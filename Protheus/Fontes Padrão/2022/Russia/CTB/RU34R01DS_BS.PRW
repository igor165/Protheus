#include "protheus.ch"
#include "Birtdataset.ch"
#include 'RU34R01.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} RUS510DS
Balance Sheet DataSet.


@author National Platform
@since  13/10/2016
@version 1.0
/*/
//--------------------------------------------------------------------

dataset RUS500ds
Title STR0001
Description STR0001

Columns
// Creating columns
define Column a_year TYPE NUMERIC SIZE 4 DECIMALS 0 LABEL 'Year'
define Column a_month TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Month'
define Column a_day TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Day'
define Column CO_KPP TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'KPP'
define Column CO_ADDRESS TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Actual addr.'
define Column CO_NAME TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Full name'
define Column CO_OKOPF TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKOPF'
define Column CO_OKFS TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKFS'
define Column CO_OKVED TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKVED'
define Column CO_OKPO TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKPO'

::setColumn( "CO_TIN", "C",TamSX3("A1_CGC")[1], 0 )
::setLabel( "CO_TIN", 'Company TIN' )

define Column TYPE_ACC TYPE NUMERIC SIZE 1 DECIMALS 0 LABEL 'Type of line'
define Column ACC_DESC TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Acc. Description'
define Column ACC_DESC2 TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Acc. Description'
define Column CODE TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'Acc. Code'
define Column PARENT TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'PARENT'
define Column CONDITION TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'CONDITION'
define Column CURR_BAL TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance'
define Column CURR_BALD TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance debit'
define Column CURR_BALC TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance credit'
define Column PREV_BAL TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Previous balance'
define Column PREV_BALD TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance debit'
define Column PREV_BALC TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance credit'
define Column PREV_BAL2 TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance 1'
define Column PREV_BAL2D	TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance debit 1'
define Column PREV_BAL2C	TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance credit 1'
define Column TIPEACC TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'TIPOCONTA'
define Column IDENTIFI TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'IDENTIFI'
define Column MAINRECORD	TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'TOTVIS'
define Column ORDEM TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL 'ORDEM'
define Column COLUMN1 TYPE NUMERIC SIZE 1 DECIMALS 0 LABEL 'COLUNA'
define Column SALDOSEM TYPE NUMERIC SIZE 17 DECIMALS 2 LABEL 'SALDOSEM'
define Column LEVEL1 TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'NIVEL'
define Column ENT_BAL TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'SLDENT'
define Column PREV_BALT TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL 'PREV_BALT'
define Column PR_BALANCE	TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'PR_BALANCE'
define Column PREV_BAL2T	TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'PREV_BAL2T'
define Column CURR_BALT TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CURR_BALT'
define Column CO_RUBL TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_RUBL'
define Column CO_MDESC TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_MDESC'
define Column CO_MDIVID TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_MDIVID'

define Column SIGNER TYPE CHARACTER SIZE 30 DECIMALS 2 LABEL 'SIGNER'

Parameters
define Parameter DDATASIGA TYPE CHAR SIZE 10 LABEL STR0009  DEFAULT VALUE "/"

// Creating query
define query "SELECT * FROM %WTable:1% WHERE %NotDel% ORDER BY ORDEM"

process dataset
Local cWTabAlias as character
Local lRet as logical
Local aArea as array
lRet := .f.
aArea :=	GetArea()
// Crating worktable
cWTabAlias := ::createWorkTable()

// Calling the main Function RUSR500tr
lRet := Processa({|| RUSR500tr(cWTabAlias)}, STR0002, STR0003, .F.)

RestArea(aArea)

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} RUSR500tr
Function that fills the dataset.
	
	@author National Platform
	@since  13/10/2016
	@version 1.0
	/*/
	//--------------------------------------------------------------------
	
Main Function RUSR500tr(cAliasDS)
	Local aSetOfBook as array
	Local nDivide as numeric
	Local aAreaCTG  as array
	Local lEnd as logical
	Local cArqTmp as character
	Local aCtbMoeda as array
	Local cDescMoeda  as character
	Local lSaldoZer  as logical
	Local dFinalA1 as date
	Local dFinalA2 as date
	Local dFinal as date
	Local cCodeGroup as character
	Local nSize as numeric
	Local lDescCont as logical
	Local cRubVal as character
	Local cDivisor as character
	Local aSingers as array
	
	Private nLastKey as numeric
	Private cPerg as character
	Private cProgName as character
	Private aSelFil as array
	Private lComNivel as logical
	
	aSingers := {}
	aadd (aSingers, GetSigners(MV_PAR11)) 	//Leader
	
	aSetOfBook	:= CTBSetOf("")
	nDivide		:= 1
	aAreaCTG 	:= CTG->(GetArea())
	aCtbMoeda 	:= CtbMoeda(mv_par03, aSetOfBook[9])
	cDescMoeda 	:= AllTrim(aCtbMoeda[3])
	lSaldoZer 	:= (MV_PAR04 == 1)
	dFinalA1 	:= dDataBase
	dFinalA2 	:= dDataBase
	dFinal 		:= dDataBase
	nSize 		:= 0
	cRubVal 	:= "384"
	nLastKey 	:= 0
	cPerg	 	:= "RU34R01"
	cProgName 	:= "RUSR500"
	lComNivel	:= .T.
	aSelFil	:=	{}
	
	aSetOfBook[3] := 0
	aSetOfBook[4] := "@E 999 999 999" //  CTN_PICTV
	aSetOfBook[5] := MV_PAR02
	// Needs to start the progress bar.
	ProcRegua(0)
	IncProc()
	
	// If user needs to select the branchs.
	If mv_par07 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
	EndIf
	
	
	If Empty(MV_PAR05)
		CTG->(dbSetOrder(1))
		If CTG->(dbSeek(xFilial("CTG")+mv_par01))
			While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
				dFinal	:= CTG->CTG_DTFIM
				CTG->(DbSkip())
			EndDo
		Else
			Help(" ",1,"NOEXISCALE")
			Return
		EndIf
	Else
		dFinal:= MV_PAR05
	EndIf
	dFinalA1 :=	Stod(Str(Year(dFinal)-1,4)+"1231")
	dFinalA2 :=	Stod(Str(Year(dFinal)-2,4)+"1231")
	nSize 	 := TAMSX3("CT2_VALOR")[1]
	nDecs 	 := DecimalCTB(aSetOfBook,mv_par03)
	cPicture := aSetOfBook[4]
	cTpValor := GetMV("MV_TPVALOR")
	aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
	
	// If user wants to divide the result.
	If MV_PAR08 == 2
		nDivide := 1000
		cRubVal := "384"
		cDivisor := STR0004
	ElseIf MV_PAR08 == 3
		nDivide := 1000000
		cRubVal := "385"
		cDivisor := STR0005
	EndIf
	
	// Calls the Function to create the temporary table cArqTmp.
	Rus500Det(dFinal,dFinalA1)
	
	//TODO Finds the informations about the branch.
	/*dbselectarea("SZD")
	SZD->(DbSetOrder(1))
	SZD->(DbSeek(xFilial()+cEmpAnt))
	
	dbSelectArea("SZE")
	SZE->(DbSetOrder(1))
	SZE->(DbSeek(xFilial()+cEmpAnt+ PadR(cFilAnt,Len(xFilial()))),.T.)*/
	// Fills the dataset.
	cTpValor	:= "P"
	cCodeGroup 	:= ""
	DbSelectArea("cArqTmp")
	lDescCont	:=	FieldPos('DESCCONT') >0
	ProcRegua(cArqTmp->(RecCount()))
	DbGoTop()
	While !Eof()
		IncProc(STR0006)
		
		//This is for group when dont have CODE COUNT
		If "/" $ Trim(cArqTMP->CONTA)
			
			If lDescCont .And. !Empty(cArqTMP->DESCCONT)
				cCodeGroup	:=	cCodeGroup + IIF(Empty(cCodeGroup),AllTrim(cArqTMP->DESCCONT), CRLF + AllTrim(cArqTMP->DESCCONT))
			Else
				cCodeGroup	:=	cCodeGroup + IIF(Empty(cCodeGroup), AllTrim(cArqTMP->DESCCTA), CRLF  +  AllTrim(cArqTMP->DESCCTA))
			EndIf
			
			dbSelectArea("cArqTmp")
			DbSkip()
			Loop
		EndIf
		
		dbSelectArea(cAliasDS)
		Reclock(cAliasDS,.T.)
		
		(cAliasDS)->a_year 		:= 	year(dFinal)
		(cAliasDS)->a_month		:=	month(dFinal)
		(cAliasDS)->a_day 		:= 	day(dFinal)
		(cAliasDS)->CO_OKOPF    := RU99CAdr("CO_OKOPF")
		(cAliasDS)->CO_OKFS     := RU99CAdr("CO_OKFS")
		(cAliasDS)->CO_OKPO     := RU99CAdr("CO_OKPO")
		(cAliasDS)->CO_OKVED    := RU99CAdr("CO_OKVED")
		(cAliasDS)->CO_NAME     := RU99CAdr("CO_NAME")
		(cAliasDS)->CO_TIN      := RU99CAdr("CO_TIN")
		(cAliasDS)->CO_KPP      := RU99CAdr("CO_KPP")
		(cAliasDS)->CO_ADDRESS  := RU99CAdr("CO_ADDRESS")
		(cAliasDS)->SIGNER		:= AllTrim(aSingers[1][2])
		
		(cAliasDS)->CO_RUBL		:= cRubVal
		(cAliasDS)->CO_MDIVID	:= cDivisor
		(cAliasDS)->CO_MDESC	:= cDescMoeda
		(cAliasDS)->CODE 		:= 	AllTrim(cArqTMP->CONTA)
		
		(cAliasDS)->PARENT 		:= 	cArqTMP->SUPERIOR
		(cAliasDS)->CONDITION 	:= 	cArqTMP->NORMAL
		
		(cAliasDS)->ACC_DESC2 	:= ""
		If lDescCont .And. !Empty(cArqTMP->DESCCONT)
			(cAliasDS)->ACC_DESC	:=	cArqTMP->DESCCONT
		Else
			(cAliasDS)->ACC_DESC	:=	cArqTMP->DESCCTA
		EndIf
		If !Empty(cCodeGroup)
			(cAliasDS)->ACC_DESC2	:=	cCodeGroup + CRLF + CRLF
		EndIf
		cCodeGroup 	:= ""
		(cAliasDS)->PREV_BAL 	:= 	cArqTMP->SALDOANT/nDivide
		(cAliasDS)->PREV_BALT	:= 	RemDCSig(ValorCTB(Round(cArqTMP->SALDOANT/nDivide,nDecs),,,nSize,nDecs,.T., cPicture,cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,"1",,.F.,.F.))
		(cAliasDS)->PREV_BALD	:=	cArqTMP->SALDOANTDB/nDivide
		(cAliasDS)->PREV_BALC	:=	cArqTMP->SALDOANTCR/nDivide
		(cAliasDS)->CURR_BAL	:= 	cArqTMP->SALDOATU/nDivide
		(cAliasDS)->CURR_BALT	:=	RemDCSig(ValorCTB(Round(cArqTMP->SALDOATU/nDivide,nDecs),,,nSize,nDecs,.T., cPicture,cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,"1",,.F.,.F.))
		(cAliasDS)->CURR_BALD	:=	cArqTMP->SALDOATUDB/nDivide
		(cAliasDS)->CURR_BALC	:=	cArqTMP->SALDOATUCR/nDivide
		
		(cAliasDS)->PR_BALANCE	:= 	cArqTMP->MOVIMENTO/nDivide
		(cAliasDS)->IDENTIFI	:=	cArqTMP->IDENTIFI
		(cAliasDS)->ORDEM		:=	cArqTMP->ORDEM
		(cAliasDS)->MAINRECORD	:=	cArqTMP->TOTVIS
		(cAliasDS)->COLUMN1		:=	cArqTMP->COLUNA
		(cAliasDS)->LEVEL1		:=	cArqTMP->NIVEL
		(cAliasDS)->ENT_BAL		:=	cArqTMP->SLDENT
		
		// If its a 0, needs to change to -.
		// If its a negativa value, needs to change the signal and the value must be between parentesis.
		If Round((cAliasDS)->PREV_BAL,0) == 0
			(cAliasDS)->PREV_BALT	:=	"-"
		ElseIf Substr(Alltrim((cAliasDS)->PREV_BALT),1,1) =="-"
			(cAliasDS)->PREV_BALT	:=	"("+SubStr(Alltrim((cAliasDS)->PREV_BALT),2)+")"
		EndIf

		If Round((cAliasDS)->CURR_BAL ,0) == 0
			(cAliasDS)->CURR_BALT	:=	"-"
		ElseIf Substr(Alltrim((cAliasDS)->CURR_BALT),1,1) =="-"
			(cAliasDS)->CURR_BALT	:=	"("+SubStr(Alltrim((cAliasDS)->CURR_BALT),2)+")"
		EndIf
		
		(cAliasDS)->( msunlock() )
		
		dbSelectArea("cArqTmp")
		cArqTmp->( DbSkip() )
	EndDo

	dbSelectArea("cArqTmp")
	cArqTmp->(DbCloseArea())
	
	// Needs to start the progress bar.
	ProcRegua(0)
	IncProc(STR0007)
	
	// Function that creates the temporary table cArqTmp.
	CTGerPlan(	NIL, NIL, NIL, @lEnd,@cArqTmp,;
		Stod(Str(Year(dFinalA2),4)+'0101'),dFinalA2	,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
		"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
		"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
		MV_PAR06,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
		,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cDescMoeda,,aSelFil)
	
	
	dbSelectArea("cArqTmp")
	ProcRegua(cArqTmp->(RecCount()))
	cArqTmp->(DbGoTop())
	(cAliasDS)->(DbGoTop())
	While (cArqTmp->(!Eof()))
		
		If "/" $ Trim(cArqTMP->CONTA)
			cArqTmp->(DbSkip())
			Loop
		EndIf
		// Updating dataset.
		dbSelectArea(cAliasDS)
		Reclock(cAliasDS,.F.)
		
		// Verifies if displays 0.
		If (!lSaldoZer .And. cArqTMP->SALDOATU/nDivide == 0 .AND. (cAliasDS)->PREV_BAL == 0 .AND. (cAliasDS)->CURR_BAL == 0)
			(cAliasDS)->(dbDelete())
		Else
			(cAliasDS)->PREV_BAL2 	:=  cArqTMP->SALDOATU/nDivide
			(cAliasDS)->PREV_BAL2T	:=	RemDCSig(ValorCTB(Round(cArqTMP->SALDOATU/nDivide,nDecs),,,nSize,nDecs,.T.,cPicture,carqtmp->NORMAL, carqtmp->CONTA,,,cTpValor,"1",,.F.,.F.))
			(cAliasDS)->PREV_BAL2D	:=	cArqTMP->SALDOATUDB/nDivide
			(cAliasDS)->PREV_BAL2C	:=	cArqTMP->SALDOATUCR/nDivide
			
			// If its a 0, needs to change to -.
			// If its a negativa value, needs to change the signal and the value must be between parentesis.
			If Round((cAliasDS)->PREV_BAL2,0) == 0
				(cAliasDS)->PREV_BAL2T	:=	"-"
			ElseIf Substr(Alltrim((cAliasDS)->PREV_BAL2T),1,1) =="-"
				(cAliasDS)->PREV_BAL2T	:=	"("+Alltrim((cAliasDS)->PREV_BAL2T)+")"
			EndIf
			
		EndIf
		
		(cAliasDS)->( MSunlock() )
		
		cArqTmp->(DbSkip())
		(cAliasDS)->(DbSkip())
	EndDo

	RestArea(aAreaCTG)
	dbSelectArea("cArqTmp")
	cArqTmp->(DbCloseArea())
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} Rus500Det
Function that calls CTGerPlan to create the temporary table cArqTmp.
	
	@author National Platform
	@since  13/10/2016
	@version 1.0
	/*/
	//--------------------------------------------------------------------
	
Function Rus500Det(dFinal,dFinalA1)
	Local aSetOfBook as array
	Local aCtbMoeda	 as array
	Local cArqTmp as character
	Local cMoedaDesc	as character
	Local lEnd as logical
	
	aSetOfBook := CTBSetOf("")
	aCtbMoeda := {}
	cMoedaDesc	:= mv_par03
	aSetOfBook[3] := 0
	aSetOfBook[4] := "@E 999 999 999" //  CTN_PICTV
	aSetOfBook[5] := MV_PAR02
	aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
	
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf
	IncProc(STR0008)
	
	// Function that creates the temporary table cArqTmp.
	CTGerPlan(	NIL, NIL, NIL, @lEnd,@cArqTmp,;
		dFinalA1+1,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
		"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
		"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
		MV_PAR06,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
		,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,,aSelFil)
	
	dbSelectArea("cArqTmp")
	dbGoTop()
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
//merge branch 12.1.19
// Russia_R5
