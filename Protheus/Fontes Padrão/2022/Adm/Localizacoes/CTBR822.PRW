#Include "CTBR822.CH"
#Include "Protheus.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR822   � Autor � Marco A. Gonzalez  �Fecha �  04/05/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Libro Diario (COL)                                         ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR822                                                    ���
�������������������������������������������������������������������������ͼ��
���GSANTACRUZ� DMINA-3973 Cambia el pict de ct2_valor                     ���
���LEnr�quez � DMINA-4230 Se elimina uso de clausula LEN en armado de qry ���
���          � 21.11.2018 por incompatibilidad con manejadores de base de ���
���          � datos. (COL)                                               ���
���LEnr�quez � DMINA-11124 Se activa parametro MV_PAR04 para filtrado por ���
���          � 16.03.2021 moneda utilizando el campo CT2_MOEDLC (COL).    ���
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function CTBR822()

	Local oReport
	Private cPerg := "CTBR822"

	//���������������������Ŀ
	//�mv_par01 - De Fecha? �
	//�mv_par02 - A Fecha?  �
	//�mv_par03 - Lote?     �
	//�mv_par04 - Moneda?   �
	//�����������������������

	//Inicializaci�n de preguntas
	MV_PAR04 := ""

	If TRepInUse()
		Pergunte(cPerg,.F.)

		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef � Autor � Marco A. Gonzalez  �Fecha �  04/05/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Definicion del Informe - Libro Diario (COL)                ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR822                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3

	oReport := TReport():New("LIVRODIA",STR0002,cPerg,{|oReport| CTBR822Rep(oReport)},STR0003)	//"LIBRO DIARIO" - "Informe de Libro Diario"

	//�����������Ŀ
	//�  Secao 1  �
	//�������������

	oSection1 := TRSection():New(oReport,STR0004,"CT2")	//"Fecha/Lote"

	TRCell():New(oSection1,"CT2_DATA"	,"CT2",STR0005,,20,.T.,{|| cData })	//"Fecha"

	//�����������Ŀ
	//�  Secao 2  �
	//�������������

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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR822Rep� Autor � Marco A. Gonzalez  �Fecha �  04/05/16   ���
�������������������������������������������������������������������������͹��
���Descri��o �Imprime el informe definido por el usuario de acuerdo con   ���
���          �las secciones/celdas creadas en la funcion ReportDef() (COL)���
�������������������������������������������������������������������������͹��
���Sintaxe   � CTBR822Rep(ExpO1)                                          ���
�������������������������������������������������������������������������͹��
���Parametros� ExpO1 = Objeto Reporte                                     ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR822                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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

		//������������������������������������������������������������������������������Ŀ
		//�Prepara relatorio para executar a query gerada pelo Embedded SQL passando como�
		//�parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados �
		//�pela funcao MakeSqlExpr para serem adicionados a query                        �
		//��������������������������������������������������������������������������������

		oSection2:EndQuery()
		//������������������������������������������Ŀ
		//�Inicio da impressao do fluxo do relat�rio �
		//��������������������������������������������
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
