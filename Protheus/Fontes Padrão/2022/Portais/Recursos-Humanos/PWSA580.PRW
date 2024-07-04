#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"  

Web Function PWSA580()
	Local cHtml   := ""

	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"
		fGetInfRotina("W_PWSA580.APW")
		GetMat()
					
		cHtml := ExecInPage("PWSA580")
	WEB EXTENDED END
Return cHtml

Web Function PWSA580A()
	Local cHtml   	:= ""
	Local oWSVacation
	Private nCurrentPage
	Private nPageTotal
	Private cLink:= "W_PWSA152.APW"	
	Private aPostos:= {}
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"
	 	Default HttpGet->Page:= "1"
	 	Default HttpGet->FilterField:= ""
		Default HttpGet->FilterValue:= ""	 	
	 	nCurrentPage:= Val(HttpGet->Page)
	 	
		oWSVacation  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVacationNotice"), WSRHVacationNotice():New())
		WsChgURL(@oWSVacation, "RHVACATIONNOTICE.APW")
		                     
		oWSVacation:cRegistration	:= HttpSession->aUser[3] //Filial
		oWSVacation:cBranch	 		:= HttpSession->aUser[2] //Matricula
		oWSVacation:cFilterField	:= HttpGet->FilterField
		oWSVacation:cFilterValue	:= HttpGet->FilterValue	
		oWSVacation:nCurrentPage 	:= nCurrentPage

	
		If oWSVacation:BrowseVacationNotice()
			aVacationNotice		:= oWSVacation:oWSBrowseVacationNoticeResult:oWSItens:oWSTVacationNoticeList
			nPageTotal			:= oWSVacation:oWSBrowseVacationNoticeResult:nPagesTotal
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf

		cHtml := ExecInPage( "PWSA580A" )	
	WEB EXTENDED END

Return cHtml

Web Function PWSA581()
	Local cHtml   := ""
	Local oWSVacation
	Local oWSConfig
	Private oVacationNotice	
	Private aLancamentos
	Private cPaisLoc	:= ""
	Private cMessage	:= ""
	    
	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"
		oWSConfig  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oWSConfig,"CFGDICTIONARY.APW")

		If oWSConfig:GetParam("MSALPHA", "MV_PAISLOC")
			cPaisLoc:= oWSConfig:cGetParamResult
		EndIf

		oWSVacation  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVacationNotice"), WSRHVacationNotice():New())
		WsChgURL(@oWSVacation, "RHVACATIONNOTICE.APW")
							
		oWSVacation:cRegistration			:= HttpSession->aUser[3] //Filial
		oWSVacation:cBranch	 				:= HttpSession->aUser[2] //Matricula
		oWSVacation:dAcquisitiveStartDate	:= CTOD(HttpGet->AcquisitiveStartDate)
		oWSVacation:dAcquisitiveEndDate		:= CTOD(HttpGet->AcquisitiveEndDate)
		oWSVacation:dEnjoymentStartDate		:= CTOD(HttpGet->EnjoymentStartDate)
		oWSVacation:dEnjoymentEndDate		:= CTOD(HttpGet->EnjoymentEndDate)
		oWSVacation:nPecuniaryAllowance		:= Val(HttpGet->PecuniaryAllowance)
		oWSVacation:cNoticeType				:= HttpGet->NoticeType
		//oWSVacation:cNoticeAcceptance		:= If(Empty(HttpGet->NoticeAcceptance),"",HttpGet->NoticeAcceptance)

		If oWSVacation:GetVacationNotice()
			oVacationNotice:= oWSVacation:oWSGetVacationNoticeResult
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf		
		
		cTipo := HttpGet->NoticeType 

		cHtml := ExecInPage("PWSA581")
		
	WEB EXTENDED END
Return cHtml

Web Function PWSA580B()
Local cHtml := ""
Local oWSVacation

	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"
		Default HttpGet->StartDate := ""	 
	
		oWSVacation  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVacationNotice"), WSRHVacationNotice():New())		
		WsChgURL(@oWSVacation, "RHVACATIONNOTICE.APW")
								
		oWSVacation:cBranch	 			:= HttpSession->aUser[2] //Filial
		oWSVacation:cRegistration		:= HttpSession->aUser[3] //Matricula
		oWSVacation:dEnjoymentStartDate	:= CTOD(HttpGet->StartDate) //Data Inicial das Ferias
		
		oWSVacation:AcceptNotice()
	
		cHtml := ExecInPage( "PWSA580" )
	WEB EXTENDED END
Return cHtml
