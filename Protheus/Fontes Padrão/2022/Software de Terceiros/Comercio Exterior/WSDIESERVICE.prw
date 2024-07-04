#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://MV_SPEDURL/DIESERVICE.apw?WSDL 
Gerado em        05/21/12 15:57:57
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JAJKNGQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSDIESERVICE
------------------------------------------------------------------------------- */

WSCLIENT WSDIESERVICE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD DIEASSINATURA
	WSMETHOD DIECFGVERSAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSERTOKEN                AS string
	WSDATA   cID_ENT                   AS string
	WSDATA   cXML                      AS base64Binary
	WSDATA   nTPDOCUMENTO              AS integer
	WSDATA   oWSDIEASSINATURARESULT    AS DIESERVICE_RESPASS
	WSDATA   cVERSAO                   AS string
	WSDATA   oWSDIECFGVERSAORESULT     AS DIESERVICE_RESPCFG

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSDIESERVICE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110919] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSDIESERVICE
	::oWSDIEASSINATURARESULT := DIESERVICE_RESPASS():New()
	::oWSDIECFGVERSAORESULT := DIESERVICE_RESPCFG():New()
Return

WSMETHOD RESET WSCLIENT WSDIESERVICE
	::cUSERTOKEN         := NIL 
	::cID_ENT            := NIL 
	::cXML               := NIL 
	::nTPDOCUMENTO       := NIL 
	::oWSDIEASSINATURARESULT := NIL 
	::cVERSAO            := NIL 
	::oWSDIECFGVERSAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSDIESERVICE
Local oClone := WSDIESERVICE():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERTOKEN    := ::cUSERTOKEN
	oClone:cID_ENT       := ::cID_ENT
	oClone:cXML          := ::cXML
	oClone:nTPDOCUMENTO  := ::nTPDOCUMENTO
	oClone:oWSDIEASSINATURARESULT :=  IIF(::oWSDIEASSINATURARESULT = NIL , NIL ,::oWSDIEASSINATURARESULT:Clone() )
	oClone:cVERSAO       := ::cVERSAO
	oClone:oWSDIECFGVERSAORESULT :=  IIF(::oWSDIECFGVERSAORESULT = NIL , NIL ,::oWSDIECFGVERSAORESULT:Clone() )
Return oClone

// WSDL Method DIEASSINATURA of Service WSDIESERVICE

WSMETHOD DIEASSINATURA WSSEND cUSERTOKEN,cID_ENT,cXML,nTPDOCUMENTO WSRECEIVE oWSDIEASSINATURARESULT WSCLIENT WSDIESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DIEASSINATURA xmlns="http://webservices.totvs.com.br/declieletr.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("XML", ::cXML, cXML , "base64Binary", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TPDOCUMENTO", ::nTPDOCUMENTO, nTPDOCUMENTO , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += "</DIEASSINATURA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.totvs.com.br/declieletr.apw/DIEASSINATURA",; 
	"DOCUMENT","http://webservices.totvs.com.br/declieletr.apw",,"1.031217",; 
    AllTrim(EasyGParam("MV_SPEDURL",,"")) +"/DIESERVICE.apw")

::Init()
::oWSDIEASSINATURARESULT:SoapRecv( WSAdvValue( oXmlRet,"_DIEASSINATURARESPONSE:_DIEASSINATURARESULT","RESPASS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DIECFGVERSAO of Service WSDIESERVICE

WSMETHOD DIECFGVERSAO WSSEND cUSERTOKEN,cID_ENT,cVERSAO,nTPDOCUMENTO WSRECEIVE oWSDIECFGVERSAORESULT WSCLIENT WSDIESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DIECFGVERSAO xmlns="http://webservices.totvs.com.br/declieletr.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("VERSAO", ::cVERSAO, cVERSAO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TPDOCUMENTO", ::nTPDOCUMENTO, nTPDOCUMENTO , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += "</DIECFGVERSAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.totvs.com.br/declieletr.apw/DIECFGVERSAO",; 
	"DOCUMENT","http://webservices.totvs.com.br/declieletr.apw",,"1.031217",; 
	AllTrim(EasyGParam("MV_SPEDURL",,""))+"/DIESERVICE.apw")

::Init()
::oWSDIECFGVERSAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_DIECFGVERSAORESPONSE:_DIECFGVERSAORESULT","RESPCFG",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure RESPASS

WSSTRUCT DIESERVICE_RESPASS
	WSDATA   nCODVLDSCHEMA             AS integer
	WSDATA   cMSGVLDSCHEMA             AS string
	WSDATA   cXMLSIG                   AS base64Binary
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT DIESERVICE_RESPASS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT DIESERVICE_RESPASS
Return

WSMETHOD CLONE WSCLIENT DIESERVICE_RESPASS
	Local oClone := DIESERVICE_RESPASS():NEW()
	oClone:nCODVLDSCHEMA        := ::nCODVLDSCHEMA
	oClone:cMSGVLDSCHEMA        := ::cMSGVLDSCHEMA
	oClone:cXMLSIG              := ::cXMLSIG
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT DIESERVICE_RESPASS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCODVLDSCHEMA      :=  WSAdvValue( oResponse,"_CODVLDSCHEMA","integer",NIL,"Property nCODVLDSCHEMA as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMSGVLDSCHEMA      :=  WSAdvValue( oResponse,"_MSGVLDSCHEMA","string",NIL,"Property cMSGVLDSCHEMA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXMLSIG            :=  WSAdvValue( oResponse,"_XMLSIG","base64Binary",NIL,"Property cXMLSIG as s:base64Binary on SOAP Response not found.",NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure RESPCFG

WSSTRUCT DIESERVICE_RESPCFG
	WSDATA   nTPDOCUMENTO              AS integer
	WSDATA   cVERCONFIG                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT DIESERVICE_RESPCFG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT DIESERVICE_RESPCFG
Return

WSMETHOD CLONE WSCLIENT DIESERVICE_RESPCFG
	Local oClone := DIESERVICE_RESPCFG():NEW()
	oClone:nTPDOCUMENTO         := ::nTPDOCUMENTO
	oClone:cVERCONFIG           := ::cVERCONFIG
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT DIESERVICE_RESPCFG
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTPDOCUMENTO       :=  WSAdvValue( oResponse,"_TPDOCUMENTO","integer",NIL,"Property nTPDOCUMENTO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cVERCONFIG         :=  WSAdvValue( oResponse,"_VERCONFIG","string",NIL,"Property cVERCONFIG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


