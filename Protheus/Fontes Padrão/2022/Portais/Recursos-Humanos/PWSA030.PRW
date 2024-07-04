#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA030PRW.CH"

#DEFINE cCodUser "MSALPHA"

/*************************************************************/
/* Autor...: Aline Correa do Vale         Data: Julho de 2004 */
/* Objetivo: Portal de Pesquisas de Organizacionais           */
/**************************************************************/
Web Function PWSA030()

Local cHtml := ""
Local oObj
HttpPost->cMsg := STR0008		//"Realizar avaliações de clima organizacional, com a finalidade de analisar o ambiente interno a partir do levantamento de suas necessidades."

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->BRWMYEVALUATES := {}
HttpSession->GETPEVALUATE := {}

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
If !Empty( HttpSession->cParticipantID )
	If oObj:BRWMYEVALUATED( "", HttpSession->cParticipantID, "2", , "1" )
		HttpSession->BRWMYEVALUATES := oObj:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST//{oObj:oWSBRWMYEVALUATESRESULT:oWSEVALUATELIST}
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA00C.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf
EndIf

cHtml += ExecInPage( "PWSA030" )

WEB EXTENDED END

Return cHtml

/*************************************************************
* Autor...: Juliana Barros Mariano         Data: 10/01/2005
* Objetivo:
**************************************************************/
Web Function PWSA030_A()

Local cHtml := ""

Local oParam   	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())

Private cParam  := ""

HttpPost->cPagina := HttpGet->nI

WEB EXTENDED INIT cHtml START "InSite"

WsChgURL(@oParam,"CFGDICTIONARY.APW")
If oParam:GETPARAM( cCodUser, "MV_APDINCB" )
	cParam := AllTrim( oParam:cGETPARAMRESULT )
EndIf

//--Se o parametro nao estiver preenchido exibe, como padrao, somente o codigo
If Empty( cParam )
	cParam := "1"
EndIf

cHtml += ExecInPage( "PWSA031" )

WEB EXTENDED END

Return cHtml

/*************************************************************
* Autor...: Emerson Grassi Rocha         Data: 26/06/06
* Objetivo:
**************************************************************/
Web Function PWSA031A()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

If !Empty( HttpSession->cParticipantID )

	If oObj:EVALUATETYPE( "", HttpGet->cPEvaluateID )
		//1 = identificada
		//2 = nao identificada
		HttpSession->cTpPesquisa := oObj:cEVALUATETYPERESULT
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA00C.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf
EndIf

cHtml += W_PWSA031()

WEB EXTENDED END

Return cHtml

/**************************************************************/
/* Autor...: Aline Correa do Vale         Data: Julho de 2004 */
/* Objetivo: Responder pesquisas organizacionais Portal RH    */
/**************************************************************/
Web Function PWSA031()

Local cHtml 		:= ""
Local oObj
Local nz			:= 0
Local nPagina 		:= 0
Local aAlternEsc	:= {}
Local nCont1		:= 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

If Empty(HttpPost->cPagina)
	HttpPost->cPagina := "1"
	HttpSession->GETPEVALUATE := NIL
	HttpSession->GETPEVALUATE := {}
EndIf

If !Empty( HttpGet->cEvaluatedID ) .And. !Empty( HttpGet->cPEvaluateID ) .And. !Empty( HttpGet->cTipoAv )
	If Empty(HttpSession->GETPEVALUATE) .or.;
	!(HttpSession->GetPEvaluate[1]:cEvaluateID == HttpGet->cPEvaluateID .And.;
	HttpSession->GetPEvaluate[1]:cEvaluatedID == HttpGet->cEvaluatedID .And.;
	HttpSession->GetPEvaluate[1]:cSelfEvaluate == HttpGet->cTipoAv)
		If oObj:GETPEVALUATE( cCodUser, HttpGet->cEvaluatedID, HttpGet->cPEvaluateID, HttpSession->cParticipantID, HttpGet->cTipoAV,,,,, CToD(HttpGet->cDateFrom),HttpGet->cProject )
			HttpSession->GETPEVALUATE := oObj:oWSGETPEVALUATERESULT:oWSEVALUATELIST
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA00C.APW" }		//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	EndIf
ElseIf !Empty(HttpPost->cPaginaAtual) //.And. HttpPost->cStatus != "2"
	for nz := 1 to Len(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[val(HttpPost->cPaginaAtual)]:oWsListOfQuestion:oWsQuestions)
		If HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[val(HttpPost->cPaginaAtual)]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType == "3" //dissertativa
			HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[val(HttpPost->cPaginaAtual)]:oWsListOfQuestion:oWSQUESTIONS[nz]:cAnswerDescription := Alltrim(&("HttpPost->TX"+StrZero(val(HttpPost->cPaginaAtual),2)+StrZero(nz,3)))
		Else
			If type(("HttpPost->RSP"+StrZero(val(HttpPost->cPaginaAtual),2)+StrZero(nz,3))) <> "U"
				aAlternEsc	:= StrTokArr(&("HttpPost->RSP"+StrZero(val(HttpPost->cPaginaAtual),2)+StrZero(nz,3)), ", ")
				IF (aAlternEsc == NIL) .or. Empty(aAlternEsc)
					aAlternEsc:= HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[val(HttpPost->cPaginaAtual)]:oWsListOfQuestion:oWsQuestions[nz]:oWSAlternativeChoice 
				Endif						
				HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[val(HttpPost->cPaginaAtual)]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_ARRAYOFRESPOSTAS"), RHPERFORMANCEEVALUATE_ARRAYOFRESPOSTAS():New())
				For nCont1 := 1 To Len(aAlternEsc)
					If aAlternEsc[nCont1] <> "---"
						Aadd(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[val(HttpPost->cPaginaAtual)]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice:oWSRESPOSTAS,Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_RESPOSTAS"), RHPERFORMANCEEVALUATE_RESPOSTAS():New()))
						HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[val(HttpPost->cPaginaAtual)]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice:oWSRESPOSTAS[nCont1]:cAlternativa := aAlternEsc[nCont1]
					EndIf
				Next
			EndIf	
		EndIf
	next nz
EndIf

cHtml += ExecInPage( "PWSA031A" )

WEB EXTENDED END

Return cHtml

//*************************************************************/
/* Autor...: Aline Correa do Vale         Data: Julho de 2004 */
/* Objetivo: Gravar/Finalizar as respostas da Avaliacao       */
//*************************************************************/
Web Function PWSA033()

Local cHtml 	:= ""
Local oObj 		:= {}
Local ni 		:= 0
Local nc 		:= 0
Local nz		:= 0
Local lCompleto := .T.
Local nCont, nCont1 := 0
Local aAlternEsc	:= {}
 
WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New()))
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

oObj:oWSEVALUATE := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_EVALUATES"), RHPERFORMANCEEVALUATE_EVALUATES():New())
oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_ARRAYOFCOMPETENCES"), RHPERFORMANCEEVALUATE_ARRAYOFCOMPETENCES():New())

oObj:oWSEVALUATE:cEvaluateId  		:= HttpSession->GetPEvaluate[1]:cEvaluateID
oObj:oWSEVALUATE:cEvaluatedId 		:= HttpSession->GetPEvaluate[1]:cEvaluatedID
oObj:oWSEVALUATE:cEvaluatorId 		:= HttpSession->GetPEvaluate[1]:cEvaluatorID
oObj:oWSEVALUATE:cProject     		:= HttpSession->GetPEvaluate[1]:cProject
oObj:oWSEVALUATE:cNet         		:= HttpSession->GetPEvaluate[1]:cNet
oObj:oWSEVALUATE:cLevel       		:= HttpSession->GetPEvaluate[1]:cLevel
oObj:oWSEVALUATE:cVision      		:= HttpSession->GetPEvaluate[1]:cVision
oObj:oWSEVALUATE:cEvaluateType		:= HttpSession->GetPEvaluate[1]:cEvaluateType
oObj:oWSEVALUATE:dInitialDate 		:= HttpSession->GetPEvaluate[1]:dInitialDate
oObj:oWSEVALUATE:dFinalDate   		:= HttpSession->GetPEvaluate[1]:dFinalDate
oObj:oWSEVALUATE:dAnswerFinalDate	:= HttpSession->GetPEvaluate[1]:dAnswerFinalDate
oObj:oWSEVALUATE:cSelfEvaluate		:= HttpSession->GetPEvaluate[1]:cSelfEvaluate
oObj:oWSEVALUATE:cModel       		:= HttpSession->GetPEvaluate[1]:cModel
oObj:oWSEVALUATE:cCompetence  		:= HttpSession->GetPEvaluate[1]:cCompetence

for nc := 1 to Len(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences)
	aAdd( oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES, Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_COMPETENCES"), RHPERFORMANCEEVALUATE_COMPETENCES():New()) )
	oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_ARRAYOFQUESTIONS"), RHPERFORMANCEEVALUATE_ARRAYOFQUESTIONS():New())
	oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:cCompetenceItem := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nc]:cCompetenceItem

    for nz := 1 to Len(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nc]:oWsListOfQuestion:oWsQuestions)
		If nc == val(HttpPost->cPaginaAtual)
			If HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType == "3" //dissertativa
				HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cAnswerDescription := Alltrim(&("HttpPost->TX"+StrZero(nc,2)+StrZero(nz,3)))
			Else
				//Alternativa Escolhida
				If type(("HttpPost->RSP"+StrZero(nC,2)+StrZero(nz,3))) <> "U"
					aAlternEsc	:= StrTokArr(&("HttpPost->RSP"+StrZero(nC,2)+StrZero(nz,3)), ", ")
					IF (aAlternEsc == NIL) .or. Empty(aAlternEsc)
						aAlternEsc:= HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nC]:oWsListOfQuestion:oWsQuestions[nz]:oWSAlternativeChoice 
					Endif						
					HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nC]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_ARRAYOFRESPOSTAS"), RHPERFORMANCEEVALUATE_ARRAYOFRESPOSTAS():New())
					For nCont1 := 1 To Len(aAlternEsc)
						If aAlternEsc[nCont1] <> "---"
							Aadd(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nC]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice:oWSRESPOSTAS,Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_RESPOSTAS"), RHPERFORMANCEEVALUATE_RESPOSTAS():New()))
							HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nC]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice:oWSRESPOSTAS[nCont1]:cAlternativa := aAlternEsc[nCont1]
						EndIf
					Next				
				EndIf
			EndIf
		EndIf

		If HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType == "3" //dissertativa
	    	aAdd( oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS, Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_QUESTIONS"), RHPERFORMANCEEVALUATE_QUESTIONS():New()) )
		    nCont := len(oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS)

			oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cAnswerDescription := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nc]:oWsListOfQuestion:oWsQuestions[nz]:cAnswerDescription
			oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cQuestionID := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nc]:oWsListOfQuestion:oWsQuestions[nz]:cQuestionID
			oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cObjectType := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType
			oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cScale      := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScale
			oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cScaleItem  := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScaleItem
		Else
			If !Empty(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:OWSCOMPETENCES[nc]:oWsListOfQuestion:OWSQUESTIONS[nz]:oWSAlternativeChoice).And.;
					 	If(Len(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nc]:oWsListOfQuestion:oWsQuestions[nz]:oWSAlternativeChoice:OWSRESPOSTAS)>0,HttpSession->GetPEvaluate[1]:oWsListOfCompetence:OWSCOMPETENCES[nc]:oWsListOfQuestion:OWSQUESTIONS[nz]:oWSAlternativeChoice:OWSRESPOSTAS[1]:CALTERNATIVA !='__',.F.) 

				aAdd( oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS, Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_QUESTIONS"), RHPERFORMANCEEVALUATE_QUESTIONS():New()) )
				nCont := len(oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS)

				oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nc]:oWsListOfQuestion:oWsQuestions[nCont]:oWSAlternativeChoice := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice
				
				oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cQuestionID := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nc]:oWsListOfQuestion:oWsQuestions[nz]:cQuestionID
				oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cObjectType := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType
				oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cScale      := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScale
				oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nc]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cScaleItem  := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nc]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScaleItem

			Else
				lCompleto := .F.
				If HttpSession->cTpPesquisa == "2" .And. nc > val(HttpPost->cPaginaAtual)
					Exit
				EndIf
			EndIf
		EndIf
    next nz
    If HttpSession->cTpPesquisa == "2" .And. lCompleto == .F..And. nc > val(HttpPost->cPaginaAtual)
	    Exit
    EndIf
next nc

//MESMO QUE A AVALIACAO ESTEJA COMPLETA, DEVE-SE APERTAR O BOTAO DE FINALIZAR
//SE APERTADO O BOTAO DE SALVAR ELE APENAS GRAVA OS DADOS MAS NAUM FINALIZA
If HttpPost->cSalva == "1"
	lCompleto := .F.
EndIf

//Permitir Finalizar pesquisa, mesmo sem estar totalmente preenchida.
	If oObj:PUTPEVALUATE( cCodUser, oObj:oWsEvaluate, lCompleto )
		If HttpPost->cSalva == "1" //SE FOI APERTADO BOTAO SALVAR
			HttpSession->_HTMLERRO := { STR0002, STR0004, "W_PWSA030.APW" }	//"Pesquisa"##"Respostas gravadas com SUCESSO!"
		ElseIf lCompleto //SE FOI APERTADO BOTAO FINALIZAR
			HttpSession->_HTMLERRO := { STR0002, STR0005, "W_PWSA030.APW" }		//"Pesquisa", "Respostas gravadas e pesquisa finalizada com SUCESSO!"
		Else
			HttpSession->_HTMLERRO := { STR0006, STR0007, "W_PWSA030.APW" }	//"Pesquisa - Incompleta", "Pesquisa gravada e não finalizada por existirem questões sem resposta!"
		EndIf
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA030.APW" }		//"Erro"
EndIf

cHtml := ExecInPage( "PWSAMSG" )

WEB EXTENDED END

Return cHtml



/*******************************************************************
* Funcao: PWSA032 - Tela de abertura com explicacao sobre PESQUISA
* Autor:	Juliana Barros Mariano
* Data:		29/09/2005
********************************************************************/
Web Function PWSA032()

Local cHtml		:= ""
Local oParam 	:= ""
Local oMsg		:= ""


WEB EXTENDED INIT cHtml START "InSite"

oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
oMsg	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oParam,"CFGDICTIONARY.APW")
WsChgURL(@oMsg,"RHPERSONALDESENVPLAN.APW")

HttpPost->cMsg := STR0008		//"Realizar avaliações de clima organizacional, com a finalidade de analisar o ambiente interno a partir do levantamento de suas necessidades."

//RESGATA PARAMETRO CONTENDO CODIGO DA MENSAGEM
//SE EM QUALQUER SITUACAO MSG NAUM ESTIVER CADASTRADA OU ESTIVER EM BRANCO, VALE MSG DEFAULT
If oParam:GETPARAM( cCodUser, "MV_MSGPC" )
	If !Empty(oParam:cGETPARAMRESULT)
		If oMsg:GETMESSAGE( cCodUser, oParam:cGETPARAMRESULT )
			If !Empty(oMsg:cGETMESSAGERESULT)
				HttpPost->cMsg := StrTran( oMsg:cGETMESSAGERESULT, Chr( 10 ), "<br>" )
			EndIf
		EndIf
	EndIf
EndIf

//cHtml := ExecInPage("PWSA032")
cHtml :=  W_PWSA030()
WEB EXTENDED END

Return cHtml

