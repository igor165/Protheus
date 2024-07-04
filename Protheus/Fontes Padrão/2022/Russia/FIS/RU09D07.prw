#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'RU09XXX.ch'
#include 'RU09D07.ch'

#define F54_INVOICE_MOVEMENT	"01"
#define F54_SALES_BOOK			"02"
#define F54_VAT_RESTORATION		"03"
#define F54_VAT_VALUE_DECREASE	"-"

#define CALLER_SALES_INVOICE	1
#define CALLER_CANCEL			2


//-----------------------------------------------------------------------
/*{Protheus.doc} RU09D07
This routine is for Outflow VAT Movements.
@author artem.kostin
@since 26/07/2018
@version P12.1.21
@type function
*/
//-----------------------------------------------------------------------
Function RU09D07()
Local oBrowse as Object

// Initalization of the table if it doesn't exist.
DBSelectArea("F54")
F54->(DBSetOrder(1))

oBrowse := FwLoadBrw("RU09D07")
oBrowse:Activate()

Return(.T.)



//-----------------------------------------------------------------------
/*{Protheus.doc} BrowseDef
Defines the browser for the Outflow VAT Movements
@author artem.kostin
@since 26/07/2018
@version P12.1.21
@type function
*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as Object
Local aRotina as Array

aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("F54")
oBrowse:AddLegend("F54_DIRECT =='+'", "RED", "In")
oBrowse:AddLegend("F54_DIRECT =='-'", "GREEN", "Out")
oBrowse:SetDescription(STR0001)
oBrowse:DisableDetails()

Return(oBrowse)



/*{Protheus.doc} MenuDef
Defines the menu for the Outflow VAT Movements
@author Artem Kostin
@since 26/07/2018
@version P12.1.21
@type function
*/
Static Function MenuDef()
Local aButtons as Array
aButtons := {{STR0902, "", 0, 2, 0, Nil}}	// Browser Menu cannot empty
Return(aButtons)



/*{Protheus.doc} ModelDef
Creates the model for the Outflow VAT Movements
@author Artem Kostin
@since 26/07/2018
@version P12.1.21
@type function
*/
Static Function ModelDef()
Local oModel as Object

Local oCab as Object
Local oStructF54 as Object

oCab := FWFormModelStruct():New()
oStructF54 := FWFormStruct(1, "F54")

oModel := MPFormModel():New("RU09D07")
// FWFORMMODELSTRUCT (): AddTable (<cAlias>, [aPK], <cDescription>, <bRealName>) -> NIL
oCab:AddTable('F54', ,'F54',)
//FWFORMMODELSTRUCT (): AddField (<cTitle>, <cTooltip>, <cIdField>, <cType>, <nSize>, [nDecimal], [bValid], [bWhen], [aValues], [lBrigat], [bInit] <lKey>, [lNoUpd], [lVirtual], [cValid]) -> NIL
oCab:AddField("Id","","F54_CAMPO","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||'"1"'},/*Key*/,.F.,.T.,)

oModel:AddFields("F54MASTER", /*cOwner*/, oCab, , ,{|o|{}})
oModel:GetModel("F54MASTER"):SetDescription(STR0001)
oModel:SetPrimaryKey({})

oModel:AddGrid("F54DETAIL", "F54MASTER", oStructF54)
oModel:SetOptional("F54DETAIL", .T.)
Return(oModel)



/*{Protheus.doc} ViewDef
Creates the view for the Outflow VAT Movements
@author Artem Kostin
@since 26/07/2018
@version P12.1.21
@type function
*/
Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStructF54 as Object

oModel := FwLoadModel("RU09D07")
oStructF54 := FWFormStruct(2, "F54")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddGrid("F54_D", oStructF54, "F54DETAIL")

oView:CreateHorizontalBox("MAINBOX", 100)

oView:SetOwnerView("F54_D", "MAINBOX")
oView:SetNoInsertLine("F54_D")
oView:SetNoUpdateLine("F54_D")
oView:SetNoDeleteLine("F54_D")
Return(oView)



/*{Protheus.doc} RU09D07Add
Creates a procedure to register the new movements of VAT Outflow Invoices values.
Function should be used in the moment, when Object Model is commited, but still exists.
@author Artem Kostin
@since 01/16/2017
@version P12.1.20
@type function
*/
Function RU09D07Add(oModel as Object)
Local lRet := .T.
Local cTab := ""
Local cModelId as Character
Local nLine as Numeric

// Checks, If the routine get an argument of Object type and If the routine has an Object to extract data.
If (ValType(oModel) != "O")
	lRet := .F.
	Help("",1,"RU09D07Add01",,STR0910,1,0)
EndIf

If lRet
	cModelId := oModel:GetId()
	// If the routine is called from Outflow VAT Invoices.
	dbSelectArea("F54")
	If cModelId == "RU09T02" .OR. cModelId == "RU09T08" .OR. cModelId == "RU09T09"
		F54->(dbSetOrder(2))
	Else // Caller is unknown.
		lRet := .F.
		Help("",1,"RU09D07Add02",,STR0926,1,0)
	EndIf
EndIf

// Performs an SQL query and fills the cTab alias.
lRet := lRet .and. getTempTable(oModel, @cTab)

If lRet
	dbSelectArea("F54")
	// During inclusion an order is not important.

	Begin Transaction
	// Setting values into the Movements table model line by line.
	nLine := 1
	(cTab)->(DbGoTop())
	While !(cTab)->(Eof())
		RecLock("F54", .T.)

		F54->F54_FILIAL := xFilial('F54')

		// number and date of adjustment
		If (cTab)->(FieldPos("ADJ_NUMBER")) > 0 
			F54->F54_ADJNR := (cTab)->ADJ_NUMBER
		EndIf
		If (cTab)->(FieldPos("ADJ_DATE")) > 0 
			F54->F54_ADJDT := StoD((cTab)->ADJ_DATE)
		EndIf

		F54->F54_DATE := StoD((cTab)->MOVE_DATE)	// The Movement Date must be equal real inclusion date of th VAT Outflow Invoice
		F54->F54_KEY := (cTab)->VAT_KEY	            // VAT Invoice Key
		F54->F54_CLIENT := (cTab)->CLIENT	        // Client's Code
		F54->F54_CLIBRA := (cTab)->CLIENT_BRANCH	// Client's Unit Code
		F54->F54_DOC := (cTab)->DOC_NUM	            // Doc. Number of the VAT Invoice
		F54->F54_PDATE := StoD((cTab)->PRINT_DATE)	// Print Date of the VAT Invoice
		F54->F54_VATCOD := (cTab)->INTCODE	        // Internal VAT Code
		F54->F54_VATRT := (cTab)->VAT_RATE	        // VAT Rate of Movement
		F54->F54_VATBS := (cTab)->VAT_BASE	        // VAT Base of Movement
		F54->F54_VALUE := (cTab)->VAT_VALUE	        // Movement Value
		F54->F54_USER := __cUserID    	            // Movement User Code
		
		If (cTab)->(FieldPos("KEYORI")) > 0 
			F54->F54_KEYORI := (cTab)->KEYORI 
		EndIf
		F54->F54_DIRECT := (cTab)->DIRECTION        // Indicates vat value increase / decrease
        F54->F54_TYPE := (cTab)->TYPE   // Type of the Movement

        F54->F54_REGKEY := (cTab)->REG_KEY // Internal Purchase Book Key
        F54->F54_REGDOC := (cTab)->REG_DOC // Sales Book Code
		MsUnlock("F54")
		(cTab)->(DbSkip())
	EndDo
	End Transaction
EndIf

CloseTempTable(cTab)
Return(lRet)
// The end of Function RU09D07Add


/*{Protheus.doc} RU09D07Edt
Creates a procedure to register movements updates of VAT Outflow Invoices values.
Function should be used in the moment, when Object Model is commited, but still exists.
@author Artem Kostin
@since 01/16/2017
@version P12.1.20
@type function
*/
Function RU09D07Edt(oModel as Object)
	Local cModelId as Character
	Local cSeek    as Character
	Local cTab     as Character
	Local cTabDel  as Character
	Local lRet     as Logical
	Local nLine    as Numeric

	lRet := .T.
	cTab := ""
	cTabDel := ""

	// Checks, If the routine get an argument of Object type and If the routine has an Object to extract data.
	If (ValType(oModel) != "O")
		lRet := .F.
		Help("",1,"RU09D07Edt01",,STR0910,1,0)
	EndIf

	If lRet
		dbSelectArea("F54")
		cModelId := oModel:GetId()
		If cModelId $ "RU09T02/RU09T08/RU09T09"
			F54->(dbSetOrder(2))
		Else // Caller is unknown.
			Help("",1,"RU09D07Edt02",,STR0926,1,0)
			lRet := .F.
		EndIf
	EndIf

	// Performs an SQL query and fills the cTab alias.
	lRet := lRet .and. getTempTable(oModel, @cTab, @cTabDel)

	If lRet
		// Setting values into the Movements table model line by line.
		// Purchase VAT is updated. Let's check out what is updated.
		nLine := 1
		F54->(dbGoTop())
		(cTab)->(DbGoTop())
		Begin Transaction
		While !(cTab)->(Eof())
			// cSeek := (cTab)->(REG_KEY + VAT_KEY + INTCODE)
			cSeek := PadR((cTab)->REG_KEY, TamSX3("F54_REGKEY")[1], " ");
					+ PadR((cTab)->VAT_KEY, TamSX3("F54_KEY")[1], " ");
					+ PadR((cTab)->INTCODE, TamSX3("F54_VATCOD")[1], " ")
			// If record is found in the Balances Table, update it.
			If !Empty(cSeek)
				If F54->(DbSeek(xFilial("F54") + cSeek))
					RecLock("F54", .F.)

				Else // If record is not found, add it.
					RecLock("F54", .T.)
					F54->F54_FILIAL := xFilial("F54")

					// number and date of adjustment
					If (cTab)->(FieldPos("ADJ_NUMBER")) > 0 
						F54->F54_ADJNR := (cTab)->ADJ_NUMBER
					EndIf
					If (cTab)->(FieldPos("ADJ_DATE")) > 0
						F54->F54_ADJDT := StoD((cTab)->ADJ_DATE)
					EndIf

					F54->F54_KEY := (cTab)->VAT_KEY	// VAT Invoice Key
					F54->F54_VATCOD := (cTab)->INTCODE	// Internal VAT Code

					F54->F54_DIRECT := (cTab)->DIRECTION
					F54->F54_TYPE := (cTab)->TYPE   // Type of the Movement
					F54->F54_REGKEY := (cTab)->REG_KEY // Internal Purchase Book Key
					F54->F54_REGDOC := (cTab)->REG_DOC // Sales Book Code
				EndIf
				
				F54->F54_DATE := dDataBase	// The Movement Date must be equal to the real inclusion date of th VAT Outflow Invoice
				F54->F54_CLIENT := (cTab)->CLIENT	// Client's Code
				F54->F54_CLIBRA := (cTab)->CLIENT_BRANCH	// Client's Unit Code
				F54->F54_DOC := (cTab)->DOC_NUM	// Doc. Number of the VAT Invoice
				F54->F54_PDATE := StoD((cTab)->PRINT_DATE)	// Print Date of the VAT Invoice
				F54->F54_VATRT := (cTab)->VAT_RATE	// VAT Rate of Movement
				F54->F54_VATBS := (cTab)->VAT_BASE	// VAT Base of Movement
				F54->F54_VALUE := (cTab)->VAT_VALUE	// Movement Value
				F54->F54_USER := __cUserID	// Movement User Code
				MsUnlock("F54")
			EndIf
			(cTab)->(DbSkip())
		EndDo

		F54->(DbGoTop())
		(cTabDel)->(DbGoTop())
		While !(cTabDel)->(Eof())
			cSeek := PadR((cTabDel)->REG_KEY, TamSX3("F54_REGKEY")[1], " ");
					+ PadR((cTabDel)->VAT_KEY, TamSX3("F54_KEY")[1], " ");
					+ PadR((cTabDel)->INTCODE, TamSX3("F54_VATCOD")[1], " ")
			// If record is found in the  Balances Table, delete it.
			If !Empty(cSeek) .and. F54->(DbSeek(xFilial("F54") + cSeek))
				RecLock("F54", .F.)
					F54->(DbDelete())
				MsUnlock("F54")
			EndIf

			(cTabDel)->(DbSkip())
		EndDo
		End Transaction
	EndIf

	CloseTempTable(cTab)
	CloseTempTable(cTabDel)
Return(lRet)
// The end of Function RU09D07Edt



/*{Protheus.doc} RU09D07Del
Creates a procedure to delete movements of VAT Outflow Invoices values.
Function should be used in the moment, when Object Model is commited, but still exists.
@author Artem Kostin
@since 01/22/2017
@version P12.1.20
@type function
*/
Function RU09D07Del(oModel as Object)
	Local cModelId     as Character
	Local cRegKey      as Character
	Local cSeek        as Character
	Local lRet         as Logical

	lRet := .T.
	// Checks, If the routine get an argument of Object type and If the routine has an Object to extract data.
	If (ValType(oModel) != "O")
		lRet := .F.
		Help("",1,"RU09D07Del01",,STR0910,1,0)
	EndIf

	If lRet
		cModelId := oModel:GetId()
		dbSelectArea("F54")
		cRegKey := DefaultValue("F54_REGKEY")

		If cModelId == "RU09T02"
			cSeek := cRegKey + oModel:GetModel("F35MASTER"):GetValue("F35_KEY")
			RU09D0703_DeleteOutflowMovements(2, cSeek)

		ElseIf cModelId == "RU09T08"
			cSeek := oModel:GetModel("F52MASTER"):GetValue("F52_RESKEY")
			RU09D0703_DeleteOutflowMovements(2, cSeek)

		ElseIf cModelId == "RU09T09"
			cSeek := cRegKey + oModel:GetModel("F35MASTER"):GetValue("F35_KEY")
			RU09D0703_DeleteOutflowMovements(2, cSeek)

		Else
			// Caller is unknown
			lRet := .F.
			Help("",1,"RU09D07Del02",,STR0926,1,0)
		EndIf
	EndIf
Return(lRet)

/*{Protheus.doc} getTempTable
Function gets alias of the temporary table and fills this table with the data from the query.
@author Artem Kostin
@since 03/12/2017
@version P12.1.20
@type function
*/
Static Function GetTempTable(oModel as Object, cTab as Character, cTabDel as Character)
	Local cModelId  as Character
	Local cOrder    as Character
	Local cQuery    as Character
	Local cQueryDel as Character
	Local lRet      as Logical
	Local oModelM   as Object
	Local cEmpty    as Character 
	Default cTab := ""
	Default cTabDel := ""

	lRet := .T.
	cModelId := oModel:GetId()
	cQuery := ""
	cEmpty := "' '"
	
	// If the routine is called from Outflow VAT Invoices.
	If cModelId == "RU09T02"
		cQuery  := RU09D0701_GetDataFromSalesVatInvoice(oModel, CALLER_SALES_INVOICE)

	ElseIf cModelId == "RU09T08"
		oModelM := oModel:GetModel("F52MASTER")
		cQuery := " SELECT"
		// Order matters.
		cQuery += " T0.F53_FILIAL AS FILIAL "
		cQuery += " ,T0.F53_RESKEY AS REG_KEY "
		cQuery += " ,T0.F53_KEY AS VAT_KEY "
		cQuery += " ,T0.F53_NTGCOD AS INTCODE "
		cQuery += " ," + ToQuotes(F54_VAT_RESTORATION) + "  AS TYPE "
		cQuery += " ,T1.F52_DATE AS MOVE_DATE "
		cQuery += " ,T1.F52_CODE AS REG_DOC "
		cQuery += " ,'-' AS DIRECTION "
		cQuery += " ,T0.F53_SUPPL AS CLIENT "
		cQuery += " ,T0.F53_SUPUN AS CLIENT_BRANCH "
		cQuery += " ,T0.F53_DOC AS DOC_NUM "
		cQuery += " ,T0.F53_PDATE AS PRINT_DATE "
		cQuery += " ,T0.F53_VATRT AS VAT_RATE "
		cQuery += " ,SUM(T0.F53_RESTBS) AS VAT_BASE "
		cQuery += " ,SUM(T0.F53_RESTVL) AS VAT_VALUE "

		// cQuery += ", T2.F35_ADJNR AS ADJ_NUMBER"
		// cQuery += ", T2.F35_ADJDT AS ADJ_DATE"
		// cQuery += ", T2.F35_KEYORI AS KEYORI"
		cQuery += " FROM " + RetSQLName("F53") + " AS T0"
		cQuery += " INNER JOIN " + RetSQLName("F52") + " AS T1"
		cQuery += " ON ("
		cQuery += " T1.F52_FILIAL = " + ToQuotes(xFilial("F52"))
		cQuery += " AND T1.F52_RESKEY = " + ToQuotes(oModelM:GetValue("F52_RESKEY"))
		cQuery += " AND T1.F52_RESKEY = T0.F53_RESKEY"
		cQuery += " AND T1.D_E_L_E_T_ = " + cEmpty
		cQuery += ")"

		cQuery += " INNER JOIN " + RetSQLName("F37") + " AS T2 ON ("
		cQuery += " F53_KEY = F37_KEY"
		cQuery += " AND T2.F37_FILIAL = " + ToQuotes(xFilial("F37"))
 		cQuery += " AND T2.D_E_L_E_T_ = " + cEmpty
		cQuery += ")"

		cQuery += " WHERE T0.F53_FILIAL = " + ToQuotes(xFilial("F53"))
		cQuery += " AND T0.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY T0.F53_FILIAL"
		cQuery += " ,T0.F53_KEY"
		cQuery += " ,T0.F53_SUPPL"
		cQuery += " ,T0.F53_SUPUN"
		cQuery += " ,T0.F53_DOC"
		cQuery += " ,T0.F53_PDATE"
		cQuery += " ,T0.F53_NTGCOD"
		cQuery += " ,T0.F53_RESKEY"
		cQuery += " ,T0.F53_VATRT"
		cQuery += " ,T1.F52_CODE"
		cQuery += " ,T1.F52_DATE"

		// cQuery += " ,T2.F35_ADJNR"
		// cQuery += " ,T2.F35_ADJDT"
		// cQuery += " ,T2.F35_KEYORI"
	// Adjustment of Sales documents
	ElseIf cModelId == "RU09T09"
		
		cQuery  := RU09D0702_GetDataFromAdjustmentVatInvoice(oModel)
	// If the routine is called from somewhere else.
	Else
		lRet := .F.
		Help("",1,"getTempTable01",,STR0926,1,0)
	EndIf

	If lRet
		cOrder	  := " ORDER BY 1, 2, 3, 4"
		cTab      := MPSysOpenQuery(ChangeQuery(cQuery + cOrder))
		cQueryDel := GetDelQuery(cQuery, oModel)
		cTabDel   := MPSysOpenQuery(ChangeQuery(cQueryDel + cOrder))
	EndIf

Return(lRet)

/*{Protheus.doc} DefaultValue
Makes default empty value with the length of given character field 
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function DefaultValue(cKey as Character)
Return Space(TamSX3(cKey)[1])

/*{Protheus.doc} ToQuotes
Encloses string to single quotes to make more readable SQL queries
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function ToQuotes(cString as Character)
Return  "'" + cString  + "'"

/*{Protheus.doc} GetCondForModel 
Makes specific coniditions for query for different models
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function GetCondForModel(oModel as Object)
	Local cModelId   as Character
	Local cQforModel as Character
	Local oModelM    as Object

	cQforModel := ""
	cModelId := oModel:GetId()
	 
	If cModelId == "RU09T02"
		oModelM := oModel:GetModel("F35MASTER")
		cQforModel := "	AND T0.F54_KEY = "       + ToQuotes(oModelM:GetValue("F35_KEY"))

	ElseIf  cModelId == "RU09T08"
		oModelM := oModel:GetModel("F52MASTER")
		cQforModel := "	AND T0.F54_REGKEY = "    + ToQuotes(oModelM:GetValue("F52_RESKEY"))

	ElseIf cModelId == "RU09T09"
		oModelM := oModel:GetModel("F35MASTER")
			cQforModel := "	AND T0.F54_KEY = "   + ToQuotes(oModelM:GetValue("F35_KEY"))
	EndIf

Return cQforModel

/*{Protheus.doc} GetDelQuery 
Makes deletion query, using selection query and model 
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Static Function GetDelQuery(cQuery as Character, oModel as Object)
	Local cQueryDel as Character

	cQueryDel := " SELECT"

	//Order matters.
	cQueryDel += " T0.F54_FILIAL	AS FILIAL,"
	cQueryDel += " T0.F54_REGKEY	AS REG_KEY,"
	cQueryDel += " T0.F54_KEY		AS VAT_KEY,"
	cQueryDel += " T0.F54_VATCOD	AS INTCODE,"
	cQueryDel += " T0.F54_CLIENT AS CLIENT,"
	cQueryDel += " T0.F54_CLIBRA AS CLIENT_BRANCH,"
	cQueryDel += " T0.F54_PDATE AS PRINT_DATE,"
	cQueryDel += " T0.F54_VATBS AS VAT_BASE,"
	cQueryDel += " T0.F54_VALUE AS VAT_VALUE,"
	cQueryDel += " T0.F54_VATRT AS VAT_RATE"
	cQueryDel += " FROM " + RetSQLName("F54") + " AS T0"
	cQueryDel += " LEFT JOIN ("
	cQueryDel += cQuery	// Includes the previous query as an area to join on.
	cQueryDel += ") AS NEW_MOVEMENT"
	cQueryDel += " ON ("
	cQueryDel += " NEW_MOVEMENT.FILIAL = " + ToQuotes(xFilial("F54"))
	cQueryDel += " AND NEW_MOVEMENT.VAT_KEY = T0.F54_KEY"
	cQueryDel += " AND NEW_MOVEMENT.REG_KEY = T0.F54_REGKEY"
	cQueryDel += " AND NEW_MOVEMENT.INTCODE = T0.F54_VATCOD"
	//cQueryDel += " AND NEW_MOVEMENT.TYPE = T0.F54_TYPE"
	cQueryDel += ")"
	cQueryDel += " WHERE T0.F54_FILIAL = " + ToQuotes(xFilial("F54"))
	cQueryDel +=  GetCondForModel(oModel)
	cQueryDel += " AND NEW_MOVEMENT.FILIAL IS NULL"
	cQueryDel += " AND NEW_MOVEMENT.VAT_KEY IS NULL"
	cQueryDel += " AND NEW_MOVEMENT.REG_KEY IS NULL"
	cQueryDel += " AND NEW_MOVEMENT.INTCODE IS NULL"
	//cQueryDel += " AND NEW_MOVEMENT.TYPE IS NULL"
	cQueryDel += " AND T0.D_E_L_E_T_ = ' '"
Return cQueryDel

/*{Protheus.doc} RU09D0702_GetDataFromAdjustmentVatInvoice
Makes select query for Adjustment VAT Invoice model: +/- records
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09D0702_GetDataFromAdjustmentVatInvoice(oModel as Object)
	Local cQueryMin as Character
	Local cQueryPlus as Character

	cQueryMin  := RU09D0701_GetDataFromSalesVatInvoice(oModel, CALLER_CANCEL)
	cQueryPlus := RU09D0701_GetDataFromSalesVatInvoice(oModel, CALLER_SALES_INVOICE)
Return (cQueryMin + " UNION ALL " + cQueryPlus)

/*{Protheus.doc} RU09D0703_DeleteOutflowMovements
Delete outflow movements from F54
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09D0703_DeleteOutflowMovements(nOrder as Numeric, cSeek as Character)
	F54->(dbSetOrder(nOrder))
	F54->(DbGoTop())
	
	Begin Transaction
		While !Empty(cSeek) .AND. F54->(dbSeek(xFilial("F54") + cSeek))
			RecLock("F54", .F.)
				F54->(DbDelete())
			MsUnlock("F54")
		EndDo
	End Transaction
Return

/*{Protheus.doc} RU09D0701_GetDataFromSalesVatInvoice
Makes select query for Sales VAT Invoice model: +/- records
@author alexander.ivanov
@since 26/02/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09D0701_GetDataFromSalesVatInvoice(oModel as Object, nCaller as Numeric)
	Local cAdjDate   as Character
	Local cAdjNumber as Character
	Local cEmpty     as Character
	Local cKey       as Character
	Local cKeyOri    as Character
	Local cQuery     as Character
	Local oMaster    as Object

	oMaster  := oModel:GetModel("F35MASTER")
	cKey     := oMaster:GetValue("F35_KEY")
	cKeyOri  := oMaster:GetValue("F35_KEYORI")
	cAdjNumber := oMaster:GetValue("F35_ADJNR")
	cAdjDate := oMaster:GetValue("F35_ADJDT")
	cEmpty := "' '"
	cQuery := " SELECT"

	// Order matters.
	cQuery += " T0.F35_FILIAL AS FILIAL,"
	cQuery += ToQuotes(DefaultValue("F54_REGKEY")) + " AS REG_KEY,"
	cQuery += " T1.F36_VATCOD AS INTCODE,"

	If (nCaller == CALLER_SALES_INVOICE)
		cQuery += ToQuotes(DefaultValue("F35_KEYORI")) + " AS KEYORI,"
		cQuery += " T0.F35_KEY AS VAT_KEY,"
		cQuery += " T0.F35_ADJNR AS ADJ_NUMBER,"
		cQuery += " T0.F35_ADJDT AS ADJ_DATE,"

	ElseIf (nCaller == CALLER_CANCEL)
		cQuery += " T0.F35_KEY AS KEYORI,"
		cQuery += ToQuotes(cKey) + " AS VAT_KEY,"
		cQuery += ToQuotes(cAdjNumber) + " AS ADJ_NUMBER,"
		cQuery += ToQuotes(cAdjDate) + " AS ADJ_DATE,"

	Else
		RU99XFUN05_Help(STR0002)
	EndIf

	cQuery += " " + ToQuotes(F54_INVOICE_MOVEMENT) + " AS TYPE,"
	cQuery += " T0.F35_TDATE AS MOVE_DATE,"
	cQuery += ToQuotes(DefaultValue("F54_REGDOC")) + " AS REG_DOC,"
	cQuery += " T0.F35_CLIENT AS CLIENT,"
	cQuery += " T0.F35_BRANCH AS CLIENT_BRANCH,"
	cQuery += " T0.F35_DOC AS DOC_NUM,"
	cQuery += " T0.F35_PDATE AS PRINT_DATE,"
	cQuery += " T1.F36_VATRT AS VAT_RATE,"

	cQuery += " '+' AS DIRECTION,"

	If (nCaller == CALLER_SALES_INVOICE)
		cQuery += " SUM(T1.F36_VATBS1) AS VAT_BASE,"
		cQuery += " SUM(T1.F36_VATVL1) AS VAT_VALUE"

	ElseIf (nCaller == CALLER_CANCEL)
		cQuery += " -SUM(T1.F36_VATBS1) AS VAT_BASE,"
		cQuery += " -SUM(T1.F36_VATVL1) AS VAT_VALUE"

	Else
		RU99XFUN05_Help(STR0002)
	EndIf

	cQuery += " FROM " + RetSQLName("F35") + " AS T0"
	cQuery += " INNER JOIN " + RetSQLName("F36") + " AS T1"
	cQuery += " ON ("
	cQuery += " T1.F36_FILIAL = " + ToQuotes(xFilial("F36"))
	cQuery += " AND T1.F36_KEY = T0.F35_KEY"
	cQuery += " AND T1.D_E_L_E_T_ = " + cEmpty
	cQuery += ")"
	cQuery += " WHERE T0.F35_FILIAL = " + ToQuotes(xFilial("F35"))

	If (nCaller == CALLER_SALES_INVOICE)
		cQuery += " AND T0.F35_KEY = " + ToQuotes(cKey)

	ElseIf (nCaller == CALLER_CANCEL)
		cQuery += " AND T0.F35_KEY = " + ToQuotes(cKeyOri)

	Else
		RU99XFUN05_Help(STR0002)
	EndIf

	cQuery += " AND T0.D_E_L_E_T_ = " + cEmpty
	cQuery += " GROUP BY T0.F35_FILIAL,"
	cQuery += " T0.F35_KEY,"
	cQuery += " T0.F35_CLIENT,"
	cQuery += " T0.F35_BRANCH,"
	cQuery += " T0.F35_DOC,"
	cQuery += " T0.F35_PDATE,"
	cQuery += " T0.F35_TDATE,"
	cQuery += " T0.F35_KEYORI,"
	cQuery += " T1.F36_VATCOD,"
	cQuery += " T1.F36_VATCD2,"
	cQuery += " T1.F36_VATRT"

	If (nCaller == CALLER_SALES_INVOICE)
		cQuery += ", T0.F35_ADJNR, T0.F35_ADJDT"
	EndIf
Return cQuery
