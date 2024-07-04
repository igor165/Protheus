#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE _NOMEIMP   01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M460CREE ³ Autor ³ Ricardo Berti		    ³ Data ³22/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa que Calcula CREE - Imposto Renta p/ la Equidad    ³±±
±±³          ³ SFF: Mesmo mecanismo do ICA, mas sem Municipio			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M460CREE                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Calculo de CREE (COL)                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460CREE(cCalculo,nItem,aInfo)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nDesconto	:=	0,lXFis,xRet,cImp
	Local nAliqSFB	:= 0
	Local nImporte	:= 0
	Local cCatCliFor:= ""
	Local cCodIca	:= ""
	Local nMoedSFF  := 1
	Local nTaxaMoed	:= 0
	Local nMoedaOri := 1
	
	SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,xRet,_CPROCNAME,_CZONCLSIGA")
	SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
	SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,LRET")
	SetPrvt("CMVAGENTE,NBASE")

	lXfis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
	lRet := .T.

	cAliasRot  := Alias()
	cOrdemRot  := IndexOrd()
	
	If !LXFis
		aItemINFO  := ParamIxb[1]
		xRet   := ParamIxb[2]
		cImp:=xRet[1]
	Else
		xRet:=0
		cImp:=aInfo[X_IMPOSTO]
	Endif
	
	If cModulo == 'FAT'
		cTipoCliFor:= SA1->A1_TPESSOA
		cZonfis    := SM0->M0_ESTENT
		cCodICA    := SA1->A1_ATIVIDA
		cCatCliFor := SA1->A1_TIPO
	Else
		cTipoCliFor:= SA2->A2_TPESSOA
		cZonFis    := SA2->A2_EST
		cCodICA    := SA2->A2_CODICA
		cCatCliFor := SA2->A2_TIPO
	Endif

	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+cImp)
		If If(!lXFis,.T.,cCalculo$"AB")
			nAliqSFB   := SFB->FB_ALIQ // Aliquota padrão
		EndIf
	EndIf	

	If lRet
		If Empty(cCodIca)
			nAliq   := nAliqSFB  // Aliquota padrão
		Else
			dbSelectArea("SFF")
			dbSetOrder(10)
			If dbseek(xFilial("SFF")+cImp)
				While !Eof() .And. SFF->(FF_IMPOSTO) == cImp
					If SFF->FF_COD_TAB == cCodICA
						If FF_FLAG != "1"
							RecLock("SFF",.F.)
							Replace FF_FLAG With "1"
						Endif
						nAliq   := SFF->FF_ALIQ  // Alicuota de Zona Fiscal
						nImporte:= SFF->FF_IMPORTE
						nMoedSFF := SFF->FF_MOEDA
						lRet 	:= .T.
						Exit
					Else
						lRet := .F.
					EndIf
					dbSkip()
				EndDo
			Else
				lRet := .F.
			EndIf
			If !lRet	
				nAliq   := nAliqSFB // Aliquota padrão
				lRet    := .T.
			EndIf
		EndIf

			If !lXFis
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o imposto somente se o valor da base for maior ou igual a base minima    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nImporte > 0 .And. (aItemINFO[3]) < nImporte
					nAliq := 0
				EndIf
				//Tira os descontos se for pelo liquido
				If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
					nDesconto	:=	xRet[18]
				Else
					nDesconto	:=	0
				Endif
				
				xRet[02]  := nAliq // Alicuota de Zona Fiscal
				xRet[03]  := (aItemINFO[3] - nDesconto)  
				xRet[04]  := round(xRet[03] * ( xRet[02]/100) ,2)
				
				nMoedaOri:= IIf(Type("lPedidos")	<> "U" .And. lPedidos , SC5->C5_MOEDA ,Max(SF2->F2_MOEDA,1))
				If xMoeda(xRet[04],nMoedaOri ,1) >= xMoeda(nImporte,nMoedSFF,1)
					xRet[04]  := xRet[04] 
				Else
					xRet[04]  := 0
				EndIf
			Else
				Do Case
					Case cCalculo=="B"
						xRet:= 0
						If GetNewPar('MV_DESCSAI','1')=='1' 
							xRet	+= MaFisRet(nItem,"IT_DESCONTO")
						Endif
						//Tira os descontos se for pelo liquido
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							If SFC->FC_LIQUIDO=="S"
								xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
							Endif
						Endif
						xRet+= MaFisRet(nItem,"IT_VALMERC")
					Case cCalculo=="A"
						xRet:=nAliq
					Case cCalculo=="V"
						If Type("M->F1_MOEDA")<>"U" 			   	
							nMoeda := M->F1_MOEDA
							nTaxaMoed := M->F1_TXMOEDA
						ElseIf Type("M->C7_MOEDA")<>"U"
							nMoeda := M->C7_MOEDA
						    nTaxaMoed := M->C7_TXMOEDA				
						ElseIf Type("M->F2_MOEDA")<>"U"
						   	nMoeda := M->F2_MOEDA
						    nTaxaMoed := M->F2_TXMOEDA				
						ElseIf Type("M->C5_MOEDA")<>"U" 
							nMoeda := M->C5_MOEDA
						    nTaxaMoed := M->C5_TXMOEDA	   
						Else
							nMoeda 		:= MAFISRET(,'NF_MOEDA')     
							nTaxaMoed 	:= MaFisRet(,'NF_TXMOEDA')			
						EndIf	        

						If nTaxaMoed==0
							nTaxaMoed:= RecMoeda(nMoeda)
						EndIf
						nVal:=0
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							If SFC->FC_CALCULO=="T"
								nBase:=MaFisRet(,"NF_BASEIV"+aInfo[X_NUMIMP])   
								nVal:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),) 
							Else
								nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])   
								nVal	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
							EndIf 
						Endif
					
						nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
												
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o imposto somente se o valor da base for maior ou igual a base minima    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If xMoeda(nVal,nMoeda,1,Nil,Nil,nTaxaMoed) > xMoeda(nImporte,nMoedSFF,1)
							xRet:=nVal * ( nAliq/100)
						Else
							xRet:= 0
						EndIf
				EndCase
			Endif
		EndIf
	dbSelectArea( cAliasRot )
	dbSetOrder( cOrdemRot )
Return( xRet )   
