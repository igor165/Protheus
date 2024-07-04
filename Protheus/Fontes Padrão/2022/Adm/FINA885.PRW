#Include "FINA885.ch"
#Include 'TOTVS.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} FINA885
Cadastro das chaves PIX -  FOR
@author R. Melo
@since 10/10/2020
@version 1.0
@return Nil, função não tem retorno
@example
u_FINA885()
/*/
Function FINA885()

    Local oBrowse As Object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F72") //"F72"
    oBrowse:SetDescription(STR0002) //"Chaves PIX"
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Criação do menu MVC
@author R. Melo
@since 10/10/2020
@version 1.0
@return Nil, função não tem retorno
/*/
Static Function MenuDef() As Array
    Local aRot As Array

    aRot := {}
    //Adicionando opções
    ADD OPTION aRot TITLE STR0003    ACTION 'VIEWDEF.FINA885' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE STR0004    ACTION 'VIEWDEF.FINA885' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE STR0005    ACTION 'VIEWDEF.FINA885' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE STR0006    ACTION 'VIEWDEF.FINA885' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*/{Protheus.doc} MenuDef
Criação do modelo de dados MVC
@author R. Melo
@since 10/10/2020
@version 1.0
@return Nil, função não tem retorno
/*/
Static Function ModelDef() As Object
    Local oModel   As Object
    Local oStTmp   As Object
    Local oStFilho As Object
    Local bVldPos  As Block
    Local bVldCom  As Block
    Local aF72Rel  As Array

    oModel   := Nil
    oStTmp   := FWFormModelStruct():New()
    oStFilho := FWFormStruct(1, 'F72')
    bVldPos  := {|| VldF72Tab()}
    bVldCom  := {|| SaveF72()}
    aF72Rel  := {}

    //Adiciona a tabela na estrutura temporária
    oStTmp:AddTable('F72', {'F72_FILIAL', 'F72_COD', 'F72_LOJA', 'F72_NOME'}, "Cabecalho F72")

    //Adiciona o campo de Filial
    oStTmp:AddField(;
        RetTitle("F72_FILIAL"),;                                                                    // [01]  C   Titulo do campo
        RetTitle("F72_FILIAL"),;                                                                    // [02]  C   ToolTip do campo
        "F72_FILIAL",;                                                                              // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSX3("F72_FILIAL")[1],;                                                                   // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,F72->F72_FILIAL,FWxFilial('F72'))" ),;   // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    //Adiciona o campo de Código do Fornecedor
    oStTmp:AddField(;
        RetTitle("F72_COD"),;                                                        // [01]  C   Titulo do campo
        RetTitle("F72_COD"),;                                                        // [02]  C   ToolTip do campo
        "F72_COD",;                                                                  // [03]  C   Id do Field
        "C",;                                                                        // [04]  C   Tipo do campo
        TamSX3("F72_COD")[1],;                                                       // [05]  N   Tamanho do campo
        0,;                                                                          // [06]  N   Decimal do campo
        Nil,;                                                                        // [07]  B   Code-block de validação do campo
        Nil,;                                                                        // [08]  B   Code-block de validação When do campo
        {},;                                                                         // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                        // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(INCLUI,SA2->A2_COD,F72->F72_COD)" ),;   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                          // [14]  L   Indica se o campo é virtual

    //Adiciona o campo de Agência
    oStTmp:AddField(;
        RetTitle("F72_LOJA"),;                                                       // [01]  C   Titulo do campo
        RetTitle("F72_LOJA"),;                                                       // [02]  C   ToolTip do campo
        "F72_LOJA",;                                                                 // [03]  C   Id do Field
        "C",;                                                                        // [04]  C   Tipo do campo
        TamSX3("F72_LOJA")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                          // [06]  N   Decimal do campo
        Nil,;                                                                        // [07]  B   Code-block de validação do campo
        Nil,;                                                                        // [08]  B   Code-block de validação When do campo
        {},;                                                                         // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                        // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(INCLUI,SA2->A2_LOJA,F72->F72_LOJA)" ),;   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                          // [14]  L   Indica se o campo é virtual

        //Adiciona o campo de DV Aência
    oStTmp:AddField(;
        RetTitle("F72_NOME"),;                                                       // [01]  C   Titulo do campo
        RetTitle("F72_NOME"),;                                                       // [02]  C   ToolTip do campo
        "F72_NOME",;                                                                 // [03]  C   Id do Field
        "C",;                                                                        // [04]  C   Tipo do campo
        TamSX3("F72_NOME")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                          // [06]  N   Decimal do campo
        Nil,;                                                                        // [07]  B   Code-block de validação do campo
        Nil,;                                                                        // [08]  B   Code-block de validação When do campo
        {},;                                                                         // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                        // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(INCLUI,SA2->A2_NOME,F72->F72_NOME)" ),;   // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)

    //Setando as propriedades na grid, o inicializador, para não dar mensagem de coluna vazia
    oStFilho:SetProperty('F72_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    oStFilho:SetProperty('F72_COD'   , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    oStFilho:SetProperty('F72_LOJA'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    oStFilho:SetProperty('F72_NOME'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))

    //Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel := MPFormModel():New("FINA885M", , bVldPos, bVldCom)
    oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
    oModel:AddGrid('FORDETAIL','FORMCAB',oStFilho)
    //oModel:LModify := .T.

    //Adiciona o relacionamento de Filho, Pai
    aAdd(aF72Rel, {'F72_FILIAL', 'Iif(!INCLUI, F72->F72_FILIAL, FWxFilial("F72"))'} )
    aAdd(aF72Rel, {'F72_COD'   , 'Iif(!INCLUI, F72->F72_COD,  "")'} )
    aAdd(aF72Rel, {'F72_LOJA'  , 'Iif(!INCLUI, F72->F72_LOJA,  "")'} )
    aAdd(aF72Rel, {'F72_NOME'  , 'Iif(!INCLUI, F72->F72_NOME,  "")'} )

    //Criando o relacionamento
    oModel:SetRelation('FORDETAIL', aF72Rel, F72->(IndexKey(1)))

    //Setando o campo único da grid para não ter repetição
    oModel:GetModel('FORDETAIL'):SetUniqueLine({"F72_CHVPIX"})
    oModel:GetModel('FORDETAIL'):SetLPost({|| VldPosGrid(1)})
    oModel:GetModel('FORDETAIL'):SetUseOldGrid(.T.)
    oModel:GetModel('FORDETAIL'):SetDelAllLine(.T.)
    //Setando outras informações do Modelo de Dados
    oModel:SetDescription(STR0002)
    oModel:SetPrimaryKey({})
    oModel:GetModel("FORMCAB"):SetDescription(STR0002)

Return oModel

/*/{Protheus.doc} MenuDef
Criação da visão MVC
@author R. Melo
@since 10/10/2020
@version 1.0
@return Nil, função não tem retorno
/*/
Static Function ViewDef() As Object
    Local nOpc       As Numeric
    Local oModel     As Object
    Local oStTmp     As Object
    Local oStFilho   As Object
    Local oView      As Object

    oModel     := FWLoadModel("FINA885")
    nOpc       := oModel:GetOperation()
    oStTmp     := FWFormViewStruct():New()
    oStFilho   := FWFormStruct(2, 'F72')
    oView      := Nil

    //Adicionando o campo Chave para ser exibido
    oStTmp:AddField(;
        "F72_COD",;                 // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        RetTitle("F72_COD"),;       // [03]  C   Titulo do campo
        X3Descric('F72_COD'),;      // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("F72_COD"),;      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,; //Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "F72_LOJA",;                // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        RetTitle("F72_LOJA"),;      // [03]  C   Titulo do campo
        X3Descric('F72_LOJA'),;     // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("F72_LOJA"),;     // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStTmp:AddField(;
        "F72_NOME",;                // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        RetTitle("F72_NOME"),;      // [03]  C   Titulo do campo
        X3Descric('F72_NOME'),;     // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("F72_NOME"),;     // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
    oView:AddGrid('VIEW_FOR',oStFilho,'FORDETAIL')

    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',20)
    oView:CreateHorizontalBox('GRID',80)

    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_CAB','CABEC')
    oView:SetOwnerView('VIEW_FOR','GRID')

    //Habilitando título
    oView:EnableTitleView('VIEW_CAB','Fornecedor')
    oView:EnableTitleView('VIEW_FOR','Chaves Pix')

    //Tratativa padrão para fechar a tela
    oView:SetCloseOnOk({||.T.})

    //Remove os campos de Filial e Tabela da Grid
    oStFilho:RemoveField('F72_FILIAL')
    oStFilho:RemoveField('F72_COD')
    oStFilho:RemoveField('F72_LOJA')
    oStFilho:RemoveField('F72_NOME')

Return oView
/*/{Protheus.doc} VldF72Tab
função chamada na validação do botão Confirmar, para verificar se já existe a tabela digitada
@type function
@author R. Melo
@since 14/01/2017
@version 1.0
    @return lRet, .T. se pode prosseguir e .F. se deve barrar
/*/
Static Function VldF72Tab()
    Local oModelDad  As Object
    Local lRet       As Logical

    oModelDad  := FWModelActive()
    lRet:= .T.

    //Modifico qualquer conteúdo do cabeçalho para não dar errorlog de campos não alterados
    oModelDad:SetValue("FORMCAB", "F72_COD" , "*")
    oModelDad:SetValue("FORMCAB", "F72_LOJA" , "*")
    oModelDad:SetValue("FORMCAB", "F72_NOME" , "*")

    //Salvo os dados do Fornecedor em seus respectivos campos da
    oModelDad:SetValue("FORMCAB", "F72_FILIAL", xFilial("F72"))
    oModelDad:SetValue("FORMCAB", "F72_COD"   , SA2->A2_COD)
    oModelDad:SetValue("FORMCAB", "F72_LOJA"  , SA2->A2_LOJA)
    oModelDad:SetValue("FORMCAB", "F72_NOME"  , SA2->A2_NOME)

    lRet := VldPosGrid()

Return  lRet
/*/{Protheus.doc} SaveF72
função desenvolvida para salvar os dados
@type function
@author R. Melo
@since 14/01/2017
@version 1.0
/*/
Static Function SaveF72() As Logical
    Local aArea      As Array
    Local aSaveLines As Array
    Local cActive    As Character
    Local cChave     As Character
    Local cCodigo    As Character
    Local cFilF72    As Character
    Local cLoja      As Character
    Local cNomeFor   As Character
    Local nAtual     As Numeric
    Local lRet       As Logical
    Local oModelDad  As Object
    Local oModelGrid As Object

    aArea      := GetArea()
    lRet       := .T.
    oModelDad  := FWModelActive()
    cFilF72    := oModelDad:GetValue('FORMCAB', 'F72_FILIAL')
    cCodigo    := oModelDad:GetValue('FORMCAB', 'F72_COD')
    cLoja      := oModelDad:GetValue('FORMCAB', 'F72_LOJA')
    cNomeFor   := oModelDad:GetValue('FORMCAB', 'F72_NOME')
    oModelGrid := oModelDad:GetModel('FORDETAIL')
    aSaveLines := FWSaveRows()

    nAtual     := 0

    DbSelectArea('F72')
    DbSetOrder(1) //F72_FILIAL + F72_COD + F72_LOJA + F72_TPCHV

    For nAtual := 1 To oModelGrid:Length()
        oModelGrid:GoLine(nAtual)
        nRecno   := oModelGrid:GetDataId(nAtual)
        If !oModelGrid:IsDeleted()

            cChave   := oModelGrid:GetValue('F72_CHVPIX')
            cTpChvAtu:= oModelGrid:GetValue('F72_TPCHV')
            cActive  := oModelGrid:GetValue('F72_ACTIVE')

            If nRecno > 0
                DbGoTo(nRecno)
                RecLock('F72', .F.)
                    DbDelete()
                MsUnlock()
            EndIf
            //Se a linha não estiver excluída, inclui o registro
            RecLock('F72', .T.)
                F72->F72_FILIAL  := cFilF72
                F72->F72_COD     := cCodigo
                F72->F72_LOJA    := cLoja
                F72->F72_NOME    := cNomeFor
                F72->F72_TPCHV 	 := cTpChvAtu
                F72->F72_CHVPIX  := cChave
                F72->F72_ACTIVE  := cActive
            MsUnlock()
        Else
            If nRecno > 0
                DbGoTo(nRecno)
                RecLock('F72', .F.)
                    DbDelete()
                MsUnlock()
            EndIf
        EndIf
    Next
    FWRestRows(aSaveLines)
    RestArea(aArea)
Return lRet


/*/{Protheus.doc} VldPosGrid
função desenvolvida validar linha da grid
@type function
@author R. Melo
@since 14/01/2017
@version 1.0
/*/
Static Function VldPosGrid(nTipo As Numeric) As Logical

    Local aSaveLines    As Array

    Local cActive       As Character
    Local cChave        As Character
    Local cDescTp       As Character
    Local cNumbPhone    As Character
    Local cTpChave      As Character
    Local cTpChvAtu     As character

    Local lRet          As Logical

    Local nContTpChv    As Numeric
    Local nCntActive    As Numeric
    Local nNum          As Numeric
    Local nTotNum       As Numeric
    Local nLinhaAtu     As Numeric
    Local nRecno        As Numeric
    Local nLenChave     As Numeric

    Local oModelDad     As Object
    Local oModelGrid    As Object

    Default nTipo := 2

    nLinhaAtu   := 0
    lRet        := .T.
    oModelDad   := FwModelActive()
    oModelGrid  := oModelDad:GetModel("FORDETAIL")
    cChave      := ""
    cTpChave    := ""
    nContTpChv  := 0
    cDescTp     := ""
    cNumbPhone  := ("0/1/2/3/4/5/6/7/8/9")
    nNum        := 0
    nTotNum     := 0
    nCntActive  := 0

    aSaveLines  := FwSaveRows()

    DbSelectArea("F72")
    F72->(DbSetOrder(1)) //F72_FILIAL + F72_COD + F72_LOJA + F72_TPCHV

    cTpChave    := oModelGrid:GetValue("F72_TPCHV")
    cActive     := oModelGrid:GetValue("F72_ACTIVE")

    If !oModelGrid:IsDeleted() .And. nTipo == 1 // Só valida no Line Post
        lRet := ValidaCGC(SA2->A2_CGC, SA2->A2_TIPO, oModelGrid:GetValue("F72_CHVPIX"), oModelGrid:GetDataId(), @oModelDad)
    EndIf

    If lRet
        For nLinhaAtu := 1 To oModelGrid:Length()
            oModelGrid:GoLine(nLinhaAtu)
            If !(oModelGrid:IsDeleted())
                cTpChvAtu   := oModelGrid:GetValue("F72_TPCHV")
                cActive     := oModelGrid:GetValue("F72_ACTIVE")
                cChave      := oModelGrid:GetValue("F72_CHVPIX")
                nRecno      := oModelGrid:GetDataId()

                If nTipo == 2 // Só valida no Grid Post
                    lRet := ValidaCGC(SA2->A2_CGC, SA2->A2_TIPO, cChave, nRecno, @oModelDad)
                EndIf

                If lRet
                    //Exclui o tipo 04 - Chave Aleatória da verificação
                    If Empty(cActive)
                        lRet := .F.
                        oModelDad:SetErrorMessage("FINA885M", Nil, "FINA885M", Nil, Nil, STR0019, Nil, Nil, Nil)
                    ElseIf cActive == "1"
                        nCntActive++
                    EndIf
                EndIf

                If lRet
                    //Valida se possui mais de uma chave CPF/CNPJ
                    If cTpChvAtu == cTpChave .And. cTpChvAtu == "03"
                        nContTpChv++
                    EndIf

                    //Caso já exista mais de um tipo de chave 'CPF/CNPJ' o processo de inclusão da linha é barrado
                    If nContTpChv > 1
                        If cTpChvAtu == "03"
                            cDescTp := STR0018
                        EndIf
                        oModelDad:SetErrorMessage("FINA885M",, "FINA885M",,, STR0010 + cDescTp + STR0009) //"' só pode ser cadastrada uma única vez por Fornecedor + Ag + Conta."
                        lRet := .F.
                    EndIf
                EndIf

                If lRet
                    cChave    := AllTrim(cChave)
                    nLenChave := Len(cChave)
                    If cTpChvAtu == "01"
                        If (lRet := SubStr(cChave, 1, 1) == "+")
                            nTotNum := 0
                            For nNum := 2 To nLenChave
                                If !(SubStr(cChave, nNum, 1) $ cNumbPhone)
                                    lRet := .F.
                                    Exit
                                Else
                                    nTotNum++
                                EndIf
                            Next nNum

                            If lRet
                                lRet := nTotNum == 13
                            EndIf
                        EndIf

                        If !lRet
                            oModelDad:SetErrorMessage("FINA885M",, "FINA885M",,, STR0013, STR0014)  // "Telefone inválido!"  "Ex: +551199998888" 
                        EndIf
                    ElseIf cTpChvAtu == "02"
                        If !IsEmail(cChave)
                            oModelDad:SetErrorMessage("FINA885M",, "FINA885M",,, STR0015, STR0016) // "E-mail inválido!"  "aaa@bbb.com"
                            lRet := .F.
                        EndIf
                    ElseIf cTpChvAtu == "03"
                        If !(nLenChave == 11 .Or. nLenChave == 14)
                            lRet := .F.
                            oModelDad:SetErrorMessage("FINA885M",, "FINA885M",,, STR0028) // "CPF/CNPJ inválido!"
                        ElseIf !(CGC(cChave,, .F.))
                            lRet := .F.
                            oModelDad:SetErrorMessage("FINA885M",, "FINA885M",,, STR0017, STR0024) // "CPF/CNPJ inválido!"
                        EndIf
                    ElseIf cTpChvAtu == "04"
                        If nLenChave <> 36
                            oModelDad:SetErrorMessage("FINA885M",, "FINA885M",,, STR0011, STR0012) //"Chave Aleatória inválida!"
                            lRet := .F.
                        EndIf
                    EndIf
                EndIf
            EndIf
        Next nLinhaAtu
    EndIf

    If nCntActive > 1
        oModelDad:SetErrorMessage("FINA885M",, "FINA885M",,, STR0008) //"Apenas 1 chave PIX pode estar ativa."
        lRet := .F.
    EndIf

    FwRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FA885ChPix()
Chaves PIX Fornecedor
Função chamada pelo MATA020
@author  Robson Melo
@since   15/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function FA885ChPix() As Logical

	Local oModelM   As Object
	Local nOperacao As Numeric
	Local aArea     As Array
	Local lOk       As Logical
	Local cOperacao As String
	Local nEnt      As Numeric
	Local cComp     As Character
	Local cTab      As Character
	Local cTabAux   As Character


	oModelM:= FWLoadModel("FINA885")//FWModelActive()
	nOperacao := oModelM:GetOperation()
	aArea     := {}
	lOk       := .T.
	cOperacao := ""
	nEnt      := 0
	cComp     := ""
	cTab      := "SA2"
	cTabAux   := "F72"


	For nEnt  := 1 To 3
		cComp := FwModeAccess(cTab, nEnt)
		If(!FwModeAccess(cTabAux, nEnt) == cComp) .And. lOk
			Help(' ', 1, STR0023   ,, STR0020 + '"' + AllTrim(FwX2Nome(cTabAux)) + ' ('+ cTabAux + ')"' + STR0021 + '"' + AllTrim(FwX2Nome(cTab)) + ' (' + cTab + ')"' , 2, 0,,,,,, {STR0022    })
			lOk := .F.
		EndIf
	Next nEnt

	If lOk
		aArea := GetArea()
		dbSelectArea("F72")
		F72->(dbSetOrder(1))
		nOperacao := 3
		cOperacao := STR0004

		If F72->(DbSeek(xFilial("F72")+SA2->(A2_COD+A2_LOJA)))
			nOperacao := 4
			cOperacao := STR0005
		EndIf

		lOk := (FWExecView(cOperacao, "FINA885", nOperacao, Nil, {||.T.}) == 0)
		RestArea(aArea)
	EndIf
Return lOk

/*/{Protheus.doc} ValidaCGC
Valida CPF ou CNPJ do Fornecedor atual contra os dados do Fornecedor das Chaves PIX encontradas.

@author Rafael Riego
@since  09/02/2022
@param  cCGCAtual, character, CPF/CNPJ do fornecedor posicionado
@param  cTipoForn, character, tipo do fornecedor posicionado
@param  cChave, character, chave pix da linha atual
@param  nRecnoF72, numeric, recno do registroa ser validado
@param  oModel, object, modelo de dados atual para gravação de erros
@return logical, verdadeiro caso todas as validações estejam ok
/*/
Static Function ValidaCGC(cCGCAtual As Character, cTipoForn As Character, cChave As Character, nRecnoF72 As Numeric, oModel As Object) As Logical

    Local aArea     As Array

    Local cRaizCGC  As Character
    Local cQuery    As Character

    Local lPermite  As Logical

    Default cCGCAtual   := ""
    Default cTipoForn   := "J"
    Default cChave      := ""
    Default nRecnoF72   := 0
    Default oModel      := FwModelActive()

    aArea       := GetArea()
    lPermite    := .T.

    cQuery      := "SELECT F72_FILIAL, F72_CHVPIX, F72_COD, F72_LOJA, SA2.A2_TIPO, SA2.A2_CGC "
    cQuery      += "FROM " + RetSQLName("F72") + " F72 "
    cQuery      += "INNER JOIN " + RetSQLName("SA2") + " SA2 ON "
    cQuery      +=     " SA2.A2_FILIAL = F72.F72_FILIAL "
    cQuery      += " AND SA2.A2_COD = F72.F72_COD "
    cQuery      += " AND SA2.A2_LOJA = F72.F72_LOJA "
    cQuery      += " AND SA2.D_E_L_E_T_ = ' ' "
    cQuery      += "WHERE F72.F72_CHVPIX = '" + cChave + "' "
    cQuery      +=  " AND F72.R_E_C_N_O_ <> " + Str(nRecnoF72) + " "
    cQuery      +=  " AND F72.D_E_L_E_T_ = ' ' "
    cQuery      := ChangeQuery(cQuery)
    cAliasQry   := MPSysOpenQuery(cQuery)

    cRaizCGC := SubStr(cCGCAtual, 1, 8)

    While (cAliasQry)->(!EoF())
        If (cAliasQry)->A2_TIPO != cTipoForn
            oModel:SetErrorMessage("FINA885M",, "FINA885M",,, STR0025)
            lPermite := .F.
            Exit
        ElseIf Empty(cCGCAtual) .And. !(Empty((cAliasQry)->A2_CGC))
            oModel:SetErrorMessage("FINA885M",, "FINA885M",,, STR0026)
            lPermite := .F.
            Exit
        ElseIf IIf(cTipoForn == "J", SubStr((cAliasQry)->A2_CGC, 1, 8) != cRaizCGC, (cAliasQry)->A2_CGC != cCGCAtual)
            oModel:SetErrorMessage("FINA885M",, "FINA885M",,, STR0027)
            lPermite := .F.
            Exit
        EndIf
        (cAliasQry)->(DbSkip())
    End
    (cAliasQry)->(DbCloseArea())

    RestArea(aArea)

Return lPermite
