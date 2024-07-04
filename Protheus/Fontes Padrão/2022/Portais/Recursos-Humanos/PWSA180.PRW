#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA180.CH"  
#DEFINE PAGE_LENGTH 10

Web Function PWSA180()
	Local cHtml   := ""

	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		fGetInfRotina("W_PWSA180.APW")
		GetMat()
					
		cHtml := ExecInPage("PWSA180")
	WEB EXTENDED END
Return cHtml

Web Function PWSA180A()
	Local cHtml   	:= ""
	Local oWSPayment
	Private nCurrentPage
	Private nPageTotal

	HttpSession->nPageLength  := PAGE_LENGTH
	HttpSession->nPageTotal   := 0
	HttpSession->nCurrentPage := 0
	HttpSession->aReceipts    := {}

	HttpCTType("text/html; charset=ISO-8859-1")	 
	
	WEB EXTENDED INIT cHtml START "InSite"
	 	Default HttpGet->Page:= "1"
	 	Default HttpGet->FilterField:= ""
		Default HttpGet->FilterValue:= ""	 	
	 	nCurrentPage := Val(HttpGet->Page)
	 	
	 	If Type("cUsuario") != "U"
	 		PutGlbValue('CUSUARIO', httpSession->RHMAT) // Atribui valor na variavel pública
	 	EndIf
	 	
		oWSPayment  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPaymentReceipts"), WSRHPaymentReceipts():New()) 
		WsChgURL(@oWSPayment, "RHPAYMENTRECEIPTS.APW")
		                     
		oWSPayment:cBranch	 		:= HttpSession->aUser[2] //Filial
		oWSPayment:cRegistration    := HttpSession->aUser[3] //Matricula
		oWSPayment:cFilterField		:= HttpGet->FilterField
		oWSPayment:cFilterValue		:= HttpGet->FilterValue	
		oWSPayment:nCurrentPage	 	:= nCurrentPage
		oWSPayment:cRHMat 			:= httpSession->RHMAT
	
	
		If oWSPayment:BrowsePaymentReceipts()
			aPaymentReceipts	:= oWSPayment:oWSBrowsePaymentReceiptsResult:oWSItens:oWSTPaymentReceiptsList
			nPageTotal			:= oWSPayment:oWSBrowsePaymentReceiptsResult:nPagesTotal			
			HttpSession->aReceipts := oWSPayment:oWSBrowsePaymentReceiptsResult:oWSItens:oWSTPaymentReceiptsList
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf

		cHtml := ExecInPage( "PWSA180A" )	
	WEB EXTENDED END

Return cHtml

Web Function PWSA181()
	Local cHtml		:= ""
	Local oWSPayment
	Local nCount	:= 0
	Local lValidURL	:= .F.
	Private oPaymentReceipt	
	Private aLancamentos
	
	HttpCTType("text/html; charset=ISO-8859-1")	
    
	WEB EXTENDED INIT cHtml START "InSite"
		oWSPayment  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPaymentReceipts"), WSRHPaymentReceipts():New()) 
		WsChgURL(@oWSPayment, "RHPAYMENTRECEIPTS.APW")

		oWSPayment:cBranch       := HttpGet->FilFunc
		oWSPayment:cRegistration := HttpGet->MatFunc		
		oWSPayment:nMonth        := Iif(Val(HttpGet->Month) == 13, 12, Val(HttpGet->Month))
		oWSPayment:nYear         := Val(HttpGet->Year)
		oWSPayment:cWeek         := HttpGet->Week
		oWSPayment:nType         := Val(HttpGet->Type)
		oWSPayment:lArchived     := IIF(HttpGet->Archived == "1", .T., .F.)				
		oWSPayment:cRHBranch     := HttpSession->aUser[2]
		oWSPayment:cRHReg        := HttpSession->aUser[3]
		oWSPayment:cRHMat        := httpSession->RHMAT
		oWSPayment:cCompany      := Alltrim(HttpGet->EmpFunc)
		
		For nCount := 1 to Len(HttpSession->aReceipts)
			If	( HttpSession->aReceipts[nCount]:nYear	== oWSPayment:nYear	) .And.;
				( HttpSession->aReceipts[nCount]:nMonth	== oWSPayment:nMonth) .And.;
				( HttpSession->aReceipts[nCount]:cWeek	== oWSPayment:cWeek	) .And.;
				( HttpSession->aReceipts[nCount]:nType	== oWSPayment:nType	)
					lValidURL := .T.
			EndIf
		Next nCount

		If !lValidURL
			Return RhAlert( Nil, STR0001, STR0002, "W_PWSA000.APW" ) //"Erro", "Dados não conferem!"
		Else	
			If oWSPayment:GetPaymentReceipt()
				oPaymentReceipt	:= oWSPayment:oWSGetPaymentReceiptResult
				aLancamentos	:= oWSPayment:oWSGetPaymentReceiptResult:oWSItens:oWSTPaymentReceiptsItem
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		EndIf
			
		cHtml := ExecInPage("PWSA181")
	WEB EXTENDED END
Return cHtml
