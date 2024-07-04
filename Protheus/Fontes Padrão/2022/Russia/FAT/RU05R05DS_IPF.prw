#include "protheus.ch"
#Include 'birtdataset.ch'
#include "TOPCONN.CH"
#include "RU02R02.CH"

	dataset ru05r05
    Title 'TORG 13'
    Description "TORG 13 PRINT FORM"
    PERGUNTE "RU04R01DS" 
    SX3->(DbSetorder(2)) 

Columns
    
//--------------------------------------------------------------------
//first page of details
define Column	B1_DESC 		TYPE	CHARACTER   SIZE 200	DECIMALS 0 LABEL 'B1_DESC'			//desc of product
define Column	B2_PROD 		TYPE	CHARACTER	SIZE 15		DECIMALS 0 LABEL 'B2_PROD'			//prod. code
define Column	B3_DESCRI	 	TYPE	CHARACTER 	SIZE 20		DECIMALS 0 LABEL 'B3_DESCRI'		//desc. of un of measure
define Column	B4_CODOKEY 		TYPE	CHARACTER 	SIZE 20     DECIMALS 0 LABEL 'B4_CODOKEY' 		//code  of un of measure
            
define Column	B5_QUANT 		TYPE	NUMERIC	 	SIZE 20	 	DECIMALS 2 LABEL 'B5_QUANT'			//product amount
define Column	B6_CUSTO1 		TYPE	NUMERIC	 	SIZE 20	 	DECIMALS 2 LABEL 'B6_CUSTO1'
define Column	B7_SUMMA 		TYPE	NUMERIC 	SIZE 20	 	DECIMALS 2 LABEL 'B7_SUMMA'   		//product amount cost	         
define Column	B8_TOTAL 		TYPE	NUMERIC 	SIZE 20	 	DECIMALS 2 LABEL 'B8_TOTAL'

define Column	A1_NOMA			TYPE 	CHARACTER 	SIZE 12	 	DECIMALS 0 LABEL 'A1_NOMA'			//num. of doc
define Column	A2_DATA			TYPE 	CHARACTER 	SIZE 8 	 	DECIMALS 0 LABEL 'A2_DATA'			//date of doc								
define Column	A3_OFIL			TYPE 	CHARACTER 	SIZE 6 	 	DECIMALS 0 LABEL 'A3_OFIL'			//branch - sender
define Column	A4_PFIL			TYPE 	CHARACTER 	SIZE 6 	 	DECIMALS 0 LABEL 'A3_PFIL'			//branch - recipient

define Column	A7_NAME         TYPE    CHARACTER   SIZE 200 	DECIMALS 0 LABEL 'Full name'		//com. name
define Column	A8_OKPO         TYPE    CHARACTER   SIZE 9   	DECIMALS 0 LABEL 'OKPO'				//com. OKPO code
define Column	A9_AGANM        TYPE    CHARACTER   SIZE 100 	DECIMALS 0 LABEL 'A9_AGANM'			//fil. name
define Column	A10_AGANM       TYPE    CHARACTER   SIZE 100 	DECIMALS 0 LABEL 'A10_AGANM'		//fil. name
            
define Column	C5_QUANT 		TYPE	NUMERIC	 	SIZE 20	 	DECIMALS 2 LABEL 'C5_QUANT'			//total quant
define Column	X5_QUANT 		TYPE	NUMERIC	 	SIZE 20	 	DECIMALS 2 LABEL 'X5_QUANT'         //total quant by page

define Column	C11_STCMAN	  	TYPE	CHARACTER	SIZE 53  	DECIMALS 0 LABEL 'C11_STCMAN'       //name       
define Column	C13_STCMAN 		TYPE	CHARACTER	SIZE 50  	DECIMALS 0 LABEL 'C13_STCMAN'       //name   		
define Column	C14_TOTVAL		TYPE	CHARACTER	SIZE 60  	DECIMALS 2 LABEL 'C14_TOTVAL'       //total RUB value

define Column	X14_TOTVAL		TYPE	CHARACTER	SIZE 60  	DECIMALS 2 LABEL 'X14_TOTVAL'       //total by page			
define Column	C14_TOTVA2		TYPE	CHARACTER	SIZE 60  	DECIMALS 2 LABEL 'C14_TOTVA2'       //total copeics value
define Column	C10_ROLE   		TYPE	CHARACTER	SIZE 80  	DECIMALS 0 LABEL 'C10_ROLE'         //role of signer
define Column	C11_ROLE   		TYPE	CHARACTER	SIZE 80  	DECIMALS 0 LABEL 'C11_ROLE'			//role of signer  


define query    "SELECT * FROM %WTable:1% "
process dataset


Local cWTabAlias as char
Local lRet as logical
Local cComPar	as character 
Local aSigners  as Array
Local cNNSIni   := NNS->NNS_COD
Local cNNSFil   := NNS->NNS_FILIAL

//These variables can be used in any report function.
	cComPar := Alltrim(SuperGetMv("MV_CMPLVL",.F.,""))
	lRet    := .f.
	cWTabAlias := ::createWorkTable()
	
	chkFile("SA2")
	aSigners := {} 
	aadd(aSigners,self:execParamValue( "MV_PAR01" ))
	aadd(aSigners,self:execParamValue( "MV_PAR02" ))
	   
	
//Running a report through the main function
	Processa({|_lEnd| lRet := X60NOT(cWTabAlias,cNNSIni,cNNSFil,aSigners,cComPar)}, ::title()) 
return .T.



//=================================================================================================

//The main function which collects the report. Uses auxiliary functions to get signatories and information for the header of the report.
//Returns .T.
//At the input accepts data about the company and the signatories of the parameters, and data about the alias, branch and document number.
//It is used in all reports and is also called as here, by it you can search for other datasets of printed forms.
//-------------------------------------------------------------------------------------------------
static function X60NOT(cAliasMov,cNNSIni,cNNSFil,aSigners,cComPar)
//-------------------------------------------------------------------------------------------------
//=================================================================================================
local   nI as numeric
Local aArea, aComData as array
Local cQuery,cAliasTMP as Character 
local aheader as array
local cA9vidD as character
local cA10vidD as char
local cOrole, cProle as character
local cOstcman, cPstcman as character
local nVatVal as numeric
local nQuaVal as numeric

	nI :=  0
	nVatVal		:= 0
	nQuaVal     := 0
	
	
//getting signatories
	cOstcman := (getHerr(aSigners[1], cNNSIni, cNNSFil)[1])
	cPstcman := (getHerr(aSigners[2], cNNSIni, cNNSFil)[1])
	cOrole  := (getHerr(aSigners[1], cNNSIni, cNNSFil)[2])
	cProle  := (getHerr(aSigners[2], cNNSIni, cNNSFil)[2])
	
//receiving company data   
	aComData := {}
	aComData := GetCoBrRUS() 
	cAliasTM2 := CriaTrab( , .F.)
	
//getting information from header
	aheader := {}
	aheader := GetApart(cAliasTM2,cNNSIni,cNNSFil)
	
	
	
	cA9vidD := aComData[1][5][2]
	cA10vidD := aComData[1][12][2]
	
	nCount := 1
	aArea := getArea()
	cAliasTMP   := GetNextAlias()
//data retrieval for report rows from NNT,SB1,SAH,SD2
	cQuery := ""
	cQuery += "SELECT * FROM " + RetSqlName("NNT") + " NNT "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON NNT.NNT_PROD = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN " + RetSqlName("SAH") + " SAH ON NNT.NNT_UM = SAH.AH_UNIMED AND SAH.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN " + RetSqlName("SD2") + " SD2 ON NNT.NNT_DOC = SD2.D2_DOC AND SD2.D_E_L_E_T_ = '' AND SD2.D2_FILIAL = NNT.NNT_FILIAL"
	cQuery += " WHERE NNT.NNT_FILIAL = '" + cNNSFil + "' "   
	cQuery += " AND NNT.NNT_COD = '" + cNNSIni + "' " 
	
	cAliasTMP   := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)
	
	//----------------------------------------
//Value assignment to dataset columns
	WHILE  (cAliasTMP)->(!EOF())
	     
	        RecLock(cAliasMov,.T.)
	            nI++ 
			nVatVal		:= 		nVatVal + ((cAliasTMP)->NNT_QUANT)*((cAliasTMP)->D2_CUSTO1 )
	        nQuaVal     :=      nQuaVal + (cAliasTMP)->NNT_QUANT
				
			B1_DESC     :=  (cAliasTMP)->B1_DESC
			B2_PROD		:=  (cAliasTMP)->NNT_PROD 
			B3_DESCRI   :=  (cAliasTMP)->AH_UNIMED
	        B4_CODOKEY  :=  (cAliasTMP)->AH_CODOKEI  
	        B5_QUANT    :=  (cAliasTMP)->NNT_QUANT    
	        C5_QUANT    :=  nQuaVal    
	        B6_CUSTO1   :=  (cAliasTMP)->D2_CUSTO1  
	        B7_SUMMA    := ((cAliasTMP)->NNT_QUANT)*((cAliasTMP)->D2_CUSTO1 )
			B8_TOTAL	:= nVatVal
				
			A1_NOMA := ALLTRIM(aheader[1])
			A2_DATA := Substr(aheader[2],7,2)+ '.' + Substr(aheader[2],5,2)+ '.' + Substr(aheader[2],1,4)	
	        A3_OFil	:=  ALLTRIM(aheader[3])
	        A4_PFIL :=  ALLTRIM(aheader[4])
			A7_NAME			:= ALLTRIM(aComData[1][5][2])
	        A8_OKPO			:= ALLTRIM(aComData[1][12][2])
	        A9_AGANM        := cA9vidD
	        A10_AGANM       := cA10vidD
	
			C11_STCMAN    := alltrim(cOstcman)
	 		C13_STCMAN    := alltrim(cPstcman)
	        C10_ROLE        := alltrim(cOrole)
	        C11_ROLE        := alltrim(cProle)
	        C14_TOTVAL      := ALLTRIM(RU99X01(nVatVal,.T.,'1'))
	        C14_TOTVA2      := ALLTRIM(RU99X01(Decimal(nVatVal),.T.,'1'))
	
	        MsUnlock()
	        (cAliasTMP)->(dbSkip())
	ENDDO
	        (cAliasTMP)->(dbCloseArea())
	        RestArea(aArea)
	return .T. 

//================================================================
static function GetApart(cAliasTM2,cNNSIni,cNNSFil) 
//================================================================
//function gets data for header
//Accepts alias and data about vilial and document
//returns an array
//----------------------------------------------------------------
Local aHeader as array
Local aAreaTMPTAB AS ARRAY
local cQuery2 as character

	aAreaTMPTAB := {}
	cAliasTM2   := GetNextAlias()
	cQuery2 := " "
	cQuery2 := "  SELECT NNT_COD, NNT_DTVALI, NNT_FILORI, NNT_FILDES, * FROM " + RetSqlName("NNT") + " NNT " 
	cQuery2 += " WHERE NNT.NNT_COD = '" + cNNSIni + "' "   
	cQuery2 += " AND NNT.NNT_FILIAL = '" + cNNSFil + "' "   
	cQuery2 += " AND NNT.D_E_L_E_T_ = '' "
	
	aArea := getArea()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasTM2,.T.,.T.)
	DbSelectArea(cAliasTM2)
	(cAliasTM2)->(DbGoTop())
	aAreaTMPTAB := (cAliasTM2)->(GetArea())
	aHeader = {}
	
	aadd(aheader, alltrim((cAliasTM2)->NNT_COD ))
	aadd(aheader, alltrim((cAliasTM2)->NNT_DTVALI ))
	aadd(aheader, alltrim((cAliasTM2)->NNT_FILORI ))
	aadd(aheader, alltrim((cAliasTM2)->NNT_FILDES ))
	
	MsUnlock()
	(cAliasTM2)->(dbSkip())
	RestArea(aAreaTMPTAB)  
	 
return aHeader 






//================================================================
static function getHerr(cSomeOne,cNNSIni,cNNSFil)
//================================================================
//The function receives information about the signer, who has the right to sign this type of document on the current date.
//Returns an array (name / role)
//At the input receives the number of the signer from the parameter and from the variables branch and document number
//----------------------------------------------------------------
Local cAliasTM2 as char
Local cQuery as char
local CDATESRA, CDATESRA2 as char
local cRole := ''
local aSomeone := {}
	
	cQuery := " "
	cQuery := "SELECT F42_NAME, F42_AUTOM,*  "
	cQuery += " FROM  " + RetSqlName("F42") + " F42"
	cQuery += " LEFT JOIN " + RetSqlName("SRA") + " SRA"
	cQuery += " ON F42.F42_EMPL = SRA.RA_MAT "
	cQuery += " LEFT JOIN " + RetSqlName("SQ3") + " SQ3"
	cQuery += " ON RTRIM(F42.F42_CARGO) =       SQ3.Q3_CARGO"
	cQuery += " WHERE SRA.RA_MAT = '" + cSomeOne + "'"
	cQuery += " AND F42.F42_EMPL = '" + cSomeOne + "'" 
	cQuery += " AND (F42.F42_REPORT='TORG13' OR F42.F42_REPORT='ALL')"
	cQuery +=  " AND  '" + DTOS(dDatabase) +  "' BETWEEN to_date(F42.F42_DFROM, 'YYYYMMDD') AND to_date(F42.F42_DATETO , 'YYYYMMDD') "
	cQuery += " AND F42.D_E_L_E_T_=' '"
	cAliasTM2   := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTM2,.T.,.T.)
	DbSelectArea(cAliasTM2)
	(cAliasTM2)->(DbGoTop())
	CDATESRA := (cAliasTM2)->RA_NASC
	CDATESRA2 := (cAliasTM2)->RA_ADMISSA

	IF alltrim((cAliasTM2)->F42_NAME)= ''
		cSomeOne    := ''
	ELSE
		cQ3descsu   := alltrim((cAliasTM2)->Q3_DESCSUM)
		cRanome     := alltrim((cAliasTM2)->F42_NAME)
//Signer’s name, surname and initials
		cSomeOne    := alltrim(substr(alltrim(cRanome),1,(at(' ',alltrim(cRanome),1))))
		cSomeOne    := alltrim(cSomeOne) + (' ') + alltrim(substr(alltrim(cRanome),(at(' ',alltrim(cRanome),1)),2))
		cSomeOne    := alltrim(alltrim(cSomeOne) + alltrim('.') + alltrim(substr(alltrim(cRanome),(at(' ',alltrim(cRanome),len(cSomeOne))),2))) 
	ENDIF
	cRole := alltrim((cAliasTM2)->F42_DSCCRG)

	aadd(aSomeone,cSomeOne)
	aadd(aSomeone,cRole)
	
	(cAliasTM2)->(dbCloseArea())
	
return aSomeOne


//RUSSIA R7



