#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'RU09T02.ch'
#include 'RU09XXX.ch'
#include 'parmtype.ch'


/*{Protheus.doc} RU09T02EventRUS
@type 		class
@author Artem Kostin
@since 11/14/2018
@version 	P12.1.21
@description Class to parse Tax Rates from the tables F30 and F31.
*/
Class RU09T02EventRUS From FwModelEvent
	Method New() CONSTRUCTOR
    Method Activate()
    Method FieldPreVld()
    Method GridLinePreVld()
    Method GridLinePosVld()
    Method ModelPosVld()
EndClass



/*{Protheus.doc} RU09T02EventRUS:New()
@type       method
@author     Artem Kostin
@since      11/14/2018
@version    P12.1.21
@description    Method - constructor of the class RU09T02EventRUS
*/
Method New() Class RU09T02EventRUS
Return Nil

/*{Protheus.doc} RU09T02EventRUS:Activate()
@type       method
@author     Alexander Ivanov
@since      10/11/2018
@version    P12.1.27
@description    Method does additional neccesary things after model's activation
*/
Method Activate(oModel, lCopy) Class RU09T02EventRUS

    Local lRet       as Logical
    Local nOperation as Numeric
    Local cF35_Type  as Character
    Local oStr       as Object
    Local oView      as Object
	
    Default lCopy := .F.

    lRet := .T.
    cF35_Type := AllTrim(FwFldGet("F35_TYPE"))
    nOperation := oModel:GetOperation()

    oView := FwViewActive()
    If (ValType(oView) == "O")
        If ((cF35_Type != "2") .and. nOperation == MODEL_OPERATION_UPDATE)
            oStr := oView:GetViewStruct("F35_M")
           	oStr:SetProperty("F35_CLIENT", MVC_VIEW_CANCHANGE, .F.)
            oStr:SetProperty("F35_INVCUR", MVC_VIEW_CANCHANGE, .F.)
            oStr:SetProperty("F35_BRANCH", MVC_VIEW_CANCHANGE, .F.)
        EndIf
    EndIf

Return lRet

/*{Protheus.doc} RU09T02EventRUS:FieldPreVld()
@type       method
@author     Artem Kostin
@since      11/14/2018
@version    P12.1.21
@description    Method - constructor of the class RU09T02EventRUS
*/
Method FieldPreVld(oSubModel, cSubModelID, cAction, cField, xValue) Class RU09T02EventRUS
Local lRet := .T.
Local oModel as Object
Local nLine as Numeric
Local nI as Numeric

Local nVatBs1 as Numeric
Local nVatVl1 as Numeric
Local nVatBs1Sum as Numeric
Local nVatVl1Sum as Numeric
Local nCurRate as Numeric

Local cQuery as Character
Local cTab as Character

If lRet .and. (cSubModelID == "F35MASTER") .and. (cAction == "SETVALUE") .and. (cField == "F35_ADJDT")
    If !( Empty(FWFldGet("F35_PDATE")) .or. (xValue >= FWFldGet("F35_PDATE")) )
        lRet := .F.
        Help("",1,"RU09T02EventRUS:FieldPreVld:04", , STR0058, 1, 0)
    EndIf
EndIf

If lRet .and. (cSubModelID == "F35MASTER") .and. (cAction == "SETVALUE") .and. (cField $ "F35_INVCUR|F35_PDATE") .and. (FWFldGet("F35_TYPE") == "2")
    If (lRet .and. cField == "F35_INVCUR")
        lRet := lRet .and. (ExistCpo('CTO', xValue, 1))
    EndIf

    If (lRet .and. cField == "F35_INVCUR")
        cQuery := " SELECT CTO_SIMB FROM " + RetSQLName("CTO") + " WHERE CTO_FILIAL = '" + xFilial("CTO") + "' AND CTO_MOEDA = '" + Iif(cField == "F35_INVCUR", xValue, FWFldGet("F35_INVCUR")) + "' AND D_E_L_E_T_ = ' '; "
        cTab := MPSysOpenQuery(ChangeQuery(cQuery))
        If !oSubModel:LoadValue("F35_ICUDES", (cTab)->CTO_SIMB)
            lRet := .F.
            Help("",1,"RU09T02EventRUS:FieldPreVld:08", , STR0056 + X3Titulo("F35_ICUDES") + STR0057, 1, 0)
        EndIf
        CloseTempTable(cTab)
    EndIf

    If (lRet)
        nCurRate := RecMoeda(Iif(cField == "F35_PDATE", DtoS(xValue), DtoS(FWFldGet("F35_PDATE"))), Iif(cField == "F35_INVCUR", xValue, (FWFldGet("F35_INVCUR"))))
        If !oSubModel:LoadValue("F35_C_RATE", nCurRate)
            lRet := .F.
            Help("",1,"RU09T02EventRUS:FieldPreVld:09", , STR0056 + X3Titulo("F35_C_RATE") + STR0057, 1, 0)
        EndIf
    EndIf

    If (lRet)
        oModel := FWModelActive()
        nLine := oModel:GetModel("F36DETAIL"):GetLine()
        nVatBs1Sum := 0
        nVatVl1Sum := 0
        For nI := 1 to oModel:GetModel("F36DETAIL"):Length()
            oModel:GetModel("F36DETAIL"):GoLine(nI)
            nVatBs1 := Round(FWFldGet("F36_VATBS") * nCurRate, 2)
            nVatVl1 := Round(FWFldGet("F36_VATVL") * nCurRate, 2)
            nVatBs1Sum += nVatBs1
            nVatVl1Sum += nVatVl1
            If !oModel:GetModel("F36DETAIL"):LoadValue("F36_VATBS1", nVatBs1)
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:01", , STR0056 + X3Titulo("F36_VATBS1") + STR0057, 1, 0)
                Exit
            ElseIf !oModel:GetModel("F36DETAIL"):LoadValue("F36_VATVL1", nVatVl1)
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:02", , STR0056 + X3Titulo("F36_VATVL1") + STR0057, 1, 0)
                Exit
            EndIf
        Next nI
        oModel:GetModel("F36DETAIL"):GoLine(nLine)

        If !oSubModel:LoadValue("F35_VATBS1", nVatBs1Sum)
            lRet := .F.
            Help("",1,"RU09T02EventRUS:FieldPreVld:06", , STR0056 + X3Titulo("F35_VATBS1") + STR0057, 1, 0)
        ElseIf !oSubModel:LoadValue("F35_VATVL1", nVatVl1Sum)
            lRet := .F.
            Help("",1,"RU09T02EventRUS:FieldPreVld:07", , STR0056 + X3Titulo("F35_VATVL1") + STR0057, 1, 0)
        EndIf
    EndIf

    If (lRet)
        oView := FwViewActive()
        If (ValType(oView) != "U")
            oView:Refresh("F35_T")
        EndIf
    EndIf
EndIf
Return(lRet)



/*{Protheus.doc} RU09T02EventRUS:GridLinePreVld()
@type       method
@author     Artem Kostin
@since      27/07/2018
@version    P12.1.21
*/
Method GridLinePreVld(oSubModel, cSubModelID, nLineVld, cAction, cField, xValue, xOldValue) Class RU09T02EventRUS
Local lRet := .T.
Local cInvDoc as Character
Local cInvSer as Character
Local nI as Numeric
Local nLine as Numeric
Local cCFExt := ""

Local cAlias as Character
Local nSign as Numeric

Local oModel as Object
Local oModelF35 as Object
Local oModelF36 as Object
Local oModelSF2 as Object

If Type("lRecursion") == "U"
	Private lRecursion := .F.
EndIf

// Prevents prevalidation from recursion.
If (lRecursion == .T.)
	// If it is recursion, just skip everything and return true.
Else
	lRecursion := .T.

    If lRet .and. (cSubModelID $ "F36DETAIL|SF2DETAIL") .and. (cAction != "CANSETVALUE") .and. (cAction != "ISENABLE") .and. (cAction != "ADDLINE")
        oModel := FWModelActive()
		If (ValType(oModel) != "O") .or. (oModel:getId() != "RU09T02")
			lRet := .F.
			Help("",1,"RU09T02EventRUS:GridLinePreVld:01",,STR0910,1,0)
        Else
            oModelF35 := oModel:GetModel("F35MASTER")
            oModelF36 := oModel:GetModel("F36DETAIL")
            oModelSF2 := oModel:GetModel("SF2DETAIL")
		EndIf

        If (lRet .and. cSubModelID $ "F36DETAIL|SF2DETAIL" .and. cAction $ "DELETE|UNDELETE" .and. oModelF35:GetValue("F35_TYPE") == "1")
            If (cSubModelID == "F36DETAIL")
				cInvDoc := oModelF36:GetValue("F36_INVDOC")
				cInvSer	:= oModelF36:GetValue("F36_INVSER")
			ElseIf (cSubModelID == "SF2DETAIL")
				cInvDoc := oModelSF2:GetValue("F2_DOC")
				cInvSer	:= oModelSF2:GetValue("F2_SERIE")
			EndIf
        
            If (lRet)
                nLine := oModelF36:GetLine()
                For nI := 1 to oModelF36:Length()
                    oModelF36:GoLine(nI)
                    If (alltrim(cInvDoc) == alltrim(oModelF36:GetValue("F36_INVDOC")) .And. cInvSer == oModelF36:GetValue("F36_INVSER"))
                        If ((cAction == "DELETE") .And. (!oModelF36:IsDeleted()))
                            oModelF36:DeleteLine()
                        ElseIf ((cAction == "UNDELETE") .And. (oModelF36:IsDeleted()))
                            oModelF36:UnDeleteLine()
                        EndIf
                    EndIf
                Next nI
                oModelF36:GoLine(nLine)
            EndIf
        EndIf

        If (lRet .and. cSubModelID == "F36DETAIL" .and. cAction == "SETVALUE" .and. cField $ "F36_VATBS|F36_VATVL|F36_VALGR|F36_VATBS1|F36_VATVL1" .and. oModelF35:GetValue("F35_TYPE") == "2")
            cAlias := "F35" + SubStr(cField, 4, Len(cField))
            If !oModelF35:LoadValue(cAlias, FWFldGet(cAlias) + Round(xValue, 2) - Round(xOldValue, 2))
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:10", , STR0056 + X3Titulo(cAlias) + STR0057, 1, 0)
            EndIf
        EndIf

        If (lRet .and. cSubModelID == "F36DETAIL" .and. cAction $ "DELETE|UNDELETE")
            If (cAction == "DELETE")
                nSign := -1
            ElseIf (cAction == "UNDELETE")
                nSign := 1
            EndIf

            If !oModelF35:LoadValue("F35_VATVL", FWFldGet("F35_VATVL") + nSign * FWFldGet("F36_VATVL"))
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:11", , STR0056 + X3Titulo("F35_VATVL") + STR0057, 1, 0)

            ElseIf !oModelF35:LoadValue("F35_VALGR", FWFldGet("F35_VALGR") + nSign * FWFldGet("F36_VALGR"))
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:12", , STR0056 + X3Titulo("F35_VALGR") + STR0057, 1, 0)

            ElseIf !oModelF35:LoadValue("F35_VATBS", FWFldGet("F35_VATBS") + nSign * FWFldGet("F36_VATBS"))
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:13", , STR0056 + X3Titulo("F35_VATBS") + STR0057, 1, 0)

            ElseIf !oModelF35:LoadValue("F35_VATVL1", FWFldGet("F35_VATVL1") + nSign * FWFldGet("F36_VATVL1"))
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:14", , STR0056 + X3Titulo("F35_VATVL1") + STR0057, 1, 0)

            ElseIf !oModelF35:LoadValue("F35_VATBS1", FWFldGet("F35_VATBS1") + nSign * FWFldGet("F36_VATBS1"))
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:15", , STR0056 + X3Titulo("F35_VATBS1") + STR0057, 1, 0)
            EndIf

            For nI := 1 To oModelF36:Length(.F.)
				oModelF36:GoLine(nI)
                If !(oModelF36:GetValue("F36_VATCD2") $ cCFExt); // if a code is already in the string of all the codes, skip it
                    .and. !(nI != nLineVld .and. oModelF36:IsDeleted()); // skip deleted lines if action is not about them
                    .and. !(nI == nLineVld .and. cAction == "DELETE") // skip a validating line, if it is going to be deleted
                    cCFExt += AllTrim(oModelF36:GetValue("F36_VATCD2")) + ";"
                EndIf
			Next nI
            oModelF36:GoLine(nLineVld)

            If !Empty(cCFExt)
                cCFExt := Left(cCFExt, Len(cCFExt)-1)
            EndIf

            If !oModelF35:LoadValue("F35_VATCD2", cCFExt)
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:16", , STR0056 + X3Titulo("F35_VATCD2") + STR0057, 1, 0)
            EndIf
        EndIf
        
        If (lRet .and. cSubModelID == "F36DETAIL" .and. cAction == "SETVALUE" .and. cField == "F36_VATCD2")
            cCFExt := AllTrim(oModelF35:GetValue("F35_VATCD2"))
            If !(xValue $ cCFExt)
                If !Empty(cCFExt)
                    cCFExt += ";"
                EndIf
                cCFExt += AllTrim(xValue)
            EndIf

            If !oModelF35:LoadValue("F35_VATCD2", cCFExt)
                lRet := .F.
                Help("",1,"RU09T02EventRUS:FieldPreVld:17", , STR0056 + X3Titulo("F35_VATCD2") + STR0057, 1, 0)
            EndIf
        EndIf
	EndIf
		
	If lRet .and. (cAction != "CANSETVALUE") .and. (cAction != "ISENABLE")
        oView := FwViewActive()
        If (ValType(oView) != "U")
            oView:Refresh("F35_T")
        EndIf
    EndIf

	lRecursion := .F.
EndIf // lRecursion == .T.
Return(lRet)



/*{Protheus.doc} RU09T02EventRUS:GridLinePosVld()
@type       method
@author     Artem Kostin
@since      11/26/2018
@version    P12.1.21
*/
Method GridLinePosVld(oSubModel, cSubModelID) Class RU09T02EventRUS
Local lRet := .T.

If lRet .and. (cSubModelID == "F5PDETAIL")
    If (Empty(oSubModel:GetValue("F5P_ADVDOC")) != Empty(oSubModel:GetValue("F5P_ADVDT")))
        lRet := .F.
        Help("",1,"RU09T02EventRUS:GridLinePosVld:01",,STR0059,1,0,,,,,,{oSubModel:GetValue("F5P_ITEM")})
    EndIf
EndIf

If lRet .and. (cSubModelID == "F36DETAIL")
    If (Empty(oSubModel:GetValue("F36_DESC")))
        lRet := .F.
        Help("", 1, "RU09T02EventRUS:GridLinePosVld:02",,STR0061,1,0,,,,,,{oSubModel:GetValue("F36_ITEM")})
    EndIf
EndIf
Return(lRet)



/*{Protheus.doc} RU09T02EventRUS:ModelPosVld()
@type       method
@author     Artem Kostin
@since      01/22/2018
@version    P12.1.21
*/
Method ModelPosVld(oSubModel, cSubModelID) Class RU09T02EventRUS
Local lRet := .T.

If lRet .and. (cSubModelID == "F35MASTER")
    If (Empty(oSubModel:GetValue("F35_ADJDT")) != Empty(oSubModel:GetValue("F35_ADJNR")))
        lRet := .F.
        Help("",1,"RU09T02EventRUS:ModelPosVld:01",,STR0059,1,0,,,,,,)
    EndIf
EndIf
Return(lRet)
