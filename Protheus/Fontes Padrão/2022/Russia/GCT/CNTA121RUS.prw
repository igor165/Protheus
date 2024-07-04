#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA121RUS
Contract Measurement (Russia)

@author Flavio Lopes Rasta
@since 05/06/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Function CNTA121RUS()
Local oBrowse as object

Private aRotina := FWLoadMenuDef("CNTA121")

oBrowse := BrowseDef()
oBrowse:Activate()

FWSetShowKeys(.T.)
SetKey( VK_F12 , Nil )

CN121Limpa()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Flavio Lopes Rasta
@since 05/06/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("CNTA121")

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author Flavio Lopes Rasta
@since 05/06/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("CNTA121")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition

@author Flavio Lopes Rasta
@since 05/06/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel as object

oModel 	:= FwLoadModel('CNTA121')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition

@author Flavio Lopes Rasta
@since 05/06/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		as object

oView	:= FWLoadView("CNTA121")

Return oView

// Russia_R5
