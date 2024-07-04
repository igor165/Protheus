#INCLUDE "Protheus.ch"
#INCLUDE "GPEA370.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEA370RUS 
Positions Register File (Russia)

@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Function GPEA370RUS(xRotAuto)
	Local oBrowse as object

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local oBrowse as object

	oBrowse := FWLoadBrw("GPEA370")
Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina :=  FWLoadMenuDef("GPEA370")
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel as object
	
	oModel 	:= FwLoadModel('GPEA370')
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 	as object
	Local oView		as object
	
	oView	:= FWLoadView("GPEA370")
Return oView
//Checked and merged by AS for Russia_R4 * *
// Russia_R5
