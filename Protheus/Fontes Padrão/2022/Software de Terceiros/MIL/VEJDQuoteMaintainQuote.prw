#include "Totvs.ch"

#include "VEJDQuoteMaintainQuote.CH"

#DEFINE lDebug .f.

Function VEJDQuoteMaintainQuote()
Return

/*/{Protheus.doc} VEJDQuoteMaintainQuote
	Classe principal para Conexao ao WebService do JDQuote

	@type function
	@author Rubens Takahashi
	@since 01/04/2019
/*/
Class VEJDQuoteMaintainQuote From VEJDQuote

	Method New() CONSTRUCTOR
	Method getQuote()
	Method getQuoteDetail()
	Method getMasterQuotes()

	Method _getCustomer()
	Method _getQuoteResponse()
	Method _getQuoteDetResponse()
	Method _getEquipmentsFromQuote()
	Method _getTradeInsFromQuote()
	Method _getMasterQuotesResponse()
	Method _getPODetails()

	Method getFromEmulator()
	Method configOkta()

	Method send()

EndClass

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Rubens Takahashi
	@since 01/04/2019
/*/
Method New() Class VEJDQuoteMaintainQuote

	::cNameHeaderToken := "JDK_TOKEN"
	//::cWSDL := "\logsmil\jdquote\MaintainQuote_Version6_6Impl.wsdl"
	::cWSDL := "http://www.itmil.com.br/john_deere/MaintainQuote_Version6_6Impl.wsdl"
	::cURLWebService := GetNewPar("MV_MIL0127","")// "https://jdquote2qual.tal.deere.com/services/MaintainQuote_Version6_6Impl"
	_Super:New()

	::lOkta := self:oOkta:oConfig:maintainQuoteJDQuote()

	If ::lOkta
		::cURLWebService := self:oOkta:oConfig:getUrlWSMaintainQuoteJDQuote()
	EndIf

Return SELF

/*/{Protheus.doc} getQuote

Executa metodo getQuote para retornar uma lista de quotacoes filtradas pelo parametro da consulta

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cMsgSend, characters, descricao
@type function
/*/
Method getQuote(cMsgSend) class VEJDQuoteMaintainQuote
	Local xRet
	::oWSDLManager:SetOperation( "getQuote" )

	cMsgSend := ;
		'<?xml version="1.0" encoding="utf-8"?>' +;
		'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://version6_6.services.view.jdquote.deere.com">' +;
			'<soapenv:Header/>' +;
			'<soapenv:Body>' +;
				'<ver:getQuote>' +;
					'<searchQuote>' +;
						cMsgSend +;
						'<dealerRacfID>' + ::cUserVAI + '</dealerRacfID>' +;
					'</searchQuote>' +;
				'</ver:getQuote>' +;
			'</soapenv:Body>' +;
		'</soapenv:Envelope>'

	xRet := ::send(cMsgSend)

	If lDebug
		Conout("getQuote")
		Conout(cMsgSend)
	EndIf

	If xRet
		::_getQuoteResponse()
	EndIf

Return xRet

/*/{Protheus.doc} getQuoteDetail

Executa methodo getWQuoteDetail para retornar informacoes detalhadas da consulta

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}
@param nQuoteId, numeric, descricao
@type function
/*/
Method getQuoteDetail(nQuoteId) class VEJDQuoteMaintainQuote
	Local xRet

	::oWSDLManager:SetOperation( "getQuoteDetail" )

	cMsgSend := ;
		'<?xml version="1.0" encoding="utf-8"?>' +;
		'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://version6_6.services.view.jdquote.deere.com">' +;
		'<soapenv:Header/>' +;
		'<soapenv:Body>' +;
			'<ver:getQuoteDetail>' +;
				'<quoteId>' + AllTrim(cValToChar(nQuoteId)) + '</quoteId>' +;
				'<leadDealerAccount>' + ::cDealerAccount + '</leadDealerAccount>' +;
			'</ver:getQuoteDetail>' +;
		'</soapenv:Body>' +;
		'</soapenv:Envelope>'

	xRet := ::send(cMsgSend)

	If lDebug
		Conout("getQuoteDetail")
		Conout(cMsgSend)
	EndIf

	If xRet
		::_getQuoteDetResponse()
	EndIf

Return xRet

/*/{Protheus.doc} getMasterQuotes

Executa metodo getMasterQuotes para retornar uma lista de quotacoes filtradas pelo parametro da consulta

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cMsgSend, characters, descricao
@type function
/*/
Method getMasterQuotes(cMsgSend) class VEJDQuoteMaintainQuote
	Local xRet
	::oWSDLManager:SetOperation( "getMasterQuotes" )

	cMsgSend := ;
		'<?xml version="1.0" encoding="utf-8"?>' +;
		'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://version6_6.services.view.jdquote.deere.com">' +;
			'<soapenv:Header/>' +;
			'<soapenv:Body>' +;
				'<ver:getMasterQuotes>' +;
					'<masterSearchCriteriaData>' +;
						cMsgSend +;
						'<dealerRacfID>' + ::cUserVAI + '</dealerRacfID>' +;
						'<errorMessage>' +;
							'<errorId></errorId>' +;
							'<errorMessage></errorMessage>' +;
						'</errorMessage>' +;
						'<statusCode></statusCode>' +;
					'</masterSearchCriteriaData>' +;
				'</ver:getMasterQuotes>' +;
			'</soapenv:Body>' +;
		'</soapenv:Envelope>'

	If lDebug
		Conout("getMasterQuotes")
		Conout(cMsgSend)
	EndIf

	xRet := ::send(cMsgSend)

	If xRet
		::_getMasterQuotesResponse()
	EndIf

Return xRet

/*/{Protheus.doc} _getQuoteResponse

Processa retorno do metodo getQuote

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method _getQuoteResponse() class VEJDQuoteMaintainQuote

	//::_LogConsole()
	::oXMLManager:DOMChildNode() // "/soapenv:Envelope/soapenv:Body"
	//::_LogConsole()
	::oXMLManager:DOMChildNode() // "/soapenv:Envelope/soapenv:Body/b:getQuoteResponse"
	//::_LogConsole()

	::aResponse := {}

	nCont := 0

	If self:oXMLManager:DOMChildNode()
		While (.t.)
			aAuxInfo := self:oXMLManager:DOMGetChildArray()

			If Len(aAuxInfo) > 1
				//Conout(cValToChar(++nCont) + " - " + cValToChar(RetXMLVal( aAuxInfo , 'quoteId'         , 'N'  , 'N' )))

				oAuxRetorno := VEJDQuoteGetQuoteResponse():New()
				oAuxRetorno:quoteId         := RetXMLVal( aAuxInfo , 'quoteId'         , 'N'  , 'N' )
				oAuxRetorno:quoteName       := RetXMLVal( aAuxInfo , 'quoteName'       , 'C'  , 'C' )
				oAuxRetorno:quoteStatus     := QuoteStatus( RetXMLVal( aAuxInfo , 'quoteStatus'     , 'C'  , 'C' ))
				oAuxRetorno:customerName    := RetXMLVal( aAuxInfo , 'customerName'    , 'C'  , 'C' )
				oAuxRetorno:quoteTotal      := RetXMLVal( aAuxInfo , 'quoteTotal'      , 'N'  , 'N' )
				oAuxRetorno:creationDate    := RetXMLVal( aAuxInfo , 'creationDate'    , 'LD' , 'D' )
				oAuxRetorno:expirationDate  := RetXMLVal( aAuxInfo , 'expirationDate'  , 'LD' , 'D' )
				oAuxRetorno:modelName       := RetXMLVal( aAuxInfo , 'modelName'       , 'C'  , 'C' )
				oAuxRetorno:quoteType       := RetXMLVal( aAuxInfo , 'quoteType'       , 'C'  , 'C' )
				oAuxRetorno:deleteIndicator := RetXMLVal( aAuxInfo , 'deleteIndicator' , 'L'  , 'L' )

				AADD(::aResponse, oAuxRetorno )

			EndIf

			If ! self:oXMLManager:DOMNextNode()
				Exit
			EndIf

		End

		self:oXMLManager:DOMParentNode()

	EndIf

Return

/*/{Protheus.doc} _getMasterQuotesResponse

Processa retorno do metodo getQuote

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method _getMasterQuotesResponse() class VEJDQuoteMaintainQuote

	//Conout(" ")
	//Conout(" ")
	//Conout(" ")

	//::_LogConsole()
	::oXMLManager:DOMChildNode() // "/S:Envelope/S:Body"
	//::_LogConsole()
	::oXMLManager:DOMChildNode() // "/S:Envelope/S:Body/ns2:getMasterQuotesResponse"
	//::_LogConsole()

	::aResponse := {}

	nCont := 0

	If self:oXMLManager:DOMChildNode()
		While (.t.)
			aAuxInfo := self:oXMLManager:DOMGetChildArray()

			If Len(aAuxInfo) > 1
				//Conout(cValToChar(++nCont) + " - " + cValToChar(RetXMLVal( aAuxInfo , 'quoteId' , 'N'  , 'N' )))

				oAuxRetorno := VEJDQuoteGetMasterQuotesResponse():New()

				oAuxRetorno:quoteId         := RetXMLVal( aAuxInfo , 'quoteId'         , 'N' , 'N' )
				oAuxRetorno:quoteName       := RetXMLVal( aAuxInfo , 'quoteName'       , 'C' , 'C' )
				oAuxRetorno:creationDate    := RetXMLVal( aAuxInfo , 'creationDate'    , 'LD' , 'D' )
				oAuxRetorno:expirationDate  := RetXMLVal( aAuxInfo , 'expirationDate'  , 'LD' , 'D' )
				oAuxRetorno:quoteType       := RetXMLVal( aAuxInfo , 'quoteType'       , 'C' , 'C' )
				oAuxRetorno:deleteIndicator := RetXMLVal( aAuxInfo , 'deleteIndicator' , 'L' , 'L' )
				
				AADD(::aResponse, oAuxRetorno )

			EndIf

			If ! self:oXMLManager:DOMNextNode()
				Exit
			EndIf

		End

		self:oXMLManager:DOMParentNode()

	EndIf

Return

Method getFromEmulator() class VEJDQuoteMaintainQuote
	Local xRet := .T.
	Local cArqXML := "/jdquote/19363554-quote-maq-oficial.xml"

	If ! ::oXMLManager:ReadFile( cArqXML , 'UTF-8' )
		conout("erro ao parsear file")
	EndIf

	If xRet
		::_getQuoteDetResponse()
	EndIf

Return xRet

/*/{Protheus.doc} _getQuoteDetResponse

Processa retorno do metodo getQuoteDetail

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method _getQuoteDetResponse() class VEJDQuoteMaintainQuote

	Local oAuxRetorno

	::oXMLManager:DOMChildNode() // "/soapenv:Envelope"
	::oXMLManager:DOMChildNode() // "/soapenv:Envelope/soapenv:Body"
	::oXMLManager:DOMChildNode() // "/soapenv:Envelope/soapenv:Body/b:getQuoteDetailResponse"

	::aResponse := {}

	If ::oXMLManager:DOMChildCount() > 1

		aAuxInfo := ::oXMLManager:DOMGetChildArray()

		oAuxRetorno := VEJDQuoteGetQuoteDetailResponse():New()
		oAuxRetorno:quoteId              := RetXMLVal(aAuxInfo, 'quoteId'              , 'C'  , 'N' )
		oAuxRetorno:quoteName            := RetXMLVal(aAuxInfo, 'quoteName'            , 'C'  , 'C' )
		oAuxRetorno:creationDate         := RetXMLVal(aAuxInfo, 'creationDate'         , 'C'  , 'D' )
		oAuxRetorno:expirationDate       := RetXMLVal(aAuxInfo, 'expirationDate'       , 'C'  , 'D' )
		oAuxRetorno:dealerAccountNumber  := RetXMLVal(aAuxInfo, 'dealerAccountNumber'  , 'C'  , 'C' )
		oAuxRetorno:lastDateModifiedDate := RetXMLVal(aAuxInfo, 'lastModifiedDate' , 'TS' , 'D' )
		oAuxRetorno:lastTimeModifiedDate := RetXMLVal(aAuxInfo, 'lastModifiedDate' , 'TS' , 'T' )
		oAuxRetorno:customerNote         := RetXMLVal(aAuxInfo, 'customerNote'         , 'C'  , 'C' )
		oAuxRetorno:totalNetTradeValue   := RetXMLVal(aAuxInfo, 'totalNetTradeValue'   , 'N'  , 'N' )
		oAuxRetorno:balanceDue           := RetXMLVal(aAuxInfo, 'balanceDue'           , 'N'  , 'N' )
		oAuxRetorno:netProceeds          := RetXMLVal(aAuxInfo, 'netProceeds'          , 'N'  , 'N' )

		If ::oXMLManager:DOMChildNode()
			While (.t.)
				aAuxInfo := ::oXMLManager:DOMGetChildArray()

				Do Case
					Case ::oXMLManager:cName == "errorMessage"
						oAuxRetorno:oErrorMessage:errorId := RetXMLVal(aAuxInfo, 'errorId' , 'N' , 'N')
						oAuxRetorno:oErrorMessage:errorMessage := RetXMLVal(aAuxInfo, 'errorMessage' , 'C' , 'C')

					Case ::oXMLManager:cName == "quoteStatus"
						oAuxRetorno:oQuoteStatus:id := RetXMLVal(aAuxInfo, 'id' , 'C' , 'C')
						oAuxRetorno:oQuoteStatus:description := QuoteStatus(RetXMLVal(aAuxInfo, 'description' , 'C' , 'C'))

					Case ::oXMLManager:cName == "quoteType"
						oAuxRetorno:oQuoteType:id := RetXMLVal(aAuxInfo, 'id' , 'C' , 'C')
						oAuxRetorno:oQuoteType:description := RetXMLVal(aAuxInfo, 'description' , 'C' , 'C')

					Case ::oXMLManager:cName == "PODetails"
						oAuxRetorno:oPODetails:deliveredOn     := RetXMLVal(aAuxInfo, 'deliveredOn'     , 'C' , 'D' )
						oAuxRetorno:oPODetails:poStatus        := RetXMLVal(aAuxInfo, 'poStatus'        , 'C' , 'C' )
						oAuxRetorno:oPODetails:purchaserType   := RetXMLVal(aAuxInfo, 'purchaserType'   , 'C' , 'C' )
						oAuxRetorno:oPODetails:signedOnDate    := RetXMLVal(aAuxInfo, 'signedOnDate'    , 'C' , 'D' )
						oAuxRetorno:oPODetails:transactionType := RetXMLVal(aAuxInfo, 'transactionType' , 'C' , 'C' )
						oAuxRetorno:oPODetails:warrantyBegins  := RetXMLVal(aAuxInfo, 'warrantyBegins'  , 'C' , 'D' )
						oAuxRetorno:oPODetails:poNumber        := RetXMLVal(aAuxInfo, 'poNumber'        , 'N' , 'N' )

					Case ::oXMLManager:cName == "salesPerson"
						oAuxRetorno:oSalesPerson:deereUserId := AllTrim(RetXMLVal(aAuxInfo, 'deereUserId' , 'C' , 'C'))
						oAuxRetorno:oSalesPerson:firstName := AllTrim(RetXMLVal(aAuxInfo, 'firstName' , 'C' , 'C'))
						oAuxRetorno:oSalesPerson:lastName := AllTrim(RetXMLVal(aAuxInfo, 'lastName' , 'C' , 'C'))
						oAuxRetorno:oSalesPerson:middleName := AllTrim(RetXMLVal(aAuxInfo, 'middleName' , 'C' , 'C'))
						oAuxRetorno:oSalesPerson:fullName := oAuxRetorno:oSalesPerson:firstName + " " + AllTrim(oAuxRetorno:oSalesPerson:middleName) + " " + oAuxRetorno:oSalesPerson:lastName
						oAuxRetorno:oSalesPerson:emailAddress := AllTrim(RetXMLVal(aAuxInfo, 'emailAddress' , 'C' , 'C'))

					Case ::oXMLManager:cName == "customer"
						self:_getCustomer(oAuxRetorno, aAuxInfo)

					Case ::oXMLManager:cName == "equipments"
						self:_getEquipmentsFromQuote(oAuxRetorno, aAuxInfo)

					Case ::oXMLManager:cName == "tradeIns"
						self:_getTradeInsFromQuote(oAuxRetorno, aAuxInfo)

				EndCase

				If ! ::oXMLManager:DOMNextNode()
					Exit
				EndIf

			End

			::oXMLManager:DOMParentNode()

		EndIf

		AADD(::aResponse, oAuxRetorno )


	EndIf
Return

/*/{Protheus.doc} _getEquipmentsFromQuote

Cria um equipamento no objeto de retorno do webserivce

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}
@param oAuxRetorno, object, descricao
@param aAuxInfo, array, descricao
@type function
/*/
Method _getEquipmentsFromQuote(oAuxRetorno, aAuxInfo) class VEJDQuoteMaintainQuote

	//    1234567890
	Local oAuxEquipment
	Local oAuxEquipOptData
	Local oAuxAdjustments

	oAuxEquipment := VEJDQuoteEquipment():New()
	oAuxEquipment:id                         := RetXMLVal( aAuxInfo , 'id'                     , 'N' , 'N' )
	oAuxEquipment:listPrice                  := RetXMLVal( aAuxInfo , 'listPrice'              , 'N' , 'N' )
	oAuxEquipment:costPrice                  := RetXMLVal( aAuxInfo , 'costPrice'              , 'N' , 'N' )
	oAuxEquipment:totalEquipmentSellingPrice := RetXMLVal( aAuxInfo , 'totalEquipmentSellingPrice' , 'N' , 'N' )
	oAuxEquipment:dealerOrderNumber          := RetXMLVal( aAuxInfo , 'dealerOrderNumber'      , 'C' , 'C' )
	oAuxEquipment:equipmentOrderNumber       := RetXMLVal( aAuxInfo , 'equipmentOrderNumber'   , 'C' , 'C' )
	oAuxEquipment:dealerStockNumber          := RetXMLVal( aAuxInfo , 'dealerStockNumber'      , 'C' , 'C' )
	oAuxEquipment:invoiceNumber              := RetXMLVal( aAuxInfo , 'invoiceNumber'          , 'C' , 'C' )
	oAuxEquipment:machineHours               := RetXMLVal( aAuxInfo , 'machineHours'           , 'C' , 'C' )
	oAuxEquipment:makeName                   := RetXMLVal( aAuxInfo , 'makeName'               , 'C' , 'C' )
	oAuxEquipment:modelName                  := RetXMLVal( aAuxInfo , 'modelName'              , 'C' , 'C' )
	oAuxEquipment:status                     := RetXMLVal( aAuxInfo , 'status'                 , 'C' , 'C' )
	oAuxEquipment:categoryId                 := RetXMLVal( aAuxInfo , 'categoryId'             , 'C' , 'C' )
	oAuxEquipment:categoryDescription        := RetXMLVal( aAuxInfo , 'categoryDescription'    , 'C' , 'C' )
	oAuxEquipment:subCategoryId              := RetXMLVal( aAuxInfo , 'subCategoryId'          , 'C' , 'C' )
	oAuxEquipment:subCategoryDescription     := RetXMLVal( aAuxInfo , 'subCategoryDescription' , 'C' , 'C' )
	oAuxEquipment:serialNumber               := RetXMLVal( aAuxInfo , 'serialNumber'           , 'C' , 'C' )

	If ::oXMLManager:DOMChildNode()
		While (.t.)
			aAuxInfo := ::oXMLManager:DOMGetChildArray()

			Do Case
				Case ::oXMLManager:cName == "equipmentOptionData"

					oAuxEquipOptData := VEJDQuoteEquipmentOptionData():New()
					oAuxEquipOptData:optionId          := RetXMLVal( aAuxInfo , 'optionId'         , 'N' , 'N' )
					oAuxEquipOptData:optionCode        := RetXMLVal( aAuxInfo , 'optionCode'       , 'C' , 'C' )
					oAuxEquipOptData:optionCostAmount  := RetXMLVal( aAuxInfo , 'optionCostAmount' , 'N' , 'N' )
					oAuxEquipOptData:optionDesc        := RetXMLVal( aAuxInfo , 'optionDesc'       , 'C' , 'C' )
					oAuxEquipOptData:optionPriceAmount := RetXMLVal( aAuxInfo , 'optionPriceAmount', 'N' , 'N' )
					oAuxEquipOptData:optionType        := RetXMLVal( aAuxInfo , 'optionType'       , 'N' , 'N' )
					AADD( oAuxEquipment:aEquiOptData , oAuxEquipOptData)

				Case ::oXMLManager:cName == "adjustments"
					oAuxAdjustments := VEJDQuoteAdjustments():New()
					oAuxAdjustments:id          := RetXMLVal( aAuxInfo , 'id'          , 'N' , 'N' )
					oAuxAdjustments:description := FwCutOff(RetXMLVal( aAuxInfo , 'description' , 'C' , 'C' ), .t.)
					oAuxAdjustments:costPrice   := RetXMLVal( aAuxInfo , 'costPrice'   , 'N' , 'N' )
					oAuxAdjustments:listPrice   := RetXMLVal( aAuxInfo , 'listPrice'   , 'N' , 'N' )
					AADD( oAuxEquipment:aAdjustments , oAuxAdjustments)

			EndCase

			If ! ::oXMLManager:DOMNextNode()
				Exit
			EndIf

		End

		::oXMLManager:DOMParentNode()

	EndIf

	AADD( oAuxRetorno:aEquipment , oAuxEquipment )

Return


Method _getCustomer(oAuxRetorno, aAuxInfo) class VEJDQuoteMaintainQuote

	oAuxRetorno:oCustomer:entityId     := RetXMLVal( aAuxInfo , 'entityId' , 'N' , 'N' )
	oAuxRetorno:oCustomer:firstName    := AllTrim( RetXMLVal( aAuxInfo , 'firstName' , 'C' , 'C' ))
	oAuxRetorno:oCustomer:lastName     := AllTrim( RetXMLVal( aAuxInfo , 'lastName' , 'C' , 'C' ))
	oAuxRetorno:oCustomer:phoneNumber  := AllTrim( RetXMLVal( aAuxInfo , 'phoneNumber' , 'C' , 'C' ))
	oAuxRetorno:oCustomer:businessName := AllTrim( RetXMLVal( aAuxInfo , 'businessName' , 'C' , 'C' ))
	oAuxRetorno:oCustomer:taxID             := AllTrim( RetXMLVal( aAuxInfo , 'taxID' , 'C' , 'C' ))
	oAuxRetorno:oCustomer:dbsCustomerNumber := AllTrim( RetXMLVal( aAuxInfo , 'dbsCustomerNumber' , 'C' , 'C' ))

	If ::oXMLManager:DOMChildNode()
		While (.t.)
			aAuxInfo := ::oXMLManager:DOMGetChildArray()

			Do Case
				Case ::oXMLManager:cName == "address"
					oAuxRetorno:oCustomer:oAddress:addressLine1 := Upper(AllTrim( RetXMLVal( aAuxInfo , 'addressLine1' , 'C' , 'C' )) )
					oAuxRetorno:oCustomer:oAddress:addressLine2 := Upper(AllTrim( RetXMLVal( aAuxInfo , 'addressLine2' , 'C' , 'C' )) )
					oAuxRetorno:oCustomer:oAddress:city         := AllTrim( RetXMLVal( aAuxInfo , 'city' , 'C' , 'C' ))
					oAuxRetorno:oCustomer:oAddress:country      := AllTrim( RetXMLVal( aAuxInfo , 'country' , 'C' , 'C' ))
					oAuxRetorno:oCustomer:oAddress:county       := AllTrim( RetXMLVal( aAuxInfo , 'county' , 'C' , 'C' ))
					oAuxRetorno:oCustomer:oAddress:state        := AllTrim( RetXMLVal( aAuxInfo , 'state' , 'C' , 'C' ))
					oAuxRetorno:oCustomer:oAddress:zip          := AllTrim( RetXMLVal( aAuxInfo , 'zip' , 'C' , 'C' ))

			EndCase

			If ! ::oXMLManager:DOMNextNode()
				Exit
			EndIf

		End

		::oXMLManager:DOMParentNode()

	EndIf

Return



/*/{Protheus.doc} _getTradeInsFromQuote

Cria um equipamento no objeto de retorno do webserivce

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}
@param oAuxRetorno, object, descricao
@param aAuxInfo, array, descricao
@type function
/*/
Method _getTradeInsFromQuote(oAuxRetorno, aAuxInfo) class VEJDQuoteMaintainQuote

	Local oAuxTradeIns

	oAuxTradeIns := VEJDQuoteTradeIns():New()
	oAuxTradeIns:id               := RetXMLVal( aAuxInfo , 'id'               , 'N' , 'N' )  // 0
	oAuxTradeIns:makeName         := RetXMLVal( aAuxInfo , 'makeName'         , 'C' , 'C' )  // ""
	oAuxTradeIns:modelName        := RetXMLVal( aAuxInfo , 'modelName'        , 'C' , 'C' )  // ""
	oAuxTradeIns:serialNumber     := RetXMLVal( aAuxInfo , 'serialNumber'     , 'C' , 'C' )  // ""
	oAuxTradeIns:description      := RetXMLVal( aAuxInfo , 'description'      , 'C' , 'C' )  // ""
	oAuxTradeIns:hourMeterReading := RetXMLVal( aAuxInfo , 'hourMeterReading' , 'C' , 'C' )  // ""
	oAuxTradeIns:tagNumber        := RetXMLVal( aAuxInfo , 'tagNumber'        , 'C' , 'C' )  // ""
	oAuxTradeIns:year             := RetXMLVal( aAuxInfo , 'year'             , 'C' , 'C' )  // 0
	oAuxTradeIns:netTradeValue    := RetXMLVal( aAuxInfo , 'netTradeValue'    , 'N' , 'N' )  // 0

	AADD( oAuxRetorno:aTradeIns , oAuxTradeIns )

Return

Method send(cMsgSend) class VEJDQuoteMaintainQuote
	Local xRet

	If ::lOkta
		::configOkta()
	EndIf

	xRet := _Super:send(cMsgSend)

Return xRet

Method configOkta() class VEJDQuoteMaintainQuote
	::oOkta:SetMaintainQuoteJDQuote()
Return



/*/{Protheus.doc} VEJDQuoteGetQuoteResponse
Classe VEJDQuoteGetQuoteResponse
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteGetQuoteResponse
	Data quoteId
	Data quoteName
	Data quoteStatus
	Data customerName
	Data quoteTotal
	Data creationDate
	Data expirationDate
	Data modelName
	Data quoteType
	Data deleteIndicator

	Method New() CONSTRUCTOR
EndClass

Method New() Class VEJDQuoteGetQuoteResponse
Return SELF

/*/{Protheus.doc} VEJDQuoteGetQuoteDetailResponse
Classe VEJDQuoteGetQuoteDetailResponse
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteGetQuoteDetailResponse

	Data quoteId
	Data quoteName
	Data creationDate
	Data expirationDate
	Data dealerAccountNumber
	Data lastDateModifiedDate
	Data lastTimeModifiedDate
	Data customerNote
	Data totalNetTradeValue
	Data balanceDue
	Data netProceeds

	Data oErrorMessage
	Data oQuoteStatus
	Data oQuoteType
	Data oSalesPerson
	Data oCustomer
	Data oPODetails

	Data aEquipment
	Data aTradeIns

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteGetQuoteDetailResponse
	self:oErrorMessage := VEJDQuoteErrorMessage():New()
	self:oQuoteStatus := VEJDQuoteStatus():New()
	self:oQuoteType := VEJDQuoteType():New()
	self:oSalesPerson := VEJDQuoteSalesPerson():New()
	self:oCustomer := VEJDQuoteCustomer():New()
	self:oPODetails := VEJDQuotePODetails():New()

	self:aEquipment := {}
	self:aTradeIns := {}
Return SELF

/*/{Protheus.doc} VEJDQuoteErrorMessage
Classe VEJDQuoteErrorMessage
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteErrorMessage
	Data errorId
	Data errorMessage
	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteErrorMessage
	self:errorId := 0
	self:errorMessage := ""
Return SELF

/*/{Protheus.doc} VEJDQuoteStatus
Classe VEJDQuoteStatus
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteStatus
	Data description
	Data id
	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteStatus
	self:description := ""
	self:id := ""
Return SELF

/*/{Protheus.doc} VEJDQuotePODetails
Classe VEJDQuotePODetails
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuotePODetails
	Data deliveredOn
	Data poStatus
	Data purchaserType
	Data signedOnDate
	Data transactionType
	Data warrantyBegins
	Data poNumber

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuotePODetails
	self:deliveredOn := CtoD(" ")
	self:poStatus := ""
	self:purchaserType := ""
	self:signedOnDate := CtoD(" ")
	self:transactionType := ""
	self:warrantyBegins := CtoD(" ")
	self:poNumber := 0
Return SELF

/*/{Protheus.doc} VEJDQuoteType
Classe VEJDQuoteType
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteType
	Data description
	Data id
	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteType
	self:description := ""
	self:id := ""
Return SELF


/*/{Protheus.doc} VEJDQuoteSalesPerson
Classe VEJDQuoteSalesPerson
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteSalesPerson

	Data deereUserId
	Data firstName
	Data lastName
	Data middleName
	Data fullName
	Data emailAddress

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteSalesPerson
	self:deereUserId := ""
	self:firstName := ""
	self:lastName := ""
	self:middleName := ""
	self:fullName := ""
	self:emailAddress := ""
Return SELF


/*/{Protheus.doc} VEJDQuoteEquipment
Classe VEJDQuoteEquipment
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteEquipment

	Data id
	Data costPrice
	Data totalEquipmentSellingPrice
	Data dealerOrderNumber
	Data equipmentOrderNumber
	Data dealerStockNumber
	Data invoiceNumber
	Data listPrice
	Data machineHours
	Data makeName
	Data modelName
	Data status
	Data categoryId
	Data categoryDescription
	Data subCategoryId
	Data subCategoryDescription
	Data serialNumber

	Data aEquiOptData
	Data aAdjustments

	Method New() CONSTRUCTOR
EndClass

Method New() Class VEJDQuoteEquipment
	self:id := 0
	self:costPrice := 0
	self:totalEquipmentSellingPrice := 0
	self:dealerOrderNumber := 0
	self:equipmentOrderNumber := ""
	self:dealerStockNumber := ""
	self:invoiceNumber := ""
	self:listPrice := ""
	self:machineHours := ""
	self:makeName := ""
	self:modelName := ""
	self:status := ""
	self:categoryId := ""
	self:categoryDescription := ""
	self:subCategoryId := ""
	self:subCategoryDescription := ""
	self:serialNumber := ""

	self:aEquiOptData := {}
	self:aAdjustments := {}
Return SELF

/*/{Protheus.doc} VEJDQuoteEquipmentOptionData
Classe VEJDQuoteEquipmentOptionData
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteEquipmentOptionData

	Data optionId
	Data optionCode
	Data optionCostAmount
	Data optionDesc
	Data optionPriceAmount
	Data optionType

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteEquipmentOptionData
	self:optionId := 0
	self:optionCode := ""
	self:optionCostAmount := 0
	self:optionDesc := ""
	self:optionPriceAmount := 0
	self:optionType := ""

Return SELF


/*/{Protheus.doc} VEJDQuoteAdjustments
Classe VEJDQuoteAdjustments
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteAdjustments

	Data id
	Data description
	Data costPrice
	Data listPrice

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteAdjustments
	self:id := 0
	self:description := ""
	self:costPrice := 0
	self:listPrice := 0
Return SELF

/*/{Protheus.doc} VEJDQuoteCustomer
Classe VEJDQuoteCustomer
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteCustomer
	Data entityId
	Data firstName
	Data lastName
	Data phoneNumber
	Data businessName
	Data taxID
	Data dbsCustomerNumber
	Data oAddress

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteCustomer
	self:entityId := 0
	self:firstName := ""
	self:lastName := ""
	self:phoneNumber := ""
	self:businessName := ""
	self:taxID := ""
	self:dbsCustomerNumber := ""

	self:oAddress := VEJDQuoteCustomerAddress():New()
Return SELF

/*/{Protheus.doc} VEJDQuoteCustomerAddress
Classe  VEJDQuoteCustomerAddress
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteCustomerAddress
	Data addressLine1
	Data addressLine2
	Data city
	Data country
	Data county
	Data state
	Data zip

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteCustomerAddress
	self:addressLine1 := ""
	self:addressLine2 := ""
	self:city := ""
	self:country := ""
	self:county := ""
	self:state := ""
	self:zip := ""
Return SELF


/*/{Protheus.doc} VEJDQuoteGetMasterQuotesResponse
Classe VEJDQuoteGetMasterQuotesResponse
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteGetMasterQuotesResponse
	Data quoteId
	Data quoteName
	Data creationDate
	Data expirationDate
	Data quoteType
	Data errorMessage
	Data deleteIndicator

	Method New() CONSTRUCTOR
EndClass

Method New() Class VEJDQuoteGetMasterQuotesResponse
Return SELF


/*/{Protheus.doc} VEJDQuoteTradeIns
Classe VEJDQuoteTradeIns
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuoteTradeIns

	Data id
	Data makeName
	Data modelName
	Data serialNumber
	Data description
	Data hourMeterReading
	Data tagNumber
	Data year
	Data netTradeValue

	Method New() CONSTRUCTOR
EndClass

Method New() Class VEJDQuoteTradeIns
	self:id := 0
	self:makeName := ""
	self:modelName := ""
	self:serialNumber := ""
	self:description := ""
	self:hourMeterReading := ""
	self:tagNumber := ""
	self:year := ""
	self:netTradeValue := 0
	
Return SELF

/*/{Protheus.doc} RetXMLVal
Retorna um valor de uma tag contida na matriz aAuxInfo
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}
@param aAuxInfo, array, descricao
@param cTag, characters, descricao
@param cTipoXML, characters, descricao
@param cTipoProtheus, characters, descricao
@type function
/*/
Static Function RetXMLVal(aAuxInfo, cTag, cTipoXML, cTipoProtheus)

	Local nPosValor := aScan(aAuxInfo , { |x| x[1] == cTag })
	Local uAuxValor

	Local cMes

	Default cTipoProtheus := "C"

	If nPosValor == 0

		//Conout("RetXMLVal - Tag nao encontrada - " + cTag)

		Do Case
		Case cTipoProtheus == "D"
			uAuxValor := CtoD(" ")
		Case cTipoProtheus == "T"
			uAuxValor := ""
		Case cTipoProtheus == "L"
			uAuxValor := .f.
		Case cTipoProtheus == "N"
			uAuxValor := 0
		Otherwise
			uAuxValor := ""
		EndCase

	Else
		uAuxValor := aAuxInfo[nPosValor, 2]

		Do Case
		Case cTipoXML == "TS" // Timestamp
			Do Case
			Case cTipoProtheus == "D" // Retorna somente a parte da data
				uAuxValor := StoD(StrTran(Left(uAuxValor,10),"-",""))
			Case cTipoProtheus == "T" // Retorna somente a parte da data
				uAuxValor := StrTran(SubStr(uAuxValor,12,8),":","")
			EndCase

		Case cTipoXML == "LD" // Data no Formato DD MMM YYYY (01-Jan-2019) - Long Date
			If cTipoProtheus == "D"
				If Empty(uAuxValor)
					uAuxValor := CtoD(" ")
				Else
					cMes := SubStr(uAuxValor,4,3)
					Do Case
						Case cMes == "Jan" ; cMes := "01"
						Case cMes == "Feb" ; cMes := "02"
						Case cMes == "Mar" ; cMes := "03"
						Case cMes == "Apr" ; cMes := "04"
						Case cMes == "May" ; cMes := "05"
						Case cMes == "Jun" ; cMes := "06"
						Case cMes == "Jul" ; cMes := "07"
						Case cMes == "Aug" ; cMes := "08"
						Case cMes == "Sep" ; cMes := "09"
						Case cMes == "Oct" ; cMes := "10"
						Case cMes == "Nov" ; cMes := "11"
						Otherwise ; cMes := "12"
					End Case
					uAuxValor := CtoD(SubStr(uAuxValor,1,2) + "/" + cMes + "/" + SubStr(uAuxValor,8,4))
				EndIf
			EndIf
		Case cTipoXML == "L" // Logical
			If cTipoProtheus == "L"
				uAuxValor := ( Upper(uAuxValor) $ "YES/SIM" )
			EndIf
		Otherwise
			Do Case
				Case cTipoProtheus == "N"
					uAuxValor := IIf( Empty(uAuxValor) , 0 , Val(uAuxValor) )
				Case cTipoProtheus == "D"
					uAuxValor := StoD(StrTran(uAuxValor,"-",""))
				Otherwise
					uAuxValor := AllTrim(uAuxValor)
			EndCase
		EndCase

	EndIf

Return uAuxValor

Static Function QuoteStatus(cQuoteStatus)
	cQuoteStatus := AllTrim(UPPER(cQuoteStatus))
	Do Case
	Case cQuoteStatus == "ACTIVE"      ; Return STR0001 // "Ativo"
	Case cQuoteStatus == "EXPIRED"     ; Return STR0002 // "Expirado"
	Case cQuoteStatus == "LOST"        ; Return STR0003 // "Venda Perdida"
	Case cQuoteStatus == "NO PURCHASE" ; Return STR0004 // "Sem Compra"
	Case cQuoteStatus == "SIGNED"      ; Return STR0005 // "Assinado"
	Case cQuoteStatus == "WON"         ; Return STR0006 // "Venda Fechada"
	Case cQuoteStatus == "BOUGHT USED EQUIPMENT" ; Return STR0007 // "Comprou Equipamento Usado"
	Otherwise ; Return cQuoteStatus
	EndCase
Return ""
