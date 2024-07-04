#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03

Modernization

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T03()
Local lRet			AS LOGICAL
Local oBrowse		AS OBJECT
Private cCadastro	AS CHARACTER

lRet		:= .T.
cCadastro	:= "Not implemented"

dbSelectArea("F4U")
dbSetOrder(1)

oBrowse		:= BrowseDef()
oBrowse:Activate()

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse defition

@param		None
@return		OBJECT oBrowse
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse		AS OBJECT
oBrowse		:= FWMBrowse():New()
oBrowse:SetDescription(cCadastro)
oBrowse:SetAlias("F4U")
Return oBrowse

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu defition

@param		None
@return		ARRAY aRotina
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
aRotina	:= FWMVCMenu("RU01T03")
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

MVC model defition

@param		None
@return		OBJECT oModel MPFormModel()
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oStruF4U		AS OBJECT
Local oStruF4V		AS OBJECT
Local oModel		AS OBJECT

oStruF4U	:= FWFormStruct(1, "F4U")
oStruF4V	:= FWFormStruct(1, "F4V")

oModel		:= MPFormModel():New("RU01T03", /* Pre-valid */, /* Pos-Valid */, /* Commit */)

oModel:AddFields("F4UMASTER", /*cOwner*/, oStruF4U)
oModel:AddGrid("F4VDETAIL", "F4UMASTER", oStruF4V, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
oModel:SetDescription("Not implemented")
oModel:GetModel("F4UMASTER"):SetDescription("Not implemented")
oModel:GetModel("F4VDETAIL"):SetDescription("Not implemented")

oModel:GetModel("F4VDETAIL"):SetUniqueLine({"F4V_ITEM"})
oModel:GetModel("F4VDETAIL"):SetOptional(.T.)
oModel:GetModel("F4VDETAIL"):SetNoInsertLine(.F.)

aRelat	:= {}
aAdd(aRelat, {"F4V_FILIAL", "XFILIAL('F4V')"})
aAdd(aRelat, {"F4V_LOTE", "F4U_LOT"})
oModel:SetRelation("F4VDETAIL", aRelat, F4V->(IndexKey(1)))

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

MVC view defition

@param		None
@return		OBJECT oView FWFormView()
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oStruF4U		AS OBJECT
Local oStruF4V		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

oStruF4U	:= FWFormStruct(2, "F4U")
oStruF4V	:= FWFormStruct(2, "F4V")
oModel		:= FWLoadModel("RU01T03")

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F4U", oStruF4U, "F4UMASTER")
oView:AddGrid("VIEW_GRID", oStruF4V, "F4VDETAIL")
oView:CreateHorizontalBox("MAIN", 70)
oView:CreateHorizontalBox("GRID", 30)
oView:SetOwnerView("VIEW_F4U", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

Return oView


// Russia_R5
