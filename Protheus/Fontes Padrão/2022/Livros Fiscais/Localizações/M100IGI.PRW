#include "SIGAWIN.CH"

 //Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    1 //Nome do imposto
#DEFINE X_NUMIMP     2 //Sufixo do imposto


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M100IGV   ¦ Autor ¦ Bruno Schmidt          ¦ Data ¦ 06.03.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que Calcula IGV Incluido  (PERU)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA467/MATA468                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M100IGI(cCalculo,nItem,aInfo)

local aImp,aItem,cImp,xRet,nOrdSFC,nRegSFC,nImp
Local nBase:=0, nAliq:=0
Local nDecs
Local lTotal := .F.
Local lLiqui := .F.
Local nBaseAnt := 0
Local nMoeda	:=1
Local lXFis := .F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")

If !lXfis
   aItem:=ParamIxb[1]
   aImp:=ParamIxb[2]
   cImp:=aInfo[1]
Else
	cImp:=aInfo[1]
Endif           



DbSelectArea("SFB")    // busca a aliquota padrao
DbSetOrder(1)
If Dbseek(xFilial()+cImp)
   nAliq:=SFB->FB_ALIQ
Endif

If Type("M->F1_MOEDA")<>"U" 
	nMoeda:= M->F1_MOEDA      	      	
    ElseIf lXFis
	nMoeda := MAFISRET(,'NF_MOEDA')     
EndIf		

nDecs := MsDecimais(nMoeda)


If !lXFis
   nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
   nBase:=Round(nBase,nDecs)
   aImp[02]:=nAliq
   aImp[03]:=nBase

   //Tira os descontos se for pelo liquido .Bruno
   If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
	    aImp[3]	-=aImp[18]
	    nBase	:=aImp[3]
   Endif
   
   //+---------------------------------------------------------------+
   //¦ Efetua o Calculo do Imposto                                   ¦
   //+---------------------------------------------------------------+
   aImp[4] := aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)
   aImp[03]:= aImp[03]- aImp[04]
   
   xRet:=aImp
Else
   	
	nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
	nBase:=Round(nBase,nDecs)
	nBaseAnt := nBase
	
	If GetNewPar('MV_DESCSAI','1')=='1'
		nBase += MaFisRet(nItem,"IT_DESCONTO")
	Endif

   	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))

	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
	
		lTotal := (SFC->FC_CALCULO=="T")
		lLiqui := (SFC->FC_LIQUIDO=="S")
	EndIf
   	
   //Tira os descontos se for pelo liquido
   If lLiqui
		nBase-=MaFisRet(nItem,"IT_DESCONTO")
   Endif 
   
 	    
   //Imposto incluido (IVC) tem um tratamento especifico para obtencao da base
   nImp:=nBase-(nBase /(1+(nAliq/100)))
   nBase -= nImp
   nBase:=Round(nBase,nDecs)
   Do Case
      Case cCalculo=="B"
            xRet:=nBase
      Case cCalculo=="A"
            xRet:=nALiq
      Case cCalculo=="V"
      		If lTotal
				//Se o calculo eh pelo total, somo os valores ja lancados para a NF (relativo aos itens anteriores)
				nBase := nBaseAnt + MaFisRet(,"NF_VALMERC")+MaFisRet(,"NF_FRETE")+MaFisRet(,"NF_DESPESA")+MaFisRet(,"NF_SEGURO")
				If lLiqui
					nBase-=MaFisRet(nItem,"NF_DESCONTO")
				EndIf
				nImp:=nBase-(nBase /(1+(nAliq/100)))
			EndIf  
			xRet:= Round(nImp,nDecs)  
			
   EndCase
   SFC->(DbSetOrder(nOrdSFC))
   SFC->(DbGoto(nRegSFC))
Endif
	
Return( xRet )