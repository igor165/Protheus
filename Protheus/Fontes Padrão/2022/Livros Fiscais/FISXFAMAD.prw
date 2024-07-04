#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FAMAD
    (Componentização da função MaFisFFF - Calculo do FAMAD)    
    
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
Function FISXFAMAD(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)

    Local nQtdUm   := 0    

	aNfItem[nItem][IT_BASEFMD] := 0	
	aNfItem[nItem][IT_VALFMD]  := 0

    //FAMAD - BASE / ALIQUOTA e VALOR
	If (aPos[FP_AFAMAD] .And. aPos[FP_A2_RECFMD] .And. aPos[FP_A1_RECFMD] .And. aPos[FP_CFAMAD] ) .And. ;
		!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FAMAD))

		If aNfItem[nItem][IT_ALQFMD] > 0 .And. aNFItem[nItem][IT_TS][TS_CFAMAD] == "1"

			// E obrigatorio que a primeira ou a segunda unidade de medida seja "M3"
			If Alltrim(cPrUm) $ "M3" 
				nQtdUm := aNfItem[nItem][IT_QUANT]
			ElseIf Alltrim(cSgUm) $ "M3"
				nQtdUm := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
			EndIf

			If nQtdUm > 0 
				aNfItem[nItem][IT_BASEFMD] := Round((aNfCab[NF_INDUFP]  * aNfItem[nItem][IT_ALQFMD] /100),2)
				aNfItem[nItem][IT_ALQFMD]  := aNfItem[nItem][IT_ALQFMD]
				aNfItem[nItem][IT_VALFMD]  := Round(((aNfCab[NF_INDUFP]  * aNfItem[nItem][IT_ALQFMD] /100) * nQtdUm),2)
			Endif
		EndIf
	EndIf

Return

