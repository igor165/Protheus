#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01T04RUS.CH'

#define F4S_OPER_EXECUTION          "1"
#define F4S_OPER_STORNO             "2"
#define F4T_STATUS_NOT_CONFIRMED    "0"
#define F4T_STATUS_CONFIRMED        "1"
#define F4T_STATUS_STORNOED         "2"
#define SN3_OPER_IN_OPERATION       "1"
#define SN3_OPER_NOT_IN_OPERATION   "2"
#define SN3_BAIXA_WRITTEN_OFF       "1"
#define SN3_BAIXA_ACTIVE            "0"
#define SN1_STATUS_ACTIVE           "1"
#define SN1_STATUS_INACTIVE         "0"
#define FN6_MOTIVO_WRITE_OFF        "22"
#define SN4_STATUS_STORNO           "1"

#define RU01T04_OPER_REEVALUATION	1
#define RU01T04_OPER_STORNO         2

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04RUS

Fixed assets reevaluation

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04RUS()
Local lRet			AS LOGICAL
Private oBrowse		AS OBJECT
Private cCadastro	AS CHARACTER
Private aEnableButtons AS ARRAY

lRet		:= .T.
cCadastro	:= STR0001	//"Reevaluation"

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

dbSelectArea("SN3")
dbSetOrder(13)  //N3_FILIAL+N3_UUID
dbSelectArea("F4T")
dbSetOrder(1)	//F4T_FILIAL+F4T_LOT+F4T_ITEM
dbSelectArea("F4S")
dbSetOrder(1)	//F4S_FILIAL+F4S_LOT

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
oBrowse:SetDescription(STR0001) //"Reevaluation"
oBrowse:SetAlias("F4S")
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
aAdd(aRotina, {STR0001, "RU01T04INC()",                 0, 3, 0, Nil, Nil, Nil}) //"Reevaluation"
aAdd(aRotina, {STR0002, "RU01T04VIE",              0, 2, 0, Nil, Nil, Nil}) //"View"
aAdd(aRotina, {STR0003, "RU01T04STO()",                 0, 5, 0, Nil, Nil, Nil}) //"Storno"
aAdd(aRotina, {STR0004, "RU01S02RUS('F4S','F4T',1,1)",  0, 2, 0, Nil, Nil, Nil}) //"Accounting Tracker"
aAdd(aRotina, {STR0005, "RU01T04FIL",                   0, 2, 0, Nil, Nil, Nil}) //"Filter Related Lots"
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04FIL

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
Function RU01T04FIL()
Local cQuery    AS CHARACTER
Local cAliasTrb AS CHARACTER
Local cKeys     AS CHARACTER
cQuery      := "   SELECT F4T_LOT, F4T_F4TLOT "
cQuery      += "     FROM "+RetSqlName("F4T")+" F4T "
cQuery      += "    WHERE F4T.D_E_L_E_T_ = ' ' "
cQuery      += "      AND F4T_FILIAL = '"+xFilial("F4T")+"' "
cQuery      += "      AND (F4T_F4TLOT = '"+F4S->F4S_LOT+"' OR F4T_LOT = '"+F4S->F4S_LOT+"') "
cQuery      += " GROUP BY F4T_LOT, F4T_F4TLOT "
cQuery      := ChangeQuery(cQuery)
cAliasTrb   := RU01GETALS(cQuery)
cKeys       := ""
While (cAliasTrb)->(! EOF())
    cKeys   += "|" + (cAliasTrb)->F4T_LOT
    If ! Empty((cAliasTrb)->F4T_F4TLOT)
        cKeys   += "|" + (cAliasTrb)->F4T_F4TLOT
    EndIf
    (cAliasTrb)->(dbSkip())
EndDo
(cAliasTrb)->(dbCloseArea())

oBrowse:AddFilter(STR0027 + F4S->F4S_LOT /* cFilter */, "F4S_LOT$'" + cKeys + "'" /* cExpAdvPL */, Nil /* [ lNoCheck ] */, .T. /* [ lSelected ] */, Nil /* [ cAlias ] */, Nil /* [ lFilterAsk ] */, /* [ aFilParser ] */, /* [ cID ] */)  // "Related journals"
oBrowse:GoTop()

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04INC

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
Function RU01T04INC(oModel AS OBJECT)
Local nX            AS NUMERIC
Local cQuery        AS CHARACTER
Local cField        AS CHARACTER
Local cAtfCur       AS CHARACTER
Local lLoadData     AS LOGICAL
Local lRet          AS LOGICAL
Local lAtfCTAP      AS LOGICAL
Local dLastDep      AS DATE
Local aF4TField     AS ARRAY
Local aIgnoreFld    AS ARRAY
Local bPadField     AS BLOCK
Local oModelGrd     AS OBJECT
Local oStruF4T      AS OBJECT

bPadField   := {|cStr, cField| PADR(cStr, GetSX3Cache(cField, "X3_TAMANHO"))}
lRet        := .T.
lAtfCTAP    := GetNewPar("MV_ATFCTAP", "0") == "0"

// Current date equals to last monthly calculation
If lRet
    dLastDep	:= SuperGetMV("MV_ULTDEPR", .F.)
    lRet        := dDataBase == dLastDep
    If ! lRet
        Help("",1,"RU01T04DATE",,STR0009,1,0)	// "Reevaluation should be performed on the date of the last amortization calculation"
    EndIf
EndIf

// Prepare oModel
lLoadData   := .F.
If lRet .And. ValType(oModel) <> "O"
    oModel      := FWLoadModel("RU01T04")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    lLoadData   := .T.
EndIf

// Ask user about parameters
If lRet .And. lLoadData
    lRet        := Pergunte("ATFA012PUT", !IsBlind())
EndIf

// Continue with data fetching if required
If lRet .And. lLoadData
    cAtfCur     := GetNewPar("MV_ATFMOED", "")
    oModel:Activate()
    oModel:GetModel("F4SMASTER"):SetValue("F4S_DESCR", STR0010) // "Execution of reevaluation"
    
    oModelGrd   := oModel:GetModel("F4TDETAIL")
    oStruF4T    := oModelGrd:GetStruct()
    aF4TField   := oStruF4T:GetFields()
    cQuery      := " SELECT SN3.R_E_C_N_O_ AS POSRECNO "

    For nX := 1 To Len(aF4TField)
        cField  := AllTrim(aF4TField[nX, MODEL_FIELD_IDFIELD])
        If cField $ "F4T_SN3"
            cQuery  += " , SN3.N3_UUID AS " + cField
        ElseIf cField $ "F4T_VORIG"
            cQuery  += " , SN3.N3_VORIG"+cAtfCur+" AS " + cField
        ElseIf cField $ "F4T_AMPLIA"
            cQuery  += " , SN3.N3_AMPLIA"+cAtfCur+" AS " + cField
        ElseIf cField $ "F4T_INCOST"
            cQuery  += " , SN3.N3_INCOST AS " + cField
        ElseIf cField $ "F4T_PRACDE|F4T_VRDACM"
            cQuery  += " , SN3.N3_VRDACM"+cAtfCur+" AS " + cField
        ElseIf cField $ "F4T_PRREVV|F4T_VALUE"
            cQuery  += " , SN3.N3_VORIG"+cAtfCur+" + SN3.N3_AMPLIA"+cAtfCur+" AS " + cField
        ElseIf cField $ "F4T_VRDMES"
            cQuery  += " , SN3.N3_VRDMES"+cAtfCur+" AS " + cField
        ElseIf cField $ "F4T_PACRVD"
            cQuery  += " , SN3.N3_ACRVDEP AS " + cField
        ElseIf cField $ "F4T_NEWTYP"
            cQuery  += " , SN3.N3_TIPO AS " + cField
        EndIf
    Next nX
    cQuery  += " FROM "+RetSqlName("SN1")+" SN1 "
    cQuery  += " JOIN "+RetSqlName("SN3")+" SN3 "
    cQuery  += "                  ON N3_CBASE = N1_CBASE "
    cQuery  += "                 AND N3_ITEM = N1_ITEM "
    cQuery  += " WHERE SN1.D_E_L_E_T_ = ' ' "
    cQuery  += "  AND SN3.D_E_L_E_T_ = ' ' "
    cQuery  += "  AND N1_FILIAL = '"+xFilial("SN1")+"' "
    cQuery  += "  AND N3_FILIAL = '"+xFilial("SN3")+"' "
    cQuery  += "  AND N3_OPER = '"+SN3_OPER_IN_OPERATION+"' "
    cQuery  += "  AND N3_BAIXA <> '"+SN3_BAIXA_WRITTEN_OFF+"' "
    cQuery  += "  AND N3_VRDACM"+cAtfCur+" > 0 "
    cQuery  += "  AND N3_TIPO IN ('"+AtfNValMod({1,2,3},"','")+"') " // Managerial types
    If lAtfCTAP ; cQuery += " AND N3_TPDEPR NOT IN ('4','5','8','9') " ; EndIf
    cQuery  += "  AND N1_CBASE BETWEEN '"+Eval(bPadField, MV_PAR01, "N1_CBASE")+"' AND '"+Eval(bPadField, MV_PAR02, "N1_CBASE")+"' "
    cQuery  += "  AND N3_TIPO BETWEEN '"+Eval(bPadField, MV_PAR03, "N3_TIPO")+"' AND '"+Eval(bPadField, MV_PAR04, "N3_TIPO")+"' "
    cQuery  += "  AND N1_GRUPO BETWEEN '"+Eval(bPadField, MV_PAR05, "N1_GRUPO")+"' AND '"+Eval(bPadField, MV_PAR06, "N1_GRUPO")+"' "
    cQuery  += "  AND N3_AQUISIC BETWEEN '"+DToS(MV_PAR07)+"' AND '"+DToS(MV_PAR08)+"' "
    cQuery  += "  AND "
    cQuery  += "      ( "
    cQuery  += "          SELECT COALESCE( "
    cQuery  += " 		          MAX( "
    cQuery  += " 					CASE WHEN N4_OCORR IN ( "
    cQuery  += " 					  '06','07','08','10','11', "
    cQuery  += " 					  '12','17','18','20' "
    cQuery  += " 					) AND N4_DATA = '"+DToS(dDataBase)+"' "
    cQuery  += " 					  THEN 'A' "
    cQuery  += " 			          ELSE 'B' END "
    cQuery  += "                  ), ' ' "
    cQuery  += "                 ) "
    cQuery  += "            FROM "+RetSqlName("SN4")+" SN4 "
    cQuery  += "           WHERE N4_CBASE = N3_CBASE "
    cQuery  += "             AND N4_ITEM = N3_ITEM "
    cQuery  += "             AND N4_TIPO = N3_TIPO "
    cQuery  += "             AND N4_SEQ = N3_SEQ "
    cQuery  += "             AND SN4.D_E_L_E_T_ = ' ' "
    cQuery  += "             AND N4_FILIAL = '"+xFilial("SN4")+"' "
    cQuery  += "             AND N4_OCORR <> '05' " //Acquisition
    cQuery  += "             AND N4_DATA >= '"+DToS(dDataBase)+"' "
    cQuery  += "      ) = 'A' "	// There must be a depreciation register, but no other SN4 registers
    cQuery  += " ORDER BY N3_CBASE, N3_ITEM, N3_TIPO, N3_SEQ "
    cQuery  := ChangeQuery(cQuery)
    
    // Insert query results into model
    oModelGrd:SetNoInsertLine(.F.)
    aIgnoreFld  := {}
    aAdd(aIgnoreFld, "F4T_FILIAL")
    aAdd(aIgnoreFld, "F4T_LOT")
    aAdd(aIgnoreFld, "F4T_ITEM")
    aAdd(aIgnoreFld, "F4T_STATUS")
    aAdd(aIgnoreFld, "F4T_F4TLOT")
    aAdd(aIgnoreFld, "F4T_F4TITE")
    aAdd(aIgnoreFld, "F4T_LA")
    aAdd(aIgnoreFld, "MVC_OK")
    aAdd(aIgnoreFld, "F4T_HIST")
    aAdd(aIgnoreFld, "F4T_COEFFI")
    aAdd(aIgnoreFld, "F4T_ACRVDE")
    aAdd(aIgnoreFld, "F4T_SN3PRE")
    aAdd(aIgnoreFld, "F4T_VN3BAS")
    aAdd(aIgnoreFld, "F4T_VN3TIP")
    aAdd(aIgnoreFld, "F4T_VN3ITE")
    aAdd(aIgnoreFld, "F4T_VN3HIS")
    aAdd(aIgnoreFld, "F4T_UID")
    aAdd(aIgnoreFld, "F4T_SN4UID")
    lRet    := RU01QRY2MD( ;
        cQuery, ;
        oModelGrd, ;
        .T. /* lGrid */, ;
        .F. /* lAddFirstLine */, ;
        aIgnoreFld /* aIgnoreFld */, ;
        {|oMdl| ProcGridInsert(oMdl)} /* bPosInsert */, ;
        .T. /* lInitPad */, ;
        "F4T_ITEM" /* cIncField */, ;
        {"SN3", "POSRECNO"})
    oModelGrd:SetNoInsertLine(.T.)

    If ! lRet
        Help("",1,"ARQVAZIO")
    EndIf
EndIf

// Execute MVC View
If lRet
    dbSelectArea("F4S")
    FWExecView(STR0001, "RU01T04", MODEL_OPERATION_INSERT, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Reevaluation"
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04STO

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
Function RU01T04STO(oModel AS OBJECT)
Local lRet      AS LOGICAL
Local dLastDep  AS DATE
Local oModel    AS OBJECT

lRet        := .T.

// Currently selected lot register must be of type execution
If lRet
    lRet    := F4S->F4S_OPER == F4S_OPER_EXECUTION
    If ! lRet
        Help("",1,"RU01T04STVL01",,STR0016,1,0)	//"Currently selected lot register must be of type execution"
    EndIf
EndIf

// Current month posterior to last monthly calculation
If lRet
    lRet    := ;
        dDataBase >= F4S->F4S_DATE .And. ;
        dDataBase <= LastDay(F4S->F4S_DATE + 1)
    If ! lRet
        Help("",1,"RU01T04SDATE",,STR0017,1,0)	// "Storno of reevaluation must be performed in the same date of execution or in the next month"
    EndIf
EndIf

// Prepare oModel
If lRet .And. ValType(oModel) <> "O"
    oModel      := FWLoadModel("RU01T04")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
    ProcGridInsert(oModel:GetModel("F4TDETAIL"))
    oModel:GetModel('F4SMASTER'):LoadValue('MVC_STODES', STR0034)
EndIf

// Execute MVC View
If lRet
    dbSelectArea("F4S")
    FWExecView(STR0001, "RU01T04", MODEL_OPERATION_UPDATE, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Reevaluation"
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
Local nOper         AS NUMERIC
Local cHistory      AS CHARACTER

nOper       := GetOperation()

If nOper == RU01T04_OPER_REEVALUATION
    cHistory    := STR0011
	oModel:SetValue("MVC_OK", .T.)  
ElseIf nOper == RU01T04_OPER_STORNO
    cHistory    := STR0034
EndIf
cHistory    += Alltrim(oModel:GetValue("F4T_VN3BAS")) + "-"
cHistory    += AllTrim(oModel:GetValue("F4T_VN3ITE")) + "/"
cHistory    += AllTrim(oModel:GetValue("F4T_VN3TIP"))

If nOper == RU01T04_OPER_REEVALUATION
    oModel:SetValue("F4T_HIST", cHistory)
ElseIf nOper == RU01T04_OPER_STORNO
	oModel:SetValue("MVC_STOHIS", cHistory)
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04POS

MVC Pos-Valid function

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04POS(oModel AS OBJECT)
Local nX            AS NUMERIC
Local nProcRec      AS NUMERIC
Local nOper         AS NUMERIC
Local nLine         AS NUMERIC
Local nLineErr      AS NUMERIC
Local lRet          AS LOGICAL
Local bVldLine      AS BLOCK
Local oMdlExeHe     AS OBJECT
Local oMdlExeGr     AS OBJECT

nOper       := GetOperation()
lRet        := .T.
oMdlExeHe   := oModel:GetModel("F4SMASTER")
oMdlExeGr   := oModel:GetModel("F4TDETAIL")
bVldLine    := {|oMdl, oMdlLine| RU01T04VLD(oMdlLine, "POSVALID", oMdl, Nil) }
nLine       := 0
nProcRec    := 0
nLineErr    := 0

If nOper == RU01T04_OPER_REEVALUATION
    For nX := 1 To oMdlExeGr:Length()
        oMdlExeGr:GoLine(nX)
        If oMdlExeGr:IsDeleted()
        ElseIf ! oMdlExeGr:GetValue("MVC_OK")
            oMdlExeGr:DeleteLine()
        ElseIf ! Eval(bVldLine, oModel, oMdlExeGr)
            nLineErr    := nX
            lRet        := .F.
            Exit
        Else
            nLine++
            lRet    := lRet .And. oMdlExeGr:LoadValue(;
                "F4T_ITEM",;
                StrZero(nLine, GetSX3Cache("F4T_ITEM", "X3_TAMANHO")))
            If ! lRet
                RU01MVCERR(oModel)
                Exit
            EndIf
            nProcRec++
        EndIf
    Next nX

    If ! lRet
        For nX := 1 To oMdlExeGr:Length()
            oMdlExeGr:GoLine(nX)
            oMdlExeGr:LoadValue(;
                    "F4T_ITEM",;
                    StrZero(nX, GetSX3Cache("F4T_ITEM", "X3_TAMANHO")))
            If oMdlExeGr:IsDeleted()
                oMdlExeGr:UnDeleteLine()
            EndIf
        Next nX

        If ! Empty(nLineErr)
            oMdlExeGr:GoLine(nLineErr)
        EndIf
    EndIf
ElseIf nOper == RU01T04_OPER_STORNO
    For nX := 1 To oMdlExeGr:Length()
        oMdlExeGr:GoLine(nX)
        If oMdlExeGr:IsDeleted()
        ElseIf ! oMdlExeGr:GetValue("MVC_OK")
        ElseIf ! Eval(bVldLine, oModel, oMdlExeGr)
            lRet    := .F.
            Exit
        Else
            nProcRec++
        EndIf
    Next nX
EndIf

If lRet .And. Empty(nProcRec)
    lRet    := .F.
    Help("",1,"RU01T04NAN",,STR0026,1,0)	//"No valid records selected"
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04COM

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
Function RU01T04COM(oModel AS OBJECT)
Local nX			AS NUMERIC
Local nY			AS NUMERIC
Local nZ			AS NUMERIC
Local nLine			AS NUMERIC
Local nOper			AS NUMERIC
Local nCurRate		AS NUMERIC
Local nQtyCur		AS NUMERIC
Local nReval		AS NUMERIC
Local nPrevVal		AS NUMERIC
Local nInCost		AS NUMERIC
Local nNewN3Line	AS NUMERIC
Local nEnlarg       AS NUMERIC
Local nAcmDep       AS NUMERIC
Local nPrAcmDep     AS NUMERIC
Local nAcrVDep      AS NUMERIC
Local nPrevTx       AS NUMERIC
Local cAtfCur		AS CHARACTER
Local cJrnLot		AS CHARACTER
Local cField		AS CHARACTER
Local cN3UUID		AS CHARACTER
Local cFieldN3		AS CHARACTER
Local cSeq          AS CHARACTER
Local cCreatUUID    AS CHARACTER
Local cUUIDOri      AS CHARACTER
Local cQuery        AS CHARACTER
Local cAlsTmp       AS CHARACTER
Local cPatrim       AS CHARACTER
Local cIDMOV        AS CHARACTER
Local cOcorr        AS CHARACTER
Local cTypeDep      AS CHARACTER
Local cUID          AS CHARACTER
Local lRet			AS LOGICAL
Local lFoundN3		AS LOGICAL
Local dDateSave		AS DATE
Local dDateRev		AS DATE
Local aExecut		AS ARRAY
Local aArea			AS ARRAY
Local aAreaSN1		AS ARRAY
Local aAreaSN3		AS ARRAY
Local aFields		AS ARRAY

Local aStornoExe    AS ARRAY
Local aValues       AS ARRAY
Local aValDepr      as Array
Local aCompData     AS ARRAY
Local aDifCurr      AS ARRAY
Local aPrevVal      AS ARRAY
Local oMdlExeHe		AS OBJECT
Local oMdlExeGr		AS OBJECT
Local oMdlJrSt		AS OBJECT
Local oMdlJrStH		AS OBJECT
Local oMdlJrStG		AS OBJECT
Local oMdlAF12      AS OBJECT
Local oMdlAF12H     AS OBJECT
Local oMdlAF12G     AS OBJECT
Local oStruct		AS OBJECT
Local xAuxVal

aArea       := GetArea()
aAreaSN1    := SN3->(GetArea())
aAreaSN3    := SN3->(GetArea())

nOper       := GetOperation()
lRet        := .F.
oMdlExeHe   := oModel:GetModel("F4SMASTER")
oMdlExeGr   := oModel:GetModel("F4TDETAIL")
aExecut     := {}
nQtyCur		:= AtfMoedas()
cAtfCur     := GetNewPar("MV_ATFMOED", "")
nCurRate	:= Posicione("SM2", 1, DToS(dDataBase), "M2_MOEDA"+cAtfCur)

BEGIN TRANSACTION
If nOper == RU01T04_OPER_REEVALUATION
    lRet    := .T.
    cJrnLot := oMdlExeHe:GetValue("F4S_LOT")
    If lRet
        For nX := 1 To oMdlExeGr:Length()
            oMdlExeGr:GoLine(nX)
            If ! oMdlExeGr:IsDeleted() .And. oMdlExeGr:GetValue("MVC_OK")
                lRet    := oMdlExeGr:SetValue("F4T_STATUS", F4T_STATUS_CONFIRMED)
                If ! lRet
                    Help("",1,"RU01T04COCOU",,STR0024,1,0)	//"Error while updating status of journal item to confirmed"
                    Exit
                EndIf
                aAdd(aExecut, {;
                    oMdlExeGr:GetValue("F4T_SN3"),;     //01
                    oMdlExeGr:GetValue("F4T_VALUE"),;   //02
                    oMdlExeGr:GetValue("F4T_PRREVV"),;  //03
                    oMdlExeGr:GetValue("F4T_INCOST"),;  //04
                    oMdlExeGr:GetValue("F4T_AMPLIA"),;  //05
                    oMdlExeGr:GetValue("F4T_VRDACM"),;  //06
                    oMdlExeGr:GetValue("F4T_PRACDE"),;  //07
                    oMdlExeGr:GetValue("F4T_ACRVDE")})  //08
            EndIf
        Next nX
    EndIf
    If lRet
        // Perform operation
        For nX := 1 To Len(aExecut)
            // Insert new SN3 line with ATFA012 model
            If lRet
                cN3UUID     := aExecut[nX, 01]
                nReval      := aExecut[nX, 02]
                nPrevVal    := aExecut[nX, 03]
                nInCost     := aExecut[nX, 04]
                nEnlarg     := aExecut[nX, 05]
                nAcmDep     := aExecut[nX, 06]
                nPrAcmDep   := aExecut[nX, 07]
                nAcrVDep    := aExecut[nX, 08]

                If lRet
                    SN1->(dbSetOrder(1))    //N1_FILIAL+N1_CBASE+N1_ITEM
                    SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID
                    lRet    := SN3->(dbSeek(xFilial("SN3") + cN3UUID))
                    If ! lRet
                        Help("",1,"RU01T04VLN31",,STR0018,1,0)	//"Error finding related FA record"
                        Exit
                    EndIf
                    lRet    := SN1->(dbSeek(SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)))
                    If ! lRet
                        Help("",1,"RU01T04VLN32",,STR0018,1,0)	//"Error finding related FA record"
                        Exit
                    EndIf
                EndIf

                oMdlAF12	:= FWLoadModel("ATFA012")
                oMdlAF12:SetOperation(MODEL_OPERATION_UPDATE)
                oMdlAF12:Activate()

                oMdlAF12H   := oMdlAF12:GetModel("SN1MASTER")
                oMdlAF12G   := oMdlAF12:GetModel("SN3DETAIL")

                lFoundN3    := .F.
                For nY := 1 To oMdlAF12G:Length()
                    lFoundN3    := cN3UUID == oMdlAF12G:GetValue("N3_UUID", nY)
                    If lFoundN3
                        oMdlAF12G:GoLine(nY)
                        lRet    := lRet .And. oMdlAF12G:LoadValue("N3_VORIG" + cAtfCur, nReval)
                        lRet    := lRet .And. oMdlAF12G:SetValue("N3_VRDACM" + cAtfCur, nAcmDep)
                        lRet    := lRet .And. oMdlAF12G:LoadValue("N3_AMPLIA" + cAtfCur, 0)
                        lRet    := lRet .And. oMdlAF12G:LoadValue("N3_PRREVVL", nPrevVal)
                        lRet    := lRet .And. oMdlAF12G:LoadValue("N3_INCOST", nInCost)
                        lRet    := lRet .And. oMdlAF12G:LoadValue("N3_PRACDEP", nPrAcmDep)
                        lRet    := lRet .And. oMdlAF12G:LoadValue("N3_ACRVDEP", nAcrVDep)
                        If ! lRet
                            RU01MVCERR(oMdlAF12)
                            Help("",1,"RU01T04COVLFD",,STR0031,1,0)	// "Error setting values of new balances register"
                            Exit
                        EndIf
                        Exit
                    EndIf
                Next nY
                If ! lFoundN3
                    lRet    := .F.
                    Help("",1,"RU01T04VLN33",,STR0018,1,0)	//"Error finding related FA record"
                    Exit
                ElseIf ! lRet
                    Exit
                EndIf

                If lRet
                    lRet    := FWFormCommit(oMdlAF12)
                    If ! lRet
                        RU01MVCERR(oMdlAF12)
                        Exit
                    EndIf
                EndIf

                oMdlAF12:DeActivate()

                If lRet
                    SN1->(dbSetOrder(1))    //N1_FILIAL+N1_CBASE+N1_ITEM
                    SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID

                    SN3->(DBSeek(xFilial("SN3")+cN3UUID))

                    For nZ := 1 To oMdlExeGr:Length()
                        oMdlExeGr:GoLine(nZ)
                        if cN3UUID ==  oMdlExeGr:GetValue("F4T_SN3")
                            cUID        := oMdlExeGr:GetValue("F4T_UID")
                            cIDMOV      := ""
                            cOcorr      := "97"
                            aPrevVal    := AtfMultMoe( Nil, Nil, {|x| SN3->&("N3_AMPLIA" + Alltrim(Str(x)) ) })
                            nPrevTx		:= &(IIf(Val(cAtfCur) > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR') + cAtfCur)
                            aValues     := AtfMultMoe(,,{|x| 0})//AtfMultMoe(Nil, Nil, {|x| SN3->&("N3_VORIG" + Alltrim(Str(x)) ) - aPrevVal[x] })
                            aValues[1]  := oMdlExeGr:GetValue("F4T_VALUE") - oMdlExeGr:GetValue("F4T_PRREVV")
                            aValDepr    := AtfMultMoe(,,{|x| 0})
                            aValDepr[1] := oMdlExeGr:GetValue("F4T_VRDACM") - oMdlExeGr:GetValue("F4T_PRACDE")
                            Exit
                        EndIf
                    Next nZ

                    aCompData   := ATFXCompl(;
                        0 ,;
                        &(IIf(Val(cAtfCur) > 9,	'SN3->N3_TXDEP','SN3->N3_TXDEPR') + cAtfCur) - nPrevTx,;
                        "09"/*cMotivo*/,;
                        /*cCodBaix*/,;
                        /*cFilOrig*/,;
                        /*cSerie*/,;
                        /*cNota*/,;
                        /*nVenda*/,;
                        /*cLocal*/,;
                        SN3->N3_PRODMES)

                    ATFXMOV(;
                        SN3->N3_FILIAL,;
                        @cIDMOV,;
                        dDataBase,;
                        cOcorr,;
                        SN3->N3_CBASE,;
                        SN3->N3_ITEM,;
                        SN3->N3_TIPO,;
                        SN3->N3_BAIXA,;
					    SN3->N3_SEQ,;
					    SN3->N3_SEQREAV,;
    					"1",;
    					SN1->N1_QUANTD,;
	    				SN3->N3_TPSALDO,;
                        Nil,;
                        aValues,;
                        aCompData,;
                        Nil,;
                        .T.,;
                        Nil,;
                        Nil,;
                        Nil,;
                        Nil,;
                        "RU01T04",;
                        cUID)

                    oMdlExeGr:GoLine(nZ)
				    lRet    := oMdlExeGr:LoadValue("F4T_SN4UID", SN4->N4_UID)

                    aCompData   := ATFXCompl(;
                        0 ,;
                        &(IIf(Val(cAtfCur) > 9,	'SN3->N3_TXDEP','SN3->N3_TXDEPR') + cAtfCur) - nPrevTx,;
                        /*cMotivo*/,;
                        /*cCodBaix*/,;
                        /*cFilOrig*/,;
                        /*cSerie*/,;
                        /*cNota*/,;
                        /*nVenda*/,;
                        /*cLocal*/,;
                        SN3->N3_PRODMES)
                        
                    ATFXMOV(;
                        SN3->N3_FILIAL,;
                        @cIDMOV,;
                        dDataBase,;
                        "98",;
                        SN3->N3_CBASE,;
                        SN3->N3_ITEM,;
                        SN3->N3_TIPO,;
                        SN3->N3_BAIXA,;
					    SN3->N3_SEQ,;
					    SN3->N3_SEQREAV,;
    					"4",;
    					SN1->N1_QUANTD,;
	    				SN3->N3_TPSALDO,;
                        Nil,;
                        aValDepr,;
                        aCompData,;
                        Nil,;
                        .T.,;
                        Nil,;
                        Nil,;
                        Nil,;
                        Nil,;
                        "RU01T04",;
                        cUID)

                    aDifCurr	:= AtfMultMoe(,,{|x| SN4->&("N4_VLROC" + Alltrim(Str(x)) ) })
                    If oModel:GetModel("F4TDETAIL"):getvalue('F4T_INCOST') < oModel:GetModel("F4TDETAIL"):getvalue('F4T_VALUE')
                        cTypeDep:='E'
                    Else
                        cTypeDep:='F'
                    EndIf
                    ATFSaldo(;
                        SN3->N3_CCONTAB,;
                        dDataBase,;
                        cTypeDep,;
                        aDifCurr[01],;
                        aDifCurr[02],;
                        aDifCurr[03],;
                        aDifCurr[04],;
                        aDifCurr[05],;
                        "+",;
                        nCurRate,;
                        SN3->N3_SUBCCON,;
                        Nil,;
                        SN3->N3_CLVLCON,;
                        SN3->N3_CUSTBEM,;
                        "1",;
                        aDifCurr)
                EndIf

                If lRet
                    lFoundN3    := .F.
                    For nZ := 1 To oMdlExeGr:Length()
                        If oMdlExeGr:GetValue("F4T_SN3", nZ) == cN3UUID
                            lFoundN3    := .T.
                            oMdlExeGr:GoLine(nZ)
                            If ! oMdlExeGr:LoadValue("F4T_SN3PRE", cN3UUID)
                                lRet    := .F.
                                Help("",1,"RU01T04CORNCF",,STR0032,1,0)	// "Error setting the reference to new created balance in journal item"
                            EndIf
                            Exit
                        EndIf
                    Next nZ
                    If ! lFoundN3
                        lRet    := .F.
                        Help("",1,"RU01T04VLN34",,STR0018,1,0)	//"Error finding related FA record"
                        Exit
                    EndIf
                EndIf
            EndIf
        Next nX
    EndIf
ElseIf nOper == RU01T04_OPER_STORNO
    lRet        := .T.
    dDateRev    := oMdlExeHe:GetValue("F4S_DATE")
    aStornoExe  := {}
    If lRet
        For nX := 1 To oMdlExeGr:Length()
            oMdlExeGr:GoLine(nX)
            If ! oMdlExeGr:IsDeleted() .And. oMdlExeGr:GetValue("MVC_OK")
                lRet    := oMdlExeGr:SetValue("F4T_STATUS", F4T_STATUS_STORNOED)
                If ! lRet
                    Help("",1,"RU01T04COSTU",,STR0021,1,0)	//"Error while updating status of previous journal to stornoed"
                    Exit
                EndIf
                aAdd(aStornoExe, {;
                    oMdlExeGr:GetValue("F4T_SN3"),;     //01
                    oMdlExeGr:GetValue("F4T_VORIG"),;   //02
                    RU01T04004_CheckPreviousReevalValue(oMdlExeGr:GetValue("F4T_SN3"),"F4T_PRREVV"),;  //03
                    oMdlExeGr:GetValue("F4T_INCOST"),;    //04
                    oMdlExeGr:GetValue("F4T_AMPLIA"),;    //05
                    oMdlExeGr:GetValue("F4T_PRACDE"),;  //06
                    RU01T04004_CheckPreviousReevalValue(oMdlExeGr:GetValue("F4T_SN3"),"F4T_PRACDE"),;  //07
                    RU01T04004_CheckPreviousReevalValue(oMdlExeGr:GetValue("F4T_SN3"),"F4T_ACRVDE")})  //08
            EndIf
        Next nX
    EndIf
    If lRet
        oMdlJrSt    := FWLoadModel("RU01T04")
        oMdlJrSt:SetOperation(MODEL_OPERATION_INSERT)

        oMdlJrStH   := oMdlJrSt:GetModel("F4SMASTER")
        oMdlJrStG   := oMdlJrSt:GetModel("F4TDETAIL")
        oMdlJrSt:Activate()

        cJrnLot     := oMdlJrStH:GetValue("F4S_LOT")

        If lRet
            lRet    := lRet .And. oMdlJrStH:SetValue(;
                "F4S_OPER",;
                F4S_OPER_STORNO)
            lRet    := lRet .And. oMdlJrStH:SetValue(;
                "F4S_DESCR",;
                oMdlExeHe:GetValue("MVC_STODES"))
            If ! lRet
                RU01MVCERR(oMdlJrSt)
            EndIf
        EndIf

        If lRet
            oMdlJrStG:SetNoInsertLine(.F.)
            oStruct := oMdlJrStG:GetStruct()
            aFields := oStruct:GetFields()
            nLine   := 0
            For nX := 1 To oMdlExeGr:Length()
                If oMdlExeGr:IsDeleted(nX) .Or. ! oMdlExeGr:GetValue("MVC_OK", nX)
                    Loop
                EndIf

                If nLine == 0 .And. oMdlJrStG:Length() == 1
                    nLine   := 1
                Else
                    nLine   := oMdlJrStG:Length() + 1
                    lRet    := nLine == oMdlJrStG:AddLine()
                EndIf
                If ! lRet
                    RU01MVCERR(oMdlJrSt)
                    Exit
                EndIf

                For nY := 1 To Len(aFields)
                    cField  := aFields[nY, MODEL_FIELD_IDFIELD]
                    If  cField $ ;
                            "F4T_ITEM" + ;
                            "F4T_STATUS" + ;
                            "F4T_F4TLOT" + ;
                            "F4T_F4TITE" + ;
                            "F4T_HIST"
                                Loop
                    EndIf
                    lRet    := lRet .And. oMdlJrStG:LoadValue(;
                        cField,;
                        oMdlExeGr:GetValue(cField, nX))
                Next nY
				
                lRet    := lRet .And. oMdlJrStG:LoadValue("F4T_ITEM"    ,   StrZero(nLine, GetSX3Cache("F4T_ITEM", "X3_TAMANHO")))
                lRet    := lRet .And. oMdlJrStG:LoadValue("F4T_STATUS"  ,   F4T_STATUS_CONFIRMED)
                lRet    := lRet .And. oMdlJrStG:LoadValue("F4T_F4TLOT"  ,   oMdlExeGr:GetValue("F4T_LOT", nX))
                lRet    := lRet .And. oMdlJrStG:LoadValue("F4T_F4TITE"  ,   oMdlExeGr:GetValue("F4T_ITEM", nX))
                lRet    := lRet .And. oMdlJrStG:LoadValue("F4T_HIST"    ,   oMdlExeGr:GetValue("MVC_STOHIS", nX))

                For nY := 1 To Len(aStornoExe)
                    cN3UUID    := aStornoExe[nY][1]
                    If lRet
                        SN1->(dbSetOrder(1))    //N1_FILIAL+N1_CBASE+N1_ITEM
                        SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID
                        lRet    := SN3->(dbSeek(xFilial("SN3") + cN3UUID))
                        If ! lRet
                            Help("",1,"RU01T04VLN36",,STR0018,1,0)	//"Error finding related FA record"
                            Exit
                        EndIf
                        lRet    := SN1->(dbSeek(SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)))
                        If ! lRet
                            Help("",1,"RU01T04VLN37",,STR0018,1,0)	//"Error finding related FA record"
                            Exit
                        EndIf
                    EndIf
                    If lRet
                        oMdlAF12	:= FWLoadModel("ATFA012")
                        oMdlAF12:SetOperation(MODEL_OPERATION_UPDATE)
                        oMdlAF12:Activate()
                        oMdlAF12G    := oMdlAF12:GetModel("SN3DETAIL")
                        cPatrim     := oMdlAF12:GetModel("SN1MASTER"):GetValue("N1_PATRIM")
                            For nZ := 1 To oMdlAF12G:Length()    //create SN4 record about storno
                                If oMdlAF12G:GetValue("N3_UUID", nZ) == cN3UUID
                                    oMdlAF12G:GoLine(nZ)
                                        cKeySN3 := xFilial("SN3")
                                        cKeySN3 += oMdlAF12G:GetValue("N3_CBASE") 
                                        cKeySN3 += oMdlAF12G:GetValue("N3_ITEM")
                                        cKeySN3 += oMdlAF12G:GetValue("N3_TIPO") + oMdlAF12G:GetValue("N3_SEQ")
                                        lRet    := lRet .AND. RU01STOSN4(cKeySN3, cPatrim, oMdlJrStG:GetValue("F4T_UID"))
                                        lRet:= lRet .AND. oMdlJrStG:LoadValue("F4T_SN4UID", SN4->N4_UID)
                                    Exit
                                EndIf
                            Next nZ
                        oMdlAF12:DeActivate()
                    EndIf
                Next nY
                If ! lRet
                    RU01MVCERR(oMdlJrSt)
                    Exit
                EndIf
            Next nX
            oMdlJrStG:SetNoInsertLine(.T.)
            If ! lRet
                RU01MVCERR(oMdlJrSt)
            EndIf
        EndIf

        If lRet
            lRet    := FWFormCommit(oMdlJrSt)
            If ! lRet
                Help("",1,"RU01T04STNM",,STR0008,1,0)	//"Reevaluation storno journal is inconsistent"
            EndIf
        EndIf
    EndIf
    If lRet
        // Perform operation
        For nX := 1 To Len(aStornoExe)
            cUUIDOri    := aStornoExe[nX, 01]
            nReval      := aStornoExe[nX, 02]
            nPrevVal    := aStornoExe[nX, 03]
            nInCost     := aStornoExe[nX, 04]
            nEnlarg     := aStornoExe[nX, 05]
            nAcmDep     := aStornoExe[nX, 06]
            nPrAcmDep   := aStornoExe[nX, 07]
            nAcrVDep    := aStornoExe[nX, 08]

            If lRet
                SN1->(dbSetOrder(1))    //N1_FILIAL+N1_CBASE+N1_ITEM
                SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID
                lRet    := SN3->(dbSeek(xFilial("SN3") + cUUIDOri))
                If ! lRet
                    Help("",1,"RU01T04VLN31",,STR0018,1,0)	//"Error finding related FA record"
                    Exit
                EndIf
                lRet    := SN1->(dbSeek(SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)))
                If ! lRet
                    Help("",1,"RU01T04VLN32",,STR0018,1,0)	//"Error finding related FA record"
                    Exit
                EndIf
            EndIf

            // Process SN3 items
            If lRet
                oMdlAF12	:= FWLoadModel("ATFA012")
                oMdlAF12:SetOperation(MODEL_OPERATION_UPDATE)
                oMdlAF12:Activate()

                If lRet
                    oMdlAF12H   := oMdlAF12:GetModel("SN1MASTER")
                    oMdlAF12G   := oMdlAF12:GetModel("SN3DETAIL")

                    // Put old value N3_VORIg and N3_VRDACM of register in operation
                    If lRet
                        lFoundN3    := .F.
                        For nY := 1 To oMdlAF12G:Length()
                            lFoundN3    := cUUIDOri == oMdlAF12G:GetValue("N3_UUID", nY)
                            If lFoundN3
                                oMdlAF12G:GoLine(nY)
                                //Alexandra()
                                lRet    := lRet .And. oMdlAF12G:LoadValue("N3_VORIG" + cAtfCur, nReval)		//02
                                lRet    := lRet .And. oMdlAF12G:LoadValue("N3_PRREVVL", nPrevVal)			//03
                                lRet    := lRet .And. oMdlAF12G:LoadValue("N3_INCOST", nInCost)				//04
                                lRet    := lRet .And. oMdlAF12G:LoadValue("N3_AMPLIA" + cAtfCur, nEnlarg)	//05
                                lRet    := lRet .And. oMdlAF12G:SetValue("N3_VRDACM" + cAtfCur, nAcmDep)	//06
                                lRet    := lRet .And. oMdlAF12G:LoadValue("N3_PRACDEP", nPrAcmDep)			//07
                                lRet    := lRet .And. oMdlAF12G:LoadValue("N3_ACRVDEP", nAcrVDep)			//08
                                
                                If ! lRet
                                    RU01MVCERR(oMdlAF12)
                                    Help("",1,"RU01T04COVLPX",,STR0031,1,0)	// "Error setting values of new balances register"
                                    Exit
                                EndIf
                                
                                Exit
                            EndIf
                        Next nY
                        If ! lFoundN3
                            lRet    := .F.
                            Help("",1,"RU01T04VLN35",,STR0018,1,0)	//"Error finding related FA record"
                            Exit
                        ElseIf ! lRet
                            Exit
                        EndIf
                    EndIf
                EndIf

                If lRet
                    lRet    := FWFormCommit(oMdlAF12)
                    If ! lRet
                        RU01MVCERR(oMdlAF12)
                        Exit
                    EndIf
                EndIf

                oMdlAF12:DeActivate()
            EndIf
        Next nX
    EndIf
    oModel:Activate()
Else
    MsgStop("Not implemented")
EndIf
If lRet
    lRet    := FWFormCommit(oModel)
    If ! lRet
        RU01MVCERR(oModel)
    EndIf
EndIf
If ! lRet
    DisarmTransaction()
EndIf
END TRANSACTION

If lRet
    // ATFA012 bug
    cQuery  := " SELECT SN3.R_E_C_N_O_ AS N3RECNO "
    cQuery  += "   FROM "+retsqlname("F4S")+" F4S "
    cQuery  += "   JOIN "+retsqlname("F4T")+" F4T ON F4T_LOT = F4S_LOT "
    cQuery  += "   JOIN "+retsqlname("SN3")+" SN3 ON N3_UUID = F4T_SN3PRE "
    cQuery  += "  WHERE F4S.D_E_L_E_T_ = ' ' "
    cQuery  += "    AND F4T.D_E_L_E_T_ = ' ' "
    cQuery  += "    AND SN3.D_E_L_E_T_ = ' ' "
    cQuery  += "    AND F4S_FILIAL = '"+xFilial("F4S")+"' "
    cQuery  += "    AND F4T_FILIAL = '"+xFilial("F4T")+"' "
    cQuery  += "    AND N3_FILIAL = '"+xFilial("SN3")+"' "
    cQuery  += "    AND F4S_LOT = '"+cJrnLot+"' "
    cQuery  += "    AND F4S_OPER = '"+F4S_OPER_EXECUTION+"' "
    cQuery  += "    AND F4T_STATUS = '"+F4T_STATUS_CONFIRMED+"' "
    cQuery  += "    AND N3_BAIXA = ' ' "
    cQuery:=ChangeQuery(cQuery)
    cAlsTmp := RU01GETALS(cQuery)
    While (cAlsTmp)->(! EOF())
        SN3->(dbGoTo((cAlsTmp)->N3RECNO))
        RecLock("SN3", .F.)
        SN3->N3_BAIXA   := SN3_BAIXA_ACTIVE
        SN3->(MsUnlock())
        (cAlsTmp)->(dbSkip())
    EndDo
    (cAlsTmp)->(dbCloseArea())
EndIf

If lRet .And. ! Empty(cJrnLot)
    RU01T04STE(cJrnLot)
EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04STE

Process standard entries 

@param		CHARACTER cLot
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04STE(cLot AS CHARACTER)
Local cQuery        AS CHARACTER
Local cAlsTmp       AS CHARACTER
Local cStdEntry     AS CHARACTER
Local lDisplay      AS LOGICAL
Local lGroup        AS LOGICAL
Local lOffline      AS LOGICAL
Local aRegisters    AS ARRAY
Local aTmp          AS ARRAY
Local aArea         AS ARRAY
Local aAreaF4S      AS ARRAY

aArea       := GetArea()
aAreaF4S    := F4S->(GetArea())

cStdEntry   := ""
lRet        := .T.

F4S->(dbSetOrder(1))    //F4S_FILIAL+F4S_LOT
lRet    := F4S->(dbSeek(xFilial("F4S") + cLot))

cQuery  := "   SELECT F4T_LOT, "
cQuery  += "          F4T_ITEM, "
cQuery  += "          F4S.R_E_C_N_O_ AS F4SRECNO, "
cQuery  += "          F4T.R_E_C_N_O_ AS F4TRECNO, "
cQuery  += "          SN3.R_E_C_N_O_ AS SN3RECNO, "
cQuery  += "          SN1.R_E_C_N_O_ AS SN1RECNO "
cQuery  += "     FROM "+RetSqlName("F4S")+" F4S "
cQuery  += "     JOIN "+RetSqlName("F4T")+" F4T ON F4T_LOT = F4S_LOT "
cQuery  += "     JOIN "+RetSqlName("SN3")+" SN3 ON "
cQuery  += "                                       ( "
cQuery  += "                                             F4S_OPER = '"+F4S_OPER_EXECUTION+"' "
cQuery  += "                                         AND N3_UUID = F4T_SN3PRE "
cQuery  += "                                       ) "
cQuery  += "                                    OR ( "
cQuery  += "                                             F4S_OPER = '"+F4S_OPER_STORNO+"' "
cQuery  += "                                         AND N3_UUID = F4T_SN3 "
cQuery  += "                                       ) "
cQuery  += "     JOIN "+RetSqlName("SN1")+" SN1 "
cQuery  += "       ON N1_CBASE = N3_CBASE "
cQuery  += "      AND N1_ITEM = N3_ITEM "
cQuery  += "    WHERE F4S.D_E_L_E_T_ = ' ' "
cQuery  += "      AND F4T.D_E_L_E_T_ = ' ' "
cQuery  += "      AND SN3.D_E_L_E_T_ = ' ' "
cQuery  += "      AND SN1.D_E_L_E_T_ = ' ' "
cQuery  += "      AND F4S_FILIAL = '"+xFilial("F4S")+"' "
cQuery  += "      AND F4T_FILIAL = '"+xFilial("F4T")+"' "
cQuery  += "      AND N3_FILIAL = '"+xFilial("SN3")+"' "
cQuery  += "      AND N1_FILIAL = '"+xFilial("SN1")+"' "
cQuery  += "      AND F4S_LOT = '"+cLot+"' "
cQuery  += "      AND F4T_STATUS = '"+F4T_STATUS_CONFIRMED+"' "
cQuery  += " ORDER BY F4T_LOT, F4T_ITEM "

aRegisters  := {}
cQuery:=ChangeQuery(cQuery)
cAlsTmp     := RU01GETALS(cQuery)

While (cAlsTmp)->(! EOF())
    aTmp    := {}
    aAdd(aTmp, {"F4S", (cAlsTmp)->F4SRECNO})
    aAdd(aTmp, {"F4T", (cAlsTmp)->F4TRECNO})
    aAdd(aTmp, {"SN3", (cAlsTmp)->SN3RECNO})
    aAdd(aTmp, {"SN1", (cAlsTmp)->SN1RECNO})
    aAdd(aRegisters, aTmp)
    
    If Empty(cStdEntry)
        cStdEntry   := IIf(F4S->F4S_OPER == F4S_OPER_EXECUTION,;
            "80E",;
            "80F")
    EndIf
    (cAlsTmp)->(dbSkip())
EndDo

(cAlsTmp)->(dbCloseArea())

If ! Empty(aRegisters)
    lDisplay    := Nil
    lGroup      := Nil
    lOffline    := Nil
    If Pergunte("RU01T04RUS", .F.)
        lDisplay    := (MV_PAR01 == 1)
        lGroup      := (MV_PAR02 == 1)
    EndIf

    lRet    := RU0134STEN(;
        cStdEntry,;
        "RU01T04" /* cRoutine */,;
        "F4T" /* cBaseAlias */,;
        aRegisters,;
        lDisplay,;
        lGroup,;
        lOffline)
EndIf

RestArea(aAreaF4S)
RestArea(aArea)

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
Local nOper         AS NUMERIC
Local aRelat		AS ARRAY
Local oStruF4S		AS OBJECT
Local oStruF4T		AS OBJECT
Local oModel		AS OBJECT

oStruF4S	:= FWFormStruct(1, "F4S")
oStruF4T	:= FWFormStruct(1, "F4T")

nOper       := GetOperation()

If nOper == RU01T04_OPER_REEVALUATION
    oStruF4S:AddField(STR0014, STR0014, "MVC_COEF", "N", GetSx3Cache("F4T_COEFFI", "X3_TAMANHO"), GetSx3Cache("F4T_COEFFI", "X3_DECIMAL"), {|oVldModel, cVldField, xVldNVal, xVldOVal| RU01T04VLD(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| 0 } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//"Coefficient"
EndIf
If nOper == RU01T04_OPER_STORNO
    oStruF4S:AddField(STR0019, STR0019, "MVC_STODES", "C", GetSX3Cache("F4S_DESCR","X3_TAMANHO"), 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| .T. } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .T. /* lObrigat */, {|| STR0034 } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//"Storno Description","Storno of "
    oStruF4T:AddField(STR0023, STR0023, "MVC_STOHIS", "C", GetSX3Cache("F4T_HIST","X3_TAMANHO"), 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| .T. } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .T. /* lObrigat */, {|| STR0034 } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//"Storno History","Storno of "
EndIf
If nOper == RU01T04_OPER_REEVALUATION .Or. nOper == RU01T04_OPER_STORNO
    oStruF4S:AddField(STR0013, STR0013, "MVC_CHKALL", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| RU01T04VLD(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| nOper == RU01T04_OPER_REEVALUATION } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//"Mark all"
    oStruF4T:AddField(STR0012, STR0012, "MVC_OK", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| RU01T04VLD(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| nOper == RU01T04_OPER_REEVALUATION } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//" "
EndIf

oModel		:= MPFormModel():New("RU01T04", /* Pre-valid */, {|oMdl| RU01T04POS(oMdl) } /* Pos-Valid */, {|oMdl| RU01T04COM(oMdl) } /* Commit */)

oModel:AddFields("F4SMASTER", /*cOwner*/, oStruF4S)
oModel:GetModel("F4SMASTER"):SetDescription(STR0006) // "Journal Details"
oModel:AddGrid("F4TDETAIL", "F4SMASTER", oStruF4T, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
aRelat	:= {}
aAdd(aRelat, {"F4T_FILIAL", "XFILIAL('F4T')"})
aAdd(aRelat, {"F4T_LOT", "F4S_LOT"})
oModel:SetRelation("F4TDETAIL", aRelat, F4T->(IndexKey(1)))
oModel:GetModel("F4TDETAIL"):SetOptional(.T.)
oModel:GetModel("F4TDETAIL"):SetNoInsertLine(.T.)

oModel:SetDescription(STR0007) // "Journal Description"

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
Local nOper         AS NUMERIC
Local cF4SIgnore    AS CHARACTER
Local cF4TIgnore    AS CHARACTER
Local oStruF4S		AS OBJECT
Local oStruF4T		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

oModel		:= FWLoadModel("RU01T04")

cF4SIgnore  := ""
cF4TIgnore  := ""
If GetOperation() == RU01T04_OPER_REEVALUATION
    cF4SIgnore  += "F4S_DATE"
    cF4SIgnore  += "F4S_USER"

    cF4TIgnore  += "F4T_FILIAL"
    cF4TIgnore  += "F4T_LOT"
    cF4TIgnore  += "F4T_SN3"
    cF4TIgnore  += "F4T_SN3PRE"
    cF4TIgnore  += "F4T_F4TLOT"
    cF4TIgnore  += "F4T_F4TITE"
    cF4TIgnore  += "F4T_LA"
    cF4TIgnore  += "F4T_ITEM"
    cF4TIgnore  += "F4T_STATUS"
    
    /*@author: astepanov*/
    cF4TIgnore  += "F4T_VORIG"
    cF4TIgnore  += "F4T_AMPLIA"
    cF4TIgnore  += "F4T_INCOST"
    cF4TIgnore  += "F4T_VRDMES"
    cF4TIgnore  += "F4T_PACRVD"
    cF4TIgnore  += "F4T_COEFFI"
    cF4TIgnore  += "F4T_ACRVDE"

ElseIf GetOperation() == RU01T04_OPER_STORNO
    cF4TIgnore  += "F4T_FILIAL"
    cF4TIgnore  += "F4T_LOT"
    cF4TIgnore  += "F4T_SN3"
    cF4TIgnore  += "F4T_SN3PRE"
    cF4TIgnore  += "F4T_F4TLOT"
    cF4TIgnore  += "F4T_F4TITE"
    cF4TIgnore  += "F4T_LA"
    cF4TIgnore  += "F4T_HIST"

    /*@author: astepanov*/
    cF4TIgnore  += "F4T_VORIG"
    cF4TIgnore  += "F4T_AMPLIA"
    cF4TIgnore  += "F4T_INCOST"
    cF4TIgnore  += "F4T_VRDMES"
    cF4TIgnore  += "F4T_PACRVD"
    cF4TIgnore  += "F4T_COEFFI"
    cF4TIgnore  += "F4T_ACRVDE"
    cF4TIgnore  += "F4T_ITEM"
    cF4TIgnore  += "F4T_STATUS"

Else
    cF4TIgnore  += "F4T_FILIAL"
    cF4TIgnore  += "F4T_LOT"
    cF4TIgnore  += "F4T_SN3"
    cF4TIgnore  += "F4T_SN3PRE"
    cF4TIgnore  += "F4T_F4TLOT"
    cF4TIgnore  += "F4T_F4TITE"
    cF4TIgnore  += "F4T_LA"
    
    /*@author: astepanov*/
    cF4TIgnore  += "F4T_VORIG"
    cF4TIgnore  += "F4T_AMPLIA"
    cF4TIgnore  += "F4T_INCOST"
    cF4TIgnore  += "F4T_VRDMES"
    cF4TIgnore  += "F4T_PACRVD"
    cF4TIgnore  += "F4T_COEFFI"
    cF4TIgnore  += "F4T_ACRVDE"
    cF4TIgnore  += "F4T_ITEM"
    cF4TIgnore  += "F4T_STATUS"

EndIf

cF4TIgnore  += "F4T_UID"
cF4TIgnore  += "F4T_SN4UID"

oStruF4S	:= FWFormStruct(2, "F4S", {|x| !(AllTrim(x) $ cF4SIgnore)})
oStruF4T	:= FWFormStruct(2, "F4T", {|x| !(AllTrim(x) $ cF4TIgnore)})

nOper       := GetOperation()

If nOper == RU01T04_OPER_REEVALUATION
    oStruF4S:AddField("MVC_COEF", PADR('ZA', Len(SX3->X3_ORDEM), 'Z'), STR0014, STR0014, Nil, "Get", GetSx3Cache("F4T_COEFFI", "X3_PICTURE"),,,.T.)	//"Coefficient"
EndIf
If nOper == RU01T04_OPER_STORNO
    oStruF4S:AddField("MVC_STODES", PADR('ZA', Len(SX3->X3_ORDEM), 'X'), STR0019, STR0019, Nil, "Get", GetSx3Cache("F4S_DESCR", "X3_PICTURE"),,,.T.)	//"Storno Description"
    oStruF4T:AddField("MVC_STOHIS", PADR('ZA', Len(SX3->X3_ORDEM), 'X'), STR0023, STR0023, Nil, "Get", GetSx3Cache("F4T_HIST", "X3_PICTURE"),,,.T.)	//"Storno History"
EndIf
If nOper == RU01T04_OPER_REEVALUATION .Or. nOper == RU01T04_OPER_STORNO
    oStruF4S:AddField("MVC_CHKALL", PADR('', Len(SX3->X3_ORDEM), 'Z'), STR0013, STR0013, Nil, "Get", "",,,.T.)	//"Mark all"
    oStruF4T:AddField("MVC_OK", StrZero(1, Len(SX3->X3_ORDEM)), STR0012, STR0012, Nil, "Get", "",,,.T.)	//" "
EndIf

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F4S", oStruF4S, "F4SMASTER")
oView:AddGrid("VIEW_GRID", oStruF4T, "F4TDETAIL")
oView:AddIncrementField("VIEW_GRID", "F4T_ITEM")
oView:CreateHorizontalBox("MAIN", 25)
oView:CreateHorizontalBox("GRID", 75)
oView:SetOwnerView("VIEW_F4S", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

oView:addUserButton(STR0035, "", {|| RU01T04PRT(oStruF4S, oStruF4T) })  //Print

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
If IsInCallStack("RU01T04STO")
    nOper   := RU01T04_OPER_STORNO
ElseIf IsInCallStack("RU01T04INC")
    nOper   := RU01T04_OPER_REEVALUATION
EndIf
Return nOper

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04VLD

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
Function RU01T04VLD(oVldModel AS OBJECT, cVldField AS CHARACTER, xVldNVal, xVldOVal)
Local nX        AS NUMERIC
Local cQuery    AS CHARACTER
Local cAlsTmp   AS CHARACTER
Local lRet      AS LOGICAL
Local dDtVld    AS DATE
Local aArea     AS ARRAY
Local aAreaSN3  AS ARRAY
Local oModel    AS OBJECT
Local oModelGrd AS OBJECT
Local oView     AS OBJECT
Local oGridObj  AS OBJECT

lRet    := .F.
oModel  := FWModelActive()

If cVldField == "MVC_CHKALL"
    lRet        := .T.
    oModelGrd   := oModel:GetModel("F4TDETAIL")
    For nX := 1 To oModelGrd:Length()
        oModelGrd:GoLine(nX)
        If ! oModelGrd:IsDeleted()
            oModelGrd:SetValue("MVC_OK", xVldNVal)
        EndIf
    Next nX
    oView		:= FWViewActive()
    oGridObj	:= oView:GetViewObj("VIEW_GRID")[3]
    oGridObj:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
ElseIf cVldField == "MVC_COEF"
    lRet    := xVldNVal > 0
    If lRet
        oModelGrd   := oModel:GetModel("F4TDETAIL")
        For nX := 1 To oModelGrd:Length()
            oModelGrd:GoLine(nX)
            If ! oModelGrd:IsDeleted()
                oModelGrd:SetValue("F4T_COEFFI", xVldNVal)
            EndIf
        Next nX
        oView		:= FWViewActive()
        oGridObj	:= oView:GetViewObj("VIEW_GRID")[3]
        oGridObj:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
    EndIf
ElseIf cVldField == "MVC_OK"
    lRet    := .T.
    If GetOperation() == RU01T04_OPER_STORNO
        lRet    := oVldModel:GetValue("F4T_STATUS") == F4T_STATUS_CONFIRMED
        If ! lRet .And. "MVC_OK" $ ReadVar()
            Help("",1,"RU01T04STCF",,STR0020,1,0)	//"Journal item must have confirmed status for storno operation"
        EndIf
    EndIf
ElseIf cVldField == "POSVALID"
    lRet        := .T.

    aArea       := GetArea()
    aAreaSN3    := SN3->(GetArea())

    If lRet
        lRet    := oVldModel:GetValue("F4T_PRREVV") <> oVldModel:GetValue("F4T_VALUE")
        If ! lRet
            Help("",1,"RU01T04VLGR",,STR0015,1,0)	// "All lines marked for execution must have a revaluation value different than previous value"
        EndIf
    EndIf

    If lRet
        SN3->(dbSetOrder(13))    //N3_FILIAL+N3_UUID
        lRet    := SN3->(dbSeek(xFilial("SN3") + oVldModel:GetValue("F4T_SN3")))
        If ! lRet
            Help("",1,"RU01T04VLN3A",,STR0018,1,0)	//"Error finding related FA record"
        EndIf
    EndIf
    
    // Write-off operations is already validated by ATFA036
    If lRet
        dDtVld  := xVldNVal:GetValue("F4SMASTER", "F4S_DATE")

		cQuery	:= " SELECT N4_CBASE "
		cQuery	+= "   FROM "+RetSqlName("SN4")+" SN4 "
		cQuery	+= "  WHERE N4_FILIAL = '"+SN3->N3_FILIAL+"' "
		cQuery	+= "    AND N4_CBASE = '"+SN3->N3_CBASE+"' "
		cQuery	+= "    AND N4_ITEM = '"+SN3->N3_ITEM+"' "
		cQuery	+= "    AND N4_TIPO = '"+SN3->N3_TIPO+"' "
		cQuery	+= "    AND N4_SEQ = '"+SN3->N3_SEQ+"' "
		cQuery	+= "    AND N4_MOTIVO <> '"+FN6_MOTIVO_WRITE_OFF+"' "
		cQuery	+= "    AND SN4.D_E_L_E_T_ = ' ' "
        cQuery	+= "    AND ( "
        cQuery	+= "             N4_DATA > '"+DToS(dDtVld)+"' "
        cQuery	+= "          OR ( "
        cQuery	+= "                   N4_DATA = '"+DToS(dDtVld)+"' "
        cQuery	+= "               AND N4_OCORR NOT IN ( "
        cQuery	+= "                     '05','07','08','10','11', "
        cQuery	+= "                     '06','12','17','18','20','63'"
        cQuery	+= "                   ) "
        cQuery	+= "             ) "
        cQuery	+= "        ) "
        If GetOperation() == RU01T04_OPER_STORNO
            cQuery	+= "    AND NOT (N4_OCORR = '01' AND N4_MOTIVO = '"+FN6_MOTIVO_WRITE_OFF+"' ) "
            cQuery	+= "    AND N4_DATA >= '"+DToS(dDtVld)+"' "
        EndIf
        cQuery	+= "    AND N4_STORNO <> '"+SN4_STATUS_STORNO+"' "
        cQuery:=ChangeQuery(cQuery)
        cAlsTmp := RU01GETALS(cQuery)
        lRet    := (cAlsTmp)->(EOF())
        (cAlsTmp)->(dbCloseArea())

        If ! lRet
            Help("",1,"RU01T04NN4",,STR0022,1,0)	//"Execution is not allowed for fixed assets with subsequent transactions"
        EndIf
    EndIf

    RestArea(aAreaSN3)
    RestArea(aArea)
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04TRI

Trigger processing

@param		CHARACTER cFieldFrom
@param		CHARACTER cFieldTo
@return		MIXED xRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04TRI(cFieldFrom AS CHARACTER, cFieldTo AS CHARACTER)
Local nX            AS NUMERIC
Local nAcrVDep      AS NUMERIC
Local nInCost       AS NUMERIC
Local nOrigVal      AS NUMERIC
Local nReval        AS NUMERIC
Local nCalcAcm      AS NUMERIC
Local nPreAcmDep    AS NUMERIC
Local cManTypes     AS CHARACTER
Local cN3Type       AS CHARACTER
Local lRVToHigh     AS LOGICAL
Local lCrHInitia    AS LOGICAL
Local lRVHInitia    AS LOGICAL
Local aManTypes     AS ARRAY
Local oModel        AS OBJECT
Local oModelGrd     AS OBJECT
Local xRet

oModel      := FWModelActive()
oModelGrd   := oModel:GetModel("F4TDETAIL")

If cFieldFrom == "F4T_VALUE" .And. cFieldTo == "F4T_ACRVDE"
    xRet        := 0
    // Set the variation for accumulated depreciation
    // This is the absolute value of the accumulatedvariation of
    //  variation on accumulated depreciation forrevaluation operations
    nAcrVDep    := oModelGrd:GetValue("F4T_PACRVD") // Accumulated depreciation after revaluation
    nInCost     := oModelGrd:GetValue("F4T_INCOST")
    nOrigVal    := oModelGrd:GetValue("F4T_VORIG")
    nReval      := oModelGrd:GetValue("F4T_VALUE")
    nPreAcmDep  := oModelGrd:GetValue("F4T_PRACDE")
    nCalcAcm    := RU01T04TRI("F4T_VALUE", "F4T_VRDACM")

    //Revaluation to greater value
    lRVToHigh	:= nReval >= nOrigVal

    //Previous value greater than initial
    lCrHInitia	:= nOrigVal >= nInCost

    //Revaluation greater than initial
    lRVHInitia	:= nReval >= nInCost

    If 		 lRVToHigh .And.  lCrHInitia .And.  lRVHInitia ;xRet := 0 + nAcrVDep + nCalcAcm - nPreAcmDep
    ElseIf 	 lRVToHigh .And.  lCrHInitia .And. !lRVHInitia  //Impossible scenario
    ElseIf 	 lRVToHigh .And. !lCrHInitia .And.  lRVHInitia ;xRet := 0 - nAcrVDep + nCalcAcm - nPreAcmDep
    ElseIf 	 lRVToHigh .And. !lCrHInitia .And. !lRVHInitia ;xRet := 0 + nAcrVDep + nCalcAcm - nPreAcmDep
    ElseIf 	!lRVToHigh .And.  lCrHInitia .And.  lRVHInitia ;xRet := 0 + nAcrVDep + nCalcAcm - nPreAcmDep
    ElseIf 	!lRVToHigh .And.  lCrHInitia .And. !lRVHInitia ;xRet := 0 - nAcrVDep - nCalcAcm + nPreAcmDep
    ElseIf 	!lRVToHigh .And. !lCrHInitia .And.  lRVHInitia  //Impossible scenario
    ElseIf 	!lRVToHigh .And. !lCrHInitia .And. !lRVHInitia ;xRet := 0 + nAcrVDep - nCalcAcm + nPreAcmDep
    EndIf
ElseIf cFieldFrom == "F4T_VALUE" .And. cFieldTo == "F4T_VRDACM"
    xRet    := oModelGrd:GetValue("F4T_PRACDE")
    xRet    := xRet * oModelGrd:GetValue("F4T_VALUE")
    xRet    := xRet / (oModelGrd:GetValue("F4T_PRREVV"))
    xRet    := Round(xRet, 02)
ElseIf cFieldFrom == "F4T_VALUE" .And. cFieldTo == "F4T_COEFFI"
    xRet    := oModelGrd:GetValue("F4T_VALUE")
    xRet    := xRet / (oModelGrd:GetValue("F4T_PRREVV"))
ElseIf cFieldFrom == "F4T_VALUE" .And. cFieldTo == "F4T_NEWTYP"
    xRet        := ""
    cManTypes	:= AtfNValMod({1,2,3},"|")
    aManTypes	:= Separa(cManTypes, "|", .T.)
    nX          := 1
    cN3Type     := oModelGrd:GetValue("F4T_VN3TIP")
    While Empty(xRet) .And. nX < Len(aManTypes)
        If cN3Type $ aManTypes[nX] + "|" + aManTypes[nX+1] + "|" + aManTypes[nX+2]
            If oModelGrd:GetValue("F4T_VALUE") >= oModelGrd:GetValue("F4T_INCOST") + oModelGrd:GetValue("F4T_AMPLIA")
                xRet	:= aManTypes[nX+1]	//Positive revaluation
            Else
                xRet	:= aManTypes[nX+2]	//Negative revaluation
            EndIf
        EndIf
        nX		+= 3
    EndDo
EndIf

Return xRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04_01PreviousRegister

Return the recno of the Valid previous revaluation register for the 
currently positioned SN3 register

@param		LOGICAL lNonWrtOff [OPTIONAL] - Filter for only non-written off registers
@param		ARRAY aFields [OPTIONAL] - Fields that should be filled (reference param)
@param		LOGICAL lSeqReval [OPTIONAL] - Filter n3_seqreav order
@return		NUMERIC - Recno of the register, -1 if non existent
@author 	victor.rezende
@since 		18/09/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04_01PreviousRegister(lNonWrtOff, aFields, lSeqReval)
Local nX		AS NUMERIC
Local nRet		AS NUMERIC
Local cTipo		AS CHARACTER
Local cManTipos	AS CHARACTER
Local cFilTipos	AS CHARACTER
Local cTp1		AS CHARACTER
Local cTp2		AS CHARACTER
Local cTp3		AS CHARACTER
Local cQuery	AS CHARACTER
Local cAliasTrb	AS CHARACTER
Local aTipos	AS ARRAY
Local aArea		AS ARRAY

Default lNonWrtOff	:= .F.
Default aFields		:= {}
Default lSeqReval	:= .T.

aArea		:= GetArea()

nRet		:= -1
cTipo		:= SN3->N3_TIPO
cManTipos	:= AtfNValMod({1,2,3},"|")
cManTipos	:= "10|16|17" + IIf(!Empty(cManTipos), "|" + cManTipos, "")

aTipos		:= Separa(cManTipos, "|", .T.)

nX			:= 1
cFilTipos	:= ""
While nX < Len(aTipos)
	cTp1	:= aTipos[nX]
	cTp2	:= aTipos[nX+1]
	cTp3	:= aTipos[nX+2]
	nX		+= 3	//By definition managerial typeset must always come in 4-tuples
	
	If cTipo $ cTp1 + "|" + cTp2 + "|" + cTp3
		cFilTipos	:= "'"+cTp1+"','"+cTp2+"','"+cTp3+"'"
	EndIf
EndDo

If ! Empty(cFilTipos)
	cQuery	:= " SELECT SN3.R_E_C_N_O_ AS RECNUM "
	For nX := 1 To Len(aFields)
		cQuery += " , " + aFields[nX,01]
	Next nX
	cQuery	+= "  FROM " + RetSqlName("SN3") + " SN3 "
	cQuery	+= " WHERE SN3.D_E_L_E_T_ = ' ' "
	cQuery	+= "   AND N3_FILIAL = '"+SN3->N3_FILIAL+"' "
	cQuery	+= "   AND N3_CBASE = '"+SN3->N3_CBASE+"' "
	cQuery	+= "   AND N3_ITEM = '"+SN3->N3_ITEM+"' "
	cQuery	+= "   AND N3_TIPO IN ("+cFilTipos+") "
	cQuery	+= IIf(lSeqReval, " AND N3_SEQREAV < '"+SN3->N3_SEQREAV+"' ", "")
	cQuery	+= IIf(lNonWrtOff, " AND N3_BAIXA <> '1' ", "")
	cQuery	+= " ORDER BY N3_SEQREAV DESC "
	cAliasTrb	:= CriaTrab(Nil, .F.)
    cQuery:=ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasTrb )
	If (cAliasTrb)->(!EOF())
		nRet	:= (cAliasTrb)->recnum
		For nX := 1 To Len(aFields)
			aFields[nX,02]	:= &("('"+cAliasTrb+"')->" + AllTrim(aFields[nX,01]))
		Next nX
	EndIf
	(cAliasTrb)->(dbCloseArea())
EndIf

RestArea(aArea)

Return nRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04_02DiffVarDepr

Return the difference over variation on accumulated depreciation for 
standard entries on revaluation calculation for the currently positioned
SN3 register

@param		None
@return		ARRAY - Array of values {Profit credit, Profit debit, Loss credit, Loss debit}
@author 	victor.rezende
@since 		18/09/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04_02DiffVarDepr()
Local nPrevNeg	AS NUMERIC
Local aRet		AS ARRAY
Local aTmp		AS ARRAY
Local aArea		AS ARRAY
Local aAreaSN3  AS ARRAY

aRet		:= {0, 0, 0, 0}

nPrevNeg	:= 0
If F4T->(F4T_ACRVDE <> 0)
    aArea       := GetArea()
    aAreaSN3    := SN3->(GetArea())

    SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID
    If SN3->(dbSeek(xFilial("SN3") + F4T->F4T_SN3))
        nPrevNeg    := SN3->N3_ACRVDEP
    EndIf

    RestArea(aAreaSN3)
    RestArea(aArea)
EndIf

//Profit credit (83-02)
If F4T->(F4T_ACRVDE > 0 .And. F4T_VALUE >= F4T_PRREVV .And. F4T_VALUE >= (F4T_INCOST + F4T_AMPLIA) .And. F4T_PRREVV >= (F4T_INCOST + F4T_AMPLIA))
	aRet[01]	:= F4T->(F4T_VRDACM - F4T_PRACDE)
ElseIf F4T->(F4T_ACRVDE > 0 .And. F4T_VALUE >= (F4T_INCOST + F4T_AMPLIA) .And. F4T_VALUE >= F4T_PRREVV .And. (F4T_INCOST + F4T_AMPLIA) >= F4T_PRREVV) .And. nPrevNeg < 0
	aRet[01]	:= F4T->(F4T_VRDACM - F4T_PRACDE) + nPrevNeg
ElseIf F4T->(F4T_ACRVDE > 0 .And. F4T_VALUE >= (F4T_INCOST + F4T_AMPLIA) .And. F4T_VALUE >= F4T_PRREVV .And. (F4T_INCOST + F4T_AMPLIA) >= F4T_PRREVV)
	aRet[01]	:= F4T->(F4T_ACRVDE)
EndIf

//Profit debit (02-83)
If F4T->(F4T_ACRVDE > 0 .And. (F4T_INCOST + F4T_AMPLIA) >= F4T_VALUE .And. F4T_PRREVV >= F4T_VALUE .And. F4T_PRREVV >= (F4T_INCOST + F4T_AMPLIA))
	aRet[02]	:= F4T->(F4T_PRACDE - F4T_VRDACM - F4T_ACRVDE)
ElseIf F4T->(F4T_ACRVDE < 0) .And. nPrevNeg > 0
	aRet[02]	:= nPrevNeg
EndIf

//Loss credit (02-91)
If F4T->(F4T_ACRVDE > 0 .And. F4T_PRREVV >= F4T_VALUE .And. (F4T_INCOST + F4T_AMPLIA) >= F4T_VALUE .And. (F4T_INCOST + F4T_AMPLIA) >= F4T_PRREVV)
	aRet[03]	:= F4T->(F4T_PRACDE - F4T_VRDACM)
ElseIf F4T->(F4T_ACRVDE > 0 .And. (F4T_INCOST + F4T_AMPLIA) >= F4T_VALUE .And. F4T_PRREVV >= F4T_VALUE .And. F4T_PRREVV >= (F4T_INCOST + F4T_AMPLIA))
	aRet[03]	:= F4T->(F4T_ACRVDE)
ElseIf F4T->(F4T_ACRVDE < 0) .And. nPrevNeg >= 0
	aRet[03]	:= Abs(F4T->F4T_ACRVDE)
ElseIf F4T->(F4T_ACRVDE < 0) .And. nPrevNeg < 0
	aRet[03]	:= F4T->(F4T_PRACDE - F4T_VRDACM)
EndIf

//Loss debit (91-02)
If F4T->(F4T_ACRVDE > 0 .And. F4T_VALUE >= (F4T_INCOST + F4T_AMPLIA) .And. F4T_VALUE >= F4T_PRREVV .And. (F4T_INCOST + F4T_AMPLIA) >= F4T_PRREVV) .And. nPrevNeg >= 0
	aRet[04]	:= F4T->(F4T_VRDACM - F4T_PRACDE - F4T_ACRVDE)
ElseIf F4T->(F4T_ACRVDE > 0) .And. nPrevNeg < 0
	aRet[04]	:= Abs(nPrevNeg)
EndIf

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04_03DiffCost

Return the standard entry value for the difference over cost on
russian revaluation of the positioned SN3 register.

@param		None
@return		ARRAY - Array of values {Profit credit, Profit debit, Loss credit, Loss debit}
@author 	victor.rezende
@since 		18/09/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04_03DiffCost()
Local aRet		AS ARRAY

aRet	    := {0, 0, 0, 0}

//Profit credit (01-83)
If F4T->(F4T_VALUE > (F4T_INCOST + F4T_AMPLIA) .And. F4T_VALUE > F4T_PRREVV)
	aRet[01]		:= F4T->F4T_VALUE
	If F4T->F4T_PRREVV > F4T->(F4T_INCOST + F4T_AMPLIA)
		aRet[01]	-= F4T->F4T_PRREVV
	Else
		aRet[01]	-= F4T->(F4T_INCOST + F4T_AMPLIA)
	EndIf
EndIf

//Profit debit (83-01)
If F4T->( F4T_PRREVV > F4T_VALUE .And. F4T_PRREVV > (F4T_INCOST + F4T_AMPLIA) )
	aRet[02]		:= F4T->F4T_PRREVV
	If F4T->F4T_VALUE > F4T->(F4T_INCOST + F4T_AMPLIA)
		aRet[02]	-= F4T->F4T_VALUE
	Else
		aRet[02]	-= F4T->(F4T_INCOST + F4T_AMPLIA)
	EndIf
EndIf

//Loss credit (91-01)
If F4T->(F4T_VALUE < (F4T_INCOST + F4T_AMPLIA) .And. F4T_PRREVV > F4T_VALUE)
	If F4T->F4T_PRREVV < F4T->(F4T_INCOST + F4T_AMPLIA)
		aRet[03]	:= F4T->F4T_PRREVV
	Else
		aRet[03]	:= F4T->(F4T_INCOST + F4T_AMPLIA)
	EndIf
	aRet[03]		-= F4T->F4T_VALUE
EndIf

//Loss debit (01-91)
If F4T->( F4T_PRREVV < F4T_VALUE .And. F4T_PRREVV < (F4T_INCOST + F4T_AMPLIA) )
	If F4T->(F4T_INCOST + F4T_AMPLIA) < F4T->F4T_VALUE
		aRet[04]	:= F4T->(F4T_INCOST + F4T_AMPLIA)
	Else
		aRet[04]	:= F4T->F4T_VALUE
	EndIf
	aRet[04]		-= F4T->F4T_PRREVV
EndIf

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T04T

Test cases for revaluation scenario

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		18/09/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
User Function RU01T04T()
Local cMsg			AS CHARACTER
Local lRet			AS LOGICAL
Local aReg1			AS ARRAY
Local aReg2			AS ARRAY
Local aExpecCost	AS ARRAY
Local aExpecDepr	AS ARRAY
Local aScenario		AS ARRAY

lRet		:= .T.
aScenario	:= {}

aReg1		:= {0 /* N3_VORIG1 */, 0 /* N3_INCOST */, 0 /* N3_ACRVDEP */, 0 /* N3_PRREVVL */, 0 /* N3_VRDACM1 */, 0 /* N3_PRACDEP */}
aReg2		:= {0 /* N3_VORIG1 */, 0 /* N3_INCOST */, 0 /* N3_ACRVDEP */, 0 /* N3_PRREVVL */, 0 /* N3_VRDACM1 */, 0 /* N3_PRACDEP */}
aExpecCost	:= {0 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 0 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {0 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 0 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 001", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {10000 /* N3_VORIG1 */, 10000 /* N3_INCOST */, 0 /* N3_ACRVDEP */, 0 /* N3_PRREVVL */, 300 /* N3_VRDACM1 */, 0 /* N3_PRACDEP */}
aReg2		:= {12000 /* N3_VORIG1 */, 11000 /* N3_INCOST */, 27.27 /* N3_ACRVDEP */, 11000 /* N3_PRREVVL */, 327.27 /* N3_VRDACM1 */, 300 /* N3_PRACDEP */}
aExpecCost	:= {1000 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 0 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {27.27 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 0 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 002", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {15000 /* N3_VORIG1 */, 15000 /* N3_INCOST */, 0 /* N3_ACRVDEP */, 0 /* N3_PRREVVL */, 600 /* N3_VRDACM1 */, 0 /* N3_PRACDEP */}
aReg2		:= {25000 /* N3_VORIG1 */, 30000 /* N3_INCOST */, -100 /* N3_ACRVDEP */, 30000 /* N3_PRREVVL */, 500 /* N3_VRDACM1 */, 600 /* N3_PRACDEP */}
aExpecCost	:= {0 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 5000 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {0 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 100 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 003", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {12000 /* N3_VORIG1 */, 11000 /* N3_INCOST */, 27.27 /* N3_ACRVDEP */, 11000 /* N3_PRREVVL */, 438.38 /* N3_VRDACM1 */, 300 /* N3_PRACDEP */}
aReg2		:= {10000 /* N3_VORIG1 */, 11000 /* N3_INCOST */, 45.79 /* N3_ACRVDEP */, 12000 /* N3_PRREVVL */, 365.32 /* N3_VRDACM1 */, 438.38 /* N3_PRACDEP */}
aExpecCost	:= {0 /* Profit credit (01-83) */, 1000 /* Profit debit (83-01) */, 1000 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {0 /* Profit credit (83-02) */, 27.27 /* Profit debit (02-83) */, 45.79 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 004", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {25000 /* N3_VORIG1 */, 30000 /* N3_INCOST */, -100 /* N3_ACRVDEP */, 30000 /* N3_PRREVVL */, 750 /* N3_VRDACM1 */, 600 /* N3_PRACDEP */}
aReg2		:= {40000 /* N3_VORIG1 */, 30000 /* N3_INCOST */, 550 /* N3_ACRVDEP */, 25000 /* N3_PRREVVL */, 1200 /* N3_VRDACM1 */, 750 /* N3_PRACDEP */}
aExpecCost	:= {10000 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 0 /* Loss credit (91-01) */, 5000 /* Loss debit (01-91) */}
aExpecDepr	:= {350 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 0 /* Loss credit (02-91) */, 100 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 005", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {1000000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 0 /* N3_ACRVDEP */, 0 /* N3_PRREVVL */, 100000 /* N3_VRDACM1 */, 0 /* N3_PRACDEP */}
aReg2		:= {680000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 32000 /* N3_ACRVDEP */, 1000000 /* N3_PRREVVL */, 68000 /* N3_VRDACM1 */, 100000 /* N3_PRACDEP */}
aExpecCost	:= {0 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 320000 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {0 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 32000 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 006", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {680000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 32000 /* N3_ACRVDEP */, 1000000 /* N3_PRREVVL */, 204000 /* N3_VRDACM1 */, 100000 /* N3_PRACDEP */}
aReg2		:= {510000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 83000 /* N3_ACRVDEP */, 680000 /* N3_PRREVVL */, 153000 /* N3_VRDACM1 */, 204000 /* N3_PRACDEP */}
aExpecCost	:= {0 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 170000 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {0 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 51000 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 007", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {510000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 83000 /* N3_ACRVDEP */, 680000 /* N3_PRREVVL */, 204000 /* N3_VRDACM1 */, 204000 /* N3_PRACDEP */}
aReg2		:= {1200000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 193000 /* N3_ACRVDEP */, 510000 /* N3_PRREVVL */, 480000 /* N3_VRDACM1 */, 204000 /* N3_PRACDEP */}
aExpecCost	:= {200000 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 0 /* Loss credit (91-01) */, 490000 /* Loss debit (01-91) */}
aExpecDepr	:= {193000 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 0 /* Loss credit (02-91) */, 83000 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 008", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {1200000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 19300 /* N3_ACRVDEP */, 510000 /* N3_PRREVVL */, 72000 /* N3_VRDACM1 */, 20400 /* N3_PRACDEP */}
aReg2		:= {1800000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 55300 /* N3_ACRVDEP */, 1200000 /* N3_PRREVVL */, 108000 /* N3_VRDACM1 */, 72000 /* N3_PRACDEP */}
aExpecCost	:= {600000 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 0 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {36000 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 0 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 009", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {1800000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 55300 /* N3_ACRVDEP */, 1200000 /* N3_PRREVVL */, 126000 /* N3_VRDACM1 */, 72000 /* N3_PRACDEP */}
aReg2		:= {900000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 7700 /* N3_ACRVDEP */, 1800000 /* N3_PRREVVL */, 63000 /* N3_VRDACM1 */, 126000 /* N3_PRACDEP */}
aExpecCost	:= {0 /* Profit credit (01-83) */, 800000 /* Profit debit (83-01) */, 100000 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {0 /* Profit credit (83-02) */, 55300 /* Profit debit (02-83) */, 7700 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 010", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {900000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 7700 /* N3_ACRVDEP */, 1800000 /* N3_PRREVVL */, 72000 /* N3_VRDACM1 */, 126000 /* N3_PRACDEP */}
aReg2		:= {1000000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 300 /* N3_ACRVDEP */, 900000 /* N3_PRREVVL */, 80000 /* N3_VRDACM1 */, 72000 /* N3_PRACDEP */}
aExpecCost	:= {0 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 0 /* Loss credit (91-01) */, 100000 /* Loss debit (01-91) */}
aExpecDepr	:= {300 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 0 /* Loss credit (02-91) */, 7700 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 011", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {1000000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 0 /* N3_ACRVDEP */, 0 /* N3_PRREVVL */, 100000 /* N3_VRDACM1 */, 0 /* N3_PRACDEP */}
aReg2		:= {1200000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 20000 /* N3_ACRVDEP */, 1000000 /* N3_PRREVVL */, 120000 /* N3_VRDACM1 */, 100000 /* N3_PRACDEP */}
aExpecCost	:= {200000 /* Profit credit (01-83) */, 0 /* Profit debit (83-01) */, 0 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {20000 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 0 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 012", aReg1, aReg2, aExpecCost, aExpecDepr})

aReg1		:= {1200000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 20000 /* N3_ACRVDEP */, 1000000 /* N3_PRREVVL */, 240000 /* N3_VRDACM1 */, 100000 /* N3_PRACDEP */}
aReg2		:= {1100000 /* N3_VORIG1 */, 1000000 /* N3_INCOST */, 0 /* N3_ACRVDEP */, 1200000 /* N3_PRREVVL */, 220000 /* N3_VRDACM1 */, 240000 /* N3_PRACDEP */}
aExpecCost	:= {0 /* Profit credit (01-83) */, 100000 /* Profit debit (83-01) */, 0 /* Loss credit (91-01) */, 0 /* Loss debit (01-91) */}
aExpecDepr	:= {0 /* Profit credit (83-02) */, 0 /* Profit debit (02-83) */, 0 /* Loss credit (02-91) */, 0 /* Loss debit (91-02) */}
aAdd(aScenario, {"CASE 013", aReg1, aReg2, aExpecCost, aExpecDepr})

RpcSetType(3)
RpcSetEnv("T1", "M RU01",,,"ATF")

cMsg		:= TestCrReg(aScenario)

RpcClearEnv()

lRet		:= Empty(cMsg)
Conout("RU01T04T Test result:")
If lRet
	Conout("All ok")
Else
	Conout(cMsg)
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} TestCrReg

Process proposed test scenarios

@param		ARRAY aScenario
@return		CHARACTER cMsg
@author 	victor.rezende
@since 		18/09/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function TestCrReg(aScenario)
Local cMsg		AS CHARACTER
Local nX		AS NUMERIC
Local nOldRec	AS NUMERIC
Local nNewRec	AS NUMERIC
Local lRet		AS LOGICAL
Local aCost		AS ARRAY
Local aDepr		AS ARRAY

lRet		:= .T.

RecLock("SN3", .T.)
SN3->N3_FILIAL		:= PADR("X", Len(SN3->N3_FILIAL), "X")
SN3->N3_CBASE		:= "CT001"
SN3->N3_ITEM		:= "ZZ"
SN3->N3_TIPO		:= "16"
SN3->N3_SEQREAV		:= "01"
SN3->N3_BAIXA		:= "1"
SN3->(MsUnLock())
nOldRec	:= SN3->(Recno())

RecLock("SN3", .T.)
SN3->N3_FILIAL		:= PADR("X", Len(SN3->N3_FILIAL), "X")
SN3->N3_CBASE		:= "CT001"
SN3->N3_ITEM		:= "ZZ"
SN3->N3_TIPO		:= "16"
SN3->N3_SEQREAV		:= "02"
SN3->N3_BAIXA		:= "0"
SN3->(MsUnLock())
nNewRec	:= SN3->(Recno())

cMsg	:= ""
For nX := 1 To Len(aScenario)
	SN3->(dbGoTo(nOldRec))
	RecLock("SN3", .F.)
	SN3->N3_VORIG1	:= aScenario[nX,02,01]
	SN3->N3_INCOST	:= aScenario[nX,02,02]
	SN3->N3_ACRVDEP	:= aScenario[nX,02,03]
	SN3->N3_PRREVVL	:= aScenario[nX,02,04]
	SN3->N3_VRDACM1	:= aScenario[nX,02,05]
	SN3->N3_PRACDEP	:= aScenario[nX,02,06]
	SN3->(MsUnLock())
	SN3->(dbGoTo(nNewRec))
	RecLock("SN3", .F.)
	SN3->N3_VORIG1	:= aScenario[nX,03,01]
	SN3->N3_INCOST	:= aScenario[nX,03,02]
	SN3->N3_ACRVDEP	:= aScenario[nX,03,03]
	SN3->N3_PRREVVL	:= aScenario[nX,03,04]
	SN3->N3_VRDACM1	:= aScenario[nX,03,05]
	SN3->N3_PRACDEP	:= aScenario[nX,03,06]
	SN3->(MsUnLock())
	
	SN3->(dbGoTo(nNewRec))
	aCost	:= RU01T04_03DiffCost()
	
	SN3->(dbGoTo(nNewRec))
	aDepr	:= RU01T04_02DiffVarDepr()
	
	cMsg	+= IIf(aScenario[nX,04,01] <> aCost[01], CRLF + aScenario[nX,01] + "-COST-1 Expected("+AllTrim(Str(aScenario[nX,04,01]))+") Result("+AllTrim(Str(aCost[01]))+")", "")
	cMsg	+= IIf(aScenario[nX,04,02] <> aCost[02], CRLF + aScenario[nX,01] + "-COST-2 Expected("+AllTrim(Str(aScenario[nX,04,02]))+") Result("+AllTrim(Str(aCost[02]))+")", "")
	cMsg	+= IIf(aScenario[nX,04,03] <> aCost[03], CRLF + aScenario[nX,01] + "-COST-3 Expected("+AllTrim(Str(aScenario[nX,04,03]))+") Result("+AllTrim(Str(aCost[03]))+")", "")
	cMsg	+= IIf(aScenario[nX,04,04] <> aCost[04], CRLF + aScenario[nX,01] + "-COST-4 Expected("+AllTrim(Str(aScenario[nX,04,04]))+") Result("+AllTrim(Str(aCost[04]))+")", "")
	cMsg	+= IIf(aScenario[nX,05,01] <> aDepr[01], CRLF + aScenario[nX,01] + "-DEPR-1 Expected("+AllTrim(Str(aScenario[nX,05,01]))+") Result("+AllTrim(Str(aDepr[01]))+")", "")
	cMsg	+= IIf(aScenario[nX,05,02] <> aDepr[02], CRLF + aScenario[nX,01] + "-DEPR-2 Expected("+AllTrim(Str(aScenario[nX,05,02]))+") Result("+AllTrim(Str(aDepr[02]))+")", "")
	cMsg	+= IIf(aScenario[nX,05,03] <> aDepr[03], CRLF + aScenario[nX,01] + "-DEPR-3 Expected("+AllTrim(Str(aScenario[nX,05,03]))+") Result("+AllTrim(Str(aDepr[03]))+")", "")
	cMsg	+= IIf(aScenario[nX,05,04] <> aDepr[04], CRLF + aScenario[nX,01] + "-DEPR-4 Expected("+AllTrim(Str(aScenario[nX,05,04]))+") Result("+AllTrim(Str(aDepr[04]))+")", "")
Next nX

SN3->(dbGoTo(nOldRec))
RecLock("SN3", .F.)
SN3->(dbDelete())
SN3->(MsUnLock())

SN3->(dbGoTo(nNewRec))
RecLock("SN3", .F.)
SN3->(dbDelete())
SN3->(MsUnLock())

Return cMsg

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetNextN3Seq

Get next N3_SEQ for currently positioned fixed asset

@param		CHARACTER cType - N3_TIPO
@param		CHARACTER cTpSaldo - N3_TPSALDO
@return		CHARACTER nSeq
@author 	victor.rezende
@since 		18/09/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function GetNextN3Seq(cType AS CHARACTER, cTpSaldo AS CHARACTER)
Local cQuery	AS CHARACTER
Local cSeq		AS CHARACTER
Local cAliasTrb	AS CHARACTER

cQuery		:= " SELECT COALESCE(MAX(N3_SEQ),'"+PADR("0", GetSX3Cache("N3_SEQ", "X3_TAMANHO"), "0")+"') AS N3_SEQ "
cQuery		+= "   FROM " + RetSqlName("SN3")
cQuery		+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery		+= "    AND N3_FILIAL = '"+xFilial("SN3")+"' "
cQuery		+= "    AND N3_CBASE = '"+SN3->N3_CBASE+"' "
/*
cQuery		+= "    and n3_item = '"+SN3->N3_ITEM+"' "
cQuery		+= "    and n3_tipo = '"+cType+"' "
cQuery		+= "    and n3_tpsaldo = '"+cTpSaldo+"' "
*/
cQuery		:= ChangeQuery(cQuery)
cAliasTrb	:= CriaTrab(Nil, .F.)
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasTrb )
cSeq	:= Soma1(AllTrim((cAliasTrb)->n3_seq))
(cAliasTrb)->(dbCloseArea())

Return cSeq

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03VIE

View function

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	alexandra.menyashina
@since 		16/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04VIE(oModel AS OBJECT)
Local lRet      AS LOGICAL
lRet    := .T.

If lRet .And. ValType("oModel") <> "O"
    oModel      := FWLoadModel("RU01T04")
    oModel:SetOperation(MODEL_OPERATION_VIEW)
    oModel:Activate()
EndIf

If lRet
    dbSelectArea("F4S")
    FWExecView(STR0001, "RU01T04", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Reevaluation"
EndIf

Return lRet

/*/{Protheus.doc} RU01T04PRT

Print

@return		Nil
@author 	Alexandra Menyashina
@since 		28/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04PRT(oStruF4S AS object, oStruF4T AS object)
Local oReport	AS OBJECT
Local cName		AS CHARACTER

cName	:= 'RU01T04'
oReport := ReportDef(cName, oStruF4S, oStruF4T)
oReport:PrintDialog()

return Nil

/*/{Protheus.doc} RU0103RReportDefDef

Print report definition

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		28/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ReportDef(cName as CHARACTER, oStruF4S AS object, oStruF4T AS object)
Local oReport	    AS OBJECT
Local oSecF4S	    AS OBJECT
Local oSecF4T	    AS OBJECT
Local oStruSN3		AS OBJECT
Local nX		    AS NUMERIC
Local cViewFldN3	AS CHARACTER

cViewFldN3    := 'N3_CBASE|N3_ITEM|N3_TIPO'
oStruSN3	:= FWFormStruct(2, "SN3", {|x| AllTrim(x) $ cViewFldN3})

oReport := TReport():New(cName/*cReport*/,STR0001/*cTitle*/,cName,{|oReport| ReportPrint(oReport, oStruF4S, oStruF4T, oStruSN3)},"PRINT", .F./*<lLandscape>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<cPageTText>*/ , .F./*<lPageTInLine>*/ , .F./*<lTPageBreak>*/ , /*<nColSpace>*/ )

oReport:lParamPage	:= .F.	//Don't print patameter page
//Header info
oSecF4S := TRSection():New(oReport,"",{'F4S'} , , .F., .T.)
For nX := 1 To Len(oStruF4S:aFields)
	If ! oStruF4S:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4S,oStruF4S:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"F4S", AllTrim(oStruF4S:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX
//Detail info
oSecF4T := TRSection():New(oReport,"",{'F4T'} , , .F., .T.)

For nX := 1 To Len(oStruSN3:aFields)
	If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4T,oStruSN3:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"SN3", alltrim(oStruSN3:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX

For nX := 1 To Len(oStruF4T:aFields)
	If ! oStruF4T:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4T,oStruF4T:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"F4T", alltrim(oStruF4T:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX

Return oReport

/*/{Protheus.doc} ReportPrint

Print prepare data

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		28/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ReportPrint(oReport, oStruF4S AS object, oStruF4T AS object, oStruSN3 AS object)
Local oSecF4S 		AS OBJECT
Local oSecF4T		AS OBJECT
Local cAliasQry		AS CHARACTER
Local cQuery		AS CHARACTER
Local cLot		    AS CHARACTER
Local cViewFldN3	AS CHARACTER
local lRet			AS LOGICAL
Local nX			AS NUMERIC
Local xValor

oSecF4S		:= oReport:Section(1)
oSecF4T		:= oReport:Section(2)
cAliasQry	:= GetNextAlias()
cQuery		:= ""
lRet		:= .T.

If oReport:Cancel()
	Return .T.
EndIf

cLot:= F4S->F4S_LOT
oSecF4S:Init()
oReport:IncMeter()

dbSelectArea('F4S')
F4S->(DBSeek( xFilial('F4S') + cLot))

For nX := 1 To Len(oStruF4S:aFields)
	If ! oStruF4S:aFields[nX, MVC_VIEW_VIRTUAL]
		If GetSx3Cache(oStruF4S:aFields[nX, MVC_VIEW_IDFIELD],'X3_TIPO') == 'D'
			xValor := F4S->&(oStruF4S:aFields[nX, MVC_VIEW_IDFIELD])
			xValor := StrTran(DTOC(xValor), "/", ".")
			oSecF4S:Cell(oStruF4S:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(xValor)
		Else
			oSecF4S:Cell(oStruF4S:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(F4S->&(oStruF4S:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	EndIf
Next nX		
oSecF4S:Printline()

oSecF4T:init()

cQuery	:= " SELECT  F4T.R_E_C_N_O_ F4TRECNO "

For nX := 1 To Len(oStruSN3:aFields)
	If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
		cQuery  += "," + oStruSN3:aFields[nX, MVC_VIEW_IDFIELD]
	EndIf
Next nX

For nX := 1 To Len(oStruF4T:aFields)
	If ! oStruF4T:aFields[nX, MVC_VIEW_VIRTUAL]
		cQuery  += "," + oStruF4T:aFields[nX, MVC_VIEW_IDFIELD]
	EndIf
Next nX

cQuery	+= " FROM "+RetSqlName("F4T")+" F4T "
cQuery	+= " JOIN "+RetSqlName("SN3")+" SN3 "
cQuery	+= " ON SN3.N3_UUID = F4T.F4T_SN3 "
cQuery	+= " WHERE F4T.D_E_L_E_T_ = ' '"
cQuery	+= " AND SN3.D_E_L_E_T_ = ' '"
cQuery	+= " AND N3_FILIAL = '" + xFilial("SN3") + "'"
cQuery	+= " AND F4T_FILIAL = '" + xFilial("F4T") + "'"
cQuery	+= " AND F4T_LOT = '" + cLot + "'"

cQuery:=ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

DbSelectArea(cAliasQry)
cAliasQry->(DbGoTop())

While (cAliasQry)->(!EOF())
    For nX := 1 To Len(oStruSN3:aFields)
		If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
			oSecF4T:Cell(oStruSN3:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)->&(oStruSN3:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	Next nX
	For nX := 1 To Len(oStruF4T:aFields)
		If ! oStruF4T:aFields[nX, MVC_VIEW_VIRTUAL]
			oSecF4T:Cell(oStruF4T:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)->&(oStruF4T:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	Next nX
	oSecF4T:Printline()
	(cAliasQry)->(dbSkip())
EndDo
oSecF4T:Finish()
//Separator
oReport:ThinLine()
oSecF4S:Finish()
Return(NIL)

/*/{Protheus.doc} RU01T04004_CheckPreviousReevalValue

Function returns value of F4T Field in former reevaluation if it was or 0

@param		Character   cSN3UID     UID of current SN3
    		Character   cFieldRet   name of field which value sould to be return
@return		Numeric     nRet        Value of cFieldRet in former reevaluation if it was or 0
@author 	Alexandra Velmozhnaya
@since 		02/04/2019
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T04004_CheckPreviousReevalValue(cSN3UID, cFieldRet)
Local nRet      as Numeric
Local cQuery    as Character
Local cAliasQry	as Character

cAliasQry	:= GetNextAlias()
nRet        := 0

cQuery	:= " SELECT  F4T." + cFieldRet + " "+cFieldRet+ ", MAX(F4S_DATE)"

cQuery	+= " FROM "+RetSqlName("F4T")+" F4T "
cQuery	+= " JOIN "+RetSqlName("SN3")+" SN3 "
cQuery	+= " ON SN3.N3_UUID = F4T.F4T_SN3 "
cQuery	+= " JOIN "+RetSqlName("F4S")+" F4S "
cQuery	+= " ON F4S.F4S_LOT = F4T.F4T_LOT "
cQuery	+= " WHERE F4T.D_E_L_E_T_ = ' '"
cQuery	+= " AND SN3.D_E_L_E_T_ = ' '"
cQuery	+= " AND F4S.D_E_L_E_T_ = ' '"
cQuery	+= " AND F4T.F4T_STATUS <> '"+F4T_STATUS_STORNOED +" '"
cQuery	+= " AND N3_FILIAL = '" + xFilial("SN3") + "'"
cQuery	+= " AND F4T_FILIAL = '" + xFilial("F4T") + "'"
cQuery	+= " AND F4S_FILIAL = '" + xFilial("F4S") + "'"
cQuery	+= " AND F4S_DATE < '" + DToS(dDataBase) + "'"
cQuery  += " GROUP BY F4T."+cFieldRet 

cQuery:=ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())
If (cAliasQry)->(!EOF())
    nRet := (cAliasQry)->(&cFieldRet)
EndIf
(cAliasQry)->(dbCloseArea())
Return nRet