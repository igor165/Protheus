// ######################################################################################
// Projeto: BSC
// Modulo : Relatório de Tarefas
// Fonte  : BSC052_Tar.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 05.01.04 | 1645 Leandro Marcelino Santos
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC052_Tar.ch"

/*--------------------------------------------------------------------------------------
@class TBSC052
@entity RelTar
Relatório de Tarefas
@table BSC052
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELTAR"
#define TAG_GROUP  "RELTARS"
#define TEXT_ENTITY STR0001/*//"Relatório de Tarefa"*/
#define TEXT_GROUP  STR0002/*//"Relatórios de Tarefas"*/

class TBSC052 from TBITable
	method New() constructor
	method NewBSC052()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oXMLSitIniciativa()
	method BSCRelTarJob(aParms)

	// registro atual
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	
	// executar 
	method nExecute(nID, cExecCMD)
endclass

method New() class TBSC052
	::NewBSC052()
return
method NewBSC052() class TBSC052
	
	// Table
	::NewTable("BSC052")
	::cEntity(TAG_ENTITY)
	
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("NOME",		"C",	60))
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("IMPDESC",	"L")) // Imprime descrição
	::addField(TBIField():New("DEPESSOA",	"N"))
	::addField(TBIField():New("DEDATA",		"D"))
	::addField(TBIField():New("ATEDATA",	"D"))
	::addField(TBIField():New("IMPORTANCI","N")) //(1) A-Vital; (2) B-Importante; (3) C-Interessante
	::addField(TBIField():New("URGENCIA","N")) //(1) 0-Urgente; (2) 1-Curto Prazo; (3) 2-Médio Prazo; (4) 3-Longo Prazo (sem prazo)
	::addField(TBIField():New("SITTAREFA",	"N")) // Situações definidas em ::oXMLSituacao() do Tarefas BSC018_Tar
	::addField(TBIField():New("SITINI",	"N")) // Situações definidas em ::oXMLSituacao() do Tarefas BSC018_Tar
	
	// Indexes
	::addIndex(TBIIndex():New("BSC052I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC052I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC052I03",	{"PARENTID", "ID"},	.t.))

	::faCopyColumn := {{"IMPORTANCIA","IMPORTANCI"}} //Origem destino;
return

// Arvore
method oArvore(nParentID) class TBSC052
	local oXMLArvore, oNode
	
	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(!::lEof())
		// Tag conjunto
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		// Nodes
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC052
	local aFields, oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", BSC_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de Nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","IMPDESC","DEPESSOA","ATEPESSOA","DEDATA","ATEDATA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC052
	local aFields, nInd, nStatus := BSC_ST_OK
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::nMakeID()}, {"CONTEXTID", nParentID}, {"PARENTID", nParentID} }))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif

	if nStatus == BSC_ST_OK
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			if(aFields[nInd][1] == "ID")
				nID := aFields[nInd][2]
			endif	
		next
	endif
	::cSQLFilter("") // Filtra pelo pai
	oXMLNode:oAddChild(::oOwner():oGetTable("PESSOA"):oToXMLList())
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oXMLSituacao())
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oXMLImportancia())
	oXMLNode:oAddChild(::oOwner():oGetTable("TAREFA"):oXMLUrgencia())
	oXMLNode:oAddChild(::oOwner():oGetTable("INICIATIVA"):oXMLSitIniciativa())




return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC052
	local nStatus := BSC_ST_OK,	nParentID, nInd
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nParentID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::nMakeID()}, {"CONTEXTID", nParentID}, {"PARENTID", nParentID} }))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	endif

return nStatus

// Execute
method nExecute(nID, cExecCMD) class TBSC052
	local nStatus := BSC_ST_OK
	local aParms := {}
	local oEstrategia	
	
	if(::lSeek(1, {nID})) // Posiciona no ID informado

		// 1 - Nome
		aAdd(aParms, alltrim(::cValue("NOME")))

		// 2 - Descrição
		aAdd(aParms, ::cValue("DESCRICAO"))

		// 3 - Imprime Descrição?
		aAdd(aParms, ::lValue("IMPDESC"))

		// 4 - De Pessoa
		aAdd(aParms, ::nValue("DEPESSOA"))

		// 5 - De Data
		aAdd(aParms, ::dValue("DEDATA"))

		// 6 - Ate Data
		aAdd(aParms, ::dValue("ATEDATA"))

		// 7 - ID da Organização
		oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
		oEstrategia:lSeek(1, {::nValue("PARENTID")})
		aAdd(aParms, oEstrategia:nValue("PARENTID"))

		// 8 - ID da Estratégia
		aAdd(aParms, ::nValue("PARENTID"))

		// 9 - ID do Relatório
		aAdd(aParms, ::nValue("ID"))

		// 10 - BSCPATH da Working THREAD
		aAdd(aParms, ::oOwner():cBscPath())

		// 11 - Nome do relatorio
		aAdd(aParms, alltrim(cExecCMD))

		// 12 - Grau de importancia
		aAdd(aParms, ::nValue("IMPORTANCI"))
		
		// 13 - Classificação da urgencia da tarefa
		aAdd(aParms, ::nValue("URGENCIA"))
		
		// 14 - Situacao da tarefa
		aAdd(aParms, ::nValue("SITTAREFA"))
		
		// 15 - Situacao da iniciativa
		aAdd(aParms, ::nValue("SITINI"))


		// Executando JOB
		::BSCRelTarJob(aParms)
	
	else

		nStatus := 	BSC_ST_BADID

	endif

return nStatus

// Funcao executa o job
method BSCRelTarJob(aParms) class TBSC052
	local cUrl 			:= left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	local aDados 		:= {}
	local aTarefa		:= {}
	local aTarCob		:= {}  
	local lAdd			:= .t.    
	local lAddTar		:= .t.
	local lImpDesc		:= .t.
	local nSitIni		:= 0  
	local nI			:= 0
	local nII			:= 0
	local nIII			:= 0
	local nSitTarefa	:= 0
	local nImportancia 	:= 0
	local nUrgencia		:= 0
	local cSituacao		:= ""
	local cPessoaDe 	:= ""
	local cNome			:= ""
	local cDescricao	:= ""
	local cBscPath		:= ""
	local cFiltro		:= ""
	local cImporUrgen	:= ""

	// Coleta os parametros
	// 1 - Nome
	cNome			:= aParms[1]
	// 2 - Descrição
	cDescricao 		:= aParms[2]
	// 3 - Imprime Descrição?
	lImpDesc		:= aParms[3]
	// 4 - De Pessoa
	nDePessoa		:= aParms[4]
	// 5 - De Data
	dDeData			:= aParms[5]
	// 6 - Ate Data
	dAteData		:= aParms[6]
	// 7 - ID da Organização
	nOrgID			:= aParms[7]
	// 8 - ID da Estratégia
	nEstID			:= aParms[8]
	// 9 - ID do Relatório
	nID				:= aParms[9]
	// 10 - BSCPATH da Working THREAD
	cBscPath		:= aParms[10]
	// 11 - Nome do arquivo que sera salvo
	cReportName := aParms[11]
	// 12 - Grau de importancia
	nImportancia := aParms[12]
	// 13 - Classificação da urgencia da tarefa
	nUrgencia := aParms[13]
	// 14 - Situacao da tarefa
	nSitTarefa := aParms[14]
	// 15 - Situacao da iniciativa
	nSitIni := aParms[15]


	// Arquivo de log
	oBSCCore:LogInit()
	oBSCCore:Log(STR0003 + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)/*//"Iniciando geração do relatório [REL052_"*/

	oHtmFile := TBIFileIO():New(oBSCCore:cBscPath()+"relato\"+cReportName)

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0004 + cBIStr(nID) + ".html]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL052_"*/
		oBSCCore:Log(STR0005, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif

	oOrganizacao := ::oOwner():oGetTable("ORGANIZACAO")
	
	oEstrategia := ::oOwner():oGetTable("ESTRATEGIA")
	
	oPerspectiva := ::oOwner():oGetTable("PERSPECTIVA")
	
	oObjetivo := ::oOwner():oGetTable("OBJETIVO")
	oObjetivo:SetOrder(2) // Por ordem de nome
	
	oIniciativa := ::oOwner():oGetTable("INICIATIVA")
	oIniciativa:SetOrder(2) // Por ordem de nome
	
	oTarefa := ::oOwner():oGetTable("TAREFA")
	oTarefa:SetOrder(2) // Por ordem de nome
	
	oMeta := ::oOwner():oGetTable("META")
	oMeta:SetOrder(2) // Por ordem de nome
	
	oPessoa := ::oOwner():oGetTable("PESSOA")
	oPessoa:SetOrder(2)

	oPesCob := ::oOwner():oGetTable("TARCOB")
	oPesCob:SetOrder(1)
	
	oOrganizacao:lSeek(1,{nOrgID})
	
	oEstrategia:lSeek(1,{nEstID})

	// Array com estrutura de tarefas
	aTarefa	:= {}

	oPerspectiva:cSQLFilter("PARENTID = "+cBIStr(oEstrategia:nValue("ID"))) // Filtra pelo pai
	oPerspectiva:lFiltered(.t.)
	oPerspectiva:_First()

	cFiltro := ''
	if(!empty(nImportancia)) // Selecionou Importancia
		cFiltro += " and IMPORTANCI = "+cBIStr(nImportancia)
	endif
	if(!empty(nUrgencia)) // Selecionou Urgencia
		cFiltro += " and URGENCIA = "+cBIStr(nUrgencia)
	endif
	if(!empty(nSitTarefa))
		cFiltro += " and SITID = "+cBIStr(nSitTarefa) // Filtra pelo situação da tarefa
	endif

	while(!oPerspectiva:lEof())
	
		oObjetivo:cSQLFilter("PARENTID = "+cBIStr(oPerspectiva:nValue("ID"))) // Filtra pelo pai
		oObjetivo:lFiltered(.t.)
		oObjetivo:_First()
		while(!oObjetivo:lEof())
			                                             
			oIniciativa:cSQLFilter("PARENTID = "+oObjetivo:cValue("ID")) // Filtra pelo pai
			oIniciativa:lFiltered(.t.)
			oIniciativa:_First()
			cIniciativa := ""  
			while(!oIniciativa:lEof())
				oTarefa:cSQLFilter("PARENTID = "+oIniciativa:cValue("ID")) // Filtra pelo pai
				oTarefa:lFiltered(.t.)
				oTarefa:_First()
				
				aTarefa := {}
				while(!oTarefa:lEof())
					oTarefa:savePos()
					if(	(oTarefa:dValue("DATAINI") >= dDeData .and. oTarefa:dValue("DATAINI") <= dAteData) .or. ;
						(oTarefa:dValue("DATAFIN") >= dDeData .and. oTarefa:dValue("DATAFIN") <= dAteData) )

						oPesCob:cSQLFilter("PARENTID = "+oTarefa:cValue("ID")) // Filtra pelo pai
						oPesCob:lFiltered(.t.)
						oPesCob:_First()    
						
						aTarCob := {}
						while(!oPesCob:lEof())
							oPessoa:_seek(1,{oPesCob:nValue("PESSOAID")})
							oPessoa:SetOrder(2) 
							if(!oPessoa:lEof())
								aadd(aTarCob,oPessoa:cValue("NOME"))
							endif
							oPesCob:_Next()
						end
						oPesCob:cSQLFilter("")
						
						
						
						//Situação
						oSituacao := oTarefa:oXMLSituacao()
						oSituacao := oSituacao:oChildByName("SITUACAO", oTarefa:nValue("SITID"))
						if(valtype(oSituacao)!="U")
							oSituacao := oSituacao:oChildByName("NOME")
							cSituacao := oSituacao:cGetValue()
						else
							cSituacao := ""
						endif
						
													
						//Importancia e Urgencia
						cImporUrgen := if(oTarefa:nValue("IMPORTANCI")==1,"A",(if(oTarefa:nValue("IMPORTANCI")==2,"B","C")))
						cImporUrgen := if(empty(oTarefa:nValue("IMPORTANCI")),"",cImporUrgen)
						cImporUrgen += "/"
						cImporUrgen += if(empty(oTarefa:nValue("URGENCIA")),"",strzero(oTarefa:nValue("URGENCIA")-1,1))
						
				       
						if nImportancia == 0 .or. oTarefa:nValue("IMPORTANCI") == nImportancia
							lAddTar := .t. 
						else
							lAddTar := .f.
						endif
						
						if lAddTar .and. (nUrgencia == 0 .or. oTarefa:nValue("URGENCIA") == nUrgencia)
							lAddTar := .t.    
						else
							lAddTar := .f.
						endif
					
						
						if(lAddTar)						
							aadd(aTarefa, {	aTarCob,;               
											oTarefa:cValue("ID"),;
											oTarefa:cValue("NOME"),;
											cSituacao,;
											cImporUrgen,;
											oTarefa:cValue("COMPLETADO"),;
											oTarefa:cValue("DATAINI"),;
											oTarefa:cValue("DATAFIN") })
						endif
							
					endif
					oTarefa:restPos()
					oTarefa:_Next()
				end
				oTarefa:cSQLFilter("")
				cIniciativa := oIniciativa:cValue("ID")
	            
	            
	            
	            if empty(nDePessoa) .or. oIniciativa:nValue("RESPID") == nDePessoa
	            	lAdd := .t.
					cPessoaDe := ""
					if oIniciativa:cValue("TIPOPESSOA") == "G"
						cPessoaDe := "Grupo"
					else        
						cPessoaDe := if(oPessoa:lseek(1,{oIniciativa:cValue("RESPID")}),oPessoa:cValue("NOME"),"")
					endif
				else
					lAdd := .f.
				endif          
				
				if lAdd .and. ( nSitIni == 0 .or. oIniciativa:nValue("NSITUACAO") == nSitIni)
					lAdd := .t.
				else
					lAdd := .f.
				endif
				
				if(lAdd)
					aadd(aDados, {	aTarefa,;
									oPerspectiva:cValue("NOME"),;
								  	oObjetivo:cValue("NOME"),;
								  	oIniciativa:cValue("NOME"),; 
							  		oIniciativa:cValue("SITUACAO"),;
								 	oIniciativa:cValue("COMPLETADO"),; 
								 	oIniciativa:cValue("DATAINI"),;
								 	oIniciativa:cValue("DATAFIN"),;
								 	cPessoaDe })
				endif
	
					oIniciativa:_Next()
			end
			oIniciativa:cSQLFilter("")
			oObjetivo:_Next()
		end
		oObjetivo:cSQLFilter("")
		oPerspectiva:_Next()
	end 
	oPerspectiva:cSQLFilter("")

	
	// Montagem do cabeçalho do html
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('    <title>Balanced ScoreCard</title>')
	oHtmFile:nWriteLN('    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">')
    oHtmFile:nWriteLN('	   <META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
    oHtmFile:nWriteLN('    <META HTTP-EQUIV="Expires" CONTENT="-1"> ')
	oHtmFile:nWriteLN('           ')
	oHtmFile:nWriteLN('    <style>')
	oHtmFile:nWriteLN('        .cabecalho_1 {')
	oHtmFile:nWriteLN('	        color: #000000;')
	oHtmFile:nWriteLN('	        font-family: Verdana;')
	oHtmFile:nWriteLN('	        font-size: 12px;')
	oHtmFile:nWriteLN('	        background-color: #C6C6C6;')
	oHtmFile:nWriteLN('         border-collapse: collapse;')
	oHtmFile:nWriteLN('	        font-weight: bold;')
	oHtmFile:nWriteLN('	        margin:  3px;')
	oHtmFile:nWriteLN('	        padding: 3px;')
	oHtmFile:nWriteLN('        }')
	oHtmFile:nWriteLN('         ')
	oHtmFile:nWriteLN('        .cabecalho_2 {')
	oHtmFile:nWriteLN('	        color: #6B6B6B;')
	oHtmFile:nWriteLN('	        font-family: Verdana;')
	oHtmFile:nWriteLN('	        font-size: 11px;')
	oHtmFile:nWriteLN('	        background-color: #DDDDDD;')
	oHtmFile:nWriteLN('	        border-collapse: collapse;')
	oHtmFile:nWriteLN('	        font-weight: bold;')
	oHtmFile:nWriteLN('	        margin:  0px;')
	oHtmFile:nWriteLN('	        padding: 3px;')
	oHtmFile:nWriteLN('        }')
	oHtmFile:nWriteLN('         ')
	oHtmFile:nWriteLN('        .texto {')
	oHtmFile:nWriteLN('         font-family: Verdana;')
	oHtmFile:nWriteLN('         font-size: 12px;')
	oHtmFile:nWriteLN('	        font-weight: normal;')
	oHtmFile:nWriteLN('        }')
	oHtmFile:nWriteLN('         ')
	oHtmFile:nWriteLN('         .texto_menor {')
	oHtmFile:nWriteLN('         font-family: Verdana;')
	oHtmFile:nWriteLN('	        font-size: 10px;')
	oHtmFile:nWriteLN('	        font-weight: bold;')
	oHtmFile:nWriteLN('        }')
	oHtmFile:nWriteLN('    </style>')
	oHtmFile:nWriteLN('            ')
	oHtmFile:nWriteLN('    <script language="javascript">')
	oHtmFile:nWriteLN('        iHeight = screen.height - 30')        	
	oHtmFile:nWriteLN('        moveTo(0,0);')							
	oHtmFile:nWriteLN('        resizeTo(screen.width , iHeight);')   	
	oHtmFile:nWriteLN('        ')
	oHtmFile:nWriteLN('        function dinMenu( x )')
	oHtmFile:nWriteLN('        {')
	oHtmFile:nWriteLN('	        if ( x.style.display == "none" )')
	oHtmFile:nWriteLN('		        x.style.display = "";')
	oHtmFile:nWriteLN('	        else')
	oHtmFile:nWriteLN('		        x.style.display = "none";')
	oHtmFile:nWriteLN('        }')
	oHtmFile:nWriteLN('    </script>')
	oHtmFile:nWriteLN('</head>')	
	

	oHtmFile:nWriteLN('<body>')
	oHtmFile:nWriteLN('    <table width="100%" border="0" cellspacing="0" cellpadding="0">')
	oHtmFile:nWriteLN('        <tr>')
	oHtmFile:nWriteLN('            <td width="150"><img src="' + cUrl + 'images/logo_sigabsc.gif"></td>')
	oHtmFile:nWriteLN('            <td>')
	oHtmFile:nWriteLN('                <table width="100%" border="0" cellspacing="0" cellpadding="0">')
	oHtmFile:nWriteLN('                    <tr><td align="center"><font size="4" face="Verdana, Arial, Helvetica, sans-serif">'+STR0007+'</font></td></tr>') //Organização
	oHtmFile:nWriteLN('                    <tr><td align="center"><font size="5" face="Verdana, Arial, Helvetica, sans-serif">' + alltrim(oOrganizacao:cValue("NOME")) + '</font></td></tr>')
	oHtmFile:nWriteLN('                </table>')
	oHtmFile:nWriteLN('            </td>')
	oHtmFile:nWriteLN('            <td width="150" align="right" valign="top"><font class="texto">'+STR0011+ ' ' + dtoc(date()) + '</font></td>') //Emissão
	oHtmFile:nWriteLN('        </tr>')
	oHtmFile:nWriteLN('    </table>')  
	oHtmFile:nWriteLN('        ')
	oHtmFile:nWriteLN('    <table width="100%" border="0" cellspacing="0" cellpadding="0">')

	oHtmFile:nWriteLN('			<tr><td>&nbsp;</td></tr>')
   	oHtmFile:nWriteLN('			<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>' + STR0001 /*Relatório de Iniciativa e Tarefas*/ + '</strong></font></td></tr>')
	oHtmFile:nWriteLN('			<tr><td>&nbsp;</td></tr>')
		
	oHtmFile:nWriteLN('        <tr><td align="center"><font class="texto">'+STR0008+ ' ' + alltrim(oEstrategia:cValue("NOME")) + '</font></td></tr>') //Estratégia:
	oHtmFile:nWriteLN('        <tr><td align="center"><font class="texto">'+STR0009+ ' ' + alltrim(oEstrategia:cValue("DATAINI")) + STR0010 + alltrim(oEstrategia:cValue("DATAFIN")) + '</font></td></tr>') //TimeFrame: // a
	oHtmFile:nWriteLN('        <tr><td><div align="center"><font class="texto">'+STR0012 + dtoc(dDeData) + STR0010 + dtoc(dAteData) + '</font></div></td></tr>') //Tarefas no período de ' // a
	oHtmFile:nWriteLN('        <tr><td><font class="texto">&nbsp;</font></td></tr>')
	
	if(len(aDados)>0)
		if lImpDesc
			oHtmFile:nWriteLN('        <tr><td><font class="texto"><strong>'+STR0013+'&nbsp;</strong>' + aParms[2] + '</font></td></tr>') //Descrição:
		endif
		oHtmFile:nWriteLN('    </table>')


		for nI := 1 to len(aDados)
			oHtmFile:nWriteLN('    <table width="100%" border="0" cellspacing="0" cellpadding="0">')
			oHtmFile:nWriteLN('        <tr><td>&nbsp;</td></tr>')
			oHtmFile:nWriteLN('        <tr><td><font class="texto"><strong>'+STR0015+'&nbsp;</strong>' + aDados[nI][2] + '</font></td></tr>') //Perspectiva:
			oHtmFile:nWriteLN('        <tr><td><font class="texto"><strong>'+STR0016+'&nbsp;</strong>' + aDados[nI][3] + '</font></td></tr>') //Objetivo:
			oHtmFile:nWriteLN('    </table>') 
			oHtmFile:nWriteLN('    <table width="100%" border="1" cellspacing="0" cellpadding="0">') 
			oHtmFile:nWriteLN('        <tr>') 
			oHtmFile:nWriteLN('            <td>') 
			oHtmFile:nWriteLN('                <table width="100%" border="0" cellspacing="0" cellpadding="0">') 
			oHtmFile:nWriteLN('                    <tr class="cabecalho_1"><td>'+ STR0017 +':&nbsp;<font class="texto">'+ aDados[nI][4] +'</font></td></tr>') //Iniciativa
			oHtmFile:nWriteLN('                    <tr class="cabecalho_2">') 
			oHtmFile:nWriteLN('                        <td>') 
			oHtmFile:nWriteLN('                            <table width="100%" border="0" cellspacing="0" cellpadding="0">') 
			oHtmFile:nWriteLN('                                <tr><td colspan="3"><font class="texto"><strong>' + "Responsável:" + '&nbsp;</strong>' + aDados[nI][9] + '</font></td></tr>') //Responsável
			oHtmFile:nWriteLN('                                <tr>') 
			oHtmFile:nWriteLN('                                    <td><font class="texto"><strong>'+ STR0019 +':&nbsp;</strong>'+ aDados[nI][5] +'</font></td>') //Em Execução 
			oHtmFile:nWriteLN('                                    <td><font class="texto"><strong>'+ STR0020 +':&nbsp;</strong>'+ aDados[nI][6] +'</font></td>') //% Completado
			oHtmFile:nWriteLN('                                    <td><font class="texto"><strong>'+ STR0031 +'&nbsp;</strong>'+ aDados[nI][7] +'</font></td>') //Data Inicial
			oHtmFile:nWriteLN('                                    <td><font class="texto"><strong>'+ STR0032 +'&nbsp;</strong>'+ aDados[nI][8] +'</font></td>') //Data Final
			oHtmFile:nWriteLN('                                </tr>') 
			oHtmFile:nWriteLN('                            </table>') 
			oHtmFile:nWriteLN('                        </td>') 
			oHtmFile:nWriteLN('                    </tr>')
			
			if len(aDados[nI][1]) > 0  
			    
				/*Monta o cabeçalho da tabela.*/
				oHtmFile:nWriteLN('                    <tr>') 
				oHtmFile:nWriteLN('                        <td>') 
				oHtmFile:nWriteLN('                            <table width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#FFFFFF">') 
				oHtmFile:nWriteLN('                                    <tr bgcolor="#ACA6D2">') 
				oHtmFile:nWriteLN('                                        <td width="35%" align="center"><font class="texto_menor">'+ STR0018 +'</font></td>') //Tarefa
				oHtmFile:nWriteLN('                                        <td width="15%" align="center"><font class="texto_menor">'+ STR0019 +'</font></td>') //Situação
				oHtmFile:nWriteLN('                                        <td width="15%" align="center"><font class="texto_menor">'+ STR0020 +'</font></td>') //% Concluído
				oHtmFile:nWriteLN('                                        <td width="15%" align="center"><font class="texto_menor">'+ STR0021 +'<br>'+ STR0022 +'</font></td>') //Importância Urgência
				oHtmFile:nWriteLN('                                        <td width="20%" align="center"><font class="texto_menor">'+ STR0033 +'</font></td>') //Período
				oHtmFile:nWriteLN('                                    </tr>')
				 
				/*Monta o corpo da tabela.*/
				for nII := 1 to len(aDados[nI][1])
					oHtmFile:nWriteLN('                                    <tr bgcolor="#D3D1E9">') 
					
					/*Tarefa*/					
					if len(aDados[nI][1][nII][1]) > 0
					   /*Caso tenha pessoas em cobrança fazemos o link.*/
						oHtmFile:nWriteLN('                                        <td><a href="javascript:dinMenu(tab' +aDados[nI][1][nII][2] +');"><font class="texto">'+ aDados[nI][1][nII][3] +'</font></a></td>') 
					else
						oHtmFile:nWriteLN('                                        <td><font class="texto">'+ aDados[nI][1][nII][3] +'</font></td>') 
					endif
					/*Situação*/
					oHtmFile:nWriteLN('                                        <td><font class="texto">'+ aDados[nI][1][nII][4] +'</font></td>') 
					/*% Completado*/
					oHtmFile:nWriteLN('                                        <td align="center"><font class="texto">'+ aDados[nI][1][nII][6] +'</font></td>') 
					/*Importância*/
					oHtmFile:nWriteLN('                                        <td><font class="texto">'+ aDados[nI][1][nII][5] +'</font></td>') 
					/*Período*/
					oHtmFile:nWriteLN('                                        <td><font class="texto">'+ aDados[nI][1][nII][7] +'&nbsp;-&nbsp;'+ aDados[nI][1][nII][8] +'</font></td>') 
					oHtmFile:nWriteLN('                                    </tr>') 
					
					/*Pessoas em cobrança*/
					if len(aDados[nI][1][nII][1]) > 0
						oHtmFile:nWriteLN('                                    <tr id="tab'+ aDados[nI][1][nII][2] +'" bgcolor="#E2E1F2" style="display:none;">') 
						oHtmFile:nWriteLN('                                        <td colspan="5">') 
						oHtmFile:nWriteLN('                                            <table width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#C6C6C6">') 
						oHtmFile:nWriteLN('                                                <tr><td><font class="texto_menor"><i>'+ STR0014 +'</i></font></td></tr>') //Pessoas em cobrança:
						
						for nIII := 1 to len(aDados[nI][1][nII][1])	
							oHtmFile:nWriteLN('                                                <tr><td><font class="texto">'+ aDados[nI][1][nII][1][nIII] +'</font></td></tr>') 
						next nIII
						oHtmFile:nWriteLN('                                            </table>') 
						oHtmFile:nWriteLN('                                        </td>') 
						oHtmFile:nWriteLN('                                    </tr>') 
					endif
				next nII
				oHtmFile:nWriteLN('                            </table>')
				oHtmFile:nWriteLN('                        </td>')
				oHtmFile:nWriteLN('                    </tr>')
				oHtmFile:nWriteLN('               </table>')
				oHtmFile:nWriteLN('            </td>')
				oHtmFile:nWriteLN('        </tr>')
				oHtmFile:nWriteLN('   </table> ')
			endif
		next nI

		/*Apresenta a legenda para Importância e Urgência.*/
		oHtmFile:nWriteLN('<br><font class="texto_menor">'+ STR0021 + ':' +'</font>') /*Importância:*/ 
		oHtmFile:nWriteLN('<font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+ STR0034 +'</font><br>') /*A-Vital  B-Importante  C-Interessante*/
		oHtmFile:nWriteLN('<font class="texto_menor">'+ STR0022 + ':' +'</font>')/*Urgência:*/
		oHtmFile:nWriteLN('<font size="1" face="Verdana, Arial, Helvetica, sans-serif">'+ STR0035 +'</font>') /*0-Urgente  1-Curto Prazo  2-Médio Prazo  3-Longo Prazo*/

	else
		oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">'+STR0023+'</font></td></tr>') //Não foram encontradas informações dentro das especificações passadas
		oHtmFile:nWriteLN('<tr><td align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">'+STR0024+'</font></td></tr>') //ou não existem pessoas em cobrança nas tarefas verificadas.
		oHtmFile:nWriteLN('</table>')

	endif
	
	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')
	
	
	oHtmFile:lClose()

	::oOwner():Log(STR0006+cNome+"]", BSC_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
	::fcMsg := STR0006+cNome+"]"
return
           
function _BSC052_Tar()
return
