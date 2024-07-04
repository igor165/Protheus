#include "protheus.ch"
#include "Birtdataset.ch"
#include "RU34R02.ch" 

//--------------------------------------------------------------------
/*/{Protheus.doc} RUS510DS
P&L DataSet.


@author National Platform
@since  13/10/2016
@version 1.0
/*/
//--------------------------------------------------------------------

dataset RUS510ds
	Title STR0001
	Description STR0001

Columns
	// Creating columns
	define Column A_YEAR TYPE NUMERIC SIZE 4 DECIMALS 0 LABEL 'Year'
	define Column A_MONTH TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Month'
	define Column A_DAY TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Day'
	define Column CO_KPP TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'KPP'
	define Column CO_ADDRESS TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Actual addr.'
	define Column CO_NAME TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Full name'
	define Column CO_OKOPF TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKOPF'
	define Column CO_OKFS TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKFS'
	define Column CO_OKVED TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKVED'
	define Column CO_OKPO TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKPO'
	::setColumn( "CO_TIN", "C", TamSX3("A1_CGC")[1], 0 )
	::setLabel( "CO_TIN", 'Company TIN' )
	define Column TYPE_ACC TYPE NUMERIC SIZE 1 DECIMALS 0 LABEL 'Type of line'
	define Column ACC_DESC TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Acc. Description'
	define Column ACC_DESC2 TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Acc. Description'
	define Column CODE TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'Acc. Code'
	define Column PARENT TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'PARENT'
	define Column CONDITION TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'CONDITION'
	define Column CURR_BALT TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CURR_BALT'
	define Column CURR_BAL TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance'
	define Column CURR_BALD TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance debit'
	define Column CURR_BALC TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance credit'
	define Column CURR_BAL1 TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance 1'
	define Column CURR_BALD1 TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance debit 1'
	define Column CURR_BALC1 TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance credit 1'
	define Column PREV_BAL TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance'
	define Column PREV_BALD TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance debit'
	define Column PREV_BALC TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Current balance credit'
	define Column PREV_BALT TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'PREV_BALT'
	define Column ANT_BALT TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'Ant. Bal. T'
	define Column ANT_BAL TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Ant. Bal.'
	define Column TIPEACC TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'TIPOCONTA'
	define Column IDENTIFI TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'IDENTIFI'
	define Column MAINRECORD	TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'TOTVIS'
	define Column ORDEM TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL 'ORDEM'
	define Column COLUMN1 TYPE NUMERIC SIZE 1 DECIMALS 0 LABEL 'COLUNA'
	define Column SALDOSEM TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'SALDOSEM'
	define Column LEVEL1 TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'NIVEL'
	define Column ENT_BAL TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'SLDENT'
	define Column GROUPACC TYPE CHARACTER SIZE 1 DECIMALS 0 LABEL 'GROUP'
	define Column CO_RUBL TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_RUBL'
	define Column CO_MDESC TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_MDESC'
	define Column CO_MDIVID TYPE CHARACTER SIZE 16 DECIMALS 2 LABEL 'CO_MDIVID'
	
	define Column SIGNER TYPE CHARACTER SIZE 30 DECIMALS 2 LABEL 'SIGNER'
	
Parameters
	define Parameter DDATASIGA TYPE CHAR SIZE 10 LABEL STR0008 DEFAULT VALUE "/"
	
		// Creating query
	define query 	"SELECT * FROM %WTable:1% WHERE %NotDel% ORDER BY ORDEM"

process dataset
	Local cWTabAlias as char
	Local lRet as logical
	Local cExp as char
	Local aArea as array
	
	lRet := .f.
	cExp := ""
	aArea :=	GetArea()
	// Crating worktable
	cWTabAlias := ::createWorkTable()
	
	// Calling the main function RUSR510TR
	lRet := Processa({|| RUSR510tr(cWTabAlias)}, STR0002, STR0003, .F.)
	
	RestArea(aArea)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} RUSR510TR
Function that fills the dataset.

@author National Platform
@since  13/10/2016
@version 1.0
/*/
//--------------------------------------------------------------------

Main Function RUSR510tr(cAliasDS)
Local aSetOfBook  as char
Local nDivide  as integer
Local aAreaCTG as array
Local dFinal as date
Local cCodeGroup as char
Local dFinalA1 as date
Local nSize as integer
Local cSpace as char
Local nDecs as integer
Local cPicture as char
Local cTpValor as char
Local cGroup as char
Local lDescCont as logical
Local cRubVal as char
Local cDivisor as character
Local aCtbMoeda as array
Local cDescMoeda as char
Local lImpAntLP as logical
Local dDtFinPre as date
Local dDtLPAct as date 
Local dDtLPPrev as date
Local dDtIniAct as date
Local dDtIniPre as date
Local cFinPer as char
Local lImpAntLP as logical

Local cRelTrb as char
Local aStruTmp as array
Local oArqTmp as object
Local nF as numeric
Local nI as numeric
Local aSingers as array

Private nLastKey as numeric
Private cPerg as char
Private cProgName as char
Private dFinal as date
Private aSelFil as array
Private lComNivel as logical

aSingers := {}
aadd (aSingers, GetSigners(MV_PAR11)) 	//Leader

lImpAntLP		:= Iif(mv_par10 == 1,.F.,.T.)
aSetOfBook	:= CTBSetOf("") 
nDivide		:=	1 
aAreaCTG 		:= CTG->(GetArea()) 
dFinal 		:= dDataBase 
dFinalA1 := dDataBase
nSize := 0 
cSpace := ""
nDecs := 0
cPicture := ""
cTpValor := ""
cGroup := ""
cRubVal := "384"
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
cDescMoeda := AllTrim(aCtbMoeda[3])

nLastKey := 0
cPerg := "RU34R02"
cProgName := "RUSR510"
aSelFil :=	{}
lComNivel := .T.

// Needs to start the progress bar.
ProcRegua(0)
IncProc()

// If user needs to select the branchs.
If mv_par06 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf

// Fills last date.
aSetOfBook[3] := 0
aSetOfBook[4] := "@E 999 999 999"//  CTN_PICTV
aSetOfBook[5] := mv_par02
If Empty(mv_par04)
	CTG->(dbSetOrder(1))
	If CTG->(dbSeek(xFilial("CTG")+mv_par01))
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEnd = mv_par01
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

cFinPer			:= Str(Month(dFinal),2)+Str(Day(dFinal),2)
dDtFinPre		:= Stod(Str(Year(dFinal)-1,4)+cFinPer)
dDtLPAct		:= Stod(Str(Year(dFinal)-1,4)+cFinPer)
dDtLPPrev		:= Stod(Str(Year(dDtLPAct)-1,4)+cFinPer)
dDtIniAct		:= Stod(Str(Year(dFinal),4)+'0101')
dDtIniPre		:= Stod(Str(Year(dFinal)-1,4)+'0101')

aSetOfBook      := CTBSetOf("")
aSetOfBook[3] 	:= 0
aSetOfBook[4]	:= "@E 999 999 999" //  CTN_PICTV
aSetOfBook[5] 	:= mv_par02
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

//--------------------------------------------------------------------------------
// Create Year -1 cArqTmp -> CtGerPlan
//--------------------------------------------------------------------------------
RU34R02Det(dDtIniPre ,dDtFinPre,dDtLPPrev,lImpAntLP)

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
RU34R02Det(dDtIniAct,dFinal,dDtLPAct,lImpAntLP)

//--------------------------------------------------------------------------------
// Process report data
//--------------------------------------------------------------------------------
// Finds the informations about the branch.
//TODO dbselectarea("SZD")
//TODO SZD->(DbSetOrder(1))
//TODO SZD->(DbSeek(xFilial()+cEmpAnt) ,, .T.)

cCodeGroup :=""
// Fills the dataset.
dbSelectArea(cRelTrb)
dbSelectArea("cArqTmp")
lDescCont	:=	FieldPos('DESCCONT') >0

ProcRegua(cArqTmp->(RecCount()))
DbGoTop()

While !Eof()
	IncProc()
	
	//This is for group when dont have CODE COUNT
	If "/" $ Trim(cArqTMP->CONTA) 
		
		If lDescCont .And. !Empty(cArqTMP->DESCCONT)
			cCodeGroup	:=	cCodeGroup + IIf(Empty(cCodeGroup),AllTrim(cArqTMP->DESCCONT), CRLF + AllTrim(cArqTMP->DESCCONT))
		Else
			cCodeGroup	:=	cCodeGroup + IIf(Empty(cCodeGroup), AllTrim(cArqTMP->DESCCTA), CRLF + AllTrim(cArqTMP->DESCCTA))
		EndIf
		
		dbSelectArea("cArqTmp")
		cArqTmp->(DbSkip())
		(cRelTrb)->(DbSkip())
		Loop
	EndIf
	
	Reclock(cAliasDS,.T.)
	
	(cAliasDS)->A_YEAR 		:= 	year(dFinal)
	(cAliasDS)->A_MONTH		:=	month(dFinal)
	(cAliasDS)->A_DAY 		:= 	day(dFinal)
	//TODO start:Change fields
	(cAliasDS)->CO_OKOPF	:= RU99CAdr("CO_OKOPF")//'12247' //TODO from SZD->ZD_OKOPF
	(cAliasDS)->CO_OKFS		:= RU99CAdr("CO_OKFS")//'31'//TODO from SZD->ZD_OKFS
	(cAliasDS)->CO_OKPO		:= RU99CAdr("CO_OKPO")//'27099446'//TODO from SZD->ZD_OKPO
	(cAliasDS)->CO_OKVED	:= RU99CAdr("CO_OKVED")//'29.4'//TODO from SZD->ZD_OKVED
	(cAliasDS)->CO_NAME		:= RU99CAdr("CO_NAME")//'Публичное акционерное общество "Альфа"'//TODO from SZD->ZD_FULL
	(cAliasDS)->CO_TIN		:= RU99CAdr("CO_TIN")//'7816274161'//TODO from SM0->M0_CGC
	(cAliasDS)->CO_KPP		:= RU99CAdr("CO_KPP")//'7816274161'
	(cAliasDS)->CO_ADDRESS	:= RU99CAdr("CO_ADDRESS")//'Россия, Москва, Арбат'
	//TODO end
	(cAliasDS)->CO_RUBL		:= cRubVal
	(cAliasDS)->CO_MDIVID	:= cDivisor
	(cAliasDS)->CO_MDESC	:= cDescMoeda
	(cAliasDS)->CODE 		:= AllTrim(cArqTMP->CONTA)
	(cAliasDS)->PARENT 		:= cArqTMP->SUPERIOR
	(cAliasDS)->CONDITION 	:= cArqTMP->NORMAL
	
	(cAliasDS)->ACC_DESC2 	:= ""
	cSpace		:= ""
	If Len(AllTrim(cArqTMP->CONTA)) > 2 .And. ;
		(Substr(AllTrim(cArqTMP->CONTA),Len(AllTrim(cArqTMP->CONTA))-1,2) == "00" .And. !(AllTrim(cArqTMP->CONTA) $ "2100|2500|2900"));
		 .Or. AllTrim(cArqTMP->CONTA) == "2421"
		cSpace := "."
	EndIf 
	If lDescCont .And. !Empty(cArqTMP->DESCCONT)
		(cAliasDS)->ACC_DESC	:=	cSpace + cArqTMP->DESCCONT
	Else
		(cAliasDS)->ACC_DESC	:=	cSpace + cArqTMP->DESCCTA
	EndIf	
	If !Empty(cCodeGroup)
		(cAliasDS)->ACC_DESC2	:=	cCodeGroup + CRLF + CRLF	
	EndIf
	cCodeGroup 	:= ""
	
	//get value from previos period  (cRelTrb)
	(cAliasDS)->PREV_BAL 	:= (cRelTrb)->SALDOATU/nDivide
	(cAliasDS)->PREV_BALD	:=	(cRelTrb)->SALDOATUDB/nDivide
	(cAliasDS)->PREV_BALC	:=	(cRelTrb)->SALDOATUCR/nDivide
	(cAliasDS)->PREV_BALT 	:= 	RemDCSig(ValorCTB(Round((cRelTrb)->SALDOATU/nDivide,nDecs),,,nSize,nDecs,.T., cPicture,(cRelTrb)->NORMAL, (cRelTrb)->CONTA,,,cTpValor,"1",,.F.,.F.))
	//pegar o mesmo periodo ate aqui (cRelTrb)
	
	(cAliasDS)->CURR_BALT	:= 	RemDCSig(ValorCTB(Round(cArqTMP->SALDOATU/nDivide,nDecs),,,nSize,nDecs,.T., cPicture,cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,"1",,.F.,.F.))
	(cAliasDS)->CURR_BAL	:= 	cArqTMP->SALDOATU/nDivide
	(cAliasDS)->CURR_BALD	:=	cArqTMP->SALDOATUDB/nDivide
	(cAliasDS)->CURR_BALC	:=	cArqTMP->SALDOATUCR/nDivide
	(cAliasDS)->CURR_BAL1	:= 	cArqTMP->SALDOATU/nDivide
	(cAliasDS)->CURR_BALD1	:=	cArqTMP->SALDOATUDB/nDivide
	(cAliasDS)->CURR_BALC1	:=	cArqTMP->SALDOATUCR/nDivide
	(cAliasDS)->ANT_BALT	:= "0"
	(cAliasDS)->ANT_BAL		:= 0
	(cAliasDS)->IDENTIFI	:=	cArqTMP->IDENTIFI
	(cAliasDS)->ORDEM		:=	cArqTMP->ORDEM
	(cAliasDS)->MAINRECORD	:=	cArqTMP->TOTVIS
	(cAliasDS)->COLUMN1		:=	cArqTMP->COLUNA
	(cAliasDS)->LEVEL1		:=	cArqTMP->NIVEL
	(cAliasDS)->ENT_BAL		:=	cArqTMP->SLDENT
	(cAliasDS)->GROUPACC	:=  Substr(cArqTMP->ORDEM,1,1)
	
	
	// If its a 0, needs to change to -.
	// If its a negativa value, needs to change the signal and the value must be between parentesis.
	If Round((cAliasDS)->PREV_BAL,0) == 0 
		(cAliasDS)->PREV_BALT	:=	"-"
	ElseIf Substr(Alltrim((cAliasDS)->PREV_BALT),1,1) =="-"
		(cAliasDS)->PREV_BALT	:=	"("+SubStr(Alltrim((cAliasDS)->PREV_BALT),2)+")"
	EndIf
	If Round((cAliasDS)->CURR_BAL,0) == 0 
		(cAliasDS)->CURR_BALT	:=	"-"
	ElseIf Substr(Alltrim((cAliasDS)->CURR_BALT),1,1) =="-"
		(cAliasDS)->CURR_BALT	:=	"("+ SubStr(Alltrim((cAliasDS)->CURR_BALT),2)+")"
	EndIf
	(cAliasDS)->SIGNER		:= AllTrim(aSingers[1][2])
	(cAliasDS)->( msunlock() )
	
	dbSelectArea("cArqTmp")
	cArqTmp->(DbSkip())
	(cRelTrb)->(DbSkip())
Enddo

dbSelectArea("cArqTmp")
cArqTmp->(DbCloseArea())

If oArqTmp<> Nil
	oArqTmp:Delete()
	oArqTmp := Nil
Endif

RestArea(aAreaCTG)

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} RU34R02Det
Function that calls CTGerPlan to create the temporary table cArqTmp.

@author National Platform
@since  13/10/2016
@version 1.0
/*/
//--------------------------------------------------------------------

Function RU34R02Det(dBegin, dEnd,dDtLP,lImpAntLP) 
Local aSetOfBook as array  
Local aCtbMoeda as array
Local cArqTmp as character 
Local cMoedaDesc as characret
Local lEnd as logical

aSetOfBook	:= CTBSetOf("")  
aCtbMoeda := {} 
cMoedaDesc	:= mv_par03

Default dBegin := dDataBase
Default dEnd := dDataBase
aSetOfBook[3] := 0
aSetOfBook[4] := "@E 999 999 999" //  CTN_PICTV
aSetOfBook[5] := mv_par02
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
//lImpAntLP		:= .F.


If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
	Return .F.
EndIf
IncProc(STR0007)
// Function that creates the temporary table cArqTmp.
CTGerPlan(	NIL, NIL, NIL, @lEnd, @cArqTmp,;//5
dBegin, dEnd, "CT7", "", "", Repl("Z", Len(CT1->CT1_CONTA)),;//11
"", Repl("Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM)),;//15
"", Repl("Z", Len(CTH->CTH_CLVL)), mv_par03,;//18
mv_par05, aSetOfBook, Space(2), Space(20), Repl("Z", 20), Space(30);//24 (61)
, , , , ,lImpAntLP,dDtLP , , , , , , , , , , , , , , , , , , , , , , , , , , , cMoedaDesc,.T., aSelFil, ,.T.)//60
//, , , ,.F.,, , , , , , , , , , , , , , , , , , , , , , , , , , , , cMoedaDesc,, aSelFil)
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
