#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxFndSul
    (Componentização da função MaFisVSul - 
    Calculo do Fundo de Desenvolvimento do Sistema Rodoviário de Mato Grosso do Sul (Fundersul))    
    
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
Function FISxFndSul(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)

Local nUferms := 0

    aNfItem[nItem][IT_VALFDS]  := 0
    aNfItem[nItem][IT_PRFDSUL] := 0
    aNfItem[nItem][IT_UFERMS]  := 0

    //Verifica se algum tributo genérico com ID do Fundersul com enquadrado, e zera referências para não calcular em duplicidade
    If !(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FUNDERSUL))    
        If aNfItem[nItem][IT_PRD][SB_PRFDSUL] > 0 .And. (aNFItem[nItem][IT_TS][TS_DUPLIC] == "S" .Or. (aSX6[MV_EASY] == "S" .And. aNFItem[nItem][IT_TS][TS_AGREG]$"BC")) .And.;
            aNFItem[nItem][IT_TS][TS_CLFDSUL] == "1" .And. (SubStr(aNfItem[nItem][IT_CF],1,1) $ "13" .Or. ;
            (SubStr(aNfItem[nItem][IT_CF],1,1)$"56")) //.And. aNFitem[nItem][IT_TIPONF] == "D"))

            If SM2->(FieldPos("M2_MOEDA"+Alltrim(aSX6[MV_UFERMS]))) > 0
                SM2->(dbSetOrder(1))
                If SM2->(MsSeek(dDataBase))
                    nUferms := SM2->&("M2_MOEDA"+Alltrim(aSX6[MV_UFERMS]))
                Endif
                If nUferms > 0
                    aNfItem[nItem][IT_VALFDS]  := aNfItem[nItem][IT_QUANT] * (nUferms * aNfItem[nItem][IT_PRD][SB_PRFDSUL] / 100)
                    aNfItem[nItem][IT_PRFDSUL] := aNfItem[nItem][IT_PRD][SB_PRFDSUL]
                    aNfItem[nItem][IT_UFERMS]  := nUferms
                Endif
            Endif        
        Endif
    EndIF
Return