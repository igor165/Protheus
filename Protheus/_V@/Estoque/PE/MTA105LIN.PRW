#INCLUDE "TOTVS.CH"

//    SCP 
//    SE  Posicionar NA CT1_CONTA usando B1_X_DEBIT, CT1_CCOBRG = 1 E CP_CC = EMPTY
//    Obrigatório Preenchimento do Campo Centro de Custos

//    Posicionar NA CT1_CONTA usando B1_X_DEBIT, CT1_ITOBRG E CP_ITEMCTA  = EMPTY
//    Obrigatório Preenchimento do Campo Item Contábil

//    Posicionar NA CT1_CONTA usando B1_X_DEBIT, CT1_CLOBRG E E CP_CLVL = EMPTY
//    Obrigatório Preenchimento do Campo Classe de Valor

User Function MTA105LIN()
    local lret      :=	.T.
	Local aArea     := GetArea()
    Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="CP_PRODUTO"})
    Local nCC       := aScan(aHeader,{|x| Trim(x[2])=="CP_CC"})
    Local nItemCta  := aScan(aHeader,{|x| Trim(x[2])=="CP_ITEMCTA"})
    Local nClVl     := aScan(aHeader,{|x| Trim(x[2])=="CP_CLVL"})

    DBSELECTAREA( "SB1" )
    SB1->(DBSETORDER( 1 )) //B1_FILIAL+B1_COD

    IF SB1->(DBSEEK( FwxFilial("SB1")+aCols[n][nPProduto]))
        IF !EMPTY(SB1->B1_X_DEBIT)
            DBSELECTAREA( "CT1" )
            CT1->(DBSETORDER( 1 )) //CT1_FILIAL+CT1_CONTA

            IF CT1->(DBSEEK( FwxFilial("CT1")+SB1->B1_X_DEBIT))
                IF CT1->CT1_CCOBRG == '1' .AND. EMPTY(aCols[n][nCC])
                    lRet := .F. 
                    Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO CENTRO DE CUSTOS.')
                ENDIF

                IF lRet .and. CT1->CT1_ITOBRG == '1' .AND. EMPTY(aCols[n][nItemCta])
                    lRet := .F.
                    Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO ITEM CONTÁBIL.')
                ENDIF

                IF lRet .and. CT1->CT1_CLOBRG == '1' .AND. EMPTY(aCols[n][nClVl])
                    lRet := .F. 
                    Alert('OBRIGATÓRIO PREENCHIMENTO DO CAMPO CLASSE DE VALOR')
                ENDIF
            ENDIF
            
            CT1->(DBCLOSEAREA(  ))
        ENDIF 
    ENDIF 
    
    SB1->(DBCLOSEAREA(  ))

	RestArea(aArea)
Return lRet 
