#INCLUDE "VDFR150.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR150  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  01.01.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Controle de Relotações                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR150(void)                                                ³±±
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
Function VDFR150()

Local aRegs := {}

Private oReport
Private cString		:= "SRA"
Private cPerg		:= "VDFR150"
Private aOrd    	:= {}
Private cTitulo		:= STR0001 //'Relatório de Controle de Relotações'
Private nSeq 		:= 0
Private cAliasQRY	:= ""

Pergunte(cPerg, .F.)

M->RA_FILIAL := ""	// Variavel para controle da numeração

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 01.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR150                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR150 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local cDescri := STR0002 //"Este relatório tem como objetivo listar as relatações da competencia informada"

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							.T.,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

oFunc := TRSection():New(oFilial, STR0004, ( "SRA","SQ3","SQB","RI5","RI6" )) //'Servidores'

nSeq := 0
TRCell():New(oFunc,	"","",'Nº', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão
TRCell():New(oFunc,"RA_MAT","SRA",STR0005,,10) //'Matrícula'
TRCell():New(oFunc,"RA_NOME","SRA",STR0006,, 40) //'Nome'
TRCell():New(oFunc,"Q3_DESCSUM","SQ3",STR0007,,40) //'Cargo/Função'
TRCell():New(oFunc,"QB_DESCRID","SRE",STR0008,,40)       // - 'Lotação'
TRCell():New(oFunc,"QB_DESCRIP","SRE",STR0009,,40)     // - 'Relotação'
TRCell():New(oFunc,"RI6_DTEFEI","RI6",STR0010) //'Efeito'
TRCell():New(oFunc,"RI6_NUMDOC","RI6",STR0011) //'Ato'
TRCell():New(oFunc,"RI5_DTATPO","RI5",STR0012) //'Data'

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 01.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR150                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR150 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oFilial    := oReport:Section(1), oFunc := oReport:Section(1):Section(1), cWhere := cWhereSR7 := "%"
Local cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
Local cRI6RI7SQL := "%SRE.RE_EMPP + SRE.RE_FILIALP + SRE.RE_MATP + SRE.RE_DATA%"

If Empty(mv_par03)
	MsgInfo(STR0013) //"É obrigatório o preenchimento da competência ! Verifique os parâmetros !"
	Return 
EndIF

cAliasQRY := GetNextAlias()

oReport:SetTitle(cTitulo + " [" + Trans(mv_par03, "@R 99/9999") + "]")
If Upper(TcGetDb()) $ "DB2_ORACLE_INFORMIX_POSTGRES"
	cRI6RI7SQL := StrTran(cRI6RI7SQL, "+", "||")
EndIf

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

cWhere += "SRE.RE_MATP = CASE WHEN COALESCE(SR7.R7_CATFUNC, SRA.RA_CATFUNC) IN ('2', '3', '6') " +;
                             "THEN CASE WHEN SQB_D.QB_COMARC = SQB_P.QB_COMARC THEN SRE.RE_MATP ELSE '' END ELSE " +;
                        "CASE WHEN COALESCE(SR7.R7_CATFUNC, SRA.RA_CATFUNC) IN ('0', '1') THEN '' ELSE SRE.RE_MATP END END"

if !empty(MV_PAR01)		//-- Filial
	cWhere += " AND " + MV_PAR01
	cWhereSR7 += " AND " + StrTran(MV_PAR01, "RA_FILIAL", "R7_FILIAL")
EndIf
if !empty(MV_PAR02)		//-- Matricula
	cWhere += " AND " + MV_PAR02
	cWhereSR7 += " AND " + StrTran(MV_PAR02, "RA_MAT", "R7_MAT")
EndIf

cWhere += " AND SRE.RE_DATA BETWEEN '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "01' AND " +;
                                  "'" + Right(mv_par03, 4) + Left(mv_par03, 2) + "31'"
cWhereSR7 += " AND R7_DATA <= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "31'"

//-- Monta a string com as categorias a serem listadas
If AllTrim( mv_par04 ) <> Replicate("*", Len(AllTrim( mv_par04 )))
	cRA_CATFUN   := ""
	For nCont  := 1 to Len(Alltrim(mv_par04)) Step nTRACATFUN
		If Substr(mv_par04, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par04, nCont, nTRACATFUN)))
			cRA_CATFUN += "'" + Substr(mv_par04, nCont, nTRACATFUN) + "',"
		EndIf
	Next
	cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)

	If ! Empty(AllTrim(cRA_CATFUN))
		cWhere += ' AND COALESCE(SR7.R7_CATFUNC, SRA.RA_CATFUNC) IN (' + cRA_CATFUN + ')'
	EndIf
EndIf

cWhere += "%"
cWhereSR7 += "%"

oFilial:BeginQuery()
BeginSql Alias cAliasQRY
   SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SQ3.Q3_DESCSUM, SQB_D.QB_DESCRIC AS QB_DESCRID, SQB_P.QB_DESCRIC AS QB_DESCRIP,
          SRE.RE_DATA AS RI6_DTEFEI, RI6.RI6_NUMDOC, RI5.RI5_DTATPO, SRE.RE_DEPTOD, SRE.RE_DEPTOP, SRE.RE_EMPD, 
          SRE.RE_FILIALD, SRE.RE_MATD, SRE.RE_DATA
     FROM %table:SRE% SRE
     JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SRE.RE_FILIALP AND SRA.RA_MAT = SRE.RE_MATP
     LEFT JOIN (SELECT R7_FILIAL, R7_MAT, MAX(R7_CATFUNC) AS R7_CATFUNC, MAX(R7_CARGO) AS R7_CARGO FROM %table:SR7% SR7
    	          WHERE %notDel% %Exp:cWhereSR7%
        	        AND R7_DATA = (SELECT MAX(R7_DATA) FROM %table:SR7% 
            	                    WHERE %notDel% %Exp:cWhereSR7% AND R7_FILIAL = SR7.R7_FILIAL AND R7_MAT = SR7.R7_MAT 
                	                  AND R7_SEQ = SR7.R7_SEQ AND R7_TIPO = SR7.R7_TIPO)
	              GROUP BY R7_FILIAL, R7_MAT) SR7 ON SR7.R7_FILIAL = SRA.RA_FILIAL AND SR7.R7_MAT = SRA.RA_MAT
     LEFT JOIN %table:RI6% RI6 ON RI6.%notDel% AND RI6.RI6_FILIAL = %Exp:xFilial("RI6")% AND RI6.RI6_FILMAT = SRA.RA_FILIAL 
      AND RI6.RI6_MAT = SRA.RA_MAT AND RI6.RI6_TABORI = %Exp:'SRE'% AND RI6.RI6_CHAVE = %Exp:cRI6RI7SQL%
     LEFT JOIN %table:RI5% RI5 ON RI5.%notDel% AND RI5.RI5_FILIAL = %Exp:xFilial("RI5")% AND RI5.RI5_ANO = RI6.RI6_ANO 
      AND RI5.RI5_NUMDOC = RI6.RI6_NUMDOC AND RI5.RI5_TIPDOC = RI6.RI6_TIPDOC
     JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = COALESCE(SR7.R7_CARGO, SRA.RA_CARGO)
     JOIN %table:SQB% SQB_D ON SQB_D.%notDel% AND SQB_D.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB_D.QB_DEPTO = SRE.RE_DEPTOD
     JOIN %table:SQB% SQB_P ON SQB_P.%notDel% AND SQB_P.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB_P.QB_DEPTO = SRE.RE_DEPTOP
    WHERE SRE.%notDel% AND SRE.RE_FILIAL = %Exp:xFilial("SRE")% AND %Exp:cWhere%
    ORDER BY SRA.RA_FILIAL, RI6.RI6_NUMDOC, SRE.RE_DATA, SRA.RA_NOME
EndSql
oFilial:EndQuery()

oFunc:SetParentQuery()
oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oFilial:Print()

Return