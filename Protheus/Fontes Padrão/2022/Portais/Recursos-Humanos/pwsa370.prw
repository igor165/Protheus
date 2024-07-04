#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA370.CH"

#DEFINE PAGE_LENGTH 10
/*************************************************************/

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    31/07/2014        ³  243473   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 


/*************************************************************/
/* Visualizacao de Vagas da rotina Aval. Processo Seletivo	 */
/*************************************************************/
Web Function PWSA370()	//ShowVacancy

Local cHtml := ""
Local oObj
Local oMsg
Local oObjCurr
Local oParam

HttpSession->nPageLength	:= PAGE_LENGTH
Private lLoginOk	:= .F.

HttpSession->nPageTotal		:= 0
HttpSession->nCurrentPage	:= 0
HttpSession->CurrentPage	:= 0
HttpSession->FiltroVagas	:= ''
HttpSession->FiltroField	:= ''
HttpSession->FiltroVagas1	:= ''
HttpSession->FiltroField1	:= ''
HttpSession->GetVacancy		:= {}
HttpSession->cSituation		:= '4' 
HttpSession->cScore			:= ''
HttpSession->cMsg			:= ''

WEB EXTENDED INIT cHtml START "InSite"
	
	oObjCurr  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObjCurr,"RHCURRICULUM.APW")
        					
	oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVACANCY"), WSRHVACANCY():New())
	oMsg  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())

	WsChgURL(@oObj,"RHVACANCY.APW")
	WsChgURL(@oMsg,"CFGDICTIONARY.APW")	
    
	If !Empty(HttpPost->cFilterValue)
		oObj:cFilterValue			:= HttpPost->cFilterValue
		oObj:cFilterField			:= HttpPost->cFilterField
		HttpSession->FiltroVagas	:= HttpPost->cFilterValue
		HttpSession->FiltroField	:= HttpPost->cFilterField 
	EndIf
    
	oParam  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	WsChgURL(@oParam, "CFGDICTIONARY.APW")
	
	If oParam:GetParam("MSALPHA", "MV_APDVIS")
		cCodVis := oParam:cGETPARAMRESULT
	EndIf	 
			
    //Registration somente deve ser enviado a Matricula do usuario qdo proveniente da rotina Avaliação do Processo Seletivo
    oObj:cRegistration	:= HttpSession->RHMat
    oObj:cEmployeeFil 	:= HTTPSession->RHFilMat
      
	If oObj:GetVacancy( "MSALPHA" )

		If Len( oObj:oWsGetVacancyResult:oWsVacancyChoice ) > 0
			HttpSession->nPageTotal	:=  Ceiling( Len(oObj:oWsGetVacancyResult:oWsVacancyChoice)/PAGE_LENGTH)	
			
			If !Empty(HttpPost->cCurrentPage)
				If Val(HttpPost->cCurrentPage) > 0 .AND. Val(HttpPost->cCurrentPage) <= HttpSession->nPageTotal 
					HttpSession->nCurrentPage	:= Val(HttpPost->cCurrentPage)
					HttpSession->CurrentPage	:= HttpSession->nCurrentPage
				Else
					HttpSession->nCurrentPage	:= HttpSession->CurrentPage
				EndIf
			Else
				HttpSession->nCurrentPage	:= 1	
			EndIf	
		 
			HttpSession->GetVacancy := oObj:oWsGetVacancyResult:oWsVacancyChoice

			cHtml += ExecInPage( "PWSA370" )
		Else
			cHtml := RHALERT( "", STR0002, STR0011, "W_PWSA370.APW" ) //"Vagas Disponiveis"###"Não existem vagas disponíveis no momento para serem avaliadas."
		EndIf

	Else
		conout( PWSGetWSError() )
	EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Gerenciar processo seletivo da vaga						 */
/*************************************************************/
Web Function PWSA371()	//GetVacancy

Local cHtml := ""
Local oObj
Local nI	:= 0
Local nY	:= 0
Local nTam	:= 0
Local nQuant:= 0
HttpSession->Selects	:= {}
HttpSession->cVacancyCode 	:= HttpPost->cVacancyCode
HttpSession->cVacancyFil 	:= HttpPost->cVacancyFil

HttpSession->nPageTotal		:= 0
HttpSession->nCurrentPage1	:= 0
HttpSession->CurrentPage1	:= 0
HttpSession->FiltroVagas1	:= ''
HttpSession->FiltroField1	:= ''

WEB EXTENDED INIT cHtml START "InSite"

	oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVACANCY"), WSRHVACANCY():New())
	WsChgURL(@oObj,"RHVACANCY.APW")
    
	If !Empty(HttpPost->cFilterValue1)
		oObj:cFilterValue			:= HttpPost->cFilterValue1
		oObj:cFilterField			:= HttpPost->cFilterField1
		HttpSession->FiltroVagas1	:= HttpPost->cFilterValue1
		HttpSession->FiltroField1	:= HttpPost->cFilterField1 
	EndIf
    
	//Registration somente deve ser enviado a Matricula do usuario qdo proveniente da rotina Avaliação do Processo Seletivo
    oObj:cRegistration	:= HttpSession->RHMAT
    oObj:cEmployeeFil 	:= HTTPSession->RHFilMat
    
	If !Empty( HttpSession->cVacancyCode )

		If oObj:GetCandProcSel( HttpSession->cVacancyCode,,,,,HttpSession->cVacancyFil  )
						
			HttpSession->ShowCandidateVacancy := oObj:OWSGETCANDPROCSELRESULT:OWSCURRICULUM1
            
            If len(HttpSession->ShowCandidateVacancy) > 0
            	nTam := Len(HttpSession->ShowCandidateVacancy)
            	For nY := 1 To nTam
            		If HttpSession->ShowCandidateVacancy[nY]:cCurriculumStatus == "0"
            			nQuant++
            		EndIf 
            	Next nY
            	HttpSession->cTamReal	:= Str(nQuant)  
				HttpSession->nPageTotal	:=  Ceiling( nQuant/PAGE_LENGTH)	
				
				If !Empty(HttpPost->cCurrentPage1)
					If Val(HttpPost->cCurrentPage1) > 0 .AND. Val(HttpPost->cCurrentPage1) <= HttpSession->nPageTotal 
						HttpSession->nCurrentPage1	:= Val(HttpPost->cCurrentPage1)
						HttpSession->CurrentPage1	:= HttpSession->nCurrentPage1
					Else
						HttpSession->nCurrentPage1	:= HttpSession->CurrentPage1
					EndIf
				Else
					HttpSession->nCurrentPage1	:= 1	
				EndIf
			EndIf

			//Monta estrutura que serão utilizados nos selects da tela
		   	If oObj:GetSelects( HttpSession->cVacancyCode )
		   		For nI := 1 To Len(oObj:OWSGETSELECTSRESULT:OWSSELECTS)
		   			aAdd(HttpSession->Selects, oObj:OWSGETSELECTSRESULT:OWSSELECTS[nI]:OWSSELECTITENS:OWSOPTIONSELECT)	
		   		Next nI	
			EndIf 

			If oObj:ShowVacancy( "MSALPHA", HttpSession->cVacancyCode, HttpSession->cVacancyFil )
			    For nI := 1 To Len(HttpSession->GetVacancy)
			    	If HttpSession->GetVacancy[nI]:CVACANCYCODE == oObj:oWSSHOWVACANCYRESULT:oWSVACANCYVIEW[1]:CVACANCYCODE .AND. ;
			    		HttpSession->GetVacancy[nI]:CVACANCYFIL == oObj:oWSSHOWVACANCYRESULT:oWSVACANCYVIEW[1]:CVACANCYFIL
						HttpSession->GetVacancy[nI]:nAvaiableVacancies 		:= oObj:oWSSHOWVACANCYRESULT:oWSVACANCYVIEW[1]:NNUMBERVACANCIES
						HttpSession->GetVacancy[nI]:nNumberClosedVacancies 	:= oObj:oWSSHOWVACANCYRESULT:oWSVACANCYVIEW[1]:NNUMBERCLOSEDVACANCIES
					    Exit
					 EndIf
				 Next nI
			Else                                                                                                            
				Conout(STR0022) //"Código da vaga não encontrado"	
				Return RHALERT( "", STR0003, STR0022, "W_PWSA370.APW" ) //"Erro"    -  "Código da vaga não encontrado"		
			EndIf     
						 
			cHtml += ExecInPage( "PWSA371" )
		
		Else
			Return RHALERT( "", STR0003, PWSGetWSError(), "#" ) 		//"Erro"		 
		EndIf
	Else                                                                                                            
		Conout(STR0013) //"Código da vaga não encontrado"	
		Return RHALERT( "", STR0012, STR0013, "#" ) //"Erro"    -  "Código da vaga não encontrado"		
	EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Visualização currículo               					 */
/*************************************************************/
Web Function PWSA371A()	//GetCurriculum

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml

	oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	HttpSession->cCurricCpf 	:= HttpGet->cCpfCand

	If oObj:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, , 3 )

		HttpSession->GetCurriculum 	:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC1}
		HttpSession->GETTABLES 		:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC2}

		cHtml += ExecInPage( "PWSA371A" )

	Else
		Return RHALERT( "", STR0012, STR0019, "W_PWSA371.APW" ) //"Erro"###"Currículo não localizado!"
	EndIf

WEB EXTENDED END

Return cHtml


Web Function PWSA371B()
	Local cHtml   	  	:= ""
	Local oOrg
	Local nI
	Local nTam                                                  

	WEB EXTENDED INIT cHtml START "InSite"	              
	 	 
		oOrg  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW")  
				
		oOrg:cEmployeeFil  	:= HttpGet->EmployeeFilial
		oOrg:cRegistration 	:= HttpGet->Registration
	   	
		IF oOrg:GetStructure()
			HttpSession->aStructure  := aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)
			
			nTam := Len(HttpSession->aStructure)
			For nI := 1 To nTam
				If Alltrim(HttpSession->aStructure[nI]:cRegistration) == Alltrim(HttpGet->Registration) .AND.;
				    AllTrim(HttpSession->aStructure[nI]:cEmployeeFilial) == AllTrim(HttpGet->EmployeeFilial)  		
	        		HttpGet->nIndice	:= str(nI)
	        		HttpGet->nOperacao	:= "1"
	        	EndIf
	        Next nI
	        If !Empty(HttpGet->nIndice)	        
	        	fGetInfRotina("W_PWSA370.APW")      
		   		W_PWSA261()
		  	EndIf
		Else
			HttpSession->aStructure := {}

			HttpSession->_HTMLERRO := { STR0012, PWSGetWSError(), "W_PWSA371.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	WEB EXTENDED END
Return cHtml 


Web Function PWSA371C()
Local cHtml   	  	:= ""
Local lViewCand		:= .F.
Local cData
Local cHora
Local lOk			:= .T.			

	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVACANCY"), WSRHVACANCY():New())
		WsChgURL(@oObj,"RHVACANCY.APW")
	
		HttpSession->cVacancyFil  	:= HttpPost->cVacancyFil
		oObj:cCurricCode	:= HttpPost->cCodCurric 
		oObj:cVacancyCode	:= HttpSession->cVacancyCode
		oObj:cTypeApproval	:= HttpPost->cAprTd
		
		If HttpPost->cAprTd == 'S'
			If oObj:SetApproveCandidate()
				If oObj:nSetApproveCandidateResult > 0
					lViewCand	:= .T.
				EndIf	
			Else
				Return RHALERT( "", STR0012, STR0020, "W_PWSA371.APW" ) //"Erro"###""Não foi possível concluir a operação."
			EndIf
		Else
			cData	:= &('HttpPost->data'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
			cHora	:= &('HttpPost->hora'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
			//Validando a data
			If Len(cData) <> 10 .OR. valtype(val(left(cData, 2))) <> "N" .OR.;
			     valtype(val(substr(cData, 4, 2))) <> "N" .OR. valtype(val(right(cData, 4))) <> "N" .OR.;
			     Substr(cData, 3, 1) <> "/" .OR. Substr(cData, 6, 1) <> "/"
				HttpSession->Msg	:= STR0015 + "\n\n" + STR0016 //"Ooperação cancelada" \n\n "Formato da data é inválido.\nUtilize o formato DD/MM/AAAA"
				lOk	:= .F.
				lViewCand := .F.
			EndIf
			If (val(substr(cData, 4, 2)) == 4 .OR. val(substr(cData, 4, 2)) == 6 .OR.;
					 val(substr(cData, 4, 2)) == 9 .OR. val(substr(cData, 4, 2)) == 11) .AND. val(left(cData, 2)) > 30
				HttpSession->Msg	:= STR0015 + "\n\n" + STR0017 + " 30 " + STR0018 //"Ooperação cancelada" \n\n "Dia incorreto! O mês especificado contém no máximo" 30 "dias."
				lOk	:= .F.
				lViewCand := .F.
			ElseIf ((val(right(cData, 4)) % 4) <> 0 .AND. val(substr(cData, 4, 2)) == 2) .AND.  val(left(cData, 2)) > 28
				HttpSession->Msg	:= STR0015 + "\n\n" + STR0017 + " 28 " + STR0018 //"Ooperação cancelada" \n\n "Dia incorreta!! O mês especificado contém no máximo" 28 "dias."
				lOk	:= .F.
				lViewCand := .F.
			ElseIf ((val(right(cData, 4)) % 4) == 0 .AND. val(substr(cData, 4, 2)) == 2) .AND.  val(left(cData, 2)) > 29
				HttpSession->Msg	:= STR0015 + "\n\n" + STR0017 + " 29 " + STR0018 //"Ooperação cancelada" \n\n "Dia incorreta!! O mês especificado contém no máximo" 29 "dias." 
				lOk	:= .F.
				lViewCand := .F.
			ElseIf val(left(cData, 2)) == 0 .OR. val(left(cData, 2)) > 31
				HttpSession->Msg	:= STR0015 + "\n\n" + STR0017 + " 31 " + STR0018 //"Ooperação cancelada" \n\n "Dia incorreta!! O mês especificado contém no máximo" 31 "dias."
				lOk	:= .F.
				lViewCand := .F.			
			EndIf
			
			If Len(cHora) <> 5 .OR. valtype(val(left(cHora, 2))) <> "N" .OR. valtype(val(right(cHora, 2))) <> "N" .OR.;
				(val(left(cHora, 2)) < 0 .OR. val(left(cHora, 2)) > 23) .OR. (val(right(cHora, 2)) < 0 .OR. val(right(cHora, 2)) > 59) 
				HttpSession->Msg	:= STR0015 + "\n\n" + STR0021 //"Ooperação cancelada" \n\n "O formato da hora está inválido!\nUtilize o formato HH:MM." 
				lOk	:= .F.
				lViewCand := .F.
			EndIf
			
			
			If lOk
				oObj:lAlterDateTime									:= .F.
				oObj:lAlterObsCand									:= .F.
				oObj:lSendMailReprove								:= .F.
				oObj:oWsSetAgendaCandidate:cCodeStep				:= HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep
			
				oObj:oWsSetAgendaCandidate:cDate 					:= &('HttpPost->data'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
				oObj:oWsSetAgendaCandidate:cTime					:= &('HttpPost->hora'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
				oObj:oWsSetAgendaCandidate:cCodeTest				:= &('HttpPost->codTest'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
				oObj:oWsSetAgendaCandidate:cEvaluationOk			:= &('HttpPost->testRealiz'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
				oObj:oWsSetAgendaCandidate:cEvaluationFinal			:= &('HttpPost->resAval'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
				oObj:oWsSetAgendaCandidate:cStepSituation			:= &('HttpPost->resEtap'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
				oObj:oWsSetAgendaCandidate:cObservationCandidate	:= AllTrim(&('HttpPost->obsCand'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep))
				oObj:oWsSetAgendaCandidate:cObservationEvaluator	:= AllTrim(&('HttpPost->obsAval'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep))
			   
			   	If HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cDate <>; 
			   		&('HttpPost->data'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
			   		oObj:lAlterDateTime	:= .T.
			   	EndIf 
			   
			   	If HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cTime <>; 
			   		&('HttpPost->hora'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
			    	oObj:lAlterDateTime	:= .T.
			   	EndIf
			    /* Ao comparar o post com a session está inserindo espaços que sempre dão diferença
			   	If HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cObservationCandidate <>; 
			   		&('HttpPost->obsCand'+HttpPost->cCodCurric+HttpSession->ShowCandidateVacancy[val(HttpPost->cM)]:oWSAgendaCandidate:oWSStepsAgendaCandidate[val(HttpPost->cNz)]:cCodeStep)
			    	oObj:lAlterObsCand	:= .T.
			   	EndIf
			   	*/
			   	If HttpPost->cEmailReprov == "S"
					oObj:lSendMailReprove	:= .T.
				EndIf
			   	 			
				If oObj:SetSchedule()
					If oObj:nSetScheduleResult > 0
						lViewCand	:= .T.
					EndIf		
				Else
					Return RHALERT( "", STR0012, STR0020, "W_PWSA371.APW" ) //"Erro"###""Não foi possível concluir a operação."    "
				EndIf 
			EndIf
		EndIf
		
		If lOk
			If lViewCand
				HttpSession->Msg	:= STR0014	//"Operação Realizada com sucesso!"
				//Volta para a tela de candidatos efetuando o refresh e retornando sem o candidato aprovado
				W_PWSA371()
			Else
				HttpSession->Msg	:= STR0014 //"Operação Realizada com sucesso!"
				//Volta para a tela de vagas efetuando o refresh e retornando sem a vaga pois todas as oportunidades foram preenchidas
				W_PWSA370()
			EndIf
		Else
			//Volta para a tela de candidatos sem cocluir a operacao
			W_PWSA371()
		EndIf	
	WEB EXTENDED END

Return cHtml

Web Function PWSA371D()
Local cHtml   	  	:= ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		W_PWSA371()
	WEB EXTENDED END
Return cHtml
