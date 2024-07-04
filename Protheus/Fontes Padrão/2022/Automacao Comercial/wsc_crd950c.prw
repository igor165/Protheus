#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/FRTCRD.apw?WSDL
Gerado em        09/13/21 18:56:19
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OYPGQTR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFRTCRD
------------------------------------------------------------------------------- */

WSCLIENT WSFRTCRD

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CRDATFIN
	WSMETHOD CRDCRITERI
	WSMETHOD CRDPONTCLI
	WSMETHOD CRDVERCART

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   dDDTINICAM                AS date
	WSDATA   dDDTFINCAM                AS date
	WSDATA   cCCLIENTE                 AS string
	WSDATA   cCLOJACLI                 AS string
	WSDATA   lLRET                     AS boolean
	WSDATA   oWSCRDATFINRESULT         AS FRTCRD_ARRAYOFLSTFIN
	WSDATA   oWSCRDCRITERIRESULT       AS FRTCRD_ARRAYOFCRDESTRCRI
	WSDATA   cCCODCAM                  AS string
	WSDATA   lLACPONTO                 AS boolean
	WSDATA   nCRDPONTCLIRESULT         AS integer
	WSDATA   cCCARTAO                  AS string
	WSDATA   lCRDVERCARTRESULT         AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFRTCRD
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFRTCRD
	::oWSCRDATFINRESULT  := FRTCRD_ARRAYOFLSTFIN():New()
	::oWSCRDCRITERIRESULT := FRTCRD_ARRAYOFCRDESTRCRI():New()
Return

WSMETHOD RESET WSCLIENT WSFRTCRD
	::dDDTINICAM         := NIL 
	::dDDTFINCAM         := NIL 
	::cCCLIENTE          := NIL 
	::cCLOJACLI          := NIL 
	::lLRET              := NIL 
	::oWSCRDATFINRESULT  := NIL 
	::oWSCRDCRITERIRESULT := NIL 
	::cCCODCAM           := NIL 
	::lLACPONTO          := NIL 
	::nCRDPONTCLIRESULT  := NIL 
	::cCCARTAO           := NIL 
	::lCRDVERCARTRESULT  := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFRTCRD
Local oClone := WSFRTCRD():New()
	oClone:_URL          := ::_URL 
	oClone:dDDTINICAM    := ::dDDTINICAM
	oClone:dDDTFINCAM    := ::dDDTFINCAM
	oClone:cCCLIENTE     := ::cCCLIENTE
	oClone:cCLOJACLI     := ::cCLOJACLI
	oClone:lLRET         := ::lLRET
	oClone:oWSCRDATFINRESULT :=  IIF(::oWSCRDATFINRESULT = NIL , NIL ,::oWSCRDATFINRESULT:Clone() )
	oClone:oWSCRDCRITERIRESULT :=  IIF(::oWSCRDCRITERIRESULT = NIL , NIL ,::oWSCRDCRITERIRESULT:Clone() )
	oClone:cCCODCAM      := ::cCCODCAM
	oClone:lLACPONTO     := ::lLACPONTO
	oClone:nCRDPONTCLIRESULT := ::nCRDPONTCLIRESULT
	oClone:cCCARTAO      := ::cCCARTAO
	oClone:lCRDVERCARTRESULT := ::lCRDVERCARTRESULT
Return oClone

// WSDL Method CRDATFIN of Service WSFRTCRD

WSMETHOD CRDATFIN WSSEND dDDTINICAM,dDDTFINCAM,cCCLIENTE,cCLOJACLI,lLRET WSRECEIVE oWSCRDATFINRESULT WSCLIENT WSFRTCRD
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CRDATFIN xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("DDTINICAM", ::dDDTINICAM, dDDTINICAM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDTFINCAM", ::dDDTFINCAM, dDDTFINCAM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLOJACLI", ::cCLOJACLI, cCLOJACLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LRET", ::lLRET, lLRET , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CRDATFIN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CRDATFIN",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/FRTCRD.apw")

::Init()
::oWSCRDATFINRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CRDATFINRESPONSE:_CRDATFINRESULT","ARRAYOFLSTFIN",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CRDCRITERI of Service WSFRTCRD

WSMETHOD CRDCRITERI WSSEND cCCLIENTE WSRECEIVE oWSCRDCRITERIRESULT WSCLIENT WSFRTCRD
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CRDCRITERI xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CRDCRITERI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CRDCRITERI",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/FRTCRD.apw")

::Init()
::oWSCRDCRITERIRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CRDCRITERIRESPONSE:_CRDCRITERIRESULT","ARRAYOFCRDESTRCRI",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CRDPONTCLI of Service WSFRTCRD

WSMETHOD CRDPONTCLI WSSEND cCCLIENTE,cCLOJACLI,cCCODCAM,lLACPONTO WSRECEIVE nCRDPONTCLIRESULT WSCLIENT WSFRTCRD
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CRDPONTCLI xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLOJACLI", ::cCLOJACLI, cCLOJACLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCODCAM", ::cCCODCAM, cCCODCAM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LACPONTO", ::lLACPONTO, lLACPONTO , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CRDPONTCLI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CRDPONTCLI",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/FRTCRD.apw")

::Init()
::nCRDPONTCLIRESULT  :=  WSAdvValue( oXmlRet,"_CRDPONTCLIRESPONSE:_CRDPONTCLIRESULT:TEXT","integer",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CRDVERCART of Service WSFRTCRD

WSMETHOD CRDVERCART WSSEND cCCARTAO,cCCLIENTE,cCLOJACLI WSRECEIVE lCRDVERCARTRESULT WSCLIENT WSFRTCRD
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CRDVERCART xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("CCARTAO", ::cCCARTAO, cCCARTAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLOJACLI", ::cCLOJACLI, cCLOJACLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CRDVERCART>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CRDVERCART",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/FRTCRD.apw")

::Init()
::lCRDVERCARTRESULT  :=  WSAdvValue( oXmlRet,"_CRDVERCARTRESPONSE:_CRDVERCARTRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFLSTFIN

WSSTRUCT FRTCRD_ARRAYOFLSTFIN
	WSDATA   oWSLSTFIN                 AS FRTCRD_LSTFIN OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRD_ARRAYOFLSTFIN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRD_ARRAYOFLSTFIN
	::oWSLSTFIN            := {} // Array Of  FRTCRD_LSTFIN():New()
Return

WSMETHOD CLONE WSCLIENT FRTCRD_ARRAYOFLSTFIN
	Local oClone := FRTCRD_ARRAYOFLSTFIN():NEW()
	oClone:oWSLSTFIN := NIL
	If ::oWSLSTFIN <> NIL 
		oClone:oWSLSTFIN := {}
		aEval( ::oWSLSTFIN , { |x| aadd( oClone:oWSLSTFIN , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTCRD_ARRAYOFLSTFIN
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LSTFIN","LSTFIN",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLSTFIN , FRTCRD_LSTFIN():New() )
			::oWSLSTFIN[len(::oWSLSTFIN)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFCRDESTRCRI

WSSTRUCT FRTCRD_ARRAYOFCRDESTRCRI
	WSDATA   oWSCRDESTRCRI             AS FRTCRD_CRDESTRCRI OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRD_ARRAYOFCRDESTRCRI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRD_ARRAYOFCRDESTRCRI
	::oWSCRDESTRCRI        := {} // Array Of  FRTCRD_CRDESTRCRI():New()
Return

WSMETHOD CLONE WSCLIENT FRTCRD_ARRAYOFCRDESTRCRI
	Local oClone := FRTCRD_ARRAYOFCRDESTRCRI():NEW()
	oClone:oWSCRDESTRCRI := NIL
	If ::oWSCRDESTRCRI <> NIL 
		oClone:oWSCRDESTRCRI := {}
		aEval( ::oWSCRDESTRCRI , { |x| aadd( oClone:oWSCRDESTRCRI , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTCRD_ARRAYOFCRDESTRCRI
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CRDESTRCRI","CRDESTRCRI",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCRDESTRCRI , FRTCRD_CRDESTRCRI():New() )
			::oWSCRDESTRCRI[len(::oWSCRDESTRCRI)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure LSTFIN

WSSTRUCT FRTCRD_LSTFIN
	WSDATA   cCTIPMEN                  AS string
	WSDATA   lLRET                     AS boolean
	WSDATA   lLTEMCOMP                 AS boolean
	WSDATA   lLUNICOMP                 AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRD_LSTFIN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRD_LSTFIN
Return

WSMETHOD CLONE WSCLIENT FRTCRD_LSTFIN
	Local oClone := FRTCRD_LSTFIN():NEW()
	oClone:cCTIPMEN             := ::cCTIPMEN
	oClone:lLRET                := ::lLRET
	oClone:lLTEMCOMP            := ::lLTEMCOMP
	oClone:lLUNICOMP            := ::lLUNICOMP
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTCRD_LSTFIN
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCTIPMEN           :=  WSAdvValue( oResponse,"_CTIPMEN","string",NIL,"Property cCTIPMEN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lLRET              :=  WSAdvValue( oResponse,"_LRET","boolean",NIL,"Property lLRET as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lLTEMCOMP          :=  WSAdvValue( oResponse,"_LTEMCOMP","boolean",NIL,"Property lLTEMCOMP as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lLUNICOMP          :=  WSAdvValue( oResponse,"_LUNICOMP","boolean",NIL,"Property lLUNICOMP as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure CRDESTRCRI

WSSTRUCT FRTCRD_CRDESTRCRI
	WSDATA   oWSACRITERIO              AS FRTCRD_ARRAYOFESTACRI OPTIONAL
	WSDATA   cCCODCAM                  AS string
	WSDATA   dCDTFINCAM                AS date
	WSDATA   dCDTINICAM                AS date
	WSDATA   lLRET                     AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRD_CRDESTRCRI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRD_CRDESTRCRI
Return

WSMETHOD CLONE WSCLIENT FRTCRD_CRDESTRCRI
	Local oClone := FRTCRD_CRDESTRCRI():NEW()
	oClone:oWSACRITERIO         := IIF(::oWSACRITERIO = NIL , NIL , ::oWSACRITERIO:Clone() )
	oClone:cCCODCAM             := ::cCCODCAM
	oClone:dCDTFINCAM           := ::dCDTFINCAM
	oClone:dCDTINICAM           := ::dCDTINICAM
	oClone:lLRET                := ::lLRET
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTCRD_CRDESTRCRI
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ACRITERIO","ARRAYOFESTACRI",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSACRITERIO := FRTCRD_ARRAYOFESTACRI():New()
		::oWSACRITERIO:SoapRecv(oNode1)
	EndIf
	::cCCODCAM           :=  WSAdvValue( oResponse,"_CCODCAM","string",NIL,"Property cCCODCAM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dCDTFINCAM         :=  WSAdvValue( oResponse,"_CDTFINCAM","date",NIL,"Property dCDTFINCAM as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dCDTINICAM         :=  WSAdvValue( oResponse,"_CDTINICAM","date",NIL,"Property dCDTINICAM as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lLRET              :=  WSAdvValue( oResponse,"_LRET","boolean",NIL,"Property lLRET as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFESTACRI

WSSTRUCT FRTCRD_ARRAYOFESTACRI
	WSDATA   oWSESTACRI                AS FRTCRD_ESTACRI OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRD_ARRAYOFESTACRI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRD_ARRAYOFESTACRI
	::oWSESTACRI           := {} // Array Of  FRTCRD_ESTACRI():New()
Return

WSMETHOD CLONE WSCLIENT FRTCRD_ARRAYOFESTACRI
	Local oClone := FRTCRD_ARRAYOFESTACRI():NEW()
	oClone:oWSESTACRI := NIL
	If ::oWSESTACRI <> NIL 
		oClone:oWSESTACRI := {}
		aEval( ::oWSESTACRI , { |x| aadd( oClone:oWSESTACRI , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTCRD_ARRAYOFESTACRI
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ESTACRI","ESTACRI",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSESTACRI , FRTCRD_ESTACRI():New() )
			::oWSESTACRI[len(::oWSESTACRI)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ESTACRI

WSSTRUCT FRTCRD_ESTACRI
	WSDATA   cCODCAM                   AS string
	WSDATA   cPERDES                   AS string
	WSDATA   nPONTOS                   AS integer
	WSDATA   cPRECO                    AS string
	WSDATA   cPRODUTO                  AS string
	WSDATA   cSEQUEM                   AS string
	WSDATA   cTIPO                     AS string
	WSDATA   cVALOR                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRD_ESTACRI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRD_ESTACRI
Return

WSMETHOD CLONE WSCLIENT FRTCRD_ESTACRI
	Local oClone := FRTCRD_ESTACRI():NEW()
	oClone:cCODCAM              := ::cCODCAM
	oClone:cPERDES              := ::cPERDES
	oClone:nPONTOS              := ::nPONTOS
	oClone:cPRECO               := ::cPRECO
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:cSEQUEM              := ::cSEQUEM
	oClone:cTIPO                := ::cTIPO
	oClone:cVALOR               := ::cVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTCRD_ESTACRI
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODCAM            :=  WSAdvValue( oResponse,"_CODCAM","string",NIL,"Property cCODCAM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPERDES            :=  WSAdvValue( oResponse,"_PERDES","string",NIL,"Property cPERDES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nPONTOS            :=  WSAdvValue( oResponse,"_PONTOS","integer",NIL,"Property nPONTOS as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPRECO             :=  WSAdvValue( oResponse,"_PRECO","string",NIL,"Property cPRECO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPRODUTO           :=  WSAdvValue( oResponse,"_PRODUTO","string",NIL,"Property cPRODUTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSEQUEM            :=  WSAdvValue( oResponse,"_SEQUEM","string",NIL,"Property cSEQUEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVALOR             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,"Property cVALOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


