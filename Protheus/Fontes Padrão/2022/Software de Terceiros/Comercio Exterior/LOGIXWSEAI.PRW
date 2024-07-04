#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://187.94.60.10:8080/EAISERVICE.apw?WSDL
Gerado em        01/18/12 21:14:33
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OZYGWTT ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service LOGIXWSEAI
------------------------------------------------------------------------------- */

WSCLIENT LOGIXWSEAI

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETMESSAGE
	WSMETHOD GETSTATUS
	WSMETHOD RECEIVEMESSAGE
	WSMETHOD SENDMESSAGE
	WSMETHOD RECEIVEMESSAGERESPONSE
	WSMETHOD SENDMESSAGERESPONSE

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cGETMESSAGERESULT         AS base64Binary
	WSDATA   cGETSTATUSRESULT          AS string
	WSDATA   cINMSG                    AS string
	WSDATA   cRECEIVEMESSAGERESULT     AS string
	WSDATA   cXML                      AS base64Binary
	WSDATA   cSENDMESSAGERESULT        AS base64Binary

ENDWSCLIENT

WSMETHOD NEW WSCLIENT LOGIXWSEAI
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110919] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT LOGIXWSEAI
Return

WSMETHOD RESET WSCLIENT LOGIXWSEAI
	::cGETMESSAGERESULT  := NIL 
	::cGETSTATUSRESULT   := NIL 
	::cINMSG             := NIL 
	::cRECEIVEMESSAGERESULT := NIL 
	::cXML               := NIL 
	::cSENDMESSAGERESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT LOGIXWSEAI
Local oClone := LOGIXWSEAI():New()
	oClone:_URL          := ::_URL 
	oClone:cGETMESSAGERESULT := ::cGETMESSAGERESULT
	oClone:cGETSTATUSRESULT := ::cGETSTATUSRESULT
	oClone:cINMSG        := ::cINMSG
	oClone:cRECEIVEMESSAGERESULT := ::cRECEIVEMESSAGERESULT
	oClone:cXML          := ::cXML
	oClone:cSENDMESSAGERESULT := ::cSENDMESSAGERESULT
Return oClone

// WSDL Method GETMESSAGE of Service LOGIXWSEAI

WSMETHOD GETMESSAGE WSSEND NULLPARAM WSRECEIVE cGETMESSAGERESULT WSCLIENT LOGIXWSEAI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETMESSAGE xmlns="http://webservices.microsiga.com.br/fweai.apw">'
cSoap += "</GETMESSAGE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/fweai.apw/GETMESSAGE",; 
	"DOCUMENT","http://webservices.microsiga.com.br/fweai.apw",,"1.031217",; 
	"http://187.94.60.10:8080/EAISERVICE.apw")

::Init()
::cGETMESSAGERESULT  :=  WSAdvValue( oXmlRet,"_GETMESSAGERESPONSE:_GETMESSAGERESULT:TEXT","base64Binary",NIL,NIL,NIL,NIL,NIL,NIL) 
ConOutXML(Self)
END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETSTATUS of Service LOGIXWSEAI

WSMETHOD GETSTATUS WSSEND NULLPARAM WSRECEIVE cGETSTATUSRESULT WSCLIENT LOGIXWSEAI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSTATUS xmlns="http://webservices.microsiga.com.br/fweai.apw">'
cSoap += "</GETSTATUS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/fweai.apw/GETSTATUS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/fweai.apw",,"1.031217",; 
	"http://187.94.60.10:8080/EAISERVICE.apw")

::Init()
::cGETSTATUSRESULT   :=  WSAdvValue( oXmlRet,"_GETSTATUSRESPONSE:_GETSTATUSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD
ConOutXML(Self)
oXmlRet := NIL
Return .T.

// WSDL Method RECEIVEMESSAGE of Service LOGIXWSEAI

WSMETHOD RECEIVEMESSAGE WSSEND cINMSG WSRECEIVE cRECEIVEMESSAGERESULT WSCLIENT LOGIXWSEAI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RECEIVEMESSAGE xmlns="http://webservices.microsiga.com.br/fweai.apw">'
cSoap += WSSoapValue("INMSG", ::cINMSG, cINMSG , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</RECEIVEMESSAGE>"
ConOut("RECEIVEMESSAGE:"+cSoap)
oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/fweai.apw/RECEIVEMESSAGE",; 
	"DOCUMENT","http://webservices.microsiga.com.br/fweai.apw",,"1.031217",; 
	"http://187.94.60.10:8080/EAISERVICE.apw")

::Init()
::cRECEIVEMESSAGERESULT :=  WSAdvValue( oXmlRet,"_RECEIVEMESSAGERESPONSE:_RECEIVEMESSAGERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD
//cXMLRet := ::cRECEIVEMESSAGERESULT
ConOutXML(Self)
oXmlRet := NIL
Return .T.

// WSDL Method SENDMESSAGE of Service LOGIXWSEAI

WSMETHOD SENDMESSAGE WSSEND cXML WSRECEIVE cSENDMESSAGERESULT WSCLIENT LOGIXWSEAI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SENDMESSAGE xmlns="http://webservices.microsiga.com.br/fweai.apw">'
cSoap += WSSoapValue("XML", ::cXML, cXML , "base64Binary", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SENDMESSAGE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/fweai.apw/SENDMESSAGE",; 
	"DOCUMENT","http://webservices.microsiga.com.br/fweai.apw",,"1.031217",; 
	"http://187.94.60.10:8080/EAISERVICE.apw")

::Init()
::cSENDMESSAGERESULT :=  WSAdvValue( oXmlRet,"_SENDMESSAGERESPONSE:_SENDMESSAGERESULT:TEXT","base64Binary",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD
ConOutXML(Self)
oXmlRet := NIL
Return .T.

Static Function ConOutXML(oObj)

VarInfo("oObj:cGETMESSAGERESULT",oObj:cGETMESSAGERESULT) 
VarInfo("oObj:cGETSTATUSRESULT",OObj:cGETSTATUSRESULT) 
VarInfo("oObj:cINMSG",OObj:cINMSG            ) 
VarInfo("oObj:cRECEIVEMESSAGERESULT",OObj:cRECEIVEMESSAGERESULT) 
VarInfo("oObj:cXML",OObj:cXML               ) 
VarInfo("oObj:cSENDMESSAGERESULT",OObj:cSENDMESSAGERESULT) 
cEasyIntEaiRet := cValToChar(OObj:cRECEIVEMESSAGERESULT) + cValToChar(OObj:cSENDMESSAGERESULT)

Return nil	