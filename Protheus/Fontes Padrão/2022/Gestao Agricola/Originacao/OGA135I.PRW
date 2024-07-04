#INCLUDE "OGA135I.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

/*/{Protheus.doc} OGA135I
Rotina para Cadastro de Tabelas de Descontos Agricolas
@type function  
@author Bruna Rocio
@since 22/10/2014 
@param cCodigo, character, Codigo da tabela de serviço
/*/
Function OGA135I( cCodigo )
	Local aAreaAtu	
	Local oMBrowse	:= Nil
	
	Private cCod := cCodigo 
	
	dbselectarea("NKP")
	aAreaAtu	:= GetArea()	

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NKQ" )
	oMBrowse:SetMenuDef( "OGA135I" )
	oMBrowse:SetDescription( STR0001 ) //"Itens das Tabelas de Serviços"
	oMBrowse:SetFilterDefault( "NKQ_FILIAL == '" + FWxFilial( "NKQ" ) + "'" + " .And. NKQ_CODTSE == '" + cCodigo + "'" )
	oMBrowse:Activate()

	RestArea( aAreaAtu )

Return( Nil )

/*/{Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina
@type function 
@author Bruna Rocio
@since 22/10/2014
@return Array, Array com os itens do menu
/*/
Static Function MenuDef()
	
	Local aRotina := {}

	aAdd( aRotina, { STR0002	 	, "PesqBrw"			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003		, "ViewDef.OGA135I"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004 	, "ViewDef.OGA135I"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005   	, "ViewDef.OGA135I"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006   	, "ViewDef.OGA135I"	, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007  	, "ViewDef.OGA135I"	, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0008    , "ViewDef.OGA135I"	, 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )

/*/{Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina
@type function
@author Equipe Agroindustria
@since 08/06/2010
@return object, Objeto model
/*/
Static Function ModelDef()

	Local oStruNKQ 	:= FWFormStruct( 1, "NKQ" )
	Local oStruNKR 	:= FWFormStruct( 1, "NKR" )
	Local oModel 		:= MPFormModel():New( "OGA135I" , , {| oModel | PosModelo( oModel ) }, )

	oStruNKR:RemoveField( "NKR_CODTSE" )
	oStruNKR:RemoveField( "NKR_ITETSE" )
	
	oModel:SetDescription( STR0009 ) //"Itens da Tabela de Serviço"

	oModel:AddFields( "NKQUNICO", Nil, oStruNKQ, {| oStruNKQ, cAction, cIDField, xValue | PreValNKQ( oStruNKQ, cAction, cIDField, xValue) } )
	oModel:AddGrid( "NKRUNICO", "NKQUNICO", oStruNKR )

	oModel:SetRelation( "NKRUNICO", { { "NKR_FILIAL", "xFilial( 'NKQ' )" }, { "NKR_CODTSE", "NKQ_CODTSE" }, { "NKR_ITETSE", "NKQ_ITETSE" } }, NKR->(IndexKey(1)))
	oModel:SetPrimaryKey( {"NKQ_FILIAL", "NKQ_CODTSE" , "NKQ_ITETSE"} )

	oModel:SetOptional( "NKRUNICO", .t. )
	oModel:GetModel( "NKRUNICO" ):SetDelAllLine( .t. )
	oModel:GetModel( "NKRUNICO" ):SetUniqueLine( { "NKR_ITEDES" } )

	oModel:GetModel( "NKQUNICO" ):SetDescription( STR0010 ) //"Dados do Item da Tabela"
	oModel:GetModel( "NKRUNICO" ):SetDescription( STR0012 ) //"Tarifa por Resultado Análise"

Return( oModel )

/*/{Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina
@type function
@author Equipe Agroindustria
@since 08/06/2010
@return object, Objeto da view
/*/
Static Function ViewDef()

	Local oStruNKQ	:= FWFormStruct( 2, "NKQ" )
	Local oStruNKR 	:= FWFormStruct( 2, "NKR" )
	Local oModel   	:= FWLoadModel( "OGA135I" )
	Local oView    	:= FWFormView():New()
		
	oStruNKR:RemoveField( "NKR_CODTSE" )
	oStruNKR:RemoveField( "NKR_ITETSE" )
	
	oView:SetModel( oModel )
	oView:AddField( "VIEW_NKQ", oStruNKQ, "NKQUNICO" )
	oView:AddGrid ( "VIEW_NKR", oStruNKR, "NKRUNICO" )
	
	oView:AddIncrementField('VIEW_NKR','NKR_ITEDES')

	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 50, "TELANOVA" )
	oView:CreateHorizontalBox( "INFERIOR" , 50, "TELANOVA" )

	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", STR0012) //"Tarifa por Resultado Análise"
	oView:CreateHorizontalBox( "PASTA_NKR", 100, , , "GRADES", "PASTA01" )

	oView:SetOwnerView( "VIEW_NKQ", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NKR", "PASTA_NKR" )

	oView:EnableTitleView( "VIEW_NKQ" )
	oView:EnableTitleView( "VIEW_NKR" )

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/*/{Protheus.doc} OGA135IWHEN
Função para When de campo, habilitando ou bloqueando a edição do campo
@type function
@author Bruna Rocio
@since 22/10/2014 
@return Logical, .T. 
/*/
Function OGA135IWHEN( )
	Local oStruNKR := FWFormStruct( 2 , 'NKR')

	If NKQ->( NKQ_TIPCOB ) == '1' //
		oStruNKR:SetProperty( "NKR_VALTAR", MVC_VIEW_CANCHANGE, .f.)
		oStruNKR:SetProperty( "NKR_PERRET", MVC_VIEW_CANCHANGE, .t.)
	Else
		oStruNKR:SetProperty( "NKR_VALTAR", MVC_VIEW_CANCHANGE, .t.)
		oStruNKR:SetProperty( "NKR_PERRET", MVC_VIEW_CANCHANGE, .f.)
	Endif	
	
Return( .t. )

/*/{Protheus.doc} PosModelo
Função de pós-validação do modelo, equilave ao "TUDOOK", invocado antes da persistência dos dados para validar o model.
@type function
@author Bruna Fagundes Rocio
@since 213/12/2014
@param oModel, object, objeto de Model 
@return Logical, .T. ou .F.
/*/
Static Function PosModelo( oModel )
	Local lRetorno := .T.
	Local cFatGer := oModel:GetValue( "NKQUNICO", "NKQ_FATGER" )
	Local cPerCob := 	oModel:GetValue( "NKQUNICO", "NKQ_PERCOB" )
	Local cPeparc := 	oModel:GetValue( "NKQUNICO", "NKQ_PEPARC" )

	If cFatGer = '2' .And. cPerCob <> '0' .And. cPeparc = '2'
		Help(, , "Ajuda", , STR0013, 1, 0 )
		AGRHelp(STR0013, STR0014, STR0015)
		lRetorno := .F.
	Endif 

Return ( lRetorno )

/*/{Protheus.doc} PreValNKQ
Função de pré-validação do submodelo, invocado quando há uma tentativa de atribuição de valores
@type function
@version P12
@author claudineia.reinert
@since 28/10/2021
@param oFieldModel, object, objeto do formField
@param cAction, character, identificação da ação
@param cIDField, character, identificação do campo que está sofrendo a atribuição
@param xValue, variant, valor que está sendo atribuido ao campo
@return Logical, .T. ou .F.
/*/
Static Function PreValNKQ( oFieldModel, cAction, cIDField, xValue )
	Local lRetorno := .T.
	Local cFatGer := oFieldModel:GetValue( "NKQ_FATGER" )
	Local cPerCob := oFieldModel:GetValue( "NKQ_PERCOB" )
	Local cPeparc := oFieldModel:GetValue( "NKQ_PEPARC" )

	If cAction == "SETVALUE" .and. cIDField $ "NKQ_FATGER|NKQ_PERCOB|NKQ_PEPARC"
		If cIDField == "NKQ_FATGER"
			cFatGer := xValue
		elseIf cIDField == "NKQ_PERCOB"
			cPerCob := xValue
		elseIf cIDField == "NKQ_PEPARC"
			cPeparc := xValue
		EndIF
		If cFatGer = '2' .And. cPerCob <> '0' .And. cPeparc = '2'
			AGRHelp(STR0013, STR0014, STR0015)
			lRetorno := .F.
		Endif 
	EndIf

Return ( lRetorno )

