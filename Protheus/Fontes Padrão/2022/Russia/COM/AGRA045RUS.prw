#INCLUDE "PROTHEUS.CH"



//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA045RUS

Main function

author:		Vadim Ivanov
since: 		20/05/2019
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function AGRA045RUS()
Local oBrowse as Object

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

The initialization of a oBrowse object

author:		Vadim Ivanov
since: 		20/05/2019
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Static Function BrowseDef()
Local oBrowse as Object

	oBrowse := FWLoadBrw("AGRA045")

Return oBrowse


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

The creation of the array to show a user menu

author:		Vadim Ivanov
since: 		20/05/2019
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Static Function MenuDef()
Local aRotina as Array

	aRotina := {}
	aRotina := FwLoadMenu("AGRA045")

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Initializing the localization model from the parent program

author:		Vadim Ivanov
since: 		20/05/2019
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Static Function ModelDef()
Local oModel as Object

	oModel := FWLoadModel("AGRA045")

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Initializing the localization view object from the parent program

author:		Vadim Ivanov
since: 		20/05/2019
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Static Function ViewDef()
Local oView as Object

	oView := FWLoadView("AGRA045")

Return oView