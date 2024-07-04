#Include "FINA136A.ch"
#Include "Protheus.ch"
#Include "FwMVCDef.ch"

/*/{Protheus.doc} F136Transf
Rotina principal para geração de transferências das parcelas da Nota Fiscal informada.

@type       Function
@author     Rafael Riego
@since      25/11/2019
@version    P12.1.27
@param      oParcela, JSON, objeto JSON contendo a informação da Parcela da Nota Fiscal (Título)
@param      cCartTechF, character, carteira para transferência
@param      cMensagem, character, variável mensagem passada por referência
@param      cRetType, character, código do retorno da operação
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Function F136Transf(oParcela As J, cCartTechF As Character, cMensagem As Character, cRetType As Character) As Logical

    Local aAlt          As Array
    Local aAreaSe1      As Array
    Local aFlagCTB      As Array
    Local aInfoBanco    As Array
    Local aSitAtu       As Array
    Local aSitAnt       As Array
    Local aTempos       As Array
    
    Local cAgen136      As Character
    Local cAgencAnt     As Character
    Local cArquivo      As Character
    Local cCamposE5     As Character
    Local cChaveFK7     As Character
    Local cChaveSE1     As Character
    Local cChaveTit     As Character
    Local cClearing     As Character
    Local cConta136     As Character
    Local cContaAnt     As Character
    Local cE1Portado    As Character
    Local cE1Situaca    As Character
    Local cFilBor       As Character
    Local cHistorico    As Character
    Local cIdFK5        As Character
    Local cKeySE1       As Character
    Local cLog          As Character
    Local cLote         As Character
    Local cNumBco       As Character
    Local cPadrao       As Character
    Local cPort136      As Character
    Local cSequencia    As Character
    Local cSituAnt      As Character
    
    Local dDataMov      As Date
    
    Local lDesc         As Logical
    Local lGerMovTrf    As Logical
    Local lHead         As Logical
    Local lMarkAbt      As Logical
    Local lOk           As Logical
    Local lPadrao       As Logical
    Local lRet          As Logical
    Local lSpbInUse     As Logical
    Local lUsaFlag      As Logical
    Local lVldCtbOff    As Logical
    
    Local nDescFK5      As Numeric
    Local nHdlPrv       As Numeric
    Local nJ            As Numeric
    Local nOpca         As Numeric
    Local nRecSE5Trf    As Numeric
    Local nRetencao     As Numeric
    Local nSldAut       As Numeric
    Local nTaxaDesc     As Numeric
    Local nTotAbImp     As Numeric
    Local nTotal        As Numeric
    Local nValCred      As Numeric
    Local nValDesc      As Numeric
    Local nVlrJson      As Numeric

    Local oModelBx      As Object
    Local oSubFKA       As Object
    Local oSubFK5       As Object
    
    Private aBaixaSE5   As Array
    Private aItemsFI2   As Array
    Private cNatureza   As Character
    Private cPortAnt    As Character
    Private cSituacao   as Character
    
    Private lValorBruto As Logical
    
    Private Valor       As Numeric
    Private Valor2      As Numeric
    Private IOF         As Numeric
    Private nMoeda      As Numeric
    Private nVlrIOF     As Numeric
    Private nMoedaBco   As Numeric
    Private nTxIOF      As Numeric
    Private nTxMoeda    As Numeric
    Private nAbatim     As Numeric
    Private nValor      As Numeric
    
    Default cCartTechF  := ""
    Default cRetType    := ""
    
    aAlt        := {}
    aBaixaSE5   := {}
    aItemsFI2   := {}
    aFlagCTB    := {}
    aInfoBanco  := {}
    aSitAtu     := {}
    aSitAnt     := {}
    aTempos     := {}
    
    cAgen136    := CriaVar("EF_AGENCIA", .F.)
    cArquivo    := ""
    cCamposE5   := ""
    cChaveFK7   := ""
    cChaveSE1   := ""
    cChaveTit   := ""
    cClearing   := ""
    cConta136   := CriaVar("EF_CONTA", .F.)
    cContaAnt   := ""
    cE1Portado  :=  Alltrim(Transform(SE1->E1_PORTADO, PesqPict("SE1", "E1_PORTADO"))) + "-" + ;
    Alltrim(Transform(SE1->E1_AGEDEP, PesqPict("SE1", "E1_AGEDEP"))) + "-" + ;
    Alltrim(Transform(SE1->E1_CONTA, PesqPict("SE1", "E1_CONTA")))
    cE1Situaca  := AllTrim(Transform(SE1->E1_SITUACA, PesqPict("SE1", "E1_SITUACA")))
    cFilBor     := ""
    cAgencAnt   := ""
    cIdFK5      := ""
    cKeySE1     := ""
    cLog        := ""
    cMensagem   := ""
    cNatureza   := ""
    cNumBco     := ""
    cPort136    := CriaVar("EF_BANCO", .F.)
    cPortAnt    := ""
    cSequencia  := ""
    
    nAbatim     := 0
    nDescFK5    := 0
    nHdlPrv     := 0
    nIndice     := SE1->(IndexOrd())
    nMoeda      := 1
    nMoedaBco   := 0
    nOpca       := 0
    nRecSE5Trf  := 0
    nRetencao   := 0
    nSldAut     := 0
    nTaxaDesc   := 0
    nTotAbImp   := 0
    nTotal      := 0
    nTxIOF      := 0
    nTxMoeda    := 0
    nValCred    := 0
    nValor      := 0
    nVlrIOF     := 0
    lDesc       := .F.
    lGerMovTrf  := .T. //Techfin sempre gera movimentação de transferência
    lHead       := .F.
    lMarkAbt    := .F.
    lOk         := .T.
    lPadrao     := .F.
    lRet        := .T.
    lSpbInUse   := SpbInuse()
    lUsaFlag    := SuperGetMV("MV_CTBFLAG", .T., .F.)
    lValorBruto := .F.
    lVldCtbOff  := .F.
    
    cChaveSE1 := oParcela["formattedErpId"]

    cLote := LoteCont("FIN")

    SE1->(DbSetOrder(1))
    SE1->(MsSeek(cChaveSE1))
    
    Begin Sequence
    
        //VerIfica se data do movimento não ‚ menor que data limite de
        //movimentacao no financeiro
        If !(DtMovFin(,, "2"))
            lOk := .F.
            cMensagem := STR0020 // "O ERP está bloqueado para movimentações financeiras na data de hoje. A nota será recomprada automaticamente pelo TOTVS Antecipa. Se desejar fazer novas antecipações nesta data, realize antes o desbloqueio para movimentações financeiras."
            cRetType := "06"
            Break
        EndIf
    
        If SE1->E1_SALDO == 0
            lOk := .F.
            cMensagem := STR0021 // "O saldo em aberto da nota fiscal está diferente do seu valor original. A nota será recomprada automaticamente pelo TOTVS Antecipa."
            cRetType  := "05"
            Break
        EndIf
    
        // Bloqueia o Registro do SE1
        If !(Softlock("SE1"))
            cMensagem := STR0001 //"Não foi possível atualizar o título informado."
            SE1->(MsUnlock())
            lOk := .F.
            cRetType := "02"
            Break
        EndIf
    
        /* Caso titulos originados pelo SIGALOJA estejam nas carteiras:
        I = Carteira Caixa Loja                                   
        J = Carteira Caixa Geral                                  
        Não permitir esta operação, pois ele precisa ser transferido antes pelas rotinas do SIGALOJA. */
        If Upper(AllTrim(SE1->E1_SITUACA)) $ "I|J" .And. Upper(AllTrim(SE1->E1_ORIGEM)) $ "LOJA010|LOJA701|FATA701"
            Help("", 1, "NOUSACLJ")
            lOk := .F.
            cRetType := "03"
            Break
        EndIf
    
        DbSelectArea("FRV") 
        FRV->(DbSetOrder(1))
        If FRV->(MsSeek(FwXFilial("FRV") + SE1->E1_SITUACA))
            M->E1_SITUACA   := FRV->FRV_CODIGO
            cNatureza       := FRV->FRV_NATIOF
        Else
            Help(" ", 1, "SITCOB",, STR0008, 1, 0) //"Situação de cobrança não cadastrada. VerIfique o cadastro de situações de cobrança."
            lOk := .F.
            cRetType := "03"
            Break
        EndIf
    
        PcoIniLan("000003")
    
        aSitAnt := Fn022SitCB(SE1->E1_SITUACA)
    
        Pergunte("FIN060", .F.)
    
        SA1->(DbSeek(FwXFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
        cContrato := SubS(SE1->E1_CONTRAT, 1, 3)
    
        //Se situacao de cobranca possui portador (nao e carteira)
        If aSitAnt[2]   //utiliza banco
            SA6->(DbSeek(FwXFilial("SA6") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA + SA6->A6_NOME))
        Else
            SA6->(DbSeek(FwXFilial("SA6")))
        EndIf
    
        nValor := SE1->E1_SALDO
    
        //TOTVS Antecipa
        If cCartTechF == F136Cartei("MV_CARTECF")
            aInfoBanco  := F136AJstBc()
            cPort136    := aInfoBanco[1]
            cAgen136    := aInfoBanco[2]
            cConta136   := aInfoBanco[3]
        EndIf

        cHistorico  := oParcela["history"]
        dDataMov    := oParcela["date"]
        nVlrJson    := oParcela["localAmount"]
        nValDesc    := oParcela["feeAmount"]

        nValCred    := SE1->E1_SALDO - nValDesc

        If SE1->E1_SALDO <> nVlrJson
            lOk := .F.
            cMensagem := STR0021 // "O saldo em aberto da nota fiscal está diferente do seu valor original. A nota será recomprada automaticamente pelo TOTVS Antecipa."
            cRetType  := "05"
            Break
        EndIf

        cPort136    := PadR(cPort136, TamSX3("A6_COD")[1])
        cAgen136    := PadR(cAgen136, TamSX3("A6_AGENCIA")[1])
        cConta136   := PadR(cConta136, TamSX3("A6_NUMCON")[1])
        cSituacao   := PadR(cCartTechF, TamSX3("FRV_CODIGO")[1])
    
        nTaxaDesc   := 0
        nTxIOF      := 0
    
        aSitAtu := FN022SITCB(cSituacao)
    
        If Empty(cHistorico)
            If FwIsInCallStack("F136AntAp")
                cHistorico := STR0003 //"Antecipação TOTVS Antecipa"
            ElseIf FwIsInCallStack("F136Cancel")
                cHistorico := STR0004 //"Cancelamento TOTVS Antecipa"
            ElseIf FwIsInCallStack("F136LibNCC")
                cHistorico := STR0025 // "Liberação NCC TOTVS Antecipa"
            EndIf
        EndIf

        If FA136Sit(cSituacao) .And. F136Valor(cSituacao) .And.;
            Fa136VerSit(cSituacao, cPort136, cAgen136, cConta136, @nValCred, @nTaxaDesc, @dDataMov, @nValDesc, @lDesc, @nRetencao, @cClearing, @aTempos)
            nOpca := 1
        Else
            nOpca   := 0
            lOk     := .F.
            cRetType := "04"
        EndIf

        If nOpcA == 1
            //Por execauto é verIficado se os valores para carteira descontada é igual ao saldo disponível do título
            If aSitAtu[3] //Se descontada
                nSldAut := SE1->E1_SALDO
                If MV_PAR09 == 1 //Considera acrescimos/decrescimos
                    nSldAut += SE1->E1_SDACRES - SE1->E1_SDDECRE
                EndIf
                If MV_PAR08 == 1 //Considera Abatimentos
                    nSldAut -= nAbatim
                EndIf
                If nSldAut <> (nValCred + nValDesc)
                    nOpca := 0
                    cMensagem := STR0022 // "Esta nota está no ERP como descontada em outra instituição financeira. A nota será recomprada automaticamente pelo TOTVS Antecipa."
                    lOk := .F.
                    cRetType := "07"
                    Break
                EndIf
            EndIf
    
            //Cria registro na tabela FI2 para retirar título do banco
            If !(Empty(SE1->E1_IDCNAB))
                F136GrvFI2()
            EndIf
    
            DbSelectArea("SE1")
            aAreaSe1 := SE1->(GetArea())
            If !(Empty(SE1->E1_NUMBOR)) .And. Fa150PesqBord(SE1->E1_NUMBOR, @cFilBor)
                cChavEA := cFilBor + E1_NUMBOR + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
            Else
                cChavEA := FwXFilial("SEA") + E1_NUMBOR + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
            EndIf
            cSituAnt := SE1->E1_SITUACA
            cPortAnt := SE1->E1_PORTADO
    
            If cSituAnt != cSituacao/* .And. MV_PAR03 == 1*/ // contabiliza transferencias
                cPadrao := fA060Pad(cSituacao, .F.)
                lPadrao := VerPadrao(cPadrao)
            EndIf
    
            lVldCtbOff := FindFunction("F060VldCtb") .And. F060VldCtb()
    
            //Transferido para situacao de protesto
            If aSitAtu[4] .And. !aSitAnt[4]
                //Atualiza Títulos protestados
                DbSelectArea("SA1")
                SA1->(DbSetOrder(1))
                If SA1->(DbSeek(xfilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
                    Reclock("SA1", .F.)
                    SA1->A1_TITPROT := A1_TITPROT + 1
                    SA1->A1_DTULTIT := dDataBase
                    SA1->(MsUnlock())
                EndIf
                DbSelectArea("SE1")
            EndIf
    
            //Atualizo o numero de protestos dos clientes quando
            //Transfiro de uma situacao de protesto para carteira que nao tenha protesto
            If (aSitAtu[1] .And. !aSitAtu[4]) .And. aSitAnt[4]
                // Atualiza Títulos protestados
                DbSelectArea("SA1")
                SA1->(DbSetOrder(1))
                If SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
                    Reclock("SA1", .F.)
                    SA1->A1_TITPROT := A1_TITPROT - 1
                    SA1->(MsUnlock())
                EndIf
                DbSelectArea("SE1")
            EndIf
    
            //Transferido para situacao com portador
            If aSitAtu[2] .And. cSituacao != cSituAnt
                // Atualiza data vencto real c/retenção Bancária
                // Se possuir retencao bancaria, grava a data de vencimento
                If MV_PAR10 == 1 .And. nRetencao > 0
                    dBase   := SE1->E1_VENCREA
                    For nJ := 1 To nRetencao
                        dBase := DataValida(dBase + 1, .T.)
                    Next nJ
                    Reclock("SE1", .F.)
                    SE1->E1_VENCREA := dBase
                    SE1->(MsUnlock())
                    // Atualiza tambem os registros agregados
                    F060AtuAgre()
                EndIf
    
                //DDA - Debito Direto Autorizado
                If SE1->E1_OCORREN $ "53/52"
                    Reclock("SE1", .F.)
                    SE1->E1_OCORREN := "01"
                    SE1->(MsUnlock())
                EndIf
            EndIf
    
            //Transferido para carteira (situacao anterior com portador)    
            If aSitAtu[1] .And. aSitAnt[2]
                //Atualiza data vencto real s/ retenção Bancária
                //Se considera retencao bancaria
                If MV_PAR10 == 1
                    Reclock("SE1")
                    SE1->E1_VENCREA := DataValida(E1_VENCORI, .T.)
                    If SE1->E1_VENCREA < SE1->E1_VENCTO
                        SE1->E1_VENCREA := DataValida(E1_VENCTO, .T.)
                    EndIf
                    SE1->(MsUnlock())
                    // Atualiza tambem os registros agregados
                    F060AtuAgre()
                EndIf
            EndIf
    
            // Estorno de cobrança descontada -> carteira
            If aSitAnt[3] .And. cSituacao != cSituAnt

                aBaixa := Sel070Baixa("TR /", SE1->E1_PREFIXO, SE1->E1_NUM,;
                SE1->E1_PARCELA, SE1->E1_TIPO,,, SE1->E1_CLIENTE, SE1->E1_LOJA, nValDesc, .T.)

                If !(Empty(cCamposE5))
                    cCamposE5 += "|"
                EndIf
                cCamposE5 := "{"
                cCamposE5 += "{'E5_DTDIGIT'  , dDataBase}"
                cCamposE5 += ",{'E5_PREFIXO' , SE1->E1_PREFIXO}"
                cCamposE5 += ",{'E5_NUMERO'  , SE1->E1_NUM}"
                cCamposE5 += ",{'E5_PARCELA' , SE1->E1_PARCELA}"
                cCamposE5 += ",{'E5_CLIFOR'  , SE1->E1_CLIENTE}"
                cCamposE5 += ",{'E5_CLIENTE' , SE1->E1_CLIENTE}"
                cCamposE5 += ",{'E5_LOJA'    , SE1->E1_LOJA}"
                cCamposE5 += ",{'E5_TIPO'    , SE1->E1_TIPO}"
                cCamposE5 += ",{'E5_DTDISPO' , CToD('" + DToC(dDataMov) + "')}"
                cCamposE5 += ",{'E5_LA'      , '" + IIf(lPadrao, "S", "N") + "'}"
                cCamposE5 += ",{'E5_BANCO'   , SE1->E1_PORTADO }"
                cCamposE5 += ",{'E5_AGENCIA' , SE1->E1_AGEDEP  }"
                cCamposE5 += ",{'E5_CONTA'   , SE1->E1_CONTA   }"
                cCamposE5 += ",{'E5_MOTBX'   , 'NOR' }"
                cCamposE5 += ",{'E5_LA'      , '" + IIf(lPadrao, "S", "N") + "'}"
                cCamposE5 += ",{'E5_TIPODOC', 'E2' }"
                If lSpbInUse
                    CamposE5 += ",{'E5_MODSPB', '1' }"
                EndIf
                cCamposE5 += "}"
                oModelBx := FwLoadModel("FINM030") //Model de movimento bancário
                oModelBx:SetOperation(MODEL_OPERATION_INSERT) //Inclusao
                oModelBx:Activate()
                oModelBx:SetValue("MASTER", "E5_GRV",   .T.)       //Informa se vai gravar SE5 ou não
                oModelBx:SetValue("MASTER", "HISTMOV",  cHistorico)//Informa os campos da SE5 que serão gravados indepentes de FK5
                oModelBx:SetValue("MASTER", "NOVOPROC", .T.)       //Informa que a inclusão será feita com um novo número de processo

                //Dados do Processo - Define a chave da FK5 no IDORIG
                oSubFKA := oModelBx:GetModel("FKADETAIL")
                oSubFK5 := oModelBx:GetModel("FK5DETAIL")
                oSubFK6 := oModelBx:GetModel("FK6DETAIL")

                cIdFK5  := FwUUIdv4()

                oSubFKA:SetValue("FKA_IDORIG", cIdFK5)
                oSubFKA:SetValue("FKA_TABORI", "FK5")

                //Dados da tabela auxiliar com o código do título a pagar
                cChaveTit := xFilial("SE1") + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + ;
                SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
                cChaveFK7 := FinGrvFK7("SE1", cChaveTit)

                nMoedaBco := Max(MoedaBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA), 1)
                cSequencia := If(Len(aBaixa) > 0, aBaixaSE5[01][09], "")

                oSubFK5:SetValue("FK5_IDDOC" , cChaveFK7)
                oSubFK5:SetValue("FK5_DATA"  , dDataMov)
                oSubFK5:SetValue("FK5_NATURE", If (Empty(cNatureza), SE1->E1_NATUREZ, cNatureza))
                oSubFK5:SetValue("FK5_RECPAG", "P")
                oSubFK5:SetValue("FK5_TPDOC" , "E2")
                oSubFK5:SetValue("FK5_ORIGEM", FunName())
                oSubFK5:SetValue("FK5_SEQ"   , cSequencia)
                oSubFK5:SetValue("FK5_CCUSTO", SE1->E1_CCUSTO)
                oSubFK5:SetValue("FK5_HISTOR", cHistorico)
                oSubFK5:SetValue("FK5_MOEDA" , StrZero(nMoedaBco, 2))
                oSubFK5:SetValue("FK5_BANCO" , SE1->E1_PORTADO)
                oSubFK5:SetValue("FK5_AGENCI", SE1->E1_AGEDEP)
                oSubFK5:SetValue("FK5_CONTA" , SE1->E1_CONTA)
                oSubFK5:SetValue("FK5_DOC"   , SE1->E1_NUMBOR)

                nTxMoeda := If(SE1->E1_MOEDA > 1, RecMoeda(dDataMov, SE1->E1_MOEDA), 0)
                nDecs := MsDecimais(nMoedaBco)
                oSubFK5:SetValue("FK5_TXMOED", nTxMoeda)
                oSubFK5:SetValue("FK5_FILORI", SE1->E1_FILORIG)

                oSubFK5:SetValue("FK5_VALOR",  nValCred)
                oSubFK5:SetValue("FK5_VLMOE2", Round(NoRound(xMoeda(nValCred, nMoedaBco, SE1->E1_MOEDA,;
                dDataMov, nDecs + 1), nDecs + 1), nDecs))

                If lSpbInUse
                    oSubFK5:SetValue("FK5_MODSPB", "1")
                EndIf

                //IOF - Estorno
                If  nVlrIOF > 0 .And. cPaisloc == "BRA"
                    /*
                    * Adicionando valores acessórios (Iof)
                    */
                    If !oSubFK6:IsEmpty()
                        //Inclui a quantidade de linhas necessárias
                        oSubFK6:AddLine()
                        //Vai para linha criada
                        oSubFK6:GoLine(oSubFK6:Length())
                    EndIf

                    oSubFK6:SetValue("FK6_IDFK6",   GetSXENum("FK6", "FK6_IDFK6"))
                    oSubFK6:SetValue("FK6_TPDOC",   "EI")
                    oSubFK6:SetValue("FK6_VALCAL",  nVlrIOF)
                    oSubFK6:SetValue("FK6_VALMOV",  nVlrIOF)
                    oSubFK6:SetValue("FK6_RECPAG",  "R")
                    oSubFK6:SetValue("FK6_IDORIG",  cIdFK5)
                    oSubFK6:SetValue("FK6_TABORI",  "FK5")
                    oSubFK6:SetValue("FK6_HISTOR",  STR0010) //"Cancelamento de cob de IOF"
                    oSubFK6:SetValue("FK6_GRVSE5",  .T.)
                    oSubFK6:SetValue("FK6_TPDESC",  If(SE1->E1_TPDESC == "I", "2", "1"))
                EndIf

                oModelBx:SetValue("MASTER", "E5_CAMPOS", cCamposE5) //Informa os campos da SE5 que serão gravados indepentes de FK5

                If oModelBx:VldData()
                    oModelBx:CommitData()
                    SE5->(DbGoto(oModelBx:GetValue("MASTER", "E5_RECNO")))
                    nRecSE5Trf := SE5->(RecNo())
                Else
                    lRet := .F.
                    cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + " - "
                    cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + " - "
                    cLog += cValToChar(oModelBx:GetErrorMessage()[6])

                    Help(,, "M060TRFS4",, cLog, 1, 0)
                    lOk := .F.
                    cRetType := "02"
                    Break
                EndIf

                oModelBx:DeActivate()
                oModelBx:Destroy()
                oModelBx:= Nil

                // VerIfica se a natureza esta cadastrada. Se nao, cria.
                Fa060Nat(2, cNatureza)

                AtuSalBco(SE1->E1_PORTADO, SE1->E1_AGEDEP, SE1->E1_CONTA, dDataMov, nValCred, "-")
            EndIf
    
            //Saldo do titulo para contabilizacao de dIferenca
            nValSaldo := Round(NoRound(xMoeda(SE1->E1_SALDO, SE1->E1_MOEDA, nMoedaBco, dDatabase, 3), 3), 2)
    
            // Banco vazio, contabiliza anterior
            DbSelectArea("SA6")
            SA6->(DbSetOrder(1))
            If Empty(cPort136)
                SA6->(DbSeek(FwXFilial() + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA))
            Else
                SA6->(DbSeek(FwXFilial() + cPort136 + cAgen136 + cConta136))
            EndIf
    
            //Retorno para carteira os abatimentos do titulo independente de serem considerados
            If aSitAnt[3] .And. cSituacao != cSituAnt
                If nAbatim > 0
                    cKeySE1 := xFilial("SE1") + SE1->(E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA)
                    aAreaSe1 := SE1->(GetArea())
                    DbSelectArea("SE1")
                    SE1->(DbSetOrder(2))
                    SE1->(DbSeek(cKeySE1))
                    While SE1->(!(EoF())) .And.;
                    SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA) == cKeySE1
                        If E1_TIPO $ MVABATIM
                            RecLock("SE1", .F.)
                            SE1->E1_PORTADO := cPort136
                            SE1->E1_AGEDEP  := cAgen136
                            SE1->E1_SITUACA := cSituacao
                            SE1->E1_CONTRAT := cContrato
                            SE1->E1_NUMBCO  := cNumBco
                            SE1->E1_MOVIMEN := dDataMov
                            SE1->E1_CONTA   := cConta136
                            If cSituacao != cSituAnt
                                SE1->E1_NUMBOR  := " "
                                SE1->E1_DATABOR := CToD("  /  /  ")
                            EndIf
                            SE1->(MsUnlock())
                        EndIf
                        SE1->(DbSkip())
                    End
                    RestArea(aAreaSe1)
                EndIf
            EndIf
    
            //Transferencia para situacao descontada
            If aSitAtu[3] .And. cSituacao != cSituAnt
    
                //Se nao for adiantamento, verIfico os abatimentos
                If !SE1->E1_TIPO $ MVRECANT + "/" + MV_CRNEG
                    SumAbatRec(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_MOEDA,"V",, @nTotAbImp)
                EndIf
    
                //Localiza a sequencia da baixa (BA)
                cSequencia := FaNxtSeqBx()  // SEquencia da baixa do titulo + 1++
    
                //VerIfica se a natureza esta cadastrada. Se nao, cria.
                Fa060Nat(1, cNatureza)
    
                /*
                * MOVIMENTO DE BAIXA
                * Controla saldo do titulo na compensacao do cheque
                */
                If lGerMovTrf
    
                    //MOVIMENTO BANCÁRIO DA TRANSFERENCIA
                    //Movimento de credito da cobranca descontada
                    If !Empty(cCamposE5)
                        cCamposE5 += "|"
                    EndIf
                    cCamposE5 := "{"
                    cCamposE5 += " {'E5_DTDIGIT', dDataBase}"
                    cCamposE5 += ",{'E5_PREFIXO', SE1->E1_PREFIXO}"
                    cCamposE5 += ",{'E5_NUMERO' , SE1->E1_NUM}"
                    cCamposE5 += ",{'E5_PARCELA', SE1->E1_PARCELA}"
                    cCamposE5 += ",{'E5_CLIfOR' , SE1->E1_CLIENTE}"
                    cCamposE5 += ",{'E5_CLIENTE', SE1->E1_CLIENTE}"
                    cCamposE5 += ",{'E5_LOJA'   , SE1->E1_LOJA}"
                    cCamposE5 += ",{'E5_TIPO'   , SE1->E1_TIPO}"
                    cCamposE5 += ",{'E5_DTDISPO', Ctod('" + DToC(dDataMov) + "')}"
                    cCamposE5 += ",{'E5_LA'     ,'" + IIf(lPadrao, "S", "N") + "'}"
                    cCamposE5 += ",{'E5_BANCO'  , '" + cPort136 + "' }"
                    cCamposE5 += ",{'E5_AGENCIA', '" + cAgen136 + "' }"
                    cCamposE5 += ",{'E5_CONTA'  , '" + cConta136 + "'}"
                    cCamposE5 += ",{'E5_MOTBX'  , 'NOR' }"
                    cCamposE5 += ",{'E5_LA'     , '" + IIf(lPadrao, "S", "N") + "'}"
                    If lSpbInUse
                        cCamposE5 += ",{'E5_MODSPB', '1' }"
                    EndIf
    
                    oModelBx := FwLoadModel("FINM030") //Model de movimento bancário
                    oModelBx:SetOperation(MODEL_OPERATION_INSERT) //Inclusao
                    oModelBx:Activate()
                    oModelBx:SetValue("MASTER", "E5_GRV", .T.) //Informa se vai gravar SE5 ou não
                    oModelBx:SetValue("MASTER", "HISTMOV", cHistorico) //Informa os campos da SE5 que serão gravados indepentes de FK5
                    oModelBx:SetValue("MASTER", "NOVOPROC", .T.) //Informa que a inclusão será feita com um novo número de processo
    
                    //Dados do Processo - Define a chave da FK5 no IDORIG
                    oSubFKA := oModelBx:GetModel("FKADETAIL")
                    oSubFK5 := oModelBx:GetModel("FK5DETAIL")
                    oSubFK6 := oModelBx:GetModel("FK6DETAIL")
    
                    cIdFK5  := FwUUIDV4()
    
                    oSubFKA:SetValue("FKA_IDORIG", cIdFK5)
                    oSubFKA:SetValue("FKA_TABORI", "FK5")
    
                    //Dados da tabela auxiliar com o código do título a pagar
                    cChaveTit := xFilial("SE1") + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + ;
                    SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
                    cChaveFK7 := FinGrvFK7("SE1", cChaveTit)
    
                    nMoedaBco := Max(MoedaBco(cPort136, cAgen136, cConta136), 1)
    
                    oSubFK5:SetValue("FK5_IDDOC" , cChaveFK7)
                    oSubFK5:SetValue("FK5_DATA"  , dDataMov)
                    oSubFK5:SetValue("FK5_NATURE", IIf(Empty(cNatureza), SE1->E1_NATUREZ, cNatureza))
                    oSubFK5:SetValue("FK5_RECPAG", "R")
                    oSubFK5:SetValue("FK5_TPDOC" , "TR")
                    oSubFK5:SetValue("FK5_ORIGEM", FunName())
                    oSubFK5:SetValue("FK5_SEQ"   , cSequencia)
                    oSubFK5:SetValue("FK5_CCUSTO", SE1->E1_CCUSTO)
                    oSubFK5:SetValue("FK5_HISTOR", cHistorico)
                    oSubFK5:SetValue("FK5_MOEDA" , StrZero(nMoedaBco, 2))
                    oSubFK5:SetValue("FK5_BANCO" , cPort136)
                    oSubFK5:SetValue("FK5_AGENCI", cAgen136)
                    oSubFK5:SetValue("FK5_CONTA" , cConta136)
    
                    nTxMoeda := If(SE1->E1_MOEDA > 1, RecMoeda(dDataMov, SE1->E1_MOEDA), 0)
                    oSubFK5:SetValue("FK5_TXMOED", nTxMoeda)
                    oSubFK5:SetValue("FK5_FILORI", SE1->E1_FILORIG)
    
                    oSubFK5:SetValue("FK5_VALOR",Round(NoRound(xMoeda(nValCred, SE1->E1_MOEDA, nMoedaBco, dDataMov, 3, nTxMoeda),;
                    3), 2))
                    oSubFK5:SetValue("FK5_VLMOE2",  nValCred)
                    nDescFK5 := nValSaldo - Round(NoRound(xMoeda((nValCred + nVlrIOF), SE1->E1_MOEDA, nMoedaBco, dDataMov, 3, nTxMoeda),;
                    3), 2)
    
                    cCamposE5 += ",{'E5_VLDESCO'," + Str(nDescFK5) + "}"
                    cCamposE5 += "}"
    
                    If lSpbInUse
                        oSubFK5:SetValue("FK5_MODSPB", "1")
                    EndIf
    
                    //Desconto
                    If nDescFK5 <> 0
                        /*
                        * Adicionando valores acessórios (Multa, Desconto, Juros, Acréscimo, Decréscimo)
                        */
                        If !oSubFK6:IsEmpty()
                            //Inclui a quantidade de linhas necessárias
                            oSubFK6:AddLine()
                            //Vai para linha criada
                            oSubFK6:GoLine(oSubFK6:Length())
                        EndIf
    
                        oSubFK6:SetValue("FK6_IDFK6",  GetSXENum("FK6", "FK6_IDFK6"))
                        oSubFK6:SetValue("FK6_TPDOC",  "DC")
                        oSubFK6:SetValue("FK6_VALCAL", nDescFK5)
                        oSubFK6:SetValue("FK6_VALMOV", nDescFK5)
                        oSubFK6:SetValue("FK6_RECPAG", "R")
                        oSubFK6:SetValue("FK6_IDORIG", cIdFK5)
                        oSubFK6:SetValue("FK6_TABORI", "FK5")
                        oSubFK6:SetValue("FK6_HISTOR", cHistorico)
                        oSubFK6:SetValue("FK6_GRVSE5", .F.)
                        oSubFK6:SetValue("FK6_TPDESC", IIf(SE1->E1_TPDESC == "I", "2", "1"))
                    EndIf
    
                    //IOF
                    If  nVlrIOF > 0 .And. cPaisloc == "BRA"
                        /*
                        * Adicionando valores acessórios (Iof)
                        */
                        If !(oSubFK6:IsEmpty())
                            //Inclui a quantidade de linhas necessárias
                            oSubFK6:AddLine()
                            //Vai para linha criada
                            oSubFK6:GoLine(oSubFK6:Length())
                        EndIf
    
                        oSubFK6:SetValue("FK6_IDFK6",   GetSXEnum("FK6", "FK6_IDFK6"))
                        oSubFK6:SetValue("FK6_TPDOC",   "I2")
                        oSubFK6:SetValue("FK6_VALCAL",  nVlrIOF)
                        oSubFK6:SetValue("FK6_VALMOV",  nVlrIOF)
                        oSubFK6:SetValue("FK6_RECPAG",  "P")
                        oSubFK6:SetValue("FK6_IDORIG",  cIdFK5)
                        oSubFK6:SetValue("FK6_TABORI",  "FK5")
                        oSubFK6:SetValue("FK6_HISTOR",  STR0009) //"IOF sobre cob descontada"
                        oSubFK6:SetValue("FK6_GRVSE5",  .T.)
                        oSubFK6:SetValue("FK6_TPDESC",  If(SE1->E1_TPDESC == "I", "2", "1"))
                    EndIf
    
                    oModelBx:SetValue("MASTER", "E5_CAMPOS", cCamposE5) //Informa os campos da SE5 que serão gravados indepentes de FK5
    
                    If oModelBx:VldData()
                        oModelBx:CommitData()
                        SE5->(DbGoto(oModelBx:GetValue("MASTER", "E5_RECNO")))
                        nRecSE5Trf := SE5->(RecNo())
                    Else
                        lRet := .F.
                        cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + " - "
                        cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + " - "
                        cLog += cValToChar(oModelBx:GetErrorMessage()[6])
    
                        Help(,, "M060TRFS4",, cLog, 1, 0)
                        lOk := .F.
                        cRetType := "02"
                        Break
                    EndIf
    
                    oModelBx:DeActivate()
                    oModelBx:Destroy()
                    oModelBx:= Nil
    
                    AtuSalBco(cPort136, cAgen136, cConta136, dDataMov, nValCred, "+")
                EndIf
            EndIf
    
            DbSelectArea("SEA")
            SEA->(DbSetOrder(1))
            If aSitAtu[1] //cSituacao $ "0FG"
                If SEA->(DbSeek(cChavEA))
                    RecLock("SEA", .F., .T.)
                    SEA->(DbDelete())
                    SEA->(MsUnlock())
                EndIf
            Else
                If !(SEA->(DbSeek(cChavEA)))
                    RecLock("SEA", .T.)     ///numbor
                Else
                    RecLock("SEA", .F.)
                EndIf
                SEA->EA_FILIAL  := xFilial("SEA")
                SEA->EA_DATABOR := dDataBase
                SEA->EA_PORTADO := cPort136
                SEA->EA_AGEDEP  := cAgen136
                SEA->EA_NUMCON  := cConta136
                SEA->EA_SITUACA := cSituacao
                SEA->EA_NUM     := SE1->E1_NUM
                SEA->EA_PARCELA := SE1->E1_PARCELA
                SEA->EA_PREFIXO := SE1->E1_PREFIXO
                SEA->EA_TIPO    := SE1->E1_TIPO
                SEA->EA_CART    := "R"
                SEA->EA_SITUANT := cSituAnt
                SEA->EA_FILORIG := SE1->E1_FILORIG
                SEA->(MsUnlock())// Destravar SEA apos alteracoes
            EndIf
            FkCommit()
    
            RecLock("SE1", .F.)
            VAR_IXB         := SE1->E1_PORTADO // Guardo portador anterior, para possivel utilizacao no LP
            cAgencAnt       := SE1->E1_AGEDEP
            cContaAnt       := SE1->E1_CONTA
            SE1->E1_PORTADO := cPort136
            SE1->E1_AGEDEP  := cAgen136
            SE1->E1_SITUACA := cSituacao
            SE1->E1_CONTRAT := cContrato
            SE1->E1_NUMBCO  := cNumBco
            SE1->E1_MOVIMEN := dDataMov
            SE1->E1_CONTA   := cConta136
            If cSituacao != cSituAnt .And. !(Empty(SE1->E1_NUMBOR))
                SE1->E1_NUMBOR := " "
                SE1->E1_DATABOR:= CToD("  /  /  ")
            EndIf
            FkCommit()
    
            If cSituAnt != SE1->E1_SITUACA // Contabiliza transferencias
                cPadrao := fA060Pad(cSituacao, .F.)
                lPadrao := VerPadrao(cPadrao)
    
                STRLCTPAD   := cSituAnt     // Disponibiliza a situacao anterior para ser utilizada no LP
                VALOR       := nValCred     // para contabilizar o total descontado (PRIVATE)
                IOF         := nVlrIOF
                VALOR2      := nValSaldo    // Saldo dos titulo para contabilizacao da dIferenca
    
                //[01] = FWI_LA ('S' ou 'N')
                //[02] = FWI_LANPAD (Lançamento Padrão utilizado)
                //[03] = FWI_VALOR (Valor da Movimentação)
                //[04] = FWI_DESCON (Desconto da Movimentação)
                //[05] = FWI_IOF (Valor do IOF)
                //[06] = FWI_SITUAC (Carteira Atual)
                //[07] = FWI_SITANT (Carteira Anterior)
                //[08] = FWI_BCOANT (Portador Anterior)
                //[09] = FWI_AGEANT (Agência Anterior)
                //[10] = FWI_CONANT (Número da Conta Anterior)
                //[11] = FWI_CONTRA (Contrato)
                //[12] = FWI_IDMOV (Id da Movimentação na FK5)
                //[13] = FWI_NUMBOR (Número do Borderô)
                If lVldCtbOff
                    FinAGrvFWI({IIf(lPadrao, "S", "N"), cPadrao, nValCred, nDescFK5, nVlrIOF, cSituacao, cSituAnt,;
                        VAR_IXB, cAgencAnt, cContaAnt, cContrato, cIdFK5, ""})
                EndIf

                //A variavel lHead controla se a rotina HeadProva ja'
                //foi executada, visto que ela s¢ pode ser executada
                //uma £nica vez e não h  como identIficar se a mesma
                //j  foi executada ou não (T=J  fez , F=Não fez)
                If lPadrao// .And. MV_PAR03 == 1
                    If !lHead
                        //Inicializa Lancamento Contabil
                        nHdlPrv := HeadProva(cLote,;
                        "FINA136A" /*cPrograma*/,;
                        SubStr(cUsuario, 7, 6),;
                        @cArquivo)
                        lHead := .T.
                    EndIf
                    //Prepara Lancamento Contabil
                    If lUsaFlag .And. (nRecSE5Trf > 0) // Armazena em aFlagCTB para atualizar no modulo Contabil
                        AAdd(aFlagCTB, {"E5_LA", "S", "SE5", nRecSE5Trf, 0, 0, 0})
                    EndIf
    
                    nTotal += DetProva(nHdlPrv,;
                    cPadrao,;
                    "FINA136A" /*cPrograma*/,;
                    cLote,;
                    /*nLinha*/,;
                    /*lExecuta*/,;
                    /*cCriterio*/,;
                    /*lRateio*/,;
                    /*cChaveBusca*/,;
                    /*aCT5*/,;
                    /*lPosiciona*/,;
                    @aFlagCTB,;
                    /*aTabRecOri*/,;
                    /*aDadosProva*/)
    
                    If  lHead
                        RodaProva(nHdlPrv, nTotal)
                        // Envia para Lancamento Contabil
                        cA100Incl(cArquivo, nHdlPrv, 3, cLote, .F./*lDigita*/, .F./*lAglut*/)
                        lHead := .F.
                    EndIf
                EndIf
            EndIf
    
            If nTotal > 0 .And. nRecSE5Trf > 0
                SE5->(DbGoto(nRecSE5Trf))
    
                If !lUsaFlag
                    cCamposE5 := "{}"
                    oModelBx := FwLoadModel("FINM030") //Recarrega o Model de movimentos para pegar o campo do relacionamento (SE5->E5_IDORIG)
                    oModelBx:SetOperation(MODEL_OPERATION_UPDATE) //Alteração
                    oModelBx:Activate()
                    oModelBx:SetValue("MASTER", "E5_GRV", .T.) //habilita gravação de SE5
                    oModelBx:SetValue("MASTER", "E5_CAMPOS", cCamposE5) //Informa os campos da SE5 que serão gravados indepentes de FK5
    
                    //Posiciona a FKA com base no IDORIG da SE5 posicionada
                    oSubFKA := oModelBx:GetModel("FKADETAIL")
                    If oSubFKA:SeekLine({{"FKA_IDORIG", SE5->E5_IDORIG}})
    
                        //Dados do movimento
                        oSubFK5 := oModelBx:GetModel("FK5DETAIL")
                        oSubFK5:SetValue("FK5_LA", "S")
    
                        If oModelBx:VldData()
                            oModelBx:CommitData()
                            SE5->(DbGoto(nRecSE5Trf))
                        Else
                            lRet := .F.
                            cLog := cValToChar(oModelBx:GetErrorMessage()[4]) + " - "
                            cLog += cValToChar(oModelBx:GetErrorMessage()[5]) + " - "
                            cLog += cValToChar(oModelBx:GetErrorMessage()[6])
    
                            Help(,,"M060TRFS6",,cLog, 1, 0)
                            lOk := .F.
                            cRetType := "02"
                            Break
                        EndIf
                    EndIf
    
                    oModelBx:DeActivate()
                    oModelBx:Destroy()
                    oModelBx:= Nil
                EndIf
            EndIf
        EndIf
    
        If !(cE1Situaca == AllTrim(SE1->E1_SITUACA))
            AAdd(aAlt, {STR0011, STR0012, "", STR0013 + " - "  + AllTrim(cE1Situaca), STR0014 + " - "  + AllTrim(SE1->E1_SITUACA)})   // "TRANSFERÊNCIA" "Transferência de carteira de cobrança:" "Situação anterior"  "Situação atual"
        EndIf
        // "TRANSFERÊNCIA" "Transferência de carteira de cobrança:" "Portador anterior" "Portador atual"
        If !(cE1Portado == (AllTrim(SE1->E1_PORTADO) + AllTrim(SE1->E1_AGEDEP) + AllTrim(SE1->E1_CONTA)))
            AAdd(aAlt, {STR0011, STR0012, "", STR0015 + " - "  +  AllTrim(cE1Portado), STR0016 + " - "  +;
            AllTrim(SE1->E1_PORTADO) + "-" + AllTrim(SE1->E1_AGEDEP) + "-" + AllTrim(SE1->E1_CONTA)})
        EndIf
    
        //numbor
        //chamada da Função que cria o Histórico de Cobrança
        FinAConc(aAlt)
    
        If cSituacao $ "0FG"        //Carteira, Carteira Protesto e Carteira Acordo
            PcoDetLan("000003", "01", "FINA136A")
            //Para as novas situacoes de cobranca
            //repito os processos padroes existentes de acordo com a categoria de cada uma
        ElseIf aSitAtu[3] //Descontada FRV->FRV_DESCON
            PcoDetLan("000003", "03", "FINA136A")
        ElseIf aSitAtu[1] //Carteira cSituacao $ "0|F|G"
            PcoDetLan("000003", "01", "FINA136A")
        EndIf
    
        //zera as variáveis para que o borderô não carregue os valores resultado da operação de transferência.
        nValor := nTaxaDesc := nTxIof := 0
    
        PcoFinLan("000003")
    
    End Sequence
    
    //obtem o ultimo help e adiciona na variável mensagem
    If !lOk
        If Empty(cMensagem)
            cMensagem := FinGetHelp()
    
            If Empty(cMensagem)
                cMensagem := STR0002 //"Erro inesperado na transferência entre carteiras."
            EndIf
        EndIf
    EndIf
    
    DbSelectArea("SE1")
    SE1->(MsUnlock())
    SE1->(DbSetOrder(nIndice))

Return Empty(cMensagem)

/*/{Protheus.doc} F136Valor
Tratamento para abatimento, acrescimos e decrescimos

@Obs   função original: F060Valor  
@author pequim

@since 02/12/2013
@version 1.0
/*/
Static Function F136Valor(cSituaca As Character) As Logical

    If FN022SITCB(cSituaca)[3] //Transferência p/ descontada
        If Empty(SE1->E1_NUMBOR)
            nAbatim := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", SE1->E1_MOEDA,;
            dDataBase, SE1->E1_CLIENTE, SE1->E1_LOJA,,, SE1->E1_TIPO)
    
            If MV_PAR08 == 1 //Abatimentos
                nValor -= nAbatim
            EndIf
            If MV_PAR09 == 1 //Acrescimos e Decrescimos
                nDescont    := SE1->E1_SDDECRES
                nJuros      := SE1->E1_SDACRESC
                nValor      += SE1->E1_SDACRESC - SE1->E1_SDDECRES
            EndIf
        Else
            //ElseIf Fn022SitCB(SE1->E1_SITUACA)[3] .And. !Empty(SE1->E1_NUMBOR)  //Transferencia de descontada p/ carteira
            nAbatim := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", SE1->E1_MOEDA,;
            dDataBase, SE1->E1_CLIENTE, SE1->E1_LOJA,,, SE1->E1_TIPO)
            nValor -= nAbatim
    
            If MV_PAR09 == 1 //Acrescimos e Decrescimos
                nDescont    := SE1->E1_SDDECRES
                nJuros      := SE1->E1_SDACRESC
                nValor      += SE1->E1_SDACRESC - SE1->E1_SDDECRES
            EndIf
        EndIf
    EndIf

Return .T.

/*/{Protheus.doc} Fa136VerSit
Verifica a Situacao do titulo 

@Obs    função original: Fa060VerSit
@author pequim
@since  02/12/2013
@param  cSituacao, character, Situação
@param  cPort136, character, Codigo do portador
@param  cAgen136, character, Agencia
@param  cConta136, character, Conta Corrente
@param  nValCred, numeric, Valor do credito
@param  nTaxaDesc, numeric, Taxa de desconto
@param  dDataMov, date, Data de movimento
@param  nValDesc, numeric, Valor de desconto
@param  lDesc, logical, Sinaliza se houve desonto ou nao
@param  nRetencao, numeric, Dias de retencao
@param  cClearing, character, Periodicidade do Clearing (localizado)
@param  aTempos, array, Combo de periodicidade do clearing

@return lRet, Validado ou nao
/*/
Static Function Fa136VerSit(cSituacao As Character, cPort136  As Character, cAgen136 As Character, cConta136 As Character,;
    nValCred As Numeric, nTaxaDesc As Numeric, dDataMov As Date, nValDesc As Numeric,;
    lDesc As Logical, nRetencao As Numeric, cClearing As Character, aTempos As Array) As Logical
    
    Local aAreaSE5      As Array
    
    Local cChave        As Character
    
    Local lIsCarteira   As Logical
    Local lIsDescont    As Logical
    Local lRet          As Logical
    
    Local nSeqOld       As Numeric
    Local nRecSe5       As Numeric
    Local nSequencia    AS Numeric
    
    aAreaSE5    := {}
    cChave      := ""
    lIsCarteira := FN022SITCB(cSituacao)[1]
    lIsDescont  := FN022SITCB(cSituacao)[3]
    lRet        := .T.
    nSeqOld     := 0
    nSequencia  := 0
    nRecSe5     := 0
    
    //Verifica se situação e banco/agencia/conta est„o coerentes.
    IF lIsCarteira  //Se situacao de cobranca for carteira
        IF !Empty(cPort136) .Or. !Empty(cAgen136) .Or. !Empty(cConta136)
            If cPaisLoc == "BRA"
                Help(" ",1,"CARTEIRA")
                lRet := .F.
            EndIf
        EndIf
    EndIf
    
    // Se for transferência para Desconto ele devera pegar a conta
    // corrente a ser creditada e a data do credito
    If lRet
        If lIsDescont .And. SE1->E1_SITUACA != cSituacao
            If ((FN022SITCB(SE1->E1_SITUACA)[1] .Or. GetNewPar("MV_TRFBCO","2") == "1"))
                Fa136Desc(@dDataMov, @nTaxaDesc, @nValCred, cSituacao)
                lDesc := .T.
            EndIf
            nRetencao := If(MV_PAR10 == 1, SA6->A6_RETENCA, 0)
        Else
            nRetencao   := SA6->A6_RETENCA
            nValCred    := nValor
        EndIf
    
        //  Estorno de cobrança descontada
        If FN022SITCB(SE1->E1_SITUACA)[3] .And. SE1->E1_SITUACA != cSituacao
            DbSelectArea("SE5")
            SE5->(DbSetOrder(2))
            If Empty(SE1->E1_NUMBOR)
                If MSSeek(FwXFilial("SE5") + "TR " +SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO))
                    nRecSE5     := SE5->(Recno())
                    nSequencia  := Val(SE5->E5_SEQ)
                    nSeqOld     := Val(SE5->E5_SEQ)
                    cNatureza   := SE5->E5_NATUREZ
                    While SE5->(!(EoF()))                       .And. ;
                    SE5->E5_FILIAL  == xFilial("SE5")   .And. ;
                    SE5->E5_TIPODOC == "TR"             .And. ;
                    SE5->E5_PREFIXO == SE1->E1_PREFIXO  .And. ;
                    SE5->E5_NUMERO  == SE1->E1_NUM      .And. ;
                    SE5->E5_PARCELA == SE1->E1_PARCELA  .And. ;
                    SE5->E5_TIPO    == SE1->E1_TIPO
    
                        nSequencia := Max(Val(SE5->E5_SEQ), nSequencia)
                        If nSeqOld < nSequencia
                            nRecSE5 := RecNo()
                            nSeqOld := nSequencia
                        EndIf
                        DbSkip()
                    EndDo
                    DbGoto(nRecSE5)
                    nValDesc := SE5->E5_VALOR
                    nValCred := SE5->E5_VALOR
                    If SE5->E5_VLDESCO < 0
                        nValDesc := SE1->E1_VALOR
                    EndIf
                    If lValorBruto .And. SE5->E5_VLDESCO <> 0 // se o valor a ser estornado é o valor bruto, calculo o valor bruto
                        nValDesc := SE5->E5_VALOR + SE5->E5_VLDESCO
                    EndIf
                    aAreaSE5    := SE5->(GetArea())
                    If DbSeek(SE5->E5_FILIAL + "I2" + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA +;
                    SE5->E5_TIPO + DToS(E5_DATA) +  SE5->E5_CLIFOR + SE5->E5_LOJA + SE5->E5_SEQ)
                        nVlrIOF := SE5->E5_VALOR
                    EndIf
                    RestArea(aAreaSE5)
                Else
                    nValDesc := 0
                EndIf
            Else
                nValDesc:= SE1->E1_VALOR
                cChave  := FwXFilial("SE5") + SE1->E1_NUMBOR
                aAreaSE5 := SE5->(GetArea())
                SE5->(Dbsetorder(10))
                If SE5->(DbSeek(cChave))
                    cNatureza := SE5->E5_NATUREZ
                    While AllTrim(SE5->E5_FILIAL + SE5->E5_DOCUMEN) == cChave .And. !SE5->(Eof())
                        If SE5->E5_TIPODOC == "I2"
                            nVlrIOF := SE5->E5_VALOR
                            Exit
                        EndIf
                        SE5->(DbSkip())
                    EndDo
                EndIf
                RestArea(aAreaSE5)
            EndIf
    
            DbSelectArea("SE1")
            lDesc := Fa136CanDe(@dDataMov, @nTaxaDesc, @nValDesc, @cNatureza, .F., @nVlrIOF, @nTxIOF)
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} Fa136Desc
Transferencia para desconto

@Obs    função original: Fa060Desc
@author pequim
@since  02/12/2013
@param  dDataMov, date, Data de movimento
@param  nTaxaDesc, numeric, Taxa de desconto
@param  nValCred, numeric, Valor do credito
@param  cSituacao, character, Situação de cobranca
/*/
Static Function Fa136Desc(dDataMov As Date, nTaxaDesc As Numeric, nValCred As Numeric, cSituacao As Character) AS Logical

    Local cPictIOF  As Character
    Local cPictTd   As Character
    
    Local dBaixa    As Date
    
    nTxMoeda := If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
    
    dBaixa := CriaVar("E1_BAIXA")
    
    cPictTd := PesqPict("SA6", "A6_TAXADES",, nMoeda)
    If cPaisLoc == "BRA"
        cPictIOF := PesqPict("SED", "ED_PERCIOF")
    EndIf
    
    //Se no cadastro de situacao de cobranca (FRV) faltar informacao,
    //usa informacoes do cadastro de bancos SA6
    dDataMov  := dDataBase + SA6->A6_RETDESC
    If nTaxaDesc == 0
        nTaxaDesc := FN022SITCB(cSituacao)[7]
        If nTaxaDesc > 0
            cPictTd := PesqPict("FRV","FRV_PERCEN",, nMoeda)
        EndIf
    EndIf
    
    If Empty(cNatureza)
        cNatureza := FN022SITCB(cSituacao)[8]
    EndIf
    
    If nTaxaDesc == 0
        nTaxaDesc   := SA6->A6_TAXADES
    EndIf
    
    If Empty(cPictTd)
        cPictTd     := PesqPict("SA6","A6_TAXADES",, nMoeda)
    EndIf
    
    If Empty(cNatureza)
        cNatureza := Substr(&(GetMv("MV_NATDESC")), 1, 10)
    EndIf
    cNatureza := PadR(cNatureza, 10)
    
    VALOR   := nValCred // Lanc Contabil
    IOF     := nVlrIOF

Return .T.

/*/{Protheus.doc} FA136Sit
Verifica se a situação informada esta correta

@Obs    função original: FA060Sit
@author pequim
@since  02/12/2013
@param  cSituacao, character, Situacao de cobranca a ser validada
@return lRetorna, retorna se válidado ou nao
/*/
Static Function FA136Sit(cSituacao As Character) As Logical

    Local aArea         As Array
    
    Local lRetorna      As Logical
    Local lIsCarteira   As Logical
    
    aArea       := {FRV->(GetArea()), GetArea()}
    lIsCarteira := FN022SITCB(cSituacao)[1]
    lRetorna    := .T.
    
    //Verifico se a situacao de cobranca esta cadastrada
    If !(cSituacao $ FN022LSTCB(0))
        Help(" ", 1, "SITCOB",, STR0008, 1, 0) //"Situação de cobrança não cadastrada. Verifique o cadastro de situações de cobrança."
        lRetorna := .F.
    EndIf
    
    //Verifico se a situação de cobrança é descontada
    If lRetorna .And. FN022SITCB(cSituacao)[2] .And. SE1->E1_TIPO $ MVABATIM
        Help(" ", 1, "FA060ABAT")
        lRetorna := .F.
    EndIf

    //Verifico se o Título está em Serasa e se a Situação de Cobrança permite Movimentação no Serasa
    If lRetorna .And. cPaisLoc == "BRA"
        FWA->(DbSetOrder(2))
        If FWA->(DbSeek(xFilial("SE1") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA))
            If FWA->FWA_STATUS != "0"
                FW2->(DbSetOrder(1))
                If FW2->(DbSeek(xFilial("FW2") + cSituacao + "0012"))
                    Help(" ", 1, "SITUACABLQ",, STR0017, 1, 0) //O título está em Serasa e essa situação de cobraça não permite movimentação no Serasa.
                    lRetorna := .F.
                EndIf
            EndIf
        EndIf
    EndIf
    
    AEval(aArea, {|area| RestArea(area)})

Return lRetorna

/*/{Protheus.doc} Fa136CanDe
Cancela transferencia para desconto

@Obs    função original: Fa060CanDe
@author pequim
@since  02/12/2013
@param  dDataMov, date, Data de movimento
@param  nTaxaDesc, numeric, Taxa de desconto
@param  nValCred, numeric, Valor do credito
@param  lCanBord, logical, Indica se é cancelamento de bordero
@param  nVlrIOF, numeric, Valor do IOF
@param  nTxIOF, numeric, taxa do IOF
/*/
Static Function Fa136CanDe(dDataMov As Date, nTaxaDesc AS Numeric, nValDesc As Numeric, cNatureza As Character,;
lCanBord As Logical, nVlrIOF As Numeric, nTxIOF As Numeric) As Logical

    Local aAreaSE1      As Array
    Local aAreaSE5      As Array
    
    Local cChaveSE1     As Character
    Local cFilialFK7    As Character
    Local cNumBord      As Character
    
    Local lRet          As Logical
    Local lValorZero    As Logical
    
    Local nDescAux      As Numeric
    Local nEstBor       As Numeric
    Local nEstIOFBor    As Numeric
    Local nOpca         As Numeric
    Local nTxIOFBor     As Numeric
    Local nValBor       As Numeric
    Local nValOri       As Numeric
    Local nVlrIOFBor    As Numeric
    
    Default nTaxaDesc   := 0
    Default nValDesc    := 0
    Default cNatureza   := Substr(&(GetMv("MV_NATDESC")), 1, 10)
    Default lCanBord    := .F.
    Default nVlrIOF     := 0
    Default nTxIOF      := 0
    
    aAreaSE1    := {}
    aAreaSE5    := {}
    cChaveSE1   := ""
    cFilialFK7  := ""
    cNumBord    := ""
    lRet        := .T.
    lValorZero  := .F. //Permitir estorno com valor zerado
    nDescAux    := 0
    nEstBor     := 0
    nEstIOFBor  := 0
    nOpca       := 0
    nTxIOFBor   := 0
    nValBor     := 0
    nValOri     := 0
    nVlrIOFBor  := 0
    
    dDataMov        := dDataBase + SA6->A6_RETDESC
    
    If !(Empty(SA6->A6_TAXADES))
        nTaxaDesc := SA6->A6_TAXADES
    EndIf
    
    If !Empty(SE1->E1_NUMBOR) .OR. lCanBord
        If lCanBord
            cNumBord := MV_PAR01
        Else
            cNumBord := SE1->E1_NUMBOR
        EndIf
    
        //Salva indice e posição atual
        aAreaSE1 := SE1->(GetArea())
        aAreaSE5 := SE5->(GetArea())
    
        //Altera ambiente da SE5
        SE5->(DbSetOrder(10)) //"E5_FILIAL+E5_DOCUMEN"
        If SE5->(DbSeek(FwXFilial("SE5") + cNumBord))
    
            While !SE5->(EoF()) .And. AllTrim(SE5->(E5_FILIAL + E5_DOCUMEN)) == AllTrim(xFilial('SE5') + cNumBord)
                //Procura pelo lançamento de IOF
                If AllTrim(SE5->E5_TIPODOC) == "I2"
                    nVlrIOFBor := SE5->E5_VALOR
                ElseIf AllTrim(SE5->E5_TIPODOC) == "BD"
                    nValBor := SE5->E5_VALOR
    
                    If SE5->E5_VLDESCO > 0
                        nDescAux := SE5->E5_VLDESCO
                    EndIf
    
                    nTaxaDesc := nDescAux / (nDescAux + nValBor) * 100
    
                ElseIf AllTrim(SE5->E5_TIPODOC) == "E2" //Se for um estorno de um título para carteira, feito separadamente, então desconsidera do valor total do borderô
                    cFilialFK7  := F136FK7Fil(cNumBord)
                    cChaveSE1   := cFilialFK7 + SE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA)
                    nValOri     := Posicione("SE1", 1, cChaveSE1, "E1_VALOR")
                    If SE5->E5_VALOR <> nValOri
                        nEstBor += SE5->E5_VALOR / (1 - (nTaxaDesc / 100))
                        nValBor -= SE5->E5_VALOR / (1 - (nTaxaDesc / 100))
                    Else
                        nEstBor += SE5->E5_VALOR
                        nValBor -= SE5->E5_VALOR
                    EndIf
                ElseIf AllTrim(SE5->E5_TIPODOC) == "EI" //Se for um estorno de IOF, então desconsidera do valor total do IOF do borderô
                    nEstIOFBor += SE5->E5_VALOR
                    nVlrIOFBor -= SE5->E5_VALOR
                EndIf
    
                SE5->(DbSkip())
            EndDo
    
        EndIf
    
        //Restaura ambiente da SE5
        RestArea(aAreaSE5)
        //Restaura ambiente da SE1
        SE1->(RestArea(aAreaSE1))
    
        If nVlrIOFBor > 0
            nTxIOFBor := (nVlrIOFBor * 100) / NoRound(nValBor + nVlrIOFBor, 4)
        EndIf
    
        //Se teve Desconto Obtem o Indice
        If nDescAux > 0 .And. nTaxaDesc == 0
            nTaxaDesc := ((nDescAux * 100) / (nValBor + nDescAux + nVlrIOFBor + nEstBor + nEstIOFBor))
        EndIf
    EndIf
    
    nTxIOF := nTxIOFBor
    If lCanBord //Se for cancelamento do Borderô, então considera os valores já obtidos do borderô pela SE5
        nVlrIOF := nVlrIOFBor
        nValDesc := nValBor + (nEstBor * (nTaxaDesc / 100))
        If lValorBruto .And. nTaxaDesc > 0 // se o valor a ser estornado é o valor bruto, calculo o valor bruto
            nValDesc := nValDesc / (1 - (nTaxaDesc / 100))
        EndIf
    Else //Se não for o cancelamento do borderô, então considera apenas a taxa de IOF aplicada no borderô e recalcula os valores com base no título que está sendo transferido
        If nVlrIOF > 0 .And. nTxIOF == 0 //Se não estiver em borderô, então o valor de IOF e o nValDesc já virão com os valores corretos
            nTxIOF := (nVlrIOF * 100) / NoRound(nValDesc + nVlrIOF, 4)
        Else
            If nTaxaDesc > 0 //Se houver desconto informado, então considero para calcular o valor correto do IOF a ser estornado
                If !lValorBruto // se o valor a ser estornado é o valor líquido, calculo o valor líquido
                    nValDesc := nValDesc - (nValDesc * (nTaxaDesc / 100))
                EndIf
    
                nVlrIOF := nValDesc * (nTxIOF / 100)
                nValDesc := nValDesc - nVlrIOF
            Else
                nVlrIOF := nValDesc * (nTxIOF / 100)
                nValDesc := nValDesc - nVlrIOF
            EndIf
        EndIf
    EndIf
    
    cNatureza   := cNatureza + Space(10 - Len(cNatureza))
    nValDesc    := IIf(Empty(nValDesc), SE1->E1_VALOR, nValDesc)
    
    If !lCanBord .And. MV_PAR09 == 1
        If nValDesc == SE1->E1_VALOR
            nValDesc := nValDesc - SE1->E1_DECRESC + SE1->E1_ACRESC
        EndIf
    EndIf
    
    If Fn022SitCB(SE1->E1_SITUACA)[3] .And. MV_PAR08 == 1 .And. !(Empty(SE1->E1_NUMBOR)) //Abatimentos só vão ser descontados no cancelamento, quando o título vier de borderô.
        If nAbatim > 0
            nValDesc -= nAbatim
        EndIf
    EndIf
    
    nOpca := 0
    
    If Empty(SE1->E1_NUMBOR)
        //Cálcula o Vlr da Tx do Iof para exibição em tela.
        If nTxIof == 0 .And. nVlrIOF > 0
            nTxIof := ((nVlrIOF * 100) / (SE5->E5_VALOR + nVlrIOF))
        EndIf
    EndIf
    
    //Não apresenta tela para rotina automática
    If F136VlDel(nValDesc, cNatureza, lCanBord, lValorZero, dDataMov)
        lRetorna := .T.
        nOpca := 1
    EndIf
    
    VALOR := nValDesc //Lanc Contabil
    IOF := nVlrIOF

Return lRet

/*/{Protheus.doc} F136VlDel
Validacao dos valores do estorno

@Obs    função original: Fa060VlDel
@author pequim
@since  02/12/2013
@version 1.0
/*/
Static Function F136VlDel(nValorDesc As Numeric, cNatureza As Character, lCanBord As Logical, lValorZero As Logical, dDataMov As Date) As Logical

    Local aArea         As Array
    Local aAreaSE1      As Array
    
    Local cFilFwSE5     As Character
    
    Local lRet          As Logical
    Local lGestao       As Logical
    Local lSEASE5Fil    As Logical
    
    Local nTaxa         As Numeric
    Local nTitBor       As Numeric
    Local nValor        As Numeric
    Local nValBor       As Numeric
    
    Default dDataMov := dDataBase
    
    lRet        := .T.
    nTaxa       := 0
    nValor      := nValorDesc
    nValBor     := 0
    //--- Tratamento Gestao Corporativa
    lGestao     := FwSizeFilial() > 2
    cFilFwSE5   := FwFilial("SE5")
    lSEASE5Fil  := .T.
    nTitBor     := 0
    aArea       := {}
    aAreaSE1    := SE1 -> (GetArea())
    
    If lGestao // TRATAMENTO PARA PEGAR FILIAL DA SEA SOMENTE SE AMBOS FOREM EXCLUSIVOS
        lSEASE5Fil := !Empty(FwFilial("SEA")) .And. !Empty(FwFilial("SE5"))
    Else
        lSEASE5Fil := !Empty(xFilial("SEA")) .And. !Empty(xFilial("SE5"))
    Endif
    
    If lCanBord
        Dbselectarea("SE1")
        SE1->(DbSetOrder(1))
        SE1->(DbSeek(xFilial("SE1") + SEA->(EA_PREFIXO + EA_NUM + EA_PARCELA + EA_TIPO)))
    EndIf
    
    nTaxa := IIf(SE1->E1_MOEDA # 1, IIf(!Empty(SE1->E1_TXMOEDA), SE1->E1_TXMOEDA, RecMoeda(dDataMov, SE1->E1_MOEDA)), 1)
    
    lValorZero := IIF(lValorZero == NIL, .F., lValorZero)
    
    IF SE1->E1_MOEDA > 1 .And. !lCanBord
        nValor := Round(NoRound(xMoeda(nValor, 1, SE1->E1_MOEDA, dDataMov, 3), 3), 2)
    Endif
    
    If lValorZero
        IF nValor < 0  .or. Empty(cNatureza) .or. (nValor > (SE1->E1_VALOR * nTaxa) .And. !lCanBord)
            lRet := .F.
        Endif
    Else
        //Posiciona no registro do bordero no SE5 para poder validar se o valor a ser estornado
        // superior ao valor do bordero
        aArea := GetArea()
        If !Empty(SE1->E1_NUMBOR)
            nEspNum := TamSX3("E5_DOCUMEN")[1] - TamSX3("E1_NUMBOR")[1]
            nNumBor := SE1->E1_NUMBOR + Space(nEspNum)
    
            // Bloco para tratar bordero gerado em filial difenrete do titulo *
            If TcSrvType() != "AS/400" .And. !Empty(cFilFwSE5)
                // Localiza a Filial do Bordero do titulo posicionado
                cQuery := "SELECT EA_FILIAL FROM " + RetSqlName("SEA")
                cQuery += " WHERE EA_FILORIG='" + SE1->E1_FILORIG + "' AND EA_NUMBOR='" + SE1->E1_NUMBOR + "' AND "
                cQuery += "EA_PREFIXO='" + SE1->E1_PREFIXO + "' AND EA_NUM='" + SE1->E1_NUM + "' AND EA_PARCELA='" + SE1->E1_PARCELA + "' AND "
                cQuery += "EA_TIPO='" + SE1->E1_TIPO + "'" // AND EA_FORNECE='" + SE1->E1_CLIENTE + "' AND EA_LOJA='" + SE1->E1_LOJA + "'"
                cQuery := ChangeQuery(cQuery)
                dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRBFIL', .F., .T.)
                If !TRBFIL->(EoF()) .And. lSEASE5Fil
                    cFilBorder := TRBFIL->EA_FILIAL
                Else
                    cFilBorder := xFilial("SE5")
                EndIf
                TRBFIL->(DbCloseArea())
            Else
                cFilBorder := xFilial("SE5")
            EndIf
    
            dbselectarea("SE5")
            SE5->(DbSetOrder(10))
            SE5->(MsSeek(cFilBorder + nNumBor))
            Do While SE5->(!(EoF())) .And. SE5->E5_FILIAL == cFilBorder .And. SE5->E5_DOCUMEN == nNumBor
                // Movimento de baixa por 2-Cobranca Descontada
                If SE5->E5_TIPODOC == "BD"
                    If SE5->E5_VLDESCO<>0 .And. !lCanBord
                        nValBor := SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC
                    Else
                        nValBor := SE5->E5_VALOR
                    EndIf
                EndIf
                SE5->(DbSkip())
            EndDo
    
            If Empty(nValorDesc)
                nValorDesc := nValor := nValBor
            EndIf
        EndIf
        //Valida o valor digitado na transferencia de descontada para carteira (Situaca = 0)
        //Valor digitado tem que ser maior que zero
        //A Natureza digitada deve existir
        //Caso seja processado via transferencia manual (nao eh cancelamento de bordero)
        //Valor de estorno nao pode ser maior que o valor do titulo + acrescimos - decrescimos e
        //Valor de estorno não pode ser maior que o valor do bordero
        If nValor <= 0 .or. Empty(cNatureza) .or. ;
        (!lCanBord .And. If(MV_PAR09 == 2, (nValor > SE1->E1_VALOR * nTaxa),;
        IIf(nTitBor <= 1, (nValor > SE1->(E1_VALOR + E1_ACRESC - E1_DECRESC) * nTaxa), .F.)) .Or.;
        (!Empty(SE1->E1_NUMBOR) .And. IIF(nTitBor > 1 ,nValor > nValBor * nTaxa, .F.)))
            lRet := .F.
        EndIf
        RestArea(aArea)
    EndIf
    
    If !lRet
        Help(" ", 1, "DADOSERR",, STR0007, 1, 0) //"Valor ou Natureza invalidos. Verifique."
    EndIf
    
    RestArea(aAreaSE1)

Return lRet

/*/{Protheus.doc} F136AntAp
Transfere título para carteita Techfin.

@author     Rafael Riego
@since      18/11/2019
@version    1.0
@param      oParcela, J, parcela a ser transferida para carteira techfin.
@param      cMsgErro, character, variável para obter a msg de erro após a execução (referência)
@param      cRetType, character, código do retorno da operação (referência)
@return     logical, verdadeiro em caso de sucesso
/*/
Function F136AntAp(oParcela As J, cMsgErro As Character, cRetType As Character) As Logical 

    Local aArea         As Array
    
    Local cCartTecF     As Character
    
    Default cMsgErro    := ""
    Default cRetType     := ""
    Default oParcela    := Nil
    
    aArea       := {SE1->(GetArea()), GetArea()}
    cCartTecF   := F136Cartei("MV_CARTECF")
    
    F136Transf(oParcela, cCartTecF, @cMsgErro, @cRetType)
    
    AEval(aArea, {|area| RestArea(area)})

Return Empty(cMsgErro)

/*/{Protheus.doc} F136Cancel
Transfere da carteira Techfin para a carteira 0.

@author     Rafael Riego
@since      25/11/2019
@version    1.0
@param      oParcela, J, parcela a ser transferida para carteira 0.
@param      cMsgErro, character, variável para obter a msg de erro após a execução (referência)
@return     logical, verdadeiro em caso de sucesso
/*/
Function F136Cancel(oParcela As J, cMsgErro As Character) As Logical

    Local aArea         As Array
    
    Local cCartTecF     As Character
   
    Default cMsgErro    := ""
    Default oParcela    := Nil
    
    aArea       := {SE1->(GetArea()), GetArea()}
    cCartTecF   := "0"

    If F136Transf(oParcela, cCartTecF, @cMsgErro)
        //Realiza transferência bancária da taxa de divergência comercial
        If oParcela["feeAmount"] > 0
            F136GerMov(oParcela, @cMsgErro, oParcela["feeAmount"])
        EndIf

        If Empty(cMsgErro)
            //Realiza transferência bancária da taxa original (transferência de carteira)
            If oParcela["feeAmountOrigin"] > 0
                F136GerMov(oParcela, @cMsgErro, oParcela["feeAmountOrigin"], 4)
            EndIf
        EndIf
    EndIf

    AEval(aArea, {|area| RestArea(area), FwFreeArray(area)})

Return Empty(cMsgErro)

/*/{Protheus.doc} F136GerMov
Efetua movimento bancário a pagar ou a receber.

@author     Rafael Riego
@since      03/02/2019
@version    1.0
@param      oParcela, J, parcela da movimentação
@param      cMsgErro, character, variável para obter a msg de erro após a execução (referência)
@param      nValor, numeric, taxa que será utilizada na movimento
@param      nOperacao, numeric, Identifica se será um movimento 3-a Pagar ou 4-a Receber.
@return     logical, verdadeiro em caso de sucesso
/*/
Function F136GerMov(oParcela As J, cMsgErro As Character, nValor As Numeric, nOperacao As Numeric) As Logical

    Local aInfoBanco    As Array
    Local aTransf       As Array

    Local cAgencia      As Character
    Local cBanco        As Character
    Local cConta        As Character
    Local cHistorico    As Character
    Local cNatureza     As Character

    Local nValTransf    As Numeric

    Default cMsgErro    := ""
    Default nOperacao   := 3 // 3 - Pagar - 4 - Receber 
    Default nValor       := oParcela["feeAmount"]

    Private lMsErroAuto As Logical
    Private lMsHelpAuto As Logical

    aTransf     := {}
    aInfoBanco  := F136AJstBc()
    cBanco      := aInfoBanco[1]
    cAgencia    := aInfoBanco[2]
    cConta      := aInfoBanco[3]
    cNatureza   := F136VerNat(nOperacao)
    cHistorico  := oParcela["taxHistory"] + "|" + oParcela["formattedErpId"]
    lMsHelpAuto := .T.
    lMsErroAuto := .F.
    nValTransf  := nValor

    //Obrigatório?
    //Sim - E5_DATA OK
    //Sim - E5_MOEDA OK
    //Sim - E5_VALOR OK
    //Sim - E5_NATUREZ OK
    //Sim - E5_BANCO OK
    //Sim - E5_AGENCIA OK
    //Sim - E5_CONTA OK

    AAdd(aTransf, {"E5_DATA",       dDataBase,  Nil})
    AAdd(aTransf, {"E5_MOEDA",      "R$",       Nil})
    AAdd(aTransf, {"E5_VALOR",      nValTransf, Nil})
    AAdd(aTransf, {"E5_NATUREZ",    cNatureza,  Nil})
    AAdd(aTransf, {"E5_BANCO",      cBanco,     Nil})
    AAdd(aTransf, {"E5_AGENCIA",    cAgencia,   Nil})
    AAdd(aTransf, {"E5_CONTA",      cConta,     Nil})
    AAdd(aTransf, {"E5_HISTOR",     cHistorico, Nil})
    //Contabilização On-line
    AAdd(aTransf, {"NAGLUTINA",     2,          Nil}) //1=Sim;2=Não
    AAdd(aTransf, {"NCTBONLINE",    1,          Nil}) //1=Sim;2=Não
    
    MsExecAuto({|pos_rotina, transferencia, operacao| FinA100(pos_rotina, transferencia, operacao)}, 0, aTransf, nOperacao)

    If lMsErroAuto
        cMsgErro := FinGetHelp()
        If Empty(cMsgErro)
            cMsgErro :=  STR0018 // "Erro não identificado na execução da rotina de transferência."
        EndIf
    EndIf

    FwFreeArray(aTransf)

Return Empty(cMsgErro)

/*/{Protheus.doc} F136GrvFI2
Rotina de gravação de registro na tabela FI2 para retirada de título do banco que já consta com o IDCNAB preenchido.

@type       Function
@author     Rafael Riego
@since      27/11/2019
@version    P12.1.27
@return     logical, sempre verdadeiro
/*/
Function F136GrvFI2() As Logical

    Local aArea     As Array
    
    Local cChave    As Character
    
    aArea   := {FI2->(GetArea()), GetArea()}
    cChave  := ""

    FI2->(DbSetOrder(1))
    cChave    :=    FwXFilial("FI2") + "1" +;
        SE1->(E1_NUMBOR + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)

    SEB->(DbSetOrder(1))
    If SEB->(DbSeek(FwXFilial("SEB") + SE1->E1_PORTADO + Pad("02", Len(SEB->EB_REFBAN)) + "E")) //Só executa se encontrar
        // Pesquisa pela ocorrencia nao gerada (FI2_GERADO = 2 - Ja esta na chave)
        If FI2->(DbSeek(cChave))
            RecLock("FI2", .F.)
        Else
            RecLock("FI2", .T.)
        EndIf

        Replace FI2_FILIAL      WITH FwXFilial("FI2")
        Replace FI2_CARTEI      WITH SE1->E1_SITUACA
        Replace FI2_OCORR       WITH SEB->EB_OCORR
        Replace FI2_GERADO      WITH "2"
        Replace FI2_NUMBOR      WITH SE1->E1_NUMBOR
        Replace FI2_PREFIX      WITH SE1->E1_PREFIXO
        Replace FI2_TITULO      WITH SE1->E1_NUM
        Replace FI2_PARCEL      WITH SE1->E1_PARCELA
        Replace FI2_TIPO        WITH SE1->E1_TIPO
        Replace FI2_CODCLI      WITH SE1->E1_CLIENTE
        Replace FI2_LOJCLI      WITH SE1->E1_LOJA
        Replace FI2_DTOCOR      WITH dDataBase
        Replace FI2_DESCOC      WITH SEB->EB_DESCRI
    EndIf

    FI2->(MsUnLock())

    AEval(aArea, {|area| RestArea(area)})

Return .T.

/*/{Protheus.doc} F136VerNat
Verifica a natureza de despesa e receita referente ao TOTVS antecipa.
 
@author     Fernando Navarro 
@since      06/05/2020
@version    1.0
@param      nOperacao, numeric, operação que em execução, sendo: 3=Pagar;4=Receber.
@return     character, código da natureza
/*/
Function F136VerNat(nOperacao As nNumeric) As Character 

    Local aArea     As Array

    Local cCond     As Character
    Local cDescri   As Character
    Local cNatureza As Character

    Local nTamNat   As Numeric

    Default nOperacao   := 4

    aArea       := GetArea()
    cNatureza   := ""
    nTamNat     := TamSX3("FK5_NATURE")[1]

    If nOperacao == 4 // Receber 
        cNatureza := SuperGetMV("MV_NTRTECF", .F., "RECETECHF")
    Else
        cNatureza := SuperGetMV("MV_NTPTECF", .F., "DESPTECHF")
    EndIf

    cNatureza := PadR(cNatureza, nTamNat)

    SED->(DbSetOrder(1))
    If SED->(!(MsSeek(FwXFilial("SED") + cNatureza)))

        If nOperacao == 4 // Receber 
            cCond     := "1"
            cDescri   := STR0023 + " TOTVS Antecipa" // Receitas
        Else
            cCond     := "2"
            cDescri   := STR0024 + " TOTVS Antecipa" // Despesas
        EndIf

        RecLock("SED",.T.)
        SED->ED_FILIAL  := xFilial("SED")
        SED->ED_CODIGO  := cNatureza
        SED->ED_CALCIRF := "N"
        SED->ED_CALCISS := "N"
        SED->ED_CALCINS := "N"
        SED->ED_CALCCSL := "N"
        SED->ED_CALCCOF := "N"
        SED->ED_CALCPIS := "N"
        SED->ED_DESCRIC := cDescri
        SED->ED_TIPO    := "2"
        SED->ED_COND    := cCond

        MsUnlock()
        FKCommit()
    EndIf

    RestArea(aArea)

Return cNatureza

/*/{Protheus.doc} F136ANFAnt
Função para avaliar se a nota fiscal esta antcipada, 

@type       function
@version    12.1.27 
@author     fernando.griecco
@since      21/05/2020
@param      cSerie, character, Série da Nota fiscal de devolução
@param      cNumero, character, Numero da Nota fiscal de devolução
@param      cCliente, character, Código do cliente 
@param      cLoja, character, Código da loja do cliente 
@param      cCartTecF, character, Carteira Techfin das notas antecipadas
@return     cCarteira, character, Carteira q a NCC será atribuida.
/*/
Function F136ANFAnt(cSerie As Character, cNumero As Character, cCliente As Character, cLoja As Character, cCartTecF As Character) As Character

    Local cCartDev  As Character
    Local cCarteira As Character
    Local cQuery    As Character

    Local lNfAnt    As Logical

    cCartDev    := F136Cartei("MV_DEVTECF")
    cCarteira   := "0"

    If !(Empty(cCartDev))
        cQuery := " SELECT COUNT(*) TOTAL "
        cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
        cQuery += " WHERE SD1.D_E_L_E_T_ = ' ' "
        cQuery += " AND   D1_FILIAL = '" + FwXFilial("SD1") + "' "
        cQuery += " AND   D1_TIPO = 'D' "
        cQuery += " AND   D1_DOC = '" + cNumero + "' "
        cQuery += " AND   D1_SERIE = '" + cSerie + "' "
        cQuery += " AND   D1_FORNECE = '" + cCliente + "' "
        cQuery += " AND   D1_LOJA = '" + cLoja + "' "
        //Avalia se algum dos documentos envolvidos no processo possui carteira antecipa 
        cQuery += " AND EXISTS (SELECT 'T' FROM " + RetSQLName("SE1") + " AUX " 
        cQuery += "     WHERE AUX.E1_FILIAL = '" + FwXFilial("SE1") + "'"
        cQuery += "     AND D1_FORNECE     = AUX.E1_CLIENTE "
        cQuery += "     AND D1_LOJA        = AUX.E1_LOJA " 
        cQuery += "     AND D1_NFORI       = AUX.E1_NUM "
        cQuery += "     AND D1_SERIORI     = AUX.E1_SERIE "
        cQuery += "     AND AUX.D_E_L_E_T_ = ' ' "
        cQuery += "     AND AUX.E1_SITUACA = '" + cCartTecF + "') "
        cQuery := ChangeQuery(cQuery)
        lNfAnt    := IIf(MpSysExecScalar(cQuery, "TOTAL") > 0 , .T., .F.)
        cCarteira := IIf(lNfAnt, cCartDev, "0")
    EndIf

    cCarteira := PadR(cCarteira, TamSX3("E1_SITUACA")[1])

Return cCarteira

/*/{Protheus.doc} F136LibNCC
Transfere a NCC da carteira Devolução Antecipa (MV_DEVTECF) para a carteira 0.

@author     Rafael Riego
@since      21/05/2020
@version    1.0
@param      oParcela, J, parcela a ser transferida para carteira 0.
@param      cMsgErro, character, variável para obter a msg de erro após a execução (referência)
@return     logical, verdadeiro em caso de sucesso
/*/
Function F136LibNCC(oParcela As J, cMsgErro As Character) As Logical

    Local aArea         As Array
    
    Local cCartTecF     As Character
   
    Default cMsgErro    := ""
    Default oParcela    := Nil
    
    aArea       := {SE1->(GetArea()), GetArea()}
    cCartTecF   := "0"

    //Adiciona a tag feeAmount caso ela não exista
    If oParcela["feeAmount"] == Nil
        oParcela["feeAmount"] := 0
    EndIf

    F136Transf(oParcela, cCartTecF, @cMsgErro)

    AEval(aArea, {|area| RestArea(area), FwFreeArray(area)})

Return Empty(cMsgErro)

/*/{Protheus.doc} F136BatAnt
Efetua o batimento de carteira para a operação de Antecipação.

@author     Rafael Riego
@since      03/06/2020
@version    1.0
@param      oParcela, J, parcela da NF cancelada que será antecipada
@param      cMensagem, character, variável para obter a msg de erro após a execução (referência)
@param      cRetType, character, código do retorno da operação (referência)
@return     logical, verdadeiro em caso de sucesso
/*/
Function F136BatAnt(oParcela As J, cMensagem As Character, cRetType As Character) As Logical

    Local aArea         As Array

    Local cOldHistor    As Character

    Local lSucesso      As Logical

    Default cMensagem    := ""
    Default oParcela    := Nil

    aArea       := {GetArea()}
    lSucesso    := .T.

    cOldHistor := oParcela["taxHistory"]

    oParcela["taxHistory"] := STR0026 //"ANT NF CANC"

    //Realiza movimentação bancária referente a antecipação da NF cancelada
    If oParcela["localAmount"] > 0
        F136GerMov(oParcela, @cMensagem, oParcela["localAmount"], 4)
    EndIf
 
    oParcela["taxHistory"] := cOldHistor

    //Realiza movimentação bancária da taxa da operação
    If Empty(cMensagem) .And. oParcela["feeAmount"] > 0
        F136GerMov(oParcela, @cMensagem, oParcela["feeAmount"], 3)
    EndIf

    If !(Empty(cMensagem))
        lSucesso := .F.
    Else
        cRetType := "08"
        cMensagem := STR0028 //"Nota Fiscal cancelada ou excluída. A Nota será recomprada automaticamente pelo TOTVS Antecipa."
    EndIf

    AEval(aArea, {|area| RestArea(area), FwFreeArray(area)})

Return lSucesso

/*/{Protheus.doc} F136BatRec
Efetua o batimento de carteira para a operação de Recompra.

@author     Rafael Riego
@since      03/06/2020
@version    1.0
@param      oParcela, J, parcela da NF cancelada que será recomprada
@param      cMsgErro, character, variável para obter a msg de erro após a execução (referência)
@return     logical, verdadeiro em caso de sucesso
/*/
Function F136BatRec(oParcela As J, cMsgErro As Character) As Logical

    Local aArea         As Array

    Local cOldHistor    As Character

    Default cMsgErro    := ""
    Default oParcela    := Nil
    
    aArea := {GetArea()}

    cOldHistor := oParcela["taxHistory"]

    oParcela["taxHistory"] := STR0027 //"REC NF CANC"

    //Realiza movimentação bancária da recompra
    If oParcela["localAmount"] > 0
        F136GerMov(oParcela, @cMsgErro, oParcela["localAmount"], 3)
    EndIf

    oParcela["taxHistory"] := cOldHistor

    //Realiza movimentação bancária da taxa da operação
    If Empty(cMsgErro) .And. oParcela["feeAmount"] > 0
        F136GerMov(oParcela, @cMsgErro, oParcela["feeAmount"], 3)
    EndIf

    AEval(aArea, {|area| RestArea(area), FwFreeArray(area)})

Return Empty(cMsgErro)

/*/{Protheus.doc} F136FK7Fil
Retorna a filial de um título em bordero de carteira descontada que sofreu estorno.

@obs        função original: F60FK7Fil
@author     rogerio melonio
@param      cNumBord, character, numero do borderô
@return     character, retorna a filial do titulo estornado de borderô de carteira descontada
@since      07/06/18
/*/
Static Function F136FK7Fil(cNumBord As Character) As Character
    
    Local cAliasTrb As Character 
    Local cFilDoc   As Character 
    Local cKeyOrig	As Character 
    Local cQuery    As Character 

    cAliasTrb   := GetNextAlias()
    cFilDoc     := ""
    cKeyOrig    := ""
    cQuery      := ""

    cQuery := "SELECT FK7_CHAVE "
    cQuery += "FROM " + RetSqlName("SE5") + " SE5 "
    cQuery += "INNER JOIN " + RetSqlName("FKA") + " FKA "
    cQuery += "	   ON FKA.FKA_FILIAL = SE5.E5_FILIAL AND FKA.FKA_IDORIG = SE5.E5_IDORIG AND FKA.FKA_TABORI = 'FK5' "
    cQuery += "INNER JOIN " + RetSqlName("FK5") + " FK5 "
    cQuery += "	   ON  FK5.FK5_FILIAL = FKA.FKA_FILIAL AND FKA.FKA_TABORI = 'FK5' AND FK5.FK5_IDMOV = FKA.FKA_IDORIG "
    cQuery += "INNER JOIN " + RetSqlName("FK7") + " FK7 "
    cQuery += "    ON FK7.FK7_FILIAL = FKA.FKA_FILIAL AND FK7.FK7_IDDOC = FK5_IDDOC "
    cQuery += "WHERE SE5.E5_FILIAL = '" + SE5->E5_FILIAL + "' AND SE5.E5_PREFIXO = '" + SE5->E5_PREFIXO + "' AND SE5.E5_NUMERO = '" + SE5->E5_NUMERO + "' "
    cQuery += "AND SE5.E5_PARCELA = '" + SE5->E5_PARCELA + "' AND SE5.E5_TIPO = '" + SE5->E5_TIPO + "' AND SE5.E5_CLIFOR = '" + SE5->E5_CLIFOR + "' "
    cQuery += "AND SE5.E5_LOJA = '" + SE5->E5_LOJA + "' AND SE5.E5_SEQ = '" + SE5->E5_SEQ + "' AND E5_DOCUMEN = '" + cNumBord +  "' "
    cQuery += "AND SE5.D_E_L_E_T_ = ''"

    cQuery := ChangeQuery(cQuery)

    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTrb, .T., .T.)
    If (cAliasTrb)->(!EoF())
        cKeyOrig := (cAliasTrb)->FK7_CHAVE
    EndIf

    (cAliasTrb)->(DbCloseArea())

    If !Empty(cKeyOrig)
        cFilDoc := SubStr(cKeyOrig, 1, At("|", cKeyOrig) - 1)
    EndIf

Return cFilDoc
