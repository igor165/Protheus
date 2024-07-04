#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU09T07.CH"

#define CALLER_CORRECTIVE_SALES_VAT_INVOICE 4

#define STR0001 "Corrective Sales VAT Invoices"
#define STR0002 "Corrective Sales VAT Invoice"
#define STR0003 "Add"
#define STR0004 "View"
#define STR0005 "Edit"
#define STR0006 "Delete"
#define STR0007 "Copy"
#define STR0008 "Track Posting"
#define STR0009 "Sales Book" 
#define STR0010 "Print report"
#define STR0011 "There is no ULCD."

#define STR0032 "VAT Invoice Data"
#define STR0055 "Payment Documents"

/*/{Protheus.doc} RU09T07
Creates the main screen of Corrective Sales VAT Invoice.
@author artem.kostin
@since 19.03.2020
@version P12.1.27
@type function
/*/
Function RU09T07()
Local oBrowse as Object
// Initalization of tables, if they do not exist.
DBSelectArea("F35")
F35->(DbSetOrder(1))
DBSelectArea("F36")
F36->(DbSetOrder(1))
DbSelectArea("F54")
F54->(dbSetOrder(1))
DbSelectArea("F5P")
F5P->(dbSetOrder(1))
DbSelectArea("F39")
F39->(dbSetOrder(1))
DbSelectArea("F3A")
F3A->(dbSetOrder(1))

SetKey(VK_F12, {|a,b| AcessaPerg("RU09T07",.T.)})

oBrowse := BrowseDef()
oBrowse:Activate()
Return(.T.)

/*/{Protheus.doc} MenuDef
Defines the browser for the Corrective Sales VAT Invoice.
@author artem.kostin
@since 19.03.2020
@version P12.1.27
@type function
/*/
Static Function BrowseDef()
Local oBrowse as Object
Local aRotina as Array

aRotina := MenuDef()

oBrowse := FwMBrowse():New()
oBrowse:SetAlias("F35")
oBrowse:SetDescription(STR0001) //"Corrective Sales VAT Invoices"
oBrowse:DisableDetails()
Return(oBrowse)

/*/{Protheus.doc} MenuDef
Defines the menu to Corrective Sales VAT Invoice.
@author artem.kostin
@since 19.03.2020
@version P12.1.27
@type function
/*/
Static Function MenuDef()
local aRotina	as Array

aRotina := {{STR0003, "RU05D01(" + str(CALLER_CORRECTIVE_SALES_VAT_INVOICE) + ")", 0, 3},; //"Add"
			{STR0004, "VIEWDEF.RU09T07", 0, 2},; //"View"
			{STR0005, "VIEWDEF.RU09T07", 0, 4},; //"Edit"
			{STR0006, "VIEWDEF.RU09T07", 0, 5},; //"Delete"
			{STR0007, "VIEWDEF.RU09T07", 0, 9},; //"Copy"
			{STR0008, "CTBC662", 0, 2},; //"Track Posting"
			{STR0009, "RU09T07_01_BrowseSalesBooks", 0, 2},;//"Sales Book" 
			{STR0010, "RU05R03()", 0, 6}}
Return(aRotina)

/*/{Protheus.doc} ModelDef
Creates the model of Corrective Sales VAT Invoice.
@author artem.kostin
@since 19.03.2020
@version P12.1.27
@type function
/*/
Static Function ModelDef()
// Models
Local oModel		as Object
Local oModelEvent	as Object
// Structures
Local oStructF35	as Object
Local oStructF36	as Object
Local oStructF5P	as Object

oStructF35 := FWFormStruct(1, "F35")
oStructF36 := FWFormStruct(1, "F36")
oStructF5P := FWFormStruct(1, "F5P")

oModel := MPFormModel():New("RU09T07")

oModel:AddFields("F35MASTER", Nil, oStructF35)

oModel:AddGrid("F36DETAIL", "F35MASTER", oStructF36)
oModel:SetRelation("F36DETAIL", {{"F36_FILIAL", "xFilial('F36')"}, {"F36_KEY", "F35_KEY"}, {"F36_DOC", "F35_DOC"}}, F36->(IndexKey(1)))

oModel:AddGrid("F5PDETAIL", "F35MASTER", oStructF5P)
oModel:SetRelation("F5PDETAIL", {{"F5P_FILIAL", "xFilial('F5P')"}, {"F5P_KEY", "F35_KEY"}}, F5P->(IndexKey(1)))
oModel:GetModel("F5PDETAIL"):SetOptional(.T.)

oModelEvent := RU09T07EventRUS():New()
oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)
Return(oModel)

/*/{Protheus.doc} ViewDef
Creates the view of Corrective Sales VAT Invoice.
@author artem.kostin
@since 19.03.2020
@version P12.1.27
@type function
/*/
Static Function ViewDef()
Local oView as Object
Local oModel as Object
// Structures of used tables
Local oStructF35 as Object
Local oStructF36 as Object
Local oStruc_T as Object
Local oStructF5P as Object
// Lists of fields to remove
Local cCmpF35_T as Character

// Defines which fields we don't need to show on the screen.
cCmpF35_T	:= "F35_VATVL ;F35_VALGR ;F35_VATBS ;F35_VATVL1;F35_VATBS1;F35_VTBSD ;F35_VTVALD;F35_VALGRD;F35_VTBS1D;F35_VTVL1D;"

oModel		:= ModelDef()
oStructF35	:= FWFormStruct(2, "F35")
oStructF36	:= FWFormStruct(2, "F36")
oStructF5P	:= FWFormStruct(2, "F5P")
oStruc_T	:= FWFormStruct(2, "F35", {|x| (AllTrim(x) $ cCmpF35_T)})
oStruc_T:SetNoFolder()

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("F35_M", oStructF35, "F35MASTER")
oView:AddGrid("F36_D", oStructF36, "F36DETAIL")
oView:AddField("F35_T", oStruc_T, "F35MASTER")
oView:AddGrid("F5P_D", oStructF5P, "F5PDETAIL")

oView:CreateHorizontalBox("BOXFORMALL", 35)
oView:CreateFolder("FOLDER","BOXFORMALL")

oView:AddSheet("FOLDER", 'Sheet1', STR0032) // VAT Invoice Data
oView:AddSheet("FOLDER", 'Sheet5', STR0055) // Payment Documents

oView:CreateHorizontalBox("HEADER1", 100,,,"FOLDER",'Sheet1')
oView:CreateHorizontalBox("F5PHEADERBOX",100/*%*/,,,'FOLDER','Sheet5')

oView:SetOwnerView("F35_M", "HEADER1")
oView:SetOwnerView("F5P_D", "F5PHEADERBOX")

oView:CreateHorizontalBox("ITEMBOX", 55)
oView:CreateHorizontalBox("TOTALBOX",10)

oView:SetOwnerView("F36_D", "ITEMBOX")
oView:SetOwnerView("F35_T", "TOTALBOX")

oView:AddIncrementField('F36_D','F36_ITEM')
oView:AddIncrementField('F5P_D','F5P_ITEM')

oView:SetViewCanActivate({|oView| RU09XFUN05_ViewCanActivate(oView)})
Return(oView)

/*/{Protheus.doc} RU09T07_01_BrowseSalesBooks
@author artem.kostin
@since 20.03.2020
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function RU09T07_01_BrowseSalesBooks(oModel as Object)
// Save working areas
Local aArea			as Array
Local aAreaAlias	as Array
Local cAlias		as Character
// Seek  key
Local cKey			as Character

cAlias		:= "F39"
aArea		:= GetArea()
aAreaAlias	:= (cAlias)->(GetArea())

If (RU05XFN010_CheckModel(oModel, "RU09T07"))
	cKey := AllTrim(oModel:GetModel("F35MASTER"):GetValue("F35_BOOKEY"))
Else
	cKey := F35->F35_BOOKEY
EndIf

RU09T04("F39_BOOKEY == '" + cKey + "'")

RestArea(aAreaAlias)
RestArea(aArea)
Return

/*/{Protheus.doc} RU09T07_02_AddCorrectiveSalesVATInvoice
@author artem.kostin
@since 23.03.2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function RU09T07_02_AddCorrectiveSalesVATInvoice()
// Process control
Local lRet			as Logical
// Models
Local oModel		as Object
Local nOperation	as Numeric

lRet := .T.
nOperation := MODEL_OPERATION_INSERT
oModel := FWLoadModel("RU09T07")
oModel:SetOperation(nOperation)
oModel:Activate()

lRet := lRet .and. RU09T07_05_FillFromUlcd(oModel)
If (lRet)
	FwExecView(/*cTitle*/, "RU09T07", nOperation,/* oDlg */,{|| .T.}, /* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)
EndIf
Return lRet

/*{Protheus.doc} CopyField
Copy field from first model to the field in second one, returns .T. if succeed
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function CopyField(oModelFrom as Object, oModelTo as Object, cFieldFrom as Character, cFieldTo as Character, lRet as Logical)
	Local cFrom as Character
	Local cTo   as Character
	// Process control
	Default lRet := .T.

	cFrom := Upper(AllTrim(cFieldFrom))
	cTo   := Upper(AllTrim(cFieldTo))
	lRet  := oModelTo:LoadValue(cTo, oModelFrom:GetValue(cFrom))
	If (oModelTo:oFormModel:HasErrorMessage())
		RU05XFN008_Help(oModelTo:oFormModel)
	EndIf
Return lRet



/*{Protheus.doc} RU09T07_05_FillFromUlcd
Fill corrective sales vat invoice model from ULCD model
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function RU09T07_05_FillFromUlcd(oModel as Object)
	// Process control
	Local lRet			as Logical
	// Models
	Local oModelULCD	as Object

	lRet := RU05XFN010_CheckModel(oModel, "RU09T07")
	If F5Y->(EOF())
		lRet := .F.
		RU99XFUN05_Help(STR0011)
	Else
		oModelULCD := FwLoadModel("RU05D02")
		oModelULCD:SetOperation(MODEL_OPERATION_VIEW)
		oModelULCD:Activate()

		RU09T07_06_FillFromUlcdHeader(oModelULCD, oModel, @lRet)
		RU09T07_07_FillFromUlcdDetails(oModelULCD, oModel, @lRet)
	EndIf
Return lRet

/*{Protheus.doc} RU09T07_06_FillFromUlcdHeader
Fill corrective sales vat invoice header from ULCD header
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function RU09T07_06_FillFromUlcdHeader(oModelULCD as Object, oModel as Object, lRet as Logical)
	// Models
	Local oModelHead	as Object
	Local oULCDHead		as Object
	// Relations between tables
	Local aRelations		as Array
	Local nI			as Numeric
	// Process control
	Default lRet := .T.

	If (lRet := lRet;
			.and. RU05XFN010_CheckModel(oModel, "RU09T07");
			.and. RU05XFN010_CheckModel(oModelULCD, "RU05D01|RU05D02"))
		oModelHead	:= oModel:GetModel("F35MASTER")
		oULCDHead	:= oModelULCD:GetModel("F5YMASTER")

		aRelations	:= F5YtoF35()
		For nI := 1 to Len(aRelations)
			If (lRet)
				CopyField(oULCDHead, oModelHead, aRelations[nI][1], aRelations[nI][2], @lRet)
			Else
				Exit
			EndIf
		Next nI
	EndIf
Return lRet

/*{Protheus.doc} RU09T07_07_FillFromUlcdDetails
Fill corrective sales vat invoice details from ULCD details
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function RU09T07_07_FillFromUlcdDetails(oModelULCD as Object, oModel as Object, lRet as Logical)
	// Models
	Local oModelDet		as Object
	Local oULCDHead		as Object
	Local oULCDDet		as Object
	// grid iterators
	Local nLast			as Numeric
	Local nLine			as Numeric
	Local nI			as Numeric
	// Relations between tables
	Local aRelF5ZtoF36	as Array
	Local aRelF5YtoF36	as Array
	// Process control
	Default lRet := .T.

	If (lRet := lRet;
			.and. RU05XFN010_CheckModel(oModel    , "RU09T07");
			.and. RU05XFN010_CheckModel(oModelULCD, "RU05D01|RU05D02"))
		aRelF5ZtoF36 := F5ZtoF36()
		aRelF5YtoF36 := F5YtoF36()

		oModelDet := oModel:GetModel("F36DETAIL")
		oULCDHead := oModelULCD:GetModel("F5YMASTER")
		oULCDDet  := oModelULCD:GetModel("F5ZDETAIL_AFTER")

		nLast := oULCDDet:Length(.T.)
		For nLine := 1 To nLast
			// F5Z => F36
			For nI := 1 to Len(aRelF5ZtoF36)
				If (lRet)
					CopyField(oULCDDet, oModelDet, aRelF5ZtoF36[nI][1], aRelF5ZtoF36[nI][2], @lRet)
				Else
					Exit
				EndIf
			Next nI
			// F5Y => F36
			For nI := 1 to Len(aRelF5YtoF36)
				If (lRet)
					CopyField(oULCDHead, oModelDet, aRelF5YtoF36[nI][1], aRelF5YtoF36[nI][2], @lRet)
				Else
					Exit
				EndIf
			Next nI

			If (nLine <> nLast)
				oModelDet:AddLine()
				oULCDDet:GoLine(nLine + 1)
				oModelDet:GoLine(nLine + 1)
			EndIf
		Next nLine
		oModelDet:GoLine(1)
	EndIf
Return lRet

/*{Protheus.doc} F5YtoF35
Returns array of field-to-field relations between tables F5Y and F35.
@author artem.kostin
@since 24/03/2020
@version 1.0
@project MA3 - Russia
*/
Static Function F5YtoF35()
	Local aRelations	as Array
	
	aRelations := {}
	AAdd(aRelations, {"F5Y_UID   ", "F35_LOGUID"})
	AAdd(aRelations, {"F5Y_CLIENT", "F35_CLIENT"})
	AAdd(aRelations, {"F5Y_BRANCH", "F35_BRANCH"})
	AAdd(aRelations, {"F5Y_CURREN", "F35_INVCUR"})
	AAdd(aRelations, {"F5Y_EXGRAT", "F35_C_RATE"})
	AAdd(aRelations, {"F5Y_CNTCOD", "F35_CONTRA"})
	AAdd(aRelations, {"F5Y_SERIE ", "F35_INVSER"})
	AAdd(aRelations, {"F5Y_DOC   ", "F35_INVDOC"})
	AAdd(aRelations, {"F5Y_BASE  ", "F35_VATBS "})
	AAdd(aRelations, {"F5Y_VATVL ", "F35_VATVL "})
	AAdd(aRelations, {"F5Y_GROSS ", "F35_VALGR "})
	AAdd(aRelations, {"F5Y_BASE1 ", "F35_VATBS1"})
	AAdd(aRelations, {"F5Y_VATVL1", "F35_VATVL1"})
	AAdd(aRelations, {"F5Y_DATE  ", "F35_INVDT "})
	AAdd(aRelations, {"F5Y_CNRVEN", "F35_CNRVEN"})
	AAdd(aRelations, {"F5Y_CNRCOD", "F35_CNOR_C"})
	AAdd(aRelations, {"F5Y_CNRBR ", "F35_CNOR_B"})
	AAdd(aRelations, {"F5Y_CNECLI", "F35_CNECLI"})
	AAdd(aRelations, {"F5Y_CNECOD", "F35_CNEE_C"})
	AAdd(aRelations, {"F5Y_CNEBR ", "F35_CNEE_B"})
	AAdd(aRelations, {"F5Y_CONUNI", "F35_CONUNI"})
Return aRelations

/*{Protheus.doc} F5ZtoF36
Returns array of field-to-field relations between tables F5Z and F36.
@author artem.kostin
@since 24/03/2020
@version 1.0
@project MA3 - Russia
*/
Static Function F5ZtoF36()
	Local aRelations	as Array

	aRelations := {}
	AAdd(aRelations, {"F5Z_UIDORI", "F36_DOCKEY"})
	AAdd(aRelations, {"F5Z_UM    ", "F36_UM    "})
	AAdd(aRelations, {"F5Z_BASE  ", "F36_VATBS "})
	AAdd(aRelations, {"F5Z_VATCOD", "F36_VATCOD"})
	AAdd(aRelations, {"F5Z_VATRT ", "F36_VATRT "})
	AAdd(aRelations, {"F5Z_GROSS ", "F36_VALGR "})
	AAdd(aRelations, {"F5Z_ITEM  ", "F36_INVIT "})
	AAdd(aRelations, {"F5Z_FDESC ", "F36_DESC  "})
	AAdd(aRelations, {"F5Z_ITMCOD", "F36_ITMCOD"})
	AAdd(aRelations, {"F5Z_ITMCOD", "F36_ITMCOD"})
	AAdd(aRelations, {"F5Z_QUANT ", "F36_QUANT "})
	AAdd(aRelations, {"F5Z_VUNIT ", "F36_VUNIT "})
	AAdd(aRelations, {"F5Z_TOTAL ", "F36_VALUE "})
	AAdd(aRelations, {"F5Z_VATVL ", "F36_VATVL "})
	AAdd(aRelations, {"F5Z_BASE1 ", "F36_VATBS1"})
	AAdd(aRelations, {"F5Z_VATVL1", "F36_VATVL1"})
Return aRelations

/*{Protheus.doc} F5YtoF36
Returns array of field-to-field relations between tables F5Y and F36.
@author artem.kostin
@since 24/03/2020
@version 1.0
@project MA3 - Russia
*/
Static Function F5YtoF36()
	Local aRelations	as Array

	aRelations := {}
	AAdd(aRelations, {"F5Y_CLIENT", "F36_CLIENT"})
	AAdd(aRelations, {"F5Y_BRANCH", "F36_BRANCH"})
	AAdd(aRelations, {"F5Y_SERIE ", "F36_INVSER"})
	AAdd(aRelations, {"F5Y_DOC   ", "F36_INVDOC"})
	AAdd(aRelations, {"F5Y_DATE  ", "F36_ITDATE"})
Return aRelations
