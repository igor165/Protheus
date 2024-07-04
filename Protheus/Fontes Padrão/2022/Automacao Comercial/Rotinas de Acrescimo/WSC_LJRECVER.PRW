#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://totvs-11032:85/ANALISAREC.apw?WSDL
Gerado em        06/10/11 11:28:05
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110315
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FPEHRCN ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSANALISAREC
------------------------------------------------------------------------------- */

WSCLIENT WSANALISAREC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETRECVER

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   oWSAANALISE               AS ANALISAREC_WSNEWARRAY
	WSDATA   oWSGETRECVERRESULT        AS ANALISAREC_ARRAYOFWSRETANALISE

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSWSNEWARRAY             AS ANALISAREC_WSNEWARRAY

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSANALISAREC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110330] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSANALISAREC
	::oWSAANALISE        := ANALISAREC_WSNEWARRAY():New()
	::oWSGETRECVERRESULT := ANALISAREC_ARRAYOFWSRETANALISE():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSNEWARRAY      := ::oWSAANALISE
Return

WSMETHOD RESET WSCLIENT WSANALISAREC
	::oWSAANALISE        := NIL 
	::oWSGETRECVERRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSNEWARRAY      := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSANALISAREC
Local oClone := WSANALISAREC():New()
	oClone:_URL          := ::_URL 
	oClone:oWSAANALISE   :=  IIF(::oWSAANALISE = NIL , NIL ,::oWSAANALISE:Clone() )
	oClone:oWSGETRECVERRESULT :=  IIF(::oWSGETRECVERRESULT = NIL , NIL ,::oWSGETRECVERRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSWSNEWARRAY := oClone:oWSAANALISE
Return oClone

// WSDL Method GETRECVER of Service WSANALISAREC

WSMETHOD GETRECVER WSSEND oWSAANALISE WSRECEIVE oWSGETRECVERRESULT WSCLIENT WSANALISAREC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETRECVER xmlns="http://TOTVS-11032:85/">'
cSoap += WSSoapValue("AANALISE", ::oWSAANALISE, oWSAANALISE , "WSNEWARRAY", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETRECVER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://TOTVS-11032:85/GETRECVER",; 
	"DOCUMENT","http://TOTVS-11032:85/",,"1.031217",; 
	"http://totvs-11032:85/ANALISAREC.apw")

::Init()
::oWSGETRECVERRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETRECVERRESPONSE:_GETRECVERRESULT","ARRAYOFWSRETANALISE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure WSNEWARRAY

WSSTRUCT ANALISAREC_WSNEWARRAY
	WSDATA   oWSVERARRAY               AS ANALISAREC_ARRAYOFWSANALISE
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ANALISAREC_WSNEWARRAY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ANALISAREC_WSNEWARRAY
Return

WSMETHOD CLONE WSCLIENT ANALISAREC_WSNEWARRAY
	Local oClone := ANALISAREC_WSNEWARRAY():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT ANALISAREC_WSNEWARRAY
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSANALISE", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSRETANALISE

WSSTRUCT ANALISAREC_ARRAYOFWSRETANALISE
	WSDATA   oWSWSRETANALISE           AS ANALISAREC_WSRETANALISE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ANALISAREC_ARRAYOFWSRETANALISE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ANALISAREC_ARRAYOFWSRETANALISE
	::oWSWSRETANALISE      := {} // Array Of  ANALISAREC_WSRETANALISE():New()
Return

WSMETHOD CLONE WSCLIENT ANALISAREC_ARRAYOFWSRETANALISE
	Local oClone := ANALISAREC_ARRAYOFWSRETANALISE():NEW()
	oClone:oWSWSRETANALISE := NIL
	If ::oWSWSRETANALISE <> NIL 
		oClone:oWSWSRETANALISE := {}
		aEval( ::oWSWSRETANALISE , { |x| aadd( oClone:oWSWSRETANALISE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ANALISAREC_ARRAYOFWSRETANALISE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSRETANALISE","WSRETANALISE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSRETANALISE , ANALISAREC_WSRETANALISE():New() )
			::oWSWSRETANALISE[len(::oWSWSRETANALISE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFWSANALISE

WSSTRUCT ANALISAREC_ARRAYOFWSANALISE
	WSDATA   oWSWSANALISE              AS ANALISAREC_WSANALISE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ANALISAREC_ARRAYOFWSANALISE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ANALISAREC_ARRAYOFWSANALISE
	::oWSWSANALISE         := {} // Array Of  ANALISAREC_WSANALISE():New()
Return

WSMETHOD CLONE WSCLIENT ANALISAREC_ARRAYOFWSANALISE
	Local oClone := ANALISAREC_ARRAYOFWSANALISE():NEW()
	oClone:oWSWSANALISE := NIL
	If ::oWSWSANALISE <> NIL 
		oClone:oWSWSANALISE := {}
		aEval( ::oWSWSANALISE , { |x| aadd( oClone:oWSWSANALISE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ANALISAREC_ARRAYOFWSANALISE
	Local cSoap := ""
	aEval( ::oWSWSANALISE , {|x| cSoap := cSoap  +  WSSoapValue("WSANALISE", x , x , "WSANALISE", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure WSRETANALISE

WSSTRUCT ANALISAREC_WSRETANALISE
	WSDATA   cCONTRATO                 AS string
	WSDATA   lVERDADE                  AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ANALISAREC_WSRETANALISE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ANALISAREC_WSRETANALISE
Return

WSMETHOD CLONE WSCLIENT ANALISAREC_WSRETANALISE
	Local oClone := ANALISAREC_WSRETANALISE():NEW()
	oClone:cCONTRATO            := ::cCONTRATO
	oClone:lVERDADE             := ::lVERDADE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ANALISAREC_WSRETANALISE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCONTRATO          :=  WSAdvValue( oResponse,"_CONTRATO","string",NIL,"Property cCONTRATO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lVERDADE           :=  WSAdvValue( oResponse,"_VERDADE","boolean",NIL,"Property lVERDADE as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure WSANALISE

WSSTRUCT ANALISAREC_WSANALISE
	WSDATA   cCLIENTE                  AS string
	WSDATA   cCONTRATO                 AS string
	WSDATA   cFILIAL                   AS string
	WSDATA   cLOJA                     AS string
	WSDATA   lMARCADO                  AS boolean
	WSDATA   cPARCELA                  AS string
	WSDATA   cPREFIXO                  AS string
	WSDATA   cTITULO                   AS string
	WSDATA   dVENCTO                   AS date
	WSDATA   nVLRACR                   AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ANALISAREC_WSANALISE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ANALISAREC_WSANALISE
Return

WSMETHOD CLONE WSCLIENT ANALISAREC_WSANALISE
	Local oClone := ANALISAREC_WSANALISE():NEW()
	oClone:cCLIENTE             := ::cCLIENTE
	oClone:cCONTRATO            := ::cCONTRATO
	oClone:cFILIAL              := ::cFILIAL
	oClone:cLOJA                := ::cLOJA
	oClone:lMARCADO             := ::lMARCADO
	oClone:cPARCELA             := ::cPARCELA
	oClone:cPREFIXO             := ::cPREFIXO
	oClone:cTITULO              := ::cTITULO
	oClone:dVENCTO              := ::dVENCTO
	oClone:nVLRACR              := ::nVLRACR
Return oClone

WSMETHOD SOAPSEND WSCLIENT ANALISAREC_WSANALISE
	Local cSoap := ""
	cSoap += WSSoapValue("CLIENTE", ::cCLIENTE, ::cCLIENTE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CONTRATO", ::cCONTRATO, ::cCONTRATO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FILIAL", ::cFILIAL, ::cFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("LOJA", ::cLOJA, ::cLOJA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("MARCADO", ::lMARCADO, ::lMARCADO , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PARCELA", ::cPARCELA, ::cPARCELA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PREFIXO", ::cPREFIXO, ::cPREFIXO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TITULO", ::cTITULO, ::cTITULO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VENCTO", ::dVENCTO, ::dVENCTO , "date", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VLRACR", ::nVLRACR, ::nVLRACR , "float", .T. , .F., 0 , NIL, .F.) 
Return cSoap


