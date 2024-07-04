#INCLUDE "MATXFIS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"
/*
MaFisBSSol -Edson Maricate  -08.12.1999
Esta rotina tem como objetivo calcular a base do retido/Solid conforme definido no regulamento de ICMS.
*/
Function FisBasSol(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cCampo)
Local nBsICMSt    := 0
Local nMargem     := 0
Local nBase 	  := 0
Local nBaseAux	  := 0
Local nBaseOri	  := 0
Local nY		  := 0
Local lValido     := .T.
Local nReduzICMS  := 0
Local lTipoCliFor := .F.
Local cTipoCliFor := ""
Local nVlMercR    := 0
Local cMvEstado	  := aSX6[MV_ESTADO]
Local lSTAtacVar  := IIf( aNFItem[nItem][IT_TS][TS_ATACVAR] == "1" .And. aNfItem[nItem][IT_PRD][SB_PICMENT] == 0 .And. cMvEstado == "CE" .And. aNFCab[NF_OPERNF] == "E" , .T. , .F.)
Local lSTConfCE   := IIf( aNFItem[nItem][IT_TS][TS_STCONF] == "1" .And. aNfItem[nItem][IT_PRD][SB_PICMRET] == 0 .And. cMvEstado == "CE" .And. aNFCab[NF_OPERNF] == "S" , .T. , .F.)
Local lDevTot     := aSX6[MV_DEVTOT]  // Indica se na devolucao total da mercadoria sera considerado no valor da base o valor do frete + despesa + seguro
Local lSomaIpi	  := aSX6[MV_SOMAIPI]
Local lIpiICST    := IIf(aNFItem[nItem][IT_TS][TS_SOMAIPI] == "2" .And. aNfItem[nItem][IT_TIPONF]=="N" , .F. , .T.)
// Controle Regime de Estimativa MT.
Local lRegESim	  := aSX6[MV_REGESIM]
Local lRet		  	:= .F.
Local nBaseICM	  := 0
Local nPerCaTM    := Iif( aNFItem[nItem][IT_TS][TS_PERCATM]>0 , aNFItem[nItem][IT_TS][TS_PERCATM]  , IIf( aNFCab[NF_PERCATM] > 0 , aNFCab[NF_PERCATM] , aSX6[MV_PERCATM] )   )
Local cMV_UFPST	  := aSX6[MV_UFPST21]
Local lSTPTPer	  := .F.
Local nValPER     := 0
Local lCalSTPe	  := .F.
Local nRedBaST	  := PerRedST(aNfItem,nItem)
Local nVlrPTST	  := 0
Local cMVSTPTPER  := aSX6[MV_STPTPER]
Local cMvTpSolCF  := aSX6[MV_TPSOLCF]
Local lMvSolBrut  := aSX6[MV_SOLBRUT]
Local cMVMkpIcPT  := aSX6[MV_MKPICPT]
Local lF4ApliIVA  := aPos[FP_F4_APLIIVA]
Local cCFOPTran   := "5351/5352/5353/5354/5355/5356/5357/5359/5360/6351/6352/6353/6354/6355/6356/6357/6359/6360/6932/5932/7358"
//Tratamento específico de PB para ignorar o tratamento para venda não presencial
Local lNConf21	  := Iif( aNfCab[NF_UFDEST]=="PB" .And. aNfCab[NF_VTOTPED]>0 .And. aNfCab[NF_VTOTPED]<500, .T. ,.F. )
Local nValIEst	  := 0
Local nAliqEst	  := FISXALIEST(aNFCab, aNfItem, aSX6, nItem)
Local nAliqAgr	  := 0
Local lAgreg	  	:= .F.
Local aMaSolICMS  := {}
Local cNCMRdBase  := aSX6[MV_STMEDRD]

Local nCustEnt  := 0
Local nBsSTCalc := 0


Local cMvUFBdSt := aSX6[MV_UFBDST]
Local cMvUFBdGo := aSX6[MV_UFBSTGO]
Local cMvUFBdSe := aSX6[MV_BASDSSE]
Local cSimpNac  := aSX6[MV_CODREG]
Local lSTRedu   := aSX6[MV_STREDU]
Local cUfOri    := ""
Local cUfDest   := ""

Local lBdSTRev   := aSX6[MV_BDSTREV] .And. aNfCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST]
Local lTribIcmST := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMSST)

Local cFunName  := Alltrim(FunName())

DEFAULT cCampo	:= ""

If !lTribIcmST
	// Carrega o tipo do cliente pagador ou destinario
	cTipoCliFor := Iif(!Empty(aNfCab[NF_PNF_TPCLIFOR]),aNfCab[NF_PNF_TPCLIFOR],aNfCab[NF_TPCLIFOR])
	lTipoCliFor := cTipoCliFor $ cMvTpSolCF

	// Carrega a reducao da base do ICMS
	nReduzICMS := PerRedIC(aNfItem,nItem)

	
	// Controle automatico para utilizacao de Pauta ou Calculo ST por percentual PAUTA x Valor Operacao.
	nVlrPTST := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F", IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP]) - IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0) + Iif(aNFItem[nItem][IT_TS][TS_INCIDE] == "", aNfItem[nItem][IT_VALIPI], 0) + aNfItem[nItem][IT_DESPESA]
	If Empty(aSX6[MV_B1PTST])
		lSTPTPer	:= Iif(aNfCab[NF_UFDEST] $ cMVSTPTPER,.T.,.F.)
		nValPER		:= Val(Transform(Substr(cMVSTPTPER,At(aNfCab[NF_UFDEST],cMVSTPTPER)+2,4),"@E 99.99"))
	Else
		lSTPTPer	:= aNfItem[nItem][IT_PRD][SB_B1PTST] > 0
		nValPER		:= aNfItem[nItem][IT_PRD][SB_B1PTST]
	Endif

	If lSTPTPer .And. nValPER > 0 .And. nVlrPTST > 0
		If (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. (nVlrPTST/aNfItem[nItem][IT_EXCECAO][8]) >= nValPER) .Or. ;
		(!Empty(aNFitem[nItem][IT_UFXPROD]) .And. (nVlrPTST/aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]) >= nValPER) .Or. ;
			aNfItem[nItem][IT_PRD][SB_VLR_ICM] <> 0 .And.( nVlrPTST / aNfItem[nItem][IT_PRD][SB_VLR_ICM] ) >= nValPER
			lCalSTPe := .T.
		EndIf
	EndIf

	// Verifica se deve-se calcular o ICMS solidario
	If aNFItem[nItem][IT_TS][TS_MKPCMP]<>"1" .And. !(aNFitem[nItem][IT_TIPONF ]$'IP') .And. IIf(aNfCab[NF_OPERNF]=="S".And.aNFCab[NF_CLIFOR] == "C",lTipoCliFor,.T.)
		If aNFCab[NF_TIPONF]$"DB"
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C")
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					dbSelectArea("SF2")
					dbSetOrder(1)
					If MsSeek(xFilial("SF2")+(SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
						If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT  .And.  Iif(!lDevTot, aPos[FP_D2_ALIQSOL] .And. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0,aPos[FP_D2_ALIQSOL])
							aNfItem[nItem][IT_BASESOL] := SD2->D2_BRICMS
							lValido := .F.
						ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. Iif(!lDevTot, aPos[FP_D2_ALIQSOL] .And. SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0,aPos[FP_D2_ALIQSOL])

							aNfItem[nItem][IT_BASESOL] := (SD2->D2_BRICMS/SD2->D2_QUANT)* aNfItem[nItem][IT_QUANT]
							lValido := .F.

						ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
							
							aNfItem[nItem][IT_BASESOL] := SD2->D2_BRICMS * (aNfItem[nItem][IT_QUANT] / SD2->D2_QUANT)
							lValido := .F.

						Else
							If SF2->F2_TIPOCLI$cMvTpSolCF
								lValido := .T.
							Else
								lValido := .F.
							EndIf
						EndIf
					EndIf
				Else
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					dbSelectArea("SF1")
					dbSetOrder(1)
					If MsSeek(xFilial("SF1")+(SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
						If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. Iif(!lDevTot, aPos[FP_D1_ALIQSOL]  .And. SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 , aPos[FP_D1_ALIQSOL])
							// Tratamento de ICMS-ST conforme decreto 29.560/2008 para o estado do Ceara.
							// Conforme o decreto que visa atender atacadista e varejistas do ceara atraves de aliquot
							// a especificas de ICMS-ST.estas sao utilizadas conforme o anexo III do decreto que e com
							// posta de varias caracteristicas tais como operação(somente)de entrada, origem do forne
							// cedor, se e optante do simples nacional, aliquota interna do produto, se o destinatario
							// e atacadista ou varejista. Segundo consulta realizada ao JIRA para tratamento de
							// devolucao.Neste caso emitiu parecer que ao devolver compras realizadas com este calculo
							// o ICMS-ST nao devera ser calculado para a nota de devolucao de compras.
							If aNfItem[nItem][IT_PRD][SB_PICMENT] == 0 .And. cMvEstado == "CE" .And. lSTAtacVar .And. ( Substr(SM0->M0_CNAE,1,2) == "46" .Or. Substr(SM0->M0_CNAE,1,2) == "47" )
								aNfItem[nItem][IT_BASESOL] := 0
							Else
								aNfItem[nItem][IT_BASESOL] := SD1->D1_BRICMS
							EndIf
							lValido := .F.

						ElseIf aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"2N"
							nDespAc := SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA
							nSDesp  := SD1->D1_BASEICM - nDespAc
							aNfItem[nItem][IT_BASESOL] := ((nSDesp * (SD1->D1_MARGEM / 100)) + nSDesp ) * (aNfItem[nItem][IT_QUANT] / SD1->D1_QUANT)
							lValido := .F.
						
						ElseIf SF1->F1_BRICMS > 0
							aNfItem[nItem][IT_BASESOL] := SD1->D1_BRICMS * (aNfItem[nItem][IT_QUANT] / SD1->D1_QUANT)
							lValido := .F.
						Else
							lValido := .F.
						EndIf
					Endif
				Endif
			ElseIf !lTipoCliFor
				lValido := .F.
			EndIf
		
		//Verifico se o documento é do tipo Complemento de preço e depois atribuo o valor do MVA para que quando este valor
		// for alterado ele ainda pegue o MVA da nota original e não do produto ou exceção - ISSUE DSERFISE-4946
		ElseIf aNFCab[NF_TIPONF]$"C" 
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_MARGEM] := SD2->D2_MARGEM
				Else
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_MARGEM] := SD1->D1_MARGEM
				EndIf
			EndIf
		EndIf
		If lValido
			// Calculo do Solidario pela Margem de lucro
			If (aNfItem[nItem][IT_PRD][SB_VLR_ICM] == 0 .And. ((Empty(aNFitem[nItem][IT_EXCECAO]) .Or. aNfItem[nItem][IT_EXCECAO][8]==0) .And. (Empty(aNFitem[nItem][IT_UFXPROD]) .Or. aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]==0))) .Or.;
				(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][20] == "2" .And. aNfItem[nItem][IT_EXCECAO][8] == 0) .Or.;
				IiF(lSTPTPer,IiF(lCalSTPe,.T.,.F.),.F.)
				If (aNfItem[nItem][IT_MARGEM] > 0 .And. aNFItem[nItem][IT_TS][TS_APLREDP]<> "1") .Or. ( lSTAtacVar .And. aNFItem[nItem][IT_TS][TS_APLREDP]<> "1").Or. ( lSTConfCE .And. aNFItem[nItem][IT_TS][TS_APLREDP]<> "1")

					nMargem := aNfItem[nItem][IT_MARGEM]

					// Se o campo novo estiver preenchido vale a regra do campo novo.
					// caso contrario continua com o parametro MV_STREDU. A regra eh a mesma.
					// Se lSTRedu = .T. significa que sera aplicada a reducao no valor da mercadoria
					// antes de somar os demais valores que fazem parte da base e da aplicacao do MVA.
					// Se lSTRedu = .F. significa que serao somados todos os valores que
					// fazem parte da base do ST, aplicado o MVA, e por ultimo a base sera reduzida.
					If !Empty(aNfItem[nItem][IT_TS][TS_STREDU])
						lSTRedu := aNfItem[nItem][IT_TS][TS_STREDU] == "1"
					Else
						lSTRedu := aSX6[MV_STREDU]
					EndIf//------\\

					If lSomaIpi
						If !lSTRedu
							aNfItem[nItem][IT_BASESOL] := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP])-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"D",aNfItem[nItem][IT_DEDICM],0),0)
						Else
							If nRedBaST > 0 .And. aNFItem[nItem][IT_TS][TS_INCSOL]<>'A'
								nVlMercR := ((aNfItem[nItem][IT_VALMERC])*nRedBaST)/100
							Else
								nVlMercR := (aNfItem[nItem][IT_VALMERC])
							Endif
							aNfItem[nItem][IT_BASESOL] := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, nVlMercR, aNfItem[nItem][IT_PRCMEDP]) - IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)
						Endif
					Else
						If !lSTRedu
							//Devo dobrar o valor da base sem as despesas
							If nRedBaST == 200
								aNfItem[nItem][IT_BASESOL] := (IIf(aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP]) * nRedBaST / 100 )
							Else
								aNfItem[nItem][IT_BASESOL] := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP]) - IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)+Iif(!lIpiICST, 0, aNfItem[nItem][IT_VALIPI])
							EndIf
						Else
							If nRedBaST > 0 .And. aNFItem[nItem][IT_TS][TS_INCSOL]<>'A'
								nVlMercR := ((aNfItem[nItem][IT_VALMERC])*nRedBaST)/100
							Else
								nVlMercR := (aNfItem[nItem][IT_VALMERC])
							Endif
							aNfItem[nItem][IT_BASESOL] := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F", IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, nVlMercR, aNfItem[nItem][IT_PRCMEDP]) - IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)+Iif(!lIpiICST, 0, aNfItem[nItem][IT_VALIPI])
						Endif
					Endif

					If lBdStRev
						aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASESOL] - aNfItem[nItem][IT_VALICM]
					EndIf

					IF aNFItem[nItem][IT_TS][TS_BSICMRE] == "1" .And. aNfItem[nItem][IT_PRD][SB_UVLRC] > 0 .And.  aNFCab[NF_UFDEST] == aNFCab[NF_UFORIGEM] .And. aNfCab[NF_OPERNF] == "S"
						aNfItem[nItem][IT_BASESOL]	:= aNfItem[nItem][IT_PRD][SB_UVLRC]	* aNfItem[nItem][IT_QUANT]
					EndIf
					If ((aNFItem[nItem][IT_TS][TS_DESPICM] <> "2" .And. aNFItem[nItem][IT_TS][TS_DESPICM] <> "4") .OR. aSX6[MV_DESPICM])
						aNfItem[nItem][IT_BASESOL] += 	aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]+aNfItem[nItem][IT_FRETE]
					EndIf
					If aNFItem[nItem][IT_TS][TS_FRETAUT] == "2"
						aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_AUTONOMO]
					EndIf

					If aNFItem[nItem][IT_TS][TS_AGREG]<>"F"
						If !lMvSolBrut .Or. aNFItem[nItem][IT_TS][TS_STDESC] == "1"
							aNfItem[nItem][IT_BASESOL] -=  (aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_DESCTOT] )
						EndIf
					EndIf				
					// Se nao calcular o ICMS Normal soma-lo na base de ICMS ST
					If ((aNfItem[nItem][IT_VALICM] == 0 .And. aNfItem[nItem][IT_DESCZF] == 0) .Or.;
						(aSX6[MV_ESTADO] == "AM" .And. aNFCab[NF_OPERNF] == "S" .And. aNFItem[nItem][IT_TS][TS_AGREG] == "I" .And.;
						(AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE]))))
						If aNFItem[nItem][IT_TS][TS_ICMSST] <> "2" .and. !empty(aNFItem[nItem][IT_TS][TS_ICMSST])
							If aNfItem[nItem][IT_VALICM] == 0
								nAliqAgr += MaAliqIcms(nItem,.T.)
							Else
								nAliqAgr += aNfItem[nItem][IT_ALIQICM]
							EndIf
							lAgreg := .T.
						EndIf
						If aNFItem[nItem][IT_TS][TS_AGRPIS]=="P"
							nAliqAgr += aNfItem[nItem][IT_ALIQPS2]
							lAgreg := .T.
						EndIf
						If aNFItem[nItem][IT_TS][TS_AGRCOF]=="C"
							nAliqAgr += aNfItem[nItem][IT_ALIQCF2]
							lAgreg := .T.
						EndIf
					EndIf
					If lAgreg
						aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASESOL] / (1-(nAliqAgr /100))
					EndIf
					If !aSX6[MV_DSZFSOL]
						aNfItem[nItem][IT_BASESOL] += (aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]))
					EndIf

					IF aNfCab[NF_SUFRAMA] .And. !(aNfCab[NF_UFDEST] $ aSX6[MV_UFSTZF])
						aNfItem[nItem][IT_BASESOL] += (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF])
					ENDIF
					If aNFItem[nItem][IT_TS][TS_BCPCST] == "1"
						aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_VALPS3] + aNfItem[nItem][IT_VALCF3]
					EndIf
					// Operacoes de venda para consumidor final nao podem ter
					// margem de lucro se o destino for para uso e consumo.
					If (( aNFItem[nItem][IT_TS][TS_CONSUMO]$"S" .And.;
						(	( cTipoCliFor$"F/L" .And. aNfCab[NF_CLIFOR]=="C" ) .Or. ( aNfCab[NF_CLIFOR]$"F/L" ) ) .And.;
						aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .Or. aNFItem[nItem][IT_TS][TS_MKPSOL]=="1") .And. aNFItem[nItem][IT_TS][TS_MKPSOL]<>"3"
						nMargem := 0
					EndIf

					// Para Calulo ICMS-ST Importacao SIGAEIC na classificacao da NFE, neste caso a base a ser considerada e a base do ICMS original
					// enviada pelo SIGAEIC que contem demais contribuicoes e impostos que compoem o valor total da importacao para se obter o ICMST
					If (aNFItem[nItem][IT_TS][TS_AGREG]$"B") .And. nMargem > 0
						aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASEICM]
					EndIf

					//Essa validacao foi implementada verificando apenas as referencias: NF_OPERNF, TS_MKPSOL, TS_INCSOL e TS_AGREG.
					//Porem, isso estava causando inconsistencias no calculo de ICMS Solidario originado do TMS.
					//Foi adicionada a validacao da referencia TS_CREDST ,pois conforme chamado da primeira implementacao - TFZGYC, esse campo
					//tambem deve ser verificado.
					If aNfCab[NF_OPERNF]=="S" .And. aNFItem[nItem][IT_TS][TS_MKPSOL] == "1" .And. aNFItem[nItem][IT_TS][TS_INCSOL] == "D" .And. aNFItem[nItem][IT_TS][TS_AGREG] == "I" .And. aNFItem[nItem][IT_TS][TS_CREDST] == "3" .And. AllTrim(aNfItem[nItem][IT_CF])$ cCFOPTran;
						.And. aNfItem[nItem][IT_BASEICM]>0
						aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASEICM]
					EndIf

					//Verifica se irá somar o valor do PIS e da COFINS na base de cálculo do ICMS ST.
					//Após somar, se aplicavel, irá incluir o valor do ICMS na base: (base de cálculo / (1-percentual da alíquota do ICMS))
					IF aNfCab[NF_OPERNF]=="E" .And. aNFCab[NF_CLIFOR] =="F" .And. aNFCab[NF_TPCLIFOR] =="X" .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123" .AND. Substr(aNfItem[nItem][IT_CF],1,1)=="3"

						// Se vier do SIGAEIC a referencia IT_BASEICM ja contem todos os valores que compoem o valor total da importacao,
						// incluindo o valor do icms. Portanto, nao somar novamente estes tributos na base do ST.
						If !(aNFItem[nItem][IT_TS][TS_AGREG]$"B" .And. nMargem > 0)
							aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_VALPS2] + aNfItem[nItem][IT_VALCF2]
							aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL] / (1-(aNFItem[nItem,IT_ALIQICM]/100)))
						EndIf
					EndIF
					If aNFItem[nItem][IT_TS][TS_INCSOL] <> "A" .Or. lBdStRev
						//Tratamento para o IVA Ajustado somente quando a informacao
						//e solicitada do pedido de vendas - planilha financeira
						If (cFunName $ "MATA410|MATC090|OFIXA018|OFIXA011|OFIXA100"	.Or. (cFunName $ "MATA460A" .And. inclui==.F. .And. altera==.F.));
							.And. aNfItem[nItem][IT_PRD][SB_IVAAJU] == "1" .And. Len(aNfItem[nItem][IT_ANFORI2][1][1]) > 0
							nBaseOri := aNfItem[nItem][IT_BASESOL] //salvo a base original para efetuar o calculo da nova base com o IVA Ajustado
							For nY := 1 To Len (aNfItem[nItem][IT_ANFORI2])//Neste momento verifico se existe a proporcionalidade para calcular a base, pois pode existir quantidades de varios lotes
								If aNfItem[nItem][IT_ANFORI2][nY][3] < aNfItem[nItem][IT_QUANT]
									nBase := ((nBaseOri/aNfItem[nItem][IT_QUANT])*aNfItem[nItem][IT_ANFORI2][nY][3])
									nBase *= (1+(aNfItem[nItem][IT_ANFORI2][nY][4]/100))
									nBaseAux	+=	nBase
									aNfItem[nItem][IT_BASESOL]	:= nBaseAux
								Else
									aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASESOL]*(1+(nMargem/100))
								EndIf
							next
						Else
							aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASESOL]*(1+(nMargem/100))
						EndIf
					EndIf
					IF lBdSTRev .Or. (aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. (aNFCab[NF_UFDEST]$cMvUFBdSt .Or. aNFCab[NF_UFDEST]$cMvUFBdSe .Or. aNFCab[NF_UFDEST]$cMvUFBdGo)  .And. ((aNfCab[NF_OPERNF] == "S" .And. aNfCab[NF_TPCLIFOR] $ "F/L" ) .Or. (aNfCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S" )))
						IF aNFCab[NF_UFDEST]$cMvUFBdSe .And. !lBdSTRev // MV_BASDSSE
							aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL])/(1-((aNfItem[nItem][IT_ALIQSOL]-aNFItem[nItem][IT_ALIQICM])/100))
						ElseIF aNFCab[NF_UFDEST]$cMvUFBdGo; // Base Dupla ST para Goias Art. 65 do RCTE/GO. // tdn.totvs.com/pages/releaseview.action?pageId=267797477
						.Or. lBdSTRev  // Base dupla pra ST nas operações de entrada, inclusive para produtos para revenda. Nessa operação, o valor do ICMS já foi descontado
							aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL])/(1-((aNfItem[nItem][IT_ALIQSOL])/100))
						Else
							If cSimpNac $ "1/2"
								aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL]-(aNfItem[nItem][IT_BASEICM]*nAliqEst/100))/(1-(aNfItem[nItem][IT_ALIQSOL])/100)
							ElseIf (aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ] >0)
								//Base Dupla ST Convenio 51/92 com diferencial de aliquota https://tdn.totvs.com/x/8Yw0Fg
								aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL]-aNfItem[nItem][IT_VALICM])/(1-(aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ])/100)
							Else
								aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL]-aNfItem[nItem][IT_VALICM])/(1-(aNfItem[nItem][IT_ALIQSOL])/100)
							Endif
						Endif
					EndIf
					If nRedBaST > 0 .And. nRedBaST <> 200 .And. aNFItem[nItem][IT_TS][TS_INCSOL]<>'A' .And. !lSTRedu
						If nRedBaST == 100
							aNfItem[nItem][IT_BASESOL] := 0
						Else
							aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL]*nRedBaST)/100
							aNfItem[nItem][IT_PREDST]  :=	nRedBaST
						EndIf

					ElseIf nReduzICMS > 0 .And. aSX6[MV_BASERET]=="S"
						aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL]*nReduzICMS)/100
						aNfItem[nItem][IT_PREDST]  := nReduzICMS

						If aNFItem[nItem][IT_TS][TS_VDASOFT] == "1" .And. nReduzICMS >= 100 .And. !lSomaIpi
							aNfItem[nItem][IT_BASESOL] -= aNfItem[nItem][IT_VALIPI]*(1+(nMargem/100))
						EndIf
					EndIf
					//Tratamento para Confaz 21/2011. As condicoes para o calculo do ICMS-ST sao para as UF's contidas no parametro
					//MV_UFPST21, para clientes do tipo Consumidor Final e para Vendas nao presenciais, verificado pelo campo F4_VENPRES.
					If (aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFItem[nItem][IT_TS][TS_VENPRES] <> "1" .And. aNFCab[NF_UFDEST] $ cMV_UFPST .And. cTipoCliFor == "F" .And. ;
						(aNFCab[NF_LINSCR] .Or. SA1->A1_CONTRIB == "2") .And. aNFItem[nItem][IT_TS][TS_MKPSOL]=="1" ) .And. !lNConf21

						aNfItem[nItem][IT_BASESOL]	:= Iif( nReduzICMS > 0 .And. aSX6[MV_BASERET] == "S" , aNfItem[nItem][IT_BASEICM] , aNfItem[nItem][IT_BICMORI] )
					Endif
				ElseIf (aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFItem[nItem][IT_TS][TS_VENPRES] <> "1" .And. aNFCab[NF_UFDEST] $ cMV_UFPST .And. cTipoCliFor == "F" .And. ;
					(aNFCab[NF_LINSCR] .Or. SA1->A1_CONTRIB == "2") .And. aNFItem[nItem][IT_TS][TS_MKPSOL]=="1" ) .And. !lNConf21
						aNfItem[nItem][IT_BASESOL]	:= Iif( nReduzICMS > 0 .And. aSX6[MV_BASERET] == "S" , aNfItem[nItem][IT_BASEICM] , aNfItem[nItem][IT_BICMORI] )
					//Verifico se devo usar a base de calculo do ICMS Proprio quando reduzida, como base para o ICMS ST.
				ElseIf (aNfItem[nItem][IT_MARGEM] > 0 .And. aNFItem[nItem][IT_TS][TS_APLREDP]=="1") .Or. ( lSTAtacVar .And. aNFItem[nItem][IT_TS][TS_APLREDP]=="1") .Or. ( lSTConfCE .And. aNFItem[nItem][IT_TS][TS_APLREDP]=="1")

					aNfItem[nItem][IT_BASESOL]	:= Iif( nReduzICMS > 0 .And. aSX6[MV_BASERET] == "S" , aNfItem[nItem][IT_BASEICM] , aNfItem[nItem][IT_BICMORI] ) + aNfItem[nItem][IT_VALIPI]
					//Caso Despesa não tenham entrado na base do ICMS Proprio deve ser colocada.
					If aNFItem[nItem][IT_TS][TS_DESPICM] == "2" .Or. aNFItem[nItem][IT_TS][TS_DESPICM] == "3";
						.Or. (aNFItem[nItem][IT_TS][TS_DESPICM]$"14" .And. aNFItem[nItem][IT_TS][TS_DESPRDIC] == "3")
						aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_DESPESA]
						aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_SEGURO]
					EndIf
					If aNFItem[nItem][IT_TS][TS_DESPRDIC] $ "3"
						aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_FRETE]
					EndIf
					aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASESOL] * (1+(aNfItem[nItem][IT_MARGEM]/100))
				Elseif aNfItem[nItem][IT_MARGEM] == 0
					If aNFCab[NF_UFDEST] == aNFCab[NF_UFORIGEM] .And. aNFItem[nItem][IT_TS][TS_OBSSOL]=="5" .And. aNFItem[nItem][IT_TS][TS_LFICM]=="Z"
						aNfItem[nItem][IT_BASESOL] := IIf(aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP])
					ElseIf	aNfItem[nItem][IT_BASESOL]> 0 .And. (!lMvSolBrut .Or. aNFItem[nItem][IT_TS][TS_STDESC] == "1")
						aNfItem[nItem][IT_BASESOL] -= (aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_DESCTOT] )
					Endif
				Else
					aNfItem[nItem][IT_BASESOL]	:= 0
				EndIf
			Else // Nesse ponto é verificado se o St será por pauta ou por MVA. O sistema vai fazer ambos os calculos e verificar qual será usado.
			If !Empty(aNfItem[nItem][IT_TS][TS_STREDU])
					lSTRedu := aNfItem[nItem][IT_TS][TS_STREDU] == "1"
				Else
					lSTRedu := aSX6[MV_STREDU]
				EndIf
				//Aqui começa o calculo pela pauta
				If !Empty(aNFitem[nItem][IT_EXCECAO]) .And. (aNfItem[nItem][IT_EXCECAO][8]<>0 .Or. aNfItem[nItem][IT_EXCECAO][20]=="2")
					aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_QUANT]*aNfItem[nItem][IT_EXCECAO][8]
					aNfItem[nItem][IT_PAUTST]  := aNfItem[nItem][IT_EXCECAO][8]
				ElseIf !Empty(aNFitem[nItem][IT_UFXPROD]) .And. aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]<>0
					aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_QUANT]*aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]
					aNfItem[nItem][IT_PAUTST]  := aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]
				Else
					aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PRD][SB_VLR_ICM]
					aNfItem[nItem][IT_PAUTST]  := aNfItem[nItem][IT_PRD][SB_VLR_ICM]
				EndIf

				aNfItem[nItem][IT_PERCVENXPMC] := ((aNfItem[nItem][IT_BASEICM]/aNfItem[nItem][IT_QUANT]) /aNfItem[nItem][IT_PAUTST]) * 100 // Calculo de percentual do valor da operação com relação ao valor de pauta do produto, cadastrado no campo B1_VLR_ICM

				// DECRETO Nº 1.828 - SANTA CATARINA.
				// Para mais informações, acessar o parecer da Consultoria Tributária: https://tdn.totvs.com/pages/releaseview.action?pageId=469445871
				If aNfItem[nItem][IT_PERCVENXPMC] >= 70 .And. SubStr(aNfItem[nItem][IT_POSIPI],1,4) $ cNCMRdBase
					nRedBaST := 0
					aNfItem[nItem][IT_PREDST]  :=	nRedBaST
				EndIf

				If !Empty( aSX6[MV_ICMPFAT] )
					aNfItem[nItem][IT_BASESOL] *= aNfItem[nItem][IT_PRD][SB_ICMPFAT]
				EndIf
				if lSTRedu .and. nRedBaST > 0  .and. aSX6[MV_REDPT] == .T.//Redução aplicada antes da composição da base (pauta)
					aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL]*nRedBaST)/100
				EndIf
				If aSX6[MV_ICPAUTA]=="2" //1=Sem Frete/Despesa/Seguro - 2=Com Frete/Despesa/Seguro
					If !Empty(aNFItem[nItem][IT_VLR_FRT])
						aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_VLR_FRT]+aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]
					Else
						aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]
					EndIf
				EndIf//Nesse ponto o sistema começa a fazer o cálculo por MVA
				If lSomaIpi
					If !lSTRedu
						nBsICMSt := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP])-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"D",aNfItem[nItem][IT_DEDICM],0),0)
					Else
						If nRedBaST > 0 .And. aNFItem[nItem][IT_TS][TS_INCSOL]<>'A'
							nVlMercR := ((aNfItem[nItem][IT_VALMERC])*nRedBaST)/100
						Else
							nVlMercR := (aNfItem[nItem][IT_VALMERC])
						Endif
						nBsICMSt := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, nVlMercR, aNfItem[nItem][IT_PRCMEDP]) - IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)
					Endif
				Else
					If !lSTRedu
						//Devo dobrar o valor da base sem as despesas
						If nRedBaST == 200
							nBsICMSt := (IIf(aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP]) * nRedBaST / 100 )
						Else
							nBsICMSt := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP]) - IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)+Iif(!lIpiICST, 0, aNfItem[nItem][IT_VALIPI])
						EndIf
					Else
						If nRedBaST > 0 .And. aNFItem[nItem][IT_TS][TS_INCSOL]<>'A'
							nVlMercR := ((aNfItem[nItem][IT_VALMERC])*nRedBaST)/100
						Else
							nVlMercR := (aNfItem[nItem][IT_VALMERC])
						Endif
						nBsICMSt := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F", IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, nVlMercR, aNfItem[nItem][IT_PRCMEDP]) - IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)+Iif(!lIpiICST, 0, aNfItem[nItem][IT_VALIPI])
					Endif
				Endif
				If ((aNFItem[nItem][IT_TS][TS_DESPICM] <> "2" .And. aNFItem[nItem][IT_TS][TS_DESPICM] <> "4") .OR. aSX6[MV_DESPICM])
					nBsICMSt += 	aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]+aNfItem[nItem][IT_FRETE]
				EndIf

				If aNFItem[nItem][IT_TS][TS_FRETAUT] == "2"
					nBSICMSt += aNfItem[nItem][IT_AUTONOMO]
				EndIf
				If !lMvSolBrut .Or. aNFItem[nItem][IT_TS][TS_STDESC] == "1"
					nBsICMSt -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
				EndIf
				If !aSX6[MV_DSZFSOL]
					nBsICMSt += aNfItem[nItem][IT_DESCZF]
					aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_DESCZF]
				EndIf

				If nReduzICMS > 0 .And. aSX6[MV_BASERET] =="S"
					nBsICMSt := (aNfItem[nItem][IT_BASESOL]*nReduzICMS)/100
					aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL]*nReduzICMS)/100
					aNfItem[nItem][IT_PREDST]  := nReduzICMS

					If aNFItem[nItem][IT_TS][TS_VDASOFT] == "1" .And. nReduzICMS >= 100
						aNfItem[nItem][IT_BASESOL] -= aNfItem[nItem][IT_VALIPI]
					EndIf
				EndIf

				If nRedBaST > 0 .And. nRedBaST <> 200 .And. aNFItem[nItem][IT_TS][TS_INCSOL]<>'A' .And. !lSTRedu
					If nRedBaST == 100
						nBSICMSt := 0
						aNfItem[nItem][IT_BASESOL] := 0
					Else
						nBSICMSt := (nBSICMSt*nRedBaST)/100 // aplicada redução para cálculo do MVA
						If aSX6[MV_REDPT] == .T.
							aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL]*nRedBaST)/100 // aplicada redução sobre a pauta ST
						EndIf
						aNfItem[nItem][IT_PREDST]  :=  nRedBaST
					EndIf
				EndIf

				//Verifica se irá somar o valor do PIS e da COFINS na base de cálculo do ICMS ST.
				//Após somar irá incluir o valor do ICMS na base: (base de cálculo / (1-percentual da alíquota do ICMS))
				IF aNfCab[NF_OPERNF]=="E" .And. aNFCab[NF_CLIFOR] =="F" .And. aNFCab[NF_TPCLIFOR] =="X" .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123" .AND. Substr(aNfItem[nItem][IT_CF],1,1)=="3"
					aNfItem[nItem][IT_BASESOL] += aNfItem[nItem][IT_VALPS2] + aNfItem[nItem][IT_VALCF2]
					aNfItem[nItem][IT_BASESOL] := (aNfItem[nItem][IT_BASESOL] / (1-(aNFItem[nItem,IT_ALIQICM]/100)))
				EndIF
				If ( aNfItem[nItem][IT_MARGEM] > 0 .And. cMVMkpIcPT=="2" .And. aNfCab[NF_OPERNF]=="S") .Or. ( lSTAtacVar .And. cMVMkpIcPT=="2") .Or. ( lSTConfCE .And. cMVMkpIcPT=="2")
					nMargem := aNfItem[nItem][IT_MARGEM]
					// Operacoes de venda para consumidor final nao podem ter
					// margem de lucro se o destino for para uso e consumo.
					If (( aNFItem[nItem][IT_TS][TS_CONSUMO]$"SO" .And.;
						(	( cTipoCliFor=="F" .And. aNfCab[NF_CLIFOR]=="C" ) .Or. ( aNfCab[NF_CLIFOR]=="F" ) ) .And.;
						aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .Or. aNFItem[nItem][IT_TS][TS_MKPSOL]=="1") .And. aNFItem[nItem][IT_TS][TS_MKPSOL]<>"3"
						nMargem := 0
					EndIf
					If aNFItem[nItem][IT_TS][TS_INCSOL] <> "A"
						aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASESOL]*(1+(nMargem/100))
						nBsICMSt := nBsICMSt*(1+(nMargem/100))
					EndIf
				EndIf
				// Calculo do valor da base do ICMS Solidario quando o valor da
				// pauta for menor do que o valor do item.
				If (lF4ApliIVA .And. aNFItem[nItem][IT_TS][TS_APLIIVA]$"1/3/4/5" .And. aNfItem[nItem][IT_MARGEM] > 0 ) .Or. ;
					(lF4ApliIVA .And. aNFItem[nItem][IT_TS][TS_APLIIVA]$"1/3" .And. lSTAtacVar) .Or. ;
					(lF4ApliIVA .And. aNFItem[nItem][IT_TS][TS_APLIIVA]$"1/3" .And. lSTConfCE)

					IF aNFItem[nItem][IT_TS][TS_APLIIVA] == "5" .And. aNFItem[nItem][IT_TS][TS_OUTPERC] > 0 .And. nBsICMSt>=(aNfItem[nItem][IT_BASESOL] * (aNFItem[nItem][IT_TS][TS_OUTPERC]/100))
						aNfItem[nItem][IT_BASESOL] := nBsICMSt*(1+(aNfItem[nItem][IT_MARGEM]/100))
						aNfItem[nItem][IT_PAUTST]  := 0
					ElseIF  aNFItem[nItem][IT_TS][TS_APLIIVA] == "4" .And. aNFCab[NF_UFDEST]$aSX6[MV_UFPAUTA].And. nBsICMSt>(aNfItem[nItem][IT_BASESOL] * (75/100))
						aNfItem[nItem][IT_BASESOL] := nBsICMSt*(1+(aNfItem[nItem][IT_MARGEM]/100))
						aNfItem[nItem][IT_PAUTST]  := 0 //
					ElseIF aNFItem[nItem][IT_TS][TS_APLIIVA]$"1/3" .And. ( nBsICMSt >= aNfItem[nItem][IT_BASESOL] )
						aNfItem[nItem][IT_BASESOL] := nBsICMSt*(1+(aNfItem[nItem][IT_MARGEM]/100))
						aNfItem[nItem][IT_PAUTST]  := 0
					ElseIF aNFItem[nItem][IT_TS][TS_APLIIVA] == "3"
						aNfItem[nItem][IT_BASESOL] := nBsICMSt*(1+(aNfItem[nItem][IT_MARGEM]/100))
						aNfItem[nItem][IT_PAUTST]  := 0
					EndIf
				EndIf
				// Calculo do valor total para acertar o ICMS de Pauta
				// A pauta nao pode ser menor que o valor comercializado
				If !aSX6[MV_ICMPAUT]
					If ( nBsICMSt > aNfItem[nItem][IT_BASESOL] )
						aNfItem[nItem][IT_BASESOL] := nBsICMSt
						aNfItem[nItem][IT_PAUTST]  := 0
					EndIf
				EndIf
				//Confaz 21/2011. As condicoes para o calculo do ICMS-ST sao para as UF's contidas no parametro
				//MV_UFPST21, para clientes do tipo Consumidor Final e para Vendas nao presenciais, verificado pelo campo F4_VENPRES.
				If (aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFItem[nItem][IT_TS][TS_VENPRES] <> "1" .And. aNFCab[NF_UFDEST] $ cMV_UFPST .And. cTipoCliFor == "F" .And. ;
					(aNFCab[NF_LINSCR] .Or. SA1->A1_CONTRIB == "2") .And. aNFItem[nItem][IT_TS][TS_MKPSOL]=="1" ) .And. !lNConf21
					aNfItem[nItem][IT_BASESOL]	:= Iif( nReduzICMS > 0 .And. aSX6[MV_BASERET] == "S" , aNfItem[nItem][IT_BASEICM] , aNfItem[nItem][IT_BICMORI] )
				Endif
			EndIf
			If aNFItem[nItem][IT_TS][TS_IPIVFCF]$"34"
				aNfItem[nItem][IT_BASESOL]+= aNfItem[nItem][IT_IPIVFCF]
			EndIf
			//Base de Calculo do ICMS ST nas operacoes substituidos do MT,
			//com base no CNAE do Anexo XI e XVI do RICMS/MT de acordo com
			//os art. 87-J-6 ao art. 87-J-16 do RICMS/MT e decreto 392/2011
			If lRegESim .And. aPos[FP_A1_REGESIM] .And. aPos[FP_A2_REGESIM] .And. aPos[FP_A1_PERCATM];
				.And. aPos[FP_B1_REGESIM] .And. aNFItem[nItem][IT_TS][TS_MKPCMP]<>"1"
				//Base Original de ICMS.
				nBaseICM := aNfItem[nItem][IT_BASEICM] + Iif(aNFItem[nItem][IT_TS][TS_INCIDE] == "N", aNfItem[nItem][IT_VALIPI], 0)
				nBaseOri := aNfItem[nItem][IT_BICMORI] + Iif(aNFItem[nItem][IT_TS][TS_INCIDE] == "N", aNfItem[nItem][IT_VALIPI], 0)
				If ( aNfCab[NF_OPERNF]=="S" .And. !aNFCab[NF_TIPONF] $ "DB" ) .Or. ( aNfCab[NF_OPERNF]=="E" .And. aNFCab[NF_TIPONF] $ "DB" )
					If aNfCab[NF_REGESIM]=="1" .And. aNfItem[nItem][IT_PRD][SB_REGESIM] == "1"
						lRet := .T.
					EndIf
				ElseIf ( aNfCab[NF_OPERNF]=="E" .And. !aNFCab[NF_TIPONF] $ "DB" ) .Or. ( aNfCab[NF_OPERNF]=="S" .And. aNFCab[NF_TIPONF] $ "DB" )
					If aNfCab[NF_REGESIM] == "1" .And. aNfItem[nItem][IT_PRD][SB_REGESIM] == "1"
						lRet := .T.
					EndIf
				EndIf
				nValIEst := aNfItem[nItem][IT_VALICM]
				If cSimpNac $ "1/2" .And. (aNFCab[NF_OPERNF] == "S" .Or. (aNfCab[NF_OPERNF]=="E" .And. aNFCab[NF_TIPONF] $ "DB"))
					nBaseICM := aNfItem[nItem][IT_BASEICM]

					/* Na devolucao de venda faco a inversao das UF's para
					que a aliquota utilizada no calculo seja a mesma da venda,
					visto que ela nao eh gravada em nenhum campo. Desta forma o
					valor de nValIEst eh calculado na devolucao seguindo a mesma
					logica da NF original. */
					If aNFCab[NF_OPERNF] == "S"
						cUfOri := aNFCab[NF_UFORIGEM]
						cUfDest := aNFCab[NF_UFDEST]
					ElseIf aNfCab[NF_OPERNF] == "E" .And. aNFCab[NF_TIPONF] $ "DB"
						cUfOri :=  aNFCab[NF_UFDEST]
						cUfDest :=  aNFCab[NF_UFORIGEM]
					EndIf

					// Calculo da Aliquota de ICMS
					If ( cUfOri $ aSX6[MV_NORTE] )
						nAliqEst := 12 //MV_ICMTRF
					Else
						nAliqEst := IIf( cUfDest $ aSX6[MV_NORTE] , 7 , 12 ) //MV_ICMTRF
					EndIf

					nValIEst := aNfItem[nItem][IT_BASEICM]*(nAliqEst/100)

					If aSX6[MV_RNDICM]
						nValIEst := Round(nValIEst,2)
					Else
						nValIEst := NoRound(nValIEst,2)
					EndIf
				EndIf
				Do Case
					//Saida fora de MT
					Case aNFCab[NF_UFORIGEM] <> "MT" .And. aNFCab[NF_UFDEST] == "MT" .And. lRet
						If aNfCab[NF_OPERNF]=="E" .Or. (aNfCab[NF_OPERNF]=="S" .And. !aNFCab[NF_TIPONF]$"DB")
							aNfItem[nItem][IT_BASRESI] := nValIEst+( nBaseOri *(nPerCaTM/100))
							aNfItem[nItem][IT_VALRESI] := nBaseOri *(nPerCaTM/100)
						EndIf
					//Entrada fora MT
					Case aNFCab[NF_UFORIGEM] == "MT" .And. aNFCab[NF_UFDEST] <> "MT" .And. lRet
						If aNfCab[NF_OPERNF]=="E" .Or. (aNfCab[NF_OPERNF]=="S" .And. aNFCab[NF_TIPONF]$"DB")
							nPerCaTM := IIf(aNFCab[NF_TIPONF]$"DB" .And. aNFCab[NF_PERCATM] > 0, Iif( aNFItem[nItem][IT_TS][TS_PERCATM]>0 , aNFItem[nItem][IT_TS][TS_PERCATM] , aNfCab[NF_PERCATM] ), nPerCaTM)
							aNfItem[nItem][IT_BASRESI] := nValIEst+((nBaseOri*nPerCaTM)/100)
							aNfItem[nItem][IT_VALRESI] := nBaseOri*(nPerCaTM/100)
						EndIf
					//Saida/Entrada MT
					Case aNFCab[NF_UFORIGEM] == "MT" .And. aNFCab[NF_UFDEST] == "MT" .And. lRet
						If aNfCab[NF_OPERNF]=="S" .Or. ( aNfCab[NF_OPERNF]=="E" .And. aNFCab[NF_TIPONF] $ "D" .And. aNFCab[NF_CLIFOR] == "C" .And.;
															SA1->A1_REGESIM == "1" .And. !Empty(aNFItem[nItem][IT_RECORI]) )
							aNfItem[nItem][IT_BASRESI] := nValIEst + ( nBaseOri * (aNfItem[nItem][IT_MARGEM]/100) ) * (Iif(aNFItem[nItem][IT_TS][TS_PERCATM]>0,aNFItem[nItem][IT_TS][TS_PERCATM],aNfCab[NF_PERCATM])/100)
							aNfItem[nItem][IT_VALRESI] := ( nBaseOri * (aNfItem[nItem][IT_MARGEM]/100) ) * (Iif(aNFItem[nItem][IT_TS][TS_PERCATM]>0,aNFItem[nItem][IT_TS][TS_PERCATM],aNfCab[NF_PERCATM])/100)
						Else
							aNfItem[nItem][IT_BASRESI] := nValIEst+(nBaseICM*(aNfItem[nItem][IT_MARGEM]/100))*(nPerCaTM/100)  // /(MV_ICMPAD/100)
							aNfItem[nItem][IT_VALRESI] := (nBaseICM*(aNfItem[nItem][IT_MARGEM]/100) ) * (nPerCaTM/100)
						EndIf
				EndCase
			EndIf
		Else
			If 	!aNFCab[NF_TIPONF]$"DB"
				aNfItem[nItem][IT_BASESOL]	:= 0
			EndIf
		EndIf

		//Tratamento para atender o DECRETO N 35.679, de 13 de Outubro de 2010 - Pernambuco para o Ramo de Auto Peças onde no caso de revenda dentro
		//do estado deverá utilizar o custo de entrada para calcular a Base de Cálculo

		If aNFCab[NF_OPERNF]=="S" .And. aSX6[MV_ESTADO] == "PE" .And. aNfCab[NF_UFDEST] == "PE"  .And. aNfItem[nItem][IT_TS][TS_CUSENTR] =="1"

			//Posiciono na tabela SD1 para buscar o valor do Custo de Aquisição mais recente
			DbSelectArea("SD1")
			SD1->(DbSetOrder(5))
			SD1->(DbSeek(xFilial("SD1")+ aNfItem[nItem][IT_PRODUTO]+'ZZ',.T.))
			SD1->(DbSkip(-1))
			IF SD1->D1_COD == aNfItem[nItem][IT_PRODUTO]
				//Valor do custo da aquisição mais recente
				//Conforme Paragrafo 4 do Art. 1 do Decreto não devem ser considerados os descontos ou abatimentos concedidos para determinação
				//do custo da aquisição da Mercadoria
					nCustEnt := (( SD1->D1_CUSTO + SD1->D1_VALDESC ) / SD1->D1_QUANT)
					nCustEnt :=   nCustEnt * aNfItem[nItem][IT_QUANT] 
			
				If aSX6[MV_FISXMVA] .And. cPaisLoc == "BRA" .and. SD1->D1_MARGEM > 0
					//Cálculo Base de cálculo ST
					//Somente realizo o cálculo quando o MVA for ajustado
					nBsSTCalc += nCustEnt + ( ( nCustEnt * SD1->D1_MARGEM ) / 100 )
					aNfItem[nItem][IT_BASESOL]	:= nBsSTCalc
				EndIf
			EndIf
		EndIf
	Else
		aNfItem[nItem][IT_BASESOL]	:= 0
	EndIf

	IF aNFItem[nItem][IT_TS][TS_F4_STLIQ] == "1" .AND. aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ] > 0 .AND. (aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ] >0 .Or. aNfItem[nItem][IT_UFXPROD][UFP_ADICST] > 0)
		If( nReduzICMS > 0 .And. aNFItem[nItem][IT_TS][TS_APLREDP]=="1")
			aNfItem[nItem][IT_BASESOL]	:=	(aNfItem[nItem][IT_BASEICM] +  Iif(aNFItem[nItem][IT_TS][TS_INCIDE] == "N", aNfItem[nItem][IT_VALIPI],0))  * ( 1 + ( aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ]/100 ))
		Else//Recompõe a base do ICMS ST
			aNfItem[nItem][IT_BASESOL]	:=	(aNfItem[nItem][IT_BASEICM]*100/Iif(nReduzICMS <> 0, nReduzICMS,100) +  Iif(aNFItem[nItem][IT_TS][TS_INCIDE] == "N", aNfItem[nItem][IT_VALIPI],0))  * ( 1 + ( aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ]/100 ))
		Endif
	EndIF
	// Tratamento para o calculo diferenciado de Base para o Estado
	// de RN Artigo 944-I.
	If aSX6[MV_ALRN944] .And. aPos[FP_B1_PRN944I]
		If aNfItem[nItem][IT_PRD][SB_PRN944I] == "S"
			nBsICMSt := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",IIf (aNfItem[nItem][IT_PRCMEDP] <= 0, aNfItem[nItem][IT_VALMERC], aNfItem[nItem][IT_PRCMEDP]) - IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)+aNfItem[nItem][IT_VALIPI]+aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]
			aNfItem[nItem][IT_BASESOL]	:= nBsICMSt
		EndIf
	EndIf

	If aPE[PE_MACSOLICMS]
		aMaSolICMS := ExecBlock("MACSOLICMS",.f.,.f.,{aNfCab[NF_OPERNF],nItem,aNfItem[nItem][IT_BASESOL],aNfItem[nItem][IT_ALIQSOL],aNfItem[nItem][IT_VALSOL]})
		IF ValType(aMaSolICMS) == "A"
			IF Len(aMaSolICMS) == 3
				aNfItem[nItem][IT_BASESOL] := aMaSolICMS[1]
				aNfItem[nItem][IT_ALIQSOL] := aMaSolICMS[2]
				aNfItem[nItem][IT_VALSOL]  := aMaSolICMS[3]
			Endif
		Endif
	Endif

	MaItArred(nItem,{"IT_BASESOL"})
Else
	//Será substituído o valor das referências legado com o calculado pelo configurador
	AtuLegIcST(aNfItem, nItem)
EndIf

Return

/*/
MaAliqSol- Edson Maricate -08.12.1999
Calculo da Aliquota para operacoes de ICMS Solidario.
/*/
Function FisAlqSol(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
Local nMvIcmPad		:= aSX6[MV_ICMPAD]
Local nAliquota 	:= If ( aNfItem[nItem][IT_PRD][SB_PICM] == 0 , IIf(aNFItem[nItem][IT_TS][TS_ICM]<>"N" .Or. aNFItem[nItem][IT_TS][TS_AGREG]$"B",aNfItem[nItem][IT_ALIQICM],MaAliqIcms(nItem,.T.)), aNfItem[nItem][IT_PRD][SB_PICM] )
Local nAliqInt 		:= If ( aNfItem[nItem][IT_PRD][SB_PICM] == 0 , nMvIcmPad ,  aNfItem[nItem][IT_PRD][SB_PICM] )//Alíquota Interna
Local nAlqFecopST   := Iif( aNfItem[nItem][IT_PRD][SB_FECOP] == "1" , aNfItem[nItem][IT_PRD][SB_ALFECST] , 0 )
Local lSTD2			:= aPos[FP_D2_ALIQSOL]
Local lSTD1			:= aPos[FP_D1_ALIQSOL]
Local cMvEstado		:= aSX6[MV_ESTADO]
Local lSTAtacVar	:= IIf( aNFItem[nItem][IT_TS][TS_ATACVAR] == "1" .And. aNfItem[nItem][IT_PRD][SB_PICMENT] == 0 .And. cMvEstado == "CE" .And. aNFCab[NF_OPERNF] == "E" , .T. , .F.)
Local lSTConfCE 	:= IIf( aNFItem[nItem][IT_TS][TS_STCONF] == "1" .And. aNfItem[nItem][IT_PRD][SB_PICMRET] == 0 .And. cMvEstado == "CE" .And. aNFCab[NF_OPERNF] == "S" , .T. , .F.)
Local lAliqExc      := .F.
Local cDestino  	:= aNFCab[NF_UFDEST]
Local cSimpNac		:= aSX6[MV_CODREG]
Local cAliqDifST   	:= "2"
Local cMvEstIcm		:= aSX6[MV_ESTICM]
Local lCalcula   	:= .T.
Local lAliqEsp      := .F.
Local lOriSulSud 	:= aNFCab[NF_UFORIGEM] $ "SP|RJ|MG|PR|SC|RS"
Local lOriCeara		:= aNFCab[NF_UFORIGEM] == "CE"
Local lAtacado 		:= Substr(SM0->M0_CNAE,1,2) == "46" // Atacadistas
Local lVarejo  		:= Substr(SM0->M0_CNAE,1,2) == "47" // Varejista
Local lTribIcmST 	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMSST)

If !lTribIcmST
	If !Empty( ANFCab[NF_PNF_UF] ) .And. (AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE".Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])) .And. aNFCab[NF_OPERNF] == "S"
		nAliquota 	:= MaAliqIcms(nItem,.T.)
	Else
		If aNFCab[NF_TIPONF] == "D"
			nAliquota 	:= FISXALQORI(aNFCab, aSX6, nItem)		
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C" )
					If lSTD2
						dbSelectArea("SD2")
						MsGoto( aNFItem[nItem][IT_RECORI] )
						nAliquota  	:= SD2->D2_ALIQSOL
						lCalcula := .F.
					Endif
				Else
					If lSTD1 .And. cPaisLoc == "BRA"
						dbSelectArea("SD1")
						MsGoto( aNFItem[nItem][IT_RECORI] )
						nAliquota  := SD1->D1_ALIQSOL
						lCalcula := .F.
					Endif
				Endif
			EndIf
		Else
			If ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] )
				nAliquota 	:= FISXAlqDest(nItem, aSX6, aNfCab, aNFItem)
			EndIf
		EndIf
	EndIf

	If lCalcula

		If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
			If ( aNFItem[nItem][IT_EXCECAO][6] ) <> 0
				nAliquota 	:= aNfItem[nItem][IT_EXCECAO][6]
			EndIf
		EndIf

		//Tratamento Antecipacao ICMS  - Aliquota interna deve ser aplicada ao cálculo do ICMS ST
		If aNFItem[nItem][IT_TS][TS_ANTICMS] == "1"
			If ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .And. aNFCab[NF_TPCLIFOR] <> "X"
				nAliquota 	:= If ( aNfItem[nItem][IT_PRD][SB_PICM] == 0 , nMvIcmPad ,  aNfItem[nItem][IT_PRD][SB_PICM] )//Alíquota Interna
				// Verifica as Excecoes fiscais
				If ( !Empty(aNFItem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][7] <> "S")
					If ( aNFItem[nItem][IT_EXCECAO][1] ) <> 0
						If  aNFCab[NF_OPERNF] == "E" .And. aNfItem[nItem][IT_EXCECAO][31] == "2"//F7->F7_UFBUSCA inverte a aliquota interna para o destino
							nAliquota :=  aNFItem[nItem][IT_EXCECAO][6]	//Aliq. de ICMS Interna do destinatário.
						Else
							nAliquota :=  aNFItem[nItem][IT_EXCECAO][1]   //Aliq. de ICMS Interna
						Endif
					EndIf
				EndIf
			EndIf
		EndIf	
		MaFisFECP(nItem,,,"ALQ")
		// Nesta condicao especifica, quando a variavel nAliquota possui o conteudo de IT_ALIQICM (Verificar declaracao),
		// se for uma operacao interna e ja houve a majoracao de IT_ALIQICM (aNfItem[nItem][IT_ALIQFECP] > 0), nao posso
		// majorar novamente pois a referencia IT_ALIQICM ja veio majorada.
		If !(aNfItem[nItem][IT_PRD][SB_PICM] == 0 .And. (aNFItem[nItem][IT_TS][TS_ICM]<>"N" .Or. aNFItem[nItem][IT_TS][TS_AGREG]$"B") .And. aNfCab[NF_UFORIGEM] == aNfCab[NF_UFDEST] .And. aNfItem[nItem][IT_ALIQFECP] > 0 .And. nAliquota == aNfItem[nItem][IT_ALIQICM])
			If	aNfItem[nItem][IT_ALFCST] > 0
				nAliquota += aNfItem[nItem][IT_ALFCST]
			EndIf
		EndIf

		//Tratamento de aliquotas de ICMS-ST conforme decreto 29.560/2008 para o estado do Ceara
		If lSTAtacVar .and. (lAtacado .or. lVarejo)
			nAliquota := 0

			If lOriCeara // Ceara
				IF nAliqInt == 7
					nAliquota := Iif(lAtacado,2.70,1.05)
				ElseIf nAliqInt == 12
					nAliquota := Iif(lAtacado,4.60,1.80)
				ElseIf nAliqInt == 17
					nAliquota := Iif(lAtacado,6.50,2.60)
				ElseIf nAliqInt == 25
					nAliquota := Iif(lAtacado,7.26,7.26)        
				Endif
			Elseif lOriSulSud //"SP|RJ|MG|PR|SC|RS" // Sul e Sudeste exceto ES
				IF nAliqInt == 7
					nAliquota := Iif(lAtacado,6.80,5.52)
				ElseIf nAliqInt == 12
					nAliquota := Iif(lAtacado,11.60,9.46)
				ElseIf nAliqInt == 17
					nAliquota := Iif(lAtacado,16.50,13.40)
				ElseIf nAliqInt == 25
					nAliquota := Iif(lAtacado,33,33)
				Endif        
			Else // Norte, Nordeste e Centro Oeste e ES
				IF nAliqInt == 7
					nAliquota := Iif(lAtacado,4.70,3.46)
				ElseIf nAliqInt == 12
					nAliquota := Iif(lAtacado,8.10,5.93)
				ElseIf nAliqInt == 17
					nAliquota := Iif(lAtacado,11.50,8.40)
				ElseIf nAliqInt == 25
					nAliquota := Iif(lAtacado,25.85,25.85)
				Endif  
			Endif

			If aNFCab[NF_SIMPNAC] =="1"
				If lOriCeara // Ceara
					nAliquota += 5
				ElseIf lOriSulSud //"SP|RJ|MG|PR|SC|RS" // Sul e Sudeste exceto ES
					nAliquota += 7
				Else
					nAliquota += 12
				EndIf
			Endif

			lAliqEsp := .T. // Flag de aliquota especifica p/ controle da majoracao.
		Endif

		// Tratamento de aliquotas de ICMS-ST conforme decreto 28.443/2006 para o estado do Ceara
		// Conforme o decreto que visa atender operacoes internas de comercio, atacado, varejo e
		// industria do estado do Ceará atraves de aliquotas especificas de ICMS-ST.
		If lSTConfCE .And. aNFCab[NF_UFDEST] == "CE" //Ceara	
			nAliquota := 3
			lAliqEsp := .T. // Flag de aliquota especifica p/ controle da majoracao.	
		EndIf

		// Tratamento para o calculo diferenciado de aliquota para o
		// estado de RN Artigo 944-I.
		If aSX6[MV_ALRN944] .And. aPos[FP_B1_PRN944I]
			If aNFCab[NF_UFORIGEM] == "RN" .And. aNfItem[nItem][IT_PRD][SB_PRN944I] == "S"
				nAliquota:= aSX6[MV_ASRN944]
				lAliqEsp := .T. // Flag de aliquota especifica p/ controle da majoracao.
			ElseIf aNfItem[nItem][IT_PRD][SB_PRN944I] == "S"
				nAliquota:= aSX6[MV_AERN944]
				lAliqEsp := .T. // Flag de aliquota especifica p/ controle da majoracao.			
			EndIf
		EndIF

		//Simples Nacional - Aliquota ICMS solidario.
		If cSimpNac $ "1/2" .And. aNFCab[NF_OPERNF] == "S"
			//Busca RecNo do Produto para verificar campo que trata a aliquota interna
			//a ser tributada para o Simples Nacional através de Exceção Fiscal.
			//O campo deve ser informado no parâmetro MV_ALQDFB1.
			If aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST]
				If aPos[FP_MV_ALQDFB1]
					cAliqDifST := aNfItem[nItem][IT_PRD][SB_ALQDFB1]
				Endif

				//Se houver aliquota na excecao fiscal esta deve prevalecer a aliquota do simples nacional.
				If !Empty(aNFItem[nItem][IT_EXCECAO]) .And. aNFItem[nItem][IT_EXCECAO][6] <> 0
					lAliqExc := .T.
				EndIf

				If !lAliqExc .And. cAliqDifST $ "2 "
					nAliquota := Val(Subs(cMvEstIcm,AT(cDestino,cMvEstIcm)+2,5))
					If aNfItem[nItem][IT_ALFCST] > 0
						nAliquota += aNfItem[nItem][IT_ALFCST]
					EndIf
					lAliqEsp := .F.
				EndIf
			Endif
		EndIf

		// FECOP - CEARA - Caso no SB1 seja configurado para calcular FECOP a aliquota do Solidario sera Majorada em 2% - opcoes informadas no SB1 de 19 % ou  27%
		If (nAlqFecopST == 19 .Or. nAlqFecopST == 27) .And. aSX6[MV_ESTADO] == "CE" .And. aNFCab[NF_UFDEST] == "CE" .And. aNfCab[NF_OPERNF] == "S"
			nAliquota := nAlqFecopST
			lAliqEsp := .T. // Flag de aliquota especifica p/ controle da majoracao.
		EndIf

		// Controle para que caso tenha sido atribuida alguma aliquota
		// especifica para calculo do ICMS-ST o calculo do FCP nao seja
		// efetuado.
		If lAliqEsp .And. aNfItem[nItem][IT_ALFCST] > 0
			aNfItem[nItem][IT_BSFCPST] := 0
			aNfItem[nItem][IT_ALFCST]  := 0
			aNfItem[nItem][IT_VFECPST] := 0
		EndIf

	EndIf

	aNFitem[nItem][IT_ALIQSOL] := nAliquota
Else
	//Será substituído o valor das referências legado com o calculado pelo configurador
	AtuLegIcST(aNfItem, nItem)
EndIf

Return(nAliquota)

/*/
MaFisVSol-Edson Maricate  -08.12.1999
Esta rotina tem como objetivo calcular o valor do ICMS retido/solidario conforme definido do regulamento de ICMS.
/*/
Function FisValSol(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cCampo)

Local lDevolRet 	:= aSX6[MV_DEVRET]
Local cMVEstado		:= aSX6[MV_ESTADO]
Local lSTAtacVar	:= IIf( aNFItem[nItem][IT_TS][TS_ATACVAR] == "1" .And. aNfItem[nItem][IT_PRD][SB_PICMENT] == 0 .And. cMVEstado == "CE" .And. aNFCab[NF_OPERNF] == "E" , .T. , .F.)
Local lSTConfCE 	:= IIf( aNFItem[nItem][IT_TS][TS_STCONF] == "1" .And. aNfItem[nItem][IT_PRD][SB_PICMRET] == 0 .And. cMVEstado == "CE" .And. aNFCab[NF_OPERNF] == "S" , .T. , .F.)
Local nRedDec35701 	:= 0
Local cSimpNac		:= aSX6[MV_CODREG]
Local nAliIter  	:= 0
Local nRedICCE		:= 0
Local nRedSTCE		:= 0
Local lRegESim	    := aSX6[MV_REGESIM]
Local cMV_UFPST	    := aSX6[MV_UFPST21]
Local nRedBaST	  	:= Iif(Len(aNFItem[nItem][IT_EXCECAO]) > 0 .And. aNFItem[nItem][IT_EXCECAO][26] > 0,aNFItem[nItem][IT_EXCECAO][26],aNFItem[nItem][IT_TS][TS_BSICMST])
Local cExceRes13	:=	"6107|6108|6929"
//Tratamento específico de PB para ignorar o tratamento para venda não presencial
Local lNConf21	  	:= Iif( aNfCab[NF_UFDEST]=="PB" .And. aNfCab[NF_VTOTPED]>0 .And. aNfCab[NF_VTOTPED]<500, .T. ,.F. )
Local nReduzICMS  	:= 0
Local lCalcula 		:= .T.
Local lConfaz21    	:= (aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. aNFItem[nItem][IT_TS][TS_VENPRES] <> "1" .And. aNFCab[NF_UFDEST] $ cMV_UFPST .And. aNFItem[nItem][IT_TS][TS_MKPSOL]=="1" .And. !lNConf21 .And. (aNFCab[NF_LINSCR] .Or. aNfCab[NF_CLIEDEST]))
Local lEntSemICM 	:= (aNFCab[NF_OPERNF] == "E" .And. !aNFCab[NF_TIPONF] $ "DB" .And. aNFCab[NF_SIMPNAC] == "1" .And. (aNFItem[nItem][IT_TS][TS_ICM] == "N" .Or. !cSimpNac $ "1/2"))
Local cMVStAliq     := aSX6[MV_UFSTALQ]
Local lDifCont		:= aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. aNFCab[NF_UFDEST]$aSX6[MV_BASDSSE] .And. aNFCab[NF_UFDEST]$aSX6[MV_UFBDST] .And. ((aNfCab[NF_OPERNF] == "S" .And. aNfCab[NF_TPCLIFOR] $ "F/L" ) .Or. (aNfCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S"))
Local nAliqSol		:= 0
Local aMaSolICMS  	:= {}
Local lTribIcmST 	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMSST)

DEFAULT cCampo := ""

If !lTribIcmST
	// Carrega a reducao da base do ICMS
	If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,14] > 0
		nReduzICMS := aNfItem[nItem,IT_EXCECAO,14]
	Else
		nReduzICMS := aNFItem[nItem][IT_TS][TS_BASEICM]
	EndIf

	aNfItem[nItem][IT_VLSLXML] := 0

	If !(aNFitem[nItem][IT_TIPONF ]$'IP')

		If aNfItem[nItem][IT_BASESOL] <> 0

			If aNFCab[NF_TIPONF] $ "DB" .Or. aNFItem[nItem][IT_TS][TS_PODER3] =="D"
				If !Empty(aNFItem[nItem][IT_RECORI])
					If aNFCab[NF_TIPONF] $ "DB"
						If ( aNFCab[NF_CLIFOR] == "C")
							dbSelectArea("SD2")
							MsGoto(aNFItem[nItem][IT_RECORI])
							If (SD2->D2_ICMSRET > 0 .Or. Abs(aNfItem[nItem][IT_VALSOL]-SD2->D2_ICMSRET)<=1 .Or. lDevolRet) .And. aNfItem[nItem][IT_QUANT] = SD2->D2_QUANT .And. Iif(!lDevolRet ,SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0,SD2->D2_ICMSRET > 0)
								aNfItem[nItem][IT_VALSOL] := SD2->D2_ICMSRET
								lCalcula := .F.
							Else
								If (!aNfCab[NF_CALCSUF]$'IN ' .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC]) .Or. aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT
									aNfItem[nItem][IT_VALSOL] := (SD2->D2_ICMSRET / SD2->D2_QUANT) * aNfItem[nItem][IT_QUANT]
									lCalcula := .F.
								EndIf
							EndIf
						Else
							dbSelectArea("SD1")
							MsGoto(aNFItem[nItem][IT_RECORI])
							If (SD1->D1_ICMSRET > 0 .Or. Abs(aNfItem[nItem][IT_VALSOL]-SD1->D1_ICMSRET)<=1 .Or. lDevolRet) .And. aNfItem[nItem][IT_QUANT] = SD1->D1_QUANT .And. Iif(!lDevolRet ,SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0,SD1->D1_ICMSRET > 0)
								aNfItem[nItem][IT_VALSOL]  := SD1->D1_ICMSRET							
								aNFitem[nItem][IT_ALIQSOL] := SD1->D1_ALIQSOL							
								lCalcula := .F.
							Else // Devolução parcial
								If (lDevolRet .And. SD1->D1_ICMSRET > 0) .And. (aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT)
									aNfItem[nItem][IT_VALSOL] := (SD1->D1_ICMSRET / SD1->D1_QUANT) * aNfItem[nItem][IT_QUANT]
									aNFitem[nItem][IT_ALIQSOL] := SD1->D1_ALIQSOL
									lCalcula := .F.
								EndIf
							EndIf

						EndIf
					Else
						If ( aNFCab[NF_CLIFOR] == "C")
							dbSelectArea("SD1")
							MsGoto(aNFItem[nItem][IT_RECORI])
							If (SD1->D1_ICMSRET > 0 .Or. Abs(aNfItem[nItem][IT_VALSOL]-SD1->D1_ICMSRET)<=1) .And. aNfItem[nItem][IT_QUANT] = SD1->D1_QUANT .And. Iif(!lDevolRet ,SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0,SD1->D1_ICMSRET > 0)
								// 29.02.2012 - FNC 00000004584/2012-00
								// Independente do valor encontrado (via excecao fiscal ou nao), o valor da base
								// e o valor do imposto deve ser o mesmo da nota original
								aNfItem[nItem][IT_VALSOL] := SD1->D1_ICMSRET
								aNfItem[nItem][IT_BASESOL]:= SD1->D1_BRICMS
								lCalcula := .F.
							EndIf
						Else
							dbSelectArea("SD2")
							MsGoto(aNFItem[nItem][IT_RECORI])
							If (SD2->D2_ICMSRET > 0 .Or. Abs(aNfItem[nItem][IT_VALSOL]-SD2->D2_ICMSRET)<=1) .And. aNfItem[nItem][IT_QUANT] = SD2->D2_QUANT .And. Iif(!lDevolRet ,SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0,SD2->D2_ICMSRET > 0)
								aNfItem[nItem][IT_VALSOL] := SD2->D2_ICMSRET
								aNfItem[nItem][IT_BASESOL]:= SD2->D2_BRICMS
								lCalcula := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If lCalcula

				If aNFItem[nItem][IT_TS][TS_INCSOL]=="A"
					aNfItem[nItem][IT_VALSOL] := ( aNfItem[nItem][IT_BASESOL]*(aNfItem[nItem][IT_MARGEM]/100) )
					aNfItem[nItem][IT_VALSOL] := ( aNfItem[nItem][IT_VALSOL] * aNfItem[nItem][IT_ALIQSOL]/100 )
					If nRedBaST > 0
						aNfItem[nItem][IT_VALSOL] := (aNfItem[nItem][IT_VALSOL]*nRedBaST)/100
					EndIf
					MaItArred(nItem,{"IT_VALSOL"})
					aNfItem[nItem][IT_VALICM] -= Max(0,NoRound(aNfItem[nItem][IT_VALSOL]*aNfItem[nItem][IT_ALIQICM]/100,2))
					MaItArred(nItem,{"IT_VALICM"})
				Else
					//Base Dupla ST para Goias Art. 65 do RCTE/GO. // tdn.totvs.com/pages/releaseview.action?pageId=267797477
					IF aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. (aNFCab[NF_UFDEST]$cMVStAliq .OR. ;
					(aNfCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFORIGEM]$cMVStAliq .And. aNFCab[NF_TIPONF] == "D"  ))  .And. ;
					((aNfCab[NF_OPERNF] == "S" .And. aNfCab[NF_TPCLIFOR] == "F" ) .Or. (aNfCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S"))
						nAliqSol := aNfItem[nItem][IT_ALIQSOL]-aNFItem[nItem][IT_ALIQICM]
					Else
						nAliqSol := aNfItem[nItem][IT_ALIQSOL]
					Endif

					aNfItem[nItem][IT_VALSOL] :=  (aNfItem[nItem][IT_BASESOL] * nAliqSol)/100

					If aNFItem[nItem][IT_TS][TS_CRPRST] == 0
						MaItArred(nItem,{"IT_VALSOL"})
					EndIf
					//Tratamento implementado para os estados de MG e AM referente ao credito presumido do contratante do servico de transporte.
					//    Este tratamento deve refletir o calculo do ICMS Normal de direito do contratante e o ICMS Retido como debito na apuracao
					//    jah deduzindo o Credito presumido.
					//    Ex: Em uma operacao interna, a entrada do CTR no valor de R$1.000,00 deverah ficar da seguinte forma:
					//
					//    ICMS Normal
					//    BC = 1000, Aliq = 18, VL ICMS = 180
					//
					//    ICMS Retido
					//    BC = 1000, Aliq = 18, VL ICMS Ret = 144, CRED PRES = 36
					//
					//    OBS: Este valor retido de 144 eh lancado automaticamente na Apuracao de ICMS/ST em outros debitos devido a configuracao
					//         da TES(F4_CREDST=3)
					//         da TES(F4_CREDST=3)                                                                                                |
					If	!(cMVEstado$"MG/AM" .And.;
						aNFItem[nItem][IT_TS][TS_CRPRST]<>0 .And.;
						(AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])))

						If !lSTAtacVar .And. !lSTConfCE

							//  Reduz o valor do ICMS conforme margem de reducao do ST, para subtrair do valor do ICMS-ST calculado.
							//  Tanto nos casos do campo TS_APLIRED = 1 ou TS_APLIRED = 3, o ICMS só é reduzido para o cálculo do ST
							//	o ICMS prórpio da operação não terá nenhuma alteração.
							If aNFItem[nItem][IT_TS][TS_APLIRED]=="1" .And. nRedBaST > 0
								//Deserfis1-6167 - Ajuste para considerar o crédito de 7%  
								aNfItem[nItem][IT_VALSOL] -= aNfItem[nItem][IT_BICMORI] * ROUND(nRedBaST/100 * Iif(aNFItem[nItem][IT_TS][TS_ALICRST]<=0, nAliqSol/100, aNFItem[nItem][IT_TS][TS_ALICRST]/100),2)
								// Neste caso iremos reduzir o valor do ICMS conforme foi a redução de BC da ST e/ou conforme a diferença da alíquota
								// vide Help do campo F4_APLIRED para mais detalhes
							ElseIf aNFItem[nItem][IT_TS][TS_APLIRED]=="3" .And. ( nRedBaST > 0)
								If aNfCab[NF_SUFRAMA] .And. aSX6[MV_RPCBIZF] .And.  aNfItem[nItem][IT_DESCZF]> 0 .And. (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]) > 0 .And. aNfCab[NF_UFDEST]$aSX6[MV_RPCBIUF]
									IF (aNfItem[nItem][IT_DESCZF]-(aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]))==0 // Se tiver desconto apenas de pis/cof
										aNfItem[nItem][IT_VALSOL] -= (((aNfItem[nItem][IT_BICMORI]+((aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]))) * Iif(nRedBaST==0,100,nRedBaST)/100)* ((aNfItem[nItem][IT_ALIQICM]/100)) )
									Else
										aNfItem[nItem][IT_VALSOL] -= (((aNfItem[nItem][IT_BICMORI]+(aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]))) * Iif(nRedBaST==0,100,nRedBaST)/100)* ((aNfItem[nItem][IT_ALIQICM]/100)) )
									EndIf
								Else
									aNfItem[nItem][IT_VALSOL] -= aNfItem[nItem][IT_BICMORI]* Iif(nRedBaST==0,100,nRedBaST)/100*  Iif(aNFItem[nItem][IT_TS][TS_ALICRST]<=0, aNfItem[nItem][IT_ALIQICM]/100, aNFItem[nItem][IT_TS][TS_ALICRST]/100)
								EndIf
								MaItArred(nItem,{"IT_VALSOL"})
							ElseIf aNFItem[nItem][IT_TS][TS_APLIRED]=="4"
								aNfItem[nItem][IT_VALSOL] -= (aNfItem[nItem][IT_BICMORI] * Iif(aNFItem[nItem][IT_TS][TS_ALICRST]<=0, nAliqSol/100, aNFItem[nItem][IT_TS][TS_ALICRST]/100))
							Else
								//Conforme a legislação Lei 9.480 de 17.12.2010 para o Estado de Mato Grosso,
								//Nao deduzir o valor do ICMS proprio no valor de ICMS ST.
								If  aNFItem[nItem][IT_TS][TS_ICMSTMT]=="1"
									IF aNFItem[nItem][IT_TS][TS_ALICRST]<=0
										aNfItem[nItem][IT_VALSOL] -= (aNfItem[nItem][IT_VALICM] + aNfItem[nItem][IT_DESCZF]  - aNfItem[nItem][IT_DESCZFPIS] - aNfItem[nItem][IT_DESCZFCOF])
									Else
										aNfItem[nItem][IT_VALSOL] -= (aNfItem[nItem][IT_BASEICM]* aNFItem[nItem][IT_TS][TS_ALICRST]/100) + (aNfItem[nItem][IT_DESCZF]  - aNfItem[nItem][IT_DESCZFPIS] - aNfItem[nItem][IT_DESCZFCOF])
									EndIf
								Endif
							EndIf
							//Decreto 35.701 de 19/10/2010 para vendas para o estado de Pernambuco
							If aNFItem[nItem][IT_TS][TS_PR35701]<>0 .And. aNFCab[NF_OPERNF]=='S' .And. aNFCab[NF_UFDEST]=="PE"
								If aNfItem[nItem][IT_PAUTST] <> 0
									nRedDec35701 := aNfItem[nItem][IT_VALICM] - ((aNfItem[nItem][IT_VALICM])* aNFItem[nItem][IT_TS][TS_PR35701]/100)
									aNfItem[nItem][IT_VALSOL] := ( (aNfItem[nItem][IT_BASESOL] * nAliqSol)/100 ) - nRedDec35701
								Else
									nRedDec35701 :=((aNfItem[nItem][IT_BASEICM] * aNfItem[nItem][IT_ALIQICM]/100)* aNFItem[nItem][IT_TS][TS_PR35701]/100)
									aNfItem[nItem][IT_VALSOL] := ( (aNfItem[nItem][IT_BASESOL] * nAliqSol)/100 ) - nRedDec35701
								Endif
								MaItArred(nItem,{"IT_VALSOL"})
							EndIf

							//PROTOCOLO ICMS 12/96:  Nas operações interestaduais originárias dos Estados signatários (São Paulo,
							//Rio de Janeiro, Minas Gerais, Rio Grande do Sul, Goiás, Paraná, Tocantins, Espírito Santo, Pernambuco, Bahia e Ceará),
							//destinados aos estabelecimentos situados no Estado do Ceará, fica atribuída ao estabelecimento remetente, na qualidade
							// de sujeito passivo por substituição, a responsabilidade pela retenção e recolhimento do ICMS conforme cálculo abaixo
							If aNFCab[NF_UFORIGEM] $ "SP|RJ|GO|RS|MG|BA|PR|ES|TO|PE|CE" .And. aNFCab[NF_UFDEST] == "CE" .And. aNFItem[nItem][IT_TS][TS_REDBCCE] <> 0
								nRedICCE := ((aNfItem[nItem][IT_BASEICM] * aNfItem[nItem][IT_ALIQICM]/100)* aNFItem[nItem][IT_TS][TS_REDBCCE]/100)

								nRedSTCE := (aNfItem[nItem][IT_BASESOL] * aNFItem[nItem][IT_TS][TS_REDBCCE]/100)
								nRedSTCE := (nRedSTCE * nAliqSol)/100

								aNfItem[nItem][IT_VALSOL] := nRedSTCE - nRedICCE
								MaItArred(nItem,{"IT_VALSOL"})
							Endif

							// Credito Outorgado concedido  no calculo do ICMS Retido nas
							// operacoes Interestaduais com o Estado de MG.
							//RETIRADO O TRATAMENTO DE ACORDO COM A FNC 00000019742/2014
							//	If aNFItem[nItem][IT_TS][TS_CROUTGO] > 0
							//		If aNfItem[nItem][IT_DESCZF] > 0
							//			aNfItem[nItem][IT_VALSOL] += (((aNfItem[nItem][IT_DESCZF]/aNfItem[nItem][IT_ALIQICM]) * 100) * aNFItem[nItem][IT_TS][TS_CROUTGO]/100)
							//		Else
							//			aNfItem[nItem][IT_VALSOL] += (aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_TS][TS_CROUTGO]/100)
							//		EndIf
							//	Endif
						EndIf
					EndIf
				EndIf

				//Credito Presumido(20%) sobre prestacao servico de transporte com ICMS/ST devido ao alienante/remetente
				//  da operacao - Decreto 44.147/2005 (MG)
				//- Esta sendo considerado a entrada deste credito como 100% do valor, sem a deducao (20%).Portanto devo
				//  subtrair do ICMS/ST Retido o valor de credito (20%), gravar na referencia LF_CRPRST que devera ser
				//  tratado na apresentacao das informacoes complementares da apuracao.
				If aNFItem[nItem][IT_TS][TS_CRPRST]<>0
					aNfItem[nItem][IT_VLCSOL]	:=	aNfItem[nItem][IT_VALSOL]
					aNfItem[nItem][IT_VALSOL]	-=	(aNfItem[nItem][IT_VALSOL]/100)*aNFItem[nItem][IT_TS][TS_CRPRST]
					MaItArred(nItem,{"IT_VALSOL"})
				EndIf

				//Cálculo de ICMS ST com carga líquida
				IF aNFItem[nItem][IT_TS][TS_F4_STLIQ] == "1"	.AND. aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ] > 0
					//Se for Simples e a aliquota do simples estiver preenchida
					If aNFCab[NF_SIMPNAC] == "1" .And. aNfItem[nItem][IT_UFXPROD][UFP_ADICST] > 0
						aNfItem[nItem][IT_ALIQSOL]  :=  aNfItem[nItem][IT_UFXPROD][UFP_ADICST]
						aNfItem[nItem][IT_VALSOL]   :=  (aNfItem[nItem][IT_BASESOL] * aNfItem[nItem][IT_ALIQSOL]) / 100
				ElseIf aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ] >0
						If substr(aNfItem[nItem][IT_LIVRO][LF_CLASFIS],1,1) $ "1/2/3/5/8"
							aNfItem[nItem][IT_ALIQSOL]	:=	aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ] + aNfItem[nItem][IT_UFXPROD][UFP_RDCTIMP]
							aNfItem[nItem][IT_VALSOL] 	:= 	(aNfItem[nItem][IT_BASESOL] * aNfItem[nItem][IT_ALIQSOL]) / 100
						Else
						aNfItem[nItem][IT_ALIQSOL]	:=	aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ]
							aNfItem[nItem][IT_VALSOL] 	:= 	(aNfItem[nItem][IT_BASESOL] * aNfItem[nItem][IT_ALIQSOL]) / 100
						EndIf
					EndIF
				EndIf

				//Simples Nacional - ICMS solidario.
				If ((cSimpNac $ "1/2" .And. (aNFCab[NF_OPERNF] == "S" .Or. (aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_TIPONF]$"DB")) .And. aNfItem[nItem][IT_VALSOL] > 0) .Or. lConfaz21 .Or. lEntSemICM)
					If aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST]
						nAliIter := IIf(aNFCab[NF_UFORIGEM] $ "SP|RJ|MG|RS|PR|SC" .And. (aNFCab[NF_UFDEST] $ aSX6[MV_NORTE] .Or. aNFCab[NF_UFDEST] $ cMV_UFPST),7,12)
						If (Year( aNfCab[NF_DTEMISS] ) >= 2013							.And.	;
							SubStr( aNfItem[nItem][IT_CLASFIS] , 1 , 1 ) $ "1|2|3|8"	.And.	;
							!Alltrim( aNfItem[nItem][IT_CF]) $cExceRes13 .And.	;
							(cSimpNac $ "1/2" .Or. aNFCab[NF_SIMPNAC] == "1"))

							nAliIter :=  4
						EndIf
						If Len(aNfItem[nItem][IT_EXCECAO]) > 0 .And. aNfItem[nItem][IT_EXCECAO][7] <> "S"
							If aNfItem[nItem][IT_EXCECAO][2] > 0 .AND. (aNfItem[nItem][IT_EXCECAO][2] == 4 .OR. aNfItem[nItem][IT_EXCECAO][2] == 7 .OR. aNfItem[nItem][IT_EXCECAO][2] == 12)
								/*
								Somente serão permitidas alíquotas interestaduais, conforme parecetr abaixo:
								http://tdn.totvs.com/pages/releaseview.action?pageId=95027214

								Estou verificando se o conteúdo do F7_ALIQEXT é interestadual, pois em algumas situações específicas a alíquota interestadual a ser utilizada não é a padrão
								Por exemplo, SP->MG tem alíquota interestadual padrão de 12, porém pode haver convênio entre os estados permitindo alíquota interestadual de 7 ao invés de 12, então deverá considerar alíquota da exceção
								Um exemplo disso é o caso da Issue http://jiraproducao.totvs.com.br/browse/MSERV-701
								Caso vier outra alíquota que não seja interestadual não será considerada para nAliIter, já que os clientes utilizam o campo F7_ALIQEXT pra informar alíquota reduzida do simples, e não a interestadual
								*/
								nAliIter := aNfItem[nItem][IT_EXCECAO][2] //Aliquota Externa
							EndIf
						EndIf
					Else
						/*

						Antes de alterar este trecho verificar o seguinte parecer:

						http://tdn.totvs.com/pages/releaseview.action?pageId=95027214

						"Deverá ser deduzido a alíquota interna do produto, quando se tratar de
						operação realizada dentro do Estado, mesmo que o ICMS próprio seja calculado
						dentro do Simples Nacional." Ou seja, nao devera ser utilizada a aliquota
						do SIMPLES para deduzir o ICMS proprio do ST.

						Caso seja utilizaca excecao fiscal, a aliquota considerada nos calculos de
						ICMS-ST, [IT_ALIQSOL], eh o campo "Aliq. de ICMS Destino" - IT_EXCECAO[6],
						mesmo que se trate de operacao interna. Nao devera ser utilizado o campo
						"Aliquota Interna" da excecao - IT_EXCECAO[1] pois este campo eh para o
						ICMS Proprio apenas.

						Para Calculo do Simples nacional a Aliquota do Proprio não pode estar majorada com FECP

						*/

						nAliIter := aNfItem[nItem][IT_ALIQSOL]

						If aNfItem[nItem][IT_ALFCST] > 0 .And. !Empty(aNFItem[nItem][IT_EXCECAO])  .And. aNfItem[nItem][IT_EXCECAO][7] <> "S"
							If aNfItem[nItem][IT_EXCECAO][6] > 0
								MaFisFECP(nItem,,,"ALQ")
								nAliIter := aNfItem[nItem][IT_EXCECAO][6] + aNfItem[nItem][IT_ALIQFECP]
							EndIf
						EndIf
					EndIf
					If ((aNFCab[NF_SIMPNAC] == "1" .And. aNFItem[nItem][IT_TS][TS_ICMSTMT]=="1") .Or. aNFCab[NF_SIMPNAC] <> "1") .AND. (aNfItem[nItem][IT_ALIQICM] == nAliIter .or. aNfItem[nItem][IT_TS][TS_ANTICMS] <> "1")
						// Confaz21 - Utilizar tratamento do parametro MV_BASERET
						// Entrada de fornecedores do simples sem ICMS - Utilizar IT_BICMORI quando nao tenho ICMS calculado em IT_BASEICM
						If lConfaz21 .Or. lEntSemICM
							aNfItem[nItem][IT_VALSOL] := (aNfItem[nItem][IT_BASESOL]*(nAliqSol/100)) - (Iif(nReduzICMS > 0 .And. aSX6[MV_BASERET] == "S",aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_BICMORI])*(nAliIter/100))
						Else // Demais casos - Utilizar IT_BASEICM p/ considerar a base reduzida (se houver reducao) de ICMS.
							// Se configurado diferimento + ST (TS_ICMSDIF == 5) preciso somar o valor do ICMS diferido para que não seja deduzido do ICMS-ST o valor do ICMS "cheio" da operação.
							aNfItem[nItem][IT_VALSOL] := ((aNfItem[nItem][IT_BASESOL]*(nAliqSol/100));
							- Iif(lDifCont,0,Iif(aNFItem[nItem][IT_TS][TS_ICMSTMT]=="2",0,(Iif(aNfItem[nItem][IT_BASEICM] > 0 ,aNfItem[nItem][IT_BASEICM], aNfItem[nItem][IT_BICMORI])*(nAliIter/100)))));
							+ IIf(aNFItem[nItem][IT_TS][TS_ICMSDIF]=="5", aNfItem[nItem][IT_ICMSDIF], 0)
						EndIf
					EndIf
				EndIf

				// Campo p/ tratamentos especificos de alguns créditos presumidos que alteram a forma de cálculo do ICMS-ST.
				If aNfItem[nItem][IT_TS][TS_FCALCPR] == "1" .And. aNfCab[NF_UFORIGEM] == "SC" .And. aNfCab[NF_UFDEST] == "SC" .And. aNfItem[nItem][IT_TS][TS_CRDPRES] > 0
					// O valor "cheio" de ST (antes de deduzir o ICMS próprio) é calculado com base na alíquota do destino - a alíquota do crédito presumido.
					aNfItem[nItem][IT_VALSOL] := aNfItem[nItem][IT_BASESOL] * ((aNfItem[nItem][IT_ALIQSOL] - aNfItem[nItem][IT_TS][TS_CRDPRES]) / 100)
					// O valor do ICMS próprio a deduzir do ST também é calculado com base na alíquota da operação própria - a alíquota do crédito presumido.
					aNfItem[nItem][IT_VALSOL] -= aNfItem[nItem][IT_BASEICM] * ((aNfItem[nItem][IT_ALIQICM] - aNfItem[nItem][IT_TS][TS_CRDPRES]) / 100)
					MaItArred(nItem,{"IT_VALSOL"})
				EndIf

				// Controle p/ nao apresentar valores negativos de ICMS-ST.
				If aNfItem[nItem][IT_VALSOL] < 0 .Or. aNfItem[nItem][IT_VALSOL] - aNfItem[nItem][IT_VFECPST] < 0
					aNfItem[nItem][IT_VALSOL] := 0
					If aSx6[MV_ZRSTNEG]
						aNfItem[nItem][IT_BASESOL] := 0
					EndIf
				EndIf
			EndIf // lCalcula
		Else
			aNfItem[nItem][IT_VALSOL]	:= 	0
		EndIf
	EndIf
	// Caso nao haja valor de ICMS solidario deve-se zerar a base
	// de calculo do ICMS-ST
	//
	// Essa alteracao foi comentada devido a uma consulta feita pelo cliente Nestle a Sefaz de Sao Paulo
	// onde a Sefaz informa que, mesmo que o valor de ICMS Retido seja zerado, caso exista um valor de Base
	// de Calculo, este devera ser informado no documento fiscal e posteriormente no XML (Tag - vBCST).
	// Alteracao feita atraves do chamado TGQDW4.
	// Foi feito um teste com a transmissao da nota fiscal e nao houve erro de validacao/transmissao.
	//Tags:
	//	<modBCST>0</modBCST>
	//	<vBCST>5.36</vBCST>
	//	<pICMSST>18.00</pICMSST>
	//	<vICMSST>0</vICMSST>

	//If aNfItem[nItem][IT_VALSOL] == 0
	//	aNfItem[nItem][IT_BASESOL]	:= 0
	//EndIf

	//Base de Calculo do ICMS ST nas operacoes substituidos do MT,
	//com base no CNAE do Anexo XI e XVI do RICMS/MT de acordo com
	//os art. 87-J-6 ao art. 87-J-16 do RICMS/MT e decreto 392/2011
	If lRegESim .And. aNfItem[nItem][IT_BASRESI] > 0 .And. aNFItem[nItem][IT_TS][TS_MKPCMP]<>"1" .AND. lCalcula .And. cCampo <> "IT_BASESOL"

		nAliIter := aNfItem[nItem][IT_ALIQSOL]
		If Len(aNfItem[nItem][IT_EXCECAO]) > 0 .And. aNfItem[nItem][IT_EXCECAO][7] <> "S"
			If aNFCab[NF_OPERNF] == "E" .And. aNfItem[nItem][IT_EXCECAO][1] > 0
				nAliIter := aNfItem[nItem][IT_EXCECAO][1]
			ElseIf aNfItem[nItem][IT_EXCECAO][6] > 0
				nAliIter := aNfItem[nItem][IT_EXCECAO][6]
			EndIf
		EndIf

		MaItArred(nItem,{"IT_BASRESI"})

		//-- Validação para zerar a BASE do ICMS ST caso a movimentação se trate de complemento de ICMS ST.
		IF!(aNFitem[nItem][IT_TIPONF ]$'IP')
			aNfItem[nItem][IT_BASESOL] := aNfItem[nItem][IT_BASRESI]/(nAliIter/100)
		ELSE
			aNfItem[nItem][IT_BASESOL] := 0
		ENDIF

		aNfItem[nItem][IT_VALSOL]  := aNfItem[nItem][IT_VALRESI]
		aNfItem[nItem][IT_ALIQSOL] := nAliIter

	EndIf

	If aPE[PE_MACSOLICMS]
		aMaSolICMS := ExecBlock("MACSOLICMS",.f.,.f.,{aNfCab[NF_OPERNF],nItem,aNfItem[nItem][IT_BASESOL],aNfItem[nItem][IT_ALIQSOL],aNfItem[nItem][IT_VALSOL]})
		IF ValType(aMaSolICMS) == "A"
			IF Len(aMaSolICMS) == 3
				aNfItem[nItem][IT_BASESOL] := aMaSolICMS[1]
				aNfItem[nItem][IT_ALIQSOL] := aMaSolICMS[2]
				aNfItem[nItem][IT_VALSOL]  := aMaSolICMS[3]
			Endif
		Endif
	Endif

	If aNfItem[nItem][IT_VLSLXML] == 0 .And. aNfItem[nItem][IT_VALSOL] > 0 //Guarda valor calculado pelo sistema
		aNfItem[nItem][IT_VLSLXML] := aNfItem[nItem][IT_VALSOL]
	Endif

	MaFisFECP(nItem,,,"BSE|VLR")

	//Tratamento para quando o preço praticado é maior que o preço de pauta, levando o ICMS ST a ficar negativo 
	If aNfItem[nItem][IT_PAUTST] > 0 .And. (aNfItem[nItem][IT_VALSOL] < 0 .Or. aNfItem[nItem][IT_VALSOL] - aNfItem[nItem][IT_VFECPST] < 0)
		aNfItem[nItem][IT_VALSOL] := 0
		If aSx6[MV_ZRSTNEG]
			aNfItem[nItem][IT_BASESOL] := 0
		EndIf
	EndIf
Else
	//Será substituído o valor das referências legado com o calculado pelo configurador
	AtuLegIcST(aNfItem, nItem)
EndIf

Return(Nil)

/*
MaMargem- Edson Maricate -08.12.1999
Calculo da Margem de lucro para calculo do ICMS Solidario.
*/
Function FISXMARGEM(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)

Local nMargem  := If ( aNfCab[NF_CLIFOR] =='F' .And. aNfCab[NF_OPERNF] == 'E' , aNfItem[nItem][IT_PRD][SB_PICMENT] , aNfItem[nItem][IT_PRD][SB_PICMRET] )
Local lSTD2      := aPos[FP_D2_MARGEM]
Local lSTD1      := aPos[FP_D1_MARGEM]
Local lNotDevol := .T.
Local nAliquota := 0
Local nAlqInter := 0
Local nMargem1  := 0
Local nMargemOri:= 0
Local nX		:= 0
Local lUFOri	:= .F.
Local lIVAAju   := .F.
Local lRastro	 := aPE[PE_MAFISRASTRO]
Local lRastroLot := .F.
Local lMvaFrete  := (aNFItem[nItem][IT_TS][TS_DESPICM]$"1#3#5" .Or. aSX6[MV_DESPICM]) .And. (aNfItem[nItem][IT_FRETE] > 0 .Or. aNfItem[nItem][IT_AUTONOMO] > 0  .Or. aNfCab[NF_AUTONOMO] > 0)
Local nTamMVA := TamSx3("D2_MARGEM")[2]
Local nPosTgIcST := 0
Local lTribIcmST := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMSST)

If !lTribIcmST
	If aNFCab[NF_TIPONF] == "D"
		If !Empty(aNFItem[nItem][IT_RECORI])
			If ( aNFCab[NF_CLIFOR] == "C" )
				If lSTD2
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nMargem	:=	SD2->D2_MARGEM
					lNotDevol	:= .F.
				Endif
			Else
				If lSTD1
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nMargem  := SD1->D1_MARGEM
					lNotDevol	:= .F.
				Endif
			Endif
		EndIf
	EndIf

	If lNotDevol

		// Margem alterada para operação com Frete embutido ou não na base do st
		// RICMS RS, decreto 37699/1997
		If lMvaFrete
			If aNFCab[NF_OPERNF] == "S"  .And.  aNfItem[nItem][IT_PRD][SB_MVAFRP] > 0
				nMargem := aNfItem[nItem][IT_PRD][SB_MVAFRP]
			Elseif aNFCab[NF_OPERNF] == "E"  .And.  aNfItem[nItem][IT_PRD][SB_MVAFRC] > 0
				nMargem := aNfItem[nItem][IT_PRD][SB_MVAFRC]
			Endif
		EndIf
		// Aplica a formula padrao do MVA para encontrar o MVA Ajustado, considerando as aliquotas e a Margem preenchida no Cadastro do Produto
		If aSX6[MV_FISXMVA] .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. !aNFItem[nItem][IT_TS][TS_CONSUMO]$"S" .And. nMargem > 0
			nAlqInter	:=	Iif( aNfItem[nItem,IT_ALIQICM] > 0 , aNFItem[nItem,IT_ALIQICM] , MaAliqIcms( nItem ) )
			nAliquota	:=	Iif( aNfItem[nItem,IT_ALIQSOL] > 0 , aNFItem[nItem,IT_ALIQSOL] , MaAliqSoli( nItem ) )

			nMargem		:=	Round(( ( ( ( 1 + nMargem / 100 ) * ( 1 - nAlqInter / 100 ) ) / ( 1 - nAliquota / 100 ) ) - 1 ) * 100,nTamMVA)
		EndIf

		// Utiliza o MVA preenchido na tabela CFC (Regras de tributos na esfera estadual)
		If	 (aNfItem[nItem][IT_UFXPROD][UFP_MVAES] = "1" .Or. Empty(aNfItem[nItem][IT_UFXPROD][UFP_MVAES])) .Or. ;
			(aNfItem[nItem][IT_UFXPROD][UFP_MVAES] = "2" .And. aNFCab[NF_OPERNF] == "E"  )   .Or. ;
			(aNfItem[nItem][IT_UFXPROD][UFP_MVAES] = "3" .And. aNFCab[NF_OPERNF] == "S"  )

			If lMvaFrete .And. aNfItem[nItem][IT_UFXPROD][UFP_MVAFRU] > 0
				nMargem := aNfItem[nItem][IT_UFXPROD][UFP_MVAFRU] // Margem para operação com Frete
			ElseIf aNfItem[nItem][IT_UFXPROD][UFP_MARGEM] > 0
				nMargem	:=	aNfItem[nItem][IT_UFXPROD][UFP_MARGEM]
			ElseIf aNFItem[nItem][IT_TS][TS_F4_STLIQ] == "1" .AND. aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ] > 0 .AND. (aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ] >0 .Or. aNfItem[nItem][IT_UFXPROD][UFP_ADICST] > 0)
				nMargem	:=	aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ]
			EndIf

		EndIf
		// Verifica as Excecoes Fiscais
		If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
			If  lMvaFrete .And. aNFItem[nItem][IT_EXCECAO][30] > 0
				nMargem :=  aNFItem[nItem][IT_EXCECAO][30]   // Margem para operação com Frete
			ElseIf ( aNFItem[nItem][IT_EXCECAO][3] ) <> 0
				nMargem :=  aNFItem[nItem][IT_EXCECAO][3]   //Margem de Lucro Presumida
			EndIf
		EndIf

	EndIf

	//Tratamento do calculo do IVA Ajustado
	//ATENCAO !!! Este tratamento so e relaizado quando o produto possui controle de rastreabilidade por Sub-Lote
	IF !Empty(aNfItem[nItem][IT_ANFORI2]) .And. Len(aNfItem[nItem][IT_ANFORI2][1][1]) > 0
		If ( aNfItem[nItem][IT_PRD][SB_IVAAJU] == "1" .And. (Iif(lRastro,lRastroLot := ExecBlock("MAFISRASTRO",.F.,.F.),aNfItem[nItem][IT_PRD][SB_RASTRO]=="S"))  )
			nMargemOri := nMargem
			For nX := 1 to Len (aNfItem[nItem][IT_ANFORI2])
				nAliquota := Iif(aNFItem[nItem,IT_ALIQICM]==0, MaAliqIcms(nItem),aNFItem[nItem,IT_ALIQICM])
				nAlqInter := aNFItem[nItem][IT_ANFORI2][nX][02]
				If !Empty(aNFItem[nItem][IT_ANFORI2][nX][01]) .And. aNFItem[nItem][IT_ANFORI2][nX][01]<>aSX6[MV_ESTADO]
					lUFOri := .T.
				EndIf
				If aSX6[MV_ESTADO] $ 'SP/SC/MG' .And. lUFOri .And. aNFCab[NF_UFDEST] == aSX6[MV_ESTADO] .And. (lRastroLot .Or. aNfItem[nItem][IT_PRD][SB_RASTRO] $ 'S')
					lIVAAju := .T.
				EndIf
				If nAliquota > 12 .And. lIVAAju
					nMargem  := ((((1+nMargem/100)*(1-nAlqInter/100))/(1-nAliquota/100))-1)*100
					nMargem1 += nMargem*(aNFItem[nItem][IT_ANFORI2][nX][3]/100)
					aNFItem[nItem][IT_ANFORI2][nX][4] := nMargem1
					nMargem1 := 0
				EndIf
				If !lIVAAju
					aNFItem[nItem][IT_ANFORI2][nX][4] := nMargemOri
				EndIf
				lUFOri := .F.
				lIVAAju := .F.
			Next nX
		EndIf
	EndIf

	//Tratamento Antecipacao ICMS - Margem Solidário IVA Ajustado
	If aNFItem[nItem][IT_TS][TS_ANTICMS] == "1"
		If ( aNfItem[nItem][IT_PRD][SB_IVAAJU] == "1") .And. (aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .And. aSX6[MV_ESTADO] $ "SP/SC/MG" .And. aNFCab[NF_TPCLIFOR] <> "X"//Somente entrada usando IVA Ajustado e Antecipacao de ICMS e Estado de São Paulo
			nAliquota := If ( aNfItem[nItem][IT_PRD][SB_PICM] == 0 , aSX6[MV_ICMPAD] ,  aNfItem[nItem][IT_PRD][SB_PICM] )//Alíquota Interna
			// Verifica as Excecoes fiscais
			If ( !Empty(aNFItem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][7] <> "S") .And. ( aNFItem[nItem][IT_EXCECAO][1] ) <> 0		
				nAliquota :=  aNFItem[nItem][IT_EXCECAO][1]   //Aliq. de ICMS Interna		
			EndIf
			nAlqInter := Iif(aNFItem[nItem,IT_ALIQICM]==0, MaAliqIcms(nItem),aNFItem[nItem,IT_ALIQICM])//Alíquota interestadual
			If nAliquota > 12 //Aliquota Interna superior a 12%
				nMargem  := ((((1+nMargem/100)*(1-nAlqInter/100))/(1-nAliquota/100))-1)*100 //IVA Ajustado
			EndIf
		EndIf
	EndIf

	aNFitem[nItem][IT_MARGEM] := nMargem
Else
	If (nPosTgIcST := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ICMSST})) >0
		aNfItem[nItem][IT_MARGEM]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_MVA]
	EndIf
EndIf

Return(nMargem)

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisUltEnt

Função que faz tratamento dos valores de ICMS ST recolhidos anteriormente
considerando as últimas aquisições. Estes cálculos somente são efetuados
quando não existe rastro configurado no sistema.

@param aNfItem,   array, Array com as informações do ANFITEM
@param aSX6,      array, Array com o cacheamento dos parâmetros SX6

@author Erick Dias
@since 25/02/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISXULTENT(nItem, aNfItem, aNfCab, aSX6, cCampo,lIcmRAnt)

DEFAULT lIcmRAnt := .F.

IF ((Substr(aNfItem[nItem][IT_CLASFIS],2,2) == "60".or. aNfItem[nItem][IT_CSOSN]=="500") .And. !aNFCab[NF_TPCLIFOR] $ "F") .Or. lIcmRAnt

    //Verifica se já foi realizada consulta das últimas aquisições para este produto
    IF (aNfItem[nItem][IT_RESSARC][RI_PRODUTO] <> aNfItem[nItem][IT_PRODUTO]) .OR. (aSX6[MV_ULTAQUI] == "2" .AND. cCampo == "IT_QUANT")

			If aNFCab[NF_TIPONF] $ "DB" .AND. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] == "C"
				//Devolução de venda
				//Aqui é preciso estonar o valor que foi gerado no XML, não é necessário fazer query nem média ponderada

				xSFTOrig(aNfItem, aNFCab, nItem, aSX6)
			Else
				//Neste caso fará a query para buscar as últimas aquisições e realizar a média ponderada, ou a entrada da devolução de compra
        //Para o método 2, mesmo que a query tenha sido realizada, quando a quantidade é alterada terá que
        //compor nova média ponderada, por este motivo precisa realizar nova query e novos cálculos
				xFisQryUEnt(aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT], aSX6[MV_ULTAQUI], aNfCab[NF_DTEMISS], aNfCab[NF_TPBANCO], aNfItem, nItem, aNFCab, aSX6)
			Endif

			//Faz os cálculos
			xFisCaclUEnt(aNfItem, nItem, .T., aSX6)

    Else
      //Para as demais alterações somente atualizará os cálculos das médias já obtidas.
    	xFisCaclUEnt(aNfItem, nItem, .T., aSX6)
    EndIF
Else

    //Aqui não possui nem CST 60 e nem CSOSN 500, por este motivo precisa zerar os valores do ressarcimento
    //Atualiza as referências
    xFisCaclUEnt(aNfItem, nItem, .F., aSX6)

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisQryUEnt

Função que fará query na SD1 em busca das últimas aquisições de um determinado
produto, considerando a data, quantidade e método de busca enviados na funçao

@param cCodProd,   caracter, Código de Produto
@param nQtdeSai,   numérico, Quantidade do item da nota fiscal de saída
@param cMetodo,    caracter, Método de obter as últimas aquisições
@param dDataRefer, date    , Data de referência, para buscar as últimas entradas anteriores a esta data
@param cTpDb,      caracter, Tipo do banco de dados do ambiente
@param aNfItem,    array, Array com as informações do ANFITEM
@param aNfItem,    array, Array com as informações do ANFCAB
@param aSX6,      array, Array com o cacheamento dos parâmetros SX6

@author Erick Dias
@since 21/02/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function xFisQryUEnt(cCodProd, nQtdeSai, cMetodo, dDataRefer, cTpDb, aNfItem, nItem, aNFCab, aSX6)

Local cSelect		:= ""
Local cFrom			:= ""
Local cWhere		:= ""
Local cAliasQry	:= "SD1"
Local nTotQtdeE	:= 0
Local cQtdeRow	:= 0
Local nValRet		:= 0
Local nBasRet		:= 0
Local nPerRet		:= 0
Local nICMSSub	:= 0
Local nBaseFcp	:= 0
Local nPercFcp	:= 0
Local nFcp		  := 0
Local lDevCompra	:= .F.
Local nQtdeSaldo	:= nQtdeSai
Local nMult			:= 0

If cMetodo == '1'
	//Para o primeiro método, deve-se considerar somente a última nota fiscal, por este motivo virá somente 1 quantidde de linha
	cQtdeRow	:= "1"
Elseif cMetodo == '2' .OR. cMetodo == '3'
	//Já para o segundo método, deve-se compor a média ponderada, e para isso estou limitando no máximo 50 linhas de retorno, por questões de performance.
	cQtdeRow	:= "50"
EndIF

//Somente garantindo que estará tudo maiúsculo para comparação
cTpDb	:= UPPER(Alltrim(cTpDb))

//Inicializa as referências de ressarcimento com valores zerados
aNfItem[nItem][IT_RESSARC][RI_PRODUTO]		     		:= cCodProd
aNfItem[nItem][IT_RESSARC][RI_ICMS_ANT_UNIT]	 		:= nValRet
aNfItem[nItem][IT_RESSARC][RI_BASE_ANT_UNIT]	 		:= nBasRet
aNfItem[nItem][IT_RESSARC][RI_PERC_ANT_UNIT]	 		:= nPerRet
aNfItem[nItem][IT_RESSARC][RI_ICMS_SUBST_UNIT]	  := nICMSSub
aNfItem[nItem][IT_RESSARC][RI_BASE_FCP_ANT_UNIT]  := nBaseFcp
aNfItem[nItem][IT_RESSARC][RI_PERC_FCP_ANT_UNIT]  := nPercFcp
aNfItem[nItem][IT_RESSARC][RI_FCP_ANT_UNIT]		     := nFcp

#IFDEF TOP

	//Se não houver produto preenchido e método nada será feito
	If !Empty(cCodProd) .AND. !Empty(cMetodo) .AND. !Empty(cQtdeRow)

		//Para filtrar a quantidade de linhas da query, para SQL e INFORMIX deve ser feito na seção do select com FIRST e TOP

		IF aNFCab[NF_TIPONF] $ "DB" .AND. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_CLIFOR] == "F" .AND. !Empty(aNFItem[nItem][IT_RECORI])
			//Trecho para buscar a nota original de compra para realizar a devolução de venda. Neste caso não farei média ponderada, uma vez que conseguimos determinar a nota original.
			//Devolução de compra
			dbSelectArea("SD1")
			MsGoto(aNFItem[nItem][IT_RECORI])
			lDevCompra	:= .T.

		Else
			//Query para buscar as últimas aquisições
			If cTpDb == "INFORMIX"
				cSelect += " FIRST " + cQtdeRow

			Elseif !cTpDb $ "ORACLE/POSTGRES/MYSQL/DB2/SQLITE"
				cSelect += " TOP " + cQtdeRow

			Elseif cTpDb == "ORACLE"
				cSelect += " * FROM ( SELECT "
			EndIF

			cSelect	+= " SD1.D1_BRICMS,	  SD1.D1_ICMSRET, "
			cSelect	+= " SD1.D1_ALIQSOL,  SD1.D1_BASNDES, "
			cSelect	+= " SD1.D1_ICMNDES,  SD1.D1_ALQNDES, "
			cSelect	+= " SD1.D1_VALANTI,  SD1.D1_QUANT,  "
			cSelect	+= " SD1.D1_UM,       SD1.D1_VALICM, "
			cSelect	+= " SD1.D1_VFCPANT,  SD1.D1_BFCPANT,   
			cSelect	+= " SD1.D1_AFCPANT, SD1.D1_VFECPST, "
			cSelect	+= " SD1.D1_BSFCPST, SD1.D1_ALFCPST, "
			cSelect	+= " SD1.D1_FCPAUX "

			cFrom   += RetSQLName("SD1") + " SD1 "

			cWhere  += "SD1.D1_FILIAL  = " + ValToSQL( xFilial("SD1") ) + " AND "
			cWhere  += "SD1.D1_COD     = " + ValToSQL(cCodProd ) + " AND "
			cWhere  += "SD1.D1_DTDIGIT <= " + ValToSql(dDataRefer) + " AND "
			cWhere  += "SD1.D1_TES     <> ' ' AND "
			cWhere  += "SD1.D1_NFORI   = ' ' AND "
			cWhere  += "SD1.D1_SERIORI = ' ' AND "
			cWhere  += "SD1.D1_TIPO NOT IN('B','D','P','I','C') AND "
			cWhere  += " (SD1.D1_ICMNDES > 0 OR SD1.D1_VALANTI > 0 or SD1.D1_ICMSRET > 0 ) AND "
			cWhere  += " (D1_QUANT <> D1_QTDEDEV) AND "

			cWhere  += "SD1.D_E_L_E_T_ = ' '"

			cWhere  += " Order by SD1.D1_DTDIGIT desc, SD1.D1_NUMSEQ desc "

			If cTpDb == "DB2"
				cWhere  += " FETCH FIRST " + cQtdeRow + " ROWS ONLY "

			ElseIF (cTpDb == "POSTGRES" .OR. cTpDb == "MYSQL" .or. cTpDb == "SQLITE")
				cWhere  += " LIMIT " + cQtdeRow

			EndIf

			If cTpDb == "ORACLE"
				cWhere  += " ) WHERE ROWNUM <= " + cQtdeRow
			EndIf

			cSelect := "%" + cSelect + "%"
			cFrom   := "%" + cFrom   + "%"
			cWhere  := "%" + cWhere  + "%"

			cAliasQry := GetNextAlias()

			BeginSQL Alias cAliasQry

				SELECT
				%Exp:cSelect%
				FROM
				%Exp:cFrom%
				WHERE
				%Exp:cWhere%

			EndSQL

		EndiF

		//Laco da query
		Do While !(cAliasQry)->(Eof())

			//Somente continuará se a quantidade for maiormaior que zero
			IF (cAliasQry)->D1_QUANT	 > 0

				//Acumula quantidade de produtos da compra processada
				nTotQtdeE += (cAliasQry)->D1_QUANT

				If aSX6[MV_ULTAQUI] == "3"
					Iif ( nQtdeSaldo > (cAliasQry)->D1_QUANT,  nMult := (cAliasQry)->D1_QUANT, 	nMult := nQtdeSaldo )
				EndIf
				//Verifica se foi digitado manualmente pelo usuário
				IF (cAliasQry)->D1_ICMNDES > 0					
					nValRet	+= Iif(aSX6[MV_ULTAQUI] == "3", (cAliasQry)->D1_ICMNDES / (cAliasQry)->D1_QUANT * nMult , (cAliasQry)->D1_ICMNDES) 
					nBasRet	+= Iif(aSX6[MV_ULTAQUI] == "3",(cAliasQry)->D1_BASNDES / (cAliasQry)->D1_QUANT * nMult , (cAliasQry)->D1_BASNDES)

					nICMSSub += Iif(aSX6[MV_ULTAQUI] == "3", ((nBasRet * (aSX6[MV_ICMPAD]/100)) - (cAliasQry)->D1_ICMNDES) / (cAliasQry)->D1_QUANT * nMult,;
					 (nBasRet * (aSX6[MV_ICMPAD]/100)) - (cAliasQry)->D1_ICMNDES)
				
					If (cAliasQry)->D1_ALQNDES > 0
						nPerRet	:= (cAliasQry)->D1_ALQNDES
					Else
						nPerRet := aSX6[MV_ICMPAD]
					EndIf
					
				//Verifica se é antecipação tributária
				ElseIF (cAliasQry)->D1_VALANTI > 0
					nValRet	+= Iif(aSX6[MV_ULTAQUI] == "3" ,(cAliasQry)->D1_VALANTI / (cAliasQry)->D1_QUANT * nMult , (cAliasQry)->D1_VALANTI)
					nBasRet	+= Iif(aSX6[MV_ULTAQUI] == "3" ,(cAliasQry)->D1_BRICMS / (cAliasQry)->D1_QUANT * nMult  , (cAliasQry)->D1_BRICMS )   
					nPerRet	:= (cAliasQry)->D1_ALIQSOL
					nICMSSub += Iif(aSX6[MV_ULTAQUI] == "3" , (cAliasQry)->D1_VALICM / (cAliasQry)->D1_QUANT * nMult ,(cAliasQry)->D1_VALICM)

				//Verifica se ICMS ST foi destacado na nota fiscal de entrada
				ElseIf (cAliasQry)->D1_ICMSRET > 0
					nValRet	 += Iif(aSX6[MV_ULTAQUI] == "3" , (cAliasQry)->D1_ICMSRET / (cAliasQry)->D1_QUANT * nMult ,(cAliasQry)->D1_ICMSRET)
					nBasRet	 += Iif(aSX6[MV_ULTAQUI] == "3" , (cAliasQry)->D1_BRICMS / (cAliasQry)->D1_QUANT * nMult ,(cAliasQry)->D1_BRICMS)
					nICMSSub += Iif(aSX6[MV_ULTAQUI] == "3" , (cAliasQry)->D1_VALICM / (cAliasQry)->D1_QUANT * nMult ,(cAliasQry)->D1_VALICM)
					nPerRet	 := (cAliasQry)->D1_ALIQSOL
				EndIf

				//FECP
				If (cAliasQry)->D1_VFCPANT > 0 //FECP recolhido anteriormente
					nFcp		+= Iif(aSX6[MV_ULTAQUI] == "3" , (cAliasQry)->D1_VFCPANT / (cAliasQry)->D1_QUANT * nMult ,(cAliasQry)->D1_VFCPANT)
					nBaseFcp	+= Iif(aSX6[MV_ULTAQUI] == "3" , (cAliasQry)->D1_BFCPANT / (cAliasQry)->D1_QUANT * nMult ,(cAliasQry)->D1_BFCPANT)
					nPercFcp	:= (cAliasQry)->D1_AFCPANT

				ElseIf (cAliasQry)->D1_VFECPST > 0 //FECP ST tributadp					
					nFcp		+= Iif(aSX6[MV_ULTAQUI] == "3" , (cAliasQry)->D1_VFECPST / (cAliasQry)->D1_QUANT * nMult, (cAliasQry)->D1_VFECPST)
					nBaseFcp	+= Iif(aSX6[MV_ULTAQUI] == "3" , (cAliasQry)->D1_BSFCPST / (cAliasQry)->D1_QUANT * nMult, (cAliasQry)->D1_BSFCPST)
					nPercFcp	:= Iif((cAliasQry)->D1_FCPAUX > 0 , (cAliasQry)->D1_FCPAUX ,(cAliasQry)->D1_ALFCPST )
				EndIF

				//Para o segundo método, preciso ver se a quantidade já foi suportada.
				//Se for devolução de compra também não precisarei passar para a próxima entrada, já que conseguimos determinar o item em questão.
				If (cMetodo $ "2|3" .AND. nTotQtdeE >= nQtdeSai) .OR. lDevCompra
					//Se a quantidade foi suportada não preciso processar próxima nota de entrada
					Exit
				EndIF

				If nQtdeSai > (cAliasQry)->D1_QUANT .AND. aSX6[MV_ULTAQUI] == "3"
					nQtdeSaldo -= (cAliasQry)->D1_QUANT
				EndIF
			EndIF

			(cAliasQry)->(DbSKip())
		Enddo

		//Fecha o Alias antes de sair da função
		IF !lDevCompra
			dbSelectArea(cAliasQry)
			dbCloseArea()
		EndIF

		If nICMSSub < 0
			nICMSSub := 0	
		EndIf

		//Atualiza as referências com valores unitários
		aNfItem[nItem][IT_RESSARC][RI_PRODUTO]		     		:= cCodProd
		aNfItem[nItem][IT_RESSARC][RI_ICMS_ANT_UNIT]	 		:= Iif(aSX6[MV_ULTAQUI] == "3",nValRet, nValRet / nTotQtdeE )
		aNfItem[nItem][IT_RESSARC][RI_BASE_ANT_UNIT]	 		:= Iif(aSX6[MV_ULTAQUI] == "3",nBasRet, nBasRet / nTotQtdeE )
		aNfItem[nItem][IT_RESSARC][RI_PERC_ANT_UNIT]	 		:= nPerRet
		aNfItem[nItem][IT_RESSARC][RI_ICMS_SUBST_UNIT]	 	:= Iif(aSX6[MV_ULTAQUI] == "3",nICMSSub, nICMSSub / nTotQtdeE )
		aNfItem[nItem][IT_RESSARC][RI_BASE_FCP_ANT_UNIT] 	:= Iif(aSX6[MV_ULTAQUI] == "3",nBaseFcp, nBaseFcp / nTotQtdeE )
		aNfItem[nItem][IT_RESSARC][RI_PERC_FCP_ANT_UNIT] 	:= nPercFcp
		aNfItem[nItem][IT_RESSARC][RI_FCP_ANT_UNIT]		 		:= Iif(aSX6[MV_ULTAQUI] == "3",nFcp, nFcp / nTotQtdeE )

	EndIF

#ENDIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisCaclUEnt

Função de cálculo dos valores de ICMS recolhido anteriormente, considerando
as últimas entradas, fazendo a proporcionalidade dos valores das últimas entradas
em função da quantidade de saída

@param aNfItem,   array, Array com as informações do ANFITEM

@author Erick Dias
@since 25/02/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function xFisCaclUEnt(aNfItem, nItem, lCalc, aSX6)

//Indica que deverá efetuar os cálculos
If lCalc
    aNfItem[nItem][IT_BSTANT]   := Iif(aSX6[MV_ULTAQUI] == "3", aNfItem[nItem][IT_RESSARC][RI_BASE_ANT_UNIT], aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_RESSARC][RI_BASE_ANT_UNIT] )
    aNfItem[nItem][IT_VSTANT]   := Iif(aSX6[MV_ULTAQUI] == "3", aNfItem[nItem][IT_RESSARC][RI_ICMS_ANT_UNIT], aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_RESSARC][RI_ICMS_ANT_UNIT] )
    aNfItem[nItem][IT_VICPRST]  := Iif(aSX6[MV_ULTAQUI] == "3", aNfItem[nItem][IT_RESSARC][RI_ICMS_SUBST_UNIT], aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_RESSARC][RI_ICMS_SUBST_UNIT] )
    aNfItem[nItem][IT_PSTANT]   := aNfItem[nItem][IT_RESSARC][RI_PERC_ANT_UNIT]
    aNfItem[nItem][IT_BFCANTS]   := Iif(aSX6[MV_ULTAQUI] == "3", aNfItem[nItem][IT_RESSARC][RI_BASE_FCP_ANT_UNIT], aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_RESSARC][RI_BASE_FCP_ANT_UNIT] )
    aNfItem[nItem][IT_PFCANTS]   := aNfItem[nItem][IT_RESSARC][RI_PERC_FCP_ANT_UNIT]
    aNfItem[nItem][IT_VFCANTS]   := Iif(aSX6[MV_ULTAQUI] == "3", aNfItem[nItem][IT_RESSARC][RI_FCP_ANT_UNIT], aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_RESSARC][RI_FCP_ANT_UNIT] )

Else
    //Aqui indica que deverá zerar os valores das referências
    aNfItem[nItem][IT_BSTANT]   := 0
    aNfItem[nItem][IT_VSTANT]   := 0
    aNfItem[nItem][IT_VICPRST]  := 0
    aNfItem[nItem][IT_PSTANT]   := 0
    aNfItem[nItem][IT_BFCANTS]   := 0
    aNfItem[nItem][IT_PFCANTS]   := 0
    aNfItem[nItem][IT_VFCANTS]   := 0

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xSFTOrig

Função qeu posiciona a SFT da nota fiscal de origem na hipótese de devolução.
Os campos que esta função trata são os campos que não possuem campos nas tabelas
SD1 e SD2, que a reprocessamento não "apaga" estes valores, por este motivo
não é possível utilizar a SD1 e SD2 para obter os valores da nota fiscal de origem,
estes valores são gravados somente na SFT, por este motivo é necessário retornar na SFT.

@param aNfItem,   array, Array com as informações do ANFITEM
@param aNFCab,   array, Array com as informações do ANFCAB
@param nItem,   numérico, número o item dentro do ANFITEM.

@author Erick Dias
@since 08/02/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function xSFTOrig(aNfItem, aNFCab, nItem, aSX6)

//Inicio as referências com valores zerados.
aNfItem[nItem][IT_RESSARC][RI_PRODUTO]		     		:= ""
aNfItem[nItem][IT_RESSARC][RI_ICMS_ANT_UNIT]	 		:= 0
aNfItem[nItem][IT_RESSARC][RI_BASE_ANT_UNIT]	 		:= 0
aNfItem[nItem][IT_RESSARC][RI_PERC_ANT_UNIT]	 		:= 0
aNfItem[nItem][IT_RESSARC][RI_ICMS_SUBST_UNIT]	 	:= 0
aNfItem[nItem][IT_RESSARC][RI_BASE_FCP_ANT_UNIT] 	:= 0
aNfItem[nItem][IT_RESSARC][RI_PERC_FCP_ANT_UNIT] 	:= 0
aNfItem[nItem][IT_RESSARC][RI_FCP_ANT_UNIT]		 		:= 0

//Certifico se é uma devolução e o recno de origem está preenchido.
If aNFCab[NF_TIPONF] $ "DB" .And. !Empty(aNFItem[nItem][IT_RECORI])	.AND. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] == "C"

	//Devolução de venda
	dbSelectArea("SD2")
	MsGoto(aNFItem[nItem][IT_RECORI])

	SFT->(dbSetOrder(1))
	IF SFT->(MsSeek(xFilial("SFT")+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+Padr(D2_ITEM,TamSx3("FT_ITEM")[1])+D2_COD)))

		//Atualizar as referências com os valores da nota fiscal original.
		aNfItem[nItem][IT_RESSARC][RI_PRODUTO]		     := SFT->FT_PRODUTO
		aNfItem[nItem][IT_RESSARC][RI_ICMS_ANT_UNIT]	 := Iif(aSX6[MV_ULTAQUI] == "3", SFT->FT_VSTANT, SFT->FT_VSTANT / SFT->FT_QUANT )
		aNfItem[nItem][IT_RESSARC][RI_BASE_ANT_UNIT]	 := Iif(aSX6[MV_ULTAQUI] == "3", SFT->FT_BSTANT, SFT->FT_BSTANT / SFT->FT_QUANT )
		aNfItem[nItem][IT_RESSARC][RI_PERC_ANT_UNIT]	 := SFT->FT_PSTANT
		aNfItem[nItem][IT_RESSARC][RI_ICMS_SUBST_UNIT]	 := Iif(aSX6[MV_ULTAQUI] == "3", SFT->FT_VICPRST, SFT->FT_VICPRST / SFT->FT_QUANT )
		aNfItem[nItem][IT_RESSARC][RI_BASE_FCP_ANT_UNIT] := Iif(aSX6[MV_ULTAQUI] == "3", SFT->FT_BFCANTS, SFT->FT_BFCANTS / SFT->FT_QUANT )
		aNfItem[nItem][IT_RESSARC][RI_PERC_FCP_ANT_UNIT] := SFT->FT_PFCANTS
		aNfItem[nItem][IT_RESSARC][RI_FCP_ANT_UNIT]		 := Iif(aSX6[MV_ULTAQUI] == "3", SFT->FT_VFCANTS, SFT->FT_VFCANTS / SFT->FT_QUANT )

	EndIF

EndIF

Return

/*/{Protheus.doc} MaFisDbST()
@description Esta funcao retorna se o valor do ICMS-ST deverá ou não
ser descontado da base do PIS/COFINS/CSLL (apuração e retenção).
Estão concentradas aqui as regras genéricas para o desconto. Regras
especificas deverão ser implementadas na função do próprio tributo.
@author joao.pellegrini
/*/
Function FISXDBST(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cImposto)

Local lRet := .F.
Local cMVDBST := ""

// Obtendo valor do parametro MV_DBSTXXX conforme o imposto
Do Case
	Case cImposto == "PS2"
		cMVDBST := aSX6[MV_DBSTPIS]
	Case cImposto == "CF2"
		cMVDBST := aSX6[MV_DBSTCOF]
	Case cImposto == "PIS"
		cMVDBST := aSX6[MV_DBSTPSR]
	Case cImposto == "COF"
		cMVDBST := aSX6[MV_DBSTCFR]
	Case cImposto == "CSL"
		cMVDBST := aSX6[MV_DBSTCLR]
EndCase

// Conteudo dos parametros MV_DBSTXXX:
// 1 - Nunca retira
// 2 - Retira se houver credito do ICMS ST
// 3 - Retira se nao houver credito do ICMS ST
// 4 - Retira se houver credito do ICMS normal
// 5 - Retira se nao houver credito do ICMS normal
// 6 - Sempre retira
Do Case
	Case cMVDBST == "1"
		lRet := .F.
	Case cMVDBST == "2"
		lRet := (aNFItem[nItem][IT_TS][TS_CREDST] == "1" .Or. (aNFItem[nItem][IT_TS][TS_CREDST] == "2" .And. aNfCab[NF_OPERNF] == "E"))
	Case cMVDBST == "3"
		lRet := (aNFItem[nItem][IT_TS][TS_CREDST] == "4" .Or. (aNFItem[nItem][IT_TS][TS_CREDST] == "2" .And. aNfCab[NF_OPERNF] == "S"))
	Case cMVDBST == "4"
		lRet := aNFItem[nItem][IT_TS][TS_CREDICM] == "S"
	Case cMVDBST == "5"
		lRet := aNFItem[nItem][IT_TS][TS_CREDICM] == "N"
	Case cMVDBST == "6"
		lRet := .T.
EndCase

Return lRet

/*/
MaFisTST - Alexandre Lemes - 24/09/2012
Verifica a base para calculo do ICMS sobre o frete quando o calculo e feito a parte do calculo do ICMS
*/
Function FISXTST(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta)
Local lTribGen		:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FRTEMB)
Local nPosTgFrtE 	:= 0

DEFAULT cExecuta  	:= "BSE|ALQ|VLR"

If !lTribGen
	//Calcula o ICMS do frete embarcador quando:
	//- a transportadora for do mesmo estado;
	//- a transportadora for um autonomo;
	//- a transportadora for de outro estado, mas nao inscrita no estado do contribuinte.
	If aNFItem[nItem][IT_TS][TS_FRETAUT] == "3" .And. ( aNfCab[NF_TRANSUF] == aSX6[MV_ESTADO] .Or. aNfCab[NF_TRANSIN] == "3" .Or.(aNfCab[NF_TRANSIN] == "2" .And. aNfCab[NF_TRANSUF] <> aSX6[MV_ESTADO] ) )
		//Define BASE do TST - IT_BASETST
		If "BSE" $ cExecuta
			aNfItem[nItem][IT_BASETST]:= aNfItem[nItem][IT_AUTONOMO]
		EndIf
		//Define Aliquota do TST - IT_ALIQTST
		If "ALQ" $ cExecuta
			aNfItem[nItem][IT_ALIQTST]:= Val(Substr(aSX6[MV_ALIQFRE],AT(aNFCab[NF_UFDEST],aSX6[MV_ALIQFRE])+2,2))
		EndIf
		//Define VLR  do TST - IT_VALTST
		If "VLR" $ cExecuta
			aNfItem[nItem][IT_VALTST] := aNfItem[nItem][IT_BASETST]*aNfItem[nItem][IT_ALIQTST]/100
		EndIf
	Else
		aNfItem[nItem][IT_BASETST]:= 0
		aNfItem[nItem][IT_ALIQTST]:= 0
		aNfItem[nItem][IT_VALTST] := 0
	Endif
Else
	If (nPosTgFrtE := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_FRTEMB})) >0

		aNfItem[nItem][IT_BASETST]:= aNfItem[nItem][IT_TRIBGEN][nPosTgFrtE][TG_IT_BASE]
		aNfItem[nItem][IT_ALIQTST]:= aNfItem[nItem][IT_TRIBGEN][nPosTgFrtE][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_VALTST] := aNfItem[nItem][IT_TRIBGEN][nPosTgFrtE][TG_IT_VALOR]
	EndIf
EndIf

Return

/*/
PerRedST - Rafael Oliveira - 29/07/2012
// Carrega a reducao da base do ICMS ST
*/
Function PerRedST(aNfItem,nItem)
Local nReduzICMS := 0
Local nPosTgIcST := 0

If (nPosTgIcST:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ICMSST})) > 0
	If aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_LF][TG_LF_PERC_REDUCAO] > 0
		nReduzICMS:= 100-aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_LF][TG_LF_PERC_REDUCAO]
		aNfItem[nItem][IT_PREDST]:= nReduzICMS
	EndIf
Else
	// Carrega a reducao da base do ICMS
	If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,26] > 0
		nReduzICMS := aNfItem[nItem,IT_EXCECAO,26]
	Else
		nReduzICMS := aNFItem[nItem][IT_TS][TS_BSICMST]
	EndIf

	aNfItem[nItem,IT_PREDST] := nReduzICMS
EndIf

Return nReduzICMS

/*/{Protheus.doc} ICSTConvRf
(Função responsavel por converter alteração de referencia legado em referencia do configurador)

@author Renato Rezende
@since 18/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
ccampo -> Campo que esta sendo alterado	
nExecuta -> Referência que está sendo verificada
/*/
Function ICSTConvRf(aNfItem,nItem,ccampo, nExecuta)
Local cCampoConv 	:= ""
Local cCtrRefBas	:= ""
Local cCtrRefVal	:= ""
Local cCtrRefAlq	:= ""

If nExecuta == 1
	cCtrRefBas	:= "IT_BASESOL"
	cCtrRefVal	:= "IT_VALSOL"
	cCtrRefAlq	:= "IT_ALIQSOL"
ElseIf nExecuta == 2
	cCtrRefBas	:= "IT_BASETST"
	cCtrRefVal	:= "IT_VALTST"
	cCtrRefAlq	:= "IT_ALIQTST"
EndIf

IF cCampo $ cCtrRefVal
    cCampoConv := "TG_IT_VALOR"
Elseif cCampo $ cCtrRefBas
    cCampoConv := "TG_IT_BASE"
Elseif cCampo $ cCtrRefAlq
    cCampoConv := "TG_IT_ALIQUOTA"
Endif

Return cCampoConv

/*/{Protheus.doc} AtuLegIcST
(Função responsavel por preencher as referencia legado com os valores das referencia do configurador)

@author Renato Rezende
@since 18/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
/*/
Static Function AtuLegIcST(aNfItem,nItem)
Local nPosTgIcST:= 0

If (nPosTgIcST := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ICMSST})) >0  

	aNfItem[nItem][IT_VALSOL]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_VALOR]
	aNfItem[nItem][IT_BASESOL]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQSOL]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_ALIQUOTA]
	
	If aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_LF][TG_LF_PERC_REDUCAO] > 0
		aNfItem[nItem][IT_PREDST]:= 100-aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_LF][TG_LF_PERC_REDUCAO]
	EndIf
	aNfItem[nItem][IT_PAUTST]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_PAUTA]
	aNfItem[nItem][IT_MARGEM]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIcST][TG_IT_MVA]

	aNFItem[nItem][IT_TS][TS_LFICMST] := RetLFLeg(aNfItem,nItem,nPosTgIcST,TS_LFICMST)

EndIf

Return
