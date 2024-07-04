#INCLUDE "VDFR110.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR110  ³ Autor ³ Alexandre Florentino³    Data ³  26.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relação de Servidores Cedidos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR110(void)                                                ³±±
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
Function VDFR110()

Local aRegs := {}

Private oReport
Private cString	:= "RID"
Private cPerg		:= "VDFR110"
Private aOrd    	:= {}
Private cTitulo		:= STR0001 //'Relatório de Servidores Cedidos para Outro Órgão'
Private nSeq 		:= 0
Private cAliasQRY	:= GetNextAlias()
Private cFilFunc	:= ""

Pergunte(cPerg, .F.)


oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Alexandre Florentino³    Data ³ 26.02.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR110                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR110 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

	Local cDescri   := STR0002 //"Esse relatório será emitido com base nas informações contidas no cadastro de Adidos e Cedidos."

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	TRCell():New(oFilial,"RID_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(cFilFunc <> (cAliasQry)->RID_FILIAL, (cFilFunc := (cAliasQry)->RID_FILIAL, nSeq := 0), Nil),;
																 	 fDesc("SM0", cEmpAnt + (cAliasQry)->(RID_FILIAL), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0004, ( "SRA","SQ3","SQB","RID" )) //'Servidores'

	nSeq := 0
	TRCell():New(oFunc,	"","",'Nº', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o número(sequencial) na linha de impressão
	TRCell():New(oFunc,"RA_MAT","SRA",STR0005, /*cPicture*/, 12) //'Matrícula'
	TRCell():New(oFunc,"RA_NOME","SRA",STR0006, /*cPicture*/, 32) //'Nome'
	TRCell():New(oFunc,"RID_ORGAO","RID",STR0007,, 30) //'Órgão'
	TRCell():New(oFunc,	"","", STR0011 ,/*cPicture*/, 30,/*lPixel*/, { || (cAliasQRY)->Q3_DESCSUM },; //'Cargo / Função'
					/*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/)  
	TRCell():New(oFunc,"RID_SITUACAO","RID",STR0008,,30) //'Situação'
	TRCell():New(oFunc,"RID_DATINI","RID",STR0009, /*cPicture*/, 12, /*lPixel*/, /*bBlock*/, "CENTER") //'Data início'
	TRCell():New(oFunc,"RID_DTPREV","RID",STR0010, /*cPicture*/, 12, /*lPixel*/, /*bBlock*/, "CENTER") //'Data Final'

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Alexandre Florentino ³ Data ³ 26.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR110                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR110 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oFilial 		:= oReport:Section(1), oFunc := oReport:Section(1):Section(1), cWhere := "%"
Local cRI6_DTSQL 	:= cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
Local cJoinSQ3		:= cJoinRCC		:= ""

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	cMV_PAR := ""
	
	If !Empty(MV_PAR01)		//-- Filial
		cMV_PAR += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cMV_PAR += " AND " + MV_PAR02
	EndIf

	cMV_PAR += "%"

	cWhere += cMV_PAR
	cJoinSQ3 := "%" + FWJoinFilial("SQ3","RID") + "%"
	cJoinRCC := "%" + FWJoinFilial("RCC","RID") + "%"
	
	oFilial:BeginQuery()
	BeginSql Alias cAliasQRY
		COLUMN RID_DATINI as DATE
		COLUMN RID_DTPREV as DATE
			
		SELECT RID.RID_FILIAL, SRA.RA_MAT, SRA.RA_NOME, RID.RID_ORGAO, SQ3.Q3_DESCSUM, SUBSTRING(RCC.RCC_CONTEU, 2, 30) AS RID_SITUACAO, 
		       RID.RID_DATINI, RID.RID_DTPREV
		  FROM %table:RID% RID
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = RID.RID_FILIAL AND SRA.RA_MAT = RID.RID_MAT 
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO 
		  JOIN %table:RCC% RCC ON RCC.%notDel% AND %Exp:cJoinRCC% AND RCC.RCC_CODIGO = %Exp:'S105'% AND SUBSTRING(RCC.RCC_CONTEU, 1, 1) = RID.RID_TIADCD
          AND (RCC.RCC_FIL = SRA.RA_FILIAL OR RCC.RCC_FIL = '') 
		 WHERE RID.%notDel% %Exp:cWhere% AND RID.RID_TIADCD IN (%Exp:'1'%, %Exp:'2'%, %Exp:'3'%) AND RID.RID_DATFIM = %Exp:''%
 		 ORDER BY SRA.RA_FILIAL, SRA.RA_NOME		
	EndSql	

	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->RID_FILIAL == cParam}, {|| (cAliasQRY)->RID_FILIAL  })

	oFilial:Print()

Return
