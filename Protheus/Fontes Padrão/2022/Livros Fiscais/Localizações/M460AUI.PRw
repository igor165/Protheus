#include "SIGAWIN.CH"
#DEFINE _NOMEIMPOS 01
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M460AUI   ¦ Autor ¦ Ivan Haponczuk         ¦ Data ¦ 03.12.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que Calcula AUI   (COLOMBIA)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ COLOMBIA                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460AUI(cCalculo,nItem,aInfo)

Local nAliq := 0
Local nBase,cImp,xRet,nOrdSFC,nRegSFC
Local lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
Local cTipo 	:= Iif( Type("cTipo")=="U","N",cTipo)
SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,LRET")
SetPrvt("CCODPROD,LRET,NBASE,CQUALI,CPROD")

lRet := .T.
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
                    
If !lXFis
   aItemINFO:=ParamIxb[1]
   aImposto:=ParamIxb[2]
   xRet:=aImposto
   cProd:=aImposto[16]
   cImp:=aImposto[1]
Else
    xRet:=0
    cImp:=aInfo[X_IMPOSTO]
    cProd:=MafisRet(nItem,"IT_PRODUTO")
Endif

If cModulo == 'FAT|LOJA|TMK|FRT'
	cTipoCli   := SA1->A1_TIPO
	cZonfis    := SA1->A1_EST
Else
	cTipoForn  := SA2->A2_TIPO
	cZonfis    := SA2->A2_EST
Endif 

nBase := 0

// Busca o CFO do Tes Correspondente - SF4
dbSelectArea("SF4")
If lXFis
   SF4->(DbSeek(xFilial("SF4")+MaFisRet(nItem,"IT_TES")))
	cTipo:=MaFisRet(nItem,"NF_TIPONF")
Endif   
cCFO    := Alltrim(SF4->F4_CF)

If lRet
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+cImp)

		nAliq := SFB->FB_ALIQ
		nBase := 1
   
 	IF SA1->(FieldPos("A1_ALQAIU"))>0 .And. SA2->(FieldPos("A2_ALQAIU"))>0
		If  lXFis
		         If (MaFisRet(,"NF_CLIFOR" ) )== "C" 
		        		 nAliq := IIF(SA1->A1_ALQAIU>0,SA1->A1_ALQAIU,nAliq)
		         Else
		       		  	nAliq := IIF(SA2->A2_ALQAIU>0,SA2->A2_ALQAIU,nAliq)
		         
		         EndIf
		Else
		
			If cTipo = "C"   // devolucao de venda 
				nAliq := IIF(SA2->A2_ALQAIU>0,SA2->A2_ALQAIU,nAliq)
			Else
				nAliq := IIF(SA1->A1_ALQAIU>0,SA1->A1_ALQAIU,nAliq)
			Endif 
		
		EndIf
		 
	EndIf

   		//+---------------------------------------------------------------+
   		//¦ Efectua el Cálculo del Impuesto                               ¦
   		//+---------------------------------------------------------------+
		If !lXFis
			//Tira os descontos se for pelo liquido .Bruno
			If Subs(aImposto[5],4,1) == "S"  
				aImposto[_BASECALC]	:=	aImposto[18] * -1
			Endif
			aImposto[_ALIQUOTA] := nAliq
			aImposto[_BASECALC] += ( aItemINFO[3]) *  nBase // Base de Cálculo
			aImposto[_IMPUESTO] := round((aImposto[_BASECALC] * ( nAliq /100)) ,2)
			xRet := aImposto
		Else
			If cCalculo=="B"   
				If GetNewPar('MV_DESCSAI','1')=='1' .And. MaFisRet(,'NF_OPERNF')	== 'S'
					xRet += MaFisRet(nItem,"IT_DESCONTO")
				Endif
				//Tira os descontos se for pelo liquido
				nOrdSFC := (SFC->(IndexOrd()))
				nRegSFC := (SFC->(Recno()))
				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
					If SFC->FC_LIQUIDO=="S"
						xRet -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif   
				Endif   
				SFC->(DbSetOrder(nOrdSFC))
				SFC->(DbGoto(nRegSFC))
				xRet+=(MaFisRet(nItem,"IT_VALMERC")) * nBase 
			ElseIf cCalculo=="V"   
				nBase := MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				nAliq := MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
				xRet  := nBase * ( nAliq /100)
			ElseIf cCalculo=="A"
				xRet := nALiq
			EndIf
		EndIf       
	EndIf   
EndIf
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )