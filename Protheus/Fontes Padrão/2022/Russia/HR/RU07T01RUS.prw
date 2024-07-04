#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07T01.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T01
Employment Book Register File 

@author raquel.andrade
@since 02/02/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T01RUS()
Local oBrowse as object
Local cRD0 as Character
Local cF4P as Character
Local cF4O as Character

cRD0 := FWModeAccess( "RD0", 1) + FWModeAccess( "RD0", 2) + FWModeAccess( "RD0", 3)
cF4P := FWModeAccess( "F4P", 1) + FWModeAccess( "F4P", 2) + FWModeAccess( "F4P", 3)
cF4O := FWModeAccess( "F4O", 1) + FWModeAccess( "F4O", 2) + FWModeAccess( "F4O", 3)

If cRD0 != cF4O .Or. cRD0 != cF4P 
	MsgInfo( STR0014 + CRLF + CRLF + ; 		//"Mode Access betwen tables People/Participants (RD0) and folowing tables must be tha same:"
	 		 STR0015  + CRLF +;						//"F4O-Employment Book"
	 		 STR0016 + CRLF + CRLF +;				//"F4P-Length Of Service"
	 		 STR0017 ) 		//"Edit Mode Access through Configurator Module."
	Return (.F.)
EndIf

oBrowse := BrowseDef()
oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author raquel.andrade
@since 02/02/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("RU07T01")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 02/02/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("RU07T01")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 02/02/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object
	
oModel 	:= FwLoadModel("RU07T01")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 02/02/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU07T01")

Return oView

//Checked and merged by AS for Russia_R4 * * *
// Russia_R5
