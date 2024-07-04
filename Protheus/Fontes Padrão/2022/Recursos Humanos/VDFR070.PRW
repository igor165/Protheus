#Include "VDFR070.Ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ VDFR070 ³ Autor ³ Wagner Mobile Costa      ³ Data ³ 17.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Periodo Aquisitivo de Férias                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR070(void)                                                ³±±
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Function VDFR070()

Local aRegs := {}

Private oReport
Private cString	:= "SRA"
Private cPerg	   	:= "VDFR070"
Private cTitulo	:= STR0001 //'Relatório de Periodo Aquisitivo de Férias'
Private nSeq     	:= 0
Private cAliasQRY	:= GetNextAlias()

ValidPerg(aRegs, cPerg, .T.)

Pergunte(cPerg, .F.)

M->RA_FILIAL := ""	// Variavel para controle da numeração

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportDef  ³ Autor ³ Wagner Mobile Costa     ³ Data ³ 17.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR070                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR070                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR070 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local cDescri := STR0002  //'Relatório de período aquisitivo de ferias atuais e remanescentes de servidores e membros que visa auxiliar o gerenciamento dos períodos aquisitivos do servidores Efetivos, comissionados e membros'

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)
oReport:nFontBody	:= 7

// TRSection():New(	oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,;
//					lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)

oFilial := TRSection():New(oReport, STR0003 , { "SM0" })//'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

oFunc   := TRSection():New(oFilial, STR0004, { "SRA", "SQB", "SQ3" }) //'Servidores'

oFerias := TRSection():New(oFunc, STR0005, { "SR8", "RCM" }) //'Férias'
oFerias:SetCellBorder("ALL",,, .T.)
oFerias:SetCellBorder("RIGHT")
oFerias:SetCellBorder("LEFT")
oFerias:SetCellBorder("BOTTOM")

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish(),;
														 oReport:Section(1):Section(1):Init(), oReport:Section(1):Section(1):PrintLine(),;
														 oReport:Section(1):Section(1):Finish()), .F.) })

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
nSeq := 0
TRCell():New(oFunc,	"","", 'No', "99999", 5, /*lPixel*/,/*bBlock*/ { || 	If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																					AllTrim(Str(++ nSeq)) } )
TRCell():New(oFunc,	"RA_MAT","SRA", STR0006) //'Matrícula'
TRCell():New(oFunc,	"RA_NOME","SRA", STR0007) //'Nome'
TRCell():New(oFunc,	"RA_CATFUNC", "SRA", STR0008,,30) //'Tipo'
TRCell():New(oFunc,	"QB_DESCRIC","SQB", STR0009,, 30) //'Lotação'
TRCell():New(oFunc,	"Q3_DESCSUM","SQ3", STR0010,, 30 ) //'Cargo/Função'                                                              

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
TRCell():New(oFerias, "","",STR0011,"",30, /*lPixel*/,/*bBlock*/ {|| Dtoc((cAliasQry)->(RF_DATABAS)) + ' - ' + Dtoc((cAliasQry)->(RF_DATAFIM)) } ) //'Periodo Aquisitivo'
TRCell():New(oFerias, "","",STR0012,"9999",10, /*lPixel*/,/*bBlock*/ {|| Trans((cAliasQry)->RF_DIASDIR, "9999") } ) //'Saldo'
TRCell():New(oFerias, "","",STR0013,"",14, /*lPixel*/,/*bBlock*/ {|| (cAliasQry)->RF_TIPO } ) //'Tipo'

oFerias:SetLeftMargin(15)

Return (oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportPrint ³ Autor ³ Wagner Mobile Costa    ³ Data ³ 17.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR290                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR070                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR070 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)

Local cWhere     := "%", cRF_TIPOSQL := cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
Local oFilial    := oReport:Section(1)
Local oFunc      := oReport:Section(1):Section(1)
Local oFerias    := oReport:Section(1):Section(1):Section(1)

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

If ! Empty(mv_par01)		//-- Filial
	cWhere += StrTran(mv_par01, "RA_FILIAL", "RF_FILIAL")
EndIf

If ! Empty(mv_par02)		//-- Matricula
	If Len(cWhere) > 1
		cWhere += " AND "
	EndIf
	cWhere += mv_par02
EndIf

If ! Empty(mv_par03)		//-- Lotação/Departamento
	If Len(cWhere) > 1
		cWhere += " AND "
	EndIf
	cWhere += mv_par03
EndIf

//-- Monta a string de categorias
If AllTrim( mv_par04 ) <> Replicate("*", Len(AllTrim( mv_par04 )))
	cRA_CATFUN   := ""
	For nCont  := 1 to Len(Alltrim(mv_par04)) Step nTRACATFUN
		If Substr(mv_par04, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par04, nCont, nTRACATFUN)))
			cRA_CATFUN += "'" + Substr(mv_par04, nCont, nTRACATFUN) + "',"
		EndIf
	Next
	
	cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)

	If Len(cWhere) > 1
		cWhere += " AND "
	EndIf
	
	If !Empty(AllTrim(cRA_CATFUN))
		cWhere += ' SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
	EndIf
	 
EndIf


If mv_par05 <> 1 //	Exibe Férias Proporcionais
	If Len(cWhere) > 1
		cWhere += " AND "
	EndIf
	cWhere += "SRF.RF_DATAFIM < '" + Dtos(FirstDay(dDataBase)) + "'"
EndIf

If cWhere == "%"
	cWhere += "1=1"
EndIf
cWhere += "%"

cRF_TIPOSQL := "%CASE WHEN SRA.RA_CATFUNC IN ('2','3','5','6') AND SRV.RV_CODFOL = '0072' THEN '" + STR0014 + "' ELSE " +;
                  "CASE WHEN SRA.RA_CATFUNC IN ('0','1')         AND SRV.RV_CODFOL = '0072' THEN '" + STR0016 + "' ELSE " +;
                  "CASE WHEN SRA.RA_CATFUNC IN ('0','1')         AND SRV.RV_CODFOL = '1335' THEN '" + STR0015 + "' ELSE '' END END END%"

// STR0014 'Regulamentares'
// STR0015 'Compensatórias'
// STR0016 'Ordinárias'


oFilial:BeginQuery()
BeginSql Alias cAliasQRY
	COLUMN RF_DATABAS as DATE
	COLUMN RF_DATAFIM as DATE

	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SX5.X5_DESCRI AS RA_CATFUNC, SQB.QB_DESCRIC, SQ3.Q3_DESCSUM, SRA.RA_NOME,  
           SRF.RF_DATABAS, SRF.RF_DATAFIM, RF_DIASDIR - RF_DIASPRG AS RF_DIASDIR, %Exp:cRF_TIPOSQL% AS RF_TIPO
      FROM %table:SRF% SRF
      JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SRF.RF_FILIAL AND SRA.RA_MAT = SRF.RF_MAT
      JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
      LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = SRA.RA_DEPTO
      JOIN %table:SX5% SX5 ON SX5.%notDel% AND SX5.X5_FILIAL = %Exp:xFilial("SX5")% AND SX5.X5_TABELA = %Exp:'28'% AND SX5.X5_CHAVE = SRA.RA_CATFUNC
      JOIN %table:SRV% SRV ON SRV.%notDel% AND SRV.RV_FILIAL = %Exp:xFilial("SRV")% AND SRV.RV_COD = SRF.RF_PD 
       AND SRV.RV_CODFOL IN (%Exp:'0072'%, %Exp:'1335'%)
     WHERE SRF.%notDel% AND SRA.RA_DEMISSA = %Exp:''% AND %Exp:cWhere% AND SRF.RF_STATUS IN (%Exp:' '%, %Exp:'0'%, %Exp:'1'%)
  ORDER BY SRA.RA_FILIAL, SRA.RA_NOME, SRF.RF_DATABAS
EndSql
oFilial:EndQuery()

oFunc:SetParentQuery()
oFunc:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL) == cParam}, {|| (cAliasQry)->(RA_FILIAL) })

oFerias:SetParentQuery()
oFerias:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL + RA_MAT) == cParam}, {|| (cAliasQry)->(RA_FILIAL + RA_MAT) })

oFilial:Print()

Return
