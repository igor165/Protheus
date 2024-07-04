#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07D05.ch" 

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D05
Family Members Register File 

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D05RUS()
Local oBrowse as object
Local cRD0 as Character
Local cSRB as Character
Local aParam	
Local cFilt		as Character	

aParam  := {}

cRD0 := FWModeAccess( "RD0", 1) + FWModeAccess( "RD0", 2) + FWModeAccess( "RD0", 3)
cSRB := FWModeAccess( "SRB", 1) + FWModeAccess( "SRB", 2) + FWModeAccess( "SRB", 3)

If cRD0 != cSRB
	// "Mode Access betwen tables People/Participants (RD0) and Family Members (SRB) must be the same."
	// "Edit Mode Access through Configurator Module. Tables RD0 and SRB."
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

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("RU07D05")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("RU07D05")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object
	
oModel 	:= FwLoadModel("RU07D05")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author anastasiya.kulagina
@since 05/03/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU07D05")

Return oView

//Checked and merged by AS for Russia_R4 * * *