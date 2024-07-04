#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "JURA228A.CH"

//-----------------------------------------------------------------------------------------------------------
//	CUIDADO QUANDO FOR GERAR ESTE WSCLIENT, PORQUE ALÉM DO WSCLIENT EXISTE FUNÇÕES NO FIM DO FONTE
//-----------------------------------------------------------------------------------------------------------

/* ===============================================================================
WSDL Location    http://juridico.totvsbpo.com.br:8082/WSDISTRIBUICOES.apw?WSDL
Gerado em        10/17/16 14:26:49
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _XNSMWLD ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service JURA228A - Serviço de validação de acesso as distribuições Totvs 
------------------------------------------------------------------------------- */

WSCLIENT JURA228A

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD MTDISTRIBUICOES

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSUARIO                  AS string
	WSDATA   cSENHA                    AS string
	WSDATA   oWSMTDISTRIBUICOESRESULT  AS WSDISTRIBUICOES_ARRAYOFSTRUACESSODIS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA228A
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160928 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA228A
	::oWSMTDISTRIBUICOESRESULT := WSDISTRIBUICOES_ARRAYOFSTRUACESSODIS():New()
Return

WSMETHOD RESET WSCLIENT JURA228A
	::cUSUARIO           := NIL 
	::cSENHA             := NIL 
	::oWSMTDISTRIBUICOESRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA228A
Local oClone := JURA228A():New()
	oClone:_URL          := ::_URL 
	oClone:cUSUARIO      := ::cUSUARIO
	oClone:cSENHA        := ::cSENHA
	oClone:oWSMTDISTRIBUICOESRESULT :=  IIF(::oWSMTDISTRIBUICOESRESULT = NIL , NIL ,::oWSMTDISTRIBUICOESRESULT:Clone() )
Return oClone

// WSDL Method MTDISTRIBUICOES of Service JURA228A

WSMETHOD MTDISTRIBUICOES WSSEND cUSUARIO,cSENHA WSRECEIVE oWSMTDISTRIBUICOESRESULT WSCLIENT JURA228A
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTDISTRIBUICOES xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("USUARIO", ::cUSUARIO, cUSUARIO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SENHA", ::cSENHA, cSENHA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</MTDISTRIBUICOES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTDISTRIBUICOES",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSDISTRIBUICOES.apw")

::Init()
::oWSMTDISTRIBUICOESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTDISTRIBUICOESRESPONSE:_MTDISTRIBUICOESRESULT","ARRAYOFSTRUACESSODIS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFSTRUACESSODIS

WSSTRUCT WSDISTRIBUICOES_ARRAYOFSTRUACESSODIS
	WSDATA   oWSSTRUACESSODIS          AS WSDISTRIBUICOES_STRUACESSODIS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSDISTRIBUICOES_ARRAYOFSTRUACESSODIS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSDISTRIBUICOES_ARRAYOFSTRUACESSODIS
	::oWSSTRUACESSODIS     := {} // Array Of  WSDISTRIBUICOES_STRUACESSODIS():New()
Return

WSMETHOD CLONE WSCLIENT WSDISTRIBUICOES_ARRAYOFSTRUACESSODIS
	Local oClone := WSDISTRIBUICOES_ARRAYOFSTRUACESSODIS():NEW()
	oClone:oWSSTRUACESSODIS := NIL
	If ::oWSSTRUACESSODIS <> NIL 
		oClone:oWSSTRUACESSODIS := {}
		aEval( ::oWSSTRUACESSODIS , { |x| aadd( oClone:oWSSTRUACESSODIS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSDISTRIBUICOES_ARRAYOFSTRUACESSODIS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUACESSODIS","STRUACESSODIS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUACESSODIS , WSDISTRIBUICOES_STRUACESSODIS():New() )
			::oWSSTRUACESSODIS[len(::oWSSTRUACESSODIS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STRUACESSODIS

WSSTRUCT WSDISTRIBUICOES_STRUACESSODIS
	WSDATA   cCODESCRITORIO            AS string
	WSDATA   cNOMERELACIONAL           AS string
	WSDATA   cURL                      AS string
	WSDATA   cTOKEN			           AS string
	WSDATA   cAGRUPADOR		           AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSDISTRIBUICOES_STRUACESSODIS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSDISTRIBUICOES_STRUACESSODIS
Return

WSMETHOD CLONE WSCLIENT WSDISTRIBUICOES_STRUACESSODIS
	Local oClone := WSDISTRIBUICOES_STRUACESSODIS():NEW()
	oClone:cCODESCRITORIO       := ::cCODESCRITORIO
	oClone:cNOMERELACIONAL      := ::cNOMERELACIONAL
	oClone:cURL                 := ::cURL
	oClone:cTOKEN               := ::cTOKEN
	oClone:cAGRUPADOR           := ::cAGRUPADOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSDISTRIBUICOES_STRUACESSODIS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODESCRITORIO     :=  WSAdvValue( oResponse,"_CODESCRITORIO","string",NIL,"Property cCODESCRITORIO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMERELACIONAL    :=  WSAdvValue( oResponse,"_NOMERELACIONAL","string",NIL,"Property cNOMERELACIONAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cURL               :=  WSAdvValue( oResponse,"_URL","string",NIL,"Property cURL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTOKEN             :=  WSAdvValue( oResponse,"_TOKEN","string",NIL,"Property cTOKEN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL)
	::cAGRUPADOR         :=  WSAdvValue( oResponse,"_AGRUPADOR","string",NIL,"Property cAGRUPADOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL)
Return
//-------------------------------------------------------------------
//	FIM DO CLIENTE WEBSERVICES
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} J228AcDiTo()
Função que valida o cliente junto a Totvs, para ver se ele está habilitado
para distribuições totvs.

@return  aDados
@author  Rafael Tenorio da Costa
@since 	 06/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J228AcDiTo()

	Local cUsuario	:= SuperGetMV('MV_JINDUSR', , "")
	Local cSenha   	:= SuperGetMV('MV_JINDPSW', , "")
	Local lRetorno	:= .F.
	Local oWS		:= Nil
	Local aDados 	:= {}
	Local nLogin	:= 0
	Local aAcessos	:= {}
	
	oWS := JURA228A():New()
	
	oWS:cUSUARIO := cUsuario
	oWS:cSENHA   := cSenha
	
	If oWS:MTDISTRIBUICOES()
		If oWS:oWsMtDistribuicoesResult <> Nil
													
			aDados	 := oWs:oWsMtDistribuicoesResult:oWsStruAcessoDis
			lRetorno := .T.
			
			For nLogin:=1 To Len(aDados)
				Aadd(aAcessos, {	aDados[nLogin]:cNomeRelacional	,;
									aDados[nLogin]:cCodEscritorio	,;
									aDados[nLogin]:cToken			,;
									aDados[nLogin]:cAgrupador		,;
									aDados[nLogin]:cUrl				} )
			Next nLogin
		EndIf
	EndIf
	
	If !lRetorno
		ConOut( STR0007 + GetWSCError() )		//"Erro ao validar serviço de monitoramento TOTVS - (MTDISTRIBUICOES): "
	EndIf
	
	FwFreeObj(aDados)
	FwFreeObj(oWS)
	
Return aAcessos
