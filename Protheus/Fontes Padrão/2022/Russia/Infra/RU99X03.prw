#Include "Totvs.ch"
#Include "FwMvcDef.ch"
#include "RU99X03.ch"

/*/{Protheus.doc} RU99X03
Browse for Managerial Views

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X03()
	Private oBrowse := BrowseDef()

	//Initializing tables
	DBSelectArea("F6P")
	F6P->(DbSetOrder(1))
	DBSelectArea("F6Q")
	F6Q->(DbSetOrder(1))

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

	oBrowse:SetAlias('F6Q')
	oBrowse:SetDescripton(STR0001) //Managerial Views
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
	ADD OPTION aMenu TITLE STR0003	 		ACTION 'VIEWDEF.RU99X03'	OPERATION 2 ACCESS 0 //View
	ADD OPTION aMenu TITLE STR0004   	 	ACTION 'VIEWDEF.RU99X03' 	OPERATION 3 ACCESS 0 //Add
	ADD OPTION aMenu TITLE STR0005   		ACTION 'VIEWDEF.RU99X03' 	OPERATION 4 ACCESS 0 //Edit
	ADD OPTION aMenu TITLE STR0006    		ACTION 'VIEWDEF.RU99X03' 	OPERATION 5 ACCESS 0 //Delete
	ADD OPTION aMenu TITLE STR0007	    	ACTION 'RU99X07'    		OPERATION 4 ACCESS 0 //User Access
	ADD OPTION aMenu TITLE STR0014	    	ACTION 'RU99X10'    		OPERATION 4 ACCESS 0 //Users Group Access
	ADD OPTION aMenu TITLE STR0008 			ACTION 'VIEWDEF.RU99X03'	OPERATION 8 ACCESS 0 //Print
	ADD OPTION aMenu TITLE STR0009 			ACTION 'VIEWDEF.RU99X03'	OPERATION 9 ACCESS 0 //Copy
Return aMenu

/*/{Protheus.doc} ModelDef
Model Definition

@type function
@author Alison Kaique
@since Apr|2019
@return oModel, object, Model's Object
/*/
Static Function ModelDef()
Local oStruct 		as Object
Local oStructF6P 	as Object
Local oModel 		as Object

oStructF6P := FWFormStruct(1,"F6P") //Relation between Vision and Queryes
oStruct := FWFormStruct(1,"F6Q")

oModel := MPFormModel():New('MDRU99X03', /*Pre-Validation*/, /*Pos-Validation*/, /*Commit*/, /*Cancel*/)
oModel:AddFields('ID_FLD_RU99X03', /*cOwner*/, oStruct, /*bPreValidation*/, /*bPosValidation*/, /*bLoad*/)
oModel:SetDescription(STR0001) //Managerial Views
oModel:GetModel('ID_FLD_RU99X03'):SetDescription(STR0001) //Managerial Views

oModel:AddGrid("F6PDETAIL", "ID_FLD_RU99X03", oStructF6P)
oModel:SetRelation("F6PDETAIL", {{"F6P_FILIAL", "xFilial('F6Q')"}, {"F6P_CODVIS", "F6Q_CODVIS"}}, F6P->(IndexKey(1)))


oModel:GetModel("F6PDETAIL"):SetUniqueLine({"F6P_CODQRY"})

oModel:SetPrimarykey({'F6Q_CODVIS'})

Return oModel

/*/{Protheus.doc} ViewDef
View Definition

@type function
@author Alison Kaique
@since Apr|2019
@return oView, object, View's Object
/*/
Static Function ViewDef()
	Local oStruct as array
	Local oStructF6P as  array
	Local oModel  := FwLoadModel('RU99X03')
	Local oView   := FwFormView():New()
	Local oButton := Nil

	oStruct := FWFormStruct(2, "F6Q") //header
	oStructF6P := FWFormStruct(2, "F6P") //sons

	oStructF6P:RemoveField( 'F6P_CODVIS' ) // removed from the view th field with function responsible to update the query, if we allow user create manually, this field must be visible

	oView:SetModel(oModel)
	oView:AddField('ID_VIEW_RU99X03', oStruct, 'ID_FLD_RU99X03')

	oView:AddGrid("VIEW_F6P", oStructF6P, "F6PDETAIL")

	oView:CreateHorizontalBox("HEADERBOX", 40)
	oView:CreateHorizontalBox("ITEMBOX",60)

	oView:SetOwnerView("ID_VIEW_RU99X03", "HEADERBOX")
	oView:SetOwnerView("VIEW_F6P", "ITEMBOX")

Return oView

/*/{Protheus.doc} RU001BUT
Definition about Group of Questions

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RU001BUT()
	Local cGrupoPerg := ""
	Local lIncPerg   := ""
	Local oModel     := FWModelActive()
	Local oModelF6Q  := oModel:GetModel('ID_FLD_RU99X03')

	RegToMemory("F6Q", IIf(INCLUI, .T., .F.))
	cGrupoPerg := oModelF6Q:GetValue("F6Q_X1PERG")

	If !Empty(cGrupoPerg)
		lIncPerg := !(MsgYesNo(STR0011 + Alltrim(cGrupoPerg))) //Do you want make changes to the Group of Questions:
	Else
		//Value false because in routine X31EditSX1 for include is returned in old R_E_C_N_O_
		//Therefore field X1_GRUPO is the older
		lIncPerg := .F.
	EndIf

	If lIncPerg
		X31EditSX1("", 03)
		If MsgYesNo(STR0012 + cGrupoPerg + STR0013 + Alltrim(SX1->X1_GRUPO) + " ?") //Do you want change the content for question from: # to:
			oModelF6Q:LoadValue("F6Q_X1PERG", SX1->X1_GRUPO)
		EndIf
	Else
		SX1->(dbSetOrder(1)) //X1_GRUPO
		If SX1->(dbSeek(cGrupoPerg))
			X31EditSX1(SX1->X1_GRUPO, 04)
		EndIf
	EndIf
Return