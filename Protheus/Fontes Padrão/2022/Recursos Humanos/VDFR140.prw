#INCLUDE "VDFR140.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR140  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  31.12.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Controle de Exonerações                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR140(void)                                                ³±±
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
Function VDFR140()

Local aRegs := {}

Private oReport
Private cString		:= "SRA"
Private cPerg		:= "VDFR140"
Private aOrd    	:= {}
Private cTitulo		:= STR0001 //'Relatório de Controle de Exonerações/Demissões'
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
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 31.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR140                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR140 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local cDescri   := STR0002 //"Relatório de Controle de Exonerações/Demissões"

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)
oReport:nFontBody := 7							

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

oFunc := TRSection():New(oFilial, STR0004, ( "SRA","SQ3","SQB","RI5","RI6" )) //'Servidores'
oFunc:SetCellBorder("ALL",,, .T.)
oFunc:SetCellBorder("RIGHT")
oFunc:SetCellBorder("LEFT")
oFunc:SetCellBorder("BOTTOM")

nSeq := 0
TRCell():New(oFunc,	"","",'Nº', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão
TRCell():New(oFunc,"RA_MAT","SRA",STR0005,,6) //'Matrícula'
TRCell():New(oFunc,"RA_NOME","SRA",STR0006) //'Nome'
TRCell():New(oFunc,"Q3_DESCSUM","SQ3",STR0008) //'Cargo/Função'
TRCell():New(oFunc,"QB_DESCRIC","SQB",STR0007) //'Lotação'
TRCell():New(oFunc,"RI6_DTEFEI","RI6",STR0009) //'Efeito'
TRCell():New(oFunc,"RI6_NUMDOC","RI6",STR0010) //'Ato'
TRCell():New(oFunc,"RI5_DTATPO","RI5",STR0011) //'Data'

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 31.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR140                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR140 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oFilial 	 := oReport:Section(1), oFunc := oReport:Section(1):Section(1), cWhere := "%"
Local cRI6_DTSRA := cRI6_DTSR7 := cWhereSRA := cWhereSR7 := ""
Local cRI6RI7SQL := "%SR7.R7_DATA + SR7.R7_SEQ + SR7.R7_TIPO%"

If Empty(mv_par03)
	MsgInfo(STR0012) //"É obrigatório o preenchimento da competência ! Verifique os parâmetros !"
	Return 
EndIF

oReport:SetTitle(cTitulo + " [" + Trans(mv_par03, "@R 99/9999") + "]")
If Upper(TcGetDb()) $ "DB2_ORACLE_INFORMIX_POSTGRES"
	cRI6RI7SQL := StrTran(cRI6RI7SQL, "+", "||")
EndIf

cAliasQRY := GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

cWhere += "AND SRA.RA_CATFUNC IN ('0', '1', '2', '3', '5', '6') "
cWhere += "AND SRA.RA_DEMISSA BETWEEN '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "01' AND " +;
                                      "'" + Right(mv_par03, 4) + Left(mv_par03, 2) + "31'"

if !empty(MV_PAR01)		//-- Filial
	cWhere += " AND " + MV_PAR01
EndIf
if !empty(MV_PAR02)		//-- Matricula
	cWhere += " AND " + MV_PAR02
EndIf
cWhere += "%"

oFilial:BeginQuery()
BeginSql Alias cAliasQRY
	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SQB.QB_DESCRIC, SQ3.Q3_DESCSUM, SRA.RI6_DTEFEI, SRA.RI6_NUMDOC, SRA.RI5_DTATPO
	  FROM (SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CARGO, SRA.RA_DEPTO, SRA.RA_DEMISSA AS RI6_DTEFEI, 
	               RI6.RI6_NUMDOC, RI5.RI5_DTATPO
	          FROM %table:SRA% SRA
	  		  LEFT JOIN %table:RI6% RI6 ON RI6.%notDel% AND RI6.RI6_FILIAL = %Exp:xFilial("RI6")% AND RI6.RI6_FILMAT = SRA.RA_FILIAL 
 		  	   AND RI6.RI6_MAT = SRA.RA_MAT AND RI6.RI6_TABORI = %Exp:'SRG'%
	  		  LEFT JOIN %table:RI5% RI5 ON RI5.%notDel% AND RI5.RI5_FILIAL = %Exp:xFilial("RI5")% AND RI5.RI5_ANO = RI6.RI6_ANO 
               AND RI5.RI5_NUMDOC = RI6.RI6_NUMDOC AND RI5.RI5_TIPDOC = RI6.RI6_TIPDOC
             WHERE SRA.%notDel% %Exp:cWhere%
             UNION
            SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, 
                  (SELECT MAX(R7_CARGO) FROM %table:SR7% SR7N 
                    WHERE %notDel% AND R7_FILIAL = SR7.R7_FILIAL AND R7_MAT = SR7.R7_MAT AND R7_SEQ = SR7.R7_SEQ AND R7_TIPO = %Exp:'004'%
                      AND R7_DATA = (SELECT MAX(R7_DATA) FROM %table:SR7% 
                                      WHERE %notDel% AND R7_FILIAL = SR7N.R7_FILIAL AND R7_MAT = SR7N.R7_MAT 
                                       AND R7_SEQ = SR7N.R7_SEQ AND R7_TIPO = %Exp:'004'%)) AS RA_CARGO, 
                   CASE WHEN SRE.RE_DEPTOP <> %Exp:''% THEN SRE.RE_DEPTOP ELSE SRA.RA_DEPTO END AS RA_DEPTO, SR7.R7_DATA AS RI6_DTEFEI, 
                   RI6.RI6_NUMDOC, RI5.RI5_DTATPO
	          FROM %table:SRA% SRA
	          JOIN %table:SR7% SR7 ON SR7.%notDel% AND SR7.R7_FILIAL = SRA.RA_FILIAL AND SR7.R7_MAT = SRA.RA_MAT
	     LEFT JOIN (SELECT RE_FILIALP, RE_MATP, RE_DEPTOP, MAX(RE_DATA) AS RE_DATA
	                  FROM %table:SRE% SRE
	                 WHERE %notDel% AND RE_EMPP = %Exp:cEmpAnt% 
	                   AND RE_DATA <= %Exp:Right(mv_par03, 4) + Left(mv_par03, 2) + '31'%
                       AND R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:SRE%
                                           WHERE %notDel% AND RE_EMPP = %Exp:cEmpAnt%  AND RE_FILIALP = SRE.RE_FILIALP
                                             AND RE_MATP = SRE.RE_MATP AND RE_DATA <= SRE.RE_DATA)
                     GROUP BY RE_FILIALP, RE_MATP, RE_DEPTOP) SRE ON SRE.RE_FILIALP = SRA.RA_FILIAL AND SRE.RE_MATP = SRA.RA_MAT
	  		  LEFT JOIN %table:RI6% RI6 ON RI6.%notDel% AND RI6.RI6_FILIAL = %Exp:xFilial("RI6")% AND RI6.RI6_FILMAT = SRA.RA_FILIAL 
	  		   AND RI6.RI6_MAT = SRA.RA_MAT AND RI6.RI6_TABORI = %Exp:'SR7'% AND RI6.RI6_CHAVE = %Exp:cRI6RI7SQL%
	  		  LEFT JOIN %table:RI5% RI5 ON RI5.%notDel% AND RI5.RI5_FILIAL = %Exp:xFilial("RI5")% AND RI5.RI5_ANO = RI6.RI6_ANO 
               AND RI5.RI5_NUMDOC = RI6.RI6_NUMDOC AND RI5.RI5_TIPDOC = RI6.RI6_TIPDOC
             WHERE SRA.%notDel% %Exp:StrTran(StrTran(cWhere, "SRA.RA_CATFUNC", "SR7.R7_CATFUNC"), "SRA.RA_DEMISSA", "SR7.R7_DATA")%
               AND SR7.R7_TIPO = %Exp:'005'%) SRA
	  LEFT JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
	  LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = SRA.RA_DEPTO
  ORDER BY SRA.RA_FILIAL, SRA.RI6_NUMDOC, SRA.RI6_DTEFEI, SRA.RA_NOME
EndSql
oFilial:EndQuery()

oFunc:SetParentQuery()    
oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oFilial:Print()

Return
