#include "SigaWF.CH" 
#include "WFHTTP.CH" 

function WFHTTPRet( __aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage )
	local nPos          := 0
	local aParams := {}
	local cReturn       := ""
	local cFileName 	:= ""
	local cProcessID 	:= ""
	local cMsg   		:= ""
	local oWF           := Nil
	Local cMessage 		:= ""
	Local cMessageType	:= ""
	Local lSuccess      := .F.
	Local cEmpresa		:= ""
	Local _cFilial		:= ""
	
	If ( ValType( __aPostParms ) == "A" )
		if ( Len( __aPostParms ) > 0 )
			//Recupera a empresa para realização do retorno do processo.
			if ( nPos := AsCan( __aPostParms,{ |x| Upper( x[1] ) == EH_EMPRESA } ) ) > 0
				cEmpresa := __aPostParams[ nPos,2 ]
				AAdd( aParams, cEmpresa )
			end
			
			//Recupera a filial para realização do retorno do processo.
			if ( nPos := AsCan( __aPostParms,{ |x| Upper( x[1] ) == EH_FILIAL } ) ) > 0
				_cFilial := __aPostParms[ nPos,2 ]
				AAdd( aParams, _cFilial )
			end
			
			//Recupera o ID do processo para realização do retorno.
			If ( Len( aParams ) == 2 )
				if ( nPos := AScan( __aPostParms, { |x| Upper( x[1] ) == Upper(EH_MAILID) } ) ) > 0
					cProcessID := Lower( __aPostParms[ nPos,2 ] )
					cProcessID := Iif( Left( cProcessID, 2 ) == "wf", Substr( cProcessID,3 ), cProcessID )
					cProcessID := Left( cProcessID + Space( 20 ),20 )
					
					RPCSetType( WF_RPCSETTYPE )
					
					If ( WFPrepEnv( aParams[1], aParams[2], "WFHTTPRet",, WFGetModulo( aParams[1], aParams[2] ) ) )
						AAdd( aParams, __aPostParms )
						
						If ( Empty( cMsg := WFReturn( aParams, .F., .T. ) ) )
							cMessage		+= STR0004  //"Resposta enviada para o servidor"
							cMessageType 	:= "Mensagem"
							lSuccess        := .T.
						else
							cMessage		+= cMsg
							cMessageType    := "Alerta"
							lSuccess        := .F.
						EndIf
					else
						cMessage		+= STR0007 // "Ocorreu uma falha de abertura de arquivos no sistema. Tente novamente."
						cMessageType    := "Erro"
						lSuccess        := .F.
					EndIf
				else
					cMsg := STR0009 // "ID do Processo NAO IDENTIFICADO. Solicite suporte."
					cMessage		+= cMsg
					cMessageType    := "Erro"
					lSuccess        := .F.
				EndIf
			Else
				cMessage		+= STR0001 //
				cMessageType    := "Erro"
				lSuccess        := .F.
				
			EndIf
		else
			cMessage		+= STR0003 //"Nao houve postdata a ser processado"
			cMessageType    := "Erro"
			lSuccess        := .F.
		EndIf
	else
		cMessage		+= STR0011 //"Os parâmetros para o retorno não foram recebidos."
		cMessageType    := "Erro"
		lSuccess        := .F.
	EndIf
	
	WFConout( STR0012,,,,.T.,"WFHTTPRET" )//"Execução de retorno"
	WFConout( STR0013 + cProcessID,,,,,"WFHTTPRET" ) //"Processo: "
	WFConout( STR0014 + cEmpresa,,,,, "WFHTTPRET" ) //"Empresa: "
	WFConout( STR0015 + _cFilial,,,,, "WFHTTPRET")//"Filial: "
	WFConout( STR0016 + cMessage,,,,, "WFHTTPRET")//"Mensagem: "
	
	If ( ExistBlock( "WFPE007" ) )
		cReturn := ExecBlock( "WFPE007",.F.,.F.,{ lSuccess, cMessage, cProcessID } )
	Else
		cFileName := Iif (lSuccess, "\wfreturn.htm", "\wfreterr.htm" )
		
		If ( File( cFileName ) )
			cReturn := WFLoadFile( cFileName )
		else
			cReturn := WFHtmlTemplate("TOTVS | Workflow", cMessage, cMessageType )
		EndIf
	EndIf
return cReturn 
 
/******************************************************************************
	SigaWFStart()
	Esta funcao capta o evento de inicializacao do serviço WEBEX para o Workflow
	a partir da declaraçao na secao do arquivo .ini do servidor protheus.
	type=web
	SigaWeb=WF
 *****************************************************************************/
function SigaWFStart()
	local cJobName := getWebJob(), cAux
   	local aAux

	PUBLIC __oWF

	while right(cJobName,1) == "_"
		cJobName := substr( cJobName, 1, rat("_", cJobName)-1 )
	enddo

	if !Empty( cAux := Alltrim( GetPvProfString( cJobName, "PrepareIn", "", GetADV97() ) ) )
		aAux := WFTokenChar( cAux, "," )
		WFPrepEnv( aAux[1], aAux[2] )
		__oWF := TWorkflow():New()
	end
	
	conout(STR0010)	// "Iniciando Workflow via Working threads (WEBEX)..."
return .t.

/******************************************************************************
	SigaWFConnect()
	Esta funcao capta os eventos de POST e GET solicitados a partir do browser.
 *****************************************************************************/
function SigaWFConnect(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	local cHtml := ""
	local nPos

	if ( nPos := AScan( __aProcParms, { |x| Lower( x[1] ) == "procid" } ) ) > 0
		cHtml := WFLoadFile( StrTran( __oWF:cMessengerDir + __aProcParms[ nPos,2 ], "\", "/" ) )
	else
		cHtml := WFHTTPRet( __aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage )
	end
	
return cHtml

web function WFHttpRet()
return .t.
