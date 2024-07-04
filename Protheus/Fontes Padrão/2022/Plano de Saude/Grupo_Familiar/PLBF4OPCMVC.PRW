#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados das guias
@author Gabriela Cattin
@since 06/05/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria as estruturas a serem usadas no Modelo de Dados.
	Local oStruBF4 := FWFormStruct( 1, 'BF4' )
	Local oStruBYX := FWFormStruct( 1, 'BYX')

	Local oModel := MPFormModel():New( 'PLBF4OPCMVC', , {|| .t. }  )

	oModel:AddFields( 'MASTERBF4' ,/*cOwner*/, oStruBF4 )
	oModel:AddGrid('BYXDETAIL', 'MASTERBF4', oStruBYX)

	oModel:SetRelation( 'BYXDETAIL', { { 'BYX_FILIAL' 	, 'xFilial( "BYX" )'},;
		{ 'BYX_CODOPE'	, 'BF4_CODINT' },;
		{ 'BYX_CODEMP'	, 'BF4_CODEMP' },;
		{ 'BYX_MATRIC'	, 'BF4_MATRIC' },;
		{ 'BYX_CODOPC'	, 'BF4_CODPRO' },;
		{ 'BYX_VEROPC'	, 'BF4_VERSAO'},;
		{ 'BYX_TIPREG'  , 'BF4_TIPREG'}},;
		BYX->( IndexKey(1 ) ) )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'OPCIONAIS DO BENEFICIÁRIO' ) 

	oModel:GetModel( "BYXDETAIL" ):SetOptional(.T.)
	oModel:GetModel('BYXDETAIL'):SetUniqueLine({'BYX_CODFOR', 'BYX_TIPREG'})

	oStruBF4:setProperty( '*', MODEL_FIELD_VALID, { || .T. } )
	oStruBYX:SetProperty( '*', MODEL_FIELD_VALID, { || .T.} )
	oStruBF4:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
	oStruBYX:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
	oStruBF4:SetProperty( '*', MODEL_FIELD_INIT, { || " " } )
	oStruBYX:SetProperty( '*', MODEL_FIELD_INIT, { || " " } )

	oModel:SetPrimaryKey({ 'BF4_FILIAL',;
		'BF4_CODINT',;
		'BF4_CODEMP',;
		'BF4_MATRIC',;
		'BF4_TIPREG',;
		'BF4_CODPRO'})

Return oModel
