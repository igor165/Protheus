#Include "Totvs.ch"
#Include "FwMvcDef.ch"
#include "RU99X04.ch"

#define STR0012 'Update Queries'

/*/{Protheus.doc} RU99X03
Browse for SQL Queries in Managerial Views

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X04()
Private oBrowse := BrowseDef()

DbSelectArea('F6R') // sinitializating table Query
F6R->(dbSetOrder(1))
DbSelectArea('F6S') // sinitializating table SubQuery
F6S->(dbSetOrder(1))
DbSelectArea('F6T') // sinitializating table Index
F6T->(dbSetOrder(1))

oBrowse:Activate()
Return

/*/{Protheus.doc} BrowseDef
Browser Definition

@type function
@author Alison Kaique
@since Apr|2019
@return oBrowse, object, Browser's Object
/*/
Static Function BrowseDef()
Local oBrowse := FwMBrowse():New()

oBrowse:SetAlias('F6R')
oBrowse:SetDescripton(STR0001) //SQL Queries in Managerial Views
oBrowse:SetWalkThru(.T.)
Return oBrowse

/*/{Protheus.doc} MenuDef
Menu Definition

@type function
@author Alison Kaique
@since Apr|2019
@version 1.0
@return aMenu, array, Options for Menu
/*/
Static Function MenuDef()
Local aMenu :=	{}

ADD OPTION aMenu TITLE STR0002  		ACTION 'PesqBrw'       		OPERATION 1 ACCESS 0 //Search
ADD OPTION aMenu TITLE STR0003	 		ACTION 'VIEWDEF.RU99X04'	OPERATION 2 ACCESS 0 //View
//Removed temporary
//ADD OPTION aMenu TITLE STR0004   	 	ACTION 'VIEWDEF.RU99X04' 	OPERATION 3 ACCESS 0 //Add
//ADD OPTION aMenu TITLE STR0005   		ACTION 'VIEWDEF.RU99X04' 	OPERATION 4 ACCESS 0 //Edit
//ADD OPTION aMenu TITLE STR0006    	ACTION 'VIEWDEF.RU99X04' 	OPERATION 5 ACCESS 0 //Delete
//ADD OPTION aMenu TITLE STR0009 		ACTION 'VIEWDEF.RU99X04	'	OPERATION 9 ACCESS 0 //Copy
ADD OPTION aMenu TITLE STR0007      	ACTION 'RU99X06'    		OPERATION 4 ACCESS 0 //Field Queries
ADD OPTION aMenu TITLE STR0011      	ACTION 'RU99X09'    		OPERATION 4 ACCESS 0 //Query Indexes
ADD OPTION aMenu TITLE STR0008 			ACTION 'VIEWDEF.RU99X04'	OPERATION 8 ACCESS 0 //Print
ADD OPTION aMenu TITLE STR0012  ACTION 'RU99X11'	OPERATION 3 ACCESS 0 //Update Queryes

Return aMenu

/*/{Protheus.doc} ModelDef
Model Definition

@type function
@author Alison Kaique
@since Apr|2019
@return oModel, object, Model's Object
/*/
Static Function ModelDef()
Local oStruct	as Object
Local oModel	as Object
Local bPosValid as Object
Local oStructF6S  as Object
Local oStructF6T  as Object

oStruct   := FWFormStruct(01, "F6R")
bPosValid := {|| PosValid()}

oModel := MPFormModel():New('MDRU99X04', /*Pre-Validation*/, /*Pos-Validation*/, /*Commit*/, /*Cancel*/)
oModel:AddFields('ID_FLD_RU99X04', /*cOwner*/, oStruct, /*bPreValidation*/, bPosValid/*bPosValidation*/, /*bLoad*/)
oModel:SetDescription(STR0001)
oModel:GetModel('ID_FLD_RU99X04'):SetDescription(STR0001)

Return oModel

/*/{Protheus.doc} ViewDef
View Definition

@type function
@author Alison Kaique
@since Apr|2019
@return oView, object, View's Object
/*/
Static Function ViewDef()
	Local oStruct := FWFormStruct(02, "F6R")
	Local oModel  := FwLoadModel('RU99X04')
	Local oView   := FwFormView():New()

	//oView:RemoveField( 'F6R_FUNCTI' ) // removed from the view th field with function responsible to update the query, if we allow user create manually, this field must be visible

	oView:SetModel(oModel)
	oView:AddField('ID_VIEW_RU99X04', oStruct, 'ID_FLD_RU99X04')
Return(oView)

/*/{Protheus.doc} PosValid
Data Validation

@type function
@author Alison Kaique
@since 	Apr|2019
@version 11.7
@return lRet, logical, Return of Validation
/*/
Static Function PosValid()
	Local lRet      := .T.
	Local oModel    := FWModelActive()
	Local oModelF6R := oModel:GetModel("ID_FLD_RU99X04")
	Local nOper     := oModel:GetOperation()

	If (nOper == MODEL_OPERATION_INSERT .OR. nOper == MODEL_OPERATION_UPDATE)
		If "*" $ oModelF6R:GetValue("F6R_QUERY")
			MsgStop(STR0010) //Query fields must be specified instead of using *
			lRet := .F.
		EndIf
	EndIf
Return lRet
