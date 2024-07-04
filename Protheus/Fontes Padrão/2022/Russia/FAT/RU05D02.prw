#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU05D01.CH"

/*/{Protheus.doc} RU05D02
Auxiliary Model for Commit in Tables F5Y and F5Z

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU05D02()
	//Compatibility
Return

/*/{Protheus.doc} ModelDef
Model Definition

@type function
@author Alison Kaique
@since Apr|2019
@return oModel, object, Model's Object
/*/
Static Function ModelDef()
	Local oModel		        As Object
	Local oStruF5Y	            As Object
	Local oStruF5Z_After        As Object

	oModel	:= MPFormModel():New("RU05D02", /*Pre-Validation*/, /*Pos-Validation*/, /*bCommit*/, /*Cancel*/)
	oModel:SetDescription(STR0009) //"Commercial Invoice Correction"

	oStruF5Y			:= FWFormStruct(1, "F5Y")
	oStruF5Z_After   	:= FWFormStruct(1, "F5Z")

	oModel:AddFields("F5YMASTER", , oStruF5Y)
	oModel:AddGrid("F5ZDETAIL_AFTER", "F5YMASTER", oStruF5Z_After)

	oModel:SetRelation("F5ZDETAIL_AFTER", {{"F5Z_FILIAL", "FWxFilial('F5Z')" }, {"F5Z_UIDF5Y", "F5Y_UID" }}, F5Z->(IndexKey(1)))
Return oModel