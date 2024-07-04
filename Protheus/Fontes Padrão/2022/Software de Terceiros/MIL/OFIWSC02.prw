////////////////
// Versao 003 //
////////////////

#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    \services.xml
Gerado em        09/03/15 18:01:30
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function OFIWSC02 ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSMIL_ScaniaAssist
------------------------------------------------------------------------------- */

WSCLIENT WSMIL_ScaniaAssist

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD SetGOPDealer
	WSMETHOD GetGOP

	WSMETHOD ExibeErro
	WSMETHOD SetDebug
	
	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ncustomerId               AS long
	WSDATA   ndealerId                 AS int
	WSDATA   cisHomeDealer             AS string
	WSDATA   ngopValue                 AS decimal
	WSDATA   cgopValidityDate          AS dateTime
	WSDATA   oWSSetGOPDealerResult     AS MIL_ScaniaAssist_Services_Response
	WSDATA   nGetGOPResult             AS decimal
	WSDATA   cremarks                  AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSMIL_ScaniaAssist
	::Init()
	If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150410] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
	If val(right(GetWSCVer(),8)) < 1.040504
		UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
	EndIf
	If !GetMv("MV_MIL0063",.T.,) .or. Empty(GetMv("MV_MIL0063"))
		Alert("Parâmetro de comunicacao com o Portal nao está configurado.")
	EndIf

Return Self

WSMETHOD INIT WSCLIENT WSMIL_ScaniaAssist
	::oWSSetGOPDealerResult := MIL_ScaniaAssist_Services_Response():New()
	
	::_URL := GetMV("MV_MIL0063") // "http://192.168.1.4/ws/Services.svc"
	
Return

WSMETHOD RESET WSCLIENT WSMIL_ScaniaAssist
	::ncustomerId        := NIL 
	::ndealerId          := NIL 
	::cisHomeDealer      := NIL 
	::ngopValue          := NIL 
	::cgopValidityDate   := NIL 
	::oWSSetGOPDealerResult := NIL 
	::nGetGOPResult      := NIL
	::cremarks           := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSMIL_ScaniaAssist
Local oClone := WSMIL_ScaniaAssist():New()
//	oClone:_URL          := ::_URL 
	oClone:ncustomerId   := ::ncustomerId
	oClone:ndealerId     := ::ndealerId
	oClone:cisHomeDealer := ::cisHomeDealer
	oClone:ngopValue     := ::ngopValue
	oClone:cgopValidityDate := ::cgopValidityDate
	oClone:oWSSetGOPDealerResult :=  IIF(::oWSSetGOPDealerResult = NIL , NIL ,::oWSSetGOPDealerResult:Clone() )
	oClone:nGetGOPResult := ::nGetGOPResult
	oClone:cremarks      := ::cremarks
Return oClone

// WSDL Method SetGOPDealer of Service WSMIL_ScaniaAssist

WSMETHOD SetGOPDealer WSSEND ncustomerId,ndealerId,cisHomeDealer,ngopValue,cgopValidityDate,cHoraAtendimento WSRECEIVE oWSSetGOPDealerResult WSCLIENT WSMIL_ScaniaAssist
Local cSoap := "" , oXmlRet

Default cHoraAtendimento := ""

BEGIN WSMETHOD

cSoap += '<SetGOPDealer xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("customerId", ::ncustomerId, ncustomerId , "long", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("dealerId", ::ndealerId, ndealerId , "int", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("isHomeDealer", ::cisHomeDealer, cisHomeDealer , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("gopValue", ::ngopValue, ngopValue , "decimal", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("gopValidityDate", ::cgopValidityDate, cgopValidityDate , "dateTime", .F. , .F., 0 , NIL, .F.)
If cHoraAtendimento == "1"
	cSoap += WSSoapValue("remarks", ::cremarks, EncodeUtf8("Lista Branca válida durante horário do expediente") , "string", .F. , .F., 0 , NIL, .F.)
EndIf 
cSoap += "</SetGOPDealer>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IServices/SetGOPDealer",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	::_URL)

::Init()
::oWSSetGOPDealerResult:SoapRecv( WSAdvValue( oXmlRet,"_SETGOPDEALERRESPONSE:_SETGOPDEALERRESULT","Response",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetGOP of Service WSMIL_ScaniaAssist

WSMETHOD GetGOP WSSEND NULLPARAM WSRECEIVE nGetGOPResult WSCLIENT WSMIL_ScaniaAssist
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetGOP xmlns="http://tempuri.org/">'
cSoap += "</GetGOP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IServices/GetGOP",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	::_URL)

::Init()
::nGetGOPResult      :=  WSAdvValue( oXmlRet,"_GETGOPRESPONSE:_GETGOPRESULT:TEXT","decimal",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

WSMETHOD SetDebug WSCLIENT WSMIL_ScaniaAssist
	WSDLDbgLevel(2)
	WSDLSaveXML(.t.)
	WSDLSetProfile(.t.) 
Return

WSMETHOD ExibeErro WSSEND cMensagem WSCLIENT WSMIL_ScaniaAssist

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	
	Default cMensagem := ""
	
	If !Empty(cSoapFCode)
		// Caso a ocorrência de erro esteja com o fault_code preenchido ,
		// a mesma teve relação com a chamada do serviço .
		MsgStop(cMensagem + chr(13) + chr(10) + cSoapFDescr,cSoapFCode)
	Else
		// Caso a ocorrência não tenha o soap_code preenchido
		// Ela está relacionada a uma outra falha ,
		// provavelmente local ou interna.
		MsgStop(cMensagem + chr(13) + chr(10) + cSvcError,"Falha Interna")
	Endif

Return


// WSDL Data Structure Response

WSSTRUCT MIL_ScaniaAssist_Services_Response
	WSDATA   oWSStatus                 AS MIL_ScaniaAssist_Services_OperationsStatus OPTIONAL
	WSDATA   cMessage                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaAssist_Services_Response
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaAssist_Services_Response
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaAssist_Services_Response
	Local oClone := MIL_ScaniaAssist_Services_Response():NEW()
	oClone:oWSStatus            := IIF(::oWSStatus = NIL , NIL , ::oWSStatus:Clone() )
	oClone:cMessage             := ::cMessage
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaAssist_Services_Response
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_STATUS","OperationsStatus",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode1 != NIL
		::oWSStatus := MIL_ScaniaAssist_Services_OperationsStatus():New()
		::oWSStatus:SoapRecv(oNode1)
	EndIf
	::cMessage           :=  WSAdvValue( oResponse,"_MESSAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Enumeration OperationsStatus

WSSTRUCT MIL_ScaniaAssist_Services_OperationsStatus
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaAssist_Services_OperationsStatus
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "SUCCESS" )
	aadd(::aValueList , "ERROR" )
Return Self

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaAssist_Services_OperationsStatus
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaAssist_Services_OperationsStatus
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT MIL_ScaniaAssist_Services_OperationsStatus
Local oClone := MIL_ScaniaAssist_Services_OperationsStatus():New()
	oClone:Value := ::Value
Return oClone


