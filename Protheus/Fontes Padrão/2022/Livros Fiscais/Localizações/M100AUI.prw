#include "SIGAWIN.CH"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    1 //Nome do imposto
#DEFINE X_NUMIMP     2 //Sufixo do imposto


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
Function M100AUI(cCalculo,nItem,aInfo)
                                                     
Local nAliq := 0
Local xRet,cImp,nOrdSFC,nRegSFC
Local lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
Local cTipo 	:= Iif( Type("cTipo")=="U","N",cTipo)
SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,LRET")
SetPrvt("CCODPROD,LRET,NPOSFORN,NPOSLOJA,CPROD,CQUALI")

cTipo := Iif( Type("cTipo")=="U","N",cTipo)

lRet := .T.
nBase := 0

If !lXFis
   aItemINFO:=ParamIxb[1]
   aImposto :=ParamIxb[2]
   xRet	    :=aImposto
	cImp     :=aImposto[1]
   cProd := aImposto[16]
Else
    xRet:=0
    cImp:=aInfo[X_IMPOSTO]
    cProd:=MaFisRet(nItem,"IT_PRODUTO")   
    SF4->(DbSeek(MaFisRet(nItem,"IT_TES")))
Endif     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-³
//³ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo = "D"   // devolucao de venda 
	cTipoCli   := SA1->A1_TIPO
	cZonfis    := SA1->A1_EST
Else
	cTipoForn  := SA2->A2_TIPO
	cZonFis    := SA2->A2_EST
Endif

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
					nAliq := IIF(SA1->A1_ALQAIU>0,SA1->A1_ALQAIU,nAliq)
			Else
					nAliq := IIF(SA2->A2_ALQAIU>0,SA2->A2_ALQAIU,nAliq)
			Endif
		EndIf
	EndIf

	If !lXFis
		aImposto[_ALIQUOTA]  := nAliq // Alicuota de Zona Fiscal
		aImposto[_BASECALC]  := ( aItemINFO[_VLRTOTAL])* nBase // Base de Cálculo
	   //Tira os descontos se for pelo liquido .Bruno
	   	If Subs(aImposto[5],4,1) == "S"  .And. Len(aImposto) >= 18 .And. ValType(aImposto[18])=="N"
		  aImposto[_BASECALC]	-=	aImposto[18]
		Endif
	   	   //+---------------------------------------------------------------+
		   //¦ Efectua el Cálculo del Impuesto                               ¦
		   //+---------------------------------------------------------------+
		   aImposto[_IMPUESTO]  := aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100)
		   xRet:=aImposto
	Else
	    Do Case
	       Case cCalculo=="A"
	            xRet:=nAliq 
	       Case cCalculo=="B"
	            xRet:=MaFisRet(nItem,"IT_VALMERC")
	            xRet:=xRet*nBase
		    nOrdSFC:=(SFC->(IndexOrd()))
		    nRegSFC:=(SFC->(Recno()))
		    SFC->(DbSetOrder(2))
		    If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
		   //Tira os descontos se for pelo liquido
			   If SFC->FC_LIQUIDO=="S"
				  xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			   Endif
		    Endif
		    SFC->(DbSetOrder(nOrdSFC))
		    SFC->(DbGoto(nRegSFC))
		Case cCalculo=="V"
		    nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
		    nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
		    xRet:=nBase * (nAliq/100)
		EndCase
	    EndIf
	EndIf       
Endif
Return( xRet )