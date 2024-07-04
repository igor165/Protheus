#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'TOPCONN.CH'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF

#DEFINE STR0001 "DIOPS -Fluxo de Caixa x Natureza Financeira"

/*/{Protheus.doc} PLSMVCFCX2

Manutencao de Código x Natureza Financeira para DIOPS - Fluxo de Caixa

@author rogerc
@since 13/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCFCX2()
Local oBrowse	:= Nil

Private B8HF3	:= ""

oBrowse := FWmBrowse():New()
oBrowse:SetAlias('B8V')
oBrowse:SetDescription(STR0001)  
oBrowse:SetMenuDef( 'PLSMVCFCX2' )
oBrowse:Activate()

Return( Nil )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@return aRotina	Lista de opcoes do menu

@author rogerc
@since 14/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { 'Pesquisar' /*STR0002*/	, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
aAdd( aRotina, { 'Visualizar' /*STR0003*/	, 'VIEWDEF.PLSMVCFCX2'	, 0 , 2 , 0 , Nil } ) //Visualizar
aAdd( aRotina, { 'Incluir' /*STR0004*/	, 'VIEWDEF.PLSMVCFCX2'	, 0 , 3 , 0 , Nil } ) //Incluir
aAdd( aRotina, { 'Alterar' /*STR0005*/	, 'VIEWDEF.PLSMVCFCX2'	, 0 , 4 , 0 , Nil } ) //Alterar
aAdd( aRotina, { 'Excluir' /*STR0006*/	, 'VIEWDEF.PLSMVCFCX2'	, 0 , 5 , 0 , Nil } ) //Excluir
aAdd( aRotina, { 'eXportar' /*STR0008*/	, 'PLSDFLCXTR'			, 0 , 3 , 0 , NIL } ) //Exporta para .CSV
aAdd( aRotina, { 'Imprimir' /*STR0009*/	, 'VIEWDEF.PLSMVCFCX2'	, 0 , 8 , 0 , Nil } ) //Imprimir
Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para o B8V

@return oModel	objeto model criado

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruB8V 		:= FWFormStruct( 1, 'B8V' )
Local oModel // Modelo de dados construído

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSMVCFCX2' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'B8VMASTER', /*cOwner*/ , oStruB8V )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( STR0001 )

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'B8VMASTER' ):SetDescription( STR0001 )

//Seta Chaves primarias
oModel:SetPrimaryKey({})

// Retorna o Modelo de dados
Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o B8V

@return oView	objeto view criado

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSMVCFCX2' )
// Cria as estruturas a serem usadas na View
Local oStruB8V 			:= FWFormStruct( 2, 'B8V' )

// Interface de visualização construída
Local oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_B8V', oStruB8V, 'B8VMASTER' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 50 )
oView:CreateHorizontalBox( 'INFERIOR', 50 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_B8V', 'SUPERIOR' )

//Insiro descrições nas views
oView:EnableTitleView( 'VIEW_B8V', STR0001 )

// Retorna o objeto de View criado
Return oView
