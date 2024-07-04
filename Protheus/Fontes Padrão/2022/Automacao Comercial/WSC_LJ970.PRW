#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:107/LJGRVDADOS.apw?WSDL
Gerado em        03/11/20 16:43:21
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VTVNTMU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLJGRVDADOS
------------------------------------------------------------------------------- */

WSCLIENT WSLJGRVDADOS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GRVCANCEL
	WSMETHOD GRVCANTEF
	WSMETHOD GRVDADOSX
	WSMETHOD GRVESTORN
	WSMETHOD GRVLOGCANC
	WSMETHOD PROCESSAR
	WSMETHOD VLDLINK

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCREGISTROS               AS string
	WSDATA   cCEMP                     AS string
	WSDATA   cCFIL                     AS string
	WSDATA   oWSGRVCANCELRESULT        AS LJGRVDADOS_ARRAYOFSTRING
	WSDATA   oWSGRVCANTEFRESULT        AS LJGRVDADOS_ARRAYOFSTRING
	WSDATA   cCALIAS                   AS string
	WSDATA   cCCONFIRME                AS string
	WSDATA   cCFUNCAO                  AS string
	WSDATA   lLCNV64TO32               AS boolean
	WSDATA   lGRVDADOSXRESULT          AS boolean
	WSDATA   lGRVESTORNRESULT          AS boolean
	WSDATA   cSLXFILIAL                AS string
	WSDATA   cSLXLOCAL                 AS string
	WSDATA   cSLXPDV                   AS string
	WSDATA   cSLXOPERADOR              AS string
	WSDATA   cSLXDTMVTO                AS string
	WSDATA   cSLXHORA                  AS string
	WSDATA   cSLXCUPOM                 AS string
	WSDATA   cSLXSERIE                 AS string
	WSDATA   cSLXITEM                  AS string
	WSDATA   nSLXVALOR                 AS float
	WSDATA   cSLXPRODUTO               AS string
	WSDATA   nSLXQTDE                  AS float
	WSDATA   cSLXSUPERVI               AS string
	WSDATA   cSLXSITUA                 AS string
	WSDATA   cSLXTPCANC                AS string
	WSDATA   nSLXDESCONT               AS float
	WSDATA   nSLXALIQICM               AS float
	WSDATA   cSLXLEGENDA               AS string
	WSDATA   nSLXVLRUNT                AS float
	WSDATA   cSLXCONTDOC               AS string
	WSDATA   cSLXSITTRIB               AS string
	WSDATA   lGRVLOGCANCRESULT         AS boolean
	WSDATA   cESTACAO                  AS string
	WSDATA   cL1                       AS string
	WSDATA   cL2                       AS string
	WSDATA   cL4                       AS string
	WSDATA   cPROCESSARRESULT          AS string
	WSDATA   cVLDLINKRESULT            AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJGRVDADOS
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20190628] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJGRVDADOS
	::oWSGRVCANCELRESULT := LJGRVDADOS_ARRAYOFSTRING():New()
	::oWSGRVCANTEFRESULT := LJGRVDADOS_ARRAYOFSTRING():New()
Return

WSMETHOD RESET WSCLIENT WSLJGRVDADOS
	::cCREGISTROS        := NIL 
	::cCEMP              := NIL 
	::cCFIL              := NIL 
	::oWSGRVCANCELRESULT := NIL 
	::oWSGRVCANTEFRESULT := NIL 
	::cCALIAS            := NIL 
	::cCCONFIRME         := NIL 
	::cCFUNCAO           := NIL 
	::lLCNV64TO32        := NIL 
	::lGRVDADOSXRESULT   := NIL 
	::lGRVESTORNRESULT   := NIL 
	::cSLXFILIAL         := NIL 
	::cSLXLOCAL          := NIL 
	::cSLXPDV            := NIL 
	::cSLXOPERADOR       := NIL 
	::cSLXDTMVTO         := NIL 
	::cSLXHORA           := NIL 
	::cSLXCUPOM          := NIL 
	::cSLXSERIE          := NIL 
	::cSLXITEM           := NIL 
	::nSLXVALOR          := NIL 
	::cSLXPRODUTO        := NIL 
	::nSLXQTDE           := NIL 
	::cSLXSUPERVI        := NIL 
	::cSLXSITUA          := NIL 
	::cSLXTPCANC         := NIL 
	::nSLXDESCONT        := NIL 
	::nSLXALIQICM        := NIL 
	::cSLXLEGENDA        := NIL 
	::nSLXVLRUNT         := NIL 
	::cSLXCONTDOC        := NIL 
	::cSLXSITTRIB        := NIL 
	::lGRVLOGCANCRESULT  := NIL 
	::cESTACAO           := NIL 
	::cL1                := NIL 
	::cL2                := NIL 
	::cL4                := NIL 
	::cPROCESSARRESULT   := NIL 
	::cVLDLINKRESULT     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJGRVDADOS
Local oClone := WSLJGRVDADOS():New()
	oClone:_URL          := ::_URL 
	oClone:cCREGISTROS   := ::cCREGISTROS
	oClone:cCEMP         := ::cCEMP
	oClone:cCFIL         := ::cCFIL
	oClone:oWSGRVCANCELRESULT :=  IIF(::oWSGRVCANCELRESULT = NIL , NIL ,::oWSGRVCANCELRESULT:Clone() )
	oClone:oWSGRVCANTEFRESULT :=  IIF(::oWSGRVCANTEFRESULT = NIL , NIL ,::oWSGRVCANTEFRESULT:Clone() )
	oClone:cCALIAS       := ::cCALIAS
	oClone:cCCONFIRME    := ::cCCONFIRME
	oClone:cCFUNCAO      := ::cCFUNCAO
	oClone:lLCNV64TO32   := ::lLCNV64TO32
	oClone:lGRVDADOSXRESULT := ::lGRVDADOSXRESULT
	oClone:lGRVESTORNRESULT := ::lGRVESTORNRESULT
	oClone:cSLXFILIAL    := ::cSLXFILIAL
	oClone:cSLXLOCAL     := ::cSLXLOCAL
	oClone:cSLXPDV       := ::cSLXPDV
	oClone:cSLXOPERADOR  := ::cSLXOPERADOR
	oClone:cSLXDTMVTO    := ::cSLXDTMVTO
	oClone:cSLXHORA      := ::cSLXHORA
	oClone:cSLXCUPOM     := ::cSLXCUPOM
	oClone:cSLXSERIE     := ::cSLXSERIE
	oClone:cSLXITEM      := ::cSLXITEM
	oClone:nSLXVALOR     := ::nSLXVALOR
	oClone:cSLXPRODUTO   := ::cSLXPRODUTO
	oClone:nSLXQTDE      := ::nSLXQTDE
	oClone:cSLXSUPERVI   := ::cSLXSUPERVI
	oClone:cSLXSITUA     := ::cSLXSITUA
	oClone:cSLXTPCANC    := ::cSLXTPCANC
	oClone:nSLXDESCONT   := ::nSLXDESCONT
	oClone:nSLXALIQICM   := ::nSLXALIQICM
	oClone:cSLXLEGENDA   := ::cSLXLEGENDA
	oClone:nSLXVLRUNT    := ::nSLXVLRUNT
	oClone:cSLXCONTDOC   := ::cSLXCONTDOC
	oClone:cSLXSITTRIB   := ::cSLXSITTRIB
	oClone:lGRVLOGCANCRESULT := ::lGRVLOGCANCRESULT
	oClone:cESTACAO      := ::cESTACAO
	oClone:cL1           := ::cL1
	oClone:cL2           := ::cL2
	oClone:cL4           := ::cL4
	oClone:cPROCESSARRESULT := ::cPROCESSARRESULT
	oClone:cVLDLINKRESULT := ::cVLDLINKRESULT
Return oClone

// WSDL Method GRVCANCEL of Service WSLJGRVDADOS

WSMETHOD GRVCANCEL WSSEND cCREGISTROS,cCEMP,cCFIL WSRECEIVE oWSGRVCANCELRESULT WSCLIENT WSLJGRVDADOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRVCANCEL xmlns="http://127.0.0.1:107/">'
cSoap += WSSoapValue("CREGISTROS", ::cCREGISTROS, cCREGISTROS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMP", ::cCEMP, cCEMP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRVCANCEL>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:107/GRVCANCEL",; 
	"DOCUMENT","http://127.0.0.1:107/",,"1.031217",; 
	"http://127.0.0.1:107/LJGRVDADOS.apw")

::Init()
::oWSGRVCANCELRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GRVCANCELRESPONSE:_GRVCANCELRESULT","ARRAYOFSTRING",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GRVCANTEF of Service WSLJGRVDADOS

WSMETHOD GRVCANTEF WSSEND cCREGISTROS,cCEMP,cCFIL WSRECEIVE oWSGRVCANTEFRESULT WSCLIENT WSLJGRVDADOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRVCANTEF xmlns="http://127.0.0.1:107/">'
cSoap += WSSoapValue("CREGISTROS", ::cCREGISTROS, cCREGISTROS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMP", ::cCEMP, cCEMP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRVCANTEF>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:107/GRVCANTEF",; 
	"DOCUMENT","http://127.0.0.1:107/",,"1.031217",; 
	"http://127.0.0.1:107/LJGRVDADOS.apw")

::Init()
::oWSGRVCANTEFRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GRVCANTEFRESPONSE:_GRVCANTEFRESULT","ARRAYOFSTRING",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GRVDADOSX of Service WSLJGRVDADOS

WSMETHOD GRVDADOSX WSSEND cCREGISTROS,cCALIAS,cCCONFIRME,cCEMP,cCFIL,cCFUNCAO,lLCNV64TO32 WSRECEIVE lGRVDADOSXRESULT WSCLIENT WSLJGRVDADOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRVDADOSX xmlns="http://127.0.0.1:107/">'
cSoap += WSSoapValue("CREGISTROS", ::cCREGISTROS, cCREGISTROS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CALIAS", ::cCALIAS, cCALIAS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCONFIRME", ::cCCONFIRME, cCCONFIRME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMP", ::cCEMP, cCEMP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFUNCAO", ::cCFUNCAO, cCFUNCAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LCNV64TO32", ::lLCNV64TO32, lLCNV64TO32 , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRVDADOSX>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:107/GRVDADOSX",; 
	"DOCUMENT","http://127.0.0.1:107/",,"1.031217",; 
	"http://127.0.0.1:107/LJGRVDADOS.apw")

::Init()
::lGRVDADOSXRESULT   :=  WSAdvValue( oXmlRet,"_GRVDADOSXRESPONSE:_GRVDADOSXRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GRVESTORN of Service WSLJGRVDADOS

WSMETHOD GRVESTORN WSSEND cCREGISTROS,cCEMP,cCFIL WSRECEIVE lGRVESTORNRESULT WSCLIENT WSLJGRVDADOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRVESTORN xmlns="http://127.0.0.1:107/">'
cSoap += WSSoapValue("CREGISTROS", ::cCREGISTROS, cCREGISTROS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMP", ::cCEMP, cCEMP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRVESTORN>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:107/GRVESTORN",; 
	"DOCUMENT","http://127.0.0.1:107/",,"1.031217",; 
	"http://127.0.0.1:107/LJGRVDADOS.apw")

::Init()
::lGRVESTORNRESULT   :=  WSAdvValue( oXmlRet,"_GRVESTORNRESPONSE:_GRVESTORNRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GRVLOGCANC of Service WSLJGRVDADOS

WSMETHOD GRVLOGCANC WSSEND cCEMP,cCFIL,cSLXFILIAL,cSLXLOCAL,cSLXPDV,cSLXOPERADOR,cSLXDTMVTO,cSLXHORA,cSLXCUPOM,cSLXSERIE,cSLXITEM,nSLXVALOR,cSLXPRODUTO,nSLXQTDE,cSLXSUPERVI,cSLXSITUA,cSLXTPCANC,nSLXDESCONT,nSLXALIQICM,cSLXLEGENDA,nSLXVLRUNT,cSLXCONTDOC,cSLXSITTRIB WSRECEIVE lGRVLOGCANCRESULT WSCLIENT WSLJGRVDADOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRVLOGCANC xmlns="http://127.0.0.1:107/">'
cSoap += WSSoapValue("CEMP", ::cCEMP, cCEMP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXFILIAL", ::cSLXFILIAL, cSLXFILIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXLOCAL", ::cSLXLOCAL, cSLXLOCAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXPDV", ::cSLXPDV, cSLXPDV , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXOPERADOR", ::cSLXOPERADOR, cSLXOPERADOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXDTMVTO", ::cSLXDTMVTO, cSLXDTMVTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXHORA", ::cSLXHORA, cSLXHORA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXCUPOM", ::cSLXCUPOM, cSLXCUPOM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXSERIE", ::cSLXSERIE, cSLXSERIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXITEM", ::cSLXITEM, cSLXITEM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXVALOR", ::nSLXVALOR, nSLXVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXPRODUTO", ::cSLXPRODUTO, cSLXPRODUTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXQTDE", ::nSLXQTDE, nSLXQTDE , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXSUPERVI", ::cSLXSUPERVI, cSLXSUPERVI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXSITUA", ::cSLXSITUA, cSLXSITUA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXTPCANC", ::cSLXTPCANC, cSLXTPCANC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXDESCONT", ::nSLXDESCONT, nSLXDESCONT , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXALIQICM", ::nSLXALIQICM, nSLXALIQICM , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXLEGENDA", ::cSLXLEGENDA, cSLXLEGENDA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXVLRUNT", ::nSLXVLRUNT, nSLXVLRUNT , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXCONTDOC", ::cSLXCONTDOC, cSLXCONTDOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SLXSITTRIB", ::cSLXSITTRIB, cSLXSITTRIB , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRVLOGCANC>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:107/GRVLOGCANC",; 
	"DOCUMENT","http://127.0.0.1:107/",,"1.031217",; 
	"http://127.0.0.1:107/LJGRVDADOS.apw")

::Init()
::lGRVLOGCANCRESULT  :=  WSAdvValue( oXmlRet,"_GRVLOGCANCRESPONSE:_GRVLOGCANCRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PROCESSAR of Service WSLJGRVDADOS

WSMETHOD PROCESSAR WSSEND cESTACAO,cL1,cL2,cL4,cCFIL,cCEMP WSRECEIVE cPROCESSARRESULT WSCLIENT WSLJGRVDADOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PROCESSAR xmlns="http://127.0.0.1:107/">'
cSoap += WSSoapValue("ESTACAO", ::cESTACAO, cESTACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("L1", ::cL1, cL1 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("L2", ::cL2, cL2 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("L4", ::cL4, cL4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMP", ::cCEMP, cCEMP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PROCESSAR>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:107/PROCESSAR",; 
	"DOCUMENT","http://127.0.0.1:107/",,"1.031217",; 
	"http://127.0.0.1:107/LJGRVDADOS.apw")

::Init()
::cPROCESSARRESULT   :=  WSAdvValue( oXmlRet,"_PROCESSARRESPONSE:_PROCESSARRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VLDLINK of Service WSLJGRVDADOS

WSMETHOD VLDLINK WSSEND cESTACAO,cL1,cL2,cL4 WSRECEIVE cVLDLINKRESULT WSCLIENT WSLJGRVDADOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VLDLINK xmlns="http://127.0.0.1:107/">'
cSoap += WSSoapValue("ESTACAO", ::cESTACAO, cESTACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("L1", ::cL1, cL1 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("L2", ::cL2, cL2 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("L4", ::cL4, cL4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VLDLINK>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:107/VLDLINK",; 
	"DOCUMENT","http://127.0.0.1:107/",,"1.031217",; 
	"http://127.0.0.1:107/LJGRVDADOS.apw")

::Init()
::cVLDLINKRESULT     :=  WSAdvValue( oXmlRet,"_VLDLINKRESPONSE:_VLDLINKRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFSTRING

WSSTRUCT LJGRVDADOS_ARRAYOFSTRING
	WSDATA   cSTRING                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJGRVDADOS_ARRAYOFSTRING
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJGRVDADOS_ARRAYOFSTRING
	::cSTRING              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT LJGRVDADOS_ARRAYOFSTRING
	Local oClone := LJGRVDADOS_ARRAYOFSTRING():NEW()
	oClone:cSTRING              := IIf(::cSTRING <> NIL , aClone(::cSTRING) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJGRVDADOS_ARRAYOFSTRING
	Local oNodes1 :=  WSAdvValue( oResponse,"_STRING","string",{},NIL,.T.,"S",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::cSTRING ,  x:TEXT  ) } )
Return


