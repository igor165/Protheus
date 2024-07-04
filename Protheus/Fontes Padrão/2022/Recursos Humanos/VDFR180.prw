#INCLUDE "VDFR180.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR180  ³ Autor ³ Robson Soares de Morais³ Data ³  02.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Retorno de Afastamentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR180(void)                                                ³±±
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

Function VDFR180()

Local aRegs := {}

Private oReport
Private cString	:= "SRA"
Private cPerg		:= "VDFR180"
Private aOrd    	:= {}
Private cTitulo	:= STR0001 //'Relatório de Retorno de Afastamentos'
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
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Robson Soares de Morais³ Data ³ 02.01.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR180                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR180 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local cDescri   := STR0002 //"Esse relatório será emitido com base nas informações contidas no cadastro de Afastamentos"

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							.T.,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

TRCell():New(oFilial,"RA_FILIAL","SR8")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

oFunc := TRSection():New(oFilial, STR0004, ( "SRA","SQ3","SQB","RI5","RI6" )) //'Servidores'

nSeq := 0
TRCell():New(oFunc,   	        "",      "",                   'Nº', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão
TRCell():New(oFunc, "RA_MAT", "SRA", STR0005,,6) //'Matrícula'
TRCell():New(oFunc, "RA_NOME", "SRA", STR0006,,40) //'Nome'
TRCell():New(oFunc, "Q3_DESCSUM", "SQ3", STR0007,,40) //'Cargo/Função'
TRCell():New(oFunc, "QB_DESCRIC", "SQB", STR0013,, 40) // Lotação
TRCell():New(oFunc, "RCM_DESCRI", "RCM", STR0008,,60) //Afastamento do servidor - R8_TIPOAFA = RCM_TIPO //'Afastamento/Motivo'
TRCell():New(oFunc, "R8_DATAFIM", "SR8", STR0009,,10) //'Efeito'
TRCell():New(oFunc, "RI6_NUMDOC", "RI6", STR0010,,5) //'Ato'
TRCell():New(oFunc, "RI5_DTATPO", "RI5", STR0011,,10) //'Data'

Return(oReport)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint  ³ Autor ³ Wagner Mobile Costa       ³ 01.01.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³  Impressão do conteúdo do relatório                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR180                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR180 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oFilial     := oReport:Section(1), oFunc := oReport:Section(1):Section(1), cWhere := cWhereSR7 := "%"  
Local cRA_CATFUN  := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
Local nTamCodAfas := 3
Local cRI6SR8SQL  := "%SR8.R8_DATAINI + SR8.R8_TIPOAFA%"

If Empty(mv_par03)
	MsgInfo(STR0012) //É obrigatório o preenchimento da competência ! Verifique os parâmetros !'
	Return 
EndIF
    
oReport:SetTitle(cTitulo + " [" + Trans(mv_par03, "@R 99/9999") + "]")
If Upper(TcGetDb()) $ "DB2_ORACLE_INFORMIX_POSTGRES"
	cRI6SR8SQL := StrTran(cRI6SR8SQL, "+", "||")
EndIf

cAliasQRY := GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

If !Empty(MV_PAR01)		//-- Filial
	cWhere += " AND " + MV_PAR01
	cWhereSR7 += " AND " + StrTran(MV_PAR01, "RA_FILIAL", "R7_FILIAL")
EndIf

If !Empty(MV_PAR02)		//-- Matricula
	cWhere += " AND " + MV_PAR02
	cWhereSR7 += " AND " + StrTran(MV_PAR02, "RA_MAT", "R7_MAT")
EndIf

//-- Monta a string de Codigos de Afastamentos para Impressao
If AllTrim( mv_par04 ) <> Replicate("*", Len(AllTrim( mv_par04 )))
	cCodAfas   := ""
	
	For nCont  := 1 to Len(Alltrim(mv_par04)) Step nTamCodAfas
		cCodAfas += "'" + Substr(mv_par04, nCont, nTamCodAfas) + "',"
	Next

	cCodAfas := Substr( cCodAfas, 1, Len(cCodAfas)-1)
   	
	If !Empty(AllTrim(cCodAfas))
		cWhere += ' AND SR8.R8_TIPOAFA IN (' + cCodAfas + ')'
	EndIf	
EndIf

//-- Monta a string com as categorias a serem listadas
If AllTrim( mv_par05 ) <> Replicate("*", Len(AllTrim( mv_par05 )))
	cRA_CATFUN   := ""
	For nCont  := 1 to Len(Alltrim(mv_par05)) Step nTRACATFUN
		If Substr(mv_par05, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par05, nCont, nTRACATFUN)))
			cRA_CATFUN += "'" + Substr(mv_par05, nCont, nTRACATFUN) + "',"
		EndIf
	Next
	cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)

	If ! Empty(AllTrim(cRA_CATFUN))
		cWhere += 'AND COALESCE(SR7.R7_CATFUNC, SRA.RA_CATFUNC) IN (' + cRA_CATFUN + ')'
	EndIf
EndIf

cWhere += " AND SR8.R8_DATAFIM BETWEEN '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "01' AND " +;
                                      "'" + Right(mv_par03, 4) + Left(mv_par03, 2) + "31'"
cWhereSR7 += " AND R7_DATA <= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "31'"

cWhere += "%"
cWhereSR7 += "%"

oFilial:BeginQuery()
	BeginSql Alias cAliasQRY
		
	SELECT RA_FILIAL, RA_MAT, RA_NOME, Q3_DESCSUM, SQB.QB_DESCRIC, RCM_DESCRI, SR8.R8_DATAFIM AS RI6_DTEFEI, 
	       RI6_NUMDOC, RI5_DTATPO, RI6_NUMDOC, R8_DATAFIM
	  FROM %table:SR8% SR8
	  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT  
	  LEFT JOIN (SELECT R7_FILIAL, R7_MAT, MAX(R7_CATFUNC) AS R7_CATFUNC, MAX(R7_CARGO) AS R7_CARGO FROM %table:SR7% SR7
    	          WHERE %notDel% %Exp:cWhereSR7%
        	        AND R7_DATA = (SELECT MAX(R7_DATA) FROM %table:SR7% 
            	                    WHERE %notDel% %Exp:cWhereSR7% AND R7_FILIAL = SR7.R7_FILIAL AND R7_MAT = SR7.R7_MAT 
                	                  AND R7_SEQ = SR7.R7_SEQ AND R7_TIPO = SR7.R7_TIPO)
	              GROUP BY R7_FILIAL, R7_MAT) SR7 ON SR7.R7_FILIAL = SRA.RA_FILIAL AND SR7.R7_MAT = SRA.RA_MAT
      LEFT JOIN (SELECT RE_FILIALP, RE_MATP, RE_DEPTOP, MAX(RE_DATA) AS RE_DATA
	               FROM %table:SRE% SRE
	               WHERE %notDel% AND RE_EMPP = %Exp:cEmpAnt% 
	                 AND RE_DATA <= %Exp:Right(mv_par03, 4) + Left(mv_par03, 2) + '31'%
                     AND R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:SRE%
                                         WHERE %notDel% AND RE_EMPP = %Exp:cEmpAnt%  AND RE_FILIALP = SRE.RE_FILIALP
                                           AND RE_MATP = SRE.RE_MATP AND RE_DATA <= SRE.RE_DATA)
                   GROUP BY RE_FILIALP, RE_MATP, RE_DEPTOP) SRE ON SRE.RE_FILIALP = SRA.RA_FILIAL AND SRE.RE_MATP = SRA.RA_MAT
	  LEFT JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = COALESCE(SR7.R7_CARGO, SRA.RA_CARGO)
	  LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% 
       AND SQB.QB_DEPTO = CASE WHEN SRE.RE_DEPTOP <> %Exp:''% THEN SRE.RE_DEPTOP ELSE SRA.RA_DEPTO END
	  LEFT JOIN %table:RCM% RCM ON RCM.%notDel% AND RCM.RCM_FILIAL = %Exp:xFilial("RCM")% AND RCM.RCM_TIPO = SR8.R8_TIPOAFA 
	  LEFT JOIN %table:RI6% RI6 ON RI6.%notDel% AND RI6.RI6_FILIAL = %Exp:xFilial("RI6")% AND RI6.RI6_FILMAT = SRA.RA_FILIAL 
	   AND RI6.RI6_MAT = SRA.RA_MAT AND RI6.RI6_TABORI = %Exp:'SR8'% AND RI6.RI6_CHAVE = %Exp:cRI6SR8SQL%
	  LEFT JOIN %table:RI5% RI5 ON RI5.%notDel% AND RI5.RI5_FILIAL = %Exp:xFilial("RI5")% AND RI5.RI5_ANO = RI6.RI6_ANO 
	   AND RI5.RI5_NUMDOC = RI6.RI6_NUMDOC AND RI5.RI5_TIPDOC = RI6.RI6_TIPDOC  
  	 WHERE SR8.%notDel% %Exp:cWhere%
	 ORDER BY SRA.RA_FILIAL, RI6.RI6_NUMDOC, SR8.R8_DATAFIM, SRA.RA_NOME 

	EndSql 
oFilial:EndQuery()

oFunc:SetParentQuery()
oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oFilial:Print()

Return Nil
