#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01T01.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01

Putting into operation

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01()
Local lRet			AS LOGICAL
Local oBrowse		AS OBJECT
Private cCadastro	AS CHARACTER

lRet		:= .T.
cCadastro	:= STR0024	//"Putting into Operation"

dbSelectArea("F4Q")
dbSetOrder(1)	//F4Q_FILIAL+F4Q_LOT

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
oBrowse:SetDescription(STR0024) //"Putting into Operation"
oBrowse:SetAlias("F4Q")
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
aRotina	:= FWMVCMenu("RU01T01")
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
Local oStruF4Q		AS OBJECT
Local oStruF4R		AS OBJECT
Local oModel		AS OBJECT

oStruF4Q	:= FWFormStruct(1, "F4Q")
oStruF4R	:= FWFormStruct(1, "F4R")

oModel		:= MPFormModel():New("RU01T01", /* Pre-valid */, /* Pos-Valid */, /* Commit */)

oModel:AddFields("F4QMASTER", /*cOwner*/, oStruF4Q)
oModel:AddGrid("F4RDETAIL", "F4QMASTER", oStruF4R, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
oModel:SetDescription(STR0024) //"Putting into Operation"
oModel:GetModel("F4QMASTER"):SetDescription(STR0024) //"Putting into Operation"
oModel:GetModel("F4RDETAIL"):SetDescription(STR0024) //"Putting into Operation"

oModel:GetModel("F4RDETAIL"):SetUniqueLine({"F4R_ITEM"})
oModel:GetModel("F4RDETAIL"):SetOptional(.T.)
oModel:GetModel("F4RDETAIL"):SetNoInsertLine(.F.)

aRelat	:= {}
aAdd(aRelat, {"F4R_FILIAL", "F4Q_FILIAL"})
aAdd(aRelat, {"F4R_LOTE", "F4Q_LOT"})
oModel:SetRelation("F4RDETAIL", aRelat, F4R->(IndexKey(1)))

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
Local oStruF4Q		AS OBJECT
Local oStruF4R		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

oStruF4Q	:= FWFormStruct(2, "F4Q")
oStruF4R	:= FWFormStruct(2, "F4R")
oModel		:= FWLoadModel("RU01T01")

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F4Q", oStruF4Q, "F4QMASTER")
oView:AddGrid("VIEW_GRID", oStruF4R, "F4RDETAIL")
oView:CreateHorizontalBox("MAIN", 70)
oView:CreateHorizontalBox("GRID", 30)
oView:SetOwnerView("VIEW_F4Q", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

Return oView
