#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"
#include "RU09T05_PS.CH"

/*
Author: Artem Nikitenko
E-mail: 
Data: 09/04/2018
Description: Dataset for "Purchase Book" BIRT report.
*/

dataset RU09T05DS
Title 'PB'
Description "PB"

PERGUNTE "RU09T05"
 
Columns
define Column H_BRANCH		TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'H_BRANCH'
define Column H_PURCODF		TYPE CHARACTER SIZE 30 DECIMALS 0 LABEL 'H_PBOOKS'
define Column H_PURCODT		TYPE CHARACTER SIZE 30 DECIMALS 0 LABEL 'H_PBOOKSS'
define Column H_DATEF		TYPE CHARACTER SIZE 18 DECIMALS 0 LABEL 'H_DATE1' 
define Column H_DATET		TYPE CHARACTER SIZE 12 DECIMALS 0 LABEL 'H_DATE2'
define Column H_STATUS		TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'H_STATUS'

define Column F37_DOC		TYPE CHARACTER SIZE 30 DECIMALS 0 LABEL 'F37_DOC'
define Column F37_PDATE 	TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'F37_PDATE'
define Column F37_ADJNR 	TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'F37_ADJNR'

define Column F37_RDATE		TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'F37_RDATE'


define Column F37_INVDT 	TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'F37_INVDT'
define Column F37_PAYM	 	TYPE CHARACTER SIZE 50 DECIMALS 0 LABEL 'F37_PAYM'
define Column F37_FORNEC	TYPE CHARACTER SIZE 6 DECIMALS 0 LABEL 'F37_FORNEC'

define Column A2_LOJA 		TYPE CHARACTER SIZE 250 DECIMALS 0 LABEL 'A2_LOJA'
define Column A2_NOME 		TYPE CHARACTER SIZE 250 DECIMALS 0 LABEL 'A2_NOME'
define Column A2_CODZON 	TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'A2_CODZON'

define Column F37_VATCOD	TYPE CHARACTER SIZE 15 DECIMALS 0 LABEL 'F37_VATCOD'
define Column F37_VATCD2 	TYPE CHARACTER SIZE 15 DECIMALS 0 LABEL 'F37_VATCD2'
define Column F37_VALGR 	TYPE CHARACTER SIZE 50 DECIMALS 0 LABEL 'F37_VALGR'

define Column F38_VATC1		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F38_VATC1'
define Column F38_VATC2		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F38_VATC2'
define Column F38_VATC3		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F38_VATC3'
define Column F38_VATC4		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F38_VATC4'
define Column F38_VATC5		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F38_VATC5'
define Column F38_VATC6		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F38_VATC6'

define Column F37_INVCUR	TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'F37_INVCUR'

define Column F37_CNEE_C	TYPE CHARACTER SIZE 7 DECIMALS 0 LABEL 'F37_CNEE_C'
define Column F37_CNEE_B	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'F37_CNEE_B'
define Column F37_CNOR_C	TYPE CHARACTER SIZE 7 DECIMALS 0 LABEL 'F37_CNOR_C'
define Column F37_CNOR_B	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'F37_CNOR_B'

define Column TOTAL_T1		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T1'
define Column TOTAL_T2		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T2'
define Column TOTAL_T3		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T3'
define Column TOTAL_T4		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T4'
define Column TOTAL_T5		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T5'
define Column TOTAL_T6		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'TOTAL_T6'

define Column NLINE			TYPE CHARACTER SIZE 8 DECIMALS 0 LABEL 'NLINE'

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

chkFile("F3C")

Processa({|_lEnd| lRet := X60NOT(cWTabAlias, aSelFil)}, ::title())

Return .T.



Static Function X60NOT(cWTabAlias, aSelFil)
Local aArea, aRet as array
Local nBase18Total, nBase10Total, nBase00Total, nBase__Total, nValue18Total, nValue10Total, nNLine as Numeric
Local cAliasTMP, cQuery, cStatus, cFils as Char
Local nF as Numeric
Local nF2 as Numeric
Local nF3 as Numeric
Local nCode as Numeric
Local aVATCode as Array


cStatus := ''
nNLine := 0
nF2 := 1
nF3 := 1
If !Empty(MV_PAR03)
	If (Alltrim(str(MV_PAR03)))="4"
	nF3 := 3
	nF2 := 1
	else
	nF3 := MV_PAR03
	nF2 := MV_PAR03
	endif
Endif
nBase18Total := nBase10Total := nBase00Total := nBase__Total := nValue18Total := nValue10Total := 0
cFils := ''
For nF:=1 to Len(aSelFil)
	if !empty(cFils)
		cFils:= cFils + ", " + alltrim(aSelFil[nF])
	else
		cFils:= alltrim(aSelFil[nF])
	endif
next
cFils := cFils + "."
For nF2:=nF2 to nF3
	For nF:=1 to Len(aSelFil)
		//aRet := {}
		//aRet := FwComAltInf({'CO_FULLNAM'}) 
		
		// Reading from the database according to the chosen parameters.
		aArea := getArea()
		cAliasTMP := GetNextAlias()
		cQuery := " SELECT F37_DOC, F37_RDATE, F37_PDATE, F37_ADJNR, F37_INVDT, F37_PAYM, F37_FORNEC, F37_BRANCH, F37_KPP_SP, F37_VALGR, sum(f3c_recbas) as SUMRECBASE, sum(f3c_value) as SUMRECVALUE,"
		cQuery += " F32_VATCOD, F32_VATCD2, F32_VATRT, A2_LOJA, A2_NOME, A2_KPP, A2_CODZON, CTO_DESCUN"

		cQuery += " FROM " + RetSqlName("F3C") + " F3C" 
	
	
		cQuery += " JOIN " + RetSqlName("F32") + " F32" 
		cQuery += " ON ( F32.D_E_L_E_T_ = ' '" 
		cQuery += " AND F32_KEY = F3C_KEY" 
		cQuery += " AND F32_VATCOD = F3C_VATCOD"
		cQuery += " AND F32_FILIAL = '"+xfilial('F32',aSelFil[nF])+"' )" 
	
	
		cQuery += " JOIN " + RetSqlName("F37") + " F37" 
		cQuery += " ON ( F37.D_E_L_E_T_ = ' '" 
		cQuery += " AND F37_KEY = F3C_KEY" 
		cQuery += " AND F37_FILIAL = '"+xfilial('F37',aSelFil[nF])+"' )"
		If !Empty(MV_PAR07)
			cQuery += " AND F37_DOC >= '" + (MV_PAR07) + "'" 	// From a VAT Purchase Invoice number //need check
		Endif
		If !Empty(MV_PAR08)
			cQuery += " AND F37_DOC <= '" + (MV_PAR08) + "'" 	// To a VAT Purchase Invoice number
		Endif
		If !Empty(MV_PAR09)
			cQuery += " AND F37_FORNEC >= '" + (MV_PAR09) + "'" 	// "From Supplier ?               "
		Endif
		If !Empty(MV_PAR10)
			cQuery += " AND F37_BRANCH >= '" + (MV_PAR10) + "'" 	// "From Branch ?                 "
		EndIf
		If !Empty(MV_PAR11)
			cQuery += " AND F37_FORNEC <= '" + (MV_PAR11) + "'" 	// "To Supplier ?                 "
		Endif
		If !Empty(MV_PAR12)
			cQuery += " AND F37_BRANCH <= '" + (MV_PAR12) + "'" 	// "To Branch ?                   "
		EndIf


		cQuery += " JOIN " + RetSqlName("SA2") + " SA2" 
		cQuery += " ON ( SA2.D_E_L_E_T_ = ' '" 
		cQuery += " AND A2_COD = F37_FORNEC" 
		cQuery += " AND A2_LOJA = F37_BRANCH" 
		cQuery += " AND A2_filial = '" +xfilial('SA2',aSelFil[nF])+ "' )" 
	
		cQuery += " JOIN " + RetSqlName("F3B") + " F3B" 
		cQuery += " ON ( F3B_FILIAL = '" +xfilial('F3B',aSelFil[nF]) + "'" 
		cQuery += " AND F3B_BOOKEY = F3C_BOOKEY"
		cQuery += " AND F3B.D_E_L_E_T_ = ' '"
		If !Empty(MV_PAR01)
			cQuery += " AND F3B_INIT >= '" + DtoS(MV_PAR01) + "'" 	// From period of a Purchase Book
		Endif

		If !Empty(MV_PAR02)
			cQuery += " AND F3B_FINAL <= '" + DtoS(MV_PAR02) + "'" 	// To period of a Purchase Book
		Endif
		If !Empty(MV_PAR05)
			cQuery += " AND F3B_CODE >= '" + (MV_PAR05) + "'" 	// From a Purchase Book Code
		Endif
		If !Empty(MV_PAR06)
			cQuery += " AND F3B_CODE <= '" + (MV_PAR06) + "'" 	// To a Purchase Book Code
		Endif
		cQuery += " AND F3B_STATUS = '" + alltrim(str(nF2)) + "' )" 	//need check Status of a Purchase Book


		cQuery += " JOIN " + RetSqlName("CTO") + " CTO" 
		cQuery += " ON ( CTO.D_E_L_E_T_ = ' '" 
		cQuery += " AND CTO_FILIAL = '" +xfilial('CTO',aSelFil[nF])+ "'" 
		cQuery += " AND TRIM(REPLACE (CTO.CTO_MOEDA, '0',''))  = TRIM(REPLACE (F37.F37_INVCUR, '0',''))) " 
	
		cQuery += " WHERE F3C.D_E_L_E_T_ = ' '"
		cQuery += " AND F3C_FILIAL = '" +xfilial('F3C',aSelFil[nF])+ "'" 


		If !Empty(MV_PAR04)
			// Parse stings of Internal VAT Codes by delimiter ";"
			aVATCode = Str2Arr( MV_PAR04, ";" )
			cQuery += " AND F3C_VATCOD IN ( "
			// Go though the set of Internal VAT Codes, except last one. //need check
			For nCode := 1 to (Len(aVATCode)-1)
				cQuery += "'" + AllTrim(aVATCode[nCode]) + "',"	// Filter by Internal VAT codes
			End

			// After the loop iterator equals number of the last element of the array.
			// We add this last element AND close condition with single quote AND right parenthesis.
			cQuery += "'" + AllTrim(aVATCode[nCode]) + "' )" 
		Endif

		cQuery += " GROUP BY F37_KEY, F32_VATCOD, F32_VATCD2, F32_VATRT, F37_FORNEC, F37_BRANCH,"
		cQuery += " F37_RDATE, F37_PDATE, F37_PAYM, F37_KPP_SP, F37_VALGR, F37_DOC,"
		cQuery += " F37_ADJNR, F37_INVDT, A2_LOJA, A2_NOME, A2_KPP, A2_CODZON, CTO_DESCUN"
	
		cQuery += " ORDER BY F37_DOC, F37_ADJNR, F37_PDATE "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTMP, .T., .T.)
		DbSelectArea(cAliasTMP) 
		(cAliasTMP)->(dbGotop()) 


		// Writing into the report's variables
		While (cAliasTMP)->(!EOF()) 
			RecLock(cWTabAlias, .T.) 

			nNLine := nNLine + 1 
			NLINE 			:= alltrim(str(nNLine)) 
			//header
			H_BRANCH		:= cFils //aRet[1][2]

			H_PURCODF		:= (MV_PAR05) 
			H_PURCODT		:= (MV_PAR06) 

			H_DATEF			:= StrTran(DtoC(MV_PAR01), "/", ".") //date from
			H_DATET			:= StrTran(DtoC(MV_PAR02), "/", ".") //date to

			if alltrim(str(MV_PAR03)) = '1'
				H_STATUS		:= alltrim(STR0003)
			else
				if alltrim(str(MV_PAR03))='2'
					H_STATUS	:= alltrim(STR0004)
				else
					if alltrim(str(MV_PAR03))='3'
						H_STATUS := alltrim(STR0005)
					else
						H_STATUS := alltrim(STR0003) + ', ' + alltrim(STR0004) + ', ' + alltrim(STR0005) +'.'
					endif
				endif
			endif

			//items
			F37_DOC := (cAliasTMP)->F37_DOC 

			if !empty((cAliasTMP)->F37_PDATE)
				F37_PDATE := StrTran(DTOC(Stod((cAliasTMP)->F37_PDATE)), "/", ".") 
			endif

			F37_ADJNR := ''
			F37_RDATE := ''

			if !empty((cAliasTMP)->F37_PDATE)
				F37_INVDT := StrTran(DTOC(Stod((cAliasTMP)->F37_INVDT)), "/", ".")
			endif

			F37_PAYM := (cAliasTMP)->F37_PAYM
			F37_VATCOD := (cAliasTMP)->F32_VATCOD
			F37_VATCD2 := (cAliasTMP)->F32_VATCD2

			F37_FORNEC := (cAliasTMP)->F37_FORNEC
			F37_BRANCH := (cAliasTMP)->F37_BRANCH
			A2_NOME := (cAliasTMP)->A2_NOME
			A2_LOJA := (cAliasTMP)->A2_LOJA

			F37_VALGR := Alltrim(TRANSFORM((cAliasTMP)->F37_VALGR, "@E 999,999,999,999,999.99"))  

			If (cAliasTMP)->F32_VATRT = 18
				F38_VATC1 := Alltrim(TRANSFORM((cAliasTMP)->SUMRECBASE, "@E 999,999,999,999,999.99"))  
				nBase18Total +=  (cAliasTMP)->SUMRECBASE
			ElseIf (cAliasTMP)->F32_VATRT = 10
				F38_VATC2 := Alltrim(TRANSFORM((cAliasTMP)->SUMRECBASE, "@E 999,999,999,999,999.99")) 
				nBase10Total += (cAliasTMP)->SUMRECBASE
			ElseIf (cAliasTMP)->F32_VATRT = 0
				F38_VATC3 := Alltrim(TRANSFORM((cAliasTMP)->SUMRECBASE, "@E 999,999,999,999,999.99")) 
				nBase00Total += (cAliasTMP)->SUMRECBASE
			Else
				F38_VATC4 := Alltrim(TRANSFORM((cAliasTMP)->SUMRECBASE, "@E 999,999,999,999,999.99")) 
				nBase__Total += (cAliasTMP)->SUMRECBASE
			Endif
 
			If (cAliasTMP)->F32_VATRT = 18
				F38_VATC5 := Alltrim(TRANSFORM((cAliasTMP)->SUMRECVALUE, "@E 999,999,999,999,999.99")) 
				nValue18Total += (cAliasTMP)->SUMRECVALUE
			ElseiF (cAliasTMP)->F32_VATRT = 10
				F38_VATC6 := Alltrim(TRANSFORM((cAliasTMP)->SUMRECVALUE, "@E 999,999,999,999,999.99")) 
				nValue10Total += (cAliasTMP)->SUMRECVALUE
			Endif
			
			if empty((cAliasTMP)->A2_KPP)
				A2_CODZON := (cAliasTMP)->A2_CODZON
			else
				if !empty((cAliasTMP)->A2_CODZON)
					A2_CODZON := Alltrim((cAliasTMP)->A2_CODZON) + '/ ' + Alltrim((cAliasTMP)->A2_KPP)
				else
					A2_CODZON := Alltrim((cAliasTMP)->A2_KPP)
				endif
			endif
			
			F37_INVCUR := (cAliasTMP)->CTO_DESCUN

			F37_CNEE_C := ''
			F37_CNEE_B := ''
			F37_CNOR_C := ''
			F37_CNOR_B := ''

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
	Next
Next nF2

return .T.

// Russia_R5
