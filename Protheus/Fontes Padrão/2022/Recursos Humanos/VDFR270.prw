#INCLUDE "VDFR270.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR270  ³ Autor ³ Robson Soares de Morais³ Data ³  20.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Quadro Porcentagem Cargo em Comissão Reservado para Efetivos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR270(void)                                                ³±±
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

Function VDFR270()

Local aRegs := {}

Private oReport
Private cString	:= "SRA"
Private cPerg		:= "VDFR270"
Private aOrd    	:= {}
Private cTitulo	:= STR0001 //'Quadro de Porcentagem de Cargo em Comissão Reservado Para Efetivos'
Private nSeq 		:= 0
Private cAliasQRY := ""
Private oCCargo

Pergunte(cPerg, .F.)

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Robson Soares de Morais³ Data ³ 20.01.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR270                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR270 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local cDescri  := STR0002 //"Relatórios quantitativos mensais atualizados sempre que há alteração no quadro de ocupação dos cargos comissionados, efetivos e membros"

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

oCargo := TRSection():New(oFilial, STR0004, ( "SRA","SQ3","RCC", "SX5" )) //'Servidores'
oCargo:SetLeftMargin(10)
oCargo:SetCellBorder("ALL",,, .T.)
oCargo:SetCellBorder("RIGHT")
oCargo:SetCellBorder("LEFT")
oCargo:SetCellBorder("BOTTOM")

oCCargo := TRCell():New(oCargo,"X5_DESCRI","SX5",mv_par04,,) //Denominação dos Cargos //'Lei n.º 9.782 de 19 de julho de 2012 (Artigo 14)'
TRCell():New(oCargo,"SQ3_MINIMO","RCC",'% Minima',, 12) //Percentual minimo de servidores efetivos
TRCell():New(oCargo,"SQ3_VAGAS","RCC",'Quantidade Cargos',, 20) //Numero de vagas autorizadas
TRCell():New(oCargo,"EFETIVO","SRA",'Quantidade Ocupada por Efetivo',,35) //Numero de Servidores efetivos ocupando vaga
TRCell():New(oCargo,"PER_TOTAL","SRA",'% Total', "@E 999.9 %", 12) //Percentual total de servidores efetivos ocupando os cargos

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 20.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR270                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR270 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport)

Local oFilial := oReport:Section(1), oCargo := oReport:Section(1):Section(1), cWhere := "%"
Local cRBR_TABELA	:= "", nTamTabela := GetSx3Cache( "RBR_TABELA", "X3_TAMANHO" ), nCont := 0, cWhereRBR := cWhereQ3 := "%%"
Local cQ3_TIPO		:= "", nTQ3_TIPO  := GetSx3Cache( "Q3_TIPO", "X3_TAMANHO" )
Local cJoinRCC		:= ""
Local cJoinSQ3		:= ""
Local cJoinRCCM 	:= ""
cAliasQRY := GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

cJoinSQ3:= "%"+ FWJoinFilial("SRA","SQ3")+"%"
cJoinRCC :="%"+ FWJoinFilial("SRA","RCC")+"%"
cJoinRCCM :="%"+ REPLACE(FWJoinFilial("SRA","RCC"),"RCC.","RCC_M.")+"%"
cMV_PAR := ""
if !empty(MV_PAR01)		//-- Filial
	cMV_PAR += " AND " + MV_PAR01
EndIf
if !empty(MV_PAR02)		//-- Matricula
	cMV_PAR += " AND " + MV_PAR02
EndIf
cMV_PAR += "%"

cWhere += cMV_PAR

//-- Monta a string de Tipos de Cargo
If AllTrim( mv_par03 ) <> Replicate("*", Len(AllTrim( mv_par03 )))
	cQ3_TIPO   := ""
	For nCont  := 1 to Len(Alltrim(mv_par03)) Step nTQ3_TIPO
		cQ3_TIPO += "'" + Substr(mv_par03, nCont, nTQ3_TIPO) + "',"
	Next
	cQ3_TIPO := Substr( cQ3_TIPO, 1, Len(cQ3_TIPO)-1)
	If !Empty(AllTrim(cQ3_TIPO))
		cWhereQ3 := '%AND SQ3.Q3_TIPO IN (' + cQ3_TIPO + ')%'
	EndIf
EndIf

oFilial:BeginQuery()

oCCargo:cTitle := mv_par04

BeginSql Alias cAliasQRY

SELECT SRA.RA_FILIAL, SX5.X5_DESCRI, MIN(RCC_M.SQ3_VAGAS) AS SQ3_MINIMO, MIN(RCC.SQ3_VAGAS) AS SQ3_VAGAS,
       COUNT(CASE WHEN RA_CATFUNC = %Exp:'3'% THEN 1 ELSE NULL END) AS EFETIVO,
       CAST(CAST(COUNT(CASE WHEN RA_CATFUNC = %Exp:'3'% THEN 1 ELSE NULL END) AS NUMERIC(18,6)) / 
       CAST(MIN(RCC.SQ3_VAGAS) AS NUMERIC(18,6)) * 100 AS NUMERIC(5, 1)) AS PER_TOTAL
  FROM %table:SRA% SRA
  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO %Exp:cWhereQ3% 
  JOIN %table:SX5% SX5 ON SX5.%notDel% AND SX5.X5_TABELA = %Exp:'RH'% AND SX5.X5_CHAVE = SQ3.Q3_TIPO
  LEFT JOIN (SELECT RCC_FILIAL,RCC_FIL,SUBSTRING(RCC_CONTEU, 1, 5) AS RA_CARGO,
                    SUM(CAST(SUBSTRING(RCC_CONTEU, 13, 5) AS INTEGER)) AS SQ3_VAGAS
               FROM %table:RCC% RCC
              WHERE %notDel% AND RCC_CODIGO = %Exp:'S111'%
              GROUP BY RCC_FILIAL,RCC_FIL,SUBSTRING(RCC_CONTEU, 1, 5)) RCC ON RCC.RA_CARGO = SRA.RA_CARGO AND %Exp:cJoinRCC% AND (RCC.RCC_FIL = SRA.RA_FILIAL OR RCC.RCC_FIL = '') 
  LEFT JOIN (SELECT RCC_FILIAL,RCC_FIL,SUBSTRING(RCC_CONTEU, 1, 2) AS Q3_TIPO,
                    SUM(CAST(SUBSTRING(RCC_CONTEU, 3, 5) AS NUMERIC(18,2))) AS SQ3_VAGAS
               FROM %table:RCC% RCC
              WHERE %notDel% AND  RCC_CODIGO = %Exp:'S110'%
              GROUP BY RCC_FILIAL,RCC_FIL,SUBSTRING(RCC_CONTEU, 1, 2)) RCC_M ON RCC_M.Q3_TIPO = SQ3.Q3_TIPO AND %Exp:cJoinRCCM%  AND (RCC_M.RCC_FIL = SRA.RA_FILIAL OR RCC_M.RCC_FIL = '')
 WHERE SRA.%notDel% AND SRA.RA_CATFUNC IN (%Exp:'3'%, %Exp:'6'%) %Exp:cWhere%
 GROUP BY SRA.RA_FILIAL, SX5.X5_DESCRI
 ORDER BY SRA.RA_FILIAL, SX5.X5_DESCRI

EndSql

oFilial:EndQuery()

oCargo:SetParentQuery()
oCargo:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oFilial:Print()

Return