#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:9110/LJRECEB.apw?WSDL
Gerado em        06/01/21 21:54:17
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _STNFNLE ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLJRECEB
------------------------------------------------------------------------------- */

WSCLIENT WSLJRECEB

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BAIXATITULO
	WSMETHOD ESTOTITREC
	WSMETHOD GERATITREC
	WSMETHOD GERATROCO
	WSMETHOD GETTITULO
	WSMETHOD GRAVACHEQUE
	WSMETHOD GRAVATABSLV
	WSMETHOD LJDELTIT
	WSMETHOD LJLOCKTIT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cMV_LJRECEB               AS string
	WSDATA   cPREFIXO                  AS string
	WSDATA   cNUMTITULO                AS string
	WSDATA   cPARCELA                  AS string
	WSDATA   dVENCIMENTO               AS date
	WSDATA   nVALOR                    AS float
	WSDATA   nVLRMULTA                 AS float
	WSDATA   nVLRJUROS                 AS float
	WSDATA   nVLRDESCONTO              AS float
	WSDATA   nVLRRECEBIDO              AS float
	WSDATA   cTIPO                     AS string
	WSDATA   cCCARTAO                  AS string
	WSDATA   cFILIALTIT                AS string
	WSDATA   cCTIPOPGTO                AS string
	WSDATA   cCNOMEUSER                AS string
	WSDATA   nVALABAT                  AS float
	WSDATA   cEMPPDV                   AS string
	WSDATA   cFILPDV                   AS string
	WSDATA   lMVLJPDVPA                AS boolean
	WSDATA   nVALTROCO                 AS float
	WSDATA   lPRIMBAIXA                AS boolean
	WSDATA   nTOTRECEB                 AS float
	WSDATA   cCNUMMOV                  AS string
	WSDATA   nBAIXATITULORESULT        AS float
	WSDATA   nVALORTOT                 AS float
	WSDATA   lSEMERRO                  AS boolean
	WSDATA   cERROS                    AS string
	WSDATA   oWSATITEST                AS LJRECEB_TITEST
	WSDATA   oWSESTOTITRECRESULT       AS LJRECEB_WSESTTIT
	WSDATA   cCFILIALG                 AS string
	WSDATA   cCPREFIXO                 AS string
	WSDATA   cCNUMERO                  AS string
	WSDATA   cCPARCELA                 AS string
	WSDATA   cCTIPO                    AS string
	WSDATA   cCODCLI                   AS string
	WSDATA   cLOJCLI                   AS string
	WSDATA   dDDATE                    AS date
	WSDATA   oWSAPGWS                  AS LJRECEB_WSPGTARR
	WSDATA   oWSAPGWSS                 AS LJRECEB_WSPGTARRS
	WSDATA   oWSATIT                   AS LJRECEB_WSTITS
	WSDATA   lGERATITRECRESULT         AS boolean
	WSDATA   nMOEDATRC                 AS integer
	WSDATA   lGERATROCORESULT          AS boolean
	WSDATA   cCPF                      AS string
	WSDATA   cCARTAO                   AS string
	WSDATA   cNUMRA                    AS string
	WSDATA   cTIPOPE                   AS string
	WSDATA   oWSGETTITULORESULT        AS LJRECEB_ARRAYOFWSTITULO
	WSDATA   cBANCO                    AS string
	WSDATA   cAGENCIA                  AS string
	WSDATA   cCONTA                    AS string
	WSDATA   cNUMERO                   AS string
	WSDATA   dDATA                     AS date
	WSDATA   cCOMPENSACAO              AS string
	WSDATA   cRG                       AS string
	WSDATA   cTELEFONE                 AS string
	WSDATA   lCHEQUETERCEIRO           AS boolean
	WSDATA   cEMITENTECHETER           AS string
	WSDATA   cGRAVACHEQUERESULT        AS string
	WSDATA   oWSADADOSSLV              AS LJRECEB_WSSLVARR
	WSDATA   lGRAVATABSLVRESULT        AS boolean
	WSDATA   cCCHAVE                   AS string
	WSDATA   cCNUMPDV                  AS string
	WSDATA   lLJDELTITRESULT           AS boolean
	WSDATA   lLJLOCKTITRESULT          AS boolean

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSTITEST                 AS LJRECEB_TITEST
	WSDATA   oWSWSPGTARR               AS LJRECEB_WSPGTARR
	WSDATA   oWSWSPGTARRS              AS LJRECEB_WSPGTARRS
	WSDATA   oWSWSTITS                 AS LJRECEB_WSTITS
	WSDATA   oWSWSSLVARR               AS LJRECEB_WSSLVARR

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJRECEB
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJRECEB
	::oWSATITEST         := LJRECEB_TITEST():New()
	::oWSESTOTITRECRESULT := LJRECEB_WSESTTIT():New()
	::oWSAPGWS           := LJRECEB_WSPGTARR():New()
	::oWSAPGWSS          := LJRECEB_WSPGTARRS():New()
	::oWSATIT            := LJRECEB_WSTITS():New()
	::oWSGETTITULORESULT := LJRECEB_ARRAYOFWSTITULO():New()
	::oWSADADOSSLV       := LJRECEB_WSSLVARR():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTITEST          := ::oWSATITEST
	::oWSWSPGTARR        := ::oWSAPGWS
	::oWSWSPGTARRS       := ::oWSAPGWSS
	::oWSWSTITS          := ::oWSATIT
	::oWSWSSLVARR        := ::oWSADADOSSLV
Return

WSMETHOD RESET WSCLIENT WSLJRECEB
	::cMV_LJRECEB        := NIL 
	::cPREFIXO           := NIL 
	::cNUMTITULO         := NIL 
	::cPARCELA           := NIL 
	::dVENCIMENTO        := NIL 
	::nVALOR             := NIL 
	::nVLRMULTA          := NIL 
	::nVLRJUROS          := NIL 
	::nVLRDESCONTO       := NIL 
	::nVLRRECEBIDO       := NIL 
	::cTIPO              := NIL 
	::cCCARTAO           := NIL 
	::cFILIALTIT         := NIL 
	::cCTIPOPGTO         := NIL 
	::cCNOMEUSER         := NIL 
	::nVALABAT           := NIL 
	::cEMPPDV            := NIL 
	::cFILPDV            := NIL 
	::lMVLJPDVPA         := NIL 
	::nVALTROCO          := NIL 
	::lPRIMBAIXA         := NIL 
	::nTOTRECEB          := NIL 
	::cCNUMMOV           := NIL 
	::nBAIXATITULORESULT := NIL 
	::nVALORTOT          := NIL 
	::lSEMERRO           := NIL 
	::cERROS             := NIL 
	::oWSATITEST         := NIL 
	::oWSESTOTITRECRESULT := NIL 
	::cCFILIALG          := NIL 
	::cCPREFIXO          := NIL 
	::cCNUMERO           := NIL 
	::cCPARCELA          := NIL 
	::cCTIPO             := NIL 
	::cCODCLI            := NIL 
	::cLOJCLI            := NIL 
	::dDDATE             := NIL 
	::oWSAPGWS           := NIL 
	::oWSAPGWSS          := NIL 
	::oWSATIT            := NIL 
	::lGERATITRECRESULT  := NIL 
	::nMOEDATRC          := NIL 
	::lGERATROCORESULT   := NIL 
	::cCPF               := NIL 
	::cCARTAO            := NIL 
	::cNUMRA             := NIL 
	::cTIPOPE            := NIL 
	::oWSGETTITULORESULT := NIL 
	::cBANCO             := NIL 
	::cAGENCIA           := NIL 
	::cCONTA             := NIL 
	::cNUMERO            := NIL 
	::dDATA              := NIL 
	::cCOMPENSACAO       := NIL 
	::cRG                := NIL 
	::cTELEFONE          := NIL 
	::lCHEQUETERCEIRO    := NIL 
	::cEMITENTECHETER    := NIL 
	::cGRAVACHEQUERESULT := NIL 
	::oWSADADOSSLV       := NIL 
	::lGRAVATABSLVRESULT := NIL 
	::cCCHAVE            := NIL 
	::cCNUMPDV           := NIL 
	::lLJDELTITRESULT    := NIL 
	::lLJLOCKTITRESULT   := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTITEST          := NIL
	::oWSWSPGTARR        := NIL
	::oWSWSPGTARRS       := NIL
	::oWSWSTITS          := NIL
	::oWSWSSLVARR        := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJRECEB
Local oClone := WSLJRECEB():New()
	oClone:_URL          := ::_URL 
	oClone:cMV_LJRECEB   := ::cMV_LJRECEB
	oClone:cPREFIXO      := ::cPREFIXO
	oClone:cNUMTITULO    := ::cNUMTITULO
	oClone:cPARCELA      := ::cPARCELA
	oClone:dVENCIMENTO   := ::dVENCIMENTO
	oClone:nVALOR        := ::nVALOR
	oClone:nVLRMULTA     := ::nVLRMULTA
	oClone:nVLRJUROS     := ::nVLRJUROS
	oClone:nVLRDESCONTO  := ::nVLRDESCONTO
	oClone:nVLRRECEBIDO  := ::nVLRRECEBIDO
	oClone:cTIPO         := ::cTIPO
	oClone:cCCARTAO      := ::cCCARTAO
	oClone:cFILIALTIT    := ::cFILIALTIT
	oClone:cCTIPOPGTO    := ::cCTIPOPGTO
	oClone:cCNOMEUSER    := ::cCNOMEUSER
	oClone:nVALABAT      := ::nVALABAT
	oClone:cEMPPDV       := ::cEMPPDV
	oClone:cFILPDV       := ::cFILPDV
	oClone:lMVLJPDVPA    := ::lMVLJPDVPA
	oClone:nVALTROCO     := ::nVALTROCO
	oClone:lPRIMBAIXA    := ::lPRIMBAIXA
	oClone:nTOTRECEB     := ::nTOTRECEB
	oClone:cCNUMMOV      := ::cCNUMMOV
	oClone:nBAIXATITULORESULT := ::nBAIXATITULORESULT
	oClone:nVALORTOT     := ::nVALORTOT
	oClone:lSEMERRO      := ::lSEMERRO
	oClone:cERROS        := ::cERROS
	oClone:oWSATITEST    :=  IIF(::oWSATITEST = NIL , NIL ,::oWSATITEST:Clone() )
	oClone:oWSESTOTITRECRESULT :=  IIF(::oWSESTOTITRECRESULT = NIL , NIL ,::oWSESTOTITRECRESULT:Clone() )
	oClone:cCFILIALG     := ::cCFILIALG
	oClone:cCPREFIXO     := ::cCPREFIXO
	oClone:cCNUMERO      := ::cCNUMERO
	oClone:cCPARCELA     := ::cCPARCELA
	oClone:cCTIPO        := ::cCTIPO
	oClone:cCODCLI       := ::cCODCLI
	oClone:cLOJCLI       := ::cLOJCLI
	oClone:dDDATE        := ::dDDATE
	oClone:oWSAPGWS      :=  IIF(::oWSAPGWS = NIL , NIL ,::oWSAPGWS:Clone() )
	oClone:oWSAPGWSS     :=  IIF(::oWSAPGWSS = NIL , NIL ,::oWSAPGWSS:Clone() )
	oClone:oWSATIT       :=  IIF(::oWSATIT = NIL , NIL ,::oWSATIT:Clone() )
	oClone:lGERATITRECRESULT := ::lGERATITRECRESULT
	oClone:nMOEDATRC     := ::nMOEDATRC
	oClone:lGERATROCORESULT := ::lGERATROCORESULT
	oClone:cCPF          := ::cCPF
	oClone:cCARTAO       := ::cCARTAO
	oClone:cNUMRA        := ::cNUMRA
	oClone:cTIPOPE       := ::cTIPOPE
	oClone:oWSGETTITULORESULT :=  IIF(::oWSGETTITULORESULT = NIL , NIL ,::oWSGETTITULORESULT:Clone() )
	oClone:cBANCO        := ::cBANCO
	oClone:cAGENCIA      := ::cAGENCIA
	oClone:cCONTA        := ::cCONTA
	oClone:cNUMERO       := ::cNUMERO
	oClone:dDATA         := ::dDATA
	oClone:cCOMPENSACAO  := ::cCOMPENSACAO
	oClone:cRG           := ::cRG
	oClone:cTELEFONE     := ::cTELEFONE
	oClone:lCHEQUETERCEIRO := ::lCHEQUETERCEIRO
	oClone:cEMITENTECHETER := ::cEMITENTECHETER
	oClone:cGRAVACHEQUERESULT := ::cGRAVACHEQUERESULT
	oClone:oWSADADOSSLV  :=  IIF(::oWSADADOSSLV = NIL , NIL ,::oWSADADOSSLV:Clone() )
	oClone:lGRAVATABSLVRESULT := ::lGRAVATABSLVRESULT
	oClone:cCCHAVE       := ::cCCHAVE
	oClone:cCNUMPDV      := ::cCNUMPDV
	oClone:lLJDELTITRESULT := ::lLJDELTITRESULT
	oClone:lLJLOCKTITRESULT := ::lLJLOCKTITRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSTITEST     := oClone:oWSATITEST
	oClone:oWSWSPGTARR   := oClone:oWSAPGWS
	oClone:oWSWSPGTARRS  := oClone:oWSAPGWSS
	oClone:oWSWSTITS     := oClone:oWSATIT
	oClone:oWSWSSLVARR   := oClone:oWSADADOSSLV
Return oClone

// WSDL Method BAIXATITULO of Service WSLJRECEB

WSMETHOD BAIXATITULO WSSEND cMV_LJRECEB,cPREFIXO,cNUMTITULO,cPARCELA,dVENCIMENTO,nVALOR,nVLRMULTA,nVLRJUROS,nVLRDESCONTO,nVLRRECEBIDO,cTIPO,cCCARTAO,cFILIALTIT,cCTIPOPGTO,cCNOMEUSER,nVALABAT,cEMPPDV,cFILPDV,lMVLJPDVPA,nVALTROCO,lPRIMBAIXA,nTOTRECEB,cCNUMMOV WSRECEIVE nBAIXATITULORESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BAIXATITULO xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("MV_LJRECEB", ::cMV_LJRECEB, cMV_LJRECEB , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PREFIXO", ::cPREFIXO, cPREFIXO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NUMTITULO", ::cNUMTITULO, cNUMTITULO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PARCELA", ::cPARCELA, cPARCELA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VENCIMENTO", ::dVENCIMENTO, dVENCIMENTO , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VALOR", ::nVALOR, nVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLRMULTA", ::nVLRMULTA, nVLRMULTA , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLRJUROS", ::nVLRJUROS, nVLRJUROS , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLRDESCONTO", ::nVLRDESCONTO, nVLRDESCONTO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VLRRECEBIDO", ::nVLRRECEBIDO, nVLRRECEBIDO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCARTAO", ::cCCARTAO, cCCARTAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILIALTIT", ::cFILIALTIT, cFILIALTIT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CTIPOPGTO", ::cCTIPOPGTO, cCTIPOPGTO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNOMEUSER", ::cCNOMEUSER, cCNOMEUSER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VALABAT", ::nVALABAT, nVALABAT , "float", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPPDV", ::cEMPPDV, cEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPDV", ::cFILPDV, cFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MVLJPDVPA", ::lMVLJPDVPA, lMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VALTROCO", ::nVALTROCO, nVALTROCO , "float", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PRIMBAIXA", ::lPRIMBAIXA, lPRIMBAIXA , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TOTRECEB", ::nTOTRECEB, nTOTRECEB , "float", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNUMMOV", ::cCNUMMOV, cCNUMMOV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BAIXATITULO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/BAIXATITULO",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::nBAIXATITULORESULT :=  WSAdvValue( oXmlRet,"_BAIXATITULORESPONSE:_BAIXATITULORESULT:TEXT","float",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ESTOTITREC of Service WSLJRECEB

WSMETHOD ESTOTITREC WSSEND nVALORTOT,lSEMERRO,cERROS,oWSATITEST,cCNOMEUSER,cEMPPDV,cFILPDV WSRECEIVE oWSESTOTITRECRESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ESTOTITREC xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("VALORTOT", ::nVALORTOT, nVALORTOT , "float", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SEMERRO", ::lSEMERRO, lSEMERRO , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ERROS", ::cERROS, cERROS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ATITEST", ::oWSATITEST, oWSATITEST , "TITEST", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNOMEUSER", ::cCNOMEUSER, cCNOMEUSER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPPDV", ::cEMPPDV, cEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPDV", ::cFILPDV, cFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ESTOTITREC>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/ESTOTITREC",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::oWSESTOTITRECRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ESTOTITRECRESPONSE:_ESTOTITRECRESULT","WSESTTIT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GERATITREC of Service WSLJRECEB

WSMETHOD GERATITREC WSSEND cCFILIALG,cCPREFIXO,cCNUMERO,cCPARCELA,cCTIPO,cCODCLI,cLOJCLI,dDDATE,oWSAPGWS,oWSAPGWSS,oWSATIT,cEMPPDV,cFILPDV,lMVLJPDVPA WSRECEIVE lGERATITRECRESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GERATITREC xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("CFILIALG", ::cCFILIALG, cCFILIALG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPREFIXO", ::cCPREFIXO, cCPREFIXO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNUMERO", ::cCNUMERO, cCNUMERO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPARCELA", ::cCPARCELA, cCPARCELA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CTIPO", ::cCTIPO, cCTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODCLI", ::cCODCLI, cCODCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJCLI", ::cLOJCLI, cLOJCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DDATE", ::dDDATE, dDDATE , "date", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("APGWS", ::oWSAPGWS, oWSAPGWS , "WSPGTARR", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("APGWSS", ::oWSAPGWSS, oWSAPGWSS , "WSPGTARRS", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ATIT", ::oWSATIT, oWSATIT , "WSTITS", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPPDV", ::cEMPPDV, cEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPDV", ::cFILPDV, cFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MVLJPDVPA", ::lMVLJPDVPA, lMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GERATITREC>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/GERATITREC",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::lGERATITRECRESULT  :=  WSAdvValue( oXmlRet,"_GERATITRECRESPONSE:_GERATITRECRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GERATROCO of Service WSLJRECEB

WSMETHOD GERATROCO WSSEND nVALOR,nMOEDATRC,cCODCLI,cLOJCLI,oWSATITEST,cCNOMEUSER,cEMPPDV,cFILPDV WSRECEIVE lGERATROCORESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GERATROCO xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("VALOR", ::nVALOR, nVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MOEDATRC", ::nMOEDATRC, nMOEDATRC , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODCLI", ::cCODCLI, cCODCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJCLI", ::cLOJCLI, cLOJCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ATITEST", ::oWSATITEST, oWSATITEST , "TITEST", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNOMEUSER", ::cCNOMEUSER, cCNOMEUSER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPPDV", ::cEMPPDV, cEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPDV", ::cFILPDV, cFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GERATROCO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/GERATROCO",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::lGERATROCORESULT   :=  WSAdvValue( oXmlRet,"_GERATROCORESPONSE:_GERATROCORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETTITULO of Service WSLJRECEB

WSMETHOD GETTITULO WSSEND cMV_LJRECEB,cCODCLI,cLOJCLI,cCPF,cCARTAO,cNUMRA,cPREFIXO,cNUMTITULO,cPARCELA,cEMPPDV,cFILPDV,lMVLJPDVPA,cTIPOPE WSRECEIVE oWSGETTITULORESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETTITULO xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("MV_LJRECEB", ::cMV_LJRECEB, cMV_LJRECEB , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODCLI", ::cCODCLI, cCODCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJCLI", ::cLOJCLI, cLOJCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPF", ::cCPF, cCPF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CARTAO", ::cCARTAO, cCARTAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NUMRA", ::cNUMRA, cNUMRA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PREFIXO", ::cPREFIXO, cPREFIXO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NUMTITULO", ::cNUMTITULO, cNUMTITULO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PARCELA", ::cPARCELA, cPARCELA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPPDV", ::cEMPPDV, cEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPDV", ::cFILPDV, cFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MVLJPDVPA", ::lMVLJPDVPA, lMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPOPE", ::cTIPOPE, cTIPOPE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETTITULO>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETTITULO",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::oWSGETTITULORESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETTITULORESPONSE:_GETTITULORESULT","ARRAYOFWSTITULO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GRAVACHEQUE of Service WSLJRECEB

WSMETHOD GRAVACHEQUE WSSEND cBANCO,cAGENCIA,cCONTA,cNUMERO,nVALOR,dDATA,cCOMPENSACAO,cRG,cTELEFONE,lCHEQUETERCEIRO,cPREFIXO,cNUMTITULO,cPARCELA,cTIPO,cEMPPDV,cFILPDV,lMVLJPDVPA,cEMITENTECHETER WSRECEIVE cGRAVACHEQUERESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRAVACHEQUE xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("BANCO", ::cBANCO, cBANCO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AGENCIA", ::cAGENCIA, cAGENCIA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CONTA", ::cCONTA, cCONTA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NUMERO", ::cNUMERO, cNUMERO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VALOR", ::nVALOR, nVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DATA", ::dDATA, dDATA , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("COMPENSACAO", ::cCOMPENSACAO, cCOMPENSACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("RG", ::cRG, cRG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TELEFONE", ::cTELEFONE, cTELEFONE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CHEQUETERCEIRO", ::lCHEQUETERCEIRO, lCHEQUETERCEIRO , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PREFIXO", ::cPREFIXO, cPREFIXO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NUMTITULO", ::cNUMTITULO, cNUMTITULO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PARCELA", ::cPARCELA, cPARCELA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPPDV", ::cEMPPDV, cEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPDV", ::cFILPDV, cFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MVLJPDVPA", ::lMVLJPDVPA, lMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMITENTECHETER", ::cEMITENTECHETER, cEMITENTECHETER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRAVACHEQUE>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/GRAVACHEQUE",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::cGRAVACHEQUERESULT :=  WSAdvValue( oXmlRet,"_GRAVACHEQUERESPONSE:_GRAVACHEQUERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GRAVATABSLV of Service WSLJRECEB

WSMETHOD GRAVATABSLV WSSEND cEMPPDV,cFILPDV,lMVLJPDVPA,oWSADADOSSLV WSRECEIVE lGRAVATABSLVRESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRAVATABSLV xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("EMPPDV", ::cEMPPDV, cEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPDV", ::cFILPDV, cFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MVLJPDVPA", ::lMVLJPDVPA, lMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ADADOSSLV", ::oWSADADOSSLV, oWSADADOSSLV , "WSSLVARR", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GRAVATABSLV>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/GRAVATABSLV",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::lGRAVATABSLVRESULT :=  WSAdvValue( oXmlRet,"_GRAVATABSLVRESPONSE:_GRAVATABSLVRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJDELTIT of Service WSLJRECEB

WSMETHOD LJDELTIT WSSEND cCCHAVE,cCNUMPDV WSRECEIVE lLJDELTITRESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJDELTIT xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNUMPDV", ::cCNUMPDV, cCNUMPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LJDELTIT>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/LJDELTIT",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::lLJDELTITRESULT    :=  WSAdvValue( oXmlRet,"_LJDELTITRESPONSE:_LJDELTITRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJLOCKTIT of Service WSLJRECEB

WSMETHOD LJLOCKTIT WSSEND cCCHAVE,cCNUMPDV WSRECEIVE lLJLOCKTITRESULT WSCLIENT WSLJRECEB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJLOCKTIT xmlns="http://webservices.microsiga.com.br">'
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNUMPDV", ::cCNUMPDV, cCNUMPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LJLOCKTIT>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.microsiga.com.br/LJLOCKTIT",; 
	"DOCUMENT","http://webservices.microsiga.com.br",,"1.031217",; 
	"http://127.0.0.1:9110/LJRECEB.apw")

::Init()
::lLJLOCKTITRESULT   :=  WSAdvValue( oXmlRet,"_LJLOCKTITRESPONSE:_LJLOCKTITRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TITEST

WSSTRUCT LJRECEB_TITEST
	WSDATA   oWSVERARRAY               AS LJRECEB_ARRAYOFWSTITULO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_TITEST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_TITEST
Return

WSMETHOD CLONE WSCLIENT LJRECEB_TITEST
	Local oClone := LJRECEB_TITEST():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_TITEST
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSTITULO", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSESTTIT

WSSTRUCT LJRECEB_WSESTTIT
	WSDATA   cERROS                    AS string OPTIONAL
	WSDATA   lSEMERRO                  AS boolean OPTIONAL
	WSDATA   nVALORTOT                 AS float OPTIONAL
	WSDATA   oWSVERARRAY               AS LJRECEB_ARRAYOFWSESTTITARRAY OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSESTTIT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSESTTIT
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSESTTIT
	Local oClone := LJRECEB_WSESTTIT():NEW()
	oClone:cERROS               := ::cERROS
	oClone:lSEMERRO             := ::lSEMERRO
	oClone:nVALORTOT            := ::nVALORTOT
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJRECEB_WSESTTIT
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cERROS             :=  WSAdvValue( oResponse,"_ERROS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lSEMERRO           :=  WSAdvValue( oResponse,"_SEMERRO","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nVALORTOT          :=  WSAdvValue( oResponse,"_VALORTOT","float",NIL,NIL,NIL,"N",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_VERARRAY","ARRAYOFWSESTTITARRAY",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSVERARRAY := LJRECEB_ARRAYOFWSESTTITARRAY():New()
		::oWSVERARRAY:SoapRecv(oNode4)
	EndIf
Return

// WSDL Data Structure WSPGTARR

WSSTRUCT LJRECEB_WSPGTARR
	WSDATA   oWSVERARRAY               AS LJRECEB_ARRAYOFWSPGT
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSPGTARR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSPGTARR
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSPGTARR
	Local oClone := LJRECEB_WSPGTARR():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSPGTARR
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSPGT", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSPGTARRS

WSSTRUCT LJRECEB_WSPGTARRS
	WSDATA   oWSVERARRAY               AS LJRECEB_ARRAYOFWSPGTS
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSPGTARRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSPGTARRS
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSPGTARRS
	Local oClone := LJRECEB_WSPGTARRS():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSPGTARRS
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSPGTS", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSTITS

WSSTRUCT LJRECEB_WSTITS
	WSDATA   oWSVERARRAY               AS LJRECEB_ARRAYOFWSTIT
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSTITS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSTITS
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSTITS
	Local oClone := LJRECEB_WSTITS():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSTITS
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSTIT", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSTITULO

WSSTRUCT LJRECEB_ARRAYOFWSTITULO
	WSDATA   oWSWSTITULO               AS LJRECEB_WSTITULO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_ARRAYOFWSTITULO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_ARRAYOFWSTITULO
	::oWSWSTITULO          := {} // Array Of  LJRECEB_WSTITULO():New()
Return

WSMETHOD CLONE WSCLIENT LJRECEB_ARRAYOFWSTITULO
	Local oClone := LJRECEB_ARRAYOFWSTITULO():NEW()
	oClone:oWSWSTITULO := NIL
	If ::oWSWSTITULO <> NIL 
		oClone:oWSWSTITULO := {}
		aEval( ::oWSWSTITULO , { |x| aadd( oClone:oWSWSTITULO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_ARRAYOFWSTITULO
	Local cSoap := ""
	aEval( ::oWSWSTITULO , {|x| cSoap := cSoap  +  WSSoapValue("WSTITULO", x , x , "WSTITULO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJRECEB_ARRAYOFWSTITULO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSTITULO","WSTITULO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSTITULO , LJRECEB_WSTITULO():New() )
			::oWSWSTITULO[len(::oWSWSTITULO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure WSSLVARR

WSSTRUCT LJRECEB_WSSLVARR
	WSDATA   oWSVERARRAY               AS LJRECEB_ARRAYOFWSSTRUTSLV
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSSLVARR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSSLVARR
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSSLVARR
	Local oClone := LJRECEB_WSSLVARR():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSSLVARR
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSSTRUTSLV", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSESTTITARRAY

WSSTRUCT LJRECEB_ARRAYOFWSESTTITARRAY
	WSDATA   oWSWSESTTITARRAY          AS LJRECEB_WSESTTITARRAY OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_ARRAYOFWSESTTITARRAY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_ARRAYOFWSESTTITARRAY
	::oWSWSESTTITARRAY     := {} // Array Of  LJRECEB_WSESTTITARRAY():New()
Return

WSMETHOD CLONE WSCLIENT LJRECEB_ARRAYOFWSESTTITARRAY
	Local oClone := LJRECEB_ARRAYOFWSESTTITARRAY():NEW()
	oClone:oWSWSESTTITARRAY := NIL
	If ::oWSWSESTTITARRAY <> NIL 
		oClone:oWSWSESTTITARRAY := {}
		aEval( ::oWSWSESTTITARRAY , { |x| aadd( oClone:oWSWSESTTITARRAY , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJRECEB_ARRAYOFWSESTTITARRAY
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSESTTITARRAY","WSESTTITARRAY",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSESTTITARRAY , LJRECEB_WSESTTITARRAY():New() )
			::oWSWSESTTITARRAY[len(::oWSWSESTTITARRAY)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFWSPGT

WSSTRUCT LJRECEB_ARRAYOFWSPGT
	WSDATA   oWSWSPGT                  AS LJRECEB_WSPGT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_ARRAYOFWSPGT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_ARRAYOFWSPGT
	::oWSWSPGT             := {} // Array Of  LJRECEB_WSPGT():New()
Return

WSMETHOD CLONE WSCLIENT LJRECEB_ARRAYOFWSPGT
	Local oClone := LJRECEB_ARRAYOFWSPGT():NEW()
	oClone:oWSWSPGT := NIL
	If ::oWSWSPGT <> NIL 
		oClone:oWSWSPGT := {}
		aEval( ::oWSWSPGT , { |x| aadd( oClone:oWSWSPGT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_ARRAYOFWSPGT
	Local cSoap := ""
	aEval( ::oWSWSPGT , {|x| cSoap := cSoap  +  WSSoapValue("WSPGT", x , x , "WSPGT", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFWSPGTS

WSSTRUCT LJRECEB_ARRAYOFWSPGTS
	WSDATA   oWSWSPGTS                 AS LJRECEB_WSPGTS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_ARRAYOFWSPGTS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_ARRAYOFWSPGTS
	::oWSWSPGTS            := {} // Array Of  LJRECEB_WSPGTS():New()
Return

WSMETHOD CLONE WSCLIENT LJRECEB_ARRAYOFWSPGTS
	Local oClone := LJRECEB_ARRAYOFWSPGTS():NEW()
	oClone:oWSWSPGTS := NIL
	If ::oWSWSPGTS <> NIL 
		oClone:oWSWSPGTS := {}
		aEval( ::oWSWSPGTS , { |x| aadd( oClone:oWSWSPGTS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_ARRAYOFWSPGTS
	Local cSoap := ""
	aEval( ::oWSWSPGTS , {|x| cSoap := cSoap  +  WSSoapValue("WSPGTS", x , x , "WSPGTS", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFWSTIT

WSSTRUCT LJRECEB_ARRAYOFWSTIT
	WSDATA   oWSWSTIT                  AS LJRECEB_WSTIT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_ARRAYOFWSTIT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_ARRAYOFWSTIT
	::oWSWSTIT             := {} // Array Of  LJRECEB_WSTIT():New()
Return

WSMETHOD CLONE WSCLIENT LJRECEB_ARRAYOFWSTIT
	Local oClone := LJRECEB_ARRAYOFWSTIT():NEW()
	oClone:oWSWSTIT := NIL
	If ::oWSWSTIT <> NIL 
		oClone:oWSWSTIT := {}
		aEval( ::oWSWSTIT , { |x| aadd( oClone:oWSWSTIT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_ARRAYOFWSTIT
	Local cSoap := ""
	aEval( ::oWSWSTIT , {|x| cSoap := cSoap  +  WSSoapValue("WSTIT", x , x , "WSTIT", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure WSTITULO

WSSTRUCT LJRECEB_WSTITULO
	WSDATA   cCLIENTE                  AS string
	WSDATA   lCONCACRS                 AS boolean OPTIONAL
	WSDATA   cCONTRATO                 AS string
	WSDATA   dDTBAIXA                  AS date OPTIONAL
	WSDATA   cFILTIT                   AS string
	WSDATA   nINTERES                  AS float OPTIONAL
	WSDATA   cLOCK                     AS string OPTIONAL
	WSDATA   cLOJA                     AS string
	WSDATA   nMOEDA                    AS integer OPTIONAL
	WSDATA   nNUMRECNO                 AS integer
	WSDATA   cNUMTITULO                AS string
	WSDATA   cPARCELA                  AS string
	WSDATA   cPREFIXO                  AS string
	WSDATA   nSALDO                    AS float OPTIONAL
	WSDATA   lSELEAS                   AS boolean OPTIONAL
	WSDATA   cTIPO                     AS string
	WSDATA   nVALABAT                  AS float OPTIONAL
	WSDATA   nVALLIQ                   AS float OPTIONAL
	WSDATA   nVALOR                    AS float
	WSDATA   dVENCIMENTO               AS date
	WSDATA   dVENCORI                  AS date OPTIONAL
	WSDATA   nVLRACRES                 AS float OPTIONAL
	WSDATA   nVLRDESCONTO              AS float
	WSDATA   nVLRJUROS                 AS float
	WSDATA   nVLRMULTA                 AS float
	WSDATA   nVLRRECEBIDO              AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSTITULO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSTITULO
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSTITULO
	Local oClone := LJRECEB_WSTITULO():NEW()
	oClone:cCLIENTE             := ::cCLIENTE
	oClone:lCONCACRS            := ::lCONCACRS
	oClone:cCONTRATO            := ::cCONTRATO
	oClone:dDTBAIXA             := ::dDTBAIXA
	oClone:cFILTIT              := ::cFILTIT
	oClone:nINTERES             := ::nINTERES
	oClone:cLOCK                := ::cLOCK
	oClone:cLOJA                := ::cLOJA
	oClone:nMOEDA               := ::nMOEDA
	oClone:nNUMRECNO            := ::nNUMRECNO
	oClone:cNUMTITULO           := ::cNUMTITULO
	oClone:cPARCELA             := ::cPARCELA
	oClone:cPREFIXO             := ::cPREFIXO
	oClone:nSALDO               := ::nSALDO
	oClone:lSELEAS              := ::lSELEAS
	oClone:cTIPO                := ::cTIPO
	oClone:nVALABAT             := ::nVALABAT
	oClone:nVALLIQ              := ::nVALLIQ
	oClone:nVALOR               := ::nVALOR
	oClone:dVENCIMENTO          := ::dVENCIMENTO
	oClone:dVENCORI             := ::dVENCORI
	oClone:nVLRACRES            := ::nVLRACRES
	oClone:nVLRDESCONTO         := ::nVLRDESCONTO
	oClone:nVLRJUROS            := ::nVLRJUROS
	oClone:nVLRMULTA            := ::nVLRMULTA
	oClone:nVLRRECEBIDO         := ::nVLRRECEBIDO
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSTITULO
	Local cSoap := ""
	cSoap += WSSoapValue("CLIENTE", ::cCLIENTE, ::cCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONCACRS", ::lCONCACRS, ::lCONCACRS , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CONTRATO", ::cCONTRATO, ::cCONTRATO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DTBAIXA", ::dDTBAIXA, ::dDTBAIXA , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILTIT", ::cFILTIT, ::cFILTIT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INTERES", ::nINTERES, ::nINTERES , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOCK", ::cLOCK, ::cLOCK , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOJA", ::cLOJA, ::cLOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MOEDA", ::nMOEDA, ::nMOEDA , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUMRECNO", ::nNUMRECNO, ::nNUMRECNO , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUMTITULO", ::cNUMTITULO, ::cNUMTITULO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PARCELA", ::cPARCELA, ::cPARCELA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PREFIXO", ::cPREFIXO, ::cPREFIXO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SALDO", ::nSALDO, ::nSALDO , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SELEAS", ::lSELEAS, ::lSELEAS , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALABAT", ::nVALABAT, ::nVALABAT , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALLIQ", ::nVALLIQ, ::nVALLIQ , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALOR", ::nVALOR, ::nVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VENCIMENTO", ::dVENCIMENTO, ::dVENCIMENTO , "date", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VENCORI", ::dVENCORI, ::dVENCORI , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VLRACRES", ::nVLRACRES, ::nVLRACRES , "float", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VLRDESCONTO", ::nVLRDESCONTO, ::nVLRDESCONTO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VLRJUROS", ::nVLRJUROS, ::nVLRJUROS , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VLRMULTA", ::nVLRMULTA, ::nVLRMULTA , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VLRRECEBIDO", ::nVLRRECEBIDO, ::nVLRRECEBIDO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJRECEB_WSTITULO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCLIENTE           :=  WSAdvValue( oResponse,"_CLIENTE","string",NIL,"Property cCLIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lCONCACRS          :=  WSAdvValue( oResponse,"_CONCACRS","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cCONTRATO          :=  WSAdvValue( oResponse,"_CONTRATO","string",NIL,"Property cCONTRATO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dDTBAIXA           :=  WSAdvValue( oResponse,"_DTBAIXA","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cFILTIT            :=  WSAdvValue( oResponse,"_FILTIT","string",NIL,"Property cFILTIT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nINTERES           :=  WSAdvValue( oResponse,"_INTERES","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::cLOCK              :=  WSAdvValue( oResponse,"_LOCK","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLOJA              :=  WSAdvValue( oResponse,"_LOJA","string",NIL,"Property cLOJA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nMOEDA             :=  WSAdvValue( oResponse,"_MOEDA","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nNUMRECNO          :=  WSAdvValue( oResponse,"_NUMRECNO","integer",NIL,"Property nNUMRECNO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNUMTITULO         :=  WSAdvValue( oResponse,"_NUMTITULO","string",NIL,"Property cNUMTITULO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPARCELA           :=  WSAdvValue( oResponse,"_PARCELA","string",NIL,"Property cPARCELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPREFIXO           :=  WSAdvValue( oResponse,"_PREFIXO","string",NIL,"Property cPREFIXO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSALDO             :=  WSAdvValue( oResponse,"_SALDO","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::lSELEAS            :=  WSAdvValue( oResponse,"_SELEAS","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nVALABAT           :=  WSAdvValue( oResponse,"_VALABAT","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nVALLIQ            :=  WSAdvValue( oResponse,"_VALLIQ","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nVALOR             :=  WSAdvValue( oResponse,"_VALOR","float",NIL,"Property nVALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::dVENCIMENTO        :=  WSAdvValue( oResponse,"_VENCIMENTO","date",NIL,"Property dVENCIMENTO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dVENCORI           :=  WSAdvValue( oResponse,"_VENCORI","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::nVLRACRES          :=  WSAdvValue( oResponse,"_VLRACRES","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nVLRDESCONTO       :=  WSAdvValue( oResponse,"_VLRDESCONTO","float",NIL,"Property nVLRDESCONTO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVLRJUROS          :=  WSAdvValue( oResponse,"_VLRJUROS","float",NIL,"Property nVLRJUROS as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVLRMULTA          :=  WSAdvValue( oResponse,"_VLRMULTA","float",NIL,"Property nVLRMULTA as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVLRRECEBIDO       :=  WSAdvValue( oResponse,"_VLRRECEBIDO","float",NIL,"Property nVLRRECEBIDO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFWSSTRUTSLV

WSSTRUCT LJRECEB_ARRAYOFWSSTRUTSLV
	WSDATA   oWSWSSTRUTSLV             AS LJRECEB_WSSTRUTSLV OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_ARRAYOFWSSTRUTSLV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_ARRAYOFWSSTRUTSLV
	::oWSWSSTRUTSLV        := {} // Array Of  LJRECEB_WSSTRUTSLV():New()
Return

WSMETHOD CLONE WSCLIENT LJRECEB_ARRAYOFWSSTRUTSLV
	Local oClone := LJRECEB_ARRAYOFWSSTRUTSLV():NEW()
	oClone:oWSWSSTRUTSLV := NIL
	If ::oWSWSSTRUTSLV <> NIL 
		oClone:oWSWSSTRUTSLV := {}
		aEval( ::oWSWSSTRUTSLV , { |x| aadd( oClone:oWSWSSTRUTSLV , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_ARRAYOFWSSTRUTSLV
	Local cSoap := ""
	aEval( ::oWSWSSTRUTSLV , {|x| cSoap := cSoap  +  WSSoapValue("WSSTRUTSLV", x , x , "WSSTRUTSLV", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure WSESTTITARRAY

WSSTRUCT LJRECEB_WSESTTITARRAY
	WSDATA   cX                        AS string
	WSDATA   cY                        AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSESTTITARRAY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSESTTITARRAY
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSESTTITARRAY
	Local oClone := LJRECEB_WSESTTITARRAY():NEW()
	oClone:cX                   := ::cX
	oClone:cY                   := ::cY
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJRECEB_WSESTTITARRAY
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cX                 :=  WSAdvValue( oResponse,"_X","string",NIL,"Property cX as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cY                 :=  WSAdvValue( oResponse,"_Y","string",NIL,"Property cY as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure WSPGT

WSSTRUCT LJRECEB_WSPGT
	WSDATA   cAGECHQ                   AS string
	WSDATA   cAUTORIZ                  AS string OPTIONAL
	WSDATA   cBCOCHQ                   AS string
	WSDATA   lCHETER                   AS boolean OPTIONAL
	WSDATA   cCIDCART                  AS string OPTIONAL
	WSDATA   cCODADM                   AS string
	WSDATA   cCOMPENS                  AS string OPTIONAL
	WSDATA   cCTACHQ                   AS string
	WSDATA   dDATACH                   AS date OPTIONAL
	WSDATA   cECHETER                  AS string OPTIONAL
	WSDATA   cNSUDOC                   AS string OPTIONAL
	WSDATA   cNSUTEF                   AS string OPTIONAL
	WSDATA   cNUMERO                   AS string OPTIONAL
	WSDATA   cRG                       AS string OPTIONAL
	WSDATA   cTEL                      AS string OPTIONAL
	WSDATA   cTIPO                     AS string
	WSDATA   nVALOR                    AS float
	WSDATA   dVENCTO                   AS date
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSPGT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSPGT
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSPGT
	Local oClone := LJRECEB_WSPGT():NEW()
	oClone:cAGECHQ              := ::cAGECHQ
	oClone:cAUTORIZ             := ::cAUTORIZ
	oClone:cBCOCHQ              := ::cBCOCHQ
	oClone:lCHETER              := ::lCHETER
	oClone:cCIDCART             := ::cCIDCART
	oClone:cCODADM              := ::cCODADM
	oClone:cCOMPENS             := ::cCOMPENS
	oClone:cCTACHQ              := ::cCTACHQ
	oClone:dDATACH              := ::dDATACH
	oClone:cECHETER             := ::cECHETER
	oClone:cNSUDOC              := ::cNSUDOC
	oClone:cNSUTEF              := ::cNSUTEF
	oClone:cNUMERO              := ::cNUMERO
	oClone:cRG                  := ::cRG
	oClone:cTEL                 := ::cTEL
	oClone:cTIPO                := ::cTIPO
	oClone:nVALOR               := ::nVALOR
	oClone:dVENCTO              := ::dVENCTO
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSPGT
	Local cSoap := ""
	cSoap += WSSoapValue("AGECHQ", ::cAGECHQ, ::cAGECHQ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("AUTORIZ", ::cAUTORIZ, ::cAUTORIZ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BCOCHQ", ::cBCOCHQ, ::cBCOCHQ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CHETER", ::lCHETER, ::lCHETER , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CIDCART", ::cCIDCART, ::cCIDCART , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODADM", ::cCODADM, ::cCODADM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("COMPENS", ::cCOMPENS, ::cCOMPENS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CTACHQ", ::cCTACHQ, ::cCTACHQ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATACH", ::dDATACH, ::dDATACH , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ECHETER", ::cECHETER, ::cECHETER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NSUDOC", ::cNSUDOC, ::cNSUDOC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NSUTEF", ::cNSUTEF, ::cNSUTEF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUMERO", ::cNUMERO, ::cNUMERO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RG", ::cRG, ::cRG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TEL", ::cTEL, ::cTEL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALOR", ::nVALOR, ::nVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VENCTO", ::dVENCTO, ::dVENCTO , "date", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSPGTS

WSSTRUCT LJRECEB_WSPGTS
	WSDATA   cFORMAST                  AS string
	WSDATA   nPARCELAST                AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSPGTS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSPGTS
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSPGTS
	Local oClone := LJRECEB_WSPGTS():NEW()
	oClone:cFORMAST             := ::cFORMAST
	oClone:nPARCELAST           := ::nPARCELAST
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSPGTS
	Local cSoap := ""
	cSoap += WSSoapValue("FORMAST", ::cFORMAST, ::cFORMAST , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PARCELAST", ::nPARCELAST, ::nPARCELAST , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSTIT

WSSTRUCT LJRECEB_WSTIT
	WSDATA   nMODULO                   AS float
	WSDATA   nTRECNO                   AS float
	WSDATA   lTSELE                    AS boolean
	WSDATA   cTTIPO                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSTIT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSTIT
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSTIT
	Local oClone := LJRECEB_WSTIT():NEW()
	oClone:nMODULO              := ::nMODULO
	oClone:nTRECNO              := ::nTRECNO
	oClone:lTSELE               := ::lTSELE
	oClone:cTTIPO               := ::cTTIPO
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSTIT
	Local cSoap := ""
	cSoap += WSSoapValue("MODULO", ::nMODULO, ::nMODULO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TRECNO", ::nTRECNO, ::nTRECNO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TSELE", ::lTSELE, ::lTSELE , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TTIPO", ::cTTIPO, ::cTTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure WSSTRUTSLV

WSSTRUCT LJRECEB_WSSTRUTSLV
	WSDATA   cAUTORIZ                  AS string
	WSDATA   cBANDEIRA                 AS string
	WSDATA   lCANTEF                   AS boolean
	WSDATA   cDATATEF                  AS string
	WSDATA   cDATCANC                  AS string
	WSDATA   cDOCCANC                  AS string
	WSDATA   cDOCTEF                   AS string
	WSDATA   cFORMA                    AS string
	WSDATA   cHORATEF                  AS string
	WSDATA   cHORCANC                  AS string
	WSDATA   cINSTITU                  AS string
	WSDATA   cNSUTEF                   AS string
	WSDATA   nRECSE5                   AS float
	WSDATA   cREDEAUT                  AS string
	WSDATA   cSEQOPER                  AS string
	WSDATA   cTIPCART                  AS string
	WSDATA   nVALOR                    AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJRECEB_WSSTRUTSLV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJRECEB_WSSTRUTSLV
Return

WSMETHOD CLONE WSCLIENT LJRECEB_WSSTRUTSLV
	Local oClone := LJRECEB_WSSTRUTSLV():NEW()
	oClone:cAUTORIZ             := ::cAUTORIZ
	oClone:cBANDEIRA            := ::cBANDEIRA
	oClone:lCANTEF              := ::lCANTEF
	oClone:cDATATEF             := ::cDATATEF
	oClone:cDATCANC             := ::cDATCANC
	oClone:cDOCCANC             := ::cDOCCANC
	oClone:cDOCTEF              := ::cDOCTEF
	oClone:cFORMA               := ::cFORMA
	oClone:cHORATEF             := ::cHORATEF
	oClone:cHORCANC             := ::cHORCANC
	oClone:cINSTITU             := ::cINSTITU
	oClone:cNSUTEF              := ::cNSUTEF
	oClone:nRECSE5              := ::nRECSE5
	oClone:cREDEAUT             := ::cREDEAUT
	oClone:cSEQOPER             := ::cSEQOPER
	oClone:cTIPCART             := ::cTIPCART
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJRECEB_WSSTRUTSLV
	Local cSoap := ""
	cSoap += WSSoapValue("AUTORIZ", ::cAUTORIZ, ::cAUTORIZ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BANDEIRA", ::cBANDEIRA, ::cBANDEIRA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CANTEF", ::lCANTEF, ::lCANTEF , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATATEF", ::cDATATEF, ::cDATATEF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DATCANC", ::cDATCANC, ::cDATCANC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DOCCANC", ::cDOCCANC, ::cDOCCANC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DOCTEF", ::cDOCTEF, ::cDOCTEF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FORMA", ::cFORMA, ::cFORMA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("HORATEF", ::cHORATEF, ::cHORATEF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("HORCANC", ::cHORCANC, ::cHORCANC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INSTITU", ::cINSTITU, ::cINSTITU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NSUTEF", ::cNSUTEF, ::cNSUTEF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RECSE5", ::nRECSE5, ::nRECSE5 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REDEAUT", ::cREDEAUT, ::cREDEAUT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEQOPER", ::cSEQOPER, ::cSEQOPER , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPCART", ::cTIPCART, ::cTIPCART , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALOR", ::nVALOR, ::nVALOR , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap