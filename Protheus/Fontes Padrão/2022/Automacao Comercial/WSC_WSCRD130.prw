#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/CRDINFOCART.apw?WSDL
Gerado em        09/13/21 19:07:51
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _XQKEQIR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCRDINFOCART
------------------------------------------------------------------------------- */

WSCLIENT WSCRDINFOCART

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ATUALIZACARTAO
	WSMETHOD PESQCARTAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSRSESSIONID             AS string
	WSDATA   cCODCLI                   AS string
	WSDATA   cLOJACLI                  AS string
	WSDATA   oWSATUALIZACARTAORESULT   AS CRDINFOCART_ARRAYOFWSINFO2
	WSDATA   cFILIAL                   AS string
	WSDATA   lLRECEBIMENTO             AS boolean
	WSDATA   oWSPESQCARTAORESULT       AS CRDINFOCART_ARRAYOFWSINFO1

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCRDINFOCART
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCRDINFOCART
	::oWSATUALIZACARTAORESULT := CRDINFOCART_ARRAYOFWSINFO2():New()
	::oWSPESQCARTAORESULT := CRDINFOCART_ARRAYOFWSINFO1():New()
Return

WSMETHOD RESET WSCLIENT WSCRDINFOCART
	::cUSRSESSIONID      := NIL 
	::cCODCLI            := NIL 
	::cLOJACLI           := NIL 
	::oWSATUALIZACARTAORESULT := NIL 
	::cFILIAL            := NIL 
	::lLRECEBIMENTO      := NIL 
	::oWSPESQCARTAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCRDINFOCART
Local oClone := WSCRDINFOCART():New()
	oClone:_URL          := ::_URL 
	oClone:cUSRSESSIONID := ::cUSRSESSIONID
	oClone:cCODCLI       := ::cCODCLI
	oClone:cLOJACLI      := ::cLOJACLI
	oClone:oWSATUALIZACARTAORESULT :=  IIF(::oWSATUALIZACARTAORESULT = NIL , NIL ,::oWSATUALIZACARTAORESULT:Clone() )
	oClone:cFILIAL       := ::cFILIAL
	oClone:lLRECEBIMENTO := ::lLRECEBIMENTO
	oClone:oWSPESQCARTAORESULT :=  IIF(::oWSPESQCARTAORESULT = NIL , NIL ,::oWSPESQCARTAORESULT:Clone() )
Return oClone

// WSDL Method ATUALIZACARTAO of Service WSCRDINFOCART

WSMETHOD ATUALIZACARTAO WSSEND cUSRSESSIONID,cCODCLI,cLOJACLI WSRECEIVE oWSATUALIZACARTAORESULT WSCLIENT WSCRDINFOCART
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ATUALIZACARTAO xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("USRSESSIONID", ::cUSRSESSIONID, cUSRSESSIONID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODCLI", ::cCODCLI, cCODCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJACLI", ::cLOJACLI, cLOJACLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ATUALIZACARTAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/ATUALIZACARTAO",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/CRDINFOCART.apw")

::Init()
::oWSATUALIZACARTAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_ATUALIZACARTAORESPONSE:_ATUALIZACARTAORESULT","ARRAYOFWSINFO2",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PESQCARTAO of Service WSCRDINFOCART

WSMETHOD PESQCARTAO WSSEND cUSRSESSIONID,cFILIAL,cCODCLI,cLOJACLI,lLRECEBIMENTO WSRECEIVE oWSPESQCARTAORESULT WSCLIENT WSCRDINFOCART
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PESQCARTAO xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("USRSESSIONID", ::cUSRSESSIONID, cUSRSESSIONID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODCLI", ::cCODCLI, cCODCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LOJACLI", ::cLOJACLI, cLOJACLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LRECEBIMENTO", ::lLRECEBIMENTO, lLRECEBIMENTO , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PESQCARTAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/PESQCARTAO",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/CRDINFOCART.apw")

::Init()
::oWSPESQCARTAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_PESQCARTAORESPONSE:_PESQCARTAORESULT","ARRAYOFWSINFO1",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFWSINFO2

WSSTRUCT CRDINFOCART_ARRAYOFWSINFO2
	WSDATA   oWSWSINFO2                AS CRDINFOCART_WSINFO2 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CRDINFOCART_ARRAYOFWSINFO2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CRDINFOCART_ARRAYOFWSINFO2
	::oWSWSINFO2           := {} // Array Of  CRDINFOCART_WSINFO2():New()
Return

WSMETHOD CLONE WSCLIENT CRDINFOCART_ARRAYOFWSINFO2
	Local oClone := CRDINFOCART_ARRAYOFWSINFO2():NEW()
	oClone:oWSWSINFO2 := NIL
	If ::oWSWSINFO2 <> NIL 
		oClone:oWSWSINFO2 := {}
		aEval( ::oWSWSINFO2 , { |x| aadd( oClone:oWSWSINFO2 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CRDINFOCART_ARRAYOFWSINFO2
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSINFO2","WSINFO2",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSINFO2 , CRDINFOCART_WSINFO2():New() )
			::oWSWSINFO2[len(::oWSWSINFO2)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFWSINFO1

WSSTRUCT CRDINFOCART_ARRAYOFWSINFO1
	WSDATA   oWSWSINFO1                AS CRDINFOCART_WSINFO1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CRDINFOCART_ARRAYOFWSINFO1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CRDINFOCART_ARRAYOFWSINFO1
	::oWSWSINFO1           := {} // Array Of  CRDINFOCART_WSINFO1():New()
Return

WSMETHOD CLONE WSCLIENT CRDINFOCART_ARRAYOFWSINFO1
	Local oClone := CRDINFOCART_ARRAYOFWSINFO1():NEW()
	oClone:oWSWSINFO1 := NIL
	If ::oWSWSINFO1 <> NIL 
		oClone:oWSWSINFO1 := {}
		aEval( ::oWSWSINFO1 , { |x| aadd( oClone:oWSWSINFO1 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CRDINFOCART_ARRAYOFWSINFO1
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSINFO1","WSINFO1",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSINFO1 , CRDINFOCART_WSINFO1():New() )
			::oWSWSINFO1[len(::oWSWSINFO1)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure WSINFO2

WSSTRUCT CRDINFOCART_WSINFO2
	WSDATA   lATIVO                    AS boolean
	WSDATA   cMENSAGEM                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CRDINFOCART_WSINFO2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CRDINFOCART_WSINFO2
Return

WSMETHOD CLONE WSCLIENT CRDINFOCART_WSINFO2
	Local oClone := CRDINFOCART_WSINFO2():NEW()
	oClone:lATIVO               := ::lATIVO
	oClone:cMENSAGEM            := ::cMENSAGEM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CRDINFOCART_WSINFO2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lATIVO             :=  WSAdvValue( oResponse,"_ATIVO","boolean",NIL,"Property lATIVO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cMENSAGEM          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,"Property cMENSAGEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure WSINFO1

WSSTRUCT CRDINFOCART_WSINFO1
	WSDATA   cCARTAO                   AS string
	WSDATA   cMENSAGEM                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CRDINFOCART_WSINFO1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CRDINFOCART_WSINFO1
Return

WSMETHOD CLONE WSCLIENT CRDINFOCART_WSINFO1
	Local oClone := CRDINFOCART_WSINFO1():NEW()
	oClone:cCARTAO              := ::cCARTAO
	oClone:cMENSAGEM            := ::cMENSAGEM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CRDINFOCART_WSINFO1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCARTAO            :=  WSAdvValue( oResponse,"_CARTAO","string",NIL,"Property cCARTAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMENSAGEM          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,"Property cMENSAGEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


