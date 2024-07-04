#INCLUDE "TOTVS.CH"
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"


/*/{Protheus.doc} ShpApi
    Class used to request Shopify's API
    @author Yves Oliveira
    @since 13/02/2020
    /*/
Class ShpApi
    Data cApiKey   As String
    Data cApiPsw   As String 
    Data cBaseUrl  As String
    Data cApiVer   As String
    Data cEndPoint As String 

    Data clientId           As String
	Data accessToken        As String
	Data storeHash          As String
	Data URL                As String
	Data path               As String
	Data header             As Array
	Data error              As String
	Data warning            As String
	Data resultString       As String
	Data resultParsedObject As Object
	Data responseType       As String
    Data bError             As CodeBlock


    Method new() Constructor
	Method setURL(cUrl)
	Method setPath(cObjectName)
	Method setHeader(aHeader)
	Method clear()
    Method setErrorBlock()
    Method sendRequest(cVerb, lJSONlegacy)
	
EndClass

/*/{Protheus.doc} new
This method sets the constructor of Shopify API
@author Yves Oliveira
@since 13/02/2020
@type method
/*/
Method new() Class ShpApi
    ::URL := ''
	::path := ''
	::header := {}
	::error := ''
	::warning := ''
	::resultString := ''
	::resultParsedObject := nil
	::responseType := ''
	::setErrorBlock()
Return

/*/{Protheus.doc} setURL
This method sets the basic URL used to connect to the Shopify API
@author Yves Oliveira
@since 13/02/2020
@type method
/*/
Method setURL(cUrl) class ShpApi
	Local lRet				:= .F.
	
	BEGIN SEQUENCE
		If !Empty(cUrl)
			::URL := cUrl
		Else
			::URL := ShpGetPar("BASEURL")
		EndIf
		lRet := .T.
	END SEQUENCE

Return lRet

/*/{Protheus.doc} setErrorBlock
This method sets the error block used to handle errors from the Shopify API
@author Yves Oliveira
@since 13/02/2020
@type method
/*/
Method setErrorBlock() class ShpApi
	::bError   := ErrorBlock({ |oError| ::error := oError:Description})
Return

/*/{Protheus.doc} setPath
This method sets the path and parameters used to connect to the Shopify API
@author Yves Oliveira
@since 13/02/2020
@type method
/*/
Method setPath(cPath) class ShpApi
	Local lRet				:= .F.
	
	BEGIN SEQUENCE

		If valtype(cPath) != 'C' .or. empty(cPath)
			::error := STR0101 // 'Parameter 0 [cPath] is invalid or empty'
			BREAK
		EndIf

        ::path := cPath

		lRet := .T.

	END SEQUENCE

Return lRet

/*/{Protheus.doc} setHeader
This method sets the header used to connect to the Shopify API
@author Yves Oliveira
@since 13/002/2020
@type method
/*/
Method setHeader(aHeader) class ShpApi
	Local lRet	  := .F.
	Local nHeader := 0
    Local cAuth   := "" 

	BEGIN SEQUENCE

		If !empty(aHeader) .and. valtype(aHeader) != 'A'
			::error := STR0102  // 'Parameter 0 [aHeader] is invalid'
			BREAK
		EndIf

		for nHeader := 1 to len(aHeader)
			AADD(::header, aHeader[nHeader])
		next nHeader

		::cApiKey   := ShpGetPar("APIKEY")
        ::cApiPsw   := ShpGetPar("APIPSW")

        cAuth := ENCODE64(::cApiKey + ":" + ::cApiPsw)
        aadd(::header,"Authorization:  Basic " + cAuth)
        aadd(::header,"Content-Type: application/json")

		lRet := .T.

	END SEQUENCE

Return lRet


/*/{Protheus.doc} clear
This method clear the response attributes
@author Yves Oliveira
@since 13/02/2020
@type method
/*/
Method clear() class ShpApi

	::error := ''
	::warning := ''
	::resultString := ''
	::resultParsedObject := nil
	::responseType := ''

Return .T.

/*/{Protheus.doc} sendRequest
This method send a new request to the Shopify API
@author Yves Oliveira
@since 13/02/2020
@type method
/*/
Method sendRequest(cVerb, lJSONlegacy, cBody, lSecondAttempt) class ShpApi
	Local nVarNameLen		:= SetVarNameLen(100)
	Local lRet				:= .F.
	Local lError			:= .F.
	Local cResult			:= ''
	Local nPosContentType	:= 0
	Local cError			:= ''
	Local cWarning			:= ''
	Local aJSONfields		:= {}
	Local nJSONparser		:= 0
	Local nPosHeader		:= 0
	Local nWait				:= 0
	Local lTryAgain			:= .F.

	Private oRest			:= nil
	Private oResult			:= nil
	Private oJSON			:= nil
	Private aHeader			:= {}

	Default cVerb			:= ''
	Default lJSONlegacy		:= .F.
	Default cBody			:= ''
	Default lSecondAttempt	:= .F.

	BEGIN SEQUENCE

		If !Empty(::error)
			BREAK
		EndIf

		If valtype(cVerb) != 'C' .or. empty(cVerb)
			::error := STR0103  //'Parameter 0 [cVerb] is invalid or empty'
			BREAK
		EndIf

		If !(cVerb $ REST_METHOD_GET + "|" + REST_METHOD_POST + "|" + REST_METHOD_PUT + "|" + REST_METHOD_DELETE)
			::error := STR0104  //'Verb not recognized'
			BREAK
		EndIf

		If valtype(lJSONlegacy) != 'L'
			::error := STR0105  //'Parameter 1 [lJSONlegacy] is invalid'
			BREAK
		EndIf

		oRest := FwRest():new(::URL)

		oRest:setPath(::path)

		If !empty(::header)
			aHeader := AClone(::header)
		Else
			::setHeader({})//Load default headers
			aHeader := AClone(::header)
		EndIf

		Do Case
            Case upper(allTrim(cVerb)) == REST_METHOD_POST
                If valtype(cBody) != 'C' .or. empty(cBody)
                    ::error := STR0106  //'Parameter 0 [cBody] is invalid or empty'
                    BREAK
                EndIf

                oRest:SetPostParams(cBody)
                
                lError := !oRest:post(aHeader)
            Case upper(allTrim(cVerb)) == REST_METHOD_PUT
                If valtype(cBody) != 'C' .or. empty(cBody)
                    ::error := STR0106 //'Parameter 0 [cBody] is invalid or empty'
                    BREAK
                EndIf
                
                lError := !oRest:put(aHeader, cBody)
			Case upper(allTrim(cVerb)) == REST_METHOD_DELETE
                lError := !oRest:delete(aHeader)
            Case upper(allTrim(cVerb)) == REST_METHOD_GET
                lError := !oRest:get(aHeader)
            Otherwise
                ::error := STR0107  + cVerb + STR0108  //'The method [' + cVerb + '] is invalid or non supported'
                BREAK
		EndCase

		cResult := alltrim(oRest:getResult())

		If lError
			::error 	   := oRest:getLastError()
			::resultString := cResult

			//Verify If the error is related to the API limit
			If !lSecondAttempt .and. (left(alltrim(::error), 3) == HTTP_TOO_MANY_REQUESTS)
				If type('oRest:oResponseH') == 'O'
					If type('oRest:oResponseH:aHeaderFields') == 'A'
						If (nPosHeader := AScan(oRest:oResponseH:aHeaderFields, {| header | upper(alltrim(header[ARRAY_HEADER_FIELD_NAME])) == HEADER_FIELD_LIMIT_TIME_RESET})) > 0
							nWait := (val(alltrim(oRest:oResponseH:aHeaderFields[nPosHeader, ARRAY_HEADER_FIELD_VALUE])) * 1000)

							If (nWait > 0)
								nWait += 10000
								//conout('*** ShpApi *** STARTING SLEEP ' + cValtoChar(nWait) + ' - ' + dtos(date()) + 'T' + time())//TODO: Colocar em CH
								sleep(nWait)
								//conout('*** ShpApi *** RETURNING FROM SLEEP ' + cValtoChar(nWait) + ' - ' + dtos(date()) + 'T' + time())//TODO: Colocar em CH
								lTryAgain := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			BREAK
		EndIf

		If !empty(cResult)
			::resultString := cResult
			If type('oRest:oResponseH') == 'O'
				If type('oRest:oResponseH:aHeaderFields') == 'A'
					If (nPosContentType := AScan(oRest:oResponseH:aHeaderFields, {| header | lower(alltrim(header[ARRAY_HEADER_FIELD_NAME])) == 'content-type'})) > 0
						::responseType := alltrim(oRest:oResponseH:aHeaderFields[nPosContentType, ARRAY_HEADER_FIELD_VALUE])

						Do Case
                            Case 'application/xml' $ lower(::responseType)
                                oResult := XmlParser(cResult, "_", @cError, @cWarning)

                                If !empty(cWarning)
                                    ::warning := cWarning
                                EndIf
                                If (oResult == nil) .or. !empty(cError)
                                    ::error := STR0109 + CRLF + cResult + CRLF + CRLF + alltrim(cError) //'An error has ocurred when trying to parser XML string:' 
                                    BREAK
                                EndIf
                            Case 'application/json' $ lower(::responseType)
                                If lJSONlegacy
                                    If !FWJsonDeserialize(cResult, @oResult)
                                        ::error := STR0110 + CRLF + cResult + CRLF + CRLF + cValtoChar(nJSONparser) + STR0111  + subStr(cResult, (nJSONparser + 1)) //'An error has ocurred when trying to parser JSON string:' + ' bytes have been read. The error ocurred from ' 
                                        BREAK
                                    EndIf
                                Else
                                    oJSON := tJsonParser():New()

                                    If !oJSON:json_hash(cResult, len(cResult), @aJSONfields, @nJSONparser, @oResult)
                                        ::error := STR0110 + CRLF + cResult + CRLF + CRLF + cValtoChar(nJSONparser) + STR0111 + subStr(cResult, (nJSONparser + 1)) //'An error has ocurred when trying to parser JSON string:' + ' bytes have been read. The error ocurred from ' 
                                        BREAK
                                    EndIf

                                    ASize(aJSONfields, 0)
                                EndIf
                            Otherwise
                                ::error := STR0112  + ::responseType + CRLF + cResult //'The response content-type is unknown: '
                                BREAK
						EndCase

						::resultParsedObject := oResult
					EndIf
				EndIf
			EndIf
		else
			::warning := STR0113 +  ::URL + ::path // 'There was no result from '
		EndIf

		If (oRest != nil) .and. valtype(oResult) == 'O'
			freeObj(oRest)
		EndIf

		lRet := .T.

	END SEQUENCE

	If lTryAgain
		::clear()
		lRet := ::connect(cVerb, lJSONlegacy, cBody, .T.)
    Else
        ErrorBlock(::bError)  
	EndIf

	If !empty(::error)
		::error += CRLF
		::error += CRLF + 'URL: ' + ::URL + CRLF
		::error += CRLF + 'path: ' + ::path + CRLF
		::error += CRLF + 'header: ' + CRLF
		AEVal(::header, {| aHeader | ::error += aHeader + CRLF})
		::error += CRLF + 'method: ' + cVerb  + CRLF
		::error += CRLF + 'body: ' + cBody  + CRLF
		::error += CRLF + 'resultString: ' + ::resultString + CRLF
		::error += CRLF + 'responseType: ' + ::responseType + CRLF
	EndIf

	SetVarNameLen(nVarNameLen)

Return lRet
