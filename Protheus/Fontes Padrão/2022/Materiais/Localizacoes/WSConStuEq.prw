#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://pruebas.stupendo.ec/EbillingV3.Consultas/ConsultaDocumento?wsdl
Generado en      09/17/18 16:32:13
Observaciones    Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _SWPMSUY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSConsultaDocumentoSoap
------------------------------------------------------------------------------- */

WSCLIENT WSConsultaDocumentoSoap

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD wsConsultaDocumento
	WSMETHOD wsConsultaDocumentoFechaAut
	WSMETHOD wsConsultaDocumentoPDF

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cRucEmpresa               AS string
	WSDATA   cTipoDocumento            AS string
	WSDATA   cEstablecimiento          AS string
	WSDATA   cPtoEmision               AS string
	WSDATA   cSecuencial               AS string
	WSDATA   cNombreArchivo            AS string
	WSDATA   cwsConsultaDocumentoResult AS string
	WSDATA   cClaveAcceso              AS string
	WSDATA   cNumAutorizacion          AS string
	WSDATA   cEstado                   AS string
	WSDATA   cDetalle                  AS string
	WSDATA   cEnContingencia           AS string
	WSDATA   cwsConsultaDocumentoFechaAutResult AS string
	WSDATA   cFechaAutorizacion        AS string
	WSDATA   cwsConsultaDocumentoPDFResult AS string
	WSDATA   cArchivoPDF               AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSConsultaDocumentoSoap
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180123 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSConsultaDocumentoSoap
Return

WSMETHOD RESET WSCLIENT WSConsultaDocumentoSoap
	::cRucEmpresa        := NIL 
	::cTipoDocumento     := NIL 
	::cEstablecimiento   := NIL 
	::cPtoEmision        := NIL 
	::cSecuencial        := NIL 
	::cNombreArchivo     := NIL 
	::cwsConsultaDocumentoResult := NIL 
	::cClaveAcceso       := NIL 
	::cNumAutorizacion   := NIL 
	::cEstado            := NIL 
	::cDetalle           := NIL 
	::cEnContingencia    := NIL 
	::cwsConsultaDocumentoFechaAutResult := NIL 
	::cFechaAutorizacion := NIL 
	::cwsConsultaDocumentoPDFResult := NIL 
	::cArchivoPDF        := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSConsultaDocumentoSoap
Local oClone := WSConsultaDocumentoSoap():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:cRucEmpresa   := ::cRucEmpresa
	oClone:cTipoDocumento := ::cTipoDocumento
	oClone:cEstablecimiento := ::cEstablecimiento
	oClone:cPtoEmision   := ::cPtoEmision
	oClone:cSecuencial   := ::cSecuencial
	oClone:cNombreArchivo := ::cNombreArchivo
	oClone:cwsConsultaDocumentoResult := ::cwsConsultaDocumentoResult
	oClone:cClaveAcceso  := ::cClaveAcceso
	oClone:cNumAutorizacion := ::cNumAutorizacion
	oClone:cEstado       := ::cEstado
	oClone:cDetalle      := ::cDetalle
	oClone:cEnContingencia := ::cEnContingencia
	oClone:cwsConsultaDocumentoFechaAutResult := ::cwsConsultaDocumentoFechaAutResult
	oClone:cFechaAutorizacion := ::cFechaAutorizacion
	oClone:cwsConsultaDocumentoPDFResult := ::cwsConsultaDocumentoPDFResult
	oClone:cArchivoPDF   := ::cArchivoPDF
Return oClone

// WSDL Method wsConsultaDocumento of Service WSConsultaDocumentoSoap

WSMETHOD wsConsultaDocumento WSSEND cRucEmpresa,cTipoDocumento,cEstablecimiento,cPtoEmision,cSecuencial,cNombreArchivo WSRECEIVE cwsConsultaDocumentoResult,cClaveAcceso,cNumAutorizacion,cEstado,cDetalle,cEnContingencia WSCLIENT WSConsultaDocumentoSoap
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:wsConsultaDocumento xmlns:q1="urn:wsConsultaDocumento">'
cSoap += WSSoapValue("RucEmpresa", ::cRucEmpresa, cRucEmpresa , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TipoDocumento", ::cTipoDocumento, cTipoDocumento , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Establecimiento", ::cEstablecimiento, cEstablecimiento , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PtoEmision", ::cPtoEmision, cPtoEmision , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Secuencial", ::cSecuencial, cSecuencial , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NombreArchivo", ::cNombreArchivo, cNombreArchivo , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:wsConsultaDocumento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:ConsultaDocumentoSoap#wsConsultaDocumento",; 
	"RPCX","urn:ConsultaDocumentoSoap",,,; 
	"https://pruebas.stupendo.ec/EbillingV3.Consultas/ConsultaDocumento?wsdl") //Modificado

::Init()
::cwsConsultaDocumentoResult :=  WSAdvValue( oXmlRet,"_WSCONSULTADOCUMENTORESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cClaveAcceso       :=  WSAdvValue( oXmlRet,"_CLAVEACCESO","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cNumAutorizacion   :=  WSAdvValue( oXmlRet,"_NUMAUTORIZACION","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cEstado            :=  WSAdvValue( oXmlRet,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cDetalle           :=  WSAdvValue( oXmlRet,"_DETALLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cEnContingencia    :=  WSAdvValue( oXmlRet,"_ENCONTINGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method wsConsultaDocumentoFechaAut of Service WSConsultaDocumentoSoap

WSMETHOD wsConsultaDocumentoFechaAut WSSEND cRucEmpresa,cTipoDocumento,cEstablecimiento,cPtoEmision,cSecuencial,cNombreArchivo WSRECEIVE cwsConsultaDocumentoFechaAutResult,cClaveAcceso,cNumAutorizacion,cEstado,cDetalle,cEnContingencia,cFechaAutorizacion WSCLIENT WSConsultaDocumentoSoap
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:wsConsultaDocumentoFechaAut xmlns:q1="urn:wsConsultaDocumentoFechaAut">'
cSoap += WSSoapValue("RucEmpresa", ::cRucEmpresa, cRucEmpresa , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TipoDocumento", ::cTipoDocumento, cTipoDocumento , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Establecimiento", ::cEstablecimiento, cEstablecimiento , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PtoEmision", ::cPtoEmision, cPtoEmision , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Secuencial", ::cSecuencial, cSecuencial , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NombreArchivo", ::cNombreArchivo, cNombreArchivo , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:wsConsultaDocumentoFechaAut>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:ConsultaDocumentoSoap#wsConsultaDocumentoFechaAut",; 
	"RPCX","urn:ConsultaDocumentoSoap",,,; 
	"https://pruebas.stupendo.ec/EbillingV3.Consultas/ConsultaDocumento?wsdl") //Modificado

::Init()
::cwsConsultaDocumentoFechaAutResult :=  WSAdvValue( oXmlRet,"_WSCONSULTADOCUMENTOFECHAAUTRESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cClaveAcceso       :=  WSAdvValue( oXmlRet,"_CLAVEACCESO","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cNumAutorizacion   :=  WSAdvValue( oXmlRet,"_NUMAUTORIZACION","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cEstado            :=  WSAdvValue( oXmlRet,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cDetalle           :=  WSAdvValue( oXmlRet,"_DETALLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cEnContingencia    :=  WSAdvValue( oXmlRet,"_ENCONTINGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cFechaAutorizacion :=  WSAdvValue( oXmlRet,"_FECHAAUTORIZACION","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method wsConsultaDocumentoPDF of Service WSConsultaDocumentoSoap

WSMETHOD wsConsultaDocumentoPDF WSSEND cRucEmpresa,cTipoDocumento,cEstablecimiento,cPtoEmision,cSecuencial,cNombreArchivo WSRECEIVE cwsConsultaDocumentoPDFResult,cClaveAcceso,cNumAutorizacion,cEstado,cDetalle,cEnContingencia,cFechaAutorizacion,cArchivoPDF WSCLIENT WSConsultaDocumentoSoap
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:wsConsultaDocumentoPDF xmlns:q1="urn:wsConsultaDocumentoPDF">'
cSoap += WSSoapValue("RucEmpresa", ::cRucEmpresa, cRucEmpresa , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TipoDocumento", ::cTipoDocumento, cTipoDocumento , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Establecimiento", ::cEstablecimiento, cEstablecimiento , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PtoEmision", ::cPtoEmision, cPtoEmision , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Secuencial", ::cSecuencial, cSecuencial , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NombreArchivo", ::cNombreArchivo, cNombreArchivo , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:wsConsultaDocumentoPDF>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:ConsultaDocumentoSoap#wsConsultaDocumentoPDF",; 
	"RPCX","urn:ConsultaDocumentoSoap",,,; 
	"https://pruebas.stupendo.ec/EbillingV3.Consultas/ConsultaDocumento?wsdl") //Modificado

::Init()
::cwsConsultaDocumentoPDFResult :=  WSAdvValue( oXmlRet,"_WSCONSULTADOCUMENTOPDFRESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cClaveAcceso       :=  WSAdvValue( oXmlRet,"_CLAVEACCESO","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cNumAutorizacion   :=  WSAdvValue( oXmlRet,"_NUMAUTORIZACION","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cEstado            :=  WSAdvValue( oXmlRet,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cDetalle           :=  WSAdvValue( oXmlRet,"_DETALLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cEnContingencia    :=  WSAdvValue( oXmlRet,"_ENCONTINGENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cFechaAutorizacion :=  WSAdvValue( oXmlRet,"_FECHAAUTORIZACION","string",NIL,NIL,NIL,"S",NIL,NIL) 
::cArchivoPDF        :=  WSAdvValue( oXmlRet,"_ARCHIVOPDF","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



