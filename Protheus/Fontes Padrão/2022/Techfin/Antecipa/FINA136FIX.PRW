#Include "Protheus.ch"

Static cQueryFK1
Static cQueryFK6
Static cQuerySE5

Static lAjuste

Static oPrepStFK1
Static oPrepStFK6
Static oPrepStSE5

/*/{Protheus.doc} FINA136FIX
Rotina para ajustar registro originados através das Baixas do TOTVS Antecipa que geraram movimentos de forma indevida na tabela FK6.

@type       Function
@author     Rafael Riego
@since      18/08/2020
@version    P12.1.27
@return     Nil
/*/
Function FinA136Fix()

    Local cCartTechF    As Character
    Local cMsgProcess   As Character
    Local cSE1xFK7      As Character

    Local oRegua        As Object

    cCartTechF := PadR(SuperGetMV("MV_CARTECF",, ""), TamSX3("FRV_CODIGO")[1])

    If !(Empty(cCartTechF))
        cSE1xFK7 := BuscTitAnt(cCartTechF)

        If (cSE1xFK7)->(EoF())
            Help(Nil, Nil, "X", "", "Nenhum título encontrado em Carteira TOTVS Antecipa para ajuste." , 1,,,,,,, {""}) //"Nenhum título encontrado em Carteira TOTVS Antecipa para ajuste."
        Else
            //1. Régua para processamento
            oRegua := MsNewProcess():New({|| ProcBaixa(oRegua, cSE1xFK7)}, "Ajuste p/ Baixas TOTVS Antecipa", "Realizando análise e ajustes necessários...", .F.)
            oRegua:Activate()

            If !lAjuste
                cMsgProcess := "Nenhum ajuste foi realizado nas baixas realizadas através do TOTVS Antecipa."
            Else
                cMsgProcess := "Ajustes realizados para todas as inconsistências encontradas nas baixas realizadas através do TOTVS Antecipa."
            EndIf

            MsgInfo(cMsgProcess, "TOTVS Antecipa")
        EndIf
        (cSE1xFK7)->(DbCloseArea())
    Else
        Help(Nil, Nil, "Y", "", "Parametro MV_CARTECF (Carteira TOTVS Antecipa) não preenchido ou não encontrado." , 1,,,,,,, {""}) //"Parametro MV_CARTECF (Carteira TOTVS Antecipa) não preenchido ou não encontrado."
    EndIf

Return Nil

/*/{Protheus.doc} BuscTitAnt
Rotina que busca os títulos em Carteira TOTVS Antecipa.

@type       Static Function
@author     Rafael Riego
@since      18/08/2020
@version    P12.1.27
@param      cCartTechF, character, carteira TOTVS Antecipa (MV_CARTECF)
@return     Nil
/*/
Static Function BuscTitAnt(cCartTechF As Character)

    Local cSE1xFK7  As Character
    Local cQuery    As Character

    //1. Localizar Títulos que estão em Carteira TOTVS Antecipa (MV_CARTECF);
    cQuery := " SELECT SE1.R_E_C_N_O_ SE1_RECNO, FK7.R_E_C_N_O_ FK7_RECNO"
    cQuery += " FROM " + RetSQLName("SE1") + " SE1 INNER JOIN " + RetSQLName("FK7") + " FK7 ON "
    cQuery += "        FK7.FK7_FILIAL = SE1.E1_FILIAL "
    cQuery += "    AND FK7.FK7_ALIAS = 'SE1' "
    cQuery += "    AND FK7.FK7_CHAVE = SE1.E1_FILIAL + '|' + SE1.E1_PREFIXO + '|' + SE1.E1_NUM + '|' + SE1.E1_PARCELA + '|' +  SE1.E1_TIPO + '|' + SE1.E1_CLIENTE + '|' + SE1.E1_LOJA "
    cQuery += " WHERE SE1.E1_FILIAL = '" + FwXFilial("SE1") + "' "
    cQuery += "   AND SE1.E1_SITUACA = '" + cCartTechF + "' "
    cQuery += "   AND SE1.E1_BAIXA <> '' "
    cQuery += "   AND (SE1.E1_JUROS > 0 OR SE1.E1_VALJUR > 0) "
    cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
    cQuery += "   AND FK7.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    cSE1xFK7 := MPSysOpenQuery(cQuery)

Return cSE1xFK7

/*/{Protheus.doc} ProcBaixa
Rotina que busca as baixas TOTVS Antecipa para verificar se foi gerado dados nas tabelas SE5/FK6 e realizar as atualizações de registros necessárias.

@type       Static Function
@author     Rafael Riego
@since      19/08/2020
@version    P12.1.27
@param      oRegua, object, regua de processamento
@param      cSE1xFK7, character, alias de relacionamento entre SE1 e FK7
@return     Nil
/*/
Static Function ProcBaixa(oRegua As Object, cSE1xFK7 As Character)

    Local cAliasFK1     As Character

    Local nRegua1       As Numeric
    Local nRegua2       As Numeric
    Local nValAjuste    As Numeric

    If oRegua == Nil
        Return Nil
    EndIf

    lAjuste := .F.

    DbSelectArea(cSE1xFK7)

    Count To nRegua1

    (cSE1xFK7)->(DbGoTop())

    oRegua:SetRegua1(nRegua1)

    CriaPStQry()

    cAliasFK1 := GetNextAlias()

    While (cSE1xFK7)->(!(EoF()))
        SE1->(DbGoTo((cSE1xFK7)->SE1_RECNO))
        FK7->(DbGoTo((cSE1xFK7)->FK7_RECNO))

        oRegua:IncRegua1()

        //1. Localizar Baixas a Receber que são do Tipo V2 (Baixa Descontada);
        oPrepStFK1:SetString(1, FK7->FK7_IDDOC)
        MPSysOpenQuery(oPrepStFK1:GetFixQuery(), cAliasFK1)

        DbSelectArea(cAliasFK1)
        Count To nRegua2
        oRegua:SetRegua1(nRegua2)

        (cAliasFK1)->(DbGoTop())

        While (cAliasFK1)->(!(EoF()))
            oRegua:IncRegua2("Título: " + FK7->FK7_CHAVE)
            FK1->(DbGoTo((cAliasFK1)->FK1_RECNO))
            Begin Transaction
            //2. Localizar FK6 (Tipo J2)
            oPrepStFK6:SetString(1, FK1->FK1_IDFK1)
            nValAjuste := BscDelFK6()

            //3. Localizar SE5 (Tipo J2)
            oPrepStSE5:SetString(1, FK1->FK1_IDFK1)
            BscDelSE5()

            //4. Fix das tabelas
            AjustaSE1(nValAjuste)
            End Transaction

            //caso entre nessa condição abaixo significa que alguma baixa foi ajustada
            If nValAjuste
                lAjuste := .T.
            EndIf
            (cAliasFK1)->(DbSkip())
        End

        (cAliasFK1)->(DbCloseArea())
        (cSE1xFK7)->(DbSkip())
    End

    DeltPStQry()

Return Nil

/*/{Protheus.doc} CriaPStQry
Iniciliza os objetos FwPreparedStatement nas variáveis statics e monta as queries para buscar os registros nas tabelas FK1, FK6 E SE5.

@type       Static Function
@author     Rafael Riego
@since      19/08/2020
@version    P12.1.27
@return     Nil
/*/
Static Function CriaPStQry()

    DeltPStQry()

    oPrepStFK1 := FwPreparedStatement():New()
    oPrepStFK6 := FwPreparedStatement():New()
    oPrepStSE5 := FwPreparedStatement():New()

    cQueryFK1 := " SELECT FK1.R_E_C_N_O_ FK1_RECNO"
    cQueryFK1 += " FROM " + RetSQLName("FK1") + " FK1 "
    cQueryFK1 += " WHERE FK1.D_E_L_E_T_ = ' ' "
    cQueryFK1 += "   AND FK1.FK1_FILIAL = '" + FwXFilial("FK1") + "' "
    cQueryFK1 += "   AND FK1.FK1_IDDOC = ? "
    cQueryFK1 += "   AND FK1.FK1_ORIGEM IN ('FINI136O', 'FINA136B') "
    cQueryFK1 += "   AND FK1.FK1_TPDOC = 'V2' "
    cQueryFK1 += "   AND FK1.D_E_L_E_T_ = ' ' "
    cQueryFK1 += "   AND NOT EXISTS( "
    cQueryFK1 += "   SELECT FK1EST.FK1_IDDOC FROM " + RetSQLName("FK1") +" FK1EST"
    cQueryFK1 += "   WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL"
    cQueryFK1 += "     AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
    cQueryFK1 += "     AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
    cQueryFK1 += "     AND FK1EST.FK1_DOC = FK1.FK1_DOC "
    cQueryFK1 += "     AND FK1EST.FK1_TPDOC = 'ES' "
    cQueryFK1 += "     AND FK1EST.D_E_L_E_T_ = ' ') "

    cQueryFK6 := " SELECT FK6.R_E_C_N_O_ FK6_RECNO"
    cQueryFK6 += " FROM " + RetSQLName("FK6") + " FK6 "
    cQueryFK6 += " WHERE FK6_FILIAL = '" + FwXFilial("FK6") + "' "
    cQueryFK6 += "   AND FK6_TABORI = 'FK1' "
    cQueryFK6 += "   AND FK6_TPDOC IN ('J2', 'M2') " //J2 - JUROS DESCONTADA/ M2 - MULTA DESCONTADA
    cQueryFK6 += "   AND FK6_IDORIG = ? "
    cQueryFK6 += "   AND D_E_L_E_T_ = ' ' "

    cQuerySE5 := " SELECT SE5.R_E_C_N_O_ SE5_RECNO"
    cQuerySE5 += " FROM " + RetSQLName("SE5") + " SE5 "
    cQuerySE5 += " WHERE E5_FILIAL = '" + FwXFilial("SE5") + "' "
    cQuerySE5 += "   AND E5_TIPODOC IN ('J2', 'M2') "
    cQuerySE5 += "   AND E5_ORIGEM IN ('FINI136O', 'FINA136B') "
    cQuerySE5 += "   AND E5_IDORIG = ? "
    cQueryFK6 += "   AND D_E_L_E_T_ = ' ' "

    oPrepStFK1:SetQuery(cQueryFK1)
    oPrepStFK6:SetQuery(cQueryFK6)
    oPrepStSE5:SetQuery(cQuerySE5)

Return Nil

/*/{Protheus.doc} DeltPStQry
Limpa os objetos FwPreparedStatement nas variáveis statics.

@type       Static Function
@author     Rafael Riego
@since      19/08/2020
@version    P12.1.27
@return     Nil
/*/
Static Function DeltPStQry()

    If oPrepStFK1 != Nil
        oPrepStFK1:Destroy()
        FreeObj(oPrepStFK1)
    EndIf
    If oPrepStFK6 != Nil
        oPrepStFK6:Destroy()
        FreeObj(oPrepStFK6)
    EndIf
    If oPrepStSE5 != Nil
        oPrepStSE5:Destroy()
        FreeObj(oPrepStSE5)
    EndIf

Return Nil

/*/{Protheus.doc} BscDelFK6
Realiza a busca das linhas de valores acessórios na SE5 para deleção e obtem os valores de juros para juste do título.

@type       Static Function
@author     Rafael Riego
@since      19/08/2020
@return     numeric, valor a ser subtraído no título
/*/
Static Function BscDelFK6() As Numeric

    Local cAliasFK6     As Character

    Local nValAjuste    As Numeric

    cAliasFK6   := GetNextAlias()
    nValAjuste  := 0

    MPSysOpenQuery(oPrepStFK6:GetFixQuery(), cAliasFK6)

    While (cAliasFK6)->(!(EoF()))
        FK6->(DbGoTo((cAliasFK6)->FK6_RECNO))
        nValAjuste += FK6->FK6_VALMOV //TODO VERIFICAR SE CAMPO É O CORRETO (EXISTE O CAMPO FK6_VALCAL)
        RecLock("FK6", .F.)
        FK6->(DbDelete())
        FK6->(MsUnlock())
        (cAliasFK6)->(DbSkip())
    End

    (cAliasFK6)->(DbCloseArea())

Return nValAjuste

/*/{Protheus.doc} BscDelSE5
Realiza a busca das linhas de valores acessórios na SE5 para deleção.

@type       Static Function
@author     Rafael Riego
@since      19/08/2020
@return     numeric, valor a ser subtraído no título
/*/
Static Function BscDelSE5()

    Local cAliasSE5 As Character

    cAliasSE5   := GetNextAlias()
    nValAjuste  := 0

    MPSysOpenQuery(oPrepStSE5:GetFixQuery(), cAliasSE5)

    While (cAliasSE5)->(!(EoF()))
        SE5->(DbGoTo((cAliasSE5)->SE5_RECNO))
        RecLock("SE5", .F.)
        SE5->(DbDelete())
        SE5->(MsUnlock())
        (cAliasSE5)->(DbSkip())
    End

    (cAliasSE5)->(DbCloseArea())

Return Nil

/*/{Protheus.doc} AjustaSE1
Rotina que atualiza o saldo e o status da tabela SE1 se baseando nos valores acessórios gerados na baixa.

@type       Static Function
@author     Rafael Riego
@since      19/08/2020
@version    P12.1.27
@param      nValAjuste, numeric, valor a ser subtraído do título
@return     Nil
/*/
Static Function AjustaSE1(nValAjuste As Numeric)

    Default nValAjuste := 0

    If nValAjuste > 0
        RecLock("SE1", .F.)
        SE1->E1_SALDO -= nValAjuste
        If SE1->E1_SALDO <= 0
            SE1->E1_SALDO := 0
            SE1->E1_STATUS := "B"
        EndIf
        SE1->(MsUnlock())
    EndIf

Return Nil
