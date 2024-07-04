#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA240.CH"

Web Function PWSA240()
	Local cHtml   	:= ""
	
	HttpSession->cTypeRequest 	:= "J"		// GAPS de Habilidades
	HttpGet->titulo				:= STR0001	//"GAPS de Habilidades"
	HttpGet->objetivo			:= STR0003	//"Verificar as diferenças entre as pontuações das competências do funcionário e as pontuações competências exigidas pelo cargo."
	HttpSession->aStructure 	:= {} 
	HttpSession->cHierarquia 	:= ""
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		fGetInfRotina("W_PWSA240.APW")
		GetMat()
			    
		cHtml := ExecInPage("PWSA260A")	
	WEB EXTENDED END
Return cHtml

Web Function PWSA241()
	Local cHtml:= ""
	Local oWSAbilities
	Private aFields
	Private aAbilities
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"
	
		HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]			
		
		oWSAbilities := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHABILITIES"), WSRHABILITIES():New())
		WsChgURL(@oWSAbilities, "RHABILITIES.APW")
				
		oWSAbilities:cBranch 		:= HttpSession->DadosFunc:cEmployeeFilial
		oWSAbilities:cRegistration 	:= HttpSession->DadosFunc:cRegistration
			
		If oWSAbilities:GetAbilitiesGAP()
			oEmployee	:= oWSAbilities:oWSGetAbilitiesGAPResult:oWSEmployee
			aGAPS		:= oWSAbilities:oWSGetAbilitiesGAPResult:oWSGAPS:oWSTAbilitiesGAP
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA240.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
			
		cHtml += ExecInPage("PWSA241")
	WEB EXTENDED END	
Return cHtml