#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXAFRMM
    (Componentização da função MaFisAFRMM - 
    AFRMM. Adicional de Frete para a Renovação da Marinha Mercante - AFRMM.
    
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
Function FISXAFRMM(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
    
    aNfItem[nItem][IT_BASEAFRMM] := 0
    aNfItem[nItem][IT_ALIQAFRMM] := 0
    aNfItem[nItem][IT_VALAFRMM]  := 0

    //Verifica se algum tributo genérico com ID do AFRMM enquadrado, e zera referências para não calcular em duplicidade
    If !(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_AFRMM))
        If aNFItem[nItem][IT_TS][TS_AFRMM] == "S"
            aNfItem[nItem][IT_BASEAFRMM] := aNfItem[nItem][IT_VALMERC]
            aNfItem[nItem][IT_ALIQAFRMM] := IIf( !Empty( aSX6[MV_TXAFRMM] )  , aSX6[MV_TXAFRMM] , 0 )
            aNfItem[nItem][IT_VALAFRMM]  := (( aNfItem[nItem][IT_BASEAFRMM] * aNfItem[nItem][IT_ALIQAFRMM] ) / 100 )

            If aPE[PE_MAAFRMM]
                aNfItem[nItem][IT_VALAFRMM] := ExecBlock("MAAFRMM",.F.,.F.,{ aNfItem[nItem][IT_VALAFRMM] })
            Endif        
        EndIf
    EndIF
Return