#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

#INCLUDE "OFIWJD05.CH"

/* ===============================================================================
WSDL Location    \PMLinkWS_1_2_PROD.xml
Gerado em        08/30/13 14:50:35
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function OFIWJD05()
Return

/* -------------------------------------------------------------------------------
WSDL Service WSJD_POINT_PEDC
------------------------------------------------------------------------------- */

WSCLIENT WSJDPMLinkWS_1_2_Pedido_Compra

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD submitOrder
	
	WSMETHOD ExibeErro
	WSMETHOD SetDebug

	WSDATA   _URL                      AS String
	WSDATA   _SOAP_ACTION              AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	
	WSDATA _USER   AS String
	WSDATA _PASSWD AS String
	
	WSDATA   oWSorderBean              AS JD_POINT_PEDC_PMLinkOrderBean
	WSDATA   oWSsubmitOrderReturn      AS JD_POINT_PEDC_PMLinkOrderResponse

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSJDPMLinkWS_1_2_Pedido_Compra
::Init()
If Empty(::_USER) .or. Empty(::_PASSWD)
	if isBlind()
		Help(,,"ERROR",,STR0002,1,0) // "Técnico sem usuário/senha do portal da John Deere"
	else
		MsgInfo(STR0002) // "Técnico sem usuário/senha do portal da John Deere"
	endif
EndIf

Return Self

WSMETHOD INIT WSCLIENT WSJDPMLinkWS_1_2_Pedido_Compra
	::oWSorderBean       := JD_POINT_PEDC_PMLINKORDERBEAN():New()
	::oWSsubmitOrderReturn := JD_POINT_PEDC_PMLINKORDERRESPONSE():New()
	
	::_URL := GetMV("MV_MIL0015")
	
	::_USER := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	::_PASSWD := AllTrim(FM_SQL("SELECT VAI_FABPWD FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))

	::_SOAP_ACTION := "http://v1_2.pmlink.services.view.jdpoint.parts.deere.com"
	
	::_HEADOUT := {}
	aadd( ::_HEADOUT , "Authorization: Basic "+Encode64(::_USER+":"+::_PASSWD ) )	
	
Return

WSMETHOD RESET WSCLIENT WSJDPMLinkWS_1_2_Pedido_Compra
	::oWSorderBean       := NIL 
	::oWSsubmitOrderReturn := NIL 
	::Init()
Return

WSMETHOD SetDebug WSSEND lSetDebug WSCLIENT WSJDPMLinkWS_1_2_Pedido_Compra

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


WSMETHOD CLONE WSCLIENT WSJDPMLinkWS_1_2_Pedido_Compra
Local oClone := WSJDPMLinkWS_1_2_Pedido_Compra():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:oWSorderBean  :=  IIF(::oWSorderBean = NIL , NIL ,::oWSorderBean:Clone() )
	oClone:oWSsubmitOrderReturn :=  IIF(::oWSsubmitOrderReturn = NIL , NIL ,::oWSsubmitOrderReturn:Clone() )
Return oClone

// WSDL Method submitOrder of Service WSJDPMLinkWS_1_2_Pedido_Compra

WSMETHOD submitOrder WSSEND oWSorderBean WSRECEIVE oWSsubmitOrderReturn WSCLIENT WSJDPMLinkWS_1_2_Pedido_Compra
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<submitOrder xmlns="http://v1_2.pmlink.services.view.jdpoint.parts.deere.com" xmlns:bean="http://beans.v1_2.pmlink.services.view.jdpoint.parts.deere.com">'
cSoap += WSSoapValue("orderBean", ::oWSorderBean, oWSorderBean , "PMLinkOrderBean", .F. , .F., 0 , NIL, .F.) 
cSoap += "</submitOrder>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::_SOAP_ACTION,; 
	"DOCUMENT",;
	::_SOAP_ACTION,,,; 
	::_URL)

::Init()
::oWSsubmitOrderReturn:SoapRecv( WSAdvValue( oXmlRet,"_P746_SUBMITORDERRESPONSE:_P746_SUBMITORDERRETURN","PMLinkOrderResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

WSMETHOD ExibeErro WSCLIENT WSJDPMLinkWS_1_2_Pedido_Compra

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	//Local cXMLError	:= GetWSCError(4)
	If !Empty(cSoapFCode)
		// Caso a ocorrÃªncia de erro esteja com o fault_code preenchido ,
		// a mesma teve relaÃ§Ã£o com a chamada do serviÃ§o .
		if isBlind()
			Help(,,cSoapFCode,,cSoapFDescr,1,0)
		else
			MsgStop(cSoapFDescr,cSoapFCode)
		endif
		//Aviso("Erro",cXMLError,{"Ok"},2)
	Else
		// Caso a ocorrÃªncia nÃ£o tenha o soap_code preenchido
		// Ela estÃ¡ relacionada a uma outra falha ,
		// provavelmente local ou interna.
		if isBlind()
			Help(,,cSvcError,,'MILERR: internal failer on the service execution',1,0)
		else
			MsgStop(cSvcError,'MILERR: internal failer on the service execution')
		endif
	Endif

Return



// WSDL Data Structure PMLinkOrderBean

WSSTRUCT JD_POINT_PEDC_PMLinkOrderBean
	WSDATA   caccountId                AS string OPTIONAL
	WSDATA   cdateOrdered              AS string OPTIONAL
	WSDATA   cdealerOrderNumber        AS string OPTIONAL
	WSDATA   cdestinationSuffix        AS string OPTIONAL
	WSDATA   cdirectedSource           AS string OPTIONAL
	WSDATA   cbreakPointCarrier        AS string OPTIONAL
	WSDATA   cbreakPointCity           AS string OPTIONAL
	WSDATA   cbreakPointState          AS string OPTIONAL
	WSDATA   ceditOnly                 AS string OPTIONAL
	WSDATA   cimportLicenseNumber      AS string OPTIONAL
	WSDATA   cinventoryType            AS string OPTIONAL
	WSDATA   cinvestigateOrder         AS string OPTIONAL
	WSDATA   cinvoiceOnly              AS string OPTIONAL
	WSDATA   cletterOfCreditNumber     AS string OPTIONAL
	WSDATA   clineCount                AS string OPTIONAL
	WSDATA   clineOfCreditId           AS string OPTIONAL
	WSDATA   cnimexCode                AS string OPTIONAL
	WSDATA   corderType                AS string OPTIONAL
	WSDATA   coverrideShipMethod       AS string OPTIONAL
	WSDATA   cpartialShipCode          AS string OPTIONAL
	WSDATA   cpickUpLocation           AS string OPTIONAL
	WSDATA   cpriority                 AS string OPTIONAL
	WSDATA   cprogramNumber            AS string OPTIONAL
	WSDATA   creceivedBy               AS string OPTIONAL
	WSDATA   cshipAddress1             AS string OPTIONAL
	WSDATA   cshipAddress2             AS string OPTIONAL
	WSDATA   cshipCity                 AS string OPTIONAL
	WSDATA   cshipCountry              AS string OPTIONAL
	WSDATA   cshipDate                 AS string OPTIONAL
	WSDATA   cshipMethod               AS string OPTIONAL
	WSDATA   cshipMonth                AS string OPTIONAL
	WSDATA   cshipName                 AS string OPTIONAL
	WSDATA   cshipPhone                AS string OPTIONAL
	WSDATA   cshipRoutingInfo1         AS string OPTIONAL
	WSDATA   cshipRoutingInfo2         AS string OPTIONAL
	WSDATA   cshipRoutingInfo3         AS string OPTIONAL
	WSDATA   cshipRoutingInfo4         AS string OPTIONAL
	WSDATA   cshipRoutingInfo5         AS string OPTIONAL
	WSDATA   cshipState                AS string OPTIONAL
	WSDATA   cshipZipCode              AS string OPTIONAL
	WSDATA   cspecialTermsId           AS string OPTIONAL
	WSDATA   cvehicleIdentificationNumber AS string OPTIONAL
	WSDATA   cwillCall                 AS string OPTIONAL
	WSDATA   oWSorderLines             AS JD_POINT_PEDC_PMLinkOrderLineBean OPTIONAL
	WSDATA   corderNotes               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_PMLinkOrderBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_PMLinkOrderBean
	::oWSorderLines        := {} // Array Of  JD_POINT_PEDC_PMLINKORDERLINEBEAN():New()
	::corderNotes          := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_PMLinkOrderBean
	Local oClone := JD_POINT_PEDC_PMLinkOrderBean():NEW()
	oClone:caccountId           := ::caccountId
	oClone:cdateOrdered         := ::cdateOrdered
	oClone:cdealerOrderNumber   := ::cdealerOrderNumber
	oClone:cdestinationSuffix   := ::cdestinationSuffix
	oClone:cdirectedSource      := ::cdirectedSource
	oClone:cbreakPointCarrier   := ::cbreakPointCarrier
	oClone:cbreakPointCity      := ::cbreakPointCity
	oClone:cbreakPointState     := ::cbreakPointState
	oClone:ceditOnly            := ::ceditOnly
	oClone:cimportLicenseNumber := ::cimportLicenseNumber
	oClone:cinventoryType       := ::cinventoryType
	oClone:cinvestigateOrder    := ::cinvestigateOrder
	oClone:cinvoiceOnly         := ::cinvoiceOnly
	oClone:cletterOfCreditNumber := ::cletterOfCreditNumber
	oClone:clineCount           := ::clineCount
	oClone:clineOfCreditId      := ::clineOfCreditId
	oClone:cnimexCode           := ::cnimexCode
	oClone:corderType           := ::corderType
	oClone:coverrideShipMethod  := ::coverrideShipMethod
	oClone:cpartialShipCode     := ::cpartialShipCode
	oClone:cpickUpLocation      := ::cpickUpLocation
	oClone:cpriority            := ::cpriority
	oClone:cprogramNumber       := ::cprogramNumber
	oClone:creceivedBy          := ::creceivedBy
	oClone:cshipAddress1        := ::cshipAddress1
	oClone:cshipAddress2        := ::cshipAddress2
	oClone:cshipCity            := ::cshipCity
	oClone:cshipCountry         := ::cshipCountry
	oClone:cshipDate            := ::cshipDate
	oClone:cshipMethod          := ::cshipMethod
	oClone:cshipMonth           := ::cshipMonth
	oClone:cshipName            := ::cshipName
	oClone:cshipPhone           := ::cshipPhone
	oClone:cshipRoutingInfo1    := ::cshipRoutingInfo1
	oClone:cshipRoutingInfo2    := ::cshipRoutingInfo2
	oClone:cshipRoutingInfo3    := ::cshipRoutingInfo3
	oClone:cshipRoutingInfo4    := ::cshipRoutingInfo4
	oClone:cshipRoutingInfo5    := ::cshipRoutingInfo5
	oClone:cshipState           := ::cshipState
	oClone:cshipZipCode         := ::cshipZipCode
	oClone:cspecialTermsId      := ::cspecialTermsId
	oClone:cvehicleIdentificationNumber := ::cvehicleIdentificationNumber
	oClone:cwillCall            := ::cwillCall
	oClone:oWSorderLines := NIL
	If ::oWSorderLines <> NIL 
		oClone:oWSorderLines := {}
		aEval( ::oWSorderLines , { |x| aadd( oClone:oWSorderLines , x:Clone() ) } )
	Endif 
	oClone:corderNotes          := IIf(::corderNotes <> NIL , aClone(::corderNotes) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT JD_POINT_PEDC_PMLinkOrderBean
	Local cSoap := ""
	cSoap += WSSoapValue("bean:accountId", ::caccountId, ::caccountId , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:dateOrdered", ::cdateOrdered, ::cdateOrdered , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:dealerOrderNumber", ::cdealerOrderNumber, ::cdealerOrderNumber , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:destinationSuffix", ::cdestinationSuffix, ::cdestinationSuffix , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:directedSource", ::cdirectedSource, ::cdirectedSource , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:breakPointCarrier", ::cbreakPointCarrier, ::cbreakPointCarrier , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:breakPointCity", ::cbreakPointCity, ::cbreakPointCity , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:breakPointState", ::cbreakPointState, ::cbreakPointState , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:editOnly", ::ceditOnly, ::ceditOnly , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:importLicenseNumber", ::cimportLicenseNumber, ::cimportLicenseNumber , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:inventoryType", ::cinventoryType, ::cinventoryType , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:investigateOrder", ::cinvestigateOrder, ::cinvestigateOrder , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:invoiceOnly", ::cinvoiceOnly, ::cinvoiceOnly , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:letterOfCreditNumber", ::cletterOfCreditNumber, ::cletterOfCreditNumber , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:lineCount", ::clineCount, ::clineCount , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:lineOfCreditId", ::clineOfCreditId, ::clineOfCreditId , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:nimexCode", ::cnimexCode, ::cnimexCode , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:orderType", ::corderType, ::corderType , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:overrideShipMethod", ::coverrideShipMethod, ::coverrideShipMethod , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:partialShipCode", ::cpartialShipCode, ::cpartialShipCode , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:pickUpLocation", ::cpickUpLocation, ::cpickUpLocation , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:priority", ::cpriority, ::cpriority , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:programNumber", ::cprogramNumber, ::cprogramNumber , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:receivedBy", ::creceivedBy, ::creceivedBy , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipAddress1", ::cshipAddress1, ::cshipAddress1 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipAddress2", ::cshipAddress2, ::cshipAddress2 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipCity", ::cshipCity, ::cshipCity , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipCountry", ::cshipCountry, ::cshipCountry , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipDate", ::cshipDate, ::cshipDate , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipMethod", ::cshipMethod, ::cshipMethod , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipMonth", ::cshipMonth, ::cshipMonth , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipName", ::cshipName, ::cshipName , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipPhone", ::cshipPhone, ::cshipPhone , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipRoutingInfo1", ::cshipRoutingInfo1, ::cshipRoutingInfo1 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipRoutingInfo2", ::cshipRoutingInfo2, ::cshipRoutingInfo2 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipRoutingInfo3", ::cshipRoutingInfo3, ::cshipRoutingInfo3 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipRoutingInfo4", ::cshipRoutingInfo4, ::cshipRoutingInfo4 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipRoutingInfo5", ::cshipRoutingInfo5, ::cshipRoutingInfo5 , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipState", ::cshipState, ::cshipState , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:shipZipCode", ::cshipZipCode, ::cshipZipCode , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:specialTermsId", ::cspecialTermsId, ::cspecialTermsId , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:vehicleIdentificationNumber", ::cvehicleIdentificationNumber, ::cvehicleIdentificationNumber , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:willCall", ::cwillCall, ::cwillCall , "string", .F. , .F., 0 , NIL, .F.) 
	aEval( ::oWSorderLines , {|x| cSoap := cSoap  +  WSSoapValue("bean:orderLines", x , x , "PMLinkOrderLineBean", .F. , .F., 0 , NIL, .F.)  } ) 
	aEval( ::corderNotes , {|x| cSoap := cSoap  +  WSSoapValue("bean:orderNotes", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure PMLinkOrderResponse

WSSTRUCT JD_POINT_PEDC_PMLinkOrderResponse
	WSDATA   corderNumber              AS string OPTIONAL
	WSDATA   creasonCode               AS string OPTIONAL
	WSDATA   cresponseMessage          AS string OPTIONAL
	WSDATA   creturnCode               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_PMLinkOrderResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_PMLinkOrderResponse
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_PMLinkOrderResponse
	Local oClone := JD_POINT_PEDC_PMLinkOrderResponse():NEW()
	oClone:corderNumber         := ::corderNumber
	oClone:creasonCode          := ::creasonCode
	oClone:cresponseMessage     := ::cresponseMessage
	oClone:creturnCode          := ::creturnCode
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_POINT_PEDC_PMLinkOrderResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::corderNumber       :=  WSAdvValue( oResponse,"_P178_ORDERNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creasonCode        :=  WSAdvValue( oResponse,"_P178_REASONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cresponseMessage   :=  WSAdvValue( oResponse,"_P178_RESPONSEMESSAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creturnCode        :=  WSAdvValue( oResponse,"_P178_RETURNCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PMLinkOrderLineBean

WSSTRUCT JD_POINT_PEDC_PMLinkOrderLineBean
	WSDATA   ccustomerPartNumber       AS string OPTIONAL
	WSDATA   cdealerBinLocation        AS string OPTIONAL
	WSDATA   cdrivenPrice              AS string OPTIONAL
	WSDATA   clineDirectedSource       AS string OPTIONAL
	WSDATA   cnimexCode                AS string OPTIONAL
	WSDATA   conlyQuantity             AS string OPTIONAL
	WSDATA   corderedQuantity          AS string OPTIONAL
	WSDATA   cpartName                 AS string OPTIONAL
	WSDATA   cpartNumber               AS string OPTIONAL
	WSDATA   clineNotes                AS string OPTIONAL
	WSDATA   cinvoiceAmount            AS string OPTIONAL
	WSDATA   cinvoiceGrossAmount       AS string OPTIONAL
	WSDATA   cpartDiscountAmount       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_POINT_PEDC_PMLinkOrderLineBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_POINT_PEDC_PMLinkOrderLineBean
	::clineNotes           := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT JD_POINT_PEDC_PMLinkOrderLineBean
	Local oClone := JD_POINT_PEDC_PMLinkOrderLineBean():NEW()
	oClone:ccustomerPartNumber  := ::ccustomerPartNumber
	oClone:cdealerBinLocation   := ::cdealerBinLocation
	oClone:cdrivenPrice         := ::cdrivenPrice
	oClone:clineDirectedSource  := ::clineDirectedSource
	oClone:cnimexCode           := ::cnimexCode
	oClone:conlyQuantity        := ::conlyQuantity
	oClone:corderedQuantity     := ::corderedQuantity
	oClone:cpartName            := ::cpartName
	oClone:cpartNumber          := ::cpartNumber
	oClone:clineNotes           := IIf(::clineNotes <> NIL , aClone(::clineNotes) , NIL )
	oClone:cinvoiceAmount       := ::cinvoiceAmount
	oClone:cinvoiceGrossAmount  := ::cinvoiceGrossAmount
	oClone:cpartDiscountAmount  := ::cpartDiscountAmount
Return oClone

WSMETHOD SOAPSEND WSCLIENT JD_POINT_PEDC_PMLinkOrderLineBean
	Local cSoap := ""
	cSoap += WSSoapValue("bean:customerPartNumber", ::ccustomerPartNumber, ::ccustomerPartNumber , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:dealerBinLocation", ::cdealerBinLocation, ::cdealerBinLocation , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:drivenPrice", ::cdrivenPrice, ::cdrivenPrice , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:lineDirectedSource", ::clineDirectedSource, ::clineDirectedSource , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:nimexCode", ::cnimexCode, ::cnimexCode , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:onlyQuantity", ::conlyQuantity, ::conlyQuantity , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:orderedQuantity", ::corderedQuantity, ::corderedQuantity , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:partName", ::cpartName, ::cpartName , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:partNumber", ::cpartNumber, ::cpartNumber , "string", .F. , .F., 0 , NIL, .F.) 
	aEval( ::clineNotes , {|x| cSoap := cSoap  +  WSSoapValue("bean:lineNotes", x , x , "string", .F. , .F., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("bean:invoiceAmount", ::cinvoiceAmount, ::cinvoiceAmount , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:invoiceGrossAmount", ::cinvoiceGrossAmount, ::cinvoiceGrossAmount , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:partDiscountAmount", ::cpartDiscountAmount, ::cpartDiscountAmount , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap



/* -------------------------------------------------------------------------------
WSDL Service WSJDPMLinkWS_2_3_Pedido_Compra
------------------------------------------------------------------------------- */

WSCLIENT WSJDPMLinkWS_2_3_Pedido_Compra
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD submitOrder

	WSMETHOD ExibeErro
	WSMETHOD SetDebug
	WSMETHOD SetToken

	//WSDATA   _Token as String

	WSDATA oOkta as OBJECT

	WSDATA   _URL                      AS String
	WSDATA   _SOAP_ACTION              AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String

	WSDATA _USER   AS String
	WSDATA _PASSWD AS String

	WSDATA   oWSorderBean              AS PMLinkWS_2_3Service_PMLinkOrderBean
	WSDATA   oWSsubmitOrderReturn      AS PMLinkWS_2_3Service_PMLinkOrderResponse

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSJDPMLinkWS_2_3_Pedido_Compra
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSJDPMLinkWS_2_3_Pedido_Compra

	::_HEADOUT := {}

	::_USER := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	::_PASSWD := AllTrim(FM_SQL("SELECT VAI_FABPWD FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))

	self:oOkta := OFJDOkta():New()
	self:oOkta:SetUserPasswd(::_USER, ::_PASSWD)

	::_URL := self:oOkta:oConfig:getUrlWSPmLinkJDPoint()
	::_SOAP_ACTION := "http://v1_3.pmlink.services.view.jdpoint.parts.deere.com"

	::oWSorderBean       := PMLinkWS_2_3Service_PMLINKORDERBEAN():New()
	::oWSsubmitOrderReturn := PMLinkWS_2_3Service_PMLINKORDERRESPONSE():New()
Return

WSMETHOD RESET WSCLIENT WSJDPMLinkWS_2_3_Pedido_Compra
	::oWSorderBean       := NIL 
	::oWSsubmitOrderReturn := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSJDPMLinkWS_2_3_Pedido_Compra
Local oClone := WSJDPMLinkWS_2_3_Pedido_Compra():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:oWSorderBean  :=  IIF(::oWSorderBean = NIL , NIL ,::oWSorderBean:Clone() )
	oClone:oWSsubmitOrderReturn :=  IIF(::oWSsubmitOrderReturn = NIL , NIL ,::oWSsubmitOrderReturn:Clone() )
Return oClone

WSMETHOD submitOrder WSSEND oWSorderBean WSRECEIVE oWSsubmitOrderReturn WSCLIENT WSJDPMLinkWS_2_3_Pedido_Compra
	Local cSoap := "" , oXmlRet
	Local cToken

	self:oOkta:SetPMLinkJDPoint()

	cToken := self:oOkta:getToken()
	If Empty(cToken)
		MsgStop("Falha na obtenção do Token de Acesso.","Erro")
		Return .f.
	EndIf

	::_HEADOUT := {}
	aadd( ::_HEADOUT , "Authorization: Bearer " + cToken )

	BEGIN WSMETHOD

	cSoap += '<submitOrder xmlns="http://v1_3.pmlink.services.view.jdpoint.parts.deere.com">'
	cSoap += WSSoapValue("orderBean", ::oWSorderBean, oWSorderBean , "PMLinkOrderBean", .F. , .F., 0 , "http://beans.v1_3.pmlink.services.view.jdpoint.parts.deere.com", .F.,.F.) 
	cSoap += "</submitOrder>"

	oXmlRet := SvcSoapCall(Self,cSoap,; 
		::_SOAP_ACTION,; 
		"DOCUMENT",;
		::_SOAP_ACTION,,,; 
		::_URL)

	::Init()
	::oWSsubmitOrderReturn:SoapRecv( WSAdvValue( oXmlRet,"_SUBMITORDERRESPONSE:_SUBMITORDERRETURN","PMLinkOrderResponse",NIL,NIL,NIL,NIL,NIL,"p551") )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

WSMETHOD SetDebug WSSEND lSetDebug WSCLIENT WSJDPMLinkWS_2_3_Pedido_Compra

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


WSMETHOD ExibeErro WSCLIENT WSJDPMLinkWS_2_3_Pedido_Compra

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	
	If ! Empty(cSoapFCode)
		MsgStop(cSoapFDescr,cSoapFCode)
	ElseIf ! Empty(cSvcError)
		MsgStop(cSvcError,'Falha interna de execução do serviço')
	Endif

Return


// WSDL Data Structure PMLinkOrderBean

WSSTRUCT PMLinkWS_2_3Service_PMLinkOrderBean
	WSDATA   caccountId                AS string OPTIONAL
	WSDATA   cdateOrdered              AS string OPTIONAL
	WSDATA   cdealerOrderNumber        AS string OPTIONAL
	WSDATA   cdestinationSuffix        AS string OPTIONAL
	WSDATA   cdirectedSource           AS string OPTIONAL
	WSDATA   cbreakPointCarrier        AS string OPTIONAL
	WSDATA   cbreakPointCity           AS string OPTIONAL
	WSDATA   cbreakPointState          AS string OPTIONAL
	WSDATA   ceditOnly                 AS string OPTIONAL
	WSDATA   cimportLicenseNumber      AS string OPTIONAL
	WSDATA   cinventoryType            AS string OPTIONAL
	WSDATA   cinvestigateOrder         AS string OPTIONAL
	WSDATA   cinvoiceOnly              AS string OPTIONAL
	WSDATA   cletterOfCreditNumber     AS string OPTIONAL
	WSDATA   clineCount                AS string OPTIONAL
	WSDATA   clineOfCreditId           AS string OPTIONAL
	WSDATA   cnimexCode                AS string OPTIONAL
	WSDATA   corderType                AS string OPTIONAL
	WSDATA   coverrideShipMethod       AS string OPTIONAL
	WSDATA   cpartialShipCode          AS string OPTIONAL
	WSDATA   cpickUpLocation           AS string OPTIONAL
	WSDATA   cpriority                 AS string OPTIONAL
	WSDATA   cprogramNumber            AS string OPTIONAL
	WSDATA   creceivedBy               AS string OPTIONAL
	WSDATA   cshipAddress1             AS string OPTIONAL
	WSDATA   cshipAddress2             AS string OPTIONAL
	WSDATA   cshipCity                 AS string OPTIONAL
	WSDATA   cshipCountry              AS string OPTIONAL
	WSDATA   cshipDate                 AS string OPTIONAL
	WSDATA   cshipMethod               AS string OPTIONAL
	WSDATA   cshipMonth                AS string OPTIONAL
	WSDATA   cshipName                 AS string OPTIONAL
	WSDATA   cshipPhone                AS string OPTIONAL
	WSDATA   cshipRoutingInfo1         AS string OPTIONAL
	WSDATA   cshipRoutingInfo2         AS string OPTIONAL
	WSDATA   cshipRoutingInfo3         AS string OPTIONAL
	WSDATA   cshipRoutingInfo4         AS string OPTIONAL
	WSDATA   cshipRoutingInfo5         AS string OPTIONAL
	WSDATA   cshipState                AS string OPTIONAL
	WSDATA   cshipZipCode              AS string OPTIONAL
	WSDATA   cspecialTermsId           AS string OPTIONAL
	WSDATA   cvehicleIdentificationNumber AS string OPTIONAL
	WSDATA   cwillCall                 AS string OPTIONAL
	WSDATA   oWSorderLines             AS PMLinkWS_2_3Service_PMLinkOrderLineBean OPTIONAL
	WSDATA   corderNotes               AS string OPTIONAL
	WSDATA   cautoSubmit               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PMLinkWS_2_3Service_PMLinkOrderBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PMLinkWS_2_3Service_PMLinkOrderBean
	::oWSorderLines        := {} // Array Of  PMLinkWS_2_3Service_PMLINKORDERLINEBEAN():New()
	::corderNotes          := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT PMLinkWS_2_3Service_PMLinkOrderBean
	Local oClone := PMLinkWS_2_3Service_PMLinkOrderBean():NEW()
	oClone:caccountId           := ::caccountId
	oClone:cdateOrdered         := ::cdateOrdered
	oClone:cdealerOrderNumber   := ::cdealerOrderNumber
	oClone:cdestinationSuffix   := ::cdestinationSuffix
	oClone:cdirectedSource      := ::cdirectedSource
	oClone:cbreakPointCarrier   := ::cbreakPointCarrier
	oClone:cbreakPointCity      := ::cbreakPointCity
	oClone:cbreakPointState     := ::cbreakPointState
	oClone:ceditOnly            := ::ceditOnly
	oClone:cimportLicenseNumber := ::cimportLicenseNumber
	oClone:cinventoryType       := ::cinventoryType
	oClone:cinvestigateOrder    := ::cinvestigateOrder
	oClone:cinvoiceOnly         := ::cinvoiceOnly
	oClone:cletterOfCreditNumber := ::cletterOfCreditNumber
	oClone:clineCount           := ::clineCount
	oClone:clineOfCreditId      := ::clineOfCreditId
	oClone:cnimexCode           := ::cnimexCode
	oClone:corderType           := ::corderType
	oClone:coverrideShipMethod  := ::coverrideShipMethod
	oClone:cpartialShipCode     := ::cpartialShipCode
	oClone:cpickUpLocation      := ::cpickUpLocation
	oClone:cpriority            := ::cpriority
	oClone:cprogramNumber       := ::cprogramNumber
	oClone:creceivedBy          := ::creceivedBy
	oClone:cshipAddress1        := ::cshipAddress1
	oClone:cshipAddress2        := ::cshipAddress2
	oClone:cshipCity            := ::cshipCity
	oClone:cshipCountry         := ::cshipCountry
	oClone:cshipDate            := ::cshipDate
	oClone:cshipMethod          := ::cshipMethod
	oClone:cshipMonth           := ::cshipMonth
	oClone:cshipName            := ::cshipName
	oClone:cshipPhone           := ::cshipPhone
	oClone:cshipRoutingInfo1    := ::cshipRoutingInfo1
	oClone:cshipRoutingInfo2    := ::cshipRoutingInfo2
	oClone:cshipRoutingInfo3    := ::cshipRoutingInfo3
	oClone:cshipRoutingInfo4    := ::cshipRoutingInfo4
	oClone:cshipRoutingInfo5    := ::cshipRoutingInfo5
	oClone:cshipState           := ::cshipState
	oClone:cshipZipCode         := ::cshipZipCode
	oClone:cspecialTermsId      := ::cspecialTermsId
	oClone:cvehicleIdentificationNumber := ::cvehicleIdentificationNumber
	oClone:cwillCall            := ::cwillCall
	oClone:oWSorderLines := NIL
	If ::oWSorderLines <> NIL 
		oClone:oWSorderLines := {}
		aEval( ::oWSorderLines , { |x| aadd( oClone:oWSorderLines , x:Clone() ) } )
	Endif 
	oClone:corderNotes          := IIf(::corderNotes <> NIL , aClone(::corderNotes) , NIL )
	oClone:cautoSubmit          := ::cautoSubmit
Return oClone

WSMETHOD SOAPSEND WSCLIENT PMLinkWS_2_3Service_PMLinkOrderBean
	Local cSoap := ""
	cSoap += WSSoapValue("accountId", ::caccountId, ::caccountId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("dateOrdered", ::cdateOrdered, ::cdateOrdered , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("dealerOrderNumber", ::cdealerOrderNumber, ::cdealerOrderNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("destinationSuffix", ::cdestinationSuffix, ::cdestinationSuffix , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("directedSource", ::cdirectedSource, ::cdirectedSource , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("breakPointCarrier", ::cbreakPointCarrier, ::cbreakPointCarrier , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("breakPointCity", ::cbreakPointCity, ::cbreakPointCity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("breakPointState", ::cbreakPointState, ::cbreakPointState , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("editOnly", ::ceditOnly, ::ceditOnly , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("importLicenseNumber", ::cimportLicenseNumber, ::cimportLicenseNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("inventoryType", ::cinventoryType, ::cinventoryType , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("investigateOrder", ::cinvestigateOrder, ::cinvestigateOrder , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("invoiceOnly", ::cinvoiceOnly, ::cinvoiceOnly , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("letterOfCreditNumber", ::cletterOfCreditNumber, ::cletterOfCreditNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("lineCount", ::clineCount, ::clineCount , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("lineOfCreditId", ::clineOfCreditId, ::clineOfCreditId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nimexCode", ::cnimexCode, ::cnimexCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("orderType", ::corderType, ::corderType , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("overrideShipMethod", ::coverrideShipMethod, ::coverrideShipMethod , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("partialShipCode", ::cpartialShipCode, ::cpartialShipCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("pickUpLocation", ::cpickUpLocation, ::cpickUpLocation , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("priority", ::cpriority, ::cpriority , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("programNumber", ::cprogramNumber, ::cprogramNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("receivedBy", ::creceivedBy, ::creceivedBy , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipAddress1", ::cshipAddress1, ::cshipAddress1 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipAddress2", ::cshipAddress2, ::cshipAddress2 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipCity", ::cshipCity, ::cshipCity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipCountry", ::cshipCountry, ::cshipCountry , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipDate", ::cshipDate, ::cshipDate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipMethod", ::cshipMethod, ::cshipMethod , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipMonth", ::cshipMonth, ::cshipMonth , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipName", ::cshipName, ::cshipName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipPhone", ::cshipPhone, ::cshipPhone , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipRoutingInfo1", ::cshipRoutingInfo1, ::cshipRoutingInfo1 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipRoutingInfo2", ::cshipRoutingInfo2, ::cshipRoutingInfo2 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipRoutingInfo3", ::cshipRoutingInfo3, ::cshipRoutingInfo3 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipRoutingInfo4", ::cshipRoutingInfo4, ::cshipRoutingInfo4 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipRoutingInfo5", ::cshipRoutingInfo5, ::cshipRoutingInfo5 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipState", ::cshipState, ::cshipState , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shipZipCode", ::cshipZipCode, ::cshipZipCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("specialTermsId", ::cspecialTermsId, ::cspecialTermsId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("vehicleIdentificationNumber", ::cvehicleIdentificationNumber, ::cvehicleIdentificationNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("willCall", ::cwillCall, ::cwillCall , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::oWSorderLines , {|x| cSoap := cSoap  +  WSSoapValue("orderLines", x , x , "PMLinkOrderLineBean", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::corderNotes , {|x| cSoap := cSoap  +  WSSoapValue("orderNotes", x , x , "string", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("autoSubmit", ::cautoSubmit, ::cautoSubmit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure PMLinkOrderResponse

WSSTRUCT PMLinkWS_2_3Service_PMLinkOrderResponse
	WSDATA   corderNumber              AS string OPTIONAL
	WSDATA   creasonCode               AS string OPTIONAL
	WSDATA   cresponseMessage          AS string OPTIONAL
	WSDATA   creturnCode               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PMLinkWS_2_3Service_PMLinkOrderResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PMLinkWS_2_3Service_PMLinkOrderResponse
Return

WSMETHOD CLONE WSCLIENT PMLinkWS_2_3Service_PMLinkOrderResponse
	Local oClone := PMLinkWS_2_3Service_PMLinkOrderResponse():NEW()
	oClone:corderNumber         := ::corderNumber
	oClone:creasonCode          := ::creasonCode
	oClone:cresponseMessage     := ::cresponseMessage
	oClone:creturnCode          := ::creturnCode
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT PMLinkWS_2_3Service_PMLinkOrderResponse
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::corderNumber       :=  WSAdvValue( oResponse, "_ORDERNUMBER"     ,"string" , NIL , NIL , NIL , "S" , NIL , "p178") 
	::creasonCode        :=  WSAdvValue( oResponse, "_REASONCODE"      ,"string" , NIL , NIL , NIL , "S" , NIL , "p178") 
	::cresponseMessage   :=  WSAdvValue( oResponse, "_RESPONSEMESSAGE" ,"string" , NIL , NIL , NIL , "S" , NIL , "p178") 
	::creturnCode        :=  WSAdvValue( oResponse, "_RETURNCODE"      ,"string" , NIL , NIL , NIL , "S" , NIL , "p178") 
Return

// WSDL Data Structure PMLinkOrderLineBean

WSSTRUCT PMLinkWS_2_3Service_PMLinkOrderLineBean
	WSDATA   ccustomerPartNumber       AS string OPTIONAL
	WSDATA   cdealerBinLocation        AS string OPTIONAL
	WSDATA   cdrivenPrice              AS string OPTIONAL
	WSDATA   clineDirectedSource       AS string OPTIONAL
	WSDATA   cnimexCode                AS string OPTIONAL
	WSDATA   conlyQuantity             AS string OPTIONAL
	WSDATA   corderedQuantity          AS string OPTIONAL
	WSDATA   cpartName                 AS string OPTIONAL
	WSDATA   cpartNumber               AS string OPTIONAL
	WSDATA   clineNotes                AS string OPTIONAL
	WSDATA   cinvoiceAmount            AS string OPTIONAL
	WSDATA   cinvoiceGrossAmount       AS string OPTIONAL
	WSDATA   cpartDiscountAmount       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PMLinkWS_2_3Service_PMLinkOrderLineBean
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PMLinkWS_2_3Service_PMLinkOrderLineBean
	::clineNotes           := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT PMLinkWS_2_3Service_PMLinkOrderLineBean
	Local oClone := PMLinkWS_2_3Service_PMLinkOrderLineBean():NEW()
	oClone:ccustomerPartNumber  := ::ccustomerPartNumber
	oClone:cdealerBinLocation   := ::cdealerBinLocation
	oClone:cdrivenPrice         := ::cdrivenPrice
	oClone:clineDirectedSource  := ::clineDirectedSource
	oClone:cnimexCode           := ::cnimexCode
	oClone:conlyQuantity        := ::conlyQuantity
	oClone:corderedQuantity     := ::corderedQuantity
	oClone:cpartName            := ::cpartName
	oClone:cpartNumber          := ::cpartNumber
	oClone:clineNotes           := IIf(::clineNotes <> NIL , aClone(::clineNotes) , NIL )
	oClone:cinvoiceAmount       := ::cinvoiceAmount
	oClone:cinvoiceGrossAmount  := ::cinvoiceGrossAmount
	oClone:cpartDiscountAmount  := ::cpartDiscountAmount
Return oClone

WSMETHOD SOAPSEND WSCLIENT PMLinkWS_2_3Service_PMLinkOrderLineBean
	Local cSoap := ""
	cSoap += WSSoapValue("customerPartNumber", ::ccustomerPartNumber, ::ccustomerPartNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("dealerBinLocation", ::cdealerBinLocation, ::cdealerBinLocation , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("drivenPrice", ::cdrivenPrice, ::cdrivenPrice , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("lineDirectedSource", ::clineDirectedSource, ::clineDirectedSource , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nimexCode", ::cnimexCode, ::cnimexCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("onlyQuantity", ::conlyQuantity, ::conlyQuantity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("orderedQuantity", ::corderedQuantity, ::corderedQuantity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("partName", ::cpartName, ::cpartName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("partNumber", ::cpartNumber, ::cpartNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::clineNotes , {|x| cSoap := cSoap  +  WSSoapValue("lineNotes", x , x , "string", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("invoiceAmount", ::cinvoiceAmount, ::cinvoiceAmount , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("invoiceGrossAmount", ::cinvoiceGrossAmount, ::cinvoiceGrossAmount , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("partDiscountAmount", ::cpartDiscountAmount, ::cpartDiscountAmount , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


