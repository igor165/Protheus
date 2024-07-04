#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"

/*
Authors: Artem Kostin, Artem Nikitenko
E-mail: akostin@national-platform.ru
Data: 12/13/2017
Description: Dataset for "SALES BOOK" BIRT report.
*/

dataset RU09T04DS
Title 'SB'
Description "SB"

PERGUNTE "RU09T04"

Columns
define Column F39_FILIAL	TYPE CHARACTER SIZE 30 DECIMALS 0 LABEL 'F39_FILIAL-1h'
define Column F39_CODE1		TYPE CHARACTER SIZE 30 DECIMALS 0 LABEL 'F39_CODE-2h1'
define Column F39_CODE2		TYPE CHARACTER SIZE 30 DECIMALS 0 LABEL 'F39_CODE-2h2'
define Column F39_STATUS	TYPE CHARACTER SIZE 18 DECIMALS 0 LABEL 'F39_STATUS-3h'
define Column F39_INIT		TYPE CHARACTER SIZE 12 DECIMALS 0 LABEL 'F39_INIT-4h'
define Column F39_FINAL		TYPE CHARACTER SIZE 12 DECIMALS 0 LABEL 'F39_FINAL-5h'
define Column F3A_DOC 		TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'F3A_DOC-1'
define Column F3A_PDATE 	TYPE CHARACTER SIZE 11 DECIMALS 0 LABEL 'F3A_PDATE-2'
define Column F2_EMISSAO	TYPE CHARACTER SIZE 11 DECIMALS 0 LABEL 'F2_EMISSAO-3'
define Column F35_ADJNR 	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'F35_ADJNR-4'
define Column F35_CLIENT 	TYPE CHARACTER SIZE 12 DECIMALS 0 LABEL 'F35_CLIENT-5'
define Column F35_BRANCH	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'F35_BRANCH-6'
define Column A1_NOME 		TYPE CHARACTER SIZE 250 DECIMALS 0 LABEL 'A1_NOME-7'
define Column A1_INSCGAN 	TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL 'A1_INSCGAN-8'
define Column F35_ADVPM 	TYPE CHARACTER SIZE 50 DECIMALS 0 LABEL 'F35_ADVPM-9?'
define Column F3A_VATCOD	TYPE CHARACTER SIZE 5 DECIMALS 0 LABEL 'F3A_VATCOD-10'
define Column F3A_VATCD2 	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'F3A_VATCD2-11'
define Column F36_VALGR 	TYPE CHARACTER SIZE 50 DECIMALS 0 LABEL 'F36_VALGR-12'
define Column F36_VATBS 	like F36_VATBS
define Column F36_VATRT 	like F36_VATRT
define Column F35_INVSER 	TYPE CHARACTER SIZE 4 DECIMALS 0 LABEL 'F35_INVSER-19'
define Column F35_INVDOC 	TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'F35_INVDOC-20'
define Column F35_INVCUR 	TYPE CHARACTER SIZE 6 DECIMALS 0 LABEL 'F35_INVCUR-21'
define Column F36_VATB1		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F36_VATB1' //1
define Column F36_VATB2		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F36_VATB2'
define Column F36_VATB3		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F36_VATB3'
define Column F36_VATB4		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F36_VATB4'
define Column F36_VATV1		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F36_VATV1'
define Column F36_VATV2		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F36_VATV2'
define Column F3A_CNEE_C	TYPE CHARACTER SIZE 7 DECIMALS 0 LABEL 'F3A_CNEE_C'
define Column F3A_CNEE_B	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'F3A_CNEE_B'
define Column F3A_CNOR_C	TYPE CHARACTER SIZE 7 DECIMALS 0 LABEL 'F3A_CNOR_C'
define Column F3A_CNOR_B	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'F3A_CNOR_B'
define Column TOTAL_T1		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T1'
define Column TOTAL_T2		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T2'
define Column TOTAL_T3		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T3'
define Column TOTAL_T4		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T4'
define Column TOTAL_T5		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T5'
define Column TOTAL_T6		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T6'
define Column NLINE		TYPE CHARACTER SIZE 8 DECIMALS 0 LABEL 'NLINE'
define query 	"SELECT * FROM %WTable:1% "
process dataset

Local cWTabAlias as Char
Local lRet as Logical
Local aSelFil as Array

lRet := .F.
aSelFil := {}

If alltrim(str(MV_PAR13)) = '1'	// Filter by branches
	aSelFil := AdmGetFil()
Else
	aSelFil := {cFilAnt}
EndIf

cWTabAlias := ::createWorkTable()

chkFile("F3A")

Processa({|_lEnd| lRet := X60NOT(cWTabAlias, aSelFil)}, ::title())

Return .T.

Static Function X60NOT(cWTabAlias, aSelFil)
Local aArea, aRet as array
Local nBase18Total, nBase10Total, nBase00Total, nBase__Total, nValue18Total, nValue10Total, nNLine as Numeric
Local cAliasTMP, cQuery as Char
Local nF as Numeric
Local nCode as Numeric
Local aVATCode as Array

nNLine := 0

nBase18Total := nBase10Total := nBase00Total := nBase__Total := nValue18Total := nValue10Total := 0


For nF:=1 to Len(aSelFil)
	aRet := {}
	
	// Reading from the database according to the chosen parameters.
	aArea := getArea()
	cAliasTMP := GetNextAlias()
	cQuery := " SELECT F39_FILIAL, F39_CODE, F39_STATUS, F39_INIT, F39_FINAL, F3A_DOC, F3A_PDATE, F2_EMISSAO, F35_ADJNR, F35_CLIENT, F35_BRANCH, F35_ADVPM," 
	cQuery += " F3A_VATCOD, F3A_VATCD2, F35_VALGR AS F36_VALGR, F35_INVSER, F35_INVDOC, F35_INVCUR, F30_DESC, CTO_DESCUN, A1_NOME, A1_INSCGAN,"
	cQuery += " F3A_VATBS, F3A_VATRT, F3A_VATVL"
	cQuery += " FROM " + RetSqlName("F39") + " F39"
	cQuery += " INNER JOIN " + RetSqlName("F3A") + " F3A"
	cQuery += " ON F3A.D_E_L_E_T_ = ' '"
	cQuery += " AND F3A_CODE = F39_CODE"
	cQuery += " AND F3A_FILIAL = '"+ xfilial('F3A',aSelFil[nF]) +"' "
	cQuery += " INNER JOIN " + RetSqlName("F35") + " F35"
	cQuery += " ON F35.D_E_L_E_T_ = ' '"
	cQuery += " AND F3A_KEY = F35_KEY"
	cQuery += " AND F35_filial = '" +xfilial('F35',aSelFil[nF])+ "'"
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery += " ON SA1.D_E_L_E_T_ = ' '"
	cQuery += " AND A1_COD = F35_CLIENT"
	cQuery += " AND A1_LOJA = F35_BRANCH"
	cQuery += " AND A1_filial = '" +xfilial('SA1',aSelFil[nF])+ "'"
	cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2"
	cQuery += " ON SF2.D_E_L_E_T_ = ' '"
	cQuery += " AND F2_DOC = F35_INVDOC"
	cQuery += " AND F2_SERIE = F35_INVSER"
	cQuery += " AND F2_FILIAL = '"+xfilial('SF2',aSelFil[nF])+"' "
	cQuery += " INNER JOIN " + RetSqlName("F31") + " F31"
	cQuery += " ON F31.D_E_L_E_T_ = ' '"
	cQuery += " AND F31_CODE = F3A_VATCOD"
	cQuery += " AND F31_filial = '" +xfilial('F31',aSelFil[nF])+ "'"
	cQuery += " INNER JOIN " + RetSqlName("F30") + " F30"
	cQuery += " ON F30.D_E_L_E_T_ = ' '"
	cQuery += " AND F30_CODE = F31_RATE"
	cQuery += " AND F30_filial = '" +xfilial('F30',aSelFil[nF])+ "'"
	cQuery += " INNER JOIN " + RetSqlName("CTO") + " CTO"
	cQuery += " ON CTO.D_E_L_E_T_ = ' '"
	cQuery += " AND CTO_filial = '" +xfilial('CTO',aSelFil[nF])+ "'"
	cQuery += " AND TRIM(REPLACE (CTO.CTO_MOEDA, '0',''))  = TRIM(REPLACE (F35.F35_INVCUR, '0','')) " 

	cQuery += " WHERE F39.D_E_L_E_T_ = ' '"
	If !Empty(MV_PAR01)
		cQuery += " AND F39_INIT >= '" + DtoS(MV_PAR01) + "'"	// From period of a Sales Book
	Endif
	If !Empty(MV_PAR02)
		cQuery += " AND F39_FINAL <= '" + DtoS(MV_PAR02) + "'"	// To period of a Sales Book
	Endif
	If !Empty(MV_PAR03)
	cQuery += " AND F39_STATUS = '" + alltrim(str(MV_PAR03)) + "'"	// Status of a Sales Book
	Endif
	cQuery += " AND F39_FILIAL ='"+xfilial('F39',aSelFil[nF])+"' "
	If !Empty(MV_PAR04)
		// Parse stings of Internal VAT Codes by delimiter ";"
		aVATCode = Str2Arr( MV_PAR04, ";" )
		cQuery += " AND F3A_VATCOD IN ( "
		// Go though the set of Internal VAT Codes, except last one.
		For nCode := 1 to (Len(aVATCode)-1)
			cQuery += "'" + AllTrim(aVATCode[nCode]) + "',"	// Filter by Internal VAT codes
		End
		// After the loop iterator equals number of the last element of the array.
		// We add this last element and close condition with single quote and right parenthesis.
		cQuery += "'" + AllTrim(aVATCode[nCode]) + "' )"
	Endif
	If !Empty(MV_PAR05)
		cQuery += " AND F39_CODE >= '" + (MV_PAR05) + "'"	// From a Sales Book Code
	Endif
	If !Empty(MV_PAR06)
		cQuery += " AND F39_CODE <= '" + (MV_PAR06) + "'"	// To a Sales Book Code
	Endif
	If !Empty(MV_PAR07)
		cQuery += " AND F35_DOC >= '" + (MV_PAR07) + "'"	// From a VAT Sales Invoice number
	Endif
	If !Empty(MV_PAR08)
		cQuery += " AND F35_DOC <= '" + (MV_PAR08) + "'"	// To a VAT Sales Invoice number
	Endif
	If !Empty(MV_PAR09)
		cQuery += " AND F35_CLIENT >= '" + (MV_PAR09) + "'"	// From customer
	Endif
	If !Empty(MV_PAR10)
		cQuery += " AND F35_BRANCH >= '" + (MV_PAR10) + "'"	// From branch
	EndIf
	If !Empty(MV_PAR11)
		cQuery += " AND F35_CLIENT <= '" + (MV_PAR11) + "'"	// To customer
	Endif
	If !Empty(MV_PAR12)
		cQuery += " AND F35_BRANCH <= '" + (MV_PAR12) + "'"	// To branch
	EndIf
	cQuery += " ORDER BY F3A_DOC , F3A_PDATE "
	
    cQuery := ChangeQuery(cQuery)	
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTMP, .T., .T.)
	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbGotop())
	
	aRet := FwComAltInf({'CO_FULLNAM'})
	
	
	// Writing into the report's variables
	While (cAliasTMP)->(!EOF())
		RecLock(cWTabAlias, .T.)
		
		nNLine := nNLine + 1
		NLINE 			:= alltrim(str(nNLine))
	
		F39_FILIAL		:= aRet[1][2]
		F39_CODE1		:= (MV_PAR05)
		F39_CODE2		:= (MV_PAR06)
	
		if (cAliasTMP)->F39_STATUS = '1'
			F39_STATUS		:=  ''
		else
			if (cAliasTMP)->F39_STATUS='2'
				F39_STATUS		:= ''
			else
				F39_STATUS		:= ''
			endif
		endif
		
		//items
		F39_INIT := StrTran(DtoC(MV_PAR01), "/", ".")
		F39_FINAL := StrTran(DtoC(MV_PAR02), "/", ".")
	
		F3A_DOC := (cAliasTMP)->F3A_DOC
		F3A_PDATE := StrTran(DTOC(Stod((cAliasTMP)->F3A_PDATE)), "/", ".")
		F2_EMISSAO := StrTran(DTOC(Stod((cAliasTMP)->F2_EMISSAO)), "/", ".")
		F35_ADJNR := (cAliasTMP)->F35_ADJNR
		F35_CLIENT := (cAliasTMP)->F35_CLIENT
		F35_BRANCH := (cAliasTMP)->F35_BRANCH
		A1_NOME := (cAliasTMP)->A1_NOME
		A1_INSCGAN := (cAliasTMP)->A1_INSCGAN
		
		F35_ADVPM := (cAliasTMP)->F35_ADVPM
		F3A_VATCOD := (cAliasTMP)->F3A_VATCOD
		F3A_VATCD2 := (cAliasTMP)->F3A_VATCD2
		F36_VALGR := Alltrim(TRANSFORM((cAliasTMP)->F36_VALGR, "@E 999,999,999,999,999.99"))  
			
		F36_VATBS := (cAliasTMP)->F3A_VATBS
		F36_VATRT := (cAliasTMP)->F3A_VATRT
			
		If (cAliasTMP)->F30_DESC = '18%'
			F36_VATB1 := Alltrim(TRANSFORM((cAliasTMP)->F3A_VATBS, "@E 999,999,999,999,999.99"))  
			nBase18Total +=  (cAliasTMP)->F3A_VATBS
		ElseIf (cAliasTMP)->F30_DESC = '10%'
			F36_VATB2 := Alltrim(TRANSFORM((cAliasTMP)->F3A_VATBS, "@E 999,999,999,999,999.99")) 
			nBase10Total += (cAliasTMP)->F3A_VATBS
		ElseIf (cAliasTMP)->F30_DESC = '0%'
			F36_VATB3 := Alltrim(TRANSFORM((cAliasTMP)->F3A_VATBS, "@E 999,999,999,999,999.99")) 
			nBase00Total += (cAliasTMP)->F3A_VATBS
		Else
			F36_VATB4 := Alltrim(TRANSFORM((cAliasTMP)->F3A_VATBS, "@E 999,999,999,999,999.99")) 
			nBase__Total += (cAliasTMP)->F3A_VATBS
		Endif
			
		If (cAliasTMP)->F30_DESC = '18%'
			F36_VATV1 := Alltrim(TRANSFORM((cAliasTMP)->F3A_VATVL, "@E 999,999,999,999,999.99")) 
			nValue18Total += (cAliasTMP)->F3A_VATVL
		ElseiF (cAliasTMP)->F30_DESC = '10%'
			F36_VATV2 := Alltrim(TRANSFORM((cAliasTMP)->F3A_VATVL, "@E 999,999,999,999,999.99")) 
			nValue10Total += (cAliasTMP)->F3A_VATVL
		Endif
			
		F35_INVSER := (cAliasTMP)->F35_INVSER
		F35_INVDOC := (cAliasTMP)->F35_INVDOC
		F35_INVCUR := (cAliasTMP)->CTO_DESCUN
			
		F3A_CNEE_C := ''
		F3A_CNEE_B := ''
		F3A_CNOR_C := ''
		F3A_CNOR_B := ''
				
		TOTAL_T1 := Alltrim(TRANSFORM(nBase18Total, "@E 999,999,999,999,999.99")) 
		TOTAL_T2 := Alltrim(TRANSFORM(nBase10Total, "@E 999,999,999,999,999.99")) 
		TOTAL_T3 := Alltrim(TRANSFORM(nBase00Total, "@E 999,999,999,999,999.99")) 
		TOTAL_T4 := Alltrim(TRANSFORM(nBase__Total, "@E 999,999,999,999,999.99")) 
		TOTAL_T5 := Alltrim(TRANSFORM(nValue18Total, "@E 999,999,999,999,999.99")) 
		TOTAL_T6 := Alltrim(TRANSFORM(nValue10Total, "@E 999,999,999,999,999.99")) 
	
		MsUnlock()
		(cAliasTMP)->(dbSkip())
	EndDo
	
	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
Next nF

return .T.