#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FIsXTPDP
    (Componentização da função MaFisTPDP - 
    TPDP - Paraiba Taxa de Processamento de Despesas Publicas
    
	@author Rafael.soliveira
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
    /*/
Function FISXTPDP(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
    aNfItem[nItem][IT_BASTPDP]	:= 0
    aNfItem[nItem][IT_ALITPDP]	:= 0
    aNfItem[nItem][IT_VALTPDP]	:= 0

    //Verifica se algum tributo genérico com ID do TPDP enquadrado, e zera referências para não calcular em duplicidade
    If !(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_TPDP))

        If aPos[FP_A1_TPDP] .And. aPos[FP_B1_TPDP] .And. aNfCab[NF_OPERNF] == "S" .And. SA1->A1_TPDP == "1" .And. ;
            aNfItem[nItem][IT_PRD][SB_TPDP] == "1" .And. aNfCab[NF_UFDEST]=="PB" .And. aNFItem[nItem][IT_TS][TS_DUPLIC] == "S" .And. aNfItem[nItem][IT_VALMERC] > 0

            aNfItem[nItem][IT_BASTPDP]	:= aNfItem[nItem][IT_VALMERC]
            aNfItem[nItem][IT_ALITPDP]	:= aSX6[MV_ALITPDP]

            If ( aNfItem[nItem][IT_BASTPDP] * ( aSX6[MV_ALITPDP] / 100 ) ) >= 30000
                aNfItem[nItem][IT_VALTPDP]	:= 30000
            Else
                aNfItem[nItem][IT_VALTPDP] := ( aNfItem[nItem][IT_BASTPDP] * ( aSX6[MV_ALITPDP] / 100 ) )
            Endif
            MaItArred(nItem,{"IT_VALTPDP"})
        EndIf

    EndIF
Return