#Include "Protheus.ch"
#Include "FwMVCDef.ch"
#Include "FinTFWizPg.ch"
#Include "FwSchedule.ch"
#Include "FileIO.ch"

//Carteira Techfin
#Define CARTTECF        1 //posição do array
#Define CARTTECF_SIZE   7 //tamanho

//Banco Ponte
#Define BANCO           2 //posição do array
#Define BANCO_SIZE      6 //tamanho

//Motivo de Baixa
#Define MOTBAIXA        3 //posição do array
#Define MOTBAIXA_SIZE   2 //tamanho

//Carteira Devolucao Techfin
#Define CARTTECFDE      4 //posição do array
#Define CARTTECFSZ      7 //tamanho

//Campos
//Carteira Techfin e Carteira Devolucao Techfin
#Define CMP_FRV_CODIGO  1
#Define CMP_FRV_DESCRI  2
#Define CMP_FRV_BANCO   3
#Define CMP_FRV_DESCON  4
#Define CMP_FRV_PROTES  5
#Define CMP_FRV_BLQMOV  6
#Define CMP_FRV_SITPDD  7

//Banco
#Define CMP_A6_COD      1
#Define CMP_A6_AGENCIA  2
#Define CMP_A6_NUMCON   3
#Define CMP_A6_NOME     4
#Define CMP_A6_NREDUZ   5
#Define CMP_A6_MOEDA    6

//Motivo de Baixa
#Define COD_MOTBX   1
#Define DESC_MOTBX  2

/*/{Protheus.doc} FinTFWizPg
Responsavel por montar a tela do wizard do TOTVS Antecipa.

@type       Function
@author     Rafael Riego
@since      19/12/2019
@version    P12.1.27
@param      oDlg, object, onde sera criado a tela do wizard
@return     aFinParam array, array contendo dados captados pelo wizard
/*/
Function FinTFWizPg() As Logical

    Local aBanco        As Array
    Local aFinParam     As Array

    Local cAgpoTechF    As Character
    Local cBcpoTechF    As Character
    Local cCarDTechF    As Character
    Local cCartTechF    As Character
    Local cCodMotBx     As Character
    Local cCtPoTechF    As Character
    Local cQuery        As Character
    Local cTempAlias    As Character

    Local lBlqBanco     As Logical
    Local lBlqCart      As Logical
    Local lBlqCartDe    As Logical
    Local lBlqMotBx     As Logical

    Local nColuna1      As Numeric
    Local nColuna2      As Numeric
    Local nLinha1       As Numeric
    Local nLinha2       As Numeric

    Local oDlg          As Object

    aBanco      := F136AjstBc()

    cBcpoTechF  := aBanco[1]
    cAgpoTechF  := aBanco[2]
    cCarDTechF  := F136Cartei("MV_DEVTECF")
    cCartTechF  := F136Cartei("MV_CARTECF")
    cCodMotBx   := PadR(SuperGetMV("MV_MOTTECF", .F., ""), TamSX3("FK1_MOTBX")[1])
    cCtPoTechF  := aBanco[3]

    lBlqBanco   := !(Empty(cBcpoTechF)) .And. !(Empty(cAgpoTechF)) .And. !(Empty(cCtPoTechF))
    lBlqCart    := !(Empty(cCartTechF))
    lBlqCartDe  := !(Empty(cCarDTechF))

    //posições dos agrupadores
    aFinParam := Array(4)
    
    //criação dos subarrays
    aFinParam[CARTTECF]     := Array(CARTTECF_SIZE)
    aFinParam[BANCO]        := Array(BANCO_SIZE)
    aFinParam[MOTBAIXA]     := Array(MOTBAIXA_SIZE)
    aFinParam[CARTTECFDE]   := Array(CARTTECF_SIZE)

    //Dados Carteira TOTVS Antecipa
    aFinParam[CARTTECF][CMP_FRV_DESCRI] := STR0001    //"CARTEIRA TOTVS ANTECIPA"
    aFinParam[CARTTECF][CMP_FRV_BANCO]  := "1"
    aFinParam[CARTTECF][CMP_FRV_DESCON] := "1"
    aFinParam[CARTTECF][CMP_FRV_PROTES] := "2"
    aFinParam[CARTTECF][CMP_FRV_BLQMOV] := "1"
    aFinParam[CARTTECF][CMP_FRV_SITPDD] := "2"

    //Descrição Motivo de Baixa Antecipa
    aFinParam[MOTBAIXA][DESC_MOTBX] := "ANTECIPA  " //não será permitido alteração da descrição do motivo de baixa
    
    //Dados Carteira Devolução TOTVS Antecipa
    aFinParam[CARTTECFDE][CMP_FRV_DESCRI]   := STR0051 // "CARTEIRA DEVOLUCAO TOTVS ANTECIPA" 
    aFinParam[CARTTECFDE][CMP_FRV_BANCO]    := "2" //FRV_BANCO
    aFinParam[CARTTECFDE][CMP_FRV_DESCON]   := "" //FRV_DESCON
    aFinParam[CARTTECFDE][CMP_FRV_PROTES]   := "2" //FRV_PROTES 
    aFinParam[CARTTECFDE][CMP_FRV_BLQMOV]   := "1" //FRV_BLQMOV
    aFinParam[CARTTECFDE][CMP_FRV_SITPDD]   := "2" //FRV_SITPDD

    If lBlqCart
        aFinParam[CARTTECF][CMP_FRV_CODIGO] := AllTrim(cCartTechF)
        cQuery := " SELECT FRV_DESCRI"
        cQuery += " FROM " + RetSQLName("FRV") + " FRV"
        cQuery += " WHERE FRV.D_E_L_E_T_ = ' '"
        cQuery += " AND FRV.FRV_CODIGO = '" + cCartTechF + "'"

        cQuery := ChangeQuery(cQuery)

        cTempAlias := MPSysOpenQuery(cQuery)

        If !(Empty((cTempAlias)->FRV_DESCRI))
            aFinParam[CARTTECF][CMP_FRV_DESCRI] := (cTempAlias)->FRV_DESCRI
        EndIf
    
        (cTempAlias)->(DbCloseArea())
    Else
        aFinParam[CARTTECF][CMP_FRV_CODIGO] := "T"
        VlCarTech(@aFinParam[CARTTECF][CMP_FRV_CODIGO])
    EndIf

    If lBlqCartDe
        aFinParam[CARTTECFDE][CMP_FRV_CODIGO] := AllTrim(cCarDTechF)
        cQuery := " SELECT FRV_DESCRI"
        cQuery += " FROM " + RetSQLName("FRV") + " FRV"
        cQuery += " WHERE FRV.D_E_L_E_T_ = ' '"
        cQuery += " AND FRV.FRV_CODIGO = '" + cCarDTechF + "'"

        cQuery := ChangeQuery(cQuery)

        cTempAlias := MPSysOpenQuery(cQuery)

        If !(Empty((cTempAlias)->FRV_DESCRI))
            aFinParam[CARTTECFDE][CMP_FRV_DESCRI] := (cTempAlias)->FRV_DESCRI
        EndIf
    
        (cTempAlias)->(DbCloseArea())
    Else
        aFinParam[CARTTECFDE][CMP_FRV_CODIGO] := "U"
        VlCarTech(@aFinParam[CARTTECFDE][CMP_FRV_CODIGO], aFinParam[CARTTECF][CMP_FRV_CODIGO])
    EndIf

    If lBlqBanco
        aFinParam[BANCO][CMP_A6_COD]        := cBcpoTechF
        aFinParam[BANCO][CMP_A6_AGENCIA]    := cAgpoTechF
        aFinParam[BANCO][CMP_A6_NUMCON]     := cCtPoTechF

        cQuery := " SELECT A6_NOME, A6_NREDUZ, A6_MOEDA"
        cQuery += " FROM " + RetSQLName("SA6") + " SA6"
        cQuery += " WHERE SA6.D_E_L_E_T_ = ' '"
        cQuery += "   AND SA6.A6_COD     = '" + cBcpoTechF + "'"
        cQuery += "   AND SA6.A6_AGENCIA = '" + cAgpoTechF + "'"
        cQuery += "   AND SA6.A6_NUMCON  = '" + cCtPoTechF + "'"

        cQuery := ChangeQuery(cQuery)

        cTempAlias := MPSysOpenQuery(cQuery)

        If !(Empty((cTempAlias)->A6_NOME))
            aFinParam[BANCO][CMP_A6_NOME] := (cTempAlias)->A6_NOME
        Else
            aFinParam[BANCO][CMP_A6_NOME] := STR0004 + Space(12) //"ANTECIPA - CONTA TRANSITORIA"
        EndIf

        If !(Empty((cTempAlias)->A6_NREDUZ))
            aFinParam[BANCO][CMP_A6_NREDUZ] := (cTempAlias)->A6_NREDUZ
        Else
            aFinParam[BANCO][CMP_A6_NREDUZ] := "ANTECIPA"
        EndIf

        If !(Empty((cTempAlias)->A6_MOEDA))
            aFinParam[BANCO][CMP_A6_MOEDA] := (cTempAlias)->A6_MOEDA
        Else
            aFinParam[BANCO][CMP_A6_MOEDA] := 1
        EndIf

        (cTempAlias)->(DbCloseArea())
    Else
        If VldBancoTF({"ANT", "ANT", "ANTECIPA"}, .F., .F.)
            aFinParam[BANCO][CMP_A6_NUMCON] := PadR("ANTECIPA", TamSX3("A6_NUMCON")[1]) //Conta
        Else
            aFinParam[BANCO][CMP_A6_NUMCON] := Space(TamSX3("A6_NUMCON")[1])
        EndIf
        aFinParam[BANCO][CMP_A6_COD]        := "ANT" //"ANT"
        aFinParam[BANCO][CMP_A6_AGENCIA]    := PadR("ANT", TamSX3("A6_AGENCIA")[1]) //Agencia
        aFinParam[BANCO][CMP_A6_NOME]       := PadR(STR0004, TamSX3("A6_NOME")[1]) //"ANTECIPA - CONTA TRANSITORIA"
        aFinParam[BANCO][CMP_A6_NREDUZ]     := PadR("ANTECIPA", TamSX3("A6_NREDUZ")[1]) //Nome Reduzido do banco
        aFinParam[BANCO][CMP_A6_MOEDA]      := 1
    EndIf

    //Verifico se o motivo de baixa já existe na chave interna e gravo
    cCodMotBx := FTUpdMotBx(cCodMotBx)

    lBlqMotBx   := !(Empty(cCodMotBx))

    If lBlqMotBx
        aFinParam[MOTBAIXA][COD_MOTBX] := cCodMotBx
    Else
        //Caso não exista, insere o motivo ANT como sugestão
        If Empty(BuscaMotBx("ANT"))
            aFinParam[MOTBAIXA][COD_MOTBX] := "ANT"
        Else
            aFinParam[MOTBAIXA][COD_MOTBX] := "   "
        EndIf
    EndIf

    DEFINE MSDIALOG oDlg TITLE STR0052 + FWCompany() STYLE DS_MODALFRAME FROM 230,180 TO 550,830 PIXEL   //Preenchimento Parâmetros:
    oDlg:lEscClose := .F.

    @001.0, 050 GROUP TO 048.0, 285 PROMPT STR0005 OF oDlg PIXEL //"Dados Situação de Cobrança"
    @048.5, 050 GROUP TO 095.5, 285 PROMPT STR0006 OF oDlg PIXEL //"Dados Banco Portador"
    @096.0, 050 GROUP TO 126.0, 285 PROMPT STR0028 of oDlg PIXEL //"Dados Motivo de Baixa"

    nColuna1 := 054 //posição fixa da primeira coluna
    nColuna2 := 115 //posição fixa da segunda coluna
    
    //FRV - Situação de Cobrança - Carteira Techfin
    //primeira linha de campos
    nLinha1 := 008
    nLinha2 := nLinha1 + 007 //15

    @nLinha1, nColuna1 SAY STR0007  SIZE 200, 20 OF oDlg PIXEL //"Código"
    @nLinha2, nColuna1 MSGET aFinParam[CARTTECF][CMP_FRV_CODIGO]   SIZE 030, 09 OF oDlg PIXEL PICTURE "@!" WHEN .F.;
        VALID VldAlfanum(aFinParam[CARTTECF][CMP_FRV_CODIGO]) .And. VldCarteTF(aFinParam[CARTTECF][CMP_FRV_CODIGO])

    @nLinha1, nColuna2 SAY STR0027  SIZE 200, 20 OF oDlg PIXEL //"Descrição"
    @nLinha2, nColuna2 MSGET aFinParam[CARTTECF][CMP_FRV_DESCRI]   SIZE 125, 09 OF oDlg PIXEL PICTURE "@!" WHEN .F.

    //FRV - Situação de Cobrança - Carteira Devolução Techfin
    //segunda linha de campos
    nLinha1 += 020 //028
    nLinha2 := nLinha1 + 007 //35

    @nLinha1, nColuna1 SAY STR0007  SIZE 200, 20 OF oDlg PIXEL //"Código"
    @nLinha2, nColuna1 MSGET aFinParam[CARTTECFDE][CMP_FRV_CODIGO]   SIZE 030, 09 OF oDlg PIXEL PICTURE "@!" WHEN .F.;
        VALID VldAlfanum(aFinParam[CARTTECFDE][CMP_FRV_CODIGO]) .And. VldCarteTF(aFinParam[CARTTECFDE][CMP_FRV_CODIGO])

    @nLinha1, nColuna2 SAY STR0027  SIZE 200, 20 OF oDlg PIXEL //"Descrição"
    @nLinha2, nColuna2 MSGET aFinParam[CARTTECFDE][CMP_FRV_DESCRI]   SIZE 125, 09 OF oDlg PIXEL PICTURE "@!" WHEN .F.

    //SA6 - Bancos
    //primeira linha de campos
    nLinha1 := 055
    nLinha2 := nLinha1 + 007 //062

    @nLinha1, nColuna1 SAY STR0008  SIZE 200, 20 OF oDlg PIXEL //"Código"
    @nLinha2, nColuna1 MSGET aFinParam[BANCO][CMP_A6_COD]   SIZE 030, 09 OF oDlg PIXEL PICTURE "@!" WHEN !lBlqBanco ;
        VALID VldAlfanum(aFinParam[BANCO][CMP_A6_COD]) .And. VldBancoTF(aFinParam[BANCO])

    @nLinha1, nColuna2 SAY STR0009  SIZE 200, 20 OF oDlg PIXEL //"Nome"
    @nLinha2, nColuna2 MSGET aFinParam[BANCO][CMP_A6_NOME]   SIZE 125, 09 OF oDlg PICTURE "@!" PIXEL WHEN .F.
    
    //segunda linha de campos
    nLinha1 += 20 //75
    nLinha2 := nLinha1 + 007 //82

    @nLinha1, nColuna1 SAY STR0010  SIZE 200, 20 OF oDlg PIXEL //"Agência"
    @nLinha2, nColuna1 MSGET aFinParam[BANCO][CMP_A6_AGENCIA] SIZE 030, 09 OF oDlg PICTURE "@!" PIXEL WHEN !lBlqBanco ;
        VALID VldAlfanum(aFinParam[BANCO][CMP_A6_AGENCIA]) .And. VldBancoTF(aFinParam[BANCO])

    @nLinha1, nColuna2 SAY STR0011  SIZE 200, 20 OF oDlg PIXEL    //"Conta"
    @nLinha2, nColuna2 MSGET aFinParam[BANCO][CMP_A6_NUMCON]   SIZE 060, 09 OF oDlg PICTURE "@!" PIXEL WHEN !lBlqBanco ;
        VALID VldAlfanum(aFinParam[BANCO][CMP_A6_NUMCON]) .And. VldBancoTF(aFinParam[BANCO])

    //Motivo de Baixa
    //primeira linha de campos
    nLinha1     := 104
    nLinha2     := 111
    @nLinha1, nColuna1 SAY STR0029           SIZE 200, 20 OF oDlg PIXEL    //"Sigla"
    @nLinha2, nColuna1 MSGET aFinParam[MOTBAIXA][COD_MOTBX]   SIZE 030, 09 OF oDlg PIXEL PICTURE "@!" WHEN !lBlqMotBx ;
        VALID VldAlfanum(aFinParam[MOTBAIXA][COD_MOTBX]) .And. VldMotBx(aFinParam[MOTBAIXA][COD_MOTBX])

    @nLinha1, nColuna2 SAY STR0030           SIZE 200, 20 OF oDlg PIXEL    //"Descrição"
    @nLinha2, nColuna2 MSGET aFinParam[MOTBAIXA][DESC_MOTBX]   SIZE 060, 09 OF oDlg PIXEL PICTURE "@!" WHEN .F.

    @ 135,150 BUTTON STR0053 SIZE 040, 015 PIXEL OF oDlg ACTION (FinTFWizPr(aFinParam), oDlg:End())   //Confirmar

    ACTIVATE DIALOG oDlg CENTERED

Return .T.

/*/{Protheus.doc} FinTfWizVl
Responsavel pela validacao dos dados da situaçao de cobrança e banco passados no wizard.

@type       Function
@author     Rafael Riego
@since      19/12/2019
@version    P12.1.27
@param      aFinParam array, array com dados do wizard
@return     Verdadeiro caso todos os dados sejam validados com sucesso
/*/
Function FinTfWizVl(aFinParam As Array) As Logical

    Local cAgpoTechF    As Character
    Local cBcpoTechF    As Character
    Local cCarDTechF    As Character
    Local cCartTechF    As Character
    Local cCodMotBx     As Character
    Local cCtPoTechF    As Character

    Local lRet          As Logical
    Local lVldBanco     As Logical
    Local lVldCart      As Logical
    Local lVldCartDe    As Logical
    Local lVldMotBx     As Logical

    Default aFinParam := {}

    aBanco      := F136AjstBc()

    cBcPoTechF  := aBanco[1]
    cAgPoTechF  := aBanco[2]
    cCarDTechF  := F136Cartei("MV_DEVTECF")
    cCartTechF  := F136Cartei("MV_CARTECF")
    cCodMotBx   := PadR(GetMV("MV_MOTTECF", .F., ""), TamSX3("FK1_MOTBX")[1])
    cCtPoTechF  := aBanco[3]
    lRet        := .T.
    lVldBanco   := Empty(cBcpoTechF) .And. Empty(cAgpoTechF) .And. Empty(cCtPoTechF)
    lVldCart    := Empty(cCartTechF)
    lVldMotBx   := Empty(cCodMotBx)
    lVldCartDe  := Empty(cCarDTechF)
    
    If !(ValidParam())
        lRet := .F.
    ElseIf lVldCart .And. (!(VldAlfanum(aFinParam[CARTTECF][CMP_FRV_CODIGO])) .Or. !(VldCarteTF(aFinParam[CARTTECF][CMP_FRV_CODIGO])))
        lRet := .F.
    ElseIf lVldCartDe .And. (!(VldAlfanum(aFinParam[CARTTECFDE][CMP_FRV_CODIGO])) .Or. !(VldCarteTF(aFinParam[CARTTECFDE][CMP_FRV_CODIGO])))
        lRet := .F.
    ElseIf lVldBanco .And. ((!(VldAlfanum(aFinParam[BANCO][CMP_A6_COD])) .Or. !(VldAlfanum(aFinParam[BANCO][CMP_A6_AGENCIA])) .Or.;
        !(VldAlfanum(aFinParam[BANCO][CMP_A6_NUMCON]))) .Or. !(VldBancoTF(aFinParam[BANCO],, .F.)))
        lRet := .F.
    ElseIf lVldMotBx .And. (!(VldAlfanum(aFinParam[MOTBAIXA][COD_MOTBX])) .Or. !(VldMotBx(aFinParam[MOTBAIXA][COD_MOTBX])))
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} ValidParam
Verifica se os parâmetros utilizados pelo TOTVS Antecipa estão criados na tabela SX6.

@type       Static Function
@author     Rafael Riego
@since      29/04/2020
@version    P12.1.27
@return     logical, verdadeiro caso os parâmetros tenham sido encontrados
/*/
Static Function ValidParam() As Logical

    Local lExiste   As Logical

    lExiste := .T.

    If !(GetMV("MV_CARTECF", .T.)) .Or. !(GetMV("MV_BCOTECF", .T.)) .Or. !(GetMV("MV_AGETECF", .T.)) .Or.;
        !(GetMV("MV_CTNTECF", .T.)) .Or. !(GetMV("MV_MOTTECF", .T.)) .Or. !(GetMV("MV_DEVTECF", .T.))
        lExiste := .F.
        Help(Nil, Nil, "NOPARAM", "", STR0031 , 1,; //"Um ou mais parâmetros Financeiros do TOTVS Antecipa não foram encontrados."
            ,,,,,,{STR0032}) // "Execute o UPDDISTR de acordo com a última expedição contínua para criação dos parâmetros Financeiros do TOTVS Antecipa."
    EndIf

Return lExiste

/*/{Protheus.doc} FinTFWizPr
Verifica o nivel de compartilhamento das tabelas FRV e SA6 e chama as funções de execauto de cada rotina, 
tambem salva os parametros MV_CARTECF, MV_BCOTECF, MV_AGETECF, MV_CTNTECF e MV_MOTTECF.

@type       Function
@author     Pedro Castro
@since      19/12/2019
@version    P12.1.27
@param      aFinParam, array, array com dados do wizard
@return     logical, verdadeiro caso tenha criado todos os dados financeiros
/*/
Function FinTFWizPr(aFinParam As Array) As Logical

    Local aAllCompany   As Array
    Local aAllUnit      As Array
    Local aCartEmp      As Array
    Local aFilial       As Array

    //Modo de acesso tabelas
    Local cAgend        As Character
    Local cEmpBkp       As Character
    Local cFilBkp       As Character
    Local cMsgErro      As Character

    Local cTempAlias    As Character

    Local nEmpresa      As Numeric
    Local nFilial       As Numeric
    Local nUnidadNeg    As Numeric

    Local lFRVEmpExc    As Logical
    Local lFRVFilExc    As Logical
    Local lFRVUniExc    As Logical
    Local lGestaoEmp    As Logical
    Local lGestaoUni    As Logical
    Local lSA6EmpExc    As Logical
    Local lSA6UniExc    As Logical
    Local lSA6FilExc    As Logical
    Local lGravou       As Logical

    Default aFinParam   := {}

    aAllCompany := {}
    aAllUnit    := {}
    aCartEmp    := {}
    aFilial     := {}
    cTempAlias  :=  GetNextAlias()
    cFilBkp     := cFilAnt
    cEmpBkp     := cEmpAnt
    cMsgErro    := ""
    lGravou     := .F. 

    lGestaoEmp := !Empty(FWSM0Layout(,1))
    lGestaoUni := !Empty(FWSM0Layout(,2))

    lFRVEmpExc  := FwModeAccess("FRV", 1) == "E"
    lFRVUniExc  := FwModeAccess("FRV", 2) == "E"
    lFRVFilExc  := FwModeAccess("FRV", 3) == "E"
    lSA6EmpExc  := FwModeAccess("SA6", 1) == "E"
    lSA6UniExc  := FwModeAccess("SA6", 2) == "E"
    lSA6FilExc  := FwModeAccess("SA6", 3) == "E"

    If !lGestaoEmp 
        lFRVEmpExc := lFRVFilExc
        lSA6EmpExc := lSA6FilExc
    EndIf

    If !lGestaoUni
        lFRVUniExc := lFRVFilExc
        lSA6UniExc := lSA6FilExc
    EndIf 

    nEmpresa    := 1
    nUnidadNeg  := 1

    If Len(aFinParam) > 0
        Begin Transaction
            If !lFRVEmpExc //Empresa compartilhada
                If FTFWGrvFRV(aFinParam[CARTTECF]) .And. FTFWGrvFRV(aFinParam[CARTTECFDE])
                    FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0013 + Alltrim(aFinParam[CARTTECF][CMP_FRV_CODIGO]) + STR0014, 0, 0, {}) //"Situacao de cobranca " + " incluida com sucesso"
                    FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0013 + Alltrim(aFinParam[CARTTECFDE][CMP_FRV_CODIGO]) + STR0014, 0, 0, {}) //"Situacao de cobranca " + " incluida com sucesso"
                    lGravou := .T.
                Else
                    cMsgErro := STR0015 + Alltrim(aFinParam[CARTTECF][CMP_FRV_CODIGO]) + CRLF //"Erro ao incluir a situacao de cobranca "
                    cMsgErro := STR0015 + Alltrim(aFinParam[CARTTECFDE][CMP_FRV_CODIGO]) //"Erro ao incluir a situacao de cobranca "
                    FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {})
                    DisarmTransaction()
                    Break
                EndIf
            ElseIf !lFRVUniExc .And. !lFRVFilExc //Unidade Neg. Compartilhada e Filial Compartilhada
                aAllCompany := FwAllCompany(cEmpAnt)
                For nEmpresa := 1 To Len(aAllCompany)
                    cFilAnt := FwAllFilial(aAllCompany[nEmpresa],,, .F.)[1]
                    If FTFWGrvFRV(aFinParam[CARTTECF]) .And. FTFWGrvFRV(aFinParam[CARTTECFDE])
                        FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0013 + Alltrim(aFinParam[CARTTECF][CMP_FRV_CODIGO]) + STR0016 + aAllCompany[nEmpresa], 0, 0, {}) //"Situacao de cobranca " + " incluida com sucesso na empresa "
                        FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0013 + Alltrim(aFinParam[CARTTECF][CMP_FRV_CODIGO]) + STR0016 + aAllCompany[nEmpresa], 0, 0, {}) //"Situacao de cobranca " + " incluida com sucesso na empresa "
                        lGravou := .T.
                    Else
                        cMsgErro := STR0015 + Alltrim(aFinParam[CARTTECF][CMP_FRV_CODIGO]) + STR0017 + aAllCompany[nEmpresa] + CRLF //"Erro ao incluir a situacao de cobranca "
                        cMsgErro := STR0015 + Alltrim(aFinParam[CARTTECFDE][CMP_FRV_CODIGO]) + STR0017 + aAllCompany[nEmpresa] //"Erro ao incluir a situacao de cobranca " 
                        FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {}) 
                        DisarmTransaction()
                        Break
                    EndIf
                Next nEmpresa
                cEmpAnt := cEmpBkp
            ElseIf lFRVUniExc .And. !lFRVFilExc //Unidade Neg. exclusiva e Filial Compartilhada
                aAllCompany := FwAllCompany(cEmpAnt)
                For nEmpresa := 1 To Len(aAllCompany)
                    aAllUnit := FwAllUnitBusiness(aAllCompany[nEmpresa], cEmpAnt)
                    For nUnidadNeg := 1 To Len(aAllUnit)
                        cFilAnt := FwAllFilial(aAllCompany[nEmpresa], aAllUnit[nUnidadNeg], cEmpAnt, .F.)[1]
                        If FTFWGrvFRV(aFinParam[CARTTECF]) .And. FTFWGrvFRV(aFinParam[CARTTECFDE])
                            FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0013 + aFinParam[CARTTECF][CMP_FRV_CODIGO] + STR0018 + aAllCompany[nEmpresa] + aAllUnit[nUnidadNeg], 0, 0, {}) //"Situacao de cobranca " + " incluida com sucesso na filial "
                            FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0013 + aFinParam[CARTTECFDE][CMP_FRV_CODIGO] + STR0018 + aAllCompany[nEmpresa] + aAllUnit[nUnidadNeg], 0, 0, {}) //"Situacao de cobranca " + " incluida com sucesso na filial "
                            lGravou := .T.
                        Else
                            cMsgErro := STR0015 + aFinParam[CARTTECF][CMP_FRV_CODIGO] + STR0019 + aAllCompany[nEmpresa] + aAllUnit[nUnidadNeg] + CRLF //"Erro ao incluir a situacao de cobranca " + " na filial "
                            cMsgErro := STR0015 + aFinParam[CARTTECFDE][CMP_FRV_CODIGO] + STR0019 + aAllCompany[nEmpresa] + aAllUnit[nUnidadNeg] //"Erro ao incluir a situacao de cobranca " + " na filial "
                            FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {}) 
                            DisarmTransaction()
                            Break
                        EndIf
                    Next nUnidadNeg
                Next nEmpresa
                cFilAnt := cFilBkp
            ElseIf lFRVUniExc .And. lFRVFilExc //Unidade Neg. exclusiva e Filial exclusiva
                aFilial := FwAllFilial(,, cEmpAnt, .F.)
                For nFilial := 1 To Len(aFilial)
                    cFilAnt := aFilial[nFilial]
                    If FTFWGrvFRV(aFinParam[CARTTECF]) .And. FTFWGrvFRV(aFinParam[CARTTECFDE])
                        FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0013 + Alltrim(aFinParam[CARTTECF][CMP_FRV_CODIGO]) + STR0018 + aFilial[nFilial], 0, 0, {}) //"Situacao de cobranca " + " incluida com sucesso na filial "
                        FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0013 + Alltrim(aFinParam[CARTTECFDE][CMP_FRV_CODIGO]) + STR0018 + aFilial[nFilial], 0, 0, {}) //"Situacao de cobranca " + " incluida com sucesso na filial "
                        lGravou := .T.
                    Else
                        cMsgErro := STR0015 + Alltrim(aFinParam[CARTTECF][CMP_FRV_CODIGO]) + STR0019 + aFilial[nFilial] + CRLF //"Erro ao incluir a situacao de cobranca " + " na filial "
                        cMsgErro := STR0015 + Alltrim(aFinParam[CARTTECFDE][CMP_FRV_CODIGO]) + STR0019 + aFilial[nFilial] //"Erro ao incluir a situacao de cobranca " + " na filial "
                        FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {}) 
                        DisarmTransaction()
                        Break
                    EndIf
                    cFilAnt := cFilBkp
                Next nFilial
            EndIf
            If !lGravou 
                cMsgErro := STR0015 + Alltrim(aFinParam[CARTTECF][CMP_FRV_CODIGO]) + CRLF //"Erro ao incluir a situacao de cobranca "
                cMsgErro := STR0015 + Alltrim(aFinParam[CARTTECFDE][CMP_FRV_CODIGO]) //"Erro ao incluir a situacao de cobranca "
                FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {})
                DisarmTransaction()
                Break
            EndIf 

            lGravou := .F. 
            If !lSA6EmpExc //Empresa compartilhada
                If FinTGrSA6(aFinParam[BANCO])
                    FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0020 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0022 + cEmpAnt, 0, 0, {}) //"Banco " + " incluido com sucesso na empresa "
                    lGravou := .T.
                Else
                    cMsgErro := STR0021 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0017 + cEmpAnt //"Erro ao incluir o banco " + " na empresa "
                    FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {}) 
                    DisarmTransaction()
                    Break
                EndIf
            ElseIf !lSA6UniExc .And. !lSA6FilExc //Unidade Neg. Compartilhada e Filial Compartilhada
                aAllCompany := FwAllCompany(cEmpAnt)
                For nEmpresa := 1 To Len(aAllCompany)
                    cFilAnt := FwAllFilial(aAllCompany[nEmpresa],,, .F.)[1]
                    If FinTGrSA6(aFinParam[BANCO])
                        FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0020 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0022 + aAllCompany[nEmpresa], 0, 0, {})  //"Banco " + " incluido com sucesso na empresa "
                        lGravou := .T.
                    Else
                        cMsgErro := STR0021 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0017 + aAllCompany[nEmpresa] //"Erro ao incluir o banco " + " na empresa "
                        FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {})  
                        DisarmTransaction()
                        Break
                    EndIf
                Next nEmpresa
                cEmpAnt := cEmpBkp
            ElseIf lSA6UniExc .And. !lSA6FilExc //Unidade Neg. exclusiva e Filial Compartilhada
                aAllCompany := FwAllCompany(cEmpAnt)
                For nEmpresa := 1 To Len(aAllCompany)
                    aAllUnit := FwAllUnitBusiness(aAllCompany[nEmpresa], cEmpAnt)
                    For nUnidadNeg := 1 To Len(aAllUnit)
                        cFilAnt := FwAllFilial(aAllCompany[nEmpresa], aAllUnit[nUnidadNeg], cEmpAnt, .F.)[1]
                        If FinTGrSA6(aFinParam[BANCO])
                            FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0020 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0022 + aAllCompany[nEmpresa] + aAllUnit[nUnidadNeg], 0, 0, {})  //"Banco " + " incluido com sucesso na empresa "
                            lGravou := .T.
                        Else
                            cMsgErro := STR0021 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0017 + aAllCompany[nEmpresa] + aAllUnit[nUnidadNeg] // "Erro ao incluir o banco " + " na empresa "
                            FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {})  
                            DisarmTransaction()
                            Break
                        EndIf
                    Next nUnidadNeg
                Next nEmpresa
                cFilAnt := cFilBkp
            ElseIf lSA6UniExc .And. lSA6FilExc //Unidade Neg. exclusiva e Filial exclusiva
                aFilial := FwAllFilial(,,cEmpAnt,.F.)
                For nFilial := 1 To Len(aFilial)
                    cFilAnt := aFilial[nFilial]
                    If FinTGrSA6(aFinParam[BANCO])
                        FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0020 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0022 + aFilial[nFilial], 0, 0, {}) //"Banco " + " incluido com sucesso na empresa "
                        lGravou := .T.
                    Else
                        cMsgErro := STR0021 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0017 + aFilial[nFilial] //"Erro ao inserir o banco " + " na empresa "
                        FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {})  
                        DisarmTransaction()
                        Break
                    EndIf
                Next nFilial
                cFilAnt := cFilBkp
            EndIf

            If !lGravou
                cMsgErro := STR0021 + Alltrim(aFinParam[BANCO][CMP_A6_NOME]) + STR0017 + cEmpAnt //"Erro ao incluir o banco " + " na empresa "
                FwLogMsg("ERROR",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {}) 
                DisarmTransaction()
                Break
            EndIf

            //caso não encontre no arquivo de baixa, insere o novo motivo
            If Empty(BuscaMotBx(aFinParam[MOTBAIXA][COD_MOTBX]))
                If FTGrvMotBx(aFinParam[MOTBAIXA][COD_MOTBX], aFinParam[MOTBAIXA][DESC_MOTBX])
                    FwLogMsg("INFO",, STR0026, FunName(), "", "01", STR0033, 0, 0, {}) //"Motivo de baixa inserido com sucesso."
                Else
                    cMsgErro := STR0047 //"Erro na inclusão do Motivo de Baixa Antecipa."
                    FwLogMsg("INFO",, STR0026, FunName(), "", "01", cMsgErro, 0, 0, {})
                    DisarmTransaction()
                    Break
                EndIf
            EndIf

            //Realiza a gravação da carteira techfin
            PutMV("MV_CARTECF", aFinParam[CARTTECF][CMP_FRV_CODIGO])
            //Realiza a gravação dos parâmetros de banco techfin
            PutMV("MV_BCOTECF", aFinParam[BANCO][CMP_A6_COD])
            PutMV("MV_AGETECF", aFinParam[BANCO][CMP_A6_AGENCIA])
            PutMV("MV_CTNTECF", aFinParam[BANCO][CMP_A6_NUMCON])
            //Realiza a gravação do motivo de baixa techfin
            FTUpdMotBx(aFinParam[MOTBAIXA][COD_MOTBX])
            PutMV("MV_MOTTECF", aFinParam[MOTBAIXA][COD_MOTBX])
            //Realiza a gravação da carteira de devolução techfin
            PutMV("MV_DEVTECF", aFinParam[CARTTECFDE][CMP_FRV_CODIGO])

            //Somente cria o agendamento do schedule caso o mesmo ainda não exista
            If !(ExisteJob())
                //Executa a cada 10 minutos
                cPeriod := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(0144);Interval(00:10);"
                //(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
                cAgend := FwInsSchedule("FINI136O", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";",;
                    SCHD_ACTIVE, Date(), 6, {cEmpAnt, cFilAnt, "TESTE"})
                If Empty(cAgend)
                    cMsgErro :=  STR0048 // "Não foi possível criar automaticamente o JOB de integração Antecipa." 
                    FwLogMsg("INFO",, "SCHEDULER", FunName(), "", "01", cMsgErro, 0, 0, {}) 
                EndIf
            EndIf
        End Transaction

        If !(Empty(cMsgErro))
            Help(Nil, Nil, "Financeiro", "", STR0049 + CRLF + CRLF + cMsgErro, 1,,,,,,,; //"Ocorreu um erro na gravação dos dados financeiros:"
                { STR0050 }) //"Execute novamente este Wizard para incluir os dados financeiros necessários para o TOTVS Antecipa."
        EndIf
    EndIf

Return Empty(cMsgErro)

/*/{Protheus.doc} FTFWGrvFRV
Responsavel por gravar o registro na FRV(Situação de Cobrança) e FW2(Sit. Cobrança x Proc. Bloquear)

@type       Function
@author     Pedro Castro
@since      23/12/2019
@version    P12.1.27
@param      aCarteira, array, array com dados do wizard
@return     logical, verdadeiro caso todos os dados passados sejam gravados
/*/
Function FTFWGrvFRV(aCarteira As Array) As Logical

    Local cQuery        As Character
    Local cTempAlias    As Character

    Local lRet          As Logical
    Local oModel        As Object
    Local oFRVMod       As Object
    Local oFW2Mod       As Object

    lRet        := .T.
    oModel      := Nil
    oFRVMod     := Nil
    oFW2Mod     := Nil

    cQuery := " SELECT FRV_FILIAL, FRV_CODIGO" 
    cQuery += " FROM " + RetSQLName("FRV") + " FRV"
    cQuery += " WHERE "
    cQuery += " FRV.FRV_FILIAL = '" + FwXFilial("FRV") + "' "
    cQuery += " AND FRV.FRV_CODIGO = '" + PadR(aCarteira[CMP_FRV_CODIGO], TamSX3("FRV_CODIGO")[1]) + "'"
    cQuery += " AND FRV.D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)

    cTempAlias := MPSysOpenQuery(cQuery)

    If !(Empty((cTempAlias)->FRV_CODIGO))
        (cTempAlias)->(DbCloseArea())
        Return .T.
    EndIf
    (cTempAlias)->(DbCloseArea())

    cQuery := " SELECT FW1_CODIGO"
    cQuery += " FROM " + RetSQLName("FW1") + " FW1 "
    cQuery += " WHERE "
    cQuery += " FW1.FW1_FILIAL = '" + FwXFilial("FW1") + "' "
    cQuery += " AND FW1.D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery(cQuery)

    cTempAlias := MPSysOpenQuery(cQuery)

    oModel := FwLoadModel("FINA022")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    //Dados Situção de cobrança
    oFRVMod := oModel:GetModel("FRVMASTER")
    oFRVMod:SetValue("FRV_FILIAL", FwXFilial("FRV"))
    oFRVMod:SetValue("FRV_CODIGO", PadR(aCarteira[CMP_FRV_CODIGO],  TamSX3("FRV_CODIGO")[1]))
    oFRVMod:SetValue("FRV_DESCRI", PadR(aCarteira[CMP_FRV_DESCRI],  TamSX3("FRV_DESCRI")[1]))
    oFRVMod:SetValue("FRV_BANCO" , PadR(aCarteira[CMP_FRV_BANCO],   TamSX3("FRV_BANCO")[1]))
    If aCarteira[CMP_FRV_BANCO] == "1"
        oFRVMod:SetValue("FRV_DESCON", PadR(aCarteira[CMP_FRV_DESCON],  TamSX3("FRV_DESCON")[1]))
    EndIf
    oFRVMod:SetValue("FRV_PROTES", PadR(aCarteira[CMP_FRV_PROTES],  TamSX3("FRV_PROTES")[1]))
    oFRVMod:SetValue("FRV_BLQMOV", PadR(aCarteira[CMP_FRV_BLQMOV],  TamSX3("FRV_BLQMOV")[1]))

    //Verifica existência do campo
    If FRV->(FieldPos("FRV_SITPDD")) > 0
        oFRVMod:SetValue("FRV_SITPDD", PadR(aCarteira[CMP_FRV_SITPDD], TamSX3("FRV_SITPDD")[1]))
    EndIf

    (cTempAlias)->(DbGoTop())
    //Dados Bloqueio
    oFW2Mod := oModel:GetModel("FW2DETAIL")
    While (cTempAlias)->(!(EoF()))
        oFW2Mod:SetValue("FW2_FILIAL",  FwXFilial("FW2"))
        oFW2Mod:SetValue("FW2_CODIGO",  PadR((cTempAlias)->FW1_CODIGO, TamSX3("FW2_CODIGO")[1]))
        oFw2Mod:AddLine()
        (cTempAlias)->(DbSkip())
    End

    (cTempAlias)->(DbCloseArea())

    If oModel:VldData()
        oModel:CommitData()
    Else
        VarInfo("", oModel:GetErrorMessage())
        lRet := .F.
    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

Return lRet

/*/{Protheus.doc} FinTGrSA6
Responsavel por gravar o registro na SA6(Bancos).

@type       Static Function
@author     Pedro Castro
@since      26/12/2019
@version    P12.1.27
@param      aBanco, array, array com dados do wizard
@return     Verdadeiro caso o registro seja inserido
/*/
Static Function FinTGrSA6(aBanco As Array) As Logical

    Local cQuery        As Character
    Local cTempAlias    As Character

    Local lRet          As Logical

    lRet        := .T.

    cQuery := " SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON" 
    cQuery += " FROM " + RetSQLName("SA6") + " SA6"
    cQuery += " WHERE SA6.D_E_L_E_T_ = ' '"
    cQuery += " AND SA6.A6_FILIAL = '" + FwXFilial("SA6") + "'"
    cQuery += " AND SA6.A6_COD     = '" + PadR(aBanco[CMP_A6_COD],        TamSX3("A6_COD")[1]) + "'"
    cQuery += " AND SA6.A6_AGENCIA = '" + PadR(aBanco[CMP_A6_AGENCIA],    TamSX3("A6_AGENCIA")[1]) + "'"
    cQuery += " AND SA6.A6_NUMCON  = '" + PadR(aBanco[CMP_A6_NUMCON],     TamSX3("A6_NUMCON")[1]) + "'"

    cQuery := ChangeQuery(cQuery)

    cTempAlias := MPSysOpenQuery(cQuery)

    If !(Empty((cTempAlias)->A6_COD))
        (cTempAlias)->(DbCloseArea())
        Return lRet
    EndIf

    (cTempAlias)->(DbCloseArea())

    RecLock("SA6", .T.)
        SA6->A6_FILIAL  := FwXFilial("SA6")
        SA6->A6_COD     := aBanco[CMP_A6_COD]
        SA6->A6_AGENCIA := aBanco[CMP_A6_AGENCIA]
        SA6->A6_NUMCON  := aBanco[CMP_A6_NUMCON]
        SA6->A6_NOME    := aBanco[CMP_A6_NOME]
        SA6->A6_NREDUZ  := aBanco[CMP_A6_NREDUZ]
        SA6->A6_MOEDA   := aBanco[CMP_A6_MOEDA]
    MsUnLock()

Return lRet

/*/{Protheus.doc} VlCarTech
Reponsavel por verificar se o codigo da situacao de cobrancao ja existe,
caso exista o codigo é trocado automaticamente.

@type       Static Function
@author     Pedro Castro
@since      23/12/2019
@version    P12.1.27
@param      cCarteira, character, código da carteira a ser verificada. parâmetro por referência
@param      cCartAux, character, código da carteira techfin (carteira de devolução não poderá ser igual)
@return     Nil
/*/
Static Function VlCarTech(cCarteira As Character, cCartAux As Character)

    Local cCartParam    As Character
    Local cCodCart      As Character
    Local cQuery        As Character
    Local cTempAlias    As Character

    Local aCarteira     As Array
    
    Local nTamFRVCod    As Numeric

    Default cCarteira   := ""
    Default cCartAux    := ""

    cTempAlias  := GetNextAlias()
    aCarteira   := {}
    cCartParam  := SuperGetMV(IIf(Empty(cCartAux), "MV_CARTECF", "MV_DEVTECF"), .F., "")
    nTamFRVCod  := TamSX3("FRV_CODIGO")[1]
    cCodCart    := Replicate("0", nTamFRVCod)

    cQuery := " SELECT FRV_CODIGO"
    cQuery += " FROM " + RetSQLName("FRV") + " FRV"
    cQuery += " WHERE FRV.D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery(cQuery)

    MPSysOpenQuery(cQuery, cTempAlias)

    (cTempAlias)->(DbGoTop())

    //Situação de Cobrança
    While (cTempAlias)->(!(EoF()))
        AAdd(aCarteira, Upper(AllTrim((cTempalias)->FRV_CODIGO)))
        (cTempAlias)->(DbSkip())
    End

    (cTempAlias)->(DbCloseArea())

    If Len(aCarteira) > 0
        //parâmetro preenchido e carteira existente
        If !(Empty(cCartParam)) .And. AScan(aCarteira, Upper(Alltrim(cCartParam))) > 0
            Return Nil
        EndIf

        //parâmetro preenchido não encontrado na tabela
        IF !(AScan(aCarteira, Upper(Alltrim(cCarteira))) > 0) 
            Return Nil
        EndIf

        cCodCart := SubStr(cCodCart, 1, nTamFRVCod)
        While cCodCart != SubStr(Replicate("Z", nTamFRVCod), 1, nTamFRVCod)
            //garante que a carteira de devolução não será a mesma da carteira techfin
            If !(Empty(cCartAux)) .And. cCodCart == cCartAux
                cCodCart := Soma1(cCodCart)
                Loop
            EndIf

            If AScan(aCarteira, Upper(AllTrim(cCodCart))) > 0
                cCodCart := Soma1(cCodCart)
            Else
                cCarteira := cCodCart
                Exit
            EndIf
        End
    EndIf

Return Nil

/*/{Protheus.doc} VldAlfanum
Verifica se somente letras e numeros foram usados nos campos banco, agencia e conta.

@type       Static Function
@author     Pedro Castro
@since      15/01/2020
@version    P12.1.27
@param      cString Character, string a serem verificados
@return     logical, Verdadeiro caso todos os dados sejam letras ou numeros
/*/
Static Function VldAlfanum(cString As Character) As Logical

    Local cAlfaNum  As Character
    Local lValido   As Logical
    Local nLetra    As Numeric

    Default cString := ""

    cString     := Upper(cString)
    cAlfaNum    := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ "
    lValido     := .T.

    For nLetra := 1 To Len(cString)
        If !(SubStr(cString, nLetra, 1) $ cAlfaNum)
            lValido := .F.
            Help(Nil, Nil, "NOCARACESPEC", "", STR0034, 1,,,,,,,; //"Não é permitido o uso de caracteres especiais."
                {STR0035})  //"Informe somente letras ou números."
            Exit
        EndIf
    Next nLetra

Return lValido

/*/{Protheus.doc} VldCarteTF
Verifica se a carteira é válida para uso.

@type       Static Function
@author     Rafael Riego
@since      08/05/2020
@version    P12.1.27
@param      cCarteira, character, código da carteira
@return     logical, verdadeiro caso a carteira sejá válida
/*/
Static Function VldCarteTF(cCarteira As Character) As Logical

    Local cAliasTmp As Character
    Local cQuery    As Character

    Local lValido   As Logical

    Default cCarteira   := ""

    lValido := .T.

    If Empty(cCarteira)
        Help(Nil, Nil, "CARTECFBRANCO", "", STR0046 , 1,,,,,,,; //"Carteira não pode estar em branco."
            {STR0042}) //"Informe uma Carteira específica para o TOTVS Antecipa." 
        Return .F.
    EndIf

    cQuery := " SELECT FRV_CODIGO"
    cQuery += " FROM " + RetSQLName("FRV") + " FRV"
    cQuery += " WHERE FRV.D_E_L_E_T_ = ' '"
    cQuery += " AND FRV.FRV_CODIGO = '" + cCarteira + "'"

    cQuery := ChangeQuery(cQuery)

    cAliasTmp := MPSysOpenQuery(cQuery)

    If !(Empty((cAliasTmp)->FRV_CODIGO))
        Help(Nil, Nil, "CARTECFEXISTE", "", STR0041 , 1,,,,,,,; // "Carteira já existe no sistema."
            {STR0042}) //"Informe uma Carteira específica para o TOTVS Antecipa."
        lValido = .F.
    EndIf

    (cAliasTmp)->(DbCloseArea())

Return lValido

/*/{Protheus.doc} VldBancoTF
Verifica se os dados bancários são válidos para uso.

@type       Static Function
@author     Rafael Riego
@since      08/05/2020
@version    P12.1.27
@param      aBanco, array, array com os dados do banco. Posições utilizadas para validação: {1=Código; 2=Agência; 3=Num. Conta}
@param      lShowHelp, logical, se verdadeiro mostra msg de erro
@param      lValidGet, logical, se chamada é originada dos gets do wizard
@return     logical, verdadeiro caso os dados bancários sejam válidos
/*/
Static Function VldBancoTF(aBanco As Array, lShowHelp As Logical, lValidGet As Logical) As Logical

    Local cAliasTmp As Character
    Local cQuery    As Character

    Local lValido   As Logical

    Default aBanco      := {}
    Default lShowHelp   := .T.
    Default lValidGet   := .T.

    lValido := .T.

    If Empty(aBanco[CMP_A6_COD]) .Or. Empty(aBanco[CMP_A6_AGENCIA]) .Or. Empty(aBanco[CMP_A6_NUMCON])
        If lValidGet
            Return .T.
        ElseIf lShowHelp
            Help(Nil, Nil, "BCOBRANCO", "", STR0043 , 1,,,,,,,;  //"Banco, Agência e Conta não podem estar em branco."
                {STR0044}) //"Informe um Banco, Agência e Conta específicos para o TOTVS Antecipa."
            Return .F.
        EndIf
    EndIf
    
    cQuery := " SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON"
    cQuery += " FROM " + RetSQLName("SA6") + " SA6"
    cQuery += " WHERE SA6.D_E_L_E_T_ = ' '"
    cQuery += " AND SA6.A6_COD = '"     + PadR(aBanco[CMP_A6_COD],      TamSX3("A6_COD")[1]) + "'"
    cQuery += " AND SA6.A6_AGENCIA = '" + PadR(aBanco[CMP_A6_AGENCIA],  TamSX3("A6_AGENCIA")[1]) + "'"
    cQuery += " AND SA6.A6_NUMCON = '"  + PadR(aBanco[CMP_A6_NUMCON],   TamSX3("A6_NUMCON")[1]) + "'"
    cQuery := ChangeQuery(cQuery)

    cAliasTmp := MPSysOpenQuery(cQuery)

    If !(Empty((cAliasTmp)->A6_COD))
        If lShowHelp
            Help(Nil, Nil, "BCOEXISTE", "", STR0045 , 1,,,,,,,; //"Banco, Agência e Conta já existem no sistema."
                {STR0044 }) //"Informe um Banco, Agência e Conta específicos para o TOTVS Antecipa."
        EndIf
        lValido = .F.
    EndIf
    (cAliasTmp)->(DbCloseArea())

Return lValido

/*/{Protheus.doc} VldMotBx
Verifica se o motivo de baixa é válido para uso.

@type       Static Function
@author     Rafael Riego
@since      08/05/2020
@version    P12.1.27
@param      cCodMotBx, character, código do motivo de baixa
@return     logical, verdadeiro caso o motivo de baixa seja válido
/*/
Static Function VldMotBx(cCodMotBx As Character) As Logical

    Local aMotivoBx As Logical

    Local lValido   As Logical

    Default cCodMotBx   := "   "

    aMotivoBx   := {}
    lValido     := .T.

    If Empty(cCodMotBx)
        lValido := .F.
        Help(Nil, Nil, "MOTBXBRANCO", "", STR0036, 1,,,,,,,; // "Motivo de Baixa não pode estar em branco."
            {STR0037}) //"Informe um motivo de baixo específico para uso do TOTVS Antecipa."
    Else
        aMotivoBx := ReadMotBx()

        If AScan(aMotivoBx, {|codigo| SubStr(codigo, 1, 3) == Upper(cCodMotBx)}) > 0
            lValido := .F.
            Help(Nil, Nil, "MOTBXEXISTE", "", STR0038, 1,,,,,,,; //"Motivo de Baixa já existe."
                {STR0039}) //"Informe um motivo de baixo específico para uso do TOTVS Antecipa."
        EndIf
    EndIf

    FwFreeArray(aMotivoBx)

Return lValido

/*/{Protheus.doc} BuscaMotBx
Verifica se o motivo de baixa informado existe.

@type       Function
@author     Rafael Riego
@since      08/05/2020
@version    P12.1.27
@param      cCodMotBx, character, código do motivo de baixa
@param      aMotivoBx, array, lista dos motivos de baixa existentes no arquivo sigaadv.mot
@return     character, código do motivo de baixa encontrado ou em branco caso não encontrado
/*/
Function BuscaMotBx(cCodMotBx As Character, aMotivoBx As Array) As Character

    Local cMotivo       As Character

    Local lLimpArray    As Logical

    Default cCodMotBx   := ""
    Default aMotivoBx   := {}

    cMotivo     := ""
    lLimpArray  := .F.

    If Empty(cCodMotBx)
        cMotivo := Space(TamSX3("FK1_MOTBX")[1])
    Else
        cMotivo := cCodMotBx
        If Empty(aMotivoBx)
            aMotivoBx := ReadMotBx()
            lLimpArray := .T.
        EndIf

        If !(AScan(aMotivoBx, {|codigo| SubStr(codigo, 1, 3) == Upper(cCodMotBx)}) > 0)
            cMotivo := Space(TamSX3("FK1_MOTBX")[1])
        EndIf
    EndIf

    If lLimpArray
        FwFreeArray(aMotivoBx)
    EndIf

Return cMotivo

/*/{Protheus.doc} FTGrvMotBx
Rotina para criar Motivo de Baixa específico para o TOTVS Antecipa.

@type       Function
@author     Rafael Riego
@since      08/05/2020
@version    P12.1.27
@param      cMotivo, character, código do motivo de baixa
@param      cDescricao, character, descrição do motivo de baixa
@return     logical, verdadeiro caso tenha criado o motivo de baixa com sucesso
/*/
Function FTGrvMotBx(cMotivo As Character, cDescricao As Character) As Logical

    Local aMotivoBx As Array
    
    Local cArquivo 	As Character
    Local cBuffer   As Character
    Local cCfgMotBx As Character

    Local lEspecie  As Logical
    Local lSucesso  As Logical

    Local nHandle	As Numeric
    Local nMotivo   As Numeric
    Local nTamLinha As Numeric

    Default cMotivo     := "ANT"
    Default cDescricao  := "ANTECIPA"

    lEspecie    := .F.
    aMotivoBx   := ReadMotBx(@lEspecie)
    cArquivo    := "SIGAADV.MOT"
    cBuffer     := ""
    cCfgMotBx   := "RNNN"
    lSucesso    := .T.
    nHandle     := 0
    nMotivo     := 0
    nTamLinha   := 19

    If Len(cDescricao) < 10
        cDescricao := PadR(cDescricao, 10)
    EndIf

    If lEspecie
        nTamLinha := 20
        cCfgMotBx := cCfgMotBx + "N"
    EndIf

    If ExistBlock("FILEMOT")
        cArquivo := ExecBlock("FILEMOT", .F., .F., {cArquivo})
    Endif

    If Empty(BuscaMotBx(cMotivo, aMotivoBx))
        nHandle := FOpen(cArquivo, FO_READWRITE)
        If nHandle < 0
            Help(Nil, Nil, "MOTBXNOARQ", "", STR0040, 1,,,,,,, {}) //"Erro ao localizar ou abrir arquivo de motivos de baixa."
            lSucesso := .F.
        Else
            nTamArq := FSeek(nHandle, 0, 2)
            FSeek(nHandle, 0, 0)

            For nMotivo := 0 To nTamArq Step nTamLinha
                cBuffer := Space(nTamLinha)
                FRead(nHandle, @cBuffer, nTamLinha)
            Next nMotivo

            FWrite(nHandle, cMotivo + cDescricao + cCfgMotBx + Chr(13) + Chr(10))
            FClose(nHandle)
        EndIf
    EndIf

Return lSucesso

/*/{Protheus.doc} FTUpdMotBx
Rotina de verificação do preenchimento do motivo de baixa contido no parâmetro MV_MOTTECF ou na chave 'antecipa-motivo-baixa'. 

@type       Static Function
@author     Rafael Riego
@since      05/11/2020
@version    P12.1.27
@param      cCodMotBx, character, código do motivo de baixa a ser verificado
@return     cCodMotBx, código do motivo de baixa encontrado
/*/
Function FTUpdMotBx(cCodMotBx As Character) As Character

    Local oJSON     As J
    Local oTFConfig As J

    oTFConfig := FwTfConfig()

    //Deve gravar pois já está contido no SX6 e não nos parâmetros internos
    If Empty(oTFConfig["fin-antecipa-motivo-baixa"]) .And. !(Empty(cCodMotBx))
        oJSON := JSONObject():New()
        oJSON["fin-antecipa-motivo-baixa"] := cCodMotBx
        FwTFSetConfig(oJSON)
        FwFreeObj(oJSON)
    ElseIf !(Empty(oTFConfig["fin-antecipa-motivo-baixa"])) .And. Empty(cCodMotBx)
        PutMV("MV_MOTTECF", oTFConfig["fin-antecipa-motivo-baixa"])
        cCodMotBx := oTFConfig["fin-antecipa-motivo-baixa"]
    EndIf

    FwFreeObj(oTFConfig)

Return cCodMotBx

/*/{Protheus.doc} ExisteJob
Verifica se o JOB existe no grupo de empresa atual.

@type       Static Function
@author     Rafael Riego
@since      05/11/2020
@version    P12.1.27
@param      cAgendamen, character, código do agendamento
@return     logical, verdadeiro caso encontre o job para empresa desejada
@obs        rotina possui referência direta as tabelas de framework XX1 e XX2 pois não existe função que atenda a este requisito. A issue DFRM1-16827 foi aberta para este propósito
/*/
Static Function ExisteJob() As Logical

    Local lCriado   As Logical

    lCriado := .F.

    If !(ExistFunc("FwOpenXX1"))
        DbSelectArea("XX1")
    Else
        FwOpenXX1()
    EndIf

    If !(ExistFunc("FwOpenXX2"))
        DbSelectArea("XX2")
    Else
        FwOpenXX2()
    EndIf

    aArea := {XX1->(GetArea()), XX2->(GetArea()), GetArea()}

    XX1->(DbSetOrder(1))
    XX2->(DbSetOrder(1))
    XX1->(DbGoTop())

    // Não existe índice por nome da Rotina
    While XX1->(!(EoF()))
        If AllTrim(Upper(XX1->XX1_ROTINA)) == "FINI136O"
            If XX2->(DbSeek(XX1->XX1_CODIGO))
                While XX2->XX2_AGEND == XX1->XX1_CODIGO
                    If cEmpAnt + "/" $ XX2->XX2_EMPFIL
                        lCriado := .T.
                        Exit
                    EndIf
                    XX2->(DbSkip())
                End
            EndIf
        EndIf
        If lCriado
            Exit
        EndIf
        XX1->(DbSkip())
    End

    AEval(aArea, {|area| RestArea(area), FwFreeArray(area)})

Return lCriado
