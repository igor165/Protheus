#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
   
/* ===============================================================================
WSDL Location    http://127.0.0.1:12345/FRTNCC.apw?WSDL
Gerado em        08/05/13 17:14:04
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JYTCTWO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFRTNCC
------------------------------------------------------------------------------- */

WSCLIENT WSFRTNCC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD FRTGETNCC

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCLIENTE                 AS string
	WSDATA   cCLOJACLI                 AS string
	WSDATA   cCENVELOPES               AS string
	WSDATA   cCEMPPDV                  AS string
	WSDATA   cCFILPDV                  AS string
	WSDATA   lLMVLJPDVPA               AS boolean
	WSDATA   dDDATAVALID               AS date
	WSDATA   lLIMPORT                  AS boolean
	WSDATA   cCNUMORC                  AS string
	WSDATA   oWSFRTGETNCCRESULT        AS FRTNCC_ARRAYOFWSRETABERTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFRTNCC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20120120] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFRTNCC
	::oWSFRTGETNCCRESULT := FRTNCC_ARRAYOFWSRETABERTO():New()
Return

WSMETHOD RESET WSCLIENT WSFRTNCC
	::cCCLIENTE          := NIL 
	::cCLOJACLI          := NIL 
	::cCENVELOPES        := NIL 
	::cCEMPPDV           := NIL 
	::cCFILPDV           := NIL 
	::lLMVLJPDVPA        := NIL 
	::dDDATAVALID        := NIL 
	::lLIMPORT           := NIL 
	::cCNUMORC           := NIL 
	::oWSFRTGETNCCRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFRTNCC
Local oClone := WSFRTNCC():New()
	oClone:_URL          := ::_URL 
	oClone:cCCLIENTE     := ::cCCLIENTE
	oClone:cCLOJACLI     := ::cCLOJACLI
	oClone:cCENVELOPES   := ::cCENVELOPES
	oClone:cCEMPPDV      := ::cCEMPPDV
	oClone:cCFILPDV      := ::cCFILPDV
	oClone:lLMVLJPDVPA   := ::lLMVLJPDVPA
	oClone:dDDATAVALID   := ::dDDATAVALID
	oClone:lLIMPORT      := ::lLIMPORT
	oClone:cCNUMORC      := ::cCNUMORC
	oClone:oWSFRTGETNCCRESULT :=  IIF(::oWSFRTGETNCCRESULT = NIL , NIL ,::oWSFRTGETNCCRESULT:Clone() )
Return oClone

// WSDL Method FRTGETNCC of Service WSFRTNCC

WSMETHOD FRTGETNCC WSSEND cCCLIENTE,cCLOJACLI,cCENVELOPES,cCEMPPDV,cCFILPDV,lLMVLJPDVPA,dDDATAVALID,lLIMPORT,cCNUMORC WSRECEIVE oWSFRTGETNCCRESULT WSCLIENT WSFRTNCC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FRTGETNCC xmlns="http://127.0.0.1:12345/">'
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CLOJACLI", ::cCLOJACLI, cCLOJACLI , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CENVELOPES", ::cCENVELOPES, cCENVELOPES , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LMVLJPDVPA", ::lLMVLJPDVPA, lLMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DDATAVALID", ::dDDATAVALID, dDDATAVALID , "date", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LIMPORT", ::lLIMPORT, lLIMPORT , "boolean", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CNUMORC", ::cCNUMORC, cCNUMORC , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</FRTGETNCC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:12345/FRTGETNCC",; 
	"DOCUMENT","http://127.0.0.1:12345/",,"1.031217",; 
	"http://127.0.0.1:12345/FRTNCC.apw")

::Init()
::oWSFRTGETNCCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_FRTGETNCCRESPONSE:_FRTGETNCCRESULT","ARRAYOFWSRETABERTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFWSRETABERTO

WSSTRUCT FRTNCC_ARRAYOFWSRETABERTO
	WSDATA   oWSWSRETABERTO            AS FRTNCC_WSRETABERTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTNCC_ARRAYOFWSRETABERTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTNCC_ARRAYOFWSRETABERTO
	::oWSWSRETABERTO       := {} // Array Of  FRTNCC_WSRETABERTO():New()
Return

WSMETHOD CLONE WSCLIENT FRTNCC_ARRAYOFWSRETABERTO
	Local oClone := FRTNCC_ARRAYOFWSRETABERTO():NEW()
	oClone:oWSWSRETABERTO := NIL
	If ::oWSWSRETABERTO <> NIL 
		oClone:oWSWSRETABERTO := {}
		aEval( ::oWSWSRETABERTO , { |x| aadd( oClone:oWSWSRETABERTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTNCC_ARRAYOFWSRETABERTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSRETABERTO","WSRETABERTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSRETABERTO , FRTNCC_WSRETABERTO():New() )
			::oWSWSRETABERTO[len(::oWSWSRETABERTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure WSRETABERTO

WSSTRUCT FRTNCC_WSRETABERTO
	WSDATA   dDATANCC                  AS date
	WSDATA   nMOEDA                    AS integer
	WSDATA   cMVMOEDA                  AS string
	WSDATA   nNUMRECNO                 AS integer
	WSDATA   cNUMTITULO                AS string
	WSDATA   cPARCELA                  AS string
	WSDATA   cPREFIXO                  AS string
	WSDATA   nSALDO                    AS float
	WSDATA   nSALDO2                   AS float
	WSDATA   lSELECIONA                AS boolean
	WSDATA   cTIPO                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTNCC_WSRETABERTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTNCC_WSRETABERTO
Return

WSMETHOD CLONE WSCLIENT FRTNCC_WSRETABERTO
	Local oClone := FRTNCC_WSRETABERTO():NEW()
	oClone:dDATANCC             := ::dDATANCC
	oClone:nMOEDA               := ::nMOEDA
	oClone:cMVMOEDA             := ::cMVMOEDA
	oClone:nNUMRECNO            := ::nNUMRECNO
	oClone:cNUMTITULO           := ::cNUMTITULO
	oClone:cPARCELA             := ::cPARCELA
	oClone:cPREFIXO             := ::cPREFIXO
	oClone:nSALDO               := ::nSALDO
	oClone:nSALDO2              := ::nSALDO2
	oClone:lSELECIONA           := ::lSELECIONA
	oClone:cTIPO                := ::cTIPO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FRTNCC_WSRETABERTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::dDATANCC           :=  WSAdvValue( oResponse,"_DATANCC","date",NIL,"Property dDATANCC as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::nMOEDA             :=  WSAdvValue( oResponse,"_MOEDA","integer",NIL,"Property nMOEDA as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMVMOEDA           :=  WSAdvValue( oResponse,"_MVMOEDA","string",NIL,"Property cMVMOEDA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nNUMRECNO          :=  WSAdvValue( oResponse,"_NUMRECNO","integer",NIL,"Property nNUMRECNO as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNUMTITULO         :=  WSAdvValue( oResponse,"_NUMTITULO","string",NIL,"Property cNUMTITULO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPARCELA           :=  WSAdvValue( oResponse,"_PARCELA","string",NIL,"Property cPARCELA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPREFIXO           :=  WSAdvValue( oResponse,"_PREFIXO","string",NIL,"Property cPREFIXO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSALDO             :=  WSAdvValue( oResponse,"_SALDO","float",NIL,"Property nSALDO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSALDO2            :=  WSAdvValue( oResponse,"_SALDO2","float",NIL,"Property nSALDO2 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lSELECIONA         :=  WSAdvValue( oResponse,"_SELECIONA","boolean",NIL,"Property lSELECIONA as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


