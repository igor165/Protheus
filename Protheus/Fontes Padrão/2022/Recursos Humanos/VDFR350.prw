#INCLUDE "VDFR350.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR350  ³ Autor ³ Alexandre Florentino  ³ Data ³  21.02.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Exonerados                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR350(void)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VDFR350()

	Local aRegs := {}
	
	Private oReport
	Private	cString	  := "SRA"
	Private cPerg	  := "VDFR350"
	Private cTitulo	  := STR0001 //'Relatório de Exonerados '
	Private nSeq 	  := 0
	Private cAliasQRY := ""

	Pergunte(cPerg, .F.)

	M->RA_FILIAL := ""	// Variavel para controle da numeração

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Alexandre Florentino  ³ Data ³ 24.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR350                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR350 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

	Local cDescri := STR0002 //'O relatório deve apresentar informações das exonerações ocorridas dentro do período selecionado.'                                                                                                                                                                                                                                                                                                                                                                                                                              

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 3)
	oReport:nFontBody := 7  

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish(),;
															 oReport:Section(1):Section(1):Init(), oReport:Section(1):Section(1):PrintLine(),;
															 oReport:Section(1):Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	TRCell():New(oFilial,"RA_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																	 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0004, ( "SRA","SQ3" )) //'Servidores'

	nSeq := 0

	TRCell():New(oFunc,	"","",'Nº', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão
	TRCell():New(oFunc,"RA_NOME","SRA",STR0005,, 40)                      //-- Nome //'Nome'
	TRCell():New(oFunc,"Q3_DESCSUM","SQ3",STR0006,, 40)                  //-- Cargo //'Cargo'
	TRCell():New(oFunc,"RA_DEMISSA","SRA",STR0007,, 20)     //-- Data da Exoneração //'Data da Exoneração'
	TRCell():New(oFunc,"MOTIVO","SRA",STR0008,, 22)     //-- Motivo do Desligamento  //'Motivo do Desligamento'
    
	//  RA_NOME  | Q3_DESCSUM | RA_DEMISSA | MOTIVO

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Alexandre Florentino ³ Data ³ 24.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR350                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR350 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)
    
	Local cIdFol 	:= cRF_TIPOSQL := cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
	Local oFilial 	:= oReport:Section(1), oFunc := oReport:Section(1):Section(1) , cWhere := "%" 
    Local cAux    	:= "%", cFields := ""
    Local cJoinSQ3	:= ""
    
	If Empty(mv_par03)
		MsgInfo(STR0013) //'Atenção. É obrigatório selecionar a competência !'
		Return 
	EndIF
	
	cAliasQRY := GetNextAlias()
		
	oReport:SetTitle(cTitulo + " [" + Trans(mv_par03, "@R 99/9999") + "]")

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)
    
	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cWhere += " AND " + MV_PAR02
	EndIf                                                                                               

	If !Empty(MV_PAR03)		//-- Competência da Exoneração
		cWhere += " AND SRA.RA_DEMISSA BETWEEN '" + Right(MV_PAR03, 4) + Left(MV_PAR03, 2) + "01' AND '" + Right(MV_PAR03, 4) + Left(MV_PAR03, 2) + "31'"
	EndIf
    
	If !Empty(MV_PAR04)		//-- Tipo de Cargo
		cWhere += " AND " + MV_PAR04
	EndIf
    
	//-- Monta a string com as categorias a serem listadas
	If AllTrim( mv_par05 ) <> Replicate("*", Len(AllTrim( mv_par05 )))
		cRA_CATFUN   := ""
		
		For nCont  := 1 to Len(Alltrim(mv_par04)) Step nTRACATFUN
			If Substr(mv_par05, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par05, nCont, nTRACATFUN)))
				cRA_CATFUN += "'" + Substr(mv_par05, nCont, nTRACATFUN) + "',"
			EndIf
		Next
	
		cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)

		If !Empty(AllTrim(cRA_CATFUN))
			cWhere += ' AND SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
		EndIf
	EndIf

	cWhere += "%"

	cFields := "%CASE WHEN SRA.RA_AFASFGT IN ('H') THEN '" + STR0009 + "' ELSE " +; //'Demissao'
			    "CASE WHEN SRA.RA_AFASFGT IN ('J','K','U') THEN '" + STR0010 + "' ELSE " +; //'A Pedido'
			    "CASE WHEN SRA.RA_AFASFGT IN ('1','3','I','L') THEN '" + STR0011 + "' ELSE " +;  //'Exonerado'
			    "CASE WHEN SRA.RA_AFASFGT IN ('9','S') THEN '" + STR0012 + "' ELSE '' END END END END%" //'Falecimento'
	cFieldsU := STR0011 //'Exonerado'
	cJoinSQ3 := "%" + FWJoinFilial( "SRA", "SQ3" ) + "%"
	
	oFilial:BeginQuery()
	BeginSql Alias cAliasQRY
		SELECT SRA.RA_FILIAL, SRA.RA_NOME, SQ3.Q3_DESCSUM, SRA.RA_DEMISSA, SRA.RA_CATFUNC, %Exp:cFields% AS MOTIVO 
		  FROM %table:SRA% SRA
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO 
		 WHERE SRA.%notDel% %Exp:cWhere% AND NOT SRA.RA_RESCRAI IN (%Exp:'30'%, %Exp:'31'%)
		 UNION ALL
		SELECT SRA.RA_FILIAL, SRA.RA_NOME, SQ3.Q3_DESCSUM, SR7.R7_DATA, SRA.RA_CATFUNC, %Exp:cFieldsU% AS MOTIVO 
		  FROM %table:SR7% SR7
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SR7.R7_FILIAL AND SRA.RA_MAT = SR7.R7_MAT 
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO 
		 WHERE SR7.%notDel% AND SRA.%notDel% %Exp:StrTran(cWhere, "SRA.RA_DEMISSA", "SR7.R7_DATA")% AND SR7.R7_TIPO = %Exp:'EXO'% 
		 ORDER BY RA_FILIAL, RA_CATFUNC, RA_DEMISSA, RA_NOME
	EndSql
		        
	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

	oFilial:Print()
	
Return