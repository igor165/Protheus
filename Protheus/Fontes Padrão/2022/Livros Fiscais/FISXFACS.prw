#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFACS
    (Componentização da função MaFisFFF - Calculo do FACS)
    
    
	@author Rafael.soliveira
    @since 22/01/2020
    @version 12.1.25
    
	@param:
	aNfCab -> Array com dados do cabeçalho da nota
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado
	aPos   -> Array com dados de FieldPos de campos
	aInfNat	-> Array com dados da narutureza
	aPE		-> Array com dados dos pontos de entrada
	aSX6	-> Array com dados Parametros
	aDic	-> Array com dados Aliasindic
	aFunc	-> Array com dados Findfunction
	cPrUm	-> Primeira unidade de medida
	cSgUm	-> Segunda unidade de medida
    /*/
Function FISXFACS(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
    
    Local nQtdUm   := 0

	aNfItem[nItem][IT_BASEFAC] := 0
	aNfItem[nItem][IT_ALIQFAC] := 0
	aNfItem[nItem][IT_VALFAC]  := 0

    //FACS  - BASE / ALIQUOTA e VALOR
	If  (aPos[FP_B1_AFACS] .And. aPos[FP_A2_RFACS] .And. aPos[FP_A1_RFACS] .And. aPos[FP_F4_CFACS] ) .AND. ;
		!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FACS))

		If aNfItem[nItem][IT_AFACS] > 0 .And. aNFItem[nItem][IT_TS][TS_CALCFAC] == "1"

			// E obrigatorio que a primeira ou a segunda unidade de medida seja "TL"
			If Alltrim(cPrUm) $ "TL|TON|TN" 
				nQtdUm := aNfItem[nItem][IT_QUANT]
			ElseIf Alltrim(cSgUm) $ "TL|TON|TN"
				nQtdUm := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
			EndIf
			
			If nQtdUm > 0 
				aNfItem[nItem][IT_BASEFAC] := Round((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFACS] /100),2)
				aNfItem[nItem][IT_ALIQFAC] := aNfItem[nItem][IT_AFACS]
				aNfItem[nItem][IT_VALFAC]  := Round(((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFACS] /100) * nQtdUm),2)
			Endif
			
		EndIf
	EndIf

Return

