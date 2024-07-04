#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "ATFR031.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFR032   � Autor � Totvs              � Data �  18/05/10   ���
�������������������������������������������������������������������������͹��
���Descricao �Detalhes do Ativo Fixo Reavaliado Formato 7.2               ���
�������������������������������������������������������������������������͹��
���Uso       �ATFR032                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFR031()

Local cPerg		:= "ATR031"
Local olReport

/*����������������������������������������������������������������Ŀ
� mv_par01 - Exercicio? - Ano do exercicio para emissao            �
� mv_par02 - Seleciona filiais? - Filiais para considerar no filtro�
������������������������������������������������������������������*/
If TRepInUse()
	Pergunte(cPerg,.F.)

	olReport := ReportDef(cPerg)
	olReport:SetParam(cPerg)
	olReport:PrintDialog()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ATFRelat  � Autor � Totvs                 � Data | 14/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria��o do objeto TReport para a impress�o do relatorio.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ATFRelat( cPerg )           				                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Perguntas dos parametros                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef( cPerg )

	Local clNomProg		:= FunName()
	Local oSection1	    := NIL
	Local oSectEnb     := NIl
	Local clTitulo 		:= STR0001  // "FORMATO 7.1:REGISTRO DE ACIVOS FIJOS- DETALLE DE ACTIVOS"
	Local clDesc   		:= STR0001  // "FORMATO 7.1:REGISTRO DE ACIVOS FIJOS- DETALLE DE ACTIVOS"
	Local cPict		:= "@E 999,999,999.99"
	Local cPictPerc := "@E 999.99"

	olReport:=TReport():New(clNomProg,clTitulo,cPerg,{|olReport| ReportPrint(olReport)},clDesc)
	olReport:SetLandscape()					// Formato paisagem
	olReport:oPage:nPaperSize	:= 8 		// Impress�o em papel A3
	olReport:lHeaderVisible 	:= .F. 		// N�o imprime cabe�alho do protheus
	olReport:lFooterVisible 	:= .F.		// N�o imprime rodap� do protheus
	olReport:lParamPage			:= .F.		// N�o imprime pagina de parametros

	//+--------------------+
	//|Define las secciones|
	//+--------------------+
	oSection1 := TRSection():New( olReport, "",,,,,,,,,,,7,,0,.F.)
	oSection1:SetTotalInLine(.F.)
	oSection1:SetTotalText(STR0089) //"Totales"

	oSectEnb := TRSection():New( olReport, "",,,,,,,,,,,7,,0,.F.)
	oSectEnb:SetReadOnly()

	TRCell():New( oSection1, "CN1BASE"		,,STR0005+CRLF+STR0006+CRLF+STR0007  ,/*Picture*/,TamSX3( "N1_CBASE" )[1]   ,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"C�digo relac. con activo fijo""
	TRCell():New( oSection1, "CN3CCONTAB"	,,STR0008+CRLF+STR0009+CRLF+STR0010  ,/*Picture*/,TamSX3( "N3_CCONTAB" )[1] ,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Cuenta Contable del activo"
	TRCell():New( oSection1, "CN1DESCRIC"	,,CRLF+STR0011+CRLF                  ,/*Picture*/,20                        ,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Descripci�n"
	TRCell():New( oSection1, "CN1MARCA"		,,STR0012+CRLF+STR0013+CRLF+STR0014  ,/*Picture*/,TamSX3( "N1_MARCA" )[1]   ,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Marca del activo Fijo"
	TRCell():New( oSection1, "CN1MODELO"	,,STR0015+CRLF+STR0016+CRLF+STR0017  ,/*Picture*/,TamSX3( "N1_MODELO" )[1]  ,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Modelo del activo Fijo"
	TRCell():New( oSection1, "CN1CHAPA"		,,STR0018+CRLF+STR0019+CRLF+STR0020  ,/*Picture*/,TamSX3( "N1_CHAPA" )[1]   ,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"N� Serie y/o placa del activo"
	TRCell():New( oSection1, "NSLDINIC"		,,STR0021+CRLF+STR0022+CRLF		     ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Saldo Inicial"
	TRCell():New( oSection1, "NAQUIS"		,,STR0023+CRLF+STR0024+CRLF			 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Adquisici�n Adicional"
	TRCell():New( oSection1, "NAMPLIA"		,, CRLF+STR0025+CRLF		         ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Mejoras"
	TRCell():New( oSection1, "NBAIXAS"		,,STR0026+CRLF+STR0027+CRLF+STR0028	 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Retira y/o Bajas"
	TRCell():New( oSection1, "NAJUSTES"		,, STR0029+CRLF+STR0030+CRLF		 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Otros Ajustes"
	TRCell():New( oSection1, "NHIST"		,, STR0036+CRLF+STR0037+CRLF+STR0038 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Valor del historial del activo fijo al 31.12"
	TRCell():New( oSection1, "NAJUSTADO"	,, STR0042+CRLF+STR0043+CRLF+STR0044 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Valor Ajustado del Activo fijo"
	TRCell():New( oSection1, "DN1AQUISIC"	,, STR0045+CRLF+STR0046+CRLF+STR0047 ,/*Picture*/,10                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Fecha de Adquisicion"
	TRCell():New( oSection1, "DN3DINDEPR"	,,STR0048+CRLF+STR0049+CRLF+STR0050	 ,/*Picture*/,10                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Fecha inicial del uso del Activo Fijo"
	TRCell():New( oSection1, "CMETODO"		,,STR0051+CRLF+STR0052+CRLF			 ,/*Picture*/,13                        ,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Metodo Aplicado"
	TRCell():New( oSection1, "CN3AUTDEPR"	,,STR0053+CRLF+STR0054+CRLF+STR0055	 ,/*Picture*/,TamSX3( "N3_AUTDEPR" )[1] ,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"N� Doc. de Autorizaci�n"
	TRCell():New( oSection1, "NN3TXDEPR1"	,, STR0056+CRLF+STR0057+CRLF+STR0058 ,cPictPerc	 ,6                         ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Porcent. de Depreciaci�n"
	TRCell():New( oSection1, "NDEPRACM"		,, STR0059+CRLF+STR0060+CRLF+STR0061 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Depr. Acuml. al Cierre del Ejercicio ant."
	TRCell():New( oSection1, "NDEPRACM2"	,, STR0062+CRLF+STR0063+CRLF		 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Depreciaci�n del Ejercicio"
	TRCell():New( oSection1, "NDEPRBXS"		,,STR0064+CRLF+STR0065+CRLF+STR0066	 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Depr. del Ejerc. relac. con los retiros y/o bajas"
	TRCell():New( oSection1, "NAJUSTES2"	,, STR0067+CRLF+STR0068+CRLF+STR0069 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Depr. Relac. con otros Ajustes"
	TRCell():New( oSection1, "NDEPRHIST"	,, STR0075+CRLF+STR0076+CRLF+STR0077 ,cPict		 ,14                        ,, ,"RIGHT"	    , .T.,"CENTER",,0,.F.) //"Depreciaci�n Acumulada Historial"

	//Totalizadores
	TRFunction():New(oSection1:Cell("NSLDINIC")		,NIL, "SUM", /*oBreak*/, "", cPict	 , /*uFormula*/, .T., .F.)
	TRFunction():New(oSection1:Cell("NAQUIS")		,NIL,�"SUM",�/*oBreak*/,�"",�cPict�� ,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NAMPLIA")	    ,NIL,�"SUM",�/*oBreak*/,�"",�cPict�� ,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NBAIXAS")	    ,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NAJUSTES")		,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NHIST")		,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NAJUSTADO")	,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NDEPRACM")		,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NDEPRACM2")	,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NDEPRBXS")	    ,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NAJUSTES2")	,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)
	TRFunction():New(oSection1:Cell("NDEPRHIST")	,NIL,�"SUM",�/*oBreak*/,�"",�cPict���,�/*uFormula*/,�.T.,�.F.)

	TRCell():New( oSectEnb, "CBLANCO"		,,CRLF+CRLF+CRLF,/*Picture*/,TamSX3( "N1_CBASE" )[1]+TamSX3( "N3_CCONTAB" )[1]+1,, ,"CENTER"	, .T.,"CENTER",,0,.F.)
	TRCell():New( oSectEnb,"CESPACIO"	    ,," ",/*Picture*/,TamSX3( "N3_CCONTAB" )[1],/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb, "CDETALLEACT"	,,CRLF+STR0084+CRLF,/*Picture*/,20+TamSX3( "N1_MARCA" )[1]+TamSX3( "N1_MODELO" )[1]+ TamSX3( "N1_CHAPA" )[1],, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Detalle Activo Fijo "
	TRCell():New( oSectEnb, "CBLANCO2"		,,CRLF+CRLF+CRLF,/*Picture*/,127,, ,"CENTER"	, .T.,"CENTER",,0,.F.)
	TRCell():New( oSectEnb,"CESPACIO2"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO3"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO4"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO5"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO6"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO7"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO8"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO9"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO10"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO11"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO12"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb, "CDEPREC"		,,CRLF+STR0086+CRLF,/*Picture*/,13+TamSX3( "N3_AUTDEPR" )[1],, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Depreciaci�n "
	TRCell():New( oSectEnb, "CBLANCO3"		,,CRLF+CRLF+CRLF,/*Picture*/,27,, ,"CENTER"	, .T.,"CENTER",,0,.F.)
	TRCell():New( oSectEnb,"CESPACIO13"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb,"CESPACIO14"	    ,," ",/*Picture*/,12,/*lPixel*/,/*{||}*/,,,"RIGHT",,,.F.)
	TRCell():New( oSectEnb, "CVALDEPREC"	,,CRLF+STR0087+CRLF,/*Picture*/,45,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Val. de la Depreciaci�n"
	TRCell():New( oSectEnb, "CBLANCO4"		,,CRLF+CRLF+CRLF,/*Picture*/,14,, ,"CENTER"	, .T.,"CENTER",,0,.F.) 
	
	oSectEnb:Cell("CESPACIO"):Disable()
	oSectEnb:Cell("CESPACIO2"):Disable()
	oSectEnb:Cell("CESPACIO3"):Disable()
	oSectEnb:Cell("CESPACIO4"):Disable()
	oSectEnb:Cell("CESPACIO5"):Disable()
	oSectEnb:Cell("CESPACIO6"):Disable()
	oSectEnb:Cell("CESPACIO7"):Disable()
	oSectEnb:Cell("CESPACIO8"):Disable()
	oSectEnb:Cell("CESPACIO9"):Disable()
	oSectEnb:Cell("CESPACIO10"):Disable()
	oSectEnb:Cell("CESPACIO11"):Disable()
	oSectEnb:Cell("CESPACIO12"):Disable()
	oSectEnb:Cell("CESPACIO13"):Disable()
	oSectEnb:Cell("CESPACIO14"):Disable()

Return olReport

/*/{Protheus.doc} BordCel
	Funcion para colocar bordes a encabezado y lineas impresas.
	@type Static Function
	@author eduardo.manriquez
	@since 22/12/2021
	@version 1.0
	@param oSection, Objeto, Objeto TRSection.
	@param lPrint, boolean, Varible que controla la impresi�n de los bordes de la celda.
	@example BordCel(oSection,lPrint)
	
/*/
Static Function BordCel(oSection,lPrint)
	Local nX		:= 0
	Local cNomCel	:= ""
	Default lPrint  := .T.

	If Type( "lPlan") == "U"
		lPlan := .F.
	Endif

	For nX := 1 to Len(oSection:aCell)
		cNomCel := oSection:aCell[nX]:cNAME
		If lPrint
			oSection:Cell(cNomCel):SetBorder("BOTTOM"	, 1, 000000, .F.)
		Else
			oSection:Cell(cNomCel):SetBorder("TOP"		, 1, 000000, .T.)
		Endif

		If lPlan
			oSection:Cell(cNomCel):SetBorder("TOP"		, 1, 000000, .T.)
		Endif
		oSection:Cell(cNomCel):SetBorder("BOTTOM"	, 1, 000000, .T.)
		oSection:Cell(cNomCel):SetBorder("LEFT"		, 1, 000000, .T.)
	Next nX
	oSection:Cell(oSection:aCell[Len(oSection:aCell)]:cNAME):SetBorder("RIGHT"	, 1, 000000, .T.)
Return

/*/{Protheus.doc} TitCelda
	Funcion para ajuste de impresi�n por opci�n Planilla.
	@type Static Function
	@author eduardo.manriquez
	@since 22/12/2021
	@version 1.0
	@param oSection, Objeto, Objeto TRSection.
	@param lEnc, boolean, Indica si la secci�n es el encabezado.
	@example TitCelda(oSection,lEnc)
/*/
Static Function TitCelda(oSection,lEnc)
	Local cEspace := " "
	Default lEnc  := .F.
	If lEnc
		oSection:Cell("CBLANCO"):SetTitle(" ") 
		oSection:Cell("CDETALLEACT"):SetTitle(STR0084) //"Detalle Activo Fijo"
		oSection:Cell("CBLANCO2"):SetTitle("") 
		oSection:Cell("CDEPREC"):SetTitle(STR0086) //"Depreciacion"
		oSection:Cell("CBLANCO3"):SetTitle(" ")
		oSection:Cell("CVALDEPREC"):SetTitle(STR0087) //"Val. de la Depreciaci�n"
		oSection:Cell("CBLANCO4"):SetTitle(" ")
		oSection:Cell("CESPACIO"):Enable()
		oSection:Cell("CESPACIO2"):Enable()
		oSection:Cell("CESPACIO3"):Enable()
		oSection:Cell("CESPACIO4"):Enable()
		oSection:Cell("CESPACIO5"):Enable()
		oSection:Cell("CESPACIO6"):Enable()
		oSection:Cell("CESPACIO7"):Enable()
		oSection:Cell("CESPACIO8"):Enable()
		oSection:Cell("CESPACIO9"):Enable()
		oSection:Cell("CESPACIO10"):Enable()
		oSection:Cell("CESPACIO11"):Enable()
		oSection:Cell("CESPACIO12"):Enable()
		oSection:Cell("CESPACIO13"):Enable()
		oSection:Cell("CESPACIO14"):Enable()
	Else
		oSection:Cell("CN1BASE"):SetTitle(STR0005+cEspace+STR0006+cEspace+STR0007)//"C�digo relac. con activo fijo""
		oSection:Cell("CN3CCONTAB"):SetTitle(STR0008+cEspace+STR0009+cEspace+STR0010)//"Cuenta Contable del activo"
		oSection:Cell("CN1DESCRIC"):SetTitle(STR0011)//"Descripci�n"
		oSection:Cell("CN1DESCRIC"):SetSize(40)
		oSection:Cell("CN1MARCA"):SetTitle(STR0012+cEspace+STR0013+cEspace+STR0014)//"Marca del activo Fijo"
		oSection:Cell("CN1MODELO"):SetTitle(STR0015+cEspace+STR0016+cEspace+STR0017)//"Modelo del activo Fijo"
		oSection:Cell("CN1CHAPA"):SetTitle(STR0018+cEspace+STR0019+cEspace+STR0020)//"N� Serie y/o placa del activo"
		oSection:Cell("NAQUIS"):SetTitle(STR0023+cEspace+STR0024)//"Adquisici�n Adicional"
		oSection:Cell("NSLDINIC"):SetTitle(STR0021+cEspace+STR0022)//"Saldo Inicial"
		oSection:Cell("NAMPLIA"):SetTitle(STR0025)//"Mejoras"
		oSection:Cell("NBAIXAS"):SetTitle(STR0026+cEspace+STR0027+cEspace+STR0028)//"Retira y/o Bajas"
		oSection:Cell("NAJUSTES"):SetTitle(STR0029+cEspace+STR0030)//"Otros Ajustes"
		oSection:Cell("NHIST"):SetTitle(STR0036+cEspace+STR0037+cEspace+STR0038)//"Valor del historial del activo fijo al 31.12"
		oSection:Cell("NAJUSTADO"):SetTitle(STR0042+cEspace+STR0043+cEspace+STR0044)//"Valor Ajustado del Activo fijo"
		oSection:Cell("DN1AQUISIC"):SetTitle(STR0045+cEspace+STR0046+cEspace+STR0047)//"Fecha de Adquisicion"
		oSection:Cell("DN3DINDEPR"):SetTitle(STR0048+cEspace+STR0049+cEspace+STR0050)//"Fecha inicial del uso del Activo Fijo"
		oSection:Cell("CMETODO"):SetTitle(STR0051+cEspace+STR0052)//"Metodo Aplicado"
		oSection:Cell("CN3AUTDEPR"):SetTitle(STR0053+cEspace+STR0054+cEspace+STR0055)//"N� Doc. de Autorizaci�n"
		oSection:Cell("NN3TXDEPR1"):SetTitle( STR0056+cEspace+STR0057+cEspace+STR0058)//"Porcent. de Depreciaci�n"
		oSection:Cell("NDEPRACM"):SetTitle( STR0059+cEspace+STR0060+cEspace+STR0061)//"Depr. Acuml. al Cierre del Ejercicio ant."
		oSection:Cell("NDEPRACM2"):SetTitle( STR0062+cEspace+STR0063)//"Depreciaci�n del Ejercicio"
		oSection:Cell("NDEPRBXS"):SetTitle(STR0064+cEspace+STR0065+cEspace+STR0066)//"Depr. del Ejerc. relac. con los retiros y/o bajas"
		oSection:Cell("NAJUSTES2"):SetTitle(STR0067+cEspace+STR0068+cEspace+STR0069)//"Depr. Relac. con otros Ajustes"
		oSection:Cell("NDEPRBXS"):SetTitle(STR0075+cEspace+STR0076+cEspace+STR0077)//"Depreciaci�n Acumulada Historial"
	Endif
Return

/*
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    ReportPrint   � Autor � Totvs                 � Data | 14/05/10 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Impress�o do relatorio.								         ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint( ExpC1 )         				                 ���
����������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Objeto tReport                                         ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ReportPrint( olReport )

	Local aInfo         := {}
	Local nInc			:= 0
	Local cStrFil		:= ""
	Local aSelFil		:= {}
	Local cBaja 		:= ""
	Local nExercicio	:= Val(MV_PAR01)
	Local oSection1		:= olReport:Section(1)
	Local oSectEnb      := olReport:Section(2)
	Local lGerArq       := (MV_PAR04 == 1)
	Private lAutomato   := isblind()
	Private lPlan       := (olReport:nDevice == 4)
	Private aTotais		:= {}
	Private aEquivale 	:= { "NSLDINIC","NAQUIS","NAMPLIA","NBAIXAS","NAJUSTES","NVOLUN","NSOCIE","NOUTROS","NAJUSINFLA","NDEPRACM","NDEPRACM2","NDEPRBXS","NAJUSTES2","NVOLUL2","NSOCIE2","NOUTROS2","NDEPRHIST","NAJUDINFLA"}
	Private aMetodo     := {"",""}
	Private aFieldSM0 	:= {"M0_NOMECOM", "M0_CGC"}
	Private aDatosEmp 	:= IIf (cVersao <> "11" ,FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0),"")
	Private cRUC	  	:= Trim(IIf (cVersao <> "11" ,aDatosEmp[2][2],SM0->M0_CGC))
	Private cApellido	:= Trim(IIf (cVersao <> "11" ,aDatosEmp[1][2],SM0->M0_NOMECOM))
	// Se aFil nao foi enviada, exibe tela para selecao das filiais
	If MV_PAR03 == 1
		aSelFil := AdmGetFil()

		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf

	if 	lPlan
		TitCelda(@oSection1,.F.)
		TitCelda(@oSectEnb,.T.)
	Endif

	BordCel(@oSection1,.T.)
	BordCel(@oSectEnb,.F.)

	aFill( aTotais, 0 )

	If MV_PAR03 == 1
		For nInc := 1 To Len( aSelFil )
			cStrFil += "'" + aSelFil[nInc] + "'"
			If nInc < Len( aSelFil )
				cStrFil += ", "
			EndIf
		Next
	Else
		cStrFil :=  "'" + xFilial('CN1') + "'"
	EndIf
	cStrFil	 := "%" + cStrFil+ "%"
	If MV_PAR02 == 1
		cBaja := "%" + Chr(39) + " " + Chr(39) + "," + Chr(39) + "0" + Chr(39) + "," + Chr(39) + "1" + Chr(39) + "%"
	Else
		cBaja :=  "%" + Chr(39) + " " + Chr(39) + "," + Chr(39) + "0" + Chr(39) + "%"
	Endif

	BeginSql Alias "PER"

		SELECT DISTINCT N1_CBASE,N1_ITEM,N1_MARCA,N1_MODELO,N1_DESCRIC,N1_CHAPA,N1_AQUISIC, N3_VORIG1,N3_CCONTAB,
						N3_QUANTD,N3_DINDEPR,N3_TPDEPR,N3_AUTDEPR,N3_TXDEPR1,N3_NODIA,N1_PRODUTO, N1_AQUISIC,N3_BAIXA,N1_BAIXA

		FROM  %table:SN1% SN1,%table:SN3% SN3

		WHERE SN1.N1_CBASE = SN3.N3_CBASE AND
			SN3.N3_TIPO = '01' AND
			SN1.N1_FILIAL IN ( %Exp:cStrFil%  ) AND
			SN3.N3_BAIXA IN (%Exp:cBaja% ) AND
			SN3.%NotDel% AND SN1.%NotDel%
		ORDER BY N1_CBASE, N1_ITEM
	EndSql

	TCSetField( "PER", "N1_AQUISIC",	"D", 08, 0 )
	TCSetField( "PER", "N3_DINDEPR",	"D", 08, 0 )
	TCSetField( "PER", "N3_VORIG1",		"N", TamSX3( "N3_VORIG1" )[1], TamSX3( "N3_VORIG1" )[2] )
	TCSetField( "PER", "N3_VRDACM1",	"N", TamSX3( "N3_VRDACM1" )[1], TamSX3( "N3_VRDACM1" )[2] )
	DbSelectArea( "PER" )
	PER->( DbGoTop() )
	If PER->( !Eof() )
		FCabR032( olReport) //Impress�o do cabe�alho
		aTotais	:= FR032Array( aEquivale )
	EndIf

	PER->(dbGoTop())
	if !lAutomato
		olReport:SetMeter( RecCount() )
	Endif

	While PER->(!Eof())
		If olReport:Cancel()
			Exit
		EndIf

		FR032PgMtd()		//PER->N3_TPDEPR

		aInfo := FRInfoATF( PER->N1_CBASE, PER->N1_ITEM, nExercicio )
		FR032PrtCol(@oSection1,aInfo)
		if lGerArq
			FR032Arq(aInfo,aEquivale)
		Endif
		olReport:OnPageBreak( { || FCabR032( olReport) } )

		DbSelectArea("PER")
		PER->( DbSkip() )
		if !lAutomato
			olReport:IncMeter()
		Endif

		If olReport:ChkIncRow( 20, .T. )
			olReport:EndPage()
		EndIf
		oSection1:PrintLine()
	EndDo
	oSection1:Finish()

	If lGerArq
		if !lAutomato
			IF MSGYESNO(STR0093,"") // "�Confirma la generaci�n del archivo TXT?"
			Processa({|| GerArq(AllTrim(MV_PAR05))},,STR0094) // "Generando archivo TXT"
			Endif
		else
			Conout(OemToAnsi(STR0094))
			GerArq(AllTrim(MV_PAR05))
		Endif
	EndIF

	PER->( DbCLoseArea() )

Return olReport

/*/{Protheus.doc} FR032Arq
	Funcion encargada de cargar la informaci�n para la generaci�n del archivo TXT.
	@type Static Function
	@author eduardo.manriquez
	@since 22/12/2021
	@version 1.0
	@param aInfo, Array, Arreglo que contiene los valores historicos del activo fijo.
	@param aEquivale, Array, Arreglo que contiene las etiquetas de los totales.
	@example FR032Arq(aInfo,aEquivale)
/*/
Static Function FR032Arq(aInfo,aEquivale)
	Local nValor := 0.00
	Local nInc   := 1

	For nInc := 1 To Len(aEquivale)
		If !Empty( aInfo )
			If Upper( aEquivale[nInc] ) == "NSLDINIC"
				// Se o bem foi adquirido em exerc�cios anteriores, obter o valor do registro tipo 01.
				// Caso contr�rio, preencher com 0 (zero).
				If Year( PER->N1_AQUISIC ) < VAL(MV_PAR01)
					nValor := PER->N3_VORIG1
				EndIf
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NAQUIS"
				// Se o bem foi adquirido no exerc�cio do relat�rio, obter do registro tipo 01.
				// Caso contr�rio, preencher com 0 (zero).
				If Year( PER->N1_AQUISIC ) == VAL(MV_PAR01)
					nValor := PER->N3_VORIG1
				EndIf
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NAMPLIA"
				nValor := aInfo[1]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NBAIXAS"
				nValor := aInfo[2]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NDEPRACM"
				nValor := aInfo[3]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NDEPRACM2"
				nValor := aInfo[4]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NDEPRBXS"
				nValor := aInfo[5]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NVOLUN"
				nValor := aInfo[9]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NSOCIE"
				nValor := aInfo[10]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NOUTROS"
				nValor := aInfo[12]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NVOLUL2"
				nValor := aInfo[13]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NSOCIE2"
				nValor := aInfo[14]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NOUTROS2"
				nValor := aInfo[15]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NAJUSTES"
				nValor := aInfo[11]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NAJUSINFLA"
				nValor := aInfo[17]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NAJUSTES2"
				nValor := aInfo[20]
				aTotais[nInc] += nValor
			ElseIf Upper( aEquivale[nInc] ) == "NAJUDINFLA"
				nValor := aInfo[21]
				aTotais[nInc] += nValor
			EndIf
		EndIf
	Next nInc
Return 

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FCabR032  � Autor � Totvs                 � Data | 06/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cabe�alho do relatorio.								      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FCabR032(Expo1)           				                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1 = Objeto tReport                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FCabR032( olReport)

	Local oSectEnb     := olReport:Section(2)
	Local lDev6        := (olReport:nDevice == 6)
	
	If  lDev6
		olReport:oPrint:NPageWidth	:= 4960.5
		olReport:oPrint:NPageHeight	:= 3478
		olReport:Section(1):nLeftMargin := 5
		olReport:Section(2):nLeftMargin := 5
	EndIf
	//Cabe�alho
	olReport:PrintText( STR0001,olReport:Row()+35  ,110)		                // "FORMATO 7.1:REGISTRO DE ACIVOS FIJOS- DETALLE DE ACTIVOS"
	olReport:PrintText( STR0002 + MV_PAR01,olReport:Row()+35  ,110)	   			 		// Per�odo
	olReport:PrintText( STR0003+cRUC,olReport:Row()+35  ,110)						// RUC
	olReport:PrintText( STR0004+ AllTrim( Upper(Capital( cApellido) )),olReport:Row()+35,110)						// "Apellidos y nombres, denominaci�n o raz�n social "
	olReport:SkipLine( 02 )
	olReport:Section(2):Init()
	oSectEnb:Printline()
	olReport:Section(1):Init()
	olReport:SetRow(olReport:Row()-Iif(olReport:Page() == 1,78,47))
	oSectEnb:Finish()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FR032Array� Autor � Totvs                 � Data | 07/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica quais colunas tem totalizadores e retorna array    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FR032Array( ExpA1 )         				                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpA1 = Array com os campos                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FR032Array( aEquivale )
	Local aRet	:= {}
	Local nInc	:= 0

	If Select( "PER" ) > 0
		For nInc := 1 To Len( aEquivale )
			If PER->( FieldPos( aEquivale[nInc] ) ) > 0
				If ValType( PER->&( aEquivale[nInc] ) ) == "N"
					aAdd( aRet, 0 )
				Else
					aAdd( aRet, NIL )
				EndIf
			Else
				If Upper( Left( aEquivale[nInc], 1 ) ) == "N"
					aAdd( aRet, 0 )
				Else
					aAdd( aRet, NIL )
				EndIf
			EndIf
		Next
	EndIf

Return aRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FRInfoATF � Autor � Totvs                 � Data | 20/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna um array com historico/valores do ativo             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FRInfoATF( cBase, cItem, cExercicio, lConsBaixados )	      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FRInfoATF( cBase, cItem, nExercicio, lConsBaixados )
Local aRet		 := {}
Local aAreaSN3	 := SN3->( GetArea() )
Local aAreaSN4	 := SN4->( GetArea() )
Local nAmplia	 := 0
Local nAmplia2	 := 0
Local nReaval	 := 0
Local nReaval2	 := 0
Local nBaixas	 := 0
Local nDeprAcm	 := 0
Local nDeprAcm2	 := 0
Local nDeprBxs	 := 0
Local nVolul	 := 0
Local nSocie	 := 0
Local nOutros	 := 0
Local nVolul2	 := 0
Local nSocie2	 := 0
Local nOutros2	 := 0
Local nAjustes   := 0
Local nAjustado  := 0
Local nAjustes2  := 0
Local nAjusInfla := 0
Local nAjuDInfla := 0
Local nHistorico := 0

DEFAULT lConsBaixados := .F.

DbSelectArea( "SN4" )
SN4->( DbSetOrder(1) )
SN4->( MsSeek( xFilial( "SN4" ) + cBase + cItem ) )
While SN4->( !Eof() ) .AND. xFilial( "SN4" ) + cBase + cItem == SN4->( N4_FILIAL + N4_CBASE + N4_ITEM )

	If SN4->N4_TIPO == "01" .AND. SN4->N4_OCORR == "09" .AND. SN4->N4_TIPOCNT == "1"		// Melhorias
		nAmplia += SN4->N4_VLROC1

	ElseIf SN4->N4_TIPO == "02" .AND. SN4->N4_OCORR == "05" .AND. SN4->N4_TIPOCNT == "1"	// Reavaliacoes
		nReaval += SN4->N4_VLROC1

		// Obs.: considerar somente os registros da SN4 cujo seu correspondente na SN3 tenha N3_TIPREAV = 1
		// (para localizar o registro na SN3 use os campos N4_SEQREAV e N3_SEQREAV.
		If SN3->( FieldPos( "N3_TIPREAV" ) ) > 0
			DbSelectArea( "SN3" )
			SN3->( DbSetOrder( 1 ) )
			If SN3->(MsSeek(xFilial("SN3")+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO+"0"+SN4->N4_SEQ))
				If 	   RTrim(SN3->N3_TIPREAV) == "1" .AND. SN3->N3_SEQREAV == SN4->N4_SEQREAV
					nVolul += SN4->N4_VLROC1
				ElseIf RTrim(SN3->N3_TIPREAV) == "2" .AND. SN3->N3_SEQREAV == SN4->N4_SEQREAV
					nSocie += SN4->N4_VLROC1
				ElseIf RTrim(SN3->N3_TIPREAV) == "3" .AND. SN3->N3_SEQREAV == SN4->N4_SEQREAV
					nOutros += SN4->N4_VLROC1
				EndIf
			EndIf
		EndIf

	ElseIf SN4->N4_TIPO == "01" .AND. SN4->N4_OCORR == "01" .AND. SN4->N4_TIPOCNT == "1"	// Baixas
		nBaixas += SN4->N4_VLROC1

	ElseIf SN4->N4_TIPO == "01" .AND. SN4->N4_OCORR == "01" .AND. SN4->N4_TIPOCNT == "4"	// Deprecia��o sobre as Baixas
		nDeprBxs += SN4->N4_VLROC1

	ElseIf SN4->N4_TIPO == "01" .AND. SN4->N4_OCORR == "01" .AND. SN4->N4_TIPOCNT == "3"	// Outras depreciacoes
		nAjustes += SN4->N4_VLROC1

	ElseIf SN4->N4_TIPO == "05" .AND. SN4->N4_TIPOCNT == "1"								// Ampliacao
		nAmplia2 += SN4->N4_VLROC1

	ElseIf SN4->N4_TIPO == "05" .AND. SN4->N4_TIPOCNT == "3"								// Reavaliacoes
		nReaval2 += SN4->N4_VLROC1

	ElseIf SN4->N4_OCORR == "06" .AND. SN4->N4_TIPOCNT == "4"								// Depreciacao acumulado no exercicio anterior
	    // Valor da deprecia��o at� o final do exerc�cio anterior.
		If Year( SN4->N4_DATA ) < nExercicio
			nDeprAcm += SN4->N4_VLROC1
		EndIf

	ElseIf SN4->N4_OCORR == "06" .AND. SN4->N4_TIPOCNT == "3"
		// Total da deprecia��o calculada no exerc�cio.
		If Year( SN4->N4_DATA ) == nExercicio
			If SN4->N4_TIPO == "02"			//reavaliacoes
				If SN3->( FieldPos( "N3_TIPREAV" ) ) > 0
					DbSelectArea( "SN3" )
					SN3->( DbSetOrder( 1 ) )
					If SN3->(MsSeek(xFilial("SN3")+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO+"0"+SN4->N4_SEQ))
						If RTrim(SN3->N3_TIPREAV) == "1" .AND. SN3->N3_SEQREAV == SN4->N4_SEQREAV
							nVolul2 += SN4->N4_VLROC1
						ElseIf RTrim(SN3->N3_TIPREAV) == "2" .AND. SN3->N3_SEQREAV == SN4->N4_SEQREAV
							nSocie2 += SN4->N4_VLROC1
						ElseIf RTrim(SN3->N3_TIPREAV) == "3" .AND. SN3->N3_SEQREAV == SN4->N4_SEQREAV
							nOutros2 += SN4->N4_VLROC1
						EndIf
					EndIf
				EndIf
			Else
				nDeprAcm2 += SN4->N4_VLROC1
			Endif
		EndIf
		DbSelectArea( "SN3" )
		SN3->( DbSetOrder( 1 ) )
		If SN3->(MsSeek(xFilial("SN3")+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO+"1"+SN4->N4_SEQ))
			nDeprAcm2 := 0
		EndIf
	EndIf

	SN4->( DbSkip() )
End

aAdd( aRet, nAmplia )					// 01- Melhorias = ampliacao
aAdd( aRet, nBaixas + nAmplia2)			// 02- Baixas + Ampliacao
aAdd( aRet, nDeprAcm )					// 03- Depreciacao Acumulada no exercicio anterior
aAdd( aRet, nDeprAcm2 )					// 04- Depreciacao Acumulada no exercicio atual
aAdd( aRet, nDeprBxs + nReaval2 )		// 05- Baixas no exercicio atual + reavaliacoes
aAdd( aRet, nReaval )					// 06- Reavaliacoes
aAdd( aRet, nAmplia )					// 07- Ampliacoes
aAdd( aRet, nBaixas+nAmplia2 )			// 08- Baixas e Ampliacoes
aAdd( aRet, nVolul )					// 09- Reavaliacao voluntaria
aAdd( aRet, nSocie )					// 10- Reavaliacao por reorganizacao de sociedade
aAdd( aRet, nAjustes )					// 11- Outros ajustes
aAdd( aRet, nOutros )					// 12- Reavaliacao outros
aAdd( aRet, nVolul2 )					// 13- Reavaliacao voluntaria - OCORRENCIA 6
aAdd( aRet, nSocie2 )					// 14- Reavaliacao por reorganizacao de sociedade - OCORRENCIA 6
aAdd( aRet, nOutros2 )			   		// 15- Reavaliacao outros - OCORRENCIA 6
aAdd( aRet, nHistorico )                // 16- Valor historico do ativo fixo em 31/12
aAdd( aRet, nAjusInfla ) 				// 17- Ajustes por Infla��o.
aAdd( aRet, nAjustado )                 // 18- Valor ajustado do ativo fixo em 31/12
aAdd( aRet, "CMETODO" )					// 19- Metodo Aplicado.
aAdd( aRet, nAjustes2 )					// 20- Deprecia��o relacionada outros Ajustes - OCORRENCIA 6
aAdd( aRet, nAjuDInfla )				// 21- Ajustes por Deprecia��o de infla��o

RestArea( aAreaSN3 )
RestArea( aAreaSN4 )

Return aRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �getTPDesc � Autor � Totvs                 � Data | 20/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a descricao do tipo de depreciacao.                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �getTPDesc( SN3->N3_TPDEPR )                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function getTPDesc( cChave, cTpDepr )
Local cDesc := ""

DbSelectArea( "SN0" )
SN0->( DbSetOrder( 1 ) )
If SN0->( MsSeek( xFilial( "SN0" ) + cChave + cTpDepr ) )
	cDesc := AllTrim(SN0->N0_DESC01)
EndIf

Return cDesc

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FR032PrtCol � Autor � Jose Lucas         � Data | 28/06/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir demais colunas quando N1_CBASE impresso em 2 ou + ���
���          � linhas.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FR032PrtCol(oSection1,aInfo)
	Local nValor := 0

	If !Empty( aInfo )
		oSection1:Cell("CN1BASE"):SetValue(PER->N1_CBASE)
		oSection1:Cell("CN3CCONTAB"):SetValue(PER->N3_CCONTAB)
		oSection1:Cell("CN1DESCRIC"):SetValue(PER->N1_DESCRIC) 
		oSection1:Cell("CN1MARCA"):SetValue(PER->N1_MARCA)
		oSection1:Cell("CN1MODELO"):SetValue(PER->N1_MODELO) 
		oSection1:Cell("CN1CHAPA"):SetValue(PER->N1_CHAPA)
		oSection1:Cell("NSLDINIC"):SetValue(Iif(Year( PER->N1_AQUISIC ) < VAL(MV_PAR01),PER->N3_VORIG1,0))
		oSection1:Cell("NAQUIS"):SetValue(Iif(Year( PER->N1_AQUISIC ) == VAL(MV_PAR01),PER->N3_VORIG1,0)) 
		oSection1:Cell("NAMPLIA"):SetValue(aInfo[1]) 
		oSection1:Cell("NBAIXAS"):SetValue(aInfo[2])
		oSection1:Cell("NAJUSTES"):SetValue(aInfo[11])
		If MV_PAR02==1 .and. !Empty(PER->N3_BAIXA) .AND. !Empty(PER->N1_BAIXA)
			nValor := PER->N3_VORIG1 + aInfo[9] + aInfo[10] + aInfo[12]
		Else
			nValor := PER->N3_VORIG1 - aInfo[2] + aInfo[9] + aInfo[10] + aInfo[12]
		Endif
		aInfo[16] := nValor
		oSection1:Cell("NHIST"):SetValue(nValor) 
		oSection1:Cell("NAJUSTADO"):SetValue(aInfo[16] + aInfo[17]) 
		oSection1:Cell("DN1AQUISIC"):SetValue(Trim(DtoC(PER->N1_AQUISIC))) 
		oSection1:Cell("DN3DINDEPR"):SetValue(Trim(DtoC(PER->N3_DINDEPR))) 
		oSection1:Cell("CMETODO"):SetValue(Iif(PER->N3_TPDEPR <> "1",Subs(GetTPDesc( "20", PER->N3_TPDEPR ),1,13),"")) 
		oSection1:Cell("CN3AUTDEPR"):SetValue(PER->N3_AUTDEPR) 
		oSection1:Cell("NN3TXDEPR1"):SetValue(PER->N3_TXDEPR1) 
		oSection1:Cell("NDEPRACM"):SetValue(aInfo[3]) 
		oSection1:Cell("NDEPRACM2"):SetValue(aInfo[4]) 
		oSection1:Cell("NDEPRBXS"):SetValue(aInfo[5]) 
		oSection1:Cell("NAJUSTES2"):SetValue(aInfo[20])
		oSection1:Cell("NDEPRHIST"):SetValue(aInfo[3] + aInfo[4] + aInfo[5] + aInfo[13] + aInfo[14] + aInfo[15]) 
	EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FR032PgMtd  � Autor � Jose Lucas         � Data | 28/06/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Quebrar descricao do metodo de calculo em 2 elementos para ���
���          � ser impresso em 2 linhas.                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FR032PgMtd()
Local nCount  := 0
Local nPosIni := 0
Local nPosFim := 0
Local cDscMetodo := ""

If ! PER->N3_TPDEPR $ " |1"
	aMetodo := {}
	cMetodo := GetTPDesc( "20", PER->N3_TPDEPR )
	For nCount := 1 To MlCount(RTrim(cMetodo),13)
		nPosIni := If(nCount==1,1,If(nCount==2,14,If(nCount==3,27,40)))
		nPosFim := If(nCount==1,13,nCount*13)
   		cDscMetodo := RTrim(Subs(cMetodo,nPosIni,nPosFim))
		If Empty(cDscMetodo)
		   Exit
		Endif
		AADD(aMetodo,cDscMetodo)
    Next nCount
EndIf
Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao     � GerArq                                 � Data � 19.03.2016 ���
���������������������������������������������������������������������������Ĵ��
��� Descricao  � Gera o arquivo magn�tico                                   ���
���������������������������������������������������������������������������Ĵ��
��� Parametros � cDir - Diretorio de criacao do arquivo.                    ���
���            � cArq - Nome do arquivo com extensao do arquivo.            ���
���������������������������������������������������������������������������Ĵ��
��� Retorno    � Nulo                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso        � 7.1 - Estructura del Registro de Activos Fijos             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GerArq(cDir)

Local nHdl       := 0
Local cLin       := ""
Local cSep       := "|"
Local cArq       := ""
Local nCont      := 0
Local nExercicio := AllTrim(MV_PAR01)
Local nContador	 := 0
Local cCampo3 	 := ""
Local lUsaCbar 	 := GetMV( "MV_USACBAR")
Local nInc 		 := 0
Local cDepraCM	 := ""
Local cDepraCM2	 := ""
Local cDeprbxs	 := ""
Local cAjustes2	 := ""
Local cVolul2	 := ""
Local cSocie2	 := ""
Local cOutros2	 := ""
Local cAjudinlfa := ""
Local nPLE		 := GetMv("MV_PLEPERU")
Local cCodBase 	 := ""
Local cCodBar	 := ""
Local cProdSAT	 := ""
Local cCatalogo	 := ""

cArq += "LE"                            // Fixo  'LE'
cArq +=  cRUC          					// Ruc
cArq +=  AllTrim(MV_PAR01)     		    // Ano
cArq +=  "00"                           // Mes Fixo '00'
cArq +=  "00"                           // Fixo '00'
cArq += "070100"                        // Fixo '070100'
cArq += "00"                            // Fixo '00'
cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao


FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
   IF SUBSTR(cDir,nCont,1)=='\'
      cDir:=Substr(cDir,1,nCont)
      EXIT
   ENDIF
NEXT

nHdl := fCreate(cDir+cArq)
If nHdl <= 0
	ApMsgStop(STR0095) // "Error al crear el archivo TXT"
Else

	dbSelectArea("PER")
	PER->(dbGoTop())
	lRet1 := .T.
	Do While PER->(!EOF())

		If Val(MV_PAR01) < 2010
			Alert(STR0091) // "Para impresi�n del TXT, el per�odo debe ser igual o superior a 2010"
			fClose(nHdl)
			return nil
		EndIf

		If Year( PER->N1_AQUISIC ) > Val(MV_PAR01)
			PER->(dbSkip())
			Loop
		EndIf

		cLin  := ""
		cProd := PER->N1_CBASE

		nAmplia	   := 0
		nAmplia2   := 0
		nReaval	   := 0
		nReaval2   := 0
		nBaixas	   := 0
		nDeprAcm   := 0
		nDeprAcm2  := 0
		nDeprBxs   := 0
		nAjustes   := 0
		nAjustado  := 0
		nAjustes2  := 0
		nAjusInfla := 0
		nAjuDInfla := 0
		nHistorico := 0
		nExercicio := Val(MV_PAR01)
		nRevTrib := 0

		DbSelectArea( "SN4" )
		SN4->( DbSetOrder(1) )
		SN4->( MsSeek( xFilial( "SN4" ) + PER->N1_CBASE + PER->N1_ITEM ) )
		While SN4->( !Eof() ) .AND. xFilial( "SN4" ) + PER->N1_CBASE + PER->N1_ITEM == SN4->( N4_FILIAL + N4_CBASE + N4_ITEM )

			If SN4->N4_OCORR == "01" .And. SN4->N4_MOTIVO == "01" .And. SN4->N4_TIPOCNT == "1"	     // Reavalia��o tribut�ria por Venda
				nRevTrib += SN4->N4_VLROC1
			EndIf

			If SN4->N4_TIPO == "01" .AND. SN4->N4_OCORR == "09" .AND. SN4->N4_TIPOCNT == "1"		// Melhorias
				nAmplia += SN4->N4_VLROC1

			ElseIf SN4->N4_TIPO == "02" .AND. SN4->N4_OCORR == "05" .AND. SN4->N4_TIPOCNT == "1"	// Reavaliacoes
				nReaval += SN4->N4_VLROC1

			ElseIf SN4->N4_TIPO == "01" .AND. SN4->N4_OCORR == "01" .AND. SN4->N4_TIPOCNT == "1"	// Baixas
				nBaixas += SN4->N4_VLROC1

			ElseIf SN4->N4_TIPO == "01" .AND. SN4->N4_OCORR == "01" .AND. SN4->N4_TIPOCNT == "4"	// Deprecia��o sobre as Baixas
				nDeprBxs += SN4->N4_VLROC1

			ElseIf SN4->N4_TIPO == "01" .AND. SN4->N4_OCORR == "01" .AND. SN4->N4_TIPOCNT == "3"	// Outras depreciacoes
				nAjustes += SN4->N4_VLROC1

			ElseIf SN4->N4_TIPO == "05" .AND. SN4->N4_TIPOCNT == "1"								// Ampliacao
				nAmplia2 += SN4->N4_VLROC1

			ElseIf SN4->N4_TIPO == "05" .AND. SN4->N4_TIPOCNT == "3"								// Reavaliacoes
				nReaval2 += SN4->N4_VLROC1

			ElseIf SN4->N4_OCORR == "06" .AND. SN4->N4_TIPOCNT == "4"								// Depreciacao acumulado no exercicio anterior
			    // Valor da deprecia��o at� o final do exerc�cio anterior.
				If Year( SN4->N4_DATA ) < nExercicio
					nDeprAcm += SN4->N4_VLROC1
				EndIf

			ElseIf SN4->N4_OCORR == "06" .AND. SN4->N4_TIPOCNT == "3"								// Depreciacao acumulado no exercicio anterior
				// Total da deprecia��o calculada no exerc�cio.
				If Year( SN4->N4_DATA ) == nExercicio
					nDeprAcm2 += SN4->N4_VLROC1
				EndIf
				DbSelectArea( "SN3" )
				SN3->( DbSetOrder( 1 ) )
				If SN3->(MsSeek(xFilial("SN3")+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO+"1"+SN4->N4_SEQ))
					nDeprAcm2 := 0
				EndIf
			EndIf

			SN4->( DbSkip() )
		End

		nContador++
		//01 - Periodo
		cLin += AllTrim(MV_PAR01)+"0000"
		cLin += cSep

		//02 - C�digo �nico de la Operaci�n (CUO)
		cLin += AllTrim(PER->N3_NODIA)
        cLin += cSep

        //03- N�mero correlativo  del asiento contable identificado  en el campo 2.
        cCampo3 := Right(AllTrim(PER->N3_NODIA),9)
        cCampo3 := Strtran( PadL(cCampo3,9), Space(1), "0")
        cLin += "M" + cCampo3
        cLin += cSep

        //04- C�digo del cat�logo utilizado.
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
		If SB1->(MsSeek(xFilial("SB1")+PER->N1_PRODUTO))
			cCodBar  := StrTran(Trim(SB1->B1_CODBAR),"|","")
			cCodBar	 := StrTran(cCodBar,"/","")
			cCodBase := StrTran(Trim(PER->N1_CBASE),"|","")
			cCodBase := StrTran(cCodBase,"/","")
			cProdSAT := Trim(SB1->B1_PRODSAT)
		Else
			cCodBar  := ""
			cCodBase := ""
			cProdSAT := ""
		EndIf

		If lUsaCbar .and. cProdSAT <> "" .And. cProdSAT == cCodBase
			cCatalogo := "1"		// UNSPSC
		ElseIf lUsaCbar .and. cCodBar <> "" .And. cCodBar == cCodBase
			cCatalogo := "3"		// GTIN
		Else
			cCatalogo := "9"		// otro
		Endif
		cLin += cCatalogo
		cLin += cSep

		//05- C�digo propio del activo fijo correspondiente al cat�logo se�alado en el campo 4.
		If cCatalogo == "1"
			cLin += cProdSAT
		ElseIf cCatalogo == "3"
			cLin += cCodBar
		Else
			cLin += cCodBase
		EndIf
		cLin += cSep

		//06- C�digo del cat�logo utilizado.
		If lUsaCbar .and. cProdSAT <> ""
			cCatalogo := "1"		// UNSPSC
		ElseIf lUsaCbar .and. cCodBar <> ""
			cCatalogo := "3"		// GTIN
		Else
			cCatalogo := ""			// otro (9 no es v�lido)
		Endif

		If nPLE > 5181
			cLin += cCatalogo
			cLin += cSep
		Endif

		//07- C�digo propio de la existencia correspondiente al cat�logo se�alado en el campo 6.
		If cCatalogo == "1"
			cLin += Trim(cProdSAT) + IIf( nPLE > 5150 .And. nPLE <= 5181, "00000000", "" )
		ElseIf cCatalogo == "3"
			cLin += cCodBar
		Else
			cLin += ""
		Endif
		cLin += cSep

		//08 - C�digo de la Cuenta Contable del Activo Fijo, desagregada hasta el nivel m�ximo de d�gitos utilizado
		cLin += IIF(nRevTrib > 0, "2","1")
		cLin += cSep

		//09 - C�digo de la Cuenta Contable del Activo Fijo, desagregada hasta el nivel m�ximo de d�gitos utilizado
		cLin += AllTrim(PER->N3_CCONTAB)
		cLin += cSep

		//10 - Estado del Activo Fijo
		cLin += IIF(PER->N3_BAIXA =="1","1","9")
		cLin += cSep

		//11 - Descripci�n del Activo Fijo
		cLin += AllTrim(PER->N1_DESCRIC)
		cLin += cSep

		//12 - Marca del Activo Fijo
		cLin += If(AllTrim(PER->N1_MARCA) != "",AllTrim(PER->N1_MARCA),"-")
		cLin += cSep

		//13 - Modelo del Activo Fijo
		cLin += If(AllTrim(PER->N1_MODELO) != "",AllTrim(PER->N1_MODELO),"-")
		cLin += cSep

		//14 - N�mero de serie y/o placa del Activo Fijo
		cLin += If(AllTrim(PER->N1_CHAPA) != "",AllTrim(PER->N1_CHAPA),"-")
        cLin += cSep

        For nInc := 1 To Len( aEquivale )
			If Upper( aEquivale[nInc] ) == "NSLDINIC"      //15 - Importe del saldo inicial del Activo Fijo
				cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
				cLin += cSep
			ElseIf Upper( aEquivale[nInc] ) == "NAQUIS"    //16 - Importe de las adquisiciones o adiciones del Activo Fijo
         		cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
        		cLin += cSep
        	ElseIf Upper( aEquivale[nInc] ) == "NAMPLIA"   //17 - Importe de las mejoras del Activo Fijo
         		cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
        		cLin += cSep
			ElseIf Upper( aEquivale[nInc] ) == "NBAIXAS"   //18 - Importe de los retiros y/o bajas del Activo Fijo
         		cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
        		cLin += cSep
			ElseIf Upper( aEquivale[nInc] ) == "NAJUSTES"  //19 - Importe por otros ajustes en el valor del Activo Fijo
         		cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
        		cLin += cSep
			ElseIf Upper( aEquivale[nInc] ) == "NVOLUN"    //20 - Valor de la revaluaci�n  voluntaria efectuada
         		cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
        		cLin += cSep
			ElseIf Upper( aEquivale[nInc] ) == "NSOCIE"    //21 - Valor de la revaluaci�n  efectuada por reorganizaci�n de sociedades
         		cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
        		cLin += cSep
        	ElseIf Upper( aEquivale[nInc] ) == "NOUTROS"   //22 - Valor de otras revaluaciones efectuada
         		cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
        		cLin += cSep
        	ElseIf Upper( aEquivale[nInc] ) == "NAJUSINFLA"//23 - Importe del valor del ajuste por inflaci�n del Fijo
         		cLin += AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
        		cLin += cSep
			ElseIf Upper( aEquivale[nInc] ) == "NDEPRACM"  //29 - Depreciaci�n  acumulada al cierre del ejercicio anterior
         		cDepraCM  := AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
			ElseIf Upper( aEquivale[nInc] ) == "NDEPRACM2" //30 - Valor de la depreciaci�n del ejercicio sin considerar  la revaluaci�n
         		cDepraCM2 := AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
			ElseIf Upper( aEquivale[nInc] ) == "NDEPRBXS"  //31 - Valor de la depreciaci�n del ejercicio relacionada con los retiros y/o bajas
         		cDeprbxs  := AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
         	ElseIf Upper( aEquivale[nInc] ) == "NAJUSTES2" //32 - Valor de la depreciaci�n relacionada  con otros ajustes
         		cAjustes2 := AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
         	ElseIf Upper( aEquivale[nInc] ) == "NVOLUL2"   //33 - Valor de la depreciaci�n de la revaluaci�n voluntaria efectuada
         		cVolul2	  := AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
         	ElseIf Upper( aEquivale[nInc] ) == "NSOCIE2"   //34 - Valor de la depreciaci�n de la revaluaci�n efectuada por reorganizaci�n de sociedades
         		cSocie2	  := AllTrim(Transform(aTotais[nInc],"@E 99999999999"))
         	ElseIf Upper( aEquivale[nInc] ) == "NOUTROS2"  //35 - Valor de la depreciaci�n de otras revaluaciones efectuadas
         		cOutros2  := AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))
         	ElseIf Upper( aEquivale[nInc] ) == "NAJUDINFLA"//36 - Valor del ajuste por inflaci�n de la depreciaci�n
         		cAjudinlfa:= AllTrim(Transform(aTotais[nInc],"@E 999999999.99"))  //IF(AllTrim(STR(aTotais[nInc]))== "0","0.00",AllTrim(STR(aTotais[nInc])))
         	EndIf
		Next

		//24 - Fecha de adquisici�n  del Activo Fijo
		cLin +=SubStr(DTOC(PER->N1_AQUISIC),1,6)+SubStr(DTOS(PER->N1_AQUISIC),1,4)
        cLin += cSep

		//25 - Fecha de inicio del Uso del Activo Fijo
		cLin +=  SubStr(DTOC(PER->N3_DINDEPR),1,6)+SubStr(DTOS(PER->N3_DINDEPR),1,4)
        cLin += cSep

		//26 - C�digo del M�todo aplicado en el c�lculo de la depreciaci�n
        cLin += AllTrim(PER->N3_TPDEPR)
        cLin += cSep

		//27 - N�mero de documento de autorizaci�n para cambiar el m�todo de la depreciaci�n
		cLin += AllTrim(PER->N3_AUTDEPR)
        cLin += cSep

		//28 - Porcentaje  de la depreciaci�n

		cLin += AllTrim(Transform(PER->N3_TXDEPR1,"@E 999999999.99"))
		cLin += cSep

		//29 - Depreciaci�n  acumulada al cierre del ejercicio anterior.
		cLin += cDepraCM
		cLin += cSep

		//30 - Valor de la depreciaci�n del ejercicio sin considerar  la revaluaci�n
		cLin += cDepraCM2
        cLin += cSep

		//31 - Valor de la depreciaci�n del ejercicio relacionada con los retiros y/o bajas
		cLin += cDeprbxs
        cLin += cSep

		//32 - Valor de la depreciaci�n relacionada  con otros ajustes
		cLin += cAjustes2
        cLin += cSep

		//33 - Valor de la depreciaci�n de la revaluaci�n voluntaria efectuada
		cLin += cVolul2
        cLin += cSep

		//34 - Valor de la depreciaci�n de la revaluaci�n efectuada por reorganizaci�n de sociedades
        cLin += cSocie2
        cLin += cSep

		//35 - Valor de la depreciaci�n de otras revaluaciones efectuadas
		cLin += cOutros2
        cLin += cSep

        //36 - Valor del ajuste por inflaci�n de la depreciaci�n
        cLin += cAjudinlfa
        cLin += cSep

		//37 - Indica el estado de la operaci�n
		cLin += "1"
		cLin += cSep

		cLin += chr(13)+chr(10)
		fWrite(nHdl,cLin)
		PER->(dbSkip())

		If cProd == PER->N1_CBASE
			lRet1 := .T.
			cProd := PER->N1_CBASE
		Else
			lRet1 := .F.
		EndIf

	EndDo

	fClose(nHdl)
	MsgAlert(STR0092,"") // "Archivo TXT generado con �xito"
EndIf

Return Nil
