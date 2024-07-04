#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/FRTCRDPSVPG.apw?WSDL
Gerado em        09/13/21 18:55:32
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QWZRLLJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFRTCRDPSVPG
------------------------------------------------------------------------------- */

WSCLIENT WSFRTCRDPSVPG

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CRDPSVCPG
	WSMETHOD CRDUPDMAV

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCVALE                    AS string
	WSDATA   oWSCRDPSVCPGRESULT        AS FRTCRDPSVPG_ARRAYOFLSVC
	WSDATA   oWSVALES                  AS FRTCRDPSVPG_RECARRAY
	WSDATA   lCRDUPDMAVRESULT          AS boolean

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSRECARRAY               AS FRTCRDPSVPG_RECARRAY

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFRTCRDPSVPG
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFRTCRDPSVPG
	::oWSCRDPSVCPGRESULT := FRTCRDPSVPG_ARRAYOFLSVC():New()
	::oWSVALES           := FRTCRDPSVPG_RECARRAY():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSRECARRAY        := ::oWSVALES
Return

WSMETHOD RESET WSCLIENT WSFRTCRDPSVPG
	::cCVALE             := NIL 
	::oWSCRDPSVCPGRESULT := NIL 
	::oWSVALES           := NIL 
	::lCRDUPDMAVRESULT   := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSRECARRAY        := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFRTCRDPSVPG
Local oClone := WSFRTCRDPSVPG():New()
	oClone:_URL          := ::_URL 
	oClone:cCVALE        := ::cCVALE
	oClone:oWSCRDPSVCPGRESULT :=  IIF(::oWSCRDPSVCPGRESULT = NIL , NIL ,::oWSCRDPSVCPGRESULT:Clone() )
	oClone:oWSVALES      :=  IIF(::oWSVALES = NIL , NIL ,::oWSVALES:Clone() )
	oClone:lCRDUPDMAVRESULT := ::lCRDUPDMAVRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSRECARRAY   := oClone:oWSVALES
Return oClone

// WSDL Method CRDPSVCPG of Service WSFRTCRDPSVPG

WSMETHOD CRDPSVCPG WSSEND cCVALE WSRECEIVE oWSCRDPSVCPGRESULT WSCLIENT WSFRTCRDPSVPG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CRDPSVCPG xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("CVALE", ::cCVALE, cCVALE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CRDPSVCPG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CRDPSVCPG",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/FRTCRDPSVPG.apw")

::Init()
::oWSCRDPSVCPGRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CRDPSVCPGRESPONSE:_CRDPSVCPGRESULT","ARRAYOFLSVC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CRDUPDMAV of Service WSFRTCRDPSVPG

WSMETHOD CRDUPDMAV WSSEND oWSVALES WSRECEIVE lCRDUPDMAVRESULT WSCLIENT WSFRTCRDPSVPG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CRDUPDMAV xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("VALES", ::oWSVALES, oWSVALES , "RECARRAY", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CRDUPDMAV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CRDUPDMAV",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/FRTCRDPSVPG.apw")

::Init()
::lCRDUPDMAVRESULT   :=  WSAdvValue( oXmlRet,"_CRDUPDMAVRESPONSE:_CRDUPDMAVRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFLSVC

WSSTRUCT FRTCRDPSVPG_ARRAYOFLSVC
	WSDATA   oWSLSVC                   AS FRTCRDPSVPG_LSVC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRDPSVPG_ARRAYOFLSVC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRDPSVPG_ARRAYOFLSVC
	::oWSLSVC              := {} // Array Of  FRTCRDPSVPG_LSVC():New()
Return

WSMETHOD CLONE WSCLIENT FRTCRDPSVPG_ARRAYOFLSVC
	Local oClone := FRTCRDPSVPG_ARRAYOFLSVC():NEW()
	oClone:oWSLSVC := NIL
	If ::oWSLSVC <> NIL 
		oClone:oWSLSVC := {}
		aEval( ::oWSLSVC , { |x| aadd( oClone:oWSLSVC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTCRDPSVPG_ARRAYOFLSVC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LSVC","LSVC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLSVC , FRTCRDPSVPG_LSVC():New() )
			::oWSLSVC[len(::oWSLSVC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RECARRAY

WSSTRUCT FRTCRDPSVPG_RECARRAY
	WSDATA   oWSVERARRAY               AS FRTCRDPSVPG_ARRAYOFDADVALE
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRDPSVPG_RECARRAY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRDPSVPG_RECARRAY
Return

WSMETHOD CLONE WSCLIENT FRTCRDPSVPG_RECARRAY
	Local oClone := FRTCRDPSVPG_RECARRAY():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTCRDPSVPG_RECARRAY
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFDADVALE", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure LSVC

WSSTRUCT FRTCRDPSVPG_LSVC
	WSDATA   lRET                      AS boolean
	WSDATA   dVALIDADE                 AS date
	WSDATA   nVALOR                    AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRDPSVPG_LSVC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRDPSVPG_LSVC
Return

WSMETHOD CLONE WSCLIENT FRTCRDPSVPG_LSVC
	Local oClone := FRTCRDPSVPG_LSVC():NEW()
	oClone:lRET                 := ::lRET
	oClone:dVALIDADE            := ::dVALIDADE
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTCRDPSVPG_LSVC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lRET               :=  WSAdvValue( oResponse,"_RET","boolean",NIL,"Property lRET as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::dVALIDADE          :=  WSAdvValue( oResponse,"_VALIDADE","date",NIL,"Property dVALIDADE as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::nVALOR             :=  WSAdvValue( oResponse,"_VALOR","float",NIL,"Property nVALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFDADVALE

WSSTRUCT FRTCRDPSVPG_ARRAYOFDADVALE
	WSDATA   oWSDADVALE                AS FRTCRDPSVPG_DADVALE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRDPSVPG_ARRAYOFDADVALE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRDPSVPG_ARRAYOFDADVALE
	::oWSDADVALE           := {} // Array Of  FRTCRDPSVPG_DADVALE():New()
Return

WSMETHOD CLONE WSCLIENT FRTCRDPSVPG_ARRAYOFDADVALE
	Local oClone := FRTCRDPSVPG_ARRAYOFDADVALE():NEW()
	oClone:oWSDADVALE := NIL
	If ::oWSDADVALE <> NIL 
		oClone:oWSDADVALE := {}
		aEval( ::oWSDADVALE , { |x| aadd( oClone:oWSDADVALE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTCRDPSVPG_ARRAYOFDADVALE
	Local cSoap := ""
	aEval( ::oWSDADVALE , {|x| cSoap := cSoap  +  WSSoapValue("DADVALE", x , x , "DADVALE", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure DADVALE

WSSTRUCT FRTCRDPSVPG_DADVALE
	WSDATA   cCODVALE                  AS string
	WSDATA   lRET                      AS boolean
	WSDATA   dVALIDADE                 AS date
	WSDATA   nVALOR                    AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRDPSVPG_DADVALE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRDPSVPG_DADVALE
Return

WSMETHOD CLONE WSCLIENT FRTCRDPSVPG_DADVALE
	Local oClone := FRTCRDPSVPG_DADVALE():NEW()
	oClone:cCODVALE             := ::cCODVALE
	oClone:lRET                 := ::lRET
	oClone:dVALIDADE            := ::dVALIDADE
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTCRDPSVPG_DADVALE
	Local cSoap := ""
	cSoap += WSSoapValue("CODVALE", ::cCODVALE, ::cCODVALE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RET", ::lRET, ::lRET , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALIDADE", ::dVALIDADE, ::dVALIDADE , "date", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALOR", ::nVALOR, ::nVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


