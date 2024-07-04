#include "SIGAWIN.CH"

//Constantes utilizadas nas localizacoes
 #DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _IVAFLETE  12
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³¦¦Funçào    ³M460IGI	  ³ Autor ³ Bruno Schmidt	       ³ Data ³ 06/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Descriçào ³ Programa que Calcula o IGV Incluido (Peru)            		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Uso       ³ MATA468/mata467, chamado pela tes                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IGI(cCalculo, nItem, aInfo)
Local nOrdSFC	:= 0
Local nRegSFC	:= 0
Local nImp		:= 0
Local nBase		:= 0
Local nAliq		:= 0
Local nDecs		:= 0
Local nCols		:= 0
Local xRet		:= 0
Local cImp		:= ""
Local aImp      := {}
Local lXFis		:= .F.
Local nRegFIE   := 0 
Local lRegFie   := Type("aRegFIE") <> "U"

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")

If !lXfis
	aItem := ParamIxb[1]
	aImp  := ParamIxb[2]
	cImp  := aImp[1]
	xRet  := aImp
Else
	cImp  := aInfo[1]
	nCols := nItem
	xRet  := 0
Endif


DbSelectArea("SFB")
DbSetOrder(1)
If Dbseek(xfilial()+cImp)
	nAliq:=SFB->FB_ALIQ
Endif	
	
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

If !lXFis
	nBase    := aItem[3]+aItem[4]+aItem[5]
	aImp[02] := nAliq
	aImp[03] := nBase
	
	//Tira os descontos se for pelo liquido.
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		aImp[3]	-= aImp[18]
		nBase	:= aImp[3]
	EndIf
	
	If lRegFie .and. Len(aRegFIE) > 0
		nRegFIE := 1
		aImp[3] := Round(aImp[3] - aRegFIE[nRegFIE][10][nItReg] * aImp[3],nDecs) 
		nBase := aImp[3]
	EndIf	
	
	aImp[4] := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)
	aImp[03]:= aImp[03]- aImp[04]
	   
	xRet:=aImp
Else
	nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
	
	If cPaisLoc == "PER" .And. SD2->(FieldPos("D2_VALADI")) > 0
		xRet -= MaFisRet(nItem,"IT_ADIANT")
	EndIf
	If GetNewPar('MV_DESCSAI','1')=='1'
		nBase += MaFisRet(nItem,"IT_DESCONTO")
	Endif
	
	//Tira os descontos se for pelo liquido
	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))
	
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
		If SFC->FC_LIQUIDO=="S"
			nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))			
		Endif
	Endif
	
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))

	nImp := nBase - Round(nBase/(1+(nAliq/100)),nDecs)
	nBase -= nImp
	
	Do Case
	Case cCalculo=="B"
		xRet:=nBase
	Case cCalculo=="A"
		xRet:=nALiq
	Case cCalculo=="V"
		xRet:=nImp
	EndCase
EndIf

Return( xRet )
