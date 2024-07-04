#INCLUDE 'DPRA110.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA110
Tela de Cadastro de Critério de Qualidade do Produto

@author Ana Carolina Tome Klock
@since 26/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA110()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA110', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DGE')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Critério de Qualidade do Produto'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA110' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA110' OPERATION 3 ACCESS 0    // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA110' OPERATION 4 ACCESS 0    // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA110' OPERATION 5 ACCESS 0    // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA110' OPERATION 8 ACCESS 0    // 'Imprimir'
ADD OPTION aRotina TITLE STR0009 ACTION 'DPRA110CRI()'    OPERATION 2 ACCESS 0    // 'Peso de Critério do Produto'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDGE := FWFormStruct( 1, 'DGE', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA110', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DGEMASTER', /*cOwner*/, oStructDGE, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0010 ) //'Modelo de Dados do Critério de Qualidade do Produto'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DGEMASTER' ):SetDescription( STR0011 ) // 'Dados do Critério de Qualidade do Produto'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA110' )
// Cria a estrutura a ser usada na View
Local oStructDGE := FWFormStruct( 2, 'DGE' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DGE', oStructDGE, 'DGEMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA', 100 )

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DGE', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA110CRI
Tela para Cadastro de Peso Critério

@author Ana Carolina Tome Klock
@since 23/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA110CRI()

// Chama o Model da tela 'Peso Critério'
oModel:= FwLoadModel('DPRA120')

// Define que está incluindo um registro
oModel:SetOperation(3)

// Ativa o Model
oModel:Activate()

// Define como padrão o Critério selecionado
oModel:SetValue( 'DGFMASTER', 'DGF_CDJZ'  , DGE->DGE_CDJZ  )

// Abre o Model
FWExecView('','DPRA120', MODEL_OPERATION_INSERT,,{ || .T. },,,,,,, oModel )

Return Nil
