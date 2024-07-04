#INCLUDE "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#INCLUDE "M460RIVA.CH"

#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO   01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVA  บAutor  ณJulio Cesar         บ Data ณ  19/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetencao de IVA                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ         Atualizacoes efetuadas desde a codificacao inicial            บฑฑ
ฑฑฬอออออออออออัออออออออัออออออัอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramadorณ Data   ณ BOPS ณ  Motivo da Alteracao                      บฑฑ
ฑฑฬอออออออออออุออออออออุออออออุอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบARodriguez ณ31/07/19ณDMINA-ณM460RIVAFCO() toma CFO de MaFisRet() COL	  บฑฑ
ฑฑบ           ณ        ณ  6748ณ											  บฑฑ
ฑฑศอออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function M460RIVA(cCalculo,nItem,aInfo)

LOCAL cFunct
LOCAL aRet
LOCAL lXFis
LOCAL aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,
LOCAL aArea 	:= GetArea()

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

aCountry:= GetCountryList()
cFunct	:= "M460RIVA" + aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3] // retorna pais com 2 letras
aRet	:= &( cFunct )(cCalculo,nItem,aInfo,lXFis)

RestArea( aArea )

RETURN aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVACOบAutor  ณDenis Martins       บ Data ณ  02/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao de IVA - Esse imposto e calculado sobre บฑฑ
ฑฑบ          ณo Imposto de Valor Agregado                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M460RIVACO(cCalculo,nItem,aInfo,lXFis)
Local xRet, nC
Local clAgen	:= GetMV("MV_AGENTE") 
Local llRetIVA	:= .T.
Local nCalcIVA := 0
Private _lxfis := lXFis

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CTIPOCLI,CTIPOFORN,CCFO")
SetPrvt("NC,NVLIMPOSTOIVA,LRET,CZONFIS,LRETCF,NIMPORTE")
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif
lRet := .F.
lRetCF := .T.
cZonFis := ""
nVlImpostoIVA := 0
nBase         := 0
nImporte 	:= 0

If !lXFis
	If cModulo$'FAT|LOJA|FRT|TMK|OMS|FIS'
		cTipoCliFor := SA1->A1_TPESSOA
		cTipoContr  := SA1->A1_CONTRBE
		cRetIVA	    := SA1->A1_RETIVA
	Else
		cTipoCliFor := SA2->A2_TPESSOA
		cTipoContr  := SA2->A2_CONTRBE
		cRetIVA	   := UPPER(SubStr(clAgen,1,1))
	Endif
Else               
	If MaFisRet(,"NF_CLIFOR") == "C"
		cTipoCliFor := SA1->A1_PESSOA
		cTipoContr  := SA1->A1_CONTRBE
		cRetIVA	    := SA1->A1_RETIVA
	Else
		cTipoCliFor := SA2->A2_PESSOA
		cTipoContr  := SA2->A2_CONTRBE
		cRetIVA	   := UPPER(SubStr(clAgen,1,1))
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico se e Agente de Retencaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cRetIVA == "S"
	lRet := .T.
	nVlImpostoIVA := 0
Endif
//Cliente /Fornecedor Tipo Persona Natural
/*If cTipoCliFor == "F"
	lRetCF := .F.
Else*/
	lRetCF := .T.
//Endif

If lRet .And. lRetCF
	If lXFis
		xRet:=M460RIVAFCO(cCalculo,nItem,aInfo)
	Else
		
		If cModulo$'COM'
			If !(SubStr(clAgen,1,1)$ "1|S")
				llRetIVA	:= .F.
			EndIf
		ElseIf cModulo$'FAT'
			If !(SA1->A1_AGENRET$ "1|S")
				llRetIVA	:= .F.
			EndIf
		EndIf
	    
		If llRetIVA     	
			dbSelectArea("SF4")
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Busca o CFO informado no PV - pode ter sido alt. devido o concepto  ณ
			//ณ                                                                     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Type("lPedidos")	<> "U" .And. lPedidos 
				cCFO := SC6->C6_CF 
			ElseIf Type("M->D2_CF")<>"U"
				cCFO := M->D2_CF
			Else
				cCFO := SD2->D2_CF
			EndIf
			//cCFO := Alltrim(SF4->F4_CF)
				
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณLocaliza o valor do imposto do IVAณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nC:=1 To Len(aImpVarSD2[6])
				If Substr(aImpVarSD2[6][nC][1],1,2) == "IV"
					nVlImpostoIVA += aImpVarSD2[6][nC][4] 
					nCalcIVA += aImpVarSD2[6][nC][3]
				Endif
			Next nC
			
			If SF4->F4_PRETIVA > 0
				aImposto[_ALIQUOTA] := SF4->F4_PRETIVA
			Else
				DbSelectArea("SFF")
				SFF->(DbSetOrder(6))
				SFF->(DbGoTop())
				If dbSeek(xFilial("SFF") + aImposto[1] + cCFO )
					aImposto[_ALIQUOTA] := SFF->FF_ALIQ
				Else
					dbSelectArea("SFB")
					dbSetOrder(1)
					If dbSeek(xFilial("SFB")+aImposto[1])
						If SFB->FB_TABELA == "N"
							If SFB->FB_FLAG != "1"
								RecLock("SFB",.F.)
								Replace FB_FLAG With "1"
							Endif
						EndIF
						aImposto[_ALIQUOTA] := SFB->FB_ALIQ
					EndIf
				EndIf
				
			EndIf
			
			aImposto[_BASECALC] := nVlImpostoIVA

				If (ValCond(nCalcIVA) >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1))
					aImposto[_IMPUESTO]  := round(aImposto[_BASECALC] *  aImposto[_ALIQUOTA]/100,2)
				EndIf
		EndIf

		xRet:=aImposto
	Endif
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAFCOบAutor  ณDenis Martins       บ Data ณ 17/02/2000  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao do Imposto X Tes - Entrada               บฑฑ
ฑฑบ          ณAlterado para o uso da funcao MATXFIS (Marcello)             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA460,MATA100                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M460RIVAFCO(cCalculo,nItem,aInfo)
Local nVlImpostoIVA,nBase,nAliq,nAux,nOrdSFC,nRegSFC,nVal,nTotBase,nVRet
Local nPos,cTes,cFil,nRegSFB,nPosCFO,cCFO
Local aRefImp
Local llRetIVA	:= .T.
Local cGrpIVA 	:= ""
Local clAgen	:= GetMV("MV_AGENTE")
Local nMoedSFF  := 1
Local nTaxaMoed	:= 0

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


nBase:=0
nAliq:=0
nVRet:=0

nVlImpostoIVA:=0 

	If cModulo$'COM'
		If !(SubStr(clAgen,1,1)$ "1|S")
			llRetIVA	:= .F.
		EndIf
	ElseIf cModulo$'FAT'
		If !(SA1->A1_AGENRET $ "1|S")
			llRetIVA	:= .F.
		EndIf
	EndIf
	    
	If llRetIVA
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ           Busca o CFO do Tes Correspondente - SF4                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cCFO := MaFisRet(nItem,"IT_CF")

		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
			DbSelectArea("SFF")
			SFF->(DbSetOrder(5))
			SFF->(DbGoTop())
			If cCalculo$"BA"
				If cCalculo=="B"				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณLocaliza o valor do imposto do IVAณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					DbSelectArea("SFC")
					nRegSFC:=Recno()
					nRegSFB:=SFB->(Recno())
					nOrdSFC:=IndexOrd()
					DbSetOrder(2)
					cTes:=MaFisRet(nItem,"IT_TES")
					aRefImp:=MaFisRelImp("MT100",{"SD2"})
					cFil:=xFilial("SFC")
					DbSeek(cFil+cTes+"IV")
					cAux:=Substr(FC_IMPOSTO,1,2) 					

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณFaz o tratamento do imposto calculado no item ou por total da notaณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					While FC_FILIAL==cFil .And. FC_TES==cTes .And. cAux=="IV"
						If FC_IMPOSTO<>aInfo[X_IMPOSTO]
							If (SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO)))
								nPos:=Ascan(aRefImp,{|x| x[2]=="D2_VALIMP"+SFB->FB_CPOLVRO})
								If nPos>0
									nVlImpostoIVA += MaFisRet(nItem,aRefImp[nPos,3])
								Endif
							Endif
						Endif
						
						DbSkip()
						cAux:=Substr(FC_IMPOSTO,1,2)
					Enddo
					DbSetOrder(nOrdSFC)
					DbGoto(nRegSFC)
					SFB->(DbGoto(nRegSFB))
					nBase:=nVlImpostoIVA 					

				Else                
					If SF4->F4_PRETIVA > 0
						nAliq := SF4->F4_PRETIVA
					Else
						dbSelectArea("SFB")
						dbSetOrder(1)
						If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
							If SFB->FB_TABELA=="N"
								If FB_FLAG != "1"
						 			RecLock("SFB",.F.)
									Replace FB_FLAG With "1"
								Endif
								nAliq:=SFB->FB_ALIQ
							EndIf
						Endif							
					EndIf
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica se tem alํquota por regiใo na SFFณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					DbSelectArea("SFF")
					SFF->(DbSetOrder(6))
					SFF->(DbGoTop())
					If DbSeek(xFilial("SFF")+AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO")+cCFO)
						nAliq := IIF(SFF->FF_ALIQ>0,SFF->FF_ALIQ,nAliq)
					Endif								
				Endif					
			Else
			
				//Tira os descontos se for pelo liquido
   				nOrdSFC:=(SFC->(IndexOrd()))
   				nRegSFC:=(SFC->(Recno()))
   				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))       
					If SFC->FC_LIQUIDO=="S"
						nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif
				Endif
				SFC->(DbSetOrder(2))
				SFC->(DbGoto(nRegSFC)) 
				
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
					If SFC->FC_CALCULO=="T"
				      If MaFisRet(,'NF_BASEIV'+aInfo[2])+ MaFisRet(nItem,'IT_BASEIV'+ aInfo[2]) > MaFisRet(,"NF_MINIV"+aInfo[2])
			  		      nVlImpostoIVA		:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2])) 
			  			Endif
			         ELSE
				        If MaFisRet(nItem,'IT_BASEIV'+aInfo[2]) >   MaFisRet(,"NF_MINIV"+aInfo[2])
			  		      	nVlImpostoIVA	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])   
			  			Endif
					Endif
				Endif 
				nBase := nVlImpostoIVA

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica se tem alํquota por regiใo na SFFณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				SFF->(DbSetOrder(6))
				SFF->(DbGoTop())
				If SFF->(DbSeek(xFilial("SFF")+AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO")+cCFO))
					nImporte := SFF->FF_IMPORTE
					nMoedSFF := SFF->FF_MOEDA		
				Endif	
				lRet:=.T.
			Endif
		Endif
	EndIf	
	If lRet .And. llRetIVA	
			Do Case
				Case cCalculo=="A"
					nVRet:=nAliq 
				Case cCalculo=="B"
					nVRet:=nBase 
				Case cCalculo=="V"			
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
					If SFC->FC_CALCULO=="T"
				        nBaseTot	:= MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),.T.)
			  		ELSE
				       	nBaseTot	:=  (MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO")+MaFisRet(nItem,"IT_DESPESA"))  
					Endif

					If xMoeda(nBaseTot,nMoeda,1,Nil,Nil,nTaxaMoed) > xMoeda(nImporte,nMoedSFF,1)		
					//If nBaseTot > nImporte
						nVRet:=round(nBase * (nAliq/100),2)
					Else
						nVRet:=0
					Endif		
			EndCase

	Endif                               
Return(nVRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAPAบAutor  ณJulio Cesar         บ Data ณ  19/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao de IVA - Esse imposto e calculado sobre บฑฑ
ฑฑบ          ณo Imposto de Valor Agregado                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณParaguay                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                

Function M460RIVAPA(cCalculo,nItem,aInfo,lXFis)
Local xRet,nIVAItem := 0  
Local nMoeda, nE 
SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CTIPOCLI,CTIPOFORN,CCFO")
SetPrvt("NC,NVLIMPOSTOIVA,CZONFIS,LRETCF,CRETIVA")

cAliasRot   := Alias()
cOrdemRot   := IndexOrd()
cTipoCliFor := SA1->A1_TIPO
cRetIVA	    := SA1->A1_RETIVA
nMoeda  	:=	IIf(Type("nMoedaCor")=="U",1,nMoedaCor)  
If lxFis
	xRet := 0
Else
    xRet := ParamIxb[2]
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico se e Agente de Retencaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cRetIVA == "S" 
	If lXFis
		xRet:=M460RIVAFPA(cCalculo,nItem,aInfo,nMoeda)
	Else
		aItemINFO   := ParamIxb[1]
		aImposto    := ParamIxb[2]
		dbSelectArea("SFF")
		dbSetOrder(5)
		If dbSeek(xFilial("SFF")+aImposto[1])
			For nE := 1 To Len(aImpVarSD2[6])
				If (Substr(aImpVarSD2[6][nE][6],3,8) == "_VALIMP1")
					nIVAItem += aImpVarSD2[6][nE][4]
				Endif
			Next
			If nIVAItem > 0
	        	aImposto[_BASECALC] := (aItemINFO[3]+aItemINFO[4]+aItemInfo[5]) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)
	         	//Tira os descontos se for pelo liquido .Bruno
	        	If Subs(aImposto[5],4,1) == "S"  
	            	aImposto[_BASECALC] := (aItemINFO[3]+aItemINFO[4]+aItemInfo[5]-aImposto[18]) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)	
	         	Endif
	         	aImposto[_ALIQUOTA] := SFB->FB_ALIQ
				If  aItemINFO[3]+aItemINFO[4]+aItemInfo[5] > SFF->FF_IMPORTE
					aImposto[_IMPUESTO] := Round(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,MsDecimais(nMoeda))
				Endif
			Endif
		Endif
		xRet:=aImposto
	EndIf
Endif    

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAFPAบAutor  ณJulio Cesar         บ Data ณ 19/11/2001  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao do Imposto X Tes - Entrada               บฑฑ
ฑฑบ          ณPara o uso da funcao MATXFIS                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA460,MATA100                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M460RIVAFPA(cCalculo,nItem,aInfo,nMoeda)
Local nIVAItem,nBase,nAliq,nOrdSFC,nRegSFC,nOrdSFF,nRegSFF,nVRet,nDesconto
Local nPos,cTes,cFil,nRegSFB
Local aRefImp    
Local lRet 

nBase     := 0
nAliq     := 0
nVRet     := 0
nDesconto := 0
nIVAItem  := 0
lRet      := .T.

dbSelectArea("SFB")
dbSetOrder(1)
If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
	If cCalculo$"BA"
		If cCalculo=="B"
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณLocaliza o valor do imposto do IVAณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea("SFC")
			nRegSFC:=Recno()
			nRegSFB:=SFB->(Recno())
			nOrdSFC:=IndexOrd()
			DbSetOrder(2)
			cTes   :=MaFisRet(nItem,"IT_TES")
			aRefImp:=MaFisRelImp("MT100",{"SD1"})
			cFil   :=xFilial("SFC")
			If DbSeek(cFil+cTes+"IVA")
				If (SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO)))
					IF (nPos := Ascan(aRefImp,{|x| x[2]=="D1_VALIMP"+SFB->FB_CPOLVRO})) > 0
						nIVAItem += MaFisRet(nItem,aRefImp[nPos,3])
					Endif
				Endif
			Endif
			If nIVAItem > 0
				If DbSeek(cFil+cTes+aInfo[X_IMPOSTO])	
					nBase := (MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO")+;
				              MaFisRet(nItem,"IT_DESPESA")) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)
					If GetNewPar('MV_DESCSAI','1')=='1' .And. SFC->FC_LIQUIDO<>"S"
						nBase	+= MaFisRet(nItem,"IT_DESCONTO")
					Endif

					//Tira os descontos se for pelo liquido 	     
					If SFC->FC_LIQUIDO=="S" .And. GetNewPar('MV_DESCSAI','1')=='2'
						nDesconto := MaFisRet(nItem,"IT_DESCONTO") 
						nBase := (MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO") +;
				                  MaFisRet(nItem,"IT_DESPESA")-nDesconto) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)
					EndIf
				EndIf				            
			Endif
			DbSetOrder(nOrdSFC)
			DbGoto(nRegSFC)
			SFB->(DbGoto(nRegSFB))
		Else
			If Empty(SFB->FB_ALIQ)	
				MsgStop(OemToAnsi(STR0002))  //"Verifique a integridade do Arquivo de Impostos"
				lRet := .F.
			Else
				nAliq := SFB->FB_ALIQ
			EndIf
		Endif
	Endif
Endif
If lRet
	Do Case
		Case cCalculo=="A"
			nVRet:=nAliq
		Case cCalculo=="B"
			nVRet:=nBase
		Case cCalculo=="V"
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			DbSelectArea("SFF")
			nRegSFF:=Recno()
			nOrdSFF:=IndexOrd()
			DbSetOrder(5)     
			cFil   :=xFilial("SFF")
			If DbSeek(cFil+aInfo[X_IMPOSTO]) .and. (MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO")+;
			   MaFisRet(nItem,"IT_DESPESA") > SFF->FF_IMPORTE)
				nVRet:= Round(nBase * nAliq/100,MsDecimais(nMoeda))
			EndIf
			DbSetOrder(nOrdSFF)
			DbGoto(nRegSFF)
	EndCase
Endif

Return(nVRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAEQ บAutor  ณ Nilton (Onsten)   บ Data ณ  24/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao de IVA - Equador						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M460RIVAEQ (cCalculo,nItem,aInfo,lXFis)
Local xRet, nC
Local clAgen	:= GetMV("MV_AGENTE") 
Local llRetIVA	:= .T.

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CTIPOCLI,CTIPOFORN,CCFO")
SetPrvt("NC,NVLIMPOSTOIVA,LRET,CZONFIS,LRETCF")
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif
lRet := .F.
lRetCF := .T.
cZonFis := ""
nVlImpostoIVA := 0
nBase         := 0    

If lXFis
	xRet:=M460RIVAFEQ (cCalculo,nItem,aInfo)
Else
	If cModulo$'COM'
		If SubStr(clAgen,1,1) != "S"
			llRetIVA	:= .F.
		EndIf
	ElseIf cModulo$'FAT'
		If SA1->A1_AGENRET != '1'
			llRetIVA	:= .F.
		EndIf
	EndIf
	    
	If llRetIVA     	
		dbSelectArea("SF4")
		cCFO := Alltrim(SF4->F4_CF)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณLocaliza o valor do imposto do IVAณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nC:=1 To Len(aImpVarSD2[6])
			If Substr(aImpVarSD2[6][nC][1],1,2) == "IV"
				nVlImpostoIVA += aImpVarSD2[6][nC][4] 
			Endif
		Next nC
			
		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+aImposto[1])
			aImposto[_ALIQUOTA] := SFB->FB_ALIQ
			aImposto[_BASECALC] := nVlImpostoIVA
			aImposto[_IMPUESTO]  := round(aImposto[_BASECALC] *  aImposto[_ALIQUOTA]/100,2)	
		EndIf					
		xRet:=aImposto
	Endif
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAFEQ บAutor  ณ Nilton (Onsten)    บ Data ณ 23/06/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao do Imposto X Tes - Entrada (Equador)     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA460,MATA100                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M460RIVAFEQ (cCalculo,nItem,aInfo)
Local nVlImpostoIVA,nBase,nAliq,nAux,nOrdSFC,nRegSFC,nVal,nTotBase,nVRet
Local nPos,cTes,cFil,nRegSFB
Local aRefImp
Local llRetIVA	:= .T.
Local clAgen	:= GetMV("MV_AGENTE")


nBase:=0
nAliq:=0
nVRet:=0
nVlImpostoIVA:=0   
lret := .T.	

	If cModulo$'COM'
		If SubStr(clAgen,1,1) != "S"
			llRetIVA	:= .F.
		EndIf
	ElseIf cModulo$'FAT'
		If SA1->A1_AGENRET != '1'
			llRetIVA	:= .F.
		EndIf
	EndIf
	    
	If llRetIVA  
		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
			If cCalculo$"BA"
				If cCalculo=="B"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณLocaliza o valor do imposto do IVAณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		  		    DbSelectArea("SFC")
					nRegSFC:=Recno()
					nRegSFB:=SFB->(Recno())
					nOrdSFC:=IndexOrd()
					DbSetOrder(2)
					cTes:=MaFisRet(nItem,"IT_TES")
					aRefImp:=MaFisRelImp("MT100",{"SD2"})
					cFil:=xFilial("SFC")
					DbSeek(cFil+cTes+"IV")
					cAux:=Substr(FC_IMPOSTO,1,2)
					While FC_FILIAL==cFil .And. FC_TES==cTes .And. cAux=="IV"
					    If FC_IMPOSTO<>aInfo[X_IMPOSTO]
					       If (SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO)))
						      nPos:=Ascan(aRefImp,{|x| x[2]=="D2_VALIMP"+SFB->FB_CPOLVRO})
		 				      If nPos>0
							     nVlImpostoIVA += MaFisRet(nItem,aRefImp[nPos,3])
						      Endif
						   Endif   
						Endif   
					    DbSkip()
						cAux:=Substr(FC_IMPOSTO,1,2)
					Enddo
					DbSetOrder(nOrdSFC)
					DbGoto(nRegSFC)
					SFB->(DbGoto(nRegSFB))
				Endif       
				dbSelectArea("SFB")
				dbSetOrder(1)
				If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
					nAliq := SFB->FB_ALIQ
				EndIF
				nBase:=nVlImpostoIVA
			Else
				lRet:=.T.
			Endif                                           						
		Endif
	EndIf

	If lRet .And. llRetIVA
		Do Case
			Case cCalculo=="A"
				nVRet:=nAliq
			Case cCalculo=="B"
				nVRet:=nBase
			Case cCalculo=="V"
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				nVRet:=round(nBase * (nAliq/100),2)
		EndCase
	Endif
Return(nVRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAVE บAutor  ณ Ivan Hacponzuk     บ Data ณ 15/07/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao de IVA - Venezuela		               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Geral                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M460RIVAVE(clCalculo,nlItem,alInfo,llXFis)
	Local xlRet,nlC,cpAliasRot,cpOrdemRot
	Local clAgen	:= GetMV("MV_AGENTE")
	Local llRetIVA	:= .T.

	SetPrvt("cpAliasRot,cpOrdemRot,apImposto,npVlImpIVA,lpRet")

	cpAliasRot	:= Alias()
	cpOrdemRot	:= IndexOrd()

	If !llXFis
		apImposto := ParamIxb[2]
		xlRet := apImposto
	Else
		xlRet := 0
	EndIf

	lpRet := .F.
	npVlImpIVA := 0

	If llXFis
		xlRet := M460RIVAFVE(clCalculo,nlItem,alInfo)
	Else
		If cModulo $ 'COM'
			If SubStr(clAgen,1,1) != "S"
				llRetIVA := .F.
			EndIf
		ElseIf cModulo $ 'FAT'
			If SA1->A1_AGENRET != '1'
				llRetIVA := .F.
			EndIf
		EndIf
		If llRetIVA
			DBSelectArea("SF4")
			cpCFO := Alltrim(SF4->F4_CF)
			For nlC:=1 to Len(aImpVarSD2[6])
				If SubStr(aImpVarSD2[6][nlC][1],1,2) == "IV"
					npVlImpIVA += aImpVarSD2[6][nlC][4]
				EndIf
			Next nlC
			DBSelectArea("SFB")
			DBSetOrder(1)
			If DBSeek(xFilial("SFB") + apImposto[1])
				apImposto[_ALIQUOTA] := SFB->FB_ALIQ
				apImposto[_BASECALC] := npVlImpIVA
				nValImp:=Round(apImposto[_BASECALC] *  apImposto[_ALIQUOTA] / 100,2)
				
				If nValImp >= Round(SFB->FB_MINRET,2)
					apImposto[_IMPUESTO] := Round(apImposto[_BASECALC] *  apImposto[_ALIQUOTA] / 100,2)
				EndIf
			EndIf
			xlRet := apImposto
		EndIf
	EndIf
	DBSelectArea(cpAliasRot)
	DBSetOrder(cpOrdemRot)
Return(xlRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAFVE บAutor  ณ Ivan Hacponzuk    บ Data ณ 23/06/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao do Imposto X Tes - Entrada (Venezuela)   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA460,MATA100                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M460RIVAFVE(clCalculo,nlItem,alInfo)
	Local nlVlImpIVA,nlBase,nlAliq,nlOrdSFC,nlRegSFC,nlVRet,clAux
	Local nlPos,clTes,clFil,nlRegSFB
	Local alRefImp
	Local llRetIVA	:= .T.
	Local clAgen	:= GetMV("MV_AGENTE")

	nlBase		:= 0
	nlAliq		:= 0
	nlVRet		:= 0
	nlVlImpIVA	:= 0
	lpRet		:= .T.

	If cModulo $ 'COM'
		If SubStr(clAgen,1,1) != "S"
			llRetIVA := .F.
		EndIf
	ElseIf cModulo $ 'FAT'
		If SA1->A1_AGENRET != '1'
			llRetIVA := .F.
		EndIf
	EndIf

	If llRetIVA
		DBSelectArea("SFB")
		DBSetOrder(1)
		If DBSeek(xFilial("SFB") + alInfo[X_IMPOSTO])
			If clCalculo $ "BA"
				If clCalculo == "B"
				    
					DBSelectArea("SFC")
					nlRegSFC := Recno()
					nlRegSFB := SFB->(Recno())
					nlOrdSFC := IndexOrd()
					SFC->(DBSetOrder(2))
					clTes := MaFisRet(nlItem,"IT_TES")
					alRefImp := MaFisRelImp("MT100",{"SD2"})
					clFil := xFilial("SFC")
					SFC->(DBSeek(clFil + clTes + "IV"))
					clAux := SubStr(SFC->FC_IMPOSTO,1,2)
					While SFC->FC_FILIAL == clFil .and. SFC->FC_TES == clTes .and. clAux == "IV"
						If SFC->FC_IMPOSTO <> alInfo[X_IMPOSTO]
							If (SFB->(DBSeek(xFilial("SFB") + SFC->FC_IMPOSTO)))
								nlPos := AScan(alRefImp,{|x| x[2] == "D2_VALIMP" + SFB->FB_CPOLVRO})
								If nlPos > 0
									 nlVlImpIVA +=SFB->FB_ALIQ/100*MaFisRet(nlItem,"IT_VALMERC")
									//nlVlImpIVA += MaFisRet(nlItem,alRefImp[nlPos,3])
								EndIf
							EndIf
						EndIf
						SFC->(DBSkip())
						clAux := SubStr(FC_IMPOSTO,1,2)
					EndDo
					nlBase := nlVlImpIVA
					DBSetOrder(nlOrdSFC)
					DBGoTo(nlRegSFC)
					SFB->(DBGoTo(nlRegSFB))
				EndIf
				nlAliq := SA2->A2_PERCCON  //% de retencion en base al proveedor
				
			Else
				lpRet:=.T.
			EndIf
		EndIf
	EndIf

	If lpRet .and. llRetIVA
		Do Case
			Case clCalculo == "A"
				nlVRet := nlAliq
			Case clCalculo == "B"
				nlVRet := nlBase
			Case clCalculo == "V"
			
				nlAliq := MaFisRet(nlItem,"IT_ALIQIV" + alInfo[X_NUMIMP])
				nlBase := MaFisRet(nlItem,"IT_BASEIV" + alInfo[X_NUMIMP])
				nlVRet := Round(nlBase * (nlAliq / 100),2) 
				
		EndCase
	EndIf
Return(nlVRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAURบAutor  ณMarcos Kato         บ Data ณ  13/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao de IVA - Esse imposto e calculado sobre บฑฑ
ฑฑบ          ณo Imposto de Valor Agregado                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M460RIVAUR(cCalculo,nItem,aInfo,lXFis)
Local xRet, nC
Local cMvAgente	 := Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))
Local llRetIVA	:= .T.
Local nMoeda  	:=	IIf(Type("nMoedaCor")=="U",1,nMoedaCor)
Local cGrpIVA := ""  
SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CTIPOCLI,CTIPOFORN,CCFO")
SetPrvt("NC,NVLIMPOSTOIVA,LRET,CZONFIS,LRETCF")
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif
cZonFis := ""
nVlImpostoIVA := 0
nBase         := 0

If !lXFis
	If cModulo$'FAT|LOJA|FRT|TMK|OMS|FIS'
		cTipoCliFor := SA1->A1_TPESSOA
	Else
		cTipoCliFor := SA2->A2_TPESSOA
	Endif
Else               
	If MaFisRet(,"NF_CLIFOR") == "C"
		cTipoCliFor := SA1->A1_TPESSOA
	Else
		cTipoCliFor := SA2->A2_TPESSOA
	EndIf
EndIf


If lXFis
	xRet:=M460RIVAFUR(cCalculo,nItem,aInfo)
Else
	If SubStr(cMvAgente,4,1) == "N" .And. Alltrim(aInfo[X_IMPOSTO])=="RI2"
		nAliq:=0
		llRetIVA	:= .F.
	EndIf
	    
	If llRetIVA     	
		dbSelectArea("SF4")
		cCFO := Alltrim(SF4->F4_CF)
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLocaliza o valor do imposto do IVAณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nC:=1 To Len(aImpVarSD2[6])
			If Substr(aImpVarSD2[6][nC][1],1,2) == "IV"
				nVlImpostoIVA += aImpVarSD2[6][nC][4] 
			Endif
		Next nC
		If SF4->F4_PRETIVA > 0
			aImposto[_ALIQUOTA] := SF4->F4_PRETIVA
		Else
			DbSelectArea("SFF")
			SFF->(DbSetOrder(5))
			SFF->(DbGoTop())
			If dbSeek(xFilial("SFF") + aImposto[1] + cCFO )
				aImposto[_ALIQUOTA] := SFF->FF_ALIQ                
			Else
				dbSelectArea("SFB")
				dbSetOrder(1)
				If dbSeek(xFilial("SFB")+aImposto[1])
					aImposto[_ALIQUOTA] := SFB->FB_ALIQ
				EndIf
			Endif
			
			DbSelectArea("SB5")
			SB5->(DbSetOrder(1))
			SB5->(DbGoTop())
			If DbSeek(xFilial("SB5")+SB1->B1_COD)
				cGrpIVA:=SB5->B5_GRPIVA
				DbSelectArea("SFF")
				SFF->(DbSetOrder(9))
				SFF->(DbGoTop())
				If DbSeek(xFilial("SFF")+aImposto[1]+AvKey(cGrpIVA,"FF_GRUPO"))
					aImposto[_ALIQUOTA]:=SFF->FF_ALIQ
				Endif		
			Endif
		Endif	
		aImposto[_BASECALC]  := nVlImpostoIVA
		aImposto[_IMPUESTO]  := Round(aImposto[_BASECALC] *  aImposto[_ALIQUOTA]/100,MsDecimais(nMoeda))	
	EndIf					
	
	xRet:=aImposto
Endif

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460RIVAFURบAutor  ณMarcos Kato         บ Data ณ 13/08/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo da Retencao do Imposto X Tes - Entrada               บฑฑ
ฑฑบ          ณAlterado para o uso da funcao MATXFIS (Marcello)             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA460,MATA100                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M460RIVAFUR(cCalculo,nItem,aInfo)
Local cCFO		 := ""
Local cMvAgente	 := Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))
Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()
Local cImpIncid	 :=""
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVal,nVRet, nI,nAliqI,nTaxaMoed,nBaseAtu
Local nMoeda  	:=	IIf(Type("nMoedaCor")=="U",1,nMoedaCor)  
Local aValRet
Local nAliqAux
Private clTipo	:= ""

If Valtype(aInfo)=="U"
	aInfo   := ParamIxb[2]
Endif

nI:=0
nBase:=0
nAliq:=0
nAliqI:=0
nDesconto:=0
nVRet:=0
nAliqAux:=0

DbSelectArea("SFB")
SFB->(DbSetOrder(1))
If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])

		cCFO := MaFisRet(nItem,"IT_CF")
		//Tira os descontos se for pelo liquido
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
			If SFC->FC_LIQUIDO=="S"
				nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
			cImpIncid:=SFC->FC_INCIMP
		Endif
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		nVal:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='2'
			nVal-=nDesconto
		Endif 
		
		If SubStr(cMvAgente,4,1) == "N" .And. Alltrim(aInfo[X_IMPOSTO])=="RI2"
			nAliq:=0
		Else
			DbSelectArea("SFF")
			SFF->(DbSetOrder(5))
			SFF->(DbGoTop())
			If dbSeek(xFilial("SFF") + aInfo[X_IMPOSTO] + cCFO )
				nAliq:=SFF->FF_ALIQ                
			Else
				nAliq:=SFB->FB_ALIQ
			Endif
			
			DbSelectArea("SB5")
			SB5->(DbSetOrder(1))
			SB5->(DbGoTop())
			If DbSeek(xFilial("SB5") + AvKey(MaFisRet(nItem,"IT_PRODUTO"),"B1_COD") )
				cGrpIVA:=SB5->B5_GRPIVA
				DbSelectArea("SFF")
				SFF->(DbSetOrder(9))
				SFF->(DbGoTop())
				If DbSeek(xFilial("SFF") + AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO") + AvKey(cGrpIVA,"FF_GRUPO"))
					nAliq:=SFF->FF_ALIQ					
				Endif		
			Endif
			
			If !Empty(cImpIncid)		
				nI:=At(";",cImpIncid)
				nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
				nAliqI:=0
				Do While nI>1
					If (SFB->(DbSeek(xFilial("SFB")+Substr(cImpIncid,1,nI-1))))
						nAliqI+=SFB->FB_ALIQ
					Endif
					nAliqAux+=nAliqI
					cImpIncid:=Stuff(cImpIncid,1,nI,"")
					nI := At( ";",cImpIncid)
					nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
				End
			Endif 
		Endif	
	
Endif

Do Case
	Case cCalculo=="B"
		nVRet:=nVal
		//If nAliqI>0
		//	nVRet:=Round(nVal * (nAliqI/100),MsDecimais(nMoeda))
		//Endif
	Case cCalculo=="A"
		nVRet:=nAliq
	Case cCalculo=="V"
		If Type("M->F2_ESPECIE")<>"U"		 
			cEspecie :=M->F2_ESPECIE
   		Elseif Type("M->F1_ESPECIE")<>"U"
   			cEspecie :=M->F1_ESPECIE
   		Else	
			cEspecie :="" //qdo ้ pedido
		Endif  
						 			
		//If nAliqAux > 0 .and. Subs(cEspecie,1,2)=="NC"
	   	//	nBase:=(MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])/(nAliqAux/100))
	   	//Else
	   		nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
	   	//Endif
		//nBase:=(MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])/IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1))
		nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
	
		If Subs(cEspecie,1,2)=="NC"
		   	nTaxaMoed := 0
			nMoeda := 1
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
		    EndIf	        
		    nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed) 
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	   	   	//ณVerifica o valor das reten็๕es e base de RI2 acumuladosณ
	   	   	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฤฤู			
		   	aValRet := RetValIR("RI2")
			//aValRet[01] = base acumulada
		   	//aValRet[02] = retencao acumulada							     
			If (aValRet[1]-nBaseAtu) <= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)			
				nVret := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				nVret := Round(nVret,MsDecimais(nMoeda))		   		
			Else
				nVret := Round((nBase*(nAliqAux/100))*(nAliq/100),MsDecimais(nMoeda))
			EndIF					
		Else 
			nVRet:= Round((nBase*(nAliqAux/100))*(nAliq/100),MsDecimais(nMoeda))
		EndIf		
EndCase
DbSelectArea( cAliasRot )
DbSetOrder( cOrdemRot )
Return(nVRet)
