#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://vmsus67226.sp01.local:8084/wsDataServer/mex?wsdl
Gerado em        08/13/19 15:31:54
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _RSJJPXT ; Return  // "dummy" function - Internal Use 


/* ====================== SERVICE WARNING MESSAGES ======================
Definition for Type as complexType NOT FOUND. This Object HAS NO RETURN.
====================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSwsDataServer
------------------------------------------------------------------------------- */

WSCLIENT WSwsDataServer

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Implements
	WSMETHOD CheckServiceActivity
	WSMETHOD AutenticaAcesso
	WSMETHOD GetSchema
	WSMETHOD IsValidDataServer
	WSMETHOD GetSchemaEmail
	WSMETHOD ReadView
	WSMETHOD ReadViewEmail
	WSMETHOD ReadRecord
	WSMETHOD ReadRecordEmail
	WSMETHOD SaveRecord
	WSMETHOD SaveRecordEmail
	WSMETHOD DeleteRecord
	WSMETHOD DeleteRecordEmail
	WSMETHOD DeleteRecordByKey
	WSMETHOD ReadLookupView
	WSMETHOD ReadLookupViewEmail

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWStype                   AS wsDataServer_Type
	WSDATA   lImplementsResult         AS boolean
	WSDATA   lCheckServiceActivityResult AS boolean
	WSDATA   cAutenticaAcessoResult    AS string
	WSDATA   cDataServerName           AS string
	WSDATA   cContexto                 AS string
	WSDATA   cGetSchemaResult          AS string
	WSDATA   oWSIsValidDataServerResult AS SCHEMA
	WSDATA   cEmailUsuarioContexto     AS string
	WSDATA   cGetSchemaEmailResult     AS string
	WSDATA   cFiltro                   AS string
	WSDATA   cReadViewResult           AS string
	WSDATA   cReadViewEmailResult      AS string
	WSDATA   cPrimaryKey               AS string
	WSDATA   cReadRecordResult         AS string
	WSDATA   cReadRecordEmailResult    AS string
	WSDATA   cXML                      AS string
	WSDATA   cSaveRecordResult         AS string
	WSDATA   cSaveRecordEmailResult    AS string
	WSDATA   cDeleteRecordResult       AS string
	WSDATA   cDeleteRecordEmailResult  AS string
	WSDATA   cDeleteRecordByKeyResult  AS string
	WSDATA   cOwnerData                AS string
	WSDATA   cReadLookupViewResult     AS string
	WSDATA   cReadLookupViewEmailResult AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSwsDataServer
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20190212] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSwsDataServer
	::oWStype            := wsDataServer_TYPE():New()
	::oWSIsValidDataServerResult := NIL 
Return

WSMETHOD RESET WSCLIENT WSwsDataServer
	::oWStype            := NIL 
	::lImplementsResult  := NIL 
	::lCheckServiceActivityResult := NIL 
	::cAutenticaAcessoResult := NIL 
	::cDataServerName    := NIL 
	::cContexto          := NIL 
	::cGetSchemaResult   := NIL 
	::oWSIsValidDataServerResult := NIL 
	::cEmailUsuarioContexto := NIL 
	::cGetSchemaEmailResult := NIL 
	::cFiltro            := NIL 
	::cReadViewResult    := NIL 
	::cReadViewEmailResult := NIL 
	::cPrimaryKey        := NIL 
	::cReadRecordResult  := NIL 
	::cReadRecordEmailResult := NIL 
	::cXML               := NIL 
	::cSaveRecordResult  := NIL 
	::cSaveRecordEmailResult := NIL 
	::cDeleteRecordResult := NIL 
	::cDeleteRecordEmailResult := NIL 
	::cDeleteRecordByKeyResult := NIL 
	::cOwnerData         := NIL 
	::cReadLookupViewResult := NIL 
	::cReadLookupViewEmailResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSwsDataServer
Local oClone := WSwsDataServer():New()
	oClone:_URL          := ::_URL 
	oClone:oWStype       :=  IIF(::oWStype = NIL , NIL ,::oWStype:Clone() )
	oClone:lImplementsResult := ::lImplementsResult
	oClone:lCheckServiceActivityResult := ::lCheckServiceActivityResult
	oClone:cAutenticaAcessoResult := ::cAutenticaAcessoResult
	oClone:cDataServerName := ::cDataServerName
	oClone:cContexto     := ::cContexto
	oClone:cGetSchemaResult := ::cGetSchemaResult
	oClone:cEmailUsuarioContexto := ::cEmailUsuarioContexto
	oClone:cGetSchemaEmailResult := ::cGetSchemaEmailResult
	oClone:cFiltro       := ::cFiltro
	oClone:cReadViewResult := ::cReadViewResult
	oClone:cReadViewEmailResult := ::cReadViewEmailResult
	oClone:cPrimaryKey   := ::cPrimaryKey
	oClone:cReadRecordResult := ::cReadRecordResult
	oClone:cReadRecordEmailResult := ::cReadRecordEmailResult
	oClone:cXML          := ::cXML
	oClone:cSaveRecordResult := ::cSaveRecordResult
	oClone:cSaveRecordEmailResult := ::cSaveRecordEmailResult
	oClone:cDeleteRecordResult := ::cDeleteRecordResult
	oClone:cDeleteRecordEmailResult := ::cDeleteRecordEmailResult
	oClone:cDeleteRecordByKeyResult := ::cDeleteRecordByKeyResult
	oClone:cOwnerData    := ::cOwnerData
	oClone:cReadLookupViewResult := ::cReadLookupViewResult
	oClone:cReadLookupViewEmailResult := ::cReadLookupViewEmailResult
Return oClone

// WSDL Method Implements of Service WSwsDataServer

WSMETHOD Implements WSSEND oWStype WSRECEIVE lImplementsResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Implements xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("type", ::oWStype, oWStype , "Type", .F. , .F., 0 , "http://www.totvs.com/", .F.,.F.) 
cSoap += "</Implements>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IRMSServer/Implements",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IRMSServer")

::Init()
::lImplementsResult  :=  WSAdvValue( oXmlRet,"_IMPLEMENTSRESPONSE:_IMPLEMENTSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CheckServiceActivity of Service WSwsDataServer

WSMETHOD CheckServiceActivity WSSEND NULLPARAM WSRECEIVE lCheckServiceActivityResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CheckServiceActivity xmlns="http://www.totvs.com/">'
cSoap += "</CheckServiceActivity>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IRMSServer/CheckServiceActivity",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IRMSServer")

::Init()
::lCheckServiceActivityResult :=  WSAdvValue( oXmlRet,"_CHECKSERVICEACTIVITYRESPONSE:_CHECKSERVICEACTIVITYRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AutenticaAcesso of Service WSwsDataServer

WSMETHOD AutenticaAcesso WSSEND NULLPARAM WSRECEIVE cAutenticaAcessoResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AutenticaAcesso xmlns="http://www.totvs.com/">'
cSoap += "</AutenticaAcesso>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsBase/AutenticaAcesso",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsBase")

::Init()
::cAutenticaAcessoResult :=  WSAdvValue( oXmlRet,"_AUTENTICAACESSORESPONSE:_AUTENTICAACESSORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetSchema of Service WSwsDataServer

WSMETHOD GetSchema WSSEND cDataServerName,cContexto WSRECEIVE cGetSchemaResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetSchema xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GetSchema>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/GetSchema",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cGetSchemaResult   :=  WSAdvValue( oXmlRet,"_GETSCHEMARESPONSE:_GETSCHEMARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IsValidDataServer of Service WSwsDataServer

WSMETHOD IsValidDataServer WSSEND cDataServerName WSRECEIVE oWSIsValidDataServerResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IsValidDataServer xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IsValidDataServer>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/IsValidDataServer",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::oWSIsValidDataServerResult :=  WSAdvValue( oXmlRet,"_ISVALIDDATASERVERRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetSchemaEmail of Service WSwsDataServer

WSMETHOD GetSchemaEmail WSSEND cDataServerName,cContexto,cEmailUsuarioContexto WSRECEIVE cGetSchemaEmailResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetSchemaEmail xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EmailUsuarioContexto", ::cEmailUsuarioContexto, cEmailUsuarioContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GetSchemaEmail>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/GetSchemaEmail",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cGetSchemaEmailResult :=  WSAdvValue( oXmlRet,"_GETSCHEMAEMAILRESPONSE:_GETSCHEMAEMAILRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ReadView of Service WSwsDataServer

WSMETHOD ReadView WSSEND cDataServerName,cFiltro,cContexto WSRECEIVE cReadViewResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReadView xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Filtro", ::cFiltro, cFiltro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ReadView>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/ReadView",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cReadViewResult    :=  WSAdvValue( oXmlRet,"_READVIEWRESPONSE:_READVIEWRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ReadViewEmail of Service WSwsDataServer

WSMETHOD ReadViewEmail WSSEND cDataServerName,cFiltro,cContexto,cEmailUsuarioContexto WSRECEIVE cReadViewEmailResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReadViewEmail xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Filtro", ::cFiltro, cFiltro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EmailUsuarioContexto", ::cEmailUsuarioContexto, cEmailUsuarioContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ReadViewEmail>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/ReadViewEmail",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cReadViewEmailResult :=  WSAdvValue( oXmlRet,"_READVIEWEMAILRESPONSE:_READVIEWEMAILRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ReadRecord of Service WSwsDataServer

WSMETHOD ReadRecord WSSEND cDataServerName,cPrimaryKey,cContexto WSRECEIVE cReadRecordResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReadRecord xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PrimaryKey", ::cPrimaryKey, cPrimaryKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ReadRecord>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/ReadRecord",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cReadRecordResult  :=  WSAdvValue( oXmlRet,"_READRECORDRESPONSE:_READRECORDRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ReadRecordEmail of Service WSwsDataServer

WSMETHOD ReadRecordEmail WSSEND cDataServerName,cPrimaryKey,cContexto,cEmailUsuarioContexto WSRECEIVE cReadRecordEmailResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReadRecordEmail xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PrimaryKey", ::cPrimaryKey, cPrimaryKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EmailUsuarioContexto", ::cEmailUsuarioContexto, cEmailUsuarioContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ReadRecordEmail>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/ReadRecordEmail",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cReadRecordEmailResult :=  WSAdvValue( oXmlRet,"_READRECORDEMAILRESPONSE:_READRECORDEMAILRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SaveRecord of Service WSwsDataServer

WSMETHOD SaveRecord WSSEND cDataServerName,cXML,cContexto WSRECEIVE cSaveRecordResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SaveRecord xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("XML", ::cXML, cXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SaveRecord>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/SaveRecord",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cSaveRecordResult  :=  WSAdvValue( oXmlRet,"_SAVERECORDRESPONSE:_SAVERECORDRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SaveRecordEmail of Service WSwsDataServer

WSMETHOD SaveRecordEmail WSSEND cDataServerName,cXML,cContexto,cEmailUsuarioContexto WSRECEIVE cSaveRecordEmailResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SaveRecordEmail xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("XML", ::cXML, cXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EmailUsuarioContexto", ::cEmailUsuarioContexto, cEmailUsuarioContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SaveRecordEmail>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/SaveRecordEmail",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cSaveRecordEmailResult :=  WSAdvValue( oXmlRet,"_SAVERECORDEMAILRESPONSE:_SAVERECORDEMAILRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DeleteRecord of Service WSwsDataServer

WSMETHOD DeleteRecord WSSEND cDataServerName,cXML,cContexto WSRECEIVE cDeleteRecordResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DeleteRecord xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("XML", ::cXML, cXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DeleteRecord>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/DeleteRecord",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cDeleteRecordResult :=  WSAdvValue( oXmlRet,"_DELETERECORDRESPONSE:_DELETERECORDRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DeleteRecordEmail of Service WSwsDataServer

WSMETHOD DeleteRecordEmail WSSEND cDataServerName,cXML,cContexto,cEmailUsuarioContexto WSRECEIVE cDeleteRecordEmailResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DeleteRecordEmail xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("XML", ::cXML, cXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EmailUsuarioContexto", ::cEmailUsuarioContexto, cEmailUsuarioContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DeleteRecordEmail>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/DeleteRecordEmail",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cDeleteRecordEmailResult :=  WSAdvValue( oXmlRet,"_DELETERECORDEMAILRESPONSE:_DELETERECORDEMAILRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DeleteRecordByKey of Service WSwsDataServer

WSMETHOD DeleteRecordByKey WSSEND cDataServerName,cPrimaryKey,cContexto WSRECEIVE cDeleteRecordByKeyResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DeleteRecordByKey xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PrimaryKey", ::cPrimaryKey, cPrimaryKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DeleteRecordByKey>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/DeleteRecordByKey",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cDeleteRecordByKeyResult :=  WSAdvValue( oXmlRet,"_DELETERECORDBYKEYRESPONSE:_DELETERECORDBYKEYRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ReadLookupView of Service WSwsDataServer

WSMETHOD ReadLookupView WSSEND cDataServerName,cFiltro,cContexto,cOwnerData WSRECEIVE cReadLookupViewResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReadLookupView xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Filtro", ::cFiltro, cFiltro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OwnerData", ::cOwnerData, cOwnerData , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ReadLookupView>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/ReadLookupView",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cReadLookupViewResult :=  WSAdvValue( oXmlRet,"_READLOOKUPVIEWRESPONSE:_READLOOKUPVIEWRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ReadLookupViewEmail of Service WSwsDataServer

WSMETHOD ReadLookupViewEmail WSSEND cDataServerName,cFiltro,cContexto,cOwnerData,cEmailUsuarioContexto WSRECEIVE cReadLookupViewEmailResult WSCLIENT WSwsDataServer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReadLookupViewEmail xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("DataServerName", ::cDataServerName, cDataServerName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Filtro", ::cFiltro, cFiltro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Contexto", ::cContexto, cContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OwnerData", ::cOwnerData, cOwnerData , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EmailUsuarioContexto", ::cEmailUsuarioContexto, cEmailUsuarioContexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ReadLookupViewEmail>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.totvs.com/IwsDataServer/ReadLookupViewEmail",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://vmsus67226.sp01.local:8084/wsDataServer/IwsDataServer")

::Init()
::cReadLookupViewEmailResult :=  WSAdvValue( oXmlRet,"_READLOOKUPVIEWEMAILRESPONSE:_READLOOKUPVIEWEMAILRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Type

WSSTRUCT wsDataServer_Type
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT wsDataServer_Type
	::Init()
Return Self

WSMETHOD INIT WSCLIENT wsDataServer_Type
Return

WSMETHOD CLONE WSCLIENT wsDataServer_Type
	Local oClone := wsDataServer_Type():NEW()
Return oClone

WSMETHOD SOAPSEND WSCLIENT wsDataServer_Type
	Local cSoap := ""
Return cSoap


