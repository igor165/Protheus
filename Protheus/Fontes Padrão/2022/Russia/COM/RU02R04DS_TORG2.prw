#include "protheus.ch"
#Include 'birtdataset.ch'
#include "TOPCONN.CH"
#include "RU02R02.CH"

/*
Autors:			Artem Nikitenko.
Data:			20/03/18
Description: 	Data set in birt format
*/

dataset RU02R04DS
Title 'TORG-2'
Description "TORG-2"

PERGUNTE "RU02R04DS"

Columns

define Column A1_DATA		TYPE CHARACTER SIZE 200 LABEL 'A1_DATA'		//A1 Company data
define Column A2_STRUCT		TYPE CHARACTER SIZE 200 LABEL 'A2_STRUCT'	//A2 Structural subdivision
define Column A3_OKPO		TYPE CHARACTER SIZE 9 LABEL 'A3_OKPO'		//A3 Company OKPO code
define Column A4_DOC		TYPE CHARACTER SIZE 12 LABEL 'A4_DOC'		//A4 System Document number
define Column A5_POS		TYPE CHARACTER SIZE 60 LABEL 'A5_POS'		//A5 Established position (Lider)
define Column A6_NAME		TYPE CHARACTER SIZE 60 LABEL 'A6_NAME'		//A6 Employees name (Lider)
define Column A7_WHOUSE		TYPE CHARACTER SIZE 20 LABEL 'A7_WHOUSE'	//A7 Warehouse name
define Column A8_SENDER		TYPE CHARACTER SIZE 200 LABEL 'A8_SENDER'	//A8 Sender
define Column A9_SUPPL		TYPE CHARACTER SIZE 200 LABEL 'A9_SUPPL'	//A9 Supplier
define Column A10_CONT		TYPE CHARACTER SIZE 12 LABEL 'A10_CONT'		//A10 Contract number
define Column A11_CDATE		TYPE CHARACTER SIZE 20 LABEL 'A11_CDATE'	//A11 Contract date
define Column A12_DDATE		TYPE CHARACTER SIZE 20 LABEL 'A12_DDATE'	//A12 Document date (Date format: dd.mm.yyyy)
define Column A13_SDATE		TYPE CHARACTER SIZE 20 LABEL 'A13_SDATE' 	//A13 Sign date (Date format:dd/month/yyyy)

define Column B1_DESC		TYPE CHARACTER SIZE 30 LABEL 'B1_DESC'				//B1 B1_DESC
define Column B2_UMRES		TYPE CHARACTER SIZE 25 LABEL 'B2_UMRES'				//B2 AH_UMRES
define Column B3_OKEI		TYPE CHARACTER SIZE 4 LABEL 'B3_OKEI'				//B3 AH_CODOKEI
define Column B4_QUANT		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'B4_QUANT'	//B4 D1_QUANT
define Column B5_PRICE 		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'B5_PRICE'	//B5 D1_VUNIT
define Column B6_TOTAL 		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'B6_TOTAL'	//B6 D1_TOTAL

define Column C1_POS		TYPE CHARACTER SIZE 60 LABEL 'C1_POS'	//C1 Established position of the head of committee
define Column C2_NAME		TYPE CHARACTER SIZE 60 LABEL 'C2_NAME'	//C2 Employees name of the head of committee
define Column C3_POS		TYPE CHARACTER SIZE 60 LABEL 'C3_POS'	//C3 Established position of the member of the committee
define Column C4_NAME		TYPE CHARACTER SIZE 60 LABEL 'C4_NAME'	//C4 Employees name of the member of the committee
define Column C5_POS		TYPE CHARACTER SIZE 60 LABEL 'C5_POS'	//C5 Established position of the member of the committee
define Column C6_NAME		TYPE CHARACTER SIZE 60 LABEL 'C6_NAME'	//C6 Employees name of the member of the committee
define Column C7_POS		TYPE CHARACTER SIZE 60 LABEL 'C7_POS'	//C7 Established position of the member of the committee
define Column C8_NAME		TYPE CHARACTER SIZE 60 LABEL 'C8_NAME'	//C8 Employees name of the member of the committee
define Column C9_NAME		TYPE CHARACTER SIZE 60 LABEL 'C9_NAME'	//C9 Employees name (Chief accountant)

define query 	"SELECT * FROM %WTable:1% "

process dataset

Local cWTabAlias as char
Local cMvpar01 as char 		//Lider A5-A6
Local cMvpar02 as char 		//h. Accountant C9
Local cMvpar03 as char 		//Head of committee C1-C2
Local cMvpar04 as char 		// member of the committee C3-C4
Local cMvpar05 as char 		// member of the committee C5-C6
Local cMvpar06 as char 		// member of the committee C7-C8

Local cSelFil as char 
Local cEmissao as char
Local cSelDoc  as char
Local lRet as logical

lRet 	:= .F.
cWTabAlias := self:createWorkTable()

chkFile("SF1")
cSelDoc:= SF1->F1_DOC
cSelFil := SF1->F1_FILIAL
cEmissao := DTOS (SF1->F1_EMISSAO)
cSelFil :=strtran(cSelFil,'"',"")
cSelDoc :=strtran(cSelDoc,'"',"")
cEmissao :=strtran(cEmissao,'"',"")

cMvpar01 := alltrim(self:execParamValue( "MV_PAR01" ))  //Lider A5-A6
cMvpar02 := alltrim(self:execParamValue( "MV_PAR02" ))	//h. Accountant C9
cMvpar03 := alltrim(self:execParamValue( "MV_PAR03" )) 	//Head of committee C1-C2
cMvpar04 := alltrim(self:execParamValue( "MV_PAR04" ))  // member of the committee C3-C4
cMvpar05 := alltrim(self:execParamValue( "MV_PAR05" ))  // member of the committee C5-C6
cMvpar06 := alltrim(self:execParamValue( "MV_PAR06" ))  // member of the committee C7-C8

if empty(cMvpar01)
	cMvpar01 := ''
endif
if empty(cMvpar02)
	cMvpar02 := ''
endif
if empty(cMvpar03)
	cMvpar03 := ''
endif
if empty(cMvpar04)
	cMvpar04 := ''
endif
if empty(cMvpar05)
	cMvpar05 := ''
endif
if empty(cMvpar06)
	cMvpar06 := ''
endif

Processa({|_lEnd| lRet := X60NOT(cWTabAlias,cSelDoc,cSelFil,cEmissao,cMvpar01,cMvpar02,cMvpar03,cMvpar04,cMvpar05,cMvpar06)}, ::title())

return .T.


/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =*/
static function X60NOT(cAliasMov, cSelDoc, cSelFil, cEmissao, cMvpar01,cMvpar02,cMvpar03,cMvpar04,cMvpar05,cMvpar06)
	Local aArea as array
	Local aCData as array
	Local aCData1 as array
	Local aSingers as array
	local aRet as array
	Local cDate as Char
	Local cAliasTMP as Char
	Local cQuery as Char
	Local cAddrKey as Char
	Local cSend as Char
	Local CFdata as Char
	local cAdr as Char
	Local cMonths as Char
	local cClAdrDate as Char
	local iAdrExi := .T.
	
	cClAdrDate := DtoS(dDatabase)

	aSingers := {}
	aadd (aSingers, GetSigners(cMvpar01)) 	//Lider A5-A6
	aadd (aSingers, GetSigners(cMvpar02)) 	//h. Accountant C9
	aadd (aSingers, GetSigners(cMvpar03)) 	//Head of committee C1-C2
	aadd (aSingers, GetSigners(cMvpar04)) 	// member of the committee C3-C4
	aadd (aSingers, GetSigners(cMvpar05)) 	// member of the committee C5-C6
	aadd (aSingers, GetSigners(cMvpar06)) 	// member of the committee C7-C8

	aArea := getArea()

	aCData := FwComAltInf({'CO_OKPO','CO_FULLNAM','CO_COMPGRP','CO_COMPEMP','CO_TIPO','CO_PHONENU','CO_COMPUNI'})

	cAddrKey := xFilial("SM0") + padr(aCData[3][2],Len(FwComAltInf({"XX8_GRPEMP"})[1][2]));
	+ padr(aCData[4][2],Len(FwComAltInf({"XX8_EMPR"})[1][2]));
	//+ padr(aCData[7][2],Len(FwComAltInf({"XX8_UNID"})[1][2]));
	+ padr(aCData[5][2],Len(FwComAltInf({"XX8_CODIGO"})[1][2]))

	aCData1 := GetCoBrRUS(SM0->M0_CODFIL)

	aadd(aCData,GetAdress(cAddrKey,'0'))

	If !empty(aCData1) .and. len(aCData1)>=3 .and. !empty(aCData1[3]) .and. !empty(aCData1[3][2]) .and. !empty(aCData1[3][2][22])
		aadd(aCData,aCData1[3][2][22])	
		WHILE AT(', ,', aCData[9])!=0
			aCData[9] := StrTran(aCData[9],', ,',',')
		ENDDO
		aCData[9] := StrTran(aCData[9],', .','.')
		WHILE AT(',,', aCData[9])!=0
			aCData[9] := StrTran(aCData[9],',,',',')
		ENDDO
		aCData[9] := StrTran(aCData[9],',.','.')
	else
		Help(" ",1,"ADDRNOTEX2")
		iAdrExi:=.f.
	Endif	

	cQuery := "SELECT D1_CC, D1_COD, D1_VUNIT, D1_QUANT, D1_TOTAL, F1_FORNECE, "
	cQuery += "NNR_DESCRI, AH_UMRES, AH_CODOKEI, A2_NOME, A2_MUN, A2_END, A2_TEL, B1_DESC, F1_EMISSAO, "
	cQuery += "AGA_MUNDES, AGA_END, AGA_HOUSE, AGA_NAMENT, AGA_COMP "
	
	cQuery += "FROM " + RetSqlName("SD1") + " SD1 "

	cQuery += "INNER JOIN " + RetSqlName("SF1") + " SF1 "
	cQuery += "ON SF1.F1_DOC = SD1.D1_DOC "
	cQuery += "AND SF1.F1_SERIE = SD1.D1_SERIE "
	cQuery += "AND SF1.F1_FORNECE = SD1.D1_FORNECE "
	cQuery += "AND SF1.F1_LOJA = SD1.D1_LOJA "
	cQuery += "AND SF1.F1_ESPECIE = SD1.D1_ESPECIE "
	cQuery += "AND SF1.F1_TIPODOC = SD1.D1_TIPODOC "
	cQuery += "AND SF1.F1_Filial = '" + xfilial('SF1') + "' "
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSqlName("NNR") + " NNR "
	cQuery += "ON NNR.NNR_CODIGO = SD1.D1_LOCAL "
	cQuery += "AND NNR.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSqlName("SAH") + " SAH "
	cQuery += "ON SAH.AH_UNIMED = SD1.D1_UM "
	cQuery += "AND SAH.AH_FILIAL = '" + xfilial('SAH') + "' "
	cQuery += "AND SAH.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery += "ON SA2.A2_COD = SF1.F1_FORNECE "
	cQuery += "AND SA2.A2_LOJA = SF1.F1_LOJA "	
	cQuery += "AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
	cQuery += "AND SA2.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "ON SB1.B1_COD = SD1.D1_COD "
	cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
	
	cQuery += "LEFT JOIN "+RetSqlName("AGA") + " AGA "
	cQuery += "ON AGA.AGA_ENTIDA = 'SA2' "	
	cQuery += "AND AGA.AGA_CODENT like '%'||A2_FILIAL||A2_COD||A2_LOJA||'%' "
	cQuery += "AND '" + cClAdrDate + "' BETWEEN '''AGA_FROM''' AND AGA_TO "
	cQuery += "AND AGA.AGA_FILIAL = '" + xFilial("AGA") + "' "
	cQuery += "AND AGA.D_E_L_E_T_ = ' ' "

	cQuery += "WHERE SD1.D1_DOC ='" + cSelDoc + "' "
	cQuery += "AND NNR.NNR_FILIAL = '" + cSelFil + "' "
	cQuery += "AND SF1.F1_DTDIGIT = '" + cEmissao + "' "
	cQuery += "AND SD1.D1_Filial = '" + xfilial('SD1') + "' "
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' "	

	cQuery := Changequery(cQuery)

	cAliasTMP := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)

	/*--------------FULLNAM-------------------ADDRESS------------*/
	CFdata := AllTrim(aCData[2][2]) + ', ' + AllTrim(aCData[8]) + ', ' + AllTrim(aCData[6][2]) + "."
	WHILE AT(', ,', CFdata)!=0
		CFdata := StrTran(CFdata,', ,',',')
	ENDDO
	CFdata := StrTran(CFdata,', .','.')
	WHILE AT(',,', CFdata)!=0
		CFdata := StrTran(CFdata,',,',',')
	ENDDO
	CFdata := StrTran(CFdata,',.','.')

	aRet := GetCoBrRUS()
	cAdr := ''

	if !empty(aRet) .and. len(aRet)>=3 .and. !empty(aRet[3]) .and. len(aRet[3])>=2 .and. !empty(aRet[3][2]) .and. len(aRet[3][2])>=18
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
		if iAdrExi
			Help(" ",1,"ADDRNOTEX2")
		endif
	endif

	cMonths:= CMonthRUS (SUBSTR(cEmissao, 5, 2))
	cDate := '"' + SUBSTR(cEmissao, 7, 2) + '"  ' +  cMonths + '  ' + SUBSTR(cEmissao, 1, 4) + ' ' + STR0013 + '.'

	(cAliasTMP)->(dbGotop())
	While (cAliasTMP)->(!EOF())
		RecLock(cAliasMov,.T.)

		A1_DATA		:= CFdata
		A2_STRUCT	:= cAdr
		A3_OKPO		:= aCData[1][2]
		A4_DOC		:= cSelDoc
		A5_POS		:= AllTrim(aSingers[1][1]) //cMvpar01 Lider A5-A6
		A6_NAME		:= AllTrim(aSingers[1][2]) //cMvpar01 Lider A5-A6
		A7_WHOUSE	:= (cAliasTMP)->NNR_DESCRI
			
		if empty((cAliasTMP)->AGA_MUNDES)
			cSend 	:= AllTrim((cAliasTMP)->AGA_NAMENT) + ", " + AllTrim((cAliasTMP)->AGA_COMP) + ", " + AllTrim((cAliasTMP)->AGA_END) + ", " + AllTrim((cAliasTMP)->AGA_HOUSE) + "."
		else
			cSend 	:= AllTrim((cAliasTMP)->AGA_NAMENT) + ", " + AllTrim((cAliasTMP)->AGA_MUNDES) + ", " + AllTrim((cAliasTMP)->AGA_END) + ", " + AllTrim((cAliasTMP)->AGA_HOUSE) + "."
		endif
		
		WHILE AT(', ,', cSend)!=0
			cSend := StrTran(cSend,', ,',',')
		ENDDO
		cSend := StrTran(cSend,', .','.')
		WHILE AT(',,', cSend)!=0
			cSend := StrTran(cSend,',,',',')
		ENDDO

		cSend := StrTran(cSend,',.','.')
		A8_SENDER	:= cSend
		A9_SUPPL	:= cSend	
		A10_CONT	:= ''	
		A11_CDATE	:= ''
		A12_DDATE	:= StrTran(DTOC(Stod((cAliasTMP)->F1_EMISSAO)),"/",".")
		A13_SDATE	:= cDate

		B1_DESC		:= (cAliasTMP)->B1_DESC	
		B2_UMRES	:= (cAliasTMP)->AH_UMRES
		B3_OKEI		:= (cAliasTMP)->AH_CODOKEI	
		B4_QUANT	:= (cAliasTMP)->D1_QUANT	
		B5_PRICE	:= (cAliasTMP)->D1_VUNIT	
		B6_TOTAL 	:= (cAliasTMP)->D1_TOTAL

		C1_POS		:= AllTrim(aSingers[3][1]) 	//cMvpar03	Head of committee C1-C2
		C2_NAME		:= AllTrim(aSingers[3][2])	//cMvpar03	Head of committee C1-C2

		C3_POS		:= AllTrim(aSingers[4][1])	//cMvpar04	member of the committee C3-C4
		C4_NAME		:= AllTrim(aSingers[4][2])	//cMvpar04	member of the committee C3-C4	

		C5_POS		:= AllTrim(aSingers[5][1])	//cMvpar05	member of the committee C5-C6	
		C6_NAME		:= AllTrim(aSingers[5][2])	//cMvpar05	member of the committee C5-C6	

		C7_POS		:= AllTrim(aSingers[6][1])	//cMvpar06 	member of the committee C7-C8	
		C8_NAME		:= AllTrim(aSingers[6][2])	//cMvpar06	member of the committee C7-C8	

		C9_NAME		:= AllTrim(aSingers[2][2])	//cMvpar02 h. Accountant C9

		MsUnlock()
		(cAliasTMP)->(dbSkip())
	EndDo

	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
return .T.

/*---------------------------------------------------------*/
static function GetSigners(cMvparN)
	Local aSingers as array
	Local cDESCSU as Char
	Local cRNome as Char
	Local cRANome as Char
	Local cAliasTM as Char
	Local cQuery as Char

	aSingers := {}
	IF cMvparN==''
		cRANome := ''
		cDESCSU := ''
	ELSE	
		cQuery := "SELECT DISTINCT F42_NAME, Q3_DESCSUM "
		cQuery += "FROM " + RetSqlName("F42") + " F42 " 
		
		cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA " 
		cQuery += "ON F42.F42_EMPL = SRA.RA_MAT "
		
		cQuery += "INNER JOIN " + RetSqlName("SQ3") + " SQ3 " 
		cQuery += "ON F42.F42_CARGO = SQ3.Q3_CARGO "

		cQuery += "WHERE SRA.RA_MAT = '" + cMvparN + "' " 
		cQuery += "AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
		cQuery += "AND SRA.D_E_L_E_T_ = ' ' "
		cQuery += "AND F42.F42_EMPL = '" + cMvparN + "' " 
		cQuery += "AND F42.F42_REPORT IN ('TORG-1', 'ALL') "
		cQuery += "AND F42.F42_FILIAL = '" + xFilial("F42") + "' "
		cQuery += "AND F42.D_E_L_E_T_ = ' ' "
		cQuery += "AND SQ3.SQ3_FILIAL = ' " + xFilial("SQ3") + "' "
		cQuery += "AND SQ3.D_E_L_E_T_ = ' ' "
		
		cQuery := Changequery(cQuery)

		cAliasTM := GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTM,.T.,.T.)
		DbSelectArea(cAliasTM)
		(cAliasTM)->(DbGoTop())
		cDESCSU := alltrim((cAliasTM)->Q3_DESCSUM)
		cRNome := alltrim((cAliasTM)->F42_NAME)

		cRANome := alltrim(substr(alltrim(cRNome),1,(at(' ',alltrim(cRNome),1))))
		cRANome += ' ' + alltrim(substr(alltrim(cRNome),(at(' ',alltrim(cRNome),1)),2))
		cRANome += '.' + alltrim(substr(alltrim(cRNome),(at(' ',alltrim(cRNome),len(cRANome))),2)) +'.'		
		(cAliasTM)->(dbCloseArea())

	ENDIF
	aadd(aSingers,cDESCSU)
	aadd(aSingers,cRANome)

RETURN aSingers

/*------------------------get full address-----------------------------------------------------*/

static function GetAdress(cAddrKey, cType)
	Local cAgaFull, cTab as char
	Local aAreaTMPTAB AS ARRAY
	aAreaTMPTAB := {}
	aCurAddrs := {}

	cQuery := "SELECT AGA_CEP, AGA_BAIRRO, AGA_END, AGA_HOUSE, AGA_BLDNG, AGA_APARTM, AGA_MUNDES "
	cQuery += "FROM " + RetSQLName("AGA") + " AGA "
	cQuery += "WHERE AGA_TIPO = '" + cType +  "' AND AGA_ENTIDA = 'SM0' "
	cQuery += "AND AGA_CODENT LIKE '%" + cAddrKey + "%' "
	cQuery += "AND AGA.AGA_FILIAL = '" + xFilial("AGA") + "' "
	cQuery += "AND AGA.D_E_L_E_T_ =' ' "

	cQuery := Changequery(cQuery)

	cTab := CriaTrab( , .F.)

	TcQuery cQuery NEW ALIAS ((cTab))  

	DbSelectArea((cTab))
	aAreaTMPTAB := (cTab)->(GetArea())

	cAgaFull := alltrim((cTab)->AGA_CEP)
	cAgaFull += ", " + alltrim((cTab)->AGA_BAIRRO) + alltrim((cTab)->AGA_MUNDES)
	cAgaFull += ", " + alltrim((cTab)->AGA_END) + ", " + alltrim((cTab)->AGA_HOUSE)
	cAgaFull += ", " + alltrim((cTab)->AGA_BLDNG) + ", " + alltrim((cTab)->AGA_APARTM)

	RestArea(aAreaTMPTAB)
return cAgaFull


/* = = = = = = = = = = = = changing format data = = = = = = = = = = = = = = = */
STATIC FUNCTION CMonthRUS (cMonths)
	local cRet as char
	DO CASE
		CASE cMonths = '01'
		cRet := STR0001
		CASE cMonths = '02'
		cRet := STR0002
		CASE cMonths = '03'
		cRet := STR0003
		CASE cMonths = '04'
		cRet := STR0004
		CASE cMonths = '05'
		cRet := STR0005
		CASE cMonths = '06'
		cRet := STR0006
		CASE cMonths = '07'
		cRet := STR0007
		CASE cMonths = '08'
		cRet := STR0008
		CASE cMonths = '09'
		cRet := STR0009
		CASE cMonths = '10'
		cRet := STR0010
		CASE cMonths = '11'
		cRet := STR0011
		CASE cMonths = '12'
		cRet := STR0012	
	ENDCASE
RETURN cRet
// Russia_R5
