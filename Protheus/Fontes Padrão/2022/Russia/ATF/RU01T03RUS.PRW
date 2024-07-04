#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01T03RUS.CH'

#define F4U_OPER_EXECUTION          "1"
#define F4U_OPER_STORNO             "2"
#define F4V_STATUS_NOT_CONFIRMED    "0"
#define F4V_STATUS_CONFIRMED        "1"
#define F4V_STATUS_STORNOED         "2"
#define SN3_OPER_IN_OPERATION       "1"
#define SN3_OPER_NOT_IN_OPERATION   "2"
#define SN3_BAIXA_WRITTEN_OFF       "1"
#define SN1_STATUS_ACTIVE           "1"
#define SN1_STATUS_INACTIVE         "0"

#define RU01T03_OPER_MODERNIZATION  1
#define RU01T03_OPER_STORNO         2

#define SN4_STATUS_NOT_STORNO		"0"
#define SN4_STATUS_STORNO			"1"
//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03RUS

Fixed assets modernization

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T03RUS()
Local lRet			AS LOGICAL
Private oBrowse		AS OBJECT
Private cCadastro	AS CHARACTER
Private aEnableButtons AS ARRAY

lRet		:= .T.
cCadastro	:= STR0001	//"Modernization"

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
dbSelectArea("F4V")
dbSetOrder(1)	//F4V_FILIAL+F4V_LOT+F4V_ITEM
dbSelectArea("F4U")
dbSetOrder(1)	//F4U_FILIAL+F4U_LOT

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
oBrowse:SetDescription(STR0001) //"Modernization"
oBrowse:SetAlias("F4U")
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
aAdd(aRotina, {STR0001, "RU01T03INC()",                 0, 3, 0, Nil, Nil, Nil}) //"Modernization"
aAdd(aRotina, {STR0002, "RU01T03VIE",		            0, 2, 0, Nil, Nil, Nil}) //"View"
aAdd(aRotina, {STR0003, "RU01T03STO()",                 0, 5, 0, Nil, Nil, Nil}) //"Storno"
aAdd(aRotina, {STR0004, "RU01S02RUS('F4U','F4V',1,1)",  0, 2, 0, Nil, Nil, Nil}) //"Accounting Tracker"
aAdd(aRotina, {STR0005, "RU01T03FIL",                   0, 2, 0, Nil, Nil, Nil}) //"Filter Related Lots"
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03FIL

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
Function RU01T03FIL()
Local cQuery    AS CHARACTER
Local cAliasTrb AS CHARACTER
Local cKeys     AS CHARACTER
cQuery      := "   SELECT F4V_LOT, F4V_F4VLOT "
cQuery      += "     FROM "+RetSqlName("F4V")+" F4V "
cQuery      += "    WHERE F4V.D_E_L_E_T_ = ' ' "
cQuery      += "      AND F4V_FILIAL = '"+xFilial("F4V")+"' "
cQuery      += "      AND (F4V_F4VLOT = '"+F4U->F4U_LOT+"' OR F4V_LOT = '"+F4U->F4U_LOT+"') "
cQuery      += " GROUP BY F4V_LOT, F4V_F4VLOT "
cQuery      := ChangeQuery(cQuery)
cAliasTrb   := RU01GETALS(cQuery)
cKeys       := ""
While (cAliasTrb)->(! EOF())
	cKeys   += "|" + (cAliasTrb)->F4V_LOT
	If ! Empty((cAliasTrb)->F4V_F4VLOT)
		cKeys   += "|" + (cAliasTrb)->F4V_F4VLOT
	EndIf
	(cAliasTrb)->(dbSkip())
EndDo
(cAliasTrb)->(dbCloseArea())

oBrowse:AddFilter(STR0027 + F4U->F4U_LOT /* cFilter */, "F4U_LOT$'" + cKeys + "'" /* cExpAdvPL */, Nil /* [ lNoCheck ] */, .T. /* [ lSelected ] */, Nil /* [ cAlias ] */, Nil /* [ lFilterAsk ] */, /* [ aFilParser ] */, /* [ cID ] */)  // "Related journals"
oBrowse:GoTop()

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03INC

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
Function RU01T03INC(oModel AS OBJECT)
Local nX            AS NUMERIC
Local cQuery        AS CHARACTER
Local cField        AS CHARACTER
Local cAtfCurr      AS CHARACTER
Local lLoadData     AS LOGICAL
Local lRet          AS LOGICAL
Local dLastDep      AS DATE
Local aF4VField     AS ARRAY
Local aIgnoreFld    AS ARRAY
Local bPadField     AS BLOCK
Local oModelGrd     AS OBJECT
Local oStruF4V      AS OBJECT

bPadField   := {|cStr, cField| PADR(cStr, GetSX3Cache(cField, "X3_TAMANHO"))}
lRet        := .T.

// Must be executed after last monthly calculation
If lRet
	dLastDep	:= SuperGetMV("MV_ULTDEPR", .F.)
	lRet        := dDataBase > dLastDep
	If ! lRet
		Help("",1,"RU01T03DATE",,STR0031,1,0)	// "Modernization cannot be execute before last monthly calculation"
	EndIf
EndIf

// Prepare oModel
lLoadData   := .F.
If lRet .And. ValType(oModel) <> "O"
	oModel      := FWLoadModel("RU01T03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	lLoadData   := .T.
EndIf

// Ask user about parameters
If lRet .And. lLoadData
	lRet        := Pergunte("ATFA012PUT", !IsBlind())
EndIf

// Continue with data fetching if required
If lRet .And. lLoadData
	cAtfCurr    := GetNewPar("MV_ATFMOED", "")
	oModel:Activate()
	oModel:GetModel("F4UMASTER"):SetValue("F4U_DESCR", STR0010) //"Execution of modernization"
	
	oModelGrd   := oModel:GetModel("F4VDETAIL")
	oStruF4V    := oModelGrd:GetStruct()
	aF4VField   := oStruF4V:GetFields()
	cQuery      := " SELECT SN3.R_E_C_N_O_ AS POSRECNO "
	For nX := 1 To Len(aF4VField)
		cField  := AllTrim(aF4VField[nX, MODEL_FIELD_IDFIELD])
		If cField $ "F4V_SN3"
			cQuery  += " , SN3.N3_UUID AS " + cField
		ElseIf cField $ "F4V_VORIG"
			cQuery  += " , SN3.N3_VORIG"+cAtfCurr+" AS " + cField
		ElseIf cField $ "F4V_AMPLIA"
			cQuery  += " , SN3.N3_AMPLIA"+cAtfCurr+" AS " + cField
		ElseIf cField $ "F4V_PERDEP"
			cQuery  += " , SN3.N3_PERDEPR AS " + cField
		ElseIf cField $ "F4V_FILIAL|F4V_LOT|F4V_ITEM|F4V_STATUS|F4V_F4VLOT|F4V_F4VITE|F4V_LA|F4V_VALUE|F4V_INCPER"
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
	cQuery  += "  AND N3_TIPO IN ('01','"+AtfNValMod({1,2,3},"','")+"') " // Tax + Managerial types
	cQuery  += "  AND N1_CBASE BETWEEN '"+Eval(bPadField, MV_PAR01, "N1_CBASE")+"' AND '"+Eval(bPadField, MV_PAR02, "N1_CBASE")+"' "
	cQuery  += "  AND N3_TIPO BETWEEN '"+Eval(bPadField, MV_PAR03, "N3_TIPO")+"' AND '"+Eval(bPadField, MV_PAR04, "N3_TIPO")+"' "
	cQuery  += "  AND N1_GRUPO BETWEEN '"+Eval(bPadField, MV_PAR05, "N1_GRUPO")+"' AND '"+Eval(bPadField, MV_PAR06, "N1_GRUPO")+"' "
	cQuery  += "  AND N3_AQUISIC BETWEEN '"+DToS(MV_PAR07)+"' AND '"+DToS(MV_PAR08)+"' "
	cQuery  += "  AND NOT EXISTS "
	cQuery  += "      ( "
	cQuery  += "          SELECT 1 "
	cQuery  += "            FROM "+RetSqlName("SN4")+" SN4 "
	cQuery	+= " 		  JOIN "+RetSqlName("F4V")+" F4V ON F4V_SN4UID = N4_UID"
	cQuery	+= "		  JOIN "+RetSqlName("F4U")+" F4U ON F4U_LOT = F4V_LOT"
	cQuery  += "           WHERE N4_CBASE = N3_CBASE "
	cQuery  += "             AND N4_ITEM = N3_ITEM "
	cQuery  += "             AND N4_TIPO = N3_TIPO "
	cQuery  += "             AND N4_SEQ = N3_SEQ "
	cQuery  += "             AND SN4.D_E_L_E_T_ = ' ' "
	cQuery  += "             AND F4V.D_E_L_E_T_ = ' ' "
	cQuery  += "             AND F4U.D_E_L_E_T_ = ' ' "
	cQuery  += "             AND N4_FILIAL = '"+xFilial("SN4")+"' "
	cQuery  += "             AND N4_FILIAL = '"+xFilial("F4U")+"' "
	cQuery  += "             AND N4_FILIAL = '"+xFilial("F4V")+"' "
	cQuery  += "             AND N4_OCORR <> '05' "
	cQuery  += "             AND N4_DATA >= '"+DToS(dDataBase)+"' "
	cQuery	+= "             AND ( "
	cQuery	+= "                      (N4_DATA > '"+DToS(dDataBase)+"' "
	cQuery	+= "						AND N4_STORNO = '"+SN4_STATUS_NOT_STORNO +"' "
	cQuery	+= "						AND F4U_OPER = '"+F4U_OPER_EXECUTION+"' ) "
	cQuery	+= "                   OR ( "
	cQuery	+= "                            N4_DATA = '"+DToS(dDataBase)+"' "
	cQuery	+= "                        AND N4_OCORR NOT IN ( "
	cQuery	+= "                              '05','07','08','10','11', "
	cQuery	+= "                              '06','12','17','18','20','62' "
	cQuery	+= "                            ) "
	cQuery	+= "                      ) "
	cQuery	+= "                 ) "
	cQuery  += "      ) "
	cQuery  += " ORDER BY N3_CBASE, N3_ITEM, N3_TIPO, N3_SEQ "
	cQuery  := ChangeQuery(cQuery)
	
	// Insert query results into model
	oModelGrd:SetNoInsertLine(.F.)
	aIgnoreFld  := {}
	aAdd(aIgnoreFld, "F4V_FILIAL")
	aAdd(aIgnoreFld, "F4V_LOT")
	aAdd(aIgnoreFld, "F4V_ITEM")
	aAdd(aIgnoreFld, "F4V_STATUS")
	aAdd(aIgnoreFld, "F4V_F4VLOT")
	aAdd(aIgnoreFld, "F4V_F4VITE")
	aAdd(aIgnoreFld, "F4V_LA")
	aAdd(aIgnoreFld, "MVC_OK")
	aAdd(aIgnoreFld, "F4V_HIST")
	aAdd(aIgnoreFld, "F4V_VALUE")
	aAdd(aIgnoreFld, "F4V_INCPER")
	aAdd(aIgnoreFld, "F4V_SN4REC")
	aAdd(aIgnoreFld, "F4V_MANAGP")
	aAdd(aIgnoreFld, "F4V_VN3BAS")
	aAdd(aIgnoreFld, "F4V_VN3TIP")
	aAdd(aIgnoreFld, "F4V_VN3ITE")
	aAdd(aIgnoreFld, "F4V_VN3HIS")
	aAdd(aIgnoreFld, "F4V_UID")
	aAdd(aIgnoreFld, "F4V_SN4UID")
	lRet    := RU01QRY2MD( ;
		cQuery, ;
		oModelGrd, ;
		.T. /* lGrid */, ;
		.F. /* lAddFirstLine */, ;
		aIgnoreFld /* aIgnoreFld */, ;
		{|oMdl| ProcGridInsert(oMdl)} /* bPosInsert */, ;
		.T. /* lInitPad */, ;
		"F4V_ITEM" /* cIncField */, ;
		{"SN3", "POSRECNO"})
	oModelGrd:SetNoInsertLine(.T.)
EndIf

// Execute MVC View
If lRet
	dbSelectArea("F4U")
	FWExecView(STR0001, "RU01T03", MODEL_OPERATION_INSERT, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Modernization"
EndIf

Return lRet

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
Function RU01T03STO(oModel AS OBJECT)
Local lRet      AS LOGICAL
Local dLastDep  AS DATE
Local oModel    AS OBJECT

lRet        := .T.

// Currently selected lot register must be of type execution
If lRet
	lRet    := F4U->F4U_OPER == F4U_OPER_EXECUTION
	If ! lRet
		Help("",1,"RU01T03STVL01",,STR0016,1,0)	//"Currently selected lot register must be of type execution"
	EndIf
EndIf

// Current date more then last monthly calculation
If lRet
	dLastDep	:= SuperGetMV("MV_ULTDEPR", .F.)
	lRet        := dDataBase >= dLastDep
	If ! lRet
		Help("",1,"RU01T03DATE",,STR0009,1,0)	// "Modernization should be performed on the date of the last amortization calculation"
	EndIf
EndIf

// Current month must be the same month of the modernization
If lRet
	lRet        := ; 
		Day(dDatabase)	>= Day(F4U->F4U_DATE) .And. ;
		Month(dDataBase) == Month(F4U->F4U_DATE) .And. ;
		Year(dDataBase) == Year(F4U->F4U_DATE)
	If ! lRet
		Help("",1,"RU01T03STVL03",,STR0018,1,0)	//"Storno of modernization must be performed on the same month of the original transaction"
	EndIf
EndIf

// Prepare oModel
If lRet .And. ValType(oModel) <> "O"
	oModel      := FWLoadModel("RU01T03")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	ProcGridInsert(oModel:GetModel("F4VDETAIL"))
EndIf

// Execute MVC View
If lRet
	dbSelectArea("F4U")
	FWExecView(STR0001, "RU01T03", MODEL_OPERATION_UPDATE, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Modernization"
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
Local nPerDif       AS NUMERIC
Local cHistory      AS CHARACTER
Local cManTypes     AS CHARACTER

nOper       := GetOperation()

If nOper == RU01T03_OPER_MODERNIZATION
	cManTypes   := AtfNValMod({1,2,3},"|")
	nPerDif     := 0
	If SN3->N3_TIPO $ cManTypes
		nPerDif := RU01T03_R2PreviousValues()[1]
		nPerDif += 1
	EndIf

	oModel:SetValue("F4V_MANAGP", nPerDif)
	cHistory    := STR0011
ElseIf nOper == RU01T03_OPER_STORNO
	cHistory    := STR0032
EndIf
cHistory    += Alltrim(oModel:GetValue("F4V_VN3BAS")) + "-"
cHistory    += AllTrim(oModel:GetValue("F4V_VN3ITE")) + "/"
cHistory    += AllTrim(oModel:GetValue("F4V_VN3TIP"))

If nOper == RU01T03_OPER_MODERNIZATION
	oModel:SetValue("MVC_OK", .T.)
	oModel:SetValue("F4V_HIST", cHistory)
ElseIf nOper == RU01T03_OPER_STORNO
	oModel:SetValue("MVC_STOHIS", cHistory)
EndIf
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03POS

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
Function RU01T03POS(oModel AS OBJECT)
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
oMdlExeHe   := oModel:GetModel("F4UMASTER")
oMdlExeGr   := oModel:GetModel("F4VDETAIL")
bVldLine    := {|oMdl, oMdlLine| RU01T03VLD(oMdlLine, "POSVALID", oMdl, Nil) }
nLine       := 0
nProcRec    := 0
nLineErr    := 0

If nOper == RU01T03_OPER_MODERNIZATION
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
				"F4V_ITEM",;
				StrZero(nLine, GetSX3Cache("F4V_ITEM", "X3_TAMANHO")))
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
					"F4V_ITEM",;
					StrZero(nX, GetSX3Cache("F4V_ITEM", "X3_TAMANHO")))
			If oMdlExeGr:IsDeleted()
				oMdlExeGr:UnDeleteLine()
			EndIf
		Next nX

		If ! Empty(nLineErr)
			oMdlExeGr:GoLine(nLineErr)
		EndIf
	EndIf
ElseIf nOper == RU01T03_OPER_STORNO
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
	Help("",1,"RU01T03NAN",,STR0026,1,0)	//"No valid records selected"
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03COM

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
Function RU01T03COM(oModel AS OBJECT)
Local nX        AS NUMERIC
Local nY        AS NUMERIC
Local nZ        AS NUMERIC
Local nOper     AS NUMERIC
Local nLine     AS NUMERIC
Local nCurVal   AS NUMERIC
Local nExpand   AS NUMERIC
Local nValFA    AS NUMERIC
Local nValCur   AS NUMERIC
Local nUsefLife AS NUMERIC
Local nQtyCur   AS NUMERIC
Local nAdjMangT AS NUMERIC
Local nCurPer   AS NUMERIC
Local nUpdPer   AS NUMERIC
Local nPrevTx   AS NUMERIC
Local nSN4Rec   AS NUMERIC
Local cField    AS CHARACTER
Local cJrnLot   AS CHARACTER
Local cN3UUID   AS CHARACTER
Local cFieldN3  AS CHARACTER
Local cFieldBs  AS CHARACTER
Local cAtfCur   AS CHARACTER
Local cIDMOV    AS CHARACTER
Local cOcorr    AS CHARACTER
Local cTypeDep  AS CHARACTER
Local cKeyCheck AS CHARACTER
Local cUID		AS CHARACTER
Local lRet      AS LOGICAL
Local lFoundN3  AS LOGICAL
Local aFields   AS ARRAY
Local aExecut   AS ARRAY
Local aArea     AS ARRAY
Local aAreaSN1  AS ARRAY
Local aAreaSN3  AS ARRAY
Local aAreaSN4  AS ARRAY
Local aValues   AS ARRAY
Local aPrevVal  AS ARRAY
Local aCompData AS ARRAY
Local aDifCurr  AS ARRAY
Local aF4VxSN4  AS ARRAY
Local oMdlExeHe AS OBJECT
Local oMdlExeGr AS OBJECT
Local oMdlJrSt  AS OBJECT
Local oMdlJrStH AS OBJECT
Local oMdlJrStG AS OBJECT
Local oStruct   AS OBJECT
Local oMdlAF12  AS OBJECT
Local oMdlAF12H AS OBJECT
Local oMdlAF12G AS OBJECT

aArea       := GetArea()
aAreaSN1    := SN3->(GetArea())
aAreaSN3    := SN3->(GetArea())
aAreaSN4    := SN4->(GetArea())

nOper       := GetOperation()
lRet        := .F.
oMdlExeHe   := oModel:GetModel("F4UMASTER")
oMdlExeGr   := oModel:GetModel("F4VDETAIL")
aExecut     := {}
nQtyCur		:= AtfMoedas()
cAtfCur     := GetNewPar("MV_ATFMOED", "")
nCurRate	:= Posicione("SM2", 1, DToS(dDataBase), "M2_MOEDA"+cAtfCur)

BEGIN TRANSACTION
If nOper == RU01T03_OPER_MODERNIZATION
	lRet    := .T.
	cJrnLot := oMdlExeHe:GetValue("F4U_LOT")
	If lRet
		For nX := 1 To oMdlExeGr:Length()
			oMdlExeGr:GoLine(nX)
			If ! oMdlExeGr:IsDeleted() .And. oMdlExeGr:GetValue("MVC_OK")
				lRet    := oMdlExeGr:SetValue("F4V_STATUS", F4V_STATUS_CONFIRMED)
				If ! lRet
					Help("",1,"RU01T03COCOU",,STR0024,1,0)	//"Error while updating status of journal item to confirmed"
					Exit
				EndIf
				aAdd(aExecut, {;
					oMdlExeGr:GetValue("F4V_SN3"),;
					oMdlExeGr:GetValue("F4V_VALUE"),;
					oMdlExeGr:GetValue("F4V_INCPER"),;
					oMdlExeGr:GetValue("F4V_MANAGP")})
			EndIf
		Next nX
	EndIf
	If lRet
		// Perform operation
		aF4VxSN4    := {}

		For nX := 1 To Len(aExecut)
			cN3UUID     := aExecut[nX, 01]
			nExpand     := aExecut[nX, 02]
			nUsefLife   := aExecut[nX, 03]
			nAdjMangT   := aExecut[nX, 04]

			SN1->(dbSetOrder(1))    //N1_FILIAL+N1_CBASE+N1_ITEM
			SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID
			lRet    := SN3->(dbSeek(xFilial("SN3") + cN3UUID))
			If ! lRet
				Help("",1,"RU01T03VLN31",,STR0028,1,0)	//"Error finding related FA record"
				Exit
			EndIf
			lRet    := SN1->(dbSeek(SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)))
			If ! lRet
				Help("",1,"RU01T03VLN32",,STR0028,1,0)	//"Error finding related FA record"
				Exit
			EndIf

			If AtClssVer(SN1->N1_PATRIM) .Or. Empty(SN1->N1_PATRIM)
				cTypeDep	:= "2"
			Elseif SN1->N1_PATRIM $ "CAS"
				cTypeDep	:= "E"
			Else
				cTypeDep	:= "F"
			EndIf
			nCurPer     := SN3->N3_PERDEPR
			aPrevVal    := AtfMultMoe(;
				Nil,;
				Nil,;
				{|x| SN3->&("N3_AMPLIA" + Alltrim(Str(x)) ) })
			nPrevTx		:= &(IIf(Val(cAtfCur) > 9,;
				'SN3->N3_TXDEP',;
				'SN3->N3_TXDEPR') + cAtfCur)

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
					If lRet .And. nExpand > 0
						nZ          := Val(cAtfCur)
						cFieldBs    := IIf(nZ > 9, "N3_AMPLI", "N3_AMPLIA") + AllTrim(Str(nZ))
						nCurVal     := oMdlAF12G:GetValue(cFieldBs)
						nValFA      := nCurVal + nExpand
						lRet        := lRet .And. oMdlAF12G:SetValue( cFieldBs, nValFA)
						If lRet
							For nZ := 1 To nQtyCur
								cFieldN3    := IIf(nZ > 9, "N3_AMPLI", "N3_AMPLIA") + AllTrim(Str(nZ))
								If cFieldN3 <> cFieldBs
									nValCur := Round( nValFA/ RecMoeda(dDataBase, nZ), TamSX3(cFieldN3)[2]) 
									lRet    := oMdlAF12G:SetValue( cFieldN3, nValCur)
								EndIf
							Next nZ
						EndIf
					EndIf

					If lRet .And. nUsefLife > 0
						nUpdPer := nCurPer + nUsefLife
						lRet    := lRet .And. oMdlAF12G:SetValue( "N3_PERDEPR", nUpdPer)
					EndIf

					If ! lRet
						RU01MVCERR(oMdlAF12)
					EndIf

					Exit
				EndIf
			Next nY
			If ! lFoundN3
				lRet    := .F.
				Help("",1,"RU01T03VLN33",,STR0028,1,0)	//"Error finding related FA record"
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

			// Create SN4 Entry and update FA balances
			If lRet
				SN1->(dbSetOrder(1))    //N1_FILIAL+N1_CBASE+N1_ITEM
				SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID

				For nZ := 1 To oMdlExeGr:Length()
                    oMdlExeGr:GoLine(nZ)
                    if cN3UUID ==  oMdlExeGr:GetValue("F4V_SN3")
                        cUID        := oMdlExeGr:GetValue("F4V_UID")
                        Exit
                    EndIf
                Next nZ

				cIDMOV      := ""
				cOcorr      := "62"
				aValues     := AtfMultMoe(Nil,Nil,{|x| SN3->&("N3_AMPLIA" + Alltrim(Str(x)) ) - aPrevVal[x] })
				aCompData   := ATFXCompl(;
					0 ,;
					&(IIf(Val(cAtfCur) > 9,	'SN3->N3_TXDEP','SN3->N3_TXDEPR') + cAtfCur) - nPrevTx,;
					/*cMotivo*/, /*cCodBaix*/, /*cFilOrig*/, /*cSerie*/, /*cNota*/, /*nVenda*/,	/*cLocal*/, SN3->N3_PRODMES)

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
					"RU01T03",;
					cUID)

				oMdlExeGr:GoLine(nZ)
				lRet    := oMdlExeGr:LoadValue("F4V_SN4UID", SN4->N4_UID)
				
				nSN4Rec     := SN4->(Recno())
				aAdd(aF4VxSN4, {cN3UUID, nSN4Rec})
				aDifCurr	:= AtfMultMoe(;
					Nil,;
					Nil,;
					{|x| SN4->&("N4_VLROC" + Alltrim(Str(x)) ) })
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
		Next nX
		
		oModel:Activate()
		For nX := 1 To Len(aF4VxSN4)
			lFoundN3    := .F.
			For nY := 1 To oMdlExeGr:Length()
				If  ! oMdlExeGr:IsDeleted(nY) .And. ;
					oMdlExeGr:GetValue("MVC_OK", nY) .And. ;
					oMdlExeGr:GetValue("F4V_SN3", nY) == aF4VxSN4[nX, 01]
						lFoundN3    := .T.
						oMdlExeGr:GoLine(nY)
						lRet    := oMdlExeGr:LoadValue("F4V_SN4REC", aF4VxSN4[nX, 02])
						If ! lRet
							Help("",1,"RU01T03VLN34",,STR0028,1,0)	//"Error finding related FA record"
							Exit
						EndIf
				EndIf
			Next nY
			If ! lFoundN3
				lRet    := .F.
				Help("",1,"RU01T03VLN35",,STR0028,1,0)	//"Error finding related FA record"
				Exit
			EndIf
		Next nX
	EndIf
ElseIf nOper == RU01T03_OPER_STORNO
	lRet    := .T.
	If lRet
		For nX := 1 To oMdlExeGr:Length()
			oMdlExeGr:GoLine(nX)
			If ! oMdlExeGr:IsDeleted() .And. oMdlExeGr:GetValue("MVC_OK")
				lRet    := oMdlExeGr:SetValue("F4V_STATUS", F4V_STATUS_STORNOED)
				If ! lRet
					Help("",1,"RU01T03COSTU",,STR0021,1,0)	//"Error while updating status of previous journal to stornoed"
					Exit
				EndIf
			EndIf
		Next nX
	EndIf
	If lRet
		oMdlJrSt    := FWLoadModel("RU01T03")
		oMdlJrSt:SetOperation(MODEL_OPERATION_INSERT)

		oMdlJrStH   := oMdlJrSt:GetModel("F4UMASTER")
		oMdlJrStG   := oMdlJrSt:GetModel("F4VDETAIL")
		oMdlJrSt:Activate()

		cJrnLot     := oMdlJrStH:GetValue("F4U_LOT")

		If lRet
			lRet    := lRet .And. oMdlJrStH:SetValue(;
				"F4U_OPER",;
				F4U_OPER_STORNO)
			lRet    := lRet .And. oMdlJrStH:SetValue(;
				"F4U_DESCR",;
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
							"F4V_ITEM" + ;
							"F4V_STATUS" + ;
							"F4V_F4VLOT" + ;
							"F4V_F4VITE" + ;
							"F4V_HIST"	+;
							"F4V_UID"
								Loop
					EndIf
					lRet    := lRet .And. oMdlJrStG:LoadValue(;
							cField,;
							oMdlExeGr:GetValue(cField, nX))
				Next nY

				lRet    := lRet .And. oMdlJrStG:LoadValue(;
							"F4V_ITEM",;
							StrZero(nLine, GetSX3Cache("F4V_ITEM", "X3_TAMANHO")))
				lRet    := lRet .And. oMdlJrStG:LoadValue(;
							"F4V_STATUS",;
							F4V_STATUS_CONFIRMED)
				lRet    := lRet .And. oMdlJrStG:LoadValue(;
							"F4V_F4VLOT",;
							oMdlExeGr:GetValue("F4V_LOT", nX))
				lRet    := lRet .And. oMdlJrStG:LoadValue(;
							"F4V_F4VITE",;
							oMdlExeGr:GetValue("F4V_ITEM", nX))
				lRet    := lRet .And. oMdlJrStG:LoadValue(;
							"F4V_HIST",;
							oMdlExeGr:GetValue("MVC_STOHIS", nX))
				lRet    := lRet .And. oMdlJrStG:LoadValue(;
							"F4V_UID",;
							RU01UUIDV4())
				//creation sn4 register sn4 storno current
				If lRet
					SN3->(DBSetOrder(13))
					lRet    := lRet .And. SN3->(DBSeek(xFilial("SN3") + oMdlJrStG:GetValue("F4V_SN3")))
					SN1->(DBSetOrder(1))
					lRet    := lRet .And. SN1->(dbSeek(SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)))
					If lRet
						cKeyCheck   := SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ)
						lRet	:= lRet .And. RU01STOSN4(cKeyCheck, SN1->N1_PATRIM, oMdlExeGr:GetValue("F4V_UID",nX))
						lRet:= lRet .And. oMdlJrStG:LoadValue("F4V_SN4UID", SN4->N4_UID)
					Else
						lRet    := .F.
						Help("",1,"RU01T03VLN39",,STR0028,1,0)	//"Error finding related FA record"
						Exit
					EndIf
				EndIf

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
				Help("",1,"RU01T03STNM",,STR0009,1,0)	//"Modernization storno journal is inconsistent"
			EndIf
		EndIf
	EndIf
	If lRet
		// Perform operation
		For nX := 1 To oMdlJrStG:Length()
			cN3UUID     := oMdlJrStG:GetValue("F4V_SN3", nX)
			nExpand     := oMdlJrStG:GetValue("F4V_VALUE", nX)
			nUsefLife   := oMdlJrStG:GetValue("F4V_INCPER", nX)
			nAdjMangT   := oMdlJrStG:GetValue("F4V_MANAGP", nX)

			SN1->(dbSetOrder(1))    //N1_FILIAL+N1_CBASE+N1_ITEM
			SN3->(dbSetOrder(13))   //N3_FILIAL+N3_UUID
			lRet    := SN3->(dbSeek(xFilial("SN3") + cN3UUID))
			If ! lRet
				Help("",1,"RU01T03VLN36",,STR0028,1,0)	//"Error finding related FA record"
				Exit
			EndIf
			lRet    := SN1->(dbSeek(SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)))
			If ! lRet
				Help("",1,"RU01T03VLN37",,STR0028,1,0)	//"Error finding related FA record"
				Exit
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

					If lRet .And. ! Empty(nExpand)
						nZ          := Val(cAtfCur)
						cFieldBs    := IIf(nZ > 9,;
							"N3_AMPLI",;
							"N3_AMPLIA") + AllTrim(Str(nZ))
						nCurVal     := oMdlAF12G:GetValue(cFieldBs)
						nValFA      := nCurVal - nExpand
						lRet        := lRet .And. oMdlAF12G:SetValue(;
							cFieldBs,;
							nValFA)
						If lRet
							For nZ := 1 To nQtyCur
								cFieldN3    := IIf(nZ > 9,;
									"N3_AMPLI",;
									"N3_AMPLIA") + AllTrim(Str(nZ))
								If cFieldN3 <> cFieldBs
									nValCur := Round(;
										nValFA/ RecMoeda(dDataBase, nY),;
										TamSX3(cFieldN3)[2])
									lRet    := oMdlAF12G:SetValue(;
													cFieldN3,;
													nValCur)
								EndIf
							Next nZ
						EndIf
					EndIf

					If lRet .And. nUsefLife > 0
						nCurPer := oMdlAF12G:GetValue("N3_PERDEPR")
						nUpdPer := nCurPer - nUsefLife
						lRet    := lRet .And. oMdlAF12G:SetValue(;
									"N3_PERDEPR",;
									nUpdPer)
					EndIf

					If ! lRet
						RU01MVCERR(oMdlAF12)
					EndIf

					Exit
				EndIf
			Next nY
			If ! lFoundN3
				lRet    := .F.
				Help("",1,"RU01T03VLN38",,STR0028,1,0)	//"Error finding related FA record"
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
		Next nX
		oMdlJrSt:Deactivate()
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

If lRet .And. ! Empty(cJrnLot)
	RU01T03STE(cJrnLot)
EndIf

RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03STE

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
Function RU01T03STE(cLot AS CHARACTER)
Local cQuery        AS CHARACTER
Local cAlsTmp       AS CHARACTER
Local cStdEntry     AS CHARACTER
Local lDisplay      AS LOGICAL
Local lGroup        AS LOGICAL
Local lOffline      AS LOGICAL
Local aRegisters    AS ARRAY
Local aTmp          AS ARRAY
Local aArea         AS ARRAY
Local aAreaF4U      AS ARRAY

aArea       := GetArea()
aAreaF4U    := F4U->(GetArea())

cStdEntry   := ""
lRet        := .T.

F4U->(dbSetOrder(1))    //F4U_FILIAL+F4U_LOT
lRet    := F4U->(dbSeek(xFilial("F4U") + cLot))

cQuery  := " SELECT F4V_LOT, "
cQuery  += " F4V_ITEM, "
cQuery  += " F4U.R_E_C_N_O_ AS F4URECNO, "
cQuery  += " F4V.R_E_C_N_O_ AS F4VRECNO, "
cQuery  += " SN3.R_E_C_N_O_ AS SN3RECNO, "
cQuery  += " SN1.R_E_C_N_O_ AS SN1RECNO, "
cQuery  += " F4V.F4V_SN4REC AS SN4RECNO "
cQuery  += " FROM "+RetSqlName("F4U")+" F4U "
cQuery  += " JOIN "+RetSqlName("F4V")+" F4V ON F4V_LOT = F4U_LOT "
cQuery  += " JOIN "+RetSqlName("SN3")+" SN3 ON N3_UUID = F4V_SN3 "
cQuery  += " JOIN "+RetSqlName("SN1")+" SN1 "
cQuery  += " ON N1_CBASE = N3_CBASE "
cQuery  += " AND N1_ITEM = N3_ITEM "
cQuery  += " WHERE F4U.D_E_L_E_T_ = ' ' "
cQuery  += " AND F4V.D_E_L_E_T_ = ' ' "
cQuery  += " AND SN3.D_E_L_E_T_ = ' ' "
cQuery  += " AND SN1.D_E_L_E_T_ = ' ' "
cQuery  += " AND F4U_FILIAL = '"+xFilial("F4U")+"' "
cQuery  += " AND F4V_FILIAL = '"+xFilial("F4V")+"' "
cQuery  += " AND N3_FILIAL = '"+xFilial("SN3")+"' "
cQuery  += " AND N1_FILIAL = '"+xFilial("SN1")+"' "
cQuery  += " AND F4U_LOT = '"+cLot+"' "
cQuery  += " AND F4V_STATUS = '"+F4V_STATUS_CONFIRMED+"' "
cQuery  += " ORDER BY F4V_LOT, F4V_ITEM "

aRegisters  := {}
cQuery:=ChangeQuery(cQuery)
cAlsTmp     := RU01GETALS(cQuery)

While (cAlsTmp)->(! EOF())
	aTmp    := {}
	aAdd(aTmp, {"F4U", (cAlsTmp)->F4URECNO})
	aAdd(aTmp, {"F4V", (cAlsTmp)->F4VRECNO})
	aAdd(aTmp, {"SN3", (cAlsTmp)->SN3RECNO})
	aAdd(aTmp, {"SN1", (cAlsTmp)->SN1RECNO})
	aAdd(aTmp, {"SN4", (cAlsTmp)->SN4RECNO})
	aAdd(aRegisters, aTmp)
	
	If Empty(cStdEntry)
		cStdEntry   := IIf(F4U->F4U_OPER == F4U_OPER_EXECUTION,;
			"80G",;
			"80H")
	EndIf
	(cAlsTmp)->(dbSkip())
EndDo

(cAlsTmp)->(dbCloseArea())

If ! Empty(aRegisters)
	lDisplay    := Nil
	lGroup      := Nil
	lOffline    := Nil
	If Pergunte("RU01T03RUS", .F.)
		lDisplay    := (MV_PAR01 == 1)
		lGroup      := (MV_PAR02 == 1)
	EndIf

	lRet    := RU0134STEN(;
		cStdEntry,;
		"RU01T03" /* cRoutine */,;
		"SN4" /* cBaseAlias */,;
		aRegisters,;
		lDisplay,;
		lGroup,;
		lOffline)
EndIf

RestArea(aAreaF4U)
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
Local oStruF4U		AS OBJECT
Local oStruF4V		AS OBJECT
Local oModel		AS OBJECT

oStruF4U	:= FWFormStruct(1, "F4U")
oStruF4V	:= FWFormStruct(1, "F4V")

nOper       := GetOperation()

If nOper == RU01T03_OPER_STORNO
	oStruF4U:AddField(STR0019, STR0019, "MVC_STODES", "C", GetSX3Cache("F4U_DESCR","X3_TAMANHO"), 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| .T. } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .T. /* lObrigat */, {|| STR0032 } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//"Storno Description"
	oStruF4V:AddField(STR0023, STR0023, "MVC_STOHIS", "C", GetSX3Cache("F4V_HIST","X3_TAMANHO"), 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| .T. } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .T. /* lObrigat */, {|| STR0032 } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//"Storno History","Storno of "
EndIf
If nOper == RU01T03_OPER_MODERNIZATION .Or. nOper == RU01T03_OPER_STORNO
	oStruF4U:AddField(STR0013, STR0013, "MVC_CHKALL", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| RU01T03VLD(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| nOper == RU01T03_OPER_MODERNIZATION } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//"Mark all"
	oStruF4V:AddField(STR0012, STR0012, "MVC_OK", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| RU01T03VLD(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| nOper == RU01T03_OPER_MODERNIZATION } /* bInit */, .F. /* lKey */, /* lNoUpd */, .T. /* lVirtual */)	//" "
EndIf

oModel		:= MPFormModel():New("RU01T03", /* Pre-valid */, {|oMdl| RU01T03POS(oMdl) } /* Pos-Valid */, {|oMdl| RU01T03COM(oMdl) } /* Commit */)

oModel:AddFields("F4UMASTER", /*cOwner*/, oStruF4U)
oModel:GetModel("F4UMASTER"):SetDescription(STR0006) // "Journal Details"
oModel:AddGrid("F4VDETAIL", "F4UMASTER", oStruF4V, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
aRelat	:= {}
aAdd(aRelat, {"F4V_FILIAL", "XFILIAL('F4V')"})
aAdd(aRelat, {"F4V_LOT", "F4U_LOT"})
oModel:SetRelation("F4VDETAIL", aRelat, F4V->(IndexKey(1)))
oModel:GetModel("F4VDETAIL"):SetOptional(.T.)
oModel:GetModel("F4VDETAIL"):SetNoInsertLine(.T.)

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
Local cF4UIgnore    AS CHARACTER
Local cF4VIgnore    AS CHARACTER
Local oStruF4U		AS OBJECT
Local oStruF4V		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

oModel		:= FWLoadModel("RU01T03")

cF4UIgnore  := ""
cF4VIgnore  := ""
If GetOperation() == RU01T03_OPER_MODERNIZATION
	cF4UIgnore  += "F4U_DATE"
	cF4UIgnore  += "F4U_USER"

	cF4VIgnore  += "F4V_FILIAL"
	cF4VIgnore  += "F4V_LOT"
	cF4VIgnore  += "F4V_SN3"
	cF4VIgnore  += "F4V_SN4REC"
	cF4VIgnore  += "F4V_F4VLOT"
	cF4VIgnore  += "F4V_F4VITE"
	cF4VIgnore  += "F4V_LA"
	cF4VIgnore  += "F4V_ITEM"
	cF4VIgnore  += "F4V_STATUS"
	cF4VIgnore  += "F4V_MANAGP"
ElseIf GetOperation() == RU01T03_OPER_STORNO
	cF4VIgnore  += "F4V_FILIAL"
	cF4VIgnore  += "F4V_LOT"
	cF4VIgnore  += "F4V_SN3"
	cF4VIgnore  += "F4V_SN4REC"
	cF4VIgnore  += "F4V_F4VLOT"
	cF4VIgnore  += "F4V_F4VITE"
	cF4VIgnore  += "F4V_LA"
	cF4VIgnore  += "F4V_MANAGP"
	cF4VIgnore  += "F4V_HIST"
Else
	cF4VIgnore  += "F4V_FILIAL"
	cF4VIgnore  += "F4V_LOT"
	cF4VIgnore  += "F4V_SN3"
	cF4VIgnore  += "F4V_SN4REC"
	cF4VIgnore  += "F4V_F4VLOT"
	cF4VIgnore  += "F4V_F4VITE"
	cF4VIgnore  += "F4V_LA"
	cF4VIgnore  += "F4V_MANAGP"
	
	/*@author: astepanov*/
	cF4VIgnore  += "F4V_STATUS"
	cF4VIgnore  += "F4V_ITEM"
	
EndIf

cF4VIgnore  += "F4V_UID"
cF4VIgnore  += "F4V_SN4UID"

oStruF4U	:= FWFormStruct(2, "F4U", {|x| !(AllTrim(x) $ cF4UIgnore)})
oStruF4V	:= FWFormStruct(2, "F4V", {|x| !( AllTrim(x) $ cF4VIgnore)})

nOper       := GetOperation()

If nOper == RU01T03_OPER_STORNO
	oStruF4U:AddField("MVC_STODES", PADR('ZA', Len(SX3->X3_ORDEM), 'X'), STR0019, STR0019, Nil, "Get", GetSx3Cache("F4U_DESCR", "X3_PICTURE"),,,.T.)	//"Storno Description"
	oStruF4V:AddField("MVC_STOHIS", PADR('ZA', Len(SX3->X3_ORDEM), 'X'), STR0023, STR0023, Nil, "Get", GetSx3Cache("F4V_HIST", "X3_PICTURE"),,,.T.)	//"Storno History"
EndIf
If nOper == RU01T03_OPER_MODERNIZATION .Or. nOper == RU01T03_OPER_STORNO
	oStruF4U:AddField("MVC_CHKALL", PADR('', Len(SX3->X3_ORDEM), 'Z'), STR0013, STR0013, Nil, "Get", "",,,.T.)	//"Mark all"
	oStruF4V:AddField("MVC_OK", StrZero(1, Len(SX3->X3_ORDEM)), STR0012, STR0012, Nil, "Get", "",,,.T.)	//" "
EndIf

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F4U", oStruF4U, "F4UMASTER")
oView:AddGrid("VIEW_GRID", oStruF4V, "F4VDETAIL")
oView:AddIncrementField("VIEW_GRID", "F4V_ITEM")
oView:CreateHorizontalBox("MAIN", 25)
oView:CreateHorizontalBox("GRID", 75)
oView:SetOwnerView("VIEW_F4U", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

oView:addUserButton(STR0033, "", {|| RU01T03PRT(oStruF4U, oStruF4V) })  //Print

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
If IsInCallStack("RU01T03STO")
	nOper   := RU01T03_OPER_STORNO
ElseIf IsInCallStack("RU01T03INC")
	nOper   := RU01T03_OPER_MODERNIZATION
EndIf
Return nOper

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03VLD

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
Function RU01T03VLD(oVldModel AS OBJECT, cVldField AS CHARACTER, xVldNVal, xVldOVal)
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
	oModelGrd   := oModel:GetModel("F4VDETAIL")
	For nX := 1 To oModelGrd:Length()
		oModelGrd:GoLine(nX)
		If ! oModelGrd:IsDeleted()
			oModelGrd:SetValue("MVC_OK", xVldNVal)
		EndIf
	Next nX
	oView		:= FWViewActive()
	oGridObj	:= oView:GetViewObj("VIEW_GRID")[3]
	oGridObj:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
ElseIf cVldField == "MVC_OK"
	lRet    := .T.
	If GetOperation() == RU01T03_OPER_STORNO
		lRet    := oVldModel:GetValue("F4V_STATUS") == F4V_STATUS_CONFIRMED
		If ! lRet .And. "MVC_OK" $ ReadVar()
			Help("",1,"RU01T03STCF",,STR0020,1,0)	//"Journal item must have confirmed status for storno operation"
		EndIf
	EndIf
ElseIf cVldField == "POSVALID"
	lRet        := .T.

	aArea       := GetArea()
	aAreaSN3    := SN3->(GetArea())

	If lRet
		lRet    := ;
			! Empty(oVldModel:GetValue("F4V_VALUE")) .Or. ;
			! Empty(oVldModel:GetValue("F4V_INCPER"))
		If ! lRet
			Help("",1,"RU01T03VLGR",,STR0030,1,0)	//"All lines marked for execution must have at least the modernization value or useful life filled with positive values"
		EndIf
	EndIf

	If lRet
		SN3->(dbSetOrder(13))    //N3_FILIAL+N3_UUID
		lRet    := SN3->(dbSeek(xFilial("SN3") + oVldModel:GetValue("F4V_SN3")))
		If ! lRet
			Help("",1,"RU01T03VLN3A",,STR0028,1,0)	//"Error finding related FA record"
		EndIf
	EndIf

	If lRet
		dDtVld  := xVldNVal:GetValue("F4UMASTER", "F4U_DATE")

		cQuery	:= " SELECT N4_CBASE "
		cQuery	+= " FROM "+RetSqlName("SN4")+" SN4 "
		cQuery	+= " JOIN "+RetSqlName("F4V")+" F4V ON F4V_SN4UID = N4_UID"
		cQuery	+= " JOIN "+RetSqlName("F4U")+" F4U ON F4U_LOT = F4V_LOT"
		cQuery	+= " WHERE N4_FILIAL = '"+SN3->N3_FILIAL+"' "
		cQuery	+= " 	AND F4U_FILIAL = '" + xFilial("F4U") +"' "
		cQuery	+= " 	AND F4V_FILIAL = '" + xFilial("F4V") +"' "
		cQuery	+= "    AND N4_CBASE = '"+SN3->N3_CBASE+"' "
		cQuery	+= "    AND N4_ITEM = '"+SN3->N3_ITEM+"' "
		cQuery	+= "    AND N4_TIPO = '"+SN3->N3_TIPO+"' "
		cQuery	+= "    AND N4_SEQ = '"+SN3->N3_SEQ+"' "
		cQuery	+= "    AND SN4.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND F4V.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND F4U.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND SN4.R_E_C_N_O_ <> " + AllTrim(Str(oVldModel:GetValue("F4V_SN4REC")))
		cQuery	+= "    AND (( "
		cQuery	+= "             N4_DATA > '"+DToS(dDtVld)+"' "
		cQuery	+= "				AND N4_STORNO = '"+ SN4_STATUS_NOT_STORNO +"' "
		cQuery	+= "				AND F4U_OPER = '"+F4U_OPER_EXECUTION+"' )"		//Not Storno modernization in future date
		cQuery	+= "          OR ( "
		cQuery	+= "                   N4_DATA = '"+DToS(dDtVld)+"' "
		cQuery	+= "               AND N4_OCORR NOT IN ( "
		cQuery	+= "                     '05','07','08','10','11', "
		cQuery	+= "                     '06','12','17','18','20', '62' "
		cQuery	+= "                   ) "
		cQuery	+= "             ) "
		cQuery	+= "        ) "
		cAlsTmp := RU01GETALS(cQuery)
		lRet    := (cAlsTmp)->(EOF())
		(cAlsTmp)->(dbCloseArea())

		If ! lRet
			Help("",1,"RU01T03NN4",,STR0029,1,0)	//"Execution is not allowed for fixed assets with subsequent transactions"
		EndIf
	EndIf

	RestArea(aAreaSN3)
	RestArea(aArea)
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03_R2PreviousValues

Return array with accumulated values for FA

@param		DATE dMaxDate
@return		ARRAY aRet
@author 	victor.rezende
@since 		15/11/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T03_R2PreviousValues(dMaxDate AS DATE)
Local nX		AS NUMERIC
Local cQuery	AS CHARACTER
Local cAliasTrb	AS CHARACTER
Local cAtfCur	AS CHARACTER
Local aCurren	AS ARRAY
Local aArea		AS ARRAY
Local aRet		AS ARRAY

Default dMaxDate	:= dDataBase

aArea	:= GetArea()
aCurren	:= AtfMultMoe(,,{|x| 0})

cQuery	:= " SELECT COUNT(DISTINCT(SUBSTRING(N4_DATA, 1, 6))) AS NDEPR "
For nX := 1 To Len(aCurren)
	cQuery	+= "        ,COALESCE(SUM(N4_VLROC"+AllTrim(Str(nX))+"), 0) AS N4_VLROC"+AllTrim(Str(nX))+" "
Next nX
cQuery	+= "   FROM "+RetSqlName("SN4")+" SN4 "
cQuery	+= "  WHERE SN4.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND N4_FILIAL = '"+SN3->N3_FILIAL+"' "
cQuery	+= "    AND N4_CBASE = '"+SN3->N3_CBASE+"' "
cQuery	+= "    AND N4_ITEM = '"+SN3->N3_ITEM+"' "
cQuery	+= "    AND N4_TIPO = '"+SN3->N3_TIPO+"' "
cQuery	+= "    AND N4_SEQ = '"+SN3->N3_SEQ+"' "
cQuery	+= "    AND N4_TPSALDO = '"+SN3->N3_TPSALDO+"' "
cQuery	+= "    AND N4_TIPOCNT = '3' "
cQuery	+= "	AND N4_DATA BETWEEN '" + DToS(LastDay( RU01T0301_NextMonthAfterLastModer() ) + 1 ) +"' "
cQuery	+= "	AND '" + DToS(FirstDay(dMaxDate)) +"' "
cQuery	+= "    AND N4_OCORR IN ('06','07','08','10','11','12','17','18','20') "

cQuery	    := ChangeQuery(cQuery)
cAliasTrb   := RU01GETALS(cQuery)
aRet	:= {(cAliasTrb)->NDEPR, {}}
For nX := 1 To Len(aCurren)
	aAdd(aRet, &("('"+cAliasTrb+"')->N4_VLROC"+AllTrim(Str(nX))))
Next nX
(cAliasTrb)->(dbCloseArea())

RestArea(aArea)

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03_S3ReturnPerDep

Return period of depreciation based on the difference of rate of
depreciation

@param		NUMERIC nModTx
@param		LOGICAL lCalcDep
@return		NUMERIC nRet
@author 	victor.rezende
@since 		15/11/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T03_S3ReturnPerDep(nModTx AS NUMERIC, lCalcDep AS LOGICAL)
Local nRet			AS NUMERIC
Default lCalcDep	:= GetNewPar("MV_CALCDEP", "1") == "1"
nRet	:= 1200 / nModTx
If lCalcDep
	If nRet / 12 == Int(nRet / 12)
		nRet	:= nRet / 12
	Else
		nRet	:= Int(nRet / 12) + 1
	EndIf
EndIf
nRet	:= NoRound(nRet,  TAMSX3('N3_PERDEPR')[2])
Return nRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T03_S3ReturnPerDep

Return array with modernizations performed on current depreciation period

@param		None
@return		ARRAY aRet
	{
		{
			SN3->N3_FILIAL,
			SN3->N3_CBASE,
			SN3->N3_ITEM,
			SN3->N3_TIPO,
			SN3->N3_TPSALDO,
			Variation on rate of depreciation,
			{
				Sum of increased value on currency 1 (F4V_VALUE based),
				(...),
				Sum of increased value on currency N (F4V_VALUE based)
			}
		},(...)
	}
@author 	victor.rezende
@since 		20/04/2018
@version 	1.4
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T03_S4MonthModernization()
Local nX			AS NUMERIC
Local nStrongCur	AS NUMERIC
Local nModValue		AS NUMERIC
Local nVarOnRate	AS NUMERIC
Local nLiveMon		AS NUMERIC
Local cQuery		AS CHARACTER
Local cTmpAls		AS CHARACTER
Local cPeriod		AS CHARACTER
Local cStrongCur	AS CHARACTER
Local bPadField		AS BLOCK
Local aTmp			AS ARRAY
Local aAtfCur		AS ARRAY
Local aCurrencies	AS ARRAY
Local aRet			AS ARRAY

aRet		:= {}
aAtfCur		:= AtfMultMoe(,,{|x| 0})
cStrongCur	:= GetNewPar("MV_ATFMOED", "1")
nStrongCur	:= Val(cStrongCur)
bPadField	:= {|cAls,cFld| PADR(&("('"+cAls+"')->"+cFld), GetSX3Cache(cFld,"X3_TAMANHO"))}

cPeriod		:= StrZero(Year(dDataBase), 4)
If GetNewPar("MV_CALCDEP", "0") == "0"
	cPeriod	+= StrZero(Month(dDataBase), 2)
EndIf

cQuery		:= " SELECT N3_FILIAL, "
cQuery		+= " N3_CBASE, "
cQuery		+= " N3_ITEM, "
cQuery		+= " N3_TIPO, "
cQuery		+= " N3_SEQ, "
cQuery		+= " N3_TPSALDO, "
cQuery		+= " N3_PERDEPR, "
cQuery		+= " SUM( "
cQuery		+= " CASE WHEN F4V_INCPER > 0 THEN "
cQuery		+= " F4V_INCPER "
cQuery		+= " ELSE "
cQuery		+= " 0 "
cQuery		+= " END "
cQuery		+= " ) AS F4V_INCPER, "
cQuery		+= " SUM(F4V_VALUE) AS F4V_VALUE "
cQuery		+= " FROM "+RetSqlName("F4U")+" F4U "
cQuery		+= " JOIN "+RetSqlName("F4V")+" F4V ON F4V_LOT = F4U_LOT "
cQuery		+= " JOIN "+RetSqlName("SN3")+" SN3 ON N3_UUID = F4V_SN3 "
cQuery		+= " WHERE F4U.D_E_L_E_T_ = ' ' "
cQuery		+= " AND F4V.D_E_L_E_T_ = ' ' "
cQuery		+= " AND SN3.D_E_L_E_T_ = ' ' "
cQuery		+= " AND F4U_FILIAL = '"+xFilial("F4U")+"' "
cQuery		+= " AND F4V_FILIAL = '"+xFilial("F4V")+"' "
cQuery		+= " AND N3_FILIAL = '"+xFilial("SN3")+"' "
cQuery		+= " AND F4U_OPER = '"+F4U_OPER_EXECUTION+"' "
cQuery		+= " AND F4V_STATUS = '"+F4V_STATUS_CONFIRMED+"' "
cQuery		+= " AND F4U_DATE LIKE '"+cPeriod+"%' "
cQuery		+= " GROUP BY N3_FILIAL, "
cQuery		+= " N3_CBASE, "
cQuery		+= " N3_ITEM, "
cQuery		+= " N3_TIPO, "
cQuery		+= " N3_SEQ, "
cQuery		+= " N3_TPSALDO, "
cQuery		+= " N3_PERDEPR  "
cQuery		+= " ORDER BY 1, 2, 3, 4, 5 "

cQuery:=ChangeQuery(cQuery)
cTmpAls		:= RU01GETALS(cQuery)
While (cTmpAls)->(! EOF())
	aCurrencies	:= AClone(aAtfCur)
	nModValue	:= (cTmpAls)->F4V_VALUE

	For nX := 1 To Len(aCurrencies)
		If nX == nStrongCur
			aCurrencies[nX]	:= nModValue
		Else
			aCurrencies[nX]	:= xMoeda(nModValue, nStrongCur, nX)
		EndIf
	Next nX
	nLiveMon	:= RU01XFUN02_MonthBeforeModer((cTmpAls)->N3_CBASE, (cTmpAls)->N3_ITEM, (cTmpAls)->N3_TIPO, (cTmpAls)->N3_SEQ)
	nVarOnRate	:= RU01TXDEPR((cTmpAls)->N3_PERDEPR, "SN3")
	nVarOnRate	-= RU01TXDEPR((cTmpAls)->N3_PERDEPR - (cTmpAls)->F4V_INCPER - nLiveMon,"SN3")
	
	aTmp		:= {}
	aAdd(aTmp, Eval(bPadField, cTmpAls, "N3_FILIAL"))
	aAdd(aTmp, Eval(bPadField, cTmpAls, "N3_CBASE"))
	aAdd(aTmp, Eval(bPadField, cTmpAls, "N3_ITEM"))
	aAdd(aTmp, Eval(bPadField, cTmpAls, "N3_TIPO"))
	aAdd(aTmp, Eval(bPadField, cTmpAls, "N3_TPSALDO"))
	aAdd(aTmp, nVarOnRate)
	aAdd(aTmp, aCurrencies)

	aAdd(aRet, aTmp)
	(cTmpAls)->(dbSkip())
EndDo
(cTmpAls)->(dbCloseArea())

Return aRet

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
Function RU01T03VIE(oModel AS OBJECT)
Local lRet      AS LOGICAL
lRet    := .T.

If lRet .And. ValType("oModel") <> "O"
    oModel      := FWLoadModel("RU01T03")
    oModel:SetOperation(MODEL_OPERATION_VIEW)
    oModel:Activate()
EndIf

If lRet
    dbSelectArea("F4U")
    FWExecView(STR0001, "RU01T03", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Modernization"
EndIf

Return lRet

/*/{Protheus.doc} RU01T03PRT

Print

@return		Nil
@author 	Alexandra Menyashina
@since 		28/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T03PRT(oStruF4U AS object, oStruF4V AS object)
Local oReport	AS OBJECT
Local cName		AS CHARACTER

cName	:= 'RU01T03'
oReport := ReportDef(cName, oStruF4U, oStruF4V)
oReport:PrintDialog()

return Nil

/*/{Protheus.doc} ReportDef

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
Static Function ReportDef(cName as CHARACTER, oStruF4U AS object, oStruF4V AS object)
Local oReport	    AS OBJECT
Local oSecF4U	    AS OBJECT
Local oSecF4V	    AS OBJECT
Local oStruSN3		AS OBJECT
Local nX		    AS NUMERIC
Local cViewFldN3	AS CHARACTER

cViewFldN3    := 'N3_CBASE|N3_ITEM|N3_TIPO'
oStruSN3	:= FWFormStruct(2, "SN3", {|x| AllTrim(x) $ cViewFldN3})

oReport := TReport():New(cName/*cReport*/,STR0001/*cTitle*/,cName,{|oReport| ReportPrint(oReport, oStruF4U, oStruF4V, oStruSN3)},"PRINT", .F./*<lLandscape>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<cPageTText>*/ , .F./*<lPageTInLine>*/ , .F./*<lTPageBreak>*/ , /*<nColSpace>*/ )

oReport:lParamPage	:= .F.	//Don't print patameter page
//Header info
oSecF4U := TRSection():New(oReport,"",{'F4U'} , , .F., .T.)
For nX := 1 To Len(oStruF4U:aFields)
	If ! oStruF4U:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4U,oStruF4U:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"F4U", AllTrim(oStruF4U:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX
//Detail info
oSecF4V := TRSection():New(oReport,"",{'F4V'} , , .F., .T.)

For nX := 1 To Len(oStruSN3:aFields)
	If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4V,oStruSN3:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"SN3", alltrim(oStruSN3:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX

For nX := 1 To Len(oStruF4V:aFields)
	If ! oStruF4V:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecF4V,oStruF4V:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"F4V", alltrim(oStruF4V:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
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
Static Function ReportPrint(oReport, oStruF4U AS object, oStruF4V AS object, oStruSN3 AS OBJECT)
Local oSecF4U 		AS OBJECT
Local oSecF4V		AS OBJECT
Local cAliasQry		AS CHARACTER
Local cQuery		AS CHARACTER
Local cLot		    AS CHARACTER
Local cViewFldN3	AS CHARACTER
local lRet			AS LOGICAL
Local nX			AS NUMERIC
Local xValor

oSecF4U		:= oReport:Section(1)
oSecF4V		:= oReport:Section(2)
cAliasQry	:= GetNextAlias()
cQuery		:= ""
lRet		:= .T.

If oReport:Cancel()
	Return .T.
EndIf

cLot:= F4U->F4U_LOT
oSecF4U:Init()
oReport:IncMeter()

dbSelectArea('F4U')
F4U->(DBSeek( xFilial('F4U') + cLot))

For nX := 1 To Len(oStruF4U:aFields)
	If ! oStruF4U:aFields[nX, MVC_VIEW_VIRTUAL]
		If GetSx3Cache(oStruF4U:aFields[nX, MVC_VIEW_IDFIELD],'X3_TIPO') == 'D'
			xValor := F4U->&(oStruF4U:aFields[nX, MVC_VIEW_IDFIELD])
			xValor := StrTran(DTOC(xValor), "/", ".")
			oSecF4U:Cell(oStruF4U:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(xValor)
		Else
			oSecF4U:Cell(oStruF4U:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(F4U->&(oStruF4U:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	EndIf
Next nX		
oSecF4U:Printline()

oSecF4V:init()

cQuery	:= " SELECT  F4V.R_E_C_N_O_ F4VRECNO "

For nX := 1 To Len(oStruSN3:aFields)
	If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
		cQuery  += "," + oStruSN3:aFields[nX, MVC_VIEW_IDFIELD]
	EndIf
Next nX

For nX := 1 To Len(oStruF4V:aFields)
	If ! oStruF4V:aFields[nX, MVC_VIEW_VIRTUAL]
		cQuery  += "," + oStruF4V:aFields[nX, MVC_VIEW_IDFIELD]
	EndIf
Next nX

cQuery	+= " FROM "+RetSqlName("F4V")+" F4V "
cQuery	+= " JOIN "+RetSqlName("SN3")+" SN3 "
cQuery	+= " ON SN3.N3_UUID = F4V.F4V_SN3 "
cQuery	+= " WHERE F4V.D_E_L_E_T_ = ' '"
cQuery	+= " AND SN3.D_E_L_E_T_ = ' '"
cQuery	+= " AND N3_FILIAL = '" + xFilial("SN3") + "'"
cQuery	+= " AND F4V_FILIAL = '" + xFilial("F4V") + "'"
cQuery	+= " AND F4V_LOT = '" + cLot + "'"
cQuery:= ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

Dbselectarea(cAliasQry)
dbgotop()

While (cAliasQry)->(!EOF())
    For nX := 1 To Len(oStruSN3:aFields)
		If ! oStruSN3:aFields[nX, MVC_VIEW_VIRTUAL]
			oSecF4V:Cell(oStruSN3:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)->&(oStruSN3:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	Next nX
	For nX := 1 To Len(oStruF4V:aFields)
		If ! oStruF4V:aFields[nX, MVC_VIEW_VIRTUAL]
			oSecF4V:Cell(oStruF4V:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)->&(oStruF4V:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	Next nX
	oSecF4V:Printline()
	(cAliasQry)->(dbSkip())
EndDo
oSecF4V:Finish()
//Separator
oReport:ThinLine()
oSecF4U:Finish()
Return(NIL)

/*/{Protheus.doc} RU01T0301_NextMonthAfterLastModer

Return Next Month After Last Modernization or date creation

@return		Nil
@author 	Alexandra Menyashina
@since 		24/12/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T0301_NextMonthAfterLastModer()
Local cQuery 		as Character
Local cAliasQry		as Character
Local aArea			as Array
Local dRet			as Date

aArea := GetArea()
cQuery := "SELECT MAX(N4_DATA) LASTMOD	"
cQuery += " FROM " + RetSqlName("SN4") + " "
cQuery += " WHERE N4_FILIAL ='"+SN3->N3_FILIAL+"' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " AND N4_CBASE = '"+SN3->N3_CBASE+"' "
cQuery += " AND N4_ITEM = '"+SN3->N3_ITEM+"' "
cQuery += " AND N4_TIPO = '"+SN3->N3_TIPO+"' "
cQuery += " AND N4_SEQ = '"+SN3->N3_SEQ+"' "
cQuery += " AND N4_OCORR IN ('61', '62')"
cQuery      := ChangeQuery(cQuery)
cAliasQry := RU01GETALS(cQuery)
dRet :=  SToD((cAliasQry)->LASTMOD)

(cAliasQry)->(dbCloseArea())
RestArea(aArea)
return dRet