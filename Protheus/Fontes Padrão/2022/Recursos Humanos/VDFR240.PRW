#INCLUDE "VDFR240.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ VDFR240 ³ Autor ³ Alexandre Florentino  ³    Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Controle de Recesso Remunerado de Estagiários   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR240()                                                    ³±±
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

Function VDFR240()

	Private oReport
	Private	cString	   := "SRA"
	Private cPerg	   := "VDFR240"
	Private cTitulo	   := STR0001 //'Relatório de Controle de Recesso Remunerado de Estagiários'
	Private nSeq       := 0
	Private cAliasQRY  := GetNextAlias()

	Pergunte(cPerg, .F.)
	M->RA_FILIAL := ""	// Variavel para controle da numeração

	oReport := ReportDef()
	oReport:PrintDialog()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportDef  ³ Autor ³ Alexandre Florentino    ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR240                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR240                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR240 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

	Local cDescri := STR0016 //'Esse relatório será emitido com base nas informações contidas nas rotinas de Controle de Dias de Direito, especificamente para o controle de Recesso de Estagiários'

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)

	// TRSection():New(	oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,;
	//					lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)

	oFilial := TRSection():New(oReport, STR0002, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	oFunc   := TRSection():New(oFilial, STR0003, { "SRA", "SQ3" }) //'Servidores'
	oFerias := TRSection():New(oFunc, STR0004, { "RIA" }) //'Férias'

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish(),;
															 oReport:Section(1):Section(1):Init(), oReport:Section(1):Section(1):PrintLine(),;
															 oReport:Section(1):Section(1):Finish()), .F.) })

	TRCell():New(oFilial,"RA_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																 	 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

	//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
	nSeq := 0
	TRCell():New(oFunc,	"","", 'No', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } )
	TRCell():New(oFunc,	"RA_MAT","SRA", STR0005) //'Matrícula'
	TRCell():New(oFunc,	"RA_NOME","SRA", STR0006 ) //'Nome'
	TRCell():New(oFunc,	"RA_ADMISSA", "SRA", STR0007) //'Data Credenciamento'
	
	//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
	oFerias:SetLeftMargin(5)
	oFerias:SetCellBorder("ALL",,, .T.)
	oFerias:SetCellBorder("RIGHT")
	oFerias:SetCellBorder("LEFT")
	oFerias:SetCellBorder("BOTTOM")

	TRCell():New(oFerias, "","",STR0008,"",23, /*lPixel*/,/*bBlock*/;
	{|| " " + 	Alltrim(Str(Year((cAliasQry)->(RF_DATABAS)))) + ' / ' +;
				Alltrim(Str(Year((cAliasQry)->(RF_DATAFIM)))) } ) //'Periodo Aquisitivo'
	TRCell():New(oFerias,	"RIA_DATINI","RIA", " " + STR0009,"",, /*lPixel*/,/*bBlock*/ {|| " " + DTOC((cAliasQry)->RIA_DATINI) }  ) //'Inicio das Férias'
	TRCell():New(oFerias,	"RIA_DATFIM","RIA", " " + STR0010,"",, /*lPixel*/,/*bBlock*/ {|| " " + DTOC((cAliasQry)->RIA_DATFIM) }  ) //'Fim das Férias'
	TRCell():New(oFerias, "",""," " + STR0011,"",12, /*lPixel*/,/*bBlock*/ {|| " " + (cAliasQry)->RIA_SITUACAO } ) //'Situação'
	TRCell():New(oFerias, "",""," " + STR0012,"",9, /*lPixel*/,/*bBlock*/;
				{|| " " + xRETFERIAS((cAliasQry)->(RIA_DATINI), (cAliasQry)->(RIA_DATFIM), (cAliasQry)->(RF_DIAS)) } ) //'Dias'

Return (oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportPrint ³ Autor ³ Alexandre Florentino   ³ Data ³ 12.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR240                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR240                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR240 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)

Local cWhere     := "%", cIdFol := cRF_TIPOSQL := cRA_CATFUN := cAberto := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" )
Local oFilial    := oReport:Section(1), nCont := 0
Local oFunc      := oReport:Section(1):Section(1)
Local oFerias    := oReport:Section(1):Section(1):Section(1)

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + MV_PAR01
	EndIf

	If ! Empty(mv_par02)	//-- Matricula
		cWhere += " AND " + mv_par02
	EndIf

	If !Empty(mv_par03)		//-- Lotação/Departamento
		cWhere += " AND " + mv_par03
	EndIf

	If !Empty(mv_par04)	//-- Admissão de/ate
		cWhere += " AND " + mv_par04
	EndIf
    
	If !Empty(mv_par05)	//-- Programação de
		cWhere += " AND ((" + mv_par05 + " OR RIA_FILIAL IS NULL))"
	EndIf
    
	If !Empty(mv_par06)	//-- Programação até
		cWhere += " AND ((" + mv_par06 + " OR RIA_FILIAL IS NULL))"
	EndIf

	cWhere += "%"
 
	cRF_TIPOSQL := "%CASE WHEN RIA.RIA_FILIAL IS NULL THEN '" + STR0013 + "' ELSE " +;   //'EM ABERTO'
					"CASE WHEN NOT RIA.RIA_FILIAL IS NULL AND RIA.RIA_DATFIM <= " + dToc(dDataBase) + " THEN '" + STR0014 + "' ELSE '" + STR0015 + "' END END%"  //'GOZADA'###'PROGRAMADA'
	cAberto := "%'" + STR0013 + "'%"

	oFilial:BeginQuery()
		
	BeginSql Alias cAliasQRY
		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA, SRF.RF_DATABAS, SRF.RF_DATAFIM, RIA.RIA_DATINI, RIA.RIA_DATFIM, 
		       SQ3.Q3_DESCSUM, CASE WHEN RIA.RIA_FILIAL IS NULL THEN SRF.RF_DIASDIR - SRF.RF_DIASPRG ELSE 0 END AS RF_DIAS, 
		       %Exp:cRF_TIPOSQL% AS RIA_SITUACAO
		  FROM %table:SRF% SRF
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SRF.RF_FILIAL AND SRA.RA_MAT = SRF.RF_MAT
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
		  LEFT JOIN %table:RIA% RIA ON RIA.%notDel% AND RIA.RIA_FILIAL = SRF.RF_FILIAL AND RIA.RIA_MAT = SRF.RF_MAT AND RIA.RIA_PD = SRF.RF_PD 
		   AND RIA.RIA_STATUS <> %Exp:'4'% AND RIA.RIA_DTINPA = SRF.RF_DATABAS
		  JOIN %table:SRV% SRV ON SRV.%notDel% AND SRV.RV_FILIAL = %Exp:xFilial("SRV")% AND SRV.RV_COD = SRF.RF_PD AND SRV.RV_CODFOL = %Exp:'0891'%
 		 WHERE SRF.%notDel% %Exp:cWhere% AND SRA.RA_CATFUNC IN (%Exp:'E'%, %Exp:'G'%) AND SRA.RA_SITFOLH <> %Exp:'D'%
		 UNION ALL
		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA, SRF.RF_DATABAS, SRF.RF_DATAFIM, %Exp:'99999999'% AS RIA_DATINI, 
		       %Exp:''% AS RIA_DATFIM, SQ3.Q3_DESCSUM, SRF.RF_DIASDIR - SRF.RF_DIASPRG AS RF_DIAS, %Exp:cAberto% AS RIA_SITUACAO
		  FROM %table:SRF% SRF
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SRF.RF_FILIAL AND SRA.RA_MAT = SRF.RF_MAT
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
		  JOIN %table:SRV% SRV ON SRV.%notDel% AND SRV.RV_FILIAL = %Exp:xFilial("SRV")% AND SRV.RV_COD = SRF.RF_PD AND SRV.RV_CODFOL = %Exp:'0891'%
		  LEFT JOIN %table:RIA% RIA ON RIA.%notDel% AND RIA.RIA_FILIAL = SRF.RF_FILIAL AND RIA.RIA_MAT = SRF.RF_MAT AND RIA.RIA_PD = SRF.RF_PD 
		   AND RIA.RIA_STATUS <> %Exp:'4'% AND RIA.RIA_DTINPA = SRF.RF_DATABAS
 		 WHERE SRF.%notDel% %Exp:cWhere% AND SRA.RA_CATFUNC IN (%Exp:'E'%, %Exp:'G'%) AND SRA.RA_SITFOLH <> %Exp:'D'%
 		   AND SRF.RF_DIASDIR - SRF.RF_DIASPRG > 0 AND NOT RIA.RIA_FILIAL IS NULL
		ORDER BY RA_FILIAL, RA_NOME, RIA_DATINI
	
	EndSql
	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL) == cParam}, {|| (cAliasQry)->(RA_FILIAL) })

	oFerias:SetParentQuery()
	oFerias:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL + RA_MAT) == cParam}, {|| (cAliasQry)->(RA_FILIAL + RA_MAT) })

	oFilial:Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ xRETFERIAS ³ Autor ³ Alexandre Florentino   ³ Data ³ 13.02.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna dias de ferias                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ xRETFERIAS(dInicio, dFim)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dInicio , dFim                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ xRETFERIAS - Generico - Release 4                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function xRETFERIAS(dInicio, dFim, nDias)
	
	Local cDias  := " "
	Local nAux   := 0
	
	Default dInicio := cTod(Space(8))  	
    Default dFim    := cTod(Space(8))  
    
    If nDias > 0
    	Return AllTrim(Str(nDias))
    EndIf
    
    If !Empty(dInicio) .OR. !Empty(dFim)
		
		While dInicio <= dFim  
			dInicio := dInicio +=1
			nAux += 1 	 
		Enddo	 
        
    	cDias := Alltrim(Str(nAux))
    	
    EndIf 
    
Return cDias
