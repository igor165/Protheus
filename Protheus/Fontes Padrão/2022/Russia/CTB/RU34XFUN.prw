#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} 
// Management Accounting Generic Function

@author Victor Guberniev
@since 28/03/2018
@version MA3 - Russia
/*/

Function SelectNotEmpty(cPar1 as Character, cPar2 as Character)
Local cRet as Character

If !(Empty(cPar1))
   cRet := cPar1
Else 
   cRet := cPar2
EndIf         

Return cRet

/*/{Protheus.doc} RU34XFUN
Function to get the value of the specified parameters from the table Accounting groups

description:
    The parameter cRequested may have two states - '1' or '2'
    '1' - for F46_OWNER == 'PD' (Product)
        Other parameters:
        cCode - Account Group Code (F46_CODE)
        cProdCode - Product Code (B1_COD)
        cWarOrCon - Warehouse Code (NNR_CODIGO)
    '2' - for F46_OWNER == 'PT' (Parther)
        Other parameters:
        cCode - Account Group Code (F46_CODE)
        cProdCode - not use for Partners
        cWarOrCon - Contract code (F5Q_CODE)
    cExpected - The field that you want to return. It may have a four states:
      '1' - returns Ledger Account (F46_CONTA)
      '2' - returns Cost Center (F46_CCUSTO)
      '3' - returns Accounting Item (F46_ITEMCC)
      '4' - returns Value Class (F46_CLVL)

FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function GetAccEnt(cRequested as Character, cCode as Character, cProdCode as Character, cWarOrCon as Character, cExpected as Character)

Local cTab              as Character
Local nCurType          as Numeric
Local cCurType          as Character
Local lPriority         as Logical
Local lPriorDif         as Logical
Local cWHType           as Character
Local cContrType        as Character
Local aArea             as Array
Local cQuery            as Character
Local aRawResult        as Array 
Local cProdType         as Character
Local cResult           as Character
Local aMvPar            as Array
Local nX                as Numeric  

Default cCode       := ''
Default cProdCode   := '' 
Default cWarOrCon   := ''
Default cRequested  := ''
Default cExpected   := ''

nX          := 1
aMvPar      := {}
cWHType     := PadR(cWHType, GetSX3Cache("F46_WHSETP", "X3_TAMANHO"), " ")
cProdType   := PadR(cProdType, GetSX3Cache("F46_PRDGRP", "X3_TAMANHO"), " ")
cContrType  := PadR(cContrType, GetSX3Cache("F46_CNTRTP", "X3_TAMANHO"), " ")
nCurType    := 1
aArea       := GetArea()
cCode       := PadR(cCode, GetSX3Cache("F46_CODE", "X3_TAMANHO"), " ")

//Save parameters pergunte to be restored in the end of the function 
While TYPE( ( "MV_PAR" + StrZero( nX, 2, 0 ) ) ) != "U"
    aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
    nX++
EndDo

IF (cRequested == '1')

    RU34XFUN03_GetTipoProduct(cProdCode, cWarOrCon, @cProdType, @cWHType)
    Pergunte("RU34D01PRD", .F.)
    lPriority := Iif(MV_PAR01 == 1, .T., .F.)
    lPriorDif := MV_PAR02 < MV_PAR03

    Do Case

        Case (lPriority .AND. lPriorDif)
            aRawResult := RU34XFUN04_GetRawResult(cCode, 2, cProdType, cWHType)
        Case (lPriority .AND. !lPriorDif)
            aRawResult := RU34XFUN04_GetRawResult(cCode, 3, cWHType, cProdType)
        Case (!lPriority)
            
            cQuery :=   "SELECT F46_CONTA, F46_CCUSTO, F46_ITEMCC, F46_CLVL FROM " +  RetSQLName("F46") + " MYF46"+;
                        " WHERE (MYF46.F46_FILIAL = '" + xFilial("F46") + "' OR MYF46.F46_FILIAL = '')"+;
                        " AND MYF46.F46_CODE = '" + cCode + "'"+;
                        " AND MYF46.F46_PRDGRP = '" + cProdType + "'"+;
                        " AND MYF46.F46_WHSETP = '" + cWHType + "'"+;
                        " AND MYF46.D_E_L_E_T_ = ''"
            cQuery := ChangeQuery(cQuery)

            cTab := MPSysOpenQuery(cQuery)
            DbSelectArea((cTab))
            If !((cTab)->(Eof()))
                aRawResult := {(cTab)->F46_CONTA, (cTab)->F46_CCUSTO, (cTab)->F46_ITEMCC, (cTab)->F46_CLVL}
            Else
                aRawResult := {'','','',''}
            EndIf
            (cTab)->(DbCloseArea())

    EndCase

Else

    RU34XFUN02_GetTipoPartners(cWarOrCon, @cContrType, @nCurType)
    cCurType := ALLTRIM(Str(nCurType))
    cContrType := PadR(cContrType, GetSX3Cache("F46_CNTRTP", "X3_TAMANHO"), " ")
    Pergunte("RU34D01PRN", .F.)
    lPriority := Iif(MV_PAR01 == 1, .T., .F.)
    lPriorDif := MV_PAR02 < MV_PAR03

    Do Case

        Case (lPriority .AND. lPriorDif)
            aRawResult := RU34XFUN04_GetRawResult(cCode, 5, cContrType, cCurType)
        Case (lPriority .AND. !lPriorDif)            
            aRawResult := RU34XFUN04_GetRawResult(cCode, 4, cCurType, cContrType)
        Case (!lPriority)

            cQuery :=   "SELECT F46_CONTA, F46_CCUSTO, F46_ITEMCC, F46_CLVL FROM " +  RetSQLName("F46") + " MYF46"+;
                        " WHERE (MYF46.F46_FILIAL = '" + xFilial("F46") + "' OR MYF46.F46_FILIAL = '')"+;
                        " AND MYF46.F46_CODE = '" + cCode + "'"+;
                        " AND MYF46.F46_CURRTP = '" + cCurType + "'"+;
                        " AND MYF46.F46_CNTRTP = '" + cContrType + "'"+;
                        " AND MYF46.D_E_L_E_T_ = ''"
            cQuery := ChangeQuery(cQuery)

            cTab := MPSysOpenQuery(cQuery)
            DbSelectArea((cTab))
            If !((cTab)->(Eof()))
                aRawResult := {(cTab)->F46_CONTA, (cTab)->F46_CCUSTO, (cTab)->F46_ITEMCC, (cTab)->F46_CLVL}
            Else                
                aRawResult := {'','','',''}
            EndIf
            (cTab)->(DbCloseArea())       

    EndCase

Endif

Do Case
    Case (cExpected == '1')
        cResult = aRawResult[1]
    Case (cExpected == '2')
        cResult = aRawResult[2]
    Case (cExpected == '3')
        cResult = aRawResult[3]
    Case (cExpected == '4')
        cResult = aRawResult[4]
    Otherwise
        cResult = '' 
EndCase

// Restore the MV_ from PERGUNTES so it will not crash the caller routine 
For nX := 1 To Len( aMvPar )
    &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
Next nX

RestArea(aArea)

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RU34XFUN01

It is returns a currency type for a contract

author:   Vadim Ivanov
since:    23/05/2019
version:  1.0
project:  MA3 - Russia
-------------------------------------------------------------------/*/

Function RU34XFUN01(cCode as Character)

Local cCurType  as Character
Local cRet      as Character
Local aArea     as Array

aArea := GetArea()

cCurType := "1" // Available currency types: 1 - Rubles, 2 - Foreign, 3 - Conventional units

If !Empty(cCode)
    dbSelectArea("F5Q")
    dbSetOrder(2)
    If Posicione("F5Q", 2, xFilial("F5Q") + cCode, "F5Q_MOEDA") != 1
        cRet := Posicione("F5Q", 2, xFilial("F5Q") + cCode, "F5Q_CONUNI")
        Do Case
            Case cRet == "1"
                cCurType := "3"
            Case cRet == "2"
                cCurType := "2"
        EndCase
    EndIf
EndIf

RestArea(aArea)

Return cCurType
 
/*/{Protheus.doc} CTBC662PRT

Print

@return		Nil
@author 	Alexandra Menyashina
@since 		21/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function CTBC662PRT()
	Local oReport	AS OBJECT
	Local cName		AS CHARACTER

	cName	:= 'CTBC662'
	oReport := CTBC662RDF(cName)
	oReport:PrintDialog()
return Nil

/*/{Protheus.doc} CTBC662RDF

Print report definition

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		21/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function CTBC662RDF(cName)
	Local oReport	AS OBJECT
	Local oSecSN1	AS OBJECT
	Local oSecCT2	AS OBJECT
	Local oStruSN1	AS OBJECT
	Local oStruCT2	AS OBJECT
	Local nX		AS NUMERIC

	oStruSN1 := FWFormStruct(2, "SN1", {|x| (AllTrim(x) $ "N1_FILIAL|N1_CBASE|N1_ITEM|N1_DESCRIC")})
	oStruCT2 := FWFormStruct( 2, 'CT2' )

	oReport := TReport():New(cName/*cReport*/,"Print FA Accounting Enteries"/*cTitle*/,cName,{|oReport| CTBC662PR(oReport)},"PRINT", .F./*<lLandscape>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<cPageTText>*/ , .F./*<lPageTInLine>*/ , .F./*<lTPageBreak>*/ , /*<nColSpace>*/ )

	oReport:lParamPage	:= .F.	//Don't print patameter page
	//Header info
	oSecSN1 := TRSection():New(oReport,"",{'SN1'} , , .F., .T.)
	For nX := 1 To Len(oStruSN1:aFields)
		If ! oStruSN1:aFields[nX, MVC_VIEW_VIRTUAL]
			TRCell():New(oSecSN1,oStruSN1:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"SN1", alltrim(oStruSN1:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
		EndIf
	Next nX

	//Detail info
	oSecCT2 := TRSection():New(oReport,"",{'CT2'} , , .F., .T.)
	For nX := 1 To Len(oStruCT2:aFields)
		If ! oStruCT2:aFields[nX, MVC_VIEW_VIRTUAL]
			TRCell():New(oSecCT2,oStruCT2:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"CT2", alltrim(oStruCT2:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
		EndIf
	Next nX
	
Return oReport

/*/{Protheus.doc} CTBC662PR

Print prepare data

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		21/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
STATIC Function CTBC662PR(oReport)
	Local oSecSN1 		AS OBJECT
	Local oSecCT2		AS OBJECT
	Local oStruSN1		AS OBJECT
	Local oStruCT2		AS OBJECT
	Local cAliasQry		AS CHARACTER
	Local cQuery		AS CHARACTER
	Local cBase			AS CHARACTER
	Local cItem			AS CHARACTER
	local lRet			AS LOGICAL
	Local nX			AS NUMERIC
	Local xValor

	oStruSN1 := FWFormStruct(2, "SN1", {|x| (AllTrim(x) $ "N1_FILIAL|N1_CBASE|N1_ITEM|N1_DESCRIC")})
	oStruCT2 := FWFormStruct( 2, 'CT2' )

	oSecSN1		:= oReport:Section(1)
	oSecCT2		:= oReport:Section(2)
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

	oSecCT2:init()

	cQuery	:= " select  CT2.R_E_C_N_O_ CT2RECNO "

	For nX := 1 To Len(oStruCT2:aFields)
		If ! oStruCT2:aFields[nX, MVC_VIEW_VIRTUAL]
			cQuery  += "," + oStruCT2:aFields[nX, MVC_VIEW_IDFIELD]
		EndIf
	Next nX

	cQuery	+= " FROM "+ RetSQLName("SN1") +" N1 "
	cQuery	+= " JOIN "	+ RetSQLName("SN4") +" N4 "
	cQuery	+= " ON N4_CBASE = N1_CBASE"
	cQuery	+= " AND N4_ITEM = N1_ITEM"
	cQuery	+= " JOIN "	+ RetSQLName("CV3") +" CV3 "
	cQuery	+= " ON CV3_RECORI = CAST(N4.R_E_C_N_O_ AS BPCHAR(17))"
	cQuery	+= " JOIN "	+ RetSQLName("CT2") +" CT2 "
	cQuery	+= " ON CT2.R_E_C_N_O_ = CAST(CV3_RECDES AS INT4)"
	cQuery	+= " WHERE	CT2.CT2_FILIAL = '" + xFilial("CT2") + "'"
	cQuery	+= " AND 	N1.N1_FILIAL = '" + xFilial("SN1") + "'"
	cQuery	+= " AND 	CV3.CV3_FILIAL = '" + xFilial("CV3") + "'"
	cQuery	+= " AND 	N4.N4_FILIAL = '" + xFilial("SN4") + "'"
	cQuery	+= " AND	N4.D_E_L_E_T_ = ' '"
	cQuery	+= " AND	CT2.D_E_L_E_T_ = ' '"
	cQuery	+= " AND	N1.D_E_L_E_T_ = ' '"
	cQuery	+= " AND	CV3.D_E_L_E_T_ = ' '"
	cQuery	+= " AND 	CV3_RECDES <> ' '"
	cQuery	+= " AND 	CV3_TABORI = 'SN4'"
	cQuery	+= " AND 	N1.N1_CBASE	= '" + cBase + "' "
	cQuery	+= " AND	N1.N1_ITEM	= '" + cItem + "' "

	cQuery   := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	Dbselectarea(cAliasQry)
	dbgotop()

	While (cAliasQry)->(!EOF())
		For nX := 1 To Len(oStruCT2:aFields)
			If ! oStruCT2:aFields[nX, MVC_VIEW_VIRTUAL]
				If GetSx3Cache(oStruCT2:aFields[nX, MVC_VIEW_IDFIELD],'X3_TIPO') == 'D'
					xValor := CT2->&(oStruCT2:aFields[nX, MVC_VIEW_IDFIELD])
					xValor := StrTran(DTOC(xValor), "/", ".")
					oSecCT2:Cell(oStruCT2:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(xValor)
				Else
					oSecCT2:Cell(oStruCT2:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)-> &(oStruCT2:aFields[nX, MVC_VIEW_IDFIELD]))
				EndIf
			EndIf
		Next nX
		oSecCT2:Printline()
		(cAliasQry)->(dbSkip())
	EndDo
	oSecCT2:Finish()
	//Separator
	oReport:ThinLine()
	oSecSN1:Finish()
Return(NIL)

/*/{Protheus.doc} RU34XFUN
Function to get the type of contract and currency from F5Q table
FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU34XFUN02_GetTipoPartners(cContrCode as Character, cContrType as Character, nCurType as Numeric)

Local cQuery        as Character
Local cTab        as Character

If cContrCode != ''

    cQuery :=   "SELECT F5Q_TYPE, F5Q_MOEDA, F5Q_CONUNI FROM " +  RetSQLName("F5Q") + " MYF5Q"+;
                " WHERE (MYF5Q.F5Q_FILIAL = '" + xFilial("F5Q") + "' OR MYF5Q.F5Q_FILIAL = '')"+;
                " AND MYF5Q.F5Q_UID = '" + cContrCode + "'"+;
                " AND MYF5Q.D_E_L_E_T_ = ''"
    cQuery := ChangeQuery(cQuery)

    cTab := MPSysOpenQuery(cQuery)
    DbSelectArea((cTab))
    If !((cTab)->(Eof()))

        If (cTab)->F5Q_MOEDA > 1
            If (cTab)->F5Q_CONUNI == "2"
                nCurType := 2
            Else
                nCurType := 3
            EndIf
        Else
            nCurType := (cTab)->F5Q_MOEDA
        EndIf
        cContrType := (cTab)->F5Q_TYPE

    EndIf
    (cTab)->(DbCloseArea())

Endif

Return

/*/{Protheus.doc} RU34XFUN
Function to get the type of product group and warehouse type(group!) from SB1 and NNR tables
FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU34XFUN03_GetTipoProduct(cProdCode as Character, cWHCode as Character, cProdType as Character, cWHType as Character)

Local cQuery        as Character
Local cTab          as Character

If cWHCode != ''

    cQuery :=   "SELECT NNR_WHSETP FROM " +  RetSQLName("NNR") + " MYNNR"+;
                " WHERE (MYNNR.NNR_FILIAL = '" + xFilial("NNR") + "' OR MYNNR.NNR_FILIAL = '')"+;
                " AND MYNNR.NNR_CODIGO = '" + cWHCode + "'"+;
                " AND MYNNR.D_E_L_E_T_ = ''"
    cQuery := ChangeQuery(cQuery)

    cTab := MPSysOpenQuery(cQuery)
    DbSelectArea((cTab))

    If !((cTab)->(Eof()))

        cWHType := (cTab)->NNR_WHSETP 

    EndIf

    (cTab)->(DbCloseArea())

Endif

If cProdCode != ''

    cQuery :=   "SELECT MYSBM.BM_TIPGRU FROM " +  RetSQLName("SB1") + " MYSB1"+;
                " LEFT JOIN " + RetSQLName("SBM") + " MYSBM ON MYSB1.B1_GRUPO = MYSBM.BM_GRUPO"+;
                " WHERE (MYSB1.B1_FILIAL = '" + xFilial("SB1") + "' OR MYSB1.B1_FILIAL = '')"+;
                " AND MYSB1.B1_COD = '" + cProdCode + "'"+;
                " AND MYSB1.D_E_L_E_T_ = ''"+;
                " AND MYSBM.D_E_L_E_T_ = ''"
    cQuery := ChangeQuery(cQuery)

    cTab := MPSysOpenQuery(cQuery)
    DbSelectArea((cTab))

    If !((cTab)->(Eof()))

        cProdType := (cTab)->BM_TIPGRU

    EndIf

    (cTab)->(DbCloseArea())

Endif

Return .T.

/*/{Protheus.doc} RU34XFUN
Function to get the all returned values from F46 to Products
FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU34XFUN04_GetRawResult(cCode as Character, nOrder as Numeric, cFirstParam as Character, cSecondParam as Character)
Local aAreaF46      as Character
Local aRawResult    as Array
LOCAL aIndex        as Array
Local aPadr         as Array
Local nCurtyp       as Numeric



aPadr:= {}
nCurtyp := 0 
aRawResult = {'','','',''}
aAreaF46 := F46->(GetArea())

DbSelectArea('F46')
F46->(DbSetOrder(nOrder))
aIndex := StrTokArr( IndexKey( nOrder), "+" )

AADD( aPadr, {aIndex[3], PadR(" ", GetSX3Cache(aIndex[3], "X3_TAMANHO"), " ")} )
AADD( aPadr, {aIndex[4], PadR(" ", GetSX3Cache(aIndex[4], "X3_TAMANHO"), " ")} )
If  aScan(aPadr, {|x| AllTrim(x[1]) == "F46_CURRTP" } ) > 0 
    nCurtyp = aScan(aPadr, {|x| AllTrim(x[1]) == "F46_CURRTP" } )
    aPadr[nCurtyp][2] :=PadR("1", GetSX3Cache(aPadr[nCurtyp][1], "X3_TAMANHO"), " ")
ENDIF


If (F46->(Dbseek(xFilial("F46") + cCode + cFirstParam + cSecondParam)) )
    aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
ElseIf (F46->(Dbseek(xFilial("F46") + cCode + cFirstParam + aPadr[2][2])) )
    aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
ElseIf (F46->(Dbseek(xFilial("F46") + cCode + aPadr[1][2] + cSecondParam)) )
    aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
ElseIf (F46->(Dbseek(xFilial("F46") + cCode  +aPadr[1][2]+ aPadr[2][2])) )
    aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
ElseIf nCurtyp > 0 
    aPadr[nCurtyp][2] :=PadR(" ", GetSX3Cache(aPadr[nCurtyp][1], "X3_TAMANHO"), " ")
    If (F46->(Dbseek(xFilial("F46") + cCode + cFirstParam + aPadr[2][2])) )
        aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
    ElseIf (F46->(Dbseek(xFilial("F46") + cCode  +aPadr[1][2]+ cSecondParam)) )
        aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
    ElseIf (F46->(Dbseek(xFilial("F46") + cCode  +aPadr[1][2]+ aPadr[2][2])) )
        aRawResult := {F46->F46_CONTA, F46->F46_CCUSTO, F46->F46_ITEMCC, F46->F46_CLVL}
    EndIf        
EndIf
RestArea(aAreaF46)

Return aRawResult

/*/{Protheus.doc} RU34XFUN
Function to validation perguntas in RU34D01 and RU34D02
FI-AP-17-14
@author alexander.kharchenko
@since 14/11/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU34XFUN05_RU34D01VPr()

Local lResult as Logical

lResult := .T.

If((MV_PAR01 == 1 .AND. MV_PAR02 == MV_PAR03) .OR. MV_PAR02 == 0 .OR. MV_PAR03 == 0)
    lResult := .F.
EndIf

Return lResult