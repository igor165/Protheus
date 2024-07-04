#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxSest
    (Componentiza��o da fun��o MaFisSEST - 
    Calculo do Servi�o Social do Transporte (SEST))    
    
	@author Renato Rezende
    @since 17/02/2020
    @version 12.1.25
    
	@param:
	aNfCab -> Array com dados do cabe�alho da nota
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
//Caso haja tributo gen�rico com ID do SEST enquadrado as refer�ncias s�o zeradas para n�o duplicar o tributo
//Se n�o houver configura��o padr�o para c�lculo do tributo, as refer�ncias tamb�m devem ser zeradas.
If !(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_SEST)) .And. !Empty(aNfCab[NF_NATUREZA]) .And. aNfCab[NF_RECSEST]=="1" .And. aNFItem[nItem][IT_TS][TS_DUPLIC]=="S" .And. aPos[FP_ED_BASESES] .And. aPos[FP_ED_PERCSES]
	if "BSE" $ cExecuta
		aNfItem[nItem][IT_BASESES] := IIf( aInfNat[NT_BASESES] > 0,((aNfItem[nItem][IT_TOTAL]*aInfNat[NT_BASESES])/100) , aNfItem[nItem][IT_TOTAL] )
	EndIF
	//Al�quota recuperada do cadastro da natureza.
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
