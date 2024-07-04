#Include "FINA136B.ch"
#Include "Protheus.ch"

Static cMotBaixa := ""

/*/{Protheus.doc} F136Baixa
Rotina API para baixa de título. Efetua baixa do título passado por parâmetro no banco portador (contido nos MVs).

@type       Function
@author     Rafael Riego
@since      12/11/2019
@version    P12.1.27
@param      oTitulo, object, objeto JSON contendo as informações do título
@param      cMsgErro, character, variável mensagem passada por referência
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Function F136Baixa(oTitulo As J, cMsgErro As Character) As Logical

    Local aArea         As Array
    Local aBaixa        As Array
    Local aDadosSE1     As Array
    Local aRecnoSE1     As Array
    Local aInfoBanco    As Array

    Local cAgencia      As Character
    Local cBanco        As Character
    Local cConta        As Character
    Local cHistorico    As Character

    Local lAglutina     As Logical
    Local lComisNCC     As Logical
    Local lContabiliza  As Logical
    Local lDesconto     As Logical
    Local lDigita       As Logical
    Local lJuros        As Logical

    Default cMsgErro    := ""

    aArea       := {SA6->(GetArea()), SE1->(GetArea()), GetArea()}
    aBaixa      := {}
    aRecnoSE1   := {}
    aDadosSE1   := {}
    aInfoBanco  := F136AJstBc()
    cBanco      := aInfoBanco[1]
    cAgencia    := aInfoBanco[2]
    cConta      := aInfoBanco[3]

    If Empty(oTitulo["history"])
        cHistorico := STR0004 // "Recebimento pelo TOTVS Antecipa"
    Else
        cHistorico := oTitulo["history"]
    EndIf

    Pergunte("FIN070", .F.)
    lAglutina     := MV_PAR02 == 2
    lContabiliza  := .T.
    lDigita       := .F.
    lDesconto     := .F.
    lJuros        := .F.
    lComisNCC     := .F.

    AAdd(aRecnoSE1, SE1->(RecNo()))
    AAdd(aDadosSE1, {SE1->(RecNo()), cHistorico, FaVlAtuCr("SE1", dDataBase)})

    If !(FwIsInCallStack("F136Bonifi")) //Caso não seja aplicação de desconto via API de Bonificação
        AAdd(aBaixa, TrazCodMot("NOR"))
        AAdd(aBaixa, oTitulo["localAmount"])
        AAdd(aBaixa, cBanco)
        AAdd(aBaixa, cAgencia)
        AAdd(aBaixa, cConta)
        AAdd(aBaixa, dDataBase)
        AAdd(aBaixa, dDataBase)
        //Sempre desconsidera decréscimos, acréscimos, multas e juros
        aDadosSE1[1][3][2] := 0 //Abatimentos
        aDadosSE1[1][3][4] := 0 //Descrescimo
        aDadosSE1[1][3][5] := 0 //Acrescimo
        aDadosSE1[1][3][8] := 0 //Juros
    Else
        //Carrega através do GetMV para os casos de substituição 
        If Empty(cMotBaixa)    
            cMotBaixa := GetMV("MV_MOTTECF", .F., "")
        EndIf

        AAdd(aBaixa, PadR(cMotBaixa, TamSX3("FK1_MOTBX")[1]))
        AAdd(aBaixa, 0)
        AAdd(aBaixa, "")
        AAdd(aBaixa, "") 
        AAdd(aBaixa, "")   
        AAdd(aBaixa, dDataBase)
        AAdd(aBaixa, dDataBase)
        aDadosSE1[1][3][9] := oTitulo["discountAmount"] //aplicação do desconto
    EndIf

    If !(MaIntBxCr(1, aRecnoSE1, aBaixa,,, {lContabiliza, lAglutina, lDigita, lDesconto, lJuros, lComisNCC},,, aDadosSE1))
        cMsgErro := FinGetHelp()
        If Empty(cMsgErro)
            cMsgErro := STR0001 + SE1->E1_PARCELA + "." // "Não foi possível realizar a baixa da parcela '"
        EndIf
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return Empty(cMsgErro)

/*/{Protheus.doc} F136CancBx
Rotina API para cancelamento de baixa. Efetua cancelamento da baixa do título passado por parâmatro.

@type       Function
@author     Rafael Riego
@since      12/11/2019
@version    P12.1.27
@param      oTitulo, object, objeto JSON contendo as informações do título
@param      cMsgErro, character, variável mensagem passada por referência
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Function F136CancBx(oTitulo As J, cMsgErro As Character) As Logical

    Local aArea         As Array
    Local aCancBaixa    As Array

    Local cHistorico    As Character

    Local nOperacao     As Numeric

    Default cMsgErro    := ""

    Private lMsErroAuto     As Logical
    Private lMsHelpAuto     As Logical
    
    lMsErroAuto     := .F.
    lMsHelpAuto     := .T.

    aArea       := {SE1->(GetArea()), GetArea()}
    aCancBaixa  := {}
    cHistorico  := oTitulo["history"]
    nOperacao   := 5
    
	AAdd(aCancBaixa, {"E1_FILIAL",  SE1->E1_FILIAL,         Nil})
    AAdd(aCancBaixa, {"E1_PREFIXO", SE1->E1_PREFIXO,        Nil})
    AAdd(aCancBaixa, {"E1_NUM",     SE1->E1_NUM,            Nil})
    AAdd(aCancBaixa, {"E1_TIPO",    SE1->E1_TIPO,           Nil})
    AAdd(aCancBaixa, {"E1_PARCELA", SE1->E1_PARCELA,        Nil})
    AAdd(aCancBaixa, {"E1_CLIENTE", SE1->E1_CLIENTE,        Nil})
    AAdd(aCancBaixa, {"E1_LOJA",    SE1->E1_LOJA,           Nil})
    AAdd(aCancBaixa, {"AUTSEQ",     oTitulo["sequence"],    Nil})
    AAdd(aCancBaixa, {"AUTDTCAN",   oTitulo["date"],        Nil})

    If !(Empty(cHistorico))
        AAdd(aCancBaixa, {"AUTHIST", cHistorico, Nil})
    EndIf

    aCancBaixa := FwVetByDic(aCancBaixa, "SE1", .F.)

    MsExecAuto({|baixa, operacao| FinA070(baixa, operacao)}, aCancBaixa, nOperacao)

    If lMsErroAuto
        cMsgErro    := FinGetHelp()
        If Empty(cMsgErro)
            cMsgErro := STR0003 //"Erro não identificado na execução da rotina."
        EndIf
    EndIf

    FwFreeArray(aCancBaixa)

    AEval(aArea, {|area| RestArea(area)})

Return Empty(cMsgErro)

/*/{Protheus.doc} F136Prorrg
Rotina API para prorrogração do pagamento. Efetua a alteração do vencimento do título.

@type       Function
@author     Renato Ito
@since      20/03/20200
@version    P12.1.27
@param      oTitulo, object, objeto JSON contendo as informações do título
@param      cMsgErro, character, variável mensagem passada por referência
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Function F136Prorrg(oTitulo As J, cMsgErro As Character) As Logical

    Local aArea         As Array
    Local aTitutoAlt    As Array

    Local cHistorico    As Character

    Local nOperacao     As Numeric

    Default cMsgErro    := ""

    Private lMsErroAuto     As Logical
    Private lMsHelpAuto     As Logical
    
    lMsErroAuto     := .F.
    lMsHelpAuto     := .T.

    aArea       := {SE1->(GetArea()), GetArea()}
    aTitutoAlt  := {}
	dVencto		:= oTitulo["newDueDate"]
    nOperacao   := 4 //alateração
    
    If Empty(oTitulo["history"])
        cHistorico := STR0005 + DToC(SE1->E1_VENCTO) + STR0006 + DToC(dVencto) //"Prorrogação de " + {Data Anterior} + " para " + {Nova Data}
    Else
        cHistorico := oTitulo["history"]
    EndIf

	AAdd(aTitutoAlt, {"E1_FILIAL",  SE1->E1_FILIAL,     Nil})
    AAdd(aTitutoAlt, {"E1_PREFIXO", SE1->E1_PREFIXO,    Nil})
    AAdd(aTitutoAlt, {"E1_NUM",     SE1->E1_NUM,        Nil})
    AAdd(aTitutoAlt, {"E1_PARCELA", SE1->E1_PARCELA,    Nil})
    AAdd(aTitutoAlt, {"E1_TIPO",    SE1->E1_TIPO,       Nil})
    AAdd(aTitutoAlt, {"E1_CLIENTE", SE1->E1_CLIENTE,    Nil})
    AAdd(aTitutoAlt, {"E1_LOJA",    SE1->E1_LOJA,       Nil})
	AAdd(aTitutoAlt, {"E1_VENCTO",  dVencto,            Nil})
	AAdd(aTitutoAlt, {"AUTLOG",     cHistorico,         Nil}) //Complemento para o log de alteração
    
	aTitutoAlt := FwVetByDic(aTitutoAlt, "SE1", .F.)

    MsExecAuto({|aTitulo, operacao| FINA040(aTitulo, operacao)}, aTitutoAlt, nOperacao)

    If lMsErroAuto
        cMsgErro    := FinGetHelp()
        If Empty(cMsgErro)
            cMsgErro := STR0003 //"Erro não identificado na execução da rotina."
        EndIf
    ElseIf oTitulo["feeAmount"] > 0 //Realiza movimentação bancária da taxa da operação
        F136GerMov(oTitulo, @cMsgErro, oTitulo["feeAmount"])
    EndIf

    FwFreeArray(aTitutoAlt)

    AEval(aArea, {|area| RestArea(area)})

Return Empty(cMsgErro)
