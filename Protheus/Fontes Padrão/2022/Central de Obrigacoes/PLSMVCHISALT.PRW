#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CODCRI         1 // Codigo da critica
#DEFINE FUNCAO         2 // Função de Validação da Crítica
#DEFINE DESCRI         3 // Descricao
#DEFINE SOLUCAO        4 // Solucao
#DEFINE TOTALIZA       5 // Indicacao de critica totalizadora
#DEFINE CAMPOS         6 // Campos para enviar à ANS
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para o conjunto B3D e B3F

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruB3X 		:= FWFormStruct( 1, 'B3X' )
//Local oStruB3F 		:= FWFormStruct( 1, 'B3F' )
Local oModel // Modelo de dados construído

// Cria o objeto do Modelo de Dados
//oModel := MPFormModel():New( 'PLSMVCCOMPROM',,,{ |oModel| PLGrvComp( oModel ) } )
oModel := MPFormModel():New( 'PLSMVCHISALT' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'B3XMASTER', /*cOwner*/ , oStruB3X )
// Adiciona ao modelo componente de grid
//oModel:AddGrid( 'B3FDETAIL', 'B3DMASTER', oStruB3F )

// Faz relacionamento entre os componentes do model
/*oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
											{ 'B3F_CODOPE' , 'B3D_CODOPE' },;
											{ 'B3F_CDOBRI' , 'B3D_CDOBRI' },;
											{ 'B3F_ANO' , 'B3D_ANO' },;
											{ 'B3F_CDCOMP' , 'B3D_CODIGO' };
					}, B3F->( IndexKey( 1 ) ) )
*/				
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( 'Histórico de Alterações' )

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'B3XMASTER' ):SetDescription( "Histórico de Alterações" )
//oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Críticas" )

// Retorna o Modelo de dados
Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o conjunto B3D e B3F

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSMVCHISALT' )
// Cria as estruturas a serem usadas na View
Local oStruB3X 			:= FWFormStruct( 2, 'B3X' )
//Local oStruB3F 			:= FWFormStruct( 2, 'B3F' )
// Interface de visualização construída
Local oView

oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_B3X', oStruB3X, 'B3XMASTER' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )


// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_B3X', 'SUPERIOR' )

//Insiro descrições nas views
oView:EnableTitleView( 'VIEW_B3X', "Histórico de Alterações" )

// Retorna o objeto de View criado
Return oView
