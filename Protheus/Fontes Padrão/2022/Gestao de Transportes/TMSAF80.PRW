#Include "TMSAF80.CH"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ TMSF80Nota ³ Autor ³ Valdemar Roberto  ³ Data ³ 03.06.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Chama digitação da nota fiscal do cliente                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF79Nota(aExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 := Vetor com as lotes criados                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF80Nota(aLotCol)
Local nCntFor1 := 0
Local nCntFor2 := 0
Local aAreas   := {DTP->(GetArea()),DTC->(GetArea()),DF1->(GetArea()),DC5->(GetArea()),DDB->(GetArea()),SA1->(GetArea()),DT5->(GetArea()),GetArea()}

DEFAULT aLotCol := {}

If !Empty(aLotCol)
	DF1->(DbSetOrder(3))
	For nCntFor1 := 1 To Len(aLotCol)
		If Ascan(aLotCol[nCntFor1,3],{|x| x[1] == "DT5"}) > 0
			MsgAlert(STR0001 + AllTrim(Posicione("SA1",1,xFilial("SA1") + aLotCol[nCntFor1,14] + aLotCol[nCntFor1,15],"A1_NOME")) + ;
					 STR0002 + AllTrim(Posicione("DDB",1,xFilial("DDB") + aLotCol[nCntFor1,16],"DDB_DESCRI")) + ;
					 STR0003 + AllTrim(Tabela("L4",aLotCol[nCntFor1,17],.F.)) + STR0004,STR0005) //"Existem notas do cliente "###", negociação "###", serviço "###" que ainda não foram digitadas."###"Atenção"
			For nCntFor2 := 1 To Len(aLotCol[nCntFor1,3])
				If aLotCol[nCntFor1,3,nCntFor2,1] == "DT5"
					DT5->(DbGoTo(aLotCol[nCntFor1,3,nCntFor2,2]))
					If DF1->(DbSeek(xFilial("DF1") + DT5->(DT5_FILORI + DT5_NUMSOL) + "COL"))
						aPanAgeTms    := Array(7)

						aPanAgeTms[1] := "DTC"
						aPanAgeTms[2] := 0
						aPanAgeTms[3] := 3
						aPanAgeTms[4] := DF1->DF1_NUMAGE
						aPanAgeTms[5] := DF1->DF1_ITEAGE
						aPanAgeTms[6] := "TMSA050Mnt"
						aPanAgeTms[7] := aLotCol[nCntFor1,19]

						Inclui := .T.
						
						TMSA050()

						DTC->(DbSetOrder(8))
						If DTC->(DbSeek(xFilial("DTC") + DF1->(DF1_FILDOC + DF1_DOC)))
							MsgAlert(STR0006,STR0005)	//"Nota inserida com sucesso."###"Atenção"
						Else //-- não confirmou a nota.
							MsgAlert(STR0007,STR0005)	//"Nota não foi inserida."###"Atenção"
						EndIf
                    Else
						MsgAlert(STR0008 + DT5->DT5_FILORI + "/" + DT5->DT5_NUMSOL + ;
								 STR0009,STR0005) //"A solicitação de coleta "###" não possui agendamento vinculado."###"Atenção"
					EndIf
				EndIf
			Next nCntFor2
			//-- Atualiza a quantidade de notas do lote
			DTP->(DbSetOrder(1))
			If DTP->(DbSeek(xFilial("DTP") + aLotCol[nCntFor1,19]))
				RecLock("DTP",.F.)
				DTP->DTP_QTDLOT := DTP->DTP_QTDDIG
				DTP->DTP_STATUS := StrZero(2,Len(DTP->DTP_STATUS))
				DTP->(MsUnlock())
			EndIf
		EndIf
	Next nCntFor1
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return
