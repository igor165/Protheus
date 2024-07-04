#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'RU09XXX.ch'
#include 'RU09T08.ch'



/*{Protheus.doc} RU09T08EventRUS
@type 		class
@author Artem Kostin
@since 27/07/2018
@version 	P12.1.21
@description Class to parse Tax Rates from the tables F30 and F31.
*/
Class RU09T08EventRUS From FwModelEvent
    
    //Standard entries to be configured on CT5
    DATA cPadrao
    
    //Variable with accounting total
    DATA nTotal
    
    //Array with informations for accounting flag record
    DATA aFlagCTB
    
    //Handler (working file number) used on accounting
    DATA nHdlPrv
    
    //Temporary file used on accounting
    DATA cOrigem
    DATA cArquivo
    DATA cLoteFis

	Method New() CONSTRUCTOR
    Method Activate()
    Method ModelPosVld()
    Method GridLinePreVld()
    Method InTTS()
    Method After(oModel, cModelId, cAlias, lNewRecord)
    Method BeforeTTS(oModel, cModelId)
    Method AfterTTS(oModel, cModelId)
     Method VldActivate(oModel, cModelID)

    Method FillF53Table(oModelF53, cTab, nUserRestRate, cTargetCode, cNewVATCode)
    Method FiltVATInvoices(oModel)
    Method RfrshF52Ttl(nRestValDiff)
    Method WriteLinesCTB(oModel,cModelId,cAlias,lNewRecord)
    Method OpenCTB(oModel)
    Method CloseCTB(oModel)    
EndClass



/*{Protheus.doc} RU09T08EventRUS:New()
@type       method
@author     Artem Kostin
@since      27/07/2018
@version    P12.1.21
@description    Method - constructor of the class RU09T08EventRUS
*/
Method New() Class RU09T08EventRUS
    self:cPadrao        := "6AI"                       
    self:nTotal         := 0                           
    self:aFlagCTB       := {}                          
    self:nHdlPrv        := 0                           
    self:cLoteFis       := ""
    self:cOrigem        :=""
    self:cArquivo       := ""
Return Nil



/*{Protheus.doc} RU09T08EventRUS:ModelPosVld()
@type       method
@author     Artem Kostin
@since      02/08/2018
@version    P12.1.21
*/
Method ModelPosVld(oModel, cModelId) Class RU09T08EventRUS
Local lRet := .T.

Local oModelF53 as Object
Local nLine := 1
Local nItem := 1

Local cCode := ""
Local cNMBAlias := "VATRES"

Local nOperation := oModel:GetOperation()

If lRet .and. (cModelId == 'RU09T08')
    If (nOperation == MODEL_OPERATION_INSERT)
        cCode := RU09D03NMB(cNMBAlias, Nil, xFilial("F52"))
        If Empty(cCode)
            lRet := .F.
            Help("",1,"RU09T08EventRUS:ModelPosVld_01",,STR0951 + cNMBAlias,2,0,,,,,, /*solucao*/)
        EndIf

        If !oModel:GetModel("F52MASTER"):LoadValue("F52_CODE", cCode)
            lRet := .F.
            Help("",1,"RU09T08EventRUS:ModelPosVld_02",,STR0008,2,0,,,,,, /*solucao*/)
        EndIf
    EndIf

    If (nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)
        If (FWFldGet("F52_WRIOFF") == "1") .and. Empty(AllTrim(FWFldGet("F52_CONTA")))
            lRet := .F.
            Help("",1,"RU09T08EventRUS:ModelPosVld_09",,STR0018,2,0,,,,,, /*solucao*/)
        EndIf

        oModelF53 := oModel:GetModel("F53DETAIL")
        For nLine := 1 to oModelF53:Length()
            oModelF53:SetLine(nLine)
            If !oModelF53:IsDeleted() .and. !Empty(AllTrim(oModelF53:GetValue("F53_KEY")))
                lRet := lRet .and. oModelF53:LoadValue("F53_ITEM", StrZero(nItem++, GetSX3Cache("F53_ITEM", "X3_TAMANHO")))

                If Empty(AllTrim(oModelF53:GetValue("F53_NTGCOD")))
                    lRet := .F.
                    Help("",1,"RU09T08EventRUS:ModelPosVld_03",,STR0014 + " " + STR0019 + " " + FWFldGet("F53_DOC"),2,0,,,,,, /*solucao*/)
                    Exit
                Else
                    cQuery := " SELECT (CASE WHEN A.F31_RATE = B.F31_RATE THEN '1' ELSE '0' END) AS ISRATEOK"
                    cQuery += " FROM  " + RetSQLName("F31") + " AS A, " + RetSQLName("F31") + " AS B"
                    cQuery += " WHERE A.F31_CODE = '" + oModelF53:GetValue("F53_OVTCOD") + "'"
                    cQuery += " AND (B.F31_CODE = '" + oModelF53:GetValue("F53_NTGCOD") + "' AND B.F31_TYPE = '2')"
                    cQuery += " AND A.F31_FILIAL = '" + xFilial("F31") + "'"
                    cQuery += " AND B.F31_FILIAL = '" + xFilial("F31") + "'"
                    cQuery += " AND A.D_E_L_E_T_ = ' '"
                    cQuery += " AND B.D_E_L_E_T_ = ' '"
                    cTab := MPSysOpenQuery(ChangeQuery(cQuery))

                    If ((cTab)->(Eof()))
                        lRet := .F.
                        Help("",1,"RU09T08EventRUS:ModelPosVld_05",,STR0017 + " " + STR0019 + " " + FWFldGet("F53_DOC") + " " + STR0020 + " " + FWFldGet("F53_OVTCOD"),2,0,,,,,, /*solucao*/)
                        Exit
                    ElseIf (AllTrim((cTab)->ISRATEOK) != "1")
                        lRet := .F.
                        Help("",1,"RU09T08EventRUS:ModelPosVld_06",,STR0017 + " " + STR0019 + " " + FWFldGet("F53_DOC") + " " + STR0020 + " " + FWFldGet("F53_OVTCOD"),2,0,,,,,, /*solucao*/)
                        Exit
                    EndIf
                EndIf
                
                If (FWFldGet("F52_WRIOFF") == "2")
                    If Empty(AllTrim(oModelF53:GetValue("F53_NVTCOD")))
                        lRet := .F.
                        Help("",1,"RU09T08EventRUS:ModelPosVld_04",,STR0015 + " " + STR0019 + " " + FWFldGet("F53_DOC") + " " + STR0020 + " " + FWFldGet("F53_OVTCOD"),2,0,,,,,, /*solucao*/)
                        Exit
                    Else
                        cQuery := " SELECT (CASE WHEN A.F31_RATE = B.F31_RATE THEN '1' ELSE '0' END) AS ISRATEOK"
                        cQuery += " FROM  " + RetSQLName("F31") + " AS A, " + RetSQLName("F31") + " AS B"
                        cQuery += " WHERE A.F31_CODE = '" + oModelF53:GetValue("F53_OVTCOD") + "'"
                        cQuery += " AND B.F31_CODE = '" + oModelF53:GetValue("F53_NVTCOD") + "'"
                        cQuery += " AND A.F31_FILIAL = '" + xFilial("F31") + "'"
                        cQuery += " AND B.F31_FILIAL = '" + xFilial("F31") + "'"
                        cQuery += " AND A.D_E_L_E_T_ = ' '"
                        cQuery += " AND B.D_E_L_E_T_ = ' '"
                        cTab := MPSysOpenQuery(ChangeQuery(cQuery))
                        
                        If ((cTab)->(Eof()))
                            lRet := .F.
                            Help("",1,"RU09T08EventRUS:ModelPosVld_07",,STR0017 + " " + STR0019 + " " + FWFldGet("F53_DOC") + " " + STR0020 + " " + FWFldGet("F53_OVTCOD"),2,0,,,,,, /*solucao*/)
                            Exit
                        ElseIf (AllTrim((cTab)->ISRATEOK) != "1")
                            lRet := .F.
                            Help("",1,"RU09T08EventRUS:ModelPosVld_08",,STR0017 + " " + STR0019 + " " + FWFldGet("F53_DOC") + " " + STR0020 + " " + FWFldGet("F53_OVTCOD"),2,0,,,,,, /*solucao*/)
                            Exit
                        EndIf
                    EndIf
                EndIf

            ElseIf Empty(AllTrim(oModelF53:GetValue("F53_KEY")))
                oModelF53:DeleteLine()
            EndIf
        Next nLine
    EndIf
EndIf
Return(lRet)



/*{Protheus.doc} RU09T08EventRUS:InTTS()
@type       method
@author     Artem Kostin
@since      08/08/2018
@version    P12.1.21
*/
Method InTTS(oModel, cModelId) Class RU09T08EventRUS
Local lRet := .T.

If (oModel:GetOperation() == MODEL_OPERATION_INSERT)
    lRet := lRet .and. RU09D07Add(oModel)
    If (FWFldGet("F52_WRIOFF") == "2")
        lRet := lRet .and. RU09D04Add(oModel)
    EndIf
ElseIf (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
    lRet := lRet .and. RU09D07Edt(oModel)
    If (FWFldGet("F52_WRIOFF") == "2")
        lRet := lRet .and. RU09D04Edt(oModel)
    EndIf
ElseIf (oModel:GetOperation() == MODEL_OPERATION_DELETE)
    lRet := lRet .and. RU09D07Del(oModel)
    If (FWFldGet("F52_WRIOFF") == "2")
        lRet := lRet .and. RU09D04Del(oModel)
    EndIf
EndIf

lRet := lRet .and. RU09D05Edt(oModel)
Return(lRet)



/*{Protheus.doc} RU09T08EventRUS:GridLinePreVld()
@type       method
@author     Artem Kostin
@since      27/07/2018
@version    P12.1.21
*/
Method GridLinePreVld(oSubModel, cSubModelID, nLineVld, cAction, cField, xValue, xOldValue) Class RU09T08EventRUS
Local lRet := .T.

Local nRestBs   := 0
Local nRestVl  := 0
Local nRestRate := 0

Local nLine := 1

Local nRestBsAvailable := 0
Local nRestVlAvailable := 0
Local nOldRestVl := 0

Local cTab := ""
Local cQuery := ""

If lRet .and. (cSubModelID == "F53DETAIL") .and. (cAction == "CANSETVALUE") .and. (cField == "F53_DOC")
    If !Empty(AllTrim(oSubModel:GetValue("F53_KEY")))
        lRet := .F.
    EndIf

ElseIf lRet .and. (cSubModelID == "F53DETAIL") .and. (cAction == "SETVALUE") .and. (cField $ "F53_NTGCOD|F53_NVTCOD")
    cQuery := " SELECT (CASE WHEN A.F31_RATE = B.F31_RATE THEN '1' ELSE '0' END) AS ISRATEOK"
    cQuery += " FROM  " + RetSQLName("F31") + " AS A, " + RetSQLName("F31") + " AS B"
    cQuery += " WHERE A.F31_CODE = '" + oSubModel:GetValue("F53_OVTCOD") + "'"
    cQuery += " AND B.F31_CODE = '" + xValue + "'"
    cQuery += " AND A.F31_FILIAL = '" + xFilial("F31") + "'"
    cQuery += " AND B.F31_FILIAL = '" + xFilial("F31") + "'"
    cQuery += " AND A.D_E_L_E_T_ = ' '"
    cQuery += " AND B.D_E_L_E_T_ = ' '"
    If (cField == "F53_NTGCOD")
        cQuery += " AND B.F31_TYPE = '2'"
    EndIf
    cTab := MPSysOpenQuery(ChangeQuery(cQuery))

    If ((cTab)->(Eof()))
        lRet := .F.
        Help("",1,"RU09T08EventRUS:GridLinePreVld_08",,STR0017 + " " + STR0019 + " " + FWFldGet("F53_DOC") + " " + STR0020 + " " + FWFldGet(cField),2,0,,,,,, /*solucao*/)
    ElseIf (AllTrim((cTab)->ISRATEOK) != "1")
        lRet := .F.
        Help("",1,"RU09T08EventRUS:GridLinePreVld_09",,STR0017 + " " + STR0019 + " " + FWFldGet("F53_DOC") + " " + STR0020 + " " + FWFldGet(cField),2,0,,,,,, /*solucao*/)
    EndIf

ElseIf lRet .and. (cSubModelID == "F53DETAIL") .and. (cAction == "SETVALUE") .and. (cField $ "F53_KEY   |F53_DOC   |")
    If (Empty(AllTrim(oSubModel:GetValue("F53_KEY"))) .and. (cField == "F53_DOC"));
    .or. (cField == "F53_KEY")
        // Select from Balances Table
        cQuery := " SELECT F32_KEY AS VAT_KEY, "
        cQuery += " F32_DOC AS DOC_NUM, "
        cQuery += " F32_SUPPL AS SUPPLIER, "
        cQuery += " F32_SUPUN AS SUPP_BRANCH, "
        cQuery += " F32_VATCOD AS INTCODE, "
        cQuery += " F32_VATCD2 AS EXTCODE, "
        cQuery += " F32_INIBS AS INIT_BASE, "
        cQuery += " F32_INIBAL AS INIT_VALUE, "
        cQuery += " F32_RESTVL AS REST_BAL, "
        cQuery += " F32_RESTBS AS REST_BASE, "
        cQuery += " F32_PDATE AS PRINT_DATE, "
        cQuery += " F32_VATRT AS VAT_RATE "
        cQuery += " FROM " + RetSQLName("F32") + " AS T0 "
        cQuery += " WHERE F32_FILIAL = '" + xFilial("F32") + "' "
        For nLine := 1 to oSubModel:Length(.F.)
            oSubModel:GoLine(nLine)
            If !Empty(AllTrim(oSubModel:GetValue("F53_KEY")))
                // Excludes the records which are already in the model from SQL select.
                cQuery += " AND NOT ("
                cQuery += " T0.F32_KEY = '" + oSubModel:GetValue("F53_KEY") + "'" 
                cQuery += " AND T0.F32_VATCOD = '" + oSubModel:GetValue("F53_OVTCOD") + "'"
                cQuery += " )"
            EndIf
        Next nLine
        If (cField == "F53_DOC")
            cQuery += " AND F32_DOC = '" + xValue + "' "
        ElseIf (cField == "F53_KEY")
            cQuery += " AND F32_KEY = '" + xValue + "' "
        EndIf
        cQuery += " AND F32_RESTBS < F32_INIBS"
        cQuery += " AND D_E_L_E_T_ = ' '"
        cQuery += " ORDER BY F32_FILIAL,"
        cQuery += " F32_SUPPL,"
        cQuery += " F32_SUPUN,"
        cQuery += " F32_DOC,"
        cQuery += " F32_RDATE,"
        cQuery += " F32_KEY,"
        cQuery += " F32_VATCOD,"
        cQuery += " F32_VATCD2"
        cTab := MPSysOpenQuery(ChangeQuery(cQuery))

        // If no Purchases VAT Invoices with such Document Number were found.
        If (cTab)->(Eof())
            lRet := .F.
            Help("",1,"RU09T08EventRUS:GridLinePreVld_07",,STR0010,2,0,,,,,, /*solucao*/)
        EndIf

        If lRet
            lRet := lRet .and. self:FillF53Table(oSubModel, cTab, 100.00)
        EndIf

        CloseTempTable(cTab)
    EndIf

ElseIf lRet .and. (cAction == "SETVALUE") .and. (cField $ "F53_RESTBS|F53_RESTVL|F53_RESTRT")
    nRestBsAvailable := oSubModel:getValue("F53_AVLBBS")
    nRestVlAvailable := oSubModel:getValue("F53_AVLBVL")

    If (cField == "F53_RESTBS")
        nRestBs := xValue
        
        If (nRestBs > nRestBsAvailable)
            lRet := .F.
            Help("",1,"RU09T08EventRUS:GridLinePreVld_02",,STR0007 + STR(Round(nRestBsAvailable, 2)),2,0,,,,,, /*solucao*/)
        Else
            // Restoration % Rate = Restoration Base / Initial Base
            nRestRate := Round(nRestBs / oSubModel:getValue("F53_INIBS") * 100.00, 2)
            // Restoration Value = Restoration Base * Restoration % Rate
            nRestVl := Round(nRestBs * oSubModel:GetValue("F53_VATRT") / 100.00, 2)
        EndIf

    ElseIf (cField == "F53_RESTVL")
        nRestVl := xValue
    
        If (nRestVl > nRestVlAvailable)
            lRet := .F.
            Help("",1,"RU09T08EventRUS:GridLinePreVld_03",,STR0007 + STR(Round(nRestVlAvailable, 2)),2,0,,,,,, /*solucao*/)
        Else
            // Restoration Base = Initial Base * Restoration Value / Initial Balance
            nRestBs := Round(nRestVl / oSubModel:getValue("F53_VATRT") * 100.00, 2)
            // Restoration % Rate = Restoration Base / Initial Base
            nRestRate := Round(nRestVl / oSubModel:getValue("F53_INIBAL") * 100.00, 2)
        EndIf

    ElseIf (cField == "F53_RESTRT")
        nRestRate := xValue
        // Restoration Base = Restoration % Rate * Initial Base
        nRestBs := Round(nRestRate * oSubModel:getValue("F53_INIBS") / 100.00, 2)
        // Restoration Value = Restoration % Rate * Initial Balance
        nRestVl := Round(nRestRate * oSubModel:getValue("F53_INIBAL") / 100.00, 2)
        
        If ( (nRestBs > nRestBsAvailable) .or. (nRestVl > nRestVlAvailable) )
            lRet := .F.
            Help("",1,"RU09T08EventRUS:GridLinePreVld_04",,STR0007 + STR(Round(nRestBsAvailable / FWFldGet("F53_INIBS") * 100.00, 2)),2,0,,,,,, /*solucao*/)
        EndIf
    EndIf

    If lRet
        nOldRestVl := oSubModel:GetValue("F53_RESTVL")

        lRet := lRet .and. oSubModel:LoadValue("F53_RESTBS", nRestBs)
        lRet := lRet .and. oSubModel:LoadValue("F53_RESTRT", nRestRate)
        lRet := lRet .and. oSubModel:LoadValue("F53_RESTVL", nRestVl)

        lRet := lRet .and. self:RfrshF52Ttl(-nOldRestVl+nRestVl)

        If !lRet
            Help("",1,"RU09T08EventRUS:GridLinePreVld_05",,STR0008,2,0,,,,,, /*solucao*/)
        EndIf
    EndIf

ElseIf lRet .and. (cAction == "DELETE")
    lRet := lRet .and. self:RfrshF52Ttl(-oSubModel:GetValue("F53_RESTVL"))

ElseIf lRet .and. (cAction == "UNDELETE")
    lRet := lRet .and. self:RfrshF52Ttl(oSubModel:GetValue("F53_RESTVL"))
EndIf
Return(lRet)



/*{Protheus.doc} RU09T08EventRUS:Activate()
@type       method
@author     Artem Kostin
@since      27/07/2018
@version    P12.1.21
*/
Method Activate(oModel, lCopy) Class RU09T08EventRUS
Local lRet      := .T.

Local nLine     := 1
Local nOper     := oModel:GetOperation()
Local oModelF53 := oModel:getModel("F53DETAIL")

Default lCopy   := .F.
aValAnt:={}
If ((nOper == MODEL_OPERATION_UPDATE) .or. (nOper == MODEL_OPERATION_INSERT))
    For nLine := 1 to oModelF53:Length(.F.)
        oModelF53:SetLine(nLine)

        lRet := lRet .and. oModelF53:LoadValue("F53_RBSBKP", FWFldGet("F53_RESTBS"))
        lRet := lRet .and. oModelF53:LoadValue("F53_RVLBKP", FWFldGet("F53_RESTVL"))
        lRet := lRet .and. oModelF53:LoadValue("F53_NVTCDB", FWFldGet("F53_NVTCOD"))

        If !lRet
            Help("",1,"RU09T08EventRUS:Activate_01",,STR0008,2,0,,,,,, /*solucao*/)
            Exit
        EndIf
        If (nOper == MODEL_OPERATION_UPDATE)
            aAdd(aValAnt,{oModelF53:GetDataId(nLine) , oModelF53:getvalue("F53_RESTVL")}) //TODORFL
        Endif
    Next nLine
EndIf

Return(lRet)



/*/{Protheus.doc} FillF53Table
Creates the view for the VAT Restoration
@author Artem Kostin
@since 10/08/2018
@version P12.1.21
@type method
/*/
Method FillF53Table(oModelF53, cTab, nUserRestRate, cTargetCode, cNewVATCode) Class RU09T08EventRUS
Local lRet := .T.

Local oModel as Object
Local lAddLine := .T.
Local nLine := 1

Local nRestRate := 0
Local nRestBsAvl := 0
Local nRestVlAvl := 0
Local nRestValTotal := 0

Local cQuery := ""
Local cTabF31 := ""
Local cExtCode := Space(TamSX3("F31_OPCODE")[1])


Default nUserRestRate := 100.00
Default cTargetCode := Space(TamSX3("F31_CODE")[1])
Default cNewVATCode := Space(TamSX3("F31_CODE")[1])

cQuery := " SELECT F31_OPCODE AS EXTCODE"
cQuery += " FROM " + RetSQLName("F31") + " T0"
cQuery += " WHERE D_E_L_E_T_ = ' '"
cQuery += " AND F31_FILIAL = '" + xFilial("F31") + "'"
cQuery += " AND F31_CODE = '" + cTargetCode + "'"
cTabF31 := MPSysOpenQuery(ChangeQuery(cQuery))
If ! (cTabF31)->(Eof())
    cExtCode := (cTabF31)->EXTCODE
EndIf
CloseTempTable(cTabF31)

oModel := FWModelActive()
If (ValType(oModel) != "O") .or. (oModel:getId() != "RU09T08")
    lRet := .F.
    Help("",1,"FillF53Table_02",,STR0011,2,0,,,,,, /*solucao*/)
EndIf

// If there is already an empty line, data could be inserted starting from this empty line.
// If there is no empty line, add new line and push new data to the bottom of the grid.
lAddLine := !Empty(AllTrim(oModelF53:GetValue("F53_KEY")))

// Loading new data selected by query at the end of the grid.
While !(cTab)->(Eof())
    If lAddLine
        nLine := oModelF53:AddLine()
    Else
        nLine := oModelF53:Length()
        lAddLine := .T.
    EndIf

    nRestBsAvl := (cTab)->INIT_BASE - (cTab)->REST_BASE
    nRestVlAvl := (cTab)->INIT_VALUE - (cTab)->REST_BAL
    nRestRate := min(nRestBsAvl / (cTab)->INIT_BASE * 100.00, nUserRestRate)
    // F53_FILIAL is filled by relation between F52MASTER and F53DETAIL.
    // F53_RESKEY is filled by relation between F52MASTER and F53DETAIL.
    // F53_CODE is filled by relation between F52MASTER and F53DETAIL.
    lRet := lRet .and. oModelF53:LoadValue("F53_ITEM", StrZero(nLine, GetSX3Cache("F53_ITEM", "X3_TAMANHO")))
    lRet := lRet .and. oModelF53:LoadValue("F53_PDATE", StoD((cTab)->PRINT_DATE))    // Purchase VAT Invoice Print Date
    lRet := lRet .and. oModelF53:LoadValue("F53_KEY", (cTab)->VAT_KEY)	// Purchase VAT Invoice Key.

    lRet := lRet .and. oModelF53:LoadValue("F53_DOC", (cTab)->DOC_NUM)	// Purchase VAT Invoice Document Number.
    lRet := lRet .and. oModelF53:LoadValue("F53_SUPPL", (cTab)->SUPPLIER)	// Purchase VAT Invoice Document Number.
    lRet := lRet .and. oModelF53:LoadValue("F53_SUPUN", (cTab)->SUPP_BRANCH)  // Purchase VAT Invoice Internal Code.
    lRet := lRet .and. oModelF53:LoadValue("F53_OVTCOD", (cTab)->INTCODE)  // Internal VAT Code of Purchase VAT Invoice
    lRet := lRet .and. oModelF53:LoadValue("F53_NTGCOD", cTargetCode)
    lRet := lRet .and. oModelF53:LoadValue("F53_NVTCD2", cExtCode)
    If (FWFldGet("F52_WRIOFF") == "2")
        lRet := lRet .and. oModelF53:LoadValue("F53_NVTCOD", cNewVATCode)
    EndIf
    lRet := lRet .and. oModelF53:LoadValue("F53_RESTRT", nRestRate) // Percentage of Restoration Base Value, which will be written off.
    // If user's rate is 100%, copy values from SQL query to avoid precision errors.
    If (nUserRestRate > nRestRate) .or. (nUserRestRate == 100.00)
        lRet := lRet .and. oModelF53:LoadValue("F53_RESTBS", nRestBsAvl)    // Restoration Base Value.
        lRet := lRet .and. oModelF53:LoadValue("F53_RESTVL", nRestVlAvl) // Restoration Value = Restoration Base * Restoration Percents
        nRestValTotal += nRestVlAvl
    Else
        lRet := lRet .and. oModelF53:LoadValue("F53_RESTBS", nRestRate * nRestBsAvl / 100)    // Restoration Base Value.
        lRet := lRet .and. oModelF53:LoadValue("F53_RESTVL", nRestRate * nRestVlAvl / 100) // Restoration Value = Restoration Base * Restoration Percents
        nRestValTotal += nRestRate * nRestVlAvl / 100
    EndIf

    // Temporary fields to control restrictions.
    lRet := lRet .and. oModelF53:LoadValue("F53_RBSBKP", 0)
    lRet := lRet .and. oModelF53:LoadValue("F53_RVLBKP", 0)
    lRet := lRet .and. oModelF53:LoadValue("F53_AVLBBS", nRestBsAvl)
    lRet := lRet .and. oModelF53:LoadValue("F53_AVLBVL", nRestVlAvl)
    // Virtual fields to inform user.
    lRet := lRet .and. oModelF53:LoadValue("F53_INIBS", (cTab)->INIT_BASE)  // Purchase VAT Invoice Initial Base
    lRet := lRet .and. oModelF53:LoadValue("F53_VATRT", (cTab)->VAT_RATE)   // Purchase VAT Invoice Tax Rate
    lRet := lRet .and. oModelF53:LoadValue("F53_INIBAL", (cTab)->INIT_VALUE)  // Purchase VAT Invoice Initial Tax Value

    (cTab)->(DbSkip())
EndDo

lRet := lRet .and. self:RfrshF52Ttl(nRestValTotal)

If !lRet
    Help("",1,"FillF53Table_01",,STR0008,2,0,,,,,, /*solucao*/)
EndIf
Return(lRet)



// Recalculates total
Method RfrshF52Ttl(nRestValDiff) Class RU09T08EventRUS
Local lRet := .T.
Local nRestValTotal := FWFldGet("F52_TOTAL") + nRestValDiff
// Saves the handle of focused object because oView::refresh() changes focus
Local nFocus := GetFocus()

If FWFldPut("F52_TOTAL", nRestValTotal, /*nLinha*/, /*oModel*/, .T., .T.)
    // Refreshes the oView object
    oView := FwViewActive()
    If (oView != Nil) .and. (oView:GetModel():GetId() == "RU09T08")
        oView:Refresh()
        // Retores saved focus
        SetFocus(nFocus)
    EndIf
Else
    lRet := .F.
    Help("",1,"RfrshF52Ttl_01",,STR0008,2,0,,,,,, /*solucao*/)
EndIf
Return(lRet)



/*/{Protheus.doc} FiltVATInvoices
 
Creates the view for the VAT Restoration
@author Artem Kostin
@since 10/08/2018
@version P12.1.21
@type method
/*/
Method FiltVATInvoices(oModel) Class RU09T08EventRUS
Local lRet := .T.

Local oModelF53 := oModel:GetModel("F53DETAIL")

Local nLine := 1

Local cTab := ""
Local cQuery := ""

// Shows user a window with filtering questions.
lRet := lRet .and. Pergunte("RU09T03FLT", .T.)

If lRet
    // Fiter Invoices from the Balances table.
    cQuery := " SELECT T0.F32_KEY AS VAT_KEY,"
    cQuery += " T0.F32_DOC AS DOC_NUM,"
    cQuery += " T0.F32_SUPPL AS SUPPLIER,"
    cQuery += " T0.F32_SUPUN AS SUPP_BRANCH,"
    cQuery += " T0.F32_PDATE AS PRINT_DATE,"
    cQuery += " T0.F32_VATCOD AS INTCODE,"
    cQuery += " T0.F32_VATCD2 AS EXTCODE,"
    cQuery += " T0.F32_RESTVL AS REST_BAL, "
    cQuery += " T0.F32_RESTBS AS REST_BASE, "
    cQuery += " T0.F32_INIBS AS INIT_BASE,"
    cQuery += " T0.F32_VATRT AS VAT_RATE,"
    cQuery += " T0.F32_INIBAL AS INIT_VALUE"
    cQuery += " FROM " + RetSQLName("F32") + " T0"
    cQuery += " INNER JOIN " + RetSQLName("F37") + " T1"
    cQuery += " ON ("
    cQuery += " T1.F37_FILIAL = '" + xFilial("F37") + "'"
    cQuery += " AND T1.D_E_L_E_T_ = ' '"
    cQuery += " AND T1.F37_DOC BETWEEN '" + AllTrim(mv_par01) + "' AND '" +  AllTrim(mv_par02) + "'"
    cQuery += " AND T1.F37_RDATE BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "'"
    cQuery += " AND	T1.F37_FORNEC BETWEEN '" + AllTrim(mv_par06) + "' AND '" + AllTrim(mv_par08) + "'"
    cQuery += " AND	T1.F37_BRANCH BETWEEN '" + AllTrim(mv_par07) + "' AND '" + AllTrim(mv_par09) + "'"
    cQuery += ")"
    cQuery += " WHERE T0.F32_FILIAL = '" + xFilial("F32") + "'"
    If !Empty(AllTrim(mv_par05))
        cQuery += " AND T0.F32_VATCOD = '" + AllTrim(mv_par05) + "'"
    EndIf
    // Excludes VAT Invoices which are already in the Model by Internal keys.
    For nLine := 1 to oModelF53:Length(.F.)
        oModelF53:GoLine(nLine)
        If !Empty(AllTrim(oModelF53:GetValue("F53_KEY")))
            cQuery += " AND NOT ("
            cQuery += " T0.F32_KEY = '" + oModelF53:GetValue("F53_KEY") + "'" 
            cQuery += " AND T0.F32_VATCOD = '" + oModelF53:GetValue("F53_OVTCOD") + "'"
            cQuery += " )"
        EndIf
    Next nLine
    cQuery += " AND T0.F32_KEY = T1.F37_KEY"
    cQuery += " AND F32_RESTBS < F32_INIBS"
    cQuery += " AND T0.D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY T0.F32_FILIAL"
    cQuery += " ,SUPPLIER"
    cQuery += " ,SUPP_BRANCH"
    cQuery += " ,DOC_NUM"
    cQuery += " ,PRINT_DATE"
    cQuery += " ,VAT_KEY"
    cQuery += " ,INTCODE"
    cQuery += " ,EXTCODE"
    cTab := MPSysOpenQuery(ChangeQuery(cQuery))

    // If no Purchases VAT Invoices with such Document Number were found.
    If (cTab)->(Eof())
        lRet := .F.
        Help("",1,"RU09T08EventRUS:FiltVATInvoices_01",,STR0010,2,0,,,,,, /*solucao*/)
    EndIf

    If lRet
        lRet := lRet .and. self:FillF53Table(oModelF53, cTab, mv_par10, mv_par11, mv_par12)
    EndIf

    oModelF53:GoLine(1)
EndIf

CloseTempTable(cTab)
Return(lRet)

/*{Protheus.doc} RU09T08EventRUS:OpenCTB
@type       method
@author     Daria Sergeeva
@since      10/01/2020
@version    P12.1.30
*/
Method OpenCTB(oModel) Class RU09T08EventRUS

Local nOperat := oModel:GetOperation()
Local oModelF52:=oModel:GetModel("F52MASTER")
if nOperat==MODEL_OPERATION_DELETE .And.  !Empty(F52_DTLA)
    self:cPadrao        := Iif(nOperat == MODEL_OPERATION_DELETE,"6AJ","6AI")//Variable with accounting total
    self:nTotal         := 0//Array with informations for accounting flag record
    self:aFlagCTB       := {}//Handler (working file number) used on accounting
    self:nHdlPrv        := 0//accounting lot. Each model has a corresponding lot configured on the table 09 of SX5
    self:cLoteFis          := LoteCont("FIS")//Temporary file used on accounting
    self:cOrigem := "RU09T08ACC"
    self:cArquivo       := ""// Function which verify if the accounting entry was configured by customer
    If VerPadrao(self:cPadrao) // Accounting beginning
        self:nHdlPrv := HeadProva(self:cLoteFis, self:cOrigem, SubStr(cUserName, 1, 6), @self:cArquivo)
        If nOperat != MODEL_OPERATION_DELETE
            oModelF52:SetValue("F52_DTLA",dDataBase)  
        EndIf
    EndIf
EndIf
Return

/*{Protheus.doc} RU09T08EventRUS:WriteLinesCTB
@type       method
@author     Daria Sergeeva
@since      10/01/2020
@version    P12.1.30
*/
Method WriteLinesCTB(oModel, cModelId, cAlias, lNewRecord) Class RU09T08EventRUS
Local nOperat := oModel:GetOperation()
Local aArea := GetArea()
Local aAreaF37 := F37->(GetArea())
Local aAreaF38 := F38->(GetArea())
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local lRet:=.T.

If nOperat==MODEL_OPERATION_DELETE .And. !Empty(F52_DTLA)
    If cAlias == "F53"
        DbSelectArea("F37")
        F37->(DbSetOrder(7))
        If (F37->(DbSeek(xFilial("F37")+F53->F53_DOC)))
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
            Help("",1,"RU09T08EventRUS:WriteLinesCTB_01",,/*STR0023*/,1,0) // "VAT Sales Invoice Header of this record was not found. Cannot delete this record."
            lRet := .F.
        EndIf   
        
        if lRet
            nValAnt := 0
            nPosnAt := aScan(aValAnt,{|x| x[1] == F53->(Recno()) })
            If nPosnAt > 0
                nValAnt := aValAnt[nPosnAt,2]
            EndIf
            If (self:nHdlPrv > 0)
                self:nTotal += DetProva(self:nHdlPrv, self:cPadrao, self:cOrigem, self:cLoteFis, /*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, ;
                xFilial("F52") + F52->F52_RESKEY /*cChaveBusca */, /*aCT5*/,;
            /*lPosiciona*/, /*@aFlagCTB*/, {'F52',F52->(Recno())} /*aTabRecOri*/, /*aDadosProva*/)  
            EndIf
        EndIf      
    EndIf                
EndIf  
    
RestArea(aArea)
RestArea(aAreaF37)
RestArea(aAreaF38)
RestArea(aAreaSF1)
RestArea(aAreaSA2)
Return

/*{Protheus.doc} RU09T08EventRUS:CloseCTB
@type       method
@author     Daria Sergeeva
@since      10/01/2020
@version    P12.1.30
*/
Method CloseCTB(oModel) Class RU09T08EventRUS
Local lMostra   as Logical// Verify if it's needed to group entries with the same accounting entities'
Local lAglutina as Logigal
Local nOperat := oModel:GetOperation()
cPerg := "RU09T08ACC"
If nOperat==MODEL_OPERATION_DELETE .And. !Empty(F52_DTLA)
    Pergunte(cPerg, .F.)
    lMostra   := (mv_par01 == 1)
    lAglutina := (mv_par02 == 1)
    If self:nHdlPrv > 0 .And. ( self:nTotal > 0 )// Function that closes the accounting lot
        cA100Incl(self:cArquivo,self:nHdlPrv,3,self:cLoteFis,lMostra,lAglutina)
        RodaProva(self:nHdlPrv, self:nTotal) // Function that shows the account dialog, performs the grouping if needed and records the accounting document ( CT2 )
    EndIf
EndIf
Return

/*{Protheus.doc} RU09T08EventRUS:After
@type       method
@author     Daria Sergeeva
@since      10/01/2020
@version    P12.1.30
*/
Method After(oModel, cModelId, cAlias, lNewRecord)  Class RU09T08EventRUS
    self:WriteLinesCTB(oModel:getModel(),cModelId,cAlias,lNewRecord)
Return

/*{Protheus.doc} RU09T08EventRUS:BeforeTTS
@type       method
@author     Daria Sergeeva
@since      10/01/2020
@version    P12.1.30
*/
Method BeforeTTS(oModel, cModelId) Class RU09T08EventRUS
    self:OpenCTB(oModel)
Return

/*{Protheus.doc} RU09T08EventRUS:AfterTTS
@type       method
@author     Daria Sergeeva
@since      10/01/2020
@version    P12.1.30
*/
Method AfterTTS(oModel, cModelId)  Class RU09T08EventRUS
    self:CloseCTB(oModel)
Return

/*{Protheus.doc} RU09T05EventRUS
@type 		method
@author Daria Sergeeva 
@since 11/02/2020
@version 	P12.1.25
*/
Method VldActivate(oModel, cModelID) Class RU09T08EventRUS
    Local lRet		:= .T.
    Local nOperation:= oModel:GetOperation() 
    lRet:=lRet .And. (nOperation != MODEL_OPERATION_UPDATE .Or. FWIsInCallStack('RU09T08CTS_VATREST') .Or. FWIsInCallStack('RU09T08CTB_VATREST') .Or. Empty(F52_DTLA)) 
Return lRet