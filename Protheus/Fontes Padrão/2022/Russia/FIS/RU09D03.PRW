#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU09D03.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03

General numbering system

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU09D03()
Local lRet			AS LOGICAL
Local oBrowse		AS OBJECT
Private cCadastro	AS CHARACTER

lRet		:= .T.
cCadastro	:= STR0001	//"General numbering system"

dbSelectArea("F33")
dbSetOrder(2)	//F33_FILIAL+F33_KEY+F33_SERIE+F33_FILUSE+F33_BSDATE

oBrowse		:= BrowseDef()
oBrowse:Activate()

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse defition for general numbering system

@param		None
@return		OBJECT oBrowse
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse		AS OBJECT
oBrowse		:= FWMBrowse():New()
oBrowse:SetDescription(STR0001) //"General numbering system"
oBrowse:SetAlias("F33")
Return oBrowse

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu defition for general numbering system

@param		None
@return		ARRAY aRotina
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
aRotina	:= FWMVCMenu("RU09D03")
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

MVC model defition for general numbering system

@param		None
@return		OBJECT oModel MPFormModel()
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oStruF33		AS OBJECT
Local oStruF4X		AS OBJECT
Local oModel		AS OBJECT

oStruF33	:= FWFormStruct(1, "F33")
oStruF4X	:= FWFormStruct(1, "F4X")

oModel		:= MPFormModel():New("RU09D03", /* Pre-valid */, /* Pos-Valid */, /* Commit */)

oModel:AddFields("F33MASTER", /*cOwner*/, oStruF33)
oModel:AddGrid("F4XDETAIL", "F33MASTER", oStruF4X, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
oModel:SetDescription(STR0001) //"General numbering system"
oModel:GetModel("F33MASTER"):SetDescription(STR0001) //"General numbering system"
oModel:GetModel("F4XDETAIL"):SetDescription(STR0001) //"General numbering system"

oModel:GetModel("F4XDETAIL"):SetUniqueLine({"F4X_DATE"})
oModel:GetModel("F4XDETAIL"):SetOptional(.T.)
oModel:GetModel("F4XDETAIL"):SetNoInsertLine(.F.)

aRelat	:= {}
aAdd(aRelat, {"F4X_FILIAL", "F33_FILIAL"})
aAdd(aRelat, {"F4X_ID", "F33_ID"})
oModel:SetRelation("F4XDETAIL", aRelat, F4X->(IndexKey(1)))

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

MVC view defition for general numbering system

@param		None
@return		OBJECT oView FWFormView()
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oStruF33		AS OBJECT
Local oStruF4X		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

oStruF33	:= FWFormStruct(2, "F33")
oStruF4X	:= FWFormStruct(2, "F4X")
oModel		:= FWLoadModel("RU09D03")

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F33", oStruF33, "F33MASTER")
oView:AddGrid("VIEW_GRID", oStruF4X, "F4XDETAIL")
oView:CreateHorizontalBox("MAIN", 70)
oView:CreateHorizontalBox("GRID", 30)
oView:SetOwnerView("VIEW_F33", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

Return oView


// Russia_R5
