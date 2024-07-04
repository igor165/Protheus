#INCLUDE "Protheus.ch"
#INCLUDE "RU07D09.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D09
Types of Attendance Registration File 

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D09()
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

	oBrowse	:= FWmBrowse():New()
	oBrowse:SetAlias("SP9")
	oBrowse:SetDescription(STR0001)  
	oBrowse:DisableDetails()
	oBrowse:SetCacheView(.F.)

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
	Local oModel := MPFormModel():New("RU07D09")
	Local oStructSP9 := FWFormStruct(1, "SP9", {|cField| "|"+ AllTrim(cField) + "|" $ "|P9_FILIAL|P9_CODIGO|P9_DESC|P9_MIN|P9_MAX|P9_DTCHK|"})

	oModel:AddFields("RU07D09_MSP9", /*cOwner*/, oStructSP9)
	oModel:SetDescription(STR0001)

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
	Local oView As Object
	Local oModel As Object
	Local oStructSP9 As Object
	
	oStructSP9 := FWFormStruct(2, "SP9", {|cField| "|"+ AllTrim(cField) + "|" $ "|P9_FILIAL|P9_CODIGO|P9_DESC|P9_MIN|P9_MAX|P9_DTCHK|"})
	oStructSP9:SetNoFolder()

	oModel := FWLoadModel("RU07D09")

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("RU07D09_VSP9", oStructSP9, "RU07D09_MSP9")
	oView:CreateHorizontalBox("HorizontalBox", 100)
	oView:SetOwnerView("RU07D09_VSP9", "HorizontalBox")

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
	Local aRotina As Array

	aRotina := {}

	AAdd(aRotina, {STR0004, "VIEWDEF.RU07D09", 0, 2, 0, Nil}) //View
	AAdd(aRotina, {STR0005, "VIEWDEF.RU07D09", 0, 3, 0, Nil}) //Insert
	AAdd(aRotina, {STR0006, "VIEWDEF.RU07D09", 0, 4, 0, Nil}) //Edit

Return aRotina
