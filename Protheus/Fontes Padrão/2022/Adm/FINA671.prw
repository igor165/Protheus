#INCLUDE "FINA671.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA671
Cadastro de tabela de conversao entre o codigo da empresa dentro Site
Reserve e o Codigo da empresa dentro do sistema Protheus

@author Alexandre Circenis
@since 29-08-2013
@version P11.9
/*/
//-------------------------------------------------------------------
Function FINA671()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FL3')
oBrowse:SetDescription(STR0001)
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.FINA671' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.FINA671' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.FINA671' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.FINA671' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE STR0006  	ACTION 'VIEWDEF.FINA671' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.FINA671' OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser acrescentada no Modelo de Dados
Local oStru := FWFormStruct( 1, 'FL3', /*bAvalCampo*/,/*lViewUsado*/ )
// Inicia o Model com um Model ja existente
Local oModel := MPFormModel():New( 'FINA671A' )

oModel:AddFields( 'FL3MASTER', /*cOwner*/, oStru )
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Cadastro de Niveis de Cargo'
// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel( 'FL3MASTER' ):SetDescription( STR0001 ) //'Cadastro de Niveis de Cargo'
// Retorna o Modelo de dados

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel( 'FINA671' )
// Cria a estrutura a ser usada na View
Local oStru := FWFormStruct( 2, 'FL3' )
// Interface de visualização construída
Local oView
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados será utilizado na View
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formulário
// (antiga Enchoice)
oView:AddField( 'VIEW_FL3', oStru, 'FL3MASTER' )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )
// Relaciona o identificador (ID) da View com o "box" para
oView:SetOwnerView( 'VIEW_FL3', 'TELA' )
// Retorna o objeto de View criado
Return oView                                                                           

