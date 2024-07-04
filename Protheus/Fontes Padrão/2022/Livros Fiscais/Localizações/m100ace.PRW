#include "SIGAWIN.CH"
#DEFINE _NOMEIMP   01 //xRet
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IVAFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _QUANTITY  1 //aItemInfo
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
±±³Fun‡…o	 ³ M100ACE	³ Autor ³ Jose Novaes Romeu    ³ Data ³ 18.06.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO DO IMPOSTO DO OLEO (ACEITE) PARA PORTO RICO         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Localizacoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M100ACE(cCalculo,nItem,aInfo)

Local cTipo,cEstFis
Local nAliqIVA
Local aArea		:= GetArea()
Local aItemINFO
Local xRet
Local lXFis,cArq,cCpo,nFator,nOrdArq

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If !lXFis
	aItemINFO:=ParamIxb[1]
	xRet:=ParamIxb[2]
Else
	xRet:=0
Endif

If cModulo$'FAT|LOJA|FRT|TMK'
	cTipo      := SA1->A1_TIPO
	cEstFis    := SA1->A1_EST
	If cModulo=="FRT"
		cArq:="SBI"
		cCpo:="BI_CONVACE"
	Else
		cArq:="SB1"
		cCpo:="B1_CONVACE"
	Endif
Else
	cTipo      := SA2->A2_TIPO
	cEstFis    := SA2->A2_EST
	cArq:="SB1"
	cCpo:="B1_CONVACE"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No calculo do imposto eh necessario dividir a base de calculo por 42 pois ³
//³ a unidade de medida para o calculo do imposto eh o barril.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lXFis
	nAliqIVA:= SFB->FB_ALIQ
	nFator:=1
	DbSelectArea(cArq)
	If FieldPos(cCpo)>0
		If !Empty(&cCpo)
			nFator:=&cCpo
		Endif
	Endif
	xRet[_BASECALC]	:= Round((aItemInfo[_QUANTITY] * nFator) / 42,2)
	xRet[_IMPUESTO]	:= Round(xRet[_BASECALC] * nAliqIVA,2)
Else
	Do Case
		Case cCalculo=="A"
			SFB->(DBseek(xFilial("SFB")+aInfo[X_IMPOSTO]))
			xRet:=SFB->FB_ALIQ
		Case cCalculo=="B"
			xRet:=1
			DbSelectArea(cArq)
			nOrdArq:=IndexOrd()
			DbSetOrder(1)
			DbSeek(xFilial(cArq)+MaFisRet(nItem,"IT_PRODUTO"))
			If FieldPos(cCpo)>0
				If !Empty(&cCpo)
					xRet:=&cCpo
				Endif
			Endif
			DbSetOrder(nOrdArq)
			xRet:=((MaFisRet(nItem,"IT_QUANT") * xRet)/42)
		Case cCalculo=="V"
			nAliqIVA:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			xRet:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			xRet:=(nAliqIVA * xRet)
	EndCase
Endif

RestArea(aArea)
Return( xRet )