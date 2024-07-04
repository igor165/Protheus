#INCLUDE "Protheus.ch"
#INCLUDE "RU07T04.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T04
Types of Attendance Registration File (Russia)

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T04RUS()
	Local oBrowse As Object

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
	Local oBrowse As Object

	oBrowse := FWLoadBrw("RU07T04")

Return oBrowse


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model definition

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
	Local oModel As Object
		
	oModel := FwLoadModel("RU07T04")

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View definition

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
	Local oModel As Object
	Local oView As Object
		
	oView := FWLoadView("RU07T04")

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

	Local aRotina := FWLoadMenuDef("RU07T04")

Return aRotina