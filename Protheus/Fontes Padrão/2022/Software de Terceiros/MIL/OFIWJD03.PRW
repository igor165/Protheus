// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 09     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#include "OFIWJD03.CH"

/* ===============================================================================
WSDL Location    https://parts.deere.com/dns/wsdl/stage/OrderStatusWS_1_2.wsdl
Gerado em        08/28/13 08:48:10
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function OFIWJD03()
Return

/* -------------------------------------------------------------------------------
WSDL Service WSJohnDeereJDPoint_Pedido_Compra
------------------------------------------------------------------------------- */

WSCLIENT WSJohnDeereJDPoint_Pedido_Compra

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD retrieveOrderStatus
	
	WSMETHOD ExibeErro
	WSMETHOD SetDebug
	
	WSDATA   _URL                      AS String
	WSDATA   _SOAP_ACTION              AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA	 ERRO
	
	WSDATA _USER   AS String
	WSDATA _PASSWD AS String
	
	
	WSDATA   cuserId                   AS string
	WSDATA   caccountNumber            AS string
	WSDATA   corderNumber              AS string
	WSDATA   oOrderStatusReturn AS JD_POINT_PEDC_OrderStatusWSBean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSJohnDeereJDPoint_Pedido_Compra
	::Init()
	::ERRO := .f.

	If Empty(::_USER) .or. Empty(::_PASSWD)
		MsgStop(STR0004,STR0002) // O seu cadastro de Equipe Técnica (OFIOA180) está com os campos referentes ao usuário X e senha do portal da John Deere em branco (campo VAI_FABUSR e campo VAI_FABPWD). Por favor verifique junto ao administrador do sistema! // Atenção!
		::ERRO := .t.
	EndIf
	
Return Self

WSMETHOD INIT WSCLIENT WSJohnDeereJDPoint_Pedido_Compra
	::oOrderStatusReturn := JD_POINT_PEDC_ORDERSTATUSWSBEAN():New()
	
	::_URL := GetMV("MV_MIL0044")   

	OFW30031_SetUserPasswd(@self:_USER, @self:_PASSWD)
	
	::_SOAP_ACTION := "http://v1_2.ostat.services.view.jdpoint.parts.deere.com"
	
	::_HEADOUT := {}
	aadd( ::_HEADOUT , "Authorization: Basic "+Encode64(::_USER+":"+::_PASSWD ) )
	aadd( ::_HEADOUT , "Timeout: 300000 " )
Return

WSMETHOD RESET WSCLIENT WSJohnDeereJDPoint_Pedido_Compra
	::cuserId            := NIL 
	::caccountNumber     := NIL 
	::corderNumber       := NIL 
	::oOrderStatusReturn := NIL 
	::Init()
Return

WSMETHOD SetDebug WSCLIENT WSJohnDeereJDPoint_Pedido_Compra
	WSDLDbgLevel(2)
	WSDLSaveXML(.t.)
	WSDLSetProfile(.t.)
Return

WSMETHOD CLONE WSCLIENT WSJohnDeereJDPoint_Pedido_Compra
Local oClone := WSJohnDeereJDPoint_Pedido_Compra():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:cuserId       := ::cuserId
	oClone:caccountNumber := ::caccountNumber
	oClone:corderNumber  := ::corderNumber
	oClone:oOrderStatusReturn :=  IIF(::oOrderStatusReturn = NIL , NIL ,::oOrderStatusReturn:Clone() )
Return oClone

WSMETHOD retrieveOrderStatus WSSEND oOrderStatusReturn WSCLIENT WSJohnDeereJDPoint_Pedido_Compra

Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<retrieveOrderStatus xmlns="http://v1_2.ostat.services.view.jdpoint.parts.deere.com">'
cSoap += WSSoapValue("userId", ::cuserId, ::cuserId , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("accountNumber", ::caccountNumber, ::caccountNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("orderNumber", ::corderNumber, ::corderNumber , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</retrieveOrderStatus>"

oXmlRet := SvcSoapCall(	Self,;
	cSoap,; 
	::_SOAP_ACTION,; 
	"DOCUMENT",;
	::_SOAP_ACTION,,,; 
	::_URL)

::Init()
::oOrderStatusReturn:SoapRecv( WSAdvValue( oXmlRet,"_P66_RETRIEVEORDERSTATUSRESPONSE:_P66_RETRIEVEORDERSTATUSRETURN","OrderStatusWSBean",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


WSMETHOD ExibeErro WSCLIENT WSJohnDeereJDPoint_Pedido_Compra

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	//Local cXMLError	:= GetWSCError(4)
	If !Empty(cSoapFCode)
		// Caso a ocorrÃªncia de erro esteja com o fault_code preenchido ,
		// a mesma teve relaÃ§Ã£o com a chamada do serviÃ§o .
		MsgStop(cSoapFDescr,cSoapFCode)
		//Aviso("Erro",cXMLError,{"Ok"},2)
	Else
		// Caso a ocorrÃªncia nÃ£o tenha o soap_code preenchido
		// Ela estÃ¡ relacionada a uma outra falha ,
		// provavelmente local ou interna.

		if "WSCERR044" $ cSvcError .and.  "11001" $ cSvcError // Host not found - endereço não encontrado  
			MsgStop(STR0009,STR0002) // O Webservice da John Deere retornou informando que o endereço para comunicação com o Webservice informado no parâmetro MV_MIL0044 está incorreto. Por favor verifique junto ao administrador do sistema! //Atenção!
		Elseif "WSCERR044" $ cSvcError .and. "401" $ cSvcError // Authorization required - usuário x e senha
			MsgStop(STR0010,STR0002) // O Webservice da John Deere retornou informando que seu usuário x e senha do portal da John Deere não possui o acesso necessário ou que está incorreto. Por favor, verifique se sua senha não está vencida ou se foi alterada recentemente. Em caso de dúvidas, verifique junto ao administrador do sistema! //Atenção!
		Elseif "WSCERR064" $ cSvcError
			MsgStop(STR0011,STR0002) // O Webservice da John Deere retornou informando que o endereço para comunicação com o Webservice informado no parâmetro MV_MIL0044 está incorreto. Por favor verifique junto ao administrador do sistema! //Atenção!
		Else
			MsgStop(cSvcError,STR0008) // Erro no retorno do Webservice da John Deere!
		Endif
	Endif

Return


// WSDL Data Structure OrderStatusWSBean

WSSTRUCT JD_POINT_PEDC_OrderStatusWSBean
	WSDATA   cversion                  AS string OPTIONAL
	WSDATA   caccountNumber            AS string OPTIONAL
	WSDATA   ccurrency                 AS string OPTIONAL
	WSDATA   cdateOrdered              AS string OPTIONAL
	WSDATA   cdealerRef                AS string OPTIONAL
	WSDATA   cdestination              AS string OPTIONAL
	WSDATA   cdiscountTotal            AS string OPTIONAL
	WSDATA   cestimatedOrderValue      AS string OPTIONAL
	WSDATA   cexceptionReport          AS string OPTIONAL
	WSDATA   cextendedPriceTotal       AS string OPTIONAL
	WSDATA   clastChanged              AS string OPTIONAL
	WSDATA   clineOfCredit             AS string OPTIONAL
	WSDATA   cmerchandiseTotal         AS string OPTIONAL
	WSDATA   corderNumber              AS string OPTIONAL
	WSDATA   corderStatus              AS string OPTIONAL
	WSDATA   corderType                AS string OPTIONAL
	WSDATA   cpartialShip              AS string OPTIONAL
	WSDATA   oWSorderNotes             AS JD_POINT_PEDC_Notes OPTIONAL
	WSDATA   oWSshipAddress            AS JD_POINT_PEDC_ShipAddress OPTIONAL
	WSDATA   oWSbillingAddress         AS JD_POINT_PEDC_BillingAddress OPTIONAL
	WSDATA   cpoolCode                 AS string OPTIONAL
	WSDATA   cprogramNumber            AS string OPTIONAL
	WSDATA   cprogramTerm              AS string OPTIONAL
	WSDATA   creturnCode               AS string OPTIONAL
	WSDATA   csubmittedBy              AS string OPTIONAL
	WSDATA   csurchargeTotal           AS string OPTIONAL
	WSDATA   cvin                      AS string OPTIONAL
	WSDATA   oWSorderLines             AS JD_POINT_PEDC_OrderLines OPTIONAL
	WSDATA   oWSshipments              AS JD_POINT_PEDC_Shipments OPTIONAL
	WSDATA   oWSinvestigations         AS JD_POINT_PEDC_Investigations OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_OrderStatusWSBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_OrderStatusWSBean
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_OrderStatusWSBean
	Local oClone := JD_POINT_PEDC_OrderStatusWSBean():NEW()
	oClone:cversion             := ::cversion
	oClone:caccountNumber       := ::caccountNumber
	oClone:ccurrency            := ::ccurrency
	oClone:cdateOrdered         := ::cdateOrdered
	oClone:cdealerRef           := ::cdealerRef
	oClone:cdestination         := ::cdestination
	oClone:cdiscountTotal       := ::cdiscountTotal
	oClone:cestimatedOrderValue := ::cestimatedOrderValue
	oClone:cexceptionReport     := ::cexceptionReport
	oClone:cextendedPriceTotal  := ::cextendedPriceTotal
	oClone:clastChanged         := ::clastChanged
	oClone:clineOfCredit        := ::clineOfCredit
	oClone:cmerchandiseTotal    := ::cmerchandiseTotal
	oClone:corderNumber         := ::corderNumber
	oClone:corderStatus         := ::corderStatus
	oClone:corderType           := ::corderType
	oClone:cpartialShip         := ::cpartialShip
	oClone:oWSorderNotes        := IIF(::oWSorderNotes = NIL , NIL , ::oWSorderNotes:Clone() )
	oClone:oWSshipAddress       := IIF(::oWSshipAddress = NIL , NIL , ::oWSshipAddress:Clone() )
	oClone:oWSbillingAddress    := IIF(::oWSbillingAddress = NIL , NIL , ::oWSbillingAddress:Clone() )
	oClone:cpoolCode            := ::cpoolCode
	oClone:cprogramNumber       := ::cprogramNumber
	oClone:cprogramTerm         := ::cprogramTerm
	oClone:creturnCode          := ::creturnCode
	oClone:csubmittedBy         := ::csubmittedBy
	oClone:csurchargeTotal      := ::csurchargeTotal
	oClone:cvin                 := ::cvin
	oClone:oWSorderLines        := IIF(::oWSorderLines = NIL , NIL , ::oWSorderLines:Clone() )
	oClone:oWSshipments         := IIF(::oWSshipments = NIL , NIL , ::oWSshipments:Clone() )
	oClone:oWSinvestigations    := IIF(::oWSinvestigations = NIL , NIL , ::oWSinvestigations:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_OrderStatusWSBean
	Local oNode18
	Local oNode19
	Local oNode20
	Local oNode28
	Local oNode29
	Local oNode30
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cversion             :=  WSAdvValue( oResponse,"_P499_VERSION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::caccountNumber       :=  WSAdvValue( oResponse,"_P499_ACCOUNTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccurrency            :=  WSAdvValue( oResponse,"_P499_CURRENCY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdateOrdered         :=  WSAdvValue( oResponse,"_P499_DATEORDERED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdealerRef           :=  WSAdvValue( oResponse,"_P499_DEALERREF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdestination         :=  WSAdvValue( oResponse,"_P499_DESTINATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdiscountTotal       :=  WSAdvValue( oResponse,"_P499_DISCOUNTTOTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cestimatedOrderValue :=  WSAdvValue( oResponse,"_P499_ESTIMATEDORDERVALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cexceptionReport     :=  WSAdvValue( oResponse,"_P499_EXCEPTIONREPORT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cextendedPriceTotal  :=  WSAdvValue( oResponse,"_P499_EXTENDEDPRICETOTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clastChanged         :=  WSAdvValue( oResponse,"_P499_LASTCHANGED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clineOfCredit        :=  WSAdvValue( oResponse,"_P499_LINEOFCREDIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmerchandiseTotal    :=  WSAdvValue( oResponse,"_P499_MERCHANDISETOTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::corderNumber         :=  WSAdvValue( oResponse,"_P499_ORDERNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::corderStatus         :=  WSAdvValue( oResponse,"_P499_ORDERSTATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::corderType           :=  WSAdvValue( oResponse,"_P499_ORDERTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartialShip         :=  WSAdvValue( oResponse,"_P499_PARTIALSHIP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode18 :=  WSAdvValue( oResponse,"_P499_ORDERNOTES","Notes",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode18 != NIL
		::oWSorderNotes := JD_POINT_PEDC_Notes():New()
		::oWSorderNotes:SoapRecv(oNode18)
	EndIf
	oNode19 :=  WSAdvValue( oResponse,"_P499_SHIPADDRESS","ShipAddress",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode19 != NIL
		::oWSshipAddress := JD_POINT_PEDC_ShipAddress():New()
		::oWSshipAddress:SoapRecv(oNode19)
	EndIf
	oNode20 :=  WSAdvValue( oResponse,"_P499_BILLINGADDRESS","BillingAddress",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode20 != NIL
		::oWSbillingAddress := JD_POINT_PEDC_BillingAddress():New()
		::oWSbillingAddress:SoapRecv(oNode20)
	EndIf
	::cpoolCode          :=  WSAdvValue( oResponse,"_P499_POOLCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprogramNumber     :=  WSAdvValue( oResponse,"_P499_PROGRAMNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprogramTerm       :=  WSAdvValue( oResponse,"_P499_PROGRAMTERM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creturnCode        :=  WSAdvValue( oResponse,"_P499_RETURNCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csubmittedBy       :=  WSAdvValue( oResponse,"_P499_SUBMITTEDBY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csurchargeTotal    :=  WSAdvValue( oResponse,"_P499_SURCHARGETOTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvin               :=  WSAdvValue( oResponse,"_P499_VIN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode28 :=  WSAdvValue( oResponse,"_P499_ORDERLINES","OrderLines",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode28 != NIL
		::oWSorderLines := JD_POINT_PEDC_OrderLines():New()
		::oWSorderLines:SoapRecv(oNode28)
	EndIf
	oNode29 :=  WSAdvValue( oResponse,"_P499_SHIPMENTS","Shipments",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode29 != NIL
		::oWSshipments := JD_POINT_PEDC_Shipments():New()
		::oWSshipments:SoapRecv(oNode29)
	EndIf
	oNode30 :=  WSAdvValue( oResponse,"_P499_INVESTIGATIONS","Investigations",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode30 != NIL
		::oWSinvestigations := JD_POINT_PEDC_Investigations():New()
		::oWSinvestigations:SoapRecv(oNode30)
	EndIf
Return

// WSDL Data Structure Notes

WSSTRUCT JD_POINT_PEDC_Notes
	WSDATA   oWSnote                   AS JD_POINT_PEDC_NoteBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_Notes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_Notes
	::oWSnote              := {} // Array Of  JD_POINT_PEDC_NOTEBEAN():New()
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_Notes
	Local oClone := JD_POINT_PEDC_Notes():NEW()
	oClone:oWSnote := NIL
	If ::oWSnote <> NIL 
		oClone:oWSnote := {}
		aEval( ::oWSnote , { |x| aadd( oClone:oWSnote , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_Notes
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_P499_NOTE","NoteBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSnote , JD_POINT_PEDC_NoteBean():New() )
			::oWSnote[len(::oWSnote)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ShipAddress

WSSTRUCT JD_POINT_PEDC_ShipAddress
	WSDATA   cshipAddressName          AS string OPTIONAL
	WSDATA   cshipAddressLine1         AS string OPTIONAL
	WSDATA   cshipAddressLine2         AS string OPTIONAL
	WSDATA   cshipAddressCity          AS string OPTIONAL
	WSDATA   cshipAddressStateProvince AS string OPTIONAL
	WSDATA   cshipPostalCode           AS string OPTIONAL
	WSDATA   cshipAddressCountry       AS string OPTIONAL
	WSDATA   cshipAddressPhone         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_ShipAddress
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_ShipAddress
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_ShipAddress
	Local oClone := JD_POINT_PEDC_ShipAddress():NEW()
	oClone:cshipAddressName     := ::cshipAddressName
	oClone:cshipAddressLine1    := ::cshipAddressLine1
	oClone:cshipAddressLine2    := ::cshipAddressLine2
	oClone:cshipAddressCity     := ::cshipAddressCity
	oClone:cshipAddressStateProvince := ::cshipAddressStateProvince
	oClone:cshipPostalCode      := ::cshipPostalCode
	oClone:cshipAddressCountry  := ::cshipAddressCountry
	oClone:cshipAddressPhone    := ::cshipAddressPhone
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_ShipAddress
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cshipAddressName   :=  WSAdvValue( oResponse,"_P499_SHIPADDRESSNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressLine1  :=  WSAdvValue( oResponse,"_P499_SHIPADDRESSLINE1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressLine2  :=  WSAdvValue( oResponse,"_P499_SHIPADDRESSLINE2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressCity   :=  WSAdvValue( oResponse,"_P499_SHIPADDRESSCITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressStateProvince :=  WSAdvValue( oResponse,"_P499_SHIPADDRESSSTATEPROVINCE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipPostalCode    :=  WSAdvValue( oResponse,"_P499_SHIPPOSTALCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressCountry :=  WSAdvValue( oResponse,"_P499_SHIPADDRESSCOUNTRY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressPhone  :=  WSAdvValue( oResponse,"_P499_SHIPADDRESSPHONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure BillingAddress

WSSTRUCT JD_POINT_PEDC_BillingAddress
	WSDATA   cbillAddressName          AS string OPTIONAL
	WSDATA   cbillAddressLine1         AS string OPTIONAL
	WSDATA   cbillAddressLine2         AS string OPTIONAL
	WSDATA   cbillAddressCity          AS string OPTIONAL
	WSDATA   cbillAddressStateProvince AS string OPTIONAL
	WSDATA   cbillPostalCode           AS string OPTIONAL
	WSDATA   cbillAddressCountry       AS string OPTIONAL
	WSDATA   cbillAddressPhone         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_BillingAddress
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_BillingAddress
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_BillingAddress
	Local oClone := JD_POINT_PEDC_BillingAddress():NEW()
	oClone:cbillAddressName     := ::cbillAddressName
	oClone:cbillAddressLine1    := ::cbillAddressLine1
	oClone:cbillAddressLine2    := ::cbillAddressLine2
	oClone:cbillAddressCity     := ::cbillAddressCity
	oClone:cbillAddressStateProvince := ::cbillAddressStateProvince
	oClone:cbillPostalCode      := ::cbillPostalCode
	oClone:cbillAddressCountry  := ::cbillAddressCountry
	oClone:cbillAddressPhone    := ::cbillAddressPhone
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_BillingAddress
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cbillAddressName   :=  WSAdvValue( oResponse,"_P499_BILLADDRESSNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressLine1  :=  WSAdvValue( oResponse,"_P499_BILLADDRESSLINE1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressLine2  :=  WSAdvValue( oResponse,"_P499_BILLADDRESSLINE2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressCity   :=  WSAdvValue( oResponse,"_P499_BILLADDRESSCITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressStateProvince :=  WSAdvValue( oResponse,"_P499_BILLADDRESSSTATEPROVINCE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillPostalCode    :=  WSAdvValue( oResponse,"_P499_BILLPOSTALCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressCountry :=  WSAdvValue( oResponse,"_P499_BILLADDRESSCOUNTRY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressPhone  :=  WSAdvValue( oResponse,"_P499_BILLADDRESSPHONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure OrderLines

WSSTRUCT JD_POINT_PEDC_OrderLines
	WSDATA   oWSorderLine              AS JD_POINT_PEDC_OrderLineBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_OrderLines
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_OrderLines
	::oWSorderLine         := {} // Array Of  JD_POINT_PEDC_ORDERLINEBEAN():New()
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_OrderLines
	Local oClone := JD_POINT_PEDC_OrderLines():NEW()
	oClone:oWSorderLine := NIL
	If ::oWSorderLine <> NIL 
		oClone:oWSorderLine := {}
		aEval( ::oWSorderLine , { |x| aadd( oClone:oWSorderLine , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_OrderLines
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_P499_ORDERLINE","OrderLineBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSorderLine , JD_POINT_PEDC_OrderLineBean():New() )
			::oWSorderLine[len(::oWSorderLine)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Shipments

WSSTRUCT JD_POINT_PEDC_Shipments
	WSDATA   oWSshipment               AS JD_POINT_PEDC_ShipmentBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_Shipments
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_Shipments
	::oWSshipment          := {} // Array Of  JD_POINT_PEDC_SHIPMENTBEAN():New()
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_Shipments
	Local oClone := JD_POINT_PEDC_Shipments():NEW()
	oClone:oWSshipment := NIL
	If ::oWSshipment <> NIL 
		oClone:oWSshipment := {}
		aEval( ::oWSshipment , { |x| aadd( oClone:oWSshipment , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_Shipments
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_P499_SHIPMENT","ShipmentBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSshipment , JD_POINT_PEDC_ShipmentBean():New() )
			::oWSshipment[len(::oWSshipment)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Investigations

WSSTRUCT JD_POINT_PEDC_Investigations
	WSDATA   oWSinvestigation          AS JD_POINT_PEDC_InvestigationBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_Investigations
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_Investigations
	::oWSinvestigation     := {} // Array Of  JD_POINT_PEDC_INVESTIGATIONBEAN():New()
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_Investigations
	Local oClone := JD_POINT_PEDC_Investigations():NEW()
	oClone:oWSinvestigation := NIL
	If ::oWSinvestigation <> NIL 
		oClone:oWSinvestigation := {}
		aEval( ::oWSinvestigation , { |x| aadd( oClone:oWSinvestigation , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_Investigations
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_P499_INVESTIGATION","InvestigationBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSinvestigation , JD_POINT_PEDC_InvestigationBean():New() )
			::oWSinvestigation[len(::oWSinvestigation)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure NoteBean

WSSTRUCT JD_POINT_PEDC_NoteBean
	WSDATA   cnumber                   AS string OPTIONAL
	WSDATA   ctype                     AS string OPTIONAL
	WSDATA   cprintCodes               AS string OPTIONAL
	WSDATA   ctext                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_NoteBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_NoteBean
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_NoteBean
	Local oClone := JD_POINT_PEDC_NoteBean():NEW()
	oClone:cnumber              := ::cnumber
	oClone:ctype                := ::ctype
	oClone:cprintCodes          := ::cprintCodes
	oClone:ctext                := ::ctext
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_NoteBean
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cnumber            :=  WSAdvValue( oResponse,"_P499_NUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctype              :=  WSAdvValue( oResponse,"_P499_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprintCodes        :=  WSAdvValue( oResponse,"_P499_PRINTCODES","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctext              :=  WSAdvValue( oResponse,"_P499_TEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure OrderLineBean

WSSTRUCT JD_POINT_PEDC_OrderLineBean
	WSDATA   ctype                     AS string OPTIONAL
	WSDATA   clineNumber               AS string OPTIONAL
	WSDATA   csplitLineNumber          AS string OPTIONAL
	WSDATA   cquantity                 AS string OPTIONAL
	WSDATA   cpartNumber               AS string OPTIONAL
	WSDATA   cbinLocation              AS string OPTIONAL
	WSDATA   cpartDescription          AS string OPTIONAL
	WSDATA   cpartName                 AS string OPTIONAL
	WSDATA   cextendedPrice            AS string OPTIONAL
	WSDATA   cshipDate                 AS string OPTIONAL
	WSDATA   cdepot                    AS string OPTIONAL
	WSDATA   cpacklistNumber           AS string OPTIONAL
	WSDATA   cstatus                   AS string OPTIONAL
	WSDATA   oWSlineNotes              AS JD_POINT_PEDC_Notes OPTIONAL
	WSDATA   oWSinvestigations         AS JD_POINT_PEDC_Investigations OPTIONAL
	WSDATA   cspecialPrice             AS string OPTIONAL
	WSDATA   cspecialPriceNote         AS string OPTIONAL
	WSDATA   cdrivenPrice              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_OrderLineBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_OrderLineBean
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_OrderLineBean
	Local oClone := JD_POINT_PEDC_OrderLineBean():NEW()
	oClone:ctype                := ::ctype
	oClone:clineNumber          := ::clineNumber
	oClone:csplitLineNumber     := ::csplitLineNumber
	oClone:cquantity            := ::cquantity
	oClone:cpartNumber          := ::cpartNumber
	oClone:cbinLocation         := ::cbinLocation
	oClone:cpartDescription     := ::cpartDescription
	oClone:cpartName            := ::cpartName
	oClone:cextendedPrice       := ::cextendedPrice
	oClone:cshipDate            := ::cshipDate
	oClone:cdepot               := ::cdepot
	oClone:cpacklistNumber      := ::cpacklistNumber
	oClone:cstatus              := ::cstatus
	oClone:oWSlineNotes         := IIF(::oWSlineNotes = NIL , NIL , ::oWSlineNotes:Clone() )
	oClone:oWSinvestigations    := IIF(::oWSinvestigations = NIL , NIL , ::oWSinvestigations:Clone() )
	oClone:cspecialPrice        := ::cspecialPrice
	oClone:cspecialPriceNote    := ::cspecialPriceNote
	oClone:cdrivenPrice         := ::cdrivenPrice
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_OrderLineBean
	Local oNode14
	Local oNode15
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ctype              :=  WSAdvValue( oResponse,"_P499_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clineNumber        :=  WSAdvValue( oResponse,"_P499_LINENUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csplitLineNumber   :=  WSAdvValue( oResponse,"_P499_SPLITLINENUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cquantity          :=  WSAdvValue( oResponse,"_P499_QUANTITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartNumber        :=  WSAdvValue( oResponse,"_P499_PARTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbinLocation       :=  WSAdvValue( oResponse,"_P499_BINLOCATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartDescription   :=  WSAdvValue( oResponse,"_P499_PARTDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartName          :=  WSAdvValue( oResponse,"_P499_PARTNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cextendedPrice     :=  WSAdvValue( oResponse,"_P499_EXTENDEDPRICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipDate          :=  WSAdvValue( oResponse,"_P499_SHIPDATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdepot             :=  WSAdvValue( oResponse,"_P499_DEPOT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpacklistNumber    :=  WSAdvValue( oResponse,"_P499_PACKLISTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cstatus            :=  WSAdvValue( oResponse,"_P499_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode14 :=  WSAdvValue( oResponse,"_P499_LINENOTES","Notes",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode14 != NIL
		::oWSlineNotes := JD_POINT_PEDC_Notes():New()
		::oWSlineNotes:SoapRecv(oNode14)
	EndIf
	oNode15 :=  WSAdvValue( oResponse,"_P499_INVESTIGATIONS","Investigations",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode15 != NIL
		::oWSinvestigations := JD_POINT_PEDC_Investigations():New()
		::oWSinvestigations:SoapRecv(oNode15)
	EndIf
	::cspecialPrice      :=  WSAdvValue( oResponse,"_P499_SPECIALPRICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cspecialPriceNote  :=  WSAdvValue( oResponse,"_P499_SPECIALPRICENOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdrivenPrice       :=  WSAdvValue( oResponse,"_P499_DRIVENPRICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ShipmentBean

WSSTRUCT JD_POINT_PEDC_ShipmentBean
	WSDATA   cshipUnit                 AS string OPTIONAL
	WSDATA   clineCount                AS string OPTIONAL
	WSDATA   cviaUnit                  AS string OPTIONAL
	WSDATA   ccarrierService           AS string OPTIONAL
	WSDATA   crequestedShipDate        AS string OPTIONAL
	WSDATA   cestWeight                AS string OPTIONAL
	WSDATA   cbreakPointCarrier        AS string OPTIONAL
	WSDATA   cbreakPointCity           AS string OPTIONAL
	WSDATA   cbreakPointState          AS string OPTIONAL
	WSDATA   ccarrierPaymentRespInd    AS string OPTIONAL
	WSDATA   cfreightChargesNeededInd  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_ShipmentBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_ShipmentBean
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_ShipmentBean
	Local oClone := JD_POINT_PEDC_ShipmentBean():NEW()
	oClone:cshipUnit            := ::cshipUnit
	oClone:clineCount           := ::clineCount
	oClone:cviaUnit             := ::cviaUnit
	oClone:ccarrierService      := ::ccarrierService
	oClone:crequestedShipDate   := ::crequestedShipDate
	oClone:cestWeight           := ::cestWeight
	oClone:cbreakPointCarrier   := ::cbreakPointCarrier
	oClone:cbreakPointCity      := ::cbreakPointCity
	oClone:cbreakPointState     := ::cbreakPointState
	oClone:ccarrierPaymentRespInd := ::ccarrierPaymentRespInd
	oClone:cfreightChargesNeededInd := ::cfreightChargesNeededInd
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_ShipmentBean
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cshipUnit          :=  WSAdvValue( oResponse,"_P499_SHIPUNIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clineCount         :=  WSAdvValue( oResponse,"_P499_LINECOUNT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cviaUnit           :=  WSAdvValue( oResponse,"_P499_VIAUNIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccarrierService    :=  WSAdvValue( oResponse,"_P499_CARRIERSERVICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crequestedShipDate :=  WSAdvValue( oResponse,"_P499_REQUESTEDSHIPDATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cestWeight         :=  WSAdvValue( oResponse,"_P499_ESTWEIGHT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbreakPointCarrier :=  WSAdvValue( oResponse,"_P499_BREAKPOINTCARRIER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbreakPointCity    :=  WSAdvValue( oResponse,"_P499_BREAKPOINTCITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbreakPointState   :=  WSAdvValue( oResponse,"_P499_BREAKPOINTSTATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccarrierPaymentRespInd :=  WSAdvValue( oResponse,"_P499_CARRIERPAYMENTRESPIND","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfreightChargesNeededInd :=  WSAdvValue( oResponse,"_P499_FREIGHTCHARGESNEEDEDIND","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure InvestigationBean

WSSTRUCT JD_POINT_PEDC_InvestigationBean
	WSDATA   ccode                     AS string OPTIONAL
	WSDATA   cseverity                 AS string OPTIONAL
	WSDATA   lwarning                  AS boolean OPTIONAL
	WSDATA   ctext                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_InvestigationBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_InvestigationBean
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_InvestigationBean
	Local oClone := JD_POINT_PEDC_InvestigationBean():NEW()
	oClone:ccode                := ::ccode
	oClone:cseverity            := ::cseverity
	oClone:lwarning             := ::lwarning
	oClone:ctext                := ::ctext
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_InvestigationBean
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccode              :=  WSAdvValue( oResponse,"_P499_CODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cseverity          :=  WSAdvValue( oResponse,"_P499_SEVERITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lwarning           :=  WSAdvValue( oResponse,"_P499_WARNING","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::ctext              :=  WSAdvValue( oResponse,"_P499_TEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 

Return

Static Function OFW30031_SetUserPasswd(cUser, cPasswd)

	if Empty(__cUserID)
		cCodVai   :=  IIF(ExistBlock('OFWJD03U'), ExecBlock("OFWJD03U",.f.,.f.), ;
			FM_SQL("SELECT VAI_CODTEC FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_FABUSR != '' AND D_E_L_E_T_ = ' ' ORDER BY R_E_C_N_O_ "))
		cUser   := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODTEC = '" + cCodVai  + "' AND D_E_L_E_T_ = ' '"))
		cPasswd := AllTrim(FM_SQL("SELECT VAI_FABPWD FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODTEC = '" + cCodVai  + "' AND D_E_L_E_T_ = ' '"))
	Else
		cUser   := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
		cPasswd := AllTrim(FM_SQL("SELECT VAI_FABPWD FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	EndIf

Return

/* -------------------------------------------------------------------------------
WSDL Service WSJohnDeereJDPoint_1_4_Pedido_Compra
------------------------------------------------------------------------------- */

WSCLIENT WSJohnDeereJDPoint_1_4_Pedido_Compra

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD retrieveOrderStatus

	WSMETHOD ExibeErro
	WSMETHOD SetDebug
	WSMETHOD SetToken

	WSDATA oOkta as OBJECT

	WSDATA   _USER AS String
	WSDATA   _PASSWD AS String

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   _SOAP_ACTION              AS String
	WSDATA ERRO 
	
	WSDATA   cuserId                   AS string
	WSDATA   caccountNumber            AS string
	WSDATA   corderNumber              AS string
	WSDATA   oOrderStatusReturn AS OrderStatusWS_1_4Service_OrderStatusWSBean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSJohnDeereJDPoint_1_4_Pedido_Compra
	::Init()
	::ERRO := .f.

	If Empty(::_USER) .or. Empty(::_PASSWD)
		MsgStop(STR0004,STR0002) // O seu cadastro de Equipe Técnica (OFIOA180) está com os campos referentes ao usuário X e senha do portal da John Deere em branco (campo VAI_FABUSR e campo VAI_FABPWD). Por favor verifique junto ao administrador do sistema! // Atenção!
		::ERRO := .t.
	EndIf

Return Self

WSMETHOD INIT WSCLIENT WSJohnDeereJDPoint_1_4_Pedido_Compra
	::oOrderStatusReturn := OrderStatusWS_1_4Service_ORDERSTATUSWSBEAN():New()
	OFW30031_SetUserPasswd(@self:_USER, @self:_PASSWD)

	If self:oOkta == NIL
		self:oOkta := OFJDOkta():New()
		self:oOkta:SetOrderStatusJDPoint()
		self:oOkta:SetUserPasswd(::_USER, ::_PASSWD)
	EndIf

	::_URL := self:oOkta:oConfig:getUrlWSOrderStatusJDPoint()
	::_SOAP_ACTION := "http://v2_4.ostat.services.view.jdpoint.parts.deere.com"

Return

WSMETHOD RESET WSCLIENT WSJohnDeereJDPoint_1_4_Pedido_Compra
	::cuserId            := NIL 
	::caccountNumber     := NIL 
	::corderNumber       := NIL 
	::oOrderStatusReturn := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSJohnDeereJDPoint_1_4_Pedido_Compra
Local oClone := WSJohnDeereJDPoint_1_4_Pedido_Compra():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:cuserId       := ::cuserId
	oClone:caccountNumber := ::caccountNumber
	oClone:corderNumber  := ::corderNumber
	oClone:oOrderStatusReturn :=  IIF(::oOrderStatusReturn = NIL , NIL ,::oOrderStatusReturn:Clone() )
Return oClone

WSMETHOD SetDebug WSSEND lSetDebug WSCLIENT WSJohnDeereJDPoint_1_4_Pedido_Compra

	Default lSetDebug := .t.

	If lSetDebug
		WSDLDbgLevel(2)
		WSDLSaveXML(.t.)
		WSDLSetProfile(.t.)
	Else
		WSDLSaveXML(.f.)
		WSDLSetProfile(.t.)
	EndIf
Return


WSMETHOD ExibeErro WSCLIENT WSJohnDeereJDPoint_1_4_Pedido_Compra

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	//Local cXMLError	:= GetWSCError(4)
	If !Empty(cSoapFCode)
		// Caso a ocorrÃªncia de erro esteja com o fault_code preenchido ,
		// a mesma teve relaÃ§Ã£o com a chamada do serviÃ§o .
		MsgStop(cSoapFDescr,cSoapFCode)
		//Aviso("Erro",cXMLError,{"Ok"},2)
	Else
		// Caso a ocorrÃªncia nÃ£o tenha o soap_code preenchido
		// Ela estÃ¡ relacionada a uma outra falha ,
		// provavelmente local ou interna.
		MsgStop(cSvcError,STR0002)
	Endif

Return

WSMETHOD retrieveOrderStatus WSRECEIVE oOrderStatusReturn WSCLIENT WSJohnDeereJDPoint_1_4_Pedido_Compra
	Local cSoap := "" , oXmlRet
	Local cToken := self:oOkta:getToken()

	If Empty(cToken)
		MsgStop(STR0012,STR0013) // "Falha na obtenção do Token de Acesso." // "Erro"
		Return .f.
	EndIf

	::_HEADOUT := {}
	aadd( ::_HEADOUT , "Authorization: Bearer " + cToken )
	aadd( ::_HEADOUT , "Timeout: 300000 " )

	BEGIN WSMETHOD

	cSoap += '<retrieveOrderStatus xmlns="http://v2_4.ostat.services.view.jdpoint.parts.deere.com">'
	cSoap += WSSoapValue("userId", ::cuserId, ::cuserId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("accountNumber", ::caccountNumber, ::caccountNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("orderNumber", ::corderNumber, ::corderNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += "</retrieveOrderStatus>"

	oXmlRet := SvcSoapCall(Self,cSoap,; 
		"retrieveOrderStatus",; 
		"DOCUMENT",;
		::_SOAP_ACTION,,,; 
		::_URL)

	::Init()
	::oOrderStatusReturn:SoapRecv( WSAdvValue( oXmlRet,"_P892_RETRIEVEORDERSTATUSRESPONSE:_RETRIEVEORDERSTATUSRETURN","OrderStatusWSBean",NIL,NIL,NIL,NIL,NIL,NIL) )

	END WSMETHOD

	oXmlRet := NIL
Return .T.


// WSDL Data Structure OrderStatusWSBean

WSSTRUCT OrderStatusWS_1_4Service_OrderStatusWSBean
	WSDATA   cversion                  AS string OPTIONAL
	WSDATA   caccountNumber            AS string OPTIONAL
	WSDATA   ccurrency                 AS string OPTIONAL
	WSDATA   cdateOrdered              AS string OPTIONAL
	WSDATA   cdealerRef                AS string OPTIONAL
	WSDATA   cdestination              AS string OPTIONAL
	WSDATA   cdiscountTotal            AS string OPTIONAL
	WSDATA   cestimatedOrderValue      AS string OPTIONAL
	WSDATA   cexceptionReport          AS string OPTIONAL
	WSDATA   cextendedPriceTotal       AS string OPTIONAL
	WSDATA   clastChanged              AS string OPTIONAL
	WSDATA   clineOfCredit             AS string OPTIONAL
	WSDATA   cmerchandiseTotal         AS string OPTIONAL
	WSDATA   corderNumber              AS string OPTIONAL
	WSDATA   corderStatus              AS string OPTIONAL
	WSDATA   corderType                AS string OPTIONAL
	WSDATA   cpartialShip              AS string OPTIONAL
	WSDATA   oWSorderNotes             AS OrderStatusWS_1_4Service_Notes OPTIONAL
	WSDATA   oWSshipAddress            AS OrderStatusWS_1_4Service_ShipAddress OPTIONAL
	WSDATA   oWSbillingAddress         AS OrderStatusWS_1_4Service_BillingAddress OPTIONAL
	WSDATA   cpoolCode                 AS string OPTIONAL
	WSDATA   cprogramNumber            AS string OPTIONAL
	WSDATA   cprogramTerm              AS string OPTIONAL
	WSDATA   creturnCode               AS string OPTIONAL
	WSDATA   csubmittedBy              AS string OPTIONAL
	WSDATA   csurchargeTotal           AS string OPTIONAL
	WSDATA   cvin                      AS string OPTIONAL
	WSDATA   oWSorderLines             AS OrderStatusWS_1_4Service_OrderLines OPTIONAL
	WSDATA   oWSshipments              AS OrderStatusWS_1_4Service_Shipments OPTIONAL
	WSDATA   oWSinvestigations         AS OrderStatusWS_1_4Service_Investigations OPTIONAL
	WSDATA   oWSjdmDBSOrderTrackingInfo AS OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoList OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_OrderStatusWSBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_OrderStatusWSBean
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_OrderStatusWSBean
	Local oClone := OrderStatusWS_1_4Service_OrderStatusWSBean():NEW()
	oClone:cversion             := ::cversion
	oClone:caccountNumber       := ::caccountNumber
	oClone:ccurrency            := ::ccurrency
	oClone:cdateOrdered         := ::cdateOrdered
	oClone:cdealerRef           := ::cdealerRef
	oClone:cdestination         := ::cdestination
	oClone:cdiscountTotal       := ::cdiscountTotal
	oClone:cestimatedOrderValue := ::cestimatedOrderValue
	oClone:cexceptionReport     := ::cexceptionReport
	oClone:cextendedPriceTotal  := ::cextendedPriceTotal
	oClone:clastChanged         := ::clastChanged
	oClone:clineOfCredit        := ::clineOfCredit
	oClone:cmerchandiseTotal    := ::cmerchandiseTotal
	oClone:corderNumber         := ::corderNumber
	oClone:corderStatus         := ::corderStatus
	oClone:corderType           := ::corderType
	oClone:cpartialShip         := ::cpartialShip
	oClone:oWSorderNotes        := IIF(::oWSorderNotes = NIL , NIL , ::oWSorderNotes:Clone() )
	oClone:oWSshipAddress       := IIF(::oWSshipAddress = NIL , NIL , ::oWSshipAddress:Clone() )
	oClone:oWSbillingAddress    := IIF(::oWSbillingAddress = NIL , NIL , ::oWSbillingAddress:Clone() )
	oClone:cpoolCode            := ::cpoolCode
	oClone:cprogramNumber       := ::cprogramNumber
	oClone:cprogramTerm         := ::cprogramTerm
	oClone:creturnCode          := ::creturnCode
	oClone:csubmittedBy         := ::csubmittedBy
	oClone:csurchargeTotal      := ::csurchargeTotal
	oClone:cvin                 := ::cvin
	oClone:oWSorderLines        := IIF(::oWSorderLines = NIL , NIL , ::oWSorderLines:Clone() )
	oClone:oWSshipments         := IIF(::oWSshipments = NIL , NIL , ::oWSshipments:Clone() )
	oClone:oWSinvestigations    := IIF(::oWSinvestigations = NIL , NIL , ::oWSinvestigations:Clone() )
	oClone:oWSjdmDBSOrderTrackingInfo := IIF(::oWSjdmDBSOrderTrackingInfo = NIL , NIL , ::oWSjdmDBSOrderTrackingInfo:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_OrderStatusWSBean
	Local oNode18
	Local oNode19
	Local oNode20
	Local oNode28
	Local oNode29
	Local oNode30
	Local oNode31
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cversion           :=  WSAdvValue( oResponse,"_VERSION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::caccountNumber     :=  WSAdvValue( oResponse,"_ACCOUNTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccurrency          :=  WSAdvValue( oResponse,"_CURRENCY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdateOrdered       :=  WSAdvValue( oResponse,"_DATEORDERED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdealerRef         :=  WSAdvValue( oResponse,"_DEALERREF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdestination       :=  WSAdvValue( oResponse,"_DESTINATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdiscountTotal     :=  WSAdvValue( oResponse,"_DISCOUNTTOTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cestimatedOrderValue :=  WSAdvValue( oResponse,"_ESTIMATEDORDERVALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cexceptionReport   :=  WSAdvValue( oResponse,"_EXCEPTIONREPORT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cextendedPriceTotal :=  WSAdvValue( oResponse,"_EXTENDEDPRICETOTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clastChanged       :=  WSAdvValue( oResponse,"_LASTCHANGED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clineOfCredit      :=  WSAdvValue( oResponse,"_LINEOFCREDIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmerchandiseTotal  :=  WSAdvValue( oResponse,"_MERCHANDISETOTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::corderNumber       :=  WSAdvValue( oResponse,"_ORDERNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::corderStatus       :=  WSAdvValue( oResponse,"_ORDERSTATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::corderType         :=  WSAdvValue( oResponse,"_ORDERTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartialShip       :=  WSAdvValue( oResponse,"_PARTIALSHIP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode18 :=  WSAdvValue( oResponse,"_ORDERNOTES","Notes",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode18 != NIL
		::oWSorderNotes := OrderStatusWS_1_4Service_Notes():New()
		::oWSorderNotes:SoapRecv(oNode18)
	EndIf
	oNode19 :=  WSAdvValue( oResponse,"_SHIPADDRESS","ShipAddress",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode19 != NIL
		::oWSshipAddress := OrderStatusWS_1_4Service_ShipAddress():New()
		::oWSshipAddress:SoapRecv(oNode19)
	EndIf
	oNode20 :=  WSAdvValue( oResponse,"_BILLINGADDRESS","BillingAddress",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode20 != NIL
		::oWSbillingAddress := OrderStatusWS_1_4Service_BillingAddress():New()
		::oWSbillingAddress:SoapRecv(oNode20)
	EndIf
	::cpoolCode          :=  WSAdvValue( oResponse,"_POOLCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprogramNumber     :=  WSAdvValue( oResponse,"_PROGRAMNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprogramTerm       :=  WSAdvValue( oResponse,"_PROGRAMTERM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creturnCode        :=  WSAdvValue( oResponse,"_RETURNCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csubmittedBy       :=  WSAdvValue( oResponse,"_SUBMITTEDBY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csurchargeTotal    :=  WSAdvValue( oResponse,"_SURCHARGETOTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvin               :=  WSAdvValue( oResponse,"_VIN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode28 :=  WSAdvValue( oResponse,"_ORDERLINES","OrderLines",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode28 != NIL
		::oWSorderLines := OrderStatusWS_1_4Service_OrderLines():New()
		::oWSorderLines:SoapRecv(oNode28)
	EndIf
	oNode29 :=  WSAdvValue( oResponse,"_SHIPMENTS","Shipments",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode29 != NIL
		::oWSshipments := OrderStatusWS_1_4Service_Shipments():New()
		::oWSshipments:SoapRecv(oNode29)
	EndIf
	oNode30 :=  WSAdvValue( oResponse,"_INVESTIGATIONS","Investigations",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode30 != NIL
		::oWSinvestigations := OrderStatusWS_1_4Service_Investigations():New()
		::oWSinvestigations:SoapRecv(oNode30)
	EndIf
	oNode31 :=  WSAdvValue( oResponse,"_JDMDBSORDERTRACKINGINFO","JDMDBSOrderTrackingInfoList",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode31 != NIL
		::oWSjdmDBSOrderTrackingInfo := OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoList():New()
		::oWSjdmDBSOrderTrackingInfo:SoapRecv(oNode31)
	EndIf
Return

// WSDL Data Structure Notes

WSSTRUCT OrderStatusWS_1_4Service_Notes
	WSDATA   oWSnote                   AS OrderStatusWS_1_4Service_ArrayOfNoteBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_Notes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_Notes
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_Notes
	Local oClone := OrderStatusWS_1_4Service_Notes():NEW()
	oClone:oWSnote              := IIF(::oWSnote = NIL , NIL , ::oWSnote:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_Notes
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NOTE","ArrayOfNoteBean",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSnote := OrderStatusWS_1_4Service_ArrayOfNoteBean():New()
		::oWSnote:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ShipAddress

WSSTRUCT OrderStatusWS_1_4Service_ShipAddress
	WSDATA   cshipAddressName          AS string OPTIONAL
	WSDATA   cshipAddressLine1         AS string OPTIONAL
	WSDATA   cshipAddressLine2         AS string OPTIONAL
	WSDATA   cshipAddressCity          AS string OPTIONAL
	WSDATA   cshipAddressStateProvince AS string OPTIONAL
	WSDATA   cshipPostalCode           AS string OPTIONAL
	WSDATA   cshipAddressCountry       AS string OPTIONAL
	WSDATA   cshipAddressPhone         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_ShipAddress
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_ShipAddress
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_ShipAddress
	Local oClone := OrderStatusWS_1_4Service_ShipAddress():NEW()
	oClone:cshipAddressName     := ::cshipAddressName
	oClone:cshipAddressLine1    := ::cshipAddressLine1
	oClone:cshipAddressLine2    := ::cshipAddressLine2
	oClone:cshipAddressCity     := ::cshipAddressCity
	oClone:cshipAddressStateProvince := ::cshipAddressStateProvince
	oClone:cshipPostalCode      := ::cshipPostalCode
	oClone:cshipAddressCountry  := ::cshipAddressCountry
	oClone:cshipAddressPhone    := ::cshipAddressPhone
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_ShipAddress
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cshipAddressName   :=  WSAdvValue( oResponse,"_SHIPADDRESSNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressLine1  :=  WSAdvValue( oResponse,"_SHIPADDRESSLINE1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressLine2  :=  WSAdvValue( oResponse,"_SHIPADDRESSLINE2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressCity   :=  WSAdvValue( oResponse,"_SHIPADDRESSCITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressStateProvince :=  WSAdvValue( oResponse,"_SHIPADDRESSSTATEPROVINCE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipPostalCode    :=  WSAdvValue( oResponse,"_SHIPPOSTALCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressCountry :=  WSAdvValue( oResponse,"_SHIPADDRESSCOUNTRY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipAddressPhone  :=  WSAdvValue( oResponse,"_SHIPADDRESSPHONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure BillingAddress

WSSTRUCT OrderStatusWS_1_4Service_BillingAddress
	WSDATA   cbillAddressName          AS string OPTIONAL
	WSDATA   cbillAddressLine1         AS string OPTIONAL
	WSDATA   cbillAddressLine2         AS string OPTIONAL
	WSDATA   cbillAddressCity          AS string OPTIONAL
	WSDATA   cbillAddressStateProvince AS string OPTIONAL
	WSDATA   cbillPostalCode           AS string OPTIONAL
	WSDATA   cbillAddressCountry       AS string OPTIONAL
	WSDATA   cbillAddressPhone         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_BillingAddress
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_BillingAddress
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_BillingAddress
	Local oClone := OrderStatusWS_1_4Service_BillingAddress():NEW()
	oClone:cbillAddressName     := ::cbillAddressName
	oClone:cbillAddressLine1    := ::cbillAddressLine1
	oClone:cbillAddressLine2    := ::cbillAddressLine2
	oClone:cbillAddressCity     := ::cbillAddressCity
	oClone:cbillAddressStateProvince := ::cbillAddressStateProvince
	oClone:cbillPostalCode      := ::cbillPostalCode
	oClone:cbillAddressCountry  := ::cbillAddressCountry
	oClone:cbillAddressPhone    := ::cbillAddressPhone
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_BillingAddress
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cbillAddressName   :=  WSAdvValue( oResponse,"_BILLADDRESSNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressLine1  :=  WSAdvValue( oResponse,"_BILLADDRESSLINE1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressLine2  :=  WSAdvValue( oResponse,"_BILLADDRESSLINE2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressCity   :=  WSAdvValue( oResponse,"_BILLADDRESSCITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressStateProvince :=  WSAdvValue( oResponse,"_BILLADDRESSSTATEPROVINCE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillPostalCode    :=  WSAdvValue( oResponse,"_BILLPOSTALCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressCountry :=  WSAdvValue( oResponse,"_BILLADDRESSCOUNTRY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbillAddressPhone  :=  WSAdvValue( oResponse,"_BILLADDRESSPHONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure OrderLines

WSSTRUCT OrderStatusWS_1_4Service_OrderLines
	WSDATA   oWSorderLine              AS OrderStatusWS_1_4Service_ArrayOfOrderLineBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_OrderLines
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_OrderLines
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_OrderLines
	Local oClone := OrderStatusWS_1_4Service_OrderLines():NEW()
	oClone:oWSorderLine         := IIF(::oWSorderLine = NIL , NIL , ::oWSorderLine:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_OrderLines
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ORDERLINE","ArrayOfOrderLineBean",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSorderLine := OrderStatusWS_1_4Service_ArrayOfOrderLineBean():New()
		::oWSorderLine:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure Shipments

WSSTRUCT OrderStatusWS_1_4Service_Shipments
	WSDATA   oWSshipment               AS OrderStatusWS_1_4Service_ArrayOfShipmentBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_Shipments
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_Shipments
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_Shipments
	Local oClone := OrderStatusWS_1_4Service_Shipments():NEW()
	oClone:oWSshipment          := IIF(::oWSshipment = NIL , NIL , ::oWSshipment:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_Shipments
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_SHIPMENT","ArrayOfShipmentBean",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSshipment := OrderStatusWS_1_4Service_ArrayOfShipmentBean():New()
		::oWSshipment:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure Investigations

WSSTRUCT OrderStatusWS_1_4Service_Investigations
	WSDATA   oWSinvestigation          AS OrderStatusWS_1_4Service_ArrayOfInvestigationBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_Investigations
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_Investigations
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_Investigations
	Local oClone := OrderStatusWS_1_4Service_Investigations():NEW()
	oClone:oWSinvestigation     := IIF(::oWSinvestigation = NIL , NIL , ::oWSinvestigation:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_Investigations
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_INVESTIGATION","ArrayOfInvestigationBean",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSinvestigation := OrderStatusWS_1_4Service_ArrayOfInvestigationBean():New()
		::oWSinvestigation:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure JDMDBSOrderTrackingInfoList

WSSTRUCT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoList
	WSDATA   oWSjdmDBSOrderTrackinInfobean AS OrderStatusWS_1_4Service_ArrayOfJDMDBSOrderTrackingInfoBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoList
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoList
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoList
	Local oClone := OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoList():NEW()
	oClone:oWSjdmDBSOrderTrackinInfobean := IIF(::oWSjdmDBSOrderTrackinInfobean = NIL , NIL , ::oWSjdmDBSOrderTrackinInfobean:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoList
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_JDMDBSORDERTRACKININFOBEAN","ArrayOfJDMDBSOrderTrackingInfoBean",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSjdmDBSOrderTrackinInfobean := OrderStatusWS_1_4Service_ArrayOfJDMDBSOrderTrackingInfoBean():New()
		::oWSjdmDBSOrderTrackinInfobean:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ArrayOfNoteBean

WSSTRUCT OrderStatusWS_1_4Service_ArrayOfNoteBean
	WSDATA   oWSNoteBean               AS OrderStatusWS_1_4Service_NoteBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_ArrayOfNoteBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_ArrayOfNoteBean
	::oWSNoteBean          := {} // Array Of  OrderStatusWS_1_4Service_NOTEBEAN():New()
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_ArrayOfNoteBean
	Local oClone := OrderStatusWS_1_4Service_ArrayOfNoteBean():NEW()
	oClone:oWSNoteBean := NIL
	If ::oWSNoteBean <> NIL 
		oClone:oWSNoteBean := {}
		aEval( ::oWSNoteBean , { |x| aadd( oClone:oWSNoteBean , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_ArrayOfNoteBean
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_NOTEBEAN","NoteBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSNoteBean , OrderStatusWS_1_4Service_NoteBean():New() )
			::oWSNoteBean[len(::oWSNoteBean)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfOrderLineBean

WSSTRUCT OrderStatusWS_1_4Service_ArrayOfOrderLineBean
	WSDATA   oWSOrderLineBean          AS OrderStatusWS_1_4Service_OrderLineBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_ArrayOfOrderLineBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_ArrayOfOrderLineBean
	::oWSOrderLineBean     := {} // Array Of  OrderStatusWS_1_4Service_ORDERLINEBEAN():New()
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_ArrayOfOrderLineBean
	Local oClone := OrderStatusWS_1_4Service_ArrayOfOrderLineBean():NEW()
	oClone:oWSOrderLineBean := NIL
	If ::oWSOrderLineBean <> NIL 
		oClone:oWSOrderLineBean := {}
		aEval( ::oWSOrderLineBean , { |x| aadd( oClone:oWSOrderLineBean , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_ArrayOfOrderLineBean
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ORDERLINEBEAN","OrderLineBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSOrderLineBean , OrderStatusWS_1_4Service_OrderLineBean():New() )
			::oWSOrderLineBean[len(::oWSOrderLineBean)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfShipmentBean

WSSTRUCT OrderStatusWS_1_4Service_ArrayOfShipmentBean
	WSDATA   oWSShipmentBean           AS OrderStatusWS_1_4Service_ShipmentBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_ArrayOfShipmentBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_ArrayOfShipmentBean
	::oWSShipmentBean      := {} // Array Of  OrderStatusWS_1_4Service_SHIPMENTBEAN():New()
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_ArrayOfShipmentBean
	Local oClone := OrderStatusWS_1_4Service_ArrayOfShipmentBean():NEW()
	oClone:oWSShipmentBean := NIL
	If ::oWSShipmentBean <> NIL 
		oClone:oWSShipmentBean := {}
		aEval( ::oWSShipmentBean , { |x| aadd( oClone:oWSShipmentBean , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_ArrayOfShipmentBean
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SHIPMENTBEAN","ShipmentBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSShipmentBean , OrderStatusWS_1_4Service_ShipmentBean():New() )
			::oWSShipmentBean[len(::oWSShipmentBean)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfInvestigationBean

WSSTRUCT OrderStatusWS_1_4Service_ArrayOfInvestigationBean
	WSDATA   oWSInvestigationBean      AS OrderStatusWS_1_4Service_InvestigationBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_ArrayOfInvestigationBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_ArrayOfInvestigationBean
	::oWSInvestigationBean := {} // Array Of  OrderStatusWS_1_4Service_INVESTIGATIONBEAN():New()
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_ArrayOfInvestigationBean
	Local oClone := OrderStatusWS_1_4Service_ArrayOfInvestigationBean():NEW()
	oClone:oWSInvestigationBean := NIL
	If ::oWSInvestigationBean <> NIL 
		oClone:oWSInvestigationBean := {}
		aEval( ::oWSInvestigationBean , { |x| aadd( oClone:oWSInvestigationBean , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_ArrayOfInvestigationBean
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INVESTIGATIONBEAN","InvestigationBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSInvestigationBean , OrderStatusWS_1_4Service_InvestigationBean():New() )
			::oWSInvestigationBean[len(::oWSInvestigationBean)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfJDMDBSOrderTrackingInfoBean

WSSTRUCT OrderStatusWS_1_4Service_ArrayOfJDMDBSOrderTrackingInfoBean
	WSDATA   oWSJDMDBSOrderTrackingInfoBean AS OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoBean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_ArrayOfJDMDBSOrderTrackingInfoBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_ArrayOfJDMDBSOrderTrackingInfoBean
	::oWSJDMDBSOrderTrackingInfoBean := {} // Array Of  OrderStatusWS_1_4Service_JDMDBSORDERTRACKINGINFOBEAN():New()
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_ArrayOfJDMDBSOrderTrackingInfoBean
	Local oClone := OrderStatusWS_1_4Service_ArrayOfJDMDBSOrderTrackingInfoBean():NEW()
	oClone:oWSJDMDBSOrderTrackingInfoBean := NIL
	If ::oWSJDMDBSOrderTrackingInfoBean <> NIL 
		oClone:oWSJDMDBSOrderTrackingInfoBean := {}
		aEval( ::oWSJDMDBSOrderTrackingInfoBean , { |x| aadd( oClone:oWSJDMDBSOrderTrackingInfoBean , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_ArrayOfJDMDBSOrderTrackingInfoBean
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_JDMDBSORDERTRACKINGINFOBEAN","JDMDBSOrderTrackingInfoBean",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSJDMDBSOrderTrackingInfoBean , OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoBean():New() )
			::oWSJDMDBSOrderTrackingInfoBean[len(::oWSJDMDBSOrderTrackingInfoBean)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure NoteBean

WSSTRUCT OrderStatusWS_1_4Service_NoteBean
	WSDATA   cnumber                   AS string OPTIONAL
	WSDATA   ctype                     AS string OPTIONAL
	WSDATA   cprintCodes               AS string OPTIONAL
	WSDATA   ctext                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_NoteBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_NoteBean
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_NoteBean
	Local oClone := OrderStatusWS_1_4Service_NoteBean():NEW()
	oClone:cnumber              := ::cnumber
	oClone:ctype                := ::ctype
	oClone:cprintCodes          := ::cprintCodes
	oClone:ctext                := ::ctext
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_NoteBean
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cnumber            :=  WSAdvValue( oResponse,"_NUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctype              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cprintCodes        :=  WSAdvValue( oResponse,"_PRINTCODES","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctext              :=  WSAdvValue( oResponse,"_TEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure OrderLineBean

WSSTRUCT OrderStatusWS_1_4Service_OrderLineBean
	WSDATA   ctype                     AS string OPTIONAL
	WSDATA   clineNumber               AS string OPTIONAL
	WSDATA   csplitLineNumber          AS string OPTIONAL
	WSDATA   cquantity                 AS string OPTIONAL
	WSDATA   cpartNumber               AS string OPTIONAL
	WSDATA   cbinLocation              AS string OPTIONAL
	WSDATA   cpartDescription          AS string OPTIONAL
	WSDATA   cpartName                 AS string OPTIONAL
	WSDATA   cextendedPrice            AS string OPTIONAL
	WSDATA   cshipDate                 AS string OPTIONAL
	WSDATA   cdepot                    AS string OPTIONAL
	WSDATA   cpacklistNumber           AS string OPTIONAL
	WSDATA   cstatus                   AS string OPTIONAL
	WSDATA   oWSlineNotes              AS OrderStatusWS_1_4Service_Notes OPTIONAL
	WSDATA   oWSinvestigations         AS OrderStatusWS_1_4Service_Investigations OPTIONAL
	WSDATA   cspecialPrice             AS string OPTIONAL
	WSDATA   cspecialPriceNote         AS string OPTIONAL
	WSDATA   cdrivenPrice              AS string OPTIONAL
	WSDATA   cestimatedDeliveryDate    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_OrderLineBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_OrderLineBean
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_OrderLineBean
	Local oClone := OrderStatusWS_1_4Service_OrderLineBean():NEW()
	oClone:ctype                := ::ctype
	oClone:clineNumber          := ::clineNumber
	oClone:csplitLineNumber     := ::csplitLineNumber
	oClone:cquantity            := ::cquantity
	oClone:cpartNumber          := ::cpartNumber
	oClone:cbinLocation         := ::cbinLocation
	oClone:cpartDescription     := ::cpartDescription
	oClone:cpartName            := ::cpartName
	oClone:cextendedPrice       := ::cextendedPrice
	oClone:cshipDate            := ::cshipDate
	oClone:cdepot               := ::cdepot
	oClone:cpacklistNumber      := ::cpacklistNumber
	oClone:cstatus              := ::cstatus
	oClone:oWSlineNotes         := IIF(::oWSlineNotes = NIL , NIL , ::oWSlineNotes:Clone() )
	oClone:oWSinvestigations    := IIF(::oWSinvestigations = NIL , NIL , ::oWSinvestigations:Clone() )
	oClone:cspecialPrice        := ::cspecialPrice
	oClone:cspecialPriceNote    := ::cspecialPriceNote
	oClone:cdrivenPrice         := ::cdrivenPrice
	oClone:cestimatedDeliveryDate := ::cestimatedDeliveryDate
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_OrderLineBean
	Local oNode14
	Local oNode15
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ctype              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clineNumber        :=  WSAdvValue( oResponse,"_LINENUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csplitLineNumber   :=  WSAdvValue( oResponse,"_SPLITLINENUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cquantity          :=  WSAdvValue( oResponse,"_QUANTITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartNumber        :=  WSAdvValue( oResponse,"_PARTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbinLocation       :=  WSAdvValue( oResponse,"_BINLOCATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartDescription   :=  WSAdvValue( oResponse,"_PARTDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartName          :=  WSAdvValue( oResponse,"_PARTNAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cextendedPrice     :=  WSAdvValue( oResponse,"_EXTENDEDPRICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipDate          :=  WSAdvValue( oResponse,"_SHIPDATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdepot             :=  WSAdvValue( oResponse,"_DEPOT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpacklistNumber    :=  WSAdvValue( oResponse,"_PACKLISTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cstatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode14 :=  WSAdvValue( oResponse,"_LINENOTES","Notes",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode14 != NIL
		::oWSlineNotes := OrderStatusWS_1_4Service_Notes():New()
		::oWSlineNotes:SoapRecv(oNode14)
	EndIf
	oNode15 :=  WSAdvValue( oResponse,"_INVESTIGATIONS","Investigations",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode15 != NIL
		::oWSinvestigations := OrderStatusWS_1_4Service_Investigations():New()
		::oWSinvestigations:SoapRecv(oNode15)
	EndIf
	::cspecialPrice      :=  WSAdvValue( oResponse,"_SPECIALPRICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cspecialPriceNote  :=  WSAdvValue( oResponse,"_SPECIALPRICENOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdrivenPrice       :=  WSAdvValue( oResponse,"_DRIVENPRICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cestimatedDeliveryDate :=  WSAdvValue( oResponse,"_ESTIMATEDDELIVERYDATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ShipmentBean

WSSTRUCT OrderStatusWS_1_4Service_ShipmentBean
	WSDATA   cshipUnit                 AS string OPTIONAL
	WSDATA   clineCount                AS string OPTIONAL
	WSDATA   cviaUnit                  AS string OPTIONAL
	WSDATA   ccarrierService           AS string OPTIONAL
	WSDATA   crequestedShipDate        AS string OPTIONAL
	WSDATA   cestWeight                AS string OPTIONAL
	WSDATA   cbreakPointCarrier        AS string OPTIONAL
	WSDATA   cbreakPointCity           AS string OPTIONAL
	WSDATA   cbreakPointState          AS string OPTIONAL
	WSDATA   ccarrierPaymentRespInd    AS string OPTIONAL
	WSDATA   cfreightChargesNeededInd  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_ShipmentBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_ShipmentBean
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_ShipmentBean
	Local oClone := OrderStatusWS_1_4Service_ShipmentBean():NEW()
	oClone:cshipUnit            := ::cshipUnit
	oClone:clineCount           := ::clineCount
	oClone:cviaUnit             := ::cviaUnit
	oClone:ccarrierService      := ::ccarrierService
	oClone:crequestedShipDate   := ::crequestedShipDate
	oClone:cestWeight           := ::cestWeight
	oClone:cbreakPointCarrier   := ::cbreakPointCarrier
	oClone:cbreakPointCity      := ::cbreakPointCity
	oClone:cbreakPointState     := ::cbreakPointState
	oClone:ccarrierPaymentRespInd := ::ccarrierPaymentRespInd
	oClone:cfreightChargesNeededInd := ::cfreightChargesNeededInd
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_ShipmentBean
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cshipUnit          :=  WSAdvValue( oResponse,"_SHIPUNIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::clineCount         :=  WSAdvValue( oResponse,"_LINECOUNT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cviaUnit           :=  WSAdvValue( oResponse,"_VIAUNIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccarrierService    :=  WSAdvValue( oResponse,"_CARRIERSERVICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::crequestedShipDate :=  WSAdvValue( oResponse,"_REQUESTEDSHIPDATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cestWeight         :=  WSAdvValue( oResponse,"_ESTWEIGHT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbreakPointCarrier :=  WSAdvValue( oResponse,"_BREAKPOINTCARRIER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbreakPointCity    :=  WSAdvValue( oResponse,"_BREAKPOINTCITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cbreakPointState   :=  WSAdvValue( oResponse,"_BREAKPOINTSTATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccarrierPaymentRespInd :=  WSAdvValue( oResponse,"_CARRIERPAYMENTRESPIND","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cfreightChargesNeededInd :=  WSAdvValue( oResponse,"_FREIGHTCHARGESNEEDEDIND","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure InvestigationBean

WSSTRUCT OrderStatusWS_1_4Service_InvestigationBean
	WSDATA   ccode                     AS string OPTIONAL
	WSDATA   cseverity                 AS string OPTIONAL
	WSDATA   lwarning                  AS boolean OPTIONAL
	WSDATA   ctext                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_InvestigationBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_InvestigationBean
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_InvestigationBean
	Local oClone := OrderStatusWS_1_4Service_InvestigationBean():NEW()
	oClone:ccode                := ::ccode
	oClone:cseverity            := ::cseverity
	oClone:lwarning             := ::lwarning
	oClone:ctext                := ::ctext
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_InvestigationBean
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccode              :=  WSAdvValue( oResponse,"_CODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cseverity          :=  WSAdvValue( oResponse,"_SEVERITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lwarning           :=  WSAdvValue( oResponse,"_WARNING","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::ctext              :=  WSAdvValue( oResponse,"_TEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure JDMDBSOrderTrackingInfoBean

WSSTRUCT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoBean
	WSDATA   ccarrService              AS string OPTIONAL
	WSDATA   cparcel                   AS string OPTIONAL
	WSDATA   cshipDate                 AS string OPTIONAL
	WSDATA   ctraceNumber              AS string OPTIONAL
	WSDATA   corderNumber              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoBean
Return

WSMETHOD CLONE WSCLIENT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoBean
	Local oClone := OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoBean():NEW()
	oClone:ccarrService         := ::ccarrService
	oClone:cparcel              := ::cparcel
	oClone:cshipDate            := ::cshipDate
	oClone:ctraceNumber         := ::ctraceNumber
	oClone:corderNumber         := ::corderNumber
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderStatusWS_1_4Service_JDMDBSOrderTrackingInfoBean
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccarrService       :=  WSAdvValue( oResponse,"_CARRSERVICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cparcel            :=  WSAdvValue( oResponse,"_PARCEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cshipDate          :=  WSAdvValue( oResponse,"_SHIPDATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctraceNumber       :=  WSAdvValue( oResponse,"_TRACENUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::corderNumber       :=  WSAdvValue( oResponse,"_ORDERNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


