#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://127.0.0.1:90/FRTPAFECF.apw?WSDL
Gerado em        08/11/17 16:54:56
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _CNSSYRS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFRTPAFECF
------------------------------------------------------------------------------- */

WSCLIENT WSFRTPAFECF

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD LERCRZCRO
	WSMETHOD LSTDAVEMIT
	WSMETHOD LSTDOCEMIT
	WSMETHOD LSTESTOQUE
	WSMETHOD LSTINFOPDV
	WSMETHOD LSTITCANC
	WSMETHOD LSTITENS
	WSMETHOD LSTITVDMANU
	WSMETHOD LSTMEPAGTO
	WSMETHOD LSTPAGCANC
	WSMETHOD LSTPDVS
	WSMETHOD LSTPRODUTO
	WSMETHOD LSTREDZ
	WSMETHOD LSTTRCCARD
	WSMETHOD LSTVENDAS
	WSMETHOD LSTVENDEST
	WSMETHOD LSTVNDCANC
	WSMETHOD LSTVNDCPF
	WSMETHOD LSTVNDMANU

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCPDV                     AS string
	WSDATA   cCEMPPDV                  AS string
	WSDATA   cCFILPDV                  AS string
	WSDATA   lLHOMOLPAF                AS boolean
	WSDATA   oWSLERCRZCRORESULT        AS FRTPAFECF_ARRAYOFSTRING
	WSDATA   dDDATAINI                 AS date
	WSDATA   dDDATAFIM                 AS date
	WSDATA   oWSLSTDAVEMITRESULT       AS FRTPAFECF_ARRAYOFDAVLIST
	WSDATA   oWSLSTDOCEMITRESULT       AS FRTPAFECF_ARRAYOFDOCLIST
	WSDATA   oWSAPRODUTOS              AS FRTPAFECF_OLSTPROD
	WSDATA   lLUPDATEETQ               AS boolean
	WSDATA   nNPAGINA                  AS integer
	WSDATA   cCCODPROD                 AS string
	WSDATA   oWSLSTESTOQUERESULT       AS FRTPAFECF_ARRAYOFESTLIST
	WSDATA   oWSLSTINFOPDVRESULT       AS FRTPAFECF_ARRAYOFLSTINFOPDV
	WSDATA   cCINICUP                  AS string
	WSDATA   oWSLSTITCANCRESULT        AS FRTPAFECF_ARRAYOFITVNDLIST
	WSDATA   oWSLSTITENSRESULT         AS FRTPAFECF_ARRAYOFITVNDLIST
	WSDATA   cCINIDOC                  AS string
	WSDATA   oWSLSTITVDMANURESULT      AS FRTPAFECF_ARRAYOFITVNDNFMNNF
	WSDATA   lLFILTRANFE               AS boolean
	WSDATA   lLISR07                   AS boolean
	WSDATA   oWSLSTMEPAGTORESULT       AS FRTPAFECF_ARRAYOFMEIPGTLIST
	WSDATA   oWSLSTPAGCANCRESULT       AS FRTPAFECF_ARRAYOFMEIPGTLIST
	WSDATA   cCFIELDRET                AS string
	WSDATA   cCSERIEPDV                AS string
	WSDATA   oWSLSTPDVSRESULT          AS FRTPAFECF_ARRAYOFSTRING
	WSDATA   oWSLSTPRODUTORESULT       AS FRTPAFECF_ARRAYOFPRODLIST
	WSDATA   lLDATARED                 AS boolean
	WSDATA   oWSLSTREDZRESULT          AS FRTPAFECF_ARRAYOFREDZLIST
	WSDATA   oWSLSTTRCCARDRESULT       AS FRTPAFECF_ARRAYOFTRCCRDLIST
	WSDATA   oWSLSTVENDASRESULT        AS FRTPAFECF_ARRAYOFVENDALIST
	WSDATA   oWSLSTVENDESTRESULT       AS FRTPAFECF_ARRAYOFLSTESTINFO
	WSDATA   oWSLSTVNDCANCRESULT       AS FRTPAFECF_ARRAYOFVENDALIST
	WSDATA   cCPFCPNJ                  AS string
	WSDATA   oWSLSTVNDCPFRESULT        AS FRTPAFECF_ARRAYOFVNDSIDENT
	WSDATA   oWSLSTVNDMANURESULT       AS FRTPAFECF_ARRAYOFVNDNFMNNF

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSOLSTPROD               AS FRTPAFECF_OLSTPROD

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFRTPAFECF
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170519 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFRTPAFECF
	::oWSLERCRZCRORESULT := FRTPAFECF_ARRAYOFSTRING():New()
	::oWSLSTDAVEMITRESULT := FRTPAFECF_ARRAYOFDAVLIST():New()
	::oWSLSTDOCEMITRESULT := FRTPAFECF_ARRAYOFDOCLIST():New()
	::oWSAPRODUTOS       := FRTPAFECF_OLSTPROD():New()
	::oWSLSTESTOQUERESULT := FRTPAFECF_ARRAYOFESTLIST():New()
	::oWSLSTINFOPDVRESULT := FRTPAFECF_ARRAYOFLSTINFOPDV():New()
	::oWSLSTITCANCRESULT := FRTPAFECF_ARRAYOFITVNDLIST():New()
	::oWSLSTITENSRESULT  := FRTPAFECF_ARRAYOFITVNDLIST():New()
	::oWSLSTITVDMANURESULT := FRTPAFECF_ARRAYOFITVNDNFMNNF():New()
	::oWSLSTMEPAGTORESULT := FRTPAFECF_ARRAYOFMEIPGTLIST():New()
	::oWSLSTPAGCANCRESULT := FRTPAFECF_ARRAYOFMEIPGTLIST():New()
	::oWSLSTPDVSRESULT   := FRTPAFECF_ARRAYOFSTRING():New()
	::oWSLSTPRODUTORESULT := FRTPAFECF_ARRAYOFPRODLIST():New()
	::oWSLSTREDZRESULT   := FRTPAFECF_ARRAYOFREDZLIST():New()
	::oWSLSTTRCCARDRESULT := FRTPAFECF_ARRAYOFTRCCRDLIST():New()
	::oWSLSTVENDASRESULT := FRTPAFECF_ARRAYOFVENDALIST():New()
	::oWSLSTVENDESTRESULT := FRTPAFECF_ARRAYOFLSTESTINFO():New()
	::oWSLSTVNDCANCRESULT := FRTPAFECF_ARRAYOFVENDALIST():New()
	::oWSLSTVNDCPFRESULT := FRTPAFECF_ARRAYOFVNDSIDENT():New()
	::oWSLSTVNDMANURESULT := FRTPAFECF_ARRAYOFVNDNFMNNF():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSOLSTPROD        := ::oWSAPRODUTOS
Return

WSMETHOD RESET WSCLIENT WSFRTPAFECF
	::cCPDV              := NIL 
	::cCEMPPDV           := NIL 
	::cCFILPDV           := NIL 
	::lLHOMOLPAF         := NIL 
	::oWSLERCRZCRORESULT := NIL 
	::dDDATAINI          := NIL 
	::dDDATAFIM          := NIL 
	::oWSLSTDAVEMITRESULT := NIL 
	::oWSLSTDOCEMITRESULT := NIL 
	::oWSAPRODUTOS       := NIL 
	::lLUPDATEETQ        := NIL 
	::nNPAGINA           := NIL 
	::cCCODPROD          := NIL 
	::oWSLSTESTOQUERESULT := NIL 
	::oWSLSTINFOPDVRESULT := NIL 
	::cCINICUP           := NIL 
	::oWSLSTITCANCRESULT := NIL 
	::oWSLSTITENSRESULT  := NIL 
	::cCINIDOC           := NIL 
	::oWSLSTITVDMANURESULT := NIL 
	::lLFILTRANFE        := NIL 
	::lLISR07            := NIL 
	::oWSLSTMEPAGTORESULT := NIL 
	::oWSLSTPAGCANCRESULT := NIL 
	::cCFIELDRET         := NIL 
	::cCSERIEPDV         := NIL 
	::oWSLSTPDVSRESULT   := NIL 
	::oWSLSTPRODUTORESULT := NIL 
	::lLDATARED          := NIL 
	::oWSLSTREDZRESULT   := NIL 
	::oWSLSTTRCCARDRESULT := NIL 
	::oWSLSTVENDASRESULT := NIL 
	::oWSLSTVENDESTRESULT := NIL 
	::oWSLSTVNDCANCRESULT := NIL 
	::cCPFCPNJ           := NIL 
	::oWSLSTVNDCPFRESULT := NIL 
	::oWSLSTVNDMANURESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSOLSTPROD        := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFRTPAFECF
Local oClone := WSFRTPAFECF():New()
	oClone:_URL          := ::_URL 
	oClone:cCPDV         := ::cCPDV
	oClone:cCEMPPDV      := ::cCEMPPDV
	oClone:cCFILPDV      := ::cCFILPDV
	oClone:lLHOMOLPAF    := ::lLHOMOLPAF
	oClone:oWSLERCRZCRORESULT :=  IIF(::oWSLERCRZCRORESULT = NIL , NIL ,::oWSLERCRZCRORESULT:Clone() )
	oClone:dDDATAINI     := ::dDDATAINI
	oClone:dDDATAFIM     := ::dDDATAFIM
	oClone:oWSLSTDAVEMITRESULT :=  IIF(::oWSLSTDAVEMITRESULT = NIL , NIL ,::oWSLSTDAVEMITRESULT:Clone() )
	oClone:oWSLSTDOCEMITRESULT :=  IIF(::oWSLSTDOCEMITRESULT = NIL , NIL ,::oWSLSTDOCEMITRESULT:Clone() )
	oClone:oWSAPRODUTOS  :=  IIF(::oWSAPRODUTOS = NIL , NIL ,::oWSAPRODUTOS:Clone() )
	oClone:lLUPDATEETQ   := ::lLUPDATEETQ
	oClone:nNPAGINA      := ::nNPAGINA
	oClone:cCCODPROD     := ::cCCODPROD
	oClone:oWSLSTESTOQUERESULT :=  IIF(::oWSLSTESTOQUERESULT = NIL , NIL ,::oWSLSTESTOQUERESULT:Clone() )
	oClone:oWSLSTINFOPDVRESULT :=  IIF(::oWSLSTINFOPDVRESULT = NIL , NIL ,::oWSLSTINFOPDVRESULT:Clone() )
	oClone:cCINICUP      := ::cCINICUP
	oClone:oWSLSTITCANCRESULT :=  IIF(::oWSLSTITCANCRESULT = NIL , NIL ,::oWSLSTITCANCRESULT:Clone() )
	oClone:oWSLSTITENSRESULT :=  IIF(::oWSLSTITENSRESULT = NIL , NIL ,::oWSLSTITENSRESULT:Clone() )
	oClone:cCINIDOC      := ::cCINIDOC
	oClone:oWSLSTITVDMANURESULT :=  IIF(::oWSLSTITVDMANURESULT = NIL , NIL ,::oWSLSTITVDMANURESULT:Clone() )
	oClone:lLFILTRANFE   := ::lLFILTRANFE
	oClone:lLISR07       := ::lLISR07
	oClone:oWSLSTMEPAGTORESULT :=  IIF(::oWSLSTMEPAGTORESULT = NIL , NIL ,::oWSLSTMEPAGTORESULT:Clone() )
	oClone:oWSLSTPAGCANCRESULT :=  IIF(::oWSLSTPAGCANCRESULT = NIL , NIL ,::oWSLSTPAGCANCRESULT:Clone() )
	oClone:cCFIELDRET    := ::cCFIELDRET
	oClone:cCSERIEPDV    := ::cCSERIEPDV
	oClone:oWSLSTPDVSRESULT :=  IIF(::oWSLSTPDVSRESULT = NIL , NIL ,::oWSLSTPDVSRESULT:Clone() )
	oClone:oWSLSTPRODUTORESULT :=  IIF(::oWSLSTPRODUTORESULT = NIL , NIL ,::oWSLSTPRODUTORESULT:Clone() )
	oClone:lLDATARED     := ::lLDATARED
	oClone:oWSLSTREDZRESULT :=  IIF(::oWSLSTREDZRESULT = NIL , NIL ,::oWSLSTREDZRESULT:Clone() )
	oClone:oWSLSTTRCCARDRESULT :=  IIF(::oWSLSTTRCCARDRESULT = NIL , NIL ,::oWSLSTTRCCARDRESULT:Clone() )
	oClone:oWSLSTVENDASRESULT :=  IIF(::oWSLSTVENDASRESULT = NIL , NIL ,::oWSLSTVENDASRESULT:Clone() )
	oClone:oWSLSTVENDESTRESULT :=  IIF(::oWSLSTVENDESTRESULT = NIL , NIL ,::oWSLSTVENDESTRESULT:Clone() )
	oClone:oWSLSTVNDCANCRESULT :=  IIF(::oWSLSTVNDCANCRESULT = NIL , NIL ,::oWSLSTVNDCANCRESULT:Clone() )
	oClone:cCPFCPNJ      := ::cCPFCPNJ
	oClone:oWSLSTVNDCPFRESULT :=  IIF(::oWSLSTVNDCPFRESULT = NIL , NIL ,::oWSLSTVNDCPFRESULT:Clone() )
	oClone:oWSLSTVNDMANURESULT :=  IIF(::oWSLSTVNDMANURESULT = NIL , NIL ,::oWSLSTVNDMANURESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSOLSTPROD   := oClone:oWSAPRODUTOS
Return oClone

// WSDL Method LERCRZCRO of Service WSFRTPAFECF

WSMETHOD LERCRZCRO WSSEND cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF WSRECEIVE oWSLERCRZCRORESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LERCRZCRO xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LERCRZCRO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LERCRZCRO",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLERCRZCRORESULT:SoapRecv( WSAdvValue( oXmlRet,"_LERCRZCRORESPONSE:_LERCRZCRORESULT","ARRAYOFSTRING",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTDAVEMIT of Service WSFRTPAFECF

WSMETHOD LSTDAVEMIT WSSEND dDDATAINI,dDDATAFIM,cCEMPPDV,cCFILPDV,lLHOMOLPAF WSRECEIVE oWSLSTDAVEMITRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTDAVEMIT xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTDAVEMIT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTDAVEMIT",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTDAVEMITRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTDAVEMITRESPONSE:_LSTDAVEMITRESULT","ARRAYOFDAVLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTDOCEMIT of Service WSFRTPAFECF

WSMETHOD LSTDOCEMIT WSSEND dDDATAINI,dDDATAFIM,cCEMPPDV,cCFILPDV,lLHOMOLPAF,cCPDV WSRECEIVE oWSLSTDOCEMITRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTDOCEMIT xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTDOCEMIT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTDOCEMIT",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTDOCEMITRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTDOCEMITRESPONSE:_LSTDOCEMITRESULT","ARRAYOFDOCLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTESTOQUE of Service WSFRTPAFECF

WSMETHOD LSTESTOQUE WSSEND cCEMPPDV,cCFILPDV,oWSAPRODUTOS,lLHOMOLPAF,lLUPDATEETQ,nNPAGINA,cCCODPROD WSRECEIVE oWSLSTESTOQUERESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTESTOQUE xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("APRODUTOS", ::oWSAPRODUTOS, oWSAPRODUTOS , "OLSTPROD", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LUPDATEETQ", ::lLUPDATEETQ, lLUPDATEETQ , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NPAGINA", ::nNPAGINA, nNPAGINA , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCODPROD", ::cCCODPROD, cCCODPROD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTESTOQUE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTESTOQUE",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTESTOQUERESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTESTOQUERESPONSE:_LSTESTOQUERESULT","ARRAYOFESTLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTINFOPDV of Service WSFRTPAFECF

WSMETHOD LSTINFOPDV WSSEND cCEMPPDV,cCFILPDV,cCPDV WSRECEIVE oWSLSTINFOPDVRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTINFOPDV xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTINFOPDV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTINFOPDV",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTINFOPDVRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTINFOPDVRESPONSE:_LSTINFOPDVRESULT","ARRAYOFLSTINFOPDV",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTITCANC of Service WSFRTPAFECF

WSMETHOD LSTITCANC WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,cCINICUP WSRECEIVE oWSLSTITCANCRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTITCANC xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CINICUP", ::cCINICUP, cCINICUP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTITCANC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTITCANC",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTITCANCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTITCANCRESPONSE:_LSTITCANCRESULT","ARRAYOFITVNDLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTITENS of Service WSFRTPAFECF

WSMETHOD LSTITENS WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,cCINICUP WSRECEIVE oWSLSTITENSRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTITENS xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CINICUP", ::cCINICUP, cCINICUP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTITENS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTITENS",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTITENSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTITENSRESPONSE:_LSTITENSRESULT","ARRAYOFITVNDLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTITVDMANU of Service WSFRTPAFECF

WSMETHOD LSTITVDMANU WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,cCINIDOC WSRECEIVE oWSLSTITVDMANURESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTITVDMANU xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CINIDOC", ::cCINIDOC, cCINIDOC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTITVDMANU>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTITVDMANU",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTITVDMANURESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTITVDMANURESPONSE:_LSTITVDMANURESULT","ARRAYOFITVNDNFMNNF",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTMEPAGTO of Service WSFRTPAFECF

WSMETHOD LSTMEPAGTO WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,lLFILTRANFE,lLISR07 WSRECEIVE oWSLSTMEPAGTORESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTMEPAGTO xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LFILTRANFE", ::lLFILTRANFE, lLFILTRANFE , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LISR07", ::lLISR07, lLISR07 , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTMEPAGTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTMEPAGTO",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTMEPAGTORESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTMEPAGTORESPONSE:_LSTMEPAGTORESULT","ARRAYOFMEIPGTLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTPAGCANC of Service WSFRTPAFECF

WSMETHOD LSTPAGCANC WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,cCINICUP WSRECEIVE oWSLSTPAGCANCRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTPAGCANC xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CINICUP", ::cCINICUP, cCINICUP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTPAGCANC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTPAGCANC",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTPAGCANCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTPAGCANCRESPONSE:_LSTPAGCANCRESULT","ARRAYOFMEIPGTLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTPDVS of Service WSFRTPAFECF

WSMETHOD LSTPDVS WSSEND cCEMPPDV,cCFILPDV,cCFIELDRET,lLHOMOLPAF,cCPDV,cCSERIEPDV WSRECEIVE oWSLSTPDVSRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTPDVS xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFIELDRET", ::cCFIELDRET, cCFIELDRET , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CSERIEPDV", ::cCSERIEPDV, cCSERIEPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTPDVS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTPDVS",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTPDVSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTPDVSRESPONSE:_LSTPDVSRESULT","ARRAYOFSTRING",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTPRODUTO of Service WSFRTPAFECF

WSMETHOD LSTPRODUTO WSSEND cCEMPPDV,cCFILPDV,lLHOMOLPAF,nNPAGINA,cCCODPROD WSRECEIVE oWSLSTPRODUTORESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTPRODUTO xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NPAGINA", ::nNPAGINA, nNPAGINA , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCODPROD", ::cCCODPROD, cCCODPROD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTPRODUTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTPRODUTO",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTPRODUTORESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTPRODUTORESPONSE:_LSTPRODUTORESULT","ARRAYOFPRODLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTREDZ of Service WSFRTPAFECF

WSMETHOD LSTREDZ WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,lLDATARED WSRECEIVE oWSLSTREDZRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTREDZ xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LDATARED", ::lLDATARED, lLDATARED , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTREDZ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTREDZ",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTREDZRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTREDZRESPONSE:_LSTREDZRESULT","ARRAYOFREDZLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTTRCCARD of Service WSFRTPAFECF

WSMETHOD LSTTRCCARD WSSEND dDDATAINI,dDDATAFIM,cCEMPPDV,cCFILPDV,lLHOMOLPAF WSRECEIVE oWSLSTTRCCARDRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTTRCCARD xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTTRCCARD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTTRCCARD",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTTRCCARDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTTRCCARDRESPONSE:_LSTTRCCARDRESULT","ARRAYOFTRCCRDLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTVENDAS of Service WSFRTPAFECF

WSMETHOD LSTVENDAS WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,cCINICUP WSRECEIVE oWSLSTVENDASRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTVENDAS xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CINICUP", ::cCINICUP, cCINICUP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTVENDAS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTVENDAS",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTVENDASRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTVENDASRESPONSE:_LSTVENDASRESULT","ARRAYOFVENDALIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTVENDEST of Service WSFRTPAFECF

WSMETHOD LSTVENDEST WSSEND dDDATAINI,dDDATAFIM,cCEMPPDV,cCFILPDV,lLHOMOLPAF WSRECEIVE oWSLSTVENDESTRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTVENDEST xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTVENDEST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTVENDEST",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTVENDESTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTVENDESTRESPONSE:_LSTVENDESTRESULT","ARRAYOFLSTESTINFO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTVNDCANC of Service WSFRTPAFECF

WSMETHOD LSTVNDCANC WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,cCINICUP WSRECEIVE oWSLSTVNDCANCRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTVNDCANC xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CINICUP", ::cCINICUP, cCINICUP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTVNDCANC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTVNDCANC",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTVNDCANCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTVNDCANCRESPONSE:_LSTVNDCANCRESULT","ARRAYOFVENDALIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTVNDCPF of Service WSFRTPAFECF

WSMETHOD LSTVNDCPF WSSEND dDDATAINI,dDDATAFIM,cCEMPPDV,cCFILPDV,cCPFCPNJ,lLHOMOLPAF WSRECEIVE oWSLSTVNDCPFRESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTVNDCPF xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPFCPNJ", ::cCPFCPNJ, cCPFCPNJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTVNDCPF>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTVNDCPF",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTVNDCPFRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTVNDCPFRESPONSE:_LSTVNDCPFRESULT","ARRAYOFVNDSIDENT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LSTVNDMANU of Service WSFRTPAFECF

WSMETHOD LSTVNDMANU WSSEND dDDATAINI,dDDATAFIM,cCPDV,cCEMPPDV,cCFILPDV,lLHOMOLPAF,cCINIDOC WSRECEIVE oWSLSTVNDMANURESULT WSCLIENT WSFRTPAFECF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LSTVNDMANU xmlns="http://127.0.0.1:90/">'
cSoap += WSSoapValue("DDATAINI", ::dDDATAINI, dDDATAINI , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATAFIM", ::dDDATAFIM, dDDATAFIM , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPDV", ::cCPDV, cCPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LHOMOLPAF", ::lLHOMOLPAF, lLHOMOLPAF , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CINIDOC", ::cCINIDOC, cCINIDOC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LSTVNDMANU>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:90/LSTVNDMANU",; 
	"DOCUMENT","http://127.0.0.1:90/",,"1.031217",; 
	"http://127.0.0.1:90/FRTPAFECF.apw")

::Init()
::oWSLSTVNDMANURESULT:SoapRecv( WSAdvValue( oXmlRet,"_LSTVNDMANURESPONSE:_LSTVNDMANURESULT","ARRAYOFVNDNFMNNF",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFSTRING

WSSTRUCT FRTPAFECF_ARRAYOFSTRING
	WSDATA   cSTRING                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFSTRING
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFSTRING
	::cSTRING              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFSTRING
	Local oClone := FRTPAFECF_ARRAYOFSTRING():NEW()
	oClone:cSTRING              := IIf(::cSTRING <> NIL , aClone(::cSTRING) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFSTRING
	Local oNodes1 :=  WSAdvValue( oResponse,"_STRING","string",{},NIL,.T.,"S",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::cSTRING ,  x:TEXT  ) } )
Return

// WSDL Data Structure ARRAYOFDAVLIST

WSSTRUCT FRTPAFECF_ARRAYOFDAVLIST
	WSDATA   oWSDAVLIST                AS FRTPAFECF_DAVLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFDAVLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFDAVLIST
	::oWSDAVLIST           := {} // Array Of  FRTPAFECF_DAVLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFDAVLIST
	Local oClone := FRTPAFECF_ARRAYOFDAVLIST():NEW()
	oClone:oWSDAVLIST := NIL
	If ::oWSDAVLIST <> NIL 
		oClone:oWSDAVLIST := {}
		aEval( ::oWSDAVLIST , { |x| aadd( oClone:oWSDAVLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFDAVLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DAVLIST","DAVLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDAVLIST , FRTPAFECF_DAVLIST():New() )
			::oWSDAVLIST[len(::oWSDAVLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFDOCLIST

WSSTRUCT FRTPAFECF_ARRAYOFDOCLIST
	WSDATA   oWSDOCLIST                AS FRTPAFECF_DOCLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFDOCLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFDOCLIST
	::oWSDOCLIST           := {} // Array Of  FRTPAFECF_DOCLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFDOCLIST
	Local oClone := FRTPAFECF_ARRAYOFDOCLIST():NEW()
	oClone:oWSDOCLIST := NIL
	If ::oWSDOCLIST <> NIL 
		oClone:oWSDOCLIST := {}
		aEval( ::oWSDOCLIST , { |x| aadd( oClone:oWSDOCLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFDOCLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DOCLIST","DOCLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDOCLIST , FRTPAFECF_DOCLIST():New() )
			::oWSDOCLIST[len(::oWSDOCLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure OLSTPROD

WSSTRUCT FRTPAFECF_OLSTPROD
	WSDATA   oWSACODPRODUTO            AS FRTPAFECF_ARRAYOFCODPROD OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_OLSTPROD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_OLSTPROD
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_OLSTPROD
	Local oClone := FRTPAFECF_OLSTPROD():NEW()
	oClone:oWSACODPRODUTO       := IIF(::oWSACODPRODUTO = NIL , NIL , ::oWSACODPRODUTO:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTPAFECF_OLSTPROD
	Local cSoap := ""
	cSoap += WSSoapValue("ACODPRODUTO", ::oWSACODPRODUTO, ::oWSACODPRODUTO , "ARRAYOFCODPROD", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFESTLIST

WSSTRUCT FRTPAFECF_ARRAYOFESTLIST
	WSDATA   oWSESTLIST                AS FRTPAFECF_ESTLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFESTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFESTLIST
	::oWSESTLIST           := {} // Array Of  FRTPAFECF_ESTLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFESTLIST
	Local oClone := FRTPAFECF_ARRAYOFESTLIST():NEW()
	oClone:oWSESTLIST := NIL
	If ::oWSESTLIST <> NIL 
		oClone:oWSESTLIST := {}
		aEval( ::oWSESTLIST , { |x| aadd( oClone:oWSESTLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFESTLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ESTLIST","ESTLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSESTLIST , FRTPAFECF_ESTLIST():New() )
			::oWSESTLIST[len(::oWSESTLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFLSTINFOPDV

WSSTRUCT FRTPAFECF_ARRAYOFLSTINFOPDV
	WSDATA   oWSLSTINFOPDV             AS FRTPAFECF_LSTINFOPDV OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFLSTINFOPDV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFLSTINFOPDV
	::oWSLSTINFOPDV        := {} // Array Of  FRTPAFECF_LSTINFOPDV():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFLSTINFOPDV
	Local oClone := FRTPAFECF_ARRAYOFLSTINFOPDV():NEW()
	oClone:oWSLSTINFOPDV := NIL
	If ::oWSLSTINFOPDV <> NIL 
		oClone:oWSLSTINFOPDV := {}
		aEval( ::oWSLSTINFOPDV , { |x| aadd( oClone:oWSLSTINFOPDV , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFLSTINFOPDV
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LSTINFOPDV","LSTINFOPDV",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLSTINFOPDV , FRTPAFECF_LSTINFOPDV():New() )
			::oWSLSTINFOPDV[len(::oWSLSTINFOPDV)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFITVNDLIST

WSSTRUCT FRTPAFECF_ARRAYOFITVNDLIST
	WSDATA   oWSITVNDLIST              AS FRTPAFECF_ITVNDLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFITVNDLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFITVNDLIST
	::oWSITVNDLIST         := {} // Array Of  FRTPAFECF_ITVNDLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFITVNDLIST
	Local oClone := FRTPAFECF_ARRAYOFITVNDLIST():NEW()
	oClone:oWSITVNDLIST := NIL
	If ::oWSITVNDLIST <> NIL 
		oClone:oWSITVNDLIST := {}
		aEval( ::oWSITVNDLIST , { |x| aadd( oClone:oWSITVNDLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFITVNDLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITVNDLIST","ITVNDLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSITVNDLIST , FRTPAFECF_ITVNDLIST():New() )
			::oWSITVNDLIST[len(::oWSITVNDLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFITVNDNFMNNF

WSSTRUCT FRTPAFECF_ARRAYOFITVNDNFMNNF
	WSDATA   oWSITVNDNFMNNF            AS FRTPAFECF_ITVNDNFMNNF OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFITVNDNFMNNF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFITVNDNFMNNF
	::oWSITVNDNFMNNF       := {} // Array Of  FRTPAFECF_ITVNDNFMNNF():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFITVNDNFMNNF
	Local oClone := FRTPAFECF_ARRAYOFITVNDNFMNNF():NEW()
	oClone:oWSITVNDNFMNNF := NIL
	If ::oWSITVNDNFMNNF <> NIL 
		oClone:oWSITVNDNFMNNF := {}
		aEval( ::oWSITVNDNFMNNF , { |x| aadd( oClone:oWSITVNDNFMNNF , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFITVNDNFMNNF
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITVNDNFMNNF","ITVNDNFMNNF",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSITVNDNFMNNF , FRTPAFECF_ITVNDNFMNNF():New() )
			::oWSITVNDNFMNNF[len(::oWSITVNDNFMNNF)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFMEIPGTLIST

WSSTRUCT FRTPAFECF_ARRAYOFMEIPGTLIST
	WSDATA   oWSMEIPGTLIST             AS FRTPAFECF_MEIPGTLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFMEIPGTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFMEIPGTLIST
	::oWSMEIPGTLIST        := {} // Array Of  FRTPAFECF_MEIPGTLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFMEIPGTLIST
	Local oClone := FRTPAFECF_ARRAYOFMEIPGTLIST():NEW()
	oClone:oWSMEIPGTLIST := NIL
	If ::oWSMEIPGTLIST <> NIL 
		oClone:oWSMEIPGTLIST := {}
		aEval( ::oWSMEIPGTLIST , { |x| aadd( oClone:oWSMEIPGTLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFMEIPGTLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_MEIPGTLIST","MEIPGTLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSMEIPGTLIST , FRTPAFECF_MEIPGTLIST():New() )
			::oWSMEIPGTLIST[len(::oWSMEIPGTLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFPRODLIST

WSSTRUCT FRTPAFECF_ARRAYOFPRODLIST
	WSDATA   oWSPRODLIST               AS FRTPAFECF_PRODLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFPRODLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFPRODLIST
	::oWSPRODLIST          := {} // Array Of  FRTPAFECF_PRODLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFPRODLIST
	Local oClone := FRTPAFECF_ARRAYOFPRODLIST():NEW()
	oClone:oWSPRODLIST := NIL
	If ::oWSPRODLIST <> NIL 
		oClone:oWSPRODLIST := {}
		aEval( ::oWSPRODLIST , { |x| aadd( oClone:oWSPRODLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFPRODLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PRODLIST","PRODLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPRODLIST , FRTPAFECF_PRODLIST():New() )
			::oWSPRODLIST[len(::oWSPRODLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFREDZLIST

WSSTRUCT FRTPAFECF_ARRAYOFREDZLIST
	WSDATA   oWSREDZLIST               AS FRTPAFECF_REDZLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFREDZLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFREDZLIST
	::oWSREDZLIST          := {} // Array Of  FRTPAFECF_REDZLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFREDZLIST
	Local oClone := FRTPAFECF_ARRAYOFREDZLIST():NEW()
	oClone:oWSREDZLIST := NIL
	If ::oWSREDZLIST <> NIL 
		oClone:oWSREDZLIST := {}
		aEval( ::oWSREDZLIST , { |x| aadd( oClone:oWSREDZLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFREDZLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_REDZLIST","REDZLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSREDZLIST , FRTPAFECF_REDZLIST():New() )
			::oWSREDZLIST[len(::oWSREDZLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTRCCRDLIST

WSSTRUCT FRTPAFECF_ARRAYOFTRCCRDLIST
	WSDATA   oWSTRCCRDLIST             AS FRTPAFECF_TRCCRDLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFTRCCRDLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFTRCCRDLIST
	::oWSTRCCRDLIST        := {} // Array Of  FRTPAFECF_TRCCRDLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFTRCCRDLIST
	Local oClone := FRTPAFECF_ARRAYOFTRCCRDLIST():NEW()
	oClone:oWSTRCCRDLIST := NIL
	If ::oWSTRCCRDLIST <> NIL 
		oClone:oWSTRCCRDLIST := {}
		aEval( ::oWSTRCCRDLIST , { |x| aadd( oClone:oWSTRCCRDLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFTRCCRDLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TRCCRDLIST","TRCCRDLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTRCCRDLIST , FRTPAFECF_TRCCRDLIST():New() )
			::oWSTRCCRDLIST[len(::oWSTRCCRDLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFVENDALIST

WSSTRUCT FRTPAFECF_ARRAYOFVENDALIST
	WSDATA   oWSVENDALIST              AS FRTPAFECF_VENDALIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFVENDALIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFVENDALIST
	::oWSVENDALIST         := {} // Array Of  FRTPAFECF_VENDALIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFVENDALIST
	Local oClone := FRTPAFECF_ARRAYOFVENDALIST():NEW()
	oClone:oWSVENDALIST := NIL
	If ::oWSVENDALIST <> NIL 
		oClone:oWSVENDALIST := {}
		aEval( ::oWSVENDALIST , { |x| aadd( oClone:oWSVENDALIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFVENDALIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_VENDALIST","VENDALIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSVENDALIST , FRTPAFECF_VENDALIST():New() )
			::oWSVENDALIST[len(::oWSVENDALIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFLSTESTINFO

WSSTRUCT FRTPAFECF_ARRAYOFLSTESTINFO
	WSDATA   oWSLSTESTINFO             AS FRTPAFECF_LSTESTINFO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFLSTESTINFO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFLSTESTINFO
	::oWSLSTESTINFO        := {} // Array Of  FRTPAFECF_LSTESTINFO():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFLSTESTINFO
	Local oClone := FRTPAFECF_ARRAYOFLSTESTINFO():NEW()
	oClone:oWSLSTESTINFO := NIL
	If ::oWSLSTESTINFO <> NIL 
		oClone:oWSLSTESTINFO := {}
		aEval( ::oWSLSTESTINFO , { |x| aadd( oClone:oWSLSTESTINFO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFLSTESTINFO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LSTESTINFO","LSTESTINFO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLSTESTINFO , FRTPAFECF_LSTESTINFO():New() )
			::oWSLSTESTINFO[len(::oWSLSTESTINFO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFVNDSIDENT

WSSTRUCT FRTPAFECF_ARRAYOFVNDSIDENT
	WSDATA   oWSVNDSIDENT              AS FRTPAFECF_VNDSIDENT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFVNDSIDENT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFVNDSIDENT
	::oWSVNDSIDENT         := {} // Array Of  FRTPAFECF_VNDSIDENT():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFVNDSIDENT
	Local oClone := FRTPAFECF_ARRAYOFVNDSIDENT():NEW()
	oClone:oWSVNDSIDENT := NIL
	If ::oWSVNDSIDENT <> NIL 
		oClone:oWSVNDSIDENT := {}
		aEval( ::oWSVNDSIDENT , { |x| aadd( oClone:oWSVNDSIDENT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFVNDSIDENT
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_VNDSIDENT","VNDSIDENT",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSVNDSIDENT , FRTPAFECF_VNDSIDENT():New() )
			::oWSVNDSIDENT[len(::oWSVNDSIDENT)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFVNDNFMNNF

WSSTRUCT FRTPAFECF_ARRAYOFVNDNFMNNF
	WSDATA   oWSVNDNFMNNF              AS FRTPAFECF_VNDNFMNNF OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFVNDNFMNNF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFVNDNFMNNF
	::oWSVNDNFMNNF         := {} // Array Of  FRTPAFECF_VNDNFMNNF():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFVNDNFMNNF
	Local oClone := FRTPAFECF_ARRAYOFVNDNFMNNF():NEW()
	oClone:oWSVNDNFMNNF := NIL
	If ::oWSVNDNFMNNF <> NIL 
		oClone:oWSVNDNFMNNF := {}
		aEval( ::oWSVNDNFMNNF , { |x| aadd( oClone:oWSVNDNFMNNF , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFVNDNFMNNF
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_VNDNFMNNF","VNDNFMNNF",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSVNDNFMNNF , FRTPAFECF_VNDNFMNNF():New() )
			::oWSVNDNFMNNF[len(::oWSVNDNFMNNF)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure DAVLIST

WSSTRUCT FRTPAFECF_DAVLIST
	WSDATA   cCCF                      AS string
	WSDATA   cCNPJ                     AS string
	WSDATA   cCNPJCLIENT               AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cCOO                      AS string
	WSDATA   cCOODAV                   AS string
	WSDATA   dEMISSAO                  AS date
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   oWSLSTITDAVLOG            AS FRTPAFECF_ARRAYOFITDAVLSTLG OPTIONAL
	WSDATA   oWSLSTITEMDAV             AS FRTPAFECF_ARRAYOFITDAVLIST OPTIONAL
	WSDATA   cMARCA                    AS string
	WSDATA   cMFADIC                   AS string
	WSDATA   cMODELO                   AS string
	WSDATA   cNOMECLIENT               AS string
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cSERIE                    AS string
	WSDATA   cSERPDV                   AS string
	WSDATA   cTIPOECF                  AS string
	WSDATA   cTITULO                   AS string
	WSDATA   nVALOR                    AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_DAVLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_DAVLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_DAVLIST
	Local oClone := FRTPAFECF_DAVLIST():NEW()
	oClone:cCCF                 := ::cCCF
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCNPJCLIENT          := ::cCNPJCLIENT
	oClone:cCODIGO              := ::cCODIGO
	oClone:cCOO                 := ::cCOO
	oClone:cCOODAV              := ::cCOODAV
	oClone:dEMISSAO             := ::dEMISSAO
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:oWSLSTITDAVLOG       := IIF(::oWSLSTITDAVLOG = NIL , NIL , ::oWSLSTITDAVLOG:Clone() )
	oClone:oWSLSTITEMDAV        := IIF(::oWSLSTITEMDAV = NIL , NIL , ::oWSLSTITEMDAV:Clone() )
	oClone:cMARCA               := ::cMARCA
	oClone:cMFADIC              := ::cMFADIC
	oClone:cMODELO              := ::cMODELO
	oClone:cNOMECLIENT          := ::cNOMECLIENT
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cSERIE               := ::cSERIE
	oClone:cSERPDV              := ::cSERPDV
	oClone:cTIPOECF             := ::cTIPOECF
	oClone:cTITULO              := ::cTITULO
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_DAVLIST
	Local oNode9
	Local oNode10
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCCF               :=  WSAdvValue( oResponse,"_CCF","string",NIL,"Property cCCF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,"Property cCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCNPJCLIENT        :=  WSAdvValue( oResponse,"_CNPJCLIENT","string",NIL,"Property cCNPJCLIENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCOO               :=  WSAdvValue( oResponse,"_COO","string",NIL,"Property cCOO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCOODAV            :=  WSAdvValue( oResponse,"_COODAV","string",NIL,"Property cCOODAV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dEMISSAO           :=  WSAdvValue( oResponse,"_EMISSAO","date",NIL,"Property dEMISSAO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode9 :=  WSAdvValue( oResponse,"_LSTITDAVLOG","ARRAYOFITDAVLSTLG",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode9 != NIL
		::oWSLSTITDAVLOG := FRTPAFECF_ARRAYOFITDAVLSTLG():New()
		::oWSLSTITDAVLOG:SoapRecv(oNode9)
	EndIf
	oNode10 :=  WSAdvValue( oResponse,"_LSTITEMDAV","ARRAYOFITDAVLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSLSTITEMDAV := FRTPAFECF_ARRAYOFITDAVLIST():New()
		::oWSLSTITEMDAV:SoapRecv(oNode10)
	EndIf
	::cMARCA             :=  WSAdvValue( oResponse,"_MARCA","string",NIL,"Property cMARCA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMFADIC            :=  WSAdvValue( oResponse,"_MFADIC","string",NIL,"Property cMFADIC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMODELO            :=  WSAdvValue( oResponse,"_MODELO","string",NIL,"Property cMODELO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMECLIENT        :=  WSAdvValue( oResponse,"_NOMECLIENT","string",NIL,"Property cNOMECLIENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cSERIE             :=  WSAdvValue( oResponse,"_SERIE","string",NIL,"Property cSERIE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERPDV            :=  WSAdvValue( oResponse,"_SERPDV","string",NIL,"Property cSERPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPOECF           :=  WSAdvValue( oResponse,"_TIPOECF","string",NIL,"Property cTIPOECF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTITULO            :=  WSAdvValue( oResponse,"_TITULO","string",NIL,"Property cTITULO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVALOR             :=  WSAdvValue( oResponse,"_VALOR","float",NIL,"Property nVALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure DOCLIST

WSSTRUCT FRTPAFECF_DOCLIST
	WSDATA   cCDC                      AS string
	WSDATA   cCOO                      AS string
	WSDATA   dDATAEMISS                AS date
	WSDATA   cGNF                      AS string
	WSDATA   cGRG                      AS string
	WSDATA   cHORAEMISS                AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cSERPDV                   AS string
	WSDATA   cSIMBOL                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_DOCLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_DOCLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_DOCLIST
	Local oClone := FRTPAFECF_DOCLIST():NEW()
	oClone:cCDC                 := ::cCDC
	oClone:cCOO                 := ::cCOO
	oClone:dDATAEMISS           := ::dDATAEMISS
	oClone:cGNF                 := ::cGNF
	oClone:cGRG                 := ::cGRG
	oClone:cHORAEMISS           := ::cHORAEMISS
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cSERPDV              := ::cSERPDV
	oClone:cSIMBOL              := ::cSIMBOL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_DOCLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCDC               :=  WSAdvValue( oResponse,"_CDC","string",NIL,"Property cCDC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCOO               :=  WSAdvValue( oResponse,"_COO","string",NIL,"Property cCOO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dDATAEMISS         :=  WSAdvValue( oResponse,"_DATAEMISS","date",NIL,"Property dDATAEMISS as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cGNF               :=  WSAdvValue( oResponse,"_GNF","string",NIL,"Property cGNF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cGRG               :=  WSAdvValue( oResponse,"_GRG","string",NIL,"Property cGRG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHORAEMISS         :=  WSAdvValue( oResponse,"_HORAEMISS","string",NIL,"Property cHORAEMISS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cSERPDV            :=  WSAdvValue( oResponse,"_SERPDV","string",NIL,"Property cSERPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSIMBOL            :=  WSAdvValue( oResponse,"_SIMBOL","string",NIL,"Property cSIMBOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFCODPROD

WSSTRUCT FRTPAFECF_ARRAYOFCODPROD
	WSDATA   oWSCODPROD                AS FRTPAFECF_CODPROD OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFCODPROD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFCODPROD
	::oWSCODPROD           := {} // Array Of  FRTPAFECF_CODPROD():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFCODPROD
	Local oClone := FRTPAFECF_ARRAYOFCODPROD():NEW()
	oClone:oWSCODPROD := NIL
	If ::oWSCODPROD <> NIL 
		oClone:oWSCODPROD := {}
		aEval( ::oWSCODPROD , { |x| aadd( oClone:oWSCODPROD , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTPAFECF_ARRAYOFCODPROD
	Local cSoap := ""
	aEval( ::oWSCODPROD , {|x| cSoap := cSoap  +  WSSoapValue("CODPROD", x , x , "CODPROD", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ESTLIST

WSSTRUCT FRTPAFECF_ESTLIST
	WSDATA   cCNPJ                     AS string
	WSDATA   cCODBAR                   AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSDATA   lFIMLISTA                 AS boolean
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   nQTDEATU                  AS float
	WSDATA   dULTSAIDA                 AS date
	WSDATA   cUM                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ESTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ESTLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ESTLIST
	Local oClone := FRTPAFECF_ESTLIST():NEW()
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCODBAR              := ::cCODBAR
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:lFIMLISTA            := ::lFIMLISTA
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:nQTDEATU             := ::nQTDEATU
	oClone:dULTSAIDA            := ::dULTSAIDA
	oClone:cUM                  := ::cUM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ESTLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,"Property cCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODBAR            :=  WSAdvValue( oResponse,"_CODBAR","string",NIL,"Property cCODBAR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lFIMLISTA          :=  WSAdvValue( oResponse,"_FIMLISTA","boolean",NIL,"Property lFIMLISTA as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nQTDEATU           :=  WSAdvValue( oResponse,"_QTDEATU","float",NIL,"Property nQTDEATU as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::dULTSAIDA          :=  WSAdvValue( oResponse,"_ULTSAIDA","date",NIL,"Property dULTSAIDA as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cUM                :=  WSAdvValue( oResponse,"_UM","string",NIL,"Property cUM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure LSTINFOPDV

WSSTRUCT FRTPAFECF_LSTINFOPDV
	WSDATA   cALQINFO                  AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cECFINFO                  AS string
	WSDATA   cIMPFISC                  AS string
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cPDV                      AS string
	WSDATA   cSERIE                    AS string
	WSDATA   cSERPDV                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_LSTINFOPDV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_LSTINFOPDV
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_LSTINFOPDV
	Local oClone := FRTPAFECF_LSTINFOPDV():NEW()
	oClone:cALQINFO             := ::cALQINFO
	oClone:cCODIGO              := ::cCODIGO
	oClone:cECFINFO             := ::cECFINFO
	oClone:cIMPFISC             := ::cIMPFISC
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cPDV                 := ::cPDV
	oClone:cSERIE               := ::cSERIE
	oClone:cSERPDV              := ::cSERPDV
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_LSTINFOPDV
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cALQINFO           :=  WSAdvValue( oResponse,"_ALQINFO","string",NIL,"Property cALQINFO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cECFINFO           :=  WSAdvValue( oResponse,"_ECFINFO","string",NIL,"Property cECFINFO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cIMPFISC           :=  WSAdvValue( oResponse,"_IMPFISC","string",NIL,"Property cIMPFISC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cPDV               :=  WSAdvValue( oResponse,"_PDV","string",NIL,"Property cPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERIE             :=  WSAdvValue( oResponse,"_SERIE","string",NIL,"Property cSERIE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERPDV            :=  WSAdvValue( oResponse,"_SERPDV","string",NIL,"Property cSERPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ITVNDLIST

WSSTRUCT FRTPAFECF_ITVNDLIST
	WSDATA   nACREITEM                 AS float
	WSDATA   nCANCACRIT                AS float
	WSDATA   cCODPROD                  AS string
	WSDATA   lCONTLOOP                 AS boolean
	WSDATA   nCONTORDOP                AS float
	WSDATA   nDESCITEM                 AS float
	WSDATA   cDESCRICAO                AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   cINDARRTRU                AS string
	WSDATA   cIPPT                     AS string
	WSDATA   lITCANCEL                 AS boolean
	WSDATA   nITEMNUM                  AS float
	WSDATA   nNUMCONTDOC               AS integer
	WSDATA   nNUMDOC                   AS integer
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   nQTDCANC                  AS float
	WSDATA   nQTDDECQTD                AS float
	WSDATA   nQTDDECVUN                AS float
	WSDATA   nQUANTIDADE               AS float
	WSDATA   cSERPDV                   AS string
	WSDATA   cSITTRIB                  AS string
	WSDATA   cTOTPARC                  AS string
	WSDATA   cUNMEDIDA                 AS string
	WSDATA   nVALCANC                  AS float
	WSDATA   nVLRLIQ                   AS float
	WSDATA   nVLRUNIT                  AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ITVNDLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ITVNDLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ITVNDLIST
	Local oClone := FRTPAFECF_ITVNDLIST():NEW()
	oClone:nACREITEM            := ::nACREITEM
	oClone:nCANCACRIT           := ::nCANCACRIT
	oClone:cCODPROD             := ::cCODPROD
	oClone:lCONTLOOP            := ::lCONTLOOP
	oClone:nCONTORDOP           := ::nCONTORDOP
	oClone:nDESCITEM            := ::nDESCITEM
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:cINDARRTRU           := ::cINDARRTRU
	oClone:cIPPT                := ::cIPPT
	oClone:lITCANCEL            := ::lITCANCEL
	oClone:nITEMNUM             := ::nITEMNUM
	oClone:nNUMCONTDOC          := ::nNUMCONTDOC
	oClone:nNUMDOC              := ::nNUMDOC
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:nQTDCANC             := ::nQTDCANC
	oClone:nQTDDECQTD           := ::nQTDDECQTD
	oClone:nQTDDECVUN           := ::nQTDDECVUN
	oClone:nQUANTIDADE          := ::nQUANTIDADE
	oClone:cSERPDV              := ::cSERPDV
	oClone:cSITTRIB             := ::cSITTRIB
	oClone:cTOTPARC             := ::cTOTPARC
	oClone:cUNMEDIDA            := ::cUNMEDIDA
	oClone:nVALCANC             := ::nVALCANC
	oClone:nVLRLIQ              := ::nVLRLIQ
	oClone:nVLRUNIT             := ::nVLRUNIT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ITVNDLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nACREITEM          :=  WSAdvValue( oResponse,"_ACREITEM","float",NIL,"Property nACREITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCANCACRIT         :=  WSAdvValue( oResponse,"_CANCACRIT","float",NIL,"Property nCANCACRIT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCODPROD           :=  WSAdvValue( oResponse,"_CODPROD","string",NIL,"Property cCODPROD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lCONTLOOP          :=  WSAdvValue( oResponse,"_CONTLOOP","boolean",NIL,"Property lCONTLOOP as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nCONTORDOP         :=  WSAdvValue( oResponse,"_CONTORDOP","float",NIL,"Property nCONTORDOP as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDESCITEM          :=  WSAdvValue( oResponse,"_DESCITEM","float",NIL,"Property nDESCITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cINDARRTRU         :=  WSAdvValue( oResponse,"_INDARRTRU","string",NIL,"Property cINDARRTRU as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cIPPT              :=  WSAdvValue( oResponse,"_IPPT","string",NIL,"Property cIPPT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lITCANCEL          :=  WSAdvValue( oResponse,"_ITCANCEL","boolean",NIL,"Property lITCANCEL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nITEMNUM           :=  WSAdvValue( oResponse,"_ITEMNUM","float",NIL,"Property nITEMNUM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNUMCONTDOC        :=  WSAdvValue( oResponse,"_NUMCONTDOC","integer",NIL,"Property nNUMCONTDOC as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNUMDOC            :=  WSAdvValue( oResponse,"_NUMDOC","integer",NIL,"Property nNUMDOC as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nQTDCANC           :=  WSAdvValue( oResponse,"_QTDCANC","float",NIL,"Property nQTDCANC as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQTDDECQTD         :=  WSAdvValue( oResponse,"_QTDDECQTD","float",NIL,"Property nQTDDECQTD as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQTDDECVUN         :=  WSAdvValue( oResponse,"_QTDDECVUN","float",NIL,"Property nQTDDECVUN as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQUANTIDADE        :=  WSAdvValue( oResponse,"_QUANTIDADE","float",NIL,"Property nQUANTIDADE as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSERPDV            :=  WSAdvValue( oResponse,"_SERPDV","string",NIL,"Property cSERPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSITTRIB           :=  WSAdvValue( oResponse,"_SITTRIB","string",NIL,"Property cSITTRIB as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTOTPARC           :=  WSAdvValue( oResponse,"_TOTPARC","string",NIL,"Property cTOTPARC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUNMEDIDA          :=  WSAdvValue( oResponse,"_UNMEDIDA","string",NIL,"Property cUNMEDIDA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVALCANC           :=  WSAdvValue( oResponse,"_VALCANC","float",NIL,"Property nVALCANC as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVLRLIQ            :=  WSAdvValue( oResponse,"_VLRLIQ","float",NIL,"Property nVLRLIQ as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVLRUNIT           :=  WSAdvValue( oResponse,"_VLRUNIT","float",NIL,"Property nVLRUNIT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ITVNDNFMNNF

WSSTRUCT FRTPAFECF_ITVNDNFMNNF
	WSDATA   nACREITEM                 AS float
	WSDATA   cCNPJEMI                  AS string
	WSDATA   cCODPROD                  AS string
	WSDATA   lCONTLOOP                 AS boolean
	WSDATA   dDATAEMISS                AS date
	WSDATA   lDELMANUAL                AS boolean
	WSDATA   nDESCITEM                 AS float
	WSDATA   cDESCRICAO                AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   lITCANCEL                 AS boolean
	WSDATA   nITEMNUM                  AS float
	WSDATA   cKEYNOTA                  AS string
	WSDATA   nNUMNOTA                  AS integer
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   nQTDDECQTD                AS float
	WSDATA   nQTDDECVUN                AS float
	WSDATA   nQUANTIDADE               AS float
	WSDATA   cSERIENOTA                AS string
	WSDATA   cTOTPARC                  AS string
	WSDATA   nTPDOCEMI                 AS integer
	WSDATA   cUNMEDIDA                 AS string
	WSDATA   nVLRLIQ                   AS float
	WSDATA   nVLRUNIT                  AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ITVNDNFMNNF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ITVNDNFMNNF
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ITVNDNFMNNF
	Local oClone := FRTPAFECF_ITVNDNFMNNF():NEW()
	oClone:nACREITEM            := ::nACREITEM
	oClone:cCNPJEMI             := ::cCNPJEMI
	oClone:cCODPROD             := ::cCODPROD
	oClone:lCONTLOOP            := ::lCONTLOOP
	oClone:dDATAEMISS           := ::dDATAEMISS
	oClone:lDELMANUAL           := ::lDELMANUAL
	oClone:nDESCITEM            := ::nDESCITEM
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:lITCANCEL            := ::lITCANCEL
	oClone:nITEMNUM             := ::nITEMNUM
	oClone:cKEYNOTA             := ::cKEYNOTA
	oClone:nNUMNOTA             := ::nNUMNOTA
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:nQTDDECQTD           := ::nQTDDECQTD
	oClone:nQTDDECVUN           := ::nQTDDECVUN
	oClone:nQUANTIDADE          := ::nQUANTIDADE
	oClone:cSERIENOTA           := ::cSERIENOTA
	oClone:cTOTPARC             := ::cTOTPARC
	oClone:nTPDOCEMI            := ::nTPDOCEMI
	oClone:cUNMEDIDA            := ::cUNMEDIDA
	oClone:nVLRLIQ              := ::nVLRLIQ
	oClone:nVLRUNIT             := ::nVLRUNIT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ITVNDNFMNNF
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nACREITEM          :=  WSAdvValue( oResponse,"_ACREITEM","float",NIL,"Property nACREITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCNPJEMI           :=  WSAdvValue( oResponse,"_CNPJEMI","string",NIL,"Property cCNPJEMI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODPROD           :=  WSAdvValue( oResponse,"_CODPROD","string",NIL,"Property cCODPROD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lCONTLOOP          :=  WSAdvValue( oResponse,"_CONTLOOP","boolean",NIL,"Property lCONTLOOP as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::dDATAEMISS         :=  WSAdvValue( oResponse,"_DATAEMISS","date",NIL,"Property dDATAEMISS as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lDELMANUAL         :=  WSAdvValue( oResponse,"_DELMANUAL","boolean",NIL,"Property lDELMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nDESCITEM          :=  WSAdvValue( oResponse,"_DESCITEM","float",NIL,"Property nDESCITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lITCANCEL          :=  WSAdvValue( oResponse,"_ITCANCEL","boolean",NIL,"Property lITCANCEL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nITEMNUM           :=  WSAdvValue( oResponse,"_ITEMNUM","float",NIL,"Property nITEMNUM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cKEYNOTA           :=  WSAdvValue( oResponse,"_KEYNOTA","string",NIL,"Property cKEYNOTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nNUMNOTA           :=  WSAdvValue( oResponse,"_NUMNOTA","integer",NIL,"Property nNUMNOTA as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nQTDDECQTD         :=  WSAdvValue( oResponse,"_QTDDECQTD","float",NIL,"Property nQTDDECQTD as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQTDDECVUN         :=  WSAdvValue( oResponse,"_QTDDECVUN","float",NIL,"Property nQTDDECVUN as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQUANTIDADE        :=  WSAdvValue( oResponse,"_QUANTIDADE","float",NIL,"Property nQUANTIDADE as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSERIENOTA         :=  WSAdvValue( oResponse,"_SERIENOTA","string",NIL,"Property cSERIENOTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTOTPARC           :=  WSAdvValue( oResponse,"_TOTPARC","string",NIL,"Property cTOTPARC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTPDOCEMI          :=  WSAdvValue( oResponse,"_TPDOCEMI","integer",NIL,"Property nTPDOCEMI as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cUNMEDIDA          :=  WSAdvValue( oResponse,"_UNMEDIDA","string",NIL,"Property cUNMEDIDA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVLRLIQ            :=  WSAdvValue( oResponse,"_VLRLIQ","float",NIL,"Property nVLRLIQ as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVLRUNIT           :=  WSAdvValue( oResponse,"_VLRUNIT","float",NIL,"Property nVLRUNIT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure MEIPGTLIST

WSSTRUCT FRTPAFECF_MEIPGTLIST
	WSDATA   oWSDADOSPAG               AS FRTPAFECF_ARRAYOFPAGLIST OPTIONAL
	WSDATA   dEMISSAO                  AS date
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   oWSTIPOS                  AS FRTPAFECF_ARRAYOFSTRING
	WSDATA   oWSTOTAIS                 AS FRTPAFECF_ARRAYOFFLOAT
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_MEIPGTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_MEIPGTLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_MEIPGTLIST
	Local oClone := FRTPAFECF_MEIPGTLIST():NEW()
	oClone:oWSDADOSPAG          := IIF(::oWSDADOSPAG = NIL , NIL , ::oWSDADOSPAG:Clone() )
	oClone:dEMISSAO             := ::dEMISSAO
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:oWSTIPOS             := IIF(::oWSTIPOS = NIL , NIL , ::oWSTIPOS:Clone() )
	oClone:oWSTOTAIS            := IIF(::oWSTOTAIS = NIL , NIL , ::oWSTOTAIS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_MEIPGTLIST
	Local oNode1
	Local oNode4
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOSPAG","ARRAYOFPAGLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDADOSPAG := FRTPAFECF_ARRAYOFPAGLIST():New()
		::oWSDADOSPAG:SoapRecv(oNode1)
	EndIf
	::dEMISSAO           :=  WSAdvValue( oResponse,"_EMISSAO","date",NIL,"Property dEMISSAO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_TIPOS","ARRAYOFSTRING",NIL,"Property oWSTIPOS as s0:ARRAYOFSTRING on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSTIPOS := FRTPAFECF_ARRAYOFSTRING():New()
		::oWSTIPOS:SoapRecv(oNode4)
	EndIf
	oNode5 :=  WSAdvValue( oResponse,"_TOTAIS","ARRAYOFFLOAT",NIL,"Property oWSTOTAIS as s0:ARRAYOFFLOAT on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSTOTAIS := FRTPAFECF_ARRAYOFFLOAT():New()
		::oWSTOTAIS:SoapRecv(oNode5)
	EndIf
Return

// WSDL Data Structure PRODLIST

WSSTRUCT FRTPAFECF_PRODLIST
	WSDATA   nALIQISS                  AS integer
	WSDATA   cCNPJ                     AS string
	WSDATA   cCODBAR                   AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSDATA   lFIMLISTA                 AS boolean
	WSDATA   cIAT                      AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   cIPPT                     AS string
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   nPICM                     AS integer
	WSDATA   nPRECO                    AS float
	WSDATA   cSITTRIB                  AS string
	WSDATA   cUM                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_PRODLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_PRODLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_PRODLIST
	Local oClone := FRTPAFECF_PRODLIST():NEW()
	oClone:nALIQISS             := ::nALIQISS
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCODBAR              := ::cCODBAR
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:lFIMLISTA            := ::lFIMLISTA
	oClone:cIAT                 := ::cIAT
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:cIPPT                := ::cIPPT
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:nPICM                := ::nPICM
	oClone:nPRECO               := ::nPRECO
	oClone:cSITTRIB             := ::cSITTRIB
	oClone:cUM                  := ::cUM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_PRODLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nALIQISS           :=  WSAdvValue( oResponse,"_ALIQISS","integer",NIL,"Property nALIQISS as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,"Property cCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODBAR            :=  WSAdvValue( oResponse,"_CODBAR","string",NIL,"Property cCODBAR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lFIMLISTA          :=  WSAdvValue( oResponse,"_FIMLISTA","boolean",NIL,"Property lFIMLISTA as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cIAT               :=  WSAdvValue( oResponse,"_IAT","string",NIL,"Property cIAT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cIPPT              :=  WSAdvValue( oResponse,"_IPPT","string",NIL,"Property cIPPT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nPICM              :=  WSAdvValue( oResponse,"_PICM","integer",NIL,"Property nPICM as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO             :=  WSAdvValue( oResponse,"_PRECO","float",NIL,"Property nPRECO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSITTRIB           :=  WSAdvValue( oResponse,"_SITTRIB","string",NIL,"Property cSITTRIB as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUM                :=  WSAdvValue( oResponse,"_UM","string",NIL,"Property cUM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure REDZLIST

WSSTRUCT FRTPAFECF_REDZLIST
	WSDATA   nCONTORDOP                AS float
	WSDATA   nCONTREDZ                 AS float
	WSDATA   nCONTREINIC               AS float
	WSDATA   dDATAMOVTO                AS date
	WSDATA   dDATAREDZ                 AS date
	WSDATA   lDELMANUAL                AS boolean
	WSDATA   cHORAREDZ                 AS string
	WSDATA   oWSIMPSSFI                AS FRTPAFECF_ARRAYOFIMPLIST OPTIONAL
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cSERIE                    AS string
	WSDATA   nTOTBRUTDIA               AS float
	WSDATA   nTOTCANCDIA               AS float
	WSDATA   nTOTCANISS                AS float
	WSDATA   nTOTOPNFIS                AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_REDZLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_REDZLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_REDZLIST
	Local oClone := FRTPAFECF_REDZLIST():NEW()
	oClone:nCONTORDOP           := ::nCONTORDOP
	oClone:nCONTREDZ            := ::nCONTREDZ
	oClone:nCONTREINIC          := ::nCONTREINIC
	oClone:dDATAMOVTO           := ::dDATAMOVTO
	oClone:dDATAREDZ            := ::dDATAREDZ
	oClone:lDELMANUAL           := ::lDELMANUAL
	oClone:cHORAREDZ            := ::cHORAREDZ
	oClone:oWSIMPSSFI           := IIF(::oWSIMPSSFI = NIL , NIL , ::oWSIMPSSFI:Clone() )
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cSERIE               := ::cSERIE
	oClone:nTOTBRUTDIA          := ::nTOTBRUTDIA
	oClone:nTOTCANCDIA          := ::nTOTCANCDIA
	oClone:nTOTCANISS           := ::nTOTCANISS
	oClone:nTOTOPNFIS           := ::nTOTOPNFIS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_REDZLIST
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCONTORDOP         :=  WSAdvValue( oResponse,"_CONTORDOP","float",NIL,"Property nCONTORDOP as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCONTREDZ          :=  WSAdvValue( oResponse,"_CONTREDZ","float",NIL,"Property nCONTREDZ as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCONTREINIC        :=  WSAdvValue( oResponse,"_CONTREINIC","float",NIL,"Property nCONTREINIC as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::dDATAMOVTO         :=  WSAdvValue( oResponse,"_DATAMOVTO","date",NIL,"Property dDATAMOVTO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dDATAREDZ          :=  WSAdvValue( oResponse,"_DATAREDZ","date",NIL,"Property dDATAREDZ as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lDELMANUAL         :=  WSAdvValue( oResponse,"_DELMANUAL","boolean",NIL,"Property lDELMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cHORAREDZ          :=  WSAdvValue( oResponse,"_HORAREDZ","string",NIL,"Property cHORAREDZ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode8 :=  WSAdvValue( oResponse,"_IMPSSFI","ARRAYOFIMPLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSIMPSSFI := FRTPAFECF_ARRAYOFIMPLIST():New()
		::oWSIMPSSFI:SoapRecv(oNode8)
	EndIf
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cSERIE             :=  WSAdvValue( oResponse,"_SERIE","string",NIL,"Property cSERIE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTOTBRUTDIA        :=  WSAdvValue( oResponse,"_TOTBRUTDIA","float",NIL,"Property nTOTBRUTDIA as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTOTCANCDIA        :=  WSAdvValue( oResponse,"_TOTCANCDIA","float",NIL,"Property nTOTCANCDIA as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTOTCANISS         :=  WSAdvValue( oResponse,"_TOTCANISS","float",NIL,"Property nTOTCANISS as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTOTOPNFIS         :=  WSAdvValue( oResponse,"_TOTOPNFIS","float",NIL,"Property nTOTOPNFIS as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure TRCCRDLIST

WSSTRUCT FRTPAFECF_TRCCRDLIST
	WSDATA   cCCF                      AS string
	WSDATA   cCNPJADM                  AS string
	WSDATA   cCNPJENTI                 AS string
	WSDATA   cCOO                      AS string
	WSDATA   cCPFCLI                   AS string
	WSDATA   dDTEMISSAO                AS date
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cTITULO                   AS string
	WSDATA   nTROCO                    AS float
	WSDATA   lUSATROCO                 AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_TRCCRDLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_TRCCRDLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_TRCCRDLIST
	Local oClone := FRTPAFECF_TRCCRDLIST():NEW()
	oClone:cCCF                 := ::cCCF
	oClone:cCNPJADM             := ::cCNPJADM
	oClone:cCNPJENTI            := ::cCNPJENTI
	oClone:cCOO                 := ::cCOO
	oClone:cCPFCLI              := ::cCPFCLI
	oClone:dDTEMISSAO           := ::dDTEMISSAO
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cTITULO              := ::cTITULO
	oClone:nTROCO               := ::nTROCO
	oClone:lUSATROCO            := ::lUSATROCO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_TRCCRDLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCCF               :=  WSAdvValue( oResponse,"_CCF","string",NIL,"Property cCCF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCNPJADM           :=  WSAdvValue( oResponse,"_CNPJADM","string",NIL,"Property cCNPJADM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCNPJENTI          :=  WSAdvValue( oResponse,"_CNPJENTI","string",NIL,"Property cCNPJENTI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCOO               :=  WSAdvValue( oResponse,"_COO","string",NIL,"Property cCOO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCPFCLI            :=  WSAdvValue( oResponse,"_CPFCLI","string",NIL,"Property cCPFCLI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dDTEMISSAO         :=  WSAdvValue( oResponse,"_DTEMISSAO","date",NIL,"Property dDTEMISSAO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cTITULO            :=  WSAdvValue( oResponse,"_TITULO","string",NIL,"Property cTITULO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTROCO             :=  WSAdvValue( oResponse,"_TROCO","float",NIL,"Property nTROCO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lUSATROCO          :=  WSAdvValue( oResponse,"_USATROCO","boolean",NIL,"Property lUSATROCO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure VENDALIST

WSSTRUCT FRTPAFECF_VENDALIST
	WSDATA   nACRETOTAL                AS float
	WSDATA   lCANCELADO                AS boolean
	WSDATA   cCNPJCLIENT               AS string
	WSDATA   lCONTLOOP                 AS boolean
	WSDATA   nCONTORDOP                AS float
	WSDATA   dDATAEMISS                AS date
	WSDATA   cDATATEF                  AS string
	WSDATA   nDESCTOTAL                AS float
	WSDATA   cHORAEMISS                AS string
	WSDATA   cHORATEF                  AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   cNOMECLIENT               AS string
	WSDATA   nNUMCONTCDC               AS integer
	WSDATA   nNUMCONTDOC               AS integer
	WSDATA   nNUMCONTONF               AS integer
	WSDATA   nNUMCONTRG                AS integer
	WSDATA   nNUMDOC                   AS integer
	WSDATA   cORDAPLDESC               AS string
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cSERPDV                   AS string
	WSDATA   nSUBTOTAL                 AS float
	WSDATA   nTOTLIQUIDO               AS float
	WSDATA   cTPACRESC                 AS string
	WSDATA   cTPDESCON                 AS string
	WSDATA   nVALCANCTOT               AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_VENDALIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_VENDALIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_VENDALIST
	Local oClone := FRTPAFECF_VENDALIST():NEW()
	oClone:nACRETOTAL           := ::nACRETOTAL
	oClone:lCANCELADO           := ::lCANCELADO
	oClone:cCNPJCLIENT          := ::cCNPJCLIENT
	oClone:lCONTLOOP            := ::lCONTLOOP
	oClone:nCONTORDOP           := ::nCONTORDOP
	oClone:dDATAEMISS           := ::dDATAEMISS
	oClone:cDATATEF             := ::cDATATEF
	oClone:nDESCTOTAL           := ::nDESCTOTAL
	oClone:cHORAEMISS           := ::cHORAEMISS
	oClone:cHORATEF             := ::cHORATEF
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:cNOMECLIENT          := ::cNOMECLIENT
	oClone:nNUMCONTCDC          := ::nNUMCONTCDC
	oClone:nNUMCONTDOC          := ::nNUMCONTDOC
	oClone:nNUMCONTONF          := ::nNUMCONTONF
	oClone:nNUMCONTRG           := ::nNUMCONTRG
	oClone:nNUMDOC              := ::nNUMDOC
	oClone:cORDAPLDESC          := ::cORDAPLDESC
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cSERPDV              := ::cSERPDV
	oClone:nSUBTOTAL            := ::nSUBTOTAL
	oClone:nTOTLIQUIDO          := ::nTOTLIQUIDO
	oClone:cTPACRESC            := ::cTPACRESC
	oClone:cTPDESCON            := ::cTPDESCON
	oClone:nVALCANCTOT          := ::nVALCANCTOT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_VENDALIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nACRETOTAL         :=  WSAdvValue( oResponse,"_ACRETOTAL","float",NIL,"Property nACRETOTAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lCANCELADO         :=  WSAdvValue( oResponse,"_CANCELADO","boolean",NIL,"Property lCANCELADO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cCNPJCLIENT        :=  WSAdvValue( oResponse,"_CNPJCLIENT","string",NIL,"Property cCNPJCLIENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lCONTLOOP          :=  WSAdvValue( oResponse,"_CONTLOOP","boolean",NIL,"Property lCONTLOOP as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nCONTORDOP         :=  WSAdvValue( oResponse,"_CONTORDOP","float",NIL,"Property nCONTORDOP as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::dDATAEMISS         :=  WSAdvValue( oResponse,"_DATAEMISS","date",NIL,"Property dDATAEMISS as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cDATATEF           :=  WSAdvValue( oResponse,"_DATATEF","string",NIL,"Property cDATATEF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nDESCTOTAL         :=  WSAdvValue( oResponse,"_DESCTOTAL","float",NIL,"Property nDESCTOTAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cHORAEMISS         :=  WSAdvValue( oResponse,"_HORAEMISS","string",NIL,"Property cHORAEMISS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHORATEF           :=  WSAdvValue( oResponse,"_HORATEF","string",NIL,"Property cHORATEF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cNOMECLIENT        :=  WSAdvValue( oResponse,"_NOMECLIENT","string",NIL,"Property cNOMECLIENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nNUMCONTCDC        :=  WSAdvValue( oResponse,"_NUMCONTCDC","integer",NIL,"Property nNUMCONTCDC as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNUMCONTDOC        :=  WSAdvValue( oResponse,"_NUMCONTDOC","integer",NIL,"Property nNUMCONTDOC as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNUMCONTONF        :=  WSAdvValue( oResponse,"_NUMCONTONF","integer",NIL,"Property nNUMCONTONF as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNUMCONTRG         :=  WSAdvValue( oResponse,"_NUMCONTRG","integer",NIL,"Property nNUMCONTRG as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNUMDOC            :=  WSAdvValue( oResponse,"_NUMDOC","integer",NIL,"Property nNUMDOC as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cORDAPLDESC        :=  WSAdvValue( oResponse,"_ORDAPLDESC","string",NIL,"Property cORDAPLDESC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cSERPDV            :=  WSAdvValue( oResponse,"_SERPDV","string",NIL,"Property cSERPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSUBTOTAL          :=  WSAdvValue( oResponse,"_SUBTOTAL","float",NIL,"Property nSUBTOTAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTOTLIQUIDO        :=  WSAdvValue( oResponse,"_TOTLIQUIDO","float",NIL,"Property nTOTLIQUIDO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTPACRESC          :=  WSAdvValue( oResponse,"_TPACRESC","string",NIL,"Property cTPACRESC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTPDESCON          :=  WSAdvValue( oResponse,"_TPDESCON","string",NIL,"Property cTPDESCON as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVALCANCTOT        :=  WSAdvValue( oResponse,"_VALCANCTOT","float",NIL,"Property nVALCANCTOT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure LSTESTINFO

WSSTRUCT FRTPAFECF_LSTESTINFO
	WSDATA   dEMISSAO                  AS date
	WSDATA   cHORA                     AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cPDV                      AS string
	WSDATA   cSERPDV                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_LSTESTINFO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_LSTESTINFO
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_LSTESTINFO
	Local oClone := FRTPAFECF_LSTESTINFO():NEW()
	oClone:dEMISSAO             := ::dEMISSAO
	oClone:cHORA                := ::cHORA
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cPDV                 := ::cPDV
	oClone:cSERPDV              := ::cSERPDV
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_LSTESTINFO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::dEMISSAO           :=  WSAdvValue( oResponse,"_EMISSAO","date",NIL,"Property dEMISSAO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cHORA              :=  WSAdvValue( oResponse,"_HORA","string",NIL,"Property cHORA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cPDV               :=  WSAdvValue( oResponse,"_PDV","string",NIL,"Property cPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERPDV            :=  WSAdvValue( oResponse,"_SERPDV","string",NIL,"Property cSERPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure VNDSIDENT

WSSTRUCT FRTPAFECF_VNDSIDENT
	WSDATA   cCPFCNPJ                  AS string
	WSDATA   dDTFIRSTS                 AS date
	WSDATA   dDTLASTS                  AS date
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   nTOTALVND                 AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_VNDSIDENT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_VNDSIDENT
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_VNDSIDENT
	Local oClone := FRTPAFECF_VNDSIDENT():NEW()
	oClone:cCPFCNPJ             := ::cCPFCNPJ
	oClone:dDTFIRSTS            := ::dDTFIRSTS
	oClone:dDTLASTS             := ::dDTLASTS
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:nTOTALVND            := ::nTOTALVND
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_VNDSIDENT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCPFCNPJ           :=  WSAdvValue( oResponse,"_CPFCNPJ","string",NIL,"Property cCPFCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dDTFIRSTS          :=  WSAdvValue( oResponse,"_DTFIRSTS","date",NIL,"Property dDTFIRSTS as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dDTLASTS           :=  WSAdvValue( oResponse,"_DTLASTS","date",NIL,"Property dDTLASTS as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nTOTALVND          :=  WSAdvValue( oResponse,"_TOTALVND","float",NIL,"Property nTOTALVND as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure VNDNFMNNF

WSSTRUCT FRTPAFECF_VNDNFMNNF
	WSDATA   nACRETOTAL                AS float
	WSDATA   lCANCELADO                AS boolean
	WSDATA   cCNPJCLIENT               AS string
	WSDATA   cCNPJEMI                  AS string
	WSDATA   lCONTLOOP                 AS boolean
	WSDATA   dDATAEMISS                AS date
	WSDATA   lDELMANUAL                AS boolean
	WSDATA   nDESCTOTAL                AS float
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   cKEYNOTA                  AS string
	WSDATA   cNOMECLIENT               AS string
	WSDATA   nNUMNOTA                  AS integer
	WSDATA   cORDAPLDESC               AS string
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cSERIENOTA                AS string
	WSDATA   nSUBTOTAL                 AS float
	WSDATA   nTOTLIQUIDO               AS float
	WSDATA   cTPACRESC                 AS string
	WSDATA   cTPDESCON                 AS string
	WSDATA   nTPDOCEMI                 AS integer
	WSDATA   nVALCANCTOT               AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_VNDNFMNNF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_VNDNFMNNF
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_VNDNFMNNF
	Local oClone := FRTPAFECF_VNDNFMNNF():NEW()
	oClone:nACRETOTAL           := ::nACRETOTAL
	oClone:lCANCELADO           := ::lCANCELADO
	oClone:cCNPJCLIENT          := ::cCNPJCLIENT
	oClone:cCNPJEMI             := ::cCNPJEMI
	oClone:lCONTLOOP            := ::lCONTLOOP
	oClone:dDATAEMISS           := ::dDATAEMISS
	oClone:lDELMANUAL           := ::lDELMANUAL
	oClone:nDESCTOTAL           := ::nDESCTOTAL
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:cKEYNOTA             := ::cKEYNOTA
	oClone:cNOMECLIENT          := ::cNOMECLIENT
	oClone:nNUMNOTA             := ::nNUMNOTA
	oClone:cORDAPLDESC          := ::cORDAPLDESC
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cSERIENOTA           := ::cSERIENOTA
	oClone:nSUBTOTAL            := ::nSUBTOTAL
	oClone:nTOTLIQUIDO          := ::nTOTLIQUIDO
	oClone:cTPACRESC            := ::cTPACRESC
	oClone:cTPDESCON            := ::cTPDESCON
	oClone:nTPDOCEMI            := ::nTPDOCEMI
	oClone:nVALCANCTOT          := ::nVALCANCTOT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_VNDNFMNNF
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nACRETOTAL         :=  WSAdvValue( oResponse,"_ACRETOTAL","float",NIL,"Property nACRETOTAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lCANCELADO         :=  WSAdvValue( oResponse,"_CANCELADO","boolean",NIL,"Property lCANCELADO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cCNPJCLIENT        :=  WSAdvValue( oResponse,"_CNPJCLIENT","string",NIL,"Property cCNPJCLIENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCNPJEMI           :=  WSAdvValue( oResponse,"_CNPJEMI","string",NIL,"Property cCNPJEMI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lCONTLOOP          :=  WSAdvValue( oResponse,"_CONTLOOP","boolean",NIL,"Property lCONTLOOP as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::dDATAEMISS         :=  WSAdvValue( oResponse,"_DATAEMISS","date",NIL,"Property dDATAEMISS as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lDELMANUAL         :=  WSAdvValue( oResponse,"_DELMANUAL","boolean",NIL,"Property lDELMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nDESCTOTAL         :=  WSAdvValue( oResponse,"_DESCTOTAL","float",NIL,"Property nDESCTOTAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cKEYNOTA           :=  WSAdvValue( oResponse,"_KEYNOTA","string",NIL,"Property cKEYNOTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOMECLIENT        :=  WSAdvValue( oResponse,"_NOMECLIENT","string",NIL,"Property cNOMECLIENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nNUMNOTA           :=  WSAdvValue( oResponse,"_NUMNOTA","integer",NIL,"Property nNUMNOTA as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cORDAPLDESC        :=  WSAdvValue( oResponse,"_ORDAPLDESC","string",NIL,"Property cORDAPLDESC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cSERIENOTA         :=  WSAdvValue( oResponse,"_SERIENOTA","string",NIL,"Property cSERIENOTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSUBTOTAL          :=  WSAdvValue( oResponse,"_SUBTOTAL","float",NIL,"Property nSUBTOTAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTOTLIQUIDO        :=  WSAdvValue( oResponse,"_TOTLIQUIDO","float",NIL,"Property nTOTLIQUIDO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTPACRESC          :=  WSAdvValue( oResponse,"_TPACRESC","string",NIL,"Property cTPACRESC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTPDESCON          :=  WSAdvValue( oResponse,"_TPDESCON","string",NIL,"Property cTPDESCON as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTPDOCEMI          :=  WSAdvValue( oResponse,"_TPDOCEMI","integer",NIL,"Property nTPDOCEMI as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVALCANCTOT        :=  WSAdvValue( oResponse,"_VALCANCTOT","float",NIL,"Property nVALCANCTOT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFITDAVLSTLG

WSSTRUCT FRTPAFECF_ARRAYOFITDAVLSTLG
	WSDATA   oWSITDAVLSTLG             AS FRTPAFECF_ITDAVLSTLG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFITDAVLSTLG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFITDAVLSTLG
	::oWSITDAVLSTLG        := {} // Array Of  FRTPAFECF_ITDAVLSTLG():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFITDAVLSTLG
	Local oClone := FRTPAFECF_ARRAYOFITDAVLSTLG():NEW()
	oClone:oWSITDAVLSTLG := NIL
	If ::oWSITDAVLSTLG <> NIL 
		oClone:oWSITDAVLSTLG := {}
		aEval( ::oWSITDAVLSTLG , { |x| aadd( oClone:oWSITDAVLSTLG , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFITDAVLSTLG
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITDAVLSTLG","ITDAVLSTLG",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSITDAVLSTLG , FRTPAFECF_ITDAVLSTLG():New() )
			::oWSITDAVLSTLG[len(::oWSITDAVLSTLG)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFITDAVLIST

WSSTRUCT FRTPAFECF_ARRAYOFITDAVLIST
	WSDATA   oWSITDAVLIST              AS FRTPAFECF_ITDAVLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFITDAVLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFITDAVLIST
	::oWSITDAVLIST         := {} // Array Of  FRTPAFECF_ITDAVLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFITDAVLIST
	Local oClone := FRTPAFECF_ARRAYOFITDAVLIST():NEW()
	oClone:oWSITDAVLIST := NIL
	If ::oWSITDAVLIST <> NIL 
		oClone:oWSITDAVLIST := {}
		aEval( ::oWSITDAVLIST , { |x| aadd( oClone:oWSITDAVLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFITDAVLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITDAVLIST","ITDAVLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSITDAVLIST , FRTPAFECF_ITDAVLIST():New() )
			::oWSITDAVLIST[len(::oWSITDAVLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure CODPROD

WSSTRUCT FRTPAFECF_CODPROD
	WSDATA   cXPRODUTO                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_CODPROD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_CODPROD
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_CODPROD
	Local oClone := FRTPAFECF_CODPROD():NEW()
	oClone:cXPRODUTO            := ::cXPRODUTO
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTPAFECF_CODPROD
	Local cSoap := ""
	cSoap += WSSoapValue("XPRODUTO", ::cXPRODUTO, ::cXPRODUTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFPAGLIST

WSSTRUCT FRTPAFECF_ARRAYOFPAGLIST
	WSDATA   oWSPAGLIST                AS FRTPAFECF_PAGLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFPAGLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFPAGLIST
	::oWSPAGLIST           := {} // Array Of  FRTPAFECF_PAGLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFPAGLIST
	Local oClone := FRTPAFECF_ARRAYOFPAGLIST():NEW()
	oClone:oWSPAGLIST := NIL
	If ::oWSPAGLIST <> NIL 
		oClone:oWSPAGLIST := {}
		aEval( ::oWSPAGLIST , { |x| aadd( oClone:oWSPAGLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFPAGLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PAGLIST","PAGLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPAGLIST , FRTPAFECF_PAGLIST():New() )
			::oWSPAGLIST[len(::oWSPAGLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFFLOAT

WSSTRUCT FRTPAFECF_ARRAYOFFLOAT
	WSDATA   nFLOAT                    AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFFLOAT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFFLOAT
	::nFLOAT               := {} // Array Of  0.00
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFFLOAT
	Local oClone := FRTPAFECF_ARRAYOFFLOAT():NEW()
	oClone:nFLOAT               := IIf(::nFLOAT <> NIL , aClone(::nFLOAT) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFFLOAT
	Local oNodes1 :=  WSAdvValue( oResponse,"_FLOAT","float",{},NIL,.T.,"N",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::nFLOAT ,  val(x:TEXT)  ) } )
Return

// WSDL Data Structure ARRAYOFIMPLIST

WSSTRUCT FRTPAFECF_ARRAYOFIMPLIST
	WSDATA   oWSIMPLIST                AS FRTPAFECF_IMPLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ARRAYOFIMPLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ARRAYOFIMPLIST
	::oWSIMPLIST           := {} // Array Of  FRTPAFECF_IMPLIST():New()
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ARRAYOFIMPLIST
	Local oClone := FRTPAFECF_ARRAYOFIMPLIST():NEW()
	oClone:oWSIMPLIST := NIL
	If ::oWSIMPLIST <> NIL 
		oClone:oWSIMPLIST := {}
		aEval( ::oWSIMPLIST , { |x| aadd( oClone:oWSIMPLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ARRAYOFIMPLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_IMPLIST","IMPLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSIMPLIST , FRTPAFECF_IMPLIST():New() )
			::oWSIMPLIST[len(::oWSIMPLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ITDAVLSTLG

WSSTRUCT FRTPAFECF_ITDAVLSTLG
	WSDATA   nACREITEM                 AS float
	WSDATA   dALTERACAO                AS date
	WSDATA   cCODPROD                  AS string
	WSDATA   nDECQTDE                  AS integer
	WSDATA   nDECVLRUNT                AS integer
	WSDATA   nDESCITEM                 AS float
	WSDATA   cDESCRICAO                AS string
	WSDATA   cHORA                     AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   lITCANCEL                 AS boolean
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   nQUANTIDADE               AS float
	WSDATA   cTIPOALT                  AS string
	WSDATA   cTOTPARC                  AS string
	WSDATA   cUNMEDIDA                 AS string
	WSDATA   nVLRLIQ                   AS float
	WSDATA   nVLRUNIT                  AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ITDAVLSTLG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ITDAVLSTLG
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ITDAVLSTLG
	Local oClone := FRTPAFECF_ITDAVLSTLG():NEW()
	oClone:nACREITEM            := ::nACREITEM
	oClone:dALTERACAO           := ::dALTERACAO
	oClone:cCODPROD             := ::cCODPROD
	oClone:nDECQTDE             := ::nDECQTDE
	oClone:nDECVLRUNT           := ::nDECVLRUNT
	oClone:nDESCITEM            := ::nDESCITEM
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cHORA                := ::cHORA
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:lITCANCEL            := ::lITCANCEL
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:nQUANTIDADE          := ::nQUANTIDADE
	oClone:cTIPOALT             := ::cTIPOALT
	oClone:cTOTPARC             := ::cTOTPARC
	oClone:cUNMEDIDA            := ::cUNMEDIDA
	oClone:nVLRLIQ              := ::nVLRLIQ
	oClone:nVLRUNIT             := ::nVLRUNIT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ITDAVLSTLG
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nACREITEM          :=  WSAdvValue( oResponse,"_ACREITEM","float",NIL,"Property nACREITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::dALTERACAO         :=  WSAdvValue( oResponse,"_ALTERACAO","date",NIL,"Property dALTERACAO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cCODPROD           :=  WSAdvValue( oResponse,"_CODPROD","string",NIL,"Property cCODPROD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nDECQTDE           :=  WSAdvValue( oResponse,"_DECQTDE","integer",NIL,"Property nDECQTDE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDECVLRUNT         :=  WSAdvValue( oResponse,"_DECVLRUNT","integer",NIL,"Property nDECVLRUNT as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDESCITEM          :=  WSAdvValue( oResponse,"_DESCITEM","float",NIL,"Property nDESCITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHORA              :=  WSAdvValue( oResponse,"_HORA","string",NIL,"Property cHORA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lITCANCEL          :=  WSAdvValue( oResponse,"_ITCANCEL","boolean",NIL,"Property lITCANCEL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nQUANTIDADE        :=  WSAdvValue( oResponse,"_QUANTIDADE","float",NIL,"Property nQUANTIDADE as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTIPOALT           :=  WSAdvValue( oResponse,"_TIPOALT","string",NIL,"Property cTIPOALT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTOTPARC           :=  WSAdvValue( oResponse,"_TOTPARC","string",NIL,"Property cTOTPARC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUNMEDIDA          :=  WSAdvValue( oResponse,"_UNMEDIDA","string",NIL,"Property cUNMEDIDA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVLRLIQ            :=  WSAdvValue( oResponse,"_VLRLIQ","float",NIL,"Property nVLRLIQ as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVLRUNIT           :=  WSAdvValue( oResponse,"_VLRUNIT","float",NIL,"Property nVLRUNIT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ITDAVLIST

WSSTRUCT FRTPAFECF_ITDAVLIST
	WSDATA   nACREITEM                 AS float
	WSDATA   cCNPJ                     AS string
	WSDATA   cCODPROD                  AS string
	WSDATA   nDECQTDE                  AS integer
	WSDATA   nDECVLRUNT                AS integer
	WSDATA   nDESCITEM                 AS float
	WSDATA   cDESCRICAO                AS string
	WSDATA   dEMISSAO                  AS date
	WSDATA   lITCANCEL                 AS boolean
	WSDATA   nNUMITEM                  AS integer
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   nQUANTIDADE               AS float
	WSDATA   cTOTPARC                  AS string
	WSDATA   cUNMEDIDA                 AS string
	WSDATA   nVLRLIQ                   AS float
	WSDATA   nVLRUNIT                  AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_ITDAVLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_ITDAVLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_ITDAVLIST
	Local oClone := FRTPAFECF_ITDAVLIST():NEW()
	oClone:nACREITEM            := ::nACREITEM
	oClone:cCNPJ                := ::cCNPJ
	oClone:cCODPROD             := ::cCODPROD
	oClone:nDECQTDE             := ::nDECQTDE
	oClone:nDECVLRUNT           := ::nDECVLRUNT
	oClone:nDESCITEM            := ::nDESCITEM
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:dEMISSAO             := ::dEMISSAO
	oClone:lITCANCEL            := ::lITCANCEL
	oClone:nNUMITEM             := ::nNUMITEM
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:nQUANTIDADE          := ::nQUANTIDADE
	oClone:cTOTPARC             := ::cTOTPARC
	oClone:cUNMEDIDA            := ::cUNMEDIDA
	oClone:nVLRLIQ              := ::nVLRLIQ
	oClone:nVLRUNIT             := ::nVLRUNIT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_ITDAVLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nACREITEM          :=  WSAdvValue( oResponse,"_ACREITEM","float",NIL,"Property nACREITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCNPJ              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,"Property cCNPJ as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODPROD           :=  WSAdvValue( oResponse,"_CODPROD","string",NIL,"Property cCODPROD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nDECQTDE           :=  WSAdvValue( oResponse,"_DECQTDE","integer",NIL,"Property nDECQTDE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDECVLRUNT         :=  WSAdvValue( oResponse,"_DECVLRUNT","integer",NIL,"Property nDECVLRUNT as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDESCITEM          :=  WSAdvValue( oResponse,"_DESCITEM","float",NIL,"Property nDESCITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dEMISSAO           :=  WSAdvValue( oResponse,"_EMISSAO","date",NIL,"Property dEMISSAO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::lITCANCEL          :=  WSAdvValue( oResponse,"_ITCANCEL","boolean",NIL,"Property lITCANCEL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nNUMITEM           :=  WSAdvValue( oResponse,"_NUMITEM","integer",NIL,"Property nNUMITEM as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nQUANTIDADE        :=  WSAdvValue( oResponse,"_QUANTIDADE","float",NIL,"Property nQUANTIDADE as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTOTPARC           :=  WSAdvValue( oResponse,"_TOTPARC","string",NIL,"Property cTOTPARC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUNMEDIDA          :=  WSAdvValue( oResponse,"_UNMEDIDA","string",NIL,"Property cUNMEDIDA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVLRLIQ            :=  WSAdvValue( oResponse,"_VLRLIQ","float",NIL,"Property nVLRLIQ as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVLRUNIT           :=  WSAdvValue( oResponse,"_VLRUNIT","float",NIL,"Property nVLRUNIT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure PAGLIST

WSSTRUCT FRTPAFECF_PAGLIST
	WSDATA   lCANCELADO                AS boolean
	WSDATA   nCONTORDOP                AS integer
	WSDATA   cDESCTPPAG                AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   nNUMCONTDOC               AS integer
	WSDATA   nNUMCONTONF               AS integer
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   cSERPDV                   AS string
	WSDATA   cTIPODOC                  AS string
	WSDATA   cTIPOPAG                  AS string
	WSDATA   nVALOR                    AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_PAGLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_PAGLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_PAGLIST
	Local oClone := FRTPAFECF_PAGLIST():NEW()
	oClone:lCANCELADO           := ::lCANCELADO
	oClone:nCONTORDOP           := ::nCONTORDOP
	oClone:cDESCTPPAG           := ::cDESCTPPAG
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:nNUMCONTDOC          := ::nNUMCONTDOC
	oClone:nNUMCONTONF          := ::nNUMCONTONF
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:cSERPDV              := ::cSERPDV
	oClone:cTIPODOC             := ::cTIPODOC
	oClone:cTIPOPAG             := ::cTIPOPAG
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_PAGLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lCANCELADO         :=  WSAdvValue( oResponse,"_CANCELADO","boolean",NIL,"Property lCANCELADO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nCONTORDOP         :=  WSAdvValue( oResponse,"_CONTORDOP","integer",NIL,"Property nCONTORDOP as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDESCTPPAG         :=  WSAdvValue( oResponse,"_DESCTPPAG","string",NIL,"Property cDESCTPPAG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nNUMCONTDOC        :=  WSAdvValue( oResponse,"_NUMCONTDOC","integer",NIL,"Property nNUMCONTDOC as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNUMCONTONF        :=  WSAdvValue( oResponse,"_NUMCONTONF","integer",NIL,"Property nNUMCONTONF as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cSERPDV            :=  WSAdvValue( oResponse,"_SERPDV","string",NIL,"Property cSERPDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPODOC           :=  WSAdvValue( oResponse,"_TIPODOC","string",NIL,"Property cTIPODOC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPOPAG           :=  WSAdvValue( oResponse,"_TIPOPAG","string",NIL,"Property cTIPOPAG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVALOR             :=  WSAdvValue( oResponse,"_VALOR","float",NIL,"Property nVALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure IMPLIST

WSSTRUCT FRTPAFECF_IMPLIST
	WSDATA   cCODIGO                   AS string
	WSDATA   cCODSFI                   AS string
	WSDATA   lINCMANUAL                AS boolean
	WSDATA   lPAFMD5OK                 AS boolean
	WSDATA   nVALOR                    AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTPAFECF_IMPLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTPAFECF_IMPLIST
Return

WSMETHOD CLONE WSCLIENT FRTPAFECF_IMPLIST
	Local oClone := FRTPAFECF_IMPLIST():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cCODSFI              := ::cCODSFI
	oClone:lINCMANUAL           := ::lINCMANUAL
	oClone:lPAFMD5OK            := ::lPAFMD5OK
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTPAFECF_IMPLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODSFI            :=  WSAdvValue( oResponse,"_CODSFI","string",NIL,"Property cCODSFI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lINCMANUAL         :=  WSAdvValue( oResponse,"_INCMANUAL","boolean",NIL,"Property lINCMANUAL as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPAFMD5OK          :=  WSAdvValue( oResponse,"_PAFMD5OK","boolean",NIL,"Property lPAFMD5OK as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nVALOR             :=  WSAdvValue( oResponse,"_VALOR","float",NIL,"Property nVALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return