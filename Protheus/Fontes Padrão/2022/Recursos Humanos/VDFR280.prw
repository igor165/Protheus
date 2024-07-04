#INCLUDE "VDFR280.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR280  ³ Autor ³ Robson Soares de Morais³ Data ³  27.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quadro de Provimento de Membros por Categoria                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR280(void)                                                ³±±
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

Function VDFR280()

Local aRegs := {}

Private oReport
Private cString	:= "SRA"
Private cPerg		:= "VDFR280"
Private aOrd    	:= {}
Private cTitulo	:= STR0001 //'Quadro de Provimento de Membros por Categoria'
Private nSeq 		:= 0
Private cAliasQRY	:= ""

Pergunte(cPerg, .F.)

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Robson Soares de Morais³ Data ³ 27.01.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR280                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR280 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local cDescri   := STR0002 //"Quadro de Provimento de Membros por Categoria"

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 3)
oReport:nFontBody := 7

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""
oFilial:nLinesBefore   := 0

oFilial:bOnPrintLine := { || (oReport:SkipLine(), 	oReport:PrintText(AllTrim(RetTitle("RA_FILIAL")) + ': ' +;
													(cAliasQry)->(RA_FILIAL) + " - " +;
													fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")),oReport:SkipLine(), .F.) } 

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )

oCargo := TRSection():New(oFilial, STR0004, ( "SRA","SQ3","SQB","RI5","RI6" )) //'Servidores'

TRCell():New(oCargo,"","",STR0005, , 61, /*lPixel*/,/*bBlock*/ { || AllTrim((cAliasQry)->(Q3_DESCSUM)) + '-' +;
																	AllTrim((cAliasQry)->(RER_DESCR)) } ) //Denominação dos Cargos //'Denominação dos Cargos'
TRCell():New(oCargo,"SQ3_VAGAS","SQ3",STR0006, "@E 99999",18) //Quantidade Cargos
TRCell():New(oCargo,"CARGOS","SQ3",STR0007, "@E 99999",18) //Numero de Servidores efetivos ocupando a vaga //'Cargos Preenchidos'
TRCell():New(oCargo,"VAGOS","RCC",STR0008, "@E 99999",12) //Numero de Servidores ocupando a vaga de comissionado //'Cargos Vagos'

oCargo:SetLeftMargin(15)
oCargo:SetCellBorder("ALL",,, .T.)
oCargo:SetCellBorder("RIGHT")
oCargo:SetCellBorder("LEFT")
oCargo:SetCellBorder("BOTTOM")

	oBrkGrupo := TRBreak():New(oCargo, { || (cAliasQry)->RA_FILIAL },{|| STR0009 },,,.F.)	//	" TOTAL/CARGOS " //"TOTAL/CARGOS"

	oTSQ3_VAGAS := TRFunction():New(oCargo:Cell("SQ3_VAGAS"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,"@E 99999",;
			{ || (cAliasQry)->SQ3_VAGAS },.F.,.F.,.F.,oCargo)

	oTCARGOS := TRFunction():New(oCargo:Cell(STR0010),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,"@E 99999",; //"CARGOS"
			{ || (cAliasQry)->CARGOS },.F.,.F.,.F.,oCargo)

	oTVAGOS := TRFunction():New(oCargo:Cell(STR0011),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,"@E 99999",; //"VAGOS"
			{ || (cAliasQry)->VAGOS },.F.,.F.,.F.,oCargo)
			
	oReport:SetPageFooter( 03, {|| prnRodape(oReport) } )

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportPrint ³ Autor ³ Robson Soares de Morais³ Data ³ 27.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR280                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR280 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport)

Local oFilial		:= oReport:Section(1), oCargo := oReport:Section(1):Section(1), cWhere := "%", nCont := 0
Local cQ3_TIPO		:= "", nQ3_TIPO   := GetSx3Cache( "Q3_TIPO", "X3_TAMANHO" )
Local cFilParam		:= ""
Local cJoinRCC		:= ""
Local cJoinRER		:= ""
Local cJoinSQB		:= ""
Local cJoinSQ3		:= ""
Local cJoinREC		:= ""
Local cJoinRBR		:= ""
Local nX			:= 0
Local aFilParam		:= {}
cAliasQRY			:= GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)
cFilParam:= StrTran(StrTran(StrTran(MV_PAR01,"RA_FILIAL IN",''),"((",""),"))","")
aFilParam	:= IIF(!Empty(cFilParam),STRTOKARR(cFilParam,","),) 

cJoinRER:= "%"+ FWJoinFilial("REC","RER")+"%"
cJoinRBR:= "%"+ FWJoinFilial("SQ3","RBR")+"%"
cJoinSQ3:= "%"+ FWJoinFilial("SRA","SQ3")+"%"
cJoinSQB:= "%"+ FWJoinFilial("SRA","SQB")+"%"
cJoinREC:= "%"+ FWJoinFilial("REC","SQB")+"%"
cJoinRCC :="%"+ FWJoinFilial("SRA","RCC")+"%"
cMV_PAR := ""
if !empty(MV_PAR01)		//-- Filial
	cMV_PAR += " AND " + MV_PAR01
EndIf
if !empty(MV_PAR02)		//-- Matricula
	cMV_PAR += " AND " + MV_PAR02
EndIf
if AllTrim( mv_par03 ) <> Replicate("*", Len(AllTrim( mv_par03 )))		//-- Tipo
	cQ3_TIPO  := ""
	For nCont := 1 to Len(Alltrim(mv_par03)) Step nQ3_TIPO
		cQ3_TIPO += "'" + Substr(mv_par03, nCont, nQ3_TIPO) + "',"
	Next
	cQ3_TIPO := Left( cQ3_TIPO, Len(cQ3_TIPO)-1)
	If !Empty(AllTrim(cQ3_TIPO))
		cMV_PAR += ' AND SQ3.Q3_TIPO IN (' + cQ3_TIPO + ')'
	EndIf
EndIf

cMV_PAR += "%"

cWhere += cMV_PAR

oFilial:BeginQuery()

BeginSql Alias cAliasQRY

SELECT SRA.RA_FILIAL, SQ3.Q3_DESCSUM, RER.RER_DESCR, MIN(RCC.SQ3_VAGAS) AS SQ3_VAGAS, COUNT(*) AS CARGOS,
       MIN(RCC.SQ3_VAGAS) - COUNT(*) AS VAGOS
  FROM %table:SRA% SRA
  JOIN %table:SQ3% SQ3 ON 
  		SQ3.%notDel% AND 
  		%Exp:cJoinSQ3%  	AND 
  		SQ3.Q3_CARGO = SRA.RA_CARGO 		AND 
  		SQ3.Q3_TABELA <> %Exp:' '%
  
  JOIN (SELECT RBR.RBR_FILIAL,RBR.RBR_TABELA, RBR.RBR_DESCTA
		FROM %table:RBR% RBR
        WHERE 	RBR.%notDel% AND 
        			RBR.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) 
        								FROM %table:RBR% 
        								WHERE %notDel% AND  
        									RBR_TABELA = RBR.RBR_TABELA AND
        									RBR_DTREF < %Exp:dDataBase%)) RBR ON 
        			RBR.RBR_TABELA = SQ3.Q3_TABELA
  JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cJoinSQB% AND SQB.QB_DEPTO = SRA.RA_DEPTO
  JOIN %table:REC% REC ON REC.%notDel% AND  %Exp:cJoinREC% AND REC.REC_CODIGO = SQB.QB_COMARC
  JOIN %table:RER% RER ON RER.%notDel% AND %Exp:cJoinRER% AND RER.RER_CODIGO = REC.REC_REGIAO
  LEFT JOIN (SELECT RCC_FILIAL,CASE WHEN RCC_FIL = %Exp:' '% THEN %Exp:cFilAnt% ELSE RCC_FIL END AS RCC_FIL,
                    SUBSTRING(RCC_CONTEU, 1, 5) AS RA_CARGO, SUBSTRING(RCC_CONTEU, 6, 6) AS QB_COMARC,
                    SUM(CAST(SUBSTRING(RCC_CONTEU, 13, 5) AS INTEGER)) AS SQ3_VAGAS
               FROM %table:RCC% RCC
              	WHERE %notDel% AND RCC_CODIGO = %Exp:'S111'%
           GROUP BY RCC_FILIAL, 
           	CASE WHEN RCC_FIL = %Exp:' '% THEN %Exp:cFilAnt% ELSE RCC_FIL END, 
              	SUBSTRING(RCC_CONTEU, 1, 5), SUBSTRING(RCC_CONTEU, 6, 6)) RCC ON 
              	%Exp:cJoinRCC% AND (RCC.RCC_FIL = SRA.RA_FILIAL OR RCC.RCC_FIL = '') AND
              	RCC.RA_CARGO = SRA.RA_CARGO AND 
              	RCC.QB_COMARC = SQB.QB_COMARC
 WHERE SRA.%notDel% AND SRA.RA_CATFUNC IN (%Exp:'0'%, %Exp:'1'%) %Exp:cWhere%
 GROUP BY SRA.RA_FILIAL, SQ3.Q3_DESCSUM, RER.RER_DESCR
 ORDER BY SRA.RA_FILIAL, SQ3.Q3_DESCSUM, RER.RER_DESCR
EndSql

oFilial:EndQuery()

oCargo:SetParentQuery()
oCargo:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oFilial:Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportPrint ³ Autor ³ Robson Soares de Morais³ Data ³ 27.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime o objeto oReport definido na funcao ReportDef		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR280                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR280 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function prnRodape(oReport)

oReport:PrtLeft(mv_par04)
oReport:PrtRight(STR0013 + DTOC(dDataBase))

Return

/*/{Protheus.doc} f_QbrFil
Rotina que monta a quebra das filiais para relatórios específicos do VDF
@type function
@author Eduardo
@since 18/10/2018
@version 1.0
@param cTabela, character, Tabela a Verificar
@param aFilParam, array, Filiais a montar o xfilial
/*/Function f_QbrFil(cTabela,aFilParam)
Local cFil		:= "' ',"
Local nX			:= "" 

Default aFilParam	:= {}

Default cTabela	:= ""
If Len(aFilParam)> 0 
	For nX:= 1 to Len(aFilParam)
		cFil:= cFil+ "'"+Alltrim(xFilial(cTabela,StrTran(aFilParam[nX],"'","")))+"'"
		If nX < len(aFilParam)
			cFil	+=","
		EndIf
	Next nX
Else
	cFil:= cFil+ "'"+xFilial(cTabela)+"'"
Endif
//cFil := Substr(cFil,at("'",cFil)+1,rat("'",cFil)-2)
Return cFil