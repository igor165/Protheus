#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'ru09t03.ch'
#include 'ru09xxx.ch'

#define RU09T03_SF1_FIELDS_HISTORY	"F1_FILIAL |F1_SERIE  |F1_DOC    |F1_DTDIGIT|F1_EMISSAO|F1_BASIMP1|F1_VALIMP1|F1_VALBRUT|F1_STATUSR|F1_LOJA   |F1_FORNECE|F1_CONUNI  |"
#define EXTRA_DAYS_AFTER_TAX_PERIOD 25

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T03RUS
Creates the main screen of Purchases VAT Invoice.
@author artem.kostin
@since 02/05/2017
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T03RUS()
Local oBrowse as Object

DBSelectArea("F37")
F37->(DbSetOrder(1))
DBSelectArea("F38")
F38->(DbSetOrder(1))

SetKey(VK_F12, {|a,b| AcessaPerg("RU09T03",.T.)})

oBrowse := FWLoadBrw("RU09T03")
oBrowse:Activate()
Return(.T.)



//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Defines the browser for the Purchases VAT Invoice.
@author artem.kostin
@since 26/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as Object
Local oTableAtt as Object
Local aRotina as Array

oTableAtt:= TableAttDef()
aRotina := MenuDef()

oBrowse := FwMBrowse():New()

oBrowse:SetAlias("F37")
oBrowse:SetDescription(STR0009)	// "Purchases VAT Invoices"
oBrowse:DisableDetails()

// 'Select All' Button
oBrowse:SetAttach(.T.)
oBrowse:SetViewsDefault(oTableAtt:aViews)
oBrowse:SetChartsDefault(oTableAtt:aCharts)
Return(oBrowse)


//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defines the menu to Purchases VAT Invoice.
@author artem.kostin
@since 02/05/2017
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRet as Array
Local aAddOpt as Array

aAddOpt := {{STR0002, "addF37ComInv(.F.)", 0, 3, 0, Nil}; // "Commercial Invoice"
			,{STR0042, "RU09T03Mnl()", 0, 3, 0, Nil}} // Manual

aRet := {{STR0003, "FwExecView('"+STR0003+"', 'RU09T03')", 0, 2, 0, Nil},;	// "View" 
		{STR0001, aAddOpt, 0, 3, 0, Nil},;	// "Add"
		{STR0004, "RU09T03act("+STR(MODEL_OPERATION_UPDATE)+", .T.)", 0, 4, 0, Nil},;	// "Edit" 
		{STR0005, "RU09T03act("+STR(MODEL_OPERATION_DELETE)+", .T.)", 0, 5, 0, Nil},;	// "Delete"
		{STR0901, "RU09T05", 0, 2, 0, Nil},;
		{STR0935, "RU09T06", 0, 2, 0, Nil},;
		{STR0006, "CTBC662", 0, 2, 0, Nil},;	// "Track Posting"
		{STR0046, "RU09T03Cp()", 0, 9, 0, Nil}}	// "Copy"
Return(aRet)



//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Creates the model of Purchases VAT Invoice.
@author artem.kostin
@since 02/05/2017
@version P12.1.17
@type function
/*/ 		 

//-----------------------------------------------------------------------
Static Function ModelDef()
Local oStructF37 as Object
Local oStructF38 as Object
Local oStructSF1 as Object
Local oModelEvent as Object

Private oModel as Object

oStructF37 := FWFormStruct(1, "F37")
oStructF38 := FWFormStruct(1, "F38")
oStructSF1 := FWFormStruct(1, "SF1",{|x| x $ RU09T03_SF1_FIELDS_HISTORY})

oModel := MPFormModel():New("RU09T03", , , {|oModel| RU09T03MR(oModel)},)
oModel:SetDescription(STR0009)	// "Purchases VAT Invoices"

oModel:AddFields("F37master", Nil, oStructF37, {|oModel, cAction, cField, xValue| RU09T03MPre(oModel, cAction, cField, xValue)}/*bPre*/, {|oModel| RU09T03MPost(oModel)}/*bPost*/)
oModel:GetModel("F37master"):SetDescription(STR0007)	// "VAT Invoices Headers on Purchases"
oModel:AddGrid("F38detail", "F37master", oStructF38)

oModel:AddGrid("SF1detail", "F37master", oStructSF1, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, {|| LoadComInv(oStructSF1, F37->F37_FILIAL, F37->F37_FORNEC, F37->F37_BRANCH, F37->F37_KEY)} /* bLoadGrid */)

oModel:GetModel("F38detail"):SetDescription(STR0008)	// "VAT Invoices Items on Purchases"
oModel:SetRelation("F38detail", {{"F38_FILIAL", "xFilial('F38')"}, {"F38_KEY", "F37_KEY"}}, F38->(IndexKey(1)))

//TODO edit connection sf1 to f37 for sf1 to f38
oModel:SetRelation("SF1detail", {{"F1_FILIAL", "xFilial('SF1')"},{"F1_FORNECE","F37_FORNEC"}, {"F1_LOJA","F37_BRANCH"}}, SF1->(IndexKey(1)))
oModel:SetRelation("SF1detail", {{"F1_SERIE", "F38_INVSER"}, {"F1_DOC", "F38_INVDOC"}}, SF1->(IndexKey(1)))
				
oModel:SetPrimaryKey({"F37_FILIAL", "F37_FORNEC", "F37_BRANCH", "F37_PDATE", "F37_DOC", "F37_TYPE"})
oModel:GetModel("F38detail"):SetUniqueLine({"F38_ITEM"})

oModel:SetOnlyQuery("SF1detail")
oModel:SetOnlyQuery("SF1detail")
oModel:GetModel("SF1detail"):SetOptional(.T.)

oModelEvent 	:= RU09T03EventRUS():New()
oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)
Return(oModel)



//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Creates the view of Purchases VAT Invoice.
@author artem.kostin
@since 02/05/2017
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStructF37 as Object
Local oStrucTotls as Object
Local oStructF38 as Object
Local oStructSF1 as Object
Local cCmpF37 as Character
Local cCmpF37_T as Character
Local cCmpF38 as Character
Local cCmpSF1 as Character
Local lHide as Logical

lHide := .F.

// Defines which fields we don't need to show on the upper part of screen.
cCmpF37 := "F37_VALUE ;F37_EXC_VL;F37_VATBS ;F37_VATVL ;F37_VALGR ;F37_BOOK  ;F37_VATBS1;F37_VATVL1"
// Defines which fields want to show on the upper part of screenfields for bottom part - Totals.
cCmpF37_T := "F37_VALUE ;F37_EXC_VL;F37_VATBS ;F37_VATVL ;F37_VATBS1;F37_VATVL1;F37_VALGR "
// Defines which fields we don't need to show in greed.
cCmpF38 := "F38_FILIAL;F38_KEY;F38_DOCKEY;F38_TYPE;F38_DOC;F38_DTLA"
/*Com invoice sheet*/
cCmpSF1 := "F1_SERIE  ;F1_DOC    ;F1_DTDIGIT;F1_EMISSAO;F1_BASIMP1;F1_VALIMP1;F1_VALBRUT"

oModel := FwLoadModel("RU09T03")
oStructF37 := FWFormStruct(2, "F37", {|x| !(AllTrim(x) $ cCmpF37)})
oStructF38 := FWFormStruct(2, "F38", {|x| !(AllTrim(x) $ cCmpF38)})
oStrucTotls := FWFormStruct(2, "F37", {|x| (AllTrim(x) $ cCmpF37_T)})
oStrucTotls:SetNoFolder()
/*Purchace invoice sheet*/

//	LOT control.  How it works: Check if the parameter MV_RASTRO = S (Yes).
// If yes, check that at least in one product the field B1_RASTRO = L (Lot).
// If no "L" hide the fields F38_ORIGIN and F38_NUMDES. 
If SuperGetMV("MV_RASTRO") == "S"
	lHide := RU09T03LOC()
EndIf
	
If (lHide)
	oStructF38:RemoveField("F38_ORIGIN")
	oStructF38:RemoveField("F38_NUMDES")
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F37M", oStructF37, "F37master")
oView:AddGrid("VIEW_F38D", oStructF38, "F38detail")
oView:AddField("VIEW_F37T", oStrucTotls, "F37master")

oView:CreateHorizontalBox("HEADERBOX", 55)
oView:CreateFolder('FOLDER1', 'HEADERBOX')

oView:AddSheet('FOLDER1', 'Sheet1', STR0019)	//VAT Invoice Sheet

oView:CreateHorizontalBox("F37HEADERBOX",100/*%*/,,,'FOLDER1','Sheet1')

oView:SetOwnerView("VIEW_F37M", "F37HEADERBOX")

oView:CreateHorizontalBox("ITEMBOX",35)
oView:CreateHorizontalBox("TOTALBOX",10)

oView:SetOwnerView("VIEW_F38D", "ITEMBOX")
oView:SetOwnerView("VIEW_F37T", "TOTALBOX")

oView:SetCloseOnOk({|| .T.})

If (FwIsInCallStack('RU09T03Mnl'));
	.or. (!INCLUI .and. (F37->F37_TYPE == "2"))
	oStructF37:RemoveField("F37_IDATE")
	oStructF37:RemoveField("F37_INVSER")
	oStructF37:RemoveField("F37_INVDOC")
	oStructF37:RemoveField("F37_CURR")
	oStructF37:RemoveField("F37_CONUNI")
	oStructF37:RemoveField("F37_MOEDA")
	oStructF37:RemoveField("F37_MOEDES")
	oStructF38:RemoveField("F38_INVSER")
	oStructF38:RemoveField("F38_INVDOC")
	oStructF38:RemoveField("F38_INVIT")
	oStructF38:RemoveField("F38_INVDT")
	oStructF38:RemoveField("F38_ITDATE")

Else
	oStructSF1 := FWFormStruct(2, "SF1", {|x| (x $ cCmpSF1)})
	oView:AddGrid("VIEW_SF1D", oStructSF1, "SF1detail")
	oView:SetViewProperty("VIEW_SF1D", "GRIDDOUBLECLICK", {{|oModel| RU09T03PIn(oModel)}})
	oView:AddSheet('FOLDER1', 'Sheet2', STR0015)	//Purchase Invoice 
	oView:CreateHorizontalBox("SF1HEADERBOX",100/*%*/,,,'FOLDER1','Sheet2')
	oView:SetOwnerView("VIEW_SF1D", "SF1HEADERBOX")
	
	oView:SetNoInsertLine("VIEW_SF1D")
	oView:SetNoUpdateLine("VIEW_SF1D")
	oView:SetNoInsertLine("VIEW_F38D")
	oView:SetNoUpdateLine("VIEW_F38D")
	If INCLUI
		oView:AddUserButton(STR0021, "", {|| RU09T03ACI() }) //Add more Purchase Invoice
	Else
		oView:SetNoDeleteLine("VIEW_SF1D")
		oView:SetNoDeleteLine("VIEW_F38D")
	EndIf
EndIf

oStructF37:RemoveField("F37_F5QUID")

If !INCLUI
	oView:AddUserButton(STR0901, "", {|| RU09T05()})
	oView:AddUserButton(STR0935, "", {|| RU09T06()})
EndIf

oView:AddIncrementField('VIEW_F38D','F38_ITEM')
Return(oView)



/*/{Protheus.doc} RU09T03Mnl
This routine starts the procedure of creating Purchases VAT Invoice manually.
@author artem.kostin
@since 11/29/2018
@version P12.1.22
@type function
/*/
Function RU09T03Mnl()
Local lRet := .T.
Local oModel:= FwLoadModel("RU09T03")

If (lRet)
	// If it is everything OK, must be show a window to the end user to continue to add a Sales VAT Invoice.
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	RU09T03Mn1(oModel)
	FwExecView(STR0001, "RU09T03", MODEL_OPERATION_INSERT,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel) // "Sales Invoice"
EndIf
Return(lRet)



Function RU09T03Mn1(oModel)
Local lRet := .T.
Local oModelF37 := oModel:GetModel("F37master")

If (lRet)
	lRet := lRet .and. oModelF37:LoadValue("F37_TYPE", "2")
	lRet := lRet .and. oModelF37:LoadValue("F37_PDATE", dDataBase)
EndIf

Return(lRet)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T03LOC
Checks if there is at least one line in F38, that contains a product, having 'L' in SB1.b1_rastro
used for LOT control (see ViewDef)
Has two branches: 
(1) for operations Edit, Delete, View takes F38_ITMCOD lines from database in query 
(2) for operation Insert takes F38_ITMCOD lines from model F38details and then makes query on SB1t10
@author natasha khozyainova
@since 31/01/2018
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T03LOC()
Local cQuery as Character 
Local cTab as Character

Local lHide as Logical 

Local oModel as Object // active model if exists - when INSERT operation
Local oModelF38 as Object // model grid F38detail - when INSERT operation

Local cVATKey as Character
Local cICod as Character // string <'product1','product2',..,'productN> made from F38_ITMCOD field - when INSERT operation

Local nX as Numeric 

lHide := .F.
cQuery:= ''
cICod := ''

// When come to this function from INSERT operation - take data from Model
If (ValType(oModel) == "O") .and. (oModel:getId() == "RU09T03")
	oModelF38 := oModel:GetModel("F38detail")
	For nX := 1 to oModelF38:Length()
			oModelF38:GoLine(nX)
			If !Empty(oModelF38:GetValue("F38_ITMCOD"))
				cICod += "'"+ oModelF38:GetValue("F38_ITMCOD") +"',"
			EndIf
	Next nX
	If !Empty(cICod)
		cICod := Left(cICod, Len(cICod)-1)
	EndIf

	cQuery := " SELECT COUNT(*) COUNT1 "
	cQuery += " FROM " + RetSQLName("SB1") + " SB1"
	cQuery += " WHERE SB1.B1_FILIAL = " +"'" + xFilial("SB1") +"' "
	If !Empty(cICod)
		cQuery += " AND SB1.B1_COD in (" + cICod + ")"
	EndIf
	cQuery += " AND SB1.D_E_L_E_T_ =' ' "
	cQuery += " AND SB1.B1_RASTRO = 'L' " 

Else // When come to this function from EDIT/VIEW/DELETE operation - take data from table F38
	cVATKey := F37->F37_KEY
	cQuery := " SELECT COUNT(*) COUNT1 "
	cQuery += " FROM " + RetSQLName("F38") + " F38"
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1"
	cQuery += " ON ("
	cQuery += " SB1.B1_FILIAL = '" + xFilial("SB1")+"' "
	cQuery += " AND F38.F38_ITMCOD = SB1.B1_COD "
	cQuery += " AND SB1.D_E_L_E_T_ =' ' "
	cQuery += " AND SB1.B1_RASTRO = 'L')"
	cQuery += " WHERE F38.F38_FILIAL = " +"'" + xFilial("F38") +"' "
	If !Empty(cVATKey)
		cQuery += " AND F38.F38_KEY = " + "'" + cVATKey +"'"
	EndIf
	cQuery += " AND F38.D_E_L_E_T_ =' ' "
EndIf
cTab := MPSysOpenQuery(ChangeQuery(cQuery))

// If the quantity of lines having 'L' in b1_rastro equals zero.
If ((cTab)->COUNT1 == 0) 
	lHide := .T.
EndIf
CloseTempTable(cTab)
Return(lHide)



//-----------------------------------------------------------------------
/*/{Protheus.doc} addF37ComInv
Function shows all the Commercial Invoices available to create a Purchases VAT Invoice bases on it.
@author artem.kostin
@since 16/05/2017
@version P12.1.17
@param lExt, logical, Indicates if it is called from Purchases VAT Invoice (.F.) or Outflow Document (.T.)
@type function
/*/
//-----------------------------------------------------------------------
Function addF37ComInv(lExt)
Local lRet := .T.
// Working areas
Local aArea as Array
Local aHeader as Array
Local aCols as Array
Local aRotina as Array

Local oDlg as Object
Local oData as Object

Local oModel as Object

Local nPosSupplier as Numeric
Local nPosBranch as Numeric
Local nLinha as Numeric
Local cFilBkp as Character

Private cSupplier as Character
Private cBranch as Character

Default lExt = .F.

aArea := GetArea()
aHeader := retHeader()

// Variables initialisation
aCols := {}
aRotina := {}
cFilBkp := cFilAnt

If (lExt)
	// If it is called from Outflow Document, must be checked if there is a Purchases VAT Invoice for this Outflow Document.
	If (SF1->F1_STATUSR == "2")
		lRet := .F.
		Help("",1,"RU09T03addF37ComInv01",,STR0018,1,0)	//"VAT Purchases Invoice was already created for this record."8
	EndIf
Else
	// If it is called from Purchases VAT Invoice, must be returned all records
	// which is allowed to create a Purchases VAT Invoice.
	If (RU09T03RD(aCols))
		If (Len(aCols) > 0)
			oDlg := MsDialog():New(160, 160, 400, 1200, STR0015, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.)	// "Purchases Invoices"
		
			oData := MsNewGetDados():New(1/*[ nTop]*/, 1/*[ nLeft]*/, 1/*[ nBottom]*/, 1/*[ nRight ]*/, /*[ nStyle]*/, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, ;
										/*[ cIniCpos]*/, /*[ aAlter]*/, /*[ nFreeze]*/, 999/*[ nMax]*/, /*[ cFieldOk]*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, ;
										oDlg/*[ oWnd]*/, aHeader/*[ aPartHeader]*/, aCols/*[ aParCols]*/, /*[ uChange]*/, /*[ cTela]*/)
			oData:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			
			oDlg:bInit := EnchoiceBar(oDlg, {|| lRet := .T., oDlg:End()}, {|| lRet := .F., oDlg:End()})
			
			oDlg:Activate(, , , .T., {|| .T.}, , {|| .F.})
		Else
			// If there is no record to create a Purchases VAT Invoice, must be canceled and closed this window.
			lRet := .F.
			Help("",1,"RU09T03addF37ComInv02",,STR0012,1,0)	// "According to your filters no records were found"
		EndIf
	Else
		// Questions window was escaped or cancelled.
		lRet := .F.
	EndIf
EndIf

If (lRet)
	If !(lExt)
		nPosSupplier := aScan(aHeader, {|x| AllTrim(x[2]) == "F1_FORNECE"})
		nPosBranch := aScan(aHeader, {|x| AllTrim(x[2]) == "F1_LOJA"})
		nLinha := oData:nAt
		
		cSupplier := oData:aCols[nLinha][nPosSupplier]
		cBranch := oData:aCols[nLinha][nPosBranch]
	else
		//Change filial for item selected at browser(MATA101N)
		cFilAnt := SF1->F1_FILIAL
	EndIf
	
	// If it is everything OK, must to show a window to the end user to continue to add a Purchases VAT Invoice.
	oModel := FwLoadModel("RU09T03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:SetDescription(STR0009)	// "Purchases VAT Invoices"
	oModel:Activate()
	oModel := RU09T03retInc(oModel, oData, aHeader, lExt)

	oModel:GetModel("F38detail"):SetNoInsertLine(.T.)
	oModel:GetModel("SF1detail"):SetNoInsertLine(.T.)
	FwExecView(STR0001, "RU09T03", MODEL_OPERATION_INSERT,/* oDlg */,{|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oModel/*oModelAct*/)	// "Add"

EndIf

cFilAnt := cFilBkp
RestArea(aArea)
Return(lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} retInc
Function that fills automatically the fields at the moment of inclusion.
@author artem.kostin
@since 03/05/2017
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09t03retInc(oModel as Object, oData as Object, aHeader as Array, lExt as Logical)
Local lRet := .T.
// Working areas
Local aArea as Array
Local aAreaSF1 as Array
Local aAreaSD1 as Array
Local aAreaSA2 as Array
Local aAreaF31 as Array
Local aAreaSA2 as Array
// Positioning of user's selection.
Local nPosSer as Numeric
Local nPosDoc as Numeric
Local nPosSupplier as Numeric
Local nPosBranch as Numeric
Local nLinha as Numeric
// Submodels
Local oModelF37 as Object
Local oModelF38 as Object
Local oModelSF1 as Object
// Holds CanInsertLine property.
Local lCanInsertLine as Logical
// Internal VAT key
Local cVATKey as Character
// Character variables for the filter.
Local cFil as Character
Local cDoc as Character
Local cSeries as Character
Local cSupplier as Character
Local cBranch as Character
Local cType as Character
// Variables for SQL requests.
Local cQuery as Character
Local cTabSF1 as Character
Local cTabSD1 as Character

aArea := GetArea()
aAreaSF1 := SF1->(GetArea())
aAreaSD1 := SD1->(GetArea())
aAreaSA2 := SA2->(GetArea())
aAreaF31 := F31->(GetArea())

// If it is called by Outflow Invoice, must be used the actual record.
If (lExt)
	cFil	:= SF1->F1_FILIAL
	cDoc	:= SF1->F1_DOC
	cSeries	:= SF1->F1_SERIE
	cSupplier := SF1->F1_FORNECE
	cBranch	:= SF1->F1_LOJA
	cType	:= SF1->F1_TIPO
// If it is called by Purchases VAT Invoice, must be found the record in SF1.
Else
	nPosDoc	:= aScan(aHeader, {|x| AllTrim(x[2]) == "F1_DOC"})
	nPosSer := aScan(aHeader, {|x| AllTrim(x[2]) == "F1_SERIE"})
	nPosSupplier := aScan(aHeader, {|x| AllTrim(x[2]) == "F1_FORNECE"}) 
	nPosBranch := aScan(aHeader, {|x| AllTrim(x[2]) == "F1_LOJA"})
	nLinha := oData:nAt

	cFil	:= xFilial("SF1")
	cDoc	:= oData:aCols[nLinha][nPosDoc]
	cSeries	:= oData:aCols[nLinha][nPosSer]
	cSupplier := oData:aCols[nLinha][nPosSupplier]
	cBranch	:= oData:aCols[nLinha][nPosBranch]
	cType	:= "N"
EndIf

// Selects a particular Inflow Invoice using a context chosen by user.
cQuery := " SELECT * FROM " + RetSQLName("SF1")
cQuery += " WHERE F1_FILIAL = '" + cFil + "'"
cQuery += " AND F1_DOC = '" + cDoc + "'"
cQuery += " AND F1_SERIE = '" + cSeries + "'"
cQuery += " AND F1_FORNECE = '" + cSupplier + "'"
cQuery += " AND F1_LOJA = '" + cBranch + "'"
cQuery += " AND F1_TIPO = '" + cType + "'"
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY F1_FILIAL"
cQuery += " ,F1_DOC"
cQuery += " ,F1_SERIE"
cQuery += " ,F1_FORNECE"
cQuery += " ,F1_LOJA"
cQuery += " ,F1_TIPO"
// Performs the query.
cTabSF1 := MPSysOpenQuery(ChangeQuery(cQuery))

// Selects a particular Inflow Invoice Details using a context chosen by user.
cQuery := " SELECT * FROM " + RetSQLName("SD1")
cQuery += " WHERE D1_FILIAL = '" + cFil + "'"
cQuery += " AND D1_DOC = '" + cDoc + "'"
cQuery += " AND D1_SERIE = '" + cSeries + "'"
cQuery += " AND D1_FORNECE = '" + cSupplier + "'"
cQuery += " AND D1_LOJA = '" + cBranch + "'"
cQuery += " AND D1_TIPO = '" + cType + "'"
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY D1_FILIAL"
cQuery += " ,D1_DOC"
cQuery += " ,D1_SERIE"
cQuery += " ,D1_FORNECE"
cQuery += " ,D1_LOJA"
cQuery += " ,D1_TIPO"
cQuery += " ,D1_ITEM"
// Performs the query.
cTabSD1 := MPSysOpenQuery(ChangeQuery(cQuery))

DbSelectArea("F31")
F31->(DbSetOrder(1))

DbSelectArea("SA2")
SA2->(DbSetOrder(1))
SA2->(DbSeek(xFilial("SA2") + cSupplier + cBranch))

// If at least one Inflow Invoice is returned by select (and should be only one).
If (!(cTabSF1)->(Eof()))
	// If this Inflow Invoice contains at least one line of details.
	If (!(cTabSD1)->(Eof()))
		oModelF37 := oModel:GetModel("F37master")
		oModelF38 := oModel:GetModel("F38detail")
		oModelSF1 := oModel:GetModel("SF1detail")
		
		cVATKey := retKey()
		While !MayIUseCode("RU09T03"+cVATKey)
			cVATKey := Soma1(cVATKey)
		EndDo

		lRet := lRet .and. oModelF37:LoadValue("F37_FILIAL", xFilial("F37")) // Filial
		lRet := lRet .and. oModelF37:LoadValue("F37_ORIGIN", "1")	// Purchases Commercial Invoice
		lRet := lRet .and. oModelF37:LoadValue("F37_TYPE", "1")	// Purchases VAT Invoice
		lRet := lRet .and. oModelF37:LoadValue("F37_PDATE", StoD((cTabSF1)->F1_EMISSAO))	// Print Date
		lRet := lRet .and. oModelF37:LoadValue("F37_INVDT", StoD((cTabSF1)->F1_DTDIGIT))	// Commercial Invoice Issue Date
		lRet := lRet .and. oModelF37:LoadValue("F37_ITDATE", StoD((cTabSF1)->F1_EMISSAO))	// Commercial Type Issue Date
		lRet := lRet .and. oModelF37:LoadValue("F37_INVSER", (cTabSF1)->F1_SERIE)	// Commercial Invoice Series
		lRet := lRet .and. oModelF37:LoadValue("F37_INVDOC", (cTabSF1)->F1_DOC)	// Commercial Invoice Number
		lRet := lRet .and. oModelF37:LoadValue("F37_RDATE", dDataBase)	// Real Inclusion Date
		lRet := lRet .and. oModelF37:LoadValue("F37_TDATE", Date())	// Input Date
		lRet := lRet .and. oModelF37:LoadValue("F37_FORNEC", (cTabSF1)->F1_FORNECE)	// Supplier
		lRet := lRet .and. oModelF37:LoadValue("F37_BRANCH", (cTabSF1)->F1_LOJA) // Supplier Branch
		lRet := lRet .and. oModelF37:LoadValue("F37_NAME", SA2->A2_NOME) // Supplier Branch
		lRet := lRet .and. oModelF37:LoadValue("F37_MOEDA", (cTabSF1)->F1_MOEDA) // VAT Invoice Currency
		lRet := lRet .and. oModelF37:LoadValue("F37_MOEDES", Posicione("CTO",1,xFilial("CTO")+StrZero((cTabSF1)->F1_MOEDA,TamSX3("CTO_MOEDA")[1]),"CTO_SIMB")) // VAT Invoice Currency Description
		lRet := lRet .and. oModelF37:LoadValue("F37_CONUNI", (cTabSF1)->F1_CONUNI) // Conventional Units
		lRet := lRet .and. oModelF37:LoadValue("F37_INVCUR", Iif((cTabSF1)->F1_CONUNI == "1", "01", StrZero((cTabSF1)->F1_MOEDA,TamSX3("F37_INVCUR")[1]))) // Commercial Invoice Currency
		lRet := lRet .and. oModelF37:LoadValue("F37_ICUDES", Posicione("CTO",1,xFilial("CTO")+PadL(FwFldGet("F37_INVCUR"),TamSX3("CTO_MOEDA")[1],"0"),"CTO_SIMB")) // Commercial Invoice Currency Description
		lRet := lRet .and. oModelF37:LoadValue("F37_C_RATE", (cTabSF1)->F1_TXMOEDA)	// Unique Internal Key
		lRet := lRet .and. oModelF37:LoadValue("F37_KEY", cVATKey)	// Unique Internal Key
		lRet := lRet .and. oModelF37:LoadValue("F37_CNEE_C", (cTabSF1)->F1_CNEECOD)	// Consignee Code
		lRet := lRet .and. oModelF37:LoadValue("F37_CNEE_B", (cTabSF1)->F1_CNEEBR)	// Consignee Branch
		lRet := lRet .and. oModelF37:LoadValue("F37_CNOR_C", (cTabSF1)->F1_CNORCOD)	// Consignor Code
		lRet := lRet .and. oModelF37:LoadValue("F37_CNOR_B", (cTabSF1)->F1_CNORBR)	// Consignor Brancs
		lRet := lRet .and. oModelF37:LoadValue("F37_CNRVEN", (cTabSF1)->F1_CNORSUP)	// Consignor
		lRet := lRet .and. oModelF37:LoadValue("F37_CNECLI", (cTabSF1)->F1_CNEEBUY)	// Consignee
		aAreaSA2 := GetArea("SA2")
		lRet := lRet .and. oModelF37:LoadValue("F37_CNRDES", PADR(Posicione("SA2",1,xFilial("SA2")+PADR((cTabSF1)->F1_CNORCOD,TamSX3("A2_COD")[1], " ")+PADR((cTabSF1)->F1_CNORBR ,TamSX3("A2_LOJA")[1]," "),"A2_NREDUZ"),TamSX3("F37_CNRDES")[1]," "))	// Consignor Des
		RestArea(aAreaSA2)
		lRet := lRet .and. oModelF37:LoadValue("F37_CNEDES", Posicione('SA1',1,xFilial('SA1')+(cTabSF1)->(F1_CNEECOD+F1_CNEEBR),'A1_NREDUZ'))	// Consignee
		lRet := lRet .and. oModelF37:LoadValue("F37_F5QUID", (cTabSF1)->F1_F5QUID)
		lRet := lRet .and. oModelF37:LoadValue("F37_CONTRA", (cTabSF1)->F1_CNTID)
		lRet := lRet .and. oModelF37:LoadValue("F37_F5QDES",Iif(!EMPTY(FwFldGet('F37_F5QUID')),Posicione('F5Q',1,XFILIAL('F5Q')+FwFldGet('F37_F5QUID'),'F5Q_DESCR'),''))
		lRet := lRet .and. oModelF37:LoadValue("F37_KPP_SP", SA2->A2_KPP)	// Supplier KPP
		lRet := lRet .and. oModelF37:LoadValue("F37_KPP_CO", GetCoBrRUS()[2][5][2]) // Branch KPP
		If !lRet
			Help("",1,"RU09t03retInc01",,STR0927,1,0)
		EndIf

		// Iterates all over the details returned by select.
		lCanInsertLine := oModel:GetModel("F38detail"):CanInsertLine()
		oModel:GetModel("F38detail"):SetNoInsertLine(.F.)
		FillF38Table(oModel, cTabSD1, .F.)
		oModel:GetModel("F38detail"):SetNoInsertLine(!lCanInsertLine)
		
		lCanInsertLine := oModel:GetModel("F38detail"):CanInsertLine()
		oModel:GetModel("SF1detail"):SetNoInsertLine(.F.)
		lRet := lRet .and. oModelSF1:LoadValue("F1_SERIE", (cTabSF1)->F1_SERIE)
		lRet := lRet .and. oModelSF1:LoadValue("F1_DOC", (cTabSF1)->F1_DOC)
		lRet := lRet .and. oModelSF1:LoadValue("F1_DTDIGIT", Stod((cTabSF1)->F1_DTDIGIT))
		lRet := lRet .and. oModelSF1:LoadValue("F1_EMISSAO", Stod((cTabSF1)->F1_EMISSAO))
		lRet := lRet .and. oModelSF1:LoadValue("F1_FORNECE", (cTabSF1)->F1_FORNECE)
		lRet := lRet .and. oModelSF1:LoadValue("F1_LOJA", (cTabSF1)->F1_LOJA)
		lRet := lRet .and. oModelSF1:LoadValue("F1_BASIMP1", (cTabSF1)->F1_BASIMP1)
		lRet := lRet .and. oModelSF1:LoadValue("F1_VALIMP1", (cTabSF1)->F1_VALIMP1)
		lRet := lRet .and. oModelSF1:LoadValue("F1_VALBRUT", (cTabSF1)->F1_VALBRUT)
		oModel:GetModel("SF1detail"):SetNoInsertLine(!lCanInsertLine)
		If !lRet
			Help("",1,"RU09t03retInc02",,STR0927,1,0)
		EndIf
	Else
		Help("",1,"RU09T03retInc03",,STR0013,1,0)	// "No Commercial Invoice's items found"
	EndIf
Else
	Help("",1,"RU09T03retInc04",,STR0014,1,0)	// "No Commercial Invoices found"
EndIf

CloseTempTable(cTabSF1)
CloseTempTable(cTabSD1)

RestArea(aAreaF31)
RestArea(aAreaSA2)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
Return(oModel)


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T03RD (retDados)
Function that returns all records which is allowed to create a Purchases VAT Invoice.
@author artem.kostin
@since 02/05/2017
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T03RD(aRet as Array)
Local lRet := .T.
// Variables for SQL requests.
Local cQuery as Character
Local cTab as Character
// Parameters of filtering questions.
Local cPerg as Character
Local cFromSer as Character
Local cToSer as Character
Local cFromDoc as Character
Local cToDoc as Character
Local cFromCus as Character
Local cFromBra as Character
Local cToCus as Character
Local cToBra as Character
Local dFromDt as Date
Local dToDt as Date

Default aRet := {}

cPerg := "RU09T0301"

// Opens the window with questions "From" - "To" used as filter.
If (Pergunte(cPerg, .T.))
	cFromSer := AllTrim(mv_par01)
	cToSer := AllTrim(mv_par02)
	cFromDoc := AllTrim(mv_par03)
	cToDoc := AllTrim(mv_par04)
	cFromCus := AllTrim(mv_par05)
	cFromBra := AllTrim(mv_par06)
	cToCus := AllTrim(mv_par07)
	cToBra := AllTrim(mv_par08)
	dFromDt := mv_par09
	dToDt := mv_par10
	
	cQuery := " SELECT T0.F1_SERIE"
	cQuery += " ,T0.F1_DOC"
	cQuery += " ,T0.F1_FORNECE"
	cQuery += " ,T0.F1_LOJA"
	cQuery += " ,T1.A2_NOME"
	cQuery += " ,T0.F1_EMISSAO"
	cQuery += " ,T0.F1_MOEDA"
	cQuery += " ,T0.F1_BASIMP1"
	cQuery += " ,T0.F1_VALIMP1"
	cQuery += " ,T0.F1_VALBRUT"
	cQuery += "	,T0.F1_CONUNI"
	cQuery += " FROM " + RetSQLName("SF1") + " T0"
	cQuery += " INNER JOIN " + RetSQLName("SA2") + " T1"
	cQuery += " ON ("
	cQuery += " T1.A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += " AND T1.A2_COD = T0.F1_FORNECE"
	cQuery += " AND T1.A2_LOJA = T0.F1_LOJA"
	cQuery += " AND T1.D_E_L_E_T_ = ' '"
	cQuery += ")"
	cQuery += " WHERE T0.F1_FILIAL = '" + xFilial("SF1") + "'"
	If (!Empty(cFromSer))
		cQuery += " AND T0.F1_SERIE >= '" + cFromSer + "'"
	EndIf
	If (!Empty(cToSer))
		cQuery += " AND T0.F1_SERIE <= '" + cToSer + "'"
	EndIf
	If (!Empty(cFromDoc))
		cQuery += " AND T0.F1_DOC >= '" + cFromDoc + "'"
	EndIf
	If (!Empty(cToDoc))
		cQuery += " AND T0.F1_DOC <= '" + cToDoc + "'"
	EndIf
	If (!Empty(cFromCus))
		cQuery += " AND T0.F1_FORNECE >= '" + cFromCus + "'"
	EndIf
	If (!Empty(cToCus))
		cQuery += " AND T0.F1_FORNECE <= '" + cToCus + "'"
	EndIf
	If (!Empty(cFromBra))
		cQuery += " AND T0.F1_LOJA >= '" + cFromBra + "'"
	EndIf
	If (!Empty(cToBra))
		cQuery += " AND T0.F1_LOJA <= '" + cToBra + "'"
	EndIf
	If (!Empty(DToS(dFromDt)))
		cQuery += " AND T0.F1_EMISSAO >= '" + DToS(dFromDt) + "'"
	EndIf
	If (!Empty(DToS(dToDt)))
		cQuery += " AND T0.F1_EMISSAO <= '" + DToS(dToDt) + "'"
	EndIf
	cQuery += " AND T0.F1_TIPO = 'N'"
	cQuery += " AND T0.F1_TIPODOC = '10'"
	cQuery += " AND T0.F1_STATUSR <> '2'"
	cQuery += " AND T0.D_E_L_E_T_ = ' '"
	
	cTab := MPSysOpenQuery(ChangeQuery(cQuery))
	
	DbSelectArea((cTab))
	(cTab)->(DbGoTop())
	
	While ((cTab)->(!Eof()))
		aAdd(aRet, {(cTab)->F1_SERIE, (cTab)->F1_DOC, (cTab)->F1_FORNECE, (cTab)->F1_LOJA, (cTab)->A2_NOME, ;
					DToC(SToD((cTab)->F1_EMISSAO)), (cTab)->F1_MOEDA, (cTab)->F1_BASIMP1, (cTab)->F1_VALIMP1, (cTab)->F1_VALBRUT, (cTab)->F1_CONUNI, .F.})
	
		(cTab)->(DbSkip())
	EndDo
	
	(cTab)->(DbCloseArea())
Else
	// If user closes the questions window, nothing happens.
	lRet := .F.
EndIf

Return(lRet)



//-----------------------------------------------------------------------
/*/{Protheus.doc} retHeader
Function that returns the header to select an Outflow Invoice to create a Purchases VAT Invoice.
@author artem.kostin
@since 02/05/2017
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Static Function retHeader()
Local aRet as Array
Local aArea as Array
Local aAreaSX3 as Array
Local aCampos as Array
Local nI as Numeric

aRet := {}
aArea := GetArea()
aAreaSX3 := SX3->(GetArea())
aCampos := {}

aAdd(aCampos, "F1_SERIE")
aAdd(aCampos, "F1_DOC")
aAdd(aCampos, "F1_FORNECE")
aAdd(aCampos, "F1_LOJA")
aAdd(aCampos, "A2_NOME")
aAdd(aCampos, "F1_EMISSAO")
aAdd(aCampos, "F1_MOEDA")
aAdd(aCampos, "F1_BASIMP1")
aAdd(aCampos, "F1_VALIMP1")
aAdd(aCampos, "F1_VALBRUT")
aAdd(aCampos, "F1_CONUNI")

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nI := 1 To Len(aCampos)
	If (SX3->(DbSeek(aCampos[nI])))
		aAdd(aRet, {AllTrim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, , SX3->X3_TIPO, , })
	EndIf
Next nI

RestArea(aAreaSX3)
RestArea(aArea)
Return(aRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} retKey
Function that returns the last value from the field F37_KEY.
@author artem.kostin
@since 10/05/2017
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Static Function retKey()
Local cQuery as Character
Local cTab as Character
Local cRet as Character
Local cProx as Character
Local aArea as Array

aArea := GetArea()

cQuery := " SELECT COALESCE(MAX(F37_KEY), '0') AS F37_KEY"
cQuery += " FROM " + RetSQLName("F37") + " T0"
cQuery += " WHERE T0.F37_FILIAL = '" + xFilial("F37") + "'"
cQuery += " AND T0.D_E_L_E_T_ = ' '"

cTab := MPSysOpenQuery(ChangeQuery(cQuery))

DbSelectArea((cTab))
(cTab)->(DbGoTop())

While ((cTab)->(!Eof()))
	cProx := Soma1(AllTrim((cTab)->F37_KEY))
	cRet := StrZero(Val(cProx), TamSX3("F38_KEY")[1])
	
	(cTab)->(DbSkip())
EndDo

(cTab)->(DbCloseArea())

RestArea(aArea) 
Return(cRet)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T03MR
Function that saves the model.
@author artem.kostin
@since 10/05/2017
@version P12.1.17
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T03MR(oModel as Object)
Local lRet := .T.

Local cPerg as Character
Local lShowJE as Logical
Local lGroupJE as Logical
Local lOnlineJE as Logical
Local lContinuous as Logical

Local oModelF38 as object
Local oModelF37 as object
Local oModelSF1 as object
Local nOperation as Numeric
Local cKeySF1 as Character

Local nI as numeric
Local nItem as numeric

Local cInvDoc as Character
Local cInvSer as Character
Local cFornece as Character
Local cLoja as Character
Local cCFExt as Character

Local cKey as Character

cKeySF1 := ""

nOperation := oModel:GetOperation()
cPerg := "RU09T03"
lContinuous := .T.

Pergunte(cPerg, .F.)

lShowJE := (mv_par01 == 1)
lGroupJE := (mv_par02 == 1)
lOnlineJE := (mv_par03 == 1)

DbSelectArea("SF1")
SF1->(DbSetOrder(1))

oModelF37 := oModel:GetModel("F37master")
oModelF38 := oModel:GetModel("F38detail")
oModelSF1 := oModel:GetModel("SF1detail")

If (nOperation == MODEL_OPERATION_INSERT)
	cCFExt := ""
	nItem := 1
	For nI := 1 to oModelF38:Length()
		oModelF38:GoLine(nI)
		//Menyashina Alexandra: If we have delete items we should move items
		If !(oModelF38:Isdeleted())
			oModelF38:LoadValue("F38_ITEM", StrZero(nItem, TamSX3("F38_ITEM")[1]))
			nItem++
		EndIf
	Next nI
	For nI := 1 to oModelF38:Length()
		oModelF38:GoLine(nI)
		If !(oModelF38:Isdeleted())
			If !(oModelF38:GetValue("F38_VATCD2") $ cCFExt)
				cCFExt += AllTrim(oModelF38:GetValue("F38_VATCD2")) + ";"
			EndIf			
		EndIf
	Next nI
	If !Empty(cCFExt)
	// Crops last two symbols ", " to prepate string for SQL query.
	cCFExt := SubStr(cCFExt, 1, Len(cCFExt)-1)
	EndIf
	lRet := lRet .and. oModelF37:LoadValue("F37_VATCD2", cCFExt)	// External VAT Codes

	cKey := retKey()
	While !(MayIUseCode("RU09T03" + cKey))
		cKey := Soma1(cKey)
	EndDo
	FreeUsedCode(.T.)
	lRet := lRet .and. oModelF37:LoadValue("F37_KEY", cKey)
EndIf

Begin Transaction
If (nOperation == MODEL_OPERATION_INSERT)
	// Finds all the Commercial Invoices, which are included into the Purchases VAT Invoice, and put the mark,
	// that the Purchases VAT Invoice for Commercial Invoice exists.
	For nI := 1 to oModelF38:Length()
		oModelF38:GoLine(nI)
		If !oModelF38:Isdeleted()
			cInvDoc := SubStr(oModelF38:GetValue("F38_INVDOC"), 1, TamSX3("F1_DOC")[1])
			cInvSer := SubStr(oModelF38:GetValue("F38_INVSER"), 1, TamSX3("F1_SERIE")[1])
			cFornece := SubStr(oModelF37:GetValue("F37_FORNEC"), 1, TamSX3("F1_FORNECE")[1])
			cLoja := SubStr(oModelF37:GetValue("F37_BRANCH"), 1, TamSX3("F1_LOJA")[1])

			If (SF1->(DbSeek(xFilial("SF1") + cInvDoc + cInvSer + cFornece + cLoja)))
				If(SF1->F1_STATUSR != "2")
					RecLock("SF1", .F.)
						SF1->F1_STATUSR := "2"
					SF1->(MsUnlock())
				EndIf
			EndIf
		EndIf
	Next nI

	lRet := lRet .and. FWFormCommit(oModel)
	lRet := lRet .and. RU09D05Add(oModel)
	lRet := lRet .and. RU09D04Add(oModel)

	If lRet .and. (oModel:GetModel("F37master"):GetValue("F37_ATBOOK") == "1")
		lRet := lRet .and. gravaBook(oModel)
	EndIf
	
	// // Posting accounting entries.
	//	RU09T03Ctb(oModel, .T.)

	If !lRet
		DisarmTransaction()
		Help("",1,"RU09T03MR01",,STR0944,1,0)
	EndIf

ElseIf (nOperation == MODEL_OPERATION_DELETE)
	If (lContinuous)

		For nI := 1 to oModelF38:Length()
			oModelF38:GoLine(nI)

			cInvDoc := SubStr(oModelF38:GetValue("F38_INVDOC"), 1, TamSX3("F1_DOC")[1])
			cInvSer := SubStr(oModelF38:GetValue("F38_INVSER"), 1, TamSX3("F1_SERIE")[1])
			cFornece := SubStr(oModelF37:GetValue("F37_FORNEC"), 1, TamSX3("F1_FORNECE")[1])
			cLoja := SubStr(oModelF37:GetValue("F37_BRANCH"), 1, TamSX3("F1_LOJA")[1])

			If (SF1->(DbSeek(xFilial("SF1") + cInvDoc + cInvSer + cFornece + cLoja)))
				// if we update this status prewios item it is bypassing
				If(SF1->F1_STATUSR != "1")
					RecLock("SF1", .F.)
						SF1->F1_STATUSR := "1"
					SF1->(MsUnlock())
				EndIf
			EndIf
		Next nI

		// Commit.
		lRet := lRet .and. FWFormCommit(oModel)
		lRet := lRet .and. RU09D05Del(oModel)
		lRet := lRet .and. RU09D04Del(oModel)
		
		// // Posting accounting entries.
		// RU09T03Ctb(oModel, .F.)

		If !lRet
			DisarmTransaction()
			Help("",1,"RU09T03MR02",,STR0944,1,0)
		EndIf
	EndIf

ElseIf (nOperation == MODEL_OPERATION_UPDATE)
	// Just commit.
	lRet := lRet .and. FWFormCommit(oModel)
	lRet := lRet .and. RU09D05Edt(oModel)
	lRet := lRet .and. RU09D04Edt(oModel)

	// // Posting accounting entries.
	// RU09T03Ctb(oModel, .F.)

	If !lRet
		DisarmTransaction()
		Help("",1,"RU09T03MR02",,STR0944,1,0)
	EndIf
EndIf
End Transaction

Return(lRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T03Ctb (CtbVAT)
Function thats posts accounting entries.
@author artem.kostin
@since 05/05/2017
@version P12.1.17
@param oModel, object, Needs to receive the actual model.
@param lInc, logical, Needs to inform it is an inclusion or not.
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T03Ctb(oModel as Object, lInc as Logical)
Local lRet := .T.
Local oModelF37 as Object
Local oModelF38 as Object
Local nHdlPrv as Numeric
Local cLoteFis as Character
Local cOrigem as Character
Local cArquivo as Character
Local nTotal as Numeric
Local lCommit as Logical
Local cPadrao as Character
Local cKeyF37 as Character
Local cKeyF38 as Character
Local aArea as Array
Local aAreaF37 as Array
Local aAreaF38 as Array
Local aAreaSF1 as Array
Local aAreaSA2 as Array
Local aAreaSD1 as Array
Local aAreaSB1 as Array
Local aAreaSC7 as Array
Local aAreaSB8 as Array
Local aAreaSF4 as Array
Local aAreaSFB as Array

Local cKeySD1 as Character
Local lShowJE as Logical
Local lGroupJE as Logical
Local cPerg as Character
Local nItem as Numeric

cPerg := "RU09T03"

Pergunte(cPerg, .F.)

oModelF37 := oModel:GetModel("F37master")
oModelF38 := oModel:GetModel("F38detail")
nHdlPrv := 0
cLoteFis := LoteCont("FIS")
cOrigem := "RU09T03"
cArquivo := " "
nTotal := 0
lCommit := .F.
// If it is an inclusion, must be used the Standard Entry 6AG to the header.
// If it is a deletion, must be used the Standard Entry 6AH to the header.
cPadrao := Iif(lInc, "6AG", "6AH")
aArea := GetArea()
aAreaF37 := F37->(GetArea())
aAreaF38 := F38->(GetArea())
aAreaSF1 := SF1->(GetArea())
aAreaSA2 := SA2->(GetArea())
aAreaSD1 := SD1->(GetArea())
aAreaSB1 := SB1->(GetArea())
aAreaSC7 := SC7->(GetArea())
aAreaSB8 := SB8->(GetArea())
aAreaSF4 := SF4->(GetArea())
aAreaSFB := SFB->(GetArea())
cKeySD1 := ""
lShowJE	:= (mv_par02 == 1)
lGroupJE := (mv_par03 == 1)

cKeyF37 := xFilial("F37") + oModelF37:GetValue("F37_FORNEC") + oModelF37:GetValue("F37_BRANCH") + DToS(oModelF37:GetValue("F37_PDATE")) + oModelF37:GetValue("F37_DOC") + oModelF37:GetValue("F37_TYPE")
	
// Needs to set the records in tables F37, SF1 and SA1 to help the end user to work with Standard Entries 6AG and 6AH.
DbSelectArea("F37")
F37->(DbSetOrder(2))
F37->(DbSeek(cKeyF37))

DbSelectArea("SF1")
SF1->(DbSetOrder(1))
SF1->(DbSeek(xFilial("SF1") + SubStr(F37->F37_INVDOC, 1, TamSX3("F1_DOC")[1]) + SubStr(F37->F37_INVSER, 1, TamSX3("F1_SERIE")[1]) + F37->F37_FORNEC + F37->F37_BRANCH))                                                                                                  

DbSelectArea("SA2")
SA2->(DbSetOrder(1))
SA2->(DbSeek(xFilial("SA2") + F37->F37_FORNEC + F37->F37_BRANCH))

DbSelectArea("F37")

nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)

If (nHdlPrv > 0)
	nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,;
					/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
					/*lPosiciona*/, /*@aFlagCTB*/, /*aTabRecOri*/, /*aDataProva*/)
	cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lShowJE, lGroupJE)
	RodaProva(nHdlPrv, nTotal)
	
	// Updates the posting date.
	RecLock("F37", .F.)
	F37->F37_DTLA := dDataBase
	F37->(MsUnlock())
	
	// Updates the Outflow Document Status for Russia. 
	//If it is an inclusion needs to set "1" and if it is a deletion needs to set "2".
	RecLock("SF1", .F.)
	SF1->F1_STATUSR := Iif(lInc, "2", "1")
	SF1->(MsUnlock())
EndIf

// If it is an inclusion, must be used the Standard Entry 6AB to the items.
// If it is a deletion, must be used the Standard Entry 6AD to the items.
cPadrao := Iif(lInc, "6AB", "6AD")
nItem := 1

cKeySD1 := xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
cKeyF38 := xFilial("F38") + oModelF38:GetValue("F38_KEY")

DbSelectArea("SD1")
SD1->(DbSetOrder(3))
SD1->(DbSeek(cKeySD1))

nTotal := 0
nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)

While ((SD1->(!Eof())) .And. (cKeySD1 == xFilial("SD1") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA))
	// Needs to set the records in tables SD1, SB1, SC7, SB8, SF4, SFB, F37 and F38
	// to help the end user to work with Standard Entries 6AB and 6AD.
	DbSelectArea("F38")
	F38->(DbSetOrder(1))
	If !(F38->(DbSeek(cKeyF38 + StrZero(nItem, TamSX3("F38_ITEM")[1]))))
		SD1->(DbSkip())
		Loop
	EndIf
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + SD1->D1_COD))
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPV + SD1->D1_COD))
	
	DbSelectArea("SB8")
	SB8->(DbSetOrder(2))
	SB8->(DbSeek(xFilial("SB8") + SD1->D1_NUMLOTE + SD1->D1_LOTECTL + SD1->D1_COD + SD1->D1_LOCAL))
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4") + SD1->D1_TES))
	
	DbSelectArea("SFB")
	SFB->(DbSetOrder(1))
	SFB->(DbSeek(xFilial("SFB") + "VAT"))
	
	DbSelectArea("F38")
	F38->(DbSetOrder(1))
	F38->(DbSeek(cKeyF38 + StrZero(nItem, TamSX3("F38_ITEM")[1])))
	
	nItem++
	
	If (nHdlPrv > 0)
		nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,;
						/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
						/*lPosiciona*/, /*@aFlagCTB*/, /*aTabRecOri*/, /*aDataProva*/)
		
		RecLock("F38", .F.)
		F38->F38_DTLA := dDataBase
		F38->(MsUnlock())
	EndIf
	
	SD1->(DbSkip())
EndDo

cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lShowJE, lGroupJE)
RodaProva(nHdlPrv, nTotal)

RestArea(aArea)
RestArea(aAreaF37)
RestArea(aAreaF38)
RestArea(aAreaSF1)
RestArea(aAreaSA2)
RestArea(aAreaSD1)
RestArea(aAreaSB1)
RestArea(aAreaSC7)
RestArea(aAreaSB8)
RestArea(aAreaSF4)
RestArea(aAreaSFB)
Return(lRet)


/*/{Protheus.doc} RU09T03N
Function that returns the customer's name.
@author felipe.morais
@since 10/07/2017
@version P12.1.16
@type function
/*/
Function RU09T03N()
Local cRet := ""
Local cKey := ""
Local aArea := GetArea()
Local aAreaSA2 := SA2->(GetArea())

If (IsInCallStack("RU09T03RUS"))
	If (IsInCallStack("addF37ComInv"))
		cKey := cSupplier + cBranch
	ElseIf (IsInCallStack("RU09T03Mnl"))
		cKey := ""
	Else
		cKey := F37->F37_FORNEC + F37->F37_BRANCH
	EndIf
Else
	cKey := SF1->F1_FORNECE + SF1->F1_LOJA
EndIf

DbSelectArea("SA2")
SA2->(DbSetOrder(1))
If !Empty(AllTrim(cKey)) .and. (SA2->(DbSeek(xFilial("SA2") + cKey)))
	cRet := SA2->A2_NOME
EndIf

RestArea(aAreaSA2)
RestArea(aArea)
Return(cRet)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T03act
Function that provides actions from out Outflow Modules
@author artem.kostin
@since 10/07/2017
@version P12.1.17
@param		nOperation	Numeric		Number of operation
			lInSide		Logical		Flag if function is called outside (.F.) for identifying SF1 record
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T03act(nOperation, lInside)
Local lRet	:=	.T.
Local cQueryCount := ""
Local cBookCodes := ""
Local cWriOffCodes := ""
Local cTabWriOff := ""
Local cTab := ""
Local cTabBook := ""
Local aListOfCodes := {}
Local aArea		:= GetArea()

Default lInside := .F.

If !lInside
	cQueryCount	:=	" SELECT COUNT(*) AS COUNT1, MAX(F37.R_E_C_N_O_) AS RECNR " 
	cQueryCount	+=	" FROM "+retSqlName('F38')+" F38, "+retSqlName('F37')+' F37 '
	cQueryCount	+=	" WHERE "
	cQueryCount	+=	" F37_FILIAL = '"+XFILIAL('F37')+"' AND "
	cQueryCount	+=	" F38_FILIAL = '"+XFILIAL('F38')+"' AND "
	cQueryCount	+=	" F38_KEY = F37_KEY AND "

	cQueryCount	+=	" F38_INVSER = '" + SF1->F1_SERIE + "' AND"
	cQueryCount	+=	" F38_INVDOC = '" + SF1->F1_DOC + "' AND"
	cQueryCount	+=	" F37_FORNEC = '" + SF1->F1_FORNECE  + "' AND"
	cQueryCount	+=	" F37_BRANCH = '" + SF1->F1_LOJA  + "' AND"
	cQueryCount	+=	" F38.D_E_L_E_T_= ' ' AND "
	cQueryCount	+=	" F37.D_E_L_E_T_= ' ' "
	cTab := MPSysOpenQuery(ChangeQuery(cQueryCount))
	If (cTab)->COUNT1 == 0 
		lRet :=	.F.
		Help("",1,"RU09T03act01",,STR0016,1,0)	// "There is no VAT Invoice for this record."
	Else
		F37->(DbGoto((cTab)->RECNR))
	EndIf
	CloseTempTable(cTab)
EndIf

If (lRet .and. (nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE))
	cBookCodes := " SELECT DISTINCT F3C_BOOKEY"
	cBookCodes += " ,F3C_CODE AS CODE"
	cBookCodes += " FROM " + RetSqlName("F3C")
	cBookCodes += " WHERE F3C_KEY = '" + F37->F37_KEY + "'"
	cBookCodes += " AND F3C_FILIAL = '" + xFilial('F3C') + "'"
	cBookCodes += " AND D_E_L_E_T_ = ' '"
	cTabBook := MPSysOpenQuery(ChangeQuery(cBookCodes))

	cWriOffCodes := " SELECT DISTINCT F3E_WRIKEY"
	cWriOffCodes += " ,F3E_CODE AS CODE"
	cWriOffCodes += " FROM " + RetSqlName("F3E")
	cWriOffCodes += " WHERE F3E_KEY = '" + F37->F37_KEY + "'"
	cWriOffCodes += " AND F3E_FILIAL = '" + xFilial('F3E') + "'"
	cWriOffCodes += " AND D_E_L_E_T_ = ' '"
	cTabWriOff := MPSysOpenQuery(ChangeQuery(cWriOffCodes))

	aListOfCodes := {}
	While !(cTabBook)->(Eof())
		If !Empty(AllTrim((cTabBook)->CODE))
			aAdd(aListOfCodes, (cTabBook)->CODE)
		EndIf
		(cTabBook)->(DbSkip())
	EndDo
	If Len(aListOfCodes) > 0
		lRet := .F.
		Help("",1,"RU09T03Act02",,STR0010,1,0,,,,,,aListOfCodes)	// Action is prohibited. This record is already in the Purchases Book
	EndIf

	aListOfCodes := {}
	While !(cTabWriOff)->(Eof())
		If !Empty(AllTrim((cTabWriOff)->CODE))
			aAdd(aListOfCodes, (cTabWriOff)->CODE)
		EndIf
		(cTabWriOff)->(DbSkip())
	EndDo
	If Len(aListOfCodes) > 0
		lRet := .F.
		Help("",1,"RU09T03Act03",,STR0040,1,0,,,,,,aListOfCodes)	// Action is prohibited. This record is already in the VAT Write-Off
	EndIf
	
	CloseTempTable(cTabWriOff)
	CloseTempTable(cTabBook)
EndIf

If lRet
	FWExecView(" ","RU09T03",nOperation,,{|| .T.})
EndIf

RestArea(aArea)
Return lRet 



//-------------------------------------------------------------------
/*/{Protheus.doc} TableAttDef
@param		Nenhum
@return	Nenhum
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		16/01/2017
/*/
//-------------------------------------------------------------------
Static Function TableAttDef()
Local oTableAtt as Object
Local lCRMBrwView as Logical

oTableAtt 	:= Nil
lCRMBrwView	:= ExistBlock("CRMBRWVIEW")	// Entrance point for views
	
If lCRMBrwView
	oTableAtt := ExecBlock("CRMBRWVIEW", .F.,.F.,{cRotina,cAliasView})
EndIf 

If Empty(oTableAtt)
	oTableAtt 	:= FWTableAtt():New()
	oTableAtt:SetAlias("F37")
EndIf

Return oTableAtt

/*{Protheus.doc} LoadComInv
@author Alexandra Menyashina
@since 05/02/2018
@version P12.1.20
@return nil
@type function
@description Function which added in Model structure more Invoice.
*/
static Function LoadComInv(oStructSF1 as object , cFil as Character, cSuplier as Character, cBranch as Character, cVATKey as Character)
Local nX as Numeric
Local cQuery as Character
Local cTab as Character
Local aRet as Array
Local aTmp as Array
Local aFields as Array
Local xValue

aRet := {}
cQuery := ""
cTab := ""
aFields	:= oStructSF1:GetFields()

cQuery += " SELECT "
For nX := 1 To Len(aFields)
	cQuery	+= aFields[nX, MODEL_FIELD_IDFIELD]
	cQuery	+= IIf(nX == Len(aFields), "", ",")
Next nX
cQuery += " FROM " + RetSqlName("SF1")
cQuery += " WHERE F1_FILIAL = '" + cFil + "'"
cQuery += " AND F1_FORNECE = '" + cSuplier + "'"
cQuery += " AND F1_LOJA = '" + cBranch + "'"
cQuery += " AND F1_SERIE IN (SELECT F38_INVSER FROM " + RetSqlName("F38") + " WHERE F38_FILIAL ='" + cFil + "' AND  F38_KEY='" + cVATKey + "')"
cQuery += " AND F1_DOC IN (SELECT F38_INVDOC FROM " + RetSqlName("F38") + " WHERE F38_FILIAL ='" + cFil + "' AND  F38_KEY='" + cVATKey + "')"
cQuery += " AND D_E_L_E_T_= ' ' "

cTab := MPSysOpenQuery(ChangeQuery(cQuery))

For nX:=1 to len(aFields)
	if aFields[nX, 4]<>'C'
		TCsETfIELD(cTab,aFields[nX, MODEL_FIELD_IDFIELD],aFields[nX, 4],aFields[nX, 5],aFields[nX, 6])
	EndIf
NEXT
	
While (cTab)->(!EOF())
	aTmp	:= {}
	For nX := 1 To Len(aFields)
		xValue	:= &("('"+cTab+"')->" + aFields[nX, MODEL_FIELD_IDFIELD])
		aAdd(aTmp, xValue)
	Next nX

	aAdd(aRet, {Len(aRet) + 1, aTmp})
	(cTab)->(dbSkip())
EndDo

(cTab)->(DbCloseArea())

Return aRet


/*{Protheus.doc} RU09T03MPre
@author Artem Kostin
@since 05/16/2018
@version P12.1.20
@type function
@description Prevalidation function for the fields of master model F37.
*/
Static Function RU09T03MPre(oModelF37 as Object, cAction as Character, cField as Character, xValue)
Local lRet := .T.

// If user changes Inclusion Date.
If ((cAction == "SETVALUE") .and. (cField == "F37_RDATE"))
	If (xValue /*F37_RDATE*/ < oModelF37:GetValue("F37_PDATE"))
		lRet := .F.
		Help("",1,"RU09T03MPre01",,STR0041,1,0)
	EndIf
EndIf

Return(lRet)
// The end of the Static Function RU09T03MPre



/*{Protheus.doc} RU09T03MPost
@author Artem Kostin
@since 05/16/2018
@version P12.1.20
@type function
@description Prevalidation function for the fields of master model F37.
*/
Static Function RU09T03MPost(oModelF37 as Object)
Local lRet := .T.

// Inclusion Date must be earlier than Print Date.
If (oModelF37:GetValue("F37_RDATE") < oModelF37:GetValue("F37_PDATE"))
	lRet := .F.
	Help("",1,"RU09T03MPost01",,STR0041,1,0)
EndIf

Return(lRet)
// The end of the Static Function RU09T03MPost



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T03ACI
Function that add more purchase invoice
@author alexandra.menyashina	
@since 22/01/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T03ACI()
Local aSize as Array
Local aStrusf1 as Array
Local nX as numeric
Local cSeria as character
Local cInvdoc as character
Local cSupplier as character
Local cBranch as character
Local dPdate as date

private oMoreDlg as object
private oBrowsePut as object
Private oTempTable 	as Object
Private cMBTempTbl 	as character
Private cMark		as character
Private aFields as Array
Private aRotina as Array

/*download current oModel*/
oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel	:= FwLoadModel("RU09T03")
EndIf

oModel:Activate()
oModelF37	:= oModel:GetModel("F37master")
cSeria	:= oModelF37:GetValue("F37_INVSER")
cInvdoc	:= oModelF37:GetValue("F37_INVDOC")
cSupplier	:= oModelF37:GetValue("F37_FORNEC")
cBranch	:= oModelF37:GetValue("F37_BRANCH")
dPdate	:= oModelF37:GetValue("F37_PDATE")
dFirst	:= oModelF37:GetValue("F37_PDATE")
dLast	:= oModelF37:GetValue("F37_PDATE")
dCurrent	:= oModelF37:GetValue("F37_PDATE")

aSize	:= MsAdvSize()
nX := 0
aStrusf1	:= {}
aColumns 	:= {}

// Create temporary table
MyCreaTRB(cSeria, cInvdoc, cSupplier, cBranch)

aAdd(aStrusf1, {"F1_SERIE"		,STR0023, PesqPict("SF1","F1_SERIE")})//"Seria"
aAdd(aStrusf1, {"F1_DOC"		,STR0024, PesqPict("SF1","F1_DOC")})//"Document"
aAdd(aStrusf1, {"F1_DTDIGIT"	,STR0029, PesqPict("SF1","F1_DTDIGIT")})//"Typing Date"
aAdd(aStrusf1, {"F1_EMISSAO"	,STR0025, PesqPict("SF1","F1_EMISSAO")})//"Com Inv Issue Date"
aAdd(aStrusf1, {"F1_FORNECE"	,STR0026, PesqPict("SF1","F1_FORNECE")})//"Customer"
aAdd(aStrusf1, {"F1_LOJA"		,STR0027, PesqPict("SF1","F1_LOJA")})//"Name"
aAdd(aStrusf1, {"F1_VALBRUT"	,STR0028, PesqPict("SF1","F1_VALBRUT")})//"Invoice Gross Value"

For nX := 1 TO Len(aStrusf1)
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData(&("{||"+aStrusf1[nX][1]+"}"))
	aColumns[Len(aColumns)]:SetTitle(aStrusf1[nX][2]) 
	aColumns[Len(aColumns)]:SetSize(TamSx3(aStrusf1[nX][1])[1]) 
	aColumns[Len(aColumns)]:SetDecimal(TamSx3(aStrusf1[nX][1])[2])
	aColumns[Len(aColumns)]:SetPicture(aStrusf1[nX][3]) 
Next nX

oMoreDlg := MsDialog():New(aSize[7], aSize[2], aSize[6], aSize[5], STR0015, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.)

// Browser with checkpoints.
oBrowsePut := FWMarkBrowse():New()
oBrowsePut:SetFieldMark("F1_OK")
oBrowsePut:SetOwner(oMoreDlg)
oBrowsePut:SetAlias(cMBTempTbl)
// Resets global aRotina.
aRotina	 := RU09T03Men()
oBrowsePut:SetMenuDef("RU09T03Men")
oBrowsePut:SetColumns(aColumns)
oBrowsePut:bAllMark := {||MarkAll(oBrowsePut, cMBTempTbl)}
oBrowsePut:DisableReport()
oBrowsePut:Activate()

cMark := oBrowsePut:Mark()

oMoreDlg:Activate(,,,.T.,,,)

aRotina	 := MenuDef() // Restore aRotina back

oTempTable:Delete()
Return()


/*{Protheus.doc} RU06D10
@author Alexander Ivanov
@since 09/20/2019
@version P12.1.27
@return
@type function
@description Appends array with subarray of field name, type (can be overridden by arg ?3), width and precision
*/
Static Function RU09T03002_AppendFields(aList as Array, cFieldName as Character, cType as Character)
	Local aField as Array
	Local nWidth as Numeric
	Local nDigits as Numeric

	Default cType := GetSX3Cache(cFieldName, "X3_TIPO")

	nWidth := GetSX3Cache(cFieldName, "X3_TAMANHO")
	nDigits := GetSX3Cache(cFieldName, "X3_DECIMAL")
	aField := {cFieldName, cType, nWidth, nDigits}
	aAdd(aList, aField)
Return


/*/{Protheus.doc} MyCreaTRB
Create temporary table and insert data into it
@param		None
@return		None
@author alexandra.menyashina
@since 16/01/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function MyCreaTRB(cSeries, cDoc, cFornec, cLoja)
	Local oModel as Object
	Local oModelSF1 as Object
	Local aIndex as Array
	Local nI as Numeric
	Local cQueryStart as Character
	Local cQuery as Character

	oModel  := FwModelActive()		
	If ValType(oModel) <> 'O'
		oModel	:= FwLoadModel("RU09T03")
	EndIf

	oModelSF1 := oModel:GetModel("SF1detail")
	oModelF37 := oModel:GetModel("F37master")

	nMoeda := oModelF37:GetValue("F37_MOEDA")
	cConUni := oModelF37:GetValue("F37_CONUNI")

	// The structure of columns for the MarkBrowse
	aFields := {}
	aAdd(aFields, {"F1_OK", "C", 1,00})
	RU09T03002_AppendFields(aFields, "F1_FILIAL")
	RU09T03002_AppendFields(aFields, "F1_SERIE")
	RU09T03002_AppendFields(aFields, "F1_DOC")
	RU09T03002_AppendFields(aFields, "F1_FORNECE")
	RU09T03002_AppendFields(aFields, "F1_LOJA")
	RU09T03002_AppendFields(aFields, "F1_EMISSAO")
	RU09T03002_AppendFields(aFields, "F1_DTDIGIT")
	RU09T03002_AppendFields(aFields, "F1_BASIMP1")
	RU09T03002_AppendFields(aFields, "F1_VALIMP1")
	RU09T03002_AppendFields(aFields, "F1_VALBRUT")

	aIndex := {}
	For nI := 2 to Len(aFields) // From F1_FILIAL to F1_EMISSAO according to the aFields
		aAdd(aIndex, aFields[nI][1])
	Next nI

	// Creates temporary table
	cMBTempTbl := CriaTrab(,.F.)
	oTempTable := FWTemporaryTable():New(cMBTempTbl)

	oTemptable:SetFields(aFields)
	oTempTable:AddIndex(cMBTempTbl + "1", aIndex)
	oTempTable:Create()
	cMBTempTbl := oTempTable:GetAlias()

	cQueryStart := " INSERT INTO " + oTempTable:GetRealName()
	cQueryStart += " (F1_OK, F1_FILIAL, F1_SERIE, F1_DOC, F1_FORNECE, F1_LOJA,"
	cQueryStart += " F1_EMISSAO, F1_DTDIGIT, F1_BASIMP1, F1_VALIMP1, F1_VALBRUT) "

	cQuery := "SELECT '0' F1_OK"

	For nI := 2 to Len(aFields)
		cQuery += " ," + aFields[nI][1]
	Next nI

	cQuery += " FROM " + RetSQLName("SF1")
	cQuery += " WHERE F1_FILIAL ='" +  xfilial("SF1")  + "'"
	cQuery += " AND F1_FORNECE ='" + cFornec + "'"
	cQuery += " AND F1_LOJA ='" + cLoja + "'"
	cQuery += " AND F1_CONUNI = '" + oModelF37:GetValue("F37_CONUNI") + "'"
	cQuery += " AND F1_MOEDA = " + Str(oModelF37:GetValue("F37_MOEDA")) + ""
	cQuery += " AND F1_STATUSR IN (' ','1') AND NOT ("

	For nI := 1 to oModelSF1:Length()
		oModelSF1:GoLine(nI)
		cQuery += " (F1_DOC ='" + oModelSF1:GetValue("F1_DOC") + "'"
		cQuery += " AND F1_EMISSAO ='" + DToS(oModelSF1:GetValue("F1_EMISSAO")) + "'"
		cQuery += " AND F1_SERIE ='" + oModelSF1:GetValue("F1_SERIE") + "') OR"
	Next nI

	cQuery := SubStr(cQuery, 1, Len(cQuery)-2)
	cQuery += ") AND D_E_L_E_T_ =' '"
	cQuery += " ORDER BY"

	For nI := 1 to Len(aIndex)
		cQuery += " " + aIndex[nI] + ","
	Next nI

	cQuery := Left(cQuery, Len(cQuery)-1) 
	cQuery := cQueryStart + ChangeQuery(cQuery)
	
	TCSqlExec(cQuery)
	DbSelectArea(cMBTempTbl)
	(cMBTempTbl)->(DbGotop())
	
Return(.T.)



//-----------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Mark all records
@param		oBrowsePut - Object
			cMBTempTbl - Alias markbrowse
@author alexandra.menyashina
@since 16/01/2018
@version P12.1.20
@type function
@project	MA3
/*/
//-----------------------------------------------------------------------
static function MarkAll(oBrowsePut as Object, cMBTempTbl as Char)
Local nRecOri 	as Numeric

nRecOri	:= (cMBTempTbl)->(RecNo())

dbSelectArea(cMBTempTbl)
(cMBTempTbl)->(DbGoTop())
Do while !(cMBTempTbl)->(Eof())
	RecLock(cMBTempTbl, .F.)
	If !Empty((cMBTempTbl)->F1_OK)
		(cMBTempTbl)->F1_OK := ''
	Else
		(cMBTempTbl)->F1_OK := cMark
	EndIf
	MsUnlock()

	(cMBTempTbl)->(DbSkip())
EndDo

(cMBTempTbl)->(DbGoTo(nRecOri))

oBrowsePut:oBrowse:Refresh(.T.)
Return(.T.)



/*/{Protheus.doc} RU09T03Men

Menu for MarkBrowse.
@param	oModel	
@author alexandra.menyashina
@since 17/01/2018
@version P12.1.20
@type function
@project	MA3
/*/
static Function RU09T03Men()
Local aRet as Array
aRet := {{STR0003, "RU09T03PIn()", 0, 2, 0, Nil},; //"View"
		{STR0001, "RU09T03Run()", 0, 4, 0, Nil},; //"Run "
		{STR0036, "RU09T03Che()", 0, 10/*4*/, 0, Nil}} //"Check interval "		
Return aRet



/*/{Protheus.doc} RU09T03Run
creation new VAT Invoice with checked Commertial Invoice
@param	oModel	
@author alexandra.menyashina
@since 17/01/2018
@version P12.1.20
@type function
@project	MA3
/*/
Function RU09T03Run()
Local lRet := .T.
// Working areas.
Local aArea as Array
Local aAreaSF1 as Array
Local aAreaSD1 as Array
// Submodels
Local oModelF37 as object
Local oModelSF1 as object
// Numbering lines in the grid.
Local nItemF as Numeric
Local lCanInsertLine as Logical
// SQL select
Local cInvDoc As Character
Local cInvSer As Character
// Variables for SQL requests.
Local cQuery as Character
Local cQueryFilter as Character
Local cTabSD1 as Character

cQuery := ""
cQueryFilter := ""

aArea := GetArea()
aAreaSF1 := SF1->(GetArea())
aAreaSD1 := SD1->(GetArea())

/*download current oModel*/
oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel := FwLoadModel("RU09T03")
EndIf

oModel:Activate()
oModelF37 := oModel:GetModel("F37master")
oModelSF1 := oModel:GetModel("SF1detail")

dPrintDate	:= oModelF37:GetValue("F37_PDATE")
cInvDoc	:= oModelF37:GetValue("F37_INVDOC")
cInvSer	:= oModelF37:GetValue("F37_INVSER")

oModel:GetModel("SF1detail"):SetNoInsertLine(.F.)
// Cycle over all Commercial Invoices marked by user.
(cMBTempTbl)->(DbGoTop())
While !((cMBTempTbl)->(Eof()))
	If ((cMBTempTbl)->F1_OK == cMark)
		cQueryFilter += " (D1_FILIAL = '" + xFilial("SD1") + "'"
		cQueryFilter += " AND D1_DOC = '" + (cMBTempTbl)->F1_DOC + "'"
		cQueryFilter += " AND D1_SERIE = '" + (cMBTempTbl)->F1_SERIE + "'"
		cQueryFilter += " AND D1_FORNECE = '" + (cMBTempTbl)->F1_FORNECE + "'"
		cQueryFilter += " AND D1_LOJA = '" + (cMBTempTbl)->F1_LOJA + "')"
		cQueryFilter += " OR"

		nItemF := oModelSF1:AddLine()
		oModelSF1:LoadValue("F1_SERIE", (cMBTempTbl)->F1_SERIE)
		oModelSF1:LoadValue("F1_DOC", (cMBTempTbl)->F1_DOC)
		oModelSF1:LoadValue("F1_FORNECE", (cMBTempTbl)->F1_FORNECE)
		oModelSF1:LoadValue("F1_LOJA", (cMBTempTbl)->F1_LOJA)
		oModelSF1:LoadValue("F1_DTDIGIT", (cMBTempTbl)->F1_DTDIGIT)
		oModelSF1:LoadValue("F1_EMISSAO", (cMBTempTbl)->F1_EMISSAO)
		oModelSF1:LoadValue("F1_BASIMP1", (cMBTempTbl)->F1_BASIMP1)
		oModelSF1:LoadValue("F1_VALIMP1", (cMBTempTbl)->F1_VALIMP1)
		oModelSF1:LoadValue("F1_VALBRUT", (cMBTempTbl)->F1_VALBRUT)
		
		//If (dPrintDate < SToD((cMBTempTbl)->F1_EMISSAO))
		If (dPrintDate < (cMBTempTbl)->F1_EMISSAO)
			dPrintDate	:= (cMBTempTbl)->F1_EMISSAO
			cInvDoc := (cMBTempTbl)->F1_DOC
			cInvSer := (cMBTempTbl)->F1_SERIE
		EndIf
	EndIf
	(cMBTempTbl)->(DbSkip())
EndDo
oModel:GetModel("SF1detail"):SetNoInsertLine(.T.)

// No lines are seleted by user.
If Empty(cQueryFilter)
	lRet := .F.
	Help("",1,"RU09T03Run01",,STR0038,1,0)
Else
	// Gets rid of "or" in the end
	cQueryFilter := Left(cQueryFilter, Len(cQueryFilter)-2)
EndIf

If lRet
	cQuery := " SELECT * FROM " + RetSQLName("SD1")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND D1_TIPO = 'N' AND ("
	cQuery += cQueryFilter
	cQuery += " ) ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_TIPO, D1_ITEM"
	cTabSD1 := MPSysOpenQuery(ChangeQuery(cQuery))

	// Iterates all over the details returned by select.
	lCanInsertLine := oModel:GetModel("F38detail"):CanInsertLine()
	oModel:GetModel("F38detail"):SetNoInsertLine(.F.)
	FillF38Table(oModel, cTabSD1, .T.)
	oModel:GetModel("F38detail"):SetNoInsertLine(!lCanInsertLine)

	If (oModelF37:GetValue("F37_PDATE") < dPrintDate)
		oModelF37:LoadValue("F37_PDATE", dPrintDate)
		oModelF37:LoadValue("F37_INVDOC", cInvDoc)
		oModelF37:LoadValue("F37_INVSER", cInvSer)
	EndIf

	oModelSF1:GoLine(1)
	oModel:GetModel("F38detail"):GoLine(1)

	RfrshView()

	oMoreDlg:End()

	CloseTempTable(cTabSD1)
	// cMBTempTbl will be clodes outside.
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
Return(lRet)



/*{Protheus.doc} RU09T03PIn
@author Alexandra Menyashina
@since 01/02/2018
@version P12.1.20
@param None
@return nil
@type function
@description open View of checked Commertial Invoice
*/
Function RU09T03PIn(oModel as Object)
// Working areas
Local aArea as Array
Local aAreaSF1 as Array
Local aAreaSD1 as Array
// Model objects
Local oModelSF1 as Object
// Keys for dbSeek()
Local cKeySF1 as Character
// Overwriting existing buttons.
Private aRotina as Array

Default oModel := FWLoadModel("RU09T03")

aRotina	:=	{{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil}}

aArea := GetArea()
aAreaSF1 := SF1->(GetArea())
aAreaSD1 := SD1->(GetArea())

DbSelectArea("SF1")
SF1->(DbSetOrder(1))

If (Type("oBrowsePut") == "O")
	nLine := oBrowsePut:At()
	(cMBTempTbl)->(DbGoTo(nLine))
	cKeySF1 := xFilial("SF1") + (cMBTempTbl)->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
Else
	oModelSF1 := oModel:GetModel("SF1detail")
	cKeySF1 := xFilial('SF1') + oModelSF1:GetValue("F1_DOC")+ oModelSF1:GetValue("F1_SERIE")+ oModelSF1:GetValue("F1_FORNECE") + oModelSF1:GetValue("F1_LOJA")
EndIf

If (SF1->(DbSeek(cKeySF1)))
	CtbDocEnt()	//open View of SF1/SD1
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
Return(Nil)


/*{Protheus.doc} RU09T03Che
@author Alexandra Menyashina
@since 16/02/2018
@version P12.1.20
@param None
@return bool
@type function
@description Checking time interval 
*/
Function RU09T03Che()
Local nLine as Numeric
// Submodels
Local oModelF37 as Object
Local oModelSF1 as Object
// The dates of Commercial Invoices
Local dPdate as Date
Local dFirst as Date
Local dLast as Date
Local dCurrent as Date

/*download current oModel*/
oModel := FwModelActive()		
If (ValType(oModel) != "O")
	oModel := FwLoadModel("RU09T03")
EndIf

oModelF37 := oModel:GetModel("F37master")
oModelSF1 := oModel:GetModel("SF1detail")

dPdate	:= oModelF37:GetValue("F37_PDATE")
dFirst	:= oModelF37:GetValue("F37_PDATE")
dLast	:= oModelF37:GetValue("F37_PDATE")
dCurrent:= oModelF37:GetValue("F37_PDATE")

For nLine := 1 to oModelSF1:Length()
	oModelSF1:GoLine(nLine)
	If !(oModelSF1:IsDeleted())
		dFirst := min(dFirst, oModelSF1:GetValue("F1_EMISSAO"))
		dLast := max(dLast, oModelSF1:GetValue("F1_EMISSAO"))	
	EndIf
Next nLine

(cMBTempTbl)->(DbGotop())
While !(cMBTempTbl)->(Eof())
	// If line is marked by user.
	If ((cMBTempTbl)->F1_OK == cMark)
		dCurrent := (cMBTempTbl)->F1_EMISSAO
		dFirst := min(dFirst, dCurrent)
		dLast := max(dLast, dCurrent)	
	EndIf
	
	(cMBTempTbl)->(DbSkip())
EndDo

If (dLast - dFirst) > 4
	Help("",1,STR0030,,STR0033 + DTOC(dFirst) + " - "+ DTOC(dLast) + STR0034,1,0)
ElseIf (abs(dLast - dPdate) > 4)
	Help("",1,STR0030,,STR0031 + DTOC(dLast) + STR0032 + " (" + DTOC(dPdate - 4) +" - "+ DTOC(dPdate + 4) + ")"  ,1,0)
ElseIf (abs(dFirst - dPdate) > 4)
	Help("",1,STR0030,,STR0031 + DTOC(dFirst) + STR0032 + " (" + DTOC(dPdate - 4) +" - "+ DTOC(dPdate + 4) + ")"  ,1,0)
Else
	Help("",1,STR0037,,STR0035,1,0)
EndIf
Return(.T.)



//-----------------------------------------------------------------------
/*/{Protheus.doc} gravaBook
@author Artem Kostin
@since 02/26/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function gravaBook(oModel as Object)
Local lRet := .T.
// Model and submodels
Local oBook as Object
Local oModelF3B as Object
Local oModelF3C as Object

Local nOperation as Numeric
Local lCanInsertLine as Logical
Local lCanUpdateLine as Logical

// SQL query and temporary table
Local cQuery := ""
Local cTab := ""
Local cTabPBook := ""

Local nRecValTotal	As Numeric
Local nLine			As Numeric

Local cRealDate := DtoS(oModel:GetModel("F37master"):GetValue("F37_RDATE"))
Local dPrintDate := oModel:GetModel("F37master"):GetValue("F37_PDATE")
Local cPrintMonth := SubStr(DtoS(dPrintDate), 5, 2)
Local dFinalDate as Date

Local aArea := GetArea()
Local aAreaF3B := F3B->(GetArea())
Local aAreaF3C := F3C->(GetArea())

nRecValTotal	:= 0
nLine			:= 0

DbSelectArea("F3B")
F3B->(DbSetOrder(1))

DbSelectArea("F3C")
F3C->(DbSetOrder(2))

// Select the book from the database, where Purchase VAT Invoice can be put. 
cQuery := " SELECT T0.F3B_BOOKEY"
cQuery += " FROM " + RetSQLName("F3B") + " AS T0"
cQuery += " WHERE T0.F3B_FILIAL = '" + xFilial("F3B") + "'"
If (cPrintMonth $ "03|06|09|12") .and. (StoD(cRealDate) <= DaySum(LastDay(dPrintDate), EXTRA_DAYS_AFTER_TAX_PERIOD))
	cQuery += " AND T0.F3B_FINAL >= '" + DtoS(dPrintDate) + "'"
	cQuery += " AND T0.F3B_INIT <= '" + DtoS(dPrintDate) + "'"
Else
	cQuery += " AND T0.F3B_FINAL >= '" + cRealDate + "'"
EndIf
cQuery += " AND T0.F3B_INIT <= '" + cRealDate + "'"
cQuery += " AND T0.F3B_STATUS = '1'"
cQuery += " AND T0.F3B_AUTO = '1'"
cQuery += " AND T0.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY T0.F3B_BOOKEY"
cTabPBook := MPSysOpenQuery(ChangeQuery(cQuery))

// If query result is not empty == Purchases Book already exists.
(cTabPBook)->(DBGoTop())
If !(cTabPBook)->(Eof())
	If F3B->(DbSeek(xFilial("F3B") + (cTabPBook)->F3B_BOOKEY))
		nOperation := MODEL_OPERATION_UPDATE
	Else
		lRet := .F.
		Help("",1,"gravaBook03",,STR0943,1,0)
	EndIf
Else
	nOperation := MODEL_OPERATION_INSERT
EndIf
(cTabPBook)->(DbCloseArea())

// Loads Purchases Book model.
oBook := FWLoadModel("RU09T05")
oBook:SetOperation(nOperation)
oBook:Activate()

oModelF3B := oBook:GetModel("F3BMASTER")
oModelF3C := oBook:GetModel("F3CDETAIL")

// If Automatic Book doesn't exist, we will create it.
If nOperation == MODEL_OPERATION_INSERT
	oModelF3B:LoadValue("F3B_FILIAL", xFilial("F3B"))
	oModelF3B:LoadValue("F3B_CODE", Space(TamSX3("F3B_CODE")[1]))
	oModelF3B:LoadValue("F3B_INIT", SToD(SubStr(cRealDate, 1, 6) + "01"))
	oModelF3B:LoadValue("F3B_FINAL", LastDay(SToD(cRealDate)))
	oModelF3B:LoadValue("F3B_STATUS", "1")
	oModelF3B:LoadValue("F3B_AUTO", "1")
EndIf

dFinalDate := oModelF3B:GetValue("F3B_FINAL")
// Selects data to fill the Automatic Book.
cQuery := RU09T05_01getSQLquery(oModelF3C)
cQuery += " AND T0.F32_KEY = '" + oModel:GetModel("F37master"):GetValue("F37_KEY") + "'"
cQuery += " AND T0.F32_OPBS > 0"
If (cPrintMonth $ "03|06|09|12")
	cQuery += " AND T0.F32_PDATE <= '" + DtoS(dFinalDate) + "'"
	cQuery += " AND T0.F32_RDATE <= '" + DtoS(DaySum(LastDay(dFinalDate), EXTRA_DAYS_AFTER_TAX_PERIOD)) + "'"   
Else
	cQuery += " AND T0.F32_RDATE <= '" + DtoS(dFinalDate) + "'"    
EndIf
cQuery += RU09T05_02getSQLorderby()
cTab := MPSysOpenQuery(cQuery)

// Iterates through the open balances of this particular Purchases VAT Invoice.
lCanUpdateLine := oModelF3C:CanUpdateLine()
lCanInsertLine := oModelF3C:CanInsertLine()
oModelF3C:SetNoUpdateLine(.F.)
oModelF3C:SetNoInsertLine(.F.)
(cTab)->(DBGoTop())
lRet := lRet .and. RU09T05F3C(oModelF3C, oModelF3B, cTab, 100.00)
oModelF3C:SetNoUpdateLine(!lCanUpdateLine)
oModelF3C:SetNoInsertLine(!lCanInsertLine)
CloseTempTable(cTab)

For nLine := 1 to oModelF3C:Length(.F.)
	oModelF3C:GoLine(nLine)
	// Calculates total. Sums not deleted lines and not empty values.
	If (!oModelF3C:IsDeleted()) .and. (!Empty(oModelF3C:GetValue("F3C_VALUE")) .or. !oModelF3C:GetValue("F3C_VALUE") == 0)
		nRecValTotal += oModelF3C:GetValue("F3C_VALUE")
	EndIf
Next nLine

oModelF3B:LoadValue("F3B_TOTAL", nRecValTotal)

// If the validation of the model is not successful.
If lRet .and. !oBook:VldData()
	lRet := .F.
	Help("",1,"gravaBook01",,STR0941,1,0)
	
// If commit not is successful.
ElseIf lRet .and. !oBook:CommitData()
	lRet := .F.
	Help("",1,"gravaBook02",,STR0942,1,0)
EndIf
oBook:DeActivate()

// TODO: here should be an accounting postings update.

RestArea(aAreaF3C)
RestArea(aAreaF3B)
RestArea(aArea)
Return(lRet)
// The end of the Static Function gravaBook



//-----------------------------------------------------------------------
/*/{Protheus.doc} FillF38Table
Fills the grids F38 and SF1. Renews the fields F37.
@author Artem Kostin
@since 04/06/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function FillF38Table(oModel as Object, cTabSD1 as Character, lAddLine as Logical)
Local lRet := .T.
// Submodels
Local oModelF37 as Object
Local oModelF38 as Object
// Sums of different values.
Local nVatBs as Numeric // VAT Base total
Local nValGr as Numeric // Gross total
Local nVatVl as Numeric // VAT Value total
Local nVatBs1 as Numeric // VAT Base in rubles
Local nVatVl1 as Numeric // VAT Value in rubles
Local nVal as Numeric // Total Value with all taxes, discounta and etc.
// Concatenation of Operational VAT Codes
Local cCFExt as Character
// Currency number and type of conventional units.
Local nMoeda as Numeric
Local cConUni as Character

Local nItem as Numeric

Default oModel := FWLoadModel("RU09T03")
Default cTabSD1 := ""
Default lAddLine := .F.

If (ValType(oModel) != "O") .or. (oModel:GetId() != "RU09T03")
	lRet := .F.
	Help("",1,"FillF38Table01",,STR0910,1,0) // No model is recieved as argument
EndIf

If (Empty(cTabSD1))
	lRet := .F.
	Help("",1,"FillF38Table02",,STR0945,1,0) // No temporary table is recieved as argument
EndIf

If (lRet)
	oModelF37 := oModel:GetModel("F37master")
	oModelF38 := oModel:GetModel("F38detail")

	nMoeda := oModelF37:GetValue("F37_MOEDA")
	cConUni := oModelF37:GetValue("F37_CONUNI")

	If (lAddLine)
		nVatBs := oModelF37:GetValue("F37_VATBS")
		nValGr := oModelF37:GetValue("F37_VALGR") 
		nVatVl := oModelF37:GetValue("F37_VATVL")
		nVatBs1 := oModelF37:GetValue("F37_VATBS1")
		nVatVl1 := oModelF37:GetValue("F37_VATVL1")
		nVal   := oModelF37:GetValue("F37_VALUE")
		cCFExt := AllTrim(oModelF37:GetValue("F37_VATCD2"))
	Else
		nVatBs := 0
		nValGr := 0 
		nVatVl := 0
		nVatBs1 := 0
		nVatVl1 := 0
		nVal   := 0
		cCFExt := ""
	EndIf

	DbSelectArea("F31")
	F31->(DbSetOrder(1))

	(cTabSD1)->(DbGoTop())
	While ((cTabSD1)->(!Eof()))
		If lAddLine
			nItem := oModelF38:AddLine()
		Else
			nItem := 1
			lAddLine := .T.
		EndIf
		SD1->(dbGoTo((cTabSD1)->R_E_C_N_O_))
		lRet := lRet .and. oModelF38:LoadValue("F38_DOCKEY", (cTabSD1)->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM + D1_TIPO))
		lRet := lRet .and. oModelF38:LoadValue("F38_ITEM", StrZero(nItem, TamSX3("F38_ITEM")[1]))
		lRet := lRet .and. oModelF38:LoadValue("F38_ITMCOD", Posicione("SB1", 1, xFilial("SB1") + (cTabSD1)->D1_COD, "B1_COD"))	// Prod./Service Description
		lRet := lRet .and. oModelF38:LoadValue("F38_ITMDES", SubStr(Posicione("SB1", 1, xFilial("SB1") + (cTabSD1)->D1_COD, "B1_DESC"),1,TamSX3("F38_ITMDES")[1]))
		lRet := lRet .and. oModelF38:LoadValue("F38_DESC", Iif(!Empty(SD1->D1_FDESC), SD1->D1_FDESC, oModelF38:GetValue("F38_ITMDES")))
		lRet := lRet .and. oModelF38:LoadValue("F38_UM", AllTrim((cTabSD1)->D1_UM))
		lRet := lRet .and. oModelF38:LoadValue("F38_QUANT", (cTabSD1)->D1_QUANT) 
		If (cConUni == "1") // Purchases Commercial Invoice in conventional units
			lRet := lRet .and. oModelF38:LoadValue("F38_VUNIT", Round((cTabSD1)->D1_BSIMP1M/(cTabSD1)->D1_QUANT, 2)) // Unit Value
			lRet := lRet .and. oModelF38:LoadValue("F38_VALUE", (cTabSD1)->D1_BSIMP1M) // Total Value
			lRet := lRet .and. oModelF38:LoadValue("F38_VATBS", (cTabSD1)->D1_BSIMP1M) // VAT Base
			lRet := lRet .and. oModelF38:LoadValue("F38_VATVL", (cTabSD1)->D1_VLIMP1M) // VAT Value
			lRet := lRet .and. oModelF38:LoadValue("F38_VALGR", (cTabSD1)->D1_VLBRUTM) // Gross Total
		Else
			lRet := lRet .and. oModelF38:LoadValue("F38_VUNIT", Round((cTabSD1)->D1_BASIMP1/(cTabSD1)->D1_QUANT, 2)) // Unit Value
			lRet := lRet .and. oModelF38:LoadValue("F38_VALUE", (cTabSD1)->D1_BASIMP1) // Total Value
			lRet := lRet .and. oModelF38:LoadValue("F38_VATBS", (cTabSD1)->D1_BASIMP1) // VAT Base
			lRet := lRet .and. oModelF38:LoadValue("F38_VATVL", (cTabSD1)->D1_VALIMP1) // VAT Value
			lRet := lRet .and. oModelF38:LoadValue("F38_VALGR", (cTabSD1)->D1_VALBRUT) // Gross Total
		EndIf
		lRet := lRet .and. oModelF38:LoadValue("F38_VATBS1", (cTabSD1)->D1_BSIMP1M) // VAT Base in Currency 1
		lRet := lRet .and. oModelF38:LoadValue("F38_VATVL1", (cTabSD1)->D1_VLIMP1M) // VAT Value in Currency 1
		lRet := lRet .and. oModelF38:LoadValue("F38_VATRT", (cTabSD1)->D1_ALQIMP1)
		lRet := lRet .and. oModelF38:LoadValue("F38_VATCOD", (cTabSD1)->D1_CF)
		lRet := lRet .and. oModelF38:LoadValue("F38_INVSER", (cTabSD1)->D1_SERIE)
		lRet := lRet .and. oModelF38:LoadValue("F38_INVDOC", (cTabSD1)->D1_DOC)
		lRet := lRet .and. oModelF38:LoadValue("F38_INVDT", Stod((cTabSD1)->D1_DTDIGIT))
		lRet := lRet .and. oModelF38:LoadValue("F38_ITDATE", Stod((cTabSD1)->D1_EMISSAO))	
		lRet := lRet .and. oModelF38:LoadValue("F38_INVIT", (cTabSD1)->D1_ITEM)
		lRet := lRet .and. oModelF38:LoadValue("F38_ORIGIN", Posicione("SB8", 2, xFilial("SB8") + (cTabSD1)->(D1_NUMLOTE+D1_LOTECTL+D1_COD+D1_LOCAL), "B8_ORIGEM"))	// Country Origin
		lRet := lRet .and. oModelF38:LoadValue("F38_NUMDES", SubStr(Posicione("SB8", 2, xFilial("SB8") + (cTabSD1)->(D1_NUMLOTE+D1_LOTECTL+D1_COD+D1_LOCAL), "B8_NUMDESP"), 1, TamSX3("F38_NUMDES")[1]))	// Customs Number
		
		If (F31->(DbSeek(xFilial("F31") + (cTabSD1)->D1_CF)))
			lRet := lRet .and. oModelF38:LoadValue("F38_VATCD2", F31->F31_OPCODE)
			If !Empty(AllTrim(F31->F31_OPCODE)) .and. !(F31->F31_OPCODE $ cCFExt)
				cCFExt += AllTrim(F31->F31_OPCODE) + ";"
			EndIf
		EndIf

		// Sums totals for the Inflow Invoice header.
		If (cConUni == "1") // Purchases Commercial Invoice in conventional units
			nVal   += (cTabSD1)->D1_BSIMP1M
			nVatBs += (cTabSD1)->D1_BSIMP1M
			nVatVl += (cTabSD1)->D1_VLIMP1M
			nValGr += (cTabSD1)->D1_VLBRUTM
		Else
			nVal   += (cTabSD1)->D1_BASIMP1
			nVatBs += (cTabSD1)->D1_BASIMP1
			nVatVl += (cTabSD1)->D1_VALIMP1
			nValGr += (cTabSD1)->D1_VALBRUT
		EndIf
		nVatBs1 += (cTabSD1)->D1_BSIMP1M
		nVatVl1 += (cTabSD1)->D1_VLIMP1M
		
		(cTabSD1)->(DbSkip())
	EndDo

	If !Empty(AllTrim(cCFExt))
		cCFExt := SubStr(cCFExt, 1, Len(cCFExt)-1)
	EndIf

	If !lRet
		Help("",1,"FillF38Table03",,STR0927,1,0)
	EndIf

	lRet := lRet .and. oModelF37:LoadValue("F37_VATVL", nVatVl)	// VAT Value
	lRet := lRet .and. oModelF37:LoadValue("F37_VALGR", nValGr)	// Gross Total
	lRet := lRet .and. oModelF37:LoadValue("F37_VATBS", nVatBs)	// VAT Base
	lRet := lRet .and. oModelF37:LoadValue("F37_VATVL1", nVatVl1)	// Gross Total in rubles
	lRet := lRet .and. oModelF37:LoadValue("F37_VATBS1", nVatBs1)	// VAT Base in rubles
	lRet := lRet .and. oModelF37:LoadValue("F37_VALUE", nVal)	// Total Value
	lRet := lRet .and. oModelF37:LoadValue("F37_VATCD2", cCFExt)	// External VAT Codes
	If !lRet
		Help("",1,"FillF38Table04",,STR0927,1,0)
	EndIf
EndIf // lRet
Return(lRet)



/*/{Protheus.doc} RU09T03Cp
@author artem.kostin
@since 12/19/2018
@version P12.1.21
@type function
/*/
Function RU09T03Cp()
Local lRet := .T.
Local oModel 	as Object
Local aAreaF37  as Array

aAreaF37	:= F37->(GetArea())
If (F37->F37_TYPE == "2")
	oModel := FWLoadModel("RU09T03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate(.T.)

	oModel:GetModel("F37master"):LoadValue("F37_TYPE", "2")
	oModel:GetModel("F37master"):LoadValue("F37_FORNEC", F37->F37_FORNEC)
	oModel:GetModel("F37master"):LoadValue("F37_BRANCH", F37->F37_BRANCH)
	oModel:GetModel("F37master"):LoadValue("F37_DOC", "")
	oModel:GetModel("F37master"):LoadValue("F37_TDATE ", dDataBase)
	oModel:GetModel("F37master"):LoadValue("F37_DTLA", StoD(""))

	FWExecView( STR0046, "RU09T03", MODEL_OPERATION_INSERT, /*oDlg*/, {|| .T. },  , /*nPercReducao*/, , /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,oModel)
	oModel:DeActivate()
Else
	HELP(' ',1,"RU09T03Cp:01" ,,STR0049,2,0,,,,,,/* solution */)
EndIf

RestArea(aAreaF37)
Return(lRet)



/*/{Protheus.doc} RU09T03T01_F38_VALUE_F38_VATBS
@author artem.kostin
@since 01/30/2019
@version P12.1.23
@type function recalculates VAT Base after the value was changed
/*/
Function RU09T03T01_F38_VATBS()
Local aVATRate := RU09GetRate(FWFldGet("F38_VATCOD"))
Local nVATBase := Round(FWFldGet("F38_VALUE"), 2)
If (aVATRate[2] != 100)
	nVATBase = Round(FWFldGet("F38_VALUE") * 100 / aVATRate[2], 2)
EndIf
Return(nVATBase)