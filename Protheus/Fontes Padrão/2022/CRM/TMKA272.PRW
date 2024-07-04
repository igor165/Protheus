#INCLUDE "TMKA272.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "APWIZARD.CH"

#DEFINE	CLR_ORANGE	RGB(255,119,000) //Laranja

STATIC lVldAssunto	:= .T.
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³	ACOLS DA ROTINA DE TELEMARKETING													 ³
³																						 ³
³	01 - Assunto																		 ³
³	02 - Descricao do assunto															 ³
³	03 - Produto																		 ³
³	04 - Descricao do produto															 ³
³	05 - Ocorrencia																		 ³	
³	06 - Descricao da ocorrencia														 ³
³	07 - Acao																			 ³
³	08 - Descricao da Acao																 ³
³	09 - Responsavel       																 ³
³	10 - Nome do Responsavel															 ³
³	11 - Data da Acao																	 ³
³	12 - Status    																		 ³
³	13 - Observacao      			   													 ³
³	14 - Data da Execucao			   													 ³
³	15 - Complemento 																	 ³
³																						 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMKA272   ³Autor  ³Vendas Clientes               ³ Data ³  06/03/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Este fonte possui somente funcoes de uso exclusivo para a             ³±±
±±³          ³rotina de TELEMARKETING                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TELEMARKETING 					                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK271AssTmk ³ Autor ³ Vendas Clientes    ³ Data ³ 04/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o do ASSUNTO informado na getdados do TeleMarketing³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleMarketing - SX3                              		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
           
Function TK272AssTmk(cAuxiliar)

Local lRet		:= .T.					//Retorno da funcao
Local aArea		:= GetArea()			//Salva o posicionamento atual
Local aAreaSUC	:= SUC->(GetArea())	//Salva o posicionamento atual
Local nPAssunto := aPosicoes[01][02]	//Assunto
Local nPDescAss := aPosicoes[02][02]	//Descricao do Assunto
Local nPOcorren	:= aPosicoes[05][02]	//Ocorrencia
Local nPDescOco	:= aPosicoes[06][02]	//Descricao da Ocorrencia
Local nPAcao   	:= aPosicoes[10][02]	//Acao
Local nPDescAca	:= aPosicoes[11][02]	//Descricao da Acao

Default cAuxiliar :=  &( ReadVar() )		//Le o conteudo do campo UD_ASSUNTO da getdados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para prosseguir com a validacao do assunto:              ³
//³Caso o assunto tenha sido preenchido via Wizard, nao sera necessario³
//³executar esta validacao novamente                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lVldAssunto
	lVldAssunto := .T.
	Return .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o assunto foi alterado em um item compartilhado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SIX->(DbSeek("SUC8"))
	SUC->(DbSetOrder(8))
	If SUC->(DbSeek(xFilial("SUC") + M->UC_CODIGO + StrZero(N,2) ))
		lRet := .F.
		Help("",1,"TMKCMP06")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o item ja gerou uma OS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. Len(aPosicoes) >= 17 .AND. !Empty(aCols[N][aPosicoes[17][2]])
	Help(" ",1,"TMKSTAOS2")
	lRet := .F.
EndIf

If lRet
	If !Empty(cAuxiliar) //UD_ASSUNTO
		DbSelectarea( "SX5" )
		DbSetorder( 1 )
		If DbSeek( xFilial("SX5")+"T1"+cAuxiliar )
			aCols[n][nPAssunto]	:= SX5->X5_CHAVE
			aCols[n][nPDescAss]	:= X5DESCRI()
		Else
			Help(" ",1,"ASSUNTO" )
			lRet := .F.
		Endif	
	Else
		aCols[n][nPDescAss] := ""
	Endif
	
	If lRet
		aCols[n][nPOcorren]	:= Space(06)
		aCols[n][nPDescOco]	:= Space(30)
		aCols[n][nPAcao] 	:= Space(06)
		aCols[n][nPDescAca]	:= Space(55)
	Endif
	
	lRefresh := .F.
EndIf

RestArea(aAreaSUC)
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK271ProTmk  ³ Autor ³ Vendas Clientes   ³ Data ³ 04/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o do PRODUTO informado na getdados do TeleMarketing³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleMarketing - SX3                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK272ProTmk(cAuxiliar)

Local lRet		:= .T.					//Retorno da funcao
Local aArea		:= GetArea()			//Salva a area atual
Local aAreaSUC	:= SUC->(GetArea())	//Salva a area atual
Local nPProd 	:= aPosicoes[3][2]		//Produto
Local nPDescPro := aPosicoes[4][2]		//Descricao do Produto

Default cAuxiliar :=  &( ReadVar() )		//Le o Conteudo do campo UD_PRODUTO	na getdados
                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o produto foi alterado em um item compartilhado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SIX->(DbSeek("SUC8"))
	SUC->(DbSetOrder(8))
	If SUC->(DbSeek(xFilial("SUC") + M->UC_CODIGO + StrZero(N,2) ))
		lRet := .F.
		Help("",1,"TMKCMP06")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o item ja gerou uma OS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. Len(aPosicoes) >= 17 .AND. !Empty(aCols[N][aPosicoes[17][2]])
	Help(" ",1,"TMKSTAOS2")
	lRet := .F.
EndIf

If lRet
	aCols[n][nPProd]	:= Space( TamSX3("UD_PRODUTO")[1] )
	aCols[n][nPDescPro]	:= Space( TamSX3("UD_DESCPRO")[1] )
	
	If !Empty(cAuxiliar) //UD_PRODUTO

		If !ExistCpo("SB1", cAuxiliar)
			lRet := .F.
		Else
			DbSelectarea("SB1")
			DbSetorder(1)
			If DbSeek(xFilial("SB1")+cAuxiliar)
				aCols[n][nPProd] 	:=SB1->B1_COD
				aCols[n][nPDescPro] :=SB1->B1_DESC
			Else
				Help(" ",1,"B1PROD" )
				lRet := .F.
			Endif
		EndIf
	Endif
	lRefresh:=.T.
EndIf

RestArea(aAreaSUC)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK271OcoTmk ³ Autor ³ Vendas Clientes    ³ Data ³ 04/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o do OCORRENCIA Informado na getdados TeleMarketing³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleMarketing - SX3                              		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TK272OcoTmk(cAuxiliar)

Local lRet		:= .T.					//Retorno da funcao
Local aArea		:= GetArea()			//Salva a area atual
Local aAreaSUC	:= SUC->(GetArea())	//Salva a area da SUC 
Local nPAssunto	:= aPosicoes[1][2]		//Assunto
Local nPOcorren	:= aPosicoes[5][2]		//Ocorrencia 	
Local nPDescOco	:= aPosicoes[6][2]		//Descricao da Ocorrencia
Local cOcorAnt	:= ""
Local cDescAnt	:= ""

Default cAuxiliar	:=  &( ReadVar() )		//Le o conteudo da getdados do campo UD_OCORREN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a ocorrencia foi alterado em um item compartilhado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SIX->(DbSeek("SUC8"))
	SUC->(DbSetOrder(8))
	If SUC->(DbSeek(xFilial("SUC") + M->UC_CODIGO + StrZero(N,2) ))
		lRet := .F.
		Help("",1,"TMKCMP06")
	EndIf
EndIf
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o item ja gerou uma OS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. Len(aPosicoes) >= 17 .AND. !Empty(aCols[N][aPosicoes[17][2]])
	Help(" ",1,"TMKSTAOS2")
	lRet := .F.
EndIf

If lRet
	cOcorAnt := aCols[n][nPOcorren]
	cDescAnt := aCols[n][nPDescOco]
	aCols[n][nPOcorren] := ""
	aCols[n][nPDescOco] := ""
	
	If !Empty(M->UD_OCORREN)
		DbSelectarea("SU9")
		DbSetorder( 1 )
		If DbSeek( xFilial("SU9")+aCols[n][nPAssunto]+cAuxiliar )
			If SU9->U9_VALIDO <> "2"
				aCols[n][nPOcorren] := SU9->U9_CODIGO
				aCols[n][nPDescOco] := SU9->U9_DESC
			Else
				Help(" ",1,"TK272OCO")
				aCols[n][nPOcorren] := cOcorAnt
				aCols[n][nPDescOco] := cDescAnt
				lRet := .F.
			EndIf
		Else
			Help(" ",1,"OCORRENCIA")
			lRet := .F.
		Endif
	Endif
	
	lRefresh:=.T.
EndIf

RestArea(aAreaSUC)
RestArea(aArea) 

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK271AcaTmk ³ Autor ³ Vendas Clientes    ³ Data ³ 04/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o da ACAO Informado na getdados TeleMarketing      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleMarketing - SX3                              		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK272AcaTmk(cAuxiliar)

Local lRet		:= .T.					//Retorno da funcao
Local lSUR		:= .F.					//Se encontrou a amarração Ocorrência X Ação
Local aArea		:= GetArea()			//Salva a area atual
Local aAreaSUC	:= SUC->(GetArea())		//Salva a area atual
Local nPOperador:= aPosicoes[7][2]		//Operador
Local nPDescOper:= aPosicoes[8][2]		//Descricao do Operador	
Local nPAcao   	:= aPosicoes[10][2]		//Acao
Local nPDescAca	:= aPosicoes[11][2]		//Descricao da Acao
Local nPOcorren := aPosicoes[5][2]		//Ocorrência

Default cAuxiliar :=  &( ReadVar() )	//Le o conteudo do campo UD_SOLUCAO na getdados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a acao foi alterada em um item compartilhado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SIX->(DbSeek("SUC8"))
	SUC->(DbSetOrder(8))
	If SUC->(DbSeek(xFilial("SUC") + M->UC_CODIGO + StrZero(N,2) ))
		lRet := .F.
		Help("",1,"TMKCMP06")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o item ja gerou uma OS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. Len(aPosicoes) >= 17 .AND. !Empty(aCols[N][aPosicoes[17][2]])
	Help(" ",1,"TMKSTAOS2")
	lRet := .F.
EndIf

If lRet
	If !Empty(M->UD_SOLUCAO)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe amarração entre a Ocorrência e a Ação.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("SUR")
		DbSetorder(1)
		If !Empty(aCols[n][nPOcorren]) .And. DbSeek(xFilial("SUR")+aCols[n][nPOcorren])		
			While SUR->(!Eof()) .And. SUR->UR_FILIAL == xFilial("SUR") .And. SUR->UR_CODREC == aCols[n][nPOcorren]
                If SUR->UR_CODSOL == cAuxiliar
                	lSUR := .T.
                	Exit
                EndIf
				SUR->(DbSkip())
			EndDo
			DbSelectarea("SUQ")
			DbSetorder(1)				    
		    If lSUR .And. DbSeek(xFilial("SUQ")+cAuxiliar)
				If SUQ->UQ_VALIDO <> "2"
					aCols[n][nPAcao]    := SUQ->UQ_SOLUCAO
					aCols[n][nPDescAca] := SUQ->UQ_DESC
					aCols[n][nPOperador]:= SUQ->UQ_CODRESP		
					PswOrder(1)
					If PswSeek(aCols[n][nPOperador])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica as informacoes do usuario³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aUser:= PswRet(1)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega o nome do usuario 	     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aCols[n][nPDescOper] := aUser[1][2]
					Else
						aCols[n][nPDescOper] :=	""
					Endif
				Else
					aCols[n][nPAcao]    := SPACE(6)
					lRet := .F.
					MsgStop(STR0037, STR0036) // "A ação escolhida está cadastrada como inválida." // "Atenção"
				Endif	
			Else
				Help(" ",1,"ACAO")
				lRet := .F.
			Endif			
		Else
			Help(" ",1,"ACAO")
			lRet := .F.
		Endif
	Else
		aCols[n][nPAcao]     := SPACE(6)
		aCols[n][nPDescAca]  := ""
		aCols[n][nPOperador] := ""
		aCols[n][nPDescOper] :=	""
	Endif
	lRefresh:=.T.
EndIf

RestArea(aAreaSUC)
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK271DescUsu³ Autor ³ Vendas Clientes    ³ Data ³ 04/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Devolve o nome do usuario  selecionado para a ACAO         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleMarketing - SX3                              		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK272DescUsu(cAuxiliar,cNomeRsp)

Local lRet 		:= .T.						//Retorno da funcao
Local aArea		:= GetArea()				//Salva o posicionamento atual
Local aAreaSUC	:= SUC->(GetArea())		//Salva o posicionamento atual
Local nPDescOpe	:= aPosicoes[8][2]			//Descricao do responsavel pela acao
Local nPAcao   	:= aPosicoes[10][02]		//Acao

Default cAuxiliar	:=  &(ReadVar())			//Le o conteudo do campo responsavel
Default cNomeRsp	:= ""

aCols[n][nPDescOpe] := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario foi alterado em um item compartilhado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SIX->(DbSeek("SUC8"))
	SUC->(DbSetOrder(8))
	If SUC->(DbSeek(xFilial("SUC") + M->UC_CODIGO + StrZero(N,2) ))
		lRet := .F.
		Help("",1,"TMKCMP06")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o compartilhamento foi feito para o mesmo usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. !Empty(aCols[N][nPAcao])
	SUQ->(DbSetOrder(1))
	If 	SUQ->(DbSeek( xFilial("SUQ") + aCols[N][nPAcao] )) .AND.;
		SUQ->UQ_COMPART == "1" .AND. (cAuxiliar == __cUserId)
		lRet := .F.
		Help("",1,"TMKCMP05")
	EndIf
EndIf

If lRet .AND. !Empty(cAuxiliar)
	PswOrder(1)
	If PswSeek(cAuxiliar)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica as informacoes do usuario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aUser:= PswRet(1)
		//Verifica se usuario não esta bloqueado.
		If !aUser[1,17]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega o nome do usuario 	     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCols[n][nPDescOpe]	:= aUser[1][2]
			cNomeRsp			:= aUser[1][2]
		Else
			Help(" ",1,"REGBLOQ")
			lRet := .F.
		Endif
	Else
	    lRet := .F.
	Endif
Endif

lRefresh:=.T.                      

RestArea(aAreaSUC)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271DataR³ Autor ³Vendas Clientes        ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa validacao da Data de Retorno Informada. Ela nao pode  ³±±
±±³          ³ser menor que a data base do sistema se n„o for vazia       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleMarketing - SX3                              		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk272DataR()

Local lRet   := .T.						//Retorno da funcao	
Local nTipSta:= Val(M->UC_STATUS)		//Status do Atendimento

If !Empty(M->UC_PENDENT)
	
	If (M->UC_PENDENT < dDatabase)
		Help(" ",1,"DATA_PEND")
		lRet := .F.
	Else
		If (nTipSta == ENCERRADA)
			Help(" ",1,"STATUSLIG")
			M->UC_PENDENT := CTOD("  /  /  ")
			lRet := .F.
		Endif
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkFiltSUR ³ Autor ³ Vendas Clientes       ³ Data ³ 13/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega tela com as acoes para a ocorrencia selecionada     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleMarketing - SX3 / Configuracao TMK - SX3     		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                       
Function Tk272SURFilt(cOcorrencia)

Local oDlgRec															// Tela 
Local oLbx1                                                             // Listbox com as opcoes
Local nPosLbx     	:= 0												// Posicao do Listbox
Local aItems      	:= {}												// Array dos itens
Local cIdTree     	:= ""               								// IDTREE do SUR
Local cIdCode     	:= ""                                               // IDCODE do SUR
Local nPos        	:= 0												// Contador
Local nPOcorre    	:= 0												// Ocorrencia
Local lRet        	:= .F.												// Retorno da funcao
Local nCont			:= 0												// Contador		
Local lTkSURFIL		:= ExistBlock("TKSURFIL")							// Ponto de Entrada para filtrar as ocorrências x ações
Local aRetSURFilt
Local aPDCols 		:= {}
Local aPDFields		:= {"U7_NOME","U7_NOME"}

Default cOcorrencia 	:= ""												// Descricao da ocorrencia

CursorWait()           
               
If Empty(cOcorrencia)
	
	If Type("aHeader") == "U"
		If "TMKR" $ FunName()	//Chama a consulta padrão, quando for executado através de qualquer relatório personalizável.
			lRet := ConPad1(,,,"SUQ")
			Return(lRet)
		EndIf
		cOcorrencia := M->UD_OCORREN
	Else 
		nPOcorre := Ascan(aHeader,{|x| AllTrim(x[2])=="UD_OCORREN"})
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao encontrou o campo UD_OCORREN , e que a funcao esta sendo chamada pela³
		//³rotina de configuracao de tmk, portanto usara o campo UF_OCORREN            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPOcorre == 0)
			nPOcorre:= Ascan(aHeader,{|x| AllTrim(x[2])=="UF_OCORREN"})
		Endif
	
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Se nao encontrou o campo UF_OCORREN , e que a funcao esta sendo chamada pela³
	    //³rotina de help desk, portanto usara o campo ADF_CODSU9		               ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If (nPOcorre == 0)
		    nPOcorre:= Ascan(aHeader,{|x| AllTrim(x[2])=="ADF_CODSU9"})
	    Endif
	                     
		cOcorrencia := aCols[n][nPOcorre]
	EndIf 
EndIf

DbSelectarea("SUR")
DbSetorder(1)
DbSeek(xFilial("SUR")+cOcorrencia)
While !Eof() .AND. (xFilial("SUR") == SUR->UR_FILIAL) .AND. (SUR->UR_CODREC == cOcorrencia)
	If !Empty(SUR->UR_CODSOL)
		Aadd(aItems,{	SUR->UR_CODSOL,;			// 1 - Codigo da Solucao
						SUR->UR_DESC,;              // 2 - Descricao 
						SUR->UR_IDTREE,;            // 3 - ID do TREE
						SUR->UR_IDCODE,;            // 4 - ID do codigo 
						SPACE(40),;                 // 5 - Nome do responsavel
						SPACE(30)})                 // 6 - e-mail do responsavel
	Endif	
	DbSkip()
End  

If lTkSURFIL
	aRetSURFilt := ExecBlock("TKSURFIL",.F.,.F.,{aItems})	
	If 	ValType(aRetSURFilt) == "A" .AND.;
		Len(aRetSURFilt) > 0 .AND.; 
		Len(aRetSURFilt[1]) >= 6
		
		aItems := Array(Len(aRetSURFilt))
		aItems := aCopy(aRetSURFilt, aItems)
	EndIf
EndIf 
              
If Len(aItems) <= 0 
   Help(" ",1,"FALTA_ACAO")
   Return(lRet)
Endif

For nCont := 1 TO Len(aItems)
	DbSelectarea("SUQ")
	DbSetorder(1)
	If DbSeek(xFilial("SUQ")+aItems[nCont][1])
		aItems[nCont][6] := SUQ->UQ_EMAIL
	
		PswOrder(1)
		If !Empty(SUQ->UQ_CODRESP) .AND. PswSeek(SUQ->UQ_CODRESP)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica as informacoes do usuario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aUser:= PswRet(1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega o nome do usuario 	     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aItems[nCont][5] := aUser[1][2]
		Endif
	Endif
Next nCont

CursorArrow()

FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)	
DEFINE MSDIALOG oDlgRec FROM 50,003 TO 260,730 TITLE STR0001 PIXEL //"Ocorrencia X Acao" 

	@ 03,04 LISTBOX oLbx1 VAR nPosLbx;
		 FIELDS HEADER ;
			STR0002,; 	//"Acao"
			STR0003,;	//"Descricao" 
			STR0070,;   //"Responsável"
			STR0004;	//"E-Mail"
		 SIZE 355,80 OF oDlgRec PIXEL NOSCROLL 
	oLbx1:SetArray(aItems)
    oLbx1:bLine:={|| {	aItems[oLbx1:nAt,1],;			// Codigo da Acao
					   	aItems[oLbx1:nAt,2],;           // Descricao da Acao
					   	aItems[oLbx1:nAt,5],;           // Responsavel 
					   	aItems[oLbx1:nAt,6]}}           // Email

    oLbx1:BlDblClick := {||(lRet:= .T.,nPos:= oLbx1:nAt, oDlgRec:End())}

	If FATPDActive() .And. FTPDUse(.T.)
		aPDCols := {"","","U7_NOME","UQ_EMAIL"}
		oLbx1:aObfuscatedCols := FATPDColObfuscate(aPDCols)
	Endif

	oLbx1:Refresh()
    
    DEFINE SBUTTON FROM 88,300 TYPE 1 ENABLE OF oDlgRec ACTION (lRet:= .T.,nPos:= oLbx1:nAt,oDlgRec:End())
    DEFINE SBUTTON FROM 88,335 TYPE 2 ENABLE OF oDlgRec ACTION (lRet:= .F.,oDlgRec:End())

FATPDLogUser("TK272SURFI")
ACTIVATE MSDIALOG oDlgRec CENTERED

If lRet
   cIdTree:= aItems[nPos][3]
   cIdCode:= aItems[nPos][4]
   DbSelectarea("SUR")
   DbSetorder(1)
   DbSeek(xFilial("SUR")+cOcorrencia+cIdTree+cIdCode)
Endif

FATPDUnload()
aSize(aPDCols, 0)
aSize(aPDFields, 0)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkFiltSU9 ³ Autor ³ Vendas Clientes       ³ Data ³ 13/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega tela com as ocorrencias do assunto selecionado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleMarketing - SX3                              		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk272SU9Filt()

Local oDlgSu9														// Tela
Local oLbx1                                                         // Listbox
Local nPosLbx  := 0                                                 // Posicao do List
Local aItems   := {}                                                // Array com os itens
Local nPos     := 0                                                 // Posicao no array
Local nPAssunto:= 0													// Assunto
Local cAssunto := ""                                                // Descricao do Assunto
Local lRet     := .F.                                               // Retorno da funcao
Local lTkSU9FIL:= ExistBlock("TKSU9FIL")							// Ponto de Entrada para filtrar as ocorr?cias
Local aRetSU9Filt 													// Retorno do Ponto de Entrada

CursorWait()

If Type("aHeader") == "U"
	If "TMKR" $ FunName()	//Chama a consulta padrão, quando for executado através de qualquer relatório personalizável.
		lRet := ConPad1(,,,"SU9")
		Return(lRet)
	EndIf
	cAssunto := M->UD_ASSUNTO
Else
	nPAssunto := Ascan(aHeader,{|x| AllTrim(x[2])=="UD_ASSUNTO"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao encontrou o campo UD_ASSUNTO , e que a funcao esta sendo chamada pela  ³
	//³rotina de configuracao de tmk, portanto usara o campo UF_ASSUNTO              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPAssunto == 0)
		nPAssunto:= Ascan(aHeader,{|x| AllTrim(x[2])=="UF_ASSUNTO"})
	Endif
	
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Se nao encontrou o campo UF_ASSUNTO , e que a funcao esta sendo chamada pela  ³
    //³rotina de Help Desk, portanto usara o campo M->ADE_ASSUNT              			 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If (nPAssunto == 0)
    	cAssunto := M->ADE_ASSUNT
    Else
	    cAssunto := Acols[n][nPAssunto]	
    Endif
EndIf

DbSelectarea("SU9")
DbSetorder(1)
DbSeek(xFilial("SU9")+cAssunto)
While !Eof() .AND. (xFilial("SU9") == SU9->U9_FILIAL) .AND. (SU9->U9_ASSUNTO == cAssunto)
	If !Empty(SU9->U9_CODIGO) .AND. (SU9->U9_VALIDO == "1")                  
		Aadd(aItems,{	SU9->U9_CODIGO,;    //Codigo
						SU9->U9_DESC,;      //Descricao
						SU9->U9_PRAZO})     //Prazo
	Endif	
	DbSkip()
End  

If lTkSU9FIL
	aRetSU9Filt := ExecBlock("TKSU9FIL",.F.,.F.,{aItems})	
	If 	ValType(aRetSU9Filt) == "A" .AND.;
		Len(aRetSU9Filt) > 0 .AND.; 
		Len(aRetSU9Filt[1]) >= 3
		
		aItems := Array(Len(aRetSU9Filt))
		aItems := aCopy(aRetSU9Filt, aItems)
	EndIf
EndIf     

CursorArrow()
	     
If Len(aItems) <= 0
   Help(" ",1,"FALTA_OCOR")
   Return(lRet)
Endif	
	
DEFINE MSDIALOG oDlgSu9 FROM  50,003 TO 260,500 TITLE STR0005 PIXEL  //"Ocorrencias Relacionadas" 

	@ 03,10 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
			STR0006,;	//"Ocorrencia"
			STR0003,;	//"Descricao"
			STR0007; 	//"Prazo" 
			SIZE 233,80 OF oDlgSu9 PIXEL NOSCROLL //"Ocorrencia","Descricao","Prazo" 
	oLbx1:SetArray(aItems)
    oLbx1:bLine:={||{aItems[oLbx1:nAt,1],;
					 aItems[oLbx1:nAt,2],;
					 aItems[oLbx1:nAt,3] }}

    oLbx1:BlDblClick := {||(lRet:= .T.,nPos:= oLbx1:nAt, oDlgSu9:End())}
	oLbx1:Refresh()
	
    DEFINE SBUTTON FROM 88,175 TYPE 1 ENABLE OF oDlgSu9 ACTION (lRet:= .T.,nPos := oLbx1:nAt,oDlgSu9:End())
    DEFINE SBUTTON FROM 88,210 TYPE 2 ENABLE OF oDlgSu9 ACTION (lRet:= .F.,oDlgSu9:End())

ACTIVATE MSDIALOG oDlgSu9 CENTERED

If lRet
   DbSelectarea("SU9")
   DbSetorder(1)
   IF DbSeek(xFilial("SU9")+cAssunto+aItems[nPos][1])
      M->UD_OCORREN := SU9->U9_CODIGO
   ENDIF
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271LigPend   ³Autor ³Vendas Clientes    ³ Data ³ 04/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe as ligacoes pendentes para o operador                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TeleMarketing                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK272LigPend(nOpc,lHabilita,oFolderTmk,oEnchTmk,cLock)

Local aArea 		:= GetArea()						// Area atual 
Local lTMKPEND 	:= ExistBlock("TMKPEND")				// P.E. para TeleMarketing
Local cCodLig		:= ""								// Codigo do Atendimento
Local oDlgHist	:= Nil									// Tela da consulta
Local oLbx			:= Nil								// Listbox com os cabecalhos do atendimento
Local oGetHist	:= Nil									// Itens do atendimento selecionado	
Local oObsMemo	:= Nil									// Campo MEMO para a observacao do atendimento
Local cObsMemo 	:=""								// String do campo MEMO	
Local oMonoAs 	:= TFont():New( "Courier New",6,0) 	// Fonte para o campo Memo
Local aPendente 	:= {}								// Array com as ligacoes pendentes
Local lRet			:= .F.								// Retorno da funcao
Local nOpcA		:= 0                                // Opcao de OK ou CANCELA
Local aHeaAnt		:= Aclone(aHeader)					// Salva o AHEADER atual
Local aColAnt		:= Aclone(aCols)					// Salva o ACOLS atual
Local nAnt 		:= n								// Salva o "n" atual
Local aFirst[1][Len(aHeader)+1]						 
Local cOperador 	:= ""								// Nome do Operador que tem as ligacoes pendentes.
Local oInd 		:= Nil
Local opesq 		:= Nil
Local oButPesq 	:= Nil
Local oButClr 	:= Nil
Local cPesq 		:= Space(100)
Local cInd 		:= Space(100)
Local aIndPesq 	:= { STR0075, STR0076, STR0077, STR0078 } //"1=Supervisor/Grupo" # "2=Chamado" # "3=Data" # "4=Contato"
Local bPesq 		:= { || Tk272Psq( 1,aIndPesq, cInd ,cPesq, oLbx, aPendente), oLbx:Refresh() }
Local bClear 		:= { || Tk272Psq( 0,aIndPesq, cInd ,cPesq, oLbx, aPendente), oLbx:Refresh() }
Local cQuery 		:= ""
Local lSuper		:= .F.
Local cUsrLog		:= ""
Local cOperator		:= ""
Local lClear		:= .F.
Local cChave		:= ""
Local lTK272Qry		:= ExistBlock("TK272QRY")
Local aPDFields		:= {"U7_NOME","A1_NOME","U5_CONTAT"}
Local aPDCols		:= {}

Default cLock		:= ""

Private aPenAnt 	:={}

FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia qual o FOLDER esta aberto e qual a ROTINA o operador tem acesso³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (TkGetTipoAte() == "2") .OR. (TkGetTipoAte() == "3") .OR. (nFolder <> 1)
	Help( " ", 1, "TMKROTINA" ) //"Esta rotina esta dispon¡vel apenas para Telemarketing !","Aten‡„o"
	Return(lRet)
Endif	

If Empty(M->UC_OPERADO)
	Help(" ",1,"FALTA_OPER")   
	Return(lRet)
Endif

aCols := aClone(aFirst)
n	  := Len(aCols)	

If lTMKPEND
	lRet := U_TMKPEND(oFolderTmk,oEnchTmk,@nOpc)
	If lRet == NIL .or. !lRet
		aCols 	:= aColAnt
		n		:= nAnt
	EndIf
	Return(lRet)
Endif

CursorWait()

//-----------------------------------------------------------------
// Reposiciona o operador para abrir a tela de pendencias 
//-----------------------------------------------------------------
cUsrLog := RetCodUsr()
If Posicione( "SU7", 1, xFilial( "SU7" ) + AllTrim( M->UC_OPERADO ), "U7_CODUSU" ) == cUsrLog 
	cOperator := M->UC_OPERADO
Else
	cOperator := Posicione( "SU7", 4, xFilial( "SU7" ) + cUsrLog, "U7_COD" )
EndIf

If Posicione( "SU7", 1, xFilial( "SU7" ) + cOperator, "U7_TIPO" ) == "2"
	lSuper := .T. 
EndIf

//-----------------------------------------------------------------
// Busca chamados pendentes para o operador/superior
//-----------------------------------------------------------------
#IFDEF TOP
	If ( TcSrvType()!= "AS/400")
		cQuery := "SELECT  SUC.UC_FILIAL, SUC.UC_CODIGO, SUC.UC_DATA, SUC.UC_CODCONT, SUC.UC_ENTIDAD, SUC.UC_CHAVE, SUC.UC_OPERADO, SUC.UC_MIDIA, SUC.UC_OPERACA, SUC.UC_STATUS, SUC.UC_TIPO, SUC.UC_CODCAMP, SUC.UC_PENDENT," 
		cQuery += " SUC.UC_HRPEND, SUC.UC_CODOBS, SUC.UC_INICIO, SUC.UC_FIM, SUC.UC_CODCANC, SUC.UC_DTENCER, SUC.UC_CODENCE, SUC.UC_CODMOT, SUC.UC_DIASDAT, SUC.UC_HORADAT, SUC.UC_CLIENTE, SUC.UC_LOJA, SUC.UC_PROSPEC, SUC.UC_CHAORIG, SUC.UC_ITCHAOR "
		cQuery += "FROM " + RetSqlName("SUC") + " SUC "
		cQuery += "WHERE "
		cQuery += 		"SUC.UC_FILIAL = '"  + xFilial("SUC") + "' AND "
		cQuery += 		"SUC.UC_OPERADO = '" + cOperator + "' AND "
		cQuery += 		"SUC.UC_STATUS = '" + PadR('2',TamSX3("UC_STATUS")[01]) + "' AND "
		cQuery +=   	"SUC.UC_CODCANC = '" + Space(TamSX3("UC_CODCANC")[01]) + "' AND "
		cQuery += 		"SUC.D_E_L_E_T_ = ' ' AND "
		cQuery += 		"SUC.UC_OPERADO NOT IN"
		cQuery += 		"( SELECT DISTINCT AG9_CODSU7  "
		cQuery += 	"FROM " + RetSqlName( "AG9" ) +" AG9 "
		cQuery += 		"  INNER JOIN " + RetSqlName( "SU7" ) + " SU7 ON U7_FILIAL = '"  + xFilial("SU7") + "' AND U7_COD = AG9_CODSU7 AND U7_TIPO = '2' AND SU7.D_E_L_E_T_= ' ')"
		
		cQuery += 		"	UNION ALL"
		cQuery += " SELECT  SUC.UC_FILIAL, SUC.UC_CODIGO, SUC.UC_DATA, SUC.UC_CODCONT, SUC.UC_ENTIDAD, SUC.UC_CHAVE, SUC.UC_OPERADO, SUC.UC_MIDIA, SUC.UC_OPERACA, SUC.UC_STATUS, SUC.UC_TIPO, SUC.UC_CODCAMP, SUC.UC_PENDENT," 
		cQuery += " SUC.UC_HRPEND, SUC.UC_CODOBS, SUC.UC_INICIO, SUC.UC_FIM, SUC.UC_CODCANC, SUC.UC_DTENCER, SUC.UC_CODENCE, SUC.UC_CODMOT, SUC.UC_DIASDAT, SUC.UC_HORADAT, SUC.UC_CLIENTE, SUC.UC_LOJA, SUC.UC_PROSPEC, SUC.UC_CHAORIG, SUC.UC_ITCHAOR " 
		cQuery += "FROM " + RetSqlName( "SUC" ) + " SUC WHERE UC_OPERADO IN"

		cQuery += 		" ( SELECT DISTINCT AG9_CODSU7  "
		cQuery += 	"FROM " + RetSqlName( "AG9" ) +" AG9 "
		If lSuper
			cQuery += 		"  INNER JOIN " + RetSqlName( "SU7" ) + " SU7 ON U7_FILIAL = '"  + xFilial("SU7") + "' AND U7_COD = AG9_CODSU7 AND ( U7_TIPO = '2' OR U7_TIPO = '1' ) AND SU7.D_E_L_E_T_= ' '"
		Else
			cQuery += 		"  INNER JOIN " + RetSqlName( "SU7" ) + " SU7 ON U7_FILIAL = '"  + xFilial("SU7") + "' AND U7_COD = AG9_CODSU7 AND U7_TIPO = '2' AND SU7.D_E_L_E_T_= ' '"
		EndIf
		cQuery += 		" WHERE AG9_FILIAL = '"  + xFilial("AG9") + "' AND AG9_CODSU0 IN"
		cQuery += 		"	(SELECT AG9_CODSU0 FROM " + RetSqlName( "AG9" ) + " AG9 WHERE AG9_FILIAL = '"  + xFilial("AG9") + "' AND AG9_CODSU7='" + cOperator + "'"	
		If SUC->(ColumnPos("UC_GRUPO")) > 0
			cQuery +=	" AND (SUC.UC_GRUPO = AG9_CODSU0 OR SUC.UC_GRUPO = '  ')"
		EndIf
		cQuery +=		" AND D_E_L_E_T_= ' ')"
		cQuery += 		" AND AG9.D_E_L_E_T_ = ' ' )  AND "
		cQuery += 		"SUC.UC_FILIAL = '" + xFilial("SUC") + "' AND "
		cQuery += 		"SUC.UC_STATUS = '" + PadR('2',TamSX3("UC_STATUS")[01]) + "' AND "
		cQuery +=   	"SUC.UC_CODCANC = '" + Space(TamSX3("UC_CODCANC")[01]) + "' AND "
		cQuery += 		"SUC.D_E_L_E_T_ = ' ' "
		
		cQuery += 		"ORDER BY UC_CODIGO  "
		
		If lTK272Qry
			cQuery := ExecBlock("TK272QRY",.F.,.F.,{cQuery,cOperator,lSuper})
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TMK',.T.,.T.)
		DbSelectArea("TMK")
		DbGoTop()
		While .NOT. eof()
			AAdd(aPendente, {	Tk272Pendente(TMK->UC_STATUS,TMK->UC_CODCANC,TMK->UC_CODIGO),;					//  01 - Semaforo - vermelho
								TMK->UC_CODIGO,;                           						//  02 - Liga‡„o
								DTOC(StoD(TMK->UC_DATA)),;  									//  03 - Data
								TMK->UC_INICIO,;												//  04 - Hora
								Posicione("SU7",1,xFilial("SU7")+TMK->UC_OPERADO,"U7_NOME"),;	//	05 - Operador
								TkEntidade(TMK->UC_ENTIDAD,TMK->UC_CHAVE,1),;					//  06 - Entidade
								TkOperacao(TMK->UC_OPERACA),;									//  07 - Operacao
								Tk272Ligacao(TMK->UC_STATUS),;									//  08 - Status
								Posicione("SUL",1,xFilial("SUL")+TMK->UC_TIPO,"UL_DESC"),;		//  09 - Comunicacao
								Posicione("SU5",1,xFilial("SU5")+TMK->UC_CODCONT,"U5_CONTAT"),; //  10 - Contato
								Posicione("SUO",1,xFilial("SUO")+TMK->UC_CODCAMP,"UO_DESC"),;	//  11 - Campanha
								Posicione("SUH",1,xFilial("SUH")+TMK->UC_MIDIA,"UH_DESC"),;		//  12 - Midia
								DTOC(StoD(TMK->UC_PENDENT)),;                                  	//  13 - Retorno
								TMK->UC_HRPEND,;                                  				//  14 - Hora
								TMK->UC_CODOBS,;												//  15 - Codigo da Observacao
								TMK->UC_CODMOT })                                            	//  16 - Codigo do Encerramento
			DbSkip()
		End
		DbSelectarea("TMK")
		DbCloseArea()
		If Len(aPendente) <= 0
			Help(" ",1,"SEMPENDENT" )
		   	CursorArrow()
			aCols := aClone(aColAnt)
			n 	  := nAnt
			RestArea(aArea)
		   	Return(lRet)
		Endif
		
	Else
		DbSelectarea("SUC")
		DbSetorder(4)			//UC_FILIAL+UC_OPERADO+DTOS(UC_DATA)+UC_STATUS
		If DbSeek(xFilial("SUC")+ cOperator)

			While !Eof() .AND. (xFilial("SUC") == SUC->UC_FILIAL) .AND. (cOperator == SUC->UC_OPERADO) 
			      
				If VAL(SUC->UC_STATUS) == PENDENTE  .AND. (Empty(SUC->UC_CODCANC))
					Aadd(aPendente, {	Tk272Pendente(SUC->UC_STATUS,SUC->UC_CODCANC,SUC->UC_CODIGO),;					//  01 - Semaforo - vermelho
										SUC->UC_CODIGO,;												//  02 - Liga‡„o
										DTOC(SUC->UC_DATA),;											//  03 - Data
										SUC->UC_INICIO,;												//  04 - Hora
										Posicione("SU7",1,xFilial("SU7")+SUC->UC_OPERADO,"U7_NOME"),;	//	05 - Operador
										TkEntidade(UC_ENTIDAD,SUC->UC_CHAVE,1),;						//  06 - Entidade
										TkOperacao(SUC->UC_OPERACA),;                                   //  07 - Operacao
										Tk272Ligacao(SUC->UC_STATUS),;                                  //  08 - Status
										Posicione("SUL",1,xFilial("SUL")+SUC->UC_TIPO,"UL_DESC"),;      //  09 - Comunicacao
										Posicione("SU5",1,xFilial("SU5")+SUC->UC_CODCONT,"U5_CONTAT"),;	//  10 - Contato
										Posicione("SUO",1,xFilial("SUO")+SUC->UC_CODCAMP,"UO_DESC"),;	//  11 - Campanha
										Posicione("SUH",1,xFilial("SUH")+SUC->UC_MIDIA,"UH_DESC"),;		//  12 - Midia
										DTOC(SUC->UC_PENDENT),;                                  	//  13- Retorno
										SUC->UC_HRPEND,;                                  				//  14- Hora
										SUC->UC_CODOBS,;												//  15 - Codigo da Observacao
										SUC->UC_CODMOT })                                             	//  16 - Codigo do Encerramento
										
				Endif
				DbSkip()
			End 
			
			If Len(aPendente) <= 0
				Help(" ",1,"SEMPENDENT" )
			   	CursorArrow()
				aCols := aClone(aColAnt)
				n 	  := nAnt
				RestArea(aArea)
			   	Return(lRet)
			Endif
			
		Else
			Help(" ",1,"SEMPENDENT" )
		   	CursorArrow()
			aCols := aClone(aColAnt)
			n 	  := nAnt
			RestArea(aArea)
		   	Return(lRet)
		Endif   			
	Endif
	
#ELSE
	DbSelectarea("SUC")
	DbSetorder(4)		//UC_FILIAL+UC_OPERADO+DTOS(UC_DATA)+UC_STATUS
	If DbSeek(xFilial("SUC")+ cOperator)
		While !Eof() .AND. xFilial("SUC") == SUC->UC_FILIAL .AND. cOperator == SUC->UC_OPERADO

			If VAL(SUC->UC_STATUS) == PENDENTE .AND. (Empty(SUC->UC_CODCANC))
				Aadd(aPendente, {	Tk272Pendente(SUC->UC_STATUS,SUC->UC_CODCANC,SUC->UC_CODIGO),;					//  01- Semaforo - vermelho
									SUC->UC_CODIGO,;												//  02- Liga‡„o
									DTOC(SUC->UC_DATA),;											//  03- Data
									SUC->UC_INICIO,;												//  04- Hora
									Posicione("SU7",1,xFilial("SU7")+SUC->UC_OPERADO,"U7_NOME"),;	//	05- Operador
									TkEntidade(UC_ENTIDAD,SUC->UC_CHAVE,1),;						//  06- Entidade
									TkOperacao(SUC->UC_OPERACA),;                                   //  07- Operacao
									Tk272Ligacao(SUC->UC_STATUS),;                                  //  08- Status
									Posicione("SUL",1,xFilial("SUL")+SUC->UC_TIPO,"UL_DESC"),;      //  09- Comunicacao
									Posicione("SU5",1,xFilial("SU5")+SUC->UC_CODCONT,"U5_CONTAT"),;	//  10- Contato
									Posicione("SUO",1,xFilial("SUO")+SUC->UC_CODCAMP,"UO_DESC"),;	//  11- Campanha
									Posicione("SUH",1,xFilial("SUH")+SUC->UC_MIDIA,"UH_DESC"),;		//  12- Midia
									DTOC(SUC->UC_PENDENT),;                                  		//  13- Retorno
									SUC->UC_HRPEND,;                                  				//  14- Hora
									SUC->UC_CODOBS,;												//  15- Codigo da Observacao
									SUC->UC_CODMOT})                                              	//  16- Codigo do Encerramento 
									
				Endif
			DbSkip()
		End                                                                                       
		
		If Len(aPendente) <= 0
			Help(" ",1,"SEMPENDENT" )
		   	CursorArrow()
			aCols := aClone(aColAnt)
			n 	  := nAnt
			RestArea(aArea)
		   	Return(lRet)
		Endif
	Else
		Help(" ",1,"SEMPENDENT" )
	   	CursorArrow()
		aCols := aClone(aColAnt)
		n 	  := nAnt
		RestArea(aArea)
	   	Return(lRet)
	Endif   			
#Endif

DbSelectarea("SU7")
DbSetorder(1)
If MsSeek(xFilial("SU7") + cOperator)
	cOperador := SU7->U7_NOME
Endif	 

aPenAnt := aClone( aPendente )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgHist FROM 50,003 TO 600,750 TITLE STR0008 + ": " + cOperador PIXEL   //"Chamados Pendentes" 

	//--------------------------------------------------------------------------------------------
	// Pesquisa por grupos ou operadores
	//--------------------------------------------------------------------------------------------
	@ 10,05 COMBOBOX  oInd	Var cInd ITEMS aIndPesq	SIZE 70,9 OF oDlgHist PIXEL 
	@ 10,75 MSGET oPesq VAR cPesq PICTURE "@!" SIZE 120,9 OF oDlgHist PIXEL 		
	oButPesq := tButton():New(10,200, STR0057, oDlgHist, bPesq,  035,011,,/*oFont*/,,.T.,,,,/*bWhen*/) //"Pesquisar"
	oButClr  := tButton():New(10,240, STR0074, oDlgHist, bClear, 035,011,,/*oFont*/,,.T.,,,,/*bWhen*/) //"Limpar"

	@01,02 TO 210,374 LABEL "" OF oDlgHist PIXEL //"Ligacoes pendentes"
	@28,05 	LISTBOX oLbx; 
			FIELDS; 
			HEADER  "",;
					STR0009,; //"Atendimento"
					STR0010,; //"Data"
					STR0011,; //"Hora"
					STR0012,; //"Operador"
					STR0013,; //"Nome"
					STR0014,; //"Opera??o"
					STR0015,; //"Status"
					STR0016,; //"Comunica??o"
					STR0017,; //"Contato"
					STR0018,; //"Campanha"
					STR0020,;  //"M?ia"
					STR0019,; //"Retorno"
					STR0011,; //"Hora"
			SIZE 365,100 OF oDlgHist PIXEL
	 
	oLbx:SetArray(aPendente)
	oLbx:bLine:={||{aPendente[oLbx:nAt,1],;  //Semaforo - vermelho
					aPendente[oLbx:nAt,2],;  //Liga??o
					aPendente[oLbx:nAt,3],;  //Data
					aPendente[oLbx:nAt,4],;  //Hora
					aPendente[oLbx:nAt,5],;  //Operador
					aPendente[oLbx:nAt,6],;	 //Nome da Entidade
					aPendente[oLbx:nAt,7],;	 //Operacao
					aPendente[oLbx:nAt,8],;	 //Status
					aPendente[oLbx:nAt,9],;  //Comunicacao
					aPendente[oLbx:nAt,10],; //Contato
					aPendente[oLbx:nAt,11],; //Campanha
			       aPendente[oLbx:nAt,12],; //Midia
			       aPendente[oLbx:nAt,13],; //Retorno
			       aPendente[oLbx:nAt,14]}} //Hora
	
	If FATPDActive() .And. FTPDUse(.T.)
		aPDCols := {"","","","","U7_NOME","A1_NOME","","","","U5_CONTAT","","","",""}
		oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)
	Endif
	
	oLbx:bChange := {|| Tk272CargaTmk(	.F.			,oGetHist	,aPendente[oLbx:nAt,2]	,aPendente[oLbx:nAt,15],;
										@cObsMemo	,oObsMemo	,NIL					,NIL,;
										NIL      	,NIL		,NIL					,NIL ),; 
										cCodLig := Eval(oLbx:bLine)[2] } // Carrega os items do pedido
		
	oLbx:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pego o codigo do atendimento e carrega o acols com os itens ³
	//³deste atendimento.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodLig:= aPendente[oLbx:nAt][2]
	
	//----------------------------------------------------------
	// Monta o acols com os itens da ligacao selecionada 	  	 
	//----------------------------------------------------------
	TkMontaItens("SUD",cCodLig,"M")
	
	oGetHist:= MSGetDados():New(130,5,210,370,2,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,99)

	//Observa??o da liga??o
	@ 212,02 TO 258,368 LABEL STR0021 OF oDlgHist PIXEL  //"Observa??o do atendimento" 
	@ 220,05 GET oObsMemo VAR cObsMemo OF oDlgHist MEMO SIZE 360,30 PIXEL READONLY
	oObsMemo:oFont := oMonoAs
	oObsMemo:bRClicked := {|| AllwaysTrue() }
	
	@ 260,005 BITMAP oBmp2 ResName "BR_VERMELHO" OF oDlgHist Size 10,10 NoBorder When .F. Pixel 
	@ 260,015 SAY STR0023 OF oDlgHist Color CLR_RED,CLR_WHITE PIXEL  	// "Pendente"
	
	@ 260,060 BITMAP oBmp1 ResName "BR_MARRON" OF oDlgHist Size 10,10 NoBorder When .F. Pixel 
	@ 260,070 SAY STR0034 OF oDlgHist Color CLR_BROWN,CLR_WHITE PIXEL   // "Pend.com FNC"
	
	@ 260,115 BITMAP oBmp1 ResName "BR_LARANJA" OF oDlgHist Size 10,10 NoBorder When .F. Pixel 
	@ 260,125 SAY STR0035 OF oDlgHist Color CLR_ORANGE,CLR_WHITE PIXEL   // "Pend.FNC Baixada"
	
	DEFINE SBUTTON FROM 260,300 TYPE 1 ENABLE OF oDlgHist ACTION (nOpcA := 1,cCodLig:= aPendente[oLbx:nAt][2],oDlgHist:End())
	
	DEFINE SBUTTON FROM 260,340 TYPE 2 ENABLE OF oDlgHist ACTION (nOpcA := 0,oDlgHist:End())

FATPDLogUser("TK272LIGPE")
ACTIVATE MSDIALOG oDlgHist CENTER ON INIT CursorArrow()

If nOpcA == 1
	lRet := .T.

	//---------------------------------------------------
	// Trava o registro para criar controle de semáforo
	//---------------------------------------------------
	DbSelectarea( "SUC" )
	DbSetorder( 1 )
	If DbSeek( xFilial( "SUC" ) + cCodLig )
			
			cChave := cEmpAnt + xFilial( "SUC" ) + cCodLig
			//---------------------------------------------------
			// Faz um lock no registro
			//---------------------------------------------------
			If Tk271Lock( cChave, M->UC_CODIGO, cCodLig, @cLock)	 	
				//---------------------------------------------------
				// Carrega os dados do atendimento
				//---------------------------------------------------
				Tk272NumTmk(@nOpc,cCodLig,@lHabilita,@oFolderTmk,@oEnchTmk,NIL,NIL)
			Else
				lClear := .T.
			EndIf		
		EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O foco nesse momento encontra-se no campo UC_CODCONT. Nao executar o gatilho existente nesse campo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkSetTrigger(.F.)		
Else
	lClear := .T.
Endif

If lClear 
	aHeader	:= aClone(aHeaAnt)
	aCols		:= aClone(aColAnt)
	n			:= nAnt
EndIf 

FATPDUnload()
aSize(aPDFields,0)
aSize(aPDCols,0)
RestArea(aArea)
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkLigacao  ³ Autor ³Vendas Clientes    	 ³ Data ³18/07/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca o Status da ligacao realizada na ligacao selecionada   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³TeleMarketing                                    			   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272Ligacao(cCampo,cAliasAtu)

Local cStatus := ""			//Retorno da funcao

DEFAULT cAliasAtu := "SUC"  //Alias da tabela que será verificado o campo UC_CODCANC

Do case
	Case AllTrim(cCampo) == "1"
		cStatus := STR0022 //"Planejada" 
	Case AllTrim(cCampo) == "2"
		cStatus := STR0023 //"Pendente" 
	Case AllTrim(cCampo) == "3"
		cStatus := STR0024 //"Encerrada" 
Endcase        

If cAliasAtu == "SUC" .And. !Empty(SUC->UC_CODCANC)
	cStatus := STR0025 //"Cancelada" 
ElseIf cAliasAtu == "TMK" .And. !Empty(TMK->UC_CODCANC)
	cStatus := STR0025 //"Cancelada" 
EndIf

Return(cStatus)

/*                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkCargaTmk   ³ Autor ³ Vendas Clientes     ³ Data ³ 20/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os items gravados de cada ligacao selecionada        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³TeleMarketing			 					     			   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272CargaTmk(	lTodas		,oGetHist	,cCodLig	,cCodMemo,;
						cObsMemo	,oObsMemo	,cCodEnce	,cEnceMemo,;
						oEnceMemo	,cCodCanc	,cCancMemo	,oCancMemo)

Local aFirst[1][Len(aHeader)+1]

aCols := aClone(aFirst)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o acols com os itens da ligacao selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkMontaItens("SUD",cCodLig,"M")

oGetHist:oBrowse:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego a observa‡„o da liga‡„o 							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cObsMemo:= ""
cObsMemo:= MSMM(cCodMemo,TamSx3("UC_OBS")[1])
oObsMemo:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a consulta for de todas as ligacoes                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTodas                                                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o motivo do encerramento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEnceMemo:= ""
	cEnceMemo:= MSMM(cCodEnce,TamSx3("UC_OBSMOT")[1])
	oEnceMemo:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o motivo do cancelamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCancMemo:= ""
	cCancMemo:= MSMM(cCodCanc,TamSx3("UC_OBSCANC")[1])
	oCancMemo:Refresh()
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271EvaTmk ³Autor  ³Vendas Clientes      ³ Data ³ 06/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a validade da linha digitada na GetDados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³TeleMarketing 								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk272EvaTmk()                  

Local lRet			:= .T.							//Retorno da funcao
Local aArea		:= GetArea()					//Armazena o posicionamento atual
Local aAreaSUC	:= SUC->(GetArea())
Local aAreaSU7	:= SU7->(GetArea())			//Armazena o posicionamento do cadastro de operadores
Local aAreaSUD	:= {}
Local aAreaSUQ	:= {}
Local lTmkLinOk	:= ExistBlock("TMKLINOK")  		//P.E. para TMK
Local nPAssunto	:= aPosicoes[1][2]				//Posicao do campo UD_ASSUNTO no ACOLS
Local nPCodOpe 	:= aPosicoes[7][2]				// Codigo do Operador
Local nPStAcao	:= aScan(aHeader, {|x| AllTrim(x[2]) == "UD_STATUS"})
Local nPAcao		:= aScan(aHeader, {|x| AllTrim(x[2]) == "UD_SOLUCAO"})
Local nPNSerie	:= aScan(aHeader, {|x| AllTrim(x[2]) == "UD_NSERIE"})
Local nPProd		:= aScan(aHeader, {|x| AllTrim(x[2]) == "UD_PRODUTO"})
Local nPosStat	:= aPosicoes[13][02]
Local cFilSUC		:= xFilial("SUC")
Local cFilSUQ		:= xFilial("SUQ")
Local cNwAcXOprt	:= ""
Local aRet			:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a linha nao esta apagada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPAssunto])
		Help(" ",1,"TMKTLVVAZ")
		lRet := .F.
	Endif
	If TK272GerCT( aCols[n][nPAcao] ) .And. nPNSerie > 0
		aRet := TK272ValBase( aCols[n][nPProd], aCols[n][nPNSerie] )
		lRet := aRet[1]
		If lRet
			aCols[n][nPNSerie] := aRet[2]
		EndIf
	EndIf
Endif

// Verifica se o registro atual da grid já está gravado na base de dados, consiste a configuração da geração da Oportunidade das Ações (Base x Tela)  
If lRet .AND. aCols[n][Len(aHeader)] > 0
	aAreaSUQ		:= SUQ->(GetArea())
	aAreaSUD		:= SUD->(GetArea())
	cNwAcXOprt		:= AllTrim(Posicione("SUQ", 1, cFilSUQ + aCols[n][nPAcao], "UQ_OPORTU"))
	SUD->(DbGoTo(aCols[n][Len(aHeader)]))
	SUQ->(DbSeek(cFilSUQ + SUD->UD_SOLUCAO))
	If Alltrim(SUQ->UQ_OPORTU) == "1"	// Se a Ação já gravada gera uma Oportunidade...
		If	AllTrim(cNwAcXOprt) <> '1'	// Se a nova Ação digitada NÃO for gerar uma Oportunidade...
			Help("",1,"Tk272EvaTmk",,STR0083,1,0,,,,,,{STR0084}) //##"A Ação da Ocorrência anterior está configurada para gerar uma Oportunidade."##"Não é possível a alteração de dados que influenciem na troca da Ação."
			lRet := .F.
		ElseIf Alltrim(SUD->UD_STATUS) == "2" .AND. aCols[n][nPStAcao] == "1"
			Help("",1,"Tk272EvaTmk",,STR0085,1,0,,,,,,{STR0086}) //##"A Ação da Ocorrência anterior encontra-se encerrada, e está configurada para gerar uma Oportunidade."##"Não é possível reabrir esta Ação."
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaSUD)
	RestArea(aAreaSUQ)
EndIf

DbSelectArea("SUQ")
DbSetOrder(1)//UQ_FILIAL+UQ_SOLUCAO
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a acao atual gera uma OS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. Len(aPosicoes) >= 17 .AND. (aPosicoes[17][2] > 0)
	nPNSerie := aPosicoes[17][2]
	If DbSeek(cFilSUQ+aCols[n][nPAcao]) .AND. (SUQ->UQ_GERAOS == "1") .AND. Empty(aCols[n][nPNSerie])
		lRet := .F.
		Help("",1,"TMKNSERIE")
	EndIf
EndIf

If lRet .AND. aCols[N][nPosStat] == "2" .AND. SIX->(DbSeek("SUC8"))
	SUC->(DbSetOrder(8)) //UC_FILIAL+UC_CHAORIG+UC_ITCHAOR
	If SUC->(DbSeek(cFilSUC+M->UC_CODIGO+StrZero(N,2)))
		While lRet .AND. SUC->(! Eof()) .AND. SUC->UC_FILIAL == cFilSUC .AND. SUC->UC_CHAORIG == M->UC_CODIGO .AND. SUC->UC_ITCHAOR == StrZero(N,2)
			If Val(SUC->UC_STATUS) != ENCERRADA .AND. SUC->UC_CODIGO <> M->UC_CODIGO
				lRet := .F.
				EXIT
			EndIf
			SUC->(DbSkip())
		EndDo
		If !lRet
			Help("",1,"TMKCMP01")
			aCols[N][nPosStat] := "1"
		EndIf
	EndIf
	RestArea(aAreaSUC)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Veririca se o chamado ou o item esta encerrado quando for utilizada uma acao³
//³que gere compartilhamento de chamado                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. !Empty(aCols[N][nPAcao]) .AND. SUQ->(DbSeek(cFilSUQ + aCols[N][nPAcao] ))
	If SUQ->UQ_COMPART $ "1/3"
		SUC->(DbSetOrder(8))
		If (aCols[n][nPosStat] == "2" .OR. M->UC_STATUS == "3") .AND. !SUC->(DbSeek(cFilSUC+M->UC_CODIGO+StrZero(N,2)))
			lRet := .F.
			Help("",1,"TMKCMP02")
		EndIf
		If Empty(aCols[n][nPCodOpe])
			lRet := .F.
			Help("",1,"TMKCMP03")
		Else
			SU7->(DbSetOrder(4)) //U7_FILIAL+U7_CODUSU
			If !SU7->(DbSeek( xFilial("SU7") + aCols[n][nPCodOpe] ))
				lRet := .F.
				Help("",1,"TMKCMP04")
			EndIf
		EndIf
		RestArea(aAreaSUC)
	EndIf
EndIf

lRet := lRet .AND. TK271ValEv("1")		//Funcao para validar a linha (Evento / Grade)

If lRet
	If lTmkLinOk
		lRet:= ExecBlock( "TMKLINOK", .F., .F. )
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ir para final de arquivo para garantir que o memo que  |
//|quando for uma inclusao de linha de item o memo estara |
//|inicializado.                                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SUD->(! Eof())
	SUD->(dbGoto(0))
EndIf

RestArea(aAreaSU7)
RestArea(aAreaSUC)
RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271GetTmk ³ Autor ³Vendas Clientes      ³ Data ³ 06/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida‡„o Geral da GetDados do Telemarketing	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³TeleMarketing 								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk272GetTmk()

Local nLinha 	:= 1					//Contador das linhas do ACOLS
Local nPProd 	:= aScan( aHeader, { |x| AllTrim(x[2]) == "UD_PRODUTO" } )
Local lRet 	 	:= .T.					//Retorno da funcao
Local nPNSerie	:= aScan( aHeader, { |x| AllTrim(x[2]) == "UD_NSERIE" } )
Local nPAcao	:= aScan( aHeader, { |x| AllTrim(x[2]) == "UD_SOLUCAO" } )
Local lDeletadas:= .T.

If Tk272EvaTmk()
	For nLinha := 1 To Len(aCols)
		If !aCols[nLinha][Len(aHeader)+1]
			lDeletadas:= .F.
		EndIf
	Next nLinha
	
	If !lDeletadas	
		For nLinha := 1 To Len(aCols)
			If !aCols[nLinha][Len(aHeader)+1]
				If TK272GerCT( aCols[nLinha][nPAcao] )	.And. nPNSerie > 0
				If Empty(aCols[nLinha][nPProd]) .AND. nLinha > 1
		   			Help(" ",1,"FALTA_PROD")
					lRet := .F.
				Endif
					aRet := TK272ValBase( aCols[nLinha][nPProd], aCols[nLinha][nPNSerie] )
					lRet := aRet[1]
					
					If lRet
						aCols[nLinha][nPNSerie] := aRet[2]
					EndIf
				EndIf
			Endif
		Next nLinha
	Else
		Help(" ",1,"TMKTLVVAZ")
		lRet := .F.
	EndIf
	If lRet
		lRet := If(!TK271ValEv("2"),.F.,lRet)
	Endif

Else
	
	lRet := .F.

EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271DelTmk ³ Autor ³ Vendas Clientes     ³ Data ³ 22/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o usuario esta deletando uma liga‡„o encerrada  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³TeleMarketing 								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk272DelTmk(nOpc)

Local lRet		:= .T.					//Retorno da funcao
Local aArea		:= GetArea()
Local aAreaSUC	:= SUC->(GetArea())
Local lTmkVlDel := ExistBlock("TMKVLDEL")

If nOpc != 3  // Se a operacao nao for de INCLUSAO

	DbSelectarea("SUC")
	DbSetorder(1)
	If DbSeek(xFilial("SUC")+M->UC_CODIGO)
		If !Empty(SUC->UC_CODCANC)
			Help(" ",1,"CANCELADA")
			lRet := .F.
		Endif
		
		If !Empty(SUC->UC_CODENCE)
			Help(" ",1,"ENCERRADA")
			lRet := .F.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario foi alterado em um item compartilhado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. SIX->(DbSeek("SUC8"))
		SUC->(DbSetOrder(8))
		If SUC->(DbSeek(xFilial("SUC") + M->UC_CODIGO + StrZero(N,2) ))
			lRet := .F.
			Help("",1,"TMKCMP07")
		EndIf
	EndIf
	
Endif

If lRet .And. lTmkVlDel
	lRet := ExecBlock("TMKVLDEL",.F.,.F.,{nOpc})	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inverte o Status de linha deletada se o usuario nao pode apaga-la ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet
	aCols[n][Len(aHeader)+1] := .F.
	oGetTmk:oBrowse:Refresh(.T.)
Endif

RestArea(aAreaSUC)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk271CancTmKºAutor³Vendas Clientes     º Data ³  03/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Executa a Rotina de Cancelameto do atendimento Telemarketingº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Uso  	 ³TeleMarketing 								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  Tk272CancTmk(	nOpc		,oCrono			,cCrono			,nTimeSeg,;
						nTimeMin	,oFolderTmk		,oEnchTmk		,oFolderTlv,;
						oEnchTlv	,cCodPagto		,cDescPagto		,cCodTransp,;
						cTransp		,cCob			,cEnt			,cCidadeC,;
						cCepC		,cUfC			,cBairroE		,cBairroC,;
						cCidadeE	,cCepE			,cUfE			,nLiquido,;
						nTxJuros	,nTxDescon		,nVlJur			,aParcelas,;
						nEntrada	,nFinanciado	,nNumParcelas	,nValorCC,;
						lHabilita	,cMotivo		,cEncerra		,oFolderTlc,;
						oEnchTlc)

Local oDlgMCan											//Tela
Local oObs    											//MEMO para descricao do cancelamento
Local cObs    := ""										//String com a descricao
Local oMonoAs := TFont():New( "Courier New", 6, 0 )		//Fonte do objeto	
Local nOpca	  := 0										//Opcao de escolha OK ou CANCELA	
Local lCancela:= .F.									//Flag para autorizar o cancelamento

DbSelectarea("SUC")
DbSetorder(1)
If DbSeek(xFilial("SUC") + M->UC_CODIGO)
	
	If !Empty(SUC->UC_CODENCE)
		Help(" ",1,"ENCERRADA")
		Return(lCancela)
	Endif
	
	If !Empty(SUC->UC_CODCANC)
	
		DEFINE MSDIALOG oDlgMCan FROM 05,10 TO 170,270 TITLE STR0026 PIXEL //"Motivo de Cancelamento"
		
			cObs := MSMM(SUC->UC_CODCANC,TamSx3("UC_OBSCANC")[1])
			
			@03,04 TO 62,128 LABEL STR0027 OF oDlgMCan PIXEL //"Motivo informado"
			@12,08 GET oObs VAR cObs OF oDlgMCan MEMO size 113,45 PIXEL READONLY
		
			oObs:oFont := oMonoAs
			DEFINE SBUTTON FROM 65,100 TYPE 1 ENABLE ACTION oDlgMCan:End()
		
		ACTIVATE MSDIALOG oDlgMCan CENTER

	Else
	
		If TmkOK(STR0028) //"Confirma Cancelamento ?"
			
			DEFINE MSDIALOG oDlgMCan FROM 05,10 TO 170,270 TITLE STR0026 PIXEL  //"Motivo de Cancelamento"
			
				cObs := MSMM(SUC->UC_CODCANC,TamSx3("UC_OBSCANC")[1])
				
				@03,04 TO 62,128 LABEL STR0029 OF oDlgMCan PIXEL //"Digite o Motivo"
				@12,08 GET oObs VAR cObs OF oDlgMCan MEMO SIZE 113,45 PIXEL Valid !Empty(cObs)
			
				oObs:oFont := oMonoAs
			
				DEFINE SBUTTON FROM 65,100  TYPE 1 ACTION (nOpca:=1,oDlgMCan:End()) ENABLE OF oDlgMCan
			
			ACTIVATE MSDIALOG oDlgMCan CENTER
			
			If nOpca == 1
				lCancela:= .T.
				RecLock("SUC",.F.)
				MSMM(,TamSx3("UC_OBSCANC")[1],,cObs,1,,,"SUC","UC_CODCANC")
				MsUnlock()
			Endif
		Endif
	Endif
Endif

Return(lCancela)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Encerra ³ Autor ³ Vendas Clientes    ³ Data ³29/07/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tela  para consultar ou informar o Motivo de Encerramento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³CALL CENTER   								              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Indica se sera consulta ou inclusao de encerramento  ³±±
±±³          ³ExpC2: Codigo do Atendimento                                ³±±
±±³          ³ExpC3: Codigo do Encerramento                               ³±±
±±³          ³ExpC4: Descricao do Motivo do Encerramento                  ³±±
±±³          ³ExpC5: Rotina a ser utilizada na consulta 1- TMK ou 3- TLC  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272Encerra(	lConsulta,	cNumAtend,	cEncerra,	cMotivo,;
						cRotina )

Local oEncerra											// Listbox com as opcoes de Encerramento
Local cDesc     := CriaVar("UN_DESC",.F.)				// Descricao da opcao de Encerramento
Local oDlg								   				// Tela do Encerramento
Local oMonoAs	:= TFont():New( "Courier New", 6, 0)	// Fonte do MEMO
Local oMotivo											// MEMO com o motivo 	
Local lHabil	:= .F.									// Habilita os objetos
Local lRet		:= .F.									// Retorno da funcao
Local cCodEnc 	:= CriaVar("UN_ENCERR",.F.)				// Codigo do encerramento
Local aArea		:= GetArea()							// Salva a area atual
Local lTkEncerr := ExistBlock("TKENCERR")				// Ponto de Entrada para automatizar informacoes encerramento. 

lHabil 	:= IIF(lConsulta,.F.,.T.)
cMotivo := ""

If lConsulta
	Do Case
		Case cRotina == "1"
			DbSelectarea("SUC")
			DbSetorder(1)
			If DbSeek(xFilial("SUC") + cNumAtend)
				If !Empty(SUC->UC_CODENCE) .OR. !Empty(SUC->UC_CODMOT)
					cCodEnc := SUC->UC_CODENCE
					cDesc   := Posicione("SUN",1,xFilial("SUN") + SUC->UC_CODENCE,"UN_DESC")
					cMotivo := MSMM(SUC->UC_CODMOT,TamSx3("UC_OBSMOT")[1])
				Else
					HELP(" ",1,"NAO ENCERR")
					Return(lRet)
				Endif
			Endif
	    Case cRotina == "3"
			DbSelectarea("ACF") 
			DbSetorder(1)
			If DbSeek(xFilial("ACF") + cNumAtend)
				If !Empty(ACF->ACF_CODENC) .OR. !Empty(ACF->ACF_CODMOT)
					cCodEnc := ACF->ACF_CODENC
					cDesc   := Posicione("SUN",1,xFilial("SUN") + ACF->ACF_CODENC,"UN_DESC")
					cMotivo := MSMM(ACF->ACF_CODMOT,TamSx3("ACF_OBSMOT")[1])
				Else
					HELP(" ",1,"NAO ENCERR")
					Return(lRet)
				Endif
			Endif
    EndCase	
Endif

If lTkEncerr
	cCodEnc := ExecBlock("TKENCERR",.F.,.F.,{cCodEnc})	   
EndIf 

If !lTk271Auto
	If AllTrim(FunName()) == "TMKA271"
		//Desabilita o "X" (fechar) da janela do status de encerramento
		DEFINE MSDIALOG oDlg FROM 05,10 TO 262,520 TITLE STR0030 PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )	//"Status de Encerramento" 
		// Desabilita a tecla ESC
	    oDlg:LESCCLOSE := .F.
	Else
		DEFINE MSDIALOG oDlg FROM 05,10 TO 262,520 TITLE STR0030 PIXEL 	//"Status de Encerramento" 
	EndIf
	
		@  2,4 TO 23,257 LABEL STR0031 OF oDlg PIXEL  //"Motivo do Encerramento" 
	
		@ 10,07 SAY STR0032 SIZE  50,8 OF oDlg PIXEL //"Encerramento"
		@ 09,45 MSGET oEncerra VAR cCodEnc SIZE  40,8  PICTURE "@!" OF oDlg PIXEL F3 "SUN" ;
				VALID Tk272ValSUN(cCodEnc,@cDesc) WHEN lHabil
		oEncerra:cSX1Hlp := "UN_ENCERR"			
	
		@ 10,90 SAY cDesc SIZE 180,8 OF oDlg PIXEL
		
		@ 26,4 TO 111,252 LABEL STR0033 OF oDlg PIXEL //"Descri‡ao do Encerramento" 
		If lConsulta
			@ 35,8 GET oMotivo VAR cMotivo OF oDlg MEMO SIZE 240,70 PIXEL READONLY
		Else
			@ 35,8 GET oMotivo VAR cMotivo OF oDlg MEMO SIZE 240,70 PIXEL When lHabil
		Endif
		oMotivo:oFont := oMonoAs
		
		DEFINE SBUTTON FROM 115,220 TYPE 1 ACTION (lRet:=.T., oDlg:End()) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTER
	
	cEncerra:= cCodEnc
	oMonoas:End()
Else
	If Len( aAutoCab ) > 0
		If Ascan(aAutoCab, {|x| x[1] == "UC_CODENCE"} ) > 0
			cEncerra := aAutoCab[Ascan(aAutoCab, {|x| x[1] == "UC_CODENCE"} )][2]
			lRet := .T.
		Else
			SUN->( DbSetOrder(1) )
			If DbSeek(xFilial("SUN")) .AND. !SUN->(eof())
				cEncerra := SUN->UN_ENCERR
				lRet := .T.
			Endif
		Endif
	Endif
Endif

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk272ValSUN ºAutor  ³Vendas Clientes     º Data ³  16/03/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Valida o codigo do encerramento informado de acordo com o   º±±
±±º          ³codigo e o tipo de atendimento:                             º±±
±±º          ³1- Telemarketing, 3 - Telecobranca, 4 - Ambos               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEMARKETING                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk272ValSUN(cCodEnc,cDesc)

Local lRet := .F.       	// Retorno da funcao
Local aArea:= GetArea()		// Salva a area atual

cDesc := ""
DbSelectarea("SUN")
DbSetorder(1)                                                       	
If DbSeek(xFilial("SUN")+cCodEnc)
	If (SUN->UN_TIPOATE $ "1;4; ")		//Telemarketing e Ambos
		cDesc 	:= SUN->UN_DESC
		lRet 	:= .T.
	Else
		Help(" ",1,"TMK272ENC" ) //"Esse código de encerramento nao é usado para a rotina de Telemarketing"		
		lRet 	:= .F.
	Endif		
Else
	Help(" ",1,"TMK272ENC" ) //"Esse código de encerramento nao é usado para a rotina de Telemarketing"		
	lRet := .F.	
Endif

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271NumTmk ³ Autor ³Vendas Clientes      ³ Data ³ 02/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os dados do atendimento de acordo com o codigo      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³TeleMarketing 								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk272NumTmk(	nOpc,		cNumTmk,	lHabilita,	oFolderTmk,;
						oEnchTmk,	cMotivo,	cEncerra ,	cLock	 )

Local lTMKENT	:= ExistBlock("TMKENT")				// P.E. para TMK
Local cNumAux 	:= ""								// Variavel auxiliar
Local cCampo    := ""								// Campo
Local cDescEnt	:= ""								// Nome da Entidade. Ex:Cadastro de Clientes

Default cLock := ""

CursorWait()

If lTMKENT
	U_TMKENT(cNumTmk)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Existe a liga‡„o preencho a tela com os dados da liga‡„o ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea( "SUC" )
DbSetorder(1)
If DbSeek(xFilial("SUC") + cNumTmk)    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a rotina estava incluindo e agora passou a ser uma alteracao solta o SXE ³
	//³Atualiza o status dos semaforos para evitar o empilhamento do ultimo folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se foi usado o SX8 e nao foi feita nenhuma inclusao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TkGetTipoAte() == "4"// todos os atendimentos
			DbSelectArea("ACF")
			RollBackSX8() // rollback do ultimo folder
				
			DbSelectArea("SUA")
			RollBackSX8() // rollback do primeiro folder.
				
			DbSelectArea("SUC")
			RollBackSX8() // rollback do penultimo folder
		        
        ElseIf TkGetTipoAte() == "1"  //TMK
			DbSelectArea("SUC")
			RollBackSX8() 
		Endif	
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a liga‡„o estiver CANCELADA/ENCERRADA n„o ‚ possivel alterar ³
	//³nenhuma informa‡„o apenas consultar                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(SUC->UC_CODCANC)
		Help(" ",1,"CANCELADA")
		Tk271HabObj(.F.,@lHabilita,@oEnchTmk)
		
		// Verifica o campo de encerramento e o MEMO (devido a conversao de Suspect para Prospect)
	Elseif ! Empty(SUC->UC_CODENCE) .OR. !Empty(SUC->UC_CODMOT)  
		Help(" ",1,"ENCERRADA")
		Tk271HabObj(.F.,@lHabilita,@oEnchTmk)
	ElseIf nOpc == 2 .And. Empty(cLock) .And. !lHabilita
		Tk271HabObj(.F.,@lHabilita,@oEnchTmk)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for uma ligacao normal habilita os objetos da tela - caso a consulta anteiror tenha desabilitado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    Tk271HabObj(.T.,@lHabilita,@oEnchTmk)
	Endif

	nOpc   := 4   // Alteracao
	Inclui := .F.
		
	cDescEnt := ALLTRIM(Posicione("SX2",1,SUC->UC_ENTIDAD,"X2NOME()"))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a enchoice de Telemarketing.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SUC")
	While ( !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == "SUC")
		If X3USO(SX3->X3_USADO)
			cCampo := ALLTRIM(SX3->X3_CAMPO)
			If (X3_CONTEXT # "V")
				M->&(cCampo) := SUC->&(cCampo)
			ElseIf (X3_CONTEXT == "V")
				M->&(cCampo) :=  CriaVar(cCampo)
			Endif
			If cCampo == "UC_DESCENT"
			    M->&(cCampo) := cDescEnt
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizar os campos UC_ENTIDAD e UC_CHAVE da enchoice.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ALLTRIM(SX3->X3_CAMPO) == "UC_ENTIDAD" .OR.  ALLTRIM(SX3->X3_CAMPO) == "UC_CHAVE"
				M->&(SX3->X3_CAMPO) := SUC->&(SX3->X3_CAMPO)	
			Endif	
		Endif
		
		DbSkip()
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡ao da GetDados - Folder 01			     ³
	//³ *** Telemarketing                       			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK271Config("SUD","UD_CODIGO",nOpc,cNumTmk,,)
	
	aHeader  := {}
	aCols    := {}
	aHeader  := aClone(aSvFolder[1][1])
	aCols    := aClone(aSvFolder[1][2])
	n		 := aSvFolder[1][3]

	If AllTrim(SUC->UC_STATUS) == "3" .Or. oGetTmk:nOpc == 2
		oGetTmk:nOpc			:= 2
		oGetTmk:oBrowse:nOpc	:= 2
	Else
		oGetTmk:nOpc			:= nOpc
		oGetTmk:oBrowse:nOpc	:= nOpc
	EndIf
	
	oGetTmk:oBrowse:Refresh()
	oEnchTmk:Refresh()
Else
	cNumAux      := GetSxeNum("SUC","UC_CODIGO")
	M->UC_CODIGO := cNumAux
	RollBackSxe()
	
	If cNumTmk > cNumAux
		Help( " ",1,"FORA_SEQ")
	Endif
Endif

CursorArrow()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK272HSUC     ºAutor  ³Vendas Clientes º Data ³  22/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da hora de retorno                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TELEMARKETING                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK272HSUC()

Local cHora := &( ReadVar() )
Local lRet	:= .F.

If cHora <> "  :  "
	If (M->UC_PENDENT == M->UC_DATA)
		If cHora >= Time()
			lRet := .T.
		Endif
	ElseIf (M->UC_PENDENT > M->UC_DATA)
		If (cHora >= "00:00") .AND. (cHora <= "24:00")
			lRet := .T.
		Endif		
	Endif	
Else
	lRet := .T.
Endif           
                                                                          
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TK272GAcao   ³ Autor ³ Vendas CRM         ³ Data ³25/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função executada pelo gatilho da ação.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³CALL CENTER   								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK272GAcao()
	Local aArea				:= GetArea()
	Local aBasesInstaladas	:= {}
	Local cChave			:= ""
	Local cNumSerieEscolhido:= ""
	Local nPosNSerie		:= aScan( aHeader, { |x| AllTrim(x[2]) == AllTrim("UD_NSERIE") } )	
	Local nPosProduto		:= aScan( aHeader, { |x| AllTrim(x[2]) == AllTrim("UD_PRODUTO") } )
	Local lTK272CBI			:= ExistBlock("TK272CBI")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Só há a relação de base instalada quando a entidade selecionada³
	//³é um cliente.                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(M->UC_ENTIDADE) == AllTrim("SA1") .And. nPosNSerie > 0 .And. nPosProduto > 0
		DbSelectArea( "AA3" )
		DbSetOrder( 1 )
		
		cChave := xFilial( "AA3" ) + SubStr( M->UC_CHAVE, 1, TamSX3("A1_COD")[1] ) + SubStr( M->UC_CHAVE, TamSX3("A1_COD")[1] + 1, TamSX3("A1_LOJA")[1] ) + aCols[N][nPosProduto]
		
		If AA3->(DbSeek( cChave , .T. ))
			While AA3->(!EOF()) .And. cChave == AA3->AA3_FILIAL + AA3->AA3_CODCLI + AA3->AA3_LOJA + AA3->AA3_CODPRO
				aAdd( aBasesInstaladas, AllTrim(AA3->AA3_NUMSER) )
				AA3->(DbSkip())
			End
		EndIf
		
		If Len(aBasesInstaladas) == 0 
			If !Empty(aCols[N][nPosNSerie])
				cNumSerieEscolhido := TK272IncBase( aCols[N][nPosProduto], aCols[N][nPosNSerie] ) 
			Else
				If lTK272CBI 
					cNumSerieEscolhido := ExecBlock( "TK272CBI", .F., .F. )				
				Else    					
					AxInclui( "AA3", , 3 )
				EndIf
			EndIf
		ElseIf Len(aBasesInstaladas) >= 1
			If !Empty(aCols[N][nPosNSerie])
				If aScan( aBasesInstaladas, { |x| AllTrim(x) == AllTrim(aCols[N][nPosNSerie]) } ) > 0
					cNumSerieEscolhido := aCols[N][nPosNSerie]
				Else
					cNumSerieEscolhido := TK272IncBase( aCols[N][nPosProduto],aCols[N][nPosNSerie] )
				EndIf
			Else			
				cNumSerieEscolhido := TK272SelBase( AllTrim(aCols[N][nPosProduto]), aBasesInstaladas )
			EndIf
		EndIf
	EndIf
	
	RestArea( aArea )
Return cNumSerieEscolhido

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TK272IncBase ³ Autor ³ Vendas CRM         ³ Data ³25/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria base instalada do produto e número de série informado.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³CALL CENTER   								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK272IncBase( cProduto, cNumeroDeSerie )
	Local lTK272CBI			:= ExistBlock("TK272CBI")
	Local lMV_TMKCBI		:= GetNewPar( "MV_TMKCBI", .T. )	
	Local cNumSerieIncluido	:= ""
	Local aCabAA3			:= {}
	Private lMsErroAuto		:= .F.

	If lTK272CBI
		cNumSerieIncluido := ExecBlock( "TK272CBI", .F., .F. )
	Else
	    If lMV_TMKCBI
	    	If MsgYesNo( STR0038, STR0036 ) // "O número de série informado não está cadastrado para esse produto, deseja cadastrá-lo?" "Atenção!"
	    		aCabAA3	:=	{																											;
	    						{ "AA3_CODCLI"	, SubStr( M->UC_CHAVE, 1, TamSX3("A1_COD")[1] )							, Nil	}	,;
	    						{ "AA3_LOJA"	, SubStr( M->UC_CHAVE, TamSX3("A1_COD")[1] + 1, TamSX3("A1_LOJA")[1] )	, Nil	}	,;
	    						{ "AA3_CODPRO"	, cProduto																	, Nil	}	,;
	    						{ "AA3_NUMSER"	, cNumeroDeSerie															, Nil	}	;
	    					}
	    		TECA040( , aCabAA3, {} , 3 )
	    		
				If !lMsErroAuto
					ConfirmSX8()
					cNumSerieIncluido := cNumeroDeSerie
				Else
					RollBackSx8()
					MostraErro()
				EndIf										    		
	    	EndIf
		Else
			Alert( STR0039 ) // "O número de série informado não existe para esse produto na base instalada. Informe um número de série válido"
			cNumSerieIncluido := ""
		EndIf
	EndIf    
Return cNumSerieIncluido

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TK272SelBase ³ Autor ³ Vendas CRM         ³ Data ³25/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Janela de seleção de base instalada.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³CALL CENTER   								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK272SelBase( cProduto, aNumerosDeSerie )
	Local oDialog	:= Nil
	Local oLstBox	:= Nil
	Local nSelected	:= 0
	Local cNumSerie	:= ""
	Local lSelected	:= .F.
	
	DEFINE MSDIALOG oDialog FROM  50,003 TO 260,500 TITLE STR0040 + Posicione( "SB1", 1, xFilial("SUD") + cProduto, "SB1->B1_DESC" ) + "'" PIXEL  // "Selecione a base instalada do produto '"

	@ 03,10 LISTBOX oLstBox VAR nSelected FIELDS HEADER ;
			STR0041; // "Número de série"
			SIZE 233,80 OF oDialog PIXEL NOSCROLL 
			
	oLstBox:SetArray(aNumerosDeSerie)
    oLstBox:bLine:={||{aNumerosDeSerie[oLstBox:nAt]}}

    oLstBox:BlDblClick := {||(lSelected:= .T.,nSelected := oLstBox:nAt, oDialog:End())}
	oLstBox:Refresh()
	
    DEFINE SBUTTON FROM 88,175 TYPE 1 ENABLE OF oDialog ACTION (lSelected:= .T.,nSelected := oLstBox:nAt, oDialog:End())
    DEFINE SBUTTON FROM 88,210 TYPE 2 ENABLE OF oDialog ACTION (lSelected:= .F.,nSelected := oLstBox:nAt, oDialog:End())

	ACTIVATE MSDIALOG oDialog CENTERED
	
	If lSelected
		If nSelected >= 1 .And. nSelected <= Len(aNumerosDeSerie)
			cNumSerie := aNumerosDeSerie[nSelected]
		EndIf
	EndIf
Return cNumSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TK272ValBase ³ Autor ³ Vendas CRM         ³ Data ³25/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação de produto e número de série.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³CALL CENTER   								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK272ValBase( cProduto, cNumeroDeSerie )
	Local lRet				:= .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o número de série estiver preenchido, verifica se a base instalada existe.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cNumeroDeSerie ) .And. AllTrim(M->UC_ENTIDADE) == AllTrim("SA1")
		DbSelectArea( "AA3" )
		DbSetOrder( 1 )
		If !DbSeek( xFilial( "AA3" ) + SubStr( M->UC_CHAVE, 1, TamSX3("A1_COD")[1] ) + SubStr( M->UC_CHAVE, TamSX3("A1_COD")[1] + 1, TamSX3("A1_LOJA")[1] ) + cProduto + cNumeroDeSerie )
			cNumeroDeSerie := TK272IncBase( cProduto, cNumeroDeSerie )
			If Empty(cNumeroDeSerie)				
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return { lRet, cNumeroDeSerie }


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TK272ValBase ³ Autor ³ Vendas CRM         ³ Data ³25/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação do campo de número de série.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³CALL CENTER   								              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK272NSVal()
	Local nPNSerie	:= aScan( aHeader, { |x| AllTrim(x[2]) == "UD_NSERIE" } )
	Local nPProd	:= aScan( aHeader, { |x| AllTrim(x[2]) == "UD_PRODUTO" } ) 	
Return TK272ValBase( aCols[n][nPProd], aCols[n][nPNSerie] )[1]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk272StSUDºAutor  ³Microsiga           º Data ³  04/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza a legenda da linha de acordo com o status selecio- º±±
±±º          ³nado.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk272StSUD(lChgLine)

Local cStatus	:= ""  
Local aArea		:= GetArea()
Local aAreaSUC	:= SUC->(GetArea())
Local lRet 		:= .T.
Local oVerde	:= LoaDbitmap(GetResources(),"BR_VERDE")	
Local oVerm		:= LoaDbitmap(GetResources(),"BR_VERMELHO")	
Local nPosStat  := aPosicoes[13][02]
Local nPosCHK	:= Ascan(aHeader,{|x|AllTrim(x[2]) == "CHECKBOX"})
Local nPAcao   	:= aPosicoes[10][02]	//Acao
Local lTmkChgLi := ExistBlock("TMKCHGLI")

Default lChgLine := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario foi alterado em um item compartilhado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lChgLine .AND. SIX->(DbSeek("SUC8"))
	SUC->(DbSetOrder(8))
	If SUC->(DbSeek(xFilial("SUC") + M->UC_CODIGO + StrZero(N,2) ))
		lRet := .F.
		Help("",1,"TMKCMP06")
	EndIf
EndIf

If lRet

	If lChgLine
		cStatus := aCols[N][nPosStat]
	Else 
		lRet 	:= Pertence("12")
		cStatus	:= &(ReadVar())
	EndIf
	
	SUQ->(DbSetOrder(1))//UQ_FILIAL+UQ_SOLUCAO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O status do item que gera OS nao podera ser alterado pelo usuario.³
	//³A alteracao do status ocorrera automaticamente ao encerrar a OS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	cStatus == "2" .AND. !Empty(aCols[N][nPAcao]) .AND.;
		SUQ->(DbSeek(xFilial("SUQ") + aCols[N][nPAcao] )) .AND.;
		SUQ->UQ_GERAOS == "1"
		
		lRet := .F.	
		Help(" ",1,"TMKSTAOS")
		
	EndIf
	
	If lRet
		If !Empty(cStatus) .AND. cStatus == "2"
			aCols[N][nPosCHK] := oVerde
		Else
			aCols[N][nPosCHK] := oVerm
		EndIf
	EndIf
	
	If Type("oGetTmk") == "O"
		oGetTmk:oBrowse:Refresh()
	EndIf
	
EndIf

If lRet .And. lChgLine .And. lTmkChgLi
	ExecBlock("TMKCHGLI",.F.,.F.)	
EndIf

RestArea(aAreaSUC)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK272WizrdºAutor  ³Vendas CRM          º Data ³  18/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Wizard do Telemarketing acionado através da consulta TMK020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA272                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK272Wizrd()

Local lRet := .T.

If Upper(FunName()) == "TMKA271"
	//Excuta o assistente wizard do atendimento do Telemarketing se a consulta padrão for executada através do Call Center
	lRet := TK272TmkWzd()
Else
	lRet := Conpad1(NIL,NIL,NIL,"T1",NIL,.F.,.F.,)
EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TK272TmkWzd
Wizard para registro de item no atendimento Telemarketing

@Return lRet

@author Squad CRM
@since 18/01/2011
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function TK272TmkWzd()

Local oWizard	:= Nil
Local oPanel	:= Nil
Local oAssunto	:= Nil
Local oOcorren	:= Nil
Local oAcao		:= Nil
Local oFolder	:= Nil
Local oPesq		:= Nil
Local oPeriodo	:= Nil
Local oDetalhe	:= Nil
Local oResp		:= Nil
Local oNomResp	:= Nil
Local oLbx		:= Nil
Local oOk		:= NIL
Local oNo		:= NIL

Local cAssunto	:= ""
Local cOcorren	:= ""
Local cAcao		:= ""
Local cPeriodo	:= ""
Local cProdSB1	:= Space(TamSX3("B1_COD")[1])
Local cPesqB1	:= Space(50)
Local cCliente	:= ""
Local cLoja		:= ""
Local cGrupo	:= ""
Local cDetalhe	:= ""
Local cNomResp	:= ""
Local cResp		:= Space(6)
Local cOrig		:= ""
Local cVenda	:= ""
Local cItVenda	:= ""

Local aAssunto	:= {{""},{""}}
Local aOcorren	:= {{},{}}
Local aAcao		:= {{},{}} 
Local aPeriodo	:= {STR0042, STR0043, STR0044, STR0045, STR0081, STR0082} //"1 Mês"###"3 Meses"###"6 Meses"###"1 Ano"###"2 Anos"###"3 Anos"
Local aProds	:= {{.F.,,,,,,,,}}

Local nTamCli	:= TamSX3("A1_COD")[1]
Local nTamLoj	:= TamSX3("A1_LOJA")[1]
Local nPosResp	:= aPosicoes[07][02]	//Responsavel
Local nPosDResp	:= aPosicoes[08][02]	//Descricao do Responsavel
Local nPAssunto := aPosicoes[01][02]	//Assunto
Local nPOcorren	:= aPosicoes[05][02]	//Ocorrencia
Local nPAcao   	:= aPosicoes[10][02]	//Acao
Local nPProd 	:= aPosicoes[03][02]	//Produto
Local nPObsMemo	:= aPosicoes[15][02]	//Memo Observacao
Local nX		:= 0					//Auxiliar de loop e buscas

Local lRet		:= .T.  
Local lFinish	:= .F.
Local lCliente	:= AllTrim(M->UC_ENTIDADE) == "SA1" 
Local lTk272Wzd	:= ExistBlock("TK272WZD")
Local lProdObg	:= X3Obrigat("UD_PRODUTO")

cGrupo := GetAdvFVal("SU7","U7_POSTO",xFilial("SU7")+TkOperador(),1,"")

DbSelectArea("SU0")
DbSetOrder(1)
DbSeek(xFilial("SU0")+cGrupo)

If SU0->U0_TMKWIZ == "1"
	
	//Carrega assuntos	
	DbSelectArea("SX5")
	DbSetOrder(1)
		
	DbSelectArea("SKK")     
	DbSetOrder(1)
	DbSeek(xFilial("SKK") + cGrupo)
	
	While !Eof() .AND. SKK->KK_FILIAL == xFilial("SKK") .AND.;
		SKK->KK_CODSU0 == cGrupo
		SX5->(DbSeek(xFilial("SX5")+"T1"+SKK->KK_CODSKQ))
        
		AAdd( aAssunto[1], X5Descri() )
		AAdd( aAssunto[2], SX5->X5_CHAVE )
		SKK->(DbSkip())
	End
                         
    cCliente := SubStr(M->UC_CHAVE,1,nTamCli)
    cLoja	 := SubStr(M->UC_CHAVE,nTamCli+1,nTamLoj)
 
	oOk := LoadBitMap(GetResources(), "LBOK")
	oNo := LoadBitMap(GetResources(), "LBNO")

	DEFINE WIZARD oWizard TITLE STR0046; //"Registrar item"
	    HEADER STR0047 ; //"Registro de novo item do atendimento"
	    MESSAGE STR0048	 ; //"Etapa 1 de 3" 
	    NEXT {|| Iif(Empty(cAssunto),(MsgInfo(STR0049),.F.),.T.)} ; //"Selecione um assunto"
	 	PANEL;
	 	NOFIRSTPANEL

	oPanel := oWizard:GetPanel(1)
		                        
	@ 05,05 TO 133,283 LABEL "" OF oPanel PIXEL

	@ 17,13 SAY STR0050 OF oPanel PIXEL SIZE 50,9 //"Assunto"
	@ 15,55 COMBOBOX oAssunto VAR cAssunto ITEMS aAssunto[1] OF oPanel SIZE 120,10 PIXEL ON CHANGE (Tk272LAss(oAssunto,oOCorren,aAssunto,@aOcorren),oAcao:SetItems({}))
	        
	@ 37,13 SAY STR0006 OF oPanel PIXEL SIZE 50,9 //"Ocorrência"
	@ 35,55 COMBOBOX oOcorren VAR cOcorren ITEMS aOcorren[1] OF oPanel SIZE 120,10 PIXEL ON CHANGE Tk272LOco(oOcorren,oAcao,aOcorren,@aAcao)

	@ 57,13 SAY STR0002 OF oPanel PIXEL SIZE 50,9 //"Ação"
	@ 55,55 COMBOBOX oAcao VAR cAcao ITEMS aAcao[1] OF oPanel SIZE 120,10 PIXEL //VALID .T.

	//Considera assunto inicializada
	If !Empty(aCols[N][nPAssunto])
		nX := aScan(aAssunto[2],aCols[N][nPAssunto])
		If nX > 0
			oAssunto:Select(nX)
			cAssunto := aAssunto[1][nX]   
		EndIf
	EndIf
	
	//Considera ocorrencia inicializada
	If !Empty(aCols[N][nPOcorren])
		nX := aScan(aOcorren[2],aCols[N][nPOcorren])
		If nX > 0
			oOcorren:Select(nX)
			cOcorren := aOcorren[1][nX]   
		EndIf
	EndIf 
	
	//Considera acao inicializada
	If !Empty(aCols[N][nPAcao])
		nX := aScan(aAcao[2],aCols[N][nPAcao])
		If nX > 0
			oAcao:Select(nX)
			cAcao := aAcao[1][nX]   
		EndIf
	EndIf
	
	//Wizard 2/3
	CREATE PANEL oWizard ;
		HEADER STR0051 ; //"Seleção do produto"
	    MESSAGE STR0052 ; //"Etapa 2 de 3"
		BACK {|| .T. } ;
		NEXT {||lRet := If(lProdObg,(Iif(oFolder:nOption==1,(!Empty(cProdSB1).AND.ExistCpo("SB1",cProdSB1)),( aScan(oLbx:aArray,{|x|x[1]}) > 0 ))),.T.),;
				If(!lRet,(MsgInfo(STR0053),.F.),.T.)  } ; //"Selecione um produto"
		PANEL;
		EXEC {||Iif(lCliente,;
				(aProds := TkLoadProds(cCliente,cLoja,oPeriodo),;
				oLbx:SetArray(aProds),;
				oLbx:bLine := { || {If(aProds[oLbx:nAt,1],oOk,oNo),;
										aProds[oLbx:nAt,2],;
										aProds[oLbx:nAt,3],;
										aProds[oLbx:nAt,4],;
										aProds[oLbx:nAt,5],;
										aProds[oLbx:nAt,6],;
										aProds[oLbx:nAt,7],;
										aProds[oLbx:nAt,8],;
										aProds[oLbx:nAt,9]}},;
				oLbx:Refresh()),.F.)}

	oPanel := oWizard:GetPanel(2)

	@ 00,00 FOLDER oFolder OF oPanel PROMPT STR0054,STR0055 PIXEL SIZE 100,100 //"Cadastro de produtos"###"Adquiridos pelo cliente"
	oFolder:align:= CONTROL_ALIGN_ALLCLIENT
	
	//Se nao for cliente, oculta a aba de pesquisa de produtos adquiridos
	If !lCliente
		oFolder:HidePage(2)
	EndIf
	
	@ 03,05 TO 120,283 LABEL STR0053 OF oFolder:aDialogs[1] PIXEL //"Selecione um produto"
	
	//Considera o produto inicializado
	If !Empty(aCols[N][nPProd])
		cProdSB1 := aCols[N][nPProd]
	EndIf
		
	@ 17,13 SAY STR0056 	OF oFolder:aDialogs[1] PIXEL SIZE 50,9 //"Produto"
	@ 15,55 MsGet cProdSB1	OF oFolder:aDialogs[1] SIZE 90,10 PIXEL VALID (Empty(cProdSB1) .OR. ExistCpo("SB1",cProdSB1)) F3 "SB1"
	
	If lCliente
		
		@ 005,007 MsGet oPesq VAR cPesqB1 OF oFolder:aDialogs[2] SIZE 90,10 PIXEL
	 	@ 005,100 BUTTON STR0057 SIZE 30,12 OF oFolder:aDialogs[2] PIXEL Action(Tk040Busca(@oLBx,cPesqB1,@oPesq,.T.)) //"Pesquisar"
	 	@ 005,135 BUTTON STR0058 SIZE 30,12 OF oFolder:aDialogs[2] PIXEL Action(Tk040Busca(@oLBx,cPesqB1,@oPesq,.F.)) //"Próximo" 
		@ 007,175 SAY STR0059 OF oFolder:aDialogs[2] PIXEL SIZE 70,9 //"Compras no(s) último(s):"
		@ 005,235 COMBOBOX oPeriodo VAR cPeriodo ITEMS aPeriodo OF oFolder:aDialogs[2] SIZE 40,10 PIXEL;
			ON CHANGE (	aProds := TkLoadProds(cCliente,cLoja,oPeriodo),;
						oLbx:SetArray(aProds),;
						oLbx:bLine := { || {If(aProds[oLbx:nAt,1],oOk,oNo),;
											aProds[oLbx:nAt,2],;
											aProds[oLbx:nAt,3],;
											aProds[oLbx:nAt,4],;
											aProds[oLbx:nAt,5],;
											aProds[oLbx:nAt,6],;
											aProds[oLbx:nAt,7],;
											aProds[oLbx:nAt,8],;
											aProds[oLbx:nAt,9]}},;
						oLbx:Refresh())
											
		@ 021,007 LISTBOX oLbx FIELDS;
				HEADER  ""		,;
						STR0060	,; //"Cod. Produto"
						STR0061	,; //"Descrição"
						STR0062	,; //"Dt. Compra"
						STR0063	,; //"Dt. Entrega"
						STR0064	,; //"Pedido/Venda"
						STR0066	,; //"Item"
						"NF/Cupom"	,; //"NF/Cupom"
						STR0065	,; //"Origem"
				SIZE 270,100 OF oFolder:aDialogs[2] PIXEL;
				ON DblClick( aEval(oLbx:aArray,{|x| x[1] := .F.}), oLbx:aArray[oLbx:nAt,1] := .T., oLbx:Refresh() ) 

		oLbx:SetArray(aProds)
		oLbx:bLine := { || {If(aProds[oLbx:nAt,1],oOk,oNo),;
							aProds[oLbx:nAt,2],;
							aProds[oLbx:nAt,3],;
							aProds[oLbx:nAt,4],;
							aProds[oLbx:nAt,5],;
							aProds[oLbx:nAt,6],;
							aProds[oLbx:nAt,7],;
							aProds[oLbx:nAt,8],;
							aProds[oLbx:nAt,9]}}

	EndIf

	//Wizard 3/3
	CREATE PANEL oWizard ;
		HEADER STR0067 ; //"Observações"
	    MESSAGE STR0068 ; //"Etapa 3 de 3"
		BACK {|| .T. } ;
		NEXT {|| .T. } ;
		FINISH {|| Iif(oFolder:nOption==2,(nX:=aScan(oLbx:aArray,{|x|x[1]}),; 
						Iif(nX>0,(	cProdSB1:=oLbx:aArray[nX][2],;
									cOrig	:=oLbx:aArray[nX][9],;
									cVenda	:=oLbx:aArray[nX][6],;
									cItVenda:=oLbx:aArray[nX][7]),;
									.T.)),.T.),;
					lFinish := .T. } ;
		PANEL
	         
	oPanel := oWizard:GetPanel(3)
	
	//Considera os detalhes preenchidos
	If !Empty(aCols[N,nPObsMemo])
		cDetalhe :=  aCols[N,nPObsMemo]
	EndIf
	
	@ 003,005 SAY STR0069 OF oPanel PIXEL SIZE 50,9 //"Detalhes:"
	@ 015,005 GET oDetalhe VAR cDetalhe MULTILINE SIZE 277,95 OF oPanel PIXEL  
    
	//Considera o responsavel identificado
	If !Empty(aCols[N][nPosResp])
		cResp 		:= aCols[N][nPosResp]
		cNomResp	:= aCols[N][nPosDResp]
	EndIf
	
	@ 118,005 SAY STR0070 OF oPanel PIXEL SIZE 50,9 //"Responsável"
	@ 115,045 MSGET oResp 		Var cResp	 OF oPanel SIZE 040,10 PIXEL VALID (Empty(cResp) .OR. UsrExist(cResp)) F3 "US2"
	@ 115,095 MSGET oNomResp 	Var cNomResp OF oPanel SIZE 100,10 PIXEL WHEN .F.
	
	ACTIVATE WIZARD oWizard CENTERED
	
	If lFinish                 
		
		aCols[n][nPAssunto] := aAssunto[2][aScan(aAssunto[1],cAssunto)]

		lRet := TK272AssTmk(aCols[n][nPAssunto])
		
		If lRet .AND. !Empty(cOcorren)
			aCols[n][nPOcorren] := aOcorren[2][aScan(aOcorren[1],cOcorren)]
			M->UD_OCORREN := aCols[n][nPOcorren]
			lRet := TK272OcoTmk(aCols[n][nPOcorren])
		EndIf 
		
		If lRet .AND. !Empty(cAcao)
			aCols[N][nPAcao] := aAcao[2][aScan(aAcao[1],cAcao)]
			M->UD_SOLUCAO := aCols[N][nPAcao]
			lRet := Tk272AcaTmk(aCols[N][nPAcao])
		EndIf 
		
		If lRet
			aCols[N][nPProd] := cProdSB1
			lRet := TK272ProTmk(aCols[N][nPProd])
		EndIf
		
		If lRet .AND. !Empty(cResp)
			aCols[N,nPosResp] := cResp
			lRet := TK272DescUsu(aCols[N,nPosResp],@cNomResp)
		EndIf
		
		If lRet
			aCols[N,nPObsMemo] := cDetalhe

			If (nX := aScan(aHeader,{|x| AllTrim(x[2]) == "UD_ORIGEM"})) > 0
				If Empty(cOrig)
					aCols[n][nX] := ""
				Else
					aCols[n][nX] := Iif(cOrig=="Loja","1","2")
				EndIf
			EndIf

			If (nX := aScan(aHeader,{|x| AllTrim(x[2]) == "UD_VENDA"})) > 0
				If Empty(cVenda)
					aCols[n][nX] := ""
				Else
					aCols[n][nX] := cVenda
				EndIf
			EndIf
			
			If (nX := aScan(aHeader,{|x| AllTrim(x[2]) == "UD_ITEMVDA"})) > 0
				If Empty(cItVenda)
					aCols[n][nX] := ""
				Else
					aCols[n][nX] := cItVenda
				EndIf
			EndIf
			
			If lTk272Wzd
				ExecBlock("TK272WZD",.F.,.F.)
			EndIf
			
			lVldAssunto := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
Else
	lRet := Conpad1(NIL,NIL,NIL,"T1",NIL,.F.,.F.,)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkLoadProdsºAutor  ³Vendas CRM         º Data ³  20/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega produtos comercializados para o cliente            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA272                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkLoadProds(cCliente,cLoja,oPeriodo)

Local aArea		:= GetArea()
Local aProds 	:= {}
Local cQuery	:= ""
Local cAlias1	:= ""    
Local cFilSC5	:= xFilial("SC5")
Local cFilSC6	:= xFilial("SC6")
Local cFilSB1	:= xFilial("SB1")
Local cFilSL1	:= xFilial("SL1")
Local cFilSL2	:= xFilial("SL2")
//Bruno Cremaschi - Projeto chave única.
local cSDoc		:= ""
local lSDoc		:= SerieNFID("SC5", 3, "C5_SERIE") == "C5_SERIE"

Local dDataCorte:= dDataBase


//{"1 Mês", "3 Meses", "6 Meses", "1 Ano", "2 Anos", "3 Anos"}   
Do Case
	Case oPeriodo:nAt == 1	//1 Mes
		dDataCorte -= 30
	Case oPeriodo:nAt == 2	//3 Meses
		dDataCorte -= 90
	Case oPeriodo:nAt == 3	//6 Meses
		dDataCorte -= 180
	Case oPeriodo:nAt == 4	//1 Ano
		dDataCorte -= 360
	Case oPeriodo:nAt == 5	//2 Anos
		dDataCorte -= 720
	Case oPeriodo:nAt == 6	//3 Anos
		dDataCorte -= 1080
EndCase

#IFDEF TOP

	cAlias1 := GetNextAlias()
	
	//Selecao de produtos vendidos via Pedido de venda
	//Bruno Cremaschi - Projeto chave única.
	if lSDoc
		cQuery	:= "SELECT C6_PRODUTO,B1_DESC,C5_EMISSAO,C6_ENTREG,C6_ITEM,C5_NUM,C5_NOTA,C5_SERIE "
	else
		cQuery	:= "SELECT C6_PRODUTO,B1_DESC,C5_EMISSAO,C6_ENTREG,C6_ITEM,C5_NUM,C5_NOTA,C5_SERIE,C5_SDOC "
	endIf
	cQuery	+= "FROM " + RetSqlName("SC6") + " SC6 "
	cQuery	+= "INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = '"+cFilSC5+"' "
	cQuery	+= 		"AND C5_CLIENTE = '"+cCliente+"' AND C5_LOJACLI = '"+cLoja+"' AND C5_TIPO = 'N' "
	cQuery	+= 		"AND C5_EMISSAO >= '" + DtoS(dDataCorte) + "' "
	cQuery	+= 		"AND C5_NOTA <> '' AND SC5.D_E_L_E_T_ = '' AND C6_NUM = C5_NUM "
	cQuery	+= "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '"+cFilSB1+"' AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = '' "
	cQuery	+= "WHERE C6_FILIAL = '" + cFilSC6 + "' AND SC6.D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.T.,.T.)
	
	TcSetField( cAlias1, "C5_EMISSAO"	, "D", 8, 0 ) 
	TcSetField( cAlias1, "C6_ENTREG"	, "D", 8, 0 ) 
	
	While !(cAlias1)->(Eof())
	//Bruno Cremaschi - Projeto chave única.
		cSDoc		:= SerieNFID((cAlias1), 2, "C5_SERIE")
		AAdd(aProds,{	.F.						,;
						(cAlias1)->C6_PRODUTO	,;
						(cAlias1)->B1_DESC		,;
						(cAlias1)->C5_EMISSAO	,;
						(cAlias1)->C6_ENTREG	,;
						(cAlias1)->C5_NUM		,;
						(cAlias1)->C6_ITEM		,;
						(cAlias1)->C5_NOTA + "/" + cSDoc	,;
						STR0071					})   //"Pedido de venda"
		
		(cAlias1)->(DbSkip())
	End
	
	(cAlias1)->(DbCloseArea())
	
	//Bruno Cremaschi - Projeto chave única.
	if lSDoc
		cQuery	:= "SELECT L2_PRODUTO,L2_DESCRI,L2_ITEM,L1_EMISSAO,L1_EMISNF,L1_NUM,L1_DOC,L1_SERIE "
	else
		cQuery	:= "SELECT L2_PRODUTO,L2_DESCRI,L2_ITEM,L1_EMISSAO,L1_EMISNF,L1_NUM,L1_DOC,L1_SERIE,L1_SDOC "
	endIf
	cQuery	+= "FROM " + RetSqlName("SL2") + " SL2 "
	cQuery	+= "INNER JOIN " + RetSqlName("SL1") + " SL1 ON L1_FILIAL = '" + cFilSL1 + "' "
	cQuery	+= 		"AND L1_CLIENTE = '" + cCliente + "' AND L1_LOJA = '" + cLoja + "' AND L1_DOC <> '' "
	cQuery	+= 		"AND L1_EMISSAO >= '" + DtoS(dDataCorte) + "' "
	cQuery	+= 		"AND SL1.D_E_L_E_T_ = '' AND L1_NUM = L2_NUM "
	cQuery	+= "AND L2_FILIAL = '" + cFilSL2 + "' AND SL2.D_E_L_E_T_ = ''"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.T.,.T.)
	
	TcSetField( cAlias1, "L1_EMISSAO"	, "D", 8, 0 ) 
	TcSetField( cAlias1, "L1_EMISNF"	, "D", 8, 0 ) 
	
	While !(cAlias1)->(Eof())
	//Bruno Cremaschi - Projeto chave única.
		cSDoc		:= SerieNFID((cAlias1), 2, "L1_SERIE")
		AAdd(aProds,{	.F.						,;
						(cAlias1)->L2_PRODUTO	,;
						(cAlias1)->L2_DESCRI	,;
						(cAlias1)->L1_EMISSAO	,;
						(cAlias1)->L1_EMISNF	,;
						(cAlias1)->L1_NUM		,;
						(cAlias1)->L2_ITEM		,;
						(cAlias1)->L1_DOC + "/" + cSDoc		,;
						STR0072					})	//"Loja"
		(cAlias1)->(DbSkip())
	End
	
	(cAlias1)->(DbCloseArea())

#ELSE
    
	DbSelectArea("SB1")
	DbSetOrder(1)
	 
	DbSelectArea("SC6")
	DbSetOrder(1)//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	
	DbSelectArea("SC5")
	DbSetOrder(3) //C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
	DbSeek(cFilSC5+cCliente+cLoja)
	
	While !SC5->(Eof()) .AND. SC5->C5_FILIAL == cFilSC5 .AND. SC5->C5_CLIENTE == cCliente .AND. SC5->C5_LOJACLI == cLoja
		If SC5->C5_TIPO == "N" .AND. !Empty(SC5->C5_NOTA) .AND. SC5->C5_EMISSAO >= dDataCorte
			SC6->(DbSeek(cFilSC6 + SC5->C5_NUM))
			While !SC6->(Eof()) .AND. SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_NUM == SC5->C5_NUM
				SB1->(DbSeek(cFilSB1 + SC6->C6_PRODUTO))
				AAdd(aProds,{	.F.			,;
							SC6->C6_PRODUTO	,;
							SB1->B1_DESC	,;
							SC5->C5_EMISSAO	,;
							SC6->C6_ENTREG	,;
							SC5->C5_NUM		,;
							SC6->C6_ITEM	,;
							SC5->C5_NOTA+"/"+SC5->C5_SERIE	,;
							STR0071			}) //"Pedido de venda"
				SC6->(DbSkip())
			End
		EndIf
		SC5->(DbSkip())
	End
	
	DbSelectArea("SL2")
	DbSelectArea(1)
	
	DbSelectArea("SL1")
	DbSetOrder(6) //L1_FILIAL+L1_CLIENTE+L1_LOJA
	DbSeek(cFilSL1+cCliente+cLoja)
	
	While !SL1->(Eof()) .AND. SL1->L1_FILIAL == cFilSL1 .AND. SL1->L1_CLIENTE == cCliente .AND. SL1->L1_LOJA == cLoja
		If !Empty(SL1->L1_DOC) .AND. SL1->L1_EMISSAO >= dDataCorte
			SL2->(DbSeek( cFilSL2 + SL1->L1_NUM ))
			While !SL2->(Eof()) .AND. SL2->L2_FILIAL == cFilSL2 .AND. SL2->L2_NUM == SL1->L1_NUM
				AAdd(aProds,{	.F.				,;
								SL2->L2_PRODUTO	,;
								SL2->L2_DESCRI	,;
								SL1->L1_EMISSAO	,;
								SL1->L1_EMISNF	,;
								SL1->L1_NUM		,;
								SL2->L2_ITEM	,;
								SL1->L1_DOC+"/"+SL1->L1_SERIE	,;
								STR0072			})//"Loja"		
				SL2->(DbSkip())
			End
		EndIf
		SL1->(DbSkip())
	End

#ENDIF
          
If Len(aProds) == 0
	AAdd(aProds,{.F.,"","",CtoD(""),CtoD(""),"","","",""})
EndIf

//Ordena pelo codigo do produto de forma crescente
aSort(aProds,,,{|x,y| x[2] < y[2] })

RestArea(aArea)

Return aProds

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk272LAss ºAutor  ³Vendas CRM          º Data ³  27/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa a listagem de ocorrencias a partir do assunto    º±±
±±º          ³selecionadoo                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA272                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk272LAss(oAssunto,oOCorren,aAssunto,aOcorren)

Local nItSel 	:= oAssunto:nAt
Local cCodAss	:= ""

aOcorren:= {{""},{""}}

If nItSel > 1
	
	cCodAss := aAssunto[2][nItSel]
	
	DbSelectArea("SU9")
	DbSetOrder(1)
	DbSeek(xFilial("SU9")+cCodAss)
	
	While !Eof() .AND. SU9->U9_FILIAL == xFilial("SU9") .AND.;
		SU9->U9_ASSUNTO == cCodAss
		
		AAdd(aOcorren[1],SU9->U9_DESC	)
		AAdd(aOcorren[2],SU9->U9_CODIGO	)
		
		SU9->(DbSkip())
	End
	
EndIf

oOCorren:SetItems(aOcorren[1])	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk272LOco ºAutor  ³Vendas CRM          º Data ³  27/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa a listagem de acoes a partir da ocorrencia sele- º±±
±±º          ³cionada                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA272                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk272LOco(oOcorren,oAcao,aOcorren,aAcao)

Local nItSel 	:= oOcorren:nAt
Local cCodOco	:= ""

aAcao:= {{""},{""}}

If nItSel > 1
	
	cCodOco := aOcorren[2][nItSel]
	
	DbSelectarea("SUR")
	DbSetorder(1)
	DbSeek(xFilial("SUR")+cCodOco)
	While !Eof() .AND. (xFilial("SUR") == SUR->UR_FILIAL) .AND. (SUR->UR_CODREC == cCodOco)
		If !Empty(SUR->UR_CODSOL)
			AAdd(aAcao[1],SUR->UR_DESC		)
			AAdd(aAcao[2],SUR->UR_CODSOL	)
		Endif	
		DbSkip()
	End  
	
EndIf

oAcao:SetItems(aAcao[1])	

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk272Psq

Rotina responsável por buscar o registro infomado pelo usuário na grid de atendimento

@param nTipo		, numérico , Tipo de seleção 
@param aIndPesq	, array		, conteúdo selecionado para pesquisa  
@param cInd		, caracter	, conteúdo selecionado sendo ( "1=Grupo", "2=Chamado","3=Data","4=Contato" ) 
@param cPesq		, caracter	, conteúdo digitado 
@param oLbx		, objeto	, objeto do grid
@param aPendente	, array		, contém os dados dos atendimentos pendentes
 
@return lRet		, lógico	, Retorna se o registro pesquisado foi encontrado

@author  Thamara Villa Jacomo 
@version P12
@since   24/01/2016  

/*/
//------------------------------------------------------------------------------------------
Static Function Tk272Psq( nTipo, aIndPesq, cInd ,cPesq, oLbx, aPendente )	
    
Local Nx 			:= 0
Local nPos 		:= Val( cInd )
Local bValidC1 	:= { || ( Posicione( "SU7", 3, xFilial( "SU7" ) + Alltrim( cPesq ), "U7_TIPO" ) == "2" ) .And. Upper( AllTrim( cPesq ) ) $ Upper( AllTrim( aPenAnt[Nx][aPos[nPos][01]] ) ) }
Local bValidC2 	:= { || Upper( AllTrim( cPesq ) ) $ Upper( AllTrim( aPenAnt[Nx][aPos[nPos][01]] ) ) }
Local bValidD 	:= { || AllTrim( aPenAnt[Nx][aPos[nPos][01]] )  == AllTrim( cPesq ) }

Local aPos 		:= { { 5, bValidC1 }, { 2, bValidC2 } , { 3, bValidD }, { 10, bValidC2 } }
aPendente := {}

If nTipo == 0
	aPendente := aClone( aPenAnt )
ElseIf nTipo == 1
	
	For Nx := 1 To Len( aPenAnt )
		If Eval( aPos[nPos][2] ) 
			Aadd( aPendente, aClone( aPenAnt[Nx] ) )
		EndIf
	Next
	If Empty( aPendente )
		aPendente := aClone( aPenAnt )
		MsgAlert( OemToAnsi( STR0073 ) )//"Nenhum item foi encontrado para ser filtrado. Filtro Nao Aplicado!") //"Nenhum item foi encontrado para ser filtrado. Filtro Nao Aplicado!"
	EndIf
EndIf

oLbx:SetArray(aPendente)
oLbx:bLine:={||{aPendente[oLbx:nAt,1],;  //Semaforo - vermelho
aPendente[oLbx:nAt,2],;  //Liga??o
aPendente[oLbx:nAt,3],;  //Data
aPendente[oLbx:nAt,4],;  //Hora
aPendente[oLbx:nAt,5],;  //Operador
aPendente[oLbx:nAt,6],;	 //Nome da Entidade
aPendente[oLbx:nAt,7],;	 //Operacao
aPendente[oLbx:nAt,8],;	 //Status
aPendente[oLbx:nAt,9],;  //Comunicacao
aPendente[oLbx:nAt,10],; //Contato
aPendente[oLbx:nAt,11],; //Campanha
aPendente[oLbx:nAt,12],; //Midia
aPendente[oLbx:nAt,13],; //Retorno
aPendente[oLbx:nAt,14]}} //Hora

oLbx:Refresh()

If oLbx:nAt > 0
	TkMontaItens( "SUD", aPendente[oLbx:nAt][2], "M" )
EndIf
 
Return( Nil )

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
