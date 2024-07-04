#INCLUDE "AGRA810.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} AGRA810
Cadastro de Cultivares

@author Cleber Maldonado
@since 14/01/2013
/*/
//--------------------------------------------------------------
Function AGRA810()
	Local aArea 	:= GetArea()
	Local oBrowse 	:= Nil

	//Instancia o objeto Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('NP4')
	oBrowse:SetDescription( STR0001 )

	//Ativa o Browse
	oBrowse:Activate()

	RestArea(aArea)
Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro de Cultivares

@author Cleber Maldonado
@since 14/01/2013
/*/
//--------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruNP4 	:= FwFormStruct( 1, "NP4" )//Cadastro de Cultivares
	Local oStruNP0 	:= FWFormStruct(1,"NP0")

// Instancia o modelo de dados
	oModel := MpFormModel():New( 'AGRA810',/*bPre*/,/*{ |oModel| }*/, , /*bCancel*/ )
	oModel:SetDescription( STR0002 )


//remove campos
	oStruNP0:RemoveField( "NP0_CULTRA" )
	oStruNP0:RemoveField( "NP0_CTVAR" )
// Adiciona estrutura de campos no modelo de dados
	oModel:AddFields( 'NP4MASTER', /*cOwner*/, oStruNP4 )
	oModel:SetDescription( STR0003 )

// Seta chave primaria
	oModel:SetPrimaryKey( {"NP4_FILIAL","NP4_CODIGO"} )

//Create the grid with the sub item
	oModel:AddGrid( "NP0GRID", "NP4MASTER", oStruNP0 )
	oModel:GetModel('NP0GRID'):SetDescription('Classes da Cultivares')
//Set the relationship between  to both
	oModel:SetRelation( 'NP0GRID', { { 'NP0_FILIAL', 'xFilial( "NP0" )' }, { 'NP0_CTVAR', 'NP4_CODIGO' } }, NP0->( IndexKey( 1 ) ) )

	oModel:GetModel( "NP0GRID" ):SetOptional( .T. )


Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro de Cultivares

@author Cleber Maldonado
@since 14/01/2013
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	 := FwLoadModel( "AGRA810" )
	Local oStruNP4 := FwFormStruct( 2, "NP4" )//Cadastro de Culturas
	Local oStruNP0 := FWFormStruct( 2, 'NP0' )
// Instancia modelo de visualização
	oView := FwFormView():New()

// Seta o modelo de dados
	oView:SetModel( oModel )

// Adciona os campos na estrutura do modelo de dados
	oView:AddField("AGRA810_V",oStruNP4,"NP4MASTER")

	oView:AddGrid( "VIEW_NP0", oStruNP0, "NP0GRID" )

	oStruNP0:RemoveField( "NP0_CULTRA" )
	oStruNP0:RemoveField( "NP0_CTVAR" )

	oView:CreateHorizontalBox( "SUPERIOR" , 50)
	oView:CreateHorizontalBox( "INFERIOR" , 50)

	oView:SetOwnerView( "AGRA810_V", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NP0", "INFERIOR" )

	oView:EnableTitleView( "AGRA810_V" )
	oView:EnableTitleView( "VIEW_NP0" )

Return oView


//----------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro de Cultivares

@author Cleber Maldonado
@since 14/01/2013
/*/
//----------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title OemToAnsi(STR0004)		Action 'VIEWDEF.AGRA810' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0005)		Action 'VIEWDEF.AGRA810' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0006)		Action 'VIEWDEF.AGRA810' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0007)		Action 'VIEWDEF.AGRA810' OPERATION 5 ACCESS 0

Return aRotina
