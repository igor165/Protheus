#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://juridico.totvsbpo.com.br:8082/WSINDICES.apw?WSDL
Gerado em        08/18/16 18:18:39
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _PTURCGK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service JURA217
------------------------------------------------------------------------------- */

WSCLIENT JURA217

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD MTINDICES
	WSMETHOD MTVALINDICES

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSUARIO                  AS string
	WSDATA   cSENHA                    AS string
	WSDATA   oWSMTINDICESRESULT        AS WSINDICES_STRUINDICE
	WSDATA   cCODINDICE                AS string
	WSDATA   cDESINDICE                AS string
	WSDATA   oWSMTVALINDICESRESULT     AS WSINDICES_STRUVALINDICE

ENDWSCLIENT

WSMETHOD NEW WSCLIENT JURA217
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT JURA217
	::oWSMTINDICESRESULT := WSINDICES_STRUINDICE():New()
	::oWSMTVALINDICESRESULT := WSINDICES_STRUVALINDICE():New()
Return

WSMETHOD RESET WSCLIENT JURA217
	::cUSUARIO           := NIL 
	::cSENHA             := NIL 
	::oWSMTINDICESRESULT := NIL 
	::cCODINDICE         := NIL 
	::cDESINDICE         := NIL 
	::oWSMTVALINDICESRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT JURA217
Local oClone := JURA217():New()
	oClone:_URL          := ::_URL 
	oClone:cUSUARIO      := ::cUSUARIO
	oClone:cSENHA        := ::cSENHA
	oClone:oWSMTINDICESRESULT :=  IIF(::oWSMTINDICESRESULT = NIL , NIL ,::oWSMTINDICESRESULT:Clone() )
	oClone:cCODINDICE    := ::cCODINDICE
	oClone:cDESINDICE    := ::cDESINDICE
	oClone:oWSMTVALINDICESRESULT :=  IIF(::oWSMTVALINDICESRESULT = NIL , NIL ,::oWSMTVALINDICESRESULT:Clone() )
Return oClone

// WSDL Method MTINDICES of Service JURA217

WSMETHOD MTINDICES WSSEND cUSUARIO,cSENHA WSRECEIVE oWSMTINDICESRESULT WSCLIENT JURA217
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTINDICES xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("USUARIO", ::cUSUARIO, cUSUARIO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("SENHA", ::cSENHA, cSENHA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTINDICES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTINDICES",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSINDICES.apw")

::Init()
::oWSMTINDICESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTINDICESRESPONSE:_MTINDICESRESULT","STRUINDICE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MTVALINDICES of Service JURA217

WSMETHOD MTVALINDICES WSSEND cUSUARIO,cSENHA,cCODINDICE,cDESINDICE WSRECEIVE oWSMTVALINDICESRESULT WSCLIENT JURA217
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MTVALINDICES xmlns="http://juridico.totvsbpo.com.br:8082/">'
cSoap += WSSoapValue("USUARIO", ::cUSUARIO, cUSUARIO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("SENHA", ::cSENHA, cSENHA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODINDICE", ::cCODINDICE, cCODINDICE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DESINDICE", ::cDESINDICE, cDESINDICE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</MTVALINDICES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://juridico.totvsbpo.com.br:8082/MTVALINDICES",; 
	"DOCUMENT","http://juridico.totvsbpo.com.br:8082/",,"1.031217",; 
	"http://juridico.totvsbpo.com.br:8082/WSINDICES.apw")

::Init()
::oWSMTVALINDICESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MTVALINDICESRESPONSE:_MTVALINDICESRESULT","STRUVALINDICE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure STRUINDICE

WSSTRUCT WSINDICES_STRUINDICE
	WSDATA   oWSDADOS                  AS WSINDICES_ARRAYOFSTRUDADOSINDICE
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINDICES_STRUINDICE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINDICES_STRUINDICE
Return

WSMETHOD CLONE WSCLIENT WSINDICES_STRUINDICE
	Local oClone := WSINDICES_STRUINDICE():NEW()
	oClone:oWSDADOS             := IIF(::oWSDADOS = NIL , NIL , ::oWSDADOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINDICES_STRUINDICE
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOS","ARRAYOFSTRUDADOSINDICE",NIL,"Property oWSDADOS as s0:ARRAYOFSTRUDADOSINDICE on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDADOS := WSINDICES_ARRAYOFSTRUDADOSINDICE():New()
		::oWSDADOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure STRUVALINDICE

WSSTRUCT WSINDICES_STRUVALINDICE
	WSDATA   oWSDADOS                  AS WSINDICES_ARRAYOFSTRUDADOSVALINDICE
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINDICES_STRUVALINDICE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINDICES_STRUVALINDICE
Return

WSMETHOD CLONE WSCLIENT WSINDICES_STRUVALINDICE
	Local oClone := WSINDICES_STRUVALINDICE():NEW()
	oClone:oWSDADOS             := IIF(::oWSDADOS = NIL , NIL , ::oWSDADOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINDICES_STRUVALINDICE
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DADOS","ARRAYOFSTRUDADOSVALINDICE",NIL,"Property oWSDADOS as s0:ARRAYOFSTRUDADOSVALINDICE on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDADOS := WSINDICES_ARRAYOFSTRUDADOSVALINDICE():New()
		::oWSDADOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFSTRUDADOSINDICE

WSSTRUCT WSINDICES_ARRAYOFSTRUDADOSINDICE
	WSDATA   oWSSTRUDADOSINDICE        AS WSINDICES_STRUDADOSINDICE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINDICES_ARRAYOFSTRUDADOSINDICE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINDICES_ARRAYOFSTRUDADOSINDICE
	::oWSSTRUDADOSINDICE   := {} // Array Of  WSINDICES_STRUDADOSINDICE():New()
Return

WSMETHOD CLONE WSCLIENT WSINDICES_ARRAYOFSTRUDADOSINDICE
	Local oClone := WSINDICES_ARRAYOFSTRUDADOSINDICE():NEW()
	oClone:oWSSTRUDADOSINDICE := NIL
	If ::oWSSTRUDADOSINDICE <> NIL 
		oClone:oWSSTRUDADOSINDICE := {}
		aEval( ::oWSSTRUDADOSINDICE , { |x| aadd( oClone:oWSSTRUDADOSINDICE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINDICES_ARRAYOFSTRUDADOSINDICE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUDADOSINDICE","STRUDADOSINDICE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUDADOSINDICE , WSINDICES_STRUDADOSINDICE():New() )
			::oWSSTRUDADOSINDICE[len(::oWSSTRUDADOSINDICE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFSTRUDADOSVALINDICE

WSSTRUCT WSINDICES_ARRAYOFSTRUDADOSVALINDICE
	WSDATA   oWSSTRUDADOSVALINDICE     AS WSINDICES_STRUDADOSVALINDICE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINDICES_ARRAYOFSTRUDADOSVALINDICE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINDICES_ARRAYOFSTRUDADOSVALINDICE
	::oWSSTRUDADOSVALINDICE := {} // Array Of  WSINDICES_STRUDADOSVALINDICE():New()
Return

WSMETHOD CLONE WSCLIENT WSINDICES_ARRAYOFSTRUDADOSVALINDICE
	Local oClone := WSINDICES_ARRAYOFSTRUDADOSVALINDICE():NEW()
	oClone:oWSSTRUDADOSVALINDICE := NIL
	If ::oWSSTRUDADOSVALINDICE <> NIL 
		oClone:oWSSTRUDADOSVALINDICE := {}
		aEval( ::oWSSTRUDADOSVALINDICE , { |x| aadd( oClone:oWSSTRUDADOSVALINDICE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINDICES_ARRAYOFSTRUDADOSVALINDICE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STRUDADOSVALINDICE","STRUDADOSVALINDICE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSTRUDADOSVALINDICE , WSINDICES_STRUDADOSVALINDICE():New() )
			::oWSSTRUDADOSVALINDICE[len(::oWSSTRUDADOSVALINDICE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure STRUDADOSINDICE

WSSTRUCT WSINDICES_STRUDADOSINDICE
	WSDATA   cATUALIZATAB              AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string
	WSDATA   cTIPO                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINDICES_STRUDADOSINDICE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINDICES_STRUDADOSINDICE
Return

WSMETHOD CLONE WSCLIENT WSINDICES_STRUDADOSINDICE
	Local oClone := WSINDICES_STRUDADOSINDICE():NEW()
	oClone:cATUALIZATAB         := ::cATUALIZATAB
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cTIPO                := ::cTIPO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINDICES_STRUDADOSINDICE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cATUALIZATAB       :=  WSAdvValue( oResponse,"_ATUALIZATAB","string",NIL,"Property cATUALIZATAB as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure STRUDADOSVALINDICE

WSSTRUCT WSINDICES_STRUDADOSVALINDICE
	WSDATA   cCODIGO                   AS string
	WSDATA   cDATA                     AS string
	WSDATA   cDESCRICAO                AS string
	WSDATA   cVALOR                    AS string
	WSDATA   cVALORABSOLUTO            AS string

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSINDICES_STRUDADOSVALINDICE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSINDICES_STRUDADOSVALINDICE
Return

WSMETHOD CLONE WSCLIENT WSINDICES_STRUDADOSVALINDICE
	Local oClone := WSINDICES_STRUDADOSVALINDICE():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDATA                := ::cDATA
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cVALOR               := ::cVALOR
	oClone:cVALORABSOLUTO       := ::cVALORABSOLUTO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSINDICES_STRUDADOSVALINDICE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATA              :=  WSAdvValue( oResponse,"_DATA","string",NIL,"Property cDATA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,"Property cDESCRICAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVALOR             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,"Property cVALOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL)
	::cVALORABSOLUTO     :=  WSAdvValue( oResponse,"_VALORABSOLUTO","string",NIL,"Property cVALOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL)
	 
Return


