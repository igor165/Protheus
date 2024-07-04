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

Definicao do modelo MVC para o conjunto B3X e B3F

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruB3X 		:= FWFormStruct( 1, 'B3X' )
	Local oStruB3F 		:= FWFormStruct( 1, 'B3F' )
	Local oModel // Modelo de dados construído

	// Cria o objeto do Modelo de Dados
	//oModel := MPFormModel():New( 'PLSMVCCOMPROM',,,{ |oModel| PLGrvComp( oModel ) } )
	oModel := MPFormModel():New( 'PLSMVCMOVSIBCRIT' )

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'B3XMASTER', /*cOwner*/ , oStruB3X )
	// Adiciona ao modelo componente de grid
	oModel:AddGrid( 'B3FDETAIL', 'B3XMASTER', oStruB3F )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
		{ 'B3F_ORICRI' , '"B3X"' },;
		{ 'B3F_CODOPE' , 'B3X_OPERA' },;
		{ 'B3F_IDEORI' , 'B3X_IDEORI' };
		}, B3F->( IndexKey( 1 ) ) )
	// oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
	// 											{ 'B3F_ORICRI' , '"B3X"' },;
	// 											{ 'B3F_CHVORI' , 'B3X->(Recno())' };
	// 					}, B3F->( IndexKey( 1 ) ) )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'Críticas' )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'B3XMASTER' ):SetDescription( "Compromissos" )
	oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Críticas" )

	// Retorna o Modelo de dados
Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o conjunto B3X e B3F

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'PLSMVCMOVSIBCRIT' )
	// Cria as estruturas a serem usadas na View
	Local oStruB3X 			:= FWFormStruct( 2, 'B3X' )
	Local oStruB3F 			:= FWFormStruct( 2, 'B3F' )
	// Interface de visualização construída
	Local oView

	oView := FWFormView():New()

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_B3X', oStruB3X, 'B3XMASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_B3F', oStruB3F, 'B3FDETAIL' )

	oStruB3F:RemoveField('B3F_CODOPE')
	oStruB3F:RemoveField('B3F_CDOBRI')
	oStruB3F:RemoveField('B3F_ANO')
	oStruB3F:RemoveField('B3F_CDCOMP')

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_B3X', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B3F', 'INFERIOR' )

	//Insiro descrições nas views
	oView:EnableTitleView( 'VIEW_B3X', "Movimento SIB" )
	oView:EnableTitleView( 'VIEW_B3F', "Críticas no Processamento" )

	oView:AddUserButton( 'Visualiza Cadastro', '', {|oView| PLCOExiCad(.F.)} )
	//oView:AddUserButton( 'Comparar ANS x Central', '', {|oView| PLCOComCad()} )
	//oView:AddUserButton( 'Enviar Alt. ANS', '', {|oView| PLSALTANS(oModel)} )

	// Retorna o objeto de View criado
Return oView
