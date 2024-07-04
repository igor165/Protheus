#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://ipt-ricardo:85/WSINCLUNCC.apw?WSDL
Generado en        02/21/11 18:31:10
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.101007
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _LVZALPT ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSINCLUNCC
------------------------------------------------------------------------------- */

WSCLIENT WSWSINCLUNCC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD INCNVTIT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   nNVALORNCC                AS float
	WSDATA   cCL1DOC                   AS string
	WSDATA   cCEMPPDV                  AS string
	WSDATA   cCSEREST                  AS string
	WSDATA   cCL1SERIE                 AS string
	WSDATA   cCL1OPER                  AS string
	WSDATA   dDL1EMISNF                AS date
	WSDATA   cCL1CLIENTE               AS string
	WSDATA   cCL1LOJA                  AS string
	WSDATA   cCFILPDV                  AS string
	WSDATA   dDDATVALID                AS date
	WSDATA   lLMVLJPDVPA               AS boolean
	WSDATA   lINCNVTITRESULT           AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSINCLUNCC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20100901] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSINCLUNCC
Return

WSMETHOD RESET WSCLIENT WSWSINCLUNCC
	::nNVALORNCC         := NIL 
	::cCL1DOC            := NIL 
	::cCEMPPDV           := NIL 
	::cCSEREST           := NIL 
	::cCL1SERIE          := NIL 
	::cCL1OPER           := NIL 
	::dDL1EMISNF         := NIL 
	::cCL1CLIENTE        := NIL 
	::cCL1LOJA           := NIL 
	::cCFILPDV           := NIL 
	::dDDATVALID         := NIL 
	::lLMVLJPDVPA        := NIL 
	::lINCNVTITRESULT    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSINCLUNCC
Local oClone := WSWSINCLUNCC():New()
	oClone:_URL          := ::_URL 
	oClone:nNVALORNCC    := ::nNVALORNCC
	oClone:cCL1DOC       := ::cCL1DOC
	oClone:cCEMPPDV      := ::cCEMPPDV
	oClone:cCSEREST      := ::cCSEREST
	oClone:cCL1SERIE     := ::cCL1SERIE
	oClone:cCL1OPER      := ::cCL1OPER
	oClone:dDL1EMISNF    := ::dDL1EMISNF
	oClone:cCL1CLIENTE   := ::cCL1CLIENTE
	oClone:cCL1LOJA      := ::cCL1LOJA
	oClone:cCFILPDV      := ::cCFILPDV
	oClone:dDDATVALID    := ::dDDATVALID
	oClone:lLMVLJPDVPA   := ::lLMVLJPDVPA
	oClone:lINCNVTITRESULT := ::lINCNVTITRESULT
Return oClone

// WSDL Method INCNVTIT of Service WSWSINCLUNCC

WSMETHOD INCNVTIT WSSEND nNVALORNCC,cCL1DOC,cCEMPPDV,cCSEREST,cCL1SERIE,cCL1OPER,dDL1EMISNF,cCL1CLIENTE,cCL1LOJA,cCFILPDV,dDDATVALID,lLMVLJPDVPA WSRECEIVE lINCNVTITRESULT WSCLIENT WSWSINCLUNCC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCNVTIT xmlns="http://ipt-ricardo:85/">'
cSoap += WSSoapValue("NVALORNCC", ::nNVALORNCC, nNVALORNCC , "float", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CL1DOC", ::cCL1DOC, cCL1DOC , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CSEREST", ::cCSEREST, cCSEREST , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CL1SERIE", ::cCL1SERIE, cCL1SERIE , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CL1OPER", ::cCL1OPER, cCL1OPER , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("DL1EMISNF", ::dDL1EMISNF, dDL1EMISNF , "date", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CL1CLIENTE", ::cCL1CLIENTE, cCL1CLIENTE , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CL1LOJA", ::cCL1LOJA, cCL1LOJA , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("DDATVALID", ::dDDATVALID, dDDATVALID , "date", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("LMVLJPDVPA", ::lLMVLJPDVPA, lLMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .T.) 
cSoap += "</INCNVTIT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-ricardo:85/INCNVTIT",; 
	"DOCUMENT","http://ipt-ricardo:85/",,"1.031217",; 
	"http://ipt-ricardo:85/WSINCLUNCC.apw")

::Init()
::lINCNVTITRESULT    :=  WSAdvValue( oXmlRet,"_INCNVTITRESPONSE:_INCNVTITRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



