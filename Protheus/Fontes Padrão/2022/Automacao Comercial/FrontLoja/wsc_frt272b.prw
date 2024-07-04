#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/WSFRT272B.apw?WSDL
Gerado em        09/13/21 18:41:24
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OMIQRFY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSFRT272B
------------------------------------------------------------------------------- */

WSCLIENT WSWSFRT272B

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD EXCONFABLW
	WSMETHOD RETPARSRV
	WSMETHOD RETSITLW

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nNOPC                     AS integer
	WSDATA   cCOPER                    AS string
	WSDATA   cCPDV                     AS string
	WSDATA   cCESTACAO                 AS string
	WSDATA   cCNUMMOV                  AS string
	WSDATA   cCEMPC                    AS string
	WSDATA   cCFILC                    AS string
	WSDATA   oWSEXCONFABLWRESULT       AS WSFRT272B_ARRAYOFRETSLW
	WSDATA   cCCHAVE                   AS string
	WSDATA   cRETPARSRVRESULT          AS string
	WSDATA   cRETSITLWRESULT           AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSFRT272B
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSFRT272B
	::oWSEXCONFABLWRESULT := WSFRT272B_ARRAYOFRETSLW():New()
Return

WSMETHOD RESET WSCLIENT WSWSFRT272B
	::nNOPC              := NIL 
	::cCOPER             := NIL 
	::cCPDV              := NIL 
	::cCESTACAO          := NIL 
	::cCNUMMOV           := NIL 
	::cCEMPC             := NIL 
	::cCFILC             := NIL 
	::oWSEXCONFABLWRESULT := NIL 
	::cCCHAVE            := NIL 
	::cRETPARSRVRESULT   := NIL 
	::cRETSITLWRESULT    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSFRT272B
Local oClone := WSWSFRT272B():New()
	oClone:_URL          := ::_URL 
	oClone:nNOPC         := ::nNOPC
	oClone:cCOPER        := ::cCOPER
	oClone:cCPDV         := ::cCPDV
	oClone:cCESTACAO     := ::cCESTACAO
	oClone:cCNUMMOV      := ::cCNUMMOV
	oClone:cCEMPC        := ::cCEMPC
	oClone:cCFILC        := ::cCFILC
	oClone:oWSEXCONFABLWRESULT :=  IIF(::oWSEXCONFABLWRESULT = NIL , NIL ,::oWSEXCONFABLWRESULT:Clone() )
	oClone:cCCHAVE       := ::cCCHAVE
	oClone:cRETPARSRVRESULT := ::cRETPARSRVRESULT
	oClone:cRETSITLWRESULT := ::cRETSITLWRESULT
Return oClone

// WSDL Method EXCONFABLW of Service WSWSFRT272B

WSMETHOD EXCONFABLW WSSEND nNOPC,cCOPER,cCPDV,cCESTACAO,cCNUMMOV,cCEMPC,cCFILC WSRECEIVE oWSEXCONFABLWRESULT WSCLIENT WSWSFRT272B
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EXCONFABLW xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("NOPC", ::nNOPC, nNOPC , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("COPER", ::cCOPER, cCOPER , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CESTACAO", ::cCESTACAO, cCESTACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNUMMOV", ::cCNUMMOV, cCNUMMOV , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPC", ::cCEMPC, cCEMPC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILC", ::cCFILC, cCFILC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EXCONFABLW>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/EXCONFABLW",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/WSFRT272B.apw")

::Init()
::oWSEXCONFABLWRESULT:SoapRecv( WSAdvValue( oXmlRet,"_EXCONFABLWRESPONSE:_EXCONFABLWRESULT","ARRAYOFRETSLW",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETPARSRV of Service WSWSFRT272B

WSMETHOD RETPARSRV WSSEND cCEMPC,cCFILC,cCCHAVE WSRECEIVE cRETPARSRVRESULT WSCLIENT WSWSFRT272B
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETPARSRV xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("CEMPC", ::cCEMPC, cCEMPC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILC", ::cCFILC, cCFILC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETPARSRV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/RETPARSRV",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/WSFRT272B.apw")

::Init()
::cRETPARSRVRESULT   :=  WSAdvValue( oXmlRet,"_RETPARSRVRESPONSE:_RETPARSRVRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETSITLW of Service WSWSFRT272B

WSMETHOD RETSITLW WSSEND cCEMPC,cCFILC,cCCHAVE WSRECEIVE cRETSITLWRESULT WSCLIENT WSWSFRT272B
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETSITLW xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("CEMPC", ::cCEMPC, cCEMPC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILC", ::cCFILC, cCFILC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RETSITLW>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/RETSITLW",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/WSFRT272B.apw")

::Init()
::cRETSITLWRESULT    :=  WSAdvValue( oXmlRet,"_RETSITLWRESPONSE:_RETSITLWRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFRETSLW

WSSTRUCT WSFRT272B_ARRAYOFRETSLW
	WSDATA   oWSRETSLW                 AS WSFRT272B_RETSLW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFRT272B_ARRAYOFRETSLW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFRT272B_ARRAYOFRETSLW
	::oWSRETSLW            := {} // Array Of  WSFRT272B_RETSLW():New()
Return

WSMETHOD CLONE WSCLIENT WSFRT272B_ARRAYOFRETSLW
	Local oClone := WSFRT272B_ARRAYOFRETSLW():NEW()
	oClone:oWSRETSLW := NIL
	If ::oWSRETSLW <> NIL 
		oClone:oWSRETSLW := {}
		aEval( ::oWSRETSLW , { |x| aadd( oClone:oWSRETSLW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSFRT272B_ARRAYOFRETSLW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETSLW","RETSLW",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRETSLW , WSFRT272B_RETSLW():New() )
			::oWSRETSLW[len(::oWSRETSLW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RETSLW

WSSTRUCT WSFRT272B_RETSLW
	WSDATA   cCCHAVE                   AS string
	WSDATA   lLRET                     AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSFRT272B_RETSLW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSFRT272B_RETSLW
Return

WSMETHOD CLONE WSCLIENT WSFRT272B_RETSLW
	Local oClone := WSFRT272B_RETSLW():NEW()
	oClone:cCCHAVE              := ::cCCHAVE
	oClone:lLRET                := ::lLRET
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSFRT272B_RETSLW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCCHAVE            :=  WSAdvValue( oResponse,"_CCHAVE","string",NIL,"Property cCCHAVE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lLRET              :=  WSAdvValue( oResponse,"_LRET","boolean",NIL,"Property lLRET as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return


