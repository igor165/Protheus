#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

Web Function PWSA280()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"	
		fGetInfRotina("W_PWSA280.APW")
		GetMat()					
		cHtml := ExecInPage("PWSA280")
	WEB EXTENDED END	
Return cHtml

Web Function PWSA280A()
	Local cHtml   	:= ""
	Local oWSExtract
	Private nCurrentPage
	Private nPageTotal
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
	 	Default HttpGet->Page:= "1"
	 	Default HttpGet->FilterField:= ""
		Default HttpGet->FilterValue:= ""	 	
	 	nCurrentPage:= Val(HttpGet->Page)
	 	
		oWSExtract  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRHExtract"), WsRHExtract():New()) 
		WsChgURL(@oWSExtract, "RHEXTRACT.apw")
		                     
		oWSExtract:cRegistration	:= HttpSession->aUser[3] //Filial
		oWSExtract:cBranch	 		:= HttpSession->aUser[2] //Matricula
		oWSExtract:cFilterField		:= HttpGet->FilterField
		oWSExtract:cFilterValue		:= HttpGet->FilterValue	
		oWSExtract:nCurrentPage		:= nCurrentPage

	
		If oWSExtract:BrowseExtract()
			aExtract	:= oWSExtract:oWSBrowseExtractResult:oWSItens:oWSTExtractList
			nPageTotal	:= oWSExtract:oWSBrowseExtractResult:nPagesTotal
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf

		cHtml := ExecInPage( "PWSA280A" )	
	WEB EXTENDED END

Return cHtml
