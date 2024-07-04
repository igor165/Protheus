#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PCPA141T4R
Exclui os registros apagados da tabela T4R.
@type  Function
@author Lucas Fagundes
@since 16/05/2022
@version P12
@return Nil
/*/
Function PCPA141T4R(aParams)
    Local cAlias  := GetNextAlias()
    Local cBanco  := ""
    Local cDelete := ""
    Local nCont   := 0
    Local nTotal  := 0

    RpcSetType(3)
    RpcSetEnv(aParams[1], aParams[2], Nil, Nil, "PCP", Nil)
    cBanco := AllTrim(Upper(TcGetDb()))

    BeginSql alias cAlias
        SELECT COUNT(1) TOTAL
          FROM %table:T4R% T4R
         WHERE T4R.T4R_FILIAL = %xfilial:T4R%
           AND T4R.D_E_L_E_T_ = '*'
    EndSql

    If (cAlias)->(!EoF())
        nTotal := (cAlias)->TOTAL
    EndIf
    (cAlias)->(DbCloseArea())

    If cBanco == "ORACLE"
        cDelete := " DELETE FROM " + RetSqlName("T4R")
        cDelete += " WHERE T4R_FILIAL = '" + xfilial("T4R") + "' AND D_E_L_E_T_ = '*' AND ROWNUM <= 100 "
    ElseIf cBanco == "POSTGRES"
        cDelete := " DELETE FROM " + RetSqlName("T4R")
        cDelete += " WHERE R_E_C_N_O_ IN (SELECT R_E_C_N_O_ "
        cDelete +=                      " FROM " + RetSqlName("T4R") + " 
        cDelete +=                      " WHERE T4R_FILIAL = '" + xfilial("T4R") + "' AND D_E_L_E_T_ = '*' LIMIT 100) "
    Else
        cDelete := " DELETE TOP (100) FROM " + RetSqlName("T4R")
        cDelete += " WHERE T4R_FILIAL = '" + xfilial("T4R") + "' AND D_E_L_E_T_ = '*' "
    EndIf

    while nCont < nTotal
        TCSQLExec(cDelete)
        nCont += 100
    end

Return Nil
