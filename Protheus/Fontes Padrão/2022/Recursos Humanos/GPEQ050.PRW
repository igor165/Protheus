#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "GPEQ050.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEQ050  ³ Autor ³ Leandro Drumond         ³ Data ³ 26.03.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quick Search Programacao de Ferias	                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FLUIG                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³Chamado|  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³       ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//QSSTRUCT GPEA050 DESCRIPTION PorEncode(STR0001) MODULE 7  //"Programação de Férias"
QSSTRUCT GPEA050 DESCRIPTION STR0001 MODULE 7  //"Programação de Férias"

QSMETHOD INIT QSSTRUCT GPEA050
	
	Local _cUserEmp := ""
	Local _cUserFil := ""
	Local _cUserMat := ""
	Local _cUserDpto:= ""
	Local _cUserCPF	:= ""
	Local _cLikeRec := ""
	Local cWhere	:= ""
	Local cDt3Meses	:= DtoS(MonthSum( Date() , 3 ))
	Local cDt6Meses := DtoS(MonthSum( Date() , 6 ))
	Local cDt9Meses	:= DtoS(MonthSum( Date() , 9 ))
	Local cDt12Meses:= DtoS(MonthSum( Date() , 12 ))
	Local cMultVinc	:= ""
	
	//Obtem as informacoes do usuario
	//__cUserId := "000001" //--Utilizado para teste no POC

	RhGetFuncInfo(@_cUserEmp,@_cUserFil,@_cUserMat,@_cUserDpto,@_cLikeRec,@_cUserCPF)
	
	QSTABLE "SRA" JOIN "SQB" ON "RA_DEPTO = QB_DEPTO AND " + FWJoinFilial( "SRA", "SQB" )
	QSTABLE "SRA" JOIN "SRF" ON "RA_FILIAL = RF_FILIAL AND RA_MAT = RF_MAT"
	QSTABLE "SRA" LEFT JOIN "SRJ" ON "RA_CODFUNC = RJ_FUNCAO AND " + FWJoinFilial( "SRA", "SRJ" )
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "RA_NOME" INDEX ORDER 3
	QSPARENTFIELD "RA_MAT" INDEX ORDER 1
	QSPARENTFIELD "QB_DEPTO" INDEX ORDER 1 SET RELATION TO "RA_DEPTO"
	QSPARENTFIELD "QB_DESCRIC" INDEX ORDER 2 SET RELATION TO "RA_DEPTO" WITH "QB_DEPTO" LABEL OemToAnsi((STR0002)) //"Descrição"
	
	// campos do SX3
	QSFIELD "RA_NOME"
	QSFIELD "RF_DATAINI" LABEL PorEncode(STR0003) //"Início 1a. Programação"
	QSFIELD "RF_DFEPRO1" LABEL PorEncode(STR0004) //"Dias Férias 1a. Prog." 
	QSFIELD "RF_DABPRO1" LABEL PorEncode(STR0005) //"Dias Abono 1a. Prog."
	QSFIELD "RF_DATABAS", "RF_DATAFIM"

	// acoes do menudef, MVC ou qualquer rotina
	QSACTION MENUDEF "GPEA050" OPERATION 2 LABEL OemToAnsi(STR0015) //"Visualizar"

	cMultVinc:= "RA_CIC = '" + _cUserCpf + "'"
	cWhere := "(( QB_FILRESP = '" + _cUserFil + "' AND QB_MATRESP = '" + _cUserMat + "' AND QB_DEPTO = '" + _cUserDpto + "') OR ( RA_CIC = '" + _cUserCpf + "') OR ( QB_DEPSUP <> '' AND QB_DEPSUP = '" + _cUserDpto + "' AND (SELECT QB_MATRESP FROM " + RetSqlName("SQB") + " SQB2 WHERE SQB2.QB_DEPTO = SQB.QB_DEPSUP AND SQB2.QB_FILRESP = '" + _cUserFil + "') = '" + _cUserMat + "'))"

	If Empty(_cLikeRec)
		cWhere03 := cWhere + " AND RF_STATUS = '1' AND RA_DEMISSA = '' AND ( (RF_DATAINI <> '' AND RF_DATAINI <= '" + cDt3Meses + "') OR (RF_DATINI2 <> '' AND RF_DATINI2 <= '" + cDt3Meses + "') OR (RF_DATINI3 <> '' AND RF_DATINI3 <= '" + cDt3Meses + "')))"
		cWhere06 := cWhere + " AND RF_STATUS = '1' AND RA_DEMISSA = '' AND ( (RF_DATAINI <> '' AND RF_DATAINI <= '" + cDt6Meses + "') OR (RF_DATINI2 <> '' AND RF_DATINI2 <= '" + cDt6Meses + "') OR (RF_DATINI3 <> '' AND RF_DATINI3 <= '" + cDt6Meses + "')))"
		cWhere09 := cWhere + " AND RF_STATUS = '1' AND RA_DEMISSA = '' AND ( (RF_DATAINI <> '' AND RF_DATAINI <= '" + cDt9Meses + "') OR (RF_DATINI2 <> '' AND RF_DATINI2 <= '" + cDt9Meses + "') OR (RF_DATINI3 <> '' AND RF_DATINI3 <= '" + cDt9Meses + "')))"
		cWhere12 := cWhere + " AND RF_STATUS = '1' AND RA_DEMISSA = '' AND ( (RF_DATAINI <> '' AND RF_DATAINI <= '" + cDt12Meses + "') OR (RF_DATINI2 <> '' AND RF_DATINI2 <= '" + cDt12Meses + "') OR (RF_DATINI3 <> '' AND RF_DATINI3 <= '" + cDt12Meses + "')))"

		QSFILTER OemToAnsi(STR0016) WHERE "RA_MAT = '' OR (" + cWhere + " AND RF_STATUS = '1' AND RA_DEMISSA = '')" 	//Todas
		QSFILTER OemToAnsi(STR0017) WHERE "RA_MAT = '' OR (" + cWhere03  //A vencer próximos 3 Meses
		QSFILTER OemToAnsi(STR0018) WHERE "RA_MAT = '' OR (" + cWhere06 //A vencer próximos 6 Meses
		QSFILTER OemToAnsi(STR0019) WHERE "RA_MAT = '' OR (" + cWhere09 //A vencer próximos 9 Meses
		QSFILTER OemToAnsi(STR0020) WHERE "RA_MAT = '' OR (" + cWhere12 //A vencer próximos 12 Meses
		QSFILTER OemToAnsi(STR0021) WHERE "RA_MAT = '' OR (" + cWhere + " AND RF_STATUS = '1' AND RA_DEMISSA = '' AND RF_DATAINI = '' AND RF_DATINI2 = '' AND RF_DATINI3 = '')" //Sem Programacao
	Else
		cWhere03 := "RF_STATUS = '1' AND RA_DEMISSA = '' AND ( (RF_DATAINI <> '' AND RF_DATAINI <= '" + cDt3Meses + "') OR (RF_DATINI2 <> '' AND RF_DATINI2 <= '" + cDt3Meses + "') OR (RF_DATINI3 <> '' AND RF_DATINI3 <= '" + cDt3Meses + "'))
		cWhere06 := "RF_STATUS = '1' AND RA_DEMISSA = '' AND ( (RF_DATAINI <> '' AND RF_DATAINI <= '" + cDt6Meses + "') OR (RF_DATINI2 <> '' AND RF_DATINI2 <= '" + cDt6Meses + "') OR (RF_DATINI3 <> '' AND RF_DATINI3 <= '" + cDt6Meses + "'))
		cWhere09 := "RF_STATUS = '1' AND RA_DEMISSA = '' AND ( (RF_DATAINI <> '' AND RF_DATAINI <= '" + cDt9Meses + "') OR (RF_DATINI2 <> '' AND RF_DATINI2 <= '" + cDt9Meses + "') OR (RF_DATINI3 <> '' AND RF_DATINI3 <= '" + cDt9Meses + "'))
		cWhere12 := "RF_STATUS = '1' AND RA_DEMISSA = '' AND ( (RF_DATAINI <> '' AND RF_DATAINI <= '" + cDt12Meses + "') OR (RF_DATINI2 <> '' AND RF_DATINI2 <= '" + cDt12Meses + "') OR (RF_DATINI3 <> '' AND RF_DATINI3 <= '" + cDt12Meses + "'))
		QSFILTER OemToAnsi(STR0016) WHERE "RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ")  OR " + cMultVinc + ") AND RF_STATUS = '1' AND RA_DEMISSA = '')" 	//Todas
		QSFILTER OemToAnsi(STR0017) WHERE "RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ")  OR " + cMultVinc + ") AND " + cWhere03 + ")" //A vencer próximos 3 Meses
		QSFILTER OemToAnsi(STR0018) WHERE "RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ")  OR " + cMultVinc + ") AND " + cWhere06 + ")" //A vencer próximos 6 Meses
		QSFILTER OemToAnsi(STR0019) WHERE "RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ")  OR " + cMultVinc + ") AND " + cWhere09 + ")" //A vencer próximos 9 Meses
		QSFILTER OemToAnsi(STR0020) WHERE "RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ")  OR " + cMultVinc + ") AND " + cWhere12 + ")" //A vencer próximos 12 Meses
		QSFILTER OemToAnsi(STR0021) WHERE "RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ") OR " + cMultVinc + ") AND RF_STATUS = '1' AND RA_DEMISSA = '' AND RF_DATAINI = '' AND RF_DATINI2 = '' AND RF_DATINI3 = '')" //Sem Programacao
	EndIf
	
Return
