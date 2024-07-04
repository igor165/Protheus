#include "protheus.ch"
#include "Birtdataset.ch"
#include "RU34R05.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} RU34R05
Report on changes of the capital.

@author Andrey Filatov
@since  28/02/2017
@version 1.0
/*/
//--------------------------------------------------------------------

dataset RU34R05DS
Title STR0001
Description STR0001

Columns
// Creating columns
define Column a_year TYPE NUMERIC SIZE 4 DECIMALS 0 LABEL 'Year'
define Column a_month TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Month'
define Column a_day TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Day'
define Column CO_NAME TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Full name'
define Column CO_OKPO TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKPO'
::setColumn( "CO_TIN", "C", TamSX3("A1_CGC")[1], 0 )
::setLabel( "CO_TIN", 'Company TIN' )
define Column CO_OKVED TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKVED'
define Column CO_OKOPF TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKOPF'
define Column CO_OKFS TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKFS'
define Column CO_MDIVID TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_MDIVID'
define Column CO_MDESC TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_MDESC'
define Column CO_RUBL TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_RUBL'

define Column ACC_DESC TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Acc. Description'
define Column ACC_DESC2 TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Acc. Description2'
define Column CODE TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'Acc. Code'
define Column VALUE TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL  'Value'
define Column VALUE2 TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'Value2'
define Column VALUE3 TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'Value3'
define Column VALUE4 TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'Value4'
define Column VALUE5 TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'Value5'
define Column VALUE6 TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'Value6'
define Column CURR_BAL TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance'
define Column PREV_BAL TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Privious balance'
define Column PREV_BALT TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'PREV_BALT'
define Column ORDEM TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL 'ORDEM'
define Column SIGNER TYPE CHARACTER SIZE 30 DECIMALS 2 LABEL 'SIGNER'

Parameters
define Parameter DDATASIGA TYPE CHAR SIZE 10 LABEL STR0007 DEFAULT VALUE "/"

// Creating query
define query 	"SELECT * FROM %WTable:1% WHERE %NotDel% ORDER BY ORDEM"

process dataset
Local cWTabAlias as character
Local aArea as array
Local lRet as logical
Local cExp as character

aArea	:= GetArea()
lRet 	:= .f.
cExp 	:= ""

// Crating worktable
cWTabAlias := ::createWorkTable()

// Calling the main function RU34R05TR
lRet := Processa({|| RU34R05TR(cWTabAlias)}, STR0002, STR0003, .F.)

RestArea(aArea)

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} RU34R05TR
Function that fills the dataset.
	
	@author Andrey Filatov
	@since  28/02/2017
	@version 1.0
	/*/
	//--------------------------------------------------------------------
	
Main Function RU34R05TR(cAliasDS)
Local aSetOfBook as array
Local nDivide as numeric
Local aAreaCTG as array
Local cCodeGroup as character
Local cDisc as character
Local dEndDate as date
Local nSize  as numeric
Local nDecs  as numeric
Local cPicture as character
Local cTpValor as character
Local cGroup as character
Local lDescCont as logical
Local cRubVal  as character
Local cDivisor as character
Local aCtbMoeda as array
Local cDescMoeda as character
Local cUpper  as character
Local cCODE1 as char
Local cCODE2 as char
Local cCurrBal2 as char
Local cCurrBal3 as char
Local n as numeric
Local lInclu as logical
Local cCodeP as char
Local cCurr_m as char
Local nColumn as numeric
Local dDtFinPre as date
Local dDtIniAct as date
Local dDtIniPre as date
Local dRepDate as date

Local cRelTrb as char
Local aStruTmp as array
Local oArqTmp as object
Local nF as numeric
Local nI as numeric
Local aSingers as array
local a3200 as array
Local a3300 as array
local nConta as numeric

local nCurr_m as numeric
local nCurr_b as numeric
local nPrev_m as numeric
local nPrev_b as numeric
local nPprev_b as numeric

Private nLastKey as numeric
Private cPerg  as character
Private cProgName as character
Private dFinal  as date
Private aSelFil as array
Private lComNivel as logical

aSingers := {}
aadd (aSingers, GetSigners(MV_PAR11)) 	//Leader

a3200 := {0,0,0,0,0,0}
a3300 := {0,0,0,0,0,0}

dFinal := dDataBase
lInclu := .T.
aSetOfBook	:= CTBSetOf("")
nDivide	:=	1
aAreaCTG := CTG->(GetArea())
//dFinal := dDataBase
dEndDate := dDataBase
nSize := 0
nDecs := 0
cPicture := ""
cTpValor := ""
cGroup := ""
cRubVal := "384"
cPerg	 	:= "RU34R05"
cProgName 	:= "RU34R05"
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
cDescMoeda := AllTrim(aCtbMoeda[3])
cUpper := ""
nLastKey := 0
aSelFil :=	{}
lComNivel := .T.
nColumn := 0

ProcRegua(0)
IncProc()

// If user needs to select the branchs.
If mv_par06 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf

// Fills last date.
aSetOfBook[3] := 0
aSetOfBook[4] := "@E 999 999 999"
aSetOfBook[5] := MV_PAR02
If Empty(mv_par04)
	CTG->(dbSetOrder(1))
	If CTG->(dbSeek(xFilial("CTG")+mv_par01))
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		Help(" ",1,"NOEXISCALE")
		RestArea(aAreaCTG)
		Return
	EndIf
Else
	dFinal:= mv_par04
EndIf

dRepDate:= Stod(Str(Year(dFinal)-2,4)+'1231')

aSetOfBook      := CTBSetOf("")
aSetOfBook[3] 	:= 0
aSetOfBook[4]	:= "@E 999 999 999"
aSetOfBook[5] 	:= MV_PAR02
nSize           := TAMSX3("CT2_VALOR")[1]
nDecs           := DecimalCTB(aSetOfBook,mv_par03)
cPicture        := aSetOfBook[4]
cTpValor        := "P" //GetMV("MV_TPVALOR")

// If user wants to divide the result.
If mv_par07==2
	nDivide:=1000
	cRubVal := "384"
	cDivisor := STR0004
ElseIf mv_par07==3
	nDivide:=1000000
	cRubVal := "385"
	cDivisor := STR0005
EndIf

dDtIniPre		:= Stod(Str(Year(dFinal)-1,4)+'0101')
dDtFinPre		:= Stod(Str(Year(dFinal)-1,4)+'1231')
dDtIniAct		:= Stod(Str(Year(dFinal),4)+'0101')

//--------------------------------------------------------------------------------
// Create Year -1 cArqTmp -> CtGerPlan
//--------------------------------------------------------------------------------
RU34R05Det(dDtIniPre,dDtFinPre)

//--------------------------------------------------------------------------------
// Create temporary table cRelTrb
//--------------------------------------------------------------------------------
If oArqTmp<> Nil
	oArqTmp:Delete()
	oArqTmp := Nil
Endif

aStruTmp := cArqTmp->(DBSTRUCT())
nF := Len(aStruTmp)

cRelTrb := GetNextAlias()

oArqTmp := FWTemporaryTable():New( cRelTrb )  
oArqTmp:SetFields(aStruTmp) 

oArqTmp:Create()

cArqTmp->(DbGoTop())
Do While !cArqTmp->(EOF())
	(cRelTrb)->(DbAppend())

	For nI := 1 To nF
		If (cRelTrb)->(FieldPos(aStruTmp[nI,1])) > 0	 .And. aStruTmp[nI,2] <> 'M'
			(cRelTrb)->(FieldPut(FieldPos(aStruTmp[nI,1]),cArqTmp->(FieldGet(cArqTmp->(FieldPos(aStruTmp[nI,1]))))))
		Endif
	Next nI

	cArqTmp->(DbSkip())
Enddo
cArqTmp->(DbCloseArea())
(cRelTrb)->(DbGoTop())

//--------------------------------------------------------------------------------
// Create Current Year cArqTmp -> CtGerPlan
//--------------------------------------------------------------------------------
RU34R05Det(dDtIniAct,dFinal)

//--------------------------------------------------------------------------------
// Process report data
//--------------------------------------------------------------------------------
cPrevClass := ''
cCodeGroup	:=""
cSpace		:=" "
cDisc		:=""

dbSelectArea("cArqTmp")
lDescCont	:=	FieldPos('DESCCONT') >0

ProcRegua(cArqTmp->(RecCount()))
cArqTmp->(DbGoTop())

While !cArqTmp->(Eof())
	IncProc()
	//This is for group when dont have CODE COUNT
	While  "/" $ Trim(cArqTMP->CONTA)
		If "/" $ Trim(cArqTMP->CONTA)
			If lDescCont .And. !Empty(cArqTMP->DESCCONT)
				cCodeGroup	:=	cCodeGroup + IIf(Empty(cCodeGroup),AllTrim(cArqTMP->DESCCONT), CRLF + cSpace+ Space(2)+ AllTrim(cArqTMP->DESCCONT))
			Else
				cCodeGroup	:=	cCodeGroup + IIf(Empty(cCodeGroup), AllTrim(cArqTMP->DESCCTA), CRLF  +  AllTrim(cArqTMP->DESCCTA))
			EndIf

			dbSelectArea("cArqTmp")
			cArqTmp->(DbSkip())
			(cRelTrb)->(DbSkip())
		EndIf
		cSpace:=cSpace+Space(1)
	Enddo

	If (cArqTMP->TIPOCONTA == '1' .And. cArqTMP->SUPERIOR = ' ')
		cSpace := Space(1)
	EndIf
	If (cArqTMP->TIPOCONTA == '2' .And. cArqTMP->SUPERIOR = ' ') 
		cSpace := Space(2)
	EndIf
	cPrevClass := cArqTMP->TIPOCONTA
	If AllTrim(SubStr((cArqTMP->CONTA),1,4)) $ "3100|3210|3220|3230|3240|3200|3310|3320|3330|3340|3300|3600"
		cUpper := 'U'
	Else
		cUpper :=''
	EndIf
	lInclu := .T.
	//for division into column

	If cCodeP == AllTrim(SubStr((cArqTMP->CONTA),1,4))
		lInclu := .F.
	EndIf
	Reclock(cAliasDS,lInclu)

	cCodeEmp := AllTrim(SubStr((cArqTMP->CONTA),5,6))
	// If its a 0, needs to change to -.
	// If its a negativa value, needs to change the signal and the value must be between parentesis.

	nColumn := cArqTMP->COLUNA

	nCurr_m:= Round(cArqTMP->MOVIMENTO/nDivide,nDecs)
	nCurr_b:= Round(cArqTMP->SALDOATU/nDivide,nDecs)
	nPrev_m:= Round((cRelTrb)->MOVIMENTO/nDivide,nDecs)
	nPrev_b:= Round((cRelTrb)->SALDOATU/nDivide,nDecs)
	nPprev_b:= Round((cRelTrb)->SALDOANT/nDivide,nDecs)

	cCurr_m:= RemDCSig(ValorCTB(nCurr_m,,,nSize,nDecs,.T., cPicture,cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,"1",,.F.,.F.))
	Iif (SubStr(Alltrim(cCurr_m),1,1) =="-",cCurr_m	:=	"("+ SubStr(Alltrim(cCurr_m),2)+")",cCurr_m)
	Iif(Round(cArqTMP->MOVIMENTO/nDivide,0) == 0,cCurr_m	:=	"-",cCurr_m)
	
	cPrev_m:= RemDCSig(ValorCTB(nPrev_m,,,nSize,nDecs,.T., cPicture,(cRelTrb)->NORMAL, (cRelTrb)->CONTA,,,cTpValor,"1",,.F.,.F.))
	Iif (SubStr(Alltrim(cPrev_m),1,1) =="-",cPrev_m	:=	"("+ SubStr(Alltrim(cPrev_m),2)+")",cPrev_m)
	Iif(Round((cRelTrb)->MOVIMENTO/nDivide,0) == 0,cPrev_m	:=	"-",cPrev_m)

	cPprev_b:= RemDCSig(ValorCTB(nPprev_b,,,nSize,nDecs,.T., cPicture,(cRelTrb)->NORMAL, (cRelTrb)->CONTA,,,cTpValor,"1",,.F.,.F.))
	Iif (SubStr(Alltrim(cPprev_b),1,1) =="-",cPprev_b	:=	"("+ SubStr(Alltrim(cPprev_b),2)+")",cPprev_b)
	Iif(Round((cRelTrb)->SALDOANT/nDivide,0) == 0,cPprev_b	:=	"-",cPprev_b)

	nConta := Val(AllTrim(SubStr((cArqTMP->CONTA),1,4)))
 
	cValue :='-'
	If '*'$ cCodeEmp
		cValue:='X'
	ElseIf	nConta == 3100 // SALDOANT  cRelTrb 18 (cRelTrb=18-19)
		cValue:=cPprev_b
		dRepDate:= Stod(Str(Year(dFinal)-2,4)+'1231')
		a3200[nColumn] := a3200[nColumn] + nPprev_b
	ElseIf nConta > 3200 .And. nConta<3300 // MOVIMENTO
		cValue:=cPrev_m
		dRepDate++
		if nConta == 3210 .or. nConta == 3220 .or. nConta==3230 .or. nConta=3240
			a3200[nColumn] := a3200[nColumn] + nPrev_m
		endif
	ElseIf nConta==3200 // SALDOATU  cArqTMP 19 () cPrev_b

		cPrev_b:= RemDCSig(ValorCTB(a3200[nColumn],,,nSize,nDecs,.T., cPicture,cArqTMP->NORMAL, cArqTMP->CONTA,,,cTpValor,"1",,.F.,.F.))
		Iif (SubStr(Alltrim(cPrev_b),1,1) =="-",cPrev_b	:=	"("+ SubStr(Alltrim(cPrev_b),2)+")",cPrev_b)
		Iif(Round((cRelTrb)->SALDOATU/nDivide,0) == 0,cPrev_b	:=	"-",cPrev_b)

		cValue := cPrev_b
		dRepDate:= Stod(Str(Year(dFinal)-1,4)+'1231')
		a3300[nColumn] := a3300[nColumn] + a3200[nColumn] 
	ElseIf nConta > 3300 .And. nConta<3400 // MOVIMENTO
		cValue:=cCurr_m
		dRepDate:=dFinal
		if nConta == 3310 .or. nConta == 3320 .or. nConta==3330 .or. nConta=3340
			a3300[nColumn] := a3300[nColumn] + nCurr_m
		endif
	ElseIf nConta == 3300 // SALDOATU   cArqTmp 20 cCurr_b

		cCurr_b:= RemDCSig(ValorCTB(a3300[nColumn],,,nSize,nDecs,.T., cPicture,cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,"1",,.F.,.F.))
		Iif (SubStr(Alltrim(cCurr_b),1,1) =="-",cCurr_b	:=	"("+ SubStr(Alltrim(cCurr_b),2)+")",cCurr_b)
		Iif(Round(cArqTMP->SALDOATU/nDivide,0) == 0,cCurr_b	:=	"-",cCurr_b)

		cValue:=cCurr_b
		dRepDate:=dFinal
	ElseIf nConta >= 3400 .And. nConta<3600
		If  nColumn ==1
			cValue:= cPprev_b
		ElseIf nColumn ==4
			cValue:= cPrev_b
		Else
			cValue:= cPrev_m
		EndIf
	ElseIf nConta==3600
		If  nColumn ==1
			cValue:= cCurr_b
		ElseIf nColumn ==2
			cValue:= cPrev_b
		Else
			cValue:= cPprev_b
		EndIf
	EndIf

	If nColumn <2
		cCodeP 		:= AllTrim(SubStr((cArqTMP->CONTA),1,4))
		cRepDate 	:= AllTrim(Str(Year(dRepDate)))

		(cAliasDS)->a_year 		:= Year(dFinal)
		(cAliasDS)->a_month		:= Month(dFinal)
		(cAliasDS)->a_day 		:= Day(dFinal)
		(cAliasDS)->CO_OKOPF	:= RU99CAdr("CO_OKOPF")
		(cAliasDS)->CO_OKFS		:= RU99CAdr("CO_OKFS")
		(cAliasDS)->CO_OKPO		:= RU99CAdr("CO_OKPO")
		(cAliasDS)->CO_OKVED	:= RU99CAdr("CO_OKVED")
		(cAliasDS)->CO_NAME		:= RU99CAdr("CO_NAME")
		(cAliasDS)->CO_TIN		:= RU99CAdr("CO_TIN")
		(cAliasDS)->CO_RUBL		:= cRubVal
		(cAliasDS)->CO_MDIVID	:= cDivisor
		(cAliasDS)->CO_MDESC	:= cDescMoeda
		(cAliasDS)->CODE 		:= AllTrim(SubStr((cArqTMP->CONTA),1,4))
		(cAliasDS)->ACC_DESC2 	:= ""
		(cAliasDS)->SIGNER		:= AllTrim(aSingers[1][2])

		If Empty(cUpper)
			(cAliasDS)->ACC_DESC    :=   cSpace+Space(1)+ Lower(cArqTMP->DESCCONT)
		Else
			If "_" $ Trim(cArqTMP->DESCCONT)
				(cAliasDS)->ACC_DESC    := (Upper(SubStr(cArqTMP->DESCCONT, 1, 1)) + Lower(SubStr(cArqTMP->DESCCONT, 2,31))+ cRepDate + Lower(SubStr(cArqTMP->DESCCONT, 37,2)))
			Else
				(cAliasDS)->ACC_DESC    := (Upper(SubStr(cArqTMP->DESCCONT, 1, 1)) + Lower(SubStr(cArqTMP->DESCCONT, 2))) + CRLF
			EndIf
			cSpace := ' '
		EndIf

		If !Empty(cCodeGroup)
			If ":" $ Trim(cCodeGroup)

				(cAliasDS)->ACC_DESC:=  cSpace+ Lower(cCodeGroup) + CRLF+ Space(3)+ (cAliasDS)->ACC_DESC
				cSpace := cSpace+ ' '
			Else
				If "_" $ Trim(cCodeGroup)
					(cAliasDS)->ACC_DESC    := "  "+ (Upper(SubStr(cCodeGroup, 1, 1)) + Lower(SubStr(cCodeGroup, 2,2))+ cRepDate + Lower(SubStr(cCodeGroup, 8,2)))+ CRLF +" "+ CRLF + (cAliasDS)->ACC_DESC
					dRepDate++
				Else
					(cAliasDS)->ACC_DESC    := (Upper(SubStr(cCodeGroup, 1, 1)) + Lower(SubStr(cCodeGroup, 2))) + CRLF+ Space(1)+ (cAliasDS)->ACC_DESC
				EndIf
			EndIf

		EndIf

		If nColumn ==1
			cCodeGroup 	:= ""
		Endif
		(cAliasDS)->PREV_BAL 	:= cArqTMP->SALDOANT/nDivide
		(cAliasDS)->PREV_BALT 	:= 	cPprev_b
		(cAliasDS)->CURR_BAL	:= 	cArqTMP->SALDOATU/nDivide
		(cAliasDS)->ORDEM		:=	cArqTMP->ORDEM

		(cAliasDS)->VALUE := cValue
	Else
		If nColumn ==2
			(cAliasDS)->VALUE2 := cValue
		ElseIf nColumn ==3
				(cAliasDS)->VALUE3 := cValue
		ElseIf nColumn ==4	
				(cAliasDS)->VALUE4 := cValue
		ElseIf nColumn ==5
				(cAliasDS)->VALUE5 := cValue
		ElseIf nColumn ==6
				(cAliasDS)->VALUE6 := cValue
		EndIf
	EndIf

	(cAliasDS)->( msunlock() )
	
	dbSelectArea("cArqTmp")
	cArqTmp->(DbSkip())
	(cRelTrb)->(DbSkip())
EndDo

dbSelectArea("cArqTmp")
cArqTmp->(DbCloseArea())

If oArqTmp<> Nil
	oArqTmp:Delete()
	oArqTmp := Nil
Endif

RestArea(aAreaCTG)

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} RU34R05Det
Function that calls CTGerPlan to create the temporary table cArqTmp.
	
	@author National Platform
	@since  16/12/2016
	@version 1.0
	/*/
	//--------------------------------------------------------------------
	
Function RU34R05Det(dBegin, dEnd)
Local aSetOfBook as array
Local aCtbMoeda as array
Local cArqTmp as character
Local cTrbRel as character
Local cMoedaDesc as character
Local lEnd as logical
	
aSetOfBook		:= CTBSetOf("")
aCtbMoeda 		:= {}
cMoedaDesc		:= mv_par03
aSetOfBook[3] 	:= 0
aSetOfBook[4] 	:= "@E 999 999 999"
aSetOfBook[5] 	:= MV_PAR02
aCtbMoeda 		:= CtbMoeda(mv_par03, aSetOfBook[9])

If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
	Return .F.
EndIf

IncProc(STR0006)
// Function that creates the temporary table cArqTmp.
CTGerPlan(	NIL, NIL, NIL, @lEnd, @cArqTmp,;
	dBegin, dEnd, "", " ", "", Repl("Z", Len(CT1->CT1_CONTA)),;
	"", Repl("Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM)),;
	"", Repl("Z", Len(CTH->CTH_CLVL)), mv_par03,;
	mv_par05, aSetOfBook, Space(2), Space(20), Repl("Z", 20), Space(30);
		, , , ,  ,  , , , , , , , , , , , , , , , , , , , , , , , , , , , , cMoedaDesc,.T., aSelFil, ,.T.)
	
Return


//--------------------------------------------------------------------
/*/{Protheus.doc} RemDCSig
	Remove D/C signal from ValorCTB return in RedStorno
	
	@author National Platform
	@since  04/08/2017
	@version 1.0
	/*/
//--------------------------------------------------------------------
	
Static Function RemDCSig(cVal as Char)

cVal := Alltrim( Strtran(Strtran(cVal,"D",""),"C","") )

Return cVal


static function GetSigners(cMvparN)
	Local aSingers as array
	Local cDESCSU as Char
	Local cRNome as Char
	Local cRANome as Char
	Local cAliasTM as Char
	Local cQuery as Char
	Local cTab as Char
	Local cAddrKey as Char
	local cMvparN as Char

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
		cQuery += "AND F42.F42_EMPL = '" + cMvparN + "' " 
		cQuery += "AND F42.F42_REPORT IN('TORG-1','ALL') "
		cQuery += "AND F42.D_E_L_E_T_=' ' "
		cQuery += "AND SRA.D_E_L_E_T_=' ' "
		cQuery += "AND SQ3.D_E_L_E_T_=' ' "

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


//updated for automaticaly patch 07.08.19

// Russia_R5
