#INCLUDE "MATXFIS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*
MaFisFECP - ALexandre Lemes - 19/10/2012
Calcula  FECP de Todos os Estados e grava a aliquota a ser
Majorada na aliquota do ICMS na referencia de Aliquota do
FECP de cada estado no array aNFItem
*/
Function FisFECP( aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cCampo, lReproc, cExecuta, aRefAlt )

Local cCfComTele	:= "1301/1302/1303/1304/1305/1306/2300/2301/2302/2303/2304/2305/2306/3301/5301/5302/5303/5304/5305/5306/5307/6302/6303/6304/6305/6306/6307/7301"
Local nAlqFecpRJ	:= aNfItem[nItem][IT_PRD][SB_FECP]
Local nAlqFecpBA	:= Iif( aPos[FP_B1_FECPBA] , aNfItem[nItem][IT_PRD][SB_FECPBA] , 0 )
Local nAlqFecpMT	:= Iif( aPos[FP_B1_FECPMT]  , aNfItem[nItem][IT_PRD][SB_FECPMT]  , 0 )
Local nAlqFecpRN	:= Iif( aPos[FP_B1_ALFECRN] , aNfItem[nItem][IT_PRD][SB_ALFECRN] , 0 )
Local nAlqFecpMG := Iif( aPos[FP_B1_ALFECMG] , aNfItem[nItem][IT_PRD][SB_ALFECMG] , 0 )
Local nAlqFecpMA	:= Iif( aPos[FP_B1_ALFUMAC] , aNfItem[nItem][IT_PRD][SB_ALFUMAC] , 0 )
Local nAlqAdicMT	:= Iif( aPos[FP_B1_ADIFECP] , aNfItem[nItem][IT_PRD][SB_ADIFECP] , 0 )
Local cCSTICMS  := SubStr(aNfitem[nItem][IT_CLASFIS], 2)
Local lFecp		:= .T.
Local lFecpST		:= cCSTICMS $ "10|30|70|60" .Or. aNfItem[nItem][IT_BASESOL] > 0  .or. (aSX6[MV_CODREG]=="1" .and. aNFItem[nItem][IT_TS][TS_CSOSN]  $"201;202;203;500" )
Local lFecpOut	:= (((aNfCab[NF_OPERNF] == "E" .And. (aNFItem[nItem][IT_TS][TS_CONSUMO]$"SO" .Or. aNFItem[nItem][IT_TS][TS_CIAP]=="S" .Or. aNFItem[nItem][IT_TS][TS_ANTICMS] == "1" )) .Or. (((aNfCab[NF_TIPONF] == "D" .Or. aNfCab[NF_OPERNF] == "S" ) .And. aNfCab[NF_PPDIFAL] .And. aNFCab[NF_LINSCR]))) .And. aNfCab[NF_UFDEST] <> aNfCab[NF_UFORIGEM])
Local aMVPPDIFAL := &(aSX6[MV_PPDIFAL])
Local lDifal 		:= Iif(valType(aMVPPDIFAL)== "A", Len(aMVPPDIFAL)>0 .And. Year(aNfCab[NF_DTEMISS]) >= aMVPPDIFAL[1][1],.F.)
Local lVenPreslj := .F.
Local lCalcVlr := .T.
Local aBaseAnt := {0,0,0}
Local aAliqAnt := {0,0,0,0}
Local aVlrAnt  := {0,0,0}
Local lTribIC  := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FECPIC)
Local lTribST  := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FCPST )
Local lTribCMP := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FCPCMP)

Default cCampo		:=	""
Default lReproc     := .F.
Default cExecuta := "BSE|ALQ|VLR"

If lReproc

	aBaseAnt := {aNfItem[nItem][IT_BASFECP], aNfItem[nItem][IT_BSFCPST], aNfItem[nItem][IT_BSFCCMP]}
	aAliqAnt := {aNfItem[nItem][IT_ALIQFECP], aNfItem[nItem][IT_ALFCST], aNfItem[nItem][IT_ALFCCMP], aNfItem[nItem][IT_FCPAUX]}
	aVlrAnt  := {aNfItem[nItem][IT_VALFECP], aNfItem[nItem][IT_VFECPST], aNfItem[nItem][IT_VFCPDIF]}

Else
	
	IF !lTribIC .AND. !lTribST .AND. !lTribCMP
		If aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI]) .and. aNFItem[nItem][IT_TS][TS_ISEFECP] <> "1" //Se não estiver marcado como Isento FECP

			If ( aNFCab[NF_CLIFOR] == "C" )
				dbSelectArea("SD2")
				MsGoto( aNFItem[nItem][IT_RECORI] )

				// Valores - Soh copio se for dev. total.

				If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT

					aNfItem[nItem][IT_VALFECP] := 0
					aNfItem[nItem][IT_VFECPST] := 0
					aNfItem[nItem][IT_VFCPDIF] := 0

					If aPos[FP_D2_VALFECP] .And. SD2->D2_VALFECP > 0
						aNfItem[nItem][IT_VALFECP] := SD2->D2_VALFECP
						lCalcVlr := .F.
					EndIf
					If aPos[FP_D2_VFECPST] .And. SD2->D2_VFECPST > 0
						aNfItem[nItem][IT_VFECPST] := SD2->D2_VFECPST
						lCalcVlr := .F.
					EndIf
					If aPos[FP_D2_VFCPDIF] .And. SD2->D2_VFCPDIF > 0
						aNfItem[nItem][IT_VFCPDIF] := SD2->D2_VFCPDIF
						lCalcVlr := .F.
					EndIf

				EndIf

			Else
				dbSelectArea("SD1")
				MsGoto( aNFItem[nItem][IT_RECORI] )

				// Valores - soh copio se for dev. total.

				If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT

					aNfItem[nItem][IT_VALFECP] := 0
					aNfItem[nItem][IT_VFECPST] := 0
					aNfItem[nItem][IT_VFCPDIF] := 0

					If aPos[FP_D1_VALFECP] .And. SD1->D1_VALFECP > 0
						aNfItem[nItem][IT_VALFECP] := SD1->D1_VALFECP
						lCalcVlr := .F.
					EndIf
					If aPos[FP_D1_VFECPST] .And. SD1->D1_VFECPST > 0
						aNfItem[nItem][IT_VFECPST] := SD1->D1_VFECPST
						lCalcVlr := .F.
					EndIf
					If aPos[FP_D1_VFCPDIF] .And. SD1->D1_VFCPDIF > 0
						aNfItem[nItem][IT_VFCPDIF] := SD1->D1_VFCPDIF
						lCalcVlr := .F.
					EndIf

				EndIf

			EndIf
		EndIf

	
		// Quando for aliquota tomo todas as decisoes p/ calculo/majoracao do FECP.
		If "ALQ" $ cExecuta

			aNfItem[nItem][IT_ALIQFECP]:= 0
			aNfItem[nItem][IT_ALFCST]  := 0
			aNfItem[nItem][IT_ALFCCMP] := 0

			// Se UFP_AFCPST for igual a "2" (Aliquota do cadastro de clientes) nao precisa preencher na CFC.
			If ((aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP] > 0 .Or. aNfItem[nItem][IT_UFXPROD][UFP_AFCPST] == '2') .And. aNFItem[nItem][IT_TS][TS_ISEFECP] <> "1")

				// Validacoes para ICMS Complementar/Antecipacao:
				// Nao majorar em Operacoes Interestaduais de Entrada para Consumo quando o campo CFC_FCPXDA = Nao
				If aNfItem[nItem][IT_UFXPROD][UFP_FECPDIF] $ "2"
					lFecpOut	:=	.F.
				Endif

				//-> Nao majorar em Operacoes Internas quanto For Venda Interna para um cliente Interestadual / Consumidor Final.
				If (aNfCab[NF_UFDEST] == aNfCab[NF_UFORIGEM] .And. (aNfItem[nItem][IT_UFXPROD][UFP_FECPINT] $ "2" .And. aNfCab[NF_TPCLIFOR] <> "F") .And. (aNfCab[NF_ROTINA] $ "LOJA701|FATA701" .OR. lReproc)  .And. aNfItem[nItem][IT_TS][TS_VENPRES] == "1") .OR. ;
					(aNfCab[NF_TIPONF] ==  "BD" .And. aNfCab[NF_UFDEST] == aNfCab[NF_UFORIGEM] .And. (aNfItem[nItem][IT_UFXPROD][UFP_FECPINT] $ "2" .And. aNfCab[NF_TPCLIFOR] <> "F") .And.  aNfItem[nItem][IT_TS][TS_VENPRES] == "1")
					lVenPreslj := .T.
				EndIf

				// Validacoes para ICMS Proprio:
				//-> Nao majorar em Operacoes Internas quando o campo CFC_FCPINT = Nao
				//-> Nao majorar em Importacoes quando o campo CFC_FCPINT = Nao
				//-> Nao majorar em Devolucoes, pois a MATXFIS busca a aliquota do documento original
				//-> Nao majorar em Operacoes Interestaduais de Entrada
				//-> Nao majorar em Operacoes Interestaduais de Saida, exceto destinadas a Consumidor Final.
				If lFecp .And.	(;
									( aNfCab[NF_UFDEST] == aNfCab[NF_UFORIGEM] .And. aNfItem[nItem][IT_UFXPROD][UFP_FECPINT] $ "2" .And. aNfCab[NF_TPCLIFOR] <> "F") .Or.;
									( aNfCab[NF_UFORIGEM] == "EX" .And. aNfItem[nItem][IT_UFXPROD][UFP_FECPINT] $ "2") .Or.;
									( aNfCab[NF_UFDEST] <> aNfCab[NF_UFORIGEM] .And. aNfCab[NF_OPERNF] == "E" .And. aNfCab[NF_UFORIGEM] <> "EX"  ) .Or.;
									( aNfCab[NF_UFDEST] <> aNfCab[NF_UFORIGEM] .And. aNfCab[NF_OPERNF] == "S" .And. aNfCab[NF_TPCLIFOR] <> "F" ) .Or.;
									( aNfCab[NF_UFDEST] <> aNfCab[NF_UFORIGEM] .And. aNfCab[NF_OPERNF] == "S" .And. aNfCab[NF_TPCLIFOR] == "F"  .And. lDifal) .Or. lVenPreslj ;
								)
					lFecp	:=	.F.
				Endif

				//Validacoes para ICMS ST: Nao majorar em Devolucoes, pois a MATXFIS busca a aliquota do documento original
				If (lFecpST .And. ( aNfCab[NF_TIPONF] $ "BD" )) .Or. lVenPreslj
					lFecpST := .F.
				Endif

				//ICMS Proprio: Nas operacoes interestaduais destinadas a nao contribuintes, devo utilizar a majoracao com aliquota do estado de origem.
				If lFecp
					If aNfCab[NF_OPERNF] == "S" .And. aNfCab[NF_UFDEST] <> aNfCab[NF_UFORIGEM] .And. aNfCab[NF_LINSCR]
						aNfItem[nItem][IT_ALIQFECP]	:= aNfItem[nItem][IT_UFXPROD][UFP_ALQFCPO]
					Else
						aNfItem[nItem][IT_ALIQFECP]	:= aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP]
					Endif

					// Se utilizar Indice Auxiliar para calculo do FECP gravo na referencia separada.
					If aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX] > 0
						aNfItem[nItem][IT_FCPAUX] := aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX]
					Endif
				Endif

				//	ICMS Substituicao Tributaria
				If lFecpST
					// Configuração de aliquota do FCP-ST por CNAE.
					If aNfItem[nItem][IT_UFXPROD][UFP_AFCPST] == '2'
						aNfItem[nItem][IT_ALFCST] := aNfCab[NF_PERFECP]
					Else
						aNfItem[nItem][IT_ALFCST] := aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP]
					EndIf

					// Se utilizar Indice Auxiliar para calculo do FECP gravo na referencia separada.
					If aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX] > 0
						aNfItem[nItem][IT_FCPAUX] := aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX]
					Endif
				Endif

				// ICMS Diferencial de Aliquotas ou Antecipacao de ICMS
				If lFecpOut
					If aNFItem[nItem][IT_TS][TS_COMPL] == "S" .Or. aNFItem[nItem][IT_TS][TS_ANTICMS] == "1"
						aNfItem[nItem][IT_ALFCCMP]	:= aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP]

						// Se utilizar Indice Auxiliar para calculo do FECP gravo na referencia separada.
						If aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX] > 0
							aNfItem[nItem][IT_FCPAUX] := aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX]
						Endif
					Endif
				Endif

			Else
				//FECP - RIO DE JANEIRO - Lei 14.264/07 - Decreto 1036 de 28/01/08
				If !aNFItem[nItem][IT_TS][TS_ISEFECP] == "1" .And. aNfItem[nItem][IT_PRD][SB_FECP] > 0

					If (( aSX6[MV_ESTADO] == "RJ" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. !(aNfCab[NF_PPDIFAL] .And. aNfCab[NF_TIPONF] =="D")) .Or. ;
						( aSX6[MV_ESTADO] == "RJ" .And. aNFCab[NF_UFDEST] == "RJ" .And. (aNFCab[NF_UFORIGEM] == "RJ" .Or. aNFCab[NF_UFORIGEM] == "EX") ) .Or. ;
						( aSX6[MV_ESTADO] == "RJ" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_LINSCR] .And. !lDifal) .Or. ;
						( aSX6[MV_ESTADO] == "RJ" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNfCab[NF_TIPONF] =="D" ) .Or.;
						( aSX6[MV_ESTADO] <> "RJ" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] == "RJ" .And. aNFCab[NF_LINSCR] .And. aNfCab[NF_PPDIFAL] .And. ((aNfItem[nItem][IT_ALIQCMP] + aNfItem[nItem][IT_PRD][SB_FECP]) > aNFitem[nItem][IT_ALIQICM])) .Or. ;
						( aSX6[MV_ESTADO] <> "RJ" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] <> "RJ" .And. aNFCab[NF_UFORIGEM] =='RJ' .And. aNfCab[NF_TIPONF] =="D" .And. aNfCab[NF_PPDIFAL]))

						If lFecpOut .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S"
							aNfItem[nItem][IT_ALFCCMP]	:= nAlqFecpRJ
						Else
							aNfItem[nItem][IT_ALIQFECP] := nAlqFecpRJ
						Endif
					EndIf

					// Se o CST for de ICMS-ST farei a majoracao do ST.
					If lFecpST

						If ( aSX6[MV_ESTADO] == "RJ" .And. aNFCab[NF_UFDEST] == "RJ" .And. aNFCab[NF_UFORIGEM] == "RJ" ) .Or. ;
							( aSX6[MV_ESTADO] <> "RJ" .And. aNFCab[NF_OPERNF] == "S" .And.  aNFCab[NF_UFDEST] == "RJ"  ) .Or. ;
							( aSX6[MV_ESTADO] == "RJ" .And. aNFCab[NF_UFDEST] == "RJ" )

							aNfItem[nItem][IT_ALFCST]  := nAlqFecpRJ
						EndIf
					EndIf
				EndIf

				//FECP - BAHIA
				If !aNFItem[nItem][IT_TS][TS_ISEFECP] == "1"

					If nAlqFecpBA > 0

						If ( aSX6[MV_ESTADO] == "BA" .And. aNFCab[NF_UFDEST] == "BA" .And. aNFCab[NF_UFORIGEM] == "BA" ) .Or. ;
							( aSX6[MV_ESTADO] == "BA" .And. aNFCab[NF_OPERNF] == "S"  .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_LINSCR] .And. !lDifal) .Or.;
							( aSX6[MV_ESTADO] <> "BA" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] == "BA" .And. aNfCab[NF_PPDIFAL]).Or.;
							( aSX6[MV_ESTADO] <> "BA" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] <> "BA" .And. aNFCab[NF_UFORIGEM]=='BA' .And. aNfCab[NF_TIPONF] =="D" .And. aNfCab[NF_PPDIFAL])

							If lFecpOut .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S"
								aNfItem[nItem][IT_ALFCCMP]	:= nAlqFecpBA
							Else
								aNfItem[nItem][IT_ALIQFECP]  := nAlqFecpBA
							Endif
						EndIf

						// Se o CST for de ICMS-ST farei a majoracao do ST.
						If lFecpST
							If ( aSX6[MV_ESTADO] == "BA" .And. aNFCab[NF_UFDEST] == "BA" .And. aNFCab[NF_UFORIGEM] == "BA" ) .Or. ;
								( aSX6[MV_ESTADO] <> "BA" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] == "BA" ) .Or. ;
								( aSX6[MV_ESTADO] == "BA" .And. aNFCab[NF_UFDEST] == "BA" )

								aNfItem[nItem][IT_ALFCST]  := nAlqFecpBA
							EndIf
						EndIf
					EndIf
				EndIf

				//FECP - MATO GROSSO
				If aNFItem[nItem][IT_TS][TS_ISEFEMT] == "2" .And. !Empty( Alltrim(aSX6[MV_FECPMT]) )

					If aSX6[MV_ESTADO] == "MT" .And. aNFItem[nItem][IT_TS][TS_ICM] == "S"  .Or.;
						( aSX6[MV_ESTADO] <> "MT" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] == "MT" .And. aNfCab[NF_PPDIFAL]) .Or.;
						( aSX6[MV_ESTADO] <> "MT" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] <> "MT" .And. aNFCab[NF_UFORIGEM]='MT' .And. aNfCab[NF_TIPONF] =="D" .And. aNfCab[NF_PPDIFAL])

						If ( aNFCab[NF_OPERNF]$"E/S" .And. Alltrim(aNfItem[nItem][IT_CF])$cCfComTele .And. aNFCab[NF_UFORIGEM] == "MT" ) .Or. ;
							( aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_LINSCR] .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. !lDifal ) .Or. ;
							( aNFCab[NF_OPERNF]$"E/S" .And. !Alltrim(aNfItem[nItem][IT_CF])$cCfComTele .And. aNFCab[NF_UFORIGEM] == "MT" .And. aNFCab[NF_UFDEST] == "MT" ) .Or. ;
							( aNFCab[NF_OPERNF] == "E" .And. Substr(aNfItem[nItem][IT_CF],1,1) == "3" .And. !Alltrim(aNfItem[nItem][IT_CF])$cCfComTele ) .Or. ;
							( aNFCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_ANTICMS] == "1" .And. aNFCab[NF_UFORIGEM] <> "MT" .And. aNFCab[NF_UFDEST] == "MT" ).OR.;
							( aNFCab[NF_OPERNF] == "E" .And. aNfCab[NF_TIPONF] =="D" .And. aNFCab[NF_UFORIGEM] == "MT" .And. aNFCab[NF_UFDEST] <> "MT" .And. aNfCab[NF_PPDIFAL])

							If lFecpOut .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S"
								aNfItem[nItem][IT_ALFCCMP]	:= nAlqFecpMT + nAlqAdicMT
							Else
								aNfItem[nItem][IT_ALIQFECP] := nAlqFecpMT + nAlqAdicMT
							EndIf
						EndIf
					EndIf

					// Atencao nas alteracoes: Este IF eh repetido no bloco de calculo do VALOR.
					If lFecpST .And. aNFCab[NF_UFDEST] == "MT" .And. aNfCab[NF_REGESIM] == "1" .And. aNfItem[nItem][IT_PRD][SB_REGESIM] == "1" .And. !aNFCab[NF_TIPONF] $ "DB"
						aNfItem[nItem][IT_ALFCST] := aNFCab[NF_PERFECP]
					EndIf
				EndIf

				//FECP - RIO GRANDE DO NORTE (FECOP)
				If aNFItem[nItem][IT_TS][TS_ISEFERN] == "2" .And. aSX6[MV_ESTADO] == "RN" .And. aNFItem[nItem][IT_TS][TS_ICM] == "S" .OR.;
					( aSX6[MV_ESTADO] <> "RN" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] == "RN" .And. aNfCab[NF_PPDIFAL]) .Or.;
					( aSX6[MV_ESTADO] <> "RN" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] <> "RN" .And. aNFCab[NF_UFORIGEM] == "RN" .And. aNfCab[NF_TIPONF] == "D" .And. aNfCab[NF_PPDIFAL])

					If nAlqFECPRN > 0
						If ( aNFCab[NF_OPERNF] == "S" .And. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S" .And. aNFCab[NF_UFORIGEM] == "RN" ) .Or. ;
							( aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFORIGEM] == "RN" .And. aNFItem[nItem][IT_TS][TS_ANTICMS] <> "1" .And. (aNFItem[nItem][IT_TS][TS_CONSUMO] $ "SO" .Or. aNFItem[nItem][IT_TS][TS_CIAP] == "S") ) .Or. ;
							( aNFCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_ANTICMS] == "1" .And. aNFCab[NF_UFORIGEM] <> "RN" .And. aNFCab[NF_UFDEST] == "RN" ) .Or. ;
							( aNFCab[NF_OPERNF] == "E" .And. Substr(aNfItem[nItem][IT_CF],1,1) == "3" ) .Or.;
							( aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] == "RN" .And. aNfCab[NF_PPDIFAL])

							If lFecpOut .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S"
								aNfItem[nItem][IT_ALFCCMP]	:= nAlqFECPRN
							Else
								aNfItem[nItem][IT_ALIQFECP] := nAlqFECPRN
							Endif
						EndIf

						// Se o CST for de ICMS-ST farei a majoracao do ST.
						If lFecpST
							If ( aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] == "RN" .And. aNFCab[NF_UFORIGEM] == "RN" ) .Or. ;
								( aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] == "RN" .And. aNFCab[NF_UFORIGEM] == "RN" .And. aNFItem[nItem][IT_TS][TS_ANTICMS] <> "1" ) .Or. ;
								( aNFCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_ANTICMS] == "1" .And. aNFCab[NF_UFORIGEM] <> "RN" .And. aNFCab[NF_UFDEST] == "RN" )

								aNfItem[nItem][IT_ALFCST] := nAlqFECPRN
							EndIf
						EndIf
					EndIf
				EndIf

				//FECP - MINAS GERAIS
				If aNFItem[nItem][IT_TS][TS_ISEFEMG] == "2" .And. !Empty( Alltrim(aSX6[MV_ALFECMG]) )

					If nAlqFecpMG > 0

						If	((aSX6[MV_ESTADO] <> "MG" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] == "MG" .And. (aNfCab[NF_PPDIFAL] .Or. lFecpST)) .Or.;
							(aSX6[MV_ESTADO] <> "MG" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFORIGEM] == "MG" .And. aNfCab[NF_TIPONF] == "D" .And. aNfCab[NF_PPDIFAL]) .Or.;
							(aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_TIPONF] == "D" .And. aNFCab[NF_UFDEST] == "MG" .And. aNFCab[NF_UFORIGEM] == "MG" .And. aNFItem[nItem][IT_TS][TS_ICM] == "S") .Or.;
							(aSX6[MV_ESTADO] == "MG" .And. aNFCab[NF_UFDEST] == "MG" .And. (aNFCab[NF_UFORIGEM] == "MG" .Or. aNFCab[NF_UFORIGEM] == "EX") .And. aNFItem[nItem][IT_TS][TS_ICM] == "S") .Or.;
							(aSX6[MV_ESTADO] == "MG" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. !(aNfCab[NF_PPDIFAL] .And. aNfCab[NF_TIPONF] =="D")) .Or.;
							(aSX6[MV_ESTADO] == "MG" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] == "MG" .And. lFecpST))

							// Se o CST for de ICMS-ST farei a majoracao do ST.
							If lFecpST
								aNfItem[nItem][IT_ALFCST] := nAlqFecpMG
							Else
								If lFecpOut .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S"
									aNfItem[nItem][IT_ALFCCMP]	:= nAlqFecpMG
								Else
									aNfItem[nItem][IT_ALIQFECP] := nAlqFecpMG
								Endif
							EndIf
						EndIf
					EndIf
				EndIf

				//FECP - MARANHAO - Lei 8.205, de 22 de dezembro de 2004  (FUMACOP)
				If nAlqFecpMA > 0
					If aSX6[MV_ESTADO] == "MA" .And. aNfCab[NF_OPERNF] == "S" .And. ( SA1->A1_CONTRIB == "2" .Or. aNFCab[NF_TPCLIFOR] == "F" ) .Or.;
						( aSX6[MV_ESTADO] <> "MA" .And. aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] == "MA" .And. aNfCab[NF_PPDIFAL]).Or.;
						( aSX6[MV_ESTADO] <> "MA" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. aNFCab[NF_UFDEST] <> "MA" .And. aNFCab[NF_UFORIGEM]=='MA' .And. aNfCab[NF_TIPONF] =="D" .And. aNfCab[NF_PPDIFAL])

						If lFecpOut .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S"
							aNfItem[nItem][IT_ALFCCMP]	:= nAlqFecpMA
						Else
							aNfItem[nItem][IT_ALIQFECP]	:= nAlqFecpMA
						Endif
					EndIf

					If lFecpST
						If ((aSX6[MV_ESTADO] == "MA" .And. aNFCab[NF_UFDEST] == "MA" .And. aNFCab[NF_UFORIGEM] == "MA" ) .Or. ;
							( aSX6[MV_ESTADO] <> "MA" .And. aNFCab[NF_OPERNF] == "S" .And.  aNFCab[NF_UFDEST] == "MA"  ) .Or. ;
							( aSX6[MV_ESTADO] == "MA" .And. aNFCab[NF_UFDEST] == "MA" ))
							aNfItem[nItem][IT_ALFCST]  := nAlqFecpMA
						EndIf
					EndIf
				EndIf
			EndIF

			// Para NF's de devolucao, utilizar a aliquota do doc. de origem.
			// Fiz este trecho no final para que caso o cliente nao possua
			// algum dos campos na base, ou esteja devolvendo uma NF emitida
			// antes da criacao dos mesmos, o sistema copie apenas o que
			// foi gravado e calcule as demais aliquotas.

			If aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI]) .and. aNFItem[nItem][IT_TS][TS_ISEFECP] <> "1" //Se não estiver marcado como Isento FECP

				If ( aNFCab[NF_CLIFOR] == "C" )

					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )

					If aPos[FP_D2_ALQFECP] .And. SD2->D2_ALQFECP > 0
						aNfItem[nItem][IT_ALIQFECP] := SD2->D2_ALQFECP
					EndIf
					If aPos[FP_D2_ALFCPST] .And. SD2->D2_ALFCPST > 0
						aNfItem[nItem][IT_ALFCST] := SD2->D2_ALFCPST
					EndIf
					If aPos[FP_D2_ALIQCMP] .And. SD2->D2_ALFCCMP > 0
						aNfItem[nItem][IT_ALFCCMP] := SD2->D2_ALFCCMP
					EndIf
					If aPos[FP_D2_FCPAUX] .And. SD2->D2_FCPAUX > 0
						aNfItem[nItem][IT_FCPAUX] := SD2->D2_FCPAUX
					EndIf

				Else

					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )

					If aPos[FP_D1_ALQFECP] .And. SD1->D1_ALQFECP > 0
						aNfItem[nItem][IT_ALIQFECP] := SD1->D1_ALQFECP
					EndIf
					If aPos[FP_D1_ALFCPST] .And. SD1->D1_ALFCPST > 0
						aNfItem[nItem][IT_ALFCST] := SD1->D1_ALFCPST
					EndIf
					If aPos[FP_D1_ALIQCMP] .And. SD1->D1_ALFCCMP > 0
						aNfItem[nItem][IT_ALFCCMP] := SD1->D1_ALFCCMP
					EndIf
					If aPos[FP_D1_FCPAUX] .And. SD1->D1_FCPAUX > 0
						aNfItem[nItem][IT_FCPAUX] := SD1->D1_FCPAUX
					EndIf
				EndIf
			EndIf
		EndIf

		If "BSE" $ cExecuta

			aNfItem[nItem][IT_BASFECP] := 0
			aNfItem[nItem][IT_BSFCPST] := 0
			aNfItem[nItem][IT_BSFCCMP] := 0

			If aNfItem[nItem][IT_ALIQFECP] > 0

				aNfItem[nItem][IT_BASFECP] := aNfItem[nItem][IT_BASEICM]

				If aNFItem[nItem][IT_TS][TS_PICMDIF] == 100 .And. aNFCab[NF_UFDEST] $ "RJ" .And. (aNFItem[nItem][IT_TS][TS_ICMSDIF] $ "7")
					aNfItem[nItem][IT_BASFECP] := aNfItem[nItem][IT_BASEICM] / (1-((aNfItem[nItem][IT_ALIQICM]+aNfItem[nItem][IT_ALIQFECP])/100))
				EndIf
				
				// Configuracao da base via CFC.
				If aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP] > 0 .And. aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPPR] == "1"
					IF aNfItem[nItem][IT_UFXPROD][UFP_BASRDZ]  == '2'
						aNfItem[nItem][IT_BASFECP] := aNfItem[nItem][IT_BICMORI]
					Else
						aNfItem[nItem][IT_BASFECP] := aNfItem[nItem][IT_BASEICM]
					EndIF
				EndIf

				// Utiliza Indice Auxiliar para calculo do FECP. Neste caso a base eh sempre o valor.
				If aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX] > 0
					aNfItem[nItem][IT_BASFECP] := aNfItem[nItem][IT_VALICM]
				Endif

			EndIf

			// ICMS-ST
			If aNfItem[nItem][IT_ALFCST] > 0

				aNfItem[nItem][IT_BSFCPST] := aNfItem[nItem][IT_BASESOL]

				If ((aSX6[MV_ESTADO] == "RJ" .And. aNFCab[NF_UFDEST] == "RJ" .And. aNFCab[NF_UFORIGEM] == "RJ") .Or. (aSX6[MV_ESTADO] == "BA" .And. aNFCab[NF_UFDEST] == "BA" .And. aNFCab[NF_UFORIGEM] == "BA"))
					aNfItem[nItem][IT_BSFCPST] := Max(( aNfItem[nItem][IT_BASESOL] - aNfItem[nItem][IT_BASEICM] ),0)
				EndIf

				If lFecpST .And. aNFCab[NF_UFDEST] == "MT" .And. aNfCab[NF_REGESIM] == "1" .And. aNfItem[nItem][IT_PRD][SB_REGESIM] == "1" .And. !aNFCab[NF_TIPONF] $ "DB"
					aNfItem[nItem][IT_BSFCPST] := Iif(aNFItem[nItem][IT_TS][TS_INCIDE] == "N", aNfItem[nItem][IT_VALIPI], 0) + aNfItem[nItem][IT_BASEICM] + aNfItem[nItem][IT_DESPESA]
				EndIf

				// Configuracao da base via CFC.
				If aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP] > 0
					Do Case
						// Base do ICMS-ST.
						Case aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPST] == "1"
							aNfItem[nItem][IT_BSFCPST] := aNfItem[nItem][IT_BASESOL]  
						// Diferenca entre as bases do ST e Proprio.
						Case aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPST] == "2"
							aNfItem[nItem][IT_BSFCPST] := Max(( aNfItem[nItem][IT_BASESOL] - aNfItem[nItem][IT_BASEICM] ),0)
						// ICMS Proprio + IPI (Quando ja nao estiver na Base) + Seguro e Despesas (Quando nao estiverem na base).
						// O frete sempre estará na base entao nao preciso somar novamente.
						Case aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPST] == "3"
							aNfItem[nItem][IT_BSFCPST] := aNfItem[nItem][IT_BASEICM] + ;
														Iif(aNFItem[nItem][IT_TS][TS_INCIDE] == "N", aNfItem[nItem][IT_VALIPI], 0) + ;
														Iif(aNFItem[nItem][IT_TS][TS_DESPICM] $ "2|3", aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO], 0)
					EndCase

				EndIf
				
				// Utiliza Indice Auxiliar para calculo do FECP. Neste caso a base eh sempre o valor.
				If aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX] > 0
					aNfItem[nItem][IT_BSFCPST] := aNfItem[nItem][IT_VALSOL]
				Endif
			EndIf

			If aNfItem[nItem][IT_ALFCCMP] > 0

				If (aNfCab[NF_PPDIFAL] .Or. (lDifal .And. aSX6[MV_ESTADO] $ aSX6[MV_BASDENT] .And. aNfCab[NF_OPERNF] == "E"))
					aNfItem[nItem][IT_BSFCCMP]	:= aNfItem[nItem][IT_BASEDES]
				Else
					aNfItem[nItem][IT_BSFCCMP]	:= aNfItem[nItem][IT_BASEICM]
				Endif

				If aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP] > 0
					// Configuracao da base via CFC.
					Do Case
						Case aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPCM] == "1"
							aNfItem[nItem][IT_BSFCCMP]	:= aNfItem[nItem][IT_BASEDES]
						Case aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPCM] == "2"
							aNfItem[nItem][IT_BSFCCMP]	:= aNfItem[nItem][IT_BASEICM]
					EndCase
				EndIf

				// Utiliza Indice Auxiliar para calculo do FECP. Neste caso a base eh sempre o valor.
				If aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX] > 0
					If aNfCab[NF_OPERNF] == "S"
						aNfItem[nItem][IT_BSFCCMP] := aNfItem[nItem][IT_DIFAL]
					Else
						aNfItem[nItem][IT_BSFCCMP] := aNfItem[nItem][IT_VALCMP]
					EndIf	
				Endif
			EndIf

			// Tratamento para devolucoes - Mesmo conceito das aliquotas: Se o cliente
			// não possuir todos os campos ou estiver devolvendo um documento lancado
			// antes da implementacao da base de calculo do FCP, ou seja, ele tem o campo
			// mas esta zerado, entao nao posso copiar da origem e devo deixar o sistema
			// efetuar os calculos.

			If aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI]) .and. aNFItem[nItem][IT_TS][TS_ISEFECP] <> "1" //Se não estiver marcado como Isento FECP

				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )

					// Bases - Soh copio se for dev. total.

					If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT

						aNfItem[nItem][IT_BASFECP] := 0
						aNfItem[nItem][IT_BSFCPST] := 0
						aNfItem[nItem][IT_BSFCCMP] := 0

						If aPos[FP_D2_BASFECP] .And. SD2->D2_BASFECP > 0
							aNfItem[nItem][IT_BASFECP] := SD2->D2_BASFECP
						EndIf
						If aPos[FP_D2_BSFCPST] .And. SD2->D2_BSFCPST > 0
							aNfItem[nItem][IT_BSFCPST] := SD2->D2_BSFCPST
						EndIf
						If aPos[FP_D2_BSFCCMP] .And. SD2->D2_BSFCCMP > 0
							aNfItem[nItem][IT_BSFCCMP] := SD2->D2_BSFCCMP
						EndIf
					EndIf
				Else
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )

					// Bases - soh copio se for dev. total.
					If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT

						aNfItem[nItem][IT_BASFECP] := 0
						aNfItem[nItem][IT_BSFCPST] := 0
						aNfItem[nItem][IT_BSFCCMP] := 0

						If aPos[FP_D1_BASFECP] .And. SD1->D1_BASFECP > 0
							aNfItem[nItem][IT_BASFECP] := SD1->D1_BASFECP
						EndIf
						If aPos[FP_D1_BSFCPST] .And. SD1->D1_BSFCPST > 0
							aNfItem[nItem][IT_BSFCPST] := SD1->D1_BSFCPST
						EndIf
						If aPos[FP_D1_BSFCCMP] .And. SD1->D1_BSFCCMP > 0
							aNfItem[nItem][IT_BSFCCMP] := SD1->D1_BSFCCMP
						EndIf

					EndIf

				EndIf
			EndIf

		EndIf

		If "VLR" $ cExecuta .And. lCalcVlr

			aNfItem[nItem][IT_VALFECP] := 0
			aNfItem[nItem][IT_VFECPST] := 0
			aNfItem[nItem][IT_VFCPDIF] := 0

			//--------------------------------------------------------------------------------------------
			// Regra Geral: Se utilizar o indice p/ calcular o FCP nao posso dividir a aliquota por 100
			// pois o indice nao eh um percentual.
			//--------------------------------------------------------------------------------------------

			// ICMS Proprio
			If aNfItem[nItem][IT_BASFECP] > 0 .And. aNfItem[nItem][IT_ALIQFECP] > 0
				aNfItem[nItem][IT_VALFECP] := aNfItem[nItem][IT_BASFECP] * Iif(aNfItem[nItem][IT_FCPAUX] > 0, aNfItem[nItem][IT_FCPAUX], ( aNfItem[nItem][IT_ALIQFECP] / 100 ))
			EndIf

			// ICMS ST
			If aNfItem[nItem][IT_BSFCPST] > 0 .And. aNfItem[nItem][IT_ALFCST] > 0
				aNfItem[nItem][IT_VFECPST] := aNfItem[nItem][IT_BSFCPST] * IIf(aNfItem[nItem][IT_FCPAUX] > 0, aNfItem[nItem][IT_FCPAUX], ( aNfItem[nItem][IT_ALFCST] / 100 ))
			EndIf

			// ICMS Complementar
			If aNfItem[nItem][IT_BSFCCMP] > 0 .And. aNfItem[nItem][IT_ALFCCMP] > 0
				If aNfCab[NF_PPDIFAL]
					aNfItem[nItem][IT_VFCPDIF] := aNfItem[nItem][IT_BSFCCMP] * Iif(aNfItem[nItem][IT_FCPAUX] > 0, aNfItem[nItem][IT_FCPAUX], ( aNfItem[nItem][IT_ALFCCMP] / 100))
				Else
					aNfItem[nItem][IT_VALFECP] := aNfItem[nItem][IT_BSFCCMP] * Iif(aNfItem[nItem][IT_FCPAUX] > 0, aNfItem[nItem][IT_FCPAUX], ( aNfItem[nItem][IT_ALFCCMP] / 100))
				EndIf
			EndIf
		EndIf
	Else
		//Função responsavel por gravar referencias com base no configurador            
		FCPConf(aNFCab,aNfItem,nItem)
	Endif

	// Quando trocar o TES preciso recalcular
	// as aliquotas para que, caso seja alterado por
	// um TES que nao calcula FECP, seja retirada a majoracao.
	If cCampo == "IT_TES" .And. !lReproc
		// Não recalcular as alíquota caso tenham sido alteradas por MaFisAlt ou MaFisLoad.
		// Esta proteção impede que, caso tenha havido uma alteração intencional na referência,
		// como por exemplo na carga do pedido de compras, esta alteração não seja desfeita.
		If !aRefAlt[nItem][IT_ALIQICM]
			MaAliqIcms(nItem)
		EndIf
		If !aRefAlt[nItem][IT_ALIQSOL]
			MaAliqSoli(nItem)
		EndIf
		If !aRefAlt[nItem][IT_ALIQCMP]
			MaAliqCmp(nItem)
		EndIf
	EndIf

EndIf

// Se for reprocessamento mantenho os valores previamente calculados.
If lReproc
	aNfItem[nItem][IT_BASFECP]  := aBaseAnt[1]
	aNfItem[nItem][IT_BSFCPST]  := aBaseAnt[2]
	aNfItem[nItem][IT_BSFCCMP]  := aBaseAnt[3]

	aNfItem[nItem][IT_ALIQFECP] := aAliqAnt[1]
	aNfItem[nItem][IT_ALFCST]	:= aAliqAnt[2]
	aNfItem[nItem][IT_ALFCCMP]	:= aAliqAnt[3]
	aNfItem[nItem][IT_FCPAUX]	:= aAliqAnt[4]

	aNfItem[nItem][IT_VALFECP]	:= aVlrAnt[1]
	aNfItem[nItem][IT_VFECPST]	:= aVlrAnt[2]
	aNfItem[nItem][IT_VFCPDIF]	:= aVlrAnt[3]
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisNameFCP

Funcao para retornar o nome do FCP conforme a UF.

@author joao.pellegrini
@since 15/09/2017
@version 11.80
/*/
//-------------------------------------------------------------------
Function FisxNameFCP(cUF, lST, lComp)

Local cRet := ""

DEFAULT lST := .F.
DEFAULT lComp := .F.

Do Case

	Case cUF $ "RJ|ES"
		cRet := "FECP"
	Case cUF $ "BA"
		cRet := "FECEP"
	Case cUF $ "MG"
		cRet := "FEM"
	Case cUF $ "CE|DF|MT|PR|PI|RN"
		cRet := "FECOP"
	Case cUF $ "MA"
		cRet := "FUMACOP"
	Case cUF $ "SE"
		cRet := "FUNPOBREZA"
	Case cUF $ "MS"
		cRet := "FECOMP"
	Case cUF $ "PB"
		cRet := "FUNCEP"
	Case cUF $ "PE"
		cRet := "FECEP"
	Case cUF $ "GO"
		cRet := "PROTEGE"
	Case cUF $ "RS"
		cRet := "AMPARA"
	Case cUF $ "RO"
		cRet := "FECOPE"
	Case cUF $ "SP|TO|AL"
		cRet := "FECOEP"

Otherwise

	cRet := "FCP"

EndCase

If lST

	cRet += " - ST"

ElseIf lComp

	cRet += " - Complementar"

EndIf

Return cRet



/*/{Protheus.doc} FCPConvRf 
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Rafael Oliveira
    @since 03/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function FCPConvRf(aNfItem, nItem, ccampo, nExecuta,aNfCab)
 Local cCampoConv 	 := ""
 Local cCmpBasRef    := ""
 Local cCmpAlqRef    := ""
 Local cCmpVlrRef    := ""
 Local cCmpAuxRef    := ""

If nExecuta == 1 // ICMS
	cCmpBasRef    := "IT_BASFECP"
	cCmpAlqRef    := "IT_ALIQFECP"
	cCmpVlrRef    := "IT_VALFECP"
Elseif nExecuta == 2 //ST
    cCmpBasRef    := "IT_BSFCPST"
	cCmpAlqRef    := "IT_ALFCST"
	cCmpVlrRef    := "IT_VFECPST"
ElseIF nExecuta == 3 // Complementar
    cCmpBasRef    := "IT_BSFCCMP"
	cCmpAlqRef    := "IT_ALFCCMP"	

	If aNfCab[NF_PPDIFAL] //Quando Difal
		cCmpVlrRef    := "IT_VFCPDIF"
	Else
		cCmpVlrRef    := "IT_VALFECP"
	EndIf	

ElseIF nExecuta == 4 // Indice Auxiliar
	cCmpVlrRef    := "IT_FCPAUX"	
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


/*/{Protheus.doc} FCPConf
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
Static Function FCPConf(aNFCab,aNfItem,nItem)
Local nPosTrG := 0

aNfItem[nItem][IT_BASFECP] 	:= 0
aNfItem[nItem][IT_ALIQFECP]	:= 0
aNfItem[nItem][IT_VALFECP] 	:= 0
aNfItem[nItem][IT_FCPAUX]  	:= 0
aNfItem[nItem][IT_BSFCPST]	:= 0
aNfItem[nItem][IT_ALFCST] 	:= 0
aNfItem[nItem][IT_VFECPST]	:= 0
aNfItem[nItem][IT_BSFCCMP]	:= 0
aNfItem[nItem][IT_ALFCCMP]	:= 0
aNfItem[nItem][IT_VFCPDIF]	:= 0

//ICMS
If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_FECPIC})) > 0 
	
	aNfItem[nItem][IT_BASFECP]    := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQFECP]  	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]
	aNfItem[nItem][IT_VALFECP]    := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]	

	aNfItem[nItem][IT_FCPAUX]    		:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_AUX_MAJ]
EndIf   

//ICMS ST
If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_FCPST})) > 0 	
	
	aNfItem[nItem][IT_BSFCPST]    := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]
	aNfItem[nItem][IT_ALFCST]  	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]
	aNfItem[nItem][IT_VFECPST]    := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]

	aNfItem[nItem][IT_FCPAUX]    		:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_AUX_MAJ]
EndIf  

//ICMS Complementar e Difal
If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_FCPCMP})) > 0 
	
	aNfItem[nItem][IT_BSFCCMP]    := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]
	aNfItem[nItem][IT_ALFCCMP]  	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]	

	If aNfCab[NF_PPDIFAL] //Quando Difal 
		aNfItem[nItem][IT_VFCPDIF]    := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
	Else
		aNfItem[nItem][IT_VALFECP]    := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
	EndIf
	
	aNfItem[nItem][IT_FCPAUX]    		:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_AUX_MAJ]

EndIf  




Return 
