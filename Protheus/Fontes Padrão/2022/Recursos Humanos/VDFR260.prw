#INCLUDE "VDFR260.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR260  ³ Autor ³ Robson Soares de Morais³ Data ³  20.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quadro do Grupo de Provimento em Comissão por Categoria      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR260(void)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     																³±±
±±³Joao Balbino	12/06/2015  TSNAH2  Corrigido a query que retorna os dados para que não busque  ±±³
±±³																				Funcionarios demitidos																			±±³
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function VDFR260()

Local aRegs := {}

Private oReport
Private cString	:= "SRA"
Private cPerg		:= "VDFR260"
Private aOrd    	:= {}
Private cTitulo	:= STR0001 //'Quadro do Grupo de Provimento em Cargo Comissionado por Categoria'
Private cAliasQRY := ""
Private oQ3_DESCSUM

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
±±³Sintaxe   ³ VDFR260                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR260 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local cDescri  := STR0002 //"Relatórios quantitativos mensais atualizados sempre que há alteração no quadro de ocupação dos cargos comissionados, efetivos e membros"

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)
oReport:nFontBody := 7

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""
oFilial:nLinesBefore   := 0

oFilial:bOnPrintLine := { || (oReport:SkipLine(), 	oReport:PrintText(AllTrim(RetTitle("RA_FILIAL")) + ': ' +;
													(cAliasQry)->(RA_FILIAL) + " - " +;
													fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")), .F.) } 

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )

oCargo := TRSection():New(oFilial, STR0004, ( "SRA","SQ3","RCC" )) //'Servidores'
oCargo:SetLeftMargin(15)
oCargo:SetCellBorder("ALL",,, .T.)
oCargo:SetCellBorder("RIGHT")
oCargo:SetCellBorder("LEFT")
oCargo:SetCellBorder("BOTTOM")

TRCell():New(oCargo,"Q3_DESCSUM","SQ3",STR0005,, 40) //Denominação dos Cargos //'Denominação dos Cargos'
TRCell():New(oCargo,"RBR_SIMBOL","RBR",STR0010) //'Simbolo'
TRCell():New(oCargo,"SQ3_VAGAS","RCC",STR0006, "@E 99999") //Quantidade Cargos //'Número de Vagas'
TRCell():New(oCargo,"EFETIVO","SRA",STR0007, "@E 99999") //Numero de Servidores efetivos ocupando a vaga //'Efetivo'
TRCell():New(oCargo,"COMISSAO","SRA",STR0008, "@E 99999") //Numero de Servidores ocupando a vaga de comissionado //'Comissão'
TRCell():New(oCargo,"VAGOS","RCC",STR0009, "@E 99999") //Cargos vagos. (Numero de Vagas - (Efetivo + Comissionado)) = Vagos //'Vagos'

oBrkGrupo := TRBreak():New(oCargo, { || .T. },{|| "TOTAL/CARGOS" },,,.F.)	//	" TOTAL/CARGOS "

oTSQ3_VAGAS := TRFunction():New(oCargo:Cell("SQ3_VAGAS"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,"@E 99999",;
		{ || (cAliasQry)->SQ3_VAGAS },.F.,.F.,.F.,oCargo)

oTEFETIVO := TRFunction():New(oCargo:Cell("EFETIVO"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,"@E 99999",;
		{ || (cAliasQry)->EFETIVO },.F.,.F.,.F.,oCargo)

oTCOMISSAO := TRFunction():New(oCargo:Cell("COMISSAO"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,"@E 99999",;
		{ || (cAliasQry)->COMISSAO },.F.,.F.,.F.,oCargo)

oTVAGOS := TRFunction():New(oCargo:Cell("VAGOS"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,"@E 99999",;
		{ || (cAliasQry)->VAGOS },.F.,.F.,.F.,oCargo)


Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint³ Autor ³ Robson Soares de Morais³ Data ³ 20.01.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR260                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR260 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport)

Local oFilial := oReport:Section(1), oCargo := oReport:Section(1):Section(1), cWhere := "%"
Local cRBR_TABELA	:= "", nTamTabela := GetSx3Cache( "RBR_TABELA", "X3_TAMANHO" ), nCont := 0, cWhereRBR := cWhereQ3 := "%%"
Local cQ3_TIPO		:= "", nTQ3_TIPO  := GetSx3Cache( "Q3_TIPO", "X3_TAMANHO" )
Local cFilParam		:= ""
Local cJoinRCC		:= ""
Local cJoinRBR		:= ""
Local cJoinSQ3		:= ""
Local cFilRBR		:= ""
Local nX			:= 0
Local aFilParam		:= {}
cAliasQRY := GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)
cFilParam:= StrTran(StrTran(StrTran(MV_PAR01,"RA_FILIAL IN",''),"((",""),"))","")
aFilParam	:= STRTOKARR(cFilParam,",") 
cJoinSQ3	:= "%"+ FWJoinFilial("SRA","SQ3")+"%"
cJoinRCC	:="%"+ FWJoinFilial("SRA","RCC")+"%"
cJoinRBR	:= "%"+ FWJoinFilial("SQ3","RBR")+"%"
cFilRBR	:= "%" + f_QbrFil("RBR",aFilParam)+"%"
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
		cWhereQ3 := '%AND Q3_TIPO IN (' + cQ3_TIPO + ')%'
	EndIf
EndIf

oFilial:BeginQuery()

cMesAno := StrZero(Month(dDataBase), 2) + Str(Year(dDataBase), 4)

BeginSql Alias cAliasQRY

SELECT SRA.RA_FILIAL, RBR.RBR_SIMBOL, SQ3.Q3_DESCSUM, MIN(RCC.SQ3_VAGAS) AS SQ3_VAGAS,
       COUNT(CASE WHEN RA_CATFUNC = %Exp:'3'% THEN 1 ELSE NULL END) AS EFETIVO,
       COUNT(CASE WHEN RA_CATFUNC = %Exp:'6'% THEN 1 ELSE NULL END) AS COMISSAO,
       MIN(RCC.SQ3_VAGAS) - COUNT(CASE WHEN RA_CATFUNC = %Exp:'3'% THEN 1 ELSE NULL END) -
                            COUNT(CASE WHEN RA_CATFUNC = %Exp:'6'% THEN 1 ELSE NULL END) AS VAGOS
  FROM %table:SRA% SRA
  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND (%Exp:cJoinSQ3%) AND SQ3.Q3_CARGO = SRA.RA_CARGO %Exp:cWhereQ3%
   AND SQ3.Q3_TABELA <> %Exp:' '%
  JOIN (SELECT RBR.RBR_FILIAL,RBR.RBR_TABELA, RBR.RBR_DESCTA, RBR.RBR_SIMBOL 
          FROM %table:RBR% RBR
         WHERE 	RBR.%notDel% %Exp:cWhereRBR% AND 
         			RBR.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM %table:RBR% 
         								WHERE 	%notDel% AND RBR_FILIAL in (%Exp:cFilRBR%)AND 
         										RBR_TABELA = RBR.RBR_TABELA AND 
         										RBR_DTREF < %Exp:Dtos(dDataBase)%
         										GROUP BY 
         										RBR_FILIAL)) RBR ON 
         	RBR.RBR_TABELA = SQ3.Q3_TABELA AND %Exp:cJoinRBR% 
  LEFT JOIN (SELECT RCC_FILIAL,RCC_FIL,SUBSTRING(RCC_CONTEU, 1, 5) AS RA_CARGO,
                    SUM(CAST(SUBSTRING(RCC_CONTEU, 13, 5) AS INTEGER)) AS SQ3_VAGAS
               FROM %table:RCC% RCC
              WHERE %notDel% AND RCC_FILIAL = %Exp:xFilial("RCC")% AND RCC_CODIGO = %Exp:'S111'%
		   GROUP BY RCC_FILIAL,RCC_FIL,SUBSTRING(RCC_CONTEU, 1, 5)) RCC ON RCC.RA_CARGO = SRA.RA_CARGO AND %Exp:cJoinRCC% AND (RCC.RCC_FIL = SRA.RA_FILIAL OR RCC.RCC_FIL = '')
 WHERE SRA.%notDel% %Exp:cWhere% AND SRA.RA_CATFUNC IN (%Exp:'3'%, %Exp:'6'%) AND SRA.RA_SITFOLH NOT IN ('D')
 GROUP BY SRA.RA_FILIAL, RBR.RBR_SIMBOL, SQ3.Q3_DESCSUM
 ORDER BY SRA.RA_FILIAL, RBR.RBR_SIMBOL, SQ3.Q3_DESCSUM

EndSql

oFilial:EndQuery()

oCargo:SetParentQuery()
oCargo:SetParentFilter({|cParam| (cAliasQRY)->(RA_FILIAL) == cParam}, {|| (cAliasQRY)->(RA_FILIAL) })

oFilial:Print()

Return