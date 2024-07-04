#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxSest
    (Componentização da função MaFisSEST - 
    Calculo do Serviço Social do Transporte (SEST))    
    
	@author Renato Rezende
    @since 17/02/2020
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
	cExecuta-> Define o que deve ser (re)processado - VLR, BSE ou Ambos
    /*/
Function FISxSest(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta)
Default cExecuta := "BSE|VLR"
//Caso haja tributo genérico com ID do SEST enquadrado as referências são zeradas para não duplicar o tributo
//Se não houver configuração padrão para cálculo do tributo, as referências também devem ser zeradas.
If !(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_SEST)) .And. !Empty(aNfCab[NF_NATUREZA]) .And. aNfCab[NF_RECSEST]=="1" .And. aNFItem[nItem][IT_TS][TS_DUPLIC]=="S" .And. aPos[FP_ED_BASESES] .And. aPos[FP_ED_PERCSES]
	if "BSE" $ cExecuta
		aNfItem[nItem][IT_BASESES] := IIf( aInfNat[NT_BASESES] > 0,((aNfItem[nItem][IT_TOTAL]*aInfNat[NT_BASESES])/100) , aNfItem[nItem][IT_TOTAL] )
	EndIF
	//Alíquota recuperada do cadastro da natureza.
	aNfItem[nItem][IT_ALIQSES] := aInfNat[NT_PERCSES]

	If "VLR" $ cExecuta
		aNfItem[nItem][IT_VALSES]  := aNfItem[nItem][IT_BASESES]*(aNfItem[nItem][IT_ALIQSES]/100)
	EndIf	
	MaItArred(nItem,{"IT_VALSES"})
else
	aNfItem[nItem][IT_BASESES] := 0
	aNfItem[nItem][IT_ALIQSES] := 0
	aNfItem[nItem][IT_VALSES]  := 0
EndIf

Return
