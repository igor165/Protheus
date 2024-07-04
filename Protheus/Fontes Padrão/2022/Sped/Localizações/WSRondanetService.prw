#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    https://cfe.rondanet.com:50901/CFERondanetServerGamaitalyTest/WebServices?wsdl
Generado en        03/06/17 14:11:24
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _QYQRJLS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRondanetService
------------------------------------------------------------------------------- */

WSCLIENT WSRondanetService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD obtenerNumeracionComprobante
	WSMETHOD obtenerComprobantesRechazadosDGIRecibidos
	WSMETHOD obtenerTextoQR
	WSMETHOD obtenerImagenQR
	WSMETHOD obtenerEstadoComprobanteDGI
	WSMETHOD obtenerComprobantesRecibidos
	WSMETHOD obtenerEstadoReporteDiario
	WSMETHOD obtenerRepresentacionImpresa
	WSMETHOD verificarConexion
	WSMETHOD obtenerEstadoReporteDiarioAutomatico
	WSMETHOD obtenerEstadoComprobanteRecibido
	WSMETHOD solicitarRangoCAE
	WSMETHOD enviarComprobante
	WSMETHOD enviarNumerosAnulados
	WSMETHOD imprimirCFE
	WSMETHOD enviarResumenReporteDiario
	WSMETHOD obtenerUsuario
	WSMETHOD enviarConjuntoComprobante
	WSMETHOD enviarAlarmas
	WSMETHOD obtenerDatosComprobante

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   crutEmisor                AS string
	WSDATA   cusuario                  AS string
	WSDATA   cpassword                 AS string
	WSDATA   ntipoComprobante          AS int
	WSDATA   cserieInterno             AS string
	WSDATA   nnumeroInterno            AS long
	WSDATA   creturn                   AS string
	WSDATA   cfechaRecibidoDesde       AS string
	WSDATA   cfechaRecibidoHasta       AS string
	WSDATA   cserie                    AS string
	WSDATA   nnumeroComprobante        AS int
	WSDATA   cformatoImagen            AS string
	WSDATA   cfecha                    AS string
	WSDATA   nsecuencia                AS int
	WSDATA   calias                    AS string
	WSDATA   ncantidad                 AS int
	WSDATA   ccomprobante              AS string
	WSDATA   cnumerosAnulados          AS string
	WSDATA   crutEmisorCFE             AS string
	WSDATA   nnumero                   AS long
	WSDATA   linterno                  AS boolean
	WSDATA   cimpresora                AS string
	WSDATA   ncantCopias               AS int
	WSDATA   cresumen                  AS string
	WSDATA   cidFormato                AS string
	WSDATA   calarmas                  AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRondanetService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20161027] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRondanetService
Return

WSMETHOD RESET WSCLIENT WSRondanetService
	::crutEmisor         := NIL 
	::cusuario           := NIL 
	::cpassword          := NIL 
	::ntipoComprobante   := NIL 
	::cserieInterno      := NIL 
	::nnumeroInterno     := NIL 
	::creturn            := NIL 
	::cfechaRecibidoDesde := NIL 
	::cfechaRecibidoHasta := NIL 
	::cserie             := NIL 
	::nnumeroComprobante := NIL 
	::cformatoImagen     := NIL 
	::cfecha             := NIL 
	::nsecuencia         := NIL 
	::calias             := NIL 
	::ncantidad          := NIL 
	::ccomprobante       := NIL 
	::cnumerosAnulados   := NIL 
	::crutEmisorCFE      := NIL 
	::nnumero            := NIL 
	::linterno           := NIL 
	::cimpresora         := NIL 
	::ncantCopias        := NIL 
	::cresumen           := NIL 
	::cidFormato         := NIL 
	::calarmas           := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRondanetService
Local oClone := WSRondanetService():New()
	oClone:_URL          := ::_URL 
	oClone:crutEmisor    := ::crutEmisor
	oClone:cusuario      := ::cusuario
	oClone:cpassword     := ::cpassword
	oClone:ntipoComprobante := ::ntipoComprobante
	oClone:cserieInterno := ::cserieInterno
	oClone:nnumeroInterno := ::nnumeroInterno
	oClone:creturn       := ::creturn
	oClone:cfechaRecibidoDesde := ::cfechaRecibidoDesde
	oClone:cfechaRecibidoHasta := ::cfechaRecibidoHasta
	oClone:cserie        := ::cserie
	oClone:nnumeroComprobante := ::nnumeroComprobante
	oClone:cformatoImagen := ::cformatoImagen
	oClone:cfecha        := ::cfecha
	oClone:nsecuencia    := ::nsecuencia
	oClone:calias        := ::calias
	oClone:ncantidad     := ::ncantidad
	oClone:ccomprobante  := ::ccomprobante
	oClone:cnumerosAnulados := ::cnumerosAnulados
	oClone:crutEmisorCFE := ::crutEmisorCFE
	oClone:nnumero       := ::nnumero
	oClone:linterno      := ::linterno
	oClone:cimpresora    := ::cimpresora
	oClone:ncantCopias   := ::ncantCopias
	oClone:cresumen      := ::cresumen
	oClone:cidFormato    := ::cidFormato
	oClone:calarmas      := ::calarmas
Return oClone

// WSDL Method obtenerNumeracionComprobante of Service WSRondanetService

WSMETHOD obtenerNumeracionComprobante WSSEND crutEmisor,cusuario,cpassword,ntipoComprobante,cserieInterno,nnumeroInterno WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerNumeracionComprobante xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("serieInterno", ::cserieInterno, cserieInterno , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numeroInterno", ::nnumeroInterno, nnumeroInterno , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerNumeracionComprobante>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERNUMERACIONCOMPROBANTERESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerComprobantesRechazadosDGIRecibidos of Service WSRondanetService

WSMETHOD obtenerComprobantesRechazadosDGIRecibidos WSSEND crutEmisor,cusuario,cpassword,cfechaRecibidoDesde,cfechaRecibidoHasta WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerComprobantesRechazadosDGIRecibidos xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("fechaRecibidoDesde", ::cfechaRecibidoDesde, cfechaRecibidoDesde , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("fechaRecibidoHasta", ::cfechaRecibidoHasta, cfechaRecibidoHasta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerComprobantesRechazadosDGIRecibidos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERCOMPROBANTESRECHAZADOSDGIRECIBIDOSRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerTextoQR of Service WSRondanetService

WSMETHOD obtenerTextoQR WSSEND crutEmisor,cusuario,cpassword,ntipoComprobante,cserie,nnumeroComprobante WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerTextoQR xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("serie", ::cserie, cserie , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numeroComprobante", ::nnumeroComprobante, nnumeroComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerTextoQR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERTEXTOQRRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerImagenQR of Service WSRondanetService

WSMETHOD obtenerImagenQR WSSEND crutEmisor,cusuario,cpassword,ntipoComprobante,cserie,nnumeroComprobante,cformatoImagen WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerImagenQR xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("serie", ::cserie, cserie , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numeroComprobante", ::nnumeroComprobante, nnumeroComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("formatoImagen", ::cformatoImagen, cformatoImagen , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerImagenQR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERIMAGENQRRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerEstadoComprobanteDGI of Service WSRondanetService

WSMETHOD obtenerEstadoComprobanteDGI WSSEND crutEmisor,cusuario,cpassword,ntipoComprobante,cserie,nnumeroComprobante WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<tns:obtenerEstadoComprobanteDGI>'  // xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("serie", ::cserie, cserie , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numeroComprobante", ::nnumeroComprobante, nnumeroComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += "</tns:obtenerEstadoComprobanteDGI>"

//oXmlRet := SvcSoapCall(	Self,cSoap,; 
//	"",; 
//	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
//	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")
  

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")



::Init()
//::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERESTADOCOMPROBANTEDGIRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 
::creturn            := WSAdvValue( oXmlRet,"_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 
END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerComprobantesRecibidos of Service WSRondanetService

WSMETHOD obtenerComprobantesRecibidos WSSEND crutEmisor,cusuario,cpassword,cfechaRecibidoDesde,cfechaRecibidoHasta WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerComprobantesRecibidos xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("fechaRecibidoDesde", ::cfechaRecibidoDesde, cfechaRecibidoDesde , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("fechaRecibidoHasta", ::cfechaRecibidoHasta, cfechaRecibidoHasta , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerComprobantesRecibidos>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERCOMPROBANTESRECIBIDOSRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerEstadoReporteDiario of Service WSRondanetService

WSMETHOD obtenerEstadoReporteDiario WSSEND crutEmisor,cusuario,cpassword,cfecha,nsecuencia WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerEstadoReporteDiario xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("fecha", ::cfecha, cfecha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("secuencia", ::nsecuencia, nsecuencia , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerEstadoReporteDiario>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERESTADOREPORTEDIARIORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerRepresentacionImpresa of Service WSRondanetService

WSMETHOD obtenerRepresentacionImpresa WSSEND crutEmisor,cusuario,cpassword,ntipoComprobante,cserie,nnumeroComprobante WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

WSDLSaveXML(.T.)

BEGIN WSMETHOD

cSoap += '<tns:obtenerRepresentacionImpresa>'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("serie", ::cserie, cserie , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numeroComprobante", ::nnumeroComprobante, nnumeroComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += "</tns:obtenerRepresentacionImpresa>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method verificarConexion of Service WSRondanetService

WSMETHOD verificarConexion WSSEND crutEmisor,calias,cusuario,cpassword WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<verificarConexion xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</verificarConexion>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_VERIFICARCONEXIONRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerEstadoReporteDiarioAutomatico of Service WSRondanetService

WSMETHOD obtenerEstadoReporteDiarioAutomatico WSSEND crutEmisor,calias,cusuario,cpassword,cfecha WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerEstadoReporteDiarioAutomatico xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("fecha", ::cfecha, cfecha , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerEstadoReporteDiarioAutomatico>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERESTADOREPORTEDIARIOAUTOMATICORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerEstadoComprobanteRecibido of Service WSRondanetService

WSMETHOD obtenerEstadoComprobanteRecibido WSSEND crutEmisor,cusuario,cpassword,ntipoComprobante,cserie,nnumeroComprobante WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerEstadoComprobanteRecibido xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("serie", ::cserie, cserie , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numeroComprobante", ::nnumeroComprobante, nnumeroComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerEstadoComprobanteRecibido>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERESTADOCOMPROBANTERECIBIDORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method solicitarRangoCAE of Service WSRondanetService

WSMETHOD solicitarRangoCAE WSSEND crutEmisor,calias,cusuario,cpassword,ntipoComprobante,ncantidad WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<solicitarRangoCAE xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cantidad", ::ncantidad, ncantidad , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += "</solicitarRangoCAE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_SOLICITARRANGOCAERESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviarComprobante of Service WSRondanetService

WSMETHOD enviarComprobante WSSEND crutEmisor,calias,cusuario,cpassword,ccomprobante WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

WSDLSaveXML(.T.)

BEGIN WSMETHOD

cSoap += '<tns:enviarComprobante>'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("comprobante", ::ccomprobante, ccomprobante , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</tns:enviarComprobante>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            := WSAdvValue( oXmlRet,"_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") //WSAdvValue( oXmlRet,"_ENVIARCOMPROBANTERESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviarNumerosAnulados of Service WSRondanetService

WSMETHOD enviarNumerosAnulados WSSEND crutEmisor,calias,cusuario,cpassword,cnumerosAnulados WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<enviarNumerosAnulados xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numerosAnulados", ::cnumerosAnulados, cnumerosAnulados , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</enviarNumerosAnulados>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_ENVIARNUMEROSANULADOSRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method imprimirCFE of Service WSRondanetService

WSMETHOD imprimirCFE WSSEND crutEmisor,cusuario,cpassword,crutEmisorCFE,ntipoComprobante,cserie,nnumero,linterno,cimpresora,ncantCopias WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<imprimirCFE xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("rutEmisorCFE", ::crutEmisorCFE, crutEmisorCFE , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("serie", ::cserie, cserie , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numero", ::nnumero, nnumero , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("interno", ::linterno, linterno , "boolean", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("impresora", ::cimpresora, cimpresora , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("cantCopias", ::ncantCopias, ncantCopias , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += "</imprimirCFE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_IMPRIMIRCFERESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviarResumenReporteDiario of Service WSRondanetService

WSMETHOD enviarResumenReporteDiario WSSEND crutEmisor,calias,cusuario,cpassword,cresumen WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<enviarResumenReporteDiario xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("resumen", ::cresumen, cresumen , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</enviarResumenReporteDiario>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_ENVIARRESUMENREPORTEDIARIORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerUsuario of Service WSRondanetService

WSMETHOD obtenerUsuario WSSEND crutEmisor,calias,cusuario,cpassword WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerUsuario xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerUsuario>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERUSUARIORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviarConjuntoComprobante of Service WSRondanetService

WSMETHOD enviarConjuntoComprobante WSSEND crutEmisor,calias,cusuario,cpassword,cidFormato,ccomprobante WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<enviarConjuntoComprobante xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("idFormato", ::cidFormato, cidFormato , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("comprobante", ::ccomprobante, ccomprobante , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</enviarConjuntoComprobante>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_ENVIARCONJUNTOCOMPROBANTERESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method enviarAlarmas of Service WSRondanetService

WSMETHOD enviarAlarmas WSSEND crutEmisor,calias,cusuario,cpassword,calarmas WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<enviarAlarmas xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alarmas", ::calarmas, calarmas , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</enviarAlarmas>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_ENVIARALARMASRESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method obtenerDatosComprobante of Service WSRondanetService

WSMETHOD obtenerDatosComprobante WSSEND crutEmisor,calias,cusuario,cpassword,ntipoComprobante,cserie,nnumero,linterno WSRECEIVE creturn WSCLIENT WSRondanetService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<obtenerDatosComprobante xmlns="http://ws.rondanet.gs1uy.org">'
cSoap += WSSoapValue("rutEmisor", ::crutEmisor, crutEmisor , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("alias", ::calias, calias , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("tipoComprobante", ::ntipoComprobante, ntipoComprobante , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("serie", ::cserie, cserie , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("numero", ::nnumero, nnumero , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("interno", ::linterno, linterno , "boolean", .F. , .F., 0 , NIL, .F.) 
cSoap += "</obtenerDatosComprobante>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.rondanet.gs1uy.org",,,; 
	"http://localhost:40901/CFERondanetServerGamaitalyTest/WebServices")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_OBTENERDATOSCOMPROBANTERESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"tns") 

END WSMETHOD

oXmlRet := NIL
Return .T.