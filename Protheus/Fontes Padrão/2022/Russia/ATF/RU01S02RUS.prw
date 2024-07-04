#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU01S02RUS.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01S02RUS

Accounting tracker screen

@param		CHARACTER cAlias - Alias of the header journal table
@param		CHARACTER cAliasDet - Alias of the detail journal table
@param		NUMERIC nIndex - Header index order to join with child table
@param		NUMERIC nIndexDet - Child index order to join with header table
@param		LOGICAL lHistory - where it was called
@param		CHARACTER cUIDDet - UID choozen line ogf operation in history
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Function RU01S02RUS(cAlias AS CHARACTER, cAliasDet AS CHARACTER, nIndex AS NUMERIC, nIndexDet AS NUMERIC, lHistory AS LOGICAL, cUIDDet as CHARACTER)
Local nX			AS NUMERIC
Local lRet			AS LOGICAL
Local aIndex		AS ARRAY
Local aIndexDet		AS ARRAY
Local aAreaDet		AS ARRAY
Local aAreaHead		AS ARRAY
Local cQuery		AS CHARACTER
Local cAliasTrb		AS CHARACTER
Local cKeyDet		AS CHARACTER
Local cKeyMast		AS CHARACTER

Default cAliasDet	:= Soma1(cAlias)
Default nIndex		:= 1
Default nIndexDet	:= 1
Default lHistory	:= .F.

Private cAlsRuAcTr	:= cAlias
Private cAlsChild	:= cAliasDet
Private cAlsJoin	:= ""

lRet		:= .T.
aIndex		:= {}
aIndexDet	:= {}

If lRet
	lRet	:= SIX->(dbSeek(cAlias+AllTrim(Str(nIndex))))	//INDICE+ORDEM
	If lRet
		aIndex	:= Separa(AllTrim(SIX->CHAVE), "+")
	Else
		Help("",1,"RU01S02INE1",,STR0004,1,0)	//"Cannot find header index for the specified order"
	EndIf
EndIf

If lRet
	lRet	:= SIX->(dbSeek(cAliasDet+AllTrim(Str(nIndexDet))))  //INDICE+ORDEM
	If lRet
		aIndexDet	:= Separa(AllTrim(SIX->CHAVE), "+")
	Else
		Help("",1,"RU01S02INE2",,STR0005,1,0)	//"Cannot find details index for the specified order"
	EndIf
EndIf

If lRet
	cAlsJoin	:= ""

	If lHistory
		cQuery		:= "SELECT * FROM " + RetSQLName(cAliasDet) + " "+ cAliasDet +" WHERE "+ cAliasDet + "." + cAliasDet + "_UID = '" + cUIDDet + "'"
		cQuery		:= ChangeQuery(cQuery)
		cAliasTrb	:= RU01GETALS(cQuery)
		aAreaDet	:= &(cAliasDet)->(GetArea())
		aAreaHead	:= &(cAlias)->(GetArea())
		cKeyDet		:= xFilial(cAlias) + (cAliasTrb)->&(cAliasDet + "_LOT") + (cAliasTrb)->&(cAliasDet + "_ITEM")
		(cAliasTrb)->(dbCloseArea())
		DBSelectArea(cAlias)
		&(cAliasDet)->(DBSetOrder(1))	//DETAIL_FILIAL + DETAIL_LOT + DETAIL_ITEM
		If &(cAliasDet)->(DBSeek(cKeyDet))
			DBSelectArea(cAlias)
			cKeyMast	:=	 xFilial(cAlias) + &(cAliasDet + "->" + cAliasDet + "_LOT")
			&(cAlias)->(DBSetOrder(1))	//HEARER_FILIAL + HEARER_LOT
			If &(cAlias)->(DBSeek(cKeyMast))
				lRet := .T.
			Else 
				lRet := .F.
			EndIf
		Else 
			lRet := .F.	
		EndIf

		cAlsJoin	+= " AND " + cAliasDet + "_UID = '" + cUIDDet + "' "
	Else
		For nX := 1 To Len(aIndex)
			cAlsJoin	+= " AND "
			cAlsJoin	+= aIndexDet[nX] + " = '" + &(cAlias + "->" + aIndex[nX]) + "' "
		Next nX
	EndIf
EndIf

If lRet
	FWExecView(STR0001, "RU01S02", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil, /* [ oModel ] */)	//"Accounting Tracker"
EndIf
Return Nil

Function RU01S02001(oSN4 as object)
Local lRet as LOGICAL

Private c2UID:=oSN4:GetValue("N4_UID")
Private cAlsRuAcTr	:="SN4"
Private cAlsChild	:=nil

FWExecView(STR0001, "RU01S02", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil, /* [ oModel ] */)	//"Accounting Tracker"

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01S02CQ

Accounting tracker screen with non-journal query

@param		CHARACTER cAlsHead - Alias of the header
@param		CHARACTER cAlsGrid - Alias of the details grid
@param		CHARACTER cSqlJoin - SQL expression to join child with CV3
@return		LOGICAL lRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Function RU01S02CQ(cAlsHead AS CHARACTER, cAlsGrid AS CHARACTER, cSqlJoin AS CHARACTER)

Private cAlsRuAcTr	:= cAlsHead
Private cAlsChild	:= cAlsGrid
Private cAlsJoin	:= cSqlJoin

FWExecView(STR0001, "RU01S02", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil, /* [ oModel ] */)	//"Accounting Tracker"

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse defition (not applicable)

@param		None
@return		None
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu defition (not applicable)

@param		None
@return		ARRAY aRotina
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

MVC model defition

@param		None
@return		OBJECT oModel MPFormModel()
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oStruHead		AS OBJECT
Local oStruGrid		AS OBJECT
Local oModel		AS OBJECT

oStruHead	:= FWFormStruct(1, cAlsRuAcTr)
oStruGrid	:= FWFormStruct(1, "CT2")

oModel		:= MPFormModel():New("RU01S02", /* Pre-valid */, /* Pos-Valid */, /* Commit */)
oModel:AddFields("MVCMASTER", /*cOwner*/, oStruHead)
If cAlsChild==nil
	oModel:SetPrimarykey({'N4_FILIAL','N4_UID'})
EndIf
oModel:GetModel("MVCMASTER"):SetDescription(STR0002) // "Journal Information"
oModel:AddGrid("CT2DETAIL", "MVCMASTER", oStruGrid, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, {|oMdl| LoadCT2Rec(oMdl) } /* bLoadGrid */)
oModel:GetModel("CT2DETAIL"):SetDescription(STR0003) // "Accounting registers"
oModel:GetModel("CT2DETAIL"):SetOptional(.T.)
oModel:GetModel("CT2DETAIL"):SetNoInsertLine(.T.)
oModel:SetDescription(STR0001) // "Accounting Tracker"

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
@see		None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oStruHead		AS OBJECT
Local oStruGrid		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT

oModel		:= FWLoadModel("RU01S02")
oStruHead	:= FWFormStruct(2, cAlsRuAcTr)
oStruGrid	:= FWFormStruct(2, "CT2")

If cAlsChild==nil
	oStruHead:RemoveField("N4_FILIAL")
	oStruHead:RemoveField("N4_MOTIVO")
	oStruHead:RemoveField("N4_TIPOCNT")
	oStruHead:RemoveField("N4_CONTA")
	oStruHead:RemoveField("N4_QUANTD")
	oStruHead:RemoveField("N4_VLROC1")
	oStruHead:RemoveField("N4_VLROC2")
	oStruHead:RemoveField("N4_VLROC3")
	oStruHead:RemoveField("N4_VLROC4")
	oStruHead:RemoveField("N4_VLROC5")
	oStruHead:RemoveField("N4_SERIE")
	oStruHead:RemoveField("N4_NOTA")
	oStruHead:RemoveField("N4_VENDA")
	oStruHead:RemoveField("N4_TXMEDIA")
	oStruHead:RemoveField("N4_TXDEPR")
	oStruHead:RemoveField("N4_CCUSTO")
	oStruHead:RemoveField("N4_LOCAL")
	oStruHead:RemoveField("N4_SEQ")
	oStruHead:RemoveField("N4_SUBCTA")
	oStruHead:RemoveField("N4_TPSALDO")
	oStruHead:RemoveField("N4_STORNO")
	oStruHead:RemoveField("N4_CLVL")
	oStruHead:RemoveField("N4_HORA")
	oStruHead:RemoveField("N4_USER")
	oStruHead:RemoveField("N4_CODBAIX")
	oStruHead:RemoveField("N4_QUANTPR")
	oStruHead:RemoveField("N4_CCUSTOT")
	oStruHead:RemoveField("N4_GRUPOTR")
	oStruHead:RemoveField("N4_NODIA")
	oStruHead:RemoveField("N4_DIACTB")
	oStruHead:RemoveField("N4_UID")
	oStruHead:RemoveField("N4_ORIUID")
EndIf

oView 		:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_HEAD", oStruHead, "MVCMASTER")
oView:AddGrid("VIEW_GRID", oStruGrid, "CT2DETAIL")
oView:CreateHorizontalBox("MAIN", 25)
oView:CreateHorizontalBox("GRID", 75)
oView:SetOwnerView("VIEW_HEAD", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

Return oView

//-----------------------------------------------------------------------
/*/{Protheus.doc} LoadCT2Rec

Load CT2 grid.

Requirements:
- Must have a relationship in SX9 with the lot contained in SIX as first order index

@param		OBJECT oModel
@return		ARRAY aRet
@author 	victor.rezende
@since 		11/01/2018
@version 	1.3
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Static Function LoadCT2Rec(oModel AS OBJECT)
Local nX		AS NUMERIC
Local cQuery	AS CHARACTER
Local cAliasTrb	AS CHARACTER
Local cExprFld	AS CHARACTER
Local aRet		AS ARRAY
Local aTmp		AS ARRAY
Local aFields	AS ARRAY
Local oStruct	AS OBJECT
Local xValue

aRet		:= {}
oStruct		:= oModel:GetStruct()
aFields		:= oStruct:GetFields()

If cAlsChild!=nil
	cQuery	:= " SELECT CT2.R_E_C_N_O_ AS CT2RECNO "
	For nX := 1 To Len(aFields)
		If ! aFields[nX, MODEL_FIELD_VIRTUAL] .And. ;
		aFields[nX, MODEL_FIELD_TIPO] $ "C|N|D|L"
			cQuery  += "," + aFields[nX, MODEL_FIELD_IDFIELD]
		EndIf
	Next nX
	cQuery	+= "	FROM "+RetSqlName(cAlsChild)+" "+cAlsChild+" "
	cQuery	+= "	JOIN "+RetSqlName("SN4") + " SN4 ON N4_UID = " + cAlsChild + "_SN4UID"
	cQuery	+= "	JOIN "+RetSqlName("CV3") + " CV3 ON CV3_RECORI = CAST(SN4.R_E_C_N_O_ AS CHAR(17)) "
	cQuery	+= "	JOIN "+RetSqlName("CT2") + " CT2 ON CT2.R_E_C_N_O_ = CAST(CV3_RECDES AS INT) "
	cQuery	+= "	WHERE " + cAlsChild + ".D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND CV3.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SN4.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND CT2.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND N4_FILIAL = '"	+ xFilial("SN4") + "' "
	cQuery	+= "    AND CV3_FILIAL = '" + xFilial("CV3") + "' "
	cQuery	+= "    AND CT2_FILIAL = '" + xFilial("CT2") + "' "
	cQuery	+= "    AND CV3_RECDES <> ' ' "
	cQuery	+= "    AND CV3_TABORI = 'SN4' "
	cQuery	+= cAlsJoin
	cQuery	+= " ORDER BY CV3_FILIAL, CV3_DTSEQ, CV3_SEQUEN "
Else

	cQuery	:= " SELECT CT2.R_E_C_N_O_ AS CT2RECNO,CV3_RECORI"
	For nX := 1 To Len(aFields)
		If ! aFields[nX, MODEL_FIELD_VIRTUAL] .And. ;
		aFields[nX, MODEL_FIELD_TIPO] $ "C|N|D|L"
			cQuery  += "," + aFields[nX, MODEL_FIELD_IDFIELD]
		EndIf
	Next nX
	cQuery	+= " FROM " + RetSqlName("CT2") + " AS CT2"

	cQuery	+= " JOIN " + RetSqlName("CV3") + " AS CV3
	cQuery	+= " ON CV3_RECORI ="

	cQuery	+= " CAST(( SELECT R_E_C_N_O_ FROM " + RetSqlName("SN4") + " WHERE N4_UID ='" + c2UID + "' ) AS CHAR(17)) " //NEED CHECK ALL

	cQuery	+= " AND CV3_FILIAL = '"	+ xFilial("CV3") + "'"
	cQuery	+= " AND CV3.D_E_L_E_T_ = ' '"
	cQuery	+= " AND CV3_RECDES <> ' '"
	cQuery	+= " AND CV3_TABORI = 'SN4'" 

	cQuery	+= " WHERE CT2.R_E_C_N_O_ = CAST(CV3_RECDES AS INT)"
	cQuery	+= " AND CT2.D_E_L_E_T_ = ' '"
	cQuery	+= " AND CT2_FILIAL = '"	+ xFilial("CT2") + "'"

	cQuery	+= " ORDER BY  CV3_FILIAL, CV3_DTSEQ, CV3_SEQUEN"
EndIf

cQuery	:= ChangeQuery(cQuery)
cAliasTrb	:= RU01GETALS(cQuery)
While (cAliasTrb)->(! EOF())
	aTmp	:= {(cAliasTrb)->CT2RECNO, {}}
	For nX := 1 To Len(aFields)
		xValue	:= Nil
		If ! aFields[nX, MODEL_FIELD_VIRTUAL] .And. ;
		aFields[nX, MODEL_FIELD_TIPO] $ "C|N|D"
			cExprFld	:= "('"+cAliasTrb+"')->"
			cExprFld	+= aFields[nX, MODEL_FIELD_IDFIELD]
			xValue		:= &(cExprFld)
			If aFields[nX, MODEL_FIELD_TIPO] == "D"
				xValue	:= SToD(xValue)
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
