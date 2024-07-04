/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M460IPS  ³ Autor ³ MARCELLO GABRIEL     ³ Data ³ 05.10.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO IESPS     (MEXICO)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
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
FUNCTION M460IPS(cCalculo,nItem,aInfo)
Local aItem,lXFis,cImp,xRet,nOrdSFC,nRegSFC,nOrdSFF,nRegSFF
Local nBase:=0,nAliq:=0,lALIQ:=.f.,lIsento:=.T.,cFil,cAux
Local cDbf:=alias(),nOrd:=IndexOrd()

dbSelectArea("SFF")
nOrdSFF:=IndexOrd()
nRegSFF:=Recno()
dbSetOrder(3)
cFil:=xfilial()
lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")

If !lXfis
	aItem:=ParamIxb[1]
	xRet:=ParamIxb[2]
	cImp:=xRet[1]
Else
	cImp:=aInfo[1]
	If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
		SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
	Else
		SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
	Endif
	xRet:=0
Endif

If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp:=Alltrim(SBI->BI_GRUPO)
Else
	cGrp:=Alltrim(SB1->B1_GRUPO)
Endif

if dbseek(cFil+cImp)
	while FF_IMPOSTO == cImp .and. FF_FILIAL == cFil .and. !lAliq
		cAux:=Alltrim(FF_GRUPO)
		if cAux!=""
			lAliq:=(cAux==cGrp)
		endif
		if lAliq
			if !Empty(FF_DTDE)
				lAliq:=(dDataBase>=FF_DTDE)
			Endif
			if !Empty(FF_DTATE)
				lAliq:=(dDataBase<=FF_DTATE) .And. lAliq
			endif
			if lAliq
				if !(lIsento:=(Upper(FF_TIPO)=="S"))
					nAliq:=FF_ALIQ
				endif
			endif    
		endif
		dbskip()
	enddo
endif
if !lIsento 
	if !lAliq .And. If(!lXFis,.T.,cCalculo=="A")
		dbselectarea("SFB")    // busca a aliquota padrao
		if dbseek(xfilial()+cImp)
			nAliq:=SFB->FB_ALIQ
		endif
	endif
	If !lXFis
		nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			nBase-=xRet[18]
		Endif
	Else
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
		//Tira os descontos se for pelo liquido
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			If SFC->FC_LIQUIDO=="S"
				nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
	Endif
endif
If !lXFis
	xRet[02]:=nAliq
	xRet[03]:=nBase
	xRet[04]:=(nAliq * nBase)/100
Else
	Do Case
		Case cCalculo=="B"
			xRet:=nBase
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
			xRet:=(nAliq * nBase)/100
	EndCase
Endif
SFF->(DbSetOrder(nOrdSFF))
SFF->(DbGoto(nRegSFF))
dbSelectarea(cDbf)
dbSetOrder(nOrd)
Return(xRet)
