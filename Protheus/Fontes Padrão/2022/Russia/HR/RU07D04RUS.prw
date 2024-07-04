#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07D04.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D04
Tax Deductions Register File 

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Function RU07D04RUS()
Local oBrowse	as object
Local cRD0		as Character
Local cF4W		as Character
Local aParam	
Local cFilt		as Character	

aParam  := {}

cRD0 := FWModeAccess( "RD0", 1) + FWModeAccess( "RD0", 2) + FWModeAccess( "RD0", 3)
cF4W := FWModeAccess( "F4W", 1) + FWModeAccess( "F4W", 2) + FWModeAccess( "F4W", 3)

If cRD0 != cF4W
	// "Mode Access betwen tables People/Participants (RD0) and Tax Deductions (F4W) must be the same."
	// "Edit Mode Access through Configurator Module. Tables RD0 and F4W."
	MsgInfo( oEmToAnsi( STR0014 ) + CRLF + CRLF + oEmToAnsi( STR0015 ) )
	Return (.F.)
EndIf

If PERGUNTE ("GPEA010RUS", .T.)
	AAdd( aParam, UPPER( alltrim( MV_PAR01 ) ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR02 ) ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR03 ) ) )
	AAdd( aParam, DTOS( MV_PAR04 ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR05 ) ) )
EndIf

cFilt := ActFiltRUS( aParam )

oBrowse := BrowseDef()
oBrowse:SetFilterDefault(cFilt)

oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("RU07D04")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("RU07D04")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object
	
oModel 	:= FwLoadModel("RU07D04")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 05/12/2017
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU07D04")

Return oView