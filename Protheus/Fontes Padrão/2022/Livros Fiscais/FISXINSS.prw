#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxInss
    (Componentização da função MaFisInss - 
    Calculo de Instituto Nacional do Seguro Social (INSS))    
    
	@author Renato Rezende
    @since 03/04/2020
    @version 12.1.27
    
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
    cExecuta    -> String vinda da pilha do MATXFIS
    lINSSSemDu  -> Variável static do MATXFIS
    lLimInss    -> Variável static do MATXFIS
/*/
Function FISxInss(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta, lINSSSemDu, lLimInss, cAliasPROD)

Local nInssAcum  := 0
Local nValMaxIns := 0
Local nI		 := 0
Local nCont      := 0
Local nTotInss	 := 0
Local nValInss	 := 0
Local nInssAnt	 := 0
Local aAliqCPEsp := {}
Local cAliqCPEsp := aSX6[MV_ALCPESP]
Local nQtdAliq   := 0
Local nBCFun     := 0
Local cFunrural := aSX6[MV_FUNRURA]
Local cFunName := AllTrim(FunName())
Local lTribGenIN:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_INSS)
Local lTribGen15:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_SECP15)
Local lTribGen20:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_SECP20)
Local lTribGen25:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_SECP25)
Local lTribGen	:= lTribGenIN .Or. lTribGen15 .Or. lTribGen20 .Or. lTribGen25
//Local aTipoRur	:= {}

DEFAULT cExecuta := "BSE|ALQ|VLR|RED"

If !lTribGen
	If "RED" $ cExecuta

		aNfItem[nItem][IT_REDINSS] := aNfItem[nItem][IT_PRD][SB_REDINSS]
		//O parametro MV_CTRAUTO define se para notas fiscais de complemento de frete deve ser considerado as informacoes de IRRF e INSS
		//(calculo e reducao) da natureza financeira ou do cadastro de produtos. .T. = Natureza  .F. = Produto  (DEFAULT .F.)
		If Empty(aNfItem[nItem][IT_REDINSS]) .Or. ( aSX6[MV_CTRAUTO] .And. aNfCab[NF_TIPONF]=="C" .And. aNfCab[NF_TPCOMP] == "F" )
			If !Empty(aNfCab[NF_NATUREZA])
				aNfItem[nItem][IT_REDINSS] := aInfNat[NT_BASEINS]
			EndIf
		EndIf

	EndIf

	If "ALQ" $ cExecuta

		aNfItem[nItem][IT_ALCP15] := 0
		aNfItem[nItem][IT_ALCP20] := 0
		aNfItem[nItem][IT_ALCP25] := 0

		aNfItem[nItem][IT_ALIQINS] := IIf( !Empty(aNfCab[NF_NATUREZA]) , aInfNat[NT_PERCINS] , 0 )
		// Manteremos duas formas de calcular o INSS especial, pode ser considerado que o valor total do item
		// se refere a aposentadoria especial, nesse caso ele pode configurar a alíquota adicional via campo definido no
		// parâmetro MV_ALINSB1.
		// A outra forma seria considerar que em apenas 1 item ele tem valor de aposentadoria especial, mas não com a mesma alíquota.
		// Exemplo: valor do item: 100,00 valor especial a 15 anos: 40,00 e valor especial a 20 anos: 30,00

		If	aNfItem[nItem][IT_SECP15]	>	0	.or.  ;
			aNfItem[nItem][IT_SECP20]	>	0	.or.  ;
			aNfItem[nItem][IT_SECP25]	>	0

			If !Empty(cAliqCPEsp)

				aAliqCPEsp := StrTokArr(cAliqCPEsp,'|')

				nQtdAliq  := 03
				For nCont := 01 To nQtdAliq

					If !Empty(aAliqCPEsp[nCont])
						aAliqCPEsp[nCont] := Val(aAliqCPEsp[nCont])
					Else
						aAliqCPEsp[nCont] := 0
					EndIf
				Next nCont

			Else

				aAliqCPEsp := {0,0,0}

			EndIf

			aNfItem[nItem][IT_ALCP15] := aAliqCPEsp[01]
			aNfItem[nItem][IT_ALCP20] := aAliqCPEsp[02]
			aNfItem[nItem][IT_ALCP25] := aAliqCPEsp[03]

		Else

			If !Empty(aSX6[MV_ALINSB1])
				dbSelectArea(cAliasPROD)
				If &(aSX6[MV_ALINSB1]) > 0

					If &(aSX6[MV_TPAPSB1]) 		== '1'
						aNfItem[nItem][IT_ALCP15] := &(aSX6[MV_ALINSB1])
					ElseIf &(aSX6[MV_TPAPSB1]) 	== '2'
						aNfItem[nItem][IT_ALCP20] := &(aSX6[MV_ALINSB1])
					ElseIf &(aSX6[MV_TPAPSB1]) 	== '3'
						aNfItem[nItem][IT_ALCP25] := &(aSX6[MV_ALINSB1])
					EndIf

				EndIf

					aNfItem[nItem][IT_ALIQINA]	:=	aNfItem[nItem][IT_ALIQINS] + &(aSX6[MV_ALINSB1])

			EndIf

		EndIf
	EndIf

	If "BSE" $ cExecuta

		aNfItem[nItem][IT_BASEINS] := 0
		nBCFun     := MaFisBCFun(nItem)

		If aNfItem[nItem][IT_PRD][SB_INSS] == "S" .Or. ( aSX6[MV_CTRAUTO] .And. aNfCab[NF_TIPONF] == "C" .And. aNfCab[NF_TPCOMP] == "F" .And. !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCINS] == "S" ) 
			If aNfItem[nItem][IT_PRD][SB_INSS] == "S" .And. ((aNFItem[nItem][IT_TS][TS_DUPLIC] == "S"  .And.  !Empty(aNfCab[NF_NATUREZA]) .and.  aInfNat[NT_CALCINS] == "S"  ) .Or. lINSSSemDu .Or. aNFItem[nItem][IT_TS][TS_CINSS]=="1") 

				If aNfCab[NF_RECINSS] == "S" .Or.;
					(aNfCab[NF_RECINSS]=="N" .And. aNFCab[NF_OPERNF]=="S" .And. aInfNat[NT_DEDINSS] == "2")

					If aNfItem[nItem][IT_ALIQINS] > 0
						If  nBCFun > 0 .And. cFunrural == '1'
							aNfItem[nItem][IT_BASEINS] := nBCFun  //bruce
						Else
							aNfItem[nItem][IT_BASEINS] := (aNfItem[nItem][IT_TOTAL] + ;
							IIf( aNFItem[nItem][IT_TS][TS_AGREG] $ "D", aNfItem[nItem][IT_DEDICM] , 0 ) + ;
							IIf( aSX6[MV_INSSDES]	==	"1", aNfItem[nItem,IT_DESCONTO], 0 ) ) * ;
							IIf(aNfItem[nItem][IT_REDINSS] > 0 , aNfItem[nItem][IT_REDINSS]/100 , 1 )
						EndIF
						If (cFunName $ "MATA410|MATA103|OFIXA018|OFIXA011|OFIXA100") .And. aNfItem[nItem][IT_BASEINS] >= aNfItem[nItem,IT_ABVLINSS]
						aNfItem[nItem][IT_BASEINS] -= aNfItem[nItem,IT_ABVLINSS] // Abatimento da base de calculo do INSS
						ElseIf cFunName $ "MATA461|MATA460A" 
							aNfItem[nItem][IT_BASEINS] -=  ((aNfItem[nItem][IT_QUANT] * SC6->C6_ABATINS) / SC6->C6_QTDVEN)
						Endif

						MaItArred(nItem, {"IT_BASEINS"})

						If aNfItem[nItem][IT_BASEINS] >0
							If	aNfItem[nItem][IT_SECP15]	>	0	.or.  ;
								aNfItem[nItem][IT_SECP20]	>	0	.or.  ;
								aNfItem[nItem][IT_SECP25]	>	0

							aNfItem[nItem][IT_BSCP15] := aNfItem[nItem][IT_SECP15]
							aNfItem[nItem][IT_BSCP20] := aNfItem[nItem][IT_SECP20]
							aNfItem[nItem][IT_BSCP25] := aNfItem[nItem][IT_SECP25]

							Else
								If !Empty(aSX6[MV_ALINSB1])
									dbSelectArea(cAliasPROD)
									If &(aSX6[MV_ALINSB1]) > 0
										If &(aSX6[MV_TPAPSB1]) == '1'
											aNfItem[nItem][IT_BSCP15] := aNfItem[nItem][IT_BASEINS]
										ElseIf &(aSX6[MV_TPAPSB1]) == '2'
											aNfItem[nItem][IT_BSCP20] := aNfItem[nItem][IT_BASEINS]
										ElseIf &(aSX6[MV_TPAPSB1]) == '3'
											aNfItem[nItem][IT_BSCP25] := aNfItem[nItem][IT_BASEINS]
										EndIf
										aNfItem[nItem][IT_BASEINA]    := aNfItem[nItem][IT_BASEINS]
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf

	If "VLR" $ cExecuta


				aNfItem[nItem][IT_VLCP15] := aNfItem[nItem][IT_BSCP15] * aNfItem[nItem][IT_ALCP15] /100
				aNfItem[nItem][IT_VLCP20] := aNfItem[nItem][IT_BSCP20] * aNfItem[nItem][IT_ALCP20] /100
				aNfItem[nItem][IT_VLCP25] := aNfItem[nItem][IT_BSCP25] * aNfItem[nItem][IT_ALCP25] /100

				aNfItem[nItem][IT_VALINS] := aNfItem[nItem][IT_BASEINS] * aNfItem[nItem][IT_ALIQINS] /100
				aNfItem[nItem][IT_VALINS] += aNfItem[nItem][IT_VLCP15] + aNfItem[nItem][IT_VLCP20] + aNfItem[nItem][IT_VLCP25]

		If aSX6[MV_LIMINSS] > 0 .and. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] == "F" .And. Len(AllTrim(aNFCab[NF_CNPJ])) < 14 .And. Len(AllTrim(aNFCab[NF_CNPJ])) > 1 .and. Empty(aNFCab[NF_TIPORUR])

			aNfItem[nItem][IT_ACINSS] := 0

			nTotInss := 0
			nInssAnt := 0

			For nI := 1 to nItem
				If aNfItem[nItem][IT_ACINSS] == 0
					aNfItem[nItem][IT_ACINSS] := aNfItem[nItem][IT_VALINS]
				EndIf
				If !aNfItem[nI][IT_DELETED]
					nTotInss += aNfItem[nI][IT_ACINSS]
					If nItem <> nI
						nInssAnt += aNfItem[nI][IT_ACINSS]
					Endif
				Endif
			Next nI

			nInssAcum  	:= VerInssAcm(aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_NREDUZ],dDataBase,dDataBase,.T.)
			nValMaxIns 	:= ( aSX6[MV_LIMINSS] - nInssAcum )
			nValInss    := ( nValMaxIns - nInssAnt )

			Do Case
				Case nValMaxIns <= 0
					aNfItem[nItem][IT_VALINS] := 0
					lLimInss := .T.
				Case ( nValMaxIns < nTotInss )
					aNfItem[nItem][IT_VALINS] := Iif( nValInss < 0 , 0 , nValInss )
					lLimInss := .T.
			EndCase

			If lLimInss .AND. Type("aHeader") == "A" .AND. Type("aCols") == "A"
				MaFisToCols(aHeader,aCols,,"MT100")
			Endif
		Endif

		// Abatimento da valor do INSS em valor - Subcontratada
		//Faturamento
		If aNfItem[nItem][IT_ABSCINS] > 0
			aNfItem[nItem][IT_VALINS] := Max(0, aNfItem[nItem][IT_VALINS] -= aNfItem[nItem][IT_ABSCINS])
		Endif
		//Movimento de entrada
		If aNfItem[nItem][IT_VALINS] >= aNfItem[nItem][IT_AVLINSS] .And. aNfItem[nItem][IT_AVLINSS] > 0
			aNfItem[nItem][IT_VALINS] -= aNfItem[nItem][IT_AVLINSS]
		Endif

	EndIf

Else
	//Atualiza as referências do legado com os valores do configurador
	AtuLegINSS(aNfItem, nItem)

EndIf

Return


/*/
MaFisINSP - Diego Dias - 06/08/2016
Calcula o INSS Patronal.
/*/
Function FISINSSPAT(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta)
Local lTribGen 	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_INSSPT)
Local nPosTgINPT:= 0

DEFAULT cExecuta  := "BSE|ALQ|VLR"

If !lTribGen
	If "BSE" $ cExecuta

		aNfItem[nItem][IT_BASEINP]	:=	0

		If	aNFItem[nItem][IT_TS][TS_DUPLIC] == "S" .And. !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCINP] == "1" .And. ;
			aInfNat[NT_PERCINP] > 0 .And. aNfCab[NF_CALCINP] == "1" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] == "F" .And. ;
			( (Len(AllTrim(aNFCab[NF_CNPJ])) < 14 .And. Len(AllTrim(aNFCab[NF_CNPJ])) > 1) .Or. aNfCab[NF_TPJFOR] == '3' ) //O Inss Patronal será calculado para pessoa física ou MEI.

			aNfItem[nItem][IT_BASEINP]	:= aNfItem[nItem][IT_VALMERC]

			If aNfItem[nItem][IT_REDINSS] > 0
				aNfItem[nItem][IT_BASEINP] := (aNfItem[nItem][IT_BASEINP] * (aNfItem[nItem][IT_REDINSS] / 100))
			EndIf
		EndIf

	EndIF

	If "ALQ" $ cExecuta
		aNfItem[nItem][IT_PERCINP]	:=	0
		aNfItem[nItem][IT_PERCINP]	:= aInfNat[NT_PERCINP]
	EndIF

	If "VLR" $ cExecuta
		aNfItem[nItem][IT_VALINP]	:=	0
		aNfItem[nItem][IT_VALINP]	:= aNfItem[nItem][IT_BASEINP] * aInfNat[NT_PERCINP] /100
	EndIF
Else

    IF (nPosTgINPT := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_INSSPT})) >0  
    
        aNfItem[nItem][IT_VALINP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgINPT][TG_IT_VALOR]
        aNfItem[nItem][IT_BASEINP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgINPT][TG_IT_BASE]
        aNfItem[nItem][IT_PERCINP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgINPT][TG_IT_ALIQUOTA]

    Endif
EndIf

Return

/*/{Protheus.doc} INSSConvRf
(Função responsavel por converter alteração de referencia legado em referencia do configurador)

@author Renato Rezende
@since 02/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
ccampo -> Campo que esta sendo alterado	
nExecuta -> Referência que está sendo verificada
/*/
Function INSSConvRf(aNfItem,nItem,ccampo, nExecuta)
Local cCampoConv 	:= ""
Local cCtrRefBas	:= ""
Local cCtrRefVal	:= ""
Local cCtrRefAlq	:= ""

If nExecuta == 1
	cCtrRefBas	:= "IT_BASEINS"
	cCtrRefVal	:= "IT_VALINS"
	cCtrRefAlq	:= "IT_ALIQINS"
ElseIf nExecuta == 2
	cCtrRefBas	:= "IT_BASEINP"
	cCtrRefVal	:= "IT_VALINP"
	cCtrRefAlq	:= "IT_PERCINP"
ElseIf nExecuta == 3
	cCtrRefBas	:= "IT_BSCP15|IT_SECP15"
	cCtrRefVal	:= "IT_VLCP15"
	cCtrRefAlq	:= "IT_ALCP15"
ElseIf nExecuta == 4
	cCtrRefBas	:= "IT_BSCP20|IT_SECP20"
	cCtrRefVal	:= "IT_VLCP20"
	cCtrRefAlq	:= "IT_ALCP20"
ElseIf nExecuta == 5
	cCtrRefBas	:= "IT_BSCP25|IT_SECP25"
	cCtrRefVal	:= "IT_VLCP25"
	cCtrRefAlq	:= "IT_ALCP25"
EndIf

IF cCampo $ cCtrRefVal
    cCampoConv := "TG_IT_VALOR"
Elseif cCampo $ cCtrRefBas
    cCampoConv := "TG_IT_BASE"
Elseif cCampo $ cCtrRefAlq
    cCampoConv := "TG_IT_ALIQUOTA"
Endif

Return cCampoConv

/*/{Protheus.doc} AtuLegINSS
(Função responsavel por preencher as referencia legado com os valores das referencia do configurador)

@author Renato Rezende
@since 03/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
/*/
Static Function AtuLegINSS(aNfItem,nItem)
Local nPosTgINSS:= 0
Local nPosTgIN15:= 0
Local nPosTgIN20:= 0
Local nPosTgIN25:= 0

If (nPosTgINSS := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_INSS})) >0  

	aNfItem[nItem][IT_VALINS]:= aNfItem[nItem][IT_TRIBGEN][nPosTgINSS][TG_IT_VALOR]
	aNfItem[nItem][IT_BASEINS]:= aNfItem[nItem][IT_TRIBGEN][nPosTgINSS][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQINS]:= aNfItem[nItem][IT_TRIBGEN][nPosTgINSS][TG_IT_ALIQUOTA]

Endif

If (nPosTgIN15 := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_SECP15})) >0  

	aNfItem[nItem][IT_VLCP15]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN15][TG_IT_VALOR]
	aNfItem[nItem][IT_BSCP15]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN15][TG_IT_BASE]
	aNfItem[nItem][IT_SECP15]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN15][TG_IT_BASE]
	aNfItem[nItem][IT_ALCP15]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN15][TG_IT_ALIQUOTA]

Endif

If (nPosTgIN20 := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_SECP20})) >0  

	aNfItem[nItem][IT_VLCP20]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN20][TG_IT_VALOR]
	aNfItem[nItem][IT_BSCP20]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN20][TG_IT_BASE]
	aNfItem[nItem][IT_SECP20]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN20][TG_IT_BASE]
	aNfItem[nItem][IT_ALCP20]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN20][TG_IT_ALIQUOTA]

Endif

If (nPosTgIN25 := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_SECP25})) >0

	aNfItem[nItem][IT_VLCP25]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN25][TG_IT_VALOR]
	aNfItem[nItem][IT_BSCP25]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN25][TG_IT_BASE]
	aNfItem[nItem][IT_SECP25]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN25][TG_IT_BASE]
	aNfItem[nItem][IT_ALCP25]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIN25][TG_IT_ALIQUOTA]

Endif

Return 
