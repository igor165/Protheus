#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01T02RUS.CH'

#define RU01T02_OPER_UNDEFINED			0
#define RU01T02_OPER_CONSERVATION		1
#define RU01T02_OPER_DESCONSERVATION	2
#define RU01T02_OPER_HISTORY			3
#define RU01T02_OPER_STORNO				4

#define F44_DEPREC_IMPACT			"1"
#define F44_STATUS_NOT_CONFIRMED    "0"
#define F44_STATUS_CONFIRMED        "1"
#define F44_STATUS_STORNOED         "2"
#define F44_TYPE_CONSERVATION		"1"
#define F44_TYPE_DESCONSERVATION	"2"
#define F44_TYPE_VIRTUAL_DEPREC		"D"
#define N1_STATUS_OPERATION			"1"
#define N1_STATUS_CONSERVATION		"5"

#define RU01T02_N1_FIELDS_HISTORY		"N1_FILIAL|N1_CBASE|N1_ITEM|N1_STATUS|N1_DESCRIC"
#define RU01T02_F44_FIELDS_HISTORY_MOD	"F44_FILIAL|F44_CODE|F44_TYPE|F44_DATE|F44_TYPE|F44_WHO|F44_DEPREC|F44_STATUS|F44_UUID"
#define RU01T02_F44_FIELDS_HISTORY_VIEW	"F44_FILIAL|F44_DATE|F44_TYPE|F44_WHO|F44_DEPREC|F44_STATUS"

/*/{Protheus.doc} RU01T02RUS

According to Russian legislation in the case of conservation of a fixed
asset for more than 3 months or for modernization for more than 12 months
depreciation calculation on it is suspended. After the repair work status
of conservation is removed. Depreciation for the period of conservation
is not performed.

@param		None
@return		None
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
Function RU01T02RUS()
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Define the menu for the browse

@param		None
@return		None
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef() 
Return {}

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Model definition

@param		None
@return		None
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local aRelat	AS ARRAY
Local oStruSN1	AS OBJECT
Local oStruF44	AS OBJECT
Local oModel	AS OBJECT

If GetOperation() == RU01T02_OPER_HISTORY
	oStruSN1	:= FWFormStruct(1, "SN1", {|x| AllTrim(x) $ RU01T02_N1_FIELDS_HISTORY})
	oStruF44	:= FWFormStruct(1, "F44", {|x| AllTrim(x) $ RU01T02_F44_FIELDS_HISTORY_MOD})
	oModel		:= MPFormModel():New("RU01T02", /* Pre-valid */, /* Pos-Valid */, /* Commit */)
	oModel:AddFields("SN1MASTER", /*cOwner*/, oStruSN1)
	oModel:AddGrid("F44DETAIL", "SN1MASTER", oStruF44, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
	aRelat	:= {}
	aAdd(aRelat, {"F44_FILIAL", "XFILIAL('F44')"})
	aAdd(aRelat, {"F44_CBASE", "N1_CBASE"})
	aAdd(aRelat, {"F44_ITEM", "N1_ITEM"})
	oModel:SetRelation("F44DETAIL", aRelat, F44->(IndexKey(2)))	//F44_FILIAL+F44_CBASE+F44_ITEM+F44_CODE+F44_TYPE
	oModel:SetDescription(STR0001) // "Fixed Asset Conservation"
	oModel:GetModel("SN1MASTER"):SetDescription(STR0002) // "Fixed Asset Details"
	oModel:GetModel("F44DETAIL"):SetDescription(STR0003) // "Operation Details"
	oModel:GetModel("F44DETAIL"):SetOptional(.T.)
	oModel:GetModel("F44DETAIL"):SetNoInsertLine(.T.)
Else
	oStruF44	:= FWFormStruct(1, "F44")
	oModel		:= MPFormModel():New("RU01T02", /* Pre-valid */, /* Pos-Valid */, /* Commit */)
	oModel:AddFields("F44MASTER", /*cOwner*/, oStruF44)
	oModel:SetDescription(STR0001) // "Fixed Asset Conservation"
	oModel:GetModel("F44MASTER"):SetDescription(STR0003) // "Operation Details"
EndIf

Return oModel


//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

View definition

@param		None
@return		None
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oModel	AS OBJECT
Local oStruSN1	AS OBJECT
Local oStruF44	AS OBJECT
Local oView		AS OBJECT

oModel		:= FWLoadModel("RU01T02")
If GetOperation() == RU01T02_OPER_HISTORY
	oStruSN1	:= FWFormStruct(2, "SN1", {|x| AllTrim(x) $ RU01T02_N1_FIELDS_HISTORY})
	oStruF44	:= FWFormStruct(2, "F44", {|x| AllTrim(x) $ RU01T02_F44_FIELDS_HISTORY_VIEW})
	oView		:= FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SN1", oStruSN1, "SN1MASTER")
	oView:AddGrid("VIEW_F44", oStruF44, "F44DETAIL")
	oView:CreateHorizontalBox("MAIN", 40)
	oView:CreateHorizontalBox("GRID", 60)
	oView:SetOwnerView("VIEW_SN1", "MAIN")
	oView:SetOwnerView("VIEW_F44", "GRID")
	oView:addUserButton(STR0020 /*< cTitle >*/, "OK" /*< cResource >*/, {|| RU01T02I("S")} /*< bBloco >*/, /*[ cToolTip ]*/, /*[ nShortCut ]*/, /*[ aOptions ]*/, .T. /*[ lShowBar ]*/)	// "Storno"
Else
	oStruF44	:= FWFormStruct(2, "F44")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_F44", oStruF44, "F44MASTER")
	oView:CreateHorizontalBox("MAIN", 100)
	oView:SetOwnerView("VIEW_F44", "MAIN")
EndIf

Return oView


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02I

Visual interface to handle conservation call.

Fixed asset (SN1) should be positioned.

@param		CHARACTER cOper C-Conservation,D-Desconservation,H-History,S-Storno
@return		None
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T02I(cOper AS CHARACTER)
Local nOpAnt		AS NUMERIC
Local cTitle		AS CHARACTER
Local cDescr		AS CHARACTER
Local aArea			AS ARRAY
Local aAreaSN1		AS ARRAY
Local aAreaF44		AS ARRAY
Local oModel		AS OBJECT
Local oModelGrd		AS OBJECT
Private cPerg		AS CHARACTER

aArea		:= GetArea()
aAreaSN1	:= SN1->(GetArea())
aAreaF44	:= F44->(GetArea())

If Type("nR01T02Op") <> "U"
	nOpAnt	:= nR01T02Op
EndIf

Private nR01T02Op	AS NUMERIC

nR01T02Op	:= RU01T02_OPER_UNDEFINED
If cOper == "C"
	nR01T02Op	:= RU01T02_OPER_CONSERVATION
ElseIf cOper == "D"
	nR01T02Op	:= RU01T02_OPER_DESCONSERVATION
ElseIf cOper == "H"
	nR01T02Op	:= RU01T02_OPER_HISTORY
ElseIf cOper == "S"
	nR01T02Op	:= RU01T02_OPER_STORNO
EndIf

If GetOperation() == RU01T02_OPER_CONSERVATION .Or. GetOperation() == RU01T02_OPER_DESCONSERVATION
	cTitle	:= IIf(GetOperation() == RU01T02_OPER_CONSERVATION, STR0004, STR0005)	// "Conservation of fixed assets", "Desconservation of fixed assets"
	cDescr	:= IIf(GetOperation() == RU01T02_OPER_CONSERVATION, STR0006, STR0007)	// "Sets conservation parametrization for fixed assets", "Sets desconservation parametrization for fixed assets"
	cPerg	:= PADR( "RU01T2CONS", LEN(SX1->X1_GRUPO) )
	Pergunte(cPerg,.F.)
	tNewProcess():New( "RU01T02I", cTitle, {|oSelf| RU01T02P( cOper, oSelf ) }, cDescr, cPerg,,,,,, .T. )
ElseIf GetOperation() == RU01T02_OPER_HISTORY
	SN1->(dbSetOrder(1))	//N1_FILIAL+N1_CBASE+N1_ITEM
	F44->(dbSetOrder(2))	//F44_FILIAL+F44_CBASE+F44_ITEM+F44_CODE+F44_TYPE
	If F44->(! dbSeek(xFilial("F44")+SN1->(N1_CBASE+N1_ITEM)))
		Help(" ",1,"REGNOIS")
	Else
    	dbSelectArea("SN1")
    	FWExecView(STR0021, "RU01T02", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, /* [ bCancel ] */, /* [ cOperatId ] */, /* [ cToolBar ] */, /* [ oModel ] */)	// "History of Movements"
	EndIf
ElseIf GetOperation() == RU01T02_OPER_STORNO
	RU01T02STO()
EndIf

If ! Empty(nOpAnt)
	nR01T02Op	:= nOpAnt
EndIf

RestArea(aAreaF44)
RestArea(aAreaSN1)
RestArea(aArea)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02P

Performs the defined operation on the positioned fixed asset.

@param		cOper = "C" for conservation, "D" for desconservation
@param		oSelf = tNewProcess object
@return		LOGICAL
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T02P(cOper AS CHARACTER, oSelf AS OBJECT)
Local cMsg					AS CHARACTER
Local cCode					AS CHARACTER
Local dDtProc				AS DATE
Local lImpactDepreciation	AS LOGICAL
Local cImpactDepreciation	AS CHARACTER
Local oModel				AS OBJECT
Local aArea				    AS ARRAY
Local aAreaF44				AS ARRAY
Local lXe					AS LOGICAL
Local lRet					AS LOGICAL

dDtProc				:=	dDataBase
lImpactDepreciation	:=	MV_PAR01 == 1
lXe					:=	.F.
lRet				:=	.T.

//Check the eligibility of the fixed asset for the requested operation
If ! RU01T02V(cOper, dDtProc, @cMsg)
	RU01T02MSG(cMsg, oSelf)
	lRet:=.F.
EndIf
If lRet
	If ValType(oSelf) == "O"
		oSelf:SetRegua1(2)
		oSelf:IncRegua1()
	EndIf

	If cOper == "C"
		cCode				:= GETSXENUM("F44", "F44_CODE", , 1)
		cImpactDepreciation	:= IIf(lImpactDepreciation, "1", "2")
		lXe:=.T.
	Else
		cCode				:= RU01T02DDD(dDtProc)
		If Empty(cCode)
			RU01T02MSG(STR0008, oSelf) // "Error inserting the register"
			lRet:=.F.
		EndIf	
		aArea		:= GetArea()
		aAreaF44	:= F44->(GetArea())	
		cCode				:= F44->F44_CODE
		cImpactDepreciation	:= F44->F44_DEPREC
		dbSelectArea("F44")	
		F44->(dbSetOrder(1))	//F44_FILIAL+F44_CBASE+F44_ITEM+F44_CODE+F44_TYPE
		If F44->(dbSeek(xFilial("F44")+cCode+"2"))
			cCode:= GETSXENUM("F44", "F44_CODE", , 1)
			lXe:=.T.
		Endif 
		RestArea(aAreaF44)
		RestArea(aArea)
	EndIf
EndIf
If lRet
	oModel	:= FWLoadModel("RU01T02")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	If ! oModel:Activate()
		RU01T02MSG(STR0008, oSelf) // "Error inserting the register"
		lRet:=.F.
	EndIf
EndIf
If lRet
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_FILIAL"	, SN1->N1_FILIAL)
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_CODE"		, cCode)
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_DATE"		, dDtProc)
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_TYPE"		, IIf(cOper == "C", "1", "2"))
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_CBASE"	, SN1->N1_CBASE)
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_ITEM"		, SN1->N1_ITEM)
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_DEPREC"	, cImpactDepreciation)
	lRet	:=	lRet .AND.	oModel:LoadValue("F44MASTER", "F44_STATUS"	, F44_STATUS_CONFIRMED)
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_WHO"		, RetCodUsr())
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_TIME"		, SubStr(TIME(), 1, GetSX3Cache("F44_TIME", "X3_TAMANHO")))
	lRet	:=	lRet .AND.	oModel:SetValue("F44MASTER", "F44_LA"		, "N")
EndIf
If lRet
	If ! oModel:VldData()
		RU01MVCERR(oModel)
		RU01T02MSG(STR0009, oSelf) // "Error validating the data"
		lRet:=.F.
	ElseIf ! oModel:CommitData()
		RU01T02MSG(STR0008, oSelf) // "Error inserting the register"
		lRet:=.F.
	EndIf
EndIf
If lRet
	If lXe
		ConfirmSX8()
	EndIf
	lRet    := FWFormCommit(oModel)
	RU01RULES(SN1->N1_CBASE,SN1->N1_ITEM)	//(19/06/18): Change status of Fixed Asset
EndIf
if lRet
	F44->(dbSetOrder(1))	//F44_FILIAL+F44_CODE+F44_TYPE
	If F44->(dbSeek(SN1->N1_FILIAL + cCode + IIf(cOper == "C", "1", "2")))
		RU01T02STE(IIf(cOper == "C", "8A6", "8A7"))
	EndIf
EndIf
If lRet
	If ValType(oSelf) == "O"
		oSelf:IncRegua1()
EndIf

RU01T02MSG(STR0010, oSelf)	// "The requested operation was executed successfully"
Endif
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02STO

Performs storno operation

@param		None
@return		LOGICAL lRet
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T02STO()
Local nX			AS NUMERIC
Local nRecF44		AS NUMERIC
Local nRecSN1		AS NUMERIC
Local cLineGrid		AS NUMERIC
Local nTotal		AS NUMERIC
Local nHdlPrv		AS NUMERIC
Local cQuery		AS CHARACTER
Local cAlsTmp		AS CHARACTER
Local cStatusFA		AS CHARACTER
Local cStdEntry		AS CHARACTER
Local cFile			AS CHARACTER
Local cFALot		AS CHARACTER
Local cF44Code		AS CHARACTER
Local cF44Type		AS CHARACTER
Local cF44UUID		AS CHARACTER
Local lRet			AS LOGICAL
Local lFlagCTB		AS LOGICAL
Local aArea			AS ARRAY
Local aAreaF44		AS ARRAY
Local aFlagCTB		AS ARRAY
Local aF44LA		AS ARRAY
Local oModel		AS OBJECT
Local oModelGrd		AS OBJECT
Local oMdl012		AS OBJECT
Local oMdlT02		AS OBJECT
Local oView			AS OBJECT
Local oGridObj		AS OBJECT

aArea		:= GetArea()
aAreaF44	:= F44->(GetArea())

lRet		:= .T.
oModel		:= FWModelActive()
oModelGrd	:= oModel:GetModel("F44DETAIL")
cLineGrid	:= oModelGrd:GetLine()

// Set F44 key variables
If lRet
	cF44Code	:= oModelGrd:GetValue("F44_CODE")
	cF44Type	:= oModelGrd:GetValue("F44_TYPE")
	cF44UUID	:= oModelGrd:GetValue("F44_UUID")
	lRet		:= cF44Type $ F44_TYPE_CONSERVATION + F44_TYPE_DESCONSERVATION
	If ! lRet
		Help("",1,"RU01T02STTP",,STR0022,1,0)	// "Storno operation must be performed on either conservation or desconservation register"
	EndIf
EndIf

// Position F44 register
If lRet
	F44->(dbSetOrder(1))	//F44_FILIAL+F44_CODE+F44_TYPE+F44_UUID
	lRet	:= F44->(dbSeek(xFilial("F44")+cF44Code+cF44Type+cF44UUID))
	nRecF44	:= F44->(Recno())
	If ! lRet
		Help("",1,"RU01T02STCD",,STR0023,1,0)	// "Could not find original operation record for storno"
	EndIf
EndIf

// Validate status of F44 register
If lRet
	lRet	:= F44->F44_STATUS == F44_STATUS_CONFIRMED
	If ! lRet
		Help("",1,"RU01T02STSO",,STR0029,1,0)	// "Status of the original conservation register must be confirmed"
	EndIf
EndIf

// Position SN1 registers
If lRet
	SN1->(dbSetOrder(1))	//N1_FILIAL+N1_CBASE+N1_ITEM
	lRet	:= SN1->(dbSeek(xFilial("SN1")+F44->F44_CBASE+F44->F44_ITEM))
	nRecSN1	:= SN1->(Recno())
	If ! lRet
		Help("",1,"RU01T02STFA",,STR0026,1,0)	// "Could not find fixed asset record for storno"
	EndIf
EndIf

// Validate date of storno
If lRet
	lRet	:= Year(dDataBase) == Year(F44->F44_DATE) .And. Month(dDataBase) == Month(F44->F44_DATE)
	If ! lRet
		Help("",1,"RU01T02STVD",,STR0024,1,0)	// "The storno operation must be performed on the same month of original operation"
	EndIf
EndIf

// Validate if any posterior operation exists for current fixed asset
If lRet
	cQuery	:= " SELECT R_E_C_N_O_ AS N4REC "
	cQuery	+= "   FROM "+RetSqlName("SN4")+" SN4 "
	cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND N4_FILIAL = '"+xFilial("SN4")+"' "
	cQuery	+= "    AND N4_CBASE = '"+F44->F44_CBASE+"' "
	cQuery	+= "    AND N4_ITEM = '"+F44->F44_ITEM+"' "
	cQuery	+= "    AND N4_DATA > '"+DToS(F44->F44_DATE)+"' "
	cQuery:=ChangeQuery(cQuery)
	cAlsTmp	:= RU01GETALS(cQuery)
	lRet	:= (cAlsTmp)->(EOF())
	(cAlsTmp)->(dbCloseArea())

	If ! lRet
		Help("",1,"RU01T02STN4",,STR0025,1,0)	// "Storno operation is not permitted for fixed assets that have posterior movements"
	EndIf
EndIf

If lRet
	lRet	:= IsBlind() .Or. MsgYesNo(STR0028 + AllTrim(SN1->N1_CBASE) + "-" + AllTrim(SN1->N1_ITEM) + "?")	// "Confirm storno operation for fixed asset "
EndIf

// Execute the operation
If lRet
	BEGIN TRANSACTION
		// Flag F44 as stornoed
		If lRet
			F44->(dbGoTo(nRecF44))
			SN1->(dbGoTo(nRecSN1))
			oMdlT02     := FWLoadModel("RU01T02")
            oMdlT02:SetOperation(MODEL_OPERATION_UPDATE)
            oMdlT02:Activate()
			oMdlT02:GetModel("F44MASTER"):LoadValue("F44_STATUS", F44_STATUS_STORNOED)
			lRet    := FWFormCommit(oMdlT02)
            If ! lRet
                RU01MVCERR(oMdlT02)
                DisarmTransaction()
            EndIf
			oMdlT02:DeActivate()
			RU01RULES(SN1->N1_CBASE,SN1->N1_ITEM)	//(19/06/18): Change status of Fixed Asset
		EndIf
	END TRANSACTION
	F44->(dbGoTo(nRecF44))
	SN1->(dbGoTo(nRecSN1))
	oModel:Activate()
	oModelGrd	:= oModel:GetModel("F44DETAIL")
	If lRet .And. ! IsBlind()
		oModelGrd:GoLine(cLineGrid)
		oModelGrd:LoadValue("F44_STATUS", F44_STATUS_STORNOED)
		oView			:= FWViewActive()
		oGridObj		:= oView:GetViewObj("VIEW_F44")[3]
		oGridObj:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
	EndIf
EndIf

// Process standard entry
If lRet
	F44->(dbGoTo(nRecF44))

	If F44->F44_TYPE == F44_TYPE_CONSERVATION
		cStdEntry	:= "8A8"
	Else
		cStdEntry	:= "8A9"
	EndIf

	RU01T02STE(cStdEntry)
EndIf

If lRet
    MsgInfo(STR0027)	// "Record successfully stornoed"
EndIf

RestArea(aAreaF44)
RestArea(aArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02STE

Executes the standard entries process for the positioned F44

@param		CHARACTER cStdEntry
@return		LOGICAL
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T02STE(cStdEntry AS CHARACTER)
Local cQuery		AS CHARACTER
Local cAlsTmp		AS CHARACTER
Local lDisplay		AS LOGICAL
Local lGroup		AS LOGICAL
Local lOffline		AS LOGICAL
Local lRet			AS LOGICAL
Local aRegisters	AS ARRAY
Local aTmp			AS ARRAY

cQuery	:= "   SELECT SN1.R_E_C_N_O_ AS SN1RECNO, "
cQuery	+= "          SN3.R_E_C_N_O_ AS SN3RECNO "
cQuery	+= "     FROM "+RetSqlName("SN1")+" SN1  "
cQuery	+= "     JOIN "+RetSqlName("SN3")+" SN3 ON N3_CBASE = N1_CBASE AND N3_ITEM = N1_ITEM "
cQuery	+= "    WHERE SN1.D_E_L_E_T_ = ' ' "
cQuery	+= "      AND SN3.D_E_L_E_T_ = ' ' "
cQuery	+= "      AND N1_FILIAL = '"+xFilial("SN1")+"' "
cQuery	+= "      AND N3_FILIAL = '"+xFilial("SN3")+"' "
cQuery	+= "      AND N1_CBASE = '"+F44->F44_CBASE+"' "
cQuery	+= "      AND N1_ITEM = '"+F44->F44_ITEM+"' "
cQuery	+= "      AND N3_OPER = '1'"
cQuery	+= " ORDER BY N3_CBASE, N3_ITEM, N3_TIPO, N3_SEQ "
aRegisters  := {}
cQuery:=ChangeQuery(cQuery)
cAlsTmp     := RU01GETALS(cQuery)
While (cAlsTmp)->(! EOF())
    aTmp    := {}
    aAdd(aTmp, {"F44", F44->(Recno())})
    aAdd(aTmp, {"SN1", (cAlsTmp)->SN1RECNO})
    aAdd(aTmp, {"SN3", (cAlsTmp)->SN3RECNO})
    aAdd(aRegisters, aTmp)
    (cAlsTmp)->(dbSkip())
EndDo
(cAlsTmp)->(dbCloseArea())

lDisplay    := Nil
lGroup      := Nil
lOffline    := Nil
If Pergunte("AFA012", .F.)
    lDisplay    := (MV_PAR01 == 1)
    lGroup      := (MV_PAR06 == 1)
EndIf

lRet    := RU0134STEN(;
    cStdEntry,;
    "RU01T02" /* cRoutine */,;
    "F44" /* cBaseAlias */,;
    aRegisters,;
    lDisplay,;
    lGroup,;
    lOffline)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02V

Validate if the positioned fixed asset is eligible for the requested
operation.

@param		cOper = "C" for conservation, "D" for desconservation
@param		dDtProc = Date of the event
@param		cMsg = Error message will be outputed to this variable
@return		LOGICAL
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T02V(cOper AS CHARACTER, dDtProc AS DATE, cMsg)
Local lRet		AS LOGICAL
Local cF44Code	AS CHARACTER

lRet	:= .T.
cMsg	:= ""

If ! cOper $ "CD"
	lRet	:= .F.
	cMsg	:= STR0011 // "Operation should be either (C)onservation or (D)esconservation"
ElseIf dDtProc < SN1->N1_AQUISIC
	lRet	:= .F.
	cMsg	:= STR0012 // "The date of the event cannot be lesser than date of acquisition of the fixed asset"
ElseIf dDtProc <= GetMV("MV_ULTDEPR") .Or. dDtProc >= LastDay(GetMV("MV_ULTDEPR") + 1) + 1
	lRet	:= .F.
	cMsg	:= STR0013 // "The date of the event must be in the month that follows the last depreciation calculation"
ElseIf !RU01CHKOPE(SN1->N1_FILIAL, SN1->N1_CBASE, SN1->N1_ITEM)
	lRet	:= .F.
	cMsg	:= STR0014 // "The fixed asset must be put in operation to be flagged for conservation"
EndIf

//Verify if Fixed Asset is available for conservation/desconservation
If lRet .And. cOper == "C"
	If SN1->N1_STATUS == N1_STATUS_CONSERVATION
		lRet	:= .F.
		cMsg	:= STR0015 // "The fixed asset is already in conservation"
	ElseIf !Empty(RU01T02CDO(dDtProc))
		lRet	:= .F.
		cMsg	:= STR0016 // "The start date must not be contained by another conservation/desconservation period"
	EndIf
ElseIf lRet .And. cOper == "D"
	cF44Code	:= RU01T02DDD(dDtProc)
	If Empty(cF44Code)
		lRet	:= .F.
		cMsg	:= STR0017 // "No available conservation period found for this fixed asset."
	ElseIf !Empty(RU01T02CDO(dDtProc, cF44Code))
		lRet	:= .F.
		cMsg	:= STR0018 // "The date of desconservation cannot be contained by another conservation/desconservation period"
	ElseIf dDtProc <= F44->F44_DATE
		lRet	:= .F.
		cMsg	:= STR0019 // "The date of desconservation must be greater than the date of conservation"
	EndIf
EndIf

Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02DDD

Return a F44 conservation register as Branch + Code for the positioned
fixed asset that have a date lower than the parameter and doesn't have a
desconservation equivalent

@param		dDtProc = Date of the event
@param		CHARACTER cN1Base
@param		CHARACTER cN1Item
@return		CHARACTER
@author 	victor.rezende
@since 		11/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T02DDD(dDtProc AS DATE, cN1Base AS CHARACTER, cN1Item AS CHARACTER)
Local cRet		AS CHARACTER
Local cKey		AS CHARACTER
Local cCurCode	AS CHARACTER
Local lOk		AS LOGICAL
Local aArea		AS ARRAY
Local aAreaSN1	AS ARRAY

lOk			:= .T.
cRet		:= ""
cCurCode	:= ""

aArea		:= GetArea()
aAreaSN1	:= SN1->(GetArea())

If lOk .And. !Empty(cN1Base)
	SN1->(dbSetorder(1))	//N1_FILIAL+N1_CBASE+N1_ITEM
	lOk		:= SN1->(dbSeek(xFilial("SN1") + cN1Base + cN1Item))
EndIf

If lOk
	cKey		:= SN1->(N1_FILIAL + N1_CBASE + N1_ITEM)
	F44->(dbSetOrder(2)) //F44_FILIAL+F44_CBASE+F44_ITEM+F44_CODE+F44_TYPE
	If F44->(dbSeek(cKey))
		While Empty(cRet) .And. F44->(!EOF()) .And. F44->(F44_FILIAL + F44_CBASE + F44_ITEM) == cKey
			cCurCode	:= F44->(F44_FILIAL + F44_CODE)

			If F44->F44_DATE <= dDtProc .And. F44->F44_TYPE == "1" .And. F44->F44_STATUS == F44_STATUS_CONFIRMED
				F44->(dbSkip())

				While F44->(!EOF()) .And. F44->F44_STATUS <> F44_STATUS_CONFIRMED
					F44->(dbSkip())
				EndDo

				If F44->(EOF()) .Or. F44->(F44_FILIAL + F44_CODE) <> cCurCode
					cRet	:= cCurCode
				EndIf
			Else
				F44->(dbSkip())
			EndIf
		EndDo
	EndIf

	If !Empty(cRet)
		F44->(dbSetOrder(1)) //F44_FILIAL+F44_CODE+F44_TYPE
		If F44->(! dbSeek(cRet))
			cRet	:= ""
		EndIf
	EndIf
EndIf

RestArea(aAreaSN1)
RestArea(aArea)

Return cRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02CDO

Returns the  branch + code of the conservation/desconservation period if
the positioned fixed asset have a conservation/desconservation period
that contains the requested date

@param		dDtProc = Date of the event
@param		cIgnoreF44 = A F44 key ( F44_FILIAL + F44_CODE ) that should be ignored by the validation (optional)
@return		CHARACTER
@author 	victor.rezende
@since 		11/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01T02CDO(dDtProc AS DATE, cIgnoreF44 AS CHARACTER)
Local cRet		AS LOGICAL
Local cKey		AS CHARACTER
Local bCurKey	AS BLOCK
Local cCurCode	AS CHARACTER
Local nX 		AS NUMERIC

nX:=0
cRet		:= ""	//By default returns empty
cIgnoreF44	:= IIf(Empty(cIgnoreF44), "", cIgnoreF44)

F44->(dbSetOrder(2))	//F44_FILIAL+F44_CBASE+F44_ITEM+F44_CODE+F44_TYPE
cKey		:= xFilial("F44") + SN1->N1_CBASE + SN1->N1_ITEM
bCurKey		:= {|cK| F44->(!EOF()) .And. F44->( F44_FILIAL+F44_CBASE+F44_ITEM ) == cK}
cCurCode	:= ""

If F44->(dbSeek( cKey ))
	While F44->(!EOF())
		nX+=1
		F44->(dbSkip())
	EndDo
EndIf

If F44->(dbSeek( cKey ))
	While Empty(cRet) .And. Eval(bCurKey, cKey)
		
		If F44->( F44_FILIAL + F44_CODE ) == cIgnoreF44
			//Ignored by parameter
		ElseIf F44->F44_STATUS <> F44_STATUS_CONFIRMED
			//Ignored stornoed registers
		ElseIf F44->F44_TYPE == "2" .And. F44->(F44_FILIAL + F44_CODE) <> cCurCode .And. F44->F44_DATE >= dDtProc
			//There should be no desconservation register without a conservation equivalent
			//  If there is, it will be treated as an infinite to current period
			cRet	:= F44->F44_FILIAL + F44->F44_CODE
		ElseIf F44->F44_TYPE == "2"
			//Lower closure with no conservation register should be ignored
		ElseIf F44->F44_TYPE == "1" .And. F44->F44_DATE <= dDtProc
			//If there is a conservation register lower than date of proc
			//  then desconservation date (next register) should be validated
			cCurCode	:= F44->(F44_FILIAL + F44_CODE)
			If nX>=2
				F44->(dbSkip())
				If !EMPTY(F44->(F44_FILIAL + F44_CODE)) .and.  ! Eval(bCurKey, cKey) .Or. (LastDay(F44->F44_DATE) >= dDtProc .and. F44->F44_STATUS !='2')
					//An conservation register without an equivalent desconservation 
					//  or and equivalent desconservation with a date greater than date of proc
					//  implies that the date of proc is contained by the current conservation period
					cRet	:= cCurCode
				EndIf
			Elseif nX==1
				If !EMPTY(F44->(F44_FILIAL + F44_CODE)) .and.  Eval(bCurKey, cKey) .Or. F44->F44_STATUS !='2'
					cRet	:= cCurCode
				EndIf
			Endif
		EndIf
		
		cCurCode	:= F44->(F44_FILIAL + F44_CODE)
		
		F44->(dbSkip())
	EndDo
EndIf

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01T02MSG

Output message to the user

@param		cMsg = Message to be outputed
@param		oSelf = tNewProcess object
@return		None
@author 	victor.rezende
@since 		04/05/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RU01T02MSG(cMsg AS CHARACTER, oSelf AS OBJECT)
If !IsBlind()
	MsgInfo(cMsg)
	If ValType(oSelf) == "O"
		oSelf:SaveLog(cMsg)
	EndIf
EndIf
Return Nil

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
Return IIf(Type("nR01T02Op") == "N", nR01T02Op, RU01T02_OPER_UNDEFINED)

//-----------------------------------------------------------------------
/*/{Protheus.doc} LoadHistData

Load history grid data

@param		OBJECT oStruF44
@return		ARRAY aRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function LoadHistData(oStruF44 AS OBJECT)
Local nX		AS NUMERIC
Local cQuery	AS CHARACTER
Local cAlsTmp	AS CHARACTER
Local cField	AS CHARACTER
Local aRet		AS ARRAY
Local aTmp		AS ARRAY
Local aFields	AS ARRAY
Local xValue

aFields	:= oStruF44:GetFields()

cQuery	:= " SELECT  "
For nX := 1 To Len(aFields)
	cQuery	+= aFields[nX, MODEL_FIELD_IDFIELD]
	cQuery	+= IIf(nX == Len(aFields), "", ",")
Next nX
cQuery	+= "   FROM " + RetSqlName("F44")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND F44_FILIAl = '"+xFilial("F44")+"' "
cQuery	+= "    AND F44_CBASE = '"+SN1->N1_CBASE+"' "
cQuery	+= "    AND F44_ITEM = '"+SN1->N1_ITEM+"' "
cQuery	+= " UNION "
cQuery	+= " SELECT "
For nX := 1 To Len(aFields)
	cField	:= AllTrim(aFields[nX, MODEL_FIELD_IDFIELD])
	If cField == "F44_FILIAL"
		cQuery	+= "'"+F44->F44_FILIAL+"'"
	ElseIf cField == "F44_CODE"
		cQuery	+= "'"+F44->F44_CODE+"'"
	ElseIf cField == "F44_DATE"
		cQuery	+= "N4_DATA"
	ElseIf cField == "F44_TYPE"
		cQuery	+= "'"+F44_TYPE_VIRTUAL_DEPREC+"'"
	ElseIf cField == "F44_WHO"
		cQuery	+= "'"+Space(GetSX3Cache("F44_WHO", "X3_TAMANHO"))+"'"
	ElseIf cField == "F44_DEPREC"
		cQuery	+= "'"+F44_DEPREC_IMPACT+"'"
	ElseIf cField == "F44_STATUS"
		cQuery	+= "'"+F44_STATUS_CONFIRMED+"'"
	Else
		cQuery	+= cField
	EndIf
	cQuery	+= IIf(nX == Len(aFields), "", ",")
Next nX
cQuery	+= "   FROM " + RetSqlName("SN4")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND N4_FILIAL = '"+xFilial("SN4")+"' "
cQuery	+= "    AND N4_CBASE = '"+SN1->N1_CBASE+"' "
cQuery	+= "    AND N4_ITEM = '"+SN1->N1_ITEM+"' "
cQuery	+= "    AND N4_MOTIVO = ' ' "
cQuery	+= "    AND N4_OCORR IN ('06','07','08','10','11','12','17','18','20') "
cQuery	+= " GROUP BY N4_DATA "
cQuery	+= " ORDER BY 1, 3, 4, 5 "

aRet	:= {}
cQuery:=ChangeQuery(cQuery)
cAlsTmp	:= RU01GETALS(cQuery)
While (cAlsTmp)->(! EOF())
	aTmp	:= {}
	For nX := 1 To Len(aFields)
		xValue	:= &("('"+cAlsTmp+"')->" + aFields[nX, MODEL_FIELD_IDFIELD])
		If aFields[nX, MODEL_FIELD_TIPO] == "D"
			xValue	:= SToD(xValue)
		EndIf
		aAdd(aTmp, xValue)
	Next nX

	aAdd(aRet, {Len(aRet) + 1, aTmp})
	(cAlsTmp)->(dbSkip())
EndDo
(cAlsTmp)->(dbCloseArea())

Return aRet
