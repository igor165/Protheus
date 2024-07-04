#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'        
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
Function HSPAHM64()
Local oBrowse

If !Hs_ExisDic({{"T","GTR"}},.T.)
	Return
EndIf 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('GTR')
oBrowse:SetDescription('Cadastro de Facilitadores para construção de Fichas') //'Cadastro de Facilitadores para construção de Fichas'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  	ACTION 'PesqBrw'          OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.HSPAHM64' OPERATION 2 ACCESS 0 // 'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.HSPAHM64' OPERATION 3 ACCESS 0 // 'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.HSPAHM64' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.HSPAHM64' OPERATION 5 ACCESS 0 // 'Excluir'
ADD OPTION aRotina TITLE 'Imprimir'   	ACTION 'VIEWDEF.HSPAHM64' OPERATION 8 ACCESS 0 // 'Imprimir'
ADD OPTION aRotina TITLE 'Copiar'    ACTION 'VIEWDEF.HSPAHM64' OPERATION 9 ACCESS 0 // 'Copiar'
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruGTR := FWFormStruct( 1, 'GTR', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('HSPM64MODEL', /*bPreValidacao*/,  ,/*bCancel*/ , /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'GTRMASTER', /*cOwner*/, oStruGTR, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados Críticas de Facilitadores Fichas' ) //'Modelo de Dados Críticas de Procedimentos'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'GTRMASTER' ):SetDescription( "Facilitadores" ) // 'Críticas'


Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'HSPAHM64' )
// Cria a estrutura a ser usada na View
Local oStruGTR := FWFormStruct( 2, 'GTR' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_GTR', oStruGTR, 'GTRMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_GTR', 'TELA' )

Return oView   



