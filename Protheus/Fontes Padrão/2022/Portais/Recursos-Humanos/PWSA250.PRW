#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA250.CH"

Web Function PWSA250()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"	
		fGetInfRotina("W_PWSA250.APW")
		GetMat()					
		cHtml := ExecInPage("PWSA250")
	WEB EXTENDED END
Return cHtml

Web Function PWSA250A()
	Local cHtml   	:= ""
	Local oWSReceipts
	Private nCurrentPage
	Private nPageTotal
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
	 	Default HttpGet->Page:= "1"
	 	Default HttpGet->FilterField:= ""
		Default HttpGet->FilterValue:= ""	 	
	 	nCurrentPage:= Val(HttpGet->Page)

		oWSReceipts  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHAnnualReceipts"), WSRHAnnualReceipts():New())
		WsChgURL(@oWSReceipts, "RHANNUALRECEIPTS.APW")
		                     
		oWSReceipts:cRegistration	:= HttpSession->aUser[3] //Filial
		oWSReceipts:cBranch	 		:= HttpSession->aUser[2] //Matricula
		oWSReceipts:cFilterField	:= HttpGet->FilterField
		oWSReceipts:cFilterValue	:= HttpGet->FilterValue	
		oWSReceipts:nCurrentPage	:= nCurrentPage

	
		If oWSReceipts:BrowseAnnualReceipts()
			aAnnualReceipts	:= oWSReceipts:oWSBrowseAnnualReceiptsResult:oWSItens:oWSTAnnualReceiptsList
			nPageTotal		:= 1 //oWSReceipts:oWSBrowseAnnualReceiptsResult:nPagesTotal
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf

		cHtml := ExecInPage( "PWSA250A" )	
	WEB EXTENDED END

Return cHtml


Web Function PWSA250B()
	Local cHtml   	:= ""
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		oWSReceipts  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHAnnualReceipts"), WSRHAnnualReceipts():New())
		WsChgURL(@oWSReceipts, "RHANNUALRECEIPTS.APW")
		oWSReceipts:cRegistration	:= HttpGet->Mat 	//Matricula
		oWSReceipts:cBranch	 		:= HttpGet->Branch	//Filial		
		oWSReceipts:cTaxYear		:= HttpGet->TaxYear		
		oWSReceipts:cDMRelease		:= HttpGet->DMRelease		
		oWSReceipts:cDMReport		:= HttpGet->DMReport		
		oWSReceipts:cResponsible	:= HttpGet->Responsible
		oWSReceipts:cCompany		:= HttpGet->Company

		//Envia dados de Origem para busca de dados de Transferencias
		oWSReceipts:cBrcOrigin	:= HttpSession->aUser[2] // Filial
		oWSReceipts:cRegOrigin	:= HttpSession->aUser[3] // Matricula
		
		If !Empty(HttpSession->aUser) .and. ;
			( AllTrim(HttpSession->aUser[3]) == AllTrim(HttpGet->Mat) .Or.;
			( AllTrim(HttpSession->aUser[1]) == AllTrim(HttpSession->cParticipantID) .And. oWSReceipts:TransfAnnualReceipt()) )

			If oWSReceipts:GetAnnualReceipt()
				cHtml	:= oWSReceipts:cGetAnnualReceiptResult			
			Else
				HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { "Erro", STR0016, "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf	
		
	WEB EXTENDED END
	
	
Return cHtml
