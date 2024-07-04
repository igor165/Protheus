#INCLUDE "Protheus.ch"
#INCLUDE "RU07D10.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMVCDEF.CH"


//--------------------------------------------------------------------
/*/{Protheus.doc} RU07D10
Employee's addresses 

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D10RUS()
Local aCoors  		as Array
Local aParam		as Array
Local cIdBrowse 	as Character
Local cIdGrid 		as Character
Local cEntida		as Character
Local oPanelUp 		as Object
Local oPanelDown 	as Object
Local oTela 		as Object
Local oRelacAGA 	as Object

Private oDlgPrinc	as Object
Private oBrowseUp	as Object
Private oBrowseDwn	as Object

cEntida	:="RD0"

aParam  := {}
aCoors	:= FWGetDialogSize( oMainWnd )

Define MsDialog oDlgPrinc Title OemToAnsi( STR0001 )  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel  //"Action"

// Create container where panels will be created
oTela     := FWFormContainer():New( oDlgPrinc )
cIdBrowse := oTela:CreateHorizontalBox( 50 )
cIdGrid   := oTela:CreateHorizontalBox( 50 )

oTela:Activate( oDlgPrinc, .F. )

// Create panels where browses will be created
oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
oPanelDown  := oTela:GeTPanel( cIdGrid )

// FWmBrowse Superior: Employees
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )   
oBrowseUp:SetDescription(STR0002) //"Employees"
oBrowseUp:SetMenuDef( 'FAKE' )
oBrowseUp:SetAlias( 'RD0' )
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetCacheView (.F.) 

// Set caption for Employees
oBrowseUp:AddLegend( "RD0->RD0_MSBLQL == '2'", 	"GREEN", STR0014) // Active
oBrowseUp:AddLegend( "RD0->RD0_MSBLQL == '1'", 	"RED"  , STR0015 )//Inactive

oBrowseUp:Activate()

// FWmBrowse Inferior: Vacation items
oBrowseDwn:= BrowseDef()
oBrowseDwn:SetOwner( oPanelDown )

// Set relationship between panels
oRelacAGA:= FWBrwRelation():New()
oRelacAGA:AddRelation( oBrowseUp  , oBrowseDwn , {{ 'AGA_ENTIDA', "'"+cEntida+"'" }, { 'AGA_CODENT' , 'RD0_FILIAL'+"+"+'Padr(RD0_CODIGO,(TamSx3("AGA_CODENT")[1])-(TamSx3("RD0_FILIAL")[1]))' } } )
oRelacAGA:Activate()

oBrowseDwn:Activate()

oBrowseUp:Refresh()
oBrowseDwn:Refresh()

Activate MsDialog oDlgPrinc Center

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()

Local oBrowse as object

oBrowse := FWLoadBrw("RU07D10")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("RU07D10")

Return aRotina

//--------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object
Local oRU07D10EVRUS   := RU07D10EVRUS():New()

oModel 	:= FwLoadModel("RU07D10")
oModel	:SetDescription(STR0001) //"Addresses"
oModel:InstallEvent("RU07D10EVRUS",,oRU07D10EVRUS)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author Marina Dubovaya
@since 26/Jul/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU07D10")

Return oView


// Russia_R5
