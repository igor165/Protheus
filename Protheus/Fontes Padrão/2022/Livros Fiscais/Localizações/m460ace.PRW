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
±±³Funcao	 ³ M460ACE	³ Autor ³ Jose Novaes Romeu    ³ Data ³ 18.06.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ CALCULO DO IMPOSTO DO OLEO (ACEITE) PARA PORTO RICO         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Localizacoes                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460ACE(cCalculo,nItem,aInfo)

Local cTipo, cEstFis
Local aArea		:= GetArea()
Local cAliqIVA, cAliq
Local i			:= 1
Local aAliq		:= {"","",""}
Local aItemINFO
Local xRet,lXFis,cArq,cCpo,nFator,nOrdArq
Local nX		:= 0

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

If IIf(!lXFis,.T.,cCalculo=="A")
	cAliqIva := Alltrim(GetMV("MV_ACESAI"))
	For nX := 1 to Len(cAliqIva)
		cAliq := Subs(cAliqIVA,nX,1)
		If IsDigit(cAliq) .or. cAliq $ ".,"
			aAliq[i] +=	cAliq
		Else
			i ++
		EndIf
	Next
Endif
If !lXFis
	nFator:=1
	DbSelectArea(cArq)
	If FieldPos(cCpo)>0
		If !Empty(&cCpo)
			nFator:=&cCpo
		Endif
	Endif
	xRet[_BASECALC]	:=	Round(aItemInfo[_QUANTITY] * nFator, 2)
	xRet[_ALIQUOTA]	:=	IIf(xRet[_BASECALC]>Val(aAliq[1]),Val(aAliq[3]),Val(aAliq[2]))
	xRet[_IMPUESTO]	:=	Round(xRet[_BASECALC] * xRet[_ALIQUOTA],2)
Else
	If cCalculo$"AB"
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
		xRet:=(MaFisRet(nItem,"IT_QUANT") * xRet)
		If cCalculo=="A"
			xRet:=IIf(xRet>Val(aAliq[1]),Val(aAliq[3]),Val(aAliq[2]))
		Endif
	ElseIf cCalculo=="V"
		nX:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
		xRet:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
		xRet:=(nX * xRet)
	Endif
Endif

RestArea( aArea )
Return( xRet )
