#Include "CTBR822.CH"
#Include "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBR822   º Autor ³ Marco A. Gonzalez  ºFecha ³  04/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Libro Diario (COL)                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR822                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºGSANTACRUZ³ DMINA-3973 Cambia el pict de ct2_valor                     º±±
±±ºLEnríquez ³ DMINA-4230 Se elimina uso de clausula LEN en armado de qry º±±
±±º          ³ 21.11.2018 por incompatibilidad con manejadores de base de º±±
±±º          ³ datos. (COL)                                               º±±
±±ºLEnríquez ³ DMINA-11124 Se activa parametro MV_PAR04 para filtrado por º±±
±±º          ³ 16.03.2021 moneda utilizando el campo CT2_MOEDLC (COL).    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CTBR822()

	Local oReport
	Private cPerg := "CTBR822"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³mv_par01 - De Fecha? ³
	//³mv_par02 - A Fecha?  ³
	//³mv_par03 - Lote?     ³
	//³mv_par04 - Moneda?   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Inicialización de preguntas
	MV_PAR04 := ""

	If TRepInUse()
		Pergunte(cPerg,.F.)

		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef º Autor ³ Marco A. Gonzalez  ºFecha ³  04/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definicion del Informe - Libro Diario (COL)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR822                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3

	oReport := TReport():New("LIVRODIA",STR0002,cPerg,{|oReport| CTBR822Rep(oReport)},STR0003)	//"LIBRO DIARIO" - "Informe de Libro Diario"

	//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Secao 1  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÙ

	oSection1 := TRSection():New(oReport,STR0004,"CT2")	//"Fecha/Lote"

	TRCell():New(oSection1,"CT2_DATA"	,"CT2",STR0005,,20,.T.,{|| cData })	//"Fecha"

	//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Secao 2  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÙ

	oSection2 := TRSection():New(oSection1,STR0006,"CT2")	//"Total"
	oSection2:SetTotalInLine(.F.)

	TRCell():New(oSection2, "CT2_FILIAL"	, "CT2", STR0007)	//"Sucursal"
	TRCell():New(oSection2, "CT2_DATA"		, "CT2")
	TRCell():New(oSection2, "CT2_LOTE"		, "CT2", STR0008)	//"Lote"
	TRCell():New(oSection2, "CT2_DEBITO"	, "CT2")
	TRCell():New(oSection2, "CT2_CREDIT"	, "CT2")
	TRCell():New(oSection2, "VALORDEB"		, "CT2", STR0009, "999,999,999,999,999.99", TamSx3("CT2_VALOR")[1]+10)	//"VALOR DEB."
	TRCell():New(oSection2, "VALORCRD"		, "CT2", STR0010, "999,999,999,999,999.99", TamSx3("CT2_VALOR")[1]+10)	//"VALOR CRD."

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBR822Repº Autor ³ Marco A. Gonzalez  ºFecha ³  04/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³Imprime el informe definido por el usuario de acuerdo con   ³±±
±±³          ³las secciones/celdas creadas en la funcion ReportDef() (COL)³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ CTBR822Rep(ExpO1)                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpO1 = Objeto Reporte                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR822                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CTBR822Rep(oReport)

	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oReport:Section(1):Section(1)
	Local cFiltro		:= ""
	Local QRYSA3		:= GetNextAlias()
	Local dFchAnt		:= STOD(" / / ")
	Local cFilMon       := IIf(!Empty(MV_PAR04),MV_PAR04,"")

	#IFDEF TOP

		oSection1:SetTotalInLine(.F.)
		oSection1:SetTotalText(STR0010)	//"Total del vendedor"
		oSection1:SetHeaderSection(.F.)

		oSection2:SetHeaderPage()	//Define o cabecalho da secao como padrao

		oBreak := TRBreak():New(oSection2,oSection2:Cell("CT2_LOTE"),"")
		TRFunction():New(oSection2:Cell("VALORDEB"),NIL,"SUM",oBreak)
		TRFunction():New(oSection2:Cell("VALORCRD"),NIL,"SUM",oBreak)

		cFiltro := "%"
		If !Empty(mv_par03)
			SX5->(DbSetOrder(1))
			If SX5->(DbSeek(xFilial("SX5")+"09"+mv_par03))
				cFiltro += "AND CT2_LOTE = '" + SX5->X5_DESCRI + "'"
			Else
				cFiltro += "AND CT2_LOTE = '' "
			Endif
		EndIf

		//Filtrado por Moneda
		If !Empty(cFilMon)
			cFiltro += " AND CT2_MOEDLC = '" + cFilMon + "' "
		EndIf

		cFiltro += "%"

		oSection2:BeginQuery()

		BeginSql alias QRYSA3
			SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_DEBITO,CT2_CREDIT,
		Case When CT2_DEBITO <> '' then SUM(CT2_VALOR) Else 0 END AS VALORDEB,
		Case When CT2_CREDIT <> '' then SUM(CT2_VALOR) Else 0 END AS VALORCRD
			FROM %table:CT2% CT2
			WHERE CT2.%notDel% %exp:cFiltro%
			AND CT2_DATA BETWEEN %exp:Dtos(mv_par01)% AND %exp:Dtos(mv_par02)%
			GROUP BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_DEBITO,CT2_CREDIT
			ORDER BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_CREDIT,CT2_DEBITO
		EndSql

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Prepara relatorio para executar a query gerada pelo Embedded SQL passando como³
		//³parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados ³
		//³pela funcao MakeSqlExpr para serem adicionados a query                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oSection2:EndQuery()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicio da impressao do fluxo do relatório ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(QRYSA3)
		(QRYSA3)->(dbGoTop())
		While !oReport:Cancel() .And. !(QRYSA3)->(Eof())

			If (QRYSA3)->CT2_DATA <> dFchAnt
				oSection2:SetTotalText(STR0012 + DTOC(dFchAnt) + STR0013)	//"TOTAL " - " : "
				oSection2:Finish()

				cData := (QRYSA3)->CT2_DATA
				oSection1:Init()
				oSection1:PrintLine()
			Endif

			oSection2:Init()
			oSection2:PrintLine()
			dFchAnt	:= (QRYSA3)->CT2_DATA

			dbSelectArea(QRYSA3)
			(QRYSA3)->(dbSkip())
		EndDo
		oSection2:SetTotalText(STR0012 + DTOC(dFchAnt) + STR0013)	//"TOTAL " - " : "
		oSection2:Finish()
	#ELSE
	#ENDIF

Return
