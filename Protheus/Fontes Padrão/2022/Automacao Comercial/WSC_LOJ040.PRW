#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://ipt-ricardo:87/LJCARFID.apw?WSDL
Generado en        04/27/11 17:15:39
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.110315
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _MVRRSQJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLJCARFID
------------------------------------------------------------------------------- */

WSCLIENT WSLJCARFID

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ATUSALDFID
	WSMETHOD CALSALDFID
	WSMETHOD CONCARTFID
	WSMETHOD CONECTA
	WSMETHOD CONSALDFID
	WSMETHOD ESTSALDFID
	WSMETHOD INCSALDFID
	WSMETHOD VALCARFID

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCNUMCAR                  AS string
	WSDATA   nNSALDOABAT               AS float
	WSDATA   cCDOC                     AS string
	WSDATA   cCSERIE                   AS string
	WSDATA   cCLOJA                    AS string
	WSDATA   cCEMPPDV                  AS string
	WSDATA   cCFILPDV                  AS string
	WSDATA   lATUSALDFIDRESULT         AS boolean
	WSDATA   nCALSALDFIDRESULT         AS float
	WSDATA   cCCODCLI                  AS string
	WSDATA   oWSCONCARTFIDRESULT       AS LJCARFID_ARRAYOFWSFIDITENS
	WSDATA   cCCONN                    AS string
	WSDATA   lCONECTARESULT            AS boolean
	WSDATA   nNVALPAGTO                AS float
	WSDATA   lCONSALDFIDRESULT         AS boolean
	WSDATA   cCTIPO                    AS string
	WSDATA   lESTSALDFIDRESULT         AS boolean
	WSDATA   dDDTVALID                 AS date
	WSDATA   nNVALOR                   AS float
	WSDATA   lINCSALDFIDRESULT         AS boolean
	WSDATA   lVALCARFIDRESULT          AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJCARFID
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110106] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJCARFID
	::oWSCONCARTFIDRESULT := LJCARFID_ARRAYOFWSFIDITENS():New()
Return

WSMETHOD RESET WSCLIENT WSLJCARFID
	::cCNUMCAR           := NIL 
	::nNSALDOABAT        := NIL 
	::cCDOC              := NIL 
	::cCSERIE            := NIL 
	::cCLOJA             := NIL 
	::cCEMPPDV           := NIL 
	::cCFILPDV           := NIL 
	::lATUSALDFIDRESULT  := NIL 
	::nCALSALDFIDRESULT  := NIL 
	::cCCODCLI           := NIL 
	::oWSCONCARTFIDRESULT := NIL 
	::cCCONN             := NIL 
	::lCONECTARESULT     := NIL 
	::nNVALPAGTO         := NIL 
	::lCONSALDFIDRESULT  := NIL 
	::cCTIPO             := NIL 
	::lESTSALDFIDRESULT  := NIL 
	::dDDTVALID          := NIL 
	::nNVALOR            := NIL 
	::lINCSALDFIDRESULT  := NIL 
	::lVALCARFIDRESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJCARFID
Local oClone := WSLJCARFID():New()
	oClone:_URL          := ::_URL 
	oClone:cCNUMCAR      := ::cCNUMCAR
	oClone:nNSALDOABAT   := ::nNSALDOABAT
	oClone:cCDOC         := ::cCDOC
	oClone:cCSERIE       := ::cCSERIE
	oClone:cCLOJA        := ::cCLOJA
	oClone:cCEMPPDV      := ::cCEMPPDV
	oClone:cCFILPDV      := ::cCFILPDV
	oClone:lATUSALDFIDRESULT := ::lATUSALDFIDRESULT
	oClone:nCALSALDFIDRESULT := ::nCALSALDFIDRESULT
	oClone:cCCODCLI      := ::cCCODCLI
	oClone:oWSCONCARTFIDRESULT :=  IIF(::oWSCONCARTFIDRESULT = NIL , NIL ,::oWSCONCARTFIDRESULT:Clone() )
	oClone:cCCONN        := ::cCCONN
	oClone:lCONECTARESULT := ::lCONECTARESULT
	oClone:nNVALPAGTO    := ::nNVALPAGTO
	oClone:lCONSALDFIDRESULT := ::lCONSALDFIDRESULT
	oClone:cCTIPO        := ::cCTIPO
	oClone:lESTSALDFIDRESULT := ::lESTSALDFIDRESULT
	oClone:dDDTVALID     := ::dDDTVALID
	oClone:nNVALOR       := ::nNVALOR
	oClone:lINCSALDFIDRESULT := ::lINCSALDFIDRESULT
	oClone:lVALCARFIDRESULT := ::lVALCARFIDRESULT
Return oClone

// WSDL Method ATUSALDFID of Service WSLJCARFID

WSMETHOD ATUSALDFID WSSEND cCNUMCAR,nNSALDOABAT,cCDOC,cCSERIE,cCLOJA,cCEMPPDV,cCFILPDV WSRECEIVE lATUSALDFIDRESULT WSCLIENT WSLJCARFID
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ATUSALDFID xmlns="http://ipt-ricardo:87/">'
cSoap += WSSoapValue("CNUMCAR", ::cCNUMCAR, cCNUMCAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NSALDOABAT", ::nNSALDOABAT, nNSALDOABAT , "float", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDOC", ::cCDOC, cCDOC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CLOJA", ::cCLOJA, cCLOJA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</ATUSALDFID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:87/ATUSALDFID",; 
	"DOCUMENT","http://ipt-ricardo:87/",,"1.031217",; 
	"http://ipt-ricardo:87/LJCARFID.apw")

::Init()
::lATUSALDFIDRESULT  :=  WSAdvValue( oXmlRet,"_ATUSALDFIDRESPONSE:_ATUSALDFIDRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CALSALDFID of Service WSLJCARFID

WSMETHOD CALSALDFID WSSEND cCNUMCAR,cCEMPPDV,cCFILPDV WSRECEIVE nCALSALDFIDRESULT WSCLIENT WSLJCARFID
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CALSALDFID xmlns="http://ipt-ricardo:87/">'
cSoap += WSSoapValue("CNUMCAR", ::cCNUMCAR, cCNUMCAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CALSALDFID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:87/CALSALDFID",; 
	"DOCUMENT","http://ipt-ricardo:87/",,"1.031217",; 
	"http://ipt-ricardo:87/LJCARFID.apw")

::Init()
::nCALSALDFIDRESULT  :=  WSAdvValue( oXmlRet,"_CALSALDFIDRESPONSE:_CALSALDFIDRESULT:TEXT","float",NIL,NIL,NIL,NIL,NIL,NIL) 
END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONCARTFID of Service WSLJCARFID

WSMETHOD CONCARTFID WSSEND cCCODCLI,cCLOJA,cCEMPPDV,cCFILPDV WSRECEIVE oWSCONCARTFIDRESULT WSCLIENT WSLJCARFID
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONCARTFID xmlns="http://ipt-ricardo:87/">'
cSoap += WSSoapValue("CCODCLI", ::cCCODCLI, cCCODCLI , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CLOJA", ::cCLOJA, cCLOJA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONCARTFID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:87/CONCARTFID",; 
	"DOCUMENT","http://ipt-ricardo:87/",,"1.031217",; 
	"http://ipt-ricardo:87/LJCARFID.apw")

::Init()
::oWSCONCARTFIDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONCARTFIDRESPONSE:_CONCARTFIDRESULT","ARRAYOFWSFIDITENS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONECTA of Service WSLJCARFID

WSMETHOD CONECTA WSSEND cCCONN WSRECEIVE lCONECTARESULT WSCLIENT WSLJCARFID
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONECTA xmlns="http://ipt-ricardo:87/">'
cSoap += WSSoapValue("CCONN", ::cCCONN, cCCONN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONECTA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:87/CONECTA",; 
	"DOCUMENT","http://ipt-ricardo:87/",,"1.031217",; 
	"http://ipt-ricardo:87/LJCARFID.apw")

::Init()
::lCONECTARESULT     :=  WSAdvValue( oXmlRet,"_CONECTARESPONSE:_CONECTARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSALDFID of Service WSLJCARFID

WSMETHOD CONSALDFID WSSEND cCNUMCAR,nNVALPAGTO,cCEMPPDV,cCFILPDV WSRECEIVE lCONSALDFIDRESULT WSCLIENT WSLJCARFID
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSALDFID xmlns="http://ipt-ricardo:87/">'
cSoap += WSSoapValue("CNUMCAR", ::cCNUMCAR, cCNUMCAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NVALPAGTO", ::nNVALPAGTO, nNVALPAGTO , "float", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONSALDFID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:87/CONSALDFID",; 
	"DOCUMENT","http://ipt-ricardo:87/",,"1.031217",; 
	"http://ipt-ricardo:87/LJCARFID.apw")

::Init()
::lCONSALDFIDRESULT  :=  WSAdvValue( oXmlRet,"_CONSALDFIDRESPONSE:_CONSALDFIDRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ESTSALDFID of Service WSLJCARFID

WSMETHOD ESTSALDFID WSSEND cCNUMCAR,cCDOC,cCSERIE,cCLOJA,cCTIPO,cCEMPPDV,cCFILPDV WSRECEIVE lESTSALDFIDRESULT WSCLIENT WSLJCARFID
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ESTSALDFID xmlns="http://ipt-ricardo:87/">'
cSoap += WSSoapValue("CNUMCAR", ::cCNUMCAR, cCNUMCAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDOC", ::cCDOC, cCDOC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CLOJA", ::cCLOJA, cCLOJA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CTIPO", ::cCTIPO, cCTIPO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</ESTSALDFID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:87/ESTSALDFID",; 
	"DOCUMENT","http://ipt-ricardo:87/",,"1.031217",; 
	"http://ipt-ricardo:87/LJCARFID.apw")

::Init()
::lESTSALDFIDRESULT  :=  WSAdvValue( oXmlRet,"_ESTSALDFIDRESPONSE:_ESTSALDFIDRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCSALDFID of Service WSLJCARFID

WSMETHOD INCSALDFID WSSEND cCNUMCAR,dDDTVALID,nNVALOR,cCDOC,cCSERIE,cCLOJA,cCEMPPDV,cCFILPDV WSRECEIVE lINCSALDFIDRESULT WSCLIENT WSLJCARFID
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCSALDFID xmlns="http://ipt-ricardo:87/">'
cSoap += WSSoapValue("CNUMCAR", ::cCNUMCAR, cCNUMCAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DDTVALID", ::dDDTVALID, dDDTVALID , "date", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NVALOR", ::nNVALOR, nNVALOR , "float", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDOC", ::cCDOC, cCDOC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CLOJA", ::cCLOJA, cCLOJA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</INCSALDFID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:87/INCSALDFID",; 
	"DOCUMENT","http://ipt-ricardo:87/",,"1.031217",; 
	"http://ipt-ricardo:87/LJCARFID.apw")

::Init()
::lINCSALDFIDRESULT  :=  WSAdvValue( oXmlRet,"_INCSALDFIDRESPONSE:_INCSALDFIDRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VALCARFID of Service WSLJCARFID

WSMETHOD VALCARFID WSSEND cCNUMCAR,cCEMPPDV,cCFILPDV WSRECEIVE lVALCARFIDRESULT WSCLIENT WSLJCARFID
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VALCARFID xmlns="http://ipt-ricardo:87/">'
cSoap += WSSoapValue("CNUMCAR", ::cCNUMCAR, cCNUMCAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</VALCARFID>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:87/VALCARFID",; 
	"DOCUMENT","http://ipt-ricardo:87/",,"1.031217",; 
	"http://ipt-ricardo:87/LJCARFID.apw")

::Init()
::lVALCARFIDRESULT   :=  WSAdvValue( oXmlRet,"_VALCARFIDRESPONSE:_VALCARFIDRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFWSFIDITENS

WSSTRUCT LJCARFID_ARRAYOFWSFIDITENS
	WSDATA   oWSWSFIDITENS             AS LJCARFID_WSFIDITENS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJCARFID_ARRAYOFWSFIDITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJCARFID_ARRAYOFWSFIDITENS
	::oWSWSFIDITENS        := {} // Array Of  LJCARFID_WSFIDITENS():New()
Return

WSMETHOD CLONE WSCLIENT LJCARFID_ARRAYOFWSFIDITENS
	Local oClone := LJCARFID_ARRAYOFWSFIDITENS():NEW()
	oClone:oWSWSFIDITENS := NIL
	If ::oWSWSFIDITENS <> NIL 
		oClone:oWSWSFIDITENS := {}
		aEval( ::oWSWSFIDITENS , { |x| aadd( oClone:oWSWSFIDITENS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJCARFID_ARRAYOFWSFIDITENS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSFIDITENS","WSFIDITENS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSFIDITENS , LJCARFID_WSFIDITENS():New() )
			::oWSWSFIDITENS[len(::oWSWSFIDITENS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure WSFIDITENS

WSSTRUCT LJCARFID_WSFIDITENS
	WSDATA   cCARTAOFID                AS string
	WSDATA   dDATAVALFID               AS date
	WSDATA   cSTATUSFID                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJCARFID_WSFIDITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJCARFID_WSFIDITENS
Return

WSMETHOD CLONE WSCLIENT LJCARFID_WSFIDITENS
	Local oClone := LJCARFID_WSFIDITENS():NEW()
	oClone:cCARTAOFID           := ::cCARTAOFID
	oClone:dDATAVALFID          := ::dDATAVALFID
	oClone:cSTATUSFID           := ::cSTATUSFID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJCARFID_WSFIDITENS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCARTAOFID         :=  WSAdvValue( oResponse,"_CARTAOFID","string",NIL,"Property cCARTAOFID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dDATAVALFID        :=  WSAdvValue( oResponse,"_DATAVALFID","date",NIL,"Property dDATAVALFID as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cSTATUSFID         :=  WSAdvValue( oResponse,"_STATUSFID","string",NIL,"Property cSTATUSFID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


