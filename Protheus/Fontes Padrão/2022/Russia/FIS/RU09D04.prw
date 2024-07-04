#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'RU09XXX.ch'

#define F34_INVOICE_MOVEMENT		"01"
#define F34_BOOK_MOVEMENT			"02"
#define F34_WRITE_OFF_MOVEMENT		"03"
#define F34_RESTORATION_MOVEMENT	"04"


/*/{Protheus.doc} RU09D04
All the Movements of money values from VAT Purchases Invoices.
There is three places, where values can be stored: Balances table, Write-Off table and VAT Purchases Invoices table.
@author Artem Kostin
@since 1/16/2018
@version P12.1.20
@type function
/*/
Function RU09D04()
Local oBrowse as Object

// Initalization of the table, if they do not exist.
DbSelectArea("F34")
F34->(dbSetOrder(1))

oBrowse := FWLoadBrw("RU09D04")
oBrowse:Activate()
Return(.T.)
// The end of Function RU09D04()



/*/{Protheus.doc} BrowseDef
Defines the browser for the VAT Purchases Invoices Movements.
@author Artem Kostin
@since 26/03/2017
@version P12.1.20
@type function
/*/
Static Function BrowseDef()
Local oBrowse as Object

Private aRotina as Array

aRotina := MenuDef()
oBrowse := FwMBrowse():New()

oBrowse:SetAlias("F34")
oBrowse:SetDescription(STR0939)
oBrowse:DisableDetails()
Return(oBrowse)



/*/{Protheus.doc} MenuDef
Defines the menu to VAT Purchases Invoices Movements.
@author Artem Kostin
@since 01/16/2017
@version P12.1.20
@type function
/*/
Static Function MenuDef()
Local aRet as Array
aRet := {{STR0902, "", 0, 2, 0, Nil}}	// Browser Menu is empty
Return(aRet)
// The end of Function MenuDef()



/*/{Protheus.doc} ModelDef
Creates the model of VAT Purchases Invoices Movements.
@author Artem Kostin
@since 01/16/2017
@version P12.1.20
@type function
/*/
Static Function ModelDef()
Local oModel as Object

Local oCab as Object
Local oStructF34 as Object

oCab := FWFormModelStruct():New()
oStructF34 := FWFormStruct(1, "F34")

oModel := MPFormModel():New("RU09D04")
// FWFORMMODELSTRUCT (): AddTable (<cAlias>, [aPK], <cDescription>, <bRealName>) -> NIL
oCab:AddTable('F34', ,'F34',)
//FWFORMMODELSTRUCT (): AddField (<cTitle>, <cTooltip>, <cIdField>, <cType>, <nSize>, [nDecimal], [bValid], [bWhen], [aValues], [lBrigat], [bInit] <lKey>, [lNoUpd], [lVirtual], [cValid]) -> NIL
oCab:AddField("Id","","F34_CAMPO","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||'"1"'},/*Key*/,.F.,.T.,)

oModel:AddFields("F34MASTER", /*cOwner*/, oCab , , ,{|o|{}})
oModel:GetModel('F34MASTER'):SetDescription(STR0939)
oModel:SetPrimaryKey({})

oModel:AddGrid("F34DETAIL", "F34MASTER", oStructF34)
oModel:SetOptional("F34DETAIL", .T.)
Return(oModel)
// The end of Function ModelDef()



/*/{Protheus.doc} ViewDef
Creates the view of VAT Purchases Invoices Movements.
@author Artem Kostin
@since 01/16/2017
@version P12.1.20
@type function
/*/
Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStructF34 as Object

oModel := FwLoadModel("RU09D04")
oStructF34 := FWFormStruct(2, "F34")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddGrid("F34_D", oStructF34, "F34DETAIL")

oView:CreateHorizontalBox("MAINBOX", 100)

oView:SetOwnerView("F34_D", "MAINBOX")
oView:SetNoInsertLine("F34_D")
oView:SetNoUpdateLine("F34_D")
oView:SetNoDeleteLine("F34_D")
Return(oView)
// The end of Function ViewDef()



/*/{Protheus.doc} RU09D04Add
Creates a procedure to register the new movements of VAT Purchases Invoices values.
Function should be used in the moment, when Object Model is commited, but still exists.
@author Artem Kostin
@since 01/16/2017
@version P12.1.20
@type function
/*/
Function RU09D04Add(oModel as Object)
Local lRet := .T.

Local cTab := ""
Local cModelId as Character

Local cEmptyBK as Character
Local cEmptyBC as Character

Local nLine as Numeric

// Checks, If the routine get an argument of Object type and If the routine has an Object to extract data.
If (ValType(oModel) != "O")
	lRet := .F.
	Help("",1,"RU09D04Add01",,STR0910,1,0)
EndIf

If lRet
	cModelId := oModel:GetId()
	// If the routine is called from Purchases VAT Invoices.
	dbSelectArea("F34")
	If cModelId == "RU09T03"
		F34->(dbSetOrder(2))
		cSeek := oModel:getModel("F37master"):getValue("F37_KEY")
	// If the routine is called from Purchases Book
	ElseIf cModelId == "RU09T05"
		F34->(dbSetOrder(1))
		cSeek := oModel:getModel("F3BMASTER"):getValue("F3B_BOOKEY")
	// If the routine is called from Write-Off Document.
	ElseIf cModelId == "RU09T06"
		F34->(dbSetOrder(1))
		cSeek := oModel:getModel("F3DMASTER"):getValue("F3D_WRIKEY")
	// If the routine is called from VAT Restoration
	ElseIf (cModelId == "RU09T08")
		F34->(dbSetOrder(1))
		cSeek := oModel:getModel("F52MASTER"):getValue("F52_RESKEY")
	Else // Caller is unknown.
		lRet := .F.
		Help("",1,"RU09D04Add02",,STR0926,1,0)
	EndIf
EndIf

// Performs an SQL query and fills the cTab alias.
lRet := lRet .and. getTempTable(oModel, @cTab)

If lRet
	dbSelectArea("F34")
	// During inclusion an order is not important.

	cEmptyBK := Space(TamSX3("F34_BOOKEY")[1])
	cEmptyBC := Space(TamSX3("F34_BOOK")[1])

	Begin Transaction
	// Setting values into the Movements table model line by line.
	nLine := 1
	(cTab)->(DbGoTop())
	While !(cTab)->(Eof())
		RecLock("F34", .T.)

		F34->F34_FILIAL := xFilial('F34')
		F34->F34_DATE := StoD((cTab)->DATE)	// The Movement Date must be equal real inclusion date of th VAT Purchases Invoice
		F34->F34_KEY := (cTab)->VAT_KEY	// VAT Invoice Key
		F34->F34_SUPPL := (cTab)->SUPPLIER	// Supplier's Code
		F34->F34_SUPUN := (cTab)->SUPP_BRANCH	// Supplier's Unit Code
		F34->F34_DOC := (cTab)->DOC_NUM	// Doc. Number of the VAT Invoice
		F34->F34_PDATE := StoD((cTab)->PRINT_DATE)	// Print Date of the VAT Invoice
		F34->F34_VATCOD := (cTab)->INTCODE	// Internal VAT Code
		F34->F34_VATCD2 := (cTab)->EXTCODE	// External (Operational) VAT Code
		F34->F34_VATRT := (cTab)->VAT_RATE	// VAT Rate of Movement
		F34->F34_VATBS := (cTab)->VAT_BASE	// VAT Base of Movement
		F34->F34_VALUE := (cTab)->VAT_VALUE	// Movement Value
		F34->F34_USER := __cUserID	// Movement User Code

		// Behavour is nested according to the caller. Could be of three.
		// If the routine is called from Purchases VAT Invoices.
		If cModelId == "RU09T03"
			F34->F34_TYPE := F34_INVOICE_MOVEMENT	// Type of the Movement
			F34->F34_BOOKEY := cEmptyBK	// Internal Purchase Book Key
			F34->F34_BOOK := cEmptyBC	// Purchases Book Code

		// If the routine is called from Purchases Book.
		ElseIf cModelId == "RU09T05"
			F34->F34_TYPE := F34_BOOK_MOVEMENT	// Type of the Movement
			F34->F34_BOOKEY := (cTab)->BOOK_KEY	// Internal Purchase Book Key
			F34->F34_BOOK := (cTab)->BOOK_CODE	// Purchases Book Code
			F34->F34_TG_COD := (cTab)->TARGET_CODE	// target code

		// If the routine is called from Write-Off Document.
		ElseIf cModelId == "RU09T06"
			F34->F34_TYPE := F34_WRITE_OFF_MOVEMENT	// Type of the Movement
			F34->F34_BOOKEY := (cTab)->BOOK_KEY	// Internal Purchase Book Key
			F34->F34_BOOK := (cTab)->BOOK_CODE	// Purchases Book Code

		// If the routine is called from VAT Restoration
		ElseIf (cModelId == "RU09T08")
			F34->F34_TYPE := F34_RESTORATION_MOVEMENT	// Type of the Movement
			F34->F34_BOOKEY := (cTab)->BOOK_KEY	// Internal VAT Restoration Key
			F34->F34_BOOK := (cTab)->BOOK_CODE	// VAT Restoration Code
			
		EndIf

		MsUnlock("F34")
		(cTab)->(DbSkip())
	EndDo
	End Transaction
EndIf

CloseTempTable(cTab)
Return(lRet)
// The end of Function RU09D04Add



/*/{Protheus.doc} RU09D04Edt
Creates a procedure to register movements updates of VAT Purchases Invoices values.
Function should be used in the moment, when Object Model is commited, but still exists.
@author Artem Kostin
@since 01/16/2017
@version P12.1.20
@type function
/*/
Function RU09D04Edt(oModel as Object)
Local lRet := .T.

Local cTab := ""
Local cTabDel := ""
Local cSeek as Character
Local cModelId as Character

Local cEmptyBK as Character
Local cEmptyBC as Character

Local nLine as Numeric

// Checks, If the routine get an argument of Object type and If the routine has an Object to extract data.
If (ValType(oModel) != "O")
	lRet := .F.
	Help("",1,"RU09D04Edt01",,STR0910,1,0)
EndIf

If lRet
	dbSelectArea("F34")
	cModelId := oModel:GetId()
	If cModelId == "RU09T03"
		F34->(dbSetOrder(1))
	// If the routine is called from Purchases Book
	ElseIf cModelId == "RU09T05"
		F34->(dbSetOrder(1))
	// If the routine is called from Write-Off Document.
	ElseIf cModelId == "RU09T06"
		F34->(dbSetOrder(1))
	// If the routine is called from VAT Restoration
	ElseIf (cModelId == "RU09T08")
		F34->(dbSetOrder(1))
	Else // Caller is unknown.
		Help("",1,"RU09D04Edt02",,STR0926,1,0)
		lRet := .F.
	EndIf
EndIf

// Performs an SQL query and fills the cTab alias.
lRet := lRet .and. getTempTable(oModel, @cTab, @cTabDel)

If lRet
	cEmptyBK := Space(TamSX3("F34_BOOKEY")[1])
	cEmptyBC := Space(TamSX3("F34_BOOK")[1])

	// Setting values into the Movements table model line by line.
	// Purchase VAT is updated. Let's check out what is updated.
	nLine := 1
	F34->(dbGoTop())
	(cTab)->(DbGoTop())
	Begin Transaction
	While !(cTab)->(Eof())
		// cSeek := (cTab)->(BOOK_KEY + VAT_KEY + INTCODE + EXTCODE)
		cSeek := PadR((cTab)->BOOK_KEY, TamSX3("F34_BOOKEY")[1], " ");
				+ PadR((cTab)->VAT_KEY, TamSX3("F34_KEY")[1], " ");
				+ PadR((cTab)->INTCODE, TamSX3("F34_VATCOD")[1], " ");
				+ PadR((cTab)->EXTCODE, TamSX3("F34_VATCD2")[1], " ")
		// If record is found in the Balances Table, update it.
		If !Empty(cSeek)
			If F34->(DbSeek(xFilial("F34") + cSeek))
				RecLock("F34", .F.)

			Else // If record is not found, add it.
				RecLock("F34", .T.)
				F34->F34_FILIAL := xFilial("F34")
			EndIf
			
			F34->F34_DATE := StoD((cTab)->DATE)	// The Movement Date must be equal to the real inclusion date of th VAT Purchases Invoice
			F34->F34_KEY := (cTab)->VAT_KEY	// VAT Invoice Key
			F34->F34_SUPPL := (cTab)->SUPPLIER	// Supplier's Code
			F34->F34_SUPUN := (cTab)->SUPP_BRANCH	// Supplier's Unit Code
			F34->F34_DOC := (cTab)->DOC_NUM	// Doc. Number of the VAT Invoice
			F34->F34_PDATE := StoD((cTab)->PRINT_DATE)	// Print Date of the VAT Invoice
			F34->F34_VATCOD := (cTab)->INTCODE	// Internal VAT Code
			F34->F34_VATCD2 := (cTab)->EXTCODE	// External (Operational) VAT Code
			F34->F34_VATRT := (cTab)->VAT_RATE	// VAT Rate of Movement
			F34->F34_VATBS := (cTab)->VAT_BASE	// VAT Base of Movement
			F34->F34_VALUE := (cTab)->VAT_VALUE	// Movement Value
			F34->F34_USER := __cUserID	// Movement User Code

			// If the routine is called from Purchases VAT Invoices.
			If cModelId == "RU09T03"
				F34->F34_TYPE := F34_INVOICE_MOVEMENT	// Type of the Movement
				F34->F34_BOOKEY := cEmptyBK	// Internal Purchase Book Key
				F34->F34_BOOK := cEmptyBC	// Purchases Book Code
			
			// If the routine is called from Purchases Book
			ElseIf cModelId == "RU09T05"
				F34->F34_TYPE := F34_BOOK_MOVEMENT	// Type of the Movement
				F34->F34_BOOKEY := (cTab)->BOOK_KEY	// Internal Purchase Book Key
				F34->F34_BOOK := (cTab)->BOOK_CODE	// Purchases Book Code
				F34->F34_TG_COD := (cTab)->TARGET_CODE	// target code

			// If the routine is called from Write-Off Document.
			ElseIf cModelId == "RU09T06"
				F34->F34_TYPE := F34_WRITE_OFF_MOVEMENT	// Type of the Movement
				F34->F34_BOOKEY := (cTab)->BOOK_KEY	// Internal Purchase Book Key
				F34->F34_BOOK := (cTab)->BOOK_CODE	// Purchases Book Code

			// If the routine is called from VAT Restoration
			ElseIf (cModelId == "RU09T08")
				F34->F34_TYPE := F34_RESTORATION_MOVEMENT	// Type of the Movement
				F34->F34_BOOKEY := (cTab)->BOOK_KEY	// Internal VAT Restoration Key
				F34->F34_BOOK := (cTab)->BOOK_CODE	// VAT Restoration Code
				F34->F34_TG_COD := (cTab)->TARGET_CODE	// target code

			EndIf
		
			MsUnlock("F34")
		EndIf
		(cTab)->(DbSkip())
	EndDo

	F34->(DbGoTop())
	(cTabDel)->(DbGoTop())
	While !(cTabDel)->(Eof())
		cSeek := PadR((cTabDel)->BOOK_KEY, TamSX3("F34_BOOKEY")[1], " ");
				+ PadR((cTabDel)->VAT_KEY, TamSX3("F34_KEY")[1], " ");
				+ PadR((cTabDel)->INTCODE, TamSX3("F34_VATCOD")[1], " ");
				+ PadR((cTabDel)->EXTCODE, TamSX3("F34_VATCD2")[1], " ")
		// If record is found in the  Balances Table, delete it.
		If !Empty(cSeek) .and. F34->(DbSeek(xFilial("F34") + cSeek))
			RecLock("F34", .F.)
				F34->(DbDelete())
			MsUnlock("F34")
		EndIf

		(cTabDel)->(DbSkip())
	EndDo
	End Transaction
EndIf

CloseTempTable(cTab)
CloseTempTable(cTabDel)

Return(lRet)
// The end of Function RU09D04Edt



/*/{Protheus.doc} RU09D04Del
Creates a procedure to delete movements of VAT Purchases Invoices values.
Function should be used in the moment, when Object Model is commited, but still exists.
@author Artem Kostin
@since 01/22/2017
@version P12.1.20
@type function
/*/
Function RU09D04Del(oModel as Object)
Local lRet := .T.

Local cSeek as Character
Local cModelId as Character

// Checks, If the routine get an argument of Object type and If the routine has an Object to extract data.
If (ValType(oModel) != "O")
	lRet := .F.
	Help("",1,"RU09D04Del01",,STR0910,1,0)
EndIf

If lRet
	cModelId := oModel:GetId()
	// If the routine is called from Purchases VAT Invoices.
	dbSelectArea("F34")
	If cModelId == "RU09T03"
		F34->(dbSetOrder(2))
		cSeek := oModel:getModel("F37master"):getValue("F37_KEY")
	// If the routine is called from Purchases Book
	ElseIf cModelId == "RU09T05"
		F34->(dbSetOrder(3))
		cSeek := oModel:getModel("F3BMASTER"):getValue("F3B_BOOKEY")
	// If the routine is called from Write-Off Document.
	ElseIf cModelId == "RU09T06"
		F34->(dbSetOrder(3))
		cSeek := oModel:getModel("F3DMASTER"):getValue("F3D_WRIKEY")
	// If the routine is called from VAT Restoration Document.
	ElseIf (cModelId == "RU09T08")
		F34->(dbSetOrder(3))
		cSeek := oModel:getModel("F52MASTER"):getValue("F52_RESKEY")
	Else // Caller is unknown.
		lRet := .F.
		Help("",1,"RU09D04Del02",,STR0926,1,0)
	EndIf
EndIf

If lRet
	F34->(DbGoTop())
	Begin Transaction
	While !Empty(cSeek) .and. F34->(dbSeek(xFilial("F34") + cSeek))
		RecLock("F34", .F.)
			F34->(DbDelete())
		MsUnlock("F34")
	EndDo
	End Transaction
EndIf

Return(lRet)
// The end of Function RU09D04Del



/*/{Protheus.doc} getTempTable
Function gets alias of the temporary table and fills this table with the data from the query.
@author Artem Kostin
@since 03/12/2017
@version P12.1.20
@type function
/*/
Static Function getTempTable(oModel as Object, cTab as Character, cTabDel as Character)
Local lRet := .T.

Local cQuery as Character
Local cQforModel as Character
Local cQueryDel as Character
Local cQueryOrder	as Character
Local cModelId as Character

Local cEmptyBK as Character

Default cTab := ""
Default cTabDel := ""

cQueryOrder := " ORDER BY 1, 2, 3, 4, 5"

If lRet
	cQuery := ""
	cQforModel := ""
	cQueryDel := ""
	cModelId := oModel:GetId()
	cEmptyBK := Space(TamSX3("F3B_BOOKEY")[1])

	// If the routine is called from Purchases VAT Invoices.
	If cModelId == "RU09T03"
		cQuery := " SELECT"
		// Order matters
		cQuery += " T0.F37_FILIAL	AS FILIAL,"
		cQuery += " '" + F34_INVOICE_MOVEMENT + "' AS TYPE,"
		cQuery += " T0.F37_KEY		AS VAT_KEY,"
		cQuery += " T1.F38_VATCOD	AS INTCODE,"
		cQuery += " T1.F38_VATCD2	AS EXTCODE,"
		cQuery += " T0.F37_DOC		AS DOC_NUM,"
		cQuery += " T0.F37_RDATE AS DATE,"
		cQuery += " '" + cEmptyBK + "' AS BOOK_KEY,"
		cQuery += " T0.F37_FORNEC AS SUPPLIER,"
		cQuery += " T0.F37_BRANCH AS SUPP_BRANCH,"
		cQuery += " T0.F37_PDATE AS PRINT_DATE,"
		cQuery += " T1.F38_VATRT AS VAT_RATE,"
		cQuery += " SUM(T1.F38_VATBS1) AS VAT_BASE,"
		cQuery += " SUM(T1.F38_VATVL1) AS VAT_VALUE"
		cQuery += " FROM " + RetSQLName("F37") + " AS T0"
		cQuery += " INNER JOIN " + RetSQLName("F38") + " AS T1"
		cQuery += " ON ("
		cQuery += " T1.F38_FILIAL = '" + xFilial("F38") + "'"
		cQuery += " AND T1.F38_KEY = T0.F37_KEY"
		cQuery += " AND T1.D_E_L_E_T_ = ' '"
		cQuery += ")"
		cQuery += " WHERE T0.F37_FILIAL = '" + xFilial("F37") + "'"
		cQuery += " AND T0.F37_KEY = '" + oModel:GetModel("F37master"):GetValue("F37_KEY") + "'"
		cQuery += " AND T0.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY T0.F37_FILIAL,"
		cQuery += " T0.F37_KEY,"
		cQuery += " T0.F37_FORNEC,"
		cQuery += " T0.F37_BRANCH,"
		cQuery += " T0.F37_DOC,"
		cQuery += " T0.F37_RDATE,"
		cQuery += " T0.F37_PDATE,"
		cQuery += " T1.F38_VATCOD,"
		cQuery += " T1.F38_VATCD2,"
		cQuery += " T1.F38_VATRT"

		cQforModel := "	AND T0.F34_KEY = '" + oModel:GetModel("F37master"):GetValue("F37_KEY") + "'"
		cQforModel += "	AND T0.F34_BOOKEY = '" + cEmptyBK + "'"

	// If the routine is called from Purchases Book.
	ElseIf cModelId == "RU09T05"
		cQuery := " SELECT"
		// Order matters
		cQuery += " T0.F3C_FILIAL	AS FILIAL,"
		cQuery += " T0.F3C_BOOKEY	AS BOOK_KEY,"
		cQuery += " T0.F3C_KEY		AS VAT_KEY,"
		cQuery += " T0.F3C_VATCOD	AS INTCODE,"
		cQuery += " T0.F3C_VATCD2	AS EXTCODE,"
		cQuery += " T1.F3B_FINAL AS DATE,"
		cQuery += " '" + F34_BOOK_MOVEMENT + "' AS TYPE,"
		cQuery += " T2.F32_SUPPL AS SUPPLIER,"
		cQuery += " T2.F32_SUPUN AS SUPP_BRANCH,"
		cQuery += " T2.F32_DOC AS DOC_NUM,"
		cQuery += " T2.F32_PDATE AS PRINT_DATE,"
		cQuery += " T2.F32_VATRT AS VAT_RATE,"
		cQuery += " T0.F3C_RECBAS AS VAT_BASE,"
		cQuery += " T0.F3C_VALUE AS VAT_VALUE,"
		cQuery += " T0.F3C_CODE AS BOOK_CODE,"
		cQuery += " T0.F3C_TG_COD AS TARGET_CODE "
		cQuery += " FROM " + RetSQLName("F3C") + " AS T0"
		cQuery += " JOIN " + RetSQLName("F3B") + " AS T1"
		cQuery += " ON ("
		cQuery += " T1.F3B_FILIAL = '" + xFilial("F3B") + "'"
		cQuery += " AND T1.F3B_BOOKEY = '" + oModel:GetModel("F3BMASTER"):GetValue("F3B_BOOKEY")+ "'"
		cQuery += " AND T1.D_E_L_E_T_ = ' '"
		cQuery += ")"
		cQuery += " JOIN " + RetSQLName("F32") + " AS T2"
		cQuery += " ON ("
		cQuery += " T2.F32_FILIAL = '" + xFilial("F32") + "'"
		cQuery += " AND T2.F32_KEY = T0.F3C_KEY"
		cQuery += " AND T2.F32_VATCOD = T0.F3C_VATCOD"
		cQuery += " AND T2.F32_VATCD2 = T0.F3C_VATCD2"
		cQuery += " AND T2.D_E_L_E_T_ = ' '"
		cQuery += ")"		
		cQuery += " WHERE T0.F3C_FILIAL = '" + xFilial("F3C") + "'"
		cQuery += " AND T0.F3C_BOOKEY = T1.F3B_BOOKEY"
		cQuery += " AND T0.D_E_L_E_T_ = ' '"

		cQforModel := " AND T0.F34_BOOKEY = '" + oModel:GetModel("F3BMASTER"):GetValue("F3B_BOOKEY") + "'"

	// If the routine is called from Write-Off Document.
	ElseIf cModelId == "RU09T06"
		cQuery := " SELECT"
		// Order matters
		cQuery += " T0.F3E_FILIAL	AS FILIAL,"
		cQuery += " T0.F3E_WRIKEY	AS BOOK_KEY,"
		cQuery += " T0.F3E_KEY		AS VAT_KEY,"
		cQuery += " T0.F3E_VATCOD	AS INTCODE,"
		cQuery += " T0.F3E_VATCD2	AS EXTCODE,"
		cQuery += " T1.F3D_FINAL AS DATE,"
		cQuery += " '" + F34_WRITE_OFF_MOVEMENT + "' AS TYPE,"
		cQuery += " T2.F32_SUPPL AS SUPPLIER,"
		cQuery += " T2.F32_SUPUN AS SUPP_BRANCH,"
		cQuery += " T2.F32_DOC AS DOC_NUM,"
		cQuery += " T2.F32_PDATE AS PRINT_DATE,"
		cQuery += " T2.F32_VATRT AS VAT_RATE,"
		cQuery += " T0.F3E_WOFBAS AS VAT_BASE,"
		cQuery += " T0.F3E_VALUE AS VAT_VALUE,"
		cQuery += " T0.F3E_CODE AS BOOK_CODE"
		cQuery += " FROM " + RetSQLName("F3E") + " AS T0"
		cQuery += " JOIN " + RetSQLName("F3D") + " AS T1"
		cQuery += " ON ("
		cQuery += " T1.F3D_FILIAL = '" + xFilial("F3D") + "'"
		cQuery += " AND T1.F3D_WRIKEY = '" + oModel:GetModel("F3DMASTER"):GetValue("F3D_WRIKEY")+ "'"
		cQuery += " AND T1.D_E_L_E_T_ = ' '"
		cQuery += ")"
		cQuery += " JOIN " + RetSQLName("F32") + " AS T2"
		cQuery += " ON ("
		cQuery += " T2.F32_FILIAL = '" + xFilial("F32") + "'"
		cQuery += " AND T2.F32_KEY = T0.F3E_KEY"
		cQuery += " AND T2.F32_VATCOD = T0.F3E_VATCOD"
		cQuery += " AND T2.F32_VATCD2 = T0.F3E_VATCD2"
		cQuery += " AND T2.D_E_L_E_T_ = ' '"
		cQuery += ")"		
		cQuery += " WHERE T0.F3E_FILIAL = '" + xFilial("F3E") + "'"
		cQuery += " AND T0.F3E_WRIKEY = T1.F3D_WRIKEY"
		cQuery += " AND T0.D_E_L_E_T_ = ' '"

		cQforModel := " AND T0.F34_BOOKEY = '" + oModel:GetModel("F3DMASTER"):GetValue("F3D_WRIKEY") + "'"

	// If the routine is called from VAT Restoration
	ElseIf (cModelId == "RU09T08")
		cQuery := " SELECT"
		// Order matters.
		cQuery += " T0.F53_FILIAL	AS FILIAL,"
		cQuery += " T0.F53_RESKEY	AS BOOK_KEY,"
		cQuery += " T0.F53_KEY		AS VAT_KEY,"
		cQuery += " T0.F53_NVTCOD	AS INTCODE,"
		cQuery += " T2.F31_OPCODE	AS EXTCODE,"
		cQuery += " '" + F34_RESTORATION_MOVEMENT + "' AS TYPE,"
		cQuery += " T1.F52_DATE AS DATE,"
		cQuery += " T1.F52_CODE AS BOOK_CODE,"
		cQuery += " T0.F53_SUPPL AS SUPPLIER,"
		cQuery += " T0.F53_SUPUN AS SUPP_BRANCH,"
		cQuery += " T0.F53_DOC AS DOC_NUM,"
		cQuery += " T0.F53_PDATE AS PRINT_DATE,"
		cQuery += " T0.F53_VATRT AS VAT_RATE,"
		cQuery += " SUM(T0.F53_RESTBS) AS VAT_BASE,"
		cQuery += " SUM(T0.F53_RESTVL) AS VAT_VALUE,"
		cQuery += " T0.F53_NTGCOD AS TARGET_CODE "
		cQuery += " FROM " + RetSQLName("F53") + " AS T0"
		cQuery += " INNER JOIN " + RetSQLName("F52") + " AS T1"
		cQuery += " ON ("
		cQuery += " T1.F52_FILIAL = '" + xFilial("F52") + "'"
		cQuery += " AND T1.F52_RESKEY = '" + oModel:GetModel("F52MASTER"):GetValue("F52_RESKEY") + "'"
		cQuery += " AND T1.F52_RESKEY = T0.F53_RESKEY"
		cQuery += " AND T1.D_E_L_E_T_ = ' '"
		cQuery += ")"
		cQuery += " INNER JOIN " + RetSQLName("F31") + " AS T2"
		cQuery += " ON ("
		cQuery += " T2.F31_FILIAL = '" + xFilial("F31") + "'"
		cQuery += " AND T2.F31_CODE = T0.F53_NVTCOD"
		cQuery += " AND T2.D_E_L_E_T_ = ' '"
		cQuery += ")"
		cQuery += " WHERE T0.F53_FILIAL = '" + xFilial("F53") + "'"
		cQuery += " AND T0.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY T0.F53_FILIAL"
		cQuery += " ,T0.F53_KEY"
		cQuery += " ,T0.F53_SUPPL"
		cQuery += " ,T0.F53_SUPUN"
		cQuery += " ,T0.F53_DOC"
		cQuery += " ,T0.F53_PDATE"
		cQuery += " ,T0.F53_NVTCOD"
		cQuery += " ,T2.F31_OPCODE"
		cQuery += " ,T0.F53_VATRT"
		cQuery += " ,T0.F53_RESKEY"
		cQuery += " ,T1.F52_CODE"
		cQuery += " ,T1.F52_DATE"
		cQuery += " ,T2.F31_OPCODE"
		cQuery += " ,T0.F53_NTGCOD"

		cQforModel := " AND T0.F34_BOOKEY = '" + oModel:GetModel("F52MASTER"):GetValue("F52_RESKEY") + "'"

	// If the routine is called from somewhere else.
	Else
		lRet := .F.
		Help("",1,"getTempTable01",,STR0926,1,0)
	EndIf
EndIf

If lRet
	cQueryDel := " SELECT"
	cQueryDel += " T0.F34_FILIAL	AS FILIAL,"
	cQueryDel += " T0.F34_BOOKEY	AS BOOK_KEY,"
	cQueryDel += " T0.F34_KEY		AS VAT_KEY,"
	cQueryDel += " T0.F34_VATCOD	AS INTCODE,"
	cQueryDel += " T0.F34_VATCD2	AS EXTCODE,"
	cQueryDel += " T0.F34_DOC AS DOC_NUM,"
	cQueryDel += " T0.F34_DATE AS DATE,"
	cQueryDel += " T0.F34_SUPPL AS SUPPLIER,"
	cQueryDel += " T0.F34_SUPUN AS SUPP_BRANCH,"
	cQueryDel += " T0.F34_PDATE AS PRINT_DATE,"
	cQueryDel += " T0.F34_VATBS AS VAT_BASE,"
	cQueryDel += " T0.F34_VALUE AS VAT_VALUE,"
	cQueryDel += " T0.F34_VATRT AS VAT_RATE"
	cQueryDel += " FROM " + RetSQLName("F34") + " AS T0"
	cQueryDel += " LEFT JOIN ("
	cQueryDel += cQuery	// Includes the previous query as an area to join on.
	cQueryDel += ") AS NEW_MOVEMENT"
	cQueryDel += " ON ("
	cQueryDel += " NEW_MOVEMENT.FILIAL = '" + xFilial("F34") + "'"
	cQueryDel += " AND NEW_MOVEMENT.VAT_KEY = T0.F34_KEY"
	cQueryDel += " AND NEW_MOVEMENT.BOOK_KEY = T0.F34_BOOKEY"
	cQueryDel += " AND NEW_MOVEMENT.INTCODE = T0.F34_VATCOD"
	cQueryDel += " AND NEW_MOVEMENT.EXTCODE = T0.F34_VATCD2"
	cQueryDel += " AND NEW_MOVEMENT.TYPE = T0.F34_TYPE"
	cQueryDel += ")"
	cQueryDel += " WHERE T0.F34_FILIAL = '" + xFilial("F34") + "'"
	cQueryDel += cQforModel // Specific coniditions for every model
	cQueryDel += " AND NEW_MOVEMENT.FILIAL IS NULL"
	cQueryDel += " AND NEW_MOVEMENT.VAT_KEY IS NULL"
	cQueryDel += " AND NEW_MOVEMENT.BOOK_KEY IS NULL"
	cQueryDel += " AND NEW_MOVEMENT.INTCODE IS NULL"
	cQueryDel += " AND NEW_MOVEMENT.EXTCODE IS NULL"
	cQueryDel += " AND NEW_MOVEMENT.TYPE IS NULL"
	cQueryDel += " AND T0.D_E_L_E_T_ = ' '"

	// Perform query after nested conditionals.
	cTab := MPSysOpenQuery(ChangeQuery(cQuery + cQueryOrder))
	cTabDel := MPSysOpenQuery(ChangeQuery(cQueryDel + cQueryOrder))
EndIf

Return(lRet)
// The end of the Static Function getTempTable(oModel, cTab)