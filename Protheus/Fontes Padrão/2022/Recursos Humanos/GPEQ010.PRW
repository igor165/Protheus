#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "GPEQ010.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEQ010  ³ Autor ³ Leandro Drumond         ³ Data ³ 26.03.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quick Search Dados Cadastrais		                        ³±±
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

QSSTRUCT GPEA010 DESCRIPTION STR0001 MODULE 7 //"Funcionarios"

QSMETHOD INIT QSSTRUCT GPEA010
	Local _cUserEmp := ""
	Local _cUserFil := ""
	Local _cUserMat := ""
	Local _cUserDpto:= ""
	Local _cLikeRec := ""
	Local _cUserCPF	:= ""
	Local cWhereAux := ""
	Local cMultVinc := ""
	
	//Obtem as informacoes do usuario
	//__cUserId := "000001" //--Utilizado para teste no POC

	RhGetFuncInfo(@_cUserEmp,@_cUserFil,@_cUserMat,@_cUserDpto,@_cLikeRec,@_cUserCPF)
	
	QSTABLE "SRA" JOIN "SQB" ON "RA_DEPTO = QB_DEPTO AND " + FWJoinFilial( "SRA", "SQB" )
	QSTABLE "SRA" JOIN "SX5" ON "X5_TABELA = '31' AND X5_CHAVE = RA_SITFOLH"

	// campos do SX3 e indices do SIX
	QSPARENTFIELD "RA_NOME" INDEX ORDER 3
	QSPARENTFIELD "RA_MAT" INDEX ORDER 1
	QSPARENTFIELD "QB_DEPTO" INDEX ORDER 1 SET RELATION TO "RA_DEPTO"
	QSPARENTFIELD "QB_DESCRIC" INDEX ORDER 2 SET RELATION TO "RA_DEPTO" WITH "QB_DEPTO" LABEL PorEncode(STR0002)
	
	// campos do SX3
	QSFIELD "RA_NOME" , "RA_MAT"
	QSFIELD "TELEFONE"   EXPRESSION "RA_DDDFONE + RA_TELEFON" LABEL PorEncode(STR0003) FIELDS "RA_DDDFONE", "RA_TELEFON" TYPE "C" SIZE 15 DECIMAL 0 PICTURE "@!" //Telefone
	QSFIELD "CELULAR"    EXPRESSION "RA_DDDCELU + RA_NUMCELU" LABEL PorEncode(STR0010) FIELDS "RA_DDDCELU", "RA_NUMCELU" TYPE "C" SIZE 15 DECIMAL 0 PICTURE "@!" //Celular
	QSFIELD "RA_EMAIL"
	//QSFIELD "QB_DEPTO", "QB_DESCRIC"
	QSFIELD "QB_DESCRIC"
	//QSFIELD "X5_DESCRI" LABEL PorEncode(STR0004) //"Situação"

	QSACTION MENUDEF "GPEA010" OPERATION 2 LABEL PorEncode(STR0005) //"Visualizar"
	QSACTION MENUDEF "RSPA010" OPERATION 2 LABEL PorEncode(STR0009) //"Curriculum"

	
	cMultVinc:= "RA_CIC = '" + _cUserCpf + "'"
	
	If Empty(_cLikeRec)	
		cWhereAux := "(( QB_FILRESP = '" + _cUserFil + "' AND QB_MATRESP = '" + _cUserMat + "' AND QB_DEPTO = '" + _cUserDpto + "') OR ( RA_CIC = '" + _cUserCpf + "') OR ( QB_DEPSUP <> '' AND QB_DEPSUP = '" + _cUserDpto + "' AND (SELECT QB_MATRESP FROM " + RetSqlName("SQB") + " SQB2 WHERE SQB2.QB_DEPTO = SQB.QB_DEPSUP AND SQB2.QB_FILRESP = '" + _cUserFil + "') = '" + _cUserMat + "'))"
		
		QSFILTER PorEncode(STR0006) WHERE "(RA_MAT = '' OR (" + cWhereAux + " AND RA_DEMISSA = ''))" //ATIVOS
		QSFILTER PorEncode(STR0007) WHERE "(RA_MAT = '' OR (" + cWhereAux + " AND RA_DEMISSA = '' AND RA_SITFOLH <> ''))" //AFASTADOS
		QSFILTER PorEncode(STR0008) WHERE "(RA_MAT = '' OR (" + cWhereAux + " AND RA_DEMISSA <> '' ))" //DEMITIDOS
	Else
		QSFILTER PorEncode(STR0006) WHERE "(RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ") OR " + cMultVinc + ")) AND RA_DEMISSA = '') " //"Ativos"
		QSFILTER PorEncode(STR0007) WHERE "(RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ") OR " + cMultVinc + ")) AND RA_DEMISSA = '' AND RA_SITFOLH <> '') " //"Afastados"
		QSFILTER PorEncode(STR0008) WHERE "(RA_MAT = '' OR ( ( SRA.R_E_C_N_O_ IN (" + _cLikeRec + ") OR " + cMultVinc + ")) AND RA_DEMISSA <> '' ) " //"Demitidos"
	EndIf
	
Return
