#Include "FINI136O.ch"
#Include "Protheus.ch"

#Define OP_ANTECIPACAO              00 //Atualização de carteira - 0 para Carteira TOTVS Antecipa
#Define OP_BAIXA                    01 //Atualização de Título - Baixa
#Define OP_ESTORNO_BAIXA            02 //Atualização de Título - Estorno de Baixa
#Define OP_COOBRIGACAO              03 //Atualização de carteira - Carteira TOTVS Antecipa para 0
#Define OP_DIVERGENCIA_COMERCIAL    04 //Atualização de carteira - Carteira TOTVS Antecipa para 0
#Define OP_RECOMPRA                 08 //Atualização de carteira - Carteira TOTVS Antecipa para 0
#Define OP_PRORROGACAO              11 //Processo de prorrogação de vencimento 
#Define OP_BONIFICACAO              12 //Bonificação
#Define OP_DEVOLUCAO                13 //Compensação por Devolução
#Define OP_LIBERACAO_NCC            14 //Liberação de NCC - Atualização de carteira - Carteira TOTVS Devolução para 0
#Define OP_CONCILIACAO              20 //Conciliação Bancária
#Define OP_BATIMENTO_CARTEIRA       50 //Batimento de carteira

Static __aToken     As Array
Static aRespAuto    As Array
Static __cEndPoint  As Character
Static lAutomato    As Logical

/*/{Protheus.doc} FINI136O
Obter as notas para processamento.

@author     Rafael Riego
@version    1.0
@type       function
@since      05/12/2019
@param      aInfo, array, array contendo as informações da execução do job, sendo elas: 1-Empresa, 2-Filial
@param      oJSONAuto, J, utilizado para realizar processamento de um JSON informado. Criado para testes automatizados.
@return     array, retorna array com as respostas de cada requisição, sendo: 
            array[1] = platformId - id único da plataforma techfin
            array[2] = erpId - chave única do título a receber protheus
            array[3] = returnType (código de erro, sendo: 00 - processo com sucesso; 01 - erro de cadator de conta bancária;
                02 - erro técnico; 03 - erro pré processamento; 04 - erro pós processamento)
            array[4] = history - mensagem de erro
/*/
Function FINI136O(aInfo As Array, oJSONAuto As J) As Array

    Local aAreaSM0      As Array
    Local aBlocos       As Array
    Local aBatimento    As Array
    Local aHeader       As Array
    Local aOperacao     As Array
    Local aSM0          As Array
    Local aSM0Bkp       As Array

    Local bAntecipac    As Block

    Local bBaixa        As Block
    Local bBatimento    As Block
    Local bBonificac    As Block
    Local bCancelam     As Block
    Local bCompDevol    As Block
    Local bCoobrigac    As Block
    Local bEstrBaixa    As Block
    Local bLiberaNCC    As Block
    Local bProrrogac    As Block
    Local bConciliac    As Block

    Local cBody         As Character
    Local cChaveSE1     As Character
    Local cCodEmp       As Character
    Local cCodFil       As Character
    Local cErpIdDe      As Character
    Local cErpIdAte     As Character
    Local cFilBack      As Character
    Local cMensagem     As Character
    Local cCodErro      As Character
    Local cURLRac       As Character

    Local dDataBkp      As Date

    Local lBatimento    As Logical
    Local lJob          As Logical

    Local nLenSE1Chv    As Numeric 
    Local nNota         As Numeric
    Local nNotas        As Numeric
    Local nOperacAtu    As Numeric
    Local nParcela      As Numeric 
    Local nParcelas     As Numeric 
    Local nPosFil       As Numeric
    Local nTitulo       As Numeric
    Local nTitulos      As Numeric

    Local oJSON         As Object
    Local oRestClien    As Object 
    Local oTFConfig     As Object
    Local oTitulo       As Object

    //Default aInfo     := {"T1", "D MG 02 "} //<- base congelada
    Default aInfo       := {"", ""}
    Default oJSONAuto   := Nil

    SetFunName("FINI136O")

    FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", FwNoAccent(STR0078), 0, 0, {}) //"Iniciando execução Job TOTVS Antecipa."

    //Garante limpeza do array de resposta
    FwFreeArray(aRespAuto)

    __aToken    := {}
    aBatimento  := {}
    aBlocos     := {}
    aHeader     := {}
    aOperacao   := {}
    aRespAuto   := {}
    aSM0        := {}

    cChaveSE1   := ""
    cMensagem   := ""

    lJob        := (Type("cFilAnt") == "U")
    lAutomato   := ValType(oJSONAuto) == "J" //se teste automatizado

    nLenSE1Chv  := 0
    nNota       := 0
    nNotas      := 0
    nOperacAtu  := 0
    nTitulo     := 0
    nTitulos    := 0

    oJSON       := Nil
    oRestClien  := Nil
    oTitulo     := Nil
    oTFConfig   := Nil

    cCodEmp     := aInfo[1]
    cCodFil     := aInfo[2]

    //Se job e parâmetros em branco
    If lJob .And. (Empty(cCodEmp) .Or. Empty(cCodFil))
        FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0001 + STR0004,  0, 0, {}) // "FINI136O:" " Parâmetros 'cCodEmp' ou 'cCodFil' estão vazios."
        Return {{"", "", "02", STR0004}}
    ElseIf !lJob .And. !(Empty(cCodEmp)) .And. cEmpAnt != cCodEmp //Caso não seja execução via job, parametro empresa tenha sido informado e a empresa seja a mesma
        If IsBlind()
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0005, 0, 0, {}) //" Empresa atual difere da empresa informada por parâmetro."
        Else
            Help("", 1, "HELP", "HELP", STR0005 + STR0045, 1,,,,,,, {}) //" Empresa atual difere da empresa informada por parâmetro." " A rotina será encerrada."
        EndIf
        Return {{"", "", "02", STR0005}}
    EndIf

    //Verifica se a empresa está montada
    If lJob
        RpcSetEnv(cCodEmp, cCodFil, /*cUser*/, /*cPass*/, "FIN", FunName(), {"SA1", "SA6", "SE1", "SE5", "FKA", "FK1", "FK5", "FRV", "SEA"})
    EndIf

    //Efetua a trava para apenas efetuar um processamento por empresa
    If !(LockByName("FINI360JOB" + cEmpAnt))
        FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", STR0001 + STR0006, 0, 0, {}) //"FINI136O:" "JOB em execução."
        Return {{"", "", "02", STR0006}}
    EndIf

    //Efetua as validações de carteira, parâmetros de banco/agência/conta portador e motivo de baixa
    If !(F136VldCar(@cMensagem)) .Or. !(F136VlBcoP(@cMensagem)) .Or. !(F136VlMtBx(@cMensagem))
        If IsBlind()
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", cMensagem, 0, 0, {})
        Else
            Help("", 1, "HELP", "HELP", cMensagem, 1,,,,,,, {})
        EndIf
        Return {{"", "", "02", cMensagem}}
    EndIf

    bAntecipac  := {|parcela| FAntecipac(parcela)}  // F136AntAp
    bBaixa      := {|parcela| FBaixa(parcela)}      // F136Baixa
    bEstrBaixa  := {|parcela| FBaixa(parcela)}      // F136CancBx
    bCoobrigac  := {|parcela| FCancel(parcela)}     // F136Cancel
    bCancelam   := {|parcela| FCancel(parcela)}     // F136Cancel
    bRecompra   := {|parcela| FCancel(parcela)}     // F136Cancel
    bConciliac  := {|parcela| FConciliac(parcela)}  // F136MovBan
    bProrrogac	:= {|parcela| FProrrogac(parcela)} 	// F136Prorrg
    bBonificac  := {|parcela| FBonificac(parcela)}  // F136Bonifi
    bCompDevol  := {|parcela| FCompDevol(parcela)}  // F136Bonifi
    bLiberaNCC  := {|parcela| FLiberaNCC(parcela)}  // F136LibNCC
    bBatimento  := {|parcela| FBatimento(parcela)}  // F136BatAnt/F136BatRec/F136BatCon

    aOperacao   := {OP_ANTECIPACAO, OP_BAIXA, OP_ESTORNO_BAIXA, OP_COOBRIGACAO, OP_DIVERGENCIA_COMERCIAL, OP_RECOMPRA, OP_CONCILIACAO,;
        OP_PRORROGACAO,  OP_BONIFICACAO, OP_DEVOLUCAO, OP_LIBERACAO_NCC, OP_BATIMENTO_CARTEIRA}

    aBlocos     := {bAntecipac, bBaixa, bEstrBaixa, bCoobrigac, bCancelam, bRecompra, bConciliac,  bProrrogac, bBonificac, bCompDevol,;
        bLiberaNCC, bBatimento}
    
    aBatimento  := {OP_ANTECIPACAO, OP_RECOMPRA, OP_CONCILIACAO}

    aAreaSM0 := SM0->(GetArea())
    aSM0Bkp  := FWLoadSM0()
    AEval(aSM0Bkp, {|filial| IIf(filial[SM0_GRPEMP] == cEmpAnt, AAdd(aSM0, AClone(filial)), Nil)})
	FwFreeArray(aSM0Bkp)

    If !lAutomato
        oTFConfig := FwTFConfig()
        //Variavel que define o EndPoint de contado com a Plataforma 
        //Deve ser ajustado conforme a manutenção pois é por ele que iremos controlar a versão do JSON.
        __cEndPoint := oTFConfig["platform-endpoint"]
        cURLRac     := oTFConfig["rac-endpoint"]
    
        If Empty(__cEndPoint)
            cMensagem := STR0046 // "URL de acesso TOTVS Antecipa não pode estar em branco." 
        ElseIf Empty(cURLRac)
            cMensagem := STR0047 // "URL de autenticação TOTVS Antecipa não pode estar em branco"
        EndIf
        If !(Empty(cMensagem))
            If IsBlind()
                FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", cMensagem, 0, 0, {})
            Else
                Help("", 1, "HELP", "HELP", cMensagem, 1,,,,,,, {})
            EndIf
            Return {{"", "", "02", cMensagem}}
        EndIf
    EndIf

    dDataBkp := dDataBase

    //queryParam
    cErpIdDe    := cEmpAnt + "|              "
    cErpIdAte   := cEmpAnt + "|||||||||||||||"

    If !lAutomato
        //Recupera o token de autenticão
        __aToken := FinAuth()
        If !(__aToken[1] $ "200|201")
            cMensagem := __aToken[2] + IIf(Len(__aToken) >= 3, CRLF + __aToken[3], "")
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", cMensagem)
            Return {{"", "", "02", cMensagem}}
        EndIf

        AAdd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "Authorization: Bearer " + __aToken[2])

        oRestClien := FwRest():New(__cEndPoint)

        // Chamada da classe exemplo de REST com retorno de lista
        oRestClien:setPath("/integration/api/v2/bearers?ErpId.from=" +;
            Escape(cERPIdDe) + "&ErpId.to=" + Escape(cERPIdAte))
    EndIf

    Begin Sequence
        If !lAutomato
            If !(oRestClien:Get(aHeader))
                cMensagem := STR0001 + STR0002 + oRestClien:GetLastError() + IIf(!(Empty(oRestClien:cResult)), ": " + oRestClien:cResult, "")
                FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", cMensagem, 0, 0, {}) // "FINI136O: GET"
                Break
            EndIf

            //Obtém o JSON de entrada
            cBody := oRestClien:GetResult()
            oJSON := JSONObject():New()

            If ValType(oJSON:FromJSON(cBody)) == "C"
                FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0001 + STR0003, 0, 0, {}) //"FINI136O:" + "Formato JSON invalido."
                Break
            EndIf
        Else
            oJSON := oJSONAuto //Atribui apenas para manter variável oJSON
        EndIf

        nParcelas   := Len(oJSON)

        For nParcela := 1 To nParcelas
            If ValType(oJSON[nParcela]) != "J"
                FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0001 + STR0037, 0, 0, {}) // "FINI136O:" + " no invalido para o JSON."
                Loop
            EndIf

            lBatimento := .F.
            oTitulo    := oJSON[nParcela]

            cMensagem := F136VlJSON(oTitulo, oTitulo["operation"])

            If !(Empty(cMensagem))
                F136Respon({oTitulo["platformId"], oTitulo["erpId"], "02", cMensagem})
                Loop
            EndIf

            oTitulo["formattedErpId"] := FormatErpId(oTitulo["erpId"])

            If !(VldChvParc(oTitulo, @cCodErro, @cMensagem))
                F136Respon({oTitulo["platformId"], oTitulo["erpId"], cCodErro, cMensagem})
                Loop
            Else
                //Caso o título não seja encontrado a operação é alterada para batimento de carteira
                If ParcExiste(oTitulo, @cCodErro, @cMensagem)
                    If !(VldSituaca(oTitulo, @cCodErro, @cMensagem))
                        F136Respon({oTitulo["platformId"], oTitulo["erpId"], cCodErro, cMensagem})
                        Loop
                    EndIf
                Else
                    //Verifica se a operação efetua batimento caso não encontre o título
                    If AScan(aBatimento, oTitulo["operation"]) > 0
                        lBatimento := .T.
                        //guarda a operação anterior e atribui a nova na chave "operation"
                        oTitulo["oldOperation"] := oTitulo["operation"]
                        oTitulo["operation"] := OP_BATIMENTO_CARTEIRA
                    Else
                        cMensagem := STR0020 + oTitulo["erpId"] + STR0060 // "Parcela:" + " não encontrada."
                        F136Respon({oTitulo["platformId"], oTitulo["erpId"], "02", cMensagem})
                        Loop
                    EndIf
                EndIf
            EndIf

            If (nOperacAtu := AScan(aOperacao, oTitulo["operation"])) == 0
                cMensagem := STR0001 + STR0008 + CValToChar(oTitulo["operation"]) + STR0009 //"FINI136O: operacao '"## "' informada no JSON nao existente no ERP."
                F136Respon({oTitulo["platformId"], oTitulo["erpId"], "02", cMensagem})
                Loop
            EndIf

            //valida data antes para não setar o dDatabase de forma incorreta
            If ValType(oTitulo["date"]) == "C"
                oTitulo["date"] := SToD(oTitulo["date"])
                If Empty(oTitulo["date"])
                    F136Respon({oTitulo["platformId"], oTitulo["erpId"], "02", STR0007}) //"Formato inválido para a data informada."
                    Loop
                EndIf
            EndIf

            If dDataBase != oTitulo["date"]
                dDataBase := oTitulo["date"]
            EndIf

            oTitulo["history"] := SubStr(FwNoAccent(DecodeUTF8(IIf(oTitulo["history"] != Nil, AllTrim(oTitulo["history"]), ""))), 1, TamSX3("FK5_HISTOR")[1])

            cFilBack := cFilAnt

            //Caso seja batimento mantém a filial logada
            If !lBatimento
                cFilAnt := IIf(Empty(SE1->E1_FILORIG), cFilAnt, SE1->E1_FILORIG)
                nPosFil := Ascan(aSM0,{|sm0| sm0[SM0_CODFIL] == cFilAnt})
                SM0->(DbGoTo(aSM0[nPosFil,SM0_RECNO]))
            EndIf

            F136Start(aBlocos[nOperacAtu], oTitulo)
            //Restaura operação caso seja batimento de carteira
            If lBatimento
                oTitulo["operation"] := oTitulo["oldOperation"]
            EndIf
            cFilAnt     := cFilBack
            dDataBase   := dDataBkp
        Next nParcela
    End Sequence

    RestArea(aAreaSM0) 
    UnlockByName("FINI360JOB" + cEmpAnt)

    //Limpa array caso seja
    If !lAutomato
        FwFreeArray(aRespAuto)
        aRespAuto := {}
    EndIf

    //Reseta variável de automação
    lAutomato  := .F.

    FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", FwNoAccent(STR0079), 0, 0, {}) //"Encerrando execução Job TOTVS Antecipa."

    // Desconecta o ambiente
    If lJob
        RpcClearEnv()
    EndIf

    FreeObj(oRestClien)
    FreeObj(oTFConfig)

Return aRespAuto

/*/{Protheus.doc} F136Start
Validação das chaves do JSON por processo enviado.

@author     Rafael Riego
@version    1.0
@since      17/01/2020
@param      oTitulo, J, objeto JSON contendo as informações da parcela
@param      bFuncao, block, bloco a ser executado através do Eval
@return     array,  resposta referente ao processamento da parcela
/*/
Static Function F136Start(bFuncao As Block, oTitulo As J) As Array

    Local aRespAux      As Array
    Local aResposta     As Array

    Local lSucesso      As Logical

    aResposta   := {}
    aRespAux    := {}

    PrintLog(oTitulo, oTitulo["operationDescription"])

    Begin Transaction
        aRespAux := Eval(bFuncao, oTitulo) 
        lSucesso := aRespAux[1] == IIf(oTitulo["operation"] == OP_BATIMENTO_CARTEIRA .And. oTitulo["oldOperation"] == OP_ANTECIPACAO, "08", "00")
        If !lSucesso
            DisarmTransaction()
        EndIf
        aResposta := {oTitulo["platformId"], oTitulo["erpId"], aRespAux[1], aRespAux[2]}
        If !(F136Respon(aResposta))
            If lSucesso
                DisarmTransaction()
            EndIf
        EndIf
    End Transaction

    FwFreeArray(aRespAux)

Return aResposta

/*/{Protheus.doc} F136VlJSON
Validação das chaves do JSON por processo enviado.

@author     Rafael Riego
@version    1.0
@since      13/12/2019
@param      oTitulo, J, objeto JSON contendo as informações da parcela
@param      nOperation, numeric, operação em execução
@return     character, mensagem preenchida no caso de erro
/*/
Function F136VlJSON(oTitulo As J, nOperation As Numeric) As Character

    Local aChaves       As Array
    Local aChavesJS     As Array

    Local cMensagem     As Character
    Local cOpDescric    As Character
    Local cTaxHistor    As Character

    Local nChave        As Numeric
    Local nChaves       As Numeric

    Default nOperation   := 999999

    aChaves     := {"platformId", "erpId", "date", "operation"} //adicionar novas tags gerais caso necessário
    cMensagem   := ""
    cOpDescric  := ""
    cTaxHistor  := ""

    If ValType(oTitulo) == "J"
        aChavesJS := oTitulo:GetNames()

        If nOperation <> 999999
            If nOperation == OP_ANTECIPACAO
                AAdd(aChaves, "feeAmount")
                AAdd(aChaves, "localAmount")
                cTaxHistor := STR0080 //"TX ANTECIPA"
                cOpDescric := STR0043 //Antecipação
            ElseIf nOperation == OP_BAIXA
                AAdd(aChaves, "localAmount")
                cTaxHistor := "" //baixa não possui taxa de operação
                cOpDescric := STR0048 // "BAIXA"
            ElseIf nOperation == OP_ESTORNO_BAIXA
                AAdd(aChaves, "localAmount")
                cTaxHistor := "" //estorno de baixa não possui taxa de operação
                cOpDescric := STR0049 // "CANCELAMENTO DE BAIXA"
            ElseIf nOperation == OP_COOBRIGACAO
                AAdd(aChaves, "feeAmount")
                AAdd(aChaves, "localAmount")
                cTaxHistor := STR0053 //"TX COOBRIGA"
                cOpDescric := STR0081 //"Coobrigação"
            ElseIf nOperation == OP_DIVERGENCIA_COMERCIAL
                AAdd(aChaves, "feeAmount")
                AAdd(aChaves, "feeAmountOrigin")
                AAdd(aChaves, "localAmount")
                cTaxHistor := STR0054 //"TX DIVERCOM"
                cOpDescric := STR0082 //"Divergência Comercial"
            ElseIf nOperation == OP_RECOMPRA
                AAdd(aChaves, "feeAmount")
                AAdd(aChaves, "localAmount")
                cTaxHistor := STR0055 //"TX RECOMPRA"
                cOpDescric := STR0083 // "Recompra"
            ElseIf nOperation == OP_CONCILIACAO
                AAdd(aChaves, "bankCode")
                AAdd(aChaves, "agencyCode")
                AAdd(aChaves, "accountCode")
                AAdd(aChaves, "typeOperation")
                AAdd(aChaves, "localAmount")
                cTaxHistor := STR0084 //"TX CONCILIA"
                cOpDescric :=  STR0042 //"Conciliação"
            ElseIf nOperation == OP_PRORROGACAO
                AAdd(aChaves, "feeAmount")
                AAdd(aChaves, "newDueDate")
                cTaxHistor := STR0056 // "TX PRORROGA"
                cOpDescric := STR0058 // Prorrogação
            ElseIf nOperation == OP_BONIFICACAO
                AAdd(aChaves, "localAmount")
                AAdd(aChaves, "creditAmount")
                AAdd(aChaves, "discountAmount")
                AAdd(aChaves, "creditUnits")
                AAdd(aChaves, "feeAmount")
                cTaxHistor := STR0057 // "TX BONIFICA"
                cOpDescric := STR0059 // "Bonificação"
            ElseIf nOperation == OP_DEVOLUCAO
                AAdd(aChaves, "creditUnits")
                AAdd(aChaves, "localAmount")
                AAdd(aChaves, "feeAmountOrigin")
                AAdd(aChaves, "feeAmount")
                cTaxHistor := STR0070 // "TX DEVOLUC"
                cOpDescric := STR0071 // "Devolução"
            ElseIf nOperation == OP_LIBERACAO_NCC
                AAdd(aChaves, "localAmount")
                cTaxHistor := "" //liberação de NCC não possui taxa de operação
                cOpDescric := STR0085 //"Liberação de NCC"
            EndIf
        Else
            cMensagem := STR0001 + STR0012  //"FINI136O:" "Chave 'oparation' consta em branco no JSON."
        EndIf

        If Empty(cMensagem)
            nChaves := Len(aChaves)
               For nChave := 1 To nChaves
                 If !(AScan(aChavesJS, {|chave| chave == aChaves[nChave]}) > 0 .And. oTitulo[aChaves[nChave]] != Nil)
                    cMensagem += STR0013   + aChaves[nChave] + STR0014 + CRLF // "Chave '" "' nao encontrada." 
                EndIf
            Next nChave
            cMensagem := Left(cMensagem, Len(cMensagem) - 1)
        EndIf

        oTitulo["taxHistory"] := cTaxHistor
        oTitulo["operationDescription"] := cOpDescric

        FwFreeArray(aChaves)
        FwFreeArray(aChavesJS)
    Else
        cMensagem := STR0001 + STR0015  // "Layout do JSON inválido."
    EndIf

Return cMensagem

/*/{Protheus.doc} F136Respon
Executa o método de resposta para plataforma Techfin.

@author     Rafael Riego
@version    1.0
@since      11/12/2019
@param      aResponse, array, array com as informações a serem enviadas do processamento título a título
            aResponse[1] = platformId - id único da plataforma techfin
            aResponse[2] = erpId - chave única do título a receber protheus
            aResponse[3] = returnType (código de erro, sendo: 00 - processo com sucesso; 01 - erro de cadator de conta bancária;
                02 - erro técnico; 03 - erro pré processamento; 04 - erro pós processamento)
            aResponse[4] = history - mensagem de erro
@return     logical, se resposta foi enviada com sucesso ou não
/*/
Function F136Respon(aResponse As Array) As Logical

    Local aHeader   As Array

    Local cBody     As Character
    Local cJSON     As Character
    Local cErro     As Character
    Local lSucess   As Logical

    Local oResponse As Object
    Local oJSON     As Object

    Default aResponse   := {}

    lSucess     := .T.

    If Empty(aResponse)
        Return .F.
    ElseIf Len(aResponse) == 4
        FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", aResponse[4],  0, 0, {})

        If !lAutomato
            oResponse   := JSONObject():New()
            oResponse["platformId"]    := aResponse[1]
            oResponse["erpId"]         := aResponse[2]
            oResponse["returnType"]    := aResponse[3]
            oResponse["history"]       := aResponse[4]
            PrintLog(oResponse, "Response")
        Else
            AAdd(aRespAuto, AClone(aResponse)) //"Formato inválido para a data informada."
            Return .T.
        EndIf
    Else
        Return .F.
    EndIf

    aHeader     := {}

    oRestClien  := FwRest():New(__cEndPoint)

    __aToken := FinAuth()

    AAdd(aHeader, "Content-Type: application/json")
    AAdd(aHeader, "charset: UTF-8")
    AAdd(aHeader, "Authorization: Bearer " + __aToken[2])

    oRestClien := FwRest():New(__cEndPoint)

    // chamada da classe exemplo de REST com retorno de lista
    oRestClien:setPath("/integration/api/v2/bearers")

    cJSON := EncodeUTF8(oResponse:ToJSON())

    oRestClien:SetPostParams(cJSON)

    If !(oRestClien:Post(aHeader))
        cErro := IIf(oRestClien:GetResult() != Nil, oRestClien:GetResult(), "")
        FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0001 + STR0016 + oRestClien:GetLastError() + CRLF + cErro, 0, 0, {}) //"FINI136O: POST: "
        lSucess := .F.
    EndIf

    If lSucess .And. oRestClien:GetHTTPCode() == "201"
        // Obtem o JSon de entrada
        cBody := oRestClien:GetResult()
        FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", STR0001 + STR0018, 0, 0, {}) //"FINI136O: " +_ //"Sucesso na requisiçao."
        FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", cBody, 0, 0, {})
    Else
        cErro := IIf(oRestClien:GetResult() != Nil, oRestClien:GetResult(), "")
        FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0001 + STR0017 + CRLF + cErro, 0, 0, {}) // "FINI136O: Erro na requisição."

        lSucess := .F.
    EndIf

    FreeObj(oJSON)
    FreeObj(oResponse)
    FreeObj(oRestClien)

Return lSucess

/*/{Protheus.doc} FinAuth
Autentica e recupera o Token para comunicação com a plataforma 

@author     Pedro Castro
@version    1.0
@since      03/01/2020
@return     array, com o Token atualizado e data de validade apta para conexão
/*/
Static Function FinAuth() As Array

    Local aHeader       As Array

    Local cBody         As Character
    Local cEndPoint     As Character
    Local cFormParam    As Character
    Local cResultado    As Character

    Local dData         As Date

    Local nTempo        As Numeric

    Local oJSON         As Object
    Local oTFConfig     As Object

    aHeader   := {}
    
    If !(Empty(__aToken))
        If TimePass(__aToken[4], __aToken[5], __aToken[3])
            Return __aToken
        EndIf
    EndIf


    __aToken    := {}
    dData       := Date()
    nTempo      := Seconds()
    oTFConfig   := FwTFConfig()

    AAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")
    AAdd(aHeader, "charset: UTF-8")

    cFormParam := "client_id=" + oTFConfig["platform-clientId"] + "&"   //"client_id=5cfd983fbe5147e190448bcbfd9e4997&"
    cFormParam += "client_secret=" + oTFConfig["platform-secret"] + "&" //"client_secret=5d303f2fafbf42b7a18220fd7ded0a7f&"
    cFormParam += "grant_type=client_credentials&"
    cFormParam += "scope=authorization_api"

    cEndPoint := oTFConfig["rac-endpoint"]
    oRestClien := FwRest():New(cEndPoint)

    // Chamada da classe exemplo de REST com retorno de lista
    oRestClien:setPath("/totvs.rac/connect/token")//https://totvs.rac.dev.totvs.io/totvs.rac/connect/token
    oRestClien:SetPostParams(cFormParam)

    Begin Sequence
        If !(oRestClien:Post(aHeader))
            cResultado := IIf(oRestClien:GetResult() <> Nil, oRestClien:GetResult(), "")
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0019 + oRestClien:GetLastError(), 0, 0, {})   //"FINAuth Post"
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0019 + cResultado, 0, 0, {})      //"FINAuth Post"
            AAdd(__aToken, oRestClien:GetHTTPCode())
            AAdd(__aToken, oRestClien:GetLastError())
            cBody := oRestClien:GetResult()
            oJSON := JSONObject():New()

            If ValType(oJSON:FromJSON(cBody)) == "C"
                FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0003, 0, 0, {}) //Formato JSON inválido.
                Break
            EndIf
            AAdd(__aToken, oJSON["error"])
            Break
        EndIf

        // Obtém o JSON de entrada
        cBody := oRestClien:GetResult()

        oJSON := JSONObject():New()

        If ValType(oJSON:FromJSON(cBody)) == "C"
            FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", STR0003, 0, 0, {}) //Formato JSON inválido.
            AAdd(__aToken, "")
            AAdd(__aToken, STR0003)
            Break
        EndIf
        If !(Empty(oJSON["access_token"]))
            AAdd(__aToken, oRestClien:GetHTTPCode())
            AAdd(__aToken, oJSON["access_token"])
            AAdd(__aToken, oJSON["expires_in"])
            AAdd(__aToken, dData)
            AAdd(__aToken, nTempo)
        EndIf
    End Sequence

    FreeObj(oJSON)
    FreeObj(oRestClien)

Return __aToken

/*/{Protheus doc} TimePass
Verifica a validade do Token de autenticação.

@author     Pedro Castro
@since      03/01/2020
@param      dData, date, data do token
@param      nTempo, numeric, tempo do token
@param      nExpiresIn, numeric, validade do token
@return     Logical, Retorna falso caso o token tenha expirado
/*/
Static Function TimePass(dData As Date, nTempo As Numeric, nExpiresIn As Numeric) As Logical

    Local dDataAtual  As Date

    Local nExpires    As Numeric
    Local nTempoAtua  As Numeric
    Local nTempoPass  As Numeric

    dDataAtual := Date()
    nTempoAtua := Seconds()
    nExpires   := nExpiresIn - (nExpiresIn * 0.01) 

    If dDataAtual == dData
        nTempoPass := nTempoAtua - nTempo
        If nTempoPass > nExpires
            Return .F.
        EndIf
    EndIf

Return .T.

/*/{Protheus.doc} VldChvParc
Valida as informações referentes a parcela.

@author     Rafael Riego
@version    1.0
@since      02/06/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@param      cCodErro, character, código do erro (referência)
@param      cMsgErro, character, mensagem em caso de erro (referência)
@return     logical,  verdadeiro em caso de sucesso
/*/
Static Function VldChvParc(oParcela As J, cCodErro As Character, cMsgErro As Character) As Logical

    Local lOk   As Logical

    lOk := .T.

    If Len(SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)) != Len(oParcela["formattedErpId"])
        cCodErro := "02"
        cMsgErro := STR0010 // "Tamanho da chave 'erpId' informado não está correto."
        lOk := .F.
    EndIf

Return lOk

/*/{Protheus.doc} ParcExiste
Valida as informações referentes a parcela.

@author     Rafael Riego
@version    1.0
@since      02/06/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@param      cCodErro, character, código do erro (referência)
@param      cMsgErro, character, mensagem em caso de erro (referência)
@return     logical,  verdadeiro em caso de sucesso
/*/
Static Function ParcExiste(oParcela As J, cCodErro As Character, cMsgErro As Character) As Logical

    SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
    If !(SE1->(DbSeek(oParcela["formattedErpId"])))
        //cCodErro := "02"
        //cMsgErro := STR0011 // "Título não encontrado na base de dados."
        Return .F.
    EndIf

Return .T.

/*/{Protheus.doc} VldSituaca
Efetua as validações do título conforme a operação informada.

@author     Rafael Riego
@version    1.0
@since      02/06/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@param      cCodErro, character, código do erro (referência)
@param      cMsgErro, character, mensagem em caso de erro (referência)
@return     logical,  verdadeiro em caso de sucesso
/*/
Static Function VldSituaca(oParcela As J, cCodErro As Character, cMsgErro As Character) As Logical

    Local cCartTecF     As Character
    Local cCartDevol    As Character

    Default cCodErro    := ""
    Default cMsgErro    := ""

    cCartTecF   := F136Cartei("MV_CARTECF")

    If oParcela["operation"] == OP_ANTECIPACAO
        If SE1->E1_SITUACA == cCartTecF
            cMsgErro := STR0027 // "A nota informada já está na carteira TOTVS Antecipa."
            cCodErro := "03"
            Return .F.
        EndIf
    ElseIf oParcela["operation"] == OP_LIBERACAO_NCC
        cCartDevol  := F136Cartei("MV_DEVTECF")
        If SE1->E1_SITUACA != cCartDevol
            cMsgErro := STR0020 + SE1->E1_PARCELA + " " + STR0069 //"Parcela: " " não se encontra em carteira de devolução Techfin."
            cCodErro := "03"
            Return .F.
        EndIf
    ElseIf oParcela["operation"] != OP_CONCILIACAO
        If SE1->E1_SITUACA != cCartTecF
            cMsgErro := STR0020 + SE1->E1_PARCELA + " " + STR0021 //"Parcela: " "não se encontra em carteira Techfin."
            cCodErro := "03"
            Return .F.
        EndIf
    EndIf

Return .T.

/*/{Protheus.doc} FBaixa
Efetua a baixa ou o estorno da baixa da parcela informada.

@author     Rafael Riego
@version    1.0
@since      06/11/2019
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     Nil
/*/
Static Function FBaixa(oParcela as J) As Array

    Local aResposta     As Array

    Local cAgencia      As Character
    Local cAliasQry     As Character
    Local cBanco        As Character
    Local cConta        As Character
    Local cHistBaixa    As Character
    Local cMensagem     As Character

    Local lSucesso      As Logical

    Default oParcela    := {}

    cAgencia    := ""
    cAliasQry   := ""
    cBanco      := ""
    cConta      := ""
    cHistBaixa  := ""
    cMensagem   := ""
    lSucesso    := .T.

    Begin Sequence

        If oParcela["operation"] == OP_BAIXA
            If SE1->E1_SALDO == 0
                cMensagem := STR0022 //"Título se encontra com baixa total."
                aResposta := {"03", cMensagem}
                Break
            ElseIf oParcela["localAmount"] > SE1->E1_SALDO
                cMensagem := STR0023 //"Valor informado para baixa não pode ser maior do que o saldo do título."
                aResposta := {"03", cMensagem}
                Break
            EndIf
        Else //OP_ESTORNO_BAIXA
            cAliasQry := RetBaixas()
            //Verificar se existe baixa no valor informado
            While (cAliasQry)->(!(EoF()))
                cHistBaixa +=   STR0038 + (cAliasQry)->FK1_SEQ      + " | " +;          // SEQUENCIA: 
                                STR0039 + (cAliasQry)->FK1_DATA     + " | " +;          // "DATA: "
                                STR0040 + AllTrim(Transform((cAliasQry)->FK1_VALOR,;    // "VALOR: "
                                                        PesqPict("FK1", "FK1_VALOR"))) + CRLF
                
                If (cAliasQry)->FK1_VALOR == oParcela["localAmount"]
                    oParcela["sequence"] := (cAliasQry)->FK1_SEQ
                    Exit
                EndIf
                (cAliasQry)->(DbSkip())
            End
            (cAliasQry)->(DbCloseArea())

            If oParcela["sequence"] == Nil
                cMensagem := STR0041 + CRLF + CRLF + cHistBaixa // "Nenhuma baixa encontrada para o valor informado."
                aResposta := {"03", cMensagem}
                Break
            EndIf
        EndIf

        If oParcela["operation"] == OP_BAIXA
            lSucesso := F136Baixa(oParcela, @cMensagem)
        Else //oParcela["operation"] == OP_ESTORNO_BAIXA
            lSucesso := F136CancBx(oParcela, @cMensagem)
        EndIf

        aResposta := {IIf(lSucesso,"00","04"), cMensagem}

    End Sequence

Return aResposta

/*/{Protheus.doc} RetBaixas
Efetua a baixa ou o estorno da baixa da parcela informada.

@author     Rafael Riego
@version    1.0
@since      09/01/2019
@param      oParcela, J, objeto JSON contendo as informações da parcela
@param      cChaveSE1, character, chave do título a receber
@return     Nil
/*/
Static Function RetBaixas(cChaveSE1 As Character) As Character

    Local cAliasFK1 As Character
    Local cChaveFK7 As Character
    Local cQuery    As Character

    Default cChaveSE1 := FwXFilial("SE1", SE1->E1_FILORIG) + "|" +;
                    SE1->E1_PREFIXO     + "|" +;
                    SE1->E1_NUM         + "|" +;
                    SE1->E1_PARCELA     + "|" +;
                    SE1->E1_TIPO        + "|" +;
                    SE1->E1_CLIENTE     + "|" +;
                    SE1->E1_LOJA

    cAliasFK1   := GetNextAlias()
    cChaveFK7   := FinBuscaFK7(cChaveSE1, "SE1")

    cQuery := "SELECT * " 
    cQuery += " FROM " + RetSQLName("FK1") + " FK1"
    cQuery += " WHERE "
    cQuery += " FK1.FK1_FILIAL = '" + FwXFilial("FK1") + "' " 
    cQuery += " AND FK1.FK1_IDDOC = '" + cChaveFK7 + "' " 
    cQuery += " AND FK1.D_E_L_E_T_ = ' ' "
    cQuery += " AND NOT EXISTS( "
    cQuery += "     SELECT FK1EST.FK1_IDDOC FROM " + RetSQLName("FK1") +" FK1EST"
    cQuery += "     WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL"
    cQuery += "     AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
    cQuery += "     AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
    cQuery += "     AND FK1EST.FK1_DOC = FK1.FK1_DOC "
    cQuery += "     AND FK1EST.FK1_TPDOC = 'ES' "
    cQuery += "     AND FK1EST.D_E_L_E_T_ = ' ') "
    cQuery += " ORDER BY FK1_SEQ DESC"

    cQuery := ChangeQuery(cQuery)

    MPSysOpenQuery(cQuery, cAliasFK1)

Return cAliasFK1

/*/{Protheus.doc} FConciliac
Efetua a conciliação bancária entre o banco portador e o banco informado Techfin (crédito ou d).

@author     Rafael Riego
@version    1.0
@since      07/01/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     array, resultado do processamento no formato {código do resultado, mensagem de erro}
/*/
Static Function FConciliac(oParcela As J) As Array

    Local aResposta     As Array
    Local aInfoBanco    As Array

    Local cAgencia      As Character
    Local cConta        As Character
    Local cMensagem     As Character
    Local cPortador     As Character

    Local lSucesso      As Logical

    Default oParcela    := Nil

    AjustBco(oParcela)

    aResposta   := {}
    cAgencia    := oParcela["agencyCode"]
    cConta      := oParcela["accountCode"]
    cMensagem   := ""
    cPortador   := oParcela["bankCode"]
    lSucesso    := .T.
    aInfoBanco  := F136AJstBc()

    If Empty(oParcela["typeOperation"])
        cMensagem := STR0024 //"Operação não preenchida!"
        aResposta := {"02", cMensagem}
    ElseIf !(SA6->(DbSeek(FwXFilial("SA6") + cPortador + cAgencia + cConta)))
        cMensagem := STR0025 //"O banco enviado não esta cadastrado"
        aResposta := {"01", cMensagem}
    ElseIf SA6->A6_COD  + SA6->A6_AGENCIA + SA6->A6_NUMCON == aInfoBanco[1] + aInfoBanco[2] + aInfoBanco[3]
        cMensagem := STR0050 // "O Banco informado não pode ser igual ao Banco contido nos parâmetros TOTVS Antecipa"
        aResposta := {"02", cMensagem}
    Else
        oParcela["expenseClass"] := SE1->E1_NATUREZ
        oParcela["revenueClass"] := SE1->E1_NATUREZ

        lSucesso := F136MovBan(oParcela, @cMensagem)

        aResposta := {IIf(lSucesso, "00", "04"), cMensagem}
    EndIf

Return aResposta

/*/{Protheus.doc} FAntecipac
Processar a antecipação das parcelas das notas fiscais.

@author     Rafael Riego
@version    1.0
@since      05/11/2019
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     array, resultado do processamento no formato {código do resultado, mensagem de erro}
/*/
Static Function FAntecipac(oParcela As J) As Array

    Local aResposta As Array

    Local cMensagem As Character
    Local cRetType  As Character

    Local lSucesso  As Logical

    aResposta   := {}
    cMensagem   := ""
    cRetType    := "04"
    lSucesso    := .T.

    Default oParcela    := Nil

    If !(Empty(SE1->E1_BAIXA))
        cMensagem := STR0026 //"O saldo em aberto da nota fiscal está diferente do seu valor original. A nota será recomprada automaticamente pelo TOTVS Antecipa."
        aResposta := {"05", cMensagem}
    Else
        lSucesso := F136AntAp(oParcela, @cMensagem, @cRetType)

        aResposta := {IIf(lSucesso, "00", cRetType), cMensagem}
    EndIf

Return aResposta

/*/{Protheus.doc} FCancel
Processa uma parcela de cancelamento.

@author     Rafael Riego
@version    1.0
@since      05/11/2019
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     array, resultado do processamento no formato {código do resultado, mensagem de erro}
/*/
Static Function FCancel(oParcela As J) As Array

    Local aResposta     As Array

    Local cMensagem     As Character

    Local lSucesso  As Logical

    Default oParcela    := {}

    aResposta   := {}
    lSucesso    := .T.

    If !(Empty(SE1->E1_BAIXA)) .And. SE1->E1_SALDO == 0
        cMensagem := STR0028 //"Não é possível realizar o cancelamento de um título que já possua baixa total"
        aResposta := {"03", cMensagem}
    Else
        lSucesso := F136Cancel(oParcela, @cMensagem)

        aResposta := {IIf(lSucesso, "00", "04"), cMensagem}
    EndIf

Return aResposta

/*/{Protheus.doc} FProrrogac
Processo de prorrogação de vencimento.

@author     Renato Ito
@version    1.0
@since      20/03/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     array, resultado do processamento no formato {código do resultado, mensagem de erro}
/*/
Static Function FProrrogac(oParcela As J) As Array

    Local aResposta As Array

    Local cMensagem As Character

    Local lSucesso  As Logical

    aResposta   := {}
    lSucesso    := .T.
    cMensagem   := ""

    //valida data do vencimento para não setar de forma incorreta
    If Empty(aResposta)
        If ValType(oParcela["newDueDate"]) == "C"
            oParcela["newDueDate"] := SToD(oParcela["newDueDate"])
            If Empty(oParcela["newDueDate"])
                aResposta := {"02", "newDueDate -> " +  STR0007} //"Formato inválido para a data informada."
            EndIf
        EndIf
    EndIf

    If Empty(aResposta)
        //Verifica se o novo vencimento já está no título
        If oParcela["newDueDate"] == SE1->E1_VENCTO
            aResposta := {"03", STR0051} //"Vencimento enviado é o mesmo do título.
        Else
            lSucesso := F136Prorrg(oParcela, @cMensagem)
            aResposta := {IIf(lSucesso, "00", "04"), cMensagem}
        EndIf
    EndIf

Return aResposta

/*/{Protheus.doc} FBonificac
Processa uma parcela de bonificação.

@author     Rafael Riego
@version    1.0
@since      29/04/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     array, resultado do processamento no formato {código do resultado, mensagem de erro}
/*/
Static Function FBonificac(oParcela As J) As Array

    Local aArea     As Array
    Local aResposta As Array

    Local cMensagem As Character

    Local lSucesso  As Logical

    Local nNCC      As Numeric
    Local nValorNCC As Numeric

    aArea       := {SE1->(GetArea()), GetArea()}
    aResposta   := {}
    cMensagem   := ""
    lSucesso    := .T.
    nValorNCC   := 0

    //Valida as informações do título principal
    If SE1->E1_SALDO == 0
        cMensagem += STR0020 + oParcela["erpId"] + STR0062 + CRLF // " não possui saldo."
    ElseIf SE1->E1_SALDO < oParcela["localAmount"]
        cMensagem := STR0064 + CValToChar(SE1->E1_SALDO) // "Valor da soma da Nota de Crédito e Desconto não pode ser maior que o saldo do título. Saldo: "
    Else
        SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
        For nNCC := 1 To Len(oParcela["creditUnits"])
            oParcela["creditUnits"][nNCC]["formattedErpId"] := FormatErpId(oParcela["creditUnits"][nNCC]["creditErpId"])
            If !(SE1->(DbSeek(oParcela["creditUnits"][nNCC]["formattedErpId"])))
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0060 + CRLF // " não encontrada."
            ElseIf !(SE1->(SimpleLock()))
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0068 + CRLF // " está em uso por outra rotina do sistema."
            ElseIf !(SE1->E1_TIPO == "NCC")
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0061 + CRLF // " não é do tipo NCC."
            ElseIf SE1->E1_SALDO == 0
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0062 + CRLF // " não possui saldo."
                //Parcela sem saldo
            ElseIf SE1->E1_SALDO < oParcela["creditUnits"][nNCC]["creditAmount"]
                //Saldo da parcela inferior ao valor de crédito
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0063 + CRLF // " possui saldo inferior ao valor de crédito informado."
            EndIf
            oParcela["creditUnits"][nNCC]["recordId"] := SE1->(RecNo())
            nValorNCC += oParcela["creditUnits"][nNCC]["creditAmount"]
        Next nNCC
    EndIf

    //Restaura o título principal para complementar as validações
    AEval(aArea, {|area| RestArea(area)})

    If !(Empty(cMensagem))
        aResposta := {"03", cMensagem}
    ElseIf oParcela["creditAmount"] != nValorNCC
        aResposta := {"03", STR0065} // "Inconsistência na soma dos valores das Notas de Crédito Cliente informadas"
    ElseIf oParcela["localAmount"] != nValorNCC + oParcela["discountAmount"]
        aResposta := {"03", STR0065} // "Inconsistência na soma dos valores das Notas de Crédito Cliente informadas"
    Else
        lSucesso := F136Bonifi(oParcela, @cMensagem)
        aResposta := {IIf(lSucesso, "00", "04"), cMensagem}
    EndIf

    //Garante a liberação de todos os registros bloqueados
    For nNCC := 1 To Len(oParcela["creditUnits"])
        //Caso não tenha criado a chave recordId não executa o trecho abaixo
        If oParcela["creditUnits"][nNCC]["recordId"] != Nil
            SE1->(DbGoTo(oParcela["creditUnits"][nNCC]["recordId"]))
            SE1->(MsUnlock())
        EndIf
    Next nNCC

    AEval(aArea, {|area| RestArea(area)})

Return aResposta

/*/{Protheus.doc} FCompDevol
Processa uma compensação através de uma devolução.

@author     Rafael Riego
@version    1.0
@since      29/04/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     array, resultado do processamento no formato {código do resultado, mensagem de erro}
/*/
Static Function FCompDevol(oParcela As J) As Array

    Local aArea     As Array
    Local aResposta As Array

    Local cMensagem As Character
    Local cCartDev  As Character

    Local lSucesso  As Logical

    Local nNCC      As Numeric
    Local nValorNCC As Numeric

    aArea       := {SE1->(GetArea()), GetArea()}
    aResposta   := {}
    cCartDev    := F136Cartei("MV_DEVTECF")
    cMensagem   := ""
    lSucesso    := .T.
    nValorNCC   := 0

    //Valida as informações do título principal
    If SE1->E1_SALDO == 0
        cMensagem += STR0020 + oParcela["erpId"] + STR0062 + CRLF // " não possui saldo."
    Else
        SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
        For nNCC := 1 To Len(oParcela["creditUnits"])
            oParcela["creditUnits"][nNCC]["formattedErpId"] := FormatErpId(oParcela["creditUnits"][nNCC]["creditErpId"])
            If !(SE1->(DbSeek(oParcela["creditUnits"][nNCC]["formattedErpId"])))
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0060 + CRLF // " não encontrada."
            ElseIf !(SE1->(SimpleLock()))
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0068 + CRLF // " está em uso por outra rotina do sistema."
            ElseIf !(SE1->E1_TIPO == "NCC")
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0061 + CRLF // " não é do tipo NCC."
            ElseIf SE1->E1_SALDO == 0
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0062 + CRLF // " não possui saldo."
                //Parcela sem saldo
            ElseIf SE1->E1_SALDO < oParcela["creditUnits"][nNCC]["creditAmount"]
                //Saldo da parcela inferior ao valor de crédito
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + STR0063 + CRLF // " possui saldo inferior ao valor de crédito informado."
            ElseIf SE1->E1_SITUACA != cCartDev
                cMensagem += STR0020 + oParcela["creditUnits"][nNCC]["creditErpId"] + " " + STR0069 + CRLF //"Parcela: " "não se encontra em carteira Techfin."
            EndIf
            oParcela["creditUnits"][nNCC]["recordId"] := SE1->(RecNo())
            nValorNCC += oParcela["creditUnits"][nNCC]["creditAmount"]
        Next nNCC
    EndIf

    //Restaura o título principal para complementar as validações
    AEval(aArea, {|area| RestArea(area)})

    If !(Empty(cMensagem))
        aResposta := {"03", cMensagem}
    ElseIf oParcela["localAmount"] != nValorNCC
        aResposta := {"03", STR0065} // "Inconsistência na soma dos valores das Notas de Crédito Cliente informadas"
    ElseIf SE1->E1_SALDO < oParcela["localAmount"]
        aResposta := {"03", STR0020 + oParcela["erpId"] + STR0063 + " " + STR0076 + CValToChar(SE1->E1_SALDO)}//"Parcela: " " possui saldo inferior ao valor de crédito informado." "Saldo: "
    Else 
        lSucesso := F136Bonifi(oParcela, @cMensagem)
        aResposta := {IIf(lSucesso, "00", "04"), cMensagem}
    EndIf

    //Garante a liberação de todos os registros bloqueados
    For nNCC := 1 To Len(oParcela["creditUnits"])
        //Caso não tenha criado a chave recordId não executa o trecho abaixo
        If oParcela["creditUnits"][nNCC]["recordId"] != Nil
            SE1->(DbGoTo(oParcela["creditUnits"][nNCC]["recordId"]))
            SE1->(MsUnlock())
        EndIf
    Next nNCC

    AEval(aArea, {|area| RestArea(area)})

Return aResposta

/*/{Protheus.doc} FLiberaNCC
Processa uma parcela para liberação de NCC (devolução para carteira 0).

@author     Rafael Riego
@version    1.0
@since      29/04/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     array, resultado do processamento no formato {código do resultado, mensagem de erro}
/*/
Static Function FLiberaNCC(oParcela As J) As Array

    Local aArea     As Array
    Local aResposta As Array

    Local cMensagem As Character
    Local cRetType  As Character

    Local lSucesso  As Logical

    aArea       := {SE1->(GetArea()), GetArea()}
    aResposta   := {}
    cRetType    := ""
    cMensagem   := ""
    lSucesso    := .T.

    //Se existir diferença no saldo da NCC com o 
    If !(SE1->E1_TIPO == "NCC")
        cMensagem   := STR0020 + oParcela["erpId"] + STR0061 + CRLF // " não é do tipo NCC."
    ElseIf SE1->E1_SALDO != oParcela["localAmount"]
        cRetType    := "09"
        cMensagem   := STR0020 + oParcela["erpId"] + STR0077 + STR0076 + CValToChar(SE1->E1_SALDO) //"Parcela: " " Saldo da NCC não confere. " "Saldo: "
    EndIf

    If Empty(cMensagem)
        lSucesso := F136LibNCC(oParcela, @cMensagem)
        aResposta := {IIf(lSucesso, "00", "04"), cMensagem}
    Else
        aResposta := {IIf(Empty(cRetType), "03", cRetType), cMensagem}
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return aResposta

/*/{Protheus.doc} FBatimento
Processa uma parcela para efetuar batimento de carteira para as operações de antecipação, recompra e conciliação.

@author     Rafael Riego
@version    1.0
@since      03/06/2020
@param      oParcela, J, objeto JSON contendo as informações da parcela
@return     array, resultado do processamento no formato {código do resultado, mensagem de erro}
/*/
Static Function FBatimento(oParcela)

    Local aArea     As Array
    Local aResposta As Array

    Local cMensagem As Character
    Local cRetType  As Character

    Local lRetorno  As Logical

    aArea       := {GetArea()}
    aResposta   := {}
    cRetType    := ""
    cMensagem   := ""
    lRetorno    := .T.

    If oParcela["oldOperation"] == OP_ANTECIPACAO
        lRetorno := F136BatAnt(oParcela, @cMensagem, @cRetType)
    ElseIf oParcela["oldOperation"] == OP_RECOMPRA
        lRetorno := F136BatRec(oParcela, @cMensagem)
    ElseIf oParcela["oldOperation"] == OP_CONCILIACAO
        oParcela["expenseClass"] := F136VerNat(3) //despesa
        oParcela["revenueClass"] := F136VerNat(4) //receita
        lRetorno := F136BatCon(oParcela, @cMensagem)
    EndIf

    If lRetorno
        aResposta := {IIf(Empty(cRetType), "00", cRetType), cMensagem}
    Else
        aResposta := {"04", cMensagem}
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return aResposta

/*/{Protheus.doc} F136VlBcoP
Validação do preenchimento dos parâmetros referentes a Banco/Agência/Conta portador e a existência do registro na SA6.

@type       Function
@author     Rafael Riego
@since      27/11/2019
@version    P12.1.27
@param      cMensagem, character, mensagem de erro obtida através do help
@return     logical, Verdadeiro caso os dados estejam preenchidos e sejam válidos.
/*/
Function F136VlBcoP(cMensagem As Character) As Logical//F136ValidaBancoPonte() As Logical

    Local aArea         As Array
    Local aInfoBanco    As Array

    Local cAgenPorta    As Character
    Local cBancPorta    As Character
    Local cContPorta    As Character

    Default cMensagem   := ""

    aArea       := {SA6->(GetArea(), GetArea())}
    aInfoBanco  := F136AJstBc()
    cBancPorta  := aInfoBanco[1]
    cAgenPorta  := aInfoBanco[2]
    cContPorta  := aInfoBanco[3]

    SA6->(DbSetOrder(1))
    If Empty(cAgenPorta)
        Help("", 1, "HELP", "HELP", STR0029, 1,,,,,,, {})  //"Agência Portador (MV_AGETECF) não pode estar branco." 
    ElseIf Empty(cBancPorta)
        Help("", 1, "HELP", "HELP", STR0030, 1,,,,,,, {})  //"Banco Portador (MV_BCOTECF) não pode estar branco."
    ElseIf Empty(cContPorta)
        Help("", 1, "HELP", "HELP", STR0031, 1,,,,,,, {})  //"Conta Portador (MV_CTNTECF) não pode estar branco."
    ElseIf !(SA6->(DbSeek(FwXFilial("SA6") + cBancPorta + cAgenPorta + cContPorta)))
        Help("", 1, "HELP", "HELP", STR0032, 1,,,,,,, {})  //"Banco Portador não encontrado no ERP."
    ElseIf SA6->A6_BLOCKED == "1" // Banco bloqueado, força o desbloqueio.
        RecLock("SA6",.F.)
        SA6->A6_BLOCKED := "2" 
        SA6->A6_DTBLOQ  := CTOD("  /  /  ")
        MsUnlock()
    EndIf

    cMensagem := FinGetHelp()

    AEval(aArea, {|area| RestArea(area)})

Return Empty(cMensagem)

/*/{Protheus.doc} F136VldCar
Validação do preenchimento dos parâmetros MV_CARTECF e MV_DEVTECF e validação da existência da carteira.

@type       Function
@author     Rafael Riego
@since      27/11/2019
@version    P12.1.27
@param      cMesangem, character, mensagem de erro que deve ser passada por referência
@return     logical, Verdadeiro caso a carteira seja válida.
/*/
Function F136VldCar(cMensagem As Character) As Logical //F136ValidaCarteiraTechFin() As Logical

    Local aArea         As Array
    Local aFinParam     As Array 

    Local cCartDev      As Character
    Local cCartTecF     As Character

    Default cMensagem   := ""

    aArea       := {FRV->(GetArea()), GetArea()}
    aFinParam   := Array(7)
    cCartTecF   := F136Cartei("MV_CARTECF")
    cCartDev    := F136Cartei("MV_DEVTECF")

    //Verifica se carteira techfin está preenchida
    If Empty(cCartTecF)
        cMensagem := STR0033 //"Carteira Techfin deve estar preenchida (MV_CATRTECF)."
    Else
        DbSelectArea("FRV")
        FRV->(DbSetOrder(1))
        If FRV->(MsSeek(FwXFilial("FRV") + cCartTecF))
            If !(FRV->FRV_BANCO == "1")
                cMensagem := STR0034 //"Carteira Techfin deve utilizar Banco. (FRV_BANCO = '1')."
            ElseIf !(FRV->FRV_DESCON == "1")
                cMensagem := STR0035 //"Carteira Techfin deve ser do tipo 'Descontada' (FRV_DESCON = '1')."
            EndIf
        Else
            aFinParam[1] := cCartTecF
            aFinParam[2] := STR0072 + " TOTVS ANTECIPA" //CARTEIRA  
            aFinParam[3] := "1" //FRV_BANCO
            aFinParam[4] := "1" //FRV_DESCON
            aFinParam[5] := "2" //FRV_PROTES 
            aFinParam[6] := "1" //FRV_BLQMOV
            aFinParam[7] := "2" //FRV_SITPDD

            If !(FTFWGrvFRV(aFinParam))
                cMensagem := STR0036 //"Carteira Techfin não encontrada no sistema."
            EndIf 
        EndIf
    EndIf

    If Empty(cMensagem)
        If Empty(cCartDev)
            cMensagem := STR0073 // "Carteira Devolução Antecipa deve estar preenchida (MV_DEVTECF)."
        Else
            DbSelectArea("FRV")
            FRV->(DbSetOrder(1))
            If FRV->(MsSeek(FwXFilial("FRV") + cCartDev))
                If !(FRV->FRV_BANCO == "2")
                    cMensagem := STR0074 // "Carteira Devolução TOTVS Antecipa não deve utilizar Banco. (FRV_BANCO = '2')."
                ElseIf !(FRV->FRV_DESCON == "2")
                    cMensagem := STR0075 // "Carteira Devolução TOTVS Antecipa não pode ser do tipo 'Descontada' (FRV_DESCON = '1')."
                EndIf
            Else
                aFinParam[1] := cCartDev
                aFinParam[2] := STR0072 + Upper(STR0071) + " TOTVS ANTECIPA"  //"CARTEIRA DEVOLUCAO"
                aFinParam[3] := "2" //FRV_BANCO
                aFinParam[4] := "2" //FRV_DESCON
                aFinParam[5] := "2" //FRV_PROTES 
                aFinParam[6] := "1" //FRV_BLQMOV
                aFinParam[7] := "2" //FRV_SITPDD

                If !(FTFWGrvFRV(aFinParam))
                    cMensagem := STR0036 //"Carteira Techfin não encontrada no sistema."
                EndIf 
            EndIf
        EndIf
    EndIf

    If !(Empty(cMensagem))
        Help("", 1, "HELP", "HELP", cMensagem, 1,,,,,,, {})
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return Empty(cMensagem)

/*/{Protheus.doc} F136VlMtBx
Validação do preenchimento do parâmetro MV_MOTTECF e validação da existência da carteira.

@type       Function
@author     Rafael Riego
@since      11/05/2020
@version    P12.1.27
@param      cMesangem, character, mensagem de erro que deve ser passada por referência
@return     logical, Verdadeiro caso o motivo de baixa seja válido.
/*/
Function F136VlMtBx(cMensagem As Character) As Logical //F136ValidaMotivoDeBaixaTechfin() As Logical

    Local aArea         As Array

    Local cMotBaixa     As Character

    Default cMensagem   := ""

    aArea       := {GetArea()}
    cMensagem   := ""
    cMotBaixa   := FTUpdMotBx(SuperGetMV("MV_MOTTECF", .F., ""))

    //Verifica se carteira techfin está preenchida
    If Empty(cMotBaixa)
        cMensagem := STR0066 // "Motivo de Baixa Antecipa deve estar preenchido (MV_MOTTECF)."
    ElseIf Empty(BuscaMotBx(cMotBaixa))
        //Grava motivo de baixa caso não exista
        If !(FTGrvMotBx("ANT", "ANTECIPA  "))
            cMensagem := FinGetHelp()
        Else
            PutMV("MV_MOTTECF", "ANT")
            FTUpdMotBx("ANT")
        EndIf
    EndIf

    If !(Empty(cMensagem))
        Help(Nil, Nil, "Motivo Baixa", "", cMensagem, 1,,,,,,, {})
    EndIf

    AEval(aArea, {|area| RestArea(area)})

Return Empty(cMensagem)

/*/{Protheus.doc} FinGetHelp
Retorna o texto do último Help executado e limpa o buffer.

@type       Function
@author     Rafael Riego
@since      27/11/2019
@version    P12.1.27
@return     character, texto do último help executado
/*/
Function FinGetHelp() As Character

    Local aHelp     As Array

    Local cProblema As Character

    Local nProblem  As Numeric

    aHelp     := {}
    cProblema := ""
    nProblem  := 0

    aHelp := FwGetUltHlp()

    If (ValType(aHelp) == "A") .And. (Len(aHelp) == 3)
        For nProblem := 1 To Len(aHelp[2])
            If !(Empty(cProblema))
                cProblema += " "
            EndIf
            cProblema += AllTrim(aHelp[2][nProblem])
        Next nProblem
    EndIf

    //Limpa último help executado
    FwClearHlp()
    
Return cProblema

/*/{Protheus.doc} AjustBco
Ajusta as chaves agencyCode, accountCode e bankCode dentro do JSON. 

@type       Function
@author     Rafael Riego
@since      10/01/2019
@version    P12.1.27
@param      oJSON, J, título a ser ajustado
@return     Nil
/*/
Static Function AjustBco(oJSON) //parametro por referencia

    Default oJSON := Nil

    If !(oJSON == Nil)
        oJSON["agencyCode"]  := PadR(oJSON["agencyCode"],    TamSX3("A6_AGENCIA")[1])
        oJSON["accountCode"] := PadR(oJSON["accountCode"],   TamSX3("A6_NUMCON")[1])
        oJSON["bankCode"]    := PadR(oJSON["bankCode"],      TamSX3("A6_COD")[1])
    EndIf

Return Nil

/*/{Protheus.doc} PrintLog
Exibe no console as informações do JSON da parcela que está sendo executada.

@type       Function
@author     Rafael Riego
@since      15/01/2019
@version    P12.1.27
@param      oJSON, J, JSON a ser exibido no log
@param      cRotina, character, nome da rotina que está sendo executada 
@return     Nil
/*/
Static Function PrintLog(oJSON As J, cRotina As Character)

    Local cLogMsg   As Character

    Default oJSON   := Nil
    Default cRotina := ""

    aChaves := {}
    cLogMsg := ""
    cTipo   := ""
    nChave  := 0
    nChaves := 0

    If ValType(oJSON) == "J"
        cLogMsg := CRLF + "[" + FwNoAccent(cRotina) + "]" //Ex.: Antecipação/Recompra/Concialiação/Conciliação/Resposta
        cLogMsg += ReadJSON(oJSON)
        FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", cLogMsg, 0, 0, {})
    EndIf

Return Nil

/*/{Protheus.doc} ReadJSON
Exibe no console as informações do JSON da parcela que está sendo executada.

@type       Function
@author     Rafael Riego
@since      26/05/2019
@version    P12.1.27
@param      oJSON, J, JSON a ser exibido no log
@return     character, json simplicado para impressão
/*/
Static Function ReadJSON(oJSON As J) As Character

    Local aChaves   As Array

    Local cLogMsg   As Character
    Local cTipo     As Character

    Local nArray    As Numeric
    Local nChave    As Numeric
    Local nChaves   As Numeric

    Default oJSON := Nil

    cLogMsg := ""
    aChaves := oJSON:GetNames()
    nChaves := Len(aChaves)

    For nChave := 1 To nChaves
        cTipo   := ValType(oJSON[aChaves[nChave]])
        If cTipo == "A"
            cLogMsg += CRLF + aChaves[nChave] + ":"
            For nArray := 1 To Len(oJSON[aChaves[nChave]])
                If ValType(oJSON[aChaves[nChave]][nArray]) == "J"
                    cLogMsg += CRLF + aChaves[nChave] + "[" + CValToChar(nArray) +  "]: {"
                    cLogMsg += ReadJSON(oJSON[aChaves[nChave]][nArray])         
                    cLogMsg += "}"
                EndIf
            Next nArray
        Else
            cLogMsg += CRLF + aChaves[nChave] + ": "
            If cTipo == "C"
                If aChaves[nChave] == "history"
                    cLogMsg += FwNoAccent(oJSON[aChaves[nChave]])
                Else
                    cLogMsg += oJSON[aChaves[nChave]]
                EndIf
            ElseIf cTipo == "D"
                cLogMsg += DToC(oJSON[aChaves[nChave]])
            ElseIf cTipo == "N"
                cLogMsg += CValToChar(oJSON[aChaves[nChave]])
            ElseIf cTipo == "J"
                cLogMsg += ReadJSON(oJSON[aChaves[nChave]])
            EndIf
        EndIf
    Next nChave

Return cLogMsg

/*/{Protheus.doc} FormatErpId
Realiza a formatação da chave do título para uso no ERP.

@type       Function
@author     Rafael Riego
@since      06/02/2019
@version    P12.1.27
@param      cOldErpId, character, chave erpId enviada pelo TOTVS Antecipa contendo o grupo de empresa
@return     character, chave do erp formatada para o tamanho correto
/*/
Static Function FormatErpId(cOldErpId As Character) As Character

    Local aChaveSE1     As Array
    Local aCmpChvSE1    As Array

    Local cFrmtErpId    As Character

    Local nCampo        As Numeric
    Local nLenChvSE1    As Numeric

    Default cOldErpId   := ""

    aChaveSE1   := {}
    aCmpChvSE1  := {"", "E1_FILIAL", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO"}
    cFrmtErpId  := ""
    nCampo      := 0
    nLenChvSE1  := 0

    If !(Empty(cOldErpId))
        aChaveSE1 := StrTokArr2(cOldErpId, "|", .T.)
        nLenChvSE1 := Len(aChaveSE1)
        If nLenChvSE1 == Len(aCmpChvSE1) //Chave deve possuir a mesma quantidade de campos para ajuste
            For nCampo := 2 To nLenChvSE1 //Inicia em 2 para ignorar o campo grupo de empresa
                cFrmtErpId += PadR(aChaveSE1[nCampo], TamSX3(aCmpChvSE1[nCampo])[1])
            Next nCampo
        EndIf
    EndIf

Return cFrmtErpId

/*/{Protheus.doc} F136AJstBc
Ajusta para os tamanhos corretos os parâmetros de banco Techfin.

@author     Rafael Riego
@version    1.0
@since      06/02/2020
@return     array, array contendo as informações referentes aos parametros de banco Techfin
            [1] Banco; [2] Agencia; [3] Conta
/*/
Function F136AjstBc() As Array

    Local aInfoBanco    As Array

    Local cAgencia      As Character
    Local cConta        As Character
    Local cBanco        As Character

    aInfoBanco := {}

    cAgencia    := PadR(SuperGetMV("MV_AGETECF", .F., ""),  TamSX3("A6_AGENCIA")[1])
    cBanco      := PadR(SuperGetMV("MV_BCOTECF", .F., ""),  TamSX3("A6_COD")[1])
    cConta      := PadR(SuperGetMV("MV_CTNTECF", .F., ""),  TamSX3("A6_NUMCON")[1])

    aInfoBanco  := {cBanco, cAgencia, cConta}

Return aInfoBanco

/*/{Protheus.doc} F136Cartei
Ajusta para o tamanho correto o parâmetro de carteira TOTVS (Antecipa/Devolução).

@author     Rafael Riego
@version    1.0
@since      03/06/2020
@param      cParametro, character, MV_CARTECF ou MV_DEVTECF
@return     character, carteira conforme parâmetro informado
/*/
Function F136Cartei(cParametro As Character) As Array

    Local cCarteira As Character

    Default cParametro  := "MV_CARTECF"

    cCarteira := PadR(SuperGetMV(cParametro, .F., ""),  TamSX3("FRV_CODIGO")[1])

Return cCarteira
