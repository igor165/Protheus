#INCLUDE "Protheus.ch"
#INCLUDE "RU07T07.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T07
Action of Vacation Register File 

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T07RUS()
Local aCoors  		as Array
Local cIdBrowse 	as Character
Local cIdGrid 		as Character
Local oPanelUp 		as Object
Local oPanelDown 	as Object
Local oTela 		as Object
Local oRelacF4E 	as Object
Local 	aParam
Local 	cFilt		as Character	

Private oDlgPrinc	as Object
Private oBrowseUp	as Object
Private oBrowseDwn	as Object

aParam  := {}
aCoors	:= FWGetDialogSize( oMainWnd )

Define MsDialog oDlgPrinc Title OemToAnsi( STR0001 )  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel  //"Action of Vacation"

// Create container where panels will be created
oTela     := FWFormContainer():New( oDlgPrinc )
cIdBrowse := oTela:CreateHorizontalBox( 50 )
cIdGrid   := oTela:CreateHorizontalBox( 50 )

If PERGUNTE ("GPEA010RUS", .T.)
	AAdd( aParam, UPPER( alltrim( MV_PAR01 ) ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR02 ) ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR03 ) ) )
	AAdd( aParam, DTOS( MV_PAR04 ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR05 ) ) )
EndIf

cFilt := ActFiltRUS( aParam )

oTela:Activate( oDlgPrinc, .F. )

// Create panels where browses will be created
oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
oPanelDown  := oTela:GeTPanel( cIdGrid )

// FWmBrowse Superior: Employees
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )   
oBrowseUp:SetDescription(STR0002 ) //"Employees"
oBrowseUp:SetMenuDef( 'FAKE' )
oBrowseUp:SetAlias( 'SRA' )
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetCacheView (.F.) 
oBrowseUp:ExecuteFilter(.T.)
oBrowseUp:SetFilterDefault(cFilt)

// Set caption for Employees
oBrowseUp:AddLegend( "RA_MSBLQL == '2'", "GREEN", STR0014) 	    // "Active"
oBrowseUp:AddLegend( "RA_MSBLQL == '1'", "RED" ,  STR0015 ) 	// "Unactive"

oBrowseUp:Activate()

// FWmBrowse Inferior: Vacation items
oBrowseDwn:= BrowseDef()
oBrowseDwn:SetOwner( oPanelDown )

// Set relationship between panels
oRelacF4E:= FWBrwRelation():New()
oRelacF4E:AddRelation( oBrowseUp  , oBrowseDwn , { { 'F4E_FILIAL', 'RA_FILIAL' }, { 'F4E_CODE' , 'RA_CODUNIC'  }, { 'F4E_MAT' , 'RA_MAT'  } } )
oRelacF4E:Activate()

oBrowseDwn:Activate()

oBrowseUp:Refresh()
oBrowseDwn:Refresh()

Activate MsDialog oDlgPrinc Center

	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse as object

// FWmBrowse Inferior: Vacation items
oBrowse:= FWMBrowse():New()
oBrowse:SetDescription(STR0003)	//"Vacation items"
oBrowse:SetMenuDef( 'RU07T07' )
oBrowse:DisableDetails()
oBrowse:SetAlias( 'F4E' )
oBrowse:SetProfileID( '2' )
oBrowse:ForceQuitButton()	
oBrowse:SetCacheView (.F.)
oBrowse:ExecuteFilter(.T.)
oBrowse:AddLegend( "F4E_STATUS $ '1*2'" 	, "RED" 	, STR0004 ) 		//"Pending Vacation"  
oBrowse:AddLegend( "F4E_STATUS $ '3*4*5'" 	, "BLUE" 	, STR0005 ) 	//"Closed Vacation"	

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("RU07T07")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object
	
oModel 	:= FwLoadModel("RU07T07")
oModel	:SetDescription( STR0001 ) //"Action of Vacation"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 18/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU07T07")

Return oView

//Checked and merged by AS for Russia_R4 * * * **
// Russia_R5
