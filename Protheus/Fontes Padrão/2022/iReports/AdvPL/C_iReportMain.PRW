#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://127.0.0.1:8088/ws/IREPORT.apw?WSDL
Gerado em        06/18/12 13:27:07
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _ULKNUIW ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSIREPORT
------------------------------------------------------------------------------- */

WSCLIENT WSIREPORT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETPARAMETERS
	WSMETHOD GETREPORT
	WSMETHOD GETSYSTEMFIELDS
	WSMETHOD GETSYSTEMTABLES
	WSMETHOD GETTABLESRELATION
	WSMETHOD GETTABLESX2NAME
	WSMETHOD GETVERSION
	WSMETHOD MAKEINTERNATIONALIZATION

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cSESSIONID                AS string
	WSDATA   cEMPRESA                  AS string
	WSDATA   cFILIAL                   AS string
	WSDATA   cREPORTNAME               AS string
	WSDATA   oWSGETPARAMETERSRESULT    AS IREPORT_ARRAYOFLSTPARAMETERS
	WSDATA   cGETREPORTRESULT          AS string
	WSDATA   cTABLEALIAS               AS string
	WSDATA   oWSGETSYSTEMFIELDSRESULT  AS IREPORT_ARRAYOFSYSFIELDSSTRU
	WSDATA   oWSGETSYSTEMTABLESRESULT  AS IREPORT_ARRAYOFSYSTABLESSTRU
	WSDATA   cLISTTABLES               AS string
	WSDATA   oWSGETTABLESRELATIONRESULT AS IREPORT_ARRAYOFLSTRELATIONS
	WSDATA   oWSGETTABLESX2NAMERESULT  AS IREPORT_ARRAYOFSYSTABLESSTRU
	WSDATA   cGETVERSIONRESULT         AS string
	WSDATA   oWSMAKEINTERNATIONALIZATIONRESULT AS IREPORT_INTERSTRU

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSIREPORT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120314] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSIREPORT
	::oWSGETPARAMETERSRESULT := IREPORT_ARRAYOFLSTPARAMETERS():New()
	::oWSGETSYSTEMFIELDSRESULT := IREPORT_ARRAYOFSYSFIELDSSTRU():New()
	::oWSGETSYSTEMTABLESRESULT := IREPORT_ARRAYOFSYSTABLESSTRU():New()
	::oWSGETTABLESRELATIONRESULT := IREPORT_ARRAYOFLSTRELATIONS():New()
	::oWSGETTABLESX2NAMERESULT := IREPORT_ARRAYOFSYSTABLESSTRU():New()
	::oWSMAKEINTERNATIONALIZATIONRESULT := IREPORT_INTERSTRU():New()
Return

WSMETHOD RESET WSCLIENT WSIREPORT
	::cSESSIONID         := NIL 
	::cEMPRESA           := NIL 
	::cFILIAL            := NIL 
	::cREPORTNAME        := NIL 
	::oWSGETPARAMETERSRESULT := NIL 
	::cGETREPORTRESULT   := NIL 
	::cTABLEALIAS        := NIL 
	::oWSGETSYSTEMFIELDSRESULT := NIL 
	::oWSGETSYSTEMTABLESRESULT := NIL 
	::cLISTTABLES        := NIL 
	::oWSGETTABLESRELATIONRESULT := NIL 
	::oWSGETTABLESX2NAMERESULT := NIL 
	::cGETVERSIONRESULT  := NIL 
	::oWSMAKEINTERNATIONALIZATIONRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSIREPORT
Local oClone := WSIREPORT():New()
	oClone:_URL          := ::_URL 
	oClone:cSESSIONID    := ::cSESSIONID
	oClone:cEMPRESA      := ::cEMPRESA
	oClone:cFILIAL       := ::cFILIAL
	oClone:cREPORTNAME   := ::cREPORTNAME
	oClone:oWSGETPARAMETERSRESULT :=  IIF(::oWSGETPARAMETERSRESULT = NIL , NIL ,::oWSGETPARAMETERSRESULT:Clone() )
	oClone:cGETREPORTRESULT := ::cGETREPORTRESULT
	oClone:cTABLEALIAS   := ::cTABLEALIAS
	oClone:oWSGETSYSTEMFIELDSRESULT :=  IIF(::oWSGETSYSTEMFIELDSRESULT = NIL , NIL ,::oWSGETSYSTEMFIELDSRESULT:Clone() )
	oClone:oWSGETSYSTEMTABLESRESULT :=  IIF(::oWSGETSYSTEMTABLESRESULT = NIL , NIL ,::oWSGETSYSTEMTABLESRESULT:Clone() )
	oClone:cLISTTABLES   := ::cLISTTABLES
	oClone:oWSGETTABLESRELATIONRESULT :=  IIF(::oWSGETTABLESRELATIONRESULT = NIL , NIL ,::oWSGETTABLESRELATIONRESULT:Clone() )
	oClone:oWSGETTABLESX2NAMERESULT :=  IIF(::oWSGETTABLESX2NAMERESULT = NIL , NIL ,::oWSGETTABLESX2NAMERESULT:Clone() )
	oClone:cGETVERSIONRESULT := ::cGETVERSIONRESULT
	oClone:oWSMAKEINTERNATIONALIZATIONRESULT :=  IIF(::oWSMAKEINTERNATIONALIZATIONRESULT = NIL , NIL ,::oWSMAKEINTERNATIONALIZATIONRESULT:Clone() )
Return oClone

// WSDL Method GETPARAMETERS of Service WSIREPORT

WSMETHOD GETPARAMETERS WSSEND cSESSIONID,cEMPRESA,cFILIAL,cREPORTNAME WSRECEIVE oWSGETPARAMETERSRESULT WSCLIENT WSIREPORT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPARAMETERS xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REPORTNAME", ::cREPORTNAME, cREPORTNAME , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETPARAMETERS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETPARAMETERS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://127.0.0.1:8088/ws/IREPORT.apw")

::Init()
::oWSGETPARAMETERSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPARAMETERSRESPONSE:_GETPARAMETERSRESULT","ARRAYOFLSTPARAMETERS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETREPORT of Service WSIREPORT

WSMETHOD GETREPORT WSSEND cSESSIONID,cREPORTNAME WSRECEIVE cGETREPORTRESULT WSCLIENT WSIREPORT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETREPORT xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REPORTNAME", ::cREPORTNAME, cREPORTNAME , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETREPORT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETREPORT",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://127.0.0.1:8088/ws/IREPORT.apw")

::Init()
::cGETREPORTRESULT   :=  WSAdvValue( oXmlRet,"_GETREPORTRESPONSE:_GETREPORTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETSYSTEMFIELDS of Service WSIREPORT

WSMETHOD GETSYSTEMFIELDS WSSEND cSESSIONID,cTABLEALIAS,cEMPRESA,cFILIAL WSRECEIVE oWSGETSYSTEMFIELDSRESULT WSCLIENT WSIREPORT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSYSTEMFIELDS xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TABLEALIAS", ::cTABLEALIAS, cTABLEALIAS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETSYSTEMFIELDS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETSYSTEMFIELDS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://127.0.0.1:8088/ws/IREPORT.apw")

::Init()
::oWSGETSYSTEMFIELDSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETSYSTEMFIELDSRESPONSE:_GETSYSTEMFIELDSRESULT","ARRAYOFSYSFIELDSSTRU",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETSYSTEMTABLES of Service WSIREPORT

WSMETHOD GETSYSTEMTABLES WSSEND cSESSIONID,cEMPRESA,cFILIAL WSRECEIVE oWSGETSYSTEMTABLESRESULT WSCLIENT WSIREPORT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSYSTEMTABLES xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETSYSTEMTABLES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETSYSTEMTABLES",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://127.0.0.1:8088/ws/IREPORT.apw")

::Init()
::oWSGETSYSTEMTABLESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETSYSTEMTABLESRESPONSE:_GETSYSTEMTABLESRESULT","ARRAYOFSYSTABLESSTRU",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETTABLESRELATION of Service WSIREPORT

WSMETHOD GETTABLESRELATION WSSEND cSESSIONID,cLISTTABLES,cEMPRESA,cFILIAL WSRECEIVE oWSGETTABLESRELATIONRESULT WSCLIENT WSIREPORT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETTABLESRELATION xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LISTTABLES", ::cLISTTABLES, cLISTTABLES , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETTABLESRELATION>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETTABLESRELATION",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://127.0.0.1:8088/ws/IREPORT.apw")

::Init()
::oWSGETTABLESRELATIONRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETTABLESRELATIONRESPONSE:_GETTABLESRELATIONRESULT","ARRAYOFLSTRELATIONS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETTABLESX2NAME of Service WSIREPORT

WSMETHOD GETTABLESX2NAME WSSEND cSESSIONID,cEMPRESA,cFILIAL,cLISTTABLES WSRECEIVE oWSGETTABLESX2NAMERESULT WSCLIENT WSIREPORT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETTABLESX2NAME xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LISTTABLES", ::cLISTTABLES, cLISTTABLES , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETTABLESX2NAME>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETTABLESX2NAME",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://127.0.0.1:8088/ws/IREPORT.apw")

::Init()
::oWSGETTABLESX2NAMERESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETTABLESX2NAMERESPONSE:_GETTABLESX2NAMERESULT","ARRAYOFSYSTABLESSTRU",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETVERSION of Service WSIREPORT

WSMETHOD GETVERSION WSSEND cSESSIONID WSRECEIVE cGETVERSIONRESULT WSCLIENT WSIREPORT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETVERSION xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETVERSION>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETVERSION",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://127.0.0.1:8088/ws/IREPORT.apw")

::Init()
::cGETVERSIONRESULT  :=  WSAdvValue( oXmlRet,"_GETVERSIONRESPONSE:_GETVERSIONRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MAKEINTERNATIONALIZATION of Service WSIREPORT

WSMETHOD MAKEINTERNATIONALIZATION WSSEND cSESSIONID WSRECEIVE oWSMAKEINTERNATIONALIZATIONRESULT WSCLIENT WSIREPORT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MAKEINTERNATIONALIZATION xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MAKEINTERNATIONALIZATION>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/MAKEINTERNATIONALIZATION",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://127.0.0.1:8088/ws/IREPORT.apw")

::Init()
::oWSMAKEINTERNATIONALIZATIONRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MAKEINTERNATIONALIZATIONRESPONSE:_MAKEINTERNATIONALIZATIONRESULT","INTERSTRU",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFLSTPARAMETERS

WSSTRUCT IREPORT_ARRAYOFLSTPARAMETERS
	WSDATA   oWSLSTPARAMETERS          AS IREPORT_LSTPARAMETERS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_ARRAYOFLSTPARAMETERS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_ARRAYOFLSTPARAMETERS
	::oWSLSTPARAMETERS     := {} // Array Of  IREPORT_LSTPARAMETERS():New()
Return

WSMETHOD CLONE WSCLIENT IREPORT_ARRAYOFLSTPARAMETERS
	Local oClone := IREPORT_ARRAYOFLSTPARAMETERS():NEW()
	oClone:oWSLSTPARAMETERS := NIL
	If ::oWSLSTPARAMETERS <> NIL 
		oClone:oWSLSTPARAMETERS := {}
		aEval( ::oWSLSTPARAMETERS , { |x| aadd( oClone:oWSLSTPARAMETERS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_ARRAYOFLSTPARAMETERS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LSTPARAMETERS","LSTPARAMETERS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLSTPARAMETERS , IREPORT_LSTPARAMETERS():New() )
			::oWSLSTPARAMETERS[len(::oWSLSTPARAMETERS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSYSFIELDSSTRU

WSSTRUCT IREPORT_ARRAYOFSYSFIELDSSTRU
	WSDATA   oWSSYSFIELDSSTRU          AS IREPORT_SYSFIELDSSTRU OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_ARRAYOFSYSFIELDSSTRU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_ARRAYOFSYSFIELDSSTRU
	::oWSSYSFIELDSSTRU     := {} // Array Of  IREPORT_SYSFIELDSSTRU():New()
Return

WSMETHOD CLONE WSCLIENT IREPORT_ARRAYOFSYSFIELDSSTRU
	Local oClone := IREPORT_ARRAYOFSYSFIELDSSTRU():NEW()
	oClone:oWSSYSFIELDSSTRU := NIL
	If ::oWSSYSFIELDSSTRU <> NIL 
		oClone:oWSSYSFIELDSSTRU := {}
		aEval( ::oWSSYSFIELDSSTRU , { |x| aadd( oClone:oWSSYSFIELDSSTRU , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_ARRAYOFSYSFIELDSSTRU
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SYSFIELDSSTRU","SYSFIELDSSTRU",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSYSFIELDSSTRU , IREPORT_SYSFIELDSSTRU():New() )
			::oWSSYSFIELDSSTRU[len(::oWSSYSFIELDSSTRU)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSYSTABLESSTRU

WSSTRUCT IREPORT_ARRAYOFSYSTABLESSTRU
	WSDATA   oWSSYSTABLESSTRU          AS IREPORT_SYSTABLESSTRU OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_ARRAYOFSYSTABLESSTRU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_ARRAYOFSYSTABLESSTRU
	::oWSSYSTABLESSTRU     := {} // Array Of  IREPORT_SYSTABLESSTRU():New()
Return

WSMETHOD CLONE WSCLIENT IREPORT_ARRAYOFSYSTABLESSTRU
	Local oClone := IREPORT_ARRAYOFSYSTABLESSTRU():NEW()
	oClone:oWSSYSTABLESSTRU := NIL
	If ::oWSSYSTABLESSTRU <> NIL 
		oClone:oWSSYSTABLESSTRU := {}
		aEval( ::oWSSYSTABLESSTRU , { |x| aadd( oClone:oWSSYSTABLESSTRU , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_ARRAYOFSYSTABLESSTRU
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SYSTABLESSTRU","SYSTABLESSTRU",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSYSTABLESSTRU , IREPORT_SYSTABLESSTRU():New() )
			::oWSSYSTABLESSTRU[len(::oWSSYSTABLESSTRU)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFLSTRELATIONS

WSSTRUCT IREPORT_ARRAYOFLSTRELATIONS
	WSDATA   oWSLSTRELATIONS           AS IREPORT_LSTRELATIONS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_ARRAYOFLSTRELATIONS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_ARRAYOFLSTRELATIONS
	::oWSLSTRELATIONS      := {} // Array Of  IREPORT_LSTRELATIONS():New()
Return

WSMETHOD CLONE WSCLIENT IREPORT_ARRAYOFLSTRELATIONS
	Local oClone := IREPORT_ARRAYOFLSTRELATIONS():NEW()
	oClone:oWSLSTRELATIONS := NIL
	If ::oWSLSTRELATIONS <> NIL 
		oClone:oWSLSTRELATIONS := {}
		aEval( ::oWSLSTRELATIONS , { |x| aadd( oClone:oWSLSTRELATIONS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_ARRAYOFLSTRELATIONS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LSTRELATIONS","LSTRELATIONS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLSTRELATIONS , IREPORT_LSTRELATIONS():New() )
			::oWSLSTRELATIONS[len(::oWSLSTRELATIONS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure INTERSTRU

WSSTRUCT IREPORT_INTERSTRU
	WSDATA   cFILENAME                 AS string
	WSDATA   cLANGUAGE                 AS string
	WSDATA   cTEXT                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_INTERSTRU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_INTERSTRU
Return

WSMETHOD CLONE WSCLIENT IREPORT_INTERSTRU
	Local oClone := IREPORT_INTERSTRU():NEW()
	oClone:cFILENAME            := ::cFILENAME
	oClone:cLANGUAGE            := ::cLANGUAGE
	oClone:cTEXT                := ::cTEXT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_INTERSTRU
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFILENAME          :=  WSAdvValue( oResponse,"_FILENAME","string",NIL,"Property cFILENAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cLANGUAGE          :=  WSAdvValue( oResponse,"_LANGUAGE","string",NIL,"Property cLANGUAGE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTEXT              :=  WSAdvValue( oResponse,"_TEXT","string",NIL,"Property cTEXT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure LSTPARAMETERS

WSSTRUCT IREPORT_LSTPARAMETERS
	WSDATA   cPARNAME                  AS string
	WSDATA   cPARORDER                 AS string
	WSDATA   cPARVALUE                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_LSTPARAMETERS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_LSTPARAMETERS
Return

WSMETHOD CLONE WSCLIENT IREPORT_LSTPARAMETERS
	Local oClone := IREPORT_LSTPARAMETERS():NEW()
	oClone:cPARNAME             := ::cPARNAME
	oClone:cPARORDER            := ::cPARORDER
	oClone:cPARVALUE            := ::cPARVALUE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_LSTPARAMETERS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cPARNAME           :=  WSAdvValue( oResponse,"_PARNAME","string",NIL,"Property cPARNAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPARORDER          :=  WSAdvValue( oResponse,"_PARORDER","string",NIL,"Property cPARORDER as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPARVALUE          :=  WSAdvValue( oResponse,"_PARVALUE","string",NIL,"Property cPARVALUE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SYSFIELDSSTRU

WSSTRUCT IREPORT_SYSFIELDSSTRU
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cNAME                     AS string
	WSDATA   cTYPE                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_SYSFIELDSSTRU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_SYSFIELDSSTRU
Return

WSMETHOD CLONE WSCLIENT IREPORT_SYSFIELDSSTRU
	Local oClone := IREPORT_SYSFIELDSSTRU():NEW()
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cNAME                := ::cNAME
	oClone:cTYPE                := ::cTYPE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_SYSFIELDSSTRU
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,"Property cTYPE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SYSTABLESSTRU

WSSTRUCT IREPORT_SYSTABLESSTRU
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cMODE                     AS string
	WSDATA   cMODEEMP                  AS string
	WSDATA   cMODEUN                   AS string
	WSDATA   cTABELA                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_SYSTABLESSTRU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_SYSTABLESSTRU
Return

WSMETHOD CLONE WSCLIENT IREPORT_SYSTABLESSTRU
	Local oClone := IREPORT_SYSTABLESSTRU():NEW()
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cMODE                := ::cMODE
	oClone:cMODEEMP             := ::cMODEEMP
	oClone:cMODEUN              := ::cMODEUN
	oClone:cTABELA              := ::cTABELA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_SYSTABLESSTRU
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMODE              :=  WSAdvValue( oResponse,"_MODE","string",NIL,"Property cMODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMODEEMP           :=  WSAdvValue( oResponse,"_MODEEMP","string",NIL,"Property cMODEEMP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMODEUN            :=  WSAdvValue( oResponse,"_MODEUN","string",NIL,"Property cMODEUN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTABELA            :=  WSAdvValue( oResponse,"_TABELA","string",NIL,"Property cTABELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure LSTRELATIONS

WSSTRUCT IREPORT_LSTRELATIONS
	WSDATA   oWSLISTCONNECTION         AS IREPORT_ARRAYOFLSTCONNECTION
	WSDATA   cNAME                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_LSTRELATIONS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_LSTRELATIONS
Return

WSMETHOD CLONE WSCLIENT IREPORT_LSTRELATIONS
	Local oClone := IREPORT_LSTRELATIONS():NEW()
	oClone:oWSLISTCONNECTION    := IIF(::oWSLISTCONNECTION = NIL , NIL , ::oWSLISTCONNECTION:Clone() )
	oClone:cNAME                := ::cNAME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_LSTRELATIONS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTCONNECTION","ARRAYOFLSTCONNECTION",NIL,"Property oWSLISTCONNECTION as s0:ARRAYOFLSTCONNECTION on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTCONNECTION := IREPORT_ARRAYOFLSTCONNECTION():New()
		::oWSLISTCONNECTION:SoapRecv(oNode1)
	EndIf
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFLSTCONNECTION

WSSTRUCT IREPORT_ARRAYOFLSTCONNECTION
	WSDATA   oWSLSTCONNECTION          AS IREPORT_LSTCONNECTION OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_ARRAYOFLSTCONNECTION
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_ARRAYOFLSTCONNECTION
	::oWSLSTCONNECTION     := {} // Array Of  IREPORT_LSTCONNECTION():New()
Return

WSMETHOD CLONE WSCLIENT IREPORT_ARRAYOFLSTCONNECTION
	Local oClone := IREPORT_ARRAYOFLSTCONNECTION():NEW()
	oClone:oWSLSTCONNECTION := NIL
	If ::oWSLSTCONNECTION <> NIL 
		oClone:oWSLSTCONNECTION := {}
		aEval( ::oWSLSTCONNECTION , { |x| aadd( oClone:oWSLSTCONNECTION , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_ARRAYOFLSTCONNECTION
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LSTCONNECTION","LSTCONNECTION",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLSTCONNECTION , IREPORT_LSTCONNECTION():New() )
			::oWSLSTCONNECTION[len(::oWSLSTCONNECTION)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure LSTCONNECTION

WSSTRUCT IREPORT_LSTCONNECTION
	WSDATA   cFIELDCDOM                AS string
	WSDATA   cFIELDDOM                 AS string
	WSDATA   cTABLECDOM                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IREPORT_LSTCONNECTION
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IREPORT_LSTCONNECTION
Return

WSMETHOD CLONE WSCLIENT IREPORT_LSTCONNECTION
	Local oClone := IREPORT_LSTCONNECTION():NEW()
	oClone:cFIELDCDOM           := ::cFIELDCDOM
	oClone:cFIELDDOM            := ::cFIELDDOM
	oClone:cTABLECDOM           := ::cTABLECDOM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IREPORT_LSTCONNECTION
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFIELDCDOM         :=  WSAdvValue( oResponse,"_FIELDCDOM","string",NIL,"Property cFIELDCDOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFIELDDOM          :=  WSAdvValue( oResponse,"_FIELDDOM","string",NIL,"Property cFIELDDOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTABLECDOM         :=  WSAdvValue( oResponse,"_TABLECDOM","string",NIL,"Property cTABLECDOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return