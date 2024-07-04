#INCLUDE "VDFR420.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR420  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  27.05.14      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relação de Promotores de Justiça designados para coadjuvarem nos ³±±
±±³          ³ trabalhos das Procuradorias de Justiça                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR410(void)                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±   
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Silvia Tag  ³18/07/2018³DRHGFP-1034³Upgrade V12-Retirada AjustaSX'           ³±±
±±³            ³          ³      ³                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VDFR420()

	Local aRegs := {}
		
	Private oReport
	Private cString   := "RIL"
	Private cPerg	    := "VDFR420"
	Private cTitulo   := STR0001 //'Relação de Promotores de Justiça designados'
	Private nSeq 	    := 0
	Private cAliasQRY := ""
		
	M->RA_FILIAL := ""	// Controle de quebra de filial

	oReport := ReportDef()
	oReport:PrintDialog()

	PtSetAcento(.F.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 27.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR410                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR410 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

	Local cDescri := STR0002 //'O relatório “Relação de Promotores de Justiça designados para coadjuvarem nos trabalhos das Procuradorias de Justiça” visa auxiliar o gerenciamento dos promotores de justiça designados para coadjuvarem nos trabalhos das Procuradorias de Justiça, bem como a quantidade de dias que o desta designação em uma determinada competência.'

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0003, { "SM0" })  //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	TRCell():New(oFilial,"RA_FILIAL", "QRY")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																			 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0004, ( "SRA" )) //'Servidores'

	nSeq := 0

	TRCell():New(oFunc,  '',           '',    'Nº', '99999', 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão
	TRCell():New(oFunc, "RA_MAT",     	cAliasQry, STR0005) //'Matricula'
	TRCell():New(oFunc, "RA_NOME",    	cAliasQry, STR0006,, 100) //'Nome'
	TRCell():New(oFunc, "RIL_INICIO", 	cAliasQry, STR0007,,12, /*lPixel*/,/*bBlock*/, "CENTER") //'Inicio do Periodo'
	TRCell():New(oFunc, "RIL_FINAL" , 	cAliasQry, STR0008,,12, /*lPixel*/,/*bBlock*/, "CENTER") //'Fim do Periodo'
	TRCell():New(oFunc, ""          ,            , STR0009, '99', 5, /*lPixel*/, /*bBlock*/ { || DiasRef() }, "CENTER"  ) //'Referencia (Dias)'
	TRCell():New(oFunc,  '',           '',    STR0010, ,, /*lPixel*/,/*bBlock*/;
				 { || AllTrim((cAliasQry)->RIL_NUMDOC) + If(! Empty((cAliasQry)->RIL_NUMDOC), "/", "") + AllTrim((cAliasQry)->RIL_ANO) } ) //'Portaria'

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DiasRef     ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 27.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o numero de dias de referencia                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR410                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR410 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DiasRef

Local nDias := Day(LastDay(Stod(Right(mv_par03, 4) + Left(mv_par03, 2) + "01")))

nDias := If(Left(Dtos((cAliasQry)->RIL_FINAL), 6) == Right(mv_par03, 4) + Left(mv_par03, 2), Day((cAliasQry)->RIL_FINAL), nDias) -;
	      If(Left(Dtos((cAliasQry)->RIL_INICIO), 6) == Right(mv_par03, 4) + Left(mv_par03, 2), Day((cAliasQry)->RIL_INICIO), 0) + 1

Return If(nDias > 30, 30, nDias)				 		 	             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 27.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR410                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR410 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oFilial := oReport:Section(1), oFunc := oReport:Section(1):Section(1), cWhere := "%", nCont := 1
Local cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" )
Local cRIL_DESIG := "", nRIL_DESIG := GetSx3Cache( "RIL_DESIGN", "X3_TAMANHO" )

	If Empty(mv_par03)
		MsgInfo(STR0011) //'É obrigatório o preenchimento da competência ! Verifique os parâmetros !'
		Return 
	EndIF

	cAliasQRY := GetNextAlias()

	oReport:SetTitle(Trim(mv_par04) + Trim(mv_par05) + " [" + Trans(mv_par03, "@R 99/9999") + "]")

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cWhere += " AND " + MV_PAR02
	EndIf

  	cWhere += " AND (((RIL.RIL_INICIO >= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "01' " +;
  	               "AND RIL.RIL_INICIO <= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "31')) OR " +;
  	                 "((RIL.RIL_FINAL >= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "01' " +;
  	               "AND RIL.RIL_FINAL <= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "31') OR " +;
  	                   "(RIL.RIL_FINAL = '' AND RIL.RIL_INICIO <= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "31')))"

	//-- Monta a string com as categorias a serem listadas
	If AllTrim( mv_par06 ) <> Replicate("*", Len(AllTrim( mv_par07 )))
		cRIL_DESIGN   := ""
		For nCont  := 1 to Len(Alltrim(mv_par06)) Step nRIL_DESIG
			If Substr(mv_par06, nCont, nRIL_DESIGN) <> Replicate("*", Len(Substr(mv_par06, nCont, nRIL_DESIGN)))
				cRIL_DESIGN += "'" + Substr(mv_par06, nCont, nRIL_DESIGN) + "',"
			EndIf
		Next
		cRIL_DESIGN := Substr( cRIL_DESIGN, 1, Len(cRIL_DESIGN)-1)
	
		If ! Empty(AllTrim(cRIL_DESIGN))
			cWhere += ' AND RIL.RIL_DESIGN IN (' + cRIL_DESIGN + ')'
		EndIf
	EndIf

	//-- Monta a string com as categorias a serem listadas
	If AllTrim( mv_par07 ) <> Replicate("*", Len(AllTrim( mv_par07 )))
		cRA_CATFUN   := ""
		For nCont  := 1 to Len(Alltrim(mv_par07)) Step nTRACATFUN
			If Substr(mv_par07, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par07, nCont, nTRACATFUN)))
				cRA_CATFUN += "'" + Substr(mv_par07, nCont, nTRACATFUN) + "',"
			EndIf
		Next
		cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)
	
		If ! Empty(AllTrim(cRA_CATFUN))
			cWhere += ' AND SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
		EndIf
	EndIf
	cWhere += "%"

	oFilial:BeginQuery()
	BeginSql Alias cAliasQRY
		COLUMN RIL_INICIO AS DATE
		COLUMN RIL_FINAL  AS DATE

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, RIL.RIL_INICIO, RIL.RIL_FINAL, RIL.RIL_NUMDOC, RIL.RIL_ANO
		  FROM %table:RIL% RIL
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = RIL.RIL_FILIAL AND SRA.RA_MAT = RIL.RIL_MAT 
		 WHERE RIL.%notDel% %Exp:cWhere%  
	 	 ORDER BY SRA.RA_FILIAL, SRA.RA_NOME
		
	EndSql
	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL })

	oFilial:Print()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ R410116BR ³ Autor ³ Wagner Mobile Costa    ³ Data ³ 27/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna lista de opções disponiveis para tabela S116  	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	   ³ R410116BR() 												        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	   ³ Generico 												        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function R410116BR(cMesAno)

Local aArea := GetArea(), aLista := {}, MvParDef := "", nTam := 0

CursorWait()

BeginSql Alias "QRY"
	SELECT SUBSTRING(RCC_CONTEU, 1, 3) AS RCC_CODIGO, SUBSTRING(RCC_CONTEU, 4, 100) AS RCC_CONTEU
	  FROM %table:RCC% RCC 
     WHERE RCC.%notDel% AND RCC.RCC_FILIAL = %Exp:xFilial("RCC")%  AND RCC_CODIGO = %Exp:'S116'%
       AND CASE WHEN RCC_FIL = %Exp:' '% THEN %Exp:cFilAnt% ELSE RCC_FIL END = %Exp:cFilAnt%
       AND RCC.R_E_C_N_O_ IN (%Exp:QryUtRCC({3}, Right(mv_par03, 4) + Left(mv_par03, 2))%)
     ORDER BY RCC_CODIGO 
EndSql


While !Eof()
	Aadd(aLista, AllTrim(RCC_CODIGO) + " - " + Left(RCC_CONTEU, 30))
	MvParDef += AllTrim(RCC_CODIGO)
	nTam := Len(AllTrim(RCC_CODIGO))
	dbSkip()
Enddo
CursorArrow()
QRY->(DbCloseArea())

MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

If f_Opcoes(@MvPar, STR0012, aLista, MvParDef, 12, 49, .F., nTam)	// 'Tipos de Designação'
	&MvRet := mvpar                                                                          // Devolve Resultado
EndIF

RestArea(aArea)

Return .T.

Static Function QryUtRCC(aTam, cAnoMes)
                                                                                                        
Local cQuery := "SELECT MAX(RCCR.R_E_C_N_O_) FROM " + RetSqlName("RCC") + " RCCR " +;
	               "JOIN (SELECT RCC_CODIGO AS COLUNA1, CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END AS COLUNA2, ", nTam := 1, nSoma := 0

Default cAnoMes := Str(Year(dDataBase), 4) + StrZero(Month(dDataBase), 2)

For nTam := 1 To Len(aTam)
	cQuery += "SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ") AS RCC_CONTE" + AllTrim(Str(nTam)) + ", "
	nSoma += aTam[nTam]
Next	

cQuery +=      "MAX(CASE WHEN RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCC_CHAVE END) AS RCC_CHAVE " +;
          "FROM " + RetSqlName("RCC") + " " +;
         "WHERE D_E_L_E_T_ = ' ' AND RCC_FILIAL = '" + xFilial("RCC") + "' " +;
         "GROUP BY RCC_CODIGO, CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END" 

nSoma := 0
For nTam := 1 To Len(aTam)
	cQuery += ", SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
	nSoma += aTam[nTam]
Next	

cQuery +=      ") RCCM ON RCCM.COLUNA1 = RCCR.RCC_CODIGO " +;
           "AND RCCM.COLUNA2 = CASE WHEN RCCR.RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCCR.RCC_FIL END " +;
           "AND RCCM.RCC_CHAVE = CASE WHEN RCCR.RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCCR.RCC_CHAVE END "

nSoma := 0
For nTam := 1 To Len(aTam)
	cQuery += " AND RCCM.RCC_CONTE" + AllTrim(Str(nTam)) + " = SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
	nSoma += aTam[nTam]
Next
           
cQuery += " WHERE RCCR.D_E_L_E_T_ = ' ' AND RCCR.RCC_FILIAL = '" + xFilial("RCC") + "' " +;
             "AND RCCR.RCC_CODIGO = RCC.RCC_CODIGO AND CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END = " +;
                                                      "CASE WHEN RCC.RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC.RCC_FIL END " +;
             "AND CASE WHEN RCCR.RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCCR.RCC_CHAVE END >= '" + cAnoMes + "' "
nSoma := 0
For nTam := 1 To Len(aTam)
	cQuery += " AND SUBSTRING(RCCR.RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ") = " +;
	               "SUBSTRING(RCC.RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")  
	nSoma += aTam[nTam]
Next

Return "%" + cQuery + "%"
