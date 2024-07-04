#Include "VDFR080.Ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o  ³ VDFR080  ³ Autor ³ Robson Soares de Morais ³ Data ³  19.12.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Relatório de férias já usufruídas membros e servidores		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR080(void)                                                ³±±
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

Function VDFR080()

Local aRegs := {}

Private oReport
Private cString  	:= "SRA"
Private cPerg	  	:= "VDFR080"
Private cTitulo	:= STR0001 //'Relatório de férias já usufruídas Membros e Servidores'
Private nSeq      	:= 0
Private cAliasQRY	:=  GetNextAlias()

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
±±³Fun‡ao  ³ ReportDef  ³ Autor ³ Robson Soares de Morais ³ Data ³ 19.12.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR080                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR080                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR080 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local cDescri := STR0001 //'Relatório de férias já usufruídas membros e servidores'

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)
oReport:nFontBody	:= 7

// TRSection():New(	oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,;
//					lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)

oFilial := TRSection():New(oReport, STR0002, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

oFunc   := TRSection():New(oFilial, STR0003, { "SRA", "SQB", "SQ3" } ) //'Servidores'
oFerias := TRSection():New(oFunc, STR0004, { "RIA", "SRF" }) //'Afastamentos'
oFerias:SetCellBorder("ALL",,, .T.)
oFerias:SetCellBorder("RIGHT")
oFerias:SetCellBorder("LEFT")
oFerias:SetCellBorder("BOTTOM")
oFerias:SetLeftMargin(15)

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
nSeq := 0
TRCell():New(oFunc, "","",'No.',"99999", 5, /*lPixel*/,/*bBlock*/ { || 	If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																					AllTrim(Str(++ nSeq)) } )
TRCell():New(oFunc, "RA_MAT","SRA",STR0005) //'Matricula'
TRCell():New(oFunc, "RA_NOME","SRA",STR0006) //'Nome'
TRCell():New(oFunc, "RA_CATFUNC", "SRA",STR0007,,30) //'Tipo'
TRCell():New(oFunc, "QB_DESCRIC","SQB",STR0008,,30) //'Lotação'
TRCell():New(oFunc, "Q3_DESCSUM","SQ3",STR0009,,30) //'Cargo/Função'

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
TRCell():New(oFerias, "","",STR0010,"",30, /*lPixel*/,;
						/*bBlock*/ {|| Dtoc((cAliasQry)->(RF_DATABAS)) + ' - ' + Dtoc((cAliasQry)->(RF_DATAFIM)) }, "CENTER" ) //'Periodo Aquisitivo'
TRCell():New(oFerias, "RIA_DATINI","RIA",STR0011, /*cPicture*/, /*nSize*/, /*lPixel*/, /*bBlock*/, "CENTER") //'Inicio das Férias'
TRCell():New(oFerias, "RIA_DATFIM","RIA",STR0012, /*cPicture*/, /*nSize*/, /*lPixel*/, /*bBlock*/, "CENTER") //'Fim das Férias'
TRCell():New(oFerias, "","",STR0013,"",14, /*lPixel*/,/*bBlock*/ {|| (cAliasQry)->RF_TIPO } ) //'Tipo'
TRCell():New(oFerias, "RIA_NRDGOZ","RIA",STR0014,"") //'Dias Gozo'
TRCell():New(oFerias, "RIA_NRDIND","RIA",STR0015,"") //'Indenizadas'
TRCell():New(oFerias, "RIA_STATUS","RIA",STR0016,"") //'Situação'

Return (oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportPrint ³ Autor ³ Robson Soares de Morais ³ Data ³ 19.12.13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR080                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR080                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR080 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportPrint(oReport)

Local cWhere     := "%", cRF_TIPOSQL := cRIAStatus := cDataFim := "" 
Local cRA_CATFUN := ""
Local nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" )
Local nCont      := 0
Local oFilial    := oReport:Section(1)
Local oFunc      := oReport:Section(1):Section(1)
Local oFerias    := oReport:Section(1):Section(1):Section(1)
Local cJoinSQ3	 := ""
Local cJoinSRV	 := ""
Local cJoinSQB	 := ""
Local cJoinSX5	 := ""

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

If ! Empty(mv_par01)		//-- Filial
	cWhere += mv_par01
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
	
	If ! Empty(AllTrim(cRA_CATFUN))
		cWhere += 'SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
	EndIf
		
EndIf

If cWhere == "%"
	cWhere += "1=1"
EndIf
cWhere += "%"

cDataFim = "%RIA.RIA_DATFIM < '" + Dtos(FirstDay(dDataBase)) + "'%"

cRF_TIPOSQL := "%CASE WHEN SRA.RA_CATFUNC IN ('2','3','4','5','6') 	AND SRV.RV_CODFOL = '0072' THEN '" + STR0017 + "' ELSE " +;
                "CASE WHEN SRA.RA_CATFUNC IN ('0','1')         		AND SRV.RV_CODFOL = '0072' THEN '" + STR0019 + "' ELSE " +;
                "CASE WHEN SRA.RA_CATFUNC IN ('0','1')				AND SRV.RV_CODFOL = '1335' THEN '" + STR0018 + "' ELSE '' END END END%"
cRIAStatus	:= "%CASE WHEN RIA.RIA_STATUS = '0' THEN '" + STR0020 + "' ELSE " +;
				"CASE WHEN RIA.RIA_STATUS = '1' THEN '" + STR0021 + "' ELSE " +;
				"CASE WHEN RIA.RIA_STATUS = '2' THEN '" + STR0022 + "' ELSE " +;
				"CASE WHEN RIA.RIA_STATUS = '3' THEN '" + STR0023 + "' ELSE " +;
				"CASE WHEN RIA.RIA_STATUS = '4' THEN '" + STR0024 + "' ELSE '' END END END END END%"

//STR0017 'Regulamentares'
//STR0018 'Compensatórias'
//STR0019 'Ordinárias'
//STR0020 'Programado'
//STR0021 'Cancelado'
//STR0022 'Suspenso'
//STR0023 'Retificado'
//STR0024 'Quitado'


cJoinSQ3 := "%" + FWJoinFilial("SQ3","RIA") + "%"
cJoinSRV := "%" + FWJoinFilial("SRV","RIA") + "%"
cJoinSQB := "%" + FWJoinFilial("SQB","RIA") + "%"
cJoinSX5 := "%" + FWJoinFilial("SX5","RIA") + "%"

oFilial:BeginQuery()
BeginSql Alias cAliasQRY

  	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SX5.X5_DESCRI AS RA_CATFUNC, SQB.QB_DESCRIC, SQ3.Q3_DESCSUM, SRA.RA_NOME,  
	       SRF.RF_DATABAS, SRF.RF_DATAFIM, RF_DIASDIR - RF_DIASPRG AS RF_DIASDIR, RIA.RIA_NRDGOZ, RIA.RIA_NRDIND,
	       RIA.RIA_DATINI, RIA.RIA_DATFIM, %Exp:cRF_TIPOSQL% AS RF_TIPO, %Exp:cRIAStatus% AS RIA_STATUS
	  FROM %table:RIA% RIA
	  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = RIA.RIA_FILIAL AND SRA.RA_MAT = RIA.RIA_MAT AND SRA.RA_DEMISSA = %Exp:''%
	  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO
	  JOIN %table:SRV% SRV ON SRV.%notDel% AND %Exp:cJoinSRV% AND SRV.RV_COD = RIA.RIA_PD 
	   AND SRV.RV_CODFOL IN (%Exp:'0072'%, %Exp:'1335'%)
	  LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cJoinSQB% AND SQB.QB_DEPTO = SRA.RA_DEPTO
	  JOIN %table:SX5% SX5 ON SX5.%notDel% AND %Exp:cJoinSX5% AND SX5.X5_TABELA = %Exp:'28'% 
	   AND SX5.X5_CHAVE = SRA.RA_CATFUNC
	  JOIN %table:SRF% SRF ON SRF.%notDel% AND SRF.RF_FILIAL = RIA.RIA_FILIAL AND SRF.RF_MAT = RIA.RIA_MAT AND 
	  		RIA.RIA_PD = SRF.RF_PD AND RIA.RIA_DTINPA = SRF.RF_DATABAS AND %Exp:cDataFim% 
	WHERE RIA.%notDel% AND %Exp:cWhere%
	ORDER BY SRA.RA_FILIAL, SRA.RA_NOME, RIA.RIA_DTINPA, RIA.RIA_DATINI

EndSql
oFilial:EndQuery()

oFunc:SetParentQuery()
oFunc:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL) == cParam}, {|| (cAliasQry)->(RA_FILIAL) })

oFerias:SetParentQuery()
oFerias:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL + RA_MAT) == cParam}, {|| (cAliasQry)->(RA_FILIAL + RA_MAT) })

oFilial:Print()

Return
