#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU09D08.CH"

/*/{Protheus.doc} RU09D08
Configuration for Payment Request to Budget Payment.
FI-CF-25-5
@author alexander.kharchenko 
@since 13.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Function RU09D08()

Local oBrowse   as Object
Private aRotina as ARRAY

RU06XFUN57_PutTableEA()
RU06XFUN58_PutTableEB()

dbSelectArea("SFB")
oBrowse := BrowseDef()
aRotina := MenuDef()
oBrowse:Activate()

Return

/*/{Protheus.doc} RU09D08
BrowseDef definition
FI-CF-25-5
@author alexander.kharchenko
@since 13.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Static Function BrowseDef()

Local oBrowse as OBJECT

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0012)
oBrowse:SetMenuDef("RU09D08")
oBrowse:SetAlias("SFB")

Return oBrowse

/*/{Protheus.doc} RU09D08
MenuDef definition
FI-CF-25-5
@author alexander.kharchenko
@since 13.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as array

aRotina := {}

ADD OPTION aRotina Title STR0001 	Action 'VIEWDEF.RU09D08'	OPERATION MODEL_OPERATION_VIEW ACCESS 0 //View
ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.RU09D08'	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Add
ADD OPTION aRotina Title STR0003    Action 'VIEWDEF.RU09D08'   	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Change
ADD OPTION aRotina Title STR0004 	Action 'VIEWDEF.RU09D08'    OPERATION MODEL_OPERATION_DELETE ACCESS 0 //Delete

Return aRotina


/*/{Protheus.doc} RU09D08
ModelDef definition
FI-CF-25-5
@author alexander.kharchenko
@since 13.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Static Function ModelDef()

Local oStrSFB 		as Object                              
Local oModel 		as Object
Local oStrF6B    	as Object
                           
oStrF6B		:= FWFormStruct(1, "F6B")
oStrSFB		:= FWFormStruct(1, "SFB")
oModel 		:= MPFormModel():New("RU09D08")

oModel:AddFields("SFBMASTER",, oStrSFB)
oModel:AddGrid("F6BDETAILS", "SFBMASTER", oStrF6B)
oModel:GetModel('F6BDETAILS'):SetOptional(.T.)
oModel:SetRelation('F6BDETAILS', {  { 'F6B_FILIAL', 'xFilial("F6B")' }, {'F6B_TAX','FB_CODIGO'} } )

oModel:GetModel("F6BDETAILS"):SetFldNoCopy({"F6B_CFGCOD"})

Return oModel


/*/{Protheus.doc} RU09D08
ViewDef definition
FI-CF-25-5
@author alexander.kharchenko
@since 13.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Static Function ViewDef()

Local oModel	    as Object
Local oStrSFB	    as Object
Local oStrF6B	    as Object

Local oView		    as Object  
Local cFldView      as Character
Local oGridModel    as Object
Local cFldNoCpy     as Character

oModel		:= FWLoadModel("RU09D08")
oView		:= FWFormView():New()
oStrSFB		:= FWFormStruct(2,"SFB",{|| .T.})
oStrF6B		:= FWFormStruct(2,"F6B",{|| .T.})

oStrF6B:RemoveField( 'F6B_FILIAL' )
oStrF6B:RemoveField( 'F6B_TAX' )

oView:SetModel(oModel)
oView:AddField("VIEW_SFB",oStrSFB,"SFBMASTER")
oView:AddGrid("VIEW_F6B",oStrF6B,"F6BDETAILS")

oView:CreateHorizontalBox('SUPERIOR', 30)
oView:CreateHorizontalBox('INFERIOR', 70)

oView:SetOwnerView('SFBMASTER','SUPERIOR')
oView:SetOwnerView('F6BDETAILS','INFERIOR')

oView:SetViewProperty('F6BDETAILS', "ENABLEDGRIDDETAIL", {50})
oView:SetViewProperty("F6BDETAILS", "GRIDFILTER", {.T.})
oView:SetViewProperty("F6BDETAILS", "GRIDSEEK", {.T.})

oView:addIncrementField("F6BDETAILS", "F6B_CFGCOD")

oGridModel  := oModel:GetMOdel('F6BDETAILS')
cFldNoCpy   := 'F6B_CFGCOD'

oView:AddUserButton(STR0005, '', {|| RU09D0801_GridRowCopy(oGridModel, 1, cFldNoCpy)})     //Recalc Total Value

Return oView

/*/{Protheus.doc} RU09D08
Function for copy row in grid
FI-CF-25-5
@author alexander.kharchenko
@since 13.12.2019 
@version 1.0 
@project MA3 - Russia
/*/

Function RU09D0801_GridRowCopy(oGrid as Object, nLine As Numeric, cNoCopyFld as Character)

Local nI As Numeric
Local aFldCpy as Array

aFldCpy := {}

//Check model Movements
If !oGrid:IsEmpty()
    nI := oGrid:addLine()
    oGrid:GoLine(nI)
    aFldCpy := oGrid:GetStruct():GetFields()
EndIf

// Initializing Value
For nI := 1 To Len(aFldCpy)
    If(aFldCpy[nI, 3] != cNoCopyFld)
        oGrid:LdValueByPos(nI, oGrid:GetValue(aFldCpy[nI, 3], nLine))
    EndIf
Next nI

Return Nil
