#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'        
#INCLUDE "PARMTYPE.CH"


//-------------------------------------------------------------------
Function HSPAHM60()
Local oBrowse

If !Hs_ExisDic({{"T","GTI"}},.T.)
	Return
EndIf 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('GTI')
oBrowse:SetDescription('Cadastro de Regiões de Imagens')
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'          OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.HSPAHM60' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.HSPAHM60' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.HSPAHM60' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.HSPAHM60' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.HSPAHM60' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.HSPAHM60' OPERATION 9 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruGTI := FWFormStruct( 1, 'GTI', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('HSPM60MODEL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('COMP011MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'GTIMASTER', /*cOwner*/, oStruGTI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados Regiões da Imagem' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'GTIMASTER' ):SetDescription( 'Região da Imagem' )

// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'HSPAHM60' )
// Cria a estrutura a ser usada na View
Local oStruGTI := FWFormStruct( 2, 'GTI' )
//Local oStruZA0 := FWFormStruct( 2, 'ZA0', { |cCampo| COMP11STRU(cCampo) } )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_GTI', oStruGTI, 'GTIMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_GTI', 'TELA' )

Return oView

