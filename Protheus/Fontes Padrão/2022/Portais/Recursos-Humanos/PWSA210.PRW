#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA210.CH"

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    25/09/2014        ³  256417   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 
Web Function PWSA210()
	Local cHtml   			:= ""
	HttpCTType("text/html; charset=ISO-8859-1")	
	HttpSession->cTypeRequest 	:= "L"		// Afastamento
	HttpGet->titulo				:= STR0001	//"Consulta de Afastamentos"
	HttpGet->objetivo			:= STR0003	//"Disponibiliza para consulta as informações dos afastamentos registrados para o funcionário. Permite também a visualização dos afastamentos dos membros de sua equipe."
	HttpSession->aStructure 	:= {} 
	HttpSession->cHierarquia 	:= ""
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		fGetInfRotina("W_PWSA210.APW")
		GetMat()
			    
		cHtml := ExecInPage("PWSA260A")	
	WEB EXTENDED END
Return cHtml

Web Function PWSA211()
	Local cHtml:= ""
	Local oWSAbsences
	Private aFields
	Private aAbsences
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"
		HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]
		oWSAbsences := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHAbsences"), WSRHAbsences():New())
		WsChgURL(@oWSAbsences, "RHABSENCES.APW",,,GetEmpFun())
		
		oWSAbsences:cBranch			:= HttpSession->DadosFunc:cEmployeeFilial
  		oWSAbsences:cRegistration	:= HttpSession->DadosFunc:cRegistration 

		If oWSAbsences:BrowseAbsences()
			aAbsences:= oWSAbsences:oWSBrowseAbsencesResult:oWSAbsences:oWSTabsence
			aFields:= oWSAbsences:oWSBrowseAbsencesResult:oWSLocaleFields:oWSTLocaleFields
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA210.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
			
		cHtml += ExecInPage("PWSA211")
	WEB EXTENDED END	
Return cHtml


Web Function PWSA212()
	Local cHtml:= ""
	Local oWSAbsences
	Private aFields
	Private oAbsence

	HttpCTType("text/html; charset=ISO-8859-1")	

	WEB EXTENDED INIT cHtml START "InSite"
		DEFAULT HttpGet->Branch	 		:= HttpSession->DadosFunc:cEmployeeFilial
		DEFAULT HttpGet->Registration	:= HttpSession->DadosFunc:cRegistration 
		
		oWSAbsences := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHAbsences"), WSRHAbsences():New())
		WsChgURL(@oWSAbsences, "RHABSENCES.APW",,,GetEmpFun())
		
		oWSAbsences:cBranch	 		:= HttpSession->DadosFunc:cEmployeeFilial
		oWSAbsences:cRegistration	:= HttpSession->DadosFunc:cRegistration 
		oWSAbsences:cSequence		:= HttpGet->Sequence
	
		If oWSAbsences:GetAbsence()
			oAbsence:= oWSAbsences:oWSGetAbsenceResult:oWSAbsence
			aFields:= oWSAbsences:oWSGetAbsenceResult:oWSLocaleFields:oWSTLocaleFields
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA210.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
			
		cHtml += ExecInPage("PWSA212")
	WEB EXTENDED END	
Return cHtml
