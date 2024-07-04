#INCLUDE "PLSPRO02.ch"
/*/PLSPRO02
Alertas Promoçãp da saúde

@author Saúde
@since 09/2014
@version P11.8
/*/

Function PLSPRO06()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BOS' )
oBrowse:SetDescription( 'Alestar Promoção da Saúde' )
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'         , 0, 1, 0, .T. } )
aAdd( aRotina, { STR0004, 			   		'VIEWDEF.PLSPRO06', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0005  , 				'VIEWDEF.PLSPRO06', 0, 3, 0, NIL } )//'Incluir'
aAdd( aRotina, { STR0006  , 				'VIEWDEF.PLSPRO06', 0, 4, 0, NIL } )//'Alterar'
aAdd( aRotina, { STR0007  , 				'VIEWDEF.PLSPRO06', 0, 5, 0, NIL } )//'Excluir'
aAdd( aRotina, { STR0008  , 				'VIEWDEF.PLSPRO06', 0, 8, 0, NIL } )//'Imprimir'
aAdd( aRotina, { STR0009  , 				'VIEWDEF.PLSPRO06', 0, 9, 0, NIL } )//'Copiar'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBOS := FWFormStruct( 1, 'BOS', /*bAvalCampo*/, /*lViewUsado*/ )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( "Alertas Promoção da Saúde", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'BOSMASTER', NIL, oStruBOS )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( "Alertas Promoção da Saúde" ) 

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BOSMASTER' ):SetDescription( "Alertas Promoção da Saúde" ) 

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruBOS := FWFormStruct( 2, 'BOS', {|cCampo| AllTrim(cCampo)  $ "BOS_RESUMO, BOS_DATSIN, BOS_TEXTO, BOS_ACAO" })
 

 // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'PLSPRO06' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BOS' , oStruBOS, 'BOSMASTER'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_BOS' , 'GERAL'  )

oView:EnableTitleView( 'VIEW_BOS' )

Return oView 

