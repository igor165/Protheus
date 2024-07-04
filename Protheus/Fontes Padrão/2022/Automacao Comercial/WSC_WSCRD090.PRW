#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/CRDLIMCRED.apw?WSDL
Gerado em        09/13/21 19:22:34
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FQRQYNH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCRDLIMCRED
------------------------------------------------------------------------------- */

WSCLIENT WSCRDLIMCRED

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETLIMCRED

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSRSESSIONID             AS string
	WSDATA   nNTIPO                    AS integer
	WSDATA   cCENTRADA                 AS string
	WSDATA   oWSGETLIMCREDRESULT       AS CRDLIMCRED_ARRAYOFWSLIMCRED

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCRDLIMCRED
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCRDLIMCRED
	::oWSGETLIMCREDRESULT := CRDLIMCRED_ARRAYOFWSLIMCRED():New()
Return

WSMETHOD RESET WSCLIENT WSCRDLIMCRED
	::cUSRSESSIONID      := NIL 
	::nNTIPO             := NIL 
	::cCENTRADA          := NIL 
	::oWSGETLIMCREDRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCRDLIMCRED
Local oClone := WSCRDLIMCRED():New()
	oClone:_URL          := ::_URL 
	oClone:cUSRSESSIONID := ::cUSRSESSIONID
	oClone:nNTIPO        := ::nNTIPO
	oClone:cCENTRADA     := ::cCENTRADA
	oClone:oWSGETLIMCREDRESULT :=  IIF(::oWSGETLIMCREDRESULT = NIL , NIL ,::oWSGETLIMCREDRESULT:Clone() )
Return oClone

// WSDL Method GETLIMCRED of Service WSCRDLIMCRED

WSMETHOD GETLIMCRED WSSEND cUSRSESSIONID,nNTIPO,cCENTRADA WSRECEIVE oWSGETLIMCREDRESULT WSCLIENT WSCRDLIMCRED
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETLIMCRED xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("USRSESSIONID", ::cUSRSESSIONID, cUSRSESSIONID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NTIPO", ::nNTIPO, nNTIPO , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CENTRADA", ::cCENTRADA, cCENTRADA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETLIMCRED>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/GETLIMCRED",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/CRDLIMCRED.apw")

::Init()
::oWSGETLIMCREDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETLIMCREDRESPONSE:_GETLIMCREDRESULT","ARRAYOFWSLIMCRED",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFWSLIMCRED

WSSTRUCT CRDLIMCRED_ARRAYOFWSLIMCRED
	WSDATA   oWSWSLIMCRED              AS CRDLIMCRED_WSLIMCRED OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CRDLIMCRED_ARRAYOFWSLIMCRED
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CRDLIMCRED_ARRAYOFWSLIMCRED
	::oWSWSLIMCRED         := {} // Array Of  CRDLIMCRED_WSLIMCRED():New()
Return

WSMETHOD CLONE WSCLIENT CRDLIMCRED_ARRAYOFWSLIMCRED
	Local oClone := CRDLIMCRED_ARRAYOFWSLIMCRED():NEW()
	oClone:oWSWSLIMCRED := NIL
	If ::oWSWSLIMCRED <> NIL 
		oClone:oWSWSLIMCRED := {}
		aEval( ::oWSWSLIMCRED , { |x| aadd( oClone:oWSWSLIMCRED , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CRDLIMCRED_ARRAYOFWSLIMCRED
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSLIMCRED","WSLIMCRED",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSLIMCRED , CRDLIMCRED_WSLIMCRED():New() )
			::oWSWSLIMCRED[len(::oWSWSLIMCRED)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure WSLIMCRED

WSSTRUCT CRDLIMCRED_WSLIMCRED
	WSDATA   nLIMCRED                  AS float
	WSDATA   nLIMUSD                   AS float
	WSDATA   cNOME                     AS string
	WSDATA   cRETORNO                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CRDLIMCRED_WSLIMCRED
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CRDLIMCRED_WSLIMCRED
Return

WSMETHOD CLONE WSCLIENT CRDLIMCRED_WSLIMCRED
	Local oClone := CRDLIMCRED_WSLIMCRED():NEW()
	oClone:nLIMCRED             := ::nLIMCRED
	oClone:nLIMUSD              := ::nLIMUSD
	oClone:cNOME                := ::cNOME
	oClone:cRETORNO             := ::cRETORNO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CRDLIMCRED_WSLIMCRED
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nLIMCRED           :=  WSAdvValue( oResponse,"_LIMCRED","float",NIL,"Property nLIMCRED as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLIMUSD            :=  WSAdvValue( oResponse,"_LIMUSD","float",NIL,"Property nLIMUSD as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRETORNO           :=  WSAdvValue( oResponse,"_RETORNO","string",NIL,"Property cRETORNO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


