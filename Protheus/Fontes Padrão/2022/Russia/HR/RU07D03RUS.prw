#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ru07d03.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D03
Residence Status Register File 

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D03RUS()

Local oBrowse 	as object
Local cRD0 		as Character
Local cF4Z 		as Character
Local aParam	
Local cFilt		as Character	

aParam  := {}

cRD0 := FWModeAccess( "RD0", 1) + FWModeAccess( "RD0", 2) + FWModeAccess( "RD0", 3)
cF4Z := FWModeAccess( "F4Z", 1) + FWModeAccess( "F4Z", 2) + FWModeAccess( "F4Z", 3)

If cRD0 != cF4Z
	// "Mode Access betwen tables People/Participants (RD0) and Residence Status (cF4Z) must be the same."
	// "Edit Mode Access through Configurator Module. Tables RD0 and cF4Z."
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

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()

Local oBrowse as object

oBrowse := FWLoadBrw("RU07D03")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
	
Local aRotina :=  FWLoadMenuDef("RU07D03")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()

Local oModel as object
	
oModel 	:= FwLoadModel("RU07D03")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author ekaterina.moskovkira
@since 09/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()

Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU07D03")

Return oView
//Checked and merged by AS for Russia_R4 * *