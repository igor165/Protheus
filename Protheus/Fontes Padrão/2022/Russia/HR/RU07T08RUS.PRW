#INCLUDE "Protheus.ch"
#INCLUDE "RU07T08.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T08
Action of Business Trip Register File 

@author raquel.andrade
@since 05/07/2018
/*/
Function RU07T08RUS()

Local oBrowse	as object
Local cSRA		as Character
Local cF4D		as Character
Local aParam	
Local cFilt		as Character	

aParam  := {}

cSRA := FWModeAccess( "SRA", 1) + FWModeAccess( "SRA", 2) + FWModeAccess( "SRA", 3)
cF4D := FWModeAccess( "F4D", 1) + FWModeAccess( "F4D", 2) + FWModeAccess( "F4D", 3)

If cSRA != cF4D 
	// "Mode Access betwen tables  (SRA) and  (F4D) must be the same."
	// "Edit Mode Access through Configurator Module. Tables SRA and F4D."
	   	MsgInfo( oEmToAnsi( STR0020 ) + CRLF + CRLF + oEmToAnsi( STR0021 ) )  		
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
@since 05/07/2018
/*/
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("RU07T08")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("RU07T08")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function ModelDef()
Local oModel as object
	
oModel 	:= FwLoadModel("RU07T08")
oModel:SetDescription(STR0001) //"Action of Business Trip" 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU07T08")

Return oView