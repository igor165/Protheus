#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU09T09.CH"

#define ADJUSTMENT_VAT_INVOICE "5"
#define USE_AUTO_BOOK "1"
#define CALLER_ADJ_SALES_VAT_INVOICE 3
#define CURRENCY_RUB "01"

/*{Protheus.doc} RU09T09
Routine to deal with Adjustive Sales Documents
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T09()
	Local oBrowse As Object

	//Initalize tables, if they do not exist.
	DBSelectArea("F5Y")
	F5Y->(DbSetOrder(1))
	DBSelectArea("F5Z")
	F5Z->(DbSetOrder(1))
	DBSelectArea("F35")
	F35->(DbSetOrder(1))
	DBSelectArea("F36")
	F36->(DbSetOrder(1))
	DbSelectArea("F5P")
	F5P->(dbSetOrder(1))

	oBrowse := FWLoadBrw("RU09T09")
	oBrowse:Activate()
Return

/*{Protheus.doc} ModelDef
Creates model for Adjustive Sales Documents
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function ModelDef()
	Local aF36ToF35  as Array
	Local oGrid 	 as Object
	Local oModel     as Object
	Local oStructF35 as Object
	Local oStructF36 as Object
	Local oModelEvent as Object
	Local oStructF5P as Object

	oStructF35 := FWFormStruct(1, "F35")
	oStructF36 := FWFormStruct(1, "F36")
	oStructF5P := FWFormStruct(1, "F5P")
	oModel := MPFormModel():New("RU09T09", , , {|oMdl| SaveModel(oMdl)},)
	oModel:AddFields("F35MASTER", Nil, oStructF35)
	oModel:AddGrid("F36DETAIL", "F35MASTER", oStructF36)
	oModel:AddGrid("F5PDETAIL", "F35MASTER", oStructF5P)
	oGrid := oModel:GetModel('F36DETAIL')
	oGrid:SetMaxLine(oGrid:Length())
	oGrid:SetNoDeleteLine(.T.)

	aF36ToF35 := {{"F36_FILIAL", "xFilial('F36')"}, {"F36_KEY", "F35_KEY"}, {"F36_DOC", "F35_DOC"}}
	aF5PToF35 := {{"F5P_FILIAL", "xFilial('F5P')"}, {"F5P_KEY", "F35_KEY"}}
	oModel:SetRelation("F36DETAIL", aF36ToF35, F36->(IndexKey(1)))
	oModel:SetRelation("F5PDETAIL", aF5PToF35, F5P->(IndexKey(1)))
	oModel:SetPrimaryKey({"F35_FILIAL", "F35_KEY"})

	oModel:SetDescription(STR0008)
	oModel:GetModel("F5PDETAIL"):SetOptional(.T.)
	oModelEvent := RU09T09EventRUS():New()
	oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)
Return(oModel)

/*{Protheus.doc} ViewDef
Creates the view for Adjustive Sales Documents
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function ViewDef()
	Local cCmpF35    as Character
	Local cCmpF35_T  as Character
	Local cCmpF36    as Character
	Local cCmpF5P    as Character
	Local oModel     as Object
	Local oStruc_T   as Object
	Local oStructF35 as Object
	Local oStructF36 as Object
	Local oStructF5P as Object
	Local oView      as Object

	cCmpF35 := "F35_IDATE;F35_CURR;F35_VATCOD;F35_VATVL;F35_VALGR;F35_VATBS;F35_VATCOD;F35_VATVL1;F35_VATBS1;F35_F5QUID"
	cCmpF36 := "F36_FILIAL;F36_KEY;F36_DOCKEY;F36_TYPE;F36_DOC;F36_EXC_V1;F36_VATVS1;F36_EXC_V1;F36_DTLA;F36_INVCUR;"
	cCmpF35_T := "F35_VATVL;F35_VALGR;F35_VATBS;F35_VATCOD;F35_VATVL1;F35_VATBS1"
	cCmpF5P := "F5P_KEY   ;"

	oModel := FwLoadModel("RU09T09")
	oStructF35 := FWFormStruct(2, "F35", {|x| !(AllTrim(x) $ cCmpF35)})
	oStructF36 := FWFormStruct(2, "F36", {|x| !(AllTrim(x) $ cCmpF36)})
	oStruc_T := FWFormStruct(2,   "F35", {|x| (AllTrim(x) $ cCmpF35_T) })
	oStruc_T:SetNoFolder()
	oStructF5P := FWFormStruct(2, "F5P", {|x| !(AllTrim(x) $ cCmpF5P)})

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("F35_M", oStructF35, "F35MASTER")
	oView:AddField("F35_T", oStruc_T,   "F35MASTER")
	oView:AddGrid("F36_D",  oStructF36, "F36DETAIL")
	oView:AddGrid("F5P_D",  oStructF5P, "F5PDETAIL")

	oView:SetCloseOnOk({|| .T.})

	oView:CreateHorizontalBox("HEADERBOX",55)
	oView:CreateFolder("FOLDER","HEADERBOX")

	oView:AddSheet("FOLDER", 'SHEET1',  STR0011)
	oView:AddSheet("FOLDER", 'SHEET5',  STR0014)

	oView:CreateHorizontalBox("HEADER1",100,,,"FOLDER",'SHEET1')
	oView:CreateHorizontalBox("F5PHEADERBOX",100,,,"FOLDER",'SHEET5')

	oView:SetOwnerView("F35_M", "HEADER1")
	oView:SetOwnerView("F5P_D", "F5PHEADERBOX")

	oView:CreateHorizontalBox("ITEMBOX", 35)
	oView:CreateHorizontalBox("TOTALBOX",10)
	oView:SetOwnerView("F36_D", "ITEMBOX")
	oView:SetOwnerView("F35_T", "TOTALBOX")

	oView:AddIncrementField("F36_D", "F36_ITEM")
	oView:AddIncrementField("F5P_D", "F5P_ITEM")
	oView:AddUserButton(STR0030, '', {|| RU09T0907_ShowOriginalVat(oModel)})
	oView:AddUserButton(STR0031, '', {|| RU09T0912_ShowOriginalULCD(oModel)})

	oStructF35:SetProperty("F35_VATCD2", MVC_VIEW_CANCHANGE, .T.)
	oStructF35:SetProperty("F35_PDATE", MVC_VIEW_CANCHANGE, .F.)
	oStructF35:SetProperty("F35_CONUNI", MVC_VIEW_CANCHANGE, .F.)
Return(oView)

/*{Protheus.doc} BrowseDef(
Creates the browser for Adjustive Sales Documents
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function BrowseDef()
	Local oBrowse As Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("F35")
	oBrowse:SetDescription(STR0008)
	oBrowse:SetFilterDefault("F35_TYPE = " + ToQuotes(ADJUSTMENT_VAT_INVOICE))
	oBrowse:SetWalkThru(.T.)
Return(oBrowse)

/*{Protheus.doc} MenuDef
Creates a menu for Adjustive Sales Documents
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function MenuDef()
	Local aMenu    as Array

	aMenu := {}
 	aAdd( aMenu, { STR0003, "RU09T0902_Add_AdjVatInvoice(.T.)",     0, 3, 0, NIL } )
	aAdd( aMenu, { STR0004, "RU09T0903_Edit_AdjVatInvoice(.F.)",    0, 4, 0, NIL } )
	aAdd( aMenu, { STR0002, "RU09T0908_View_AdjVatInvoice(.F.)",    0, 2, 0, NIL } )
	aAdd( aMenu, { STR0005, "RU09T0904_Delete_AdjVatInvoice(.F.)",  0, 5, 0, NIL } )
Return aMenu

/*{Protheus.doc} RU09T0907_ShowOriginalVat
Find and open original VAT of opened Adj. Sales Document
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0907_ShowOriginalVat(oModel as Object)
	Local cNameOper  as Character
	Local oModelOper as Object
	Local cKeyOri as Character
	Local nOrdF35Key := 3

	dbSelectArea("F35")
	dbSetOrder(nOrdF35Key)

	If !oModel:IsActive()
		RU99XFUN05_Help(STR0034)
	Else
		cKeyOri := oModel:GetModel("F35MASTER"):GetValue("F35_KEYORI")
	
		If F35->(dbSeek(xFilial("F35") + cKeyOri))
			cNameOper := "RU09T02RUS"
			oModelOper := FWLoadModel(cNameOper)
			FwExecView(, cNameOper, MODEL_OPERATION_VIEW,/* oDlg */,{|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oModelOper/*oModelAct*/)//open view of operation
		Else
			RU99XFUN05_Help(STR0015)
		EndIf
	EndIf
Return

/*{Protheus.doc} JoinFields
Join field values to make a key. Field names are without table prefix
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function JoinFields(oModel as Object, aShorts as Array)
	Local cField     as Character
	Local cKey       as Character
	Local cTabPrefix as Character
	Local nI         as Numeric

	cTabPrefix := Left(oModel:CID, 3) + "_"
	cKey := ""

	For nI := 1 To Len(aShorts)
		cField := cTabPrefix + aShorts[nI]
		cKey += oModel:GetValue(cField)
	Next nI
Return cKey

/*{Protheus.doc} RU09T0912_ShowOriginalULCD
Find and open original ULCD of opened Adj. Sales Document
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0912_ShowOriginalULCD(oModel as Object)
	Local cKeyOrd2   as Character
	Local cNameOper  as Character
	Local oModelOper as Object

	If !oModel:IsActive()
		RU99XFUN05_Help(STR0034)
	Else
		oHead := oModel:GetModel("F35MASTER")

		// F5Y_FILIAL+F5Y_CLIENT+F5Y_BRANCH+F5Y_DOC+F5Y_SERIE 
		cKeyOrd2 := xFilial("F5Y") + JoinFields(oHead, {"CLIENT", "BRANCH", "INVDOC", "INVSER"})

		dbSelectArea("F5Y")
		dbSetOrder(2)

		If F5Y->(dbSeek(cKeyOrd2))
			cNameOper := "RU05D01"
			oModelOper := FWLoadModel(cNameOper)
			FwExecView(, cNameOper, MODEL_OPERATION_VIEW,/* oDlg */,{|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oModelOper/*oModelAct*/)//open view of operation
		Else 
			RU99XFUN05_Help(STR0016)
		EndIf
	EndIf
Return

/*{Protheus.doc} SaveModel
RU09T09 model commitment
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function SaveModel(oModel as Object)
	Local aArea      as Array
	Local lRet       as Logical
	Local nOperation as Numeric

	nOperation := oModel:GetOperation()
	aArea := GetArea()
	Do Case
		Case nOperation == MODEL_OPERATION_INSERT
			lRet := SaveInsert(oModel)

		Case nOperation == MODEL_OPERATION_UPDATE
			lRet := SaveUpdate(oModel)

		Case nOperation == MODEL_OPERATION_DELETE
			lRet := SaveDelete(oModel)

		Otherwise 
            lRet := .F.
    EndCase

	RestArea(aArea)
Return lRet

/*{Protheus.doc} SaveInsert
RU09T09 model commitment for "Add" operation
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function SaveInsert(oModel as Object)
	Local cKey      as Character
	Local cNMBAlias as Character
	Local cNumber   as Character
	Local lRet      as Logical
	Local oModelM   as Object

	oModelM := oModel:GetModel("F35MASTER")
	cNMBAlias := "VATINV"

	cKey := retKey() // copy from ru09t02
	While !(MayIUseCode("RU09T09" + cKey))
		cKey := Soma1(cKey)
	EndDo

	FreeUsedCode(.T.)// copy also
	oModelM:SetValue("F35_KEY", cKey)
	cNumber := RU09D03NMB(cNMBAlias, Nil, xFilial("F35"))
	lRet := !Empty(cNumber)

	If lRet
		Begin Transaction
				FWFormCommit(oModel)
				//ctbVAT(oModel, .T.)
				If (oModelM:GetValue("F35_ATBOOK") == USE_AUTO_BOOK)
					//gravaBook(oModel)
				EndIf
			// Creating Outflow VAT Movements
			RU09D07Add(oModel)
		End Transaction

	Else
		RU99XFUN05_Help(STR0017)
	EndIf

Return lRet

/*{Protheus.doc} SaveUpdate
RU09T09 model commitment for "Update" operation
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function SaveUpdate(oModel as Object)
	Local lRet       as Logical
	Local oModelM    as Object

	oModelM := oModel:GetModel("F35MASTER")
	lRet    := Empty(oModelM:GetValue("F35_BOOK"))
	
	If (lRet)
		Begin Transaction
			FWFormCommit(oModel)
			// Updating Outflow VAT Movements
			RU09D07Edt(oModel)
		End Transaction	
	Else
		RU99XFUN05_Help(STR0018)
	EndIf
Return lRet 

/*{Protheus.doc} SaveDelete
RU09T09 model commitment for "Delete" operation
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function SaveDelete(oModel as Object)
	Local lRet    as Logical
	Local oModelM as Object

	oModelM := oModel:GetModel("F35MASTER")
	lRet := Empty(oModelM:GetValue("F35_BOOK"))

	If (lRet)
		Begin Transaction
			// Posting accounting entries.
			//ctbVAT(oModel, .F.)
			FWFormCommit(oModel)
			// Deleting Outflow VAT Movements
			RU09D07Del(oModel)
		End Transaction	
	Else	
		RU99XFUN05_Help(STR0019)
	EndIf
Return lRet

/*{Protheus.doc} TabAsTab
Prepare table name for SQL query, use original name
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function TabAsTab(cTableName as Character)
Return RetSQLName(cTableName) + " AS " + cTableName

/*{Protheus.doc} RU09T0901_GetSalesBooks
Get array of sales book names which contain given cF35Key 
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0901_GetSalesBooks(cF35Key as Character)
	Local aSaleBooks as Array
	Local cQuery     as Character
	cQuery := " SELECT DISTINCT F39_CODE FROM "  + TabAsTab("F39")
	cQuery += " INNER JOIN "            + TabAsTab("F3A") 
	cQuery += " ON F3A_CODE = F39_CODE AND F39_FILIAL = F3A_FILIAL"

	cQuery += " WHERE F39_FILIAL = "  + ToQuotes(xFilial("F5Y"))
	cQuery += " AND F3A.F3A_KEY = "   + ToQuotes(cF35Key)
	cQuery += " AND F39.D_E_L_E_T_ = ' '"

	aSaleBooks := RU09T0906_QueryToList(cQuery, "F39_CODE")	
Return aSaleBooks

/*{Protheus.doc} RU09T0902_Add_AdjVatInvoice
Creation of Adj Vat Invoice, lNeedFocus is true for RU09T09
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0902_Add_AdjVatInvoice(lNeedFocus as Logical)
	Local lRet       as Logical
	Local oModel     as Object
	Local oModelDet  as Object
	Local oModelHead as Object
	Local oModelDocs as Object
	lRet := .T.

	If lNeedFocus
		RU05D01(CALLER_ADJ_SALES_VAT_INVOICE)
	Else
		If RU09T0905_UlcdHasCorrectiveInvoice(.F.)
			RU99XFUN05_Help(STR0020)
			lRet := .F.
		EndIf

		If lRet
			oModel := FWLoadModel("RU09T09")
			oModelHead := oModel:GetModel("F35MASTER")
			oModelDet  := oModel:GetModel("F36DETAIL")
			oModelDocs := oModel:GetModel("F5PDETAIL")
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()
		
			If !FillNewFields(oModelHead)
				RU99XFUN05_Help(STR0021)
				lRet := .F.
			EndIf
		EndIf

		If lRet
			If !FillFromUlcd(oModelHead, oModelDet)
				RU99XFUN05_Help(STR0022)
				lRet := .F.
			EndIf
		EndIf

		If lRet
			If !FindVatInvoiceFromUlcd()
				RU99XFUN05_Help(STR0023)
				lRet := .F.
			EndIf
		EndIf

		If lRet 
			If !FillFromVat(oModelHead, oModelDet, oModelDocs)
				RU99XFUN05_Help(STR0024)
				lRet := .F.
			EndIf
		EndIf

		If lRet
			oModelDet:SetNoInsertLine(.T.)
			FWExecView(STR0003, "RU09T09", MODEL_OPERATION_INSERT,,{|| .T. },,,,,,,oModel)
		EndIf
	EndIf
Return lRet

/*{Protheus.doc} BooksToReport
Join book names to report string 
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function BooksToReport(aSaleBooks as Array)
	Local cMsgMany   as Character
	Local cMsgSingle as Character
	Local cReport    as Character
	Local nBook      as Numeric
	Local nBookCount as Numeric
	Local nButOne    as Numeric

	cMsgSingle := STR0028
	cMsgMany   := STR0029
	nBookCount := Len(aSaleBooks)
	nButOne    := nBookCount - 1
	cReport    := ""

	If nBookCount > 0
		If nBookCount == 1
			cReport := cMsgSingle + aSaleBooks[1]
		Else
			cReport := cMsgMany
			For nBook := 1 To nButOne
				cReport += aSaleBooks[nBook] + ", "
			Next nBook
			cReport += aSaleBooks[nBookCount]
		EndIf 
	EndIf
Return cReport

/*{Protheus.doc} RU09T0903_Edit_AdjVatInvoice
Function to open Adj Vat Invoice for editing
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0903_Edit_AdjVatInvoice(lNeedFocus as Logical)
	Local cReport  as Character
	Local lCanEdit as Logical

	lCanEdit := .T.
	cReport := CheckAVAT(lNeedFocus, STR0025)
	If !Empty(cReport)
		lCanEdit := .F.
		RU99XFUN05_Help(cReport)
	EndIf

	If lCanEdit
		If lNeedFocus
			FwExecView(STR0004,'RU09T09', MODEL_OPERATION_UPDATE,,{|| .T.},,,,,,,FWLoadModel('RU09T09'))
		Else 
			FWExecView(STR0004, "RU09T09", MODEL_OPERATION_UPDATE)
		EndIf
	EndIf
Return

/*{Protheus.doc} RU09T0904_Delete_AdjVatInvoice
Function to open Adj Vat Invoice for deletion
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0904_Delete_AdjVatInvoice(lNeedFocus as Logical)
	Local cReport    as Character
	Local lCanDelete as Logical

	lCanDelete := .T.
	cReport := CheckAVAT(lNeedFocus, STR0026)
	If !Empty(cReport)
		lCanDelete := .F.
		RU99XFUN05_Help(cReport)
	EndIf
	
	If lCanDelete
		If lNeedFocus
			FwExecView(STR0005,'RU09T09', MODEL_OPERATION_DELETE,,{|| .T.},,,,,,,FWLoadModel('RU09T09'))
		Else 
			FWExecView(STR0005, "RU09T09", MODEL_OPERATION_DELETE)
		EndIf
	EndIf
Return

/*{Protheus.doc} RU09T0905_UlcdHasCorrectiveInvoice
Checks if current selected ULCD has CorrectiveInvoice
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0905_UlcdHasCorrectiveInvoice(lNeedFocus as Logical)
	Local cVat as Character
	cVat := RU09T0910_UlcdGetCorrectiveInvoice(lNeedFocus)
Return !Empty(cVat)

/*{Protheus.doc} RU09T0908_View_AdjVatInvoice
@description Open Adj Vat Invoice for viewing
@author alexander.ivanov
@since 04/03/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0908_View_AdjVatInvoice(lNeedFocus as Logical)
	Local lCanShow as Logical
	lCanShow := .T.
	If lNeedFocus
		If !RU09T0905_UlcdHasCorrectiveInvoice(lNeedFocus)
			RU99XFUN05_Help(STR0035)
			lCanShow := .F.
		EndIf
	EndIf

	If lCanShow
		FwExecView(STR0002,'RU09T09')
	EndIf
Return

/*{Protheus.doc} RU09T0910_UlcdGetCorrectiveInvoice
Returns F35_KEY as ID of Corrective Invoice of selected Ulcd  
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0910_UlcdGetCorrectiveInvoice(lNeedFocus as Logical)
	Local aArea   as Array
	Local cVat    as Character

	cVat := ""
 	aArea := GetArea()
	DBSelectArea("F35")
	F35->(DbSetOrder(8))
	F35->(DbSeek(xFilial("F35") + F5Y->F5Y_UID))
	cVat := F35->F35_KEY

	If !lNeedFocus	
    	RestArea(aArea)
	EndIf
Return cVat


/*{Protheus.doc} FillFromUlcd
Fill Adj. Sales Doc. model from ULCD model
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function FillFromUlcd(oModelHead, oModelDet)
	Local lRet       as Logical
	Local lUseRubles as Logical
	Local nF36_Quant as Numeric
	Local nF36_Value as Numeric
	Local nF36_Vunit as Numeric
	Local nLast      as Numeric
	Local nLine      as Numeric
	Local oModelULCD as Object
	Local oULCDDet   as Object
	Local oULCDHead  as Object

	lRet := .T.
	If F5Y->(EOF())
		lRet := .F.
		RU99XFUN05_Help(STR0027)
	Else
		oModelULCD := FwLoadModel("RU05D01")
		oModelULCD:SetOperation(MODEL_OPERATION_VIEW)
		oModelULCD:Activate()
		oULCDHead := oModelULCD:GetModel("F5YMASTER")
		oULCDDet  := oModelULCD:GetModel("F5ZDETAIL_AFTER")

		// F5Y => F35
		CopyField(oULCDHead, oModelHead, "F5Y_UID    to F35_LOGUID", @lRet)
		CopyField(oULCDHead, oModelHead, "F5Y_CLIENT to F35_CLIENT", @lRet)
		CopyField(oULCDHead, oModelHead, "F5Y_BRANCH to F35_BRANCH", @lRet)

		lUseRubles := oULCDHead:GetValue("F5Y_CONUNI") == "1"
		If lUseRubles
			lRet := lRet .AND. oModelHead:SetValue("F35_INVCUR", CURRENCY_RUB)
			lRet := lRet .AND. oModelHead:SetValue("F35_C_RATE", 1)  
		Else 
			CopyField(oULCDHead, oModelHead, "F5Y_CURREN to F35_INVCUR", @lRet)
			CopyField(oULCDHead, oModelHead, "F5Y_EXGRAT to F35_C_RATE", @lRet)
		EndIf
		
		CopyField(oULCDHead, oModelHead, "F5Y_CNTCOD to F35_CONTRA", @lRet)
		CopyField(oULCDHead, oModelHead, "F5Y_SERIE  to F35_INVSER", @lRet)
		CopyField(oULCDHead, oModelHead, "F5Y_DOC    to F35_INVDOC", @lRet)

		// "1" at the end of field name means "1st currence" - rubles
		// ruble fields must be filled with rubles
		CopyField(oULCDHead, oModelHead, "F5Y_BASE1  to F35_VATBS1", @lRet)
		CopyField(oULCDHead, oModelHead, "F5Y_VATVL1 to F35_VATVL1", @lRet)

		If lUseRubles
			CopyField(oULCDHead, oModelHead, "F5Y_BASE1  to F35_VATBS", @lRet)
			CopyField(oULCDHead, oModelHead, "F5Y_VATVL1 to F35_VATVL", @lRet)
			CopyField(oULCDHead, oModelHead, "F5Y_GROSS1 to F35_VALGR", @lRet)
		Else
			CopyField(oULCDHead, oModelHead, "F5Y_BASE  to F35_VATBS", @lRet)
			CopyField(oULCDHead, oModelHead, "F5Y_VATVL to F35_VATVL", @lRet)
			CopyField(oULCDHead, oModelHead, "F5Y_GROSS to F35_VALGR", @lRet)
		EndIf

		CopyField(oULCDHead,  oModelHead, "F5Y_DATE   to F35_ADJDT",   @lRet)
		CopyField(oULCDHead,  oModelHead, "F5Y_CNRVEN to F35_CNRVEN",  @lRet)
		CopyAnyway(oULCDHead, oModelHead, "F5Y_CNRCOD to F35_CNOR_C",  @lRet)
		CopyAnyway(oULCDHead, oModelHead, "F5Y_CNRBR  to F35_CNOR_B",  @lRet)
		CopyField(oULCDHead,  oModelHead, "F5Y_CNECLI to F35_CNECLI",  @lRet)
		CopyAnyway(oULCDHead, oModelHead, "F5Y_CNECOD to F35_CNEE_C",  @lRet)
		CopyAnyway(oULCDHead, oModelHead, "F5Y_CNEBR  to F35_CNEE_B",  @lRet)
		CopyField(oULCDHead,  oModelHead, "F5Y_CONUNI to F35_CONUNI",  @lRet)
		
		lRet := lRet .AND. UpdateVirt(oModelHead)

		nLast := oULCDDet:Length(.T.)

 		For nLine := 1 To nLast

			// F5Z => F36
			CopyField(oULCDDet,  oModelDet, "F5Z_UIDORI to F36_DOCKEY", @lRet)
			CopyField(oULCDDet,  oModelDet, "F5Z_UM     to F36_UM", 	@lRet)
			CopyField(oULCDDet,  oModelDet, "F5Z_VATCOD to F36_VATCOD", @lRet)

			// ruble fields must be filled with rubles
			CopyField(oULCDDet,  oModelDet, "F5Z_BASE1  to F36_VATBS1", @lRet)
			CopyField(oULCDDet,  oModelDet, "F5Z_VATVL1 to F36_VATVL1", @lRet)

			If lUseRubles
				CopyField(oULCDDet,  oModelDet, "F5Z_BASE1  to F36_VATBS", @lRet)
				CopyField(oULCDDet,  oModelDet, "F5Z_GROSS1 to F36_VALGR", @lRet)
				CopyField(oULCDDet,  oModelDet, "F5Z_VATVL1 to F36_VATVL", @lRet)
			Else
				CopyField(oULCDDet,  oModelDet, "F5Z_BASE  to F36_VATBS", @lRet)
				CopyField(oULCDDet,  oModelDet, "F5Z_GROSS to F36_VALGR", @lRet)
				CopyField(oULCDDet,  oModelDet, "F5Z_VATVL to F36_VATVL", @lRet)
			EndIf

			CopyField(oULCDDet,  oModelDet, "F5Z_VATRT  to F36_VATRT",  @lRet)
			CopyField(oULCDDet,  oModelDet, "F5Z_ITEM   to F36_INVIT",  @lRet)
			CopyField(oULCDDet,  oModelDet, "F5Z_FDESC  to F36_DESC",   @lRet)
			CopyField(oULCDDet,  oModelDet, "F5Z_ITMCOD to F36_ITMCOD", @lRet)

			nF36_Quant := oULCDDet:GetValue("F5Z_QUANT")
			lRet := lRet .AND. oModelDet:SetValue("F36_QUANT", nF36_Quant)
			nF36_Value := oULCDDet:GetValue(Iif(lUseRubles,"F5Z_BASE1","F5Z_BASE"))
			lRet := lRet .AND. oModelDet:SetValue("F36_VALUE", nF36_Value)
			nF36_Vunit := 0
			If (nF36_Quant > 0)
				nF36_Vunit := nF36_Value / nF36_Quant
			EndIf
			lRet := lRet .AND. oModelDet:SetValue("F36_VUNIT", nF36_Vunit)
			
			// F5Y => F36 
			CopyField(oULCDHead,  oModelDet, "F5Y_SERIE to F36_INVSER", @lRet)
			CopyField(oULCDHead,  oModelDet, "F5Y_DOC   to F36_INVDOC", @lRet)
			CopyField(oULCDHead,  oModelDet, "F5Y_DATE  to F36_ITDATE", @lRet)

			If nLine <> nLast
				oModelDet:AddLine()
				oULCDDet:GoLine(nLine + 1)
				oModelDet:GoLine(nLine + 1)
			EndIf

		Next nLine
		oModelDet:GoLine(1)
	EndIf

Return lRet

/*{Protheus.doc} FillFromVat
Fill Adj. Sales Doc. model from VAT model
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function FillFromVAT(oModelHead, oModelDet, oModelDocs)
	Local aPattern   as Array
	Local cNextAdjNr as Character
	Local lFound     as Logical
	Local lRet       as Logical
	Local nLast      as Numeric
	Local nLine      as Numeric
	Local nNextAdjNr as Numeric
	Local oModelVat  as Object
	Local oVatDet    as Object
	Local oVatHead   as Object
	Local oVatPayDoc as Object

	lRet := .T.
	oModelVat := FwLoadModel("RU09T02")
	oModelVat:SetOperation(MODEL_OPERATION_VIEW)
	oModelVat:Activate()
	oVatHead   := oModelVat:GetModel("F35MASTER")
	oVatDet    := oModelVat:GetModel("F36DETAIL")
	oVatPayDoc := oModelVat:GetModel("F5PDETAIL")

	// Increment adjustment number
	nNextAdjNr := Val(oVatHead:GetValue("F35_ADJNR")) + 1
	cNextAdjNr := PadR(nNextAdjNr, TamSX3("F35_ADJNR")[1], " ")
	oModelHead:SetValue("F35_ADJNR", cNextAdjNr)

	CopyField(oVatHead, oModelHead, "F35_INVDT  to F35_INVDT",  @lRet)
	CopyField(oVatHead, oModelHead, "F35_KPP_CO to F35_KPP_CO", @lRet)
	CopyField(oVatHead, oModelHead, "F35_DOC    to F35_DOC",    @lRet)
	CopyField(oVatHead, oModelHead, "F35_PDATE  to F35_PDATE",  @lRet)
	CopyField(oVatHead, oModelHead, "F35_KPP_CL to F35_KPP_CL", @lRet)
	CopyField(oVatHead, oModelHead, "F35_GOVCTR to F35_GOVCTR", @lRet)
	CopyField(oVatHead, oModelHead, "F35_MOEDA  to F35_MOEDA",  @lRet)
	CopyField(oVatHead, oModelHead, "F35_MOEDES to F35_MOEDES", @lRet)
	CopyField(oVatHead, oModelHead, "F35_KEY    to F35_KEYORI", @lRet)
	CopyField(oVatHead, oModelHead, "F35_VATCD2 to F35_VATCD2", @lRet)
	CopyField(oVatHead, oModelHead, "F35_ADJNR  to F35_ANRORI", @lRet)
	CopyField(oVatHead, oModelHead, "F35_ADJDT  to F35_ADTORI", @lRet)
	CopyField(oVatHead, oModelHead, "F35_TYPE   to F35_TYPORI", @lRet)
	CopyField(oVatHead, oModelHead, "F35_DOC    to F35_DOCORI", @lRet)
	CopyField(oVatHead, oModelHead, "F35_PDATE  to F35_PDTORI", @lRet)
	CopyField(oVatHead, oModelHead, "F35_F5QUID to F35_F5QUID", @lRet)

	nLast := oVatDet:Length(.T.)

	For nLine := 1 To nLast
		oVatDet:GoLine(nLine)
		aPattern := {{"F36_FILIAL", xFilial("F36")}}
		AAdd(aPattern, {"F36_ITEM", oVatDet:GetValue("F36_ITEM")})
		AAdd(aPattern, {"F36_ITMCOD", oVatDet:GetValue("F36_ITMCOD")})
		
		lFound := oModelDet:SeekLine(aPattern)
		If lFound
			CopyField(oVatHead, oModelDet, "F35_KEY    to F36_KEY",    @lRet)
			CopyField(oVatHead, oModelDet, "F35_DOC    to F36_DOC",    @lRet)
			CopyField(oVatDet, oModelDet,  "F36_ORIGIN to F36_ORIGIN", @lRet)
			CopyField(oVatDet, oModelDet,  "F36_CUSCOD to F36_CUSCOD", @lRet)
		EndIf
		
	Next nLine

	oModelDet:GoLine(1)
	lRet := lRet .and. AddPayDocs(oVatPayDoc, oModelDocs)
Return lRet

/*{Protheus.doc} FillNewFields
Fill some fields specific for Adj. Sales Doc. model
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function FillNewFields(oModelHead)
	Local lRet as Logical

	oModelHead:SetValue("F35_ATBOOK", "2") // initiation trick
	lRet := oModelHead:SetValue("F35_ATBOOK", "2")

	lRet := lRet .AND. oModelHead:SetValue("F35_TYPE",   ADJUSTMENT_VAT_INVOICE)
	lRet := lRet .AND. oModelHead:SetValue("F35_ORIGIN", "2")
	lRet := lRet .AND. oModelHead:SetValue("F35_TDATE",  Date())
Return lRet

// TODO: move it to RU99XFUN_GENFUN.PRW
/*{Protheus.doc} RU09T0906_QueryToList
Return list of found values using SQL query string and field name
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0906_QueryToList(cQuery as Character, cField as Character)
	Local aArea     as Array
	Local aList     as Array
	Local cExpress  as Character
	Local cTab      as Character

	aList := {}
	aArea := GetArea()
	cQuery := ChangeQuery(cQuery)
	cTab := RU01GETALS(cQuery)
	DbSelectArea(cTab)
	DbGoTop()

	While !(EOF())
		cExpress := "(cTab)->" + cField
		AAdd(aList, &cExpress)                                                                                               
		DbSkip()	
	EndDo

	(cTab)->(DBCloseArea())
	RestArea(aArea)
Return aList


/*{Protheus.doc} FindVatInvoiceFromUlcd
Returns .T. if  original Vat found for selected ULCD. Shy result: positioning on found VAT record
Recuires positioning on some ULCD record
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function FindVatInvoiceFromUlcd()

	// F35_FILIAL+F35_INVSER+F35_INVDOC+F35_CLIENT+F35_BRANCH
	DBSelectArea("F35")
	F35->(DbSetOrder(4))
Return F35->(dbSeek(xFilial("F35") + F5Y->(F5Y_SERORI + F5Y_DOCORI + F5Y_CLIENT + F5Y_BRANCH)))


/*{Protheus.doc} ToQuotes
Encloses string to single quotes to make more readable SQL queries
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function ToQuotes(cString as Character)
Return  "'" + cString  + "'"


/*{Protheus.doc} CopyField
Copy field from first model to the field in second one, returns .T. if succeed
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function CopyField(oModelFrom, oModelTo, cAtoB, lRet)
	Local aAB    as Array
	Local cFrom  as Character
	Local cTo    as Character
	Local nWordCount as Numeric
	cAtoB:= Upper(AllTrim(cAtoB)) // "F5Z_HORNS TO F35_HOOFS"
	aAB := StrTokArr(cAtoB, " ")
	nWordCount := 3
	If Len(aAB) != nWordCount
		lRet := .F.
	Else 
		cFrom := aAB[1]
		cTo := aAB[3]
		lRet := lRet .And. oModelTo:SetValue((cTo), oModelFrom:GetValue(cFrom))
	EndIf
Return


/*{Protheus.doc} CopyAnyway
Copy field from first model to the field in second one WITHOUT VALIDATIONS, returns .T. if succeed
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function CopyAnyway(oModelFrom, oModelTo, cAtoB, lRet)
	Local aAB    as Array
	Local cFrom  as Character
	Local cTo    as Character
	Local nWordCount as Numeric
	cAtoB:= Upper(AllTrim(cAtoB)) // "F5Z_HORNS TO F35_HOOFS"
	aAB := StrTokArr(cAtoB, " ")
	nWordCount := 3
	If Len(aAB) != nWordCount
		lRet := .F.
	Else 
		cFrom := aAB[1]
		cTo := aAB[3]
		lRet := lRet .And. oModelTo:LoadValue((cTo), oModelFrom:GetValue(cFrom))
	EndIf
Return


/*{Protheus.doc} retKey
Copypasted from RU09T02RUS
TODO: deduplicate!
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function retKey()
Local cQuery as Character
Local cTab as Character
Local cRet as Character
Local cProx as Character
Local aArea as Array

aArea := GetArea()

cQuery := " SELECT COALESCE(MAX(F35_KEY), '0') AS F35_KEY"
cQuery += " FROM " + RetSQLName("F35") + " T0"
cQuery += " WHERE T0.F35_FILIAL = '" + xFilial("F35") + "'"
cQuery += " AND T0.D_E_L_E_T_ = ' '"

cTab := MPSysOpenQuery(cQuery)
DbSelectArea((cTab))
(cTab)->(DbGoTop())

While ((cTab)->(!Eof()))
	cProx := Soma1(AllTrim((cTab)->F35_KEY))
	cRet := StrZero(Val(cProx), TamSX3("F36_KEY")[1])
	(cTab)->(DbSkip())
EndDo

(cTab)->(DbCloseArea())
RestArea(aArea) 
Return(cRet)


/*{Protheus.doc} CheckAVAT
@description Generates report of reasons why you cannot change Adj. VAT, otherwise returns ""
@author alexander.ivanov
@since 14/05/2020
@version 1.0
@project MA3 - Russia
*/
Static Function CheckAVAT(lNeedFocus as Logical, cMsgStart as Character)
	Local aSaleBooks as Array
	Local cF35_KEY   as Character
	Local cReport    as Character

	cReport := ""
	aArea = GetArea()

	If lNeedFocus
		cF35_KEY := RU09T0910_UlcdGetCorrectiveInvoice(lNeedFocus)
		If Empty(cF35_KEY)
			cReport := STR0035
		Else
			aSaleBooks := RU09T0901_GetSalesBooks(cF35_KEY)
			If Len(aSaleBooks) > 0
				cReport := cMsgStart + BooksToReport(aSaleBooks)
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return cReport


/*{Protheus.doc} AddPayDocs
@description Copy payment documents from original VAT to Adj.VAT
@author alexander.ivanov
@since 21/05/2020
@version 1.0
@project MA3 - Russia
*/
Static Function AddPayDocs(oVatPDocs, oModelDocs)
	Local lRet     as Logical
	Local nLast    as Numeric
	Local nLine    as Numeric
	lRet := .T.
	nLast := oVatPDocs:Length(.T.)
	
	For nLine := 1 To nLast
		CopyField(oVatPDocs, oModelDocs, "F5P_ADVDOC to F5P_ADVDOC", @lRet)
		CopyField(oVatPDocs, oModelDocs, "F5P_ADVDT  to F5P_ADVDT",  @lRet)
		CopyField(oVatPDocs, oModelDocs, "F5P_UIDF4C to F5P_UIDF4C", @lRet)
		If nLine <> nLast
			oModelDocs:AddLine()
			oVatPDocs:GoLine(nLine + 1)
			oModelDocs:GoLine(nLine + 1)
		EndIf	
	Next nLine
Return lRet	

/*{Protheus.doc} UpdateVirt
@description Updates some virtual fields in F35 like if we can call x3_relacao again
@author alexander.ivanov
@since 27/05/2020
@version 1.0
@project MA3 - Russia
*/
Static Function UpdateVirt(oModelHead as Object)
	Local cCneeDescr as Character
	Local cCnorDescr as Character
	Local cCurrDescr as Character
	Local cInvoicCur as Character
	Local cSeekCnee  as Character
	Local cSeekCnor  as Character
	Local lRet       as Logical

	lRet := .T.
	cInvoicCur := oModelHead:GetValue("F35_INVCUR")
	cCurrDescr := Posicione("CTO", 1, xFilial("CTO") + cInvoicCur, "CTO_SIMB")
	lRet := lRet .And. oModelHead:SetValue("F35_ICUDES", cCurrDescr)

	cSeekCnee  := xFilial('SA1') + oModelHead:GetValue("F35_CNEE_C") + oModelHead:GetValue("F35_CNEE_B")
	cCneeDescr := Posicione('SA1', 1, cSeekCnee, 'A1_NREDUZ')
	lRet := lRet .AND. oModelHead:SetValue("F35_CNEDES", cCneeDescr)

	cSeekCnor  := xFilial('SA2') + oModelHead:GetValue("F35_CNOR_C") + oModelHead:GetValue("F35_CNOR_B")
	cCnorDescr := Posicione('SA2', 1, cSeekCnor, 'A2_NREDUZ')
	lRet := lRet .AND. oModelHead:SetValue("F35_CNRDES", cCnorDescr)
Return lRet


/*{Protheus.doc} RU09T0913_FilterULCDsForAddingAdjVAT
@description Filtering function, returns .T. if AdjVAT can be created from current ULCD  
@author alexander.ivanov
@since 04/06/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T0913_FilterULCDsForAddingAdjVAT()
	Local aArea as Array
	Local lRet  as Logical

	aArea := GetArea()
	DBSelectArea("F35")
	F35->(DbSetOrder(4))
	lRet := F35->(dbSeek(xFilial("F35") + F5Y->(F5Y_SERORI + F5Y_DOCORI + F5Y_CLIENT + F5Y_BRANCH)))
	RestArea(aArea)

	If lRet 
		lRet := Empty(RU09T0910_UlcdGetCorrectiveInvoice(.F.))
	EndIf 
Return lRet

/*{Protheus.doc} RU09T00914_F35_Origin_Combo
@description Combobox for f35_origin
@author alexander.ivanov
@since 17/07/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09T00914_F35_Origin_Combo()
   Local aItems as Array
	aItems := {STR0036, STR0037}
Return RU99XFUN04_MakeCombo(aItems)