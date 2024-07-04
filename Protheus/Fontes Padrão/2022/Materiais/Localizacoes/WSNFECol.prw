#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc?wsdl
Generado en        15/03/22 11:52:29
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _DMQQKXS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNFECol
------------------------------------------------------------------------------- */

WSCLIENT WSNFECol

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Enviar
	WSMETHOD EstadoDocumento
	WSMETHOD EnvioCorreo
	WSMETHOD DescargaPDF
	WSMETHOD DescargaXML
	WSMETHOD FoliosRestantes
	WSMETHOD CargarCertificado
	WSMETHOD GenerarEvento
	WSMETHOD DescargarEventoXML
	WSMETHOD GenerarContenedor

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ctokenEmpresa             AS string
	WSDATA   ctokenPassword            AS string
	WSDATA   oWSfactura                AS Service_FacturaGeneral
	WSDATA   cadjuntos                 AS string
	WSDATA   oWSEnviarResult           AS Service_DocumentResponse
	WSDATA   cdocumento                AS string
	WSDATA   oWSEstadoDocumentoResult  AS Service_DocumentStatusResponse
	WSDATA   ccorreo                   AS string
	WSDATA   oWSEnvioCorreoResult      AS Service_SendEmailResponse
	WSDATA   oWSDescargaPDFResult      AS Service_DownloadPDFResponse
	WSDATA   oWSDescargaXMLResult      AS Service_DownloadXMLResponse
	WSDATA   oWSFoliosRestantesResult  AS Service_FoliosRemainingResponse
	WSDATA   ccertificado              AS string
	WSDATA   cpassword                 AS string
	WSDATA   oWSCargarCertificadoResult AS Service_LoadCertificateResponse
	WSDATA   oWSdatosEvento            AS Service_DatosEvento
	WSDATA   oWSGenerarEventoResult    AS Service_EventoResponse
	WSDATA   cdocumentoEvento          AS string
	WSDATA   oWSDescargarEventoXMLResult AS Service_DescargarEventoResponse
	WSDATA   oWSGenerarContenedorResult AS Service_ContenedorResponse

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNFECol
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNFECol
	::oWSfactura         := Service_FACTURAGENERAL():New()
	::oWSEnviarResult    := Service_DOCUMENTRESPONSE():New()
	::oWSEstadoDocumentoResult := Service_DOCUMENTSTATUSRESPONSE():New()
	::oWSEnvioCorreoResult := Service_SENDEMAILRESPONSE():New()
	::oWSDescargaPDFResult := Service_DOWNLOADPDFRESPONSE():New()
	::oWSDescargaXMLResult := Service_DOWNLOADXMLRESPONSE():New()
	::oWSFoliosRestantesResult := Service_FOLIOSREMAININGRESPONSE():New()
	::oWSCargarCertificadoResult := Service_LOADCERTIFICATERESPONSE():New()
	::oWSdatosEvento     := Service_DATOSEVENTO():New()
	::oWSGenerarEventoResult := Service_EVENTORESPONSE():New()
	::oWSDescargarEventoXMLResult := Service_DESCARGAREVENTORESPONSE():New()
	::oWSGenerarContenedorResult := Service_CONTENEDORRESPONSE():New()
Return

WSMETHOD RESET WSCLIENT WSNFECol
	::ctokenEmpresa      := NIL 
	::ctokenPassword     := NIL 
	::oWSfactura         := NIL 
	::cadjuntos          := NIL 
	::oWSEnviarResult    := NIL 
	::cdocumento         := NIL 
	::oWSEstadoDocumentoResult := NIL 
	::ccorreo            := NIL 
	::oWSEnvioCorreoResult := NIL 
	::oWSDescargaPDFResult := NIL 
	::oWSDescargaXMLResult := NIL 
	::oWSFoliosRestantesResult := NIL 
	::ccertificado       := NIL 
	::cpassword          := NIL 
	::oWSCargarCertificadoResult := NIL 
	::oWSdatosEvento     := NIL 
	::oWSGenerarEventoResult := NIL 
	::cdocumentoEvento   := NIL 
	::oWSDescargarEventoXMLResult := NIL 
	::oWSGenerarContenedorResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNFECol
Local oClone := WSNFECol():New()
	oClone:_URL          := ::_URL 
	oClone:ctokenEmpresa := ::ctokenEmpresa
	oClone:ctokenPassword := ::ctokenPassword
	oClone:oWSfactura    :=  IIF(::oWSfactura = NIL , NIL ,::oWSfactura:Clone() )
	oClone:cadjuntos     := ::cadjuntos
	oClone:oWSEnviarResult :=  IIF(::oWSEnviarResult = NIL , NIL ,::oWSEnviarResult:Clone() )
	oClone:cdocumento    := ::cdocumento
	oClone:oWSEstadoDocumentoResult :=  IIF(::oWSEstadoDocumentoResult = NIL , NIL ,::oWSEstadoDocumentoResult:Clone() )
	oClone:ccorreo       := ::ccorreo
	oClone:oWSEnvioCorreoResult :=  IIF(::oWSEnvioCorreoResult = NIL , NIL ,::oWSEnvioCorreoResult:Clone() )
	oClone:oWSDescargaPDFResult :=  IIF(::oWSDescargaPDFResult = NIL , NIL ,::oWSDescargaPDFResult:Clone() )
	oClone:oWSDescargaXMLResult :=  IIF(::oWSDescargaXMLResult = NIL , NIL ,::oWSDescargaXMLResult:Clone() )
	oClone:oWSFoliosRestantesResult :=  IIF(::oWSFoliosRestantesResult = NIL , NIL ,::oWSFoliosRestantesResult:Clone() )
	oClone:ccertificado  := ::ccertificado
	oClone:cpassword     := ::cpassword
	oClone:oWSCargarCertificadoResult :=  IIF(::oWSCargarCertificadoResult = NIL , NIL ,::oWSCargarCertificadoResult:Clone() )
	oClone:oWSdatosEvento :=  IIF(::oWSdatosEvento = NIL , NIL ,::oWSdatosEvento:Clone() )
	oClone:oWSGenerarEventoResult :=  IIF(::oWSGenerarEventoResult = NIL , NIL ,::oWSGenerarEventoResult:Clone() )
	oClone:cdocumentoEvento := ::cdocumentoEvento
	oClone:oWSDescargarEventoXMLResult :=  IIF(::oWSDescargarEventoXMLResult = NIL , NIL ,::oWSDescargarEventoXMLResult:Clone() )
	oClone:oWSGenerarContenedorResult :=  IIF(::oWSGenerarContenedorResult = NIL , NIL ,::oWSGenerarContenedorResult:Clone() )
Return oClone

// WSDL Method Enviar of Service WSNFECol

WSMETHOD Enviar WSSEND ctokenEmpresa,ctokenPassword,oWSfactura,cadjuntos WSRECEIVE oWSEnviarResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet
Local cSoapFE := GetMv( "MV_SOAPFE" , .F. ,  "")

BEGIN WSMETHOD

cSoap += '<Enviar xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("factura", ::oWSfactura, oWSfactura , "FacturaGeneral", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += WSSoapValue("adjuntos", ::cadjuntos, cadjuntos , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Enviar>"

If cSoapFE == "1"
	conout("WSEnviar: " + cSoap)
EndIf
oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/Enviar",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSEnviarResult:SoapRecv( WSAdvValue( oXmlRet,"_ENVIARRESPONSE:_ENVIARRESULT","DocumentResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EstadoDocumento of Service WSNFECol

WSMETHOD EstadoDocumento WSSEND ctokenEmpresa,ctokenPassword,cdocumento WSRECEIVE oWSEstadoDocumentoResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EstadoDocumento xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documento", ::cdocumento, cdocumento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EstadoDocumento>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/EstadoDocumento",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSEstadoDocumentoResult:SoapRecv( WSAdvValue( oXmlRet,"_ESTADODOCUMENTORESPONSE:_ESTADODOCUMENTORESULT","DocumentStatusResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EnvioCorreo of Service WSNFECol

WSMETHOD EnvioCorreo WSSEND ctokenEmpresa,ctokenPassword,cdocumento,ccorreo,cadjuntos WSRECEIVE oWSEnvioCorreoResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EnvioCorreo xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documento", ::cdocumento, cdocumento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("correo", ::ccorreo, ccorreo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("adjuntos", ::cadjuntos, cadjuntos , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EnvioCorreo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/EnvioCorreo",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSEnvioCorreoResult:SoapRecv( WSAdvValue( oXmlRet,"_ENVIOCORREORESPONSE:_ENVIOCORREORESULT","SendEmailResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DescargaPDF of Service WSNFECol

WSMETHOD DescargaPDF WSSEND ctokenEmpresa,ctokenPassword,cdocumento WSRECEIVE oWSDescargaPDFResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DescargaPDF xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documento", ::cdocumento, cdocumento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DescargaPDF>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/DescargaPDF",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSDescargaPDFResult:SoapRecv( WSAdvValue( oXmlRet,"_DESCARGAPDFRESPONSE:_DESCARGAPDFRESULT","DownloadPDFResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DescargaXML of Service WSNFECol

WSMETHOD DescargaXML WSSEND ctokenEmpresa,ctokenPassword,cdocumento WSRECEIVE oWSDescargaXMLResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DescargaXML xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documento", ::cdocumento, cdocumento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DescargaXML>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/DescargaXML",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSDescargaXMLResult:SoapRecv( WSAdvValue( oXmlRet,"_DESCARGAXMLRESPONSE:_DESCARGAXMLRESULT","DownloadXMLResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method FoliosRestantes of Service WSNFECol

WSMETHOD FoliosRestantes WSSEND ctokenEmpresa,ctokenPassword WSRECEIVE oWSFoliosRestantesResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FoliosRestantes xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</FoliosRestantes>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/FoliosRestantes",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSFoliosRestantesResult:SoapRecv( WSAdvValue( oXmlRet,"_FOLIOSRESTANTESRESPONSE:_FOLIOSRESTANTESRESULT","FoliosRemainingResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CargarCertificado of Service WSNFECol

WSMETHOD CargarCertificado WSSEND ctokenEmpresa,ctokenPassword,ccertificado,cpassword WSRECEIVE oWSCargarCertificadoResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CargarCertificado xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("certificado", ::ccertificado, ccertificado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CargarCertificado>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/CargarCertificado",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSCargarCertificadoResult:SoapRecv( WSAdvValue( oXmlRet,"_CARGARCERTIFICADORESPONSE:_CARGARCERTIFICADORESULT","LoadCertificateResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GenerarEvento of Service WSNFECol

WSMETHOD GenerarEvento WSSEND ctokenEmpresa,ctokenPassword,oWSdatosEvento WSRECEIVE oWSGenerarEventoResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GenerarEvento xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("datosEvento", ::oWSdatosEvento, oWSdatosEvento , "DatosEvento", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</GenerarEvento>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GenerarEvento",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSGenerarEventoResult:SoapRecv( WSAdvValue( oXmlRet,"_GENERAREVENTORESPONSE:_GENERAREVENTORESULT","EventoResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DescargarEventoXML of Service WSNFECol

WSMETHOD DescargarEventoXML WSSEND ctokenEmpresa,ctokenPassword,cdocumentoEvento,cdocumento WSRECEIVE oWSDescargarEventoXMLResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DescargarEventoXML xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documentoEvento", ::cdocumentoEvento, cdocumentoEvento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documento", ::cdocumento, cdocumento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DescargarEventoXML>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/DescargarEventoXML",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSDescargarEventoXMLResult:SoapRecv( WSAdvValue( oXmlRet,"_DESCARGAREVENTOXMLRESPONSE:_DESCARGAREVENTOXMLRESULT","DescargarEventoResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GenerarContenedor of Service WSNFECol

WSMETHOD GenerarContenedor WSSEND ctokenEmpresa,ctokenPassword,cdocumento WSRECEIVE oWSGenerarContenedorResult WSCLIENT WSNFECol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GenerarContenedor xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documento", ::cdocumento, cdocumento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GenerarContenedor>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/GenerarContenedor",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/v1.0/Service.svc")

::Init()
::oWSGenerarContenedorResult:SoapRecv( WSAdvValue( oXmlRet,"_GENERARCONTENEDORRESPONSE:_GENERARCONTENEDORRESULT","ContenedorResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure FacturaGeneral

WSSTRUCT Service_FacturaGeneral
	WSDATA   oWSanticipos              AS Service_ArrayOfAnticipos OPTIONAL
	WSDATA   oWSautorizado             AS Service_Autorizado OPTIONAL
	WSDATA   ccantidadDecimales        AS string OPTIONAL
	WSDATA   oWScargosDescuentos       AS Service_ArrayOfCargosDescuentos OPTIONAL
	WSDATA   oWScliente                AS Service_Cliente OPTIONAL
	WSDATA   oWScondicionPago          AS Service_ArrayOfCondicionDePago OPTIONAL
	WSDATA   cconsecutivoDocumento     AS string OPTIONAL
	WSDATA   oWSdetalleDeFactura       AS Service_ArrayOfFacturaDetalle OPTIONAL
	WSDATA   oWSdocumentosReferenciados AS Service_ArrayOfDocumentoReferenciado OPTIONAL
	WSDATA   oWSentregaMercancia       AS Service_Entrega OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtras OPTIONAL
	WSDATA   cfechaEmision             AS string OPTIONAL
	WSDATA   cfechaFinPeriodoFacturacion AS string OPTIONAL
	WSDATA   cfechaInicioPeriodoFacturacion AS string OPTIONAL
	WSDATA   cfechaPagoImpuestos       AS string OPTIONAL
	WSDATA   cfechaVencimiento         AS string OPTIONAL
	WSDATA   oWSimpuestosGenerales     AS Service_ArrayOfFacturaImpuestos OPTIONAL
	WSDATA   oWSimpuestosTotales       AS Service_ArrayOfImpuestosTotales OPTIONAL
	WSDATA   oWSinformacionAdicional   AS Service_ArrayOfstring OPTIONAL
	WSDATA   oWSmediosDePago           AS Service_ArrayOfMediosDePago OPTIONAL
	WSDATA   cmoneda                   AS string OPTIONAL
	WSDATA   oWSordenDeCompra          AS Service_ArrayOfOrdenDeCompra OPTIONAL
	WSDATA   cpropina                  AS string OPTIONAL
	WSDATA   crangoNumeracion          AS string OPTIONAL
	WSDATA   credondeoAplicado         AS string OPTIONAL
	WSDATA   oWSsectorSalud            AS Service_SectorSalud OPTIONAL
	WSDATA   oWStasaDeCambio           AS Service_TasaDeCambio OPTIONAL
	WSDATA   oWStasaDeCambioAlternativa AS Service_TasaDeCambioAlternativa OPTIONAL
	WSDATA   oWSterminosEntrega        AS Service_TerminosDeEntrega OPTIONAL
	WSDATA   ctipoDocumento            AS string OPTIONAL
	WSDATA   ctipoOperacion            AS string OPTIONAL
	WSDATA   ctipoSector               AS string OPTIONAL
	WSDATA   ctotalAnticipos           AS string OPTIONAL
	WSDATA   ctotalBaseImponible       AS string OPTIONAL
	WSDATA   ctotalBrutoConImpuesto    AS string OPTIONAL
	WSDATA   ctotalCargosAplicados     AS string OPTIONAL
	WSDATA   ctotalDescuentos          AS string OPTIONAL
	WSDATA   ctotalMonto               AS string OPTIONAL
	WSDATA   ctotalProductos           AS string OPTIONAL
	WSDATA   ctotalSinImpuestos        AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_FacturaGeneral
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_FacturaGeneral
Return

WSMETHOD CLONE WSCLIENT Service_FacturaGeneral
	Local oClone := Service_FacturaGeneral():NEW()
	oClone:oWSanticipos         := IIF(::oWSanticipos = NIL , NIL , ::oWSanticipos:Clone() )
	oClone:oWSautorizado        := IIF(::oWSautorizado = NIL , NIL , ::oWSautorizado:Clone() )
	oClone:ccantidadDecimales   := ::ccantidadDecimales
	oClone:oWScargosDescuentos  := IIF(::oWScargosDescuentos = NIL , NIL , ::oWScargosDescuentos:Clone() )
	oClone:oWScliente           := IIF(::oWScliente = NIL , NIL , ::oWScliente:Clone() )
	oClone:oWScondicionPago     := IIF(::oWScondicionPago = NIL , NIL , ::oWScondicionPago:Clone() )
	oClone:cconsecutivoDocumento := ::cconsecutivoDocumento
	oClone:oWSdetalleDeFactura  := IIF(::oWSdetalleDeFactura = NIL , NIL , ::oWSdetalleDeFactura:Clone() )
	oClone:oWSdocumentosReferenciados := IIF(::oWSdocumentosReferenciados = NIL , NIL , ::oWSdocumentosReferenciados:Clone() )
	oClone:oWSentregaMercancia  := IIF(::oWSentregaMercancia = NIL , NIL , ::oWSentregaMercancia:Clone() )
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaEmision        := ::cfechaEmision
	oClone:cfechaFinPeriodoFacturacion := ::cfechaFinPeriodoFacturacion
	oClone:cfechaInicioPeriodoFacturacion := ::cfechaInicioPeriodoFacturacion
	oClone:cfechaPagoImpuestos  := ::cfechaPagoImpuestos
	oClone:cfechaVencimiento    := ::cfechaVencimiento
	oClone:oWSimpuestosGenerales := IIF(::oWSimpuestosGenerales = NIL , NIL , ::oWSimpuestosGenerales:Clone() )
	oClone:oWSimpuestosTotales  := IIF(::oWSimpuestosTotales = NIL , NIL , ::oWSimpuestosTotales:Clone() )
	oClone:oWSinformacionAdicional := IIF(::oWSinformacionAdicional = NIL , NIL , ::oWSinformacionAdicional:Clone() )
	oClone:oWSmediosDePago      := IIF(::oWSmediosDePago = NIL , NIL , ::oWSmediosDePago:Clone() )
	oClone:cmoneda              := ::cmoneda
	oClone:oWSordenDeCompra     := IIF(::oWSordenDeCompra = NIL , NIL , ::oWSordenDeCompra:Clone() )
	oClone:cpropina             := ::cpropina
	oClone:crangoNumeracion     := ::crangoNumeracion
	oClone:credondeoAplicado    := ::credondeoAplicado
	oClone:oWSsectorSalud       := IIF(::oWSsectorSalud = NIL , NIL , ::oWSsectorSalud:Clone() )
	oClone:oWStasaDeCambio      := IIF(::oWStasaDeCambio = NIL , NIL , ::oWStasaDeCambio:Clone() )
	oClone:oWStasaDeCambioAlternativa := IIF(::oWStasaDeCambioAlternativa = NIL , NIL , ::oWStasaDeCambioAlternativa:Clone() )
	oClone:oWSterminosEntrega   := IIF(::oWSterminosEntrega = NIL , NIL , ::oWSterminosEntrega:Clone() )
	oClone:ctipoDocumento       := ::ctipoDocumento
	oClone:ctipoOperacion       := ::ctipoOperacion
	oClone:ctipoSector          := ::ctipoSector
	oClone:ctotalAnticipos      := ::ctotalAnticipos
	oClone:ctotalBaseImponible  := ::ctotalBaseImponible
	oClone:ctotalBrutoConImpuesto := ::ctotalBrutoConImpuesto
	oClone:ctotalCargosAplicados := ::ctotalCargosAplicados
	oClone:ctotalDescuentos     := ::ctotalDescuentos
	oClone:ctotalMonto          := ::ctotalMonto
	oClone:ctotalProductos      := ::ctotalProductos
	oClone:ctotalSinImpuestos   := ::ctotalSinImpuestos
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_FacturaGeneral
	Local cSoap := ""
	cSoap += WSSoapValue("anticipos", ::oWSanticipos, ::oWSanticipos , "ArrayOfAnticipos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("autorizado", ::oWSautorizado, ::oWSautorizado , "Autorizado", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("cantidadDecimales", ::ccantidadDecimales, ::ccantidadDecimales , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("cargosDescuentos", ::oWScargosDescuentos, ::oWScargosDescuentos , "ArrayOfCargosDescuentos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("cliente", ::oWScliente, ::oWScliente , "Cliente", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("condicionPago", ::oWScondicionPago, ::oWScondicionPago , "ArrayOfCondicionDePago", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("consecutivoDocumento", ::cconsecutivoDocumento, ::cconsecutivoDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("detalleDeFactura", ::oWSdetalleDeFactura, ::oWSdetalleDeFactura , "ArrayOfFacturaDetalle", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("documentosReferenciados", ::oWSdocumentosReferenciados, ::oWSdocumentosReferenciados , "ArrayOfDocumentoReferenciado", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("entregaMercancia", ::oWSentregaMercancia, ::oWSentregaMercancia , "Entrega", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtras", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaEmision", ::cfechaEmision, ::cfechaEmision , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaFinPeriodoFacturacion", ::cfechaFinPeriodoFacturacion, ::cfechaFinPeriodoFacturacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaInicioPeriodoFacturacion", ::cfechaInicioPeriodoFacturacion, ::cfechaInicioPeriodoFacturacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaPagoImpuestos", ::cfechaPagoImpuestos, ::cfechaPagoImpuestos , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaVencimiento", ::cfechaVencimiento, ::cfechaVencimiento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("impuestosGenerales", ::oWSimpuestosGenerales, ::oWSimpuestosGenerales , "ArrayOfFacturaImpuestos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("impuestosTotales", ::oWSimpuestosTotales, ::oWSimpuestosTotales , "ArrayOfImpuestosTotales", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("informacionAdicional", ::oWSinformacionAdicional, ::oWSinformacionAdicional , "ArrayOfstring", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("mediosDePago", ::oWSmediosDePago, ::oWSmediosDePago , "ArrayOfMediosDePago", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("moneda", ::cmoneda, ::cmoneda , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("ordenDeCompra", ::oWSordenDeCompra, ::oWSordenDeCompra , "ArrayOfOrdenDeCompra", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("propina", ::cpropina, ::cpropina , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("rangoNumeracion", ::crangoNumeracion, ::crangoNumeracion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("redondeoAplicado", ::credondeoAplicado, ::credondeoAplicado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("sectorSalud", ::oWSsectorSalud, ::oWSsectorSalud , "SectorSalud", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tasaDeCambio", ::oWStasaDeCambio, ::oWStasaDeCambio , "TasaDeCambio", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tasaDeCambioAlternativa", ::oWStasaDeCambioAlternativa, ::oWStasaDeCambioAlternativa , "TasaDeCambioAlternativa", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("terminosEntrega", ::oWSterminosEntrega, ::oWSterminosEntrega , "TerminosDeEntrega", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoDocumento", ::ctipoDocumento, ::ctipoDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoOperacion", ::ctipoOperacion, ::ctipoOperacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoSector", ::ctipoSector, ::ctipoSector , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("totalAnticipos", ::ctotalAnticipos, ::ctotalAnticipos , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("totalBaseImponible", ::ctotalBaseImponible, ::ctotalBaseImponible , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("totalBrutoConImpuesto", ::ctotalBrutoConImpuesto, ::ctotalBrutoConImpuesto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("totalCargosAplicados", ::ctotalCargosAplicados, ::ctotalCargosAplicados , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("totalDescuentos", ::ctotalDescuentos, ::ctotalDescuentos , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("totalMonto", ::ctotalMonto, ::ctotalMonto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("totalProductos", ::ctotalProductos, ::ctotalProductos , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("totalSinImpuestos", ::ctotalSinImpuestos, ::ctotalSinImpuestos , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure DocumentResponse

WSSTRUCT Service_DocumentResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cconsecutivoDocumento     AS string OPTIONAL
	WSDATA   ccufe                     AS string OPTIONAL
	WSDATA   lesValidoDian             AS boolean OPTIONAL
	WSDATA   cfechaAceptacionDIAN      AS string OPTIONAL
	WSDATA   cfechaRespuesta           AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   oWSmensajesValidacion     AS Service_ArrayOfstring OPTIONAL
	WSDATA   cnombre                   AS string OPTIONAL
	WSDATA   cqr                       AS string OPTIONAL
	WSDATA   oWSreglasNotificacionDIAN AS Service_ArrayOfstring OPTIONAL
	WSDATA   oWSreglasValidacionDIAN   AS Service_ArrayOfstring OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctipoCufe                 AS string OPTIONAL
	WSDATA   cxml                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DocumentResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DocumentResponse
Return

WSMETHOD CLONE WSCLIENT Service_DocumentResponse
	Local oClone := Service_DocumentResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cconsecutivoDocumento := ::cconsecutivoDocumento
	oClone:ccufe                := ::ccufe
	oClone:lesValidoDian        := ::lesValidoDian
	oClone:cfechaAceptacionDIAN := ::cfechaAceptacionDIAN
	oClone:cfechaRespuesta      := ::cfechaRespuesta
	oClone:chash                := ::chash
	oClone:cmensaje             := ::cmensaje
	oClone:oWSmensajesValidacion := IIF(::oWSmensajesValidacion = NIL , NIL , ::oWSmensajesValidacion:Clone() )
	oClone:cnombre              := ::cnombre
	oClone:cqr                  := ::cqr
	oClone:oWSreglasNotificacionDIAN := IIF(::oWSreglasNotificacionDIAN = NIL , NIL , ::oWSreglasNotificacionDIAN:Clone() )
	oClone:oWSreglasValidacionDIAN := IIF(::oWSreglasValidacionDIAN = NIL , NIL , ::oWSreglasValidacionDIAN:Clone() )
	oClone:cresultado           := ::cresultado
	oClone:ctipoCufe            := ::ctipoCufe
	oClone:cxml                 := ::cxml
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_DocumentResponse
	Local oNode9
	Local oNode12
	Local oNode13
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cconsecutivoDocumento :=  WSAdvValue( oResponse,"_CONSECUTIVODOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccufe              :=  WSAdvValue( oResponse,"_CUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lesValidoDian      :=  WSAdvValue( oResponse,"_ESVALIDODIAN","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cfechaAceptacionDIAN :=  WSAdvValue( oResponse,"_FECHAACEPTACIONDIAN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfechaRespuesta    :=  WSAdvValue( oResponse,"_FECHARESPUESTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode9 :=  WSAdvValue( oResponse,"_MENSAJESVALIDACION","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode9 != NIL
		::oWSmensajesValidacion := Service_ArrayOfstring():New()
		::oWSmensajesValidacion:SoapRecv(oNode9)
	EndIf
	::cnombre            :=  WSAdvValue( oResponse,"_NOMBRE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cqr                :=  WSAdvValue( oResponse,"_QR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode12 :=  WSAdvValue( oResponse,"_REGLASNOTIFICACIONDIAN","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWSreglasNotificacionDIAN := Service_ArrayOfstring():New()
		::oWSreglasNotificacionDIAN:SoapRecv(oNode12)
	EndIf
	oNode13 :=  WSAdvValue( oResponse,"_REGLASVALIDACIONDIAN","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWSreglasValidacionDIAN := Service_ArrayOfstring():New()
		::oWSreglasValidacionDIAN:SoapRecv(oNode13)
	EndIf
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoCufe          :=  WSAdvValue( oResponse,"_TIPOCUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cxml               :=  WSAdvValue( oResponse,"_XML","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DocumentStatusResponse

WSSTRUCT Service_DocumentStatusResponse
	WSDATA   laceptacionFisica         AS boolean OPTIONAL
	WSDATA   cacuseComentario          AS string OPTIONAL
	WSDATA   cacuseEstatus             AS string OPTIONAL
	WSDATA   cacuseResponsable         AS string OPTIONAL
	WSDATA   cacuseRespuesta           AS string OPTIONAL
	WSDATA   cambiente                 AS string OPTIONAL
	WSDATA   ccadenaCodigoQR           AS string OPTIONAL
	WSDATA   ccadenaCufe               AS string OPTIONAL
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cconsecutivo              AS string OPTIONAL
	WSDATA   ccufe                     AS string OPTIONAL
	WSDATA   cdescripcionDocumento     AS string OPTIONAL
	WSDATA   cdescripcionEstatusDocumento AS string OPTIONAL
	WSDATA   centregaMetodoDIAN        AS string OPTIONAL
	WSDATA   lesValidoDIAN             AS boolean OPTIONAL
	WSDATA   nestatusDocumento         AS int OPTIONAL
	WSDATA   oWSeventos                AS Service_ArrayOfEvento OPTIONAL
	WSDATA   cfechaAceptacionDIAN      AS string OPTIONAL
	WSDATA   cfechaDocumento           AS string OPTIONAL
	WSDATA   oWShistorialDeEntregas    AS Service_ArrayOfHistorialDeEntrega OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cmensajeDocumento         AS string OPTIONAL
	WSDATA   lposeeAdjuntos            AS boolean OPTIONAL
	WSDATA   lposeeRepresentacionGrafica AS boolean OPTIONAL
	WSDATA   oWSreglasValidacionDIAN   AS Service_ArrayOfstring OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctipoCufe                 AS string OPTIONAL
	WSDATA   ctipoDocumento            AS string OPTIONAL
	WSDATA   ctrackID                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DocumentStatusResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DocumentStatusResponse
Return

WSMETHOD CLONE WSCLIENT Service_DocumentStatusResponse
	Local oClone := Service_DocumentStatusResponse():NEW()
	oClone:laceptacionFisica    := ::laceptacionFisica
	oClone:cacuseComentario     := ::cacuseComentario
	oClone:cacuseEstatus        := ::cacuseEstatus
	oClone:cacuseResponsable    := ::cacuseResponsable
	oClone:cacuseRespuesta      := ::cacuseRespuesta
	oClone:cambiente            := ::cambiente
	oClone:ccadenaCodigoQR      := ::ccadenaCodigoQR
	oClone:ccadenaCufe          := ::ccadenaCufe
	oClone:ncodigo              := ::ncodigo
	oClone:cconsecutivo         := ::cconsecutivo
	oClone:ccufe                := ::ccufe
	oClone:cdescripcionDocumento := ::cdescripcionDocumento
	oClone:cdescripcionEstatusDocumento := ::cdescripcionEstatusDocumento
	oClone:centregaMetodoDIAN   := ::centregaMetodoDIAN
	oClone:lesValidoDIAN        := ::lesValidoDIAN
	oClone:nestatusDocumento    := ::nestatusDocumento
	oClone:oWSeventos           := IIF(::oWSeventos = NIL , NIL , ::oWSeventos:Clone() )
	oClone:cfechaAceptacionDIAN := ::cfechaAceptacionDIAN
	oClone:cfechaDocumento      := ::cfechaDocumento
	oClone:oWShistorialDeEntregas := IIF(::oWShistorialDeEntregas = NIL , NIL , ::oWShistorialDeEntregas:Clone() )
	oClone:cmensaje             := ::cmensaje
	oClone:cmensajeDocumento    := ::cmensajeDocumento
	oClone:lposeeAdjuntos       := ::lposeeAdjuntos
	oClone:lposeeRepresentacionGrafica := ::lposeeRepresentacionGrafica
	oClone:oWSreglasValidacionDIAN := IIF(::oWSreglasValidacionDIAN = NIL , NIL , ::oWSreglasValidacionDIAN:Clone() )
	oClone:cresultado           := ::cresultado
	oClone:ctipoCufe            := ::ctipoCufe
	oClone:ctipoDocumento       := ::ctipoDocumento
	oClone:ctrackID             := ::ctrackID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_DocumentStatusResponse
	Local oNode17
	Local oNode20
	Local oNode25
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::laceptacionFisica  :=  WSAdvValue( oResponse,"_ACEPTACIONFISICA","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cacuseComentario   :=  WSAdvValue( oResponse,"_ACUSECOMENTARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cacuseEstatus      :=  WSAdvValue( oResponse,"_ACUSEESTATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cacuseResponsable  :=  WSAdvValue( oResponse,"_ACUSERESPONSABLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cacuseRespuesta    :=  WSAdvValue( oResponse,"_ACUSERESPUESTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cambiente          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccadenaCodigoQR    :=  WSAdvValue( oResponse,"_CADENACODIGOQR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccadenaCufe        :=  WSAdvValue( oResponse,"_CADENACUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cconsecutivo       :=  WSAdvValue( oResponse,"_CONSECUTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccufe              :=  WSAdvValue( oResponse,"_CUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescripcionDocumento :=  WSAdvValue( oResponse,"_DESCRIPCIONDOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescripcionEstatusDocumento :=  WSAdvValue( oResponse,"_DESCRIPCIONESTATUSDOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::centregaMetodoDIAN :=  WSAdvValue( oResponse,"_ENTREGAMETODODIAN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lesValidoDIAN      :=  WSAdvValue( oResponse,"_ESVALIDODIAN","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nestatusDocumento  :=  WSAdvValue( oResponse,"_ESTATUSDOCUMENTO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	oNode17 :=  WSAdvValue( oResponse,"_EVENTOS","ArrayOfEvento",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode17 != NIL
		::oWSeventos := Service_ArrayOfEvento():New()
		::oWSeventos:SoapRecv(oNode17)
	EndIf
	::cfechaAceptacionDIAN :=  WSAdvValue( oResponse,"_FECHAACEPTACIONDIAN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfechaDocumento    :=  WSAdvValue( oResponse,"_FECHADOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode20 :=  WSAdvValue( oResponse,"_HISTORIALDEENTREGAS","ArrayOfHistorialDeEntrega",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode20 != NIL
		::oWShistorialDeEntregas := Service_ArrayOfHistorialDeEntrega():New()
		::oWShistorialDeEntregas:SoapRecv(oNode20)
	EndIf
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensajeDocumento  :=  WSAdvValue( oResponse,"_MENSAJEDOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lposeeAdjuntos     :=  WSAdvValue( oResponse,"_POSEEADJUNTOS","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::lposeeRepresentacionGrafica :=  WSAdvValue( oResponse,"_POSEEREPRESENTACIONGRAFICA","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	oNode25 :=  WSAdvValue( oResponse,"_REGLASVALIDACIONDIAN","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode25 != NIL
		::oWSreglasValidacionDIAN := Service_ArrayOfstring():New()
		::oWSreglasValidacionDIAN:SoapRecv(oNode25)
	EndIf
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoCufe          :=  WSAdvValue( oResponse,"_TIPOCUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoDocumento     :=  WSAdvValue( oResponse,"_TIPODOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctrackID           :=  WSAdvValue( oResponse,"_TRACKID","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure SendEmailResponse

WSSTRUCT Service_SendEmailResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_SendEmailResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_SendEmailResponse
Return

WSMETHOD CLONE WSCLIENT Service_SendEmailResponse
	Local oClone := Service_SendEmailResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_SendEmailResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DownloadPDFResponse

WSSTRUCT Service_DownloadPDFResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   ccufe                     AS string OPTIONAL
	WSDATA   cdocumento                AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctipoCufe                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DownloadPDFResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DownloadPDFResponse
Return

WSMETHOD CLONE WSCLIENT Service_DownloadPDFResponse
	Local oClone := Service_DownloadPDFResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:ccufe                := ::ccufe
	oClone:cdocumento           := ::cdocumento
	oClone:chash                := ::chash
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
	oClone:ctipoCufe            := ::ctipoCufe
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_DownloadPDFResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::ccufe              :=  WSAdvValue( oResponse,"_CUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoCufe          :=  WSAdvValue( oResponse,"_TIPOCUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DownloadXMLResponse

WSSTRUCT Service_DownloadXMLResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   ccufe                     AS string OPTIONAL
	WSDATA   cdocumento                AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cnombre                   AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctipoCufe                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DownloadXMLResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DownloadXMLResponse
Return

WSMETHOD CLONE WSCLIENT Service_DownloadXMLResponse
	Local oClone := Service_DownloadXMLResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:ccufe                := ::ccufe
	oClone:cdocumento           := ::cdocumento
	oClone:chash                := ::chash
	oClone:cmensaje             := ::cmensaje
	oClone:cnombre              := ::cnombre
	oClone:cresultado           := ::cresultado
	oClone:ctipoCufe            := ::ctipoCufe
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_DownloadXMLResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::ccufe              :=  WSAdvValue( oResponse,"_CUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnombre            :=  WSAdvValue( oResponse,"_NOMBRE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoCufe          :=  WSAdvValue( oResponse,"_TIPOCUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure FoliosRemainingResponse

WSSTRUCT Service_FoliosRemainingResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   nfoliosRestantes          AS int OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_FoliosRemainingResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_FoliosRemainingResponse
Return

WSMETHOD CLONE WSCLIENT Service_FoliosRemainingResponse
	Local oClone := Service_FoliosRemainingResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:nfoliosRestantes     := ::nfoliosRestantes
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_FoliosRemainingResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nfoliosRestantes   :=  WSAdvValue( oResponse,"_FOLIOSRESTANTES","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure LoadCertificateResponse

WSSTRUCT Service_LoadCertificateResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_LoadCertificateResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_LoadCertificateResponse
Return

WSMETHOD CLONE WSCLIENT Service_LoadCertificateResponse
	Local oClone := Service_LoadCertificateResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_LoadCertificateResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DatosEvento

WSSTRUCT Service_DatosEvento
	WSDATA   ccodigoEvento             AS string OPTIONAL
	WSDATA   ccodigoInterno1           AS string OPTIONAL
	WSDATA   ccodigoInterno2           AS string OPTIONAL
	WSDATA   ccomentario               AS string OPTIONAL
	WSDATA   cdocumento                AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfDatosExtras OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DatosEvento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DatosEvento
Return

WSMETHOD CLONE WSCLIENT Service_DatosEvento
	Local oClone := Service_DatosEvento():NEW()
	oClone:ccodigoEvento        := ::ccodigoEvento
	oClone:ccodigoInterno1      := ::ccodigoInterno1
	oClone:ccodigoInterno2      := ::ccodigoInterno2
	oClone:ccomentario          := ::ccomentario
	oClone:cdocumento           := ::cdocumento
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_DatosEvento
	Local cSoap := ""
	cSoap += WSSoapValue("codigoEvento", ::ccodigoEvento, ::ccodigoEvento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoInterno1", ::ccodigoInterno1, ::ccodigoInterno1 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoInterno2", ::ccodigoInterno2, ::ccodigoInterno2 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("comentario", ::ccomentario, ::ccomentario , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("documento", ::cdocumento, ::cdocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfDatosExtras", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure EventoResponse

WSSTRUCT Service_EventoResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cconsecutivoDocumentoEvento AS string OPTIONAL
	WSDATA   ccufe                     AS string OPTIONAL
	WSDATA   cfechaRespuesta           AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctipoCufe                 AS string OPTIONAL
	WSDATA   cxml                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_EventoResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_EventoResponse
Return

WSMETHOD CLONE WSCLIENT Service_EventoResponse
	Local oClone := Service_EventoResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cconsecutivoDocumentoEvento := ::cconsecutivoDocumentoEvento
	oClone:ccufe                := ::ccufe
	oClone:cfechaRespuesta      := ::cfechaRespuesta
	oClone:chash                := ::chash
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
	oClone:ctipoCufe            := ::ctipoCufe
	oClone:cxml                 := ::cxml
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_EventoResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cconsecutivoDocumentoEvento :=  WSAdvValue( oResponse,"_CONSECUTIVODOCUMENTOEVENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccufe              :=  WSAdvValue( oResponse,"_CUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfechaRespuesta    :=  WSAdvValue( oResponse,"_FECHARESPUESTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoCufe          :=  WSAdvValue( oResponse,"_TIPOCUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cxml               :=  WSAdvValue( oResponse,"_XML","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DescargarEventoResponse

WSSTRUCT Service_DescargarEventoResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   ccufe                     AS string OPTIONAL
	WSDATA   cdocumento                AS string OPTIONAL
	WSDATA   cfechaRespuesta           AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctipoCufe                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DescargarEventoResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DescargarEventoResponse
Return

WSMETHOD CLONE WSCLIENT Service_DescargarEventoResponse
	Local oClone := Service_DescargarEventoResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:ccufe                := ::ccufe
	oClone:cdocumento           := ::cdocumento
	oClone:cfechaRespuesta      := ::cfechaRespuesta
	oClone:chash                := ::chash
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
	oClone:ctipoCufe            := ::ctipoCufe
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_DescargarEventoResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::ccufe              :=  WSAdvValue( oResponse,"_CUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfechaRespuesta    :=  WSAdvValue( oResponse,"_FECHARESPUESTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoCufe          :=  WSAdvValue( oResponse,"_TIPOCUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ContenedorResponse

WSSTRUCT Service_ContenedorResponse
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   ccontenedorXml            AS string OPTIONAL
	WSDATA   cfecha                    AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ContenedorResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ContenedorResponse
Return

WSMETHOD CLONE WSCLIENT Service_ContenedorResponse
	Local oClone := Service_ContenedorResponse():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:ccontenedorXml       := ::ccontenedorXml
	oClone:cfecha               := ::cfecha
	oClone:chash                := ::chash
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ContenedorResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::ccontenedorXml     :=  WSAdvValue( oResponse,"_CONTENEDORXML","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfecha             :=  WSAdvValue( oResponse,"_FECHA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfAnticipos

WSSTRUCT Service_ArrayOfAnticipos
	WSDATA   oWSAnticipos              AS Service_Anticipos OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfAnticipos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfAnticipos
	::oWSAnticipos         := {} // Array Of  Service_ANTICIPOS():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfAnticipos
	Local oClone := Service_ArrayOfAnticipos():NEW()
	oClone:oWSAnticipos := NIL
	If ::oWSAnticipos <> NIL 
		oClone:oWSAnticipos := {}
		aEval( ::oWSAnticipos , { |x| aadd( oClone:oWSAnticipos , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfAnticipos
	Local cSoap := ""
	aEval( ::oWSAnticipos , {|x| cSoap := cSoap  +  WSSoapValue("Anticipos", x , x , "Anticipos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Autorizado

WSSTRUCT Service_Autorizado
	WSDATA   oWSdireccion              AS Service_Direccion OPTIONAL
	WSDATA   cemail                    AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cnombreComercial          AS string OPTIONAL
	WSDATA   cnombreContacto           AS string OPTIONAL
	WSDATA   cnota                     AS string OPTIONAL
	WSDATA   cnumeroDocumento          AS string OPTIONAL
	WSDATA   cnumeroDocumentoDV        AS string OPTIONAL
	WSDATA   crazonSocial              AS string OPTIONAL
	WSDATA   ctelefax                  AS string OPTIONAL
	WSDATA   ctelefono                 AS string OPTIONAL
	WSDATA   ctipoIdentificacion       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Autorizado
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Autorizado
Return

WSMETHOD CLONE WSCLIENT Service_Autorizado
	Local oClone := Service_Autorizado():NEW()
	oClone:oWSdireccion         := IIF(::oWSdireccion = NIL , NIL , ::oWSdireccion:Clone() )
	oClone:cemail               := ::cemail
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cnombreComercial     := ::cnombreComercial
	oClone:cnombreContacto      := ::cnombreContacto
	oClone:cnota                := ::cnota
	oClone:cnumeroDocumento     := ::cnumeroDocumento
	oClone:cnumeroDocumentoDV   := ::cnumeroDocumentoDV
	oClone:crazonSocial         := ::crazonSocial
	oClone:ctelefax             := ::ctelefax
	oClone:ctelefono            := ::ctelefono
	oClone:ctipoIdentificacion  := ::ctipoIdentificacion
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Autorizado
	Local cSoap := ""
	cSoap += WSSoapValue("direccion", ::oWSdireccion, ::oWSdireccion , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreComercial", ::cnombreComercial, ::cnombreComercial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreContacto", ::cnombreContacto, ::cnombreContacto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nota", ::cnota, ::cnota , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroDocumento", ::cnumeroDocumento, ::cnumeroDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroDocumentoDV", ::cnumeroDocumentoDV, ::cnumeroDocumentoDV , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("razonSocial", ::crazonSocial, ::crazonSocial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("telefax", ::ctelefax, ::ctelefax , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("telefono", ::ctelefono, ::ctelefono , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoIdentificacion", ::ctipoIdentificacion, ::ctipoIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfCargosDescuentos

WSSTRUCT Service_ArrayOfCargosDescuentos
	WSDATA   oWSCargosDescuentos       AS Service_CargosDescuentos OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfCargosDescuentos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfCargosDescuentos
	::oWSCargosDescuentos  := {} // Array Of  Service_CARGOSDESCUENTOS():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfCargosDescuentos
	Local oClone := Service_ArrayOfCargosDescuentos():NEW()
	oClone:oWSCargosDescuentos := NIL
	If ::oWSCargosDescuentos <> NIL 
		oClone:oWSCargosDescuentos := {}
		aEval( ::oWSCargosDescuentos , { |x| aadd( oClone:oWSCargosDescuentos , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfCargosDescuentos
	Local cSoap := ""
	aEval( ::oWSCargosDescuentos , {|x| cSoap := cSoap  +  WSSoapValue("CargosDescuentos", x , x , "CargosDescuentos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Cliente

WSSTRUCT Service_Cliente
	WSDATA   cactividadEconomicaCIIU   AS string OPTIONAL
	WSDATA   capellido                 AS string OPTIONAL
	WSDATA   oWSdestinatario           AS Service_ArrayOfDestinatario OPTIONAL
	WSDATA   oWSdetallesTributarios    AS Service_ArrayOfTributos OPTIONAL
	WSDATA   oWSdireccionCliente       AS Service_Direccion OPTIONAL
	WSDATA   oWSdireccionFiscal        AS Service_Direccion OPTIONAL
	WSDATA   cemail                    AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   oWSinformacionLegalCliente AS Service_InformacionLegal OPTIONAL
	WSDATA   cnombreComercial          AS string OPTIONAL
	WSDATA   cnombreContacto           AS string OPTIONAL
	WSDATA   cnombreRazonSocial        AS string OPTIONAL
	WSDATA   cnota                     AS string OPTIONAL
	WSDATA   cnotificar                AS string OPTIONAL
	WSDATA   cnumeroDocumento          AS string OPTIONAL
	WSDATA   cnumeroIdentificacionDV   AS string OPTIONAL
	WSDATA   oWSresponsabilidadesRut   AS Service_ArrayOfObligaciones OPTIONAL
	WSDATA   csegundoNombre            AS string OPTIONAL
	WSDATA   ctelefax                  AS string OPTIONAL
	WSDATA   ctelefono                 AS string OPTIONAL
	WSDATA   ctipoIdentificacion       AS string OPTIONAL
	WSDATA   ctipoPersona              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Cliente
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Cliente
Return

WSMETHOD CLONE WSCLIENT Service_Cliente
	Local oClone := Service_Cliente():NEW()
	oClone:cactividadEconomicaCIIU := ::cactividadEconomicaCIIU
	oClone:capellido            := ::capellido
	oClone:oWSdestinatario      := IIF(::oWSdestinatario = NIL , NIL , ::oWSdestinatario:Clone() )
	oClone:oWSdetallesTributarios := IIF(::oWSdetallesTributarios = NIL , NIL , ::oWSdetallesTributarios:Clone() )
	oClone:oWSdireccionCliente  := IIF(::oWSdireccionCliente = NIL , NIL , ::oWSdireccionCliente:Clone() )
	oClone:oWSdireccionFiscal   := IIF(::oWSdireccionFiscal = NIL , NIL , ::oWSdireccionFiscal:Clone() )
	oClone:cemail               := ::cemail
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:oWSinformacionLegalCliente := IIF(::oWSinformacionLegalCliente = NIL , NIL , ::oWSinformacionLegalCliente:Clone() )
	oClone:cnombreComercial     := ::cnombreComercial
	oClone:cnombreContacto      := ::cnombreContacto
	oClone:cnombreRazonSocial   := ::cnombreRazonSocial
	oClone:cnota                := ::cnota
	oClone:cnotificar           := ::cnotificar
	oClone:cnumeroDocumento     := ::cnumeroDocumento
	oClone:cnumeroIdentificacionDV := ::cnumeroIdentificacionDV
	oClone:oWSresponsabilidadesRut := IIF(::oWSresponsabilidadesRut = NIL , NIL , ::oWSresponsabilidadesRut:Clone() )
	oClone:csegundoNombre       := ::csegundoNombre
	oClone:ctelefax             := ::ctelefax
	oClone:ctelefono            := ::ctelefono
	oClone:ctipoIdentificacion  := ::ctipoIdentificacion
	oClone:ctipoPersona         := ::ctipoPersona
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Cliente
	Local cSoap := ""
	cSoap += WSSoapValue("actividadEconomicaCIIU", ::cactividadEconomicaCIIU, ::cactividadEconomicaCIIU , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("apellido", ::capellido, ::capellido , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("destinatario", ::oWSdestinatario, ::oWSdestinatario , "ArrayOfDestinatario", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("detallesTributarios", ::oWSdetallesTributarios, ::oWSdetallesTributarios , "ArrayOfTributos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("direccionCliente", ::oWSdireccionCliente, ::oWSdireccionCliente , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("direccionFiscal", ::oWSdireccionFiscal, ::oWSdireccionFiscal , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("informacionLegalCliente", ::oWSinformacionLegalCliente, ::oWSinformacionLegalCliente , "InformacionLegal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreComercial", ::cnombreComercial, ::cnombreComercial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreContacto", ::cnombreContacto, ::cnombreContacto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreRazonSocial", ::cnombreRazonSocial, ::cnombreRazonSocial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nota", ::cnota, ::cnota , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("notificar", ::cnotificar, ::cnotificar , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroDocumento", ::cnumeroDocumento, ::cnumeroDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroIdentificacionDV", ::cnumeroIdentificacionDV, ::cnumeroIdentificacionDV , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("responsabilidadesRut", ::oWSresponsabilidadesRut, ::oWSresponsabilidadesRut , "ArrayOfObligaciones", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("segundoNombre", ::csegundoNombre, ::csegundoNombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("telefax", ::ctelefax, ::ctelefax , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("telefono", ::ctelefono, ::ctelefono , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoIdentificacion", ::ctipoIdentificacion, ::ctipoIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoPersona", ::ctipoPersona, ::ctipoPersona , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfCondicionDePago

WSSTRUCT Service_ArrayOfCondicionDePago
	WSDATA   oWSCondicionDePago        AS Service_CondicionDePago OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfCondicionDePago
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfCondicionDePago
	::oWSCondicionDePago   := {} // Array Of  Service_CONDICIONDEPAGO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfCondicionDePago
	Local oClone := Service_ArrayOfCondicionDePago():NEW()
	oClone:oWSCondicionDePago := NIL
	If ::oWSCondicionDePago <> NIL 
		oClone:oWSCondicionDePago := {}
		aEval( ::oWSCondicionDePago , { |x| aadd( oClone:oWSCondicionDePago , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfCondicionDePago
	Local cSoap := ""
	aEval( ::oWSCondicionDePago , {|x| cSoap := cSoap  +  WSSoapValue("CondicionDePago", x , x , "CondicionDePago", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfFacturaDetalle

WSSTRUCT Service_ArrayOfFacturaDetalle
	WSDATA   oWSFacturaDetalle         AS Service_FacturaDetalle OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfFacturaDetalle
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfFacturaDetalle
	::oWSFacturaDetalle    := {} // Array Of  Service_FACTURADETALLE():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfFacturaDetalle
	Local oClone := Service_ArrayOfFacturaDetalle():NEW()
	oClone:oWSFacturaDetalle := NIL
	If ::oWSFacturaDetalle <> NIL 
		oClone:oWSFacturaDetalle := {}
		aEval( ::oWSFacturaDetalle , { |x| aadd( oClone:oWSFacturaDetalle , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfFacturaDetalle
	Local cSoap := ""
	aEval( ::oWSFacturaDetalle , {|x| cSoap := cSoap  +  WSSoapValue("FacturaDetalle", x , x , "FacturaDetalle", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfDocumentoReferenciado

WSSTRUCT Service_ArrayOfDocumentoReferenciado
	WSDATA   oWSDocumentoReferenciado  AS Service_DocumentoReferenciado OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfDocumentoReferenciado
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfDocumentoReferenciado
	::oWSDocumentoReferenciado := {} // Array Of  Service_DOCUMENTOREFERENCIADO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfDocumentoReferenciado
	Local oClone := Service_ArrayOfDocumentoReferenciado():NEW()
	oClone:oWSDocumentoReferenciado := NIL
	If ::oWSDocumentoReferenciado <> NIL 
		oClone:oWSDocumentoReferenciado := {}
		aEval( ::oWSDocumentoReferenciado , { |x| aadd( oClone:oWSDocumentoReferenciado , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfDocumentoReferenciado
	Local cSoap := ""
	aEval( ::oWSDocumentoReferenciado , {|x| cSoap := cSoap  +  WSSoapValue("DocumentoReferenciado", x , x , "DocumentoReferenciado", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Entrega

WSSTRUCT Service_Entrega
	WSDATA   oWSdatosTransportistas    AS Service_DatosDelTransportista OPTIONAL
	WSDATA   oWSdireccionDespacho      AS Service_Direccion OPTIONAL
	WSDATA   oWSdireccionEntrega       AS Service_Direccion OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfechaEfectivaSalida      AS string OPTIONAL
	WSDATA   cfechaEstimada            AS string OPTIONAL
	WSDATA   cfechaReal                AS string OPTIONAL
	WSDATA   cfechaSolicitada          AS string OPTIONAL
	WSDATA   cidentificacionTransporte AS string OPTIONAL
	WSDATA   cmatriculaTransporte      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Entrega
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Entrega
Return

WSMETHOD CLONE WSCLIENT Service_Entrega
	Local oClone := Service_Entrega():NEW()
	oClone:oWSdatosTransportistas := IIF(::oWSdatosTransportistas = NIL , NIL , ::oWSdatosTransportistas:Clone() )
	oClone:oWSdireccionDespacho := IIF(::oWSdireccionDespacho = NIL , NIL , ::oWSdireccionDespacho:Clone() )
	oClone:oWSdireccionEntrega  := IIF(::oWSdireccionEntrega = NIL , NIL , ::oWSdireccionEntrega:Clone() )
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaEfectivaSalida := ::cfechaEfectivaSalida
	oClone:cfechaEstimada       := ::cfechaEstimada
	oClone:cfechaReal           := ::cfechaReal
	oClone:cfechaSolicitada     := ::cfechaSolicitada
	oClone:cidentificacionTransporte := ::cidentificacionTransporte
	oClone:cmatriculaTransporte := ::cmatriculaTransporte
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Entrega
	Local cSoap := ""
	cSoap += WSSoapValue("datosTransportistas", ::oWSdatosTransportistas, ::oWSdatosTransportistas , "DatosDelTransportista", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("direccionDespacho", ::oWSdireccionDespacho, ::oWSdireccionDespacho , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("direccionEntrega", ::oWSdireccionEntrega, ::oWSdireccionEntrega , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaEfectivaSalida", ::cfechaEfectivaSalida, ::cfechaEfectivaSalida , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaEstimada", ::cfechaEstimada, ::cfechaEstimada , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaReal", ::cfechaReal, ::cfechaReal , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaSolicitada", ::cfechaSolicitada, ::cfechaSolicitada , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("identificacionTransporte", ::cidentificacionTransporte, ::cidentificacionTransporte , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("matriculaTransporte", ::cmatriculaTransporte, ::cmatriculaTransporte , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfExtras

WSSTRUCT Service_ArrayOfExtras
	WSDATA   oWSExtras                 AS Service_Extras OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfExtras
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfExtras
	::oWSExtras            := {} // Array Of  Service_EXTRAS():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfExtras
	Local oClone := Service_ArrayOfExtras():NEW()
	oClone:oWSExtras := NIL
	If ::oWSExtras <> NIL 
		oClone:oWSExtras := {}
		aEval( ::oWSExtras , { |x| aadd( oClone:oWSExtras , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfExtras
	Local cSoap := ""
	aEval( ::oWSExtras , {|x| cSoap := cSoap  +  WSSoapValue("Extras", x , x , "Extras", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfFacturaImpuestos

WSSTRUCT Service_ArrayOfFacturaImpuestos
	WSDATA   oWSFacturaImpuestos       AS Service_FacturaImpuestos OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfFacturaImpuestos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfFacturaImpuestos
	::oWSFacturaImpuestos  := {} // Array Of  Service_FACTURAIMPUESTOS():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfFacturaImpuestos
	Local oClone := Service_ArrayOfFacturaImpuestos():NEW()
	oClone:oWSFacturaImpuestos := NIL
	If ::oWSFacturaImpuestos <> NIL 
		oClone:oWSFacturaImpuestos := {}
		aEval( ::oWSFacturaImpuestos , { |x| aadd( oClone:oWSFacturaImpuestos , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfFacturaImpuestos
	Local cSoap := ""
	aEval( ::oWSFacturaImpuestos , {|x| cSoap := cSoap  +  WSSoapValue("FacturaImpuestos", x , x , "FacturaImpuestos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfImpuestosTotales

WSSTRUCT Service_ArrayOfImpuestosTotales
	WSDATA   oWSImpuestosTotales       AS Service_ImpuestosTotales OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfImpuestosTotales
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfImpuestosTotales
	::oWSImpuestosTotales  := {} // Array Of  Service_IMPUESTOSTOTALES():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfImpuestosTotales
	Local oClone := Service_ArrayOfImpuestosTotales():NEW()
	oClone:oWSImpuestosTotales := NIL
	If ::oWSImpuestosTotales <> NIL 
		oClone:oWSImpuestosTotales := {}
		aEval( ::oWSImpuestosTotales , { |x| aadd( oClone:oWSImpuestosTotales , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfImpuestosTotales
	Local cSoap := ""
	aEval( ::oWSImpuestosTotales , {|x| cSoap := cSoap  +  WSSoapValue("ImpuestosTotales", x , x , "ImpuestosTotales", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfstring

WSSTRUCT Service_ArrayOfstring
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfstring
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfstring
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfstring
	Local oClone := Service_ArrayOfstring():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfstring
	Local cSoap := ""
	aEval( ::cstring , {|x| cSoap := cSoap  +  WSSoapValue("string", x , x , "string", .F. , .F., 0 , "http://schemas.microsoft.com/2003/10/Serialization/Arrays", .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfstring
	Local oNodes1 :=  WSAdvValue( oResponse,"_B_STRING","string",{},NIL,.T.,"S",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::cstring ,  x:TEXT  ) } )
Return

// WSDL Data Structure ArrayOfMediosDePago

WSSTRUCT Service_ArrayOfMediosDePago
	WSDATA   oWSMediosDePago           AS Service_MediosDePago OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfMediosDePago
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfMediosDePago
	::oWSMediosDePago      := {} // Array Of  Service_MEDIOSDEPAGO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfMediosDePago
	Local oClone := Service_ArrayOfMediosDePago():NEW()
	oClone:oWSMediosDePago := NIL
	If ::oWSMediosDePago <> NIL 
		oClone:oWSMediosDePago := {}
		aEval( ::oWSMediosDePago , { |x| aadd( oClone:oWSMediosDePago , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfMediosDePago
	Local cSoap := ""
	aEval( ::oWSMediosDePago , {|x| cSoap := cSoap  +  WSSoapValue("MediosDePago", x , x , "MediosDePago", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfOrdenDeCompra

WSSTRUCT Service_ArrayOfOrdenDeCompra
	WSDATA   oWSOrdenDeCompra          AS Service_OrdenDeCompra OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfOrdenDeCompra
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfOrdenDeCompra
	::oWSOrdenDeCompra     := {} // Array Of  Service_ORDENDECOMPRA():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfOrdenDeCompra
	Local oClone := Service_ArrayOfOrdenDeCompra():NEW()
	oClone:oWSOrdenDeCompra := NIL
	If ::oWSOrdenDeCompra <> NIL 
		oClone:oWSOrdenDeCompra := {}
		aEval( ::oWSOrdenDeCompra , { |x| aadd( oClone:oWSOrdenDeCompra , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfOrdenDeCompra
	Local cSoap := ""
	aEval( ::oWSOrdenDeCompra , {|x| cSoap := cSoap  +  WSSoapValue("OrdenDeCompra", x , x , "OrdenDeCompra", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure SectorSalud

WSSTRUCT Service_SectorSalud
	WSDATA   oWSBeneficiario           AS Service_BeneficiarioSalud OPTIONAL
	WSDATA   cIdPersonalizacion        AS string OPTIONAL
	WSDATA   oWSPacientes              AS Service_ArrayOfDatosPacienteSalud OPTIONAL
	WSDATA   cTipoEscenario            AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtras OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_SectorSalud
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_SectorSalud
Return

WSMETHOD CLONE WSCLIENT Service_SectorSalud
	Local oClone := Service_SectorSalud():NEW()
	oClone:oWSBeneficiario      := IIF(::oWSBeneficiario = NIL , NIL , ::oWSBeneficiario:Clone() )
	oClone:cIdPersonalizacion   := ::cIdPersonalizacion
	oClone:oWSPacientes         := IIF(::oWSPacientes = NIL , NIL , ::oWSPacientes:Clone() )
	oClone:cTipoEscenario       := ::cTipoEscenario
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_SectorSalud
	Local cSoap := ""
	cSoap += WSSoapValue("Beneficiario", ::oWSBeneficiario, ::oWSBeneficiario , "BeneficiarioSalud", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("IdPersonalizacion", ::cIdPersonalizacion, ::cIdPersonalizacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("Pacientes", ::oWSPacientes, ::oWSPacientes , "ArrayOfDatosPacienteSalud", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("TipoEscenario", ::cTipoEscenario, ::cTipoEscenario , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtras", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure TasaDeCambio

WSSTRUCT Service_TasaDeCambio
	WSDATA   cbaseMonedaDestino        AS string OPTIONAL
	WSDATA   cbaseMonedaOrigen         AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfechaDeTasaDeCambio      AS string OPTIONAL
	WSDATA   cindicadorDeTasa          AS string OPTIONAL
	WSDATA   cmonedaDestino            AS string OPTIONAL
	WSDATA   cmonedaOrigen             AS string OPTIONAL
	WSDATA   coperadorCalculo          AS string OPTIONAL
	WSDATA   ctasaDeCambio             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_TasaDeCambio
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_TasaDeCambio
Return

WSMETHOD CLONE WSCLIENT Service_TasaDeCambio
	Local oClone := Service_TasaDeCambio():NEW()
	oClone:cbaseMonedaDestino   := ::cbaseMonedaDestino
	oClone:cbaseMonedaOrigen    := ::cbaseMonedaOrigen
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaDeTasaDeCambio := ::cfechaDeTasaDeCambio
	oClone:cindicadorDeTasa     := ::cindicadorDeTasa
	oClone:cmonedaDestino       := ::cmonedaDestino
	oClone:cmonedaOrigen        := ::cmonedaOrigen
	oClone:coperadorCalculo     := ::coperadorCalculo
	oClone:ctasaDeCambio        := ::ctasaDeCambio
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_TasaDeCambio
	Local cSoap := ""
	cSoap += WSSoapValue("baseMonedaDestino", ::cbaseMonedaDestino, ::cbaseMonedaDestino , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("baseMonedaOrigen", ::cbaseMonedaOrigen, ::cbaseMonedaOrigen , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaDeTasaDeCambio", ::cfechaDeTasaDeCambio, ::cfechaDeTasaDeCambio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("indicadorDeTasa", ::cindicadorDeTasa, ::cindicadorDeTasa , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("monedaDestino", ::cmonedaDestino, ::cmonedaDestino , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("monedaOrigen", ::cmonedaOrigen, ::cmonedaOrigen , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("operadorCalculo", ::coperadorCalculo, ::coperadorCalculo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tasaDeCambio", ::ctasaDeCambio, ::ctasaDeCambio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure TasaDeCambioAlternativa

WSSTRUCT Service_TasaDeCambioAlternativa
	WSDATA   cbaseMonedaDestino        AS string OPTIONAL
	WSDATA   cbaseMonedaOrigen         AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfechaDeTasaDeCambio      AS string OPTIONAL
	WSDATA   cindicadorDeTasa          AS string OPTIONAL
	WSDATA   cmonedaDestino            AS string OPTIONAL
	WSDATA   cmonedaOrigen             AS string OPTIONAL
	WSDATA   coperadorCalculo          AS string OPTIONAL
	WSDATA   ctasaDeCambio             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_TasaDeCambioAlternativa
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_TasaDeCambioAlternativa
Return

WSMETHOD CLONE WSCLIENT Service_TasaDeCambioAlternativa
	Local oClone := Service_TasaDeCambioAlternativa():NEW()
	oClone:cbaseMonedaDestino   := ::cbaseMonedaDestino
	oClone:cbaseMonedaOrigen    := ::cbaseMonedaOrigen
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaDeTasaDeCambio := ::cfechaDeTasaDeCambio
	oClone:cindicadorDeTasa     := ::cindicadorDeTasa
	oClone:cmonedaDestino       := ::cmonedaDestino
	oClone:cmonedaOrigen        := ::cmonedaOrigen
	oClone:coperadorCalculo     := ::coperadorCalculo
	oClone:ctasaDeCambio        := ::ctasaDeCambio
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_TasaDeCambioAlternativa
	Local cSoap := ""
	cSoap += WSSoapValue("baseMonedaDestino", ::cbaseMonedaDestino, ::cbaseMonedaDestino , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("baseMonedaOrigen", ::cbaseMonedaOrigen, ::cbaseMonedaOrigen , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaDeTasaDeCambio", ::cfechaDeTasaDeCambio, ::cfechaDeTasaDeCambio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("indicadorDeTasa", ::cindicadorDeTasa, ::cindicadorDeTasa , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("monedaDestino", ::cmonedaDestino, ::cmonedaDestino , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("monedaOrigen", ::cmonedaOrigen, ::cmonedaOrigen , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("operadorCalculo", ::coperadorCalculo, ::coperadorCalculo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tasaDeCambio", ::ctasaDeCambio, ::ctasaDeCambio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure TerminosDeEntrega

WSSTRUCT Service_TerminosDeEntrega
	WSDATA   oWScargosDescuentos       AS Service_ArrayOfCargosDescuentos OPTIONAL
	WSDATA   ccodigoCondicionEntrega   AS string OPTIONAL
	WSDATA   ccostoTransporte          AS string OPTIONAL
	WSDATA   oWSdireccionEntrega       AS Service_Direccion OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cidentificacion           AS string OPTIONAL
	WSDATA   cmonto                    AS string OPTIONAL
	WSDATA   cresponsableEntrega       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_TerminosDeEntrega
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_TerminosDeEntrega
Return

WSMETHOD CLONE WSCLIENT Service_TerminosDeEntrega
	Local oClone := Service_TerminosDeEntrega():NEW()
	oClone:oWScargosDescuentos  := IIF(::oWScargosDescuentos = NIL , NIL , ::oWScargosDescuentos:Clone() )
	oClone:ccodigoCondicionEntrega := ::ccodigoCondicionEntrega
	oClone:ccostoTransporte     := ::ccostoTransporte
	oClone:oWSdireccionEntrega  := IIF(::oWSdireccionEntrega = NIL , NIL , ::oWSdireccionEntrega:Clone() )
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cidentificacion      := ::cidentificacion
	oClone:cmonto               := ::cmonto
	oClone:cresponsableEntrega  := ::cresponsableEntrega
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_TerminosDeEntrega
	Local cSoap := ""
	cSoap += WSSoapValue("cargosDescuentos", ::oWScargosDescuentos, ::oWScargosDescuentos , "ArrayOfCargosDescuentos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoCondicionEntrega", ::ccodigoCondicionEntrega, ::ccodigoCondicionEntrega , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("costoTransporte", ::ccostoTransporte, ::ccostoTransporte , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("direccionEntrega", ::oWSdireccionEntrega, ::oWSdireccionEntrega , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("identificacion", ::cidentificacion, ::cidentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("monto", ::cmonto, ::cmonto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("responsableEntrega", ::cresponsableEntrega, ::cresponsableEntrega , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfEvento

WSSTRUCT Service_ArrayOfEvento
	WSDATA   oWSEvento                 AS Service_Evento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfEvento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfEvento
	::oWSEvento            := {} // Array Of  Service_EVENTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfEvento
	Local oClone := Service_ArrayOfEvento():NEW()
	oClone:oWSEvento := NIL
	If ::oWSEvento <> NIL 
		oClone:oWSEvento := {}
		aEval( ::oWSEvento , { |x| aadd( oClone:oWSEvento , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfEvento
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EVENTO","Evento",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEvento , Service_Evento():New() )
			::oWSEvento[len(::oWSEvento)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfHistorialDeEntrega

WSSTRUCT Service_ArrayOfHistorialDeEntrega
	WSDATA   oWSHistorialDeEntrega     AS Service_HistorialDeEntrega OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfHistorialDeEntrega
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfHistorialDeEntrega
	::oWSHistorialDeEntrega := {} // Array Of  Service_HISTORIALDEENTREGA():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfHistorialDeEntrega
	Local oClone := Service_ArrayOfHistorialDeEntrega():NEW()
	oClone:oWSHistorialDeEntrega := NIL
	If ::oWSHistorialDeEntrega <> NIL 
		oClone:oWSHistorialDeEntrega := {}
		aEval( ::oWSHistorialDeEntrega , { |x| aadd( oClone:oWSHistorialDeEntrega , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfHistorialDeEntrega
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_HISTORIALDEENTREGA","HistorialDeEntrega",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSHistorialDeEntrega , Service_HistorialDeEntrega():New() )
			::oWSHistorialDeEntrega[len(::oWSHistorialDeEntrega)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfDatosExtras

WSSTRUCT Service_ArrayOfDatosExtras
	WSDATA   oWSDatosExtras            AS Service_DatosExtras OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfDatosExtras
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfDatosExtras
	::oWSDatosExtras       := {} // Array Of  Service_DATOSEXTRAS():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfDatosExtras
	Local oClone := Service_ArrayOfDatosExtras():NEW()
	oClone:oWSDatosExtras := NIL
	If ::oWSDatosExtras <> NIL 
		oClone:oWSDatosExtras := {}
		aEval( ::oWSDatosExtras , { |x| aadd( oClone:oWSDatosExtras , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfDatosExtras
	Local cSoap := ""
	aEval( ::oWSDatosExtras , {|x| cSoap := cSoap  +  WSSoapValue("DatosExtras", x , x , "DatosExtras", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Anticipos

WSSTRUCT Service_Anticipos
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfechaDeRecibido          AS string OPTIONAL
	WSDATA   cfechadePago              AS string OPTIONAL
	WSDATA   choraDePago               AS string OPTIONAL
	WSDATA   cid                       AS string OPTIONAL
	WSDATA   cinstrucciones            AS string OPTIONAL
	WSDATA   cmontoPagado              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Anticipos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Anticipos
Return

WSMETHOD CLONE WSCLIENT Service_Anticipos
	Local oClone := Service_Anticipos():NEW()
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaDeRecibido     := ::cfechaDeRecibido
	oClone:cfechadePago         := ::cfechadePago
	oClone:choraDePago          := ::choraDePago
	oClone:cid                  := ::cid
	oClone:cinstrucciones       := ::cinstrucciones
	oClone:cmontoPagado         := ::cmontoPagado
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Anticipos
	Local cSoap := ""
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaDeRecibido", ::cfechaDeRecibido, ::cfechaDeRecibido , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechadePago", ::cfechadePago, ::cfechadePago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("horaDePago", ::choraDePago, ::choraDePago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("id", ::cid, ::cid , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("instrucciones", ::cinstrucciones, ::cinstrucciones , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("montoPagado", ::cmontoPagado, ::cmontoPagado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure Direccion

WSSTRUCT Service_Direccion
	WSDATA   caCuidadoDe               AS string OPTIONAL
	WSDATA   caLaAtencionDe            AS string OPTIONAL
	WSDATA   cbloque                   AS string OPTIONAL
	WSDATA   cbuzon                    AS string OPTIONAL
	WSDATA   ccalle                    AS string OPTIONAL
	WSDATA   ccalleAdicional           AS string OPTIONAL
	WSDATA   cciudad                   AS string OPTIONAL
	WSDATA   ccodigoDepartamento       AS string OPTIONAL
	WSDATA   ccorreccionHusoHorario    AS string OPTIONAL
	WSDATA   cdepartamento             AS string OPTIONAL
	WSDATA   cdepartamentoOrg          AS string OPTIONAL
	WSDATA   cdireccion                AS string OPTIONAL
	WSDATA   cdistrito                 AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   chabitacion               AS string OPTIONAL
	WSDATA   clenguaje                 AS string OPTIONAL
	WSDATA   oWSlocalizacion           AS Service_ArrayOfCoordenadas OPTIONAL
	WSDATA   cmunicipio                AS string OPTIONAL
	WSDATA   cnombreEdificio           AS string OPTIONAL
	WSDATA   cnumeroEdificio           AS string OPTIONAL
	WSDATA   cnumeroParcela            AS string OPTIONAL
	WSDATA   cpais                     AS string OPTIONAL
	WSDATA   cpiso                     AS string OPTIONAL
	WSDATA   cregion                   AS string OPTIONAL
	WSDATA   csubDivision              AS string OPTIONAL
	WSDATA   cubicacion                AS string OPTIONAL
	WSDATA   czonaPostal               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Direccion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Direccion
Return

WSMETHOD CLONE WSCLIENT Service_Direccion
	Local oClone := Service_Direccion():NEW()
	oClone:caCuidadoDe          := ::caCuidadoDe
	oClone:caLaAtencionDe       := ::caLaAtencionDe
	oClone:cbloque              := ::cbloque
	oClone:cbuzon               := ::cbuzon
	oClone:ccalle               := ::ccalle
	oClone:ccalleAdicional      := ::ccalleAdicional
	oClone:cciudad              := ::cciudad
	oClone:ccodigoDepartamento  := ::ccodigoDepartamento
	oClone:ccorreccionHusoHorario := ::ccorreccionHusoHorario
	oClone:cdepartamento        := ::cdepartamento
	oClone:cdepartamentoOrg     := ::cdepartamentoOrg
	oClone:cdireccion           := ::cdireccion
	oClone:cdistrito            := ::cdistrito
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:chabitacion          := ::chabitacion
	oClone:clenguaje            := ::clenguaje
	oClone:oWSlocalizacion      := IIF(::oWSlocalizacion = NIL , NIL , ::oWSlocalizacion:Clone() )
	oClone:cmunicipio           := ::cmunicipio
	oClone:cnombreEdificio      := ::cnombreEdificio
	oClone:cnumeroEdificio      := ::cnumeroEdificio
	oClone:cnumeroParcela       := ::cnumeroParcela
	oClone:cpais                := ::cpais
	oClone:cpiso                := ::cpiso
	oClone:cregion              := ::cregion
	oClone:csubDivision         := ::csubDivision
	oClone:cubicacion           := ::cubicacion
	oClone:czonaPostal          := ::czonaPostal
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Direccion
	Local cSoap := ""
	cSoap += WSSoapValue("aCuidadoDe", ::caCuidadoDe, ::caCuidadoDe , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("aLaAtencionDe", ::caLaAtencionDe, ::caLaAtencionDe , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("bloque", ::cbloque, ::cbloque , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("buzon", ::cbuzon, ::cbuzon , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("calle", ::ccalle, ::ccalle , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("calleAdicional", ::ccalleAdicional, ::ccalleAdicional , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("ciudad", ::cciudad, ::cciudad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoDepartamento", ::ccodigoDepartamento, ::ccodigoDepartamento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("correccionHusoHorario", ::ccorreccionHusoHorario, ::ccorreccionHusoHorario , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("departamento", ::cdepartamento, ::cdepartamento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("departamentoOrg", ::cdepartamentoOrg, ::cdepartamentoOrg , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("direccion", ::cdireccion, ::cdireccion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("distrito", ::cdistrito, ::cdistrito , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("habitacion", ::chabitacion, ::chabitacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("lenguaje", ::clenguaje, ::clenguaje , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("localizacion", ::oWSlocalizacion, ::oWSlocalizacion , "ArrayOfCoordenadas", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("municipio", ::cmunicipio, ::cmunicipio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreEdificio", ::cnombreEdificio, ::cnombreEdificio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroEdificio", ::cnumeroEdificio, ::cnumeroEdificio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroParcela", ::cnumeroParcela, ::cnumeroParcela , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("pais", ::cpais, ::cpais , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("piso", ::cpiso, ::cpiso , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("region", ::cregion, ::cregion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("subDivision", ::csubDivision, ::csubDivision , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("ubicacion", ::cubicacion, ::cubicacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("zonaPostal", ::czonaPostal, ::czonaPostal , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfExtensible

WSSTRUCT Service_ArrayOfExtensible
	WSDATA   oWSExtensible             AS Service_Extensible OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfExtensible
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfExtensible
	::oWSExtensible        := {} // Array Of  Service_EXTENSIBLE():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfExtensible
	Local oClone := Service_ArrayOfExtensible():NEW()
	oClone:oWSExtensible := NIL
	If ::oWSExtensible <> NIL 
		oClone:oWSExtensible := {}
		aEval( ::oWSExtensible , { |x| aadd( oClone:oWSExtensible , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfExtensible
	Local cSoap := ""
	aEval( ::oWSExtensible , {|x| cSoap := cSoap  +  WSSoapValue("Extensible", x , x , "Extensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure CargosDescuentos

WSSTRUCT Service_CargosDescuentos
	WSDATA   ccodigo                   AS string OPTIONAL
	WSDATA   cdescripcion              AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cindicador                AS string OPTIONAL
	WSDATA   cmonto                    AS string OPTIONAL
	WSDATA   cmontoBase                AS string OPTIONAL
	WSDATA   cporcentaje               AS string OPTIONAL
	WSDATA   csecuencia                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_CargosDescuentos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_CargosDescuentos
Return

WSMETHOD CLONE WSCLIENT Service_CargosDescuentos
	Local oClone := Service_CargosDescuentos():NEW()
	oClone:ccodigo              := ::ccodigo
	oClone:cdescripcion         := ::cdescripcion
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cindicador           := ::cindicador
	oClone:cmonto               := ::cmonto
	oClone:cmontoBase           := ::cmontoBase
	oClone:cporcentaje          := ::cporcentaje
	oClone:csecuencia           := ::csecuencia
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_CargosDescuentos
	Local cSoap := ""
	cSoap += WSSoapValue("codigo", ::ccodigo, ::ccodigo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("descripcion", ::cdescripcion, ::cdescripcion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("indicador", ::cindicador, ::cindicador , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("monto", ::cmonto, ::cmonto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("montoBase", ::cmontoBase, ::cmontoBase , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("porcentaje", ::cporcentaje, ::cporcentaje , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("secuencia", ::csecuencia, ::csecuencia , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfDestinatario

WSSTRUCT Service_ArrayOfDestinatario
	WSDATA   oWSDestinatario           AS Service_Destinatario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfDestinatario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfDestinatario
	::oWSDestinatario      := {} // Array Of  Service_DESTINATARIO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfDestinatario
	Local oClone := Service_ArrayOfDestinatario():NEW()
	oClone:oWSDestinatario := NIL
	If ::oWSDestinatario <> NIL 
		oClone:oWSDestinatario := {}
		aEval( ::oWSDestinatario , { |x| aadd( oClone:oWSDestinatario , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfDestinatario
	Local cSoap := ""
	aEval( ::oWSDestinatario , {|x| cSoap := cSoap  +  WSSoapValue("Destinatario", x , x , "Destinatario", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfTributos

WSSTRUCT Service_ArrayOfTributos
	WSDATA   oWSTributos               AS Service_Tributos OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfTributos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfTributos
	::oWSTributos          := {} // Array Of  Service_TRIBUTOS():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfTributos
	Local oClone := Service_ArrayOfTributos():NEW()
	oClone:oWSTributos := NIL
	If ::oWSTributos <> NIL 
		oClone:oWSTributos := {}
		aEval( ::oWSTributos , { |x| aadd( oClone:oWSTributos , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfTributos
	Local cSoap := ""
	aEval( ::oWSTributos , {|x| cSoap := cSoap  +  WSSoapValue("Tributos", x , x , "Tributos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure InformacionLegal

WSSTRUCT Service_InformacionLegal
	WSDATA   ccodigoEstablecimiento    AS string OPTIONAL
	WSDATA   cnombreRegistroRUT        AS string OPTIONAL
	WSDATA   cnumeroIdentificacion     AS string OPTIONAL
	WSDATA   cnumeroIdentificacionDV   AS string OPTIONAL
	WSDATA   cnumeroMatriculaMercantil AS string OPTIONAL
	WSDATA   cprefijoFacturacion       AS string OPTIONAL
	WSDATA   ctipoIdentificacion       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_InformacionLegal
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_InformacionLegal
Return

WSMETHOD CLONE WSCLIENT Service_InformacionLegal
	Local oClone := Service_InformacionLegal():NEW()
	oClone:ccodigoEstablecimiento := ::ccodigoEstablecimiento
	oClone:cnombreRegistroRUT   := ::cnombreRegistroRUT
	oClone:cnumeroIdentificacion := ::cnumeroIdentificacion
	oClone:cnumeroIdentificacionDV := ::cnumeroIdentificacionDV
	oClone:cnumeroMatriculaMercantil := ::cnumeroMatriculaMercantil
	oClone:cprefijoFacturacion  := ::cprefijoFacturacion
	oClone:ctipoIdentificacion  := ::ctipoIdentificacion
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_InformacionLegal
	Local cSoap := ""
	cSoap += WSSoapValue("codigoEstablecimiento", ::ccodigoEstablecimiento, ::ccodigoEstablecimiento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreRegistroRUT", ::cnombreRegistroRUT, ::cnombreRegistroRUT , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroIdentificacion", ::cnumeroIdentificacion, ::cnumeroIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroIdentificacionDV", ::cnumeroIdentificacionDV, ::cnumeroIdentificacionDV , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroMatriculaMercantil", ::cnumeroMatriculaMercantil, ::cnumeroMatriculaMercantil , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("prefijoFacturacion", ::cprefijoFacturacion, ::cprefijoFacturacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoIdentificacion", ::ctipoIdentificacion, ::ctipoIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfObligaciones

WSSTRUCT Service_ArrayOfObligaciones
	WSDATA   oWSObligaciones           AS Service_Obligaciones OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfObligaciones
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfObligaciones
	::oWSObligaciones      := {} // Array Of  Service_OBLIGACIONES():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfObligaciones
	Local oClone := Service_ArrayOfObligaciones():NEW()
	oClone:oWSObligaciones := NIL
	If ::oWSObligaciones <> NIL 
		oClone:oWSObligaciones := {}
		aEval( ::oWSObligaciones , { |x| aadd( oClone:oWSObligaciones , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfObligaciones
	Local cSoap := ""
	aEval( ::oWSObligaciones , {|x| cSoap := cSoap  +  WSSoapValue("Obligaciones", x , x , "Obligaciones", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure CondicionDePago

WSSTRUCT Service_CondicionDePago
	WSDATA   ccodigoEvento             AS string OPTIONAL
	WSDATA   ccomentario               AS string OPTIONAL
	WSDATA   cduracionPeriodo          AS string OPTIONAL
	WSDATA   cduracionPeriodoMedida    AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfechaVencimiento         AS string OPTIONAL
	WSDATA   cidentificador            AS string OPTIONAL
	WSDATA   cmedioPagoAsociado        AS string OPTIONAL
	WSDATA   cmonto                    AS string OPTIONAL
	WSDATA   cmontoMulta               AS string OPTIONAL
	WSDATA   cmontoPenalidad           AS string OPTIONAL
	WSDATA   cperiodoDesde             AS string OPTIONAL
	WSDATA   cperiodoHasta             AS string OPTIONAL
	WSDATA   cporcentajeDescuento      AS string OPTIONAL
	WSDATA   cporcentajePago           AS string OPTIONAL
	WSDATA   creferenciaAnticipo       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_CondicionDePago
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_CondicionDePago
Return

WSMETHOD CLONE WSCLIENT Service_CondicionDePago
	Local oClone := Service_CondicionDePago():NEW()
	oClone:ccodigoEvento        := ::ccodigoEvento
	oClone:ccomentario          := ::ccomentario
	oClone:cduracionPeriodo     := ::cduracionPeriodo
	oClone:cduracionPeriodoMedida := ::cduracionPeriodoMedida
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaVencimiento    := ::cfechaVencimiento
	oClone:cidentificador       := ::cidentificador
	oClone:cmedioPagoAsociado   := ::cmedioPagoAsociado
	oClone:cmonto               := ::cmonto
	oClone:cmontoMulta          := ::cmontoMulta
	oClone:cmontoPenalidad      := ::cmontoPenalidad
	oClone:cperiodoDesde        := ::cperiodoDesde
	oClone:cperiodoHasta        := ::cperiodoHasta
	oClone:cporcentajeDescuento := ::cporcentajeDescuento
	oClone:cporcentajePago      := ::cporcentajePago
	oClone:creferenciaAnticipo  := ::creferenciaAnticipo
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_CondicionDePago
	Local cSoap := ""
	cSoap += WSSoapValue("codigoEvento", ::ccodigoEvento, ::ccodigoEvento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("comentario", ::ccomentario, ::ccomentario , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("duracionPeriodo", ::cduracionPeriodo, ::cduracionPeriodo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("duracionPeriodoMedida", ::cduracionPeriodoMedida, ::cduracionPeriodoMedida , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaVencimiento", ::cfechaVencimiento, ::cfechaVencimiento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("identificador", ::cidentificador, ::cidentificador , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("medioPagoAsociado", ::cmedioPagoAsociado, ::cmedioPagoAsociado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("monto", ::cmonto, ::cmonto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("montoMulta", ::cmontoMulta, ::cmontoMulta , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("montoPenalidad", ::cmontoPenalidad, ::cmontoPenalidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("periodoDesde", ::cperiodoDesde, ::cperiodoDesde , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("periodoHasta", ::cperiodoHasta, ::cperiodoHasta , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("porcentajeDescuento", ::cporcentajeDescuento, ::cporcentajeDescuento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("porcentajePago", ::cporcentajePago, ::cporcentajePago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("referenciaAnticipo", ::creferenciaAnticipo, ::creferenciaAnticipo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure FacturaDetalle

WSSTRUCT Service_FacturaDetalle
	WSDATA   ccantidadPorEmpaque       AS string OPTIONAL
	WSDATA   ccantidadReal             AS string OPTIONAL
	WSDATA   ccantidadRealUnidadMedida AS string OPTIONAL
	WSDATA   ccantidadUnidades         AS string OPTIONAL
	WSDATA   oWScargosDescuentos       AS Service_ArrayOfCargosDescuentos OPTIONAL
	WSDATA   ccodigoFabricante         AS string OPTIONAL
	WSDATA   ccodigoIdentificadorPais  AS string OPTIONAL
	WSDATA   ccodigoProducto           AS string OPTIONAL
	WSDATA   ccodigoTipoPrecio         AS string OPTIONAL
	WSDATA   cdescripcion              AS string OPTIONAL
	WSDATA   cdescripcion2             AS string OPTIONAL
	WSDATA   cdescripcion3             AS string OPTIONAL
	WSDATA   cdescripcionTecnica       AS string OPTIONAL
	WSDATA   oWSdocumentosReferenciados AS Service_ArrayOfDocumentoReferenciado OPTIONAL
	WSDATA   cestandarCodigo           AS string OPTIONAL
	WSDATA   cestandarCodigoID         AS string OPTIONAL
	WSDATA   cestandarCodigoIdentificador AS string OPTIONAL
	WSDATA   cestandarCodigoNombre     AS string OPTIONAL
	WSDATA   cestandarCodigoProducto   AS string OPTIONAL
	WSDATA   cestandarOrganizacion     AS string OPTIONAL
	WSDATA   cestandarSubCodigoProducto AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cidEsquema                AS string OPTIONAL
	WSDATA   oWSimpuestosDetalles      AS Service_ArrayOfFacturaImpuestos OPTIONAL
	WSDATA   oWSimpuestosTotales       AS Service_ArrayOfImpuestosTotales OPTIONAL
	WSDATA   oWSinformacionAdicional   AS Service_ArrayOfLineaInformacionAdicional OPTIONAL
	WSDATA   cmandatorioNumeroIdentificacion AS string OPTIONAL
	WSDATA   cmandatorioNumeroIdentificacionDV AS string OPTIONAL
	WSDATA   cmandatorioTipoIdentificacion AS string OPTIONAL
	WSDATA   cmarca                    AS string OPTIONAL
	WSDATA   cmodelo                   AS string OPTIONAL
	WSDATA   cmuestraGratis            AS string OPTIONAL
	WSDATA   cnombreFabricante         AS string OPTIONAL
	WSDATA   cnota                     AS string OPTIONAL
	WSDATA   cprecioReferencia         AS string OPTIONAL
	WSDATA   cprecioTotal              AS string OPTIONAL
	WSDATA   cprecioTotalSinImpuestos  AS string OPTIONAL
	WSDATA   cprecioVentaUnitario      AS string OPTIONAL
	WSDATA   csecuencia                AS string OPTIONAL
	WSDATA   cseriales                 AS string OPTIONAL
	WSDATA   csubCodigoFabricante      AS string OPTIONAL
	WSDATA   csubCodigoProducto        AS string OPTIONAL
	WSDATA   ctipoAIU                  AS string OPTIONAL
	WSDATA   cunidadMedida             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_FacturaDetalle
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_FacturaDetalle
Return

WSMETHOD CLONE WSCLIENT Service_FacturaDetalle
	Local oClone := Service_FacturaDetalle():NEW()
	oClone:ccantidadPorEmpaque  := ::ccantidadPorEmpaque
	oClone:ccantidadReal        := ::ccantidadReal
	oClone:ccantidadRealUnidadMedida := ::ccantidadRealUnidadMedida
	oClone:ccantidadUnidades    := ::ccantidadUnidades
	oClone:oWScargosDescuentos  := IIF(::oWScargosDescuentos = NIL , NIL , ::oWScargosDescuentos:Clone() )
	oClone:ccodigoFabricante    := ::ccodigoFabricante
	oClone:ccodigoIdentificadorPais := ::ccodigoIdentificadorPais
	oClone:ccodigoProducto      := ::ccodigoProducto
	oClone:ccodigoTipoPrecio    := ::ccodigoTipoPrecio
	oClone:cdescripcion         := ::cdescripcion
	oClone:cdescripcion2        := ::cdescripcion2
	oClone:cdescripcion3        := ::cdescripcion3
	oClone:cdescripcionTecnica  := ::cdescripcionTecnica
	oClone:oWSdocumentosReferenciados := IIF(::oWSdocumentosReferenciados = NIL , NIL , ::oWSdocumentosReferenciados:Clone() )
	oClone:cestandarCodigo      := ::cestandarCodigo
	oClone:cestandarCodigoID    := ::cestandarCodigoID
	oClone:cestandarCodigoIdentificador := ::cestandarCodigoIdentificador
	oClone:cestandarCodigoNombre := ::cestandarCodigoNombre
	oClone:cestandarCodigoProducto := ::cestandarCodigoProducto
	oClone:cestandarOrganizacion := ::cestandarOrganizacion
	oClone:cestandarSubCodigoProducto := ::cestandarSubCodigoProducto
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cidEsquema           := ::cidEsquema
	oClone:oWSimpuestosDetalles := IIF(::oWSimpuestosDetalles = NIL , NIL , ::oWSimpuestosDetalles:Clone() )
	oClone:oWSimpuestosTotales  := IIF(::oWSimpuestosTotales = NIL , NIL , ::oWSimpuestosTotales:Clone() )
	oClone:oWSinformacionAdicional := IIF(::oWSinformacionAdicional = NIL , NIL , ::oWSinformacionAdicional:Clone() )
	oClone:cmandatorioNumeroIdentificacion := ::cmandatorioNumeroIdentificacion
	oClone:cmandatorioNumeroIdentificacionDV := ::cmandatorioNumeroIdentificacionDV
	oClone:cmandatorioTipoIdentificacion := ::cmandatorioTipoIdentificacion
	oClone:cmarca               := ::cmarca
	oClone:cmodelo              := ::cmodelo
	oClone:cmuestraGratis       := ::cmuestraGratis
	oClone:cnombreFabricante    := ::cnombreFabricante
	oClone:cnota                := ::cnota
	oClone:cprecioReferencia    := ::cprecioReferencia
	oClone:cprecioTotal         := ::cprecioTotal
	oClone:cprecioTotalSinImpuestos := ::cprecioTotalSinImpuestos
	oClone:cprecioVentaUnitario := ::cprecioVentaUnitario
	oClone:csecuencia           := ::csecuencia
	oClone:cseriales            := ::cseriales
	oClone:csubCodigoFabricante := ::csubCodigoFabricante
	oClone:csubCodigoProducto   := ::csubCodigoProducto
	oClone:ctipoAIU             := ::ctipoAIU
	oClone:cunidadMedida        := ::cunidadMedida
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_FacturaDetalle
	Local cSoap := ""
	cSoap += WSSoapValue("cantidadPorEmpaque", ::ccantidadPorEmpaque, ::ccantidadPorEmpaque , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("cantidadReal", ::ccantidadReal, ::ccantidadReal , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("cantidadRealUnidadMedida", ::ccantidadRealUnidadMedida, ::ccantidadRealUnidadMedida , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("cantidadUnidades", ::ccantidadUnidades, ::ccantidadUnidades , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("cargosDescuentos", ::oWScargosDescuentos, ::oWScargosDescuentos , "ArrayOfCargosDescuentos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoFabricante", ::ccodigoFabricante, ::ccodigoFabricante , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoIdentificadorPais", ::ccodigoIdentificadorPais, ::ccodigoIdentificadorPais , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoProducto", ::ccodigoProducto, ::ccodigoProducto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoTipoPrecio", ::ccodigoTipoPrecio, ::ccodigoTipoPrecio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("descripcion", ::cdescripcion, ::cdescripcion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("descripcion2", ::cdescripcion2, ::cdescripcion2 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("descripcion3", ::cdescripcion3, ::cdescripcion3 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("descripcionTecnica", ::cdescripcionTecnica, ::cdescripcionTecnica , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("documentosReferenciados", ::oWSdocumentosReferenciados, ::oWSdocumentosReferenciados , "ArrayOfDocumentoReferenciado", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("estandarCodigo", ::cestandarCodigo, ::cestandarCodigo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("estandarCodigoID", ::cestandarCodigoID, ::cestandarCodigoID , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("estandarCodigoIdentificador", ::cestandarCodigoIdentificador, ::cestandarCodigoIdentificador , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("estandarCodigoNombre", ::cestandarCodigoNombre, ::cestandarCodigoNombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("estandarCodigoProducto", ::cestandarCodigoProducto, ::cestandarCodigoProducto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("estandarOrganizacion", ::cestandarOrganizacion, ::cestandarOrganizacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("estandarSubCodigoProducto", ::cestandarSubCodigoProducto, ::cestandarSubCodigoProducto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("idEsquema", ::cidEsquema, ::cidEsquema , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("impuestosDetalles", ::oWSimpuestosDetalles, ::oWSimpuestosDetalles , "ArrayOfFacturaImpuestos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("impuestosTotales", ::oWSimpuestosTotales, ::oWSimpuestosTotales , "ArrayOfImpuestosTotales", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("informacionAdicional", ::oWSinformacionAdicional, ::oWSinformacionAdicional , "ArrayOfLineaInformacionAdicional", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("mandatorioNumeroIdentificacion", ::cmandatorioNumeroIdentificacion, ::cmandatorioNumeroIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("mandatorioNumeroIdentificacionDV", ::cmandatorioNumeroIdentificacionDV, ::cmandatorioNumeroIdentificacionDV , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("mandatorioTipoIdentificacion", ::cmandatorioTipoIdentificacion, ::cmandatorioTipoIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("marca", ::cmarca, ::cmarca , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("modelo", ::cmodelo, ::cmodelo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("muestraGratis", ::cmuestraGratis, ::cmuestraGratis , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreFabricante", ::cnombreFabricante, ::cnombreFabricante , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nota", ::cnota, ::cnota , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("precioReferencia", ::cprecioReferencia, ::cprecioReferencia , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("precioTotal", ::cprecioTotal, ::cprecioTotal , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("precioTotalSinImpuestos", ::cprecioTotalSinImpuestos, ::cprecioTotalSinImpuestos , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("precioVentaUnitario", ::cprecioVentaUnitario, ::cprecioVentaUnitario , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("secuencia", ::csecuencia, ::csecuencia , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("seriales", ::cseriales, ::cseriales , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("subCodigoFabricante", ::csubCodigoFabricante, ::csubCodigoFabricante , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("subCodigoProducto", ::csubCodigoProducto, ::csubCodigoProducto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoAIU", ::ctipoAIU, ::ctipoAIU , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("unidadMedida", ::cunidadMedida, ::cunidadMedida , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure DocumentoReferenciado

WSSTRUCT Service_DocumentoReferenciado
	WSDATA   ccodigoEstatusDocumento   AS string OPTIONAL
	WSDATA   ccodigoInterno            AS string OPTIONAL
	WSDATA   cconceptoRecaudo          AS string OPTIONAL
	WSDATA   ccufeDocReferenciado      AS string OPTIONAL
	WSDATA   oWSdescripcion            AS Service_ArrayOfstring OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfecha                    AS string OPTIONAL
	WSDATA   cfechaFinValidez          AS string OPTIONAL
	WSDATA   cfechaInicioValidez       AS string OPTIONAL
	WSDATA   cmonto                    AS string OPTIONAL
	WSDATA   cnumeroDocumento          AS string OPTIONAL
	WSDATA   cnumeroIdentificacion     AS string OPTIONAL
	WSDATA   ctipoCUFE                 AS string OPTIONAL
	WSDATA   ctipoDocumento            AS string OPTIONAL
	WSDATA   ctipoDocumentoCodigo      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DocumentoReferenciado
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DocumentoReferenciado
Return

WSMETHOD CLONE WSCLIENT Service_DocumentoReferenciado
	Local oClone := Service_DocumentoReferenciado():NEW()
	oClone:ccodigoEstatusDocumento := ::ccodigoEstatusDocumento
	oClone:ccodigoInterno       := ::ccodigoInterno
	oClone:cconceptoRecaudo     := ::cconceptoRecaudo
	oClone:ccufeDocReferenciado := ::ccufeDocReferenciado
	oClone:oWSdescripcion       := IIF(::oWSdescripcion = NIL , NIL , ::oWSdescripcion:Clone() )
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfecha               := ::cfecha
	oClone:cfechaFinValidez     := ::cfechaFinValidez
	oClone:cfechaInicioValidez  := ::cfechaInicioValidez
	oClone:cmonto               := ::cmonto
	oClone:cnumeroDocumento     := ::cnumeroDocumento
	oClone:cnumeroIdentificacion := ::cnumeroIdentificacion
	oClone:ctipoCUFE            := ::ctipoCUFE
	oClone:ctipoDocumento       := ::ctipoDocumento
	oClone:ctipoDocumentoCodigo := ::ctipoDocumentoCodigo
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_DocumentoReferenciado
	Local cSoap := ""
	cSoap += WSSoapValue("codigoEstatusDocumento", ::ccodigoEstatusDocumento, ::ccodigoEstatusDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoInterno", ::ccodigoInterno, ::ccodigoInterno , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("conceptoRecaudo", ::cconceptoRecaudo, ::cconceptoRecaudo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("cufeDocReferenciado", ::ccufeDocReferenciado, ::ccufeDocReferenciado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("descripcion", ::oWSdescripcion, ::oWSdescripcion , "ArrayOfstring", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fecha", ::cfecha, ::cfecha , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaFinValidez", ::cfechaFinValidez, ::cfechaFinValidez , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaInicioValidez", ::cfechaInicioValidez, ::cfechaInicioValidez , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("monto", ::cmonto, ::cmonto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroDocumento", ::cnumeroDocumento, ::cnumeroDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroIdentificacion", ::cnumeroIdentificacion, ::cnumeroIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoCUFE", ::ctipoCUFE, ::ctipoCUFE , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoDocumento", ::ctipoDocumento, ::ctipoDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoDocumentoCodigo", ::ctipoDocumentoCodigo, ::ctipoDocumentoCodigo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure DatosDelTransportista

WSSTRUCT Service_DatosDelTransportista
	WSDATA   oWSdetallesTributarios    AS Service_ArrayOfTributos OPTIONAL
	WSDATA   oWSdireccionResponsableEntrega AS Service_Direccion OPTIONAL
	WSDATA   cemail                    AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cindicadordeAtencion      AS string OPTIONAL
	WSDATA   cindicadordeCuidado       AS string OPTIONAL
	WSDATA   cnombreContacto           AS string OPTIONAL
	WSDATA   cnombreResponsableEntrega AS string OPTIONAL
	WSDATA   cnota                     AS string OPTIONAL
	WSDATA   cnumeroIdentificacion     AS string OPTIONAL
	WSDATA   cnumeroIdentificacionDV   AS string OPTIONAL
	WSDATA   cnumeroMatriculaMercantil AS string OPTIONAL
	WSDATA   cprefijoFacturacion       AS string OPTIONAL
	WSDATA   oWSresponsabilidadesRut   AS Service_ArrayOfObligaciones OPTIONAL
	WSDATA   ctelefax                  AS string OPTIONAL
	WSDATA   ctelefono                 AS string OPTIONAL
	WSDATA   ctipoIdentificacion       AS string OPTIONAL
	WSDATA   oWStransportadorDireccion AS Service_Direccion OPTIONAL
	WSDATA   ctransportadorNombre      AS string OPTIONAL
	WSDATA   ctransportadorNumeroDocumento AS string OPTIONAL
	WSDATA   ctransportadorNumeroDocumentoDV AS string OPTIONAL
	WSDATA   ctransportadorTipoIdentificacion AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DatosDelTransportista
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DatosDelTransportista
Return

WSMETHOD CLONE WSCLIENT Service_DatosDelTransportista
	Local oClone := Service_DatosDelTransportista():NEW()
	oClone:oWSdetallesTributarios := IIF(::oWSdetallesTributarios = NIL , NIL , ::oWSdetallesTributarios:Clone() )
	oClone:oWSdireccionResponsableEntrega := IIF(::oWSdireccionResponsableEntrega = NIL , NIL , ::oWSdireccionResponsableEntrega:Clone() )
	oClone:cemail               := ::cemail
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cindicadordeAtencion := ::cindicadordeAtencion
	oClone:cindicadordeCuidado  := ::cindicadordeCuidado
	oClone:cnombreContacto      := ::cnombreContacto
	oClone:cnombreResponsableEntrega := ::cnombreResponsableEntrega
	oClone:cnota                := ::cnota
	oClone:cnumeroIdentificacion := ::cnumeroIdentificacion
	oClone:cnumeroIdentificacionDV := ::cnumeroIdentificacionDV
	oClone:cnumeroMatriculaMercantil := ::cnumeroMatriculaMercantil
	oClone:cprefijoFacturacion  := ::cprefijoFacturacion
	oClone:oWSresponsabilidadesRut := IIF(::oWSresponsabilidadesRut = NIL , NIL , ::oWSresponsabilidadesRut:Clone() )
	oClone:ctelefax             := ::ctelefax
	oClone:ctelefono            := ::ctelefono
	oClone:ctipoIdentificacion  := ::ctipoIdentificacion
	oClone:oWStransportadorDireccion := IIF(::oWStransportadorDireccion = NIL , NIL , ::oWStransportadorDireccion:Clone() )
	oClone:ctransportadorNombre := ::ctransportadorNombre
	oClone:ctransportadorNumeroDocumento := ::ctransportadorNumeroDocumento
	oClone:ctransportadorNumeroDocumentoDV := ::ctransportadorNumeroDocumentoDV
	oClone:ctransportadorTipoIdentificacion := ::ctransportadorTipoIdentificacion
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_DatosDelTransportista
	Local cSoap := ""
	cSoap += WSSoapValue("detallesTributarios", ::oWSdetallesTributarios, ::oWSdetallesTributarios , "ArrayOfTributos", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("direccionResponsableEntrega", ::oWSdireccionResponsableEntrega, ::oWSdireccionResponsableEntrega , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("indicadordeAtencion", ::cindicadordeAtencion, ::cindicadordeAtencion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("indicadordeCuidado", ::cindicadordeCuidado, ::cindicadordeCuidado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreContacto", ::cnombreContacto, ::cnombreContacto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreResponsableEntrega", ::cnombreResponsableEntrega, ::cnombreResponsableEntrega , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nota", ::cnota, ::cnota , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroIdentificacion", ::cnumeroIdentificacion, ::cnumeroIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroIdentificacionDV", ::cnumeroIdentificacionDV, ::cnumeroIdentificacionDV , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroMatriculaMercantil", ::cnumeroMatriculaMercantil, ::cnumeroMatriculaMercantil , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("prefijoFacturacion", ::cprefijoFacturacion, ::cprefijoFacturacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("responsabilidadesRut", ::oWSresponsabilidadesRut, ::oWSresponsabilidadesRut , "ArrayOfObligaciones", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("telefax", ::ctelefax, ::ctelefax , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("telefono", ::ctelefono, ::ctelefono , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoIdentificacion", ::ctipoIdentificacion, ::ctipoIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("transportadorDireccion", ::oWStransportadorDireccion, ::oWStransportadorDireccion , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("transportadorNombre", ::ctransportadorNombre, ::ctransportadorNombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("transportadorNumeroDocumento", ::ctransportadorNumeroDocumento, ::ctransportadorNumeroDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("transportadorNumeroDocumentoDV", ::ctransportadorNumeroDocumentoDV, ::ctransportadorNumeroDocumentoDV , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("transportadorTipoIdentificacion", ::ctransportadorTipoIdentificacion, ::ctransportadorTipoIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure Extras

WSSTRUCT Service_Extras
	WSDATA   ccontrolInterno1          AS string OPTIONAL
	WSDATA   ccontrolInterno2          AS string OPTIONAL
	WSDATA   cnombre                   AS string OPTIONAL
	WSDATA   cpdf                      AS string OPTIONAL
	WSDATA   cvalor                    AS string OPTIONAL
	WSDATA   cxml                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Extras
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Extras
Return

WSMETHOD CLONE WSCLIENT Service_Extras
	Local oClone := Service_Extras():NEW()
	oClone:ccontrolInterno1     := ::ccontrolInterno1
	oClone:ccontrolInterno2     := ::ccontrolInterno2
	oClone:cnombre              := ::cnombre
	oClone:cpdf                 := ::cpdf
	oClone:cvalor               := ::cvalor
	oClone:cxml                 := ::cxml
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Extras
	Local cSoap := ""
	cSoap += WSSoapValue("controlInterno1", ::ccontrolInterno1, ::ccontrolInterno1 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("controlInterno2", ::ccontrolInterno2, ::ccontrolInterno2 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombre", ::cnombre, ::cnombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("pdf", ::cpdf, ::cpdf , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("valor", ::cvalor, ::cvalor , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("xml", ::cxml, ::cxml , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure FacturaImpuestos

WSSTRUCT Service_FacturaImpuestos
	WSDATA   cbaseImponibleTOTALImp    AS string OPTIONAL
	WSDATA   ccodigoTOTALImp           AS string OPTIONAL
	WSDATA   ccontrolInterno           AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cporcentajeTOTALImp       AS string OPTIONAL
	WSDATA   cunidadMedida             AS string OPTIONAL
	WSDATA   cunidadMedidaTributo      AS string OPTIONAL
	WSDATA   cvalorTOTALImp            AS string OPTIONAL
	WSDATA   cvalorTributoUnidad       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_FacturaImpuestos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_FacturaImpuestos
Return

WSMETHOD CLONE WSCLIENT Service_FacturaImpuestos
	Local oClone := Service_FacturaImpuestos():NEW()
	oClone:cbaseImponibleTOTALImp := ::cbaseImponibleTOTALImp
	oClone:ccodigoTOTALImp      := ::ccodigoTOTALImp
	oClone:ccontrolInterno      := ::ccontrolInterno
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cporcentajeTOTALImp  := ::cporcentajeTOTALImp
	oClone:cunidadMedida        := ::cunidadMedida
	oClone:cunidadMedidaTributo := ::cunidadMedidaTributo
	oClone:cvalorTOTALImp       := ::cvalorTOTALImp
	oClone:cvalorTributoUnidad  := ::cvalorTributoUnidad
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_FacturaImpuestos
	Local cSoap := ""
	cSoap += WSSoapValue("baseImponibleTOTALImp", ::cbaseImponibleTOTALImp, ::cbaseImponibleTOTALImp , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoTOTALImp", ::ccodigoTOTALImp, ::ccodigoTOTALImp , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("controlInterno", ::ccontrolInterno, ::ccontrolInterno , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("porcentajeTOTALImp", ::cporcentajeTOTALImp, ::cporcentajeTOTALImp , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("unidadMedida", ::cunidadMedida, ::cunidadMedida , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("unidadMedidaTributo", ::cunidadMedidaTributo, ::cunidadMedidaTributo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("valorTOTALImp", ::cvalorTOTALImp, ::cvalorTOTALImp , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("valorTributoUnidad", ::cvalorTributoUnidad, ::cvalorTributoUnidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ImpuestosTotales

WSSTRUCT Service_ImpuestosTotales
	WSDATA   ccodigoTOTALImp           AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cmontoTotal               AS string OPTIONAL
	WSDATA   credondeoAplicado         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ImpuestosTotales
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ImpuestosTotales
Return

WSMETHOD CLONE WSCLIENT Service_ImpuestosTotales
	Local oClone := Service_ImpuestosTotales():NEW()
	oClone:ccodigoTOTALImp      := ::ccodigoTOTALImp
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cmontoTotal          := ::cmontoTotal
	oClone:credondeoAplicado    := ::credondeoAplicado
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ImpuestosTotales
	Local cSoap := ""
	cSoap += WSSoapValue("codigoTOTALImp", ::ccodigoTOTALImp, ::ccodigoTOTALImp , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("montoTotal", ::cmontoTotal, ::cmontoTotal , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("redondeoAplicado", ::credondeoAplicado, ::credondeoAplicado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure MediosDePago

WSSTRUCT Service_MediosDePago
	WSDATA   ccodigoBanco              AS string OPTIONAL
	WSDATA   ccodigoCanalPago          AS string OPTIONAL
	WSDATA   ccodigoReferencia         AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfechaDeVencimiento       AS string OPTIONAL
	WSDATA   cmedioPago                AS string OPTIONAL
	WSDATA   cmetodoDePago             AS string OPTIONAL
	WSDATA   cnombreBanco              AS string OPTIONAL
	WSDATA   cnumeroDeReferencia       AS string OPTIONAL
	WSDATA   cnumeroDias               AS string OPTIONAL
	WSDATA   cnumeroTransferencia      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_MediosDePago
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_MediosDePago
Return

WSMETHOD CLONE WSCLIENT Service_MediosDePago
	Local oClone := Service_MediosDePago():NEW()
	oClone:ccodigoBanco         := ::ccodigoBanco
	oClone:ccodigoCanalPago     := ::ccodigoCanalPago
	oClone:ccodigoReferencia    := ::ccodigoReferencia
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaDeVencimiento  := ::cfechaDeVencimiento
	oClone:cmedioPago           := ::cmedioPago
	oClone:cmetodoDePago        := ::cmetodoDePago
	oClone:cnombreBanco         := ::cnombreBanco
	oClone:cnumeroDeReferencia  := ::cnumeroDeReferencia
	oClone:cnumeroDias          := ::cnumeroDias
	oClone:cnumeroTransferencia := ::cnumeroTransferencia
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_MediosDePago
	Local cSoap := ""
	cSoap += WSSoapValue("codigoBanco", ::ccodigoBanco, ::ccodigoBanco , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoCanalPago", ::ccodigoCanalPago, ::ccodigoCanalPago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoReferencia", ::ccodigoReferencia, ::ccodigoReferencia , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaDeVencimiento", ::cfechaDeVencimiento, ::cfechaDeVencimiento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("medioPago", ::cmedioPago, ::cmedioPago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("metodoDePago", ::cmetodoDePago, ::cmetodoDePago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombreBanco", ::cnombreBanco, ::cnombreBanco , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroDeReferencia", ::cnumeroDeReferencia, ::cnumeroDeReferencia , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroDias", ::cnumeroDias, ::cnumeroDias , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroTransferencia", ::cnumeroTransferencia, ::cnumeroTransferencia , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure OrdenDeCompra

WSSTRUCT Service_OrdenDeCompra
	WSDATA   ccodigoCliente            AS string OPTIONAL
	WSDATA   oWSdocumentoReferencia    AS Service_DocumentoReferenciado OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfecha                    AS string OPTIONAL
	WSDATA   cnumeroOrden              AS string OPTIONAL
	WSDATA   cnumeroPedido             AS string OPTIONAL
	WSDATA   ctipoCUFE                 AS string OPTIONAL
	WSDATA   ctipoOrden                AS string OPTIONAL
	WSDATA   cuuid                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_OrdenDeCompra
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_OrdenDeCompra
Return

WSMETHOD CLONE WSCLIENT Service_OrdenDeCompra
	Local oClone := Service_OrdenDeCompra():NEW()
	oClone:ccodigoCliente       := ::ccodigoCliente
	oClone:oWSdocumentoReferencia := IIF(::oWSdocumentoReferencia = NIL , NIL , ::oWSdocumentoReferencia:Clone() )
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfecha               := ::cfecha
	oClone:cnumeroOrden         := ::cnumeroOrden
	oClone:cnumeroPedido        := ::cnumeroPedido
	oClone:ctipoCUFE            := ::ctipoCUFE
	oClone:ctipoOrden           := ::ctipoOrden
	oClone:cuuid                := ::cuuid
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_OrdenDeCompra
	Local cSoap := ""
	cSoap += WSSoapValue("codigoCliente", ::ccodigoCliente, ::ccodigoCliente , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("documentoReferencia", ::oWSdocumentoReferencia, ::oWSdocumentoReferencia , "DocumentoReferenciado", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fecha", ::cfecha, ::cfecha , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroOrden", ::cnumeroOrden, ::cnumeroOrden , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroPedido", ::cnumeroPedido, ::cnumeroPedido , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoCUFE", ::ctipoCUFE, ::ctipoCUFE , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipoOrden", ::ctipoOrden, ::ctipoOrden , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("uuid", ::cuuid, ::cuuid , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure BeneficiarioSalud

WSSTRUCT Service_BeneficiarioSalud
	WSDATA   oWSDireccionResidencia    AS Service_Direccion OPTIONAL
	WSDATA   cTipoIdentificacion       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_BeneficiarioSalud
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_BeneficiarioSalud
Return

WSMETHOD CLONE WSCLIENT Service_BeneficiarioSalud
	Local oClone := Service_BeneficiarioSalud():NEW()
	oClone:oWSDireccionResidencia := IIF(::oWSDireccionResidencia = NIL , NIL , ::oWSDireccionResidencia:Clone() )
	oClone:cTipoIdentificacion  := ::cTipoIdentificacion
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_BeneficiarioSalud
	Local cSoap := ""
	cSoap += WSSoapValue("DireccionResidencia", ::oWSDireccionResidencia, ::oWSDireccionResidencia , "Direccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("TipoIdentificacion", ::cTipoIdentificacion, ::cTipoIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfDatosPacienteSalud

WSSTRUCT Service_ArrayOfDatosPacienteSalud
	WSDATA   oWSDatosPacienteSalud     AS Service_DatosPacienteSalud OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfDatosPacienteSalud
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfDatosPacienteSalud
	::oWSDatosPacienteSalud := {} // Array Of  Service_DATOSPACIENTESALUD():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfDatosPacienteSalud
	Local oClone := Service_ArrayOfDatosPacienteSalud():NEW()
	oClone:oWSDatosPacienteSalud := NIL
	If ::oWSDatosPacienteSalud <> NIL 
		oClone:oWSDatosPacienteSalud := {}
		aEval( ::oWSDatosPacienteSalud , { |x| aadd( oClone:oWSDatosPacienteSalud , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfDatosPacienteSalud
	Local cSoap := ""
	aEval( ::oWSDatosPacienteSalud , {|x| cSoap := cSoap  +  WSSoapValue("DatosPacienteSalud", x , x , "DatosPacienteSalud", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Evento

WSSTRUCT Service_Evento
	WSDATA   cambienteDIAN             AS string OPTIONAL
	WSDATA   ccodigo                   AS string OPTIONAL
	WSDATA   ccomentario               AS string OPTIONAL
	WSDATA   ccufe                     AS string OPTIONAL
	WSDATA   cdescripcionEvento        AS string OPTIONAL
	WSDATA   cemisorNumeroDocumento    AS string OPTIONAL
	WSDATA   cemisorNumeroDocumentoDV  AS string OPTIONAL
	WSDATA   cemisorRazonSocial        AS string OPTIONAL
	WSDATA   cemisorTipoIdentificacion AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtrasEvento OPTIONAL
	WSDATA   cfechaEmision             AS string OPTIONAL
	WSDATA   cfechaRecepcion           AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cidPerfilDIAN             AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cnombreArchivoXML         AS string OPTIONAL
	WSDATA   cnota                     AS string OPTIONAL
	WSDATA   cnumeroDelEvento          AS string OPTIONAL
	WSDATA   creceptorNumeroDocumento  AS string OPTIONAL
	WSDATA   creceptorNumeroDocumentoDV AS string OPTIONAL
	WSDATA   creceptorRazonSocial      AS string OPTIONAL
	WSDATA   creceptorTipoIdentificacion AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctipoCufe                 AS string OPTIONAL
	WSDATA   ctipoEvento               AS string OPTIONAL
	WSDATA   cversionUBL               AS string OPTIONAL
	WSDATA   cxml                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Evento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Evento
Return

WSMETHOD CLONE WSCLIENT Service_Evento
	Local oClone := Service_Evento():NEW()
	oClone:cambienteDIAN        := ::cambienteDIAN
	oClone:ccodigo              := ::ccodigo
	oClone:ccomentario          := ::ccomentario
	oClone:ccufe                := ::ccufe
	oClone:cdescripcionEvento   := ::cdescripcionEvento
	oClone:cemisorNumeroDocumento := ::cemisorNumeroDocumento
	oClone:cemisorNumeroDocumentoDV := ::cemisorNumeroDocumentoDV
	oClone:cemisorRazonSocial   := ::cemisorRazonSocial
	oClone:cemisorTipoIdentificacion := ::cemisorTipoIdentificacion
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaEmision        := ::cfechaEmision
	oClone:cfechaRecepcion      := ::cfechaRecepcion
	oClone:chash                := ::chash
	oClone:cidPerfilDIAN        := ::cidPerfilDIAN
	oClone:cmensaje             := ::cmensaje
	oClone:cnombreArchivoXML    := ::cnombreArchivoXML
	oClone:cnota                := ::cnota
	oClone:cnumeroDelEvento     := ::cnumeroDelEvento
	oClone:creceptorNumeroDocumento := ::creceptorNumeroDocumento
	oClone:creceptorNumeroDocumentoDV := ::creceptorNumeroDocumentoDV
	oClone:creceptorRazonSocial := ::creceptorRazonSocial
	oClone:creceptorTipoIdentificacion := ::creceptorTipoIdentificacion
	oClone:cresultado           := ::cresultado
	oClone:ctipoCufe            := ::ctipoCufe
	oClone:ctipoEvento          := ::ctipoEvento
	oClone:cversionUBL          := ::cversionUBL
	oClone:cxml                 := ::cxml
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_Evento
	Local oNode10
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cambienteDIAN      :=  WSAdvValue( oResponse,"_AMBIENTEDIAN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccomentario        :=  WSAdvValue( oResponse,"_COMENTARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccufe              :=  WSAdvValue( oResponse,"_CUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescripcionEvento :=  WSAdvValue( oResponse,"_DESCRIPCIONEVENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cemisorNumeroDocumento :=  WSAdvValue( oResponse,"_EMISORNUMERODOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cemisorNumeroDocumentoDV :=  WSAdvValue( oResponse,"_EMISORNUMERODOCUMENTODV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cemisorRazonSocial :=  WSAdvValue( oResponse,"_EMISORRAZONSOCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cemisorTipoIdentificacion :=  WSAdvValue( oResponse,"_EMISORTIPOIDENTIFICACION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode10 :=  WSAdvValue( oResponse,"_EXTRAS","ArrayOfExtrasEvento",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSextras := Service_ArrayOfExtrasEvento():New()
		::oWSextras:SoapRecv(oNode10)
	EndIf
	::cfechaEmision      :=  WSAdvValue( oResponse,"_FECHAEMISION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfechaRecepcion    :=  WSAdvValue( oResponse,"_FECHARECEPCION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidPerfilDIAN      :=  WSAdvValue( oResponse,"_IDPERFILDIAN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnombreArchivoXML  :=  WSAdvValue( oResponse,"_NOMBREARCHIVOXML","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnota              :=  WSAdvValue( oResponse,"_NOTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnumeroDelEvento   :=  WSAdvValue( oResponse,"_NUMERODELEVENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creceptorNumeroDocumento :=  WSAdvValue( oResponse,"_RECEPTORNUMERODOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creceptorNumeroDocumentoDV :=  WSAdvValue( oResponse,"_RECEPTORNUMERODOCUMENTODV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creceptorRazonSocial :=  WSAdvValue( oResponse,"_RECEPTORRAZONSOCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creceptorTipoIdentificacion :=  WSAdvValue( oResponse,"_RECEPTORTIPOIDENTIFICACION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoCufe          :=  WSAdvValue( oResponse,"_TIPOCUFE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoEvento        :=  WSAdvValue( oResponse,"_TIPOEVENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cversionUBL        :=  WSAdvValue( oResponse,"_VERSIONUBL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cxml               :=  WSAdvValue( oResponse,"_XML","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure HistorialDeEntrega

WSSTRUCT Service_HistorialDeEntrega
	WSDATA   cLeidoEmailIPAddress      AS string OPTIONAL
	WSDATA   cLeidoEstatus             AS string OPTIONAL
	WSDATA   cLeidoFecha               AS string OPTIONAL
	WSDATA   ccanalDeEntrega           AS string OPTIONAL
	WSDATA   oWSemail                  AS Service_ArrayOfstring OPTIONAL
	WSDATA   centregaEstatus           AS string OPTIONAL
	WSDATA   centregaEstatusDescripcion AS string OPTIONAL
	WSDATA   centregaFecha             AS string OPTIONAL
	WSDATA   cfechaProgramada          AS string OPTIONAL
	WSDATA   cmensajePersonalizado     AS string OPTIONAL
	WSDATA   cnitProveedorReceptor     AS string OPTIONAL
	WSDATA   crecepcionEmailComentario AS string OPTIONAL
	WSDATA   crecepcionEmailEstatus    AS string OPTIONAL
	WSDATA   crecepcionEmailFecha      AS string OPTIONAL
	WSDATA   crecepcionEmailIPAddress  AS string OPTIONAL
	WSDATA   ctelefono                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_HistorialDeEntrega
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_HistorialDeEntrega
Return

WSMETHOD CLONE WSCLIENT Service_HistorialDeEntrega
	Local oClone := Service_HistorialDeEntrega():NEW()
	oClone:cLeidoEmailIPAddress := ::cLeidoEmailIPAddress
	oClone:cLeidoEstatus        := ::cLeidoEstatus
	oClone:cLeidoFecha          := ::cLeidoFecha
	oClone:ccanalDeEntrega      := ::ccanalDeEntrega
	oClone:oWSemail             := IIF(::oWSemail = NIL , NIL , ::oWSemail:Clone() )
	oClone:centregaEstatus      := ::centregaEstatus
	oClone:centregaEstatusDescripcion := ::centregaEstatusDescripcion
	oClone:centregaFecha        := ::centregaFecha
	oClone:cfechaProgramada     := ::cfechaProgramada
	oClone:cmensajePersonalizado := ::cmensajePersonalizado
	oClone:cnitProveedorReceptor := ::cnitProveedorReceptor
	oClone:crecepcionEmailComentario := ::crecepcionEmailComentario
	oClone:crecepcionEmailEstatus := ::crecepcionEmailEstatus
	oClone:crecepcionEmailFecha := ::crecepcionEmailFecha
	oClone:crecepcionEmailIPAddress := ::crecepcionEmailIPAddress
	oClone:ctelefono            := ::ctelefono
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_HistorialDeEntrega
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cLeidoEmailIPAddress :=  WSAdvValue( oResponse,"_LEIDOEMAILIPADDRESS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLeidoEstatus      :=  WSAdvValue( oResponse,"_LEIDOESTATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLeidoFecha        :=  WSAdvValue( oResponse,"_LEIDOFECHA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccanalDeEntrega    :=  WSAdvValue( oResponse,"_CANALDEENTREGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_EMAIL","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSemail := Service_ArrayOfstring():New()
		::oWSemail:SoapRecv(oNode5)
	EndIf
	::centregaEstatus    :=  WSAdvValue( oResponse,"_ENTREGAESTATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::centregaEstatusDescripcion :=  WSAdvValue( oResponse,"_ENTREGAESTATUSDESCRIPCION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::centregaFecha      :=  WSAdvValue( oResponse,"_ENTREGAFECHA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfechaProgramada   :=  WSAdvValue( oResponse,"_FECHAPROGRAMADA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensajePersonalizado :=  WSAdvValue( oResponse,"_MENSAJEPERSONALIZADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnitProveedorReceptor :=  WSAdvValue( oResponse,"_NITPROVEEDORRECEPTOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crecepcionEmailComentario :=  WSAdvValue( oResponse,"_RECEPCIONEMAILCOMENTARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crecepcionEmailEstatus :=  WSAdvValue( oResponse,"_RECEPCIONEMAILESTATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crecepcionEmailFecha :=  WSAdvValue( oResponse,"_RECEPCIONEMAILFECHA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crecepcionEmailIPAddress :=  WSAdvValue( oResponse,"_RECEPCIONEMAILIPADDRESS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctelefono          :=  WSAdvValue( oResponse,"_TELEFONO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure DatosExtras

WSSTRUCT Service_DatosExtras
	WSDATA   ccodigoInterno1           AS string OPTIONAL
	WSDATA   ccodigoInterno2           AS string OPTIONAL
	WSDATA   cnombre                   AS string OPTIONAL
	WSDATA   cvalor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DatosExtras
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DatosExtras
Return

WSMETHOD CLONE WSCLIENT Service_DatosExtras
	Local oClone := Service_DatosExtras():NEW()
	oClone:ccodigoInterno1      := ::ccodigoInterno1
	oClone:ccodigoInterno2      := ::ccodigoInterno2
	oClone:cnombre              := ::cnombre
	oClone:cvalor               := ::cvalor
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_DatosExtras
	Local cSoap := ""
	cSoap += WSSoapValue("codigoInterno1", ::ccodigoInterno1, ::ccodigoInterno1 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoInterno2", ::ccodigoInterno2, ::ccodigoInterno2 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombre", ::cnombre, ::cnombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("valor", ::cvalor, ::cvalor , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfCoordenadas

WSSTRUCT Service_ArrayOfCoordenadas
	WSDATA   oWSCoordenadas            AS Service_Coordenadas OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfCoordenadas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfCoordenadas
	::oWSCoordenadas       := {} // Array Of  Service_COORDENADAS():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfCoordenadas
	Local oClone := Service_ArrayOfCoordenadas():NEW()
	oClone:oWSCoordenadas := NIL
	If ::oWSCoordenadas <> NIL 
		oClone:oWSCoordenadas := {}
		aEval( ::oWSCoordenadas , { |x| aadd( oClone:oWSCoordenadas , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfCoordenadas
	Local cSoap := ""
	aEval( ::oWSCoordenadas , {|x| cSoap := cSoap  +  WSSoapValue("Coordenadas", x , x , "Coordenadas", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Extensible

WSSTRUCT Service_Extensible
	WSDATA   ccontrolInterno1          AS string OPTIONAL
	WSDATA   ccontrolInterno2          AS string OPTIONAL
	WSDATA   cnombre                   AS string OPTIONAL
	WSDATA   cvalor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Extensible
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Extensible
Return

WSMETHOD CLONE WSCLIENT Service_Extensible
	Local oClone := Service_Extensible():NEW()
	oClone:ccontrolInterno1     := ::ccontrolInterno1
	oClone:ccontrolInterno2     := ::ccontrolInterno2
	oClone:cnombre              := ::cnombre
	oClone:cvalor               := ::cvalor
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Extensible
	Local cSoap := ""
	cSoap += WSSoapValue("controlInterno1", ::ccontrolInterno1, ::ccontrolInterno1 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("controlInterno2", ::ccontrolInterno2, ::ccontrolInterno2 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombre", ::cnombre, ::cnombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("valor", ::cvalor, ::cvalor , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure Destinatario

WSSTRUCT Service_Destinatario
	WSDATA   ccanalDeEntrega           AS string OPTIONAL
	WSDATA   oWSemail                  AS Service_ArrayOfstring OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cfechaProgramada          AS string OPTIONAL
	WSDATA   cmensajePersonalizado     AS string OPTIONAL
	WSDATA   cnitProveedorReceptor     AS string OPTIONAL
	WSDATA   ctelefono                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Destinatario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Destinatario
Return

WSMETHOD CLONE WSCLIENT Service_Destinatario
	Local oClone := Service_Destinatario():NEW()
	oClone:ccanalDeEntrega      := ::ccanalDeEntrega
	oClone:oWSemail             := IIF(::oWSemail = NIL , NIL , ::oWSemail:Clone() )
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cfechaProgramada     := ::cfechaProgramada
	oClone:cmensajePersonalizado := ::cmensajePersonalizado
	oClone:cnitProveedorReceptor := ::cnitProveedorReceptor
	oClone:ctelefono            := ::ctelefono
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Destinatario
	Local cSoap := ""
	cSoap += WSSoapValue("canalDeEntrega", ::ccanalDeEntrega, ::ccanalDeEntrega , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("email", ::oWSemail, ::oWSemail , "ArrayOfstring", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaProgramada", ::cfechaProgramada, ::cfechaProgramada , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("mensajePersonalizado", ::cmensajePersonalizado, ::cmensajePersonalizado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nitProveedorReceptor", ::cnitProveedorReceptor, ::cnitProveedorReceptor , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("telefono", ::ctelefono, ::ctelefono , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure Tributos

WSSTRUCT Service_Tributos
	WSDATA   ccodigoImpuesto           AS string OPTIONAL
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Tributos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Tributos
Return

WSMETHOD CLONE WSCLIENT Service_Tributos
	Local oClone := Service_Tributos():NEW()
	oClone:ccodigoImpuesto      := ::ccodigoImpuesto
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Tributos
	Local cSoap := ""
	cSoap += WSSoapValue("codigoImpuesto", ::ccodigoImpuesto, ::ccodigoImpuesto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure Obligaciones

WSSTRUCT Service_Obligaciones
	WSDATA   oWSextras                 AS Service_ArrayOfExtensible OPTIONAL
	WSDATA   cobligaciones             AS string OPTIONAL
	WSDATA   cregimen                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Obligaciones
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Obligaciones
Return

WSMETHOD CLONE WSCLIENT Service_Obligaciones
	Local oClone := Service_Obligaciones():NEW()
	oClone:oWSextras            := IIF(::oWSextras = NIL , NIL , ::oWSextras:Clone() )
	oClone:cobligaciones        := ::cobligaciones
	oClone:cregimen             := ::cregimen
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Obligaciones
	Local cSoap := ""
	cSoap += WSSoapValue("extras", ::oWSextras, ::oWSextras , "ArrayOfExtensible", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("obligaciones", ::cobligaciones, ::cobligaciones , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("regimen", ::cregimen, ::cregimen , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfLineaInformacionAdicional

WSSTRUCT Service_ArrayOfLineaInformacionAdicional
	WSDATA   oWSLineaInformacionAdicional AS Service_LineaInformacionAdicional OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfLineaInformacionAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfLineaInformacionAdicional
	::oWSLineaInformacionAdicional := {} // Array Of  Service_LINEAINFORMACIONADICIONAL():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfLineaInformacionAdicional
	Local oClone := Service_ArrayOfLineaInformacionAdicional():NEW()
	oClone:oWSLineaInformacionAdicional := NIL
	If ::oWSLineaInformacionAdicional <> NIL 
		oClone:oWSLineaInformacionAdicional := {}
		aEval( ::oWSLineaInformacionAdicional , { |x| aadd( oClone:oWSLineaInformacionAdicional , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfLineaInformacionAdicional
	Local cSoap := ""
	aEval( ::oWSLineaInformacionAdicional , {|x| cSoap := cSoap  +  WSSoapValue("LineaInformacionAdicional", x , x , "LineaInformacionAdicional", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure DatosPacienteSalud

WSSTRUCT Service_DatosPacienteSalud
	WSDATA   oWSCamposGenerales        AS Service_ArrayOfGeneralSalud OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DatosPacienteSalud
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DatosPacienteSalud
Return

WSMETHOD CLONE WSCLIENT Service_DatosPacienteSalud
	Local oClone := Service_DatosPacienteSalud():NEW()
	oClone:oWSCamposGenerales   := IIF(::oWSCamposGenerales = NIL , NIL , ::oWSCamposGenerales:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_DatosPacienteSalud
	Local cSoap := ""
	cSoap += WSSoapValue("CamposGenerales", ::oWSCamposGenerales, ::oWSCamposGenerales , "ArrayOfGeneralSalud", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfExtrasEvento

WSSTRUCT Service_ArrayOfExtrasEvento
	WSDATA   oWSExtrasEvento           AS Service_ExtrasEvento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfExtrasEvento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfExtrasEvento
	::oWSExtrasEvento      := {} // Array Of  Service_EXTRASEVENTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfExtrasEvento
	Local oClone := Service_ArrayOfExtrasEvento():NEW()
	oClone:oWSExtrasEvento := NIL
	If ::oWSExtrasEvento <> NIL 
		oClone:oWSExtrasEvento := {}
		aEval( ::oWSExtrasEvento , { |x| aadd( oClone:oWSExtrasEvento , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ArrayOfExtrasEvento
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EXTRASEVENTO","ExtrasEvento",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSExtrasEvento , Service_ExtrasEvento():New() )
			::oWSExtrasEvento[len(::oWSExtrasEvento)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Coordenadas

WSSTRUCT Service_Coordenadas
	WSDATA   cgradosLatitud            AS string OPTIONAL
	WSDATA   cgradosLongitud           AS string OPTIONAL
	WSDATA   cminutosLatitud           AS string OPTIONAL
	WSDATA   cminutosLongitud          AS string OPTIONAL
	WSDATA   corientacionLatitud       AS string OPTIONAL
	WSDATA   corientacionLongitud      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Coordenadas
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Coordenadas
Return

WSMETHOD CLONE WSCLIENT Service_Coordenadas
	Local oClone := Service_Coordenadas():NEW()
	oClone:cgradosLatitud       := ::cgradosLatitud
	oClone:cgradosLongitud      := ::cgradosLongitud
	oClone:cminutosLatitud      := ::cminutosLatitud
	oClone:cminutosLongitud     := ::cminutosLongitud
	oClone:corientacionLatitud  := ::corientacionLatitud
	oClone:corientacionLongitud := ::corientacionLongitud
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Coordenadas
	Local cSoap := ""
	cSoap += WSSoapValue("gradosLatitud", ::cgradosLatitud, ::cgradosLatitud , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("gradosLongitud", ::cgradosLongitud, ::cgradosLongitud , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("minutosLatitud", ::cminutosLatitud, ::cminutosLatitud , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("minutosLongitud", ::cminutosLongitud, ::cminutosLongitud , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("orientacionLatitud", ::corientacionLatitud, ::corientacionLatitud , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("orientacionLongitud", ::corientacionLongitud, ::corientacionLongitud , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure LineaInformacionAdicional

WSSTRUCT Service_LineaInformacionAdicional
	WSDATA   ccantidad                 AS string OPTIONAL
	WSDATA   ccodigo                   AS string OPTIONAL
	WSDATA   ccodigoInterno1           AS string OPTIONAL
	WSDATA   ccodigoInterno2           AS string OPTIONAL
	WSDATA   cdescripcion              AS string OPTIONAL
	WSDATA   cfechaFin                 AS string OPTIONAL
	WSDATA   cfechaInicio              AS string OPTIONAL
	WSDATA   cnombre                   AS string OPTIONAL
	WSDATA   csecuencia                AS string OPTIONAL
	WSDATA   ctipo                     AS string OPTIONAL
	WSDATA   cunidadMedidaTransporte   AS string OPTIONAL
	WSDATA   cvalor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_LineaInformacionAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_LineaInformacionAdicional
Return

WSMETHOD CLONE WSCLIENT Service_LineaInformacionAdicional
	Local oClone := Service_LineaInformacionAdicional():NEW()
	oClone:ccantidad            := ::ccantidad
	oClone:ccodigo              := ::ccodigo
	oClone:ccodigoInterno1      := ::ccodigoInterno1
	oClone:ccodigoInterno2      := ::ccodigoInterno2
	oClone:cdescripcion         := ::cdescripcion
	oClone:cfechaFin            := ::cfechaFin
	oClone:cfechaInicio         := ::cfechaInicio
	oClone:cnombre              := ::cnombre
	oClone:csecuencia           := ::csecuencia
	oClone:ctipo                := ::ctipo
	oClone:cunidadMedidaTransporte := ::cunidadMedidaTransporte
	oClone:cvalor               := ::cvalor
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_LineaInformacionAdicional
	Local cSoap := ""
	cSoap += WSSoapValue("cantidad", ::ccantidad, ::ccantidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigo", ::ccodigo, ::ccodigo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoInterno1", ::ccodigoInterno1, ::ccodigoInterno1 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("codigoInterno2", ::ccodigoInterno2, ::ccodigoInterno2 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("descripcion", ::cdescripcion, ::cdescripcion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaFin", ::cfechaFin, ::cfechaFin , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("fechaInicio", ::cfechaInicio, ::cfechaInicio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombre", ::cnombre, ::cnombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("secuencia", ::csecuencia, ::csecuencia , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipo", ::ctipo, ::ctipo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("unidadMedidaTransporte", ::cunidadMedidaTransporte, ::cunidadMedidaTransporte , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("valor", ::cvalor, ::cvalor , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfGeneralSalud

WSSTRUCT Service_ArrayOfGeneralSalud
	WSDATA   oWSGeneralSalud           AS Service_GeneralSalud OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfGeneralSalud
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfGeneralSalud
	::oWSGeneralSalud      := {} // Array Of  Service_GENERALSALUD():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfGeneralSalud
	Local oClone := Service_ArrayOfGeneralSalud():NEW()
	oClone:oWSGeneralSalud := NIL
	If ::oWSGeneralSalud <> NIL 
		oClone:oWSGeneralSalud := {}
		aEval( ::oWSGeneralSalud , { |x| aadd( oClone:oWSGeneralSalud , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfGeneralSalud
	Local cSoap := ""
	aEval( ::oWSGeneralSalud , {|x| cSoap := cSoap  +  WSSoapValue("GeneralSalud", x , x , "GeneralSalud", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ExtrasEvento

WSSTRUCT Service_ExtrasEvento
	WSDATA   ccodigoInterno1           AS string OPTIONAL
	WSDATA   ccodigoInterno2           AS string OPTIONAL
	WSDATA   cnombre                   AS string OPTIONAL
	WSDATA   cvalor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ExtrasEvento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ExtrasEvento
Return

WSMETHOD CLONE WSCLIENT Service_ExtrasEvento
	Local oClone := Service_ExtrasEvento():NEW()
	oClone:ccodigoInterno1      := ::ccodigoInterno1
	oClone:ccodigoInterno2      := ::ccodigoInterno2
	oClone:cnombre              := ::cnombre
	oClone:cvalor               := ::cvalor
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ExtrasEvento
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodigoInterno1    :=  WSAdvValue( oResponse,"_CODIGOINTERNO1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccodigoInterno2    :=  WSAdvValue( oResponse,"_CODIGOINTERNO2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnombre            :=  WSAdvValue( oResponse,"_NOMBRE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure GeneralSalud

WSSTRUCT Service_GeneralSalud
	WSDATA   cNombre                   AS string OPTIONAL
	WSDATA   cValor                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_GeneralSalud
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_GeneralSalud
Return

WSMETHOD CLONE WSCLIENT Service_GeneralSalud
	Local oClone := Service_GeneralSalud():NEW()
	oClone:cNombre              := ::cNombre
	oClone:cValor               := ::cValor
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_GeneralSalud
	Local cSoap := ""
	cSoap += WSSoapValue("Nombre", ::cNombre, ::cNombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("Valor", ::cValor, ::cValor , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
Return cSoap


