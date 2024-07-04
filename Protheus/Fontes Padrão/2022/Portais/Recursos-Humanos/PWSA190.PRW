#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"  

Web Function PWSA190()
	Local cHtml   := ""

	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"
		fGetInfRotina("W_PWSA190.APW")
		GetMat()
					
		cHtml := ExecInPage("PWSA190")
	WEB EXTENDED END
Return cHtml

Web Function PWSA190A()
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
	 	
		oWSVacation  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVacationReceipts"), WSRHVacationReceipts():New())
		WsChgURL(@oWSVacation, "RHVACATIONRECEIPTS.APW")
		                     
		oWSVacation:cRegistration	:= HttpSession->aUser[3] //Filial
		oWSVacation:cBranch	 		:= HttpSession->aUser[2] //Matricula
		oWSVacation:cFilterField		:= HttpGet->FilterField
		oWSVacation:cFilterValue		:= HttpGet->FilterValue	
		oWSVacation:nCurrentPage	 	:= nCurrentPage

	
		If oWSVacation:BrowseVacationReceipts()
			aVacationReceipts	:= oWSVacation:oWSBrowseVacationReceiptsResult:oWSItens:oWSTVacationReceiptsList		//oWSListOFPOSTS:oWSDATAPOSTOS
			nPageTotal			:= oWSVacation:oWSBrowseVacationReceiptsResult:nPagesTotal
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf

		cHtml := ExecInPage( "PWSA190A" )	
	WEB EXTENDED END

Return cHtml







Web Function PWSA191()
	Local cHtml   := ""
	Local oWSVacation
	Local oWSConfig
	Private oVacationReceipt	
	Private aLancamentos
	Private cPaisLoc:= ""
	Private cMessage	:= ""
	    
	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"
		oWSConfig  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oWSConfig,"CFGDICTIONARY.APW")

		If oWSConfig:GetParam("MSALPHA", "MV_PAISLOC")
			cPaisLoc:= oWSConfig:cGetParamResult
		EndIf

		oWSVacation  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVacationReceipts"), WSRHVacationReceipts():New())
		WsChgURL(@oWSVacation, "RHVACATIONRECEIPTS.APW")
							
		oWSVacation:cRegistration	:= HttpSession->aUser[3] //Filial
		oWSVacation:cBranch	 		:= HttpSession->aUser[2] //Matricula
		oWSVacation:dAcquisitiveStartDate	:= CTOD(HttpGet->AcquisitiveStartDate)
		oWSVacation:dEnjoymentStartDate		:= CTOD(HttpGet->EnjoymentStartDate)
                          
		If oWSVacation:GetVacationReceipt()
			oVacationReceipt:= oWSVacation:oWSGetVacationReceiptResult
			aLancamentos	:= oWSVacation:oWSGetVacationReceiptResult:oWSItens:oWSTVacationReceiptsItem
			If oWSVacation:GetMessage() 
				cMessage		:= oWSVacation:CGETMESSAGERESULT
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf	
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
			
		cHtml := ExecInPage("PWSA191")
	WEB EXTENDED END
Return cHtml



