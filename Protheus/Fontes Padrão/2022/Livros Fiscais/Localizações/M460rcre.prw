#INCLUDE "PROTHEUS.CH"
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M460RCRE ³ Autor ³ Ricardo Berti		    ³ Data ³22/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa que Calcula Retencao CREE 						  ³±±
±±³          ³ SFF: Mesmo mecanismo de Ret.ICA, mas sem Municipio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M460RCRE                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Retencao de CREE (COL)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460RCRE(cCalculo,nItem,aInfo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nDesconto	:= 0,lXFis,xRet,cImp
Local nAliqSFB	:= 0
Local nImporte	:= 0
Local cCatCliFor:= ""
Local cCodIca	:= ""
Local aImpRef	:= {}
Local aImpVal	:= {}
Local nI		:=1


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
	//cCFO := SF4->F4_CF
	//cTes := SF4->F4_CODIGO 
Else
	xRet:=0
	//cCFO:= MaFisRet(nItem,"IT_CF")
	//cTes:= MaFisRet(nItem,"IT_TES")
	cImp:= aInfo[X_IMPOSTO]
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

//Verifica na SFF se existe ZonFis correspondente para:
// * Calculo de Imposto;
// * Obtencao de Aliquota;
// * Faixa de Imposto De/Ate.

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
		//Tira os descontos se for pelo liquido
		If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
			nDesconto	:=	xRet[18]
		Else
			nDesconto	:=	0
		Endif
		
		xRet[02]  := nAliq // Alicuota de Zona Fiscal
		xRet[03]  := (aItemINFO[3] - nDesconto) 

		
		xRet[04]  := round(xRet[03] * ( xRet[02]/100) ,2)
		
		If nImporte > 0 .And. xRet[04] >= nImporte
			xRet[04]  := xRet[04] 
		Else
			xRet[04]  := 0
		EndIf
	Else
		Do Case
			Case cCalculo=="B"
				nOrdSFC:=(SFC->(IndexOrd()))
				nRegSFC:=(SFC->(Recno()))
		
				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
					//Tira os descontos se for pelo liquido
					cImpIncid:=Alltrim(SFC->FC_INCIMP)
					If SFC->FC_LIQUIDO=="S"
						xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif
				Endif
				//+---------------------------------------------------------------+
				//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
				//+---------------------------------------------------------------+
				If !Empty(cImpIncid)
					aImpRef:=MaFisRet(nItem,"IT_DESCIV")
					aImpVal:=MaFisRet(nItem,"IT_VALIMP")
					For nI:=1 to Len(aImpRef)
						If !Empty(aImpRef[nI])
							IF Trim(aImpRef[nI][1])$cImpIncid
								xRet+=aImpVal[nI]
							Endif
						Endif
					Next
				Else
					xRet+=If(SFC->FC_CALCULO=="T",MaFisRet(,"NF_VALMERC"),MaFisRet(nItem,"IT_VALMERC"))
				Endif
				SFC->(DbSetOrder(nOrdSFC))
				SFC->(DbGoto(nRegSFC))

			Case cCalculo=="A"
				xRet:=nAliq

			Case cCalculo=="V"         
			
				nOrdSFC:=(SFC->(IndexOrd()))
				nRegSFC:=(SFC->(Recno()))
				SFC->(DbSetOrder(2))
				nVal	:= 0
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
					nVal:=0
					If SFC->FC_CALCULO=="T"
						
						nBase:=MaFisRet(,"NF_BASEIV"+aInfo[X_NUMIMP])+MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
						nVal:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),.T.) - nBase
					Else
						nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
						nVal	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
					Endif
				Endif
				
				SFC->(DbSetOrder(nOrdSFC))
				SFC->(DbGoto(nRegSFC))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o imposto somente se o valor da base for maior ou igual a base minima    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nVal >= nImporte
					xRet:=nBase * ( nAliq/100)
				Else
					xRet:= 0
				EndIf
		EndCase
	EndIf
EndIf
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )   
