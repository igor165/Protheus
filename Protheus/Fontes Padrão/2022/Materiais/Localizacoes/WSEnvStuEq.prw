#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://161.47.91.90/Cargar/FileUploader.asmx?wsdl
Generado en      09/13/18 13:16:45
Observaciones    Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _JXQNKES ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFileUploader
------------------------------------------------------------------------------- */

WSCLIENT WSFileUploader

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD UploadFile
	WSMETHOD UploadFileAll
	WSMETHOD LoadFileAll
	WSMETHOD LoadFileAllSim

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cRucEmpresa               AS string
	WSDATA   carchivo                  AS base64Binary
	WSDATA   cNombreArchivo            AS string
	WSDATA   cUploadFileResult         AS string
	WSDATA   cmensaje                  AS string
	WSDATA   carchivoXML               AS base64Binary
	WSDATA   carchivoADJ               AS base64Binary
	WSDATA   cUploadFileAllResult      AS string
	WSDATA   carchivoTXT               AS base64Binary
	WSDATA   cLoadFileAllResult        AS string
	WSDATA   cLoadFileAllSimResult     AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFileUploader
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170816 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFileUploader
Return

WSMETHOD RESET WSCLIENT WSFileUploader
	::cRucEmpresa        := NIL 
	::carchivo           := NIL 
	::cNombreArchivo     := NIL 
	::cUploadFileResult  := NIL 
	::cmensaje           := NIL 
	::carchivoXML        := NIL 
	::carchivoADJ        := NIL 
	::cUploadFileAllResult := NIL 
	::carchivoTXT        := NIL 
	::cLoadFileAllResult := NIL 
	::cLoadFileAllSimResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFileUploader
Local oClone := WSFileUploader():New()
	oClone:_URL          := ::_URL 
	oClone:cRucEmpresa   := ::cRucEmpresa
	oClone:carchivo      := ::carchivo
	oClone:cNombreArchivo := ::cNombreArchivo
	oClone:cUploadFileResult := ::cUploadFileResult
	oClone:cmensaje      := ::cmensaje
	oClone:carchivoXML   := ::carchivoXML
	oClone:carchivoADJ   := ::carchivoADJ
	oClone:cUploadFileAllResult := ::cUploadFileAllResult
	oClone:carchivoTXT   := ::carchivoTXT
	oClone:cLoadFileAllResult := ::cLoadFileAllResult
	oClone:cLoadFileAllSimResult := ::cLoadFileAllSimResult
Return oClone

// WSDL Method UploadFile of Service WSFileUploader

WSMETHOD UploadFile WSSEND cRucEmpresa,carchivo,cNombreArchivo WSRECEIVE cUploadFileResult,cmensaje WSCLIENT WSFileUploader
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<UploadFile xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("RucEmpresa", ::cRucEmpresa, cRucEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("archivo", ::carchivo, carchivo , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NombreArchivo", ::cNombreArchivo, cNombreArchivo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</UploadFile>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/UploadFile",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://161.47.91.90/Cargar/FileUploader.asmx")

::Init()
::cUploadFileResult  :=  WSAdvValue( oXmlRet,"_UPLOADFILERESPONSE:_UPLOADFILERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 
::cmensaje           :=  WSAdvValue( oXmlRet,"_UPLOADFILERESPONSE:_MENSAJE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method UploadFileAll of Service WSFileUploader

WSMETHOD UploadFileAll WSSEND cRucEmpresa,carchivoXML,carchivoADJ,cNombreArchivo WSRECEIVE cUploadFileAllResult WSCLIENT WSFileUploader
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<UploadFileAll xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("RucEmpresa", ::cRucEmpresa, cRucEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("archivoXML", ::carchivoXML, carchivoXML , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("archivoADJ", ::carchivoADJ, carchivoADJ , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NombreArchivo", ::cNombreArchivo, cNombreArchivo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</UploadFileAll>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/UploadFileAll",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://161.47.91.90/Cargar/FileUploader.asmx")

::Init()
::cUploadFileAllResult :=  WSAdvValue( oXmlRet,"_UPLOADFILEALLRESPONSE:_UPLOADFILEALLRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LoadFileAll of Service WSFileUploader

WSMETHOD LoadFileAll WSSEND cRucEmpresa,carchivoTXT,carchivoADJ,cNombreArchivo WSRECEIVE cLoadFileAllResult WSCLIENT WSFileUploader
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LoadFileAll xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("RucEmpresa", ::cRucEmpresa, cRucEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("archivoTXT", ::carchivoTXT, carchivoTXT , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("archivoADJ", ::carchivoADJ, carchivoADJ , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NombreArchivo", ::cNombreArchivo, cNombreArchivo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LoadFileAll>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/LoadFileAll",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://161.47.91.90/Cargar/FileUploader.asmx")

::Init()
::cLoadFileAllResult :=  WSAdvValue( oXmlRet,"_LOADFILEALLRESPONSE:_LOADFILEALLRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LoadFileAllSim of Service WSFileUploader

WSMETHOD LoadFileAllSim WSSEND cRucEmpresa,carchivoTXT,carchivoADJ,cNombreArchivo WSRECEIVE cLoadFileAllSimResult WSCLIENT WSFileUploader
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LoadFileAllSim xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("RucEmpresa", ::cRucEmpresa, cRucEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("archivoTXT", ::carchivoTXT, carchivoTXT , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("archivoADJ", ::carchivoADJ, carchivoADJ , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NombreArchivo", ::cNombreArchivo, cNombreArchivo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</LoadFileAllSim>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/LoadFileAllSim",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://161.47.91.90/Cargar/FileUploader.asmx")

::Init()
::cLoadFileAllSimResult :=  WSAdvValue( oXmlRet,"_LOADFILEALLSIMRESPONSE:_LOADFILEALLSIMRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



