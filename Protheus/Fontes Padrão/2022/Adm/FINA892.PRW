#Include "PROTHEUS.CH"
#Include "FwMVCDEF.CH"
#Include "FINA892.CH"

#DEFINE DEF_FILIAL  1
#Define DEF_ENVIO   1
#Define DEF_CHECK   2
#Define DEF_ESTORNO 3
#Define DEF_DATA    2

Static __lPIXImp    := Nil
Static __lAutomat   := .F.
Static __lGrvF71    := .F.
Static __cProcPrinc := "FINI892"
Static __lUsaFlag   := Nil
Static __lIniCtb    := Nil
Static __lContabi   := Nil
Static __lPadrao    := Nil
Static __lDigita    := Nil
Static __lAglutin   := Nil
Static __cFilCtb    := ""
Static __lRec2Tit   := Nil
Static __lFinPix    := Nil
Static __lBaImpPix  := Nil
Static __lBordImp   := Nil
Static __lSitCPix   := Nil
Static __lCNABImp   := Nil
Static __nCasasDc   := Nil
Static __lLibTit    := Nil
Static __lMVGlosa   := Nil
Static __lTemDic    := Nil
Static __nPosData   := Nil
Static __lDiaDesc   := Nil
Static __ExcluiIm   := Nil
Static __oPagPix    := Nil

/*/{Protheus.doc} FINI892
	Função responsável por integrar o pix e realizar o cancelamento do mesmo.

	@author     Rafael Riego
	@since      18/01/2021
	@version    12.1.27
	@param      aInfo, array, informações para realizar conexão com o ambiente
	@param      l892Auto, logical, se é uma execução automática de automação ou não
	@param      oJAutoEnv, json, array JSON de automação de envio
	@param      oJAutoChk, json, array JSON de automação de consulta
	@param      oJAutoEst, json, array JSON de automação de cancelamento
	@return     Nil
/*/
Function FINI892(aInfo As Array, l892Auto As Logical, oJAutoEnv As J, oJAutoChk As J, oJAutoEst As J)
    Local cBusId     As Character
    Local cChave     As Character
    Local cCodEmp    As Character
    Local cCodFil    As Character
    Local cExtBusId  As Character
    Local cFunName   As Character
    Local cPass      As Character
    Local cPosId     As Character
    Local cTenant    As Character
    Local cUser      As Character
    Local lJob       As Logical
    Local lExecuta   As Logical
    Local lEnvAberto As Logical
    Local oConfig    As Object
    Local oPayHub    As Object
    
    Private cFilJob     As Character
    
    Default aInfo     := {}
    Default l892Auto  := .F.
    Default oJAutoEnv := Nil
    Default oJAutoChk := Nil
    Default oJAutoEst := Nil
    
    //Caso seja execução via robô, seta a variável static __lAutomat para true para realizar os desvios necessários no processo
    If l892Auto
        __lAutomat := .T.
    EndIf
    
    lExecuta   := .T.
    lEnvAberto := .F.
    lJob       := (Type("cFilAnt") == "U")
    
    If Len(aInfo) > 0
        cCodEmp := aInfo[1]
        cCodFil := aInfo[2]
    EndIf
    
    SetFunName("FINI892")
    cFunName := FunName()
    FwLogMsg("INFO",, STR0040, cFunName, "", "01", FwNoAccent(STR0002), 0, 0, {})
    
    //Se job e parâmetros em branco
    If (Empty(cCodEmp) .Or. Empty(cCodFil))
        FwLogMsg("ERROR",, STR0040, cFunName, "", "01", STR0003 + STR0004,  0, 0, {})
        Return Nil
    ElseIf !lJob .And. !__lAutomat
        FwLogMsg("ERROR",, STR0040, cFunName, "", "01", STR0005, 0, 0, {})
        Return Nil
    EndIf
    
    If !__lAutomat
        //Verifica se a empresa está montada
        RpcSetEnv(cCodEmp, cCodFil, /*cUser*/, /*cPass*/, "FIN", cFunName, {"SA2", "SA6", "SE2", "SEA", "SEE"})
        lEnvAberto := .T.
    EndIf
    
    //Efetua a trava para apenas efetuar um processamento por empresa
    If !LockByName("FINI892JOB" + cEmpAnt)
        FwLogMsg("INFO",, STR0040, cFunName, "", "01", STR0003 + STR0006, 0, 0, {})
        lExecuta := .F.
    EndIf
    
    If lExecuta
        cChave  := cEmpAnt
        oConfig := FwTFConfig()
        
        If ValType(cTenant := oConfig["fin_tenant_PagamentosDigitais_" + cChave]) == "U"
            cTenant  := ""
        EndIf

        If ValType(cUser := oConfig["fin_user_PagamentosDigitais_" + cChave]) == "U"
            cUser := ""
        EndIf

        If ValType(cPass := oConfig["fin_password_PagamentosDigitais_" + cChave]) == "U"
            cPass := ""
        EndIf

        If ValType(cPosId := oConfig["fin_idpos_PagamentosDigitais_" + cChave]) == "U"
            cPosId := ""
        EndIf

        If ValType(cBusId := oConfig["fin_busId_PagamentosDigitais_" + cChave]) == "U"
            cBusId := ""
        EndIf

        If ValType(cExtBusId := oConfig["fin_extBusId_PagamentosDigitais_" + cChave]) == "U"
            cExtBusId := ""
        EndIf
        
        lExecuta := (!Empty(cTenant) .And. !Empty(cUser) .And. !Empty(cPass) .And. !Empty(cPosId) .And. !Empty(cBusId))        
        
        If lExecuta
            oPayHub := PayHubPix():New(cExtBusId, cPosId, cTenant, cUser, cPass, "totvs_pagamento_digital_protheus_ro",, "BRL",, oJAutoEnv, oJAutoChk, oJAutoEst)
            
            //Valida integridade dos dados, conexão, existência do caixa e existência do código externo de unidade de negócio
            If __lAutomat .Or. (oPayHub:CheckIntegrity() .And. oPayHub:ValidConn() .And. oPayHub:ValidExternalBusinessUnitId() .And. oPayHub:ValidPosId(cBusId))
                //Carrega todos os dados a semem processados
                oPayHub:LoadData()
                
                //Efetua o processamento de todos os dados
                oPayHub:Execute()
            EndIf
        Else
            FwLogMsg("INFO",, STR0040, cFunName, "", "01", STR0003 + STR0029, 0, 0, {}) //"Dados para integração não preenchidos. Execute o Wizard PIX (FINA893).
        EndIf
    EndIf
    
    FreeObj(oConfig)
    FreeObj(oPayHub)
    UnLockByName("FINI892JOB" + cEmpAnt)
    
    If lEnvAberto
    	RpcClearEnv()
    EndIf
Return Nil

/*/{Protheus.doc} F892CtbInc()
    Efetua a contabilização dos títulos gerados para PIX

    @version    12.1.27
    @author     Edson Melo
    @Return     lRet, Logical, .T. Cancela retenção do título, .F. Não cancela retenção do título por estar em PIX
    @since      13/11/2020
/*/
Function F892CtbInc(cArquivo As Character, nHdlPrv As Numeric, cLoteATF As Character, nTotal As Numeric, aDadosProva As Array, aDiario As Array)
    Default aDadosProva := Nil
    Default aDiario     := {}
    
    //Grava Rodapé
    If nHdlPrv > 0
        RodaProva(nHdlPrv , nTotal, aDadosProva)
        
        //Envia para Lançamento Contábil
        cA100Incl(cArquivo, nHdlPrv, 3, cLoteATF, lMostraCtb, lAglutCtb,,,, @aFlagCTB, aDadosProva, aDiario)
        INCLUI := .F. //Não tirar - Impede a abertura do wizard FINA891 após o processamento do FA150PIX
        
        aFlagCTB := {}
        aDiario  := {}
        nHdlPrv := 0
    EndIf

Return Nil

/*/{Protheus.doc} F982MntPIX
    Função que realiza a manutenção da tabela F71 através do modelo de dados FINA890.

    @author     pedro castro
    @since      23/10/2020
    @version    P12
    @param      aDadosTit, array, dados do título para manutenção da tabela F71, sendo {1=Campo;2=Valor}
    @param      cOperation, character, operação a ser executada, sendo 1=Inclusão;2=Alteração
    @param      nF71Recno, numeric, recno do registro da tabela F71 que deverá ser atualizado
    @param      cErrorMsg, character, mensagem de erro caso não seja possível gravar a tabela F71 (referência)
    @return     logical, verdadeiro caso tenha atualizado o registro com sucesso
/*/
Function F982MntPIX(aDadosTit As Array, cOperation As Character, nF71Recno As Numeric, cErrorMsg As Character) As Logical
    Local aAreaF71   As Array
    Local aAreaAtual As Array
    Local lOk        As Logical
    Local nCampo     As Numeric
    Local nPosCampo  As Numeric
    Local nPosValor  As Numeric
    Local nQtdCmp    As Numeric
    Local oF71Model  As Object
    Local oModel     As Object
    Local nOperacao  As Numeric 
    Default aDadosTit   := {}
    Default cOperation  := "1"
    Default nF71Recno   := 0
    Default cErrorMsg   := ""
    
    aAreaAtual := GetArea()
    aAreaF71   := F71->(GetArea())
    nQtdCmp    := Len(aDadosTit)
    nPosCampo  := 1
    nPosValor  := 2
    
    If (lOk := (cOperation == "2"))
        F71->(DbSetOrder(1))
        
        If (lOk := (nF71Recno > 0))
            F71->(DbGoTo(nF71Recno))
            nOperacao := MODEL_OPERATION_UPDATE
        EndIf
        
        If !lOk
            cErrorMsg := STR0030 //"Registro não encontrado na tabela F71 para atualização."
        EndIf
    ElseIf (lOk := (cOperation == "1"))
        nOperacao := MODEL_OPERATION_INSERT
    EndIf
    
    If lOk
        oModel := FwLoadModel("FINA890")
        oModel:SetOperation(nOperacao)
        oModel:Activate()
        lOk := oModel:IsActive()
        
        If lOk
            oF71Model := oModel:GetModel("FORMF71")
            
            For nCampo := 1 To nQtdCmp
                If !(oF71Model:SetValue(aDadosTit[nCampo][nPosCampo], aDadosTit[nCampo][nPosValor]))
                    lOk := .F.
                    Exit
                EndIf
            Next nCampo
            
            If lOk .And. (lOk := (oModel:VldData()))
                oModel:CommitData()
            EndIf
        EndIf
    EndIf
    
    If !lOk .And. Empty(cErrorMsg)
        cErrorMsg := oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE]
    EndIf
    
    If oModel != Nil
        oModel:DeActivate()
        oModel:Destroy()
        oModel := Nil
    EndIf
    
    RestArea(aAreaF71)
    RestArea(aAreaAtual)
    FwFreeArray(aAreaF71)
    FwFreeArray(aAreaAtual)
Return lOk

/*/{Protheus.doc} PayHubPix
    Classe responsavel pela comunicação com o TOTVS Pagamentos Digitais

    @type       Class
    @author     Edson Melo/Rafael Riego
    @since      22/01/2021
    @version    12.1.27

    @Return
/*/
Class PayHubPix
    Method New()    CONSTRUCTOR

    //Tratamentos de erros e integridade.
    Method CheckIntegrity()     //Checa a integridade dos dados para consumir as API's
    Method SetError()
    Method CatchRestError()     //Captura e trata erros do Rest
    Method CleanError()         //Limpa mensagens de erro
    Method GetStatus()

    //Limpeza dos dados da transação anterior.
    Method CleanOldTransaction()

    //Geração/Manutenão do Token.
    Method GetToken()           //Busca o Token
    Method ExpirationDate()
    Method OutOfDate()

    //Geração do QRCode.
    Method LinkPaymentTransaction()

    //Verificação do pagamento - em lote
    Method GetPaymentLinkTransactions()

    //Estorno de transação.
    Method RefundTransaction()

    //Carrega as informações a serem processadas
    Method LoadData()

    //Executa o processamento dos dados encontrados através do método LoadData
    Method Execute()

    //Validação da conexão com o TOTVS PAGAMENTOS DIGITAIS
    Method ValidConn()

    //Validação do Caixa (IdPos) do TOVS Pagamentos Digitais
    Method ValidPosId()

    //Validação do código da unidade de negócio no TOVS Pagamentos Digitais
    Method ValidExternalBusinessUnitId()

    // Verifica se está em ambiente de homologação
    Method GetEnvHomolog()

    // Seta as informações de acordo com o ambiente que está executando (Homologação/Produção)
    Method GetURL()
    Method GetURLRac()
    Method GetCliSecret()
    Method GetMethod()

    Data aErrorMsg      As Array
    Data aFilData       As Array

    Data cBusId         As Character
    Data cClientId      As Character
    Data cCodeComp      As Character
    Data cCurrency      As Character
    Data cPinPadId      As Character
    Data cLastError     As Character
    Data cMethod        As Character
    Data cPassword      As Character
    Data cPosId         As Character
    Data cTenant        As Character
    Data cTimeExpi      As Character
    Data cToken         As Character
    Data cUserName      As Character

    Data cEnvHomolog    As Character
    Data cURL           As Character
    Data cURLRAC        As Character
    Data cCliSecret     As Character

    Data dExpDate       As Date

    Data oJAutoEnv      As J
    Data oJAutoChk      As J
    Data oJAutoEst      As J

    Data lStatus        As Logical

    Data nFilAtu        As Numeric

EndClass

/*/{Protheus.doc} New
    Metodo construtor da classe

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      22/01/2021
    @version    12.1.27
    @param      cCodeComp,  Character,  Codigo da empresa                   - 01
    @param      cPosId,     Character,  Caixa (Ponto de venda)              - 02
    @param      cTenant,    Character,  Empresa cadastrada no RAC           - 03
    @param      cUserName,  Character,  Usuario RAC                         - 04
    @param      cPassword,  Character,  Senha RAC                           - 05
    @param      cClientId,  Character,  Identificador do produto no RAC     - 06
    @param      cCliSecret, Character,  Senha do identificador              - 07
    @param      cCurrency,  Character,  Moeda atual                         - 08
    @param      cPinPadId,  Character,  Terminal                            - 09
    @Return     PayHubPix,  Object,     Objeto construído
/*/
Method New(cCodeComp, cPosId, cTenant, cUserName, cPassword, cClientId, cCliSecret, cCurrency, cPinPadId, oJAutoEnv, oJAutoChk, oJAutoEst) Class PayHubPix
    Local oConfig       As Object

    Default cCodeComp   := ""
    Default cPosId      := ""
    Default cTenant     := ""
    Default cUserName   := ""
    Default cPassword   := ""
    Default cClientId   := ""
    Default cCliSecret  := ""
    Default cCurrency   := "BRL"
    Default cPinPadId   := ""

    oConfig := FwTFConfig()

    Self:cTenant        := AllTrim(cTenant)
    Self:cUserName      := AllTrim(cUserName)
    Self:cPassword      := AllTrim(cPassword)
    Self:cClientId      := AllTrim(cClientId)
    Self:cCodeComp      := AllTrim(cCodeComp)
    Self:cCurrency      := AllTrim(cCurrency)
    Self:cPinPadId      := AllTrim(cPinPadId)
    Self:cPosId         := AllTrim(cPosId)
    Self:cEnvHomolog    := Self:GetEnvHomolog()
    Self:cURL           := Self:GetURL()
    Self:cURLRac        := Self:GetURLRAC()
    Self:cCliSecret     := Self:GetCliSecret()
    Self:cMethod        := Self:GetMethod()
    Self:lStatus        := .T.
    Self:aErrorMsg      := {}
    Self:cLastError     := ""
    Self:aFilData       := {}
    Self:oJAutoEnv      := oJAutoEnv
    Self:oJAutoChk      := oJAutoChk
    Self:oJAutoEst      := oJAutoEst
Return Self

/*/{Protheus.doc} GetEnvHomolog
    Método de acesso ao appserver.ini para verificar se irá executar em base de homologação

    @type       Method
    @author     sidney.silva
    @since      19/11/2021
    @version    1.0
    @Return     Self:cEnvHomolog, Character, variável que verifica o ambiente
/*/
Method GetEnvHomolog() As Character Class PayHubPix
    Self:cEnvHomolog := GetSrvProfString("FinPixHomologacao", "")
Return Self:cEnvHomolog

/*/{Protheus.doc} GetURL
    Método de acesso à propriedade de classe cURL

    @type       Method
    @author     Norberto M de Melo
    @since      19/11/2021
    @version    1.0
    @Return     NIL
/*/
Method GetURL() AS Character Class PayHubPix
    Self:cURL := IIf(Self:cEnvHomolog == "1",;
    "https://staging.raas.varejo.totvs.com.br/",;
    "https://raas.varejo.totvs.com.br/") 
Return Self:cURL

/*/{Protheus.doc} GetURLRac
    Método de acesso à propriedade de classe cURLRac

    @type       Method
    @author     Norberto M de Melo
    @since      19/11/2021
    @version    1.0
    @Return     NIL
/*/
Method GetURLRac() AS Character Class PayHubPix
    Self:cURLRAC := "https://" + AllTrim(Self:cTenant) + ".rac" 
    Self:cURLRAC += "." + IIf(Self:cEnvHomolog == "1", "staging.totvs.app" , "totvs.app")
Return Self:cURLRAC

/*/{Protheus.doc} GetCliSecret
    Método de acesso à propriedade de classe cCliSecret

    @type       Method
    @author     Norberto M de Melo
    @since      19/11/2021
    @version    1.0
    @Return     NIL
/*/
Method GetCliSecret() AS Character Class PayHubPix
    Self:cCliSecret := IIf(Self:cEnvHomolog == "1",;
    "39f56c0d-1a0d-48e9-94de-eb32f4e8877c",;
    "2fbdf0a3-8777-4045-8503-031bcae6af1e")
Return Self:cCliSecret

/*/{Protheus.doc} GetMethod
    Método de acesso à propriedade de classe cMethod

    @type       Method
    @author     Norberto M de Melo
    @since      19/11/2021
    @version    1.0
    @Return     NIL
/*/
Method GetMethod() AS Character Class PayHubPix
    Self:cMethod := IIf(Self:cEnvHomolog == "1", "shipaypagador", "pix")
Return Self:cMethod

/*/{Protheus.doc} ValidConn
    Valida conexão

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
    @Return     Logico, .T. se conseguiu gerar token, senão .F.
/*/
Method ValidConn() Class PayHubPix
    Local lGerToken As Logical
    
    //Inicializa variável
    lGerToken := !Empty(Self:GetToken()) 
Return lGerToken

/*/{Protheus.doc} GetToken
    Metodo responsavel por pegar o token de acesso ao RAC

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
    @Return     Objeto, Resultado do metodo.
/*/
Method GetToken() Class PayHubPix
    Local aHeadStr   As Array
    Local cParams    As Character
    Local cResult    As Character
    Local nTokenExpi As Numeric
    Local oRestClien As Object
    Local oJSON      As Object
    
    cParams    := ""
    aHeadStr   := {}
    cResult    := ""
    nTokenExpi := 0
    oRestClien := FwRest():New(Self:cURLRAC)
    oJSON      := JSONObject():new()
    
    If Self:OutOfDate() //Fora da validade?
        AAdd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")
        AAdd(aHeadStr, "charset: UTF-8")
        AAdd(aHeadStr, "User-Agent: Protheus " + GetBuild())

        cParams := "grant_type=password"
        cParams += "&username=" + Self:cUserName
        cParams += "&password=" + Self:cPassword
        cParams += "&scope=authorization_api"
        cParams += "&client_id=" + Self:cClientId
        cParams += "&client_secret="+ Self:cCliSecret

        oRestClien:SetPath("/totvs.rac/connect/token")
        oRestClien:SetPostParams(cParams)

        If oRestClien:Post(aHeadStr)
            cResult := oJSON:FromJSON(oRestClien:GetResult())
            
            If ValType(cResult) == "U"                        //Nil indica que conseguiu popular o objeto com o Json
                Self:cToken     := oJSON["access_token"]      //Chave de acesso
                nTokenExpi    := oJSON["expires_in"] / 60   //Expiração do token em minutos
                Self:ExpirationDate(nTokenExpi)
            Else
                Self:cToken := ""
                Self:SetError(STR0010 + cResult)
            EndIf
        Else
            Self:cToken := ""
            
            If ValType(oRestClien:cResult) == "U"
                oRestClien:cResult := STR0011
            EndIf
            
            Self:SetError(Self:CatchRestError(oRestClien))
        EndIf
    EndIf

    FreeObj(oRestClien)
    FreeObj(oJSON)
    FwFreeArray(aHeadStr)
Return Self:cToken

/*/{Protheus.doc} ExpirationDate
    Controle de expiração do Token

    @type       Method
    @author     Edson Melo
    @since      10/08/2020
    @version    12.1.27
    @param      nTime, Numerico, tempo para conversão
    @param      cTipo, Caracter, tipo da conversão
/*/
Method ExpirationDate(nTime As Numeric, cTipo As Char) Class PayHubPix
    Local cTime     As Character
    Local nDias     As Numeric
    Local nHora     As Numeric
    Local cTipoConv As Character
    
    Default nTime := 1
    Default cTipo := "M"
    
    //Inicializa variáveis
    cTime     := ""
    nDias     := 0
    nHora     := 0    
    cTipoConv := Upper(cTipo)
    
    nTime := IIf(cTipoConv == "H", (nTime * 60), (nTime / 60))    
    cTime := IncTime(Time(),, nTime)
    nHora := Val(SubStr(cTime, 1, 2))
    
    While nHora > 24
        nHora := nHora - 24
        nDias ++
    EndDo

    Self:cTimeExpi  := StrZero(nHora, 2) + SubStr(cTime, 3, Len(cTime))
    Self:dExpDate   := Date() + nDias
Return

/*/{Protheus.doc} OutOfDate
    Metodo responsavel verificar se o token esta vencido.

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
    @Return     Logico, Indica se o token esta vencido.
/*/
Method OutOfDate() Class PayHubPix
    Local lRet  As Logical
    Local dData As Date
    
    //Inicializa variáveis
    lRet  := .F.
    dData := Date()
    
    lRet := ((Empty(Self:dExpDate) .And. Empty(Self:cTimeExpi)) .Or.; 
        (Self:dExpDate == dData .And. Time() >= Self:cTimeExpi) .Or.;
        (Self:dExpDate < dData))
Return lRet

/*/{Protheus.doc} LinkPaymentTransaction
    Metodo responsavel para geração do QRCode do PIX

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
    @Return     Array, resultado da classe
/*/
Method LinkPaymentTransaction() Class PayHubPix
    Local aDadosEnv     As Array
    Local aDadosTit     As Array
    Local aHeadStr      As Array
    Local aRetImp       As Array
    Local cErrorMsg     As Character
    Local cParams       As Character
    Local cResult       As Character
    Local cVencto       As Character
    Local cSituaCob     As Character
    Local cTpDescFin    As Character
    Local dDtLimDesc    As Date
    Local lImposCalc    As Logical
    Local lDescFin      As Logical
    Local nBaseImpos    As Numeric
    Local nRegAtu       As Numeric
    Local nRegAuto      As Numeric
    Local nTxMoeda      As Numeric
    Local nVlrPix       As Numeric
    Local nDesconto     As Numeric
    Local nDecresc      As Numeric
    Local nAcresc       As Numeric
    Local nAbatImpos    As Numeric
    Local nAbatiment    As Numeric
    Local nOutrosAba    As Numeric 
    Local nVASoma       As Numeric
    Local nVASubtra     As Numeric
    Local nRecnoSE1     As Numeric
    Local nTaxaPerm     As Numeric
    Local nPerJuros     As Numeric
    Local nDescFin      As Numeric
    Local oJSON         As Object
    Local oRestClien   As Object
    Local nDiasExp      As Numeric
    
    //Contabilização
    Private aFlagCTB   As Array
    Private cArquivo   As Character
    Private cLote      As Character
    Private lAglutCtb  As Logical
    Private lCabec     As Logical
    Private lCancPix   As Logical
    Private lCtbPixOn  As Logical
    Private lMostraCtb As Logical
    Private nHdlPrv    As Numeric
    Private nTotal     As Numeric

    //Inicializa variáveis
    cErrorMsg   := ""
    lCancPix    := .F.
    aDadosEnv   := Self:aFilData[Self:nFilAtu][DEF_DATA][DEF_ENVIO]
    nRegAtu     := 0
    cParams     := ""
    aHeadStr    := {"Content-Type: application/json", ""}
    cResult     := ""
    oRestClien  := FwRest():New(Self:cURL)
    oJSON       := JSONObject():New()
    nVlrPix	    := 0
    nTxMoeda    := 0

    Pergunte("FINA890", .F.)
    
    lMostraCtb  := .F.
    lCtbPixOn   := MV_PAR02 == 1
    lAglutCtb   := MV_PAR03 == 1
    aFlagCTB    := {}
    __lPIXImp   := IIf(__lPIXImp == Nil, FindFunction("PIXGerImp"), __lPIXImp)
    __lFinPix   := IIf(__lFinPix == Nil, ExistBlock("FINVLPIX"), __lFinPix)
	__lBaImpPix := IIf(__lBaImpPix == Nil, FindFunction("BaseImpPix"), __lBaImpPix)
	__lBordImp  := IIf(__lBordImp == Nil, FindFunction("BorderoImp"), __lBordImp)
    __lSitCPix  := IIf(__lSitCPix == Nil, FindFunction("F022SITPIX"), __lSitCPix)
    __lCNABImp  := IIf(__lCNABImp == Nil, SuperGetMV("MV_CNABIMP", .F., .F.), __lCNABImp)
    __nCasasDc  := IIf(__nCasasDc == Nil, TamSX3("FK1_TXMOED")[2], __nCasasDc)
    __lMVGlosa  := IIf(__lMVGlosa == Nil, SuperGetMv("MV_GLOSA", .F., .F.), __lMVGlosa)
    __lTemDic   := IIf(__lTemDic == Nil, F71->(FieldPos("F71_DIAEXP")) > 0 .And. F71->(FieldPos("F71_MULTA")) > 0, __lTemDic)
    
    For nRegAtu := 1 To Len(aDadosEnv)
        Self:CleanOldTransaction()
        aDadosTit   := {}
        aFlagCTB    := {}
        aRetImp     := {}
        cArquivo    := ""
        cErrorMsg   := ""
        cLote       := ""
        nTotal      := 0
        nHdlPrv     := 0
        lCabec      := .F.
        lCancPix    := .F.
        nDesconto   := 0
        nMulta      := 0
        nJuros      := 0
        dDtLimDesc  := CToD("//")
        lImposCalc  := .T.
        nBaseImpos  := 0
        nVASoma     := 0
        nVASubtra   := 0
        nAbatImpos  := 0
        nOutrosAba  := 0
        nAbatiment  := 0
        nDecresc    := 0
        nAcresc     := 0
        nTaxaPerm   := 0
        nPerJuros   := 0
        lDescFin    := .F.
        cTpDescFin  := ""
        nDiasExp    := 0
        
        F71->(DbGoTo(aDadosEnv[nRegAtu]))
        If Empty(Self:cCodeComp) .Or. Empty(F71->F71_IDTRAN) .Or. Empty(F71->F71_VALOR) .Or. Empty(self:cCurrency) .Or. Empty(F71->F71_CODBAN) .Or.;
            Empty(F71->F71_AGENCI) .Or. Empty(F71->F71_NUMCON) .Or. Empty(F71->F71_FILBCO) .Or. Empty(F71->F71_TPCHV) .Or. Empty(F71->F71_CHVPIX)
            Self:SetError(STR0014, .T.)
            Loop
        EndIf
        
        If __lAutomat
            nRegAuto := BuscaRegJS(Self:oJAutoEnv, F71->F71_IDTRAN)
            
            If nRegAuto <= 0
                Self:SetError(STR0031, .T.)
                Loop
            EndIf
            
            oJSON := Self:oJAutoEnv[nRegAuto]
        EndIf
        
        DbSelectArea("SE1")
        SE1->(DbSetOrder(1))
        If !(SE1->(MsSeek(FwXFilial("SE1") + F71->(F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO))))
            Self:SetError(STR0015 + F71->(F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO), .T.)
            Loop
        EndIf
        
        SA1->(DbSetOrder(1))
        If !(SA1->(MsSeek(FwXFilial("SA1", SE1->E1_FILORIG) + SE1->(E1_CLIENTE+E1_LOJA))))
            Self:SetError("Cliente não encontrado! Código: " + SE1->E1_CLIENTE + "/Loja: " + SE1->E1_LOJA, .T.) //TODO STR
            Loop
        EndIf
        
        nRecnoSE1 := SE1->(Recno())
        nTxMoeda  := SE1->E1_TXMOEDA
        
        If SE1->E1_MOEDA > 1 .And. (Empty(nTxMoeda) .Or. !Empty(SE1->E1_DTVARIA))
            nTxMoeda := RecMoeda(IIf(Empty(SE1->E1_DTVARIA), dDataBase, SE1->E1_DTVARIA), SE1->E1_MOEDA)
        EndIf
        
        If __lBordImp .And. !__lCNABImp
            lImposCalc := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)
        EndIf
        
        If __lBaImpPix
            nBaseImpos := BaseImpPix(nRecnoSE1, @nVASoma, @nVASubtra, @nAbatImpos, nTxMoeda, @nOutrosAba)
        EndIf
        
        Begin Transaction
            If __lPIXImp .And. !lImposCalc .And. (!__lMVGlosa .Or. (__lMVGlosa .And. SE1->(E1_VALOR == E1_SALDO) .And. Empty(SE1->E1_BAIXA)))
                If !PIXGerImp(nBaseImpos, nTxMoeda)
                    cErrorMsg := STR0016 + F71->(F71_PREFIX+F71_NUM+F71_PARCEL+F71_TIPO)
                    DisarmTransaction()
                    Break
                EndIf
            EndIf
            
            nVlrPix	   := SE1->E1_SALDO
            nDescFin   := SE1->E1_DESCFIN
            cTpDescFin := SE1->E1_TIPODES
            nTaxaPerm  := SE1->E1_VALJUR
            nPerJuros  := SE1->E1_PORCJUR
            
            If (lDescFin  := (nDescFin > 0))
                dDtLimDesc  := DtDescFin()          
            EndIf
            
            If __lFinPix
                nVlrPix := ExecBlock("FINVLPIX")                
            Else
                If __lTemDic 
                    nMulta    := F71->F71_MULTA
                    nDiasExp  := F71->F71_DIAEXP
                EndIf
                
                If SE1->(E1_SDACRES+E1_SDDECRE) > 0
                    nVlrPix  += (SE1->E1_SDACRES - SE1->E1_SDDECRE)
                    nAcresc  := SE1->E1_SDACRES
                    nDecresc := SE1->E1_SDDECRE                
                EndIf
                
                If ((nVASoma > 0) .Or. (nVASubtra != 0 ))
                    nVlrPix += (nVASoma - Abs(nVASubtra))
                EndIf
                
                If (nAbatImpos+nOutrosAba) > 0
                    If SE1->E1_MOEDA > 1
                        If nAbatImpos > 0
                            nAbatImpos := Round(xMoeda(nAbatImpos, 1, SE1->E1_MOEDA, dDataBase, __nCasasDc, 0, nTxMoeda), 2)
                        EndIf
                        
                        If nOutrosAba > 0
                            nOutrosAba := Round(xMoeda(nOutrosAba, 1, SE1->E1_MOEDA, dDataBase, __nCasasDc, 0, nTxMoeda), 2)
                            nAbatiment := nOutrosAba 
                        EndIf
                    EndIf
                    
                    nVlrPix    -= (nAbatImpos+nOutrosAba)
                    nAbatiment := nOutrosAba
                EndIf
            EndIf
            
            cParams := "{"
            cParams += '"externalBusinessUnitId": "' + Self:cCodeComp      + '",'
            cParams += '"externalTransactionId": "'  + F71->F71_IDTRAN     + '",'
            cParams += '"amount" : '                 + CValToChar(nVlrPix) + ' ,'
            cParams += '"currency": "'               + self:cCurrency      + '",'
            cParams += '"externalPosId": "'          + Self:cPosId         + '",'
            cParams += '"wallet": "'                 + Self:cMethod        + '"'
                        
            //Informações do cliente para geração do pix cobrança
            cParams += ',"customer": {'
            cParams +=      '"id": "'    + AllTrim(SA1->(A1_COD+A1_LOJA)) + '",'
            cParams +=      '"email": "' + AllTrim(SA1->A1_EMAIL)         + '",'
            cParams +=      '"name": "'  + AllTrim(SA1->A1_NOME)          + '",' //Obrigatório
            cParams +=      '"ssn": "'   + AllTrim(SA1->A1_CGC)           + '",' //Obrigatório
            cParams +=      '"locale": ' + '"BRL"'
            cParams +=  "}"
            
            If Self:cMethod == "pix"
                cVencto := SubStr(FwTimeStamp(2, SE1->E1_VENCREA), 1, 10)
                cParams += ',"expirationDate" : "' + cVencto + ' 23:59", '
                
                //Informações sobre vencimento, abatimento, desconto, juros e multa
                cParams += '"due": {'   //Chave Due
                cParams +=          '"dueDate": "' + cVencto + '", '
                cParams +=          '"dayValidAfterDue": ' + CValToChar(nDiasExp) + ','            
                cParams +=      '"amountDetails": {'//Chave amountdetails
                
                //Descontos financeiro
                If lDescFin                    
                    If cTpDescFin == "1" //Desconto Fixo 
                        cParams +=      '"discount": {'
                        cParams +=          '"fixedDate": [{
                        cParams +=              '"date": "' + DToC(dDtLimDesc) + '", '
                        cParams +=              '"value": ' + CValToChar(nDescFin / 30)
                        cParams +=          "}],"
                        cParams +=          '"modality": "PercentageUntilTheDateInformed"'
                        cParams +=      "},"
                    ElseIf cTpDescFin == "2" //Desconto por dia de antecipacao
                        cParams +=      '"discountByDay": {'
                        cParams +=          '"modality": "PercentageInAdvanceCalendarDay",'
                        cParams +=          '"value": ' + CValToChar(nDescFin / 30 / 100)
                        cParams +=      "},"
                    EndIf
                EndIf
                
                //Multa
                cParams += '"fine": {'
                cParams +=      '"value": ' + CValToChar(nMulta) + ','
                cParams +=      '"modality": "FixedAmount"'
                cParams +=  "}"
                
                //Juros ou taxa de permanência            
                cParams += ',"interest": {' //Abre chave interest
                If nTaxaPerm > 0
                    cParams += '"value": ' + CValToChar(nTaxaPerm) + ','
                    cParams += '"modality": "AmountCalendarDay"'
                Else
                    cParams += '"value": ' + CValToChar(nPerJuros) + ','
                    cParams += '"modality": "PercentagePerCalendarDay"'
                EndIf
                
                cParams += "}"
                cParams += "}"
                cParams += "}"
                cParams += ',"pixDictKey": "' + AllTrim(F71->F71_CHVPIX) + '" '
            EndIf
            
            cParams += "}"
            
            aHeadStr[2] := "Authorization: Bearer " + IIf(!__lAutomat, Self:GetToken(), "")
            oRestClien:SetPath("/pay-hub/transacting/api/v2/payment/link")
            oRestClien:SetPostParams(cParams)
            
            If !__lAutomat
                If !(oRestClien:Post(aHeadStr))
                    cErrorMsg := Self:CatchRestError(oRestClien)
                    DisarmTransaction()
                    Break
                ElseIf ValType(cResult := oJSON:FromJSON(oRestClien:GetResult())) != "U"
                    cErrorMsg := STR0017 + cResult
                    Break
                EndIf
            EndIf
            
            If Empty(cErrorMsg)
                If Upper(oJSON["processorMessage"]) == "ERROR"
                    cErrorMsg := STR0022 + Self:cMethod
                    cErrorMSg += CRLF + STR0013 + oJSON["errorReason"]
                    DisarmTransaction()
                    Break
                Else
                    AAdd(aDadosTit, {"F71_STATUS", "3"})
                    AAdd(aDadosTit, {"F71_VLRPIX", nVlrPix})
                    AAdd(aDadosTit, {"F71_EMVPIX", oJSON["qrCode"]})
                    AAdd(aDadosTit, {"F71_IDPROC", oJSON["processorTransactionId"]})
                    AAdd(aDadosTit, {"F71_DTPSP",  dDataBase})
                    AAdd(aDadosTit, {"F71_IDPD",   oJSON["transactionId"]})
                    AAdd(aDadosTit, {"F71_HRPSP",  Time()})
                    AAdd(aDadosTit, {"F71_MENSAG", MntlogMsg(STR0041)})
                    
                    If __lTemDic
                        AAdd(aDadosTit, {"F71_DECRES", nDecresc})
                        AAdd(aDadosTit, {"F71_ACRESC", nAcresc})
                        AAdd(aDadosTit, {"F71_VASOMA", nVASoma})
                        AAdd(aDadosTit, {"F71_VASUBT", nVASubtra})
                        AAdd(aDadosTit, {"F71_ABATIM", nAbatiment})
                        
                        If lDescFin
                            AAdd(aDadosTit, {"F71_TPDESC", cTpDescFin})
                            AAdd(aDadosTit, {"F71_DTLIMI", dDtLimDesc})
                            AAdd(aDadosTit, {"F71_DESFIN", nDescFin})
                        EndIf
                        
                        AAdd(aDadosTit, {"F71_TXPERM", nTaxaPerm})
                        AAdd(aDadosTit, {"F71_PERJUR", nPerJuros})
                    EndIf
                    
                    If !(F982MntPIX(aDadosTit, "2", aDadosEnv[nRegAtu], @cErrorMsg))
                        DisarmTransaction()
                        Break
                    EndIf
                    
                    SE1->(DbGoTo(nRecnoSE1))
                    
                    If SE1->E1_SITUACA == "0" 
                        cSituaCob := IIf(__lSitCPix, F022SITPIX(), "")
                        cSituaCob := IIf(Empty(cSituaCob), SE1->E1_SITUACA, cSituaCob)
                        
                        Reclock("SE1", .F.)
                        SE1->E1_SITUACA := cSituaCob
                        SE1->(MsUnlock())
                    EndIf
                    
                    //Contabilização PIX
                    F150CtbPix()
                    
                    If nTotal > 0
                        F892CtbInc(cArquivo, @nHdlPrv, cLote, nTotal)
                    EndIf
                EndIf
            EndIf
        End Transaction
        
        If !(Empty(cErrorMsg))
            Self:SetError(cErrorMsg, .T.)
        EndIf
        
        FwFreeArray(aDadosTit)
        FwFreeArray(aRetImp)
    Next nRegAtu

    FwFreeArray(aHeadStr)
    FwFreeArray(aFlagCTB)
    FreeObj(oJSON)
    FreeObj(oRestClien)
Return Nil

/*/{Protheus.doc} RefundTransaction
    Metodo responsavel por realizar a transação de estorno do PIX

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      26/01/2021
    @version    12.1.27
    @Return     Array, resultado da classe
/*/
Method RefundTransaction() Class PayHubPix
    Local aDadosEsto  As Array
    Local aDadosTit   As Array
    Local aHeadStr    As Array
    Local cErrorMsg   As Character
    Local cParams     As Character
    Local cResult     As Character
    Local oJSON       As Object
    Local oRestClien  As Object
    Local nRegAtu     As Numeric
    Local nRegAuto    As Numeric
    Local nRecnoF71   As Numeric
    Local nRecnoSE1   As Numeric
    Local cIdDocF71   As Character   
    
    //Contabilização
    Private aFlagCTB   As Array
    Private cArquivo   As Character
    Private cLote      As Character
    Private nHdlPrv    As Numeric
    Private nTotal     As Numeric
    Private lAglutCtb  As Logical
    Private lCabec     As Logical
    Private lCancPix   As Logical
    Private lCtbPixOn  As Logical
    Private lMostraCtb As Logical

    aDadosEsto  := Self:aFilData[Self:nFilAtu][DEF_DATA][DEF_ESTORNO]
    lCancPix    := .T.
    cParams     := ""
    aHeadStr    := {"Content-Type: application/json", ""}
    cResult     := ""
    oRestClien  := FwRest():New(Self:cURL)
    oJSON       := JSONObject():New()
    nRecnoF71   := 0
    nRecnoSE1   := 0
    cIdDocF71   := ""
    
    Pergunte("FINA890", .F.)
    lMostraCtb := .F.
    lCtbPixOn  := MV_PAR02 == 1
    lAglutCtb  := MV_PAR03 == 1
    aFlagCTB   := {}

    For nRegAtu := 1 To Len(aDadosEsto)
        Self:CleanOldTransaction()
        aFlagCTB    := {}
        cErrorMsg   := ""
        cArquivo    := ""
        cLote       := ""
        nTotal      := 0
        nHdlPrv     := 0
        lCabec      := .F.
        lCancPix    := .F.

        F71->(DbGoTo(aDadosEsto[nRegAtu]))

        If IIf(!__lAutomat, Empty(F71->F71_IDPD) .Or. Empty(F71->F71_IDPROC), .F.) .Or.; //só valida os campos caso não seja automação (campos preenchidos por integração)
            Empty(Self:cCodeComp) .Or. Empty(F71->F71_IDTRAN) .Or. Empty(F71->F71_VALOR) .Or. Empty(self:cCurrency) .Or. Empty(Self:cPosId)
            Self:SetError(STR0014, .T.)
            Loop
        EndIf

        If __lAutomat
            If (nRegAuto := BuscaRegJS(Self:oJAutoEst, F71->F71_IDTRAN)) == 0
                Self:SetError(STR0031, .T.)
                Loop
            EndIf
            oJSON := Self:oJAutoEst[nRegAuto]
        EndIf

        DbSelectArea("SE1")
        SE1->(DbSetOrder(1))
        If !(MsSeek(FwXFilial("SE1") + F71->(F71_PREFIX + F71_NUM + F71_PARCEL + F71_TIPO)))
            Self:SetError(STR0015 + F71->(F71_PREFIX + F71_NUM + F71_PARCEL + F71_TIPO), .T.)
            Loop
        EndIf
        
        nRecnoF71   := F71->(Recno())
        nRecnoSE1   := SE1->(Recno())
        cIdDocF71   := F71->F71_IDDOC 
        aHeadStr[2] := "Authorization: Bearer " + IIf(!__lAutomat, Self:GetToken(), "")
        
        cParams := '{'
        cParams += '"transactionId"          : "' + F71->F71_IDPD              + '",'
        cParams += '"processorTransactionId" : "' + F71->F71_IDPROC            + '",'
        cParams += '"externalBusinessUnitId" : "' + Self:cCodeComp             + '",'
        cParams += '"externalTransactionId"  : "' + F71->F71_IDTRAN            + '",'
        cParams += '"amount"                 : '  + CValToChar(F71->F71_VALOR) + ' ,'
        cParams += '"currency"               : "' + self:cCurrency             + '",'
        cParams += '"posPadId"               : "' + "1"                        + '",'
        cParams += '"externalPosId"          : "' + Self:cPosId                + '"'
        cParams += '}'

        oRestClien:SetPath("/pay-hub/transacting/api/v2/payment/refund/")
        oRestClien:SetPostParams(cParams)

        If !__lAutomat
            If !(oRestClien:Post(aHeadStr))
                Self:SetError(Self:CatchRestError(oRestClien), .T.)
                Loop
            ElseIf ValType(cResult := oJSON:FromJSON(oRestClien:GetResult())) != "U"
                Self:SetError(STR0017 + cResult, .T.)
                Loop
            EndIf
        EndIf

        If Self:GetStatus()[1]
            Begin Transaction
                aDadosTit := {}
                AAdd(aDadosTit, {"F71_STATUS", "7"})
                
                If !(F982MntPIX(aDadosTit, "2", nRecnoF71, @cErrorMsg))
                    DisarmTransaction()
                    Break
                EndIf
                
                If __lLibTit
                    LibTitPix(cIdDocF71, nRecnoSE1)
                EndIf
                
                //Contabilização PIX
                F150CtbPix()
                
                If nTotal > 0
                    F892CtbInc(cArquivo, @nHdlPrv, cLote, nTotal)
                EndIf
            End Transaction
        EndIf
        
        If !(Empty(cErrorMsg))
            Self:SetError(cErrorMsg, .T.)
        EndIf
        
        FwFreeArray(aDadosTit)
    Next nRegAtu

    FwFreeArray(aHeadStr)
    FreeObj(oRestClien)
Return Self:GetStatus()

/*/{Protheus.doc} CatchRestError
    Metodo que seta erro originado pela integração através do objeto FwRest.

    @type       Method
    @author     Rafael Riego
    @since      19/08/2021
    @version    12.1.27
    @param      oRest, object, classe FwRest
    @return     character, mensagem de erro da execução de integração
/*/
Method CatchRestError(oRest) Class PayHubPix
    Local cErrorMsg As Character
    
    Default oRest := Nil

    cErrorMsg := ""

    If oRest != Nil
        cErrorMsg := oRest:GetHTTPCode()
        
        If !(Empty(oRest:cResult))
            cErrorMsg += CRLF + STR0012 + oRest:cResult //todo verificar decodeutf8
        EndIf
        
        cErrorMsg += CRLF + STR0013 + oRest:GetLastError()
    EndIf

Return cErrorMsg

/*/{Protheus.doc} SetError
    Metodo responsavel pelo indicativo de erro na classe

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
    @param      cMessage, Caracter, mensagem de erro
    @param      lSaveF71, logical, verdadeiro, se deve gravar no campo de log da tabela F71
/*/
Method SetError(cMessage, lSaveF71) Class PayHubPix

    Default lSaveF71 := .F.

    AAdd(Self:aErrorMsg, cMessage)
    FwLogMsg("ERROR",, STR0040, FunName(), "", "01", cMessage,  0, 0, {})
    Self:cLastError := cMessage
    Self:lStatus := .F.

    If lSaveF71
        GrvLogMsg(cMessage)
    EndIf

Return Nil

/*/{Protheus.doc} GrvLogMsg
    Função que realiza a gravação de mensagem de log na tabela F71.

    @type       Method
    @author     Rafael Riego
    @since      10/08/2020
    @param      cNewLogMsg, character, nova mensagem que será gravada no campo F71_MENSAG
    @return     character, nova mensagem concatenada com o conteudo do campo F71_MENSAG
/*/
Static Function GrvLogMsg(cNewLogMsg As Character) As Character
    Local cLogMsg   As Character

    Default cNewLogMsg  := ""

    cLogMsg := MntlogMsg(cNewLogMsg)

    If !(Empty(cLogMsg))
        F982MntPIX({{"F71_MENSAG", cLogMsg}}, "2", F71->(Recno()))
    EndIf

Return cLogMsg

/*/{Protheus.doc} MntlogMsg
    Função que realiza a montagem de mensagem de log na tabela F71.

    @type       function
    @author     Rafael Riego
    @since      24/11/2021
    @param      cNewLogMsg, character, nova mensagem que será gravada no campo F71_MENSAG
    @return     character, nova mensagem concatenada com o conteudo do campo F71_MENSAG
/*/
Static Function MntlogMsg(cNewLogMsg As Character) As Character
    Local cLogMsg   As Character
    
    Default cNewLogMsg  := ""
    
    cLogMsg := ""
    
    If !(Empty(cNewLogMsg))
        cLogMsg += "[" + STR0040 + ": " + FwTimeStamp(2) + "]" + CRLF
        cLogMsg += cNewLogMsg
        cLogMsg += IIf(Empty(F71->F71_MENSAG), "", CRLF + CRLF + F71->F71_MENSAG)
    EndIf

Return cLogMsg

/*/{Protheus.doc} CleanError
    Metodo responsavel limpar as mensagem de erro da classe.

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
/*/
Method CleanError() Class PayHubPix
    Self:lStatus    := .T.
    FwFreeArray(Self:aErrorMsg)
    Self:aErrorMsg := {}
Return Nil

/*/{Protheus.doc} CleanOldTransaction
    Metodo responsavel limpar os dados da transação anterior, no inicio de uma nova transação
    os objetos de retornos são limpos.

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
/*/
Method CleanOldTransaction() Class PayHubPix
    //Limpa os erros das transações anteriores
    Self:CleanError()
Return Nil

/*/{Protheus.doc} GetStatus
    Metodo responsavel por devolver o estatus atual da classe e as mensagens de erro caso existam.

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
    @Return     Array, Array com Status da ultima transação e mensagem da ultima transação
/*/
Method GetStatus() Class PayHubPix
Return {Self:lStatus, Self:aErrorMsg}

/*/{Protheus.doc} CheckIntegrity
    Metodo responsavel verificar a integridade geral da classe.

    @type       Method
    @author     Edson Melo/Rafael Riego
    @since      10/08/2020
    @version    12.1.27
/*/
Method CheckIntegrity() Class PayHubPix
    If Empty(Self:cCodeComp)
        Self:SetError(STR0027)
    EndIf

    If Empty(Self:cPosId)
        Self:SetError(STR0032)
    EndIf

    If Empty(Self:cTenant)
        Self:SetError(STR0033)
    EndIf

    If Empty(Self:cUserName)
        Self:SetError(STR0034)
    EndIf

    If Empty(Self:cPassword)
        Self:SetError(STR0035)
    EndIf

    If Empty(Self:cClientId)
        Self:SetError(STR0036)
    EndIf

    If Empty(Self:cCliSecret)
        Self:SetError(STR0037)
    EndIf

    If Empty(Self:cCurrency)
        Self:SetError(STR0028)
    EndIf
Return Self:GetStatus()[1]

/*/{Protheus.doc} ValidPosId
    Valida o id do caixa virtual no TOTVS PD.

    @type       Method
    @author     Rafael Riego
    @since      13/08/2021
    @version    12.1.27
    @param      cBusId, character, código interno da unidade de negócio registrada no TOTVS PD.
    @Return     Logico, verdadeiro caso o Pos Id seja válido
/*/
Method ValidPosId(cBusId) Class PayHubPix
    Local aHeadStr    As Array
    Local cParams     As Character
    Local cResult     As Character
    Local oJSON       As J
    Local lResult     As Logical
    Local oRestClien As Object
    
    Default cBusId      := ""
    
    aHeadStr    := {"Authorization: Bearer " + Self:GetToken()}
    cParams     := ""
    cResult     := ""
    oJSON       := JSONObject():New()
    oRestClien := FwRest():New(Self:cURL)
    lResult     := .F.
    
    oRestClien:SetPath("api/pay-hub/configuring/api/v1/pos/?externalIdValue=" + Self:cPosId + IIf(Empty(cBusId), "", "&businessUnitId=" + cBusId))
    
    If oRestClien:Get(aHeadStr)
        cResult  := oJSON:FromJSON(oRestClien:GetResult())
        
        If ValType(cResult) == "U"
            If Len(oJSON["items"]) >= 1
                lResult := .T.
            Else
                Self:SetError(STR0012 + STR0038)
            EndIf
        Else
            Self:SetError(STR0017 + cResult)
        EndIf
    Else
        Self:SetError(Self:CatchRestError(oRestClien))
    EndIf
    
    FreeObj(oRestClien)
    FreeObj(oJSON)
Return lResult

/*/{Protheus.doc} ValidExternalBusinessUnitId
    Valida o Código Externo da Unidade de Negócio no TOTVS PD.

    @type       Method
    @author     Rafael Riego
    @since      13/08/2021
    @version    12.1.27
    @param      cBusId, character, código interno da unidade de negócio registrada no TOTVS PD (referência).
    @Return     Logico, verdadeiro caso o External Business Id seja válido
/*/
Method ValidExternalBusinessUnitId(cBusId) Class PayHubPix
    Local aHeadStr    As Array
    Local cParams     As Character
    Local cResult     As Character
    Local oJSON       As J
    Local lResult     As Logical
    Local oRestClien As Object
    Local cMsgErro    As Character
    Local lExisteObj  As Logical
    
    Default cBusId      := ""
    
    aHeadStr    := {"Authorization: Bearer " + Self:GetToken()}
    cParams     := ""
    cResult     := ""
    oJSON       := JSONObject():New()
    oRestClien := FwRest():New(Self:cURL)
    lResult     := .F.
    cMsgErro    :=  ""
    lExisteObj  := .T.
    
    oRestClien:SetPath("api/pay-hub/configuring/api/v1/business-units/?externalId=" + Self:cCodeComp)
    
    If oRestClien:Get(aHeadStr)
        cResult    := oJSON:FromJSON(oRestClien:GetResult())
        lExisteObj := (ValType(cResult) == "U")
        cMsgErro   := IIf(lExisteObj, cMsgErro, (STR0017+cResult)) 
        cBusId     := ""
        
        If lExisteObj
            lExisteObj := (Len(oJSON["items"]) >= 1)
            cMsgErro   := IIf(lExisteObj, cMsgErro, (STR0012 + STR0039))
            
            If lExisteObj
                lResult := .T.
                cBusId := oJSON["items"][1]["id"]
            EndIf
        EndIf
    Else
        Self:SetError(Self:CatchRestError(oRestClien))
    EndIf
    
    If !lExisteObj
        Self:SetError(cMsgErro)
    EndIf
    
    FreeObj(oRestClien)
    FreeObj(oJSON)
Return lResult

/*/{Protheus.doc} LoadData
    Valida quais filiais possuem dados a serem integrados através da API.

    @type       Method
    @author     Rafael Riego
    @since      19/08/2021
    @version    12.1.27
/*/
Method LoadData() Class PayHubPix
    Local aArea         As Array
    Local aFilial       As Array
    Local aFilData      As Array
    Local aSM0          As Array
    Local cAgencia      As Character
    Local cBanco        As Character
    Local cConta        As Character
    Local cFilBco       As Character
    Local cFilOriAnt    As Character
    Local cQuery        As Character
    Local cSE1xF71      As Character
    Local cSolCan       As Character
    Local cStatus       As Character
    Local dDtVencRea    As Date
    Local nFilAtu       As Numeric
    Local nRecno        As Numeric
    Local nSM0          As Numeric
    Local nSM0PosIni    As Numeric

    aArea       := GetArea()
    aFilData    := {}
    aFilial     := {}
    aSM0        := FwLoadSM0()
    cFilOriAnt  := ""
    cQuery      := ""
    cSE1xF71    := GetNextAlias()
    nFilAtu     := 0
    nSM0PosIni  := AScan(aSM0, {|filial| filial[1] == cEmpAnt})

    For nSM0 := nSM0PosIni To Len(aSM0)
        If aSM0[nSM0][SM0_GRPEMP] == cEmpAnt
            AAdd(aFilial, aSM0[nSM0][SM0_CODFIL])
        EndIf
    Next nSM0

    cQuery := "SELECT SE1.E1_FILORIG, SE1.E1_VENCREA, F71.R_E_C_N_O_ RECNO, F71.F71_FILBCO, F71.F71_CODBAN, F71.F71_AGENCI, F71.F71_NUMCON, "
    cQuery += "F71.F71_STATUS, F71.F71_SOLCAN, F71.F71_IDPD "
    cQuery += "FROM " + RetSQLName("SE1") + " SE1 INNER JOIN " + RetSQLName("F71") + " F71 "
    cQuery += "ON (F71.F71_FILIAL = SE1.E1_FILIAL "
    cQuery += "AND F71.F71_PREFIX = SE1.E1_PREFIXO "
    cQuery += "AND F71.F71_NUM    = SE1.E1_NUM "
    cQuery += "AND F71.F71_PARCEL = SE1.E1_PARCELA "
    cQuery += "AND F71.F71_TIPO = SE1.E1_TIPO "
    cQuery += "AND F71.F71_CODCLI = SE1.E1_CLIENTE "
    cQuery += "AND F71.F71_LOJCLI = SE1.E1_LOJA "
    cQuery += "AND ((F71.F71_STATUS = '1' AND F71.F71_FILBCO <> ' ' AND F71.F71_CODBAN <> ' ' AND F71.F71_AGENCI <> ' ' AND F71.F71_NUMCON <> ' ') " //1= Gerar QR Code
    cQuery += "OR (F71.F71_SOLCAN = '1' AND F71.F71_STATUS IN ('3', '4') AND F71.F71_IDPD <> ' '))) " //1=Sim;2=Não e 3=QR Gerado;4=Cliente Notificado e IDPD preenchido
    cQuery += "WHERE " + FinSelFil(aFilial, "SE1", .F., .T., 20) + " "
    cQuery += "AND F71.D_E_L_E_T_ = ' ' "
    cQuery += "AND SE1.D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY SE1.E1_FILORIG, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO"
    
    cQuery   := ChangeQuery(cQuery)    
    cSE1xF71 := MPSysOpenQuery(cQuery)

    While (cSE1xF71)->(!EoF())
        If cFilOriAnt != (cSE1xF71)->E1_FILORIG
            AAdd(aFilData, {(cSE1xF71)->E1_FILORIG, {{}, {}, {}}})
            nFilAtu     += 1
            cFilOriAnt  := (cSE1xF71)->E1_FILORIG
        EndIf
        
        //Regras para Integração:
        //Enviar    = Status igual à 1 (aguardando envio) e campos de dados bancários preenchidos
        //Estornar  = Status igual à 3 (Qr Code Gerado) ou 4 (Cliente Notificado), Solicitação de Cancelamento igual à 1 (Sim) e Data de Vencimento maior ou igual a data base
        //Verificar = Status igual à 3 (Qr Code Gerado) ou 4 (Cliente Notificado)
        
        cSolCan     := (cSE1xF71)->F71_SOLCAN
        cStatus     := (cSE1xF71)->F71_STATUS
        dDtVencRea  := SToD((cSE1xF71)->E1_VENCREA)
        nRecno      := (cSE1xF71)->RECNO
        cAgencia    := (cSE1xF71)->F71_AGENCI
        cBanco      := (cSE1xF71)->F71_CODBAN
        cConta      := (cSE1xF71)->F71_NUMCON
        cFilBco     := (cSE1xF71)->F71_FILBCO
        cIdPD       := (cSE1xF71)->F71_IDPD
        
        If cStatus == "1" .And. !Empty(cFilBco) .And. !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cConta)
            AAdd(aFilData[nFilAtu][DEF_DATA][DEF_ENVIO],    nRecno)
        ElseIf (cStatus  == "3" .Or. cStatus == "4")
            If cSolCan == "1" .And. Date() <= dDtVencRea
                AAdd(aFilData[nFilAtu][DEF_DATA][DEF_ESTORNO],  nRecno)
            Else
                AAdd(aFilData[nFilAtu][DEF_DATA][DEF_CHECK],    cIdPD)
            EndIf
        EndIf
        
        (cSE1xF71)->(DbSkip())
    EndDo
    
    (cSE1xF71)->(DbCloseArea())
    Self:aFilData := AClone(aFilData)
    
    RestArea(aArea)
    FwFreeArray(aArea)
    FwFreeArray(aFilData)
    FwFreeArray(aFilial)
    FwFreeArray(aSM0)
Return Nil

/*/{Protheus.doc} Execute
    Efetua o processamento dos dados carregados através do método LoadData.

    @type       Method
    @author     Rafael Riego
    @since      19/08/2021
    @version    12.1.27
/*/
Method Execute() Class PayHubPix
    Local aSM0Area  As Array
    Local cFunName  As Character
    Local nFilial   As Numeric
    
    nFilial := 0

    //Não executa nenhuma filial caso nenhuma empresa esteja aberta
    If Select("SX2") == 0
        Return Nil
    EndIf
    
    cFunName := FunName()
    aSM0Area := SM0->(GetArea())
    
    FwLogMsg("INFO",, STR0040, cFunName, "", "01", cFilAnt + STR0003 + STR0008,  0, 0, {})

    //Executa caso não seja automação ou caso seja e possua dados a serem buscados
    If !__lAutomat .Or. Self:oJAutoChk != Nil
    	Self:GetPaymentLinkTransactions()
    EndIf
    
    For nFilial := 1 To Len(Self:aFilData)
        //Se na primeira execução o ambiente está aberto, verifica se a filial atual é a mesma de processamento para evitar reabertura na filial correta
        If Self:aFilData[nFilial][DEF_FILIAL] != cFilAnt
            cFilAnt := Self:aFilData[nFilial][DEF_FILIAL]
            SM0->(DbSetOrder(1))
            SM0->(DbSeek(cEmpAnt + cFilAnt)) //Posiciona na filial a ser processada
        EndIf
        
        Self:nFilAtu := nFilial
        
        If (!__lAutomat .And. Len(Self:aFilData[nFilial][DEF_DATA][DEF_ENVIO]) > 0) .Or. (__lAutomat .And. Self:oJAutoEnv != Nil)
            FwLogMsg("INFO",, STR0040, cFunName, "", "01", cFilAnt + STR0003 + STR0007,  0, 0, {})
            Self:LinkPaymentTransaction()
        EndIf
        
        If (!__lAutomat .And. Len(Self:aFilData[nFilial][DEF_DATA][DEF_ESTORNO]) > 0) .Or. (__lAutomat .And. Self:oJAutoEst != Nil)
            FwLogMsg("INFO",, STR0040, cFunName, "", "01", cFilAnt + STR0003 + STR0009,  0, 0, {})
            Self:RefundTransaction()
        EndIf
    Next nFilial

    RestArea(aSM0Area)
    FwFreeArray(aSM0Area)
    cFilAnt := SM0->M0_CODFIL
Return Nil

/*/{Protheus.doc} BuscaRegJS
    Busca registro dentro do JSON para realizar o processamento via automação.

    @type       function
    @author     Rafael Riego
    @since      26/08/2021
    @param      oJSON, json, array JSON de automação
    @param      cIdTran, character, id de transação do registro na tabel F71
    @return     numeric, posição do registro dentro do JSON (retorna 0 caso não encontrado)
/*/
Static Function BuscaRegJS(oJSON As J, cIdTran As Character) As Numeric
    Local nJSON     As Numeric
    Local nPosicao  As Numeric

    Default oJSON   := Nil
    Default cIdTran := Nil

    nPosicao := 0

    If oJSON != Nil .And. !(Empty(cIdTran))
        For nJSON := 1 To Len(oJSON)
            If oJSON[nJSON]:HasProperty("transactionId") .And. oJSON[nJSON]["externalTransactionId"] == cIdTran
                nPosicao := nJSON
                Exit
            EndIf
        Next nJSON
    EndIf

Return nPosicao

/*/{Protheus.doc} GetPaymentLinkTransactions
    Realiza a busca dos títulos em PIX que foram processados.

    @type       method
    @author     Rafael Riego
    @since      20/12/2021
    @return     nil
/*/
Method GetPaymentLinkTransactions() Class PayHubPix
    Local aAreaSM0      As Array
    Local aCabecalho    As Array
    Local cDtHoraFim    As Character
    Local cFilBkp       As Character
    Local cFimUTC       As Character
    Local cHoraLocal    As Character
    Local cIdCV8        As Character
    Local cIniUTC       As Character
    Local cMsgErro      As Character
    Local dDataLocal    As Date
    Local lErro         As Logical
    Local oTransacao    As J
    Local nQtdTrans     As Numeric
    Local nTransacao    As Numeric
    Local oRestCli      As Object
    
    Private oModelTaxa  As Object
    
    cHoraLocal := Time()
    dDataLocal := Date()
    
    DtHoraExec(@cDtHoraFim, @cIniUTC, @cFimUTC)
    
    aAreaSM0   := GetArea()
    aCabecalho := {}
    cFilBkp    := cFilAnt
    cPath      := "pay-hub/reporting/api/v1/settlement"
    cPath      += "?externalBusinessUnitId="   + Self:cCodeComp
    cPath      += "&startDateMov="             + cIniUTC
    cPath      += "&endDateMov="               + cFimUTC
    cPath      += "&externalPosId="            + Self:cPosId
    lErro      := .F.
    oRestCli   := FwRest():New(Self:cURL)
    oTransacao := Nil
    
    AAdd(aCabecalho, "accept: application/json")
    AAdd(aCabecalho, "Content-Type: application/json")
    AAdd(aCabecalho, "charset: UTF-8")
    AAdd(aCabecalho, "Authorization: Bearer " + IIf(__lAutomat, "", self:GetToken()))

    oRestCli:SetPath(cPath)

    If !__lAutomat
        If oRestCli:Get(aCabecalho)
            cHTTPCode := oRestCli:GetHTTPCode()

            If cHTTPCode == "200" //Sucesso
                oTransacao := JSONObject():New()
                lErro      := ValType(cResult := oTransacao:FromJSON(oRestCli:GetResult("transactions"))) <> "U"
            ElseIf cHTTPCode $ "401|403" // Não autorizado / Acesso Proibido
                lErro := .T.
            ElseIf cHTTPCode == "400" // Bad Request
                lErro := .T.
            EndIf
        Else
            Self:SetError(Self:CatchRestError(oRestCli))
            lErro := .T.
        EndIf
    EndIf
    
    If !lErro
        If __lAutomat
            oTransacao := Self:oJAutoChk
        EndIf
        
        nQtdTrans  := Len(oTransacao["transactions"])
        cIdCV8     := ""
        cSubProc   := FwTimeStamp(3)
        oModelTaxa := FwLoadModel("FINM030")
        
        For nTransacao := 1 To nQtdTrans
            cMsgErro  := ""
            __lGrvF71 := .F.
            
            If !FIN892Proc(oTransacao["transactions"][nTransacao], @cMsgErro)
                If Empty(cIdCV8)
                    ProcLogIni({}, __cProcPrinc, cSubProc, @cIdCV8)
                    ProcLogAtu("INICIO")
                EndIf
                
                Self:SetError(cMsgErro, __lGrvF71)
                ProcLogAtu("ERRO", "FINI892ERR", cMsgErro,, .F.)
            EndIf
        Next nTransacao
        
        If !(Empty(cIdCV8))
            ProcLogAtu("FIM")
        EndIf
        
        //Restaura SM0 para atualização do parâmetro MV_PIXDTHR
        cFilAnt := cFilBkp
        RestArea(aAreaSM0)
        GrvUltExec(cDtHoraFim)
        oModelTaxa:Destroy()
        FreeObj(oModelTaxa)

        If __oPagPix != Nil
            __oPagPix:Destroy()
            __oPagPix := Nil
        EndIf
    EndIf
    
    FwFreeArray(aAreaSM0)
    FwFreeArray(aCabecalho)
    FreeObj(oRestCli)
    FreeObj(oTransacao)
Return Nil

/*/{Protheus.doc} FIN892Proc
    Efetua o processamento de um título em PIX.

    possíveis status de retorno:

    1. Cancelado/Expirado   - Deve efetuar o cancelamento do PIX (Status = 7) e alteração do campo FKF_RECPIX para "2" (Não);
    2. Pendente             - Não deve realizar nenhuma ação, apenas atualizar a mensagem da tabela F71.
    3. Aprovado             - Pagamento realizado com sucesso. Alterar Status do PIX para '5' e baixar o título.

    @Obs        Tabelas F71 e SE1 devem estar posicionadas.
    @type       function
    @author     Rafael Riego
    @since      26/08/2021
    @param      oJSON, json, Posição da atual do JSON a ser processado
    @return     logical, retorno verdadeiro em caso de sucesso
/*/
Function FIN892Proc(oJSON As J, cErrorMsg As String) As Logical
    Local aAreaF71   As Array
    Local aAreaSE1   As Array
    Local aDadosPar  As Array
    Local aDadosTit  As Array
    Local aImpos     As Array
    Local aPCC       As Array
    Local aOutImp    As Array
    Local aTitulo    As Array
    Local cHistorico As Character
    Local cStatusId  As Character
    Local dDataBaixa As Date
    Local dDataAnt   As Date
    Local dDataCred  As Date
    Local lPIX       As Logical
    Local lProcessad As Logical
    Local nValorRec  As Numeric
    Local nValorLiq  As Numeric
    Local nRecnoSE1  As Numeric
    Local lExcluiImp As Logical
    Local nRecnoF71  As Numeric
    Local cChaveTit  As Character
    Local lRet       As Logical   
    
    Private lExecJob    As Logical
    Private lMsErroAuto As Logical
    Private lMVGlosa    As Logical
    Private nAbatim     As Numeric
    Private nAcresc     As Numeric
    Private nCofins     As Numeric
    Private nCsll       As Numeric
    Private nDecresc    As Numeric
    Private nDescont    As Numeric
    Private nIrrf       As Numeric
    Private nIss        As Numeric
    Private nJuros      As Numeric
    Private nlImpMR     As Numeric
    Private nMulta      As Numeric
    Private nParciais   As Numeric
    Private nPis        As Numeric
    Private nVaSoma     As Numeric
    Private nVaSubt     As Numeric

    Default oJSON       := Nil

    If oJSON == Nil
        cErrorMsg := STR0011
        Return .F.
    EndIf
    
    __lRec2Tit := IIf(__lRec2Tit == Nil, SuperGetMV("MV_REC2TIT",, "2") == "1", __lRec2Tit)    
    __lLibTit  := IIf(__lLibTit == Nil, FindFunction("LibTitPix"), __lLibTit)
    __lTemDic  := IIf(__lTemDic == Nil, F71->(FieldPos("F71_DIAEXP")) > 0 .And. F71->(FieldPos("F71_MULTA")) > 0, __lTemDic)
    __lCNABImp := IIf(__lCNABImp == Nil, SuperGetMV("MV_CNABIMP", .F., .F.), __lCNABImp)
	__ExcluiIm := IIf(__ExcluiIm == Nil, FindFunction("ExcluiImpo"), __ExcluiIm)
    
    aAreaF71    := F71->(GetArea())
    aAreaSE1    := SE1->(GetArea())
    aDadosTit   := {}
    aDadosPar   := {}
    aImpos      := {}
    aPCC        := {}
    aOutImp     := {}
    aTitulo     := {}
    cErrorMsg   := ""
    cHistorico  := STR0043
    lPIX        := .T.
    nValorLiq   := 0
    nValorRec   := 0
    lExcluiImp  := .F.
    nRecnoF71   := 0
    cChaveTit   := ""
    lRet        := .T.
    
    lMsErroAuto := .F.
    lExecJob    := .T. //controla execucao via Job utilizado para pontos de entrada que nao tem como passar o parametro
    nAbatim     := 0
    nAcresc     := 0
    nDecresc    := 0
    nJuros      := 0
    nDescont    := 0
    nMulta      := 0
    nVaSoma     := 0
    nVaSubt     := 0

    Begin Transaction
        cStatusId   := oJSON["status"]["id"]
        lProcessad  := oJSON["settled"]
        
        F71->(DbSetOrder(3))
        SE1->(DbSetOrder(1))
        
        If !(F71->(DbSeek(oJSON["externalTransactionId"])))
            cErrorMsg := STR0013 + STR0044 + oJSON["externalTransactionId"] + STR0045
            DisarmTransaction()
            Break
        ElseIf F71->F71_STATUS == "5" .And. cStatusId == "2" .And. lProcessad
            cErrorMsg := STR0013 + STR0046
            DisarmTransaction()
            Break
        ElseIf F71->F71_STATUS == "7" .And. cStatusId $ "3|4" .And. !lProcessad
            cErrorMsg := STR0013 + STR0047
            DisarmTransaction()
            Break
        EndIf
        
        If !SE1->(MsSeek(F71->(F71_FILIAL + F71_PREFIX + F71_NUM + F71_PARCEL + F71_TIPO)))
            cErrorMsg := STR0015 + F71->(F71_PREFIX + F71_NUM + F71_PARCEL + F71_TIPO)
            DisarmTransaction()
            Break
        ElseIf cFilAnt <> SE1->E1_FILORIG
            cFilAnt := SE1->E1_FILORIG
            SM0->(DbSeek(cEmpAnt + cFilAnt))
        EndIf
        
        __lGrvF71 := .T.
        nRecnoSE1 := SE1->(Recno())
        nRecnoF71 := F71->(Recno())
        
        If cStatusId $ "3|4" //Expired ou Cancelled
            If !__lCNABImp .And. __ExcluiIm
		        lExcluiImp := !BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)            
                
                If lExcluiImp
                    cChaveTit  := xFilial("SE1", SE1->E1_FILORIG)+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
                    lExcluiImp := !HistPagPix(SE1->E1_FILORIG, cChaveTit, @__oPagPix)
                    
                    If lExcluiImp
                        ExcluiImpo(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, nRecnoF71)
                    EndIf
                EndIf
            EndIf
            
            If !PIXCancel(F71->F71_FILIAL, F71->F71_IDDOC)
                cErrorMsg := FinGetHelp()
                DisarmTransaction()
                Break
            EndIf
            
            F71->(DbGoto(nRecnoF71))
            AAdd(aDadosTit, {"F71_STATUS", "7"})
            
            If !(F982MntPIX(aDadosTit, "2", nRecnoF71, @cErrorMsg))
                DisarmTransaction()
                Break
            EndIf
            
            If __lLibTit
                LibTitPix(F71->F71_IDDOC, nRecnoSE1)
            EndIf
        ElseIf cStatusId == "1" //Pending
            GrvLogMsg(STR0042)
        ElseIf cStatusId == "2" .And. lProcessad //aprovado e processado
            nValorRec  := oJSON["amount"]["transaction"]
            nValorLiq  := oJSON["amount"]["deposited"]
            nTaxa      := IIf(oJSON["amount"]["fee"] != Nil, oJSON["amount"]["fee"], 0)            
            dDataBaixa := FwDateTimeToLocal(oJSON["operationDate"])[1]
			dDataCred  := FwDateTimeToLocal(oJSON["liquidationDate"])[1]        
            
            If __lTemDic
                nAcresc   := F71->F71_ACRESC
                nDecresc  := F71->F71_DECRES
                nAbatim   := F71->F71_ABATIM
                nVA       := F71->(F71_VASOMA-F71_VASUBT)
                nMulta    := CalcMulta(dDataBaixa)
                nJuros    := CalcJuros(dDataBaixa)
                nDescont  := CalcDesFin(dDataBaixa)
                nValorRec += (Abs(F71->F71_VASUBT) + nDecresc + nDescont) - (F71->F71_VASOMA + nAcresc + nJuros + nMulta)
            EndIf
            
            AAdd(aDadosTit, {"F71_STATUS", "5"})
            AAdd(aDadosTit, {"F71_MENSAG", MntlogMsg(STR0049)})
            
            If Empty(cErrorMsg)
                AAdd(aTitulo, {"E1_PREFIXO"     , F71->F71_PREFIX   , Nil}) // 01
                AAdd(aTitulo, {"E1_NUM"         , F71->F71_NUM      , Nil}) // 02
                AAdd(aTitulo, {"E1_PARCELA"     , F71->F71_PARCEL   , Nil}) // 03
                AAdd(aTitulo, {"E1_TIPO"        , F71->F71_TIPO     , Nil}) // 04
                AAdd(aTitulo, {"AUTMOTBX"       , "NOR"             , Nil}) // 05
                AAdd(aTitulo, {"AUTDTBAIXA"     , dDataBaixa        , Nil}) // 06
                AAdd(aTitulo, {"AUTDTCREDITO"   , dDataCred         , Nil}) // 07
                AAdd(aTitulo, {"AUTHIST"        , cHistorico        , Nil}) // 08
                AAdd(aTitulo, {"AUTVALREC"      , nValorRec         , Nil}) // 09
                AAdd(aTitulo, {"AUTJUROS"       , nJuros            , Nil}) // 10
                AAdd(aTitulo, {"AUTDESCONT"     , nDescont          , Nil}) // 11
                AAdd(aTitulo, {"AUTMULTA"       , nMulta            , Nil}) // 12
                AAdd(aTitulo, {"AUTACRESC"      , nAcresc           , Nil}) // 13
                AAdd(aTitulo, {"AUTDECRESC"     , nDecresc          , Nil}) // 14
                AAdd(aTitulo, {"AUTBANCO"       , F71->F71_CODBAN   , Nil}) // 16
                AAdd(aTitulo, {"AUTAGENCIA"     , F71->F71_AGENCI   , Nil}) // 17
                AAdd(aTitulo, {"AUTCONTA"       , F71->F71_NUMCON   , Nil}) // 18
                
                lMsErroAuto := .F.
                dDataAnt    := dDataBase
                dDataBase   := dDataBaixa
                
                //Efetiva a baixa do título
                MSExecAuto({|titulo, operacao,,,,,,,,,, pix| FINA070(titulo, operacao,,,,,,,,,, pix)}, aTitulo, 3,,,,,,,,,, lPIX)
                
                If !lMsErroAuto
                    lRet := F982MntPIX(aDadosTit, "2", F71->(Recno()), @cErrorMsg)
                    
                    If lRet .And. nTaxa > 0
                        lRet := F892Taxa(nTaxa, F71->F71_CODBAN, F71->F71_AGENCI, F71->F71_NUMCON, dDataBaixa, dDataCred, @cErrorMsg)
                    EndIf
                EndIf
                
                If (lMsErroAuto .Or. !lRet)
                    If lMsErroAuto
                        cErrorMsg := STR0021 +  F71->(F71_PREFIX + F71_NUM + F71_PARCEL + F71_TIPO) + STR0020 + FinGetHelp()
                    EndIf
                    
                    DisarmTransaction()
                    Break                    
                EndIf
                
                If __lLibTit
                    LibTitPix(F71->F71_IDDOC, nRecnoSE1)
                EndIf
                
                dDataBase := dDataAnt
            EndIf
        EndIf
    End Transaction

    RestArea(aAreaF71)
    RestArea(aAreaSE1)

    FwFreeArray(aAreaF71)
    FwFreeArray(aAreaSE1)
    FwFreeArray(aDadosPar)
    FwFreeArray(aDadosTit)
    FwFreeArray(aImpos)
    FwFreeArray(aPCC)
    FwFreeArray(aOutImp)
    FwFreeArray(aTitulo)

Return Empty(cErrorMsg)

/*/{Protheus.doc} F892Taxa
    Realiza a geração do movimento referente a taxa de operação PIX.

    @type       function
    @author     Rafael Riego
    @since      22/12/2021
    @param      nTaxa, numeric, valor da taxa
    @param      cBanco, character, código do banco
    @param      cAgencia, character, agencia
    @param      cConta, character, número da conta
    @param      dBaixa, date, data da baixa
    @param      dDataCred, date, data do crédito
    @param      cMsgErro, character, msg de erro (passada por referência)
    @return     logical, verdadeiro em caso de sucesso
/*/
Static Function F892Taxa(nTaxa As Numeric, cBanco As Character, cAgencia As Character, cConta As Character, dBaixa As Date, dDataCred As Date, cMsgErro As Character) As Logical
    Local aArea         As Array
    Local cCamposE5     As Character
    Local cChaveFK7     As Character
    Local cChaveTit     As Character
    Local cFunName      As Character
    Local cHistorDB     As Character
    Local cNatureza     As Character
    Local lContabili    As Logical
    Local lPadrao       As Logical
    Local lRet          As Logical
    Local oSubFKATar    As Object
    Local oSubFK5Tar    As Object

    Private aFlagCTB    As Array
	Private cLote       As Character
	Private cArquivo    As Character
    Private lAglutina   As Logical
    Private lCabec      As Logical
    Private lDigita     As Logical
    Private lUsaFlag    As Logical
	Private nHdlPrv     As Numeric
	Private nTotal      As Numeric

    Default nTaxa       := 0
    Default cBanco      := SA6->A6_COD
    Default cAgencia    := SA6->A6_AGENCIA
    Default cConta      := SA6->A6_NUMCON
    Default dBaixa      := dDataBase
    Default dDataCred   := dDataBase
    Default cMsgErro    := ""

    If nTaxa > 0
        aArea       := GetArea()
        aFlagCTB    := {}
        cCamposE5   := ""
        cChaveFK7   := ""
        cChaveTit   := ""
        cFunName    := FunName()
        cHistorDB   := ""
        cLote       := ""
        cNatureza   := ""
        lCabec      := .F.
        lRet        := .T.
        nTotal      := 0

        //Inicia contabilização
        If !__lIniCtb .Or. __cFilCtb != cFilAnt
            __lIniCtb   := .T.
            __lUsaFlag  := lUsaFlag := SuperGetMV( "MV_CTBFLAG", .T., .F.)
            __lPadrao   := lPadrao  := VerPadrao("562") // Movimentacao Bancária a Pagar
            Pergunte("FIN070", .F.)
            __lContabi  := lContabili   := MV_PAR04 == 1
            __lDigita   := lDigita      := .F.
            __lAglutin  := lAglutina    := MV_PAR02 == 1
            __cFilCtb   := cFilAnt
        Else
            lUsaFlag    := __lUsaFlag
            lContabili  := __lContabi
            lPadrao     := __lPadrao
            lDigita     := __lDigita
            lAglutina   := __lAglutin
        EndIf

        // Gera registro na movimentacao bancaria
        cNatureza := F200VerNat()

        //Define os campos que não existem na FK5 e que serão gravados apenas na E5, para que a gravação da E5 continue igual
        //Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
        cCamposE5 := "{"
        cCamposE5 += "{'E5_DTDIGIT'     , SToD('" + DToS(dDataBase) + "')}"
        cCamposE5 += ",{'E5_MOTBX'      , 'NOR'}"
        cCamposE5 += ",{'E5_PREFIXO'    , '" + SE1->E1_PREFIXO  + "'}"
        cCamposE5 += ",{'E5_NUMERO'     , '" + SE1->E1_NUM      + "'}"
        cCamposE5 += ",{'E5_PARCELA'    , '" + SE1->E1_PARCELA  + "'}"
        cCamposE5 += ",{'E5_TIPO'       , '" + SE1->E1_TIPO     + "'}"
        cCamposE5 += ",{'E5_CLIFOR'     , '" + SE1->E1_CLIENTE  + "'}"
        cCamposE5 += ",{'E5_LOJA'       , '" + SE1->E1_LOJA     + "'}"
        cCamposE5 += "}"

        //Dados da tabela auxiliar com o código do título a receber
        cChaveTit	:= SE1->E1_FILIAL + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
            SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
        cChaveFK7	:= FinGrvFK7("SE1", cChaveTit)

        cHistorDB := STR0050

        //Model de Movimento Bancario
        oModelTaxa:SetOperation(MODEL_OPERATION_INSERT)
        oModelTaxa:Activate()
        oModelTaxa:SetValue("MASTER", "E5_GRV",      .T.)        //Informa se vai gravar SE5 ou não
        oModelTaxa:SetValue("MASTER", "NOVOPROC",    .T.)        //Informa que a inclusão será feita com um novo número de processo
        oModelTaxa:SetValue("MASTER", "E5_CAMPOS",   cCamposE5)  //Informa os campos da SE5 que serão gravados indepentes de FK5

        oSubFKATar := oModelTaxa:GetModel("FKADETAIL")
        oSubFKATar:SetValue("FKA_IDORIG", FwUUIdV4())
        oSubFKATar:SetValue("FKA_TABORI", "FK5")

        //Informacoes do movimento
        oSubFK5Tar := oModelTaxa:GetModel("FK5DETAIL")
        oSubFK5Tar:SetValue("FK5_IDDOC",    cChaveFK7)
        oSubFK5Tar:SetValue("FK5_ORIGEM",   cFunName)
        oSubFK5Tar:SetValue("FK5_DATA",     dBaixa)
        oSubFK5Tar:SetValue("FK5_VALOR",    nTaxa)
        oSubFK5Tar:SetValue("FK5_VLMOE2",   nTaxa)
        oSubFK5Tar:SetValue("FK5_RECPAG",   "P")
        oSubFK5Tar:SetValue("FK5_BANCO",    cBanco)
        oSubFK5Tar:SetValue("FK5_AGENCI",   cAgencia)
        oSubFK5Tar:SetValue("FK5_CONTA",    cConta)
        oSubFK5Tar:SetValue("FK5_DTDISP",   dDataCred)
        oSubFK5Tar:SetValue("FK5_NATURE",   IIf(!(Empty(cNatureza)), cNatureza, SE1->E1_NATUREZ))
        oSubFK5Tar:SetValue("FK5_TPDOC",    "DB")
        oSubFK5Tar:SetValue("FK5_FILORI",   SE1->E1_FILORIG)
        oSubFK5Tar:SetValue("FK5_HISTOR",   cHistorDB)
        oSubFK5Tar:SetValue("FK5_MOEDA",    StrZero(SE1->E1_MOEDA, 2))

        If SpbInUse()
            oSubFK5Tar:SetValue("FK5_MODSPB",   "1")
        EndIf

        If oModelTaxa:VldData()
            oModelTaxa:CommitData()
            SE5->(DbGoTo(oModelTaxa:GetValue("MASTER", "E5_RECNO")))
        Else
            lRet := .F.
            cMsgErro := cValToChar(oModelTaxa:GetErrorMessage()[4]) + " - "
            cMsgErro += cValToChar(oModelTaxa:GetErrorMessage()[5]) + " - "
            cMsgErro += cValToChar(oModelTaxa:GetErrorMessage()[6])
        EndIf

        oModelTaxa:DeActivate()

        If lRet
            //Atualiza Saldos Bancarios
            AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DATA, SE5->E5_VALOR, "-")
            
            //Atualiza Saldos por Natureza FIV/FIW
            AtuSldNat(SE5->E5_NATUREZ, SE5->E5_DATA, "01", "3", "P", nTaxa, nTaxa, "+",, cFunName, "SE5", SE5->(Recno()))
            
            If !lCabec .And. lPadrao .And. lContabili
                nHdlPrv := HeadProva(cLote, "FINI892", SubStr(cUsuario, 7, 6), @cArquivo)
                lCabec := .T.
            EndIf
            
            DbSelectArea("SE5")
            
            If lCabec .And. lPadrao .And. lContabili .And. nHdlPrv != 0
                If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
                    AAdd(aFlagCTB, {"E5_LA", "S", "SE5", SE5->(RecNo()), 0, 0, 0})
                EndIf
                
                nTotal += DetProva(nHdlPrv, "562", "FINI892", cLote,,,,,,,, @aFlagCTB,,)

                //Efetiva Lançamento Contabil
                cA100Incl(cArquivo, nHdlPrv, 3, cLote, lDigita, lAglutina, /*cOnLine*/, /*dDtLanc*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, /*aDiario*/)
                
                If LanceiCtb .And. !lUsaFlag
                    RecLock("SE5")
                    SE5->E5_LA := "S"
                    SE5->(MsUnLock())
                    
                    DbSelectArea("FK5")
                    FK5->(DbSetOrder(1))//FK5_FILIAL+FK5_IDMOV
                    
                    If SE5->E5_TABORI == "FK5" .And. FK5->(MsSeek(FwXFilial("FK5") + SE5->E5_IDORIG))
                        RecLock("FK5")
                        FK5->FK5_LA := "S"
                        FK5->(MsUnlock())
                    EndIf
                EndIf
            EndIf
        EndIf
        RestArea(aArea)
    EndIf
    
    FwFreeArray(aArea)
    FwFreeArray(aFlagCTB)
Return Empty(cMsgErro)

/*/{Protheus.doc} DtHoraExec
    Realiza o tratamento de Data/Hora de ínicio e fim da execução da API.

    @type       function
    @author     Rafael Riego
    @since      20/12/2021
    @param      cDtHoraFim, character, data/hora final da execução para atualização do parâmetro MV_PIXDTHR (passada por referência)
    @param      cIniUTC, charcater, data/hora inicial da execução padrão UTC (passada por referência)
    @param      cFimUTC, charcater, data/hora final da execução padrão UTC (passada por referência)
    @return     Nil
/*/
Static Function DtHoraExec(cDtHorafim As Character, cIniUTC As Character, cFimUTC As Character)
    Local aFimUTC       As Array
    Local aIniUTC       As Array
    Local cDtHrParam    As Character
    Local cHoraLocal    As Character
    Local dDataLocal    As Date

    Default cDtHorafim  := ""
    Default cIniUTC     := ""
    Default cFimUTC     := ""

    cHoraLocal := Time()
    dDataLocal := Date()
    cDtHrParam := SuperGetMV("MV_PIXDTHR", .F., "")
    
    //Caso nenhuma execução tenha sido realizada ainda
    If Empty(cDtHrParam)
        cIniUTC := SubStr(FwTimeStamp(3, dDataLocal - 10), 1, 10) + "T00:00:00.000000"
    Else
        aIniUTC := LocalToUTC(StrTran(SubStr(cDtHrParam, 1, 10), "-", ""), SubStr(cDtHrParam, 12, 8))
        cIniUTC := FwTimeStamp(3, SToD(aIniUTC[1]), aIniUTC[2]) + ".000000"
    EndIf
    
    cDtHoraFim  := FwTimeStamp(3, dDataLocal) + ".000000"
    aFimUTC     := LocalToUTC(DToS(dDataLocal), cHoraLocal)
    cFimUTC     := FwTimeStamp(3, SToD(aFimUTC[1]), aFimUTC[2]) + ".000000"
    
    FwFreeArray(aIniUTC)
    FwFreeArray(aFimUTC)
Return Nil

/*/{Protheus.doc} GrvUltExec
    Realiza a gravação da última execução, incrementando 1ms.

    @type       function
    @author     Rafael Riego
    @since      20/12/2021
    @param      cDtHrFim, character, data/hora início da execução (passada por referência)
    @return     Nil
/*/
Static Function GrvUltExec(cDtHrFim As Character)
    cDtHrFim := Left(cDtHrFim, Len(cDtHrFim) - 1) + "1"
    PutMV("MV_PIXDTHR", cDtHrFim)
Return Nil

/*/{Protheus.doc} DtDescFin
    Retorna a data limite para desconto financeiro.

    @author     Rafael Riego
    @since      11/05/2022
    @return     date, data válida para desconto financeiro
/*/
Static Function DtDescFin() As Date
    Local dDtLimite     As Date
    
    If __nPosData == Nil
        __nPosData := FieldPos(&(SuperGetMv("MV_DTDESCF")))
    EndIf
    
    If __lDiaDesc == Nil
        __lDiaDesc := SuperGetMv("MV_DIADESC", .F., .F.)
    EndIf
    
    //Se existir a data limite para pagto. com desconto, após o vencimento do titulo, utiliza esta data
    If !(Empty(SE1->E1_LIDESCF))
        dDtLimite := SE1->E1_LIDESCF //Data fixa
    ElseIf __nPosData == 0
        dDtLimite := SE1->E1_VENCREA - SE1->E1_DIADESC
    Else
        dDtLimite := FieldGet(__nPosData) - SE1->E1_DIADESC
    EndIf
    
    If __lDiaDesc
        dDtLimite := DataValida(dDtLimite, .T.)
    EndIf
Return dDtLimite

/*/{Protheus.doc} CalcDesFin
    calcula o valor do desconto financeiro a ser aplicado no PIX.

    @author     Rafael Riego
    @since      11/05/2022
    @param      dDataPagto, date, data do pagamento
    Return      numeric, valor do desconto concedido
/*/
Static Function CalcDesFin(dDataPagto As Date) As Numeric
    Local nDesconto As Numeric
    Local nDias     As Numeric
    
    nDesconto   := 0
    nDias       := 0

    If F71->F71_DESFIN > 0
        If F71->F71_TPDESC == "1" // Desconto fixo ate a data limite
            If (!Empty(F71->F71_DTLIMI) .And. dDataPagto <= F71->F71_DTLIMI)
                nDesconto := F71->F71_VLRPIX * (F71->F71_DESFIN / 30 / 100)
            EndIf
        ElseIf F71->F71_TPDESC == "2"	// Desconto por dia de antecipacao
            If (nDias := F71->F71_DTLIMI - dDataPagto) > 0
                nDesconto := F71->F71_VLRPIX * (((F71->F71_DESFIN / 30) * nDias) / 100)
            EndIf
        EndIf    
    EndIf
    
    If (nDesconto > F71->F71_VLRPIX)
        nDesconto := F71->F71_VLRPIX
    EndIf
Return Round(nDesconto, 2)

/*/{Protheus.doc} CalcJuros
    calcula o valor do juros a ser aplicado no PIX.

    @author     Rafael Riego
    @since      11/05/2022
    @param      dDataPagto, date, data do pagamento
    Return      numeric, valor do desconto concedido
/*/
Static Function CalcJuros(dDataPagto As Date) As Numeric
    Local nJurosCalc As Numeric
    Local nDifDias   As Numeric
    
    nJurosCalc  := 0
    nDifDias    := 0
    
    If (nDifDias := (dDataPagto - F71->F71_VENCTO)) > 0
        If F71->F71_TXPERM > 0
            nJurosCalc := F71->F71_TXPERM * nDifDias                                //Valor Fixo * Dias de Atraso
        ElseIf F71->F71_PERJUR > 0
            nJurosCalc := F71->F71_VLRPIX * ((nDifDias * F71->F71_PERJUR) / 100)    //Saldo Enviado * (Dias de Atraso * Percentual Por Dia)
        EndIf
    EndIf

Return Round(nJurosCalc, 2)

/*/{Protheus.doc} CalcMulta
    calcula o valor da multa a ser aplicado no PIX.

    @author     Rafael Riego
    @since      21/06/2022
    @param      dDataPagto, date, data do pagamento
    Return      numeric, valor da multa aplicada
/*/
Static Function CalcMulta(dDataPagto As Date) As Numeric
    Local nMulta As Numeric
    
    nMulta := 0

    If dDataPagto > F71->F71_VENCTO
        nMulta := F71->F71_MULTA
    EndIF

Return nMulta
