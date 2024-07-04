#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://169.254.161.140:88/LOJGERDADDR.apw?WSDL
Gerado em        05/11/11 08:00:50
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110315
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SNPNHRS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLOJGERDADDR
------------------------------------------------------------------------------- */

WSCLIENT WSLOJGERDADDR

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETLOTE

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCPRODUTO                 AS string
	WSDATA   cCLOTE                    AS string
	WSDATA   cCEMP                     AS string
	WSDATA   cCFIL                     AS string
	WSDATA   lGETLOTERESULT            AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLOJGERDADDR
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.090818P-20100625] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLOJGERDADDR
Return

WSMETHOD RESET WSCLIENT WSLOJGERDADDR
	::cCPRODUTO          := NIL 
	::cCLOTE             := NIL 
	::cCEMP              := NIL 
	::cCFIL              := NIL 
	::lGETLOTERESULT     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLOJGERDADDR
Local oClone := WSLOJGERDADDR():New()
	oClone:_URL          := ::_URL 
	oClone:cCPRODUTO     := ::cCPRODUTO
	oClone:cCLOTE        := ::cCLOTE
	oClone:cCEMP         := ::cCEMP
	oClone:cCFIL         := ::cCFIL
	oClone:lGETLOTERESULT := ::lGETLOTERESULT
Return oClone

// WSDL Method GETLOTE of Service WSLOJGERDADDR

WSMETHOD GETLOTE WSSEND cCPRODUTO,cCLOTE,cCEMP,cCFIL WSRECEIVE lGETLOTERESULT WSCLIENT WSLOJGERDADDR
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETLOTE xmlns="http://169.254.161.140:88/">'
cSoap += WSSoapValue("CPRODUTO", ::cCPRODUTO, cCPRODUTO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CLOTE", ::cCLOTE, cCLOTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMP", ::cCEMP, cCEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETLOTE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://169.254.161.140:88/GETLOTE",; 
	"DOCUMENT","http://169.254.161.140:88/",,"1.031217",; 
	"http://169.254.161.140:88/LOJGERDADDR.apw")

::Init()
::lGETLOTERESULT     :=  WSAdvValue( oXmlRet,"_GETLOTERESPONSE:_GETLOTERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



