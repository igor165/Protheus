
#include "Totvs.ch"
#include "ofjdokta.CH"

#define PROF_TIMETOKEN   1
#define PROF_EXPIREIN    2
#define PROF_ACCESSTOKEN 3
#define PROF_IDTOKEN     4
#define PROF_REFRESHTOKEN     5
#define PROF_DATETOKEN   6
   
#define SRVC_PMLINK  1
#define SRVC_ORDERSTATUS 2 
#define SRVC_JDQUOTE_MAINTAINQUOTE 3 
#define SRVC_JDQUOTE_PODATA 4
#define SRVC_WARRANTY 5
#define SRVC_NFCOMPRA 6
#define SRVC_DTFGETAPI 7
#define SRVC_DTFPUTAPI 8

/*/{Protheus.doc} OFJDOktaConfig
	Classe de Configuracao do Okta
	
	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Class OFJDOkta from LongNameClass

	Data oProfile as OBJECT

	Data _profProg as String
	Data _profTask as String
	Data _profType as String

	Data _AccessToken as String
	Data _DateCreate as String // Data no Formato YYYYMMDD
	Data _TimeCreate as String
	Data _ExpiresInSeconds as Number
	Data _RefreshToken as String
	Data _IDToken as String

	Data _sessionToken
	Data _codeAuthn
	Data _scope
	Data _scopeParam

	Data _userName as String
	Data _userPasswd as String
	Data _cURL as String
	Data _cRedirect_URI as String
	Data _client_ID as String
	Data _client_Secret as String
	Data _urlAuthN as String
	Data _cAuthServer as String

	Data _auxProfile

	Data _service as Number

	Data oJsonResult as Object
	Data oXMLManager as Object
	Data oRest as OBJECT

	Data oConfig as OBJECT

	Method NEW() Constructor
	Method DESTROY()

	Method getToken()
	Method cleanProfile()

	Method SetUserPasswd()

	Method SetPMLinkJDPoint()
	Method SetOrderStatusJDPoint()
	Method SetMaintainQuoteJDQuote()
	Method SetPODataJDQuote()
	Method SetWarranty()
	Method SetNFCompra()
	Method SetDTFGETAPI()
	Method SetDTFPUTAPI()

	Method IsPMLinkJDPoint()
	Method IsOrderStatusJDPoint()
	Method IsMaintainQuoteJDQuote()
	Method IsPODataJDQuote()
	Method IsWarranty()
	Method IsNFCompra()
	Method IsDTFGETAPI()
	Method IsDTFPUTAPI()

	Method _loadProfile()
	Method _saveProfile()

	Method _getNewToken()
	Method _getSessionToken()
	Method _getCode()
	Method _getAccessToken()

	Method _getDTFAccessToken()

	Method _getTokenRefresh()

	Method _postToken()

	Method _POSTTOKENDTF()

	Method _setTask()

	Method _getError()

EndClass

Method New() Class OFJDOkta

	Private lSchedule := FWGetRunSchedule()

	self:_AccessToken := ""
	self:_DateCreate := ""
	self:_TimeCreate := ""
	self:_ExpiresInSeconds := 0
	self:_RefreshToken := ""
	self:_IDToken := ""

	self:_profProg := "OFJDOKTA"
	self:_profType := ""

	self:_auxProfile := Array(5)
	
	self:_scope := ""
	self:_scopeParam := ""
	
	self:_userName := ""
	self:_userPasswd := ""
	
	self:oJsonResult := JsonObject():New()
	self:oXMLManager := TXMLManager():New()

	self:oRest := FWRest():New(self:_cURL)

	self:oProfile := FWProfile():New()

	self:oConfig := OFJDOktaConfig():New()
	self:oConfig:getConfig()

	self:_client_ID := self:oConfig:getClientID()
	self:_client_Secret := self:oConfig:getClientSecret()
	self:_cRedirect_URI := self:oConfig:getRedirURI()

	If .f.
		fsConout("")
	EndIf

Return SELF

Method DESTROY() Class OFJDOkta

	fwFreeObj(@self:oJsonResult)
	fwFreeObj(@self:oXMLManager)
	fwFreeObj(@self:oRest)

	aSize(self:_auxProfile,0)

Return

Method _loadProfile() Class OFJDOkta

	Local useProfile := .t.
	Local cElapTime := 0
	Local nTotSec := 0

	self:oProfile:SetProgram(self:_profProg)
	self:oProfile:SetTask(self:_profTask)
	self:oProfile:SetType(self:_profType)

	self:_AccessToken := ""
	self:_RefreshToken := ""

	self:_auxProfile := self:oProfile:Load()
	If Len(self:_auxProfile) == 0
	Else

		If Len(self:_auxProfile) == 5
			Return
		EndIf

		self:_RefreshToken := self:_auxProfile[PROF_REFRESHTOKEN]
		Do Case
		Case self:_auxProfile[PROF_DATETOKEN] <> DtoS(Date())
			useProfile := .f.
		Case self:_auxProfile[PROF_TIMETOKEN] > Time()
			useProfile := .f.
		Otherwise
			cElapTime := ElapTime(self:_auxProfile[PROF_TIMETOKEN], Time())

			nTotSec += Val(Left(cElapTime,2)) * 60 * 60
			nTotSec += Val(SubStr(cElapTime,4,2)) * 60
			nTotSec += Val(Right(cElapTime,2))

			If nTotSec > self:_auxProfile[PROF_EXPIREIN] - 60
				useProfile := .f.
			EndIf
		EndCase

		If useProfile
			self:_AccessToken := self:_auxProfile[PROF_ACCESSTOKEN]

		EndIf
	EndIf

Return

Method _saveProfile() Class OFJDOkta
	self:oProfile:SetProgram(self:_profProg)
	self:oProfile:SetTask(self:_profTask)
	self:oProfile:SetType(self:_profType)
	self:oProfile:SetProfile( self:_auxProfile )
	self:oProfile:Save()
Return

Method cleanProfile() Class OFJDOkta
	self:oProfile:SetProgram(self:_profProg)
	self:oProfile:SetTask(self:_profTask)
	self:oProfile:SetType(self:_profType)
	self:oProfile:SetProfile( {} )
	self:oProfile:Save()
Return

Method SetUserPasswd(cUser, cPasswd) Class OFJDOkta
	self:_userName := cUser
	self:_userPasswd := cPasswd
Return

Method SetPMLinkJDPoint() Class OFJDOkta
	
	If ::IsPMLinkJDPoint()
		return
	endif
	
	self:_service := SRVC_PMLINK

	self:_cURL := self:oConfig:getURLOktaPmLinkJdPoint()
	self:_cAuthServer := self:oConfig:getAuthSrvPmLinkJdPoint()
	self:_urlAuthN := self:oConfig:getPathAuthPmLinkJdPoint()
	self:_scope := Escape(self:oConfig:getScopePmLinkJdPoint())
	self:_scopeParam := self:oConfig:getScopePmLinkJdPoint()

	self:_setTask()

Return

Method SetOrderStatusJDPoint() Class OFJDOkta

	If ::IsOrderStatusJDPoint()
		return
	endif

	self:_service := SRVC_ORDERSTATUS

	self:_cURL := self:oConfig:getURLOktaOrderStatusJdPoint()
	self:_cAuthServer := self:oConfig:getAuthSrvOrderStatusJdPoint()
	self:_urlAuthN := self:oConfig:getPathAuthOrderStatusJdPoint()
	self:_scope := Escape(self:oConfig:getScopeOrderStatusJdPoint())
	self:_scopeParam := self:oConfig:getScopeOrderStatusJdPoint()

	self:_setTask()

Return

Method SetMaintainQuoteJDQuote() Class OFJDOkta

	if ::IsMaintainQuoteJDQuote()
		return
	endif

	self:_service := SRVC_JDQUOTE_MAINTAINQUOTE

	self:_cURL := self:oConfig:getURLOktaMaintainQuoteJDQuote()
	self:_cAuthServer := self:oConfig:getAuthSrvMaintainQuoteJDQuote()
	self:_urlAuthN := self:oConfig:getPathAuthMaintainQuoteJDQuote()
	self:_scope := Escape(self:oConfig:getScopeMaintainQuoteJDQuote())
	self:_scopeParam := self:oConfig:getScopeMaintainQuoteJDQuote()

	self:_setTask()

Return

Method SetPODataJDQuote() Class OFJDOkta

	if ::IsPODataJDQuote()
		return
	endif

	self:_service := SRVC_JDQUOTE_PODATA

	self:_cURL := self:oConfig:getURLOktaPoDataJDQuote()
	self:_cAuthServer := self:oConfig:getAuthSrvPoDataJDQuote()
	self:_urlAuthN := self:oConfig:getPathAuthPoDataJDQuote()
	self:_scope := Escape(self:oConfig:getScopePoDataJDQuote())
	self:_scopeParam := self:oConfig:getScopePoDataJDQuote()

	self:_setTask()

Return

Method SetWarranty() Class OFJDOkta

	if ::IsWarranty()
		return
	endif

	self:_service := SRVC_WARRANTY

	self:_cURL := self:oConfig:getURLOktaWarranty()
	self:_cAuthServer := self:oConfig:getAuthSrvWarranty()
	self:_urlAuthN := self:oConfig:getPathAuthWarranty()
	self:_scope := Escape(self:oConfig:getScopeWarranty())
	self:_scopeParam := self:oConfig:getScopeWarranty()

	self:_setTask()

Return

Method SetNFCompra() Class OFJDOkta

	if ::IsNFCompra()
		return
	endif

	self:_service := SRVC_NFCOMPRA

	self:_cURL := self:oConfig:getURLOktaNotaFiscalCompra()
	self:_cAuthServer := self:oConfig:getAuthSrvNotaFiscalCompra()
	self:_urlAuthN := self:oConfig:getPathAuthNotaFiscalCompra()
	self:_scope := Escape(self:oConfig:getScopeNotaFiscalCompra())
	self:_scopeParam := self:oConfig:getScopeNotaFiscalCompra()

	self:_setTask()

Return

Method SetDTFGETAPI() Class OFJDOkta

	if ::IsDTFGETAPI()
		return
	endif

	self:_service := SRVC_DTFGETAPI

	self:_cURL := self:oConfig:getURLOktaDTFGETAPI()
	self:_cAuthServer := self:oConfig:getAuthSrvDTFGETAPI()
	self:_urlAuthN := self:oConfig:getPathAuthDTFGETAPI()
	self:_scope := Escape(self:oConfig:getScopeDTFGETAPI())
	self:_scopeParam := self:oConfig:getScopeDTFGETAPI()

	self:_setTask()

Return

Method SetDTFPUTAPI() Class OFJDOkta

	if ::IsDTFPUTAPI()
		return
	endif

	self:_service := SRVC_DTFPUTAPI

	self:_cURL := self:oConfig:getURLOktaDTFPUTAPI()
	self:_cAuthServer := self:oConfig:getAuthSrvDTFPUTAPI()
	self:_urlAuthN := self:oConfig:getPathAuthDTFPUTAPI()
	self:_scope := Escape(self:oConfig:getScopeDTFPUTAPI())
	self:_scopeParam := self:oConfig:getScopeDTFPUTAPI()

	self:_setTask()

Return



Method IsPMLinkJDPoint() Class OFJDOkta
Return self:_service == SRVC_PMLINK

Method IsOrderStatusJDPoint() Class OFJDOkta
Return self:_service == SRVC_ORDERSTATUS

Method IsMaintainQuoteJDQuote() Class OFJDOkta
Return self:_service == SRVC_JDQUOTE_MAINTAINQUOTE

Method IsPODataJDQuote() Class OFJDOkta
Return self:_service == SRVC_JDQUOTE_PODATA

Method IsWarranty() Class OFJDOkta
Return self:_service == SRVC_WARRANTY

Method IsNFCompra() Class OFJDOkta
Return self:_service == SRVC_NFCOMPRA

Method IsDTFGETAPI() Class OFJDOkta
Return self:_service == SRVC_DTFGETAPI

Method IsDTFPUTAPI() Class OFJDOkta
Return self:_service == SRVC_DTFPUTAPI


Method _setTask() Class OFJDOkta
	cTaskType := Left(self:_cAuthServer,20)
	self:_profTask := Left(self:_cAuthServer,10)
	self:_profType := Right(self:_cAuthServer,10)
Return

Method getToken() Class OFJDOkta

	if self:IsDTFGETAPI() .or. self:IsDTFPUTAPI()
		if self:_getDTFAccessToken()
			return self:_AccessToken
		endif
	endif

	self:_loadProfile()
	If ! Empty(self:_AccessToken)
		Return self:_AccessToken
	EndIf

	if ! Empty(self:_RefreshToken)
		if self:_getTokenRefresh()
			return self:_AccessToken
		endif
	endif

	if self:_getNewToken()
		return self:_AccessToken
	endif

Return ""

Method _getNewToken() Class OFJDOkta

	If ! self:_getSessionToken() 
		Return .f.
	EndIf

	If ! self:_getCode() 
		Return .f.
	EndIf

	If ! self:_getAccessToken()
		Return .f.
	EndIf

	self:_saveProfile()

Return .t.

Method _getSessionToken() Class OFJDOkta

	Local aHeader := {}
	Local lRetorno := .t.
	Local cError := ""
	Local cAuxResult := ""
	Local cRetFromJson := ""
	Local cAuxMsg := ""
	Local lSchedule := FWGetRunSchedule()

	Local jsonParam := '{ "username": "' + self:_userName + '", "password": "' + self:_userPasswd + '"}'

	AADD( aHeader , "Accept: application/json" )
	AADD( aHeader , "Content-Type: application/json" )

	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath(self:_urlAuthN)
	self:oRest:setPostParams(jsonParam)
	
	lRetorno := self:oRest:Post(aHeader)

	//conout(" ")
	//fsConout("[        __   ___  __   __     __          ___  __        ___            ]", "[42m")
	//fsConout("[       /__` |__  /__` /__` | /  \ |\ |     |  /  \ |__/ |__  |\ |       ]", "[42m")
	//fsConout("[       .__/ |___ .__/ .__/ | \__/ | \|     |  \__/ |  \ |___ | \|       ]", "[42m")
	//fsConout("[                                                                        ]", "[42m")
	//conout(" ")
	//fsConout(self:oRest:cHost)
	//fsConout(self:oRest:cPath)
	//conout(" ")
	//fsConout(jsonParam, )
	//conout(" ")
	//fsConout("Retorno   " + cValToChar(lRetorno) ,)
	//conout(" ")
	//fsConout("HTTP Code " + cValToChar(self:oRest:GetHTTPCode()),)
	//conout(" ")
	//fsConout("Result " + cValToChar(self:oRest:GetResult()),)
	//conout(" ")

	If lRetorno
		cAuxResult := self:oRest:GetResult()
		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		If ValType(cRetFromJson) == "U" 
			self:_sessionToken := self:oJsonResult['sessionToken']
		Else
			cAuxMsg := STR0008 + CHR(13) + CHR(10) +; // "Não foi possível processar o retorno da chamada para obter o token da sessão"
				STR0009 + "(fromJson): " + cRetFromJson // "Retorno"

			self:_sessionToken := ""
			lRetorno := .f.
		EndIf

	Else

		cAuxResult := self:oRest:GetResult()
		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		If ValType(cRetFromJson) == "U" 
			cAuxMsg += STR0002 + ": " + self:oJsonResult:GetJsonText("errorCode") + chr(13) + chr(10) +; // "Código do Erro"
				STR0003 + ": " + IIf( self:oJsonResult:GetJsonText("errorSummary") == "Authentication failed" , STR0004, self:oJsonResult:GetJsonText("errorSummary") ) // Resumo do Erro // "Falha de autenticação"

			MsgStop(STR0001 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cAuxMsg , STR0005) // "Erro na obtenção do token de sessão (sessionToken)"
			cAuxMsg := ""

		Else
			cError := cValToChar(self:oRest:getLastError())
			
			cAuxMsg += STR0008 + CHR(13) + CHR(10) + ; // "Não foi possível processar o retorno da chamada para obter o token da sessão"
				IIf( ! Empty(cError) , "GetLastError: " + cValToChar(cError) + chr(13) + chr(10) , "" ) +;
				STR0009 + "(fromJson): " + cRetFromJson

			cAuxMsg += chr(13) + chr(10) + "HTTP Code: " + cValToChar(self:oRest:GetHTTPCode())
		EndIf

		self:_sessionToken := ""
		lRetorno := .f.
	EndIf

	//conout(" ")
	//fsConout("[                                                                   ]", "[42m")

	If ! lRetorno .and. ! Empty(cAuxMsg) .and. !lSchedule
		If Aviso(STR0005, cAuxMsg, { STR0013 ,"Ok"}, 3, "getSessionToken") == 1 // "Copiar retorno para Area de Transferência."
			CopytoClipboard(cAuxMsg + IIf( ! Empty( cAuxResult ) , CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0009 + ": " + CHR(13) + CHR(10) + cAuxResult , "" ) )
		EndIf

	EndIf

	aSize(aHeader,0)

Return lRetorno

Method _getCode() Class OFJDOkta
	
	Local aHeader := {}
	Local aAuxINPUT := {}
	Local cGetParam
	Local lRetorno
	Local nPos
	Local cAuxMsg := ""
	Local cAuxResult := ""
	Local lSchedule := FWGetRunSchedule()

	Local lAprError := .f.

	AADD(aHeader, "Accept: */*")
	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath('/oauth2/' + self:_cAuthServer + '/v1/authorize')
	self:oRest:setPostParams("")

	cGetParam := ;
		"client_id=" + cValToChar(self:_client_ID) + "&" + ;
		"response_type=code" + "&" + ;
		"response_mode=form_post" + "&" + ;
		"scope=" + cValToChar(self:_scope) + "&" + ;
		"redirect_uri=" + cValToChar(self:_cRedirect_URI) + "&" + ;
		"state=State" + "&" + ;
		"sessionToken=" + cValToChar(self:_sessionToken)

	lRetorno := self:oRest:Get(aHeader, cGetParam)
	
	//fsConout("[   __   __  ___  ___       __   __      __   __   __     __   __      __   ___              ___  __   __    __       __        __   ]", "[105m")
	//fsConout("[  /  \ |__)  |  |__  |\ | |  \ /  \    /  ` /  \ |  \ | / _` /  \    |  \ |__      /\  |  |  |  /  \ |__) |  /  /\  /  `  /\  /  \  ]", "[105m")
	//fsConout("[  \__/ |__)  |  |___ | \| |__/ \__/    \__, \__/ |__/ | \__> \__/    |__/ |___    /~~\ \__/  |  \__/ |  \ | /_ /~~\ \__, /~~\ \__/  ]", "[105m")
	//fsConout("[                                                                                                                                    ]", "[105m")
	//conout(" ")
	//fsConout(cGetParam)
	//conout(" ")
	//fsConout("Retorno   " + cValToChar(lRetorno))
	//conout(" ")
	//fsConout("HTTP Code " + cValToChar(self:oRest:GetHTTPCode()))
	//conout(" ")
	//Conout("Result")
	//conout(self:oRest:GetResult())
	//conout(" ")

	self:_codeAuthn := ""
	If lRetorno
		cAuxResult := self:oRest:GetResult()

		If self:oXMLManager:Parse(cAuxResult)
			aAuxINPUT := self:oXMLManager:XPathGetChildArray( "/html/body/form" )
			For nPos := 1 to Len(aAuxINPUT)

				aAuxAttr := self:oXMLManager:XPathGetAttArray( aAuxINPUT[nPos,2] )
				If aScan( aAuxAttr , { |x| x[1] == "name" .and. x[2] == "code" }) > 0
					self:_codeAuthn := aAuxAttr[aScan( aAuxAttr , { |x| x[1] == "value" } ), 2 ]
				EndIf
				If aScan( aAuxAttr , { |x| x[1] == "name" .and. x[2] == "error" }) > 0
					lRetorno := .f.
					//fsConout("[            __   ___  __   __   __           ___  __        __   __        ]","[101m]")
					//fsConout("[       /\  /  ` |__  /__` /__` /  \    |\ | |__  / _`  /\  |  \ /  \       ]","[101m]")
					//fsConout("[      /~~\ \__, |___ .__/ .__/ \__/    | \| |___ \__> /~~\ |__/ \__/       ]","[101m]")
					//fsConout("[                                                                           ]","[101m]")
					cAuxMsg += STR0002 + ": " + aAuxAttr[aScan( aAuxAttr , { |x| x[1] == "value" } ), 2 ] + chr(13) + chr(10)
				EndIf
				If aScan( aAuxAttr , { |x| x[1] == "name" .and. x[2] == "error_description" }) > 0
					cAuxMsg += STR0003 + ": " + aAuxAttr[aScan( aAuxAttr , { |x| x[1] == "value" } ), 2 ] + chr(13) + chr(10)
				EndIf
			Next nPos
		Else
			cAuxMsg := STR0010 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; 
				"Error (TXMLManager): " + self:oXMLManager:Error()

			lRetorno := .f.

		EndIf
	Else
		//fsConout(cValToChar(self:oRest:GETLASTERROR()))
		cAuxMsg += "Last error: " + cValToChar(self:oRest:GETLASTERROR()) + chr(13) + chr(10) +;
			"HTTP Code " + cValToChar(self:oRest:GetHTTPCode())
	EndIf

	If Empty(self:_codeAuthn) .and. lRetorno
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __      __   __   __     __   __  ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \    /  ` /  \ |  \ | / _` /  \ ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/    \__, \__/ |__/ | \__> \__/ ")
		//Conout("                                                                                                                      ")
		//Conout(chr(27) + "[0m")
		lRetorno := .f.
	EndIf

	If ! lRetorno .and. !lSchedule

		cAuxMsg += chr(13) + chr(10) + chr(13) + chr(10) + STR0006 + chr(13) + chr(10) +; // Parâmetros de conexão:
			"URL: " + cValtoChar(self:_cURL) + chr(13) + chr(10) +;
			"Path: " + '/oauth2/' + cValtoChar(self:_cAuthServer) + '/v1/authorize' + chr(13) + chr(10) +;
			"Auth. Server: " + cValtoChar(self:_cAuthServer) + chr(13) + chr(10) +;
			"Scope:" + cValToChar(self:_scopeParam) + CHR(13) + CHR(10) + ;
			"Redirect:" + cValToChar(self:_cRedirect_URI) + CHR(13) + CHR(10) + ;
			"State: State" + CHR(13) + CHR(10) // Parâmetros de conexão:

		lAprError := self:_getError(self:oRest:GetHTTPCode(),self:oRest:GetResult())

		if !lAprError
			If Aviso(STR0005, cAuxMsg, { STR0013 ,"Ok"}, 3, "getCode") == 1 // "Copiar retorno para Area de Transferência."
				CopytoClipboard(cAuxMsg + IIf( ! Empty( cAuxResult ) , CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0009 + ": " + CHR(13) + CHR(10) + cAuxResult , "" ) )
			EndIf
		EndIf

	EndIf

	aSize(aHeader,0)
	aSize(aAuxINPUT,0)

	//conout(" ")
	//fsConout("[                                                                   ]", "[105m")


Return lRetorno

Method _getAccessToken() Class OFJDOkta
	Local cGetParam
	Local lRetorno

	cGetParam := ;
		"grant_type=authorization_code" + "&" + ;
		"redirect_uri=" + cValToChar(self:_cRedirect_URI) + "&" + ;
		"scope=" + cValToChar(self:_scope) + "&" + ;
		"code=" + cValtoChar(self:_codeAuthn)

	lRetorno := self:_postToken(cGetParam)

Return lRetorno

Method _getDTFAccessToken() Class OFJDOkta
	Local cGetParam
	Local lRetorno

	cGetParam := ;
		"grant_type=client_credentials" + "&" + ;// JOSE LUIS VERIFICAR QUAL O GRANT_TYPE
		"scope=" + cValToChar(self:_scope) + "&" +;
		"client_id=" + cValToChar(self:_client_ID) + "&" +;
		"client_secret=" + cValToChar(self:_client_Secret)
	
	lRetorno := self:_postTokenDTF(cGetParam)

Return lRetorno

Method _getTokenRefresh() Class OFJDOkta
	Local cGetParam
	Local lRetorno

	cGetParam := ;
		"grant_type=refresh_token" + "&" +;
		"redirect_uri=" + cValToChar(self:_cRedirect_URI) + "&" +;
		"scope=" + cValToChar(self:_scope) + "&" +;
		"refresh_token=" + cValToChar(self:_RefreshToken)

	lRetorno := self:_postToken(cGetParam)

Return lRetorno

Method _postToken(cGetParam) Class OFJDOkta

	Local lRetorno := .t.
	Local aHeader := {}
	Local cAuxMsg := ""
	Local cAuxResult := ""
	Local cRetFromJson := ""
	Local lSchedule := FWGetRunSchedule()

	AADD( aHeader , "Accept: application/json" )
	AADD( aHeader , "Content-Type: application/x-www-form-urlencoded" )
	AADD( aHeader , "Authorization: Basic " + Encode64(self:_client_ID + ":" + self:_client_Secret) )

	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath('/oauth2/' + self:_cAuthServer + '/v1/token')

	self:_AccessToken := ""
	self:oRest:SetPostParams(cGetParam)

	lRetorno := self:oRest:Post(aHeader)

	//conout(" ")
	//fsConout("[       __   __   __  ___    ___  __        ___            ]","[46m")
	//fsConout("[      |__) /  \ /__`  |      |  /  \ |__/ |__  |\ |       ]","[46m")
	//fsConout("[      |    \__/ .__/  |      |  \__/ |  \ |___ | \|       ]","[46m")
	//fsConout("[                                                          ]","[46m")
	//conout(" ")
	//fsConout(cGetParam)
	//conout(" ")
	//fsConout("Retorno   " + cValToChar(lRetorno))
	//conout(" ")
	//fsConout("HTTP Code " + cValToChar(self:oRest:GetHTTPCode()))
	//conout(" ")

	If lRetorno
		
		//fsConout(self:oRest:GetResult())
		//conout(" ")

		cAuxResult := self:oRest:GetResult()

		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		If ValType(cRetFromJson) == "U" 
			self:_DateCreate := DtoS(Date())
			self:_TimeCreate := Time()

			self:_AccessToken := self:oJsonResult:GetJsonText("access_token")
			self:_ExpiresInSeconds := Val(self:oJsonResult:GetJsonText("expires_in"))
			self:_IDToken := self:oJsonResult:GetJsonText("id_token")
			self:_RefreshToken := cValToChar(self:oJsonResult:GetJsonText("refresh_token"))
			self:_auxProfile := Array(6)
			self:_auxProfile[PROF_TIMETOKEN]    := self:_TimeCreate
			self:_auxProfile[PROF_EXPIREIN]     := self:_ExpiresInSeconds
			self:_auxProfile[PROF_ACCESSTOKEN]  := self:_AccessToken
			self:_auxProfile[PROF_REFRESHTOKEN] := IIf( self:_RefreshToken <> "null" , self:_RefreshToken , "" )
			self:_auxProfile[PROF_IDTOKEN]      := self:_IDToken
			self:_auxProfile[PROF_DATETOKEN]    := self:_DateCreate
		Else
			cAuxMsg := STR0011 + "(_postToken)" + CHR(13) + CHR(10) +; // "Não foi possível processar o retorno da chamada para obter o token."
				STR0009 + "(fromJson): " + cRetFromJson // "Retorno"

			lRetorno := .f.
		EndIf

	Else
		//Conout(" ")
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __     ___  __        ___      ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \     |  /  \ |__/ |__  |\ | ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/     |  \__/ |  \ |___ | \| ")
		//Conout("                                                                                                                   ")
		//Conout(chr(27) + "[0m")
		//Conout(" ")
		//Conout( self:oRest:GetLastError() )
		//Conout("")
		cAuxMsg += "Last error: " + cValToChar(self:oRest:GetLastError()) + chr(13) + chr(10) +;
			"HTTP Code " + cValToChar(self:oRest:GetHTTPCode())

		lRetorno := .f.
	EndIf

	If Empty(self:_AccessToken)
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __           __   __   ___  __   __     ___  __        ___      ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \     /\  /  ` /  ` |__  /__` /__`     |  /  \ |__/ |__  |\ | ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/    /~~\ \__, \__, |___ .__/ .__/     |  \__/ |  \ |___ | \| ")
		//Conout("                                                                                                                                                    ")
		//Conout(chr(27) + "[0m")
		lRetorno := .f.
	EndIf

	If !lRetorno .and. !lSchedule
		cAuxMsg := STR0012 + chr(13) + chr(10) + chr(13) + chr(10) + cAuxMsg // "Erro na obtenção do token."

		If Aviso(STR0005, cAuxMsg, { STR0013 ,"Ok"}, 3, "postToken") == 1 // "Copiar retorno para Area de Transferência."
			CopytoClipboard(cAuxMsg + IIf( ! Empty( cAuxResult ) , CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0009 + ": " + CHR(13) + CHR(10) + cAuxResult , "" ) )
		EndIf

	EndIf

	//conout(" ")
	//fsConout("[                                                                   ]", "[46m")

Return lRetorno


Method _postTokenDTF(cGetParam) Class OFJDOkta

	Local lRetorno := .t.
	Local aHeader := {}
	Local cAuxMsg := ""
	Local cAuxResult := ""
	Local cRetFromJson := ""
	Local lSchedule := FWGetRunSchedule()

	AADD( aHeader , "Content-Type: application/x-www-form-urlencoded" )

	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath('/oauth2/' + self:_cAuthServer + '/v1/token')

	self:_AccessToken := ""
	self:oRest:SetPostParams(cGetParam)

	lRetorno := self:oRest:Post(aHeader)

	//conout(" ")
	//fsConout("[       __   __   __  ___    ___  __        ___            ]","[46m")
	//fsConout("[      |__) /  \ /__`  |      |  /  \ |__/ |__  |\ |       ]","[46m")
	//fsConout("[      |    \__/ .__/  |      |  \__/ |  \ |___ | \|       ]","[46m")
	//fsConout("[                                                          ]","[46m")
	//conout(" ")
	//fsConout(cGetParam)
	//conout(" ")
	//fsConout("Retorno   " + cValToChar(lRetorno))
	//conout(" ")
	//fsConout("HTTP Code " + cValToChar(self:oRest:GetHTTPCode()))
	//conout(" ")

	If lRetorno
		
		//fsConout(self:oRest:GetResult())
		//conout(" ")

		cAuxResult := self:oRest:GetResult()

		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		If ValType(cRetFromJson) == "U" 
			self:_DateCreate := DtoS(Date())
			self:_TimeCreate := Time()

			self:_AccessToken := self:oJsonResult:GetJsonText("access_token")
			self:_ExpiresInSeconds := Val(self:oJsonResult:GetJsonText("expires_in"))
			self:_IDToken := self:oJsonResult:GetJsonText("id_token")
			self:_RefreshToken := ""
			
		Else
			cAuxMsg := STR0011 + "(_postTokenDTF)" + CHR(13) + CHR(10) +; // "Não foi possível processar o retorno da chamada para obter o token."
				STR0009 + "(fromJson): " + cRetFromJson // "Retorno"

			lRetorno := .f.
		EndIf

	Else
		//Conout(" ")
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __     ___  __        ___      ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \     |  /  \ |__/ |__  |\ | ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/     |  \__/ |  \ |___ | \| ")
		//Conout("                                                                                                                   ")
		//Conout(chr(27) + "[0m")
		//Conout(" ")
		//Conout( self:oRest:GetLastError() )
		//Conout("")
		cAuxMsg += "Last error: " + cValToChar(self:oRest:GetLastError()) + chr(13) + chr(10) +;
			"HTTP Code " + cValToChar(self:oRest:GetHTTPCode())

		lRetorno := .f.
	EndIf

	If Empty(self:_AccessToken)
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __           __   __   ___  __   __     ___  __        ___      ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \     /\  /  ` /  ` |__  /__` /__`     |  /  \ |__/ |__  |\ | ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/    /~~\ \__, \__, |___ .__/ .__/     |  \__/ |  \ |___ | \| ")
		//Conout("                                                                                                                                                    ")
		//Conout(chr(27) + "[0m")
		lRetorno := .f.
	EndIf

	If ! lRetorno .and. !lSchedule
		cAuxMsg := STR0012 + chr(13) + chr(10) + chr(13) + chr(10) + cAuxMsg // "Erro na obtenção do token."

		If Aviso(STR0005, cAuxMsg, { STR0013 ,"Ok"}, 3, "postToken") == 1 // "Copiar retorno para Area de Transferência."
			CopytoClipboard(cAuxMsg + IIf( ! Empty( cAuxResult ) , CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0009 + ": " + CHR(13) + CHR(10) + cAuxResult , "" ) )
		EndIf

	EndIf

	//conout(" ")
	//fsConout("[                                                                   ]", "[46m")

Return lRetorno



Static Function fsConout(cTexto, cCor)
	Default cCor := ""

	If ! Empty(cCor)
		cCor := chr(27) + cCor
	EndIf

	Conout(cCor + cTexto + chr(27) + "[0m")

Return

Method _getError(cHttpCode, cHtml) Class OFJDOkta

	local cLocal:= "file:///"+GetSrvProfString("RootPath","")
	local cFile := "\system\error400_"+DtoS(dDataBase)+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2)+".html"
	local nHdl := 0
	local lRetorno := .f.

	Default cHttpCode := ""

	If cHttpCode == "400"

		nHdl := Fcreate( cFile ,,,.f.)
		If nHdl < 0
			FMX_HELP("INIHANDLE", STR0014 + CHR(13) + CHR(10) + cFile + CHR(13) + CHR(10) + "FError() " + Str(FERROR(),4) , STR0015)
			return
		EndIf

		FWRITE(nHdl,EncodeUtf8(cHtml))

		FClose(nHdl)

		cLocal := StrTran(cLocal+StrTran(cFile,"\","/"),"\","/")

		DEFINE DIALOG oDlg TITLE "Error 400" FROM 180,180 TO 550,1124 PIXEL
			// Prepara o conector WebSocket
			PRIVATE oWebChannel := TWebChannel():New()
			nPort := oWebChannel:connect()
			
			// Cria componente
			PRIVATE oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100,, nPort)
			oWebEngine:bLoadFinished := {|self,url| conout(STR0016 + url) }
			oWebEngine:navigate(cLocal)
			oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
		
		ACTIVATE DIALOG oDlg CENTERED

		lRetorno := .t.

		Dele File &(cLocal)

	EndIf

Return lRetorno
