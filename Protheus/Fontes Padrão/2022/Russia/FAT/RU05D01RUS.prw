#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU05D01.CH"

/*/{Protheus.doc} RU05D01
Dummy file for compatibility with the protheus localization rules

@type function
@author Artem Kostin
@since Jun|2019
/*/
Function RU05D01RUS()
	//(31/10/19): Series of documents
	SetKey(VK_F12, {|| AcessaPerg("RU05D01",.T.)})
	RU05D01()
Return

Static Function BrowseDef()
Return FWLoadBrw("RU05D01")

Static Function MenuDef()
Return FwLoadMenuDef("RU05D01")

Static Function ModelDef()
Return FwLoadModel("RU05D01")

Static Function ViewDef()
Return FwLoadView("RU05D01")