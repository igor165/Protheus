#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07D01.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D01
Personal Data Register File

@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D01RUS()
Local oBrowse as object
Local cRD0 as Character
Local cF4J as Character
Local cF4M as Character
Local cF4L as Character
Local cF4H as Character
Local cF4G as Character
Local aParam	
Local cFilt		as Character	

aParam  := {}

cRD0 := FWModeAccess( "RD0", 1) + FWModeAccess( "RD0", 2) + FWModeAccess( "RD0", 3)
cF4J := FWModeAccess( "F4J", 1) + FWModeAccess( "F4J", 2) + FWModeAccess( "F4J", 3) 
cF4M := FWModeAccess( "F4M", 1) + FWModeAccess( "F4M", 2) + FWModeAccess( "F4M", 3)
cF4L := FWModeAccess( "F4L", 1) + FWModeAccess( "F4L", 2) + FWModeAccess( "F4L", 3)
cF4H := FWModeAccess( "F4H", 1) + FWModeAccess( "F4H", 2) + FWModeAccess( "F4H", 3)
cF4G := FWModeAccess( "F4G", 1) + FWModeAccess( "F4G", 2) + FWModeAccess( "F4G", 3)

If cRD0 != cF4J .Or. cRD0 != cF4M .Or. cRD0 != cF4L .Or. cRD0 != cF4H  .Or. cRD0 != cF4G
	MsgInfo( STR0013 + CRLF + CRLF + ; 		//"Mode Access betwen tables People/Participants (RD0) and folowing tables must be tha same:"
	 		 STR0015 + CRLF +;				//"F4J-Marital Status"
	 		 STR0016 + CRLF +;				//"F4M-SNILS"
	 		 STR0017 + CRLF + ; 			//"F4L-Education"
	 		 STR0018 + CRLF + ;				//"F4H-Military Services"
			 STR0023 + CRLF + CRLF +; 		//"F4G-Documents"	
	 		 STR0014 ) 						//"Edit Mode Access through Configurator Module."
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
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("RU07D01")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("RU07D01")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object
	
oModel 	:= FwLoadModel("RU07D01")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 19/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU07D01")

Return oView