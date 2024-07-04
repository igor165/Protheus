#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01T01RUS.CH'

#define F4Q_OPER_EXECUTION          "1"
#define F4Q_OPER_STORNO             "2"
#define F4R_STATUS_NOT_CONFIRMED    "0"
#define F4R_STATUS_CONFIRMED        "1"
#define F4R_STATUS_STORNOED         "2"
#define SN3_OPER_IN_OPERATION       "1"
#define SN3_OPER_NOT_IN_OPERATION   "2"
#define SN3_BAIXA_WRITTEN_OFF       "1"

#define RU01T01_OPER_PUT            1
#define RU01T01_OPER_STORNO         2

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01RUS

Putting into operation

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01RUS()
Local lRet			AS LOGICAL
Private oBrowse		AS OBJECT
Private cCadastro	AS CHARACTER
Private aEnableButtons AS ARRAY

lRet		:= .T.
cCadastro	:= STR0001	//"Putting into Operation"
aEnableButtons	:= {{.F.,Nil},;	// 1 - Copiar
					{.F.,Nil},;	// 2 - Recortar
					{.F.,Nil},;	// 3 - Colar
					{.F.,Nil},;	// 4 - Calculadora
					{.F.,Nil},;	// 5 - Spool
					{.F.,Nil},;	// 6 - Imprimir
					{.T.,Nil},;	// 7 - Confirmar
					{.T.,Nil},;	// 8 - Cancelar
					{.F.,Nil},;	// 9 - WalkTrhough
					{.F.,Nil},;	// 10 - Ambiente
					{.F.,Nil},;	// 11 - Mashup
					{.T.,Nil},;	// 12 - Help
					{.F.,Nil},;	// 13 - Formulario HTML
					{.F.,Nil}}	// 14 - ECM

dbSelectArea("F4Q")
dbSetOrder(1)	//F4Q_FILIAL+F4Q_LOT

oBrowse		:= BrowseDef()
oBrowse:Activate()

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse defition

@param		None
@return		OBJECT oBrowse
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
oBrowse		:= FWMBrowse():New()
oBrowse:SetDescription(STR0001) //"Putting into Operation"
oBrowse:SetAlias("F4Q")
Return oBrowse

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu defition

@param		None
@return		ARRAY aRotina
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
aAdd(aRotina, {STR0002, "RU01T01INC()",                 0, 3, 0, Nil, Nil, Nil}) //"Put Into Operation"
aAdd(aRotina, {STR0003, "RU01T01VIE",              0, 2, 0, Nil, Nil, Nil}) //"View"
aAdd(aRotina, {STR0004, "RU01T01STO()",                 0, 5, 0, Nil, Nil, Nil}) //"Storno"
aAdd(aRotina, {STR0005, "RU01S02RUS('F4Q','F4R',1,1)",  0, 2, 0, Nil, Nil, Nil}) //"Accounting Tracker"
aAdd(aRotina, {STR0006, "RU01T01FIL",                   0, 2, 0, Nil, Nil, Nil}) //"Filter Related Lots"
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01VIE

View function

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01VIE(oModel AS OBJECT)
Local lRet      AS LOGICAL
lRet    := .T.

If lRet .And. ValType("oModel") <> "O"
    oModel      := FWLoadModel("RU01T01")
    oModel:SetOperation(MODEL_OPERATION_VIEW)
    oModel:Activate()
EndIf

If lRet
    dbSelectArea("F4Q")
    FWExecView(STR0001, "RU01T01", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Putting into operation"
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01INC

Inclusion function

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01INC(oModel AS OBJECT)
Local nX        AS NUMERIC
Local cQuery    AS CHARACTER
Local lRet      AS LOGICAL
Local lLoadData AS LOGICAL
Local dLastDep  AS DATE
Local aSN3Field AS ARRAY
Local bPadField AS BLOCK
Local oStruSN3  AS OBJECT
Local oModelGrd AS OBJECT

bPadField   := {|cStr, cField| PADR(cStr, GetSX3Cache(cField, "X3_TAMANHO"))}
lRet        := .T.

// Current month posterior to last monthly calculation
If lRet
    dLastDep	:= SuperGetMV("MV_ULTDEPR", .F.)
    lRet        := ;
        Month(dDataBase) == Month(dLastDep + 1) .And. ;
        Year(dDataBase) == Year(dLastDep + 1)
    If ! lRet
        Help("",1,"RU01T01DATE",,STR0007,1,0)	//"Putting into operation should be performed on the month posterior to the last amortization calculation"
    EndIf
EndIf

// Prepare oModel
lLoadData   := .F.
If lRet .And. ValType(oModel) <> "O"
    oModel      := FWLoadModel("RU01T01")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    lLoadData   := .T.
EndIf

// Ask user about parameters
If lRet .And. lLoadData
    lRet        := Pergunte("ATFA012PUT", !IsBlind())
EndIf

// Continue with data fetching if required
If lRet .And. lLoadData
    oModel:Activate()
    oModel:GetModel("F4QMASTER"):SetValue("F4Q_DESCR", STR0018) //"Execution of putting into operation"
    oModelGrd   := oModel:GetModel("SN3DETAIL")
    oStruSN3    := oModelGrd:GetStruct()
    aSN3Field   := oStruSN3:GetFields()
    cQuery  := " SELECT SN3.R_E_C_N_O_ AS N3RECNO "
    For nX := 1 To Len(aSN3Field)
        If ! (aSN3Field[nX, MODEL_FIELD_IDFIELD] $ "MVC_OK|N3_DINDEPR|MVC_HISTOR")
            cQuery  += "," + aSN3Field[nX, MODEL_FIELD_IDFIELD]
        EndIf
    Next nX
    cQuery  += ",'"+DToS(LastDay(dDataBase)+1)+"' AS N3_DINDEPR "
    cQuery  += " FROM "+RetSqlName("SN1")+" SN1 "
    cQuery  += " JOIN "+RetSqlName("SN3")+" SN3  ON N3_CBASE = N1_CBASE "
    cQuery  += "                 AND N3_ITEM = N1_ITEM "
    cQuery  += " WHERE SN1.D_E_L_E_T_ = ' ' "
    cQuery  += "  AND SN3.D_E_L_E_T_ = ' ' "
    cQuery  += "  AND N1_FILIAL = '"+xFilial("SN1")+"' "
    cQuery  += "  AND N3_FILIAL = '"+xFilial("SN3")+"' "
    cQuery  += "  AND N3_OPER <> '"+SN3_OPER_IN_OPERATION+"' "
    cQuery  += "  AND N3_BAIXA <> '"+SN3_BAIXA_WRITTEN_OFF+"' "
    cQuery  += "  AND N3_TIPO IN ('01','"+AtfNValMod({1,2,3},"','")+"') " // Tax + Managerial types
    cQuery  += "  AND N1_CBASE BETWEEN '"+Eval(bPadField, MV_PAR01, "N1_CBASE")+"' AND '"+Eval(bPadField, MV_PAR02, "N1_CBASE")+"' "
    cQuery  += "  AND N3_TIPO BETWEEN '"+Eval(bPadField, MV_PAR03, "N3_TIPO")+"' AND '"+Eval(bPadField, MV_PAR04, "N3_TIPO")+"' "
    cQuery  += "  AND N1_GRUPO BETWEEN '"+Eval(bPadField, MV_PAR05, "N1_GRUPO")+"' AND '"+Eval(bPadField, MV_PAR06, "N1_GRUPO")+"' "
    cQuery  += "  AND N3_AQUISIC BETWEEN '"+DToS(MV_PAR07)+"' AND '"+DToS(MV_PAR08)+"' "
    cQuery  += " ORDER BY 1, 2, 3 "
    cQuery  := ChangeQuery(cQuery)
    
    // Insert query results into model
    oModelGrd:SetNoInsertLine(.F.)
    lRet    := RU01QRY2MD( ;
        cQuery, ;
        oModelGrd, ;
        .T. /* lGrid */, ;
        .F. /* lAddFirstLine */, ;
        {"MVC_OK","N3_DINDEPR","MVC_HISTOR"} /* aIgnoreFld */, ;
        {|oMdl| ProcGridInsert(oMdl)} /* bPosInsert */)
    oModelGrd:SetNoInsertLine(.T.)

    If ! lRet
        Help("",1,"RU01T01ARQVAZIO",,STR0012,1,0)	//"No fixed assets match the criteria"
    EndIf
EndIf

// Execute MVC View
If lRet
    dbSelectArea("F4Q")
    FWExecView(STR0001, "RU01T01", MODEL_OPERATION_INSERT, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Putting into operation"
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ProcGridInsert

Function to process pos line insert on grid

@param		OBJECT oModel
@return		None
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ProcGridInsert(oModel AS OBJECT)
Local cHistory      AS CHARACTER
Local nOper as NUMERIC
nOper       := GetOperation()

If nOper == RU01T01_OPER_PUT
	cHistory    := STR0020 
ElseIf nOper == RU01T01_OPER_STORNO
	cHistory    := STR0035 + " "
EndIf

cHistory    += Alltrim(oModel:GetValue("N3_CBASE")) + "-"
cHistory    += AllTrim(oModel:GetValue("N3_ITEM")) + "/"
cHistory    += AllTrim(oModel:GetValue("N3_TIPO"))

If nOper == RU01T01_OPER_PUT
    oModel:SetValue("MVC_OK", .T.)
    oModel:SetValue("N3_DINDEPR", LastDay(dDataBase) + 1)
    oModel:SetValue("MVC_HISTOR", cHistory)
ElseIf nOper == RU01T01_OPER_STORNO
    oModel:SetValue("MVC_STOHIS", cHistory)
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01STO

Storno function

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01STO(oModel AS OBJECT)
Local lRet      AS LOGICAL
Local dLastDep  AS DATE
Local nX        AS NUMERIC
lRet        := .T.

// Currently selected lot register must be of type execution
If lRet
    lRet    := F4Q->F4Q_OPER == F4Q_OPER_EXECUTION
    If ! lRet
        Help("",1,"RU01T01STVL01",,STR0021,1,0)	//"Currently selected lot register must be of type execution"
    EndIf
EndIf

// Current month posterior to last monthly calculation
If lRet
    dLastDep	:= SuperGetMV("MV_ULTDEPR", .F.)
    lRet        := ;
        Month(dDataBase) == Month(dLastDep + 1) .And. ;
        Year(dDataBase) == Year(dLastDep + 1)
    If ! lRet
        Help("",1,"RU01T01STVL02",,STR0022,1,0)	//"Storno of putting into operation should be performed on the month posterior to the last amortization calculation"
    EndIf
EndIf

// Current month must be the same of performed put into operation
If lRet
    lRet        := ;
        Month(dDataBase) == Month(F4Q->F4Q_DATE) .And. ;
        Year(dDataBase) == Year(F4Q->F4Q_DATE)
    If ! lRet
        Help("",1,"RU01T01STVL03",,STR0033,1,0)	//"Storno of putting into operation must be performed on the same month of the original transaction"
    EndIf
EndIf

// Prepare oModel
If lRet .And. ValType(oModel) <> "O"
    oModel      := FWLoadModel("RU01T01")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
    for nX := 1 to oModel:GetModel("F4RDETAIL"):Length()
        oModel:GetModel("F4RDETAIL"):GoLine(nX)
        ProcGridInsert(oModel:GetModel("F4RDETAIL"))
    Next nX
    oModel:GetModel('F4QMASTER'):LoadValue('MVC_STODES', STR0035)
    oModel:GetModel('F4QMASTER'):LoadValue('F4Q_DESCR', STR0035)
EndIf

// Execute MVC View
If lRet
    dbSelectArea("F4Q")
    FWExecView(STR0001, "RU01T01", MODEL_OPERATION_UPDATE, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Putting into operation"
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetMVCFields

Return MVC fields with separator

@param		None
@return		CHARACTER cFields
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function GetMVCFields()
Local cFields       AS CHARACTER
cFields     := "N3_CBASE|N3_ITEM|N3_TIPO|N3_HISTOR|N3_DINDEPR|N3_CCONTAB|N3_UUID|N3_VORIG" + GetNewPar("MV_ATFMOED", "")
Return cFields

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01VLD

MVC field validation function

@param		OBJECT oVldModel
@param		CHARACTER cVldField
@param		xVldNVal
@param		xVldOVal
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01VLD(oVldModel AS OBJECT, cVldField AS CHARACTER, xVldNVal, xVldOVal)
Local nX        AS NUMERIC
Local cQuery    AS CHARACTER
Local cAliasQry AS CHARACTER
Local cFldCntD  AS CHARACTER
Local lRet      AS LOGICAL
Local dVldDate  AS DATE
Local oModel    AS OBJECT
Local oModelGrd AS OBJECT
Local oView     AS OBJECT
Local oGridObj  AS OBJECT

lRet    := .F.
oModel  := FWModelActive()

If cVldField == "MVC_STOK"
    lRet    := .T.
    
    // Journal item must have confirmed status for storno operation
    If lRet
        lRet    := oVldModel:GetValue("F4R_STATUS") == F4R_STATUS_CONFIRMED
        If ! lRet
            Help("",1,"RU01T01VL01",,STR0026,1,0)   //"Journal item must have confirmed status for storno operation"
        EndIf
    EndIf

    If lRet
        dVldDate    := oModel:GetModel("F4QMASTER"):GetValue("F4Q_DATE")
        If dDataBase < dVldDate
            dVldDate    := dDataBase
        EndIf

        cQuery  := "    SELECT N3_OPER, "
        cQuery  += "           COALESCE(N4_DATA, '        ') AS N4_DATA "
        cQuery  += "      FROM "+RetSqlName("SN3")+" SN3 "
        cQuery  += " LEFT JOIN "+RetSqlName("SN4")+" SN4 "
        cQuery  += "        ON SN4.D_E_L_E_T_ = ' ' "
        cQuery  += "       AND N4_FILIAL = N3_FILIAL "
        cQuery  += "       AND N4_CBASE = N3_CBASE "
        cQuery  += "       AND N4_ITEM = N3_ITEM "
        cQuery  += "       AND N4_OCORR <> '05' "   // Acquisition
        cQuery  += "       AND N4_OCORR <> '61' "   // Put into operation
        cQuery  += "       AND N4_DATA >= '"+DToS(dVldDate)+"' "
        cQuery  += "     WHERE SN3.D_E_L_E_T_ = ' ' "
        cQuery  += "       AND N3_FILIAL = '"+xFilial("SN3")+"' "
        cQuery  += "       AND N3_UUID = '"+oVldModel:GetValue("F4R_SN3")+"' "
        cQuery      := ChangeQuery(cQuery)
        cAliasQry	:= RU01GETALS(cQuery)

        If lRet
            lRet    := (cAliasQry)->N3_OPER == SN3_OPER_IN_OPERATION
            If ! lRet
                Help("",1,"RU01T01VL02",,STR0027,1,0)	//"Marked fixed asset is not in operation"
            EndIf
        EndIf

        If lRet
            lRet    := Empty((cAliasQry)->N4_DATA)
            If ! lRet
                Help("",1,"RU01T01VL03",,STR0028,1,0)	//"Marked fixed asset have further operations and can't be stornoed"
            EndIf
        EndIf

        (cAliasQry)->(dbCloseArea())
    EndIf
ElseIf cVldField == "MVC_CHKALL"
    lRet        := .T.
    If GetOperation() == RU01T01_OPER_STORNO
        oModelGrd   := oModel:GetModel("F4RDETAIL")
    Else
        oModelGrd   := oModel:GetModel("SN3DETAIL")
    EndIf
    For nX := 1 To oModelGrd:Length()
        oModelGrd:GoLine(nX)
        If ! oModelGrd:IsDeleted()
            If GetOperation() == RU01T01_OPER_STORNO
                cFldCntD    := "MVC_STOK"
            Else
                cFldCntD    := "MVC_OK"
            EndIf
            oModelGrd:SetValue(cFldCntD, xVldNVal)
        EndIf
    Next nX
    oView		:= FWViewActive()
    oGridObj	:= oView:GetViewObj("VIEW_GRID")[3]
    oGridObj:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01COM

MVC Commit function

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01COM(oModel AS OBJECT)
Local nX        AS NUMERIC
Local nY        AS NUMERIC
Local nZ        AS NUMERIC
Local nPrevTx   AS NUMERIC
Local nCurRate  AS NUMERIC
Local cF4QLot   AS CHARACTER
Local cF4QDesc  AS CHARACTER
Local cSN3UUID  AS CHARACTER
Local cQuery    AS CHARACTER
Local cAlsTmp   AS CHARACTER
Local cStdEntry AS CHARACTER
Local cAtfCur   AS CHARACTER
Local cKeySN3   AS CHARACTER
local cPatrim   AS CHARACTER
Local cUId      AS CHARACTER
Local lRet      AS LOGICAL
Local lLineOk   AS LOGICAL
Local oModelSN3 AS LOGICAL
Local oModelF4R AS LOGICAL
Local bMVCSetV  AS BLOCK
Local bMVCLoaV  AS BLOCK
Local aSN3Info  AS ARRAY
Local aArea     AS ARRAY
Local aAreaSN1  AS ARRAY
Local aAreaSN3  AS ARRAY
Local aAreaSN4  AS ARRAY
Local aF4RInfos AS ARRAY
Local aCompData AS ARRAY
local aDifCurr  AS ARRAY
Local oMdl012   AS OBJECT
Local oMdl012G  AS OBJECT
Local oMdlJrS   AS OBJECT
Local oMdlJrSH  AS OBJECT
Local oMdlJrSI  AS OBJECT
Local xValue

aArea       := GetArea()
aAreaSN1    := SN1->(GetArea())
aAreaSN3    := SN3->(GetArea())
aAreaSN4    := SN4->(GetArea())

lRet        := .F.
bMVCSetV    := {|oMdl, cField, xVal| lRet := lRet .And. oMdl:SetValue(cField, xVal)}
bMVCLoaV    := {|oMdl, cField, xVal| lRet := lRet .And. oMdl:LoadValue(cField, xVal)}
cStdEntry   := ""
cAtfCur    := GetNewPar("MV_ATFMOED", "")
aCompData   := {}
nCurRate	:= Posicione("SM2", 1, DToS(dDataBase), "M2_MOEDA"+cAtfCur)

If GetOperation() == RU01T01_OPER_PUT
    lRet        := .T.
    cStdEntry   := "8A2"
    cF4QLot     := oModel:GetModel("F4QMASTER"):GetValue("F4Q_LOT")

    If lRet
        oModelSN3   := oModel:GetModel("SN3DETAIL")
        oModelF4R   := oModel:GetModel("F4RDETAIL")
    EndIf

    // Clean F4RDETAIL
    If lRet
        For nX := 1 To oModelF4R:Length()
            If ! oModelF4R:IsDeleted(nX)
                oModelF4R:GoLine(nX)
                oModelF4R:DeleteLine()
            EndIf
        Next nX
    EndIf

    // Insert all marked elements from SN3DETAIL to F4RDETAIL
    If lRet
        oModelF4R:SetNoInsertLine(.F.)
        aSN3Info    := {}
        nY          := 0
        For nX := 1 To oModelSN3:Length()
            If ! oModelSN3:IsDeleted(nX) .And. oModelSN3:GetValue("MVC_OK", nX)
                xValue  := oModelF4R:Length() + 1
                lRet    := xValue == oModelF4R:AddLine()
                If ! lRet
                    RU01MVCERR(oMdlJrS)
                    Exit
                EndIf
                nY++
                xValue  := StrZero(nY, GetSX3Cache("F4R_ITEM", "X3_TAMANHO"))
                Eval(bMVCSetV, oModelF4R, "F4R_ITEM", xValue)
                xValue  := F4R_STATUS_CONFIRMED
                Eval(bMVCSetV, oModelF4R, "F4R_STATUS", xValue)
                xValue  := oModelSN3:GetValue("N3_UUID", nX)
                Eval(bMVCSetV, oModelF4R, "F4R_SN3", xValue)
                xValue  := oModelSN3:GetValue("MVC_HISTOR", nX)
                Eval(bMVCSetV, oModelF4R, "F4R_HIST", xValue)

                If lRet
                    aAdd(aSN3Info, {;
                        oModelSN3:GetValue("N3_UUID", nX),;
                        oModelSN3:GetValue("N3_DINDEPR", nX),;
                        oModelSN3:GetValue("N3_VORIG" + cAtfCur, nX)})
                EndIf
            EndIf

            If ! lRet
                Help("",1,"RU01T01JDVL",,STR0013,1,0)	//"Error on journal detail validation"
                Exit
            EndIf
        Next nX
        oModelF4R:SetNoInsertLine(.T.)

        If lRet .And. Empty(aSN3Info)
            lRet    := .F.
            Help("",1,"RU01T01JDNF",,STR0014,1,0)	//"No fixed assets marked for putting into operation"
        EndIf
    EndIf

    // Perform operations for created F4R registers
    If lRet
        BEGIN TRANSACTION
        For nX := 1 To Len(aSN3Info)
            SN1->(dbSetOrder(1))    //N1_FILIAL+N1_CBASE+N1_ITEM
            SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID
            If  ! SN3->(dbSeek(xFilial("SN3")+aSN3Info[nX,01])) .Or. ;
                ! SN1->(dbSeek(xFilial("SN1")+SN3->(N3_CBASE+N3_ITEM)))
                    lRet    := .F.
                    Help("",1,"RU01T01FAREGNOIS",,STR0015,1,0)	//"Error processing fixed assets registers"
                    DisarmTransaction()
                    Exit
            EndIf

            oMdl012     := FWLoadModel("ATFA012")
            oMdl012:SetOperation(MODEL_OPERATION_UPDATE)
            oMdl012:Activate()
            oMdl012G    := oMdl012:GetModel("SN3DETAIL")
            
            cPatrim := oMdl012:GetModel("SN1MASTER"):GetValue("N1_PATRIM")
            If AtClssVer(cPatrim) .Or. Empty(cPatrim)
                cTypeDep	:= "2"
            Elseif cPatrim $ "CAS"
                cTypeDep	:= "E"
            Else
                cTypeDep	:= "F"
            EndIf

            lLineOk     := .F.
            For nY := 1 To oMdl012G:Length()
                If oMdl012G:GetValue("N3_UUID", nY) == aSN3Info[nX,01]
                    oMdl012G:GoLine(nY)
                    lLineOk := oMdl012G:SetValue("N3_OPER", SN3_OPER_IN_OPERATION)
                    oMdl012G:LoadValue("N3_DINDEPR", aSN3Info[nX,02])
                    oMdl012G:LoadValue("N3_INCOST", aSN3Info[nX,03])
                    cIDMOV  := ""
                    cOcorr  := "61"
                    nPrevTx		:= &(IIf(Val(cAtfCur) > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR') + cAtfCur)
                    aValues  := AtfMultMoe(,,{|x| oMdl012G:GetValue("N3_VORIG" + Alltrim(Str(x)) ) })

                    For nZ := 1 To oModelF4R:Length()
                        oModelF4R:GoLine(nZ)
                        if oMdl012G:GetValue("N3_UUID", nY) ==  oModelF4R:GetValue("F4R_SN3")
                            cUId        := oModelF4R:GetValue("F4R_UID")
                            Exit
                        EndIf
                    Next nZ

                    aCompData   := ATFXCompl(0 , &(IIf(Val(cAtfCur) > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR') + cAtfCur) - nPrevTx,;
                        /*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/,oMdl012G:GetValue("N3_PRODMES"))

                    ATFXMOV(;
                        xFilial("SN3"),;
                        @cIDMOV,;
                        dDataBase,;
                        cOcorr,;
                        oMdl012G:GetValue("N3_CBASE"),;
                        oMdl012G:GetValue("N3_ITEM"),;
                        oMdl012G:GetValue("N3_TIPO"),;
                        oMdl012G:GetValue("N3_BAIXA"),;
                        oMdl012G:GetValue("N3_SEQ"),;
                        oMdl012G:GetValue("N3_SEQREAV"),;
                        "1",;
                        oMdl012:GetModel("SN1MASTER"):GetValue("N1_QUANTD"),;
                        oMdl012G:GetValue("N3_TPSALDO"),;
                        Nil,;
                        aValues,;
                        aCompData,;
                        Nil,;
                        .T.,;
                        Nil,;
                        Nil,;
                        Nil,;
                        Nil,;
                        "RU01T01",;
                        cUID)
                    
                    //(12/10/18): Set information about SN4 register in journal it
                    oModelF4R:GoLine(nZ)
                    Eval(bMVCSetV, oModelF4R, "F4R_SN4UID", SN4->N4_UID)

                    aDifCurr	:= AtfMultMoe(Nil, Nil, {|x| SN4->&("N4_VLROC" + Alltrim(Str(x)) ) })
                    ATFSaldo(;
                        oMdl012G:GetValue("N3_CCONTAB"),;
                        dDataBase,;
                        cTypeDep,;
                        aDifCurr[01],;
                        aDifCurr[02],;
                        aDifCurr[03],;
                        aDifCurr[04],;
                        aDifCurr[05],;
                        "+",;
                        nCurRate,;
                        oMdl012G:GetValue("N3_SUBCCON"),;
                        Nil,;
                        oMdl012G:GetValue("N3_CLVLCON"),;
                        oMdl012G:GetValue("N3_CUSTBEM"),;
                        "1",;
                        aDifCurr)
                    Exit
                EndIf
            Next nY

            If ! lLineOk
                lRet    := .F.
                Help("",1,"RU01T01FAUPE",,STR0016,1,0)	//"SN3 balances update error"
                oMdl012:DeActivate()
                DisarmTransaction()
                Exit
            EndIf

            lRet    := FWFormCommit(oMdl012)
            If ! lRet
                RU01MVCERR(oMdl012)
                DisarmTransaction()
                Exit
            EndIf

            oMdl012:DeActivate()
        Next nX

        oModel:Activate()

        // Clean SN3 registers before commit
        If lRet
            For nX := 1 To oModelSN3:Length()
                oModelSN3:GoLine(nX)
                oModelSN3:DeleteLine()
            Next nX
        EndIf

        // Perform final commit
        If lRet
            lRet    := FWFormCommit(oModel)
            If ! lRet
                DisarmTransaction()
                Help("",1,"RU01T01JDUE",,STR0017,1,0)	//"F4R balances update error"
            EndIf
        EndIf
        END TRANSACTION
    EndIf
ElseIf GetOperation() == RU01T01_OPER_STORNO
    lRet        := .T.
    cStdEntry   := "8A3"
    cF4QDesc    := oModel:GetModel("F4QMASTER"):GetValue("MVC_STODES")
    oModelF4R   := oModel:GetModel("F4RDETAIL")
    aF4RInfos   := {}
    BEGIN TRANSACTION
        // Update previous journal
        If lRet
            For nX := 1 To oModelF4R:Length()
                oModelF4R:GoLine(nX)
                If  ! oModelF4R:IsDeleted() .And. oModelF4R:GetValue("MVC_STOK")
                    If ! RU01T01VLD(oModelF4R, "MVC_STOK", .T., .T.)
                        lRet    := .F.
                        Help("",1,"RU01T01STCV",,STR0029,1,0)	//"Marked storno registers are no longer valid"
                        Exit
                    EndIf

                    aAdd(aF4RInfos, { ;
                        StrZero(Len(aF4RInfos) + 1, GetSX3Cache("F4R_ITEM", "X3_TAMANHO")), ;
                        F4R_STATUS_CONFIRMED, ;             //02
                        oModelF4R:GetValue("F4R_SN3"), ;    //03
                        oModelF4R:GetValue("F4R_LOT"), ;    //04
                        oModelF4R:GetValue("F4R_ITEM"), ;   //05
                        oModelF4R:GetValue("MVC_STOHIS"), ; //06
                        oModelF4R:GetValue("F4R_UID"), ;    //07
                        oModelF4R:GetValue("F4R_SN4UID") ;  //08
                        })

                    xValue  := F4R_STATUS_STORNOED
                    Eval(bMVCLoaV, oModelF4R, "F4R_STATUS", xValue)
                    If ! lRet
                        RU01MVCERR(oModel)
                        Exit
                    EndIf
                EndIf
            Next nX

            If lRet
                lRet    := FWFormCommit(oModel)
                If ! lRet
                    Help("",1,"RU01T01STOM",,STR0031,1,0)	//"Information on confirmation journal is inconsistent"
                EndIf
            EndIf

            oModel:Deactivate()
        EndIf

        // Create new storno journal
        If lRet
            oMdlJrS := FWLoadModel("RU01T01")
            oMdlJrS:SetOperation(MODEL_OPERATION_INSERT)
            oMdlJrS:Activate()

            cF4QLot := oMdlJrS:GetModel("F4QMASTER"):GetValue("F4Q_LOT")

            oMdlJrSH    := oMdlJrS:GetModel("F4QMASTER")
            oMdlJrSI    := oMdlJrS:GetModel("F4RDETAIL")

            xValue  := F4Q_OPER_STORNO
            Eval(bMVCLoaV, oMdlJrSH, "F4Q_OPER", xValue)
            Eval(bMVCLoaV, oMdlJrSH, "F4Q_DESCR", cF4QDesc)

            // Clean F4RDETAIL
            If lRet
                For nX := 1 To oMdlJrSI:Length()
                    If ! oMdlJrSI:IsDeleted(nX)
                        oMdlJrSI:GoLine(nX)
                        oMdlJrSI:DeleteLine()
                    EndIf
                Next nX
            EndIf

            oMdlJrSI:SetNoInsertLine(.F.)
            For nX := 1 To Len(aF4RInfos)
                xValue  := oMdlJrSI:Length() + 1
                lRet    := xValue == oMdlJrSI:AddLine()
                If ! lRet
                    RU01MVCERR(oMdlJrS)
                    Exit
                EndIf

                Eval(bMVCLoaV, oMdlJrSI, "F4R_ITEM", aF4RInfos[nX,01])
                Eval(bMVCLoaV, oMdlJrSI, "F4R_STATUS", aF4RInfos[nX,02])
                Eval(bMVCLoaV, oMdlJrSI, "F4R_SN3", aF4RInfos[nX,03])
                Eval(bMVCLoaV, oMdlJrSI, "F4R_F4RLOT", aF4RInfos[nX,04])
                Eval(bMVCLoaV, oMdlJrSI, "F4R_F4RITE", aF4RInfos[nX,05])
                Eval(bMVCLoaV, oMdlJrSI, "F4R_HIST", aF4RInfos[nX,06])
  
                If ! lRet
                    RU01MVCERR(oMdlJrS)
                    Exit
                EndIf
            Next nX
            oMdlJrSI:SetNoInsertLine(.T.)

            If lRet
                lRet    := FWFormCommit(oMdlJrS)
                If ! lRet
                    Help("",1,"RU01T01STNM",,STR0030,1,0)	//"Information on new storno journal is inconsistent"
                EndIf
            EndIf

            oMdlJrS:Deactivate()
        EndIf

        // Set fixed assets as not in operation
        If lRet
            SN1->(dbSetOrder(1))   //N1_FILIAL+N1_CBASE+N1_ITEM
            SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID
            For nX := 1 To Len(aF4RInfos)
                cSN3UUID    := aF4RInfos[nX, 03]

                oMdl012     := FWLoadModel("ATFA012")
                oMdl012:SetOperation(MODEL_OPERATION_UPDATE)
                
                If  SN3->(! dbSeek(xFilial("SN3") + cSN3UUID)) .Or. ;
                    SN1->(! dbSeek(SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)))
                        lRet    := .F.
                        Help(" ",1,"REGNOIS")
                        Exit
                EndIf

                oMdl012:Activate()
                oMdl012G    := oMdl012:GetModel("SN3DETAIL")
                cPatrim     := oMdl012:GetModel("SN1MASTER"):GetValue("N1_PATRIM")
                lLineOk     := .F.
                For nY := 1 To oMdl012G:Length()
                    If oMdl012G:GetValue("N3_UUID", nY) == cSN3UUID
                        oMdl012G:GoLine(nY)
                        cKeySN3 := xFilial("SN3") 
                        cKeySN3 += oMdl012G:GetValue("N3_CBASE") 
                        cKeySN3 += oMdl012G:GetValue("N3_ITEM")
                        cKeySN3 += oMdl012G:GetValue("N3_TIPO") + oMdl012G:GetValue("N3_SEQ")
                        lRet := lRet .And. RU01STOSN4(cKeySN3,cPatrim,aF4RInfos[nx, 07]/*F4R_UID*/)

                        lLineOk := oMdl012G:SetValue("N3_OPER", SN3_OPER_NOT_IN_OPERATION)
                        //(17/10/18):informatiomn about SN4 register
                        If lLineOk
                            oMdlJrS := FWLoadModel("RU01T01")
                            oMdlJrS:SetOperation(MODEL_OPERATION_UPDATE)
                            oMdlJrS:Activate()
                            oMdlJrS:GetModel("F4RDETAIL"):GoLine(nX)
                            Eval(bMVCLoaV, oMdlJrS:GetModel("F4RDETAIL"), "F4R_SN4UID", SN4->N4_UID)
                            If lLineOk
                                lLineOk    := FWFormCommit(oMdlJrS)
                                If ! lLineOk
                                    lRet   := .F.
                                    Help("",1,"RU01T01STOMSN4",,STR0031,1,0)	//"Information on confirmation journal is inconsistent"
                                EndIf

                                oMdlJrS:Deactivate()
                            EndIf
                        EndIf
                        
                        Exit
                    EndIf
                Next nY
                If ! lLineOk
                    lRet    := .F.
                    Help("",1,"RU01T01FAUPE",,STR0016,1,0)	//"SN3 balances update error"
                    oMdl012:DeActivate()
                    Exit
                EndIf

                lRet    := FWFormCommit(oMdl012)
                If ! lRet
                    RU01MVCERR(oMdl012)
                    DisarmTransaction()
                    Exit
                EndIf

                oMdl012:DeActivate()
            Next nX
        EndIf

        If ! lRet
            DisarmTransaction()
            oModel:Activate()
        EndIf
    END TRANSACTION
EndIf

// Process standard transactions
If lRet .And. ! Empty(cStdEntry)
    lRet    := RU01T01STE(cF4QLot, cStdEntry)
EndIf

RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01STE

Process standard entries 

@param		CHARACTER cLot
@param		CHARACTER cStdEntry
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01STE(cLot AS CHARACTER, cStdEntry AS CHARACTER)
Local cQuery        AS CHARACTER
Local cAlsTmp       AS CHARACTER
Local lDisplay      AS LOGICAL
Local lGroup        AS LOGICAL
Local lOffline      AS LOGICAL
Local aRegisters    AS ARRAY
Local aTmp          AS ARRAY

cQuery  := " SELECT F4Q.R_E_C_N_O_ AS F4QRECNO,"
cQuery  += " F4R.R_E_C_N_O_ AS F4RRECNO,"
cQuery  += " SN3.R_E_C_N_O_ AS SN3RECNO,"
cQuery  += " SN4.R_E_C_N_O_ AS SN4RECNO"
cQuery  += " FROM "+RetSqlName("F4Q")+" F4Q"
cQuery  += " JOIN "+RetSqlName("F4R")+" F4R ON F4R_LOT = F4Q_LOT"
cQuery  += " JOIN "+RetSqlName("SN3")+" SN3 ON N3_UUID = F4R_SN3"
cQuery  += " JOIN "+RetSqlName("SN4")+" SN4 ON N4_UID = F4R_SN4UID"
cQuery  += " WHERE F4Q.D_E_L_E_T_ = ' '"
cQuery  += " AND F4R.D_E_L_E_T_ = ' '"
cQuery  += " AND SN3.D_E_L_E_T_ = ' '"
cQuery  += " AND SN4.D_E_L_E_T_ = ' '"
cQuery  += " AND F4Q_FILIAL = '"+xFilial("F4Q")+"'"
cQuery  += " AND F4R_FILIAL = '"+xFilial("F4R")+"'"
cQuery  += " AND N3_FILIAL = '"+xFilial("SN3")+"'"
cQuery  += " AND N4_FILIAL = '"+xFilial("SN4")+"'"
cQuery  += " AND F4Q_LOT = '"+cLot+"'"
cQuery  += " AND F4R_STATUS = '"+F4R_STATUS_CONFIRMED+"'"
cQuery  += " ORDER BY F4R_LOT, F4R_ITEM"

aRegisters  := {}
cQuery:= Changequery(cQuery)
cAlsTmp     := RU01GETALS(cQuery)

While (cAlsTmp)->(! EOF())
    aTmp    := {}
    aAdd(aTmp, {"F4R", (cAlsTmp)->F4RRECNO})
    aAdd(aTmp, {"F4Q", (cAlsTmp)->F4QRECNO})
    aAdd(aTmp, {"SN3", (cAlsTmp)->SN3RECNO})
    aAdd(aTmp, {"SN4", (cAlsTmp)->SN4RECNO})
    aAdd(aRegisters, aTmp)
    (cAlsTmp)->(dbSkip())
EndDo

(cAlsTmp)->(dbCloseArea())

lDisplay    := Nil
lGroup      := Nil
lOffline    := Nil
If Pergunte("RU01T01RUS", .F.)
    lDisplay    := (MV_PAR01 == 1)
    lGroup      := (MV_PAR02 == 1)
EndIf

lRet    := RU0134STEN(;
    cStdEntry,;
    "RU01T01" /* cRoutine */,;
    "SN4"/* cBaseAlias */,;
    aRegisters,;
    lDisplay,;
    lGroup,;
    lOffline)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

MVC model defition

@param		None
@return		OBJECT oModel MPFormModel()
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local nX            AS NUMERIC
Local cFields		AS CHARACTER
Local aFields		AS ARRAY
Local oStruF4Q		AS OBJECT
Local oStruF4R		AS OBJECT
Local oStruSN3		AS OBJECT
Local oModel		AS OBJECT

cFields     := GetMVCFields()
oStruF4Q	:= FWFormStruct(1, "F4Q")
oStruF4R	:= FWFormStruct(1, "F4R")
oStruSN3	:= FWFormStruct(1, "SN3", {|x| AllTrim(x) $ cFields})

aFields     := oStruSN3:GetFields()
For nX := 1 To Len(aFields)
    oStruF4R:AddField(;
        aFields[nX, MODEL_FIELD_TITULO],;
        aFields[nX, MODEL_FIELD_TITULO],;
        aFields[nX, MODEL_FIELD_IDFIELD],;
        aFields[nX, MODEL_FIELD_TIPO],;
        aFields[nX, MODEL_FIELD_TAMANHO],;
        aFields[nX, MODEL_FIELD_DECIMAL],;
        {|| .T. } /* bValid */,;
        {|| .F. } /* bWhen */,;
        /* aValues */,;
        .F. /* lObrigat */,;
        /* bInit */,;
        .F. /* lKey */,;
        /* lNoUpd */,;
        .T. /* lVirtual */)
Next nX

If GetOperation() == RU01T01_OPER_STORNO
    oStruF4Q:SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})
    oStruF4R:SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})
    oStruF4R:AddField(STR0008, STR0008, "MVC_STOK", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| RU01T01VLD(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| .F. } /* bInit */, .F. /* lKey */, /* lNoUpd */, .F. /* lVirtual */)	//" "
    oStruF4R:AddField(STR0023, STR0023, "MVC_STOHIS", "C", GetSX3Cache("F4R_HIST","X3_TAMANHO"), 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| .T. } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .T. /* lObrigat */, {|| STR0035} /* bInit */, .F. /* lKey */, /* lNoUpd */, .F. /* lVirtual */)	//"Storno history","Storno of "
    oStruF4Q:AddField(STR0024, STR0024, "MVC_STODES", "C", GetSX3Cache("F4Q_DESCR","X3_TAMANHO"), 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| .T. } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .T. /* lObrigat */, {|| STR0035}/* bInit */, .F. /* lKey */, /* lNoUpd */, .F. /* lVirtual */)	//"Storno Description"
EndIf

If GetOperation() == RU01T01_OPER_PUT .Or. GetOperation() == RU01T01_OPER_STORNO
    oStruF4Q:AddField(STR0034, STR0034, "MVC_CHKALL", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| RU01T01VLD(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| GetOperation() == RU01T01_OPER_PUT } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//"Mark all"
EndIf

oModel		:= MPFormModel():New("RU01T01", {|oMdl| RU01T01PRE(oMdl) } /* Pre-valid */, /* Pos-Valid */, {|oMdl| RU01T01COM(oMdl) } /* Commit */)

oModel:AddFields("F4QMASTER", /*cOwner*/, oStruF4Q)
oModel:GetModel("F4QMASTER"):SetDescription(STR0010) // "Journal Details"

If GetOperation() == RU01T01_OPER_PUT
    oModel:AddGrid("F4RDETAIL", "F4QMASTER", oStruF4R, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
Else
    oModel:AddGrid("F4RDETAIL", "F4QMASTER", oStruF4R, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, {|oMdl| LoadData(oMdl)} /* bLoadGrid */)
EndIf
aRelat	:= {}
aAdd(aRelat, {"F4R_FILIAL", "XFILIAL('F4R')"})
aAdd(aRelat, {"F4R_LOT", "F4Q_LOT"})
oModel:SetRelation("F4RDETAIL", aRelat, F4R->(IndexKey(1)))
oModel:GetModel("F4RDETAIL"):SetOptional(.T.)
oModel:GetModel("F4RDETAIL"):SetNoInsertLine(.T.)

If GetOperation() == RU01T01_OPER_PUT
    oStruSN3:SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})
    oStruSN3:SetProperty("N3_DINDEPR", MODEL_FIELD_WHEN, {|| .T.})
    oStruSN3:AddField(STR0008, STR0008, "MVC_OK", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| .T. } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| .T. } /* bInit */, .F. /* lKey */, /* lNoUpd */, .F. /* lVirtual */)	//" "
    oStruSN3:AddField(STR0019, STR0019, "MVC_HISTOR", "C", GetSX3Cache("F4R_HIST","X3_TAMANHO"), 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| .T. } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .T. /* lObrigat */, {|| .T. } /* bInit */, .F. /* lKey */, /* lNoUpd */, .F. /* lVirtual */)	//"Journal history"
    oModel:AddGrid("SN3DETAIL", "F4QMASTER", oStruSN3, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
    oModel:GetModel("SN3DETAIL"):SetDescription(STR0009) // "Fixed Assets Selection"
    oModel:GetModel("SN3DETAIL"):SetOptional(.T.)
    oModel:GetModel("SN3DETAIL"):SetNoInsertLine(.T.)
EndIf

oModel:SetDescription(STR0011) // "Journal Description"

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

MVC view defition

@param		None
@return		OBJECT oView FWFormView()
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local nX            AS NUMERIC
Local cFields		AS CHARACTER
Local cGrdMName		AS CHARACTER
Local cOrder		AS CHARACTER
Local cViewFld      AS CHARACTER
Local aFields		AS ARRAY
Local oStruF4Q		AS OBJECT
Local oStruF4R		AS OBJECT
Local oStruSN3		AS OBJECT
Local oStruGrid		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

cViewFld    := 'N3_CBASE|N3_ITEM|N3_TIPO|N3_CCONTAB|N3_VORIG1|N3_DINDEPR|F4R_HIST'
oModel		:= FWLoadModel("RU01T01")
cFields     := GetMVCFields()
oStruSN3	:= FWFormStruct(2, "SN3", {|x| AllTrim(x) $ cViewFld}/*!(AllTrim(x) $ "N3_UUID") .And. AllTrim(x) $ cFields}*/)
aFields     := oStruSN3:GetFields()

If GetOperation() == RU01T01_OPER_PUT
    oStruF4Q	:= FWFormStruct(2, "F4Q", {|x| !(AllTrim(x) $ "F4Q_DATE|F4Q_USER")})
    oStruF4Q:AddField("MVC_CHKALL", PADR('', Len(SX3->X3_ORDEM), 'Z'), STR0034, STR0034, Nil, "Get", "",,,.T.)	//"Mark all"
    For nX := 1 To Len(aFields)
        oStruSN3:SetProperty(;
            aFields[nX, MVC_VIEW_IDFIELD], ;
            MVC_VIEW_ORDEM, ;
            StrZero(nX + 1, Len(SX3->X3_ORDEM)))
    Next nX
    oStruSN3:AddField("MVC_OK", StrZero(1, Len(SX3->X3_ORDEM)), STR0008, STR0008, Nil, "Get", "",,,.T.)	//" "
    oStruSN3:AddField("MVC_HISTOR", PADR('', Len(SX3->X3_ORDEM), 'Z'), STR0019, STR0019, Nil, "Get", "",,,.T.)	//"Journal history"
    oStruSN3:SetProperty("MVC_HISTOR", MVC_VIEW_PICT, "@")
    
    oStruGrid   := oStruSN3
    cGrdMName   := "SN3DETAIL"
ElseIf GetOperation() == RU01T01_OPER_STORNO
    oStruF4Q	:= FWFormStruct(2, "F4Q", {|x| !(AllTrim(x) $ "F4Q_DATE|F4Q_USER|F4Q_OPER")})
    oStruF4Q:AddField("MVC_STODES", PADR('', Len(SX3->X3_ORDEM), 'X'), STR0024, STR0024, Nil, "Get", "",,,.T.)	//"Storno Description"
    oStruF4Q:AddField("MVC_CHKALL", PADR('', Len(SX3->X3_ORDEM), 'Z'), STR0034, STR0034, Nil, "Get", "",,,.T.)	//"Mark all"
    oStruF4R	:= FWFormStruct(2, "F4R", {|x| AllTrim(x) $ cViewFld/*!( AllTrim(x) $ "F4R_FILIAL|F4R_LOT|F4R_SN3|F4R_F4RLOT|F4R_F4RITE|F4R_LA" )*/})

    oStruF4R:AddField("MVC_STOK", StrZero(1, Len(SX3->X3_ORDEM)), STR0008, STR0008, Nil, "Get", "",,,.T.)	//" "
    oStruF4R:AddField("MVC_STOHIS", PADR('', Len(SX3->X3_ORDEM), 'Z'), STR0023, STR0023, Nil, "Get", "",,,.T.)	//"Storno history"
    oStruF4R:SetProperty("MVC_STOHIS", MVC_VIEW_PICT, "@")

    For nX := 1 To Len(aFields)
        If aFields[nX, MVC_VIEW_IDFIELD] $ cViewFld
            oStruF4R:AddField(;
                aFields[nX, MVC_VIEW_IDFIELD],;
                aFields[nX, MVC_VIEW_ORDEM],;
                aFields[nX, MVC_VIEW_TITULO],;
                aFields[nX, MVC_VIEW_DESCR],;
                Nil,;
                "Get",;
                "",;
                ,;
                ,;
                .T.)
        EndIf
    Next nX

    aFields := oStruF4R:GetFields()
    For nX := 1 To Len(aFields)
        If aFields[nX, MVC_VIEW_IDFIELD] $ cViewFld
            If SubStr(aFields[nX, MVC_VIEW_IDFIELD], 1, 4) <> "MVC_"
                cOrder  := StrZero(nX + 1, Len(SX3->X3_ORDEM))
                If AllTrim(aFields[nX, MVC_VIEW_IDFIELD]) == "F4R_HIST"
                    cOrder  := PADR("", Len(SX3->X3_ORDEM), "Z")
                EndIf
                oStruF4R:SetProperty(;
                    aFields[nX, MVC_VIEW_IDFIELD], ;
                    MVC_VIEW_ORDEM, ;
                    cOrder)
            EndIf
        EndIf
    Next nX

    oStruGrid   := oStruF4R
    cGrdMName   := "F4RDETAIL"
Else
    oStruF4Q	:= FWFormStruct(2, "F4Q", {|x| !(AllTrim(x) $ "F4Q_DATE|F4Q_USER")})

    oStruF4R	:= FWFormStruct(2, "F4R", {|x| ( AllTrim(x) $  cViewFld)})

    For nX := 1 To Len(aFields)
        if aFields[nX, MVC_VIEW_IDFIELD] $ cViewFld
            oStruF4R:AddField(;
                aFields[nX, MVC_VIEW_IDFIELD],;
                aFields[nX, MVC_VIEW_ORDEM],;
                aFields[nX, MVC_VIEW_TITULO],;
                aFields[nX, MVC_VIEW_DESCR],;
                Nil,;
                "Get",;
                "",;
                ,;
                ,;
                .T.)
        EndIf
    Next nX

    aFields := oStruF4R:GetFields()
    For nX := 1 To Len(aFields)
        cOrder  := StrZero(nX, Len(SX3->X3_ORDEM))
        If AllTrim(aFields[nX, MVC_VIEW_IDFIELD]) == "F4R_HIST"
            cOrder  := PADR("", Len(SX3->X3_ORDEM), "Z")
        EndIf
        oStruF4R:SetProperty(;
            aFields[nX, MVC_VIEW_IDFIELD], ;
            MVC_VIEW_ORDEM, ;
            cOrder)
    Next nX

    oStruGrid   := oStruF4R
    cGrdMName   := "F4RDETAIL"
EndIf

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F4Q", oStruF4Q, "F4QMASTER")
oView:AddGrid("VIEW_GRID", oStruGrid, cGrdMName)
oView:CreateHorizontalBox("MAIN", 25)
oView:CreateHorizontalBox("GRID", 75)
oView:SetOwnerView("VIEW_F4Q", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

oView:addUserButton(STR0036, "", {|| RU01T01PRT(oStruF4Q, oStruGrid) })  //Print

Return oView

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetOperation

Get selected operation

@param		None
@return		NUMERIC nOper
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function GetOperation()
Local nOper     AS NUMERIC
nOper   := 0
If IsInCallStack("RU01T01STO")
    nOper   := RU01T01_OPER_STORNO
ElseIf IsInCallStack("RU01T01INC")
    nOper   := RU01T01_OPER_PUT
EndIf
Return nOper

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01FIL

Perform filtering on active browser for journal records related
to currently positioned journal register

@param		None
@return		None
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01FIL()
Local cQuery    AS CHARACTER
Local cAliasTrb AS CHARACTER
Local cKeys     AS CHARACTER
cQuery      := "   SELECT F4R_LOT, F4R_F4RLOT "
cQuery      += "     FROM "+RetSqlName("F4R")+" F4R "
cQuery      += "    WHERE F4R.D_E_L_E_T_ = ' ' "
cQuery      += "      AND F4R_FILIAL = '"+xFilial("F4R")+"' "
cQuery      += "      AND (F4R_F4RLOT = '"+F4Q->F4Q_LOT+"' OR F4R_LOT = '"+F4Q->F4Q_LOT+"') "
cQuery      += " GROUP BY F4R_LOT, F4R_F4RLOT "
cQuery      := ChangeQuery(cQuery)
cAliasTrb   := RU01GETALS(cQuery)
cKeys       := ""
While (cAliasTrb)->(! EOF())
    cKeys   += "|" + (cAliasTrb)->F4R_LOT
    If ! Empty((cAliasTrb)->F4R_F4RLOT)
        cKeys   += "|" + (cAliasTrb)->F4R_F4RLOT
    EndIf
    (cAliasTrb)->(dbSkip())
EndDo
(cAliasTrb)->(dbCloseArea())

oBrowse:AddFilter(STR0032 + F4Q->F4Q_LOT /* cFilter */, "F4Q_LOT$'" + cKeys + "'" /* cExpAdvPL */, Nil /* [ lNoCheck ] */, .T. /* [ lSelected ] */, Nil /* [ cAlias ] */, Nil /* [ lFilterAsk ] */, /* [ aFilParser ] */, /* [ cID ] */)  // "Related journals"
oBrowse:GoTop()

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} LoadData

Load data into grid for view and storno

@param		OBJECT oModel
@return		ARRAY aRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function LoadData(oModel AS OBJECT)
Local nX        AS NUMERIC
Local cQuery    AS CHARACTER
Local cAliasTrb AS CHARACTER
Local aRet      AS ARRAY
Local aTmp      AS ARRAY
Local aFields   AS ARRAY
Local oStruct   AS OBJECT
Local xValue

aRet        := {}
oStruct     := oModel:GetStruct()
aFields     := oStruct:GetFields()

cQuery  := " SELECT F4R.R_E_C_N_O_ AS F4RRECNO "
For nX := 1 To Len(aFields)
    If  aFields[nX, MODEL_FIELD_TIPO] $ "C|N|D|L" .And. ;
        SubStr(aFields[nX, MODEL_FIELD_IDFIELD], 1, 4) <> "MVC_"
            cQuery  += "," + aFields[nX, MODEL_FIELD_IDFIELD]
    EndIf
Next nX
cQuery  += "   FROM "+RetSqlName("F4R")+" F4R "
cQuery  += "   JOIN "+RetSqlName("SN3")+" SN3 ON SN3.N3_UUID = F4R.F4R_SN3 "
cQuery  += "  WHERE F4R.D_E_L_E_T_ = ' ' "
cQuery  += "    AND SN3.D_E_L_E_T_ = ' ' "
cQuery  += "    AND F4R_FILIAL = '"+xFilial("F4R")+"' "
cQuery  += "    AND N3_FILIAL = '"+xFilial("SN3")+"' "
cQuery  += "    AND F4R_LOT = '"+F4Q->F4Q_LOT+"' "
If GetOperation() == RU01T01_OPER_STORNO
    cQuery  += "    AND F4R_STATUS = '"+F4R_STATUS_CONFIRMED+"' "
EndIf
cQuery  += " ORDER BY F4R_FILIAL, F4R_LOT, F4R_ITEM "
cQuery  := ChangeQuery(cQuery)
cAliasTrb   := RU01GETALS(cQuery)
While (cAliasTrb)->(! EOF())
    aTmp    := {(cAliasTrb)->F4RRECNO, {}}
    For nX := 1 To Len(aFields)
        xValue  := Nil
        If aFields[nX, MODEL_FIELD_IDFIELD] == "MVC_STOK"
            xValue  := .F.
        ElseIf aFields[nX, MODEL_FIELD_IDFIELD] == "MVC_STOHIS"
            xValue  := STR0035
        ElseIf aFields[nX, MODEL_FIELD_IDFIELD] == "MVC_STODES"
            xValue  := STR0035/*Space(GetSX3Cache("F4Q_DESCR","X3_TAMANHO"))*/
        ElseIf  aFields[nX, MODEL_FIELD_TIPO] $ "C|N|D"
                xValue  := &("('"+cAliasTrb+"')->" + aFields[nX, MODEL_FIELD_IDFIELD])
                If aFields[nX, MODEL_FIELD_TIPO] == "D"
                    xValue  := SToD(xValue)
                EndIf
        EndIf
        aAdd(aTmp[2], xValue)
    Next nX
    aAdd(aRet, aTmp)
    (cAliasTrb)->(dbSkip())
EndDo
(cAliasTrb)->(dbCloseArea())

Return aRet


// Russia_R5

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T01PRE

Model prevalidation

@param       OBJECT oModel
@return      LOGICAL lOk
@example     
@author      astepanov
@since       11/21/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU01T01PRE(oModel)

Local bMVCLoaV AS BLOCK
Local lRet     AS LOGICAL
lRet := .T.

bMVCLoaV    := {|oMdl, cField, xVal| lRet := lRet .And. oMdl:LoadValue(cField, xVal)}
If GetOperation() == RU01T01_OPER_STORNO
    lRet := Eval(bMVCLoaV, oModel:GetModel("F4QMASTER"),"F4Q_DESCR",STR0018) // Value: "Putting into operation"
EndIf

Return lRet

/*/{Protheus.doc} RU01T01PRT

Print

@return		Nil
@author 	Alexandra Menyashina
@since 		27/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T01PRT(oStruF4Q AS object, oStruF4R AS object)
Local oReport	AS OBJECT
Local cName		AS CHARACTER

cName	:= 'RU01T01'
oReport := ReportDef(cName, oStruF4Q, oStruF4R)
oReport:PrintDialog()

return Nil

/*/{Protheus.doc} ReportDef

Print report definition

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		27/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ReportDef(cName, oStruF4Q AS object, oStruF4R AS object)
Local oReport	    AS OBJECT
Local oSecF4Q	    AS OBJECT
Local oSecF4R	    AS OBJECT
Local oStruSN3      AS OBJECT
Local nX		    AS NUMERIC
Local cViewFldN3	AS CHARACTER

cViewFldN3    := 'N3_CBASE|N3_ITEM|N3_TIPO|N3_CCONTAB'
oStruSN3	:= FWFormStruct(2, "SN3", {|x| AllTrim(x) $ cViewFldN3})

oReport := TReport():New(cName/*cReport*/,STR0001/*cTitle*/,cName,{|oReport| ReportPrint(oReport, oStruF4Q, oStruF4R, oStruSN3)},"PRINT", .F./*<lLandscape>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<cPageTText>*/ , .F./*<lPageTInLine>*/ , .F./*<lTPageBreak>*/ , /*<nColSpace>*/ )

oReport:lParamPage	:= .F.	//Don't print patameter page
//Header info
oSecF4Q := TRSection():New(oReport,"",{'F4Q'} , , .F., .T.)
For nX := 1 To Len(oStruF4Q:aFields)
	If ! oStruF4Q:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4Q,oStruF4Q:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"F4Q", AllTrim(oStruF4Q:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX
//Detail info
oSecF4R := TRSection():New(oReport,"",{'F4R'} , , .F., .T.)
For nX := 1 To Len(oStruSN3:aFields)
	If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4R,oStruSN3:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"SN3", alltrim(oStruSN3:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX
For nX := 1 To Len(oStruF4R:aFields)
	If ! oStruF4R:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4R,oStruF4R:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"F4R", alltrim(oStruF4R:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX

Return oReport

/*/{Protheus.doc} ReportPrint

Print prepare data

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		27/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ReportPrint(oReport, oStruF4Q AS object, oStruF4R AS object, oStruSN3 AS object)
Local oSecF4Q 		AS OBJECT
Local oSecF4R		AS OBJECT
Local cAliasQry		AS CHARACTER
Local cQuery		AS CHARACTER
Local cLot		    AS CHARACTER
local lRet			AS LOGICAL
Local nX			AS NUMERIC
Local xValor 

oSecF4Q		:= oReport:Section(1)
oSecF4R		:= oReport:Section(2)
cAliasQry	:= GetNextAlias()
cQuery		:= ""
lRet		:= .T.

If oReport:Cancel()
	Return .T.
EndIf

cLot:= F4Q->F4Q_LOT
oSecF4Q:Init()
oReport:IncMeter()

dbSelectArea('F4Q')
F4Q->(DBSeek( xFilial('F4Q') + cLot))

For nX := 1 To Len(oStruF4Q:aFields)
	If ! oStruF4Q:aFields[nX, MVC_VIEW_VIRTUAL]
		If GetSx3Cache(oStruF4Q:aFields[nX, MVC_VIEW_IDFIELD],'X3_TIPO') == 'D'
			xValor := F4Q->&(oStruF4Q:aFields[nX, MVC_VIEW_IDFIELD])
			xValor := StrTran(DTOC(xValor), "/", ".")
			oSecF4Q:Cell(oStruF4Q:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(xValor)
		Else
			oSecF4Q:Cell(oStruF4Q:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(F4Q->&(oStruF4Q:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	EndIf
Next nX		
oSecF4Q:Printline()

oSecF4R:init()

cQuery	:= " SELECT  F4R.R_E_C_N_O_ F4RRECNO "

For nX := 1 To Len(oStruSN3:aFields)
	If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
		cQuery  += "," + oStruSN3:aFields[nX, MVC_VIEW_IDFIELD]
	EndIf
Next nX

For nX := 1 To Len(oStruF4R:aFields)
	If ! oStruF4R:aFields[nX, MVC_VIEW_VIRTUAL]
		cQuery  += "," + oStruF4R:aFields[nX, MVC_VIEW_IDFIELD]
	EndIf
Next nX

cQuery	+= " FROM "+RetSqlName("F4R")+" F4R "
cQuery	+= " JOIN "+RetSqlName("SN3")+" SN3 "
cQuery	+= " ON SN3.N3_UUID = F4R.F4R_SN3 "
cQuery	+= " WHERE F4R.D_E_L_E_T_ = ' '"
cQuery	+= " AND SN3.D_E_L_E_T_ = ' '"
cQuery	+= " AND N3_FILIAL = '" + xFilial("SN3") + "'"
cQuery	+= " AND F4R_FILIAL = '" + xFilial("F4R") + "'"
cQuery	+= " AND F4R_LOT = '" + cLot + "'"
cQuery  := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

Dbselectarea(cAliasQry)
dbgotop()

While (cAliasQry)->(!EOF())
    For nX := 1 To Len(oStruSN3:aFields)
		If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
			oSecF4R:Cell(oStruSN3:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)->&(oStruSN3:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	Next nX
	For nX := 1 To Len(oStruF4R:aFields)
		If ! oStruF4R:aFields[nX, MVC_VIEW_VIRTUAL]
			oSecF4R:Cell(oStruF4R:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)->&(oStruF4R:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	Next nX
	oSecF4R:Printline()
	(cAliasQry)->(dbSkip())
EndDo
oSecF4R:Finish()
//Separator
oReport:ThinLine()
oSecF4Q:Finish()
Return(NIL)

