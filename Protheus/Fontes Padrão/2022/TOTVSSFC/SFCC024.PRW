#INCLUDE 'SFCC024.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCC024
Tela de cadastro de Desenho Produto

@author Ana Carolina Tomé Klock
@since 27/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function SFCC024()
Local oBrowse

If DPRIntegra() != 1                     
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('CZA')
	oBrowse:SetDescription( STR0001 ) // 'Consulta de Desenho'
	oBrowse:Activate()
Else
	DPRXError( 'SFCC024', 'DPRA102_DATASU', 3 ) 
EndIf

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCC024' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCC024' OPERATION 3 ACCESS 0  // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCC024' OPERATION 4 ACCESS 0  // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCC024' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCC024' OPERATION 8 ACCESS 0  // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCC024' OPERATION 9 ACCESS 0  // 'Copiar'
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCZA := FWFormStruct( 1, 'CZA', /*bAvalCampo*/,/*lViewUsado*/ ) 
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCC024', /*bPreValidacao*/,  /*bPosValidação*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CZAMASTER', /*cOwner*/, oStructCZA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados do Desenho'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CZAMASTER' ):SetDescription( STR0010 )  //'Dados de Desenho'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCC024' )
// Cria a estrutura a ser usada na View
Local oStructCZA := FWFormStruct( 2, 'CZA' )

// Cria o objeto de View
oView := FWFormView():New()
                                
// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CZA', oStructCZA, 'CZAMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )                                        

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CZA', 'TELA' ) 

Return oView 