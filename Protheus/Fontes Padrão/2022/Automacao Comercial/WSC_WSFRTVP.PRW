
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://127.0.0.1:30/FRTVALEPRE.apw?WSDL
Gerado em        12/20/16 09:22:14
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _DMJVBJM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFRTVALEPRE
------------------------------------------------------------------------------- */

WSCLIENT WSFRTVALEPRE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD UPDRECEBTO
	WSMETHOD UPDVENDA
	WSMETHOD VALORVALE
	WSMETHOD VLDVALE
	WSMETHOD VPESTORNA

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCODIGO                  AS string
	WSDATA   cCCAIXA                   AS string
	WSDATA   cCDOC                     AS string
	WSDATA   cCESTACAO                 AS string
	WSDATA   cCPDV                     AS string
	WSDATA   dDDATA                    AS date
	WSDATA   cCHORA                    AS string
	WSDATA   cCCLIENTE                 AS string
	WSDATA   cCLOJA                    AS string
	WSDATA   cCSERIE                   AS string
	WSDATA   cCEMPPDV                  AS string
	WSDATA   cCFILPDV                  AS string
	WSDATA   cUPDRECEBTORESULT         AS string
	WSDATA   cCVEND                    AS string
	WSDATA   cUPDVENDARESULT           AS string
	WSDATA   oWSVALEPRE                AS FRTVALEPRE_WSVALEPRE
	WSDATA   nVALORVALERESULT          AS float
	WSDATA   cVLDVALERESULT            AS string
	WSDATA   oWSAVPREEST               AS FRTVALEPRE_WSVALEARRAY
	WSDATA   cVPESTORNARESULT          AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSWSVALEPRE              AS FRTVALEPRE_WSVALEPRE
	WSDATA   oWSWSVALEARRAY            AS FRTVALEPRE_WSVALEARRAY

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFRTVALEPRE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160707 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFRTVALEPRE
	::oWSVALEPRE         := FRTVALEPRE_WSVALEPRE():New()
	::oWSAVPREEST        := FRTVALEPRE_WSVALEARRAY():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSVALEPRE       := ::oWSVALEPRE
	::oWSWSVALEARRAY     := ::oWSAVPREEST
Return

WSMETHOD RESET WSCLIENT WSFRTVALEPRE
	::cCCODIGO           := NIL 
	::cCCAIXA            := NIL 
	::cCDOC              := NIL 
	::cCESTACAO          := NIL 
	::cCPDV              := NIL 
	::dDDATA             := NIL 
	::cCHORA             := NIL 
	::cCCLIENTE          := NIL 
	::cCLOJA             := NIL 
	::cCSERIE            := NIL 
	::cCEMPPDV           := NIL 
	::cCFILPDV           := NIL 
	::cUPDRECEBTORESULT  := NIL 
	::cCVEND             := NIL 
	::cUPDVENDARESULT    := NIL 
	::oWSVALEPRE         := NIL 
	::nVALORVALERESULT   := NIL 
	::cVLDVALERESULT     := NIL 
	::oWSAVPREEST        := NIL 
	::cVPESTORNARESULT   := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSVALEPRE       := NIL
	::oWSWSVALEARRAY     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFRTVALEPRE
Local oClone := WSFRTVALEPRE():New()
	oClone:_URL          := ::_URL 
	oClone:cCCODIGO      := ::cCCODIGO
	oClone:cCCAIXA       := ::cCCAIXA
	oClone:cCDOC         := ::cCDOC
	oClone:cCESTACAO     := ::cCESTACAO
	oClone:cCPDV         := ::cCPDV
	oClone:dDDATA        := ::dDDATA
	oClone:cCHORA        := ::cCHORA
	oClone:cCCLIENTE     := ::cCCLIENTE
	oClone:cCLOJA        := ::cCLOJA
	oClone:cCSERIE       := ::cCSERIE
	oClone:cCEMPPDV      := ::cCEMPPDV
	oClone:cCFILPDV      := ::cCFILPDV
	oClone:cUPDRECEBTORESULT := ::cUPDRECEBTORESULT
	oClone:cCVEND        := ::cCVEND
	oClone:cUPDVENDARESULT := ::cUPDVENDARESULT
	oClone:oWSVALEPRE    :=  IIF(::oWSVALEPRE = NIL , NIL ,::oWSVALEPRE:Clone() )
	oClone:nVALORVALERESULT := ::nVALORVALERESULT
	oClone:cVLDVALERESULT := ::cVLDVALERESULT
	oClone:oWSAVPREEST   :=  IIF(::oWSAVPREEST = NIL , NIL ,::oWSAVPREEST:Clone() )
	oClone:cVPESTORNARESULT := ::cVPESTORNARESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSWSVALEPRE  := oClone:oWSVALEPRE
	oClone:oWSWSVALEARRAY := oClone:oWSAVPREEST
Return oClone

// WSDL Method UPDRECEBTO of Service WSFRTVALEPRE

WSMETHOD UPDRECEBTO WSSEND cCCODIGO,cCCAIXA,cCDOC,cCESTACAO,cCPDV,dDDATA,cCHORA,cCCLIENTE,cCLOJA,cCSERIE,cCEMPPDV,cCFILPDV WSRECEIVE cUPDRECEBTORESULT WSCLIENT WSFRTVALEPRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<UPDRECEBTO xmlns="http://127.0.0.1:30/">'
cSoap += WSSoapValue("CCODIGO", ::cCCODIGO, cCCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCAIXA", ::cCCAIXA, cCCAIXA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDOC", ::cCDOC, cCDOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CESTACAO", ::cCESTACAO, cCESTACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATA", ::dDDATA, dDDATA , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CHORA", ::cCHORA, cCHORA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLOJA", ::cCLOJA, cCLOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</UPDRECEBTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:30/UPDRECEBTO",; 
	"DOCUMENT","http://127.0.0.1:30/",,"1.031217",; 
	"http://127.0.0.1:30/FRTVALEPRE.apw")

::Init()
::cUPDRECEBTORESULT  :=  WSAdvValue( oXmlRet,"_UPDRECEBTORESPONSE:_UPDRECEBTORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method UPDVENDA of Service WSFRTVALEPRE

WSMETHOD UPDVENDA WSSEND cCCODIGO,cCVEND,cCDOC,cCESTACAO,cCPDV,dDDATA,cCHORA,cCCLIENTE,cCLOJA,cCSERIE,cCEMPPDV,cCFILPDV WSRECEIVE cUPDVENDARESULT WSCLIENT WSFRTVALEPRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<UPDVENDA xmlns="http://127.0.0.1:30/">'
cSoap += WSSoapValue("CCODIGO", ::cCCODIGO, cCCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CVEND", ::cCVEND, cCVEND , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDOC", ::cCDOC, cCDOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CESTACAO", ::cCESTACAO, cCESTACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATA", ::dDDATA, dDDATA , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CHORA", ::cCHORA, cCHORA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLOJA", ::cCLOJA, cCLOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</UPDVENDA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:30/UPDVENDA",; 
	"DOCUMENT","http://127.0.0.1:30/",,"1.031217",; 
	"http://127.0.0.1:30/FRTVALEPRE.apw")

::Init()
::cUPDVENDARESULT    :=  WSAdvValue( oXmlRet,"_UPDVENDARESPONSE:_UPDVENDARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VALORVALE of Service WSFRTVALEPRE

WSMETHOD VALORVALE WSSEND oWSVALEPRE,cCEMPPDV,cCFILPDV WSRECEIVE nVALORVALERESULT WSCLIENT WSFRTVALEPRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VALORVALE xmlns="http://127.0.0.1:30/">'
cSoap += WSSoapValue("VALEPRE", ::oWSVALEPRE, oWSVALEPRE , "WSVALEPRE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VALORVALE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:30/VALORVALE",; 
	"DOCUMENT","http://127.0.0.1:30/",,"1.031217",; 
	"http://127.0.0.1:30/FRTVALEPRE.apw")

::Init()
::nVALORVALERESULT   :=  WSAdvValue( oXmlRet,"_VALORVALERESPONSE:_VALORVALERESULT:TEXT","float",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VLDVALE of Service WSFRTVALEPRE

WSMETHOD VLDVALE WSSEND oWSVALEPRE,cCEMPPDV,cCFILPDV WSRECEIVE cVLDVALERESULT WSCLIENT WSFRTVALEPRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VLDVALE xmlns="http://127.0.0.1:30/">'
cSoap += WSSoapValue("VALEPRE", ::oWSVALEPRE, oWSVALEPRE , "WSVALEPRE", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VLDVALE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:30/VLDVALE",; 
	"DOCUMENT","http://127.0.0.1:30/",,"1.031217",; 
	"http://127.0.0.1:30/FRTVALEPRE.apw")

::Init()
::cVLDVALERESULT     :=  WSAdvValue( oXmlRet,"_VLDVALERESPONSE:_VLDVALERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VPESTORNA of Service WSFRTVALEPRE

WSMETHOD VPESTORNA WSSEND oWSAVPREEST,cCEMPPDV,cCFILPDV WSRECEIVE cVPESTORNARESULT WSCLIENT WSFRTVALEPRE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VPESTORNA xmlns="http://127.0.0.1:30/">'
cSoap += WSSoapValue("AVPREEST", ::oWSAVPREEST, oWSAVPREEST , "WSVALEARRAY", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VPESTORNA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:30/VPESTORNA",; 
	"DOCUMENT","http://127.0.0.1:30/",,"1.031217",; 
	"http://127.0.0.1:30/FRTVALEPRE.apw")

::Init()
::cVPESTORNARESULT   :=  WSAdvValue( oXmlRet,"_VPESTORNARESPONSE:_VPESTORNARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure WSVALEPRE

WSSTRUCT FRTVALEPRE_WSVALEPRE
	WSDATA   cCODIGO                   AS string
	WSDATA   nOPERACAO                 AS float
	WSDATA   cPRODUTO                  AS string
	WSDATA   nVALOR                    AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTVALEPRE_WSVALEPRE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTVALEPRE_WSVALEPRE
Return

WSMETHOD CLONE WSCLIENT FRTVALEPRE_WSVALEPRE
	Local oClone := FRTVALEPRE_WSVALEPRE():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:nOPERACAO            := ::nOPERACAO
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTVALEPRE_WSVALEPRE
	Local cSoap := ""
	cSoap += WSSoapValue("CODIGO", ::cCODIGO, ::cCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OPERACAO", ::nOPERACAO, ::nOPERACAO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRODUTO", ::cPRODUTO, ::cPRODUTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALOR", ::nVALOR, ::nVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSVALEARRAY

WSSTRUCT FRTVALEPRE_WSVALEARRAY
	WSDATA   oWSVERARRAY               AS FRTVALEPRE_ARRAYOFWSVPREEST
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTVALEPRE_WSVALEARRAY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTVALEPRE_WSVALEARRAY
Return

WSMETHOD CLONE WSCLIENT FRTVALEPRE_WSVALEARRAY
	Local oClone := FRTVALEPRE_WSVALEARRAY():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTVALEPRE_WSVALEARRAY
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSVPREEST", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSVPREEST

WSSTRUCT FRTVALEPRE_ARRAYOFWSVPREEST
	WSDATA   oWSWSVPREEST              AS FRTVALEPRE_WSVPREEST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTVALEPRE_ARRAYOFWSVPREEST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTVALEPRE_ARRAYOFWSVPREEST
	::oWSWSVPREEST         := {} // Array Of  FRTVALEPRE_WSVPREEST():New()
Return

WSMETHOD CLONE WSCLIENT FRTVALEPRE_ARRAYOFWSVPREEST
	Local oClone := FRTVALEPRE_ARRAYOFWSVPREEST():NEW()
	oClone:oWSWSVPREEST := NIL
	If ::oWSWSVPREEST <> NIL 
		oClone:oWSWSVPREEST := {}
		aEval( ::oWSWSVPREEST , { |x| aadd( oClone:oWSWSVPREEST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTVALEPRE_ARRAYOFWSVPREEST
	Local cSoap := ""
	aEval( ::oWSWSVPREEST , {|x| cSoap := cSoap  +  WSSoapValue("WSVPREEST", x , x , "WSVPREEST", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure WSVPREEST

WSSTRUCT FRTVALEPRE_WSVPREEST
	WSDATA   cCCODIGO                  AS string
	WSDATA   cCOPERACAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTVALEPRE_WSVPREEST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTVALEPRE_WSVPREEST
Return

WSMETHOD CLONE WSCLIENT FRTVALEPRE_WSVPREEST
	Local oClone := FRTVALEPRE_WSVPREEST():NEW()
	oClone:cCCODIGO             := ::cCCODIGO
	oClone:cCOPERACAO           := ::cCOPERACAO
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTVALEPRE_WSVPREEST
	Local cSoap := ""
	cSoap += WSSoapValue("CCODIGO", ::cCCODIGO, ::cCCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COPERACAO", ::cCOPERACAO, ::cCOPERACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


