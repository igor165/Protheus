#Include "FINA136D.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} F136Bonifi
Rotina API para bonificação de título. Efetua a compensação da NCC e/ou aplicação de desconto no título.

@type       Function
@author     Rafael Riego
@since      30/04/2020
@version    P12.1.27
@param      oParcela, object, objeto JSON contendo as informações do título
@param      cMsgErro, character, variável mensagem passada por referência
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Function F136Bonifi(oParcela As J, cMsgErro As Character) As Logical

    Local aArea         As Array
    Local aDadosSE1     As Array
    Local aNCC          As Array
    Local aParametro    As Array
    Local aSE1          As Array
    Local aValores      As Array

    Local cHistorico    As Character

    Local nNCC          As Numeric
    Local nSaldoComp    As Numeric

    Default cMsgErro    := ""

    aArea       := {SE1->(GetArea()), GetArea()}
    aDadosSE1   := {}
    aNCC        := {}
    aParametro  := {.T., .F., .F., .F., .F., .F.}
    aSE1        := {}
    aValores    := {}
    nSaldoComp  := oParcela["localAmount"]

    If Empty(oParcela["history"])
        cHistorico := STR0001 // "Bonificação Totvs Antecipa"
    Else
        cHistorico := oParcela["history"]
    EndIf

    AAdd(aSE1, SE1->(RecNo()))

    For nNCC := 1 To Len(oParcela["creditUnits"])
        AAdd(aNCC, oParcela["creditUnits"][nNCC]["recordId"])
        AAdd(aValores, oParcela["creditUnits"][nNCC]["creditAmount"])
        SE1->(DbGoTo(oParcela["creditUnits"][nNCC]["recordId"]))
        AAdd(aDadosSE1, {SE1->(RecNo()), cHistorico, FaVlAtuCr("SE1", dDataBase)})
    Next nNCC

    //Caso tenha compensação, executa
    If oParcela["creditAmount"] > 0 .Or. FwIsInCallStack("FCompDevol")
        If !(MaIntBxCr(3, aSE1, /*3*/, aNCC, /*5*/, aParametro, /*7*/, /*8*/, aDadosSE1,/*10*/, nSaldoComp,;
            /*12*/, aValores, /*14*/, /*15*/, /*16*/, /*17*/, /*18*/, /*19*/))
            cMsgErro := FinGetHelp()
            If Empty(cMsgErro)
                cMsgErro := "Não foi possível realizar a compensação da NCC '" + SE1->E1_PARCELA + "."
            EndIf
        EndIf
        //Reposiciona registro após a MaIntBxCr movimentar o ponteiro para o final do arquivo
        SE1->(DbGoTo(aSE1[1]))
    EndIf

    //Gera aplicação de desconto no título
    If Empty(cMsgErro) .And. oParcela["discountAmount"] > 0
        AplicDesco(oParcela, @cMsgErro)
    EndIf

    //Gera a movimentação do crédito aplicado (NCCs) e Desconto
    If Empty(cMsgErro) .And. oParcela["localAmount"] > 0
        MovCredito(oParcela, @cMsgErro)
    EndIf

    //Gera taxa da movimentação
    If Empty(cMsgErro) .And. oParcela["feeAmount"] > 0
        F136GerMov(oParcela, @cMsgErro, oParcela["feeAmount"])
    EndIf

    //Realiza transferência bancária da taxa original
    If Empty(cMsgErro) .And. oParcela["feeAmountOrigin"] > 0
        F136GerMov(oParcela, @cMsgErro, oParcela["feeAmountOrigin"] , 4)
    EndIf
    FwFreeArray(aDadosSE1)
    FwFreeArray(aNCC)
    FwFreeArray(aValores)
    
    AEval(aArea, {|area| RestArea(area)})
    
Return Empty(cMsgErro)

/*/{Protheus.doc} AplicDesco
Rotina para aplicação de desconto na parcela.

@type       Static Function
@author     Rafael Riego
@since      06/05/2020
@version    P12.1.27
@param      oParcela, object, objeto JSON contendo as informações do título
@param      cMsgErro, character, variável mensagem passada por referência
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Static Function AplicDesco(oParcela As J, cMsgErro As Character) As Logical

    Local cOldHistor    As Character

    Default cMsgErro    := ""

    cOldHistor := oParcela["history"]
    oParcela["history"] := STR0003 // "Desconto TOTVS Antecipa"

    F136Baixa(oParcela, @cMsgErro)
    
    oParcela["history"] := cOldHistor


Return Empty(cMsgErro)

/*/{Protheus.doc} MovCredito
Rotina para gerar movimentação bancária com o valor do crédito aplicado na NF.

@type       Static Function
@author     Rafael Riego
@since      20/05/2020
@version    P12.1.27
@param      oParcela, object, objeto JSON contendo as informações do título
@param      cMsgErro, character, variável mensagem passada por referência
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Static Function MovCredito(oParcela As J, cMsgErro As Character) As Logical

    Local cOldHistor    As Character

    Default cMsgErro    := ""

    cOldHistor := oParcela["taxHistory"]
    //Compensação por devolução
    If FwIsInCallStack("FCompDevol")
        oParcela["taxHistory"] := STR0005 // "DEVOLUCAO"
    Else
        oParcela["taxHistory"] := STR0004 // "BONIFICACAO"
    EndIf

    F136GerMov(oParcela, @cMsgErro, oParcela["localAmount"])

    oParcela["taxHistory"] := cOldHistor

Return Empty(cMsgErro)
