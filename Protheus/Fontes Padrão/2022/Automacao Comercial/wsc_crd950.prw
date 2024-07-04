#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/FRTBAIXACRD.apw?WSDL
Gerado em        09/13/21 18:52:56
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _MLCPQSH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFRTBAIXACRD
------------------------------------------------------------------------------- */

WSCLIENT WSFRTBAIXACRD

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD FRTBXCRD

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSACRDITENS              AS FRTBAIXACRD_WSCRDARRAY
	WSDATA   cCCODVALE                 AS string
	WSDATA   nNVALOR                   AS float
	WSDATA   nNTOTPAG                  AS float
	WSDATA   cCOPC                     AS string
	WSDATA   nNLINHA                   AS integer
	WSDATA   nFRTBXCRDRESULT           AS float

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSWSCRDARRAY             AS FRTBAIXACRD_WSCRDARRAY

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFRTBAIXACRD
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFRTBAIXACRD
	::oWSACRDITENS       := FRTBAIXACRD_WSCRDARRAY():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSCRDARRAY      := ::oWSACRDITENS
Return

WSMETHOD RESET WSCLIENT WSFRTBAIXACRD
	::oWSACRDITENS       := NIL 
	::cCCODVALE          := NIL 
	::nNVALOR            := NIL 
	::nNTOTPAG           := NIL 
	::cCOPC              := NIL 
	::nNLINHA            := NIL 
	::nFRTBXCRDRESULT    := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSCRDARRAY      := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFRTBAIXACRD
Local oClone := WSFRTBAIXACRD():New()
	oClone:_URL          := ::_URL 
	oClone:oWSACRDITENS  :=  IIF(::oWSACRDITENS = NIL , NIL ,::oWSACRDITENS:Clone() )
	oClone:cCCODVALE     := ::cCCODVALE
	oClone:nNVALOR       := ::nNVALOR
	oClone:nNTOTPAG      := ::nNTOTPAG
	oClone:cCOPC         := ::cCOPC
	oClone:nNLINHA       := ::nNLINHA
	oClone:nFRTBXCRDRESULT := ::nFRTBXCRDRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSWSCRDARRAY := oClone:oWSACRDITENS
Return oClone

// WSDL Method FRTBXCRD of Service WSFRTBAIXACRD

WSMETHOD FRTBXCRD WSSEND oWSACRDITENS,cCCODVALE,nNVALOR,nNTOTPAG,cCOPC,nNLINHA WSRECEIVE nFRTBXCRDRESULT WSCLIENT WSFRTBAIXACRD
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FRTBXCRD xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("ACRDITENS", ::oWSACRDITENS, oWSACRDITENS , "WSCRDARRAY", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCODVALE", ::cCCODVALE, cCCODVALE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NVALOR", ::nNVALOR, nNVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NTOTPAG", ::nNTOTPAG, nNTOTPAG , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("COPC", ::cCOPC, cCOPC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NLINHA", ::nNLINHA, nNLINHA , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</FRTBXCRD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/FRTBXCRD",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/FRTBAIXACRD.apw")

::Init()
::nFRTBXCRDRESULT    :=  WSAdvValue( oXmlRet,"_FRTBXCRDRESPONSE:_FRTBXCRDRESULT:TEXT","float",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure WSCRDARRAY

WSSTRUCT FRTBAIXACRD_WSCRDARRAY
	WSDATA   oWSVERARRAY               AS FRTBAIXACRD_ARRAYOFWSCRDITENS
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTBAIXACRD_WSCRDARRAY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTBAIXACRD_WSCRDARRAY
Return

WSMETHOD CLONE WSCLIENT FRTBAIXACRD_WSCRDARRAY
	Local oClone := FRTBAIXACRD_WSCRDARRAY():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTBAIXACRD_WSCRDARRAY
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSCRDITENS", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSCRDITENS

WSSTRUCT FRTBAIXACRD_ARRAYOFWSCRDITENS
	WSDATA   oWSWSCRDITENS             AS FRTBAIXACRD_WSCRDITENS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTBAIXACRD_ARRAYOFWSCRDITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTBAIXACRD_ARRAYOFWSCRDITENS
	::oWSWSCRDITENS        := {} // Array Of  FRTBAIXACRD_WSCRDITENS():New()
Return

WSMETHOD CLONE WSCLIENT FRTBAIXACRD_ARRAYOFWSCRDITENS
	Local oClone := FRTBAIXACRD_ARRAYOFWSCRDITENS():NEW()
	oClone:oWSWSCRDITENS := NIL
	If ::oWSWSCRDITENS <> NIL 
		oClone:oWSWSCRDITENS := {}
		aEval( ::oWSWSCRDITENS , { |x| aadd( oClone:oWSWSCRDITENS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTBAIXACRD_ARRAYOFWSCRDITENS
	Local cSoap := ""
	aEval( ::oWSWSCRDITENS , {|x| cSoap := cSoap  +  WSSoapValue("WSCRDITENS", x , x , "WSCRDITENS", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure WSCRDITENS

WSSTRUCT FRTBAIXACRD_WSCRDITENS
	WSDATA   lA                        AS boolean
	WSDATA   nB                        AS float
	WSDATA   cC                        AS string
	WSDATA   cD                        AS string
	WSDATA   cE                        AS string
	WSDATA   cF                        AS string
	WSDATA   cG                        AS string
	WSDATA   cH                        AS string
	WSDATA   cI                        AS string
	WSDATA   cJ                        AS string
	WSDATA   cL                        AS string
	WSDATA   cM                        AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTBAIXACRD_WSCRDITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTBAIXACRD_WSCRDITENS
Return

WSMETHOD CLONE WSCLIENT FRTBAIXACRD_WSCRDITENS
	Local oClone := FRTBAIXACRD_WSCRDITENS():NEW()
	oClone:lA                   := ::lA
	oClone:nB                   := ::nB
	oClone:cC                   := ::cC
	oClone:cD                   := ::cD
	oClone:cE                   := ::cE
	oClone:cF                   := ::cF
	oClone:cG                   := ::cG
	oClone:cH                   := ::cH
	oClone:cI                   := ::cI
	oClone:cJ                   := ::cJ
	oClone:cL                   := ::cL
	oClone:cM                   := ::cM
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTBAIXACRD_WSCRDITENS
	Local cSoap := ""
	cSoap += WSSoapValue("A", ::lA, ::lA , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("B", ::nB, ::nB , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("C", ::cC, ::cC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("D", ::cD, ::cD , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("E", ::cE, ::cE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("F", ::cF, ::cF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("G", ::cG, ::cG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("H", ::cH, ::cH , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("I", ::cI, ::cI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("J", ::cJ, ::cJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("L", ::cL, ::cL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("M", ::cM, ::cM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


