#Include "QIPM010.CH"
#Include "PROTHEUS.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ QPM010 - Variaveis utilizadas para parametros					³
//³ mv_par01				// Produto Origem    					³
//³ mv_par02				// Revisao Origem 						³
//³ mv_par03				// Produto Destino                		³
//³ mv_par04				// Revisao Destino						³
//³ mv_par05				// Origem da Descricao                  ³
//³ mv_par06				// Descricao do Produto Destino         ³
//³ mv_par07				// Roteiro De       	                ³
//³ mv_par08				// Roteiro Ate		                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static sMvPar05 := Nil
Static sMvPar06 := Nil
Static sMvPar07 := Nil
Static sMvPar08 := Nil

/*/
Função em desuso - descontinuada no RPO
*/
Function QIPM010()
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Qip010ExPr ³ Autor ³ Marcelo Pimentel      ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verif. se Prod. est  cadastrado ou se j  existe				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Qip010ExPr(ExpC1)                             				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: "O" se for Produto Origem              				³±±
±±³          ³ ExpC1: "D" se for Produto Destino             				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID (QPM010)                            				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip010ExPr(cPerg)
	Local cChave, lRet := .T.

	PergQPM010()

	If cPerg == "O"  // Produto Origem
		If !Isdigit(mv_par02)
			//Quando acertado o pergunte, colocar help
			//informando que campo deve ser numerico.
			Return(.F.)
		EndIf
		cChave := mv_par01 + Inverte(mv_par02)
		If naovazio()
			// Verifica se existe o Produto/Revisao
			If QP6->(DbSeek(xFilial('QP6') + cChave ))
				// Sugere a descricao do Produto Origem p/ o Produto Destino

				QP010Verif(sMvPar05)

				// Sugere a proxima revisao
				mv_par04 := QA_UltRvQ(mv_par01,dDataBase,.f.,.t.)
				mv_par03 := mv_par01
				If empty(mv_par04)
				mv_par04 := "00"
				Else
				mv_par04 := Soma1(mv_par04)
				While .t.
					If !FreeForUse("QP6",xFilial("QP6")+MV_PAR01+MV_PAR04)
						mv_par04 := Soma1(mv_par04)
					Else
						Exit
					EndIf
				EndDo
				EndIF
				lRet := .T.
			Else
				MsgAlert(STR0001,STR0002)		//"Produto/RevisÆo nÆo cadastrado"###"Aten‡Æo"
			EndIf
		EndIf
	Else	// Produto Destino
		If !Isdigit(mv_par04)
			// Quando acertado o pergunte, colocar help
			// informando que campo deve ser numerico.
			Return(.F.)
		EndIf
		cChave := mv_par03 + Inverte(mv_par04)
		If naovazio()
			If mv_par01 <> mv_par03
				// Verifica se j  existe o Produto/Revisao
				If !QP6->(DbSeek(xFilial('QP6') + cChave ))
					lRet := .T.
				Else
					MsgAlert(STR0003,STR0002)		//"Produto/RevisÆo j  cadastrado"###"Aten‡Æo"
				EndIf
			EndIf
			QP010Verif(sMvPar05)
		EndIf
	EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Qip010CkPr ³ Autor ³ Marcelo Pimentel      ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se produto est  cadastrado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                            							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip010CkPr(cChamada)
	Local nRec		:= 0
	Local cSeek     := ""

	Default cChamada := "M"

	PergQPM010()

	If cChamada == "M"
		mv_par03 := Upper(mv_par03)
		mv_par04 := "00"
		cSeek    := mv_par03
	Else
		mv_par01 := Upper(mv_par01)
		mv_par02 := "00"
		cSeek    := mv_par01
	EndIf

	If naovazio()
		nRec := QP6->(recno())
		QP6->(dbSetOrder(1))
		If QP6->(DbSeek(xFilial('QP6') + cSeek),.T.)
			If QP6->(!EOF())
				If cChamada == "M"
					mv_par04 := Soma1(QP6->QP6_REVI)
				Else
					mv_par02 := Soma1(QP6->QP6_REVI)
				EndIf
			EndIF
			sMvPar06 := QP010Verif()
		Endif
		If dVigRev <= QP6->QP6_DTINI
			dVigRev := (QP6->QP6_DTINI+1)
		EndIf

		QP6->(dbSetOrder(1))
		QP6->(DbGoTo(nRec))
	EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010UpIns  ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 29/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se Campo Produto nao esta vazio e converte para     ³±±
±±³			 ³ maiusculo.													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                               						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010UpIns()

	Local lRet := .f.

	PergQPM010()

	If naovazio()
		mv_par01 := Upper(mv_par01)
		lRet := .t.
	EndIf

	//Preenche o parametro MV_PAR02 com a ultima revisao do produto.
	If lRet
		If Empty(MV_PAR02)
			MV_PAR02 := QA_UltRvQ(mv_par01,dDataBase,.f.,.t.)
		EndIf
		sMvPar06 := QP010Verif()
	EndIF

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ QP010Verif ³ Autor ³ Cleber Souza          ³ Data ³ 25/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica de onde vira a descricao do produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPM010                                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QP010Verif(nEscolha)
	Local aAreaSB1   := SB1->(GetArea())
	Local cDes       := Space(TamSX3("B1_DESC")[1])

	If nEscolha == NIL
		nEscolha := sMvPar05
	EndIf

	If (nEscolha == 1)
		sMvPar06 := cDes

	ElseIf (nEscolha == 2)
		DbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+MV_PAR01))
			cDes := SB1->B1_DESC
		EndIf

	ElseIf (nEscolha == 3)
		DbSelectArea("QP6")
		QP6->(dbSetOrder(1))
		If QP6->(DbSeek(xFilial("QP6")+MV_PAR01))
			cDes := QP6->QP6_DESCPO
		EndIf

	EndIf

	RestArea(aAreaSB1)
Return(cDes)

/*/{Protheus.doc} PergQPM010 
Proteção Error.log Chamadas Pergunte QPM010 com dicionário imcompatível
@author brunno.costa
@since 28/02/2022
@version 1.0
/*/
Static Function PergQPM010()
	If ValType(mv_par05) == "N"
		sMvPar05 := mv_par05
		sMvPar06 := mv_par06
		sMvPar07 := mv_par07
		sMvPar08 := mv_par08
	Else
		If ValType(mv_par08) == "N"
			sMvPar05 := mv_par08
		Else
			sMvPar05 := 1
		EndIf
		sMvPar06 := mv_par05
		sMvPar07 := mv_par06
		sMvPar08 := mv_par07
	EndIf
Return
