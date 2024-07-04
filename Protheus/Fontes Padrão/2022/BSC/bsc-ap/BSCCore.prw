// #######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSCCore - Objeto principal BSC - contem todas as referencias
// ---------+------------------------+----------------------------------------------------
// Data     | Autor             	 | Descricao
// ---------+------------------------+----------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli  |               
// 04.01.05 | 0739 Aline Correa      | Criacao do metodo oContext.
// 24.04.09 | 3174 Valdiney V GOMES  | Alteração no método cRequest passando o XML gerado 
//									 | a ser gravado em arquivo texto antes de ser trans_
//									 | ferido. Corrige o problema de String Size Overflow. 
// 22.06.09 | 3510 Gilmar P. Santos  | Alteração do método oGetTable para ocorrer
//									 | sincronismo entre os dados das tabelas em operações
//									 | multithread. FNC 00000008745/2009
// ---------------------------------------------------------------------------------------
#include "BSCDefs.ch"
#include "BIDefs.ch"
#include "BSCCore.ch"

//  Versão do BSC do RPO
#define BSC_VERSIONS {	" 1.06.100224",; //Versão de controle N1 [Não contém update relacionado.]
						" 1.05.091117",;
						" 1.05.090626",;  
						" 1.05.090610",;
						" 1.05.090527",;
					 	" 1.04.050216",;
					  	" 1.03.040601",;
					   	" 1.02.040523" }

/*--------------------------------------------------------------------------------------
@class: TBSCObject->TBSCCore
Classe principal do BSC, eh para o BSC como o registry eh para o windows.
--------------------------------------------------------------------------------------*/
class TBSCCore from TBIObject
	
	data foLogger		// Faz o log das operações do sistema
	data foSecurity		// Objeto que rege a segurança de todos os recursos
	data foSystemVar	// Objeto que gerencia variaveis do sistema
	data fnUserCard		// Id cartao com as informações de autenticação do usuario
	data fnThread		// Numero da thread bsc, normalmente a ordem em que foi iniciada
	data fnDBStatus		// Status retornado pelo Top após abertura de tabelas
	data fcHelpServer	// Servidor de ajuda do Protheus, sera pego no INI, tag helpserver
	data fcBscPath		// Path onde o BSC está instalado, baseado em GetJobProfString()
	data faTables		// Tabelas do BSC
	data fnContextID	// ID Estrategia Atual
	data foOltpController	// Controle de transação
	data foScheduler	// Agendador de tarefas (Job)
	
	method New() constructor
	method NewBSCCore()
    
	// Versao
	method cBSCVersion()
	method lUpdateDB()
	method UpdateVersion()
	method ExecUpdate(cUpdate)
	method CreatePolicyFile()//Cria o arquivo .java.policy
	method SchedInit( lStart ) //inicializa o job do Agendador

	// Internacionalização
	method LanguageInit()

	// Base de dados
	method nDBOpen()
	method oGetTable(cEntity)
	method oAncestor(cParentType, oChildTable)
	method cGetParent(oChildTable)
	method oOltpController()
	method oContext(oChildTable, nParentId)
	
	// Login
	method nContextID()
	method lSetupCard(nCard)
	method nLogin(cUser, cPassword, cSessao)
	method xSessionValue(cVar, xValue)
	method oGetTool(cToolName)
	method lRecPassword(cUserName, cEmail) 

	// Log
	method LogInit()
	method Log(cText, nType)

	// Resposta
	method cRequest(cContent)
	method oArvore(cTipo, lIncluiPessoas, isConfigRequest, nOrgId)
	method nThread(nValue)
	method nDBStatus(nValue)
	method cHelpURL(cEntity)
	method cHelpServer()
	method cBscPath()
	method cListPessoas(nUserCod) 	
	method aListPessoas(nUserCod)

	// Desktop
	method CreateJNPL()
endclass

/*--------------------------------------------------------------------------------------
@constructor New(cBscPath)
@param cBscPath - Path de instalação do BSC. Se não for passado irá procurar no ini.
Constroe o objeto em memória.
--------------------------------------------------------------------------------------*/
method New(cBSCPath) class TBSCCore
	::NewBSCCore(cBscPath)
return
method NewBSCCore(cBscPath) class TBSCCore
	Local cBarra := cBIGetSeparatorBar() // Armazena o tipo de barra a ser utilizada

	::NewObject()
	    
	// Status padrao para inicio
	::fnDBStatus := -1
	
	// Arquivo de log (inicia no construtor para todas as threads terem o nome do log)
	::foLogger := TBIFileIO():New("bsc.log")
	::foLogger:oOwner(self)

	// SystemVar
	::foSystemVar := TBSCSystemVar():New()
	::foSystemVar:oOwner(self)
	
	// Path do BSC
	::fcBscPath := iif(empty(cBscPath), GetJobProfString("BSCPATH", "ERROR"), cBscPath)
	if(::fcBscPath=="ERROR")
		conout(STR0030+lower(GetADV97())) //"Aviso: Bscpath não definido em "
		ms_quit()
		//ExUserException("Bscpath não definido em "+lower(GetADV97()))
	else           
		// Corrige as barras caso seja necessário
		if(right(::fcBscPath,1)!=cBarra)
			::fcBscPath += cBarra
		endif	
		if(left(::fcBscPath,1)!=cBarra)
			::fcBscPath := cBarra+::fcBscPath
		endif	
	endif	

	// Arquivo de Help
	::fcHelpServer := GetSrvProfString("HELPSERVER", "ERROR")
	if(::fcHelpServer=="ERROR")
		conout(STR0031+lower(GetADV97())) //"Aviso: Helpserver não definido em "
		conout(STR0032) //"Aviso: Continuando sem acesso a ajuda no BSC."
	endif

	// Tabelas de Sistema (Classe, Grupo, Entidade, Entidade-Pai, Ponteiro para Tabela/NOT_A_TABLE)
	::faTables := {;
		{"TBSC001"		,"PARAMETROS"	,"PARAMETRO"	,""				,NIL},;
		{"TBSC002"		,"USUARIOS"		,"USUARIO"		,""				,NIL},;
		{"TBSC002A"		,"GRUPOS"		,"GRUPO"		,""				,NIL},;
		{"TBSC002B"		,"GRPUSUARIOS"	,"GRPUSUARIO"	,""				,NIL},;
		{"TBSC003"		,"REGRAS"		,"REGRA"		,""				,NIL},;
		{"TBSC004"		,"MENSAGENS"	,"MENSAGEM"		,""				,NIL},;
		{"TBSC004A"		,"DESTINATARIOS","DESTINATARIO"	,"MENSAGEM"		,NIL},;
		{"TBSC009"		,"BSCS"			,"BSC"			,""				,NIL},;
		{"TBSC010"		,"ORGANIZACOES"	,"ORGANIZACAO"	,"BSC"			,NIL},;
		{"TBSC011"		,"ESTRATEGIAS"	,"ESTRATEGIA"	,"ORGANIZACAO"	,NIL},;
		{"TBSC011A"		,"DESDOBS"		,"DESDOB"		,"ESTRATEGIA"	,NIL},;
		{"TBSC012"		,"PESSOAS"		,"PESSOA"		,"ORGANIZACAO"	,NIL},;
		{"TBSC012A"		,"PGRUPOS"		,"PGRUPO"		,"ORGANIZACAO"	,NIL},;
		{"TBSC012B"		,"GRPXPESSOAS"	,"GRPXPESSOA"	,"PGRUPO"		,NIL},;
		{"TBSC013"		,"PERSPECTIVAS"	,"PERSPECTIVA"	,"ESTRATEGIA"	,NIL},;
		{"TBSC014"		,"OBJETIVOS"	,"OBJETIVO"		,"PERSPECTIVA"	,NIL},;
		{"TBSC015"		,"INDICADORES"	,"INDICADOR"	,"OBJETIVO"		,NIL},;
		{"TBSC015A"		,"PLANILHAS"	,"PLANILHA"		,"INDICADOR"	,NIL},;
		{"TBSC015B"		,"RPLANILHAS"	,"RPLANILHA"	,"INDICADOR"	,NIL},;
		{"TBSC015C"		,"INDDOCS"		,"INDDOC"		,"INDICADOR"	,NIL},;
		{"TBSC015D"		,"INDTENDS"		,"INDTEND"		,"INDICADOR"	,NIL},;
		{"TBSC015E"		,"DWCONSULTAS"	,"DWCONSULTA"	,"INDICADOR"	,NIL},;		
		{"TBSC016"		,"METAS"		,"META"			,"INDICADOR"	,NIL},;
		{"TBSC017"		,"INICIATIVAS"	,"INICIATIVA"	,"OBJETIVO"		,NIL},;
		{"TBSC017A"		,"INIDOCS"		,"INIDOC"		,"INICIATIVA"	,NIL},;
		{"TBSC018"		,"TAREFAS"		,"TAREFA"		,"INICIATIVA"	,NIL},;
		{"TBSC018A"		,"TARDOCS"		,"TARDOC"		,"TAREFA"		,NIL},;
		{"TBSC018B"		,"TARCOBS"		,"TARCOB"		,"TAREFA"		,NIL},;
		{"TBSC020"		,"RETORNOS"		,"RETORNO"		,"TAREFA"		,NIL},;
		{"TBSC021"		,"DATASRCS"		,"DATASRC"		,"INDICADOR"	,NIL},;
		{"TBSC022"		,"AVALIACOES"	,"AVALIACAO"	,"INDICADOR"	,NIL},; 
		{"TBSC023"		,"FCSINDS"		,"FCSIND"		,"FCS"			,NIL},;
		{"TBSC023A"		,"FCSPLANS"		,"FCSPLAN"		,"FCSIND"		,NIL},;
		{"TBSC023B"		,"FCSRPLANS"	,"FCSRPLAN"		,"FCSIND"		,NIL},;
		{"TBSC023C"		,"FCDDOCS"		,"FCSDOC"		,"FCSIND"		,NIL},;
		{"TBSC023D"		,"FCSMETAS"		,"FCSMETA"		,"FCSIND"		,NIL},;
		{"TBSC023E"		,"FCSDATASRCS"	,"FCSDATASRC"	,"FCSIND"		,NIL},;
		{"TBSC023F"		,"FCSAVALIACOES","FCSAVALIACAO"	,"FCSIND"		,NIL},; 
		{"TBSC024"		,"FCSS"			,"FCS"			,"OBJETIVO"		,NIL},;
		{"TBSC030"		,"DASHBOARDS"	,"DASHBOARD"	,"ESTRATEGIA"	,NIL},;
		{"TBSC031" 		,"GRAPHS"		,"GRAPH"		,"ESTRATEGIA"	,NIL},;
		{"TBSC030A"		,"CARDS"		,"CARD"			,"DASHBOARD"	,NIL},;
		{"TBSC040"		,"FERRAMENTAS"	,"FERRAMENTA"	,"ESTRATEGIA"	,NIL},;
		{"TBSC041"		,"MAPAESTS"		,"MAPAEST"		,"FERRAMENTA"	,NIL},;
		{"TBSC041A"		,"TEMASEST"		,"TEMAEST"		,"ESTRATEGIA"	,NIL},;
		{"TBSC041B"		,"TEMSESTOBJ"	,"TEMESTOBJ"	,"TEMAEST"		,NIL},;
		{"TBSC041C"		,"MAPATEMAS"	,"MAPATEMA"		,"PERSPECTIVA"	,NIL},;
		{"TBSC041D"		,"TEMAOBJETIVOS","TEMAOBJETIVO" ,"MAPATEMA"		,NIL},;
		{"TBSC042"		,"CENTRAIS"		,"CENTRAL"		,"FERRAMENTA"	,NIL},;
		{"TBSC043"		,"DRILLS"		,"DRILL"		,"FERRAMENTA"	,NIL},;
		{"TBSC044"		,"DRILLINDS"	,"DRILLIND"		,"FERRAMENTA"	,NIL},;
		{"TBSC045"		,"DRILLOBJS"	,"DRILLOBJ"		,"FERRAMENTA"	,NIL},;
		{"TBSC046"		,"MAPAOBJS"		,"MAPAOBJ"		,"FERRAMENTA"	,NIL},;
		{"TBSC050"		,"RELATORIOS"	,"RELATORIO"	,"ESTRATEGIA"	,NIL},;
		{"TBSC051"		,"RELESTS"		,"RELEST"		,"RELATORIO"	,NIL},;
		{"TBSC052"		,"RELTARS"		,"RELTAR"		,"RELATORIO"	,NIL},;
		{"TBSC053"		,"RELINDS"		,"RELIND"		,"RELATORIO"	,NIL},;
		{"TBSC054"		,"REL5W2HS"		,"REL5W2H"		,"RELATORIO"	,NIL},;
		{"TBSC055"		,"RELBOOKSTRAS"	,"RELBOOKSTRA"	,"RELATORIO"	,NIL},;
		{"TBSC056"		,"RELEVOLS"		,"RELEVOL"		,"RELATORIO"	,NIL},;
		{"TBSC060"		,"REUNIOES"		,"REUNIAO"		,"ORGANIZACAO"	,NIL},;
		{"TBSC061"		,"REUCONS"		,"REUCON"		,"REUNIAO"		,NIL},;
		{"TBSC062"		,"REURETS"		,"REURET"		,"REUNIAO"		,NIL},;
		{"TBSC063"		,"REUPAUS"		,"REUPAU"		,"REUNIAO"		,NIL},;
		{"TBSC064"		,"REUDOCS"		,"REUDOC"		,"REUNIAO"		,NIL},;
		{"TBSC070"		,"DESKTOPS"		,"DESKTOP"		,""				,NIL},;
		{"TBSC080"		,"SMTPCONFS"	,"SMTPCONF"		,""				,NIL},;
		{"TBSC082"		,"AGENDAMENTOS"	,"AGENDAMENTO"	,""				,NIL}}

return

/*-------------------------------------------------------------------------------------
@property cBSCVersion()
Retorna a versao do RPO do bsc.
@return - . .f. se usuario invalido.
--------------------------------------------------------------------------------------*/
method cBSCVersion() class TBSCCore
return BSC_VERSIONS[1]

function cBSCVersion()
return BSC_VERSIONS[1]

/*-------------------------------------------------------------------------------------
@method lUpdateDB()
Funcao inicializa base de dados do BSC.
Checa as estruturas das tabelas, atualizando-as se necessário.
@return - .t. se for a primeira abertura da base
--------------------------------------------------------------------------------------*/
method lUpdateDB() class TBSCCore
	local oTable, nInd, lFirstBase := .t.
	
	::Log(STR0001, BSC_LOG_SCRFILE)/*//"Verificando a base de dados..."*/
	::nDBStatus(nBIOpenDBIni(nil,, { |x| ::Log(x, BSC_LOG_SCRFILE) }))
	if(::nDBStatus() >= 0)
		// Se a versão do banco de dados for superior a do RPO, não permitir a execução do sistema
		oTable := TBSC001():New()
		if(oTable:lExists())
			oTable:lOpen()
			oTable:lSeek(1,{"BSCDBVERSION"})
			if(!oTable:lEof())
				if( oTable:cValue("DADO") > ::cBSCVersion() )
					::Log(STR0016, BSC_LOG_SCRFILE)/*//"Erro: RPO SigaBSC mais antigo do que a base. Impossivel inicializar."*/
					::nDBStatus(-999)
				endif
			endif
			oTable:Free()
		endif
	endif

	if(::nDBStatus() >= 0)
		for nInd := 1 to len(::faTables)
			oTable := &(::faTables[nInd][1]+"():New()")
			oTable:bLogger({|x| ::Log(x, BSC_LOG_SCRFILE)})
			if(oTable:lExists())
				lFirstBase := .f.
			endif
			oTable:ChkStruct(.t.)
			oTable:Free()
		next

		::Log(STR0002, BSC_LOG_SCRFILE)/*//"Verificando indices..."*/
		for nInd := 1 to len(::faTables)
			oTable := &(::faTables[nInd][1]+"():New()")
			oTable:bLogger({|x| ::Log(x, BSC_LOG_SCRFILE)})
			oTable:lOpen(.t., .t.)
			oTable:Free()
		next

		// Remoção de todos os registros temporários (ID==0)
		for nInd := 1 to len(::faTables)
			oTable := &(::faTables[nInd][1]+"():New()")
			oTable:bLogger({|x| ::Log(x, BSC_LOG_SCRFILE)})
			oTable:lOpen(.t., .t.)
			if(oTable:cTablename()!="BSC001")
				if(oTable:lSeek(1, {0}))
					oTable:lDelete()
				endif
			endif	
			oTable:Free()
		next


		::Log(STR0005, BSC_LOG_SCRFILE)/*//"Verificacao da base concluída..."*/

		BICloseDB()

	else
		::Log(STR0006, BSC_LOG_SCRFILE)/*//"Erro ao verificar base de dados..."*/
	endif                        

return lFirstBase

/*-------------------------------------------------------------------------------------
@method UpdateVersion(lFirstBase)
@param lFirstBase - Indica se a base foi criada pela primeira vez ou já existiam
Atualiza os dados do BSC se necessário.
--------------------------------------------------------------------------------------*/
method UpdateVersion(lFirstBase) class TBSCCore
	local oVersion, aVersions, oTable, nI, aUpdate

	// Abre todas as Tabelas Exclusivas (.t.)
	if(::nDBOpen(.T.) < 0)
		::Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
		::Log("  ")
		return
	endif

	if(lFirstBase)
		// Cria registro do release BSC
		oTable := ::oGetTable("PARAMETRO")
		oTable:lAppend({ {"CHAVE", "BSCDBVERSION"}, {"TIPO", "C"}, {"DADO", ::cBSCVersion()} })

		// Cria BSC ADMIN default na base
		oTable := ::oGetTable("USUARIO")
		oTable:lAppend({ {"ID", 1}, {"PARENTID", 0}, {"CONTEXTID", 0}, {"NOME", "BSCADMIN"}, {"SENHA", cBIStr2Hex(pswencript("BSC"))}, {"COMPNOME", STR0003}, {"ADMIN", .t.} })/*//"Administrador"*/
		
		// Cria "Nova Organização" default na base
		oTable := ::oGetTable("ORGANIZACAO")
		if(oTable:nRecCount()==0)
			oTable:lAppend({ {"ID", 1}, {"NOME", STR0004} }) // "Nova Organização"
		endif
	else
		oVersion := ::oGetTable("PARAMETRO")
		if(!oVersion:lSeek(1,{"BSCDBVERSION"}))
			oVersion:lAppend({ {"CHAVE", "BSCDBVERSION"}, {"TIPO", "C"}, {"DADO", " 0.00.000000"} })
		endif

		// Vetor com as últimas atualizações
		aVersions := BSC_VERSIONS
                                
		// Vetor com as atualizações que deve ser executadas
		aUpdate := {}
		for nI := len(aVersions) to 1 step -1
			if( oVersion:cValue("DADO") < aVersions[nI] )
				aadd(aUpdate,aVersions[nI])
			endif
		next

		// Executa as atualizações necessárias			
		for nI := 1 to len(aUpdate)
			::ExecUpdate(aUpdate[nI])
			oVersion:lUpdate({ {"DADO", aUpdate[nI]} })
		next
			
	endif                                               
	
	//Fecha Tabelas
	BICloseDB()

	::Log(STR0029, BSC_LOG_SCRFILE)/*//"Atualização dos dados concluída..."*/

return

/*-------------------------------------------------------------------------------------
@method ExecUpdate(cUpdate)
Executa atualização informada
@param cUpdate - Versão a ser atualizada
--------------------------------------------------------------------------------------*/
method ExecUpdate(cUpdate) class TBSCCore
	local oTable, nI, nJ, aCampos, oReuniao, oOldReuniao, oAta, oConvoca, oCobranca
	local cNome, cAssunto, dDataR, cHoraR, cLocal, cAta, nParentId, nOldId, nPessoaId, nId
	local oMeta, oIndicador, oPlanilha, oRelEvol, oRelInd
	do case
		case cUpdate == " 1.02.040523"
			// Criptografa senhas já cadastradas
			oTable := ::oGetTable("USUARIO")
			oTable:_First()
			while(!oTable:lEof())
				oTable:lUpdate( {{ "SENHA", cBIStr2Hex(pswencript(alltrim(oTable:cValue("SENHA")))) }} )
				oTable:_Next()
	        enddo
	        
	        // Atualiza reunioes antigas(de iniciativas) para reunioes modernas (raíz do bsc)
			::Log(STR0033, BSC_LOG_SCRFILE) //"Iniciando a atualização da Tabela de Reuniões..."
	        oReuniao := ::oGetTable("REUNIAO")
	        oOldReuniao := TBITable():New("BSC019")
	        oCobranca := TBITable():New("BSC019A")
			if(oCobranca:lExists())
				oCobranca:lOpen()
			endif
			oIniciativa := ::oGetTable("INICIATIVA")
			
			if(oOldReuniao:lExists() .And. oOldReuniao:lOpen())
				oOldReuniao:_First()
				while(!oOldReuniao:lEof())
					cNome	:= oOldReuniao:cValue("NOME")
					cAssunto:= oOldReuniao:cValue("ASSUNTO")
					dDataR	:= oOldReuniao:dValue("DATAR")
					cHoraR	:= oOldReuniao:cValue("HORAR")
					cLocal	:= oOldReuniao:cValue("LOCAL")
					cAta	:= oOldReuniao:cValue("ATA")
					nOldID	:= oOldReuniao:nValue("ID")
					nParentID := oOldReuniao:nValue("PARENTID")
					oIniciativa:lSeek(1,{nParentId})
					nParentID := ::oAncestor("ORGANIZACAO",oIniciativa):nValue("ID")
					nID := oReuniao:nMakeID()
					oReuniao:lAppend( {	{"ID", nID}, ;
										{"PARENTID", nParentID}, ;
										{"NOME", cNome}, ;
										{"DETALHES", cAssunto}, ;
										{"DATAREU", dDataR}, ;
										{"HORAINI", cHoraR}, ;
										{"LOCAL", cLocal} })

					if(!empty(cAta))
						oAta := ::oGetTable("REUDOC")
						oAta:lAppend( {	{"ID", oAta:nMakeID()}, ;
										{"PARENTID", nID}, ;
										{"NOME", "ATA"}, ;
										{"DESCRICAO", cAta} })
					endif
					
					if(oCobranca:lExists())
						oConvoca := ::oGetTable("REUCON")
						oCobranca:cSQLFilter("PARENTID = "+cBIStr(nOldID)) // Filtra pelo pai
						oCobranca:lFiltered(.t.)
						oCobranca:_First()
						while(!oCobranca:lEof())
							nPessoaID	:= oCobranca:nValue("PESSOAID")
							oConvoca:lAppend({	{"ID", oConvoca:nMakeID()}, ;
												{"PARENTID", nID}, ;
												{"PESSOAID", nPessoaID} })
							oCobranca:_Next()
						enddo
						oCobranca:cSQLFilter("") // Limpa Filtro pelo pai
					endif
					oOldReuniao:_Next()
				enddo
	        endif
			::Log(STR0034, BSC_LOG_SCRFILE) //"Concluída a atualização da Tabela de Reuniões..."
		case cUpdate == " 1.03.040601"
			aCampos := {{"GRUPO"		,{"NOME"}},;
						{"BSC"			,{"NOME"}},;
						{"ORGANIZACAO"	,{"NOME"}},;
						{"ESTRATEGIA"	,{"NOME"}},;
						{"PESSOA"		,{"NOME"}},;
						{"PERSPECTIVA"	,{"NOME"}},;
						{"OBJETIVO"		,{"NOME"}},;
						{"INDICADOR"	,{"NOME"}},;
						{"META"			,{"NOME"}},;
						{"INICIATIVA"	,{"NOME"}},;
						{"INIDOC"		,{"NOME"}},;
						{"TAREFA"		,{"NOME","LOCAL"}},;
						{"TARDOC"		,{"NOME"}},;
						{"RETORNO"		,{"NOME"}},;
						{"DATASRC"		,{"NOME"}},;
						{"AVALIACAO"	,{"NOME"}},;
						{"DASHBOARD"	,{"NOME"}},;
						{"REUNIAO"		,{"NOME"}}}

			for nI := 1 to len(aCampos)
				oTable := ::oGetTable(aCampos[nI,1])
				for nJ := 1 to len(aCampos[nI,2])
					oTable:NoSensitiveUpdate(aCampos[nI,2,nJ])
				next                       
			next

			::Log(STR0035, BSC_LOG_SCRFILE) //"Iniciando a atualização das Planilhas..."
			oPlanilha := ::oGetTable("PLANILHA")
			oPlanilha:_First()
			while(!oPlanilha:lEof())           
				if(oPlanilha:nValue("PARCELA")==0)
					oPlanilha:xValue("PARCELA", oPlanilha:nValue("MONTANTE"))
				endif
				oPlanilha:xValue("ANO", strzero(oPlanilha:nValue("ANO"),4))
				oPlanilha:xValue("MES", strzero(oPlanilha:nValue("MES"),2))
				oPlanilha:xValue("DIA", strzero(oPlanilha:nValue("DIA"),2))
				oPlanilha:_Next()
			enddo                
			::Log(STR0036, BSC_LOG_SCRFILE) //"Concluída a atualização das Planilhas..."

			::Log(STR0037, BSC_LOG_SCRFILE) //"Iniciando recálculo das planilhas..."
			oMeta := ::oGetTable("META")
			oIndicador := ::oGetTable("INDICADOR")
			oIndicador:_First()
			while(!oIndicador:lEof())
				if(oMeta:lSoftSeek(3,{oIndicador:nValue("ID")}))
					if(oMeta:nValue("PARENTID")==oIndicador:nValue("ID"))
						oIndicador:lUpdate({{"ASCEND",oMeta:nValue("AZUL1")>=oMeta:nValue("VERMELHO")}})
					else
						oIndicador:lUpdate({{"ASCEND",.t.}})
					endif 
				else
					oIndicador:lUpdate({{"ASCEND",.t.}})
				endif
				oIndicador:lUpdate({{"RFREQ",oIndicador:nValue("FREQ")}})
				
				::oGetTable("PLANILHA"):nRecalcula(oIndicador:nValue("ID"))
		
				::oGetTable("RPLANILHA"):nDelIndicador(oIndicador)
				::oGetTable("RPLANILHA"):nInsIndicador(oIndicador)
				
				oIndicador:_Next()
			enddo                
			::Log(STR0038, BSC_LOG_SCRFILE) //"Concluído o recálculo das planilhas..."
				
		case cUpdate == " 1.04.050216"
			::Log(STR0039, BSC_LOG_SCRFILE) //"Iniciando a atualização de Metas Parceladas..."
			oMeta := ::oGetTable("META")
			oMeta:_First()
			while(!oMeta:lEof())           
				if(oMeta:cValue("PARCELADA")==" ")
					oMeta:xValue("PARCELADA", "F")
				endif
				oMeta:_Next()
			enddo                
			::Log(STR0040, BSC_LOG_SCRFILE) //"Concluída a atualização de Metas Parceladas..."
		case cUpdate == " 1.05.090527"
			// atualização para importação de metas
			::Log(STR0044, BSC_LOG_SCRFILE) //"Iniciando a atualização necessária para importação de Metas via Fonte de Dados..."
			If upd090527(::oGetTable("DATASRC"))
				::Log(STR0046, BSC_LOG_SCRFILE) //"Atualização ocorreu com SUCESSO..."
			Else
				::Log(STR0045, BSC_LOG_SCRFILE) //"Atualização ocorreu com ERRO..."
			EndIF
		case cUpdate == " 1.05.090610"
			// atualização para pesos nos indicadores
			::Log(STR0047, BSC_LOG_SCRFILE) //"Iniciando a atualização necessária para a Atribuição de Pesos à Indicadores..."
			If upd090610(::oGetTable("INDICADOR"))
				::Log(STR0046, BSC_LOG_SCRFILE) //"Atualização ocorreu com SUCESSO..."
			Else
				::Log(STR0045, BSC_LOG_SCRFILE) //"Atualização ocorreu com ERRO..."
			EndIF
		case cUpdate == " 1.05.090626"
			// atualização para ordenação nos relatórios
			::Log(STR0048, BSC_LOG_SCRFILE) //"Iniciando a atualização necessária para a Atribuição de Ordens em Relatórios..."

			oRelEvol := ::oGetTable("RELEVOL")
			oRelEvol:_First()
			while(!oRelEvol:lEof())           
				oRelEvol:nValue("ORDEMOBJ", 1)
				oRelEvol:nValue("ORDEMIND", 1)
				oRelEvol:_Next()
			enddo

			oRelInd := ::oGetTable("RELIND")
			oRelInd:_First()
			while(!oRelInd:lEof())           
				oRelInd:nValue("ORDEMOBJ", 1)
				oRelInd:nValue("ORDEMIND", 1)
				oRelInd:_Next()
			enddo

			::Log(STR0046, BSC_LOG_SCRFILE) //"Atualização ocorreu com SUCESSO..."
	endcase
	
return

/*-------------------------------------------------------------------------------------
@method nDBOpen()
Inicializa as capacidades e recursos do BSC, incluindo banco de dados para uso.
É chamado pela working-thread após a inicialização da mesma.
@param lExclusive - .T. Exclusivo / .F. Compartilhado (Default)
@return - Indica o sucesso da operação.
--------------------------------------------------------------------------------------*/
method nDBOpen(lExclusive) class TBSCCore
	local nInd                                                

	default lExclusive := .f.

	::nDBStatus(nBIOpenDBIni(,,))
	if(lRet := (::nDBStatus() >= 0))

		// Controle de transação
		// Deve ser instanciado antes da abertura das tabelas
		::foOltpController := TBIOltpController():New()
		for nInd := 1 to len(::faTables)
			::faTables[nInd][5] := &(::faTables[nInd][1]+"():New()")
			::faTables[nInd][5]:oOwner(self)
			::faTables[nInd][5]:bLogger({|x| ::Log(x, BSC_LOG_SCRFILE)})
			::faTables[nInd][5]:lOpen(lExclusive)
			::faTables[nInd][5]:oOltpController(::foOltpController)
		next

		// Security
		::foSecurity := TBSCSecurity():New(self)

	else
		::Log(STR0008, BSC_LOG_SCRFILE)/*//"Erro ao tentar abrir as tabelas do BSC."*/
	endif
return ::nDBStatus()

/*-------------------------------------------------------------------------------------
@property oGetTable(cEntity)
Retorna um objeto de tabela instanciado para uso, TBIDataSet já aberto, (lOpen interno)
de acordo com o contexto do atual usuário, através de seu IDCard já credenciado.
@param cEntity - Entidade do BSC para qual será aberta a tabela.
@return - Objeto de tabela ou NIL se não conseguir abrir.
--------------------------------------------------------------------------------------*/
method oGetTable(cEntity) class TBSCCore
	local oTable, nPos

	nPos := aScan(::faTables, {|x| x[3] == cEntity})
	if(nPos!=0)
		oTable := ::faTables[nPos][5]
		if( valtype(oTable) != "O" )
			oTable := &(::faTables[nPos][1]+"():New()")
			oTable:lOpen()
		else
			// Força um refresh físico nas tabelas já abertas para garantir que alterações realizadas em 
			// threads rodando em paralelo sejam refletidas de forma correta.
		   	oTable:savePos()		
			oTable:_First()
			oTable:restPos()
		endif
		if(!oTable:lIsOpen())
			::Log(STR0009+oTable:cTablename()+"]", BSC_LOG_RAISE)/*//"Erro ao fazer uso da tabela["*/
		endif
	else
		oTable := ::oGetTool(cEntity)
	endif
return oTable

/*-------------------------------------------------------------------------------------
@property oGetTool(cToolName)
Retorna um objeto ferramenta instanciado no core, para uso em operações de incluir, alterar, carregar.
@param cEntity - Entidade do BSC para qual será aberta a tabela.
@return - Objeto de tabela ou NIL se não conseguir abrir.
--------------------------------------------------------------------------------------*/
method oGetTool(cToolName) class TBSCCore
	local oTool

	if(cToolName == "SYSTEMVAR")
		oTool := ::foSystemVar
	elseif(cToolName == "AGENDADOR")
		oTool := ::foScheduler
	elseif(cToolName == "MENSAGENS_ENVIADAS")
		oTool := TBSCMensagensEnviadas():New()
		oTool:oOwner(self)
	elseif(cToolName == "MENSAGENS_RECEBIDAS")
		oTool := TBSCMensagensRecebidas():New()
		oTool:oOwner(self)
	elseif(cToolName == "MENSAGENS_EXCLUIDAS")
		oTool := TBSCMensagensExcluidas():New()
		oTool:oOwner(self)
	elseif(cToolName == "MAPAEST2")		
		oTool := TBSCMAPA_EST2():New()
		oTool:oOwner(self)
	elseif(cToolName == "PERSP_DRILLD")	
		oTool := TBSCPERSP_DD():New()
		oTool:oOwner(self)
	elseif(cToolName == "INDICADOR_DET")
		oTool := TBSCIND_DET():New()
		oTool:oOwner(self)
	elseif(cToolName == "USERPERM")
		oTool := TBSC002C():New()
		oTool:oOwner(self)
	elseif(cToolName == "ESTEXPORT")
		oTool := TBSCEstExport():New()
		oTool:oOwner(self)
	elseif(cToolName == "ESTIMPORT")
		oTool := TBSCEstImport():New()
		oTool:oOwner(self)
	elseif(cToolName == "PROGRESSBAR")
		oTool := BSCProgressBar():New()
		oTool:oOwner(self)
	endif

return oTool

/*-------------------------------------------------------------------------------------
@property nContextID()
Retorna o ID da estratégia em que o usuário está atualmente.
@return - . .f. se usuario invalido.
--------------------------------------------------------------------------------------*/
method nContextID() class TBSCCore
return ::fnContextID

/*-------------------------------------------------------------------------------------
@property lSetupCard(nCard)
Define o cartao do usuario desta working thread.
@param nCard - Cartao a ser inserido.
@return - .t. se o usuario valido. .f. se usuario invalido.
--------------------------------------------------------------------------------------*/
method lSetupCard(nCard) class TBSCCore
return ::foSecurity:lSetupCard(nCard)

/*-------------------------------------------------------------------------------------
@method oLogin(cUser, cPassword, cSessao)
Retorna o usercard com base no usuário logado.
@param cUser - Nome de usuario para o qual sera gerado o usercard.
@param cPassword - Senha de usuario para o qual sera gerado o usercard.
@return - Usercard se usuario valido. 0 se usuario nao autorizado.
--------------------------------------------------------------------------------------*/
method nLogin(cUser, cPassword, cSessao) class TBSCCore
return ::foSecurity:nLogin(cUser, cPassword, cSessao)

/*-------------------------------------------------------------------------------------
@property xSessionValue(cVar, xValue)
Grava ou Recupera uma Variavel de uma Sessão.
@param cVar - Nome da Variavel.
@param xValue - Valor da Variavel
@return - Valor da Variavel gravada na Sessão do Usuario.
--------------------------------------------------------------------------------------*/
method xSessionValue(cVar, xValue) class TBSCCore
return ::foSystemVar:xSessionValue(cVar, xValue)

/*------------------------------------------------------------------------------------------
@method cRequest(cContent)
Atende a todas as requisições do client.
@param cContent - Conteudo XML a ser processado.
@return - Função de transferência que envia o conteúdo do arquivo texto gerado para o client.
-------------------------------------------------------------------------------------------*/
method cRequest(cContent) class TBSCCore
	local oXMLInput, oXMLOutput
	local nID,  oTable, oNode, oAttrib
	local cExecCMD, cLoadCMD, cHelpCMD, cDelCMD
	local nStatus := BSC_ST_OK, cStatusMsg := ""
	local cFileName	:= "", cFileContent := ""
	local aFiles, nItemFile := 1
	local cTempFile     

	local cError := "", cWarning := ""

	local nInd, nSecurityId, nSecParentId

	local lPwdUsuario := .F.
	
	private cTipo, aTransacoes
	
	// MEDE O TEMPO DO PARSER
	// nTime1 := round(seconds()*1000, 0)
	// conout("* Antes de parsear: " + cBIStr(nTime1))

	// Decodifica os entities predefinidos que este parser equivocadamente nao faz
	// cContent := cBIXMLDecode(cContent)

	// Testa XML Parser
	oXmlInput := XmlParser(cContent, '_', @cError, @cWarning)

	// Parseia xml in
//	CREATE oXMLInput XMLSTRING cContent;
//		SETASARRAY ;
//			_TRANSACOES:_TRANSACAO
	
	// MEDE O TEMPO DO PARSER
	// nTime2 := round(seconds()*1000, 0)
	// conout("* Depois de parsear: " + cBIStr(nTime2) + " - Total: "+cBIStr(nTime2-nTime1))

	// Cria o root de XML out
	oXMLOutput := TBIXMLNode():New("RESPOSTAS")
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("RESPOSTA"))
    
	// Verifica sucesso do parse
	nXMLStatus := XMLError()
//	if(nXMLStatus == XERROR_SUCCESS)
	if(empty(cError) .and. empty(cWarning))
		if(valtype(oXMLInput:_TRANSACOES:_TRANSACAO)!="U")
			if(valtype(oXMLInput:_TRANSACOES:_TRANSACAO)=="O")
				aTransacoes := {}
				aAdd(aTransacoes, oXMLInput:_TRANSACOES:_TRANSACAO)
			elseif(valtype(oXMLInput:_TRANSACOES:_TRANSACAO)=="A")
				aTransacoes := oXMLInput:_TRANSACOES:_TRANSACAO
			endif
			// Processa todas as transações
			for nInd := 1 to len(aTransacoes)
				do case
					// AJUDA <TIPO>                             			
					case aTransacoes[nInd]:_COMANDO:TEXT == "AJUDA"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT
						cHelpCMD := aTransacoes[nInd]:_HELPCMD:TEXT
						
						if(cHelpCMD == "POLITICA")
							::CreatePolicyFile()
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode := oNode:oAddChild(TBIXMLNode():New("AJUDA"))
							oNode:oAddChild(TBIXMLNode():New("URL",left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))+"h_bscpolicy.apw"))
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode := oNode:oAddChild(TBIXMLNode():New("AJUDA"))
							oNode:oAddChild(TBIXMLNode():New("URL", ::cHelpURL(cHelpCMD)))
						endif							
					
					// ARVORE <TIPO>
					case aTransacoes[nInd]:_COMANDO:TEXT == "ARVORE"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT
						nID	  := aTransacoes[nInd]:_ID:TEXT
						
						if(::foSecurity:lHasAccess(cTipo, 0))
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode:oAddChild(::oArvore(cTipo,,,nID))
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
						endif	
						
					// CARREGAR <TIPO> <ID>                             			
					case aTransacoes[nInd]:_COMANDO:TEXT == "CARREGAR"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT
						nID := nBIVal(aTransacoes[nInd]:_ID:TEXT)
						
						if(valtype(XmlChildEx(aTransacoes[nInd], "_LOADCMD"))!="U")
							cLoadCMD := aTransacoes[nInd]:_LOADCMD:TEXT
						endif
		                    
						if(cTipo=="DIRUSUARIOS") // Objeto abstrato
							if(::foSecurity:lHasAccess(cTipo, nID, "CARREGAR"))
								oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode := oNode:oAddChild(TBIXMLNode():New("DIRUSUARIOS"))
								oNode:oAddChild(TBIXMLNode():New("ID", 1))
								oNode:oAddChild(TBIXMLNode():New("NOME", STR0010))/*//"Diretório de Usuários"*/
								oNode:oAddChild(TBIXMLNode():New("TOTALUSUARIOS", ::oGetTable("USUARIO"):nSqlCount()))
								oNode:oAddChild(TBIXMLNode():New("TOTALGRUPOS", ::oGetTable("GRUPO"):nSqlCount()))
								oNode:oAddChild(::oGetTable("USUARIO"):oToXMLList())
								oNode:oAddChild(::oGetTable("GRUPO"):oToXMLList())
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
							endif

						elseif(cTipo=="DIRPESSOAS") // Objeto abstrato
								oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode := oNode:oAddChild(TBIXMLNode():New("DIRPESSOAS"))
								oNode:oAddChild(TBIXMLNode():New("ID", 1))
								oNode:oAddChild(TBIXMLNode():New("NOME", "Diretório de Pessoas"))
								oNode:oAddChild(::oGetTable("PESSOA"):oToXMLList())
								oNode:oAddChild(::oGetTable("PGRUPO"):oToXMLList())
								oNode:oAddChild(::oGetTable("ORGANIZACAO"):oToXMLList())
	
						elseif(cTipo=="AGENDADOR") // Objeto abstrato
							if(::foSecurity:lHasAccess(cTipo, nID, "CARREGAR"))
								oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode := oNode:oAddChild(TBIXMLNode():New("AGENDADOR"))
								oNode:oAddChild(TBIXMLNode():New("ID", 1))
								oNode:oAddChild(TBIXMLNode():New("CONTEXTID", 1))
								oNode:oAddChild(TBIXMLNode():New("NOME", STR0015))/*//"Lista de Agendamentos"*/
								oNode:oAddChild(TBIXMLNode():New("SITUACAO",::foScheduler:isRunning()))
								oNode:oAddChild(::oGetTable("AGENDAMENTO"):oToXMLList())
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
							endif
						elseif(cTipo=="DESKTOP")
							oTable := ::oGetTable(cTipo)
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode:oAddChild(oTable:oToXMLNode())

						elseif(cTipo=="PWDUSUARIO")
							oTable := ::oGetTable("USUARIO")
							
							if( nID > 0 .AND. oTable:lSeek(1, {nID}) )
								oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode:oAddChild(oTable:oToXMLNode(nID, cLoadCMD))
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_BADID))
							endif 
							
						elseif(cTipo=="LISTA_ORGANIZACAO") 
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode := oNode:oAddChild(TBIXMLNode():New("ORGANIZACOES"))
							oNode:oAddChild(TBIXMLNode():New("NOME", "ORGANIZACAO"))       
							oNode:oAddChild(::oGetTable("ORGANIZACAO"):oToXMLList())
                        
                        else
							oTable := ::oGetTable(cTipo)
							
							/*Inclusão*/
							If (nID == 0)
								  
								If	!(valtype(XmlChildEx(aTransacoes[nInd], "_PARENTID")) == "U")
									nParentID := nBIVal(aTransacoes[nInd]:_PARENTID:TEXT)  
								Else
									nParentID := 0
								EndIf

								if substr(cTipo, 1, 6) != "MENSAG"
									cTipo := ::cGetParent(::oGetTable(cTipo))
								endif
								
								if(::foSecurity:lHasAccess(cTipo, nParentID, "CARREGAR"))
									oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
									oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
									if( !oTable:lSeek(1, {0}) )
										while( !oTable:lAppend({{"ID", 0}, {"PARENTID", 0}, {"CONTEXTID", 0} }) )
											sleep(500)
										end
									endif
									oNode:oAddChild(oTable:oToXMLNode(nParentID, "_BLANK"))
								else
									oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
								endif
							elseif(cTipo=="PLANILHA" .or. ;
								cTipo=="RPLANILHA" .or. ;
								cTipo=="FCSPLAN" .or. ;
								cTipo=="FCSRPLAN" .or. ;
								cTipo=="BSC" .or. ;
								cTipo=="MAPAEST" .or. ;
								cTipo=="MAPAOBJ" .or. ;
								cTipo=="CENTRAL" .or. ;
								cTipo=="DRILL" .or. ;
								cTipo=="DRILLIND" .or. ;
								cTipo=="DRILLOBJ" .or. ;
								cTipo=="RELEST" .or. ;
								cTipo=="RELTAR" .or. ;
								cTipo=="REL5W2H" .or. ;
								cTipo=="RELIND" .or. ;
								cTipo=="RELBOOKSTRA" .or. ;
								cTipo=="RELEVOL" .or. ;
								cTipo=="SMTPCONF" .or.;
								cTipo=="MAPATEMA" .or.;
								cTipo=="MAPAEST2" .or.;
								cTipo=="PERSP_DRILLD".or.;
								cTipo=="INDICADOR_DET".or.;
								cTipo=="USERPERM".or.;
								cTipo=="MENSAGEM" .or.;
								cTipo=="MENSAGENS_ENVIADAS" .or.;
								cTipo=="MENSAGENS_RECEBIDAS" .or.;
								cTipo=="MENSAGENS_EXCLUIDAS" .or.;
								cTipo=="ESTIMPORT" .or.;
								cTipo=="ESTEXPORT")
								// Tabela virtual
								if(::foSecurity:lHasAccess(cTipo, nID, "CARREGAR"))
									oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
									oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
									oNode:oAddChild(oTable:oToXMLNode(nID, cLoadCMD))
								else
									oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
								endif                      
							elseif(oTable:lSeek(1, {nID}))
								// Tabela real
								::foSecurity:foUserTable:SavePos()
								if(::foSecurity:lHasAccess(cTipo, nID, "CARREGAR"))
									::foSecurity:foUserTable:RestPos()
									oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
									oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
									oNode:oAddChild(oTable:oToXMLNode(nID, cLoadCMD))
								else
									oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
								endif
							else
								//Caso o ID seja menos 1 nao e necessario possicionar na tabela para retornar o registro.
								if(nID == -1)
									oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
									oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
									oNode:oAddChild(oTable:oToXMLNode(nID, cLoadCMD))
								else
									oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_BADID))
								endif
							endif	
						endif
					
					// INCLUIR <TIPO>
					case aTransacoes[nInd]:_COMANDO:TEXT == "INCLUIR"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT
						cArvore := aTransacoes[nInd]:_ARVORETIPO:TEXT						
			            cOrganizacao := aTransacoes[nInd]:_ORGANIZACAO:TEXT
			            
						oTable := ::oGetTable(cTipo) 
						
						if(cTipo == "REUNIAO" .or. cTipo == "PESSOA" .or. cTipo == "PGRUPO" .or. cTipo == "ORGANIZACAO" .or. cTipo=="ESTRATEGIA")
							nSecurityId := nBIVal(&("aTransacoes["+str(nInd)+"]:_REGISTROS:_"+cTipo+":_PARENTID:TEXT"))
						else
							nSecurityId := nBIVal(&("aTransacoes["+str(nInd)+"]:_REGISTROS:_"+cTipo+":_CONTEXTID:TEXT"))
						endif  
						
						nSecParentId:= nBIVal(&("aTransacoes["+str(nInd)+"]:_REGISTROS:_"+cTipo+":_PARENTID:TEXT"))						
						
						if(::foSecurity:lHasAccess(cTipo, nSecurityId, "INCLUIR", nSecParentId))
							// Tabela de objeto
							nStatus := oTable:nInsFromXML(aTransacoes[nInd], "_REGISTROS:_"+cTipo) 
							
							if(nStatus==BSC_ST_OK)
								oNode:oAddChild(TBIXMLNode():New("ID", oTable:nValue("ID")))
							else
								cStatusMsg := oTable:cMsg()
							endif	
							
							// Status
							oAttrib := TBIXMLAttrib():New()
							oAttrib:lSet("MSG", cStatusMsg)
							oNode:oAddChild(TBIXMLNode():New("STATUS", nStatus, oAttrib))
							
							// Arvore e atualizações
							oUsuarios := ::foSecurity:oLoggedUser() 
							
							If cArvore == "USUARIO" .or. oUsuarios:cValue("UPDTREE")	== "F"
								oNode := oNode:oAddChild(TBIXMLNode():New("ATUALIZACOES"))
								oNode:oAddChild(::oArvore(cArvore,,,cOrganizacao))									
							endif
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
						endif	
			
					// ALTERAR <TIPO>
					case aTransacoes[nInd]:_COMANDO:TEXT == "ALTERAR"
						cTipo 	:= aTransacoes[nInd]:_TIPO:TEXT
						cArvore := aTransacoes[nInd]:_ARVORETIPO:TEXT						
						cOrganizacao := aTransacoes[nInd]:_ORGANIZACAO:TEXT
						
						if(cTipo!="SYSTEMVAR")
							nID   := nBIVal(&("aTransacoes["+str(nInd)+"]:_REGISTROS:_"+cTipo+":_ID:TEXT"))
							
							if(cTipo!="PLANILHA" .and. cTipo!="RPLANILHA" .and. cTipo!="FCSPLAN" .and. cTipo!="FCSRPLAN" .and. cTipo!="USERPERM")
								nSecParentId:= nBIVal(&("aTransacoes["+str(nInd)+"]:_REGISTROS:_"+cTipo+":_PARENTID:TEXT"))
							else
								nSecParentId := nId
							endif   
							
						else   
						
							nID   := 0
							nSecParentId := 0
						endif

						if(cTipo == "PWDUSUARIO")
							lPwdUsuario := .T.
						else
							lPwdUsuario := .F.
						endif
		
						if(lPwdUsuario .OR. ::foSecurity:lHasAccess(cTipo, nID, "ALTERAR", nSecParentId))
							// Tabela de objeto

							if(lPwdUsuario)
								oTable := ::oGetTable("USUARIO")
							else
								oTable := ::oGetTable(cTipo)
							endif

							nStatus := oTable:nUpdFromXML(aTransacoes[nInd], "_REGISTROS:_"+cTipo)
							
							if(nStatus!=BSC_ST_OK)
								cStatusMsg := oTable:cMsg()
							endif
							
							// Status
							oAttrib := TBIXMLAttrib():New()
							oAttrib:lSet("MSG", cStatusMsg)
							oNode:oAddChild(TBIXMLNode():New("STATUS", nStatus, oAttrib))
							
							// Arvore e atualizações
							oUsuarios := ::foSecurity:oLoggedUser()
							
							If cArvore == "USUARIO" .or. oUsuarios:cValue("UPDTREE")== "F"
								oNode := oNode:oAddChild(TBIXMLNode():New("ATUALIZACOES"))
								oNode:oAddChild(::oArvore(cArvore,,,cOrganizacao))
							endif  
							
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
						endif	
			
					// EXCLUIR <TIPO> <ID>
					case aTransacoes[nInd]:_COMANDO:TEXT == "EXCLUIR"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT
						cArvore := aTransacoes[nInd]:_ARVORETIPO:TEXT
						nID := nBIVal(aTransacoes[nInd]:_ID:TEXT)  
						cOrganizacao := aTransacoes[nInd]:_ORGANIZACAO:TEXT
						
						if(valtype(XmlChildEx(aTransacoes[nInd], "_DELCMD"))!="U")
							cDelCMD := aTransacoes[nInd]:_DELCMD:TEXT
						endif
						
						if(::foSecurity:lHasAccess(cTipo, nID, "EXCLUIR"))
							// Tabela de objeto
							oTable := ::oGetTable(cTipo)
							nStatus := oTable:nDelFromXML(nID, cDelCMD)

							if(nStatus==BSC_ST_OK)
								oNode:oAddChild(TBIXMLNode():New("ID", oTable:nValue("ID")))
							else
								cStatusMsg := oTable:cMsg()
							endif	

							// Status
							oAttrib := TBIXMLAttrib():New()
							oAttrib:lSet("MSG", cStatusMsg)
							oNode:oAddChild(TBIXMLNode():New("STATUS", nStatus, oAttrib))
			
							// Arvore e atualizações
							oUsuarios := ::foSecurity:oLoggedUser()
							If cArvore == "USUARIO" .or. oUsuarios:cValue("UPDTREE")	== "F"
								oNode := oNode:oAddChild(TBIXMLNode():New("ATUALIZACOES"))
								oNode:oAddChild(::oArvore(cArvore,,,cOrganizacao))
							Else
								
							Endif
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
						endif	
						
					// EXECUTAR <TIPO> <ID>
					case aTransacoes[nInd]:_COMANDO:TEXT == "EXECUTAR"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT
						nID := nBIVal(aTransacoes[nInd]:_ID:TEXT)
						cExecCMD := aTransacoes[nInd]:_EXECCMD:TEXT
						
						if(::foSecurity:lHasAccess(cTipo, nID, "EXECUTAR"))
							// Tabela de objeto
							oTable := ::oGetTable(cTipo)
							nStatus := oTable:nExecute(nID, cExecCMD)
							//if(nStatus!=BSC_ST_OK)
								cStatusMsg := oTable:cMsg()
							//endif

							// Status
							oAttrib := TBIXMLAttrib():New()
							oAttrib:lSet("MSG", cStatusMsg)
							oNode:oAddChild(TBIXMLNode():New("STATUS", nStatus, oAttrib))
			
							// Arvore e atualizações
							oNode := oNode:oAddChild(TBIXMLNode():New("ATUALIZACOES"))
							oNode:oAddChild(::oArvore(cTipo))
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NORIGHTS))
						endif	
			
					// SALVARBASE64 <SALVARBASE64>
					case aTransacoes[nInd]:_COMANDO:TEXT == "SALVARBASE64"
						cFileName 	 := aTransacoes[nInd]:_FILENAME:TEXT
						cFileContent := aTransacoes[nInd]:_FILECONTENT:TEXT
		
						// Gera arquivo 	
						oFile := TBIFileIO():New(::cBscPath()+ "\" +cFileName )
		
						// Cria o arquivo 
						if ! oFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
							::Log(STR0013 + cFileName , BSC_LOG_SCRFILE)//"Erro na criação do arquivo."
							::Log(STR0014, BSC_LOG_SCRFILE)//"Operação abortada."
							oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_INUSE))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							return
						endif
		
						oFile:nWriteLN(decode64(cFileContent))
						oFile:lClose()
		
						oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
						oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
		
					//LISTAR ARQUIVOS <LISTAR ARQUIVOS>
					case aTransacoes[nInd]:_COMANDO:TEXT == "LISTARARQUIVOS"
						cFileLocal 	 := ::cBscPath()+ "\" + aTransacoes[nInd]:_LOCAL:TEXT
					    aFiles := directory(cFileLocal)
		
						oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_OK))
						oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
					
						oNode := oNode:oAddChild(TBIXMLNode():New("FILE"))
						oNode := oNode:oAddChild(TBIXMLNode():New("ARQUIVOS"))
		
						nFiles := len(aFiles)
						for nItemFile:=1 to nFiles 
							oNodeLine := oNode:oAddChild(TBIXMLNode():New("ARQUIVO"))
							oNodeLine:oAddChild(TBIXMLNode():New("NAME",	lower(aFiles[nItemFile][1])))
							oNodeLine:oAddChild(TBIXMLNode():New("SIZE",	str(aFiles[nItemFile][2]/1024,10,2)+ " Kb"))
							oNodeLine:oAddChild(TBIXMLNode():New("DATE",	dToc(aFiles[nItemFile][3]) + " " + aFiles[nItemFile][4]))
						next nItemFile
										
					// COMANDO NAO ENVIADO
					otherwise
						oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NOCMD))
						
				endcase
			next
		else
			// Nao ha nenhuma transacao
			oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_NOTRANSACTION))
		endif			
	else
		// Erro no parse
		oNode:oAddChild(TBIXMLNode():New("STATUS", BSC_ST_BADXML))
		if(!empty(cError))
			::Log(STR0041 + cError, BSC_LOG_SCRFILE) //"Erro no Parse "
		endif
		if(!empty(cWarning))
			::Log(STR0041 + cWarning, BSC_LOG_SCRFILE) //Aviso no Parse "
		endif
	endif
	    
    /*Cria um arquivo temporário único para cada  requisição utilizando funções do DW (HTMLLIB.PRG).*/   
    cTempFile := 'bsc' + randByTime() + dwStr(randomize(1,50)) + '.xml' 
    /*Persiste o XML gerado em um arquivo texto (bsc.xml) no StartPath do Protheus.*/
    oXMLOutput:XMLFile(cTempFile,.T.,"ISO-8859-1")
	/*Transfere o conteúdo do arquivo via HTTP.*/ 
return BIFileTransfer( cTempFile, BSCIsDebug())

/*-------------------------------------------------------------------------------------
@method LogInit()
Inicializa o arquivo de log do BSC.
--------------------------------------------------------------------------------------*/
method LogInit() class TBSCCore
	if(!::foLogger:lExists())
		if(!::foLogger:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.))
			::Log(STR0011+::foLogger:cFileName(), BSC_LOG_RAISE)/*//"Erro na criação do arquivo: "*/
			::foLogger:lClose()
		endif	
	endif
return

/*-------------------------------------------------------------------------------------
@method SchedInit()
Inicializa o Scheduler junto com o BSC.
--------------------------------------------------------------------------------------*/
method SchedInit( lStart ) class TBSCCore
	::foScheduler := TBSCScheduler():New(GetJobProfString("INSTANCENAME", "BSC"))
	if(lStart .and. !::foScheduler:isRunning())
		::foScheduler:Start()
	endif
return

/*-------------------------------------------------------------------------------------
@method Log(cText, nType)
Grava o log do BSC.
@param cText - Texto a ser trabalhado(logado).
@param nType - Constante identificando a operacao de log (default: BSC_LOG_SCR).
BSC_LOG_SCR - Somente apresenta na console.
BSC_LOG_FILE - Somente grava no arquivo de log.
BSC_LOG_RAISE - Grava no arquivo de log e levanta exceção no Protheus.
BSC_LOG_SCRFILE - Apresenta na console e grava no arquivo de log.
--------------------------------------------------------------------------------------*/
method Log(cText, nType) class TBSCCore
return BSCLogInFile(::foLogger, cText, nType)

/*-------------------------------------------------------------------------------------
@property nThread(nValue)
Define/recupera o numero da thread bsc a qual pertence este obj bsccore.
@param nValue - Numerico indicando a ordem de abertura da thread.
@return - Numerico indicando a ordem de abertura da thread.
--------------------------------------------------------------------------------------*/
method nThread(nValue) class TBSCCore
	property ::fnThread := nValue
return ::fnThread

/*-------------------------------------------------------------------------------------
@property nDBStatus(nValue)
Define/recupera o numero da DBStatus bsc a qual pertence este obj bsccore.
@param nValue - Numerico indicando a ordem de abertura da DBStatus.
@return - Numerico indicando a ordem de abertura da DBStatus.
--------------------------------------------------------------------------------------*/
method nDBStatus(nValue) class TBSCCore
	property ::fnDBStatus := nValue
return ::fnDBStatus

/*-------------------------------------------------------------------------------------
@property cHelpServer()
Recupera o servidor de ajuda do Protheus, sera pego no INI, tag helpserver.
@return - Servidor de ajuda do protheus.
--------------------------------------------------------------------------------------*/
method cHelpServer() class TBSCCore
return ::fcHelpServer

/*-------------------------------------------------------------------------------------
@property cBscPath(cPath)
Define/Recupera o path no qual o bsc esta instalado.
@return - Path do bsc, a partir do rootpath.
--------------------------------------------------------------------------------------*/
method cBscPath(cPath,cPathSeparador) class TBSCCore
	default cPathSeparador := "\"
	property ::fcBscPath := cPath

	if(cPathSeparador == "\")
		return ::fcBscPath
	else
		return strTran(::fcBscPath,"\",cPathSeparador)
	endif


/*-------------------------------------------------------------------------------------
@method cHelpURL(cEntity)
Recupera a URL do Help Server.
@param cEntity - Entidade do qual se quer o help.
@return - URL do Help Server.
--------------------------------------------------------------------------------------*/
method cHelpURL(cEntity) class TBSCCore
	local aHelpPath, cHelpPath, cHelpServer, cHelpURL, nInd1

	// Matriz de paths para os helps, deve ser montada da seguinte forma:
	// cada elemento: { <chave URL 1>, <pagina Html correspondente ao help> }
	aHelpPath := 	{ ;
		{ "META_ALVO"							, "Alvos.htm"},;
		{ "ANALISE"								, "Analisando_.htm" },;
		{ "AVALIACAO"							, "Avaliacao_de_Indicadores.htm" },;
		{ "USUARIO"								, "Avaliando_Indicadores.htm" },;
		{ "ESTRATEGIAS"    						, "Cadastrando_Estrategias.htm" },;
		{ "CADASTRANDO_INICIATIVAS"				, "Cadastrando_Iniciativas.htm" },;
		{ "META"	 							, "Cadastrando_Metas.htm" },;
		{ "OBJETIVO"							, "Cadastrando_Objetivos.htm" },;
		{ "ORGANIZACOES"						, "Cadastrando_Organizacoes.htm" },;
		{ "PERSPECTIVA"							, "Cadastrando_Perspectivas.htm" },;
		{ "PESSOA_RESPONSAVEL"					, "Cadastrando_Pessoas_Responsaveis.htm" },;
		{ "DADOS"								, "Coletando_Dados.htm" },;
		{ "CONCEITOS"							, "Conceitos_e_Definicoes.htm" },;
		{ "CONFIGURACOES"						, "Configuracoes.htm" },;
		{ "CONFIGURANDO"						, "Configurando_o_AP8Srv.Ini.htm" },;
		{ "INDICADOR"							, "Criando_Medidas.htm" },;
		{ "DASHBOARD"							, "DashBoard.htm" },;
		{ "ESTRATEGIA"							, "Estrategia.htm" },;
		{ "FEEDBACKS"							, "FeedBacks.htm" },;
		{ "INICIANDO"							, "Iniciando.htm" },;
		{ "INICIATIVAS"							, "Iniciativas.htm" },;
		{ "MAPA_ESTRATEGICO1"					, "Mapa_Estrategico1.htm" },;
		{ "MAPA_ESTRATEGICO"					, "Mapa_Estrategico.htm" },;
		{ "MEDIDAS"								, "Medidas.htm" },;
		{ "MODELO_811"							, "modelo_811.htm" },;
		{ "MODELO_ORGANIZACIONAL"				, "Modelo_Organizacional.htm" },;
		{ "OBJETIVOS"							, "Objetivos.htm" },;
		{ "ORGANIZACAO"							, "Organizacao.htm" },;
		{ "PERSPECTIVAS"						, "Perspectivas.htm" },;
		{ "RELATORIOS1"							, "Relatorios1.htm" },;
		{ "RELATORIOS"							, "Relatorios.htm" },;
		{ "REQUISITOS"							, "Requisitos.htm" },;
		{ "SCORECARDS"							, "ScoreCards.htm" },;
		{ "SIGABSC"								, "SigaBSC.htm" },;
		{ "USUARIOS"							, "Usuarios_do_Sistema.htm" },;
		{ "USUARIOS_PESSOAS"					, "Usuarios_Pessoas.htm" },;
		{ "FERRAMENTA"							, "Utilizando_a_Ferramenta.htm" };
	}
	cHelpPath := "/"+cBSCLanguage()+"/sigabsc_"
	cHelpServer := lower(::cHelpServer())
	cHelpServer := strtran(cHelpServer, "/", "")
	cHelpServer := strtran(cHelpServer, "\", "")
	cHelpServer := strtran(cHelpServer, "http:", "")
	cHelpURL := "http://"+cHelpServer+cHelpPath

	// Montar help a ser carregado
	nInd1 := aScan( aHelpPath, {|x| x[1]==cEntity} )
	if(nInd1 > 0)
		if(nInd1 == 34) //sigabsc.htm
			cHelpURL := "http://"+cHelpServer+"/"+cBSCLanguage()+"/"+aHelpPath[nInd1,2]	
		else
			cHelpURL += aHelpPath[nInd1,2]
		endif
	else
		cHelpURL := "NOHELP"
	endif	
				
return cHelpURL

/*-------------------------------------------------------------------------------------
@method oArvore(cTipo, lIncluiPessoas)
Retorna a arvore do tipo pedido.
@param cTipo - Tipo da arvore a ser montada.
@param lIncluiPessoas - Define se as Organizações terão o node "Pessoas".
@return - Node XML gerado com a arvore pedida.
--------------------------------------------------------------------------------------*/
method oArvore(cTipo, lIncluiPessoas,isConfigRequest,nOrgId) class TBSCCore
	local oXMLArvore, oXMLNode, oAttrib, oTable, oXMLChild
	local cUser, cComp
	
	default lIncluiPessoas 	:= .t.
	default isConfigRequest	:= .f.
	default nOrgId			:= 0
	
	// Envia informação do usuario atualmente conectado
	oTable 	:= ::foSecurity:oLoggedUser()
	cUser 	:= alltrim(oTable:cValue("NOME"))
	cComp 	:= alltrim(oTable:cValue("COMPNOME"))

	if(cTipo != "DESKTOP")
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("USUARIO", cComp+" ("+cUser+") ")
		oXMLArvore := TBIXMLNode():New("ARVORE",,oAttrib)
	endif		

	// Se o tipo da arvore for Desktop
	if(cTipo=="DESKTOP")
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("USUARIO", cComp+" ("+cUser+") ")
		oAttrib:lSet("COD",oTable:nValue("ID") )		

		oXMLArvore := TBIXMLNode():New("ARVORE",,oAttrib)
		oXMLArvore:oAddChild(::oGetTable("DESKTOP"):oArvore())	
		oXMLArvore:oAddChild(::oGetTable("DESKTOP"):oXMLListOrgEst())				
		
	elseif(cTipo=="USUARIO" .or. cTipo=="GRUPO" .or. cTipo=="GRPUSUARIO")

		// No de configuracoes
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", "CONFIGURACOES")
		oAttrib:lSet("NOME", STR0017) //"Configurações"
		oXMLNode := oXMLArvore:oAddChild(TBIXMLNode():New("CONFIGURACOES","",oAttrib))

		// Configurações de servidor de envio
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("NOME", STR0026) //"Agendador"
		oAttrib:lSet("FEEDBACK", 0)
		oXMLChild := oXMLNode:oAddChild(TBIXMLNode():New("AGENDADOR","",oAttrib))
		//agendamentos
		oXMLChild:oAddChild(::oGetTable("AGENDAMENTO"):oArvore())

		// Configurações de servidor de envio
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("NOME", STR0027) //"Servidor de envio"
		oAttrib:lSet("FEEDBACK", 0)
		oXMLChild := oXMLNode:oAddChild(TBIXMLNode():New("SMTPCONF","",oAttrib))

		// Diretorio de usuarios
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("NOME", STR0028) //"Cadastro de Usuários"
		oAttrib:lSet("FEEDBACK", 0)
		oXMLNode := oXMLNode:oAddChild(TBIXMLNode():New("DIRUSUARIOS","",oAttrib))

		oXMLNode:oAddChild(::oGetTable("GRUPO"):oArvore())
		oXMLNode:oAddChild(::oGetTable("USUARIO"):oArvore())

	else
		oTempArvore 	:=	 ::oGetTable("ORGANIZACAO"):oArvore(nOrgId)
      
		if(isConfigRequest)
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 1)
			oAttrib:lSet("NOME", STR0017)//Configuracoes
			oXMLConfig := TBIXMLNode():New("SIS_CONFIGS","",oAttrib)

			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 1)
			oAttrib:lSet("TIPO", "SIS_ACCESSOS")		
			oAttrib:lSet("NOME", STR0018)
			oXMLMyConfig := oXMLConfig:oAddChild(TBIXMLNode():New("SIS_ACESSO","",oAttrib))
			
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 1)
			oAttrib:lSet("NOME", STR0019)//"Organização"
			oXMLMyConfig:oAddChild(TBIXMLNode():New("ACESSOS_ORGA","", oAttrib))

			oTempArvore:oAddChild(oXMLConfig)
			
		endif			
       
		oXMLArvore:oAddChild(oTempArvore)
	endif	
	
return oXMLArvore

/*-------------------------------------------------------------------------------------
@method oAncestor(cParentType, oChildTable)
Retorna uma tabela ancestral posicionada.
@param oChildTable - Tabela de entidade aberta e posicionada.
@param cParentType - Tipo da entidade a ser localizada como ancestral.
@return - Tabela de entidade ancestral de oTable.
--------------------------------------------------------------------------------------*/
method oAncestor(cParentType, oChildTable) class TBSCCore
	local oTable, nPos, nOrder, nIDFinal
	local oAncestor := ::oGetTable(cParentType)
	local nParentID := oChildTable:nValue("PARENTID")

	while(oChildTable != oAncestor)
		// Encontro tabela anterior posicionada
		nPos := aScan(::faTables, { |x| x[5] == oChildTable })
		oTable := ::oGetTable(::faTables[nPos][4])
		if(valtype(oTable)!="U")
			nOrder := oTable:nGetOrder()
			oTable:SavePos()
			oTable:lSeek(1, {nParentID})
			oTable:cSqlFilter("")
			nParentID := oTable:nValue("PARENTID")
			nIDFinal := oTable:nValue("ID")
			oChildTable := oTable
			oTable:RestPos()
		else
			exit
		endif
	end

	if(valtype(oTable)!="U")
		oChildTable:lSeek(1, {nIDFinal})
		oChildTable:SetOrder(nOrder)
	endif

return oChildTable

/*-------------------------------------------------------------------------------------
@method LanguageInit()
Escreve os arquivos properties de internacionalização do Java.
--------------------------------------------------------------------------------------*/
method LanguageInit() class TBSCCore
	local cDefault, cResource, cTexto, cLocale
	local aFiles, oPropFile, nInd, nCount
	
	// Internacionalização
	cDefault := ::cBscPath()+"International.properties"

	if ( cBSCLanguage() == "PORTUGUESE" )
		cLocale := "pt_BR"
		cResource := ::cBscPath()+"International_pt_BR.properties"
	elseif ( cBSCLanguage() == "ENGLISH" )
		cLocale := "en"
		cResource := ::cBscPath()+"International_en.properties"
	elseif ( cBSCLanguage() == "SPANISH" )
		cLocale := "es"
		cResource := ::cBscPath()+"International_es.properties"
    endif
    
	// cTexto deve ter o conteudo do arquivo properties	
	cTexto := cBSCInternational()
	
	// Arquivo default e da linguagem
	aFiles := {cDefault, cResource}
	for nInd := 1 to len(aFiles)
		oPropFile := TBIFileIO():New(aFiles[nInd])
		//if(!oPropFile:lExists())
			if(!oPropFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.))
				::Log(STR0011+oPropFile:cFileName(), BSC_LOG_RAISE)/*//"Erro na criação do arquivo: "*/
				oPropFile:lClose()
			endif	
		//endif
	
		nCount := 0
		while((!oPropFile:lOpen(FO_WRITE+FO_EXCLUSIVE)) .and. nCount<60)
			sleep(500)
			nCount++
		enddo
		if(nCount == 30)  // se nao abrir em +-15 segundos da erro no conout e libera a thread
			::Log(STR0012+oPropFile:cFileName(), BSC_LOG_RAISE) //"Aviso: Timeout expirado ao tentar gravar arquivo: "
		else
			oPropFile:nWriteLn(cTexto)
			oPropFile:lClose()
		endif
	next

return

/*-------------------------------------------------------------------------------------
@method CreatPolicyFile()
Cria o arquivo de .java.policy. Com as diretivas de seguranca para o applet.
--------------------------------------------------------------------------------------*/
method CreatePolicyFile() class TBSCCore
cFileName 	 := ".java.policy"
cFileContent := 'grant codeBase "'+ left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER)) + '-" {'					+CRLF+;
					'permission java.awt.AWTPermission "accessClipboard";' 		+CRLF+;  
					'permission java.lang.RuntimePermission "queuePrintJob";' 	+CRLF+;  
				'};'
	
// Gera arquivo 	
oFile := TBIFileIO():New(::cBscPath()+"\"+cFileName)

// Cria o arquivo 
if ! oFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
	::Log(STR0013 + cFileName , BSC_LOG_SCRFILE)//"Erro na criação do arquivo."
	::Log(STR0014, BSC_LOG_SCRFILE)//"Operação abortada."
else
	oFile:nWriteLN(cFileContent)
Endif

oFile:lClose()

return
/*-------------------------------------------------------------------------------------
@function BSCLogInFile(oFileStream, cText, nType)
Executa a gravação de cText no arquivo em oFileStream segundo critério de nType.
@param oFileStream - Instancia de TBIFileIO
@param cText - Texto a ser trabalhado(logado).
@param nType - Constante identificando a operacao de log (default: BSC_LOG_SCR).
BSC_LOG_SCR - Somente apresenta na console.
BSC_LOG_FILE - Somente grava no arquivo de log.
BSC_LOG_RAISE - Grava no arquivo de log e levanta exceção no Protheus.
BSC_LOG_SCRFILE - Apresenta na console e grava no arquivo de log.
--------------------------------------------------------------------------------------*/
function BSCLogInFile(oFileStream, cText, nType)
	local nCount := 0
	default nType := BSC_LOG_SCR

	if(nType==BSC_LOG_SCRFILE .or. nType==BSC_LOG_FILE)
		nCount := 0	
		while((!oFileStream:lOpen(FO_WRITE+FO_EXCLUSIVE)) .and. nCount<60)
			sleep(500)
			nCount++
		enddo
		if(nCount == 60)  // se nao abrir em +-30 segundos da erro no conout e libera a thread
			conout(STR0012+oFileStream:cFileName())/*//"Aviso: Timeout expirado ao tentar gravar no arquivo: "*/
		else
			oFileStream:nGoEOF()
			oFileStream:nWriteLn(dtos(date())+"/"+time()+" = "+padr(cText,80)+padr(procname(1),15)+" ("+strZero(procline(1),4)+") ")
			oFileStream:lClose()
		endif
	endif	
	
	if(nType==BSC_LOG_SCR .or. nType==BSC_LOG_SCRFILE)
		conout(cText)
	endif

	if(nType==BSC_LOG_RAISE)
		ExUserException(cText)
	endif
return

/*-------------------------------------------------------------------------------------
@function BSCFileOpen(oTable, nTentativas)
Executa a abretura de uma tabela.
@param oTable - Nome da tabela
@param nTentativa - Numeros de tentativas de abertura (default: 5)
@return - .T./.F.
--------------------------------------------------------------------------------------*/
function BSCFileOpen(oTable, nTentativas)
Local lRet := .F., nTry := 0
Default nTentativas := 5

while(!oTable:lOpen(.t.) .and. nTry < nTentativas)
	sleep(1000)
	nTry++
enddo
if(nTry < nTentativas)
	lRet := .T.
else
	::Log(STR0042, BSC_LOG_SCRFILE) //"Dados não atualizados!"
	::Log(STR0043 + oTable:cTableName() + " !", BSC_LOG_SCRFILE) //"Não foi possivel o acesso exclusivo a tabela "
endif

return(lRet)

/*-------------------------------------------------------------------------------------
@method cGetParent(oChildTable)
Retorna o nome da Entidade Pai.
@param oChildTable - Tabela de entidade aberta e posicionada.
@return - Nome da Entidade Pai.
--------------------------------------------------------------------------------------*/
method cGetParent(oChildTable) class TBSCCore
return ::faTables[aScan(::faTables, { |x| x[5] == oChildTable })][4]

/*-------------------------------------------------------------------------------------
@method cListPessoas(nUserCod)
Retorna uma lista com cod de pessoas associadas a o usuario
@param nUserCod - Codigo do usuario
@return - Lista dos usuarios.
--------------------------------------------------------------------------------------*/
method cListPessoas(nUserCod) class TBSCCore
local oPessoa		:= ::oGetTable("PESSOA")
local aPessoas	:= {}

oPessoa:SetOrder(4)
oPessoa:lSeek(4,{nUserCod})

while(!oPessoa:lEof() .And. oPessoa:nValue("USERID") == nUserCod)
	// Nao lista o ID 0, de inclusao
	if(oPessoa:nValue("ID")==0)
		oPessoa:_Next()
		loop
	endif			
	aadd(aPessoas,oPessoa:nValue("ID"))
	oPessoa:_Next()
enddo                     

return "("+	cBIConcatMacro(",", aPessoas ) + ")"

/*-------------------------------------------------------------------------------------
@method cListPessoas(nUserCod)
Retorna uma lista com cod de pessoas associadas a o usuario
@param nUserCod - Codigo do usuario
@return - Lista dos usuarios.
--------------------------------------------------------------------------------------*/
method aListPessoas(nUserCod) class TBSCCore

local oPessoa		:= ::oGetTable("PESSOA")
local aPessoas		:= {}

oPessoa:SetOrder(4)
oPessoa:lSeek(4,{nUserCod})

while(!oPessoa:lEof() .And. oPessoa:nValue("USERID") == nUserCod)

	// Nao lista o ID 0, de inclusao
	if(oPessoa:nValue("ID")==0)
		oPessoa:_Next()
		loop
	endif			
	aadd(aPessoas,oPessoa:nValue("ID"))
	oPessoa:_Next()
enddo                     

return  aPessoas 

/*-------------------------------------------------------------------------------------
@method oOltpController()
Retorna o Controle de Transações
@return - Controle de Transações.
--------------------------------------------------------------------------------------*/
method oOltpController() class TBSCCore
return ::foOltpController

/*-------------------------------------------------------------------------------------
@method oContext(oChildTable)
Retorna os nomes da entidades, ids e nomes dos ancestrais posicionada.
@param oChildTable - Tabela de entidade aberta e posicionada.
@return - Tabela de entidade ancestral de oTable.
create siga0739 - 04/01/2005
--------------------------------------------------------------------------------------*/
method oContext(oChildTable, nParentInclusao) class TBSCCore
	local oAttrib, oNode, oXMLOutput, nInd, cParent
	local oTable, aRetorno := {}
	local nParentID := oChildTable:nValue("PARENTID")
	default nParentInclusao := 0
	if(oChildTable:nValue("ID")==0) //inclusao
		nParentID := nParentInclusao
	endif
	
	cParent := ::cGetParent(oChildTable)
	
	while(!empty(cParent) .and. cParent != "BSC" )
		// Encontro tabela anterior posicionada
		oTable := ::oGetTable(cParent)
		if(valtype(oTable)!="U")
			oTable:SavePos()
			oTable:cSqlFilter("")
			oTable:lSeek(1, {nParentID})
			nParentID := oTable:nValue("PARENTID")
			aAdd(aRetorno,{cParent,oTable:nValue("ID"),oTable:cValue("NOME")})
			oChildTable := oTable
			cParent := ::cGetParent(oChildTable)
			oTable:RestPos()
		else
			cParent := ""
		endif
	end
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("CONTEXTOS",,oAttrib)

	for nInd := 1 to len(aRetorno)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("CONTEXTO"))
		oNode:oAddChild(TBIXMLNode():New("ENTIDADE", aRetorno[nInd][1]))
		oNode:oAddChild(TBIXMLNode():New("ID", aRetorno[nInd][2]))
		oNode:oAddChild(TBIXMLNode():New("NOME", aRetorno[nInd][3]))
	next

return oXMLOutput

/*-------------------------------------------------------------------------------------
@method lRecPassword(cUserName, cEmail)
Envia um e-mail uma nova senha para o usuario.
@return - .T. se o email foi enviado com sucesso
create siga1776 - 19/04/2007
--------------------------------------------------------------------------------------*/
method lRecPassword(cUserName, cEmail) class TBSCCore 
	local oUserTable	:= ::oGetTable("USUARIO")	
	local oSendMail		:= ::oGetTable("SMTPCONF")
	local cServer		:= ""
	local cPorta		:= ""
	local cConta		:= ""
	local cAutUsuario	:= ""
	local cAutSenha		:= ""
	local cCopia 		:= ""	
	local cCorpo 		:= ""
	local cAssunto		:= ""
	local cAnexos		:= ""
	local cFrom			:= ""	
	local lValid 		:= .f.	
	local cNewSenha		:= ""
	local lFoundUser	:= .f.

	if oSendMail:lSeek(1,{1})
		cServer		:= alltrim(oSendMail:cValue("SERVIDOR"))
		cPorta		:= alltrim(oSendMail:cValue("PORTA"))
		cConta		:= alltrim(oSendMail:cValue("NOME"))
		cAutUsuario	:= alltrim(oSendMail:cValue("USUARIO"))
		cAutSenha	:= alltrim(oSendMail:cValue("SENHA"))
		cFrom		:= "BSC <" + alltrim(oSendMail:cValue("NOME")) + ">"
		cAssunto	:= STR0020//"Recuperação de senha"
		lFoundUser	:= oUserTable:lSeek(2,{cUserName})
		
		if(lFoundUser .and. alltrim(oUserTable:cValue("EMAIL"))==cEmail)
			cNewSenha	:= alltrim(str(randomize(0,999999)))
			cNewSenha	:= padl(cNewSenha,6,"a")
			cCorpo		:= STR0021 + oUserTable:cValue("NOME") + STR0022 + cNewSenha +"."//"A nova senha do usuário: "
			//Gravando a nova senha	
			if oUserTable:lUpdate({{"SENHA",cBIStr2Hex(pswencript(cNewSenha))} })
				lValid := .t.
			endif
		else
			cEmail := cFrom 
			if(lFoundUser)
//				cCorpo := "A requisição de redefinição da senha do usuário " + cUserName + ", não foi atendida porque o e-mail cadastrado não confere com o e-mail solicitado."
				cCorpo := STR0023 + cUserName + STR0024
			else
//				cCorpo := "A requisição de redefinição da senha do usuário " + cUserName + ", não foi atendida porque o usuário não foi encontrado."
				cCorpo := STR0023 + cUserName + STR0025
			endif
		endif
		
		oSendMail:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cEmail, cAssunto, cCorpo, cAnexos, cFrom, cCopia) 
		
		if(lValid)		
			cEmail := cFrom 
			//Enviando o e-mail para o administrador.
			oSendMail:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cEmail, cAssunto, cCorpo, cAnexos, cFrom, cCopia) 
		endif
	endif
	
return lValid   

/*-------------------------------------------------------------------------------------
@function BSCEncode(acValue, alApplet)
Executa escape em caracteres inválidos (para execução em html ou applet).
@param acValue - Texto a ser trabalhado 
@param alApplet - Indica se destino é saída HTML ou saída em applet
--------------------------------------------------------------------------------------*/
function BSCEncode(acValue, alApplet)
	local cRet := acValue
	local aDe, aPara
	if valType(acValue) == "C"
		default alApplet := .f.
		if !alApplet                      			      //º        , ª      ,á         ,ã         ,â        ,à         ,é         ,ê        ,í         ,ô        ,ó         ,õ         ,ú         ,ü       ,ù         ,ç
			aDe   := { "<"   , ">"   , "  "          , "\" , chr(167),chr(166),chr(225)  ,chr(227)  ,chr(226) ,chr(224)  ,chr(233)  ,chr(234) ,chr(237)  ,chr(244) ,chr(243)  ,chr(245)  ,chr(250)  ,chr(252),chr(249)  ,chr(231)   }
			aPara := { "&lt;", "&gt;", "&nbsp;&nbsp;", "\\", "&ordm;","&ordf;","&aacute;","&atilde;","&acirc;","&agrave;","&eacute;","&ecirc;","&iacute;","&ocirc;","&oacute;","&otilde;","&uacute;","&uuml;","&ugrave;","&ccedil;" }
		else
			aDe   := { "\" , '"' , "'", CRLF, CR, LF  }
			aPara := { "\\", '\"', "\'", "\n", "\n", "" }
		endif
		aEval(aDe, { |x, i|cRet := strTran(cRet, x, aPara[i]) })
	endif
	
return cRet

/*-------------------------------------------------------------------------------------
@function upd090527()
Executa a atualização da base e compatibilização do novo campo TIPO
--------------------------------------------------------------------------------------*/
static function upd090527(oDtSrc)
	
	Local lRet := .F.
	
	oDtSrc:_First()
	while(!oDtSrc:lEof())
		If oDtSrc:lValue("REFER")
			oDtSrc:xValue("TIPODS", DTSRC_REFER)
		Else
			oDtSrc:xValue("TIPODS", DTSRC_RESULT)
		EndIf
		oDtSrc:_Next()
	enddo
	lRet := .T.
	
return lRet

/*-------------------------------------------------------------------------------------
@function upd090610()
Executa a atualização da base necessária para a Atribuição de Pesos à Indicadores
--------------------------------------------------------------------------------------*/
static function upd090610(oIndicador)
	
	Local lRet := .F.
	
	oIndicador:_First()
	while(!oIndicador:lEof())
		oIndicador:xValue("PESO", 1)
		oIndicador:xValue("RPESO", 1)
		oIndicador:_Next()
	enddo
	lRet := .T.
	
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateJNPL
Montagem do arquivo JNLP. 

@author  Helio Leal
@version P11
@since   07/06/2016
/*/
//-------------------------------------------------------------------
Method CreateJNPL() class TBSCCore	                                        
	Local cFile		:= ::cBscPath() + 'bsc.jnlp'
	Local oFileJNPL := TBIFileIO():New(cFile)     
	Local cHost 	:= BSCFixPath(cBIGetWebHost())                  

	//---------------------------------------------------------------------
	// Cria o arquivo JNLP
	//---------------------------------------------------------------------
	If (!oFileJNPL:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.))
		//---------------------------------------------------------------------
		// Erro na criação do arquivo.
		//---------------------------------------------------------------------
		::Log(STR0013 + cFileName , KPI_LOG_SCRFILE)	
	Else
	    //---------------------------------------------------------------------
		// Escreve o corpo do arquivo.
		//---------------------------------------------------------------------
		oFileJNPL:nWriteLn('<?xml version="1.0" encoding="utf-8"?>')		
		oFileJNPL:nWriteLn('<jnlp spec="1.0+" codebase="' + cHost + '" href="bsc.jnlp">')

		oFileJNPL:nWriteLn('<information>')

		//---------------------------------------------------------------------
		// Define as informações gerais da aplicação.
		//---------------------------------------------------------------------
		oFileJNPL:nWriteLn('<title>BSC Deskto P12</title>')
		oFileJNPL:nWriteLn('<vendor>TOTVS SA</vendor>')
		oFileJNPL:nWriteLn('<homepage href="www.totvs.com.br"/>')
		oFileJNPL:nWriteLn('<description>BSC WebStart P12</description>') 

		//---------------------------------------------------------------------
		// Define o ícone e a tela inicial.
		//---------------------------------------------------------------------
		oFileJNPL:nWriteLn('<icon kind="shortcut" href="imagens/totvs.ico"/>') 
		oFileJNPL:nWriteLn('<icon href="imagens/splash_screen_totvs.png" kind="splash"/>') 

		//---------------------------------------------------------------------
		// Define como será criado o atalho em ambiente Windows.
		//---------------------------------------------------------------------
		oFileJNPL:nWriteLn('<shortcut online="true">')
		oFileJNPL:nWriteLn('<desktop/>')
		oFileJNPL:nWriteLn('<menu submenu="TOTVS"/>')
		oFileJNPL:nWriteLn('</shortcut>')

		oFileJNPL:nWriteLn('</information>')

		//---------------------------------------------------------------------
		// Define as políticas de segurança da aplicação.
		//---------------------------------------------------------------------
		oFileJNPL:nWriteLn('<security>')
		oFileJNPL:nWriteLn('<all-permissions />')
		oFileJNPL:nWriteLn('</security>')

		//---------------------------------------------------------------------
		// Defime o programa inicial a ser executado e os parâmetros necessários.
		//---------------------------------------------------------------------
		oFileJNPL:nWriteLn('<application-desc main-class="bsc.applet.BscApplication">')
		oFileJNPL:nWriteLn('<argument>' + cHost + '</argument>')
		oFileJNPL:nWriteLn('<argument>' + cBSCLanguage() + '</argument>')
		oFileJNPL:nWriteLn('<argument>' + Iif(BscIsDebug(),'T', 'F') + '</argument>')

		oFileJNPL:nWriteLn('</application-desc>')

		//---------------------------------------------------------------------
		// Define os recursos necessários para a aplicação.
		//---------------------------------------------------------------------
		oFileJNPL:nWriteLn('<resources>')
		oFileJNPL:nWriteLn('<j2se version="1.6+"/>')
		oFileJNPL:nWriteLn('<jar eager="true" href="bsc.jar" main="true"/>')
		oFileJNPL:nWriteLn('</resources>')
			
		oFileJNPL:nWriteLn('</jnlp>')
    EndIf

	//---------------------------------------------------------------------
	// Fecha o arquivo.
	//---------------------------------------------------------------------
	oFileJNPL:lClose()
Return cFile  

//-------------------------------------------------------------------
/*/{Protheus.doc} BSCFixPath
Assegura que os paths utilizados na montagem de endereço completo de arquivos terminem 
com BARRA INVERTIDA.


@param cPath (Caracter) - Path a ser tratado
@param cPath (Caracter) - Barra que será utilizada para na URL
@return (Caracter) Path tratado com BARRA INVERTIDA (Ex.: \System\)

@author  Helio Leal
@version P11
@since   07/06/2016
/*/
//-------------------------------------------------------------------
function BSCFixPath(cPath, cBar)
	Default cBar := "/"	
	
	cPath 	:= Iif( (right(cPath,1) $ "\/"), cPath, cPath + "\" )
   	cPath 	:= StrTran(cPath, "\", cBar)
	cPath 	:= StrTran(cPath, "/", cBar)   

return cPath
