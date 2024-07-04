#include 'totvs.ch'
#include 'FWMVCDef.ch'
#include 'FINA714.ch'

/*/{Protheus.doc} FINA714
    Cadastro de Esp�cies de Boleto Registrado

    @type function
    @version 12.1.33
    @author alison.kaique
    @since 29/04/2021
/*/
Function FINA714()
    Local oBrowse As Object

    If (AliasInDic("F77"))
        // carga Inicial
        FWMsgRun(, {|| F714Carga() }, STR0005, STR0006) //#"Processando"#"Carga Inicial..."

        // inicialliza o Browse
        oBrowse := BrowseDef()

        // ativa o browse.
        oBrowse:Activate()
    Else
        Help("", 1, "F77", , STR0007, 1,; // #"Tabela F77 n�o dispon�vel."
                    ,,,,,, {STR0008}) // #"Favor atualizar o sistema para que seja criada a tabela F77."
    EndIf
Return

/*/{Protheus.doc} BrowseDef
    Defini��o do Browse

    @type function
    @version 12.1.33
    @author alison.kaique
    @since 29/04/2021
/*/
Static Function BrowseDef()
    Local oBrowse As Object

    oBrowse := FwMBrowse():New()

    oBrowse:SetAlias('F77')
    oBrowse:SetDescripton(STR0001) // #"Especies do Boleto Registrado"
Return oBrowse

/*/{Protheus.doc} MenuDef
    Defini��o das op��es do menu

    @type function
    @version 12.1.33
    @author alison.kaique
    @since 29/04/2021
/*/
Static Function MenuDef()
    Local aRotina As Array

    aRotina := FWMVCMenu('FINA714') // Retorna as op��es padr�es de menu.
Return aRotina

/*/{Protheus.doc} ModelDef
    Defini��o do Modelo de Dados

    @type function
    @version 12.1.33
    @author alison.kaique
    @since 29/04/2021
/*/
Static Function ModelDef()
    Local oStrF77   As Object
    Local oModel    As Object
    Local bPosValid As CodeBlock

    oStrF77   := FWFormStruct(1, 'F77')
    oStrF77:SetProperty( 'F77_BANCO' , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == 03})
    oStrF77:SetProperty( 'F77_ESPECI', MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == 03})

    // bloco de c�digo de valida��o do modelo (TudoOK)
    bPosValid := { |oMdl| MDF77TOK(oMdl) }

    // Cria o objeto do modelo de dados.
    oModel := MPFormModel():New('FINA714', /*bPreValid*/, bPosValid, /*bCommitPos*/, /*bCancel*/)

    // Adiciona a descri��o do modelo de dados.
    oModel:SetDescription(STR0001) // #"Especies do Boleto Registrado"

    // Adiciona ao modelo um componente de formul�rio.
    oModel:AddFields('F77MASTER', /*cOwner*/, oStrF77, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
    oModel:GetModel('F77MASTER'):SetDescription(STR0001) // #"Especies do Boleto Registrado"

    // Configura chave prim�ria.
    oModel:SetPrimaryKey({"F77_FILIAL", "F77_BANCO", "F77_ESPECI"})

// Retorna o Modelo de dados.
Return oModel

/*/{Protheus.doc} ViewDef
    Defini��o da Vis�o de Dados

    @type function
    @version 12.1.33
    @author alison.kaique
    @since 29/04/2021
/*/
Static Function ViewDef()
    Local oModel  As Object
    Local oStrF77 As Object
    Local oView   As Object

    oModel  := FWLoadModel('FINA714')
    oStrF77 := FWFormStruct(2, 'F77')
    oView   := FWFormView():New()

    // Define qual Modelo de dados ser� utilizado
    oView:SetModel(oModel)

    // Define que a view ser� fechada ap�s a grava��o dos dados no OK.
    oView:bCloseOnOk := {|| .T.}

    // Adiciona no nosso view um controle do tipo formul�rio (antiga enchoice).
    oView:AddField('VIEW_F77', oStrF77, 'F77MASTER')

    // Cria um "box" horizontal para receber cada elemento da view.
    oView:CreateHorizontalBox('SCREEN', 100)

    // Relaciona o identificador (ID) da view com o "box" para exibi��o.
    oView:SetOwnerView('VIEW_F77', 'SCREEN')

// Retorna a View de dados.
Return oView

/*/{Protheus.doc} MDF77TOK
    Valida��o de TudoOK do Modelo

    @type function
    @version 12.1.33
    @author alison.kaique
    @since 29/04/2021
/*/
Static Function MDF77TOK(oMdl)
    Local lRet    As Logical
    Local oMdlF77 As Object
    Local nOper   As Numeric
    Local cBanco  As Character
    Local cEspeci As Character

    lRet    := .T.
    oMdlF77 := oMdl:GetModel("F77MASTER")
    nOper   := oMdl:GetOperation()

    //Valida��o de Inclus�o
    If (nOper == MODEL_OPERATION_INSERT)
        cBanco  := oMdlF77:GetValue('F77_BANCO')
        cEspeci := oMdlF77:GetValue('F77_ESPECI')

        // valida se o registro j� existe
        F77->(DbSetOrder(01)) //  F77_FILIAL + F77_BANCO + F77_ESPECI
        If (F77->(MsSeek(FwxFilial('F77') + cBanco + cEspeci)))
            Help("", 1, "F77_ESPECI", , STR0002 + cEspeci + STR0003 + cBanco, 1,; // #"Esp�cie "#" j� cadastrada para o Banco "
                    ,,,,,, {STR0004}) // #"Informe esp�cie ainda n�o cadastrada."
            lRet := .F.
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} F714Carga
    Carga Inicial de Dados

    @type function
    @version 12.1.33
    @author alison.kaique
    @since 03/05/2021
/*/
Function F714Carga()
    Local aDados     As Array // dados a serem carregados
    Local nI         As Numeric // controle do FOR
    Local nTamBanco  As Numeric // tamanho do campo F77_BANCO
    Local nTamEspeci As Numeric // tamanho do campo F77_ESPECI
    Local nTamDescri As Numeric // tamanho do campo F77_DESCRI
    Local nTamSigla  As Numeric // tamanho do campo F77_SIGLA
    Local oModel     As Object // modelo de Dados
    Local cError     As Character // log de erro

    aDados     := {}
    nTamBanco  := TamSX3('F77_BANCO')[01]
    nTamEspeci := TamSX3('F77_ESPECI')[01]
    nTamDescri := TamSX3('F77_DESCRI')[01]
    nTamSigla  := TamSX3('F77_SIGLA')[01]
    cError     := ""

    // Banco do Brasil
    AAdd(aDados, {'001', '1', 'CHEQUE', 'CH'})
    AAdd(aDados, {'001', '2', 'DUPLICATA MERCANTIL', 'DM'})
    AAdd(aDados, {'001', '3', 'DUPLICATA MTIL POR INDICACAO', 'DMI'})
    AAdd(aDados, {'001', '4', 'DUPLICATA DE SERVICO', 'DS'})
    AAdd(aDados, {'001', '5', 'DUPLICATA DE SRVC P/INDICACAO', 'DSI'})
    AAdd(aDados, {'001', '6', 'DUPLICATA RURAL', 'DR'})
    AAdd(aDados, {'001', '7', 'LETRA DE CAMBIO', 'LC'})
    AAdd(aDados, {'001', '8', 'NOTA DE CREDITO COMERCIAL', 'NCC'})
    AAdd(aDados, {'001', '9', 'NOTA DE CREDITO A EXPORTACAO', 'NCE'})
    AAdd(aDados, {'001', '10', 'NOTA DE CREDITO INDUSTRIAL', 'NCI'})
    AAdd(aDados, {'001', '11', 'NOTA DE CREDITO RURAL', 'NCR'})
    AAdd(aDados, {'001', '12', 'NOTA PROMISSORIA', 'NP'})
    AAdd(aDados, {'001', '13', 'NOTA PROMISSORIA RURAL', 'NPR'})
    AAdd(aDados, {'001', '14', 'TRIPLICATA MERCANTIL', 'TM'})
    AAdd(aDados, {'001', '15', 'TRIPLICATA DE SERVICO', 'TS'})
    AAdd(aDados, {'001', '16', 'NOTA DE SEGURO', 'NS'})
    AAdd(aDados, {'001', '17', 'RECIBO', 'RC'})
    AAdd(aDados, {'001', '18', 'FATURA', 'FAT'})
    AAdd(aDados, {'001', '19', 'NOTA DE DEBITO', 'ND'})
    AAdd(aDados, {'001', '20', 'APOLICE DE SEGURO', 'AS'})
    AAdd(aDados, {'001', '21', 'MENSALIDADE ESCOLAR', 'ME'})
    AAdd(aDados, {'001', '22', 'PARCELA DE CONSORCIO', 'PC'})
    AAdd(aDados, {'001', '23', 'DIVIDA ATIVA DA UNIAO', 'DAU'})
    AAdd(aDados, {'001', '24', 'DIVIDA ATIVA DE ESTADO', 'DAE'})
    AAdd(aDados, {'001', '25', 'DIVIDA ATIVA DE MUNICIPIO', 'DAM'})
    AAdd(aDados, {'001', '31', 'CARTAO DE CREDITO', 'CC'})
    AAdd(aDados, {'001', '32', 'BOLETO PROPOSTA', 'BP'})
    AAdd(aDados, {'001', '99', 'OUTROS', 'OU'})

    // Ita�
    AAdd(aDados, {'341', '01', 'DUPLICATA MERCANTIL', 'DM'})
    AAdd(aDados, {'341', '02', 'NOTA PROMISS�RIA', 'NP'})
    AAdd(aDados, {'341', '03', 'NOTA DE SEGURO', 'NS'})
    AAdd(aDados, {'341', '04', 'MENSALIDADE ESCOLAR', 'ME'})
    AAdd(aDados, {'341', '05', 'RECIBO', 'RC'})
    AAdd(aDados, {'341', '06', 'CONTRATO', 'CT'})
    AAdd(aDados, {'341', '07', 'COSSEGUROS', 'COSS'})
    AAdd(aDados, {'341', '08', 'DUPLICATA DE SERVI�O', 'DS'})
    AAdd(aDados, {'341', '09', 'LETRA DE C�MBIO', 'LC'})
    AAdd(aDados, {'341', '13', 'NOTA DE D�BITOS', 'ND'})
    AAdd(aDados, {'341', '15', 'DOCUMENTO DE D�VIDA', 'DD'})
    AAdd(aDados, {'341', '16', 'ENCARGOS CONDOMINIAIS', 'EC'})
    AAdd(aDados, {'341', '17', 'PRESTA��O DE SERVI�OS', 'PS'})
    AAdd(aDados, {'341', '18', 'BOLETO DE PROPOSTA', 'BP'})
    AAdd(aDados, {'341', '99', 'DIVERSOS', 'DV'})

    // Caixa
    AAdd(aDados, {'104', '01', 'CHEQUE', 'CH'})
    AAdd(aDados, {'104', '02', 'DUPLICATA MERCANTIL', 'DM'})
    AAdd(aDados, {'104', '03', 'DUPLICATA MERCANTIL P/ INDICA��O', 'DMI'})
    AAdd(aDados, {'104', '04', 'DUPLICATA DE SERVI�O', 'DS'})
    AAdd(aDados, {'104', '05', 'DUPLICATA DE SERVI�O P/ INDICA��O', 'DSI'})
    AAdd(aDados, {'104', '06', 'DUPLICATA RURAL', 'DR'})
    AAdd(aDados, {'104', '07', 'LETRA DE C�MBIO', 'LC'})
    AAdd(aDados, {'104', '08', 'NOTA DE CR�DITO COMERCIAL', 'NCC'})
    AAdd(aDados, {'104', '09', 'NOTA DE CR�DITO � EXPORTA��O', 'NCE'})
    AAdd(aDados, {'104', '10', 'NOTA DE CR�DITO INDUSTRIAL', 'NCI'})
    AAdd(aDados, {'104', '11', 'NOTA DE CR�DITO RURAL', 'NCR'})
    AAdd(aDados, {'104', '12', 'NOTA PROMISS�RIA', 'NP'})
    AAdd(aDados, {'104', '13', 'NOTA PROMISS�RIA RURAL', 'NPR'})
    AAdd(aDados, {'104', '14', 'TRIPLICATA MERCANTIL', 'TM'})
    AAdd(aDados, {'104', '15', 'TRIPLICATA DE SERVI�O', 'TS'})
    AAdd(aDados, {'104', '16', 'NOTA DE SEGURO', 'NS'})
    AAdd(aDados, {'104', '17', 'RECIBO', 'RC'})
    AAdd(aDados, {'104', '18', 'FATURA', 'FAT'})
    AAdd(aDados, {'104', '19', 'NOTA DE D�BITO', 'ND'})
    AAdd(aDados, {'104', '20', 'AP�LICE DE SEGURO', 'AP'})
    AAdd(aDados, {'104', '21', 'MENSALIDADE ESCOLAR', 'ME'})
    AAdd(aDados, {'104', '22', 'PARCELA DE CONS�RCIO', 'PC'})
    AAdd(aDados, {'104', '23', 'NOTA FISCAL', 'NF'})
    AAdd(aDados, {'104', '24', 'DOCUMENTO DE D�VIDA', 'DD'})
    AAdd(aDados, {'104', '25', 'C�DULA DE PRODUTO RURAL', 'CPR'})
    AAdd(aDados, {'104', '31', 'CART�O DE CR�DITO', 'CC'})
    AAdd(aDados, {'104', '32', 'BOLETO DE PROPOSTA', 'BP'})
    AAdd(aDados, {'104', '99', 'OUTROS', 'OU'})

    // Bradesco
    AAdd(aDados, {'237', '01', 'CHEQUE', 'CH'})
    AAdd(aDados, {'237', '02', 'DUPLICATA DE VENDA MERCANTIL', 'DM'})
    AAdd(aDados, {'237', '03', 'DUPLICATA MERCANTIL POR INDICACAO', 'DMI'})
    AAdd(aDados, {'237', '04', 'DUPLICATA DE PRESTACAO DE SERVICOS', 'DS'})
    AAdd(aDados, {'237', '05', 'DUPLICATA PREST. SERVICOS POR INDICACAO', 'DSI'})
    AAdd(aDados, {'237', '06', 'DUPLICATA RURAL', 'DR'})
    AAdd(aDados, {'237', '07', 'LETRA DE C�MBIO', 'LC'})
    AAdd(aDados, {'237', '08', 'NOTA DE CR�DITO COMERCIAL', 'NCC'})
    AAdd(aDados, {'237', '09', 'NOTA DE CREDITO EXPORTACAO', 'NCE'})
    AAdd(aDados, {'237', '10', 'NOTA DE CR�DITO INDUSTRIAL', 'NCI'})
    AAdd(aDados, {'237', '11', 'NOTA DE CR�DITO RURAL', 'NCR'})
    AAdd(aDados, {'237', '12', 'NOTA PROMISS�RIA', 'NP'})
    AAdd(aDados, {'237', '13', 'NOTA PROMISS�RIA RURAL', 'NPR'})
    AAdd(aDados, {'237', '14', 'TRIPLICATA DE VENDA MERCANTIL', 'TM'})
    AAdd(aDados, {'237', '15', 'TRIPLICATA DE PRESTACAO DE SERVICOS', 'TS'})
    AAdd(aDados, {'237', '16', 'NOTA DE SERVICO', 'NS'})
    AAdd(aDados, {'237', '17', 'RECIBO', 'RC'})
    AAdd(aDados, {'237', '18', 'FATURA', 'FAT'})
    AAdd(aDados, {'237', '19', 'NOTA DE D�BITO', 'ND'})
    AAdd(aDados, {'237', '20', 'AP�LICE DE SEGURO', 'AP'})
    AAdd(aDados, {'237', '21', 'MENSALIDADE ESCOLAR', 'ME'})
    AAdd(aDados, {'237', '22', 'PARCELA DE CONS�RCIO', 'PC'})
    AAdd(aDados, {'237', '23', 'DOCUMENTO DE D�VIDA', 'DD'})
    AAdd(aDados, {'237', '24', 'CEDULA DE CREDITO BANCARIO', 'CCB'})
    AAdd(aDados, {'237', '25', 'FINANCIAMENTO', 'FI'})
    AAdd(aDados, {'237', '26', 'RATEIO DE DESPESAS', 'RD'})
    AAdd(aDados, {'237', '27', 'DUPLICATA RURAL INDICACAO', 'DRI'})
    AAdd(aDados, {'237', '28', 'ENCARGOS CONDOMINIAIS', 'EC'})
    AAdd(aDados, {'237', '29', 'ENCARGOS CONDOMINIAIS POR INDICACAO', 'ECI'})
    AAdd(aDados, {'237', '31', 'CARTAO DE CREDITO', 'CC'})
    AAdd(aDados, {'237', '32', 'BOLETO DE PROPOSTA', 'BDP'})
    AAdd(aDados, {'237', '99', 'OUTROS', 'OUT'})

    // Banco Santander
    AAdd(aDados, {'033', '02', 'DUPLICATA MERCANTIL', 'DM'})
    AAdd(aDados, {'033', '04', 'DUPLICATA DE SERVICO', 'DS'})
    AAdd(aDados, {'033', '12', 'NOTA PROMISSORIA', 'NP'})
    AAdd(aDados, {'033', '13', 'NOTA PROMISSORIA RURAL', 'NR'})
    AAdd(aDados, {'033', '17', 'RECIBO', 'RC'})
    AAdd(aDados, {'033', '20', 'APOLICE DE SEGURO', 'AP'})
    AAdd(aDados, {'033', '31', 'CARTAO DE CREDITO', 'BCC'})
    AAdd(aDados, {'033', '32', 'BOLETO PROPOSTA', 'BDP'})
    AAdd(aDados, {'033', '97', 'CHEQUE', 'CH'})
    AAdd(aDados, {'033', '98', 'NOTA PROMISS�RIA DIRETA', 'ND'})
    AAdd(aDados, {'033', '99', 'OUTROS', 'OUT'})

    F77->(DbSetOrder(01)) // F77_FILIAL + F77_BANCO + F77_ESPECI

    For nI := 01 To Len(aDados)
        //verifica se o registro existe
        If !(F77->(DbSeek(FwxFilial('F77') + PadR(aDados[nI, 01], nTamBanco) + PadR(aDados[nI, 02], nTamEspeci))))
        // instanciando o modelo de dados
        oModel := FWLoadModel('FINA714')
        // definindo a opera��o
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        // ativando o modelo
        oModel:Activate()

        // preenchendo os campos com seus respectivos valores
        oModel:SetValue("F77MASTER", "F77_BANCO" , aDados[nI, 01])
        oModel:SetValue("F77MASTER", "F77_ESPECI", aDados[nI, 02])
        oModel:SetValue("F77MASTER", "F77_DESCRI", Left(aDados[nI, 03], nTamDescri))
        oModel:SetValue("F77MASTER", "F77_SIGLA", Left(aDados[nI, 04], nTamSigla))

        // validando dados
        If (oModel:VldData())
            // gravando dados
            oModel:CommitData()
        Else
            // gravando erro
            cError += STR0009 + aDados[nI, 02] + STR0010 + aDados[nI, 01] + CRLF // #"Erro na inclus�o da esp�cie: "#" para o banco: "
            cError += cValToChar(oModel:GetErrorMessage()[4]) + ' - '
            cError += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
            cError += cValToChar(oModel:GetErrorMessage()[6])
            cError += Replicate('_', 10) + CRLF
        EndIf

        // desativando o Modelo
        oModel:DeActivate()
        EndIf
    Next nI

    // mostra o error log
        If !(Empty(cError))
            Help( , , "F714CARGA", , cError, 1, 0 )
        EndIf

    FreeObj(oModel)
    oModel := Nil
Return
