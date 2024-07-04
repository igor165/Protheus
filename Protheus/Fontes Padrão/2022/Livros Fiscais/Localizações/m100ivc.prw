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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa  �   M100IVC  � Autor �  Nilton (Onsten)� Data �   16/06/10  ���
�������������������������������������������������������������������������͹��
���                 Programa que calcula o IVC (IVA Incluido)             ���
�������������������������������������������������������������������������͹��
��� Sintaxe   � M100IVC                                                   ���
�������������������������������������������������������������������������͹��
��� Parametros�                                       			           ���
���         1 � cCalculo                                                  ���
���         2 � nItem                                                     ���
���         3 � aInfo                                                     ���
�������������������������������������������������������������������������͹��
��� Retorno   � aImposto                                                  ���
�������������������������������������������������������������������������͹��
��� Uso       � MATA10x, LOJA010 e LOJA220, chamado pelo ponto de entrada ���
�������������������������������������������������������������������������͹��
���         Atualizacoes efetuadas desde a codificacao inicial            ���
�������������������������������������������������������������������������͹��
���Programador� Data   � BOPS �  Motivo da Alteracao                      ���
�������������������������������������������������������������������������͹��
���           �        �      �                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M100IVC(cCalculo,nItem,aInfo)

LOCAL cFunc
LOCAL aRet,lXFis
LOCAL aArea
LOCAL aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")

aArea 	:= GetArea()
aCountry := GetCountryList()
cFunct	:= "M100IVC" + aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3]  // retorna pais com 2 letras

aRet		:= &( cFunct )(cCalculo,nItem,aInfo,lXFis)

RestArea( aArea )

RETURN aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M100IVCEQ �Autor  � Nilton (Onsten)   � Data �  11/06/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do Imposto IVA - Entrada - Localizacao Equador      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���   	         �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M100IVCEQ(cCalculo,nItem,aInfo,lXFis)

Local nAliq := 0
Local nBase,cImp,xRet,nOrdSFC,nRegSFC,cVerIva
SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,LRET")
SetPrvt("CCODPROD,LRET,NBASE,CQUALI,CPROD")

cTipo := Iif( Type("cTipo")=="U","N",cTipo)

lRet := .T.
nBase := 0  


If !lXFis
	aItemINFO := ParamIxb[1]
	aImposto  := ParamIxb[2]
	xRet      := aImposto
	cImp      := aImposto[1]
	cProd     := aImposto[16]
Else
    xRet:=0
    cImp:=aInfo[X_IMPOSTO]
    cProd:=MaFisRet(nItem,"IT_PRODUTO")   
    SF4->(DbSeek(MaFisRet(nItem,"IT_TES")))
Endif     

//�����������������������������������������������������������������������Ŀ
//�Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-�
//�ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) �
//�������������������������������������������������������������������������
/*If cTipo = "D"   // devolucao de venda 
	cTipoCli   := SA1->A1_TIPO
	cZonfis    := SA1->A1_EST
Else
	cTipoForn  := SA2->A2_TIPO
	cZonFis    := SA2->A2_EST
Endif */

dbSelectArea("SF4")
If lXFis
   SF4->(DbSeek(xFilial("SF4")+MaFisRet(nItem,"IT_TES")))
Endif   
cCFO    := Alltrim(SF4->F4_CF)
cVerIVA := SF4->F4_CALCIVA
//TES nao calcula IVA
If cVerIva == "2" .or. cVerIva == "3"
   lRet := .F.
   Return ( xRet )                                            
endif

If lRet     
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+cImp)

   		//+---------------------------------------------------------------+
   		//� Verifica a Al�quota                                           �
   		//+---------------------------------------------------------------+		   
		If IIf(lXFis,cCalculo$"BA",.T.)
			nAliq := 0
			nBase := 1
			If nAliq == 0
				nAliq := SB1->B1_ALQIVA
			EndIf 		
			If nAliq == 0
				nAliq := SFB->FB_ALIQ
			EndIf  
			If cVerIva == "4"
			   nAliq := 0
			endif			
		EndIf

	    If !lXFis
			dbSelectArea("SFC")
			dbSetOrder(2)
			aImposto[_ALIQUOTA]  := nAliq // Alicuota de Zona Fiscal
			aImposto[_BASECALC]  := round (aItemINFO[_VLRTOTAL] / (1+(nAliq / 100)),2) * nBase // + aItemINFO[_FLETE] + aItemINFO[_GASTOS] - aItemINFO[9])* nBase // Base de C�lculo
		   //Tira os descontos se for pelo liquido 
		   If Subs(aImposto[5],4,1) == "S"  .And. Len(aImposto) >= 18 .And. ValType(aImposto[18])=="N"
			  aImposto[_BASECALC]	-=	aImposto[18]
		   Endif
		   	   //+---------------------------------------------------------------+
			   //� Efectua el C�lculo del Impuesto                               �
			   //+---------------------------------------------------------------+
		   aImposto[_IMPUESTO]  := aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100)
		   xRet:=aImposto
		Else
		    Do Case
		       Case cCalculo=="A"
		            xRet:=nAliq 
		       Case cCalculo=="B"
		       
					dbSelectArea("SFC")
					dbSetOrder(2)
//						If FunName() $ "MATA121" 
//							If cTpFrete == "C-CIF"
//								xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")
//							Else
//								xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")
//							EndIf
//						Else
		            		xRet:= Round(MaFisRet(nItem,"IT_VALMERC") / (1+(nAliq / 100)),2) //+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")) * nBase
//						EndIf
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
//					EndIf
		       Case cCalculo=="V"
		            nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
		            nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
					dbSelectArea("SFC")
					dbSetOrder(2)
		            xRet:=nBase * (nAliq/100) 
		    EndCase
	    EndIf
	EndIf       
Endif
Return( xRet )
