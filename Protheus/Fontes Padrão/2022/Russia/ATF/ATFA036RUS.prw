#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'ATFA036.CH'

#define SOURCEFATHER	"ATFA036"

//-----------------------------------------------------------------------
/*/{Protheus.doc} ATFA036RUS()

Russian localization of FA write-off routine (ATFA036)

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function ATFA036RUS()
Local oBrowse		AS OBJECT

Private cCadastro	AS CHARACTER
Private aRotina		AS ARRAY

aRotina		:= {}
cCadastro	:= STR0001	// "Asset write-off"

SetKey( VK_F12, {|| Pergunte("AFA036", .T.) } )

oBrowse		:= BrowseDef()
oBrowse:Activate()

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()

Browse definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse		AS OBJECT
oBrowse		:= FWLoadBrw(SOURCEFATHER)
Return oBrowse

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Menu definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRotina		AS ARRAY
aRotina		:= FWLoadMenuDef(SOURCEFATHER)
aAdd(aRotina, {STR0094, "AFA036RUAC", 0, 2, 0, Nil, Nil, Nil})	// "Accounting Tracker"
aAdd(aRotina, {STR0157, "AFA036RUVI", 0, 2, 0, Nil, Nil, Nil})	// "View Invoices"
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

MVC Model definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oModel		AS OBJECT
Local oEventRUS		AS OBJECT

oModel		:= FWLoadModel(SOURCEFATHER)
oEventRUS	:= EV01A036RU():New()
oModel:InstallEvent("EV01A036RU",,oEventRUS)

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

MVC View definition

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oView			AS OBJECT
oView		:= FWLoadView(SOURCEFATHER)
Return oView

//-----------------------------------------------------------------------
/*/{Protheus.doc} AFA036RUVI()

View invoice related invoice for positioned FN6/SN1/SN3 register 

@param		CHARACTER cAliasBrw
@param		NUMERIC nRecBrw
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function AFA036RUVI(cAliasBrw AS CHARACTER, nRecBrw AS NUMERIC)
Local nX			AS NUMERIC
Local lOK			AS LOGICAL
Local oStructSF2	AS OBJECT
Local oStructHead	AS OBJECT
Local oVStructSF2	AS OBJECT
Local oVStructHead	AS OBJECT
Local oModel		AS OBJECT
Local oModelHead	AS OBJECT
Local oModelSF2		AS OBJECT
Local oView			AS OBJECT

lOK		:= .T.

If lOk .And. !( lOk := cAliasBrw $ "FN6|SN1|SN3" )
	Help("",1,"AFA036RUVIIA",,STR0158,1,0)	// "Invalid alias for invoice link with write-off register"
EndIf

If lOk
	oStructHead	:= FWFormStruct(1, cAliasBrw, /*bSX3*/)
	oStructSF2	:= FWFormStruct(1, "SF2", /*bSX3*/)
	
	oModel		:= MPFormModel():New("AFA036RUVI", /* Pre-valid */, /* Pos-Valid */, /* Commit */)

	oModel:AddFields("MVCMASTER", /*cOwner*/, oStructHead)
	oModel:AddGrid("SF2DETAIL", "MVCMASTER", oStructSF2, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, {|oMdl| LoadSF2Grid(cAliasBrw, nRecBrw, oMdl)} /* bLoadGrid */)

	oModelHead	:= oModel:GetModel("MVCMASTER")
	oModelSF2	:= oModel:GetModel("SF2DETAIL")

	oModelSF2:SetNoInsertLine(.T.)
	oModel:SetDescription(STR0159)	// "Write-off invoices"

	oVStructHead:= FWFormStruct(2, cAliasBrw, /*bSX3*/)
	oVStructSF2	:= FWFormStruct(2, "SF2", /*bSX3*/)

	oView		:= FWFormView():New()
	oView:AddField("VIEW_HEAD", oVStructHead, "MVCMASTER")
	oView:AddGrid("VIEW_GRID", oVStructSF2, "SF2DETAIL")
	oView:CreateHorizontalBox("MAIN", 25)
	oView:CreateHorizontalBox("GRID", 75)
	oView:SetOwnerView("VIEW_HEAD", "MAIN")
	oView:SetOwnerView("VIEW_GRID", "GRID")

	oView:addUserButton(STR0160 /* cTitle */, "OK" /* cResource */, {|oMdl,oBtn| ViewInvoice(oMdl,oBtn)} /* bExec */, /* cToolTip */, /* nShortCut */, /* aOptions */, .T. /* lShowBar */)	// "View invoice"
EndIf

If lOk
	RU01MVCRender(oModel, oView)
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} LoadSF2Grid()

Load grid for SF2 items

@param		CHARACTER cAliasBrw
@param		NUMERIC nRecBrw
@param		OBJECT oModelSF2
@param		ARRAY aData
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function LoadSF2Grid(cAliasBrw AS CHARACTER, nRecBrw AS NUMERIC, oModelSF2 AS OBJECT)
Local nX			AS NUMERIC
Local cField		AS CHARACTER
Local cType			AS CHARACTER
Local cQuery		AS CHARACTER
Local cTmpAls		AS CHARACTER
Local aFields		AS ARRAY
Local aFieldsQry	AS ARRAY
Local aData			AS ARRAY
Local aTmp			AS ARRAY
Local xValue		:= Nil		

aFields		:= oModelSF2:GetStruct():GetFields()
aFieldsQry	:= RU01MVCGRC(oModelSF2:GetStruct())
aData		:= {}

cQuery		:= " SELECT SF2.R_E_C_N_O_ AS F2RECNO "
For nX := 1 To Len(aFieldsQry)
	cQuery	+= ",SF2."+aFieldsQry[nX,MODEL_FIELD_IDFIELD]
Next nX
cQuery		+= "   FROM "+RetSqlName("SF2")+" SF2 "
cQuery		+= "  WHERE SF2.D_E_L_E_T_ = ' ' "
cQuery		+= "    AND SF2.F2_FILIAL = '"+xFilial("SF2")+"' "
cQuery		+= "    AND SF2.R_E_C_N_O_ IN ( "

If cAliasBrw == "FN6"
	cQuery		+= " SELECT SF2SUB.R_E_C_N_O_ "
	cQuery		+= "   FROM "+RetSqlName("FN6")+" FN6 "
	cQuery		+= "   JOIN "+RetSqlName("SF2")+" SF2SUB "
	cQuery		+= "     ON SF2SUB.D_E_L_E_T_ = ' ' "
	cQuery		+= "    AND SF2SUB.F2_FILIAL = FN6_FILIAL "
	cQuery		+= "    AND SF2SUB.F2_DOC = FN6_NUMNF "
	cQuery		+= "    AND SF2SUB.F2_SERIE = FN6_SERIE "
	cQuery		+= "  WHERE FN6.D_E_L_E_T_ = ' ' "
	cQuery		+= "    AND FN6_FILIAL = '"+xFilial("FN6")+"' "
	cQuery		+= "    AND FN6.R_E_C_N_O_ = " + AllTrim(Str(nRecBrw)) 
ElseIf cAliasBrw == "SN1"
	cQuery		+= " SELECT SF2SUB.R_E_C_N_O_ "
	cQuery		+= "   FROM "+RetSqlName("SN1")+" SN1 "
	cQuery		+= "   JOIN "+RetSqlName("FN6")+" FN6 "
	cQuery		+= "     ON FN6.D_E_L_E_T_ = ' ' "
	cQuery		+= "    AND FN6_FILIAL = N1_FILIAL "
	cQuery		+= "    AND FN6_CBASE = N1_CBASE "
	cQuery		+= "    AND FN6_CITEM = N1_ITEM "
	cQuery		+= "   JOIN "+RetSqlName("SF2")+" SF2SUB "
	cQuery		+= "     ON SF2SUB.D_E_L_E_T_ = ' ' "
	cQuery		+= "    AND SF2SUB.F2_FILIAL = FN6_FILIAL "
	cQuery		+= "    AND SF2SUB.F2_DOC = FN6_NUMNF "
	cQuery		+= "    AND SF2SUB.F2_SERIE = FN6_SERIE "
	cQuery		+= "  WHERE SN1.D_E_L_E_T_ = ' ' "
	cQuery		+= "    AND N1_FILIAL = '"+xFilial("SN1")+"' "
	cQuery		+= "    AND SN1.R_E_C_N_O_ = " + AllTrim(Str(nRecBrw)) 
ElseIf cAliasBrw == "SN3"
	cQuery		+= " SELECT SF2SUB.R_E_C_N_O_ "
	cQuery		+= "   FROM "+RetSqlName("SN3")+" SN3 "
	cQuery		+= "   JOIN "+RetSqlName("FN6")+" FN6 "
	cQuery		+= "     ON FN6.D_E_L_E_T_ = ' ' "
	cQuery		+= "    AND FN6_FILIAL = N3_FILIAL "
	cQuery		+= "    AND FN6_CBASE = N3_CBASE "
	cQuery		+= "    AND FN6_CITEM = N3_ITEM "
	cQuery		+= "   JOIN "+RetSqlName("SF2")+" SF2SUB "
	cQuery		+= "     ON SF2SUB.D_E_L_E_T_ = ' ' "
	cQuery		+= "    AND SF2SUB.F2_FILIAL = FN6_FILIAL "
	cQuery		+= "    AND SF2SUB.F2_DOC = FN6_NUMNF "
	cQuery		+= "    AND SF2SUB.F2_SERIE = FN6_SERIE "
	cQuery		+= "  WHERE SN3.D_E_L_E_T_ = ' ' "
	cQuery		+= "    AND N3_FILIAL = '"+xFilial("SN1")+"' "
	cQuery		+= "    AND SN3.R_E_C_N_O_ = " + AllTrim(Str(nRecBrw)) 
EndIf

cQuery		+= "        ) "
cQuery:= ChangeQuery(cQuery)
cTmpAls		:= RU01GETALS(cQuery)
While (cTmpAls)->(! EOF())
	aTmp	:= {(cTmpAls)->F2RECNO, {}}
	For nX := 1 To Len(aFields)
		xValue		:= Nil
		cField		:= aFields[nX, MODEL_FIELD_IDFIELD]
		cType		:= aFields[nX, MODEL_FIELD_TIPO]
		If ASCan(aFieldsQry, {|x| x[MODEL_FIELD_IDFIELD] == cField}) > 0
			xValue	:= &("('"+cTmpAls+"')->" + cField)
			If cType == "D"
				xValue	:= SToD(xValue)
			ElseIf cType == "L"
				xValue	:= xValue == "T"
			EndIf
		EndIf
		aAdd(aTmp[2], xValue)
	Next nX
	aAdd(aData, aTmp)
	(cTmpAls)->(dbSkip())
EndDo
(cTmpAls)->(dbCloseArea())

Return aData

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewInvoice()

View invoice for currently selected grid item

@param		OBJECT oView
@param		OBJECT oButton
@return		LOGICAL
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewInvoice(oView AS OBJECT, oButton AS OBJECT)
Local nLine			AS NUMERIC
Local nRecSF2		AS NUMERIC
Local lOK			AS LOGICAL
Local aArea			AS ARRAY
Local aAreaSF2		AS ARRAY
Local aAreaSD2		AS ARRAY
Local aRotBkp		AS ARRAY
Local oModel		AS OBJECT
Local oModelSF2		AS OBJECT

If Type("aRotina") <> "U"
	aRotBkp	:= aRotina
EndIf

oModel		:= oView:GetModel()
oModelSF2	:= oModel:GetModel("SF2DETAIL")

lOk			:= .T.

lOk			:= lOk .And. oModelSF2:Length() > 0
lOk			:= lOk .And. (nLine := oModelSF2:GetLine()) > 0
lOk			:= lOk .And. (nRecSF2 := oModelSF2:GetDataId()) > 0

If lOk
	SF2->(dbGoTo(nRecSF2))
	lOk		:= SF2->(Recno()) == nRecSF2
EndIf

If lOk
	aArea		:= GetArea()
	aAreaSF2	:= SF2->(GetArea())
	aAreaSD2	:= SD2->(GetArea())

	SF2->(dbSetOrder(1))	// F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	SD2->(dbSetOrder(3))	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	SD2->(dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))

	aRotina	:= {}
	aAdd(aRotina, {"", "", 0, 2, 0, Nil})
	aAdd(aRotina, {"", "", 0, 2, 0, Nil})
	aAdd(aRotina, {"", "", 0, 2, 0, Nil})
	aAdd(aRotina, {"", "", 0, 2, 0, Nil})

	dbSelectArea("SF2")
	CtbDocSaida()

	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	RestArea(aArea)
Else
	Help(" ",1,"REGNOIS")
EndIf

If !Empty(aRotBkp)
	aRotina	:= aRotBkp
EndIf

Return lOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} EV01A036RU

Observer class for ATFA036RUS

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        FWModelEvent
/*/
//-----------------------------------------------------------------------
Class EV01A036RU From FWModelEvent
	Method New() Public Constructor
	Method Activate(oModel, lCopy) Public
End Class

//-----------------------------------------------------------------------
/*/{Protheus.doc} EV01A036RU:New()

Constructor method for EV01A036RU

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        EV01A036RU
/*/
//-----------------------------------------------------------------------
Method New() Class EV01A036RU
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} EV01A036RU:Activate()

Method called after activation

@param		OBJECT oModel
@param		LOGICAL lCopy
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        EV01A036RU
/*/
//-----------------------------------------------------------------------
Method Activate(oModel, lCopy) Class EV01A036RU
Local oModelFN8		AS OBJECT
Local oModelType	AS OBJECT
Local oStructType	AS OBJECT

lRusConfirmations	:= .F.

// Standard initializer for write off % should be enforced
If FwIsInCallStack("AT036CANCE")
ElseIf FwIsInCallStack("AT036CANCMT")
ElseIf FwIsInCallStack("AF036CANCL")
	// Badge cancel should have no triggers
ElseIf oModel:GetOperation() <> MODEL_OPERATION_INSERT ;
.And. oModel:GetOperation() <> MODEL_OPERATION_UPDATE
ElseIf ! Empty(oModelFN8 := oModel:GetModel("FN8LOTE"))
	oModelType		:= oModel:GetModel("FN7TIPO")
	oStructType		:= oModelType:GetStruct()
	oStructType:AddTrigger(;
		"FN7_PERCBX",;
		"FN7_VLBAIX",;
		{|| .T.},;
		{|oMdl, cFld, xNewVl, xOldVl| ;
			AFA036RUTR(;
				oModel,;
				"FN7_PERCBX",;
				"FN7_VLBAIX",;
				oMdl, cFld, xNewVl, xOldVl)})
	oStructType:AddTrigger(;
		"FN7_VLBAIX",;
		"FN7_PERCBX",;
		{|| .T.},;
		{|oMdl, cFld, xNewVl, xOldVl| ;
			AFA036RUTR(;
				oModel,;
				"FN7_VLBAIX",;
				"FN7_PERCBX",;
				oMdl, cFld, xNewVl, xOldVl)})
	AF036LGatL('_BAIXA', oModel)
	oModelFN8:SetValue("OK", .T.)
Else
	oModelType		:= oModel:GetModel("FN7TIPO")
	oStructType		:= oModelType:GetStruct()
	oStructType:AddTrigger(;
		"FN7_PERCBX",;
		"FN7_VLBAIX",;
		{|| .T.},;
		{|oMdl, cFld, xNewVl, xOldVl| ;
			AFA036RUTR(;
				oModel,;
				"FN7_PERCBX",;
				"FN7_VLBAIX",;
				oMdl, cFld, xNewVl, xOldVl)})
	oStructType:AddTrigger(;
		"FN7_VLBAIX",;
		"FN7_PERCBX",;
		{|| .T.},;
		{|oMdl, cFld, xNewVl, xOldVl| ;
			AFA036RUTR(;
				oModel,;
				"FN7_VLBAIX",;
				"FN7_PERCBX",;
				oMdl, cFld, xNewVl, xOldVl)})
	AFA036RUGR(oModel)
EndIf

lRusConfirmations	:= .T.

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} AFA036RUGR()

Set write-off % for std. initializer and update lines

@param		OBJECT oModel
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function AFA036RUGR(oModel AS OBJECT)
Local nX			AS NUMERIC
Local oModelFN7		AS OBJECT

AF036GatQt("FN6_BAIXA", oModel)

oModelFN7		:= oModel:GetModel("FN7TIPO")
For nX := 1 To oModelFN7:Length()
	oModelFN7:GoLine(nX)
	oModelFN7:SetValue("OK", .T.)
Next nX

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} AFA036RUAC()

Accounting tracker

Will extend Russian accounting tracker for journals

@param		CHARACTER cAlias
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function AFA036RUAC(cAlias AS CHARACTER)
Local nX			AS NUMERIC
Local cQuery		AS CHARACTER
Local cAlsTmp		AS CHARACTER
Local cSqlJoin		AS CHARACTER
Local cJoinCV3		AS CHARACTER
Local cJoinSN3		AS CHARACTER
Local cSep			AS CHARACTER
Local aRecSN3		AS ARRAY

cSqlJoin	:= " AND CV3_LP IN ('810','814') "
aRecSN3		:= {}

If cAlias == "SN3"
	aAdd(aRecSN3, SN3->(Recno()))
ElseIf cAlias == "FN6"
	cSqlJoin+= " AND CV3_DTSEQ = '"+DToS(FN6->FN6_DTBAIX)+"' "

	cQuery	:= " SELECT SN3.R_E_C_N_O_ AS N3REC "
	cQuery	+= "   FROM "+RetSqlName("FN6")+" FN6 "
	cQuery	+= "   JOIN "+RetSqlName("SN3")+" SN3 "
	cQuery	+= "     ON SN3.N3_FILIAL = FN6.FN6_FILIAL "
	cQuery	+= "    AND SN3.N3_CBASE = FN6.FN6_CBASE "
	cQuery	+= "    AND SN3.N3_ITEM = FN6.FN6_CITEM "
	cQuery	+= "  WHERE FN6.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SN3.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND FN6.R_E_C_N_O_ = " + AllTrim(Str(FN6->(Recno())))
	cQuery      := ChangeQuery(cQuery)
	cAlsTmp	:= RU01GETALS(cQuery)
	While (cAlsTmp)->(!EOF())
		aAdd(aRecSN3, (cAlsTmp)->N3REC)
		(cAlsTmp)->(dbSkip())
	EndDo
	(cAlsTmp)->(dbCloseArea())
Else	// SN1
	cQuery	:= " SELECT SN3.R_E_C_N_O_ AS N3REC "
	cQuery	+= "   FROM "+RetSqlName("SN1")+" SN1 "
	cQuery	+= "   JOIN "+RetSqlName("SN3")+" SN3 "
	cQuery	+= "     ON SN3.N3_FILIAL = SN1.N1_FILIAL "
	cQuery	+= "    AND SN3.N3_CBASE = SN1.N1_CBASE "
	cQuery	+= "    AND SN3.N3_ITEM = SN1.N1_ITEM "
	cQuery	+= "  WHERE SN1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SN3.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SN1.R_E_C_N_O_ = " + AllTrim(Str(SN1->(Recno())))
	cQuery  := ChangeQuery(cQuery)
	cAlsTmp	:= RU01GETALS(cQuery)
	While (cAlsTmp)->(!EOF())
		aAdd(aRecSN3, (cAlsTmp)->N3REC)
		(cAlsTmp)->(dbSkip())
	EndDo
	(cAlsTmp)->(dbCloseArea())
EndIf

If Empty(aRecSN3)
	Help("",1,"ARQVAZIO")
Else
	cJoinCV3	:= " AND CV3_RECORI IN ( "
	cJoinSN3	:= " AND SN3.R_E_C_N_O_ IN ( "
	For nX := 1 To Len(aRecSN3)
		cSep		:= IIf(nX == 1, "", ",")
		cJoinCV3	+= cSep + "'"+AllTrim(Str(aRecSN3[nX]))+"'"
		cJoinSN3	+= cSep + AllTrim(Str(aRecSN3[nX]))
	Next nX
	cJoinCV3	+= " ) "
	cJoinSN3	+= " ) "

	cSqlJoin	+= cJoinCV3
	cSqlJoin	+= cJoinSN3

	RU01S02CQ(cAlias, "SN3", cSqlJoin)
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} AFA036RUTR()

Russian triggers for ATFA036

@param		OBJECT oModel
@param		CHARACTER cFieldOri
@param		CHARACTER cFieldDes
@param		VARIANT xValue
@return		VARIANT xValue
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function AFA036RUTR(oModel AS OBJECT, cFieldOri AS CHARACTER, cFieldDes AS CHARACTER, oMdl, cFld, xNewVl, xOldVl)
Local cAtfCur		AS CHARACTER
Local cModelId		AS CHARACTER
Local oModelType	AS OBJECT
Local oModelValue	AS OBJECT
Local xValue		:= Nil

cModelId		:= oModel:GetId()
cAtfCur			:= PADL(;
	GetNewPar("MV_ATFMOED", "01"),;
	TamSX3("FN7_MOEDA")[1],;
	"0")
oModelType		:= oModel:GetModel("FN7TIPO")
oModelValue		:= oModel:GetModel("FN7VALOR")

If cFieldOri == "FN7_PERCBX" .And. cFieldDes == "FN7_VLBAIX"
	xValue		:= 0
	If oModelValue:SeekLine({;
	{"FN7_TIPO",	oModelType:GetValue("FN7_TIPO")},;
	{"FN7_TPSALD",	oModelType:GetValue("FN7_TPSALD")},;
	{"FN7_MOEDA",	cAtfCur}})
		oModelValue:SetValue("FN7_PERCBX", xNewVl)
		xValue		:= oModelValue:GetValue("FN7_VLBAIX")
	EndIf
ElseIf cFieldOri == "FN7_VLBAIX" .And. cFieldDes == "FN7_PERCBX"
	xValue		:= 0
	If oModelValue:SeekLine({;
	{"FN7_TIPO",	oModelType:GetValue("FN7_TIPO")},;
	{"FN7_TPSALD",	oModelType:GetValue("FN7_TPSALD")},;
	{"FN7_MOEDA",	cAtfCur}})
		oModelValue:SetValue("FN7_VLBAIX", xNewVl)
		xValue		:= oModelValue:GetValue("FN7_PERCBX")
	EndIf
EndIf
Return xValue

// Russia_R5
