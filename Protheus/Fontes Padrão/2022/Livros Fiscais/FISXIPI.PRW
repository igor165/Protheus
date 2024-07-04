#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"
#INCLUDE "MATXFIS.CH"

/*/{Protheus.doc} FISXIPI
    (Componentização da função MaFisIPI - 
    Calculo do imposto sobre produtos industrializacos ( IPI ))    
    
	@Author Renato Rezende
    @since 17/04/2020
    @version 12.1.27

    @Autor da função original 
    Alexandre Lemes # 21/11/2012

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
Function FISXIPI(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta, lNoProces, cRefSDesc,lAtuTrbLeg)
Local aRastItem	 := {}
Local nQuantPed  := 0
Local nReduzIPI  := 0
Local nSalvaBase := aNfItem[nItem][IT_BASEIPI]
Local nSalvaAliq := aNfItem[nItem][IT_ALIQIPI]
Local nSalvaValor := aNfItem[nItem][IT_VALIPI]
Local lExistNF   := .F.
Local lDevolBSE  := .F.
Local lDevolALQ  := .F.
Local lDevolVLR  := .F.
Local nQuantida  :=  0
Local lRndrne    := aSX6[MV_RNDIPI]
Local lSobra 	 := aSX6[MV_RNDSOBR]
Local cCFORemFut	:= aSX6[MV_REMVFUT]
Local lRemFut		:= .F.
Local lIpiMin		:= !Empty(aNFItem[nItem][IT_TS][TS_IPIMIN]) .And. aNFItem[nItem][IT_TS][TS_IPIMIN] == "1"
Local lSegUPau := aSX6[MV_IPI2UNI] //utiliza ou nao segunda unidade quando for pauta
Local nVlOprIPI	:= 0
Local nVlPautIPI	:= 0
Local aMaIPIVeic    := {}
Local lDeduzBA 		:= aSX6[MV_ESTADO] == "BA" .And. aNfCab[NF_UFDEST] == "BA"  .And. aNFCab[NF_SIMPNAC] =="1" .And. aNFItem[nItem][IT_TS][TS_FTRICMS] > 0
Local aMaCalcIPI    := IIf( aPE[PE_MACALCIPI] , ExecBlock("MaCalcIPI", .F., .F., {nItem, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_TES], aNfCab[NF_CLIFOR], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], aNfCab[NF_OPERNF]}) , Array(3) )
Local cFunName      := AllTrim(FunName())
Local nPosTrGIPI 	:= 0 
Local lTribGen 		:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_IPI)
Local lPautIPI		:= .F.


DEFAULT cExecuta  := "BSE|ALQ|VLR"
DEFAULT lNoProces := .F.
DEFAULT cRefSDesc := ""



/*Se for Remessa de uma entrega futura soma o IPI da NF original na base do ICMS da nota de remessa*/
lRemFut:= aNFItem[nItem][IT_TS][TS_IPI] == "N" .And. Alltrim(aNfItem[nItem][IT_CF])$cCFORemFut .And. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S" .And. aPos[FP_IPIVFCF] .And. aNFItem[nItem][IT_TS][TS_IPIVFCF]$"234"


If !lTribGen
	//O bloco a seguir providencia para que em operações de devolução e ou beneficiamento quando o parametro MV_DEVTOT = .T.
	//o valor da BASE do IPI seja igual a  Base do Imposto do documento Original quando a devolução e ou beneficiamento for
	//igual a do documento original, se houverem despesas acessorias inclusas na base do documento original (Frete, Despesas e Seguro)
	//as mesmas deverão ser digitadas manualmente no documento de devolução.
	If !Empty(aNFItem[nItem][IT_RECORI]) .And. ( aNFCab[NF_TIPONF] $ "DB" .Or. aNFItem[nItem][IT_TS][TS_PODER3] == "D" )

		lExistNF := RetComp( aNFCab[NF_CLIFOR] , aNFItem[nItem][IT_RECORI] )
		lPautIPI := iif("VLR" $ cExecuta,PautIPI(lSegUPau,aNFCab,aNFItem,nItem,@lPautIPI),.F.)

		If aNFCab[NF_TIPONF] $ "DB"
			If aNFCab[NF_CLIFOR] == "C"
				SD2->(MsGoto(aNFItem[nItem][IT_RECORI]))
				If !lExistNF .And. (aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT)  .And. (Iif(!aSX6[MV_DEVTOT] ,SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0 , SD2->D2_BASEIPI >0) .Or. ;
					(!aNfCab[NF_CALCSUF]$"IN " .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ))
					aNfItem[nItem][IT_BASEIPI] := SD2->D2_BASEIPI
					aNfItem[nItem][IT_PREDIPI]	:= aNFItem[nItem][IT_TS][TS_BASEIPI]
					lDevolBSE := .T.
				EndIf
				If !lExistNF .And. (aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S")  .And. (Iif(!aSX6[MV_DEVTOT] ,SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0 , SD2->D2_BASEIPI >0) .Or. ;
					(!aNfCab[NF_CALCSUF]$"IN " .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ))
					aNfItem[nItem][IT_BASEIPI] := ((SD2->D2_BASEIPI / SD2->D2_QUANT) * aNfItem[nItem][IT_QUANT])
					aNfItem[nItem][IT_PREDIPI]	:= aNFItem[nItem][IT_TS][TS_BASEIPI]
					lDevolBSE := .T.
				EndIf
				aNFitem[nItem][IT_ALIQIPI] := SD2->D2_IPI
				aNFitem[nItem][IT_TIPONF ] := IIf( SD2->D2_TIPO$"IP" , SD2->D2_TIPO , aNfCab[NF_TIPONF] )
				lDevolALQ := .T.
				If (SD2->D2_VALIPI > 0 .Or. Abs( aNfItem[nItem][IT_VALIPI] - SD2->D2_VALIPI) <= 1 ) .And. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .And. Iif(!aSX6[MV_DEVTOT] , SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA == 0 , SD2->D2_VALIPI > 0)
					aNfItem[nItem][IT_VALIPI] := SD2->D2_VALIPI
					if lPautIPI
						lDevolVLR := .F.
					Else
						lDevolVLR := .T.
					EndIf
				EndIf
			Else
				SD1->(MsGoto(aNFItem[nItem][IT_RECORI]))
				If !lExistNF .And. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. Iif(!aSX6[MV_DEVTOT] , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 ,SD1->D1_BASEIPI > 0)
					aNfItem[nItem][IT_BASEIPI] := SD1->D1_BASEIPI
					aNfItem[nItem][IT_PREDIPI]	:= aNFItem[nItem][IT_TS][TS_BASEIPI]
					lDevolBSE := .T.
				EndIf
				If !lExistNF .And. (aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S")  .And. (Iif(!aSX6[MV_DEVTOT] ,SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 , SD1->D1_BASEIPI >0) .Or. ;
					(!aNfCab[NF_CALCSUF]$"IN " .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ))
					aNfItem[nItem][IT_BASEIPI] := ((SD1->D1_BASEIPI / SD1->D1_QUANT) * aNfItem[nItem][IT_QUANT])
					aNfItem[nItem][IT_PREDIPI] := aNFItem[nItem][IT_TS][TS_BASEIPI]
					lDevolBSE := .T.
				EndIf
				aNFitem[nItem][IT_ALIQIPI] := SD1->D1_IPI
				aNFitem[nItem][IT_TIPONF ] := IIf( SD1->D1_TIPO$"IP" , SD1->D1_TIPO , aNfCab[NF_TIPONF] )
				lDevolALQ := .T.
				If (SD1->D1_VALIPI > 0 .Or. Abs( aNfItem[nItem][IT_VALIPI] - SD1->D1_VALIPI) <= 1 ) .And. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. Iif(!aSX6[MV_DEVTOT] , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA == 0 , SD1->D1_VALIPI > 0)
					aNfItem[nItem][IT_VALIPI] := SD1->D1_VALIPI
					if lPautIPI
						lDevolVLR := .F.
					Else
						lDevolVLR := .T.
					EndIf
				EndIf
			EndIf
		Else
			If aNFCab[NF_CLIFOR] == "C"
				SD1->(MsGoto(aNFItem[nItem][IT_RECORI]))
				If !lExistNF .And. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. Iif(!aSX6[MV_DEVTOT] , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 ,SD1->D1_BASEIPI > 0)
					aNfItem[nItem][IT_BASEIPI] := SD1->D1_BASEIPI
					aNfItem[nItem][IT_PREDIPI]	:= aNFItem[nItem][IT_TS][TS_BASEIPI]
					lDevolBSE := .T.
				EndIf
				aNFitem[nItem][IT_ALIQIPI] := SD1->D1_IPI
				aNFitem[nItem][IT_TIPONF ] := IIf( SD1->D1_TIPO$"IP" , SD1->D1_TIPO , aNfCab[NF_TIPONF] )
				lDevolALQ := .T.
				If (SD1->D1_VALIPI > 0 .Or. Abs(aNfItem[nItem][IT_VALIPI] - SD1->D1_VALIPI) <= 1 ) .And. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. Iif(!aSX6[MV_DEVTOT] , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA == 0 , SD1->D1_VALIPI > 0)
					aNfItem[nItem][IT_VALIPI] := SD1->D1_VALIPI
					if lPautIPI
						lDevolVLR := .F.
					Else
						lDevolVLR := .T.
					EndIf
				EndIf
			Else
				SD2->(MsGoto(aNFItem[nItem][IT_RECORI]))
				If !lExistNF .And. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .And. Iif(!aSX6[MV_DEVTOT] ,SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0 , SD2->D2_BASEIPI >0)
					aNfItem[nItem][IT_BASEIPI] := SD2->D2_BASEIPI
					aNfItem[nItem][IT_PREDIPI]	:= aNFItem[nItem][IT_TS][TS_BASEIPI]
					lDevolBSE := .T.
				EndIf
				aNFitem[nItem][IT_ALIQIPI] := SD2->D2_IPI
				aNFitem[nItem][IT_TIPONF ] := IIf( SD2->D2_TIPO$"IP" , SD2->D2_TIPO , aNfCab[NF_TIPONF] )
				lDevolALQ := .T.
				If (SD2->D2_VALIPI > 0 .Or. Abs(aNfItem[nItem][IT_VALIPI] - SD2->D2_VALIPI) <= 1 ) .And. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .And. Iif(!aSX6[MV_DEVTOT] , SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA == 0 , SD2->D2_VALIPI > 0)
					aNfItem[nItem][IT_VALIPI] := SD2->D2_VALIPI
					if lPautIPI
						lDevolVLR := .F.
					Else
						lDevolVLR := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf


	//Define BASE do IPI - IT_BASEIPI
	If "BSE" $ cExecuta


		If !lDevolBSE

			aNfItem[nItem][IT_BASEIPI]	:= 0

			If (aNFItem[nItem][IT_TS][TS_IPI] <> "N" .And. !aNFitem[nItem][IT_TIPONF ] $ "PI" .And. aNFCab[NF_LJCIPI]) .Or. lRemFut

				// Calculo da base de IPI.
				If aNFItem[nItem][IT_TS][TS_AGREG]<>"F"
					aNfItem[nItem][IT_BASEIPI] := aNfItem[nItem][IT_VALMERC]  
					IF lDeduzBA
						MaFisBSICM(nItem)
						aNfItem[nItem][ IT_BASEIPI] -= IIf(cRefSDesc == "1",0,(aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]))
					
					Else
						aNfItem[nItem][ IT_BASEIPI] -= IIf(cRefSDesc == "1" ,0,(aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]))
					EndIf
					If (aNFCab[NF_OPERNF] == "S" .And. aNfCab[NF_OPIRRF] == "EP" .And. cRefSDesc <> "1" ) .Or. aNfCab[NF_ROTINA] == 'LOJA701' // Somente deduz quando emitido pelo LOJA ou Saida para Orgao Publico
						aNfItem[nItem][IT_BASEIPI] -=  IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR" , aNfItem[nItem][IT_DEDICM] , 0 )
					Endif
				EndIf

				IF aNFItem[nItem][IT_TS][TS_TRANFIL] == "1" .And. aSX6[MV_PBIPITR] > 0  .And. aNFitem[nItem][IT_PRCCF] > 0
					aNfItem[nItem][IT_BASEIPI]:=aNFitem[nItem][IT_PRCCF] * (aSX6[MV_PBIPITR]/100)
				EndIf

				//Deduz PIS/Cofins Zona Franca de Manaus da base de calculo do IPI
				If aSX6[MV_IPIZFM] .And. ( aNfCab[NF_ROTINA] $ "MATA461|FATA701|MATA103" .Or. cFunName $ "MATA920|OFIXA018|OFIXA011|OFIXA100" )
					aNfItem[nItem][IT_BASEIPI] := aNfItem[nItem][IT_BASEIPI] - aNfItem[nItem][IT_DESCZFPIS] - aNfItem[nItem][IT_DESCZFCOF]
				Endif

				// Se o parâmetro está habilitado significa que não foi informado o II no valor aduaneiro então devo somar o II na base do ICMS para ficar correta.
				IF aSX6[MV_EIC0064] .And.  !( aNFItem[nItem][IT_TS][TS_AGREG] $ "B|C" ).And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F" .And. aNFCab[NF_TPCLIFOR] =="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3" .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123"
					aNfItem[nItem][IT_BASEIPI] += aNfItem[nItem][IT_VALII]
				EndIf

				//	Cálculo da base de imposto IPI, com o valor do imposto do ICMS próprio.
				If aSX6[MV_SOMAICM] 
					MaFisBSICM(nItem)
					If aNFItem[nItem][IT_TS][TS_AGREG] == "I" .And. aNFCab[NF_OPERNF] == "S"
						MaFisVICMS(nItem)
						aNfItem[nItem][IT_BASEIPI] += aNfItem[nItem][IT_VALICM]
					Endif
				Endif
                // Adição de despesas, seguros e acréscimos a Base de IPI.
				If aNFItem[nItem][IT_TS][TS_DESPIPI] == "S"
					aNfItem[nItem][IT_BASEIPI] += aNfItem[nItem][IT_DESPESA]
					aNfItem[nItem][IT_BASEIPI] += aNfItem[nItem][IT_SEGURO]
					aNfItem[nItem][IT_BASEIPI] += aNfItem[nItem][IT_ACRESCI]
				EndIf

				If aNFItem[nItem][IT_TS][TS_IPIFRET] == "S"
					aNfItem[nItem][IT_BASEIPI] += aNfItem[nItem][IT_FRETE]
				EndIf

				If aNFItem[nItem][IT_TS][TS_AGREG] <> "F"
					If aNFItem[nItem][IT_TS][TS_TPIPI] == "B" .Or. ( aSX6[MV_IPIBRUT] == "S" .And. aNFItem[nItem][IT_TS][TS_TPIPI] == " " )
						aNfItem[nItem][IT_BASEIPI] += IIf(cRefSDesc == "1",0,(aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT] + aNfItem[nItem][IT_DESCZF]))
						IF (aNFCab[NF_OPERNF] == "S" .And. aNfCab[NF_OPIRRF] == "EP" .And. cRefSDesc <> "1") .Or. aNfCab[NF_ROTINA] == 'LOJA701' // Somente deduz quando emitido pelo LOJA ou Saida para Orgao Publico
							aNfItem[nItem][IT_BASEIPI] +=  IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR" , aNfItem[nItem][IT_DEDICM] , 0 )
						EndIf
					EndIf
				EndIf

				// Salva a base de IPI original e aplica a reducao.
				aNfItem[nItem][IT_BIPIORI]	:= NoRound(aNfItem[nItem][IT_BASEIPI],2)

				nReduzIPI := PerRedIPI(aNfItem,nItem)

				If nReduzIPI <> 0
					If lRndrne .Or. lSobra
						aNfItem[nItem][IT_BASEIPI] := Round(aNfItem[nItem][IT_BASEIPI] * nReduzIPI / 100 , 2 )
					Else
						aNfItem[nItem][IT_BASEIPI] := NoRound(aNfItem[nItem][IT_BASEIPI] * nReduzIPI / 100 , 2 )
					EndIf

					aNfItem[nItem][IT_PREDIPI] := nReduzIPI
				EndIf

				If aNFItem[nItem][IT_TS][TS_IPI] == "R"
					If aNFItem[nItem][IT_TS][TS_IPIPECR] > 0
						aNfItem[nItem][IT_BASEIPI] := aNfItem[nItem][IT_BASEIPI] * aNFItem[nItem][IT_TS][TS_IPIPECR] / 100
					Else
						aNfItem[nItem][IT_BASEIPI] := aNfItem[nItem][IT_BASEIPI] / 2
					Endif
				EndIf
			EndIf

			If aPE[PE_MACALCIPI] .And. aMaCalcIPI[1]=="S" .And. !Empty(aMaCalcIPI[3])
				aNfItem[nItem][IT_BASEIPI]:= aMaCalcIPI[3]
			EndIf
		Else
			If !(aNFItem[nItem][IT_TS][TS_IPI] <> "N" .And. !aNFitem[nItem][IT_TIPONF ]$"IP")
				aNfItem[nItem][IT_BASEICM]	:= 0
				aNfItem[nItem][IT_BSFRETE]	:= 0
			EndIf
		EndIf

		If lNoProces
			aNfItem[nItem][IT_BASEIPI] := nSalvaBase
		EndIf

		// Rastro de Ativo para primeira saida, nao calcula IPI
		If aSX6[MV_RASTRO] == "S" .And. aSX6[MV_RSATIVO] .And. aNfCab[NF_OPERNF] == "S" .And. aNfItem[nItem][IT_PRD][SB_RSATIVO] == "1"
			aRastItem := RastroItem(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_LOTE],Iif(Empty(aNfItem[nItem][IT_SUBLOTE]),AllTrim(aNfItem[nItem][IT_SUBLOTE]),aNfItem[nItem][IT_SUBLOTE]))
			If Len(aRastItem) > 0
				If !aRastItem[1] .And. aRastItem[2] == 0
					aNfItem[nItem][IT_BASEIPI] := 0
				Else
					//TOTALIZA ITENS DO PEDIDO DE VENDA.
					aEval( aNfItem , {|x| nQuantPed += IIf(!x[IT_DELETED] .And. x[IT_PRODUTO] == aNfItem[nItem][IT_PRODUTO] .And. x[IT_LOTE] == aNfItem[nItem][IT_LOTE] .And. x[IT_SUBLOTE] == aNfItem[nItem][IT_SUBLOTE] , x[IT_QUANT] , 0 )} )

					If nQuantPed > aRastItem[2]
						//MENSAGEM PARA QUEBRA DOS ITENS.
						If  aRastItem[1] .And. aNfItem[nItem][IT_QUANT] > aRastItem[2] .And. lRastItem
							MsgInfo(STR0033+CRLF+;  //"Para controle correto da geração do IPI, será necessário quebrar em dois Itens:"
							STR0034+aNfItem[nItem][IT_ITEM]+; //Item:
							STR0035+aNfItem[nItem][IT_PRODUTO]+;// Produto:
							STR0036+aNfItem[nItem][IT_LOTE]+; // Lote:
							STR0037+aNfItem[nItem][IT_SUBLOTE]+CRLF+; // Sub-Lote:
							STR0038+Str(aRastItem[2])+CRLF+;//"1- Quantidade Tributada:"
							STR0039+Str(aNfItem[nItem][IT_QUANT]-aRastItem[2])+CRLF+;//"2- Quantidade Não Tributada:"
							STR0040,;//"Não houve alteração do calculo do IPI"
							STR0032) //"Quebra Item, Tributado x Não Tributado" 
							If ValType(lPlanRaAtv) <> "U"
								lPlanRaAtv := .F.
								lRastItem := .F.
							EndIf
						Else
							aNfItem[nItem][IT_BASEIPI] := 0
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		MaItArred(nItem,{"IT_BASEIPI"})
		
	EndIf 

	//Define ALIQUOTA DO IPI IT_ALIQIPI
	If "ALQ" $ cExecuta .And. !lDevolALQ

		aNFitem[nItem][IT_ALIQIPI] := 0
		aNFitem[nItem][IT_TIPONF ] := aNfCab[NF_TIPONF]

		If (aNFItem[nItem][IT_TS][TS_IPI] <> "N" .And. !aNFItem[nItem][IT_TIPONF] $ "PC") .Or. lRemFut 

			aNFitem[nItem][IT_ALIQIPI] := aNfItem[nItem][IT_PRD][SB_IPI]

			If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNFItem[nItem,IT_EXCECAO,17] <> 0 	// Verifica as Excecoes fiscais
				aNFitem[nItem][IT_ALIQIPI] := aNFItem[nItem,IT_EXCECAO,17]
			Endif

			If aPE[PE_MACALCIPI]
				If aMaCalcIPI[1] == "S" .And. !Empty(aMaCalcIPI[2])
					aNFitem[nItem][IT_ALIQIPI] := aMaCalcIPI[2]
				EndIf
			EndIf
		
		Else
			IF aNFCab[NF_CLIFOR] == "C"
				if !Empty(aNFItem[nItem][IT_RECORI])
					dbSelectArea("SD2")
					SD2->(MsGoto( aNFItem[nItem][IT_RECORI] ))
					aNFitem[nItem][IT_ALIQIPI]  := SD2->D2_IPI
				ENDIF
			ELSE 
				if !Empty(aNFItem[nItem][IT_RECORI])
					dbSelectArea("SD1")
					SD1->(MsGoto( aNFItem[nItem][IT_RECORI] ))
					aNFitem[nItem][IT_ALIQIPI] := SD1->D1_IPI
				endif

			ENDIF
		
        EndIF
	
	EndIf

	//Define VALOR do IPI    IT_VALIPI
	If "VLR" $ cExecuta .And. !lDevolVLR

		aNfItem[nItem][IT_VALIPI]  := 0
		aNfItem[nItem][IT_PAUTIPI] := 0

		If (aNFItem[nItem][IT_TS][TS_IPI] <> "N" .And. aNFitem[nItem][IT_TIPONF ] <> "I") .Or. lRemFut

			If aNFitem[nItem][IT_TIPONF ] == "P"
				If aNFItem[nItem][IT_TS][TS_AGREG] <> "F"
					aNfItem[nItem][IT_VALIPI] := aNfItem[nItem][IT_VALMERC]
				EndIf
			Else

				aNfItem[nItem][IT_VALIPI] := (aNfItem[nItem][IT_BASEIPI] * (aNfItem[nItem][IT_ALIQIPI] / 100))

				// Calculo do IPI de Pauta: Verifica SB1 ou SF7
				If (!Empty(aNfItem[nItem][IT_PRD][SB_VLR_IPI]) .Or. ( !Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][9] <> 0 ) )

					If !Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][9] <> 0

						aNFitem[nItem][IT_ALIQIPI] := IIF(!Empty(aNfItem[nItem][IT_EXCECAO][17]),aNfItem[nItem][IT_EXCECAO][17],aNfItem[nItem][IT_PRD][SB_IPI])

						nVlOprIPI	:= (aNfItem[nItem][IT_BASEIPI] * aNfItem[nItem][IT_ALIQIPI] / 100)
						nVlPautIPI	:= IIF(lSegUPau .And. aNfItem[nItem][IT_PRD][SB_CONV] > 0, ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem][IT_QUANT]) * aNfItem[nItem][IT_EXCECAO][9]

						If lIpiMin
							If nVlOprIPI < nVlPautIPI
								aNfItem[nItem][IT_VALIPI]  := nVlPautIPI
								aNfItem[nItem][IT_PAUTIPI] := aNfItem[nItem][IT_EXCECAO][9]
								aNFitem[nItem][IT_ALIQIPI] := 0
							Else
								aNfItem[nItem][IT_VALIPI]  := nVlOprIPI
								aNfItem[nItem][IT_PAUTIPI] := 0
							EndIf
						Else
							aNfItem[nItem][IT_VALIPI]  := nVlPautIPI
							aNfItem[nItem][IT_PAUTIPI] := aNfItem[nItem][IT_EXCECAO][9]
							aNFitem[nItem][IT_ALIQIPI] := 0
						EndIf
					Else

						aNFitem[nItem][IT_ALIQIPI] := IIF(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. !Empty(aNfItem[nItem][IT_EXCECAO][17]),aNfItem[nItem][IT_EXCECAO][17],aNfItem[nItem][IT_PRD][SB_IPI])

						nVlOprIPI	:= (aNfItem[nItem][IT_BASEIPI] * aNfItem[nItem][IT_ALIQIPI] / 100 )
						nVlPautIPI	:= IIF(lSegUPau .And. aNfItem[nItem][IT_PRD][SB_CONV] > 0, ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem][IT_QUANT]) * aNfItem[nItem][IT_PRD][SB_VLR_IPI]

						If lIpiMin
							If nVlOprIPI < nVlPautIPI
								aNfItem[nItem][IT_VALIPI]  := nVlPautIPI
								aNfItem[nItem][IT_PAUTIPI] := aNfItem[nItem][IT_PRD][SB_VLR_IPI]
								aNFitem[nItem][IT_ALIQIPI] := 0
							Else
								aNfItem[nItem][IT_VALIPI]  := nVlOprIPI
								aNfItem[nItem][IT_PAUTIPI] := 0
							EndIf
						Else
							aNfItem[nItem][IT_VALIPI]  := nVlPautIPI
							aNfItem[nItem][IT_PAUTIPI] := aNfItem[nItem][IT_PRD][SB_VLR_IPI]
							aNFitem[nItem][IT_ALIQIPI] := 0
						EndIf

					EndIf

					// Caso seja devolucao utiliza os valores da NF de origem
					DevIPI(aNFCab,aNfItem,nItem)

					If !Empty(aSX6[MV_IPIPFAT])
						aNfItem[nItem][IT_VALIPI] *= aNfItem[nItem][IT_PRD][SB_IPIPFAT]
					EndIf

				EndIf
			EndIf

			MaItArred(nItem,{"IT_VALIPI"})

		EndIf

		If cRefSDesc == "1"
			aNfItem[nItem][IT_VIPIORI] := aNfItem[nItem][IT_VALIPI]
		EndIf
	EndIf

	If lRemFut .And. aNfItem[nItem][IT_VALIPI] > 0
		aNfItem[nItem][IT_IPIVFCF] := aNfItem[nItem][IT_VALIPI]
		aNfItem[nItem][IT_VALIPI] :=0
		aNfItem[nItem][IT_BASEIPI]:=0
	EndIf

	// Restaurando aliquota e valor originais pois a base foi refeita
	// acima para efetuar uma correcao na base ocasionada por uma
	// implementacao incorreta.

	If lNoProces .And. !lTribGen
		aNfItem[nItem][IT_ALIQIPI] := nSalvaAliq
		aNfItem[nItem][IT_VALIPI] := nSalvaValor
	EndIf
	//Seguindo a ordem do enquadramento do IIF abaixo
	If  'CST' $ cExecuta
		If Empty(aNfItem[nItem][IT_PRD][SB_GRPCST])
			aNFItem[nItem][IT_TS][TS_GRPCST]:= aNfItem[nItem][IT_GRPCST]
		Else
			aNfItem[nItem][IT_PRD][SB_GRPCST]:= aNfItem[nItem][IT_GRPCST]
		EndIf
	EndIf

	//codigo de enquadramento do IPI
	aNfItem[nItem][IT_GRPCST]	:= IIf(!Empty(aNfItem[nItem][IT_PRD][SB_GRPCST]),aNfItem[nItem][IT_PRD][SB_GRPCST],aNFItem[nItem][IT_TS][TS_GRPCST])

	If aPE[PE_MAIPIVEIC] // ATENCAO!!! Ponto de entrada para uso exclusivo da TOTVS, nao sugerir o uso do mesmo a clientes - GDP FISCAL
		aMaIPIVeic := ExecBlock("MaIPIVeic",.F.,.F.,{nItem,aNfItem[nItem][IT_BASEIPI],aNfItem[nItem][IT_ALIQIPI],aNfItem[nItem][IT_VALIPI]})
		aNfItem[nItem][IT_BASEIPI] := aMaIPIVeic[1]
		aNfItem[nItem][IT_ALIQIPI] := aMaIPIVeic[2]
		aNfItem[nItem][IT_VALIPI]  := aMaIPIVeic[3]
	EndIf

Else

	

	If (nPosTrGIPI := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_IPI})) > 0 

			aNFItem[nItem][IT_TS][TS_IPI] := "S"			
			aNfItem[nItem][IT_BASEIPI] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_BASE]
			
			If aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_LF][TG_LF_PERC_REDUCAO] > 0
				aNfItem[nItem][IT_PREDIPI]	:= 100-aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_LF][TG_LF_PERC_REDUCAO]
			EndIf
			
			aNfItem[nItem][IT_ALIQIPI] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_ALIQUOTA]
			aNfItem[nItem][IT_VALIPI] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_VALOR]			

			
			
			IF aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_PAUTA]	
				aNfItem[nItem][IT_BASEIPI] := aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_BASE]		
				aNfItem[nItem][IT_VALIPI]  := aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_VALOR]
				aNfItem[nItem][IT_PAUTIPI] := aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_PAUTA]
				aNFitem[nItem][IT_ALIQIPI] := 0

				// Caso seja devolucao utiliza os valores da NF de origem
				//Quando processado dados pelo configurador pode ocorrer diferença de valores caso origem tenha TES TS_IPI = N
				DevIPI(aNFCab,aNfItem,nItem)
			EndIf			

		aNFItem[nItem][IT_TS][TS_CTIPI] := aNfItem[nItem][IT_TRIBGEN][nPosTrGIPI][TG_IT_REGRA_ESCR][RE_CST]
		aNFItem[nItem][IT_TS][TS_LFIPI] := RetLFLeg(aNfItem,nItem,nPosTrGIPI,TS_LFIPI)		

	EndIf

EndIf

Return

/*/
PerRedIPI - Rafael Oliveira - 29/07/2012
// Carrega a reducao da base do ICMS
*/
Function PerRedIPI(aNfItem,nItem)
Local nReduzIPI := 0
Local nPosTrG := 0

If (nPosTrG:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_IPI})) > 0
	If aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_PERC_REDUCAO] > 0
		nReduzIPI := 100-aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_PERC_REDUCAO]
		aNfItem[nItem][IT_PREDIPI] := nReduzIPI
	EndIf
Else

	// Carrega a reducao da base do ICMS
	If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,15] > 0
		nReduzIPI := aNfItem[nItem,IT_EXCECAO,15]
	Else
		nReduzIPI := aNFItem[nItem][IT_TS][TS_BASEIPI]
	EndIf

	aNfItem[nItem,IT_PREDIPI] := nReduzIPI
EndIf	

Return nReduzIPI

/*/{Protheus.doc} AltTribLeg
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Erich Buttner
    @since 24/11/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function IPIConvRf(aNfItem,nItem,ccampo)
 Local cCampoConv := ""

	IF cCampo == "IT_VALIPI"
		cCampoConv := "TG_IT_VALOR"		
	Elseif cCampo == "IT_BASEIPI"	
		cCampoConv := "TG_IT_BASE"				
	Elseif cCampo == "IT_ALIQIPI"
		cCampoConv := "TG_IT_ALIQUOTA"				
	Endif
	

Return cCampoConv


/*/{Protheus.doc} DevIPI
	(Caso seja devolucao utiliza os valores da NF de origem)
/*/
Static Function DevIPI(aNFCab,aNfItem,nItem)

// Caso seja devolucao utiliza os valores da NF de origem
If aNFCab[NF_TIPONF] $ "DB"
	If aNFCab[NF_CLIFOR] == "C"
		dbSelectArea("SD2")
		If !Empty(aNFItem[nItem][IT_RECORI])
			SD2->(MsGoto(aNFItem[nItem][IT_RECORI]) )
			If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
				aNfItem[nItem][IT_VALIPI]  := SD2->D2_VALIPI
				aNfItem[nItem][IT_ALIQIPI] := SD2->D2_IPI
				If aNfItem[nItem][IT_PAUTIPI] > 0
					aNfItem[nItem][IT_PAUTIPI] := SD2->D2_VALIPI / SD2->D2_QUANT
				EndIf
			ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
				If aNfItem[nItem][IT_PAUTIPI] > 0
					aNfItem[nItem][IT_PAUTIPI] := SD2->D2_VALIPI / SD2->D2_QUANT
					aNfItem[nItem][IT_VALIPI]  := aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIPI]
				Else
					aNfItem[nItem][IT_VALIPI]  := aNfItem[nItem][IT_QUANT] * (SD2->D2_VALIPI / SD2->D2_QUANT)//aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIPI]
				EndIf
			EndIf
		EndIf
	Else
		dbSelectArea("SD1")
		If !Empty(aNFItem[nItem][IT_RECORI])
			SD1->(MsGoto( aNFItem[nItem][IT_RECORI]) )
			If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
				aNfItem[nItem][IT_ALIQIPI] := SD1->D1_IPI
				aNfItem[nItem][IT_VALIPI]  := SD1->D1_VALIPI
				If aNfItem[nItem][IT_PAUTIPI] > 0
					aNfItem[nItem][IT_PAUTIPI] := SD1->D1_VALIPI / SD1->D1_QUANT
				EndIf
			ElseIf aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
				If aNfItem[nItem][IT_PAUTIPI] > 0
					aNfItem[nItem][IT_PAUTIPI] := SD1->D1_VALIPI / SD1->D1_QUANT
					aNfItem[nItem][IT_VALIPI]  := aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIPI]
				Else
					aNfItem[nItem][IT_VALIPI]  := aNfItem[nItem][IT_QUANT] * (SD1->D1_VALIPI / SD1->D1_QUANT) //aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIPI]
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return 

/*/{Protheus.doc} AltTribLeg
	(Função responsavel por verificar se o IPI item original tem Pauta configurada no produto ou na Exceção Fiscal na Devolução ou Beneficiamento)
	
	@author Yuri Gimenes
    @since 25/10/2021
    @version 12.1.27

	@param:	
	lSegUPau -> Parâmetro que define se a pauta será pela segunda unidade de Medida
	aNFItem  -> Array com dados cabeçalho da nota
	aNFItem  -> Array com dados item da nota
	nItem    -> Item que esta sendo processado	
	lPautIPI -> Variável que define se o IPI será pela pauta

/*/
Static Function PautIPI(lSegUPau,aNFCab,aNFItem,nItem,lPautIPI)

If aNFCab[NF_TIPONF] $ "DB"
	If (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][9] <> 0) .or. !Empty(aNfItem[nItem][IT_PRD][SB_VLR_IPI]) 
		If !Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][9] <> 0

			aNFitem[nItem][IT_ALIQIPI] := IIF(!Empty(aNfItem[nItem][IT_EXCECAO][17]),aNfItem[nItem][IT_EXCECAO][17],aNfItem[nItem][IT_PRD][SB_IPI])

			nVlOprIPI	:= (aNfItem[nItem][IT_BASEIPI] * aNfItem[nItem][IT_ALIQIPI] / 100)
			nVlPautIPI	:= IIF(lSegUPau .And. aNfItem[nItem][IT_PRD][SB_CONV] > 0, ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem][IT_QUANT]) * aNfItem[nItem][IT_EXCECAO][9]

			If nVlOprIPI < nVlPautIPI
				lPautIPI := .T.
			ENDIF
		else
			aNFitem[nItem][IT_ALIQIPI] := IIF(!Empty(aNFitem[nItem][IT_EXCECAO]) .And. !Empty(aNfItem[nItem][IT_EXCECAO][17]),aNfItem[nItem][IT_EXCECAO][17],aNfItem[nItem][IT_PRD][SB_IPI])

			nVlOprIPI	:= (aNfItem[nItem][IT_BASEIPI] * aNfItem[nItem][IT_ALIQIPI] / 100 )
			nVlPautIPI	:= IIF(lSegUPau .And. aNfItem[nItem][IT_PRD][SB_CONV] > 0, ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2),aNfItem[nItem][IT_QUANT]) * aNfItem[nItem][IT_PRD][SB_VLR_IPI]

			If nVlOprIPI < nVlPautIPI
				lPautIPI := .T.
			ENDIF
		EndIf
	EndIf
ENDIF

Return lPautIPI
