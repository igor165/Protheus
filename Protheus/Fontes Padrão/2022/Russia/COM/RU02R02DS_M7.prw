#include "protheus.ch"
#Include 'birtdataset.ch'
#include "TOPCONN.CH"
#include "RU02R02.CH"

/*
Autor:			Anastasiya Kulagina
Data:			01/11/17
Description: 	Data set in birt format
*/

dataset RU02R02DS
Title 'M-7'
Description "M-7"


PERGUNTE "RU02R02DS"

Columns
define Column A1_DOC		TYPE CHARACTER SIZE 12 LABEL 'A1_DOC'				//A1 System Document number 
define Column A2_POS		TYPE CHARACTER SIZE 60 LABEL 'A2_POS'				//A2 Established position 
define Column A3_NAME		TYPE CHARACTER SIZE 60 LABEL 'A3_NAME'				//A3 Name of responsible person 
define Column A4_DATE		TYPE CHARACTER SIZE 20 LABEL 'A4_DATE'			    //A4 Document date 
define Column A5_DATA		TYPE CHARACTER SIZE 200 LABEL 'A5_Company data'		//A5 Company data 
define Column A6_OKPO		TYPE CHARACTER SIZE 9 LABEL 'A6_OKPO'				//A6 Company OKPO code 
define Column A7_ADDR		TYPE CHARACTER SIZE 200 LABEL 'A7_Company address'	//A7 Company address 
define Column A8_SENDER		TYPE CHARACTER SIZE 200 LABEL 'A8_SENDER'			//A8 Sender 
define Column A9_SUPPL		TYPE CHARACTER SIZE 200 LABEL 'A9_SUPPLIER'			//A9 Supplier 
define Column A10_RECEIV	TYPE CHARACTER SIZE 200 LABEL 'A10_RECEIVER'		//A10 Receiver 
define Column A11_CONT		TYPE CHARACTER SIZE 12 LABEL 'A11_CONT'				//A11 Contract number 
define Column A12_CDATE		TYPE CHARACTER SIZE 10 LABEL 'A12_CDATE'			//A12 Contract date 
define Column A13_DESC		TYPE CHARACTER SIZE 30 LABEL 'A13_DESC'				//A13 Material description 
define Column A14_UMRES		TYPE CHARACTER SIZE 25 LABEL 'A14_UMRES'			//A14 Base unit of measure 

define Column B1_SSUB		TYPE CHARACTER SIZE 9 LABEL 'B1_SSUB'				//B1 Structural subdivision 
define Column B2_DESCRI		TYPE CHARACTER SIZE 20 LABEL 'B2_DESCRI'			//B2 warehouse name 
define Column B3_SUPPL		TYPE CHARACTER SIZE 6 LABEL 'B3_SUPPLIER'			//B3 Supplier’s code 
define Column B4_CONTA		TYPE CHARACTER SIZE 20 LABEL 'B4_CONTA'				//B4 Supplier’s account number 
define Column B5_DOC 		TYPE CHARACTER SIZE 8 LABEL 'B5_DOC'				//B5 External Document number 


define Column C1_POS		TYPE CHARACTER SIZE 60 LABEL 'C1_POS'				//C1 Established position 
define Column C2_NAME		TYPE CHARACTER SIZE 60 LABEL 'C2_NAME' 				//C2 Employee’s name 
define Column C3_POS		TYPE CHARACTER SIZE 60 LABEL 'C3_POS' 				//C3 Established position 
define Column C4_NAME		TYPE CHARACTER SIZE 60 LABEL 'C4_NAME' 				//C4 Employee’s name 
define Column C5_POS		TYPE CHARACTER SIZE 60 LABEL 'C5_POS' 				//C5 Established position 
define Column C6_NAME 		TYPE CHARACTER SIZE 60 LABEL 'C6_NAME'				//C6 Employee’s name 
define Column C7_NAME  		TYPE CHARACTER SIZE 60 LABEL 'C7_NAME'				//C7 Name of Stockman 
define query 	"SELECT * FROM %WTable:1% "

process dataset

Local cWTabAlias as char
Local cMvpar01 as char 		//Approved
Local cMvpar02 as char 		//Warehouse Manager.
Local cMvpar03 as char 		//committee member
Local cMvpar04 as char 		//committee member
Local cSelFil as char 
Local cEmissao as char
Local cSelDoc  as char
Local lRet as logical

lRet := .F.
cWTabAlias := self:createWorkTable()
If self:isPreview()
endif

chkFile("SF1")
cSelDoc := SF1->F1_DOC
cSelFil := SF1->F1_FILIAL
cEmissao := DTOS (SF1->F1_DTDIGIT)
cSelFil := strtran(cSelFil, '"', "")
cSelDoc := strtran(cSelDoc, '"', "")
cEmissao := strtran(cEmissao, '"', "")
cMvpar01 := alltrim(self:execParamValue( "MV_PAR01" ))		//Approved.
cMvpar02 := alltrim(self:execParamValue( "MV_PAR02" ))		//Warehouse Manager.
cMvpar03 := ''  											//committee member
cMvpar04 := ''												//committee member

Processa({|_lEnd| lRet := X60NOT(cWTabAlias, cMvpar01, cMvpar02, cMvpar03, cMvpar04, cSelDoc, cSelFil, cEmissao )}, ::title())

return .T.


////////////////////////////////////////////////////////////////////////////
static function X60NOT(cAliasMov, cMvpar01, cMvpar02, cMvpar03, cMvpar04, cSelDoc, cSelFil, cEmissao )
	Local aArea as array
	Local aCData as array
	Local aCData1 as array
	Local aSingers as array
	Local cAliasTMP as Char
	Local cQuery as Char
	Local cAddrKey as Char
	Local cDate as Char
	Local cSend as Char
	Local cSupl as Char
	Local CFdata as Char
	Local cMonths as Char
	
	aSingers := {}
	aadd (aSingers, GetSigners(cMvpar01)) //Approved.
	aadd (aSingers, GetSigners(cMvpar02)) //Warehouse Manager.
	aadd (aSingers, GetSigners(cMvpar03)) //committee member
	aadd (aSingers, GetSigners(cMvpar04)) //committee member
	
	aArea := getArea()
	
	aCData := FwComAltInf({'CO_OKPO', 'CO_FULLNAM', 'CO_COMPGRP', 'CO_COMPEMP', 'CO_TIPO', 'CO_PHONENU', 'CO_COMPUNI'})
	
	cAddrKey := xFilial("SM0") + padr(aCData[3][2],Len(FwComAltInf({"XX8_GRPEMP"})[1][2]));
	 + padr(aCData[4][2], Len(FwComAltInf({"XX8_EMPR"})[1][2]));
	 + padr(aCData[5][2], Len(FwComAltInf({"XX8_CODIGO"})[1][2]))
		 
	aCData1 := GetCoBrRUS(cSelFil)
  	
	aadd(aCData, GetAdress(cAddrKey, '0')) 	//Legal address of the company 
	aadd(aCData, aCData1[3][2][22]) 		//The actual address of the branch
	
	WHILE AT(', ,', aCData[9]) != 0
			aCData[9] := StrTran(aCData[9],', ,',',')
	ENDDO
	aCData[9] := StrTran(aCData[9], ', .', '.')
	WHILE AT(',,', aCData[9])!=0
			aCData[9] := StrTran(aCData[9], ',,', ',')
	ENDDO
	aCData[9] := StrTran(aCData[9], ',.', '.')
	
	cQuery := "SELECT F1_DTDIGIT, F1_FORNECE, F1_DOC, A2_NOME, A2_MUN, A2_END, A2_CONTA, "
	cQuery += "D1_CC, D1_COD, B1_DESC, D1_ITEM, AH_UMRES, D1_UM, NNR_DESCRI, A2_TEL "
	
	cQuery += "FROM " + RetSqlName("SF1") + " SF1 "
	
	cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery += "ON SA2.A2_COD = SF1.F1_FORNECE "
	cQuery += "AND SA2.A2_LOJA = SF1.F1_LOJA "
	cQuery += "AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
	cQuery += "AND SA2.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSqlName("SD1") + " SD1 "
	cQuery += "ON SD1.D1_DOC = SF1.F1_DOC "
	cQuery += "AND SD1.D1_SERIE = SF1.F1_SERIE "
	cQuery += "AND SD1.D1_FORNECE = SF1.F1_FORNECE "
	cQuery += "AND SD1.D1_LOJA = SF1.F1_LOJA "
	cQuery += "AND SD1.D1_ESPECIE = SF1.F1_ESPECIE "
	cQuery += "AND SD1.D1_TIPODOC = SF1.F1_TIPODOC "
	cQuery += "AND SD1.D1_Filial = '" + xfilial('SD1') + "' "	
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' "
	
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "ON SB1.B1_COD = SD1.D1_COD "
	cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
	
	cQuery += "INNER JOIN " + RetSqlName("SAH") + " SAH "
	cQuery += "ON SAH.AH_UNIMED = SB1.B1_UM "
	cQuery += "AND SAH.AH_FILIAL = '" + xfilial('SAH') + "' "
	cQuery += "AND SAH.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSqlName("NNR") + " NNR "
	cQuery += "ON NNR.NNR_CODIGO = SD1.D1_LOCAL "
	cQuery += "AND NNR.NNR_FILIAL = '" + xfilial('NNR') + "' "
	cQuery += "AND NNR.D_E_L_E_T_ = ' ' "

	cQuery += "WHERE SF1.F1_DOC = '" + cSelDoc + "' "
	cQuery += "AND SF1.F1_DTDIGIT = '" + cEmissao + "' "	
	cQuery += "AND SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' "
	
	cQuery += "ORDER BY D1_ITEM "	
	
	cQuery := ChangeQuery(cQuery)
	
	cAliasTMP := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T.)
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
		
	cMonths:= cMonthRUS (SUBSTR(cEmissao, 5, 2))
	cDate := '"' + SUBSTR(cEmissao, 7, 2) + '"  ' +  cMonths + '  ' + SUBSTR(cEmissao, 1, 4) + 'ã.'
	
	(cAliasTMP)->(dbGotop())
	
	While (cAliasTMP)->(!EOF())
		RecLock(cAliasMov,.T.)
		
		A1_DOC 		:= ''
		A2_POS 		:= aSingers[1][1]
		A3_NAME 	:= aSingers[1][2]
		A4_DATE 	:= cDate
		A5_DATA 	:= AllTrim(aCData[2][2])
		A6_OKPO 	:= aCData[1][2]
		A7_ADDR		:= AllTrim(aCData[9])
		cSend 		:= AllTrim((cAliasTMP)->A2_NOME) + ", " + AllTrim((cAliasTMP)->A2_MUN) + ", " + AllTrim((cAliasTMP)->A2_END) + ", " + AllTrim((cAliasTMP)->A2_TEL) + "."
		WHILE AT(', ,', cSend)!=0
			cSend := StrTran(cSend,', ,',',')
		ENDDO
		cSend := StrTran(cSend,', .','.')
		WHILE AT(',,', cSend)!=0
			cSend := StrTran(cSend,',,',',')
		ENDDO
		cSend := StrTran(cSend,',.','.')
		A8_SENDER 	:= cSend
		cSupl := cSend
		A9_SUPPL 	:= cSupl
		A10_RECEIV 	:= CFdata
		A11_CONT 	:= ''
		A12_CDATE 	:= ''
		A13_DESC 	:= (cAliasTMP)->B1_DESC
		A14_UMRES 	:= (cAliasTMP)->AH_UMRES
		
		B1_SSUB 	:= (cAliasTMP)->D1_CC
		B2_DESCRI 	:= (cAliasTMP)->NNR_DESCRI
		B3_SUPPL 	:= (cAliasTMP)->F1_FORNECE
		B4_CONTA 	:= (cAliasTMP)->A2_CONTA
		B5_DOC 		:= (cAliasTMP)->F1_DOC
		
		C1_POS 		:= aSingers[3][1]
		C2_NAME 	:= aSingers[3][2]
		C3_POS 		:= aSingers[4][1]
		C4_NAME 	:= aSingers[4][2]
		C5_POS 		:=''
		C6_NAME 	:=''
		C7_NAME 	:= aSingers[2][2]
		
		MsUnlock()
		(cAliasTMP)->(dbSkip())
	EndDo
	
	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
return .T.
/*---------------------------------------------------------*/
static function GetSigners(cMvpar01)
	Local aSingers as array
	Local cDESCSU as Char
	Local cRNome as Char
	Local cRANome as Char
	Local cAliasTM as Char
	Local cQuery as Char
	
	aSingers := {}
	IF cMvpar01==''
		cRANome := ''
		cDESCSU := ''
	ELSE	
		cQuery := "SELECT DISTINCT F42_NAME, Q3_DESCSUM "
		
		cQuery += "FROM " + RetSqlName("F42") + " F42 " 
		
		cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA " 
		cQuery += "ON SRA.RA_MAT = F42.F42_EMPL "
		cQuery += "AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' "	 
		cQuery += "AND SRA.D_E_L_E_T_= ' ' "

		cQuery += "INNER JOIN " + RetSqlName("SQ3") + " SQ3 " 
		cQuery += "ON SQ3.Q3_CARGO = F42.F42_CARGO "
		cQuery += "AND SQ3.Q3_FILIAL = '" + xFilial("SQ3") + "' "
		cQuery += "AND SQ3.D_E_L_E_T_= ' ' "

		cQuery += "WHERE SRA.RA_MAT = '" + cMvpar01 + "' " 
		cQuery += "AND F42.F42_EMPL = '" + cMvpar01 + "' " 
		cQuery += "AND F42.F42_REPORT IN ('M7', 'ALL') "
		cQuery += "AND F42.F42_FILIAL = '" + xFilial("F42") + "' "
		cQuery += "AND F42.D_E_L_E_T_= ' ' "		
	
		cQuery := ChangeQuery(cQuery)

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
	cQuery += "AND AGA.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

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
/*---------------------------------------------------------------------------------------------*/
STATIC FUNCTION cMonthRUS (cMonths)
	DO CASE
		CASE cMonths = '01'
		 RETURN STR0001
		CASE cMonths = '02'
		 RETURN STR0002
		CASE cMonths = '03'
		 RETURN STR0003
		CASE cMonths = '04'
		 RETURN STR0004
		CASE cMonths = '05'
		 RETURN STR0005
		CASE cMonths = '06'
		 RETURN STR0006
		CASE cMonths = '07'
		 RETURN STR0007
		CASE cMonths = '08'
		 RETURN STR0008
		CASE cMonths = '09'
		 RETURN STR0009
		CASE cMonths = '10'
		 RETURN STR0010
		CASE cMonths = '11'
		 RETURN STR0011
		CASE cMonths = '12'
		 RETURN STR0012	
	ENDCASE