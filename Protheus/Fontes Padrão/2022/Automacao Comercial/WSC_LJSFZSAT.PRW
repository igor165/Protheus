#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    https://wssatsp.fazenda.sp.gov.br/CfeConsultarLotes/CfeConsultarLotes.asmx?WSDL
Gerado em        09/23/16 10:12:40
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _MYOBRFK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCfeConsultaLotes
------------------------------------------------------------------------------- */

WSCLIENT WSCfeConsultaLotes

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ConsultarLotesEnviados

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ccfeDadosMsg              AS string
	WSDATA   ccUF                      AS string
	WSDATA   cversaoDados              AS string
	WSDATA   oWS                       AS SCHEMA
	WSDATA   cCfeConsultarLotesResult  AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCfeConsultaLotes
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20151103] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCfeConsultaLotes
	::oWS                := NIL 
Return

WSMETHOD RESET WSCLIENT WSCfeConsultaLotes
	::ccfeDadosMsg       := NIL 
	::ccUF               := NIL 
	::cversaoDados       := NIL 
	::oWS                := NIL 
	::cCfeConsultarLotesResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCfeConsultaLotes
Local oClone := WSCfeConsultaLotes():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:ccfeDadosMsg  := ::ccfeDadosMsg
	oClone:ccUF          := ::ccUF
	oClone:cversaoDados  := ::cversaoDados
	oClone:cCfeConsultarLotesResult := ::cCfeConsultarLotesResult
Return oClone

// WSDL Method ConsultarLotesEnviados of Service WSCfeConsultaLotes

WSMETHOD ConsultarLotesEnviados WSSEND ccfeDadosMsg,ccUF,cversaoDados,oWS WSRECEIVE cCfeConsultarLotesResult WSCLIENT WSCfeConsultaLotes
Local cSoap := "" , oXmlRet
Local cSoapHead := "" 

BEGIN WSMETHOD

cSoapHead += '<cfeCabecMsg xmlns="http://www.fazenda.sp.gov.br/sat/wsdl/CfeConsultaLotes">'
cSoapHead += WSSoapValue("cUF", ::ccUF, ccUF , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("versaoDados", ::cversaoDados, cversaoDados , "string", .F. , .F., 0 , NIL, .F.) 
cSoapHead += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.) 
cSoapHead +=  "</cfeCabecMsg>"

cSoap += '<CfeConsultarLotes xmlns="http://www.fazenda.sp.gov.br/sat/wsdl/CfeConsultaLotes">'
cSoap += WSSoapValue("cfeDadosMsg", ::ccfeDadosMsg, ccfeDadosMsg , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CfeConsultarLotes>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.fazenda.sp.gov.br/sat/wsdl/CfeConsultar",; 
	"DOCUMENT","http://www.fazenda.sp.gov.br/sat/wsdl/CfeConsulta?Lotes",cSoapHead,,; 
	"https://wssatsp.fazenda.sp.gov.br/CfeConsultarLotes/CfeConsultarLotes.asmx")

::Init()
::cCfeConsultarLotesResult :=  WSAdvValue( oXmlRet,"_CFECONSULTARLOTESRESPONSE:_CFECONSULTARLOTESRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.
