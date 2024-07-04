#INCLUDE "VDFR390.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

/*/{Protheus.doc} VDFR390
Relatório por exercício de Difícil Provimento.
@author Wagner Mobile Costa
@version 11
@since 30/03/2014
@return Nil
/*/
Function VDFR390()

Local lValido	:= .F.
Local cMsg		:= ""

Private oReport
Private cString		:= "RIK"
Private cPerg	    := "VDFR390"
Private cTitulo		:= STR0001 //'Relatório por exercício de Difícil Provimento'
Private nSeq 	    := 0

	M->RA_FILIAL := ""	// Variavel para controle da numeração

	If ! Pergunte(cPerg, .T.)
		Return
	EndIf

	//Valida se o campo Categoria foi preenchido
	While !lValido
		If Val(Substr(MV_PAR03,1,2)) < 1 .OR. Val(Substr(MV_PAR03,1,2)) > 12
			cMsg += STR0016 + STR0017 + " - " + STR0018 + MV_PAR03 + CRLF + CRLF//"Período de: "##"Mês informado inválido. Informe um mês entre 01 e 12."##"Valor informado: "
		EndIf
		If Val(Substr(MV_PAR04,1,2)) < 1 .OR. Val(Substr(MV_PAR04,1,2)) > 12
			cMsg += STR0019 + STR0017 + " - " + STR0018 + MV_PAR04 + CRLF + CRLF//"Período até: "##"Mês informado inválido. Informe um mês entre 01 e 12."##"Valor informado: "
		EndIf
		If Empty(MV_PAR06) .OR. AllTrim( MV_PAR06 ) == Replicate("*", Len(AllTrim( MV_PAR06 )))
			cMsg += STR0020 + STR0015 //"Categorias: "##"Informe pelo menos 1 categoria!"
		EndIf
		If Empty(cMsg)
			lValido := .T.
		Else
			MsgAlert(cMsg)
			cMsg := ""
			If ! Pergunte(cPerg, .T.)
				Return
			EndIf
		EndIf
	EndDo

	oReport := ReportDef()
	oReport:PrintDialog()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Montagem das definições do relatório.
@sample 	ReportDef()
@author	    Wagner Mobile Costa
@since		30/03/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ReportDef()

	Local cDescri := STR0002 //"O Relatório por exercício de Difícil Provimento visa listar os membros que estiveram ou estão em comarcas de difícil provimento."

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 3)
	oReport:nFontBody := 7

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0003, { "QRY" })  //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	TRCell():New(oFilial,"RA_FILIAL","QRY")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> QRY->RA_FILIAL, (M->RA_FILIAL := QRY->RA_FILIAL, nSeq := 0), Nil),;
																	 fDesc("SM0", cEmpAnt + QRY->(RA_FILIAL), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0004, ( "QRY" )) //'Servidores'

	nSeq := 0

	TRCell():New(oFunc,  '',          '',    'Nº', '99999', 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão
	TRCell():New(oFunc, 'RA_MAT',     'QRY', STR0005) //'Matricula'
	TRCell():New(oFunc, 'RA_NOME',    'QRY', STR0006,, 40) //'Nome'
	TRCell():New(oFunc, 'QB_DESCRIC', 'QRY', STR0007,, 40 ) //'Lotação'
	TRCell():New(oFunc, 'RI8_PERCEN', 'QRY', STR0009 + Chr(13) + Chr(10) + STR0010,'999999999.99', 12 ) //'Porcentagem'###'Subsidio'
	TRCell():New(oFunc, 'RI8_DATADE', 'QRY', STR0012 + Chr(13) + Chr(10) + STR0011 ) //'Período'###'Inicial'
	TRCell():New(oFunc, 'RI8_DATATE', 'QRY', STR0012 + Chr(13) + Chr(10) + STR0013 ) //'Período'###'Final'

	oFunc:Cell("RI8_DATADE"):lAutoSize	:= .F.
	oFunc:Cell("RI8_DATATE"):lAutoSize	:= .F.
	oFunc:Cell("RI8_PERCEN"):lAutoSize	:= .F.
	oFunc:Cell("RA_MAT"):lAutoSize 		:= .F.
	oFunc:Cell("RA_NOME"):lAutoSize		:= .T.
	oFunc:Cell("QB_DESCRIC"):lAutoSize	:= .T.

Return(oReport)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do conteúdo do relatório.
@sample 	ReportPrint(oReport)
@author	    Wagner Mobile Costa
@since		31/03/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local nCont   := 0, cRIK_COD := "", nRIK_COD := GetSx3Cache( "RIK_COD", "X3_TAMANHO" )
Local oFilial := oReport:Section(1), oFunc := oReport:Section(1):Section(1), cWhere := cWhereD := cWhereM := cWhereRIK := "%"
Local cPerIni := mv_par03, cPerFim := mv_par04, cRA_CATFUN := cAux := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" )
Local cSQBJoin := fTbJoinSQL("SQB", "SRA","%")
Local cSREJoin := Replace(fTbJoinSQL("SQB", "SRE","%"),"RE_FILIAL","RE_FILIALP")
Local cMesAnoPer := "" //variavel para manipulacao dos campos RIK_PERIOD e RIK_PERIOA

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cWhere += " AND " + MV_PAR02
	EndIf

	//-- Monta a string com as categorias a serem listadas
	If AllTrim( mv_par06 ) <> Replicate("*", Len(AllTrim( mv_par06 )))
		cRA_CATFUN := ""
		For nCont  := 1 to Len(Alltrim(mv_par06)) Step nTRACATFUN
			If Substr(mv_par06, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par06, nCont, nTRACATFUN)))
				cRA_CATFUN += "'" + Substr(mv_par06, nCont, nTRACATFUN) + "',"
			EndIf
		Next
		cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)

		If ! Empty(AllTrim(cRA_CATFUN))
			cWhere += ' AND SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
		EndIf
	EndIf

  	cWhereRIK += " AND ("
  	If Empty(cPerIni)
		cPerIni := "000000"
  	EndIf
  	If Empty(cPerFim)
		cPerFim := "999999"
  	EndIf

  	cWhereRIK += "((RIK_PERIOD >= '" + Right(cPerIni, 4) + Left(cPerIni, 2) + "' " +;
	           "AND RIK_PERIOD <= '" + Right(cPerFim, 4) + Left(cPerFim, 2) + "') OR RIK_PERIOD = '') OR " +;
 	             "((RIK_PERIOD >= '" + Right(cPerIni, 4) + Left(cPerIni, 2) + "' " +;
  	           "AND RIK_PERIOD <= '" + Right(cPerFim, 4) + Left(cPerFim, 2) + "') OR RIK_PERIOD = ''))"

	If Upper(TcGetDb()) $ "DB2_ORACLE_INFORMIX_POSTGRES"
		cWhereRIK := StrTran(cWhereRIK, "+", "||")
	EndIf

	//-- Monta a string de Codigos de Verba
	If AllTrim( mv_par05 ) <> Replicate("*", Len(AllTrim( mv_par05 )))
		cRIK_COD   := ""
		For nCont  := 1 to Len(Alltrim(mv_par05)) Step nRIK_COD
			cRIK_COD += "'" + Substr(mv_par05, nCont, nRIK_COD) + "',"
		Next
		cRIK_COD := Substr( cRIK_COD, 1, Len(cRIK_COD)-1)
		If !Empty(AllTrim(cRIK_COD))
			cWhereRIK += ' AND RIK.RIK_COD IN (' + cRIK_COD + ')'
		EndIf
	EndIf

	//-- Monta a string com as categorias a serem listadas
	If AllTrim( mv_par06 ) <> Replicate("*", Len(AllTrim( mv_par06 )))
		cAux := ""
		For nCont  := 1 to Len(Alltrim(mv_par06)) Step nTRACATFUN
			If Substr(mv_par06, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par06, nCont, nTRACATFUN)))
				If ! Empty(cAux)
					cAux += " OR "
				EndIf
				cAux += "RIK.RIK_CATEG LIKE '%" + Substr(mv_par06, nCont, nTRACATFUN) + "%'"
			EndIf
		Next

		If ! Empty(AllTrim(cAux))
		 	cWhereRIK += " AND (" + cAux + ")"
		EndIf
	EndIf

	cWhereRIK += "%"

	aStruct := { 	{ "RA_FILIAL", "C", Len(SRA->RA_FILIAL), 0 }, { "RA_MAT", "C", Len(SRA->RA_MAT), 0 }, { "RA_NOME", "C", Len(SRA->RA_NOME), 0 },;
					{ "RA_CODFUNC", "C", Len(SRA->RA_CODFUNC), 0 }, { "QB_DEPTO", "C", Len(SQB->QB_DEPTO), 0 },;
	      			{ "QB_DESCRIC", "C", Len(SQB->QB_DESCRIC), 0 }, { "QB_COMARC", "C", Len(SQB->QB_COMARC), 0 },;
	      			{ "RI8_PERCEN", "N", 10, 2 }, { "RI8_DATADE", "D", 8, 0 }, { "RI8_DATATE", "D", 8, 0 }}
	oTmpTable := FWTemporaryTable():New("QRY")
	oTmpTable:SetFields( aStruct )
	oTmpTable:AddIndex( "IND", {"RA_FILIAL","RA_NOME"} ) // Cria o arquivo de indice para a tabela temporaria
	oTmpTable:Create() // Disponibiliza a tabela temporária para uso pelo programa

	BeginSql Alias "QRYRIK"
		SELECT RIK_COD, RIK_DESC, RIK_PERCEN, RIK_PERIOD, RIK_PERIOA, RIK_FUNCC, RIK_FUNCD, RIK_DEPTOC, RIK_DEPTOD, RIK_COMARC, RIK_COMARD,
		        RIK_CATEG
		  FROM %table:RIK% RIK
	     WHERE RIK.%notDel% %Exp:cWhereRIK%
	  ORDER BY RIK_COD
	EndSql

	While ! QRYRIK->(Eof())
		//-- Se um dos campos desconsiderar todos pula esta linha
		If AllTrim(QRYRIK->RIK_FUNCD) == "*" .Or. AllTrim(QRYRIK->RIK_COMARD) == "*" .Or. QRYRIK->RIK_PERCEN == 0
			QRYRIK->(DbSkip())
			Loop
		EndIf

		// RIK_FUNCC  e RIK_FUNCD 	(Função Considerar e Desconsiderar)
		// RIK_DEPTOC e RIK_DEPTOD  (Departamento Considerar e Desconsiderar)
		// RIK_COMARC e RIK_COMARD  (Comarca Considerar e Desconsiderar)

		// Filtro para Admissão
		cWhereD := cWhere

		//-- Monta a string com as categorias definidas na RIK
		cAux := AllTrim( QRYRIK->RIK_CATEG )
		cRA_CATFUN := ""
		If cAux <> Replicate("*", Len(cAux))
			For nCont  := 1 to Len(Alltrim(mv_par06)) Step nTRACATFUN
				If Substr(cAux, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(cAux, nCont, nTRACATFUN))) .And.;
																	   ! Empty(Substr(cAux, nCont, nTRACATFUN))
					If ! Empty(cRA_CATFUN)
						cRA_CATFUN += ", "
					EndIf
					cRA_CATFUN += "'" + Substr(cAux, nCont, nTRACATFUN) + "'"
				EndIf
			Next

			If ! Empty(AllTrim(cRA_CATFUN))
			 	cWhereD += " AND SRA.RA_CATFUNC IN (" + cRA_CATFUN + ")"
			EndIf
		EndIf

		cWhereD += "%"

		// Filtro para Mudança de Comarca
		cWhereM := cWhere

		//-- Monta a string com as categorias definidas na RIK
		If ! Empty(cRA_CATFUN)
			cWhereM += " AND SRA.RA_CATFUNC IN (" + cRA_CATFUN + ")"
		EndIf

		cWhereM += "%"
		cRA_CATFUN := '% IN (' + cRA_CATFUN + ')%'

		BeginSql Alias "QRYD"
			COLUMN RA_ADMISSA	AS DATE
			COLUMN RE_DATA    	AS DATE
			COLUMN RA_DEMISSA	AS DATE

			SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CODFUNC, SQB.QB_DEPTO, SQB.QB_DESCRIC, SQB.QB_COMARC,
			       COALESCE((SELECT MAX(RE_DATA) FROM %table:SRE%
                                WHERE %notDel% AND RE_EMPP = %Exp:cEmpAnt%  AND RE_FILIALP = SRE.RE_FILIALP
                                  AND RE_MATP = SRE.RE_MATP AND RE_DATA < SRE.RE_DATA),
			                 (SELECT MIN(RE_DATA) FROM %table:SRE% WHERE %notDel% AND RE_EMPP = %Exp:cEmpAnt% AND RE_FILIALP = SRA.RA_FILIAL
			                    AND RE_MATP = SRA.RA_MAT AND RE_FILIALD <> RE_FILIALP), SRA.RA_ADMISSA) AS RA_ADMISSA, SRA.RA_DEMISSA
			  FROM %table:SRA% SRA
		 LEFT JOIN (SELECT RE_FILIALP, RE_MATP, RE_DEPTOD, MIN(RE_DATA) AS RE_DATA
	                  FROM %table:SRE% SRE
	                 WHERE %notDel% AND RE_EMPP = %Exp:cEmpAnt%
                       AND R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:SRE%
                                           WHERE %notDel% AND RE_EMPP = %Exp:cEmpAnt%  AND RE_FILIALP = SRE.RE_FILIALP
                                             AND RE_MATP = SRE.RE_MATP AND RE_DATA <= SRE.RE_DATA)
                     GROUP BY RE_FILIALP, RE_MATP, RE_DEPTOD) SRE ON SRE.RE_FILIALP = SRA.RA_FILIAL AND SRE.RE_MATP = SRA.RA_MAT
			  JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cSQBJoin% AND SQB.QB_DEPTO = COALESCE(SRE.RE_DEPTOD, SRA.RA_DEPTO)
		     WHERE SRA.%notDel% %Exp:cWhereD%
		     UNION
			SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME,
					COALESCE((SELECT MAX(R7_FUNCAO) FROM %table:SR7% SR7
    	              			 WHERE %notDel% AND R7_FILIAL = SR7.R7_FILIAL AND R7_MAT = SR7.R7_MAT AND SR7.R7_DATA <= SRE.RE_DATA
        	                       AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_)
        	                                             FROM %table:SR7%
       	                                                WHERE %notDel% AND R7_FILIAL = SR7.R7_FILIAL
            	                                          AND R7_MAT = SR7.R7_MAT AND R7_SEQ = SR7.R7_SEQ AND R7_TIPO = SR7.R7_TIPO
            	                                          AND R7_DATA = (SELECT MAX(R7_DATA) FROM %table:SR7%
            	                                                            WHERE %notDel% AND R7_FILIAL = SR7.R7_FILIAL
            	                                                              AND R7_MAT = SR7.R7_MAT AND R7_SEQ = SR7.R7_SEQ AND R7_TIPO = SR7.R7_TIPO
            	                                                              AND R7_DATA <= SRE.RE_DATA))), SRA.RA_CODFUNC) AS RA_CODFUNC,
					SQB.QB_DEPTO, SQB.QB_DESCRIC, SQB.QB_COMARC, SRE.RE_DATA, SRA.RA_DEMISSA
			  FROM %table:SRE% SRE
			  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SRE.RE_FILIALP AND SRA.RA_MAT = SRE.RE_MATP
			  JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cSREJoin% AND SQB.QB_DEPTO = SRE.RE_DEPTOP
		     WHERE SRE.%notDel% %Exp:cWhereM% AND SRE.RE_EMPP = %Exp:cEmpAnt% AND SRE.RE_FILIALD = SRE.RE_FILIALP AND SRE.RE_DEPTOD <> SRE.RE_DEPTOP
		       AND COALESCE((SELECT MAX(R7_CATFUNC) FROM %table:SR7% SR7
    	              			 WHERE %notDel% AND R7_FILIAL = SR7.R7_FILIAL AND R7_MAT = SR7.R7_MAT AND SR7.R7_DATA <= SRE.RE_DATA
        	                       AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_)
        	                                             FROM %table:SR7%
       	                                                WHERE %notDel% AND R7_FILIAL = SR7.R7_FILIAL
            	                                          AND R7_MAT = SR7.R7_MAT AND R7_SEQ = SR7.R7_SEQ AND R7_TIPO = SR7.R7_TIPO
            	                                          AND R7_DATA = (SELECT MAX(R7_DATA) FROM %table:SR7%
            	                                                            WHERE %notDel% AND R7_FILIAL = SR7.R7_FILIAL
            	                                                              AND R7_MAT = SR7.R7_MAT AND R7_SEQ = SR7.R7_SEQ AND R7_TIPO = SR7.R7_TIPO
            	                                                              AND R7_DATA <= SRE.RE_DATA))), SRA.RA_CATFUNC) %Exp:cRA_CATFUN%
		  ORDER BY RA_FILIAL, RA_MAT, RA_ADMISSA
		EndSql
		lNew := .T.

		While ! QRYD->(Eof())
			//-- Preenche a data Final
			If ! lNew .And. ! QRY->(Eof()) .And. QRY->(RA_FILIAL + RA_MAT) == QRYD->(RA_FILIAL + RA_MAT)
				RecLock("QRY", .F.)
				cMesAnoPer := If(Empty(QRYRIK->RIK_PERIOD),"",Substring(QRYRIK->RIK_PERIOD,5,2) + Substring(QRYRIK->RIK_PERIOD,1,4))
				If !Empty(cMesAnoPer) .And. Ctod("01/" + Trans(cMesAnoPer, "@R 99/9999")) > QRY->RI8_DATADE
					QRY->RI8_DATADE := Ctod("01/" + Trans(cMesAnoPer, "@R 99/9999"))
				EndIf

				QRY->RI8_DATATE := QRYD->RA_ADMISSA - 1

				QRY->(MsUnLock())
			EndIf

			RecLock("QRY", .T.)
			QRY->RA_FILIAL  	:= QRYD->RA_FILIAL
			QRY->RA_MAT     	:= QRYD->RA_MAT
			QRY->RA_NOME    	:= QRYD->RA_NOME

			QRY->RA_CODFUNC 	:= QRYD->RA_CODFUNC
			QRY->QB_DEPTO		:= QRYD->QB_DEPTO
			QRY->QB_DESCRIC 	:= QRYD->QB_DESCRIC
			QRY->QB_COMARC		:= QRYD->QB_COMARC
			QRY->RI8_PERCEN 	:= QRYRIK->RIK_PERCEN
			QRY->RI8_DATADE 	:= QRYD->RA_ADMISSA

			cMesAnoPer := If(Empty(QRYRIK->RIK_PERIOD),"",Substring(QRYRIK->RIK_PERIOD,5,2) + Substring(QRYRIK->RIK_PERIOD,1,4))
			If !Empty(cMesAnoPer) .And. Ctod("01/" + Trans(cMesAnoPer, "@R 99/9999")) > QRY->RI8_DATADE
				QRY->RI8_DATADE := Ctod("01/" + Trans(cMesAnoPer, "@R 99/9999"))
			EndIf

			If !Empty(QRYRIK->RIK_PERIOA)
				QRY->RI8_DATATE := LastDay(Ctod("01/" + Trans(Substring(QRYRIK->RIK_PERIOA,5,2)+Substring(QRYRIK->RIK_PERIOA,1,4), "@R 99/9999")))
			EndIf

			lNew := .F.

			M->RA_DEMISSA := QRYD->RA_DEMISSA
			QRYD->(DbSkip())

			If QRY->(RA_FILIAL + RA_MAT) <> QRYD->(RA_FILIAL + RA_MAT) .And. ! Empty(M->RA_DEMISSA)
				QRY->RI8_DATATE := M->RA_DEMISSA
			EndIf
			QRY->(MsUnLock())

		EndDo

		//-- Remove os registros que não atendem o filtro
		QRYD->(DbCloseArea())
		DbSelectArea("QRY")
		DbGoTop()

		While ! Eof()

			If 	QRY->RI8_DATADE > Ctod("01/" + Trans(mv_par04, "@R 99/9999")) .Or.;
				(! Empty(QRYRIK->RIK_PERIOD) .And. QRY->RI8_DATADE > Ctod("01/" + Trans(Substring(QRYRIK->RIK_PERIOD,5,2)+Substring(QRYRIK->RIK_PERIOD,1,4), "@R 99/9999"))) .Or.;
		   		(! Empty(QRY->RI8_DATATE) .And. QRY->RI8_DATATE < Ctod("01/" + Trans(mv_par03, "@R 99/9999"))) .Or.;
				(! Empty(QRYRIK->RIK_PERIOA) .And. QRY->RI8_DATATE < Ctod("01/" + Trans(Substring(QRYRIK->RIK_PERIOA,5,2)+Substring(QRYRIK->RIK_PERIOA,1,4), "@R 99/9999"))) .Or.;
				DelReg(QRY->RA_CODFUNC, QRYRIK->RIK_FUNCC, QRYRIK->RIK_FUNCD) .Or.;
				DelReg(QRY->QB_DEPTO, QRYRIK->RIK_DEPTOC, QRYRIK->RIK_DEPTOD) .Or.;
				DelReg(QRY->QB_COMARC, QRYRIK->RIK_COMARC, QRYRIK->RIK_COMARD)

				QRY->(RecLock("QRY", .F.))
				QRY->(DbDelete())
				QRY->(MsUnLock())
			EndIf

			QRY->(DbSkip())
		EndDo

		QRYRIK->(DbSkip())
	EndDo

	oFunc:SetParentFilter({|cParam| QRY->RA_FILIAL  == cParam}, {|| QRY->RA_FILIAL   })

	oFilial:Print()
	QRY->(DbCloseArea())
	QRYRIK->(DbCloseArea())

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} R390TpRIK
Retorna lista de opções utilizando a tabela RIK.
@sample 	R390TpRIK()
@author	    Wagner Mobile Costa
@since		31/03/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function R390TpRIK()

Local aArea := GetArea(), aLista := {}, MvParDef := "", nTam := 0
Local lPula := .F., cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" )
Local nCont := 0
Local nPos  := 0

CursorWait()
DbSelectArea("RIK")
DbSetOrder(1)
DbSeek(xFilial())
While !Eof() .And. RIK->RIK_FILIAL = xFilial()
	//-- Verifica as categorias a serem utilizadas
	lPula := .F.
	If RIK->RIK_CATEG <> Replicate("*", Len(AllTrim( RIK->RIK_CATEG ))) .And. AllTrim( mv_par06 ) <> Replicate("*", Len(AllTrim( mv_par06 )))
		lPula := .T.
		For nCont  := 1 to Len(Alltrim(mv_par06)) Step nTRACATFUN
			If Substr(mv_par06, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par06, nCont, nTRACATFUN)))
				For nPos  := 1 to Len(Alltrim(RIK->RIK_CATEG)) Step nTRACATFUN
					If Substr(mv_par06, nCont, nTRACATFUN) == Substr(RIK->RIK_CATEG, nPos, nTRACATFUN)
						lPula := .F.
					EndIf
				Next
			EndIf
		Next

		If ! Empty(AllTrim(cRA_CATFUN))
		 	cWhereRIK += " AND ('" + cRA_CATFUN + "')"
		EndIf
	EndIf

	If lPula .Or. RIK->RIK_PERCEN == 0
		DbSkip()
		Loop
	EndIf

	Aadd(aLista, AllTrim(RIK->RIK_COD) + " - " + Left(RIK->RIK_DESC, 30))
	MvParDef += AllTrim(RIK->RIK_COD)
	nTam := Len(AllTrim(RIK->RIK_COD))
	dbSkip()
Enddo
CursorArrow()

MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

If f_Opcoes(@MvPar, STR0014, aLista, MvParDef, 12, 49, .F., nTam) //"Tipos de Verba"
	&MvRet := mvpar                                               // Devolve Resultado
EndIF

RestArea(aArea)

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} DelReg
Verifica se o valor está contido na lista de valores a considerar (cValueC) ou na lista de valores  a  desconsiderar (cValueD).
@sample 	DelReg(cValue, cValueC, cValueD)
@param		cValue, caractere, conteúdo a ser analisado.
@param		cValueC, caractere, valor a considerar.
@param		cValueD, caractere, valor a desconsiderar.
@author	    Wagner Mobile Costa
@since		28/08/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function DelReg(cValue, cValueC, cValueD)

Local lRet := .F.

//-- Valores a Considerar
cValueC := AllTrim(cValueC)
If ! Empty(cValueC) .And. cValueC <> "*"
	lRet := ! cValue $ cValueC
EndIf

//-- Valores a Desconsiderar
cValueD := AllTrim(cValueD)
If ! Empty(cValueD) .And. cValueD <> "*" .And. ! lRet
	lRet := cValue $ cValueD
EndIf

Return lRet