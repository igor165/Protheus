#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#include "FINA884.CH"


Function FINA884L()
	Local oBrowse := FwLoadBrw("FINA884L")
	oBrowse:Activate()
Return (Nil)

Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()
	oBrowse:SetAlias("A1N")
	oBrowse:SetDescription(STR0006) // "Search"
	oBrowse:SetMenuDef("FINA884L")	
Return (oBrowse)


Static Function MenuDef()
	Local aRotina := FwMVCMenu("FINA884L")
Return (aRotina)


Static Function ModelDef()
	Local oModel   := MPFormModel():New("FINA884L")//MPFORMMODEL():New(<cID >, <bPre >, <bPost >, <bCommit >, <bCancel >)
	Local oStruA1N := FwFormStruct(1, "A1N")
	
	Local aRelation:={}

	oModel:AddFields("A1NMASTER", Nil        , oStruA1N, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	// oModel:SetPrimaryKey({"A1N_COD","A1N_AGENCIA","A1N_NOMEAGE"})

	oModel:SetDescription((FwSX2Util():GetX2Name("A1N")))
	oModel:GetModel("A1NMASTER"):SetDescription(FwSX2Util():GetX2Name("A1N"))


Return (oModel)

Static Function ViewDef()
	Local oView    := FwFormView():New()
	Local oStruA1N := FwFormStruct(2, "A1N")
	Local oModel    := FwLoadModel("FINA884L")

	oView:SetModel(oModel)

	oView:AddField("VIEW_A1N", oStruA1N, "A1NMASTER")

	oView:CreateHorizontalBox("SUPERIOR", 100)
	oView:CreateVerticalBox( 'SUPERIORESQ', 100, 'SUPERIOR' )


	oView:SetOwnerView("VIEW_A1N", "SUPERIORESQ")
Return (oView)


Function A884Log()

	A1N->(RecLock("A1N",.T.))
	A1N->A1N_FILIAL	:=FwxFilial("A1N")
	A1N->A1N_DATA	:=MsDate()
	A1N->A1N_HORA	:=Time()
	A1N->A1N_USER	:=UsrRetName(__cUserID) 

	A1N->(MsUnLock())

Return
