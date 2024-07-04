#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"


/*
Autor:			Anastasiya Kulagina
Data:			01/11/17
Description: 	Data set in birt format
*/

dataset RU04R01DS
	Title "M-11"
	Description "Print M-11"
	PERGUNTE "RU04R01DS"
	

Columns
define Column D3_EMISSAO	TYPE CharACTER SIZE 10 LABEL 'D3_EMISSAO'			//4H Document date / Дата документа
define Column D3_DOC		TYPE CharACTER SIZE 10 LABEL 'D3_DOC'				//3H System Document number / Номер документа
define Column D3_LOCAL1		TYPE CharACTER SIZE 2 LABEL	'D3_LOCAL1'				//5H Issuing warehouse code, sender / отправитель
define Column NR_DESCRI1	TYPE CharACTER SIZE 20 LABEL 'NR_DESCRI1'			//6H Issuing warehouse name, sender / отправитель
define Column D3_LOCAL2		TYPE CharACTER SIZE 2 LABEL	'D3_LOCAL2'				//7H Receiving warehouse code, recipient / получатель
define Column NR_DESCRI2	TYPE CharACTER SIZE 20 LABEL 'NR_DESCRI2'			//8H Receiving warehouse name, recipient / получатель
define Column CO_DATA		TYPE CharACTER SIZE 200 LABEL 'Company data'		//1H Company data / Данные компании
define Column CO_OKPO		TYPE CharACTER SIZE 9 LABEL 'CO_OKPO'				//2H Company OKPO code / ОКПО компании
define Column D3_CONTA		TYPE CharACTER SIZE 20 LABEL 'D3_CONTA'				//1i Stock account code / Код счета
define Column B1_DESC		TYPE CharACTER SIZE 30 LABEL 'B1_DESC'				//3i Material description / Описание материала
define Column D3_COD		TYPE CharACTER SIZE 15 LABEL 'D3_COD'				//4i Material code / Код материала
define Column AH_CODOKEI	TYPE CharACTER SIZE 4 LABEL 'AH_CODOKEI'			//5i Base unit of measure system code / Системного код меры
define Column AH_UMRES		TYPE CharACTER SIZE 25 LABEL 'AH_UMRES'				//6i Base unit of measure short name / Системное имя меры
define Column NNT_QUANT 	TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'NNT_QUANT'	//7i Requested quantity in base units / Требуемое количество в базовых единицах
define Column D3_QUANT		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'D3_QUANT'	//8i Posted quantity in base units / Количество в базовых единицах
define Column B1_UPRC		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'B1_UPRC'		//9i Price per base unit / Цена за базовую единицу
define Column D3_CUSTO1		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'D3_CUSTO1'	//10i Total value for the row without Tax (VAT) / Общая стоимость строки без налога (НДС)

define Column Q3_DESCSU1 	TYPE CharACTER SIZE 60 LABEL 'Q3_DESCSU1'			// issued by, position/Отпустил, должность
define Column RA_NOME1 		TYPE CharACTER SIZE 60 LABEL 'RA_NOME1'				// issued by,Full name/Отпустил, расшифровка
define Column Q3_DESCSU2 	TYPE CharACTER SIZE 60 LABEL 'Q3_DESCSU2'			// Receiver, position/Получил, должность
define Column RA_NOME2 		TYPE CharACTER SIZE 60 LABEL 'RA_NOME2'				// Receiver, Full name/Получил, расшифровка

define query 	"SELECT * FROM %WTable:1% "

process dataset

Local cWTabAlias	as Char
Local cMvpar01		as Char
Local cMvpar02		as Char
Local cSelFil		as Char
Local cEmissao		as Char
Local cSelDoc		as Char
Local lRet			as Logical

lRet 	:= .F.
cWTabAlias := Self:CreateWorkTable()
If Self:isPreview()
EndIf

chkFile("SD3")
cSelDoc		:=	SD3->D3_DOC
cSelFil		:=	SD3->D3_FILIAL
cEmissao	:=	DTOS (SD3->D3_Emissao)
cSelFil		:=	Strtran(cSelFil,'"',"")
cSelDoc 	:=	Strtran(cSelDoc,'"',"")
cEmissao	:=	Strtran(cEmissao,'"',"")
cMvpar01	:=	Alltrim(Self:ExecParamValue( "MV_PAR01" ))
cMvpar02	:=	Alltrim(Self:ExecParamValue( "MV_PAR02" ))

Processa({|_lEnd| lRet := X60NOT(cWTabAlias, cMvpar01, cMvpar02, cSelDoc, cSelFil, cEmissao )}, ::title())

Return .T.


////////////////////////////////////////////////////////////////////////////
static function X60NOT(cAliasMov, cMvpar01, cMvpar02, cSelDoc, cSelFil, cEmissao )
	Local aArea		as Array
	Local aCDate	as Array
	Local aSingers	as Array
	Local cADDRESS	as Char
	Local cAliasTMP	as Char
	Local cQuery	as Char
	Local cTab		as Char
	Local cAddrKey	as Char
	Local CM1
	Local CUSTO1
	
	aSingers := {}
	aadd (aSingers, GetSigners(cMvpar01))
	aadd (aSingers, GetSigners(cMvpar02))
	
	aArea := getArea()
	
	aCDate := FwComAltInf({'CO_KPP','CO_INN','CO_OKPO','CO_FULLNAM','CO_PHONENU','CO_COMPGRP','CO_COMPEMP','CO_TIPO','CO_COMPUNI'})
	
	cAddrKey := xFilial("SM0") + padr(aCDate[6][2],Len(FwComAltInf({"XX8_GRPEMP"})[1][2]));
	 + padr(aCDate[7][2],Len(FwComAltInf({"XX8_EMPR"})[1][2]));
	 	//+ padr(aCDate[9][2],Len(FwComAltInf({"XX8_UNID"})[1][2]));
	 	  + padr(aCDate[8][2],Len(FwComAltInf({"XX8_CODIGO"})[1][2]))	  
	
	aadd(aCDate,GetAdress(cAddrKey))
	
	cQuery := ''

	cQuery := "SELECT DISTINCT  D3_EMISSAO, D3_CF, D3_LOCAL, NNR_DESCRI, D3_CONTA, B1_DESC, D3_COD, AH_CODOKEI, AH_UMRES, " 
	cQuery += "NNT_QUANT, D3_QUANT, B2_CM1, D3_CUSTO1, SD3.R_E_C_N_O_ " 
	cQuery += "FROM " + RetSqlName("SD3") + " SD3 "
	
	cQuery += "INNER JOIN " + RetSqlName("NNR") + " NNR "
	cQuery += "ON NNR.NNR_CODIGO = SD3.D3_LOCAL " 
	cQuery += "AND NNR.NNR_FILIAL = '" + cSelFil + "' "
	
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 " 
	cQuery += "ON SB1.B1_COD = SD3.D3_COD "
	
	cQuery += "INNER JOIN " + RetSqlName("SAH") + " SAH " 
	cQuery += "ON SAH.AH_UNIMED = SD3.D3_UM "
	
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " SB2 "
	cQuery += "ON SB2.B2_COD = SB1.B1_COD " 
	cQuery += "AND SB2.B2_FILIAL = '" + cSelFil + "' "

	
	cQuery += "LEFT JOIN " +  RetSqlName("NNT") + " NNT "
	cQuery += "ON NNT.NNT_DOC = SD3.D3_DOC "
	cQuery += "OR NNT.NNT_DOC = NULL "
	
	cQuery += "WHERE SD3.D3_CF IN ('DE4', 'RE4') "
	cQuery += "AND SD3.D_E_L_E_T_=' ' " 
	cQuery += "AND NNR.D_E_L_E_T_=' ' "
	cQuery +=  "AND SB1.D_E_L_E_T_=' ' " 
	cQuery +=  "AND SB2.D_E_L_E_T_=' ' " 
	cQuery +=  "AND SAH.D_E_L_E_T_=' ' " 
	cQuery +=  "AND (NNT.D_E_L_E_T_=' ' OR NNT.D_E_L_E_T_ is NULL) "
	cQuery +=  "AND SD3.D3_DOC = '" + cSelDoc + "' " 
	cQuery += "AND SD3.D3_EMISSAO = '" + cEmissao + "' "
	cQuery += "ORDER BY R_E_C_N_O_"
	cQuery := ChangeQuery(cQuery)
	
	cAliasTMP := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)

	/*--------------FULLNAM---------------------------ADDRESS-------------------PHONENU---------------*/
	cADDRESS:= AllTrim(aCDate[4][2])+ ',' + AllTrim(aCDate[9]) + ', ' + AllTrim(aCDate[5][2]) +  ', ИНН ' + AllTrim(aCDate[2][2]) + ', КПП ' + AllTrim(aCDate[1][2]) + "."
	WHILE AT(', ,', cADDRESS)!=0
		cADDRESS := StrTran(cADDRESS,', ,',',')
	ENDDO
	cADDRESS := StrTran(cADDRESS,', .','.')
	
	WHILE AT(',,', cADDRESS)!=0
		cADDRESS := StrTran(cADDRESS,',,',',')
	ENDDO
	cADDRESS := StrTran(cADDRESS,',.','.')
	(cAliasTMP)->(dbGotop())
	
	While (cAliasTMP)->(!EOF())
		RecLock(cAliasMov,.T.)
		CO_DATA := cADDRESS
		CO_OKPO := aCDate[3][2]
		D3_EMISSAO := DTOC (STOD ((cAliasTMP)->D3_EMISSAO))
		Q3_DESCSU1 := aSingers[1][1]	
		RA_NOME1 :=	aSingers[1][2]
		Q3_DESCSU2 := aSingers[2][1]
		RA_NOME2 := aSingers[2][2]
		IF (LEN(cSelDoc)> 10 )
			D3_DOC:= CVALTOChar(VAL (RIGHT(cSelDoc, 10)))
		ELSE
			D3_DOC	:= CVALTOChar(VAL(cSelDoc))
		ENDIF
		
		If ((cAliasTMP)->D3_CF == 'RE4')
			D3_LOCAL1	:= (cAliasTMP)->D3_LOCAL
			NR_DESCRI1	:= (cAliasTMP)->NNR_DESCRI
			D3_CONTA	:= (cAliasTMP)->D3_CONTA
			B1_DESC		:= (cAliasTMP)->B1_DESC
			D3_COD		:= (cAliasTMP)->D3_COD
			AH_CODOKEI	:= (cAliasTMP)->AH_CODOKEI
			AH_UMRES	:= (cAliasTMP)->AH_UMRES
			IF (cAliasTMP)->NNT_QUANT != 0
				NNT_QUANT := (cAliasTMP)->NNT_QUANT
			ELSE
				NNT_QUANT := (cAliasTMP)->D3_QUANT
			ENDIF
			D3_QUANT	:= (cAliasTMP)->D3_QUANT
			CM1 := (cAliasTMP)->B2_CM1
			B1_UPRC		:= (cAliasTMP)->B2_CM1
			D3_CUSTO1	:= (cAliasTMP)->D3_CUSTO1
			
			(cAliasTMP)->(dbSkip())
			D3_LOCAL2	:= (cAliasTMP)->D3_LOCAL
			NR_DESCRI2	:= (cAliasTMP)->NNR_DESCRI
		ELSE
			D3_LOCAL2	:= (cAliasTMP)->D3_LOCAL
			NR_DESCRI2	:= (cAliasTMP)->NNR_DESCRI
			(cAliasTMP)->(dbSkip())
			D3_LOCAL1	:= (cAliasTMP)->D3_LOCAL
			NR_DESCRI1	:= (cAliasTMP)->NNR_DESCRI
			D3_CONTA	:= (cAliasTMP)->D3_CONTA
			B1_DESC		:= (cAliasTMP)->B1_DESC
			D3_COD		:= (cAliasTMP)->D3_COD
			AH_CODOKEI	:= (cAliasTMP)->AH_CODOKEI
			AH_UMRES	:= (cAliasTMP)->AH_UMRES
			IF (cAliasTMP)->NNT_QUANT != 0
				NNT_QUANT := (cAliasTMP)->NNT_QUANT
			ELSE
				NNT_QUANT := (cAliasTMP)->D3_QUANT
			ENDIF
			D3_QUANT	:= (cAliasTMP)->D3_QUANT
			B1_UPRC		:= (cAliasTMP)->B2_CM1
			D3_CUSTO1	:= (cAliasTMP)->D3_CUSTO1
		ENDIF
		MsUnlock()
		(cAliasTMP)->(dbSkip())
	EndDo
	
	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
Return .T.
/*---------------------------------------------------------*/
static function GetSigners(cMvpar01)
	Local aSingers		as Array
	Local cDESCSU		as Char
	Local cRNome		as Char
	Local cRANome		as Char
	Local cAliasTM		as Char
	Local cQuery		as Char
	Local cTab			as Char
	Local cAddrKey		as Char
	
	aSingers := {}
	IF cMvpar01==''
		cRANome := ''
		cDESCSU := ''
	ELSE	
		cQuery := "SELECT DISTINCT F42_NAME, Q3_DESCSUM "
		cQuery += "FROM " + RetSqlName("F42") + " F42 " 
		cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA " 
		cQuery += "ON F42.F42_EMPL = SRA.RA_MAT " 
		cQuery += "INNER JOIN " + RetSqlName("SQ3") + " SQ3 " 
		cQuery += "ON F42.F42_CARGO = SQ3.Q3_CARGO "
		cQuery += "WHERE SRA.RA_MAT = '" + cMvpar01 + "' " 
		cQuery += "AND F42.F42_EMPL = '" + cMvpar01 + "' " 
		cQuery += "AND F42.F42_REPORT IN('M11','ALL') "
		cQuery += "AND F42.D_E_L_E_T_=' ' "
		cQuery += "AND SRA.D_E_L_E_T_=' ' "
		cQuery += "AND SQ3.D_E_L_E_T_=' '"
	
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
	
Return aSingers

/*------------------------get full address-----------------------------------------------------*/
Static Function GetAdress(cAddrKey)
	Local cAgaFull as Char
	Local cTab as Char
	Local aAreaTMP AS ARRAY
	
	aAreaTMP := {}
	aCurAddrs := {}
	cQuery := "SELECT AGA_CEP, AGA_BAIRRO, AGA_END, AGA_HOUSE, AGA_BLDNG, AGA_APARTM, AGA_MUNDES "
	cQuery += "FROM " + RetSQLName("AGA") + " AGA "
	cQuery += "WHERE AGA_TIPO = '0' AND AGA_ENTIDA = 'SM0' "
	cQuery += "AND AGA_CODENT LIKE '%" + cAddrKey + "%'"
		
	cTab := CriaTrab( , .F.)

	TcQuery cQuery NEW ALIAS ((cTab))  
    
	DbSelectArea((cTab))
	aAreaTMP := (cTab)->(GetArea())

	cAgaFull := alltrim((cTab)->AGA_CEP)
	cAgaFull += ", " + alltrim((cTab)->AGA_BAIRRO) + alltrim((cTab)->AGA_MUNDES)
	cAgaFull += ", " + alltrim((cTab)->AGA_END) + ", " + alltrim((cTab)->AGA_HOUSE)
	cAgaFull += ", " + alltrim((cTab)->AGA_BLDNG) + ", " + alltrim((cTab)->AGA_APARTM)

	RestArea(aAreaTMP)
	WHILE AT(', ,', cAgaFull)!=0
		cAgaFull := StrTran(cAgaFull,', ,',',')
	ENDDO
	cAgaFull := StrTran(cAgaFull,', .','.')
	
	WHILE AT(',,', cAgaFull)!=0
		cAgaFull := StrTran(cAgaFull,',,',',')
	ENDDO
	cAgaFull := StrTran(cAgaFull,',.','.')
	
Return cAgaFull
/*---------------------------------------------------------------------------------------------*/
// Russia_R5
