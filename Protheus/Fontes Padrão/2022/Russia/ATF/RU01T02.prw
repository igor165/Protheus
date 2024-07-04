#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01T02.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02

Conservation

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T02()
Local lRet			AS LOGICAL
Local oBrowse		AS OBJECT
Private cCadastro	AS CHARACTER

lRet		:= .T.
cCadastro	:= STR0014	// "Fixed Asset Conservation."

dbSelectArea("F44")
dbSetOrder(1)	//F44_FILIAL+F44_CODE+F44_TYPE

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
oBrowse:SetAlias("F44")
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
aRotina	:= FWMVCMenu("RU01T02")
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
Local oStruF44		AS OBJECT
Local oModel		AS OBJECT

oStruF44	:= FWFormStruct(1, "F44")

oModel		:= MPFormModel():New("RU01T02", /* Pre-valid */, /* Pos-Valid */, /* Commit */)

oModel:AddFields("F44MASTER", /*cOwner*/, oStruF44)
oModel:SetDescription(STR0014) // "Fixed Asset Conservation."
oModel:GetModel("F44MASTER"):SetDescription(STR0014) // "Fixed Asset Conservation."

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
Local oStruF44		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

oStruF44	:= FWFormStruct(2, "F44")
oModel		:= FWLoadModel("RU01T02")

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F44", oStruF44, "F44MASTER")
oView:CreateHorizontalBox("MAIN", 100)
oView:SetOwnerView("VIEW_F44", "MAIN")

Return oView


// Russia_R5
