// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 08     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#include "OFIWJD01.CH"

/* ===============================================================================
WSDL Location    http://localhost:8088/mockPIAbstractProxyServiceBinding?WSDL
Gerado em        04/23/13 11:13:37
Observacoes      Codigo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function OFIWJD01()
Return

/* -------------------------------------------------------------------------------
WSDL Service WSJohnDeere_Garantia
------------------------------------------------------------------------------- */

WSCLIENT WSJohnDeere_Garantia

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET

	WSMETHOD RetrieveWarrantyInfo
	WSMETHOD SubmitDeliveryReceipt
	WSMETHOD RetrieveOpenPIPsMCD
	WSMETHOD SaveClaim
	WSMETHOD RetrieveClaim
	WSMETHOD UpdateDealerInvoice
	WSMETHOD RetrieveCreditMemo

	WSMETHOD ProcWarrMemo

	WSMETHOD ExibeErro
	WSMETHOD SetDebug
	WSMETHOD PesqVX5

	WSMETHOD ConfigHeader

	WSDATA _URL     AS String
	WSDATA _DIRETORIO AS String
	WSDATA _HEADOUT AS Array of String
	WSDATA _COOKIES AS Array of String

	// Especifico da Marca John Deere
	WSDATA _LANGUAGE_CODE AS String
	WSDATA _DEALER_ACCOUNT AS String
	WSDATA _MSG_VERSION AS String
	WSDATA _TNS_IJD AS String
	WSDATA _SOAP_ACTION AS String
	WSDATA _TARGET_NAMESPACE AS String
	WSDATA _APP_ID AS String
	WSDATA _DBS_ID AS String

	WSDATA _USER   AS String
	WSDATA _PASSWD AS String

	WSDATA _OKTA
	WSDATA _oOKTA

	WSDATA oOUTPUT

	WSDATA oRetrieveWarInfo_INPUT		AS JD_RetrieveWarrantyInfo_INPUT
	WSDATA oSubmitDeliveryReceipt_INPUT	AS JD_SubmitDeliveryReceipt_INPUT
	WSDATA oRetrieveOpenPIPsMCD_INPUT	AS JD_RetrieveOpenPIPsMCD_INPUT
	WSDATA oSaveClaim_INPUT				AS JD_SaveClaim_REQUEST
	WSDATA oRetrieveClaim_INPUT			AS JD_RetrieveClaim_REQUEST
	WSDATA oUpdateDealerInvoice_INPUT	AS JD_UpdateDealerInvoice_INPUT
	WSDATA oRetrieveCreditMemo_INPUT    AS JD_RetrieveCreditMemo_INPUT

	WSDATA cXMLSaveClaim AS String

ENDWSCLIENT

WSMETHOD NEW WSSEND cMensagem WSCLIENT WSJohnDeere_Garantia
	::Init(cMensagem)
	If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf
	If !GetMv("MV_MIL0004",.T.,) .or. Empty(GetMv("MV_MIL0004"))
		Alert(STR0001) // "Parametros de comunicacao com o Portal da John Deere nao estao configurados."
	EndIf
	If Empty(::_USER) .or. Empty(::_PASSWD)
		MsgInfo(STR0002) // "Técnico sem usuário/senha do portal da John Deere"
	EndIf

	::cXMLSaveClaim := ""
	
Return Self

WSMETHOD INIT WSSEND cMensagem WSCLIENT WSJohnDeere_Garantia

	::_URL    := GetMV("MV_MIL0004")

	::_USER := AllTrim(FM_SQL("SELECT VAI_FABUSR FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))
	::_PASSWD := AllTrim(FM_SQL("SELECT VAI_FABPWD FROM " + RetSQLname("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '"))

	::_SOAP_ACTION := "http://sap.com/xi/WebService/soap1.1"
	::_TARGET_NAMESPACE := "http://v1_0.webservice.piabstractproxy.u90785.deere.com"

	::_LANGUAGE_CODE := "PT"
	::_DEALER_ACCOUNT := GetMV("MV_MIL0005")
	::_MSG_VERSION := "1.0"
	::_APP_ID := "TOTVS"
	::_DBS_ID := "TOTVS"

	::_HEADOUT := {""}

	::_oOkta := OFJDOkta():New()
	::_OKTA := ::_oOkta:oConfig:warranty()
	if ::_OKTA
		::_oOkta:SetUserPasswd(::_USER, ::_PASSWD)
		::_oOkta:SetWarranty()
		::_URL := ::_oOKTA:oConfig:getUrlWSWarranty()
	endif


	If cMensagem <> NIL
		Do Case
		Case cMensagem == "RetrieveWarrantyInfo"
			::oRetrieveWarInfo_INPUT := JD_RetrieveWarrantyInfo_INPUT():New()
		Case cMensagem == "RetrieveOpenPIPsMCD"
			::oRetrieveOpenPIPsMCD_INPUT := JD_RetrieveOpenPIPsMCD_INPUT():New()
		Case cMensagem == "SubmitDeliveryReceipt"
			::oSubmitDeliveryReceipt_INPUT := JD_SubmitDeliveryReceipt_INPUT():New()
			::oSubmitDeliveryReceipt_INPUT:oCUSTOMER  := JD_SubmitDeliveryReceipt_CUSTOMER():New()
			::oSubmitDeliveryReceipt_INPUT:oEQUIPMENT := JD_SubmitDeliveryReceipt_EQUIPMENT():New()
		Case cMensagem == "SaveClaim"
			::oSaveClaim_INPUT := JD_SaveClaim_REQUEST():New()
		Case cMensagem == "RetrieveClaim"
			::oRetrieveClaim_INPUT := JD_RetrieveClaim_INPUT():New()
		Case cMensagem == "UpdateDealerInvoice"
			::oUpdateDealerInvoice_INPUT := JD_UpdateDealerInvoice_INPUT():New()
		Case cMensagem == "RetrieveCreditMemo"
			::oRetrieveCreditMemo_INPUT := JD_RetrieveCreditMemo_INPUT():New()
		EndCase
	EndIf

Return

WSMETHOD RESET WSSEND cMensagem WSCLIENT WSJohnDeere_Garantia

	::oOUTPUT := NIL

	::oRetrieveWarInfo_INPUT := NIL
	::oSubmitDeliveryReceipt_INPUT := NIL
	::oRetrieveOpenPIPsMCD_INPUT := NIL
	::oSaveClaim_INPUT := NIL
	::oRetrieveClaim_INPUT := NIL
	::oUpdateDealerInvoice_INPUT := NIL
	::oRetrieveCreditMemo_INPUT := NIL

	::Init(cMensagem)
Return

WSMETHOD ConfigHeader WSCLIENT WSJohnDeere_Garantia
	Local cToken := ""
	if ::_OKTA
		cToken := ::_oOkta:getToken()
		If Empty(cToken)
			MsgStop(STR0003,STR0004) // "Falha na obtenção do Token de Acesso." // "Erro"
			Return .f.
		EndIf
		::_HEADOUT[1] := "Authorization: Bearer " + cToken
	else
		::_HEADOUT[1] := "Authorization: Basic "+Encode64(::_USER+":"+::_PASSWD)
	endif
Return .t.

WSMETHOD SetDebug WSSEND lSetDebug WSCLIENT WSJohnDeere_Garantia

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

WSMETHOD PesqVX5 WSSEND cTabela , cCodigo WSCLIENT WSJohnDeere_Garantia

	Local cRetorno

	cRetorno := FM_SQL("SELECT VX5_DESCRI FROM " + RetSQLName("VX5") + " WHERE VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5_CHAVE = '" + cTabela + "' AND VX5_CODIGO = '" + cCodigo + "' AND D_E_L_E_T_ = ' '")

Return cRetorno

WSMETHOD ExibeErro WSSEND cMensagem WSCLIENT WSJohnDeere_Garantia

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	//Local cXMLError	:= GetWSCError(4)
	
	Default cMensagem := ""
	
	If !Empty(cSoapFCode)
		// Caso a ocorrência de erro esteja com o fault_code preenchido ,
		// a mesma teve relação com a chamada do serviço .
		MsgStop(cMensagem + chr(13) + chr(10) + cSoapFDescr,cSoapFCode)
		//Aviso("Erro",cXMLError,{"Ok"},2)
	ElseIf ! Empty(cSvcError) .or. ! Empty(cMensagem)
		// Caso a ocorrência não tenha o soap_code preenchido
		// Ela está relacionada a uma outra falha ,
		// provavelmente local ou interna.
		MsgStop(cMensagem + chr(13) + chr(10) + cSvcError,'FALHA INTERNA DE EXECUCAO DO SERVIÇO')
	Endif

Return


/*
===============================================================================
###############################################################################
##+----------+----------------------+-------+-------------+------+----------+##
##|Metodo    | RetrieveWarrantyInfo | Autor |  Takahashi  | Data | 23/04/13 |##
##+----------+----------------------+-------+-------------+------+----------+##
##|Descricao | Retorna informacoes de garantia  de um determinado PIN       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
WSMETHOD RetrieveWarrantyInfo WSSEND oRetrieveWarInfo_INPUT WSCLIENT WSJohnDeere_Garantia
	Local cSoap := "" , oXmlRet

	If ! ::ConfigHeader()
		Return .f.
	EndIf

	::oRetrieveWarInfo_INPUT:cMSGVERSION    := ::_MSG_VERSION
	::oRetrieveWarInfo_INPUT:cLANGCODE      := ::_LANGUAGE_CODE
	::oRetrieveWarInfo_INPUT:cDEALERACCOUNT := ::_DEALER_ACCOUNT

	BEGIN WSMETHOD

	cSoap += '<ijd:MTRetrieveWarrantyInfo_Request xmlns:ijd="http://deere.com/xi/ijdwinxml">'
	cSoap += WSSoapValue("INPUT", ::oRetrieveWarInfo_INPUT, oRetrieveWarInfo_INPUT , "INPUT", .F. , .F., 0 , NIL, .F.)
	cSoap += '</ijd:MTRetrieveWarrantyInfo_Request>'

	oXmlRet := SvcSoapCall(;
		Self,;
		cSoap,;
		::_SOAP_ACTION,;
		"DOCUMENT",;
		::_SOAP_ACTION,;
		,;
		,;
		::_URL)

	oAuxRetorno := XmlGetChild( oXmlRet, 3 )
	if type("oAuxRetorno") == "U"
		oAuxRetorno := XmlGetChild( oXmlRet, 1 )
	endif
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RESULTS")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RETURN")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_OUTPUT")

	::oOUTPUT := JD_RetrieveWarrantyInfo_OUTPUT():New()
	::oOUTPUT:SoapRecv( oAuxRetorno )

	END WSMETHOD

	oXmlRet := NIL

Return .T.

/*
===============================================================================
###############################################################################
##+----------+-----------------------+-------+------------+------+----------+##
##|Metodo    | SubmitDeliveryReceipt | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-----------------------+-------+------------+------+----------+##
##|Descricao | Registra um PIN para um determinado cliente                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
WSMETHOD SubmitDeliveryReceipt WSSEND oSubmitDeliveryReceipt_INPUT WSRECEIVE oSubmit_Delivery_Receipt_OUTPUT WSCLIENT WSJohnDeere_Garantia
	Local cSoap := "" , oXmlRet

	If ! ::ConfigHeader()
		Return .f.
	EndIf

	::oSubmitDeliveryReceipt_INPUT:cMSGVERSION		:= ::_MSG_VERSION
	::oSubmitDeliveryReceipt_INPUT:cLANGCODE		:= ::_LANGUAGE_CODE
	::oSubmitDeliveryReceipt_INPUT:cDEALERACCOUNT	:= ::_DEALER_ACCOUNT
	::oSubmitDeliveryReceipt_INPUT:cAPP_ID			:= ::_APP_ID

	::oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cDEALERACCOUNT := ::_DEALER_ACCOUNT

	BEGIN WSMETHOD

	cSoap += '<ijd:MTSubmitDeliveryReceipt_Request xmlns:ijd="http://deere.com/xi/ijdwinxml">'
	cSoap += WSSoapValue("INPUT", ::oSubmitDeliveryReceipt_INPUT, oSubmitDeliveryReceipt_INPUT , "INPUT", .F. , .F., 0 , NIL, .F.)
	cSoap += "</ijd:MTSubmitDeliveryReceipt_Request>"


	oXmlRet := SvcSoapCall(;
		Self,;
		cSoap,;
		::_SOAP_ACTION,;
		"DOCUMENT",;
		::_SOAP_ACTION,;
		,;
		,;
		::_URL)

	oAuxRetorno := XmlChildEx(oXmlRet,"_NS1_MTSUBMITDELIVERYRECEIPT_RESPONSE")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RESULTS")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RETURN")
	::oOUTPUT := JD_SubmitDeliveryReceipt_OUTPUT():New()
	::oOUTPUT:SoapRecv(oAuxRetorno)

	END WSMETHOD

	oXmlRet := NIL
Return .T.

/*
===============================================================================
###############################################################################
##+----------+-----------------------+-------+------------+------+----------+##
##|Metodo    | RetrieveOpenPIPsMCD   | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-----------------------+-------+------------+------+----------+##
##|Descricao | Retorna revisões/campanha de um determinado PIN              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
WSMETHOD RetrieveOpenPIPsMCD WSSEND oRetrieveOpenPIPsMCD_INPUT WSRECEIVE oOUTPUT WSCLIENT WSJohnDeere_Garantia

	Local cSoap := "" , oXmlRet
	Local oAuxRetorno

	If ! ::ConfigHeader()
		Return .f.
	EndIf

	::oRetrieveOpenPIPsMCD_INPUT:cMSGVERSION	:= ::_MSG_VERSION
	::oRetrieveOpenPIPsMCD_INPUT:cLANGCODE		:= ::_LANGUAGE_CODE
	::oRetrieveOpenPIPsMCD_INPUT:cDEALERACCOUNT	:= ::_DEALER_ACCOUNT

	BEGIN WSMETHOD

	cSoap += '<ijd:MTRetrieveOpenPIPsMaintenanceContractDetails_Request xmlns:ijd="http://deere.com/xi/ijdwinxml">'
	cSoap += WSSoapValue("INPUT", ::oRetrieveOpenPIPsMCD_INPUT, oRetrieveOpenPIPsMCD_INPUT , "INPUT", .F. , .F., 0 , NIL, .F.)
	cSoap += "</ijd:MTRetrieveOpenPIPsMaintenanceContractDetails_Request>"

	oXmlRet := SvcSoapCall(;
		Self,;
		cSoap,;
		::_SOAP_ACTION,;
		"DOCUMENT",;
		::_SOAP_ACTION,;
		,;
		,;
		::_URL)


	oAuxRetorno := XmlGetChild( oXmlRet, 1 )
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RESULTS")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RETURN")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_OUTPUT")

	::oOUTPUT := JD_RetrieveOpenPIPsMCD_OUTPUT():New()
	::oOUTPUT:SoapRecv(oAuxRetorno)

	END WSMETHOD

	oXmlRet := NIL
	oAuxRetorno := NIL

Return .T.

/*
===============================================================================
###############################################################################
##+----------+-----------------------+-------+------------+------+----------+##
##|Metodo    | SaveClaim             | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-----------------------+-------+------------+------+----------+##
##|Descricao | Envio de Garantia                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
WSMETHOD SaveClaim WSSEND oSaveClaim_INPUT WSRECEIVE oOUTPUT WSCLIENT WSJohnDeere_Garantia

	Local cSoap := "" , oXmlRet
	Local oAuxRetorno

	If ! ::ConfigHeader()
		Return .f.
	EndIf

	::oSaveClaim_INPUT:oINPUT:cMSGVERSION    := ::_MSG_VERSION
	::oSaveClaim_INPUT:oINPUT:cLANGCODE      := ::_LANGUAGE_CODE
	::oSaveClaim_INPUT:oINPUT:cDBS_ID        := ::_DBS_ID

	BEGIN WSMETHOD

	cSoap += '<ijd:MTSaveClaim_Request xmlns:ijd="http://deere.com/xi/ijdwinxml">'
//	cSoap += WSSoapValue("DTSaveClaim_Input", ::oSaveClaim_INPUT, oSaveClaim_INPUT , "DTSaveClaim_Input", .F. , .F., 0 , NIL, .F.)

	cSoap += WSSoapValue("INPUT", ::oSaveClaim_INPUT:oINPUT, ::oSaveClaim_INPUT:oINPUT , "INPUT", .F. , .F., 0 , NIL, .F.)

	aEval( ::oSaveClaim_INPUT:oREPLACEPART , {|x| cSoap := cSoap  +  WSSoapValue("REPLACEPART", x , x , "REPLACEPART", .F. , .F., 0 , NIL, .F.)  } )
	aEval( ::oSaveClaim_INPUT:oLABOR 	  , {|x| cSoap := cSoap  +  WSSoapValue("LABOR", x , x , "LABOR", .F. , .F., 0 , NIL, .F.)  } )
	aEval( ::oSaveClaim_INPUT:oOTHERCREDIT , {|x| cSoap := cSoap  +  WSSoapValue("OTHERCREDIT", x , x , "OTHERCREDIT", .F. , .F., 0 , NIL, .F.)  } )
	aEval( ::oSaveClaim_INPUT:oPINS 		  , {|x| cSoap := cSoap  +  WSSoapValue("PINS", x , x , "PINS", .F. , .F., 0 , NIL, .F.)  } )

	cSoap += "</ijd:MTSaveClaim_Request>"

	oXmlRet := SvcSoapCall(;
		Self,;
		cSoap,;
		::_SOAP_ACTION,;
		"DOCUMENT",;
		::_SOAP_ACTION,;
		,;
		,;
		::_URL)

	::cXMLSaveClaim := cSoap

	oAuxRetorno := XmlGetChild( oXmlRet, 1 )
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RESULTS")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RETURN")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_OUTPUT")

	::oOUTPUT := JD_SaveClaim_OUTPUT():New()
	::oOUTPUT:SoapRecv(oAuxRetorno)

	END WSMETHOD

	oXmlRet := NIL
	oAuxRetorno := NIL

Return .T.




/*
===============================================================================
###############################################################################
##+----------+----------------------+-------+-------------+------+----------+##
##|Metodo    | RetrieveClaim        | Autor |  Takahashi  | Data | 23/04/13 |##
##+----------+----------------------+-------+-------------+------+----------+##
##|Descricao | Retorna informacoes de uma solicitacao de garantia           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
WSMETHOD RetrieveClaim WSSEND oRetrieveClaim_INPUT WSRECEIVE oOUTPUT WSCLIENT WSJohnDeere_Garantia

	Local cSoap := "" , oXmlRet
	Local oAuxRetorno

	If ! ::ConfigHeader()
		Return .f.
	EndIf


	::oRetrieveClaim_INPUT:cMSGVERSION    := ::_MSG_VERSION
	::oRetrieveClaim_INPUT:cLANGCODE      := ::_LANGUAGE_CODE

	BEGIN WSMETHOD

	cSoap += '<ijd:MTRetrieveClaim_Request xmlns:ijd="http://deere.com/xi/ijdwinxml">'
	cSoap += WSSoapValue("INPUT", ::oRetrieveClaim_INPUT, oRetrieveClaim_INPUT , "INPUT", .F. , .F., 0 , NIL, .F.)
	cSoap += "</ijd:MTRetrieveClaim_Request>"

	oXmlRet := SvcSoapCall(;
		Self,;
		cSoap,;
		::_SOAP_ACTION,;
		"DOCUMENT",;
		::_SOAP_ACTION,;
		,;
		,;
		::_URL)

	oAuxRetorno := XmlGetChild( oXmlRet, 1 )
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RESULTS")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RETURN")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_OUTPUT")

	::oOUTPUT := JD_RetrieveClaim_OUTPUT():New()
	::oOUTPUT:SoapRecv( oAuxRetorno )

	END WSMETHOD

	oXmlRet := NIL
Return .T.

/*
===============================================================================
###############################################################################
##+----------+----------------------+-------+-------------+------+----------+##
##|Metodo    | UpdateDealerInvoice  | Autor |  Takahashi  | Data | 23/04/13 |##
##+----------+----------------------+-------+-------------+------+----------+##
##|Descricao | Atualiza Numero de NF de Servico na base da JD               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
WSMETHOD UpdateDealerInvoice WSSEND oUpdateDealerInvoice_INPUT WSRECEIVE oSUCCESS WSCLIENT WSJohnDeere_Garantia
	Local cSoap := "" , oXmlRet

	Local oAuxRetorno

	If ! ::ConfigHeader()
		Return .f.
	EndIf


	::oUpdateDealerInvoice_INPUT:cMSGVERSION    := ::_MSG_VERSION
	::oUpdateDealerInvoice_INPUT:cLANGCODE      := ::_LANGUAGE_CODE

	BEGIN WSMETHOD

	cSoap += '<war:UpdateDealerInvoice_Request xmlns:war="http://deere.com/xi/ijdnaag/warranty">'
	cSoap += WSSoapValue("Input", ::oUpdateDealerInvoice_INPUT, oUpdateDealerInvoice_INPUT , "INPUT", .F. , .F., 0 , NIL, .F.)
	cSoap += "</war:UpdateDealerInvoice_Request>"

	oXmlRet := SvcSoapCall(;
		Self,;
		cSoap,;
		::_SOAP_ACTION,;
		"DOCUMENT",;
		::_SOAP_ACTION,;
		,;
		,;
		::_URL)

	oAuxRetorno := XmlChildEx(oXmlRet,"_NS0_UPDATEDEALERINVOICE_RESPONSE")
	If ValType(oAuxRetorno) == "U"
		oAuxRetorno := XmlGetChild( oXmlRet, 1 )
	EndIf
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RESULTS")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RETURN")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_OUTPUT")

	::oOUTPUT := JD_UpdateDealerInvoice_OUTPUT():New()
	::oOUTPUT:SoapRecv( oAuxRetorno )

	END WSMETHOD

	oXmlRet := NIL
Return .T.


/*
===============================================================================
###############################################################################
##+----------+----------------------+-------+-------------+------+----------+##
##|Metodo    | RetrieveCreditMemo   | Autor |  Takahashi  | Data | 23/04/13 |##
##+----------+----------------------+-------+-------------+------+----------+##
##|Descricao | Retorna informacoes de memo credito de uma garantia          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
WSMETHOD RetrieveCreditMemo WSSEND oRetrieveCreditMemo_INPUT WSRECEIVE oOUTPUT WSCLIENT WSJohnDeere_Garantia
	Local cSoap := "" , oXmlRet

	Local oAuxRetorno

	If ! ::ConfigHeader()
		Return .f.
	EndIf


	::oRetrieveCreditMemo_INPUT:cMSGVERSION    := ::_MSG_VERSION
	::oRetrieveCreditMemo_INPUT:cLANGCODE      := ::_LANGUAGE_CODE

	BEGIN WSMETHOD

	cSoap += '<ijd:MTRetrieveCreditMemo_Request xmlns:ijd="http://deere.com/xi/ijdwinxml">'
	cSoap += WSSoapValue("INPUT", ::oRetrieveCreditMemo_INPUT, oRetrieveCreditMemo_INPUT , "INPUT", .F. , .F., 0 , NIL, .F.)
	cSoap += "</ijd:MTRetrieveCreditMemo_Request>"

	oXmlRet := SvcSoapCall(;
		Self,;
		cSoap,;
		::_SOAP_ACTION,;
		"DOCUMENT",;
		::_SOAP_ACTION,;
		,;
		,;
		::_URL)

	oAuxRetorno := XmlGetChild( oXmlRet, 1 )
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RESULTS")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_RETURN")
	oAuxRetorno := XmlChildEx(oAuxRetorno,"_OUTPUT")

	::oOUTPUT := JD_RetrieveCreditMemo_OUTPUT():New()
	::oOUTPUT:SoapRecv( oAuxRetorno )

	END WSMETHOD

	oXmlRet := NIL
Return .T.









WSMETHOD ProcWarrMemo WSSEND cFileWarrMemo WSRECEIVE oOUTPUT WSCLIENT WSJohnDeere_Garantia

	//Local cFileWarrMemo := "\jd\warrmemo\warrmemo2.xml"
	Local cError := ""
	Local cWarning := ""
	Local oXmlRet
	Local oAuxRetorno

//	BEGIN WSMETHOD

	//oXmlRet := XmlParserFile ( "\jd\warrmemo.xml" , "_" , @cError , @cWarning )
	oXmlRet := XmlParserFile ( cFileWarrMemo , "_" , @cError , @cWarning )

	If !Empty(cError)
		Alert(cError + CRLF + CRLF + cFileWarrMemo)
		Return .f.
	EndIf

	If !Empty(cWarning)
		Alert(cWarning + CRLF + CRLF + cFileWarrMemo)
		Return .f.
	EndIf


	oAuxRetorno := XmlChildEx(oXmlRet,"_NS0_CLAIM")

	::oOUTPUT := JD_WarrMemo_CLAIM():New()
	::oOUTPUT:SoapRecv( oAuxRetorno )

	//END WSMETHOD

	oXmlRet := NIL

Return .T.
















/*
===============================================================================
###############################################################################
##+----------+-----------------------+-------+------------+------+----------+##
##|Estrutura | JD_SUCCESS            | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-----------------------+-------+------------+------+----------+##
##|Direcao   | Retorno                                                      |##
##+----------+--------------------------------------------------------------+##
##|Descricao | Estrutura de retorno utilizado em varios metodos             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
WSSTRUCT JD_SUCCESS
	WSDATA   cTYPE       AS string OPTIONAL
	WSDATA   cTYPE_DESC  AS string OPTIONAL
	WSDATA   cID         AS string OPTIONAL
	WSDATA   nRESCODE    AS integer OPTIONAL
	WSDATA   cRESDESC    AS string OPTIONAL
	WSDATA   cLOG_NO     AS string OPTIONAL
	WSDATA   cLOG_MSG_NO AS string OPTIONAL
	WSDATA   cMESSAGE_V1 AS string OPTIONAL
	WSDATA   cMESSAGE_V2 AS string OPTIONAL
	WSDATA   cMESSAGE_V3 AS string OPTIONAL
	WSDATA   cMESSAGE_V4 AS string OPTIONAL
	WSDATA   cPARAMETER  AS string OPTIONAL
	WSDATA   nROW        AS integer OPTIONAL
	WSDATA   cFIELD      AS string OPTIONAL
	WSDATA   cSYSTEM     AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV

ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SUCCESS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SUCCESS
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_SUCCESS
	::Init()

	If oResponse = NIL ; Return ; Endif

	::cTYPE       :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)

	Do Case
	Case ::cTYPE == "S"
		::cTYPE_DESC := "Sucesso"
	Case ::cTYPE == "I"
		::cTYPE_DESC := "Informativo"
	Case ::cTYPE == "W"
		::cTYPE_DESC := "Advertencia"
	Case ::cTYPE == "E"
		::cTYPE_DESC := "Erro - Deere"
	Case ::cTYPE == "X"
		::cTYPE_DESC := "Erro - Dealer"
	EndCase

	::cID         :=  WSAdvValue( oResponse,"_ID","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nRESCODE    :=  WSAdvValue( oResponse,"_RESCODE","integer",NIL,NIL,NIL,"N",NIL,NIL)
	::cRESDESC    :=  WSAdvValue( oResponse,"_RESDESC","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cLOG_NO     :=  WSAdvValue( oResponse,"_LOG_NO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cLOG_MSG_NO :=  WSAdvValue( oResponse,"_LOG_MSG_NO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMESSAGE_V1 :=  WSAdvValue( oResponse,"_MESSAGE_V1","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMESSAGE_V2 :=  WSAdvValue( oResponse,"_MESSAGE_V2","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMESSAGE_V3 :=  WSAdvValue( oResponse,"_MESSAGE_V3","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMESSAGE_V4 :=  WSAdvValue( oResponse,"_MESSAGE_V4","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPARAMETER  :=  WSAdvValue( oResponse,"_PARAMETER","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nROW        :=  WSAdvValue( oResponse,"_ROW","integer",NIL,NIL,NIL,"N",NIL,NIL)
	::cFIELD      :=  WSAdvValue( oResponse,"_FIELD","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSYSTEM     :=  WSAdvValue( oResponse,"_SYSTEM","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_RetrieveWarrantyInfo_INPUT | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Envio                                                                |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura de envio utilizada na consulta de inf. de garantia         |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_RetrieveWarrantyInfo_INPUT
	WSDATA cMSGVERSION    AS string OPTIONAL
	WSDATA cDEALERACCOUNT AS string OPTIONAL
	WSDATA cLANGCODE      AS string OPTIONAL
	WSDATA cPIN           AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveWarrantyInfo_INPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveWarrantyInfo_INPUT
Return

WSMETHOD SOAPSEND WSCLIENT JD_RetrieveWarrantyInfo_INPUT
	Local cSoap := ""
	cSoap += WSSoapValue("DEALERACCOUNT", ::cDEALERACCOUNT , ::cDEALERACCOUNT , "string" , .f. , .f. , 0 , NIL , .f. )
	cSoap += WSSoapValue("LANGCODE"     , ::cLANGCODE      , ::cLANGCODE      , "string" , .f. , .f. , 0 , NIL , .f. )
	cSoap += WSSoapValue("MSGVERSION"   , ::cMSGVERSION    , ::cMSGVERSION    , "string" , .f. , .f. , 0 , NIL , .f. )
	cSoap += WSSoapValue("PIN"          , ::cPIN           , ::cPIN           , "string" , .f. , .f. , 0 , NIL , .f. )
Return cSoap


WSSTRUCT JD_RetrieveWarrantyInfo_OUTPUT
	WSDATA   oSUCCESS                 AS JD_SUCCESS OPTIONAL
	WSDATA   oWARINFO                 AS JD_RetrieveWarrantyInfo_WARINFO OPTIONAL
	WSDATA   oE_MACHINESTATUS         AS JD_RetrieveWarrantyInfo_E_MACHINESTATUS OPTIONAL
	WSDATA   oE_AMOUNT_OF_USE         AS JD_RetrieveWarrantyInfo_E_AMOUNT_OF_USE OPTIONAL
	WSDATA   oE_WARRANTY_DATA_HEADER  AS JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_HEADER OPTIONAL
	WSDATA   oE_WARRANTY_DATA_DETAILS AS JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_DETAILS OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV

ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveWarrantyInfo_OUTPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveWarrantyInfo_OUTPUT
	::oE_MACHINESTATUS        	:= {}
	::oE_AMOUNT_OF_USE         := {}
	::oE_WARRANTY_DATA_HEADER  := {}
	::oE_WARRANTY_DATA_DETAILS := {}
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveWarrantyInfo_OUTPUT

	Local nRElem, oNode, nTElem

	::Init()

	If oResponse = NIL ; Return ; Endif

	// Extraindo a Tag SUCCESS
	oNode :=  WSAdvValue( oResponse,"_SUCCESS","SUCCESS",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oSUCCESS := JD_SUCCESS():New()
		::oSUCCESS:SoapRecv(oNode)
	EndIf

	// Extraindo a Tag WARINFO
	oNode :=  WSAdvValue( oResponse,"_WARINFO","WARINFO",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oWARINFO := JD_RetrieveWarrantyInfo_WARINFO():New()
		::oWARINFO:SoapRecv(oNode)
	EndIf
	
	If ::oSUCCESS:cType == "X"
		Return
	EndIf	

	// Extraindo a Tag MACHINE_STATUS
	oNode :=  WSAdvValue( oResponse,"_E_MACHINESTATUS","E_MACHINESTATUS",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oE_MACHINESTATUS , JD_RetrieveWarrantyInfo_E_MACHINESTATUS():New() )
			::oE_MACHINESTATUS[len(::oE_MACHINESTATUS)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	// Extraindo a Tag AMOUNT_OF_USE
	oNode :=  WSAdvValue( oResponse,"_E_AMOUNT_OF_USE","E_AMOUNT_OF_USE",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oE_AMOUNT_OF_USE , JD_RetrieveWarrantyInfo_E_AMOUNT_OF_USE():New() )
			::oE_AMOUNT_OF_USE[len(::oE_AMOUNT_OF_USE)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	// Extraindo a Tag E_WARRANTY_DATA_HEADER
	oNode :=  WSAdvValue( oResponse,"_E_WARRANTY_DATA_HEADER","E_WARRANTY_DATA_HEADER",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oE_WARRANTY_DATA_HEADER , JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_HEADER():New() )
			::oE_WARRANTY_DATA_HEADER[len(::oE_WARRANTY_DATA_HEADER)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	oNode :=  WSAdvValue( oResponse,"_E_WARRANTY_DATA_DETAILS","E_WARRANTY_DATA_DETAILS",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oE_WARRANTY_DATA_DETAILS , JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_DETAILS():New() )
			::oE_WARRANTY_DATA_DETAILS[len(::oE_WARRANTY_DATA_DETAILS)]:SoapRecv(oNode[nRElem])
		Endif
	Next
Return













WSSTRUCT JD_RetrieveWarrantyInfo_WARINFO
	WSDATA   cDEALERACCOUNT            AS string OPTIONAL
	WSDATA   cPIN                      AS string OPTIONAL
	WSDATA   dRECEIVEDATE              AS string OPTIONAL
	WSDATA   cMODEL                    AS string OPTIONAL
	WSDATA   cCUSTOMERNO               AS string OPTIONAL
	WSDATA   dDELIVERYDATE             AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveWarrantyInfo_WARINFO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveWarrantyInfo_WARINFO
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveWarrantyInfo_WARINFO
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cDEALERACCOUNT     :=  WSAdvValue( oResponse,"_DEALERACCOUNT","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cPIN               :=  WSAdvValue( oResponse,"_PIN","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cMODEL             :=  WSAdvValue( oResponse,"_MODEL","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cCUSTOMERNO        :=  WSAdvValue( oResponse,"_CUSTOMERNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::dRECEIVEDATE       :=  StoD(WSAdvValue( oResponse,"_RECIEVEDATE","string","",NIL,NIL,"S",NIL,NIL) )
	::dDELIVERYDATE      :=  StoD(WSAdvValue( oResponse,"_DELIVERYDATE","string","",NIL,NIL,"S",NIL,NIL) )
Return





WSSTRUCT JD_RetrieveWarrantyInfo_E_MACHINESTATUS
	WSDATA   cMACHINESTATUS      AS string OPTIONAL
	WSDATA   cMACHINESTATUS_DESC AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveWarrantyInfo_E_MACHINESTATUS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveWarrantyInfo_E_MACHINESTATUS
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveWarrantyInfo_E_MACHINESTATUS
	::Init()

	If oResponse = NIL ; Return ; Endif

	::cMACHINESTATUS      := WSAdvValue( oResponse,"_MACHINESTATUS","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMACHINESTATUS_DESC := IIf( ::cMACHINESTATUS <> NIL , OFIOA560DS( "023" , ::cMACHINESTATUS ) , "" )
Return







// WSDL Data Structure E_AMOUNT_OF_USE

WSSTRUCT JD_RetrieveWarrantyInfo_E_AMOUNT_OF_USE
	WSDATA   dREADINGDATE AS string OPTIONAL
	WSDATA   cUOM         AS string OPTIONAL
	WSDATA   cUOM_DESC    AS string OPTIONAL
	WSDATA   cAMOUNTOFUSE AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV

ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveWarrantyInfo_E_AMOUNT_OF_USE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveWarrantyInfo_E_AMOUNT_OF_USE
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveWarrantyInfo_E_AMOUNT_OF_USE
	::Init()
	If oResponse = NIL ; Return ; Endif
	::dREADINGDATE := StoD(WSAdvValue( oResponse,"_READINGDATE","string","",NIL,NIL,"S",NIL,NIL) )
	::cUOM         := WSAdvValue( oResponse,"_UOM","string","",NIL,NIL,"S",NIL,NIL)
	::cUOM_DESC    := IIf( ::cUOM <> NIL , OFIOA560DS("005",::cUOM) , "" )
	::cAMOUNTOFUSE := WSAdvValue( oResponse,"_AMOUNTOFUSE","string","",NIL,NIL,"S",NIL,NIL)
Return





// WSDL Data Structure E_WARRANTY_DATA_HEADER

WSSTRUCT JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_HEADER
	WSDATA   cWARRANTY_TYPE      AS string OPTIONAL
	WSDATA   cWARRANTY_TYPE_DESC	     AS string OPTIONAL
	WSDATA   cWARRANTY_NUMBER    AS string OPTIONAL
	WSDATA   dASSIGNDATE         AS string OPTIONAL
	WSDATA   dSTARTDATE          AS string OPTIONAL
	WSDATA   dEXPIREDATE         AS string OPTIONAL
	WSDATA   nDEDUCTIBLE         AS float OPTIONAL
	WSDATA   cDEDUCTIBLECURRENCY AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_HEADER
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_HEADER
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_HEADER
	::Init()

	If oResponse = NIL ; Return ; Endif

	::cWARRANTY_TYPE		:=  WSAdvValue( oResponse,"_WARRANTY_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cWARRANTY_TYPE_DESC	:=  IIf( ::cWARRANTY_TYPE <> NIL, OFIOA560DS("020", ::cWARRANTY_TYPE , "" ), "" )
	::cWARRANTY_NUMBER		:=  WSAdvValue( oResponse,"_WARRANTY_NUMBER","string",NIL,NIL,NIL,"S",NIL,NIL)
	::dASSIGNDATE			:=  StoD(WSAdvValue( oResponse,"_ASSIGNDATE","string","",NIL,NIL,"S",NIL,NIL))
	::dSTARTDATE 			:=  StoD(WSAdvValue( oResponse,"_STARTDATE" ,"string","",NIL,NIL,"S",NIL,NIL))
	::dEXPIREDATE			:=  StoD(WSAdvValue( oResponse,"_EXPIREDATE","string","",NIL,NIL,"S",NIL,NIL))
	::nDEDUCTIBLE			:=  WSAdvValue( oResponse,"_DEDUCTIBLE","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cDEDUCTIBLECURRENCY	:=  WSAdvValue( oResponse,"_DEDUCTIBLECURRENCY","string",NIL,NIL,NIL,"S",NIL,NIL)
Return




// WSDL Data Structure E_WARRANTY_DATA_DETAILS

WSSTRUCT JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_DETAILS
	WSDATA   cWARRANTY_TYPE   AS string OPTIONAL
	WSDATA   cWARRANTY_TYPE_DESC   AS string OPTIONAL
	WSDATA   cLIMIT_TYPE      AS string OPTIONAL
	WSDATA   cLIMIT_TYPE_DESC AS string OPTIONAL
	WSDATA   cLIMIT_VALUE     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_DETAILS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_DETAILS
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveWarrantyInfo_E_WARRANTY_DATA_DETAILS
	::Init()

	If oResponse = NIL ; Return ; Endif

	::cWARRANTY_TYPE      :=  WSAdvValue( oResponse,"_WARRANTY_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cWARRANTY_TYPE_DESC :=  IIf( ::cWARRANTY_TYPE <> NIL , OFIOA560DS("020", ::cWARRANTY_TYPE ) , "" )
	::cLIMIT_TYPE         :=  WSAdvValue( oResponse,"_LIMIT_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cLIMIT_TYPE_DESC    :=  IIf( ::cLIMIT_TYPE <> NIL , OFIOA560DS("005",::cLIMIT_TYPE ) , "" )
	::cLIMIT_VALUE        :=  WSAdvValue( oResponse,"_LIMIT_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL)
Return






// WSDL Data Structure INPUT

WSSTRUCT JD_SubmitDeliveryReceipt_INPUT
	WSDATA   cMSGVERSION    AS string OPTIONAL
	WSDATA   cDEALERACCOUNT AS string OPTIONAL
	WSDATA   nDRNO          AS integer OPTIONAL
	WSDATA   cCUSTTYPE      AS string OPTIONAL
	WSDATA   cLANGCODE      AS string OPTIONAL
	WSDATA   cDELIVERYDATE  AS string OPTIONAL
	WSDATA   cAPP_ID        AS string OPTIONAL
	WSDATA   oCUSTOMER      AS JD_SubmitDeliveryReceipt_CUSTOMER OPTIONAL
	WSDATA   oEQUIPMENT     AS JD_SubmitDeliveryReceipt_EQUIPMENT OPTIONAL
	WSDATA   oMEASUREMENTS  AS JD_SubmitDeliveryReceipt_MEASUREMENTS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD ADDMEASUREMENT
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SubmitDeliveryReceipt_INPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SubmitDeliveryReceipt_INPUT
	::oMEASUREMENTS      := {} // Array Of  JD_SubmitDeliveryReceipt_MEASUREMENTS():New()
Return

WSMETHOD ADDMEASUREMENT WSCLIENT JD_SubmitDeliveryReceipt_INPUT
	AADD( ::oMEASUREMENTS , JD_SubmitDeliveryReceipt_MEASUREMENTS():New() )
Return Len(::oMEASUREMENTS)

WSMETHOD SOAPSEND WSCLIENT JD_SubmitDeliveryReceipt_INPUT
	Local cSoap := ""

	cSoap += WSSoapValue("DEALERACCOUNT", ::cDEALERACCOUNT , ::cDEALERACCOUNT , "string" , .f. , .f. , 0 , NIL , .f. )
	cSoap += WSSoapValue("LANGCODE"     , ::cLANGCODE      , ::cLANGCODE      , "string" , .f. , .f. , 0 , NIL , .f. )
	cSoap += WSSoapValue("MSGVERSION"   , ::cMSGVERSION    , ::cMSGVERSION    , "string" , .f. , .f. , 0 , NIL , .f. )
	cSoap += WSSoapValue("DRNO", ::nDRNO, ::nDRNO , "integer", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("APP_ID", ::cAPP_ID, ::cAPP_ID , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("CUSTTYPE", ::cCUSTTYPE, ::cCUSTTYPE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("DELIVERYDATE", ::cDELIVERYDATE, ::cDELIVERYDATE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("CUSTOMER", ::oCUSTOMER, ::oCUSTOMER , "CUSTOMER", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("EQUIPMENT", ::oEQUIPMENT, ::oEQUIPMENT , "EQUIPMENT", .F. , .F., 0 , NIL, .F.)
	aEval( ::oMEASUREMENTS , {|x| cSoap := cSoap  +  WSSoapValue("MEASUREMENTS", x , x , "MEASUREMENTS", .F. , .F., 0 , NIL, .F.)  } )
Return cSoap



// WSDL Data Structure CUSTOMER

WSSTRUCT JD_SubmitDeliveryReceipt_CUSTOMER
	WSDATA   cBUSIND                   AS string OPTIONAL
	WSDATA   cLASTNM                   AS string OPTIONAL
	WSDATA   cFIRSTNM                  AS string OPTIONAL
	WSDATA   cMI                       AS string OPTIONAL
	WSDATA   cBUSNM                    AS string OPTIONAL
	WSDATA   cCONTACT                  AS string OPTIONAL
	WSDATA   cSTADDR1                  AS string OPTIONAL
	WSDATA   cSTADDR2                  AS string OPTIONAL
	WSDATA   cCITY                     AS string OPTIONAL
	WSDATA   cSTATE                    AS string OPTIONAL
	WSDATA   cCOUNTRY                  AS string OPTIONAL
	WSDATA   cPHONE                    AS string OPTIONAL
	WSDATA   cZIP                      AS string OPTIONAL
	WSDATA   cEMAIL_ADDRESS            AS string OPTIONAL
	WSDATA   cCKCCUSTID                AS string OPTIONAL
	WSDATA   cTAXID                    AS string OPTIONAL
	WSDATA   cTAXID_TYPE               AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SubmitDeliveryReceipt_CUSTOMER
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SubmitDeliveryReceipt_CUSTOMER
Return

WSMETHOD SOAPSEND WSCLIENT JD_SubmitDeliveryReceipt_CUSTOMER
	Local cSoap := ""
	cSoap += WSSoapValue("BUSIND",  ::cBUSIND, ::cBUSIND , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += IIf( !Empty(::cFIRSTNM) , WSSoapValue("FIRSTNM", ::cFIRSTNM, ::cFIRSTNM , "string", .F. , .F., 0 , NIL, .F.), "" )
	cSoap += IIf( !Empty(::cLASTNM ) , WSSoapValue("LASTNM",  ::cLASTNM, ::cLASTNM , "string", .F. , .F., 0 , NIL, .F.)  , "" )
	cSoap += IIf( !Empty(::cBUSNM  ) , WSSoapValue("BUSNM",   ::cBUSNM, ::cBUSNM , "string", .F. , .F., 0 , NIL, .F.)    , "" )
	cSoap += WSSoapValue("CITY",    ::cCITY, ::cCITY , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("COUNTRY", ::cCOUNTRY, ::cCOUNTRY , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("EMAIL_ADDRESS", ::cEMAIL_ADDRESS, ::cEMAIL_ADDRESS , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += IIf( !Empty(::cMI     ) , WSSoapValue("MI",      Left(::cMI,10), Left(::cMI,10) , "string", .F. , .F., 0 , NIL, .F.)          , "" )
	cSoap += IIf( !Empty(::cCONTACT) , WSSoapValue("CONTACT", ::cCONTACT, ::cCONTACT , "string", .F. , .F., 0 , NIL, .F.) , "" )
	cSoap += WSSoapValue("PHONE",   ::cPHONE, ::cPHONE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("STADDR1", ::cSTADDR1, ::cSTADDR1 , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += IIf( !Empty(::cSTADDR2) , WSSoapValue("STADDR2", ::cSTADDR2, ::cSTADDR2 , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += WSSoapValue("STATE",   ::cSTATE, ::cSTATE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += IIf( !Empty(::cCKCCUSTID) , WSSoapValue("CKCCUSTID", ::cCKCCUSTID, ::cCKCCUSTID , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += WSSoapValue("TAXID",      ::cTAXID, ::cTAXID , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("TAXID_TYPE", ::cTAXID_TYPE, ::cTAXID_TYPE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("ZIP",     ::cZIP, ::cZIP , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap



// WSDL Data Structure EQUIPMENT

WSSTRUCT JD_SubmitDeliveryReceipt_EQUIPMENT
	WSDATA   cOWNERCODE                AS string OPTIONAL
	WSDATA   cPIN                      AS string OPTIONAL
	WSDATA   cMKTCODE                  AS string OPTIONAL
	WSDATA   cDEALERACCOUNT            AS string OPTIONAL
	WSDATA   cEXPFIRSTUSEDATE          AS string OPTIONAL
//	WSDATA   cLICENSE_PLATE            AS string OPTIONAL
//	WSDATA   cOPE_MANUAL_ID            AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPSEND

ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SubmitDeliveryReceipt_EQUIPMENT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SubmitDeliveryReceipt_EQUIPMENT
Return


WSMETHOD SOAPSEND WSCLIENT JD_SubmitDeliveryReceipt_EQUIPMENT
	Local cSoap := ""
	cSoap += WSSoapValue("OWNERCODE", ::cOWNERCODE, ::cOWNERCODE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("PIN", ::cPIN, ::cPIN , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("MKTCODE", ::cMKTCODE, ::cMKTCODE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("DEALERACCOUNT", ::cDEALERACCOUNT, ::cDEALERACCOUNT , "string", .F. , .F., 0 , NIL, .F.)
//	cSoap += WSSoapValue("EXPFIRSTUSEDATE", ::cEXPFIRSTUSEDATE, ::cEXPFIRSTUSEDATE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += IIf( !Empty(::cEXPFIRSTUSEDATE) , WSSoapValue("EXPFIRSTUSEDATE", ::cEXPFIRSTUSEDATE, ::cEXPFIRSTUSEDATE , "string", .F. , .F., 0 , NIL, .F.) , "")	
//	cSoap += WSSoapValue("LICENSE_PLATE", ::cLICENSE_PLATE, ::cLICENSE_PLATE , "string", .F. , .F., 0 , NIL, .F.)
//	cSoap += WSSoapValue("OPE_MANUAL_ID", ::cOPE_MANUAL_ID, ::cOPE_MANUAL_ID , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap




// WSDL Data Structure MEASUREMENTS

WSSTRUCT JD_SubmitDeliveryReceipt_MEASUREMENTS
	WSDATA   cAMTUSE                   AS string OPTIONAL
	WSDATA   cUSEINDICATOR             AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SubmitDeliveryReceipt_MEASUREMENTS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SubmitDeliveryReceipt_MEASUREMENTS
Return

WSMETHOD SOAPSEND WSCLIENT JD_SubmitDeliveryReceipt_MEASUREMENTS
	Local cSoap := ""
	cSoap += WSSoapValue("AMTUSE"		, AllTrim(::cAMTUSE)		, AllTrim(::cAMTUSE)		, "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("USEINDICATOR"	, AllTrim(::cUSEINDICATOR)	, AllTrim(::cUSEINDICATOR)	, "string", .F. , .F., 0 , NIL, .F.)
Return cSoap



// WSDL Data Structure Return

WSSTRUCT JD_SubmitDeliveryReceipt_OUTPUT
	WSDATA   oSUCCESS                AS JD_SUCCESS OPTIONAL
	WSDATA   oDELRECPT               AS JD_SubmitDeliveryReceipt_DELRECPT OPTIONAL
	WSDATA   oDRSTATUS               AS JD_SubmitDeliveryReceipt_DRSTATUS OPTIONAL
	WSDATA   oET_RETURN_MSG          AS JD_SubmitDeliveryReceipt_ET_RETURN_MSG OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV

ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SubmitDeliveryReceipt_OUTPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SubmitDeliveryReceipt_OUTPUT
	::oET_RETURN_MSG     := {} // Array Of  SubmitDeliveryReceipt_ET_RETURN_MSG():New()
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_SubmitDeliveryReceipt_OUTPUT

	Local nRElem, oNode, nTElem

	::Init()

	If oResponse = NIL ; Return ; Endif

	oNode :=  WSAdvValue( oResponse,"_SUCCESS","SUCCESS",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oSUCCESS := JD_SUCCESS():New()
		::oSUCCESS:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_DELRECPT","DELRECPT",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oDELRECPT := JD_SubmitDeliveryReceipt_DELRECPT():New()
		::oDELRECPT:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_DRSTATUS","DRSTATUS",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oDRSTATUS := JD_SubmitDeliveryReceipt_DRSTATUS():New()
		::oDRSTATUS:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_ET_RETURN_MSG","ET_RETURN_MSG",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oET_RETURN_MSG , JD_SubmitDeliveryReceipt_ET_RETURN_MSG():New() )
			::oET_RETURN_MSG[len(::oET_RETURN_MSG)]:SoapRecv(oNode[nRElem])
		Endif
	Next
Return

// WSDL Data Structure DELRECPT

WSSTRUCT JD_SubmitDeliveryReceipt_DELRECPT
	WSDATA   nDRNO                     AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SubmitDeliveryReceipt_DELRECPT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SubmitDeliveryReceipt_DELRECPT
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_SubmitDeliveryReceipt_DELRECPT
	::Init()
	If oResponse = NIL ; Return ; Endif
	::nDRNO              :=  WSAdvValue( oResponse,"_DRNO","integer",NIL,NIL,NIL,"N",NIL,"tns")
Return

// WSDL Data Structure DRSTATUS

WSSTRUCT JD_SubmitDeliveryReceipt_DRSTATUS
	WSDATA   cPIN                      AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cMSG                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SubmitDeliveryReceipt_DRSTATUS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SubmitDeliveryReceipt_DRSTATUS
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_SubmitDeliveryReceipt_DRSTATUS
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cPIN               :=  WSAdvValue( oResponse,"_PIN","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMSG               :=  WSAdvValue( oResponse,"_MSG","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure ET_RETURN_MSG

WSSTRUCT JD_SubmitDeliveryReceipt_ET_RETURN_MSG
	WSDATA   cRETURN_ID                AS string OPTIONAL
	WSDATA   cNUMBER                   AS string OPTIONAL
	WSDATA   cMESSAGE                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SubmitDeliveryReceipt_ET_RETURN_MSG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SubmitDeliveryReceipt_ET_RETURN_MSG
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_SubmitDeliveryReceipt_ET_RETURN_MSG
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cRETURN_ID         :=  WSAdvValue( oResponse,"_RETURN_ID","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cNUMBER            :=  WSAdvValue( oResponse,"_NUMBER","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMESSAGE           :=  WSAdvValue( oResponse,"_MESSAGE","string",NIL,NIL,NIL,"S",NIL,NIL)
Return










// WSDL Data Structure INPUT

WSSTRUCT JD_RetrieveOpenPIPsMCD_INPUT
	WSDATA   cMSGVERSION               AS string OPTIONAL
	WSDATA   cLANGCODE                 AS string OPTIONAL
	WSDATA   cPIN                      AS string OPTIONAL
	WSDATA   cDEALERACCOUNT            AS string OPTIONAL
	WSDATA   cMACHINECD                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_INPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_INPUT
Return

WSMETHOD SOAPSEND WSCLIENT JD_RetrieveOpenPIPsMCD_INPUT
	Local cSoap := ""
	cSoap += WSSoapValue("MSGVERSION", ::cMSGVERSION, ::cMSGVERSION , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("LANGCODE", ::cLANGCODE, ::cLANGCODE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("PIN", ::cPIN, ::cPIN , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("DEALERACCOUNT", ::cDEALERACCOUNT, ::cDEALERACCOUNT , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("MACHINECD", ::cMACHINECD, ::cMACHINECD , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap

























// WSDL Data Structure OUTPUT

WSSTRUCT JD_RetrieveOpenPIPsMCD_OUTPUT
	WSDATA   oSUCCESS      AS JD_SUCCESS OPTIONAL
	WSDATA   oPINNO        AS JD_RetrieveOpenPIPsMCD_PINNO OPTIONAL
	WSDATA   oPIP          AS JD_RetrieveOpenPIPsMCD_PIP OPTIONAL
	WSDATA   oCONTRACT     AS JD_RetrieveOpenPIPsMCD_CONTRACT OPTIONAL	// ok
	WSDATA   oBUNDLE       AS JD_RetrieveOpenPIPsMCD_BUNDLE OPTIONAL
	WSDATA   oREPLACEPART  AS JD_RetrieveOpenPIPsMCD_REPLACEPART OPTIONAL	// ok
	WSDATA   oLABOR        AS JD_RetrieveOpenPIPsMCD_LABOR OPTIONAL			// ok
	WSDATA   oOTHERCREDIT  AS JD_RetrieveOpenPIPsMCD_OTHERCREDIT OPTIONAL	// ok

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_OUTPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_OUTPUT
	::oPIP               := {} // Array Of JD_RetrieveOpenPIPsMCD_PIP():New()
	::oCONTRACT          := {} // Array Of JD_RetrieveOpenPIPsMCD_CONTRACT():New()
	::oBUNDLE            := {} // Array Of JD_RetrieveOpenPIPsMCD_BUNDLE():New()
	::oREPLACEPART       := {} // Array Of JD_RetrieveOpenPIPsMCD_REPLACEPART():New()
	::oLABOR             := {} // Array Of JD_RetrieveOpenPIPsMCD_LABOR():New()
	::oOTHERCREDIT       := {} // Array Of JD_RetrieveOpenPIPsMCD_OTHERCREDIT():New()
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveOpenPIPsMCD_OUTPUT

	Local nRElem, oNode, nTElem

	::Init()

	If oResponse = NIL ; Return ; Endif
	oNode :=  WSAdvValue( oResponse,"_SUCCESS","SUCCESS",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oSUCCESS := JD_SUCCESS():New()
		::oSUCCESS:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_PINNO","PINNO",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oPINNO := JD_RetrieveOpenPIPsMCD_PINNO():New()
		::oPINNO:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_PIP","PIP",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oPIP , JD_RetrieveOpenPIPsMCD_PIP():New() )
			::oPIP[len(::oPIP)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	oNode :=  WSAdvValue( oResponse,"_CONTRACT","CONTRACT",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oCONTRACT , JD_RetrieveOpenPIPsMCD_CONTRACT():New() )
			::oCONTRACT[len(::oCONTRACT)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	oNode :=  WSAdvValue( oResponse,"_BUNDLE","BUNDLE",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oBUNDLE , JD_RetrieveOpenPIPsMCD_BUNDLE():New() )
			::oBUNDLE[len(::oBUNDLE)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	oNode :=  WSAdvValue( oResponse,"_REPLACEPART","REPLACEPART",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oREPLACEPART , JD_RetrieveOpenPIPsMCD_REPLACEPART():New() )
			::oREPLACEPART[len(::oREPLACEPART)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	oNode :=  WSAdvValue( oResponse,"_LABOR","LABOR",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oLABOR , JD_RetrieveOpenPIPsMCD_LABOR():New() )
			::oLABOR[len(::oLABOR)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	oNode :=  WSAdvValue( oResponse,"_OTHERCREDIT","OTHERCREDIT",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oOTHERCREDIT , JD_RetrieveOpenPIPsMCD_OTHERCREDIT():New() )
			::oOTHERCREDIT[len(::oOTHERCREDIT)]:SoapRecv(oNode[nRElem])
		Endif
	Next
Return


// WSDL Data Structure PINNO

WSSTRUCT JD_RetrieveOpenPIPsMCD_PINNO
	WSDATA   cPIN                      AS string OPTIONAL
	WSDATA   cMODEL                    AS string OPTIONAL
	WSDATA   nVALID                    AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_PINNO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_PINNO
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveOpenPIPsMCD_PINNO
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cPIN               :=  WSAdvValue( oResponse,"_PIN","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cMODEL             :=  WSAdvValue( oResponse,"_MODEL","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nVALID             :=  WSAdvValue( oResponse,"_VALID","integer",NIL,NIL,NIL,"N",NIL,NIL)
Return

// WSDL Data Structure PIP

WSSTRUCT JD_RetrieveOpenPIPsMCD_PIP
	WSDATA   cPIPNO                    AS string OPTIONAL
	WSDATA   cTYPE                     AS string OPTIONAL
	WSDATA   cTYPE_DESC                AS string OPTIONAL
	WSDATA   cTITLE                    AS string OPTIONAL
	WSDATA   dEXPIRDT                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_PIP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_PIP
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveOpenPIPsMCD_PIP
	::Init()

	If oResponse = NIL ; Return ; Endif

	::cPIPNO     :=  WSAdvValue( oResponse,"_PIPNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cTYPE      :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cTYPE_DESC :=  IIf( ::cTYPE <> NIL , OFIOA560DS( "019" , ::cTYPE ) , "" ) 
	::cTITLE     :=  WSAdvValue( oResponse,"_TITLE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::dEXPIRDT   :=  StoD(WSAdvValue( oResponse,"_EXPIRDT","string","",NIL,NIL,"S",NIL,NIL))
Return

// WSDL Data Structure CONTRACT

WSSTRUCT JD_RetrieveOpenPIPsMCD_CONTRACT
	WSDATA   cPLANNAME             AS string OPTIONAL
	WSDATA   cMACHINECD            AS string OPTIONAL
	WSDATA   cMATERIAL_MASTER      AS string OPTIONAL
	WSDATA   dCONTRACT_STARTDATE   AS string OPTIONAL
	WSDATA   dCONTRACT_ENDDATE     AS string OPTIONAL
	WSDATA   cCONTRACT_STATUS      AS string OPTIONAL
	WSDATA   nSERVICENO            AS integer OPTIONAL
	WSDATA   cSERVINTTYPE          AS string OPTIONAL
	WSDATA   cSERVINTTYPE_DESC     AS string OPTIONAL
	WSDATA   dINTERVAL_STARTDATE   AS string OPTIONAL
	WSDATA   dINTERVAL_ENDDATE     AS string OPTIONAL
	WSDATA   cINTERVAL_STATUS      AS string OPTIONAL
	WSDATA   cINTERVAL_STATUS_DESC AS string OPTIONAL
	WSDATA   cINTERVAL_LIMIT       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_CONTRACT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_CONTRACT
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveOpenPIPsMCD_CONTRACT

	::Init()

	If oResponse = NIL ; Return ; Endif

	::cPLANNAME             :=  WSAdvValue( oResponse,"_PLANNAME","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMACHINECD            :=  WSAdvValue( oResponse,"_MACHINECD","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cMATERIAL_MASTER      :=  WSAdvValue( oResponse,"_MATERIAL_MASTER","string",NIL,NIL,NIL,"S",NIL,NIL)
	::dCONTRACT_STARTDATE   :=  StoD(WSAdvValue( oResponse,"_CONTRACT_STARTDATE","string","",NIL,NIL,"S",NIL,NIL))
	::dCONTRACT_ENDDATE     :=  StoD(WSAdvValue( oResponse,"_CONTRACT_ENDDATE"  ,"string","",NIL,NIL,"S",NIL,NIL))
	::cCONTRACT_STATUS      :=  WSAdvValue( oResponse,"_CONTRACT_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nSERVICENO            :=  WSAdvValue( oResponse,"_SERVICENO","integer",NIL,NIL,NIL,"N",NIL,NIL)
	::cSERVINTTYPE          :=  WSAdvValue( oResponse,"_SERVINTTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSERVINTTYPE_DESC     :=  IIf( ::cSERVINTTYPE <> NIL , OFIOA560DS("014", ::cSERVINTTYPE ) , "" )
	::dINTERVAL_STARTDATE   :=  StoD(WSAdvValue( oResponse,"_INTERVAL_STARTDATE","string","",NIL,NIL,"S",NIL,NIL) )
	::dINTERVAL_ENDDATE     :=  StoD(WSAdvValue( oResponse,"_INTERVAL_ENDDATE"  ,"string","",NIL,NIL,"S",NIL,NIL) )
	::cINTERVAL_STATUS      :=  WSAdvValue( oResponse,"_INTERVAL_STATUS"   ,"string","",NIL,NIL,"S",NIL,NIL)
	::cINTERVAL_STATUS_DESC :=  IIf( ::cINTERVAL_STATUS <> NIL , OFIOA560DS("021",::cINTERVAL_STATUS) , "" )
	::cINTERVAL_LIMIT       :=  WSAdvValue( oResponse,"_INTERVAL_LIMIT"    ,"string","",NIL,NIL,"S",NIL,NIL)

Return

// WSDL Data Structure BUNDLE

WSSTRUCT JD_RetrieveOpenPIPsMCD_BUNDLE
	WSDATA   cPIPNO         AS string OPTIONAL
	WSDATA   cKEY           AS string OPTIONAL
	WSDATA   cLABOR         AS string OPTIONAL
	WSDATA   cLABOR_DESC    AS string OPTIONAL
	WSDATA   nQTY           AS float OPTIONAL
	WSDATA   cNO            AS string OPTIONAL
	WSDATA   cSUBTYPE       AS string OPTIONAL
	WSDATA   cSUBTYPE_DESC  AS string OPTIONAL
	WSDATA   cTIPO_REGISTRO AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_BUNDLE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_BUNDLE
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveOpenPIPsMCD_BUNDLE
	::Init()
	If oResponse = NIL ; Return ; Endif
	::nQTY          :=  WSAdvValue( oResponse,"_QTY","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cNO           :=  WSAdvValue( oResponse,"_NO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cKEY          :=  WSAdvValue( oResponse,"_KEY","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cLABOR        :=  WSAdvValue( oResponse,"_LABOR","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPIPNO        :=  WSAdvValue( oResponse,"_PIPNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSUBTYPE      :=  WSAdvValue( oResponse,"_SUBTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSUBTYPE_DESC :=  IIf( ::cSUBTYPE <> NIL , OFIOA560DS( "018" , ::cSUBTYPE ) , "" )

	If "LABOR" $ ::cLABOR
		::cTIPO_REGISTRO := "S"
		::cLABOR_DESC	 := IIf( ::cLABOR <> NIL , OFIOA560DS( "017" , ::cLABOR ) , "" )
	Else
		::cTIPO_REGISTRO := "P"
		::cLABOR_DESC	 := IIf( ::cLABOR <> NIL , FM_SQL("SELECT B1_DESC FROM " + RetSQLName("SB1") + " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = '" + AllTrim(::cLABOR ) + "' AND D_E_L_E_T_ = ' ' ") , "" )
	EndIf

Return

// WSDL Data Structure REPLACEPART

WSSTRUCT JD_RetrieveOpenPIPsMCD_REPLACEPART
	WSDATA   cPLANNAME                 AS string OPTIONAL
	WSDATA   cMACHINECD                AS string OPTIONAL
	WSDATA   cMATERIAL_MASTER          AS string OPTIONAL
	WSDATA   nQTY                      AS float OPTIONAL
	WSDATA   cSERVINTTYPE              AS string OPTIONAL
	WSDATA   cPARTNO                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_REPLACEPART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_REPLACEPART
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveOpenPIPsMCD_REPLACEPART
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cPLANNAME          :=  WSAdvValue( oResponse,"_PLANNAME","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMACHINECD         :=  WSAdvValue( oResponse,"_MACHINECD","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cMATERIAL_MASTER   :=  WSAdvValue( oResponse,"_MATERIAL_MASTER","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nQTY               :=  WSAdvValue( oResponse,"_QTY","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cSERVINTTYPE       :=  WSAdvValue( oResponse,"_SERVINTTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPARTNO            :=  WSAdvValue( oResponse,"_PARTNO","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure LABOR

WSSTRUCT JD_RetrieveOpenPIPsMCD_LABOR
	WSDATA   cPLANNAME        AS string OPTIONAL
	WSDATA   cMATERIAL_MASTER AS string OPTIONAL
	WSDATA   nAMT             AS float OPTIONAL
	WSDATA   cTYPE            AS string OPTIONAL
	WSDATA   cTYPE_DESC       AS string OPTIONAL
	WSDATA   cSUBTYPE         AS string OPTIONAL
	WSDATA   cSUBTYPE_DESC    AS string OPTIONAL
	WSDATA   cMACHINECD       AS string OPTIONAL
	WSDATA   cSERVINTTYPE     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_LABOR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_LABOR
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveOpenPIPsMCD_LABOR
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cPLANNAME          :=  WSAdvValue( oResponse,"_PLANNAME","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMATERIAL_MASTER   :=  WSAdvValue( oResponse,"_MATERIAL_MASTER","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nAMT               :=  WSAdvValue( oResponse,"_AMT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cTYPE_DESC         :=  IIf( ::cTYPE <> NIL , OFIOA560DS( "017" , ::cTYPE ) , "" )
	::cSUBTYPE           :=  WSAdvValue( oResponse,"_SUBTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSUBTYPE_DESC      :=  IIf( ::cSUBTYPE <> NIL , OFIOA560DS( "018" , ::cSUBTYPE ) , "" )
	::cMACHINECD         :=  WSAdvValue( oResponse,"_MACHINECD","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cSERVINTTYPE       :=  WSAdvValue( oResponse,"_SERVINTTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure OTHERCREDIT

WSSTRUCT JD_RetrieveOpenPIPsMCD_OTHERCREDIT
	WSDATA   cPLANNAME         AS string OPTIONAL
	WSDATA   cMATERIAL_MASTER  AS string OPTIONAL
	WSDATA   nLABOR_MATCOST    AS float OPTIONAL
	WSDATA   cDESC             AS string OPTIONAL
	WSDATA   cDESC_DESC        AS string OPTIONAL
	WSDATA   cMACHINECD        AS string OPTIONAL
	WSDATA   cSERVINTTYPE      AS string OPTIONAL
	WSDATA   cSERVINTTYPE_DESC AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveOpenPIPsMCD_OTHERCREDIT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveOpenPIPsMCD_OTHERCREDIT
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveOpenPIPsMCD_OTHERCREDIT
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cPLANNAME          :=  WSAdvValue( oResponse,"_PLANNAME","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMATERIAL_MASTER   :=  WSAdvValue( oResponse,"_MATERIAL_MASTER","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nLABOR_MATCOST     :=  WSAdvValue( oResponse,"_LABOR_MATCOST","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cDESC              :=  WSAdvValue( oResponse,"_DESC","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cDESC_DESC         :=  IIf( ::cDESC <> NIL , OFIOA560DS( "022" , ::cDESC ) , "" )
	::cMACHINECD         :=  WSAdvValue( oResponse,"_MACHINECD","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cSERVINTTYPE       :=  WSAdvValue( oResponse,"_SERVINTTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSERVINTTYPE_DESC  :=  IIf( ::cSERVINTTYPE <> NIL , FM_SQL("SELECT VX5_DESCRI FROM " + RetSQLName("VX5") + " WHERE VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5_CHAVE = '014' AND VX5_CODIGO = '" + ::cSERVINTTYPE + "' AND D_E_L_E_T_ = ' '") , "" )

Return














/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_SaveClaim_REQUEST          | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Envio                                                                |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura utilizada no envio da garantia                             |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_SaveClaim_REQUEST
	WSDATA   oINPUT                  AS JD_SaveClaim_INPUT OPTIONAL
	WSDATA   oREPLACEPART            AS JD_SaveClaim_REPLACEPART OPTIONAL
	WSDATA   oLABOR                  AS JD_SaveClaim_LABOR OPTIONAL
	WSDATA   oOTHERCREDIT            AS JD_SaveClaim_OTHERCREDIT OPTIONAL
	WSDATA   oPINS                   AS JD_SaveClaim_PINS OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD ADDREPLACEPART
	WSMETHOD ADDLABOR
	WSMETHOD ADDOTHERCREDIT
	WSMETHOD ADDPINS

	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SaveClaim_REQUEST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SaveClaim_REQUEST
	::oINPUT := JD_SaveClaim_INPUT():New()
	::oREPLACEPART       := {} // Array Of  JD_SaveClaim_REPLACEPART():New()
	::oLABOR             := {} // Array Of  JD_SaveClaim_LABOR():New()
	::oOTHERCREDIT       := {} // Array Of  JD_SaveClaim_OTHERCREDIT():New()
	::oPINS              := {} // Array Of  JD_SaveClaim_PINS():New()
Return

WSMETHOD ADDREPLACEPART WSCLIENT JD_SaveClaim_REQUEST
	AADD( ::oREPLACEPART , JD_SaveClaim_REPLACEPART():New() )
Return Len(::oREPLACEPART)

WSMETHOD ADDLABOR WSCLIENT JD_SaveClaim_REQUEST
	AADD( ::oLABOR , JD_SaveClaim_LABOR():New() )
Return Len(::oLABOR)

WSMETHOD ADDOTHERCREDIT WSCLIENT JD_SaveClaim_REQUEST
	AADD( ::oOTHERCREDIT , JD_SaveClaim_OTHERCREDIT():New() )
Return Len(::oOTHERCREDIT)

WSMETHOD ADDPINS WSCLIENT JD_SaveClaim_REQUEST
	AADD( ::oPINS , JD_SaveClaim_PINS():New() )
Return Len(::oPINS)

WSMETHOD SOAPSEND WSCLIENT JD_SaveClaim_REQUEST

	Local cSoap := ""

	cSoap += WSSoapValue("INPUT", ::oINPUT, ::oINPUT , "INPUT", .F. , .F., 0 , NIL, .F.)

	aEval( ::oREPLACEPART , {|x| cSoap := cSoap  +  WSSoapValue("REPLACEPART", x , x , "REPLACEPART", .F. , .F., 0 , NIL, .F.)  } )
	aEval( ::oLABOR 	  , {|x| cSoap := cSoap  +  WSSoapValue("LABOR", x , x , "LABOR", .F. , .F., 0 , NIL, .F.)  } )
	aEval( ::oOTHERCREDIT , {|x| cSoap := cSoap  +  WSSoapValue("OTHERCREDIT", x , x , "OTHERCREDIT", .F. , .F., 0 , NIL, .F.)  } )
	aEval( ::oPINS 		  , {|x| cSoap := cSoap  +  WSSoapValue("PINS", x , x , "PINS", .F. , .F., 0 , NIL, .F.)  } )
Return cSoap

// WSDL Data Structure INPUT

WSSTRUCT JD_SaveClaim_INPUT
	WSDATA   cMSGVERSION               AS string OPTIONAL
	WSDATA   cLANGCODE                 AS string OPTIONAL
	WSDATA   cCLAIMTYPE                AS string OPTIONAL
	WSDATA   cSUBCLAIMTYPE             AS string OPTIONAL
	WSDATA   cLIFETIME                 AS string OPTIONAL
	WSDATA   cDEALERACCOUNT            AS string OPTIONAL
	WSDATA   cWO                       AS string OPTIONAL
	WSDATA   cSEG                      AS string OPTIONAL
	WSDATA   cAPPLICATION              AS string OPTIONAL
	WSDATA   cAUTHORIZATIONNO          AS string OPTIONAL
	WSDATA   cINSTALLEDBY              AS string OPTIONAL
	WSDATA   cMODEL                    AS string OPTIONAL
	WSDATA   cMODELSERIALNO            AS string OPTIONAL
	WSDATA   cPIPNO                    AS string OPTIONAL
	WSDATA   cINSTALLDATE              AS string OPTIONAL
	WSDATA   cAMTUSE                   AS string OPTIONAL
	WSDATA   cUSEINDICATOR             AS string OPTIONAL
	WSDATA   cFAILUREDATE              AS string OPTIONAL
	WSDATA   cDLRCLAIMNO               AS string OPTIONAL
	WSDATA   cOWNERSTATCD              AS string OPTIONAL
	WSDATA   cKEYPARTNO                AS string OPTIONAL
	WSDATA   cMAINTPLAN                AS string OPTIONAL
	WSDATA   cSERVINTTYPE              AS string OPTIONAL
	WSDATA   cPARTSUSE                 AS string OPTIONAL
	WSDATA   cPARTSUSEIND              AS string OPTIONAL
	WSDATA   cPONUMB                   AS string OPTIONAL
	WSDATA   cREFNO3                   AS string OPTIONAL
	WSDATA   cRETAILNAME               AS string OPTIONAL
	WSDATA   cSTORENO                  AS string OPTIONAL
	WSDATA   cTESTRESULT               AS string OPTIONAL
	WSDATA   cFAILURETYPE              AS string OPTIONAL
	WSDATA   cFAILURETYPECOMMENTS      AS string OPTIONAL
	WSDATA   cLUGHT                    AS string OPTIONAL
	WSDATA   cLUGHTUSEIND              AS string OPTIONAL
	WSDATA   cFAILUREAREA              AS string OPTIONAL
	WSDATA   cDOWNTIMEIND              AS string OPTIONAL
	WSDATA   cDTACCASE                 AS string OPTIONAL
	WSDATA   cDTACSOL                  AS string OPTIONAL
	WSDATA   cCOMPSERNO                AS string OPTIONAL
	WSDATA   cINVOICENO                AS string OPTIONAL
	WSDATA   cREPAIRDATE               AS string OPTIONAL
	WSDATA   cPOLICY                   AS string OPTIONAL
	WSDATA   nCUSTAMT                  AS float OPTIONAL
	WSDATA   nDLRAMT                   AS float OPTIONAL
	WSDATA   nCOAMT                    AS float OPTIONAL
	WSDATA   cBASISFORSETTLEMENT       AS string OPTIONAL
	WSDATA   cCAUSE                    AS string OPTIONAL
	WSDATA   cCOMPLAINT                AS string OPTIONAL
	WSDATA   cCORRECTION               AS string OPTIONAL
	WSDATA   cNOTRAVEL                 AS string OPTIONAL
	WSDATA   cMACHINETYPE              AS string OPTIONAL
	WSDATA   cGOODSINSTALLATION        AS string OPTIONAL
	WSDATA   cDBS_ID                   AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SaveClaim_INPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SaveClaim_INPUT
	::cMSGVERSION          := ""
	::cLANGCODE            := ""
	::cCLAIMTYPE           := ""
	::cSUBCLAIMTYPE        := ""
	::cLIFETIME            := ""
	::cDEALERACCOUNT       := ""
	::cWO                  := ""
	::cSEG                 := ""
	::cAPPLICATION         := ""
	::cAUTHORIZATIONNO     := ""
	::cINSTALLEDBY         := ""
	::cMODEL               := ""
	::cMODELSERIALNO       := ""
	::cPIPNO               := ""
	::cINSTALLDATE         := ""
	::cAMTUSE              := ""
	::cUSEINDICATOR        := ""
	::cFAILUREDATE         := ""
	::cDLRCLAIMNO          := ""
	::cOWNERSTATCD         := ""
	::cKEYPARTNO           := ""
	::cMAINTPLAN           := ""
	::cSERVINTTYPE         := ""
	::cPARTSUSE            := ""
	::cPARTSUSEIND         := ""
	::cPONUMB              := ""
	::cREFNO3              := ""
	::cRETAILNAME          := ""
	::cSTORENO             := ""
	::cTESTRESULT          := ""
	::cFAILURETYPE         := ""
	::cFAILURETYPECOMMENTS := ""
	::cLUGHT               := ""
	::cLUGHTUSEIND         := ""
	::cFAILUREAREA         := ""
	::cDOWNTIMEIND         := ""
	::cDTACCASE            := ""
	::cDTACSOL             := ""
	::cCOMPSERNO           := ""
	::cINVOICENO           := ""
	::cREPAIRDATE          := ""
	::cPOLICY              := ""
	::nCUSTAMT             := 0
	::nDLRAMT              := 0
	::nCOAMT               := 0
	::cBASISFORSETTLEMENT  := ""
	::cCAUSE               := ""
	::cCOMPLAINT           := ""
	::cCORRECTION          := ""
	::cNOTRAVEL            := ""
	::cMACHINETYPE         := ""
	::cGOODSINSTALLATION   := ""
	::cDBS_ID              := ""
Return

WSMETHOD SOAPSEND WSCLIENT JD_SaveClaim_INPUT
	Local cSoap := ""
	cSoap += IIf( !Empty(::cMSGVERSION) , WSSoapValue("MSGVERSION", ::cMSGVERSION, ::cMSGVERSION , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cLANGCODE) , WSSoapValue("LANGCODE", ::cLANGCODE, ::cLANGCODE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cCLAIMTYPE) , WSSoapValue("CLAIMTYPE", ::cCLAIMTYPE, ::cCLAIMTYPE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cSUBCLAIMTYPE) , WSSoapValue("SUBCLAIMTYPE", ::cSUBCLAIMTYPE, ::cSUBCLAIMTYPE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cLIFETIME) , WSSoapValue("LIFETIME", ::cLIFETIME, ::cLIFETIME , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cDEALERACCOUNT) , WSSoapValue("DEALERACCOUNT", ::cDEALERACCOUNT, ::cDEALERACCOUNT , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cWO) , WSSoapValue("WO", ::cWO, ::cWO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cSEG) , WSSoapValue("SEG", ::cSEG, ::cSEG , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cAPPLICATION) , WSSoapValue("APPLICATION", ::cAPPLICATION, ::cAPPLICATION , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cAUTHORIZATIONNO) , WSSoapValue("AUTHORIZATIONNO", ::cAUTHORIZATIONNO, ::cAUTHORIZATIONNO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cINSTALLEDBY) , WSSoapValue("INSTALLEDBY", ::cINSTALLEDBY, ::cINSTALLEDBY , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cMODEL) , WSSoapValue("MODEL", ::cMODEL, ::cMODEL , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cMODELSERIALNO) , WSSoapValue("MODELSERIALNO", ::cMODELSERIALNO, ::cMODELSERIALNO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cPIPNO) , WSSoapValue("PIPNO", ::cPIPNO, ::cPIPNO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cINSTALLDATE) , WSSoapValue("INSTALLDATE", ::cINSTALLDATE, ::cINSTALLDATE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cAMTUSE) , WSSoapValue("AMTUSE", ::cAMTUSE, ::cAMTUSE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cUSEINDICATOR) , WSSoapValue("USEINDICATOR", ::cUSEINDICATOR, ::cUSEINDICATOR , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cFAILUREDATE) , WSSoapValue("FAILUREDATE", ::cFAILUREDATE, ::cFAILUREDATE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cDLRCLAIMNO) , WSSoapValue("DLRCLAIMNO", ::cDLRCLAIMNO, ::cDLRCLAIMNO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cOWNERSTATCD) , WSSoapValue("OWNERSTATCD", ::cOWNERSTATCD, ::cOWNERSTATCD , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cKEYPARTNO) , WSSoapValue("KEYPARTNO", ::cKEYPARTNO, ::cKEYPARTNO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cMAINTPLAN) , WSSoapValue("MAINTPLAN", ::cMAINTPLAN, ::cMAINTPLAN , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cSERVINTTYPE) , WSSoapValue("SERVINTTYPE", ::cSERVINTTYPE, ::cSERVINTTYPE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cPARTSUSE) , WSSoapValue("PARTSUSE", ::cPARTSUSE, ::cPARTSUSE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cPARTSUSEIND) , WSSoapValue("PARTSUSEIND", ::cPARTSUSEIND, ::cPARTSUSEIND , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cPONUMB) , WSSoapValue("PONUMB", ::cPONUMB, ::cPONUMB , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cREFNO3) , WSSoapValue("REFNO3", ::cREFNO3, ::cREFNO3 , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cRETAILNAME) , WSSoapValue("RETAILNAME", ::cRETAILNAME, ::cRETAILNAME , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cSTORENO) , WSSoapValue("STORENO", ::cSTORENO, ::cSTORENO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cTESTRESULT) , WSSoapValue("TESTRESULT", ::cTESTRESULT, ::cTESTRESULT , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cFAILURETYPE) , WSSoapValue("FAILURETYPE", ::cFAILURETYPE, ::cFAILURETYPE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cFAILURETYPECOMMENTS) , WSSoapValue("FAILURETYPECOMMENTS", ::cFAILURETYPECOMMENTS, ::cFAILURETYPECOMMENTS , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cLUGHT) , WSSoapValue("LUGHT", ::cLUGHT, ::cLUGHT , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cLUGHTUSEIND) , WSSoapValue("LUGHTUSEIND", ::cLUGHTUSEIND, ::cLUGHTUSEIND , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cFAILUREAREA) , WSSoapValue("FAILUREAREA", ::cFAILUREAREA, ::cFAILUREAREA , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cDOWNTIMEIND) , WSSoapValue("DOWNTIMEIND", ::cDOWNTIMEIND, ::cDOWNTIMEIND , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cDTACCASE) , WSSoapValue("DTACCASE", ::cDTACCASE, ::cDTACCASE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cDTACSOL) , WSSoapValue("DTACSOL", ::cDTACSOL, ::cDTACSOL , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cCOMPSERNO) , WSSoapValue("COMPSERNO", ::cCOMPSERNO, ::cCOMPSERNO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cINVOICENO) , WSSoapValue("INVOICENO", ::cINVOICENO, ::cINVOICENO , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cREPAIRDATE) , WSSoapValue("REPAIRDATE", ::cREPAIRDATE, ::cREPAIRDATE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cPOLICY) , WSSoapValue("POLICY", ::cPOLICY, ::cPOLICY , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::nCUSTAMT) , WSSoapValue("CUSTAMT", ::nCUSTAMT, ::nCUSTAMT , "float", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::nDLRAMT) , WSSoapValue("DLRAMT", ::nDLRAMT, ::nDLRAMT , "float", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::nCOAMT) , WSSoapValue("COAMT", ::nCOAMT, ::nCOAMT , "float", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cBASISFORSETTLEMENT) , WSSoapValue("BASISFORSETTLEMENT", ::cBASISFORSETTLEMENT, ::cBASISFORSETTLEMENT , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cCAUSE) , WSSoapValue("CAUSE", ::cCAUSE, ::cCAUSE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cCOMPLAINT) , WSSoapValue("COMPLAINT", ::cCOMPLAINT, ::cCOMPLAINT , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cCORRECTION) , WSSoapValue("CORRECTION", ::cCORRECTION, ::cCORRECTION , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cNOTRAVEL) , WSSoapValue("NOTRAVEL", ::cNOTRAVEL, ::cNOTRAVEL , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cMACHINETYPE) , WSSoapValue("MACHINETYPE", ::cMACHINETYPE, ::cMACHINETYPE , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cGOODSINSTALLATION) , WSSoapValue("GOODSINSTALLATION", ::cGOODSINSTALLATION, ::cGOODSINSTALLATION , "string", .F. , .F., 0 , NIL, .F.) , "")
	cSoap += IIf( !Empty(::cDBS_ID) , WSSoapValue("DBS_ID", ::cDBS_ID, ::cDBS_ID , "string", .F. , .F., 0 , NIL, .F.) , "")
Return cSoap

// WSDL Data Structure REPLACEPART

WSSTRUCT JD_SaveClaim_REPLACEPART
	WSDATA   cPARTNO                   AS string OPTIONAL
	WSDATA   cALT_UOM                  AS string OPTIONAL
	WSDATA   nQTY                      AS float OPTIONAL
	WSDATA   cRPSERNO                  AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SaveClaim_REPLACEPART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SaveClaim_REPLACEPART
Return

WSMETHOD SOAPSEND WSCLIENT JD_SaveClaim_REPLACEPART
	Local cSoap := ""
	cSoap += WSSoapValue("PARTNO", ::cPARTNO, ::cPARTNO , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("ALT_UOM", ::cALT_UOM, ::cALT_UOM , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("QTY", ::nQTY, ::nQTY , "float", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("RPSERNO", ::cRPSERNO, ::cRPSERNO , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap

// WSDL Data Structure LABOR

WSSTRUCT JD_SaveClaim_LABOR
	WSDATA   cTYPE                     AS string OPTIONAL
	WSDATA   nAMT                      AS float OPTIONAL
	WSDATA   cSPGFR                    AS string OPTIONAL
	WSDATA   cSUBTYPE                  AS string OPTIONAL
	WSDATA   cTECHID                   AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SaveClaim_LABOR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SaveClaim_LABOR
Return

WSMETHOD SOAPSEND WSCLIENT JD_SaveClaim_LABOR
	Local cSoap := ""
	cSoap += WSSoapValue("TYPE", ::cTYPE, ::cTYPE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("AMT", ::nAMT, ::nAMT , "float", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("SPGFR", ::cSPGFR, ::cSPGFR , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("SUBTYPE", ::cSUBTYPE, ::cSUBTYPE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("TECHID", ::cTECHID, ::cTECHID , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap

// WSDL Data Structure OTHERCREDIT

WSSTRUCT JD_SaveClaim_OTHERCREDIT
	WSDATA   nLABOR_MATCOST            AS float OPTIONAL
	WSDATA   cDESC                     AS string OPTIONAL
	WSDATA   cLABOR_COMMENT            AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SaveClaim_OTHERCREDIT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SaveClaim_OTHERCREDIT
Return

WSMETHOD SOAPSEND WSCLIENT JD_SaveClaim_OTHERCREDIT
	Local cSoap := ""
	cSoap += WSSoapValue("LABOR_MATCOST", ::nLABOR_MATCOST, ::nLABOR_MATCOST , "float", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("DESC", ::cDESC, ::cDESC , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += IIf( !Empty(::cLABOR_COMMENT) , WSSoapValue("LABOR_COMMENT", ::cLABOR_COMMENT, ::cLABOR_COMMENT , "string", .F. , .F., 0 , NIL, .F.) , "" )
Return cSoap

// WSDL Data Structure PINS

WSSTRUCT JD_SaveClaim_PINS
	WSDATA   cPIN                      AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SaveClaim_PINS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SaveClaim_PINS
Return

WSMETHOD SOAPSEND WSCLIENT JD_SaveClaim_PINS
	Local cSoap := ""
	cSoap += WSSoapValue("PIN", ::cPIN, ::cPIN , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap



/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_SaveClaim_OUTPUT           | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Retorno                                                              |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura de retorno do envio de garantia                            |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_SaveClaim_OUTPUT
//	WSDATA   oSUCCESS                AS JD_SaveClaim_SUCCESS OPTIONAL
	WSDATA   oSUCCESS                AS JD_SUCCESS OPTIONAL
	WSDATA   oCLAIM                  AS JD_SaveClaim_CLAIM OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SaveClaim_OUTPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SaveClaim_OUTPUT
	::oCLAIM             := {} // Array Of  JD_SaveClaim_CLAIM():New()
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_SaveClaim_OUTPUT
	Local oNode1
	Local nRElem2, oNodes2, nTElem2
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_SUCCESS","SUCCESS",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode1 != NIL
		//::oSUCCESS := JD_SaveClaim_SUCCESS():New()
		::oSUCCESS := JD_SUCCESS():New()
		::oSUCCESS:SoapRecv(oNode1)
	EndIf
	oNodes2 :=  WSAdvValue( oResponse,"_CLAIM","CLAIM",{},NIL,.T.,"O",NIL,NIL)
	nTElem2 := len(oNodes2)
	For nRElem2 := 1 to nTElem2
		If !WSIsNilNode( oNodes2[nRElem2] )
			aadd(::oCLAIM , JD_SaveClaim_CLAIM():New() )
			::oCLAIM[len(::oCLAIM)]:SoapRecv(oNodes2[nRElem2])
		Endif
	Next
Return

// WSDL Data Structure SUCCESS

//WSSTRUCT JD_SaveClaim_SUCCESS
//	WSDATA   cTYPE                     AS string OPTIONAL
//	WSDATA   cID                       AS string OPTIONAL
//	WSDATA   nRESCODE                  AS integer OPTIONAL
//	WSDATA   cRESDESC                  AS string OPTIONAL
//	WSDATA   cLOG_NO                   AS string OPTIONAL
//	WSDATA   cLOG_MSG_NO               AS string OPTIONAL
//	WSDATA   cMESSAGE_V1               AS string OPTIONAL
//	WSDATA   cMESSAGE_V2               AS string OPTIONAL
//	WSDATA   cMESSAGE_V3               AS string OPTIONAL
//	WSDATA   cMESSAGE_V4               AS string OPTIONAL
//	WSDATA   cPARAMETER                AS string OPTIONAL
//	WSDATA   nROW                      AS integer OPTIONAL
//	WSDATA   cFIELD                    AS string OPTIONAL
//	WSDATA   cSYSTEM                   AS string OPTIONAL
//	WSMETHOD NEW
//	WSMETHOD INIT
//
//	WSMETHOD SOAPRECV
//ENDWSSTRUCT
//
//WSMETHOD NEW WSCLIENT JD_SaveClaim_SUCCESS
//	::Init()
//Return Self
//
//WSMETHOD INIT WSCLIENT JD_SaveClaim_SUCCESS
//Return
//
//WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_SaveClaim_SUCCESS
//	::Init()
//	If oResponse = NIL ; Return ; Endif
//	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::nRESCODE           :=  WSAdvValue( oResponse,"_RESCODE","integer",NIL,NIL,NIL,"N",NIL,NIL)
//	::cRESDESC           :=  WSAdvValue( oResponse,"_RESDESC","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cLOG_NO            :=  WSAdvValue( oResponse,"_LOG_NO","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cLOG_MSG_NO        :=  WSAdvValue( oResponse,"_LOG_MSG_NO","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cMESSAGE_V1        :=  WSAdvValue( oResponse,"_MESSAGE_V1","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cMESSAGE_V2        :=  WSAdvValue( oResponse,"_MESSAGE_V2","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cMESSAGE_V3        :=  WSAdvValue( oResponse,"_MESSAGE_V3","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cMESSAGE_V4        :=  WSAdvValue( oResponse,"_MESSAGE_V4","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cPARAMETER         :=  WSAdvValue( oResponse,"_PARAMETER","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::nROW               :=  WSAdvValue( oResponse,"_ROW","integer",NIL,NIL,NIL,"N",NIL,NIL)
//	::cFIELD             :=  WSAdvValue( oResponse,"_FIELD","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cSYSTEM            :=  WSAdvValue( oResponse,"_SYSTEM","string",NIL,NIL,NIL,"S",NIL,NIL)
//Return

// WSDL Data Structure CLAIM
WSSTRUCT JD_SaveClaim_CLAIM
	WSDATA   cWO                       AS string OPTIONAL
	WSDATA   cSEG                      AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_SaveClaim_CLAIM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_SaveClaim_CLAIM
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_SaveClaim_CLAIM
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cWO                :=  WSAdvValue( oResponse,"_WO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSEG               :=  WSAdvValue( oResponse,"_SEG","string",NIL,NIL,NIL,"S",NIL,NIL)
Return




/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_RetrieveClaim_INPUT        | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Envio                                                                |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura de envio utilizada na consulta de inf. de garantia         |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_RetrieveClaim_INPUT
	WSDATA   cMSGVERSION               AS string OPTIONAL
	WSDATA   cLANGCODE                 AS string OPTIONAL
	WSDATA   cDEALERACCOUNT            AS string OPTIONAL
	WSDATA   cWO                       AS string OPTIONAL
	WSDATA   cSEG                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveClaim_INPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveClaim_INPUT
Return

WSMETHOD SOAPSEND WSCLIENT JD_RetrieveClaim_INPUT
	Local cSoap := ""
	cSoap += WSSoapValue("MSGVERSION", ::cMSGVERSION, ::cMSGVERSION , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("LANGCODE", ::cLANGCODE, ::cLANGCODE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("DEALERACCOUNT", ::cDEALERACCOUNT, ::cDEALERACCOUNT , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("WO", ::cWO, ::cWO , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("SEG", ::cSEG, ::cSEG , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap

/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_RetrieveClaim_OUTPUT       | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Retorno                                                              |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura de retorno utilizada na consulta de inf. de garantia       |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_RetrieveClaim_OUTPUT
	WSDATA   oSUCCESS                AS JD_SUCCESS OPTIONAL
	WSDATA   oCLAIM                  AS JD_RetrieveClaim_CLAIM OPTIONAL
	WSDATA   oREPLACEPART            AS JD_RetrieveClaim_REPLACEPART OPTIONAL
	WSDATA   oLABOR                  AS JD_RetrieveClaim_LABOR OPTIONAL
	WSDATA   oOTHERCREDIT            AS JD_RetrieveClaim_OTHERCREDIT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveClaim_OUTPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveClaim_OUTPUT
	::oCLAIM             := {} // Array Of  JD_RetrieveClaim_CLAIM():New()
	::oREPLACEPART       := {} // Array Of  JD_RetrieveClaim_REPLACEPART():New()
	::oLABOR             := {} // Array Of  JD_RetrieveClaim_LABOR():New()
	::oOTHERCREDIT       := {} // Array Of  JD_RetrieveClaim_OTHERCREDIT():New()
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveClaim_OUTPUT
	Local oNode1
	Local nRElem2, oNodes2, nTElem2
	Local nRElem3, oNodes3, nTElem3
	Local nRElem4, oNodes4, nTElem4
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_SUCCESS","SUCCESS",NIL,NIL,NIL,"O",NIL,"tns")
	If oNode1 != NIL
		::oSUCCESS := JD_SUCCESS():New()
		::oSUCCESS:SoapRecv(oNode1)
	EndIf
	oNodes2 :=  WSAdvValue( oResponse,"_CLAIM","CLAIM",{},NIL,.T.,"O",NIL,"tns")
	nTElem2 := len(oNodes2)
	For nRElem2 := 1 to nTElem2
		If !WSIsNilNode( oNodes2[nRElem2] )
			aadd(::oCLAIM , JD_RetrieveClaim_CLAIM():New() )
			::oCLAIM[len(::oCLAIM)]:SoapRecv(oNodes2[nRElem2])
		Endif
	Next
	oNodes3 :=  WSAdvValue( oResponse,"_REPLACEPART","REPLACEPART",{},NIL,.T.,"O",NIL,"tns")
	nTElem3 := len(oNodes3)
	For nRElem3 := 1 to nTElem3
		If !WSIsNilNode( oNodes3[nRElem3] )
			aadd(::oREPLACEPART , JD_RetrieveClaim_REPLACEPART():New() )
			::oREPLACEPART[len(::oREPLACEPART)]:SoapRecv(oNodes3[nRElem3])
		Endif
	Next
	oNodes4 :=  WSAdvValue( oResponse,"_LABOR","LABOR",{},NIL,.T.,"O",NIL,"tns")
	nTElem4 := len(oNodes4)
	For nRElem4 := 1 to nTElem4
		If !WSIsNilNode( oNodes4[nRElem4] )
			aadd(::oLABOR , JD_RetrieveClaim_LABOR():New() )
			::oLABOR[len(::oLABOR)]:SoapRecv(oNodes4[nRElem4])
		Endif
	Next
	oNodes5 :=  WSAdvValue( oResponse,"_OTHERCREDIT","OTHERCREDIT",{},NIL,.T.,"O",NIL,"tns")
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oOTHERCREDIT , JD_RetrieveClaim_OTHERCREDIT():New() )
			::oOTHERCREDIT[len(::oOTHERCREDIT)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
Return

// WSDL Data Structure CLAIM

WSSTRUCT JD_RetrieveClaim_CLAIM
	WSDATA   cSAPCLAIMNO               AS string OPTIONAL
	WSDATA   cCLAIMTYPE                AS string OPTIONAL
	WSDATA   cSUBCLAIMTYPE             AS string OPTIONAL
	WSDATA   cLIFETIME                 AS string OPTIONAL
	WSDATA   cDEALERACCOUNT            AS string OPTIONAL
	WSDATA   cWO                       AS string OPTIONAL
	WSDATA   cSEG                      AS string OPTIONAL
	WSDATA   dOPENDATE                 AS date OPTIONAL
	WSDATA   dSUBDATE                  AS date OPTIONAL
	WSDATA   dRETDATE                  AS date OPTIONAL
	WSDATA   dMODIFYDATE               AS date OPTIONAL
	WSDATA   cCRMEMO                   AS string OPTIONAL
	WSDATA   cSTATUS                   AS string OPTIONAL
	WSDATA   cAPPLICATION              AS string OPTIONAL
	WSDATA   cAUTHORIZATIONNO          AS string OPTIONAL
	WSDATA   cINSTALLEDBY              AS string OPTIONAL
	WSDATA   cPIN                      AS string OPTIONAL
	WSDATA   cMODEL                    AS string OPTIONAL
	WSDATA   cMODELSERIALNO            AS string OPTIONAL
	WSDATA   cPIPNO                    AS string OPTIONAL
	WSDATA   cINSTALLDATE              AS string OPTIONAL
	WSDATA   cAMTUSE                   AS string OPTIONAL
	WSDATA   cUSEINDICATOR             AS string OPTIONAL
	WSDATA   cFAILUREDATE              AS string OPTIONAL
	WSDATA   cDLRCLAIMNO               AS string OPTIONAL
	WSDATA   cOWNERSTATCD              AS string OPTIONAL
	WSDATA   cKEYPARTNO                AS string OPTIONAL
	WSDATA   cMAINTPLAN                AS string OPTIONAL
	WSDATA   cSERVINT                  AS string OPTIONAL
	WSDATA   cPARTSUSE                 AS string OPTIONAL
	WSDATA   cPARTSUSEIND              AS string OPTIONAL
	WSDATA   cPONUMB                   AS string OPTIONAL
	WSDATA   cREFNO3                   AS string OPTIONAL
	WSDATA   cRETAILNAME               AS string OPTIONAL
	WSDATA   cSTORENO                  AS string OPTIONAL
	WSDATA   cTESTRESULT               AS string OPTIONAL
	WSDATA   cFAILURETYPE              AS string OPTIONAL
	WSDATA   cFAILURETYPECOMMENTS      AS string OPTIONAL
	WSDATA   nLUGHT                    AS decimal OPTIONAL
	WSDATA   cLUGHTUSEIND              AS string OPTIONAL
	WSDATA   cFAILUREAREA              AS string OPTIONAL
	WSDATA   cDOWNTIMEIND              AS string OPTIONAL
	WSDATA   cDTACCASE                 AS string OPTIONAL
	WSDATA   cDTACSOL                  AS string OPTIONAL
	WSDATA   cCOMPSERNO                AS string OPTIONAL
	WSDATA   cINVOICENO                AS string OPTIONAL
	WSDATA   cREPAIRDATE               AS string OPTIONAL
	WSDATA   cPOLICY                   AS string OPTIONAL
	WSDATA   nCUSTAMT                  AS float OPTIONAL
	WSDATA   nDLRAMT                   AS float OPTIONAL
	WSDATA   nCOAMT                    AS float OPTIONAL
	WSDATA   cBASISFORSETTLEMENT       AS string OPTIONAL
	WSDATA   cCAUSE                    AS string OPTIONAL
	WSDATA   cCOMPLAINT                AS string OPTIONAL
	WSDATA   cCORRECTION               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveClaim_CLAIM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveClaim_CLAIM
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveClaim_CLAIM
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cSAPCLAIMNO        :=  WSAdvValue( oResponse,"_SAPCLAIMNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cCLAIMTYPE         :=  WSAdvValue( oResponse,"_CLAIMTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSUBCLAIMTYPE      :=  WSAdvValue( oResponse,"_SUBCLAIMTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cLIFETIME          :=  WSAdvValue( oResponse,"_LIFETIME","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cDEALERACCOUNT     :=  WSAdvValue( oResponse,"_DEALERACCOUNT","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cWO                :=  WSAdvValue( oResponse,"_WO","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cSEG               :=  WSAdvValue( oResponse,"_SEG","string",NIL,NIL,NIL,"S",NIL,"tns")
	::dOPENDATE          :=  StoD(WSAdvValue( oResponse,"_OPENDATE","string","",NIL,NIL,"S",NIL,NIL))
	::dSUBDATE           :=  StoD(WSAdvValue( oResponse,"_SUBDATE","string","",NIL,NIL,"S",NIL,NIL))
	::dRETDATE           :=  StoD(WSAdvValue( oResponse,"_RETDATE","string","",NIL,NIL,"S",NIL,NIL))
	::dMODIFYDATE        :=  StoD(WSAdvValue( oResponse,"_MODIFYDATE","string","",NIL,NIL,"S",NIL,NIL))
	::cCRMEMO            :=  WSAdvValue( oResponse,"_CRMEMO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSTATUS            :=  PadL(WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL),2,"0")
	::cAPPLICATION       :=  WSAdvValue( oResponse,"_APPLICATION","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cAUTHORIZATIONNO   :=  WSAdvValue( oResponse,"_AUTHORIZATIONNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cINSTALLEDBY       :=  WSAdvValue( oResponse,"_INSTALLEDBY","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPIN               :=  WSAdvValue( oResponse,"_PIN","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMODEL             :=  WSAdvValue( oResponse,"_MODEL","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMODELSERIALNO     :=  WSAdvValue( oResponse,"_MODELSERIALNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPIPNO             :=  WSAdvValue( oResponse,"_PIPNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cINSTALLDATE       :=  WSAdvValue( oResponse,"_INSTALLDATE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cAMTUSE            :=  WSAdvValue( oResponse,"_AMTUSE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cUSEINDICATOR      :=  WSAdvValue( oResponse,"_USEINDICATOR","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cFAILUREDATE       :=  WSAdvValue( oResponse,"_FAILUREDATE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cDLRCLAIMNO        :=  WSAdvValue( oResponse,"_DLRCLAIMNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cOWNERSTATCD       :=  WSAdvValue( oResponse,"_OWNERSTATCD","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cKEYPARTNO         :=  WSAdvValue( oResponse,"_KEYPARTNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cMAINTPLAN         :=  WSAdvValue( oResponse,"_MAINTPLAN","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSERVINT           :=  WSAdvValue( oResponse,"_SERVINT","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPARTSUSE          :=  WSAdvValue( oResponse,"_PARTSUSE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPARTSUSEIND       :=  WSAdvValue( oResponse,"_PARTSUSEIND","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPONUMB            :=  WSAdvValue( oResponse,"_PONUMB","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cREFNO3            :=  WSAdvValue( oResponse,"_REFNO3","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cRETAILNAME        :=  WSAdvValue( oResponse,"_RETAILNAME","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSTORENO           :=  WSAdvValue( oResponse,"_STORENO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cTESTRESULT        :=  WSAdvValue( oResponse,"_TESTRESULT","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cFAILURETYPE       :=  WSAdvValue( oResponse,"_FAILURETYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cFAILURETYPECOMMENTS :=  WSAdvValue( oResponse,"_FAILURETYPECOMMENTS","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nLUGHT             :=  WSAdvValue( oResponse,"_LUGHT","decimal",NIL,NIL,NIL,"N",NIL,NIL)
	::cLUGHTUSEIND       :=  WSAdvValue( oResponse,"_LUGHTUSEIND","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cFAILUREAREA       :=  WSAdvValue( oResponse,"_FAILUREAREA","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cDOWNTIMEIND       :=  WSAdvValue( oResponse,"_DOWNTIMEIND","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cDTACCASE          :=  WSAdvValue( oResponse,"_DTACCASE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cDTACSOL           :=  WSAdvValue( oResponse,"_DTACSOL","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cCOMPSERNO         :=  WSAdvValue( oResponse,"_COMPSERNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cINVOICENO         :=  WSAdvValue( oResponse,"_INVOICENO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cREPAIRDATE        :=  WSAdvValue( oResponse,"_REPAIRDATE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cPOLICY            :=  WSAdvValue( oResponse,"_POLICY","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nCUSTAMT           :=  WSAdvValue( oResponse,"_CUSTAMT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nDLRAMT            :=  WSAdvValue( oResponse,"_DLRAMT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nCOAMT             :=  WSAdvValue( oResponse,"_COAMT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cBASISFORSETTLEMENT :=  WSAdvValue( oResponse,"_BASISFORSETTLEMENT","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cCAUSE             :=  WSAdvValue( oResponse,"_CAUSE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cCOMPLAINT         :=  WSAdvValue( oResponse,"_COMPLAINT","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cCORRECTION        :=  WSAdvValue( oResponse,"_CORRECTION","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure REPLACEPART

WSSTRUCT JD_RetrieveClaim_REPLACEPART
	WSDATA   cSAPCLAIMNO               AS string OPTIONAL
	WSDATA   nQTY                      AS float OPTIONAL
	WSDATA   cPARTNO                   AS string OPTIONAL
	WSDATA   cRPSERNO                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveClaim_REPLACEPART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveClaim_REPLACEPART
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveClaim_REPLACEPART
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cSAPCLAIMNO        :=  WSAdvValue( oResponse,"_SAPCLAIMNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nQTY               :=  WSAdvValue( oResponse,"_QTY","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cPARTNO            :=  WSAdvValue( oResponse,"_PARTNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cRPSERNO           :=  WSAdvValue( oResponse,"_RPSERNO","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure LABOR

WSSTRUCT JD_RetrieveClaim_LABOR
	WSDATA   cSAPCLAIMNO               AS string OPTIONAL
	WSDATA   cTYPE                     AS string OPTIONAL
	WSDATA   cSUBTYPE                  AS string OPTIONAL
	WSDATA   cSPGFR                    AS string OPTIONAL
	WSDATA   nAMT                      AS float OPTIONAL
	WSDATA   cTECHID                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveClaim_LABOR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveClaim_LABOR
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveClaim_LABOR
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cSAPCLAIMNO        :=  WSAdvValue( oResponse,"_SAPCLAIMNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSUBTYPE           :=  WSAdvValue( oResponse,"_SUBTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSPGFR             :=  WSAdvValue( oResponse,"_SPGFR","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nAMT               :=  WSAdvValue( oResponse,"_AMT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cTECHID            :=  WSAdvValue( oResponse,"_TECHID","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

// WSDL Data Structure OTHERCREDIT

WSSTRUCT JD_RetrieveClaim_OTHERCREDIT
	WSDATA   cSAPCLAIMNO               AS string OPTIONAL
	WSDATA   cDESC                     AS string OPTIONAL
	WSDATA   nLABOR_MATCOST            AS float OPTIONAL
	WSDATA   cLABOR_COMMENT            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveClaim_OTHERCREDIT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveClaim_OTHERCREDIT
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveClaim_OTHERCREDIT
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cSAPCLAIMNO        :=  WSAdvValue( oResponse,"_SAPCLAIMNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cDESC              :=  WSAdvValue( oResponse,"_DESC","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nLABOR_MATCOST     :=  WSAdvValue( oResponse,"_LABOR_MATCOST","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cLABOR_COMMENT     :=  WSAdvValue( oResponse,"_LABOR_COMMENT","string",NIL,NIL,NIL,"S",NIL,NIL)
Return







/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_UpdateDealerInvoice_INPUT  | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Envio                                                                |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura de envio utilizada na atualizacao de Nota Fiscal           |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_UpdateDealerInvoice_INPUT
	WSDATA   cMSGVERSION               AS string OPTIONAL
	WSDATA   cLANGCODE                 AS string OPTIONAL
	WSDATA   cSAPCLAIMNO               AS string OPTIONAL
	WSDATA   cDLRINVNO                 AS string OPTIONAL
	WSDATA   cDLRINVDT                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_UpdateDealerInvoice_INPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_UpdateDealerInvoice_INPUT
Return

WSMETHOD SOAPSEND WSCLIENT JD_UpdateDealerInvoice_INPUT
	Local cSoap := ""
	cSoap += WSSoapValue("MSGVERSION", ::cMSGVERSION, ::cMSGVERSION , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("LANGCODE", ::cLANGCODE, ::cLANGCODE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("SAPCLAIMNO", ::cSAPCLAIMNO, ::cSAPCLAIMNO , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("DLRINVNO", ::cDLRINVNO, ::cDLRINVNO , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("DLRINVDT", ::cDLRINVDT, ::cDLRINVDT , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap


/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_UpdateDealerInvoice_OUTPUT | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Retorno                                                              |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura de retorno utilizada na atualizacao de Nota Fiscal         |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_UpdateDealerInvoice_OUTPUT
	WSDATA   oSUCCESS                AS JD_SUCCESS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_UpdateDealerInvoice_OUTPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_UpdateDealerInvoice_OUTPUT
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_UpdateDealerInvoice_OUTPUT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_SUCCESS","SUCCESS",NIL,NIL,NIL,"O",NIL,"tns")
	If oNode1 != NIL
		::oSUCCESS := JD_SUCCESS():New()
		::oSUCCESS:SoapRecv(oNode1)
	EndIf
Return



/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_RetrieveCreditMemo_INPUT   | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Envio                                                                |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura de envio utilizada na consulta de Memo Credito             |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_RetrieveCreditMemo_INPUT
	WSDATA   cMSGVERSION               AS string OPTIONAL
	WSDATA   cLANGCODE                 AS string OPTIONAL
	WSDATA   cDEALERACCOUNT            AS string OPTIONAL
	WSDATA   cWO                       AS string OPTIONAL
	WSDATA   cSEG                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveCreditMemo_INPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveCreditMemo_INPUT
Return

WSMETHOD SOAPSEND WSCLIENT JD_RetrieveCreditMemo_INPUT
	Local cSoap := ""
	cSoap += WSSoapValue("MSGVERSION", ::cMSGVERSION, ::cMSGVERSION , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("LANGCODE", ::cLANGCODE, ::cLANGCODE , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("DEALERACCOUNT", ::cDEALERACCOUNT, ::cDEALERACCOUNT , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("WO", ::cWO, ::cWO , "string", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("SEG", ::cSEG, ::cSEG , "string", .F. , .F., 0 , NIL, .F.)
Return cSoap

/*
=======================================================================================
#######################################################################################
##+----------+-------------------------------+-------+------------+------+----------+##
##|Estrutura | JD_RetrieveCreditMemo_OUTPUT  | Autor | Takahashi  | Data | 23/04/13 |##
##+----------+-------------------------------+-------+------------+------+----------+##
##|Direcao   | Retorno                                                              |##
##+----------+----------------------------------------------------------------------+##
##|Descricao | Estrutura de retorno utilizada na atualizacao de Nota Fiscal         |##
##+----------+----------------------------------------------------------------------+##
#######################################################################################
=======================================================================================
*/
WSSTRUCT JD_RetrieveCreditMemo_OUTPUT
	WSDATA   oSUCCESS                AS JD_SUCCESS OPTIONAL
	WSDATA   oCREDITMEMO             AS JD_RetrieveCreditMemo_CREDITMEMO OPTIONAL
	WSDATA   oREPLACEPART            AS JD_RetrieveCreditMemo_REPLACEPART OPTIONAL
	WSDATA   oLABOR                  AS JD_RetrieveCreditMemo_LABOR OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveCreditMemo_OUTPUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveCreditMemo_OUTPUT
	::oREPLACEPART       := {} // Array Of  JD_RetrieveCreditMemo_REPLACEPART():New()
	::oLABOR             := {} // Array Of  JD_RetrieveCreditMemo_LABOR():New()
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveCreditMemo_OUTPUT
	Local oNode1
	Local oNode2
	Local nRElem3, oNodes3, nTElem3
	Local nRElem4, oNodes4, nTElem4
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNode1 :=  WSAdvValue( oResponse,"_SUCCESS","SUCCESS",NIL,NIL,NIL,"O",NIL,"tns")
	If oNode1 != NIL
		::oSUCCESS := JD_SUCCESS():New()
		::oSUCCESS:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_CREDITMEMO","CREDITMEMO",NIL,NIL,NIL,"O",NIL,"tns")
	If oNode2 != NIL
		::oCREDITMEMO := JD_RetrieveCreditMemo_CREDITMEMO():New()
		::oCREDITMEMO:SoapRecv(oNode2)
	EndIf
	oNodes3 :=  WSAdvValue( oResponse,"_REPLACEPART","REPLACEPART",{},NIL,.T.,"O",NIL,"tns")
	nTElem3 := len(oNodes3)
	For nRElem3 := 1 to nTElem3
		If !WSIsNilNode( oNodes3[nRElem3] )
			aadd(::oREPLACEPART , JD_RetrieveCreditMemo_REPLACEPART():New() )
			::oREPLACEPART[len(::oREPLACEPART)]:SoapRecv(oNodes3[nRElem3])
		Endif
	Next
	oNodes4 :=  WSAdvValue( oResponse,"_LABOR","LABOR",{},NIL,.T.,"O",NIL,"tns")
	nTElem4 := len(oNodes4)
	For nRElem4 := 1 to nTElem4
		If !WSIsNilNode( oNodes4[nRElem4] )
			aadd(::oLABOR , JD_RetrieveCreditMemo_LABOR():New() )
			::oLABOR[len(::oLABOR)]:SoapRecv(oNodes4[nRElem4])
		Endif
	Next
Return

// WSDL Data Structure CREDITMEMO

WSSTRUCT JD_RetrieveCreditMemo_CREDITMEMO
	WSDATA   cDEALERACCOUNT            AS string OPTIONAL
	WSDATA   cCRMEMONO                 AS string OPTIONAL
	WSDATA   cWO                       AS string OPTIONAL
	WSDATA   cSEG                      AS string OPTIONAL
	WSDATA   cPIN                      AS string OPTIONAL
	WSDATA   nPARTSALLOW               AS float OPTIONAL
	WSDATA   nLABORALLOW               AS float OPTIONAL
	WSDATA   nTRAVELCREDIT             AS float OPTIONAL
	WSDATA   nSALESTAX                 AS float OPTIONAL
	WSDATA   nOTHERCREDITAMT           AS float OPTIONAL
	WSDATA   cFAILCOMMENTS             AS string OPTIONAL
	WSDATA   nCOAMT                    AS float OPTIONAL
	WSDATA   nDEDUCTIBLE               AS float OPTIONAL
	WSDATA   nCUSTAMT                  AS float OPTIONAL
	WSDATA   nDLRAMT                   AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveCreditMemo_CREDITMEMO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveCreditMemo_CREDITMEMO
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveCreditMemo_CREDITMEMO
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cDEALERACCOUNT     :=  WSAdvValue( oResponse,"_DEALERACCOUNT","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cCRMEMONO          :=  WSAdvValue( oResponse,"_CRMEMONO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cWO                :=  WSAdvValue( oResponse,"_WO","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cSEG               :=  WSAdvValue( oResponse,"_SEG","string",NIL,NIL,NIL,"S",NIL,"tns")
	::cPIN               :=  WSAdvValue( oResponse,"_PIN","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nPARTSALLOW        :=  WSAdvValue( oResponse,"_PARTSALLOW","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nLABORALLOW        :=  WSAdvValue( oResponse,"_LABORALLOW","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nTRAVELCREDIT      :=  WSAdvValue( oResponse,"_TRAVELCREDIT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nSALESTAX          :=  WSAdvValue( oResponse,"_SALESTAX","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nOTHERCREDITAMT    :=  WSAdvValue( oResponse,"_OTHERCREDITAMT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cFAILCOMMENTS      :=  WSAdvValue( oResponse,"_FAILCOMMENTS","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nCOAMT             :=  WSAdvValue( oResponse,"_COAMT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nDEDUCTIBLE        :=  WSAdvValue( oResponse,"_DEDUCTIBLE","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nCUSTAMT           :=  WSAdvValue( oResponse,"_CUSTAMT","float",NIL,NIL,NIL,"N",NIL,NIL)
	::nDLRAMT            :=  WSAdvValue( oResponse,"_DLRAMT","float",NIL,NIL,NIL,"N",NIL,NIL)
Return

// WSDL Data Structure REPLACEPART

WSSTRUCT JD_RetrieveCreditMemo_REPLACEPART
	WSDATA   cPARTNO                   AS string OPTIONAL
	WSDATA   nQTY                      AS float OPTIONAL
	WSDATA   cEXCHCODE                 AS string OPTIONAL
	WSDATA   nPRICE                    AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveCreditMemo_REPLACEPART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveCreditMemo_REPLACEPART
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveCreditMemo_REPLACEPART
	::Init()
	If oResponse = NIL ; Return ; Endif
	::cPARTNO            :=  WSAdvValue( oResponse,"_PARTNO","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nQTY               :=  WSAdvValue( oResponse,"_QTY","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cEXCHCODE          :=  WSAdvValue( oResponse,"_EXCHCODE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nPRICE             :=  WSAdvValue( oResponse,"_PRICE","float",NIL,NIL,NIL,"N",NIL,NIL)
Return

// WSDL Data Structure LABOR

WSSTRUCT JD_RetrieveCreditMemo_LABOR
	WSDATA   nHOURS                    AS float OPTIONAL
	WSDATA   cTYPE                     AS string OPTIONAL
	WSDATA   cSUBTYPE                  AS string OPTIONAL
	WSDATA   nRATE                     AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_RetrieveCreditMemo_LABOR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_RetrieveCreditMemo_LABOR
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_RetrieveCreditMemo_LABOR
	::Init()
	If oResponse = NIL ; Return ; Endif
	::nHOURS             :=  WSAdvValue( oResponse,"_HOURS","float",NIL,NIL,NIL,"N",NIL,NIL)
	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cSUBTYPE           :=  WSAdvValue( oResponse,"_SUBTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::nRATE              :=  WSAdvValue( oResponse,"_RATE","float",NIL,NIL,NIL,"N",NIL,NIL)
Return












WSSTRUCT JD_WarrMemo_CLAIM
	WSDATA oHEADER        AS JD_WarrMemo_HEADER
	WSDATA oFORMTEXT      AS JD_WarrMemo_FORMTEXT
	WSDATA oREPLACEPART   AS JD_WarrMemo_REPLACEPART
	WSDATA oLABOR         AS JD_WarrMemo_LABOR
	WSDATA oCLAIMTOTALS   AS JD_WarrMemo_CLAIMTOTALS
	WSDATA oPRICINGDETAIL AS JD_WarrMemo_PRICINGDETAIL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV

ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_CLAIM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT JD_WarrMemo_CLAIM
	::oLABOR         := {} // Array of JD_WarrMemo_LABOR():New()
	::oREPLACEPART   := {} // Array of JD_WarrMemo_REPLACEPART():New()
	::oPRICINGDETAIL := {} // Array of JD_WarrMemo_PRICINGDETAIL():New()
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_CLAIM

	Local nRElem, oNode, nTElem

	::Init()

	If oResponse = NIL ; Return ; Endif

	oNode :=  WSAdvValue( oResponse,"_HEADER","HEADER",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oHEADER := JD_WarrMemo_HEADER():New()
		::oHEADER:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_FORMTEXT","FORMTEXT",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oFORMTEXT := JD_WarrMemo_FORMTEXT():New()
		::oFORMTEXT:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_CLAIMTOTALS","CLAIMTOTALS",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oCLAIMTOTALS := JD_WarrMemo_CLAIMTOTALS():New()
		::oCLAIMTOTALS:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_REPLACEPART","REPLACEPART",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oREPLACEPART , JD_WarrMemo_REPLACEPART():New() )
			::oREPLACEPART[len(::oREPLACEPART)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	oNode :=  WSAdvValue( oResponse,"_LABOR","LABOR",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oLABOR , JD_WarrMemo_LABOR():New() )
			::oLABOR[len(::oLABOR)]:SoapRecv(oNode[nRElem])
		Endif
	Next

	oNode :=  WSAdvValue( oResponse,"_PRICINGDETAIL","PRICINGDETAIL",{},NIL,.T.,"O",NIL,NIL)
	nTElem := len(oNode)
	For nRElem := 1 to nTElem
		If !WSIsNilNode( oNode[nRElem] )
			aadd(::oPRICINGDETAIL , JD_WarrMemo_PRICINGDETAIL():New() )
			::oPRICINGDETAIL[len(::oPRICINGDETAIL)]:SoapRecv(oNode[nRElem])
		Endif
	Next

Return









WSSTRUCT JD_WarrMemo_HEADER

	WSDATA cDEALERACCOUNT  AS string
	WSDATA cDEALERNAME     AS string
	WSDATA cWO             AS string
	WSDATA cSEG            AS string
	WSDATA cDLRCLAIMNO     AS string
	WSDATA cMEMOTYPE       AS string
	WSDATA cMEMODATE       AS string
	WSDATA cCURRENCY       AS string
	WSDATA cSALESOFFICE    AS string
	WSDATA cPIN            AS string
	WSDATA cBUILDFACT      AS string
	WSDATA cPIPNO          AS string
	WSDATA cKEYPARTNO      AS string
	WSDATA cSAPCLAIMNO     AS string
	WSDATA cCLAIMTYPE      AS string
	WSDATA dREPAIRDATE     AS string
	WSDATA cCKCCUSTID      AS string
	WSDATA cCOUNTRY        AS string
	WSDATA cDEALERVATNO    AS string
	WSDATA cHEADERCOMMENTS AS string
	WSDATA cCRMEMONO       AS string
	WSDATA cORIGMEMONO     AS string
	WSDATA cSUBCLAIMTYPE   AS string
	WSDATA cCUSTNAME       AS string

	WSDATA oDEALERINVOICE AS JD_WarrMemo_HEADER_DEALERINVOICE
	WSDATA oDEBITCLAIM    AS JD_WarrMemo_HEADER_DEBITCLAIM

	WSMETHOD NEW
	WSMETHOD SOAPRECV

ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_HEADER

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_HEADER

	Local oNode

	If oResponse = NIL ; Return ; Endif

	::cDEALERACCOUNT  := FMX_RETXML( oResponse, "_DEALERACCOUNT"   , "" )
	::cDEALERNAME     := FMX_RETXML( oResponse, "_DEALERNAME"      , "" )
	::cWO             := FMX_RETXML( oResponse, "_WO"              , "" )
	::cSEG            := FMX_RETXML( oResponse, "_SEG"             , "" )
	::cDLRCLAIMNO     := FMX_RETXML( oResponse, "_DLRCLAIMNO"      , "" )
	::cMEMOTYPE       := FMX_RETXML( oResponse, "_MEMOTYPE"        , "" )
	::cMEMODATE       := FMX_RETXML( oResponse, "_MEMODATE"        , "" )
	::cCURRENCY       := FMX_RETXML( oResponse, "_CURRENCY"        , "" )
	::cSALESOFFICE    := FMX_RETXML( oResponse, "_SALESOFFICE"     , "" )
	::cPIN            := FMX_RETXML( oResponse, "_PIN"             , "" )
	::cBUILDFACT      := FMX_RETXML( oResponse, "_BUILDFACT"       , "" )
	::cPIPNO          := FMX_RETXML( oResponse, "_PIPNO"           , "" )
	::cKEYPARTNO      := FMX_RETXML( oResponse, "_KEYPARTNO"       , "" )
	::cSAPCLAIMNO     := FMX_RETXML( oResponse, "_SAPCLAIMNO"      , "" )
	::cCLAIMTYPE      := FMX_RETXML( oResponse, "_CLAIMTYPE"       , "" )
	::dREPAIRDATE     := StoD(FMX_RETXML( oResponse, "_REPAIRDATE" , "" ) )
	::cCKCCUSTID      := FMX_RETXML( oResponse, "_CKCCUSTID"       , "" )
	::cCOUNTRY        := FMX_RETXML( oResponse, "_COUNTRY"         , "" )
	::cDEALERVATNO    := FMX_RETXML( oResponse, "_DEALERVATNO"     , "" )
	::cHEADERCOMMENTS := FMX_RETXML( oResponse, "_HEADERCOMMENTS"  , "" )
	::cCRMEMONO       := FMX_RETXML( oResponse, "_CRMEMONO"        , "" )
	::cORIGMEMONO     := FMX_RETXML( oResponse, "_ORIGMEMONO"      , "" )
	::cSUBCLAIMTYPE   := FMX_RETXML( oResponse, "_SUBCLAIMTYPE"    , "" )
	::cCUSTNAME       := FMX_RETXML( oResponse, "_CUSTNAME"        , "" )

	oNode :=  WSAdvValue( oResponse,"_DEALERINVOICE","DEALERINVOICE",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oDEALERINVOICE := JD_WarrMemo_HEADER_DEALERINVOICE():New()
		::oDEALERINVOICE:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_DEBITCLAIM","DEBITCLAIM",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oDEBITCLAIM := JD_WarrMemo_HEADER_DEBITCLAIM():New()
		::oDEBITCLAIM:SoapRecv(oNode)
	EndIf

Return


WSSTRUCT JD_WarrMemo_HEADER_DEALERINVOICE

	WSDATA cDLRINVNO AS string
	WSDATA dDLRINVDT AS date

	WSMETHOD NEW

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_HEADER_DEALERINVOICE
Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_HEADER_DEALERINVOICE

	If oResponse = NIL ; Return ; Endif

	::cDLRINVNO := FMX_RETXML( oResponse, "_DLRINVNO" , "" )
	::dDLRINVDT := StoD(FMX_RETXML( oResponse, "_DLRINVDT" , "" ))

Return


WSSTRUCT JD_WarrMemo_HEADER_DEBITCLAIM

	WSDATA cADJCODE        AS string
	WSDATA cADJDESCR       AS string
	WSDATA cINITIATEDCODE  AS string
	WSDATA cINITIATEDDESCR AS string
	WSDATA cCOMMENTS       AS string

	WSMETHOD NEW

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_HEADER_DEBITCLAIM

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_HEADER_DEBITCLAIM

	If oResponse = NIL ; Return ; Endif
//	::nHOURS             :=  WSAdvValue( oResponse,"_HOURS","float",NIL,NIL,NIL,"N",NIL,NIL)
//	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::cSUBTYPE           :=  WSAdvValue( oResponse,"_SUBTYPE","string",NIL,NIL,NIL,"S",NIL,NIL)
//	::nRATE              :=  WSAdvValue( oResponse,"_RATE","float",NIL,NIL,NIL,"N",NIL,NIL)

	::cADJCODE        := FMX_RETXML( oResponse , "_ADJCODE" , "")
	::cADJDESCR       := FMX_RETXML( oResponse , "_ADJDESCR" , "")
	::cINITIATEDCODE  := FMX_RETXML( oResponse , "_INITIATEDCODE" , "")
	::cINITIATEDDESCR := FMX_RETXML( oResponse , "_INITIATEDDESCR" , "")
	::cCOMMENTS       := FMX_RETXML( oResponse , "_COMMENTS" , "")

Return



WSSTRUCT JD_WarrMemo_FORMTEXT

	WSDATA cVARCOMMENTS  AS string
	WSDATA oMEMOTEXT AS JD_WarrMemo_FORMTEXT_MEMOTEXT

	WSMETHOD NEW
	WSMETHOD INIT

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_FORMTEXT

Return Self

WSMETHOD INIT WSCLIENT JD_WarrMemo_FORMTEXT
	//::oMEMOTEXT := JD_WarrMemo_FORMTEXT_MEMOTEXT():New()
Return

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_FORMTEXT

	Local oNode

	If oResponse = NIL ; Return ; Endif

	::cVARCOMMENTS := FMX_RETXML( oResponse , "_VARCOMMENTS" , "" )

	oNode :=  WSAdvValue( oResponse,"_MEMOTEXT","MEMOTEXT",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oMEMOTEXT := JD_WarrMemo_FORMTEXT_MEMOTEXT():New()
		::oMEMOTEXT:SoapRecv(oNode)
	EndIf


Return


WSSTRUCT JD_WarrMemo_FORMTEXT_MEMOTEXT

	WSDATA cMKTUNIT AS string
	WSDATA cCUSTOM AS string
	WSDATA cFOOTER AS string

	WSMETHOD NEW

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_FORMTEXT_MEMOTEXT

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_FORMTEXT_MEMOTEXT

	If oResponse = NIL ; Return ; Endif

	::cMKTUNIT := FMX_RETXML( oResponse , "_MKTUNIT" , "")
	::cCUSTOM  := FMX_RETXML( oResponse , "_CUSTOM" , "")
	::cFOOTER  := FMX_RETXML( oResponse , "_FOOTER" , "")

Return


WSSTRUCT JD_WarrMemo_REPLACEPART
	WSDATA cPARTNO      AS string
	WSDATA cDESCRIPTION AS string
	WSDATA nQTY         AS float
	WSDATA nPRICE       AS float
	WSDATA nTOTAL       AS float

	WSMETHOD NEW

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_REPLACEPART

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_REPLACEPART

	If oResponse = NIL ; Return ; Endif

	::cPARTNO      := FMX_RETXML( oResponse , "_PARTNO" , "" )
	::cDESCRIPTION := FMX_RETXML( oResponse , "_DESCRIPTION" , "" )
	::nQTY         := Val(FMX_RETXML( oResponse , "_QTY" , "0" ))
	::nPRICE       := Val(FMX_RETXML( oResponse , "_PRICE" , "0" ))
	::nTOTAL       := Val(FMX_RETXML( oResponse , "_TOTAL" , "0" ))

Return


WSSTRUCT JD_WarrMemo_LABOR

	WSDATA cTYPE    AS string
	WSDATA cSUBTYPE AS string
	WSDATA nHOURS   AS float
	WSDATA nRATE    AS float
	WSDATA nTOTAL   AS float

	WSMETHOD NEW

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_LABOR

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_LABOR

	If oResponse = NIL ; Return ; Endif

	::cTYPE    := FMX_RETXML( oResponse , "_TYPE" , "" )
	::cSUBTYPE := FMX_RETXML( oResponse , "_SUBTYPE" , "" )
	::nHOURS   := Val(FMX_RETXML( oResponse , "_HOURS" , "0" ))
	::nRATE    := Val(FMX_RETXML( oResponse , "_RATE"  , "0" ))
	::nTOTAL   := Val(FMX_RETXML( oResponse , "_TOTAL" , "0" ))

Return


WSSTRUCT JD_WarrMemo_CLAIMTOTALS

	WSDATA nDEDUCTIBLE  AS float
	WSDATA nSALESTAX    AS float
	WSDATA nPRETAXTOTAL AS float
	WSDATA nMEMOTOTAL   AS float

	WSDATA oPARTS AS JD_WarrMemo_CLAIMTOTALS_PARTS
	WSDATA oLABOR AS JD_WarrMemo_CLAIMTOTALS_LABOR
	WSDATA oOTHERCREDITS AS JD_WarrMemo_CLAIMTOTALS_OTHERCREDITS

	WSMETHOD NEW


	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_CLAIMTOTALS

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_CLAIMTOTALS

	If oResponse = NIL ; Return ; Endif

	::nDEDUCTIBLE  := Val(FMX_RETXML( oResponse , "_DEDUCTIBLE" , "0" ))
	::nSALESTAX    := Val(FMX_RETXML( oResponse , "_SALESTAX" , "0" ))
	::nPRETAXTOTAL := Val(FMX_RETXML( oResponse , "_PRETAXTOTAL" , "0" ))
	::nMEMOTOTAL   := Val(FMX_RETXML( oResponse , "_MEMOTOTAL" , "0" ))

	oNode :=  WSAdvValue( oResponse,"_PARTS","PARTS",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oPARTS := JD_WarrMemo_CLAIMTOTALS_PARTS():New()
		::oPARTS:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_LABOR","LABOR",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oLABOR := JD_WarrMemo_CLAIMTOTALS_LABOR():New()
		::oLABOR:SoapRecv(oNode)
	EndIf

	oNode :=  WSAdvValue( oResponse,"_OTHERCREDITS","OTHERCREDITS",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode != NIL
		::oOTHERCREDITS := JD_WarrMemo_CLAIMTOTALS_OTHERCREDITS():New()
		::oOTHERCREDITS:SoapRecv(oNode)
	EndIf

Return

WSSTRUCT JD_WarrMemo_CLAIMTOTALS_PARTS

	WSDATA nPARTSUBTOTAL   AS float
	WSDATA nPARTSALLOW     AS float
	WSDATA nPARTSSALESTAX   AS float
	WSDATA nPARTGRANDTOTAL AS float

	WSMETHOD NEW

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_CLAIMTOTALS_PARTS

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_CLAIMTOTALS_PARTS

	If oResponse = NIL ; Return ; Endif

	::nPARTSUBTOTAL   := Val(FMX_RETXML( oResponse , "_PARTSUBTOTAL" , "0" ))
	::nPARTSALLOW     := Val(FMX_RETXML( oResponse , "_PARTSALLOW" , "0" ))
	::nPARTSSALESTAX   := Val(FMX_RETXML( oResponse , "_PARTSSALESTAX" , "0" ))
	::nPARTGRANDTOTAL := Val(FMX_RETXML( oResponse , "_PARTGRANDTOTAL" , "0" ))

Return




WSSTRUCT JD_WarrMemo_CLAIMTOTALS_LABOR

	WSDATA nLABORSUBTOTAL   AS float
	WSDATA nLABORALLOW      AS float
	WSDATA nLABORSALESTAX   AS float
	WSDATA nLABORGRANDTOTAL AS float

	WSMETHOD NEW


	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_CLAIMTOTALS_LABOR

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_CLAIMTOTALS_LABOR

	If oResponse = NIL ; Return ; Endif

	::nLABORSUBTOTAL   := Val(FMX_RETXML( oResponse , "_LABORSUBTOTAL", "0"))
	::nLABORALLOW      := Val(FMX_RETXML( oResponse , "_LABORALLOW", "0"))
	::nLABORSALESTAX   := Val(FMX_RETXML( oResponse , "_LABORSALESTAX", "0"))
	::nLABORGRANDTOTAL := Val(FMX_RETXML( oResponse , "_LABORGRANDTOTAL", "0"))

Return


WSSTRUCT JD_WarrMemo_CLAIMTOTALS_OTHERCREDITS
	WSDATA nOTHSALESTAX    AS float
	WSDATA nOTHERCREDITAMT AS float
	WSDATA nTRAVELCREDIT   AS float
	WSDATA nOTHERTOTAL	   AS float

	WSMETHOD NEW

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_CLAIMTOTALS_OTHERCREDITS

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_CLAIMTOTALS_OTHERCREDITS

	If oResponse = NIL ; Return ; Endif

	::nOTHSALESTAX    := Val(FMX_RETXML( oResponse , "_OTHSALESTAX", "0"))
	::nOTHERCREDITAMT := Val(FMX_RETXML( oResponse , "_OTHERCREDITAMT", "0"))
	::nOTHERTOTAL     := Val(FMX_RETXML( oResponse , "_OTHERTOTAL", "0"))
	::nTRAVELCREDIT   := Val(FMX_RETXML( oResponse , "_TRAVELCREDIT", "0"))

Return




WSSTRUCT JD_WarrMemo_PRICINGDETAIL
	WSDATA cCONDITION   AS string
	WSDATA cDESCRIPTION AS string
	WSDATA nAMT         AS float

	WSMETHOD NEW

	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT JD_WarrMemo_PRICINGDETAIL

Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT JD_WarrMemo_PRICINGDETAIL

	If oResponse = NIL ; Return ; Endif

	::cCONDITION   := FMX_RETXML( oResponse , "_CONDITION" , "" )
	::cDESCRIPTION := FMX_RETXML( oResponse , "_DESCRIPTION" , "" )
	::nAMT         := Val(FMX_RETXML( oResponse , "_AMT" , "" ))

Return
