#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#include "FINA884.CH"


Function FINA884P()
	Local oBrowse := FwLoadBrw("FINA884P")
	oBrowse:Activate()
Return (Nil)

Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()
	oBrowse:SetAlias("RVS")
	oBrowse:SetDescription(STR0006) // "Search"
	oBrowse:SetMenuDef("FINA884P")
	oBrowse:AddLegend( "RVS_STATUS==9", "GREEN"   	, STR0024 ) //"Cuentas por Pagar"   Payments
	oBrowse:AddLegend( "RVS_STATUS==1", "YELLOW"	, STR0027 ) // "Cuentas por Cobrar"  Accounts receivable
	oBrowse:AddLegend( "RVS_STATUS==2", "BLUE"  	, STR0026 ) //"Relación Incompleta"
	oBrowse:AddLegend( "RVS_STATUS==0", "RED"   	, STR0025 ) //"Relación Completa"
Return (oBrowse)


Static Function MenuDef()
	Local aRotina := FwMVCMenu("FINA884P")
Return (aRotina)


Static Function ModelDef()
	Local oModel   := MPFormModel():New("FINA884P")//MPFORMMODEL():New(<cID >, <bPre >, <bPost >, <bCommit >, <bCancel >)
	Local oStruRVS := FwFormStruct(1, "RVS")
	Local oStruRVT := FwFormStruct(1, "RVT")
	Local aRelation:={}

	oModel:AddFields("RVSMASTER", Nil        , oStruRVS, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	oModel:AddGrid("RVTDETAIL"  , "RVSMASTER", oStruRVT, /*{ |oModelRVT, nLine, cAction, cField| AA001LPRE(oModelRVT, nLine, cAction, cField)}*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )

	AAdd(aRelation,{"RVT_FILIAL", "FwXFilial('RVT')"})
	AAdd(aRelation,{"RVT_ID", "RVS_ID"})

	oModel:SetRelation("RVTDETAIL",aRelation, RVT->(IndexKey(1)))
	oModel:SetPrimaryKey({"RVS_COD","RVS_AGENCIA","RVS_NOMEAGE"})

	oModel:SetDescription(STR0006)  // "Search"

	// oModel:GetModel('RVSMASTER' ):SetOnlyQuery ( .T. )
	oModel:GetModel("RVSMASTER"):SetDescription(FwSX2Util():GetX2Name("RVS"))

	oModel:GetModel("RVTDETAIL"):SetDescription(FwSX2Util():GetX2Name("RVT"))
	oModel:GetModel('RVTDETAIL'):SetOptional( .T. )



Return (oModel)

Static Function ViewDef()
	Local oView    := FwFormView():New()
	Local oStruRVS := FwFormStruct(2, "RVS")
	Local oStruRVT := FwFormStruct(2, "RVT")
	Local oModel    := FwLoadModel("FINA884P")

	oView:SetModel(oModel)

	oView:AddField("VIEW_RVS", oStruRVS, "RVSMASTER")
	oView:AddGrid("VIEW_RVT", oStruRVT, "RVTDETAIL")
	oView:AddIncrementField( 'RVTDETAIL', 'RVT_ITEM'  )

	oView:CreateHorizontalBox("SUPERIOR", 30)
	oView:CreateHorizontalBox("INFERIOR", 70)

	oView:CreateVerticalBox( 'SUPERIORESQ', 100, 'SUPERIOR' )


	oView:SetOwnerView("VIEW_RVS", "SUPERIORESQ")
	oView:SetOwnerView("VIEW_RVT", "INFERIOR")

	oView:AddIncrementField("VIEW_RVT", "RVT_ITEM")
	oView:EnableTitleView('VIEW_RVT', "PLAID VS SIGAFIN")
Return (oView)


