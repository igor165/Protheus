#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/DELNCC.apw?WSDL
Gerado em        09/13/21 18:57:16
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _PMYPDIL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSDELNCC
------------------------------------------------------------------------------- */

WSCLIENT WSDELNCC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD FRTDELNCC

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCBXFILIAL                AS string
	WSDATA   cCBXDOC                   AS string
	WSDATA   cCBXSERIE                 AS string
	WSDATA   cCBXCLIENTE               AS string
	WSDATA   cCBXLOJA                  AS string
	WSDATA   cCEMPPDV                  AS string
	WSDATA   cCFILPDV                  AS string
	WSDATA   lLMVLJPDVPA               AS boolean
	WSDATA   lFRTDELNCCRESULT          AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSDELNCC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSDELNCC
Return

WSMETHOD RESET WSCLIENT WSDELNCC
	::cCBXFILIAL         := NIL 
	::cCBXDOC            := NIL 
	::cCBXSERIE          := NIL 
	::cCBXCLIENTE        := NIL 
	::cCBXLOJA           := NIL 
	::cCEMPPDV           := NIL 
	::cCFILPDV           := NIL 
	::lLMVLJPDVPA        := NIL 
	::lFRTDELNCCRESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSDELNCC
Local oClone := WSDELNCC():New()
	oClone:_URL          := ::_URL 
	oClone:cCBXFILIAL    := ::cCBXFILIAL
	oClone:cCBXDOC       := ::cCBXDOC
	oClone:cCBXSERIE     := ::cCBXSERIE
	oClone:cCBXCLIENTE   := ::cCBXCLIENTE
	oClone:cCBXLOJA      := ::cCBXLOJA
	oClone:cCEMPPDV      := ::cCEMPPDV
	oClone:cCFILPDV      := ::cCFILPDV
	oClone:lLMVLJPDVPA   := ::lLMVLJPDVPA
	oClone:lFRTDELNCCRESULT := ::lFRTDELNCCRESULT
Return oClone

// WSDL Method FRTDELNCC of Service WSDELNCC

WSMETHOD FRTDELNCC WSSEND cCBXFILIAL,cCBXDOC,cCBXSERIE,cCBXCLIENTE,cCBXLOJA,cCEMPPDV,cCFILPDV,lLMVLJPDVPA WSRECEIVE lFRTDELNCCRESULT WSCLIENT WSDELNCC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FRTDELNCC xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("CBXFILIAL", ::cCBXFILIAL, cCBXFILIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CBXDOC", ::cCBXDOC, cCBXDOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CBXSERIE", ::cCBXSERIE, cCBXSERIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CBXCLIENTE", ::cCBXCLIENTE, cCBXCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CBXLOJA", ::cCBXLOJA, cCBXLOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LMVLJPDVPA", ::lLMVLJPDVPA, lLMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</FRTDELNCC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/FRTDELNCC",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/DELNCC.apw")

::Init()
::lFRTDELNCCRESULT   :=  WSAdvValue( oXmlRet,"_FRTDELNCCRESPONSE:_FRTDELNCCRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



