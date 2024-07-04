#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://127.0.0.1:76/LJESTORC.apw?WSDL
Gerado em        10/09/14 08:22:18
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TCZPPDQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLJESTORC
------------------------------------------------------------------------------- */

WSCLIENT WSLJESTORC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD LJESTORCBUS
	WSMETHOD LJESTORCCHQ
	WSMETHOD LJESTORCDEV
	WSMETHOD LJESTORCIT
	WSMETHOD LJESTORCPG
	WSMETHOD LJESTORCTIT
	WSMETHOD LJESTORCVRE

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCNUMCUPOM                AS string
	WSDATA   cCSERIE                   AS string
	WSDATA   cCEMPWS                   AS string
	WSDATA   cCFILWS                   AS string
	WSDATA   oWSLJESTORCBUSRESULT      AS LJESTORC_TRETORC
	WSDATA   lLPORTECX                 AS boolean
	WSDATA   oWSLJESTORCCHQRESULT      AS LJESTORC_TRETSEF
	WSDATA   cCORC                     AS string
	WSDATA   lLJESTORCDEVRESULT        AS boolean
	WSDATA   nNMOEDA                   AS integer
	WSDATA   oWSLJESTORCITRESULT       AS LJESTORC_TRETITORC
	WSDATA   oWSLJESTORCPGRESULT       AS LJESTORC_ARRAYOFTRETPGORC
	WSDATA   oWSLJESTORCTITRESULT      AS LJESTORC_ARRAYOFTRETSE1
	WSDATA   lLJESTORCVRERESULT        AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJESTORC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20141007] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJESTORC
	::oWSLJESTORCBUSRESULT := LJESTORC_TRETORC():New()
	::oWSLJESTORCCHQRESULT := LJESTORC_TRETSEF():New()
	::oWSLJESTORCITRESULT := LJESTORC_TRETITORC():New()
	::oWSLJESTORCPGRESULT := LJESTORC_ARRAYOFTRETPGORC():New()
	::oWSLJESTORCTITRESULT := LJESTORC_ARRAYOFTRETSE1():New()
Return

WSMETHOD RESET WSCLIENT WSLJESTORC
	::cCNUMCUPOM         := NIL 
	::cCSERIE            := NIL 
	::cCEMPWS            := NIL 
	::cCFILWS            := NIL 
	::oWSLJESTORCBUSRESULT := NIL 
	::lLPORTECX          := NIL 
	::oWSLJESTORCCHQRESULT := NIL 
	::cCORC              := NIL 
	::lLJESTORCDEVRESULT := NIL 
	::nNMOEDA            := NIL 
	::oWSLJESTORCITRESULT := NIL 
	::oWSLJESTORCPGRESULT := NIL 
	::oWSLJESTORCTITRESULT := NIL 
	::lLJESTORCVRERESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJESTORC
Local oClone := WSLJESTORC():New()
	oClone:_URL          := ::_URL 
	oClone:cCNUMCUPOM    := ::cCNUMCUPOM
	oClone:cCSERIE       := ::cCSERIE
	oClone:cCEMPWS       := ::cCEMPWS
	oClone:cCFILWS       := ::cCFILWS
	oClone:oWSLJESTORCBUSRESULT :=  IIF(::oWSLJESTORCBUSRESULT = NIL , NIL ,::oWSLJESTORCBUSRESULT:Clone() )
	oClone:lLPORTECX     := ::lLPORTECX
	oClone:oWSLJESTORCCHQRESULT :=  IIF(::oWSLJESTORCCHQRESULT = NIL , NIL ,::oWSLJESTORCCHQRESULT:Clone() )
	oClone:cCORC         := ::cCORC
	oClone:lLJESTORCDEVRESULT := ::lLJESTORCDEVRESULT
	oClone:nNMOEDA       := ::nNMOEDA
	oClone:oWSLJESTORCITRESULT :=  IIF(::oWSLJESTORCITRESULT = NIL , NIL ,::oWSLJESTORCITRESULT:Clone() )
	oClone:oWSLJESTORCPGRESULT :=  IIF(::oWSLJESTORCPGRESULT = NIL , NIL ,::oWSLJESTORCPGRESULT:Clone() )
	oClone:oWSLJESTORCTITRESULT :=  IIF(::oWSLJESTORCTITRESULT = NIL , NIL ,::oWSLJESTORCTITRESULT:Clone() )
	oClone:lLJESTORCVRERESULT := ::lLJESTORCVRERESULT
Return oClone

// WSDL Method LJESTORCBUS of Service WSLJESTORC

WSMETHOD LJESTORCBUS WSSEND cCNUMCUPOM,cCSERIE,cCEMPWS,cCFILWS WSRECEIVE oWSLJESTORCBUSRESULT WSCLIENT WSLJESTORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJESTORCBUS xmlns="http://127.0.0.1:76/">'
cSoap += WSSoapValue("CNUMCUPOM", ::cCNUMCUPOM, cCNUMCUPOM , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPWS", ::cCEMPWS, cCEMPWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILWS", ::cCFILWS, cCFILWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</LJESTORCBUS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:76/LJESTORCBUS",; 
	"DOCUMENT","http://127.0.0.1:76/",,"1.031217",; 
	"http://127.0.0.1:76/LJESTORC.apw")

::Init()
::oWSLJESTORCBUSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LJESTORCBUSRESPONSE:_LJESTORCBUSRESULT","TRETORC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJESTORCCHQ of Service WSLJESTORC

WSMETHOD LJESTORCCHQ WSSEND cCSERIE,cCNUMCUPOM,lLPORTECX,cCEMPWS,cCFILWS WSRECEIVE oWSLJESTORCCHQRESULT WSCLIENT WSLJESTORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJESTORCCHQ xmlns="http://127.0.0.1:76/">'
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CNUMCUPOM", ::cCNUMCUPOM, cCNUMCUPOM , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LPORTECX", ::lLPORTECX, lLPORTECX , "boolean", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPWS", ::cCEMPWS, cCEMPWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILWS", ::cCFILWS, cCFILWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</LJESTORCCHQ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:76/LJESTORCCHQ",; 
	"DOCUMENT","http://127.0.0.1:76/",,"1.031217",; 
	"http://127.0.0.1:76/LJESTORC.apw")

::Init()
::oWSLJESTORCCHQRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LJESTORCCHQRESPONSE:_LJESTORCCHQRESULT","TRETSEF",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJESTORCDEV of Service WSLJESTORC

WSMETHOD LJESTORCDEV WSSEND cCORC,cCEMPWS,cCFILWS WSRECEIVE lLJESTORCDEVRESULT WSCLIENT WSLJESTORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJESTORCDEV xmlns="http://127.0.0.1:76/">'
cSoap += WSSoapValue("CORC", ::cCORC, cCORC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPWS", ::cCEMPWS, cCEMPWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILWS", ::cCFILWS, cCFILWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</LJESTORCDEV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:76/LJESTORCDEV",; 
	"DOCUMENT","http://127.0.0.1:76/",,"1.031217",; 
	"http://127.0.0.1:76/LJESTORC.apw")

::Init()
::lLJESTORCDEVRESULT :=  WSAdvValue( oXmlRet,"_LJESTORCDEVRESPONSE:_LJESTORCDEVRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJESTORCIT of Service WSLJESTORC

WSMETHOD LJESTORCIT WSSEND cCORC,nNMOEDA,cCEMPWS,cCFILWS WSRECEIVE oWSLJESTORCITRESULT WSCLIENT WSLJESTORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJESTORCIT xmlns="http://127.0.0.1:76/">'
cSoap += WSSoapValue("CORC", ::cCORC, cCORC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NMOEDA", ::nNMOEDA, nNMOEDA , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPWS", ::cCEMPWS, cCEMPWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILWS", ::cCFILWS, cCFILWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</LJESTORCIT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:76/LJESTORCIT",; 
	"DOCUMENT","http://127.0.0.1:76/",,"1.031217",; 
	"http://127.0.0.1:76/LJESTORC.apw")

::Init()
::oWSLJESTORCITRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LJESTORCITRESPONSE:_LJESTORCITRESULT","TRETITORC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJESTORCPG of Service WSLJESTORC

WSMETHOD LJESTORCPG WSSEND cCORC,cCEMPWS,cCFILWS WSRECEIVE oWSLJESTORCPGRESULT WSCLIENT WSLJESTORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJESTORCPG xmlns="http://127.0.0.1:76/">'
cSoap += WSSoapValue("CORC", ::cCORC, cCORC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPWS", ::cCEMPWS, cCEMPWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILWS", ::cCFILWS, cCFILWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</LJESTORCPG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:76/LJESTORCPG",; 
	"DOCUMENT","http://127.0.0.1:76/",,"1.031217",; 
	"http://127.0.0.1:76/LJESTORC.apw")

::Init()
::oWSLJESTORCPGRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LJESTORCPGRESPONSE:_LJESTORCPGRESULT","ARRAYOFTRETPGORC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJESTORCTIT of Service WSLJESTORC

WSMETHOD LJESTORCTIT WSSEND cCSERIE,cCNUMCUPOM,cCEMPWS,cCFILWS WSRECEIVE oWSLJESTORCTITRESULT WSCLIENT WSLJESTORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJESTORCTIT xmlns="http://127.0.0.1:76/">'
cSoap += WSSoapValue("CSERIE", ::cCSERIE, cCSERIE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CNUMCUPOM", ::cCNUMCUPOM, cCNUMCUPOM , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPWS", ::cCEMPWS, cCEMPWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILWS", ::cCFILWS, cCFILWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</LJESTORCTIT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:76/LJESTORCTIT",; 
	"DOCUMENT","http://127.0.0.1:76/",,"1.031217",; 
	"http://127.0.0.1:76/LJESTORC.apw")

::Init()
::oWSLJESTORCTITRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LJESTORCTITRESPONSE:_LJESTORCTITRESULT","ARRAYOFTRETSE1",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJESTORCVRE of Service WSLJESTORC

WSMETHOD LJESTORCVRE WSSEND cCORC,cCEMPWS,cCFILWS WSRECEIVE lLJESTORCVRERESULT WSCLIENT WSLJESTORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJESTORCVRE xmlns="http://127.0.0.1:76/">'
cSoap += WSSoapValue("CORC", ::cCORC, cCORC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPWS", ::cCEMPWS, cCEMPWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILWS", ::cCFILWS, cCFILWS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</LJESTORCVRE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:76/LJESTORCVRE",; 
	"DOCUMENT","http://127.0.0.1:76/",,"1.031217",; 
	"http://127.0.0.1:76/LJESTORC.apw")

::Init()
::lLJESTORCVRERESULT :=  WSAdvValue( oXmlRet,"_LJESTORCVRERESPONSE:_LJESTORCVRERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TRETORC

WSSTRUCT LJESTORC_TRETORC
	WSDATA   lCLIPAD                   AS boolean
	WSDATA   nORC_ABAT                 AS float
	WSDATA   cORC_CLI                  AS string
	WSDATA   cORC_CUPOM                AS string
	WSDATA   nORC_DESC                 AS float
	WSDATA   cORC_DOCCANC              AS string
	WSDATA   cORC_DOCTEF               AS string
	WSDATA   cORC_EMISSAO              AS string
	WSDATA   cORC_FORMPG               AS string
	WSDATA   cORC_INSTITU              AS string
	WSDATA   cORC_LOJA                 AS string
	WSDATA   nORC_MOEDA                AS integer
	WSDATA   lORC_MOVFE                AS boolean
	WSDATA   cORC_OPERA                AS string
	WSDATA   cORC_PDV                  AS string
	WSDATA   cORC_PEDCLI               AS string
	WSDATA   cORC_SITUA                AS string
	WSDATA   cORC_STATUES              AS string
	WSDATA   cORC_STORC                AS string
	WSDATA   cORC_TIPO                 AS string
	WSDATA   cORC_VALID                AS string
	WSDATA   cORC_VEN                  AS string
	WSDATA   cORC_VENDTEF              AS string
	WSDATA   nORC_VLLIQ                AS float
	WSDATA   nORC_VLMER                AS float
	WSDATA   nORC_VLTOT                AS float
	WSDATA   cORCAMENTO                AS string
	WSDATA   cSERIE                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_TRETORC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_TRETORC
Return

WSMETHOD CLONE WSCLIENT LJESTORC_TRETORC
	Local oClone := LJESTORC_TRETORC():NEW()
	oClone:lCLIPAD              := ::lCLIPAD
	oClone:nORC_ABAT            := ::nORC_ABAT
	oClone:cORC_CLI             := ::cORC_CLI
	oClone:cORC_CUPOM           := ::cORC_CUPOM
	oClone:nORC_DESC            := ::nORC_DESC
	oClone:cORC_DOCCANC         := ::cORC_DOCCANC
	oClone:cORC_DOCTEF          := ::cORC_DOCTEF
	oClone:cORC_EMISSAO         := ::cORC_EMISSAO
	oClone:cORC_FORMPG          := ::cORC_FORMPG
	oClone:cORC_INSTITU         := ::cORC_INSTITU
	oClone:cORC_LOJA            := ::cORC_LOJA
	oClone:nORC_MOEDA           := ::nORC_MOEDA
	oClone:lORC_MOVFE           := ::lORC_MOVFE
	oClone:cORC_OPERA           := ::cORC_OPERA
	oClone:cORC_PDV             := ::cORC_PDV
	oClone:cORC_PEDCLI          := ::cORC_PEDCLI
	oClone:cORC_SITUA           := ::cORC_SITUA
	oClone:cORC_STATUES         := ::cORC_STATUES
	oClone:cORC_STORC           := ::cORC_STORC
	oClone:cORC_TIPO            := ::cORC_TIPO
	oClone:cORC_VALID           := ::cORC_VALID
	oClone:cORC_VEN             := ::cORC_VEN
	oClone:cORC_VENDTEF         := ::cORC_VENDTEF
	oClone:nORC_VLLIQ           := ::nORC_VLLIQ
	oClone:nORC_VLMER           := ::nORC_VLMER
	oClone:nORC_VLTOT           := ::nORC_VLTOT
	oClone:cORCAMENTO           := ::cORCAMENTO
	oClone:cSERIE               := ::cSERIE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_TRETORC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lCLIPAD            :=  WSAdvValue( oResponse,"_CLIPAD","boolean",NIL,"Property lCLIPAD as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nORC_ABAT          :=  WSAdvValue( oResponse,"_ORC_ABAT","float",NIL,"Property nORC_ABAT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cORC_CLI           :=  WSAdvValue( oResponse,"_ORC_CLI","string",NIL,"Property cORC_CLI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_CUPOM         :=  WSAdvValue( oResponse,"_ORC_CUPOM","string",NIL,"Property cORC_CUPOM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nORC_DESC          :=  WSAdvValue( oResponse,"_ORC_DESC","float",NIL,"Property nORC_DESC as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cORC_DOCCANC       :=  WSAdvValue( oResponse,"_ORC_DOCCANC","string",NIL,"Property cORC_DOCCANC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_DOCTEF        :=  WSAdvValue( oResponse,"_ORC_DOCTEF","string",NIL,"Property cORC_DOCTEF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_EMISSAO       :=  WSAdvValue( oResponse,"_ORC_EMISSAO","string",NIL,"Property cORC_EMISSAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_FORMPG        :=  WSAdvValue( oResponse,"_ORC_FORMPG","string",NIL,"Property cORC_FORMPG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_INSTITU       :=  WSAdvValue( oResponse,"_ORC_INSTITU","string",NIL,"Property cORC_INSTITU as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_LOJA          :=  WSAdvValue( oResponse,"_ORC_LOJA","string",NIL,"Property cORC_LOJA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nORC_MOEDA         :=  WSAdvValue( oResponse,"_ORC_MOEDA","integer",NIL,"Property nORC_MOEDA as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lORC_MOVFE         :=  WSAdvValue( oResponse,"_ORC_MOVFE","boolean",NIL,"Property lORC_MOVFE as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cORC_OPERA         :=  WSAdvValue( oResponse,"_ORC_OPERA","string",NIL,"Property cORC_OPERA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_PDV           :=  WSAdvValue( oResponse,"_ORC_PDV","string",NIL,"Property cORC_PDV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_PEDCLI        :=  WSAdvValue( oResponse,"_ORC_PEDCLI","string",NIL,"Property cORC_PEDCLI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_SITUA         :=  WSAdvValue( oResponse,"_ORC_SITUA","string",NIL,"Property cORC_SITUA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_STATUES       :=  WSAdvValue( oResponse,"_ORC_STATUES","string",NIL,"Property cORC_STATUES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_STORC         :=  WSAdvValue( oResponse,"_ORC_STORC","string",NIL,"Property cORC_STORC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_TIPO          :=  WSAdvValue( oResponse,"_ORC_TIPO","string",NIL,"Property cORC_TIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_VALID         :=  WSAdvValue( oResponse,"_ORC_VALID","string",NIL,"Property cORC_VALID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_VEN           :=  WSAdvValue( oResponse,"_ORC_VEN","string",NIL,"Property cORC_VEN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORC_VENDTEF       :=  WSAdvValue( oResponse,"_ORC_VENDTEF","string",NIL,"Property cORC_VENDTEF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nORC_VLLIQ         :=  WSAdvValue( oResponse,"_ORC_VLLIQ","float",NIL,"Property nORC_VLLIQ as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nORC_VLMER         :=  WSAdvValue( oResponse,"_ORC_VLMER","float",NIL,"Property nORC_VLMER as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nORC_VLTOT         :=  WSAdvValue( oResponse,"_ORC_VLTOT","float",NIL,"Property nORC_VLTOT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cORCAMENTO         :=  WSAdvValue( oResponse,"_ORCAMENTO","string",NIL,"Property cORCAMENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERIE             :=  WSAdvValue( oResponse,"_SERIE","string",NIL,"Property cSERIE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TRETSEF

WSSTRUCT LJESTORC_TRETSEF
	WSDATA   cEF_AGENCIA               AS string
	WSDATA   cEF_BANCO                 AS string
	WSDATA   cEF_CONTA                 AS string
	WSDATA   cEF_NUM                   AS string
	WSDATA   nEF_VALOR                 AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_TRETSEF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_TRETSEF
Return

WSMETHOD CLONE WSCLIENT LJESTORC_TRETSEF
	Local oClone := LJESTORC_TRETSEF():NEW()
	oClone:cEF_AGENCIA          := ::cEF_AGENCIA
	oClone:cEF_BANCO            := ::cEF_BANCO
	oClone:cEF_CONTA            := ::cEF_CONTA
	oClone:cEF_NUM              := ::cEF_NUM
	oClone:nEF_VALOR            := ::nEF_VALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_TRETSEF
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cEF_AGENCIA        :=  WSAdvValue( oResponse,"_EF_AGENCIA","string",NIL,"Property cEF_AGENCIA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cEF_BANCO          :=  WSAdvValue( oResponse,"_EF_BANCO","string",NIL,"Property cEF_BANCO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cEF_CONTA          :=  WSAdvValue( oResponse,"_EF_CONTA","string",NIL,"Property cEF_CONTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cEF_NUM            :=  WSAdvValue( oResponse,"_EF_NUM","string",NIL,"Property cEF_NUM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nEF_VALOR          :=  WSAdvValue( oResponse,"_EF_VALOR","float",NIL,"Property nEF_VALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure TRETITORC

WSSTRUCT LJESTORC_TRETITORC
	WSDATA   nORC_IMP                  AS float
	WSDATA   nORC_IMPIN                AS float
	WSDATA   oWSORC_ITENS              AS LJESTORC_ARRAYOFTRET_ITENS
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_TRETITORC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_TRETITORC
Return

WSMETHOD CLONE WSCLIENT LJESTORC_TRETITORC
	Local oClone := LJESTORC_TRETITORC():NEW()
	oClone:nORC_IMP             := ::nORC_IMP
	oClone:nORC_IMPIN           := ::nORC_IMPIN
	oClone:oWSORC_ITENS         := IIF(::oWSORC_ITENS = NIL , NIL , ::oWSORC_ITENS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_TRETITORC
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nORC_IMP           :=  WSAdvValue( oResponse,"_ORC_IMP","float",NIL,"Property nORC_IMP as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nORC_IMPIN         :=  WSAdvValue( oResponse,"_ORC_IMPIN","float",NIL,"Property nORC_IMPIN as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_ORC_ITENS","ARRAYOFTRET_ITENS",NIL,"Property oWSORC_ITENS as s0:ARRAYOFTRET_ITENS on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSORC_ITENS := LJESTORC_ARRAYOFTRET_ITENS():New()
		::oWSORC_ITENS:SoapRecv(oNode3)
	EndIf
Return

// WSDL Data Structure ARRAYOFTRETPGORC

WSSTRUCT LJESTORC_ARRAYOFTRETPGORC
	WSDATA   oWSTRETPGORC              AS LJESTORC_TRETPGORC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_ARRAYOFTRETPGORC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_ARRAYOFTRETPGORC
	::oWSTRETPGORC         := {} // Array Of  LJESTORC_TRETPGORC():New()
Return

WSMETHOD CLONE WSCLIENT LJESTORC_ARRAYOFTRETPGORC
	Local oClone := LJESTORC_ARRAYOFTRETPGORC():NEW()
	oClone:oWSTRETPGORC := NIL
	If ::oWSTRETPGORC <> NIL 
		oClone:oWSTRETPGORC := {}
		aEval( ::oWSTRETPGORC , { |x| aadd( oClone:oWSTRETPGORC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_ARRAYOFTRETPGORC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TRETPGORC","TRETPGORC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTRETPGORC , LJESTORC_TRETPGORC():New() )
			::oWSTRETPGORC[len(::oWSTRETPGORC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTRETSE1

WSSTRUCT LJESTORC_ARRAYOFTRETSE1
	WSDATA   oWSTRETSE1                AS LJESTORC_TRETSE1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_ARRAYOFTRETSE1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_ARRAYOFTRETSE1
	::oWSTRETSE1           := {} // Array Of  LJESTORC_TRETSE1():New()
Return

WSMETHOD CLONE WSCLIENT LJESTORC_ARRAYOFTRETSE1
	Local oClone := LJESTORC_ARRAYOFTRETSE1():NEW()
	oClone:oWSTRETSE1 := NIL
	If ::oWSTRETSE1 <> NIL 
		oClone:oWSTRETSE1 := {}
		aEval( ::oWSTRETSE1 , { |x| aadd( oClone:oWSTRETSE1 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_ARRAYOFTRETSE1
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TRETSE1","TRETSE1",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTRETSE1 , LJESTORC_TRETSE1():New() )
			::oWSTRETSE1[len(::oWSTRETSE1)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTRET_ITENS

WSSTRUCT LJESTORC_ARRAYOFTRET_ITENS
	WSDATA   oWSTRET_ITENS             AS LJESTORC_TRET_ITENS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_ARRAYOFTRET_ITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_ARRAYOFTRET_ITENS
	::oWSTRET_ITENS        := {} // Array Of  LJESTORC_TRET_ITENS():New()
Return

WSMETHOD CLONE WSCLIENT LJESTORC_ARRAYOFTRET_ITENS
	Local oClone := LJESTORC_ARRAYOFTRET_ITENS():NEW()
	oClone:oWSTRET_ITENS := NIL
	If ::oWSTRET_ITENS <> NIL 
		oClone:oWSTRET_ITENS := {}
		aEval( ::oWSTRET_ITENS , { |x| aadd( oClone:oWSTRET_ITENS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_ARRAYOFTRET_ITENS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TRET_ITENS","TRET_ITENS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTRET_ITENS , LJESTORC_TRET_ITENS():New() )
			::oWSTRET_ITENS[len(::oWSTRET_ITENS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TRETPGORC

WSSTRUCT LJESTORC_TRETPGORC
	WSDATA   cE1_PARCELA               AS string
	WSDATA   cL4_ADMINIS               AS string
	WSDATA   cL4_AGENCIA               AS string
	WSDATA   cL4_CHEQID                AS string
	WSDATA   cL4_COMP                  AS string
	WSDATA   cL4_CONTA                 AS string
	WSDATA   cL4_DATA                  AS string
	WSDATA   cL4_DATATEF               AS string
	WSDATA   cL4_DOCTEF                AS string
	WSDATA   cL4_FORMA                 AS string
	WSDATA   cL4_FORMAID               AS string
	WSDATA   nL4_MOEDA                 AS integer
	WSDATA   cL4_NSUTEF                AS string
	WSDATA   cL4_NUMCART               AS string
	WSDATA   nL4_RECNO                 AS integer
	WSDATA   nL4_VALOR                 AS float
	WSDATA   cL4DATA                   AS string
	WSDATA   cPORTE                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_TRETPGORC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_TRETPGORC
Return

WSMETHOD CLONE WSCLIENT LJESTORC_TRETPGORC
	Local oClone := LJESTORC_TRETPGORC():NEW()
	oClone:cE1_PARCELA          := ::cE1_PARCELA
	oClone:cL4_ADMINIS          := ::cL4_ADMINIS
	oClone:cL4_AGENCIA          := ::cL4_AGENCIA
	oClone:cL4_CHEQID           := ::cL4_CHEQID
	oClone:cL4_COMP             := ::cL4_COMP
	oClone:cL4_CONTA            := ::cL4_CONTA
	oClone:cL4_DATA             := ::cL4_DATA
	oClone:cL4_DATATEF          := ::cL4_DATATEF
	oClone:cL4_DOCTEF           := ::cL4_DOCTEF
	oClone:cL4_FORMA            := ::cL4_FORMA
	oClone:cL4_FORMAID          := ::cL4_FORMAID
	oClone:nL4_MOEDA            := ::nL4_MOEDA
	oClone:cL4_NSUTEF           := ::cL4_NSUTEF
	oClone:cL4_NUMCART          := ::cL4_NUMCART
	oClone:nL4_RECNO            := ::nL4_RECNO
	oClone:nL4_VALOR            := ::nL4_VALOR
	oClone:cL4DATA              := ::cL4DATA
	oClone:cPORTE               := ::cPORTE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_TRETPGORC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cE1_PARCELA        :=  WSAdvValue( oResponse,"_E1_PARCELA","string",NIL,"Property cE1_PARCELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_ADMINIS        :=  WSAdvValue( oResponse,"_L4_ADMINIS","string",NIL,"Property cL4_ADMINIS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_AGENCIA        :=  WSAdvValue( oResponse,"_L4_AGENCIA","string",NIL,"Property cL4_AGENCIA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_CHEQID         :=  WSAdvValue( oResponse,"_L4_CHEQID","string",NIL,"Property cL4_CHEQID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_COMP           :=  WSAdvValue( oResponse,"_L4_COMP","string",NIL,"Property cL4_COMP as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_CONTA          :=  WSAdvValue( oResponse,"_L4_CONTA","string",NIL,"Property cL4_CONTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_DATA           :=  WSAdvValue( oResponse,"_L4_DATA","string",NIL,"Property cL4_DATA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_DATATEF        :=  WSAdvValue( oResponse,"_L4_DATATEF","string",NIL,"Property cL4_DATATEF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_DOCTEF         :=  WSAdvValue( oResponse,"_L4_DOCTEF","string",NIL,"Property cL4_DOCTEF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_FORMA          :=  WSAdvValue( oResponse,"_L4_FORMA","string",NIL,"Property cL4_FORMA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_FORMAID        :=  WSAdvValue( oResponse,"_L4_FORMAID","string",NIL,"Property cL4_FORMAID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nL4_MOEDA          :=  WSAdvValue( oResponse,"_L4_MOEDA","integer",NIL,"Property nL4_MOEDA as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cL4_NSUTEF         :=  WSAdvValue( oResponse,"_L4_NSUTEF","string",NIL,"Property cL4_NSUTEF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL4_NUMCART        :=  WSAdvValue( oResponse,"_L4_NUMCART","string",NIL,"Property cL4_NUMCART as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nL4_RECNO          :=  WSAdvValue( oResponse,"_L4_RECNO","integer",NIL,"Property nL4_RECNO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nL4_VALOR          :=  WSAdvValue( oResponse,"_L4_VALOR","float",NIL,"Property nL4_VALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cL4DATA            :=  WSAdvValue( oResponse,"_L4DATA","string",NIL,"Property cL4DATA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPORTE             :=  WSAdvValue( oResponse,"_PORTE","string",NIL,"Property cPORTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TRETSE1

WSSTRUCT LJESTORC_TRETSE1
	WSDATA   oWSASE5                   AS LJESTORC_ARRAYOFTRETSE5 OPTIONAL
	WSDATA   cCHAVE                    AS string
	WSDATA   dE1_BAIXA                 AS date
	WSDATA   dE1_EMISSAO               AS date
	WSDATA   cE1_FLUXO                 AS string
	WSDATA   cE1_NUMCRD                AS string
	WSDATA   cE1_ORIGEM                AS string
	WSDATA   cE1_PARCELA               AS string
	WSDATA   cE1_PORTADO               AS string
	WSDATA   nE1_SALDO                 AS float
	WSDATA   cE1_SITUACA               AS string
	WSDATA   cE1_STATUS                AS string
	WSDATA   cE1_TIPO                  AS string
	WSDATA   nE1_VALOR                 AS float
	WSDATA   dE1_VENCTO                AS date
	WSDATA   nE1_VLRREAL               AS float
	WSDATA   nINDICE                   AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_TRETSE1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_TRETSE1
Return

WSMETHOD CLONE WSCLIENT LJESTORC_TRETSE1
	Local oClone := LJESTORC_TRETSE1():NEW()
	oClone:oWSASE5              := IIF(::oWSASE5 = NIL , NIL , ::oWSASE5:Clone() )
	oClone:cCHAVE               := ::cCHAVE
	oClone:dE1_BAIXA            := ::dE1_BAIXA
	oClone:dE1_EMISSAO          := ::dE1_EMISSAO
	oClone:cE1_FLUXO            := ::cE1_FLUXO
	oClone:cE1_NUMCRD           := ::cE1_NUMCRD
	oClone:cE1_ORIGEM           := ::cE1_ORIGEM
	oClone:cE1_PARCELA          := ::cE1_PARCELA
	oClone:cE1_PORTADO          := ::cE1_PORTADO
	oClone:nE1_SALDO            := ::nE1_SALDO
	oClone:cE1_SITUACA          := ::cE1_SITUACA
	oClone:cE1_STATUS           := ::cE1_STATUS
	oClone:cE1_TIPO             := ::cE1_TIPO
	oClone:nE1_VALOR            := ::nE1_VALOR
	oClone:dE1_VENCTO           := ::dE1_VENCTO
	oClone:nE1_VLRREAL          := ::nE1_VLRREAL
	oClone:nINDICE              := ::nINDICE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_TRETSE1
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ASE5","ARRAYOFTRETSE5",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSASE5 := LJESTORC_ARRAYOFTRETSE5():New()
		::oWSASE5:SoapRecv(oNode1)
	EndIf
	::cCHAVE             :=  WSAdvValue( oResponse,"_CHAVE","string",NIL,"Property cCHAVE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dE1_BAIXA          :=  WSAdvValue( oResponse,"_E1_BAIXA","date",NIL,"Property dE1_BAIXA as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dE1_EMISSAO        :=  WSAdvValue( oResponse,"_E1_EMISSAO","date",NIL,"Property dE1_EMISSAO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cE1_FLUXO          :=  WSAdvValue( oResponse,"_E1_FLUXO","string",NIL,"Property cE1_FLUXO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE1_NUMCRD         :=  WSAdvValue( oResponse,"_E1_NUMCRD","string",NIL,"Property cE1_NUMCRD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE1_ORIGEM         :=  WSAdvValue( oResponse,"_E1_ORIGEM","string",NIL,"Property cE1_ORIGEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE1_PARCELA        :=  WSAdvValue( oResponse,"_E1_PARCELA","string",NIL,"Property cE1_PARCELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE1_PORTADO        :=  WSAdvValue( oResponse,"_E1_PORTADO","string",NIL,"Property cE1_PORTADO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nE1_SALDO          :=  WSAdvValue( oResponse,"_E1_SALDO","float",NIL,"Property nE1_SALDO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cE1_SITUACA        :=  WSAdvValue( oResponse,"_E1_SITUACA","string",NIL,"Property cE1_SITUACA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE1_STATUS         :=  WSAdvValue( oResponse,"_E1_STATUS","string",NIL,"Property cE1_STATUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE1_TIPO           :=  WSAdvValue( oResponse,"_E1_TIPO","string",NIL,"Property cE1_TIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nE1_VALOR          :=  WSAdvValue( oResponse,"_E1_VALOR","float",NIL,"Property nE1_VALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::dE1_VENCTO         :=  WSAdvValue( oResponse,"_E1_VENCTO","date",NIL,"Property dE1_VENCTO as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::nE1_VLRREAL        :=  WSAdvValue( oResponse,"_E1_VLRREAL","float",NIL,"Property nE1_VLRREAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nINDICE            :=  WSAdvValue( oResponse,"_INDICE","integer",NIL,"Property nINDICE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure TRET_ITENS

WSSTRUCT LJESTORC_TRET_ITENS
	WSDATA   cL2_DESCRI                AS string
	WSDATA   cL2_PRODUTO               AS string
	WSDATA   nL2_QUANT                 AS float
	WSDATA   nL2_VLRITEM               AS float
	WSDATA   nL2_VRUNIT                AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_TRET_ITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_TRET_ITENS
Return

WSMETHOD CLONE WSCLIENT LJESTORC_TRET_ITENS
	Local oClone := LJESTORC_TRET_ITENS():NEW()
	oClone:cL2_DESCRI           := ::cL2_DESCRI
	oClone:cL2_PRODUTO          := ::cL2_PRODUTO
	oClone:nL2_QUANT            := ::nL2_QUANT
	oClone:nL2_VLRITEM          := ::nL2_VLRITEM
	oClone:nL2_VRUNIT           := ::nL2_VRUNIT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_TRET_ITENS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cL2_DESCRI         :=  WSAdvValue( oResponse,"_L2_DESCRI","string",NIL,"Property cL2_DESCRI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cL2_PRODUTO        :=  WSAdvValue( oResponse,"_L2_PRODUTO","string",NIL,"Property cL2_PRODUTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nL2_QUANT          :=  WSAdvValue( oResponse,"_L2_QUANT","float",NIL,"Property nL2_QUANT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nL2_VLRITEM        :=  WSAdvValue( oResponse,"_L2_VLRITEM","float",NIL,"Property nL2_VLRITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nL2_VRUNIT         :=  WSAdvValue( oResponse,"_L2_VRUNIT","float",NIL,"Property nL2_VRUNIT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFTRETSE5

WSSTRUCT LJESTORC_ARRAYOFTRETSE5
	WSDATA   oWSTRETSE5                AS LJESTORC_TRETSE5 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_ARRAYOFTRETSE5
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_ARRAYOFTRETSE5
	::oWSTRETSE5           := {} // Array Of  LJESTORC_TRETSE5():New()
Return

WSMETHOD CLONE WSCLIENT LJESTORC_ARRAYOFTRETSE5
	Local oClone := LJESTORC_ARRAYOFTRETSE5():NEW()
	oClone:oWSTRETSE5 := NIL
	If ::oWSTRETSE5 <> NIL 
		oClone:oWSTRETSE5 := {}
		aEval( ::oWSTRETSE5 , { |x| aadd( oClone:oWSTRETSE5 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_ARRAYOFTRETSE5
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TRETSE5","TRETSE5",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTRETSE5 , LJESTORC_TRETSE5():New() )
			::oWSTRETSE5[len(::oWSTRETSE5)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TRETSE5

WSSTRUCT LJESTORC_TRETSE5
	WSDATA   cCHAVE                    AS string
	WSDATA   cE5_AGENCIA               AS string
	WSDATA   cE5_BANCO                 AS string
	WSDATA   cE5_CONTA                 AS string
	WSDATA   dE5_DATA                  AS date
	WSDATA   cE5_MOTBX                 AS string
	WSDATA   cE5_RECPAG                AS string
	WSDATA   cE5_TIPO                  AS string
	WSDATA   cE5_TIPODOC               AS string
	WSDATA   nE5_VALOR                 AS float
	WSDATA   nINDICE                   AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJESTORC_TRETSE5
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJESTORC_TRETSE5
Return

WSMETHOD CLONE WSCLIENT LJESTORC_TRETSE5
	Local oClone := LJESTORC_TRETSE5():NEW()
	oClone:cCHAVE               := ::cCHAVE
	oClone:cE5_AGENCIA          := ::cE5_AGENCIA
	oClone:cE5_BANCO            := ::cE5_BANCO
	oClone:cE5_CONTA            := ::cE5_CONTA
	oClone:dE5_DATA             := ::dE5_DATA
	oClone:cE5_MOTBX            := ::cE5_MOTBX
	oClone:cE5_RECPAG           := ::cE5_RECPAG
	oClone:cE5_TIPO             := ::cE5_TIPO
	oClone:cE5_TIPODOC          := ::cE5_TIPODOC
	oClone:nE5_VALOR            := ::nE5_VALOR
	oClone:nINDICE              := ::nINDICE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJESTORC_TRETSE5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCHAVE             :=  WSAdvValue( oResponse,"_CHAVE","string",NIL,"Property cCHAVE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE5_AGENCIA        :=  WSAdvValue( oResponse,"_E5_AGENCIA","string",NIL,"Property cE5_AGENCIA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE5_BANCO          :=  WSAdvValue( oResponse,"_E5_BANCO","string",NIL,"Property cE5_BANCO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE5_CONTA          :=  WSAdvValue( oResponse,"_E5_CONTA","string",NIL,"Property cE5_CONTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dE5_DATA           :=  WSAdvValue( oResponse,"_E5_DATA","date",NIL,"Property dE5_DATA as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cE5_MOTBX          :=  WSAdvValue( oResponse,"_E5_MOTBX","string",NIL,"Property cE5_MOTBX as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE5_RECPAG         :=  WSAdvValue( oResponse,"_E5_RECPAG","string",NIL,"Property cE5_RECPAG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE5_TIPO           :=  WSAdvValue( oResponse,"_E5_TIPO","string",NIL,"Property cE5_TIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cE5_TIPODOC        :=  WSAdvValue( oResponse,"_E5_TIPODOC","string",NIL,"Property cE5_TIPODOC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nE5_VALOR          :=  WSAdvValue( oResponse,"_E5_VALOR","float",NIL,"Property nE5_VALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nINDICE            :=  WSAdvValue( oResponse,"_INDICE","integer",NIL,"Property nINDICE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return


