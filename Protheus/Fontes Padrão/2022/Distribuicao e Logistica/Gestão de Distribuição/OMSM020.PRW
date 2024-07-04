#INCLUDE "OMSM020.ch"
#include "FiveWin.ch"
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    Ё DFata41  Ё Autor Ё Marcos Cesar          Ё Data Ё 20/07/1999 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Curva CAP : Essa curva tem como objetivo classificar os cli- Ё╠╠
╠╠Ё          Ё entes quanto a frequencia de visitas, baseando-se no numero  Ё╠╠
╠╠Ё          Ё de PDVs e na media mensal de vendas.                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё DFata41()                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Especifico p/ Distribuidora Antarctica.                      Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё Motivo da Alteracao                      Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Cristiane    Ё11.02.00Ё      Ё Conversao p/ Protheus (DISM020)          Ё╠╠
╠╠Ё Moreto       Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function DISM020()

Local oBtn1,oBtn2,oBtn3
Local oDlg

DEFINE MSDIALOG oDlg FROM 96,13 TO 310,592 TITLE STR0001 PIXEL //"Curva CAP"
//	@ 06,6 To 66,284
	@ 13,15 SAY OemToAnsi(STR0002) SIZE 250,7 OF oDlg PIXEL //"Este programa tem como objetivo classificar os clientes quanto a frequencia de visitas,"
	@ 23,15 SAY OemToAnsi(STR0003) SIZE 200,7 OF oDlg PIXEL //"baseando-se no numero de PDVs e na media mensal de vendas."

   @ 090,185 BUTTON oBtn1 PROMPT STR0004  ACTION (oDlg:End(),A41Proc()) SIZE 34,11 OF oDlg PIXEL //"Classificar"
   @ 090,223 BUTTON oBtn2 PROMPT STR0005  ACTION M020ClasCAP() SIZE 34,11 OF oDlg PIXEL //"Criterios"
	@ 090,260 BUTTON oBtn3 PROMPT STR0006  ACTION (oDlg:End()) SIZE 34,11 OF oDlg PIXEL //"Sair"
ACTIVATE DIALOG oDlg CENTERED

Return Nil

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    Ё A41Proc  Ё Autor Ё Marcos Cesar          Ё Data Ё 20/07/1999 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Chamada do Processamento.                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё A41Proc()                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё DFata41                                                      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function A41Proc()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array contendo o Total Geral de PDVs e do Potencial. Estrutu-Ё
//Ё ra.                                                          Ё
//Ё                                                              Ё
//Ё aArray[1] : Total de PDVs                                    Ё
//Ё aArray[2] : Total do Potencial de Venda                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Local aTotal 		:= { 0, 0 }
Local oTempTable	:= Nil
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array contendo os Campos do Arquivo de Trabalho.             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aCamposTRB := {{ "TRB_COD"   , "C",  6, 0 },;  // Codigo do Cliente
					{ "TRB_LOJA"  , "C",  2, 0 },;  // Loja do Cliente
					{ "TRB_POTENC", "N", 12, 0 },;  // Potencial de Venda (Cerveja + Refrigerante)
					{ "TRB_CHAVE" , "C", 15, 0 }}   // Chave Descendente de Indexacao (Potencial * -1)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria, Abre e Indexa o Arquivo de Trabalho.                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCamposTRB )
oTempTable:AddIndex("01", {"TRB_CHAVE"} )
oTempTable:Create()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Geracao do Arquivo de Trabalho.                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Processa( { || A41Trab(@aTotal) }, STR0008) //"Gerando Arquivo de Trabalho"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processamento da Curva CAP.                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Processa( { || A41Curva(@aTotal) }, STR0001) //"Curva CAP"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Deleta o Arquivo de Trabalho.                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oTempTable:Delete()

Return Nil

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    Ё A41Trab    Ё Autor Ё Marcos Cesar        Ё Data Ё 20/07/1999 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Geracao do Arquivo de Trabalho.                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё A41Trab()                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё DFata41                                                      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function A41Trab(aTotal)

Local nTotalPot := 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Le o Arquivo SA1 (Cadastro de Clientes).                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("SA1")
ProcRegua(LastRec())
dbSetOrder(1)
dbSeek(xFilial())

While !Eof() .And. SA1->A1_FILIAL == xFilial()
	IncProc()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula o Potencial Total (Cerveja + Refrigerante).          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTotalPot := SA1->A1_POTCERV + SA1->A1_POTREFR

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava o Arquivo de Trabalho.                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("TRB")
	RecLock("TRB", .T.)

	TRB->TRB_COD    := SA1->A1_COD
	TRB->TRB_LOJA   := SA1->A1_LOJA
	TRB->TRB_POTENC := nTotalPot
	TRB->TRB_CHAVE  := StrZero(1000000000 - nTotalPot, 15, 0)

	MsUnLock()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza o Array contendo o Total Geral.                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aTotal[1] := aTotal[1] + 1
	aTotal[2] := aTotal[2] + nTotalPot

	dbSelectArea("SA1")
	dbSkip()
End

Return Nil

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    Ё A41Curva   Ё Autor Ё Marcos Cesar        Ё Data Ё 20/07/1999 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Processamento da Curva CAP.                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё A41Curva()                                                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё DFata41                                                      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function A41Curva(aTotal)

Local nPercPDV := 0
Local nPercPot := 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Le o Arquivo de Trabalho.                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("TRB")
ProcRegua(LastRec())
dbGoTop()

While !Eof()
	IncProc()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Acumula o Percentual de PDVs.                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPercPDV := nPercPDV + ( (1 / aTotal[1]) * 100 )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Acumula o Percentual do Potencial de Venda.                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPercPot := nPercPot + ( (TRB->TRB_POTENC / aTotal[2]) * 100 )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pesquisa o Arquivo DAT (Criterios de Classificacao da Curva  Ё
	//Ё CAP) p/ verificar em qual Classificacao o Cliente se enquadraЁ
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("DAT")
	dbSetOrder(1)
	dbSeek(xFilial())

	While !Eof() .And. DAT->DAT_FILIAL == xFilial()
		If (nPercPDV >= DAT->DAT_M1PDV .And. nPercPDV <= DAT->DAT_M2PDV) .Or.;
			(nPercPot >= DAT->DAT_M1POT .And. nPercPot <= DAT->DAT_M2POT)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Pesquisa o Arquivo SA1 (Cadastro de Clientes) p/ gravar a    Ё
			//Ё Classificacao do Cliente.                                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial() + TRB->TRB_COD + TRB->TRB_LOJA)

			If Found()
				RecLock("SA1", .F.)

				SA1->A1_CAP := DAT->DAT_CLASS

				MsUnLock()
			EndIf

			Exit
		EndIf

		dbSelectArea("DAT")
		dbSkip()
	End

	dbSelectArea("TRB")
	dbSkip()
End

Return Nil

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    Ё DFata411 Ё Autor Ё Marcos Cesar          Ё Data Ё 20/07/1999 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Esse ExecBlock permite ao usuario, atraves de uma MultiLine, Ё╠╠
╠╠Ё          Ё informar os criterios de classificacao da Curva CAP.         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё DFata411()                                                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Especifico p/ Distribuidora Antarctica.                      Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё Motivo da Alteracao                      Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Cristiane    Ё11.02.00Ё      Ё Conversao p/ Protheus (DISM020) - RdMake Ё╠╠
╠╠Ё Moreto       Ё        Ё      Ё DFATA411.PRW -> Funcao M020ClasCAP       Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function M020ClasCAP()
Local oDlg1
Local nA:= 0

	aHeader := {}
	aCols   := {}
	nUsado  := 0
	nOpcx   := 3
	aRotina := {{ STR0009,"AxPesqui", 0 , 1 },; //"Pesquisar"
					{ STR0010, "AxVisual",0 , 2 },; //"Visualizar"
					{ STR0011, "AxInclui",0 , 3 },; //"Incluir"
					{ STR0012, "AxAltera",0 , 4 },; //"Alterar"
					{ STR0013, "AxDeleta",0 , 5 } } //"Excluir"

	cCadastro := OemToAnsi(STR0014) //"Criterios de Classificacao da Curva CAP"
	cAlias    := "DAT"
	nReg      := 1

	FillGetDados(nOpcx,"DAT",1)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Dialog do Criterio de Classificacao.                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DEFINE MSDIALOG oDlg1 FROM 200,0 TO 540,600 TITLE cCadastro PIXEL
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Exibe a GetDados.                                            Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oGetD:=MsGetDados():New(05,5,140,295,nOpcx,"AllWaysTrue()","M020Valid()",,.T.,,1)

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Botoes.                                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DEFINE SBUTTON FROM 150,237 TYPE 01 ACTION (A411Grava(),oDlg1:End()) ENABLE OF oDlg1
		DEFINE SBUTTON FROM 150,267 TYPE 02 ACTION (oDlg1:End()) ENABLE OF oDlg1
	ACTIVATE DIALOG oDlg1 CENTERED

Return Nil

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    Ё A411GravaЁ Autor Ё Marcos Cesar          Ё Data Ё 20/07/1999 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Grava o Arquivo DAT (Criterios da Curva CAP).                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё A411Grava()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё DFata411                                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function A411Grava()

Local lRet  := .T.
Local nItem := 0
Local nPosClass := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_CLASS"})
Local nPosM1PDV := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M1PDV"})
Local nPosM2PDV := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M2PDV"})
Local nPosM1POT := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M1POT"})
Local nPosM2POT := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M2POT"})
Local nPosFreq  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_FREQ"})
Local nA:= 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacao dos Criterios informados.                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRet := M020Valid()

If lRet
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Deleta os Registros no Arquivo DAT (Criterios de Classifica- Ё
	//Ё cao da Curva CAP).                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("DAT")
	dbSetOrder(1)
	dbSeek(xFilial())

	While !Eof() .And. DAT->DAT_FILIAL == xFilial()
		RecLock("DAT", .F.)
			dbDelete()
		MsUnLock()

		dbSkip()
	End

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inclui os Registros no Arquivo DAT (Criterios de Classifica- Ё
	//Ё cao da Curva CAP).                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nA := 1 To Len(aCols)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se esta Deletado.                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If aCols[nA][nUsado + 1]
			Loop
		EndIf

		nItem := nItem + 1

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava o Arquivo DAT.                                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("DAT")
		RecLock("DAT", .T.)

		DAT->DAT_FILIAL := xFilial()
		DAT->DAT_ITEM   := StrZero(nItem,2)
		DAT->DAT_CLASS  := aCols[nA][nPosClass]
		DAT->DAT_M1PDV  := aCols[nA][nPosM1PDV]
		DAT->DAT_M2PDV  := aCols[nA][nPosM2PDV]
		DAT->DAT_M1POT  := aCols[nA][nPosM1POT]
		DAT->DAT_M2POT  := aCols[nA][nPosM2POT]
		DAT->DAT_FREQ   := aCols[nA][nPosFreq]

		MsUnLock()
	Next nA

EndIf

Return Nil

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    Ё DFata413 Ё Autor Ё Marcos Cesar          Ё Data Ё 21/07/1999 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Esse ExecBlock valida os Criterios informados pelo Usuario.  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё DFata413()                                                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Especifico p/ Distribuidora Antarctica.                      Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Atualizacoes sofridas desde a Construcao Inicial.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Programador  Ё Data   Ё BOPS Ё Motivo da Alteracao                      Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Cristiane    Ё11.02.00Ё      Ё Conversao p/ Protheus (DISM020) - RdMake Ё╠╠
╠╠Ё Moreto       Ё        Ё      Ё DFATA413.PRW -> M020Valid                Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function M020Valid()

Local lRet := .T.
Local nAnt := 0
Local nPos := 0
Local nPosClass := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_CLASS"})
Local nPosM1PDV := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M1PDV"})
Local nPosM2PDV := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M2PDV"})
Local nPosM1POT := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M1POT"})
Local nPosM2POT := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_M2POT"})
Local nPosFreq  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAT_FREQ"})
Local nA			 := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se os Valores estao corretos.                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !aCols[n][nUsado + 1]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se existe Campo Obrigatorio em Branco.              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Empty(aCols[n][nPosClass])
      Aviso(STR0016,STR0015,{'OK'})
		lRet := .F.
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se a Classificacao ja esta cadastrada.              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nA := 1 To Len(aCols)
		If !aCols[nA][nUsado + 1] .And. nA <> n
			If aCols[nA][nPosClass] == aCols[n][nPosClass]
            Aviso(STR0016,STR0017,{'OK'})
				lRet := .F.

				Exit
			EndIf
		EndIf
	Next nA

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se o Percentual de PDVs da Classificacao ultrapassa Ё
	//Ё 100 %.                                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRet .And. (aCols[n][nPosM1PDV] > 100 .Or. aCols[n][nPosM2PDV] > 100)
       Aviso(STR0016,STR0018,{'OK'})
		lRet := .F.
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se o Percentual de Potencial da Classificacao ultra-Ё
	//Ё passa 100 %.                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRet .And. (aCols[n][nPosM1Pot] > 100 .Or. aCols[n][nPosM2Pot] > 100)
       Aviso(STR0016,STR0018,{'OK'})
		lRet := .F.
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se o Percentual de PDVs da Classificacao esta corre-Ё
	//Ё to.                                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRet .And. aCols[n][nPosM1PDV] > aCols[n][nPosM2PDV]
      Aviso(STR0016,STR0019,{'OK'})
		lRet := .F.
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se o Percentual de Potencial da Classificacao esta  Ё
	//Ё correto.                                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lRet .And. aCols[n][nPosM1Pot] > aCols[n][nPosM2Pot]
      Aviso(STR0016,STR0020,{'OK'})
		lRet := .F.
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Compara os Percentuais com a Classificacao Anterior.         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nAnt := n - 1

	If nAnt >= 1 .And. !aCols[nAnt][nUsado + 1]
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o Percentual de PDVs da Classificacao esta corre-Ё
		//Ё to com o Percentual da Classificacao anterior.               Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lRet .And. aCols[n][nPosM1PDV] <= aCols[nAnt][nPosM2PDV]
         Aviso(STR0016,STR0021,{'OK'})			
			lRet := .F.
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o Percentual de Potencial da Classificacao esta  Ё
		//Ё correto com o Percentual da Classificacao anterior.          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lRet .And. aCols[n][nPosM1Pot] <= Acols[nAnt][nPosM2Pot]
         Aviso(STR0016,STR0022,{'OK'})			
			lRet := .F.
		EndIf
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Compara os Percentuais com a Classificacao Posterior.        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPos := n + 1

	If nPos <= Len(aCols) .And. !aCols[nPos][nUsado + 1]
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o Percentual de PDVs da Classificacao esta corre-Ё
		//Ё to com o Percentual da Classificacao posterior.              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lRet .And. aCols[n][nPosM2PDV] >= aCols[nPos][nPosM1PDV]
         Aviso(STR0016,STR0023,{'OK'})
         lRet := .F.
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o Percentual de Potencial da Classificacao esta  Ё
		//Ё correto com o Percentual da Classificacao posterior.         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lRet .And. aCols[n][nPosM2Pot] >= Acols[nPos][nPosM1Pot]
          Aviso(STR0016,STR0024,{'OK'})
			lRet := .F.
		EndIf
	EndIf
EndIf

Return(lRet)
