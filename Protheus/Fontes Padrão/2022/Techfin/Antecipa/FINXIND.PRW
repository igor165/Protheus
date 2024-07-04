#include "protheus.ch"
#include "totvs.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FWCOMMAND.ch"
#INCLUDE "FINXIND.CH"

#DEFINE PJ 1
#DEFINE PF 2
#DEFINE CGC_CPF 1
#DEFINE VALOR_CART_EXP 2
#DEFINE PERC_PONTUAL 3
#DEFINE FAT_MEDIO 4
#DEFINE MAIOR_RECEB 5

Static __oTmpCp As Object
Static __dDataDe As Date
Static __dDataAt As Date
Static __cBDName As Character
Static __lChkTerm As Logical
Static __lSucess As Logical

/*/{Protheus.doc} INDCREDITO
    Extrator dos indicadores financeiros
    @type  Main Function
    @author Vitor Duca
    @since 29/07/2021
    @version 1.0
/*/
Main Function INDCREDITO()

    MsApp():New( "SIGAFIN" )
    oApp:cInternet  := Nil
    __cInterNet := NIL
    oApp:bMainInit  := { || ( oApp:lFlat := .F. , WizardInd() , WizardFim() ) }
    oApp:CreateEnv()
    OpenSM0()

    PtSetTheme( "TEMAP10" )
    SetFunName( "FIN_IND" )
    oApp:lMessageBar := .T.

    Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

    oApp:Activate()


Return Nil

/*/{Protheus.doc} WizardInd
    Wizard de configuração do extrator
    @type  Static Function
    @author Vitor Duca
    @since 29/07/2021
    @version 1.0
/*/
Static Function WizardInd()

    Local oWizard   As Object
    Local cGrpEmp   As Character
    Local cMsg      As Character
    Local cRelease  As Character

    Private oSayEmp As Object
    Private oMeterEmp As Object
    Private oSayIndCP As Object
    Private oMeterCP As Object

    IniStatic() //Inicializa variaveis estaticas
    IF FwLibVersion() >= "20220207"
        cRelease := GetRpoRelease()

        oWizard := FWCarolWizard():New()

        If MethIsMemberOf( oWizard, "SetTrialMode")
            oWizard:SetWelcomeMessage( STR0001 ) //"Bem vindo ao extrator de indicadores financeiros"
            oWizard:AddRequirement( STR0002 /*"Release do RPO "*/, cRelease , { || cRelease >= "12.1.025" }, STR0003 /*"Versão de RPO deve ser no mínimo 12.1.25"*/ )
            oWizard:AddRequirement( STR0004/*"Versão da LIB"*/, FwLibVersion(), { || FwLibVersion() >= "20220207" }, STR0005 /*"Versão da LIB deve ser maior ou igual a 20210517 "*/ )
            oWizard:AddStep( STR0006/*"Termo de autorização"*/, { | oPanel | cria_pn1( oPanel ) }, { || ValidPg1() }, { || .F. }, { || .T. } )
            oWizard:AddStep( STR0007 /*"Parâmetros"*/, { | oPanel | cria_pn2( oPanel ) }, { || ValidPg2() }, { || .F. }, { || .T. } )
            oWizard:AddProcess( { | cGrpEmp, cMsg | FExecInd( cGrpEmp, @cMsg) } )

            oWizard:SetTrialMode(.T.)

            oWizard:Activate()

            FreeUsedCode()
        Else
            MsgAlert(STR0008, STR0009) //"Versão da TechFin esta desatualizada, por favor atualize e tente novamente" # "Ambiente desatualizado"
            Return
        Endif
    Else
        MsgAlert(STR0010, STR0009) //"A LIB do ambiente esta desatualizada, por favor atualize para uma versão superior a 20220207" #  "Ambiente desatualizado"
        Return
    Endif
Return

/*/{Protheus.doc} cria_pn1
    Criação do painel contendo o termo de autorização
    @type  Static Function
    @author Vitor Duca
    @since 29/07/2021
    @version 1.0
    @param oPanel, Object, Objeto grafico do Wizard do tipo Painel
    @return NIL
/*/
Static Function cria_pn1(oPanel As Object)
	Local oGet1 AS Object
	Local oFont3 AS Object
    Local oFont2 AS Object
    Local oCheck1 AS Object
    Local cTexto As Character
    Local cIdioma As Character
    Local cErroHttp As Character
    Local cUrlMsg As Character
    Local cTxtLocal As Character
    Local cTxtUrl As Character
    Local cLinkIdioma As Character

    DEFAULT oPanel := NIL

    cIdioma := FwRetIdiom()
    cLinkIdioma := Iif(cIdioma == "en", "en-US", Iif(cIdioma == "es", "es", "pt-BR"))
    cUrlMsg := "http://manifest.engpro.totvs.com.br/disclaimer-fin-" + cLinkIdioma

    cTxtLocal := Space(25)
    cTxtLocal += STR0035 + CRLF + CRLF
    cTxtLocal += "1.   " + STR0036 + "," + " " + STR0037 + CRLF + CRLF
    cTxtLocal += "2.   " + STR0038 + CRLF + CRLF
    cTxtLocal += "3.   " + STR0039 + CRLF + CRLF
    cTxtLocal += "4.   " + STR0040 + " " + STR0041 + " " + STR0042 + CRLF + CRLF
    cTxtLocal += "5.   " + STR0043

    cTxtUrl := DecodeUTF8(HttpGet(cUrlMsg))

    cTexto :=  Iif(HttpGetStatus(@cErroHttp) <> 200, cTxtLocal, cTxtUrl)

    oFont3 := TFont():New('Times New Roman',,-14,.T.)
	oFont := TFont():New( ,, -25, .F., .T.,,,,, )
    oFont2 := TFont():New("Arial",,-15,,.F.,,,,,,.F.,.F.)
    oCheck1 := TCheckBox():New(oPanel:nClientHeight/2.2,(oPanel:nClientWidth/4) - 172,STR0011,{|u|if(PCount()>0,__lChkTerm:= u,__lChkTerm)},oPanel,130,210,,{||.T.},,,,,,.T.,,,) //"Eu concordo com os termos e condições acima"
    @ 015,035 GET oGet1 VAR cTexto OF oPanel MEMO PIXEL FONT oFont3 SIZE 350,165 WHEN .F.

Return

/*/{Protheus.doc} cria_pn2
    Criação do painel contendo os parametros que serão considerados
    na extração das informações
    @type  Static Function
    @author Vitor Duca
    @since 25/10/2021
    @version 1.0
    @param oPanel, Object, Objeto grafico do Wizard do tipo Painel
    @return NIL
/*/
Static Function cria_pn2(oPanel As Object)
    Local oFont As Object
    Local oDataDe   As Object
    Local oGetDtDe  As Object
    Local oDataAte  As Object
    Local oGetDtAte As Object

    oFont := TFont():New("Arial",,-15,,.F.,,,,,,.F.,.F.)

    oDataDe := TSay():New(10,15, {|| STR0012 }, oPanel,,oFont ,,,,.T.,CLR_BLACK) //"Data de:"
    oGetDtDe:= TGet():New(8,50,{|u| If(PCount()>0,__dDataDe:=u,__dDataDe) },oPanel,60,10,"@D",,CLR_BLACK,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.)
    oGetDtDe:bHelp   := {|| ShowHelpCpo("EMISSADE",{STR0044 + STR0013 + STR0045}, 1, {}, 1)} //"O valor desse campo deve ser >= 365 dias antes do " # " e não deve ultrapassar 3 anos"

    oDataAte :=  TSay():New(30,15, {|| STR0013 }, oPanel,,oFont ,,,,.T.,CLR_BLACK) //"Data até:"
    oGetDtAte:= TGet():New(28,50,{|u| __dDataAt := Date()-1 },oPanel,60,10,"@D",{|u| Iif(!Empty(__dDataDe),__dDataAt > __dDataDe,.T.)},CLR_BLACK,,,,,.T.,,,{|| .F.},,,,.F.,.F.,,,,,,.T.)
    oGetDtAte:bHelp   := {|| ShowHelpCpo("EMISSATE",{STR0014}, 1, {}, 1)} //"O conteudo deste campo tem que ser menor ou igual a ontem"

Return

/*/{Protheus.doc} ValidPg1
    Validação do painel 1, consiste em validar se
    - Se foi marcado o checkbox do termo de autorização
    - Não permitir concorrencia entre os usuarios
    @type  Static Function
    @author Vitor duca
    @since 02/08/2021
    @version 1.0
/*/
Static Function ValidPg1() As Logical
    Local lRet As Logical

    lRet := .T.

    If !__lChkTerm
        lRet := .F.
    EndIf

    If lRet
        If !MayIUseCode("FINXIND_01")
            MsgStop(STR0015, STR0016) //"Outro usuario esta acessando a rotina, aguarde a finalização para conseguir prosseguir" # "AVISO"
            lRet := .F.
        Endif
    EndIf

Return lRet

/*/{Protheus.doc} ValidPg2
    Validação do painel 2, consiste em validar se
    - Se o conteudo das datas são diferentes de vazio
    - Se o intervalo de datas é = ou > que 365 dias
    - Se Data ate esta com conteudo menor ou igual a D-1
    @type  Static Function
    @author Vitor duca
    @since 29/07/2021
    @version 1.0
    @return lRet, Logical, Validação do passo 3
/*/
Static Function ValidPg2() As Logical
    Local lRet As Logical

    lRet := .T.


    If Empty(__dDataDe)
        lRet := .F.
        MsgAlert(STR0017,STR0018) //"As datas são invalidas, verifique o conteudo do campo" # "ATENÇÃO"
    Endif    

    If lRet .and. __dDataAt - __dDataDe < 365
        lRet := .F.
        MsgAlert(STR0019,STR0018) //"O intervalo entre as datas deve ser de no minimo 365 dias" # "ATENÇÃO"
    Endif

    If lRet
        /* Ajuste para ano bissexto que tem 366 dias, por exemplo
           de 09/09/2019 ate 09/09/2022 são 3 anos, porem como 2020 foi um ano bissexto
           totaliza um total de 1096 dias, não 1095 como seria 3 anos de 365 dias */
        If Day(__dDataAt)+Month(__dDataAt) == Day(__dDataDe)+Month(__dDataDe) 
            lRet := Year(__dDataAt) - Year(__dDataDe) <= 3
        Else
            lRet := __dDataAt - __dDataDe <= 1095
        Endif    

        If !lRet
            MsgAlert(STR0046, STR0018) // "O intervalo entre as datas não pode ser maior que 3 anos"
        Endif
    Endif

Return lRet

/*/{Protheus.doc} FExecInd
    Executa o envio dos indicadores
    @type  Static Function
    @author Vitor Duca
    @since 29/07/2021
    @version 1.0
    @param cGrpEmp, Character, Codigo do grupo de empresa (M0_CODIGO)
    @param cMsg, Character, Mensagem caso ocorra algum erro durante o processamento
    @return NIL
/*/
Static Function FExecInd(cGrpEmp As Character, cMsg As Character) As Logical
    Local oSmartLink As Object
    Local lRet As Logical
    Local cJson As Character
    Local oMsgJson As Object
    Local oConfig := FWTFConfig()

    DEFAULT cGrpEmp := ""
    DEFAULT cMsg    := ""

    lRet := .T.
    oMsgJson := JsonObject():new()

    FGrvIndSM0(Nil, Nil, @oMsgJson)
    FGrvIndCP(Nil, Nil, Nil, @oMsgJson)
    FGrvIndCR(Nil, Nil, Nil, @oMsgJson)

    oMsgJson['tenantid'] := oConfig[ "platform-tenantId" ]

    If ValType(oMsgJson) == "J"
        cJson := oMsgJson:ToJson()
        If !Empty(cJson)
            oSmartLink := FwTotvsLinkClient():New()
            __lSucess := oSmartLink:SendAudience("ExtracaoIndicadoresFinanceiros","LinkProxy",cJson)
            If !__lSucess
                lRet := .F.
                cMsg := STR0021 //"A mensagem não foi enviada, por favor verifique"
            Endif
        Else
            lRet := .F.
            cMsg := STR0022 //"Mensagem de envio incorreta, verifique"
        Endif
    Endif

Return lRet

/*/{Protheus.doc} FGrvIndSM0
    Grava indicadores referentes ao grupo de empresa e filiais
    @type  Function
    @author Vitor Duca
    @since 20/08/2021
    @param dDateDe, Date, Data de inicio que sera utilizada na extração dos dados
    @param dDataAte, Date, Data fim que sera utilizada na extração dos dados
    @version 1.0
/*/
Function FGrvIndSM0(dDataDe As Date, dDataAte As Date, oMsgJson)
    Local nY As Numeric
    Local aFilial As Array
    Local aCgc As Array
    Local cdDataDe As Character
    Local cdDataAte As Character

    DEFAULT dDataDe := __dDataDe
    DEFAULT dDataAte := __dDataAt
    DEFAULT oMsgJson := NIL

    nY := 0
    aFilial := {}
    aCgc := {}
    cdDataDe := dTos(dDataDe)
    cdDataAte := dTos(dDataAte)
    aFilial := FWAllFilial(,,,.F.)

    For nY := 1 to Len(aFilial)
        Aadd(aCgc, FWSM0Util():GetSM0Data(cEmpAnt, aFilial[nY], {"M0_CGC"})[1][2])
    Next nY

    oMsgJson['Nome'] := FWGrpName(cEmpAnt)
    oMsgJson['CNPJ'] := aCgc
    oMsgJson['DataDe'] := SubStr(cdDataDe, 1, 4) + '-' + SubStr(cdDataDe, 5, 2) + '-' + SubStr(cdDataDe, 7, 2)
    oMsgJson['DataAte'] := SubStr(cdDataAte, 1, 4) + '-' + SubStr(cdDataAte, 5, 2) + '-' + SubStr(cdDataAte, 7, 2)

Return

/*/{Protheus.doc} FGrvIndCP
    Grava indicadores do Contas a pagar
    @type  Function
    @author Vitor Duca
    @since 30/07/2021
    @param lInteg, Logical, Determina se a função esta sendo chamada atraves de integração
    @param dDateDe, Date, Data de inicio que sera utilizada na extração dos dados
    @param dDataAte, Date, Data fim que sera utilizada na extração dos dados
    @param oMsgJson, Json, Mensagem em Json que sera montada para envio dos dados atraves do Smart Link
    @version 1.0
/*/
Function FGrvIndCP(lInteg As Logical, dDataDe As Date, dDataAte As Date, oMsgJson)
    Local nResult As Numeric
    Local cAliasTmp As Character
    Local cQuery As Character
    Local cTabela As Character
    Local cOpData As Character
    Local cNulo As Character
    Local cDataDe As Character
    Local cDataAte As Character
    Local cDataBase As Character
    Local lRet As Logical
    Local oJsonCP As Object
    Local oJsonAux As Object

    DEFAULT lInteg := .F.
    DEFAULT dDataDe := CTOD("//")
    DEFAULT dDataAte := CTOD("//")
    DEFAULT oMsgJson := JsonObject():new()

    If lInteg
        __dDataDe := dDataDe
        __dDataAt := dDataAte
    ENDIF

    nResult := 0
    cOpData := ""
    cNulo  := VerFuncDb("ISNULL")
    cDataDe := DTos(__dDataDe)
    cDataAte := DTos(__dDataAt)
    cDataBase := Dtos(dDataBase)
    cAliasTmp := ""
    lRet := .T.
    oJsonCP := JsonObject():New()

    lRet := FDbCreate("SE2", lInteg)

    If lRet

        cTabela := __oTmpCp:GetRealName()

        /*
        Percentual de pagamentos pontuais
        Total de tí­tulos pagos em dia (considerar pagamento com até 5 dias de atraso)
        versus Total de títulos pagos pelo Parceiro
        */

        cQuery := "SELECT DISTINCT (SELECT COUNT(*) "
        cQuery +=                "FROM " + cTabela + " "
        cQuery +=                "WHERE  BAIXA <= VENC_SUP "
        cQuery +=                    "AND BAIXA <> '        ' "
        cQuery +=                    "AND SALDO = 0 "
        cQuery +=                    "AND D_E_L_E_T_ = ' ') PAGO_DIA, "
        cQuery +=        "(SELECT COUNT(*)  "
        cQuery +=                "FROM " + cTabela + " "
        cQuery +=                "WHERE BAIXA <> '        ' "
        cQuery +=                        "AND SALDO = 0 "
        cQuery +=                        "AND D_E_L_E_T_ = ' ') PAGO_TOTAL FROM " + cTabela

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            nResult := 0
            If (cAliasTmp)->PAGO_TOTAL <> 0
                nResult := Round((cAliasTmp)->PAGO_DIA / (cAliasTmp)->PAGO_TOTAL * 100,2)
            ENDIF
        ENDIF

        (cAliasTmp)->(DbCloseArea())

        oJsonCP["PercentualPagamentosPontuais"] := Round(nResult,2)

        /*
        Quantidade media de pagamentos em atraso em dias
        Média de dias de atraso dos títulos pagos pelo Parceiro
        */

        cOpData := VerFuncDb("DATEDIFF",{"VENCREA","BAIXA"})

        cQuery := "SELECT DISTINCT (SELECT COUNT(*) "
        cQuery +=                "FROM " + cTabela + " "
        cQuery +=                "WHERE BAIXA <> '        ' "
        cQuery +=                    "AND SALDO = 0 "
        cQuery +=                    "AND D_E_L_E_T_ = ' ') PAGO_ATR, "
        cQuery +=        "(SELECT "+cNulo+"(SUM("+cOpData+"),0)  "
        cQuery +=  "FROM " + cTabela + " "
        cQuery +=  "WHERE  BAIXA > VENCREA "
        cQuery +=          "AND BAIXA <> '        ' "
        cQuery +=          "AND SALDO = 0 "
        cQuery +=                        "AND D_E_L_E_T_ = ' ') DIAS_ATR FROM " + cTabela

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            nResult := Abs((cAliasTmp)->DIAS_ATR / (cAliasTmp)->PAGO_ATR)
        ENDIF

        (cAliasTmp)->(DbCloseArea())

        oJsonCP["MediaPagamentosAtraso"] := Round(nResult,2)

        /*
        Quantidade total de titulos pagos
        */

        cQuery := "SELECT  COUNT(*) PAGOS_TOTAL "
        cQuery += "FROM " + cTabela + " "
        cQuery += "WHERE BAIXA <> '        ' "
        cQuery +=         "AND SALDO = 0 "
        cQuery +=         "AND D_E_L_E_T_ = ' ' "

        nResult := MpSysExecScalar(cQuery,"PAGOS_TOTAL")

        oJsonCP["TotalTitulosPagos"] := int(nResult)

        /*
        Maior prazo de atraso pagamentos
        Maior atraso dos títulos pagos pelo Parceiro (quantidade em dias)
        */

        cOpData := VerFuncDb("DATEDIFF",{"BAIXA","VENCREA"})

        cQuery := "SELECT MAX("+cOpData+") MAX_ATRASO "
        cQuery += "FROM " + cTabela + " "
        cQuery += "WHERE  BAIXA > VENCREA "
        cQuery +=     "AND BAIXA <> '        ' "
        cQuery +=     "AND SALDO = 0 "
        cQuery +=     "AND D_E_L_E_T_ = ' ' "

        nResult := Abs(MpSysExecScalar(cQuery,"MAX_ATRASO"))

        oJsonCP["MaiorPrazoAtraso"] := int(nResult)

        /*
        Quantidade de pagamentos com mais de 15 dias de atraso
        */

        cQuery := "SELECT COUNT(*) PAGO_ATR_15 "
        cQuery += "FROM " + cTabela + " "

        If __cBDName == "POSTGRES"
            cQuery += "WHERE  BAIXA > TO_CHAR(CAST(VENCREA AS DATE) + interval'15 days','YYYYMMDD') "
        ElseIf __cBDName == "ORACLE"
            cQuery += "WHERE  BAIXA > TO_CHAR(CAST(VENCREA AS DATE) + 15, 'YYYYMMDD')"
        Else
            cQuery += "WHERE  BAIXA > CONVERT(VARCHAR,DATEADD(DAY,15,VENCREA),112) "
        ENDIF

        cQuery +=     "AND BAIXA <> '        ' "
        cQuery +=     "AND SALDO = 0 "
        cQuery +=     "AND D_E_L_E_T_ = ' ' "

        nResult := MpSysExecScalar(cQuery,"PAGO_ATR_15")

        oJsonCP["PagamentosAtrasoQuinzeDias"] := int(nResult)

        /*
        Maior Valor Contas a Pagar
        Calcular o saldo em aberto diário do Parceiro, e trazer o maior valor deste saldo diário nos Ãºltimos 12 meses
        Calcular a maior exposição com base nas movimentações
        */

        nResult := FCalExpCP("FIN_TMP",cTabela)

        oJsonCP["MaiorValorContasPagar"] := Round(nResult,2)

        //------------------------------------------
        //Soma do Contas a Pagar em aberto
        //------------------------------------------

        cQuery := "SELECT "+cNulo+"(SUM(VLCRUZ),0) A_PAGAR "
        cQuery += "FROM " + cTabela + " "
        cQuery += "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery +=     "AND SALDO <> 0 "
        cQuery +=     "AND BAIXA = '        ' "
        cQuery +=     "AND D_E_L_E_T_ = ' ' "

        nResult := MpSysExecScalar(cQuery,"A_PAGAR")

        oJsonCP["TotalContasPagar"] := Round(nResult,2)

        //------------------------------------------
        //Soma do Contas a Pagar Vencido
        //------------------------------------------

        cQuery := "SELECT "+cNulo+"(SUM(VLCRUZ),0) VENCIDOS "
        cQuery += "FROM " + cTabela + " "
        cQuery += "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery +=     "AND SALDO <> 0 "
        cQuery +=     "AND '"+cDataBase+"' > VENC_SUP "
        cQuery +=     "AND D_E_L_E_T_ = ' ' "

        nResult := MpSysExecScalar(cQuery,"VENCIDOS")

        oJsonCP["TotalContasPagarVencido"] := Round(nResult,2)

        /*
        Percentual de pagamentos por faixa
        Percentual de pagamentos efetuados por faixa: até 5 dias
        (inclusive pagamento em dia e antes do vencimento) / de 6 a 30 / 31 a 60 / > 60 dias
        */

        cOpData := VerFuncDb("DATEDIFF",{"BAIXA","VENCREA"})

        cQuery := "SELECT DISTINCT (SELECT COUNT(*) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  BAIXA <> '        ' "
        cQuery +=                             "AND SALDO = 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')PAGO_TOTAL, "
        cQuery +=                "(SELECT COUNT(*) "
        cQuery +=                    "FROM " + cTabela + " "
        cQuery +=                    "WHERE  BAIXA <> '        ' "
        cQuery +=                         "AND BAIXA <= VENC_SUP "
        cQuery +=                         "AND SALDO = 0 "
        cQuery +=                         "AND D_E_L_E_T_ = ' ')PAGO_DIA, "
        cQuery +=                "(SELECT COUNT(*) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  BAIXA <> '        ' "
        cQuery +=                             "AND BAIXA > VENCREA "
        cQuery +=                             "AND 6 <= "+cOpData+" "
        cQuery +=                             "AND 30 >= "+cOpData+" "
        cQuery +=                             "AND SALDO = 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')PAGO_ATR30, "
        cQuery +=                "(SELECT COUNT(*) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  BAIXA <> '        ' "
        cQuery +=                         "AND BAIXA > VENCREA "
        cQuery +=                         "AND 31 <= "+cOpData+" "
        cQuery +=                         "AND 60 >= "+cOpData+" "
        cQuery +=                         "AND SALDO = 0 "
        cQuery +=                         "AND D_E_L_E_T_ = ' ')PAGO_ATR60, "
        cQuery +=                "(SELECT COUNT(*) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  BAIXA <> '        ' "
        cQuery +=                         "AND BAIXA > VENCREA "
        cQuery +=                         "AND 60 < "+cOpData+" "
        cQuery +=                         "AND SALDO = 0 "
        cQuery +=                         "AND D_E_L_E_T_ = ' ')PAGO_ATRMX "
        cQuery += "FROM " + cTabela

        oJsonAux := JsonObject():New()

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            //Percentual de pagamentos em dia
            nResult := Round((cAliasTmp)->PAGO_DIA / (cAliasTmp)->PAGO_TOTAL * 100,2)
            oJsonAux["5"] := Round(nResult,2)

            //Percentual de pagamentos ate 30 dias de atraso
            nResult := Round( (cAliasTmp)->PAGO_ATR30 / (cAliasTmp)->PAGO_TOTAL * 100,2)
            oJsonAux["6-30"] := Round(nResult,2)

            //Percentual de pagamentos ate 60 dias de atraso
            nResult := Round((cAliasTmp)->PAGO_ATR60 / (cAliasTmp)->PAGO_TOTAL * 100,2)
            oJsonAux["31-60"] := Round(nResult,2)

            //Percentual de pagamentos com mais de 60 dias de atraso
            nResult := Round((cAliasTmp)->PAGO_ATRMX / (cAliasTmp)->PAGO_TOTAL * 100,2)
            oJsonAux["60"] := Round(nResult,2)
        ENDIF

        oJsonCP["PagamentosPorFaixa"] := oJsonAux

        oJsonAux := NIL

        (cAliasTmp)->(DbCloseArea())

        //------------------------------------------
        //Prazo médio de pagamento
        //------------------------------------------

        cOpData := VerFuncDb("DATEDIFF",{"VENCREA","EMISSAO"})

        cQuery := "SELECT COUNT(*) TOTAL_TITULOS, "+cNulo+"(SUM("+cOpData+"),0) IDADE_PAG "
        cQuery += "FROM " + cTabela + " "
        cQuery += "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery +=         "AND D_E_L_E_T_ = ' ' "

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            nResult := Abs((cAliasTmp)->IDADE_PAG  / (cAliasTmp)->TOTAL_TITULOS)
        ENDIF

        (cAliasTmp)->(DbCloseArea())

        oJsonCP["PrazoMedioPagamento"] := Int(nResult)

        /*
        Aging do Contas a Pagar
        Soma do valor dos títulos a vencer por faixa de vencimento: de 1 a 15 dias / 16 a 30 dias /
        31 a 60 dias / 61 a 90 dias / 91 a 120 dias / 121 a 150 dias / 151 a 180 dias / > 180 dias
        */

        cOpData := VerFuncDb("DATEDIFF",{"VENCREA","'"+cDataBase+"'"})

        cQuery := "SELECT DISTINCT (SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 15 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') A_VENCER_15, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 16 <= "+cOpData+" "
        cQuery +=                             "AND 30 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENCER_30, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 31 <= "+cOpData+" "
        cQuery +=                             "AND 60 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENCER_60, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 61 <= "+cOpData+" "
        cQuery +=                             "AND 90 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENCER_90, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 91 <= "+cOpData+" "
        cQuery +=                             "AND 120 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENCER_120, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 121 <= "+cOpData+" "
        cQuery +=                             "AND 150 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENCER_150, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 151 <= "+cOpData+" "
        cQuery +=                             "AND 180 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENCER_180, "
        cQuery +=                         "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                             "FROM " + cTabela + " "
        cQuery +=                             "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                                 "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                                 "AND 181 < "+cOpData+" "
        cQuery +=                                 "AND SALDO <> 0 "
        cQuery +=                                 "AND D_E_L_E_T_ = ' ') A_VENCER_MAIS_180 "
        cQuery += "FROM " + cTabela

        oJsonAux := JsonObject():New()

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            //Valores a vencer em 15 dias
            nResult := (cAliasTmp)->A_VENCER_15
            oJsonAux["1-15"] := Round(nResult,2)

            //Valores a vencer em 30 dias
            nResult := (cAliasTmp)->A_VENCER_30
            oJsonAux["16-30"] := Round(nResult,2)

            //Valores a vencer em 60 dias
            nResult := (cAliasTmp)->A_VENCER_60
            oJsonAux["31-60"] := Round(nResult,2)

            //Valores a vencer em 90 dias
            nResult := (cAliasTmp)->A_VENCER_90
            oJsonAux["61-90"] := Round(nResult,2)

            //Valores a vencer em 120 dias
            nResult := (cAliasTmp)->A_VENCER_120
            oJsonAux["91-120"] := Round(nResult,2)

            //Valores a vencer em 150 dias
            nResult := (cAliasTmp)->A_VENCER_150
            oJsonAux["121-150"] := Round(nResult,2)

            //Valores a vencer em 180 dias
            nResult := (cAliasTmp)->A_VENCER_180
            oJsonAux["151-180"] := Round(nResult,2)

            //Valores a vencer em mais de 180 dias
            nResult := (cAliasTmp)->A_VENCER_MAIS_180
            oJsonAux["180"] := Round(nResult,2)
        ENDIF

        oJsonCP["Aging"] := oJsonAux

        oJsonAux := NIL

        (cAliasTmp)->(DbCloseArea())

        /*
        Contas a Pagar por Faixa de Atraso
        Soma dos títulos vencidos e não pagos por faixa de vencimento: de 1 a 15 dias / 16 a 30 dias / 31 a 60 dias /
        61 a 90 dias / 91 a 120 dias / 121 a 150 dias / 151 a 180 dias / > 180 dias
        */

        cOpData := VerFuncDb("DATEDIFF",{"'"+cDataBase+"'","VENCREA"})

        cQuery := "SELECT DISTINCT (SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 15 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_15, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 16 <= "+cOpData+" "
        cQuery +=                             "AND 30 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_30, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 31 <= "+cOpData+" "
        cQuery +=                             "AND 60 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_60, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 61 <= "+cOpData+" "
        cQuery +=                             "AND 90 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_90, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 91 <= "+cOpData+" "
        cQuery +=                             "AND 120 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_120, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 121 <= "+cOpData+" "
        cQuery +=                             "AND 150 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_150, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 151 <= "+cOpData+" "
        cQuery +=                             "AND 180 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_180, "
        cQuery +=                         "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                             "FROM " + cTabela + " "
        cQuery +=                             "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                                 "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                                 "AND 181 < "+cOpData+" "
        cQuery +=                                 "AND SALDO <> 0 "
        cQuery +=                                 "AND D_E_L_E_T_ = ' ') MAIS_180 "
        cQuery += "FROM " + cTabela

        oJsonAux := JsonObject():New()

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            //Valores vencidos em 15 dias
            nResult := (cAliasTmp)->VENC_15
            oJsonAux["1-15"] := Round(nResult,2)

            //Valores vencidos em 30 dias
            nResult := (cAliasTmp)->VENC_30
            oJsonAux["16-30"] := Round(nResult,2)

            //Valores vencidos em 60 dias
            nResult := (cAliasTmp)->VENC_60
            oJsonAux["31-60"] := Round(nResult,2)

            //Valores vencidos em 90 dias
            nResult := (cAliasTmp)->VENC_90
            oJsonAux["61-90"] := Round(nResult,2)

            //Valores vencidos em 120 dias
            nResult := (cAliasTmp)->VENC_120
            oJsonAux["91-120"] := Round(nResult,2)

            //Valores vencidos em 150 dias
            nResult := (cAliasTmp)->VENC_150
            oJsonAux["121-150"] := Round(nResult,2)

            //Valores vencidos em 180 dias
            nResult := (cAliasTmp)->VENC_180
            oJsonAux["151-180"] := Round(nResult,2)

            //Valores vencidos em mais de 180 dias
            nResult := (cAliasTmp)->MAIS_180
            oJsonAux["180"] := Round(nResult,2)
        ENDIF

        oJsonCP["FaixaDeAtraso"] := oJsonAux

        oJsonAux := NIL

        (cAliasTmp)->(DbCloseArea())
    ENDIF

    If __oTmpCp != Nil
        __oTmpCp:Delete()
        __oTmpCp := Nil
    EndIf

    oMsgJson["ContasPagar"] := oJsonCP

Return

/*/{Protheus.doc} FGrvIndCR
    Grava indicadores do Contas a receber
    @type  Function
    @author Leonardo Kichitaro
    @since 02/08/2021
    @param lInteg, Logical, Determina se a função esta sendo chamada atraves de integração
    @param dDateDe, Date, Data de inicio que sera utilizada na extração dos dados
    @param dDataAte, Date, Data fim que sera utilizada na extração dos dados
    @param oMsgJson, Json, Mensagem em Json que sera montada para envio dos dados atraves do Smart Link
    @version 1.0
/*/
Function FGrvIndCR(lInteg As Logical, dDataDe As Date, dDataAte As Date, oMsgJson)
    Local nResult As Numeric
	Local nTotalFat As Numeric
	Local nQuantFat As Numeric
	Local nQuantCli As Numeric
	Local nTotalTit As Numeric
	Local nTotalAVis As Numeric
	Local nTotalAPra As Numeric
	Local nTotalAnt As Numeric
	Local nMeses As Numeric
    Local cAliasTmp As Character
    Local cQuery As Character
    Local cTabela As Character
    Local cDataDe As Character
    Local cDataAte As Character
    Local cDataBase As Character
    Local aResult As Array
    Local nX As Numeric
    Local cTamF2Dup As Character
    Local cNulo As Character
    Local lRet As Logical
    Local oJsonCR As Object
    Local oJsonFAT As Object
    Local oJsonAux As Object

    DEFAULT lInteg := .F.
    DEFAULT dDataDe := CTOD("//")
    DEFAULT dDataAte := CTOD("//")
    DEFAULT oMsgJson := JsonObject():new()

    If lInteg
        __dDataDe := dDataDe
        __dDataAt := dDataAte
    Endif

    nResult := 0
    aResult := {}
    cOpData := ""
    cNulo := VerFuncDb("ISNULL")
    cDataDe := DTos(__dDataDe)
    cDataAte := DTos(__dDataAt)
    cDataBase := Dtos(dDataBase)
    cAliasTmp := ""
	nMeses := DateDiffMonth(__dDataAt,__dDataDe)//considerar o mes inicial
    cTamF2Dup := Space(TAMSX3("F2_DUPL")[1])
    lRet := .T.
    oJsonCR := JsonObject():new()
    oJsonFAT := JsonObject():new()

    lRet := FDbCreate("SE1",lInteg)


    If lRet

        cTabela := __oTmpCp:GetRealName()

        /*
        Percentual de recebimentos pontuais
        Total de títulos recebidos em dia (considerar pagamento com até 5 dias de atraso) x
        Total de tí­tulos recebidos pelos clientes do Parceiro
        */

        cQuery := "SELECT DISTINCT (SELECT COUNT(*) "
        cQuery +=                "FROM " + cTabela + " "
        cQuery +=                "WHERE  BAIXA <= VENC_SUP "
        cQuery +=                    "AND BAIXA <> '        ' "
        cQuery +=                    "AND SALDO = 0 "
        cQuery +=                    "AND D_E_L_E_T_ = ' ') RECEB_DIA, "
        cQuery +=        "(SELECT COUNT(*)  "
        cQuery +=                "FROM " + cTabela + " "
        cQuery +=                "WHERE BAIXA <> '        ' "
        cQuery +=                        "AND SALDO = 0 "
        cQuery +=                        "AND D_E_L_E_T_ = ' ') RECEB_TOTAL FROM " + cTabela

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            If (cAliasTmp)->RECEB_TOTAL <> 0
                nResult := Round((cAliasTmp)->RECEB_DIA / (cAliasTmp)->RECEB_TOTAL * 100,2)
            EndIf
        ENDIF

        (cAliasTmp)->(DbCloseArea())

        oJsonCR["RecebimentosPontuais"] := Round(nResult,2)

        /*
        Quantidade media de recebimentos em atraso
        Média de dias de atraso dos títulos pagos pelos clientes do Parceiro
        */

        cOpData := VerFuncDb("DATEDIFF",{"VENCREA","BAIXA"})

        cQuery := "SELECT DISTINCT (SELECT COUNT(*) "
        cQuery +=                "FROM " + cTabela + " "
        cQuery +=                "WHERE BAIXA <> '        ' "
        cQuery +=                    "AND SALDO = 0 "
        cQuery +=                    "AND D_E_L_E_T_ = ' ') PAGO_ATR, "
        cQuery +=        "(SELECT "+cNulo+"(SUM("+cOpData+"),0)  "
        cQuery +=  "FROM " + cTabela + " "
        cQuery +=  "WHERE  BAIXA > VENCREA "
        cQuery +=          "AND BAIXA <> '        ' "
        cQuery +=          "AND SALDO = 0 "
        cQuery +=                        "AND D_E_L_E_T_ = ' ') DIAS_ATR FROM " + cTabela

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            nResult := Abs((cAliasTmp)->DIAS_ATR / (cAliasTmp)->PAGO_ATR)
        ENDIF

        (cAliasTmp)->(DbCloseArea())

        oJsonCR["MediaRecebimentoAtraso"] := Round(nResult,2)

        //------------------------------------------
        //Quantidade total de titulos recebidos
        //------------------------------------------

        cQuery := "SELECT  COUNT(*) PAGOS_TOTAL "
        cQuery += "FROM " + cTabela + " "
        cQuery += "WHERE BAIXA <> '        ' "
        cQuery +=         "AND SALDO = 0 "
        cQuery +=         "AND D_E_L_E_T_ = ' ' "

        nResult := MpSysExecScalar(cQuery,"PAGOS_TOTAL")

        oJsonCR["TotalTitulosRecebidos"] := Int(nResult)

        /*
        Total faturamento
        Soma dos faturamentos emitidos pelo Parceiro para seus clientes, base anual (Data Até / Data Ate)
        */

        cQuery := "SELECT " + cNulo + "(SUM(F2_VALFAT),0) TOTAL_FAT "
        cQuery += "FROM " + RetSqlName("SF2") + " "
        cQuery += "WHERE F2_DUPL <> '"+cTamF2Dup+"' "
        cQuery += "  AND F2_EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery += "  AND D_E_L_E_T_ = ' ' "

        nResult := MpSysExecScalar(cQuery,"TOTAL_FAT")

        oJsonFAT["TotalAno"] := Round(nResult,2)

        nTotalFat := nResult

        /*
        Faturamento medio mensal
        Valor médio mensal dos faturamentos emitidos pelo Parceiro para seus clientes (Data Até / Data Ate)
        */

        nResult := (nTotalFat / nMeses)

        oJsonFAT["MediaMensal"] := Round(nResult,2)

        //------------------------------------------
        //Ticket medio
        //------------------------------------------

        cQuery := "SELECT COUNT(*) QUANT_FAT "
        cQuery += "FROM " + RetSqlName("SF2") + " "
        cQuery += "WHERE F2_DUPL <> '"+cTamF2Dup+"' "
        cQuery += "  AND F2_EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery += "  AND D_E_L_E_T_ = ' ' "

        nQuantFat := MpSysExecScalar(cQuery,"QUANT_FAT")

        nResult := nTotalFat / nQuantFat

        oJsonFAT["TicketMedio"] := Int(nResult)

        //-------------------------------------------------------
        //Prazo medio de recebimento
        //-------------------------------------------------------

        cOpData := VerFuncDb("DATEDIFF",{"VENCREA","EMISSAO"})

        cQuery := "SELECT COUNT(*) TOTAL_TITULOS, SUM("+cOpData+") IDADE_PAG "
        cQuery += "FROM " + cTabela + " "
        cQuery += "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery +=         "AND D_E_L_E_T_ = ' ' "

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            nResult := (cAliasTmp)->IDADE_PAG  / (cAliasTmp)->TOTAL_TITULOS
        ENDIF

        (cAliasTmp)->(DbCloseArea())

        oJsonCR["PrazoMedio"] := Int(nResult)

        /*
        Percentual de faturamento a prazo
        Total dos faturamentos a prazo emitidos pelo Parceiro x total de faturamentos emitidos
        */

        cQuery := "SELECT DISTINCT "
        cQuery += "   ( SELECT COUNT(*) "
        cQuery += "       FROM " + cTabela + " "
        cQuery += "      WHERE EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery += "        AND EMISSAO = VENCTO "
        cQuery += "        AND D_E_L_E_T_ = ' ') TOTAL_AVISTA, "
        cQuery += "   ( SELECT COUNT(*) "
        cQuery += "       FROM " + cTabela + " "
        cQuery += "      WHERE EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery += "        AND EMISSAO <> VENCTO "
        cQuery += "        AND D_E_L_E_T_ = ' ') TOTAL_PRAZO "
        cQuery += " FROM " + cTabela + " "

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            nTotalAVis := (cAliasTmp)->TOTAL_AVISTA
            nTotalAPra := (cAliasTmp)->TOTAL_PRAZO
            nTotalTit := nTotalAVis + nTotalAPra

            nResult := ((nTotalAPra / nTotalTit) * 100)
        ENDIF

        (cAliasTmp)->(DbCloseArea())

        oJsonFAT["PercentualPrazo"] := Round(nResult,2)

        //------------------------------------------
        //Quantidade total de clientes ativos nos ultimos 12 meses
        //------------------------------------------

        cQuery := "SELECT DISTINCT COUNT(*) TOTAL_CLI "
        cQuery += "FROM (SELECT DISTINCT F2_CLIENTE, F2_LOJA "
        cQuery += "		   FROM "+ RetSqlName("SF2") + " "
        cQuery += "		  WHERE F2_DUPL <> '"+cTamF2Dup+"' "
        cQuery += "         AND F2_EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery += "         AND D_E_L_E_T_ = ' ') SA1 "

        nResult := MpSysExecScalar(cQuery,"TOTAL_CLI")

        oJsonFAT["ClientesAtivos"] := Int(nResult)

        nQuantCli := nResult

        /*
        Percentual de titulos antecipados
        Total de títulos antecipados na carteira do Parceiro x total de títulos emitidos pelo Parceiro
        */

        cQuery := "SELECT COUNT(*) TOTAL_ANTECIPA "
        cQuery += "  FROM " + cTabela + " SE1 "
        cQuery += " INNER JOIN "+ RetSqlName("FRV") + " FRV "
        cQuery += "         ON FRV_CODIGO = SE1.SITUACA "
        cQuery += "        AND FRV_DESCON = '1' "
        cQuery += "        AND FRV.D_E_L_E_T_ = ' '	"
        cQuery += " WHERE EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

        nTotalAnt := MpSysExecScalar(cQuery,"TOTAL_ANTECIPA")

        nResult := ((nTotalAnt / nTotalTit ) * 100)

        oJsonCR["TitulosAntecipados"] := Round(nResult,2)

        /*
        Valor maior acumulo Cliente 1 a 5
        Calcular o saldo em aberto diário de cada um dos clientes do Parceiro, e trazer o maior valor deste saldo
        diário nos Ãºltimos 12 meses, e calcular os 5 maiores clientes com base neste saldo, calcular a maior exposição
        com base nas movimentações do contas a receber quebrando por raiz de CNPJ ou CPF.
        */

        aResult := FCalExpCR("FIN_TMP",cTabela)

        //CPFs
        oJsonAux := JsonObject():new()
        For nX := 1 To Len(aResult[PF])
            oJsonAux[Alltrim(aResult[PF][nX][CGC_CPF])] := Round(aResult[PF][nX][VALOR_CART_EXP],2)
        Next
        oJsonCR["ValorAcumuladoPF"] := oJsonAux
        oJsonAux := NIL

        //CNPJs
        oJsonAux := JsonObject():new()
        For nX := 1 To Len(aResult[PJ])
            oJsonAux[aResult[PJ][nX][CGC_CPF]] := Round(aResult[PJ][nX][VALOR_CART_EXP],2)
        Next
        oJsonCR["ValorAcumuladoPJ"] := oJsonAux
        oJsonAux := NIL

        /*
        Percentual de recebimentos pontuais Cliente 1 a 5
        Total de títulos pagos em dia (considerar pagamento com até X dias de atraso) x Total de títulos pagos pelos
        clientes do Parceiro, para os 5 maiores clientes
        */

        //CPFs
        oJsonAux := JsonObject():new()
        For nX := 1 To Len(aResult[PF])
            oJsonAux[Alltrim(aResult[PF][nX][CGC_CPF])] := Round(aResult[PF][nX][PERC_PONTUAL],2)
        Next
        oJsonCR["RecebimentoPontualPF"] := oJsonAux
        oJsonAux := NIL

        //CNPJs
        oJsonAux := JsonObject():new()
        For nX := 1 To Len(aResult[PJ])
            oJsonAux[aResult[PJ][nX][CGC_CPF]] := Round(aResult[PJ][nX][PERC_PONTUAL],2)
        Next
        oJsonCR["RecebimentoPontualPJ"] := oJsonAux
        oJsonAux := NIL

        /*
        Faturamento médio mensal 1 a 5
        Valor médio mensal dos faturamentos emitidos pelo Parceiro para os 5 maiores clientes
        */

        //CPFs
        oJsonAux := JsonObject():new()
        For nX := 1 To Len(aResult[PF])
            oJsonAux[Alltrim(aResult[PF][nX][CGC_CPF])] := Round(aResult[PF][nX][FAT_MEDIO],2)
        Next
        oJsonFAT["FaturamentoMedioPF"] := oJsonAux
        oJsonAux := NIL

        //CNPJs
        oJsonAux := JsonObject():new()
        For nX := 1 To Len(aResult[PJ])
            oJsonAux[aResult[PJ][nX][CGC_CPF]] := Round(aResult[PJ][nX][FAT_MEDIO],2)
        Next
        oJsonFAT["FaturamentoMedioPJ"] := oJsonAux
        oJsonAux := NIL

        /*
        Maior Pagamento 1 a 5
        Maior valor pago por um tÃ­tulo para os 5 maiores clientes
        */

        //CPFs
        oJsonAux := JsonObject():new()
        For nX := 1 To Len(aResult[PF])
            oJsonAux[Alltrim(aResult[PF][nX][CGC_CPF])] := Round(aResult[PF][nX][MAIOR_RECEB],2)
        Next
        oJsonCR["MaiorPagamentoPF"] := oJsonAux
        oJsonAux := NIL

        //CNPJs
        oJsonAux := JsonObject():new()
        For nX := 1 To Len(aResult[PJ])
            oJsonAux[aResult[PJ][nX][CGC_CPF]] := Round(aResult[PJ][nX][MAIOR_RECEB],2)
        Next
        oJsonCR["MaiorPagamentoPJ"] := oJsonAux
        oJsonAux := NIL

        /*
        Concentração para atingir 70% da carteira
        Valor do maior acumulo para atingir 70% da carteira do Parceiro
        Faturamento por cliente, elencar por valor e encontrar o valor necessário a ser liberado e crédito para
        atingir 70% destes clientes
        */

        oJsonAux := JsonObject():new()

        nResult := Round(aResult[3],2)
        oJsonAux["70"] := nResult

        /*
        Concentração para atingir 80% da carteira
        Valor do maior acumulo para atingir 80% da carteira do Parceiro
        Faturamento por cliente, elencar por valor e encontrar o valor necessário a ser liberado e crédito para
        atingir 70% destes clientes
        */

        nResult := Round(aResult[4],2)
        oJsonAux["80"] := nResult

        /*
        Concentração para atingir 90% da carteira
        Valor do maior acumulo para atingir 90% da carteira do Parceiro
        Faturamento por cliente, elencar por valor e encontrar o valor necessário a ser liberado e crédito para
        atingir 70% destes clientes
        */

        nResult := Round(aResult[5],2)
        oJsonAux["90"] := nResult

        oJsonCR["Concentracao"] := oJsonAux
        oJsonAux := NIL

        /*
        Percentual de recebimentos por faixa
        Percentual de recebimentos por faixa: até 5 dias (inclusive recebimento em dia e antecipado) / de 6 a 30 /
        31 a 60 / > 60 dias
        */

        cOpData := VerFuncDb("DATEDIFF",{"BAIXA","VENCREA"})

        cQuery := "SELECT DISTINCT (SELECT COUNT(*) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  BAIXA <> '        ' "
        cQuery +=                             "AND SALDO = 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')REC_TOTAL, "
        cQuery +=                "(SELECT COUNT(*) "
        cQuery +=                    "FROM " + cTabela + " "
        cQuery +=                    "WHERE  BAIXA <> '        ' "
        cQuery +=                         "AND BAIXA <= VENC_SUP "
        cQuery +=                         "AND SALDO = 0 "
        cQuery +=                         "AND D_E_L_E_T_ = ' ')REC_DIA, "
        cQuery +=                "(SELECT COUNT(*) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  BAIXA <> '        ' "
        cQuery +=                             "AND BAIXA > VENCREA "
        cQuery +=                             "AND 6 <= "+cOpData+" "
        cQuery +=                             "AND 30 >= "+cOpData+" "
        cQuery +=                             "AND SALDO = 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')REC_ATR30, "
        cQuery +=                "(SELECT COUNT(*) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  BAIXA <> '        ' "
        cQuery +=                         "AND BAIXA > VENCREA "
        cQuery +=                         "AND 31 <= "+cOpData+" "
        cQuery +=                         "AND 60 >= "+cOpData+" "
        cQuery +=                         "AND SALDO = 0 "
        cQuery +=                         "AND D_E_L_E_T_ = ' ')REC_ATR60, "
        cQuery +=                "(SELECT COUNT(*) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  BAIXA <> '        ' "
        cQuery +=                         "AND BAIXA > VENCREA "
        cQuery +=                         "AND 60 < "+cOpData+" "
        cQuery +=                         "AND SALDO = 0 "
        cQuery +=                         "AND D_E_L_E_T_ = ' ')REC_ATRMX "
        cQuery += "FROM " + cTabela

        oJsonAux := JsonObject():new()

        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            //Percentual de recebimentos em dia
            nResult := Round((cAliasTmp)->REC_DIA / (cAliasTmp)->REC_TOTAL * 100,2)
            oJsonAux["5"] := Round(nResult,2)

            //Percentual de recebimentos ate 30 dias de atraso
            nResult := Round( (cAliasTmp)->REC_ATR30 / (cAliasTmp)->REC_TOTAL * 100,2)
            oJsonAux["6-30"] := Round(nResult,2)

            //Percentual de recebimentos ate 60 dias de atraso
            nResult := Round((cAliasTmp)->REC_ATR60 / (cAliasTmp)->REC_TOTAL * 100,2)
            oJsonAux["31-60"] := Round(nResult,2)

            //Percentual de recebimentos com mais de 60 dias de atraso
            nResult := Round((cAliasTmp)->REC_ATRMX / (cAliasTmp)->REC_TOTAL * 100,2)
            oJsonAux["60"] := Round(nResult,2)
        ENDIF
        oJsonCR["RecebimentoFaixa"] := oJsonAux
        oJsonAux := NIL

        (cAliasTmp)->(DbCloseArea())

        /*
        Aging do Contas a Receber
        Soma do valor dos títulos a vencer por faixa de vencimento: de 1 a 15 dias / 16 a 30 dias / 31 a 60 dias /
        61 a 90 dias / 91 a 120 dias / 121 a 150 dias / 151 a 180 dias / > 180 dias
        */

        cOpData := VerFuncDb("DATEDIFF",{"VENCREA","'"+cDataBase+"'"})

        cQuery := "SELECT DISTINCT (SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 15 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') A_VENC_15, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 16 <= "+cOpData+" "
        cQuery +=                             "AND 30 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENC_30, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 31 <= "+cOpData+" "
        cQuery +=                             "AND 60 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENC_60, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 61 <= "+cOpData+" "
        cQuery +=                             "AND 90 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENC_90, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 91 <= "+cOpData+" "
        cQuery +=                             "AND 120 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENC_120, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 121 <= "+cOpData+" "
        cQuery +=                             "AND 150 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENC_150, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                             "AND 151 <= "+cOpData+" "
        cQuery +=                             "AND 180 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ')A_VENC_180, "
        cQuery +=                         "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                             "FROM " + cTabela + " "
        cQuery +=                             "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                                 "AND VENCREA > '"+cDataBase+"' "
        cQuery +=                                 "AND 181 < "+cOpData+" "
        cQuery +=                                 "AND SALDO <> 0 "
        cQuery +=                                 "AND D_E_L_E_T_ = ' ') A_MAIS_180 "
        cQuery += "FROM " + cTabela

        cAliasTmp := MPSysOpenQuery(cQuery)
        oJsonAux := JsonObject():new()

        If (cAliasTmp)->(!Eof())
            //Valores a vencer em 15 dias
            nResult := (cAliasTmp)->A_VENC_15
            oJsonAux["1-15"] := Round(nResult,2)

            //Valores a vencer em 30 dias
            nResult := (cAliasTmp)->A_VENC_30
            oJsonAux["16-30"] := Round(nResult,2)

            //Valores a vencer em 60 dias
            nResult := (cAliasTmp)->A_VENC_60
            oJsonAux["31-60"] := Round(nResult,2)

            //Valores a vencer em 90 dias
            nResult := (cAliasTmp)->A_VENC_90
            oJsonAux["61-90"] := Round(nResult,2)

            //Valores a vencer em 120 dias
            nResult := (cAliasTmp)->A_VENC_120
            oJsonAux["91-120"] := Round(nResult,2)

            //Valores a vencer em 150 dias
            nResult := (cAliasTmp)->A_VENC_150
            oJsonAux["121-150"] := Round(nResult,2)

            //Valores a vencer em 180 dias
            nResult := (cAliasTmp)->A_VENC_180
            oJsonAux["151-180"] := Round(nResult,2)

            //Valores a vencer em mais de 180 dias
            nResult := (cAliasTmp)->A_MAIS_180
            oJsonAux["180"] := Round(nResult,2)
        ENDIF
        oJsonCR["Aging"] := oJsonAux
        oJsonAux := NIL

        (cAliasTmp)->(DbCloseArea())

        /*
        Contas a Receber por Faixa de Atraso
        Soma do valor dos títulos vencidos e não pagos por faixa de vencimento: de 1 a 15 dias / 16 a 30 dias /
        31 a 60 dias / 61 a 90 dias / 91 a 120 dias / 121 a 150 dias / 151 a 180 dias / > 180 dias
        */

        cOpData := VerFuncDb("DATEDIFF",{"'"+cDataBase+"'","VENCREA"})

        cQuery := "SELECT DISTINCT (SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 15 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_15, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 16 <= "+cOpData+" "
        cQuery +=                             "AND 30 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_30, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 31 <= "+cOpData+" "
        cQuery +=                             "AND 60 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_60, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 61 <= "+cOpData+" "
        cQuery +=                             "AND 90 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_90, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 91 <= "+cOpData+" "
        cQuery +=                             "AND 120 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_120, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 121 <= "+cOpData+" "
        cQuery +=                             "AND 150 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_150, "
        cQuery +=                 "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                     "FROM " + cTabela + " "
        cQuery +=                     "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                             "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                             "AND 151 <= "+cOpData+" "
        cQuery +=                             "AND 180 >= "+cOpData+" "
        cQuery +=                             "AND SALDO <> 0 "
        cQuery +=                             "AND D_E_L_E_T_ = ' ') VENC_180, "
        cQuery +=                         "(SELECT "+cNulo+"(SUM(VLCRUZ), 0) "
        cQuery +=                             "FROM " + cTabela + " "
        cQuery +=                             "WHERE  EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"'
        cQuery +=                                 "AND VENCREA < '"+cDataBase+"' "
        cQuery +=                                 "AND 181 < "+cOpData+" "
        cQuery +=                                 "AND SALDO <> 0 "
        cQuery +=                                 "AND D_E_L_E_T_ = ' ') MAIS_180 "
        cQuery += "FROM " + cTabela

        oJsonAux := JsonObject():new()
        cAliasTmp := MPSysOpenQuery(cQuery)
        If (cAliasTmp)->(!Eof())
            //Valores vencidos em 15 dias
            nResult := (cAliasTmp)->VENC_15
            oJsonAux["1-15"] := Round(nResult,2)

            //Valores vencidos em 30 dias
            nResult := (cAliasTmp)->VENC_30
            oJsonAux["16-30"] := Round(nResult,2)

            //Valores vencidos em 60 dias
            nResult := (cAliasTmp)->VENC_60
            oJsonAux["31-60"] := Round(nResult,2)

            //Valores vencidos em 90 dias
            nResult := (cAliasTmp)->VENC_90
            oJsonAux["61-90"] := Round(nResult,2)

            //Valores vencidos em 120 dias
            nResult := (cAliasTmp)->VENC_120
            oJsonAux["91-120"] := Round(nResult,2)

            //Valores vencidos em 150 dias
            nResult := (cAliasTmp)->VENC_150
            oJsonAux["121-150"] := Round(nResult,2)

            //Valores vencidos em 180 dias
            nResult := (cAliasTmp)->VENC_180
            oJsonAux["151-180"] := Round(nResult,2)

            //Valores vencidos em mais de 180 dias
            nResult := (cAliasTmp)->MAIS_180
            oJsonAux["180"] := Round(nResult,2)
        ENDIF

        (cAliasTmp)->(DbCloseArea())

        oJsonCR["FaixaDeAtraso"] := oJsonAux
        oJsonAux := NIL

    Endif

    If __oTmpCp != Nil
        __oTmpCp:Delete()
        __oTmpCp := Nil
    EndIf

    oMsgJson["ContasReceber"] := oJsonCR
    oMsgJson["Faturamento"] := oJsonFAT

Return

/*/{Protheus.doc} FDbCreate
    Cria a tabela temporaria que sera utilizada para gravar as metricas
    @type  Static Function
    @author Vitor Duca
    @since 30/07/2021
    @version 1.0
    @param cAliasSE, Character, Alias da tabela de acordo SE2/SE1
    @param lInteg, Logical, Determina se a execução da rotina esta sendo via integração
    @return NIL
/*/
Static Function FDbCreate(cAliasSE As Character, lInteg As Logical) As Logical
    Local aCampos As Array
    Local nTamData As Numeric
    Local lRet As Logical
    Local nTamVal As Numeric
    Local nDecVal As Numeric

    DEFAULT cAliasSE := "SE2"
    DEFAULT lInteg := .F.

    lRet := .T.
    nTamData := TamSX3("E2_EMISSAO")[1]
    nTamVal  := TamSX3("E2_SALDO")[1]
    nDecVal  := TamSX3("E2_SALDO")[2]

    aCampos := {{"BAIXA"   , "D" , nTamData                  ,  0},;
                {"VENCREA" , "D" , nTamData                  ,  0},;
                {"VENC_SUP", "D" , nTamData                  ,  0},;
                {"VENCTO"  , "D" , nTamData                  ,  0},;
                {"EMISSAO" , "D" , nTamData                  ,  0},;
                {"SALDO"   , "N" , nTamVal                   ,  nDecVal },;
                {"VLCRUZ"  , "N" , nTamVal                   ,  nDecVal },;
                {"MOEDA"   , "N" , TamSX3("E1_MOEDA")[1]     ,  0 },;
                {"SITUACA" , "C" , TamSX3("E1_SITUACA")[1]   ,  0 },;
                {"CLIENTE" , "C" , TamSX3("E1_CLIENTE")[1]   ,  0 },;
                {"LOJA"    , "C" , TamSX3("E1_LOJA")[1]      ,  0 },;
                {"IDDOC"   , "C" , TamSX3("FK7_IDDOC")[1]    ,  0 } }

    // Campo de FILIAL que sera usado para vincular o cliente x temporaria na função
    // FCalExpCR()
    If cAliasSE == "SE1"
        AADD(aCampos, {"FILIAL"   , "C" , TamSX3("E1_FILIAL")[1]                  ,  0})
    Endif

    __oTmpCp := FWTemporaryTable():New()
    __oTmpCp:SetFields(aCampos)
    __oTmpCp:AddIndex("1",{"BAIXA","VENCREA","SALDO"})
    __oTmpCp:AddIndex("2",{"EMISSAO","SALDO"})
    __oTmpCp:AddIndex("3",{"EMISSAO","VENCREA"})
    __oTmpCp:AddIndex("4",{"SITUACA"})
	__oTmpCp:AddIndex("5",{"CLIENTE","LOJA"})
    __oTmpCp:AddIndex("6",{"BAIXA","VENC_SUP","SALDO"})
    __oTmpCp:AddIndex("7",{"EMISSAO","VENC_SUP"})
    __oTmpCp:AddIndex("8",{"IDDOC","MOEDA"})
    __oTmpCp:Create()

    lRet := FDbInsert(cAliasSE, lInteg)

Return lRet

/*/{Protheus.doc} FDbInsert
    Função responsavel por inserir os registros necessarios para extração
    dos indicadores na tabela temporaria
    @type  Static Function
    @author Vitor Duca
    @since 30/07/2021
    @version 1.0
    @param cAliasSE, Character, Alias da tabela de acordo SE2/SE1
    @param lInteg, Logical, Determina se a execução da rotina esta sendo via integração
    @return NIL
/*/
Static Function FDbInsert(cAliasSE As Character, lInteg As Logical) As Logical
    Local cQuery As Character
    Local cInsert As Character
    Local cUpdate As Character
    Local cTipo As Character
    Local cConcat As Character
    Local lRet As Logical
    Local nVenc As Numeric

    DEFAULT cAliasSE := "SE2"
    DEFAULT lInteg := .F.

    cConcat := "+"
    lRet := .T.
    nVenc := 5

    If __cBDName == 'ORACLE'
        cConcat := "||"
    Endif

    IF cAliasSE == "SE2"

        cTipo := MVPROVIS + "|" + MVPAGANT + "|" + MVABATIM + "|" + MV_CPNEG

        cQuery := "SELECT SE2.E2_BAIXA, "
        cQuery +=     "SE2.E2_VENCREA, "
        cQuery +=     "SE2.E2_VENCREA VENC_SUP, "
        cQuery +=     "SE2.E2_VENCTO, "
        cQuery +=     "SE2.E2_EMISSAO, "
        cQuery +=     "SE2.E2_SALDO, "
        cQuery +=     "SE2.E2_VLCRUZ, "
        cQuery +=     "SE2.E2_MOEDA, "
        cQuery +=     "FK7.FK7_IDDOC "
        cQuery += "FROM " + RetSqlName("SE2") + " SE2 "
        cQuery +=     "INNER JOIN " + RetSqlName("FK7") + " FK7 "
        cQuery +=             "ON FK7.FK7_FILIAL = SE2.E2_FILIAL "
        cQuery +=                 "AND FK7.FK7_ALIAS = 'SE2' "

        If __cBDName == 'POSTGRES'
            cQuery +=                 "AND RTRIM(FK7.FK7_CHAVE) = RTRIM(CONCAT(SE2.E2_FILIAL, '|', SE2.E2_PREFIXO, '|', "
            cQuery +=                                     "SE2.E2_NUM, '|', SE2.E2_PARCELA, '|', "
            cQuery +=                                     "SE2.E2_TIPO, '|', SE2.E2_FORNECE, '|', "
            cQuery +=                                     "SE2.E2_LOJA)) "
        Else
            cQuery +=                 "AND FK7.FK7_CHAVE = SE2.E2_FILIAL "+cConcat+" '|' "+cConcat+" SE2.E2_PREFIXO "+cConcat+" '|' "
            cQuery +=                                     ""+cConcat+" SE2.E2_NUM "+cConcat+" '|' "+cConcat+" SE2.E2_PARCELA "+cConcat+" '|' "
            cQuery +=                                     ""+cConcat+" SE2.E2_TIPO "+cConcat+" '|' "+cConcat+" SE2.E2_FORNECE "+cConcat+" '|' "
            cQuery +=                                     ""+cConcat+" SE2.E2_LOJA "
        Endif

        cQuery +=                 "AND FK7.D_E_L_E_T_ = ' ' "
        cQuery += "WHERE  SE2.E2_TIPO NOT IN " + FORMATIN(cTipo,"|") + " "
        cQuery +=     "AND SE2.E2_NUMLIQ = '" + replicate(" ", tamSX3("E2_NUMLIQ")[1]) + "' "
        cQuery +=     "AND ( SE2.E2_FATURA = '"+ replicate(" ", tamSX3("E2_FATURA")[1]) +"' "
        cQuery +=             "OR SE2.E2_FATURA = 'NOTFAT' ) "
        cQuery +=     "AND NOT EXISTS (SELECT FI8.FI8_NUMORI "
        cQuery +=                     "FROM "+RetSqlName("FI8")+" FI8 "
        cQuery +=                     "WHERE  FI8.FI8_FILIAL = SE2.E2_FILIAL "
        cQuery +=                             "AND FI8.FI8_PRFORI = SE2.E2_PREFIXO "
        cQuery +=                             "AND FI8.FI8_NUMORI = SE2.E2_NUM "
        cQuery +=                             "AND FI8.FI8_PARORI = SE2.E2_PARCELA "
        cQuery +=                             "AND FI8.FI8_TIPORI = SE2.E2_TIPO "
        cQuery +=                             "AND FI8.FI8_FORORI = SE2.E2_FORNECE "
        cQuery +=                             "AND FI8.FI8_LOJORI = SE2.E2_LOJA "
        cQuery +=                             "AND FI8.D_E_L_E_T_ = ' ' ) "
        cQuery +=     "AND SE2.E2_EMISSAO BETWEEN '"+DTos(__dDataDe)+"' AND '"+Dtos(__dDataAt)+"' "
        cQuery +=     "AND SE2.D_E_L_E_T_ = ' ' "

        cInsert := "INSERT "

        If __cBDName == "ORACLE"
            cInsert += " /*+ APPEND */ "
        Endif

        cInsert += "INTO "  + __oTmpCp:GetRealName() + " (BAIXA, VENCREA, VENC_SUP, VENCTO, EMISSAO, SALDO, VLCRUZ, MOEDA, IDDOC) " + cQuery

	ELSEIF cAliasSE == "SE1"

        cTipo := MVPROVIS + "|" + MVRECANT + "|" + MVABATIM + "|" + MV_CRNEG + "|" + MVIRABT + "|" + MVINABT + "|" +;
                 MVCFABT + "|" + MVCSABT + "|" + MVPIABT + "|" + MVISABT + "|" + MVI2ABT

        cQuery := "SELECT SE1.E1_BAIXA, "
        cQuery +=     "SE1.E1_VENCREA, "
        cQuery +=     "SE1.E1_VENCREA VENC_SUP, "
        cQuery +=     "SE1.E1_VENCTO, "
        cQuery +=     "SE1.E1_EMISSAO, "
        cQuery +=     "SE1.E1_SALDO, "
        cQuery +=     "SE1.E1_VLCRUZ, "
        cQuery +=     "SE1.E1_SITUACA, "
        cQuery +=     "SE1.E1_CLIENTE, "
        cQuery +=     "SE1.E1_LOJA, "
        cQuery +=     "SE1.E1_MOEDA, "
        cQuery +=     "FK7.FK7_IDDOC, "
        cQuery +=     "SE1.E1_FILIAL "
        cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
        cQuery +=     "INNER JOIN " + RetSqlName("FK7") + " FK7 "
        cQuery +=             "ON FK7.FK7_FILIAL = SE1.E1_FILIAL "
        cQuery +=                 "AND FK7.FK7_ALIAS = 'SE1' "

        If __cBDName == 'POSTGRES'
            cQuery +=                 "AND RTRIM(FK7.FK7_CHAVE) = RTRIM(CONCAT(SE1.E1_FILIAL, '|', SE1.E1_PREFIXO, '|', "
            cQuery +=                                     "SE1.E1_NUM, '|', SE1.E1_PARCELA, '|', "
            cQuery +=                                     "SE1.E1_TIPO, '|', SE1.E1_CLIENTE, '|', "
            cQuery +=                                     "SE1.E1_LOJA)) "
        Else
            cQuery +=                 "AND FK7.FK7_CHAVE = SE1.E1_FILIAL "+cConcat+" '|' "+cConcat+" SE1.E1_PREFIXO "+cConcat+" '|' "
            cQuery +=                                     ""+cConcat+" SE1.E1_NUM "+cConcat+" '|' "+cConcat+" SE1.E1_PARCELA "+cConcat+" '|' "
            cQuery +=                                     ""+cConcat+" SE1.E1_TIPO "+cConcat+" '|' "+cConcat+" SE1.E1_CLIENTE "+cConcat+" '|' "
            cQuery +=                                     ""+cConcat+" SE1.E1_LOJA "
        Endif

        cQuery +=                 "AND FK7.D_E_L_E_T_ = ' ' "
        cQuery += "WHERE  SE1.E1_TIPO NOT IN " + FORMATIN(cTipo,"|") + " "
        cQuery +=     "AND SE1.E1_NUMLIQ = '"+ replicate(" ", tamSX3("E1_NUMLIQ")[1]) +"'  "
        cQuery +=     "AND ( SE1.E1_FATURA = '"+ replicate(" ", tamSX3("E1_FATURA")[1]) +"' "
        cQuery +=             "OR SE1.E1_FATURA = 'NOTFAT' ) "
        cQuery +=     "AND NOT EXISTS (SELECT FI7.FI7_NUMORI "
        cQuery +=                     "FROM "+RetSqlName("FI7")+" FI7 "
        cQuery +=                     "WHERE  FI7.FI7_FILIAL = SE1.E1_FILIAL "
        cQuery +=                             "AND FI7.FI7_PRFORI = SE1.E1_PREFIXO "
        cQuery +=                             "AND FI7.FI7_NUMORI = SE1.E1_NUM "
        cQuery +=                             "AND FI7.FI7_PARORI = SE1.E1_PARCELA "
        cQuery +=                             "AND FI7.FI7_TIPORI = SE1.E1_TIPO "
        cQuery +=                             "AND FI7.FI7_CLIORI = SE1.E1_CLIENTE "
        cQuery +=                             "AND FI7.FI7_LOJORI = SE1.E1_LOJA "
        cQuery +=                             "AND FI7.D_E_L_E_T_ = ' ' ) "
        cQuery +=     "AND SE1.E1_EMISSAO BETWEEN '"+DTos(__dDataDe)+"' AND '"+Dtos(__dDataAt)+"' "
        cQuery +=     "AND SE1.D_E_L_E_T_ = ' ' "

        cInsert := "INSERT "

        If __cBDName == "ORACLE"
            cInsert += " /*+ APPEND */ "
        Endif

        cInsert += "INTO " + __oTmpCp:GetRealName() + " (BAIXA, VENCREA, VENC_SUP, VENCTO, EMISSAO, SALDO, VLCRUZ, SITUACA, CLIENTE, LOJA, MOEDA, IDDOC, FILIAL) " + cQuery
    ENDIF

	If TcSQLExec(cInsert) < 0
        UserException(TcSqlError())
    ENDIF

    /*
        Altera o campo VENC_SUP incrementando mais 5 dias, pois a Supplier considera o titulo vencido
        5 dias apos o vencimento
    */

    If __cBDName == "POSTGRES"
        cUpdate := "UPDATE " + __oTmpCp:GetRealName() + " SET VENC_SUP = TO_CHAR(CAST(VENC_SUP AS DATE) + interval'" + cValToChar(nVenc) + " days','YYYYMMDD') "
    ElseIf __cBDName == "ORACLE"
        cUpdate := "UPDATE " + __oTmpCp:GetRealName() + " SET VENC_SUP = TO_CHAR(TO_DATE(VENC_SUP,'YYYYMMDD') + " + cValToChar(nVenc) + ", 'YYYYMMDD')"
    Else
        cUpdate := "UPDATE " + __oTmpCp:GetRealName() + " SET VENC_SUP = CONVERT(VARCHAR,DATEADD(DAY," + cValToChar(nVenc) + ",VENC_SUP),112) "
    ENDIF

    If TcSQLExec(cUpdate) < 0
        UserException(TcSqlError())
    Endif

    (__oTmpCp:GetAlias())->(DbGoTop())

    If (__oTmpCp:GetAlias())->(Eof())
        lRet := .F.
    Endif

Return lRet

/*/{Protheus.doc} VerFuncDb
    Converte a função/sintaxe que existe no SQL server para outros bancos
    @type  Static Function
    @author Vitor Duca
    @since 03/08/2021
    @version 1.0
    @param cFunSQL, Character, Nome da função existente no SQL Server
    @param aParam, Array, Parametros que são passados para a função (Devem estar na ordem)
    @return cRet, Character , String que pode ser utilizada na montagem da query
    @example
    cFunction := VerFuncDb("DATEDIFF",{"BAIXA","VENCREA"})
/*/
Static Function VerFuncDb(cFunSQL As Character, aParam As Array) As Character
    Local cRet As Character

    DEFAULT cFunSQL := ""
    DEFAULT aParam  := {}

    cRet := ""
    __cBDName := AllTrim(tcGetdb())

    cFunSQL := UPPER(AllTrim(cFunSQL))

    /*Caso o aParam seja vazio, apenas ira retornar a função equivalente ao BD
      Caso contrario ira retornar a sintaxe equivalente ao BD*/
    If Empty(aParam)
        Do CASE
            CASE cFunSQL == "ISNULL"
                If __cBDName == "ORACLE"
			        cRet := "NVL"
		        Elseif __cBDName == "POSTGRES"
			        cRet := "COALESCE"
                Else
                    cRet := cFunSQL
		        ENDIF
            CASE cFunSQL == "SUBSTRING"
                If __cBDName $ "ORACLE|POSTGRES"
                    cRet := "SUBSTR"
                else
                    cRet := cFunSQL
                Endif
        End CASE
    Else
        Do CASE
            /*
                Função DATEDIFF é usada no SQL para retornar a diferença entre duas datas
                que são passadas por parametro, pois o SQL não consegue efetuar operação de subtração
                em campos do tipo data, essa função não existe no Oracle e no Postgres, mas estes bancos
                permite operações aritmeticas em campos do tipo data
            */
            CASE cFunSQL == "DATEDIFF"
                If __cBDName $ "ORACLE|POSTGRES"
			        cRet := "CAST("+aParam[1]+" As Date) - CAST("+aParam[2]+" As Date)"
		        Else
			        cRet := cFunSQL+"(DAY,"+aParam[2]+","+aParam[1]+")"
		        ENDIF
        End CASE
    Endif

Return cRet

/*/{Protheus.doc} FCalExpCP
    Calcula o saldo da carteira de exposição do Contas a Pagar
    @type  Static Function
    @author Leornado/Vitor
    @since 12/08/2021
    @version 1.0
    @param cTMP, Character, Tabela temporaria que sera criada
    @param cTable, Character, Tabela que sera usada para relacionamento na inserção dos registros
    @return nRet, Numeric, Valor que sera gravado no indicador
/*/
Static Function FCalExpCP(cTMP As Character, cTable As Character) As Numeric
    Local aCampos As Array
    Local nX As Numeric
    Local oRecLock As Object
    Local nDias As Numeric
    Local dDtGrv As Date
    Local cUpdate As Character
    Local cUpdate1 As Character
    Local cError As Character
    Local cNulo As Character
    Local nRet As Numeric

    DEFAULT cTMP := ""
    DEFAULT cTable := ""

    nX       := 0
    dDtGrv   := Date()
    nDias    := __dDataAt - __dDataDe
    oReclock := NIL
    cError   := ""
    cNulo    := VerFuncDb("ISNULL")
    nRet     := 0
    nTamVal  := TamSX3("E2_SALDO")[1]
    nDecVal  := TamSX3("E2_SALDO")[2]

    aCampos := {{"DT_EMISSAO"  , "D" , TamSX3("E2_EMISSAO")[1]  ,  0},;
                    {"VAL_COMPRA"  , "N" , nTamVal   ,  nDecVal },;
                    {"VAL_PAGO" , "N" , nTamVal      ,  nDecVal },;
                    {"CART_EXP" , "N" , nTamVal      ,  nDecVal }}

    IF TCObject(cTMP)
        TCDelFile(cTMP)
    Endif

    FWDBCreate( cTMP, aCampos, "TOPCONN", .T.)
    //Gravação do campo DT_EMISSAO, que ira conter todo o intervalo entre __dDataDe e __dDataAt
    oReclock := FINDTCRECORD():New(cTMP)

    For nX := 1 To nDias + 1
        dDtGrv :=  Iif(nX == 1 ,__dDataDe, dDtGrv+1)
        oReclock:SetValue("DT_EMISSAO",dDtGrv)
        oReclock:AddBulk()
    Next nX

    oReclock:Commit()

    If !Empty(oReclock:cMessage)
        TCDelFile(cTMP)
        Final( STR0023 ) //"Ocorreu um erro na criação da tabela temporária e o processo será abortado"
    ENDIF

    oReclock:Destroy()

    //Gravação dos campos VAL_COMPRA e VAL_PAGO que serão utilizados para o calculo do campo CART_EXP
    cUpdate := "UPDATE " + cTMP + " SET VAL_COMPRA = (SELECT "+cNulo+"(SUM(VLCRUZ),0) VAL_COMPRA FROM " + cTable + " WHERE EMISSAO = DT_EMISSAO ) "
    cUpdate1 := "UPDATE " + cTMP + " SET VAL_PAGO = (SELECT "+cNulo+"(SUM(VLCRUZ)-SUM(SALDO),0) VAL_PAGO FROM " + cTable + " WHERE BAIXA = DT_EMISSAO ) "

    If TcSQLExec(cUpdate) < 0 .OR. TcSQLExec(cUpdate1) < 0
        TCDelFile(cTMP)
        UserException(TcSqlError())
    Endif

    //Execução da Stored Procedure para preenchimento do campo CART_EXP (Exposição da carteira)
    If !Empty(cError := FExecProc(cTMP,1))
        TCDelFile(cTMP)
        UserException(cError)
    Endif

    nRet := MpSysExecScalar("SELECT MAX(CART_EXP) MAX_VLR FROM " + cTMP,"MAX_VLR")

    TCDelFile(cTMP)

Return nRet

/*/{Protheus.doc} FCalExpCR
    Calcula o saldo da carteira de exposição do Contas a Receber
    @type  Static Function
    @author Leornado/Vitor
    @since 12/08/2021
    @version 1.0
    @param cTMP, Character, Tabela temporaria que sera criada
    @return nRet, Numeric, Valor que sera gravado no indicador
/*/
Static Function FCalExpCR(cTMP As Character, cTable As Character) As Array
    Local aCampos As Array
    Local cQuery As Character
    Local cError As Character
    Local cInsert As Character
    Local nTamCGC  As Numeric
    Local nTamPess As Numeric
    Local nTamData As Numeric
    Local nTamVal As Numeric
    Local nDecVal As Numeric
    Local aRet As Array
    Local a5CNPJs As Array
    Local a5CPFs As Array
    Local cAliasExpo As Character
    Local cCgcAnt As Character
    Local cDataDe As Character
    Local cDataAte As Character
    Local cSubs As Character
    Local cNulo As Character
    Local cJoinFil As Character

    nTamCGC  := TamSX3("A1_CGC")[1]
    nTamPess := TamSX3("A1_PESSOA")[1]
    nTamData := TamSX3("E2_EMISSAO")[1]
    nTamVal  := TamSX3("E2_SALDO")[1]
    nDecVal  := TamSX3("E2_SALDO")[2]
    cDataDe  := Dtos(__dDataDe)
    cDataAte := Dtos(__dDataAt)
    cSubs    := VerFuncDb("SUBSTRING")
    cNulo    := VerFuncDb("ISNULL")
    cJoinFil := ""
    
    If FindFunction( "totvs.protheus.backoffice.ngf.util.BranchRelation" )
        cJoinFil := &('totvs.protheus.backoffice.ngf.util.BranchRelation( {"SE1","FILIAL","SE1"}, {"SA1","A1_FILIAL","SA1"} )')
    Endif

    aCampos := {{"DT_EMISSAO"   , "D" , nTamData  ,  0       },;
                    {"CGC"      , "C" , nTamCGC   ,  0       },;
                    {"PESSOA"   , "C" , nTamPess  ,  0       },;
                    {"VAL_VEND" , "N" , nTamVal   ,  nDecVal },;
                    {"VAL_RECB" , "N" , nTamVal   ,  nDecVal },;
                    {"TIPO"     , "C" , 1         ,  0       },;
                    {"CART_EXP" , "N" , nTamVal   ,  nDecVal }}

    IF TCObject(cTMP)
        TCDelFile(cTMP)
    Endif

    FWDBCreate( cTMP, aCampos, "TOPCONN", .T.)

	cQuery := "SELECT DISTINCT SE1.EMISSAO, SA1.A1_CGC, SA1.A1_PESSOA, "+cNulo+"(SUM(SE1.VLCRUZ),0) VAL_VEND, 0 VAL_RECB, '1' TIPO "
    cQuery += "FROM " + RetSqlName("SA1") + " SA1 "
	cQuery += "INNER JOIN " + cTable + " SE1 ON " + cJoinFil + " " 
    cQuery +=                    "AND SA1.A1_COD = SE1.CLIENTE "
	cQuery += 					 "AND SA1.A1_LOJA = SE1.LOJA "
	cQuery += 					 "AND SE1.EMISSAO BETWEEN '" + cDataDe + "' AND '" + cDataAte + "' "
	cQuery += 					 "AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SA1.A1_MSBLQL <> '1' "
	cQuery += "AND SA1.A1_CGC <> '" + Space(nTamCGC) + "' "
	cQuery += "AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY SA1.A1_CGC,SE1.EMISSAO, SA1.A1_PESSOA "

	cQuery += "UNION "

	cQuery += "SELECT DISTINCT SE1.BAIXA, SA1.A1_CGC, SA1.A1_PESSOA, 0 VAL_VEND, "+cNulo+"(SUM(SE1.VLCRUZ)-SUM(SE1.SALDO),0) VAL_RECB, '2' TIPO "
    cQuery += "FROM " + RetSqlName("SA1") + " SA1 "
	cQuery += "INNER JOIN " + cTable + " SE1 ON " + cJoinFil + " " 
    cQuery +=                    "AND SA1.A1_COD = SE1.CLIENTE "
	cQuery += 					 "AND SA1.A1_LOJA = SE1.LOJA "
	cQuery += 					 "AND SE1.BAIXA BETWEEN '" + cDataDe + "' AND '" + cDataAte + "' "
	cQuery += 					 "AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SA1.A1_MSBLQL <> '1' "
	cQuery += "AND SA1.A1_CGC <> '" + Space(nTamCGC) + "' "
	cQuery += "AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY SA1.A1_CGC,SE1.BAIXA, SA1.A1_PESSOA "
	cQuery += "ORDER BY A1_CGC "

    cInsert := "INSERT "

    If __cBDName == "ORACLE"
        cInsert += " /*+ APPEND */ "
    Endif

    cInsert += "INTO " + cTMP + " (DT_EMISSAO, CGC, PESSOA, VAL_VEND, VAL_RECB, TIPO) " + cQuery

    If TcSqlExec(cInsert) < 0
        TCDelFile(cTMP)
        UserException(TcSqlError())
    Endif

    //Execução da Stored Procedure para preenchimento do campo CART_EXP (Exposição da carteira)
    If !Empty(cError := FExecProc(cTMP,2))
        TCDelFile(cTMP)
        UserException(TcSqlError())
    Endif

    //Consulta os 5 maiores valores por CNPJ
    cQuery := "SELECT DISTINCT " + cSubs + "(CGC, 1, 8) CGC, "+cNulo+"(SUM(VAL_MAX),0) VAL_MAX "
    cQuery += "FROM   (SELECT DISTINCT " + cSubs + "(CGC, 1, 8) CGC, MAX(CART_EXP) VAL_MAX "
    cQuery +=         "FROM   " + cTMP + " "
    cQuery +=         "WHERE  PESSOA = 'J' "
    cQuery +=         "GROUP  BY CGC, "
    cQuery +=                 "PESSOA) " + cTMP + " "
    cQuery += "GROUP  BY CGC "
    cQuery += "ORDER  BY VAL_MAX DESC "

	cAliasExpo := MPSysOpenQuery(cQuery)

	a5CNPJs := {}

	While (cAliasExpo)->(!Eof())
		If Len(a5CNPJs) == 0 .Or. Ascan(a5CNPJs, {|x|x[1] == (cAliasExpo)->CGC}) == 0
			If Len(a5CNPJs) < 5
				aAdd(a5CNPJs,{(cAliasExpo)->CGC,(cAliasExpo)->VAL_MAX,0,0,0})
			EndIf
		EndIf

		cCgcAnt := (cAliasExpo)->CGC

		(cAliasExpo)->(dbSkip())
	EndDo

    (cAliasExpo)->(DbCloseArea())

	//Consulta os 5 maiores valores por CPF
	cQuery := "SELECT DISTINCT CGC, MAX(CART_EXP) VAL_MAX"
	cQuery += "  FROM " + cTMP + " "
	cQuery += " WHERE PESSOA = 'F' "
    cQuery += "GROUP  BY CGC "
	cQuery += "ORDER BY VAL_MAX DESC "

	cAliasExpo := MPSysOpenQuery(cQuery)

	a5CPFs := {}

	While (cAliasExpo)->(!Eof())
		If Len(a5CPFs) == 0 .Or. Ascan(a5CPFs, {|x|x[1] == (cAliasExpo)->CGC}) == 0
			If Len(a5CPFs) < 5
				aAdd(a5CPFs,{(cAliasExpo)->CGC,(cAliasExpo)->VAL_MAX,0,0,0})
			EndIf
		EndIf

		cCgcAnt := (cAliasExpo)->CGC

		(cAliasExpo)->(dbSkip())
	EndDo

    (cAliasExpo)->(DbCloseArea())

	//Indicadores por cliente - PJ
	FQueryCli(cTable, "J", @a5CNPJs, cDataDe, cDataAte)

    //Indicadores por cliente - PF
    FQueryCli(cTable, "F", @a5CPFs, cDataDe, cDataAte)

    //Calcula concentração da carteira
     aCampos := {{"CGC"      , "C" , nTamCGC   ,  0       },;
                {"CART_EXP"  , "N" , nTamVal   ,  nDecVal }}

    oTmpCalExp := FWTemporaryTable():New()
    oTmpCalExp:SetFields(aCampos)
    oTmpCalExp:AddIndex("1",{"CART_EXP"})
    oTmpCalExp:Create()
    cInsert := "INSERT "

    If __cBDName == "ORACLE"
        cInsert += " /*+ APPEND */ "
    Endif

    cInsert += "INTO "  + oTmpCalExp:GetRealName() + " (CGC, CART_EXP) " + "SELECT CGC, MAX(CART_EXP) SALDO FROM " + cTMP + " GROUP BY CGC"

    If TcSqlExec(cInsert) < 0
        TCDelFile(cTMP)
        UserException(TcSqlError())
    Endif

    cQuery := "SELECT COUNT(*) TOTAL_CLI FROM " + oTmpCalExp:GetRealName()
    nTotalCli := MpSysExecScalar(cQuery, "TOTAL_CLI")

    //70%
    n70percent := Int(nTotalCli * 0.70)
    nConc70 := 0

    //80%
    n80percent := Int(nTotalCli * 0.80)
    nConc80 := 0

    //90%
    n90percent := Int(nTotalCli * 0.90)
    nConc90 := 0


    If __cBDName == 'ORACLE'
		cQuery := "SELECT CART_EXP FROM " + oTmpCalExp:GetRealName() + " WHERE ROWNUM < " + CValToChar(n70percent)
	ElseIf __cBDName == 'POSTGRES'
		cQuery := "SELECT CART_EXP FROM " + oTmpCalExp:GetRealName() + " LIMIT " + CValToChar(n70percent)
	Else
		cQuery := "SELECT TOP " + CValToChar(n70percent) + " CART_EXP FROM " + oTmpCalExp:GetRealName()
    Endif    

    cAliasConcentra := MPSysOpenQuery(cQuery)

    If (cAliasConcentra)->(!EOF())
        (cAliasConcentra)->(DBSkip(n70percent-1))
        nConc70 := (cAliasConcentra)->CART_EXP
    Endif
    (cAliasConcentra)->(DBCLOSEAREA())

    If __cBDName == 'ORACLE'
		cQuery := "SELECT CART_EXP FROM " + oTmpCalExp:GetRealName() + " WHERE ROWNUM < " + CValToChar(n80percent)
	ElseIf __cBDName == 'POSTGRES'
		cQuery := "SELECT CART_EXP FROM " + oTmpCalExp:GetRealName() + " LIMIT " + CValToChar(n80percent)
	Else
		cQuery := "SELECT TOP " + CValToChar(n80percent) + " CART_EXP FROM " + oTmpCalExp:GetRealName()
    Endif  

    cAliasConcentra := MPSysOpenQuery(cQuery)

    If (cAliasConcentra)->(!EOF())
        (cAliasConcentra)->(DBSkip(n80percent-1))
        nConc80 := (cAliasConcentra)->CART_EXP
    Endif
    (cAliasConcentra)->(DBCLOSEAREA())

    If __cBDName == 'ORACLE'
		cQuery := "SELECT CART_EXP FROM " + oTmpCalExp:GetRealName() + " WHERE ROWNUM < " + CValToChar(n90percent)
	ElseIf __cBDName == 'POSTGRES'
		cQuery := "SELECT CART_EXP FROM " + oTmpCalExp:GetRealName() + " LIMIT " + CValToChar(n90percent)
	Else
		cQuery := "SELECT TOP " + CValToChar(n90percent) + " CART_EXP FROM " + oTmpCalExp:GetRealName()
    Endif  

    cAliasConcentra := MPSysOpenQuery(cQuery)

    If (cAliasConcentra)->(!EOF())
        (cAliasConcentra)->(DBSkip(n90percent-1))
        nConc90 := (cAliasConcentra)->CART_EXP
    Endif
    (cAliasConcentra)->(DBCLOSEAREA())
    
	aRet := {a5CNPJs,a5CPFs,nConc70,nConc80,nConc90}

    TCDelFile(cTMP)

Return aRet

/*/{Protheus.doc} FQueryCli
    Execução das querys referentes as metricas do top 5 clientes
    @type  Static Function
    @author Vitor Duca
    @since 18/08/2021
    @version 1.0
    @param cTblTmp, Character, Tabela que sera alimentada pela Stored Procedure
    @param nTipo, Numeric, Numero que ira identificar qual procedure devera ser executada
    @return NIL
/*/
Static Function FQueryCli(cTable As Character, cPessoa As Character, aDados As Array, cDataDe As Character, cDataAte As Character)
    Local cQuery As Character
    Local cAliasExpo As Character
    Local nPercPont As Numeric
    Local nFatMed As Numeric
    Local nMeses As Numeric
    Local nMaxVlRec As Numeric
    Local nX As Numeric
    Local cSubs As Character
    Local cWhere As Character

    nMeses := DateDiffMonth(__dDataAt,__dDataDe)
    nPercPont := 0
    nFatMed := 0
    nMaxVlRec := 0
    nX := 0
    cQuery := ""
    cSubs  := VerFuncDb("SUBSTRING")

    For nX := 1 To Len(aDados)

        If cPessoa == "J"
            cWhere :=                    "AND " + cSubs + "(SA1.A1_CGC,1,8) = '" + aDados[nX][CGC_CPF] + "' "
        Else
            cWhere :=                    "AND SA1.A1_CGC = '" + aDados[nX][CGC_CPF] + "' "
        Endif

        cQuery := "SELECT DISTINCT (SELECT COUNT(*) "
        cQuery +=                "FROM " + cTable + " TMP "
        cQuery +=                "INNER JOIN " + RetSqlName("SA1") + " SA1 "
        cQuery +=                   "ON SA1.A1_COD = TMP.CLIENTE "
        cQuery +=                   "AND SA1.A1_LOJA = TMP.LOJA "
        cQuery +=                   "AND SA1.D_E_L_E_T_ = ' ' "
        cQuery +=                "WHERE  TMP.BAIXA <= TMP.VENCREA "
        cQuery +=                    "AND TMP.BAIXA <> '        ' "
        cQuery +=                    cWhere
        cQuery +=                    "AND SA1.A1_PESSOA = '"+cPessoa+"' "
        cQuery +=                    "AND TMP.SALDO = 0 "
        cQuery +=                    "AND TMP.D_E_L_E_T_ = ' ') PAGO_DIA, "
        cQuery +=        "(SELECT COUNT(*)  "
        cQuery +=                "FROM " + cTable + " TMP "
        cQuery +=                "INNER JOIN " + RetSqlName("SA1") + " SA1 "
        cQuery +=                   "ON SA1.A1_COD = TMP.CLIENTE "
        cQuery +=                   "AND SA1.A1_LOJA = TMP.LOJA "
        cQuery +=                   "AND SA1.D_E_L_E_T_ = ' ' "
        cQuery +=                "WHERE TMP.BAIXA <> '        ' "
        cQuery +=                        cWhere
        cQuery +=                        "AND SA1.A1_PESSOA = '"+cPessoa+"' "
        cQuery +=                        "AND TMP.SALDO = 0 "
        cQuery +=                        "AND TMP.D_E_L_E_T_ = ' ') PAGO_TOTAL FROM " + cTable

        cAliasExpo := MPSysOpenQuery(cQuery)
        nPercPont := 0
        If (cAliasExpo)->(!Eof()) .and. (cAliasExpo)->PAGO_TOTAL <> 0
            nPercPont := Round((cAliasExpo)->PAGO_DIA / (cAliasExpo)->PAGO_TOTAL * 100,2)
        ENDIF

        (cAliasExpo)->(DbCloseArea())

        cQuery := "SELECT "+VerFuncDb("ISNULL")+"(SUM(F2_VALFAT),0) TOTAL_FAT "
        cQuery += "FROM " + RetSqlName("SF2") + " SF2 "
        cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
        cQuery +=               "ON SA1.A1_COD = SF2.F2_CLIENTE "
        cQuery +=               "AND SA1.A1_LOJA = SF2.F2_LOJA "
        cQuery +=               cWhere
        cQuery +=               "AND SA1.D_E_L_E_T_ = ' ' "
        cQuery += "WHERE F2_DUPL <> '"+Space(TAMSX3("F2_DUPL")[1])+"' "
        cQuery += "  AND F2_EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "
        cQuery += "  AND SF2.D_E_L_E_T_ = ' ' "

        nFatMed := MpSysExecScalar(cQuery,"TOTAL_FAT") / nMeses

        cQuery := "SELECT MAX(VLCRUZ) VALOR_MAIOR_RECEB "
        cQuery += "  FROM " + RetSqlName("SA1") + " SA1 "
        cQuery += " INNER JOIN " + cTable + " "
        cQuery +=        " ON CLIENTE = SA1.A1_COD "
        cQuery +=        " AND LOJA = SA1.A1_LOJA "
        cQuery +=        " AND BAIXA <> '        ' "
        cQuery +=        " AND SALDO = 0 "
        cQuery += " WHERE SA1.A1_PESSOA = '"+cPessoa+"' "
        cQuery += cWhere
        cQuery += " AND SA1.D_E_L_E_T_ = '' "

        nMaxVlRec := MpSysExecScalar(cQuery,"VALOR_MAIOR_RECEB")

        aDados[nX][PERC_PONTUAL] := nPercPont
        aDados[nX][FAT_MEDIO] := nFatMed
        aDados[nX][MAIOR_RECEB] := nMaxVlRec
    Next nX

Return
/*/{Protheus.doc} FExecProc
    Criação e execução da Stored procedure que sera responsavel por calcular
    a exposição da carteira
    @type  Static Function
    @author Vitor Duca
    @since 05/08/2021
    @version 1.0
    @param cTblTmp, Character, Tabela que sera alimentada pela Stored Procedure
    @param nTipo, Numeric, Numero que ira identificar qual procedure devera ser executada
           1 = Contas a Pagar (Maior Valor contas a pagar)
           2 = Contas a Receber (Valor Maior acumulo dos 5 clientes)
    @return cLogMsg, Character, Mensagem de erro, caso a execução foi concluida sem erros, sera retornado a variavel vazia
/*/
Static Function FExecProc(cTblTmp As Character, nTipo As Numeric) As Character
    Local cErro As Character
    Local cOut As Character
    Local cLogMsg As Character

    DEFAULT cTblTmp := ""
    DEFAULT nTipo   := 0

    cErro := ""
    cOut := ""
    cLogMsg := ""

    If TCSPExist("UPDTMP_"+cEmpAnt)
	    If TcSqlExec("DROP PROCEDURE UPDTMP_"+cEmpAnt) < 0
            cLogMsg := STR0029 + TcSqlError() + chr(10) // 'Erro na reconstrução da Stored Procedure : '
        Endif
	EndIf

    If Empty(cLogMsg)
        If nTipo == 1
            cQuery := "CREATE PROCEDURE UPDTMP_" + cEmpAnt + " AS " + CRLF
            cQuery += "DECLARE CUR_SEQUEN CURSOR FOR SELECT  VAL_PAGO, VAL_COMPRA, CART_EXP, R_E_C_N_O_ " + CRLF
            cQuery +=     "FROM " + cTblTmp + " " + CRLF
            cQuery +=     "DECLARE @RESULT FLOAT " + CRLF
            cQuery +=     "DECLARE @VAL_PAGO FLOAT " + CRLF
            cQuery +=     "DECLARE @VAL_COMPRA FLOAT " + CRLF
            cQuery +=     "DECLARE @ACUMULADO FLOAT = 0 " + CRLF
            cQuery +=     "DECLARE @CART_EXP FLOAT " + CRLF
            cQuery +=     "DECLARE @RECNO INT " + CRLF
            cQuery +=     "OPEN CUR_SEQUEN " + CRLF
            cQuery +=     "FETCH NEXT FROM CUR_SEQUEN " + CRLF
            cQuery +=     "INTO @VAL_PAGO,@VAL_COMPRA, @CART_EXP, @RECNO " + CRLF
            cQuery +=     "WHILE @@FETCH_STATUS = 0 " + CRLF
            cQuery +=         "BEGIN " + CRLF
            cQuery +=             "SELECT @RESULT = (@VAL_COMPRA + @ACUMULADO) - @VAL_PAGO " + CRLF
            cQuery +=             "SELECT @ACUMULADO = @RESULT " + CRLF
            cQuery +=             "UPDATE " + cTblTmp + " SET CART_EXP = ROUND(@ACUMULADO,2) WHERE R_E_C_N_O_ =  @RECNO " + CRLF
            cQuery +=             "FETCH NEXT FROM CUR_SEQUEN " + CRLF
            cQuery +=             "INTO @VAL_PAGO,@VAL_COMPRA,@CART_EXP, @RECNO " + CRLF
            cQuery +=         "END " + CRLF
            cQuery +=     "CLOSE CUR_SEQUEN " + CRLF
            cQuery +=     "DEALLOCATE CUR_SEQUEN " + CRLF

        ELSEIF nTipo == 2
            cQuery := "CREATE PROCEDURE UPDTMP_" + cEmpAnt + " AS " + CRLF
            cQuery += "DECLARE CUR_SEQUEN CURSOR FOR SELECT  VAL_VEND, VAL_RECB, CART_EXP, CGC, R_E_C_N_O_ " + CRLF
            cQuery +=    "FROM " + cTblTmp + " " + CRLF
            cQuery +=    "DECLARE @RESULT FLOAT " + CRLF
            cQuery +=    "DECLARE @VAL_VEND FLOAT " + CRLF
            cQuery +=    "DECLARE @VAL_RECB FLOAT " + CRLF
            cQuery +=    "DECLARE @ACUMULADO FLOAT = 0 " + CRLF
            cQuery +=    "DECLARE @CART_EXP FLOAT " + CRLF
            cQuery +=    "DECLARE @RECNO INT " + CRLF
            cQuery +=    "DECLARE @CGC VARCHAR(14) " + CRLF
            cQuery +=    "DECLARE @LAST_CGC VARCHAR(14) " + CRLF
            cQuery +=    "OPEN CUR_SEQUEN " + CRLF
            cQuery +=    "FETCH NEXT FROM CUR_SEQUEN " + CRLF
            cQuery +=    "INTO @VAL_VEND,@VAL_RECB, @CART_EXP, @CGC, @RECNO " + CRLF
            cQuery +=    "WHILE @@FETCH_STATUS = 0 " + CRLF
            cQuery +=        "BEGIN " + CRLF
            cQuery +=            "IF @LAST_CGC = '' " + CRLF
            cQuery +=                "SELECT @LAST_CGC = @CGC " + CRLF
            cQuery +=            "ELSE " + CRLF
            cQuery +=                "IF @LAST_CGC <> @CGC " + CRLF
            cQuery +=                    "SELECT @ACUMULADO = 0 " + CRLF
            cQuery +=                    "SELECT @LAST_CGC = @CGC " + CRLF
            cQuery +=            "SELECT @RESULT = (@VAL_VEND + @ACUMULADO) - @VAL_RECB " + CRLF
            cQuery +=            "SELECT @ACUMULADO = @RESULT " + CRLF
            cQuery +=            "UPDATE FIN_TMP SET CART_EXP = ROUND(@ACUMULADO,2) WHERE R_E_C_N_O_ =  @RECNO " + CRLF
            cQuery +=            "FETCH NEXT FROM CUR_SEQUEN " + CRLF
            cQuery +=            "INTO @VAL_VEND,@VAL_RECB, @CART_EXP, @CGC, @RECNO " + CRLF
            cQuery +=        "END " + CRLF
            cQuery +=    "CLOSE CUR_SEQUEN " + CRLF
            cQuery +=    "DEALLOCATE CUR_SEQUEN " + CRLF
        ENDIF

        If MsParseFull(cQuery,__cBDName, @cErro, @cOut) == '1'

            If TcSqlExec(cOut) < 0
                cLogMsg := STR0030 + TcSqlError() + chr(10) //'Erro na criação da Stored Procedure : '
            Else
                TCSPEXEC( xProcedures("UPDTMP") )
                If !Empty(TcSqlError())
                    cLogMsg := STR0031 + TcSqlError() + chr(10) //'Erro na execução da Stored Procedure : '
                Endif
            Endif
        Else
            cLogMsg := STR0032 /*"Resultado: Falha!"*/ + chr(10) + "Error: " + cErro + chr(10) + STR0033 /*"Parcial: "*/ + cOut
        Endif

        If TCSPExist("UPDTMP_"+cEmpAnt) .and. TcSqlExec("DROP PROCEDURE UPDTMP_"+cEmpAnt) <> 0
            cLogMsg := STR0034 + TcSqlError() + chr(10) //"Erro ao deletar Stored procedure"
        Endif

    ENDIF

Return cLogMsg

/*/{Protheus.doc} FIntegInd
    Função para integração, tem por objetivo realizar a extração dos indicadores
    sem necessitar de interface com o usuario
    @type  Function
    @author Vitor Duca
    @since 13/08/2021
    @version 1.0
    @param aGrpSM0, Array, Array contendo os grupos de empresa
    @param dDataDe, Date, Data de inicio que sera usada para definir o periodo de extração
    @param dDataAte, Date, Data final que sera usada para definir o periodo de extração
/*/
Function FIntegInd(aGrpSM0 As Array, dDataDe As Date, dDataAte As Date) As Logical

    DEFAULT aGrpSM0 := {}
    DEFAULT dDataDe := CTOD("//")
    DEFAULT dDataAte := CTOD("//")

    PutGlbVars("EMP_SM0", aGrpSM0)
    PutGlbVars("DATADE", dDataDe)
    PutGlbVars("DATAATE", dDataAte)

    ManualJob("FINXIND_JOB", GetEnvServer(),"","","FxIniRPC","FxQuitRPC", "",,,,,,10000)

Return .T.

/*/{Protheus.doc} FxIniRPC
    Inicializa ambiente para envio do indicadores financeiros
    @type  Function
    @author Vitor Duca
    @since 16/08/2021
    @version 1.0
/*/
Function FxIniRPC()
    Local nX := 0
    Local aSM0Grp := {}
    Local dDataDe := CTOD("//")
    Local dDataAte := CTOD("//")

    GetGlbVars("EMP_SM0",aSM0Grp)
    GetGlbVars("DATADE", dDataDe)
    GetGlbVars("DATAATE", dDataAte)

    For nX := 1 to Len(aSM0Grp)
        RpcSetType(3)
        RpcSetEnv( aSM0Grp[nX],,,,"FIN","FINXIND_JOB",,,,.T. )
            IniStatic() //Inicializa variaveis estaticas

            __dDataDe := dDataDe
            __dDataAt := dDataAte

            FExecInd(aSM0Grp[nX])

        RpcClearEnv()
    Next nX
Return

/*/{Protheus.doc} FxQuitRPC
    Finaliza o JOB de envio dos indicadores
    @type  Function
    @author Vitor Duca
    @since 16/08/2021
    @version 1.0
/*/
Function FxQuitRPC()

    ClearGlbValue("EMP_SM0")
    ClearGlbValue("DATADE")
    ClearGlbValue("DATAATE")

RETURN

/*/{Protheus.doc} IniStatic
    Inicializa variaveis estaticas
    @type  Static Function
    @author Vitor Duca
    @since 16/08/2021
    @version 1.0
/*/
Static Function IniStatic()

    __dDataDe  := CTOD(space(8))
    __dDataAt  := CTOD(space(8))
    __cBDName  := AllTrim(tcGetdb())
    __lChkTerm := .F.
    __lSucess  := .F.

Return

/*/{Protheus.doc} WizardFim
    Exibe mensagem final
    @type  Static Function
    @author Vitor Duca
    @since 03/11/2021
    @version 1.0
/*/
Static Function WizardFim()
    Local oModal As Object
    Local oFont As Object
    Local oSay As Object

    If __lSucess
        oFont := TFont():New("Arial",,-15,,.F.,,,,,,.F.,.F.)

        oModal  := FWDialogModal():New()
        oModal:SetEscClose(.F.)
        oModal:setTitle(STR0024) //"Indicadores financeiros"

        //Seta a largura e altura da janela em pixel
        oModal:setSize(200, 250)

        oModal:createDialog()
        oModal:addCloseButton(nil, STR0025) //"Finalizar"

        oSay := TSay():New(5,5,{|| STR0026 + "."+CRLF+CRLF+STR0027},oModal:getPanelMain(),,oFont,,,,.T.,,,oModal:nFreeWidth-1,oModal:nFreeHeight,,,,,,.T.) //"Obrigado pelo envio das informações # "Seus indicadores financeiros serão de suma importância para nossa análise de crédito e em breve retornaremos através de nossa equipe de Crédito ANTECIPA."
        oSay:SetTextAlign( 0, 0 )

        oModal:Activate()
        __Quit()

    Else
        Final(STR0028) //"Abortado pelo operador"
    Endif

Return
