#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU09T07.CH"

/*/{Protheus.doc} RU09T07
Dummy file for compatibility with the protheus localization rules

@type function
@author Artem Kostin
@since March|2020
/*/
Function RU09T07RUS()
	RU09T07()
Return

Static Function BrowseDef()
Return FWLoadBrw("RU09T07")

Static Function MenuDef()
Return FwLoadMenuDef("RU09T07")

Static Function ModelDef()
Return FwLoadModel("RU09T07")

Static Function ViewDef()
Return FwLoadView("RU09T07")
