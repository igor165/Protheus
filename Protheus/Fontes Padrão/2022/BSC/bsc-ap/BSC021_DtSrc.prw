// ######################################################################################
// Projeto: BSC
// Modulo : Database
// Fonte  : BSC021_DtSrc.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "BSC021_DtSrc.ch"

/*--------------------------------------------------------------------------------------
@class TBSC021
@entity DataSource
Painel de instrumentos cuztomizado do BSC.
@table BSC021
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DATASRC"
#define TAG_GROUP  "DATASRCS"
#define TEXT_ENTITY STR0001/*//"Fonte de Dados"*/
#define TEXT_GROUP  STR0002/*//"Fontes de Dados"*/

class TBSC021 from TBITable
	method New() constructor
	method NewBSC021()

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

method New() class TBSC021
	::NewBSC021()
return
method NewBSC021() class TBSC021
	local oField

	// Table
	::NewTable("BSC021")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",		"N"))
	::addField(TBIField():New("PARENTID",	"N"))
	::addField(TBIField():New("CONTEXTID",	"N"))
	::addField(TBIField():New("FEEDBACK",	"N"))
	::addField(oField := TBIField():New("NOME","C",	60))
	oField:lSensitive(.f.)
	::addField(TBIField():New("DESCRICAO",	"C",	255))
	::addField(TBIField():New("CLASSE",		"N")) // BSC_SRC_TOP, BSC_SRC_ADVPL, BSC_SRC_FORMULA
	::addField(TBIField():New("REFER",		"L"))
	::addField(TBIField():New("TIPODS",		"C",	10)) // tipo de fonte de dados: Referência, Resultado ou de Metas
	::addField(TBIField():New("RECRIA",		"L"))
	::addField(TBIField():New("TEXTO",		"M"))
	
	// Top
	::addField(TBIField():New("TIPOENV",	"N")) // 1 - BSC_SRC_ENVIRONMENT / 2 - BSC_SRC_CUSTOM
	// 1 - ENVIRONMENT
	::addField(TBIField():New("ENVIRON",	"C",	60))
	// 2 - SETUP
	::addField(TBIField():New("TOPDB",		"C",	60))
	::addField(TBIField():New("TOPALIAS",	"C",	60))
	::addField(TBIField():New("TOPSERVER",	"C",	60))
	::addField(TBIField():New("TOPCONTYPE","C",	60))
	//Integracao com o DataWareHouse
	::addField(TBIField():New("IDCONS"		,"N"))//Id consulta do dw
	::addField(TBIField():New("URL"			,"C",255))	
	::addField(TBIField():New("DW"			,"C",020))
	::addField(TBIField():New("CONSULTA"	,"C",020))
	::addField(TBIField():New("CPO_DATA"	,"C",010))
	::addField(TBIField():New("INDICADOR"	,"C",010))

	// Indexes
	::addIndex(TBIIndex():New("BSC021I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("BSC021I02",	{"NOME", "CONTEXTID"},	.t.))
	::addIndex(TBIIndex():New("BSC021I03",	{"PARENTID", "ID"},	.t.))
return

// Classes DTSRC
// BSC_SRC_TOP, BSC_SRC_ADVPL, BSC_SRC_FORMULA	
method oXMLClasses() class TBSC021
	local oAttrib, oNode, oXMLOutput
	local nInd, aUnidades := { "Top Connect", "AdvPl","DataWareHouse" } // , STR0003 }/*//"Formula"*/

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
method oArvore(nParentID) class TBSC021
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
method oToXMLList(nParentID) class TBSC021
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
method oToXMLNode(nParentID) class TBSC021
	local aFields, nInd, nID
	local oXMLNode		:=	TBIXMLNode():New(TAG_ENTITY)
   
	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
	next
	
	// Tipos de data-sources
	oXMLNode:oAddChild(::oOwner():oContext(self, nParentID))
	oXMLNode:oAddChild(::oXMLClasses())	
	
return oXMLNode

// Insere nova entidade   
method nInsFromXML(oXML, cPath) class TBSC021
	local aFields, nInd, nID, nStatus := BSC_ST_OK
	local nContextID	:=	0
	local nQtdReg  		:=	0
	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1]=="CONTEXTID")		
			nContextID := aFields[nInd][2]
		endif
	next
	aAdd( aFields, {"ID", nID := ::nMakeID()} )

	::oOwner():oOltpController():lBeginTransaction()
	
	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := BSC_ST_UNIQUE
		else
			nStatus := BSC_ST_INUSE
		endif
	endif	

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()		
	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TBSC021
	local	nInd	:=	0
	local	nID		:=	0
	local 	nQtdReg	:=	0
	local	nContextID	:=	0
	local	nStatus := BSC_ST_OK

	private oXMLInput 	:=	oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif	
		if(aFields[nInd][1] == "CONTEXTID")
			nContextID	:= aFields[nInd][2]
		endif
	next

	::oOwner():oOltpController():lBeginTransaction()
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
	
	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()		
	
return nStatus

// Excluir entidade do server
method nDelFromXML(nID) class TBSC021
	local nStatus 		:= BSC_ST_OK

	::oOwner():oOltpController():lBeginTransaction()
		
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

	if(nStatus != BSC_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

	// Quando implementar security
	// nStatus := BSC_ST_NORIGHTS
return nStatus

// Duplica os registros filhos de nParentID, colocando-os como filhos de nNewParentID do contexto nNewContextID
method nDuplicate(nParentID, nNewParentID, nNewContextID) class TBSC021
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
method nExecute(nID, cExecCMD) class TBSC021
	local cUrlWsDw	:=  getJobProfString("URLWSDW", "http://localhost/SIGADW.apw")//Endereco do web service do dw
	local nStatus 	:= BSC_ST_OK 
	
	// Executando JOB
	StartJob("BSCDataSrcJob", GetEnvServer(), .T., {nID, ::oOwner():cBscPath(), cExecCMD, cUrlWsDw})

return nStatus

// Funcao executa o job
function BSCDataSrcJob(aParms)
	local nTipoEnv		:=	0
	local nFrequencia	:=	0
	local nDecimais		:=	0
	local nClasse		:=	0
	local nTopError		:=	0
	local nDataSrcID	:=	0
	local nIndicadorID	:=	0
	local nRegDw		:=	0
	local nPosX			:=	0
	local nPosY			:=	0
	local nPosI			:=	0
	local nItens		:=	0		
	local nInd			:=	0
	local cTopDb		:=	""
	local cTopAlias		:=	""
	local cTopServer	:=	""
	local cConType		:=	""
	local cEnvironment	:=	""
	local cTexto		:=	""
	local cNome			:=	""
	local cArquivo		:=	""
	local cExecCMD		:=	"" 
	local cMsg			:=	""	    
	local cDW_Url		:=  ""
	local cUrlWsDw		:=  ""     
	local cLogName		:=  ""
 	local aOrigem		:=	{}
	local aFields		:=	{}
	local aFieldsX		:=	{}   
	local aFieldsY		:=	{}   
	local aIndicador	:=	{}
 	local aNewData		:=	{}	
	local aValDatas		:=	{}
	local aValInd		:=	{}
	local oObjDW		:=	nil
	local oDataSrc		:=	nil
	local oIndicador	:=	nil	
	local nContextID	:=  0
	local nParentID		:= 	0
	local oLogger		:=	nil
	local oThreadFile	:=	nil
	local oAttrib		:=	nil      
	local oScheduler	:= 	nil
	local lRecria		:=	.f.	
	local nStatus		:=	BSC_ST_OK
	local cTipoDS		:= ""
	local aAux
	
	public oBSCCore		:=	nil
	public cBSCPath		:=	nil
	public cBSCErrorMsg :=	""

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
	
	if(len(aParms) > 3 .and. valtype(aParms[4])=="C")
		cUrlWsDw := aParms[4]
	else
		cUrlWsDw := ""
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
	oDataSrc := oBSCCore:oGetTable("DATASRC")
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
	oIndicador := oBSCCore:oGetTable("INDICADOR")
	oIndicador:lSeek(1, {nIndicadorID})

	nContextID  := oIndicador:nValue("CONTEXTID")
	nParentID  	:= oIndicador:nValue("PARENTID")
	nFrequencia := oIndicador:nValue("FREQ")
	// 4 - Decimais
	nDecimais := oIndicador:nValue("DECIMAIS")
	// 5 - Classe
	nClasse := oDataSrc:nValue("CLASSE")
	// 6 - Recria
	lRecria := oDataSrc:lValue("RECRIA")
	
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
	// "TIPODS"
	cTipoDS := oDataSrc:cValue("TIPODS")
	 
	
	oScheduler  := TBSCScheduler():New()     
	cLogName += "import/"
	cLogName += alltrim(str(nDataSrcID))
	cLogName += "/BSC_"
	cLogName += strtran(dToc(date()),"/","") + "_"
	cLogName += strtran(time(),":","")
	
	oScheduler:lSche_CriaLog(cBSCPath,cLogName)//Criando o arquivo de log.
	oScheduler:lSche_WriteLog("Iniciando a importação das fontes de dados.")


	// Exclui o arquivo de Thread Collector
	oBSCCore:Log(STR0008+cArquivo+"]", BSC_LOG_SCRFILE)/*//"Iniciando arquivo Thread Collector ["*/
	oThreadFile := TBIFileIO():New(oBSCCore:cBscPath()+"thread\"+cArquivo + ".xml")
	if oThreadFile:lExists()
		if(!oThreadFile:lErase())
			oBSCCore:Log(STR0009+cBIStr(nDataSrcID)+"/"+cNome+"]", BSC_LOG_SCRFILE)/*//"Fonte de dados já está em uso ["*/
			oBSCCore:Log(STR0010, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
			oScheduler:lSche_WriteLog(STR0009+cBIStr(nDataSrcID)+"/"+cNome+"]")
			oScheduler:lSche_WriteLog(STR0010)
			return
		endif               
	endif

	// Cria o arquivo de Thread Collector
	if ! oThreadFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oBSCCore:Log(STR0011+cArquivo+"]", BSC_LOG_SCRFILE)/*//"Erro na criação do arquivo de Thread Collector ["*/
		oBSCCore:Log(STR0010, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		oScheduler:lSche_WriteLog(STR0011+cArquivo+"]")		
		oScheduler:lSche_WriteLog(STR0010)		
		return
	endif
              
	// Cria a estrutura do arquivo de Thread Collector
	oXMLThread 	:= TBIXMLNode():New("THREAD")

	oAttrib 	:= TBIXMLAttrib():New()
	oAttrib:lSet("CPO_DATA", Date())
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
			
			// Pegar configuração do environment (ambiente).
			if( nTipoEnv == BSC_SRC_CUSTOM )
				oBSCCore:Log(STR0012, BSC_LOG_SCRFILE)/*//"Iniciando conexão TOP Connnect - Customizado"*/
				oScheduler:lSche_WriteLog(STR0012)
				if( nTopError := nBIOpenDB(cTopDB, cTopAlias, cTopServer, cTopConType, {|cStr| oBSCCore:Log(cStr, BSC_LOG_SCRFILE)}) ) < 0
					oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
					oScheduler:lSche_WriteLog(cBIMsgTopError(nTopError))
					return
				endif
			elseif( nTipoEnv == BSC_SRC_ENVIRONMENT )
				oBSCCore:Log(STR0013+cEnvironment+"]", BSC_LOG_SCRFILE)/*//"Iniciando conexão TOP Connnect - Ambiente ["*/
				oScheduler:lSche_WriteLog(STR0013+cEnvironment+"]")
				if( nTopError := nBIOpenDBINI(nil, cEnvironment, {|cStr| oBSCCore:Log(cStr, BSC_LOG_SCRFILE)}) ) < 0
					oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
					oScheduler:lSche_WriteLog(cBIMsgTopError(nTopError))
					return
				endif
			endif
		endif

		if(cExecCMD == "IMPORTCON" .or. cExecCMD == "TESTSINTAX" )

			// Pega dados do tclink.
			oBSCCore:Log(STR0014, BSC_LOG_SCRFILE)/*//"Parseando declarações"*/   
			oScheduler:lSche_WriteLog(STR0014)        
			
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
		
		if(cExecCMD == "IMPORTCON" .and. !(cTipoDS == DTSRC_METAS))

			// Origem
			oBSCCore:Log(STR0016, BSC_LOG_SCRFILE)/*//"Extraindo origem da importação"*/  
			oScheduler:lSche_WriteLog(STR0016)
			
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
			oScheduler:lSche_WriteLog(STR0017)
			if(oBSCCore:nDBOpen() < 0)
				oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
				oBSCCore:Log("  ")
				oScheduler:lSche_WriteLog(cBIMsgTopError(nTopError))
				return
			endif	
			oPlanilha := oBSCCore:oGetTable(iif(cTipoDS == DTSRC_REFER, "RPLANILHA", "PLANILHA"))
			for nInd := 1 to len(aOrigem)
				dData := aOrigem[nInd][1]
				nValor := aOrigem[nInd][2]
				oPlanilha:lDateSeek(nIndicadorID, dData, nFrequencia)
				if !oPlanilha:lEof()
					oPlanilha:lUpdate({ {"PARCELA", nValor} })
				endif
			next
			oPlanilha:nRecalcula(nIndicadorID)
			oBSCCore:Log(STR0018, BSC_LOG_SCRFILE)/*//"Importação concluída"*/
			oScheduler:lSche_WriteLog(STR0018)
			BICloseDB()
		
		ElseIf(cExecCMD == "IMPORTCON" .and. cTipoDS == DTSRC_METAS)
			
			// Origem
			oBSCCore:Log(STR0016, BSC_LOG_SCRFILE)/*//"Extraindo origem da importação de metas"*/ 
			oScheduler:lSche_WriteLog(STR0016)
			aOrigem := {}
			oQuery := TBIQuery():New("TMP")
			oQuery:lOpen(cTexto)
			oQuery:SetField("METADTALVO", "D", 8)
			oQuery:SetField("METAZUL", "N", 18, nDecimais)
			oQuery:SetField("METAVERDE", "N", 18, nDecimais)
			oQuery:SetField("METAMARELO", "N", 18, nDecimais)
			oQuery:SetField("METAVERMELHO", "N", 18, nDecimais)
			oQuery:SetField("METAPARC", "L", 1)
			
			while(!oQuery:lEof())
				aAdd(aOrigem, {oQuery:dValue("METADTALVO"), oQuery:nValue("METAZUL"), oQuery:nValue("METAVERDE"), oQuery:nValue("METAMARELO"), oQuery:nValue("METAVERMELHO"), oQuery:lValue("METAPARC"), oQuery:cValue("METANAME")})
				oQuery:_Next()
			end
			
			// Destino
			oBSCCore:Log(STR0017, BSC_LOG_SCRFILE)/*//"Gravando planilha"*/  
			oScheduler:lSche_WriteLog(STR0017)
			if(oBSCCore:nDBOpen() < 0)
				oBSCCore:Log(cBIMsgTopError(nTopError), BSC_LOG_SCRFILE)
				oBSCCore:Log("  ")
				return
			endif	
			
			// Inclui as metas importadas pela fonte.
			oBSCCore:Log(STR0027, BSC_LOG_SCRFILE)/*//"Gravando meta"*/  
			oScheduler:lSche_WriteLog(STR0027)
			for nInd := 1 to len(aOrigem)
				insertMeta(nIndicadorID, nContextID, nParentID, aOrigem[nInd, 1], aOrigem[nInd, 2], aOrigem[nInd, 3], aOrigem[nInd, 4], aOrigem[nInd, 5], aOrigem[nInd, 6], aOrigem[nInd, 7])
			next
			
			oBSCCore:Log(STR0018, BSC_LOG_SCRFILE)/*//"Importação concluída"*/
			BICloseDB()
			
		endif
			
		// Cria estrutura de finalização de processos no arquivo de Thread Collector.
		oAttrib 	:= TBIXMLAttrib():New()
		oAttrib:lSet("CPO_DATA", Date())
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

			// Pegar dados do tclink.
			oBSCCore:Log(STR0014, BSC_LOG_SCRFILE)/*//"Parseando declarações"*/      
			oScheduler:lSche_WriteLog(STR0014)
			if(!findfunction( substr(cTexto,at(cTexto,"(")) ))
				// erro
				oBSCCore:Log("*" + STR0025 + ": " + cBIStr(cTexto), BSC_LOG_SCRFILE) //"ERRO Função não existente no RPO"
				oScheduler:lSche_WriteLog("*" + STR0025 + ": " + cBIStr(cTexto))
				return
			endif
			
		endif
		
		if(cExecCMD == "IMPORTCON")

			oBSCCore:Log(STR0016, BSC_LOG_SCRFILE)/*//"Extraindo origem da importação"*/   
			oScheduler:lSche_WriteLog(STR0016)
			StartJob("BSCDtSrcExec", cEnvironment, .t., {cBscPath, GetEnvServer(), cTexto, nIndicadorID, nContextID, nParentID, nFrequencia, cTipoDS})

		endif
			
		// Cria estrutura de finalização de processos no arquivo de Thread Collector.		
		oAttrib 	:= TBIXMLAttrib():New()
		oAttrib:lSet("CPO_DATA", Date())
		oAttrib:lSet("HORA", Time())
		
		oXMLThread:oAddChild(TBIXMLNode():New("END",,oAttrib))

		// Grava estrutura XML no arquivo de Thread Collector.
		oThreadFile:nGoBOF()
		oThreadFile:nWrite(oXMLThread:cXMLString(.t., "ISO-8859-1"))
		                  
		// Fecha arquivo de Thread Collector.
		oThreadFile:lClose()
	elseif(nClasse == BSC_SRC_DW)
		oObjDW	:=	WSSIGADW():New()
		oObjDW:_URL := cUrlWsDw
        
        //Logando no DW
		oScheduler:lSche_WriteLog(STR0032) // "Logando no DW"
		cDW_Url := oDataSrc:cValue("URL")
		if !("http" $ cDW_Url)
			cDW_Url :=	"http://" + cDW_Url
		endif			
					
		oObjDW:LOGIN(alltrim(cDW_Url),alltrim(oDataSrc:cValue("DW")),"BSCADMIN","BSC")		
		cSessao	:=	oObjDW:CLOGINRESULT
		if valType(cSessao) != "U"
			oScheduler:lSche_WriteLog(STR0033) // "Login efetuado com sucesso"
			// Origem
			oBSCCore:Log(STR0016, BSC_LOG_SCRFILE)/*//"Extraindo origem da importação"*/  
			oScheduler:lSche_WriteLog(STR0016)
			lgetStruCon	:=	oObjDW:RETCONSULTA(cSessao,oDataSrc:nValue("IDCONS"),.t.)
			
			if(lgetStruCon)
				//Valores recebidos do DW
				aFieldsX	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSFIELDSX:OWSFIELDSDET
				aFieldsY	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSFIELDSY:OWSFIELDSDET
				aIndicador	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSMEASURES:OWSFIELDSDET
				
				oPlanilha	:=	oBSCCore:oGetTable(iif(cTipoDS == DTSRC_REFER, "RPLANILHA", "PLANILHA"))
				
				//Localizando onde estao os campos
				nPosY := ascan(aFieldsY		,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("CPO_DATA"))})
				nPosX := ascan(aFieldsX		,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("CPO_DATA"))})
				nPodI := ascan(aIndicador	,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("INDICADOR"))})
				
				//Pegando as datas.
				if(nPosY != 0)
					aValDatas	:=	aFieldsY[nPosY]:OWSVALUES:OWSFIELDSVALUE
				elseif(nPosX != 0)
					aValDatas	:=	aFieldsX[nPosX]:OWSVALUES:OWSFIELDSVALUE
				endif
				
				//Pegando os valores.				
				if(nPodI != 0)
					aValInd :=	aIndicador[nPodI]:OWSVALUES:OWSFIELDSVALUE
				endif
				
				//Grava os dados em uma tabela emporaria
				if(len(aValDatas) == len(aValInd) .and. len(aValInd) > 0)
					saveTmpDados(aValDatas,aValInd,oIndicador,oPlanilha)
					oPlanilha:nRecalcula(nIndicadorID)
				else
					oBSCCore:Log(STR0022, BSC_LOG_SCRFILE)/*//"A coluna de datas e valores tem tamanhos diferentes"*/
					oScheduler:lSche_WriteLog(STR0022)
				endif
			endif			
				
			// Destino
			oBSCCore:Log(STR0017, BSC_LOG_SCRFILE)/*//"Gravando planilha"*/
			oScheduler:lSche_WriteLog(STR0017)
		else
			oBSCCore:Log(STR0023, BSC_LOG_SCRFILE)/*//"Nao foi possivel fazer a conexão com o DW."*/
			oScheduler:lSche_WriteLog(STR0023)
		endif
		oBSCCore:Log(STR0018, BSC_LOG_SCRFILE)/*//"Importação concluída"*/
		oScheduler:lSche_WriteLog(STR0018)
	elseif(nClasse == BSC_SRC_FORMULA)
		oBSCCore:Log(STR0020, BSC_LOG_SCRFILE)/*//"Classe [FORMULA] ainda não suportada."*/
		oScheduler:lSche_WriteLog(STR0020)
	else
		oBSCCore:Log(STR0024, BSC_LOG_SCRFILE)//"Classe não suportada."
		oScheduler:lSche_WriteLog(STR0024)
	endif

	oBSCCore:Log(STR0021+cNome+"]", BSC_LOG_SCRFILE)/*//"Finalizando fonte de dados ["*/

	oScheduler:lSche_WriteLog(STR0021+cNome+"]")
	oScheduler:lSche_CloseLog()
	
return

// Funcao executa a funcao ADVPL no ambiente desejado
function BSCDtSrcExec(aParms)
	local cBscEnv, cBSCPath, cTexto, nIndicadorID, nFrequencia, aOrigem, cTipoDS
	
	cBscPath := 	aParms[1]
	cBscEnv := 		aParms[2]
	cTexto  := 		aParms[3]
	nIndicadorID := aParms[4]
	nContextID := aParms[5]
	nParentID := aParms[6]
	nFrequencia := 	aParms[7]
	cTipoDS := 		aParms[8]

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
	
	StartJob("BSCDtSrcWrite", cBscEnv, .t., {cBscPath, aOrigem, nIndicadorID, nContextID, nParentID, nFrequencia, cTipoDS})
			
return

// Funcao finaliza fonte de dados ADVPL gravando na planilha
// no ambiente do BSC
function BSCDtSrcWrite(aParms)
	local cBscPath, aOrigem, nIndicadorID, nContextID, nParentID, nFrequencia, cTipoDS, nInd
	public oBSCCore, cBSCErrorMsg := ""

	cBscPath := aParms[1]
	aOrigem := aParms[2]
	nIndicadorID := aParms[3]
	nContextID := aParms[4]
	nParentID := aParms[5]
	nFrequencia := aParms[6]
	cTipoDS := aParms[7]

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
			oBSCCore:Log(STR0026, BSC_LOG_SCRFILE) //"Retorno não é válido"
			break
		endif

		// Destino
		If !(cTipoDS == DTSRC_METAS)
			oBSCCore:Log(STR0017, BSC_LOG_SCRFILE)/*//"Gravando planilha"*/
			oPlanilha := oBSCCore:oGetTable(iif(cTipoDS == DTSRC_REFER, "RPLANILHA", "PLANILHA"))
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
		ElseIf cTipoDS == DTSRC_METAS
			oBSCCore:Log(STR0027, BSC_LOG_SCRFILE)/*//"Gravando meta"*/
			for nInd := 1 to len(aOrigem)
				insertMeta(nIndicadorID, nContextID, nParentID, aOrigem[nInd, 1], aOrigem[nInd, 2], aOrigem[nInd, 3], aOrigem[nInd, 4], aOrigem[nInd, 5], aOrigem[nInd, 6], aOrigem[nInd, 7])
			next
		EndIf
		oBSCCore:Log(STR0018, BSC_LOG_SCRFILE)/*//"Importação concluída"*/
		BICloseDB()
		
	recover
		
		oBSCCore:Log(STR0010, BSC_LOG_SCRFILE)/*//"Operação abortada"*/
		
	end sequence	

return

/*
*Cria a tabela temporaria.
*/
static function tmpCriaTable(cTableName,cIndexName)
	local oTableTemp	 := TBITable():New(cTableName+getDbExtension() ,cTableName)

	oTableTemp:lLocal(.t.)		

	//Fields
	oTableTemp:addField(TBIField():New("DIA"	, 	"C",	2))
	oTableTemp:addField(TBIField():New("MES"	, 	"C",	2))
	oTableTemp:addField(TBIField():New("ANO"	, 	"C",	4))
	oTableTemp:addField(TBIField():New("VALOR"	,	"N", 	19,	6))

	//Indexes
	oTableTemp:addIndex(TBIIndex():New(cIndexName+"01",{"ANO", "MES", "DIA"},	.f.))
	oTableTemp:ChkStruct(.t.)
	oTableTemp:lOpen(.f., .t.)
	
return oTableTemp

/*
*Grava os dados do xml na tabela temporaria
*/
static function saveTmpDados(aCmpData,aCmpValue,oTableInd,oPlanilha)
	local nRegDw	:=	0
	local nVlrAcum	:=	0
	local cData		:=	""
	local cAnoAnt	:=	""
	local cMesAnt	:=	""
	local cDiaAnt	:=	""
	local aNewData 	:=	{}
	local aFields	:=	{}		
	local oTmpTable	:=	tmpCriaTable("DW_IMP","DW_IMP")
    local nTotReg	:=	len(aCmpValue)
				
	for nRegDw	:= 1 to nTotReg
		aNewData	:=	oPlanilha:aDateConv(sTod(aCmpData[nRegDw]:CVALOR), oTableInd:nValue("FREQ")) 
		aAdd(aFields, {"DIA"	, aNewData[3]})
		aAdd(aFields, {"MES"	, aNewData[2]})
		aAdd(aFields, {"ANO"	, aNewData[1]})
		aAdd(aFields, {"VALOR"	, val(aCmpValue[nRegDw]:CVALOR)})
		
		// Grava
		if( ! oTmpTable:lAppend(aFields))
			if(oTmpTable:nLastError()==DBERROR_UNIQUE)
				nStatus := BSC_ST_UNIQUE
			else
				nStatus := BSC_ST_INUSE
			endif
		endif	
	next nRegDW

	oTmpTable:_First()
	while( ! oTmpTable:lEof())
		cAnoAnt		:=	oTmpTable:cValue("ANO")
		cMesAnt		:=	oTmpTable:cValue("MES")
		cDiaAnt		:=	oTmpTable:cValue("DIA")
		nVlrAcum	+= oTmpTable:nValue("VALOR")

		oTmpTable:_Next()
		
		cData		:=	oTmpTable:cValue("ANO")+oTmpTable:cValue("MES")+oTmpTable:cValue("DIA")
		
        //Verifico se devo adicionar a tabela
		if(cData # cAnoAnt+cMesAnt+cDiaAnt)
			oPlanilha:lSeek(2,{oTableInd:nValue("ID"),cAnoAnt,cMesAnt,cDiaAnt})
			if(!oPlanilha:lEof())
				oPlanilha:lUpdate({{"PARCELA", nVlrAcum} })
			endif
			nVlrAcum	:=	0
		endif
	end
	oTmpTable:Free()
	oTmpTable:DropTable()

return .t.

/*
*Grava os dados na tabela de metas
*/
static function insertMeta(nIndicadorID, nContextID, nParentID, dDtAlvo, nAlvoAzul, nAlvoVerde, nAlvoAmarelo, nAlvoVermelho, lParcel, cName)

	local oMeta	:= oBSCCore:oGetTable("META")
	local lRet
	local cDesc := cBIStr(dDtAlvo) + " - " + STR0028 + cBIStr(Date()) + " - " + cBIStr(Time()) //"Meta importada em "
	
	cName := iif(!empty(cName), cName, cBIStr(dDtAlvo) + " - " + iif(lParcel, STR0030, STR0031) + " " + STR0029) //"Parcelado" "Acumulado" "Importado"
	
	If lRet := (BSC_ST_OK == oMeta:nUpdMeta( { {"PARENTID", nIndicadorID}, {"CONTEXTID", nContextID}, {"AVALMEMO", cDesc}, ;
			{"NOME", cName}, {"DESCRICAO", cDesc}, {"PARCELADA", xBIConvTO("C", lParcel)}, {"DATAALVO", dDtAlvo}, ;
			{"AZUL1", nAlvoAzul}, {"VERDE", nAlvoVerde}, {"AMARELO", nAlvoAmarelo}, {"VERMELHO", nAlvoVermelho} ;
		}))
	Else
		oBSCCore:Log(oMeta:fcMsg)
	EndIf
	
return lRet
                  
function _BSC021_DtSrc()
return
