// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#include "OFIWJD06.CH"

/* ===============================================================================
WSDL Location    https://apps.deere.com/homologacao/ews/services/WSCreateCustomer?wsdl
Gerado em        09/05/13 13:31:59
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */
/*
Method
	INS - Insert
	UPD - Update
	VER - Search
	OLD - Old values
	NEW - Forcing Insert

Person Type = 
	1 - Pessoa Fisica
	2 - Pessoa Juridica 

Atividade = 
	1 - Produtor Agricola
	2 - Governamental
	3 - Grupo Especial
*/

User Function _NUENKTY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSJohnDeere_Customer
------------------------------------------------------------------------------- */

WSCLIENT WSJohnDeere_Customer

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	
	WSMETHOD create

	WSMETHOD ExibeErro
	WSMETHOD SetDebug

	WSDATA  _URL                        AS String
	WSDATA  _HEADOUT                    AS Array of String
	WSDATA  _COOKIES                    AS Array of String
	
	WSDATA _SOAP_ACTION AS String
	WSDATA _USER   AS String
	WSDATA _PASSWD AS String
	
	WSDATA   oJDCustomer_CreateRequest   AS JD_Customer_CreateCustomerRequest
	WSDATA   oJDCustomer_CreateReturn    AS JD_Customer_CreateCustomerResponse

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSJohnDeere_Customer
	::Init()
	If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130625] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
	If !GetMv("MV_MIL0004",.T.,) .or. Empty(GetMv("MV_MIL0004"))
		Alert(STR0001) // "Parametros de comunicacao com o Portal da John Deere nao estao configurados."
	EndIf
	If Empty(::_USER) .or. Empty(::_PASSWD)
		MsgInfo(STR0002) // "Técnico sem usuário/senha do portal da John Deere"
	EndIf
Return Self

WSMETHOD INIT WSCLIENT WSJohnDeere_Customer
	::oJDCustomer_CreateRequest   := JD_Customer_CREATECUSTOMERREQUEST():New()
	::oJDCustomer_CreateReturn    := JD_Customer_CREATECUSTOMERRESPONSE():New()

	//::_USER := "fs52934"
	//::_PASSWD := "europa88"
	//::_URL := "https://apps.deere.com/homologacao/ews/services/WSCreateCustomer"
	//	::_URL := "http://localhost:8088/extranetclientes"
	
	::_URL    := GetMV("MV_MIL0022")

	::_USER := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	::_PASSWD := AllTrim(FM_SQL("SELECT VAI_FABPWD FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))

	::_SOAP_ACTION := ::_URL
	
	::_HEADOUT := {}
	aadd( ::_HEADOUT , "Authorization: Basic "+Encode64(::_USER+":"+::_PASSWD ) )
	
Return

WSMETHOD RESET WSCLIENT WSJohnDeere_Customer
	::oJDCustomer_CreateRequest   := NIL 
	::oJDCustomer_CreateReturn    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSJohnDeere_Customer
	Local oClone := WSJohnDeere_Customer():New()
	oClone:_URL          := ::_URL 
	oClone:oJDCustomer_CreateRequest :=  IIF(::oJDCustomer_CreateRequest = NIL , NIL ,::oJDCustomer_CreateRequest:Clone() )
	oClone:oJDCustomer_CreateReturn :=  IIF(::oJDCustomer_CreateReturn = NIL , NIL ,::oJDCustomer_CreateReturn:Clone() )
Return oClone

// WSDL Method create of Service WSJruohnDeere_Customer

WSMETHOD create WSSEND oJDCustomer_CreateRequest WSRECEIVE oJDCustomer_CreateReturn WSCLIENT WSJohnDeere_Customer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

Self:oJDCustomer_CreateRequest:oCustomer_Header:cConcessionario := GetMV("MV_MIL0005")
//Self:oJDCustomer_CreateRequest:oCustomer_Header:cConcessionario := "220" 
Self:oJDCustomer_CreateRequest:oCustomer_Header:cDataEnvio := DtoS(dDataBase) 
Self:oJDCustomer_CreateRequest:oCustomer_Header:cUsuario := ::_USER 
Self:oJDCustomer_CreateRequest:CodigoValidacao()

//cSoap += '<q1:create xmlns:q1="https://apps.deere.com/homologacao/ews/">'
cSoap += '<q1:create xmlns:q1="'+GetMV("MV_MIL0022")+'">'
cSoap += WSSoapValue("request", ::oJDCustomer_CreateRequest, oJDCustomer_CreateRequest , "CreateCustomerRequest", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:create>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::_SOAP_ACTION,;
	"RPCX",;
	::_SOAP_ACTION,;
	,,; 
	::_URL)


::Init()
::oJDCustomer_CreateReturn:SoapRecv( WSAdvValue( oXmlRet,"_CREATERETURN","CreateCustomerResponse",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

WSMETHOD SetDebug WSCLIENT WSJohnDeere_Customer
	WSDLDbgLevel(2)
	WSDLSaveXML(.t.)
	WSDLSetProfile(.t.)
Return

WSMETHOD ExibeErro WSCLIENT WSJohnDeere_Customer

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	//Local cXMLError	:= GetWSCError(4)
	If !Empty(cSoapFCode)
		// Caso a ocorrência de erro esteja com o fault_code preenchido ,
		// a mesma teve relação com a chamada do serviço .
		MsgStop(cSoapFDescr,cSoapFCode)
		//Aviso("Erro",cXMLError,{"Ok"},2)
	Else
		// Caso a ocorrência não tenha o soap_code preenchido
		// Ela está relacionada a uma outra falha ,
		// provavelmente local ou interna.
		MsgStop(cSvcError,'FALHA INTERNA DE EXECUCAO DO SERVIÇO')
	Endif

Return

// WSDL Data Structure CreateCustomerRequest

WSSTRUCT JD_Customer_CreateCustomerRequest
	WSDATA   oCustomer_clienteSAP      AS JD_Customer_ArrayOf_ClienteSAP OPTIONAL
	WSDATA   oCustomer_Header          AS JD_Customer_Header OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD CodigoValidacao
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_Customer_CreateCustomerRequest
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_Customer_CreateCustomerRequest
	::oCustomer_clienteSAP := JD_Customer_ArrayOf_ClienteSAP():New()
	::oCustomer_Header := JD_Customer_Header():New()
Return

WSMETHOD CLONE WSCLIENT JD_Customer_CreateCustomerRequest
	Local oClone := JD_Customer_CreateCustomerRequest():NEW()
	oClone:oCustomer_clienteSAP        := IIF(::oCustomer_clienteSAP = NIL , NIL , ::oCustomer_clienteSAP:Clone() )
	oClone:oCustomer_Header            := IIF(::oCustomer_Header = NIL , NIL , ::oCustomer_Header:Clone() )
Return oClone

WSMETHOD CodigoValidacao WSCLIENT JD_Customer_CreateCustomerRequest

	Local cRetorno := ""
	
	// 1) é utilizada a data, pegando 2 numeros e pulando 1 a cada 2:
    // -> exemplo: data de 2013-09-11 -> 20130911 -> 20*30*11 ( xx?xx?xx => 20 1 30 9 11) = 20, 30, 11
	cRetorno := ::oCustomer_Header:cdataEnvio
	cRetorno := Val(Left(cRetorno,2)) * Val(SubString(cRetorno,4,2)) * Val(Right(cRetorno,2))
	// 2) multiplica-se o resultado anterior por 220, que é o valor da concessionária
	cRetorno := AllTrim(Str(cRetorno * Val(::oCustomer_Header:cconcessionario)))
	
	::oCustomer_Header:ccodigoValidacao := cRetorno

Return cRetorno

WSMETHOD SOAPSEND WSCLIENT JD_Customer_CreateCustomerRequest
	Local cSoap := ""
	cSoap += WSSoapValue("clienteSAP", ::oCustomer_clienteSAP, ::oCustomer_clienteSAP , "ArrayOf_tns1_ClienteSAP", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("header", ::oCustomer_Header, ::oCustomer_Header , "Header", .F. , .T., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ArrayOf_tns1_ClienteSAP

WSSTRUCT JD_Customer_ArrayOf_ClienteSAP
	WSDATA   oClienteSAP AS JD_Customer_ClienteSAP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
	WSMETHOD ADDCLIENTESAP
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_Customer_ArrayOf_ClienteSAP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_Customer_ArrayOf_ClienteSAP
	::oClienteSAP        := {} // Array Of  JD_Customer_CLIENTESAP():New()
Return

WSMETHOD ADDCLIENTESAP WSCLIENT JD_Customer_ArrayOf_ClienteSAP
	AADD( ::oClienteSAP , JD_Customer_ClienteSAP():New() )
Return Len(::oClienteSAP)

WSMETHOD CLONE WSCLIENT JD_Customer_ArrayOf_ClienteSAP
	Local oClone := JD_Customer_ArrayOf_ClienteSAP():NEW()
	oClone:oClienteSAP := NIL
	If ::oClienteSAP <> NIL 
		oClone:oClienteSAP := {}
		aEval( ::oClienteSAP , { |x| aadd( oClone:oClienteSAP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT JD_Customer_ArrayOf_ClienteSAP
	Local cSoap := ""
	aEval( ::oClienteSAP , {|x| cSoap := cSoap  +  WSSoapValue("ClienteSAP", x , x , "ClienteSAP", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_Customer_ArrayOf_ClienteSAP
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oClienteSAP , JD_Customer_ClienteSAP():New() )
  			::oClienteSAP[len(::oClienteSAP)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Header

WSSTRUCT JD_Customer_Header
	WSDATA   ccodigoValidacao          AS string OPTIONAL
	WSDATA   cconcessionario           AS string OPTIONAL
	WSDATA   cdataEnvio                AS string OPTIONAL
	WSDATA   cmensagemErro             AS string OPTIONAL
	WSDATA   nnivelErro                AS int OPTIONAL
	WSDATA   csistema                  AS string OPTIONAL
	WSDATA   cusuario                  AS string OPTIONAL
	WSDATA   cversao                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_Customer_Header
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_Customer_Header
Return

WSMETHOD CLONE WSCLIENT JD_Customer_Header
	Local oClone := JD_Customer_Header():NEW()
	oClone:ccodigoValidacao     := ::ccodigoValidacao
	oClone:cconcessionario      := ::cconcessionario
	oClone:cdataEnvio           := ::cdataEnvio
	oClone:cmensagemErro        := ::cmensagemErro
	oClone:nnivelErro           := ::nnivelErro
	oClone:csistema             := ::csistema
	oClone:cusuario             := ::cusuario
	oClone:cversao              := ::cversao
Return oClone

WSMETHOD SOAPSEND WSCLIENT JD_Customer_Header
	Local cSoap := ""
	cSoap += WSSoapValue("codigoValidacao", ::ccodigoValidacao, ::ccodigoValidacao , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("concessionario", ::cconcessionario, ::cconcessionario , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("dataEnvio", ::cdataEnvio, ::cdataEnvio , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("mensagemErro", ::cmensagemErro, ::cmensagemErro , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("nivelErro", ::nnivelErro, ::nnivelErro , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("sistema", ::csistema, ::csistema , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("usuario", ::cusuario, ::cusuario , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("versao", ::cversao, ::cversao , "string", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_Customer_Header
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccodigoValidacao   :=  WSAdvValue( oResponse,"_CODIGOVALIDACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cconcessionario    :=  WSAdvValue( oResponse,"_CONCESSIONARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdataEnvio         :=  WSAdvValue( oResponse,"_DATAENVIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmensagemErro      :=  WSAdvValue( oResponse,"_MENSAGEMERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nnivelErro         :=  WSAdvValue( oResponse,"_NIVELERRO","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::csistema           :=  WSAdvValue( oResponse,"_SISTEMA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cusuario           :=  WSAdvValue( oResponse,"_USUARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cversao            :=  WSAdvValue( oResponse,"_VERSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure CreateCustomerResponse

WSSTRUCT JD_Customer_CreateCustomerResponse
	WSDATA   oCustomer_clienteSAP             AS JD_Customer_ArrayOf_ClienteSAP OPTIONAL
	WSDATA   oCustomer_Header                 AS JD_Customer_Header OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_Customer_CreateCustomerResponse
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_Customer_CreateCustomerResponse
Return

WSMETHOD CLONE WSCLIENT JD_Customer_CreateCustomerResponse
	Local oClone := JD_Customer_CreateCustomerResponse():NEW()
	oClone:oCustomer_clienteSAP        := IIF(::oCustomer_clienteSAP = NIL , NIL , ::oCustomer_clienteSAP:Clone() )
	oClone:oCustomer_Header            := IIF(::oCustomer_Header = NIL , NIL , ::oCustomer_Header:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_Customer_CreateCustomerResponse
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CLIENTESAP","ArrayOf_tns1_ClienteSAP",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oCustomer_clienteSAP := JD_Customer_ArrayOf_ClienteSAP():New()
		::oCustomer_clienteSAP:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_HEADER","Header",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oCustomer_Header := JD_Customer_Header():New()
		::oCustomer_Header:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure ClienteSAP

WSSTRUCT JD_Customer_ClienteSAP
	WSDATA   cIBGECityCode             AS string OPTIONAL
	WSDATA   cPOBox                    AS string OPTIONAL
	WSDATA   cSAPCustomerCode          AS string OPTIONAL
	WSDATA   cactivityType             AS string OPTIONAL
	WSDATA   caddressCode              AS string OPTIONAL
	WSDATA   ccity                     AS string OPTIONAL
	WSDATA   ccnpj                     AS string OPTIONAL
	WSDATA   ccomplement               AS string OPTIONAL
	WSDATA   ccountry                  AS string OPTIONAL
	WSDATA   ccpf                      AS string OPTIONAL
	WSDATA   cdistrict                 AS string OPTIONAL
	WSDATA   cemail                    AS string OPTIONAL
	WSDATA   cie                       AS string OPTIONAL
	WSDATA   cmethod                   AS string OPTIONAL
	WSDATA   cname                     AS string OPTIONAL
	WSDATA   cnumber                   AS string OPTIONAL
	WSDATA   cpartnerFunction          AS string OPTIONAL
	WSDATA   cpersonType               AS string OPTIONAL
	WSDATA   cpostalCode               AS string OPTIONAL
	WSDATA   cregion                   AS string OPTIONAL
	WSDATA   cstatusMessage            AS string OPTIONAL
	WSDATA   cstreet                   AS string OPTIONAL
	WSDATA   ctelephone                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_Customer_ClienteSAP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_Customer_ClienteSAP
Return

WSMETHOD CLONE WSCLIENT JD_Customer_ClienteSAP

	Local oClone := JD_Customer_ClienteSAP():NEW()
	
	oClone:cIBGECityCode        := ::cIBGECityCode
	oClone:cPOBox               := ::cPOBox
	oClone:cSAPCustomerCode     := ::cSAPCustomerCode
	oClone:cactivityType        := ::cactivityType
	oClone:caddressCode         := ::caddressCode
	oClone:ccity                := ::ccity
	oClone:ccnpj                := ::ccnpj
	oClone:ccomplement          := ::ccomplement
	oClone:ccountry             := ::ccountry
	oClone:ccpf                 := ::ccpf
	oClone:cdistrict            := ::cdistrict
	oClone:cemail               := ::cemail
	oClone:cie                  := ::cie
	oClone:cmethod              := ::cmethod
	oClone:cname                := ::cname
	oClone:cnumber              := ::cnumber
	oClone:cpartnerFunction     := ::cpartnerFunction
	oClone:cpersonType          := ::cpersonType
	oClone:cpostalCode          := ::cpostalCode
	oClone:cregion              := ::cregion
	oClone:cstatusMessage       := ::cstatusMessage
	oClone:cstreet              := ::cstreet
	oClone:ctelephone           := ::ctelephone
Return oClone

WSMETHOD SOAPSEND WSCLIENT JD_Customer_ClienteSAP
	Local cSoap := ""
	cSoap += WSSoapValue("IBGECityCode", ::cIBGECityCode, ::cIBGECityCode , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("POBox", ::cPOBox, ::cPOBox , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SAPCustomerCode", ::cSAPCustomerCode, ::cSAPCustomerCode , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("activityType", ::cactivityType, ::cactivityType , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("addressCode", ::caddressCode, ::caddressCode , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("city", ::ccity, ::ccity , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("cnpj", ::ccnpj, ::ccnpj , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("complement", ::ccomplement, ::ccomplement , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("country", ::ccountry, ::ccountry , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("cpf", ::ccpf, ::ccpf , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("district", ::cdistrict, ::cdistrict , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ie", ::cie, ::cie , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("method", ::cmethod, ::cmethod , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("name", ::cname, ::cname , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("number", ::cnumber, ::cnumber , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("partnerFunction", ::cpartnerFunction, ::cpartnerFunction , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("personType", ::cpersonType, ::cpersonType , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("postalCode", ::cpostalCode, ::cpostalCode , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("region", ::cregion, ::cregion , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("statusMessage", ::cstatusMessage, ::cstatusMessage , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("street", ::cstreet, ::cstreet , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("telephone", ::ctelephone, ::ctelephone , "string", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_Customer_ClienteSAP
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIBGECityCode      :=  WSAdvValue( oResponse,"_IBGECITYCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPOBox             :=  WSAdvValue( oResponse,"_POBOX","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSAPCustomerCode   :=  WSAdvValue( oResponse,"_SAPCUSTOMERCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cactivityType      :=  WSAdvValue( oResponse,"_ACTIVITYTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::caddressCode       :=  WSAdvValue( oResponse,"_ADDRESSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccity              :=  WSAdvValue( oResponse,"_CITY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccnpj              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccomplement        :=  WSAdvValue( oResponse,"_COMPLEMENT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccountry           :=  WSAdvValue( oResponse,"_COUNTRY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ccpf               :=  WSAdvValue( oResponse,"_CPF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdistrict          :=  WSAdvValue( oResponse,"_DISTRICT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cemail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cie                :=  WSAdvValue( oResponse,"_IE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cmethod            :=  WSAdvValue( oResponse,"_METHOD","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnumber            :=  WSAdvValue( oResponse,"_NUMBER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpartnerFunction   :=  WSAdvValue( oResponse,"_PARTNERFUNCTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpersonType        :=  WSAdvValue( oResponse,"_PERSONTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cpostalCode        :=  WSAdvValue( oResponse,"_POSTALCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cregion            :=  WSAdvValue( oResponse,"_REGION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cstatusMessage     :=  WSAdvValue( oResponse,"_STATUSMESSAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cstreet            :=  WSAdvValue( oResponse,"_STREET","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::ctelephone         :=  WSAdvValue( oResponse,"_TELEPHONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


