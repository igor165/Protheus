#include "SIGAWIN.CH"
#DEFINE _NOMEIMP   01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IVAFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M100ARB	³ Autor ³ Leonardo Ruben       ³ Data ³ 08.08.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO DO IMPOSTO DE ARBITRIO PARA PORTO RICO              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Localizacoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100ARB(cCalculo,nItem,aInfo)

Local lRet := .T.
Local cTipo, cEstFis, cCFO, cAgeRet

Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()

Local aItemINFO
Local xRet,lXfis

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If cModulo$'FAT|LOJA|FRT|TMK'
	cTipo      := SA1->A1_TIPO
	cEstFis    := SA1->A1_EST
	cAgeRet    := SA1->A1_RETIVA
Else
	cTipo      := SA2->A2_TIPO
	cEstFis    := SA2->A2_EST
	cAgeRet    := SA2->A2_RETIVA
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca o CFO do Tes Correspondente - SF4³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
cCFO := Alltrim(SF4->F4_CF)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e compra de importacao e se eh agente de retencao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (cTipo=="3") .And. (cAgeRet=="1")

If lRet
	If !lXFis
		aItemINFO  := ParamIxb[1]
		xRet   := ParamIxb[2]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aliquota por produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_AliqIva := SB1->B1_IPI
		xRet[_ALIQUOTA]  := _AliqIVA
		
		If lRet .And. _AliqIVA > 0  
			If Type("LGETFRETE")<>"U" .And. lGetFrete  // Frete imbutido na nota
				If nValFrete > 0   //Se frete informado abate o valor do frete da base de calculo
					xRet[_BASECALC]  := aItemINFO[_VLRTOTAL] - nValfrete + aItemINFO[_GASTOS]
				Else //Senao abate da base de calculo 1/11 do total da nota, conforme legislacao
					xRet[_BASECALC]  := aItemINFO[_VLRTOTAL] - Round((aItemINFO[_VLRTOTAL]/11),2) + aItemINFO[_GASTOS]
				EndIf
			Else //Frete nao imbutido na nota. Nesse caso nao afeta a base de calculo
				xRet[_BASECALC]  := aItemINFO[_VLRTOTAL] + aItemINFO[_GASTOS]
			Endif
			xRet[_IMPUESTO]  := Round(xRet[_BASECALC] * ( xRet[_ALIQUOTA]/100) ,2)
		Endif
	Else
		xRet:=0
		Do Case
			Case cCalculo   =="B"
				xRet  := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			Case cCalculo   =="A"
				xRet  := SB1->B1_IPI
			Case cCalculo   =="V"
				xRet  := MaFisRet(nItem,"IT_BASEIV"+aInfo[2])*MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])/100
		EndCase
	EndIf
Else
	xRet:=If(!lXFis,ParamIxb[2],0)
EndIf

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return xRet
