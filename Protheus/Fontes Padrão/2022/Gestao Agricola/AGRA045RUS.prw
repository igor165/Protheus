#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA045.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA045RUS
Warehouses manager (Russia)

@author Victor Guberniev
@since 11/04/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Function AGRA045RUS()

Local oBrowse as object

oBrowse := BrowseDef()

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Victor Guberniev
@since 11/04/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

Local oBrowse as object

oBrowse := FWLoadBrw("AGRA045")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author Victor Guberniev
@since 11/04/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("AGRA045")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definiзгo do modelo de dados
@author 	Victor Guberniev
@since 		11/04/2018
@version 	1.0
@project	MA3
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel as object

oModel 	:= FwLoadModel('AGRA045')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definiзгo do interface
@author 	Victor Guberniev
@since 		11/04/2018
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView		as object

oView	:= FWLoadView("AGRA045")

Return oView



