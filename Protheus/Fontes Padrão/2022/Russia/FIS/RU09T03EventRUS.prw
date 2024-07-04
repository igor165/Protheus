#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'RU09T03.ch'
#include 'RU09XXX.ch'


/*{Protheus.doc} RU09T03EventRUS
@type 		class
@author Artem Kostin
@since 11/30/2018
@version 	P12.1.21
@description Class to parse Tax Rates from the tables F30 and F31.
*/
Class RU09T03EventRUS From FwModelEvent
	Method New() CONSTRUCTOR
    Method Activate()
    Method FieldPreVld()
    Method ModelPosVld()
    Method GridLinePreVld()
    Method GridLinePosVld()
EndClass



/*{Protheus.doc} RU09T03EventRUS:New()
@type       method
@author     Artem Kostin
@since      11/30/2018
@version    P12.1.21
@description    Method - constructor of the class RU09T03EventRUS
*/
Method New() Class RU09T03EventRUS
Return Nil



/*{Protheus.doc} RU09T03EventRUS:Activate()
@type       method
@author     Artem Kostin
@since      01/24/2018
@version    P12.1.23
@description    Method does additional neccesary things after model's activation
*/
Method Activate(oModel, lCopy) Class RU09T03EventRUS

    Local lRet       as Logical
    Local nOperation as Numeric
    Local cF37_Type  as Character
    Local oStr       as Object
    Local oView      as Object
	
    Default lCopy := .F.

    lRet := .T.
    cF37_Type := AllTrim(FwFldGet("F37_TYPE"))
    nOperation := oModel:GetOperation()

    If (cF37_Type == "1" .and. nOperation == MODEL_OPERATION_UPDATE)
        oModel:GetModel("F38detail"):SetNoInsertLine(.T.)
        oModel:GetModel("SF1detail"):SetNoInsertLine(.T.)
    EndIf

    oView := FwViewActive()
    If (ValType(oView) == "O" .and. oView:GetModel():GetId() == "RU09T03")
        If ((cF37_Type != "2") .and. nOperation == MODEL_OPERATION_UPDATE)
            oStr := oView:GetViewStruct("VIEW_F37M")
            oStr:SetProperty("F37_FORNEC", MVC_VIEW_CANCHANGE, .F.)
            oStr:SetProperty("F37_INVCUR", MVC_VIEW_CANCHANGE, .F.)
            oStr:SetProperty("F37_BRANCH", MVC_VIEW_CANCHANGE, .F.)
        EndIf
    EndIf

Return lRet


/*{Protheus.doc} RU09T03EventRUS:FieldPreVld()
@type       method
@author     Artem Kostin
@since      11/30/2018
@version    P12.1.21
@description    Method - constructor of the class RU09T03EventRUS
*/
Method FieldPreVld(oSubModel, cSubModelID, cAction, cField, xValue) Class RU09T03EventRUS
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

If lRet .and. (cSubModelID == "F37master") .and. (cAction == "SETVALUE") .and. (cField == "F37_ADJDT")
    If !( Empty(FWFldGet("F37_PDATE")) .or. (xValue >= FWFldGet("F37_PDATE")) )
        lRet := .F.
        Help("",1,"RU09T03EventRUS:FieldPreVld:04", , STR0045, 1, 0)
    EndIf
EndIf

If lRet .and. (cSubModelID == "F37master") .and. (cAction == "SETVALUE") .and. (cField $ "F37_INVCUR|F37_PDATE") .and. (FWFldGet("F37_TYPE") == "2")
    If (lRet .and. cField == "F37_INVCUR")
        lRet := lRet .and. (ExistCpo('CTO', xValue, 1))
    EndIf

    If (lRet .and. cField == "F37_INVCUR")
        cQuery := " SELECT CTO_SIMB FROM " + RetSQLName("CTO") + " WHERE CTO_FILIAL = '" + xFilial("CTO") + "' AND CTO_MOEDA = '" + Iif(cField == "F37_INVCUR", xValue, FWFldGet("F37_INVCUR")) + "' AND D_E_L_E_T_ = ' '; "
        cTab := MPSysOpenQuery(ChangeQuery(cQuery))
        If !oSubModel:LoadValue("F37_ICUDES", (cTab)->CTO_SIMB)
            lRet := .F.
            Help("",1,"RU09T03EventRUS:FieldPreVld:08", , STR0043 + X3Titulo("F37_ICUDES") + STR0044, 1, 0)
        EndIf
        CloseTempTable(cTab)
    EndIf

    If (lRet)
        nCurRate := RecMoeda(Iif(cField == "F37_PDATE", DtoS(xValue), DtoS(FWFldGet("F37_PDATE"))), Iif(cField == "F37_INVCUR", xValue, (FWFldGet("F37_INVCUR"))))
        If !oSubModel:LoadValue("F37_C_RATE", nCurRate)
            lRet := .F.
            Help("",1,"RU09T03EventRUS:FieldPreVld:09", , STR0043 + X3Titulo("F37_C_RATE") + STR0044, 1, 0)
        EndIf
    EndIf

    If (lRet)
        oModel := FWModelActive()
        nLine := oModel:GetModel("F38detail"):GetLine()
        nVatBs1Sum := 0
        nVatVl1Sum := 0
        For nI := 1 to oModel:GetModel("F38detail"):Length()
            oModel:GetModel("F38detail"):GoLine(nI)
            nVatBs1 := Round(FWFldGet("F38_VATBS") * nCurRate, 2)
            nVatVl1 := Round(FWFldGet("F38_VATVL") * nCurRate, 2)
            nVatBs1Sum += nVatBs1
            nVatVl1Sum += nVatVl1
            If !oModel:GetModel("F38detail"):LoadValue("F38_VATBS1", nVatBs1)
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:01", , STR0043 + X3Titulo("F38_VATBS1") + STR0044, 1, 0)
                Exit
            ElseIf !oModel:GetModel("F38detail"):LoadValue("F38_VATVL1", nVatVl1)
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:02", , STR0043 + X3Titulo("F38_VATVL1") + STR0044, 1, 0)
                Exit
            EndIf
        Next nI
		oModel:GetModel("F38detail"):GoLine(nLine)

        If !oSubModel:LoadValue("F37_VATBS1", nVatBs1Sum)
            lRet := .F.
            Help("",1,"RU09T03EventRUS:FieldPreVld:06", , STR0043 + X3Titulo("F37_VATBS1") + STR0044, 1, 0)
        ElseIf !oSubModel:LoadValue("F37_VATVL1", nVatVl1Sum)
            lRet := .F.
            Help("",1,"RU09T03EventRUS:FieldPreVld:07", , STR0043 + X3Titulo("F37_VATVL1") + STR0044, 1, 0)
        EndIf
    EndIf

    If (lRet)
        oView := FwViewActive()
        If (ValType(oView) != "U")
            oView:Refresh("VIEW_F37T")
        EndIf
    EndIf
EndIf
Return(lRet)



/*{Protheus.doc} RU09T03EventRUS:GridLinePreVld()
@type       method
@author     Artem Kostin
@since      11/30/2018
@version    P12.1.21
*/
Method GridLinePreVld(oSubModel, cSubModelID, nLineVld, cAction, cField, xValue, xOldValue) Class RU09T03EventRUS
Local lRet := .T.
Local cInvDoc as Character
Local cInvSer as Character
Local nI as Numeric
Local nLine as Numeric
Local cCFExt := ""

Local oModel as Object
Local oModelF37 as Object
Local oModelF38 as Object
Local oModelSF1 as Object

Local lCanInsertLine as Logical

If Type("lRecursion") == "U"
	Private lRecursion := .F.
EndIf

// Prevents prevalidation from recursion.
If (lRecursion == .T.)
	// If it is recursion, just skip everything and return true.
Else
	lRecursion := .T.

    If lRet .and. (cSubModelID $ "F38detail|SF1detail") .and. (cAction $ "DELETE|UNDELETE|SETVALUE")
		oModel := FWModelActive()
		If (ValType(oModel) != "O") .or. (oModel:getId() != "RU09T03")
			lRet := .F.
			Help("",1,"RU09T03EventRUS:GridLinePreVld:01",,STR0910,1,0)
		Else
			oModelF37 := oModel:GetModel("F37master")
			oModelF38 := oModel:GetModel("F38detail")
			oModelSF1 := oModel:GetModel("SF1detail")
		EndIf

		If lRet .and. ((cAction == "DELETE") .Or. (cAction == "UNDELETE")) .and. oModelF37:GetValue("F37_TYPE") == "1"
			dMiDa	:= oModelF37:GetValue("F37_PDATE")
			cHeadDc	:= oModelF37:GetValue("F37_INVDOC")
			If (cSubModelID == "F38detail")
				cInvDoc := oModelF38:GetValue("F38_INVDOC")
				cInvSer	:= oModelF38:GetValue("F38_INVSER")
			ElseIf (cSubModelID == "SF1detail")
				cInvDoc := oModelSF1:GetValue("F1_DOC")
				cInvSer	:= oModelSF1:GetValue("F1_SERIE")
			EndIf

			If lRet
				nLine := oModelF38:GetLine()
				For nI := 1 to oModelF38:Length()
					oModelF38:GoLine(nI)
					If (alltrim(cInvDoc) == alltrim(oModelF38:GetValue("F38_INVDOC")) .And. cInvSer == oModelF38:GetValue("F38_INVSER"))
						If ((cAction == "DELETE") .And. (!oModelF38:IsDeleted()))
							oModelF38:DeleteLine()
						ElseIf ((cAction == "UNDELETE") .And. (oModelF38:IsDeleted()))
							oModelF38:UnDeleteLine()
						EndIf
					EndIf
				Next nI
				oModelF38:GoLine(nLine)

				// Goes thougth the Puchases Invoices grid and finds the first related line.
				nLine := oModelSF1:GetLine()
				For nI := 1 To oModelSF1:Length()
					oModelSF1:GoLine(nI)
					If (alltrim(cInvDoc) == alltrim(oModelSF1:GetValue("F1_DOC")) .And. cInvSer == oModelSF1:GetValue("F1_SERIE"))
						If ((cAction == "DELETE") .And. !(oModelSF1:IsDeleted()))
							oModelSF1:DeleteLine()
							//if we delete invoice from f37_pdate we need find new
							if (dMiDa == oModelSF1:GetValue("F1_EMISSAO"))
								dMiDa1 := STOD("19000101")
								oModelSF1:GoLine(1)
								For nI := 1 To oModelSF1:Length()
									oModelSF1:GoLine(nI)
									if !(oModelSF1:IsDeleted())
										If	(dMiDa1 < oModelSF1:GetValue("F1_EMISSAO"))
										dMiDa1	:= oModelSF1:GetValue("F1_EMISSAO")
										cHeadDc	:= alltrim(oModelSF1:GetValue("F1_DOC"))
										EndIf
									EndIf
								Next nI
								oModelF37:LoadValue("F37_PDATE", dMida1)
								oModelF37:LoadValue("F37_INVDOC", cHeadDc)
							EndIf
							dMida1 := oModelF37:GetValue("F37_PDATE")
						
						ElseIf ((cAction == "UNDELETE") .And. (oModelSF1:IsDeleted()))
							oModelSF1:UnDeleteLine()
							//if we undelete invoice with max date we need set its value un f37_pdate
							If (dMiDa < oModelSF1:GetValue("F1_EMISSAO"))
								dMiDa1	:= oModelSF1:GetValue("F1_EMISSAO")
								cHeadDc	:= oModelSF1:GetValue("F1_DOC")
							Else
								dMiDa1 := dMiDa
							EndIf
							dMiDa1	:= max(dMiDa, oModelSF1:GetValue("F1_EMISSAO"))
							oModelF37:LoadValue("F37_PDATE", dMida1)
							oModelF37:LoadValue("F37_INVDOC", cHeadDc)
						EndIf
					EndIf
				Next nI
				oModelSF1:GoLine(nLine)
			EndIf
		EndIf

		If (lRet .and. cSubModelID == "F38detail" .and. cAction == "SETVALUE" .and. cField $ "F38_VATBS|F38_VATVL|F38_VALGR|F38_VATBS1|F38_VATVL1|F38_VALUE" .and. FWFldGet("F37_TYPE") == "2")
			cAlias := "F37" + SubStr(cField, 4, Len(cField))
            If !oModelF37:LoadValue(cAlias, FWFldGet(cAlias) + Round(xValue, 2) - Round(xOldValue, 2))
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:10", , STR0043 + X3Titulo(cAlias) + STR0044, 1, 0)
            EndIf
		EndIf

		If (lRet .and. cSubModelID == "F38detail" .and. cAction $ "DELETE|UNDELETE")
            If (cAction == "DELETE")
                nSign := -1
            ElseIf (cAction == "UNDELETE")
                nSign := 1
            EndIf

            If !oModelF37:LoadValue("F37_VATVL", FWFldGet("F37_VATVL") + nSign * FWFldGet("F38_VATVL"))
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:11", , STR0043 + X3Titulo("F37_VATVL") + STR0044, 1, 0)

            ElseIf !oModelF37:LoadValue("F37_VALGR", FWFldGet("F37_VALGR") + nSign * FWFldGet("F38_VALGR"))
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:12", , STR0043 + X3Titulo("F37_VALGR") + STR0044, 1, 0)

            ElseIf !oModelF37:LoadValue("F37_VATBS", FWFldGet("F37_VATBS") + nSign * FWFldGet("F38_VATBS"))
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:13", , STR0043 + X3Titulo("F37_VATBS") + STR0044, 1, 0)

            ElseIf !oModelF37:LoadValue("F37_VATVL1", FWFldGet("F37_VATVL1") + nSign * FWFldGet("F38_VATVL1"))
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:14", , STR0043 + X3Titulo("F37_VATVL1") + STR0044, 1, 0)

            ElseIf !oModelF37:LoadValue("F37_VATBS1", FWFldGet("F37_VATBS1") + nSign * FWFldGet("F38_VATBS1"))
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:15", , STR0043 + X3Titulo("F37_VATBS1") + STR0044, 1, 0)

			ElseIf !oModelF37:LoadValue("F37_VALUE", FWFldGet("F37_VALUE") + nSign * FWFldGet("F37_VALUE"))
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:15", , STR0043 + X3Titulo("F37_VALUE") + STR0044, 1, 0)
            EndIf

            For nI := 1 To oModelF38:Length(.F.)
				oModelF38:GoLine(nI)
                If !(oModelF38:GetValue("F38_VATCD2") $ cCFExt); // if a code is already in the string of all the codes, skip it
                    .and. !(nI != nLineVld .and. oModelF38:IsDeleted()); // skip deleted lines if action is not about them
                    .and. !(nI == nLineVld .and. cAction == "DELETE") // skip a validating line, if it is going to be deleted
                    cCFExt += AllTrim(oModelF38:GetValue("F38_VATCD2")) + ";"
                EndIf
			Next nI
            oModelF38:GoLine(nLineVld)

            If !Empty(cCFExt)
                cCFExt := Left(cCFExt, Len(cCFExt)-1)
            EndIf

            If !oModelF37:LoadValue("F37_VATCD2", cCFExt)
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:16", , STR0043 + X3Titulo("F37_VATCD2") + STR0044, 1, 0)
            EndIf
        EndIf
        
        If (lRet .and. cSubModelID == "F38detail" .and. cAction == "SETVALUE" .and. cField == "F38_VATCD2")
            lCanInsertLine := oModelF38:CanInsertLine()
            oModelF38:SetNoInsertLine(.F.)
            cCFExt := AllTrim(oModelF37:GetValue("F37_VATCD2"))
            If !oModelF38:IsDeleted() .and. !(xValue $ cCFExt)
                If !Empty(cCFExt)
                    cCFExt += ";"
                EndIf
                cCFExt += AllTrim(xValue) + ";"
            EndIf
            oModelF38:SetNoInsertLine(!lCanInsertLine)

            If !oModelF37:LoadValue("F37_VATCD2", cCFExt)
                lRet := .F.
                Help("",1,"RU09T03EventRUS:FieldPreVld:17", , STR0043 + X3Titulo("F37_VATCD2") + STR0044, 1, 0)
            EndIf
        EndIf
    EndIf

	If lRet .and. (cAction != "CANSETVALUE") .and. (cAction != "ISENABLE")
        oView := FwViewActive()
        If (ValType(oView) != "U")
            oView:Refresh("VIEW_F37T")
        EndIf
	EndIf
	
	lRecursion := .F.
EndIf
Return(lRet)



/*{Protheus.doc} RU09T03EventRUS:GridLinePosVld()
@type       method
@author     Artem Kostin
@since      01/14/2018
@version    P12.1.21
*/
Method GridLinePosVld(oSubModel, cSubModelID) Class RU09T03EventRUS
Local lRet := .T.

If lRet .and. (cSubModelID == "F38detail")
    If (Empty(oSubModel:GetValue("F38_DESC")))
        lRet := .F.
        Help("", 1, "RU09T03EventRUS:GridLinePosVld:01",,STR0048,1,0,,,,,,{oSubModel:GetValue("F38_ITEM")})
    EndIf
EndIf
Return(lRet)


/*{Protheus.doc} RU09T03EventRUS:ModelPosVld()
@type       method
@author     Artem Kostin
@since      08/01/2019
@version    P12.1.21
@description    Method validates the model RU09T03.
*/
Method ModelPosVld(oSubModel, cSubModelID) Class RU09T03EventRUS
Local lRet := .T.

If (Empty(oSubModel:GetModel("F37master"):GetValue("F37_RDATE")))
    lRet := .F.
    Help("",1,"RU09T03EventRUS:ModelPosVld:01",,STR0047,1,0)
EndIf
Return(lRet)