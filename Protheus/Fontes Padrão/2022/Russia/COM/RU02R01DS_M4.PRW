#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"

/*
Autor:			Artem Nikitenko.
Data:			11/10/17
Description: 	Data set in birt format
*/

dataset RU02R01DS
Title 'M-4'
Description "M-4"

PERGUNTE "RU02R01DS"

Columns
define Column CO_FULLNAM 	TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'CO_FULLNAM'//1H
define Column CO_ADDRESS	TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'CO_ADDRESS'//1H
define Column CO_KPP		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'CO_KPP'//1H
define Column CO_INN		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'CO_INN'//1H
define Column CO_PHONE		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'CO_PHONE'//1H
define Column CO_DATA		TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Company data'
define Column CO_OKPO		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKPO'//2H
define Column CL_NAME 		like A2_NOME //7H
define Column CL_ADDRESS	TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Client Address'
define Column CL_TIN		like A2_CGC
define Column CL_KPP		like A2_KPP
define Column H_DOC			TYPE CHARACTER SIZE 8 DECIMALS 0 LABEL 'test111' //10h // 5H
define Column H_SYSCOD		TYPE CHARACTER SIZE 12 DECIMALS 0 LABEL 'System code'
define Column H_IDATE 		TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL 'Posting Date' // 5H
define Column H_NAME 		LIKE D1_LOCAL //6H
define Column H_NAMWAREH 	LIKE NNR_DESCRI
define Column H_VENCOD 		LIKE F1_FORNECE //8H
define Column H_CONTA 		LIKE A2_CONTA //9H
define Column H_DDATE 		TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Isue date day'
define Column H_MDATE 		TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Isue date month'
define Column H_YDATE 		TYPE NUMERIC SIZE 4 DECIMALS 0 LABEL 'Isue date year'
define Column H_CURRENCY 	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'Currency Code'
define Column H_CURDESC		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'Currency Description'
define Column IT_DESC		like B1_DESC //1i
define Column IT_MATCOD		like D1_COD //2i
define Column IT_QUANT		like D1_QUANT //6I
define column IT_UM			like AH_UMRES
define column H_D1_CC		TYPE CHARACTER SIZE 250 DECIMALS 0 LABEL 'H_D1_CC'
define column IT_CODERP		LIKE AH_CODOKEI//3I
define column IT_CODESCR	LIKE AH_DESCPO
define column IT_UMDESC		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'UM DESCRIPTION'//4I
define Column IT_UNIT_PR	like D1_VUNIT//7I
define Column IT_VALUE 		TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Item value'
define Column IT_VAT_RAT	like D1_ALQIMP1
define Column IT_VAT		like D1_VALIMP1
define Column IT_VALTOT		TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Item total value'
define Column TOT_GOODS		TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Total goods value'
define Column TOT_VAT		like F1_VALIMP1
define Column TOT_SOGU		TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'TOT_SOGU'//61i
define Column TOT_VALUE 	TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Total value'
define Column Q3_DESCSU2 	TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'Q3_DESCSU2'
define Column RA_NOME2 		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'RA_NOME2'

define Column CRV	 		TYPE CHARACTER SIZE 60 DECIMALS 0 LABEL 'CRV'

define query 	"SELECT * FROM %WTable:1% "

process dataset

Local cWTabAlias,cMvpar02 as char
Local lRet as logical
Local self as object

lRet 	:= .f.
cWTabAlias := ::createWorkTable()

chkFile("SA2")
cMvpar02 := alltrim(self:execParamValue( "MV_PAR01" ))

Processa({|_lEnd| lRet := X60NOT(cWTabAlias,cMvpar02)}, ::title())

return .T.


static function X60NOT(cAliasMov,cMvpar02)
Local aArea,aRet	as array
Local nSumT,nGetSxe	as Numeric
Local cQ3descsu,cRanome,cR2nome2,cQuery,cAliasTM2,cAliasTM3,cAliasTM4,cNotIni,cAliasTMP,cAdr,cAdr2 as Char
local iAdrExi := .T.

/* //Can be use after fix bug in ATUSX (Message abut not chosen signers)
if Empty(cMvpar02) .and. cPaisLoc == "RUS"
	HELP(" ",1,"RU02R01_M4")
endif
*/
cQuery := "SELECT CO_SHORTNM "
cQuery += "FROM SYS_COMPANY_L_RUS SYS "
cQuery += "WHERE CO_COMPGRP ='" + cEmpAnt + "'"
cQuery += "AND CO_TIPO = '1'"

cAliasTM4	:= GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTM4,.T.,.T.)
DbSelectArea(cAliasTM4)
(cAliasTM4)->(DbGoTop())

cQuery := "SELECT CO_COMPGRP,CO_TIPO,CO_SHORTNM,AGA_CEP,AGA_BAIRRO,AGA_MUNDES,AGA_END,AGA_HOUSE,AGA_BLDNG,AGA_APARTM "
cQuery += "FROM SYS_COMPANY_L_RUS SYS "
cQuery += "INNER JOIN " + RetSqlName("AGA") + " AS AGA "
cQuery += "ON AGA.AGA_NAMENT	=	SYS.CO_SHORTNM "
cQuery += "AND AGA.AGA_NAMENT = '" + alltrim((cAliasTM4)->CO_SHORTNM) + "'"
(cAliasTM4)->(dbCloseArea())

cAliasTM3	:= GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTM3,.T.,.T.)
DbSelectArea(cAliasTM3)
(cAliasTM3)->(DbGoTop())

cAdr2 := ''
if !empty(alltrim((cAliasTM3)->AGA_CEP))
	cAdr2 += ", " +  alltrim((cAliasTM3)->AGA_CEP)
endif

if !empty(alltrim((cAliasTM3)->AGA_BAIRRO))
	cAdr2 += ", " +  alltrim((cAliasTM3)->AGA_BAIRRO)
endif

if !empty(alltrim((cAliasTM3)->AGA_MUNDES))
	cAdr2 += ", " +  alltrim((cAliasTM3)->AGA_MUNDES)
endif

if !empty(alltrim((cAliasTM3)->AGA_END))
	cAdr2 += ", " + alltrim((cAliasTM3)->AGA_END)
endif

if !empty(alltrim((cAliasTM3)->AGA_HOUSE))
	cAdr2 += ", " + alltrim((cAliasTM3)->AGA_HOUSE)
endif

if !empty(alltrim((cAliasTM3)->AGA_BLDNG))
	cAdr2 += ", " + alltrim((cAliasTM3)->AGA_BLDNG)
endif

if !empty(alltrim((cAliasTM3)->AGA_APARTM))
	cAdr2 += ", " + alltrim((cAliasTM3)->AGA_APARTM)
endif

(cAliasTM3)->(dbCloseArea())

cQuery := "SELECT F42_NAME,Q3_DESCSUM "
cQuery += "FROM " + RetSqlName("F42") + " F42"
cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA"
cQuery += " ON F42.F42_EMPL = SRA.RA_MAT "
cQuery += " INNER JOIN " + RetSqlName("SQ3") + " SQ3"
cQuery += " ON F42.F42_CARGO =		SQ3.Q3_CARGO"
cQuery += " WHERE SRA.RA_MAT = '" + cMvpar02 + "'"
cQuery += " AND F42.F42_EMPL = '" + cMvpar02 + "'"
cQuery += " AND (F42.F42_REPORT='M4' OR F42.F42_REPORT='ALL')"
cQuery += " AND F42.D_E_L_E_T_=' '"

cAliasTM2	:= GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTM2,.T.,.T.)
DbSelectArea(cAliasTM2)
(cAliasTM2)->(DbGoTop())
if alltrim((cAliasTM2)->F42_NAME)=''
	cR2nome2    := ''
else
	cQ3descsu	:= alltrim((cAliasTM2)->Q3_DESCSUM)
	cRanome		:= alltrim((cAliasTM2)->F42_NAME)
	cR2nome2	:= alltrim(substr(alltrim(cRanome),1,(at(' ',alltrim(cRanome),1))))
	cR2nome2	:= alltrim(cR2nome2) + (' ') + alltrim(substr(alltrim(cRanome),(at(' ',alltrim(cRanome),1)),2))
	cR2nome2	:= alltrim(cR2nome2) + alltrim('.') + alltrim(substr(alltrim(cRanome),(at(' ',alltrim(cRanome),len(cR2nome2))),2)) +'.'
endif
(cAliasTM2)->(dbCloseArea())

cNotIni:= SF1->F1_DOC

aArea := getArea()
nSumT := 0
nGetSxe:= GetSxeNum("SF1","F1_MSIDENT")

cAliasTMP	:= GetNextAlias()

cNotIni :=strtran(cNotIni,'"',"")

cQuery := "SELECT A2_NOME,A2_END,A2_BAIRRO,A2_MUN,A2_PAIS,A2_EST,A2_CEP,A2_CGC,A2_KPP,A2_CONTA,"
cQuery += "F1_DOC,F1_FORNECE,F1_LOJA,F1_DTDIGIT,F1_VALIMP1,F1_VALBRUT,F1_VALMERC,F1_MOEDA,"
cQuery += "D1_COD, D1_QUANT,D1_UM,D1_VUNIT,D1_LOCAL,B1_DESC,D1_CC,F1_MSIDENT,"
cQuery += "D1_VALIMP1,D1_ALQIMP1,D1_TOTAL,AH_UNIMED,D1_TIPODOC,AH_CODOKEI,AH_DESCPO,"
cQuery += "D1_CC,NNR_DESCRI,AH_UMRES,D1_ITEM "
cQuery += "FROM "+RetSqlName("SF1") + " SF1"
cQuery += " INNER JOIN "+RetSqlName("SA2") + " SA2"
cQuery += " ON SA2.A2_COD = 		SF1.F1_FORNECE"
cQuery += " AND SA2.A2_LOJA = 		SF1.F1_LOJA "
cQuery += " AND SA2.D_E_L_E_T_=' '"
cQuery += " AND SA2.A2_FILIAL = 	'" + xFilial("SA2") + "'"
cQuery += " INNER JOIN "+RetSqlName("SD1") + " SD1"
cQuery += " ON SD1.D1_FILIAL =		SF1.F1_FILIAL"
cQuery += " AND SD1.D1_DOC = 		SF1.F1_DOC"
cQuery += " AND SD1.D1_SERIE = 		SF1.F1_SERIE"
cQuery += " AND SD1.D1_FORNECE = 	SF1.F1_FORNECE"
cQuery += " AND SD1.D1_LOJA = 		SF1.F1_LOJA"
cQuery += " AND SD1.D1_TIPODOC = 	SF1.F1_TIPODOC"
cQuery += " AND SD1.D1_ESPECIE = 	SF1.F1_ESPECIE"
cQuery += " AND SD1.D_E_L_E_T_=' '"
cQuery += " AND SD1.D1_FILIAL =		'" + xFilial("SD1") + "'"
cQuery += " AND SD1.D1_TIPODOC='10'"
cQuery += " INNER JOIN "+RetSqlName("SAH") + " SAH"
cQuery += " ON SAH.AH_UNIMED=		SD1.D1_UM"
cQuery += " AND SAH.D_E_L_E_T_=' '"
cQuery += " INNER JOIN "+RetSqlName("SB1") + " SB1"
cQuery += " ON SB1.B1_COD=			SD1.D1_COD"
cQuery += " AND SB1.D_E_L_E_T_=' '"
cQuery += " INNER JOIN "+RetSqlName("NNR") + " NNR"
cQuery += " ON NNR.NNR_FILIAL=		SD1.D1_FILIAL"
cQuery += " AND NNR.NNR_CODIGO=		SD1.D1_LOCAL"
cQuery += " AND NNR.D_E_L_E_T_=' '"
cQuery += " WHERE SF1.F1_FILIAL = 	'" + xFilial("SF1") + "'"
cQuery += " AND SF1.D_E_L_E_T_=' '"
cQuery += " AND SF1.F1_DOC = '" + cNotIni + "'"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
DbSelectArea(cAliasTMP)
(cAliasTMP)->(dbGotop())

aRet := GetCoBrRUS()
cAdr := ''

if !empty(aRet) .and. len(aRet)>=3
	if !empty(aRet[3]) .and. len(aRet[3])>=2
		if !empty(aRet[3][2]) .and. len(aRet[3][2])>=18
			if !empty(Alltrim(aRet[3][2][6]))
				cAdr += alltrim(aRet[3][2][6])
			endif
			if !empty(alltrim(aRet[3][2][10]))
				cAdr += ", " + alltrim(aRet[3][2][10])
			endif
			if !empty(alltrim(aRet[3][2][12]))
				cAdr += ", " + alltrim(aRet[3][2][12])
			endif
			if !empty(alltrim(aRet[3][2][13]))
				cAdr += ", " + alltrim(aRet[3][2][13])
			endif
			if !empty(alltrim(aRet[3][2][15]))
				cAdr += ", " + alltrim(aRet[3][2][15])
			endif
			if !empty(alltrim(aRet[3][2][16]))
				cAdr += ", " + alltrim(aRet[3][2][16])
			endif
			if !empty(alltrim(aRet[3][2][17]))
				cAdr += ", " + alltrim(aRet[3][2][17])
			endif
			if !empty(alltrim(aRet[3][2][18]))
				cAdr += ", " + alltrim(aRet[3][2][18])
			endif
			if !empty(cAdr)
				cAdr +="."
			endif
		else
			Help(" ",1,"ADDRNOTEX2")
			iAdrExi := .F.
		endif
	else
		Help(" ",1,"ADDRNOTEX2")
		iAdrExi := .F.
	endif	
else
	Help(" ",1,"ADDRNOTEX2")
	iAdrExi := .F.
Endif

While (cAliasTMP)->(!EOF())

	RecLock(cAliasMov,.T.)
	
	if iAdrExi
		if !empty(aRet[3][1]) .and. !empty(aRet[3][1][7]) .and. !empty(aRet[3][1][5])
			if alltrim(aRet[3][1][7])='1' .and. alltrim(aRet[3][1][5])='0'
				CO_DATA		:= ALLTRIM(aRet[1][5][2])+", " + ALLTRIM(aRet[1][13][2]) + "/" + ALLTRIM(aRet[1][14][2]) + cAdr2 + "." /* + ALLTRIM(CO_ADDRESS) + ", " + alltrim(aRet[1][7][2]) + "."*/
			else
				CO_DATA		:= ALLTRIM(aRet[1][5][2])+", " + ALLTRIM(aRet[1][13][2]) + "/" + ALLTRIM(aRet[1][14][2]) + "."
			endif
		else
			Help(" ",1,"ADDRNOTEX2")
			iAdrExi := .f.
		endif
	else
		CO_DATA := ''
	endif

	CO_OKPO			:= aRet[1][12][2]
	CL_NAME			:= (cAliasTMP)->A2_NOME
	CL_ADDRESS		:= ALLTRIM((cAliasTMP)->A2_END)+", "+ALLTRIM((cAliasTMP)->A2_BAIRRO)
	CL_TIN			:= (cAliasTMP)->A2_CGC
	CL_KPP			:= (cAliasTMP)->A2_KPP
	H_NAME 			:= (cAliasTMP)->D1_LOCAL
	H_CONTA 		:= (cAliasTMP)->A2_CONTA
	H_SYSCOD		:= cValToChar(Val((nGetSxe))) //VAL((cAliasTMP)->F1_MSIDENT)//3h
	H_DOC			:= (cAliasTMP)->F1_DOC //10h
	H_NAMWAREH 		:= (cAliasTMP)->NNR_DESCRI	//6h 
	H_D1_CC			:= cAdr
	H_VENCOD 		:= (cAliasTMP)->F1_FORNECE
	H_IDATE 		:= StrTran(DTOC(Stod((cAliasTMP)->F1_DTDIGIT)),"/",".")//h5
	H_DDATE 		:= Val(SUBSTR((cAliasTMP)->F1_DTDIGIT,7,2))
	H_MDATE 		:= Val(SUBSTR((cAliasTMP)->F1_DTDIGIT,5,2))
	H_YDATE 		:= Val(SUBSTR((cAliasTMP)->F1_DTDIGIT,1,4))		
	H_CURRENCY		:= "643"
	H_CURDESC		:= ''
	IT_CODERP		:= (cAliasTMP)->AH_CODOKEI //3i
	IT_DESC			:= (cAliasTMP)->B1_DESC //1i
	IT_MATCOD		:= (cAliasTMP)->D1_COD //2i
	IT_UM			:= (cAliasTMP)->AH_UMRES
	IT_UMDESC	 	:= Posicione("SAH",1,xfilial("SAH")+(cAliasTMP)->D1_UM,"SAH->AH_UMRES")
	IT_UNIT_PR		:= (cAliasTMP)->D1_VUNIT
	IT_QUANT		:= (cAliasTMP)->D1_QUANT
	nSumT 			:= nSumT + IT_QUANT
	TOT_SOGU		:= nSumT
	IT_VALUE		:= (cAliasTMP)->D1_TOTAL
	IT_VAT			:= (cAliasTMP)->D1_VALIMP1
	IT_VAT_RAT		:= (cAliasTMP)->D1_ALQIMP1/100
	IT_VALTOT		:= (((cAliasTMP)->D1_TOTAL) + ((cAliasTMP)->D1_VALIMP1))
	TOT_VAT			:= (cAliasTMP)->F1_VALIMP1 //91i
	TOT_GOODS	 	:= (cAliasTMP)->F1_VALMERC //81i
	TOT_VALUE	 	:= (cAliasTMP)->F1_VALBRUT //101i
	
	RA_NOME2 := alltrim(cR2nome2)
	Q3_DESCSU2 := alltrim(cQ3descsu)

	MsUnlock()
	(cAliasTMP)->(dbSkip())

EndDo

(cAliasTMP)->(dbCloseArea())
RestArea(aArea)
ConfirmSx8()

return .T.
// Russia_R5
