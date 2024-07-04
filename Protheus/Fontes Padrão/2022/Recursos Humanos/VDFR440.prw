#INCLUDE "VDFR440.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

/*/{Protheus.doc} VDFR440
Relatório da Lotacionograma
@author Wagner Mobile Costa
@version 11
@since 27/05/2014
@history 05/05/2015, Joao Balbino, TSFWOG - Corrigido erro na query que trazia registros duplicados.
@history 18/07/2018, silvia Taguti, DRHGFP-1034 - Upgrade V12.Retirada AjustaSX1
@return Nil
/*/
Function VDFR440()

	Local aRegs := {}

	Private oReport
	Private cString   := "RIL"
	Private cPerg	    := "VDFR440"
	Private cTitulo   := STR0001 //'Lotacionograma'
	Private nSeq 	    := 0, lSalta := .F.

	Pergunte(cPerg,.F.)

	M->RA_FILIAL := ""	// Controle de quebra de filial

	oReport := ReportDef()
	oReport:PrintDialog()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Montagem das definições do relatório
@sample 	ReportDef()
@author	    Wagner Mobile Costa
@since		27/05/2014
@version	P11.8
/*/
//-----------------------------------------------------------------------------
Static Function ReportDef()

	Local cDescri := STR0002 //O Relatório Semanal de toda movimentação de Servidores, membros, estagiários e terceirizados da empresa

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								.T.,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(lSalta := .F., oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0003, { "QRY" })  //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""
	oFilial:nLinesBefore   := 0

	TRCell():New(oFilial,"RA_FILIAL", "QRY")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> QRY->(RA_FILIAL + QB_DEPTO), (M->RA_FILIAL := QRY->(RA_FILIAL + QB_DEPTO), nSeq := 0), Nil),;
																			 fDesc("SM0", cEmpAnt + QRY->(RA_FILIAL), "M0_NOMECOM")) } )


	oDepto := TRSection():New(oFilial, 'Deptos',( "QRY" ))
	oDepto:cCharSeparator := ""
	TRCell():New(oDepto, "", "", 'Depto:',/*Picture*/,7 + Len(SQB->(QB_DEPTO + "-" + QB_DESCRIC))/*Tamanho*/,/*lPixel*/,;
					{|| 	If(M->RA_FILIAL <> QRY->(RA_FILIAL + QB_DEPTO), (M->RA_FILIAL := QRY->(RA_FILIAL + QB_DEPTO), nSeq := 0), Nil),;
							AllTrim(QRY->QB_DEPTO) + '-' + AllTrim(QRY->QB_DESCRIC) })

	oDepto:SetLineStyle()
	oDepto:nLinesBefore   := 0
	oDepto:bOnPrintLine := { || GerSup() }

	oFunc := TRSection():New(oDepto, STR0004, ( "QRY" )) //'Servidores'
	oFunc:nLinesBefore := 0
	oFunc:SetCellBorder("ALL",,, .T.)
	oFunc:SetCellBorder("RIGHT")
	oFunc:SetCellBorder("LEFT")
	oFunc:SetCellBorder("BOTTOM")

	nSeq := 0

	TRCell():New(oFunc,  '',           '',    'Nº', '9999', 4, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) }, "CENTER" ) //Para incluir o número(sequencial) na linha de impressão
	TRCell():New(oFunc, "RA_MAT",     	 "QRY", RetTitle("RA_MAT"))
	TRCell():New(oFunc, "RA_NOME",    	 "QRY", RetTitle("RA_NOME"),, 40)
	TRCell():New(oFunc, "RA_ADMISSA",   "QRY", STR0005 + " " + STR0016,,10, /*lPixel*/,/*bBlock*/, "CENTER") //DATA DE ADMISSÃO
	TRCell():New(oFunc, "Q3_DESCS_E", "QRY", STR0006,, 30)	//'Cargo Efetivo'
	TRCell():New(oFunc, "RBR_SIMB_E", "QRY", STR0007)	//'Simbolo Efetivo'
	TRCell():New(oFunc, "Q3_DESCSUM"  , "QRY", STR0008,, 30)	//'Cargo Comissionado'
	TRCell():New(oFunc, "RBR_SIMBOL"  , "QRY", STR0009,, 17)	//'Simbolo Comissionado'
	TRCell():New(oFunc, "OBSERVA"  , 	"QRY", STR0010,, 50)	//'Observação'

Return(oReport)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do conteúdo do relatório
@sample 	ReportPrint(oReport)
@author	    Wagner Mobile Costa
@since		27/05/2014
@version	P11.8
/*/
//-----------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local oFilial    := oReport:Section(1), oDepto := oReport:Section(1):Section(1), oFunc := oReport:Section(1):Section(1):Section(1)
Local oTmpTable	 := Nil
Local cWhere     := cWhereC := cWhereSRA := cWhereSQB := cWhereRILW := cFields := cFieldsSRA := cFieldsRIL := cFieldsSQB := "%"
Local cRA_CATFUN := cQ3_CARGO := cQ3_CARGO_E := cWhereRIL := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" )
Local lFechaP    := lOr := .F., nCont := 1, aStruct := {}
Local cFilSQB 	 := ""
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + StrTran(MV_PAR01, "RA_FILIAL", "SRA.RA_FILIAL")
	EndIf

	cWhereSQB := cWhere
	If !Empty(MV_PAR03)		//-- Lotacao
		cWhereSQB += " AND " + StrTran(MV_PAR03, "RA_DEPTO", "QB_DEPTO")
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cWhere += " AND " + MV_PAR02
	EndIf
	cWhereC := cWhere

	cQ3_CARGO_E := "CASE WHEN NOT SRA.RA_CATFUNC IN ('1', '6') OR SRA.RA_CATFUNC = '3' THEN COALESCE(SQ3E.Q3_CARGO, SQ3.Q3_CARGO) ELSE '' END"
	cQ3_CARGO   := "CASE WHEN SRA.RA_CATFUNC IN ('1', '3', '6') THEN SQ3.Q3_CARGO ELSE '' END"

	lFechaP := lOr := .F.
	If !Empty(MV_PAR05) .Or. ! Empty(MV_PAR06)
		cWhereC += " AND ("
		lFechaP := .T.
	EndIf

	If !Empty(MV_PAR05)			//-- Cargo Efetivo
		cWhereC += "(" + StrTran(MV_PAR05, "Q3_CARGO_E", cQ3_CARGO_E) + ")"

		If Empty(MV_PAR06)
			cWhereC += " OR (" + cQ3_CARGO + " <> ' ')"
		EndIf
		lOr := .T.
	EndIf

	If !Empty(MV_PAR06)		//-- Cargo Comissionado
		If lOr
			cWhereC += " OR "
		EndIF
		cWhereC += "(" + StrTran(MV_PAR06, "Q3_CARGO", cQ3_CARGO) + ")"

		If Empty(MV_PAR05)
			cWhereC += " OR (" + cQ3_CARGO_E + " <> ' ')"
		EndIf

	EndIf

	If lFechaP
		cWhereC += ")"
	EndIf

	If !Empty(MV_PAR01)		//-- Filial
		cWhereRIL += " AND " + StrTran(MV_PAR01, "RA_FILIAL", "RIL.RIL_FILIAL")
	EndIf

  	cWhereRIL += " AND (((RIL.RIL_INICIO >= '" + Left(Dtos(dDataBase), 6) + "01' " +;
   	                   "AND RIL.RIL_INICIO <= '" + Left(Dtos(dDataBase), 6) + "31')) OR " +;
  	                      "((RIL.RIL_FINAL >= '" + Left(Dtos(dDataBase), 6) + "01' " +;
  	                    "AND RIL.RIL_FINAL <= '" + Left(Dtos(dDataBase), 6) + "31') OR " +;
  	                        "(RIL.RIL_FINAL = '' AND RIL.RIL_INICIO <= '" + Left(Dtos(dDataBase), 6) + "31')))"
  	cWhereRILW := "%" + cWhereRIL + "%"

	cFields := "SRA.RA_FILIAL, SQB.QB_DEPTO, SQB.QB_DEPSUP, SQB.QB_DESCRIC, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA, " +;
				cQ3_CARGO_E + " AS Q3_CARGO_E, " +;
	            "CASE WHEN NOT SRA.RA_CATFUNC IN ('1', '6') OR SRA.RA_CATFUNC = '3' " +;
	                  "THEN COALESCE(SQ3E.Q3_DESCSUM, SQ3.Q3_DESCSUM) ELSE '' END AS Q3_DESCS_E, " +;
	            "CASE WHEN NOT SRA.RA_CATFUNC IN ('1', '6')  OR SRA.RA_CATFUNC = '3'" +;
	                  "THEN COALESCE(RBRE.RBR_SIMBOL, RBR.RBR_SIMBOL) ELSE '' END AS RBR_SIMB_E, " + cQ3_CARGO + " AS Q3_CARGO, " +;
	            "CASE WHEN SRA.RA_CATFUNC IN ('1', '3', '6') THEN SQ3.Q3_DESCSUM ELSE '' END AS Q3_DESCSUM, " +;
	            "CASE WHEN SRA.RA_CATFUNC IN ('1', '3', '6') THEN RBR.RBR_SIMBOL ELSE '' END AS RBR_SIMBOL, " +;
	            "CASE WHEN SRA.RA_CATFUNC IN ('1', '3', '6') " +;
	                  "THEN SQ3.Q3_PRIORL ELSE COALESCE(SQ3E.Q3_PRIORL, SQ3.Q3_PRIORL) END AS Q3_PRIORL, "

	cFieldsSRA += cFields + " COALESCE((SELECT MAX('" + STR0011 + "') FROM " + RetSqlName("RIL") + " RIL " +;
                                             "WHERE D_E_L_E_T_ = ' ' AND RIL_FILIAL = SRA.RA_FILIAL AND RIL_MAT = SRA.RA_MAT " +;
	 			                                     cWhereRIL + "), CASE WHEN SQB.QB_FILTIT + SQB.QB_MATTIT = SRA.RA_FILIAL + SRA.RA_MAT " +;
	 			                                                            "THEN '" + STR0012 + "' + SQB.QB_DESCRIC ELSE '' END,  '') AS OBSERVA%"

	cFieldsRIL += cFields + " COALESCE(CASE WHEN SQBF.QB_FILTIT + SQBF.QB_MATTIT = SRA.RA_FILIAL + SRA.RA_MAT " +;
	 			                                                            "THEN '" + STR0012 + "' + SQBF.QB_DESCRIC ELSE NULL END, " +;
	 			                          "(SELECT MAX('" + STR0015 + "') FROM " + RetSqlName("RIL") + " RIL " +;		//## 'Em Designação'
                                             "WHERE D_E_L_E_T_ = ' ' AND RIL_FILIAL = SRA.RA_FILIAL AND RIL_MAT = SRA.RA_MAT " +;
	 			                                     cWhereRIL + "), '') AS OBSERVA%"

	cFieldsSQB += "SQB.QB_FILIAL AS RA_FILIAL, SQB.QB_DEPTO, SQB.QB_DEPSUP, SQB.QB_DESCRIC, ' ' AS RA_MAT, '' AS RA_NOME, '' AS RA_ADMISSA, " +;
   				   "' ' AS Q3_CARGO_E, ' ' AS Q3_DESCS_E, ' ' AS RBR_SIMB_E, ' ' AS Q3_CARGO, ' ' AS Q3_DESCSUM, ' ' AS RBR_SIMBOL, " +;
   				   "' ' AS Q3_PRIORL, '" + STR0013 + "' AS OBSERVA%"

	If Upper(TcGetDb()) $ "DB2_ORACLE_INFORMIX_POSTGRES"
		cFieldsSRA := StrTran(cFieldsSRA, "+", "||")
		cFieldsRIL := StrTran(cFieldsRIL, "+", "||")
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
			cWhereC += ' AND SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
		EndIf
	EndIf

	//-- Filtro funcionários e designados
	cWhereSRA := cWhereC
	cWhereRIL := cWhereC
	If !Empty(MV_PAR03)		//-- Lotacao
		cWhereSRA += " AND " + MV_PAR03
		cWhereRIL += " AND " + StrTran(MV_PAR03, "RA_DEPTO", "RIL_DEPTO")
	EndIf

	//Fecha as condições
	cWhere    += "%"
	cWhereC   += "%"
	cWhereSRA += "%"
	cWhereRIL += "%"
	cWhereSQB += "%"

	aStruct := { 	{ "RA_FILIAL", "C", Len(SRA->RA_FILIAL), 0 }, { "NIVEL", "N", 2, 0 }, { "QB_DEPTO", "C", Len(SQB->QB_DEPTO), 0 },;
					{ "QB_DEPSUP", "C", Len(SQB->QB_DEPSUP), 0 }, { "QB_DESCRIC", "C", Len(SQB->QB_DESCRIC), 0 }, { "RA_MAT", "C", Len(SRA->RA_MAT), 0 },;
					{ "RA_NOME", "C", Len(SRA->RA_NOME), 0 }, { "RA_ADMISSA", "D", 8, 0 }, { "Q3_DESCS_E", "C", Len(SQ3->Q3_DESCSUM), 0 },;
					{ "RBR_SIMB_E", "C", Len(RBR->RBR_SIMBOL), 0 }, { "Q3_DESCSUM", "C", Len(SQ3->Q3_DESCSUM), 0 },;
					{ "RBR_SIMBOL", "C", Len(RBR->RBR_SIMBOL), 0 }, { "Q3_PRIORL", "C", Len(SQ3->Q3_PRIORL), 0 },;
					{ "OBSERVA", "C", 70, 0 } }

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIF

	If Select("QRYLOT") > 0
		QRYLOT->(DbCloseArea())
	EndIF

	oTmpTable := FWTemporaryTable():New("QRY")
	oTmpTable:SetFields( aStruct )
	oTmpTable:AddIndex( "IND", {"RA_FILIAL","NIVEL", "QB_DEPTO", "Q3_PRIORL","RA_NOME"} )
	oTmpTable:Create()

	BeginSql Alias "QRYLOT"
	   COLUMN RA_ADMISSA AS DATE

	    SELECT DISTINCT %Exp:cFieldsSRA%
  		   FROM %table:SRA% SRA
         JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = SRA.RA_DEPTO
         LEFT JOIN (SELECT SR7.R7_FILIAL, SR7.R7_MAT, SRA.RA_CARGO, SR7.R7_ECARGO, MAX(SR7.R7_DATA) AS R7_DATA
                       FROM %table:SR7% SR7
   	                   JOIN %table:SRA% SRA ON SRA.%notdel% %Exp:cWhere% AND SRA.RA_DEMISSA = %Exp:' '% AND SRA.RA_FILIAL = SR7.R7_FILIAL AND SRA.RA_MAT = SR7.R7_MAT
                      WHERE SR7.%notdel%
                        AND SR7.R_E_C_N_O_ IN (SELECT MAX(SR7X.R_E_C_N_O_) FROM %table:SR7% SR7X
                                                 JOIN %table:SRA% SRAX ON SRAX.%notdel% AND SRAX.RA_FILIAL = SR7X.R7_FILIAL AND SRAX.RA_MAT = SR7X.R7_MAT
                                                WHERE SR7X.%notdel%  AND SR7X.R7_FILIAL = SR7.R7_FILIAL AND SR7X.R7_MAT = SR7.R7_MAT
                                                  AND SR7X.R7_SEQ = SR7.R7_SEQ AND SR7X.R7_DATA <= SR7.R7_DATA)
                  GROUP BY SR7.R7_FILIAL, SR7.R7_MAT, SRA.RA_CARGO, SR7.R7_ECARGO) SR7 ON SR7.R7_FILIAL = SRA.RA_FILIAL AND SR7.R7_MAT = SRA.RA_MAT
         LEFT JOIN %table:SQ3% SQ3 ON SQ3.%notdel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
         LEFT JOIN %table:SQ3% SQ3E ON SQ3E.%notdel% AND SQ3E.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3E.Q3_CARGO = SR7.R7_ECARGO
         LEFT JOIN (SELECT RBR.RBR_TABELA, RBR.RBR_DESCTA, RBR.RBR_SIMBOL
                       FROM %table:RBR% RBR
                      WHERE RBR.%notdel% AND RBR.RBR_FILIAL = %Exp:xFilial("RBR")%
                        AND RBR.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:RBR% RBRM WHERE RBRM.%notdel% AND RBRM.RBR_FILIAL = RBR.RBR_FILIAL
                                                     AND RBRM.RBR_TABELA = RBR.RBR_TABELA
                                                     AND RBRM.RBR_DTREF < %Exp:Dtos(dDataBase)%)) RBR ON RBR.RBR_TABELA = SQ3.Q3_TABELA
         LEFT JOIN (SELECT RBR.RBR_TABELA, RBR.RBR_DESCTA, RBR.RBR_SIMBOL
                       FROM %table:RBR% RBR
                      WHERE RBR.%notdel% AND RBR.RBR_FILIAL = %Exp:xFilial("RBR")%
                        AND RBR.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:RBR% RBRM WHERE RBRM.%notdel% AND RBRM.RBR_FILIAL = RBR.RBR_FILIAL
                                                     AND RBRM.RBR_TABELA = RBR.RBR_TABELA
                                                     AND RBRM.RBR_DTREF < %Exp:Dtos(dDataBase)%)) RBRE ON RBRE.RBR_TABELA = SQ3E.Q3_TABELA
        WHERE SRA.%notdel% %Exp:cWhereSRA% AND SRA.RA_DEMISSA = %Exp:' '%
        UNION ALL
       SELECT DISTINCT  %Exp:cFieldsRIL%
         FROM (SELECT RIL_FILIAL, RIL_MAT, RIL_INICIO, RIL_DESIGN
                  FROM %table:RIL% RIL
                 WHERE %notdel% %Exp:cWhereRILW%
                 GROUP BY RIL_FILIAL, RIL_MAT, RIL_INICIO, RIL_DESIGN) RILM
         JOIN %table:RIL% RIL ON RIL.%notdel% AND RIL.RIL_FILIAL = RILM.RIL_FILIAL AND RIL.RIL_MAT = RILM.RIL_MAT AND RIL.RIL_INICIO = RILM.RIL_INICIO
          AND RIL.RIL_DESIGN = RILM.RIL_DESIGN
  		 JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = RIL.RIL_FILIAL AND SRA.RA_MAT = RIL.RIL_MAT
         JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = RIL.RIL_DEPTO
         JOIN %table:SQB% SQBF ON SQBF.%notDel% AND SQBF.QB_FILIAL = %Exp:xFilial("SQB")% AND SQBF.QB_DEPTO = SRA.RA_DEPTO
         LEFT JOIN (SELECT SR7.R7_FILIAL, SR7.R7_MAT, SRA.RA_CARGO, SR7.R7_ECARGO, MAX(SR7.R7_DATA) AS R7_DATA
                       FROM %table:SR7% SR7
   	                   JOIN %table:SRA% SRA ON SRA.%notdel% %Exp:cWhere% AND SRA.RA_DEMISSA = %Exp:' '% AND SRA.RA_FILIAL = SR7.R7_FILIAL AND SRA.RA_MAT = SR7.R7_MAT
                      WHERE SR7.%notdel%
                        AND SR7.R_E_C_N_O_ IN (SELECT MAX(SR7X.R_E_C_N_O_) FROM %table:SR7% SR7X
                                                 JOIN %table:SRA% SRAX ON SRAX.%notdel% AND SRAX.RA_FILIAL = SR7X.R7_FILIAL AND SRAX.RA_MAT = SR7X.R7_MAT
                                                WHERE SR7X.%notdel%  AND SR7X.R7_FILIAL = SR7.R7_FILIAL AND SR7X.R7_MAT = SR7.R7_MAT
                                                  AND SR7X.R7_SEQ = SR7.R7_SEQ AND SR7X.R7_DATA <= SR7.R7_DATA)
                  GROUP BY SR7.R7_FILIAL, SR7.R7_MAT, SRA.RA_CARGO, SR7.R7_ECARGO) SR7 ON SR7.R7_FILIAL = SRA.RA_FILIAL AND SR7.R7_MAT = SRA.RA_MAT
         LEFT JOIN %table:SQ3% SQ3 ON SQ3.%notdel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
         LEFT JOIN %table:SQ3% SQ3E ON SQ3E.%notdel% AND SQ3E.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3E.Q3_CARGO = SR7.R7_ECARGO
         LEFT JOIN (SELECT RBR.RBR_TABELA, RBR.RBR_DESCTA, RBR.RBR_SIMBOL
                       FROM %table:RBR% RBR
                      WHERE RBR.%notdel% AND RBR.RBR_FILIAL = %Exp:xFilial("RBR")%
                        AND RBR.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:RBR% RBRM WHERE RBRM.%notdel% AND RBRM.RBR_FILIAL = RBR.RBR_FILIAL
                                                     AND RBRM.RBR_TABELA = RBR.RBR_TABELA
                                                     AND RBRM.RBR_DTREF < %Exp:Dtos(dDataBase)%)) RBR ON RBR.RBR_TABELA = SQ3.Q3_TABELA
         LEFT JOIN (SELECT RBR.RBR_TABELA, RBR.RBR_DESCTA, RBR.RBR_SIMBOL
                       FROM %table:RBR% RBR
                      WHERE RBR.%notdel% AND RBR.RBR_FILIAL = %Exp:xFilial("RBR")%
                        AND RBR.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:RBR% RBRM WHERE RBRM.%notdel% AND RBRM.RBR_FILIAL = RBR.RBR_FILIAL
                                                     AND RBRM.RBR_TABELA = RBR.RBR_TABELA
                                                     AND RBRM.RBR_DTREF < %Exp:Dtos(dDataBase)%)) RBRE ON RBRE.RBR_TABELA = SQ3E.Q3_TABELA
        WHERE SRA.%notdel% %Exp:cWhereRIL% AND SRA.RA_DEMISSA = %Exp:' '%
        ORDER BY RA_FILIAL, QB_DEPTO, Q3_PRIORL, RA_NOME
	EndSql

	MsAguarde({|| LoadRep(cWhereRILW) }, cTitulo,STR0014,.T.)		//'Montando a consulta. Aguarde ..

    if mv_par04 == 1		//-- Gera lotações sem servidores
		cWhereSQB := "%"
		cWhereSRA := "%"
		If !Empty(MV_PAR01)		//-- Filial
			cWhereSRA += " AND " + StrTran(MV_PAR01, "RA_FILIAL", "SRA.RA_FILIAL")
		EndIf

		If !Empty(MV_PAR03)		//-- Lotacao
			cWhereSQB += " AND " + StrTran(MV_PAR03, "RA_DEPTO", "QB_DEPTO")
		EndIf

		cWhereSRA += "%"
		cWhereSQB += "%"
		cFilSQB	  := "%" + FWJoinFilial("SRA", "SQB") + "%"

		BeginSql Alias "QRYLOT"
		   COLUMN RA_ADMISSA AS DATE

	       SELECT %Exp:cFieldsSQB%
	         FROM %table:SQB% SQB
	         LEFT JOIN %table:SRA% SRA ON %EXP:cFilSQB% AND SQB.QB_DEPTO = SRA.RA_DEPTO
	        WHERE SQB.%notDel% %Exp:cWhereSQB% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SRA.RA_DEPTO IS NULL
		EndSql

		MsAguarde({|| LoadRep("") }, cTitulo,STR0014,.T.)		//'Montando a consulta. Aguarde ..
	EndIf

	DbSelectArea("QRY")

	oDepto:SetParentFilter({|cParam| QRY->RA_FILIAL == cParam}, {|| QRY->RA_FILIAL })

	oFunc:SetParentFilter({|cParam| QRY->(RA_FILIAL + QB_DEPTO) == cParam}, {|| QRY->(RA_FILIAL + QB_DEPTO) })

	oFilial:Print()
	QRY->(DbCloseArea())

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadRep
Carrega os dados do alias "QRYLOT" para "QRY"
@sample 	LoadRep(cWhereRIL)
@author	    Wagner Mobile Costa
@since		10/06/2014
@version	P11.8
/*/
//-----------------------------------------------------------------------------
Static Function LoadRep(cWhereRIL)

Local cAux := ""

While ! QRYLOT->(Eof())

	RecLock("QRY", .T.)
	QRY->RA_FILIAL  := QRYLOT->RA_FILIAL
	QRY->QB_DEPTO   := QRYLOT->QB_DEPTO
	QRY->QB_DEPSUP  := QRYLOT->QB_DEPSUP
	QRY->QB_DESCRIC := QRYLOT->QB_DESCRIC
	QRY->RA_MAT     := QRYLOT->RA_MAT
	QRY->RA_NOME    := QRYLOT->RA_NOME
	QRY->RA_ADMISSA := QRYLOT->RA_ADMISSA
	QRY->Q3_DESCS_E := QRYLOT->Q3_DESCS_E
	QRY->RBR_SIMB_E := QRYLOT->RBR_SIMB_E
	QRY->Q3_DESCSUM := QRYLOT->Q3_DESCSUM
	QRY->RBR_SIMBOL := QRYLOT->RBR_SIMBOL
	QRY->Q3_PRIORL  := QRYLOT->Q3_PRIORL
	QRY->OBSERVA    := QRYLOT->OBSERVA

	//-- Tratamento para preencher todas as designacoes do periodo
	If AllTrim(QRY->OBSERVA) = AllTrim(STR0011) .And. ! Empty(cWhereRil)
		cAux := ""

		BeginSql Alias "QRYRIL"
			SELECT RIL_CARGO FROM %table:RIL% RIL
             WHERE %notdel% %Exp:cWhereRIL% AND RIL_FILIAL = %Exp:QRYLOT->RA_FILIAL% AND RIL_MAT = %Exp:QRYLOT->RA_MAT%
             ORDER BY RIL_INICIO, RIL_DESIGN
		EndSql

		While ! QRYRIL->(Eof())
			If Empty(cAux)
				cAux := STR0011
			Else
				cAux += ","
			EndIf

			cAux += AllTrim(QRYRIL->RIL_CARGO)

			QRYRIL->(DbSkip())
		EndDo

		QRYRIL->(DbCloseArea())

		QRY->OBSERVA := cAux
	EndIf

	QRY->(MsUnLock())

	QRYLOT->(DbSkip())
EndDo
QRYLOT->(DbCloseArea())

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GerSup
Gera os departamentos superiores
@sample 	GerSup()
@author	    Wagner Mobile Costa
@since		29/05/2014
@version	P11.8
/*/
//-----------------------------------------------------------------------------
Static Function GerSup()

Local aArea    := GetArea(), aDepto := {}, nDepto := nPrint := 1

cQB_Depto := QRY->QB_DEPTO
cQB_DESCRIC := AllTrim(QRY->QB_DESCRIC)
cQB_DEPSUP := QRY->QB_DEPSUP

Aadd(aDepto, 'Depto: ' + AllTrim(cQB_DEPTO) + '-' + cQB_DESCRIC)

If !Empty(cQB_DEPSUP)
	BeginSql Alias "QRYSUP"
		SELECT QB_DESCRIC, QB_DEPSUP
	      FROM %table:SQB%
	     WHERE %notdel% AND QB_FILIAL = %Exp:xFilial("SQB")% AND QB_DEPTO = %Exp:cQB_DEPSUP%
	EndSql
	If ! QRYSUP->(Eof())
		cQB_DEPTO   := cQB_DEPSUP
		cQB_DESCRIC := QRYSUP->QB_DESCRIC
		cQB_DEPSUP  := QRYSUP->QB_DEPSUP
		Aadd(aDepto, 'Depto: ' + AllTrim(cQB_DEPTO) + '-' + cQB_DESCRIC)
	EndIf
	QRYSUP->(DbCloseArea())
EndIf

If lSalta
	oReport:PrintText("")
EndIf

nDepto := Len(aDepto)
If nDepto > mv_par08
	nDepto := mv_par08
EndIf
While nDepto > 0
	oReport:PrintText(aDepto[nDepto])
	nPrint ++
	nDepto --
	If nPrint > mv_par08
		Exit
	EndIf
EndDo

RestArea(aArea)
lSalta := .T.

Return .F.