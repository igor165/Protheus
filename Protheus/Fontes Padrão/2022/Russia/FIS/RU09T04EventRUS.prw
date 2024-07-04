#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'RU09T08.ch'
#Include "RU09T04.ch"
#include 'RU09XXX.ch'


/*{Protheus.doc} RU09T04EventRUS
@type 		class
@author Artem Kostin
@since 13/08/2018
@version 	P12.1.21
@description Class to handle business procces of RU09T04
*/
Class RU09T04EventRUS From FwModelEvent
	Method New() CONSTRUCTOR
    Method ModelPosVld()
    Method GridLinePreVld()
    Method GridLinePosVld()
    Method R09T4AInc(oModel)
    Method Activate(oModel, lCopy)

    Method RfrshF39Ttl(nValDiff)
    Method FillF3ATable(oSubModel, cTab)
EndClass


Method Activate(oModel, lCopy) Class RU09T04EventRUS
    Local lRet := .T.

    If (oModel:GetOperation()<>MODEL_OPERATION_INSERT .And. (F39->F39_STATUS $ "2|3| " .Or. F39->F39_AUTO == "1") .And. !(FwIsInCallStack("gravaBook")))
        oModel:GetModel("F3ADETAIL"):SetNoInsertLine()
        
        If (F39->F39_STATUS $ "2|3| ")
            oModel:GetModel("F3ADETAIL"):SetNoDeleteLine()
        EndIf
    EndIf

Return lRet

/*{Protheus.doc} RU09T04EventRUS:New()
@type       method
@author     Artem Kostin
@since      27/07/2018
@version    P12.1.21
@description    Method - constructor of the class RU09T04EventRUS
*/
Method New() Class RU09T04EventRUS
Return Nil



/*{Protheus.doc} RU09T04EventRUS:ModelPosVld()
@type       method
@author     Artem Kostin
@since      08/08/2018
@version    P12.1.21
*/
Method ModelPosVld(oModel, cModelId) Class RU09T04EventRUS
Local lRet := .T.

Local nLine as Numeric
Local oModelF39 := oModel:GetModel("F39MASTER")
Local oModelF3A := oModel:GetModel("F3ADETAIL")
Local oModelF54 := oModel:GetModel("F54DETAIL")
Local nOperation := oModel:GetOperation()

If (cModelId == 'RU09T04')
    For nLine := 1 to oModelF3A:Length()
        oModelF3A:GoLine(nLine)
        If !oModelF3A:IsDeleted() .and. ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE))

            //Filed code at F3A 
            lRet := lRet .and. oModelF3A:LoadValue("F3A_CODE", oModelF39:GetValue("F39_CODE"))
            //F54 - type
            lRet := lRet .and. oModelF54:LoadValue("F54_TYPE", "02") //sales book
            // F54_FILIAL is in relations
            lRet := lRet .and. oModelF54:LoadValue("F54_DIRECT", "-")
            lRet := lRet .and. oModelF54:LoadValue("F54_DATE", oModelF39:GetValue("F39_FINAL"))
            // F54_TYPE is in relations
            lRet := lRet .and. oModelF54:LoadValue("F54_CLIENT", oModelF3A:GetValue("F3A_CLIENT"))
            lRet := lRet .and. oModelF54:LoadValue("F54_CLIBRA", oModelF3A:GetValue("F3A_BRANCH"))
            // F54_KEY is fullfiled in the function FillF53Table()
            lRet := lRet .and. oModelF54:LoadValue("F54_DOC", oModelF3A:GetValue("F3A_DOC"))
            lRet := lRet .and. oModelF54:LoadValue("F54_PDATE", oModelF3A:GetValue("F3A_PDATE"))
            // F54_VATCOD is in relations
            lRet := lRet .and. oModelF54:LoadValue("F54_VATBS", oModelF3A:GetValue("F3A_VATBS"))
            lRet := lRet .and. oModelF54:LoadValue("F54_VATRT", oModelF3A:GetValue("F3A_VATRT"))
            lRet := lRet .and. oModelF54:LoadValue("F54_VALUE", oModelF3A:GetValue("F3A_VATVL"))
            // F54_REGKEY is in relations
            lRet := lRet .and. oModelF54:LoadValue("F54_REGDOC", oModelF39:GetValue("F39_CODE"))
            lRet := lRet .and. oModelF54:LoadValue("F54_USER", __cUserID)
        EndIf

        If !lRet
            Help("",1,"FillF53Table_01",,STR0008,1,0)
            Exit
        EndIf
    Next nLine
EndIf
Return(lRet)

/*/{Protheus.doc} GridLinePreVld
@author Ruslan Burkov
@since 10/03/2018
@version 1.0
@return ${return}, ${return_description}
@param oSubModel, object, descricao
@param nLinVld, numeric, descricao
@param cAction, characters, descricao
@param cField, characters, descricao
@param xValue, , descricao
@param xOldValue, , descricao
@type function
/*/
Method GridLinePreVld(oSubModel, cModelID, nLinVld, cAction, cField, xValue, xOldValue) Class RU09T04EventRUS
Local lRet := .T.
Local cQuery as Character
Local cSalesVAT as Character
Local cPrintDate as Character
Local cKey as Character
Local cTab as Character
Local nLine as Numeric
Local nCurDelta as Numeric //for right change F3A_ITEM on delete\undelete rows
// Variables to operate with View
Local oView as Object
// Saves the line selected by user
Local aSaveRows as Array

If Type("lRecursion") == "U"
	Private lRecursion := .F.
EndIf

// Prevents prevalidation from recursion.
If (lRecursion == .T.)

Else
	lRecursion := .T.
    aSaveRows := FWSaveRows()

	// If it is the deletion of an empty line return Nil.
    If lRet .and. (cAction == "DELETE") .and. Empty(AllTrim(oSubModel:getValue("F3A_KEY")))
        lRet := Nil

	ElseIf lRet .and. (cAction == "CANSETVALUE") .and. (cField == "F3A_DOC")
        If !Empty(AllTrim(oSubModel:GetValue("F3A_KEY")))
            lRet := .F.
        EndIf

    // If user put something into the Doc. Num. field and pressed enter.
    ElseIf (lRet .and. (cAction == "SETVALUE") .And. (cField $ "F3A_KEY   |F3A_DOC   |"))

        If (Empty(AllTrim(oSubModel:GetValue("F3A_KEY"))) .and. (cField == "F3A_DOC")) .or. (cField == "F3A_KEY")

            cSalesVAT := AllTrim(F35->F35_DOC)
            cPrintDate := DToS(F35->F35_PDATE)
            
            cQuery := RU09T04_01getSQLquery(oSubModel)
            cQuery += " AND T0.F35_DOC = '" + cSalesVAT + "'" 
            cQuery += " AND T0.F35_PDATE = '" + cPrintDate + "'" 
            If (cField == "F3A_DOC")
                cQuery += " AND T0.F35_DOC = '" + xValue + "' "
            ElseIf (cField == "F3A_KEY")
                cQuery += " AND T0.F35_KEY = '" + xValue + "' "
            EndIf
            cQuery += RU09T04_02getSQLGroupOrder()
            cTab := MPSysOpenQuery(ChangeQuery(cQuery))

            // If no VAT Invoices with such Document Number were found.
            If (cTab)->(Eof())
                lRet := .F.
                Help("",1,"RU09T04EventRUS:GridLinePreVld_01",,STR0953,1,0) 
            EndIf

            lRet := lRet .and. self:FillF3ATable(oSubModel, cTab)
            CloseTempTable(cTab)
        EndIf
	
	ElseIf (lRet .and. ((cAction == "DELETE") .Or. (cAction == "UNDELETE")) .And. (!(oSubModel:IsInserted()) .Or. (oSubModel:IsInserted() ;
	.And. !Empty(oSubModel:GetValue("F3A_DOC")) .And. !Empty(oSubModel:GetValue("F3A_KEY")))))
		// Saves the VAT Key of the deleted line.
		cKey :=  AllTrim(oSubModel:GetValue("F3A_KEY"))
        nCurDelta := 0;
		// Goes over all the grid and deletes all lines related to this Sales VAT Invoices.
		For nLine := 1 To oSubModel:Length()
			oSubModel:GoLine(nLine)
            
			If (cKey == AllTrim(oSubModel:GetValue("F3A_KEY")))
				If ((cAction == "DELETE") .And. !(oSubModel:IsDeleted()))
                    nCurDelta--
					oSubModel:DeleteLine()
                    lRet := lRet .and. self:RfrshF39Ttl(-oSubModel:GetValue("F3A_VATVL"))
				ElseIf ((cAction == "UNDELETE") .And. (oSubModel:IsDeleted()))
					oSubModel:UnDeleteLine()
                    nCurDelta++
                    lRet := lRet .and. self:RfrshF39Ttl(oSubModel:GetValue("F3A_VATVL"))
				EndIf
            Else
                oSubModel:LoadValue("F3A_ITEM", StrZero(Val(oSubModel:GetValue("F3A_ITEM")) + nCurDelta, TamSX3("F3A_ITEM")[1]))
			EndIf

		Next nLine
	EndIf

	FWRestRows(aSaveRows)

    If lRet .and. (cAction != "CANSETVALUE") .and. (cAction != "ISENABLE")
        // Refreshes the oView object
        oView := FwViewActive()
        If (oView != Nil) .and. (oView:GetModel():GetId() == "RU09T04")
            oView:Refresh()
        EndIf
    EndIf

	lRecursion := .F.
EndIf
Return(lRet)



/*{Protheus.doc} RU09T04EventRUS:GridLinePosVld()
@type       method
@author     Artem Kostin
@since      18/01/2019
*/
Method GridLinePosVld(oSubModel, cSubModelID) Class RU09T04EventRUS 
Local lRet := .T.

If lRet .and. (cSubModelID == "F3ADETAIL")
    If (oSubModel:GetValue("F3A_ADSHNR") != 0 .AND. Empty(oSubModel:GetValue("F3A_ADSHDT")))
        lRet := .F.
        Help("",1,"RU09T04EventRUS:GridLinePosVld:01",,STR0954,1,0)
    ElseIf (oSubModel:GetValue("F3A_ADSHNR") == 0 .AND. !Empty(oSubModel:GetValue("F3A_ADSHDT")))
        lRet := .F.
        Help("",1,"RU09T04EventRUS:GridLinePosVld:02",,STR0955,1,0)
    EndIf
EndIf

Return(lRet)



/*/{Protheus.doc} R09T4AInc
@author felipe.morais
@since 30/10/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Method R09T4AInc(oModel) class RU09T04EventRUS
Local lRet := .T.

Local aParam as Array
Local aPerguntas as Array
Local oModelF39 as Object
Local oModelF3A as Object
Local oModelF54 as Object
Local nItem as Numeric
Local nLine as Numeric 
Local cTab as Character
Local cQuery as Character
Local cCodeF3A as Character
Local cCode as Character
Local nLinha as Numeric

Default nLine := 0

aParam :={}
aPerguntas	:= {}
nItem := 1
nLine := 0 
cTab :=''
cQuery := ""
cCodeF3A :=""
cCode		:=""
nLinha := 1
oModelF39 := oModel:GetModel("F39MASTER")
oModelF3A := oModel:GetModel("F3ADETAIL")
oModelF54 := oModel:GetModel("F54DETAIL")
oModelF3A:GoLine(1)
cCodeF3A := oModelF3A:GetValue("F3A_CODE")


AAdd(aPerguntas,{ 1, STR0016+ ' '+ STR0022	, Space(TamSX3("F35_DOC")[1])            ,"@!",'.T.',"F35",".T.",60, .F.})
AAdd(aPerguntas,{ 1, STR0016+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_DOC")[1])   ,"@!",'.T.',"F35",".T.",60, .F.})             
AAdd(aPerguntas,{ 1, STR0017+ ' '+ STR0022	, oModelF39:GetValue("F39_INIT")         ,	 ,'.T.',"",".T.",60, .F.})             
AAdd(aPerguntas,{ 1, STR0017+ ' '+ STR0023	, oModelF39:GetValue("F39_FINAL")        ,	 ,'.T.',"",".T.",60, .F.})  
AAdd(aPerguntas,{ 1, STR0020+ ' '+ STR0022	, Space(TamSX3("F35_CLIENT")[1])         ,"@!",'.T.',"SA1",".T.",60, .F.}) 
AAdd(aPerguntas,{ 1, STR0021+ ' '+ STR0022	, Space(TamSX3("F35_BRANCH")[1])         ,"@!",'.T.',"",".T.",60, .F.})            
AAdd(aPerguntas,{ 1, STR0020+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_CLIENT")[1]),"@!",'.T.',"SA1",".T.",60, .F.})
AAdd(aPerguntas,{ 1, STR0021+ ' '+ STR0023	, Replicate("Z", TamSX3("F35_BRANCH")[1]),"@!",'.T.',"",".T.",60, .F.})   

If ParamBox(aPerguntas,STR0030,aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
	cQuery := RU09T04_01getSQLquery(oModelF3A)
    cQuery += " AND T0.F35_DOC BETWEEN '"+aParam[1]+"' AND '"+aParam[2]+"'" 
	cQuery += " AND T0.F35_PDATE BETWEEN '"+ DToS(aParam[3])+"' AND '"+ DToS(aParam[4])+"'"
	cQuery += " AND T0.F35_CLIENT BETWEEN '"+aParam[5]+"' AND '"+aParam[7]+"'"
	cQuery += " AND T0.F35_BRANCH BETWEEN '"+aParam[6]+"' AND '"+aParam[8]+"'"
    cQuery += RU09T04_02getSQLGroupOrder()
	cTab := MPSysOpenQuery(ChangeQuery(cQuery))

	lRet := lRet .and. self:FillF3ATable(oModelF3A, cTab)

EndIf

CloseTempTable(cTab)

oModelF3A:GoLine(1)
Return


// Recalculates total
Method RfrshF39Ttl(nValDiff) Class RU09T04EventRUS
Local lRet := .T.
Local nValTotal := FWFldGet("F39_TOTAL") + nValDiff
// Saves the handle of focused object because oView::refresh() changes focus
Local nFocus := GetFocus()
Local oView as Object

If FWFldPut("F39_TOTAL", nValTotal, /*nLinha*/, /*oModel*/, .T., .T.)
    // Refreshes the oView object
    oView := FwViewActive()
    If (ValType(oView) == 'O') .and. (oView:GetModel():GetId() == "RU09T04")
        oView:Refresh()
        // Retores saved focus
        SetFocus(nFocus)
    EndIf
Else
    lRet := .F.
    Help("",1,"RfrshF39Ttl_01",,STR0008,1,0)
EndIf
Return(lRet)


Method FillF3ATable(oSubModel, cTab) Class RU09T04EventRUS
    Local aSheetNrs  as Array
    Local cStartDate as Character
    Local cEndDate   as Character
    Local lAddLine   as Logical
    Local lRet       as Logical
    Local nLine      as Numeric
    Local nTmpMaxNr  as Numeric
    Local nCnt       as Numeric
    Local oModel     as Object // Sales book root model
    Local oModelF54  as Object // Sales VAT Movements model

    lAddLine :=  !Empty(AllTrim(oSubModel:GetValue("F3A_KEY")))
    lRet := .T.
    oModel := oSubModel:oFormModel
    oModelF54 := oModel:GetModel("F54DETAIL")


    aSheetNrs := {}

    While ((cTab)->(!Eof()))
        // If there is no empty line, add new line and push new data to the bottom of the grid.
        // If there is already an empty line, data could be inserted starting from this empty line.
        If lAddLine
            nLine := oSubModel:AddLine()
        Else
            nLine := oSubModel:Length(.F.)
            lAddLine := .T.
        EndIf
        
        If (SToD((cTab)->F35_PDATE) > FWFldGet("F39_FINAL"))  
			(cTab)->(DbSkip())
			Loop
		EndIf

        lRet := lRet .and. oSubModel:LoadValue("F3A_KEY", (cTab)->F35_KEY)
        lRet := lRet .and. oSubModel:LoadValue("F3A_DOC", (cTab)->F35_DOC)
        lRet := lRet .and. oSubModel:LoadValue("F3A_PDATE", SToD((cTab)->F35_PDATE))
        lRet := lRet .and. oSubModel:LoadValue("F3A_VATCOD", (cTab)->F36_VATCOD)
        lRet := lRet .and. oSubModel:LoadValue("F3A_VATCD2", (cTab)->F36_VATCD2)
        lRet := lRet .and. oSubModel:LoadValue("F3A_INVSER", (cTab)->F35_INVSER)
        lRet := lRet .and. oSubModel:LoadValue("F3A_INVDOC", (cTab)->F35_INVDOC)
        lRet := lRet .and. oSubModel:LoadValue("F3A_CLIENT", (cTab)->F35_CLIENT)
        lRet := lRet .and. oSubModel:LoadValue("F3A_BRANCH", (cTab)->F35_BRANCH)
        lRet := lRet .and. oSubModel:LoadValue("F3A_INVDT", SToD((cTab)->F35_INVDT))
        lRet := lRet .and. oSubModel:LoadValue("F3A_INVCUR", (cTab)->F35_INVCUR)
        lRet := lRet .and. oSubModel:LoadValue("F3A_VATVL", (cTab)->F36_VATVL)
        lRet := lRet .and. oSubModel:LoadValue("F3A_VALGR", (cTab)->F36_VALGR)
        lRet := lRet .and. oSubModel:LoadValue("F3A_VATRT", (cTab)->F36_VATRT)
        lRet := lRet .and. oSubModel:LoadValue("F3A_VATBS", (cTab)->F36_VATBS)
        lRet := lRet .and. oSubModel:LoadValue("F3A_NAME", SubStr((cTab)->A1_NOME, 1, TamSX3("F3A_NAME")[1]))

        lRet := lRet .and. oSubModel:LoadValue("F3A_CNOR_C", (cTab)->F35_CNOR_C)
        lRet := lRet .and. oSubModel:LoadValue("F3A_CNOR_B", (cTab)->F35_CNOR_B)
        lRet := lRet .and. oSubModel:LoadValue("F3A_CNEE_C", (cTab)->F35_CNEE_C)
        lRet := lRet .and. oSubModel:LoadValue("F3A_CNEE_B", (cTab)->F35_CNEE_B)
        
        lRet := lRet .and. oSubModel:LoadValue("F3A_ADJNR", (cTab)->F35_ADJNR)
        lRet := lRet .and. oSubModel:LoadValue("F3A_ADJDT", SToD((cTab)->F35_ADJDT)) 

        lRet := lRet .and. oSubModel:LoadValue("F3A_ITEM", StrZero(nLine, TamSX3("F3A_ITEM")[1]))

        lRet := lRet .and. oModelF54:LoadValue("F54_KEY", (cTab)->F35_KEY)

        lRet := lRet .and. self:RfrshF39Ttl(oSubModel:GetValue("F3A_VATVL"))

        cStartDate := AllTrim(RU09T04GetQD(FWFldGet("F39_INIT"))[1])
		If SToD((cTab)->F35_PDATE) < SToD(cStartDate)
			//get search period for number
			aPeriod := RU09T04GetQD(Stod( (cTab)->F35_PDATE))
			cStartDate := AllTrim(aPeriod[1])
			cEndDate := AllTrim(aPeriod[2])

			//get exist numbers in saved and added rows. if exist set max num, else create new num = max + 1
			cQuery := "SELECT MAX(F3A.F3A_ADSHNR) AS F3A_ADSHNR "
			cQuery += "FROM " + RetSQLName("F3A") + " F3A "
			cQuery += "WHERE F3A.F3A_PDATE >= '"+ cStartDate + "' AND F3A.F3A_PDATE < '" + cEndDate + "' AND "
			cQuery += "F3A.D_E_L_E_T_ = ' ' AND "
			cQuery += "F3A.F3A_FILIAL = '" + xFilial("F3A") + "' AND F3A.F3A_BOOKEY = '" + FWFldGet("F39_BOOKEY") + "' "

			cQueryRes := MPSysOpenQuery(ChangeQuery(cQuery))

			nTmpMaxNr := 0
			For nCnt := 1 To Len(aSheetNrs) Step 1
				If aSheetNrs[nCnt][1] >= STOD(cStartDate) .AND. aSheetNrs[nCnt][1] < STOD(cEndDate) .AND. nTmpMaxNr < aSheetNrs[nCnt][2]
					nTmpMaxNr := aSheetNrs[nCnt][2]
				EndIf
			Next

			If (cQueryRes)->F3A_ADSHNR > 0 .Or. nTmpMaxNr > 0
				lRet := lRet .and. oSubModel:LoadValue("F3A_ADSHNR", Max((cQueryRes)->F3A_ADSHNR, nTmpMaxNr)) 
			Else
				cQuery := "SELECT MAX(F3A.F3A_ADSHNR) AS F3A_ADSHNR "
				cQuery += "FROM " + RetSQLName("F3A") + " F3A "
				cQuery += "WHERE F3A.F3A_PDATE >= '"+ cStartDate + "' AND F3A.F3A_PDATE < '" + cEndDate + "' AND "
				cQuery += "F3A.D_E_L_E_T_ = ' ' AND "
				cQuery += "F3A.F3A_FILIAL = '" + xFilial("F3A") + "' "
				cQueryRes := MPSysOpenQuery(ChangeQuery(cQuery))

				lRet := lRet .and. oSubModel:LoadValue("F3A_ADSHNR", Max((cQueryRes)->F3A_ADSHNR, nTmpMaxNr) + 1)
				AAdd(aSheetNrs, {Stod( (cTab)->F35_PDATE), Max((cQueryRes)->F3A_ADSHNR, nTmpMaxNr) + 1})
			EndIf 

            If (lRet)
                lRet := lRet .and. oSubModel:LoadValue("F3A_ADSHDT", SToD(cEndDate))
            EndIf
		EndIf

        If !lRet
            Help("",1,"RU09T04Pre_01",,STR0927,1,0)
            Exit
        EndIf
        
        (cTab)->(DbSkip())
    EndDo

    If (oModel:HasErrorMessage())
        RU05XFN008_Help(oModel)
    EndIf
Return lRet



/*{Protheus.doc} RU09T04_01getSQLquery
It is an attempt to generalize common things.
@author Artem Kostin
@since 01/28/2019
@version P12.1.23
@type function
*/
Function RU09T04_01getSQLquery(oSubModel as Object)
Local cQuery as Character
Local nLine as Numeric

cQuery := "SELECT T0.F35_DOC," 
cQuery += " T0.F35_PDATE," 
cQuery += " T0.F35_KEY," 
cQuery += " T0.F35_INVSER," 
cQuery += " T0.F35_INVDOC," 
cQuery += " T0.F35_CLIENT," 
cQuery += " T0.F35_BRANCH," 
cQuery += " T0.F35_INVCUR," 
cQuery += " T0.F35_ADJNR," 
cQuery += " T0.F35_ADJDT," 
cQuery += " T1.F36_VATCOD," 
cQuery += " T1.F36_VATCD2," 
cQuery += " SUM(T1.F36_VATVL1) F36_VATVL," 
cQuery += " SUM(T1.F36_VATVL1 + T1.F36_VATBS1) F36_VALGR," 
cQuery += " SUM(T1.F36_VATBS1) F36_VATBS," 
cQuery += " T1.F36_VATRT," 
cQuery += " T2.A1_NOME," 
cQuery += " T0.F35_INVDT,"
cQuery += " T0.F35_CNEE_B,"
cQuery += " T0.F35_CNOR_C,"
cQuery += " T0.F35_CNOR_B,"
cQuery += " T0.F35_CNEE_C"
cQuery += " FROM " + RetSQLName("F35") + " T0" 
cQuery += " LEFT JOIN " + RetSQLName("F36") + " T1" 
cQuery += " ON T1.F36_FILIAL = '" + xFilial("F36") + "'"
cQuery += " AND T1.D_E_L_E_T_ = ' '"
cQuery += " AND T1.F36_KEY = T0.F35_KEY" 
cQuery += " LEFT JOIN " + RetSQLName("SA1") + " T2" 
cQuery += " ON T2.A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += " AND T2.D_E_L_E_T_ = ' '" 
cQuery += " AND T2.A1_COD = T0.F35_CLIENT" 
cQuery += " AND T2.A1_LOJA = T0.F35_BRANCH" 
cQuery += " WHERE T0.F35_FILIAL = '" + xFilial("F35") + "'"
cQuery += " AND T0.D_E_L_E_T_ = ' '" 
cQuery += " AND T0.F35_BOOK = ' '"
For nLine := 1 to oSubModel:Length(.F.)
    oSubModel:GoLine(nLine)
    If !Empty(AllTrim(oSubModel:GetValue("F3A_KEY")))
        // Excludes the records which are already in the model from SQL select.
        cQuery += " AND NOT ("
        cQuery += " T1.F36_KEY = '" + oSubModel:GetValue("F3A_KEY") + "'" 
        cQuery += " AND T1.F36_VATCOD = '" + oSubModel:GetValue("F3A_VATCOD") + "'"
        cQuery += " )"
    EndIf
Next nLine

Return(cQuery)



/*{Protheus.doc} RU09T04_02getSQLGroupOrder
It is an attempt to generalize common things.
@author Artem Kostin
@since 01/28/2019
@version P12.1.23
@type function
*/
Function RU09T04_02getSQLGroupOrder()
Local cQuery as Character
cQuery := " GROUP BY T0.F35_DOC," 
cQuery += " T0.F35_PDATE," 
cQuery += " T0.F35_KEY," 
cQuery += " T1.F36_VATCOD," 
cQuery += " T1.F36_VATCD2," 
cQuery += " T0.F35_INVDT,"
cQuery += " T0.F35_INVSER," 
cQuery += " T0.F35_INVDOC," 
cQuery += " T0.F35_CLIENT," 
cQuery += " T0.F35_BRANCH," 
cQuery += " T0.F35_INVCUR," 
cQuery += " T0.F35_CNEE_B,"
cQuery += " T0.F35_CNOR_C,"
cQuery += " T0.F35_CNOR_B,"
cQuery += " T0.F35_CNEE_C,"
cQuery += " T0.F35_ADJNR," 
cQuery += " T0.F35_ADJDT," 
cQuery += " T1.F36_VATRT," 
cQuery += " T2.A1_NOME" 
cQuery += " ORDER BY T0.F35_DOC," 
cQuery += " T0.F35_PDATE," 
cQuery += " T1.F36_VATCOD," 
cQuery += " T1.F36_VATCD2"
Return(cQuery)
