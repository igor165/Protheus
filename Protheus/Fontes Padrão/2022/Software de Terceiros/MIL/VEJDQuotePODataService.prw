#include "Totvs.ch"
#include 'protheus.ch'

#include "VEJDQuotePODataService.ch"

Function VEJDQuotePODataService()
Return

/*/{Protheus.doc} VEJDQuotePODataService
	Classe principal para Conexao ao WebService de PO do JDQuote

	@type function
	@author Rubens Takahashi
	@since 01/05/2019
/*/
Class VEJDQuotePODataService From VEJDQuote

	Method New() CONSTRUCTOR

	Method getPODetailByQuoteID()
	Method getPOPdf()
	Method searchPurchaseOrder()

	Method _getPODetailResponse()
	Method _getRevisions()
	Method _getEquipments()

	Method _getPOPdfResponse()

	Method configOkta()
	Method send()

EndClass

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Rubens Takahashi
	@since 01/04/2019
/*/
Method New() Class VEJDQuotePODataService

	::cNameHeaderToken := "VENDOR_AUTH_TOKEN"
	//::cWSDL := "/logsmil/jdquote/PODataService_Version1_1Impl.wsdl"
	::cWSDL := "http://www.itmil.com.br/john_deere/PODataService_Version1_1Impl.wsdl"
	::cURLWebService := GetNewPar("MV_MIL0129","")// "https://jdquote2ws.deere.com/services/PODataService_Version1_1Impl"
	_Super:New()

	::lOkta := self:oOkta:oConfig:poDataJDQuote()

	If ::lOkta
		::cURLWebService := self:oOkta:oConfig:getUrlWSPoDataJDQuote()
	EndIf

Return SELF

Method send(cMsgSend) class VEJDQuotePODataService
	Local xRet

	If ::lOkta
		::configOkta()
	EndIf

	xRet := _Super:send(cMsgSend)

Return xRet

Method configOkta() class VEJDQuotePODataService
	::oOkta:SetPODataJDQuote()
Return


Method getPODetailByQuoteID(nQuoteId) Class VEJDQuotePODataService
	Local xRet

	::oWSDLManager:SetOperation( "getPODetailByQuoteID" )

	cMsgSend := ;
		'<?xml version="1.0" encoding="utf-8"?>' +;
		'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://version1_1.po.services.view.jdquote.deere.com">' +;
		'<soapenv:Header/>' +;
		'<soapenv:Body>' +;
			'<ver:getPODetailByQuoteID>' +;
				'<quoteId>' + AllTrim(cValToChar(nQuoteId)) + '</quoteId>' +;
				'<racfID>' + ::cDealerAccount + '</racfID>' +;
				'<userLang>PT</userLang>' +;
			'</ver:getPODetailByQuoteID>' +;
		'</soapenv:Body>' +;
		'</soapenv:Envelope>'

	xRet := ::send(cMsgSend)

	If xRet
		::_getPODetailResponse()
	EndIf

Return xRet

Method getPOPdf(nQuoteId, nPONumber) Class VEJDQuotePODataService
	Local xRet

	::oWSDLManager:SetOperation( "getPODetailByQuoteID" )

	cMsgSend := ;
		'<?xml version="1.0" encoding="utf-8"?>' +;
		'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://version1_1.po.services.view.jdquote.deere.com">'+;
		'<soapenv:Header/>' +;
		'<soapenv:Body>' +;
			'<ver:getPOPdf>' +;
				'<quoteId>' + AllTrim(cValToChar(nQuoteId)) + '</quoteId>' +;
				'<poNumber>' + AllTrim(cValToChar(nPONumber)) + '</poNumber>' +;
				'<racfID>' + ::cDealerAccount + '</racfID>' +;
				'<revisionId></revisionId>' +;
				'<userPrefLang>PT</userPrefLang>' +;
			'</ver:getPOPdf>' +;
		'</soapenv:Body>' +;
		'</soapenv:Envelope>'

	xRet := ::send(cMsgSend)

	If xRet
		xRet := ::_getPOPdfResponse()
	EndIf

Return xRet


/*/{Protheus.doc} _getPODetailResponse

Processa retorno do metodo getQuoteDetail

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method _getPODetailResponse() class VEJDQuotePODataService

	Local oAuxRetorno

	::oXMLManager:DOMChildNode() // "/soapenv:Envelope"
	::oXMLManager:DOMChildNode() // "/soapenv:Envelope/soapenv:Body"
	::oXMLManager:DOMChildNode() // "/soapenv:Envelope/soapenv:Body/ns2:getPODetailByQuoteIDResponse"

	::aResponse := {}

	If ::oXMLManager:DOMChildCount() > 1

		aAuxInfo := ::oXMLManager:DOMGetChildArray()

		oAuxRetorno := VEJDQuoteGetPODetailResponse():New()
		oAuxRetorno:poNumber := RetXMLVal(aAuxInfo, 'poNumber', 'C'  , 'N' )

		If ::oXMLManager:DOMChildNode()
			While (.t.)
				aAuxInfo := ::oXMLManager:DOMGetChildArray()

				Do Case
					Case ::oXMLManager:cName == "revisions"
						self:_getRevisions(oAuxRetorno, aAuxInfo)
				EndCase

				If ! ::oXMLManager:DOMNextNode()
					Exit
				EndIf

			End

			::oXMLManager:DOMParentNode()

		EndIf

		AADD(::aResponse, oAuxRetorno )

		If Len(::aResponse[1]:aRevisions) > 1
			Conout(".-. .-. .-. . . .-. .-. .-. ")
			Conout("|-|  |  |-  |\| |   |-| | | ")
			Conout("` '  '  `-' ' ` `-' ` ' `-' ")
			Conout("                            ")
			Conout("Pedido de venda com mais de uma revisao - " + cValToChar(oAuxRetorno:poNumber))
		EndIf

	EndIf
Return

Method _getRevisions(oAuxRetorno, aAuxInfo) class VEJDQuotePODataService
	Local oAuxRevision 

	oAuxRevision := VEJDQuoteGetPORevisions():New()
	oAuxRevision:orderDate     := RetXMLVal( aAuxInfo , 'orderDate'     , 'TS' , 'D' )
	oAuxRevision:internalNotes := RetXMLVal( aAuxInfo , 'internalNotes' , 'C'  , 'C' )
	oAuxRevision:signedOnDate  := RetXMLVal( aAuxInfo , 'signedOnDate'  , 'TS' , 'D' )
	oAuxRevision:status        := POStatus(RetXMLVal( aAuxInfo , 'status'        , 'C'  , 'C' ))
	
	cPdfData := RetXMLVal( aAuxInfo , 'pdfData' , 'C'  , 'C' )
	If !Empty(cPdfData)
		cPdfData := Decode64( cPdfData)
		oAuxRevision:pdf := cPdfData
	EndIf

	If ::oXMLManager:DOMChildNode()
		While (.t.)
			aAuxInfo := ::oXMLManager:DOMGetChildArray()

			Do Case
				Case ::oXMLManager:cName == "errorMessage"
					oAuxRevision:oErrorMessage:errorId := RetXMLVal(aAuxInfo, 'errorId' , 'N' , 'N')
					oAuxRevision:oErrorMessage:errorMessage := RetXMLVal(aAuxInfo, 'errorMessage' , 'C' , 'C')

				Case ::oXMLManager:cName == "equipments"
					self:_getEquipments(oAuxRevision, aAuxInfo)

			EndCase

			If ! ::oXMLManager:DOMNextNode()
				Exit
			EndIf

		End

		::oXMLManager:DOMParentNode()

	EndIf

	AADD(oAuxRetorno:aRevisions, oAuxRevision )

Return

Method _getEquipments(oAuxRetorno, aAuxInfo) class VEJDQuotePODataService
	Local oAuxEquipment
	Local oAuxStanOpt

	oAuxEquipment := VEJDQuotePOEquipment():New()
	oAuxEquipment:finalSellingPrice := RetXMLVal( aAuxInfo , 'finalSellingPrice' , 'N' , 'N' )
	oAuxEquipment:serialNumber      := RetXMLVal( aAuxInfo , 'serialNumber'      , 'C' , 'C' )
	oAuxEquipment:prodDescription   := RetXMLVal( aAuxInfo , 'prodDescription'   , 'C' , 'C' )
	oAuxEquipment:status            := RetXMLVal( aAuxInfo , 'status'            , 'C' , 'C' )
	oAuxEquipment:makeName          := RetXMLVal( aAuxInfo , 'makeName'          , 'C' , 'C' )
	oAuxEquipment:modelName         := RetXMLVal( aAuxInfo , 'modelName'         , 'C' , 'C' )
	oAuxEquipment:hourMeterReading  := RetXMLVal( aAuxInfo , 'hourMeterReading'  , 'C' , 'C' )

	If ::oXMLManager:DOMChildNode()
		While (.t.)
			aAuxInfo := ::oXMLManager:DOMGetChildArray()

			Do Case
				Case ::oXMLManager:cName == "standardOptions"
					oAuxStanOpt := VEJDQuotePOStandardOptions():New()
					oAuxStanOpt:code                  := RetXMLVal( aAuxInfo , 'code'                  , 'C' , 'C' )
					oAuxStanOpt:description           := RetXMLVal( aAuxInfo , 'description'           , 'C' , 'C' )
					oAuxStanOpt:quantity              := RetXMLVal( aAuxInfo , 'quantity'              , 'N' , 'N' )
					oAuxStanOpt:extendedDiscountPrice := RetXMLVal( aAuxInfo , 'extendedDiscountPrice' , 'N' , 'N' )
					AADD( oAuxEquipment:aStandardOptions , oAuxStanOpt )

			EndCase

			If ! ::oXMLManager:DOMNextNode()
				Exit
			EndIf

		End

		::oXMLManager:DOMParentNode()

	EndIf

	AADD( oAuxRetorno:aEquipment , oAuxEquipment )

Return


/*/{Protheus.doc} _getPOPdfResponse

Processa retorno do metodo getPOPdf

@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method _getPOPdfResponse() class VEJDQuotePODataService

	Local oAuxRetorno
	Local cPdfData
	Local lPossuiPDF := .f.

	::oXMLManager:DOMChildNode() // "/soapenv:Envelope"
	::oXMLManager:DOMChildNode() // "/soapenv:Envelope/soapenv:Body"
	::oXMLManager:DOMChildNode() // "/soapenv:Envelope/soapenv:Body/ns2:getPOPdfResponse"

	::aResponse := {}

	If ::oXMLManager:DOMChildCount() > 1

		aAuxInfo := ::oXMLManager:DOMGetChildArray()

		oAuxRetorno := VEJDQuoteGetPOPdfResponse():New()

		cPdfData := RetXMLVal( aAuxInfo , 'pdf' , 'C'  , 'C' )
		If !Empty(cPdfData)
			cPdfData := Decode64( cPdfData)
			oAuxRetorno:pdf := cPdfData
			lPossuiPDF := .t.
		EndIf

		If ::oXMLManager:DOMChildNode()
			While (.t.)
				aAuxInfo := ::oXMLManager:DOMGetChildArray()

				Do Case
					Case ::oXMLManager:cName == "errorMessage"
						oAuxRetorno:oErrorMessage:errorId := RetXMLVal(aAuxInfo, 'errorId' , 'N' , 'N')
						oAuxRetorno:oErrorMessage:errorMessage := RetXMLVal(aAuxInfo, 'errorMessage' , 'C' , 'C')

				EndCase

				If ! ::oXMLManager:DOMNextNode()
					Exit
				EndIf

			End

			::oXMLManager:DOMParentNode()

		EndIf

		AADD(::aResponse, oAuxRetorno )

	EndIf
Return lPossuiPDF



Class VEJDQuoteGetPOPdfResponse

	Data pdf
	Data oErrorMessage

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteGetPOPdfResponse
	self:pdf := ""
	
	self:oErrorMessage := VEJDQuotePOErrorMessage():New()

Return SELF











Class VEJDQuoteGetPODetailResponse

	Data poNumber
	Data aRevisions

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteGetPODetailResponse
	self:poNumber := 0
	self:aRevisions := {}

Return SELF

Class VEJDQuoteGetPORevisions

	Data orderDate
	Data internalNotes
	Data signedOnDate
	Data status
	Data aEquipment
	Data pdf

	Data oErrorMessage
	//transactionType
	//warrantyBeginsDate

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuoteGetPORevisions
	self:orderDate := CtoD(" ")
	self:internalNotes := ""
	self:signedOnDate := CtoD(" ")
	self:status := ""
	self:aEquipment := {}
	self:pdf := ""

	self:oErrorMessage := VEJDQuotePOErrorMessage():New()

Return SELF

/*/{Protheus.doc} VEJDQuotePOEquipment
Classe VEJDQuotePOEquipment
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuotePOEquipment

	Data finalSellingPrice
	Data serialNumber
	Data prodDescription
	Data status
	Data makeName
	Data modelName
	Data hourMeterReading

	Data aStandardOptions

	Method New() CONSTRUCTOR
EndClass

Method New() Class VEJDQuotePOEquipment

	self:finalSellingPrice := 0
	self:serialNumber := ""
	self:prodDescription := ""
	self:status := ""
	self:makeName := ""
	self:modelName := ""
	self:hourMeterReading := ""

	self:aStandardOptions := {}

Return SELF

/*/{Protheus.doc} VEJDQuotePOStandardOptions
Classe VEJDQuotePOStandardOptions
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuotePOStandardOptions

	Data code
	Data description
	Data quantity
	Data extendedDiscountPrice

	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuotePOStandardOptions
	self:code := ""
	self:description := ""
	self:quantity := 0
	self:extendedDiscountPrice := 0

Return SELF

/*/{Protheus.doc} VEJDQuotePOErrorMessage
Classe VEJDQuotePOErrorMessage
@author Rubens
@since 10/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class VEJDQuotePOErrorMessage
	Data errorId
	Data errorMessage
	Method New() CONSTRUCTOR

EndClass

Method New() Class VEJDQuotePOErrorMessage
	self:errorId := 0
	self:errorMessage := ""
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

	If nPosValor <> 0
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


Static Function POStatus(cPOStatus)
	cPOStatus := AllTrim(Upper(cPOStatus))
	Do Case
	Case cPOStatus == "ACTIVE"      ; Return STR0001 // "Ativo"
	Case cPOStatus == "SIGNED"      ; Return STR0002 // "Assinado"
	Otherwise ; Return cPOStatus
	EndCase
Return ""
