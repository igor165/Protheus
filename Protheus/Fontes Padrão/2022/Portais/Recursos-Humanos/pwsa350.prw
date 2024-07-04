#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA350.CH"
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    31/07/2014        ³  243473   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/  
Web Function PWSA350()
	Local cHtml   	:= ""
    
	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "M"	 //"Competencia"    
      HttpSession->cCargoSimulado := ""    

		HttpGet->titulo           := STR0001 	  
		HttpGet->objetivo         := STR0002
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		
		fGetInfRotina("W_PWSA350.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA350A")
	WEB EXTENDED END
Return cHtml 

Web Function PWSA351()
   Local oWSCompetence
   Local nI              := 0
	Local cHtml   			:= ""
	Private aReturns			:= {}
	Private cIndice			:= If(HttpGet->nIndice == Nil ,HttpGet->cIndFun, HttpGet->nIndice) 	
		
	HttpCTType("text/html; charset=ISO-8859-1")
	HttpSession->DadosFunc := HttpSession->aStructure[val(cIndice)]
   //HttpPost->DadosFunc   := HttpSession->aStructure[val(HttpGet->nIndice)]
   HttpGet->titulo       := STR0001
   	
	WEB EXTENDED INIT cHtml START "InSite"	
		oWSCompetence := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCompetence"), WSRHCompetence():New())
		WsChgURL(@oWSCompetence, "RHCompetence.APW")	 
		                 
		oWSCompetence:cRegistration		 := HttpSession->DadosFunc:cRegistration  
		oWSCompetence:cBranch	 		 := HttpSession->DadosFunc:cEmployeeFilial
      oWSCompetence:cPositionID       := HttpSession->DadosFunc:cPositionID

      HttpSession->cCargoSimulado     := "" 
      HttpSession->cCargoSimuladoDesc  := "" 
      If ValType( HttpPost->txtcargo ) != "U"
          IF HttpPost->txtcargo != ""
             HttpSession->cCargoSimulado    := HttpPost->txtcargo 
             HttpSession->cCargoSimuladoDesc := HttpPost->txtCD 
             oWSCompetence:cPositionID      := HttpPost->txtcargo
          EndIF   
      EndIF                
		
		//Busca avaliacao de desempenho				
		If oWSCompetence:GetCompetence()
			aReturns		:= oWSCompetence:oWSGetCompetenceResult:oWsItens:oWsTCompetenceData
         HttpGet->Competencias := ""   
         HttpGet->ValoresCargo := ""
         HttpGet->ValoresFunc  := ""             

         IF len(aReturns) > 0
 
             For nI := 1 To Len(aReturns)
                 HttpGet->Competencias := HttpGet->Competencias + "'" + aReturns[nI]:cSkillDescription + "'"   
                 HttpGet->ValoresCargo := HttpGet->ValoresCargo + str(aReturns[nI]:nSkillPosition)
                 HttpGet->ValoresFunc  := HttpGet->ValoresFunc  + str(aReturns[nI]:nSkillEmployee)             

                 If nI < Len(aReturns)   
                     HttpGet->Competencias := HttpGet->Competencias + ", "
                     HttpGet->ValoresCargo := HttpGet->ValoresCargo + ", "
                     HttpGet->ValoresFunc  := HttpGet->ValoresFunc  + ", "
                 EndIf       

             Next nI
         EndIf
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA351.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf


      //Busca descritivo de competencias do cargo             
      If oWSCompetence:GetHabilities()
         HttpGet->Habilidades  := oWSCompetence:oWSGetHabilitiesResult:oWsItens:oWsListOfCompetences
      Else
         HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA351.APW" }
         Return ExecInPage("PWSAMSG" )
      EndIf

		
		cHtml := ExecInPage("PWSA351")
	WEB EXTENDED END	

Return cHtml


   