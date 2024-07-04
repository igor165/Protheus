#include "RU01S01.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWBROWSE.CH"

#DEFINE SOURCEFATHER		"RU01S01"
#DEFINE SQL_FORM_FILTER		3
#DEFINE IS_ACTIVE_FILTER	6

/*/{Protheus.doc} RU01S01RUS

Localization of RU01S01

@param		None
@return		None
@author 	alexandra.menyashina
@since 		07/08/2018
@version 	1.0
@project	MA3
/*/
Function RU01S01RUS()
Local cDescMod	AS CHARACTER
Local aEnableButtons AS ARRAY

aEnableButtons	:= {{.F.,Nil},;	// 1 - Copiar
					{.F.,Nil},;	// 2 - Recortar
					{.F.,Nil},;	// 3 - Colar
					{.F.,Nil},;	// 4 - Calculadora
					{.F.,Nil},;	// 5 - Spool
					{.T.,Nil},;	// 6 - Imprimir
					{.F.,Nil},;	// 7 - Confirmar
					{.T.,Nil},;	// 8 - Cancelar
					{.F.,Nil},;	// 9 - WalkTrhough
					{.F.,Nil},;	// 10 - Ambiente
					{.F.,Nil},;	// 11 - Mashup
					{.T.,Nil},;	// 12 - Help
					{.F.,Nil},;	// 13 - Formulário HTML
					{.F.,Nil}}	// 14 - ECM

cDescMod	:= Alltrim(SN1->N1_CBASE) + " " + Alltrim(SN1->N1_DESCRIC)

FWExecView(cDescMod, "RU01S01", MODEL_OPERATION_VIEW, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, /* [ oModel ] */)	//"Accounting Tracker"	
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu defition
@param		None
@return		ARRAY aRotina
@author 	alexandra.menyashina
@since 		07/08/2018
@version 	1.0
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Menu defition
@param		None
@return		ARRAY aRotina
@author 	alexandra.menyashina
@since 		07/08/2018
@version 	1.0
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oModel		AS OBJECT
Local oStruHead		AS OBJECT
Local oStruGrid		AS OBJECT
Local oStructSN4	AS OBJECT

oStruHead	:= FWFormStruct(1, "SN1")
oStruGrid	:= FWFormStruct(1, "SN3")
oStructSN4	:= FWFormStruct(1, "SN4",)

oModel		:= MPFormModel():New("RU01S01", /* Pre-valid */, /* Pos-Valid */, /* Commit */)
oModel:AddFields("SN1MASTER", /*cOwner*/, oStruHead)
oModel:AddGrid("SN3DETAIL", "SN1MASTER", oStruGrid)
oModel:AddGrid("SN4DETAIL", "SN1MASTER", oStructSN4, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, {|oMdl| LoadSN4(oMdl,SN1->N1_CBASE,SN1->N1_ITEM) } /* bLoadGrid */)

oModel:SetDescription(STR0012) // "Operation: SN1->N1_CBASE SN1->N1_DESCRIC"

oModel:SetRelation( 'SN3DETAIL', {{'N3_FILIAL','xFilial("SN3")'}, {'N3_CBASE' ,'N1_CBASE'}, {'N3_ITEM'  ,'N1_ITEM'  } } , SN3->(IndexKey(1)))
//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+DTOS(N4_DATA)
oModel:SetRelation("SN4DETAIL", {{"N4_CBASE", "N3_CBASE"}, {"N4_ITEM", "N3_ITEM"},{"N4_TIPO", "N3_TIPO"},{"DTOS(N4_DATA)", "DTOS(SN3->N3_AQUISIC)"}}, SN4->(IndexKey(1)))

If !FWisincallstack("AF012ALTEX")				
	oModel:SetPrimaryKey({"N4_FILIAL", "N4_UID"})
	oModel:GetModel("SN4DETAIL"):SetUniqueLine({"N4_UID"})
EndIf

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Menu defition
@param		None
@return		ARRAY aRotina
@author 	alexandra.menyashina
@since 		07/08/2018
@version 	1.0
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oView			AS OBJECT
Local oStruHead		AS OBJECT
Local oStruGrid		AS OBJECT
Local oModel		AS OBJECT
Local oView			AS OBJECT
Local cFieldSN1		AS CHARACTER

cFieldSN1	:= "N1_CBASE|N1_ITEM|N1_DESCRIC"

oModel		:= FWLoadModel("RU01S01")

oStruHead	:= FWFormStruct(2, "SN1", {|x| (AllTrim(x) $ cFieldSN1)})
oStruHead:SetNoFolder()
oStruGrid	:= FWFormStruct(2, "SN4")

oView 		:= FWFormView():New()
oView:SetModel(oModel)

oStruGrid:RemoveField('N4_CBASE')
oStruGrid:RemoveField('N4_ITEM')

oView:AddField("VIEW_HEAD", oStruHead, "SN1MASTER")
oView:AddGrid("VIEW_GRID", oStruGrid, "SN4DETAIL")
oView:CreateHorizontalBox("MAIN", 20)
oView:CreateHorizontalBox("GRID", 80)
oView:SetOwnerView("VIEW_HEAD", "MAIN")
oView:SetOwnerView("VIEW_GRID", "GRID")

oView:SetViewProperty("SN4DETAIL", "ONLYVIEW")
oView:SetViewProperty("VIEW_GRID", "GRIDFILTER",{.T.}) 
oView:SetViewProperty("VIEW_GRID", "GRIDSEEK", {.T.})
//Delete after demonstration for consultant
cCSS:= "QTableView{ selection-background-color: #b9b9b9 }"
oView:SetViewProperty("VIEW_GRID", "SETCSS", {cCSS})

oView:SetViewProperty("VIEW_GRID", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU01S01DOC(oFormula, cFieldName, nLineGrid, nLineModel )}})

oView:AddUserButton(STR0017, "", {|| RU01S01PRT() })// "Print"
oView:AddUserButton(STR0013, "", {|| RU01S01DOC() }) //"Original document"
oView:AddUserButton(STR0015, "", {|| RU01S01ACE() }) //"Accounting entries"

Return oView

//-----------------------------------------------------------------------
/*/{Protheus.doc} LoadSN4

Load SN4 grid.

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
Static Function LoadSN4(oModel AS OBJECT,cBase AS CHARACTER, cItem AS CHARACTER)
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

cQuery	:= "SELECT  N4.R_E_C_N_O_ N4RECNO, N4.* FROM "+ RetSQLName("SN4") +" N4 "
cQuery	+= " JOIN "	+ RetSQLName("SN3") +" N3 "
cQuery	+= " ON	(	N3.N3_CBASE	=	N4.N4_CBASE "
cQuery	+= " AND	N3.N3_ITEM	=	N4.N4_ITEM "
cQuery	+= " AND	N3.N3_TIPO		=	N4.N4_TIPO"
cQuery	+= " AND	N3.N3_SEQ		=	N4.N4_SEQ "
cQuery	+= " AND	N3.D_E_L_E_T_ = ' ' )"
cQuery	+= " WHERE	N4.N4_FILIAL = '" + xFilial("SN4") + "'"
cQuery	+= " AND 	N3.N3_FILIAL = '" + xFilial("SN3") + "'"
cQuery	+= " AND 	N3.N3_CBASE	= '" + cBase + "' "
cQuery	+= " AND	N3.N3_ITEM	= '" + cItem + "' "
cQuery	+= " AND	N4.D_E_L_E_T_ = ' '"
cQuery	+= " ORDER BY N4.R_E_C_N_O_"

cQuery	:= ChangeQuery(cQuery)
cAliasTrb	:= RU01GETALS(cQuery)
While (cAliasTrb)->(! EOF())
	aTmp	:= {(cAliasTrb)->N4RECNO, {}}
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
		If aFields[nX, MODEL_FIELD_IDFIELD] == 'N4_USER'
			xValue := RU01S01USN((cAliasTrb)->N4RECNO)
		EndIf
		aAdd(aTmp[2], xValue)
	Next nX
	aAdd(aRet, aTmp)
	(cAliasTrb)->(dbSkip())
EndDo
(cAliasTrb)->(dbCloseArea())

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01S01DOC

Original Document
@param		None
@return		LOGICAL lRet
@author 	alexandra.menyashina
@since 		07/08/2018
@version 	1.0
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
Function RU01S01DOC(oFormula, cFieldName, nLineGrid, nLineModel)
Local lRet			AS LOGICAL
Local lNotWrtOff	AS LOGICAL
Local cHeader		AS CHARACTER
Local cDetail		AS CHARACTER
Local cAliHead		AS CHARACTER
LOCAL cAliDet		AS CHARACTER
Local cNameOper		AS CHARACTER
Local cQuery		AS CHARACTER
Local cAliasTrb		AS CHARACTER
Local cCode			AS CHARACTER
Local cOcorr		AS CHARACTER
Local aArea			AS ARRAY
Local aAreaSN4		AS ARRAY
Local aAreaHead		AS ARRAY
Local aAreaDet		AS ARRAY
Local oModelOper	AS OBJECT
Local oModel		AS OBJECT

Default oFormula:=NIL
Default cFieldName:=""
Default nLineGrid:=0
Default nLineModel:=0
Default lRet	:= .F.
Default cCode	:= ""
Default lNotWrtOff	:= .T.

aArea		:= GetArea()
aAreaSN4	:= SN4->(GetArea())
aAreaHead	:= {}
aAreaDet	:= {}

oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel	:= FwLoadModel("RU01S01")
EndIf
cOcorr	:= oModel:GetModel("SN4DETAIL"):GetValue("N4_OCORR")

Do Case
Case	cOcorr == "61"	
	cNameOper	:=	"RU01T01"
	lRet 		:= .T.
	cAliHead	:=	"F4Q"
	cAliDet		:=	"F4R"
Case	cOcorr == "62"	
	cNameOper	:=	"RU01T03"
	cAliHead	:=	"F4U"
	cAliDet		:=	"F4V"
	lRet := .T.
Case	cOcorr == "63" .or. cOcorr == "97" .or. cOcorr == "98"
	cNameOper	:=	"RU01T04"
	cAliHead	:=	"F4S"
	cAliDet		:=	"F4T"
	lRet := .T.
Case 	cOcorr == "01"
	DBSelectArea('SN4')
	SN4->(DBSetOrder(10)) //"N4_FILIAL+N4_UID"
		If SN4->(DBSeek(;
		oModel:GetModel("SN4DETAIL"):GetValue("N4_FILIAL")+;
		oModel:GetModel("SN4DETAIL"):GetValue("N4_UID");
		))
			If SN4->N4_ORIGEM=="ATFA012 "
				DBSelectArea('SN3')
				SN3->(DBSetOrder(1))	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ 
				If SN3->(DBSeek(;
				oModel:GetModel("SN3DETAIL"):GetValue("N3_FILIAL")+;
				oModel:GetModel("SN3DETAIL"):GetValue("N3_CBASE")+;
				oModel:GetModel("SN3DETAIL"):GetValue("N3_ITEM")+;
				oModel:GetModel("SN3DETAIL"):GetValue("N3_TIPO")+;
				oModel:GetModel("SN3DETAIL"):GetValue("N3_BAIXA")+;
				SN4->N4_SEQ;
				))
			EndIf
			cNameOper	:=	"ATFA036"
			cAliHead	:=	"FN6"
			cAliDet		:=	"FN7"
			lNotWrtOff	:= .F.
			lRet := .T.
		EndIf
	EndIf
Otherwise
	cNameOper	:=	"ATFA012"
	cAliHead	:=	"SN1"
	cAliDet		:=	"SN3"
EndCase

aAreaDet	:= &(cAliDet)->(GetArea())
aAreaHead	:= &(cAliHead)->(GetArea())

If lRet .AND. lNotWrtOff
	cCode	:= 	oModel:GetModel("SN4DETAIL"):GetValue("N4_UID")	//SN4->N4_UID
	cQuery		:= "SELECT * FROM " + RetSQLName(cAliDet) + " "+ cAliDet +" WHERE "+ cAliDet + "." + cAliDet + "_SN4UID = '" + cCode + "'"
	cQuery		:= ChangeQuery(cQuery)
	cAliasTrb	:= RU01GETALS(cQuery)
	
	cKeyDet		:= xFilial(cAliDet) + (cAliasTrb)->&(cAliDet + "_LOT") + (cAliasTrb)->&(cAliDet + "_ITEM")
	(cAliasTrb)->(dbCloseArea())

	DBSelectArea(cAliDet)
	&(cAliDet)->(DBSetOrder(1))	//DETAIL_FILIAL + DETAIL_LOT + DETAIL_ITEM
	If &(cAliDet)->(DBSeek(cKeyDet))
		DBSelectArea(cAliHead)
		cKeyMast	:=	 xFilial(cAliHead) + &(cAliDet + "->" + cAliDet + "_LOT")
		&(cAliHead)->(DBSetOrder(1))	//HEADER_FILIAL + HEADER_LOT
		If &(cAliHead)->(DBSeek(cKeyMast))
			lRet := .T.
		Else 
			lRet := .F.
		EndIf
	Else 
		lRet := .F.	
	EndIf

ElseIf lRet .AND. !lNotWrtOff
	cKeyDet		:= xFilial('SN4') + xFilial('SN4') +;
					oModel:GetModel("SN4DETAIL"):GetValue("N4_CBASE") +;
					oModel:GetModel("SN4DETAIL"):GetValue("N4_ITEM") +;
					oModel:GetModel("SN4DETAIL"):GetValue("N4_TIPO") +;
					oModel:GetModel("SN4DETAIL"):GetValue("N4_TPSALDO") 

	DBSelectArea(cAliDet)
	&(cAliDet)->(DBSetOrder(2))	   //FN7_FILIAL+FN7_FILORI+FN7_CBASE+FN7_CITEM+FN7_TIPO+FN7_TPSALD+FN7_SEQREA+FN7_SEQ+DTOS(FN7_DTBAIX)+FN7_ITEM                                                                                                     
	If &(cAliDet)->(DBSeek(cKeyDet))
		DBSelectArea(cAliHead)
		cKeyMast	:=	 xFilial(cAliHead) + &(cAliDet + "->" + cAliDet + "_CODBX")
		&(cAliHead)->(DBSetOrder(1))	//FN6_FILIAL+FN6_CODBX
		If &(cAliHead)->(DBSeek(cKeyMast))
			lRet := .T.
		Else 
			lRet := .F.
		EndIf
	Else 
		lRet := .F.	
	EndIf
Else
	lRet := .T.
EndIf

If lRet .AND. lNotWrtOff
	oModelOper	:= FWLoadModel(cNameOper)
	FwExecView(, cNameOper, MODEL_OPERATION_VIEW,/* oDlg */,{|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oModelOper/*oModelAct*/)//open view of operation
ElseIf lRet .AND. !lNotWrtOff
	AT36Visual("1")
Else
	Help(" ",1,"RU01S01ORDOC",,STR0014,1,0)	//"Original document is not exist"
EndIf

RestArea(aAreaDet)
RestArea(aAreaHead)
RestArea(aAreaSN4)
RestArea(aArea)
return lRet



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU01S01ACE

Accounting Entries
@param		None
@return		LOGICAL lRet
@author 	alexandra.menyashina
@since 		21/08/2018
@version 	1.0
@project	MA3
@see		None
/*/
//-----------------------------------------------------------------------
function RU01S01ACE()
Local oModel	AS OBJECT
Local cOcorr	AS CHARACTER
Local cAliHead	AS CHARACTER
Local cAliDet	AS CHARACTER
Local nIndHead	AS NUMERIC
LOcal nIndDet	AS NUMERIC
Local lRet		AS LOGICAL

lRet	:= .T.
oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel	:= FwLoadModel("RU01S01")
EndIf
cOcorr	:= oModel:GetModel("SN4DETAIL"):GetValue("N4_OCORR")

Do Case
Case	cOcorr == "61"
	cAliHead	:=	"F4Q"
	nIndHead	:=	1
	cAliDet		:=	"F4R"
	nIndDet		:=	1
Case	cOcorr == "62"	
	cAliHead	:=	"F4U"
	nIndHead	:=	1
	cAliDet		:=	"F4V"
	nIndDet		:=	1
Case	cOcorr == "63"	
	cAliHead	:=	"F4S"
	nIndHead	:=	1
	cAliDet		:=	"F4T"
	nIndDet		:=	1
Case cOcorr == "06"
	dbSelectArea("SN4")
	dbSetOrder(10)
	SN4->(DBSeek(xFilial('SN4') + oModel:GetModel("SN4DETAIL"):GetValue("N4_UID")))
	RU01S02001(oModel:GetModel("SN4DETAIL"))
	lRet		:= .F.
Otherwise
	lRet		:= .F.
	Help(" ",1,"RU01S01ACENT",,STR0016,1,0)	//"Accounting Entries are not exist"
EndCase
If lRet
	RU01S02RUS(cAliHead,cAliDet,nIndHead,nIndDet,.T., Iif(lRet,oModel:GetModel("SN4DETAIL"):GetValue("N4_ORIUID"),Nil))
EndIf

return

/*/{Protheus.doc} RU01S01PRT

Print

@return		Nil
@author 	Alexandra Menyashina
@since 		19/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01S01PRT()
Local oReport	AS OBJECT
Local cName		AS CHARACTER

cName	:= 'RU01S01'
oReport := ReportDef(cName)
oReport:PrintDialog()

return Nil

/*/{Protheus.doc} ReportDef

Print report definition

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		19/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ReportDef(cName)
Local oReport	AS OBJECT
Local oSecSN1	AS OBJECT
Local oSecSN4	AS OBJECT
Local oStruSN1	AS OBJECT
Local oStruSN4	AS OBJECT
Local nX		AS NUMERIC

oStruSN1 := FWFormStruct(2, "SN1", {|x| (AllTrim(x) $ "N1_CBASE|N1_ITEM|N1_DESCRIC")})
oStruSN4 := FWFormStruct( 2, 'SN4' )

oReport := TReport():New(cName/*cReport*/,STR0001/*cTitle*/,cName,{|oReport| ReportPrint(oReport)},"PRINT", .F./*<lLandscape>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<cPageTText>*/ , .F./*<lPageTInLine>*/ , .F./*<lTPageBreak>*/ , /*<nColSpace>*/ )

oReport:lParamPage	:= .F.	//Don't print patameter page
//Header info
oSecSN1 := TRSection():New(oReport,"",{'SN1'} , , .F., .T.)
For nX := 1 To Len(oStruSN1:aFields)
	If ! oStruSN1:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecSN1,oStruSN1:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"SN1", alltrim(oStruSN1:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX

//Detail info
oSecSN4 := TRSection():New(oReport,"",{'SN4'} , , .F., .T.)
For nX := 1 To Len(oStruSN4:aFields)
	If ! oStruSN4:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecSN4,oStruSN4:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"SN4", alltrim(oStruSN4:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX
	
Return oReport

/*/{Protheus.doc} ReportPrint

Print prepare data

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		19/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSecSN1 		AS OBJECT
Local oSecSN4		AS OBJECT
Local oStruSN1		AS OBJECT
Local oStruSN4		AS OBJECT
Local oView			AS OBJECT
Local oGridFilt		AS OBJECT
Local cAliasQry		AS CHARACTER
Local cQuery		AS CHARACTER
Local cBase			AS CHARACTER
Local cItem			AS CHARACTER
Local cFiter		AS CHARACTER
local lRet			AS LOGICAL
Local nX			AS NUMERIC
Local xValor

oStruSN1 := FWFormStruct(2, "SN1", {|x| (AllTrim(x) $ "N1_CBASE|N1_ITEM|N1_DESCRIC")})
oStruSN4 := FWFormStruct( 2, 'SN4' )
oView	 := FWViewActive()
oGridFilt := oView:GetViewObj('SN4DETAIL')[3]:oBrowse:fwfilter()

oSecSN1		:= oReport:Section(1)
oSecSN4		:= oReport:Section(2)
cAliasQry	:= GetNextAlias()
cQuery		:= ""
lRet		:= .T.

If oReport:Cancel()
	Return .T.
EndIf

oSecSN1:Init()
oReport:IncMeter()

cBase := SN1->N1_CBASE
cItem := SN1->N1_ITEM

dbSelectArea('SN1')
SN1->(DBSeek( xFilial('SN1') + cBase + cItem))

For nX := 1 To Len(oStruSN1:aFields)
	oSecSN1:Cell(oStruSN1:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(SN1->&(oStruSN1:aFields[nX, MVC_VIEW_IDFIELD]))
Next nX		
oSecSN1:Printline()

oSecSN4:init()

cQuery	:= " select  N4.R_E_C_N_O_ SN4RECNO "

For nX := 1 To Len(oStruSN4:aFields)
	If ! oStruSN4:aFields[nX, MVC_VIEW_VIRTUAL]
		cQuery  += "," + oStruSN4:aFields[nX, MVC_VIEW_IDFIELD]
	EndIf
Next nX

cQuery	+= " FROM "+ RetSQLName("SN4") +" N4 "
cQuery	+= " JOIN "	+ RetSQLName("SN3") +" N3 "
cQuery	+= " ON	(	N3.N3_CBASE	=	N4.N4_CBASE "
cQuery	+= " AND	N3.N3_ITEM	=	N4.N4_ITEM "
cQuery	+= " AND	N3.N3_TIPO		=	N4.N4_TIPO"
cQuery	+= " AND	N3.N3_SEQ		=	N4.N4_SEQ "
cQuery	+= " AND	N3.D_E_L_E_T_ = ' ' )"
cQuery	+= " WHERE	N4.N4_FILIAL = '" + xFilial("SN4") + "'"
cQuery	+= " AND 	N3.N3_FILIAL = '" + xFilial("SN3") + "'"
cQuery	+= " AND 	N3.N3_CBASE	= '" + cBase + "' "
cQuery	+= " AND	N3.N3_ITEM	= '" + cItem + "' "
cQuery	+= " AND	not (N4.N4_TIPOCNT	= '3' and N4.N4_OCORR in  ('20', '06') )"		// hide depreciacion records with type '3'
cQuery	+= " AND	N4.D_E_L_E_T_ = ' '"

for nX := 1 to Len(oGridFilt:aFilter)
	If oGridFilt:aFilter[nX][IS_ACTIVE_FILTER]
		cQuery += " AND " + oGridFilt:aFilter[nX][SQL_FORM_FILTER]
	EndIF
next nX

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

Dbselectarea(cAliasQry)
dbgotop()

While (cAliasQry)->(!EOF())
	For nX := 1 To Len(oStruSN4:aFields)
		If ! oStruSN4:aFields[nX, MVC_VIEW_VIRTUAL]
			If GetSx3Cache(oStruSN4:aFields[nX, MVC_VIEW_IDFIELD],'X3_TIPO') == 'D'
				xValor := SN4->&(oStruSN4:aFields[nX, MVC_VIEW_IDFIELD])
				xValor := StrTran(DTOC(xValor), "/", ".")
				oSecSN4:Cell(oStruSN4:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(xValor)
			Else
				oSecSN4:Cell(oStruSN4:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)-> &(oStruSN4:aFields[nX, MVC_VIEW_IDFIELD]))
			EndIf
		EndIf
	Next nX
	oSecSN4:Printline()
	(cAliasQry)->(dbSkip())
EndDo
oSecSN4:Finish()
//Separator
oReport:ThinLine()
oSecSN1:Finish()
Return(NIL)

/*/{Protheus.doc} RU01S01PR

Fill user name

@param		NUMERIC nRec
@return		CHARACTER name of user
@author 	Alexandra Menyashina
@since 		20/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function RU01S01USN(nRec as NUMERIC)
Local aArea		AS CHARACTER
Local aAreaSN4	AS CHARACTER
Local cUserA	AS CHARACTER
Local cUserI	AS CHARACTER

aArea := GetArea()
aAreaSN4 := SN4->(GetArea())
SN4->(DBGoTo(nRec))

cUserA := FWLeUserlg("N4_USERLGA")
cUserI := FWLeUserlg("N4_USERLGI")

Return Iif(Empty(cUserA),cUserI,cUserA)