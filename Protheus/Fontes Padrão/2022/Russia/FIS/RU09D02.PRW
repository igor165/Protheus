#Include "Protheus.ch"
#Include "FwMVCDef.ch"
#Include "RU09D02.ch"

Function RU09D02()
//////
Local lRet as Logical
Local oBrowse as Object

Private aRotina as Array

lRet := .T.
aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("F31")
oBrowse:SetDescription(STR0001)
oBrowse:Activate()
Return(lRet)

Static Function MenuDef()
Local aRet as Array

aRet := {{STR0002, "VIEWDEF.RU09D02", 0, 2, 0, Nil},;
		{STR0003, "VIEWDEF.RU09D02", 0, 3, 0, Nil},;
		{STR0004, "VIEWDEF.RU09D02", 0, 4, 0, Nil},;
		{STR0005, "VIEWDEF.RU09D02", 0, 5, 0, Nil}}
Return(aRet)

Static Function ModelDef()
Local oModel as Object
Local oStrF31 as Object

oStrF31 := FWFormStruct(1, "F31")
oModel := MPFormModel():New("RU09D02", , , , )

oModel:AddFields("F31MASTER", Nil, oStrF31)
oModel:SetPrimaryKey({"F31_FILIAL", "F31_CODE"})
Return(oModel)

Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStrF31 as Object

oModel := ModelDef()
oStrF31 := FWFormStruct(2, "F31")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("F31", oStrF31, "F31MASTER")
Return(oView)
//merge branch 12.1.19
// Russia_R5
