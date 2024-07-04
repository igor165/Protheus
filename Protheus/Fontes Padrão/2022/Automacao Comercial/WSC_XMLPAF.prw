#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx?WSDL
Gerado em        02/04/20 15:13:31
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _RJUAKFL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSBlocoX
------------------------------------------------------------------------------- */

WSCLIENT WSBlocoX

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD TransmitirArquivo
	WSMETHOD ConsultarProcessamentoArquivo
	WSMETHOD DownloadArquivo
	WSMETHOD CancelarArquivo
	WSMETHOD ReprocessarArquivo
	WSMETHOD ConsultarPendenciasDesenvolvedorPafEcf
	WSMETHOD ConsultarPendenciasContribuinte
	WSMETHOD ListarArquivos
	WSMETHOD ConsultarHistoricoArquivo
	WSMETHOD ConsultarStatusMetodosBlocoX

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cpXmlCompactado           AS base64Binary
	WSDATA   cTransmitirArquivoResult  AS string
	WSDATA   cpXml                     AS string
	WSDATA   cConsultarProcessamentoArquivoResult AS string
	WSDATA   cDownloadArquivoResult    AS string
	WSDATA   cCancelarArquivoResult    AS string
	WSDATA   cReprocessarArquivoResult AS string
	WSDATA   cConsultarPendenciasDesenvolvedorPafEcfResult AS string
	WSDATA   cConsultarPendenciasContribuinteResult AS string
	WSDATA   cListarArquivosResult     AS string
	WSDATA   cConsultarHistoricoArquivoResult AS string
	WSDATA   cConsultarStatusMetodosBlocoXResult AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSBlocoX
::Init()
If !ExistFunc("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20190628] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSBlocoX
Return

WSMETHOD RESET WSCLIENT WSBlocoX
	::cpXmlCompactado    := NIL 
	::cTransmitirArquivoResult := NIL 
	::cpXml              := NIL 
	::cConsultarProcessamentoArquivoResult := NIL 
	::cDownloadArquivoResult := NIL 
	::cCancelarArquivoResult := NIL 
	::cReprocessarArquivoResult := NIL 
	::cConsultarPendenciasDesenvolvedorPafEcfResult := NIL 
	::cConsultarPendenciasContribuinteResult := NIL 
	::cListarArquivosResult := NIL 
	::cConsultarHistoricoArquivoResult := NIL 
	::cConsultarStatusMetodosBlocoXResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSBlocoX
Local oClone := WSBlocoX():New()
	oClone:_URL          := ::_URL 
	oClone:cpXmlCompactado := ::cpXmlCompactado
	oClone:cTransmitirArquivoResult := ::cTransmitirArquivoResult
	oClone:cpXml         := ::cpXml
	oClone:cConsultarProcessamentoArquivoResult := ::cConsultarProcessamentoArquivoResult
	oClone:cDownloadArquivoResult := ::cDownloadArquivoResult
	oClone:cCancelarArquivoResult := ::cCancelarArquivoResult
	oClone:cReprocessarArquivoResult := ::cReprocessarArquivoResult
	oClone:cConsultarPendenciasDesenvolvedorPafEcfResult := ::cConsultarPendenciasDesenvolvedorPafEcfResult
	oClone:cConsultarPendenciasContribuinteResult := ::cConsultarPendenciasContribuinteResult
	oClone:cListarArquivosResult := ::cListarArquivosResult
	oClone:cConsultarHistoricoArquivoResult := ::cConsultarHistoricoArquivoResult
	oClone:cConsultarStatusMetodosBlocoXResult := ::cConsultarStatusMetodosBlocoXResult
Return oClone

// WSDL Method TransmitirArquivo of Service WSBlocoX

WSMETHOD TransmitirArquivo WSSEND cpXmlCompactado WSRECEIVE cTransmitirArquivoResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TransmitirArquivo xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXmlCompactado", ::cpXmlCompactado, cpXmlCompactado , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</TransmitirArquivo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/TransmitirArquivo",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cTransmitirArquivoResult :=  WSAdvValue( oXmlRet,"_TRANSMITIRARQUIVORESPONSE:_TRANSMITIRARQUIVORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarProcessamentoArquivo of Service WSBlocoX

WSMETHOD ConsultarProcessamentoArquivo WSSEND cpXml WSRECEIVE cConsultarProcessamentoArquivoResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarProcessamentoArquivo xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXml", ::cpXml, cpXml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultarProcessamentoArquivo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/ConsultarProcessamentoArquivo",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cConsultarProcessamentoArquivoResult :=  WSAdvValue( oXmlRet,"_CONSULTARPROCESSAMENTOARQUIVORESPONSE:_CONSULTARPROCESSAMENTOARQUIVORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DownloadArquivo of Service WSBlocoX

WSMETHOD DownloadArquivo WSSEND cpXml WSRECEIVE cDownloadArquivoResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DownloadArquivo xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXml", ::cpXml, cpXml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DownloadArquivo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/DownloadArquivo",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cDownloadArquivoResult :=  WSAdvValue( oXmlRet,"_DOWNLOADARQUIVORESPONSE:_DOWNLOADARQUIVORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelarArquivo of Service WSBlocoX

WSMETHOD CancelarArquivo WSSEND cpXml WSRECEIVE cCancelarArquivoResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelarArquivo xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXml", ::cpXml, cpXml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CancelarArquivo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/CancelarArquivo",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cCancelarArquivoResult :=  WSAdvValue( oXmlRet,"_CANCELARARQUIVORESPONSE:_CANCELARARQUIVORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ReprocessarArquivo of Service WSBlocoX

WSMETHOD ReprocessarArquivo WSSEND cpXml WSRECEIVE cReprocessarArquivoResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ReprocessarArquivo xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXml", ::cpXml, cpXml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ReprocessarArquivo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/ReprocessarArquivo",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cReprocessarArquivoResult :=  WSAdvValue( oXmlRet,"_REPROCESSARARQUIVORESPONSE:_REPROCESSARARQUIVORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarPendenciasDesenvolvedorPafEcf of Service WSBlocoX

WSMETHOD ConsultarPendenciasDesenvolvedorPafEcf WSSEND cpXml WSRECEIVE cConsultarPendenciasDesenvolvedorPafEcfResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarPendenciasDesenvolvedorPafEcf xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXml", ::cpXml, cpXml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultarPendenciasDesenvolvedorPafEcf>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/ConsultarPendenciasDesenvolvedorPafEcf",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cConsultarPendenciasDesenvolvedorPafEcfResult :=  WSAdvValue( oXmlRet,"_CONSULTARPENDENCIASDESENVOLVEDORPAFECFRESPONSE:_CONSULTARPENDENCIASDESENVOLVEDORPAFECFRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarPendenciasContribuinte of Service WSBlocoX

WSMETHOD ConsultarPendenciasContribuinte WSSEND cpXml WSRECEIVE cConsultarPendenciasContribuinteResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarPendenciasContribuinte xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXml", ::cpXml, cpXml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultarPendenciasContribuinte>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/ConsultarPendenciasContribuinte",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cConsultarPendenciasContribuinteResult :=  WSAdvValue( oXmlRet,"_CONSULTARPENDENCIASCONTRIBUINTERESPONSE:_CONSULTARPENDENCIASCONTRIBUINTERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListarArquivos of Service WSBlocoX

WSMETHOD ListarArquivos WSSEND cpXml WSRECEIVE cListarArquivosResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListarArquivos xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXml", ::cpXml, cpXml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ListarArquivos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/ListarArquivos",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cListarArquivosResult :=  WSAdvValue( oXmlRet,"_LISTARARQUIVOSRESPONSE:_LISTARARQUIVOSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarHistoricoArquivo of Service WSBlocoX

WSMETHOD ConsultarHistoricoArquivo WSSEND cpXml WSRECEIVE cConsultarHistoricoArquivoResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarHistoricoArquivo xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += WSSoapValue("pXml", ::cpXml, cpXml , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultarHistoricoArquivo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/ConsultarHistoricoArquivo",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cConsultarHistoricoArquivoResult :=  WSAdvValue( oXmlRet,"_CONSULTARHISTORICOARQUIVORESPONSE:_CONSULTARHISTORICOARQUIVORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarStatusMetodosBlocoX of Service WSBlocoX

WSMETHOD ConsultarStatusMetodosBlocoX WSSEND NULLPARAM WSRECEIVE cConsultarStatusMetodosBlocoXResult WSCLIENT WSBlocoX
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarStatusMetodosBlocoX xmlns="http://webservices.sef.sc.gov.br/wsDfeSiv/">'
cSoap += "</ConsultarStatusMetodosBlocoX>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/ConsultarStatusMetodosBlocoX",; 
	"DOCUMENT","http://webservices.sef.sc.gov.br/wsDfeSiv/",,,; 
	"http://webservices.sef.sc.gov.br/wsDfeSiv/BlocoX.asmx")

::Init()
::cConsultarStatusMetodosBlocoXResult :=  WSAdvValue( oXmlRet,"_CONSULTARSTATUSMETODOSBLOCOXRESPONSE:_CONSULTARSTATUSMETODOSBLOCOXRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.