#include 'protheus.ch'
#include 'parmtype.ch'
#include "RU06D04.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D04
Payment Request Routine

@author natasha
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
function RU06D04RUS()
Local oBrowse as object
Public cOperTp as Character //variable to store the type of operation

// Included because of the MSDOCUMENT routine,
//the MVC does not need any private variables
//but MSDOCUMENT needs the arotina and cCastro variables
Private cCadastro as Character
Private aRotina as ARRAY

cOperTp     := ''
aRotina		:= {}
//cCadastro := STR0001 //"Payment Requests"
oBrowse := BrowseDef()
oBrowse:Activate()

return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author natasha
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse as object



oBrowse := FWLoadBrw("RU06D04")

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author natasha
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina	AS ARRAY
aRotina :=  FWLoadMenuDef("RU06D04")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author natasha
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object

oModel 	:= FwLoadModel("RU06D04")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author natasha
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object

oView	:= FWLoadView("RU06D04")

Return oView

// Russia_R5
