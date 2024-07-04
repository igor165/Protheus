#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://totvs-11032:85/LOJESTOQUE.apw?WSDL
Gerado em        03/02/11 15:27:45
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.101007
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _MBOOYHB ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLOJESTOQUE
------------------------------------------------------------------------------- */

WSCLIENT WSLOJESTOQUE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONESTOQUE
	WSMETHOD CONFILIAIS
	WSMETHOD VLLINK

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCEMPPDV                  AS string
	WSDATA   cCFILPDV                  AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cCPRODUTO                 AS string
	WSDATA   cCLOCALPROD               AS string
	WSDATA   oWSCONESTOQUERESULT       AS LOJESTOQUE_ARRAYOFWSRETETQ
	WSDATA   oWSCONFILIAISRESULT       AS LOJESTOQUE_ARRAYOFWSRETFIL
	WSDATA   cCCONN                    AS string
	WSDATA   lVLLINKRESULT             AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLOJESTOQUE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLOJESTOQUE
	::oWSCONESTOQUERESULT := LOJESTOQUE_ARRAYOFWSRETETQ():New()
	::oWSCONFILIAISRESULT := LOJESTOQUE_ARRAYOFWSRETFIL():New()
Return

WSMETHOD RESET WSCLIENT WSLOJESTOQUE
	::cCEMPPDV           := NIL 
	::cCFILPDV           := NIL 
	::cCFIL              := NIL 
	::cCPRODUTO          := NIL 
	::cCLOCALPROD        := NIL 
	::oWSCONESTOQUERESULT := NIL 
	::oWSCONFILIAISRESULT := NIL 
	::cCCONN             := NIL 
	::lVLLINKRESULT      := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLOJESTOQUE
Local oClone := WSLOJESTOQUE():New()
	oClone:_URL          := ::_URL 
	oClone:cCEMPPDV      := ::cCEMPPDV
	oClone:cCFILPDV      := ::cCFILPDV
	oClone:cCFIL         := ::cCFIL
	oClone:cCPRODUTO     := ::cCPRODUTO
	oClone:cCLOCALPROD   := ::cCLOCALPROD
	oClone:oWSCONESTOQUERESULT :=  IIF(::oWSCONESTOQUERESULT = NIL , NIL ,::oWSCONESTOQUERESULT:Clone() )
	oClone:oWSCONFILIAISRESULT :=  IIF(::oWSCONFILIAISRESULT = NIL , NIL ,::oWSCONFILIAISRESULT:Clone() )
	oClone:cCCONN        := ::cCCONN
	oClone:lVLLINKRESULT := ::lVLLINKRESULT
Return oClone

// WSDL Method CONESTOQUE of Service WSLOJESTOQUE

WSMETHOD CONESTOQUE WSSEND cCEMPPDV,cCFILPDV,cCFIL,cCPRODUTO,cCLOCALPROD WSRECEIVE oWSCONESTOQUERESULT WSCLIENT WSLOJESTOQUE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONESTOQUE xmlns="http://totvs-11032:85/">'
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CPRODUTO", ::cCPRODUTO, cCPRODUTO , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CLOCALPROD", ::cCLOCALPROD, cCLOCALPROD , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += "</CONESTOQUE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://totvs-11032:85/CONESTOQUE",; 
	"DOCUMENT","http://totvs-11032:85/",,"1.031217",; 
	"http://totvs-11032:85/LOJESTOQUE.apw")

::Init()
::oWSCONESTOQUERESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONESTOQUERESPONSE:_CONESTOQUERESULT","ARRAYOFWSRETETQ",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONFILIAIS of Service WSLOJESTOQUE

WSMETHOD CONFILIAIS WSSEND cCEMPPDV,cCFILPDV WSRECEIVE oWSCONFILIAISRESULT WSCLIENT WSLOJESTOQUE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONFILIAIS xmlns="http://totvs-11032:85/">'
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</CONFILIAIS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://totvs-11032:85/CONFILIAIS",; 
	"DOCUMENT","http://totvs-11032:85/",,"1.031217",; 
	"http://totvs-11032:85/LOJESTOQUE.apw")

::Init()
::oWSCONFILIAISRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONFILIAISRESPONSE:_CONFILIAISRESULT","ARRAYOFWSRETFIL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VLLINK of Service WSLOJESTOQUE

WSMETHOD VLLINK WSSEND cCCONN WSRECEIVE lVLLINKRESULT WSCLIENT WSLOJESTOQUE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VLLINK xmlns="http://totvs-11032:85/">'
cSoap += WSSoapValue("CCONN", ::cCCONN, cCCONN , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += "</VLLINK>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://totvs-11032:85/VLLINK",; 
	"DOCUMENT","http://totvs-11032:85/",,"1.031217",; 
	"http://totvs-11032:85/LOJESTOQUE.apw")

::Init()
::lVLLINKRESULT      :=  WSAdvValue( oXmlRet,"_VLLINKRESPONSE:_VLLINKRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFWSRETETQ

WSSTRUCT LOJESTOQUE_ARRAYOFWSRETETQ
	WSDATA   oWSWSRETETQ               AS LOJESTOQUE_WSRETETQ OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LOJESTOQUE_ARRAYOFWSRETETQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LOJESTOQUE_ARRAYOFWSRETETQ
	::oWSWSRETETQ          := {} // Array Of  LOJESTOQUE_WSRETETQ():New()
Return

WSMETHOD CLONE WSCLIENT LOJESTOQUE_ARRAYOFWSRETETQ
	Local oClone := LOJESTOQUE_ARRAYOFWSRETETQ():NEW()
	oClone:oWSWSRETETQ := NIL
	If ::oWSWSRETETQ <> NIL 
		oClone:oWSWSRETETQ := {}
		aEval( ::oWSWSRETETQ , { |x| aadd( oClone:oWSWSRETETQ , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LOJESTOQUE_ARRAYOFWSRETETQ
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSRETETQ","WSRETETQ",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSRETETQ , LOJESTOQUE_WSRETETQ():New() )
			::oWSWSRETETQ[len(::oWSWSRETETQ)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFWSRETFIL

WSSTRUCT LOJESTOQUE_ARRAYOFWSRETFIL
	WSDATA   oWSWSRETFIL               AS LOJESTOQUE_WSRETFIL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LOJESTOQUE_ARRAYOFWSRETFIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LOJESTOQUE_ARRAYOFWSRETFIL
	::oWSWSRETFIL          := {} // Array Of  LOJESTOQUE_WSRETFIL():New()
Return

WSMETHOD CLONE WSCLIENT LOJESTOQUE_ARRAYOFWSRETFIL
	Local oClone := LOJESTOQUE_ARRAYOFWSRETFIL():NEW()
	oClone:oWSWSRETFIL := NIL
	If ::oWSWSRETFIL <> NIL 
		oClone:oWSWSRETFIL := {}
		aEval( ::oWSWSRETFIL , { |x| aadd( oClone:oWSWSRETFIL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LOJESTOQUE_ARRAYOFWSRETFIL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSRETFIL","WSRETFIL",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSRETFIL , LOJESTOQUE_WSRETFIL():New() )
			::oWSWSRETFIL[len(::oWSWSRETFIL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure WSRETETQ

WSSTRUCT LOJESTOQUE_WSRETETQ
	WSDATA   cCDESCRI                  AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cCGRUPO                   AS string
	WSDATA   cCLOCALPROD               AS string
	WSDATA   cCPRODUTO                 AS string
	WSDATA   cCUNIDADE                 AS string
	WSDATA   nNATUAL                   AS float
	WSDATA   nNINICIAL                 AS float
	WSDATA   nNPRECO1                  AS float
	WSDATA   nNPRECO2                  AS float
	WSDATA   nNPRECO3                  AS float
	WSDATA   nNPRECO4                  AS float
	WSDATA   nNPRECO5                  AS float
	WSDATA   nNPRECO6                  AS float
	WSDATA   nNPRECO7                  AS float
	WSDATA   nNPRECO8                  AS float
	WSDATA   nNPRECO9                  AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LOJESTOQUE_WSRETETQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LOJESTOQUE_WSRETETQ
Return

WSMETHOD CLONE WSCLIENT LOJESTOQUE_WSRETETQ
	Local oClone := LOJESTOQUE_WSRETETQ():NEW()
	oClone:cCDESCRI             := ::cCDESCRI
	oClone:cCFIL                := ::cCFIL
	oClone:cCGRUPO              := ::cCGRUPO
	oClone:cCLOCALPROD          := ::cCLOCALPROD
	oClone:cCPRODUTO            := ::cCPRODUTO
	oClone:cCUNIDADE            := ::cCUNIDADE
	oClone:nNATUAL              := ::nNATUAL
	oClone:nNINICIAL            := ::nNINICIAL
	oClone:nNPRECO1             := ::nNPRECO1
	oClone:nNPRECO2             := ::nNPRECO2
	oClone:nNPRECO3             := ::nNPRECO3
	oClone:nNPRECO4             := ::nNPRECO4
	oClone:nNPRECO5             := ::nNPRECO5
	oClone:nNPRECO6             := ::nNPRECO6
	oClone:nNPRECO7             := ::nNPRECO7
	oClone:nNPRECO8             := ::nNPRECO8
	oClone:nNPRECO9             := ::nNPRECO9
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LOJESTOQUE_WSRETETQ
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCDESCRI           :=  WSAdvValue( oResponse,"_CDESCRI","string",NIL,"Property cCDESCRI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCFIL              :=  WSAdvValue( oResponse,"_CFIL","string",NIL,"Property cCFIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCGRUPO            :=  WSAdvValue( oResponse,"_CGRUPO","string",NIL,"Property cCGRUPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCLOCALPROD        :=  WSAdvValue( oResponse,"_CLOCALPROD","string",NIL,"Property cCLOCALPROD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCPRODUTO          :=  WSAdvValue( oResponse,"_CPRODUTO","string",NIL,"Property cCPRODUTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCUNIDADE          :=  WSAdvValue( oResponse,"_CUNIDADE","string",NIL,"Property cCUNIDADE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nNATUAL            :=  WSAdvValue( oResponse,"_NATUAL","float",NIL,"Property nNATUAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNINICIAL          :=  WSAdvValue( oResponse,"_NINICIAL","float",NIL,"Property nNINICIAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO1           :=  WSAdvValue( oResponse,"_NPRECO1","float",NIL,"Property nNPRECO1 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO2           :=  WSAdvValue( oResponse,"_NPRECO2","float",NIL,"Property nNPRECO2 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO3           :=  WSAdvValue( oResponse,"_NPRECO3","float",NIL,"Property nNPRECO3 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO4           :=  WSAdvValue( oResponse,"_NPRECO4","float",NIL,"Property nNPRECO4 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO5           :=  WSAdvValue( oResponse,"_NPRECO5","float",NIL,"Property nNPRECO5 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO6           :=  WSAdvValue( oResponse,"_NPRECO6","float",NIL,"Property nNPRECO6 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO7           :=  WSAdvValue( oResponse,"_NPRECO7","float",NIL,"Property nNPRECO7 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO8           :=  WSAdvValue( oResponse,"_NPRECO8","float",NIL,"Property nNPRECO8 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNPRECO9           :=  WSAdvValue( oResponse,"_NPRECO9","float",NIL,"Property nNPRECO9 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure WSRETFIL

WSSTRUCT LOJESTOQUE_WSRETFIL
	WSDATA   cCCIDENT                  AS string
	WSDATA   cCCODFIL                  AS string
	WSDATA   cCNAMEFIL                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LOJESTOQUE_WSRETFIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LOJESTOQUE_WSRETFIL
Return

WSMETHOD CLONE WSCLIENT LOJESTOQUE_WSRETFIL
	Local oClone := LOJESTOQUE_WSRETFIL():NEW()
	oClone:cCCIDENT             := ::cCCIDENT
	oClone:cCCODFIL             := ::cCCODFIL
	oClone:cCNAMEFIL            := ::cCNAMEFIL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LOJESTOQUE_WSRETFIL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCCIDENT           :=  WSAdvValue( oResponse,"_CCIDENT","string",NIL,"Property cCCIDENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCCODFIL           :=  WSAdvValue( oResponse,"_CCODFIL","string",NIL,"Property cCCODFIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCNAMEFIL          :=  WSAdvValue( oResponse,"_CNAMEFIL","string",NIL,"Property cCNAMEFIL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return




