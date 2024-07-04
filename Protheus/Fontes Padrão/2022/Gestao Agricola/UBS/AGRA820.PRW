#INCLUDE "AGRA820.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------
/*{Protheus.doc} AGRA820
Cadastro de Peneiras

@author Cleber Maldonado
@since 14/01/2013
**/
//--------------------------------------------------------------
Function AGRA820()
	Local aArea 	:= GetArea()
	Local oBrowse 	:= Nil

	//Instancia o objeto Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('NP7')
	oBrowse:SetDescription( STR0001 )

	//Ativa o Browse
	oBrowse:Activate()

	RestArea(aArea)
Return()

//--------------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro de Peneiras

@author Cleber Maldonado
@since 14/01/2013
**/
//--------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruNP7 	:= FwFormStruct( 1, "NP7" )//Cadastro de Peneiras

	// Instancia o modelo de dados
	oModel := MpFormModel():New( 'AGRA820',/*bPre*/,/*{ |oModel| }*/, , /*bCancel*/ )
	oModel:SetDescription( STR0002 )

	// Adiciona estrutura de campos no modelo de dados
	oModel:AddFields( 'NP7MASTER', /*cOwner*/, oStruNP7 )
	oModel:SetDescription( STR0003 )

	// Seta chave primaria
	oModel:SetPrimaryKey( {"NP7_FILIAL","NP7_CODIGO"} )
Return oModel

//-----------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro de Peneiras

@author Cleber Maldonado
@since 14/01/2013
**/
//-----------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA820" )
	Local oStruNP7 	:= FwFormStruct( 2, "NP7" )//Cadastro de Peneiras
	// Instancia modelo de visualização
	oView := FwFormView():New()

	// Seta o modelo de dados
	oView:SetModel( oModel )

	// Adciona os campos na estrutura do modelo de dados
	oView:AddField( 'VIEW_NP7', oStruNP7, 'NP7MASTER' )

	// Cria o box
	oView:CreateHorizontalBox( 'TOTAL', 100 )

	// Seta o owner
	oView:SetOwnerView( 'VIEW_NP7', 'TOTAL' )
Return oView

//----------------------------------------------------------------
/*{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro de Peneiras

@author Cleber Maldonado
@since 14/01/2013
**/
//----------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title OemToAnsi(STR0004)		Action 'VIEWDEF.AGRA820' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0005)		Action 'VIEWDEF.AGRA820' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0006)		Action 'VIEWDEF.AGRA820' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title OemToAnsi(STR0007)		Action 'VIEWDEF.AGRA820' OPERATION 5 ACCESS 0
Return aRotina