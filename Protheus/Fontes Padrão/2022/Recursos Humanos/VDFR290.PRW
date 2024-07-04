#Include "VDFR290.Ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o  ³ VDFR290  ³ Autor ³ Robson Soares de Morais ³ Data ³  03.12.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Licenças e Afastamentos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR290(void)                                                ³±±
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

Function VDFR290()

Local aRegs := {}

Private oReport
Private cString	:= "SRA"
Private cPerg	    := "VDFR290"
Private cTitulo	:= STR0001 //- 'Relatório de Licenças e Afastamentos'
Private nSeq      	:= 0
Private cAliasQRY	:= GetNextAlias()

Pergunte(cPerg, .F.)

M->RA_FILIAL := ""	// Variavel para controle da numeração

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportDef  ³ Autor ³ Robson Soares de Morais ³ Data ³ 03.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR290                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR290                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR290 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local cDescri := STR0001 //- 'Relatório de Licenças e Afastamentos'
Local aOrd    := { STR0003, STR0004 }  //- Matricula Nome

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 3)
oReport:nFontBody := 7

// TRSection():New(	oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,;
//					lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)

oFilial := TRSection():New(oReport, STR0005, { "SM0" }, aOrd) //- Filiais 
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

oFunc := TRSection():New(oFilial, STR0006, { "SRA", "SQB", "SQ3" })  // - Servidores
oFunc:SetCellBorder("ALL",,, .T.)
oFunc:SetCellBorder("RIGHT")
oFunc:SetCellBorder("LEFT")
oFunc:SetCellBorder("BOTTOM")

oAfast := TRSection():New(oFunc, STR0007, { "SR8", "RCM" })                 // - Afastamentos
oAfast:SetCellBorder("ALL",,, .T.)
oAfast:SetCellBorder("RIGHT")
oAfast:SetCellBorder("LEFT")
oAfast:SetCellBorder("BOTTOM")

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish(),;
														 oReport:Section(1):Section(1):Init(), oReport:Section(1):Section(1):PrintLine(),;
														 oReport:Section(1):Section(1):Finish()), .F.) })

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
nSeq := 0
TRCell():New(oFunc,	"","", 'No', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } )
TRCell():New(oFunc,	"RA_MAT","SRA", STR0003,, 12) //- Matrícula
TRCell():New(oFunc,	"RA_NOME","SRA")
TRCell():New(oFunc,	"RA_CATFUNC", "SRA", STR0008,,32) //- Tipo
TRCell():New(oFunc,	"QB_DESCRIC","SQB",STR0009)  //- Lotação
TRCell():New(oFunc,	"Q3_DESCSUM","SQ3",STR0010)  //- Cargo / Função                                                               

oAfast:SetLeftMargin(10)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
TRCell():New(oAfast, "R8_GEDOC", "SR8", STR0011)   //- 'Nº Gedoc'
TRCell():New(oAfast, "R8_DATAINI", "SR8", STR0012,, 12) //- 'Inicio Licença'
TRCell():New(oAfast, "R8_DATAFIM", "SR8", STR0013,, 12) //- 'Fim Licença'  
TRCell():New(oAfast, "","", STR0014,, 13, /*lPixel*/,/*bBlock*/ { || 	Trans(If(! Empty((cAliasQry)->R8_DATAFIM),;  //- 'Dias Licenca'
																				(cAliasQry)->R8_DATAFIM - (cAliasQry)->R8_DATAINI + 1, 0), "@E 9999") } )
TRCell():New(oAfast, "RCM_DESCRI", "RCM", 'Tipo')

Return (oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportPrint ³ Autor ³ Robson Soares de Morais ³ Data ³ 05.12.13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR290                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR290                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR290 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)

Local cWhere  	:= "%", cOrdem := cCodAfas := "", nTamCodAfas := GetSx3Cache( "RCM_TIPO", "X3_TAMANHO" ), nCont := 0
Local oFilial 	:= oReport:Section(1)
Local oFunc   	:= oReport:Section(1):Section(1)
Local oAfast  	:= oReport:Section(1):Section(1):Section(1)
Local cAux    	:= ""
Local cJoinSQ3	:= ""
Local cJoinSQB	:= ""
Local cJoinSX5	:= ""
Local cJoinRCM	:= ""

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

cAux := SubStr(mv_par03, 22,8)

If ! Empty(mv_par01)		//-- Filial                  

	cWhere += " AND " + mv_par01
EndIf

If ! Empty(mv_par02)		//-- Matricula
	cWhere += " AND " + mv_par02
EndIf

If ! Empty(mv_par03)		//-- Data Inicial e Final
   cWhere += " AND ((" + mv_par03 + ") OR (" + StrTran(mv_par03, "R8_DATAINI", "R8_DATAFIM") + ") OR ( R8_DATAINI < '" + cAux + "' AND R8_DATAFIM = ' ' )) "
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
cWhere += "%"

cOrdem  := "%SRA.RA_FILIAL, " + If(oFilial:GetOrder() == 2, "SRA.RA_NOME", "SRA.RA_MAT") + ", SR8.R8_DATAINI DESC%"

cJoinSQ3 := "%" + FWJoinFilial("SQ3","SRA") + "%"
cJoinSQB := "%" + FWJoinFilial("SQB","SRA") + "%"
cJoinSX5 := "%" + FWJoinFilial("SX5","SRA") + "%"
cJoinRCM := "%" + FWJoinFilial("RCM","SRA") + "%"

oFilial:BeginQuery()
BeginSql Alias cAliasQRY
	COLUMN R8_DATAINI as DATE
	COLUMN R8_DATAFIM as DATE

	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SX5.X5_DESCRI AS RA_CATFUNC, SQB.QB_DESCRIC, SQ3.Q3_DESCSUM, SR8.R8_GEDOC, 
	       SR8.R8_DATAINI, SR8.R8_DATAFIM, RCM.RCM_DESCRI
	 FROM %table:SR8% SR8 
	 JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT AND SRA.RA_DEMISSA = %Exp:' '%
	 JOIN %table:SX5% SX5 ON SX5.%notDel% AND %Exp:cJoinSX5% AND SX5.X5_TABELA = %Exp:'28'% AND SX5.X5_CHAVE = SRA.RA_CATFUNC
	 JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO
	 LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cJoinSQB% AND SQB.QB_DEPTO = SRA.RA_DEPTO
	 LEFT JOIN %table:RCM% RCM ON RCM.%notDel% AND %Exp:cJoinRCM% AND RCM.RCM_TIPO = SR8.R8_TIPOAFA 
	WHERE SR8.%notDel% %Exp:cWhere%
	ORDER BY %exp:cOrdem%
EndSql
oFilial:EndQuery()

oFunc:SetParentQuery()
oFunc:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL) == cParam}, {|| (cAliasQry)->(RA_FILIAL) })

oAfast:SetParentQuery()
oAfast:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL + RA_MAT) == cParam}, {|| (cAliasQry)->(RA_FILIAL + RA_MAT) })

oFilial:Print()

Return
