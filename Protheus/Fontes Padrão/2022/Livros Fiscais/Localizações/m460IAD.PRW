#INCLUDE "Protheus.ch"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M460IAD ³ Autor ³ Camila Januario        ³ Data ³ 18.08.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do IAD - Imposto Adicional - Saídas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Chile                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IAD(cCalculo,nItem,aInfo)

Local nBase    := 0
Local nAliq    := 0 
Local cConcept := ""
Local cProduto := ""
Local aItem    := {}
Local lXFis    := .F.
Local aArea    := GetArea()

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If !lXFis
	aItem    := ParamIxb[1]
	xRet     := ParamIxb[2]
	cImp     := xRet[1]
	cProduto := xRet[16]
Else
	xRet     := 0
	cProduto := MaFisRet(nItem,"IT_PRODUTO")
	cImp     := aInfo[X_IMPOSTO]
EndIf

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))
	cConcept := SB1->B1_CONIAD
EndIf

If If(!lXFis,.T.,cCalculo=="A")	

	dbSelectArea("SFB")
	SFB->(dbSetOrder(1))
	If SFB->(dbSeek(xFilial("SFB")+cImp))
		nAliq := SFB->FB_ALIQ
	Endif
	
	dbSelectArea("CCR")
	CCR->(dbSetOrder(1))
	If CCR->(dbSeek(xFilial("CCR")+cConcept))
		If !Empty(CCR->CCR_ALIQ)
			nAliq := CCR->CCR_ALIQ
		EndIf
	EndIf
	
EndIf

If !Empty(cConcept)
	If !lXFis
		nBase:=aItem[3]+aItem[4]+aItem[5] //valor total + frete + outros impostos
		xRet[02]:=nAliq
		xRet[03]:=nBase
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			xRet[3]-=xRet[18]
			nBase:=xRet[3]
		Endif
		xRet[04]:=(nAliq * nBase)/100
	Else
		Do Case
			Case cCalculo=="B"			
				xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
				If GetNewPar("MV_DESCSAI","1")=="1" .and. FunName() == "MATA410"
					xRet += MaFisRet(nItem,"IT_DESCONTO")
				Endif			
			Case cCalculo=="A"
				xRet:=nALiq
			Case cCalculo=="V"
				dbSelectArea("CCR")
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				xRet:=(nAliq * nBase)/100
		EndCase
	EndIf
EndIf
RestArea(aArea)
Return xRet