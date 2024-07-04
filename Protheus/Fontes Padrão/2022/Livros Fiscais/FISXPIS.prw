#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FisxPis
    (Componentização da função MaFisPIS - 
    Calculo do PIS - Apuracao)    
    
	@Author Renato Rezende
    @since 11/05/2020
    @version 12.1.27

    @Autor da função original 
    Alexandre Lemes # 28/09/2012

	@param:
	aNfCab      -> Array com dados do cabeçalho da nota
	aNFItem     -> Array com dados item da nota
	nItem       -> Item que esta sendo processado
	aPos        -> Array com dados de FieldPos de campos
	aInfNat	    -> Array com dados da natureza
	aPE		    -> Array com dados dos pontos de entrada
	aSX6	    -> Array com dados Parametros
	aDic	    -> Array com dados Aliasindic
	aFunc	    -> Array com dados Findfunction
/*/
Function FisxPis(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cTipo, cExecuta, lReproc, lAgregICM)
Local aExcecao	 := {}
Local aAreaSA1   := {}
Local aAreaSC6   := {}
Local aMaPISVeic := {}
Local aMaPISDif  := {}
Local cNatureza  := ""
Local nDescISS	 := 0
Local nVlUnitCig := 0
Local nFatRedPIS := 1
Local nAliqAgr	 := 0
Local nBasePIS   := 0
Local nBasePS2	 := 0
Local nBasePS3	 := 0
Local nPautaSB1  := aNfItem[nItem][IT_PRD][SB_VLR_PIS]
Local nRedBsPIS	 := aNfItem[nItem][IT_PRD][SB_REDPIS]
Local nAliqSB1   := aNfItem[nItem][IT_PRD][SB_PPIS]
Local nAliqBase  := IIf( !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNFItem[nItem,IT_EXCECAO,12] <> 0 , aNFItem[nItem,IT_EXCECAO,12] , IIf(Empty(nAliqSB1) , aSX6[MV_TXPIS] , nAliqSB1) )
Local nAliqPIS   := nAliqBase // Retencao
Local nAliqPS2   := nAliqBase // Apuracao
Local nAliqPS3   := nAliqBase // Substituicao Tributaria ST
Local lRecalPS2  := .T.
Local lAgreg     := .F.
Local lDc5602	 := .F.
Local lZFMAlqZ	 := .F.
Local lSegUndPau := aSX6[MV_PISCOFP] //utiliza ou nao segunda unidade quando for pauta
Local lPisMin	 := aNfItem[nItem][IT_TS][TS_PISMIN] == "1"
Local nVlOprPis	 := 0
Local nVlPautPis := 0
Local lValidArrd := .F.
Local nAxPautaB1 := 0
Local lTribPIS   := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_PIS)
Local lTribST  	 := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_PISST)
Local lTribRET   := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_PISRET)

Local aMaCalcPIS := IIf( aPE[PE_MACALCPIS] .and. !lTribRET .and. "PIS" $ cTipo , ExecBlock("MaCalcPIS", .F., .F., {nItem, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_TES], aNfCab[NF_CLIFOR], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], aNfCab[NF_OPERNF]}), Array(3))
Local aMaCPISAPU := IIf( aPE[PE_MACPISAPU] .And. !lTribPIS .and. "PS2" $ cTipo , ExecBlock("MaCPISAPU", .F., .F., {nItem, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_TES], aNfCab[NF_CLIFOR], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], aNfCab[NF_OPERNF]}), Array(3))

Local nBaseOri := aNfItem[nItem][IT_BASEPS2]
Local nAliqOri := aNfItem[nItem][IT_ALIQPS2]
Local nValOri  := aNfItem[nItem][IT_VALPS2]
Local nMajOri  := aNfItem[nItem][IT_VALPMAJ]
Local cFunName := AllTrim(FunName())

//Reducao de BASE PIS pesquisa pelo PRODUTO / TES ou EXCECAO
DEFAULT nRedBsPIS := 0
DEFAULT cExecuta  := "BSE|ALQ|VLR"
DEFAULT lReproc := .F.
DEFAULT lAgregICM := .T.

If aSX6[MV_PCFATPC] .And. aNfCab[NF_OPERNF] == "S" .And. !Empty(aNfCab[NF_CLIEFAT])
	aExcecao	:= aNFitem[nItem][IT_EXCECAO]
	aNFitem[nItem][IT_EXCECAO] := aNFitem[nItem][IT_EXCEFAT]
	cNatureza	:= aNfCab[NF_NATUREZA]
	aNfCab[NF_NATUREZA]	:= aNfCab[NF_NATUFAT]
EndIf

nRedBsPIS := IIf( aNFItem[nItem][IT_TS][TS_BASEPIS] > 0 , aNFItem[nItem][IT_TS][TS_BASEPIS] , nRedBsPIS )
nRedBsPIS := IIf( !Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,18] > 0 , aNfItem[nItem,IT_EXCECAO,18] , nRedBsPIS )

If nRedBsPIS <> 0
	nFatRedPIS	:= IIf( nRedBsPIS>0,1-nRedBsPIS/100,1)
EndIf

//PIS APURACAO - IT_BASEPS2 / IT_ALIQPS2 / IT_VALPS2
IF !lTribPIS // Se não possuir configurador calcula legado
	If "PS2" $ cTipo
		lDc5602:=.F.
		If aNfItem[nItem][IT_TABNTRE] == "4313" .AND. aNfCab[NF_OPERNF]=="S"
			lDc5602:=Decret5602((aNfItem[nItem][IT_VALMERC]/ aNfItem[nItem][IT_QUANT]),aNfItem[nItem][IT_POSIPI],aNfItem[nItem][IT_CODNTRE])
		EndIF
		aNfItem[nItem][IT_ALQPMAJ] := aNFItem[nItem][IT_TS][TS_ALQPMAJ] //Alimenta a referencia de aliquota majorada do PIS APURACAO
		aNfItem[nItem][IT_VALPMAJ] := 0 						// garante a limpeza da referencia caso o produto seja trocado na edicao da NF.
		//Devolucao de importacao, mantem os valores do PIS APURACAO do documento Original
		//If aNFCab[NF_TPCLIFOR]=="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)$"37"
		If ( aNFCab[NF_TIPONF] $"DB" .Or. aNFItem[nItem][IT_TS][TS_PODER3] == "D" ) .And. !Empty(aNFItem[nItem][IT_RECORI]) .And. aNFItem[nItem][IT_TS][TS_OPERGAR] <> '1'
			If aNFCab[NF_TIPONF] $ "DB"
				If aNFCab[NF_CLIFOR] == "C"
					SD2->(MsGoto(aNFItem[nItem][IT_RECORI]) )
					If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
						aNfItem[nItem][IT_ALIQPS2] := SD2->D2_ALQIMP6
						aNfItem[nItem][IT_BASEPS2] := SD2->D2_BASIMP6
						aNfItem[nItem][IT_VALPS2]  := SD2->D2_VALIMP6
						lRecalPS2 := .F.
					ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
						aNfItem[nItem][IT_ALIQPS2] := SD2->D2_ALQIMP6
						aNfItem[nItem][IT_BASEPS2] := (aNfItem[nItem][IT_QUANT] * SD2->D2_BASIMP6)/SD2->D2_QUANT
						aNfItem[nItem][IT_VALPS2]  := (aNfItem[nItem][IT_QUANT] * SD2->D2_VALIMP6)/SD2->D2_QUANT
						lRecalPS2 := .F.
					EndIf
				Else
					SD1->(MsGoto( aNFItem[nItem][IT_RECORI]) )
					If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
						aNfItem[nItem][IT_ALIQPS2] := SD1->D1_ALQIMP6
						aNfItem[nItem][IT_BASEPS2] := SD1->D1_BASIMP6
						aNfItem[nItem][IT_VALPS2]  := SD1->D1_VALIMP6
						If aNFItem[nItem][IT_TS][TS_ALQPMAJ] > 0
							aNfItem[nItem][IT_VALPMAJ] := aNfItem[nItem][IT_BASEPS2] * (aNFItem[nItem][IT_TS][TS_ALQPMAJ]/100)
						EndIf
						lRecalPS2 := .F.
					ElseIf aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
						aNfItem[nItem][IT_ALIQPS2] := SD1->D1_ALQIMP6
						aNfItem[nItem][IT_BASEPS2] := (aNfItem[nItem][IT_QUANT] * SD1->D1_BASIMP6)/SD1->D1_QUANT
						aNfItem[nItem][IT_VALPS2]  := (aNfItem[nItem][IT_QUANT] * SD1->D1_VALIMP6)/SD1->D1_QUANT
						lRecalPS2 := .F.
					EndIf
				EndIf
			Else
				If aNFCab[NF_CLIFOR] == "C"
					SD1->(MsGoto( aNFItem[nItem][IT_RECORI]) )
					If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
						aNfItem[nItem][IT_ALIQPS2] := SD1->D1_ALQIMP6
						aNfItem[nItem][IT_BASEPS2] := SD1->D1_BASIMP6
						aNfItem[nItem][IT_VALPS2]  := SD1->D1_VALIMP6
						lRecalPS2 := .F.
					EndIf
				Else
					SD2->(MsGoto(aNFItem[nItem][IT_RECORI]) )
					If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
						aNfItem[nItem][IT_ALIQPS2] := SD2->D2_ALQIMP6
						aNfItem[nItem][IT_BASEPS2] := SD2->D2_BASIMP6
						aNfItem[nItem][IT_VALPS2]  := SD2->D2_VALIMP6
						lRecalPS2 := .F.
					ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
						aNfItem[nItem][IT_ALIQPS2] := SD2->D2_ALQIMP6
						aNfItem[nItem][IT_BASEPS2] := (aNfItem[nItem][IT_QUANT] * SD2->D2_BASIMP6)/SD2->D2_QUANT
						aNfItem[nItem][IT_VALPS2]  := (aNfItem[nItem][IT_QUANT] * SD2->D2_VALIMP6)/SD2->D2_QUANT
						lRecalPS2 := .F.
					EndIf
				EndIf
			EndIf
		EndIf

		//PIS APURACAO - CALCULO
		If lRecalPS2

			lZFMAlqZ := aNFItem[nItem][IT_TS][TS_PISCOF]=="4" .And. aNFItem[nItem][IT_TS][TS_PISCRED]=="3" .And. ;
			aNfCab[NF_CLIFOR]=="C" .And. !aNfCab[NF_CALCSUF]$"IN " .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
			aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] .And. ( aNFItem[nItem][IT_TS][TS_PISCRED]$"134" ) .And. ;
			Empty(aNfItem[nItem][IT_ALIQPS2]) .And. ((aPE[PE_MACSTPICO] .And. !ExecBlock("MaCstPiCo",.F.,.F.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})[2]$"04#06#73") .Or. (!aPE[PE_MACSTPICO] .And. aNFItem[nItem][IT_TS][TS_CSTPIS] $"04#06#73")) .AND. !lDc5602

			If (aNFItem[nItem][IT_TS][TS_PISCOF]$"1|3" .And. !aNFItem[nItem][IT_TS][TS_PISCRED]$"3") .Or. lZFMAlqZ
				//Define a Aliquota do PIS APURACAO - IT_ALIQPS2
				If "ALQ" $ cExecuta
					If ( aNFItem[nItem][IT_TS][TS_PISCRED] == "3" .Or. Empty(aNFItem[nItem][IT_TS][TS_PISCRED]) ) .And. aNfItem[nItem][IT_PRD][SB_PIS] == "2"
						nAliqPS2 := 0
					Endif

					If ( aPE[PE_MACSTPICO] .And. ExecBlock("MaCstPiCo",.F.,.F.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})[2]$"04#06#73") .Or. (!aPE[PE_MACSTPICO] .And. (aNFItem[nItem][IT_TS][TS_CSTPIS] $"04#06#73" .Or. aNFItem[nItem][IT_TS][TS_PSCFST]== "3"))
						nAliqPS2:=0
					EndIF

					aNfItem[nItem][IT_ALIQPS2]	:= IIf( aSX6[MV_APURPIS] , aSX6[MV_TXPIS] , nAliqPS2 )// MV_APURPIS = .T. pegar aliquota do MV_TXPIS

					If aPE[PE_MAPISDIF] // //Ponto de Entrada para calculo de PIS Apuracao com Aliquota Diferenciada
						aMaPISDif := ExecBlock("MAPISDIF",.F.,.F.,{nItem,nAliqPS2})
						If aMaPISDif[1] == "S"
							aNfItem[nItem][IT_ALIQPS2] := aMaPISDif[2]
						EndIf
					EndIf				

					//Aliquota Majorada do PIS, Majora a Aliquota do PIS APURACAO qunado for Importacao. MaFisII
					If aNFItem[nItem][IT_TS][TS_ALQPMAJ] > 0 .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F" .And. ((aNFCab[NF_TPCLIFOR] =="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3") .Or. aNFItem[nItem][IT_TS][TS_IMPIND] == "1") .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123"
						aNfitem[nItem][IT_ALIQPS2] := aNFitem[nItem][IT_ALIQPS2] + aNFItem[nItem][IT_TS][TS_ALQPMAJ]
					EndIf

					IF lDc5602
						aNfitem[nItem][IT_ALIQPS2]:= 0
					EndIF

					//Ponto de Entrada - Atua, tanto na alíquota, quanto na base e valor do PIS Apuracao	
					If (aPE[PE_MACPISAPU] .And. aMaCPISAPU[1] == "S" .And. Len(aMaCPISAPU) > 1)
						aNfItem[nItem][IT_ALIQPS2] := aMaCPISAPU[2]					
					EndIf

				EndIf

				//PIS APURACAO - BASE - IT_BASEPS2
				If "BSE" $ cExecuta
					If !aNFItem[nItem][IT_TS][TS_PISCRED] $ "5" .AND. !aNfItem[nItem][IT_TIPONF]$"I|P"

						If ( nPautaSB1 == 0 .And. (Empty(aNFitem[nItem][IT_EXCECAO]) .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][10])))) .Or.;
							(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][10])) .Or.;
							aNfItem[nItem,IT_QUANT]==0 .Or. aSX6[MV_PISPAUT]

							If (( nPautaSB1 == 0 .And. (Empty(aNFitem[nItem][IT_EXCECAO]) .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][10])))) .Or.;
								(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][10]) .And. nPautaSB1 == 0) .Or.;
								(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][12])) .Or.;
								aNfItem[nItem,IT_QUANT]==0) .Or. (lPisMin)
								nBasePS2 := aNfItem[nItem][IT_VALMERC]-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_VALICM],0)

								//Tratamento do Agrega Valor - PIS / COF / ICMS
								nAliqAgr := 0

								If lAgregICM .And. aNFItem[nItem][IT_TS][TS_AGREG]=="I"
									If aNFItem[nItem][IT_TS][TS_ICM] == "N"
										nAliqAgr += aNfItem[nItem][IT_ALIQSOL]
										lAgreg	 := .T.
									Else
										If aNfCab[NF_PPDIFAL]
											nAliqAgr += aNfItem[nItem][IT_ALIQCMP]+aNfItem[nItem][IT_ALFCCMP]
										Else
											nAliqAgr += aNfItem[nItem][IT_ALIQICM]
										Endif
										lAgreg	 := .T.
									EndIf
								EndIf

								If aNFItem[nItem][IT_TS][TS_AGRPIS]=="P"
									nAliqAgr += aNfItem[nItem][IT_ALIQPS2]
									lAgreg	 := .T.
									If aNFItem[nItem][IT_TS][TS_AGRCOF]=="C"
										nAliqAgr += aNfItem[nItem][IT_ALIQCF2]
									Endif
								Endif

								If lAgreg

									If aSX6[MV_RNDICM]
										nBasePS2 := Round(nBasePS2 / ( 1 - (nAliqAgr/100)) , 2 )
									Else
										nBasePS2 := nBasePS2 / ( 1 - (nAliqAgr/100))
									EndIf

								Endif

								If aNFItem[nItem][IT_TS][TS_AGREG] == "I" .And. !lAgreg
									nBasePS2 += If(aNFitem[nItem][IT_TIPONF ]<>"I",aNfItem[nItem][IT_VALICM],0)
								EndIf

								If !(aNFItem[nItem][IT_TS][TS_AGREG]=="I" .AND. lAgreg .AND. aSX6[MV_DBSTPIS]$"1|6" .AND. IntTms()) //Tratamento para não duplicar o valor do icms na base de pis
									nBasePS2 := ( nBasePS2 - IIf( aNFItem[nItem][IT_TS][TS_PISBRUT] == "1" , 0 , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]+aNfItem[nItem][IT_DS43080]) ) + aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS] + IIf(aNfItem[nItem][IT_DESCZFPIS]<>0,0,IIF(aNFItem[nItem][IT_TS][TS_CRPRST]<>0 .And. IntTms(),aNfItem[nitem][IT_VLCSOL],aNfItem[nitem][IT_VALSOL])) )
								EndIf

								If ( !(aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_CALCSUF]$"SI" .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
									aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ) .And. aSX6[MV_FRTBASE] ) .Or. aSX6[MV_FRTBASE]
									nBasePS2 += IIf(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_DESPESA],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_SEGURO],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_FRETE],0)
								EndIf

								// Campo A2_DEDBSPC em branco ou "1": segue a regra antiga (Parametro MV_DEDBPIS)
								// Processa sempre legado quando Saídas diferente de Devolucao/Benef
								If aNFCab[NF_DEDBSPC] $ " 1" .Or. (aNfCab[NF_OPERNF] == "S" .And. !aNFitem[nItem][IT_TIPONF ] $ "BD" )

									If aNFItem[nItem][IT_TS][TS_CREDIPI] == "N" .AND. aNFItem[nItem][IT_TS][TS_IPI]<>"R";
										.AND. ( aSX6[MV_DEDBPIS]$"S,P" .AND. ( aNfItem[nItem][IT_EMISNFORI] >= aSX6[MV_ICMDSDT] .OR. Empty(aNfItem[nItem][IT_EMISNFORI]) ) )

										nBasePS2 += aNfItem[nItem][IT_VALIPI]
									EndIf
									If !(aNFItem[nItem][IT_TS][TS_AGREG]$"DR")
										If ( aSX6[MV_DEDBPIS]$"S,I" .AND. ( aNfItem[nItem][IT_EMISNFORI] >= aSX6[MV_ICMDSDT] .OR. Empty(aNfItem[nItem][IT_EMISNFORI]) ) )
											If !Substr(aNFItem[nItem][IT_CLASFIS], 2)$aSX6[MV_DICMISE]
												nBasePS2 -= aNfItem[nItem][IT_VALICM]
											EndIf
										EndIf
									EndIf
									// Caso seja comerciante atacadista, o valor do IPI deve ser retirado da base de calculo do PIS pois esta embutido no valor da mercadoria
									If aNFItem[nItem][IT_TS][TS_CREDIPI] == "S" .And. aNFItem[nItem][IT_TS][TS_IPI]$ "RS";
										.AND. ( aSX6[MV_DEDBPIS]$"S,P" .AND. ( aNfItem[nItem][IT_EMISNFORI] >= aSX6[MV_ICMDSDT] .OR. Empty(aNfItem[nItem][IT_EMISNFORI]) ) )
										
										nBasePS2 -= aNfItem[nItem][IT_VALIPI]
									EndIf
								Else
									// Opcoes do aNFCab[NF_DEDBSPC]:
									// 1 - Legado - Considera as regras dos parâmetros MV_DEDBPIS e MV_DEDBCOF.
									// 2 - Deduz ICMS e IPI.
									// 3 - Deduz Apenas ICMS.
									// 4 - Deduz Apenas IPI.
									// 5 - Não Deduz Nenhum.
									// 6 - Soma IPI
									Do Case
										Case aNFCab[NF_DEDBSPC] == "2"
											nBasePS2 -= aNfItem[nItem][IT_VALICM]
											nBasePS2 -= aNfItem[nItem][IT_VALIPI]
										Case aNFCab[NF_DEDBSPC] == "3" .And. !Substr(aNFItem[nItem][IT_CLASFIS], 2)$aSX6[MV_DICMISE]
											nBasePS2 -= aNfItem[nItem][IT_VALICM]
										Case aNFCab[NF_DEDBSPC] == "4"
											nBasePS2 -= aNfItem[nItem][IT_VALIPI]
										Case aNFCab[NF_DEDBSPC] == "6" .And. aNfItem[nItem][IT_TS][TS_LFIPI] <> "T" .AND. aNFItem[nItem][IT_TS][TS_IPI] <> "R"
											nBasePS2 += aNfItem[nItem][IT_VALIPI]
									EndCase

								EndIf

								//Exclui valor do Difal (EC/15) da base de cálculo de PIS
								IF aNfItem[nItem][IT_TS][TS_DIFALPC] == '1'
									nBasePS2 -= (aNfItem[nItem][IT_DIFAL]+aNfItem[nItem][IT_VALCMP]+aNfItem[nItem][IT_VFCPDIF])
								EndIF

								If aSX6[MV_CRDBPIS] $ "S" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3"
									nBasePS2 += aNfItem[nItem][IT_VALICM]
								EndIf

								If aNFItem[nItem][IT_TS][TS_PISDSZF] == "2"
									nBasePS2 += aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS])
								Endif

								// Tratamento para retirada do valor do ICMS solidario da base do PIS Apuracao
								If ((MaFisDbST("PS2",nItem) .Or. (aSX6[MV_RPCBIZF] .And. aNfCab[NF_SUFRAMA])) .And. aNfItem[nItem][IT_DESCZFPIS] == 0)
									nBasePS2 -= IIF(aNFItem[nItem][IT_TS][TS_CRPRST]<>0 .And. IntTms(),aNfItem[nItem][IT_VLCSOL],aNfItem[nItem][IT_VALSOL])
								Endif

							Else
								nBasePS2 := IIF(lSegUndPau,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT])
							EndIf

							nBasePS2 += aNfItem[nItem][IT_ACRESCI]

							nBasePS2 *= nFatRedPIS

							if aSX6[MV_DEISSBS] == .F. .And. aNfCab[NF_OPERNF]=="S"
								aNfItem[nItem][IT_BASEPS2] := nBasePS2 - aNfItem[nItem][IT_VALISS]
							else
								aNfItem[nItem][IT_BASEPS2] := nBasePS2
							endif

							If !aSX6[MV_RNDICM] .And. lAgreg
								MaItArred(nItem,{"IT_BASEPS2"})
							EndIf

							If aNFItem[nItem][IT_TS][TS_OPERSUC]=="1" .And. aNfCab[NF_SIMPSC]<>"1" .And. aNFCab[NF_SIMPNAC]<>"1" // Operacoes com Sucata
								nBasePS2 := (aNFitem[nItem][IT_VALICM] / ( (100-(aNFitem[nItem][IT_ALIQICM]+aNFitem[nItem][IT_ALIQPS2]+aNFitem[nItem][IT_ALIQCF2]))/100 ) )
								aNfItem[nItem][IT_BASEPS2] := nBasePS2
							Endif
						Else
							//Calculo da BASE PIS APURACAO pela PAUTA do SB1 ou EXCECAO
							If (Empty(aNFitem[nItem,IT_EXCECAO]) .Or. Empty(aNFItem[nItem,IT_EXCECAO,10]))
								nBasePS2 := IIF(lSegUndPau,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT]) * nPautaSB1
								aNfItem[nItem][IT_PAUTPIS]	:= nPautaSB1
							Else
								nBasePS2 := aNfItem[nItem,IT_QUANT] * aNFItem[nItem,IT_EXCECAO,10]
								aNfItem[nItem][IT_PAUTPIS]	:= aNFItem[nItem,IT_EXCECAO,10]
							EndIf

							aNfItem[nItem][IT_BASEPS2] := nBasePS2
						EndIf

						//Agregar o valor do pedagio na base do PIS/COFINS
						If	aNFItem[nItem][IT_TS][TS_AGRPEDG] $ "4|5" .And. aNfItem[nItem][IT_VALPEDG] > 0
							aNfItem[nItem][IT_BASEPS2] += aNfItem[nItem][IT_VALPEDG]
						EndIf
						
						//Zera a BASE do PIS APURACAO somente quando a aliquota for = 0 e o CSTPIS  NAO for = "04#06#73"
						If Empty( aNfItem[nItem][IT_ALIQPS2] ) .And. ((aPE[PE_MACSTPICO] .And. !ExecBlock("MaCstPiCo",.F.,.F.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})[2]$"04#06#73") .Or. (!aPE[PE_MACSTPICO] .And. !aNFItem[nItem][IT_TS][TS_CSTPIS] $"04#06#73")) .AND. !lDc5602 .And. !lZFMAlqZ
							aNfItem[nItem][IT_BASEPS2] := 0
						EndIf

					Else
						aNfItem[nItem][IT_BASEPS2] := 0
					EndIf

					//Especifico para VEICULOS
					If cPaisLoc == "BRA" .And. aSX6[MV_CALCVEI] .And. "PS2" $ cTipo .And. aNfCab[NF_OPERNF] == "S" .And. aPos[FP_B1_CHASSI] .And. !Empty( aNfItem[nItem][IT_PRD][SB_CHASSI] ) // Alteracao de base para veiculos usados
						If aNfItem[nItem][IT_BASVEIC] == 0
							aAreaSC6 := SC6->(GetArea())
							SC6->(dbSetOrder(1))
							If SC6->( MsSeek(xFilial("SC6")+aNfCab[NF_PEDIDO]+aNfItem[nItem][IT_ITEM]+aNfItem[nItem][IT_PRODUTO]) )
								aNfItem[nItem][IT_BASVEIC] := SC6->C6_BASVEIC
							EndIf
							RestArea(aAreaSC6)
						EndIf
						aNfItem[nItem][IT_BASEPS2] -= aNfItem[nItem][IT_BASVEIC]
						If aNfItem[nItem][IT_BASEPS2] < 0
							aNfItem[nItem][IT_BASEPS2] := 0
						EndIF
					EndIf

					//Ponto de Entrada - Atua, tanto na alíquota, quanto na base do PIS Apuracao
					If (aPE[PE_MACPISAPU] .And. aMaCPISAPU[1] == "S" .And. Len(aMaCPISAPU) > 2)
						aNfItem[nItem][IT_BASEPS2]:= aMaCPISAPU[3]
					EndIf

				EndIf

				//Define o Valor do PIS MAJORADO conforme aliquota informada na TES.
				If aNFItem[nItem][IT_TS][TS_ALQPMAJ] > 0
					aNfItem[nItem][IT_VALPMAJ] := aNfItem[nItem][IT_BASEPS2] * (aNFItem[nItem][IT_TS][TS_ALQPMAJ]/100)
				EndIf

				//PIS APURACAO - VALOR - IT_VALPS2
				If "VLR" $ cExecuta

					If ((nPautaSB1 == 0 .And. (Empty(aNFitem[nItem][IT_EXCECAO]) .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][10])))) .Or.;
						aNfItem[nItem,IT_QUANT]==0 .Or. !aSX6[MV_PISPAUT]) .Or. (aPE[PE_MACPISAPU] .And. aMaCPISAPU[1] == "S" .And. Len(aMaCPISAPU) > 2)

						aNfItem[nItem][IT_VALPS2] := aNfItem[nItem][IT_BASEPS2]*aNfItem[nItem][IT_ALIQPS2]/100

					Else
						//PIS APURACAO - Aplica PAUTA SB1 ou Excecao
						If aNfItem[nItem][IT_BASEPS2] <> 0
							If Empty(aNFitem[nItem,IT_EXCECAO]) .Or. (Empty(aNFItem[nItem,IT_EXCECAO,10]) .And. Empty(aNFItem[nItem,IT_EXCECAO,12]))
								nAxPautaB1 := nPautaSB1
							Else
								nAxPautaB1 := aNFItem[nItem,IT_EXCECAO,10]
							Endif
							
							IF lPisMin

								nVlOprPis	:= aNfItem[nItem][IT_BASEPS2]*aNfItem[nItem][IT_ALIQPS2]/100
								nVlPautPis	:= IIF(lSegUndPau .And. aNfItem[nItem][IT_PRD][SB_CONV] > 0,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT]) * nAxPautaB1

								IF  nVlOprPis <  nVlPautPis
									aNfItem[nItem][IT_BASEPS2] := IIF(lSegUndPau .And. aNfItem[nItem][IT_PRD][SB_CONV] > 0,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT])
									aNfitem[nItem][IT_ALIQPS2] := nAxPautaB1
									aNfItem[nItem][IT_VALPS2]  := aNfItem[nItem][IT_BASEPS2] * aNfitem[nItem][IT_ALIQPS2]
									aNfItem[nItem][IT_PAUTPIS] := nAxPautaB1

									/*Se efetuou o cálculo por pauta e o CST não for 03, forço o 03*/
									IF aNFItem[nItem][IT_TS][TS_CSTPIS] <> '03' .And. aNfCab[NF_OPERNF] == "S"
										aNFItem[nItem][IT_TS][TS_CSTPIS] := '03'
									ENDIF

									aNFItem[nItem][IT_PAUTAPS] := .T.
								ELSE
									aNfItem[nItem][IT_VALPS2]  := nVlOprPis
									aNfItem[nItem][IT_PAUTPIS] := 0
									aNFItem[nItem][IT_PAUTAPS] := .F.
									// Quando CST não mudar para 03 não ira gravar tabela da receita
									aNfItem[nItem][IT_TABNTRE] := ""
									aNfItem[nItem][IT_CODNTRE] := ""
									aNfItem[nItem][IT_GRPNTRE] := ""
									aNfItem[nItem][IT_DATNTRE] := cTod("//")
								ENDIF
							ElseIf !Empty(aNFitem[nItem,IT_EXCECAO]) .And. !Empty(aNFItem[nItem,IT_EXCECAO,12])
								aNfItem[nItem][IT_BASEPS2] := aNfItem[nItem][IT_VALMERC]-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_VALICM],0)
								aNfitem[nItem][IT_ALIQPS2] := aNFItem[nItem,IT_EXCECAO,12]
								aNfItem[nItem][IT_VALPS2]  := aNfItem[nItem][IT_BASEPS2] * aNfitem[nItem][IT_ALIQPS2] /100
								aNfItem[nItem][IT_PAUTPIS] := aNFItem[nItem,IT_EXCECAO,10]
								aNFItem[nItem][IT_PAUTAPS] := .F.
							ELSE
								aNfItem[nItem][IT_BASEPS2] := IIF(lSegUndPau,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT])
								aNfitem[nItem][IT_ALIQPS2] := nAxPautaB1
								aNfItem[nItem][IT_VALPS2]  := aNfItem[nItem][IT_BASEPS2] * aNfitem[nItem][IT_ALIQPS2]
								aNfItem[nItem][IT_PAUTPIS] := nAxPautaB1
								aNFItem[nItem][IT_PAUTAPS] := .T.
							ENDIF						
						EndIf
					EndIf

					If aNFItem[nItem][IT_TS][TS_AGRPIS]=="P"
						aNfItem[nItem][IT_VALPS2] := Round(aNfItem[nItem][IT_VALPS2],2)
					EndIf

					//DESCONTO SUFRAMA - PIS APURACAO
					If !lZFMAlqZ .And. aNfCab[NF_CLIFOR]=="C" .And. !aNfCab[NF_CALCSUF]$"IN " .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
						aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] .And. ( aNFItem[nItem][IT_TS][TS_PISCRED]$"134" )

						If ( aPE[PE_MACSTPICO] .And. ExecBlock("MaCstPiCo",.f.,.f.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})[2]$"04#06#73") .Or. ( !aPE[PE_MACSTPICO] .And. aNFItem[nItem][IT_TS][TS_CSTPIS] $"04#06#73")
							If aNfItem[nItem][IT_PAUTPIS] == 0
								aNfItem[nItem][IT_VALPS2]:= aNfItem[nItem][IT_BASEPS2] * nAliqBase / 100
							Else
								aNfItem[nItem][IT_VALPS2]:= aNfItem[nItem][IT_BASEPS2]
							Endif
						EndIf
						If aNfItem[nItem][IT_DESCZFPIS] > 0
							MaItArred(nItem,{"IT_DESCZFPIS"})					
							aNfItem[nItem][IT_DESCZF] -= aNfItem[nItem][IT_DESCZFPIS]
						EndIf
						MaItArred(nItem,{"IT_VALPS2"})

						If aNfCab[NF_ROTINA] $ "MATA461|FATA701" .Or. cFunName $ "MATA920|OFIXA018|OFIXA011|OFIXA100"
							MaItArred(nItem,{"IT_VALPS2"})
							aNfItem[nItem][IT_VALMERC]+= aNfItem[nItem][IT_DESCZFPIS]
							aNfItem[nItem][IT_VALMERC]-= aNfItem[nItem][IT_VALPS2]
							If cPaisLoc == "RUS"
								aNfItem[nItem][IT_VALMERC_C1]+= xMoeda(aNfItem[nItem][IT_DESCZFPIS],aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
								aNfItem[nItem][IT_VALMERC_C1]-= xMoeda(aNfItem[nItem][IT_VALPS2],aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
							EndIf
							If cFunName $ "MATA920"
								aNfItem[nItem][IT_PRCUNI] := aNfItem[nItem][IT_VALMERC]/aNfItem[nItem][IT_QUANT]
							Elseif cFunName $ "MATA461|MATA460A|FATA701|MATA460B|OFIXA018|OFIXA011|OFIXA100"
								aNfItem[nItem][IT_PRCUNI] := (aNfItem[nItem][IT_VALMERC]- (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) + aNfItem[nItem][IT_ACRESCI] )/aNfItem[nItem][IT_QUANT]
							EndIf
						EndIf
						aNfItem[nItem][IT_DESCZFPIS]:= aNfItem[nItem][IT_VALPS2]
						MaItArred(nItem,{"IT_DESCZFPIS"})
						aNfItem[nItem][IT_DESCZF]   += aNfItem[nItem][IT_DESCZFPIS]
						aNfItem[nItem][IT_VALPS2]   := 0
						If aNFItem[nItem][IT_TS][TS_PSCFST] == "1" .And. !aNFItem[nItem][IT_TS][TS_CSTPIS] $"04#06#73"
							aNfItem[nItem][IT_BASEPS2]  := 0
						EndIf
					EndIf
					//Se o valor do Pis Apuracao for Zero e houver sobra deverá entrar para arrendondar
					//Exemplo: PIS = 0,53 x 1,65% = 0,008745
					//Arrendondando seguindo os parametros padroes ficará PIS = 0,00
					//Deixando uma sobra de 0,008, a qual deverá arredondar para 0,01 o valor do PIS.
					lValidArrd:= Iif(aNfItem[nItem][IT_VALPS2] > 0 .And. aNfItem[nItem][IT_VALPS2] < 0.01, .T.,.F.)
					MaItArred(nItem,{"IT_VALPS2"},,lValidArrd)
				Endif
				If "PS2" $ cTipo
					If aPE[PE_MAPISVEIC] // ATENCAO!!! Ponto de entrada para uso exclusivo da TOTVS, nao sugerir o uso do mesmo a clientes - GDP FISCAL
						aMaPISVeic := ExecBlock("MaPISVeic",.F.,.F.,{nItem,aNfItem[nItem][IT_BASEPS2],aNfItem[nItem][IT_ALIQPS2],aNfItem[nItem][IT_VALPS2]})
						aNfItem[nItem][IT_BASEPS2] := aMaPISVeic[1]
						aNfItem[nItem][IT_ALIQPS2] := aMaPISVeic[2]
						aNfItem[nItem][IT_VALPS2]  := aMaPISVeic[3]
					EndIf
				Endif
			Else
				If "BSE" $ cExecuta
					aNfItem[nItem][IT_BASEPS2]:= 0
				EndIf
				If "VLR" $ cExecuta
					aNfItem[nItem][IT_VALPS2] := 0
				EndIf
				If "ALQ" $ cExecuta
					aNfItem[nItem][IT_ALIQPS2]:= 0
				EndIf
			EndIf
		EndIf

		// Se for reprocessamento restauro a base, aliquota e valor originais.
		If lReproc
			aNfItem[nItem][IT_BASEPS2] := nBaseOri
			aNfItem[nItem][IT_ALIQPS2] := nAliqOri
			aNfItem[nItem][IT_VALPS2]  := nValOri
			aNfItem[nItem][IT_VALPMAJ] := nMajOri
		EndIf
	EndIf
Else
	PISConf(aNFCab,aNfItem,nItem,"1")
Endif

//PIS RETENCAO - IT_BASEPIS / IT_ALIQPIS / IT_VALPIS
IF !lTribRET // Se não possuir configurador calcula legado
	If "PIS" $ cTipo
		//Define a Aliquota do PIS RETENCAO - IT_ALIQPIS
		If "ALQ" $ cExecuta
			If Empty(nAliqSB1) .Or. aSX6[MV_TPALPIS] == "1"
				If !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCPIS] == "S" .And. !Empty(aInfNat[NT_PERCPIS])

					nAliqPIS :=  aInfNat[NT_PERCPIS]

					If nModulo == 43 .And. SA1->A1_TPESSOA == "EP" // Para o Tipo de Cliente 'Empresa Publica',quando transporte for Internacional,nao gerar a retencao de PIS/COFINS -- BOPS 153148
						aAreaSA1 := SA1->(GetArea())
						SA1->(dbSetOrder(1))
						If SA1->(msSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)) .And. SA1->A1_EST == "EX"
							nAliqPIS := 0
						EndIf
						RestArea(aAreaSA1)
					EndIf

				EndIf

				If aPE[PE_MACALCPIS]
					If aMaCalcPIS[1] == "S" .And. !Empty(aMaCalcPIS[2])
						nAliqPIS := aMaCalcPIS[2]
					EndIf
				EndIf

			EndIf


			aNfItem[nItem][IT_ALIQPIS]	:= nAliqPIS
		Endif
		//Calculo de BASE e VALOR do PIS RETENCAO - IT_BASEPIS e IT_VALPIS

		If "BSE" $ cExecuta .Or. "VLR" $ cExecuta
			If ( aPE[PE_MACALCPIS] .And. aMaCalcPIS[1]=="S" ) .Or. ( !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCPIS]=="S" ;
				.And. aNfCab[NF_RECPIS] $ "S|P" .And. ( aNfItem[nItem][IT_PRD][SB_PIS] == "1" .Or. (aNfCab[NF_RECPIS] == "P" .And. !aSX6[MV_RETEMPU] ) ) )
				//MV_RETEMPU Define a forma de calculo de retenção para empresas publicas, caso esteja = .T. passará a validar informações dos campos de retenção do cadastro de produtos e não mais do cadastro de clientes. 
				// A base de calculo da retencao eh o valor da duplicata
				// porem de acordo com a Cons. Trib. Liz, o valor do ISS nao
				// devera ser deduzido da base do PIS/COF/CSL retencao. Para
				// isso foi criado o parametro MV_DEISSBS que se estiver como
				// .T. nao sera descontado e se estiver como .F. - default sera
				nDescISS := Iif( aSX6[MV_DEISSBS] .And. aNfCab[NF_RECISS]=="1" .And. aSX6[MV_DESCISS] .And. aNfCab[NF_OPERNF]=="S" .And. aSX6[MV_TPABISS]=="1",aNfItem[nItem][IT_VALISS],0)
				nBasePIS := aNfItem[nItem,IT_BASEDUP] + IIf( aSX6[MV_PISBRU] == "1" , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) , 0 ) + nDescISS

				// Retirado:
				// 		Inciso II, paragrafo 2º, artigo 1º da Lei 10845/02
				//		Issue - DSERFIS2-386
				If aNfItem[nItem][IT_TS][TS_APLREPC]$"13"
					nBasePIS *= nFatRedPIS
				EndIf

				//Tratamento extraido da funcao MaFisVTot para saber se foi contemplado o VALOR DE IPI na base da duplicata para que eu possa subtrair
				If (aNFItem[nItem][IT_TS][TS_IPIPC]=="2") .And. (aNFitem[nItem][IT_TIPONF]=="P" .Or. aNFItem[nItem][IT_TS][TS_IPI]<>'R')
					nBasePIS -= aNfItem[nItem][IT_VALIPI]
				EndIf
				If aSX6[MV_CRDBPIS] $ "S" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3"
					nBasePIS += aNfItem[nItem][IT_VALICM]
				EndIf

				// Tratamento para retirada do valor do ICMS solidario da base do PIS Retencao
				If MaFisDbST("PIS",nItem) .And. aNfItem[nItem][IT_DESCZFPIS] == 0
					nBasePIS -= aNfItem[nitem][IT_VALSOL]
				Endif

				//Quando operação com diferimento para orgão Publico, base de retenção deve ser sobre total da nota.
				If aNFItem[nItem][IT_TS][TS_PICMDIF]<>0 .And. aNFItem[nItem][IT_TS][TS_ICMSDIF]$" ,1,2" .And. aNFItem[nItem][IT_TS][TS_ICM] == "S"
					nBasePIS += aNfItem[nItem][IT_ICMSDIF]
				EndIf

				If "BSE" $ cExecuta
					If aPE[PE_MACALCPIS] .And. aMaCalcPIS[1]=="S" .And. Len(aMaCalcPIS) > 2 .And. !Empty(aMaCalcPIS[3])
						aNfItem[nItem][IT_BASEPIS]:= aMaCalcPIS[3]
					Elseif aSX6[MV_DEISSBS] == .F. .and. aSX6[MV_TPABISS]=="2" .And. aNfCab[NF_OPERNF]=="S"
						aNfItem[nItem][IT_BASEPIS]:= nBasePIS - aNfItem[nItem][IT_VALISS]
					else
						aNfItem[nItem][IT_BASEPIS]:= nBasePIS
					endif
				Endif

				If "VLR" $ cExecuta
					aNfItem[nItem][IT_VALPIS] := aNfItem[nItem][IT_BASEPIS] * aNfItem[nItem][IT_ALIQPIS] / 100
				Endif

				If aNfItem[nItem][IT_PRD][SB_RETOPER] == "1" .And. !aNfCab[NF_RECPIS] == "N" //Item classificado na Medida Provisoria 252 Junho/2005 e nao aguardar o limite imposto pela Lei 10.925 (R$ 5.000,00) autopecas
					aNfItem[nItem][IT_PIS252] := aNfItem[nItem][IT_VALPIS]
				Endif
			Else
				If "BSE" $ cExecuta
					aNfItem[nItem][IT_BASEPIS]:= 0
				EndIf
				If "VLR" $ cExecuta
					aNfItem[nItem][IT_VALPIS] := 0
				EndIf
			EndIf
		EndIf

		MaItArred(nItem,{"IT_VALPIS"})
	EndIf
Else
	PISConf(aNFCab,aNfItem,nItem,"2")
Endif

//Calcula PIS-ST   Base  Aliquota e Valor - IT_BASEPS3 - IT_ALIQPS3 - IT_VALPS3
IF !lTribST // Se não possuir configurador calcula legado
	If "PS3" $ cTipo
		If aNFItem[nItem][IT_TS][TS_PSCFST] $ "1|3|4"
			//Conforme IN SRF 594 de 2005, nao devem integrar a base de calculo do PIS/COFINS ST:
			//- Receitas isentas e as decorrentes de vendas a aliquota 0
			//- Vendas canceladas
			//- Descontos incondicionais
			//- IPI
			//- ICMS ST
			If aNFItem[nItem][IT_TS][TS_PSCFST] != "4"

				If aNFItem[nItem][IT_TS][TS_IPIPC] == "2"//Somente retiro aqui o valor do PS3 e CF3 caso o campo IPIPC estiver como 2, pois se estiver como 1 já estou retirando os valores no momento de compor o IT_TOTAL
					
				nBasePS3 := aNfItem[nItem][IT_TOTAL] //- ((aNfItem[nItem][IT_VALPS3]) + aNfItem[nItem][IT_VALCF3])
				
				If aNFItem[nItem][IT_TS][TS_APSCFST] == "1" // Caso os valores de PIS-ST e Cofins-ST estejam agregados no total da nota, eles deverão ser descontados pois já fazem parte da somatória.
					nBasePS3 -= (aNfItem[nItem][IT_VALPS3] + aNfItem[nItem][IT_VALCF3])
				EndIf
				
				nBasePS3 -= aNfItem[nItem][IT_VALIPI] //Conforme IN SRF546/2005 o valor do IPI deve integrar a base calculo PIS/COFINS ST-Zona Franca de Manaus
				
					If !(aNFItem[nItem][IT_TS][TS_INCSOL]$"A,N,D") // Verifica se o valor do ICMS Solidario esta agregado ao valor total
						nBasePS3 -= aNfItem[nItem][IT_VALSOL]
					Endif

				Else
					nBasePS3 := aNfItem[nItem][IT_VALMERC] + aNfItem[nItem][IT_VALIPI]
				Endif

				If ( !(aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_CALCSUF]$"SI" .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
						aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ) .And. aSX6[MV_FRTBASE] ) .Or. aSX6[MV_FRTBASE]
						nBasePS3 += IIf(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_DESPESA],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_SEGURO],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_FRETE],0)
				EndIf

				If aNFCab[NF_CLIFOR] == "C" .And. aNFCab[NF_TIPONF] $ "DB" .And. !aNfItem[nItem][IT_TIPONF]$"I|P" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC]
					If aNFItem[nItem][IT_TS][TS_PISCRED] <> "3" .And. aNFItem[nItem][IT_TS][TS_PISCOF]$"13" .And. !aNfCab[NF_CALCSUF]$"IN "
						nBasePS3 -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
					ElseIf aNFItem[nItem][IT_TS][TS_PISCRED] == "3" .And. aNFItem[nItem][IT_TS][TS_PISCOF]$"4" .And. aNfCab[NF_CALCSUF]$"I"
						nBasePS3 -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
					EndIf
				Else
					If aNFItem[nItem][IT_TS][TS_PISCRED] <> "3" .And. aNFItem[nItem][IT_TS][TS_PISCOF]$"13" .And. aNFItem[nItem][IT_TS][TS_PISBRUT] == '2' .And. aNFItem[nItem][IT_TS][TS_IPIPC] <> '2'
						nBasePS3 -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]+aNfItem[nItem][IT_DS43080])
					EndIf
				EndIf

				If aNFItem[nItem][IT_TS][TS_PISDSZF] == "2"
					nBasePS3 += aNfItem[nItem][IT_DESCZF]
				EndIf

				nBasePS3 *= nFatRedPIS
				//Se usuario informou percentual de Substituicao Tributaria de cigarro, ira multiplicar a base de calculo pelo percentual
				If Len(Alltrim(aSX6[MV_PUPCCST])) > 0 .And. aPos[FP_B1_PUPCCST]
					nVlUnitCig := aNfItem[nItem][IT_PRD][SB_PUPCCST] // Campo onde e informado o valor unitario para calcular valor de PIS ST.
				EndIF

				If !Empty(aNFitem[nItem][IT_EXCECAO])
					If aNfItem[nItem,IT_EXCECAO,25] > 0
						nVlUnitCig	:= aNfItem[nItem,IT_EXCECAO,25]
						aNfItem[nItem][IT_PRCUNIC] := nVlUnitCig
					Endif
				Endif

				If Len(AllTrim(aSX6[MV_B1CPSST])) > 0 .And. aPos[FP_B1_B1CPSST]
					aNfItem[nItem][IT_COEPSST] := aNfItem[nItem][IT_PRD][SB_B1CPSST] // Campo onde e informado o % de Substituição tributaria do PIS para fabrincante de cigarros.
				EndIf

				If nVlUnitCig > 0
					If aNfItem[nItem][IT_COEPSST] > 0
						nBasePS3 := ( aNfItem[nItem][IT_QUANT] * nVlUnitCig ) * aNfItem[nItem][IT_COEPSST]
					Else
						nBasePS3 := aNfItem[nItem][IT_QUANT] * nVlUnitCig
					EndIf
				EndIF

				If aNFCab[NF_TIPONF]$"D" .And. !Empty(aNFItem[nItem][IT_RECORI]) .And. aNFCab[NF_CLIFOR] == "C" .And. cPaisLoc == "BRA"
					SD2->( MsGoto( aNFItem[nItem][IT_RECORI] ) )
					nBasePS3 := aNfItem[nItem][IT_QUANT] * SD2->D2_BASEPS3 / SD2->D2_QUANT
				EndIF

				If "BSE" $ cExecuta
					aNfItem[nItem][IT_BASEPS3] := nBasePS3
				Endif
			EndIf
				
			If "ALQ" $ cExecuta
				IF aNFItem[nItem][IT_TS][TS_PSCFST] == "3" // 3= Aliq. Zero
					nAliqPS3 := 0
				Elseif Len(Alltrim(aSX6[MV_B1PISST])) > 0 .And. aNfItem[nItem][IT_PRD][SB_B1PISST] > 0 	//Verifica Campo criado na SB1
					nAliqPS3 := aNfItem[nItem][IT_PRD][SB_B1PISST]
				ElseIF aSX6[MV_TXPISST] > 0
					nAliqPS3 := aSX6[MV_TXPISST] // Verifica aliquota parametro
				Endif
				aNfItem[nItem][IT_ALIQPS3] := nAliqPS3
			Endif
			If "VLR" $ cExecuta
				aNfItem[nItem][IT_VALPS3]  := aNfItem[nItem][IT_BASEPS3]*aNfItem[nItem][IT_ALIQPS3]/100
			Endif
		Else
			If "BSE" $ cExecuta
				aNfItem[nItem][IT_BASEPS3] := 0
			EndIf
			If "ALQ" $ cExecuta
				aNfItem[nItem][IT_ALIQPS3] := 0
			EndIf
			If "VLR" $ cExecuta
				aNfItem[nItem][IT_VALPS3]  := 0
			EndIf
		EndIf
		MaItArred(nItem,{"IT_VALPS3"})
	EndIf
Else 
	PISConf(aNFCab,aNfItem,nItem,"3")
Endif

If aSX6[MV_PCFATPC] .And. aNfCab[NF_OPERNF] == "S" .And. !Empty(aNfCab[NF_CLIEFAT])
	aNFitem[nItem][IT_EXCECAO] 	:= aExcecao
	aNfCab[NF_NATUREZA] 		:= cNatureza
EndIf

Return

/*
±±³Funcao    xFisDc5602 ³ Autor ³Erick G. Dias          ³ Data ³20/08/2013³±±
±±³Descri‡…o ³Função que irá verificar se o item terá ou não a isenção    ³±±
±±³          ³de PIS e COFINS conforme o decreto 5602,ou não a isenção    ³±±
±±³Descri‡…o ³Função que irá verificar se o item terá ou não a isenção    ³±±
*/

Function FISXDC5602(nVlItem,cNCM,cCodNat,aSX6)

Local lRet			:= .F.
Local clMVDRE5602	:= aSX6[MV_DC5602]
Local cConteud		:= ""
Local cCod			:= ""
Local nPosNCM		:= 0
Local nPosCod		:= 0
Local nVal			:= 0

clMVDRE5602 := LeParSeq("MV_DC5602")
nPosNCM	:= At(alltrim(cNCM),clMVDRE5602)

IF nPosNCM > 0
	//Procura o código desta NCM
	cConteud := substr(clMVDRE5602,nPosNCM,at("/",substr(clMVDRE5602,nPosNCM)))
	nPosCod  := at(cCodNat,cConteud)
	If nPosCod > 1
		//Buscar o valor máximo para este código
		cCod := substr(cConteud,nPosCod,at(",",substr(cConteud,nPosCod))-1)
		nVal := val(SubStr(cCod,5))
		//Se o valor do item da nota fiscal for menor que o valor máximo para esta NCM e este código, então a alíquota será reduzida.
		IF nVlItem <= nVal
			lRet:=.T.
		EndIF
	EndIF
EndIF

Return lRet



/*/{Protheus.doc} PISConvRf 
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Rafael Oliveira
    @since 03/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function PISConvRf(aNfItem, nItem, ccampo, nExecuta,aNfCab)
 Local cCampoConv 	 := ""
 Local cCmpBasRef    := ""
 Local cCmpAlqRef    := ""
 Local cCmpVlrRef    := ""
 Local cCmpAuxRef    := ""

If nExecuta == 1 // PIS
	cCmpBasRef    := "IT_BASEPS2"
	cCmpAlqRef    := "IT_ALIQPS2"
	cCmpVlrRef    := "IT_VALPS2|IT_PAUTPIS"		
Elseif nExecuta == 2 //PIS ST
    cCmpBasRef    := "IT_BASEPS3"
	cCmpAlqRef    := "IT_ALIQPS3"
	cCmpVlrRef    := "IT_VALPS3"
ElseIF nExecuta == 3 // PIS Retenção
    cCmpBasRef    := "IT_BASEPIS"
	cCmpAlqRef    := "IT_ALIQPIS"
	cCmpVlrRef    := "IT_VALPIS"
ElseIF nExecuta == 4 // PIS Majoração 
	cCmpAlqRef    := "IT_ALQPMAJ"
	cCmpVlrRef    := "IT_VALPMAJ"		
Endif

IF cCampo $ cCmpBasRef
    cCampoConv := "TG_IT_BASE"
Elseif cCampo $ cCmpAlqRef
    cCampoConv := "TG_IT_ALIQUOTA"
Elseif cCampo $ cCmpVlrRef
	cCampoConv := "TG_IT_VALOR"
Elseif cCampo $ cCmpAuxRef
	cCampoConv := "TG_IT_AUX_MAJ"
Endif	

Return cCampoConv


/*/{Protheus.doc} PISConf
 Função responsavel por gravar referencias com base no configurador

 	@author Rafael Oliveira
    @since 03/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	cMvEstado -> Estado
    cExecuta    -> Identifica calculo
    /*/
Static Function PISConf(aNFCab, aNfItem, nItem, cExecuta)
Local nPosTrG := 0

IF cExecuta == "1"
	//PIS Apuração
	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PIS})) > 0 
		
		aNfItem[nItem][IT_BASEPS2]  	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]
		aNfItem[nItem][IT_ALIQPS2]  	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_VALPS2]   	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]		
		aNfItem[nItem][IT_PAUTPIS]		 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_PAUTA]
		aNFItem[nItem][IT_TS][TS_CSTPIS] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_REGRA_ESCR][RE_CST]
		
		IF aNfItem[nItem][IT_PAUTPIS] > 0
			aNFItem[nItem][IT_PAUTAPS] := .T.
			aNfItem[nItem][IT_PRD][SB_VLR_PIS] := IT_PAUTPIS		
		Endif
	EndIf  

	//PIS Majoracão
	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PISMAJ})) > 0 	
		
		aNfItem[nItem][IT_ALQPMAJ]    		:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_VALPMAJ]    		:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
		aNFItem[nItem][IT_TS][TS_ALQPMAJ]	:= aNfItem[nItem][IT_ALQPMAJ]
	EndIf 
	
	//Zona Franca
	ZFTribLeg(aNFItem, nItem)

Elseif cExecuta == "2"
	//PIS Retenção
	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PISRET})) > 0 	
		
		aNfItem[nItem][IT_BASEPIS]		 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]
		aNfItem[nItem][IT_ALIQPIS]		 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_VALPIS] 		 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]	
		aNFItem[nItem][IT_TS][TS_CSTPIS] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_REGRA_ESCR][RE_CST]
	EndIf	 
Elseif cExecuta == "3"
	//PIS ST
	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PISST})) > 0 
		
		aNfItem[nItem][IT_BASEPS3]			:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]
		aNfItem[nItem][IT_ALIQPS3]			:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]		
		aNfItem[nItem][IT_VALPS3] 			:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]	
		aNFItem[nItem][IT_TS][TS_CSTPIS]	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_REGRA_ESCR][RE_CST]
	EndIf 
	
Endif

Return 
