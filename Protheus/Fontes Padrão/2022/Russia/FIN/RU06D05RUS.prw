#include 'protheus.ch'
#include 'parmtype.ch' 
//#include "RU06D04.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D05RUS
Payment Order Routine

@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
function RU06D05RUS()
Local oBrowse as object

// Included because of the MSDOCUMENT routine, 
//the MVC does not need any private variables 
//but MSDOCUMENT needs the arotina and cCastro variables
Private cCadastro as Character
Private aRotina as Array

aRotina		:= {}
oBrowse := BrowseDef()
oBrowse:Activate()
	
return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef 
Browse definition.

@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("RU06D05")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina	AS ARRAY
aRotina :=  FWLoadMenuDef("RU06D05")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel as object
	
oModel 	:= FwLoadModel("RU06D05")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel 	as object
Local oView		as object
	
oView	:= FWLoadView("RU06D05")

Return oView

Function RU06D0513_Brw(oModel)
Local lRet:= .T. 

lRet := !(FwFldGet("F49_PAYTYP") == '0' )

If !lRet
	oView := FwViewActive()
    oView:lModify := .F. 
    oView:oModel:lModify := .F. 
    oView:BUTTONCANCELACTION()
Else
    RU06D0408_FillVirtFilial(oModel)
Endif 
Return (lRet)
// Russia_R5
