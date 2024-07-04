#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://demo-nomina-soap.thefactoryhka.com.co/Service.svc?wsdl
Generado en        30/09/21 16:44:40
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _ENLZIHM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNominaCol
------------------------------------------------------------------------------- */

WSCLIENT WSNominaCol

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Enviar
	WSMETHOD FoliosRestantes
	WSMETHOD EstadoDocumento
	WSMETHOD DescargaXML
	WSMETHOD DescargaPDF
	WSMETHOD EnvioCorreo

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSrequest                AS Service_Request
	WSDATA   oWSrequestConsultarDocumento AS Service_RequestConsultarDocumento
	WSDATA   oWSEnviarResult           AS Service_Response
	WSDATA   oWSFoliosRestantesResult  AS Service_ResponseFoliosRemaining
	WSDATA   oWSEstadoDocumentoResult  AS Service_ResponseStatusDocument
	WSDATA   oWSDescargaXMLResult      AS Service_ResponseDownloadDocument
	WSDATA   oWSDescargaPDFResult      AS Service_ResponseDownloadDocument
	WSDATA   oWSEnvioCorreoResult      AS Service_ResponseSendEmail

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNominaCol
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20210522] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNominaCol
	::oWSrequest         := Service_REQUEST():New()
	::oWSrequestConsultarDocumento := Service_RequestConsultarDocumento():New()
	::oWSEnviarResult    := Service_RESPONSE():New()
	::oWSFoliosRestantesResult := Service_RESPONSEFOLIOSREMAINING():New()
	::oWSEstadoDocumentoResult := Service_RESPONSESTATUSDOCUMENT():New()
	::oWSDescargaXMLResult := Service_RESPONSEDOWNLOADDOCUMENT():New()
	::oWSDescargaPDFResult := Service_RESPONSEDOWNLOADDOCUMENT():New()
	::oWSEnvioCorreoResult := Service_RESPONSESENDEMAIL():New()
Return

WSMETHOD RESET WSCLIENT WSNominaCol
	::oWSrequest         := NIL
	::oWSrequestConsultarDocumento  := NIL 
	::oWSEnviarResult    := NIL 
	::oWSFoliosRestantesResult := NIL 
	::oWSEstadoDocumentoResult := NIL 
	::oWSDescargaXMLResult := NIL 
	::oWSDescargaPDFResult := NIL 
	::oWSEnvioCorreoResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNominaCol
Local oClone := WSNominaCol():New()
	oClone:_URL          := ::_URL 
	oClone:oWSrequest    :=  IIF(::oWSrequest = NIL , NIL ,::oWSrequest:Clone() )
	oClone:oWSrequestConsultarDocumento    :=  IIF(::oWSrequestConsultarDocumento = NIL , NIL ,::oWSrequestConsultarDocumento:Clone() )
	oClone:oWSEnviarResult :=  IIF(::oWSEnviarResult = NIL , NIL ,::oWSEnviarResult:Clone() )
	oClone:oWSFoliosRestantesResult :=  IIF(::oWSFoliosRestantesResult = NIL , NIL ,::oWSFoliosRestantesResult:Clone() )
	oClone:oWSEstadoDocumentoResult :=  IIF(::oWSEstadoDocumentoResult = NIL , NIL ,::oWSEstadoDocumentoResult:Clone() )
	oClone:oWSDescargaXMLResult :=  IIF(::oWSDescargaXMLResult = NIL , NIL ,::oWSDescargaXMLResult:Clone() )
	oClone:oWSDescargaPDFResult :=  IIF(::oWSDescargaPDFResult = NIL , NIL ,::oWSDescargaPDFResult:Clone() )
	oClone:oWSEnvioCorreoResult :=  IIF(::oWSEnvioCorreoResult = NIL , NIL ,::oWSEnvioCorreoResult:Clone() )
Return oClone

// WSDL Method Enviar of Service WSNominaCol

WSMETHOD Enviar WSSEND oWSrequest WSRECEIVE oWSEnviarResult WSCLIENT WSNominaCol
Local cSoap := "" , oXmlRet
Local cCFDICON := GetMv( "MV_SOAPFE" , .F. ,  "")

BEGIN WSMETHOD

If cCFDICON == "1"
	varinfo('prueba objeto', ::oWSrequest)
EndIf

cSoap += '<Enviar xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("request", ::oWSrequest, oWSrequest , "Request", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</Enviar>"

If cCFDICON == "1"
	conout("WSNominaCol:WSEnviar: " + cSoap)
EndIf

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/Enviar",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demo-nomina-soap.thefactoryhka.com.co/Service.svc")

::Init()
::oWSEnviarResult:SoapRecv( WSAdvValue( oXmlRet,"_ENVIARRESPONSE:_ENVIARRESULT","Response",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method FoliosRestantes of Service WSNominaCol

WSMETHOD FoliosRestantes WSSEND oWSrequest WSRECEIVE oWSFoliosRestantesResult WSCLIENT WSNominaCol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<FoliosRestantes xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("request", ::oWSrequest, oWSrequest , "RequestConsultar", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</FoliosRestantes>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/FoliosRestantes",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demo-nomina-soap.thefactoryhka.com.co/Service.svc")

::Init()
::oWSFoliosRestantesResult:SoapRecv( WSAdvValue( oXmlRet,"_FOLIOSRESTANTESRESPONSE:_FOLIOSRESTANTESRESULT","ResponseFoliosRemaining",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EstadoDocumento of Service WSNominaCol

WSMETHOD EstadoDocumento WSSEND oWSrequestConsultarDocumento WSRECEIVE oWSEstadoDocumentoResult WSCLIENT WSNominaCol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EstadoDocumento xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("request", ::oWSrequestConsultarDocumento, oWSrequestConsultarDocumento , "RequestConsultarDocumento", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</EstadoDocumento>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/EstadoDocumento",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demo-nomina-soap.thefactoryhka.com.co/Service.svc")

::Init()
::oWSEstadoDocumentoResult:SoapRecv( WSAdvValue( oXmlRet,"_ESTADODOCUMENTORESPONSE:_ESTADODOCUMENTORESULT","ResponseStatusDocument",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DescargaXML of Service WSNominaCol

WSMETHOD DescargaXML WSSEND oWSrequestConsultarDocumento WSRECEIVE oWSDescargaXMLResult WSCLIENT WSNominaCol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DescargaXML xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("request", ::oWSrequestConsultarDocumento, oWSrequestConsultarDocumento , "RequestConsultarDocumento", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</DescargaXML>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/DescargaXML",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demo-nomina-soap.thefactoryhka.com.co/Service.svc")

::Init()
::oWSDescargaXMLResult:SoapRecv( WSAdvValue( oXmlRet,"_DESCARGAXMLRESPONSE:_DESCARGAXMLRESULT","ResponseDownloadDocument",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DescargaPDF of Service WSNominaCol

WSMETHOD DescargaPDF WSSEND oWSrequestConsultarDocumento WSRECEIVE oWSDescargaPDFResult WSCLIENT WSNominaCol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DescargaPDF xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("request", ::oWSrequestConsultarDocumento, oWSrequestConsultarDocumento , "RequestConsultarDocumento", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</DescargaPDF>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/DescargaPDF",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demo-nomina-soap.thefactoryhka.com.co/Service.svc")

::Init()
::oWSDescargaPDFResult:SoapRecv( WSAdvValue( oXmlRet,"_DESCARGAPDFRESPONSE:_DESCARGAPDFRESULT","ResponseDownloadDocument",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EnvioCorreo of Service WSNominaCol

WSMETHOD EnvioCorreo WSSEND oWSrequest WSRECEIVE oWSEnvioCorreoResult WSCLIENT WSNominaCol
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EnvioCorreo xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("request", ::oWSrequest, oWSrequest , "RequestEnviarCorreo", .F. , .F., 0 , "http://tempuri.org/", .F.,.F.) 
cSoap += "</EnvioCorreo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/EnvioCorreo",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demo-nomina-soap.thefactoryhka.com.co/Service.svc")

::Init()
::oWSEnvioCorreoResult:SoapRecv( WSAdvValue( oXmlRet,"_ENVIOCORREORESPONSE:_ENVIOCORREORESULT","ResponseSendEmail",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.



/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
//AGREGADO
// WSDL Data Structure Request document 

WSSTRUCT Service_RequestConsultarDocumento
	WSDATA   cconsecutivoDocumentoNom   AS string OPTIONAL
	WSDATA   ctokenEnterprise          AS string OPTIONAL
	WSDATA   ctokenPassword            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_RequestConsultarDocumento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_RequestConsultarDocumento
Return

WSMETHOD CLONE WSCLIENT Service_RequestConsultarDocumento
	Local oClone := Service_RequestConsultarDocumento():NEW()
	oClone:cconsecutivoDocumentoNom        := ::cconsecutivoDocumentoNom
	oClone:ctokenEnterprise     := ::ctokenEnterprise
	oClone:ctokenPassword       := ::ctokenPassword
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_RequestConsultarDocumento
	Local cSoap := ""
	cSoap += WSSoapValue("consecutivoDocumentoNom", ::cconsecutivoDocumentoNom, ::cconsecutivoDocumentoNom , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Request", .F.,.F.) 
	cSoap += WSSoapValue("tokenEnterprise", ::ctokenEnterprise, ::ctokenEnterprise , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Request", .F.,.F.) 
	cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ::ctokenPassword , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Request", .F.,.F.) 
Return cSoap


/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////




// WSDL Data Structure Request

WSSTRUCT Service_Request
	WSDATA   cidSoftware               AS string OPTIONAL
	WSDATA   cnitEmpleador             AS string OPTIONAL
	WSDATA   oWSnomina                 AS Service_NominaGeneral OPTIONAL
	WSDATA   ctokenEnterprise          AS string OPTIONAL
	WSDATA   ctokenPassword            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Request
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Request
Return

WSMETHOD CLONE WSCLIENT Service_Request
	Local oClone := Service_Request():NEW()
	oClone:cidSoftware          := ::cidSoftware
	oClone:cnitEmpleador        := ::cnitEmpleador
	oClone:oWSnomina            := IIF(::oWSnomina = NIL , NIL , ::oWSnomina:Clone() )
	oClone:ctokenEnterprise     := ::ctokenEnterprise
	oClone:ctokenPassword       := ::ctokenPassword
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Request
	Local cSoap := ""
	cSoap += WSSoapValue("idSoftware", ::cidSoftware, ::cidSoftware , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Request", .F.,.F.) 
	cSoap += WSSoapValue("nitEmpleador", ::cnitEmpleador, ::cnitEmpleador , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Request", .F.,.F.) 
	cSoap += WSSoapValue("nomina", ::oWSnomina, ::oWSnomina , "NominaGeneral", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Request", .F.,.F.) 
	cSoap += WSSoapValue("tokenEnterprise", ::ctokenEnterprise, ::ctokenEnterprise , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Request", .F.,.F.) 
	cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ::ctokenPassword , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Request", .F.,.F.) 
Return cSoap

// WSDL Data Structure Response

WSSTRUCT Service_Response
	WSDATA   ccodigo                   AS string OPTIONAL
	WSDATA   cconsecutivoDocumento     AS string OPTIONAL
	WSDATA   ccune                     AS string OPTIONAL
	WSDATA   lesvalidoDIAN             AS boolean OPTIONAL
	WSDATA   cidSoftware               AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cnitEmpleado              AS string OPTIONAL
	WSDATA   cnitEmpleador             AS string OPTIONAL
	WSDATA   cqr                       AS string OPTIONAL
	WSDATA   oWSreglasNotificacionesDIAN AS Service_ArrayOfstring OPTIONAL
	WSDATA   oWSreglasNotificacionesTFHKA AS Service_ArrayOfstring OPTIONAL
	WSDATA   oWSreglasRechazoDIAN      AS Service_ArrayOfstring OPTIONAL
	WSDATA   oWSreglasRechazoTFHKA     AS Service_ArrayOfstring OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctrackId                  AS string OPTIONAL
	WSDATA   cxml                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Response
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Response
Return

WSMETHOD CLONE WSCLIENT Service_Response
	Local oClone := Service_Response():NEW()
	oClone:ccodigo              := ::ccodigo
	oClone:cconsecutivoDocumento := ::cconsecutivoDocumento
	oClone:ccune                := ::ccune
	oClone:lesvalidoDIAN        := ::lesvalidoDIAN
	oClone:cidSoftware          := ::cidSoftware
	oClone:cmensaje             := ::cmensaje
	oClone:cnitEmpleado         := ::cnitEmpleado
	oClone:cnitEmpleador        := ::cnitEmpleador
	oClone:cqr                  := ::cqr
	oClone:oWSreglasNotificacionesDIAN := IIF(::oWSreglasNotificacionesDIAN = NIL , NIL , ::oWSreglasNotificacionesDIAN:Clone() )
	oClone:oWSreglasNotificacionesTFHKA := IIF(::oWSreglasNotificacionesTFHKA = NIL , NIL , ::oWSreglasNotificacionesTFHKA:Clone() )
	oClone:oWSreglasRechazoDIAN := IIF(::oWSreglasRechazoDIAN = NIL , NIL , ::oWSreglasRechazoDIAN:Clone() )
	oClone:oWSreglasRechazoTFHKA := IIF(::oWSreglasRechazoTFHKA = NIL , NIL , ::oWSreglasRechazoTFHKA:Clone() )
	oClone:cresultado           := ::cresultado
	oClone:ctrackId             := ::ctrackId
	oClone:cxml                 := ::cxml
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_Response
	Local oNode10
	Local oNode11
	Local oNode12
	Local oNode13
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cconsecutivoDocumento :=  WSAdvValue( oResponse,"_CONSECUTIVODOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccune              :=  WSAdvValue( oResponse,"_CUNE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lesvalidoDIAN      :=  WSAdvValue( oResponse,"_ESVALIDODIAN","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cidSoftware        :=  WSAdvValue( oResponse,"_IDSOFTWARE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnitEmpleado       :=  WSAdvValue( oResponse,"_NITEMPLEADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnitEmpleador      :=  WSAdvValue( oResponse,"_NITEMPLEADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cqr                :=  WSAdvValue( oResponse,"_QR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode10 :=  WSAdvValue( oResponse,"_REGLASNOTIFICACIONESDIAN","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSreglasNotificacionesDIAN := Service_ArrayOfstring():New()
		::oWSreglasNotificacionesDIAN:SoapRecv(oNode10)
	EndIf
	oNode11 :=  WSAdvValue( oResponse,"_REGLASNOTIFICACIONESTFHKA","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWSreglasNotificacionesTFHKA := Service_ArrayOfstring():New()
		::oWSreglasNotificacionesTFHKA:SoapRecv(oNode11)
	EndIf
	oNode12 :=  WSAdvValue( oResponse,"_REGLASRECHAZODIAN","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWSreglasRechazoDIAN := Service_ArrayOfstring():New()
		::oWSreglasRechazoDIAN:SoapRecv(oNode12)
	EndIf
	oNode13 :=  WSAdvValue( oResponse,"_REGLASRECHAZOTFHKA","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWSreglasRechazoTFHKA := Service_ArrayOfstring():New()
		::oWSreglasRechazoTFHKA:SoapRecv(oNode13)
	EndIf
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctrackId           :=  WSAdvValue( oResponse,"_TRACKID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cxml               :=  WSAdvValue( oResponse,"_XML","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ResponseFoliosRemaining

WSSTRUCT Service_ResponseFoliosRemaining
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   nfoliosRestantes          AS int OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ResponseFoliosRemaining
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ResponseFoliosRemaining
Return

WSMETHOD CLONE WSCLIENT Service_ResponseFoliosRemaining
	Local oClone := Service_ResponseFoliosRemaining():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:nfoliosRestantes     := ::nfoliosRestantes
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ResponseFoliosRemaining
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::nfoliosRestantes   :=  WSAdvValue( oResponse,"_FOLIOSRESTANTES","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ResponseStatusDocument

WSSTRUCT Service_ResponseStatusDocument
	WSDATA   cambiente                 AS string OPTIONAL
	WSDATA   ccadenaCodigoQR           AS string OPTIONAL
	WSDATA   ccadenaCune               AS string OPTIONAL
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cconsecutivo              AS string OPTIONAL
	WSDATA   ccune                     AS string OPTIONAL
	WSDATA   cdescripcionDocumento     AS string OPTIONAL
	WSDATA   cdescripcionEstatusDocumento AS string OPTIONAL
	WSDATA   lesValidoDIAN             AS boolean OPTIONAL
	WSDATA   nestatusDocumento         AS int OPTIONAL
	WSDATA   cfechaAceptacionDIAN      AS string OPTIONAL
	WSDATA   cfechaDocumento           AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cmensajeDocumento         AS string OPTIONAL
	WSDATA   oWSreglasValidacionDIAN   AS Service_ArrayOfstring OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSDATA   ctipoDocumento            AS string OPTIONAL
	WSDATA   ctrackID                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ResponseStatusDocument
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ResponseStatusDocument
Return

WSMETHOD CLONE WSCLIENT Service_ResponseStatusDocument
	Local oClone := Service_ResponseStatusDocument():NEW()
	oClone:cambiente            := ::cambiente
	oClone:ccadenaCodigoQR      := ::ccadenaCodigoQR
	oClone:ccadenaCune          := ::ccadenaCune
	oClone:ncodigo              := ::ncodigo
	oClone:cconsecutivo         := ::cconsecutivo
	oClone:ccune                := ::ccune
	oClone:cdescripcionDocumento := ::cdescripcionDocumento
	oClone:cdescripcionEstatusDocumento := ::cdescripcionEstatusDocumento
	oClone:lesValidoDIAN        := ::lesValidoDIAN
	oClone:nestatusDocumento    := ::nestatusDocumento
	oClone:cfechaAceptacionDIAN := ::cfechaAceptacionDIAN
	oClone:cfechaDocumento      := ::cfechaDocumento
	oClone:cmensaje             := ::cmensaje
	oClone:cmensajeDocumento    := ::cmensajeDocumento
	oClone:oWSreglasValidacionDIAN := IIF(::oWSreglasValidacionDIAN = NIL , NIL , ::oWSreglasValidacionDIAN:Clone() )
	oClone:cresultado           := ::cresultado
	oClone:ctipoDocumento       := ::ctipoDocumento
	oClone:ctrackID             := ::ctrackID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ResponseStatusDocument
	Local oNode15
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cambiente          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccadenaCodigoQR    :=  WSAdvValue( oResponse,"_CADENACODIGOQR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccadenaCune        :=  WSAdvValue( oResponse,"_CADENACUNE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cconsecutivo       :=  WSAdvValue( oResponse,"_CONSECUTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccune              :=  WSAdvValue( oResponse,"_CUNE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescripcionDocumento :=  WSAdvValue( oResponse,"_DESCRIPCIONDOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescripcionEstatusDocumento :=  WSAdvValue( oResponse,"_DESCRIPCIONESTATUSDOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lesValidoDIAN      :=  WSAdvValue( oResponse,"_ESVALIDODIAN","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nestatusDocumento  :=  WSAdvValue( oResponse,"_ESTATUSDOCUMENTO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cfechaAceptacionDIAN :=  WSAdvValue( oResponse,"_FECHAACEPTACIONDIAN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfechaDocumento    :=  WSAdvValue( oResponse,"_FECHADOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensajeDocumento  :=  WSAdvValue( oResponse,"_MENSAJEDOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode15 :=  WSAdvValue( oResponse,"_REGLASVALIDACIONDIAN","ArrayOfstring",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode15 != NIL
		::oWSreglasValidacionDIAN := Service_ArrayOfstring():New()
		::oWSreglasValidacionDIAN:SoapRecv(oNode15)
	EndIf
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctipoDocumento     :=  WSAdvValue( oResponse,"_TIPODOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctrackID           :=  WSAdvValue( oResponse,"_TRACKID","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ResponseDownloadDocument

WSSTRUCT Service_ResponseDownloadDocument
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   ccune                     AS string OPTIONAL
	WSDATA   cdocumento                AS string OPTIONAL
	WSDATA   chash                     AS string OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cnombre                   AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ResponseDownloadDocument
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ResponseDownloadDocument
Return

WSMETHOD CLONE WSCLIENT Service_ResponseDownloadDocument
	Local oClone := Service_ResponseDownloadDocument():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:ccune                := ::ccune
	oClone:cdocumento           := ::cdocumento
	oClone:chash                := ::chash
	oClone:cmensaje             := ::cmensaje
	oClone:cnombre              := ::cnombre
	oClone:cresultado           := ::cresultado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ResponseDownloadDocument
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::ccune              :=  WSAdvValue( oResponse,"_CUNE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdocumento         :=  WSAdvValue( oResponse,"_DOCUMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::chash              :=  WSAdvValue( oResponse,"_HASH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnombre            :=  WSAdvValue( oResponse,"_NOMBRE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ResponseSendEmail

WSSTRUCT Service_ResponseSendEmail
	WSDATA   ncodigo                   AS int OPTIONAL
	WSDATA   cmensaje                  AS string OPTIONAL
	WSDATA   cresultado                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ResponseSendEmail
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ResponseSendEmail
Return

WSMETHOD CLONE WSCLIENT Service_ResponseSendEmail
	Local oClone := Service_ResponseSendEmail():NEW()
	oClone:ncodigo              := ::ncodigo
	oClone:cmensaje             := ::cmensaje
	oClone:cresultado           := ::cresultado
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_ResponseSendEmail
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncodigo            :=  WSAdvValue( oResponse,"_CODIGO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cmensaje           :=  WSAdvValue( oResponse,"_MENSAJE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresultado         :=  WSAdvValue( oResponse,"_RESULTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure NominaGeneral

WSSTRUCT Service_NominaGeneral
	WSDATA   cconsecutivoDocumentoNom  AS string OPTIONAL
	WSDATA   oWSdeducciones            AS Service_Deduccion OPTIONAL
	WSDATA   oWSdevengados             AS Service_Devengado OPTIONAL
	WSDATA   oWSdocumentosReferenciadosNom AS Service_ArrayOfDocumentoReferenciadoNom OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cfechaEmisionNom          AS string OPTIONAL
	WSDATA   oWSlugarGeneracionXML     AS Service_LugarGeneracionXML OPTIONAL
	WSDATA   oWSnotas                  AS Service_ArrayOfNota OPTIONAL
	WSDATA   cnovedad                  AS string OPTIONAL
	WSDATA   cnovedadCUNE              AS string OPTIONAL
	WSDATA   oWSpagos                  AS Service_ArrayOfPago OPTIONAL
	WSDATA   cperiodoNomina            AS string OPTIONAL
	WSDATA   oWSperiodos               AS Service_ArrayOfPeriodo OPTIONAL
	WSDATA   crangoNumeracionNom       AS string OPTIONAL
	WSDATA   credondeo                 AS string OPTIONAL
	WSDATA   ctipoDocumentoNom         AS string OPTIONAL
	WSDATA   ctipoMonedaNom            AS string OPTIONAL
	WSDATA   ctipoNota                 AS string OPTIONAL
	WSDATA   ctotalComprobante         AS string OPTIONAL
	WSDATA   ctotalDeducciones         AS string OPTIONAL
	WSDATA   ctotalDevengados          AS string OPTIONAL
	WSDATA   oWStrabajador             AS Service_Trabajador OPTIONAL
	WSDATA   ctrm                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_NominaGeneral
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_NominaGeneral
Return

WSMETHOD CLONE WSCLIENT Service_NominaGeneral
	Local oClone := Service_NominaGeneral():NEW()
	oClone:cconsecutivoDocumentoNom := ::cconsecutivoDocumentoNom
	oClone:oWSdeducciones       := IIF(::oWSdeducciones = NIL , NIL , ::oWSdeducciones:Clone() )
	oClone:oWSdevengados        := IIF(::oWSdevengados = NIL , NIL , ::oWSdevengados:Clone() )
	oClone:oWSdocumentosReferenciadosNom := IIF(::oWSdocumentosReferenciadosNom = NIL , NIL , ::oWSdocumentosReferenciadosNom:Clone() )
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cfechaEmisionNom     := ::cfechaEmisionNom
	oClone:oWSlugarGeneracionXML := IIF(::oWSlugarGeneracionXML = NIL , NIL , ::oWSlugarGeneracionXML:Clone() )
	oClone:oWSnotas             := IIF(::oWSnotas = NIL , NIL , ::oWSnotas:Clone() )
	oClone:cnovedad             := ::cnovedad
	oClone:cnovedadCUNE         := ::cnovedadCUNE
	oClone:oWSpagos             := IIF(::oWSpagos = NIL , NIL , ::oWSpagos:Clone() )
	oClone:cperiodoNomina       := ::cperiodoNomina
	oClone:oWSperiodos          := IIF(::oWSperiodos = NIL , NIL , ::oWSperiodos:Clone() )
	oClone:crangoNumeracionNom  := ::crangoNumeracionNom
	oClone:credondeo            := ::credondeo
	oClone:ctipoDocumentoNom    := ::ctipoDocumentoNom
	oClone:ctipoMonedaNom       := ::ctipoMonedaNom
	oClone:ctipoNota            := ::ctipoNota
	oClone:ctotalComprobante    := ::ctotalComprobante
	oClone:ctotalDeducciones    := ::ctotalDeducciones
	oClone:ctotalDevengados     := ::ctotalDevengados
	oClone:oWStrabajador        := IIF(::oWStrabajador = NIL , NIL , ::oWStrabajador:Clone() )
	oClone:ctrm                 := ::ctrm
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_NominaGeneral
	Local cSoap := ""
	cSoap += WSSoapValue("consecutivoDocumentoNom", ::cconsecutivoDocumentoNom, ::cconsecutivoDocumentoNom , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("deducciones", ::oWSdeducciones, ::oWSdeducciones , "Deduccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("devengados", ::oWSdevengados, ::oWSdevengados , "Devengado", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("documentosReferenciadosNom", ::oWSdocumentosReferenciadosNom, ::oWSdocumentosReferenciadosNom , "ArrayOfDocumentoReferenciadoNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaEmisionNom", ::cfechaEmisionNom, ::cfechaEmisionNom , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("lugarGeneracionXML", ::oWSlugarGeneracionXML, ::oWSlugarGeneracionXML , "LugarGeneracionXML", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("notas", ::oWSnotas, ::oWSnotas , "ArrayOfNota", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("novedad", ::cnovedad, ::cnovedad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("novedadCUNE", ::cnovedadCUNE, ::cnovedadCUNE , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagos", ::oWSpagos, ::oWSpagos , "ArrayOfPago", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("periodoNomina", ::cperiodoNomina, ::cperiodoNomina , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("periodos", ::oWSperiodos, ::oWSperiodos , "ArrayOfPeriodo", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("rangoNumeracionNom", ::crangoNumeracionNom, ::crangoNumeracionNom , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("redondeo", ::credondeo, ::credondeo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipoDocumentoNom", ::ctipoDocumentoNom, ::ctipoDocumentoNom , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipoMonedaNom", ::ctipoMonedaNom, ::ctipoMonedaNom , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipoNota", ::ctipoNota, ::ctipoNota , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("totalComprobante", ::ctotalComprobante, ::ctotalComprobante , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("totalDeducciones", ::ctotalDeducciones, ::ctotalDeducciones , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("totalDevengados", ::ctotalDevengados, ::ctotalDevengados , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("trabajador", ::oWStrabajador, ::oWStrabajador , "Trabajador", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("trm", ::ctrm, ::ctrm , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfstring 
// -------objeto Obtenido de WSNFECOL.PRW

// WSDL Data Structure Deduccion

WSSTRUCT Service_Deduccion
	WSDATA   cafc                      AS string OPTIONAL
	WSDATA   oWSanticiposNom           AS Service_ArrayOfAnticipoNom OPTIONAL
	WSDATA   ccooperativa              AS string OPTIONAL
	WSDATA   cdeuda                    AS string OPTIONAL
	WSDATA   ceducacion                AS string OPTIONAL
	WSDATA   cembargoFiscal            AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   oWSfondosPensiones        AS Service_ArrayOfFondoPension OPTIONAL
	WSDATA   oWSfondosSP               AS Service_ArrayOfFondoSP OPTIONAL
	WSDATA   oWSlibranzas              AS Service_ArrayOfLibranza OPTIONAL
	WSDATA   oWSotrasDeducciones       AS Service_ArrayOfOtraDeduccion OPTIONAL
	WSDATA   oWSpagosTerceros          AS Service_ArrayOfPagoTercero OPTIONAL
	WSDATA   cpensionVoluntaria        AS string OPTIONAL
	WSDATA   cplanComplementarios      AS string OPTIONAL
	WSDATA   creintegro                AS string OPTIONAL
	WSDATA   cretencionFuente          AS string OPTIONAL
	WSDATA   oWSsalud                  AS Service_ArrayOfSalud OPTIONAL
	WSDATA   oWSsanciones              AS Service_ArrayOfSancion OPTIONAL
	WSDATA   oWSsindicatos             AS Service_ArrayOfSindicato OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Deduccion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Deduccion
Return

WSMETHOD CLONE WSCLIENT Service_Deduccion
	Local oClone := Service_Deduccion():NEW()
	oClone:cafc                 := ::cafc
	oClone:oWSanticiposNom      := IIF(::oWSanticiposNom = NIL , NIL , ::oWSanticiposNom:Clone() )
	oClone:ccooperativa         := ::ccooperativa
	oClone:cdeuda               := ::cdeuda
	oClone:ceducacion           := ::ceducacion
	oClone:cembargoFiscal       := ::cembargoFiscal
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:oWSfondosPensiones   := IIF(::oWSfondosPensiones = NIL , NIL , ::oWSfondosPensiones:Clone() )
	oClone:oWSfondosSP          := IIF(::oWSfondosSP = NIL , NIL , ::oWSfondosSP:Clone() )
	oClone:oWSlibranzas         := IIF(::oWSlibranzas = NIL , NIL , ::oWSlibranzas:Clone() )
	oClone:oWSotrasDeducciones  := IIF(::oWSotrasDeducciones = NIL , NIL , ::oWSotrasDeducciones:Clone() )
	oClone:oWSpagosTerceros     := IIF(::oWSpagosTerceros = NIL , NIL , ::oWSpagosTerceros:Clone() )
	oClone:cpensionVoluntaria   := ::cpensionVoluntaria
	oClone:cplanComplementarios := ::cplanComplementarios
	oClone:creintegro           := ::creintegro
	oClone:cretencionFuente     := ::cretencionFuente
	oClone:oWSsalud             := IIF(::oWSsalud = NIL , NIL , ::oWSsalud:Clone() )
	oClone:oWSsanciones         := IIF(::oWSsanciones = NIL , NIL , ::oWSsanciones:Clone() )
	oClone:oWSsindicatos        := IIF(::oWSsindicatos = NIL , NIL , ::oWSsindicatos:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Deduccion
	Local cSoap := ""
	cSoap += WSSoapValue("afc", ::cafc, ::cafc , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("anticiposNom", ::oWSanticiposNom, ::oWSanticiposNom , "ArrayOfAnticipoNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("cooperativa", ::ccooperativa, ::ccooperativa , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("deuda", ::cdeuda, ::cdeuda , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("educacion", ::ceducacion, ::ceducacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("embargoFiscal", ::cembargoFiscal, ::cembargoFiscal , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fondosPensiones", ::oWSfondosPensiones, ::oWSfondosPensiones , "ArrayOfFondoPension", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fondosSP", ::oWSfondosSP, ::oWSfondosSP , "ArrayOfFondoSP", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("libranzas", ::oWSlibranzas, ::oWSlibranzas , "ArrayOfLibranza", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("otrasDeducciones", ::oWSotrasDeducciones, ::oWSotrasDeducciones , "ArrayOfOtraDeduccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagosTerceros", ::oWSpagosTerceros, ::oWSpagosTerceros , "ArrayOfPagoTercero", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pensionVoluntaria", ::cpensionVoluntaria, ::cpensionVoluntaria , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("planComplementarios", ::cplanComplementarios, ::cplanComplementarios , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("reintegro", ::creintegro, ::creintegro , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("retencionFuente", ::cretencionFuente, ::cretencionFuente , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("salud", ::oWSsalud, ::oWSsalud , "ArrayOfSalud", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("sanciones", ::oWSsanciones, ::oWSsanciones , "ArrayOfSancion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("sindicatos", ::oWSsindicatos, ::oWSsindicatos , "ArrayOfSindicato", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Devengado

WSSTRUCT Service_Devengado
	WSDATA   oWSanticiposNom           AS Service_ArrayOfAnticipoNom OPTIONAL
	WSDATA   capoyoSost                AS string OPTIONAL
	WSDATA   oWSauxilios               AS Service_ArrayOfAuxilio OPTIONAL
	WSDATA   oWSbasico                 AS Service_ArrayOfBasico OPTIONAL
	WSDATA   cbonifRetiro              AS string OPTIONAL
	WSDATA   oWSbonificaciones         AS Service_ArrayOfBonificacion OPTIONAL
	WSDATA   oWSbonoEPCTVs             AS Service_ArrayOfBonoEPCTV OPTIONAL
	WSDATA   oWScesantias              AS Service_ArrayOfCesantia OPTIONAL
	WSDATA   oWScomisiones             AS Service_ArrayOfComision OPTIONAL
	WSDATA   oWScompensaciones         AS Service_ArrayOfCompensacion OPTIONAL
	WSDATA   cdotacion                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   oWShorasExtras            AS Service_ArrayOfHoraExtra OPTIONAL
	WSDATA   oWShuelgasLegales         AS Service_ArrayOfHuelgaLegal OPTIONAL
	WSDATA   oWSincapacidades          AS Service_ArrayOfIncapacidad OPTIONAL
	WSDATA   cindemnizacion            AS string OPTIONAL
	WSDATA   oWSlicencias              AS Service_Licencias OPTIONAL
	WSDATA   oWSotrosConceptos         AS Service_ArrayOfOtroConcepto OPTIONAL
	WSDATA   oWSpagosTerceros          AS Service_ArrayOfPagoTercero OPTIONAL
	WSDATA   oWSprimas                 AS Service_ArrayOfPrima OPTIONAL
	WSDATA   creintegro                AS string OPTIONAL
	WSDATA   cteletrabajo              AS string OPTIONAL
	WSDATA   oWStransporte             AS Service_ArrayOfTransporte OPTIONAL
	WSDATA   oWSvacaciones             AS Service_Vacacion OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Devengado
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Devengado
Return

WSMETHOD CLONE WSCLIENT Service_Devengado
	Local oClone := Service_Devengado():NEW()
	oClone:oWSanticiposNom      := IIF(::oWSanticiposNom = NIL , NIL , ::oWSanticiposNom:Clone() )
	oClone:capoyoSost           := ::capoyoSost
	oClone:oWSauxilios          := IIF(::oWSauxilios = NIL , NIL , ::oWSauxilios:Clone() )
	oClone:oWSbasico            := IIF(::oWSbasico = NIL , NIL , ::oWSbasico:Clone() )
	oClone:cbonifRetiro         := ::cbonifRetiro
	oClone:oWSbonificaciones    := IIF(::oWSbonificaciones = NIL , NIL , ::oWSbonificaciones:Clone() )
	oClone:oWSbonoEPCTVs        := IIF(::oWSbonoEPCTVs = NIL , NIL , ::oWSbonoEPCTVs:Clone() )
	oClone:oWScesantias         := IIF(::oWScesantias = NIL , NIL , ::oWScesantias:Clone() )
	oClone:oWScomisiones        := IIF(::oWScomisiones = NIL , NIL , ::oWScomisiones:Clone() )
	oClone:oWScompensaciones    := IIF(::oWScompensaciones = NIL , NIL , ::oWScompensaciones:Clone() )
	oClone:cdotacion            := ::cdotacion
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:oWShorasExtras       := IIF(::oWShorasExtras = NIL , NIL , ::oWShorasExtras:Clone() )
	oClone:oWShuelgasLegales    := IIF(::oWShuelgasLegales = NIL , NIL , ::oWShuelgasLegales:Clone() )
	oClone:oWSincapacidades     := IIF(::oWSincapacidades = NIL , NIL , ::oWSincapacidades:Clone() )
	oClone:cindemnizacion       := ::cindemnizacion
	oClone:oWSlicencias         := IIF(::oWSlicencias = NIL , NIL , ::oWSlicencias:Clone() )
	oClone:oWSotrosConceptos    := IIF(::oWSotrosConceptos = NIL , NIL , ::oWSotrosConceptos:Clone() )
	oClone:oWSpagosTerceros     := IIF(::oWSpagosTerceros = NIL , NIL , ::oWSpagosTerceros:Clone() )
	oClone:oWSprimas            := IIF(::oWSprimas = NIL , NIL , ::oWSprimas:Clone() )
	oClone:creintegro           := ::creintegro
	oClone:cteletrabajo         := ::cteletrabajo
	oClone:oWStransporte        := IIF(::oWStransporte = NIL , NIL , ::oWStransporte:Clone() )
	oClone:oWSvacaciones        := IIF(::oWSvacaciones = NIL , NIL , ::oWSvacaciones:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Devengado
	Local cSoap := ""
	cSoap += WSSoapValue("anticiposNom", ::oWSanticiposNom, ::oWSanticiposNom , "ArrayOfAnticipoNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("apoyoSost", ::capoyoSost, ::capoyoSost , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("auxilios", ::oWSauxilios, ::oWSauxilios , "ArrayOfAuxilio", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("basico", ::oWSbasico, ::oWSbasico , "ArrayOfBasico", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("bonifRetiro", ::cbonifRetiro, ::cbonifRetiro , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("bonificaciones", ::oWSbonificaciones, ::oWSbonificaciones , "ArrayOfBonificacion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("bonoEPCTVs", ::oWSbonoEPCTVs, ::oWSbonoEPCTVs , "ArrayOfBonoEPCTV", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("cesantias", ::oWScesantias, ::oWScesantias , "ArrayOfCesantia", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("comisiones", ::oWScomisiones, ::oWScomisiones , "ArrayOfComision", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("compensaciones", ::oWScompensaciones, ::oWScompensaciones , "ArrayOfCompensacion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("dotacion", ::cdotacion, ::cdotacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("horasExtras", ::oWShorasExtras, ::oWShorasExtras , "ArrayOfHoraExtra", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("huelgasLegales", ::oWShuelgasLegales, ::oWShuelgasLegales , "ArrayOfHuelgaLegal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("incapacidades", ::oWSincapacidades, ::oWSincapacidades , "ArrayOfIncapacidad", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("indemnizacion", ::cindemnizacion, ::cindemnizacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("licencias", ::oWSlicencias, ::oWSlicencias , "Licencias", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("otrosConceptos", ::oWSotrosConceptos, ::oWSotrosConceptos , "ArrayOfOtroConcepto", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagosTerceros", ::oWSpagosTerceros, ::oWSpagosTerceros , "ArrayOfPagoTercero", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("primas", ::oWSprimas, ::oWSprimas , "ArrayOfPrima", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("reintegro", ::creintegro, ::creintegro , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("teletrabajo", ::cteletrabajo, ::cteletrabajo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("transporte", ::oWStransporte, ::oWStransporte , "ArrayOfTransporte", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("vacaciones", ::oWSvacaciones, ::oWSvacaciones , "Vacacion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfDocumentoReferenciadoNom

WSSTRUCT Service_ArrayOfDocumentoReferenciadoNom
	WSDATA   oWSDocumentoReferenciadoNom AS Service_DocumentoReferenciadoNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfDocumentoReferenciadoNom
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfDocumentoReferenciadoNom
	::oWSDocumentoReferenciadoNom := {} // Array Of  Service_DOCUMENTOREFERENCIADONOM():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfDocumentoReferenciadoNom
	Local oClone := Service_ArrayOfDocumentoReferenciadoNom():NEW()
	oClone:oWSDocumentoReferenciadoNom := NIL
	If ::oWSDocumentoReferenciadoNom <> NIL 
		oClone:oWSDocumentoReferenciadoNom := {}
		aEval( ::oWSDocumentoReferenciadoNom , { |x| aadd( oClone:oWSDocumentoReferenciadoNom , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfDocumentoReferenciadoNom
	Local cSoap := ""
	aEval( ::oWSDocumentoReferenciadoNom , {|x| cSoap := cSoap  +  WSSoapValue("DocumentoReferenciadoNom", x , x , "DocumentoReferenciadoNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfExtensibleNom

WSSTRUCT Service_ArrayOfExtensibleNom
	WSDATA   oWSExtensibleNom          AS Service_ExtensibleNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfExtensibleNom
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfExtensibleNom
	::oWSExtensibleNom     := {} // Array Of  Service_EXTENSIBLENOM():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfExtensibleNom
	Local oClone := Service_ArrayOfExtensibleNom():NEW()
	oClone:oWSExtensibleNom := NIL
	If ::oWSExtensibleNom <> NIL 
		oClone:oWSExtensibleNom := {}
		aEval( ::oWSExtensibleNom , { |x| aadd( oClone:oWSExtensibleNom , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfExtensibleNom
	Local cSoap := ""
	aEval( ::oWSExtensibleNom , {|x| cSoap := cSoap  +  WSSoapValue("ExtensibleNom", x , x , "ExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure LugarGeneracionXML

WSSTRUCT Service_LugarGeneracionXML
	WSDATA   cdepartamentoEstado       AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cidioma                   AS string OPTIONAL
	WSDATA   cmunicipioCiudad          AS string OPTIONAL
	WSDATA   cpais                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_LugarGeneracionXML
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_LugarGeneracionXML
Return

WSMETHOD CLONE WSCLIENT Service_LugarGeneracionXML
	Local oClone := Service_LugarGeneracionXML():NEW()
	oClone:cdepartamentoEstado  := ::cdepartamentoEstado
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cidioma              := ::cidioma
	oClone:cmunicipioCiudad     := ::cmunicipioCiudad
	oClone:cpais                := ::cpais
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_LugarGeneracionXML
	Local cSoap := ""
	cSoap += WSSoapValue("departamentoEstado", ::cdepartamentoEstado, ::cdepartamentoEstado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("idioma", ::cidioma, ::cidioma , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("municipioCiudad", ::cmunicipioCiudad, ::cmunicipioCiudad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pais", ::cpais, ::cpais , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfNota

WSSTRUCT Service_ArrayOfNota
	WSDATA   oWSNota                   AS Service_Nota OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfNota
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfNota
	::oWSNota              := {} // Array Of  Service_NOTA():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfNota
	Local oClone := Service_ArrayOfNota():NEW()
	oClone:oWSNota := NIL
	If ::oWSNota <> NIL 
		oClone:oWSNota := {}
		aEval( ::oWSNota , { |x| aadd( oClone:oWSNota , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfNota
	Local cSoap := ""
	aEval( ::oWSNota , {|x| cSoap := cSoap  +  WSSoapValue("Nota", x , x , "Nota", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfPago

WSSTRUCT Service_ArrayOfPago
	WSDATA   oWSPago                   AS Service_Pago OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfPago
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfPago
	::oWSPago              := {} // Array Of  Service_PAGO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfPago
	Local oClone := Service_ArrayOfPago():NEW()
	oClone:oWSPago := NIL
	If ::oWSPago <> NIL 
		oClone:oWSPago := {}
		aEval( ::oWSPago , { |x| aadd( oClone:oWSPago , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfPago
	Local cSoap := ""
	aEval( ::oWSPago , {|x| cSoap := cSoap  +  WSSoapValue("Pago", x , x , "Pago", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfPeriodo

WSSTRUCT Service_ArrayOfPeriodo
	WSDATA   oWSPeriodo                AS Service_Periodo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfPeriodo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfPeriodo
	::oWSPeriodo           := {} // Array Of  Service_PERIODO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfPeriodo
	Local oClone := Service_ArrayOfPeriodo():NEW()
	oClone:oWSPeriodo := NIL
	If ::oWSPeriodo <> NIL 
		oClone:oWSPeriodo := {}
		aEval( ::oWSPeriodo , { |x| aadd( oClone:oWSPeriodo , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfPeriodo
	Local cSoap := ""
	aEval( ::oWSPeriodo , {|x| cSoap := cSoap  +  WSSoapValue("Periodo", x , x , "Periodo", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Trabajador

WSSTRUCT Service_Trabajador
	WSDATA   caltoRiesgoPension        AS string OPTIONAL
	WSDATA   ccodigoTrabajador         AS string OPTIONAL
	WSDATA   cemail                    AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   clugarTrabajoDepartamentoEstado AS string OPTIONAL
	WSDATA   clugarTrabajoDireccion    AS string OPTIONAL
	WSDATA   clugarTrabajoMunicipioCiudad AS string OPTIONAL
	WSDATA   clugarTrabajoPais         AS string OPTIONAL
	WSDATA   cnumeroDocumento          AS string OPTIONAL
	WSDATA   cotrosNombres             AS string OPTIONAL
	WSDATA   cprimerApellido           AS string OPTIONAL
	WSDATA   cprimerNombre             AS string OPTIONAL
	WSDATA   csalarioIntegral          AS string OPTIONAL
	WSDATA   csegundoApellido          AS string OPTIONAL
	WSDATA   csubTipoTrabajador        AS string OPTIONAL
	WSDATA   csueldo                   AS string OPTIONAL
	WSDATA   ctipoContrato             AS string OPTIONAL
	WSDATA   ctipoIdentificacion       AS string OPTIONAL
	WSDATA   ctipoTrabajador           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Trabajador
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Trabajador
Return

WSMETHOD CLONE WSCLIENT Service_Trabajador
	Local oClone := Service_Trabajador():NEW()
	oClone:caltoRiesgoPension   := ::caltoRiesgoPension
	oClone:ccodigoTrabajador    := ::ccodigoTrabajador
	oClone:cemail               := ::cemail
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:clugarTrabajoDepartamentoEstado := ::clugarTrabajoDepartamentoEstado
	oClone:clugarTrabajoDireccion := ::clugarTrabajoDireccion
	oClone:clugarTrabajoMunicipioCiudad := ::clugarTrabajoMunicipioCiudad
	oClone:clugarTrabajoPais    := ::clugarTrabajoPais
	oClone:cnumeroDocumento     := ::cnumeroDocumento
	oClone:cotrosNombres        := ::cotrosNombres
	oClone:cprimerApellido      := ::cprimerApellido
	oClone:cprimerNombre        := ::cprimerNombre
	oClone:csalarioIntegral     := ::csalarioIntegral
	oClone:csegundoApellido     := ::csegundoApellido
	oClone:csubTipoTrabajador   := ::csubTipoTrabajador
	oClone:csueldo              := ::csueldo
	oClone:ctipoContrato        := ::ctipoContrato
	oClone:ctipoIdentificacion  := ::ctipoIdentificacion
	oClone:ctipoTrabajador      := ::ctipoTrabajador
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Trabajador
	Local cSoap := ""
	cSoap += WSSoapValue("altoRiesgoPension", ::caltoRiesgoPension, ::caltoRiesgoPension , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("codigoTrabajador", ::ccodigoTrabajador, ::ccodigoTrabajador , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("lugarTrabajoDepartamentoEstado", ::clugarTrabajoDepartamentoEstado, ::clugarTrabajoDepartamentoEstado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("lugarTrabajoDireccion", ::clugarTrabajoDireccion, ::clugarTrabajoDireccion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("lugarTrabajoMunicipioCiudad", ::clugarTrabajoMunicipioCiudad, ::clugarTrabajoMunicipioCiudad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("lugarTrabajoPais", ::clugarTrabajoPais, ::clugarTrabajoPais , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("numeroDocumento", ::cnumeroDocumento, ::cnumeroDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("otrosNombres", ::cotrosNombres, ::cotrosNombres , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("primerApellido", ::cprimerApellido, ::cprimerApellido , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("primerNombre", ::cprimerNombre, ::cprimerNombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("salarioIntegral", ::csalarioIntegral, ::csalarioIntegral , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("segundoApellido", ::csegundoApellido, ::csegundoApellido , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("subTipoTrabajador", ::csubTipoTrabajador, ::csubTipoTrabajador , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("sueldo", ::csueldo, ::csueldo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipoContrato", ::ctipoContrato, ::ctipoContrato , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipoIdentificacion", ::ctipoIdentificacion, ::ctipoIdentificacion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipoTrabajador", ::ctipoTrabajador, ::ctipoTrabajador , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfAnticipoNom

WSSTRUCT Service_ArrayOfAnticipoNom
	WSDATA   oWSAnticipoNom            AS Service_AnticipoNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfAnticipoNom
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfAnticipoNom
	::oWSAnticipoNom       := {} // Array Of  Service_ANTICIPONOM():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfAnticipoNom
	Local oClone := Service_ArrayOfAnticipoNom():NEW()
	oClone:oWSAnticipoNom := NIL
	If ::oWSAnticipoNom <> NIL 
		oClone:oWSAnticipoNom := {}
		aEval( ::oWSAnticipoNom , { |x| aadd( oClone:oWSAnticipoNom , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfAnticipoNom
	Local cSoap := ""
	aEval( ::oWSAnticipoNom , {|x| cSoap := cSoap  +  WSSoapValue("AnticipoNom", x , x , "AnticipoNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfFondoPension

WSSTRUCT Service_ArrayOfFondoPension
	WSDATA   oWSFondoPension           AS Service_FondoPension OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfFondoPension
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfFondoPension
	::oWSFondoPension      := {} // Array Of  Service_FONDOPENSION():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfFondoPension
	Local oClone := Service_ArrayOfFondoPension():NEW()
	oClone:oWSFondoPension := NIL
	If ::oWSFondoPension <> NIL 
		oClone:oWSFondoPension := {}
		aEval( ::oWSFondoPension , { |x| aadd( oClone:oWSFondoPension , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfFondoPension
	Local cSoap := ""
	aEval( ::oWSFondoPension , {|x| cSoap := cSoap  +  WSSoapValue("FondoPension", x , x , "FondoPension", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfFondoSP

WSSTRUCT Service_ArrayOfFondoSP
	WSDATA   oWSFondoSP                AS Service_FondoSP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfFondoSP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfFondoSP
	::oWSFondoSP           := {} // Array Of  Service_FONDOSP():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfFondoSP
	Local oClone := Service_ArrayOfFondoSP():NEW()
	oClone:oWSFondoSP := NIL
	If ::oWSFondoSP <> NIL 
		oClone:oWSFondoSP := {}
		aEval( ::oWSFondoSP , { |x| aadd( oClone:oWSFondoSP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfFondoSP
	Local cSoap := ""
	aEval( ::oWSFondoSP , {|x| cSoap := cSoap  +  WSSoapValue("FondoSP", x , x , "FondoSP", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfLibranza

WSSTRUCT Service_ArrayOfLibranza
	WSDATA   oWSLibranza               AS Service_Libranza OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfLibranza
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfLibranza
	::oWSLibranza          := {} // Array Of  Service_LIBRANZA():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfLibranza
	Local oClone := Service_ArrayOfLibranza():NEW()
	oClone:oWSLibranza := NIL
	If ::oWSLibranza <> NIL 
		oClone:oWSLibranza := {}
		aEval( ::oWSLibranza , { |x| aadd( oClone:oWSLibranza , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfLibranza
	Local cSoap := ""
	aEval( ::oWSLibranza , {|x| cSoap := cSoap  +  WSSoapValue("Libranza", x , x , "Libranza", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfOtraDeduccion

WSSTRUCT Service_ArrayOfOtraDeduccion
	WSDATA   oWSOtraDeduccion          AS Service_OtraDeduccion OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfOtraDeduccion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfOtraDeduccion
	::oWSOtraDeduccion     := {} // Array Of  Service_OTRADEDUCCION():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfOtraDeduccion
	Local oClone := Service_ArrayOfOtraDeduccion():NEW()
	oClone:oWSOtraDeduccion := NIL
	If ::oWSOtraDeduccion <> NIL 
		oClone:oWSOtraDeduccion := {}
		aEval( ::oWSOtraDeduccion , { |x| aadd( oClone:oWSOtraDeduccion , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfOtraDeduccion
	Local cSoap := ""
	aEval( ::oWSOtraDeduccion , {|x| cSoap := cSoap  +  WSSoapValue("OtraDeduccion", x , x , "OtraDeduccion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfPagoTercero

WSSTRUCT Service_ArrayOfPagoTercero
	WSDATA   oWSPagoTercero            AS Service_PagoTercero OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfPagoTercero
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfPagoTercero
	::oWSPagoTercero       := {} // Array Of  Service_PAGOTERCERO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfPagoTercero
	Local oClone := Service_ArrayOfPagoTercero():NEW()
	oClone:oWSPagoTercero := NIL
	If ::oWSPagoTercero <> NIL 
		oClone:oWSPagoTercero := {}
		aEval( ::oWSPagoTercero , { |x| aadd( oClone:oWSPagoTercero , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfPagoTercero
	Local cSoap := ""
	aEval( ::oWSPagoTercero , {|x| cSoap := cSoap  +  WSSoapValue("PagoTercero", x , x , "PagoTercero", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfSalud

WSSTRUCT Service_ArrayOfSalud
	WSDATA   oWSSalud                  AS Service_Salud OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfSalud
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfSalud
	::oWSSalud             := {} // Array Of  Service_SALUD():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfSalud
	Local oClone := Service_ArrayOfSalud():NEW()
	oClone:oWSSalud := NIL
	If ::oWSSalud <> NIL 
		oClone:oWSSalud := {}
		aEval( ::oWSSalud , { |x| aadd( oClone:oWSSalud , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfSalud
	Local cSoap := ""
	aEval( ::oWSSalud , {|x| cSoap := cSoap  +  WSSoapValue("Salud", x , x , "Salud", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfSancion

WSSTRUCT Service_ArrayOfSancion
	WSDATA   oWSSancion                AS Service_Sancion OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfSancion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfSancion
	::oWSSancion           := {} // Array Of  Service_SANCION():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfSancion
	Local oClone := Service_ArrayOfSancion():NEW()
	oClone:oWSSancion := NIL
	If ::oWSSancion <> NIL 
		oClone:oWSSancion := {}
		aEval( ::oWSSancion , { |x| aadd( oClone:oWSSancion , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfSancion
	Local cSoap := ""
	aEval( ::oWSSancion , {|x| cSoap := cSoap  +  WSSoapValue("Sancion", x , x , "Sancion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfSindicato

WSSTRUCT Service_ArrayOfSindicato
	WSDATA   oWSSindicato              AS Service_Sindicato OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfSindicato
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfSindicato
	::oWSSindicato         := {} // Array Of  Service_SINDICATO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfSindicato
	Local oClone := Service_ArrayOfSindicato():NEW()
	oClone:oWSSindicato := NIL
	If ::oWSSindicato <> NIL 
		oClone:oWSSindicato := {}
		aEval( ::oWSSindicato , { |x| aadd( oClone:oWSSindicato , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfSindicato
	Local cSoap := ""
	aEval( ::oWSSindicato , {|x| cSoap := cSoap  +  WSSoapValue("Sindicato", x , x , "Sindicato", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfAuxilio

WSSTRUCT Service_ArrayOfAuxilio
	WSDATA   oWSAuxilio                AS Service_Auxilio OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfAuxilio
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfAuxilio
	::oWSAuxilio           := {} // Array Of  Service_AUXILIO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfAuxilio
	Local oClone := Service_ArrayOfAuxilio():NEW()
	oClone:oWSAuxilio := NIL
	If ::oWSAuxilio <> NIL 
		oClone:oWSAuxilio := {}
		aEval( ::oWSAuxilio , { |x| aadd( oClone:oWSAuxilio , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfAuxilio
	Local cSoap := ""
	aEval( ::oWSAuxilio , {|x| cSoap := cSoap  +  WSSoapValue("Auxilio", x , x , "Auxilio", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfBasico

WSSTRUCT Service_ArrayOfBasico
	WSDATA   oWSBasico                 AS Service_Basico OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfBasico
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfBasico
	::oWSBasico            := {} // Array Of  Service_BASICO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfBasico
	Local oClone := Service_ArrayOfBasico():NEW()
	oClone:oWSBasico := NIL
	If ::oWSBasico <> NIL 
		oClone:oWSBasico := {}
		aEval( ::oWSBasico , { |x| aadd( oClone:oWSBasico , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfBasico
	Local cSoap := ""
	aEval( ::oWSBasico , {|x| cSoap := cSoap  +  WSSoapValue("Basico", x , x , "Basico", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfBonificacion

WSSTRUCT Service_ArrayOfBonificacion
	WSDATA   oWSBonificacion           AS Service_Bonificacion OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfBonificacion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfBonificacion
	::oWSBonificacion      := {} // Array Of  Service_BONIFICACION():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfBonificacion
	Local oClone := Service_ArrayOfBonificacion():NEW()
	oClone:oWSBonificacion := NIL
	If ::oWSBonificacion <> NIL 
		oClone:oWSBonificacion := {}
		aEval( ::oWSBonificacion , { |x| aadd( oClone:oWSBonificacion , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfBonificacion
	Local cSoap := ""
	aEval( ::oWSBonificacion , {|x| cSoap := cSoap  +  WSSoapValue("Bonificacion", x , x , "Bonificacion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfBonoEPCTV

WSSTRUCT Service_ArrayOfBonoEPCTV
	WSDATA   oWSBonoEPCTV              AS Service_BonoEPCTV OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfBonoEPCTV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfBonoEPCTV
	::oWSBonoEPCTV         := {} // Array Of  Service_BONOEPCTV():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfBonoEPCTV
	Local oClone := Service_ArrayOfBonoEPCTV():NEW()
	oClone:oWSBonoEPCTV := NIL
	If ::oWSBonoEPCTV <> NIL 
		oClone:oWSBonoEPCTV := {}
		aEval( ::oWSBonoEPCTV , { |x| aadd( oClone:oWSBonoEPCTV , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfBonoEPCTV
	Local cSoap := ""
	aEval( ::oWSBonoEPCTV , {|x| cSoap := cSoap  +  WSSoapValue("BonoEPCTV", x , x , "BonoEPCTV", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfCesantia

WSSTRUCT Service_ArrayOfCesantia
	WSDATA   oWSCesantia               AS Service_Cesantia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfCesantia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfCesantia
	::oWSCesantia          := {} // Array Of  Service_CESANTIA():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfCesantia
	Local oClone := Service_ArrayOfCesantia():NEW()
	oClone:oWSCesantia := NIL
	If ::oWSCesantia <> NIL 
		oClone:oWSCesantia := {}
		aEval( ::oWSCesantia , { |x| aadd( oClone:oWSCesantia , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfCesantia
	Local cSoap := ""
	aEval( ::oWSCesantia , {|x| cSoap := cSoap  +  WSSoapValue("Cesantia", x , x , "Cesantia", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfComision

WSSTRUCT Service_ArrayOfComision
	WSDATA   oWSComision               AS Service_Comision OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfComision
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfComision
	::oWSComision          := {} // Array Of  Service_COMISION():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfComision
	Local oClone := Service_ArrayOfComision():NEW()
	oClone:oWSComision := NIL
	If ::oWSComision <> NIL 
		oClone:oWSComision := {}
		aEval( ::oWSComision , { |x| aadd( oClone:oWSComision , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfComision
	Local cSoap := ""
	aEval( ::oWSComision , {|x| cSoap := cSoap  +  WSSoapValue("Comision", x , x , "Comision", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfCompensacion

WSSTRUCT Service_ArrayOfCompensacion
	WSDATA   oWSCompensacion           AS Service_Compensacion OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfCompensacion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfCompensacion
	::oWSCompensacion      := {} // Array Of  Service_COMPENSACION():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfCompensacion
	Local oClone := Service_ArrayOfCompensacion():NEW()
	oClone:oWSCompensacion := NIL
	If ::oWSCompensacion <> NIL 
		oClone:oWSCompensacion := {}
		aEval( ::oWSCompensacion , { |x| aadd( oClone:oWSCompensacion , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfCompensacion
	Local cSoap := ""
	aEval( ::oWSCompensacion , {|x| cSoap := cSoap  +  WSSoapValue("Compensacion", x , x , "Compensacion", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfHoraExtra

WSSTRUCT Service_ArrayOfHoraExtra
	WSDATA   oWSHoraExtra              AS Service_HoraExtra OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfHoraExtra
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfHoraExtra
	::oWSHoraExtra         := {} // Array Of  Service_HORAEXTRA():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfHoraExtra
	Local oClone := Service_ArrayOfHoraExtra():NEW()
	oClone:oWSHoraExtra := NIL
	If ::oWSHoraExtra <> NIL 
		oClone:oWSHoraExtra := {}
		aEval( ::oWSHoraExtra , { |x| aadd( oClone:oWSHoraExtra , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfHoraExtra
	Local cSoap := ""
	aEval( ::oWSHoraExtra , {|x| cSoap := cSoap  +  WSSoapValue("HoraExtra", x , x , "HoraExtra", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfHuelgaLegal

WSSTRUCT Service_ArrayOfHuelgaLegal
	WSDATA   oWSHuelgaLegal            AS Service_HuelgaLegal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfHuelgaLegal
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfHuelgaLegal
	::oWSHuelgaLegal       := {} // Array Of  Service_HUELGALEGAL():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfHuelgaLegal
	Local oClone := Service_ArrayOfHuelgaLegal():NEW()
	oClone:oWSHuelgaLegal := NIL
	If ::oWSHuelgaLegal <> NIL 
		oClone:oWSHuelgaLegal := {}
		aEval( ::oWSHuelgaLegal , { |x| aadd( oClone:oWSHuelgaLegal , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfHuelgaLegal
	Local cSoap := ""
	aEval( ::oWSHuelgaLegal , {|x| cSoap := cSoap  +  WSSoapValue("HuelgaLegal", x , x , "HuelgaLegal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfIncapacidad

WSSTRUCT Service_ArrayOfIncapacidad
	WSDATA   oWSIncapacidad            AS Service_Incapacidad OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfIncapacidad
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfIncapacidad
	::oWSIncapacidad       := {} // Array Of  Service_INCAPACIDAD():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfIncapacidad
	Local oClone := Service_ArrayOfIncapacidad():NEW()
	oClone:oWSIncapacidad := NIL
	If ::oWSIncapacidad <> NIL 
		oClone:oWSIncapacidad := {}
		aEval( ::oWSIncapacidad , { |x| aadd( oClone:oWSIncapacidad , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfIncapacidad
	Local cSoap := ""
	aEval( ::oWSIncapacidad , {|x| cSoap := cSoap  +  WSSoapValue("Incapacidad", x , x , "Incapacidad", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Licencias

WSSTRUCT Service_Licencias
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   oWSlicenciaMP             AS Service_ArrayOfLicencia OPTIONAL
	WSDATA   oWSlicenciaNR             AS Service_ArrayOfLicencia OPTIONAL
	WSDATA   oWSlicenciaR              AS Service_ArrayOfLicencia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Licencias
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Licencias
Return

WSMETHOD CLONE WSCLIENT Service_Licencias
	Local oClone := Service_Licencias():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:oWSlicenciaMP        := IIF(::oWSlicenciaMP = NIL , NIL , ::oWSlicenciaMP:Clone() )
	oClone:oWSlicenciaNR        := IIF(::oWSlicenciaNR = NIL , NIL , ::oWSlicenciaNR:Clone() )
	oClone:oWSlicenciaR         := IIF(::oWSlicenciaR = NIL , NIL , ::oWSlicenciaR:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Licencias
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("licenciaMP", ::oWSlicenciaMP, ::oWSlicenciaMP , "ArrayOfLicencia", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("licenciaNR", ::oWSlicenciaNR, ::oWSlicenciaNR , "ArrayOfLicencia", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("licenciaR", ::oWSlicenciaR, ::oWSlicenciaR , "ArrayOfLicencia", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfOtroConcepto

WSSTRUCT Service_ArrayOfOtroConcepto
	WSDATA   oWSOtroConcepto           AS Service_OtroConcepto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfOtroConcepto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfOtroConcepto
	::oWSOtroConcepto      := {} // Array Of  Service_OTROCONCEPTO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfOtroConcepto
	Local oClone := Service_ArrayOfOtroConcepto():NEW()
	oClone:oWSOtroConcepto := NIL
	If ::oWSOtroConcepto <> NIL 
		oClone:oWSOtroConcepto := {}
		aEval( ::oWSOtroConcepto , { |x| aadd( oClone:oWSOtroConcepto , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfOtroConcepto
	Local cSoap := ""
	aEval( ::oWSOtroConcepto , {|x| cSoap := cSoap  +  WSSoapValue("OtroConcepto", x , x , "OtroConcepto", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfPrima

WSSTRUCT Service_ArrayOfPrima
	WSDATA   oWSPrima                  AS Service_Prima OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfPrima
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfPrima
	::oWSPrima             := {} // Array Of  Service_PRIMA():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfPrima
	Local oClone := Service_ArrayOfPrima():NEW()
	oClone:oWSPrima := NIL
	If ::oWSPrima <> NIL 
		oClone:oWSPrima := {}
		aEval( ::oWSPrima , { |x| aadd( oClone:oWSPrima , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfPrima
	Local cSoap := ""
	aEval( ::oWSPrima , {|x| cSoap := cSoap  +  WSSoapValue("Prima", x , x , "Prima", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfTransporte

WSSTRUCT Service_ArrayOfTransporte
	WSDATA   oWSTransporte             AS Service_Transporte OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfTransporte
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfTransporte
	::oWSTransporte        := {} // Array Of  Service_TRANSPORTE():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfTransporte
	Local oClone := Service_ArrayOfTransporte():NEW()
	oClone:oWSTransporte := NIL
	If ::oWSTransporte <> NIL 
		oClone:oWSTransporte := {}
		aEval( ::oWSTransporte , { |x| aadd( oClone:oWSTransporte , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfTransporte
	Local cSoap := ""
	aEval( ::oWSTransporte , {|x| cSoap := cSoap  +  WSSoapValue("Transporte", x , x , "Transporte", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Vacacion

WSSTRUCT Service_Vacacion
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   oWSvacacionesCompensadas  AS Service_ArrayOfVacaciones OPTIONAL
	WSDATA   oWSvacacionesComunes      AS Service_ArrayOfVacaciones OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Vacacion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Vacacion
Return

WSMETHOD CLONE WSCLIENT Service_Vacacion
	Local oClone := Service_Vacacion():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:oWSvacacionesCompensadas := IIF(::oWSvacacionesCompensadas = NIL , NIL , ::oWSvacacionesCompensadas:Clone() )
	oClone:oWSvacacionesComunes := IIF(::oWSvacacionesComunes = NIL , NIL , ::oWSvacacionesComunes:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Vacacion
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("vacacionesCompensadas", ::oWSvacacionesCompensadas, ::oWSvacacionesCompensadas , "ArrayOfVacaciones", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("vacacionesComunes", ::oWSvacacionesComunes, ::oWSvacacionesComunes , "ArrayOfVacaciones", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure DocumentoReferenciadoNom

WSSTRUCT Service_DocumentoReferenciadoNom
	WSDATA   ccunePred                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cfechaGenPred             AS string OPTIONAL
	WSDATA   cnumeroPred               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_DocumentoReferenciadoNom
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_DocumentoReferenciadoNom
Return

WSMETHOD CLONE WSCLIENT Service_DocumentoReferenciadoNom
	Local oClone := Service_DocumentoReferenciadoNom():NEW()
	oClone:ccunePred            := ::ccunePred
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cfechaGenPred        := ::cfechaGenPred
	oClone:cnumeroPred          := ::cnumeroPred
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_DocumentoReferenciadoNom
	Local cSoap := ""
	cSoap += WSSoapValue("cunePred", ::ccunePred, ::ccunePred , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaGenPred", ::cfechaGenPred, ::cfechaGenPred , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("numeroPred", ::cnumeroPred, ::cnumeroPred , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure ExtensibleNom

WSSTRUCT Service_ExtensibleNom
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

WSMETHOD NEW WSCLIENT Service_ExtensibleNom
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ExtensibleNom
Return

WSMETHOD CLONE WSCLIENT Service_ExtensibleNom
	Local oClone := Service_ExtensibleNom():NEW()
	oClone:ccontrolInterno1     := ::ccontrolInterno1
	oClone:ccontrolInterno2     := ::ccontrolInterno2
	oClone:cnombre              := ::cnombre
	oClone:cpdf                 := ::cpdf
	oClone:cvalor               := ::cvalor
	oClone:cxml                 := ::cxml
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ExtensibleNom
	Local cSoap := ""
	cSoap += WSSoapValue("controlInterno1", ::ccontrolInterno1, ::ccontrolInterno1 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("controlInterno2", ::ccontrolInterno2, ::ccontrolInterno2 , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("nombre", ::cnombre, ::cnombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pdf", ::cpdf, ::cpdf , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("valor", ::cvalor, ::cvalor , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("xml", ::cxml, ::cxml , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Nota

WSSTRUCT Service_Nota
	WSDATA   cdescripcion              AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Nota
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Nota
Return

WSMETHOD CLONE WSCLIENT Service_Nota
	Local oClone := Service_Nota():NEW()
	oClone:cdescripcion         := ::cdescripcion
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Nota
	Local cSoap := ""
	cSoap += WSSoapValue("descripcion", ::cdescripcion, ::cdescripcion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Pago

WSSTRUCT Service_Pago
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   oWSfechasPagos            AS Service_ArrayOfFechaPago OPTIONAL
	WSDATA   cmedioPago                AS string OPTIONAL
	WSDATA   cmetodoDePago             AS string OPTIONAL
	WSDATA   cnombreBanco              AS string OPTIONAL
	WSDATA   cnumeroCuenta             AS string OPTIONAL
	WSDATA   ctipoCuenta               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Pago
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Pago
Return

WSMETHOD CLONE WSCLIENT Service_Pago
	Local oClone := Service_Pago():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:oWSfechasPagos       := IIF(::oWSfechasPagos = NIL , NIL , ::oWSfechasPagos:Clone() )
	oClone:cmedioPago           := ::cmedioPago
	oClone:cmetodoDePago        := ::cmetodoDePago
	oClone:cnombreBanco         := ::cnombreBanco
	oClone:cnumeroCuenta        := ::cnumeroCuenta
	oClone:ctipoCuenta          := ::ctipoCuenta
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Pago
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechasPagos", ::oWSfechasPagos, ::oWSfechasPagos , "ArrayOfFechaPago", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("medioPago", ::cmedioPago, ::cmedioPago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("metodoDePago", ::cmetodoDePago, ::cmetodoDePago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("nombreBanco", ::cnombreBanco, ::cnombreBanco , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("numeroCuenta", ::cnumeroCuenta, ::cnumeroCuenta , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipoCuenta", ::ctipoCuenta, ::ctipoCuenta , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Periodo

WSSTRUCT Service_Periodo
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cfechaIngreso             AS string OPTIONAL
	WSDATA   cfechaLiquidacionFin      AS string OPTIONAL
	WSDATA   cfechaLiquidacionInicio   AS string OPTIONAL
	WSDATA   cfechaRetiro              AS string OPTIONAL
	WSDATA   ctiempoLaborado           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Periodo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Periodo
Return

WSMETHOD CLONE WSCLIENT Service_Periodo
	Local oClone := Service_Periodo():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cfechaIngreso        := ::cfechaIngreso
	oClone:cfechaLiquidacionFin := ::cfechaLiquidacionFin
	oClone:cfechaLiquidacionInicio := ::cfechaLiquidacionInicio
	oClone:cfechaRetiro         := ::cfechaRetiro
	oClone:ctiempoLaborado      := ::ctiempoLaborado
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Periodo
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaIngreso", ::cfechaIngreso, ::cfechaIngreso , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaLiquidacionFin", ::cfechaLiquidacionFin, ::cfechaLiquidacionFin , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaLiquidacionInicio", ::cfechaLiquidacionInicio, ::cfechaLiquidacionInicio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaRetiro", ::cfechaRetiro, ::cfechaRetiro , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tiempoLaborado", ::ctiempoLaborado, ::ctiempoLaborado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure AnticipoNom

WSSTRUCT Service_AnticipoNom
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cmontoanticipo            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_AnticipoNom
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_AnticipoNom
Return

WSMETHOD CLONE WSCLIENT Service_AnticipoNom
	Local oClone := Service_AnticipoNom():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cmontoanticipo       := ::cmontoanticipo
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_AnticipoNom
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("montoanticipo", ::cmontoanticipo, ::cmontoanticipo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure FondoPension

WSSTRUCT Service_FondoPension
	WSDATA   cdeduccion                AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cporcentaje               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_FondoPension
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_FondoPension
Return

WSMETHOD CLONE WSCLIENT Service_FondoPension
	Local oClone := Service_FondoPension():NEW()
	oClone:cdeduccion           := ::cdeduccion
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cporcentaje          := ::cporcentaje
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_FondoPension
	Local cSoap := ""
	cSoap += WSSoapValue("deduccion", ::cdeduccion, ::cdeduccion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("porcentaje", ::cporcentaje, ::cporcentaje , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure FondoSP

WSSTRUCT Service_FondoSP
	WSDATA   cdeduccionSP              AS string OPTIONAL
	WSDATA   cdeduccionSub             AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cporcentaje               AS string OPTIONAL
	WSDATA   cporcentajeSub            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_FondoSP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_FondoSP
Return

WSMETHOD CLONE WSCLIENT Service_FondoSP
	Local oClone := Service_FondoSP():NEW()
	oClone:cdeduccionSP         := ::cdeduccionSP
	oClone:cdeduccionSub        := ::cdeduccionSub
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cporcentaje          := ::cporcentaje
	oClone:cporcentajeSub       := ::cporcentajeSub
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_FondoSP
	Local cSoap := ""
	cSoap += WSSoapValue("deduccionSP", ::cdeduccionSP, ::cdeduccionSP , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("deduccionSub", ::cdeduccionSub, ::cdeduccionSub , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("porcentaje", ::cporcentaje, ::cporcentaje , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("porcentajeSub", ::cporcentajeSub, ::cporcentajeSub , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Libranza

WSSTRUCT Service_Libranza
	WSDATA   cdeduccion                AS string OPTIONAL
	WSDATA   cdescripcion              AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Libranza
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Libranza
Return

WSMETHOD CLONE WSCLIENT Service_Libranza
	Local oClone := Service_Libranza():NEW()
	oClone:cdeduccion           := ::cdeduccion
	oClone:cdescripcion         := ::cdescripcion
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Libranza
	Local cSoap := ""
	cSoap += WSSoapValue("deduccion", ::cdeduccion, ::cdeduccion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("descripcion", ::cdescripcion, ::cdescripcion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure OtraDeduccion

WSSTRUCT Service_OtraDeduccion
	WSDATA   cdescripcionOtraDeduccion AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cmontootraDeduccion       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_OtraDeduccion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_OtraDeduccion
Return

WSMETHOD CLONE WSCLIENT Service_OtraDeduccion
	Local oClone := Service_OtraDeduccion():NEW()
	oClone:cdescripcionOtraDeduccion := ::cdescripcionOtraDeduccion
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cmontootraDeduccion  := ::cmontootraDeduccion
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_OtraDeduccion
	Local cSoap := ""
	cSoap += WSSoapValue("descripcionOtraDeduccion", ::cdescripcionOtraDeduccion, ::cdescripcionOtraDeduccion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("montootraDeduccion", ::cmontootraDeduccion, ::cmontootraDeduccion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure PagoTercero

WSSTRUCT Service_PagoTercero
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cmontopagotercero         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_PagoTercero
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_PagoTercero
Return

WSMETHOD CLONE WSCLIENT Service_PagoTercero
	Local oClone := Service_PagoTercero():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cmontopagotercero    := ::cmontopagotercero
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_PagoTercero
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("montopagotercero", ::cmontopagotercero, ::cmontopagotercero , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Salud

WSSTRUCT Service_Salud
	WSDATA   cdeduccion                AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cporcentaje               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Salud
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Salud
Return

WSMETHOD CLONE WSCLIENT Service_Salud
	Local oClone := Service_Salud():NEW()
	oClone:cdeduccion           := ::cdeduccion
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cporcentaje          := ::cporcentaje
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Salud
	Local cSoap := ""
	cSoap += WSSoapValue("deduccion", ::cdeduccion, ::cdeduccion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("porcentaje", ::cporcentaje, ::cporcentaje , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Sancion

WSSTRUCT Service_Sancion
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   csancionPriv              AS string OPTIONAL
	WSDATA   csancionPublic            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Sancion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Sancion
Return

WSMETHOD CLONE WSCLIENT Service_Sancion
	Local oClone := Service_Sancion():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:csancionPriv         := ::csancionPriv
	oClone:csancionPublic       := ::csancionPublic
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Sancion
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("sancionPriv", ::csancionPriv, ::csancionPriv , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("sancionPublic", ::csancionPublic, ::csancionPublic , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Sindicato

WSSTRUCT Service_Sindicato
	WSDATA   cdeduccion                AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cporcentaje               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Sindicato
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Sindicato
Return

WSMETHOD CLONE WSCLIENT Service_Sindicato
	Local oClone := Service_Sindicato():NEW()
	oClone:cdeduccion           := ::cdeduccion
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cporcentaje          := ::cporcentaje
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Sindicato
	Local cSoap := ""
	cSoap += WSSoapValue("deduccion", ::cdeduccion, ::cdeduccion , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("porcentaje", ::cporcentaje, ::cporcentaje , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Auxilio

WSSTRUCT Service_Auxilio
	WSDATA   cauxilioNS                AS string OPTIONAL
	WSDATA   cauxilioS                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Auxilio
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Auxilio
Return

WSMETHOD CLONE WSCLIENT Service_Auxilio
	Local oClone := Service_Auxilio():NEW()
	oClone:cauxilioNS           := ::cauxilioNS
	oClone:cauxilioS            := ::cauxilioS
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Auxilio
	Local cSoap := ""
	cSoap += WSSoapValue("auxilioNS", ::cauxilioNS, ::cauxilioNS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("auxilioS", ::cauxilioS, ::cauxilioS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Basico

WSSTRUCT Service_Basico
	WSDATA   cdiasTrabajados           AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   csueldoTrabajado          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Basico
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Basico
Return

WSMETHOD CLONE WSCLIENT Service_Basico
	Local oClone := Service_Basico():NEW()
	oClone:cdiasTrabajados      := ::cdiasTrabajados
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:csueldoTrabajado     := ::csueldoTrabajado
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Basico
	Local cSoap := ""
	cSoap += WSSoapValue("diasTrabajados", ::cdiasTrabajados, ::cdiasTrabajados , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("sueldoTrabajado", ::csueldoTrabajado, ::csueldoTrabajado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Bonificacion

WSSTRUCT Service_Bonificacion
	WSDATA   cbonificacionNS           AS string OPTIONAL
	WSDATA   cbonificacionS            AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Bonificacion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Bonificacion
Return

WSMETHOD CLONE WSCLIENT Service_Bonificacion
	Local oClone := Service_Bonificacion():NEW()
	oClone:cbonificacionNS      := ::cbonificacionNS
	oClone:cbonificacionS       := ::cbonificacionS
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Bonificacion
	Local cSoap := ""
	cSoap += WSSoapValue("bonificacionNS", ::cbonificacionNS, ::cbonificacionNS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("bonificacionS", ::cbonificacionS, ::cbonificacionS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure BonoEPCTV

WSSTRUCT Service_BonoEPCTV
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cpagoAlimentacionNS       AS string OPTIONAL
	WSDATA   cpagoAlimentacionS        AS string OPTIONAL
	WSDATA   cpagoNS                   AS string OPTIONAL
	WSDATA   cpagoS                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_BonoEPCTV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_BonoEPCTV
Return

WSMETHOD CLONE WSCLIENT Service_BonoEPCTV
	Local oClone := Service_BonoEPCTV():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cpagoAlimentacionNS  := ::cpagoAlimentacionNS
	oClone:cpagoAlimentacionS   := ::cpagoAlimentacionS
	oClone:cpagoNS              := ::cpagoNS
	oClone:cpagoS               := ::cpagoS
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_BonoEPCTV
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagoAlimentacionNS", ::cpagoAlimentacionNS, ::cpagoAlimentacionNS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagoAlimentacionS", ::cpagoAlimentacionS, ::cpagoAlimentacionS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagoNS", ::cpagoNS, ::cpagoNS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagoS", ::cpagoS, ::cpagoS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Cesantia

WSSTRUCT Service_Cesantia
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cpago                     AS string OPTIONAL
	WSDATA   cpagoIntereses            AS string OPTIONAL
	WSDATA   cporcentaje               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Cesantia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Cesantia
Return

WSMETHOD CLONE WSCLIENT Service_Cesantia
	Local oClone := Service_Cesantia():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cpago                := ::cpago
	oClone:cpagoIntereses       := ::cpagoIntereses
	oClone:cporcentaje          := ::cporcentaje
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Cesantia
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pago", ::cpago, ::cpago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagoIntereses", ::cpagoIntereses, ::cpagoIntereses , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("porcentaje", ::cporcentaje, ::cporcentaje , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Comision

WSSTRUCT Service_Comision
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cmontocomision            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Comision
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Comision
Return

WSMETHOD CLONE WSCLIENT Service_Comision
	Local oClone := Service_Comision():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cmontocomision       := ::cmontocomision
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Comision
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("montocomision", ::cmontocomision, ::cmontocomision , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Compensacion

WSSTRUCT Service_Compensacion
	WSDATA   ccompensacionE            AS string OPTIONAL
	WSDATA   ccompensacionO            AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Compensacion
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Compensacion
Return

WSMETHOD CLONE WSCLIENT Service_Compensacion
	Local oClone := Service_Compensacion():NEW()
	oClone:ccompensacionE       := ::ccompensacionE
	oClone:ccompensacionO       := ::ccompensacionO
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Compensacion
	Local cSoap := ""
	cSoap += WSSoapValue("compensacionE", ::ccompensacionE, ::ccompensacionE , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("compensacionO", ::ccompensacionO, ::ccompensacionO , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure HoraExtra

WSSTRUCT Service_HoraExtra
	WSDATA   ccantidad                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   choraFin                  AS string OPTIONAL
	WSDATA   choraInicio               AS string OPTIONAL
	WSDATA   cpago                     AS string OPTIONAL
	WSDATA   cporcentaje               AS string OPTIONAL
	WSDATA   ctipoHorasExtra           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_HoraExtra
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_HoraExtra
Return

WSMETHOD CLONE WSCLIENT Service_HoraExtra
	Local oClone := Service_HoraExtra():NEW()
	oClone:ccantidad            := ::ccantidad
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:choraFin             := ::choraFin
	oClone:choraInicio          := ::choraInicio
	oClone:cpago                := ::cpago
	oClone:cporcentaje          := ::cporcentaje
	oClone:ctipoHorasExtra      := ::ctipoHorasExtra
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_HoraExtra
	Local cSoap := ""
	cSoap += WSSoapValue("cantidad", ::ccantidad, ::ccantidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("horaFin", ::choraFin, ::choraFin , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("horaInicio", ::choraInicio, ::choraInicio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pago", ::cpago, ::cpago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("porcentaje", ::cporcentaje, ::cporcentaje , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipoHorasExtra", ::ctipoHorasExtra, ::ctipoHorasExtra , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure HuelgaLegal

WSSTRUCT Service_HuelgaLegal
	WSDATA   ccantidad                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cfechaFin                 AS string OPTIONAL
	WSDATA   cfechaInicio              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_HuelgaLegal
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_HuelgaLegal
Return

WSMETHOD CLONE WSCLIENT Service_HuelgaLegal
	Local oClone := Service_HuelgaLegal():NEW()
	oClone:ccantidad            := ::ccantidad
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cfechaFin            := ::cfechaFin
	oClone:cfechaInicio         := ::cfechaInicio
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_HuelgaLegal
	Local cSoap := ""
	cSoap += WSSoapValue("cantidad", ::ccantidad, ::ccantidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaFin", ::cfechaFin, ::cfechaFin , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaInicio", ::cfechaInicio, ::cfechaInicio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Incapacidad

WSSTRUCT Service_Incapacidad
	WSDATA   ccantidad                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cfechaFin                 AS string OPTIONAL
	WSDATA   cfechaInicio              AS string OPTIONAL
	WSDATA   cpago                     AS string OPTIONAL
	WSDATA   ctipo                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Incapacidad
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Incapacidad
Return

WSMETHOD CLONE WSCLIENT Service_Incapacidad
	Local oClone := Service_Incapacidad():NEW()
	oClone:ccantidad            := ::ccantidad
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cfechaFin            := ::cfechaFin
	oClone:cfechaInicio         := ::cfechaInicio
	oClone:cpago                := ::cpago
	oClone:ctipo                := ::ctipo
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Incapacidad
	Local cSoap := ""
	cSoap += WSSoapValue("cantidad", ::ccantidad, ::ccantidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaFin", ::cfechaFin, ::cfechaFin , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaInicio", ::cfechaInicio, ::cfechaInicio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pago", ::cpago, ::cpago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("tipo", ::ctipo, ::ctipo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfLicencia

WSSTRUCT Service_ArrayOfLicencia
	WSDATA   oWSLicencia               AS Service_Licencia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfLicencia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfLicencia
	::oWSLicencia          := {} // Array Of  Service_LICENCIA():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfLicencia
	Local oClone := Service_ArrayOfLicencia():NEW()
	oClone:oWSLicencia := NIL
	If ::oWSLicencia <> NIL 
		oClone:oWSLicencia := {}
		aEval( ::oWSLicencia , { |x| aadd( oClone:oWSLicencia , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfLicencia
	Local cSoap := ""
	aEval( ::oWSLicencia , {|x| cSoap := cSoap  +  WSSoapValue("Licencia", x , x , "Licencia", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure OtroConcepto

WSSTRUCT Service_OtroConcepto
	WSDATA   cconceptoNS               AS string OPTIONAL
	WSDATA   cconceptoS                AS string OPTIONAL
	WSDATA   cdescripcionConcepto      AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_OtroConcepto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_OtroConcepto
Return

WSMETHOD CLONE WSCLIENT Service_OtroConcepto
	Local oClone := Service_OtroConcepto():NEW()
	oClone:cconceptoNS          := ::cconceptoNS
	oClone:cconceptoS           := ::cconceptoS
	oClone:cdescripcionConcepto := ::cdescripcionConcepto
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_OtroConcepto
	Local cSoap := ""
	cSoap += WSSoapValue("conceptoNS", ::cconceptoNS, ::cconceptoNS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("conceptoS", ::cconceptoS, ::cconceptoS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("descripcionConcepto", ::cdescripcionConcepto, ::cdescripcionConcepto , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Prima

WSSTRUCT Service_Prima
	WSDATA   ccantidad                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cpago                     AS string OPTIONAL
	WSDATA   cpagoNS                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Prima
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Prima
Return

WSMETHOD CLONE WSCLIENT Service_Prima
	Local oClone := Service_Prima():NEW()
	oClone:ccantidad            := ::ccantidad
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cpago                := ::cpago
	oClone:cpagoNS              := ::cpagoNS
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Prima
	Local cSoap := ""
	cSoap += WSSoapValue("cantidad", ::ccantidad, ::ccantidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pago", ::cpago, ::cpago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pagoNS", ::cpagoNS, ::cpagoNS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Transporte

WSSTRUCT Service_Transporte
	WSDATA   cauxilioTransporte        AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cviaticoManuAlojNS        AS string OPTIONAL
	WSDATA   cviaticoManuAlojS         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Transporte
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Transporte
Return

WSMETHOD CLONE WSCLIENT Service_Transporte
	Local oClone := Service_Transporte():NEW()
	oClone:cauxilioTransporte   := ::cauxilioTransporte
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cviaticoManuAlojNS   := ::cviaticoManuAlojNS
	oClone:cviaticoManuAlojS    := ::cviaticoManuAlojS
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Transporte
	Local cSoap := ""
	cSoap += WSSoapValue("auxilioTransporte", ::cauxilioTransporte, ::cauxilioTransporte , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("viaticoManuAlojNS", ::cviaticoManuAlojNS, ::cviaticoManuAlojNS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("viaticoManuAlojS", ::cviaticoManuAlojS, ::cviaticoManuAlojS , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfVacaciones

WSSTRUCT Service_ArrayOfVacaciones
	WSDATA   oWSVacaciones             AS Service_Vacaciones OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfVacaciones
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfVacaciones
	::oWSVacaciones        := {} // Array Of  Service_VACACIONES():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfVacaciones
	Local oClone := Service_ArrayOfVacaciones():NEW()
	oClone:oWSVacaciones := NIL
	If ::oWSVacaciones <> NIL 
		oClone:oWSVacaciones := {}
		aEval( ::oWSVacaciones , { |x| aadd( oClone:oWSVacaciones , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfVacaciones
	Local cSoap := ""
	aEval( ::oWSVacaciones , {|x| cSoap := cSoap  +  WSSoapValue("Vacaciones", x , x , "Vacaciones", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfFechaPago

WSSTRUCT Service_ArrayOfFechaPago
	WSDATA   oWSFechaPago              AS Service_FechaPago OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_ArrayOfFechaPago
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_ArrayOfFechaPago
	::oWSFechaPago         := {} // Array Of  Service_FECHAPAGO():New()
Return

WSMETHOD CLONE WSCLIENT Service_ArrayOfFechaPago
	Local oClone := Service_ArrayOfFechaPago():NEW()
	oClone:oWSFechaPago := NIL
	If ::oWSFechaPago <> NIL 
		oClone:oWSFechaPago := {}
		aEval( ::oWSFechaPago , { |x| aadd( oClone:oWSFechaPago , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_ArrayOfFechaPago
	Local cSoap := ""
	aEval( ::oWSFechaPago , {|x| cSoap := cSoap  +  WSSoapValue("FechaPago", x , x , "FechaPago", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Licencia

WSSTRUCT Service_Licencia
	WSDATA   ccantidad                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cfechaFin                 AS string OPTIONAL
	WSDATA   cfechaInicio              AS string OPTIONAL
	WSDATA   cpago                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Licencia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Licencia
Return

WSMETHOD CLONE WSCLIENT Service_Licencia
	Local oClone := Service_Licencia():NEW()
	oClone:ccantidad            := ::ccantidad
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cfechaFin            := ::cfechaFin
	oClone:cfechaInicio         := ::cfechaInicio
	oClone:cpago                := ::cpago
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Licencia
	Local cSoap := ""
	cSoap += WSSoapValue("cantidad", ::ccantidad, ::ccantidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaFin", ::cfechaFin, ::cfechaFin , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaInicio", ::cfechaInicio, ::cfechaInicio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pago", ::cpago, ::cpago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure Vacaciones

WSSTRUCT Service_Vacaciones
	WSDATA   ccantidad                 AS string OPTIONAL
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cfechaFin                 AS string OPTIONAL
	WSDATA   cfechaInicio              AS string OPTIONAL
	WSDATA   cpago                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_Vacaciones
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_Vacaciones
Return

WSMETHOD CLONE WSCLIENT Service_Vacaciones
	Local oClone := Service_Vacaciones():NEW()
	oClone:ccantidad            := ::ccantidad
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cfechaFin            := ::cfechaFin
	oClone:cfechaInicio         := ::cfechaInicio
	oClone:cpago                := ::cpago
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_Vacaciones
	Local cSoap := ""
	cSoap += WSSoapValue("cantidad", ::ccantidad, ::ccantidad , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaFin", ::cfechaFin, ::cfechaFin , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechaInicio", ::cfechaInicio, ::cfechaInicio , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("pago", ::cpago, ::cpago , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap

// WSDL Data Structure FechaPago

WSSTRUCT Service_FechaPago
	WSDATA   oWSextrasNom              AS Service_ArrayOfExtensibleNom OPTIONAL
	WSDATA   cfechapagonomina          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_FechaPago
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_FechaPago
Return

WSMETHOD CLONE WSCLIENT Service_FechaPago
	Local oClone := Service_FechaPago():NEW()
	oClone:oWSextrasNom         := IIF(::oWSextrasNom = NIL , NIL , ::oWSextrasNom:Clone() )
	oClone:cfechapagonomina     := ::cfechapagonomina
Return oClone

WSMETHOD SOAPSEND WSCLIENT Service_FechaPago
	Local cSoap := ""
	cSoap += WSSoapValue("extrasNom", ::oWSextrasNom, ::oWSextrasNom , "ArrayOfExtensibleNom", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
	cSoap += WSSoapValue("fechapagonomina", ::cfechapagonomina, ::cfechapagonomina , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.Models.Documents", .F.,.F.) 
Return cSoap


