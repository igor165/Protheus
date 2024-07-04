#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'ru09t03.ch'
#include 'RU09XXX.ch'

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T06
Creates the main screen of Write-Off Documents.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T06()
Local oBrowse as Object
SetKey(VK_F12, {||AcessaPerg("RU09T06ACC",.T.)})
// Initalization of the tables, if they do not exist.
DbSelectArea("F3D")
DbSelectArea("F3E")

oBrowse := FWLoadBrw("RU09T06")
aRotina := MenuDef()
oBrowse:Activate()

Return(.T.)
// The end of the Function RU09T06()



//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Defines the browser of the Purchases VAT Books.
@author Artem Kostin
@since 26/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as Object

Local cBrowseFilter as Character
Local cVATKey as Character

Local cTab as Character
Local cQuery as Character

Private aRotina as Array

cTab := ""
cBrowseFilter := ""

oBrowse := FwMBrowse():New()

oBrowse:setAlias("F3D")
oBrowse:AddLegend("F3D_STATUS =='1'", "GREEN", "Open")
oBrowse:AddLegend("F3D_STATUS =='2'", "BLACK", "Blocked")
oBrowse:AddLegend("F3D_STATUS =='3'", "RED", "Closed")
oBrowse:setDescription(STR0935)
oBrowse:DisableDetails()

If IsInCallStack("RU09T03RUS")
    cVATKey := F37->F37_KEY
    
    cQuery := " SELECT DISTINCT T0.F3D_WRIKEY AS BOOK_KEY FROM " + RetSQLName("F3D") + " AS T0"
    cQuery += " JOIN " + RetSQLName("F3E") + " AS T1 ON ("
    cQuery += " T1.F3E_FILIAL = '" + xFilial("F3E") +"'"
    cQuery += " AND T1.F3E_KEY = '" + cVATKey + "'"
    cQuery += " AND T1.F3E_WRIKEY = T0.F3D_WRIKEY"
    cQuery += " )"
    cQuery += " WHERE T0.F3D_FILIAL = '" + xFilial("F3D") +"'"
    cQuery += " AND T0.D_E_L_E_T_ = ' '"
	cQuery += " AND T1.D_E_L_E_T_ = ' '"
    cTab := MPSysOpenQuery(ChangeQuery(cQuery))

    While !(cTab)->(Eof())
        cBrowseFilter += "(F3D_WRIKEY=='" + (cTab)->BOOK_KEY + "') .and. "
        (cTab)->(DbSkip())
    EndDo
    CloseTempTable(cTab)
    // Cuts " .and. " from the end of the line of the Purchases Write-Off Keys.
    If !Empty(cBrowseFilter)
        cBrowseFilter := SubStr(cBrowseFilter, 1, Len(cBrowseFilter)-7)
    Else
        cBrowseFilter := "F3D_WRIKEY=='" + Space(TamSX3("F3D_WRIKEY")[1]) + "'"
    EndIf

    oBrowse:setFilterDefault(cBrowseFilter)
EndIf

Return(oBrowse)



//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defines the menu to Write-Off Documents.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aButtons as Array

aButtons := {{STR0902, "FwExecView('" + STR0902 + "', 'RU09T06', " + STR(MODEL_OPERATION_VIEW) + ")", 0, 2, 0, Nil},;
		{STR0903, "FwExecView('" + STR0903 + "', 'RU09T06', " + STR(MODEL_OPERATION_INSERT) + ")", 0, 3, 0, Nil},;
		{STR0904, "FwExecView('" + STR0904 + "', 'RU09T06', " + STR(MODEL_OPERATION_UPDATE) + ")", 0, 4, 0, Nil},;
		{STR0905, "FwExecView('" + STR0905 + "', 'RU09T06', " + STR(MODEL_OPERATION_DELETE) + ")", 0, 5, 0, Nil},;
        {STR0054, "CTBC662", 0, 2, 0, Nil},; //"Track Posting"
        {STR0055,"RU09T06001_RETWRIOFF",0,7,0,Nil}}

Return(aButtons)
// The end of the Static Function MenuDef()



//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Creates the model of Write-Off Documents.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oModel as Object
Local oStructF3D as Object
Local oStructF3E as Object

oStructF3D := FWFormStruct(1, "F3D")
oStructF3E := FWFormStruct(1, "F3E")
oModel := MPFormModel():New("RU09T06", Nil, {|oModel| RU09T06MPost(oModel)}, {|oModel| ModelRec(oModel)})
oModel:setDescription(STR0935)

// This flag field plays role of the nonexistent method of the grid object ::IsChanged ? "*"-Yes : Nil-No
aAdd(oStructF3E:aFields, {"WrOBsDiff", "WriteOffBaseDiff", "F3E_WBSDIF", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
aAdd(oStructF3E:aFields, {"WrOVlDiff", "WriteOffValueDiff", "F3E_WVLDIF", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
aAdd(oStructF3E:aFields, {"OpVlDiff", "OpenValueDiff", "F3E_OPBSBU", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
aAdd(oStructF3E:aFields, {"OpVlDiff", "OpenValueDiff", "F3E_OPVLBU", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})

oModel:AddFields("F3DMASTER", Nil, oStructF3D, {|oModel, cAction, cField, xValue| RU09T06FPre(oModel, cAction, cField, xValue)})

oModel:AddGrid("F3EDETAIL",;
                "F3DMASTER",;
                oStructF3E,;
                {|oModel, nLinVld, cAction, cField, xValue, xOldValue| RU09T06DLPre(oModel, nLinVld, cAction, cField, xValue, xOldValue)},;
                /* bLinePost */,;
                /* bGridPre */,;
                /* bGridPost */)

oModel:getModel("F3DMASTER"):setDescription(STR0935)
oModel:getModel("F3EDETAIL"):setDescription(STR0936)
oModel:getModel("F3EDETAIL"):setOptional(.T.)

oModel:setRelation("F3EDETAIL", {{"F3E_FILIAL", "xFilial('F3E')"}, {"F3E_WRIKEY", "F3D_WRIKEY"}, {"F3E_CODE", "F3D_CODE"}}, F3E->(IndexKey(1)))
oModel:setPrimaryKey({"F3D_FILIAL", "F3D_WRIKEY"})
oModel:setActivate({|| RU09T06AAct(oModel)})

oModel:getModel("F3EDETAIL"):setUniqueLine({"F3E_FILIAL", "F3E_KEY","F3E_VATCOD","F3E_VATCD2"})
oModelEvent := RU09T06EventRUS():New()
oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)
Return(oModel)
// The end of the Static Function ModelDef()


//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Creates the view of Write-Off Documents.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStructF3D as Object
Local oStructF3E as Object

Local cCmpF3D as Character
Local cCmpF3E as Character
Local cCmpTotal as Character

// Defines which fields we don't need to show on the screen.
cCmpF3D := "F3D_WRIKEY;F3D_TOTAL "
cCmpF3E := "F3E_CODE  ;F3E_WRIKEY;F3E_KEY   ;F3E_ITEM  "
cCmpTotal := "F3D_TOTAL "

oModel := FwLoadModel("RU09T06")

oStructF3D := FWFormStruct(2, "F3D", {|x| !(AllTrim(x) $ cCmpF3D)})
oStructF3E := FWFormStruct(2, "F3E", {|x| !(AllTrim(x) $ cCmpF3E)})
oSturctTotal := FWFormStruct(2, "F3D", {|x| (AllTrim(x) $ cCmpTotal)})

If (INCLUI)
    // This field will be filled in while commiting and shown in other view cases.
    oStructF3D:RemoveField("F3D_CODE")
Else
    // User shouldn't have an option to change dates in saved write-off.
    oStructF3D:SetProperty("F3D_FINAL", MVC_VIEW_CANCHANGE, .F.)
EndIf

// If Write-Off is Blocked or Closed.
If (ALTERA) .and. ((F3D->F3D_STATUS == "2") .Or. (F3D->F3D_STATUS == "3"))
    oStructF3D:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
    oStructF3D:SetProperty('F3D_STATUS', MVC_VIEW_CANCHANGE, .T.)
EndIf

oStructF3E:SetProperty("F3E_DOC", MVC_VIEW_CANCHANGE, F3E_DOC_When())

oView := FWFormView():New()
oView:setModel(oModel)
oView:AddField("F3D_M", oStructF3D, "F3DMASTER")
oView:AddGrid("F3E_D", oStructF3E, "F3EDETAIL")
oView:AddField("F3D_T", oSturctTotal, "F3DMASTER")

oView:CreateHorizontalBox("HEADERBOX", 25)
oView:CreateHorizontalBox("ITEMBOX", 65)
oView:CreateHorizontalBox("TOTALBOX", 10)

oView:setOwnerView("F3D_M", "HEADERBOX")
oView:setOwnerView("F3E_D", "ITEMBOX")
oView:setOwnerView("F3D_T", "TOTALBOX")

// If Write-Off is opened and not automatic and operation is Insertion or Update.
If (INCLUI) .or. ((F3D->F3D_STATUS == "1") .and. ALTERA)
    oView:AddUserButton(STR0946, "", {|| RU09T06AInc(oModel)})
EndIf

oView:AddUserButton(STR0907, '', {|| RU09T06VAT(oModel)})
oView:AddUserButton(STR0908, '', {|| RU06VATInExp(oModel)})

oView:setCloseOnOk({|| .T.})
oView:setDescription(STR0935)

Return(oView)
// The end of the Static Function ViewDef()



//-----------------------------------------------------------------------
/*/{Protheus.doc} F3E_DOC_When
Function returns false, if key is not empty.
This function is used to prevent editing the Purchases VAT Invoice Document Number
after it has been filled once. Only line deletion is allowed for user.
@author Artem Kostin
@since 05/15/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function F3E_DOC_When()
Local lRet := .T.
Local oModel as Object

oModel := FWModelActive()
If (ValType(oModel) == "O") .and. (oModel:getId() == "RU09T06")
    lRet := Empty(oModel:GetModel("F3EDETAIL"):GetValue("F3E_KEY"))
EndIf

Return lRet
// The end of the Static Function F3E_DOC_When()



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T06MPost
Handles fields changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T06MPost(oModel as Object)
Local lRet := .T.

Local cCode as Character

Local nLine as Numeric
Local nWofBsDiff as Numeric
Local nWofValDiff as Numeric

Local oModelF3E := oModel:getModel("F3EDETAIL")
Local nOperation := oModel:GetOperation()

Local cNMBAlias := "WRODOC"

If (nOperation == MODEL_OPERATION_INSERT)
    cCode := RU09D03NMB(cNMBAlias, Nil, xFilial("F3D"))
    If Empty(cCode)
        lRet := .F.
        Help("",1,"RU09T06MPost01",,STR0951 + cNMBAlias,1,0)
    EndIf

    If !oModel:getModel("F3DMASTER"):LoadValue("F3D_CODE", cCode)
        lRet := .F.
        Help("",1,"RU09T06MPost02",,STR0927,1,0)
    EndIf
EndIf

If (nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)
    If lRet       
        For nLine := 1 to oModelF3E:Length(.F.)
            oModelF3E:GoLine(nLine)

            // If the row is inserted and deleted. Or if the row is not inserted and is not deleted.
            If oModelF3E:IsInserted() == oModelF3E:IsDeleted()
                nWofBsDiff := 0
                nWofValDiff := 0

                // With one exception.
                If !oModelF3E:IsDeleted() .and. oModelF3E:IsUpdated()
                    nWofBsDiff := oModelF3E:GetValue("F3E_WOFBAS") - oModelF3E:GetValue("F3E_WBSDIF")
                    nWofValDiff := oModelF3E:GetValue("F3E_VALUE") - oModelF3E:GetValue("F3E_WVLDIF")
                EndIf
            EndIf

            // If row is not inserted but deleted.
            If !oModelF3E:IsInserted() .and. oModelF3E:IsDeleted()
                nWofBsDiff := - oModelF3E:GetValue("F3E_WBSDIF")
                nWofValDiff := - oModelF3E:GetValue("F3E_WVLDIF")
            EndIf

            // If row is inserted and not deleted.
            If oModelF3E:IsInserted() .and. !oModelF3E:IsDeleted()
                nWofBsDiff := oModelF3E:GetValue("F3E_WOFBAS")
                nWofValDiff := oModelF3E:GetValue("F3E_VALUE")
            EndIf
            
            lRet := lRet .and. oModelF3E:LoadValue("F3E_WBSDIF", nWofBsDiff)
            lRet := lRet .and. oModelF3E:LoadValue("F3E_WVLDIF", nWofValDiff)
            
            If !lRet
                Help("",1,"RU09T06MPost03",,STR0927,1,0)
                Exit
            EndIf
        Next nLine
    EndIf // lRet
EndIf

Return(lRet)
// The end of the Static Function RU09T06MPost(oModelF3D)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T06DLPre
Handles grid's line changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T06FPre(oModelF3D as Object, cAction as Character, cField as Character, xValue)
Local lRet := .T.

Local oModel as Object
Local nLine as Numeric

oModel := FWModelActive()
oModelF3E := oModel:GetModel("F3EDETAIL")

If (cAction == "SETVALUE") .and. (cField == "F3D_FINAL")
    For nLine := 1 to oModelF3E:Length()
        oModelF3E:GoLine(nLine)
        If !oModelF3E:IsDeleted() .and. (oModelF3E:GetValue("F3E_PDATE") > xValue)
            lRet := .F.
            Help("",1,"RU09T06FPre01",,STR0947+oModelF3E:GetValue("F3E_DOC"),1,0)
            Exit
        EndIf
    Next nLine
EndIf
Return(lRet)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T06DLPre
Handles grid's line changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T06DLPre(oModelF3E as Object, nLinVld as Numeric, cAction as Character, cField as Character, xValue, xOldValue)
// Logical routine flow control
Local lRet := .T.
// Stores Write-Offing values
Local nWofBs as Numeric
Local nWofVal as Numeric
Local nWofRate as Numeric
Local nWofValTotal as Numeric
// Variables for SQL queries
Local cQuery as Character
Local cTab as Character
// Variables for certain filters
Local cIntCodeList as Character
// Variables to operate with Model
Local oModel as Object
Local nLine as Numeric
// Saves the line selected by user
Local aSaveRows as Array
Local nFocus := GetFocus()
// Variables to operate with View
Local oView as Object

If Type("lRecursion") == "U"
	Private lRecursion := .F.
EndIf

// Prevents prevalidation from recursion.
If (lRecursion == .T.)
    
Else
	lRecursion := .T.
    aSaveRows := FWSaveRows()

    // Variables initialization.
    nLine := 1

    cQuery := ""
    cTab := ""
    cIntCodeList := ""

    oModel := FWModelActive()
    If (ValType(oModel) != "O") .or. (oModel:getId() != "RU09T06")
        lRet := .F.
        Help("",1,"RU09T06DLPre01",,STR0910,1,0)
    EndIf

    // If it is the deletion of an empty line return Nil.
    If (cAction == "DELETE") .and. Empty(AllTrim(oModelF3E:GetValue("F3E_KEY")))
        lRet := Nil

    ElseIf lRet .and. (cAction == "CANSETVALUE") .and. (cField == "F3E_DOC")
        If !Empty(AllTrim(oModelF3E:GetValue("F3E_KEY")))
            lRet := .F.
        EndIf

    // If user put something into the Doc. Num. field and pressed enter.
    ElseIf lRet .and. (cAction == "SETVALUE") .and. (cField $ "F3E_KEY   |F3E_DOC   |")
        If (Empty(AllTrim(oModelF3E:GetValue("F3E_KEY"))) .and. (cField == "F3E_DOC"));
        .or. (cField == "F3E_KEY")
            // Finds VAT Invoice grouped items from the Balances table.
            cQuery := " SELECT T0.F32_KEY AS VAT_KEY, "
            cQuery += " T0.F32_DOC AS DOC_NUM, "
            cQuery += " T0.F32_VATCOD AS INTCODE, "
            cQuery += " T0.F32_VATCD2 AS EXTCODE, "
            cQuery += " T0.F32_INIBS AS INIT_BASE, "
            cQuery += " T0.F32_INIBAL AS INIT_VALUE, "
            cQuery += " T0.F32_OPBAL AS OPEN_BALANCE, "
            cQuery += " T0.F32_OPBS AS OPEN_BASE, "
            cQuery += " T0.F32_PDATE AS PRINT_DATE, "
            cQuery += " T0.F32_VATRT AS VAT_RATE "
            cQuery += " FROM " + RetSQLName("F32") + " AS T0 "
            cQuery += " WHERE T0.F32_FILIAL = '" + xFilial("F32") + "' "
            // Prevent lines with the same combination of Doc and Internal Code.
            For nLine := 1 to oModelF3E:Length(.F.)
                oModelF3E:GoLine(nLine)
                // This condition is based on the uniqueness of the Internal Code.
                If !Empty(AllTrim(oModelF3E:GetValue("F3E_KEY")))
                    // Adds conditions to exclude the records, which are already in the model, from SQL query.
                    cQuery += " AND NOT ("
                    cQuery += " T0.F32_KEY = '" + oModelF3E:GetValue("F3E_KEY") + "'" 
                    cQuery += " AND T0.F32_VATCOD = '" + oModelF3E:GetValue("F3E_VATCOD") + "'"
                    cQuery += " )"
                EndIf
            Next nLine
            // If user fill the final date of the Purchase Write-Off, this conditional will be taken into account.
            If !Empty(oModel:getModel("F3DMASTER"):GetValue("F3D_FINAL"))
                cQuery += " AND T0.F32_RDATE <= '" + DtoS(oModel:getModel("F3DMASTER"):GetValue("F3D_FINAL")) + "' "
            EndIf
            If (cField == "F3E_DOC")
                cQuery += " AND F32_DOC = '" + xValue + "' "
            ElseIf (cField == "F3E_KEY")
                cQuery += " AND F32_KEY = '" + xValue + "' "
            EndIf
            cQuery += " AND T0.F32_OPBS > 0"
            cQuery += " AND T0.D_E_L_E_T_ = ' '"
            cQuery += " ORDER BY T0.F32_FILIAL,"
            cQuery += " T0.F32_SUPPL,"
            cQuery += " T0.F32_SUPUN,"
            cQuery += " T0.F32_DOC,"
            cQuery += " T0.F32_RDATE,"
            cQuery += " T0.F32_KEY,"
            cQuery += " T0.F32_VATCOD,"
            cQuery += " T0.F32_VATCD2"
            cTab := MPSysOpenQuery(ChangeQuery(cQuery))

            // If no Purchases VAT Invoices with such Document Number were found.
            If (cTab)->(Eof())
                lRet := .F.
                Help("",1,"RU09T06DLPre04",,STR0913,1,0)
            EndIf

            If lRet
                lRet := lRet .and. FillF3ETable(oModelF3E, cTab, 100.00)
            EndIf

            CloseTempTable(cTab) // Deletes the temporary table.
        EndIf

    ElseIf lRet .and. (cAction == "SETVALUE") .and. (cField $ "F3E_WOFBAS|F3E_VATPER|F3E_VALUE |") .and. !Empty(oModelF3E:GetValue("F3E_DOC"))
        // If user changes Write-Off Base, the Write-Off Value and Write-Off Percent will be changed proportionally.
        If (cField == "F3E_WOFBAS")
            nWofBs := xValue
            // If user wants to Write-Off the whole open balance, it can be a round error.
            // Here it is an attempt to avoid round error after multiplication and division.
            If (nWofBs == (oModelF3E:GetValue("F3E_OPBSBU")+oModelF3E:GetValue("F3E_WBSDIF")))
                nWofVal := oModelF3E:GetValue("F3E_OPVLBU") + oModelF3E:GetValue("F3E_WVLDIF")
            Else
                // Write-Off Value = Write-Off Base * Write-Off % Rate
                nWofVal := Round(xValue * oModelF3E:GetValue("F3E_VATRT") / 100.00, 2)
            EndIf
            // Write-Off % Rate = Write-Off Base / Open Base
            nWofRate := Round(xValue / oModelF3E:GetValue("F3E_VATBS") * 100.00, 2)

        // If user changes Write-Off Percent, the Write-Off Value and Write-Off Base will be changed proportionally.
        ElseIf (cField == "F3E_VATPER")
            // Write-Off Base = Write-Off % Rate * Open Base
            nWofBs := Round(xValue * oModelF3E:GetValue("F3E_VATBS") / 100.00, 2)
            nWofRate := xValue
            // Write-Off Value = Write-Off % Rate * Open Balance
            nWofVal := Round(xValue * oModelF3E:GetValue("F3E_VATVL") / 100.00, 2)

        // If user changes Write-Off Value, the Write-Off Percent and Write-Off Base will be changed proportionally.
        ElseIf (cField == "F3E_VALUE")
            nWofVal := xValue
            // If user wants to Write-Off the whole open balance, it can be a round error.
            // Here it is an attempt to avoid round error after multiplication and division.
            If (nWofVal == (oModelF3E:GetValue("F3E_OPVLBU")+oModelF3E:GetValue("F3E_WVLDIF")))
                nWofBs := oModelF3E:GetValue("F3E_OPBSBU") + oModelF3E:GetValue("F3E_WBSDIF")
            Else
                // Write-Off Base = Open Base * Write-Off Value / Open Balance
                nWofBs := Round(xValue * 100 / oModelF3E:GetValue("F3E_VATRT"), 2)
            EndIf
            // Write-Off % Rate = Write-Off Value / Open Balance
            nWofRate := Round(nWofBs / oModelF3E:GetValue("F3E_VATBS") * 100.00, 2)
        EndIf
        // Checks, if user puts the value, which is out of borders.
        If (nWofBs > (oModelF3E:GetValue("F3E_OPBSBU")+oModelF3E:GetValue("F3E_WBSDIF"))) .or. (nWofBs > oModelF3E:GetValue("F3E_VATBS"))
            lRet := .F.
            Help("",1,"RU09T06DLPre01",,STR0928,1,0)
        EndIf
        // If everything is ok.
        If lRet
            oModelF3E:LoadValue("F3E_WOFBAS", nWofBs)
            oModelF3E:LoadValue("F3E_VATPER", nWofRate)
            oModelF3E:LoadValue("F3E_VALUE", nWofVal)

            oModelF3E:LoadValue("F3E_OPBS", oModelF3E:GetValue("F3E_OPBSBU") + oModelF3E:GetValue("F3E_WBSDIF") - nWofBs)
            oModelF3E:LoadValue("F3E_OPBAL", oModelF3E:GetValue("F3E_OPVLBU") + oModelF3E:GetValue("F3E_WVLDIF") - nWofVal)
        EndIf
    EndIf

    If lRet .and. (cAction != "CANSETVALUE") .and. (cAction != "ISENABLE")
        nWofValTotal := 0
        // Goes thought the grid and sums all values into the total.
        For nLine := 1 to oModelF3E:Length(.F.)
            If (cAction == "DELETE") .and. (nLine == nLinVld)
                Loop
            EndIf
            oModelF3E:GoLine(nLine)
            // Calculates total. Sums not deleted lines and not empty values.
            If ((!oModelF3E:IsDeleted()) .and. ((!Empty(oModelF3E:GetValue("F3E_VALUE"))) .or. (oModelF3E:GetValue("F3E_VALUE") != 0)));
            .or. ((cAction == "UNDELETE") .and. (nLine == nLinVld))
                nWofValTotal += oModelF3E:GetValue("F3E_VALUE")
            EndIf
        Next nLine
        // Puts the total sum into the field.
        oModel:getModel("F3DMASTER"):LoadValue("F3D_TOTAL", nWofValTotal)
    EndIf

    FWRestRows(aSaveRows)

    If lRet .and. (cAction != "CANSETVALUE") .and. (cAction != "ISENABLE")
        // Refreshes the oView object
        oView := FwViewActive()
        If (oView != Nil) .and. (oView:GetModel():GetId() == "RU09T06")
            oView:Refresh()
            // Retores saved focus
            SetFocus(nFocus)
        EndIf
    EndIf
    
    lRecursion := .F.
EndIf
Return(lRet)
// The end of the Static Function RU09T06DLPre(oModelF3E)



//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelRec
Records Purchases Write-Off model into the database.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ModelRec(oModel as Object)    // Full Model
Local lRet := .T.
Local nOperation as Numeric
Local nLine as Numeric

// Checks, if input argument is not an Object.
If !lRet .or. ValType(oModel) != "O"
    lRet := .F.
    Help("",1,"RU09T06ModelRec08",,STR0910,1,0)
EndIf

// Checks, if operation code is defined.
nOperation := oModel:getOperation()
If !lRet .or. ValType(nOperation) != "N"
    lRet := .F.
    Help("",1,"RU09T06ModelRec09",,STR0914,1,0)
EndIf

oModelF3E := oModel:GetModel("F3EDETAIL")

oModel:GetModel("F3EDETAIL"):SetNoDeleteLine(.F.)
For nLine := 1 to oModelF3E:Length(.F.)
    oModelF3E:GoLine(nLine)
    // Gets rid out of empty lines.
    If ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)) .and. Empty(oModelF3E:GetValue("F3E_KEY"))
        oModelF3E:DeleteLine()
    EndIf
Next nLine
oModel:GetModel("F3EDETAIL"):SetNoDeleteLine(.T.)

Begin Transaction
// If everything is OK, commit the model.
If lRet

    If (nOperation == MODEL_OPERATION_DELETE) .And. lRet .and. F3D->F3D_STATUS=='3' .And. !Empty(F3D->F3D_DTLA)
        ctbVATwrof(oModel, .F. )
    Endif 
    If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. lRet .and. oModel:GetModel("F3DMASTER"):GetValue("F3D_STATUS")=='3' .And. Empty(F3D->F3D_DTLA)
        oModel:GetModel("F3DMASTER"):SetValue("F3D_DTLA",dDataBase)         
    EndIf 
    lRet := lRet .and. FWFormCommit(oModel)

    If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. lRet .and. F3D->F3D_STATUS=='3' 
        ctbVATwrof(oModel, .T. )
    Endif  

    // Renew the Balances and Movements after commit.
    If nOperation == MODEL_OPERATION_INSERT
        lRet := lRet .and. RU09D05Edt(oModel)
        lRet := lRet .and. RU09D04Add(oModel)
    ElseIf nOperation == MODEL_OPERATION_UPDATE
        lRet := lRet .and. RU09D05Edt(oModel)
        lRet := lRet .and. RU09D04Edt(oModel)
    ElseIf nOperation == MODEL_OPERATION_DELETE
        lRet := lRet .and. RU09D05Edt(oModel)
        lRet := lRet .and. RU09D04Del(oModel)       
    EndIf
EndIf

If !lRet
    Help("",1,"RU09T06ModelRec",,STR0937,1,0)
    DisarmTransaction()
EndIf

End Transaction

// TODO: here should be an accounting postings update.

Return(lRet)
// The end of the Static Function ModelRec(oModel)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T06AInc
@author Artem Kostin
@since 02/27/2018
@version 12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T06AInc(oModel as Object)
Local lRet := .T.

Local aParam as Array
Local aPerguntas as Array

Local oModelF3D as Object
Local oModelF3E as Object

Local nLine as Numeric
Local nWofValTotal as Numeric

Local cTab as Character
Local cQuery as Character

// Initialisation of the variables.
aParam :={}
aPerguntas	:= {}
nLine := 1

cTab := ""
cQuery := ""

oModelF3D := oModel:getModel("F3DMASTER")
oModelF3E := oModel:getModel("F3EDETAIL")

// Questions to help user filter result of the autocomplete function.
// ?	Doc. No.: Purchase VAT Invoice Number.
aAdd(aPerguntas,{ 1, STR0916 + " " + STR0923, Space(TamSX3("F37_DOC")[1]),            "@!",'.T.',"",".T.",60, .F.})
aAdd(aPerguntas,{ 1, STR0916 + " " + STR0924,   Replicate("z", TamSX3("F37_DOC")[1]),   "@!",'.T.',"",".T.",60, .F.})
// ?	Print Date: Purchase VAT Invoice Print Date.
aAdd(aPerguntas,{ 1, STR0917 + " " + STR0924,   oModelF3D:GetValue("F3D_FINAL"),            /*mask*/,'.T.',"",".T.",60, .F.})
// ?	Comm. Ser.: Commercial Invoice Series.
aAdd(aPerguntas,{ 1, STR0918 + " " + STR0923, Space(TamSX3("F37_INVSER")[1]),       "@!",'.T.',"",".T.",60, .F.})
aAdd(aPerguntas,{ 1, STR0918 + " " + STR0924, Replicate("z", TamSX3("F37_INVSER")[1]),"@!",'.T.',"",".T.",60, .F.})
// ?	To Comm. No.: Commercial Invoice Number.
aAdd(aPerguntas,{ 1, STR0919 + " " + STR0923, Space(TamSX3("F37_INVDOC")[1]),         "@!",'.T.',"",".T.",60, .F.})
aAdd(aPerguntas,{ 1, STR0919 + " " + STR0924, Replicate("z", TamSX3("F37_INVDOC")[1]),  "@!",'.T.',"",".T.",60, .F.})
// ?	Supplier: Purchase VAT Invoice Supplier Code.
aAdd(aPerguntas,{ 1, STR0920 + " " + STR0923, Space(TamSX3("F37_FORNEC")[1]),             "@!",'.T.',"",".T.",60, .F.})
aAdd(aPerguntas,{ 1, STR0920 + " " + STR0924, Replicate("z", TamSX3("F37_FORNEC")[1]),      "@!",'.T.',"",".T.",60, .F.})
// ?	Branch: Purchase VAT Invoice Supplier Branch.
aAdd(aPerguntas,{ 1, STR0921+ " " + STR0923, Space(TamSX3("F37_BRANCH")[1]),      "@!",'.T.',"",".T.",60, .F.})
aAdd(aPerguntas,{ 1, STR0921+ " " + STR0924, Replicate("z", TamSX3("F37_BRANCH")[1]),"@!",'.T.',"",".T.",60, .F.})
// ?	Write-Off %: Purchase VAT Invoice Write-Off %. The initial value must be 100%.
aAdd(aPerguntas,{ 1, STR0922, 100.00,                                               "@999.99",'.T.',"",".T.",60, .F.})


// Shows user a window with questions.
If !ParamBox(aPerguntas, STR0925, aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
    lRet := .F.
EndIf

If lRet
    // Select from Invoices.
    cQuery := " SELECT T0.F32_KEY AS VAT_KEY,"
    cQuery += " T0.F32_DOC AS DOC_NUM,"
    cQuery += " T0.F32_SUPPL AS SUPPLIER,"
    cQuery += " T0.F32_SUPUN AS BRANCH,"
    cQuery += " T0.F32_PDATE AS PRINT_DATE,"
    cQuery += " T0.F32_VATCOD AS INTCODE,"
    cQuery += " T0.F32_VATCD2 AS EXTCODE,"
    cQuery += " T0.F32_OPBS AS OPEN_BASE,"
    cQuery += " T0.F32_OPBAL AS OPEN_BALANCE,"
    cQuery += " T0.F32_INIBS AS INIT_BASE,"
    cQuery += " T0.F32_VATRT AS VAT_RATE,"
    cQuery += " T0.F32_INIBAL AS INIT_VALUE"
    cQuery += " FROM " + RetSQLName("F32") + " T0"
    cQuery += " INNER JOIN " + RetSQLName("F37") + " T1"
    cQuery += " ON ("
    cQuery += " T1.F37_FILIAL = '" + xFilial("F37") + "'"
    cQuery += " AND T1.D_E_L_E_T_ = ' '"
    cQuery += " AND T1.F37_DOC BETWEEN '" + aParam[1] + "' AND '" + aParam[2] + "'"
    cQuery += " AND T1.F37_RDATE <= '" + DtoS(aParam[3]) + "'"
    cQuery += " AND	T1.F37_INVSER BETWEEN '" + aParam[4] + "' AND '" + aParam[5] + "'"
    cQuery += " AND	T1.F37_INVDOC BETWEEN '" + aParam[6] + "' AND '" + aParam[7] + "'"
    cQuery += " AND	T1.F37_FORNEC BETWEEN '" + aParam[8] + "' AND '" + aParam[9] + "'"
    cQuery += " AND	T1.F37_BRANCH BETWEEN '" + aParam[10] + "' AND '" + aParam[11] + "'"
    cQuery += ")"
    cQuery += " INNER JOIN " + RetSQLName("F31") + " T2"
    cQuery += " ON ("
    cQuery += " T2.F31_FILIAL = '" + xFilial("F31") + "'"
    cQuery += " AND T2.F31_CODE = T0.F32_VATCOD"
    cQuery += " AND T2.F31_USE = '3'"
    cQuery += " AND T2.D_E_L_E_T_ = ' '"
    cQuery += ")"
    cQuery += " WHERE T0.F32_FILIAL = '" + xFilial("F32") + "'"
    // Goes thought the grid and collects list of Doc Numbers, which are already in the Model.
    // Lines marked as deleted must be counted too, because user can undelete them.
    For nLine := 1 to oModelF3E:Length(.F.)
        oModelF3E:GoLine(nLine)
        If !Empty(AllTrim(oModelF3E:GetValue("F3E_KEY")))
            // Adds conditions to exclude the records, which are already in the model, from SQL query.
            cQuery += " AND NOT ("
            cQuery += " T0.F32_KEY = '" + oModelF3E:GetValue("F3E_KEY") + "'" 
            cQuery += " AND T0.F32_VATCOD = '" + oModelF3E:GetValue("F3E_VATCOD") + "'"
            cQuery += " )"
        EndIf
    Next nLine
    cQuery += " AND T0.F32_KEY = T1.F37_KEY"
    cQuery += " AND T0.F32_OPBS > 0"
    cQuery += " AND T0.D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY DOC_NUM"
    cQuery += " ,SUPPLIER"
    cQuery += " ,BRANCH"
    cQuery += " ,PRINT_DATE"
    cQuery += " ,VAT_KEY"
    cQuery += " ,INTCODE"
    cQuery += " ,EXTCODE"
    cTab := MPSysOpenQuery(ChangeQuery(cQuery))

    lRet := lRet .and. FillF3ETable(oModelF3E, cTab, aParam[12])

    nWofValTotal := 0
    // Goes thought the grid and sums all values into the total.
    For nLine := 1 to oModelF3E:Length(.F.)
        oModelF3E:GoLine(nLine)
        // Calculates total. Sums not deleted lines and not empty values.
        If !oModelF3E:IsDeleted() .and. ((!Empty(oModelF3E:GetValue("F3E_VALUE"))) .or. (!oModelF3E:GetValue("F3E_VATVL") == 0))
            nWofValTotal += oModelF3E:GetValue("F3E_VALUE")
        EndIf
    Next nLine
    // Puts the total sum into the field.
    oModel:getModel("F3DMASTER"):LoadValue("F3D_TOTAL", nWofValTotal)

    // Refreshes a oView object
    oView := FwViewActive()
    If (oView <> Nil) .and. (oView:GetModel():GetId() == "RU09T06")
        oView:Refresh()
    EndIf
EndIf

CloseTempTable(cTab)
Return(lRet)
// The end of the Function RU09T06AInc(oModel)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06VATInExp
@author Artem Kostin
@since 02/28/2018
@version 12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU06VATInExp(oModel)
Local lRet := .T.

Local cArq as Character

Local nHandle as Numeric

cArq := cGetFile("File CSV | *.csv", "File .CSV", 1, "C:\", .F., GETF_LOCALHARD, .F., .T.)

If (!Empty(cArq))
	nHandle := FCreate(cArq)
	
	If !(nHandle == -1)
		Processa({|| gravaReg(@nHandle,oModel)}, STR0933, STR0934, .F.)

		FClose(nHandle)

        Help("",1,"RU06VATInExp01",,STR0930,1,0)
	Else
        lRet := .T.
        Help("",1,"RU06VATInExp02",,STR0931,1,0)
	EndIf
EndIf

Return(lRet)
// The end of the Function RU06VATInExp



//-----------------------------------------------------------------------
/*/{Protheus.doc} gravaReg
@author Artem Kostin
@since 02/28/2018
@version 12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function gravaReg(nHandle,oModel)
Local aArea as Array
Local aAreaF3E as Array

Local aStructF3D as Array
Local aStructF3E as Array

Local oModelF3E as Object 
Local oModelF3D as Object

Local nI as Numeric

Local cString as Character
Local cBookKey as Character
Local cFilF3D as Character

aArea := GetArea()
aAreaF3E := F3E->(GetArea())
aAreaF3D := F3D->(GetArea())

aStructF3E := F3E->(DbStruct())
aStructF3D := F3D->(DbStruct())

oModelF3D := oModel:getModel("F3DMASTER")

cString := ""
cBookKey := oModelF3D:GetValue("F3D_WRIKEY")
cFilF3D := xFilial("F3D")
cFilF3E := xFilial("F3E")

DbSelectArea("F3D")
F3D->(DbSetOrder(1))
F3D->(DbGoTop())

DbSelectArea("F3E")
F3E->(DbSetOrder(2))
F3E->(DbGoTop())

If F3D->(DbSeek(cFilF3D+cBookKey))
    // Writes the titles of header data.
    For nI := 1 To Len(aStructF3D)
        cString += AllTrim(Posicione("SX3", 2, aStructF3D[nI, 1], "X3Titulo()"))  +  ";"                                                   
    Next nI
	FWrite(nHandle, cString + CRLF)

    // Writes the header data.
	While (!F3D->(Eof())) .And. (F3D->(F3D_FILIAL+F3D_WRIKEY) == cFilF3D+cBookKey)
		cString := ""
		For nI := 1 To Len(aStructF3D)
            // If the type is numeric.
			If (aStructF3D[nI, 2] == "N")
				cString += StrTran(STR(&("F3D->"+aStructF3D[nI, 1])),'.',',') + ";"
            // If the type is date.
			ElseIf (aStructF3D[nI , 2] == "D")
				cString += CHR(160) + DtoC(&("F3D->"+aStructF3D[nI, 1])) + ";"
            // The other else types.
			Else 
				cString += CHR(160) + &("F3D->"+aStructF3D[nI, 1]) + ";"
			EndIf
		Next nI
		FWrite(nHandle, cString + CRLF)
		IncProc(STR0934 + StrZero(nI, 10))
		F3D->(DbSkip())
	EndDo

    If F3E->(dbSeek(cFilF3E+cBookKey))
        // Reinitialise of the input data.
        cString := ""
        // Writes the titles of details data.
        For nI := 1 To Len(aStructF3E)
            cString += AllTrim(Posicione("SX3", 2, aStructF3E[nI, 1], "X3Titulo()")) + ";" 
        Next nI
        FWrite(nHandle, cString + CRLF)

        // Writes details data.
        While !F3E->(Eof())
            If F3E->(F3E_FILIAL+F3E_WRIKEY) == cFilF3E+cBookKey
                cString := ""
                For nI := 1 To Len(aStructF3E)
                    // If the type is numeric.
                    If aStructF3E[nI, 2] == "N"
                        cString += StrTran(STR(&("F3E->"+aStructF3E[nI, 1])),'.',',')  + ";"
                    // If the type is date.
                    ElseIf aStructF3E[nI, 2] == "D"
                        cString += CHR(160) + DtoC(&("F3E->"+aStructF3E[nI, 1])) + ";"
                    // The other else types.
                    Else
                        cString += CHR(160) + &("F3E->"+aStructF3E[nI, 1]) + ";"
                    EndIf
                Next nI
                FWrite(nHandle, cString + CRLF)
                IncProc(STR0934 + StrZero(nI, 10))
            EndIf
            F3E->(DbSkip())
        EndDo
    EndIf
EndIf

RestArea(aAreaF3D)
RestArea(aAreaF3E)
RestArea(aArea)
Return(.T.)
// The end of the Function gravaReg



/*/{Protheus.doc} RU09T06VAT
@author Artem Kostin
@since 07/03/2018
@version 1.0
@type function
/*/
Static Function RU09T06VAT(oModel)
Local aAreaF37 as Array
Local oModelInvc as Object
Local cKey as Character

aAreaF37 := getArea()
oModelInvc := oModel:getModel('F3EDETAIL')
cKey := AllTrim(oModelInvc:GetValue("F3E_KEY"))

If !Empty(cKey)
	dbSelectArea('F37') 
	F37->(DbSetOrder(3))
	If F37->(DbSeek(xFilial('F37') + cKey))
		FWExecView(STR0009, "RU09T03", MODEL_OPERATION_VIEW, , {|| .T.})
    Else
        Help("",1,"RU09T06VAT01",,STR0909 + cKey,1,0)	// 
	EndIf
	RestArea(aAreaF37)
EndIf
oModelInvc:GoLine(1)
Return(.T.)



/*/{Protheus.doc} RU09T06AAct
@author Artem Kostin
@since 14/03/2018
@version 1.0
@type function
/*/
Static Function RU09T06AAct(oModel)
Local lRet := .T.
Local nLine as Numeric
Local nOperation as Numeric

Local oModelF3E as Object
Local oStructF3E    as Object

nOperation := oModel:GetOperation()

If ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE))
    nLine := 0

    oModelF3E := oModel:getModel("F3EDETAIL")

    For nLine := 1 to oModelF3E:Length(.F.)
        oModelF3E:goLine(nLine)
        lRet := lRet .and. oModelF3E:LoadValue("F3E_WBSDIF", oModelF3E:GetValue("F3E_WOFBAS"))
        lRet := lRet .and. oModelF3E:LoadValue("F3E_WVLDIF", oModelF3E:GetValue("F3E_VALUE"))
        lRet := lRet .and. oModelF3E:LoadValue("F3E_OPBSBU", oModelF3E:GetValue("F3E_OPBS"))
        lRet := lRet .and. oModelF3E:LoadValue("F3E_OPVLBU", oModelF3E:GetValue("F3E_OPBAL"))

        If !lRet
            Help("",1,"RU09T06AAct01",,STR0927,1,0)
            Exit
        EndIf
    Next nLine

    oStructF3E := oModelF3E:GetStruct()
    oStructF3E:SetProperty('*',MODEL_FIELD_WHEN,{||FWFldGet("F3D_STATUS") == "1"})
EndIf

// If Write-Off Status is Blocked or Closed.
//If (nOperation == MODEL_OPERATION_UPDATE) .and. ((F3D->F3D_STATUS == "2") .Or. (F3D->F3D_STATUS == "3"))
//    oModel:GetModel("F3EDETAIL"):setNoInsertLine(.T.)
//    oModel:GetModel("F3EDETAIL"):setNoDeleteLine(.T.)
//    oModel:GetModel("F3EDETAIL"):setNoUpdateLine(.T.)
//EndIf

Return(lRet)



Static Function FillF3ETable(oModelF3E as Object, cTab as Character, nUserRate as Numeric)
Local lRet := .T.
Local lAddLine := .T.
Local nLine as Numeric
Local nWofRate as Numeric

// If there is already an empty line, data could be inserted starting from this empty line.
// If there is no empty line, add new line and push new data to the bottom of the grid.
lAddLine := !Empty(AllTrim(oModelF3E:GetValue("F3E_KEY")))
// Loading new data selected by query at the end of the grid.
nLine := 0
While !(cTab)->(Eof())
    If lAddLine
        nLine := oModelF3E:AddLine()
    Else
        nLine := oModelF3E:Length()
        lAddLine := .T.
    EndIf

    nWofRate := min((cTab)->OPEN_BASE / (cTab)->INIT_BASE * 100.00, nUserRate)
    // F3E_FILIAL is filled by relation between F3DMASTER and F3EDETAIL.
    // F3E_CODE is filled by relation between F3DMASTER and F3EDETAIL.
    // F3E_WRIKEY is filled by relation between F3DMASTER and F3EDETAIL.
    lRet := lRet .and. oModelF3E:LoadValue("F3E_ITEM", StrZero(nLine, GetSX3Cache("F3E_ITEM", "X3_TAMANHO")))  // Number of the line in the Write-Off details table.
    lRet := lRet .and. oModelF3E:LoadValue("F3E_KEY", (cTab)->VAT_KEY)	// Purchase VAT Invoice Key.
    lRet := lRet .and. oModelF3E:LoadValue("F3E_DOC", (cTab)->DOC_NUM)	// Purchase VAT Invoice Document Number.
    lRet := lRet .and. oModelF3E:LoadValue("F3E_PDATE", StoD((cTab)->PRINT_DATE))    // Purchase VAT Invoice Print Date
    lRet := lRet .and. oModelF3E:LoadValue("F3E_VATCOD", (cTab)->INTCODE)  // Purchase VAT Invoice Internal Code.
    lRet := lRet .and. oModelF3E:LoadValue("F3E_VATCD2", (cTab)->EXTCODE)  // Purchase VAT Invoice External (Operational) Code.
    lRet := lRet .and. oModelF3E:LoadValue("F3E_VATPER", nWofRate) // Percentage of Write-Off Base Value, which will be written off.
    // If user's rate is 100%, copy values from SQL query to avoid precision errors.
    If (nUserRate > nWofRate) .or. (nUserRate == 100.00)
        lRet := lRet .and. oModelF3E:LoadValue("F3E_WOFBAS", (cTab)->OPEN_BASE)    // Write-Off Base Value.
        lRet := lRet .and. oModelF3E:LoadValue("F3E_VALUE", (cTab)->OPEN_BALANCE) // Write-Off Value = Write-Off Base * Write-Off Percents
        lRet := lRet .and. oModelF3E:LoadValue("F3E_OPBAL", 0)  // Purchase VAT Invoice Tax Value ready for Write-Off or Write-Off.
        lRet := lRet .and. oModelF3E:LoadValue("F3E_OPBS", 0)  // Purchase VAT Invoice Tax Value ready for Write-Off or Write-Off.
    Else
        lRet := lRet .and. oModelF3E:LoadValue("F3E_WOFBAS", nWofRate * (cTab)->INIT_BASE / 100)    // Write-Off Base Value.
        lRet := lRet .and. oModelF3E:LoadValue("F3E_VALUE", nWofRate * (cTab)->INIT_VALUE / 100) // Write-Off Value = Write-Off Base * Write-Off Percents
        lRet := lRet .and. oModelF3E:LoadValue("F3E_OPBAL", (cTab)->OPEN_BALANCE - nWofRate * (cTab)->INIT_VALUE / 100)  // Purchase VAT Invoice Tax Value ready for Write-Off or Write-Off.
        lRet := lRet .and. oModelF3E:LoadValue("F3E_OPBS", (cTab)->OPEN_BASE - nWofRate * (cTab)->INIT_BASE / 100)  // Purchase VAT Invoice Tax Value ready for Write-Off or Write-Off.
    EndIf
    // Temporary fields to control restrictions.
    lRet := lRet .and. oModelF3E:LoadValue("F3E_WBSDIF", 0)
    lRet := lRet .and. oModelF3E:LoadValue("F3E_WVLDIF", 0)
    lRet := lRet .and. oModelF3E:LoadValue("F3E_OPBSBU", (cTab)->OPEN_BASE)
    lRet := lRet .and. oModelF3E:LoadValue("F3E_OPVLBU", (cTab)->OPEN_BALANCE)
    // Virtual fields to inform user.
    lRet := lRet .and. oModelF3E:LoadValue("F3E_VATBS", (cTab)->INIT_BASE)  // Purchase VAT Invoice Initial Base
    lRet := lRet .and. oModelF3E:LoadValue("F3E_VATRT", (cTab)->VAT_RATE)   // Purchase VAT Invoice Tax Rate
    lRet := lRet .and. oModelF3E:LoadValue("F3E_VATVL", (cTab)->INIT_VALUE)  // Purchase VAT Invoice Initial Tax Value
    // Last line will always exist and be empty for new user inputs.
    (cTab)->(DbSkip())
EndDo

If !lRet
    Help("",1,"FillF3ETable01",,STR0927,1,0)
EndIf
Return(lRet)

Static Function RU09T06CTL_View()
Local oModel as Object

oModel:= FwLoadModel("RU09T06")
oModel:SetOperation(MODEL_OPERATION_VIEW)
oModel:Activate()

FwExecView(STR0902, "RU09T06", MODEL_OPERATION_VIEW,/* oDlg */, /*{|| .T.}*/,/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)

Return

/*/{Protheus.doc} ctbVATwrof
Function thats posts accounting entries.
@author felipe.morais
@since 10/01/2020
@version P12.1.16
@param oModel, object, Needs to receive the actual model.
@param lInc, logical, Needs to inform it is an inclusion or not.
@type function
/*/

Static Function ctbVATwrof(oModel as Object, lInc as Logical)
Local lRet as Logical
Local oModelF3D as Object
Local oModelF3E as Object
Local nHdlPrv as Numeric
Local cLoteFis as Character
Local cOrigem as Character
Local cArquivo as Character
Local nTotal as Numeric
Local lCommit as Logical
Local cPadrao as Character
Local lMostra as Logical
Local lAglutina as Logical
Local cPerg as Character
Local nOperation as Numeric
// Used areas
Local aArea as Array
Local aAreaF37 as Array
Local aAreaF38 as Array
Local aAreaSF1 as Array
Local aAreaSA2 as Array
lRet := .T.
oModelF3D := oModel:GetModel("F3DMASTER")
oModelF3E := oModel:GetModel("F3EDETAIL")
nTotal := 0
aArea := GetArea()
aAreaF37 := F37->(GetArea())
aAreaF38 := F38->(GetArea())
aAreaSF1 := SF1->(GetArea())
aAreaSA2 := SA2->(GetArea())
cPerg := "RU09T06ACC"
nOperation:=oModel:GetOperation()
Pergunte(cPerg, .F.)
lMostra := (mv_par01 == 1)
lAglutina := (mv_par02 == 1)

nHdlPrv := 0
cLoteFis := LoteCont("FIS")
cOrigem := "RU09T06ACC"
cArquivo := " "
lCommit := .F.
// If it is an inclusion, must be used the Standard Entry 6AG to the header.
// If it is a deletion, must be used the Standard Entry 6AH to the header.
cPadrao := Iif(lInc, "6AG", "6AH")
If VerPadrao(cPadrao) // Accounting beginning
    nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)   
EndIf
DbSelectArea("F3C")

F3E->(DbSetOrder(2))
If(F3E->(DbSeek(xFilial("F3E")+oModelF3D:GetValue("F3D_WRIKEY"))))
    //While KEY on F3E is equal to key
    While (F3E->(!Eof())) .And. (xFilial("F3E")+oModelF3D:GetValue("F3D_WRIKEY"))==F3E->(F3E_FILIAL+F3E_WRIKEY)
        DbSelectArea("F37")
        F37->(DbSetOrder(7))
        If (F37->(DbSeek(xFilial("F37")+oModelF3E:GetValue("F3E_DOC"))))
            DbSelectArea("SF1")
            SF1->(DbSetOrder(1))
            If (F37->F37_TYPE == "2") .and. !(SF1->(DbSeek(xFilial("SF1") + SubStr(F37->F37_INVDOC, 1, TamSX3("F1_DOC")[1]) + SubStr(F37->F37_INVSER, 1, TamSX3("F1_SERIE")[1]))))
                lRet := .F.
            EndIf

            If lRet
                DbSelectArea("SA2")
                SA2->(DbSetOrder(1))
                If !SA2->(DbSeek(xFilial("SA2") + F37->F37_FORNEC + F37->F37_BRANCH))
                    lRet := .F.
                EndIf
            EndIf
        Else
            Help("",1,"RU09T06_ctbVATwrof_F37",,STR0023,1,0) // "VAT Sales Invoice Header of this record was not found. Cannot delete this record."
            lRet := .F.
        EndIf
        DbSelectArea("F37")        

        If (nHdlPrv > 0) .And. lRet
            nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,;
                            /*cCriterio*/, /*lRateio*/, xFilial("F3D") + F3D->F3D_WRIKEY /*cChaveBusca*/, /*aCT5*/,;
                            /*lPosiciona*/, /*@aFlagCTB*/, {'F3D',F3D->(Recno())} /*aTabRecOri*/, /*aDadosProva*/)
            
            // Updates the posting date.
            RecLock("F3D", .F.)
            F3D->F3D_DTLA := dDataBase
            F3D->(MsUnlock())
            
            // Updates the Outflow Document Status for Russia. 
            //If it is an inclusion needs to set "2" and if it is a deletion needs to set "1".
            RecLock("SF1", .F.)
            SF1->F1_STATUSR := Iif(lInc, "2", "1")
            SF1->(MsUnlock())

        EndIf
        F3E->(DbSkip())
    EndDo    
EndIf
	
If (nTotal > 0)
	cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lMostra, lAglutina)
EndIf
RodaProva(nHdlPrv, nTotal)

RestArea(aArea)
RestArea(aAreaF37)
RestArea(aAreaF38)
RestArea(aAreaSF1)
RestArea(aAreaSA2)

Return(lRet)

/*/{Protheus.doc} RU09T06001_RETWRIOFF
Function thats storno accounting entries.
@author Sergeeva Daria
@since 18/02/2020
@version P12.1.16
@type function
/*/
Function RU09T06001_RETWRIOFF()
Local oModel as Object
Local oModelF3D as Object
Local lEnt as Logical
lEnt:=.F.
DbSelectArea("F3D")
DbSetOrder(1)
oModel:= FwLoadModel("RU09T06")
oModel:SetOperation(4)
oModel:Activate()
oModelF3D:=oModel:GetModel("F3DMASTER")
Begin Transaction
If F3D->F3D_STATUS=="3"  .And. !Empty(F3D->F3D_DTLA)
    ctbVATwrof(oModel,lEnt) 
    FwFldPut('F3D_STATUS','1',,,,.T.)   
    oModel:GetModel("F3DMASTER"):SetValue("F3D_DTLA",stod(""))   
EndIf
If oModel:VldData() 
    oModel:CommitData()
Else
     DisarmTransaction()    
EndIf

End Transaction
Return