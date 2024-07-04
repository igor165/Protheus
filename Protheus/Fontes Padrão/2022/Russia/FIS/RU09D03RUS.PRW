#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU09D03RUS.CH'

#define CRLF				CHR(13)+CHR(10)
#define SEMAPH_GLTI			"RU09D03T03_THREADINI"
#define SEMAPH_GLTC			"RU09D03T03_THREAD"
#define SEMAPH_GLDN			"RU09D03T03_TRDONE"
#define THREAD_INNERREG		"RU09D03T03_REGS"
#define F33_STATUS_ACTIVE	"1"
#define F33_FILCTL_EXCLUS	"1"
#define F33_FILCTL_SHARED	"2"
#define F33_RESTAR_NEVER	"0"
#define F33_RESTAR_YEAR		"1"
#define F33_RESTAR_MONTH	"2"
#define F33_RESTAR_DAILY	"3"
#define F33_DATEP_YES		"1"
#define F33_DATEP_NO		"2"
#define F33_ALPHA_YES		"1"

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03RUS

General numbering system

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU09D03RUS()
Local lRet			AS LOGICAL
Local oBrowse		AS OBJECT
Private cCadastro	AS CHARACTER

lRet		:= .T.
cCadastro	:= STR0001	//"General numbering system"

dbSelectArea("F33")
dbSetOrder(1)	//F33_FILIAL+F33_KEY+F33_SERIE+F33_FILUSE+F33_BSDATE

oBrowse		:= BrowseDef()
oBrowse:Activate()

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse defition for general numbering system

@param		None
@return		OBJECT oBrowse
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse		AS OBJECT
oBrowse		:= FWMBrowse():New()
oBrowse:SetDescription(STR0001) //"General numbering system"
oBrowse:SetAlias("F33")
Return oBrowse

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu defition for general numbering system

@param		None
@return		ARRAY aRotina
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
aRotina	:= FWMVCMenu("RU09D03")
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

MVC model defition for general numbering system

@param		None
@return		OBJECT oModel MPFormModel()
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local nX			AS NUMERIC
Local aRelat		AS ARRAY
Local oStruF33		AS OBJECT
Local oStruF4X		AS OBJECT
Local oModel		AS OBJECT

oStruF33	:= FWFormStruct(1, "F33")
oStruF4X	:= FWFormStruct(1, "F4X")

oModel		:= MPFormModel():New("RU09D03RUS", /* Pre-valid */, {|oMdl| MVCPosValid(oMdl)} /* Pos-Valid */, /* Commit */)

oModel:AddFields("F33MASTER", /*cOwner*/, oStruF33)
oModel:AddGrid("F4XDETAIL", "F33MASTER", oStruF4X, /* bLinePre */, {|oMdl,nlin| GridLinePos(oMdl,nlin) } /* bLinePost */, /* bPre */, /* bLinePost */, {|oMdlGrd, xPar1| ModelGridLoad(oMdlGrd, xPar1)} /* bLoadGrid */)
oModel:SetDescription(STR0001) //"General numbering system"
oModel:GetModel("F33MASTER"):SetDescription(STR0001) //"General numbering system"
oModel:GetModel("F4XDETAIL"):SetDescription(STR0010) //"Dates and sequences"

oModel:GetModel("F4XDETAIL"):SetUniqueLine({"F4X_DATE"})
oModel:GetModel("F4XDETAIL"):SetOptional(.T.)
oModel:GetModel("F4XDETAIL"):SetNoInsertLine(.F.)

aRelat	:= {}
aAdd(aRelat, {"F4X_FILIAL", "F33_FILIAL"})
aAdd(aRelat, {"F4X_ID", "F33_ID"})
oModel:SetRelation("F4XDETAIL", aRelat, F4X->(IndexKey(1)))

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

MVC view defition for general numbering system

@param		None
@return		OBJECT oView FWFormView()
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oStruF33		AS OBJECT
Local oStruF4X		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

oStruF33	:= FWFormStruct(2, "F33", {|x| !(AllTrim(x) $ "F33_FILIAL|F33_ID|F33_UUID|F33_UUIDPR|F33_BSDATE|F33_ACTSEQ|F33_EXAMP")})
oStruF4X	:= FWFormStruct(2, "F4X", {|x| !(AllTrim(x) $ "F4X_ID")})
oModel		:= FWLoadModel("RU09D03")

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F33", oStruF33, "F33MASTER")
oView:AddGrid("VIEW_GRID", oStruF4X, "F4XDETAIL")
oView:CreateHorizontalBox("MAIN", 70)
oView:CreateHorizontalBox("GRID", 30)
oView:SetOwnerView("VIEW_F33", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

Return oView

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelGridLoad

MVC grid load function

@param		OBJECT oModelGrd
@param		MIXED xPar1
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelGridLoad(oModelGrd AS OBJECT, xPar1)
Local nX		AS NUMERIC
Local nPosNext	AS NUMERIC
Local nPosAct	AS NUMERIC
Local nPosDate	AS NUMERIC
Local cLeadCH	AS CHARACTER
Local cAlpha	AS CHARACTER
Local cMin		AS CHARACTER
Local cMax		AS CHARACTER
Local cPrefix	AS CHARACTER
Local cSuffix	AS CHARACTER
Local cDatePre	AS CHARACTER
Local cRestart	AS CHARACTER
Local cSeq		AS CHARACTER
Local cActSeq	AS CHARACTER
Local dDate		AS DATE
Local aRet		AS ARRAY
Local aFields	AS ARRAY
Local oModel	AS OBJECT
aRet		:= FormLoadGrid(oModelGrd, xPar1)

If ! IsBlind()
	aFields		:= oModelGrd:GetStruct():GetFields()
	nPosNext	:= AScan(aFields, {|x| ALlTrim(x[ MODEL_FIELD_IDFIELD ]) == "F4X_NEXTNU"})
	nPosAct		:= AScan(aFields, {|x| ALlTrim(x[ MODEL_FIELD_IDFIELD ]) == "F4X_ACTSEQ"})
	nPosDate	:= AScan(aFields, {|x| ALlTrim(x[ MODEL_FIELD_IDFIELD ]) == "F4X_DATE"})
	If ( nPosNext * nPosAct * nPosDate ) > 0
		oModel		:= oModelGrd:GetModel()
		cLeadCH		:= oModel:GetModel("F33MASTER"):GetValue("F33_LEADCH")
		nSize		:= oModel:GetModel("F33MASTER"):GetValue("F33_SIZE")
		cAlpha		:= oModel:GetModel("F33MASTER"):GetValue("F33_ALPHA")
		cMin		:= oModel:GetModel("F33MASTER"):GetValue("F33_MIN")
		cMax		:= oModel:GetModel("F33MASTER"):GetValue("F33_MAX")
		cPrefix		:= oModel:GetModel("F33MASTER"):GetValue("F33_PREFIX")
		cSuffix		:= oModel:GetModel("F33MASTER"):GetValue("F33_SUFFIX")
		cDatePre	:= oModel:GetModel("F33MASTER"):GetValue("F33_DATEP")
		cRestart	:= oModel:GetModel("F33MASTER"):GetValue("F33_RESTAR")
		For nX := 1 To Len(aRet)
			cSeq					:= ""
			cActSeq					:= aRet[nX, 2, nPosAct]
			dDate					:= aRet[nX, 2, nPosDate]
			aRet[nX, 2, nPosNext]	:= RU09D03_RD(cLeadCH, nSize, cActSeq, cAlpha, cMin, cMax, cPrefix, cSuffix, cDatePre, cRestart, cSeq, dDate)
		Next nX
	EndIf
EndIf

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePos

MVC grid lines pos valid

@param		OBJECT oModelGrd
@param		NUMERIC nLin
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function GridLinePos(oModelGrd AS OBJECT, nLin AS NUMERIC)
Local nX		AS NUMERIC
Local lRet		AS LOGICAL
Local dOldDate	AS DATE
Local dNewDate	AS DATE
lRet	:= .T.

If lRet
	dOldDate	:= oModelGrd:GetValue("F4X_DATE")
	dNewDate	:= SetBaseDate(M->F33_RESTAR, dOldDate)
	lRet		:= dOldDate == dNewDate .Or. oModelGrd:SetValue("F4X_DATE", dNewDate)
EndIf

If lRet
	For nX := 1 To oModelGrd:Length()
		If	! oModelGrd:IsDeleted(nX) .And. ;
			nX <> oModelGrd:GetLine() .And. ;
			oModelGrd:GetValue("F4X_DATE") == oModelGrd:GetValue("F4X_DATE", nX)
				lRet	:= .F.
				Help("",1,"RU09D03DTRE",,STR0009,1,0)	//"Duplicated start date for this resetting pattern"
				Exit
		EndIf
	Next nX
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RefreshGrid

Refresh View grid

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RefreshGrid()
Local lRet		AS LOGICAL
Local oView		AS OBJECT
Local oGridObj	AS OBJECT
lRet			:= .T.
oView			:= FWViewActive()
oGridObj		:= oView:GetViewObj("VIEW_GRID")[3]
oGridObj:Refresh(.T. /* lEvalChanges */, .T. /* lGoTop */)
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetBaseDate

Function to set base date for numbering period

@param		CHARACTER cRestart
@param		DATE dCurDate
@return		DATE dDate
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function SetBaseDate(cRestart AS CHARACTER, dCurDate AS DATE)
Local dDate		AS DATE
If cRestart == "1"
	dDate	:= SToD(SubStr(DToS(dCurDate), 1, 4) + "0101")
ElseIf cRestart == "2"
	dDate	:= SToD(SubStr(DToS(dCurDate), 1, 6) + "01")
Else
	dDate	:= dCurDate
EndIf
Return dDate

//-----------------------------------------------------------------------
/*/{Protheus.doc} MVCPosValid

MVC pre-valid function

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function MVCPosValid(oModel AS OBJECT)
Local nX		AS NUMERIC
Local lRet		AS LOGICAL
Local oModelGrd	AS OBJECT

lRet		:= .T.
oModelGrd	:= oModel:GetModel("F33DETAIL")

lRet		:= lRet .And. RU09D03V("F33_STATUS", .F.)
lRet		:= lRet .And. (ValType(oModelGrd) <> "O" .Or. RU09D03V("F33_RESTAR", .F.))

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03TRI

Function for rendering

@param		CHARACTER cField
@return		MIXED xRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU09D03TRI(cField AS CHARACTER)
Local nX			AS NUMERIC
Local nSize			AS NUMERIC
Local cLeadCH		AS CHARACTER
Local cAlpha		AS CHARACTER
Local cMin			AS CHARACTER
Local cMax			AS CHARACTER
Local cPrefix		AS CHARACTER
Local cSuffix		AS CHARACTER
Local cDatePre		AS CHARACTER
Local cRestart		AS CHARACTER
Local cSeq			AS CHARACTER
Local cActSeq		AS CHARACTER
Local dDate			AS DATE
Local oModel		AS OBJECT
Local oModelGrd		AS OBJECT
Local xRet

oModel		:= FwModelActive()
oModelGrd	:= oModel:GetModel("F4XDETAIL")

If AllTrim(cField) $ "F4X_ACTSEQ|F4X_DATE"
	cLeadCH		:= oModel:GetModel("F33MASTER"):GetValue("F33_LEADCH")
	nSize		:= oModel:GetModel("F33MASTER"):GetValue("F33_SIZE")
	cAlpha		:= oModel:GetModel("F33MASTER"):GetValue("F33_ALPHA")
	cMin		:= oModel:GetModel("F33MASTER"):GetValue("F33_MIN")
	cMax		:= oModel:GetModel("F33MASTER"):GetValue("F33_MAX")
	cPrefix		:= oModel:GetModel("F33MASTER"):GetValue("F33_PREFIX")
	cSuffix		:= oModel:GetModel("F33MASTER"):GetValue("F33_SUFFIX")
	cDatePre	:= oModel:GetModel("F33MASTER"):GetValue("F33_DATEP")
	cRestart	:= oModel:GetModel("F33MASTER"):GetValue("F33_RESTAR")
	cSeq		:= ""
	cActSeq		:= oModelGrd:GetValue("F4X_ACTSEQ")
	dDate		:= oModelGrd:GetValue("F4X_DATE")
	xRet		:= RU09D03_RD(cLeadCH, nSize, cActSeq, cAlpha, cMin, cMax, cPrefix, cSuffix, cDatePre, cRestart, cSeq, dDate)
ElseIf AllTrim(cField) == "F33_FILCTL"
	If M->F33_FILCTL == F33_FILCTL_SHARED
		xRet	:= Space(GetSX3Cache("F33_FILUSE", "X3_TAMANHO"))
	Else
		xRet	:= M->F33_FILUSE
	EndIf
ElseIf SubStr(cField, 1, 4) == "F33_"
	xRet		:= &("M->"+cField)
	For nX := 1 To oModelGrd:Length()
		oModelGrd:GoLine(nX)
		oModelGrd:SetValue("F4X_NEXTNU", RU09D03TRI("F4X_ACTSEQ"), .T.)
	Next nX
	If oModelGrd:Length() > 0
		RefreshGrid()
	EndIf
EndIf

Return xRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03_RD

Function for rendering

@param		CHARACTER cLeadCh
@param		NUMERIC nSize
@param		CHARACTER cCurSeq
@param		CHARACTER cAlpha
@param		CHARACTER cMin
@param		CHARACTER cMax
@param		CHARACTER cPrefix
@param		CHARACTER cSuffix
@param		CHARACTER cDatePref
@param		CHARACTER cRestart
@param		CHARACTER cActSeq
@param		DATE dDate
@return		CHARACTER cRetSeq
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU09D03_RD(cLeadCh AS CHARACTER, nSize AS NUMERIC, cCurSeq AS CHARACTER, cAlpha As CHARACTER, cMin As CHARACTER, cMax AS CHARACTER, cPrefix AS CHARACTER, cSuffix AS CHARACTER, cDatePref AS CHARACTER, cRestart AS CHARACTER, cActSeq AS CHARACTER, dDate AS DATE)

Default dDate	:= dDataBase

cRetSeq	:= ""
cActSeq	:= PADL(AllTrim(cCurSeq), nSize, "0")
cMin	:= PADL(AllTrim(cMin), nSize, "0")
cMax	:= PADL(AllTrim(cMax), nSize, IIf(Empty(cMax), "Z", "0"))

cActSeq	:= RU01INCCHR(cActSeq, (cAlpha == "1"))

If ! Empty(cActSeq) .And. cActSeq < cMin
	cActSeq	:= cMin
EndIf

If ! Empty(cActSeq) .And. cActSeq > cMax
	cActSeq	:= ""
EndIf

If ! Empty(cActSeq)
	If cLeadCh == "0"	//Don't use lead char
		While ! Empty(cActSeq) .And. SubStr(cActSeq, 1, 1) == "0"
			cActSeq	:= SubStr(cActSeq, 2, Len(cActSeq) - 1)
		EndDo
	EndIf
EndIf

If ! Empty(cActSeq)
	cRetSeq	:= ""

	If cDatePref == "1"
		If cRestart == "1"		// Yearly
			cRetSeq	:= SubStr(DToS(dDate), 1, 4)
		ElseIf cRestart == "2"	//Monthly
			cRetSeq	:= SubStr(DToS(dDate), 1, 6)
		Else
			cRetSeq	:= DToS(dDate)
		EndIf
	EndIf

	cRetSeq	+= AllTrim(cPrefix)
	cRetSeq	+= AllTrim(cActSeq)
	cRetSeq	+= AllTrim(cSuffix)
EndIf

Return cRetSeq

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03V

Validation function

@param		CHARACTER cField
@param		LOGICAL lConfirm
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU09D03V(cField AS CHARACTER, lConfirm AS LOGICAL)
Local nX		AS NUMERIC
Local cKey		AS LOGICAL
Local cKeyMax	AS LOGICAL
Local lRet		AS LOGICAL
Local aArea		AS ARRAY
Local aAreaF33	AS ARRAY
Local oModel	AS OBJECT
Local oModelGrd	AS OBJECT
lRet	:= .F.
If cField == "F33_SERIE"
	lRet	:= AllTrim(M->F33_KEY) $ "FACARD" .Or. IsInCallStack("U_RU09D03T")
	If ! lRet .And. lConfirm
		Help("",1,"RU09D03ASFA",,STR0014,1,0)	//"Serie is allowed only for fixed assets card key"
	EndIf
ElseIf cField == "F33_STATUS"
	lRet	:= .T.
	If M->F33_STATUS == F33_STATUS_ACTIVE
		aArea		:= GetArea()
		aAreaF33	:= F33->(GetArea())

		F33->(dbSetOrder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
		cKey	:= xFilial("F33") + M->F33_KEY + M->F33_SERIE + M->F33_STATUS + M->F33_FILCTL + M->F33_FILUSE
		If F33->(dbSeek(cKey))
			While F33->(!EOF()) .And. F33->(F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE) == cKey
				If F33->F33_ID <> M->F33_ID
					lRet	:= .F.
					Help("",1,"RU09D03UNAC",,STR0008,1,0)	//"Activation not allowed because there is other active numbering control record for this key and series"
					Exit
				EndIf
				F33->(dbSkip())
			EndDo
		EndIf

		RestArea(aAreaF33)
		RestArea(aArea)
	EndIf
ElseIf cField == "F33_RESTAR"
	lRet		:= .T.
	oModel		:= FwModelActive()
	oModelGrd	:= oModel:GetModel("F4XDETAIL")

	If ! IsBlind() .And. oModelGrd:Length() > 0 .And. lConfirm .And. ! MsgYesNo(STR0011)	//"All rows of the grid will be updated according to the new reset rule. Proceed?""
		lRet	:= .F.
	EndIf

	For nX := 1 To oModelGrd:Length()
		oModelGrd:GoLine(nX)
		If ! oModelGrd:IsDeleted()
			If ! GridLinePos(oModelGrd, nX)
				lRet	:= .F.
				Exit
			EndIf
		EndIf
	Next nX
ElseIf cField == "F4X_ACTSEQ"
	cKey	:= AllTrim(M->F4X_ACTSEQ)
	If Len(cKey) < M->F33_SIZE
		cKey	:= PADL(AllTrim(M->F4X_ACTSEQ), M->F33_SIZE, "0")
	EndIf
	cKeyMax	:= PADL( ;
		"", ;
		M->F33_SIZE, ;
		IIf(M->F33_ALPHA == F33_ALPHA_YES, "Z", "9");
	)
	lRet	:= Len(cKey) <= Len(cKeyMax) .And. cKey <= cKeyMax
	If ! lRet
		Help("",1,"RU09D03ACNB",,STR0013,1,0)	//"Actual sequence cannot be greater than maximum allowed size"
	EndIf
ElseIf cField == "F33_SIZE"
	lRet		:= .T.
	oModel		:= FwModelActive()
	oModelGrd	:= oModel:GetModel("F4XDETAIL")

	For nX := 1 To oModelGrd:Length()
		oModelGrd:GoLine(nX)
		If ! oModelGrd:IsDeleted()
			cKey	:= AllTrim(oModelGrd:GetValue("F4X_ACTSEQ"))
			If Len(cKey) > M->F33_SIZE
				lRet	:= .F.
				Help("",1,"RU09D03ACNB",,STR0013,1,0)	//"Actual sequence cannot be greater than maximum allowed size"
				Exit
			EndIf
		EndIf
	Next nX
EndIf
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03EXP

Function for next number rendering

@param		None
@return		CHARACTER cRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU09D03EXP()
Local cSeq		AS CHARACTER
Local cRet		AS CHARACTER

cSeq	:= ""
cRet	:= RU09D03_RD(M->F33_LEADCH, M->F33_SIZE, M->F33_ACTSEQ, M->F33_ALPHA, M->F33_MIN, M->F33_MAX, M->F33_PREFIX, M->F33_SUFFIX, M->F33_DATEP, M->F33_RESTAR, @cSeq)

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03SIZ

Function for maximum size calculation

@param		None
@return		NUMERIC nRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU09D03SIZ()
Local nRet		AS NUMERIC

nRet		:= 0
If M->F33_DATEP == F33_DATEP_YES .And. M->F33_RESTAR == F33_RESTAR_YEAR
	nRet	+= 4
ElseIf M->F33_DATEP == F33_DATEP_YES .And. M->F33_RESTAR == F33_RESTAR_MONTH
	nRet	+= 6
ElseIf M->F33_DATEP == F33_DATEP_YES
	nRet	+= 8
EndIf

nRet	+= Len(AllTrim(M->F33_PREFIX))
nRet	+= M->F33_SIZE
nRet	+= Len(AllTrim(M->F33_SUFFIX))

Return nRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03Nmb

Main numbering function

@param		CHARACTER cKey
@param		CHARACTER cSerie
@param		CHARACTER cFilUse
@return		CHARACTER cRetSeq
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU09D03Nmb(cKey AS CHARACTER, cSerie AS CHARACTER, cFilUse AS CHARACTER)
Local nRecHead		AS NUMERIC
Local cRetSeq		AS CHARACTER
Local cActSeq		AS CHARACTER
Local cKey			AS CHARACTER
Local lLockHead		AS LOGICAL
Local lOk			AS LOGICAL
Local dDateSear		AS DATE

Default cSerie	:= Space(GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
Default cFilUse	:= cFilAnt
cKey			:= PADR(cKey, GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerie			:= PADR(cSerie, GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
lOk				:= .T.
cRetSeq			:= ""
cActSeq			:= ""

//Position head F33 register
F33->(dbSetOrder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
If lOk
	If 	F33->(! dbSeek(xFilial("F33") + cKey + cSerie + F33_STATUS_ACTIVE + F33_FILCTL_EXCLUS + cFilUse)) .And. ;
		F33->(! dbSeek(xFilial("F33") + cKey + cSerie + F33_STATUS_ACTIVE + F33_FILCTL_SHARED))
			lOk		:= .F.
			Help("",1,"RU09D03REGNOIS",,STR0012,1,0)	//"No active numbering record control exists for this key series combination"
	EndIf
EndIf

//Lock head register
lLockHead	:= .F.
If lOk
	F33->(SoftLock("F33"))
	lLockHead	:= .T.
	nRecHead	:= F33->(Recno())
EndIf

//Define branch to be used
If lOk
	If F33->F33_FILCTL == F33_FILCTL_SHARED
		cFilUse	:= Space(GetSX3Cache("F33_FILUSE", "X3_TAMANHO"))
	Else
		cFilUse	:= cFilAnt
	EndIf
EndIf

//Position F4X according to correct date reseting pattern
If lOk
	If F33->F33_RESTAR == F33_RESTAR_NEVER
		cKey		:= xFilial("F4X") + F33->F33_ID
		dDateSear	:= dDataBase
	Else
		dDateSear	:= SetBaseDate(F33->F33_RESTAR, dDataBase)
		cKey		:= xFilial("F4X") + F33->F33_ID + DToS(dDateSear)
	EndIf
	F4X->(dbSetorder(1))	//F4X_FILIAL+F4X_ID+F4X_DATE
	If F4X->(! dbSeek(cKey))
		RecLock("F4X", .T.)
		F4X->F4X_FILIAL	:= xFilial("F4X")
		F4X->F4X_ID		:= F33->F33_ID
		F4X->F4X_DATE	:= dDateSear
		F4X->F4X_ACTSEQ	:= ""
		F4X->(MsUnlock())
	EndIf
EndIf

//Reserve next number
If lOk
	cActSeq	:= F4X->F4X_ACTSEQ
	cRetSeq	:= RU09D03_RD(F33->F33_LEADCH, F33->F33_SIZE, F4X->F4X_ACTSEQ, F33->F33_ALPHA, F33->F33_MIN, F33->F33_MAX, F33->F33_PREFIX, F33->F33_SUFFIX, F33->F33_DATEP, F33->F33_RESTAR, @cActSeq, dDateSear)
	If ! Empty(cRetSeq)
		RecLock("F4X", .F.)
		F4X->F4X_ACTSEQ	:= cActSeq
		F4X->(MsUnlock())
	EndIf
EndIf

//Unlock head register
If lLockHead
	F33->(dbGoTo(nRecHead))
	F33->(MsUnlock())
EndIf

Return cRetSeq

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T

Test-driven development for general numbering system

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
User Function RU09D03T()
Local cMsg			AS CHARACTER
Local lRet			AS LOGICAL
Local lResetEnv		AS LOGICAL

Local cQuery        AS CHARACTER

lRet		:= .T.
lResetEnv	:= Type("cFilAnt") == "U"
cMsg		:= "RU09D03T Test result:" + CRLF

If lResetEnv
	RpcSetType(3)
	RpcSetEnv("T1", "M RU01",,,"ATF")
EndIf

If GetSrvProfString("RUTC_MODE", "null") == "development"
	cQuery := "DELETE FROM " + RetSqlname("F4X") + " WHERE F4X_ID IN (SELECT F33_ID FROM " + RetSqlname("F33") + " WHERE F33_SERIE LIKE 'TC%')"
	cQuery := ChangeQuery(cQuery)
	TcSqlExec(cQuery)

	cQuery := "DELETE FROM " + RetSqlname("F33") + " WHERE F33_SERIE LIKE 'TC%'"
	cQuery := ChangeQuery(cQuery)
	TcSqlExec(cQuery)
EndIf

cObs	:= ""
cMsg	+= "Test case 01 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T01(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 02 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T02(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 03 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T03(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 04 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T04(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 05 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T05(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 06 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T06(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 07 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T07(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 08 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T08(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 09 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T09(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF
cMsg	+= "Test case 10 > " + IIf(Empty(cObs:=""),"","") + IIf(RU09D03T10(@cObs), "Ok", "Not ok") + IIf(!Empty(cObs), " - " + cObs, "") + CRLF

MsgInfo(cMsg)

If lResetEnv
	RpcClearEnv()
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03X

Support function for threading on test cases

@param		CHARACTER cEmpX
@param		CHARACTER cFilX
@param		CHARACTER cOper
@param		ARRAY ARRAY
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
User Function RU09D03X(cEmpX AS CHARACTER, cFilX AS CHARACTER, cOper AS CHARACTER, aParams AS ARRAY)
Local nX		AS NUMERIC
Local nTry		AS NUMERIC
Local nMaxTries	AS NUMERIC
Local lRet		AS LOGICAL
Local lSemaphor	AS LOGICAL
Local aRegs		AS ARRAY
lRet	:= .T.

RpcSetType(3)
RpcSetEnv(cEmpX, cFilX,,,"ATF")

If cOper == "RU09D03T03"
	IPCGo(SEMAPH_GLTI)
	nTry		:= 0
	nMaxTries	:= 20
	While ! KillApp()
		nTry++
		If IpcWaitEx(SEMAPH_GLTC + AllTrim(Str(aParams[01])), 2000)
			Exit
		ElseIf nTry > nMaxTries
			Return .F.
		EndIf
	EndDo

	aRegs	:= {}
	For nX := 1 To aParams[03]
		aAdd(aRegs, RU09D03Nmb(aParams[04], aParams[05]))
	Next nX
	PutGlbVars(THREAD_INNERREG + AllTrim(Str(aParams[01])), aRegs)
	IPCGo(SEMAPH_GLDN + AllTrim(Str(aParams[01])))
EndIf

RpcClearEnv()

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} TIndexExistAssert

Post-Validation assert index exists

@param		CHARACTER cObs
@param		CHARACTER cDescr
@param		CHARACTER cAlias
@param		NUMERIC nIndex
@param		CHARACTER cKey
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function TIndexExistAssert(cObs AS CHARACTER, cDescr AS CHARACTER, cAlias AS CHARACTER, nIndex AS NUMERIC, cKey AS CHARACTER)
Local lRet		AS LOGICAL

(cAlias)->(dbSetorder(nIndex))
lRet	:= F33->(dbSeek(cKey))
If ! lRet
	cObs	:= STR0005 + cDescr + " for alias ("+cAlias+"), index ("+AllTrim(Str(nIndex))+") and key ("+cKey+") dont exists"	//"Post-condition failed: "
EndIf
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} TEqualsAssert

Test post-validation assert equals

@param		CHARACTER cObs
@param		CHARACTER cDescr
@param		MIXED xValue
@param		MIXED xExpected
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function TEqualsAssert(cObs AS CHARACTER, cDescr AS CHARACTER, xValue, xExpected)
Local lRet		AS LOGICAL
lRet		:= xValue == xExpected
If ! lRet
	cObs	:= STR0005 + " "+cDescr+" ("+AllToChar(xValue)+") should be ("+AllToChar(xExpected)+") "	//"Post-condition failed: "
EndIf
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} TEmptyAssert

Test post-validation assert empty

@param		CHARACTER cObs
@param		CHARACTER cDescr
@param		MIXED xValue
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function TEmptyAssert(cObs AS CHARACTER, cDescr AS CHARACTER, xValue)
Local lRet		AS LOGICAL
lRet		:= Empty(xValue)
If ! lRet
	cObs	:= STR0005 + " "+cDescr+" ("+AllToChar(xValue)+") should be empty "	//"Post-condition failed: "
EndIf
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T01

Test case 01 - Create F33 entry

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T01(cObs AS CHARACTER)
Local cKey		AS CHARACTER
Local cSerie	AS CHARACTER
Local lRet		AS LOGICAL
Local oModel	AS OBJECT

lRet		:= .T.
cKey		:= PADR("1", GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerie		:= PADR("TC1", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))

//Pre-conditions
// 1) Numbering entry cKey + cSerie should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerie))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerie+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 2) Record cKey from ON table should exist
If lRet
	SX5->(dbSetorder(1))	//X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(! dbSeek(xFilial("SX5") + "ON" + cKey))
		lRet	:= .F.
		cObs	:= STR0002 + "Register "+cKey+" from ON table dont exist"	//"Pre-condition failed: "
	EndIf
EndIf
//End Pre-conditions

//Setup test case
//End Setup test case

//Execution
// 1) Create numbering entry cKey + cSerie
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", 9)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0004 + "Model validation failed"	//"Execution failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0004 + "Model commit failed"	//"Execution failed: "
	EndIf
	oModel:DeActivate()
EndIf
//End Execution

//Post-conditions validation
// 1) Numbering entry cKey + cSerie should exist
lRet	:= lRet .And. TIndexExistAssert(@cObs, "numbering control", "F33", 3, (xFilial("F33") + cKey + cSerie))
//End Post-conditions validation

//Post-script
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T02

Test case 02 - Validate numbering sequence

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T02(cObs AS CHARACTER)
Local nX		AS NUMERIC
Local cKey		AS CHARACTER
Local cSerie	AS CHARACTER
Local lRet		AS LOGICAL
Local aNumber	AS ARRAY
Local oModel	AS OBJECT

lRet		:= .T.
cKey		:= PADR("1", GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerie		:= PADR("TC2", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))

//Pre-conditions
// 1) Numbering entry cKey + cSerie should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerie))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerie+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 2) Record cKey from ON table should exist
If lRet
	SX5->(dbSetorder(1))	//X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(! dbSeek(xFilial("SX5") + "ON" + cKey))
		lRet	:= .F.
		cObs	:= STR0002 + "Register "+cKey+" from ON table dont exist"	//"Pre-condition failed: "
	EndIf
EndIf
//End Pre-conditions

//Setup test case
// 1) Create numbering entry cKey + cSerie
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", 9)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0004 + "Model validation failed"	//"Execution failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0004 + "Model commit failed"	//"Execution failed: "
	EndIf
	oModel:DeActivate()
EndIf
//End Setup test case

//Execution
// 1) Get next 100 numbers
If lRet
	aNumber	:= {}
	For nX := 1 To 100
		aAdd(aNumber, RU09D03Nmb(cKey, cSerie))
	Next nX
EndIf
//End Execution

//Post-conditions validation
// 1) Numbers should be in sequence
If lRet
	For nX := 1 To Len(aNumber)
		If Val(aNumber[nX]) <> nX
			lRet	:= .F.
			cObs	:= STR0005 + " element number ("+Alltrim(Str(nX))+") with value ("+aNumber[nX]+") not equals ("+Alltrim(Str(nX))+") "	//"Post-condition failed: "
			Exit
		EndIf
	Next nX
EndIf
//End Post-conditions validation

//Post-script
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T03

Test case 03 - Validate concurrence

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T03(cObs AS CHARACTER)
Local nX		AS NUMERIC
Local nY		AS NUMERIC
Local nThreads	AS NUMERIC
Local nRegs		AS NUMERIC
Local nMaxTries	AS NUMERIC
Local nTry		AS NUMERIC
Local cKey		AS CHARACTER
Local cSerie	AS CHARACTER
Local cGlbVar	AS CHARACTER
Local lRet		AS LOGICAL
Local lSemaphor	AS LOGICAL
Local aRegs		AS ARRAY
Local aRegsTmp	AS ARRAY

lRet		:= .T.
nThreads	:= 2
nRegs		:= 100
aRegs		:= {}
cKey		:= PADR("1", GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerie		:= PADR("TC3", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))

//Pre-conditions
// 1) Numbering entry cKey + cSerie should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerie))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerie+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 2) Record cKey from ON table should exist
If lRet
	SX5->(dbSetorder(1))	//X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(! dbSeek(xFilial("SX5") + "ON" + cKey))
		lRet	:= .F.
		cObs	:= STR0002 + "Register "+cKey+" from ON table dont exist"	//"Pre-condition failed: "
	EndIf
EndIf
//End Pre-conditions

//Setup test case
// 1) Create numbering entry cKey + cSerie
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", 8)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
//End Setup test case

//Execution
// 1) Start threads to create registers
If lRet
	nMaxTries	:= 20
	For nX := 1 To nThreads
		StartJob("U_RU09D03X", GetEnvServer(), .F., cEmpAnt, cFilAnt, "RU09D03T03", {;
			nX, ;
			cGlbVar, ;
			nRegs, ;
			cKey, ;
			cSerie, ;
			nThreads ;
		})
		nTry	:= 0
		While ! KillApp()
			nTry++
			If IpcWaitEx(SEMAPH_GLTI, 1000)
				Exit
			ElseIf nTry > nMaxTries
				lRet	:= .F.
				cObs	:= STR0004 + "Max tries ("+AllTrim(Str(nMaxTries))+") exceeded ("+AllTrim(Str(nTry))+") for start job"	//"Execution failed: "
				Exit
			EndIf
		EndDo
	Next nX
	
	For nX := 1 To nThreads
		IPCGo(SEMAPH_GLTC + AllTrim(Str(nX)))
	Next nX
	
	For nX := 1 To nThreads
		nTry	:= 0
		While ! KillApp()
			nTry++
			If IpcWaitEx(SEMAPH_GLDN + AllTrim(Str(nX)), 1000)
				Exit
			ElseIf nTry > nMaxTries
				lRet	:= .F.
				cObs	:= STR0004 + "Max tries ("+AllTrim(Str(nMaxTries))+") exceeded ("+AllTrim(Str(nTry))+") for execution of thread ("+AllTrim(Str(nX))+")"	//"Execution failed: "
				Exit
			EndIf
		EndDo
	Next nX
EndIf
// 2) Aggregates results from threads
If lRet
	aRegs	:= {}
	For nX := 1 To nThreads
		aRegsTmp	:= {}
		GetGlbVars(THREAD_INNERREG + AllTrim(Str(nX)), @aRegsTmp)
		For nY := 1 To Len(aRegsTmp)
			aAdd(aRegs, aRegsTmp[nY])
		Next nY
	Next nX
	aSort(aRegs)
EndIf
//End Execution

//Post-conditions validation
// 1) There should be nThreads * nRegs registers
lRet	:= lRet .And. TEqualsAssert(@cObs, "number of registers", Len(aRegs), (nThreads * nRegs))
// 2) All registers should be continuous
If lRet
	For nX := 1 To (nThreads * nRegs)
		If nX <> Val(aRegs[nX])
			lRet	:= .F.
			cObs	:= STR0005 + " register number ("+AllTrim(Str(nX))+") with value ("+aRegs[nX]+") is not continuous "	//"Post-condition failed: "
			Exit
		EndIf
	Next nX
EndIf
//End Post-conditions validation

//Post-script
// 1) Clear global variables
ClearGlbValue("RU09D03T03*")
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T04

Test case 04 - Validate minimum and maximum value

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T04(cObs AS CHARACTER)
Local nX		AS NUMERIC
Local nSize		AS NUMERIC
Local nMin		AS NUMERIC
Local nMax		AS NUMERIC
Local cKey		AS CHARACTER
Local cNum		AS CHARACTER
Local cSerie	AS CHARACTER
Local lRet		AS LOGICAL
Local aSeqs		AS ARRAY

lRet		:= .T.
cKey		:= PADR("1", GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerie		:= PADR("TC4", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
nSize		:= 6
nMin		:= 3
nMax		:= 15

//Pre-conditions
// 1) Numbering entry cKey + cSerie should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerie))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerie+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 2) Record cKey from ON table should exist
If lRet
	SX5->(dbSetorder(1))	//X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(! dbSeek(xFilial("SX5") + "ON" + cKey))
		lRet	:= .F.
		cObs	:= STR0002 + "Register "+cKey+" from ON table dont exist"	//"Pre-condition failed: "
	EndIf
EndIf
//End Pre-conditions

//Setup test case
// 1) Create numbering entry cKey + cSerie
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	oModel:GetModel("F33MASTER"):SetValue("F33_MIN", StrZero(nMin, nSize))
	oModel:GetModel("F33MASTER"):SetValue("F33_MAX", StrZero(nMax, nSize))
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
//End Setup test case

//Execution
// 1) Get number sequence
If lRet
	aSeqs	:= {}
	For nX := nMin to nMax
		aAdd(aSeqs, RU09D03Nmb(cKey, cSerie))
	Next nX
	aAdd(aSeqs, RU09D03Nmb(cKey, cSerie))
EndIf
//End Execution

//Post-conditions validation
// 1) First should equal nMin
lRet	:= lRet .And. TEqualsAssert(@cObs, "current minimum number", Val(aSeqs[1]), nMin)
// 2) Second should equal nMin + 1
lRet	:= lRet .And. TEqualsAssert(@cObs, "current second number", Val(aSeqs[2]), (nMin + 1))
// 3) Pre-last should equal nMax - 1
lRet	:= lRet .And. TEqualsAssert(@cObs, "current previous to last number", Val(aSeqs[Len(aSeqs) - 2]), (nMax - 1))
// 4) Last should equal nMax
lRet	:= lRet .And. TEqualsAssert(@cObs, "current last number", Val(aSeqs[Len(aSeqs) - 1]), nMax)
// 5) Post-last should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "current post-last number", aSeqs[Len(aSeqs)])
//End Post-conditions validation

//Post-script
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T05

Test case 05 - Validate alphanumeric sequences

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T05(cObs AS CHARACTER)
Local nX		AS NUMERIC
Local nSize		AS NUMERIC
Local nMin		AS NUMERIC
Local nMax		AS NUMERIC
Local cKey		AS CHARACTER
Local cNum		AS CHARACTER
Local cSerie	AS CHARACTER
Local lRet		AS LOGICAL
Local aSeqs		AS ARRAY

lRet		:= .T.
cKey		:= PADR("1", GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerie		:= PADR("TC5", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
nSize		:= 6
nMin		:= 1
nMax		:= 100

//Pre-conditions
// 1) Numbering entry cKey + cSerie should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerie))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerie+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 2) Record cKey from ON table should exist
If lRet
	SX5->(dbSetorder(1))	//X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(! dbSeek(xFilial("SX5") + "ON" + cKey))
		lRet	:= .F.
		cObs	:= STR0002 + "Register "+cKey+" from ON table dont exist"	//"Pre-condition failed: "
	EndIf
EndIf
//End Pre-conditions

//Setup test case
// 1) Create numbering entry cKey + cSerie
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	oModel:GetModel("F33MASTER"):SetValue("F33_MAX", PADL("2S", nSize, "0"))
	oModel:GetModel("F33MASTER"):SetValue("F33_ALPHA", "1")
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
//End Setup test case

//Execution
// 1) Get number sequence
If lRet
	aSeqs	:= {}
	For nX := nMin to nMax
		aAdd(aSeqs, RU09D03Nmb(cKey, cSerie))
	Next nX
	aAdd(aSeqs, RU09D03Nmb(cKey, cSerie))
EndIf
//End Execution

//Post-conditions validation
// 1) First should equal 000001
lRet	:= lRet .And. TEqualsAssert(@cObs, "first sequence", aSeqs[1], "000001")
// 2) Second should equal 000002
lRet	:= lRet .And. TEqualsAssert(@cObs, "second sequence", aSeqs[2], "000002")
// 3) 9th should equal 000009
lRet	:= lRet .And. TEqualsAssert(@cObs, "9th sequence", aSeqs[9], "000009")
// 4) 10th should equal 00000A
lRet	:= lRet .And. TEqualsAssert(@cObs, "10th sequence", aSeqs[10], "00000A")
// 5) 35th should equal 00000Z
lRet	:= lRet .And. TEqualsAssert(@cObs, "35th sequence", aSeqs[35], "00000Z")
// 6) 36th should equal 000010
lRet	:= lRet .And. TEqualsAssert(@cObs, "36th sequence", aSeqs[36], "000010")
// 7) 45th should equal 000019
lRet	:= lRet .And. TEqualsAssert(@cObs, "45th sequence", aSeqs[45], "000019")
// 8) 46th should equal 00001A
lRet	:= lRet .And. TEqualsAssert(@cObs, "46th sequence", aSeqs[46], "00001A")
// 9) 71th should equal 00001Z
lRet	:= lRet .And. TEqualsAssert(@cObs, "71th sequence", aSeqs[71], "00001Z")
// 10) 72th should equal 000020
lRet	:= lRet .And. TEqualsAssert(@cObs, "72th sequence", aSeqs[72], "000020")
// 11) Pre-Last should equal 00002R
lRet	:= lRet .And. TEqualsAssert(@cObs, "pre-last sequence", aSeqs[Len(aSeqs) - 2], "00002R")
// 12) Last should equal 00002S
lRet	:= lRet .And. TEqualsAssert(@cObs, "last sequence", aSeqs[Len(aSeqs) - 1], "00002S")
// 13) Pos-Last should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "post-last sequence", aSeqs[Len(aSeqs)])
//End Post-conditions validation

//Post-script
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T06

Test case 06 - Validate prefix and suffix

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T06(cObs AS CHARACTER)
Local nX		AS NUMERIC
Local nSize		AS NUMERIC
Local cKey		AS CHARACTER
Local cSerie	AS CHARACTER
Local cNum		AS CHARACTER
Local cPrefix	AS CHARACTER
Local cSuffix	AS CHARACTER
Local lRet		AS LOGICAL
Local aSeqs		AS ARRAY

lRet		:= .T.
cKey		:= PADR("1", GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerie		:= PADR("TC6", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
nSize		:= 6
cPrefix		:= "PRE-"
cSuffix		:= "-SUF"

//Pre-conditions
// 1) Numbering entry cKey + cSerie should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerie))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerie+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 2) Record cKey from ON table should exist
If lRet
	SX5->(dbSetorder(1))	//X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(! dbSeek(xFilial("SX5") + "ON" + cKey))
		lRet	:= .F.
		cObs	:= STR0002 + "Register "+cKey+" from ON table dont exist"	//"Pre-condition failed: "
	EndIf
EndIf
//End Pre-conditions

//Setup test case
// 1) Create numbering entry cKey + cSerie
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	oModel:GetModel("F33MASTER"):SetValue("F33_PREFIX", cPrefix)
	oModel:GetModel("F33MASTER"):SetValue("F33_SUFFIX", cSuffix)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
//End Setup test case

//Execution
// 1) Get number sequence
If lRet
	cNum	:= RU09D03Nmb(cKey, cSerie)
EndIf
//End Execution

//Post-conditions validation
// 1) cNum should equal cPrefix + 000001 + cSuffix
lRet	:= lRet .And. TEqualsAssert(@cObs, "number", cNum, cPrefix + "000001" + cSuffix)
//End Post-conditions validation

//Post-script
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T07

Test case 07 - Branches

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T07(cObs AS CHARACTER)
Local nX		AS NUMERIC
Local nSize		AS NUMERIC
Local cKey		AS CHARACTER
Local cSerie	AS CHARACTER
Local cBranch1	AS CHARACTER
Local cBranch2	AS CHARACTER
Local cBranch3	AS CHARACTER
Local cNum1		AS CHARACTER
Local cNum2		AS CHARACTER
Local cNum3		AS CHARACTER
Local cNum4		AS CHARACTER
Local lRet		AS LOGICAL

lRet		:= .T.
cKey		:= PADR("1", GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerie		:= PADR("TC7", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
nSize		:= 9
cBranch1	:= PADR("1", Len(xFilial("F33")))
cBranch2	:= PADR("2", Len(xFilial("F33")))
cBranch3	:= PADR("3", Len(xFilial("F33")))

//Pre-conditions
// 1) Numbering entry cKey + cSerie should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerie))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerie+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 2) Record cKey from ON table should exist
If lRet
	SX5->(dbSetorder(1))	//X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(! dbSeek(xFilial("SX5") + "ON" + cKey))
		lRet	:= .F.
		cObs	:= STR0002 + "Register "+cKey+" from ON table dont exist"	//"Pre-condition failed: "
	EndIf
EndIf
//End Pre-conditions

//Setup test case
// 1) Create numbering entry cKey + cSerie
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_FILCTL", F33_FILCTL_EXCLUS)
	oModel:GetModel("F33MASTER"):SetValue("F33_FILUSE", cBranch1)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()

	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_FILCTL", F33_FILCTL_EXCLUS)
	oModel:GetModel("F33MASTER"):SetValue("F33_FILUSE", cBranch2)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()

	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerie)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_FILCTL", F33_FILCTL_SHARED)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
//End Setup test case

//Execution
// 1) Get 10 number sequences for branch 1,
//		5 number sequences for branch 2,
//		1 number sequences for branch 3,
//		7 number sequences for empty branch
If lRet
	For nX := 1 To 10
		If nX <= 10 ; cNum1	:= RU09D03Nmb(cKey, cSerie, cBranch1) ; EndIf
		If nX <= 05 ; cNum2	:= RU09D03Nmb(cKey, cSerie, cBranch2) ; EndIf
		If nX <= 01 ; cNum3	:= RU09D03Nmb(cKey, cSerie, cBranch3) ; EndIf
		If nX <= 07 ; cNum4	:= RU09D03Nmb(cKey, cSerie) ; EndIf
	Next nX
EndIf
//End Execution

//Post-conditions validation
// 1) cNum1 should equal 000000010
lRet	:= lRet .And. TEqualsAssert(@cObs, "number for branch 1", cNum1, "000000010")
// 2) cNum2 should equal 000000005
lRet	:= lRet .And. TEqualsAssert(@cObs, "number for branch 2", cNum2, "000000005")
// 3) cNum3 should equal 000000001
lRet	:= lRet .And. TEqualsAssert(@cObs, "number for branch 3", cNum3, "000000001")
// 4) cNum4 should equal 000000007
lRet	:= lRet .And. TEqualsAssert(@cObs, "number for branch 4", cNum4, "000000008")
//End Post-conditions validation

//Post-script
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T08

Test case 08 - Reseting system

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T08(cObs AS CHARACTER)
Local nX		AS NUMERIC
Local nSize		AS NUMERIC
Local cKey		AS CHARACTER
Local cSerNever	AS CHARACTER
Local cSerYear	AS CHARACTER
Local cSerMonth	AS CHARACTER
Local cSerDay	AS CHARACTER
Local lRet		AS LOGICAL
Local dPrevDate	AS DATE
Local aSeqNever	AS ARRAY
Local aSeqYear	AS ARRAY
Local aSeqMonth	AS ARRAY
Local aSeqDay	AS ARRAY

lRet		:= .T.
cKey		:= PADR("1", GetSX3Cache("F33_KEY", "X3_TAMANHO"))
cSerNever	:= PADR("TC8N", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
cSerYear	:= PADR("TC8Y", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
cSerMonth	:= PADR("TC8M", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
cSerDay		:= PADR("TC8D", GetSX3Cache("F33_SERIE", "X3_TAMANHO"))
nSize		:= 4
dPrevDate	:= dDataBase

//Pre-conditions
// 1) Numbering entry cKey + cSerNever should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerNever))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerNever+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 2) Numbering entry cKey + cSerYear should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerYear))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerYear+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 3) Numbering entry cKey + cSerMonth should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerMonth))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerMonth+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 4) Numbering entry cKey + cSerDay should not exist
If lRet
	F33->(dbSetorder(3))	//F33_FILIAL+F33_KEY+F33_SERIE+F33_STATUS+F33_FILCTL+F33_FILUSE
	If F33->(dbSeek(xFilial("F33") + cKey + cSerDay))
		lRet	:= .F.
		cObs	:= STR0002 + "Numbering control "+cKey+"/"+cSerDay+" already exists"	//"Pre-condition failed: "
	EndIf
EndIf
// 5) Record cKey from ON table should exist
If lRet
	SX5->(dbSetorder(1))	//X5_FILIAL+X5_TABELA+X5_CHAVE
	If SX5->(! dbSeek(xFilial("SX5") + "ON" + cKey))
		lRet	:= .F.
		cObs	:= STR0002 + "Register "+cKey+" from ON table dont exist"	//"Pre-condition failed: "
	EndIf
EndIf
//End Pre-conditions

//Setup test case
// 1) Setup system variables
If lRet
	dDataBase	:= SToD("20170115")
EndIf
// 2) Create numbering entry cKey + cSerNever
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerNever)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	oModel:GetModel("F33MASTER"):SetValue("F33_RESTAR", F33_RESTAR_NEVER)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
// 3) Create numbering entry cKey + cSerYear
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerYear)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	oModel:GetModel("F33MASTER"):SetValue("F33_RESTAR", F33_RESTAR_YEAR)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
// 4) Create numbering entry cKey + cSerMonth
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerMonth)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	oModel:GetModel("F33MASTER"):SetValue("F33_RESTAR", F33_RESTAR_MONTH)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
// 5) Create numbering entry cKey + cSerDay
If lRet
	oModel	:= FWLoadModel("RU09D03")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:GetModel("F33MASTER"):SetValue("F33_KEY", cKey)
	oModel:GetModel("F33MASTER"):SetValue("F33_SERIE", cSerDay)
	oModel:GetModel("F33MASTER"):SetValue("F33_STATUS", F33_STATUS_ACTIVE)
	oModel:GetModel("F33MASTER"):SetValue("F33_SIZE", nSize)
	oModel:GetModel("F33MASTER"):SetValue("F33_RESTAR", F33_RESTAR_DAILY)
	If ! oModel:VldData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model validation failed"	//"Setup failed: "
	ElseIf ! oModel:CommitData()
		lRet	:= .F.
		cObs	:= STR0003 + "Model commit failed"	//"Setup failed: "
	EndIf
	oModel:DeActivate()
EndIf
//End Setup test case

//Execution
// 1) Get 600 number sequences for all sequences
If lRet
	aSeqNever	:= {}
	aSeqYear	:= {}
	aSeqMonth	:= {}
	aSeqDay		:= {}
	For nX := 1 To 600
		aAdd(aSeqNever, RU09D03Nmb(cKey, cSerNever))
		aAdd(aSeqYear, RU09D03Nmb(cKey, cSerYear))
		aAdd(aSeqMonth, RU09D03Nmb(cKey, cSerMonth))
		aAdd(aSeqDay, RU09D03Nmb(cKey, cSerDay))
		dDataBase++
	Next nX
	dDataBase--
	aAdd(aSeqDay, RU09D03Nmb(cKey, cSerDay))
EndIf
//End Execution

//Post-conditions validation
// 1) Never reseting sequential 1st should be 0001
lRet	:= lRet .And. TEqualsAssert(@cObs, "Never reseting sequential 1st", aSeqNever[001], "0001")
// 2) Yearly reseting sequential 1st should be 0001
lRet	:= lRet .And. TEqualsAssert(@cObs, "Yearly reseting sequential 1st", aSeqYear[001], "0001")
// 3) Monthly reseting sequential 1st should be 0001
lRet	:= lRet .And. TEqualsAssert(@cObs, "Monthly reseting sequential 1st", aSeqMonth[001], "0001")
// 4) Daily reseting sequential 1st should be 0001
lRet	:= lRet .And. TEqualsAssert(@cObs, "Daily reseting sequential 1st", aSeqDay[001], "0001")
// 5) Never reseting sequential 2nd should be 0002
lRet	:= lRet .And. TEqualsAssert(@cObs, "Never reseting sequential 2nd", aSeqNever[002], "0002")
// 6) Yearly reseting sequential 2nd should be 0002
lRet	:= lRet .And. TEqualsAssert(@cObs, "Yearly reseting sequential 2nd", aSeqYear[002], "0002")
// 7) Monthly reseting sequential 2nd should be 0002
lRet	:= lRet .And. TEqualsAssert(@cObs, "Monthly reseting sequential 2nd", aSeqMonth[002], "0002")
// 8) Daily reseting sequential 2nd should be 0001
lRet	:= lRet .And. TEqualsAssert(@cObs, "Daily reseting sequential 2nd", aSeqDay[002], "0001")
// 9) Never reseting sequential 18th should be 0018
lRet	:= lRet .And. TEqualsAssert(@cObs, "Never reseting sequential 18th", aSeqNever[018], "0018")
// 10) Yearly reseting sequential 18th should be 0018
lRet	:= lRet .And. TEqualsAssert(@cObs, "Yearly reseting sequential 18th", aSeqYear[018], "0018")
// 11) Monthly reseting sequential 18th should be 0001
lRet	:= lRet .And. TEqualsAssert(@cObs, "Monthly reseting sequential 18th", aSeqMonth[018], "0001")
// 12) Never reseting sequential 352th should be 0352
lRet	:= lRet .And. TEqualsAssert(@cObs, "Never reseting sequential 352th", aSeqNever[352], "0352")
// 13) Yearly reseting sequential 352th should be 0001
lRet	:= lRet .And. TEqualsAssert(@cObs, "Yearly reseting sequential 352th", aSeqYear[352], "0001")
// 14) Never reseting sequential 600th should be 0600
lRet	:= lRet .And. TEqualsAssert(@cObs, "Never reseting sequential 600th", aSeqNever[600], "0600")
// 15) Yearly reseting sequential 600th should be 0249
lRet	:= lRet .And. TEqualsAssert(@cObs, "Yearly reseting sequential 600th", aSeqYear[600], "0249")
// 16) Monthly reseting sequential 600th should be 0006
lRet	:= lRet .And. TEqualsAssert(@cObs, "Monthly reseting sequential 600th", aSeqMonth[600], "0006")
// 17) Daily reseting sequential 601th should be 0002
lRet	:= lRet .And. TEqualsAssert(@cObs, "Daily reseting sequential 601th", aSeqDay[601], "0002")
//End Post-conditions validation

//Post-script
dDataBase	:= dPrevDate
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T09

Test case 09 - Rendering

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T09(cObs AS CHARACTER)
Local cRender	AS CHARACTER
Local lRet		AS LOGICAL
Local aRender	AS ARRAY

lRet		:= .T.

//Pre-conditions
//End Pre-conditions

//Setup test case
//End Setup test case

//Execution
If lRet
	aRender	:= {}
	cRender	:= RU09D03_RD( ;
		"" 			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"001500" 	/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"      " 	/* F33_MIN */, ;
		"ZZZZZZ" 	/* F33_MAX */, ;
		"" 			/* F33_PREFIX */, ;
		"" 			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 1
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"" 			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"001500" 	/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"      " 	/* F33_MIN */, ;
		"001500" 	/* F33_MAX */, ;
		"" 			/* F33_PREFIX */, ;
		"" 			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 2
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"" 			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"001500" 	/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"      " 	/* F33_MIN */, ;
		"ZZZZZZ" 	/* F33_MAX */, ;
		"XXX"		/* F33_PREFIX */, ;
		"YYY"		/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 3
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"0"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"1"		 	/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"" 			/* F33_MIN */, ;
		"" 			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 4
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"0"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"999999" 	/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"" 			/* F33_MIN */, ;
		"" 			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 5
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"0"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"9999999" 	/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"" 			/* F33_MIN */, ;
		"" 			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 6
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"0"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"Z" 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"" 			/* F33_MIN */, ;
		"" 			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 7
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"0"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"0A" 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"" 			/* F33_MIN */, ;
		"" 			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 8
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"10" 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"" 			/* F33_MIN */, ;
		"000011"	/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 9
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"Z" 		/* F33_ACTSEQ */, ;
		"1" 		/* F33_ALPHA */, ;
		"" 			/* F33_MIN */, ;
		""			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 10
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"Z" 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"" 			/* F33_MIN */, ;
		""			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 11
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"2" 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"1"			/* F33_MIN */, ;
		"1"			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 12
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"2" 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		"2"			/* F33_MIN */, ;
		"2"			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 13
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"0"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		"G" 		/* F33_ACTSEQ */, ;
		"1" 		/* F33_ALPHA */, ;
		"0"			/* F33_MIN */, ;
		"Z"			/* F33_MAX */, ;
		""			/* F33_PREFIX */, ;
		""			/* F33_SUFFIX */, ;
		F33_DATEP_NO		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 14
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		""	 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		""			/* F33_MIN */, ;
		""			/* F33_MAX */, ;
		"-PR-"		/* F33_PREFIX */, ;
		"-SF"		/* F33_SUFFIX */, ;
		F33_DATEP_YES	/* F33_DATEP */, ;
		F33_RESTAR_YEAR	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 15
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		""	 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		""			/* F33_MIN */, ;
		""			/* F33_MAX */, ;
		"-PR-"		/* F33_PREFIX */, ;
		"-SF"		/* F33_SUFFIX */, ;
		F33_DATEP_YES		/* F33_DATEP */, ;
		F33_RESTAR_MONTH	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 16
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		""	 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		""			/* F33_MIN */, ;
		""			/* F33_MAX */, ;
		"-PR-"		/* F33_PREFIX */, ;
		"-SF"		/* F33_SUFFIX */, ;
		F33_DATEP_YES		/* F33_DATEP */, ;
		F33_RESTAR_NEVER	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 17
	aAdd(aRender, cRender)
	cRender	:= RU09D03_RD( ;
		"1"			/* F33_LEADCH */, ;
		6 			/* F33_SIZE */, ;
		""	 		/* F33_ACTSEQ */, ;
		"2" 		/* F33_ALPHA */, ;
		""			/* F33_MIN */, ;
		""			/* F33_MAX */, ;
		"-PR-"		/* F33_PREFIX */, ;
		"-SF"		/* F33_SUFFIX */, ;
		F33_DATEP_YES		/* F33_DATEP */, ;
		F33_RESTAR_DAILY	/* F33_RESTAR */, ;
		"" 			/* cSeq */)	//Renderization 18
	aAdd(aRender, cRender)
EndIf
//End Execution

//Post-conditions validation
// 1) Renderization example 1 should be 001501
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 1", aRender[01], "001501")
// 2) Renderization example 2 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Renderization 2", aRender[02])
// 3) Renderization example 3 should be 001501
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 3", aRender[03], "XXX001501YYY")
// 4) Renderization example 4 should be 2
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 4", aRender[04], "2")
// 5) Renderization example 5 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Renderization 5", aRender[05])
// 6) Renderization example 6 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Renderization 6", aRender[06])
// 7) Renderization example 7 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Renderization 7", aRender[07])
// 8) Renderization example 8 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Renderization 8", aRender[08])
// 9) Renderization example 9 should be 000011
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 9", aRender[09], "000011")
// 10) Renderization example 10 should be 000010
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 10", aRender[10], "000010")
// 11) Renderization example 11 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Renderization 11", aRender[11])
// 12) Renderization example 12 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Renderization 12", aRender[12])
// 13) Renderization example 13 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Renderization 13", aRender[13])
// 14) Renderization example 14 should be H
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 14", aRender[14], "H")
// 15) Renderization example 15 should be [year]-PR-000001-SF
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 15", aRender[15], SubStr(DToS(dDataBase), 1, 4) + "-PR-000001-SF")
// 16) Renderization example 16 should be [year][month]-PR-000001-SF
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 16", aRender[16], SubStr(DToS(dDataBase), 1, 6) + "-PR-000001-SF")
// 17) Renderization example 17 should be [year][month][day]-PR-000001-SF
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 17", aRender[17], DToS(dDataBase) + "-PR-000001-SF")
// 18) Renderization example 18 should be [year][month][day]-PR-000001-SF
lRet	:= lRet .And. TEqualsAssert(@cObs, "Renderization 18", aRender[18], DToS(dDataBase) + "-PR-000001-SF")
//End Post-conditions validation

//Post-script
//End Post-script

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09D03T10

Test case 09 - Rendering

@param		CHARACTER cObs
@return		LOGICAL lRet
@author 	victor.rezende
@since 		07/12/2017
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU09D03T10(cObs AS CHARACTER)
Local cRender	AS CHARACTER
Local lRet		AS LOGICAL
Local aIncs		AS ARRAY

lRet		:= .T.

//Pre-conditions
//End Pre-conditions

//Setup test case
//End Setup test case

//Execution
If lRet
	aIncs	:= {}
	aAdd(aIncs, RU01INCCHR("000001", .F.))	// Case 01
	aAdd(aIncs, RU01INCCHR("999999", .F.))	// Case 02
	aAdd(aIncs, RU01INCCHR("000009", .T.))	// Case 03
	aAdd(aIncs, RU01INCCHR("0000ZZ", .T.))	// Case 04
	aAdd(aIncs, RU01INCCHR("ZZZZZZ", .T.))	// Case 05
	aAdd(aIncs, RU01INCCHR("Z", .T.))	// Case 06
	aAdd(aIncs, RU01INCCHR("Y", .T.))	// Case 07
EndIf
//End Execution

//Post-conditions validation
// 1) Case 01 should be 000002
lRet	:= lRet .And. TEqualsAssert(@cObs, "Case 01", aIncs[01], "000002")
// 2) Case 02 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Case 02", aIncs[02])
// 3) Case 03 should be 00000A
lRet	:= lRet .And. TEqualsAssert(@cObs, "Case 03", aIncs[03], "00000A")
// 4) Case 04 should be 000100
lRet	:= lRet .And. TEqualsAssert(@cObs, "Case 04", aIncs[04], "000100")
// 5) Case 05 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Case 05", aIncs[05])
// 6) Case 06 should be empty
lRet	:= lRet .And. TEmptyAssert(@cObs, "Case 06", aIncs[06])
// 7) Case 07 should be Z
lRet	:= lRet .And. TEqualsAssert(@cObs, "Case 07", aIncs[07], "Z")
//End Post-conditions validation

//Post-script
//End Post-script

Return lRet


// Russia_R5
