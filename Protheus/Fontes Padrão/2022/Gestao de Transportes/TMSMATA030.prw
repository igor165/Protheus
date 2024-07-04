#include "protheus.ch"
#include "tmsmata030.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSMATA030
Função que valida se é possível excluir o cliente.

@author arume.alexandre
@since 01/10/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TMSMATA030()

    Local aArea     := GetArea()
    Local lRet      := .T.
    Local cQuery    := ""
    Local cAliasTRB := ""
    
    cAliasTRB := GetNextAlias()
    cQuery := " SELECT "
    cQuery += " COUNT(DTC_FILIAL) QUANT "
    cQuery += "   FROM " + RetSqlName("DTC")
    cQuery += "   WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
    cQuery += "     AND ( ( DTC_CLIREM = '" + SA1->A1_COD + "' AND DTC_LOJREM = '" + SA1->A1_LOJA + "' )   "
    cQuery += "        OR ( DTC_CLIDES = '" + SA1->A1_COD + "' AND DTC_LOJDES = '" + SA1->A1_LOJA + "' )   "
    cQuery += "        OR ( DTC_CLICON = '" + SA1->A1_COD + "' AND DTC_LOJCON = '" + SA1->A1_LOJA + "' )   "
    cQuery += "        OR ( DTC_CLIDPC = '" + SA1->A1_COD + "' AND DTC_LOJDPC = '" + SA1->A1_LOJA + "' ) ) "
    cQuery += "     AND D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
    If (cAliasTRB)->(!Eof())
        If (cAliasTRB)->QUANT > 0
            lRet := .F.
        EndIf
    EndIf
    (cAliasTRB)->(DbCloseArea())
    If lRet
        cQuery := " SELECT "
        cQuery += " COUNT(*) QUANT "
        cQuery += "   FROM " + RetSqlName("DE4")
        cQuery += "   WHERE DE4_FILIAL = '" + xFilial("DE4") + "' "
        cQuery += "     AND DE4_CNPJ   = '" + SA1->A1_CGC    + "' " 
        cQuery += "     AND D_E_L_E_T_ = ' ' "
        cQuery += " UNION ALL "
        cQuery += " SELECT "
        cQuery += " COUNT(*) QUANT "
        cQuery += "   FROM " + RetSqlName("DE4")
        cQuery += "   WHERE DE4_FILIAL = '" + xFilial("DE4") + "' "
        cQuery += "     AND DE4_CNPJ1  = '" + SA1->A1_CGC    + "' " 
        cQuery += "     AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
        While (cAliasTRB)->(!Eof())
            If (cAliasTRB)->QUANT > 0
                lRet := .F.
                Exit
            EndIf
            (cAliasTRB)->(DbSkip())
        End
        (cAliasTRB)->(DbCloseArea())
    EndIf
    If lRet
        cQuery := " SELECT "
        cQuery += " COUNT(*) QUANT "
        cQuery += "   FROM " + RetSqlName("DW3")
        cQuery += "   WHERE DW3_FILIAL = '" + xFilial("DW3") + "' "
        cQuery += "     AND DW3_CODCLI = '" + SA1->A1_COD    + "' " 
        cQuery += "     AND DW3_LOJCLI = '" + SA1->A1_LOJA   + "' "
        cQuery += "     AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
        If (cAliasTRB)->(!Eof())
            If (cAliasTRB)->QUANT > 0
                lRet := .F.
            EndIf
        EndIf
        (cAliasTRB)->(DbCloseArea())
    EndIf

    If !lRet
        Help( ,, 'TMSNODEL',, STR0001 , 1, 0) //-- Nao sera possivel excluir o cliente, pois o mesmo esta em uso no SIGATMS.
    EndIf

    RestArea(aArea)

Return lRet