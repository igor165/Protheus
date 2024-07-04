// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#include "OFIWJD04.CH"

/* ===============================================================================
WSDL Location    /jd/jdpoint/notafiscal.wsdl
Gerado em        08/20/13 16:32:56
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function OFIWJD04()
Return

/* -------------------------------------------------------------------------------
WSDL Service WSJohnDeereJDPointNF
------------------------------------------------------------------------------- */

WSCLIENT WSJohnDeereJDPointNF

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD getAdvanceShipNotice

	WSMETHOD ExibeErro
	WSMETHOD SetDebug

	WSDATA lOkta
	WSDATA oOkta as OBJECT

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA 	 _SOAP_ACTION 			   AS String
	WSDATA 	 _TARGET_NAMESPACE         AS String
	WSDATA	 ERRO

	WSDATA _USER   AS String
	WSDATA _PASSWD AS String


	WSDATA   oWSinput                  AS AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeIP
	WSDATA   oWSgetAdvanceShipNoticeReturn AS AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeOP

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSJohnDeereJDPointNF

	::Init()
	::ERRO := .f.

	If Empty(::_USER) .or. Empty(::_PASSWD)
		MsgStop(STR0002,STR0004) // O seu cadastro de Equipe Técnica (OFIOA180) está com os campos referentes ao usuário X e senha do portal da John Deere em branco (campo VAI_FABUSR e campo VAI_FABPWD). Por favor verifique junto ao administrador do sistema! // Atenção!
		::ERRO := .t.
	EndIf

Return Self

WSMETHOD INIT WSCLIENT WSJohnDeereJDPointNF
	::oWSinput           := AdvanceShipNoticeWS_1_1Service_GETADVANCESHIPNOTICEIP():New()
	::oWSgetAdvanceShipNoticeReturn := AdvanceShipNoticeWS_1_1Service_GETADVANCESHIPNOTICEOP():New()

	::_URL := GetMV("MV_MIL0043")

	::_USER := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	::_PASSWD := AllTrim(FM_SQL("SELECT VAI_FABPWD FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	
	::_SOAP_ACTION := ""// "http://sap.com/xi/WebService/soap1.1"
	::_TARGET_NAMESPACE := "http://v1_1.asn.service.view.financialdocument.parts.deere.com"
	
	If self:oOkta == NIL
		self:oOkta := OFJDOkta():New()
		::lOkta := self:oOkta:oConfig:notaFiscalCompra()
		If ::lOkta
			self:oOkta:SetUserPasswd(::_USER, ::_PASSWD)
			self:oOkta:SetNFCompra()
			::_URL := self:oOkta:oConfig:getUrlWSNotaFiscalCompra()
		EndIf
	EndIf
Return

WSMETHOD RESET WSCLIENT WSJohnDeereJDPointNF
	::oWSinput           := NIL 
	::oWSgetAdvanceShipNoticeReturn := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSJohnDeereJDPointNF
Local oClone := WSJohnDeereJDPointNF():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:oWSinput      :=  IIF(::oWSinput = NIL , NIL ,::oWSinput:Clone() )
	oClone:oWSgetAdvanceShipNoticeReturn :=  IIF(::oWSgetAdvanceShipNoticeReturn = NIL , NIL ,::oWSgetAdvanceShipNoticeReturn:Clone() )
Return oClone

// WSDL Method getAdvanceShipNotice of Service WSJohnDeereJDPointNF

WSMETHOD getAdvanceShipNotice WSSEND oWSinput WSRECEIVE oWSgetAdvanceShipNoticeReturn WSCLIENT WSJohnDeereJDPointNF
Local cSoap := "" , oXmlRet
Local cToken := ""

::_HEADOUT := {}

If ::lOkta
	cToken := self:oOkta:getToken()
	If Empty(cToken)
		MsgStop(STR0008,STR0009) // "Falha na obtenção do Token de Acesso."
		Return .f.
	EndIf
	aadd( ::_HEADOUT , "Authorization: Bearer " + cToken )
Else
	aadd( ::_HEADOUT , "Authorization: Basic "+Encode64(::_USER+":"+::_PASSWD ) )
EndIf
aadd( ::_HEADOUT , "Timeout: 400000 " )

BEGIN WSMETHOD

cSoap += '<getAdvanceShipNotice xmlns="http://v1_1.asn.service.view.financialdocument.parts.deere.com" xmlns:bean="http://beans.v1_1.asn.service.view.financialdocument.parts.deere.com">'
cSoap += WSSoapValue("input", ::oWSinput, oWSinput , "GetAdvanceShipNoticeIP", .F. , .F., 0 , NIL, .F.) 
cSoap += "</getAdvanceShipNotice>"

oXmlRet := SvcSoapCall(;
	Self,;
	cSoap,; 
	::_SOAP_ACTION,;
	"DOCUMENT",;
	::_SOAP_ACTION,;
	,;
	,; 
	::_URL)

::Init()
::oWSgetAdvanceShipNoticeReturn:SoapRecv( WSAdvValue( oXmlRet,"_NS2_GETADVANCESHIPNOTICERESPONSE:_NS2_GETADVANCESHIPNOTICERETURN","GetAdvanceShipNoticeOP",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure GetAdvanceShipNoticeIP

WSSTRUCT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeIP
	WSDATA   ccaseID                   AS string OPTIONAL
	WSDATA   cinvSequenceNumber    AS string OPTIONAL
	WSDATA   cinvoiceSeriesNumber      AS string OPTIONAL
	WSDATA   cmoveOrderID              AS string OPTIONAL
	WSDATA   cpacklistID               AS string OPTIONAL
	WSDATA   csoldByUnitCode           AS string OPTIONAL
	WSDATA   caccountID                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeIP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeIP
Return

WSMETHOD CLONE WSCLIENT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeIP
	Local oClone := AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeIP():NEW()
	oClone:ccaseID              := ::ccaseID
	oClone:cinvSequenceNumber := ::cinvSequenceNumber
	oClone:cinvoiceSeriesNumber := ::cinvoiceSeriesNumber
	oClone:cmoveOrderID         := ::cmoveOrderID
	oClone:cpacklistID          := ::cpacklistID
	oClone:csoldByUnitCode      := ::csoldByUnitCode
	oClone:caccountID           := ::caccountID
Return oClone

WSMETHOD SOAPSEND WSCLIENT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeIP
	Local cSoap := ""
	cSoap += WSSoapValue("bean:caseID", ::ccaseID, ::ccaseID , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:invoiceSequenceNumber", ::cinvSequenceNumber, ::cinvSequenceNumber , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:invoiceSeriesNumber", ::cinvoiceSeriesNumber, ::cinvoiceSeriesNumber , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:moveOrderID", ::cmoveOrderID, ::cmoveOrderID , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:packlistID", ::cpacklistID, ::cpacklistID , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:soldByUnitCode", ::csoldByUnitCode, ::csoldByUnitCode , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("bean:accountID", ::caccountID, ::caccountID , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure GetAdvanceShipNoticeOP

WSSTRUCT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeOP
	WSDATA   caccountID                AS string OPTIONAL
	WSDATA   csoldByUnit               AS string OPTIONAL
	WSDATA   oWSinvoice                AS AdvanceShipNoticeWS_1_1Service_Invoice OPTIONAL
	WSDATA   cresponseMessage          AS string OPTIONAL
	WSDATA   creturnCode               AS string OPTIONAL
	WSDATA   creasonCode               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeOP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeOP
Return

WSMETHOD CLONE WSCLIENT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeOP
	Local oClone := AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeOP():NEW()
	oClone:caccountID           := ::caccountID
	oClone:csoldByUnit          := ::csoldByUnit
	oClone:oWSinvoice           := IIF(::oWSinvoice = NIL , NIL , ::oWSinvoice:Clone() )
	oClone:cresponseMessage     := ::cresponseMessage
	oClone:creturnCode          := ::creturnCode
	oClone:creasonCode          := ::creasonCode
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AdvanceShipNoticeWS_1_1Service_GetAdvanceShipNoticeOP
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::caccountID         :=  WSAdvValue( oResponse,"_ACCOUNTID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csoldByUnit        :=  WSAdvValue( oResponse,"_SOLDBYUNIT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_INVOICE","Invoice",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSinvoice := AdvanceShipNoticeWS_1_1Service_Invoice():New()
		::oWSinvoice:SoapRecv(oNode3)
	EndIf
	::cresponseMessage   :=  WSAdvValue( oResponse,"_RESPONSEMESSAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creturnCode        :=  WSAdvValue( oResponse,"_RETURNCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::creasonCode        :=  WSAdvValue( oResponse,"_REASONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Invoice

WSMETHOD ExibeErro WSCLIENT WSJohnDeereJDPointNF

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description

	If !Empty(cSoapFCode)
		MsgStop(cSoapFDescr,cSoapFCode)
	Else
		// Caso a ocorrÃªncia nÃ£o tenha o soap_code preenchido
		// Ela estÃ¡ relacionada a uma outra falha ,
		// provavelmente local ou interna.  
		if "WSCERR044" $ cSvcError .and.  "11001" $ cSvcError // Host not found - endereço não encontrado  
			MsgStop(STR0007,STR0004) // O Webservice da John Deere retornou informando que o endereço para comunicação com o Webservice informado no parâmetro MV_MIL0043 está incorreto. Por favor verifique junto ao administrador do sistema! //Atenção!
		Elseif "WSCERR044" $ cSvcError .and. "401" $ cSvcError // Authorization required - usuário x e senha
			MsgStop(STR0006,STR0004) // O Webservice da John Deere retornou informando que seu usuário x e senha do portal da John Deere não possui o acesso necessário ou que está incorreto. Por favor, verifique se sua senha não está vencida ou se foi alterada recentemente. Em caso de dúvidas, verifique junto ao administrador do sistema! //Atenção!
		Elseif "WSCERR064" $ cSvcError
			MsgStop(STR0007,STR0004) // O Webservice da John Deere retornou informando que o endereço para comunicação com o Webservice informado no parâmetro MV_MIL0043 está incorreto. Por favor verifique junto ao administrador do sistema! //Atenção!
		ElseIf !Empty(cSvcError)
			MsgStop(cSvcError,STR0003) // Erro no retorno do Webservice da John Deere!
		Endif	
	Endif

Return

WSMETHOD SetDebug WSCLIENT WSJohnDeereJDPointNF
	WSDLDbgLevel(2)
	WSDLSaveXML(.t.)
	WSDLSetProfile(.t.)
Return

WSSTRUCT AdvanceShipNoticeWS_1_1Service_Invoice
	WSDATA   oWSinvoiceItem            AS AdvanceShipNoticeWS_1_1Service_InvoiceItem OPTIONAL
	WSDATA   cinvSequenceNumber    AS string OPTIONAL
	WSDATA   cinvoiceSeriesNumber      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AdvanceShipNoticeWS_1_1Service_Invoice
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AdvanceShipNoticeWS_1_1Service_Invoice
	::oWSinvoiceItem       := {} // Array Of  AdvanceShipNoticeWS_1_1Service_INVOICEITEM():New()
Return

WSMETHOD CLONE WSCLIENT AdvanceShipNoticeWS_1_1Service_Invoice
	Local oClone := AdvanceShipNoticeWS_1_1Service_Invoice():NEW()
	oClone:oWSinvoiceItem := NIL
	If ::oWSinvoiceItem <> NIL 
		oClone:oWSinvoiceItem := {}
		aEval( ::oWSinvoiceItem , { |x| aadd( oClone:oWSinvoiceItem , x:Clone() ) } )
	Endif 
	oClone:cinvSequenceNumber := ::cinvSequenceNumber
	oClone:cinvoiceSeriesNumber := ::cinvoiceSeriesNumber
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AdvanceShipNoticeWS_1_1Service_Invoice
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INVOICEITEM","InvoiceItem",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSinvoiceItem , AdvanceShipNoticeWS_1_1Service_InvoiceItem():New() )
			::oWSinvoiceItem[len(::oWSinvoiceItem)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
	::cinvSequenceNumber :=  WSAdvValue( oResponse,"_INVOICESEQUENCENUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cinvoiceSeriesNumber :=  WSAdvValue( oResponse,"_INVOICESERIESNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure InvoiceItem

WSSTRUCT AdvanceShipNoticeWS_1_1Service_InvoiceItem
	WSDATA   ccofinsValue              AS string OPTIONAL
	WSDATA   cicmsBase                 AS string OPTIONAL
	WSDATA   cicmsValue                AS string OPTIONAL
	WSDATA   cicmsBasisPercentage      AS string OPTIONAL
	WSDATA   cicmsRatePercentage       AS string OPTIONAL
	WSDATA   cipiValue                 AS string OPTIONAL
	WSDATA   corderID                  AS string OPTIONAL
	WSDATA   cpartNumber               AS string OPTIONAL
	WSDATA   cpisValue                 AS string OPTIONAL
	WSDATA   cquantity                 AS string OPTIONAL
	WSDATA   cunitValue                AS string OPTIONAL
	WSDATA   ccaseID                   AS string OPTIONAL
	WSDATA   charmonizeCode            AS string OPTIONAL
	WSDATA   cmoveOrderID              AS string OPTIONAL
	WSDATA   cpackListID               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AdvanceShipNoticeWS_1_1Service_InvoiceItem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AdvanceShipNoticeWS_1_1Service_InvoiceItem
Return

WSMETHOD CLONE WSCLIENT AdvanceShipNoticeWS_1_1Service_InvoiceItem
	Local oClone := AdvanceShipNoticeWS_1_1Service_InvoiceItem():NEW()
	oClone:ccofinsValue         := ::ccofinsValue
	oClone:cicmsBase            := ::cicmsBase
	oClone:cicmsValue           := ::cicmsValue
	oClone:cicmsBasisPercentage := ::cicmsBasisPercentage
	oClone:cicmsRatePercentage  := ::cicmsRatePercentage
	oClone:cipiValue            := ::cipiValue
	oClone:corderID             := ::corderID
	oClone:cpartNumber          := ::cpartNumber
	oClone:cpisValue            := ::cpisValue
	oClone:cquantity            := ::cquantity
	oClone:cunitValue           := ::cunitValue
	oClone:ccaseID              := ::ccaseID
	oClone:charmonizeCode       := ::charmonizeCode
	oClone:cmoveOrderID         := ::cmoveOrderID
	oClone:cpackListID          := ::cpackListID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AdvanceShipNoticeWS_1_1Service_InvoiceItem
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccofinsValue       :=  WSAdvValue( oResponse,"_COFINSVALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cicmsBase          :=  WSAdvValue( oResponse,"_ICMSBASE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cicmsValue         :=  WSAdvValue( oResponse,"_ICMSVALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cicmsBasisPercentage :=  WSAdvValue( oResponse,"_ICMSBASISPERCENTAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cicmsRatePercentage :=  WSAdvValue( oResponse,"_ICMSRATEPERCENTAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cipiValue          :=  WSAdvValue( oResponse,"_IPIVALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::corderID           :=  WSAdvValue( oResponse,"_ORDERID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartNumber        :=  WSAdvValue( oResponse,"_PARTNUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpisValue          :=  WSAdvValue( oResponse,"_PISVALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cquantity          :=  WSAdvValue( oResponse,"_QUANTITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cunitValue         :=  WSAdvValue( oResponse,"_UNITVALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccaseID            :=  WSAdvValue( oResponse,"_CASEID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::charmonizeCode     :=  WSAdvValue( oResponse,"_HARMONIZECODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmoveOrderID       :=  WSAdvValue( oResponse,"_MOVEORDERID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpackListID        :=  WSAdvValue( oResponse,"_PACKLISTID","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


