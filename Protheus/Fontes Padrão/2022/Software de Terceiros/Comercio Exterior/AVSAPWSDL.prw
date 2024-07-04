#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://tec2000/easysap/Service.asmx?WSDL
Gerado em        06/15/05 09:19:12
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.040504
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSService
------------------------------------------------------------------------------- */
STATIC cEndereco:=LOWER(EasyGParam("MV_SAP0006",,""))


WSCLIENT WSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ConnectaSAP

	WSDATA   _URL                      AS String
	WSDATA   ccPar10                   AS string
	WSDATA   ccPar11                   AS string
	WSDATA   ccPar12                   AS string
	WSDATA   ccPar13                   AS string
	WSDATA   ccPar14                   AS string
	WSDATA   ccPar15                   AS string
	WSDATA   ccPar16                   AS string
	WSDATA   ccPar17                   AS string
	WSDATA   ccPar18                   AS string
	WSDATA   ccPar19                   AS string
	WSDATA   ccPar28                   AS string
	WSDATA   ccPar29                   AS string
	WSDATA   ccProced                  AS string
	WSDATA   ccRFC                     AS string
	WSDATA   ccRecLog                  AS string
	WSDATA   ccPrice                   AS string
	WSDATA   cConnectaSAPResult        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSservice
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.040831P] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSservice
Return

WSMETHOD RESET WSCLIENT WSservice
	::ccPar10            := NIL 
	::ccPar11            := NIL 
	::ccPar12            := NIL 
	::ccPar13            := NIL 
	::ccPar14            := NIL 
	::ccPar15            := NIL 
	::ccPar16            := NIL 
	::ccPar17            := NIL 
	::ccPar18            := NIL 
	::ccPar19            := NIL 
	::ccPar28            := NIL 
	::ccPar29            := NIL 
	::ccProced           := NIL 
	::ccRFC              := NIL 
	::ccRecLog           := NIL 
	::ccPrice            := NIL 
	::cConnectaSAPResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSservice
Local oClone := WSservice():New()
	oClone:_URL          := ::_URL 
	oClone:ccPar10       := ::ccPar10
	oClone:ccPar11       := ::ccPar11
	oClone:ccPar12       := ::ccPar12
	oClone:ccPar13       := ::ccPar13
	oClone:ccPar14       := ::ccPar14
	oClone:ccPar15       := ::ccPar15
	oClone:ccPar16       := ::ccPar16
	oClone:ccPar17       := ::ccPar17
	oClone:ccPar18       := ::ccPar18
	oClone:ccPar19       := ::ccPar19
	oClone:ccPar28       := ::ccPar28
	oClone:ccPar29       := ::ccPar29
	oClone:ccProced      := ::ccProced
	oClone:ccRFC         := ::ccRFC
	oClone:ccRecLog      := ::ccRecLog
	oClone:ccPrice       := ::ccPrice
	oClone:cConnectaSAPResult := ::cConnectaSAPResult
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method ConnectaSAP of Service WSservice
------------------------------------------------------------------------------- */

WSMETHOD ConnectaSAP WSSEND ccPar10,ccPar11,ccPar12,ccPar13,ccPar14,ccPar15,ccPar16,ccPar17,ccPar18,ccPar19,ccPar28,ccPar29,ccProced,ccRFC,ccRecLog,ccPrice WSRECEIVE cConnectaSAPResult WSCLIENT WSservice
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConnectaSAP xmlns="'+cEndereco+'">'
cSoap += WSSoapValue("cPar10", ::ccPar10, ccPar10 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar11", ::ccPar11, ccPar11 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar12", ::ccPar12, ccPar12 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar13", ::ccPar13, ccPar13 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar14", ::ccPar14, ccPar14 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar15", ::ccPar15, ccPar15 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar16", ::ccPar16, ccPar16 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar17", ::ccPar17, ccPar17 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar18", ::ccPar18, ccPar18 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar19", ::ccPar19, ccPar19 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar28", ::ccPar28, ccPar28 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPar29", ::ccPar29, ccPar29 , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cProced", ::ccProced, ccProced , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cRFC", ::ccRFC, ccRFC , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cRecLog", ::ccRecLog, ccRecLog , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("cPrice", ::ccPrice, ccPrice , "string", .F. , .F., 0 ) 
cSoap += "</ConnectaSAP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	cEndereco+"/ConnectaSAP",; 
	"DOCUMENT",cEndereco,,,; 
	cEndereco+".asmx")

::Init()
::cConnectaSAPResult :=  WSAdvValue( oXmlRet,"_CONNECTASAPRESPONSE:_CONNECTASAPRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



