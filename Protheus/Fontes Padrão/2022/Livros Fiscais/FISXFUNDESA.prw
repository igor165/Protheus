#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFUNDESA
    (Componentização da função MaFisFFF - Calculo do FUNDESA-RS)
    
    
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
    /*/
Function FISXFUNDESA(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)    

    aNfItem[nItem][IT_BASFUND]  := 0
    aNfItem[nItem][IT_ALIFUND]	:= 0
    aNfItem[nItem][IT_VALFUND]	:= 0    

    //FUNDESA-RS
	If (aPos[FP_B1_AFUNDES] .And. aPos[FP_F4_CFUNDES]) .And. ;
		!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FUNDESA))

        If aNfItem[nItem][IT_PRD][SB_AFUNDES] > 0 .And. aNFItem[nItem][IT_TS][TS_CFUNDES] == "1"
            aNfItem[nItem][IT_BASFUND] := aNfCab[NF_INDUFP] * aNfItem[nItem][IT_PRD][SB_AFUNDES]
            aNfItem[nItem][IT_ALIFUND] := aNfItem[nItem][IT_PRD][SB_AFUNDES]
            aNfItem[nItem][IT_VALFUND] := aNfItem[nItem][IT_BASFUND] * aNfItem[nItem][IT_QUANT]
        EndIf
    EndIf

Return