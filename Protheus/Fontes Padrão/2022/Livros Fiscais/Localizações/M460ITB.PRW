#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M460ITB  ³ Autor ³ Silvia Taguti         ³ Data ³ 18.06.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do imposto ITBIS - Saida                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Republica Dominicana                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ivan Haponczuk³07/04/11³      ³Relocalizacao da Republica dominicana    ³±±
±±³              ³        ³      ³para a versao P11.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460ITB(cCalculo,nItem,aInfo)

Local xRet
Local nI        := 0
Local nPos      := 0 
Local nAliq     := 0
Local nBase     := 0
Local nBasRed   := 0
Local aItem     := {}
Local aImpRef   := {}
Local aImpVal   := {}
Local cImp      := ""
Local cProduto  := ""
Local cEstado   := ""
Local cImpIncid := ""
Local lXFis     := .F.
Local lIsento   := .F.
Local aArea := GetArea()

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If !lXFis
	aItem     := ParamIxb[1]
	xRet      := ParamIxb[2]
	cImp      := xRet[1]
	cProduto  := xRet[16]
Else
	xRet      := 0
	cImp      := aInfo[1]
	cProduto  := MaFisRet(nItem,"IT_PRODUTO")
EndIf

//+------------------------------------+
//¦ Dados do cliente/fornecedor        ¦
//+------------------------------------+ 
If cModulo$"FAT|LOJA|TMK|FRT"
	cEstado := SA1->A1_EST
	nBasRed := ((100-SA1->A1_BASITB)/100)
Else
	cEstado := SA2->A2_EST
	nBasRed := ((100-SA2->A2_BASITB)/100)
Endif

//+------------------------------------+
//¦ Verifica se o produto e isento     ¦
//+------------------------------------+ 
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))
	lIsento := Iif(SB1->B1_ITBISEN=="1",.T.,.F.)
EndIf

If !lIsento .or. cEstado == "EX"

	If !lXFis .or. cCalculo=="A"
		//+------------------------------------+
		//¦ Aliquota padrao                    ¦
		//+------------------------------------+ 
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1))
		If SFB->(dbSeek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif

		//+------------------------------------+
		//¦ Aliquota zero para exportacoes     ¦
		//+------------------------------------+
		If cModulo$"FAT|LOJA|TMK|FRT" .and. cEstado == "EX"
			nAliq := 0
		EndIf
	EndIf
	
	If !lXFis
		nBase := aItem[3]+aItem[4]+aItem[5] //valor total + frete + outros impostos
		
		//+----------------------------------------------------------+
		//¦ Tira os descontos se for pelo liquido                    ¦
		//+----------------------------------------------------------+ 
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			nBase -= xRet[18]
		Endif
		
		//+----------------------------------------------------------+
		//¦ Soma a Base de Cálculo os Impostos Incidentes            ¦
		//+----------------------------------------------------------+ 
		cImpIncid := xRet[10]
		nPos := aScan( aItem[6],{|x| x[1] == AllTrim(cImpIncid) } )
		If nPos > 0
			nBase += aItem[6,nPos,4]
		Endif
	
		nBase := (nBase * nBasRed) //Base reduzida
		xRet[02]:= nAliq
		xRet[03]:= nBase
		xRet[04]:=(nAliq * nBase)/100
	Else
		Do Case
			Case cCalculo == "B"
				xRet := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
				If GetNewPar("MV_DESCSAI","1")=="1" .and. FunName() == "MATA410"
					xRet += MaFisRet(nItem,"IT_DESCONTO")
				Endif

				//+----------------------------------------------------------+
				//¦ Tira os descontos se for pelo liquido                    ¦
				//+----------------------------------------------------------+ 
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
					cImpIncid := Alltrim(SFC->FC_INCIMP)
					If SFC->FC_LIQUIDO == "S"
						xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif
				EndIf
				
   				//+---------------------------------------------------------------+
				//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
				//+---------------------------------------------------------------+
	            If !Empty(cImpIncid)
				   aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				   aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				   For nI:=1 to Len(aImpRef)
				       If !Empty(aImpRef[nI])
					      If AllTrim(aImpRef[nI][1])$cImpIncid
						     xRet += aImpVal[nI]
					      EndIf
					   EndIf   
				   Next	nI
	            EndIf
	            
				xRet := (xRet * nBasRed) //Base reduzida
			Case cCalculo == "A"
				xRet := nAliq
			Case cCalculo == "V"
				nAliq := MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
				nBase := MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
				xRet  := (nAliq * nBase)/100
		EndCase
	EndIf
EndIf

RestArea(aArea)
Return xRet
