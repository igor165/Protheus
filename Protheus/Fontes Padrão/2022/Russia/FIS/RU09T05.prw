#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'ru09t03.ch'
#include 'RU09XXX.ch'

#define EXTRA_DAYS_AFTER_TAX_PERIOD 25

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05
Creates the main screen of Purchases VAT Books.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T05()
Local oBrowse as Object
Private aRotina as Array
SetKey(VK_F12, {||AcessaPerg("RU09T05ACC",.T.)})

// Initalization of the tables, if they do not exist.
DbSelectArea("F3B")
DbSelectArea("F3C")

F3C->(DbSetOrder(4))

oBrowse := FWLoadBrw("RU09T05")
aRotina := MenuDef()

oBrowse:Activate()

Return(.T.)
// The end of the Function RU09T05()



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

cTab := ""
cBrowseFilter := ""

oBrowse := FwMBrowse():New()

oBrowse:setAlias("F3B")
oBrowse:AddLegend("F3B_STATUS =='1'", "GREEN", "Open")
oBrowse:AddLegend("F3B_STATUS =='2'", "BLACK", "Blocked")
oBrowse:AddLegend("F3B_STATUS =='3'", "RED", "Closed")
oBrowse:setDescription(STR0901)
oBrowse:DisableDetails()

If IsInCallStack("RU09T03RUS")
    cVATKey := F37->F37_KEY
    
    cQuery := " SELECT DISTINCT T0.F3B_BOOKEY AS BOOK_KEY FROM " + RetSQLName("F3B") + " AS T0 "
    cQuery += " JOIN " + RetSQLName("F3C") + " AS T1 ON ("
    cQuery += " T1.F3C_FILIAL = '" + xFilial("F3C") +"'"
    cQuery += " AND T1.F3C_KEY = '" + cVATKey + "'"
    cQuery += " AND T1.F3C_BOOKEY = T0.F3B_BOOKEY"
    cQuery += " ) "
    cQuery += " WHERE T0.F3B_FILIAL = '" + xFilial("F3B") +"'"
    cQuery += " AND T0.D_E_L_E_T_ = ' '"
	cQuery += " AND T1.D_E_L_E_T_ = ' '"
    cTab := MPSysOpenQuery(ChangeQuery(cQuery))

    While !(cTab)->(Eof())
        cBrowseFilter += "(F3B_BOOKEY=='" + (cTab)->BOOK_KEY + "') .and. "
        (cTab)->(DbSkip())
    EndDo
    CloseTempTable(cTab)
    // Cuts " .and. " from the end of the line of the Purchases Book Keys.
    If !Empty(cBrowseFilter)
        cBrowseFilter := SubStr(cBrowseFilter, 1, Len(cBrowseFilter)-7)
    Else
        cBrowseFilter := "F3B_BOOKEY=='" + Space(TamSX3("F3B_BOOKEY")[1]) + "'"
    EndIf

    oBrowse:setFilterDefault(cBrowseFilter)
EndIf

Return(oBrowse)

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defines the menu to Purchases VAT Books.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aButtons as Array

aButtons := {{STR0902, "FwExecView('" + STR0902 + "', 'RU09T05', " + STR(MODEL_OPERATION_VIEW) + ")", 0, 2, 0, Nil},;
		{STR0903, "FwExecView('" + STR0903 + "', 'RU09T05', " + STR(MODEL_OPERATION_INSERT) + ")", 0, 3, 0, Nil},;
		{STR0904, "FwExecView('" + STR0904 + "', 'RU09T05', " + STR(MODEL_OPERATION_UPDATE) + ")", 0, 4, 0, Nil},;
		{STR0905, "FwExecView('" + STR0905 + "', 'RU09T05', " + STR(MODEL_OPERATION_DELETE) + ")", 0, 5, 0, Nil},;
        {STR0054, "CTBC662", 0, 2, 0, Nil},; //"Track Posting"
        {STR0055,"RU09T05001_RETBOOK",0,7,0,Nil}}

Return(aButtons)
// The end of the Static Function MenuDef()

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Creates the model of Purchases VAT Books.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oModel as Object
Local oStructF3B as Object
Local oStructF3C as Object
Local oModelEvent as Object

oStructF3B := FWFormStruct(1, "F3B")
oStructF3C := FWFormStruct(1, "F3C")

oModel := MPFormModel():New("RU09T05", Nil, {|oModel| RU09T05MPost(oModel)}, {|oModel| ModelRec(oModel)}, /*bLoadModel*/)
oModel:setDescription(STR0901)

// This flag field plays role of the nonexistent method of the grid object ::IsChanged ? "*"-Yes : Nil-No
aAdd(oStructF3C:aFields, {"RecBsDiff", "ReclaimBaseDiff", "F3C_RBSDIF", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
aAdd(oStructF3C:aFields, {"RecVlDiff", "ReclaimValueDiff", "F3C_RVLDIF", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
aAdd(oStructF3C:aFields, {"OpVlDiff", "OpenValueDiff", "F3C_OPBSBU", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
aAdd(oStructF3C:aFields, {"OpVlDiff", "OpenValueDiff", "F3C_OPVLBU", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})

oModel:AddFields("F3BMASTER", Nil, oStructF3B, {|oModel, cAction, cField, xValue| RU09T05FPre(oModel, cAction, cField, xValue)})

oModel:AddGrid("F3CDETAIL",;
                "F3BMASTER",;
                oStructF3C,;
                {|oModel, nLinVld, cAction, cField, xValue, xOldValue| RU09T05DLPre(oModel, nLinVld, cAction, cField, xValue, xOldValue)},;
                /* bLinePost */,;
                /* bGridPre */,;
                /* bGridPost */)

oModel:GetModel("F3BMASTER"):setDescription(STR0901)

oModel:GetModel("F3CDETAIL"):setDescription(STR0906)
oModel:GetModel("F3CDETAIL"):setOptional(.T.)

oModel:setRelation("F3CDETAIL", {{"F3C_FILIAL", "xFilial('F3C')"}, {"F3C_BOOKEY", "F3B_BOOKEY"}, {"F3C_CODE", "F3B_CODE"}}, F3C->(IndexKey(4))) //IndexKey(1)
oModel:setPrimaryKey({"F3B_FILIAL", "F3B_BOOKEY"})
oModel:setActivate({|| RU09T05AAct(oModel)})

oModel:GetModel("F3CDETAIL"):setUniqueLine({"F3C_FILIAL", "F3C_KEY","F3C_VATCOD","F3C_VATCD2"})

oModelEvent := RU09T05EventRUS():New()
oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)

Return(oModel)
// The end of the Static Function ModelDef()



//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Creates the view of Purchases VAT Books.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStructF3B as Object
Local oStructF3C as Object

Local cCmpF3B as Character
Local cCmpF3C as Character
Local cCmpTotal as Character

// Defines which fields we don't need to show on the screen.
cCmpF3B := "F3B_BOOKEY;F3B_TOTAL "
cCmpF3C := "F3C_CODE  ;F3C_BOOKEY;F3C_KEY   ;" 
cCmpTotal := "F3B_TOTAL "

oModel := FwLoadModel("RU09T05")

oStructF3B := FWFormStruct(2, "F3B", {|x| !(AllTrim(x) $ cCmpF3B)})
oStructF3C := FWFormStruct(2, "F3C", {|x| !(AllTrim(x) $ cCmpF3C)})
oSturctTotal := FWFormStruct(2, "F3B", {|x| (AllTrim(x) $ cCmpTotal)})

If (INCLUI)
    // This field will be filled in while commiting and shown in other view cases.
    oStructF3B:RemoveField("F3B_CODE")
Else
    // User shouldn't have an option to change dates in saved books.
    oStructF3B:SetProperty("F3B_INIT", MVC_VIEW_CANCHANGE, .F.)
    oStructF3B:SetProperty("F3B_FINAL", MVC_VIEW_CANCHANGE, .F.)
EndIf

// If Book Status is Blocked or Closed. If it is an Automatic Purchases Book.
If (ALTERA) .and. ((F3B->F3B_STATUS == "2") .Or. (F3B->F3B_STATUS == "3") .or. (F3B->F3B_AUTO == "1"))
    oStructF3B:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
    oStructF3B:SetProperty('F3B_STATUS', MVC_VIEW_CANCHANGE, .T.)
    oStructF3B:SetProperty('F3B_CMNT', MVC_VIEW_CANCHANGE, .T.)
EndIf

oStructF3B:RemoveField("F3B_VRCMNT")

oStructF3C:SetProperty("F3C_DOC", MVC_VIEW_CANCHANGE, F3C_DOC_When())

oView := FWFormView():New()
oView:setModel(oModel)
oView:AddField("F3B_M", oStructF3B, "F3BMASTER")
oView:AddGrid("F3C_D", oStructF3C, "F3CDETAIL")
oView:AddField("F3B_T", oSturctTotal, "F3BMASTER")

oView:CreateHorizontalBox("HEADERBOX", 25)
oView:CreateHorizontalBox("ITEMBOX", 65)
oView:CreateHorizontalBox("TOTALBOX", 10)

oView:setOwnerView("F3B_M", "HEADERBOX")
oView:setOwnerView("F3C_D", "ITEMBOX")
oView:setOwnerView("F3B_T", "TOTALBOX")

// If Book is opened and non automatic and operation is Insertion or Update.
If (INCLUI) .or. ((F3B->F3B_STATUS == "1") .and. (F3B->F3B_AUTO == "2") .and. (ALTERA))
    oView:AddUserButton(STR0946, '', {|| RU09T05AInc(oModel)})
EndIf

oView:AddUserButton(STR0907, '', {|| RU09T05VAT(oModel)})
oView:AddUserButton(STR0908, '', {|| RU05VATInExp(oModel)})

oView:setCloseOnOk({|| .T.})

Return(oView)
// The end of the Static Function ViewDef()



//-----------------------------------------------------------------------
/*/{Protheus.doc} F3C_DOC_When
Function returns false, if key is not empty.
This function is used to prevent editing the Purchases VAT Invoice Document Number
after it has been filled once. Only line deletion is allowed for user.
@author Artem Kostin
@since 05/15/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function F3C_DOC_When()
Local lRet := .T.
Local oModel as Object

oModel := FWModelActive()
If (ValType(oModel) == "O") .and. (oModel:getId() == "RU09T05")
    lRet := Empty(oModel:GetModel("F3CDETAIL"):GetValue("F3C_KEY"))
EndIf

Return lRet
// The end of the Static Function F3C_DOC_When()



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05MPost
Handles fields changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T05MPost(oModel as Object)
Local lRet := .T.

Local cCode as Character

Local nLine as Numeric
Local nRecBsDiff as Numeric
Local nRecValDiff as Numeric

Local oModelF3C := oModel:GetModel("F3CDETAIL")
Local nOperation := oModel:GetOperation()

Local cNMBAlias := "PUBOOK"

Local lCanUpdateLine as Logical

If (nOperation == MODEL_OPERATION_INSERT)
    // Variables intialization.
    cCode := RU09D03NMB(cNMBAlias, Nil, xFilial("F3B"))
    If Empty(cCode)
        lRet := .F.
        Help("",1,"RU09T05MPost01",,STR0951 + cNMBAlias,1,0)
    EndIf

    If !oModel:GetModel("F3BMASTER"):LoadValue("F3B_CODE", cCode)
        lRet := .F.
        Help("",1,"RU09T05MPost_Code",,STR0927,1,0)
    EndIf
EndIf

If (nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)
    If lRet
        lCanUpdateLine := oModel:GetModel("F3CDETAIL"):CanUpdateLine()
        oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.F.)
        For nLine := 1 to oModelF3C:Length(.F.)
            oModelF3C:GoLine(nLine)

            // If the row is inserted and deleted. Or if the row is not inserted and is not deleted.
            If oModelF3C:IsInserted() == oModelF3C:IsDeleted()
                nRecBsDiff := 0
                nRecValDiff := 0

                // With one exception.
                If !oModelF3C:IsDeleted() .and. oModelF3C:IsUpdated()
                    nRecBsDiff := oModelF3C:GetValue("F3C_RECBAS") - oModelF3C:GetValue("F3C_RBSDIF")
                    nRecValDiff := oModelF3C:GetValue("F3C_VALUE") - oModelF3C:GetValue("F3C_RVLDIF")
                EndIf
            EndIf

            // If row is not inserted but deleted.
            If !oModelF3C:IsInserted() .and. oModelF3C:IsDeleted()
                nRecBsDiff := - oModelF3C:GetValue("F3C_RBSDIF")
                nRecValDiff := - oModelF3C:GetValue("F3C_RVLDIF")
            EndIf

            // If row is inserted and not deleted.
            If oModelF3C:IsInserted() .and. !oModelF3C:IsDeleted()
                nRecBsDiff := oModelF3C:GetValue("F3C_RECBAS")
                nRecValDiff := oModelF3C:GetValue("F3C_VALUE")
            EndIf

            lRet := lRet .and. oModelF3C:LoadValue("F3C_RBSDIF", nRecBsDiff)
            lRet := lRet .and. oModelF3C:LoadValue("F3C_RVLDIF", nRecValDiff)

            If !lRet
                Help("",1,"RU09T05MPost_LoadValue",,STR0927,1,0)
                Exit
            EndIf
        Next nLine
        oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(!lCanUpdateLine)
    EndIf // lRet
EndIf

Return(lRet)
// The end of the Static Function RU09T05MPost(oModelF3B)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05FPre
Handles grid's line changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T05FPre(oModelF3B as Object, cAction as Character, cField as Character, xValue)
Local lRet := .T.

Local oModel as Object
Local nLine as Numeric

oModel := FWModelActive()
oModelF3C := oModel:GetModel("F3CDETAIL")

If (cAction == "SETVALUE") .and. (cField == "F3B_FINAL")
    If (oModelF3B:GetValue("F3B_INIT") > xValue)
        lRet := .F.
        Help("",1,"RU09T05FPre01",,STR0948,1,0)
    EndIf

    If lRet
        For nLine := 1 to oModelF3C:Length()
            oModelF3C:GoLine(nLine)
            If !oModelF3C:IsDeleted() .and. (oModelF3C:GetValue("F3C_PDATE") > xValue)
                lRet := .F.
                Help("",1,"RU09T05FPre02",,STR0947+" "+oModelF3C:GetValue("F3C_DOC"),1,0)
                Exit
            EndIf
        Next nLine
    EndIf
EndIf

If (cAction == "SETVALUE") .and. (cField == "F3B_INIT")
    If (oModelF3B:GetValue("F3B_FINAL") < xValue)
        lRet := .F.
        Help("",1,"RU09T05FPre03",,STR0949,1,0)
    EndIf
EndIf
Return(lRet)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05DLPre
Handles grid's line changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T05DLPre(oModelF3C as Object, nLinVld as Numeric, cAction as Character, cField as Character, xValue, xOldValue)
// Logical routine flow control
Local lRet := .T.
// Stores reclaiming values
Local nRecBs as Numeric
Local nRecVal as Numeric
Local nRecRate as Numeric
Local nRecValTotal as Numeric
// Variables for SQL queries
Local cQuery as Character
Local cTab as Character
// Variables for certain filters
Local cVATKey as Character
Local cIntCodeList as Character
Local dFinalDate as Date
Local cFinalMonth as Character
// Variables to operate with Model
Local oModel as Object
Local nLine as Numeric
Local lCanUpdateLine as Logical
// Saves the line selected by user
Local aSaveRows as Array
Local nFocus := GetFocus()
// Variables to operate with View
Local oView as Object
//for right change F3C_ITEM on delete\undelete rows
Local nCurDelta as Numeric 
Local cVatCode as Character

If Type("lRecursion") == "U"
	Private lRecursion := .F.
EndIf

// Prevents prevalidation from recursion.
If (lRecursion == .T.)
    
Else
	lRecursion := .T.
    aSaveRows := FWSaveRows()

    // Variables initialization.
    nLine := 0

    cQuery := ""
    cTab := ""
    cIntCodeList := ""

    oModel := FWModelActive()
    If (ValType(oModel) != "O") .or. (oModel:getId() != "RU09T05")
        lRet := .F.
        Help("",1,"RU09T05DLPre01",,STR0910,1,0)
    EndIf

    // If it is the deletion of an empty line return Nil.
    If (cAction == "DELETE") .and. Empty(AllTrim(oModelF3C:getValue("F3C_KEY")))
        lRet := Nil

    ElseIf lRet .and. (cAction == "CANSETVALUE") .and. (cField == "F3C_DOC")
        If !Empty(AllTrim(oModelF3C:GetValue("F3C_KEY")))
            lRet := .F.
        EndIf

    // If user put something into the Doc. Num. field and pressed enter.
    ElseIf lRet .and. (cAction == "SETVALUE")  .and. (cField $ "F3C_KEY   |F3C_DOC   |")
        If (Empty(AllTrim(oModelF3C:GetValue("F3C_KEY"))) .and. (cField == "F3C_DOC"));
        .or. (cField == "F3C_KEY")

            dFinalDate := oModel:GetModel("F3BMASTER"):GetValue("F3B_FINAL")
            cFinalMonth := SubStr(DtoS(dFinalDate), 5, 2)
            // Finds VAT Invoice grouped items from the Balances table.
            cQuery := RU09T05_01getSQLquery(oModelF3C)
            // VAT Values, which are three years old and older, cannot be reclaimed.
            If (cField == "F3C_DOC")
                cQuery += " AND F32_DOC = '" + xValue + "' "
            ElseIf (cField == "F3C_KEY")
                cQuery += " AND F32_KEY = '" + xValue + "' "
            EndIf
            cQuery += " AND T0.F32_RDATE >= '" + DtoS(YearSub(oModel:GetModel("F3BMASTER"):GetValue("F3B_FINAL"), 3)) +"'"
            If (cFinalMonth $ "03|06|09|12")
                cQuery += " AND T0.F32_PDATE <= '" + DtoS(dFinalDate) + "'"
                cQuery += " AND T0.F32_RDATE <= '" + DtoS(DaySum(LastDay(dFinalDate), EXTRA_DAYS_AFTER_TAX_PERIOD)) + "'"   
            Else
                cQuery += " AND T0.F32_RDATE <= '" + DtoS(dFinalDate) + "'"    
            EndIf
            cQuery += RU09T05_02getSQLorderby()
            cTab := MPSysOpenQuery(ChangeQuery(cQuery))

            // If no Purchases VAT Invoices with such Document Number were found.
            If (cTab)->(Eof())
                lRet := .F.
                Help("",1,"RU09T05DLPre04",,STR0913,1,0)
            EndIf

            If lRet
                lRet := lRet .and. RU09T05F3C(oModelF3C, oModel:GetModel("F3BMASTER"), cTab, 100.00)
            EndIf

            CloseTempTable(cTab) // Deletes the temporary table.
        EndIf

    ElseIf lRet .and. (cAction == "SETVALUE") .and. (cField $ "F3C_RECBAS|F3C_VATPER|F3C_VALUE |") .and. !Empty(oModelF3C:GetValue("F3C_DOC"))
        // If user changes Reclaim Base, the Reclaim Value and Reclaim Percent will be changed proportionally.
        If (cField == "F3C_RECBAS")
            nRecBs := xValue
            // If user wants to reclaim the whole open balance, it can be a round error.
            // Here it is an attempt to avoid round error after multiplication and division.
            If (nRecBs = (oModelF3C:GetValue("F3C_OPBSBU") + oModelF3C:GetValue("F3C_RBSDIF")))
                nRecVal := oModelF3C:GetValue("F3C_OPVLBU") + oModelF3C:GetValue("F3C_RVLDIF")
            Else
                // Reclaim Value = Reclaim Base * Reclaim % Rate
                nRecVal := Round(xValue * oModelF3C:GetValue("F3C_VATRT") / 100.00, 2)
            EndIf
            // Reclaim % Rate = Reclaim Base / Open Base
            nRecRate := Round(xValue / oModelF3C:getValue("F3C_VATBS") * 100.00, 2)

        // If user changes Reclaim Percent, the Reclaim Value and Reclaim Base will be changed proportionally.
        ElseIf (cField == "F3C_VATPER")
            // Reclaim Base = Reclaim % Rate * Open Base
            nRecBs := Round(xValue * oModelF3C:getValue("F3C_VATBS") / 100.00, 2)
            nRecRate := xValue
            // Reclaim Value = Reclaim % Rate * Open Balance
            nRecVal := Round(xValue * oModelF3C:getValue("F3C_VATVL") / 100.00, 2)
            
        // If user changes Reclaim Value, the Reclaim Percent and Reclaim Base will be changed proportionally.
        ElseIf (cField == "F3C_VALUE")
            nRecVal := xValue
            If (nRecVal = (oModelF3C:GetValue("F3C_OPVLBU")+oModelF3C:GetValue("F3C_RVLDIF")))
                nRecBs := oModelF3C:GetValue("F3C_OPBSBU") + oModelF3C:GetValue("F3C_RBSDIF")
            Else
                // Reclaim Base = Open Base * Reclaim Value / Open Balance
                nRecBs := Round(xValue / oModelF3C:GetValue("F3C_VATRT") * 100.00, 2)
            EndIf
            // Reclaim % Rate = Reclaim Value / Open Balance
            nRecRate := Round(nRecBs / oModelF3C:getValue("F3C_VATBS") * 100.00, 2)
        EndIf
        // Checks, if user puts the value, which is out of borders.
        If (nRecBs > (oModelF3C:GetValue("F3C_OPBSBU") + oModelF3C:GetValue("F3C_RBSDIF"))) .or. (nRecBs > oModelF3C:GetValue("F3C_VATBS"))
            lRet := .F.
            Help("",1,"RU09T05DLPre02",,STR0928,1,0)
        EndIf
        // If everything is ok.
        If lRet
            oModelF3C:LoadValue("F3C_RECBAS", nRecBs)
            oModelF3C:LoadValue("F3C_VATPER", nRecRate)
            oModelF3C:LoadValue("F3C_VALUE", nRecVal)

            oModelF3C:LoadValue("F3C_OPBS", oModelF3C:GetValue("F3C_OPBSBU") + oModelF3C:GetValue("F3C_RBSDIF") - nRecBs)
            oModelF3C:LoadValue("F3C_OPBAL", oModelF3C:GetValue("F3C_OPVLBU") + oModelF3C:GetValue("F3C_RVLDIF") - nRecVal)
        EndIf
    EndIf

    // If user deletes or undeletes any line from automatic book, all lines must be deleted.
    If lRet .and. ((cAction == "DELETE") .or. (cAction == "UNDELETE")) .and. (oModel:GetModel("F3BMASTER"):GetValue("F3B_AUTO") == "1");
            .and. (!Empty(oModelF3C:GetValue("F3C_DOC"))) .and. (!Empty(oModelF3C:GetValue("F3C_KEY")))
        // Saves the VAT Key of the deleted line.
        cVATKey := oModelF3C:GetValue("F3C_KEY")
        nCurDelta := 0
        // Goes over all the grid.
        For nLine := 1 to oModelF3C:Length(.F.)
            oModelF3C:GoLine(nLine)
            // Deletes all lines related to this Purchases VAT Invoices.
            If (oModelF3C:GetValue("F3C_KEY") == cVATKey)
                // If action is deletion, line is not deleted yet and line was not changed before.
                If (cAction == "DELETE") .and. (!oModelF3C:IsDeleted())
                    nCurDelta--
                    oModelF3C:DeleteLine()
                // If action is restoring, line is deleted and line was changed before.
                ElseIf (cAction == "UNDELETE") .and. oModelF3C:IsDeleted()
                    oModelF3C:UnDeleteLine()
                    nCurDelta++
                EndIf
            Else
                lCanUpdateLine := oModel:GetModel("F3CDETAIL"):CanUpdateLine()
                oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.F.)
                oModelF3C:LoadValue("F3C_ITEM", StrZero(Val(oModelF3C:GetValue("F3C_ITEM")) + nCurDelta, TamSX3("F3C_ITEM")[1]))
                oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(!lCanUpdateLine)
            EndIf
        Next nLine
    EndIf

    If lRet .and. ((cAction == "DELETE") .or. (cAction == "UNDELETE"))
        cVATKey := AllTrim(oModelF3C:GetValue("F3C_KEY"))
        cVatCode := AllTrim(oModelF3C:GetValue("F3C_VATCOD"))
        nCurDelta := 0
        For nLine := 1 to oModelF3C:Length()
            oModelF3C:GoLine(nLine)
            If (AllTrim(oModelF3C:GetValue("F3C_KEY")) == cVATKey .and. AllTrim(oModelF3C:GetValue("F3C_VATCOD")) == cVatCode) 
                If (cAction == "DELETE") .and. (!oModelF3C:IsDeleted())
                    nCurDelta--
                ElseIf (cAction == "UNDELETE") .and. oModelF3C:IsDeleted()
                    nCurDelta++
                EndIf
            Else
                lCanUpdateLine := oModel:GetModel("F3CDETAIL"):CanUpdateLine()
                oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.F.)
                oModelF3C:LoadValue("F3C_ITEM", StrZero(Val(oModelF3C:GetValue("F3C_ITEM")) + nCurDelta, TamSX3("F3C_ITEM")[1]))
                oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(!lCanUpdateLine)
            EndIf
        Next nLine
    EndIf

    If lRet .and. ((cAction == "SETVALUE") .or. (cAction == "DELETE") .or. (cAction == "UNDELETE"))
        nRecValTotal := 0
        // Goes thought the grid and sums all values into the total.
        For nLine := 1 to oModelF3C:Length(.F.)
            // Calculates total. Sums not deleted lines and not empty values.
            If (cAction == "DELETE") .and. (nLine == nLinVld)
                Loop
            EndIf

            oModelF3C:GoLine(nLine)
            If ((!oModelF3C:IsDeleted()) .and. (!Empty(oModelF3C:GetValue("F3C_VALUE")) .or. (oModelF3C:GetValue("F3C_VALUE") != 0)));
            .or. ((cAction == "UNDELETE") .and. (nLine == nLinVld))
                nRecValTotal += oModelF3C:GetValue("F3C_VALUE")
            EndIf
        Next nLine
        // Puts the total sum into the field.
        oModel:GetModel("F3BMASTER"):LoadValue("F3B_TOTAL", nRecValTotal)
    EndIf

    FWRestRows(aSaveRows)

    If lRet .and. (cAction != "CANSETVALUE") .and. (cAction != "ISENABLE")
        // Refreshes the oView object
        oView := FwViewActive()
        If (oView != Nil) .and. (oView:GetModel():GetId() == "RU09T05")
            oView:Refresh()
            // Retores saved focus
            SetFocus(nFocus)
        EndIf
    EndIf
    
    lRecursion := .F.
EndIf // lRecursion == .T.
Return(lRet)
// The end of the Static Function RU09T05DLPre(oModelF3C)



//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelRec
Records Purchases Book model into the database.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ModelRec(oModel as Object)    // Full Model
Local lRet := .T.
Local nOperation as Numeric

Local oModelF3C as Object

Local nLine as Numeric

// Checks, if input argument is not an Object.
If ValType(oModel) != "O"
    lRet := .F.
    Help("",1,"RU09T05ModelRec08",,STR0910,1,0)
EndIf

// Checks, if operation code is defined.
nOperation := oModel:getOperation()
If ValType(nOperation) != "N"
    lRet := .F.
    Help("",1,"RU09T05ModelRec09",,STR0914,1,0)
EndIf

Begin Transaction
If lRet
    dbSelectArea("F37")
    F37->(dbSetOrder(3))
    oModelF3C := oModel:GetModel("F3CDETAIL")
    
    oModel:GetModel("F3CDETAIL"):SetNoDeleteLine(.F.)
    For nLine := 1 to oModelF3C:Length(.F.)
        oModelF3C:GoLine(nLine)
        // Gets rid out of empty lines.
        If ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)) .and. Empty(oModelF3C:GetValue("F3C_KEY"))
            oModelF3C:DeleteLine()
        EndIf

        // If line is deleted from the Purchases Book, the related VAT Invoice property "In autobook?" will be set "No".
        If ((nOperation == MODEL_OPERATION_DELETE) .or. ((oModel:GetModel("F3BMASTER"):GetValue("F3B_AUTO") == "1") .and. oModelF3C:IsDeleted())) .and. !Empty(oModelF3C:GetValue("F3C_KEY"))
            If F37->(dbSeek(xFilial("F37") + oModelF3C:GetValue("F3C_KEY")))
                RecLock("F37", .F.)
                    F37->F37_ATBOOK := "2"
                MsUnlock("F37")
            Else
                lRet := .F.
                Help("",1,"RU09T05ModelRec10",,STR0909 + "'" + oModelF3C:GetValue("F3C_KEY") + "'",1,0)
            EndIf
        EndIf
    Next nLine
    oModel:GetModel("F3CDETAIL"):SetNoDeleteLine(.T.)
//is delete call function
    If (nOperation == MODEL_OPERATION_DELETE) .And. lRet .and. F3B->F3B_STATUS=='3' .And. !Empty(F3B->F3B_DTLA)
        ctbVATpurb(oModel, .F. )            
    Endif 
    If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. lRet .and. oModel:GetModel("F3BMASTER"):GetValue("F3B_STATUS")=='3' .And. Empty(F3B->F3B_DTLA)
        oModel:GetModel("F3BMASTER"):SetValue("F3B_DTLA",dDataBase)         
    EndIf 
    // If everything is OK, commit the model.
    lRet := lRet .and. FWFormCommit(oModel)

//is insert call function
    If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. lRet .and. F3B->F3B_STATUS=='3'
        ctbVATpurb(oModel, .T. )        
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
    Help("",1,"RU09T05ModelRec",,STR0915,1,0)
    DisarmTransaction()
EndIf

End Transaction


// TODO: here should be an accounting postings update.
Return(lRet)
// The end of the Static Function ModelRec(oModel)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05AInc
@author Artem Kostin
@since 02/27/2018
@version 12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T05AInc(oModel as Object)
Local lRet := .T.

Local aParam as Array
Local aPerguntas as Array

Local oModelF3B as Object
Local oModelF3C as Object

Local nLine as Numeric
Local nRecValTotal as Numeric

Local cTab as Character
Local cQuery as Character
Local cFinalMonth as Character

// Initialisation of the variables.
aParam :={}
aPerguntas	:= {}
nLine := 1

cTab := ""
cQuery := ""

oModelF3B := oModel:GetModel("F3BMASTER")
oModelF3C := oModel:GetModel("F3CDETAIL")

// Questions to help user filter result of the autocomplete function.
// ?	Doc. No.: Purchase VAT Invoice Number.
aAdd(aPerguntas,{ 1, STR0916 + " " + STR0923, Space(TamSX3("F37_DOC")[1]),            "@!",'.T.',"F37DOC",".T.",60, .F.})
aAdd(aPerguntas,{ 1, STR0916 + " " + STR0924,   Replicate("z", TamSX3("F37_DOC")[1]),"@!",'.T.',"F37DOC",".T.",60, .F.})
// ?	Print Date: Purchase VAT Invoice Print Date.
aAdd(aPerguntas,{ 1, STR0917 + " " + STR0923, oModelF3B:GetValue("F3B_INIT"),    /*mask*/,'.T.',"",".T.",60, .F.}) // Not used in qeury.
aAdd(aPerguntas,{ 1, STR0917 + " " + STR0924,   oModelF3B:GetValue("F3B_FINAL"),/*mask*/,'.T.',"",".T.",60, .F.})
// ?	Supplier: Purchase VAT Invoice Supplier Code.
aAdd(aPerguntas,{ 1, STR0920 + " " + STR0923, Space(TamSX3("F37_FORNEC")[1]),          "@!",'.T.',"SA2",".T.",60, .F.})
aAdd(aPerguntas,{ 1, STR0921 + " " + STR0923, Space(TamSX3("F37_BRANCH")[1]),          "@!",'.T.',"",".T.",60, .F.})
// ?	Branch: Purchase VAT Invoice Supplier Branch.
aAdd(aPerguntas,{ 1, STR0920 + " " + STR0924, Replicate("z", TamSX3("F37_FORNEC")[1]),"@!",'.T.',"SA2",".T.",60, .F.})
aAdd(aPerguntas,{ 1, STR0921 + " " + STR0924, Replicate("z", TamSX3("F37_BRANCH")[1]),"@!",'.T.',"",".T.",60, .F.})
//      Preliminary VAT code.
aAdd(aPerguntas,{ 1, STR0952, Space(TamSX3("F38_VATCOD")[1]),          "@!",'.T.',"F31",".T.",60, .F.})
// ?	Reclaim %: Purchase VAT Invoice Reclaim %. The initial value must be 100%.
aAdd(aPerguntas,{ 1, STR0922, 100.00,                                                 "@999.99",'.T.',"",".T.",60, .F.})
//      Preliminary VAT code.

// Shows user a window with questions.
If !ParamBox(aPerguntas, STR0925, aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
    lRet := .F.
EndIf

If lRet
    cFinalMonth := SubStr(DtoS(aParam[4]), 5, 2)
    // Select from Invoices.
    cQuery := RU09T05_01getSQLquery(oModelF3C)
    If !Empty(aParam[9])
        cQuery += " AND T0.F32_VATCOD = '" + aParam[9] + "'"
    EndIf
        // VAT Values, which are three years old and elder, cannot be reclaimed.
    cQuery += " AND T0.F32_DOC BETWEEN '" + aParam[1] + "' AND '" + aParam[2] + "'"
    cQuery += " AND T0.F32_RDATE >= '" + DtoS(YearSub(aParam[4], 3)) +"'"
    If (cFinalMonth $ "03|06|09|12")
        cQuery += " AND T0.F32_PDATE <= '" + DtoS(aParam[4]) + "'"
        cQuery += " AND T0.F32_RDATE <= '" + DtoS(DaySum(LastDay(aParam[4]), EXTRA_DAYS_AFTER_TAX_PERIOD)) + "'"   
    Else
        cQuery += " AND T0.F32_RDATE <= '" + DtoS(aParam[4]) + "'"    
    EndIf
    cQuery += " AND	T0.F32_SUPPL BETWEEN '" + aParam[5] + "' AND '" + aParam[7] + "'"
    cQuery += " AND	T0.F32_SUPUN BETWEEN '" + aParam[6] + "' AND '" + aParam[8] + "'"
    cQuery += RU09T05_02getSQLorderby()
    cTab := MPSysOpenQuery(ChangeQuery(cQuery))

    lRet := lRet .and. RU09T05F3C(oModelF3C, oModelF3B, cTab, aParam[10])
    nRecValTotal := 0
    // Goes thought the grid and sums all values into the total.
    For nLine := 1 to oModelF3C:Length(.F.)
        oModelF3C:GoLine(nLine)
        // Calculates total. Sums not deleted lines and not empty values.
        If (!oModelF3C:IsDeleted()) .and. (!Empty(oModelF3C:GetValue("F3C_VALUE")) .or. !oModelF3C:GetValue("F3C_VALUE") == 0)
            nRecValTotal += oModelF3C:GetValue("F3C_VALUE")
        EndIf
    Next nLine
    // Puts the total sum into the field.
    oModel:GetModel("F3BMASTER"):LoadValue("F3B_TOTAL", nRecValTotal)
    oModelF3C:GoLine(1)

    // Refreshes the oView object
    oView := FwViewActive()
    If (oView != Nil) .and. (oView:GetModel():GetId() == "RU09T05")
        oView:Refresh()
    EndIf
EndIf

CloseTempTable(cTab)
Return(lRet)
// The end of the Function RU09T05AInc(oModel)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU05VATInExp
@author Artem Kostin
@since 02/28/2018
@version 12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU05VATInExp(oModel)
Local lRet := .T.
Local cArq as Character

Local nHandle as Numeric

cArq := cGetFile("File CSV | *.csv", "File .CSV", 1, "C:\", .F., GETF_LOCALHARD, .F., .T.)

If (!Empty(cArq))
	nHandle := FCreate(cArq)
	
	If !(nHandle == -1)
		Processa({|| gravaReg(@nHandle,oModel)}, STR0933, STR0934, .F.)

		FClose(nHandle)

        Help("",1,"RU05VATInExp01",,STR0930,1,0)
	Else
        lRet := .F.
        Help("",1,"RU05VATInExp02",,STR0931,1,0)
	EndIf
EndIf

Return(lRet)
// The end of the Function RU05VATInExp



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
Local aAreaF3C as Array

Local aStructF3B as Array
Local aStructF3C as Array

Local oModelF3C as Object 
Local oModelF3B as Object

Local nI as Numeric

Local cString as Character
Local cBookKey as Character
Local cFilF3B as Character
Local cFilF3C as Character

aArea := GetArea()
aAreaF3C := F3C->(GetArea())
aAreaF3B := F3B->(GetArea())

aStructF3C := F3C->(DbStruct())
aStructF3B := F3B->(DbStruct())

oModelF3B := oModel:GetModel("F3BMASTER")

cString := ""
cFilF3B := xFilial("F3B")
cFilF3C := xFilial("F3C")
cBookKey := oModelF3B:GetValue("F3B_BOOKEY")

DbSelectArea("F3B")
F3B->(DbSetOrder(1))
F3B->(DbGoTop())

DbSelectArea("F3C")
F3C->(DbSetOrder(4)) //2
F3C->(DbGoTop())

If F3B->(DbSeek(cFilF3B+cBookKey))
    // Writes the titles of the header data.
    For nI := 1 To Len(aStructF3B)
        cString += AllTrim(Posicione("SX3", 2, aStructF3B[nI, 1], "X3Titulo()"))  +  ";"                                                   
    Next nI
	FWrite(nHandle, cString + CRLF)

    // Writes the header data.
	While (!F3B->(Eof()))
        If (F3B->(F3B_FILIAL+F3B_BOOKEY) == cFilF3B+cBookKey)
            cString := ""
            For nI := 1 To Len(aStructF3B)
                // If the type is numeric.
                If (aStructF3B[nI, 2] == "N")
                    cString += StrTran(STR(&("F3B->"+aStructF3B[nI, 1])),'.',',') + ";"
                // If the type is date.
                ElseIf (aStructF3B[nI , 2] == "D")
                    cString += CHR(160) + DtoC(&("F3B->"+aStructF3B[nI, 1])) + ";"
                // The other else types.
                Else 
                    cString += CHR(160) + &("F3B->"+aStructF3B[nI, 1]) + ";"
                EndIf
            Next nI
            FWrite(nHandle, cString + CRLF)
            IncProc(STR0934 + StrZero(nI, 10))
        EndIf
		F3B->(DbSkip())
	EndDo
    
    If F3C->(DbSeek(cFilF3C+cBookKey))
        // Reinitialise of the input data.
        cString := ""
        // Writes the titles of the details data.
        For nI := 1 To Len(aStructF3C)
            cString += AllTrim(Posicione("SX3", 2, aStructF3C[nI, 1], "X3Titulo()")) + ";" 
        Next nI
        FWrite(nHandle, cString + CRLF)

        // Writes the details data
        While !F3C->(Eof())
            If F3C->(F3C_FILIAL+F3C_BOOKEY) == cFilF3C+cBookKey
                cString := ""
                For nI := 1 To Len(aStructF3C)
                    // If the type is numeric.
                    If aStructF3C[nI, 2] == "N"
                        cString += StrTran(STR(&("F3C->"+aStructF3C[nI, 1])),'.',',')  + ";"
                    // If the type is date.
                    ElseIf aStructF3C[nI, 2] == "D"
                        cString += CHR(160) + DtoC(&("F3C->"+aStructF3C[nI, 1])) + ";"
                    // The other else types.
                    Else 
                        cString += CHR(160) + &("F3C->"+aStructF3C[nI, 1]) + ";"
                    EndIf
                Next nI
                FWrite(nHandle, cString + CRLF)
                IncProc(STR0934 + StrZero(nI, 10))
            EndIf
            F3C->(DbSkip())
        EndDo
    EndIf
EndIf

RestArea(aAreaF3B)
RestArea(aAreaF3C)
RestArea(aArea)

oModel:GetModel("F3CDETAIL"):GoLine(1)
Return(.T.)
// The end of the Function gravaReg



/*/{Protheus.doc} RU09T05VAT
@author Artem Kostin
@since 07/03/2018
@version 1.0
@type function
/*/
Static Function RU09T05VAT(oModel)
Local lRet := .T.
Local aAreaF37 as Array
Local oModelInvc as Object
Local cKey as Character

aAreaF37 := getArea()
oModelInvc := oModel:GetModel('F3CDETAIL')
cKey := AllTrim(oModelInvc:GetValue("F3C_KEY"))

If !Empty(cKey)
	dbSelectArea('F37') 
	F37->(DbSetOrder(3))
	If F37->(DbSeek(xFilial('F37') + cKey))
		FWExecView(STR0009, "RU09T03", MODEL_OPERATION_VIEW, , {|| .T.})
    Else
        lRet := .T.
        Help("",1,"RU09T05VAT01",,STR0909 + cKey,1,0)
	EndIf
	RestArea(aAreaF37)
EndIf
oModelInvc:GoLine(1)
Return(lRet)



/*/{Protheus.doc} RU09T05AAct
Function performs actions before model is shown to user, but after its activation,
to prepare some specifics:
    1. fill auxiliary fields in the grid
@author Artem Kostin
@since 14/03/2018
@version 1.0
@type function
/*/
Static Function RU09T05AAct(oModel)
Local lRet := .T.
Local nLine as Numeric
Local nOperation as Numeric

Local oModelF3C as Object

nOperation := oModel:GetOperation()

If ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE))
    nLine := 0

    oModelF3C := oModel:GetModel("F3CDETAIL")

    For nLine := 1 to oModelF3C:Length(.F.)
        oModelF3C:GoLine(nLine)
        lRet := lRet .and. oModelF3C:LoadValue("F3C_RBSDIF", oModelF3C:GetValue("F3C_RECBAS"))
        lRet := lRet .and. oModelF3C:LoadValue("F3C_RVLDIF", oModelF3C:GetValue("F3C_VALUE"))
        lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBSBU", oModelF3C:GetValue("F3C_OPBS"))
        lRet := lRet .and. oModelF3C:LoadValue("F3C_OPVLBU", oModelF3C:GetValue("F3C_OPBAL"))

        If !lRet
            Help("",1,"RU09T05AAct",,STR0927,1,0)
            Exit
        EndIf
    Next nLine
EndIf

// If Book Status is Blocked or Closed.
If (nOperation == MODEL_OPERATION_UPDATE) .and. ((F3B->F3B_STATUS == "2") .Or. (F3B->F3B_STATUS == "3"))
    oModel:GetModel("F3CDETAIL"):SetNoInsertLine(.T.)
    oModel:GetModel("F3CDETAIL"):SetNoDeleteLine(.T.)
    oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.T.)
EndIf
// If it is an Automatic Purchases Book.
If (nOperation == MODEL_OPERATION_UPDATE) .and. (F3B->F3B_AUTO == "1")
    oModel:GetModel("F3CDETAIL"):SetNoInsertLine(.T.)
    oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.T.)
EndIf

Return(lRet)



Function RU09T05F3C(oModelF3C as Object, oModelF3B as Object, cTab as Character, nUserRate as Numeric)
Local lRet := .T.
Local lAddLine := .T.
// Local variables to store the common codes.
Local cBookCode as Character
Local cBookKey as Character

Local nLine as Numeric
Local nRecRate as Numeric

Local cTargCode As Char
Local cStartDate as Character
Local cEndDate as Character
Local aSheetNrs as Array
Local nTmpMaxNr as Numeric
Local nCnt as Numeric

aSheetNrs := {}

cBookCode := oModelF3B:GetValue("F3B_CODE")
cBookKey := oModelF3B:GetValue("F3B_BOOKEY")

// If there is no empty line, add new line and push new data to the bottom of the grid.
// If there is already an empty line, data could be inserted starting from this empty line.
lAddLine :=  !Empty(AllTrim(oModelF3C:GetValue("F3C_KEY")))

// Loading new data selected by query at the end of the grid.
While !(cTab)->(Eof()) .AND. lRet == .T.
    If lAddLine
        nLine := oModelF3C:AddLine()
    Else
        nLine := oModelF3C:Length(.F.)
        lAddLine := .T.
    EndIf
    
    nRecRate := min((cTab)->OPEN_BASE / (cTab)->INIT_BASE * 100.00, nUserRate)

    lRet := lRet .and. oModelF3C:LoadValue("F3C_FILIAL", xFilial("F3C"))
    lRet := lRet .and. oModelF3C:LoadValue("F3C_CODE", cBookCode)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_BOOKEY", cBookKey)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_ITEM", StrZero(nLine, GetSX3Cache("F3C_ITEM", "X3_TAMANHO")))  // Number of the line in the Reclaim details table.
    lRet := lRet .and. oModelF3C:LoadValue("F3C_KEY", (cTab)->VAT_KEY)	// Purchase VAT Invoice Key.
    lRet := lRet .and. oModelF3C:LoadValue("F3C_DOC", (cTab)->DOC_NUM)	// Purchase VAT Invoice Document Number.
    lRet := lRet .and. oModelF3C:LoadValue("F3C_PDATE", StoD((cTab)->PRINT_DATE)) // Purchase VAT Invoice Print Date
    lRet := lRet .and. oModelF3C:LoadValue("F3C_VATCOD", (cTab)->INTCODE) // Purchase VAT Invoice Internal Code.
    lRet := lRet .and. oModelF3C:LoadValue("F3C_VATCD2", (cTab)->EXTCODE) // Purchase VAT Invoice External (Operational) Code.
    lRet := lRet .and. oModelF3C:LoadValue("F3C_VATPER", nRecRate) // Percentage of Reclaim Base Value, which will be written off.
    // If user's rate is 100%, copy values from SQL query to avoid precision errors.
    If (nUserRate > nRecRate) .or. (nUserRate == 100.00)
        lRet := lRet .and. oModelF3C:LoadValue("F3C_RECBAS", (cTab)->OPEN_BASE) // Reclaim Base Value.
        lRet := lRet .and. oModelF3C:LoadValue("F3C_VALUE", (cTab)->OPEN_BALANCE) // Reclaim Value = Reclaim Base * Reclaim Percents
        lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBAL", 0) // Purchase VAT Invoice Tax Value ready for reclaim or Reclaim.
        lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBS", 0) // Purchase VAT Invoice Tax Value ready for reclaim or Reclaim.
    Else
        lRet := lRet .and. oModelF3C:LoadValue("F3C_RECBAS", nRecRate * (cTab)->INIT_BASE / 100) // Reclaim Base Value.
        lRet := lRet .and. oModelF3C:LoadValue("F3C_VALUE", nRecRate * (cTab)->INIT_VALUE / 100) // Reclaim Value = Reclaim Base * Reclaim Percents
        lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBAL", (cTab)->OPEN_BALANCE - nRecRate * (cTab)->INIT_VALUE / 100) // Purchase VAT Invoice Tax Value ready for reclaim or Reclaim.
        lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBS", (cTab)->OPEN_BASE - nRecRate * (cTab)->INIT_BASE / 100) // Purchase VAT Invoice Tax Value ready for reclaim or Reclaim.
    EndIf
    // Temporary fields to control restrictions.
    lRet := lRet .and. oModelF3C:LoadValue("F3C_RBSDIF", 0)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_RVLDIF", 0)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBSBU", (cTab)->OPEN_BASE)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_OPVLBU", (cTab)->OPEN_BALANCE)
    // Virtual fields to inform user.
    lRet := lRet .and. oModelF3C:LoadValue("F3C_VATBS", (cTab)->INIT_BASE) // Purchase VAT Invoice Initial Base
    lRet := lRet .and. oModelF3C:LoadValue("F3C_VATRT", (cTab)->VAT_RATE)  // Purchase VAT Invoice Tax Rate
    lRet := lRet .and. oModelF3C:LoadValue("F3C_VATVL", (cTab)->INIT_VALUE) // Purchase VAT Invoice Initial Tax Value
    // Last line will always exist and be empty for new user inputs.

    lRet := lRet .and. oModelF3C:LoadValue("F3C_CNOR_C", (cTab)->F37_CNOR_C)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_CNOR_B", (cTab)->F37_CNOR_B)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_CNEE_C", (cTab)->F37_CNEE_C)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_CNEE_B", (cTab)->F37_CNEE_B)
    
    lRet := lRet .and. oModelF3C:LoadValue("F3C_ADJNR", (cTab)->F37_ADJNR)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_ADJDT", SToD((cTab)->F37_ADJDT))
    lRet := lRet .and. oModelF3C:LoadValue("F3C_NAME", SubStr((cTab)->SHORTNAME, 1, TamSX3("F3C_NAME")[1]))
    lRet := lRet .and. oModelF3C:LoadValue("F3C_SUPPL", (cTab)->SUPPL)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_SUPUN", (cTab)->SUPUN)
    lRet := lRet .and. oModelF3C:LoadValue("F3C_INVCUR", (cTab)->F37_INVCUR)

    lRet := lRet .and. oModelF3C:LoadValue("F3C_ADSHNR", 0)

    If Empty((cTab)->F31_TG_COD)
        If (F31->F31_TYPE) == "1"
            lRet = .F.
            Help("",1,"RU09T05F3C:00",,STR0956,1,0)
        ElseIf (F31->F31_TYPE) == "2"
            cTargCode := F31->F31_CODE
        EndIf
    Else
        cTargCode := (cTab)->F31_TG_COD
    EndIf

    lRet := lRet .And. oModelF3C:LoadValue("F3C_TG_COD", AllTrim(cTargCode))

    // functionality will be required in the next release
    /*cStartDate := AllTrim(RU09T05GetQD(FWFldGet("F3B_INIT"))[1])
    If SToD((cTab)->PRINT_DATE) < SToD(cStartDate)
        //get search period for number
        aPeriod := RU09T05GetQD(Stod( (cTab)->PRINT_DATE))
        cStartDate := AllTrim(aPeriod[1])
        cEndDate := AllTrim(aPeriod[2])

        //get exist numbers in saved and added rows. if exist set max num, else create new num = max + 1
        cQuery := "SELECT Max(F3C.F3C_ADSHNR) as F3C_ADSHNR "
        cQuery += "FROM " + RetSQLName("F3C") + " F3C "
        cQuery += "WHERE F3C.F3C_PDATE >= '"+ cStartDate + "' AND F3C.F3C_PDATE < '" + cEndDate + "' AND "
        cQuery += "F3C.D_E_L_E_T_ = ' ' AND "
        cQuery += "F3C.F3C_FILIAL = '" + xFilial("F3C") + "' AND F3C.F3C_CODE = '" + FWFldGet("F3B_CODE") + "' "

        cQueryRes := MPSysOpenQuery(cQuery)

        nTmpMaxNr := 0
        For nCnt := 1 To Len(aSheetNrs) Step 1
            If aSheetNrs[nCnt][1] >= STOD(cStartDate) .AND. aSheetNrs[nCnt][1] < STOD(cEndDate) .AND. nTmpMaxNr < aSheetNrs[nCnt][2]
                nTmpMaxNr := aSheetNrs[nCnt][2]
            EndIf
        Next

        If (cQueryRes)->F3C_ADSHNR > 0 .Or. nTmpMaxNr > 0
            lRet := lRet .and. oModelF3C:LoadValue("F3C_ADSHNR", Max((cQueryRes)->F3C_ADSHNR, nTmpMaxNr)) 
        Else
            cQuery := "SELECT Max(F3C.F3C_ADSHNR) as F3C_ADSHNR "
            cQuery += "FROM " + RetSQLName("F3C") + " F3C "
            cQuery += "WHERE F3C.F3C_PDATE >= '"+ cStartDate + "' AND F3C.F3C_PDATE < '" + cEndDate + "' AND "
            cQuery += "F3C.D_E_L_E_T_ = ' ' AND "
            cQuery += "F3C.F3C_FILIAL = '" + xFilial("F3C") + "' "
            cQueryRes := MPSysOpenQuery(cQuery)

            lRet := lRet .and. oModelF3C:LoadValue("F3C_ADSHNR", Max((cQueryRes)->F3C_ADSHNR, nTmpMaxNr) + 1)
            AAdd(aSheetNrs, {Stod( (cTab)->PRINT_DATE), Max((cQueryRes)->F3C_ADSHNR, nTmpMaxNr) + 1})
        EndIf 
    EndIf*/
    

    (cTab)->(DbSkip())
EndDo

If !lRet
    Help("",1,"RU09T05F3C:01",,STR0927,1,0)
EndIf
Return(lRet)



Function RU09T05Name()
Local cName := ""
Local cKey := ""
Local aArea := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaF37 := F37->(GetArea())
 
DbSelectArea("F37")
F37->(DbSetOrder(3))
If (F37->(DbSeek(xFilial("F37") + F3C->F3C_KEY)))
    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    cKey := F37->(F37_FORNEC + F37_BRANCH)
    If !Empty(AllTrim(cKey)) .and. (SA2->(DbSeek(xFilial("SA2") + cKey)))
        cName := SA2->A2_NREDUZ
    EndIf
EndIf
 
RestArea(aAreaF37)
RestArea(aAreaSA2)
RestArea(aArea)
Return(cName)


/*/
@author: Ruslan Burkov
@description: return start and and dates of quarter by data
/*/
Function RU09T05GetQD(dData) 
	Local nMonth as Numeric
	Local cStartDate as Character
	Local cEndDate as Character
	Local aRet as Array

	nMonth := Month(dData) 
	If nMonth >= 1 .and. nMonth <= 9
		If nMonth <= 3
			nMonth := 1
		ElseIf nMonth <= 6
			nMonth := 4
		Else
			nMonth := 7
		EndIf
		cStartDate := AllTrim(Str(Year(dData))) + StrZero(nMonth, 2) + "01"
		cEndDate :=  AllTrim(Str(Year(dData))) + StrZero(nMonth + 3, 2) + "01"  // end not include!
		aRet := {cStartDate, cEndDate}
	ElseIf nMonth >= 10 .and. nMonth <= 12
		nMonth := 10
		cStartDate := Str(Year(dData)) + StrZero(nMonth, 2) + "01"
		cEndDate := Str(Year(dData) + 1) + "0101" // end not include!
		aRet := {cStartDate, cEndDate}
	EndIf

Return aRet



/*{Protheus.doc} RU09T05_01getSQLquery
It is an attempt to generalize common things.
@author Artem Kostin
@since 01/28/2019
@version P12.1.23
@type function
*/
Function RU09T05_01getSQLquery(oModelF3C as Object)
Local cQuery as Character
Local nLine as Numeric

cQuery := " SELECT T0.F32_KEY AS VAT_KEY,"
cQuery += " T0.F32_DOC AS DOC_NUM,"
cQuery += " T0.F32_VATCOD AS INTCODE,"
cQuery += " T0.F32_VATCD2 AS EXTCODE,"
cQuery += " T0.F32_INIBS AS INIT_BASE,"
cQuery += " T0.F32_INIBAL AS INIT_VALUE,"
cQuery += " T0.F32_OPBS AS OPEN_BASE,"
cQuery += " T0.F32_OPBAL AS OPEN_BALANCE,"
cQuery += " T0.F32_PDATE AS PRINT_DATE,"
cQuery += " T0.F32_VATRT AS VAT_RATE,"
cQuery += " T1.F37_CNEE_B,"
cQuery += " T1.F37_CNOR_C,"
cQuery += " T1.F37_CNOR_B,"
cQuery += " T1.F37_CNEE_C,"
cQuery += " T1.F37_ADJNR," 
cQuery += " T1.F37_ADJDT,"
cQuery += " T0.F32_SUPPL AS SUPPL," 
cQuery += " T0.F32_SUPUN AS SUPUN," 
cQuery += " T2.A2_NOME AS SHORTNAME,"
cQuery += " T1.F37_INVCUR, "
cQuery += " T3.F31_TG_COD "
cQuery += " FROM " + RetSQLName("F32") + " AS T0 "
cQuery += " LEFT JOIN " + RetSQLName("F37") + " T1"
cQuery += " ON T1.F37_FILIAL  = '" + xFilial("F37") + "'"
cQuery += " AND T1.D_E_L_E_T_ = ' '"
cQuery += " AND T1.F37_KEY = T0.F32_KEY"
cQuery += " LEFT JOIN " + RetSQLName("SA2") + " T2" 
cQuery += " ON T2.A2_FILIAL = '" + xFilial("SA2") + "'"
cQuery += " AND T2.D_E_L_E_T_ = ' '" 
cQuery += " AND T2.A2_COD = T0.F32_SUPPL" 
cQuery += " AND T2.A2_LOJA = T0.F32_SUPUN"
cQuery += " LEFT JOIN " + RetSQLName("F31") + " T3" 
cQuery += " ON T3.F31_FILIAL = '" + xFilial("F31") + "' "
cQuery += " AND T3.D_E_L_E_T_ = ' '"
cQuery += " AND T0.F32_VATCOD = T3.F31_CODE"
cQuery += " WHERE T0.F32_FILIAL = '" + xFilial("F32") + "' "
cQuery += " AND T0.D_E_L_E_T_ = ' '"
cQuery += " AND T0.F32_OPBS > 0"
// Goes thought the grid and collects list of Doc Numbers, which are already in the Model.
// Lines marked as deleted must be counted too, because user can undelete them.
For nLine := 1 to oModelF3C:Length(.F.)
    oModelF3C:GoLine(nLine)
    If !Empty(AllTrim(oModelF3C:GetValue("F3C_KEY")))
        // Adds conditions to exclude the records, which are already in the model, from SQL query.
        cQuery += " AND NOT ("
        cQuery += " T0.F32_KEY = '" + oModelF3C:GetValue("F3C_KEY") + "'" 
        cQuery += " AND T0.F32_VATCOD = '" + oModelF3C:GetValue("F3C_VATCOD") + "'"
        cQuery += " )"
    EndIf
Next nLine

Return(cQuery)



/*{Protheus.doc} RU09T05_02getSQLorderby
It is an attempt to generalize common things.
@author Artem Kostin
@since 01/28/2019
@version P12.1.23
@type function
*/
Function RU09T05_02getSQLorderby()
Local cQuery as Character
cQuery := " ORDER BY T0.F32_FILIAL"
cQuery += " ,T0.F32_SUPPL"
cQuery += " ,T0.F32_SUPUN"
cQuery += " ,T0.F32_DOC"
cQuery += " ,T0.F32_RDATE"
cQuery += " ,T0.F32_KEY"
cQuery += " ,T0.F32_VATCOD"
cQuery += " ,T0.F32_VATCD2"
Return(cQuery)


Function RU09T05CTL_View()
Local oModel as Object

oModel:= FwLoadModel("RU09T05")
oModel:SetOperation(MODEL_OPERATION_VIEW)
oModel:Activate()

FwExecView(STR0902, "RU09T05", MODEL_OPERATION_VIEW,/* oDlg */, /*{|| .T.}*/,/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)

Return
/*/{Protheus.doc} RU09T05001_RETBOOK
Function thats storno accounting entries.
@author Sergeeva Daria
@since 10/01/2020
@version P12.1.16
@param oModel, object, Needs to receive the actual model.
@param lInc, logical, Needs to inform it is an inclusion or not.
@type function
/*/
Function RU09T05001_RETBOOK()
Local oModel as Object
Local lEnt as Logical

lEnt:=.F.
DbSelectArea('F3B')
DbSetOrder(1)

oModel:= FwLoadModel("RU09T05")
oModel:SetOperation(4)
oModel:Activate()

Begin Transaction
If F3B->F3B_STATUS=="3" .And. !Empty(F3B->F3B_DTLA)
    ctbVATpurb(oModel,lEnt) 
    FwFldPut('F3B_STATUS','1',,,,.T.)//oModelF3B:LoadValue("F3B_STATUS","1") //oModelF3B:SetValue("F3B_STATUS","1") 
    oModel:GetModel("F3BMASTER"):SetValue("F3B_DTLA",stod(""))         
EndIf
If oModel:VldData() 
    oModel:CommitData()
Else
     DisarmTransaction()   
EndIf
End Transaction
Return
/*/{Protheus.doc} ctbVATpurb
Function thats posts accounting entries.
@author Sergeeva Daria
@since 10/01/2020
@version P12.1.16
@param oModel, object, Needs to receive the actual model.
@param lInc, logical, Needs to inform it is an inclusion or not.
@type function
/*/

Static Function ctbVATpurb(oModel as Object, lInc as Logical)
Local lRet as Logical
Local oModelF3B as Object
Local oModelF3C as Object
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
oModelF3B := oModel:GetModel("F3BMASTER")
oModelF3C := oModel:GetModel("F3CDETAIL")
nTotal := 0
aArea := GetArea()
aAreaF37 := F37->(GetArea())
aAreaF38 := F38->(GetArea())
aAreaSF1 := SF1->(GetArea())
aAreaSA2 := SA2->(GetArea())
cPerg := "RU09T05ACC"
nOperation:=oModel:GetOperation()
Pergunte(cPerg, .F.)
lMostra := (mv_par01 == 1)
lAglutina := (mv_par02 == 1)

nHdlPrv := 0
cLoteFis := LoteCont("FIS")
cOrigem := "RU09T05ACC"
cArquivo := " "
lCommit := .F.
// If it is an inclusion, must be used the Standard Entry 6AE to the header.
// If it is a deletion, must be used the Standard Entry 6AF to the header.
cPadrao := Iif(lInc, "6AE", "6AF")
If VerPadrao(cPadrao) // Accounting beginning
    nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)    
EndIf

//Seek oon F3C
DbSelectArea("F3C")
F3C->(DbSetOrder(2))
If(F3C->(DbSeek(xFilial("F3C")+oModelF3B:GetValue("F3B_BOOKEY"))))
    //While KEY on F3C is equal to key
    While (F3C->(!Eof())) .And. (xFilial("F3C")+oModelF3B:GetValue("F3B_BOOKEY"))==F3C->(F3C_FILIAL+F3C_BOOKEY)
        DbSelectArea("F37")
        F37->(DbSetOrder(7))
        If(F37->(DbSeek(xFilial("F37")+oModelF3C:GetValue("F3C_DOC"))))
            DbSelectArea("SF1")
            SF1->(DbSetOrder(1))
            If (F37->F37_TYPE == "2") .and. !(SF1->(DbSeek(xFilial("SF1") + SubStr(F37->F37_INVDOC, 1, TamSX3("F1_DOC")[1]) + SubStr(F37->F37_INVSER, 1, TamSX3("F1_SERIE")[1]))))
                lRet := .F.
            EndIf
            
            If lRet
                DbSelectArea("SA2")
                SA2->(DbSetOrder(1))
                If !SA2->(DbSeek(xFilial("SA2") + F37->F37_FORNEC + F37->F37_BRANCH))
                    lRet:= .F.
                EndIf
            EndIf
        Else
            Help("",1,"RU09T05_ctbVATpurb_F37",,STR0023,1,0) // "VAT Sales Invoice Header of this record was not found. Cannot delete this record."
            lRet:= .F.
        EndIf
                       

        If (nHdlPrv > 0) .And. lRet
            nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, xFilial("F3B") + F3B->F3B_BOOKEY /*cChaveBusca */, ;
            /*aCT5*/,/*lPosiciona*/, /*@aFlagCTB*/, {'F3B',F3B->(Recno())} /*aTabRecOri*/, /*aDadosProva*/)
            
            //Updates the posting date.
            RecLock("F3B", .F.)
            F3B->F3B_DTLA := dDataBase
            F3B->(MsUnlock())
            
            // Updates the Outflow Document Status for Russia. 
            //If it is an inclusion needs to set "2" and if it is a deletion needs to set "1".
            RecLock("SF1", .F.)
            SF1->F1_STATUSR := Iif(lInc, "2", "1")
            SF1->(MsUnlock())

        EndIf            
        F3C->(DbSkip())
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