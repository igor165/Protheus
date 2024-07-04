#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:86/WSINTRMSOLUM.apw?WSDL
Gerado em        07/09/13 18:08:05
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _YJSGXVV ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSINTRMSOLUM
------------------------------------------------------------------------------- */

WSCLIENT WSWSINTRMSOLUM

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETVERSION

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cVERSION                  AS string
	WSDATA   oWSGETVERSIONRESULT       AS WSINTRMSOLUM_STRESULT

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSINTRMSOLUM
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130604] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSINTRMSOLUM
	::oWSGETVERSIONRESULT := WSINTRMSOLUM_STRESULT():New()
Return

WSMETHOD RESET WSCLIENT WSWSINTRMSOLUM
	::cVERSION           := NIL 
	::oWSGETVERSIONRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSINTRMSOLUM
Local oClone := WSWSINTRMSOLUM():New()
	oClone:_URL          := ::_URL 
	oClone:cVERSION      := ::cVERSION
	oClone:oWSGETVERSIONRESULT :=  IIF(::oWSGETVERSIONRESULT = NIL , NIL ,::oWSGETVERSIONRESULT:Clone() )
Return oClone

// WSDL Method GETVERSION of Service WSWSINTRMSOLUM

WSMETHOD GETVERSION WSSEND cVERSION WSRECEIVE oWSGETVERSIONRESULT WSCLIENT WSWSINTRMSOLUM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETVERSION xmlns="http://webservices.totvs.com.br/wsintrmsolum.apw">'
cSoap += WSSoapValue("VERSION", ::cVERSION, cVERSION , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETVERSION>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.totvs.com.br/wsintrmsolum.apw/GETVERSION",; 
	"DOCUMENT","http://webservices.totvs.com.br/wsintrmsolum.apw",,"1.031217",; 
	"http://localhost:86/WSINTRMSOLUM.apw")

::Init()
::oWSGETVERSIONRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETVERSIONRESPONSE:_GETVERSIONRESULT","STRESULT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STRESULT

WSSTRUCT WSINTRMSOLUM_STRESULT
	WSDATA   oWSASOURCES               AS WSINTRMSOLUM_ARRAYOFSTSOURCE
	WSDATA   cSVERSION                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINTRMSOLUM_STRESULT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINTRMSOLUM_STRESULT
Return

WSMETHOD CLONE WSCLIENT WSINTRMSOLUM_STRESULT
	Local oClone := WSINTRMSOLUM_STRESULT():NEW()
	oClone:oWSASOURCES          := IIF(::oWSASOURCES = NIL , NIL , ::oWSASOURCES:Clone() )
	oClone:cSVERSION            := ::cSVERSION
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINTRMSOLUM_STRESULT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ASOURCES","ARRAYOFSTSOURCE",NIL,"Property oWSASOURCES as s0:ARRAYOFSTSOURCE on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSASOURCES := WSINTRMSOLUM_ARRAYOFSTSOURCE():New()
		::oWSASOURCES:SoapRecv(oNode1)
	EndIf
	::cSVERSION          :=  WSAdvValue( oResponse,"_SVERSION","string",NIL,"Property cSVERSION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFSTSOURCE

WSSTRUCT WSINTRMSOLUM_ARRAYOFSTSOURCE
	WSDATA   oWSSTSOURCE               AS WSINTRMSOLUM_STSOURCE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINTRMSOLUM_ARRAYOFSTSOURCE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINTRMSOLUM_ARRAYOFSTSOURCE
	::oWSSTSOURCE          := {} // Array Of  WSINTRMSOLUM_STSOURCE():New()
Return

WSMETHOD CLONE WSCLIENT WSINTRMSOLUM_ARRAYOFSTSOURCE
	Local oClone := WSINTRMSOLUM_ARRAYOFSTSOURCE():NEW()
	oClone:oWSSTSOURCE := NIL
	If ::oWSSTSOURCE <> NIL 
		oClone:oWSSTSOURCE := {}
		aEval( ::oWSSTSOURCE , { |x| aadd( oClone:oWSSTSOURCE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINTRMSOLUM_ARRAYOFSTSOURCE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STSOURCE","STSOURCE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTSOURCE , WSINTRMSOLUM_STSOURCE():New() )
			::oWSSTSOURCE[len(::oWSSTSOURCE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STSOURCE

WSSTRUCT WSINTRMSOLUM_STSOURCE
	WSDATA   cSDATE                    AS string
	WSDATA   cSISSUE                   AS string
	WSDATA   cSLATESTDATE              AS string
	WSDATA   cSSOURCE                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINTRMSOLUM_STSOURCE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINTRMSOLUM_STSOURCE
Return

WSMETHOD CLONE WSCLIENT WSINTRMSOLUM_STSOURCE
	Local oClone := WSINTRMSOLUM_STSOURCE():NEW()
	oClone:cSDATE               := ::cSDATE
	oClone:cSISSUE              := ::cSISSUE
	oClone:cSLATESTDATE         := ::cSLATESTDATE
	oClone:cSSOURCE             := ::cSSOURCE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINTRMSOLUM_STSOURCE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSDATE             :=  WSAdvValue( oResponse,"_SDATE","string",NIL,"Property cSDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSISSUE            :=  WSAdvValue( oResponse,"_SISSUE","string",NIL,"Property cSISSUE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSLATESTDATE       :=  WSAdvValue( oResponse,"_SLATESTDATE","string",NIL,"Property cSLATESTDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSSOURCE           :=  WSAdvValue( oResponse,"_SSOURCE","string",NIL,"Property cSSOURCE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


