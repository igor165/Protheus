#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA500.CH"


Function ATFA500()
    Local oBrowse := BrowseDef()
    oBrowse:Activate()
Return

Static Function ModelDef()
    Local oStru  := FwFormStruct(1, "SNZ")
    Local oModel := MPFormModel():New("ATFA500")

    oModel:AddFields("MODEL_SNZ", /*cOwner*/, oStru)

    oModel:SetDescription(STR0001)
    oModel:GetModel("MODEL_SNZ"):SetDescription(STR0001)
Return oModel

Static Function ViewDef()
    Local oView  := Nil
    Local oStru  := FwFormStruct(2, "SNZ")
    Local oModel := FwLoadModel("ATFA500")

    oView  := FwFormView():New()
    oView:SetCloseOnOk({||.T.})

    oView:SetModel(oModel)
    oView:AddField("VIEW_SNZ_FIELDS", oStru, "MODEL_SNZ")

    oView:CreateHorizontalBox("VIEW_SNZ_HB_100", 100)
    oView:SetOwnerView("VIEW_SNZ_FIELDS", "VIEW_SNZ_HB_100")
Return oView

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ATFA500" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE STR0002 ACTION "AF500FIN"        OPERATION OP_ALTERAR    ACCESS 0
    ADD OPTION aRotina TITLE STR0003 ACTION "AF500CAN"        OPERATION OP_ALTERAR    ACCESS 0
Return aRotina

Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("SNZ")

    oBrowse:SetDescription(STR0001)

    oBrowse:AddLegend("NZ_STATUS=='0'", "YELLOW", STR0004)
    oBrowse:AddLegend("NZ_STATUS=='1'", "BLUE"  , STR0005)
    oBrowse:AddLegend("NZ_STATUS=='2'", "RED"   , STR0006)
Return oBrowse

Function AF500FIN()
    Local oAF500 := FwLoadModel("ATFA500")
    Local oSNZ   := oAF500:GetModel("MODEL_SNZ")

    oAF500:SetOperation(OP_ALTERAR)
    oAF500:Activate()

    oSNZ:SetValue("NZ_STATUS", "1")

    If oAF500:VldData()
        oAF500:CommitData()
    EndIf

    oAF500:Deactivate()
    oAF500:Destroy()
Return

Function AF500CAN()
    Local oAF500 := FwLoadModel("ATFA500")
    Local oSNZ   := oAF500:GetModel("MODEL_SNZ")

    oAF500:SetOperation(OP_ALTERAR)
    oAF500:Activate()

    oSNZ:SetValue("NZ_STATUS", "2")

    If oAF500:VldData()
        oAF500:CommitData()
    EndIf

    oAF500:Deactivate()
    oAF500:Destroy()
Return