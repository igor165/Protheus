#Include "FINA136C.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} F136MovBan
Rotina API para transfer�ncia banc�ria. Efetua a transfer�ncia do banco portador para o banco informado via par�matro.

@type       Function
@author     Rafael Riego
@since      12/11/2019
@version    P12.1.27
@param      oTitulo, object, objeto JSON contendo as informa��es do t�tulo
@param      cMsgErro, character, vari�vel mensagem passada por refer�ncia
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Function F136MovBan(oTitulo As J, cMsgErro As Character) As Logical //F136MovimentacaoBancaria

    Local aArea         As Array
    Local aInfoBanco    As Array
    Local aTransf       As Array

    Local cAgPortado    As Character
    Local cBcoPortad    As Character
    Local cContaPort    As Character
    Local cDocTran      As Character
    Local cHistorico    As Character
    Local cNatDespes    As Character
    Local cNatReceit    As Character

    Local nOperacao     As Numeric

    Private lMsErroAuto     As Logical
    Private lMsHelpAuto     As Logical

    aArea           := {SA6->(GetArea()), GetArea()}
    aInfoBanco      := F136AJstBc()
    aTransf         := {}
    cBcoPortad      := aInfoBanco[1]
    cAgPortado      := aInfoBanco[2]
    cContaPort      := aInfoBanco[3]
    cNatDespes      := oTitulo["expenseClass"]
    cNatReceit      := oTitulo["revenueClass"]
    cDocTran        := SubStr(StrTran(AllTrim(DToS(Date())) + Alltrim(Str(Seconds())), ".", ""), 3, TamSX3("FK5_NUMCH")[1])
    lMsErroAuto     := .F.
    lMsHelpAuto     := .T.
    nOperacao       := 7

    If Empty(oTitulo["history"])
        If oTitulo["typeOperation"] == 2 //Cr�dito
            oTitulo["history"] := STR0002 //"Implanta��o de antecipa��o"
        Else
            oTitulo["history"] := STR0003 //"Estorno de antecipa��o"
        EndIf
    EndIf

    //Ajuste da string para n�o estourar o tamanho do campo FK5_HISTOR
    cHistorico := PadR(oTitulo["history"], TamSX3("FK5_HISTOR")[1])

    AAdd(aTransf, {"DDATACRED",     oTitulo["date"],        Nil})
    AAdd(aTransf, {"NVALORTRAN",    oTitulo["localAmount"], Nil})
    AAdd(aTransf, {"CTIPOTRAN",     "R$",                   Nil})
    AAdd(aTransf, {"CDOCTRAN",      cDocTran,               Nil})
    
    //Contabiliza��o On-line
    AAdd(aTransf, {"NAGLUTINA",     2,                      Nil}) //1=Sim;2=N�o
    AAdd(aTransf, {"NCTBONLINE",    1,                      Nil}) //1=Sim;2=N�o

    If !(Empty(cHistorico))
        AAdd(aTransf, {"CHIST100",     cHistorico,         Nil})
    EndIf
    If oTitulo["typeOperation"] == 1 //DEBITO
        AAdd(aTransf, {"CBCOORIG",  oTitulo["bankCode"],    Nil})
        AAdd(aTransf, {"CAGENORIG", oTitulo["agencyCode"],  Nil})
        AAdd(aTransf, {"CCTAORIG",  oTitulo["accountCode"], Nil})
        AAdd(aTransf, {"CBCODEST",  cBcoPortad,             Nil})
        AAdd(aTransf, {"CAGENDEST", cAgPortado,             Nil})
        AAdd(aTransf, {"CCTADEST",  cContaPort,             Nil})
        AAdd(aTransf, {"CNATURDES", cNatReceit,             Nil})
        AAdd(aTransf, {"CNATURORI", cNatDespes,             Nil})
    ElseIf oTitulo["typeOperation"] == 2 //CREDITO
        AAdd(aTransf, {"CBCOORIG",  cBcoPortad,             Nil})
        AAdd(aTransf, {"CAGENORIG", cAgPortado,             Nil})
        AAdd(aTransf, {"CCTAORIG",  cContaPort,             Nil})
        AAdd(aTransf, {"CBCODEST",  oTitulo["bankCode"],    Nil})
        AAdd(aTransf, {"CAGENDEST", oTitulo["agencyCode"],  Nil})
        AAdd(aTransf, {"CCTADEST",  oTitulo["accountCode"], Nil})
        AAdd(aTransf, {"CNATURDES", cNatDespes,             Nil})
        AAdd(aTransf, {"CNATURORI", cNatReceit,             Nil})
    EndIf

    MsExecAuto({|pos_rotina, transferencia, operacao| FinA100(pos_rotina, transferencia, operacao)}, 0, aTransf, nOperacao)

    If lMsErroAuto
        cMsgErro := FinGetHelp()
        If Empty(cMsgErro)
            cMsgErro := STR0001 //"Erro n�o identificado na execu��o da rotina de transfer�ncia."
        EndIf
    EndIf

    FwFreeArray(aTransf)

    AEval(aArea, {|area| RestArea(area)})

Return Empty(cMsgErro)

/*/{Protheus.doc} F136BatCon
Efetua o batimento de carteira para a opera��o de concilia��o.

@author     Rafael Riego
@since      03/06/2020
@version    1.0
@param      oParcela, J, parcela da NF cancelada que ser� conciliado
@param      cMsgErro, character, vari�vel para obter a msg de erro ap�s a execu��o (refer�ncia)
@return     logical, verdadeiro em caso de sucesso
/*/
Function F136BatCon(oParcela As J, cMsgErro As Character) As Logical

    Local aArea         As Array

    Default cMsgErro    := ""
    Default oParcela    := Nil
    
    aArea := {GetArea()}


    //Realiza movimenta��o banc�ria da concilia��o
    If oParcela["localAmount"] > 0
        F136MovBan(oParcela, @cMsgErro)
    EndIf

    AEval(aArea, {|area| RestArea(area), FwFreeArray(area)})

Return Empty(cMsgErro)
