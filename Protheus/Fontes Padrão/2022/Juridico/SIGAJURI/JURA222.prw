#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://juridico.totvsbpo.com.br:8082/WSCOMARCA.apw?WSDL
Gerado em        08/19/16 16:16:14
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OTWQEPT ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service JURA222
------------------------------------------------------------------------------- */

WSCLIENT JURA222

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD MTALLCOMARCAS
	WSMETHOD MTCOMARCAS
	WSMETHOD MTCOMLOC2LOC3
	WSMETHOD MTLOC2N
	WSMETHOD MTLOC3N
	WSMETHOD MTMASCARAS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSUARIO                  AS string
	WSDATA   oWSMTALLCOMARCASRESULT    AS WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA
	WSDATA   cCCOD                     AS string
	WSDATA   cCDESC                    AS string
	WSDATA   cCUF                      AS string
	WSDATA   oWSMTCOMARCASRESULT       AS WSCOMARCA_STRUCOMARCA
	WSDATA   cCCODCOMAR                AS string
	WSDATA   cCDESCCOMAR               AS string
	WSDATA   cCCODLOC2N                AS string
	WSDATA   cCDESCLOC2N               AS string
	WSDATA   cCCODLOC3N                AS string
	WSDATA   cCDESCLOC3N               AS string
	WSDATA   oWSMTCOMLOC2LOC3RESULT    AS WSCOMARCA_STRUCOMLOC2LOC3
	WSDATA   cCCOMAR                   AS string
	WSDATA   oWSMTLOC2NRESULT          AS WSCOMARCA_STRULOC2N
	WSDATA   cCLOC2N                   AS string
	WSDATA   oWSMTLOC3NRESULT          AS WSCOMARCA_STRULOC3N
	WSDATA   oWSMTMASCARASRESULT       AS WSCOMARCA_STRUMASCARA

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA222
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160811 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA222
	::oWSMTALLCOMARCASRESULT := WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA():New()
	::oWSMTCOMARCASRESULT := WSCOMARCA_STRUCOMARCA():New()
	::oWSMTCOMLOC2LOC3RESULT := WSCOMARCA_STRUCOMLOC2LOC3():New()
	::oWSMTLOC2NRESULT   := WSCOMARCA_STRULOC2N():New()
	::oWSMTLOC3NRESULT   := WSCOMARCA_STRULOC3N():New()
	::oWSMTMASCARASRESULT := WSCOMARCA_STRUMASCARA():New()
Return

WSMETHOD RESET WSCLIENT JURA222
	::cUSUARIO           := NIL 
	::oWSMTALLCOMARCASRESULT := NIL 
	::cCCOD              := NIL 
	::cCDESC             := NIL 
	::cCUF               := NIL 
	::oWSMTCOMARCASRESULT := NIL 
	::cCCODCOMAR         := NIL 
	::cCDESCCOMAR        := NIL 
	::cCCODLOC2N         := NIL 
	::cCDESCLOC2N        := NIL 
	::cCCODLOC3N         := NIL 
	::cCDESCLOC3N        := NIL 
	::oWSMTCOMLOC2LOC3RESULT := NIL 
	::cCCOMAR            := NIL 
	::oWSMTLOC2NRESULT   := NIL 
	::cCLOC2N            := NIL 
	::oWSMTLOC3NRESULT   := NIL 
	::oWSMTMASCARASRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA222
Local oClone := JURA222():New()
	oClone:_URL          := ::_URL 
	oClone:cUSUARIO      := ::cUSUARIO
	oClone:oWSMTALLCOMARCASRESULT :=  IIF(::oWSMTALLCOMARCASRESULT = NIL , NIL ,::oWSMTALLCOMARCASRESULT:Clone() )
	oClone:cCCOD         := ::cCCOD
	oClone:cCDESC        := ::cCDESC
	oClone:cCUF          := ::cCUF
	oClone:oWSMTCOMARCASRESULT :=  IIF(::oWSMTCOMARCASRESULT = NIL , NIL ,::oWSMTCOMARCASRESULT:Clone() )
	oClone:cCCODCOMAR    := ::cCCODCOMAR
	oClone:cCDESCCOMAR   := ::cCDESCCOMAR
	oClone:cCCODLOC2N    := ::cCCODLOC2N
	oClone:cCDESCLOC2N   := ::cCDESCLOC2N
	oClone:cCCODLOC3N    := ::cCCODLOC3N
	oClone:cCDESCLOC3N   := ::cCDESCLOC3N
	oClone:oWSMTCOMLOC2LOC3RESULT :=  IIF(::oWSMTCOMLOC2LOC3RESULT = NIL , NIL ,::oWSMTCOMLOC2LOC3RESULT:Clone() )
	oClone:cCCOMAR       := ::cCCOMAR
	oClone:oWSMTLOC2NRESULT :=  IIF(::oWSMTLOC2NRESULT = NIL , NIL ,::oWSMTLOC2NRESULT:Clone() )
	oClone:cCLOC2N       := ::cCLOC2N
	oClone:oWSMTLOC3NRESULT :=  IIF(::oWSMTLOC3NRESULT = NIL , NIL ,::oWSMTLOC3NRESULT:Clone() )
	oClone:oWSMTMASCARASRESULT :=  IIF(::oWSMTMASCARASRESULT = NIL , NIL ,::oWSMTMASCARASRESULT:Clone() )
Return oClone

// WSDL Method MTALLCOMARCAS of Service JURA222

WSMETHOD MTALLCOMARCAS WSSEND cUSUARIO WSRECEIVE oWSMTALLCOMARCASRESULT WSCLIENT JURA222
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTALLCOMARCAS xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("USUARIO", ::cUSUARIO, cUSUARIO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTALLCOMARCAS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTALLCOMARCAS",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSCOMARCA.apw")

::Init()
::oWSMTALLCOMARCASRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTALLCOMARCASRESPONSE:_MTALLCOMARCASRESULT","ARRAYOFSTRUDADOSCOMARCA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MTCOMARCAS of Service JURA222

WSMETHOD MTCOMARCAS WSSEND cCCOD,cCDESC,cCUF WSRECEIVE oWSMTCOMARCASRESULT WSCLIENT JURA222
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTCOMARCAS xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("CCOD", ::cCCOD, cCCOD , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDESC", ::cCDESC, cCDESC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CUF", ::cCUF, cCUF , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTCOMARCAS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTCOMARCAS",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSCOMARCA.apw")

::Init()
::oWSMTCOMARCASRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTCOMARCASRESPONSE:_MTCOMARCASRESULT","STRUCOMARCA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MTCOMLOC2LOC3 of Service JURA222

WSMETHOD MTCOMLOC2LOC3 WSSEND cCCODCOMAR,cCDESCCOMAR,cCUF,cCCODLOC2N,cCDESCLOC2N,cCCODLOC3N,cCDESCLOC3N WSRECEIVE oWSMTCOMLOC2LOC3RESULT WSCLIENT JURA222
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTCOMLOC2LOC3 xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("CCODCOMAR", ::cCCODCOMAR, cCCODCOMAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDESCCOMAR", ::cCDESCCOMAR, cCDESCCOMAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CUF", ::cCUF, cCUF , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODLOC2N", ::cCCODLOC2N, cCCODLOC2N , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDESCLOC2N", ::cCDESCLOC2N, cCDESCLOC2N , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODLOC3N", ::cCCODLOC3N, cCCODLOC3N , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDESCLOC3N", ::cCDESCLOC3N, cCDESCLOC3N , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTCOMLOC2LOC3>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTCOMLOC2LOC3",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSCOMARCA.apw")

::Init()
::oWSMTCOMLOC2LOC3RESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTCOMLOC2LOC3RESPONSE:_MTCOMLOC2LOC3RESULT","STRUCOMLOC2LOC3",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MTLOC2N of Service JURA222

WSMETHOD MTLOC2N WSSEND cCCOD,cCDESC,cCCOMAR WSRECEIVE oWSMTLOC2NRESULT WSCLIENT JURA222
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTLOC2N xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("CCOD", ::cCCOD, cCCOD , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDESC", ::cCDESC, cCDESC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCOMAR", ::cCCOMAR, cCCOMAR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTLOC2N>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTLOC2N",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSCOMARCA.apw")

::Init()
::oWSMTLOC2NRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTLOC2NRESPONSE:_MTLOC2NRESULT","STRULOC2N",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MTLOC3N of Service JURA222

WSMETHOD MTLOC3N WSSEND cCCOD,cCDESC,cCLOC2N WSRECEIVE oWSMTLOC3NRESULT WSCLIENT JURA222
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTLOC3N xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("CCOD", ::cCCOD, cCCOD , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDESC", ::cCDESC, cCDESC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CLOC2N", ::cCLOC2N, cCLOC2N , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTLOC3N>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTLOC3N",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSCOMARCA.apw")

::Init()
::oWSMTLOC3NRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTLOC3NRESPONSE:_MTLOC3NRESULT","STRULOC3N",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MTMASCARAS of Service JURA222

WSMETHOD MTMASCARAS WSSEND cUSUARIO WSRECEIVE oWSMTMASCARASRESULT WSCLIENT JURA222
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTMASCARAS xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("USUARIO", ::cUSUARIO, cUSUARIO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTMASCARAS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTMASCARAS",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSCOMARCA.apw")

::Init()
::oWSMTMASCARASRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTMASCARASRESPONSE:_MTMASCARASRESULT","STRUMASCARA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFSTRUDADOSCOMARCA

WSSTRUCT WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA
	WSDATA   oWSSTRUDADOSCOMARCA       AS WSCOMARCA_STRUDADOSCOMARCA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA
	::oWSSTRUDADOSCOMARCA  := {} // Array Of  WSCOMARCA_STRUDADOSCOMARCA():New()
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA
	Local oClone := WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA():NEW()
	oClone:oWSSTRUDADOSCOMARCA := NIL
	If ::oWSSTRUDADOSCOMARCA <> NIL 
		oClone:oWSSTRUDADOSCOMARCA := {}
		aEval( ::oWSSTRUDADOSCOMARCA , { |x| aadd( oClone:oWSSTRUDADOSCOMARCA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUDADOSCOMARCA","STRUDADOSCOMARCA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUDADOSCOMARCA , WSCOMARCA_STRUDADOSCOMARCA():New() )
			::oWSSTRUDADOSCOMARCA[len(::oWSSTRUDADOSCOMARCA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STRUCOMARCA

WSSTRUCT WSCOMARCA_STRUCOMARCA
	WSDATA   oWSDADOS                  AS WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRUCOMARCA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRUCOMARCA
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRUCOMARCA
	Local oClone := WSCOMARCA_STRUCOMARCA():NEW()
	oClone:oWSDADOS             := IIF(::oWSDADOS = NIL , NIL , ::oWSDADOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRUCOMARCA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOS","ARRAYOFSTRUDADOSCOMARCA",NIL,"Property oWSDADOS as s0:ARRAYOFSTRUDADOSCOMARCA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDADOS := WSCOMARCA_ARRAYOFSTRUDADOSCOMARCA():New()
		::oWSDADOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure STRUCOMLOC2LOC3

WSSTRUCT WSCOMARCA_STRUCOMLOC2LOC3
	WSDATA   oWSDADOS                  AS WSCOMARCA_ARRAYOFSTRUDADOSCOMLOC2LOC3
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRUCOMLOC2LOC3
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRUCOMLOC2LOC3
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRUCOMLOC2LOC3
	Local oClone := WSCOMARCA_STRUCOMLOC2LOC3():NEW()
	oClone:oWSDADOS             := IIF(::oWSDADOS = NIL , NIL , ::oWSDADOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRUCOMLOC2LOC3
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOS","ARRAYOFSTRUDADOSCOMLOC2LOC3",NIL,"Property oWSDADOS as s0:ARRAYOFSTRUDADOSCOMLOC2LOC3 on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDADOS := WSCOMARCA_ARRAYOFSTRUDADOSCOMLOC2LOC3():New()
		::oWSDADOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure STRULOC2N

WSSTRUCT WSCOMARCA_STRULOC2N
	WSDATA   oWSDADOS                  AS WSCOMARCA_ARRAYOFSTRUDADOSLOC2N
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRULOC2N
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRULOC2N
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRULOC2N
	Local oClone := WSCOMARCA_STRULOC2N():NEW()
	oClone:oWSDADOS             := IIF(::oWSDADOS = NIL , NIL , ::oWSDADOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRULOC2N
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOS","ARRAYOFSTRUDADOSLOC2N",NIL,"Property oWSDADOS as s0:ARRAYOFSTRUDADOSLOC2N on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDADOS := WSCOMARCA_ARRAYOFSTRUDADOSLOC2N():New()
		::oWSDADOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure STRULOC3N

WSSTRUCT WSCOMARCA_STRULOC3N
	WSDATA   oWSDADOS                  AS WSCOMARCA_ARRAYOFSTRUDADOSLOC3N
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRULOC3N
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRULOC3N
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRULOC3N
	Local oClone := WSCOMARCA_STRULOC3N():NEW()
	oClone:oWSDADOS             := IIF(::oWSDADOS = NIL , NIL , ::oWSDADOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRULOC3N
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOS","ARRAYOFSTRUDADOSLOC3N",NIL,"Property oWSDADOS as s0:ARRAYOFSTRUDADOSLOC3N on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDADOS := WSCOMARCA_ARRAYOFSTRUDADOSLOC3N():New()
		::oWSDADOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure STRUMASCARA

WSSTRUCT WSCOMARCA_STRUMASCARA
	WSDATA   oWSDADOS                  AS WSCOMARCA_ARRAYOFSTRUDADOSMASCARA
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRUMASCARA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRUMASCARA
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRUMASCARA
	Local oClone := WSCOMARCA_STRUMASCARA():NEW()
	oClone:oWSDADOS             := IIF(::oWSDADOS = NIL , NIL , ::oWSDADOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRUMASCARA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOS","ARRAYOFSTRUDADOSMASCARA",NIL,"Property oWSDADOS as s0:ARRAYOFSTRUDADOSMASCARA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDADOS := WSCOMARCA_ARRAYOFSTRUDADOSMASCARA():New()
		::oWSDADOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure STRUDADOSCOMARCA

WSSTRUCT WSCOMARCA_STRUDADOSCOMARCA
	WSDATA   cCODIGO                   AS string
	WSDATA   oWSDADOSLOC2N             AS WSCOMARCA_ARRAYOFSTRUDADOSLOC2N OPTIONAL
	WSDATA   cDESCRICAO                AS string
	WSDATA   cUF                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRUDADOSCOMARCA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRUDADOSCOMARCA
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRUDADOSCOMARCA
	Local oClone := WSCOMARCA_STRUDADOSCOMARCA():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:oWSDADOSLOC2N        := IIF(::oWSDADOSLOC2N = NIL , NIL , ::oWSDADOSLOC2N:Clone() )
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cUF                  := ::cUF
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRUDADOSCOMARCA
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_DADOSLOC2N","ARRAYOFSTRUDADOSLOC2N",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSDADOSLOC2N := WSCOMARCA_ARRAYOFSTRUDADOSLOC2N():New()
		::oWSDADOSLOC2N:SoapRecv(oNode2)
	EndIf
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUF                :=  WSAdvValue( oResponse,"_UF","string",NIL,"Property cUF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFSTRUDADOSCOMLOC2LOC3

WSSTRUCT WSCOMARCA_ARRAYOFSTRUDADOSCOMLOC2LOC3
	WSDATA   oWSSTRUDADOSCOMLOC2LOC3   AS WSCOMARCA_STRUDADOSCOMLOC2LOC3 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSCOMLOC2LOC3
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSCOMLOC2LOC3
	::oWSSTRUDADOSCOMLOC2LOC3 := {} // Array Of  WSCOMARCA_STRUDADOSCOMLOC2LOC3():New()
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSCOMLOC2LOC3
	Local oClone := WSCOMARCA_ARRAYOFSTRUDADOSCOMLOC2LOC3():NEW()
	oClone:oWSSTRUDADOSCOMLOC2LOC3 := NIL
	If ::oWSSTRUDADOSCOMLOC2LOC3 <> NIL 
		oClone:oWSSTRUDADOSCOMLOC2LOC3 := {}
		aEval( ::oWSSTRUDADOSCOMLOC2LOC3 , { |x| aadd( oClone:oWSSTRUDADOSCOMLOC2LOC3 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSCOMLOC2LOC3
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUDADOSCOMLOC2LOC3","STRUDADOSCOMLOC2LOC3",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUDADOSCOMLOC2LOC3 , WSCOMARCA_STRUDADOSCOMLOC2LOC3():New() )
			::oWSSTRUDADOSCOMLOC2LOC3[len(::oWSSTRUDADOSCOMLOC2LOC3)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSTRUDADOSLOC2N

WSSTRUCT WSCOMARCA_ARRAYOFSTRUDADOSLOC2N
	WSDATA   oWSSTRUDADOSLOC2N         AS WSCOMARCA_STRUDADOSLOC2N OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSLOC2N
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSLOC2N
	::oWSSTRUDADOSLOC2N    := {} // Array Of  WSCOMARCA_STRUDADOSLOC2N():New()
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSLOC2N
	Local oClone := WSCOMARCA_ARRAYOFSTRUDADOSLOC2N():NEW()
	oClone:oWSSTRUDADOSLOC2N := NIL
	If ::oWSSTRUDADOSLOC2N <> NIL 
		oClone:oWSSTRUDADOSLOC2N := {}
		aEval( ::oWSSTRUDADOSLOC2N , { |x| aadd( oClone:oWSSTRUDADOSLOC2N , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSLOC2N
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUDADOSLOC2N","STRUDADOSLOC2N",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUDADOSLOC2N , WSCOMARCA_STRUDADOSLOC2N():New() )
			::oWSSTRUDADOSLOC2N[len(::oWSSTRUDADOSLOC2N)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSTRUDADOSLOC3N

WSSTRUCT WSCOMARCA_ARRAYOFSTRUDADOSLOC3N
	WSDATA   oWSSTRUDADOSLOC3N         AS WSCOMARCA_STRUDADOSLOC3N OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSLOC3N
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSLOC3N
	::oWSSTRUDADOSLOC3N    := {} // Array Of  WSCOMARCA_STRUDADOSLOC3N():New()
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSLOC3N
	Local oClone := WSCOMARCA_ARRAYOFSTRUDADOSLOC3N():NEW()
	oClone:oWSSTRUDADOSLOC3N := NIL
	If ::oWSSTRUDADOSLOC3N <> NIL 
		oClone:oWSSTRUDADOSLOC3N := {}
		aEval( ::oWSSTRUDADOSLOC3N , { |x| aadd( oClone:oWSSTRUDADOSLOC3N , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSLOC3N
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUDADOSLOC3N","STRUDADOSLOC3N",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUDADOSLOC3N , WSCOMARCA_STRUDADOSLOC3N():New() )
			::oWSSTRUDADOSLOC3N[len(::oWSSTRUDADOSLOC3N)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSTRUDADOSMASCARA

WSSTRUCT WSCOMARCA_ARRAYOFSTRUDADOSMASCARA
	WSDATA   oWSSTRUDADOSMASCARA       AS WSCOMARCA_STRUDADOSMASCARA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSMASCARA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSMASCARA
	::oWSSTRUDADOSMASCARA  := {} // Array Of  WSCOMARCA_STRUDADOSMASCARA():New()
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSMASCARA
	Local oClone := WSCOMARCA_ARRAYOFSTRUDADOSMASCARA():NEW()
	oClone:oWSSTRUDADOSMASCARA := NIL
	If ::oWSSTRUDADOSMASCARA <> NIL 
		oClone:oWSSTRUDADOSMASCARA := {}
		aEval( ::oWSSTRUDADOSMASCARA , { |x| aadd( oClone:oWSSTRUDADOSMASCARA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_ARRAYOFSTRUDADOSMASCARA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUDADOSMASCARA","STRUDADOSMASCARA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUDADOSMASCARA , WSCOMARCA_STRUDADOSMASCARA():New() )
			::oWSSTRUDADOSMASCARA[len(::oWSSTRUDADOSMASCARA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STRUDADOSCOMLOC2LOC3

WSSTRUCT WSCOMARCA_STRUDADOSCOMLOC2LOC3
	WSDATA   cCODCOMARCA               AS string
	WSDATA   cCODLOC2N                 AS string
	WSDATA   cCODLOC3N                 AS string
	WSDATA   cDESCCOMARCA              AS string
	WSDATA   cDESCLOC2N                AS string
	WSDATA   cDESCLOC3N                AS string
	WSDATA   cUF                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRUDADOSCOMLOC2LOC3
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRUDADOSCOMLOC2LOC3
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRUDADOSCOMLOC2LOC3
	Local oClone := WSCOMARCA_STRUDADOSCOMLOC2LOC3():NEW()
	oClone:cCODCOMARCA          := ::cCODCOMARCA
	oClone:cCODLOC2N            := ::cCODLOC2N
	oClone:cCODLOC3N            := ::cCODLOC3N
	oClone:cDESCCOMARCA         := ::cDESCCOMARCA
	oClone:cDESCLOC2N           := ::cDESCLOC2N
	oClone:cDESCLOC3N           := ::cDESCLOC3N
	oClone:cUF                  := ::cUF
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRUDADOSCOMLOC2LOC3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODCOMARCA        :=  WSAdvValue( oResponse,"_CODCOMARCA","string",NIL,"Property cCODCOMARCA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODLOC2N          :=  WSAdvValue( oResponse,"_CODLOC2N","string",NIL,"Property cCODLOC2N as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODLOC3N          :=  WSAdvValue( oResponse,"_CODLOC3N","string",NIL,"Property cCODLOC3N as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCCOMARCA       :=  WSAdvValue( oResponse,"_DESCCOMARCA","string",NIL,"Property cDESCCOMARCA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCLOC2N         :=  WSAdvValue( oResponse,"_DESCLOC2N","string",NIL,"Property cDESCLOC2N as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCLOC3N         :=  WSAdvValue( oResponse,"_DESCLOC3N","string",NIL,"Property cDESCLOC3N as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUF                :=  WSAdvValue( oResponse,"_UF","string",NIL,"Property cUF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STRUDADOSLOC2N

WSSTRUCT WSCOMARCA_STRUDADOSLOC2N
	WSDATA   cCODIGO                   AS string
	WSDATA   oWSDADOSLOC3N             AS WSCOMARCA_ARRAYOFSTRUDADOSLOC3N OPTIONAL
	WSDATA   cDESCRICAO                AS string
	WSDATA   cENDERECO                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRUDADOSLOC2N
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRUDADOSLOC2N
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRUDADOSLOC2N
	Local oClone := WSCOMARCA_STRUDADOSLOC2N():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:oWSDADOSLOC3N        := IIF(::oWSDADOSLOC3N = NIL , NIL , ::oWSDADOSLOC3N:Clone() )
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cENDERECO            := ::cENDERECO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRUDADOSLOC2N
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_DADOSLOC3N","ARRAYOFSTRUDADOSLOC3N",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSDADOSLOC3N := WSCOMARCA_ARRAYOFSTRUDADOSLOC3N():New()
		::oWSDADOSLOC3N:SoapRecv(oNode2)
	EndIf
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cENDERECO          :=  WSAdvValue( oResponse,"_ENDERECO","string",NIL,"Property cENDERECO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STRUDADOSLOC3N

WSSTRUCT WSCOMARCA_STRUDADOSLOC3N
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRUDADOSLOC3N
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRUDADOSLOC3N
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRUDADOSLOC3N
	Local oClone := WSCOMARCA_STRUDADOSLOC3N():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRUDADOSLOC3N
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STRUDADOSMASCARA

WSSTRUCT WSCOMARCA_STRUDADOSMASCARA
	WSDATA   cCODCOMARCA               AS string
	WSDATA   cCODLOC2N                 AS string
	WSDATA   cCODLOC3N                 AS string
	WSDATA   cDESCOMARCA               AS string
	WSDATA   cDESLOC2N                 AS string
	WSDATA   cDESLOC3N                 AS string
	WSDATA   cMASCARA                  AS string
	WSDATA   cUF                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSCOMARCA_STRUDADOSMASCARA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSCOMARCA_STRUDADOSMASCARA
Return

WSMETHOD CLONE WSCLIENT WSCOMARCA_STRUDADOSMASCARA
	Local oClone := WSCOMARCA_STRUDADOSMASCARA():NEW()
	oClone:cCODCOMARCA          := ::cCODCOMARCA
	oClone:cCODLOC2N            := ::cCODLOC2N
	oClone:cCODLOC3N            := ::cCODLOC3N
	oClone:cDESCOMARCA          := ::cDESCOMARCA
	oClone:cDESLOC2N            := ::cDESLOC2N
	oClone:cDESLOC3N            := ::cDESLOC3N
	oClone:cMASCARA             := ::cMASCARA
	oClone:cUF                  := ::cUF
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSCOMARCA_STRUDADOSMASCARA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODCOMARCA        :=  WSAdvValue( oResponse,"_CODCOMARCA","string",NIL,"Property cCODCOMARCA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODLOC2N          :=  WSAdvValue( oResponse,"_CODLOC2N","string",NIL,"Property cCODLOC2N as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODLOC3N          :=  WSAdvValue( oResponse,"_CODLOC3N","string",NIL,"Property cCODLOC3N as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCOMARCA        :=  WSAdvValue( oResponse,"_DESCOMARCA","string",NIL,"Property cDESCOMARCA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESLOC2N          :=  WSAdvValue( oResponse,"_DESLOC2N","string",NIL,"Property cDESLOC2N as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESLOC3N          :=  WSAdvValue( oResponse,"_DESLOC3N","string",NIL,"Property cDESLOC3N as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMASCARA           :=  WSAdvValue( oResponse,"_MASCARA","string",NIL,"Property cMASCARA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUF                :=  WSAdvValue( oResponse,"_UF","string",NIL,"Property cUF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


