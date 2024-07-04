#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXCOFINS
    (Componentização da função MaFisCOFINS - 
    Calculo do COFINS - Apuracao / Retencao e ST) 

    MaFisCOFINS -Alexandre Lemes -28/09/2012
    Calculo do COFINS - Apuracao / Retencao e ST   
    
	@author Rafael Oliveira
    @since 11/05/2020
    @version 12.1.27
    
	@param:
	aNfCab      -> Array com dados do cabeçalho da nota
	aNFItem     -> Array com dados item da nota
	nItem       -> Item que esta sendo processado
	aPos        -> Array com dados de FieldPos de campos
	aInfNat	    -> Array com dados da narutureza
	aPE		    -> Array com dados dos pontos de entrada
	aSX6	    -> Array com dados Parametros
	aDic	    -> Array com dados Aliasindic
	aFunc	    -> Array com dados Findfunction    
    cTipo       -> String com tributo a ser calculadao: Apuracao / Retencao e ST
    cExecuta    -> String vinda da pilha do MATXFIS
    lReproc     -> Indica pilha de reprocessamento
    lAgregICM   -> Indica se Agrega ICMS
/*/
Function FISXCOFINS(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cTipo, cExecuta, lReproc, lAgregICM)

Local aExcecao	 := {}
Local aAreaSA1   := {}
Local aAreaSC6   := {}
Local aMaCOFVeic := {}
Local aMaCOFDif  := {}
Local cNatureza	 := ""

Local nDescISS	  := 0
Local nVlUnitCig  := 0
Local nFatRedCOF  := 1
Local nAliqAgr	  := 0
Local nBaseCOF    := 0
Local nBaseCF2	  := 0
Local nBaseCF3	  := 0
Local nPautaSB1   := aNfItem[nItem][IT_PRD][SB_VLR_COF]
Local nRedBsCOF	  := aNfItem[nItem][IT_PRD][SB_REDCOF]
Local nAliqSB1    := aNfItem[nItem][IT_PRD][SB_PCOFINS]
Local nAliqBase   := IIf( !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNFItem[nItem,IT_EXCECAO,13] <> 0 , aNFItem[nItem,IT_EXCECAO,13] , IIf(Empty(nAliqSB1) , aSX6[MV_TXCOFIN] , nAliqSB1) )
Local nAliqCOF    := nAliqBase // Retencao
Local nAliqCF2    := nAliqBase // Apuracao
Local nAliqCF3    := nAliqBase // Substituicao Tributaria ST
Local lRecalCF2   := .T.
Local lAgreg      := .F.
Local lDc5602	  := .F.
Local lZFMAlqZ	  := .F.
Local lSegUndPau  := aSX6[MV_PISCOFP] //utiliza ou nao segunda unidade quando for pauta
Local lCofMin	  := aNfItem[nItem][IT_TS][TS_COFMIN] == "1"
Local nVlOprCof	  := 0
Local nVlPautCof  := 0
Local nAxPautaB1  := 0

Local nBaseOri    := aNfItem[nItem][IT_BASECF2]
Local nAliqOri    := aNfItem[nItem][IT_ALIQCF2]
Local nValOri     := aNfItem[nItem][IT_VALCF2]
Local nMajOri     := aNfItem[nItem][IT_VALCMAJ]
Local lIntTms     := IntTms()
Local cFunName    := AllTrim(FunName())
Local lTribCOF	  := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_COF)
Local lTribCOFRet := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_COFRET)
Local lTribCOFST  := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_COFST)

Local aMaCalcCOF := IIf( aPE[PE_MACALCCOF] .And. !lTribCOFRet .and. "COF" $ cTipo, ExecBlock("MaCalcCOF", .F., .F., {nItem, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_TES], aNfCab[NF_CLIFOR], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], aNfCab[NF_OPERNF]}), Array(3))
Local aMaCCOFAPU := IIf( aPE[PE_MACCOFAPU] .And. !lTribCOF	  .and. "CF2" $ cTipo, ExecBlock("MaCCOFAPU", .F., .F., {nItem, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_TES], aNfCab[NF_CLIFOR], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], aNfCab[NF_OPERNF]}), Array(3))
 

//Reducao de BASE COFINS pesquisa pelo PRODUTO / TES ou EXCECAO
DEFAULT nRedBsCOF := 0
DEFAULT cExecuta  := "BSE|ALQ|VLR"
DEFAULT lReproc   := .F.
DEFAULT lAgregICM := .T.

If aSX6[MV_PCFATPC] .And. aNfCab[NF_OPERNF] == "S" .And. !Empty(aNfCab[NF_CLIEFAT])
	aExcecao	:= aNFitem[nItem][IT_EXCECAO]
	aNFitem[nItem][IT_EXCECAO] := aNFitem[nItem][IT_EXCEFAT]
	cNatureza	:= aNfCab[NF_NATUREZA]
	aNfCab[NF_NATUREZA]	:= aNfCab[NF_NATUFAT]
EndIf

nRedBsCOF := IIf( aNFItem[nItem][IT_TS][TS_BASECOF] > 0 , aNFItem[nItem][IT_TS][TS_BASECOF] , nRedBsCOF )
nRedBsCOF := IIf( !Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,19] > 0 , aNfItem[nItem,IT_EXCECAO,19] , nRedBsCOF )
If nRedBsCOF <> 0
	nFatRedCOF	:= IIf( nRedBsCOF>0,1-nRedBsCOF/100,1)
EndIf

//COFINS APURACAO - IT_BASECF2 / IT_ALIQCF2 / IT_VALCF2
If !lTribCOF

	If "CF2" $ cTipo

		lDc5602:=.F.
		If aNfItem[nItem][IT_TABNTRE] == "4313" .AND. aNfCab[NF_OPERNF]=="S"
			lDc5602:=Decret5602((aNfItem[nItem][IT_VALMERC]/ aNfItem[nItem][IT_QUANT]),aNfItem[nItem][IT_POSIPI],aNfItem[nItem][IT_CODNTRE])
		EndIF

		aNfItem[nItem][IT_ALQCMAJ] := aNFItem[nItem][IT_TS][TS_ALQCMAJ] //Alimenta a referencia de aliquota majorada do COFINS APURACAO
		aNfItem[nItem][IT_VALCMAJ] := 0 // garante a limpeza da referencia caso o produto seja trocado na edicao da NF.

		//Devolucao de importacao, mantem os valores do COFINS APURACAO do documento Original
		//If aNFCab[NF_TPCLIFOR]=="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)$"37"
		If ( aNFCab[NF_TIPONF] $"DB" .Or. aNFItem[nItem][IT_TS][TS_PODER3] == "D" ) .And. !Empty(aNFItem[nItem][IT_RECORI]) .And. aNFItem[nItem][IT_TS][TS_OPERGAR] <> '1'
			If aNFCab[NF_TIPONF] $ "DB"
				If aNFCab[NF_CLIFOR] == "C"
					SD2->(MsGoto(aNFItem[nItem][IT_RECORI]) )
					If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
						aNfItem[nItem][IT_ALIQCF2] := SD2->D2_ALQIMP5
						aNfItem[nItem][IT_BASECF2] := SD2->D2_BASIMP5
						aNfItem[nItem][IT_VALCF2]  := SD2->D2_VALIMP5
						lRecalCF2 := .F.
					ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
						aNfItem[nItem][IT_ALIQCF2] := SD2->D2_ALQIMP5
						aNfItem[nItem][IT_BASECF2] := (aNfItem[nItem][IT_QUANT] * SD2->D2_BASIMP5)/SD2->D2_QUANT
						aNfItem[nItem][IT_VALCF2]  := (aNfItem[nItem][IT_QUANT] * SD2->D2_VALIMP5)/SD2->D2_QUANT
						lRecalCF2 := .F.
					EndIf
				Else
					SD1->(MsGoto( aNFItem[nItem][IT_RECORI]) )
					If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
						aNfItem[nItem][IT_ALIQCF2] := SD1->D1_ALQIMP5
						aNfItem[nItem][IT_BASECF2] := SD1->D1_BASIMP5
						aNfItem[nItem][IT_VALCF2]  := SD1->D1_VALIMP5
						If aNFItem[nItem][IT_TS][TS_ALQCMAJ] > 0
							aNfItem[nItem][IT_VALCMAJ] := aNfItem[nItem][IT_BASECF2] * (aNFItem[nItem][IT_TS][TS_ALQCMAJ]/100)
						EndIf
						lRecalCF2 := .F.
					ElseIf aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
						aNfItem[nItem][IT_ALIQCF2] := SD1->D1_ALQIMP5
						aNfItem[nItem][IT_BASECF2] := (aNfItem[nItem][IT_QUANT] * SD1->D1_BASIMP5)/SD1->D1_QUANT
						aNfItem[nItem][IT_VALCF2]  := (aNfItem[nItem][IT_QUANT] * SD1->D1_VALIMP5)/SD1->D1_QUANT
						lRecalCF2 := .F.
					EndIf
				EndIf
			Else
				If aNFCab[NF_CLIFOR] == "C"
					SD1->(MsGoto( aNFItem[nItem][IT_RECORI]) )
					If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
						aNfItem[nItem][IT_ALIQCF2] := SD1->D1_ALQIMP5
						aNfItem[nItem][IT_BASECF2] := SD1->D1_BASIMP5
						aNfItem[nItem][IT_VALCF2]  := SD1->D1_VALIMP5
						lRecalCF2 := .F.
					EndIf
				Else
					SD2->(MsGoto(aNFItem[nItem][IT_RECORI]) )
					If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
						aNfItem[nItem][IT_ALIQCF2] := SD2->D2_ALQIMP5
						aNfItem[nItem][IT_BASECF2] := SD2->D2_BASIMP5
						aNfItem[nItem][IT_VALCF2]  := SD2->D2_VALIMP5
						lRecalCF2 := .F.
					ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
						aNfItem[nItem][IT_ALIQCF2] := SD2->D2_ALQIMP5
						aNfItem[nItem][IT_BASECF2] := (aNfItem[nItem][IT_QUANT] * SD2->D2_BASIMP5)/SD2->D2_QUANT
						aNfItem[nItem][IT_VALCF2]  := (aNfItem[nItem][IT_QUANT] * SD2->D2_VALIMP5)/SD2->D2_QUANT
						lRecalCF2 := .F.
					EndIf
				EndIf
			EndIf
		EndIf

		//COFINS APURACAO - CALCULO
		If lRecalCF2

			lZFMAlqZ := aNFItem[nItem][IT_TS][TS_PISCOF]=="4" .And. aNFItem[nItem][IT_TS][TS_PISCRED]=="3" .And. ;
			aNfCab[NF_CLIFOR]=="C" .And. !aNfCab[NF_CALCSUF]$"IN " .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
			aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] .And. ( aNFItem[nItem][IT_TS][TS_PISCRED]$"134" ) .And. ;
			Empty(aNfItem[nItem][IT_ALIQCF2]) .And. ((aPE[PE_MACSTPICO] .And. !ExecBlock("MaCstPiCo",.F.,.F.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})[2]$"04#06#73") .Or. (!aPE[PE_MACSTPICO] .And. aNFItem[nItem][IT_TS][TS_CSTCOF] $"04#06#73")) .AND. !lDc5602

			If (aNFItem[nItem][IT_TS][TS_PISCOF]$"2|3" .And. !aNFItem[nItem][IT_TS][TS_PISCRED]$"3") .Or. lZFMAlqZ

				//Define a Aliquota do COFINS APURACAO - IT_ALIQCF2
				If "ALQ" $ cExecuta
					If ( aNFItem[nItem][IT_TS][TS_PISCRED] == "3" .Or. Empty(aNFItem[nItem][IT_TS][TS_PISCRED]) ) .And. aNfItem[nItem][IT_PRD][SB_COFINS] == "2"
						nAliqCF2 := 0
					Endif

					If ( aPE[PE_MACSTPICO] .And. ExecBlock("MaCstPiCo",.F.,.F.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})[2]$"04#06#73") .Or. (!aPE[PE_MACSTPICO] .And. (aNFItem[nItem][IT_TS][TS_CSTCOF] $"04#06#73" .Or. aNFItem[nItem][IT_TS][TS_PSCFST]== "3"))
						nAliqCF2:=0
					EndIF

					aNfItem[nItem][IT_ALIQCF2]	:= IIf( aSX6[MV_APURCOF] , aSX6[MV_TXCOFIN] , nAliqCF2 ) // MV_APURCOF = .T. pegar aliquota do MV_TXCOFIN

					If aPE[PE_MaCofDif] // //Ponto de Entrada para calculo de Cofins Apuracao com Aliquota Diferenciada
						aMaCOFDif := ExecBlock("MaCofDif",.F.,.F.,{nItem,nAliqCF2})
						If aMaCOFDif[1] == "S"
							aNfItem[nItem][IT_ALIQCF2] := aMaCOFDif[2]
						EndIf
					EndIf

					//Aliquota Majorada do COFINS, Majora a Aliquota do COFINS APURACAO qunado for Importacao. MaFisII
					If aNFItem[nItem][IT_TS][TS_ALQCMAJ] > 0 .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F" .And. ((aNFCab[NF_TPCLIFOR] =="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3") .Or. aNFItem[nItem][IT_TS][TS_IMPIND] == "1") .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123"
						aNfitem[nItem][IT_ALIQCF2] := aNFitem[nItem][IT_ALIQCF2] + aNFItem[nItem][IT_TS][TS_ALQCMAJ]
					EndIf

					IF lDc5602
						aNfitem[nItem][IT_ALIQCF2]:= 0
					EndIF

					//Ponto de Entrada - Atua, tanto na alíquota, quanto na base e valor do COFINS Apuracao	
					If (aPE[PE_MACCOFAPU] .And. aMaCCOFAPU[1] == "S" .And. Len(aMaCCOFAPU) > 1)
						aNfItem[nItem][IT_ALIQCF2] := aMaCCOFAPU[2]
					EndIf

				EndIf

				//COFINS APURACAO - BASE - IT_BASECF2
				If "BSE" $ cExecuta
					If !aNFItem[nItem][IT_TS][TS_PISCRED] $ "5" .AND. !aNfItem[nItem][IT_TIPONF]$"I|P"

						If ( nPautaSB1 == 0 .And. (Empty(aNFitem[nItem][IT_EXCECAO]) .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][11])))) .Or.;
							(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][11])) .Or.;
							aNfItem[nItem,IT_QUANT]==0 .Or. aSX6[MV_COFPAUT]

							If (( nPautaSB1 == 0 .And. (Empty(aNFitem[nItem][IT_EXCECAO]) .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][11])))) .Or.;
								(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][11]) .And. nPautaSB1 == 0) .Or.;
								(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][13])) .Or. ;
								aNfItem[nItem,IT_QUANT]==0) .Or. (lCofMin)

								nBaseCF2 := aNfItem[nItem][IT_VALMERC]-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_VALICM],0)

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

								If aNFItem[nItem][IT_TS][TS_AGRCOF]=="C"
									nAliqAgr += aNfItem[nItem][IT_ALIQCF2]
									lAgreg	 := .T.
									If aNFItem[nItem][IT_TS][TS_AGRPIS]=="P"
										nAliqAgr += aNfItem[nItem][IT_ALIQPS2]
									Endif
								Endif

								If lAgreg

									If aSX6[MV_RNDICM]
										nBaseCF2 := Round(nBaseCF2 / ( 1 - (nAliqAgr/100)) , 2 )
									Else
										nBaseCF2 := nBaseCF2 / ( 1 - (nAliqAgr/100))
									EndIf

								Endif

								If aNFItem[nItem][IT_TS][TS_AGREG] == "I" .And. !lAgreg
									nBaseCF2 += If(aNFitem[nItem][IT_TIPONF ]<>"I",aNfItem[nItem][IT_VALICM],0)
								EndIf

								If !(aNFItem[nItem][IT_TS][TS_AGREG]=="I" .AND. lAgreg .AND. aSX6[MV_DBSTCOF]$"1|6" .AND. lIntTms) //Tratamento para não duplicar o valor do icms na base de cof
									nBaseCF2 := ( nBaseCF2 - IIf( aNFItem[nItem][IT_TS][TS_COFBRUT] == "1" , 0 , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]+aNfItem[nItem][IT_DS43080]) ) + aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS] + IIf(aNfItem[nItem][IT_DESCZFCOF]<>0,0,IIF(aNFItem[nItem][IT_TS][TS_CRPRST]<>0 .And. lIntTms,aNfItem[nitem][IT_VLCSOL],aNfItem[nitem][IT_VALSOL])) )
								EndIf

								If ( !(aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_CALCSUF]$"SI" .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
									aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ) .And. aSX6[MV_FRTBASE] ) .Or. aSX6[MV_FRTBASE]
									nBaseCF2 += IIf(aNFItem[nItem][IT_TS][TS_DESPCOF] <> "2",aNfItem[nItem][IT_DESPESA],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPCOF] <> "2",aNfItem[nItem][IT_SEGURO],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPCOF] <> "2",aNfItem[nItem][IT_FRETE],0)
								EndIf

								// Campo A2_DEDBSPC em branco ou "1": segue a regra antiga (Parametro MV_DEDBCOF)
								// Processa sempre legado quando Saídas diferente de Devolucao/Benef
								If aNFCab[NF_DEDBSPC] $ " 1" .Or. (aNfCab[NF_OPERNF] == "S" .And. !aNFitem[nItem][IT_TIPONF ] $ "BD" )

									If aNFItem[nItem][IT_TS][TS_CREDIPI] == "N" .AND. aNFItem[nItem][IT_TS][TS_IPI] <> "R";
										.AND. ( aSX6[MV_DEDBCOF]$"S,P" .AND. ( aNfItem[nItem][IT_EMISNFORI] >= aSX6[MV_ICMDSDT] .OR. Empty(aNfItem[nItem][IT_EMISNFORI]) ) )

										nBaseCF2 += aNfItem[nItem][IT_VALIPI]
									EndIf
									If !(aNFItem[nItem][IT_TS][TS_AGREG]$"DR")
										If ( aSX6[MV_DEDBCOF]$"S,I" .AND. ( aNfItem[nItem][IT_EMISNFORI] >= aSX6[MV_ICMDSDT] .OR. Empty(aNfItem[nItem][IT_EMISNFORI]) ) )
											If !Substr(aNFItem[nItem][IT_CLASFIS], 2)$aSX6[MV_DICMISE]
												nBaseCF2 -= aNfItem[nItem][IT_VALICM]
											EndIf
										EndIf
									EndIf
									
									If aNFItem[nItem][IT_TS][TS_CREDIPI] == "S" .And. aNFItem[nItem][IT_TS][TS_IPI]$ "RS" ;
										.And. ( aSX6[MV_DEDBCOF]$"S,P" .AND. ( aNfItem[nItem][IT_EMISNFORI] >= aSX6[MV_ICMDSDT] .OR. Empty(aNfItem[nItem][IT_EMISNFORI]) ) )

										nBaseCF2 -= aNfItem[nItem][IT_VALIPI]
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
											nBaseCF2 -= aNfItem[nItem][IT_VALICM]
											nBaseCF2 -= aNfItem[nItem][IT_VALIPI]
										Case aNFCab[NF_DEDBSPC] == "3" .And. !Substr(aNFItem[nItem][IT_CLASFIS], 2)$aSX6[MV_DICMISE]
											nBaseCF2 -= aNfItem[nItem][IT_VALICM]
										Case aNFCab[NF_DEDBSPC] == "4"
											nBaseCF2 -= aNfItem[nItem][IT_VALIPI]
										Case aNFCab[NF_DEDBSPC] == "6" .And. aNfItem[nItem][IT_TS][TS_LFIPI] <> "T" .AND. aNFItem[nItem][IT_TS][TS_IPI] <> "R"
											nBaseCF2 += aNfItem[nItem][IT_VALIPI]
									EndCase
								EndIf

								//Exclui valor do Difal (EC/15) da base de cálculo de COFINS
								IF aNfItem[nItem][IT_TS][TS_DIFALPC] == '1'
									nBaseCF2 -= (aNfItem[nItem][IT_DIFAL]+aNfItem[nItem][IT_VALCMP]+aNfItem[nItem][IT_VFCPDIF])
								EndIF

								If aSX6[MV_CRDBCOF] $ "S" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3"
									nBaseCF2 += aNfItem[nItem][IT_VALICM]
								EndIf

								If aNFItem[nItem][IT_TS][TS_COFDSZF] == "2"
									nBaseCF2 += aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS])
								Endif

								//Tratamento para retirada do valor do ICMS solidario da base do COFINS Apuracao
								If ((MaFisDbST("CF2",nItem) .Or. (aSX6[MV_RPCBIZF] .And. aNfCab[NF_SUFRAMA])) .And. aNfItem[nItem][IT_DESCZFCOF] == 0)
									nBaseCF2 -= IIF(aNFItem[nItem][IT_TS][TS_CRPRST]<>0 .And. lIntTms,aNfItem[nitem][IT_VLCSOL],aNfItem[nitem][IT_VALSOL])
								Endif
							Else
								nBaseCF2 := IIF(lSegUndPau,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT])
							EndIf

							nBaseCF2 += aNfItem[nItem][IT_ACRESCI]
							
							nBaseCF2 *= nFatRedCOF

							if aSX6[MV_DEISSBS] == .F. .And. aNfCab[NF_OPERNF]=="S"
								aNfItem[nItem][IT_BASECF2] := nBaseCF2 - aNfItem[nItem][IT_VALISS]
							else
								aNfItem[nItem][IT_BASECF2] := nBaseCF2
							endif

							If !aSX6[MV_RNDICM] .And. lAgreg
								MaItArred(nItem,{"IT_BASECF2"})
							EndIf

							If aNFItem[nItem][IT_TS][TS_OPERSUC]=="1" .And. aNfCab[NF_SIMPSC]<>"1" .And. aNFCab[NF_SIMPNAC]<>"1" // Operacoes com Sucata
								nBaseCF2 := (aNFitem[nItem][IT_VALICM] / ( (100-(aNFitem[nItem][IT_ALIQICM]+aNFitem[nItem][IT_ALIQPS2]+aNFitem[nItem][IT_ALIQCF2]))/100 ) )
								aNfItem[nItem][IT_BASECF2] := nBaseCF2
							Endif
						Else
							//Calculo da BASE COFINS APURACAO pela PAUTA do SB1 ou EXCECAO
							If (Empty(aNFitem[nItem,IT_EXCECAO]) .Or. Empty(aNFItem[nItem,IT_EXCECAO,11]))
								nBaseCF2 := IIF(lSegUndPau,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT]) * nPautaSB1
								aNfItem[nItem][IT_PAUTCOF]	:= nPautaSB1
							Else
								nBaseCF2 := aNfItem[nItem,IT_QUANT] * aNFItem[nItem,IT_EXCECAO,11]
								aNfItem[nItem][IT_PAUTCOF]	:= aNFItem[nItem,IT_EXCECAO,11]
							EndIf

							aNfItem[nItem][IT_BASECF2] := nBaseCF2

						EndIf
						
						//Agregar o valor do pedagio na base do PIS/COFINS
						If	aNFItem[nItem][IT_TS][TS_AGRPEDG] $ "4|5" .And. aNfItem[nItem][IT_VALPEDG] > 0
							aNfItem[nItem][IT_BASECF2] += aNfItem[nItem][IT_VALPEDG]
						EndIf

						//Zera a BASE do COFINS APURACAO somente quando a aliquota for = 0 e o CSTCOF  NAO for = "04#06#73"
						If Empty( aNfItem[nItem][IT_ALIQCF2] ) .And. ((aPE[PE_MACSTPICO] .And. !ExecBlock("MaCstPiCo",.F.,.F.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})[2]$"04#06#73") .Or. (!aPE[PE_MACSTPICO] .And. !aNFItem[nItem][IT_TS][TS_CSTCOF] $"04#06#73")) .AND. !lDc5602 .And. !lZFMAlqZ
							aNfItem[nItem][IT_BASECF2] := 0
						EndIf

					Else
						aNfItem[nItem][IT_BASECF2] := 0
					EndIf

					//Especifico para VEICULOS
					If cPaisLoc == "BRA" .And. aSX6[MV_CALCVEI] .And. "CF2" $ cTipo .And. aNfCab[NF_OPERNF] == "S" .And. aPos[FP_B1_CHASSI] .And. !Empty( aNfItem[nItem][IT_PRD][SB_CHASSI] ) // Alteracao de base para veiculos usados
						If aNfItem[nItem][IT_BASVEIC] == 0
							aAreaSC6 := SC6->(GetArea())
							SC6->(dbSetOrder(1))
							If SC6->( MsSeek(xFilial("SC6")+aNfCab[NF_PEDIDO]+aNfItem[nItem][IT_ITEM]+aNfItem[nItem][IT_PRODUTO]) )
								aNfItem[nItem][IT_BASVEIC] := SC6->C6_BASVEIC
							EndIf
							RestArea(aAreaSC6)
						EndIf
						aNfItem[nItem][IT_BASECF2] -= aNfItem[nItem][IT_BASVEIC]
						If aNfItem[nItem][IT_BASECF2] < 0
							aNfItem[nItem][IT_BASECF2] := 0
						EndIF
					EndIf

					//Ponto de Entrada - Atua, tanto na alíquota, quanto na base do PIS Apuracao
					If (aPE[PE_MACCOFAPU] .And. aMaCCOFAPU[1] == "S" .And. Len(aMaCCOFAPU) > 2)
						aNfItem[nItem][IT_BASECF2]:= aMaCCOFAPU[3]
					EndIf

				EndIf

				//Define o Valor do COFINS MAJORADO conforme aliquota informada na TES.
				If aNFItem[nItem][IT_TS][TS_ALQCMAJ] > 0
					aNfItem[nItem][IT_VALCMAJ] := aNfItem[nItem][IT_BASECF2] * (aNFItem[nItem][IT_TS][TS_ALQCMAJ]/100)
				EndIf

				//COFINS APURACAO - VALOR - IT_VALCF2
				If "VLR" $ cExecuta
					If ((nPautaSB1 == 0 .And. (Empty(aNFitem[nItem][IT_EXCECAO]) .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. Empty(aNfItem[nItem][IT_EXCECAO][11])))) .Or.;
						aNfItem[nItem,IT_QUANT]==0 .Or. !aSX6[MV_PISPAUT]) .Or. (aPE[PE_MACCOFAPU] .And. aMaCCOFAPU[1] == "S" .And. Len(aMaCCOFAPU) > 2)

						aNfItem[nItem][IT_VALCF2] := aNfItem[nItem][IT_BASECF2]*aNfItem[nItem][IT_ALIQCF2]/100
					Else
						//COFINS APURACAO - Aplica PAUTA SB1 ou Excecao
							If Empty(aNFitem[nItem,IT_EXCECAO]) .Or. (Empty(aNFItem[nItem,IT_EXCECAO,11]) .And. Empty(aNFItem[nItem,IT_EXCECAO,13]))
								nAxPautaB1 := nPautaSB1
							Else
								nAxPautaB1 := aNFItem[nItem,IT_EXCECAO,11]
							Endif

						If aNfItem[nItem][IT_BASECF2] <> 0
							IF lCofMin
								nVlOprCof	:= aNfItem[nItem][IT_BASECF2]*aNfItem[nItem][IT_ALIQCF2]/100
								nVlPautCof	:= IIF(lSegUndPau .And. aNfItem[nItem][IT_PRD][SB_CONV] > 0,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT]) * nAxPautaB1

								IF nVlOprCof < nVlPautCof
									aNfItem[nItem][IT_BASECF2] := IIF(lSegUndPau .And. aNfItem[nItem][IT_PRD][SB_CONV] > 0,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT])
									aNfItem[nItem][IT_ALIQCF2] := nAxPautaB1
									aNfItem[nItem][IT_VALCF2]  := aNfItem[nItem][IT_BASECF2] * aNfItem[nItem][IT_ALIQCF2]
									aNfItem[nItem][IT_PAUTCOF] := nAxPautaB1

									/*Se efetuou o cálculo por pauta e o CST não for 03, forço o 03*/
									IF aNFItem[nItem][IT_TS][TS_CSTCOF] <> '03' .And. aNfCab[NF_OPERNF] == "S"
										aNFItem[nItem][IT_TS][TS_CSTCOF] := '03'
									ENDIF
									aNFItem[nItem][IT_PAUTACF] := .T.
								ELSE
									aNfItem[nItem][IT_VALCF2]  := 	nVlOprCof
									aNfItem[nItem][IT_PAUTCOF] := 0
									aNFItem[nItem][IT_PAUTACF] := .F.
									// Quando CST não mudar para 03 não ira gravar tabela da receita
									aNfItem[nItem][IT_TABNTRE] := ""
									aNfItem[nItem][IT_CODNTRE] := ""
									aNfItem[nItem][IT_GRPNTRE] := ""
									aNfItem[nItem][IT_DATNTRE] := cTod("//")
								ENDIF
							ElseIf !Empty(aNFitem[nItem,IT_EXCECAO]) .And. !Empty(aNFItem[nItem,IT_EXCECAO,13])
								aNfItem[nItem][IT_BASECF2] := aNfItem[nItem][IT_VALMERC]-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_VALICM],0)
								aNfItem[nItem][IT_ALIQCF2] := aNFItem[nItem,IT_EXCECAO,13]
								aNfItem[nItem][IT_VALCF2]  := aNfItem[nItem][IT_BASECF2] * aNfItem[nItem][IT_ALIQCF2] /100
								aNfItem[nItem][IT_PAUTCOF] := aNFItem[nItem,IT_EXCECAO,11]
								aNFItem[nItem][IT_PAUTACF] := .F.
							ELSE
								aNfItem[nItem][IT_BASECF2] := IIF(lSegUndPau,ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem,IT_QUANT])
								aNfItem[nItem][IT_ALIQCF2] := nAxPautaB1
								aNfItem[nItem][IT_VALCF2]  := aNfItem[nItem][IT_BASECF2] * aNfItem[nItem][IT_ALIQCF2]
								aNfItem[nItem][IT_PAUTCOF] := nAxPautaB1
								aNFItem[nItem][IT_PAUTACF] := .T.
							ENDIF
							
						EndIf
					EndIf

					If aNFItem[nItem][IT_TS][TS_AGRCOF]=="C"
						aNfItem[nItem][IT_VALCF2] := Round(aNfItem[nItem][IT_VALCF2],2)
					EndIf

					//DESCONTO SUFRAMA - COFINS APURACAO
					If !lZFMAlqZ .And. aNfCab[NF_CLIFOR]=="C" .And. !aNfCab[NF_CALCSUF]$"IN " .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
						aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] .And. ( aNFItem[nItem][IT_TS][TS_PISCRED]$"134" )

						If ( aPE[PE_MACSTPICO] .And. ExecBlock("MaCstPiCo",.f.,.f.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})[2]$"04#06#73") .Or. ( !aPE[PE_MACSTPICO] .And. aNFItem[nItem][IT_TS][TS_CSTCOF] $"04#06#73")
							If aNfItem[nItem][IT_PAUTCOF] == 0
								aNfItem[nItem][IT_VALCF2]:= aNfItem[nItem][IT_BASECF2] * nAliqBase / 100								
							Else
								aNfItem[nItem][IT_VALCF2]:= aNfItem[nItem][IT_BASECF2]
							EndIf
						Endif
						If aNfItem[nItem][IT_DESCZFCOF] > 0
							MaItArred(nItem,{"IT_DESCZFCOF"})					
							aNfItem[nItem][IT_DESCZF] -= aNfItem[nItem][IT_DESCZFCOF]
						Endif
						MaItArred(nItem,{"IT_VALCF2"})

						If aNfCab[NF_ROTINA] $ "MATA461|FATA701" .Or. cFunName $ "MATA920|OFIXA018|OFIXA011|OFIXA100"
							aNfItem[nItem][IT_VALMERC]+= aNfItem[nItem][IT_DESCZFCOF]
							aNfItem[nItem][IT_VALMERC]-= aNfItem[nItem][IT_VALCF2]
							If cPaisLoc == "RUS"
								aNfItem[nItem][IT_VALMERC_C1]+= xMoeda(aNfItem[nItem][IT_DESCZFCOF],aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
								aNfItem[nItem][IT_VALMERC_C1]-= xMoeda(aNfItem[nItem][IT_VALCF2],aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
							EndIf
							If cFunName $ "MATA920"
								aNfItem[nItem][IT_PRCUNI] := aNfItem[nItem][IT_VALMERC]/aNfItem[nItem][IT_QUANT]
							Elseif cFunName $  "MATA461|MATA460A|FATA701|OFIXA018|OFIXA011|OFIXA100"
								aNfItem[nItem][IT_PRCUNI] := (aNfItem[nItem][IT_VALMERC]- (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) + aNfItem[nItem][IT_ACRESCI] )/aNfItem[nItem][IT_QUANT]
							EndIf
						EndIf
						aNfItem[nItem][IT_DESCZFCOF]:= aNfItem[nItem][IT_VALCF2]
						MaItArred(nItem,{"IT_DESCZFCOF"})
						aNfItem[nItem][IT_DESCZF]   += aNfItem[nItem][IT_DESCZFCOF]
						aNfItem[nItem][IT_VALCF2]   := 0
						If aNFItem[nItem][IT_TS][TS_PSCFST] == "1" .And. !aNFItem[nItem][IT_TS][TS_CSTCOF] $"04#06#73"
							aNfItem[nItem][IT_BASECF2]  := 0
						EndIf
					EndIf

					MaItArred(nItem,{"IT_VALCF2"})
				Endif
				If "CF2" $ cTipo
					If aPE[PE_MACOFVEIC] // ATENCAO!!! Ponto de entrada para uso exclusivo da TOTVS, nao sugerir o uso do mesmo a clientes - GDP FISCAL
						aMaCOFVeic := ExecBlock("MaCOFVeic",.F.,.F.,{nItem,aNfItem[nItem][IT_BASECF2],aNfItem[nItem][IT_ALIQCF2],aNfItem[nItem][IT_VALCF2]})
						aNfItem[nItem][IT_BASECF2] := aMaCOFVeic[1]
						aNfItem[nItem][IT_ALIQCF2] := aMaCOFVeic[2]
						aNfItem[nItem][IT_VALCF2]  := aMaCOFVeic[3]
					EndIf
				Endif
			Else
				If "BSE" $ cExecuta
					aNfItem[nItem][IT_BASECF2]:= 0
				EndIf
				If "VLR" $ cExecuta
					aNfItem[nItem][IT_VALCF2] := 0
				EndIf
				If "ALQ" $ cExecuta
					aNfItem[nItem][IT_ALIQCF2]:= 0
				EndIf
			EndIf
		EndIf

		// Se for reprocessamento restauro a base, aliquota e valor originais.
		If lReproc .And. !lTribCOF 
			aNfItem[nItem][IT_BASECF2] := nBaseOri
			aNfItem[nItem][IT_ALIQCF2] := nAliqOri
			aNfItem[nItem][IT_VALCF2] := nValOri
			aNfItem[nItem][IT_VALCMAJ] := nMajOri
		EndIf
	EndIf
	
Else
	AtuLegCOF(aNfItem,nItem,1)
	MaItArred(nItem,{"IT_VALCF2"})
EndIf

//COFINS RETENCAO - IT_BASECOF / IT_ALIQCOF / IT_VALCOF
If !lTribCOFRet
	If "COF" $ cTipo
		//Define a Aliquota do COFINS RETENCAO - IT_ALIQCOF
		If "ALQ" $ cExecuta
			If Empty(nAliqSB1) .Or. aSX6[MV_TPALCOF] == "1"
				If !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCCOF] == "S" .And. !Empty(aInfNat[NT_PERCCOF])

					nAliqCOF :=  aInfNat[NT_PERCCOF]

					If nModulo == 43 .And. SA1->A1_TPESSOA == "EP" // Para o Tipo de Cliente 'Empresa Publica',quando transporte for Internacional,nao gerar a retencao de PIS/COFINS -- BOPS 153148
						aAreaSA1 := SA1->(GetArea())
						SA1->(dbSetOrder(1))
						If SA1->(msSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)) .And. SA1->A1_EST == "EX"
							nAliqCOF := 0
						EndIf
						RestArea(aAreaSA1)
					EndIf

				EndIf
				If aPE[PE_MACALCCOF]
					If aMaCalcCOF[1] == "S" .And. !Empty(aMaCalcCOF[2])
						nAliqCOF := aMaCalcCOF[2]
					EndIf
				EndIf
			EndIf
			aNfItem[nItem][IT_ALIQCOF]	:= nAliqCOF
		Endif

		//Calculo de BASE e VALOR do COFINS RETENCAO - IT_BASECOF e IT_VALCOF
		If "BSE" $ cExecuta .Or. "VLR" $ cExecuta
			If ( aPE[PE_MACALCCOF] .And. aMaCalcCOF[1]=="S" ) .Or. ( !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCCOF]=="S" ;
				.And. aNfCab[NF_RECCOFI] $ "S|P" .And. ( aNfItem[nItem][IT_PRD][SB_COFINS] == "1" .Or. (aNfCab[NF_RECCOFI] == "P" .And. !aSX6[MV_RETEMPU]) ) )
				// A base de calculo da retencao eh o valor da duplicata
				// porem de acordo com a Cons. Trib. Liz, o valor do ISS nao
				// devera ser deduzido da base do PIS/COF/CSL retencao. Para
				// isso foi criado o parametro MV_DEISSBS que se estiver como
				// .T. nao sera descontado e se estiver como .F. - default sera
				//MV_RETEMPU Define a forma de calculo de retenção para empresas publicas, caso esteja = .T. passará a validar informações dos campos de retenção do cadastro de produtos e não mais do cadastro de clientes. 
				nDescISS := Iif( aSX6[MV_DEISSBS] .And. aNfCab[NF_RECISS]=="1" .And. aSX6[MV_DESCISS] .And. aNfCab[NF_OPERNF]=="S" .And. aSX6[MV_TPABISS]=="1",aNfItem[nItem][IT_VALISS],0)
				nBaseCOF := aNfItem[nItem,IT_BASEDUP] + IIf( aSX6[MV_COFBRU] == "1" , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) , 0 ) + nDescISS

				// Retirado:
				// 		Inciso II, paragrafo 2º, artigo 1º da Lei 10845/02
				//		Issue - DSERFIS2-386
				If aNfItem[nItem][IT_TS][TS_APLREPC]$"23"
					nBaseCOF *= nFatRedCOF
				EndIf

				//Tratamento extraido da funcao MaFisVTot para saber se foi contemplado o VALOR DE IPI na base da duplicata para que eu possa subtrair
				If (aNFItem[nItem][IT_TS][TS_IPIPC]=="2") .And. (aNFitem[nItem][IT_TIPONF]=="P" .Or. aNFItem[nItem][IT_TS][TS_IPI]<>'R')
					nBaseCOF -= aNfItem[nItem][IT_VALIPI]
				EndIf
				If aSX6[MV_CRDBCOF] $ "S" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3"
					nBaseCOF += aNfItem[nItem][IT_VALICM]
				EndIf

				// Tratamento para retirada do valor do ICMS solidario da base do COFINS Retencao
				If MaFisDbST("COF",nItem).And. aNfItem[nItem][IT_DESCZFCOF] == 0
					nBaseCOF -= aNfItem[nitem][IT_VALSOL]
				Endif

				//Quando operação de entrada com diferimento para orgão Publico, base de retenção deve ser sobre total da nota.
				If aNfItem[nItem][IT_TS][TS_PICMDIF]<>0 .And. aNfItem[nItem][IT_TS][TS_ICMSDIF]$" ,1,2" .And. aNfItem[nItem][IT_TS][TS_ICM] == "S"
					nBaseCOF += aNfItem[nItem][IT_ICMSDIF]
				EndIf
				// efetuada tratativa que leva em consideração o parâmetro MV_DEISSBS que configura se deduz o valor do ISS da base do PCC
				If "BSE" $ cExecuta
					If aPE[PE_MACALCCOF] .And. aMaCalcCOF[1]=="S"  .And. Len(aMaCalcCOF) > 2 .And. !Empty(aMaCalcCOF[3])
						aNfItem[nItem][IT_BASECOF]:= aMaCalcCOF[3]
					Elseif aSX6[MV_DEISSBS] == .F. .and. aSX6[MV_TPABISS] == "2" .And. aNfCab[NF_OPERNF]=="S"// o MV_TPABISS quando 1 já retira o valor do ISS da duplicata, assim a váriavel nBaseCof já possui a dedução do valor do iss
						aNfItem[nItem][IT_BASECOF]:= nBaseCOF - aNfItem[nItem][IT_VALISS]
					else
						aNfItem[nItem][IT_BASECOF]:= nBaseCOF
					endif
				Endif
				If  "VLR" $ cExecuta
					aNfItem[nItem][IT_VALCOF] := aNfItem[nItem][IT_BASECOF] * aNfItem[nItem][IT_ALIQCOF] / 100
				Endif
				If aNfItem[nItem][IT_PRD][SB_RETOPER] == "1" .And. !aNfCab[NF_RECCOFI] == "N" //Item classificado na Medida Provisoria 252 Junho/2005 e nao aguardar o limite imposto pela Lei 10.925 (R$ 5.000,00) autopecas
					aNfItem[nItem][IT_COF252] := aNfItem[nItem][IT_VALCOF]
				Endif

			Else
				If "BSE" $ cExecuta
					aNfItem[nItem][IT_BASECOF]:= 0
				EndIf
				If "VLR" $ cExecuta
					aNfItem[nItem][IT_VALCOF] := 0
				EndIf
			EndIf
		EndIf
		MaItArred(nItem,{"IT_VALCOF"})
	EndIf
Else
	AtuLegCOF(aNfItem,nItem,2)
EndIf

//Calcula COFINS-ST   Base  Aliquota e Valor - IT_BASECF3 - IT_ALIQCF3 - IT_VALCF3
If !lTribCOFST
	If "CF3" $ cTipo
		If aNFItem[nItem][IT_TS][TS_PSCFST] $ "1|3|4"
			//Conforme IN SRF 594 de 2005, nao devem integrar a base de calculo do PIS/COFINS ST:
			//- Receitas isentas e as decorrentes de vendas a aliquota 0
			//- Vendas canceladas
			//- Descontos incondicionais
			//- IPI
			//- ICMS ST

			If aNFItem[nItem][IT_TS][TS_PSCFST] != "4"
				If aNFItem[nItem][IT_TS][TS_IPIPC] == "2"//Somente retiro aqui o valor do PS3 e CF3 caso o campo IPIPC estiver como 2, pois se estiver como 1 já estou retirando os valores no momento de compor o IT_TOTAL

				nBaseCF3 := aNfItem[nItem][IT_TOTAL] //- ((aNfItem[nItem][IT_VALPS3]) + aNfItem[nItem][IT_VALCF3])

				If aNFItem[nItem][IT_TS][TS_APSCFST] == "1" // Caso os valores de PIS-ST e Cofins-ST estejam agregados no total da nota, eles deverão ser descontados pois já fazem parte da somatória.
					nBaseCF3 -= (aNfItem[nItem][IT_VALPS3] + aNfItem[nItem][IT_VALCF3])
				EndIf

				nBaseCF3 -= aNfItem[nItem][IT_VALIPI] //Conforme IN SRF546/2005 o valor do IPI deve integrar a base calculo PIS/COFINS ST-Zona Franca de Manaus

					If !(aNFItem[nItem][IT_TS][TS_INCSOL]$"A,N,D") // Verifica se o valor do ICMS Solidario esta agregado ao valor total
						nBaseCF3 -= aNfItem[nItem][IT_VALSOL]
					Endif
				Else
					nBaseCF3 := aNfItem[nItem][IT_VALMERC] + aNfItem[nItem][IT_VALIPI]
				Endif

				If ( !(aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_CALCSUF]$"SI" .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
						aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ) .And. aSX6[MV_FRTBASE] ) .Or. aSX6[MV_FRTBASE]
						nBaseCF3 += IIf(aNFItem[nItem][IT_TS][TS_DESPCOF] <> "2",aNfItem[nItem][IT_DESPESA],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPCOF] <> "2",aNfItem[nItem][IT_SEGURO],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPCOF] <> "2",aNfItem[nItem][IT_FRETE],0)
				EndIf
				If aNFCab[NF_CLIFOR] == "C" .And. aNFCab[NF_TIPONF] $ "DB" .And. !aNfItem[nItem][IT_TIPONF]$"I|P" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC]
					If aNFItem[nItem][IT_TS][TS_PISCRED] <> "3" .And. aNFItem[nItem][IT_TS][TS_PISCOF]$"13" .And. !aNfCab[NF_CALCSUF]$"IN "
						nBaseCF3 -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
					ElseIf aNFItem[nItem][IT_TS][TS_PISCRED] == "3" .And. aNFItem[nItem][IT_TS][TS_PISCOF]$"4" .And. aNfCab[NF_CALCSUF]$"I"
						nBaseCF3 -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
					EndIf
				Else
					If aNFItem[nItem][IT_TS][TS_PISCRED] <> "3" .And. aNFItem[nItem][IT_TS][TS_PISCOF]$"13" .And. aNFItem[nItem][IT_TS][TS_COFBRUT] == '2' .And. aNFItem[nItem][IT_TS][TS_IPIPC] <> '2'
						nBaseCF3 -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]+aNfItem[nItem][IT_DS43080])
					EndIf
				EndIf

				If aNFItem[nItem][IT_TS][TS_COFDSZF] == "2"
					nBaseCF3 += aNfItem[nItem][IT_DESCZF]
				EndIf

				nBaseCF3 *= nFatRedCOF
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
				If Len(AllTrim(aSX6[MV_B1CCFST])) > 0 .And. aPos[FP_B1_B1CCFST]
					aNfItem[nItem][IT_COECFST] := aNfItem[nItem][IT_PRD][SB_B1CCFST] // Campo onde e informado o % de Substituição tributaria da COFINS para fabrincante de cigarros.
				EndIf
				If nVlUnitCig > 0
					If aNfItem[nItem][IT_COECFST] > 0
						nBaseCF3 := ( aNfItem[nItem][IT_QUANT] * nVlUnitCig ) * aNfItem[nItem][IT_COECFST]
					Else
						nBaseCF3 := aNfItem[nItem][IT_QUANT] * nVlUnitCig
					EndIf
				EndIF
				If aNFCab[NF_TIPONF]$"D" .And. !Empty(aNFItem[nItem][IT_RECORI]) .And. aNFCab[NF_CLIFOR] == "C"
					SD2->( MsGoto( aNFItem[nItem][IT_RECORI] ) )
					nBaseCF3 := aNfItem[nItem][IT_QUANT] * SD2->D2_BASECF3 / SD2->D2_QUANT
				EndIF
				If "BSE" $ cExecuta
					aNfItem[nItem][IT_BASECF3] := nBaseCF3
				Endif
			EndIf

			If "ALQ" $ cExecuta
				IF aNFItem[nItem][IT_TS][TS_PSCFST] == "3" // 3= Aliq. Zero
					nAliqCF3 := 0
				Elseif Len(Alltrim(aSX6[MV_B1COFST])) > 0 .And. aNfItem[nItem][IT_PRD][SB_B1COFST] > 0 	//Verifica Campo criado na SB1
					nAliqCF3 := aNfItem[nItem][IT_PRD][SB_B1COFST]
				ElseIF aSX6[MV_TXCOFST] > 0  // Verifica aliquota parametro
					nAliqCF3 := aSX6[MV_TXCOFST]
				Endif
				aNfItem[nItem][IT_ALIQCF3] := nAliqCF3
			Endif
			If "VLR" $ cExecuta
				aNfItem[nItem][IT_VALCF3]  := aNfItem[nItem][IT_BASECF3]*aNfItem[nItem][IT_ALIQCF3]/100
			Endif
		Else
			If "BSE" $ cExecuta
				aNfItem[nItem][IT_BASECF3] := 0
			EndIf
			If "ALQ" $ cExecuta
				aNfItem[nItem][IT_ALIQCF3] := 0
			EndIf
			If "VLR" $ cExecuta
				aNfItem[nItem][IT_VALCF3]  := 0
			EndIf
		EndIf
		MaItArred(nItem,{"IT_VALCF3"})
	EndIf
Else
	AtuLegCOF(aNfItem,nItem,3)
EndIf

If aSX6[MV_PCFATPC] .And. aNfCab[NF_OPERNF] == "S" .And. !Empty(aNfCab[NF_CLIEFAT])
	aNFitem[nItem][IT_EXCECAO] 	:= aExcecao
	aNfCab[NF_NATUREZA] 		:= cNatureza
EndIf

Return

/*/{Protheus.doc} COFConvRf 
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Erich Buttner
    @since 10/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function COFConvRf(aNfItem, nItem, ccampo, nExecuta)
 Local cCampoConv 	:= ""
 Local cCmpRefBase  := ""
 Local cCmpRefAliq  := ""
 Local cCmpRefVlr	:= ""
 
If nExecuta == 1 //COFINS Apuração 
    cCmpRefBase := "IT_BASECF2"
	cCmpRefAliq := "IT_ALIQCF2"
	cCmpRefVlr	:= "IT_VALCF2"
Elseif nExecuta == 2 // COFINS ST
    cCmpRefBase := "IT_BASECF3"
	cCmpRefAliq := "IT_ALIQCF3"
	cCmpRefVlr	:= "IT_VALCF3"
ElseIF nExecuta == 3 // COFINS Retenção
    cCmpRefBase := "IT_BASECOF"
	cCmpRefAliq := "IT_ALIQCOF"
	cCmpRefVlr	:= "IT_VALCOF"
Endif

IF cCampo $ cCmpRefVlr
    cCampoConv := "TG_IT_VALOR"		
Elseif cCampo $ cCmpRefBase	
    cCampoConv := "TG_IT_BASE"
ElseIf cCampo $ cCmpRefAliq
	cCampoConv := "TG_IT_ALIQUOTA"					
Endif	

Return cCampoConv

/*/{Protheus.doc} AtuLegCOF
(Função responsavel por preencher as referencia legado com os valores das referencia do configurador)

@author Erich Buttner
@since 10/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
/*/
Static Function AtuLegCOF(aNfItem,nItem,nExecuta)
Local nPosTgCOF		:= 0
Local nPosTgCFRET   := 0
Local nPosTgCFST	:= 0 

If nExecuta == 1 
	If (nPosTgCOF := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_COF})) >0  

		aNfItem[nItem][IT_VALCF2]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCOF][TG_IT_VALOR]
		aNfItem[nItem][IT_BASECF2]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCOF][TG_IT_BASE]
		aNfItem[nItem][IT_ALIQCF2]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCOF][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_PAUTCOF]		 := aNfItem[nItem][IT_TRIBGEN][nPosTgCOF][TG_IT_PAUTA]
		aNFItem[nItem][IT_TS][TS_CSTCOF] := aNfItem[nItem][IT_TRIBGEN][nPosTgCOF][TG_IT_REGRA_ESCR][RE_CST]

		IF aNfItem[nItem][IT_PAUTCOF] > 0
			aNFItem[nItem][IT_PAUTACF] := .T.
			aNfItem[nItem][IT_PRD][SB_VLR_COF] := IT_PAUTCOF		
		Endif

	EndIf
	//COF Majoracão
	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_COFMAJ})) > 0 	
		
		aNfItem[nItem][IT_ALQCMAJ]   		:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_VALCMAJ]    		:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]	
		aNFItem[nItem][IT_TS][TS_ALQCMAJ]	:= aNfItem[nItem][IT_ALQCMAJ]
	EndIf 

	//Zona Franca Manaus
	ZFTribLeg(aNFItem, nItem)

Endif

If nExecuta == 2 .And. (nPosTgCFRET := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_COFRET})) >0  

	aNfItem[nItem][IT_VALCOF]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCFRET][TG_IT_VALOR]
	aNfItem[nItem][IT_BASECOF]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCFRET][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQCOF]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCFRET][TG_IT_ALIQUOTA]
	aNFItem[nItem][IT_TS][TS_CSTCOF] := aNfItem[nItem][IT_TRIBGEN][nPosTgCFRET][TG_IT_REGRA_ESCR][RE_CST]

Endif

If nExecuta == 3 .And. (nPosTgCFST := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_COFST})) >0  

	aNfItem[nItem][IT_VALCF3]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCFST][TG_IT_VALOR]
	aNfItem[nItem][IT_BASECF3]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCFST][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQCF3]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCFST][TG_IT_ALIQUOTA]
	aNFItem[nItem][IT_TS][TS_CSTCOF] := aNfItem[nItem][IT_TRIBGEN][nPosTgCFST][TG_IT_REGRA_ESCR][RE_CST]	
Endif

Return 
