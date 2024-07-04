#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXIMA
    (Componentização da função MaFisFFF - Calculo do IMA-MT)
    
    
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

Function FISXIMA(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
    
    Local nQtdUm   := 0

	aNfItem[nItem][IT_BASIMA]	:= 0
	aNfItem[nItem][IT_ALIIMA]	:= 0
	aNfItem[nItem][IT_VALIMA]	:= 0

    //IMA-MT
	If  (aPos[FP_B1_AIMAMT] .And. aPos[FP_A2_RIMAMT] .And. aPos[FP_A1_RIMAMT] .And. aPos[FP_F4_CIMAMT]) .AND. ;
		!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_IMAMT))

		If aNfItem[nItem][IT_AIMAMT] > 0 .And. aNFItem[nItem][IT_TS][TS_CIMAMT] == "1"

			If Alltrim(cPrUm) $ "TL|TN|TON" 
				nQtdUm := aNfItem[nItem][IT_QUANT]
			ElseIf Alltrim(cSgUm) $ "TL|TN|TON"
				nQtdUm := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
			EndIf
			
			If nQtdUm > 0 
				aNfItem[nItem][IT_BASIMA]	:= aNfCab[NF_INDUFP]  * aNfItem[nItem][IT_AIMAMT] /100
				aNfItem[nItem][IT_ALIIMA]	:= aNfItem[nItem][IT_AIMAMT]
				aNfItem[nItem][IT_VALIMA]	:= Round(aNfItem[nItem][IT_BASIMA] * nQtdUm,2)			
			EndIf
			
			IF aNfCab[NF_RECIMA] == "1"
				aNfItem[nItem][IT_VLIMAR]	:= aNfItem[nItem][IT_VALIMA]
			EndIF
		EndIf
	EndIf

Return

