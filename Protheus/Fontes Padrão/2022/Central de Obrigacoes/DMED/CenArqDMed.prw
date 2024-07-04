#include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"

#define DMED        "4"

#define ORIGINAL     "N"
#define RETIFICADORA "S"

#define NORMAL       1
#define ESPECIAL     2

#define READY       "2"
#define FINISHED    "4"

#define PDTE_RECIBO "1"
#DEFINE RECIBO_OK   "2"
#DEFINE RETIFICADO  "3"
#DEFINE TAM_RECIBO  12

#define TOP         "1"
#define RTOP        "2"
#define DTOP        "3"
#define RDTOP       "4"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
/*/{Protheus.doc} CenArqDMed
    Classe responsável pela criação do arquivo .txt Dmed
    @type  Class
    @author david.juan
    @since 20201016
    @version 2020
    @see http://normas.receita.fazenda.gov.br/sijut2consulta/anexoOutros.action?idArquivoBinario=54814
/*/
Function CenArqDMed(cCodOpe,cCodObr,cCodComp,cAno,cTipo)
    Local oTxtDMed   := CenArqDMed():New()
    Local lSuccess   := .F.
    Default cCodOpe  := ""
    Default cAno     := ""
    Default cTipo    := ""
    Default cCodObr  := ""
    Default cCodComp := ""

    If cTipo == DMED
        dbSelectArea('B8M')
        B8M->(DbSetOrder( 1 ) )
        If B8M->(MsSeek(xFilial("B3D") + cCodOpe))
            oTxtDMed:setCodOpe(B8M->B8M_CODOPE)
            oTxtDMed:setCodObr(cCodObr)
            oTxtDMed:setCodComp(cCodComp)
            oTxtDMed:setTipo(cTipo)
            oTxtDMed:setRazSocOpe(B8M->B8M_RAZSOC)
            oTxtDMed:setCnpjOpe(B8M->B8M_CNPJOP)
            oTxtDMed:setAnoCalendar(cAno)                   //Ano Calendário: B3D_ANO
            While Pergunte("CENPERDMED",.T.,"Parâmetros Geração DMED")
                oTxtDMed:setAnoRef(MV_PAR01)                //Ano referencia: ?
                oTxtDMed:setTipoDeclaracao(MV_PAR02)        //Declaração Retificadora: ?
                oTxtDMed:setNumRecibo(MV_PAR03)             //Número do Recibo: ?
                oTxtDMed:setCNES(MV_PAR04)                  //CNES ?
                oTxtDMed:setCpfRespCnpj(MV_PAR05)           //CPF Resp.Perante CNPJ ?
                oTxtDMed:setSituacaoDeclaracao(MV_PAR06)    //Situação da Declaração ?
                oTxtDMed:setDataEvent(MV_PAR07)             //Data do evento: ?
                oTxtDMed:setIdEstrutura(MV_PAR08)           //Identificador de Estrutura ?
                oTxtDMed:setRespPreenchimento(MV_PAR09)   //CPF Resp.pelo Preenchimento ?
                oTxtDMed:setFolder(Alltrim(MV_PAR10))       //Diretorio do arquivo ?
                If oTxtDMed:validPergunte()
                    lSuccess := oTxtDMed:Execute()
                    Exit
                EndIf
            EndDo
            if lHabMetric .and. lLibSupFw .and. lVrsAppSw
                FWMetrics():addMetrics("Gera Arquivo para Envio - DMED", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
            endif

        EndIf
    Else
        Alert("Operação não disponível para este tipo de obrigação.")
    EndIf
    oTxtDMed:destroy()
    FreeObj(oTxtDMed)
    oTxtDMed    := nil
Return lSuccess

Function CenRecRet()
    Local oCenCltB2U    := CenCltB2U():New()
    Local oCltB2U       := nil
    local cMsg          := ""

    MV_PAR03 := ""
    If (MV_PAR01 >= "2016" .OR. MV_PAR01 <= cValToChar((Year(B3D->B3D_VCTO)))) .AND. MV_PAR02 == 2 // RETIFICADORA
        oCenCltB2U:setValue("healthInsurerCode" ,B3D->B3D_CODOPE)
        oCenCltB2U:setValue("requirementCode"   ,B3D->B3D_CDOBRI)
        oCenCltB2U:setValue("commitmentYear"    ,MV_PAR01)
        oCenCltB2U:setValue("commitmentCode"    ,B3D->B3D_CODIGO)
        oCenCltB2U:setValue("reference"         ,"01")
        oCenCltB2U:setValue("calendarYear"      ,B3D->B3D_ANO)

        oCenCltB2U:bscReqRet()

        oCenCltB2U:setValue("fileName"          ,B2U->B2U_NOMARQ)
        oCenCltB2U:setValue("status"            ,RECIBO_OK)
        If oCenCltB2U:bscChaPrim()
            oCltB2U := oCenCltB2U:mapFromDao()
            MV_PAR03 := oCltB2U:getValue("receiptNumber")
        EndIf
    ElseIf MV_PAR01 < "2016" .OR. MV_PAR01 > cValToChar((Year(B3D->B3D_VCTO)))
        cMsg += "1 - Ano referencia inválido (O ano deve estar entre 2016 e "+cValToChar(Year(B3D->B3D_VCTO))+")" + CRLF
    EndIf
    If !Empty(cMsg)
        MsgInfo(cMsg, "Central de Obrigações")
    EndIf
    oCenCltB2U:destroy()
    FreeObj(oCenCltB2U)
    oCenCltB2U := nil
    FreeObj(oCltB2U)
    oCltB2U := nil

Return

Class CenArqDMed From CenGeraTxt
    Data aRecnos        As Array
    Data cTipoDecla     As String
    Data cNumRecRet     As String
    Data cIdEstru       As String
    Data cCNES          As String
    Data cRespoCnpj     As String
    Data cRespoPree     As String
    Data cSitDecla      As String
    Data cDataEvent     As String

    Method New() Constructor
    Method validPergunte()
    Method Execute()
    Method saveFileLog()
    Method atuStatusByRecno()
    Method pictureVlrDmed(nValor)

    Method linDmed()
    Method linRESPO()
    Method linDECPJ()
    Method linOPPAS()
    Method linTOP()
    Method linRTOP()
    Method linDTOP()
    Method linRDTOP()
    Method linFIMDmed()

    Method getCltB2W()
    Method setIdEstrutura(nIdEstru)
    Method setDataEvent(dDataEvent)
    Method setSituacaoDeclaracao(nSitDecla)
    Method setCpfRespCnpj(cRespoCnpj)
    Method setRespPreenchimento(cRespoPree)
    Method setCNES(cCNES)
    Method setNumRecibo(cNumRecRet)
    Method setTipoDeclaracao(cTipoDecla)

EndClass

Method New() Class CenArqDMed
    _Super:New()
    self:aRecnos        := {}
    self:cTipoDecla     := ""
    self:cNumRecRet     := ""
    self:cIdEstru       := ""
    self:cCNES          := ""
    self:cRespoCnpj     := ""
    self:cRespoPree     := ""
    self:cSitDecla      := ""
    self:cDataEvent     := ""
Return self

Method validPergunte() Class CenArqDMed
    Local cMsg := ""

    If Empty(MV_PAR01) .And. UPPER(FunName())<>"RPC"
        cMsg += "1 - Ano referencia deve ser preenchido" + CRLF
    ElseIf MV_PAR01 < "2016" .OR. MV_PAR01 > cValToChar((Year(B3D->B3D_VCTO))) .And. UPPER(FunName())<>"RPC"
        cMsg += "1 - Ano referencia inválido (O ano deve estar entre 2016 e "+cValToChar((Year(B3D->B3D_VCTO)))+")" + CRLF
    EndIf
    If Empty(MV_PAR02) .And. UPPER(FunName())<>"RPC"
        cMsg += "2 - Declaração Retificadora deve ser preenchido" + CRLF
    EndIf
    If Empty(MV_PAR03) .And. MV_PAR02 == 2  .And. UPPER(FunName())<>"RPC"// RETIFICADORA
        cMsg += "3 - Número do Recibo é obrigatório para Declaração Retificadora = S" + CRLF
    EndIf
    If Empty(MV_PAR05) .And. UPPER(FunName())<>"RPC"
        cMsg += "5 - CPF Resp.Perante CNPJ deve ser preenchido" + CRLF
    EndIf
    If Empty(MV_PAR06) .And. UPPER(FunName())<>"RPC"
        cMsg += "6 - Situação da Declaração deve ser preenchido" + CRLF
    ElseIf YEAR(DATE()) <= Val(self:cAnoCalendar) .And. MV_PAR06 == NORMAL
        cMsg += "6 - Situação da Declaração deve ser = S-Especial para o Ano-Calendário posicionado" + CRLF
    EndIf

    If Empty(MV_PAR07) .And. MV_PAR06 == ESPECIAL .And. UPPER(FunName())<>"RPC"
        cMsg += "7 - Data do evento é obrigatório para situação = N-Especial" + CRLF
    EndIf

    If Empty(MV_PAR09) .And. UPPER(FunName())<>"RPC"
        cMsg +="9 - O campo com CPF Responsável deve ser preenchido" + CRLF
    EndIf

    If Empty(MV_PAR10) .And. UPPER(FunName())<>"RPC"
        cMsg += "10 - Diretorio do arquivo deve ser preenchido" + CRLF
    EndIf

    If !Empty(cMsg) .And. UPPER(FunName())<>"RPC"
        MsgInfo("Os campos abaixo estão inválidos: " + CRLF + cMsg)
    EndIf

Return (Empty(cMsg))

Method Execute() Class CenArqDMed
    local lSuccess := .F.

    self:setFileName(self:cCnpjOpe + "-Dmed-" + self:cAnoRef +;
        "-" + self:cAnoCalendar + "-" + If(self:cTipoDecla == "N",'ORIG','RETI') +;
        "-" + self:cSitDecla +"-" +self:cNumRecRet+".txt")
    If !self:downFromServer()
        self:linDmed()
        self:linRESPO()
        self:linDECPJ()
        self:linOPPAS()
        self:linTOP()
        self:linFIMDmed()

        If Empty(self:getErro())
            If self:saveFile()
                self:atuStatusByRecno()
                self:saveFileLog()
                self:saveInServer()
                If UPPER(FunName()) <> "RPC"
                    MsgInfo("Arquivo " + self:cFilename + CRLF + " gerado com sucesso em " + self:cFolder, "Central de Obrigações")
                EndIf
                lSuccess := .T.
            EndIf
        EndIf
    Else
        If UPPER(FunName()) <> "RPC"

            MsgInfo("O arquivo para esta competência já foi gerado anteriormente!" + CRLF +;
                "Para gerar novamente é necessário acessar a tela DMED -> Historico de Arquivos, e EXCLUIR o arquivo gerado " + CRLF + CRLF +;
                "O arquivo atual foi copiado para " + self:cFolder, "Central de Obrigações")
        EndIf
        lSuccess := .T.
    EndIf
    If !lSuccess
        If isBlind()
            ConOut(self:getErro())
        Else
            MsgAlert(self:getErro())
        EndIf
    EndIf
Return lSuccess

Method getCltB2W() Class CenArqDMed
    Local oCenCltB2W := CenCltB2W():New()
    If !Empty(oCenCltB2W)
        oCenCltB2W:setValue("healthInsurerCode", self:cCodOpe)
        oCenCltB2W:setValue("referenceYear"    , self:cAnoRef)
        If self:cTipoDecla == "N"
            oCenCltB2W:setValue("status"       , READY)
        ElseIf self:cTipoDecla == "S"
            oCenCltB2W:setValue("status"       , READY + "','" + FINISHED)
        EndIf
    EndIf
Return oCenCltB2W

Method saveFileLog() Class CenArqDMed
    Local oCenCltB2U   := CenCltB2U():New()

    oCenCltB2U:setValue("healthInsurerCode"        ,self:cCodOpe)           // B2U_CODOPE
    oCenCltB2U:setValue("requirementCode"          ,self:cCodObr)           // B2U_CODOBR
    oCenCltB2U:setValue("commitmentYear"           ,self:cAnoRef)           // B2U_ANOCMP
    oCenCltB2U:setValue("commitmentCode"           ,self:cCodComp)          // B2U_CDCOMP
    oCenCltB2U:setValue("reference"                ,"01")                   // B2U_REFERE
    oCenCltB2U:setValue("calendarYear"             ,self:cAnoCalendar)      // B2U_ANOCAL
    oCenCltB2U:setValue("fileName"                 ,self:cFilename )        // B2U_NOMARQ
    oCenCltB2U:setValue("fileDate"                 ,DToS(Date()))           // B2U_DATARQ
    oCenCltB2U:setValue("fileTime"                 ,Time())                 // B2U_HORARQ
    oCenCltB2U:setValue("receiptNumber"            ,"")                     // B2U_NUMREC
    If self:cTipoDecla == RETIFICADORA

        If !Empty(B2U->B2U_NOMARQ)
            oCenCltB2U:setValue("fileName"          ,B2U->B2U_NOMARQ )          // B2U_NOMARQ
        EndIf
        oCenCltB2U:setValue("status"                ,RECIBO_OK)
        oCenCltB2U:setValue("correctedReceiptNumber",self:cNumRecRet)           // B2U_RECRET
        If oCenCltB2U:bscChaPrim()
            oCenCltB2U:setValue("fileName"          ,self:cFilename )           // B2U_NOMARQ
            If !oCenCltB2U:bscChaPrim()
                oCenCltB2U:atuStatusByRecno(RETIFICADO, oCenCltB2U:getDbRecno())// B2U_STATUS
            EndIf
        EndIf
    EndIf
    oCenCltB2U:setValue("status"                   ,PDTE_RECIBO)                // B2U_STATUS

    oCenCltB2U:insert()

    oCenCltB2U:destroy()
    FreeObj(oCenCltB2U)
    oCenCltB2U := nil
Return

Method atuStatusByRecno() Class CenArqDMed
    Local oCltB2W      := CenCltB2W():New()
    If !Empty(self:aRecnos)
        aEval(self:aRecnos, {|x| oCltB2W:atuStatusByRecno(FINISHED, x)})
    EndIf

    oCltB2W:destroy()
    FreeObj(oCltB2W)
    oCltB2W := nil
Return

Method pictureVlrDmed(nValor) Class CenArqDMed
    Local cValor := ""
    Default nValor := 0
    cValor := AllTrim(StrTran(transform(nValor, "@E 9999999.99"),","))
Return cValor

// Dmed – Declaração de serviços médicos e de saúde
Method linDmed() Class CenArqDMed
    Local alinDmed  := {}
    aAdd(alinDmed, "Dmed" )
    aAdd(alinDmed, self:cAnoRef)            // PERGUNTE - Ano referência
    aAdd(alinDmed, self:cAnoCalendar )      // Ano-calendário
    aAdd(alinDmed, self:cTipoDecla  )       // PERGUNTE - Indicador de retificadora
    aAdd(alinDmed, self:cNumRecRet  )       // PERGUNTE - Número do recibo
    aAdd(alinDmed, self:cIdEstru  )         // PERGUNTE - Identificador de estrutura do leiaute
    self:setLine(alinDmed)

Return

// RESPO – Responsável pelo preenchimento
Method linRESPO() Class CenArqDMed
    Local alinRESPO     := {}
    Local oCenCltB6N    := CenCltB6N():New()
    Local oCenB6N       := nil

    aAdd(alinRESPO, "RESPO")
    If oCenCltB6N:getRespByCodOpe(self:cCodOpe, self:cRespoPree)
        oCenB6N := oCenCltB6N:mapFromDao()
        aAdd(alinRESPO, oCenB6N:getValue("ssn"))                // {"B6N_CPFRES"} - CPF
        aAdd(alinRESPO, AllTrim(oCenB6N:getValue("name")))      // {"B6N_NOMRES"} - Nome
        aAdd(alinRESPO, oCenB6N:getValue("areaCode"))           // {"B6N_DDDRES"} - DDD
        aAdd(alinRESPO, oCenB6N:getValue("phoneNumber"))        // {"B6N_TELRES"} - Telefone
        aAdd(alinRESPO, oCenB6N:getValue("extensionLine"))      // {"B6N_RAMALR"} - Ramal
        aAdd(alinRESPO, oCenB6N:getValue("fax"))                // {"B6N_FAXRES"} - Fax
        aAdd(alinRESPO, AllTrim(oCenB6N:getValue("eMail")))     // {"B6N_EMAILR"} - Correio eletrônico
    Else
        self:setErro("Não foi encontrado responsável pela Operadora " + self:cCodOpe)
    EndIf
    self:setLine(alinRESPO)

    oCenCltB6N:destroy()
    FreeObj(oCenCltB6N)
    oCenCltB6N := nil
    FreeObj(oCenB6N)
    oCenB6N := nil
Return

// DECPJ – Declarante pessoa jurídica
// - Registro obrigatório no arquivo quando for declarante pessoa jurídica;
Method linDECPJ() Class CenArqDMed
    Local alinDECPJ := {}

    aAdd(alinDECPJ, "DECPJ")
    aAdd(alinDECPJ, self:cCnpjOpe)          // {B8M_CNPJOP} - CNPJ
    aAdd(alinDECPJ, self:cRazSocOpe)        // {B8M_RAZSOC} - Nome empresarial
    aAdd(alinDECPJ, "2")                    // 2 – Operadora de plano privado de assistência à saúde;
    aAdd(alinDECPJ, self:cCodOpe)           // {B8M_CODOPE} - Registro ANS
    aAdd(alinDECPJ, self:cCNES)             // PERGUNTE - CNES
    aAdd(alinDECPJ, self:cRespoCnpj)        // PERGUNTE - CPF responsável perante o CNPJ
    aAdd(alinDECPJ, self:cSitDecla)         // PERGUNTE - Indicador de situação da declaração
    aAdd(alinDECPJ, self:cDataEvent)        // PERGUNTE - Data do evento
    self:setLine(alinDECPJ)
Return

// OPPAS – Operadora de plano privado de assistência à saúde
// - Ocorre caso o declarante seja operadora de plano privado de assistência à saúde.
Method linOPPAS() Class CenArqDMed
    Local alinOPPAS := {}
    aAdd(alinOPPAS, "OPPAS")
    self:setLine(alinOPPAS)
Return

// TOP – Titular do plano
//- Deve estar classificado em ordem crescente por CPF do titular;
//- Deve estar associado ao registro do tipo OPPAS.
Method linTOP() Class CenArqDMed
    Local alinTOP    := {}
    Local oTop       := nil
    Local oCltTop    := self:getCltB2W()

    If oCltTop:getAnoOpe()
        If oCltTop:getTop()
            oTop := oCltTop:mapFromDao()
            while oCltTop:HasNext()
                oTop := oCltTop:GetNext()
                aAdd(alinTOP, "TOP")
                aAdd(alinTOP, AllTrim(oTop:getValue("ssnHolder")))          // {"B2W_CPFTIT"} - CPF do titular
                aAdd(alinTOP, AllTrim(oTop:getValue("beneficiaryName") ))   // {"B2W_NOMBEN"} - Nome
                aAdd(alinTOP, self:pictureVlrDmed(oTop:getValue("expenseAmount")))  // {"B2W_VLRDES"} - Valor pago no ano com o titular
                self:setLine(alinTOP)
                alinTOP := {}
                aAdd(self:aRecnos, oCltTop:getDbRecno())
                self:linRTOP(AllTrim(oTop:getValue("ssnHolder")))
                self:linDTOP(AllTrim(oTop:getValue("ssnHolder")))
            Enddo
            FreeObj(oTop)
            oTop := nil
        Else
            self:setErro("Não existe nenhum registro do tipo TOP para montagem do arquivo")
        EndIf
    Else
        self:setErro("Não foram encontrados registros para a operadora " + self:cCodOpe + " e/ou o ano de " + self:cAnoRef)
    EndIf
    oCltTop:destroy()
    FreeObj(oCltTop)
    oCltTop := nil
Return

// RTOP – Reembolso do titular do plano
// - Deve estar classificado em ordem crescente por CPF/CNPJ do prestador de serviço (primeiro os CPF e depois os CNPJ);
// - Deve estar associado ao registro do tipo TOP;
// - Só deverá constar o registro se houver valor de reembolso do ano-calendário ou de anos-calendário anteriores.
Method linRTOP(cCpfTit) Class CenArqDMed
    Local alinRTOP      := {}
    Local oRTop         := nil
    Local oCltRTop      := self:getCltB2W()

    If oCltRTop:getAnoOpe()
        If oCltRTop:getRTop(cCpfTit)
            oRTop := oCltRTop:mapFromDao()
            while oCltRTop:HasNext()
                oRTop := oCltRTop:GetNext()
                aAdd(alinRTOP, "RTOP")
                aAdd(alinRTOP, AllTrim(oRTop:getValue("providerEinSsn")))       // {"B2W_CPFPRE"} - CPF/CNPJ do prestador de serviço
                aAdd(alinRTOP, AllTrim(oRTop:getValue("providerName")))         // {"B2W_NOMPRE"} - Nome/Nome empresarial do prestador de serviço
                aAdd(alinRTOP, self:pictureVlrDmed(oRTop:getValue("reimburseTotalValue")))        // {"B2W_VLRREE"} - Valor do reembolso do ano-calendário
                aAdd(alinRTOP, self:pictureVlrDmed(oRTop:getValue("previousYearReimburseT")))     // {"B2W_VLRANE"} - Valor do reembolso de anos anteriores
                self:setLine(alinRTOP)
                alinRTOP := {}
                aAdd(self:aRecnos, oCltRTop:getDbRecno())
            Enddo
            FreeObj(oRTop)
            oRTop := nil
        EndIf
    EndIf
    oCltRTop:destroy()
    FreeObj(oCltRTop)
    oCltRTop := nil
Return

// DTOP – Dependente do titular
// - Deve estar classificado em ordem crescente por CPF e Data de nascimento do dependente;
// - Deve estar associado ao registro do tipo TOP.
Method linDTOP(cCpfTit) Class CenArqDMed
    Local alinDTOP      := {}
    Local oDTop         := nil
    Local oCltDTop      := self:getCltB2W()

    If oCltDTop:getAnoOpe()
        If oCltDTop:getDTop(cCpfTit)
            oDTop := oCltDTop:mapFromDao()
            while oCltDTop:HasNext()
                oDTop := oCltDTop:GetNext()
                aAdd(alinDTOP, "DTOP")
                aAdd(alinDTOP, AllTrim(oDTop:getValue("ssnBeneficiary")))            // {"B2W_CPFBEN"} - CPF do dependente
                aAdd(alinDTOP, AllTrim(oDTop:getValue("dependentBirthDate")))        // {"B2W_DTNASD"} - Data de Nascimento
                aAdd(alinDTOP, AllTrim(oDTop:getValue("beneficiaryName")))           // {"B2W_NOMBEN"} - Nome
                aAdd(alinDTOP, AllTrim(oDTop:getValue("dependenceRelationship")))    // {"B2W_RELDEP"} - Relação de Dependência 03 Cônjuge/companheiro;04 Filho/filha;06 Enteado/enteada;08 Pai/mãe;10 Agregado/outros
                aAdd(alinDTOP, self:pictureVlrDmed(oDTop:getValue("expenseAmount"))) // {"B2W_VLRDES"} - Valor pago no ano com o dependente
                self:setLine(alinDTOP)
                alinDTOP := {}
                aAdd(self:aRecnos, oCltDTop:getDbRecno())
                self:linRDTOP(oDTop:getValue("ssnBeneficiary"), oDTop:getValue("beneficiaryName"))
            Enddo
            FreeObj(oDTop)
            oDTop := nil
        EndIf
    EndIf
    oCltDTop:destroy()
    FreeObj(oCltDTop)
    oCltDTop := nil
Return

// RDTOP – Reembolso do dependente
//- Deve estar classificado em ordem crescente por CPF/CNPJ do prestador de serviço (primeiro os CPF e depois os CNPJ);
//- Deve estar associado ao registro do tipo DTOP;
//- Só deverá constar o registro se houver valor de reembolso do ano-calendário e de anos-calendário anteriores.
Method linRDTOP(cCpfBenf, cBenefName) Class CenArqDMed
    Local alinRDTOP     := {}
    Local oRDTop        := nil
    Local oCltRDTop     := self:getCltB2W()

    If oCltRDTop:getAnoOpe()
        If oCltRDTop:getRDTop(cCpfBenf, cBenefName)
            oRDTop := oCltRDTop:mapFromDao()
            while oCltRDTop:HasNext()
                oRDTop := oCltRDTop:GetNext()
                aAdd(alinRDTOP, "RDTOP")
                aAdd(alinRDTOP, AllTrim(oRDTop:getValue("providerEinSsn")))     // {"B2W_CPFPRE"} - CPF/CNPJ do prestador de serviço
                aAdd(alinRDTOP, AllTrim(oRDTop:getValue("providerName")))       // {"B2W_NOMPRE"} - Nome/Nome empresarial do prestador de serviço
                aAdd(alinRDTOP, self:pictureVlrDmed(oRDTop:getValue("reimburseTotalValue")))       // {"B2W_VLRREE"} - Valor do reembolso do ano-calendário
                aAdd(alinRDTOP, self:pictureVlrDmed(oRDTop:getValue("previousYearReimburseT")))    // {"B2W_VLRANE"} - Valor do reembolso de anos anteriores
                self:setLine(alinRDTOP)
                alinRDTOP := {}
                aAdd(self:aRecnos, oCltRDTop:getDbRecno())
            Enddo
            FreeObj(oRDTop)
            oRDTop := nil
        EndIf
    EndIf
    oCltRDTop:destroy()
    FreeObj(oCltRDTop)
    oCltRDTop := nil
Return

// FIMDmed – Término da declaração
Method linFIMDmed() Class CenArqDMed
    Local alinFIMDmed   := {}
    aAdd(alinFIMDmed, "FIMDmed")
    self:setLine(alinFIMDmed)
Return

Method setIdEstrutura(nIdEstru) Class CenArqDMed
    If !Empty(nIdEstru)
        Do Case
            Case nIdEstru == 1
                self:cIdEstru := ""
            Case nIdEstru == 2
                self:cIdEstru := "S5830B"
            Case nIdEstru == 3
                self:cIdEstru := "P8915U"
            Case nIdEstru == 4
                self:cIdEstru := "L9368Z"
            Case nIdEstru == 5
                self:cIdEstru := "R2609P"
        EndCase
    EndIf
Return

Method setDataEvent(dDataEvent) Class CenArqDMed
    self:cDataEvent := DtoS(dDataEvent)
Return

Method setSituacaoDeclaracao(nSitDecla) Class CenArqDMed
    If nSitDecla == NORMAL
        self:cSitDecla := "N"
    ElseIf nSitDecla == ESPECIAL
        self:cSitDecla := "S"
    EndIf
Return

Method setCpfRespCnpj(cRespoCnpj) Class CenArqDMed
    self:cRespoCnpj := Alltrim(cRespoCnpj)
Return

Method setRespPreenchimento(cRespoPree) Class CenArqDMed
    self:cRespoPree := Alltrim(cRespoPree)
Return

Method setCNES(cCNES) Class CenArqDMed
    self:cCNES := AllTrim(cCNES)
Return

Method setNumRecibo(cNumRecRet) Class CenArqDMed
    self:cNumRecRet := AllTrim(cNumRecRet)
Return

Method setTipoDeclaracao(cTipoDecla) Class CenArqDMed
    If cTipoDecla == 1
        self:cTipoDecla := ORIGINAL
    ElseIf cTipoDecla == 2
        self:cTipoDecla := RETIFICADORA
    EndIf
Return