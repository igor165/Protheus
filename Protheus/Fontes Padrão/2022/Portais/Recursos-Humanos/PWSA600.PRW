#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"  
#INCLUDE "PWSA600.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ Web Functions responsaveis avaliação de treinamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ FNC            ³  Motivo da Alteracao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³              ³        ³                ³                                ³±±
±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*******************************************************************
* Funcao: PWSA600
* Autor: Flavio S. Correa
* Data: 12/01/16
* Lista de Avaliações do Treinamento
********************************************************************/
Web Function PWSA600()
	Local cHtml   	:= ""
	Local oRequest	
	
	WEB EXTENDED INIT cHtml START "InSite"
		HttpCTType("text/html; charset=ISO-8859-1")

		oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTRAININGTEST"), WSRHTRAININGTEST():New())
		WsChgURL(@oRequest,"RHTRAININGTEST.APW")
	
		oRequest:cFILIALFUNC    := HttpSession->aUser[2]
		oRequest:cTIPO		    := "1" //1=pagina de avaliação/2=mural de avisos
		oRequest:cMATRICULA     := HttpSession->aUser[3]
	    httpSession->aAgenda := Nil
	   	If oRequest:BRWAGENDA()
			httpSession->aAgenda := oRequest:oWSBRWAGENDARESULT:OWSTAGENDA
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" ,"top"}	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	
		cHtml := ExecInPage( "PWSA600" )	
	WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA601
* Autor: Flavio S. Correa
* Data: 12/01/16
* Inicia Avaliação
********************************************************************/
Web Function PWSA601()
	Local cHtml   	:= ""
	Local oRequest	
	Local nIndice		:= 0
	
	WEB EXTENDED INIT cHtml START "InSite"
		HttpCTType("text/html; charset=ISO-8859-1")
		
		oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTRAININGTEST"), WSRHTRAININGTEST():New())
		WsChgURL(@oRequest,"RHTRAININGTEST.APW")
	
		oRequest:cCODAVAL    := HttpGet->cCodAval
		oRequest:cTIPO		 := HttpGet->cTipo
		oRequest:nRAJ_RECNO	 := Val(HttpGet->RAJ_RECNO)
		HttpPost->RAJ_RECNO	 := HttpGet->RAJ_RECNO
		nIndice				 := Val(httpGet->nIndice)
		HttpSession->oAvaliacao := Nil
		HttpSession->oAvaliacaoR := Nil
		If nIndice > 0
			HttpSession->oAgenda	:= {HttpSession->aAgenda[nIndice]}
			If oRequest:GETAVALIACAO()
				HttpSession->oAvaliacao := oRequest:oWsGetAvaliacaoResult
				HttpSession->oAvaliacaoR := {oRequest:oWsGetAvaliacaoResult}
				cHtml := ExecInPage( "PWSA601" )	
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" ,"top"}	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->oAgenda := {}
			HttpSession->_HTMLERRO := { STR0001, STR0002, "W_PWSA000.APW" ,"top"}	//"Erro" / "Agenda não encontrada!"
			Return ExecInPage("PWSAMSG" )
		EndIf
	   	
		
		
	WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA602
* Autor: Flavio S. Correa
* Data: 12/01/16
* Salva Avaliação
********************************************************************/
Web Function PWSA602()
Local cHtml   		:= ""
Local nTamQ			:= 0
Local cCodQ			:= ""
Local nMA			:= 0
Local nO			:= 0
Local nQ			:= 0
Local nTamMA    	:= 0
Local aAlternSelec	:= {}
Local oRequest	
Local cResp 		:= ""
Local oAgenda		

If Len(HttpSession->oAgenda) > 0
	oAgenda := HttpSession->oAgenda[1]
EndIf


WEB EXTENDED INIT cHtml START "InSite"
	HttpCTType("text/html; charset=ISO-8859-1")
	
	oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHTRAININGTEST"), WSRHTRAININGTEST():New())
	WsChgURL(@oRequest,"RHTRAININGTEST.APW")
	If Valtype(oAgenda) == "O"
		If oAgenda:lEditavel
			If Valtype(HttpSession->oAvaliacaoR) == "A"
				HttpSession->oAvaliacao := HttpSession->oAvaliacaoR[1]
				nTamQ	:= Len(HttpSession->oAvaliacao:oWsListOfQuestions:oWsQuestionsTestTypes)
				For nQ := 1 To nTamQ			
					cCodQ	:= strzero(nQ,3)
					
					If nQ == 1
						oRequest:oWSAVALIACAO := WsClassNew("RHTRAININGTEST_TAVALIACAO")
						oRequest:oWSAVALIACAO:nRAJ_RECNO 	:= Val(HttpPost->RAJ_RECNO)
						oRequest:oWSAVALIACAO:cDuration		:= Alltrim(HttpPost->tempoUtilizado)
						oRequest:oWSAVALIACAO:oWSANSWERS	:= WSClassNew("RHTRAININGTEST_ARRAYOFTRESPOSTAS")
						oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS := {}
					EndIf
					
					If HttpSession->oAvaliacao:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cAnswerType == '3' //3=Dissertativa;
						cResp := Alltrim(&("HttpPost->perg"+cCodQ))
						If !Empty(cResp)
							nO++
							aadd(oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS,WSClassNew("RHTRAININGTEST_TRESPOSTAS"))
							oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS[nO]:cQUESTIONCODE := HttpSession->oAvaliacao:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cQuestion
							oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS[nO]:cANSWER := cResp
						EndIf
					Else //1=Multipla escolha;2=Unica escolha;4=Pontuacao 
						If HttpSession->oAvaliacao:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cAnswerType $ '2/4' //2=Unica escolha	/pontucao		
							cResp := Alltrim(&("HttpPost->perg"+cCodQ))
							If !Empty(cResp)
								nO++
								aadd(oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS,WSClassNew("RHTRAININGTEST_TRESPOSTAS"))
								oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS[nO]:cQUESTIONCODE := HttpSession->oAvaliacao:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cQuestion
								oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS[nO]:cANSWER := cResp
							EndIf
						Else
							aAlternSelec	:= {}
							If !Empty(&("HttpPost->perg"+cCodQ)) 
								aAlternSelec:= StrToKarr(&("HttpPost->perg"+cCodQ), ',')
							EndIf
							nTamMA	:= Len(aAlternSelec)				
							For nMA	:= 1 To nTamMA
								cResp := AllTrim(aAlternSelec[nMA])
								If !Empty(cResp)
									nO++
									aadd(oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS,WSClassNew("RHTRAININGTEST_TRESPOSTAS"))
									oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS[nO]:cQUESTIONCODE := HttpSession->oAvaliacao:oWsListOfQuestions:oWsQuestionsTestTypes[nQ]:cQuestion
									oRequest:oWSAVALIACAO:oWSANSWERS:OWSTRESPOSTAS[nO]:cANSWER := cResp
								EndIf
							Next nMA
						EndIf			
					EndIf				
				Next nQ 	
				If oRequest:PutAvaliacao()
					cHtml := ExecInPage( "PWSA602" )
					HttpSession->oAvaliacao := Nil
					HttpSession->oAvaliacaoR := Nil
				Else
					HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" ,"top"}	//"Erro"
					Return ExecInPage("PWSAMSG" )
				EndIf	
			Else
				HttpSession->_HTMLERRO := { STR0001, STR0003, "W_PWSA000.APW" ,"top"}	//"Erro" / "Avaliação não encontrada!"
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			cHtml := W_PWSA600()
		EndIf
	Else
		cHtml := W_PWSA600()
	EndIf
WEB EXTENDED END

Return cHtml
