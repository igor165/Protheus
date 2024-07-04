#include "rwmake.ch" 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CBMTA650E   º Autor ³ Anderson Rodrigues º Data ³Wed  26/06/03º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Faz Validacao da  exclusao da OP - Mata650                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function CBMTA650E()
Local aArea		 := Getarea()
Local aAreaSD4   := GetArea("SD4")
Local aAreaCBH   := GetArea("CBH")
Local cLocProc   := GetMvNNR('MV_LOCPROC',space(tamsx3('B1_LOCPAD')[1]))
Local nTamSX1    := Len(SX1->X1_GRUPO)
Local lErro      := .f.
Local lExcluiOPF := .f.

If !SuperGetMV("MV_CBPE017",.F.,.F.)
	Return .t.
EndIf

If Type("l650Auto") == "L" .and. l650Auto // ---> Executa somente se for Protheus
	Return .t.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se deve deletar Ops Filhas conforme parametro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ! Empty(SC2->C2_ORDSEP)
	CB7->(DbSetOrder(1))
	If CB7->(DbSeek(xFilial("CB7")+SC2->C2_ORDSEP))
		MsgBox("Ordem de Producao nao pode ser excluida pois a mesma encontra-se amarrada a Ordem de Separacao "+SC2->C2_ORDSEP,"Atencao","Stop")
		Return .f.
	Else
		RecLock("SC2",.F.)
		SC2->C2_ORDSEP := ""
		SC2->(MsUnLock())
	EndIf
EndIf

SX1->(DbSetOrder(1))
If SX1->(DbSeek(PADR("MTA650",nTamSX1)+"10")) // -->  Verifica se deleta as OPs Filhas ..
	lExcluiOPF := If(SX1->X1_PRESEL == 1,.t.,.f.)
Else
	MsgBox("Pergunta MTA65010 nao encontrada no SX1","Atencao","OK")
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro de monitoramento para a OP³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CBH->(DbSetOrder(3))
If CBH->(DbSeek(xFilial("CBH")+Alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)))
	MsgBox("OP nao pode ser excluida, pois possui registro(s) na rotina de monitoramento","Aviso","OK")
	RestArea(aAreaCBH)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP possui empenho                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SD4->(DbSetOrder(2))
If SD4->(DbSeek(xFilial("SD4")+Alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)))
	While ! SD4->(EOF()) .and. SD4->(D4_FILIAL+Left(D4_OP,6)) == xFilial("SD4")+Alltrim(SC2->C2_NUM)
		If ! lExcluiOPF .and. (SC2->C2_SEQUEN # Substr(SD4->D4_OP,9,3) .or. SC2->C2_ITEM # Substr(SD4->D4_OP,7,2))
			SD4->(DbSkip())
			Loop
		ElseIf SD4->D4_LOCAL # cLocProc
			SD4->(DbSkip())
			Loop
		ElseIf SD4->D4_EMPROC > 0
			AutoGrLog("Produto "+Alltrim(SD4->D4_COD)+" possui saldo empenhado para a OP "+Alltrim(SD4->D4_OP))
			lErro:= .t.
		EndIf
		SD4->(DbSkip())
	Enddo
	If lErro
		MostraErro()
		RestArea(aAreaSD4)
		Return .f.
	EndIf
EndIf
RestArea(aAreaSD4)
RestArea(aAreaCBH)
RestArea(aArea)
Return .t.
