#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.195.4.139:8089/TSSWSSUNAT.apw?WSDL
Generado en        10/23/18 16:41:11
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _PLKTLEX ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTSSWSSUNAT
------------------------------------------------------------------------------- */

WSCLIENT WSTSSWSSUNAT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CERTPFX
	WSMETHOD CONSULTADOC
	WSMETHOD SENDDOC

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSERTOKEN                AS string
	WSDATA   cIDENT                    AS string
	WSDATA   cCERTIFICATE              AS base64Binary
	WSDATA   cPASSWORD                 AS base64Binary
	WSDATA   cCERTPFXRESULT            AS string
	WSDATA   cIDDOC                    AS string
	WSDATA   cMODELO                   AS string
	WSDATA   oWSCONSULTADOCRESULT      AS TSSWSSUNAT_CONSULTARESULT
	WSDATA   cXML                      AS base64Binary
	WSDATA   oWSSENDDOCRESULT          AS TSSWSSUNAT_SENDDOCRESULT

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTSSWSSUNAT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170626] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTSSWSSUNAT
	::oWSCONSULTADOCRESULT := TSSWSSUNAT_CONSULTARESULT():New()
	::oWSSENDDOCRESULT   := TSSWSSUNAT_SENDDOCRESULT():New()
Return

WSMETHOD RESET WSCLIENT WSTSSWSSUNAT
	::cUSERTOKEN         := NIL 
	::cIDENT             := NIL 
	::cCERTIFICATE       := NIL 
	::cPASSWORD          := NIL 
	::cCERTPFXRESULT     := NIL 
	::cIDDOC             := NIL 
	::cMODELO            := NIL 
	::oWSCONSULTADOCRESULT := NIL 
	::cXML               := NIL 
	::oWSSENDDOCRESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTSSWSSUNAT
Local oClone := WSTSSWSSUNAT():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERTOKEN    := ::cUSERTOKEN
	oClone:cIDENT        := ::cIDENT
	oClone:cCERTIFICATE  := ::cCERTIFICATE
	oClone:cPASSWORD     := ::cPASSWORD
	oClone:cCERTPFXRESULT := ::cCERTPFXRESULT
	oClone:cIDDOC        := ::cIDDOC
	oClone:cMODELO       := ::cMODELO
	oClone:oWSCONSULTADOCRESULT :=  IIF(::oWSCONSULTADOCRESULT = NIL , NIL ,::oWSCONSULTADOCRESULT:Clone() )
	oClone:cXML          := ::cXML
	oClone:oWSSENDDOCRESULT :=  IIF(::oWSSENDDOCRESULT = NIL , NIL ,::oWSSENDDOCRESULT:Clone() )
Return oClone

// WSDL Method CERTPFX of Service WSTSSWSSUNAT

WSMETHOD CERTPFX WSSEND cUSERTOKEN,cIDENT,cCERTIFICATE,cPASSWORD WSRECEIVE cCERTPFXRESULT WSCLIENT WSTSSWSSUNAT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CERTPFX xmlns="http://webservices.totvs.com.br">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CERTIFICATE", ::cCERTIFICATE, cCERTIFICATE , "base64Binary", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PASSWORD", ::cPASSWORD, cPASSWORD , "base64Binary", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CERTPFX>"

oXmlRet := SvcSoapCall( ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/CERTPFX",; 
	"DOCUMENT","http://webservices.totvs.com.br",,"1.031217",; 
	"http://10.195.4.139:8089/TSSWSSUNAT.apw")

::Init()
::cCERTPFXRESULT     :=  WSAdvValue( oXmlRet,"_CERTPFXRESPONSE:_CERTPFXRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSULTADOC of Service WSTSSWSSUNAT

WSMETHOD CONSULTADOC WSSEND cUSERTOKEN,cIDENT,cIDDOC,cMODELO WSRECEIVE oWSCONSULTADOCRESULT WSCLIENT WSTSSWSSUNAT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSULTADOC xmlns="http://webservices.totvs.com.br">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDDOC", ::cIDDOC, cIDDOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MODELO", ::cMODELO, cMODELO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONSULTADOC>"

oXmlRet := SvcSoapCall( ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/CONSULTADOC",; 
	"DOCUMENT","http://webservices.totvs.com.br",,"1.031217",; 
	"http://10.195.4.139:8089/TSSWSSUNAT.apw")

::Init()
::oWSCONSULTADOCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTADOCRESPONSE:_CONSULTADOCRESULT","CONSULTARESULT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SENDDOC of Service WSTSSWSSUNAT

WSMETHOD SENDDOC WSSEND cUSERTOKEN,cIDENT,cIDDOC,cMODELO,cXML WSRECEIVE oWSSENDDOCRESULT WSCLIENT WSTSSWSSUNAT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SENDDOC xmlns="http://webservices.totvs.com.br">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDENT", ::cIDENT, cIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IDDOC", ::cIDDOC, cIDDOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MODELO", ::cMODELO, cMODELO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("XML", ::cXML, cXML , "base64Binary", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SENDDOC>"

oXmlRet := SvcSoapCall( ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/SENDDOC",; 
	"DOCUMENT","http://webservices.totvs.com.br",,"1.031217",; 
	"http://10.195.4.139:8089/TSSWSSUNAT.apw")

::Init()
::oWSSENDDOCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SENDDOCRESPONSE:_SENDDOCRESULT","SENDDOCRESULT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure CONSULTARESULT

WSSTRUCT TSSWSSUNAT_CONSULTARESULT
	WSDATA   nAMBIENTE                 AS integer
	WSDATA   cCODIGO                   AS string
	WSDATA   dFECHAAUT                 AS date
	WSDATA   cHORAAUT                  AS string
	WSDATA   cIDDOC                    AS string
	WSDATA   cMENSAJE                  AS string
	WSDATA   cRECOMEND                 AS string
	WSDATA   nSTATUS                   AS integer
	WSDATA   cXML                      AS base64Binary
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSUNAT_CONSULTARESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSUNAT_CONSULTARESULT
Return

WSMETHOD CLONE WSCLIENT TSSWSSUNAT_CONSULTARESULT
	Local oClone := TSSWSSUNAT_CONSULTARESULT():NEW()
	oClone:nAMBIENTE            := ::nAMBIENTE
	oClone:cCODIGO              := ::cCODIGO
	oClone:dFECHAAUT            := ::dFECHAAUT
	oClone:cHORAAUT             := ::cHORAAUT
	oClone:cIDDOC               := ::cIDDOC
	oClone:cMENSAJE             := ::cMENSAJE
	oClone:cRECOMEND            := ::cRECOMEND
	oClone:nSTATUS              := ::nSTATUS
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSUNAT_CONSULTARESULT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","integer",NIL,"Property nAMBIENTE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dFECHAAUT          :=  WSAdvValue( oResponse,"_FECHAAUT","date",NIL,"Property dFECHAAUT as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cHORAAUT           :=  WSAdvValue( oResponse,"_HORAAUT","string",NIL,"Property cHORAAUT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cIDDOC             :=  WSAdvValue( oResponse,"_IDDOC","string",NIL,"Property cIDDOC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMENSAJE           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,"Property cMENSAJE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRECOMEND          :=  WSAdvValue( oResponse,"_RECOMEND","string",NIL,"Property cRECOMEND as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSTATUS            :=  WSAdvValue( oResponse,"_STATUS","integer",NIL,"Property nSTATUS as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","base64Binary",NIL,"Property cXML as s:base64Binary on SOAP Response not found.",NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure SENDDOCRESULT

WSSTRUCT TSSWSSUNAT_SENDDOCRESULT
	WSDATA   oWSERROR                  AS TSSWSSUNAT_ERRORPER
	WSDATA   lHASERROR                 AS boolean
	WSDATA   cIDDOC                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSUNAT_SENDDOCRESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSUNAT_SENDDOCRESULT
Return

WSMETHOD CLONE WSCLIENT TSSWSSUNAT_SENDDOCRESULT
	Local oClone := TSSWSSUNAT_SENDDOCRESULT():NEW()
	oClone:oWSERROR             := IIF(::oWSERROR = NIL , NIL , ::oWSERROR:Clone() )
	oClone:lHASERROR            := ::lHASERROR
	oClone:cIDDOC               := ::cIDDOC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSUNAT_SENDDOCRESULT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ERROR","ERRORPER",NIL,"Property oWSERROR as s0:ERRORPER on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSERROR := TSSWSSUNAT_ERRORPER():New()
		::oWSERROR:SoapRecv(oNode1)
	EndIf
	::lHASERROR          :=  WSAdvValue( oResponse,"_HASERROR","boolean",NIL,"Property lHASERROR as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cIDDOC             :=  WSAdvValue( oResponse,"_IDDOC","string",NIL,"Property cIDDOC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ERRORPER

WSSTRUCT TSSWSSUNAT_ERRORPER
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRIP                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSSUNAT_ERRORPER
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSSUNAT_ERRORPER
Return

WSMETHOD CLONE WSCLIENT TSSWSSUNAT_ERRORPER
	Local oClone := TSSWSSUNAT_ERRORPER():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRIP             := ::cDESCRIP
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSSUNAT_ERRORPER
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRIP           :=  WSAdvValue( oResponse,"_DESCRIP","string",NIL,"Property cDESCRIP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


