#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFASE
    (Componentização da função MaFisFFF - Calculo do FASE-MT)
    
    
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
Function FISXFASE(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
    
    Local nQtdUm   := 0
    
	aNfItem[nItem][IT_BASFASE]  := 0
	aNfItem[nItem][IT_ALIFASE]	:= 0
	aNfItem[nItem][IT_VALFASE]	:= 0   

    //FASE-MT
	If  (aPos[FP_B1_AFASEMT] .And. aPos[FP_A2_RFASEMT] .And. aPos[FP_A1_RFASEMT] .And. aPos[FP_F4_CFASE]) .AND. ;
		!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FASEMT))

		If aNfItem[nItem][IT_AFASEMT] > 0 .And. aNFItem[nItem][IT_TS][TS_CFASE] == "1"

			// E obrigatorio que a primeira ou a segunda unidade de medida seja "KG"
			If Alltrim(cPrUm) $ "KG" 
				nQtdUm := aNfItem[nItem][IT_QUANT]
			ElseIf Alltrim(cSgUm) $ "KG"
				nQtdUm := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
			EndIf
			
			If nQtdUm > 0 
				aNfItem[nItem][IT_BASFASE]	:= Round((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFASEMT] /100),2)
				aNfItem[nItem][IT_ALIFASE]	:= aNfItem[nItem][IT_AFASEMT]
				aNfItem[nItem][IT_VALFASE]	:= Round(aNfItem[nItem][IT_BASFASE] * nQtdUm,2)			
			EndIf
			
			IF aNfCab[NF_RECFASE] == "1"
				aNfItem[nItem][IT_VLFASER]	:= aNfItem[nItem][IT_VALFASE]
			EndIF
		EndIf
	EndIf

Return

