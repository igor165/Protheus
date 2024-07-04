#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA830.CH"

Function FISA830()

	Private oBrowse // RECEBE O BROWSE.
	Private aRotina := MenuDef() // RECEBE AS ROTINAS DO MENU.
	
	dbSelectArea("NJA")
	// CRIA O OBJETO DO BROWSE 
	oBrowse := FWMBrowse():New()
	// ALIAS DA TABELA
	oBrowse:SetAlias("NJA")
	// NOME DO FONTE ONDE ESTA A FUNÇÃO MENUDEF.
	oBrowse:SetMenuDef("FISA830")
	// DESCRIÇÃO DA TELA
	oBrowse:SetDescription(STR0001) //"Certificados" 
	
	oBrowse:AddLegend( "NJA_STACER == 'ED'"						   ,'GREEN' ,STR0003) //Enviar Certificação 
	oBrowse:AddLegend( "NJA_STACER == 'AC'"						   ,'RED'   ,STR0004) //Certificada
	oBrowse:AddLegend( "NJA_STACER == 'AN'"						   ,'ORANGE',STR0005) //Anulada
	oBrowse:AddLegend( "NJA_STACER == 'AC' .And. NJA_STALIQ == '1'",'BLUE'  ,STR0006) //Liquidado Parcialmente
	oBrowse:AddLegend( "NJA_STACER == 'AC' .And. NJA_STALIQ != '2'",'GRAY'  ,STR0007) //Liquidado Total
	
	//Ativa o Browse
	oBrowse:Activate()

Return Nil


Static Function MenuDef()
// Genera un Menu Estandar en MVC sin Necesidad de aRotina.
Return FWMVCMenu( "FISA830" ) 

Static Function ModelDef()
	Local oStruNJA := FWFormStruct( 1, "NJA" )	
	Local oModel	
	//--- Objeto Constructor del Modelo de Datos
	oModel := MPFormModel():New( "FISA830M")
	//--- Agrega un Modelo para la captura de datos
	oModel:AddFields( "NJAMASTER", /*es el encabezado*/, oStruNJA )
	//--- Descripción del Modelo de Datos
	oModel:SetDescription( STR0001) //"Certificados" 
	//--- Descripción de los componente del Modelo de Datos
	oModel:GetModel( "NJAMASTER" ):SetDescription( STR0001 ) //"Certificados" 
	oModel:SetPrimaryKey( { "NJAMASTER", "NJA_FILIAL","NJA_CODCET" } )
Return oModel
  

Static Function ViewDef()
	Local oModel   := FWLoadModel( "FISA830" )
	Local oStruNJA := FWFormStruct( 2, "NJA")
	Local oView
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEW_NJA", oStruNJA, "NJAMASTER" )
	oView:CreateHorizontalBox( "PANTALLA" , 100 )
	oView:SetOwnerView( "VIEW_NJA", "PANTALLA" )
Return oView