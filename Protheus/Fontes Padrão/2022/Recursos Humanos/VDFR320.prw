#INCLUDE "VDFR320.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR320  ³ Autor ³ Alexandre Florentino  ³ Data ³  05.02.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Relatório de Antiguidade dos Membros                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR320()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oReport                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function VDFR320()
	
	Local aRegs := {}

	Private oReport
	Private cString	:= "SRA"
	Private cPerg		:= "VDFR320"
	Private aOrd    	:= {}
	Private cTitulo	:= ""
	Private nSeq 		:= nRecEOF := 0
	Private cAliasQRY	:= ""
	Private oEntrancia


	Pergunte(cPerg, .F.)

	M->RA_FILIAL := ""	// Variavel para controle da numeração

	PtSetAcento(.T.)
	
	oReport := ReportDef()
	oReport:PrintDialog()

	PtSetAcento(.F.)

	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Alexandre Florentino  ³ Data ³ 05.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR320                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR320                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR320 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

	Local cDescri   := STR0002 //"Relatório de Antiguidade dos Membros"

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 3)

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""
	
	oFilial:bOnPrintLine := { || (oReport:SkipLine(),	If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
															oReport:PrintText(AllTrim(RetTitle("RA_FILIAL")) + ': ' +;
															(cAliasQry)->(RA_FILIAL) + " - " +;
															fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")), oReport:SkipLine(), .F.) } 

	TRCell():New(oFilial,"RA_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->(RA_FILIAL + RER_CODIGO), (M->RA_FILIAL := (cAliasQry)->(RA_FILIAL + RER_CODIGO), nSeq := 0), Nil),;
																	 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

	oCargo := TRSection():New(oFilial,STR0008 , { "SQ3" }) //'Cargos'
	oCargo:cCharSeparator := ""
	oCargo:nLinesBefore   := 2
	TRCell():New(oCargo,"Q3_DESCSUM","SQ3","",,40)

	oFunc := TRSection():New(oCargo, STR0013, ( "SRA","SQ3","SQB","RI5","RI6" )) //'Membros' # 'Relação de Antiguidade'

	// Se 'PROCURADORES DE JUSTIÇA' (STR0015), titulo fica 'Instância (1o.)', senão fica 'Entrância '+(cAliasQry)->(RER_DESCR)+' (1o.)'
	oFunc:bOnPrintLine := { || (oEntrancia:cTitle := if( 	alltrim((cAliasQry)->(Q3_DESCSUM))==alltrim(STR0015),OemTOansi(STR0012),OemTOansi(STR0005+' '+;
								  								alltrim((cAliasQry)->(RER_DESCR))+' (1o)' ))),;
								  	If(	nRecEOF == (cAliasQRY)->(Recno()), (PrintLine(oReport, oReport:Section(1):Section(1):Section(1)),;
								  												 prnAssinatura(oReport), .F.), .T.) }


	oFunc:SetCellBorder("ALL",,, .T.)
	oFunc:SetCellBorder("RIGHT")
	oFunc:SetCellBorder("LEFT")
	oFunc:SetCellBorder("BOTTOM")

	nSeq := 0
	TRCell():New(oFunc,	"NUMERO","",'No', "99999", 5, /*lPixel*/,/*bBlock*/ {|| 	(	If(M->RA_FILIAL <> (cAliasQry)->(RA_FILIAL + RER_CODIGO), (M->RA_FILIAL := (cAliasQry)->(RA_FILIAL + RER_CODIGO), nSeq := 0), Nil),;
																							"  "+AllTrim(Str(++nSeq))) })//Para incluir o número(sequencial) na linha de impressão
	TRCell():New(oFunc,"RA_MAT","SRA",STR0007,,12)                                 //'Matrícula'
	TRCell():New(oFunc,"RA_NOME","SRA",STR0008,,TamSX3("RA_NOMECMP")[1])                           	//'Nome'
	oEntrancia := TRCell():New(oFunc,	"INSTANCIA","", "" ,/*cPicture*/, 30,/*lPixel*/, { || 	AntDUtil(dDataBase - (cAliasQRY)->RE_DATA) },; //'Instância (1o.)'
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")              
	TRCell():New(oFunc,	"CARREIRA","", OemTOansi(STR0010) ,/*cPicture*/, 18,/*lPixel*/, { || 	AntDUtil(dDataBase - (cAliasQRY)->RA_ADMISSA) },; //'Carreira (2o.)'
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER")              
	TRCell():New(oFunc,	"TEMPO","", OemTOansi(STR0011) ,/*cPicture*/, 28,/*lPixel*/, { || 	AntDUtil((cAliasQRY)->RII_TMPLIQ) },; //'Tempo de serviço público averbado (3º)'
					/*cAlign*/ "CENTER", /*lLineBreak*/ .T., /*cHeaderAlign*/ "CENTER") 
					
Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Alexandre Florentino  ³ Data ³ 05.02.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR320                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR320                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR320 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)

	Local oFilial     := oReport:Section(1), cWhere := "%", cQ3_DESCSUM := cQ3_DESC_OR := cRA_NOME := ""
	Local oCargo      := oReport:Section(1):Section(1)
	Local oFunc       := oReport:Section(1):Section(1):Section(1)
	Local cRI6_DTSQL  := cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
    Local nTamCodAfas := 2

	Local cRI6RIISQL := "%RII.RII_PERDE+RII.RII_PERATE+RII_TIPAVE+RII_SEQUEN%"

	If Empty(mv_par04) .Or. Empty(mv_par05) .Or. Empty(mv_par06)
		MsgInfo(STR0014)	// 'É obrigatório o preenchimento das perguntas Cargo de [Procuradores], [Promotores] e [Substitutos] ! '
		Return 
	EndIf
	
	If Upper(TcGetDb()) $ "DB2_ORACLE_INFORMIX_POSTGRES"
		cRI6RIISQL := StrTran(cRI6RIISQL, "+", "||")
	EndIf
	
	cAliasQRY := GetNextAlias()

	oReport:SetTitle(alltrim(MV_PAR07)+" "+alltrim(MV_PAR08)+" - "+STR0019+" "+Dtoc(MV_PAR09) )	
	
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	cMV_PAR := ""
	If !Empty(MV_PAR01)		//-- Filial
		cMV_PAR += " AND " + MV_PAR01
	EndIf
	
	If !empty(MV_PAR02)		//-- Matricula
		cMV_PAR += " AND " + MV_PAR02
	EndIf

	If !Empty(MV_PAR03)		//-- Intrancia
		cMV_PAR += " AND " + MV_PAR03
	EndIf
	
	cMV_PAR += "%"

	cWhere += cMV_PAR
	
	cQ3_DESCSUM := "%CASE WHEN " + mv_par04 + " THEN '" + STR0015 + "' ELSE CASE WHEN " + mv_par05 + " THEN '" + STR0016 + "' ELSE " +;	// 'PROCURADORES DE JUSTIÇA' # 'PROMOTORES DE JUSTIÇA' 
			          "CASE WHEN " + mv_par06 + " THEN '" + STR0017 + "' ELSE '' END END END%"	// 'PROMOTORES DE JUSTIÇA SUBSTITUTOS'
	cQ3_DESC_OR := "%CASE WHEN " + mv_par04 + " THEN 1 ELSE CASE WHEN " + mv_par05 + " THEN 2 ELSE CASE WHEN " + mv_par06 + " THEN 3 ELSE 0 END END END%"			          

	cRA_NOME := "%CASE WHEN RA_NOMECMP <> '' THEN RA_NOMECMP ELSE RA_NOME END%"

	oFilial:BeginQuery()
		BeginSql Alias cAliasQRY
			SELECT SRA.RA_FILIAL, %Exp:cQ3_DESCSUM% AS Q3_DESCSUM, 
			        RER.RER_CODIGO, RER.RER_DESCR, 
			        %Exp:cRA_NOME% AS RA_NOME, 
			        SRA.RA_MAT, COALESCE(SRE.RE_DATA, SRA.RA_ADMISSA) AS RE_DATA, SRA.RA_ADMISSA, RII.RII_TMPLIQ 
			  FROM %table:SRA% SRA
	 		  JOIN (	SELECT RB6.RB6_TABELA, RB6.RB6_DESCTA, RB6_FAIXA, RB6_NIVEL, RB6_REGIAO
						  FROM %table:RB6% RB6
						 WHERE RB6.%notDel% AND RB6.RB6_FILIAL = %Exp:xFilial("RB6")%
						   AND RB6.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:RB6% WHERE %notDel% AND RB6_FILIAL = %Exp:xFilial("RB6")%
						   AND RB6_TABELA = RB6.RB6_TABELA AND RB6_FAIXA = RB6.RB6_FAIXA 
						   AND RB6_NIVEL = RB6.RB6_NIVEL AND RB6_DTREF < %Exp:dDataBase%)) RB6 ON RB6.RB6_TABELA = SRA.RA_TABELA 
			   AND RB6.RB6_FAIXA = SRA.RA_TABFAIX AND RB6.RB6_NIVEL = SRA.RA_TABNIVE   
 			  LEFT JOIN %table:RER% RER ON RER.%notDel% AND RER.RER_FILIAL = %Exp:xFilial("RER")% AND RER.RER_CODIGO = RB6.RB6_REGIAO 
		LEFT JOIN (    SELECT SRE.RE_FILIALP, SRE.RE_MATP, SRE.RE_DEPTOP, MIN(SRE.RE_DATA) AS RE_DATA
                         FROM (SELECT RE_FILIALP, RE_MATP, RE_DEPTOP, MIN(RE_DATA) AS RE_DATA
             			  FROM %table:SRE% SRE
             			  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SRE.RE_FILIALP AND SRA.RA_MAT = SRE.RE_MATP
              			 WHERE SRE.%notDel% AND RE_FILIAL = %Exp:xFilial("SRE")% AND SRE.RE_DEPTOD <> SRE.RE_DEPTOP
				 GROUP BY RE_FILIALP, RE_MATP, RE_DEPTOP
                                 UNION
                                SELECT SR3.R3_FILIAL, SR3.R3_MAT, SRA.RA_DEPTO, MIN(SR3.R3_DATA) AS R3_DATA
             			  FROM %table:SR3% SR3
             			  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SR3.R3_FILIAL AND SRA.RA_MAT = SR3.R3_MAT
                                   AND SRA.RA_TABELA = SR3.R3_TABELA AND SRA.RA_TABNIVE = SR3.R3_TABNIVE AND SRA.RA_TABFAIX = SR3.R3_TABFAIX
              			 WHERE SR3.%notDel% AND SR3.R3_TIPO = %Exp:mv_par16%
				 GROUP BY SR3.R3_FILIAL, SR3.R3_MAT, SRA.RA_DEPTO) SRE
                              GROUP BY SRE.RE_FILIALP, SRE.RE_MATP, SRE.RE_DEPTOP) SRE ON SRE.RE_FILIALP = SRA.RA_FILIAL AND SRE.RE_MATP = SRA.RA_MAT 
  			   AND SRE.RE_DEPTOP = SRA.RA_DEPTO 
   			  LEFT JOIN ( SELECT RII.RII_FILIAL, RII.RII_MAT, SUM(RII.RII_TMPLIQ) AS RII_TMPLIQ
						     FROM %table:RII% RII
	  	 				     LEFT JOIN %table:RI6% RI6 ON RI6.%notDel% AND RI6.RI6_FILIAL = %Exp:xFilial("RI6")% AND RI6.RI6_FILMAT = RII.RII_FILIAL 
	  	 					  AND RI6.RI6_MAT = RII.RII_MAT AND RI6.RI6_TABORI = %Exp:'RII'% AND RI6.RI6_CHAVE = %Exp:cRI6RIISQL%
	  	                     LEFT JOIN %table:RI5% RI5 ON RI5.%notDel% AND RI5.RI5_FILIAL = %Exp:xFilial("RI5")% AND RI5.RI5_ANO = RI6.RI6_ANO 
	  	                      AND RI5.RI5_NUMDOC = RI6.RI6_NUMDOC AND RI5.RI5_TIPDOC = RI6.RI6_TIPDOC AND RI5.RI5_DTAPUB <> %Exp:''%
						    WHERE RII.%notDel% AND RII.RII_TIPAVE = %Exp:'1'% AND RII.RII_TIPREG = %Exp:'1'% 
						      AND CASE WHEN RII.RII_TIPINF = %Exp:'H'% THEN 1 ELSE CASE WHEN RI5.RI5_FILIAL IS NULL THEN 0 ELSE 1 END END = 1
						    GROUP BY RII_FILIAL, RII_MAT) RII ON RII.RII_FILIAL = SRA.RA_FILIAL AND RII.RII_MAT = SRA.RA_MAT 
		     WHERE SRA.%notDel% %Exp:cWhere% AND SRA.RA_ADMISSA < %Exp:dDataBase% AND SRA.RA_SITFOLH <> %Exp:'D'% AND %Exp:cQ3_DESCSUM% <> %Exp:''%  
		 	 ORDER BY 	SRA.RA_FILIAL, %Exp:cQ3_DESC_OR%,
			         	RER.RER_CODIGO DESC, COALESCE(SRE.RE_DATA, SRA.RA_ADMISSA), SRA.RA_ADMISSA, CASE WHEN RII_TMPLIQ IS NULL THEN 0 ELSE RII_TMPLIQ END DESC, SRA.RA_NASC
		EndSql
	oFilial:EndQuery()
	
	While ! (cAliasQRY)->(Eof())
		nRecEOF := (cAliasQRY)->(Recno())
		(cAliasQRY)->(DbSkip())
	EndDo
	
    
	oCargo:SetParentQuery()    
	oCargo:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL + (cAliasQRY)->(RER_CODIGO) == cParam}, {|| (cAliasQRY)->RA_FILIAL + (cAliasQRY)->(RER_CODIGO) })

	oFilial:Print()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AntDUtil ³ Autor ³ Marcos Pereira      ³ Data ³ 06.02.14     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Para calculo da quantidade de anos, mês e dias               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AntDUtil(dDataInicial)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AntDUtil(nTempo)
Local nDias   	:= 0
Local nAnos  	:= 0
Local nMeses  	:= 0
Local cRetorno	:= " "+STR0018	// 'SEM AVERBAÇÃO'  //Precisa manter o espaço no inicio para garantir a ordenação de desempate por averbação
Default nTempo:= 0

nAnos	:= NoRound(nTempo/365,0)  //Fator divisor de 360 dias por ano, conforme regra do MP
nTempo	-= nAnos*365            		
nMeses	:= NoRound(nTempo/30,0)
nTempo	-= nMeses*30
nDias	:= nTempo

If nAnos + nMeses + nDias > 0
	cRetorno := (Strzero(nAnos,2) + "a" + Strzero(nMeses,2) + "m" + Strzero(nDias,2) + "d")
EndIf
                                           
Return cRetorno 

//------------------------------------------------------------------------------
/*/{Protheus.doc} prnAssinatura
Monta o Rodapé do relatório
@sample 	prnAssinatura(oReport)
@author	Wagner Mobile Costa
@since		24/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function prnAssinatura(oReport)

oReport:SkipLine()
oReport:SkipLine()
oReport:SkipLine()

oReport:PrtLeft(Space(8) + AllTrim(mv_par10))
oReport:PrintText(AllTrim(mv_par12),, 1600)

oReport:PrtLeft(Space(8) + AllTrim(mv_par11))
oReport:PrintText(AllTrim(mv_par13),, 1600)

oReport:SkipLine()
oReport:SkipLine()
oReport:SkipLine()

oReport:PrtCenter(AllTrim(mv_par14))
oReport:SkipLine()
oReport:PrtCenter(AllTrim(mv_par15))

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrintLine
Imprime a linha da secao passada como parametro
@sample 	PrintLine(oReport,oSecao)
@author	Wagner Mobile Costa
@since		24/09/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function PrintLine(oReport,oSecao)
Local ni
Local nj
Local nSkipAfter := 1
Local nLine := 0
Local nRowBottom
Local aLine := {}
Local lPrint := .T.
Local lEvalBreak := .F.
Local nLineCount
Local lNextLine
Local nTmpCount
Local lLineCount := .F.
Local aCellPos
Local lLineBreak
Local lLineStyle
Local nLeftMargin
Local nLineHeight
Local nPageHeight
Local nPageHeightTrue
Local lHeaderVisible
Local nLinesBefore
Local oObj
Local aTmp
Local Self := oSecao

DEFAULT lExcel 		 := oReport:nDevice == IMP_EXCEL

lEvalPosition := .T.
lParamPage    := .F.

If !lParamPage
	oLastSection := Self
EndIf

If oSecao:lPrinting .and. oSecao:lEnabled

	If .F. // oSecao:bOnPrintLine <> NIL
		lPrint := Eval(oSecao:bOnPrintLine,Self)
		
		If ValType(lPrint) <> "L"
			lPrint := .T.
		EndIf
	EndIf

	//acerta coluna das celulas
	If oSecao:lCellPos
		oSecao:CellPos()
	EndIf

	//celulas de posicionamento
	If lEvalPosition
		oSecao:EvalPosition()
	EndIf

	If !oSecao:ExUserFilter()
		Return
	EndIf

	//calcula celulas para verificar quebras das funcoes
	oSecao:EvalCell()

	//quebras
	lEvalBreak := (oSecao:EvalBreak() .or. oReport:EvalBreak())

	If oSecao:lVisible .and. oSecao:lUserVisible .and. lPrint

		aCellPos := oSecao:aCellPos
		lLineBreak := oSecao:lLineBreak
		lLineStyle := oSecao:lLineStyle
		nLeftMargin := oSecao:LeftMargin()
		nLineHeight := oReport:nLineHeight
		nPageHeight := oReport:PageHeight()
		nPageHeightTrue := oReport:PageHeight(.T.)
		lHeaderVisible := oSecao:lHeaderVisible
		nLinesBefore := oSecao:nLinesBefore

		//vefifica se impressao da linha cabe na pagina
		If !lLineBreak .and. !lLineStyle
			nLine++
			nSkipAfter := 0
			Aadd(aLine,{{},0,0,0})	//celulas,skipline,borda top,borda bottom
		EndIf

		For ni := 1 To Len(aCellPos)
			oObj := aCellPos[ni]
			
			If lLineBreak .or. lLineStyle
				If oObj:nCol == nLeftMargin
					nLine++
					nLineDiff := 1
					Aadd(aLine,{{},0,0,0})	//celulas,skipline,borda top,borda bottom
				EndIf
			EndIf

			oObj:lPrintCell := .T.
			oObj:nLineStart := 1
			aTmp := aLine[nLine]
			Aadd(aTmp[1],oObj)
			aTmp[2] := Max(aTmp[2],oObj:LineCount())
			aTmp[3] := Max(aTmp[3],oObj:oBrdTop:Weight())
			aTmp[4] := Max(aTmp[4],oObj:oBrdBottom:Weight())
		Next
		
		If Len(aLine) > 0
		
			//imprime conteudo das celulas
			ni := 1
			While ni <= Len(aLine)
				aTmp := aLine[ni]

				oReport:StartPage()
				If oReport:nBorderDiff > 0 .and. aTmp[3] > 0
					If oReport:nBorderDiff > aTmp[3]
						oReport:IncRow(-aTmp[3])
					Else
						oReport:IncRow(-oReport:nBorderDiff)
					EndIf
				EndIf

				lLineCount := .F.
				nLineCount := aTmp[2]
				nRowBottom := oReport:nRow + nLineHeight*aTmp[2] + aTmp[3] + aTmp[4]
				While nRowBottom > nPageHeight
					nLineCount := Int((nPageHeight - oReport:nRow)/nLineHeight)-1
					
					//numero de linhas maior q o que cabe na pagina toda
					If nLineCount > Int(nPageHeightTrue/nLineHeight)-1
						nLineCount := Int((nPageHeightTrue - oReport:nRow)/nLineHeight)-1
					EndIf
					
					If nLineCount < 1
						lLineCount := .T.
						nLineCount := aTmp[2]
						For nj := 1 To Len(oReport:aSection)
							oReport:aSection[nj]:EndBorder()
						Next nj

						If !oReport:EndPage()
							nLineCount := -1
							Exit
						EndIf
					EndIf

					nRowBottom := oReport:nRow + nLineHeight*nLineCount + aTmp[3] + aTmp[4]
				End

				If nLineCount < 0
					Exit
				EndIf

				oReport:StartPage()
				lPageBreak := oReport:PageBreak()
				
				If (oSecao:lInit .or. lEvalBreak) .and. !lPageBreak
					If nLinesBefore > 0
						oReport:nBorderDiff := 0
						oReport:SkipLine(nLinesBefore)
					EndIf
					oReport:StartPage()
					lPageBreak := oReport:PageBreak()
				EndIf
	
				If oSecao:lInit .and. lHeaderVisible
					oReport:PrintText(oSecao:cTitle,,oReport:LeftMargin(,.T.))
					oReport:StartPage()
					lPageBreak := oReport:PageBreak()
				EndIf
	
				If !oSecao:lHeaderPage .and. (lPageBreak .or. oSecao:lPrintHeader .or. lLineCount)
					oSecao:SetRow(oReport:nRow)
					If ( lPageBreak .or. lLineCount )  .and. !oReport:oPage:lFirstPage
						oSecao:oBrdTop:Print()
						For nj := 1 To Len(oReport:aSection)
							oReport:aSection[nj]:IniRow()
						Next nj
					Else
						oSecao:oBrdTop:Print()
					EndIf
					oSecao:PrintHeader(.F.,,,lExcel)
					oReport:StartPage()
					lPageBreak := oReport:PageBreak()
				EndIf
			
				oSecao:lInit := .F.
				oSecao:lPrintHeader := .F.
				lEvalBreak := .F.
	
				oReport:StartPage()
				oSecao:nLineCount := nLineCount
				nLineCount := 0
				lNextLine := .T.
				
				If lExcel
					oReport:XlsNewRow()
				EndIf
				
				For nj := 1 To Len(aTmp[1])
					oObj := aTmp[1][nj]
					oObj:SetRow(oReport:nRow)
					oObj:SetRowDiff(aTmp[3])

					//verifica seimprimiu todo conteudo da celula na pagina atual
					nTmpCount := oObj:Print(,,lExcel)
					If nTmpCount > 0
						lNextLine := .F.
						nLineCount := Max(nLineCount,nTmpCount)
						If lLineStyle
							oObj:lHeaderVisible := .F.
						EndIf
					Else
						oObj:lPrintCell := .F.
						If lLineStyle
							oObj:lHeaderVisible := .T.
						EndIf
					EndIf
				Next

				oReport:SkipLine(oSecao:nLineCount)
				oReport:IncRow(aTmp[3]+aTmp[4])
				oReport:nBorderDiff := aTmp[4]
				
				//verifica se imprime a mesma linha identica para imprimir restante das celulas na outra pagina (exemplo: campo memo)
				If lNextLine
					ni++
				Else
					aTmp[2] := nLineCount
				EndIf
			End

			oReport:SkipLine(nSkipAfter)
			oReport:lNoPrint := .F.
		EndIf
	EndIf
	
	//totalizadores
	//oSecao:EvalFunction()
EndIf
Return
