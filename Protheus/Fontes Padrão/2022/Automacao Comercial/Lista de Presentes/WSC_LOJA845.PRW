#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8090/ws/WSLOJA845.apw?WSDL
Gerado em        03/11/11 13:44:39
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.101007
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KWRJDSO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSLOJA845
------------------------------------------------------------------------------- */

WSCLIENT WSWSLOJA845

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD LJ845PESQC
	WSMETHOD LJ845RETD

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCEMP01                   AS string
	WSDATA   cCFIL01                   AS string
	WSDATA   cCLSTCMP01                AS string
	WSDATA   cCFILTRO                  AS string
	WSDATA   nNORDEM01                 AS integer
	WSDATA   lLTCBOX01                 AS boolean
	WSDATA   cCLCFG                    AS string
	WSDATA   oWSLJ845PESQCRESULT       AS WSLOJA845_ARRAYOFARETMOD
	WSDATA   cCEMP02                   AS string
	WSDATA   cCFIL02                   AS string
	WSDATA   cCALIAS01                 AS string
	WSDATA   cCQRYW                    AS string
	WSDATA   cCLSTCMP02                AS string
	WSDATA   nNORDEM02                 AS integer
	WSDATA   lLTCBOX02                 AS boolean
	WSDATA   oWSLJ845RETDRESULT        AS WSLOJA845_ARRAYOFARETMOD

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSLOJA845
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100601A-20100727] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSLOJA845
	::oWSLJ845PESQCRESULT := WSLOJA845_ARRAYOFARETMOD():New()
	::oWSLJ845RETDRESULT := WSLOJA845_ARRAYOFARETMOD():New()
Return

WSMETHOD RESET WSCLIENT WSWSLOJA845
	::cCEMP01            := NIL 
	::cCFIL01            := NIL 
	::cCLSTCMP01         := NIL 
	::cCFILTRO           := NIL 
	::nNORDEM01          := NIL 
	::lLTCBOX01          := NIL 
	::cCLCFG             := NIL 
	::oWSLJ845PESQCRESULT := NIL 
	::cCEMP02            := NIL 
	::cCFIL02            := NIL 
	::cCALIAS01          := NIL 
	::cCQRYW             := NIL 
	::cCLSTCMP02         := NIL 
	::nNORDEM02          := NIL 
	::lLTCBOX02          := NIL 
	::oWSLJ845RETDRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSLOJA845
Local oClone := WSWSLOJA845():New()
	oClone:_URL          := ::_URL 
	oClone:cCEMP01       := ::cCEMP01
	oClone:cCFIL01       := ::cCFIL01
	oClone:cCLSTCMP01    := ::cCLSTCMP01
	oClone:cCFILTRO      := ::cCFILTRO
	oClone:nNORDEM01     := ::nNORDEM01
	oClone:lLTCBOX01     := ::lLTCBOX01
	oClone:cCLCFG        := ::cCLCFG
	oClone:oWSLJ845PESQCRESULT :=  IIF(::oWSLJ845PESQCRESULT = NIL , NIL ,::oWSLJ845PESQCRESULT:Clone() )
	oClone:cCEMP02       := ::cCEMP02
	oClone:cCFIL02       := ::cCFIL02
	oClone:cCALIAS01     := ::cCALIAS01
	oClone:cCQRYW        := ::cCQRYW
	oClone:cCLSTCMP02    := ::cCLSTCMP02
	oClone:nNORDEM02     := ::nNORDEM02
	oClone:lLTCBOX02     := ::lLTCBOX02
	oClone:oWSLJ845RETDRESULT :=  IIF(::oWSLJ845RETDRESULT = NIL , NIL ,::oWSLJ845RETDRESULT:Clone() )
Return oClone

// WSDL Method LJ845PESQC of Service WSWSLOJA845

WSMETHOD LJ845PESQC WSSEND cCEMP01,cCFIL01,cCLSTCMP01,cCFILTRO,nNORDEM01,lLTCBOX01,cCLCFG WSRECEIVE oWSLJ845PESQCRESULT WSCLIENT WSWSLOJA845
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJ845PESQC xmlns="http://localhost:8090/ws/">'
cSoap += WSSoapValue("CEMP01", ::cCEMP01, cCEMP01 , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CFIL01", ::cCFIL01, cCFIL01 , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CLSTCMP01", ::cCLSTCMP01, cCLSTCMP01 , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CFILTRO", ::cCFILTRO, cCFILTRO , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("NORDEM01", ::nNORDEM01, nNORDEM01 , "integer", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("LTCBOX01", ::lLTCBOX01, lLTCBOX01 , "boolean", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CLCFG", ::cCLCFG, cCLCFG , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += "</LJ845PESQC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8090/ws/LJ845PESQC",; 
	"DOCUMENT","http://localhost:8090/ws/",,"1.031217",; 
	"http://localhost:8090/ws/WSLOJA845.apw")

::Init()
::oWSLJ845PESQCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LJ845PESQCRESPONSE:_LJ845PESQCRESULT","ARRAYOFARETMOD",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LJ845RETD of Service WSWSLOJA845

WSMETHOD LJ845RETD WSSEND cCEMP02,cCFIL02,cCALIAS01,cCQRYW,cCLSTCMP02,nNORDEM02,lLTCBOX02 WSRECEIVE oWSLJ845RETDRESULT WSCLIENT WSWSLOJA845
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LJ845RETD xmlns="http://localhost:8090/ws/">'
cSoap += WSSoapValue("CEMP02", ::cCEMP02, cCEMP02 , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CFIL02", ::cCFIL02, cCFIL02 , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CALIAS01", ::cCALIAS01, cCALIAS01 , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CQRYW", ::cCQRYW, cCQRYW , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("CLSTCMP02", ::cCLSTCMP02, cCLSTCMP02 , "string", .T. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("NORDEM02", ::nNORDEM02, nNORDEM02 , "integer", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("LTCBOX02", ::lLTCBOX02, lLTCBOX02 , "boolean", .F. , .F., 0 , NIL, .T.) 
cSoap += "</LJ845RETD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8090/ws/LJ845RETD",; 
	"DOCUMENT","http://localhost:8090/ws/",,"1.031217",; 
	"http://localhost:8090/ws/WSLOJA845.apw")

::Init()
::oWSLJ845RETDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LJ845RETDRESPONSE:_LJ845RETDRESULT","ARRAYOFARETMOD",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFARETMOD

WSSTRUCT WSLOJA845_ARRAYOFARETMOD
	WSDATA   oWSARETMOD                AS WSLOJA845_ARETMOD OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSLOJA845_ARRAYOFARETMOD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSLOJA845_ARRAYOFARETMOD
	::oWSARETMOD           := {} // Array Of  WSLOJA845_ARETMOD():New()
Return

WSMETHOD CLONE WSCLIENT WSLOJA845_ARRAYOFARETMOD
	Local oClone := WSLOJA845_ARRAYOFARETMOD():NEW()
	oClone:oWSARETMOD := NIL
	If ::oWSARETMOD <> NIL 
		oClone:oWSARETMOD := {}
		aEval( ::oWSARETMOD , { |x| aadd( oClone:oWSARETMOD , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSLOJA845_ARRAYOFARETMOD
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ARETMOD","ARETMOD",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSARETMOD , WSLOJA845_ARETMOD():New() )
			::oWSARETMOD[len(::oWSARETMOD)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARETMOD

WSSTRUCT WSLOJA845_ARETMOD
	WSDATA   cCRETORNO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSLOJA845_ARETMOD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSLOJA845_ARETMOD
Return

WSMETHOD CLONE WSCLIENT WSLOJA845_ARETMOD
	Local oClone := WSLOJA845_ARETMOD():NEW()
	oClone:cCRETORNO            := ::cCRETORNO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSLOJA845_ARETMOD
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCRETORNO          :=  WSAdvValue( oResponse,"_CRETORNO","string",NIL,"Property cCRETORNO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return