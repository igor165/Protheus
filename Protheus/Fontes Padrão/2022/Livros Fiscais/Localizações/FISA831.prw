#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA831.CH"

Function FISA831()

	Private oBrowse // RECEBE O BROWSE.
	Private aRotina := MenuDef() // RECEBE AS ROTINAS DO MENU.
	
	dbSelectArea("NJU")
	// CRIA O OBJETO DO BROWSE 
	oBrowse := FWMBrowse():New()
	// ALIAS DA TABELA
	oBrowse:SetAlias("NJU")
	// NOME DO FONTE ONDE ESTA A FUNÇÃO MENUDEF.
	oBrowse:SetMenuDef("FISA831")
	// DESCRIÇÃO DA TELA
	oBrowse:SetDescription(STR0001) //"Cosechas" 
	//Ativa o Browse
	oBrowse:Activate()

Return Nil


Static Function MenuDef()
// Genera un Menu Estandar en MVC sin Necesidad de aRotina.
Return FWMVCMenu( "FISA831" ) 

Static Function ModelDef()
	Local oStruNJU := FWFormStruct( 1, "NJU" )	
	Local oModel	
	//--- Objeto Constructor del Modelo de Datos
	oModel := MPFormModel():New( "FISA831M")//, { | oMdl | CTBA092PRE( oMdl ) } , { | oMdl | CTBA092POS( oMdl ) },/*bCommit*/,/*bCancel*/ )
	//--- Agrega un Modelo para la captura de datos
	oModel:AddFields( "NJUMASTER", /*es el encabezado*/, oStruNJU )
	//--- Descripción del Modelo de Datos
	oModel:SetDescription( STR0001) //"Cosechas" 
	//--- Descripción de los componente del Modelo de Datos
	oModel:GetModel( "NJUMASTER" ):SetDescription( STR0001 ) //"Cosechas" 
	oModel:SetPrimaryKey( { "NJUMASTER", "NJU_FILIAL","NJU_CODSAF" } )
Return oModel
  

Static Function ViewDef()
	Local oModel   := FWLoadModel( "FISA831" )
	Local oStruNJU := FWFormStruct( 2, "NJU")
	Local oView := Nil
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEW_NJU", oStruNJU, "NJUMASTER" )
	oView:CreateHorizontalBox( "PANTALLA" , 100 )
	oView:SetOwnerView( "VIEW_NJU", "PANTALLA" )
Return oView