#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA710.CH"

/******************************************************************************
* Funcao: PWSA710
* Autor: Marcelo Faria
* Data: 05/04/2016
* Resultado da Avaliacao Consolidada
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista     ³ Data   ³FNC:            ³Motivo da Alteracao             ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³              ³        ³                ³                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//* Seleciona Politica Consolidada
Web Function PWSA710()
   Local   cHtml := ""
   Local   oPolicy
   Private oPolicies
      
	WEB EXTENDED INIT cHtml START "InSite"
		HttpGet->titulo          := STR0002 //"Avaliação Consolidada"
		HttpSession->PageLenght  := "20"
		HttpSession->aStructure	 := {}
		HttpSession->cHierarquia	 := ""
       HttpSession->cTypeRequest := ""

       // Carrega SM0
		OpenSm0()
		HttpSession->aSM0 := FWLoadSM0()

		fGetInfRotina("W_PWSA710.APW")
		GetMat()	 //Pega a Matricula e a filial do participante logado

      	oPolicy := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHAPDConsolidated"), WSRHAPDConsolidated():New())
		WsChgURL(@oPolicy,"RHAPDConsolidated.APW")                             

      	If oPolicy:GetPolicies()
			oPolicies := oPolicy:oWSGetPoliciesResult
		Endif

		cHtml := ExecInPage("PWSA710A")
	WEB EXTENDED END
Return cHtml  


//* Informações da Equipe
Web Function PWSA711()
	Local cHtml   	:= ""
   Local aPostPolicy := {}

	WEB EXTENDED INIT cHtml START "InSite"
		HttpGet->titulo          := STR0002 	//"Avaliação Consolidada"
		HttpSession->aStructure	 := {}
		HttpSession->cHierarquia	 := ""

		If(valtype(HttpPost->optPolicy) != "U")
			aPostPolicy := StrTokArr2(HttpPost->optPolicy,"##",.T.)
	       HttpSession->cPolicy     := alltrim(aPostPolicy[1])
	       HttpSession->cPolicyDesc := alltrim(aPostPolicy[2])
		Else
			If(valtype(HttpSession->cPolicy) == "U")
		       HttpSession->cPolicy     := "00000"
		       HttpSession->cPolicyDesc := ""
		    EndIf
		EndIf

		GetMat()								   //Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA710B")
	WEB EXTENDED END
Return cHtml  


//* Resultado Consolidado do Funcionário
Web Function PWSA712()
Local oObj
Local cHtml   := ""
Local nIndice := 0

If(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
EndIf

WEB EXTENDED INIT cHtml START "InSite"   	
    //GetMat()//Pega filial e matricula do participante 

    nIndice :=  val(HttpGet->nIndice)
   	If (HttpGet->nOperacao == "1")  
   		HttpSession->DadosFunc := HttpSession->aStructure[nIndice]
	EndIf

   	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHAPDConsolidated"), WSRHAPDConsolidated():New())
	WsChgURL(@oObj,"RHAPDConsolidated.APW")

	oObj:cPolicy        := HttpSession->cPolicy
	oObj:cParticipantID := HttpSession->aStructure[nIndice]:cParticipantID
	If oObj:GetConsolidated()     
		oConsolidado := oObj:oWSGetConsolidatedResult
	Else
		oConsolidado := {}
	EndIf

    cHtml := ExecInPage( "PWSA712" )  
	
WEB EXTENDED END
Return cHtml


//* Lista dos funcionários da equipe
Web Function PWSA713()
	Local cHtml   	  	:= ""
	Local oParam	  	    := Nil
	Local cHierarquia 	:= ""    
	Local nPos        	:= 0                
	Local aAux        	:= {}  
	Local nAux        	:= 0
	Local nNivel      	:= 0
	Local oOrg  

	Private lCorpManage
	Private nPageTotal
	Private nCurrentPage                                                                 

	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml START "InSite"	              
	 	Default HttpGet->Page         		:= "1"
		Default HttpGet->PageLength       	:= HttpSession->PageLenght
		Default HttpGet->Order           	:= "desc"
		Default HttpGet->FilterField     	:= ""
		Default HttpGet->FilterValue	    := ""
		Default HttpGet->EmployeeFilial   	:= ""  
		Default HttpGet->Registration     	:= ""
	 	nCurrentPage                       := Val(HttpGet->Page)

      	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHAPDConsolidated"), WSRHAPDConsolidated():New())
		WsChgURL(@oOrg,"RHAPDConsolidated.APW")                             
		
		If Empty(HttpGet->EmployeeFilial) .And. Empty(HttpGet->Registration)
			oOrg:cParticipantID 	    := HttpSession->cParticipantID 		
			
			If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
				oOrg:cRegistration	 := HttpSession->RHMat
			EndIf	
		Else
			oOrg:cEmployeeFil  	    := HttpGet->EmployeeFilial
			oOrg:cRegistration 	    := HttpGet->Registration
		EndIf

		oOrg:cPolicy       		    := HttpSession->cPolicy
		oOrg:cVision       		    := HttpSession->aInfRotina:cVisao
		oOrg:nPage         		    := nCurrentPage
		oOrg:cFilterValue 		    := HttpGet->FilterValue
		oOrg:cFilterField   		    := HttpGet->FilterField
		oOrg:cRankingOrder 		    := HttpGet->Order
        oOrg:nPageLength            := val(HttpGet->PageLength)
		HttpSession->PageLenght     := HttpGet->PageLength

       IF oOrg:GetStructRanking()
			HttpSession->aStructure  := aClone(oOrg:oWSGetStructRankingResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
			nPageTotal 		       := oOrg:oWSGetStructRankingResult:nPagesTotal

         // *****************************************************************
         // Inicio - Monta Hierarquia                                                 
         // *****************************************************************
			cHierarquia := '<ul style="list-style-type: none;"><li><a href="#" class="links" onclick="javascript:GoToPage(null,1,null,null,null,null,' +;
					       "'" + HttpSession->aStructure[1]:cEmployeeFilial + "'," +;
					       "'" + HttpSession->aStructure[1]:cRegistration + "'" + ')">'

			If Empty(HttpSession->cHierarquia) .or. (HttpSession->cParticipantID == HttpSession->aStructure[1]:cParticipantID)
				nNivel                 := 1    
				HttpSession->cHierarquia := ""
			Else
				aAux := Str2Arr(HttpSession->cHierarquia, "</ul>")
				If (nPos := aScan(aAux, {|x| cHierarquia $ x })) > 0
					For nAux := len(aAux) to nPos step -1
						aDel(aAux,nAux)
						aSize(aAux,Len(aAux)-1)
					Next nAux
				EndIf
				HttpSession->cHierarquia := ""
				For nPos := 1 to Len(aAux)
					HttpSession->cHierarquia += aAux[nPos] + "</ul>"
				Next nPos

				nNivel := Iif(Len(aAux) > 0,Len(aAux)+1,1)
			EndIf
			
			For nPos := 1 to nNivel
				cHierarquia += '&nbsp;&nbsp;&nbsp;'
			Next nPos
			cHierarquia += Alltrim(str(nNivel)) + " . " + HttpSession->aStructure[1]:cName + '</a></li></ul>'
	            
			HttpSession->cHierarquia += cHierarquia
         	// Fim - Monta Hierarquia
		Else
			HttpSession->aStructure := {}
			nPageTotal 		      := 1

			HttpSession->_HTMLERRO  := { STR0001, PWSGetWSError(), "W_PWSA000.APW","top" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf 
		            
		cHtml := ExecInPage( "PWSA710C" )

	WEB EXTENDED END
Return cHtml
