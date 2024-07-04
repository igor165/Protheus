#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/FRTCRDBX.apw?WSDL
Gerado em        09/13/21 18:54:18
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _XZURVLA ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFRTCRDBX
------------------------------------------------------------------------------- */

WSCLIENT WSFRTCRDBX

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD FRTCRD02

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSACRDVALEC              AS FRTCRDBX_WSCRDARRBX
	WSDATA   cCL1CLIENTE               AS string
	WSDATA   cCL1LOJA                  AS string
	WSDATA   nNUSADO                   AS float
	WSDATA   cCL1DOC                   AS string
	WSDATA   cCL1SERIE                 AS string
	WSDATA   cCMOTIVO                  AS string
	WSDATA   nFRTCRD02RESULT           AS float

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSWSCRDARRBX             AS FRTCRDBX_WSCRDARRBX

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFRTCRDBX
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFRTCRDBX
	::oWSACRDVALEC       := FRTCRDBX_WSCRDARRBX():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSCRDARRBX      := ::oWSACRDVALEC
Return

WSMETHOD RESET WSCLIENT WSFRTCRDBX
	::oWSACRDVALEC       := NIL 
	::cCL1CLIENTE        := NIL 
	::cCL1LOJA           := NIL 
	::nNUSADO            := NIL 
	::cCL1DOC            := NIL 
	::cCL1SERIE          := NIL 
	::cCMOTIVO           := NIL 
	::nFRTCRD02RESULT    := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSCRDARRBX      := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFRTCRDBX
Local oClone := WSFRTCRDBX():New()
	oClone:_URL          := ::_URL 
	oClone:oWSACRDVALEC  :=  IIF(::oWSACRDVALEC = NIL , NIL ,::oWSACRDVALEC:Clone() )
	oClone:cCL1CLIENTE   := ::cCL1CLIENTE
	oClone:cCL1LOJA      := ::cCL1LOJA
	oClone:nNUSADO       := ::nNUSADO
	oClone:cCL1DOC       := ::cCL1DOC
	oClone:cCL1SERIE     := ::cCL1SERIE
	oClone:cCMOTIVO      := ::cCMOTIVO
	oClone:nFRTCRD02RESULT := ::nFRTCRD02RESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSWSCRDARRBX := oClone:oWSACRDVALEC
Return oClone

// WSDL Method FRTCRD02 of Service WSFRTCRDBX

WSMETHOD FRTCRD02 WSSEND oWSACRDVALEC,cCL1CLIENTE,cCL1LOJA,nNUSADO,cCL1DOC,cCL1SERIE,cCMOTIVO WSRECEIVE nFRTCRD02RESULT WSCLIENT WSFRTCRDBX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FRTCRD02 xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("ACRDVALEC", ::oWSACRDVALEC, oWSACRDVALEC , "WSCRDARRBX", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CL1CLIENTE", ::cCL1CLIENTE, cCL1CLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CL1LOJA", ::cCL1LOJA, cCL1LOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NUSADO", ::nNUSADO, nNUSADO , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CL1DOC", ::cCL1DOC, cCL1DOC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CL1SERIE", ::cCL1SERIE, cCL1SERIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CMOTIVO", ::cCMOTIVO, cCMOTIVO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</FRTCRD02>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/FRTCRD02",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/FRTCRDBX.apw")

::Init()
::nFRTCRD02RESULT    :=  WSAdvValue( oXmlRet,"_FRTCRD02RESPONSE:_FRTCRD02RESULT:TEXT","float",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure WSCRDARRBX

WSSTRUCT FRTCRDBX_WSCRDARRBX
	WSDATA   oWSVERARRBX               AS FRTCRDBX_ARRAYOFWSCRDVABX
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRDBX_WSCRDARRBX
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRDBX_WSCRDARRBX
Return

WSMETHOD CLONE WSCLIENT FRTCRDBX_WSCRDARRBX
	Local oClone := FRTCRDBX_WSCRDARRBX():NEW()
	oClone:oWSVERARRBX          := IIF(::oWSVERARRBX = NIL , NIL , ::oWSVERARRBX:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTCRDBX_WSCRDARRBX
	Local cSoap := ""
	cSoap += WSSoapValue("VERARRBX", ::oWSVERARRBX, ::oWSVERARRBX , "ARRAYOFWSCRDVABX", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSCRDVABX

WSSTRUCT FRTCRDBX_ARRAYOFWSCRDVABX
	WSDATA   oWSWSCRDVABX              AS FRTCRDBX_WSCRDVABX OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRDBX_ARRAYOFWSCRDVABX
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRDBX_ARRAYOFWSCRDVABX
	::oWSWSCRDVABX         := {} // Array Of  FRTCRDBX_WSCRDVABX():New()
Return

WSMETHOD CLONE WSCLIENT FRTCRDBX_ARRAYOFWSCRDVABX
	Local oClone := FRTCRDBX_ARRAYOFWSCRDVABX():NEW()
	oClone:oWSWSCRDVABX := NIL
	If ::oWSWSCRDVABX <> NIL 
		oClone:oWSWSCRDVABX := {}
		aEval( ::oWSWSCRDVABX , { |x| aadd( oClone:oWSWSCRDVABX , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTCRDBX_ARRAYOFWSCRDVABX
	Local cSoap := ""
	aEval( ::oWSWSCRDVABX , {|x| cSoap := cSoap  +  WSSoapValue("WSCRDVABX", x , x , "WSCRDVABX", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure WSCRDVABX

WSSTRUCT FRTCRDBX_WSCRDVABX
	WSDATA   nCRDPRE1                  AS float
	WSDATA   cCRDPRE2                  AS string
	WSDATA   cCRDPRE3                  AS string
	WSDATA   cCRDPRE4                  AS string
	WSDATA   nCRDPRE5                  AS float
	WSDATA   nCRDPRE6                  AS float
	WSDATA   nCRDPRE7                  AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FRTCRDBX_WSCRDVABX
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FRTCRDBX_WSCRDVABX
Return

WSMETHOD CLONE WSCLIENT FRTCRDBX_WSCRDVABX
	Local oClone := FRTCRDBX_WSCRDVABX():NEW()
	oClone:nCRDPRE1             := ::nCRDPRE1
	oClone:cCRDPRE2             := ::cCRDPRE2
	oClone:cCRDPRE3             := ::cCRDPRE3
	oClone:cCRDPRE4             := ::cCRDPRE4
	oClone:nCRDPRE5             := ::nCRDPRE5
	oClone:nCRDPRE6             := ::nCRDPRE6
	oClone:nCRDPRE7             := ::nCRDPRE7
Return oClone

WSMETHOD SOAPSEND WSCLIENT FRTCRDBX_WSCRDVABX
	Local cSoap := ""
	cSoap += WSSoapValue("CRDPRE1", ::nCRDPRE1, ::nCRDPRE1 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CRDPRE2", ::cCRDPRE2, ::cCRDPRE2 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CRDPRE3", ::cCRDPRE3, ::cCRDPRE3 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CRDPRE4", ::cCRDPRE4, ::cCRDPRE4 , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CRDPRE5", ::nCRDPRE5, ::nCRDPRE5 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CRDPRE6", ::nCRDPRE6, ::nCRDPRE6 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CRDPRE7", ::nCRDPRE7, ::nCRDPRE7 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


