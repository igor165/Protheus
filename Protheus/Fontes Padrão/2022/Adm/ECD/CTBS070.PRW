#Include "CTBS070.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
/*/
{Protheus.doc} CTBS070
Cadastro de Outras Demonstrações 
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Function CTBS070()
Local oBrowse
Local aBrowse     := {}
Local aIndex      := {}

Private aRotina   := MenuDef()
Private cAliasTmp

CriaTmpCSF()

aAdd(aBrowse, {STR0001, "CODREV", "C", 006, 0, "@!"}) //"Cod. Revisão"
aAdd(aBrowse, {STR0002, "CODREG", "C", 004, 0, "@!"}) //"Cod. Registr"
aAdd(aBrowse, {STR0003, "TIPDOC", "C", 003, 0, "@!"}) //"Tip. Doc.   "
aAdd(aBrowse, {STR0004, "NOMDEM", "C", 254, 0, "@!"}) //"Nome Demonst"
aAdd(aBrowse, {STR0005, "LOCARQ", "C", 254, 0, "@!"}) //"Arq. RTF    "
aAdd(aBrowse, {STR0006, "PERIOD", "C", 003, 0, "@!"}) //"Período     "

aAdd(aIndex, "CODREV" )	

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAliasTmp)
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetTemporary(.T.)
oBrowse:SetFields(aBrowse)
oBrowse:DisableDetails()
oBrowse:SetDescription(STR0034) //"Cadastro de Outras Demonstrações .RTF"
oBrowse:Activate()

Return Nil
/*/
{Protheus.doc} MenuDef
Cadastro de Outras Demonstrações
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0033 ACTION 'VIEWDEF.CTBS070' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.CTBS070' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0009 ACTION 'CTSAltCSF()'     OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.CTBS070' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina
/*/
{Protheus.doc} ModelDef
Cadastro de Outras Demonstrações
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function ModelDef()
//Criação do objeto do modelo de dados
Local oModel := Nil

//Criação da estrutura de dados utilizada na interface
Local oStruTMP := FWFormModelStruct():New()

//adicionado por conta de testes do sonarqube de instanciamento do modelo que fazem testes diretamente nas modeldefs.
If TYPE("cAliasTmp") == "U"
    cAliasTmp := GetNextAlias() //ja é criada como escopo local.
Endif

oStruTMP:AddTable(cAliasTmp,{"CODREV","CODREG","TIPDOC","NOMDEM","LOCARQ","PERIOD"},"TMPCSF")

//Adiciona os campos da estrutura
oStruTMP:AddField(;
    STR0001,;                                                                                   // [01]  C   Titulo do campo //"Cod. Revisão"
    STR0001,;                                                                                   // [02]  C   ToolTip do campo //"Cod. Revisão"
    "CODREV",;                                                                                  // [03]  C   Id do Field
    "C",;                                                                                       // [04]  C   Tipo do campo
    06,;                                                                                        // [05]  N   Tamanho do campo
    0,;                                                                                         // [06]  N   Decimal do campo
    Nil,;                                                                                       // [07]  B   Code-block de validação do campo
    Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
    {},;                                                                                        // [09]  A   Lista de valores permitido do campo
    .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
    FWBuildFeature( STRUCT_FEATURE_INIPAD,"CS0->CS0_CODREV"),;                                  // [11]  B   Code-block de inicializacao do campo
    .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
    .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                        // [14]  L   Indica se o campo é virtual

oStruTMP:AddField(;
    STR0002,;                                                                                   // [01]  C   Titulo do campo //"Cod. Registr"
    STR0002,;                                                                                   // [02]  C   ToolTip do campo //"Cod. Registr"
    "CODREG",;                                                                                  // [03]  C   Id do Field
    "C",;                                                                                       // [04]  C   Tipo do campo
    04,;                                                                                        // [05]  N   Tamanho do campo
    0,;                                                                                         // [06]  N   Decimal do campo
    Nil,;                                                                                       // [07]  B   Code-block de validação do campo
    FWBuildFeature( STRUCT_FEATURE_INIPAD,'"J800"'),;                                           // [08]  B   Code-block de validação When do campo
    {},;                                                                                        // [09]  A   Lista de valores permitido do campo
    .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
    Nil,;                                                                                       // [11]  B   Code-block de inicializacao do campo
    .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
    .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                        // [14]  L   Indica se o campo é virtual

oStruTMP:AddField(;
    STR0011,;                                                                                   // [01]  C   Titulo do campo //"Tip. Doc."
    STR0011,;                                                                                   // [02]  C   ToolTip do campo //"Tip. Doc."
    "TIPDOC",;                                                                                  // [03]  C   Id do Field
    "C",;                                                                                       // [04]  C   Tipo do campo
    03,;                                                                                        // [05]  N   Tamanho do campo
    0,;                                                                                         // [06]  N   Decimal do campo
    Nil,;                                                                                       // [07]  B   Code-block de validação do campo
    Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
    {},;                                                                                        // [09]  A   Lista de valores permitido do campo
    .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
    Nil,;                                                                                       // [11]  B   Code-block de inicializacao do campo
    .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
    .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                        // [14]  L   Indica se o campo é virtual

oStruTMP:AddField(;
    STR0004,;                                                                                   // [01]  C   Titulo do campo //"Nome Demonst"
    STR0004,;                                                                                   // [02]  C   ToolTip do campo //"Nome Demonst"
    "NOMDEM",;                                                                                  // [03]  C   Id do Field
    "C",;                                                                                       // [04]  C   Tipo do campo
    254,;                                                                                       // [05]  N   Tamanho do campo
    0,;                                                                                         // [06]  N   Decimal do campo
    Nil,;                                                                                       // [07]  B   Code-block de validação do campo
    Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
    {},;                                                                                        // [09]  A   Lista de valores permitido do campo
    .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
    Nil,;                                                                                       // [11]  B   Code-block de inicializacao do campo
    .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
    .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                        // [14]  L   Indica se o campo é virtual

oStruTMP:AddField(;
    STR0012,;                                                                                   // [01]  C   Titulo do campo //"Arq. RTF"
    STR0012,;                                                                                   // [02]  C   ToolTip do campo //"Arq. RTF"
    "LOCARQ",;                                                                                  // [03]  C   Id do Field
    "C",;                                                                                       // [04]  C   Tipo do campo
    254,;                                                                                       // [05]  N   Tamanho do campo
    0,;                                                                                         // [06]  N   Decimal do campo
    Nil,;                                                                                       // [07]  B   Code-block de validação do campo
    FWBuildFeature( STRUCT_FEATURE_WHEN,"Inclui" ),;                                            // [08]  B   Code-block de validação When do campo
    {},;                                                                                        // [09]  A   Lista de valores permitido do campo
    .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
    Nil,;                                                                                       // [11]  B   Code-block de inicializacao do campo
    .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
    .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                        // [14]  L   Indica se o campo é virtual

oStruTMP:AddField(;
    STR0013,;                                                                                   // [01]  C   Titulo do campo //"Período"
    STR0013,;                                                                                   // [02]  C   ToolTip do campo //"Período"
    "PERIOD",;                                                                                  // [03]  C   Id do Field
    "C",;                                                                                       // [04]  C   Tipo do campo
    03,;                                                                                        // [05]  N   Tamanho do campo
    0,;                                                                                         // [06]  N   Decimal do campo
    Nil,;                                                                                       // [07]  B   Code-block de validação do campo
    Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
    {},;                                                                                        // [09]  A   Lista de valores permitido do campo
    .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
    Nil,;                                                                                       // [11]  B   Code-block de inicializacao do campo
    .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
    .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                        // [14]  L   Indica se o campo é virtual


oModel := MPFormModel():New("CTBS070",/*bPre*/,{|oModel| CTSVldCSF(oModel)}/*bPos*/,{|oModel| CTSGrvCSF(oModel)}/*bCommit*/,/*bCancel*/) 

//Atribuindo formulários para o modelo
oModel:AddFields("MASTERCSF",/*cOwner*/,oStruTMP)

//Setando a chave primária da rotina
oModel:SetPrimaryKey({'CODREV'})

//Adicionando descrição ao modelo
oModel:SetDescription(STR0014) //"Cadastro de Outras Demonstrações .RTF"

Return oModel
/*/
{Protheus.doc} ViewDef
Cadastro de Outras Demonstrações
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function ViewDef()
Local oModel := FWLoadModel("CTBS070")
Local oStruTMP := FWFormViewStruct():New()
Local oView := Nil
Local aTipDoc := {}

aTipDoc := {"",;
            STR0015,; //"001=Resultado Abrangente do Período"
            STR0016,; //"002=Fluxos de Caixa"
            STR0017,; //"003=Valor Adicionado"
            STR0018,; //"010=Notas Explicativas"
            STR0019,; //"011=Relatório da Administração"
            STR0020,; //"012=Parecer dos Auditores"
            STR0021} //"099=Outros"

//Adicionando campos da estrutura
oStruTMP:AddField(;
    "CODREV",;                  // [01]  C   Nome do Campo
    "01",;                      // [02]  C   Ordem
    STR0001,;                   // [03]  C   Titulo do campo //"Cod. Revisão"
    STR0001,;                   // [04]  C   Descricao do campo //"Cod. Revisão"
    Nil,;                       // [05]  A   Array com Help
    "C",;                       // [06]  C   Tipo do campo
    "@!",;                      // [07]  C   Picture
    Nil,;                       // [08]  B   Bloco de PictTre Var
    Nil,;                       // [09]  C   Consulta F3
    .F.,;                       // [10]  L   Indica se o campo é alteravel
    Nil,;                       // [11]  C   Pasta do campo
    Nil,;                       // [12]  C   Agrupamento do campo
    Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
    Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
    "CS0->CS0_CODREV",;         // [15]  C   Inicializador de Browse
    Nil,;                       // [16]  L   Indica se o campo é virtual
    Nil,;                       // [17]  C   Picture Variavel
    Nil)                        // [18]  L   Indica pulo de linha após o campo

oStruTMP:AddField(;
    "CODREG",;                  // [01]  C   Nome do Campo
    "02",;                      // [02]  C   Ordem
    STR0002,;                   // [03]  C   Titulo do campo //"Cod. Registr"
    STR0002,;                   // [04]  C   Descricao do campo //"Cod. Registr"
    Nil,;                       // [05]  A   Array com Help
    "C",;                       // [06]  C   Tipo do campo
    "@!",;                      // [07]  C   Picture
    Nil,;                       // [08]  B   Bloco de PictTre Var
    Nil,;                       // [09]  C   Consulta F3
    .F.,;                       // [10]  L   Indica se o campo é alteravel
    Nil,;                       // [11]  C   Pasta do campo
    Nil,;                       // [12]  C   Agrupamento do campo
    {STR0023},;                 // [13]  A   Lista de valores permitido do campo (Combo) //"J801=Termo Subst. ECD" //"J800=Outras Dem. RTF"
    Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
    Nil,;                       // [15]  C   Inicializador de Browse
    Nil,;                       // [16]  L   Indica se o campo é virtual
    Nil,;                       // [17]  C   Picture Variavel
    Nil)                        // [18]  L   Indica pulo de linha após o campo

oStruTMP:AddField(;
    "TIPDOC",;                  // [01]  C   Nome do Campo
    "03",;                      // [02]  C   Ordem
    STR0011,;                   // [03]  C   Titulo do campo //"Tip. Doc."
    STR0011,;                   // [04]  C   Descricao do campo //"Tip. Doc."
    Nil,;                       // [05]  A   Array com Help
    "C",;                       // [06]  C   Tipo do campo
    "@!",;                      // [07]  C   Picture
    Nil,;                       // [08]  B   Bloco de PictTre Var
    Nil,;                       // [09]  C   Consulta F3
    .T.,;                       // [10]  L   Indica se o campo é alteravel
    Nil,;                       // [11]  C   Pasta do campo
    Nil,;                       // [12]  C   Agrupamento do campo
    aTipDoc,;                   // [13]  A   Lista de valores permitido do campo (Combo)
    Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
    Nil,;                       // [15]  C   Inicializador de Browse
    Nil,;                       // [16]  L   Indica se o campo é virtual
    Nil,;                       // [17]  C   Picture Variavel
    Nil)                        // [18]  L   Indica pulo de linha após o campo

oStruTMP:AddField(;
    "NOMDEM",;                  // [01]  C   Nome do Campo
    "04",;                      // [02]  C   Ordem
    STR0004,;                   // [03]  C   Titulo do campo //"Nome Demonst"
    STR0004,;                   // [04]  C   Descricao do campo //"Nome Demonst"
    Nil,;                       // [05]  A   Array com Help
    "C",;                       // [06]  C   Tipo do campo
    "@!",;                      // [07]  C   Picture
    Nil,;                       // [08]  B   Bloco de PictTre Var
    Nil,;                       // [09]  C   Consulta F3
    .T.,;                       // [10]  L   Indica se o campo é alteravel
    Nil,;                       // [11]  C   Pasta do campo
    Nil,;                       // [12]  C   Agrupamento do campo
    Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
    Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
    Nil,;                       // [15]  C   Inicializador de Browse
    Nil,;                       // [16]  L   Indica se o campo é virtual
    Nil,;                       // [17]  C   Picture Variavel
    Nil)                        // [18]  L   Indica pulo de linha após o campo

oStruTMP:AddField(;
    "LOCARQ",;                  // [01]  C   Nome do Campo
    "05",;                      // [02]  C   Ordem
    STR0012,;                   // [03]  C   Titulo do campo //"Arq. RTF"
    STR0012,;                   // [04]  C   Descricao do campo //"Arq. RTF"
    Nil,;                       // [05]  A   Array com Help
    "C",;                       // [06]  C   Tipo do campo
    "@!",;                      // [07]  C   Picture
    Nil,;                       // [08]  B   Bloco de PictTre Var
    "DIR",;                     // [09]  C   Consulta F3
    .T.,;                       // [10]  L   Indica se o campo é alteravel
    Nil,;                       // [11]  C   Pasta do campo
    Nil,;                       // [12]  C   Agrupamento do campo
    Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
    Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
    Nil,;                       // [15]  C   Inicializador de Browse
    Nil,;                       // [16]  L   Indica se o campo é virtual
    Nil,;                       // [17]  C   Picture Variavel
    Nil)                        // [18]  L   Indica pulo de linha após o campo    

oStruTMP:AddField(;
    "PERIOD",;                  // [01]  C   Nome do Campo
    "06",;                      // [02]  C   Ordem
    STR0013,;                   // [03]  C   Titulo do campo //"Período"
    STR0013,;                   // [04]  C   Descricao do campo //"Período"
    Nil,;                       // [05]  A   Array com Help
    "C",;                       // [06]  C   Tipo do campo
    "@!",;                      // [07]  C   Picture
    Nil,;                       // [08]  B   Bloco de PictTre Var
    Nil,;                       // [09]  C   Consulta F3
    .T.,;                       // [10]  L   Indica se o campo é alteravel
    Nil,;                       // [11]  C   Pasta do campo
    Nil,;                       // [12]  C   Agrupamento do campo
    {"",STR0026,STR0027,STR0024,STR0025},;// [13]  A   Lista de valores permitido do campo (Combo) //"T03=3º Período" //"T04=4º Período" //"T01=1º Período" //"T02=2º Período"
    Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
    Nil,;                       // [15]  C   Inicializador de Browse
    Nil,;                       // [16]  L   Indica se o campo é virtual
    Nil,;                       // [17]  C   Picture Variavel
    Nil)                        // [18]  L   Indica pulo de linha após o campo    

//Criando a view que será o retorno da função e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formulários para interface
oView:AddField("VIEW_TMP", oStruTMP, "MASTERCSF")
oView:CreateHorizontalBox( 'BOX_FORM_CSF', 100)
oView:SetOwnerView('VIEW_TMP','BOX_FORM_CSF')	

Return oView
/*/
{Protheus.doc} CriaTmpCSF
Cria arquivo temporário
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function CriaTmpCSF()
Local oTmpTable
Local aStrut      := {}

cAliasTmp := GetNextAlias()

aAdd(aStrut, {"CODREV", "C", 006, 0} )
aAdd(aStrut, {"CODREG", "C", 004, 0} )
aAdd(aStrut, {"TIPDOC", "C", 003, 0} )
aAdd(aStrut, {"NOMDEM", "C", 254, 0} )
aAdd(aStrut, {"LOCARQ", "C", 254, 0} )
aAdd(aStrut, {"PERIOD", "C", 003, 0} )

oTmpTable := FWTemporaryTable():New(cAliasTmp)
oTmpTable:SetFields(aStrut)
oTmpTable:AddIndex("TRBCSF1", {"CODREV","CODREG","TIPDOC","NOMDEM","LOCARQ","PERIOD"}) 
oTmpTable:Create()

CarrTmpCSF()

Return
/*/
{Protheus.doc} CarrTmpCSF
Carrega os dados da tabela temporária
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function CarrTmpCSF()
Local cALiasAux := ""

cAliasAux := RetQryCSF(CS0->CS0_CODREV,,,,.T.)

While !(cAliasAux)->(Eof())
    
    (cAliasTmp)->(RecLock(cAliasTmp,.T.))
        (cAliasTmp)->CODREV := (cAliasAux)->CSF_CODREV
        (cAliasTmp)->CODREG := (cAliasAux)->CSF_CODREG
        (cAliasTmp)->TIPDOC := (cAliasAux)->CSF_TIPDOC
        (cAliasTmp)->NOMDEM := (cAliasAux)->CSF_NOMDEM
        (cAliasTmp)->LOCARQ := (cAliasAux)->CSF_LOCARQ
        (cAliasTmp)->PERIOD := (cAliasAux)->CSF_PERIOD
    (cAliasTmp)->(MsUnLock())

    (cAliasAux)->(dbSkip())
EndDo
(cAliasAux)->(dbCloseArea())

Return 
/*/
{Protheus.doc} CTSAltCSF
Chama a view para a alteração
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Function CTSAltCSF()

FWExecView(STR0009,"CTBS070",MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/) //"Alterar"

Return .T.
/*/
{Protheus.doc} CTSGrvCSF
Carrega os dados da tabela temporária
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Function CTSGrvCSF(oModel)
Local aArea    	:= GetArea()
Local nOperation:= oModel:GetOperation()

If nOperation == 3
    GTSInsCSF(oModel)
ElseIf nOperation == 4
    GTSUPDCSF(oModel)
ElseIf nOperation == 5
    GTSDelCSF(oModel)
EndIf

RestArea(aArea)

Return .T.
/*/
{Protheus.doc} CTSVldCSF
Carrega os dados da tabela temporária
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Function CTSVldCSF(oModel)
Local aArea    	:= {}
Local aAreaTmp  := {}
Local lRet	 	:= .T.
Local nOperation:= oModel:GetOperation()

FwClearHLP()

If VldModForm(oModel)
    aArea    := GetArea()
    aAreaTmp := (cAliasTmp)->(GetArea())

    If lRet .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
        If Empty(oModel:GetValue("MASTERCSF","TIPDOC"))
            Help("",1,"CTSVldCSF",STR0028,STR0030,1,0,,,,,,{STR0029})         //"Tipo de documento não informado." //"Verifique os dados informados." //"Para o registro J800 é obrigatório informar um tipo de documento."
            lRet := .F.
        EndIf

        If lRet 
            lRet := .F.           
            CS2->(dbSetOrder(1))
            If CS2->(dbSeek(xFilial("CS2")+CS0->CS0_CODREV))		                
                lRet := CTBSVldCal(CS0->CS0_CALEND,oModel:GetValue("MASTERCSF","PERIOD"),nil,nil,AllTrim(CS2->CS2_SITESP)<>"Z")				                          
            EndIf
        EndIf

        If lRet                  
            cAliasAux := RetQryCSF( oModel:GetValue("MASTERCSF","CODREV"),;                                    
                                    oModel:GetValue("MASTERCSF","TIPDOC"),;
                                    oModel:GetValue("MASTERCSF","LOCARQ"),;
                                    oModel:GetValue("MASTERCSF","PERIOD"),;
                                    .T.)

            If !(cAliasAux)->(Eof())
                Help("",1,"CTSVldCSF",STR0032,STR0031,1,0,,,,,,{STR0029})		 //"Já existe um registro gravado com essas informações." //"Verifique os dados informados." //"Registro já existe."
                lRet := .F.
            EndIf
            (cAliasAux)->(dbCloseArea())                    
        EndIf
    EndIf
    RestArea(aAreaTmp)
    RestArea(aArea)
EndIf

Return lRet
/*/
{Protheus.doc} GTSInsCSF
Carrega os dados da tabela temporária
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function GTSInsCSF(oModel)
Local dDatIni	:= StoD("")
Local dDatFim   := StoD("")
Local aArqRtf	:= {}
Local cFile    	:= ""
Local cExt     	:= ""
Local cLinha	:= Replicate("0",18)
Local nI        := 0

If Empty(oModel:GetValue("MASTERCSF","PERIOD"))
    dDatIni := CS0->CS0_DTINI
    dDatFim := CS0->CS0_DTFIM
Else
    //Chamada para atualizar as variáveis dDatIni e dDatFim
    CTBSVldCal(CS0->CS0_CALEND,oModel:GetValue("MASTERCSF","PERIOD"),@dDatIni,@dDatFim)	
EndIf

cArqRTF	:= Iif( Upper(TCSrvType())=="LINUX", AllTrim(StrTran(oModel:GetValue("MASTERCSF","LOCARQ"),"\","/")), AllTrim(oModel:GetValue("MASTERCSF","LOCARQ")))

SplitPath(cArqRTF,/*cDrive*/,/*cPath*/, @cFile,@cExt)

If !Empty(cArqRTF) 

    (cAliasTmp)->(RecLock(cAliasTmp,.T.))        
        (cAliasTmp)->CODREG := "J800"
        (cAliasTmp)->CODREV	:= oModel:GetValue("MASTERCSF","CODREV")
        (cAliasTmp)->NOMDEM := oModel:GetValue("MASTERCSF","NOMDEM")        
        (cAliasTmp)->TIPDOC := oModel:GetValue("MASTERCSF","TIPDOC")
        (cAliasTmp)->PERIOD := oModel:GetValue("MASTERCSF","PERIOD")	
        (cAliasTmp)->LOCARQ := oModel:GetValue("MASTERCSF","LOCARQ")            				
    (cAliasTmp)->(MsUnLock())

    CSF->(RecLock("CSF",.T.))
        CSF->CSF_FILIAL	:= xFilial("CSF")
        CSF->CSF_CODREG := "J800"
        CSF->CSF_CODREV	:= oModel:GetValue("MASTERCSF","CODREV")
        CSF->CSF_NOMDEM := oModel:GetValue("MASTERCSF","NOMDEM")
        CSF->CSF_TIPDOC := oModel:GetValue("MASTERCSF","TIPDOC")
        CSF->CSF_PERIOD := oModel:GetValue("MASTERCSF","PERIOD")	
        CSF->CSF_LOCARQ := oModel:GetValue("MASTERCSF","LOCARQ")            				
    CSF->(MsUnLock())
    
    aArqRtf := EcdLoadTXT(cArqRTF)

    For nI := 1 to Len(aArqRtf)
        cLinha := Soma1(cLinha)
        CSF->(RecLock("CSF",.T.))
            CSF->CSF_FILIAL	:= xFilial("CSF")
            CSF->CSF_CODREV	:= oModel:GetValue("MASTERCSF","CODREV")					
            CSF->CSF_LINHA 	:= cLinha
            CSF->CSF_DTINI	:= dDatIni
            CSF->CSF_DTFIM	:= dDatFim
            CSF->CSF_CODREG := "J800"
            CSF->CSF_NOMDEM := oModel:GetValue("MASTERCSF","NOMDEM")
            CSF->CSF_ARQRTF	:= aArqRtf[nI]            
            CSF->CSF_TIPDOC := oModel:GetValue("MASTERCSF","TIPDOC")
            CSF->CSF_PERIOD := oModel:GetValue("MASTERCSF","PERIOD")	
            CSF->CSF_LOCARQ := oModel:GetValue("MASTERCSF","LOCARQ")            				
        CSF->(MsUnLock())
    Next nI
EndIf	

Return .T.
/*/
{Protheus.doc} GTSUpDCSF
Carrega os dados da tabela temporária
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function GTSUpDCSF(oModel)
Local cAliasAux := ""

If VldModForm(oModel) 
    cAliasAux := RetQryCSF( (cAliasTmp)->CODREV,;                        
                            (cAliasTmp)->TIPDOC,;
                            (cAliasTmp)->LOCARQ,;
                            (cAliasTmp)->PERIOD )

    While !(cAliasAux)->(Eof())
        
        CSF->(dbGoTo((cAliasAux)->RECNO))
        CSF->(RecLock("CSF",.F.))                
            CSF->CSF_NOMDEM := oModel:GetValue("MASTERCSF","NOMDEM")
            CSF->CSF_TIPDOC := oModel:GetValue("MASTERCSF","TIPDOC")
            CSF->CSF_PERIOD := oModel:GetValue("MASTERCSF","PERIOD")	         				
        CSF->(MsUnLock())

        (cAliasAux)->(dbSkip())
    EndDo
    (cAliasAux)->(dbCloseArea())

    (cAliasTmp)->(RecLock(cAliasTmp,.F.))            
        (cAliasTmp)->NOMDEM := oModel:GetValue("MASTERCSF","NOMDEM")       
        (cAliasTmp)->TIPDOC := oModel:GetValue("MASTERCSF","TIPDOC")
        (cAliasTmp)->PERIOD := oModel:GetValue("MASTERCSF","PERIOD")	         				
    (cAliasTmp)->(MsUnLock())
EndIf

Return .T.
/*/
{Protheus.doc} GTSDelCSF
Carrega os dados da tabela temporária
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function GTSDelCSF(oModel)
Local cAliasAux := ""

cAliasAux := RetQryCSF( (cAliasTmp)->CODREV,;                      
                        (cAliasTmp)->TIPDOC,;
                        (cAliasTmp)->LOCARQ,;
                        (cAliasTmp)->PERIOD)

While !(cAliasAux)->(Eof())
	CSF->(dbGoto((cAliasAux)->RECNO))
	CSF->(RecLock("CSF",.F.))
		CSF->(dbDelete())
	CSF->(MsUnLock())
	(cAliasAux)->(dbSkip())
EndDo
(cAliasAux)->(dbCloseArea())

(cAliasTmp)->(RecLock(cAliasTmp,.F.))
	(cAliasTmp)->(dbDelete())
(cAliasTmp)->(MsUnLock())

Return .T.
/*/
{Protheus.doc} RetQryCSF
Monta a query para a CSF
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Function RetQryCSF(cCodRev,cTipDoc,cLocArq,cPeriod,lLinha)
Local cSQL      := ""
Local cAliasAux := ""

DEFAULT cCodRev := ""
DEFAULT cTipDoc := ""
DEFAULT cLocArq := ""
DEFAULT cPeriod := ""
DEFAULT lLinha  := .F.

cSQL := " SELECT "
cSQL += "	CSF_CODREV, CSF_CODREG, CSF_TIPDOC, CSF_NOMDEM, CSF_LOCARQ, CSF_PERIOD, R_E_C_N_O_ RECNO "
cSQL += "	FROM "
cSQL += 		RetSqlName("CSF")
cSQL += "		WHERE "
cSQL += "			CSF_FILIAL = '"+xFilial("CSF")+"' AND "
cSQL += "			CSF_CODREV = '"+cCodRev+"' AND "
cSQL += "		    CSF_CODREG = 'J800' AND "

If !Empty(cTipDoc)
    cSQL += "		CSF_TIPDOC = '"+cTipDoc+"' AND "
EndIf
If !Empty(cLocArq)
    cSQL += "		CSF_LOCARQ = '"+cLocArq+"' AND "
EndIf
If !Empty(cPeriod)
    cSQL += "		CSF_PERIOD = '"+cPeriod+"' AND "
EndIf
If lLinha
    cSQL += "		CSF_LINHA  = '"+Space(TamSX3("CSF_LINHA")[1])+"' AND "
EndIf

cSQL += "			D_E_L_E_T_ = ' '

cSQL := ChangeQuery(cSQL)
cAliasAux := GetNextAlias()

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasAux,.T.,.T.)

Return cAliasAux
/*/
{Protheus.doc} RetQryCSF
Monta a query para a CSF
@author TOTVS
@since 14/02/2019
@version 1.0
	@return Nil, Função não tem retorno
	@example
	CTBS070()
/*/
Static Function VldModForm(oModel)
Local lRet := .T.
Local nOperation:= oModel:GetOperation()

If  nOperation == MODEL_OPERATION_UPDATE .And.;
    oModel:GetValue("MASTERCSF","NOMDEM") == (cAliasTmp)->NOMDEM .And.;
    oModel:GetValue("MASTERCSF","TIPDOC") == (cAliasTmp)->TIPDOC .And.;
    oModel:GetValue("MASTERCSF","PERIOD") == (cAliasTmp)->PERIOD    
    lRet := .F.   
EndIf

Return lRet
