#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFABOV
    (Componentização da função MaFisFFF - Calculo do FABOV)
    
    
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
Function FISXFABOV(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
  
	Local nQtdUm	:= 0

	aNfItem[nItem][IT_BASEFAB] := 0
	aNfItem[nItem][IT_ALIQFAB] := 0
	aNfItem[nItem][IT_VALFAB]  := 0

    //FABOV - BASE / ALIQUOTA e VALOR
	If (aPos[FP_B1_AFABOV] .And. aPos[FP_A2_RFABOV] .And. aPos[FP_A1_RFABOV] .And. aPos[FP_F4_CFABOV] ) .And. ;
		!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FABOV))

		If aNfItem[nItem][IT_AFABOV] > 0 .And. aNFItem[nItem][IT_TS][TS_CALCFAB] == "1"            

			// E obrigatorio que a primeira ou a segunda unidade de medida seja "UN"
			If Alltrim(cPrUm) == "UN" 
				nQtdUm := aNfItem[nItem][IT_QUANT]
			ElseIf Alltrim(cSgUm) == "UN"
				nQtdUm:= ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
			EndIf

			If nQtdUm > 0
				aNfItem[nItem][IT_BASEFAB] := Round((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFABOV] /100),2)
				aNfItem[nItem][IT_ALIQFAB] := aNfItem[nItem][IT_AFABOV]
				aNfItem[nItem][IT_VALFAB]  := Round(((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFABOV] /100) * nQtdUm),2)
			EndIf			
		EndIf
	EndIf
Return

