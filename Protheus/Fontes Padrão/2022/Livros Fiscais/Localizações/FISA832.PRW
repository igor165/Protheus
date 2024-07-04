#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA832.CH"

Function FISA832()

	Private oBrowse // RECEBE O BROWSE.
	Private aRotina := MenuDef() // RECEBE AS ROTINAS DO MENU.
	
	dbSelectArea("FR8")
	// CRIA O OBJETO DO BROWSE 
	oBrowse := FWMBrowse():New()
	// ALIAS DA TABELA
	oBrowse:SetAlias("FR8")
	// NOME DO FONTE ONDE ESTA A FUNÇÃO MENUDEF.
	oBrowse:SetMenuDef("FISA832")
	// DESCRIÇÃO DA TELA
	oBrowse:SetDescription(STR0001) //"Cosechas" 
	//Ativa o Browse
	oBrowse:Activate()

Return Nil


Static Function MenuDef()
// Genera un Menu Estandar en MVC sin Necesidad de aRotina.
Return FWMVCMenu( "FISA832" ) 

Static Function ModelDef()
	Local oStruFR8 := FWFormStruct( 1, "FR8" )	
	Local oModel	
	//--- Objeto Constructor del Modelo de Datos
	oModel := MPFormModel():New( "FISA832M")//, { | oMdl | CTBA092PRE( oMdl ) } , { | oMdl | CTBA092POS( oMdl ) },/*bCommit*/,/*bCancel*/ )
	//--- Agrega un Modelo para la captura de datos
	oModel:AddFields( "FR8MASTER", /*es el encabezado*/, oStruFR8 )
	//--- Descripción del Modelo de Datos
	oModel:SetDescription( STR0001) //"Cosechas" 
	//--- Descripción de los componente del Modelo de Datos
	oModel:GetModel( "FR8MASTER" ):SetDescription( STR0001 ) //"Cosechas" 
	oModel:SetPrimaryKey( { "FR8MASTER", "FR8_FILIAL","FR8_CODIGO" } )
Return oModel
  

Static Function ViewDef()
	Local oModel   := FWLoadModel( "FISA832" )
	Local oStruFR8 := FWFormStruct( 2, "FR8")
	Local oView := Nil
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEW_FR8", oStruFR8, "FR8MASTER" )
	oView:CreateHorizontalBox( "PANTALLA" , 100 )
	oView:SetOwnerView( "VIEW_FR8", "PANTALLA" )
Return oView