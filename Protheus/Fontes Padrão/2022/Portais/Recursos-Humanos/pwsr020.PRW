#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PWSR020PRW.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Chamado³  Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Emerson Camp³07/03/14³R.196101³Ajustes para atender a P12              ³±±
±±³            ³        ³        ³                                        ³±±
±±³Allyson M   ³22/10/14³  TQUQES³Ajuste no titulo da pagina de vagas     ³±±
±±³            ³        ³        ³disponiveis p/ usar a string do include.³±±
±±³Renan Borges³10/07/15³  TSS563³Ajuste para voltar para a página correta³±±
±±³            ³        ³        ³após a mensagem de que não há vagas dis-³±±
±±³            ³        ³        ³poníveis.                               ³±±
±±³Renan Borges³08/12/15³TTSYXZ  ³Ajuste para que a rotina de solicitação ³±±
±±³            ³        ³        ³de vagas internas no Portal de Gestão o ³±±
±±³            ³        ³        ³capital humano atualize o status das so-³±±
±±³            ³        ³        ³licitações ao atualizar a pagina.       ³±±
±±|M. Silveira |08/06/17|DRHPONTP|Ajustes na inscricao do Proc. Selectivo ³±±
±±|            |        |-812    |p/ incluir a filial e a sua descricao.  ³±±
±±|Wesley 	   |29/09/17|MPRIMESP|Ajustes na reinscrição de vaga.         ³±±
±±|Lossani     |        |-10475  |                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#DEFINE PAGE_LENGTH 10
//Visualizacao de Vagas
Web Function PWSR020()	//ShowVacancy

Local cHtml := ""
Local cMsg	:= ""
Local oObj
Local oMsg
Local oObjCurr

HttpSession->nPageLength	:= PAGE_LENGTH
Private lLoginOk	:= .F.

HttpSession->FiltroVagas	:= ''
HttpSession->FiltroField	:= ''
HttpSession->GetVacancy		:= {}
HttpSession->cSituation		:= '4'
HttpSession->cScore			:= ''
HttpSession->cMsg			:= ''

If HttpSession->cTipoPortal == '2'
	HttpSession->cTypeRequest	:= "9"	//Vagas Internas
ElseIf HttpSession->cTipoPortal == '9'
	HttpSession->cTypeRequest	:= "H" 	//Vagas Externas
EndIf
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml //START "InSite"
	oObjCurr  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())	
	WsChgURL(@oObjCurr,"RHCURRICULUM.APW")

	If HttpSession->cTipoPortal == '9'
		If Empty(HttpSession->GetCurriculum)
			If !Empty(HttpPost->cCurricCpf)

				HttpSession->cCurricCpf 	:= DECODE64(HttpPost->cCurricCpf)
				HttpSession->cCurricPass 	:= DECODE64(HttpPost->cCurricPass)

				If oObjCurr:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpSession->cCurricPass, 2 )
					HttpSession->GetCurriculum 	:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC1}
					HttpSession->GETTABLES 		:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC2}
					lLoginOk	:= .T.
				Else
					lLoginOk	:= .F.
					HttpSession->cCurricCpf := ""
					Return RHALERT( "", STR0001, STR0008, "W_PWSR020A.APW" ) //"Portal Candidato"###"CPF ou Senha invalido."
				EndIf
			Else
				lLoginOk	:= .F.
				HttpSession->cCurricCpf := ""
				Return RHALERT( " ", STR0001, STR0009, "W_PWSR020A.APW" ) //"Portal Candidato"###"CPF deve ser informado."
			EndIf
		Else
			If oObjCurr:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpSession->cCurricPass, 3 )
				HttpSession->GetCurriculum	:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC1}
				HttpSession->GETTABLES 		:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC2}
				lLoginOk	:= .T.
			Else
				lLoginOk	:= .F.
				HttpSession->GetCurriculum := {}
				Return RHALERT( " ", STR0001, STR0018, "W_PWSR020A.APW" ) //"Curriculo nao encontrado"
			EndIf
		EndIf
	EndIf

	If HttpSession->cTipoPortal == '2' .OR. (lLoginOk .and. HttpSession->cTipoPortal == '9')
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVACANCY"), WSRHVACANCY():New())
		oMsg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oObj,"RHVACANCY.APW")
		WsChgURL(@oMsg,"CFGDICTIONARY.APW")

		If !Empty(HttpPost->cFilterValue)
			oObj:cFilterValue			:= HttpPost->cFilterValue
			oObj:cFilterField			:= HttpPost->cFilterField
			HttpSession->FiltroVagas	:= HttpPost->cFilterValue
			HttpSession->FiltroField	:= HttpPost->cFilterField
		EndIf

		//Objeto que retorna o conteudo do Parametro "MV_VAGAMSG" (SX6)
		If oMsg:GETPARAM( "MSALPHA", "MV_VAGAMSG" )
			If oMsg:cGETPARAMRESULT != ".F."
				cMsg := oMsg:cGETPARAMRESULT
			EndIf
		EndIf

		If HttpSession->cTipoPortal == "2"
			oObj:cTypeVacancy := "2"
		ElseIf HttpSession->cTipoPortal == "9"
		  	oObj:cTypeVacancy := "3"
		EndIf

	    //Registration somente deve ser enviado a Matricula do usuario
	    //qdo proveniente da rotina Avaliação do Processo Seletivo
	    oObj:cRegistration	:= ''

		If oObj:GetVacancy( "MSALPHA",,,,,,, .T. )

			If Len( oObj:oWSGETVACANCYRESULT:oWSVACANCYCHOICE ) > 0
				If Len(oObj:oWSGETVACANCYRESULT:oWSVACANCYCHOICE) > 0
					HttpSession->nPageTotal	:=  Ceiling( Len(oObj:oWSGETVACANCYRESULT:oWSVACANCYCHOICE)/PAGE_LENGTH)
				EndIf

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

				HttpSession->GetVacancy := {oObj:oWSGETVACANCYRESULT:oWSVACANCYCHOICE}

				cHtml += ExecInPage( "PWSR020" )
			Else
				//Permite o Usuario Alterar a Mensagem Padrao quando Nao Ha Vagas Disponiveis
				If !Empty(cMsg)
					cHtml := RHALERT( "", STR0001, cMsg, "W_PWSR020.APW" ) //"Vagas Disponiveis"
				Else
					cHtml := RHALERT( "", STR0001, STR0002, "W_PWSR020.APW" ) //"Vagas Disponiveis"###"Não existem vagas disponíveis no momento."
				EndIf
			EndIf

		Else
			If HttpSession->cTipoPortal == "9"	// Portal do Candidato
				HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSR001.APW" ,"top"}			//"Erro"
			Else
				HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSA000.APW" ,"top"}			//"Erro"
			EndIf
			Return ExecInPage("PWSAMSG" )
		EndIf
	EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************/
Web Function PWSR020A()	//Login - CPF / SENHA
	Local cHtml := ""
	Local oObj
	Local oObjCfg
	Local lOk	:= .F.
	Public	cPaisLoc
	Private	cTtlLogin	:= STR0001
	HttpCTType("text/html; charset=ISO-8859-1")
	If Empty(HttpSession->GetCurriculum) .OR. Empty(HttpSession->GetCurriculum[1]:cCurriculum)
		WEB EXTENDED INIT cHtml
			oObjCfg  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
			WsChgUrl(@oObjCfg,"CFGDICTIONARY.apw")

			oObjCfg:GETPARAM( "MSALPHA", "MV_PAISLOC" )
			cPaisLoc:=oObjCfg:cGETPARAMRESULT

			oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
			WsChgURL(@oObj,"RHCURRICULUM.APW")

	     	//Tratamento para quando um usuario acaba de cadastrar o curriculo e na sequencia se cadastra em uma vaga
			If !Empty(HttpSession->GetCurriculum)

				If Empty(HttpSession->GetCurriculum[1]:cCurriculum)
					If oObj:GetCurriculum( "MSALPHA", HttpSession->GetCurriculum[1]:cCpf, HttpSession->GetCurriculum[1]:cPassword, 2 )
						HttpSession->GetCurriculum 	:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC1}
						HttpSession->GETTABLES 		:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC2}

						lOk	:= .T.
					Else
						HttpSession->cCurricCpf		:= ''
						HttpSession->cCurricPass	:= ''
						HttpSession->GetCurriculum	:= {}
						HttpSession->ShowVacancy	:= {}
						HttpSession->oRequests 		:= {}
						lOk	:= .F.
					EndIf
				Else
					lOk	:= .T.
				EndIf
			EndIf

			If lOk
				W_PWSR020()
			Else
				cHtml += ExecInPage( "PWSR020A" )
			EndIf
		WEB EXTENDED END
	Else
		W_PWSR020()
	EndIf
Return cHtml

/*************************************************************/
/* Visualizacao de Vagas									 */
/*************************************************************/
Web Function PWSR021()	//GetVacancy

Local cHtml := ""
Local oObj
Local cVacancyCode := HttpPost->cVacancyCode
Local cVacancyFil  := HttpPost->cVacancyFil
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml

    oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVACANCY"), WSRHVACANCY():New())
	WsChgURL(@oObj,"RHVACANCY.APW")

	HttpSession->cVacancyCode 	:= cVacancyCode
    HttpSession->cVacancyFil	:= cVacancyFil

	If !Empty( HttpSession->cVacancyCode)

		If oObj:ShowVacancy( "MSALPHA", HttpSession->cVacancyCode, HttpSession->cVacancyFil )
			HttpSession->ShowVacancy := {oObj:oWSSHOWVACANCYRESULT:oWSVACANCYVIEW}

			oObj2  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHFACTORS"), WSRHFACTORS():New())			
			WsChgURL(@oObj2,"RHFACTORS.APW")

			HttpSession->cPositionCode  	:= HttpSession->ShowVacancy[1,1]:cPositionCode
			HttpSession->cCostCenterCode	:= HttpSession->ShowVacancy[1,1]:cCostCenterCode

			If oObj2:BrwFactors( "MSALPHA", HttpSession->cPositionCode, HttpSession->cCostCenterCode )
				HttpSession->BrwFactors 	:= {oObj2:oWSBRWFACTORSRESULT:oWSFACTORSVIEW}
			Else
				HttpSession->BrwFactors 	:= {{}}
			EndIf

			If oObj2:BrwHability( "MSALPHA", HttpSession->cPositionCode, HttpSession->cCostCenterCode )
				HttpSession->BrwHability 	:= {oObj2:oWSBRWHABILITYRESULT:oWSHABILITYVIEW}
			Else
				HttpSession->BrwHability 	:= {{}}
			EndIf

			cHtml += ExecInPage( "PWSR021" )

		Else
			Return RHALERT( "", STR0003, PWSGetWSError(), "W_PWSR020.APW" ) 		//"Erro"
		EndIf
	Else
		Conout(STR0005) //"Código da vaga não encontrado"
		Return RHALERT( "", STR0003, STR0005, "W_PWSR020.APW" ) //"Erro"    -  "Código da vaga não encontrado"
	EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Inscricao a um Processo Selectivo                         */
/*************************************************************/
Web Function PWSR022()

Local cHtml   	:= ""
Local oWs
local nI		:= 0
Local lPerInscr	:= .T.
HttpCTType("text/html; charset=ISO-8859-1")
If HttpSession->cTypeRequest == '9' //Vagas Internas
		WEB EXTENDED INIT cHtml START "InSite"

		oWs  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())			
		WsChgURL(@oWs,"RHREQUEST.APW")

	    oWs:OWSINSCRSELECTIONPROC:CBRANCH            := HttpSession->ShowVacancy[1,1]:cVacancyFil             //Codigo da Filial da Vaga
	    oWs:OWSINSCRSELECTIONPROC:CBRANCHDESCRIPTION := HttpSession->ShowVacancy[1,1]:cVacancyDescriptionFil  //Descricao da filial da Vaga

	    oWs:OWSINSCRSELECTIONPROC:CCODE        	 := HttpSession->ShowVacancy[1,1]:cVacancyCode //Codigo da Vaga
		oWs:OWSINSCRSELECTIONPROC:CDESCRIPTION 	 := HttpSession->ShowVacancy[1,1]:cOpenPositionDescription //Descrição da Vaga

		oWs:OWSINSCRSELECTIONPROC:CPARTICIPANTID := HttpSession->cParticipantID

		If oWs:AddInscrSelectionProc()
			HttpGet->msg := STR0007 // "Operacao realizada com sucesso"
	    	cHtml += ExecInPage( "PWSR020" )
		Else
			HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSA000.APW" ,"top"}			//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	WEB EXTENDED END
ElseIf HttpSession->cTypeRequest == 'H' .AND. Alltrim(HttpSession->GetCurriculum[1]:cCPF) == Alltrim(HttpSession->cCurricCpf) //Vagas Externas
	//Verifica se o candidato já se candidatou a essa vaga - Permite se reinscrever caso a solicitação esteja cancelada e a vaga permitir a reinscrição (QS_REINSC)
	//1=Em processo de aprovacao;2=Atendida;3=Reprovada;4=Aguardando Efetivacao do RH
	For nI := 1 To Len(HttpSession->oRequests)
		//Se existir requisição em aberto ou estiver reprovada e a vaga não permitir reincrição não deixa efetuar uma nova inscrição //Reinscrição [1=Sim 2=Não]
		If HttpSession->oRequests[nI]:oWSItems:oWSTRequestItem[4]:cNewValue == HttpSession->ShowVacancy[1,1]:cVacancyCode
			If HttpSession->oRequests[nI]:oWSStatus:cCode != "3" .Or. ( HttpSession->oRequests[nI]:oWSStatus:cCode = "3" .And. HttpSession->ShowVacancy[1,1]:cReinscription = "2" )
				lPerInscr	:= .F.
			EndIf
		EndIf
	Next nI

	If lPerInscr
		WEB EXTENDED INIT cHtml

			oWs  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())						
			WsChgURL(@oWs,"RHREQUEST.APW")

     	    oWs:OWSINSCRSELECTIONPROC:CBRANCH        	   := HttpSession->ShowVacancy[1,1]:cVacancyFil             //Codigo da Filial da Vaga
	       oWs:OWSINSCRSELECTIONPROC:CBRANCHDESCRIPTION := HttpSession->ShowVacancy[1,1]:cVacancyDescriptionFil //Codigo da Desc da filial da Vaga
		    oWs:OWSINSCRSELECTIONPROC:CCODE        	 := HttpSession->ShowVacancy[1,1]:cVacancyCode              //Codigo da Vaga
			oWs:OWSINSCRSELECTIONPROC:CDESCRIPTION 	 := HttpSession->ShowVacancy[1,1]:cOpenPositionDescription //Descrição da Vaga

			oWs:OWSINSCRSELECTIONPROC:CCPF 			:= Alltrim(HttpSession->cCurricCpf)
			oWs:OWSINSCRSELECTIONPROC:cCurriculum	:= HttpSession->GetCurriculum[1]:cCurriculum
			oWs:OWSINSCRSELECTIONPROC:cName			:= HttpSession->GetCurriculum[1]:cName
			oWs:OWSINSCRSELECTIONPROC:cTest			:= HttpSession->ShowVacancy[1,1]:cTest
			oWs:OWSINSCRSELECTIONPROC:cScore		:= HttpSession->cScore
			oWs:OWSINSCRSELECTIONPROC:cSituation	:= HttpSession->cSituation

			If oWs:AddInscrSelectionProcExt()
				HttpGet->msg := STR0007 // "Operacao realizada com sucesso"
		    	cHtml += ExecInPage( "PWSR020" )
			Else
				Return RHALERT( "", STR0003, PWSGetWSError(), "W_PWSR022.APW" ) //"Erro"
			EndIf
		WEB EXTENDED END
	Else
		HttpSession->_HTMLERRO	  := {,,}
		HttpSession->_HTMLERRO[1] := STR0003	//"Erro"
		HttpSession->_HTMLERRO[2] := STR0010	//"Existe uma solicitação de inscrição para essa vaga em andamento.<br>Aguarde a efetivação da solicitação."
		HttpSession->_HTMLERRO[3] := "W_PWSR020A.APW"

		cHtml += ExecInPage( "PWSRHERR" )
	EndIf
EndIf
Return cHtml

/*************************************************************/
/* Minhas Solicitações - Inscricao a um Processo Selectivo   */
/*************************************************************/
Web Function PWSR022A()
	Local cHtml   	:= ""
	Local oRequest
	Local nI

	Private nCurrentPage
	Private nPageTotal
	Private aSolicitacoes
	Private cLink:= ""
	Private cExtraParams:= ""
	Private aMostra	:= {"TMP_VAGA","TMP_DESC"}
	HttpCTType("text/html; charset=ISO-8859-1")
	//H = igual 'vagas externas' e nao possui login
	If HttpSession->cTypeRequest == 'H'
		WEB EXTENDED INIT cHtml
			Default HttpGet->Page:= "1"
			HttpSession->oRequests:= {}
		 	nCurrentPage:= Val(HttpGet->Page)

			//MINHAS SOLICITACOES
			oRequest  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())						
			WsChgURL(@oRequest,"RHREQUEST.APW")

			oRequest:cRequestType   := "H"//Incricao no Processo Seletivo para uma vaga Externa
			oRequest:cParticipantID := Alltrim(HttpSession->cCurricCpf)
			oRequest:nCurrentPage 	:= nCurrentPage
			oRequest:cFilterField   := HttpGet->FilterField
			oRequest:cFilterValue	:= HttpGet->FilterValue

			If oRequest:GetRequest()
				aSolicitacoes	:= oRequest:oWSGETREQUESTRESULT:oWSLISTOFREQUEST:OWSTREQUEST
				nPageTotal 		:= oRequest:oWSGETREQUESTRESULT:nPagesTotal
			Else
				HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSR022A.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf

			For nI := 1 To Len(aSolicitacoes)
				If (AScan(HttpSession->oRequests, {|oTemp| oTemp:cCode == aSolicitacoes[nI]:cCode}) == 0)
					Aadd(HttpSession->oRequests, aSolicitacoes[nI])
				EndIf
			Next

			cHtml := ExecInPage( "PWSA111B" )
		WEB EXTENDED END
	Else
		WEB EXTENDED INIT cHtml START "InSite"
			Default HttpGet->Page:= "1"
			HttpSession->oRequests:= {}
		 	nCurrentPage:= Val(HttpGet->Page)

			//MINHAS SOLICITACOES
			oRequest  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())			
			WsChgURL(@oRequest,"RHREQUEST.APW")

			oRequest:cRequestType := "9"//Incricao no Processo Seletivo para uma vaga Interna
			oRequest:cParticipantID := HttpSession->cParticipantID
			oRequest:nCurrentPage 	:= nCurrentPage
			oRequest:cFilterField   := HttpGet->FilterField
			oRequest:cFilterValue	:= HttpGet->FilterValue
			oRequest:cEnrolmentId 	:= HttpSession->RHMat

			If oRequest:GetRequest()
				aSolicitacoes	:= oRequest:oWSGETREQUESTRESULT:oWSLISTOFREQUEST:OWSTREQUEST
				nPageTotal 		:= oRequest:oWSGETREQUESTRESULT:nPagesTotal
			Else
				HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSA000.APW","top" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf

			For nI := 1 To Len(aSolicitacoes)
				If (AScan(HttpSession->oRequests, {|oTemp| oTemp:cCode == aSolicitacoes[nI]:cCode}) == 0)
					Aadd(HttpSession->oRequests, aSolicitacoes[nI])
				EndIf
			Next

			cHtml := ExecInPage( "PWSA111B" )
		WEB EXTENDED END
	EndIf

Return cHtml

// Inscricao em um Processo Selectivo quando possui pre-teste
Web Function PWSR024()
Local cHtml   	:= ""
Local nI		:= 1
Local lPerInscr	:= .T.
Local oAssessMent
HttpSession->aQuestoes	:= {}
	HttpCTType("text/html; charset=ISO-8859-1")
	//Verifica se o candidato já se candidatou a essa vaga
	For nI := 1 To Len(HttpSession->oRequests)
		If HttpSession->oRequests[nI]:oWSItems:oWSTRequestItem[4]:cNewValue == HttpSession->ShowVacancy[1,1]:cVacancyCode
			lPerInscr	:= .F.
		EndIf
	Next nI

	If lPerInscr
		If !Empty(httpSession->ShowVacancy[1,1]:cTest)
			WEB EXTENDED INIT cHtml

				oAssessMent  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
				WsChgURL(@oAssessMent,"RHCURRICULUM.APW")

				oAssessMent:cCodAval	:= httpSession->ShowVacancy[1,1]:cTest

				If oAssessMent:GetAssessMent()
					HttpSession->aQuestoes	:= oAssessMent:oWsGetAssessmentResult:oWsTestTypes
				Else
					HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSR020A.APW" }	//"Erro"
					Return ExecInPage("PWSAMSG" )
				EndIf

				cHtml += ExecInPage( "PWSR022" )
			WEB EXTENDED END
		Else
			W_PWSR022()
		EndIf
	Else
		HttpSession->_HTMLERRO	  := {,,}
		HttpSession->_HTMLERRO[1] := STR0003	//"Erro"
		HttpSession->_HTMLERRO[2] := STR0010	//"Existe uma solicitação de inscrição para essa vaga em andamento.<br>Aguarde a efetivação da solicitação."
		HttpSession->_HTMLERRO[3] := "W_PWSR020A.APW"

		cHtml += ExecInPage( "PWSRHERR" )
	EndIf
Return cHtml

// Avaliar o retorno das respostas e validar se o candidato  */
// foi aprovado ou nao.
Web Function PWSR025()
Local cHtml   	:= ""
Local nT
Local nQ
Local nA
Local nMA
Local nO		:= 0
Local nTamTT	:= 0
Local nTamQ		:= 0
Local nTamA		:= 0
Local nSoma		:= 0
Local nTamMA    := 0
Local cCodQ
Local lDissert	:= .F. //Se houver uma dissertativa o sistema nao podera aprovar automaticamente
Local oAssessMent
Local nTotalPontos	:= 0
Local aAlternSelec	:= {}
Local lInvalQuestao	:= .F.

Local oEmail
Local oParam
Local cBody			:= ""
Local cMailAuth		:= ""
Local cMailConta	:= ""
Local cMailSenha	:= ""
Local cMailServer	:= ""
Local nAt			:= 0
Local lAutentic		:= .T.
Local lMailAuth		:= .F.
Local lSSL			:= .F.
Local lTLS			:= .F.

If !Empty(HttpSession->aQuestoes)
	nTamTT	:= Len(HttpSession->aQuestoes)
EndIf
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml

	oAssessMent  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oAssessMent,"RHCURRICULUM.APW")
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation	:= wsClassNew('RHCURRICULUM_ARRAYOFEVALUATIONQUESTIONS')
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions	:= {}

	For nT := 1 To nTamTT
		nTamQ	:= Len(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes)
		For nQ := 1 To nTamQ

			cCodQ	:= HttpSession->aQuestoes[nT]:cItem
			If HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cAnswerType == '3' //3=Dissertativa;
				nO++
				lDissert	:= .T.

				SetObject(nO, @oAssessMent, HttpSession->ShowVacancy[1,1]:cVacancyCode, HttpSession->GetCurriculum[1]:cCurriculum, HttpSession->aQuestoes[nT]:cQuestion, HttpSession->aQuestoes[nT]:cSubject, HttpSession->aQuestoes[nT]:cItem, Alltrim(&("HttpPost->perg"+cCodQ)), Alltrim(HttpPost->tempoUtilizado), HttpSession->aQuestoes[nT]:cEvaluation, 0)
			Else //1=Multipla escolha;2=Unica escolha;4=Pontuacao
				nSoma	:= 0
				nTamA	:= Len(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:oWsListOfAlternative:oWsAlternativeQuestions)
				If HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cAnswerType == '2' //2=Unica escolha
					For nA := 1 To nTamA
						If HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:oWsListOfAlternative:oWsAlternativeQuestions[nA]:cAlternative == &("HttpPost->perg"+cCodQ)
							nO++
							nSoma := Val(Alltrim(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:oWsListOfAlternative:oWsAlternativeQuestions[nA]:cValue))
							nTotal	:= ((Val(Alltrim(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cPoints)) * nSoma) / 100)

							SetObject(nO, @oAssessMent, HttpSession->ShowVacancy[1,1]:cVacancyCode, HttpSession->GetCurriculum[1]:cCurriculum, HttpSession->aQuestoes[nT]:cQuestion, HttpSession->aQuestoes[nT]:cSubject, Alltrim(&("HttpPost->perg"+cCodQ)), '', Alltrim(HttpPost->tempoUtilizado), HttpSession->aQuestoes[nT]:cEvaluation, nTotal)
						EndIf
					Next nA
				Else
					aAlternSelec	:= {}
					If !Empty(&("HttpPost->perg"+cCodQ))
						aAlternSelec:= StrToKarr(&("HttpPost->perg"+cCodQ), ',')
					EndIf
					nTamMA			:= Len(aAlternSelec)
					lInvalQuestao	:= .F.

					For nMA	:= 1 To nTamMA
						For nA := 1 To nTamA
							If (AllTrim(aAlternSelec[nMA]) == Alltrim(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:oWsListOfAlternative:oWsAlternativeQuestions[nA]:cAlternative)) .AND.;
							   (Val(Alltrim(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:oWsListOfAlternative:oWsAlternativeQuestions[nA]:cValue)) == 0)
							    lInvalQuestao	:= .T.
							EndIf
					    Next nA
					Next nMA

					For nA := 1 To nTamA
						For nMA	:= 1 To nTamMA
							If Alltrim(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:oWsListOfAlternative:oWsAlternativeQuestions[nA]:cAlternative) == AllTrim(aAlternSelec[nMA])
								nO++
								nSoma += Val(Alltrim(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:oWsListOfAlternative:oWsAlternativeQuestions[nA]:cValue))

								If !lInvalQuestao
									nTotal	:= ((Val(Alltrim(HttpSession->aQuestoes[nT]:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cPoints)) * nSoma) / 100)
								Else
									nTotal	:= 0
								EndIf

								SetObject(nO, @oAssessMent, HttpSession->ShowVacancy[1,1]:cVacancyCode, HttpSession->GetCurriculum[1]:cCurriculum, HttpSession->aQuestoes[nT]:cQuestion, HttpSession->aQuestoes[nT]:cSubject, HttpSession->aQuestoes[nT]:cItem, '', Alltrim(HttpPost->tempoUtilizado), HttpSession->aQuestoes[nT]:cEvaluation, nTotal)
								Exit
							EndIf
						Next nMA
					Next nA
				EndIf
			EndIf
		Next nQ
	Next nT
	If oAssessMent:SetAssessMent()
		nTotalPontos	:= oAssessMent:nSetAssessmentResult
		/*
		* A reprovação automatica não ocorre se:
		* 1- Se o campo Reprovacao automatica estiver como nao
		* 2- Se houver campos dissertativos na avaliacao
		*/
		If nTotalPontos >= HttpSession->ShowVacancy[1,1]:nPoint .OR. HttpSession->ShowVacancy[1,1]:cAutoFailure == "2" .OR. lDissert
			//HttpSession->ShowVacancy[1][1]:cReinscription - Reinscrição [1=Sim 2=Não]
			HttpSession->cSituation	:=	"4"	//4 = Aguardando efetivação do RH
			HttpSession->cScore		:= Alltrim(Str(nTotalPontos))
		Else
			HttpSession->cSituation	:=	"3"	// 3 = Rejeitada
			HttpSession->cScore		:= Alltrim(Str(nTotalPontos))
		EndIf

		//Envia Email se nro pontos conq maior ou igual ao nro de pontos da avaliacao e nao tem questao dissertativa
		// ou nro ponto menor que a avaliacao e reprovação automatica como sim
		If (nTotalPontos >= HttpSession->ShowVacancy[1,1]:nPoint .AND. !lDissert) .OR. ( nTotalPontos < HttpSession->ShowVacancy[1,1]:nPoint .AND. HttpSession->ShowVacancy[1,1]:cAutoFailure == "1")
			//Envia Email se houver mensagem cadastrada (aprovada ou reprovada)
			If !Empty(HttpSession->GetCurriculum[1]:cEmail) .AND. (!Empty(HttpSession->ShowVacancy[1,1]:cApprovalMessage) .OR. !Empty(HttpSession->ShowVacancy[1,1]:cDisapprovalMessage))
				oEmail  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
				WsChgURL(@oEmail,"RHCURRICULUM.APW")

				oParam  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
				WsChgUrl(@oParam,"CFGDICTIONARY.apw")

				If oParam:GETPARAM( "MSALPHA", "MV_RHAUTEN" )
					lMailAuth	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
				EndIf

				If oParam:GETPARAM( "MSALPHA", "MV_RELSSL" )
					lSSL	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
				EndIf

				If oParam:GETPARAM( "MSALPHA", "MV_RELTLS" )
					lTLS	:= Iif(Valtype(oParam:cGETPARAMRESULT)== "C",&(oParam:cGETPARAMRESULT) ,oParam:cGETPARAMRESULT)
				EndIf

				//CONSULTA E-MAIL CADASTRADO
				If oEmail:GETEMAIL2( "MSALPHA" )
					If Empty(oEmail:oWSGETEMAIL2RESULT:cEmailServ) .Or. Empty(oEmail:oWSGETEMAIL2RESULT:cEmailAccount);
					 	.Or. Empty(oEmail:oWSGETEMAIL2RESULT:cEmailPass)
						HttpSession->cMsg	:= STR0011//"Servidor, Conta ou Senha de e-mail nao configurados."
					Else
						cMailConta	:= oEmail:oWSGETEMAIL2RESULT:cEmailAccount
						cMailSenha  := oEmail:oWSGETEMAIL2RESULT:cEmailPass
						cMailServer := oEmail:oWSGETEMAIL2RESULT:cEmailServ

						If ( nAt := At(":", cMailServer) ) > 0
							cMailServer := Substr(cMailServer, 1, nAt - 1)
						Endif

						If lSSL .And. lTLS
							CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk //TLS SSL
						ElseIf lSSL
							CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk //SSL
						ElseIf lTLS
							CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk //TLS
						Else
							CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
						EndIf

						If lOk .And. lMailAuth
							lAutentic:= MailAuth(cMailConta, cMailSenha)
							If !lAutentic
								If ( nAt := At("@", cMailConta) ) > 0
									cMailAuth	:= Substr(cMailConta, 1, nAt - 1)
									lAutentic	:= MailAuth(cMailAuth, cMailSenha)
								Endif
							EndIf
						EndIf
						If !lDissert
							If lOk	.and. lAutentic
								cBody := "<body Style='color: #000000; font-family: Verdana;'>"
								cBody += "<h3>"+STR0012+"</h3>"//Inscrição em vaga disponível
								cBody += "<p><strong>"+STR0013+":</strong></p>" //Retorno sobre avaliação:
								If nTotalPontos >= HttpSession->ShowVacancy[1,1]:nPoint
									cBody += "<p>"+HttpSession->ShowVacancy[1,1]:cApprovalMessageDescription+"</p>"
								ElseIf HttpSession->ShowVacancy[1,1]:cAutoFailure == "1"
									cBody += "<p>"+HttpSession->ShowVacancy[1,1]:cDisapprovalMessageDescription+"</p>"
						   		EndIf
								cBody += "</body>"


								SEND MAIL FROM cMailConta;
								TO HttpSession->GetCurriculum[1]:cEmail;
								SUBJECT STR0013;	//"Retorno sobre avaliação"
								BODY  cBody;
								RESULT lOk

								If lOk
									HttpSession->cMsg := STR0014	//"E-mail enviado com sucesso."
								Else
									GET MAIL ERROR cSmtpError
									HttpSession->cMsg := "<br>"+STR0015+ cSmtpError //"Não foi possível enviar o e-mail: "
								Endif
								// Desconecta do Servidor
								DISCONNECT SMTP SERVER
							Else
								GET MAIL ERROR cSmtpError
								HttpSession->cMsg := "<br>"+STR0015 + cSmtpError //"Não foi possível enviar o e-mail: "
							//fim do envio de email
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		//Segue com o processo de incricao na vaga
		W_PWSR022()
	Else
		HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSR020A.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf

WEB EXTENDED END

Return cHtml

Static Function SetObject(nO, oAssessMent, cVacancyCode, cCurriculum, cQuestion, cSubject, cItem, cDescAnswer, cTempoUtilizado, cEvaluation, nTotal)

	aAdd(oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions, wsClassNew('RHCURRICULUM_EVALUATIONQUESTIONS'))

	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:cVacancyCode	:= cVacancyCode		//Cod Vaga
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:cCurriculum	:= cCurriculum		//Cod Curriculum
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:cQuestion		:= cQuestion 		//Questao
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:cSubject		:= cSubject 		//Topico
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:cAlternative	:= cItem 			//Alternativa
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:cDescAnswer	:= cDescAnswer		//Resposta
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:cDuration		:= cTempoUtilizado	//Duracao
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:cEvaluation	:= cEvaluation 		//Avaliacao
	oAssessMent:oWsEvaluationData:oWsListOfEvaluation:oWsEvaluationQuestions[nO]:nAdjustment	:= nTotal			//Resultado %

Return
