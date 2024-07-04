#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://127.0.0.1:30/BAIXANCC.apw?WSDL
Gerado em        10/01/13 14:54:38
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _GRHNASQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSBAIXANCC
------------------------------------------------------------------------------- */

WSCLIENT WSBAIXANCC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD FRTBXNCC
	WSMETHOD FRTGETSA6

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSANCCITENS              AS BAIXANCC_WSNCCARRAY
	WSDATA   nNNCCUSADA                AS float
	WSDATA   nNNCCGERADA               AS float
	WSDATA   cCL1DOC                   AS string
	WSDATA   cCL1SERIE                 AS string
	WSDATA   cCL1OPER                  AS string
	WSDATA   dDL1EMISNF                AS date
	WSDATA   cCL1CLIENTE               AS string
	WSDATA   cCL1LOJA                  AS string
	WSDATA   nNL1CREDIT                AS float
	WSDATA   cCSEREST                  AS string
	WSDATA   cCEMPPDV                  AS string
	WSDATA   cCFILPDV                  AS string
	WSDATA   lLMVLJPDVPA               AS boolean
	WSDATA   oWSARECNOSE1              AS BAIXANCC_WSSE1ARRAY
	WSDATA   oWSAVLRRECEB              AS BAIXANCC_WSRECEB
	WSDATA   cCL1ORC                   AS string
	WSDATA   nFRTBXNCCRESULT           AS float
	WSDATA   oWSFRTGETSA6RESULT        AS BAIXANCC_ARRAYOFWSBANCO

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSWSNCCARRAY             AS BAIXANCC_WSNCCARRAY
	WSDATA   oWSWSSE1ARRAY             AS BAIXANCC_WSSE1ARRAY
	WSDATA   oWSWSRECEB                AS BAIXANCC_WSRECEB

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSBAIXANCC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.111010P-20111220] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSBAIXANCC
	::oWSANCCITENS       := BAIXANCC_WSNCCARRAY():New()
	::oWSARECNOSE1       := BAIXANCC_WSSE1ARRAY():New()
	::oWSAVLRRECEB       := BAIXANCC_WSRECEB():New()
	::oWSFRTGETSA6RESULT := BAIXANCC_ARRAYOFWSBANCO():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSNCCARRAY      := ::oWSANCCITENS
	::oWSWSSE1ARRAY      := ::oWSARECNOSE1
	::oWSWSRECEB         := ::oWSAVLRRECEB
Return

WSMETHOD RESET WSCLIENT WSBAIXANCC
	::oWSANCCITENS       := NIL 
	::nNNCCUSADA         := NIL 
	::nNNCCGERADA        := NIL 
	::cCL1DOC            := NIL 
	::cCL1SERIE          := NIL 
	::cCL1OPER           := NIL 
	::dDL1EMISNF         := NIL 
	::cCL1CLIENTE        := NIL 
	::cCL1LOJA           := NIL 
	::nNL1CREDIT         := NIL 
	::cCSEREST           := NIL 
	::cCEMPPDV           := NIL 
	::cCFILPDV           := NIL 
	::lLMVLJPDVPA        := NIL 
	::oWSARECNOSE1       := NIL 
	::oWSAVLRRECEB       := NIL 
	::cCL1ORC            := NIL 
	::nFRTBXNCCRESULT    := NIL 
	::oWSFRTGETSA6RESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSNCCARRAY      := NIL
	::oWSWSSE1ARRAY      := NIL
	::oWSWSRECEB         := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSBAIXANCC
Local oClone := WSBAIXANCC():New()
	oClone:_URL          := ::_URL 
	oClone:oWSANCCITENS  :=  IIF(::oWSANCCITENS = NIL , NIL ,::oWSANCCITENS:Clone() )
	oClone:nNNCCUSADA    := ::nNNCCUSADA
	oClone:nNNCCGERADA   := ::nNNCCGERADA
	oClone:cCL1DOC       := ::cCL1DOC
	oClone:cCL1SERIE     := ::cCL1SERIE
	oClone:cCL1OPER      := ::cCL1OPER
	oClone:dDL1EMISNF    := ::dDL1EMISNF
	oClone:cCL1CLIENTE   := ::cCL1CLIENTE
	oClone:cCL1LOJA      := ::cCL1LOJA
	oClone:nNL1CREDIT    := ::nNL1CREDIT
	oClone:cCSEREST      := ::cCSEREST
	oClone:cCEMPPDV      := ::cCEMPPDV
	oClone:cCFILPDV      := ::cCFILPDV
	oClone:lLMVLJPDVPA   := ::lLMVLJPDVPA
	oClone:oWSARECNOSE1  :=  IIF(::oWSARECNOSE1 = NIL , NIL ,::oWSARECNOSE1:Clone() )
	oClone:oWSAVLRRECEB  :=  IIF(::oWSAVLRRECEB = NIL , NIL ,::oWSAVLRRECEB:Clone() )
	oClone:cCL1ORC       := ::cCL1ORC
	oClone:nFRTBXNCCRESULT := ::nFRTBXNCCRESULT
	oClone:oWSFRTGETSA6RESULT :=  IIF(::oWSFRTGETSA6RESULT = NIL , NIL ,::oWSFRTGETSA6RESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSWSNCCARRAY := oClone:oWSANCCITENS
	oClone:oWSWSSE1ARRAY := oClone:oWSARECNOSE1
	oClone:oWSWSRECEB    := oClone:oWSAVLRRECEB
Return oClone

// WSDL Method FRTBXNCC of Service WSBAIXANCC

WSMETHOD FRTBXNCC WSSEND oWSANCCITENS,nNNCCUSADA,nNNCCGERADA,cCL1DOC,cCL1SERIE,cCL1OPER,dDL1EMISNF,cCL1CLIENTE,cCL1LOJA,nNL1CREDIT,cCSEREST,cCEMPPDV,cCFILPDV,lLMVLJPDVPA,oWSARECNOSE1,oWSAVLRRECEB,cCL1ORC WSRECEIVE nFRTBXNCCRESULT WSCLIENT WSBAIXANCC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FRTBXNCC xmlns="http://127.0.0.1:30/">'
cSoap += WSSoapValue("ANCCITENS", ::oWSANCCITENS, oWSANCCITENS , "WSNCCARRAY", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NNCCUSADA", ::nNNCCUSADA, nNNCCUSADA , "float", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NNCCGERADA", ::nNNCCGERADA, nNNCCGERADA , "float", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CL1DOC", ::cCL1DOC, cCL1DOC , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CL1SERIE", ::cCL1SERIE, cCL1SERIE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CL1OPER", ::cCL1OPER, cCL1OPER , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DL1EMISNF", ::dDL1EMISNF, dDL1EMISNF , "date", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CL1CLIENTE", ::cCL1CLIENTE, cCL1CLIENTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CL1LOJA", ::cCL1LOJA, cCL1LOJA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NL1CREDIT", ::nNL1CREDIT, nNL1CREDIT , "float", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CSEREST", ::cCSEREST, cCSEREST , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CEMPPDV", ::cCEMPPDV, cCEMPPDV , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFILPDV", ::cCFILPDV, cCFILPDV , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LMVLJPDVPA", ::lLMVLJPDVPA, lLMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ARECNOSE1", ::oWSARECNOSE1, oWSARECNOSE1 , "WSSE1ARRAY", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("AVLRRECEB", ::oWSAVLRRECEB, oWSAVLRRECEB , "WSRECEB", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CL1ORC", ::cCL1ORC, cCL1ORC , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</FRTBXNCC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:30/FRTBXNCC",; 
	"DOCUMENT","http://127.0.0.1:30/",,"1.031217",; 
	"http://127.0.0.1:30/BAIXANCC.apw")

::Init()
::nFRTBXNCCRESULT    :=  WSAdvValue( oXmlRet,"_FRTBXNCCRESPONSE:_FRTBXNCCRESULT:TEXT","float",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method FRTGETSA6 of Service WSBAIXANCC

WSMETHOD FRTGETSA6 WSSEND cCL1OPER WSRECEIVE oWSFRTGETSA6RESULT WSCLIENT WSBAIXANCC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FRTGETSA6 xmlns="http://127.0.0.1:30/">'
cSoap += WSSoapValue("CL1OPER", ::cCL1OPER, cCL1OPER , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</FRTGETSA6>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:30/FRTGETSA6",; 
	"DOCUMENT","http://127.0.0.1:30/",,"1.031217",; 
	"http://127.0.0.1:30/BAIXANCC.apw")

::Init()
::oWSFRTGETSA6RESULT:SoapRecv( WSAdvValue( oXmlRet,"_FRTGETSA6RESPONSE:_FRTGETSA6RESULT","ARRAYOFWSBANCO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure WSNCCARRAY

WSSTRUCT BAIXANCC_WSNCCARRAY
	WSDATA   oWSVERARRAY               AS BAIXANCC_ARRAYOFWSNCCITENS
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_WSNCCARRAY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_WSNCCARRAY
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_WSNCCARRAY
	Local oClone := BAIXANCC_WSNCCARRAY():NEW()
	oClone:oWSVERARRAY          := IIF(::oWSVERARRAY = NIL , NIL , ::oWSVERARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_WSNCCARRAY
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRAY", ::oWSVERARRAY, ::oWSVERARRAY , "ARRAYOFWSNCCITENS", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure WSSE1ARRAY

WSSTRUCT BAIXANCC_WSSE1ARRAY
	WSDATA   oWSRECARRAY               AS BAIXANCC_ARRAYOFWSRECNOSE1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_WSSE1ARRAY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_WSSE1ARRAY
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_WSSE1ARRAY
	Local oClone := BAIXANCC_WSSE1ARRAY():NEW()
	oClone:oWSRECARRAY          := IIF(::oWSRECARRAY = NIL , NIL , ::oWSRECARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_WSSE1ARRAY
	Local cSoap := ""
	cSoap += WSSoapValue("RECARRAY", ::oWSRECARRAY, ::oWSRECARRAY , "ARRAYOFWSRECNOSE1", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure WSRECEB

WSSTRUCT BAIXANCC_WSRECEB
	WSDATA   oWSRECARRAY               AS BAIXANCC_ARRAYOFWSVLRRECEB OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_WSRECEB
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_WSRECEB
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_WSRECEB
	Local oClone := BAIXANCC_WSRECEB():NEW()
	oClone:oWSRECARRAY          := IIF(::oWSRECARRAY = NIL , NIL , ::oWSRECARRAY:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_WSRECEB
	Local cSoap := ""
	cSoap += WSSoapValue("RECARRAY", ::oWSRECARRAY, ::oWSRECARRAY , "ARRAYOFWSVLRRECEB", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSBANCO

WSSTRUCT BAIXANCC_ARRAYOFWSBANCO
	WSDATA   oWSWSBANCO                AS BAIXANCC_WSBANCO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_ARRAYOFWSBANCO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_ARRAYOFWSBANCO
	::oWSWSBANCO           := {} // Array Of  BAIXANCC_WSBANCO():New()
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_ARRAYOFWSBANCO
	Local oClone := BAIXANCC_ARRAYOFWSBANCO():NEW()
	oClone:oWSWSBANCO := NIL
	If ::oWSWSBANCO <> NIL 
		oClone:oWSWSBANCO := {}
		aEval( ::oWSWSBANCO , { |x| aadd( oClone:oWSWSBANCO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT BAIXANCC_ARRAYOFWSBANCO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSBANCO","WSBANCO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSBANCO , BAIXANCC_WSBANCO():New() )
			::oWSWSBANCO[len(::oWSWSBANCO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFWSNCCITENS

WSSTRUCT BAIXANCC_ARRAYOFWSNCCITENS
	WSDATA   oWSWSNCCITENS             AS BAIXANCC_WSNCCITENS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_ARRAYOFWSNCCITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_ARRAYOFWSNCCITENS
	::oWSWSNCCITENS        := {} // Array Of  BAIXANCC_WSNCCITENS():New()
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_ARRAYOFWSNCCITENS
	Local oClone := BAIXANCC_ARRAYOFWSNCCITENS():NEW()
	oClone:oWSWSNCCITENS := NIL
	If ::oWSWSNCCITENS <> NIL 
		oClone:oWSWSNCCITENS := {}
		aEval( ::oWSWSNCCITENS , { |x| aadd( oClone:oWSWSNCCITENS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_ARRAYOFWSNCCITENS
	Local cSoap := ""
	aEval( ::oWSWSNCCITENS , {|x| cSoap := cSoap  +  WSSoapValue("WSNCCITENS", x , x , "WSNCCITENS", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFWSRECNOSE1

WSSTRUCT BAIXANCC_ARRAYOFWSRECNOSE1
	WSDATA   oWSWSRECNOSE1             AS BAIXANCC_WSRECNOSE1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_ARRAYOFWSRECNOSE1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_ARRAYOFWSRECNOSE1
	::oWSWSRECNOSE1        := {} // Array Of  BAIXANCC_WSRECNOSE1():New()
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_ARRAYOFWSRECNOSE1
	Local oClone := BAIXANCC_ARRAYOFWSRECNOSE1():NEW()
	oClone:oWSWSRECNOSE1 := NIL
	If ::oWSWSRECNOSE1 <> NIL 
		oClone:oWSWSRECNOSE1 := {}
		aEval( ::oWSWSRECNOSE1 , { |x| aadd( oClone:oWSWSRECNOSE1 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_ARRAYOFWSRECNOSE1
	Local cSoap := ""
	aEval( ::oWSWSRECNOSE1 , {|x| cSoap := cSoap  +  WSSoapValue("WSRECNOSE1", x , x , "WSRECNOSE1", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFWSVLRRECEB

WSSTRUCT BAIXANCC_ARRAYOFWSVLRRECEB
	WSDATA   oWSWSVLRRECEB             AS BAIXANCC_WSVLRRECEB OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_ARRAYOFWSVLRRECEB
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_ARRAYOFWSVLRRECEB
	::oWSWSVLRRECEB        := {} // Array Of  BAIXANCC_WSVLRRECEB():New()
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_ARRAYOFWSVLRRECEB
	Local oClone := BAIXANCC_ARRAYOFWSVLRRECEB():NEW()
	oClone:oWSWSVLRRECEB := NIL
	If ::oWSWSVLRRECEB <> NIL 
		oClone:oWSWSVLRRECEB := {}
		aEval( ::oWSWSVLRRECEB , { |x| aadd( oClone:oWSWSVLRRECEB , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_ARRAYOFWSVLRRECEB
	Local cSoap := ""
	aEval( ::oWSWSVLRRECEB , {|x| cSoap := cSoap  +  WSSoapValue("WSVLRRECEB", x , x , "WSVLRRECEB", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure WSBANCO

WSSTRUCT BAIXANCC_WSBANCO
	WSDATA   cCODIGO                   AS string
	WSDATA   nMOEDA                    AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_WSBANCO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_WSBANCO
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_WSBANCO
	Local oClone := BAIXANCC_WSBANCO():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:nMOEDA               := ::nMOEDA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT BAIXANCC_WSBANCO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nMOEDA             :=  WSAdvValue( oResponse,"_MOEDA","integer",NIL,"Property nMOEDA as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure WSNCCITENS

WSSTRUCT BAIXANCC_WSNCCITENS
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
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_WSNCCITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_WSNCCITENS
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_WSNCCITENS
	Local oClone := BAIXANCC_WSNCCITENS():NEW()
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

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_WSNCCITENS
	Local cSoap := ""
	cSoap += WSSoapValue("DATANCC", ::dDATANCC, ::dDATANCC , "date", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("MOEDA", ::nMOEDA, ::nMOEDA , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("MVMOEDA", ::cMVMOEDA, ::cMVMOEDA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NUMRECNO", ::nNUMRECNO, ::nNUMRECNO , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NUMTITULO", ::cNUMTITULO, ::cNUMTITULO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PARCELA", ::cPARCELA, ::cPARCELA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PREFIXO", ::cPREFIXO, ::cPREFIXO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SALDO", ::nSALDO, ::nSALDO , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SALDO2", ::nSALDO2, ::nSALDO2 , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SELECIONA", ::lSELECIONA, ::lSELECIONA , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure WSRECNOSE1

WSSTRUCT BAIXANCC_WSRECNOSE1
	WSDATA   nRECNOSE1                 AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_WSRECNOSE1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_WSRECNOSE1
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_WSRECNOSE1
	Local oClone := BAIXANCC_WSRECNOSE1():NEW()
	oClone:nRECNOSE1            := ::nRECNOSE1
Return oClone

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_WSRECNOSE1
	Local cSoap := ""
	cSoap += WSSoapValue("RECNOSE1", ::nRECNOSE1, ::nRECNOSE1 , "integer", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure WSVLRRECEB

WSSTRUCT BAIXANCC_WSVLRRECEB
	WSDATA   nPOSRGSE1                 AS float OPTIONAL
	WSDATA   nVLRDESCO                 AS float OPTIONAL
	WSDATA   nVLRJUROS                 AS float OPTIONAL
	WSDATA   nVLRMULTA                 AS float OPTIONAL
	WSDATA   nVLRRECEB                 AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT BAIXANCC_WSVLRRECEB
	::Init()
Return Self

WSMETHOD INIT WSCLIENT BAIXANCC_WSVLRRECEB
Return

WSMETHOD CLONE WSCLIENT BAIXANCC_WSVLRRECEB
	Local oClone := BAIXANCC_WSVLRRECEB():NEW()
	oClone:nPOSRGSE1            := ::nPOSRGSE1
	oClone:nVLRDESCO            := ::nVLRDESCO
	oClone:nVLRJUROS            := ::nVLRJUROS
	oClone:nVLRMULTA            := ::nVLRMULTA
	oClone:nVLRRECEB            := ::nVLRRECEB
Return oClone

WSMETHOD SOAPSEND WSCLIENT BAIXANCC_WSVLRRECEB
	Local cSoap := ""
	cSoap += WSSoapValue("POSRGSE1", ::nPOSRGSE1, ::nPOSRGSE1 , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VLRDESCO", ::nVLRDESCO, ::nVLRDESCO , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VLRJUROS", ::nVLRJUROS, ::nVLRJUROS , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VLRMULTA", ::nVLRMULTA, ::nVLRMULTA , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VLRRECEB", ::nVLRRECEB, ::nVLRRECEB , "float", .F. , .F., 0 , NIL, .F.) 
Return cSoap


