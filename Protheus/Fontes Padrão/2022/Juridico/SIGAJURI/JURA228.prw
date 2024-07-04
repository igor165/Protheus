#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://legaldata.totvsbpo.com.br:9090/WebServiceDistribuicao/WebServiceSolucionare.asmx?WSDL
Gerado em        02/14/17 16:01:07
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KIERXCF ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service JURA228
------------------------------------------------------------------------------- */

WSCLIENT JURA228

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD RecuperarNovaDistribuicao
	WSMETHOD ConfirmaDistribuicaoEnviada

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cnomeRelacional           AS string
	WSDATA   ctoken                    AS string
	WSDATA   ncodEscritorio            AS int
	WSDATA   oWSRecuperarNovaDistribuicaoResult AS SCHEMA
	WSDATA   nID                       AS int
	WSDATA   lbaixado                  AS boolean
	WSDATA   lConfirmaDistribuicaoEnviadaResult AS boolean
	WSDATA   cURL                      AS String

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA228
	::Init()
	If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20161110 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA228
	::oWSRecuperarNovaDistribuicaoResult := NIL 
Return

WSMETHOD RESET WSCLIENT JURA228
	::cnomeRelacional    := NIL 
	::ctoken             := NIL 
	::ncodEscritorio     := NIL 
	::oWSRecuperarNovaDistribuicaoResult := NIL 
	::nID                := NIL 
	::lbaixado           := NIL 
	::lConfirmaDistribuicaoEnviadaResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA228
Local oClone := JURA228():New()
	oClone:_URL          := ::_URL 
	oClone:cnomeRelacional := ::cnomeRelacional
	oClone:ctoken        := ::ctoken
	oClone:ncodEscritorio := ::ncodEscritorio
	oClone:nID           := ::nID
	oClone:lbaixado      := ::lbaixado
	oClone:lConfirmaDistribuicaoEnviadaResult := ::lConfirmaDistribuicaoEnviadaResult
Return oClone

// WSDL Method RecuperarNovaDistribuicao of Service JURA228

WSMETHOD RecuperarNovaDistribuicao WSSEND cnomeRelacional,ctoken,ncodEscritorio WSRECEIVE oWSRecuperarNovaDistribuicaoResult WSCLIENT JURA228
Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<RecuperarNovaDistribuicao xmlns="http://tempuri.org/">'
		cSoap += WSSoapValue("nomeRelacional", ::cnomeRelacional, cnomeRelacional , "string", .F. , .F., 0 , NIL, .F.,.F.) 
		cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .F. , .F., 0 , NIL, .F.,.F.) 
		cSoap += WSSoapValue("codEscritorio", ::ncodEscritorio, ncodEscritorio , "int", .T. , .F., 0 , NIL, .F.,.F.) 
		cSoap += "</RecuperarNovaDistribuicao>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
			"http://tempuri.org/RecuperarNovaDistribuicao",; 
			"DOCUMENT","http://tempuri.org/",,,; 
			::cURL)

		::Init()
		::oWSRecuperarNovaDistribuicaoResult :=  WSAdvValue( oXmlRet,"_RECUPERARNOVADISTRIBUICAORESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.

// WSDL Method ConfirmaDistribuicaoEnviada of Service JURA228

WSMETHOD ConfirmaDistribuicaoEnviada WSSEND cnomeRelacional,ctoken,nID,lbaixado WSRECEIVE lConfirmaDistribuicaoEnviadaResult WSCLIENT JURA228
Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += '<ConfirmaDistribuicaoEnviada xmlns="http://tempuri.org/">'
		cSoap += WSSoapValue("nomeRelacional", ::cnomeRelacional, cnomeRelacional , "string", .F. , .F., 0 , NIL, .F.,.F.) 
		cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .F. , .F., 0 , NIL, .F.,.F.) 
		cSoap += WSSoapValue("ID", ::nID, nID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
		cSoap += WSSoapValue("baixado", ::lbaixado, lbaixado , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
		cSoap += "</ConfirmaDistribuicaoEnviada>"

		oXmlRet := SvcSoapCall(	Self,cSoap,; 
			"http://tempuri.org/ConfirmaDistribuicaoEnviada",; 
			"DOCUMENT","http://tempuri.org/",,,; 
			::cURL)

		::Init()
		::lConfirmaDistribuicaoEnviadaResult :=  WSAdvValue( oXmlRet,"_CONFIRMADISTRIBUICAOENVIADARESPONSE:_CONFIRMADISTRIBUICAOENVIADARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T.



