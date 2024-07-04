#INCLUDE "VDFR380.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR380  ³ Autor ³ Alexandre Florentino     ³ Data ³  28.03.14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Exercício Cumulativo de Função                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR380(void)                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VDFR380()

	Private oReport
	Private cString		:= 'RI8'
	Private cPerg	    := "VDFR380"
	Private cTitulo		:= STR0001 //'Relatório de Exercício Cumulativo de Função'
	Private nSeq 	    := 0
	Private cAliasQry 	:= ''
	
	Pergunte(cPerg, .F.)

	M->RA_FILIAL := ""	// Variavel para controle da numeração

	oReport := ReportDef()
	oReport:PrintDialog()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Alexandre Florentino  ³ Data ³ 28.03.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR380                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR380 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

	Local cDescri := STR0002 //'O relatório de exercício cumulativo de função visa auxiliar a consulta dos membros que estão acumulando funções.'
	
	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								.T.,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	TRCell():New(oFilial,"RI8_FILSUB","RI8")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RI8_FILSUB, (M->RA_FILIAL := (cAliasQry)->RI8_FILSUB, nSeq := 0), Nil),;
																	 fDesc("SM0", cEmpAnt + (cAliasQry)->(RI8_FILSUB), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0004, ( "SRA","RI8","SQB" )) //'Membros'

	nSeq := 0

	TRCell():New(oFunc,            '',       '',       'Nº', '99999', 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão
	TRCell():New(oFunc,  'RI8_MATSUB',    'RI8',	STR0006,, 6)     //-- Matricula //'RI8_MATSUB'###'Matrícula'
	TRCell():New(oFunc,     'RA_NOME',    'SRA',    STR0007,, 40)     //-- Nome                           //'Nome'
	TRCell():New(oFunc,   'RI8_GEDOC',    'RI8',    STR0008,, 20 )     //-- Nº Gedoc //'Nº Gedoc'
	TRCell():New(oFunc,  'QB_DESCRIC',    'SQB',    STR0009 + Chr(13) + Chr(10) + STR0010 )     //-- Promotoria Titularidade //'Promotoria'###'Titularidade'
	TRCell():New(oFunc,  'QB_DESCRI8',    'SQB',    STR0011 + Chr(13) + Chr(10) + STR0012,,30 ) //-- Lotação Cumulativa //'Lotação'###'Cumulativa'
	TRCell():New(oFunc,  'RI8_PERCEN',    'RI8',    STR0013 + Chr(13) + Chr(10) + STR0014,,6 ) //-- Porcentagem Subsidio //'Porcentagem'###'Subsidio'
	TRCell():New(oFunc,  'RI8_DATADE',    'RI8',    STR0015 + Chr(13) + Chr(10) + STR0016 )     //-- Início do Cumulativo //'Início do'###'Cumulativo'
	TRCell():New(oFunc,  'RI8_DATATE',    'RI8',    STR0017 + Chr(13) + Chr(10) + STR0016 )     //-- Final do Cumulativo //'Final do'###'Cumulativo'
	TRCell():New(oFunc,            '',    'RI8',    STR0018 + Chr(13) + Chr(10) + STR0019, , 8,;
					/*lPixel*/, /*bBlock*/ { || Right((cAliasQry)->RI8_PERIOD,2) + '/' + Left((cAliasQry)->RI8_PERIOD,4)  },,, ) //'Mês Início '###'do pagamento'
	TRCell():New(oFunc,  'RI8_PARCEL',    'RI8',    STR0020 + Chr(13) + Chr(10) + STR0021, '999', 5)     //-- Qtde de Parcelas //'Qtde de '###'Parcelas'
    
Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Alexandre Florentino ³ Data ³ 28.03.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR380                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR380 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)
    
	Local nCont		:= 0
	Local cSQBJoin	:= fTbJoinSQL("SQB", "RI8","%")
	Local cRI8Join	:= Replace(cSQBJoin,"SQB.","SQBRI8.")
	Local oFilial	:= oReport:Section(1), oFunc := oReport:Section(1):Section(1) , cWhere := "%"

	If Empty(mv_par03) .OR. Empty(mv_par04)
		MsgInfo(STR0022)	// 'Atenção. É obrigatório preencher a competência inicial e final !'
		Return 
	EndIF

	cAliasQry := GetNextAlias()

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cWhere += " AND " + MV_PAR02
	EndIf

  	cWhere += " AND (((RI8_DATADE >= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "01' " +;
  	               "AND RI8_DATADE <= '" + Right(mv_par04, 4) + Left(mv_par04, 2) + "31') OR RI8_DATADE = '') OR " +;
  	                 "((RI8_DATATE >= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "01' " +;
  	               "AND RI8_DATATE <= '" + Right(mv_par04, 4) + Left(mv_par04, 2) + "31') OR RI8_DATATE = ''))"

	If !Empty(MV_PAR05)		//-- Lotação
		cWhere += " AND " + MV_PAR05
	EndIf

	cWhere += "%"

	oFilial:BeginQuery()
	BeginSql Alias cAliasQry
		
		SELECT RI8.RI8_FILSUB, RI8.RI8_MATSUB, SRA.RA_NOME, RI8.RI8_GEDOC, SQB.QB_DESCRIC, SQBRI8.QB_DESCRIC AS QB_DESCRI8, RI8.RI8_PERCEN,
 			   RI8.RI8_DATADE, RI8.RI8_DATATE, RI8.RI8_PERIOD, RI8.RI8_PARCEL
 		  FROM %table:RI8% RI8
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = RI8.RI8_FILSUB AND SRA.RA_MAT = RI8.RI8_MATSUB
 		   AND SRA.RA_CATFUNC IN (%Exp:'0'%, %Exp:'1'%)
		  JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cSQBJoin% AND SQB.QB_DEPTO = RI8.RI8_DEPTO
		  JOIN %table:SQB% SQBRI8 ON SQBRI8.%notDel% AND %Exp:cRI8Join% AND SQBRI8.QB_DEPTO = RI8.RI8_DEPTOT
	 	 WHERE RI8.%notDel% %Exp:cWhere%
	 	 ORDER BY SRA.RA_FILIAL, SRA.RA_NOME 
	EndSql
	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQry)->RI8_FILSUB  == cParam}, {|| (cAliasQry)->RI8_FILSUB  })

	oFilial:Print()

Return