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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º   M460IVC  º Autor º  Nilton (Onsten)  Data º   16/06/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                 Programa que calcula o IVC (Base Origem M460IVAI)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º M460IVC                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº                                         			      º±±
±±º         1 º cCalculo                                                  º±±
±±º         2 º nItem                                                     º±±
±±º         3 º aInfo                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º aImposto                                                  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º MATA10x, LOJA010 e LOJA220, chamado pelo ponto de entrada º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramadorº Data   º BOPS º  Motivo da Alteracao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           º        º      º                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVC (cCalculo,nItem,aInfo)

LOCAL aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,
LOCAL cFunct
LOCAL aRet
LOCAL lXFis
LOCAL aArea := GetArea()

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

aCountry := GetCountryList()
cFunct	:= "M460IVC" + aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3] // retorna pais com 2 letras
aRet		:= &( cFunct )(cCalculo,nItem,aInfo,lXFis)

RestArea( aArea )

RETURN aRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460IVCEQ ºAutor  ³ Nilton (Onsten)    º Data ³  16/06/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³    Calculo de Imposto IVA incluido - Localizacao Equador   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460IVCEQ(cCalculo,nItem,aInfo,lXFis)

Local nAliq := 0
Local nBase,cImp,xRet,nOrdSFC,nRegSFC
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

//If cModulo == 'FAT|LOJA|TMK|FRT'
//	cTipoCli   := SA1->A1_TIPO
//	cZonfis    := SA1->A1_EST
//Else
//	cTipoForn  := SA2->A2_TIPO
///	cZonfis    := SA2->A2_EST
//Endif 

nBase := 0

// Busca o CFO do Tes Correspondente - SF4
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
Endif

If lRet
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+cImp)

   		//+---------------------------------------------------------------+
   		//¦ Verifica a Alíquota                                           ¦
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
			EndIf				
		EndIf
   
   		//+---------------------------------------------------------------+
   		//¦ Efectua el Cálculo del Impuesto                               ¦
   		//+---------------------------------------------------------------+
		If !lXFis
/*			If cCalculo == 'B'
				ValMerc:= MaFisRet(nItem,"IT_VALMERC")
				nDesc:=MaFisRet(nItem,"IT_DESCONTO")
				nBase:=ValMerc- nDesc 	
				xRet:=nBase
			Else
				If cCalculo == 'V'				
	            	ValMerc:= MaFisRet(nItem,"IT_VALMERC")
					nDesc:=MaFisRet(nItem,"IT_DESCONTO")
					nBase:=ValMerc - nDesc 	
	            	nValImp:=((nBase * nAliq)/100)
	            	xRet:=nValImp	
				ElseIf cCalculo == 'A'
					xRet:=nAliq
				EndIf				 	
			EndIf		
*/		
			dbSelectArea("SFC")
			dbSetOrder(2)
			SFC->(dbGoTop())
			If Subs(aImposto[5],4,1) == "S"  
				aImposto[_BASECALC]	:=	aImposto[18] * -1
			Endif
			aImposto[_ALIQUOTA] := nAliq
			aImposto[_BASECALC] += round (aItemINFO[3] / (1+(nAliq / 100)),2) * nBase  //+ aItemINFO[4] + aItemINFO[5] - SC5->C5_SEGURO ) * nBase

			aImposto[_IMPUESTO] := aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100)		
			xRet := aImposto
		Else
			If cCalculo=="B"
				xRet += MaFisRet(nItem,"IT_VALMERC")
				nOrdSFC := (SFC->(IndexOrd()))
				nRegSFC := (SFC->(Recno()))
				SFC->(DbSetOrder(2))
				SFC->(dbGoTop())
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
					If SFC->FC_LIQUIDO=="S"
						xRet -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif   
				Endif   
				SFC->(DbSetOrder(nOrdSFC))
				SFC->(DbGoto(nRegSFC))
//					If FunName() $ "MATA410"
// 						If M->C5_TPFRETE == "F"
//							xRet+=(MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")) * nBase
//						Else                                                                                                                                      
//							xRet+=(MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")) * nBase
//						EndIf
//					Else
						xRet:= Round(MaFisRet(nItem,"IT_VALMERC") / (1+(nAliq / 100)),2) //+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")) * nBase
//					EndIf
//				EndIf
			ElseIf cCalculo=="V"   
				nBase := MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				dbSelectArea("SFC")
				dbSetOrder(2)
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

