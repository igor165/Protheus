#INCLUDE "VDFR220.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o  ³ VDFR220  ³ Autor ³ Alexandre Florentino ³    Data ³  07.02.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Relatório de Férias Indenizadas		                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR220()                                                    ³±±
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
Function VDFR220()

	Private oReport
	Private cString  	:= "SRA"
	Private cPerg	  	:= "VDFR220"
	Private cTitulo	:= STR0001 //'Relatório de Férias Indenizadas'
	Private nSeq      	:= 0
	Private cAliasQRY	:= GetNextAlias()

	M->RA_FILIAL := ""	// Variavel para controle da numeração
	
	Pergunte(cPerg, .F.)
	oReport := ReportDef()
	oReport:PrintDialog()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportDef  ³ Autor ³ Alexandre Florentino    ³ Data ³ 07.02.14 ³±±
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

	Local cDescri := STR0002 //'Esse relatório será emitido com base nas informações contidas nos Lançamentos da rotina de Dias de Direito e Programação de Férias – SRF/RIA'

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)
	oReport:nFontBody := 7

	oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	oFunc   := TRSection():New(oFilial, STR0004, { "SRA", "SQB", "SQ3", "RIA", "SRF"  } ) //'Servidores'

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	TRCell():New(oFilial,"RA_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

	nSeq := 0

	TRCell():New(oFunc, "","",'No',"99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } )
	TRCell():New(oFunc, "RA_MAT","SRA",STR0005,, 10) //'Matrícula'
	TRCell():New(oFunc, "RA_NOME","SRA",STR0006,, 31) //'Nome'
	TRCell():New(oFunc, "Q3_DESCSUM","SQ3",STR0007,, 30) //'Cargo/Função'
	TRCell():New(oFunc, "","",STR0008,"",23, /*lPixel*/,/*bBlock*/ {|| Dtoc((cAliasQry)->(RF_DATABAS)) + '-' + Dtoc((cAliasQry)->(RF_DATAFIM)) }, "CENTER" ) //'Periodo Aquisitivo'
	TRCell():New(oFunc, "","",STR0009,"",16, /*lPixel*/,/*bBlock*/ {|| Alltrim(MES_AUX((cAliasQry)->(RF_DATABAS))) + '/' + Alltrim(Str(YEAR((cAliasQry)->(RF_DATABAS)))) }, "CENTER" ) //'Mês/Férias em que faz jus'
	TRCell():New(oFunc, "","",STR0010,"",14, /*lPixel*/,/*bBlock*/ {|| Alltrim(MES_AUX((cAliasQry)->(RIA_DTPGAD))) + '/' + Alltrim(Str(YEAR((cAliasQry)->(RIA_DTPGAD))))}, "CENTER" ) //'Mês Indenização'

	TRCell():New(oFunc, "RIA_NRDIND","RIA",STR0011,"",13, /*lPixel*/,/*bBlock*/ {|| Trans((cAliasQry)->RIA_NRDIND, "@E 99") }, "CENTER" ) //'Dias de Indenização'

Return (oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ ReportPrint ³ Autor ³ Alexandre Florentino ³    Data ³ 07.02.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório VDFR220                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR220                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR220 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport)
	
	Local cWhere  := "%", cIdFol := cRF_TIPOSQL := cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
	Local oFilial := oReport:Section(1)
	Local oFunc   := oReport:Section(1):Section(1)

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If !Empty(mv_par01)		//-- Filial
		cWhere += " AND " + mv_par01
	EndIf                                                                                                         			

	If !Empty(mv_par02)		//-- Período Indenização  De ?
		cWhere += " AND SUBSTRING(RIA.RIA_DTPGAD,1,6) >= '" + Right(mv_par02, 4) + Left(mv_par02, 2) + "'"
	EndIf
                                                                                          			
	If !Empty(mv_par03)		//-- Período Indenização  Ate ?
		cWhere += " AND SUBSTRING(RIA.RIA_DTPGAD,1,6) <= '" + Right(mv_par03, 4) + Left(mv_par03, 2) + "'"
	EndIf

	//-- Monta a string com as categorias a serem listadas
	If AllTrim( mv_par04 ) <> Replicate("*", Len(AllTrim( mv_par04 )))
		cRA_CATFUN   := ""
		
		For nCont  := 1 to Len(Alltrim(mv_par04)) Step nTRACATFUN
			If Substr(mv_par04, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par04, nCont, nTRACATFUN)))
				cRA_CATFUN += "'" + Substr(mv_par04, nCont, nTRACATFUN) + "',"
			EndIf
		Next
	
		cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)

		If ! Empty(AllTrim(cRA_CATFUN))
			cWhere += ' AND SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
		EndIf
	EndIf
	
	cWhere += "%"

	oFilial:BeginQuery()
	BeginSql Alias cAliasQRY

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SQ3.Q3_DESCSUM, SRF.RF_DATABAS, RIA.RIA_DTPGAD, SRF.RF_DATAFIM, RIA.RIA_NRDIND
		  FROM %table:RIA% RIA
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = %Exp:xFilial("RIA")% AND SRA.RA_MAT = RIA.RIA_MAT
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO	
		  JOIN %table:SRF% SRF ON SRF.%notDel% AND SRF.RF_FILIAL = %Exp:xFilial("SRF")% AND SRF.RF_MAT = RIA.RIA_MAT 
		   AND SRF.RF_PD = RIA.RIA_PD AND SRF.RF_DATABAS = RIA.RIA_DTINPA AND SRF.RF_STATUS <> %Exp:'4'%
		  JOIN %table:SRV% SRV ON SRV.%notDel% AND SRV.RV_FILIAL = %Exp:xFilial("SRV")% AND SRV.RV_COD = SRF.RF_PD AND SRV.RV_CODFOL = %Exp:'0072'%
		 WHERE RIA.%notDel% AND RIA.RIA_NRDIND > 0 AND RIA.RIA_STATUS IN (%Exp:'0'%,%Exp:'2'%,%Exp:'4'%) %Exp:cWhere%
		 ORDER BY SRA.RA_FILIAL, SRA.RA_NOME
	EndSql
		
	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL) == cParam}, {|| (cAliasQry)->(RA_FILIAL) })
	
	
	oFilial:Print()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao  ³ MES_AUX     ³ Autor ³ Alexandre Florentino ³    Data ³ 11.02.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar do relatório VDFR220                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MES_AUX()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dDatAux                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MES_AUX - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MES_AUX(dDatAux)

	Local cRetMes := ""
    Local nOpc    := 0
    
	Default dDatAux := Ctod(Space(8))
	
	nOpc := Month(dDatAux)
	
	Do Case
		Case nOpc == 1
			cRetMes := "jan"
		Case nOpc == 2
			cRetMes := "fev"
		Case nOpc == 3
			cRetMes := "mar"
		Case nOpc == 4
			cRetMes := "abr"
		Case nOpc == 5
			cRetMes := "mai"
		Case nOpc == 6
			cRetMes := "jun"	
		Case nOpc == 7
			cRetMes := "jul"
		Case nOpc == 8
			cRetMes := "ago"
		Case nOpc == 9
			cRetMes := "set"
		Case nOpc == 10
			cRetMes := "out"
		Case nOpc ==11
			cRetMes := "nov"
		Case nOpc == 12
			cRetMes := "dez"
		Otherwise
			cRetMes := ""
	EndCase

Return cRetMes
