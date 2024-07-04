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
#include "bsc083_estexp.ch"

#define TAG_ENTITY "ESTEXPORT"
#define TAG_GROUP  "ESTEXPORTS"

class TBSCEstExport from TBITable
	data cJobName
	data calcLog
	data foProgressBar

	method New() constructor
	method NewEstExport()

	method oToXMLNode(cID, cRequest) 
	method nExecute(cID, cRequest)

	//Metodos de log
	method lCal_CriaLog(cPathSite, cLogName) 
	method lCal_WriteLog()
	method lCal_CloseLog()
	method unlockExport(nHandle)

	//Metodos para exportação
	method exportXml(aPk, cDirName, cNode)
	method exportXmlAux( cDirName, nIdxKey, aSearchKey, cFieldSearchKey, cPkName, cTable, cGroup, nPct, nPctStp, nMax, cExtraFilter )
	method saveXml(cDirName, nIdxKey, aSearchKey, cFieldSearchKey, cPkName, cTable, cGroup, nMax, cExtraFilter, nStatus)
	
	//Métodos auxiliares
	method changeSpecialChar(cText)
	
	//Controle do progress bar
	method setProgressBar(oProgressBar)
	method oProgressBar()
endclass
	
method New() class TBSCEstExport
	::NewEstExport()
return

method NewEstExport() class TBSCEstExport
	::cJobName		:=	alltrim(getJobProfString("INSTANCENAME", "BSC")+"_BscEstExp.lck")
	::NewObject() 
return

method setProgressBar( oProgressBar ) class TBSCEstExport
	::foProgressBar := oProgressBar
return

method oProgressBar() class TBSCEstExport
	if !( valtype( ::foProgressBar ) == "O" )
		::foProgressBar := ::oOwner():oGetTool( "PROGRESSBAR" )
		::foProgressBar:setup( "bscestexp_1" )
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
method oToXMLNode(cID,cRequest) class TBSCEstExport
	local oXMLNode 		:=	TBIXMLNode():New(TAG_ENTITY)    
	local oXMLArqs 		:=	TBIXMLNode():New("ARQUIVOS")    
	local cPathExport	:=	"metadados\*.xml" 
	local oNodeLine     :=  nil
    local cFileLocal 	:=  ""
    local aFiles 		:=  {}
    local nStatus		:=	0 //0=Parado
    local nItemFile		:=  1
    local nHandle		:=	0 

    //Verifica o status atual
	nHandle	:=	fCreate(::cJobName,1) 
	if (nHandle == -1)
		nStatus	:=	1 //1-Executando
	else
		nStatus	:=	0 //0-Parado 
		::unlockExport(nHandle)		
	endif                                         

	oXMLNode:oAddChild(TBIXMLNode():New("STATUS", nStatus))	

	//Capturando os arquivos com os metadados
	cFileLocal 	:=  ::oOwner():cBscPath() + cPathExport
    aFiles 		:=  directory(cFileLocal) 
	for nItemFile := 1 to len(aFiles)
		oNodeLine := oXMLArqs:oAddChild(TBIXMLNode():New("ARQUIVO"))
		oNodeLine:oAddChild(TBIXMLNode():New("ID",		lower(aFiles[nItemFile][1])))
		oNodeLine:oAddChild(TBIXMLNode():New("NOME",	lower(aFiles[nItemFile][1])))
		oNodeLine:oAddChild(TBIXMLNode():New("SIZE",	str(aFiles[nItemFile][2]/1024,10,2)+ " Kb"))
		oNodeLine:oAddChild(TBIXMLNode():New("DATE",	dToc(aFiles[nItemFile][3]) + " " + aFiles[nItemFile][4]))
	next nItemFile
	oXMLNode:oAddChild(oXMLArqs) 
	
	oXMLNode:oAddChild(::oOwner():oGetTable("ORGANIZACAO"):oToXMLList())
	
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
method nExecute(cID, cRequest)  class TBSCEstExport
	local cPathSite		:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	local aRet			:= {}
	local nHandle		:= 0	
	default cRequest 	:= ""	

	//Inicia ProgressBar para garantir que client não pegará lixo
	::oProgressBar()
	
 	//Verifica se o job esta em execucao
	nHandle	:=	fCreate(::cJobName,1)
	if(nHandle != -1)
		::unlockExport(nHandle)
			
		aRet := aBIToken(cRequest,"|",.f.)	//Parametros   
		aadd(aRet,cPathSite)				//Site do BSC
		aadd(aRet,::oOwner():cBscPath())	//Bsc Path
		
		//bscExp_Metadados(aRet)	
		StartJob("bscExp_Metadados", GetEnvServer(), .T., aRet)
	else
		::oOwnser():Log(STR0002, BSC_LOG_SCRFILE) //"Atenção. Existe uma exportação de estrutura em andamento."

		::oProgressBar():setStatus(PROGRESS_BAR_ERROR)
   		::oProgressBar():setMessage(STR0002) //"Atenção. Existe uma exportação de estrutura em andamento."
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
method lCal_CriaLog(cPathSite,cLogName) class TBSCEstExport
	cPathSite	:=	strtran(cPathSite,"\","/")
	::calcLog	:= 	TBIFileIO():New(::oOwner():cBscPath()+"logs\metadados\export\"+ cLogName + ".html")

	// Cria o arquivo htm
	If ! ::calcLog:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		::oOwnser():Log(STR0003) //"Erro na criacao do arquivo de log."
	else
		::calcLog:nWriteLN('<html>')
		::calcLog:nWriteLN('<head>')
		::calcLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
  		::calcLog:nWriteLN('<title>'+STR0004+'</title>') //"BSC - Log de exportação"
		::calcLog:nWriteLN('<link href= "'+ cPathSite + 'css/report.css" rel="stylesheet" type="text/css">')
		::calcLog:nWriteLN('</head>')
		::calcLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::calcLog:nWriteLN('<table width="90%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td class="titulo"><div align="center">'+STR0004+ '</div></td>') //"BSC - Log de exportação"
		::calcLog:nWriteLN('</tr>')
		::calcLog:nWriteLN('</table>')
		::calcLog:nWriteLN('<table width="90%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td width="21%" class="cabecalho_1">'+STR0005+'</td>') //"Data"
		::calcLog:nWriteLN('<td width="79%" class="cabecalho_1">'+STR0006+'</td>') //"Eventos"
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
method lCal_WriteLog(cMensagem) class TBSCEstExport

	  ::calcLog:nWriteLN('<tr>')
	  ::calcLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	  ::calcLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	  ::calcLog:nWriteLN('</tr>')
      
      ::oOwner():Log(cMensagem)
return .t.
       
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
method lCal_CloseLog() class TBSCEstExport
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
method unlockExport(nHandle) class TBSCEstExport
	local lUnLock := .t.

    if ! fClose(nHandle) 
		lUnLock := .f.
	endif
return lUnLock    

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} exportXml
Cria estrutura XML de todas as entidades abaixo do nó informado

@protected
@param		aPk Array de chaves de busca
@param		cDirName Nome do diretório onde serão gravadas as estruturas
@param		cNode Nome do nó que será processado
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		Status do processamento (BSC_ST_OK ou BSC_ST_BADXML)
/*/
//--------------------------------------------------------------------------------------
method exportXml(aPk, cDirName, cNode) class TBSCEstExport
	local nQtdTabelas	:= 23
	local nPct 			:= 0
	local nPctIni		:= 0
	local nStatus		:= BSC_ST_OK
	local oFile			:= nil
	local cFileName		:= ""

	nPct := int( 100 / nQtdTabelas )
	nPctIni := 100 - ( nQtdTabelas * nPct )

	//Ajuste de arredondamento
	::oProgressBar():setPercent( nPctIni )

	//Arquivo de controle
	cFileName := ::oOwner():cBscPath() + "metadados\" + cDirName + ".org\.lock"
	oFile := TBIFileIO():New( cFileName )

	//Verifica se já existe arquivo de controle
	if oFile:lExists()
		::lCal_WriteLog( STR0010 )  //Arquivo informado já existe

		oProgressBar:setStatus(PROGRESS_BAR_ERROR)
   		oProgressBar:setMessage( STR0010 )  //Arquivo informado já existe

		nStatus := BSC_ST_BADXML
	endif

	if ( nStatus == BSC_ST_OK )
		//Cria arquivo de controle
		if !oFile:lCreate( FO_READWRITE, .T. )
			::lCal_WriteLog( STR0008 )  //Erro na criação do arquivo
	
			oProgressBar:setStatus(PROGRESS_BAR_ERROR)
	   		oProgressBar:setMessage( STR0008 )  //Erro na criação do arquivo
	
			nStatus := BSC_ST_BADXML
		else
			//fecha arquivo
			oFile:lClose()
		endif
	endif

	//Inicia exportação da estrutura
	if ( nStatus == BSC_ST_OK )
		nStatus := ::exportXmlAux( cDirName, 1, @aPk, "ID", "ID", cNode, "ORGANIZACOES", @nPctIni, nPct )
	endif

return nStatus

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} exportXmlAux
Método recursivo para criar estrutura XML de todas as entidades abaixo do nó informado

@protected
@param		cDirName Nome do diretório onde serão gravadas as estruturas
@param		nIdxKey Índice para busca
@param		aSearchKey array de chaves de busca
@param		cFieldKey Nome do campo onde será realizada a busca
@param		cPkName Nome do campo chave
@param		cTable Nome da tabela
@param		cGroup Nome do grupo no XML
@param		nPctIni Pct atual (passado via referência)
@param		nPctStp Pct que cada tabela representa
@param		nMax Quantidade máxima de registros por arquivo
@param		cExtraFilter Filtro adicional que pode ser aplicado na tabela a ser exportada
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		Status do processamento (BSC_ST_OK ou BSC_ST_BADXML)
/*/
//--------------------------------------------------------------------------------------
method exportXmlAux( cDirName, nIdxKey, aSearchKey, cFieldSearchKey, cPkName, cTable, cGroup, nPct, nPctStp, nMax, cExtraFilter ) class TBSCEstExport
	local	aIds			:= {}
	local	nStatus			:= BSC_ST_OK 
	default nMax			:= 500
	default cExtraFilter	:= ""
	
	nPct := nPct + nPctStp

	conout( padl( Alltrim( Str( nPct ) ), 3, "0" ) + "%" + "    " + cGroup )

	//Exporta estrutura da tabela informada
	aIds := ::saveXML( cDirName, nIdxKey, @aSearchKey, cFieldSearchKey, cPkName, cTable, cGroup, nMax, cExtraFilter, @nStatus )

	if (nStatus	!= BSC_ST_OK)
		oProgressBar:setStatus(PROGRESS_BAR_ERROR)
   		oProgressBar:setMessage( STR0008 + " - " + cGroup + ".xml" )  //Erro na criação do arquivo

   		return nStatus
	endif
	
    ::oProgressBar():setPercent( nPct )
	
	//Exporta estruturas filhas
	do case
		case cTable == "ORGANIZACAO"
            //Estrutura Estratégia
            nStatus := ::exportXmlAux( cDirName, 4, @aIds, "PARENTID", "ID", "ESTRATEGIA", "ESTRATEGIAS", @nPct, nPctStp )
            
		case cTable == "ESTRATEGIA"
            //Estrutura Perspectiva
            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "PERSPECTIVA", "PERSPECTIVAS", @nPct, nPctStp )

			if (nStatus == BSC_ST_OK)
				//Estrutura Dashboard
	            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "DASHBOARD", "DASHBOARDS", @nPct, nPctStp )
			endif

			if (nStatus == BSC_ST_OK)
				//Estrutura Tema Estratégico
	            nStatus := ::exportXmlAux( cDirName, 2, @aIds, "PARENTID", "ID", "TEMAEST", "TEMAESTS", @nPct, nPctStp )
			endif			
			
			if (nStatus == BSC_ST_OK)
				//Estrutura Mapa 1
	            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "MAPAEST", "MAPAESTS1", @nPct, nPctStp, nMax, "SCRTYPE <> 'T' AND DESTYPE <> 'T'" )
			endif

			if (nStatus == BSC_ST_OK)
				//Estrutura Mapa 2
	            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "MAPAEST", "MAPAESTS2", @nPct, nPctStp, nMax, "SCRTYPE <> 'T' AND DESTYPE = 'T'" )
			endif

			if (nStatus == BSC_ST_OK)
				//Estrutura Mapa 3
	            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "MAPAEST", "MAPAESTS3", @nPct, nPctStp, nMax, "SCRTYPE = 'T' AND DESTYPE <> 'T'" )
			endif

			if (nStatus == BSC_ST_OK)
				//Estrutura Mapa 4
	            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "MAPAEST", "MAPAESTS4", @nPct, nPctStp, nMax, "SCRTYPE = 'T' AND DESTYPE = 'T'" )
			endif
		case cTable == "PERSPECTIVA"
            //Estrutura Objetivo
            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "OBJETIVO", "OBJETIVOS", @nPct, nPctStp )
                 
			if (nStatus == BSC_ST_OK)
	            //Estrutura Mapa Tema
	            nStatus := ::exportXmlAux( cDirName, 2, @aIds, "PARENTID", "ID", "MAPATEMA", "MAPATEMAS", @nPct, nPctStp )
			endif	
		case cTable == "OBJETIVO"
            //Estrutura Indicador
            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "INDICADOR", "INDICADORES", @nPct, nPctStp )
                 
			if (nStatus == BSC_ST_OK)
	            //Estrutura Iniciativa
	            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "INICIATIVA", "INICIATIVAS", @nPct, nPctStp )
			endif
			
			if (nStatus == BSC_ST_OK)	
	            //Estrutura FCS
	            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "FCS", "FCSS", @nPct, nPctStp )
			endif	
		case cTable == "INICIATIVA"
            //Estrutura TAREFA
            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "TAREFA", "TAREFAS", @nPct, nPctStp )

			if (nStatus == BSC_ST_OK)	
	            //Estrutura INIDOC
	            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "INIDOC", "INIDOCS", @nPct, nPctStp )
			endif	
		case cTable == "FCS"
            //Estrutura FCSIND
            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "FCSIND", "FCSINDS", @nPct, nPctStp )

		case cTable == "MAPATEMA"
            //Estrutura TEMAOBJETIVO
            nStatus := ::exportXmlAux( cDirName, 2, @aIds, "PARENTID", "ID", "TEMAOBJETIVO", "TEMAOBJETIVOS", @nPct, nPctStp )

		case cTable == "DASHBOARD"
            //Estrutura CARD
            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "CARD", "CARDS", @nPct, nPctStp )

		case cTable == "TEMAEST"
            //Estrutura TEMESTOBJ
            nStatus := ::exportXmlAux( cDirName, 2, @aIds, "PARENTID", "ID", "TEMESTOBJ", "TEMESTOBJS", @nPct, nPctStp )

		case cTable == "INDICADOR"
            //Estrutura INDDOC
            nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "INDDOC", "INDDOCS", @nPct, nPctStp )

		case cTable == "FCSIND"
            //Estrutura FCSDOC
   	        nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "FCSDOC", "FCSDOCS", @nPct, nPctStp )
            
		case cTable == "TAREFA"	
            //Estrutura TARDOC
			nStatus := ::exportXmlAux( cDirName, 3, @aIds, "PARENTID", "ID", "TARDOC", "TARDOCS", @nPct, nPctStp )
            
//		case cTable == "TEMAOBJETIVO"
//		case cTable == "MAPAEST"
//		case cTable == "CARD"
//		case cTable == "DESDOB"
//		case cTable == "TEMESTOBJ"
	endcase
return nStatus


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} saveXml
Cria estrutura XML

@protected
@param		oXMLFile Objeto que controla a gravação em arquivo
@param		nIdxKey Indíce para busca
@param		aSearchKey array de chaves de busca
@param		cFieldKey Nome do campo onde será realizada a busca
@param		cPkName Nome do campo chave
@param		cTable Nome da tabela      
@param		cGroup Nome do grupo no XML
@param		nMax Quantidade máxima de registros por arquivo
@param		cExtraFilter Filtro adicional que pode ser aplicado na tabela a ser exportada
@param		nStatus Status de retorno do processamento (passado via referência)
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		Array com Ids Adicionados ao XML
/*/
//--------------------------------------------------------------------------------------
method saveXml(cDirName, nIdxKey, aSearchKey, cFieldSearchKey, cPkName, cTable, cGroup, nMax, cExtraFilter, nStatus) class TBSCEstExport
	local aIds				:= {}
	local aIdsRet			:= {}
	local aFields			:= {}
	local vFieldValue		:= nil
	local nQtd 				:= 0  
    local nKey				:= 0  
	local lSeekId			:= .T.
	local oTable			:= nil
	local vSearchKey		:= nil
	local cFilter			:= ""
	local nCount			:= 0
	local nCountFile		:= 1
	local cFileName			:= ""
	local lOpen				:= .F.

	oTable := ::oOwner():oGetTable( cTable )
	oTable:SetOrder( nIdxKey )

	for nKey := 1 to len( aSearchKey )
		vSearchKey := aSearchKey[nKey]

		aIds := {}

		//Localiza chave na tabela atual (para não precisar criar índices foi usado filtro)
		cFilter := cFieldSearchKey + "=" + cBIStr( vSearchKey )
		if ( !Empty( cExtraFilter ) )
			cFilter += " AND (" + cExtraFilter + ")"
		endif

		oTable:cSQLFilter( cFilter )
		oTable:lFiltered( .T. )
		oTable:_First()

		while( !oTable:lEof() )
			if ( nCount == 0 )
				//Abre xml
				cFileName := ::oOwner():cBscPath() + "metadados\" + cDirName + ".org\" + cGroup + "\" + padl( Alltrim( Str(nCountFile) ), 6, "0" ) + ".xml"

				oXMLFile := TBIFileIO():New( cFileName )
				if !oXmlFile:lCreate( FO_READWRITE, .T. )
					::lCal_WriteLog( STR0008 + " - " + cFileName )  //Erro na criação do arquivo xxx.xml
					nStatus := BSC_ST_BADXML
			
					return .F.
				endif

				lOpen := .T.
			
				oXmlFile:nWriteln( '<?xml version="1.0" encoding="ISO-8859-1" ?>' )
				oXmlFile:nWriteln( "<METADADOS>" )
			
				oXMLFile:nWriteln( "<" + Upper( cGroup ) + ">" )
			endif

			oXMLFile:nWriteln( "<" + Upper( cTable ) + ">" )

			//Recupera campos do registro atual
			aFields := oTable:xRecord(RF_ARRAY)

			lSeekId = .T.

			for nQtd := 1 to len( aFields )
				//utilizado lSeekId para melhorar performance
				if ( lSeekId .AND. upper( aFields[nQtd][1] ) == upper( cPkName ) )
					lSeekId = .F.
					aAdd( aIds, aFields[nQtd][2] )
				endif

				//Nome do Campo
				oXMLFile:nWrite( "<" + Upper( aFields[nQtd][1] ) + ">" )

				//Valor do Campo
				vFieldValue := cBIStr( aFields[nQtd][2] )
				
				//Converte caracteres especiais
				vFieldValue := ::changeSpecialChar( vFieldValue )

				oXMLFile:nWriteln( vFieldValue )
				
				oXMLFile:nWriteln( "</" + Upper( aFields[nQtd][1] ) + ">" )
			next

			oXMLFile:nWriteln( "</" + Upper( cTable ) + ">" )

			nCount++
			if ( nCount >= nMax )
				nCount = 0
				
				//fecha XML
				oXMLFile:nWriteln( "</" + Upper( cGroup ) + ">" )
				oXmlFile:nWriteln( "</METADADOS>" )
				oXmlFile:lClose()
		 
				lOpen := .F.
					
				nCountFile++
			endif

			oTable:_Next()
		enddo

		AEVal ( aIds, {|nId| aAdd( aIdsRet, nId )} )
	next

	if ( lOpen )
		//fecha XML
		oXMLFile:nWriteln( "</" + Upper( cGroup ) + ">" )
		oXmlFile:nWriteln( "</METADADOS>" )
		oXmlFile:lClose()
	endif

	oTable:cSQLFilter("")

	nStatus := BSC_ST_OK

return aIdsRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} changeSpecialChar
Converte caracteres especiais em seus devidos códigos

@protected
@param		cText Valor a ser convertido
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		Valor com caracteres especiais convertidos
/*/
//--------------------------------------------------------------------------------------
method changeSpecialChar(cText) class TBSCEstExport
	local cTextOut
	
	cTextOut = alltrim( cText )
	cTextOut = replace( cTextOut, "&", "&amp;" )
	cTextOut = replace( cTextOut, "\", "&quot;" )
	cTextOut = replace( cTextOut, ">", "&gt;" )
	cTextOut = replace( cTextOut, "<", "&lt;" )
return cTextOut

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} bscExp_Metadados
Exporta metadados do BSC

@protected
@param		aParms
@author		3510 - Gilmar P. Santos
@version	P10 R1.3
@since		22/06/2009
@return		.T. se não ocorrer erro
/*/
//--------------------------------------------------------------------------------------
function bscExp_Metadados(aParms)
	local cLogName		:= ""
	local nQtd			:= 0 
	local nTotal		:= 0 
	local nHandle		:= 0

	local nStatus		:= BSC_ST_OK

	local oExport		:= nil

	local oProgress		:= nil
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
	oBSCCore := TBSCCore():New( aParms[4] )
	ErrorBlock( {|oE| __BSCError(oE)} )

    oProgressBar := oBSCCore:oGetTool( "PROGRESSBAR" )
    oProgressBar:setup("bscestexp_1")

	oProgressBar:setStatus(PROGRESS_BAR_OK)
   	oProgressBar:setMessage(STR0001) //"Iniciando Exportação..."
   	
	//Abre conexão
	if( oBSCCore:nDBOpen() < 0 )
		oBSCCore:Log( STR0007, BSC_LOG_SCRFILE ) //"Erro na abertura do banco de dados"

		oProgress:setStatus(PROGRESS_BAR_ERROR) 
   		oProgress:setMessage(STR0007) //"Erro na abertura do banco de dados"

		// Espera 1 segundo para finalizar
		// e dar tempo para o retorno ao BSS
		sleep( 1000 )

		return .F.
	endif

	//Instancia oExport
	oExport	:= oBSCCore:oGetTable( TAG_ENTITY )
	oExport:setProgressBar( oProgressBar )
	
	//Verifica se o job esta em execucao
	nHandle	:=	fCreate( oExport:cJobName, 1 )
	if ( nHandle == -1 )
		oBSCCore:Log( STR0002, BSC_LOG_SCRFILE ) //"Atenção. Existe uma exportação de estrutura em andamento." 

		oProgressBar:setStatus(PROGRESS_BAR_ERROR)
   		oProgressBar:setMessage(STR0002) //"Atenção. Existe uma exportação de estrutura em andamento."

		// Espera 1 segundo para finalizar
		// e dar tempo para o retorno ao BSS
		sleep( 1000 )

		return .F.
	endif

	//Criando do arquivo de log.
	cLogName := alltrim( getJobProfString( "INSTANCENAME", "BSC") ) + "_"
	cLogName += strtran( dToc( date() ), "/", "" ) + "_"
	cLogName += strtran( time(), ":", "" )

	oExport:lCal_CriaLog( aParms[3], cLogName )
	oExport:lCal_WriteLog( STR0001 ) //"Iniciando exportação..."

	nStatus := oExport:exportXml( @{aParms[2]}, aParms[1], "ORGANIZACAO" ) //aParms[2] = ID, aParms[1] = DirName

	if (nStatus == BSC_ST_OK)			
		oProgressBar:setMessage( STR0009 ) //"Exportação finalizada"
		oProgressBar:endProgress()
	endif

	oExport:lCal_WriteLog( STR0009 ) //"Exportação finalizada"
	oExport:lCal_CloseLog() 

	//Libera o job em execução	
	oExport:unlockExport( nHandle )

	// Espera 2 segundos para finalizar
	// e dar tempo para o retorno ao BSC		
	sleep(2000)	 

return .T.

function _BSC083_Estexp()
return