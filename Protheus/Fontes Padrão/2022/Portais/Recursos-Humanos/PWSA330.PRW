#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA330.CH"

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    25/09/2014        ³  256421   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 
/*******************************************************************
* Funcao: PWSA330
* Autor: Emerson Campos	
* Data: 15/06/2012
* Mapa de Treinamento
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista     ³ Data   ³FNC:            ³  	Motivo da Alteracao         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                ³                                ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSA330()

	Local cHtml   	:= ""

	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "C"		//"Mapa de Treinamento"    
		HttpGet->titulo           	:= STR0001 	//"Consulta de Mapa de Treinamento"    
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		
		fGetInfRotina("W_PWSA330.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA330A")
	WEB EXTENDED END
Return cHtml
Web Function PWSA330B()
	Local cHtml   	:= ""
	Local nIndice 	:= 0
	Local oWSTrainings
	Private aTrainings
	Private aTraiDisp
	
	If(valType(HttpGet->nIndice) != "U")
	   nIndice := val(HttpGet->nIndice) 
	EndIf


	WEB EXTENDED INIT cHtml START "InSite"  
  	
		 //Pega filial e matricula do participante
	    GetMat() 
	
	    nIndice :=  val(HttpGet->nIndice)
	   	If (HttpGet->nOperacao == "1")  
	   		HttpSession->DadosFunc := HttpSession->aStructure[nIndice]   	
		EndIf
	    
	    oWSTrainings := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTrainings"), WSRHTrainings():New())
		WsChgURL(@oWSTrainings, "RHTrainings.APW",,,GetEmpFun())
		
		oWSTrainings:cBranch	 	:= HttpSession->DadosFunc:cEmployeeFilial
		
		//Consulta os treinamentos disponiveis
	    If oWSTraining:BrowseTrainings()
			aTraiDisp 	:= oWSTraining:oWSBrowseTrainingsResult:oWSListOfTrainings:oWSDataTrainings
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA330.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf	
	    
	    
		oWSTrainings:cRegistration	:= HttpSession->DadosFunc:cRegistration
		oWSTrainings:cPositionId	:= HttpSession->DadosFunc:cPositionId
		
		//Consulta todos os cursos exigidos pelo cargo e todos os cursos realizados pelo funcionário
		If oWSTrainings:GetMapTrainings()
			aTrainings	:= oWSTrainings:OWSGETMAPTRAININGSRESULT:OWSITENS:OWSDATACOURSES			 
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA330.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
         
		cHtml := ExecInPage( "PWSA330B" ) 
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA330C
* Autor: Emerson Campos
* Data: 20/06/2012
* Mapa de Treinamento por Departamento
********************************************************************/
Web Function PWSA330C()
	Local cHtml   		:= ""
	Local oWSTrainings
	Local nTam			:= Len(HttpSession->aStructure)
	Local nI			:= 0
	Local nX			:= 0
	
	HttpSession->aMapTraiDepto	:= {}

	WEB EXTENDED INIT cHtml START "InSite"		
	
		oWSTrainings := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTrainings"), WSRHTrainings():New())
		WsChgURL(@oWSTrainings, "RHTrainings.APW")

		oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE := wsClassNew('RHTRAININGS_ARRAYOFDATACOURSESEMPLOYEE')
		oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE := {}
		
		For nX := 1 To nTam
			If HttpSession->aStructure[nX]:cDepartment == HttpSession->Department[val(HttpGet->nIndiceDepto)]:cDepartment
			   	aAdd(oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE, wsClassNew('RHTRAININGS_DATACOURSESEMPLOYEE')) 
				
				nI += 1
				oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE[nI]:CADMISSIONDATE 	:= HttpSession->aStructure[nX]:cAdmissionDate
				oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE[nI]:CBRANCH			:= HttpSession->aStructure[nX]:cEmployeeFilial
				oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE[nI]:CDESCRDEPARTMENT	:= HttpSession->aStructure[nX]:cDescrDepartment
				oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE[nI]:CDESCSITUACAO   := HttpSession->aStructure[nX]:cDescSituacao
				oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE[nI]:CPOSITIONID		:= HttpSession->aStructure[nX]:cPositionId
				oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE[nI]:CREGISTRATION	:= HttpSession->aStructure[nX]:cRegistration
				oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE[nI]:CNAME			:= HttpSession->aStructure[nX]:cName
				oWSTrainings:OWSEMPLOYEESDATA:OWSLISTOFEMPLOYEE:OWSDATACOURSESEMPLOYEE[nI]:CINDICE			:= Str(nX)
			EndIf			
		Next nX

		//Consulta o mapa de treinamento por departamento
	    If oWSTrainings:GetDepartMapTrainings()
			HttpSession->aMapTraiDepto	:= oWSTrainings:OWSGetDepartmapTrainingsResult 
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA330.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf	
	 
	cHtml += ExecInPage( "PWSA330C" ) 
	WEB EXTENDED END
Return cHtml  

Web Function PWSA330D()
	Local cHtml   	:= ""

	WEB EXTENDED INIT cHtml START "InSite"

		cHtml += ExecInPage("PWSA330D")
	WEB EXTENDED END  
	
	
Return cHtml
