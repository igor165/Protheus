// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC023E_DtSrc.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 23.06.05 | 0739 Aline Correa do Vale (Copia e dependencia do BSC021)
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC023E_DtSrc.ch"

/*--------------------------------------------------------------------------------------
@class TBSC023E
@entity DataSource
Painel de instrumentos cuztomizado do BSC.
@table BSC023E
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "FCSDATASRC"
#define TAG_GROUP  "FCSDATASRCS"
#define TEXT_ENTITY STR0001/*//"Fonte de Dados"*/
#define TEXT_GROUP  STR0002/*//"Fontes de Dados"*/

class TBSC023E from TBITable
	method New() constructor
	method NewBSC023E()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method oXMLClasses()
	
	// executar 
	method nDuplicate(nParentID, nNewParentID, nNewContextID)
	method nExecute(nID, cExecCMD, cArquivo)
endclass

method New() class TBSC023E
	::NewBSC023E()
return
method NewBSC023E() class TBSC023E
	local oField

	// Table
	::NewTable("BSC023E")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME",		"C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("CLASSE",		"N")) // BSC_SRC_TOP, BSC_SRC_ADVPL, BSC_SRC_FORMULA
	::addField(TBIField():New("REFER",		"L"))
	::addField(TBIField():New("RECRIA",		"L"))
	::addField(TBIField():New("TEXTO",		"M"))
	
	// Top
	::addField(TBIField():New("TIPOENV",	"N")) // 1 - BSC_SRC_ENVIRONMENT / 2 - BSC_SRC_CUSTOM
	// 1 - ENVIRONMENT
	::addField(TBIField():New("ENVIRON",	"C",	60))
	// 2 - SETUP
	::addField(TBIField():New("TOPDB",			"C",	60))
	::addField(TBIField():New("TOPALIAS",		"C",	60))
	::addField(TBIField():New("TOPSERVER",		"C",	60))
	::addField(TBIField():New("TOPCONTYPE",		"C",	60))

	// Indexes
	::addIndex(TBIIndex():New("BSC023EI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC023EI02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC023EI03",	{"PARENTID", "ID"},	.t.))
return

// Classes DTSRC
// BSC_SRC_TOP, BSC_SRC_ADVPL, BSC_SRC_FORMULA	
method oXMLClasses() class TBSC023E
	local oAttrib, oNode, oXMLOutput
	local nInd, aUnidades := { "Top Connect", "AdvPl" } // , STR0003 }/*//"Formula"*/

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("CLASSES",,oAttrib)

	for nInd := 1 to len(aUnidades)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("CLASSE"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aUnidades[nInd]))
	next
return oXMLOutput

// Arvore
method oArvore(nParentID) class TBSC023E
	local oXMLArvore, oNode
	
	::SetOrder(2) // Por ordem de nome
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
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TBSC023E
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
	// Tipo
	oAttrib:lSet("TAG001", "CLASSE")
	oAttrib:lSet("CAB001", STR0004)/*//"Classe"*/
	oAttrib:lSet("CLA001", BSC_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome
	if(!empty(nParentID))
		::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	else
		::cSQLFilter("PARENTID > 0 ")
	endif
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","CONTEXTID","DESCRICAO","TEXTO",;
					"TIPOENV", "TOPDB","TOPALIAS","TOPSERVER","TOPCONTYPE","ENVIRON","EMPRESA","FILIAL"})
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1]=="CLASSE")
				if(aFields[nInd][2]==0)
					aFields[nInd][2] := 1
				endif	
				aFields[nInd][2] := ::oXMLClasses():oChildByPos(aFields[nInd][2]):oChildByName("NOME"):cGetValue()
			endif	
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TBSC023E
	local aFields, nInd, nID
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next
	
	// Tipos de data-sources
	oXMLNode:oAddChild(::oXMLClasses())
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))

return oXMLNode

// Insere nova entidade   
method nInsFromXML(oXML, cPath) class TBSC023E
	local aFields, nInd, nID, nStatus := BSC_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd( aFields, {"ID", nID := ::nMakeID()} )
	
	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := BSC_ST_UNIQUE
		else
			nStatus := BSC_ST_INUSE
		endif
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC023E
	local nInd, nStatus := BSC_ST_OK,	nID
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {nID}))
		nStatus := BSC_ST_BADID
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

// Excluir entidade do server
method nDelFromXML(nID) class TBSC023E
	local nStatus := BSC_ST_OK
	
	// Deleta o elemento
	if(nStatus == BSC_ST_OK)
		if(::lSeek(1, {nID}))
			if(!::lDelete())
				nStatus := BSC_ST_INUSE
			endif
		else
			nStatus := BSC_ST_BADID
		endif	
    endif

	// Quando implementar security
	// nStatus := BSC_ST_NORIGHTS
return nStatus

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC023E
	local nStatus := BSC_ST_OK, aFields, nID
	
	::oOwner():oOltpController():lBeginTransaction()

	::SetOrder(1) // Por ordem de id
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	while(!::lEof() .and. nStatus == BSC_ST_OK)
		// Copia temporario
		aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID", "CONTEXTID"})
		aAdd( aFields, {"ID",  nID := ::nMakeID()} )
		aAdd( aFields, {"PARENTID", nNewParentID} )
		aAdd( aFields, {"CONTEXTID", nNewContextID} )

		// Grava
		::savePos()
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif
		::restPos()

		::_Next()
	enddo
	::cSQLFilter("") // Zera filtro

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

// Execute
method nExecute(nID, cExecCMD) class TBSC023E
	local nStatus := BSC_ST_OK

	// Executando JOB
	StartJob("BSCFcsDataSrcJob", GetEnvServer(), .f., {nID, ::oOwner():cBscPath(), cExecCMD, .t.})

return nStatus     

// Funcao executa o job
function BSCFcsDataSrcJob(aParms)
	local nTipoEnv, cTopDb, cTopAlias, cTopServer, cConType, cEnvironment, cTexto
	local cNome, nFrequencia, nDecimais, nClasse, lRecria
	local cExecCMD, cMsg, oLogger, nTopError, cArquivo, oThreadFile, oAttrib, aOrigem, nInd
	local oDataSrc, oIndicador, nDataSrcID, nIndicadorID
	public oBSCCore, cBSCPath, cBSCErrorMsg := ""

	// Parâmetros
	nDataSrcID := aParms[1]
	if(len(aParms) > 1 .and. valtype(aParms[2])=="C")
		cBSCPath := aParms[2]
	else
		cBSCPath := "\"
	endif
	if(len(aParms) > 2 .and. valtype(aParms[3])=="C")
		cExecCMD := aParms[3]
	else
		cExecCMD := "IMPORTCON"
	endif	

	oBSCCore := TBSCCore():New(cBSCPath)
	ErrorBlock( {|oE| __BSCError(oE)})

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	// Espera 2 segundos para iniciar
	// e dar tempo para o retorno ao BSC
	sleep(2000)

	// Iniciando fonte de dados, tabelas e log
	oBSCCore:LogInit()
	if(oBSCCore:nDBOpen() < 0)
		oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
		oBSCCore:Log(STR0005, BSC_LOG_SCRFILE)/*//"Não foi póssível conectar-se ao banco de dados do BSC."*/
		return
	endif	

	// Cria nome de arquivo desta thread
	cArquivo :=	"TH_DATASRC_"+cBIStr(nDataSrcID)

	// Seleciona fonte de dados informada
	oDataSrc := oBSCCore:oGetTable("FCSDATASRC")
	if(!oDataSrc:lSeek(1, {nDataSrcID}))
		oBSCCore:Log(STR0006, BSC_LOG_SCRFILE)/*//"Código da Fonte-de-Dados inexistente."*/
		return
	endif

	// 1 - Nome
	cNome := alltrim(oDataSrc:cValue("NOME"))
	oBSCCore:Log(STR0007+cNome+"]", BSC_LOG_SCRFILE)/*//"Iniciando fonte de dados ["*/
	// 2 - ParentID (ID da Indicador)
	nIndicadorID := oDataSrc:nValue("PARENTID")
	// 3 - Frequencia
	oIndicador := oBSCCore:oGetTable("FCSIND")
	oIndicador:lSeek(1, {nIndicadorID})
	nFrequencia := oIndicador:nValue("FREQ")
	// 4 - Decimais
	nDecimais := oIndicador:nValue("DECIMAIS")
	// 5 - Classe
	nClasse := oDataSrc:nValue("CLASSE")
	// 6 - Recria
	lRecria := oDataSrc:lValue("RECRIA")
	// 7 - Refer
	lRefer := oDataSrc:lValue("REFER")
	// 8 - Environment ou Setup
	nTipoEnv := oDataSrc:nValue("TIPOENV")
	// 9 - Environment
	cEnvironment := alltrim(oDataSrc:cValue("ENVIRON"))
	// 10 - TopDB
	cTopDB := alltrim(oDataSrc:cValue("TOPDB"))
	// 11 - TopAlias
	cTopAlias := alltrim(oDataSrc:cValue("TOPALIAS"))
	// 12 - TopServer
	cTopServer := alltrim(oDataSrc:cValue("TOPSERVER"))
	// 13 - TopConType
	cTopConType := alltrim(oDataSrc:cValue("TOPCONTYPE"))
	// 14 - Texto	
	cTexto := alltrim(oDataSrc:cValue("TEXTO"))

	// Exclui o arquivo de Thread Collector
	oBSCCore:Log(STR0008+cArquivo+"]", BSC_LOG_SCRFILE)/*//"Iniciando arquivo Thread Collector ["*/
	oThreadFile := TBIFileIO():New(oBSCCore:cBscPath()+"thread\"+cArquivo + ".xml")
	if oThreadFile:lExists()
		if(!oThreadFile:lErase())
			oBSCCore:Log(STR0009+cBIStr(nDataSrcID)+"/"+cNome+"]", BSC_LOG_SCRFILE)/*//"Fonte de dados já está em uso ["*/
			oBSCCore:Log(STR0010, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
			return
		endif               
	endif

	// Cria o arquivo de Thread Collector
	if ! oThreadFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0011+cArquivo+"]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo de Thread Collector ["*/
		oBSCCore:Log(STR0010, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif
              
	// Cria a estrutura do arquivo de Thread Collector
	oXMLThread 	:= TBIXMLNode():New("THREAD")

	oAttrib 	:= TBIXMLAttrib():New()
	oAttrib:lSet("DATA", Date())
	oAttrib:lSet("HORA", Time())
		
	oXMLThread:oAddChild(TBIXMLNode():New("BEGIN",,oAttrib))
	oXMLThread:oAddChild(TBIXMLNode():New("STATUS",BSC_ST_OK))
	oXMLThread:oAddChild(TBIXMLNode():New("PERCENT",-1))
		                                           
	// Grava estrutura XML no arquivo de Thread Collector
	oThreadFile:nWrite(oXMLThread:cXMLString(.t., "ISO-8859-1"))

	// Processa por tipo de data source
	if(nClasse == BSC_SRC_TOP)
		                                           
		if(cExecCMD == "IMPORTCON" .or. cExecCMD == "TESTCON" )

			// Fecha o environment do BSC
			BICloseDB()
			
			// Pega configuração do environment
			if( nTipoEnv == BSC_SRC_CUSTOM )
				oBSCCore:Log(STR0012, BSC_LOG_SCRFILE)/*//"Iniciando conexão TOP Connnect - Customizado"*/
				if( nTopError := nBIOpenDB(cTopDB, cTopAlias, cTopServer, cTopConType, {|cStr| oBSCCore:Log(cStr, BSC_LOG_SCRFILE)}) ) < 0
					oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
					return
				endif
			elseif( nTipoEnv == BSC_SRC_ENVIRONMENT )
				oBSCCore:Log(STR0013+cEnvironment+"]", BSC_LOG_SCRFILE)/*//"Iniciando conexão TOP Connnect - Ambiente ["*/
				if( nTopError := nBIOpenDBINI(nil, cEnvironment, {|cStr| oBSCCore:Log(cStr, BSC_LOG_SCRFILE)}) ) < 0
					oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
					return
				endif
			endif
		
		endif

		if(cExecCMD == "IMPORTCON" .or. cExecCMD == "TESTSINTAX" )

			// Pega dados do tclink
			oBSCCore:Log(STR0014, BSC_LOG_SCRFILE)/*//"Parseando declarações"*/
			cMsg := ""
			// 31/03/05 - Fernando Patelli
			// O parser não será mais utilizado nas operações de fonte de dados
			// A query já deve estar correta com a sintaxe de banco de dados utilizado
			//cTexto := cBIParseSQL(cTexto, @cMsg)
			//if(cMsg != "")
			// 	erro
			//	oBSCCore:Log(STR0015, BSC_LOG_SCRFILE)/*//" *Erro ao parsear query."*/
			//	oBSCCore:Log(" *"+cMsg, BSC_LOG_SCRFILE)
			//	return
			//endif
		endif
		
		if(cExecCMD == "IMPORTCON")

			// Origem
			oBSCCore:Log(STR0016, BSC_LOG_SCRFILE)/*//"Extraindo origem da importação"*/
			aOrigem := {}
			oQuery := TBIQuery():New("TMP")
			oQuery:lOpen(cTexto)
			oQuery:SetField("BSCDATA", "D", 8)
			oQuery:SetField("BSCVALOR", "N", 18, nDecimais)
			while(!oQuery:lEof())
				aAdd(aOrigem, {oQuery:dValue("BSCDATA"), oQuery:nValue("BSCVALOR")})
				oQuery:_Next()
			end
			BICloseDB()
			
			// Destino
			oBSCCore:Log(STR0017, BSC_LOG_SCRFILE)/*//"Gravando planilha"*/
			if(oBSCCore:nDBOpen() < 0)
				oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
				oBSCCore:Log("  ")
				return
			endif
			oPlanilha := oBSCCore:oGetTable(iif(lRefer, "FCSRPLAN", "FCSPLAN"))
			for nInd := 1 to len(aOrigem)
				dData := aOrigem[nInd][1]
				nValor := aOrigem[nInd][2]
				oPlanilha:lDateSeek(nIndicadorID, dData, nFrequencia)
				if(oPlanilha:lEof())
					exit // excedeu a ultima data
				endif
				oPlanilha:lUpdate({ {"PARCELA", nValor} })
			next
			oPlanilha:nRecalcula(nIndicadorID)
			oBSCCore:Log(STR0018, BSC_LOG_SCRFILE)/*//"Importação concluída"*/
			BICloseDB()
			
		endif
			
		// Cria estrutura de finalização de processos no arquivo de Thread Collector		
		oAttrib 	:= TBIXMLAttrib():New()
		oAttrib:lSet("DATA", Date())
		oAttrib:lSet("HORA", Time())
		
		oXMLThread:oAddChild(TBIXMLNode():New("END",,oAttrib))

		// Grava estrutura XML no arquivo de Thread Collector
		oThreadFile:nGoBOF()
		oThreadFile:nWrite(oXMLThread:cXMLString(.t., "ISO-8859-1"))
		                  
		// Fecha arquivo de Thread Collector
		oThreadFile:lClose()

	elseif(nClasse == BSC_SRC_ADVPL)

		if(cExecCMD == "IMPORTCON" .or. cExecCMD == "TESTCON" )
		endif
		
		if(cExecCMD == "IMPORTCON" .or. cExecCMD == "TESTSINTAX" )

			// Pega dados do tclink
			oBSCCore:Log(STR0014, BSC_LOG_SCRFILE)/*//"Parseando declarações"*/
			if(!findfunction( substr(cTexto,at(cTexto,"(")) ))
				// erro
				oBSCCore:Log("*" + STR0022, BSC_LOG_SCRFILE) // "ERRO Função não existente no RPO."
				return
			endif
			
		endif
		
		if(cExecCMD == "IMPORTCON")

			oBSCCore:Log(STR0016, BSC_LOG_SCRFILE)/*//"Extraindo origem da importação"*/
			StartJob("BSCFcsDtExec", cEnvironment, .t., {cBscPath, GetEnvServer(), cTexto, nIndicadorID, nFrequencia, lRefer})

		endif
			
		// Cria estrutura de finalização de processos no arquivo de Thread Collector		
		oAttrib 	:= TBIXMLAttrib():New()
		oAttrib:lSet("DATA", Date())
		oAttrib:lSet("HORA", Time())
		
		oXMLThread:oAddChild(TBIXMLNode():New("END",,oAttrib))

		// Grava estrutura XML no arquivo de Thread Collector
		oThreadFile:nGoBOF()
		oThreadFile:nWrite(oXMLThread:cXMLString(.t., "ISO-8859-1"))
		                  
		// Fecha arquivo de Thread Collector
		oThreadFile:lClose()
	
	elseif(nClasse == BSC_SRC_FORMULA)

		oBSCCore:Log(STR0020, BSC_LOG_SCRFILE)/*//"Classe [FORMULA] ainda não suportada."*/

	else

		oBSCCore:Log(STR0023, BSC_LOG_SCRFILE) // "Classe não suportada."

	endif

	oBSCCore:Log(STR0021+cNome+"]", BSC_LOG_SCRFILE)/*//"Finalizando fonte de dados ["*/
	
return


// Funcao executa a funcao ADVPL no ambiente desejado
function BSCFcsDtExec(aParms)
	local cBscEnv, cBSCPath, cTexto, nIndicadorID, nFrequencia, lRefer, aOrigem
	
	cBscPath := 	aParms[1]
	cBscEnv := 		aParms[2]
	cTexto  := 		aParms[3]
	nIndicadorID := aParms[4]
	nFrequencia := 	aParms[5]
	lRefer := 		aParms[6]

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	begin sequence
		aOrigem := &cTexto
	recover
		aOrigem := nil
	end sequence
	
	StartJob("BSCFcsDtWrite", cBscEnv, .t., {cBscPath, aOrigem, nIndicadorID, nFrequencia, lRefer})
			
return

// Funcao finaliza fonte de dados ADVPL gravando na planilha
// no ambiente do BSC
function BSCFcsDtWrite(aParms)
	local cBscPath, aOrigem, nIndicadorID, nFrequencia, lRefer, nInd
	public oBSCCore, cBSCErrorMsg := ""

	cBscPath := aParms[1]
	aOrigem := aParms[2]
	nIndicadorID := aParms[3]
	nFrequencia := aParms[4]
	lRefer := aParms[5]

	oBSCCore := TBSCCore():New(cBSCPath)
	ErrorBlock( {|oE| __BSCError(oE)})

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	begin sequence

		// Reiniciando tabelas bsc
		oBSCCore:LogInit()
		if(oBSCCore:nDBOpen() < 0)
			oBSCCore:Log(STR0005, BSC_LOG_SCRFILE)/*//"Não foi póssível conectar-se ao banco de dados do BSC."*/
			break
		endif	

		if(valtype(aOrigem)!="A")
			oBSCCore:Log(STR0024, BSC_LOG_SCRFILE) // "Retorno não é válido."
			break
		endif

		// Destino
		oBSCCore:Log(STR0017, BSC_LOG_SCRFILE)/*//"Gravando planilha"*/
		oPlanilha := oBSCCore:oGetTable(iif(lRefer, "FCSRPLAN", "FCSPLAN"))
		for nInd := 1 to len(aOrigem)
			dData := aOrigem[nInd][1]
			nValor := aOrigem[nInd][2]
			oPlanilha:lDateSeek(nIndicadorID, dData, nFrequencia)
			if(oPlanilha:lEof())
				exit // excedeu a ultima data
			endif
			oPlanilha:lUpdate({ {"PARCELA", nValor} })
		next
		oPlanilha:nRecalcula(nIndicadorID)
		oBSCCore:Log(STR0018, BSC_LOG_SCRFILE)/*//"Importação concluída"*/
		BICloseDB()
			
	recover
			
		oBSCCore:Log(STR0010, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
			
	end sequence	

return       

function _BSC023e_DtSrc()
return

