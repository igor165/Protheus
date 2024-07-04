#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TOTVS.ch'

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

Definicao do modelo MVC para o conjunto B3A e B3F

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruB3A 		:= FWFormStruct( 1, 'B3A' )
	Local oStruB3F 		:= FWFormStruct( 1, 'B3F' )
	Local oModel // Modelo de dados construído

	// Cria o objeto do Modelo de Dados
	//oModel := MPFormModel():New( 'PLSMVCCOMPROM',,,{ |oModel| PLGrvComp( oModel ) } )
	oModel := MPFormModel():New( 'PLSMVCOBRCRIT' )

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'B3AMASTER', /*cOwner*/ , oStruB3A )
	// Adiciona ao modelo componente de grid
	oModel:AddGrid( 'B3FDETAIL', 'B3AMASTER', oStruB3F )

	// Faz relacionamento entre os componentes do model
	//B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP
	//B3A_CODOPE+B3A_CDOBRI+B3A_ANO+B3A_CODIGO
	oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
		{ 'B3F_CODOPE' , 'B3A->B3A_CODOPE' },;
		{ 'B3F_CDOBRI' , 'B3A->B3A_CODIGO' };
		}, B3F->( IndexKey( 1 ) ) )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'Críticas' )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'B3AMASTER' ):SetDescription( "Obrigação" )
	oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Críticas" )

	oModel:SetPrimaryKey({})

	// Retorna o Modelo de dados
Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o conjunto B3A e B3F

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'PLSMVCOBRCRIT' )
	// Cria as estruturas a serem usadas na View
	Local oStruB3A 			:= FWFormStruct( 2, 'B3A' )
	Local oStruB3F 			:= FWFormStruct( 2, 'B3F' )
	// Interface de visualização construída
	Local oView

	oView := FWFormView():New()

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_B3A', oStruB3A, 'B3AMASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_B3F', oStruB3F, 'B3FDETAIL' )

	oStruB3F:RemoveField('B3F_CODOPE')
	oStruB3F:RemoveField('B3F_CDOBRI')
	//oStruB3F:RemoveField('B3F_ANO')
	//oStruB3F:RemoveField('B3F_CDCOMP')

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_B3A', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B3F', 'INFERIOR' )

	//Insiro descrições nas views
	oView:EnableTitleView( 'VIEW_B3A', "Obrigação" )
	oView:EnableTitleView( 'VIEW_B3F', "Críticas no Processamento" )

	oView:AddUserButton( 'Enviar Alt. ANS', '', {|oView| PLSALTANS(oModel)} )

	//oView:SetViewProperty( 'VIEW_B3F', "ENABLEDGRIDDETAIL", { 50 } )

	// Retorna o objeto de View criado
Return oView