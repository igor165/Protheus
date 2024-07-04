#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IMPFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100RCRE ³ Autor ³ Ricardo Berti		    ³ Data ³22/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa que Calcula Retencao CREE 						  ³±±
±±³          ³ SFF: Mesmo mecanismo de Ret.ICA, mas sem Municipio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M100RCRE                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Retencao de CREE (COL)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M100RCRE(cCalculo,nItem,aInfo)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nDesconto	:=	0,xRet,lXFis,cImp,nBase,nAliq,nTotBase,nVRet
	Local nFaxDe,lRet, cGrpIRPF

	Local nVal			:=0 
	Local nAliqSFB		:= 0
	Local nImporte		:= 0
	Local cCatCliFor	:= ""
	Local cCodIca		:= ""
	
	SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,xRet,_CPROCNAME,_CZONCLSIGA")
	SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
	SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,LRET")
	SetPrvt("CMVAGENTE,NPOSLOJA,NPOSFORN")

	lRet 	:= .T.
	nBase	:= 0
	nAliq	:= 0
	nDesconto:= 0
	nVRet	:= 0
	cGrpIRPF:= ""
	aValRet := {0,0}

	lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
	// .T. - metodo de calculo utilizando a matxfis
	// .F. - metodo antigo de calculo
	cAliasRot  := Alias()
	cOrdemRot  := IndexOrd()
	
	If !lXFis
		aItemINFO  := ParamIxb[1]
		xRet   := ParamIxb[2]
		cImp:=xRet[1]
		//cTes:= MaFisRet(nItem,"IT_TES")	
	Else
		xRet:=0
		cImp:=aInfo[X_IMPOSTO]
		//SF4->(DbSeek(xFilial("SF4")+MaFisRet(nItem,"IT_TES")))
		//cTes := SF4->F4_CODIGO
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-³
	//³ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModulo$'COM|EST|EIC'
		cCatCliFor := SA2->A2_TIPO
		cTipoCliFor:= SA2->A2_TPESSOA
		cZonfis    := SA2->A2_EST
		cCodICA    := SA2->A2_CODICA
	Else
		cCatCliFor := SA1->A1_TIPO
		cTipoCliFor:= SA1->A1_TPESSOA
		cZonfis    := SM0->M0_ESTENT
		cCodICA    := SA1->A1_ATIVIDA
	Endif
	
	If lRet
		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+cImp)
			If If(!lXFis,.T.,cCalculo$"AB")
				nAliqSFB  := SFB->FB_ALIQ // Aliquota padrão
			EndIf
		EndIf
		
		//Verifica na SFF se existe CIIU correspondente para:
		// * Calculo de Imposto;
		// * Obtencao de Aliquota;
		// * Faixa de Imposto De/Ate.

		If If(!lXFis,.T.,cCalculo$"ABV")
			
			If Empty(cCodIca)
				nAliq   := nAliqSFB  // Aliquota padrão
				lRet    := .T.
			Else
				dbSelectArea("SFF")
				dbSetOrder(10)
				If dbseek(xFilial("SFF")+cImp)
					While !Eof() .And. SFF->(FF_IMPOSTO) == cImp
						If SFF->FF_COD_TAB == cCodICA
							If cCalculo == "V"
								nImporte := SFF->FF_IMPORTE               
								lRet:=.T.
							ElseIf cCalculo $ "BA" 							
								If FF_FLAG != "1" 
									RecLock("SFF",.F.)
									Replace FF_FLAG With "1"
									SFF->(MsUnlock())
								Endif
								nFaxde   := SFF->FF_FXDE
								//nMoedaSFF := SFF->FF_MOEDA
								nTotBase := nVal // xMoeda(nVal,nMoeda,1,Nil,Nil,nTaxaMoed)
								nAliq:=SFF->FF_ALIQ
								lRet := .T.
							Endif           
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
					nAliq   := nAliqSFB  // Aliquota padrão
					lRet    := .T.
				EndIf
			EndIf
		EndIf
		If lRet
			If !lXFis
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o imposto somente se o valor da base for maior ou igual a base minima    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//Tira os descontos se for pelo liquido
				If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
					nDesconto	:=	xRet[18]
				Else
					nDesconto	:=	0
				Endif
				xRet[02]  := nAliq // Alicuota de Zona Fiscal
				xRet[03]  := (aItemINFO[3]) 
				xRet[04]  := round(xRet[03] * ( xRet[02]/100) ,2)
			Else
				Do Case
					Case cCalculo=="A"
						xRet:=nAliq
					Case cCalculo=="B"
						xRet:= 0
						If GetNewPar('MV_DESCSAI','1')=='1' 
							xRet	+= MaFisRet(nItem,"IT_DESCONTO")
						Endif
						//Tira os descontos se for pelo liquido
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							If SFC->FC_LIQUIDO=="S"
								xRet-=MaFisRet(nItem,"IT_DESCONTO")
							Endif
						Endif
						xRet+= MaFisRet(nItem,"IT_VALMERC") //If(SFC->FC_CALCULO=="T",MaFisRet(,"NF_VALMERC")+MaFisRet(nItem,"IT_VALMERC"),MaFisRet(nItem,"IT_VALMERC"))

					Case cCalculo=="V"      
					
						nVal:=0
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							If SFC->FC_CALCULO=="T"
								nBase:= MaFisRet(nItem,'IT_BASEIV'+aInfo[2])  
								nVal:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),) 
							Else
								nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])   
								nVal	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
							EndIf 
						Endif
	
						nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])         
						If nVal >= nImporte
							xRet:=nVal * ( nAliq/100)
						Else
							xRet:= 0
						EndIf
					EndCase
			Endif
		Endif
	Endif
	dbSelectArea( cAliasRot )
	dbSetOrder( cOrdemRot )
Return( xRet ) 
