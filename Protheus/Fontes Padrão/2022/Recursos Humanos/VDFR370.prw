#INCLUDE "VDFR370.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

/*/{Protheus.doc} VDFR370
Relatório de progressão funcional Vertical
@author Alexandre Florentino
@version 11
@since 25/03/2014
@history 17/12/2014, Marcos Pereira, TRGWMU - Implementação da pergunta 05 para filtragem pela data prevista da próxima progressão.
@history 15/01/2015, Marcos Pereira, TRJPC1 - Implementação da pergunta 06 para  definir o tipo de aumento a ser considerado para a;
		progressão e ajuste p/considerar apenas cargo efetivo, desprezando o comissionado.
@history 13/04/2015, Joao Balbino, TRXGTW - Correção da query reponsavel por gerar o relatório.
@history 17/04/2015, Joao Balbino, TSCSNN - Correção da função reportdef para obedecer a parametrização informada.
@return Nil
/*/
Function VDFR370()

	Private oReport
	Private cString  	:= 'SRA'
	Private cPerg	  	:= "VDFR370"
	Private cTitulo		:= STR0001 //'Relatório de Progressão Funcional Vertical - Mensal e Individual'
	Private nSeq 	  	:= 0
	Private cAliasQry 	:= '', lPrnDet := .F.
	Private oFunc, oFaltas, aFalMat := {}

	Pergunte(cPerg, .F.)

	M->RA_FILIAL := ""	// Variavel para controle da numeração

	oReport := ReportDef()
	oReport:PrintDialog()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Montagem das definições do relatório
@sample 	ReportDef()
@author	    Alexandre Florentino
@since		25/03/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ReportDef()

	Local cDescri := STR0003 //"Este relatório visa auxiliar o gerenciamento da progressão vertical dos servidores efetivos."

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 3)
	oReport:nFontBody := 7

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0004, { cAliasQry }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	TRCell():New(oFilial,"RA_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																	 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, ,( cAliasQry ))

	nSeq := 0

	TRCell():New(oFunc,            '',       '',    'Nº', '99999', 5, /*lPixel*/,/*bBlock*/ { || PrintSeq()  }, "RIGHT" ) //Para incluir o número(sequencial) na linha de impressão
	TRCell():New(oFunc,      "RA_MAT",    'SRA', STR0008)    //-- Matricula
	TRCell():New(oFunc,     "RA_NOME",    'SRA', STR0009)    //-- Nome
	TRCell():New(oFunc,            '',    'SRA', STR0010, , , /*lPixel*/, /*bBlock*/ { || ((cAliasQry)->RA_TABNIVE + ' / ' + (cAliasQry)->RA_TABFAIX)  },"CENTER",, ) //'Nível / Classe Atual'
	TRCell():New(oFunc,            '',    'SRA', STR0011, , , /*lPixel*/, /*bBlock*/ { || ((cAliasQry)->NX_TABNIVE + ' / ' + (cAliasQry)->RA_TABFAIX)  },"CENTER",, ) //'Nível / Classe Posterior'
	TRCell():New(oFunc,     'R3_DATA',    'SR3', STR0012, , , /*lPixel*/, /*bBlock*/, "CENTER" )				//-- Data Ult. Progressão
    TRCell():New(oFunc, 'R3_DATANXT' ,    'SR3', STR0013, , , /*lPixel*/, /*bBlock*/ { || DiasPrg() }, "CENTER")//-- Data Prevista

Return(oReport)

//------------------------------------------------------------------------------
/*/{Protheus.doc} DiasPrg
Funcao para retorno do número de dias para progressão
@sample 	DiasPrg()
@author	    Alexandre Florentino
@since		13/05/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function DiasPrg()

Local dData := (cAliasQry)->R3_DATANXT, nPos := 1

For nPos := 1 To Len(aFalMat)
	If aFalMat[nPos][1] == (cAliasQry)->RA_FILIAL .And. aFalMat[nPos][2] == (cAliasQry)->RA_MAT
		dData += aFalMat[nPos][3]
	EndIf
Next

Return dData

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrintSeq
Funcao para controle da impressão do cabecalho das colunas
@sample 	PrintSeq()
@author	    Wagner Mobile Costa
@since		08/05/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function PrintSeq()

lPrnDet := .F.
oFunc:SetHeaderSection(nSeq == 0)

DbSelectArea("QRY")
Set Filter To RC_FILIAL = (cAliasQry)->RA_FILIAL .And. RC_MAT = (cAliasQry)->RA_MAT
DbGoTop()

DbSelectArea(cAliasQry)

Return AllTrim(Str(++ nSeq))

//------------------------------------------------------------------------------
/*/{Protheus.doc} NewLine
Funcao para controle de salto de linha quando houver detalhe.
@sample 	NewLine()
@author	    Wagner Mobile Costa
@since		15/05/2014
@version	P11.8
/*/
//-----------------------------------------------------------------------------
Static Function NewLine()

If lPrnDet
	oReport:SkipLine()
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do conteúdo do relatório.
@sample 	ReportPrint(oReport)
@author	    Alexandre Florentino
@since		25/03/2014
@version	P11.8
/*/
//-----------------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local nCont    := 0, aFaltas := {}, aDevol := {}
Local oFunc    := oReport:Section(1):Section(1), oFilial := oReport:Section(1)
Local oTmpTable:= Nil
Local cAux     := "%+%", cWhere := "%", cQuery := "", cAnoMes := ""
Local cR3_TIPO := "", cWhereR3 := ""

	If MV_PAR04 == 2 .And. ( oReport:nDevice == 4 .And. oReport:nExcelPrintType == 3 )
		MsgInfo(STR0034) //Não é possível imprimir o relatório sintético em formato tabela, pois ele apresenta apenas os totalizadores.
	    oReport:CancelPrint()
	    Return
	EndIf

	If Upper(TcGetDb()) $ "DB2_ORACLE_INFORMIX_POSTGRES"
		cAux := "%||%"
	EndIf

	oReport:SetTitle(STR0029 + " - " + If(!empty(mv_par05),left(mv_par05,2)+'/'+right(mv_par05,4)+' - ','') + If(mv_par04 <> 2, STR0031, STR0030)) //'PROGRESSÃO FUNCIONAL VERTICAL'###'Analitico'###'Sintético'

	cAliasQry := GetNextAlias()

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cWhere += " AND " + MV_PAR02
	EndIf

	If !Empty(MV_PAR03)		//-- Progressão
		cWhere += " AND " + MV_PAR03
	EndIf

	cWhere += "%"

	//-- Monta a string de Tipos de Aumento
	If AllTrim( mv_par06 ) <> Replicate("*", Len(AllTrim( mv_par06 )))
		cR3_TIPO   := ""
		For nCont  := 1 to Len(Alltrim(mv_par06)) Step 3
			If Substr(mv_par06, nCont, 3) <> "*"
				cR3_TIPO += "'" + Substr(mv_par06, nCont, 3) + "',"
			EndIf
		Next
		cR3_TIPO := Substr( cR3_TIPO, 1, Len(cR3_TIPO)-1)
		If !Empty(AllTrim(cR3_TIPO))
			If !Empty(MV_PAR01)		//-- Filial
				cWhereR3 += " AND " + StrTran(MV_PAR01, "RA_FILIAL", "SR3.R3_FILIAL")
			EndIf

			If !Empty(MV_PAR02)		//-- Matricula
				cWhereR3 += " AND " + StrTran(MV_PAR02, "RA_MAT", "SR3.R3_MAT")
			EndIf

			cWhereR3 += 'AND SR3.R3_TIPO IN (' + cR3_TIPO + ')'
			cWhereR3 := "%" + cWhereR3 + "%"
		EndIf
	EndIf

	If Empty(cWhereR3)
		MsgInfo(STR0033)  //"É obrigatório selecionar os tipos de aumento de progessão ! Verifique os parâmetros !"
		Return
	EndIF

	cAnoMes := right(mv_par05,4) + left(mv_par05,2)

	oFilial:BeginQuery()
	BeginSql Alias cAliasQry
		COLUMN R3_DATANXT AS DATE
		COLUMN R3_DATA    AS DATE

		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_TABELA, SRA.RA_TABNIVE, SRA.NX_TABNIVE, SRA.RA_TABFAIX, SRA.R3_DATA,
		       SRA.R3_DATANXT, SRA.RECNO_RA
		  FROM (SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA,
		               CASE WHEN COALESCE(SR3P.R3_DATA, %Exp:''%) = %Exp:''% THEN SR3.R3_TABELA ELSE SR3P.R3_TABELA END AS RA_TABELA,
		               CASE WHEN COALESCE(SR3P.R3_DATA, %Exp:''%) = %Exp:''% THEN SR3.R3_TABNIVE ELSE SR3P.R3_TABNIVE END AS RA_TABNIVE,
		               CASE WHEN COALESCE(SR3P.R3_DATA, %Exp:''%) = %Exp:''% THEN SRA.RA_TABFAIX ELSE SR3P.R3_TABFAIX END AS RA_TABFAIX,
					   CASE WHEN COALESCE(SR3P.R3_DATA, %Exp:''%) = %Exp:''% THEN SRA.RA_ADMISSA ELSE SR3P.R3_DATA END AS R3_DATA,
					   CAST(CAST(SUBSTRING(CASE WHEN COALESCE(SR3P.R3_DATA, %Exp:''%) = %Exp:''%
					     					    THEN SRA.RA_ADMISSA ELSE SR3P.R3_DATA END, 1, 4) AS INTEGER) + 5 AS VARCHAR(4)) %Exp:cAux%
					   REPLACE(SUBSTRING(CASE WHEN COALESCE(SR3P.R3_DATA, %Exp:''%) = %Exp:''%
					    					  THEN SRA.RA_ADMISSA ELSE SR3P.R3_DATA END, 5, 4), %Exp:'0229'%, %Exp:'0228'%) AS R3_DATANXT,
					  (SELECT MIN(RB6_NIVEL) FROM %table:RB6% RB6
						WHERE RB6.%notDel% AND RB6_FILIAL = %Exp:xFilial("RB6")%
                          AND RB6_TABELA = CASE WHEN COALESCE(SR3P.R3_DATA, %Exp:''%) = %Exp:''%
                                                THEN SR3.R3_TABELA ELSE SR3P.R3_TABELA END
						  AND RB6_NIVEL > CASE WHEN COALESCE(SR3P.R3_DATA, %Exp:''%) = %Exp:''%
                                               THEN SR3.R3_TABNIVE ELSE SR3P.R3_TABNIVE END) AS NX_TABNIVE, SRA.R_E_C_N_O_ AS RECNO_RA
					FROM %table:SRA% SRA
					JOIN %table:SR3% SR3 ON SR3.%notDel% AND SR3.R3_FILIAL = SRA.RA_FILIAL AND SR3.R3_MAT = SRA.RA_MAT
                     AND SR3.R3_DATA = SRA.RA_ADMISSA AND SR3.R3_SEQ = '1'
					LEFT JOIN (SELECT SR3.R3_FILIAL, SR3.R3_MAT, SR3.R3_TABELA, SR3.R3_TABNIVE, SR3.R3_TABFAIX, SR3.R3_DATA
					             FROM %table:SR3% SR3
							     JOIN (SELECT SR3M.R3_FILIAL, SR3M.R3_MAT, MAX(SR3M.R_E_C_N_O_) AS R_E_C_N_O_ FROM %table:SR3% SR3M
								         JOIN (SELECT R3_FILIAL, R3_MAT, MAX(R3_DATA) AS R3_DATA
										         FROM %table:SR3%
								                WHERE %notDel% %Exp:StrTran(cWhereR3, "SR3.", "")%
											    GROUP BY R3_FILIAL, R3_MAT) SR3DM ON SR3DM.R3_FILIAL = SR3M.R3_FILIAL
										  AND SR3DM.R3_MAT = SR3M.R3_MAT
								        WHERE SR3M.%notDel% %Exp:StrTran(cWhereR3, "SR3.", "SR3M.")%
										GROUP BY SR3M.R3_FILIAL, SR3M.R3_MAT) SR3M ON SR3M.R3_FILIAL = SR3.R3_FILIAL AND SR3M.R3_MAT = SR3.R3_MAT
								   AND SR3M.R_E_C_N_O_ = SR3.R_E_C_N_O_
						        WHERE SR3.%notDel% %Exp:cWhereR3%) SR3P ON SR3P.R3_FILIAL = SRA.RA_FILIAL AND SR3P.R3_MAT = SRA.RA_MAT
					WHERE SRA.%notDel% AND SRA.RA_CATFUNC IN (%Exp:'2'%, %Exp:'3'%, %Exp:'5'%) AND SRA.RA_SITFOLH <> %Exp:'D'%) SRA
	     WHERE (SRA.NX_TABNIVE <> %Exp:''% AND SRA.R3_DATA <> %Exp:''%) %Exp:cWhere%
	     ORDER BY SRA.RA_FILIAL, SRA.RA_NOME
	EndSql
	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQry)->(RA_FILIAL ) == cParam}, {|| (cAliasQry)->(RA_FILIAL) })
	oFunc:nLinesBefore := 0
	oFunc:SetCellBorder("ALL",,, .T.)
	oFunc:SetCellBorder("RIGHT")
	oFunc:SetCellBorder("LEFT")
	oFunc:SetCellBorder("BOTTOM")

	aStruct := { 	{ "RC_FILIAL", "C", Len(SRC->RC_FILIAL), 0 }, { "RC_MAT", "C", Len(SRC->RC_MAT), 0 }, { "RCM_DESCRI", "C", Len(RCM->RCM_DESCRI), 0 },;
	      			{ "TP_AFASTA", "N", 1, 0 }, { "R8_DATAINI", "D", 8, 0 }, { "R8_DATAFIM", "D", 8, 0 },;
	      			{ "RC_DIAS", "N", 5, 0 } }

	oTmpTable := FWTemporaryTable():New("QRY")
	oTmpTable:SetFields( aStruct )
	oTmpTable:AddIndex( "IND", {"RC_FILIAL","RC_MAT", "TP_AFASTA", "R8_DATAINI"} )
	oTmpTable:Create()

	While ! (cAliasQry)->(Eof())
		//-- Processa os afastamentos
		BeginSql Alias "QRYSR8"
			COLUMN R8_DATAINI AS DATE
			COLUMN R8_DATAFIM AS DATE

			SELECT SR8.R8_FILIAL, SR8.R8_MAT, RCM.RCM_DESCRI, SR8.R8_DATAINI, SR8.R8_DATAFIM
			 FROM %table:SR8% SR8
		     JOIN %table:RCM% RCM ON RCM.%notDel% AND RCM.RCM_FILIAL = %Exp:xFilial("RCM")% AND RCM.RCM_TIPO = SR8.R8_TIPOAFA
		      AND RCM.RCM_PROGR = %Exp:'1'%
		    WHERE SR8.%notDel% AND SR8.R8_FILIAL = %Exp:(cAliasQry)->RA_FILIAL% AND SR8.R8_MAT = %Exp:(cAliasQry)->RA_MAT%
    AND ((R8_DATAINI >= %Exp:Dtos((cAliasQry)->R3_DATA)%
	            AND R8_DATAINI <= %Exp:Dtos((cAliasQry)->R3_DATANXT)% OR R8_DATAINI = %Exp:''%) OR
	               (R8_DATAFIM >= %Exp:Dtos((cAliasQry)->R3_DATA)%
	            AND R8_DATAFIM <= %Exp:Dtos((cAliasQry)->R3_DATANXT)% OR R8_DATAFIM = %Exp:''%))
		EndSql

		While ! QRYSR8->(Eof())
			RecLock("QRY", .T.)
			QRY->RC_FILIAL  := QRYSR8->R8_FILIAL
			QRY->RC_MAT     := QRYSR8->R8_MAT
			QRY->RCM_DESCRI := QRYSR8->RCM_DESCRI
			QRY->R8_DATAINI := QRYSR8->R8_DATAINI
			QRY->R8_DATAFIM := QRYSR8->R8_DATAFIM
			QRY->TP_AFASTA  := 1
			M->R8_DATAINI   := QRYSR8->R8_DATAINI
			If M->R8_DATAINI < (cAliasQry)->R3_DATA
				M->R8_DATAINI := (cAliasQry)->R3_DATA
			EndIf

			If Empty(QRYSR8->R8_DATAFIM)
				QRY->RC_DIAS := (cAliasQry)->R3_DATANXT - M->R8_DATAINI + 1
			Else
				QRY->RC_DIAS := QRYSR8->R8_DATAFIM - M->R8_DATAINI + 1
			EndIf

			Aadd(aFalMat, { QRYSR8->R8_FILIAL, QRYSR8->R8_MAT, QRY->RC_DIAS })

			QRY->(DbUnLock())

			QRYSR8->(DbSkip())
		EndDo

		QRYSR8->(DbCloseArea())

		//-- Processa as faltas
		DbSelectArea("SRA")
		DbGoTo((cAliasQry)->RECNO_RA)
		dDtaIni  := (cAliasQry)->R3_DATA
		dDtaFim  := (cAliasQry)->R3_DATANXT
		cProces  := cPeriodo := cRoteiro := ""	// Iguala a nulo para que todos sejam considerados

		aFaltas  := fGetFalDev(	SRA->RA_FILIAL, SRA->RA_MAT, (cAliasQry)->R3_DATA, (cAliasQry)->R3_DATANXT,;
								/* aAPdFaltas */, /* aAPdDevols */, /* lSintetico */, /* aTmpBru */, .F. /* lAnoCiv */,;
								(cAliasQry)->R3_DATANXT)

		aDevol   := AClone(aFaltas)[2]
		aFaltas  := AClone(aFaltas)[1]
		For nCont := 1 To Len(aDevol)
			nPos := Ascan(aFaltas, { |x| x[4] = aDevol[nCont][4] .and. aDevol[nCont][4] >= anomes((cAliasQry)->R3_DATA) .and. aDevol[nCont][4] <= anomes((cAliasQry)->R3_DATANXT) })
			If nPos > 0
				aFaltas[nPos][2] -= aDevol[nCont][2]
			EndIf
		Next

		For nCont := 1 To Len(aFaltas)
			If aFaltas[nCont][2] <= 0 .or. aFaltas[nCont][4] < anomes((cAliasQry)->R3_DATA) .or. aFaltas[nCont][4] > anomes((cAliasQry)->R3_DATANXT)
				Loop
			EndIf

			RecLock("QRY", .T.)
			QRY->RC_FILIAL  := SRA->RA_FILIAL
			QRY->RC_MAT     := SRA->RA_MAT
			QRY->RCM_DESCRI := STR0005   //'Faltas'
			QRY->R8_DATAINI := Stod(aFaltas[nCont][4] + "01")
			QRY->TP_AFASTA  := 2
			QRY->RC_DIAS    := aFaltas[nCont][2]
			QRY->(DbUnLock())

			Aadd(aFalMat, { SRA->RA_FILIAL, SRA->RA_MAT, QRY->RC_DIAS })
		Next

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbGoTop())

    If MV_PAR04 <> 2 // - Sintético
    	oFunc:bLineCondition := { || NewLine() }

		cWhere := StrTran(cWhere, "RA_FILIAL", "R8_FILIAL"  )
		cWhere := StrTran(cWhere, "RA_MAT", "R8_MAT"     )
		cWhere := StrTran(cWhere, "R3_DATA", "R8_DATAINI" )

		oFaltas := TRSection():New(oFunc, , ( "QRY" ))
	    TRCell():New(oFaltas,  'RCM_DESCRI',    "QRY",      STR0014,,30)      //-- Tipo Afastamento/Faltas             //'Tipo Afastamento/Faltas'
	    TRCell():New(oFaltas,            '',    "QRY",      STR0015, , 30, /*lPixel*/, /*bBlock*/ { || If(QRY->TP_AFASTA = 1, (Dtoc(QRY->R8_DATAINI) + ' '+ STR0016 + ' ' + Dtoc(QRY->R8_DATAFIM)), Periodo(QRY->R8_DATAINI) + "/" + Str(Year(QRY->R8_DATAINI), 4)) }, "CENTER") //'Período'###'Até'
	    TRCell():New(oFaltas,            '',    "QRY",      STR0017 + Chr(13) + Chr(10) +  STR0018, ,15 , /*lPixel*/, /*bBlock*/ { || (lPrnDet := .T., Str(QRY->RC_DIAS, 3) )  }, "CENTER") //'Quantidade'###'de Dias'
		oFaltas:nLinesBefore := 1
		oFaltas:SetLeftMargin(10)

		oFaltas:SetCellBorder("ALL",,, .T.)
		oFaltas:SetCellBorder("RIGHT")
		oFaltas:SetCellBorder("LEFT")
		oFaltas:SetCellBorder("BOTTOM")

		oFaltas:SetParentFilter({|cParam| QRY->(RC_FILIAL + RC_MAT ) == cParam}, {|| (cAliasQry)->(RA_FILIAL + RA_MAT)  })
	EndIf

	oFunc:SetLineCondition({ ||  iif(empty(cAnoMes),.t.,anomes(DiasPrg())==cAnoMes) })

	oFilial:Print()
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} Periodo
Funcao para impressão do texto do periodo.
@sample 	Periodo(dPeriodo)
@author	    Wagner Mobile Costa
@since		08/05/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function Periodo(dPeriodo)

Local cTexto := "", aPeriodo := { 	STR0006, STR0007, STR0019, STR0020, STR0021, STR0022,;
									STR0023, STR0024, STR0025, STR0026, STR0027, STR0028 }, nMes := Month(dPeriodo)
                                    //'JAN'###'FEV'###'MAR'###'ABR'###'MAI'###'JUN'###'JUL'###'AGO'###'SET'###'OUT'###'NOV'###'DEZ'
If nMes > 0 .And. nMes < 13
	cTexto := aPeriodo[nMes]
EndIf

Return cTexto

//------------------------------------------------------------------------------
/*/{Protheus.doc} R370R3TIPO
Retorna lista de opções utilizando a tabela SX5 (41).
@sample 	R370R3TIPO()
@author	    Wagner Mobile Costa
@since		14/01/2015
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function R370R3TIPO()

Local aArea := GetArea(), aLista := {}, MvParDef := "", nTam := 3

CursorWait()

DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial() + "41")

While !Eof() .And. X5_FILIAL + X5_TABELA == xFilial("SX5") + "41"
	Aadd(aLista, AllTrim(SX5->X5_CHAVE) + " - " + AllTrim(SX5->X5_DESCRI))
	MvParDef += AllTrim(SX5->X5_CHAVE)
	dbSkip()
Enddo

CursorArrow()

MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

If f_Opcoes(@MvPar, STR0032, aLista, MvParDef, 12, 49, .F., nTam) //'Tipo de Aumento'
	&MvRet := mvpar                                               // Devolve Resultado
EndIF

RestArea(aArea)

Return .T.