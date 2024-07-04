#include "rwmake.ch" 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CBMS520VLD ³ Autor ³ Henrique Gomes Oikawa               ³ Data ³ 08/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da exclusao da Nota Fiscal de Saida (MATA520/MATA521)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function CBMS520VLD()
Local lExcRF  := SuperGetMV("MV_CBEXCNF",.f.,'0')=='1'
Local nTamSX1 := Len(SX1->X1_GRUPO)
Local aSavPerg:= Array(30)
Local nI	  := 0
Local nPerg	  := 0

If !SuperGetMV("MV_CBPE021",.F.,.F.)
	Return .t.
EndIf

If Type("l520AUTO") =="L" .and. l520AUTO
	Return .t.
EndIf

CB7->(DbSetOrder(4))
If ! CB7->(DbSeek(xFilial("CB7")+SF2->(F2_DOC+F2_SERIE))) .Or. (CB7->(CB7_CLIENT+CB7_LOJA) # SF2->(F2_CLIENTE+F2_LOJA)) .Or. (CB7->CB7_ORIGEM # '1')	
	Return .t.
EndIf

If lExcRF // Nao permite exclusao via Protheus somente via radio...
	MsgBox("Conforme informado no parametro MV_CBEXCNF a nota deve ser excluida pelo SIGAACD","Aviso","STOP")
	Return .f.
EndIf

For nI := 1 To Len(aSavPerg)
	aSavPerg[nI] := &("mv_par"+StrZero(nI,2))
Next nI

Pergunte("MTA521",.F.)

nPerg := mv_par04

For nI := 1 To Len(aSavPerg)
	&("mv_par"+StrZero(nI,2)) := aSavPerg[nI]
Next nI

If nPerg == 1 // Retorna para Carteira
	MsgBox("Para excluir esta Nota a Opcao de deixar os itens aptos a faturar e obrigatoria, altere o parametro acionando a tecla F12","Aviso","STOP")
	Return .f.
EndIf

Return .t.
