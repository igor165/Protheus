#INCLUDE "VDFR400.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFR400
Relatório de Quadro de Estagiários Existentes
@sample 	VDFR400()
@author	    Alexandre Florentino
@since		08/04/2014
@version	P11.8
@history	04/05/2016, João Balbino, Corrigido o modo de geração do relatório para que seja exibida todas as páginas.
/*/
//------------------------------------------------------------------------------
Function VDFR400()

	Private oReport
	Private cString   	:= "RCC"
	Private cPerg	    := "VDFR400"
	Private cTitulo   	:= STR0001 //"Relatório de Quadro de Estagiários"
	Private nSeq 	    := 0
	Private cAliasQRY	:= ""
	Private lRPrint		:= .T.

	Pergunte(cPerg, .F.)

	M->RCC_FILIAL := ""	// Controle de quebra da numeracao
	M->RCC_FIL     := ""

	oReport := ReportDef()
	oReport:PrintDialog()

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Montagem das definições do relatório
@sample 	ReportDef()
@author	    Alexandre Florentino
@since		08/04/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ReportDef()

	Local cDescri := STR0002 //"O relatório “Quadro de Estagiários” visa listar a ocupação de vagas de estagiários durante o ano."

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)
	oReport:nFontBody := 7

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1 .And. lRPrint, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })
	oReport:SetLandscape ()

	oFilial := TRSection():New(oReport, "Filiais", { "SM0" })
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

    oFilial:bonPrintLine:= {|| NewPage(oReport) }

	TRCell():New(oFilial,"RA_FILIAL","RCC",,,, /*lPixel*/,/*bBlock*/ { || M->RCC_FIL := If(Empty((cAliasQry)->RA_FILIAL), cFilAnt, (cAliasQry)->RA_FILIAL) })
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																			 fDesc("SM0", cEmpAnt + M->RCC_FIL, "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0003, ( "RCC","RER","REC" )) //"Estagiários" //"Estagiários"

	nSeq := 0

	TRCell():New(oFunc,	"","",STR0004, "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão //'Nº'
	TRCell():New(oFunc,"RER_DESCR","RER",STR0005) 	//-- Entrância //"Entrância"
	TRCell():New(oFunc,"REC_NOME" ,"REC",STR0006)   	//-- Comarca //"Comarca"
	TRCell():New(oFunc,	"","", STR0007 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(VAGAS), "@E 99999")	},;    //-- Vagas //"Vagas"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0008 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_01), "@E 99999") },;    //-- Janeiro //"Janeiro"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0009 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_02), "@E 99999") },; //-- Fevereiro //"Fevereiro"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0010 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_03), "@E 99999") },;    //-- Março //"Março"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0011 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_04), "@E 99999") },;    //-- Abril //"Abril"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0012 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_05), "@E 99999") },;    	 //-- Maio //"Maio"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0013 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_06), "@E 99999") },;    //-- Junho //"Junho"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0014 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_07), "@E 99999") },;    //-- Julho //"Julho"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0015 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_08), "@E 99999") },;    //-- Agosto //"Agosto"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0016 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_09), "@E 99999") },;    //-- Setembro //"Setembro"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0017 ,/*cPicture*/, 5,/*lPixel*/, { || 	Trans((cAliasQry)->(MES_10), "@E 99999") },;    //-- Outubro //"Outubro"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0018 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_11), "@E 99999") },;    //-- Novembro //"Novembro"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")
	TRCell():New(oFunc,	"","", STR0019 ,/*cPicture*/, 5,/*lPixel*/, { || Trans((cAliasQry)->(MES_12), "@E 99999") },;    //-- Dezembro //"Dezembro"
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")

Return(oReport)


//------------------------------------------------------------------------------
/*/{Protheus.doc} NewPage
Quebra Página por Filial
@sample 	NewPage(oReport)
@author	    Alexandre Florentino
@since		08/04/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function NewPage(oReport)

Local lPrint := .T.

If M->RA_FILIAL <> (cAliasQry)->(RA_FILIAL)
	nSeq := 0
	M->RA_FILIAL := (cAliasQry)->(RA_FILIAL)
	If M->RA_FILIAL <> ''
		lRPrint := .F.
		oReport:EndPage(.T.)
		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
		oReport:Section(1):Finish()
		lPrint := .F.
		lRPrint := .T.
	EndIf
EndIf

Return lPrint


//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do conteúdo do relatório
@sample 	ReportPrint(oReport)
@author	    Alexandre Florentino
@since		08/04/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local nCont  := 0
	Local oFilial := oReport:Section(1), oFunc := oReport:Section(1):Section(1) , cWhere := "%"
	Local cMvPar01	  := ''
	Local cRECJoinSQB := fTbJoinSQL("REC", "SQB","%")
	Local cSRAJoinRCC := fTbJoinSQL("SRA", "RCC","%")
	Local cSQ3JoinRCC := fTbJoinSQL("SQ3", "RCC","%")
	Local cSQ3JoinSRA := fTbJoinSQL("SRA", "SQ3","%")
	Local cSQBJoinRCC := fTbJoinSQL("SQB", "RCC","%")
	Local cSQBJoinSRA := fTbJoinSQL("SRA", "SQB","%")
	Local cRERJoinSRA := Replace(fTbJoinSQL("SRA", "RER","%"),"SRA.","RCCF.")//alterar alias para RCCR
	Local cRECJoinSRA := Replace(fTbJoinSQL("SRA", "REC","%"),"SRA.","RCCF.")//alterar alias para RCCR
	Local cSRARCCF    := Replace(fTbJoinSQL("SRA", "RCC","%"),"SRA.","RCCF.")//Replace(fTbJoinSQL("SQB", "SRE","%"),"RE_FILIAL","RE_FILIALP")

	If Empty(mv_par02)
		MsgInfo(STR0020) //"Atenção. É obrigatório o preenchimento do ano do exercício!"
		Return
	EndIF

	cAliasQRY := GetNextAlias()

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)
	If !Empty(MV_PAR01)
		cMvPar01 := Replace(MV_PAR01,"RCC_FILIAL","SRA.RA_FILIAL")
	EndIf

	oFilial:BeginQuery()
		BeginSql Alias cAliasQRY

		  SELECT RCCF.RA_FILIAL AS RA_FILIAL,
		       RER.RER_CODIGO, MIN(RER.RER_DESCR) AS RER_DESCR, REC.REC_CODIGO, REC.REC_NOME,
		       SUM(CAST(SUBSTRING(RCC.RCC_CONTEU, 12, 5) AS INTEGER)) AS VAGAS,
			   MIN(RCCF.MES_01) AS MES_01, MIN(RCCF.MES_02) AS MES_02, MIN(RCCF.MES_03) AS MES_03, MIN(RCCF.MES_04) AS MES_04,
			   MIN(RCCF.MES_05) AS MES_05, MIN(RCCF.MES_06) AS MES_06, MIN(RCCF.MES_07) AS MES_07, MIN(RCCF.MES_08) AS MES_08,
			   MIN(RCCF.MES_09) AS MES_09, MIN(RCCF.MES_10) AS MES_10, MIN(RCCF.MES_11) AS MES_11, MIN(RCCF.MES_12) AS MES_12
		  FROM %table:RCC% RCC
		  JOIN (SELECT SRA.RA_FILIAL AS RA_FILIAL,
		               CASE WHEN RCC.RCC_CHAVE = %Exp:' '% THEN %Exp:mv_par02 + '12'%  ELSE RCC.RCC_CHAVE END AS RCC_PERIOD,
					   SUBSTRING(RCC.RCC_CONTEU, 1, 5) AS Q3_CARGO,
					   SUBSTRING(RCC.RCC_CONTEU, 6, 6) AS QB_COMARC,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '0201'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '0201'% )
								   AND SQ3.Q3_CARGO =  SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_01,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '0301'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '0301'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_02,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '0401'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '0401'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_03,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02  + '0501'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '0501'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_04,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '0601'%
				                 AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '0601'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_05,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '0701'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '0701'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_06,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '0801'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '0801'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_07,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '0901'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '0901'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_08,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '1001'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '1001'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_09,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '1101'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '1101'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_10,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:MV_PAR02 + '1201'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:MV_PAR02 + '1201'%)
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_11,
					   COUNT(CASE WHEN SRA.RA_ADMISSA < %Exp:StrZero(Val(MV_PAR02) + 1, 4) + '0101'%
				                   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:StrZero(Val(MV_PAR02) + 1, 4) + '0101'% )
								   AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
								   AND SQB.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6) THEN 1 ELSE NULL END) AS MES_12
			      FROM %table:RCC% RCC
				  LEFT JOIN %table:SRA% SRA ON SRA.%notDel% AND %Exp:cSRAJoinRCC% AND (RCC.RCC_FIL = '' OR RCC.RCC_FIL = SRA.RA_FILIAL)
				   AND SRA.RA_CATFUNC IN (%Exp:'E'%, %Exp:'G'%) AND SRA.RA_ADMISSA < %Exp:StrZero(Val(MV_PAR02) + 1, 4) + '0101'%
				   AND (SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:StrZero(Val(MV_PAR02) + 1, 4) + '0101'%)
				   AND SRA.RA_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
		          LEFT JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cSQ3JoinRCC% AND SQ3.Q3_CARGO = SRA.RA_CARGO
		           AND SQ3.Q3_CATEG IN (%Exp:'E'%, %Exp:'G'%)
		          LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cSQBJoinRCC% AND SQB.QB_DEPTO = SRA.RA_DEPTO
		  	     WHERE RCC.%notDel%  AND RCC.RCC_CODIGO = %Exp:'S111'%
                   AND (RCC.RCC_FIL = '' OR RCC.RCC_FIL = SRA.RA_FILIAL)
				 GROUP BY SRA.RA_FILIAL,
				          RCC.RCC_CHAVE,
					      SUBSTRING(RCC.RCC_CONTEU, 1, 5),
					      SUBSTRING(RCC.RCC_CONTEU, 6, 6)) RCCF ON  %Exp:cSRARCCF%
		   AND RCCF.RCC_PERIOD = CASE WHEN RCC.RCC_CHAVE = %Exp:' '% THEN %Exp:mv_par02 + '12'% ELSE RCC.RCC_CHAVE END
		   AND RCCF.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5) AND RCCF.QB_COMARC = SUBSTRING(RCC.RCC_CONTEU, 6, 6)
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cSQ3JoinRCC% AND SQ3.Q3_CARGO = SUBSTRING(RCC.RCC_CONTEU, 1, 5)
		   AND SQ3.Q3_CATEG IN (%Exp:'E'%, %Exp:'G'%)
		  JOIN %table:REC% REC ON REC.%notDel% AND %Exp:cRECJoinSRA%  AND REC.REC_CODIGO = SUBSTRING(RCC.RCC_CONTEU, 6, 6)
		  JOIN %table:RER% RER ON RER.%notDel% AND %Exp:cRERJoinSRA%  AND RER.RER_CODIGO = REC.REC_REGIAO
		 WHERE RCC.%notDel% AND RCC.RCC_CODIGO = %Exp:'S111'%
		 GROUP BY RCCF.RA_FILIAL, RER.RER_CODIGO, REC.REC_NOME, REC.REC_CODIGO
		 ORDER BY RCCF.RA_FILIAL, RER.RER_CODIGO DESC, REC.REC_NOME, REC.REC_CODIGO

		EndSql
	oFilial:EndQuery(cMvPar01)

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

	oFilial:Print()

Return