// ######################################################################################
// Projeto: BSC
// Modulo : Core
// Fonte  : BSC - 
// ---------+-----------------------+----------------------------------------------------
// Data     | Autor                 | Descricao
// ---------+-----------------------+----------------------------------------------------
// 22.06.09 | 3510 Gilmar P. Santos | FNC 00000008745/2009
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "BSCDefs.ch"
#include "bsc084_estimp.ch"

#define TAG_ENTITY "ESTIMPORT"
#define TAG_GROUP  "ESTIMPORTS"

class TBSCEstImport from TBITable
	data cJobName
	data calcLog
	data foProgressBar

	method New() constructor
	method NewEstImport()

	method oToXMLNode(cID,cRequest) 
	method nExecute(cID, cRequest)

	//Metodos de log
	method lCal_CriaLog(cPathSite,cLogName) 
	method lCal_WriteLog()
	method lCal_CloseLog() 
	method unlockImport(nHandle)
	
	//Metodos para importação
	method importXml(cDirName)
	method importXMLAux(cDirName, cTable, cGroup, aFieldExcept, aKeyConv, nStatus, lRetIds)
	method saveXML(oXmlInput, cTable, cGroup, aFieldExcept, aKeyConv, nStatus, lRetIds)

	//Metodos auxiliares
	method isXmlNode(oNode, cNode)
	method getXmlNode(oNode, cNode)

	//Controle do progress bar
	method setProgressBar(oProgressBar)
	method oProgressBar()
endclass
	
method New() class TBSCEstImport
	::NewEstImport()
return

method NewEstImport() class TBSCEstImport
	::cJobName		:=	alltrim(getJobProfString("INSTANCENAME", "BSC")+"_BscEstImp.lck")
	::NewObject() 
return

method setProgressBar( oProgressBar ) class TBSCEstImport
	::foProgressBar := oProgressBar
return

method oProgressBar() class TBSCEstImport
	if !( valtype( ::foProgressBar ) == "O" )
		::foProgressBar := ::oOwner():oGetTool( "PROGRESSBAR" )
		::foProgressBar:setup( "bscestimp_1" )
	endif

	return ::foProgressBar
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Carrega o nó requisitado

@protected
@param		cID ID da entidade.
@param		cRequest Sequencia de caracteres com as instrucoes de execuxao
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		No XML com os dados
/*/
//--------------------------------------------------------------------------------------
method oToXMLNode(cID,cRequest) class TBSCEstImport
	local oXMLNode 		:=	TBIXMLNode():New(TAG_ENTITY)    
	local oXMLArqs 		:=	TBIXMLNode():New("ARQUIVOS")    
	local cPathImport	:=	"metadados\*.org" 
	local oNodeLine     :=  nil
    local cFileLocal 	:=  ""
    local aFiles 		:=  {}
    local nStatus		:=	0 //0=Parado
    local nItemFile		:=  1
    local nHandle		:=	0 

    //Verifica o status atual
	nHandle	:=	fCreate(::cJobName,1) 
	if(nHandle == -1)
		nStatus	:=	1 //1-Executando
	else
		nStatus	:=	0 //0-Parado 
		::unlockImport(nHandle)		
	endif 

	oXMLNode:oAddChild(TBIXMLNode():New("STATUS", nStatus))

	//Capturando os arquivos metadados
	cFileLocal 	:=  oBscCore:cBscPath() + cPathImport
    aFiles 		:=  directory( cFileLocal, "D" )
	for nItemFile := 1 to len(aFiles)
		oNodeLine := oXMLArqs:oAddChild(TBIXMLNode():New("ARQUIVO"))
		oNodeLine:oAddChild( TBIXMLNode():New( "ID"  , lower( aFiles[nItemFile][1] ) ) )
		oNodeLine:oAddChild( TBIXMLNode():New( "NOME", lower( aFiles[nItemFile][1] ) ) )
		oNodeLine:oAddChild( TBIXMLNode():New( "SIZE", "" ) )
		oNodeLine:oAddChild( TBIXMLNode():New( "DATE", dToc( aFiles[nItemFile][3] ) + " " + aFiles[nItemFile][4] ) )
	next nItemFile
	oXMLNode:oAddChild(oXMLArqs)

return oXMLNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nExecute
Excuta o comando do client

@protected
@param		cID ID da entidade.
@param		cRequest Sequencia de caracteres com as instrucoes de execuxao
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		No XML com o status da execução
/*/
//--------------------------------------------------------------------------------------
method nExecute(cID, cRequest)  class TBSCEstImport
	local cPathSite		:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	local aRet			:=  {}
	local nHandle		:=	0	
	default cRequest 	:=  ""

	//Inicia ProgressBar para garantir que client não pegará lixo
	::oProgressBar()

	//Verifica se o job esta em execucao
	nHandle	:=	fCreate(::cJobName,1)
	if(nHandle != -1)
		::unlockImport(nHandle)
	
		aRet := aBIToken(cRequest,"|",.f.)	  	//Parametros
		aadd(aRet,cPathSite)					//Site do BSC
		aadd(aRet,::oOwner():cBscPath())		//Bsc Path

		//BscImp_Metadados(aRet)
		StartJob("BscImp_Metadados", GetEnvServer(), .T., aRet)
	else
		::oOwner():Log(STR0002, BSC_LOG_SCRFILE) //"Atenção. Existe uma importação de estrutura em andamento."

		::oProgressBar():setStatus(PROGRESS_BAR_ERROR)
   		::oProgressBar():setMessage(STR0002) //"Atenção. Existe uma importação de estrutura em andamento."
	endif

return BSC_ST_OK

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lCal_CriaLog
Cria o arquivo de log

@protected
@param		cPathSite caminho do site
@param		cLogName Log
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		.T.
/*/
//--------------------------------------------------------------------------------------
method lCal_CriaLog(cPathSite,cLogName) class TBSCEstImport
	cPathSite	:=	strtran(cPathSite,"\","/")
	::calcLog	:= 	TBIFileIO():New(::oOwner():cBscPath()+"logs\metadados\import\"+ cLogName + ".html")

	// Cria o arquivo htm
	If ! ::calcLog:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		::oOwner():Log(STR0003) //"Erro na criacao do arquivo de log."
	else
		::calcLog:nWriteLN('<html>')
		::calcLog:nWriteLN('<head>')
		::calcLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
  		::calcLog:nWriteLN('<title>'+STR0010+'</title>') //"BSC - Log de importação"
		::calcLog:nWriteLN('<link href= "'+ cPathSite + 'css/report.css" rel="stylesheet" type="text/css">')
		::calcLog:nWriteLN('</head>')
		::calcLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::calcLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td class="titulo"><div align="center">'+STR0010+ '</div></td>') //"BSC - Log de importação"
		::calcLog:nWriteLN('</tr>')
		::calcLog:nWriteLN('</table>')
		::calcLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td width="21%" class="cabecalho_1">'+STR0012+'</td>') //"Data"
		::calcLog:nWriteLN('<td width="79%" class="cabecalho_1">'+STR0013+'</td>') //"Eventos"
		::calcLog:nWriteLN('</tr>')
	endif

return .T.
      
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lCal_WriteLog
Grava um evento no log

@protected
@param		cMensagem Texto a ser gravado no log
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		.T.
/*/
//--------------------------------------------------------------------------------------
method lCal_WriteLog(cMensagem) class TBSCEstImport

	  ::calcLog:nWriteLN('<tr>')
	  ::calcLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	  ::calcLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	  ::calcLog:nWriteLN('</tr>')

	  ::oOwner():Log(cMensagem)	
return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lCal_CloseLog
Fecha o arquivo de log

@protected
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		.T.
/*/
//--------------------------------------------------------------------------------------
method lCal_CloseLog() class TBSCEstImport
	::calcLog:nWriteLN('</table>')
	::calcLog:nWriteLN('<br>')
	::calcLog:nWriteLN('</body>')
	::calcLog:nWriteLN('</html>')
	::calcLog:lClose()
	
return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} unlockExport
Para a exportação

@protected
@param		nHandle Handle do arquivo
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		Indica se houve sucesso ou não (Boolean)
/*/
//--------------------------------------------------------------------------------------
method unlockImport(nHandle) class TBSCEstImport
	local lUnLock := .t.

    if ! fClose(nHandle) 
		lUnLock := .f.
	endif

return lUnLock    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} isXmlNode
Verifica se existe o nó informado no XML

@protected
@param		oNode Objeto XML
@param		cNode Nome do nó que será procurado no objeto oNode
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		Indica se o nó procurado está presente ou não em oNode (Boolean)
/*/
//--------------------------------------------------------------------------------------
method isXmlNode(oNode, cNode) class TBSCEstImport
	local lRet := .F.

	cNode := upper( cNode )

	lRet := ( !valtype( XmlChildEx ( oNode, cNode ) ) == "U" )
return lRet   

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} isXmlNode
Retorno a estrutura do nó informado no XML

@protected
@param		oNode Objeto XML
@param		cNode Nome do nó que será procurado no objeto oNode
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		Objeto com o nó cNode
/*/
//--------------------------------------------------------------------------------------
method getXmlNode(oNode, cNode) class TBSCEstImport
	local oRet := nil

	cNode := upper( cNode )
	oRet := XmlChildEx ( oNode, cNode )
return oRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} importXml
Importa estrutura da organização no XML informado

@protected
@param		cDirName Nome do diretório da estrutura a ser importada
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		BSC_ST_OK se não ocorreram erros
/*/
//--------------------------------------------------------------------------------------
method importXml(cDirName) class TBSCEstImport
	local aIdOrganizacao 	:= {}
	local aIdEstrategia	 	:= {}
	local aIdPerspectiva	:= {}
	local aIdObjetivo 		:= {}
	local aIdIndicador		:= {}
	local aIdIniciativa		:= {}
	local aIdTarefa			:= {}
	local aIdFcs			:= {}
	local aIdFcsInd			:= {}
	local aIdMapaTema		:= {}
	local aIdDashBoard		:= {}
	local aIdTemaEst		:= {}

	local nStatus			:= BSC_ST_OK

	local nQtdTabelas		:= 23						//Quantidade de tabelas
	local nStep 			:= int(100 / nQtdTabelas)	//100 / qtd_tabelas
	local nPct				:= 100 - (nQtdTabelas * nStep)

	//::oOwner():oOltpController():lBeginTransaction()

	::oProgressBar():setPercent( nPct )
	conout(str(nPct) + "%")
	
	aIdOrganizacao	:= ::importXMLAux( cDirName,;
                                       "ORGANIZACAO" ,;
                                       "ORGANIZACOES" ,;
                                       @{"PARENTID", "CONTEXTID"},;
                                       @{.F., .F.},;
                                       @nStatus ,;
                                       .T.)

	nPct += nStep
	::oProgressBar():setPercent( nPct )
	conout(str(nPct) + "%")

	if ( nStatus == BSC_ST_OK )
		aIdEstrategia	:= ::importXMLAux( cDirName,;
	                                       "ESTRATEGIA",;
	                                       "ESTRATEGIAS",;
	                                       @{"PARENTID", "CONTEXTID"},;
	                                       @{aIdOrganizacao, "ID"},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )
		aIdPerspectiva	:= ::importXMLAux( cDirName,;
	                                       "PERSPECTIVA" ,;
	                                       "PERSPECTIVAS" ,;
	                                       @{"PARENTID", "CONTEXTID"},;
	                                       @{aIdEstrategia, aIdEstrategia},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif
	
	if ( nStatus == BSC_ST_OK )	                                       
		aIdObjetivo		:= ::importXMLAux( cDirName,;
	                                       "OBJETIVO",;
	                                       "OBJETIVOS",;
	                                       @{"PARENTID", "CONTEXTID", "RESPID", "TIPOPESSOA"},;
	                                       @{aIdPerspectiva, aIdEstrategia, .F., .F.},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif
	
	if ( nStatus == BSC_ST_OK )	                                       
		aIdIndicador	:= ::importXMLAux( cDirName,;
	                                       "INDICADOR",;
	                                       "INDICADORES",;
	                                       @{"PARENTID", "CONTEXTID", "RESPID", "TIPOPESSOA", "RRESPID", "RTIPOPES"},;
	                                       @{aIdObjetivo, aIdEstrategia, .F., .F., .F., .F.},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		::importXMLAux( cDirName,;
	                    "INDDOC",;
	                    "INDDOCS",;
	                    @{"PARENTID", "CONTEXTID"},;
	                    @{aIdIndicador, aIdEstrategia},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		aIdIniciativa	:= ::importXMLAux( cDirName,;
	                                       "INICIATIVA",;
	                                       "INICIATIVAS",;
	                                       @{"PARENTID", "CONTEXTID", "RESPID", "TIPOPESSOA"},;
	                                       @{aIdObjetivo, aIdEstrategia, .F., .F.},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		::importXMLAux( cDirName,;
	                    "INIDOC",;
	                    "INIDOCS",;
	                    @{"PARENTID", "CONTEXTID"},;
	                    @{aIdIniciativa, aIdEstrategia},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif
	
	if ( nStatus == BSC_ST_OK )	                                       
		aIdTarefa		:= ::importXMLAux( cDirName,;
	                                       "TAREFA",;
	                                       "TAREFAS",;
	                                       @{"PARENTID", "CONTEXTID"},;
	                                       @{aIdIniciativa, aIdEstrategia},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		::importXMLAux( cDirName,;
	                    "TARDOC",;
	                    "TARDOCS",;
	                    @{"PARENTID", "CONTEXTID"},;
	                    @{aIdTarefa, aIdEstrategia},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif
	
	if ( nStatus == BSC_ST_OK )	                                       
		aIdFcs			:= ::importXMLAux( cDirName,;
	                                       "FCS",;
	                                       "FCSS",;
	                                       @{"PARENTID", "CONTEXTID"},;
	                                       @{aIdObjetivo, aIdEstrategia},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif
		
	if ( nStatus == BSC_ST_OK )	                                       
		aIdFcsInd		:= ::importXMLAux( cDirName,;
	                                       "FCSIND",;
	                                       "FCSINDS",;
	                                       @{"PARENTID", "CONTEXTID", "RESPID", "TIPOPESSOA", "RRESPID", "RTIPOPES"},;
	                                       @{aIdFcs, aIdEstrategia, .F., .F., .F., .F.},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		::importXMLAux( cDirName,;
	                    "FCSDOC",;
	                    "FCSDOCS",;
	                    @{"PARENTID", "CONTEXTID"},;
	                    @{aIdFcsInd, aIdEstrategia},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		aIdMapaTema		:= ::importXMLAux( cDirName,;
	                                       "MAPATEMA",;
	                                       "MAPATEMAS",;
	                                       @{"PARENTID", "CONTEXTID"},;
	                                       @{aIdPerspectiva, aIdEstrategia},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif
	
	if ( nStatus == BSC_ST_OK )	                                       
		::importXMLAux( cDirName,;
	                    "TEMAOBJETIVO",;
	                    "TEMAOBJETIVOS",;
	                    @{"PARENTID", "CONTEXTID", "OBJETIVOID"},;
	                    @{aIdMapaTema, aIdEstrategia, aIdObjetivo},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		aIdDashBoard	:= ::importXMLAux( cDirName,;
	                                       "DASHBOARD",;
	                                       "DASHBOARDS",;
	                                       @{"PARENTID", "CONTEXTID"},;
	                                       @{aIdEstrategia, aIdEstrategia},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		::importXMLAux( cDirName,;
	                    "CARD",;
	                    "CARDS",;
	                    @{"PARENTID", "CONTEXTID", "ENTID"},;
	                    @{aIdDashBoard, aIdEstrategia, aIdIndicador},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		aIdTemaEst		:= ::importXMLAux( cDirName,;
	                                       "TEMAEST",;
	                                       "TEMAESTS",;
	                                       @{"PARENTID", "CONTEXTID"},;
	                                       @{aIdEstrategia, aIdEstrategia},;
	                                       @nStatus ,;
	                                       .T.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )	                                       
		::importXMLAux( cDirName,;
	                    "TEMESTOBJ",;
	                    "TEMESTOBJS",;
	                    @{"PARENTID", "CONTEXTID", "OBJETIVOID"},;
	                    @{aIdTemaEst, aIdEstrategia, aIdObjetivo},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )
		::importXMLAux( cDirName,;
	                    "MAPAEST" ,;
	                    "MAPAESTS1" ,;
	                    @{"PARENTID", "CONTEXTID", "SRCID", "DESTID"},;
	                    @{aIdEstrategia, aIdEstrategia, aIdObjetivo, aIdObjetivo},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif          

	if ( nStatus == BSC_ST_OK )
		::importXMLAux( cDirName,;
	                    "MAPAEST" ,;
	                    "MAPAESTS2" ,;
	                    @{"PARENTID", "CONTEXTID", "SRCID", "DESTID"},;
	                    @{aIdEstrategia, aIdEstrategia, aIdObjetivo, aIdMapaTema},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )
		::importXMLAux( cDirName,;
	                    "MAPAEST" ,;
	                    "MAPAESTS3" ,;
	                    @{"PARENTID", "CONTEXTID", "SRCID", "DESTID"},;
	                    @{aIdEstrategia, aIdEstrategia, aIdMapaTema, aIdObjetivo},;
	                    @nStatus ,;
	                    .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	if ( nStatus == BSC_ST_OK )
		::importXMLAux( cDirName,;
	                    "MAPAEST" ,;
                        "MAPAESTS4" ,;
                        @{"PARENTID", "CONTEXTID", "SRCID", "DESTID"},;
                        @{aIdEstrategia, aIdEstrategia, aIdMapaTema, aIdMapaTema},;
                        @nStatus ,;
                        .F.)

		nPct += nStep
		::oProgressBar():setPercent( nPct )
		conout(str(nPct) + "%")
	endif

	//if(nStatus != BSC_ST_OK)
	//	::oOwner():oOltpController():lRollback()
	//endif

	//::oOwner():oOltpController():lEndTransaction()

return nStatus

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} importXMLAux
Importa estrutura da tabela informada

@protected
@param		cDirName Nome do diretório da estrutura a ser importada
@param		cTable Nome do nó na estrutura XML
@param		cGroup Nome do grupo na estrutura XML
@param		aFieldExcept Campos que não serão importados
@param		aKeyConv Array para adequação de IDs
@param		nStatus Retorno do status do processamento (passado via referência)
@param		lRetIds Indica se deve ou não retornar IDs
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		array de ids gerados (com estrutura para de-para)
/*/
//--------------------------------------------------------------------------------------
method importXMLAux(cDirName, cTable, cGroup, aFieldExcept, aKeyConv, nStatus, lRetIds) class TBSCEstImport
	local aIds 			:= {}
	local aIdsRet		:= {}
	local xIds 			:= {}    
	local aFiles		:= {}
	local cGroupDirName	:= ""
 	local nCount		:= 0
 	local nLen			:= 0
 	local oXmlInput		:= nil
 	local cXml			:= ""
 	local cError		:= ""
 	local cWarning		:= ""
 	local cFileName		:= ""

	cGroupDirName := cDirName + "\" + cGroup + "\*.xml"

	aFiles := directory( cGroupDirName )
	nLen := len( aFiles )

	conout( cGroup )
	for nCount := 1 to nLen
		conout( "     " + aFiles[nCount][1] )

		cFileName := cDirName + "\" + cGroup + "\" + aFiles[nCount][1]
		//Lendo os dados do arquivo
		cXml := wfLoadFile( cFileName )

		//XML Parser
		oXmlInput := XmlParser( cXml, "_", @cError, @cWarning )

		If( empty( cError ) .AND. empty( cWarning ) )
			//Importa XML	
			aIds := ::saveXML( oXmlInput, cTable, cGroup, @aFieldExcept, @aKeyConv, @nStatus, lRetIds )

			if ( nStatus != BSC_ST_OK )
				EXIT
			endif

			if ( lRetIds )
				//Concatena ids de retorno
				aEval( aIds, {|xIds| aAdd( aIdsRet, xIds ) } )
			endif
		else 
			if(!empty(cError))
				::lCal_WriteLog( STR0007 + " - " + cError ) //"Erro no Parse"

		   		nStatus := BSC_ST_BADXML
			endif

			if(!empty(cWarning))
				::lCal_WriteLog( STR0008 + " - " + cWarning ) //"Aviso no Parse"

		   		nStatus := BSC_ST_BADXML
  			endif

			EXIT
        endif
	next	

return aIdsRet
	
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} saveXML
Importa estrutura da tabela informada

@protected
@param		oXmlInput Objeto XML que será importado
@param		cTable Nome do nó na estrutura XML
@param		cGroup Nome do grupo na estrutura XML
@param		aFieldExcept Campos que não serão importados
@param		aKeyConv Array para adequação de IDs
@param		nStatus retorno do status do processamento (passado via referência)
@param		lRetIds Indica se deve ou não retornar IDs
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		array de ids gerados (com estrutura para de-para)
/*/
//--------------------------------------------------------------------------------------
method saveXML(oXmlInput, cTable, cGroup, aFieldExcept, aKeyConv, nStatus, lRetIds) class TBSCEstImport
	local aKeyFields	:= {}
	local aKeys			:= {}
	local aKeysRet		:= {}
	local oTable		:= nil
	local aFields		:= {}
	local aFieldsAux	:= {}
	local aAux			:={}
	local oRegNode		:= nil
	local oNode			:= nil
	local oNodeField	:= nil
	local oNodeAux		:= 0
	local nNode			:= 0
	local nNewId		:= 0
	local i				:= 0
	local nQtdNode		:= 0
	local nReg			:= 0
	local xAux			:= nil
	local cType			:= ""
	local cField		:= ""
	local nLen			:= 0

	oRegNode := ::getXmlNode( oXMLInput:_METADADOS, "_" + cGroup )

	//Verifica existência de nó cNode no grupo cGroup no XML
	if ( ::isXMLNode( oRegNode, "_" + cTable ) )
		oTable := ::oOwner():oGetTable( cTable )

		//Monta array com campos que serão ignorados
		if valtype( aFieldExcept ) == "A"
			aKeys := aClone( aFieldExcept )
		endif
		aAdd( aKeys , "ID" )

		//recupera estrutura da tabela
		aFields := oTable:xRecord( RF_ARRAYFLD, aKeys )

		oNode := ::getXmlNode( oRegNode, "_" + cTable )

		if ( valtype( oNode ) == "A" ) 
			nQtdNode := len( oNode )
		elseif ( valtype( oNode ) == "O" )
			nQtdNode := 1
		endif

		for nNode := 1 to nQtdNode
			if ( valtype( oNode ) == "A" ) 
				oNodeAux := oNode[nNode]
			elseif ( valtype( oNode ) == "O" )
				oNodeAux := oNode
			endif

			//Inicializa lista de campos
			aFieldsAux := {}

			// Extrai valores do XML
			nLen := len( aFields )
			for i := 1 to nLen
				cField := AllTrim( aFields[i] )
				if ( ::isXmlNode( oNodeAux, "_" + cField ) )
					oNodeField := ::getXmlNode( oNodeAux, "_" + cField )
					cType := oTable:aFields( cField ):cType()
					aAdd( aFieldsAux , {cField, xBIConvTo( cType, oNodeField:TEXT )} )
				endif
			next

			//Adiciona campo chave
			nNewId := oTable:nMakeId()
			aAdd( aFieldsAux , { "ID" , nNewId } )

			//Adiciona demais campos
			nLen := len( aFieldExcept )
			for i := 1 to nLen
				//se for uma matriz, deve ser feita conversão de Ids
				if ( valtype( aKeyConv[i] ) == "A" )
					cField := AllTrim( aFieldExcept[i] )
					oNodeField := ::getXmlNode( oNodeAux, "_" + aFieldExcept[i] )

					aAux := aKeyConv[i]
					nReg := aScan( aAux , {|xAux| xAux[1] == xBIConvTo( "N", oNodeField:TEXT )} )

					if (nReg > 0)
						aAdd( aFieldsAux , {cField, aAux[nReg][2]} )
					else
						nStatus := BSC_ST_BADXML
						::lCal_WriteLog( STR0011 ) //"Inconsistência no XML"
					endif

				//se for uma string, deve ser feita cópia de valores de campo
				elseif ( valtype( aKeyConv[i] ) == "C" )
					nReg := aScan( aFieldsAux , {|xAux| xAux[1] == aKeyConv[i]} )

					if (nReg > 0)
						aAdd( aFieldsAux , {aFieldExcept[i], aFieldsAux[nReg][2]} )
					else
						nStatus := BSC_ST_BADXML
						::lCal_WriteLog( STR0011 ) //"Inconsistência no XML"
					endif
				endif
			next

			if ( nStatus == BSC_ST_OK )
				//Efetua gravação
				if( !oTable:lAppend( aFieldsAux ) )
					if ( oTable:nLastError() == DBERROR_UNIQUE )
						nStatus := BSC_ST_UNIQUE
						::lCal_WriteLog( STR0014 + ": " + oTable:cTablename() ) //"Chave duplicada"
					else                   
						nStatus := BSC_ST_INUSE
						::lCal_WriteLog( STR0015 + ": " + oTable:cTablename() ) //"Registro em uso"
					endif
				else                                             
					if ( lRetIds )
						//Armazena nova chave de conversão no retorno
						oNodeField := ::getXmlNode( oNodeAux, "_ID" )
						aAdd( aKeysRet , {xBIConvTo( "N", oNodeField:TEXT ) , nNewId} )
					endif
				endif
			endif
				
			if (nStatus != BSC_ST_OK)
				EXIT
			endif
        next
	endif

return aKeysRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} bscImp_Metadados
Importa metadados do BSC

@protected
@param		aParms
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		.T. se não ocorrer erro
/*/
//--------------------------------------------------------------------------------------
function bscImp_Metadados(aParms)
	local oImport		:= nil
	local nStatus 		:= BSC_ST_OK
	//local cError   		:= ""
	//local cWarning 		:= ""
	local cLogName		:= "" 
	//local cXml 	   		:= "" 
	//local oXmlInput		:= nil
	local nHandle		:= 0
	local cFileName		:= ""
	//local nSize			:= 0

	local oProgressBar	:= nil
	local oBscCore		:= nil

	//Configuracoes do ambiente
	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on
	
	//Instanciando BSCCore
	oBSCCore := TBSCCore():New( aParms[3] )
	ErrorBlock( {|oE| __BSCError(oE)} )  

    oProgressBar := oBSCCore:oGetTool( "PROGRESSBAR" )
    oProgressBar:setup("bscestimp_1")

	oProgressBar:setStatus(PROGRESS_BAR_OK)
   	oProgressBar:setMessage(STR0001) //"Iniciando Importação..."
		
	//Abre conexão
	if ( oBSCCore:nDBOpen() < 0 )
		oBSCCore:Log( STR0004, BSC_LOG_SCRFILE ) //"Erro na abertura do banco de dados"

		oProgressBar:setStatus(PROGRESS_BAR_ERROR)
   		oProgressBar:setMessage(STR0004) //"Erro na abertura do banco de dados"

		// Espera 1 segundo para finalizar
		// e dar tempo para o retorno ao BSS
		sleep( 1000 )

		return .F.
	endif
	
	//Instancia oImport
	oImport	:= oBSCCore:oGetTable( TAG_ENTITY )
	oImport:setProgressBar( oProgressBar )

   	//Verifica se o job esta em execucao
	nHandle	:=	fCreate( oImport:cJobName, 1 )
	if ( nHandle == -1 )
		oBSCCore:Log( STR0002, BSC_LOG_SCRFILE ) //"Atenção. Existe uma importação de estrutura em andamento."

		oProgressBar:setStatus(PROGRESS_BAR_ERROR)
   		oProgressBar:setMessage(STR0002) //"Atenção. Existe uma importação de estrutura em andamento."

		// Espera 1 segundo para finalizar
		// e dar tempo para o retorno ao BSS
		sleep( 1000 )

		return .F.
	endif             	
	
	//Criando do arquivo de log
	cLogName := alltrim( getJobProfString( "INSTANCENAME", "BSC" ) ) + "_"
	cLogName += strtran( dToc( date() ), "/", "" ) + "_"
	cLogName += strtran( time(), ":", "" )

	oImport:lCal_CriaLog( aParms[2], cLogName )   //Criando o arquivo de log.
	oImport:lCal_WriteLog( STR0001 )              //"Iniciando importação ..."
	oImport:lCal_WriteLog( STR0005 + aParms[1] )  //"Arquivo: "

	oProgressBar:setMessage(STR0006) //"Importando dados..."

	//Nome do arquivo que será importado
	cFileName := oBscCore:cBscPath() + "\metadados\" + aParms[1]

	nStatus := oImport:importXml( cFileName )
		
	do case
		case nStatus == BSC_ST_OK
	   		oProgressBar:setMessage(STR0009) //"Importação finalizada"
			oProgressBar:endProgress()
		
		case nStatus == BSC_ST_BADXML
			oProgressBar:setStatus(PROGRESS_BAR_ERROR) 
	   		oProgressBar:setMessage(STR0011) //"Inconsistência no XML"

		case nStatus == BSC_ST_UNIQUE
			oProgressBar:setStatus(PROGRESS_BAR_ERROR) 
	   		oProgressBar:setMessage(STR0014) //"Chave duplicada"
		
		case nStatus == BSC_ST_INUSE
			oProgressBar:setStatus(PROGRESS_BAR_ERROR) 
	   		oProgressBar:setMessage(STR0015) //"Registro em uso"
		
		otherwise
	   		oProgressBar:setMessage(STR0009) //"Importação finalizada"
			oProgressBar:setStatus(PROGRESS_BAR_ERROR) 

	endcase

	oImport:lCal_WriteLog(STR0009) //"Importação finalizada"
	oImport:lCal_CloseLog() 

	//Libera o job em execução	
	oImport:unlockImport(nHandle)

	// Espera 2 segundos para finalizar
	// e dar tempo para o retorno ao BSC		
	sleep(2000)	 

return .T.

function _BSC084_Estimp()
return