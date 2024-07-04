#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"  
#INCLUDE "PWSA220.CH"
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    01/10/2014        ³  257604   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/  
/*******************************************************************
* Funcao: PWSA220
* Treinamentos
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista     ³ Data   ³Chamado:        ³  	Motivo da Alteracao         ³±± 
±±³Marcelo Faria |17/06/11|	SCYE93		   |Padronizacao do serviço de soli-³±±
±±³              |        |			       |citacao de treinamento, como    ³±±
±±³              |        |         	   |outros serviços de solicitacao  ³±±
±±³              |        |                |disponibilizados no Portal.     ³±±
±±³Allyson M     |25/03/14|TPBAFB          |-Ajusta na busca do superior do ³±±
±±³              |        |                |funcionario p/ aprovacao de     ³±±
±±³              |        |                |reserva de treinamento.         ³±±
±±³              |        |                |-Ajuste na aprovacao da solici- ³±±
±±³              |        |                |tacao p/ respeitar a hierarquia ³±±
±±³              |        |                |corretamente         			³±±
±±³              |        |                |-Ajuste na reprovacao da solici-³±±
±±³              |        |                |tacao p/ respeitar a hierarquia ³±±
±±³              |        |                |corretamente         			³±±
±±³              ³        ³                ³-Ajuste p/ aprovacao de solici- ³±±
±±³              ³        ³                ³tacao respeitar a qtde de niveis³±±
±±³              ³        ³                ³de fluxo de aprovacao.   		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³        Atualizacoes sofridas APÓS A VERSÃO 11                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Emerson Campos|09/07/14|	TPWQVJ		    |Interesse em treinamento      ³±±
±±³Renan Borges  ³12/09/16³TVWVWI          ³Ajuste ao utilizar Visão por    ³±±
±±³              ³        ³                ³ Departamento e realizar a soli-³±±
±±³              ³        ³                ³tação para um membro da equipe, ³±±
±±³              ³        ³                ³seja carregado o aprovador cor- ³±± 
±±³              ³        ³                ³retamente, quando o responsável ³±± 
±±³              ³        ³                ³pelo departamento estiver em um ³±± 
±±³              ³        ³                ³departamento diferente ao do so-³±± 
±±³              ³        ³                ³licitante.                      ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PWSA220()
	Local cHtml   	:= ""
	HttpSession->FilterField    := ""
	HttpSession->FilterValue    := ""
	HttpSession->FilterField2   := ""
	HttpSession->FilterValue2   := ""
	HttpSession->FilterCateg    := STR0011 //"Todos"
	HttpSession->FilterType   	:= "3"
		
	WEB EXTENDED INIT cHtml START "InSite"	
	
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgURL(@oObj,"RHCURRICULUM.APW") 
							              
		HttpSession->cTypeRequest 	:= "A"		// Treinamentos
		HttpGet->titulo           	:= STR0002 	//"Solicitacao de Transferencia"
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		
		fGetInfRotina("W_PWSA220.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA120A") 
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA221
* Carrega treinamentos
********************************************************************/
Web Function PWSA221()
	Local cHtml   	:= ""
	Local oWSTraining
	Private nCurrentPage
	Private nPageTotal
	Private aOtherTrainings := {}
	Private nCurrentPg
	Private nPgTotal
	Private cIndice       := ""
	Private lOtherTrainings	:= .F.
	Private aCateg			:= {}

	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
	 	Default HttpGet->Page           := "1"
		Default HttpGet->FilterField    := ""
		Default HttpGet->FilterValue    := ""
		Default HttpGet->FilterField2   := ""
		Default HttpGet->FilterValue2   := ""
		Default HttpGet->FilterCateg    := STR0011 //"Todos"
		Default HttpGet->FilterType   	:= "3"
		
	 	nCurrentPage := Val(HttpGet->Page)
	 	
	 	HttpSession->FilterCateg	:= HttpGet->FilterCateg 
	 	HttpSession->FilterType		:= HttpGet->FilterType 
	 	
	 	//Controla o filtro dos treinamentos
	 	If (HttpSession->FilterField <> HttpGet->FilterField .OR. HttpSession->FilterValue <> HttpGet->FilterValue) .AND. HttpGet->cFilFie2 <> Nil 
	 		HttpSession->FilterField 	:= HttpGet->FilterField
	 		HttpSession->FilterValue 	:= HttpGet->FilterValue
	 	Else	 	
		 	//Controla o filtro dos treinamentos fechados
		 	If ValType(HttpGet->FilterField2) <> 'U' .AND. (HttpSession->FilterField2 <> HttpGet->FilterField2 .OR. HttpSession->FilterValue2 <> HttpGet->FilterValue2)
		 		HttpSession->FilterField2 	:= HttpGet->FilterField2
		 		HttpSession->FilterValue2 	:= HttpGet->FilterValue2
		 	EndIf
		 	
		 	If !Empty(HttpGet->cFilVal)
		 		HttpSession->FilterField  	:= HttpGet->cFilFie
		 		HttpSession->FilterValue  	:= HttpGet->cFilVal
		 	EndIf
		EndIf	
		
		If ! ValType(HttpGet->cFilVal2) <>'U' 
			If ! Empty(HttpGet->cFilVal2)				 		
	 			HttpSession->FilterField2  	:= HttpGet->cFilFie2
	 			HttpSession->FilterValue2  	:= HttpGet->cFilVal2
	 		EndIf
	 	EndIf
	 	
	 	Default HttpGet->OutPage           := "1"
	 	
	 	nCurrentPg := Val(HttpGet->OutPage)
	 	
		oWSTraining := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTrainings"), WSRHTrainings():New())
		WsChgURL(@oWSTraining, "RHTRAININGS.APW")
		cIndice						:= HttpGet->nIndice
   		HttpSession->DadosFunc 		:= HttpSession->aStructure[val(HttpGet->nIndice)]
		oWSTraining:cBranch	 		:= HttpSession->DadosFunc:cEmployeeFilial
		oWSTraining:cFilterField	:= HttpGet->FilterField
		oWSTraining:cFilterValue	:= HttpGet->FilterValue	
		oWSTraining:cFilterCateg	:= HttpSession->FilterCateg
		oWSTraining:cFilterType		:= HttpSession->FilterType
		
		oWSTraining:nPage		 	:= nCurrentPage
		If oWSTraining:BrowseTrainings()
			aTrainings 	:= oWSTraining:oWSBrowseTrainingsResult:oWSListOfTrainings:oWSDataTrainings
			nPageTotal	:= oWSTraining:OWSBROWSETRAININGSRESULT:NPAGESTOTAL
			aCateg := oWSTraining:oWSBrowseTrainingsResult:oWSListOfCategs:oWSDataCategs
			oWSTraining:nPage		 		:= nCurrentPg
			//Busca outros treinamentos
			oWSTraining:cFilterField	:= HttpSession->FilterField2
			oWSTraining:cFilterValue	:= HttpSession->FilterValue2
			oWSTraining:cRegistration	:= HttpSession->DadosFunc:cRegistration
			oWSTraining:cFilterCateg	:= HttpSession->FilterCateg
			oWSTraining:cFilterType		:= HttpSession->FilterType
			
			If oWSTraining:OtherTrainings()
				aOtherTrainings 	:= oWSTraining:oWSOtherTrainingsResult:oWSListOfTrainings:oWSDataTrainings
				nPgTotal			:= oWSTraining:oWSOtherTrainingsResult:nPagesTotal
				lOtherTrainings	:= oWSTraining:oWSOtherTrainingsResult:lParameterMVINTTREI
			Else
				HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf

		cHtml := ExecInPage( "PWSA221" )	
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA221a
* Busca dados do treinamento
********************************************************************/
Web Function PWSA221a()
	Local cHtml   	:= ""
	Local oWSTraining
	Private oTraining
	Private aDisciplines := {}
	Private nCurrentPage
	Private nPageTotal

	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		
		oWSTraining := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTrainings"), WSRHTrainings():New())
		If (HttpGet->nOperacao == "1")
	   		HttpSession->DadosFunc 		:= HttpSession->aStructure[val(HttpGet->nIndice)]
			WsChgURL(@oWSTraining, "RHTRAININGS.APW",,,GetEmpFun())
		EndIf
		
		
		If (HttpGet->nOperacao == "1")
	   		HttpSession->DadosFunc 		:= HttpSession->aStructure[val(HttpGet->nIndice)]

			oWSTraining:cBranch	 		:= HttpSession->DadosFunc:cEmployeeFilial
			oWSTraining:cRegistration	:= HttpSession->DadosFunc:cRegistration
			oWSTraining:cCalendarCode	:= HttpGet->CalendarCode
			oWSTraining:cCourseCode		:= HttpGet->CourseCode
			oWSTraining:cCourseClass	:= HttpGet->CourseClass	
			If oWSTraining:GetTraining()
				oTraining 	:= oWSTraining:oWSGetTrainingResult
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}
				Return ExecInPage("PWSAMSG" )
			EndIf

			oWSDiscipline := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTrainings"), WSRHTrainings():New())
			WsChgURL(@oWSDiscipline, "RHTRAININGS.APW",,,GetEmpFun())
			oWSDiscipline:cBranch	 	:= HttpSession->DadosFunc:cEmployeeFilial
			oWSDiscipline:cCourseCode	:= HttpGet->CourseCode
			If oWSDiscipline:GetDiscipline()
				aDisciplines := oWSDiscipline:oWSGetDisciplineResult:oWSListOfDisciplines:oWSDataDisciplines
			Else
				HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
				Return ExecInPage("PWSAMSG" )
			EndIf
		EndIf
		
		if (HttpGet->nOperacao == "3" .or. HttpGet->nOperacao == "4")
			fGetInfRotina("W_PWSA220.APW")
			oRequest					:= HttpSession->oRequests[val(HttpGet->nIndiceSolic)]

			oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
			WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,oRequest:cEmpresa)                             
			oOrg:cEmployeeFil   := PegaValores(oRequest,"RA3_FILIAL")
			oOrg:cRegistration  := PegaValores(oRequest,"RA3_MAT")
	 		oOrg:cVision	    := HttpSession->aInfRotina:cVisao
	    
	    	
			If oOrg:GetStructure()
				HttpSession->DadosFunc 	:= aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)[1]
			Endif
		
			WsChgURL(@oWSTraining, "RHTRAININGS.APW",,,GetEmpFun())
	    
			oWSTraining:cBranch	 		:= HttpSession->DadosFunc:CEMPLOYEEFILIAL//HttpSession->aUser[2]
			oWSTraining:cRegistration	:= ''
			oWSTraining:cCalendarCode	:= PegaValores(oRequest, "RA3_CALEND")
			oWSTraining:cCourseCode		:= PegaValores(oRequest, "RA3_CURSO")
			oWSTraining:cCourseClass	:= PegaValores(oRequest, "RA3_TURMA")	
	
			If oWSTraining:GetTraining()
				oTraining 	:= oWSTraining:oWSGetTrainingResult
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}
				Return ExecInPage("PWSAMSG" )
			EndIf				
	
	   	Endif	

	   	cHtml := ExecInPage("PWSA223")	
	
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA221b
* Interesse por treinamento
********************************************************************/
Web Function PWSA221b()
	Local cHtml   		:= ""
	Local oWSTraining
	Private oTraining
	Private aDisciplines := {}
	Private nCurrentPage
	Private nPageTotal
	Private lHasRequest	:= .T.

	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		oWSRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oWSRequest, "RHREQUEST.APW",,,GetEmpFun())
		
		oWSRequest:oWSTrainingReservationRequest:cBranch			:= HttpSession->DadosFunc:cEmployeeFilial
		oWSRequest:oWSTrainingReservationRequest:cRegistration	:= HttpSession->DadosFunc:cRegistration
		oWSRequest:oWSTrainingReservationRequest:cCalendarCode	:= ''
		oWSRequest:oWSTrainingReservationRequest:cCourseCode		:= HttpGet->CourseCode
		oWSRequest:oWSTrainingReservationRequest:cCourseClass	:= ''
		
		If oWSRequest:ValidRequestTraining()
			lHasRequest := oWSRequest:lValidRequestTrainingResult
			
			oWSTraining := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTrainings"), WSRHTrainings():New())
			WsChgURL(@oWSTraining, "RHTRAININGS.APW",,,GetEmpFun())
			
			If (HttpGet->nOperacao == "1")
		   		HttpSession->DadosFunc 		:= HttpSession->aStructure[val(HttpGet->nIndice)]
				oWSTraining:cBranch	 		:= HttpSession->DadosFunc:cEmployeeFilial
				oWSTraining:cRegistration	:= HttpSession->DadosFunc:cRegistration
				oWSTraining:cCourseCode		:= HttpGet->CourseCode
				If oWSTraining:GetOutherTraining()
					oTraining 	:= oWSTraining:oWSGetOutherTrainingResult
				Else
					HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}
					Return ExecInPage("PWSAMSG" )
				EndIf
		
				oWSDiscipline := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTrainings"), WSRHTrainings():New())
				WsChgURL(@oWSDiscipline, "RHTRAININGS.APW",,,GetEmpFun())
				oWSDiscipline:cBranch	 	:= HttpSession->DadosFunc:cEmployeeFilial
				oWSDiscipline:cCourseCode	:= HttpGet->CourseCode
				If oWSDiscipline:GetDiscipline()
					aDisciplines := oWSDiscipline:oWSGetDisciplineResult:oWSListOfDisciplines:oWSDataDisciplines
				Else
					HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
					Return ExecInPage("PWSAMSG" )
				EndIf
			EndIf
				
			if (HttpGet->nOperacao == "3" .or. HttpGet->nOperacao == "4")
				fGetInfRotina("W_PWSA220.APW")
				oRequest						:= HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
	
				oWSTraining:cBranch	 		:= HttpSession->aUser[2]
				oWSTraining:cRegistration	:= ''
				oWSTraining:cCourseCode		:= PegaValores(oRequest, "RA3_CURSO")
		
				If oWSTraining:GetTraining()
					oTraining 	:= oWSTraining:oWSGetTrainingResult
				Else
					HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}
					Return ExecInPage("PWSAMSG" )
				EndIf
	   		EndIf
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
		cHtml := ExecInPage("PWSA224")	
		
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA222
* Grava solicitacao do treinamento
********************************************************************/
Web Function PWSA222()
	Local cHtml:= ""
	Local oOrg
	Local oWSRequest
	Private cMessage

	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		oWSRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oWSRequest, "RHREQUEST.APW")
	
	    oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	     
		oOrg:cParticipantID 	:= HttpSession->cParticipantID
		oOrg:cTypeOrg       	:= ""
		oOrg:cVision        	:= HttpSession->aInfRotina:cVisao
		If ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
			oOrg:cRegistration	:= HttpSession->RHMat
		EndIf	

		If oOrg:GetStructure()
		    //Pega filial e matricula do participante
		    GetMat() 

			oWSRequest:oWSRequest:cApproverBranch	   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oWSRequest:oWSRequest:cApproverRegistration := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oWSRequest:oWSRequest:nApproverLevel		:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oWSRequest:oWSREQUEST:cEmpresaAPR	 		:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
			
			oWSRequest:oWSRequest:cStarterBranch		:= HttpSession->aUser[2]
			oWSRequest:oWSRequest:cStarterRegistration 	:= HttpSession->aUser[3]
			oWSRequest:oWSRequest:cBranch 				:= HttpSession->DadosFunc:cEmployeeFilial
			oWSRequest:oWSRequest:cRegistration 		:= HttpSession->DadosFunc:cRegistration
			oWSRequest:oWSRequest:cVision 				:= HttpSession->aInfRotina:cVisao
			oWSRequest:oWSRequest:cObservation    		:= Alltrim(HttpPost->txtObservacao)
	 	    oWSRequest:oWSREQUEST:cEmpresa	 			:= GetEmpFun()
	 	    
			oWSRequest:oWSTrainingReservationRequest:cBranch		:= HttpSession->DadosFunc:cEmployeeFilial
			oWSRequest:oWSTrainingReservationRequest:cRegistration	:= HttpSession->DadosFunc:cRegistration
			oWSRequest:oWSTrainingReservationRequest:cCalendarCode	:= HttpPost->txtCalendario
			oWSRequest:oWSTrainingReservationRequest:cCourseCode	:= HttpPost->txtCurso
			oWSRequest:oWSTrainingReservationRequest:cCourseClass	:= HttpPost->txtTurma
		
			If oWSRequest:AddTrainingReservationRequest()
				HttpGet->msg := STR0003 // "Operacao realizada com sucesso"
				
		        W_PWSA220()
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf	
	WEB EXTENDED END

Return cHtml   


/*******************************************************************
* Funcao: PWSA223
* Busca solicitacoes
********************************************************************/
Web Function PWSA223()
	Local cHtml    	:= ""
	Local oWSTraining
	Private oTraining
	Private oRequest
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
       	oRequest					:= HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		
       	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,oRequest:cEmpresa)                             
		oOrg:cEmployeeFil   := PegaValores(oRequest,"RA3_FILIAL")
		oOrg:cRegistration  := PegaValores(oRequest,"RA3_MAT")
        oOrg:cVision	    := HttpSession->aInfRotina:cVisao
       	
       	If oOrg:GetStructure()
			HttpSession->DadosFunc 	:= aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)[1]
		Endif

			
		oWSTraining := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTrainings"), WSRHTrainings():New())
		WsChgURL(@oWSTraining, "RHTRAININGS.APW",,,GetEmpFun())

		oWSTraining 				:= WSClassNew("RHREQUEST_TTrainingReservation")
	    	
		oWSTraining:cBranch			:= HttpSession->DadosFunc:cEmployeeFilial//HttpSession->aUser[2]
		oWSTraining:cRegistration	:= PegaValores(oRequest, "RA3_MAT")
		oWSTraining:cCalendarCode	:= PegaValores(oRequest, "RA3_CALEND") 
		oWSTraining:cCourseCode		:= PegaValores(oRequest, "RA3_CURSO")
		oWSTraining:cCourseClass	:= PegaValores(oRequest, "RA3_TURMA") 

		If oWSTraining:GetTraining()
			oTraining:= oWSTraining:oWSGetTrainingResult
		EndIf

	   	cHtml := ExecInPage("PWSA223")
	WEB EXTENDED END	
Return cHtml 


/*******************************************************************
* Funcao: PWSA224
* Aprova solicitacao do treinamento (Superior)
********************************************************************/
Web Function PWSA224()
	Local cHtml    	:= ""
	Local oOrg    
	Local oWSRequest
	Local nIndice	:= Val(HttpPost->nIndiceSolic)
	Private cMessage
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
        oWSRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
		WsChgURL(@oWSRequest, "RHREQUEST.APW")   
        
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	   	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	   	                  
		oOrg:cVision         := HttpSession->oRequests[nIndice]:CVISION
		oOrg:cEmployeeFil    := HttpSession->oRequests[nIndice]:CBRANCH
		oOrg:cRegistration   := HttpSession->oRequests[nIndice]:CREGISTRATION
		oOrg:cEmployeeSolFil := HttpSession->aUser[2]
		oOrg:cRegistSolic	 := HttpSession->aUser[3]
		oOrg:cRequestType	 := HttpSession->cTypeRequest

		If oOrg:GetStructure()
			oWSRequest:oWsRequest				:= RHREQUEST_TREQUEST():New()

			oWSRequest:oWSREQUEST:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oWSRequest:oWSREQUEST:cApproverRegistration  	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oWSRequest:oWSREQUEST:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oWSRequest:oWSREQUEST:cEmpresaAPR	 		    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
			oWSRequest:oWSREQUEST:cDepartAPR	 			:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartAprovador

			oWSRequest:oWsRequest:cBranch      	:= HttpSession->DadosFunc:cEmployeeFilial//HttpSession->aUser[2]
			oWSRequest:oWsRequest:cRegistration	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration//HttpSession->aUser[3]
			oWSRequest:oWsRequest:cCode        	:= HttpPost->txtCodigo
			oWSRequest:oWsRequest:cObservation 	:= HttpPost->txtObservacao
					
			If oWSRequest:ApproveRequest()
				HttpGet->msg := STR0004 // "Aprovacao realizada com sucesso"
	
		   		W_PWSA115()
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}
				Return ExecInPage("PWSAMSG")
			EndIf 
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}
			Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END

Return cHtml 

/*******************************************************************
* Funcao: PWSA225
* Reprova solicitacao do treinamento (Superior)
********************************************************************/
Web Function PWSA225()
	Local cHtml    	:= ""
	Local oOrg    
	Local oWSRequest
	Local nIndice	:= Val(HttpPost->nIndiceSolic)
	Private cMessage
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
        oWSRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
		WsChgURL(@oWSRequest, "RHREQUEST.APW")   
        
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	   	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	   	                  
		oOrg:cParticipantID	  := HttpSession->cParticipantID
		oOrg:cVision          := HttpSession->oRequests[nIndice]:CVISION 
		If ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
	    	oOrg:cRegistration  := HttpSession->RHMat
		EndIf   

		If oOrg:GetStructure()
			oWSRequest:oWsRequest				:= RHREQUEST_TREQUEST():New()

			oWSRequest:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oWSRequest:oWsRequest:cApproverRegistration  	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oWSRequest:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oWSRequest:oWSREQUEST:cEmpresaAPR	 		    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa

			oWSRequest:oWsRequest:cBranch      	:= HttpSession->DadosFunc:cEmployeeFilial//HttpSession->aUser[2]
			oWSRequest:oWsRequest:cRegistration	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration//HttpSession->aUser[3]
			oWSRequest:oWsRequest:cCode        	:= HttpPost->txtCodigo
			oWSRequest:oWsRequest:cObservation 	:= HttpPost->txtObservacao
					
			If oWSRequest:ReproveRequest()
				HttpGet->msg := STR0005 // "Reprovacao realizada com sucesso"
	
		   		W_PWSA115()
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}
				Return ExecInPage("PWSAMSG")
			EndIf
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}
			Return ExecInPage("PWSAMSG")
		EndIf  
	WEB EXTENDED END
Return cHtml 

/*******************************************************************
* Funcao: PWSA226
* Grava interesse em treinamento
********************************************************************/
Web Function PWSA226()
	Local cHtml:= ""
	Local oOrg
	Local oWSRequest
	Private cMessage

	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		oWSRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oWSRequest, "RHREQUEST.APW",,,GetEmpFun())
	
	    oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	     
		oOrg:cParticipantID 	:= HttpSession->cParticipantID
		oOrg:cTypeOrg       	:= ""
		oOrg:cVision        	:= HttpSession->aInfRotina:cVisao
		If ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
			oOrg:cRegistration	:= HttpSession->RHMat
		EndIf	

		If oOrg:GetStructure()
		    //Pega filial e matricula do participante
		    GetMat() 

			oWSRequest:oWSRequest:cApproverBranch	   		:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oWSRequest:oWSRequest:cApproverRegistration 	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oWSRequest:oWSRequest:nApproverLevel			:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup

			oWSRequest:oWSRequest:cStarterBranch			:= HttpSession->aUser[2]
			oWSRequest:oWSRequest:cStarterRegistration 	:= HttpSession->aUser[3]
			oWSRequest:oWSRequest:cBranch 					:= HttpSession->DadosFunc:cEmployeeFilial
			oWSRequest:oWSRequest:cRegistration 			:= HttpSession->DadosFunc:cRegistration
			oWSRequest:oWSRequest:cVision 					:= HttpSession->aInfRotina:cVisao
			oWSRequest:oWSRequest:cObservation    			:= Alltrim(HttpPost->txtObservacao)
			
			oWSRequest:oWSTrainingReservationRequest:cBranch			:= HttpSession->DadosFunc:cEmployeeFilial
			oWSRequest:oWSTrainingReservationRequest:cRegistration	:= HttpSession->DadosFunc:cRegistration
			oWSRequest:oWSTrainingReservationRequest:cCalendarCode	:= ''
			oWSRequest:oWSTrainingReservationRequest:cCourseCode		:= HttpPost->txtCurso
			oWSRequest:oWSTrainingReservationRequest:cCourseClass	:= ''
		
			If oWSRequest:RequestTraining()
				HttpGet->msg := STR0003 // "Operacao realizada com sucesso"				
		       W_PWSA220()		        
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf	
	WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA227
* Exclui interesse por treinamento
********************************************************************/
Web Function PWSA227()
	Local cHtml   		:= ""
	Local oWSRequest

	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		oWSRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oWSRequest, "RHREQUEST.APW",,,GetEmpFun())
		
		oWSRequest:oWSTrainingReservationRequest:cBranch			:= HttpSession->DadosFunc:cEmployeeFilial
		oWSRequest:oWSTrainingReservationRequest:cRegistration	:= HttpSession->DadosFunc:cRegistration
		oWSRequest:oWSTrainingReservationRequest:cCalendarCode	:= ''
		oWSRequest:oWSTrainingReservationRequest:cCourseCode		:= HttpGet->CourseCode
		oWSRequest:oWSTrainingReservationRequest:cCourseClass	:= ''
		
		If oWSRequest:DelRequestTraining()
			If oWSRequest:lDelRequestTrainingResult
				HttpGet->msg := STR0006 // "Exclusão realizada com sucesso!"	
		    Else
				HttpGet->msg := STR0007 // "Não foi possível realizar a exclusão!"
		    EndIf
		    W_PWSA220()		        
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA220.APW"}	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	WEB EXTENDED END

Return cHtml 
