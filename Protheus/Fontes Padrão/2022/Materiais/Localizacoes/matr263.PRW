#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR263.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR263  ³ Autor ³ Bruno Schmidt			³ Data ³ 07/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Registro de Inventario Permanente Valorizado.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³20/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() y   ³±±
±±³            ³        ³          ³MTR263CUnf() que hacen modificaciones ³±±
±±³            ³        ³          ³a SX1 por motivo adecuacion a fuentes ³±±
±±³            ³        ³          ³a nuevas estructuras SX para v12.     ³±±
±±³Alf. Medrano³19/11/15³PCREQ-4263³ se realiza merge 12.1.8              ³±±
±±³  Marco A.  ³16/12/16³SERINN001 ³Se aplican los cambios de Ctree en los³±±
±±³            ³        ³-127      ³CriaTrab que crean tablas temporales  ³±±
±±³            ³        ³          ³fisicas. (PER)                        ³±±
±±³Marco A. Glz³08/02/18³DMINA-654 ³Se realizan modificaciones para la    ³±±
±±³            ³        ³          ³correcta impresion de Archivo/Reporte ³±±
±±³            ³        ³          ³Inventario Valorizado. (PER)          ³±±
±±³Oscar Garcia³21/05/18³DMINA-2802³Se eliminan #IFNDEF TOP, #IFNDEF TOP  ³±±
±±³            ³        ³          ³y CriaTrab() por SONARQUBE.           ³±±
±±³Verónica Flo³11/12/19³DMINA-7913³Se agrega bifurcacion cuando existe PE³±±
±±³            ³        ³          ³MTR263CM en la función GerArq() PER   ³±±
±±³gSantacruz  ³13/01/20³DMINA-8195³Estabilizacion (Percy / RSM)          ³±±
±±³gSantacruz  ³03/03/20³DMINA-8195³Estabilizacion (Percy / RSM)          ³±±
±±³Verónica Flo³11/05/20³DMINA-9066³Se modifica función M263SemMov para la³±±
±±³            ³        ³          ³correcta extración de productos sin   ³±±
±±³            ³        ³          ³movimientos , ademas se agrean los    ³±±
±±³            ³        ³          ³puntos de entrada MTR263CM y MTR263CO ³±±
±±³            ³        ³          ³que fueron eliminados (PER)           ³±±
±±³Verónica Flo³22/05/20³DMINA-9255³Se modifica la función de Gerarq para ³±±
±±³            ³        ³          ³que indique correctamente el resultado³±±
±±³            ³        ³          ³del PE asi como tomar la UM del campo ³±±
±±³            ³        ³          ³B5_UNSUNAT o AH_CODERP (PER)		  ³±±
±±³gsantacruz  ³25/05/20³DMINA-9255³Replica de issue dmina-2024           ³±±
±±³arodriguez  ³06/06/20³DMINA-9339³Incluir productos solo con cantidad   ³±±
±±³            ³        ³          ³inicial y sin movtos inventario       ³±±
±±³            ³        ³          ³Costo unitario negativo, informa cero ³±±
±±³            ³        ³          ³Cant total cero,informa costo total>=0³±±
±±³            ³        ³          ³Otras correcciones en informe y TXT   ³±±
±±³            ³        ³          ³Buenas prácticas de programación (PER)³±±
±±³arodriguez  ³25/06/20³DMINA-9200³Ejecuta M263LocFil() y no M264LocFil()³±±
±±³            ³        ³          ³para indicar establecimiento.    (PER)³±±
±±³ARodriguez  ³17/12/20³DMINA     ³Ajustes en las columnas 5, 7, 8 y 9.  ³±±
±±³            ³        ³    -10545³manejo de MV_PLEPERU y tabla 13 SUNAT ³±±
±±³ARodriguez  ³07/01/21³DMINA     ³Ajustes en las columnas 17, 20 y 23   ³±±
±±³            ³        ³    -10791³en el TXT para prevenir rechazos PLE  ³±±
±±³Oscar Garcia³24/06/21³DMINA-    ³Se ajusta tamaño de campo Num Doc a   ³±±
±±³            ³        ³     12466³tam. campo F1_DOC en imp. de archivo; ³±±
±±³            ³        ³          ³se ajusta impresiond e titalizador.PER³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATR263()

Local oReport	:= Nil
Local lImpR4	:= FindFunction("TRepInUse") .And. TRepInUse()
Private cPerg	:="MTR263"
Private titulo	:= STR0001
Private nInd	:= 0
Private cPosCpo     := IIf(cVersao=="11", "FieldPos", "ColumnPos")
//Determina o uso dos campos _SERIE2 para o Peru
Private lSerie2 := GetNewPar("MV_LSERIE2",.T.)

If lImpR4
		oReport := ReportDef()
		If Valtype( oReport ) == 'O'
			If ! Empty( oReport:uParam )
				Pergunte( oReport:uParam, .F. )
			EndIf
			oReport:PrintDialog()
		Endif
Endif

oReport := Nil

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Bruno Schmidt		    ³ Data ³ 07/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

	Local cTamD1Doc		:= TamSX3('D1_DOC')[1]
	Local cPicD1Qt		:= PesqPict("SD1", "D1_QUANT", 18)
	Local cTamD1Qt		:= TamSX3('D1_QUANT')[1]
	Local cPicD1Cust	:= PesqPict("SD1", "D1_CUSTO", 18)
	Local cTamD1Cust	:= TamSX3('D1_CUSTO')[1]
	Local cPicD2Qt		:= PesqPict("SD2", "D2_QUANT", 18)
	Local cTamD2Qt		:= TamSX3('D2_QUANT')[1]
	Local cPicD2Cust	:= PesqPict("SD2", "D2_CUSTO1", 18)
	Local cTamD2Cust	:= TamSX3('D2_CUSTO1')[1]

	Local oSection1		:= Nil
	Local oSection2		:= Nil
	Local oSection3		:= Nil
	Local oReport		:= Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New("MATR263",SubStr(STR0001,1,94),cPerg,{|oReport| ReportPrint(oReport)}, "")// "Formato 13.1: Registro de inventario permanente valorizado – Detalle del inventario valorizado" - validação 4 digitos na pergunta estabelecimento
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:lFooterVisible := .F.	// Não imprime rodapé do protheus

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                     ³
	//³ mv_par01         // Do produto                           ³
	//³ mv_par02         // Ate o produto                        ³
	//³ mv_par03         // Do tipo                              ³
	//³ mv_par04         // Ate o tipo                           ³
	//³ mv_par05         // Da data                              ³
	//³ mv_par06         // Ate a data                           ³
	//³ mv_par07         // Que alamcen                          ³
	//³ mv_par08         // Do  Grupo                            ³
	//³ mv_par09         // Ate o Grupo                          ³
	//³ mv_par10         // Qual moeda imprimir ( 1 a 5 )        ³
	//³ mv_par11         // Qual Custo ? ( Medio / Reposicao )   ³
	//³ mv_par12         // Seq.de Impresao (Digitacao /Calculo )³
	//³ mv_par13         // Metodo de Avaliacao 		         ³
	//³ mv_par14         // Muestra prod sin movimiento? ³
	//³ mv_par15         // ¿Establecimiento?  ³
	//³ mv_par16         // ¿Generar Archivo?³
	//³ mv_par17         // ¿Directorio?	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Pergunte(cPerg, .F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da Sessao 1 - Dados do Produto                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New(oReport, STR0063, {"SB1", "SB2"}) //"Cabecalio"
	oSection1 :SetTotalInLine(.F.)
	oSection1 :SetReadOnly()
	oSection1 :SetLineStyle()
	oSection1 :SetHeaderPage()
	oSection1 :NCOLS := 1

	TRCell():New(oSection1,"CODIGO"	, "   ", STR0071			, /*Picture*/, TAMSX3("B1_COD")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/)	// "CODIGO DE EXISTENCIA"
	TRCell():New(oSection1,"TIPO"	, "   ", STR0058 + STR0028	, /*Picture*/, 30					, /*lPixel*/, /*{|| code-block de impressao }*/)	// "TIPO"  " (TABLA 5)"
	TRCell():New(oSection1,"DESC"	, "   ", STR0072			, /*Picture*/, TAMSX3("B1_DESC")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/)	// "DESCRIPCION"
	TRCell():New(oSection1,"CODUN"	, "   ", STR0073			, /*Picture*/, 30					, /*lPixel*/, /*{|| code-block de impressao }*/)	// "CODIGO DE LA UNIDAD DE MEDIDA (TABLA 6)"
	TRCell():New(oSection1,"METVAL" , "   ", STR0016 			, /*Picture*/, 30,   				, /*lPixel*/, /*{|| code-block de impressao }*/)	// "Método de Valuación
	TRCell():New(oSection1,"ESTABL"      ,"   ","CODIGO DEL ESTABLECIMIENTO" ,/*Picture*/,50,   				,/*lPixel*/,/*{|| code-block de impressao }*/)		// "cODIGO DEL ESTABLECIMIENTO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da Sessao 2 - Cont. dos dados do Produto           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2 := TRSection():New(oSection1, STR0064, {"SB1", "SB2"}) //"Produtos (Parte 2)"
	oSection2 :SetTotalInLine(.F.)
	oSection2 :SetReadOnly()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da Sessao 3 - Movimentos                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection3 := TRSection():New(oSection2, STR0065,{"SD1", "SD2", "SD3"}) //"Movimentação dos Produtos"
	oSection3 :SetTotalInLine(.F.)
	oSection3 :SetTotalText(STR0021) //"T O T A I S  :"
	oSection3 :SetReadOnly()

	oSection3 :NCOLS:=1
	TRCell():New(oSection1," "	,"",SPACE(40),/*Picture*/,80,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1," "	,"",Replicate("_",50),/*Picture*/,80,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1," "	,"",STR0082 + CRLF + STR0083 + CRLF + Replicate("_",50),/*Picture*/,80,/*lPixel*/,/*{|| code-block de impressao }*/) //"DOCUMENTO DE TRASLADO, COMPROBANTE DE PAGO,       :" - "DOCUMENTO INTERNO O SIMILAR                       :"
	oSection3 :NCOLS:=0

	TRCell():New(oSection3,"dDtMov"		, "   ", STR0040				,/*Picture*/,13         ,/*lPixel*/,/*{|| code-block de impressao }*/)	//"FECHA"
	TRCell():New(oSection3,"Tipo"		, "   ", STR0058+CRLF+STR0029	,"@!"	,8			,/*lPixel*/,/*{|| code-block de impressao }*/)  // "TIPO" "(TAB.10)"
	TRCell():New(oSection3,"cCF"		, "   ", STR0042				,"@!"		,4/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)  // "C.F"
	TRCell():New(oSection3,"SERIE"		, "   ", STR0074				,"@!"		,20			,/*lPixel*/,/*{|| code-block de impressao }*/)	// "SERIE"
	TRCell():New(oSection3,"cDoc"		, "   ", STR0043+CRLF+STR0044,"@!"		,cTamD1Doc	,/*lPixel*/,/*{|| code-block de impressao }*/)	//"DOCUMENTO" "NUMERO"
	TRCell():New(oSection3,"cTraco1"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"TpOper"		, "   ", STR0041+CRLF+STR0053 ,"@!"		,2			,/*lPixel*/,/*{|| code-block de impressao }*/)   // "TP.OPERAC." "(TABLA 12)"
	TRCell():New(oSection3,"cTraco1"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nENTQtd"	, "   ", STR0045+CRLF+STR0046	,cPicD1Qt	,cTamD1Qt	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco2"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nCusMovEnt"	, "   ", STR0045+CRLF+STR0027	,cPicD1Cust	,cTamD1Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco3"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nENTCus"	, "   ", STR0045+CRLF+STR0047	,cPicD1Cust	,cTamD1Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco4"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nSAIQtd"	, "   ", STR0050+CRLF+STR0046	,cPicD2Qt	,cTamD2Qt	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco5"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nCusMovSai"	, "   ", STR0050+CRLF+STR0027	,cPicD1Cust	,cTamD1Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco6"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nSAICus"	, "   ", STR0050+CRLF+STR0047	,cPicD2Cust	,cTamD2Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco7"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nSALDQtd"	, "   ", STR0051+CRLF+STR0046	,cPicD1Qt	,cTamD1Qt	,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco8"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nSALDCus"	, "   ", STR0051+CRLF+STR0027,cPicD1Cust	,cTamD1Cust	,/*lPixel*/,/*{|| code-block de impressao }*/) // "SALDO"###"COSTO UNITARIO"
	TRCell():New(oSection3,"cTraco9"	, "   ", "|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"TcusTot"	, "   ", STR0051+CRLF+STR0047	,cPicD1Cust ,cTamD1Cust,/*lPixel*/,/*{|| code-block de impressao }*/) // "SALDO"###"COSTO TOTAL"

	TRFunction():New(oSection3:Cell("nENTQtd"), NIL, "SUM", /*oBreak*/, "", cPicD1Qt	, /*uFormula*/, .T., .F.)
	TRFunction():New(oSection3:Cell("nENTCus"), NIL, "SUM", /*oBreak*/, "", cPicD1Cust	, /*uFormula*/, .T., .F.)

	TRFunction():New(oSection3:Cell("nSAIQtd"), NIL, "SUM", /*oBreak*/, "", cPicD2Qt	, /*uFormula*/, .T., .F.)
	TRFunction():New(oSection3:Cell("nSAICus"), NIL, "SUM", /*oBreak*/, "", cPicD2Cust	, /*uFormula*/, .T., .F.)

Return (oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Bruno Schmidt	 	    ³ Data ³ 07/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

	Local oSection1		:= oReport:Section(1)
	Local oSection2		:= oReport:Section(1):Section(1)
	Local oSection3		:= oReport:Section(1):Section(1):Section(1)
	Local cSelectD1		:= ''
	Local cWhereD1		:= '%%'
	Local cSelectD2		:= ''
	Local cD2EMISSAO	:= ''
	Local cWhereD2		:= '%%'
	Local cSelectD3		:= ''
	Local cWhereD3		:= '%%'
	Local cWhereRE		:= ''
	Local CprodAux	    := ''
	Local aSalAtu		:= {0, 0, 0, 0, 0, 0, 0}
	Local lQuery		:= .F.
	Local nTamCod		:= TamSX3("B1_COD")[1]
	Local aArea			:= GetArea()
	Local lInverte		:= .F.
	Local cTP			:= ""
	Local nSalIni		:= 0
	Local nQtIni		:= 0
	Local nX			:= 0
	Local nContador		:= 0
	Local lSele			:= .F.
	Local cTmpSD1Fil	:= ""
	Local cTmpSD2Fil	:= ""
	Local cTmpSD3Fil	:= ""
	Local cTmpSB9Fil	:= ""
	Local lRet		 	:= .T.
	Local cFilialProd 	:= ""
	Local cAliasTop 	:= ''
	Local cEstabProd	:= ""
	Local aConSX5 		:= {}
	Local cDescrX5 		:= ''
	Local aTmpFil 		:= {}
	Local nTamNDoc		:= GetSX3Cache("F1_DOC", "X3_TAMANHO")

	Private aSelFil		:= {}
	Private cSerKINV	:= SuperGetMv("MV_SERKINV", .F., "")	//Serie definida para los tipos de movimiento generados por ajuste de inventario
	Private cSerKTM		:= SuperGetMv("MV_SERKTM", .F., "")		//Serie para los movimientos operativos de inventario
	Private aLocal		:= {}
	Private nTamLocal	:= LEN(SB1->B1_LOCPAD)
	Private aLocalFiR	:= {}
	Private oTmpTable	:= Nil
	Private cProdIni 	:= mv_par01
	Private lContinua	:= .T.
	Private nPLEPeru	:= SuperGetMv("MV_PLEPERU", .F., 5150)	// Número de versión del PLE, v5.1.5.0 vigente hasta Jun/2020
	Private cLocalTrans	:= SuperGetMv("MV_DEPTRAN", .F., "")	// Almacén de tránsito
	Private cEstabTrans	:= "9999"								// Establecimiento de tránsito (IDSUNAT) Ver comentarios abajo...
	Private cMVPar15	:= ""

	/* Posible creación de parámetro MV_ESTTRAN para utilizar en solución a proceso "incompleto" en Bakels:
	 * - Registraron salidas del almacén de tránsito sin realizar la correspondiente entrada al almacén de destino (traspasos).
	 * En la tabla de almacenes (NNR) tienen el código "9999" en campo Id SUNAT para los almacenes de tránsito. El uso de la variable cEstabTrans
	 * es para evitar que se considere en el inventario inicial de almacenes normales las existencias de los de tránsito.
	 */

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MV_CUSREP - Parametro utilizado para habilitar o calculo do   ³
	//³            Custo de Reposicao.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private lCusRep  := SuperGetMv("MV_CUSREP", .F., .F.) .And. (FindFunction("MA330AvRep") .And. MA330AvRep()) //MV_CUSREP Habilitar calculo de costo de reposición .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se utiliza custo unificado por Empresa/Filial       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetCustomText({|| Cabec263(oReport)})

	If Empty(mv_par15) //Si establecimiento vacio
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			lRet := .F.
		EndIf
	Else
		aSelFil := {mv_par15}
	EndIf

	MV_PAR07	:= MT263SelLocal(ALLTRIM(MV_PAR07),aSelFil) //llena con los almacenes seleccionados, si es que MV_PAR07 (Almacen) esta vacio

	lSele		:= .F.
	For nX:=1 To Len(aLocal)
		IF aLocal[nX,1]
			lSele := .T.
			EXIT
		ENDIF
	NEXT
	IF ! lSele
		MV_PAR07 := "('" + PADR('01', nTamLocal) +  "')"
	ENDIF

	oReport:SetTitle(OemToAnsi(STR0008)+OemToAnsi(STR0009) + STR0011+" "+mv_par07)     // ""Registro de Inventario Permanente Valorizado""###"(SEQUENCIA)"###"ARMAZEM:"
	oReport:SetTitle(oReport:Title()+STR0017+STR0004+STR0018+AllTrim(&("MV_SIMB"+Str(mv_par10,1)))+")") //" (Por "###" ,em "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTamQ := TamSX3("B2_QATU")
	aTamT := TamSX3("B2_VFIM1")
	aTamX := TamSX3("F4_CF")
	aTamF := TamSX3("A2_COD")
	aTamL := TamSX3("A2_LOJA")
	aTamP := TamSX3("B2_FILIAL")

	aCampos := {}
	AADD(aCampos, {"FILIAL"   , "C", aTamP[1],aTamP[2]})
	aAdd(aCampos, {"PRODUTO"  , "C", nTamCod,0})
	aAdd(aCampos, {"EMISSAO"  , "D", 08, 0})
	aAdd(aCampos, {"SEQCALC"  , "C", 14, 0})
	aAdd(aCampos, {"NUMSEQ"   , "C", 14, 0})
	aAdd(aCampos, {"TES"      , "C", 03, 0})
	aAdd(aCampos, {"CF"       , "C", aTamX[1], aTamX[2]})
	aAdd(aCampos, {"TIPODOC"  , "C", 03, 0})
	aAdd(aCampos, {"NUMDOC"   , "C", TamSX3('D1_DOC')[1], 0})
	aAdd(aCampos, {"SERIE"    , "C", 03, 0})
	aAdd(aCampos, {"QUANT"    , "N", aTamQ[1], aTamQ[2]})
	aAdd(aCampos, {"CUSTOTAL" , "N", aTamT[1], aTamT[2]})
	aAdd(aCampos, {"CLIFOR"   , "C", aTamF[1], aTamF[2]})
	aAdd(aCampos, {"LOJA"     , "C", aTamL[1], aTamL[2]})
	AADD(aCampos, {"NODIA"    , "C", 10,0})
	AADD(aCampos, {"CUSFINAL" , "N", aTamT[1],aTamT[2]})
	AADD(aCampos, {"CUSTUNI"  , "N", aTamT[1],aTamT[2]})
	AADD(aCampos, {"CUSTINI"  , "N", aTamT[1],aTamT[2]})
	AADD(aCampos, {"DTDIGIT1" , "D", 08,0})
	AADD(aCampos, {"SERIE2"   , "C", 20,0})
	AADD(aCampos, {"SERIE3"   , "C", 20,0})
	AADD(aCampos,{"XLOCAL"   ,"C",TamSX3('B2_LOCAL')[1],0})
	AADD(aCampos,{"XTPESTAB" ,"C",TamSX3('NNR_TIPOES')[1],0})
	AADD(aCampos,{"XIDESTAB" ,"C",TamSX3('NNR_IDSUNA')[1],0})
	AADD(aCampos,{"XITEM" 	 ,"C",10,0})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)

	cAliasTop := "TRC"
	lQuery := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):BeginQuery()

	cMVPar15 := GetRngFil( aSelFil, "SB9", .T., @cTmpSB9Fil)
	MV_PAR15 := StrTran (cMVPar15, "IN ")
	aAdd(aTmpFil,cTmpSB9Fil)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do SELECT da tabela SD1                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSelectD1 := "%"
	If mv_par10 == 1 //Que costo imprimir? 1-Medio 2-Reposicion
		If lCusRep .And. mv_par11 == 2 //Si esta habilitado el proceso de Caclulo de Reposicion ## Secuencia de impresion? 1-Emision+TES 2-Calculo
			cSelectD1 += " sum(D1_CUSRP1) CUSTOTAL "
		Else
			cSelectD1 += " sum(D1_CUSTO) CUSTOTAL "
		EndIf
	Else
		If lCusRep .And. mv_par11 == 2
			cSelectD1 += " sum(D1_CUSRP"+str(mv_par10,1)+") CUSTOTAL "
		Else
			cSelectD1 += " sum(D1_CUSTO"+str(mv_par10,1)+") CUSTOTAL "
		EndIf
	EndIf

	cSelectD1 += "%"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do Where da tabela SD1                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhereD1 := "%"
	cWhereD1 += " SD1.D1_LOCAL IN "+mv_par07+" AND "
	cWhereD1 += " SD1.D1_FILIAL " + GetRngFil( aSelFil, "SD1", .T., @cTmpSD1Fil ) +  " AND "
	cWhereD1 += "%"

	aAdd(aTmpFil,cTmpSD1Fil)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do SELECT da tabela SD2                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCusRep .And. mv_par11 == 2 ////Secuencia de impresion? 1-Emision+TES 2-Calculo
		cSelectD2 := "% sum(D2_CUSRP"
		cSelectD2 += Str(mv_par10,1) + ")"// Coloca a Moeda do Custo
	Else
		cSelectD2 := "% sum(D2_CUSTO"
		cSelectD2 += Str(mv_par10,1) + ")" // Coloca a Moeda do Custo
	EndIf
	cSelectD2 += " CUSTOTAL "
	cSelectD2 += "%"
	cD2EMISSAO := "% D2_EMISSAO EMISSAO,%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do Where da tabela SD2                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhereD2 := "%"
	cWhereD2 += " SD2.D2_LOCAL IN "+mv_par07+" AND "
	cWhereD2 += " SD2.D2_EMISSAO >= '"+Dtos(mv_par05)+"' AND "
	cWhereD2 += " SD2.D2_EMISSAO <= '"+Dtos(mv_par06)+"' AND "
	cWhereD2 += " SD2.D2_FILIAL " + GetRngFil( aSelFil, "SD2", .T., @cTmpSD2Fil )+  " AND "
	cWhereD2 += "%"
    aAdd(aTmpFil,cTmpSD2Fil)
	cWhereRE := "%"
	cWhereRE += " (SD2.D2_REMITO   = '" + Space(TamSx3('D2_REMITO')[1]) + "' OR SD2.D2_TPDCENV IN ('1','A')) "
	cWhereRE += "%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do SELECT da tabelas SD3                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCusRep .And. mv_par11 == 2 //Secuencia de impresion? 1-Emision+TES 2-Calculo
		cSelectD3 := "% sum(D3_CUSRP"
		cSelectD3 += Str(mv_par10,1)  + ")"// Coloca a Moeda do Custo
	Else
		cSelectD3 := "% sum(D3_CUSTO"
		cSelectD3 += Str(mv_par10,1)  + ")"// Coloca a Moeda do Custo
	EndIf
	cSelectD3 += " CUSTOTAL "
	cSelectD3 += "%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do WHERE da tabela SD3                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhereD3 := "%"
	cWhereD3 += " SD3.D3_LOCAL IN " + mv_par07 + " AND"
	If SuperGetMV('MV_D3ESTOR', .F., 'N') == 'N'
		cWhereD3 += " SD3.D3_ESTORNO <> 'S' AND"
	EndIf
	If SuperGetMV('MV_D3SERVI', .F., 'N') == 'N' .And. IntDL()
		cWhereD3 += " ((D3_SERVIC = '   ') OR (D3_SERVIC <> '   ' AND D3_TM <= '500' AND D3_STSERV = '3')) AND"
	EndIf
	cWhereD3 += " SD3.D3_FILIAL " + GetRngFil( aSelFil, "SD3", .T., @cTmpSD3Fil )+  " AND "
	cWhereD3 += "%"
	aAdd(aTmpFil,cTmpSD3Fil)

	cOrder := "%"
	If mv_par12 == 1 //Ordenado por Digitacion/Calculo
		cOrder += " PRODUTO, EMISSAO,NODIA, NUMSEQ, TES"
	Else
		cOrder += " PRODUTO, SEQCALC, NODIA, TES"
	EndIf
	cOrder += "%"
	cWhereTP := "%"
	cWhereGR := "%"
	cWhereTP += " SB1.B1_TIPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
	cWhereGR += " SB1.B1_GRUPO BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' AND "
	cWhereTP += "%"
	cWhereGR += "%"

	BeginSql Alias cAliasTop

		SELECT
				D1_FILIAL FILIAL,
				B1_TIPO TIPO,
				D1_COD PRODUTO,
				D1_SEQCALC SEQCALC,
				D1_NUMSEQ NUMSEQ,
				D1_DTDIGIT EMISSAO,
				D1_TES TES,
				D1_CF CF,
				D1_ESPECIE TIPODOC,
				D1_DOC NUMDOC,
				D1_SERIE SERIE,
				SUM(D1_QUANT) QUANT,
				D1_FORNECE CLIFOR,
				D1_LOJA LOJA,
	            F1_NODIA NODIA,
	            F1_SERIE2 SERIE2,
	            D1_DTDIGIT DTDIGIT1,
	            D1_LOCAL XLOCAL,
		         D1_ITEM XITEM,
				%Exp:cSelectD1%

		FROM %table:SD1% SD1,%table:SF4% SF4,%table:SB1% SB1,%table:SF1% SF1
		WHERE SD1.D1_COD     >= %Exp:mv_par01% 	AND
              SD1.D1_COD     <= %Exp:mv_par02% AND
		      %Exp:cWhereD1%
		      SD1.D1_DTDIGIT >= %Exp:mv_par05% 	AND
			  SD1.D1_DTDIGIT <= %Exp:mv_par06%	AND
			  SD1.D1_ORIGLAN <> 'LF'           	AND
			  SD1.D1_REMITO  = ' '             	AND
			  SD1.D1_TIPO_NF >= ' '            	AND
			  SD1.%NotDel%						AND
			  SF4.F4_FILIAL  =  %xFilial:SF4%	AND
			  SF4.F4_CODIGO  = SD1.D1_TES 		AND
			  SF4.F4_ESTOQUE = 'S' 				AND
			  SF4.%NotDel%                     	AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND
			  %Exp:cWhereTP%
			  SB1.B1_COD     = SD1.D1_COD 		AND
		      %Exp:cWhereGR%
              SB1.%NotDel%    AND
              SF1.F1_FILIAL = SD1.D1_FILIAL  AND
	          SF1.F1_DOC = SD1.D1_DOC   AND
		      SF1.F1_SERIE = SD1.D1_SERIE AND
		      SF1.F1_FORNECE = SD1.D1_FORNECE  AND
		      SF1.F1_LOJA = SD1.D1_LOJA      AND
		      SF1.F1_TIPO = SD1.D1_TIPO      AND
		      SF1.%NotDel%
		GROUP BY D1_FILIAL,B1_TIPO,D1_COD,D1_SEQCALC,D1_NUMSEQ,D1_DTDIGIT,D1_TES,D1_CF,D1_ESPECIE,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,F1_NODIA,F1_SERIE2,D1_DTDIGIT,D1_LOCAL,D1_ITEM

		UNION
		SELECT
				D2_FILIAL FILIAL,
				B1_TIPO TIPO,
		        D2_COD PRODUTO,
		        D2_SEQCALC SEQCALC,
		        D2_NUMSEQ NUMSEQ,
		        %Exp:cD2EMISSAO%
		        D2_TES TES,
		        D2_CF CF,
		        D2_ESPECIE TIPODOC,
		        D2_DOC NUMDOC,
		        D2_SERIE SERIE,
		        SUM(D2_QUANT) QUANT,
		        D2_CLIENTE CLIFOR,
		        D2_LOJA LOJA,
		        F2_NODIA NODIA,
		        F2_SERIE2 SERIE2,
		        D2_DTDIGIT DTDIGIT1,
		        D2_LOCAL XLOCAL,
		        D2_ITEM XITEM,
				%Exp:cSelectD2%
		FROM %table:SD2% SD2,%table:SF4% SF4,%table:SB1% SB1,%table:SF2% SF2
		WHERE SD2.D2_COD     >= %Exp:mv_par01% 	AND
              SD2.D2_COD     <= %Exp:mv_par02% AND
		      %Exp:cWhereD2%
			  SD2.D2_ORIGLAN <> 'LF'           	AND
			  %Exp:cWhereRE%                    	AND
			  SD2.%NotDel%						AND
			  SF4.F4_FILIAL  =  %xFilial:SF4%	AND
			  SF4.F4_CODIGO  = SD2.D2_TES 		AND
			  SF4.F4_ESTOQUE = 'S' 				AND
			  SF4.%NotDel%                     	AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND
			  %Exp:cWhereTP%
			  SB1.B1_COD     = SD2.D2_COD 		AND
		      %Exp:cWhereGR%
              SB1.%NotDel%  AND
              SF2.F2_FILIAL = SD2.D2_FILIAL  AND
		      SF2.F2_DOC = SD2.D2_DOC   AND
		      SF2.F2_SERIE = SD2.D2_SERIE AND
		      SF2.F2_CLIENTE = SD2.D2_CLIENTE  AND
		      SF2.F2_LOJA = SD2.D2_LOJA      AND
		      SF2.F2_TIPO = SD2.D2_TIPO      AND
              SF2.%NotDel%
		GROUP BY D2_FILIAL,B1_TIPO,D2_COD,D2_SEQCALC,D2_NUMSEQ,D2_EMISSAO,D2_TES,D2_CF,D2_ESPECIE,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_UM,F2_NODIA,F2_SERIE2,D2_DTDIGIT,D2_LOCAL,D2_ITEM

		UNION
		SELECT
				D3_FILIAL FILIAL,
				B1_TIPO TIPO,
				D3_COD PRODUTO,
				D3_SEQCALC SEQCALC,
				D3_NUMSEQ NUMSEQ,
				D3_EMISSAO EMISSAO,
				D3_TM TES,
				D3_CF CF,
				D3_CF TIPODOC,
				D3_DOC NUMDOC,
				' ' SERIE,
				SUM(D3_QUANT) QUANT,
				' ' CLIFOR,
				' ' LOJA,
				D3_NODIA NODIA,
				' ' SERIE2,
				D3_EMISSAO DTDIGIT1,
				D3_LOCAL XLOCAL,
				' ' XITEM,
				%Exp:cSelectD3%

		FROM %table:SD3% SD3,%table:SB1% SB1
		WHERE SD3.D3_COD     >= %Exp:mv_par01% 	AND
              SD3.D3_COD     <= %Exp:mv_par02% AND
		      SD3.D3_EMISSAO >= %Exp:mv_par05% 	AND
			  SD3.D3_EMISSAO <= %Exp:mv_par06%	AND
			  %Exp:cWhereD3%
			  SD3.%NotDel%						AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND
			  %Exp:cWhereTP%
			  SB1.B1_COD     = SD3.D3_COD 		AND
		      %Exp:cWhereGR%
              SB1.%NotDel%
		GROUP BY D3_FILIAL,B1_TIPO,D3_COD,D3_SEQCALC,D3_NUMSEQ,D3_EMISSAO,D3_TM,D3_CF,D3_CF,D3_DOC,D3_UM,D3_EMISSAO,D3_NODIA,D3_EMISSAO,D3_LOCAL
		ORDER BY PRODUTO,NODIA, EMISSAO

	EndSql

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatorio para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

	aEval(aCampos, {|e| IIf(e[2]!= "C", TCSetField("TRC", e[1], e[2],e[3],e[4]),Nil)})

	MTR263FillTrb(aCampos)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("TRB")
	oReport:SetMeter(TRB->(LastRec()))
	dbGoTop()

	If AllTrim(str(MV_PAR16)) $ "2|3"
		While !oReport:Cancel() .And. !("TRB")->(Eof())

			If !SB1->(MsSeek(xFilial()+TRB->PRODUTO))
				TRB->(dbSkip())
				Loop
			EndIf

			If SB1->B1_GRUPO < MV_PAR08 .Or.SB1->B1_GRUPO > MV_PAR09
				TRB->(dbSkip())
				Loop
			EndIf

			oSection3:Cell("nSALDQtd"):SetValue(0)
			oSection3:Cell("nSALDCus"):SetValue(0)
			oSection3:Cell("TcusTot") :SetValue(0)
			oSection3:Cell("nSAIQTD") :SetValue(0)

			cProduto := TRB->PRODUTO

			If TRB->FILIAL <> cFilialProd
				cFilialProd := TRB->FILIAL
		    EndIf

		    If TRB->XIDESTAB <> cEstabProd
		    	cEstabProd := TRB->XIDESTAB
			EndIf

			aLocalFiR := M263LocFil(mv_par07,TRB->FILIAL,TRB->PRODUTO,TRB->XIDESTAB) //Rutina ubicada en PERXTMP

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento para produtos sem movimentacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ALLTRIM(TRB->NUMDOC) == "*SINMOV*"
				aSalAtu	:= {0, 0, 0, 0, 0, 0, 0};				nQtini	:= 0;				nSalIni	:= 0
				For nX:=1 To Len(aLocalFiR)
					IF aLocalFiR[nX,1] .And. (aLocalFiR[nX,2] <> cLocalTrans .Or. TRB->XIDESTAB == cEstabTrans)
						aSalAtu1 := M264fCalcEst(SB1->B1_COD,aLocalFiR[nX,2],MV_PAR05,TRB->FILIAL) ////Rutina ubicada en PERXTMP
						nQtIni +=aSalAtu1[1]           // QUANTIDADE
						nSalIni+=aSalAtu1[MV_PAR10+1]  // VALOR
					ENDIF
				Next

				aSalAtu[1]			+= nQtIni
				aSalAtu[mv_par10+1]	+= nSalIni

				If nQtIni <> 0
					aConSX5 := FWGetSX5( "P6",Alltrim( MV_PAR13 ),"ES" )
					cDescrP6 :=  SUBSTR(TRIM(aConSX5[1,4]),1,26)
					oSection1:Init()
					oSection1:Cell("CODIGO"):SetValue(SB1->B1_COD)
					oSection1:Cell("TIPO")  :SetValue(fTabla5(SB1->B1_TIPO))
					oSection1:Cell("DESC")  :SetValue(SB1->B1_DESC)
					oSection1:Cell("CODUN") :SetValue(fTabla6(SB1->B1_UM))
					cDescrX5 := aConSX5[1,4]
					oSection1:Cell("METVAL") :SetValue(Alltrim( MV_PAR13 )+' - '+cDescrX5 )
					aConSX5 := FWGetSX5( "XZ",TRB->XTPESTAB,"ES" )
					cDescrX5 :=  aConSX5[1,4]
					oSection1:Cell("ESTABL") :SetValue(TRB->XIDESTAB +' - '+ cDescrX5 )
					oSection1:PrintLine()

					oSection3:Init()
					oSection3:Cell("dDtMov")	:SetValue(MV_PAR05)  // STR0020 "SALDO INICIAL"
					oSection3:Cell("Tipo")   	:SetValue(' ')
					oSection3:Cell("cCF")   	:SetValue(' ')
					oSection3:Cell("SERIE")	    :SetValue(' ')
					oSection3:Cell("cDoc")	    :SetValue(' ')
					oSection3:Cell("cTraco1")	:SetValue(' ')
					oSection3:Cell("TpOper")	:SetValue('16')
					oSection3:Cell("cTraco1")	:SetValue(' ')
					oSection3:Cell("nSALDQtd")	:Hide()
					oSection3:Cell("cTraco2")	:SetValue(' ')
					oSection3:Cell("nCusMovEnt"):Hide()
					oSection3:Cell("cTraco3")	:SetValue(' ')
					oSection3:Cell("TcusTot")	:Hide()
					oSection3:Cell("cTraco4")	:SetValue(' ')
					oSection3:Cell("nSAIQtd")	:Hide()
					oSection3:Cell("cTraco5")	:SetValue(' ')
					oSection3:Cell("nCusMovSai"):Hide()
					oSection3:Cell("cTraco6")	:SetValue(' ')
					oSection3:Cell("nSAICus")	:SetValue(0)
					oSection3:Cell("nSAICus")	:Hide()
					oSection3:Cell("cTraco7")	:SetValue(' ')
					oSection3:Cell("nSALDCus")	:Hide()
					oSection3:Cell("nENTQtd")	:Show()
					oSection3:Cell("nENTQtd")	:SetValue(nQtIni)
					oSection3:Cell("nCusMovEnt")	:Show()
					oSection3:Cell("nENTCus")	:Show()
					oSection3:Cell("nENTCus")	:SetValue(nSalIni)
					oSection3:Cell("nSALDqtd")	:Show()
					oSection3:Cell("nSALDqtd")	:SetValue(nQtIni)
					oSection3:Cell("nSALDCus")	:Show()
					oSection3:Cell("tcusTot")	:Show()
					oSection3:Cell("tcusTot")	:SetValue(nSalIni)
					If nQtIni<>0
						oSection3:Cell("nCusMovEnt")	:SetValue(Max(nSalIni/nQtini, 0))
						oSection3:Cell("nSALDCus")	:SetValue(Max(nSalIni/nQtini, 0))
					Else
						oSection3:Cell("nCusMovEnt")	:SetValue(0)
						oSection3:Cell("nSALDCus")		:SetValue(0)
					EndIf
					oSection3:Cell("cTraco8")	:SetValue(' ')
					oSection3:Cell("cTraco9")	:SetValue(' ')
					oSection3:PrintLine()
					oReport:PrintText(STR0023)	//"NO HUBO MOVIMIENTO PARA ESTE PRODUCTO"
					oSection1:Finish()
					oSection3:Finish()
					oReport:ThinLine()
				EndIf

				TRB->(dbSkip())
				Loop
			EndIf

			If oReport:Cancel()
				Exit
			EndIf

			CprodAux := ""
			nContador := 0

			If !lQuery .Or. (lQuery .And. TRB->PRODUTO == SB1->B1_COD)
				While TRB->(!Eof()) .And. TRB->PRODUTO == cProduto .and. TRB->XIDESTAB == cEstabProd

					If oReport:Cancel()
						Exit
					EndIf

					oReport:IncMeter()

					If CprodAux <> SB1->B1_COD

						aSalAtu   := {0,0,0,0,0,0,0}
						aConSX5 := FWGetSX5( "P6",Alltrim( MV_PAR13 ),"ES" )
						cDescrP6 :=  SUBSTR(TRIM(aConSX5[1,4]),1,26)

						oSection1:Init()
						oSection1:Cell("CODIGO"):SetValue(SB1->B1_COD)
						oSection1:Cell("TIPO")  :SetValue(fTabla5(SB1->B1_TIPO))
						oSection1:Cell("DESC")  :SetValue(SB1->B1_DESC)
						oSection1:Cell("CODUN") :SetValue(fTabla6(SB1->B1_UM))

						aConSX5 := FWGetSX5( "P6",Alltrim( MV_PAR13 ),"ES" )
						cDescrX5 := aConSX5[1,4]

						oSection1:Cell("METVAL") :SetValue(Alltrim( MV_PAR13 )+' - '+cDescrX5 )

						aConSX5 := FWGetSX5( "XZ",TRB->XTPESTAB,"ES" )
						cDescrX5 :=  aConSX5[1,4]

						oSection1:Cell("ESTABL") :SetValue(TRB->XIDESTAB +' - '+ cDescrX5 )
						oSection1:PrintLine()
						CprodAux:= SB1->B1_COD
						nQtini	:= 0
						nSalIni	:= 0

						//repetir impresión de saldos por cada filial que esta en el proceso de generación.
		         		For nX:=1 To Len(aLocalFiR)
		        			IF aLocalFiR[nX,1] .And. (aLocalFiR[nX,2] <> cLocalTrans .Or. TRB->XIDESTAB == cEstabTrans)
		                  	   aSalatu1 := M264fCalcEst(SB1->B1_COD,aLocalFiR[nX,2],MV_PAR05,TRB->FILIAL) //Rutina ubicada en PERXTMP
		                       nQtIni += aSalAtu1[1]           // QUANTIDADE
		                       nSalIni += aSalAtu1[MV_PAR10+1]  // VALOR
			                ENDIF
			            Next

						aSalAtu[1]			+= nQtIni
						aSalAtu[mv_par10+1]	+= nSalIni

						// Guarda o valor para o arquivo TXT
		                RecLock("TRB",.F.)
		                TRB->CUSTINI := nQtIni
						TRB->(MsUnlock())

						oSection3:Init()
						oSection3:Cell("dDtMov")	:SetValue(MV_PAR05)  // STR0020 "SALDO INICIAL"
						oSection3:Cell("Tipo")   	:SetValue(' ')
						oSection3:Cell("cCF")   	:SetValue(' ')
						oSection3:Cell("SERIE")	    :SetValue(' ')
						oSection3:Cell("cDoc")	    :SetValue(' ')
						oSection3:Cell("cTraco1")	:SetValue(' ')
						oSection3:Cell("TpOper")	:SetValue('16')
						oSection3:Cell("cTraco1")	:SetValue(' ')
						oSection3:Cell("nSALDQtd")	:Hide()
						oSection3:Cell("cTraco2")	:SetValue(' ')
						oSection3:Cell("nCusMovEnt"):Hide()
						oSection3:Cell("cTraco3")	:SetValue(' ')
						oSection3:Cell("TcusTot")	:Hide()
						oSection3:Cell("cTraco4")	:SetValue(' ')
						oSection3:Cell("nSAIQtd")	:Hide()
						oSection3:Cell("cTraco5")	:SetValue(' ')
						oSection3:Cell("nCusMovSai"):Hide()
						oSection3:Cell("cTraco6")	:SetValue(' ')
						oSection3:Cell("nSAICus")	:SetValue(0)
						oSection3:Cell("nSAICus")	:Hide()
						oSection3:Cell("cTraco7")	:SetValue(' ')
						oSection3:Cell("nSALDCus")	:Hide()
						oSection3:Cell("nENTQtd")	:Show()
						oSection3:Cell("nENTQtd")	:SetValue(nQtIni)
						oSection3:Cell("nCusMovEnt")	:Show()
						oSection3:Cell("nENTCus")	:Show()
						oSection3:Cell("nENTCus")	:SetValue(nSalIni)
						oSection3:Cell("nSALDqtd")	:Show()
						oSection3:Cell("nSALDqtd")	:SetValue(nQtIni)
						oSection3:Cell("nSALDCus")	:Show()
						oSection3:Cell("tcusTot")	:Show()
						oSection3:Cell("tcusTot")	:SetValue(nSalIni)

						IF nQtIni <> 0
							oSection3:Cell("nCusMovEnt")	:SetValue(Max(nSalIni/nQtini, 0))
							oSection3:Cell("nSALDCus")		:SetValue(Max(nSalIni/nQtini, 0))
						ELSE
							oSection3:Cell("nCusMovEnt")	:SetValue(0)
							oSection3:Cell("nSALDCus")		:SetValue(0)
						ENDIF

						oSection3:Cell("cTraco8")	:SetValue(' ')
						oSection3:Cell("cTraco9")	:SetValue(' ')
						oSection3:PrintLine()
						nContador += 1
					EndIf

					dbSelectArea("TRB")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica la fecha para productos sin movimientos        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oSection3:Init()
					oSection3:Cell("nSAICus"):SetValue(0)

					If lQuery
						If ALLTRIM(TIPODOC) $ "FT/NF"
							TIPODOC := "FAC"
						EndIf
					EndIf

					If CtoD("  /  /  ") != EMISSAO

						oSection3:Cell("dDtMov"):SetValue(EMISSAO)
						oSection3:Cell("cCF")   :SetValue(TIPODOC)

						// ----------------------------------------------------------------------------------- //
						// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
						// ----------------------------------------------------------------------------------- //
						_cSerieNf := TRB->SERIE
						If TRB->TES > "500" // Documentos de Salida
							_cSerieNf := M264getSerie2("1/3/4/5/6/7") //Rutina ubicada en PERXTMP
						Else
							_cSerieNf := M264getSerie2("2") //Rutina ubicada en PERXTMP
						EndIf

						If Empty(_cSerieNf)
							If lSerie2 .And. !Empty(AllTrim(TRB->SERIE2))
								_cSerieNf := AllTrim(TRB->SERIE2)
							Elseif  !Empty(AllTrim(TRB->SERIE))
								_cSerieNf := AllTrim(TRB->SERIE)
							Else
								_cSerieNf := "0"
							EndIf
						Endif

						If Alltrim(TRB->NUMDOC) $ "INVENT" .AND. Alltrim(TRB->CF) $ "DE0|RE0"
					    	_cSerieNf :=  Alltrim(cSerKINV)
						Elseif Alltrim(TRB->CF) $ "DE0|DE1|DE4|DE6|ER0|PR0|RE0|RE1|RE4|RE6"
							_cSerieNf :=  Alltrim(cSerKTM)
						EndIf

						If len(Alltrim(_cSerieNf))==3
							_cSerieNf += "0"+alltrim(_cSerieNf)
						EndIf

						oSection3:Cell("SERIE") :SetValue(_cSerieNf)
						oSection3:Cell("cDoc")  :SetValue(Right(Alltrim(NUMDOC), nTamNDoc))

						If TES <= "500"
							oSection3:Cell("nENTQtd"):Show()
							oSection3:Cell("nENTCus"):Show()
							oSection3:Cell("nENTQtd"):SetValue(QUANT)
							oSection3:Cell("nENTCus"):SetValue(Round(CUSTOTAL,aTamT[2]))

							nCusto := 0
							If QUANT != 0
								nCusto := Max(Round(CUSTOTAL,aTamT[2])/QUANT, 0)
								oSection3:Cell("nCusMovEnt"):Show()
								oSection3:Cell("nCusMovEnt"):SetValue(nCusto)
							Else
								oSection3:Cell("nCusMovEnt"):Hide()
								oSection3:Cell("nCusMovEnt"):SetValue(0)
							EndIf

							oSection3:Cell("nSAIQtd"):Hide()
							oSection3:Cell("nCusMovSai"):Hide()
							oSection3:Cell("nSAICus"):Hide()
							oSection3:Cell("nSAIQtd"):SetValue(0)
							oSection3:Cell("nCusMovSai"):SetValue(0)
							oSection3:Cell("nSAICus"):SetValue(0)
						Else
							oSection3:Cell("nENTQtd"):Hide()
							oSection3:Cell("nCusMovEnt"):Hide()
							oSection3:Cell("nENTCus"):Hide()
							oSection3:Cell("nENTQtd"):SetValue(0)
							oSection3:Cell("nCusMovEnt"):SetValue(0)
							oSection3:Cell("nENTCus"):SetValue(0)

							oSection3:Cell("nSAIQtd"):Show()
							oSection3:Cell("nSAICus"):Show()
							oSection3:Cell("nSAIQtd"):SetValue(QUANT * -1)					// Salida ==> Negativo
							oSection3:Cell("nSAICus"):SetValue(Round(CUSTOTAL,aTamT[2]) * -1)

							nCusto := 0
							If QUANT != 0
								nCusto := Max(Round(CUSTOTAL,aTamT[2])/QUANT, 0)
								oSection3:Cell("nCusMovSai"):Show()
								oSection3:Cell("nCusMovSai"):SetValue(nCusto)
							Else
								oSection3:Cell("nCusMovSai"):Hide()
								oSection3:Cell("nCusMovSai"):SetValue(0)
							EndIf
						EndIf

						// Totalizadores
						If TES <= "500"
							aSalAtu[1] += QUANT
							aSalAtu[mv_par10+1] += IIF(QUANT > 0 .And. nCusto > 0,( QUANT * nCusto ),Round(CUSTOTAL,aTamT[2]))
							aSalAtu[7] += ConvUm(SB1->B1_COD,QUANT,0,2)
						Else
							aSalAtu[1] -= QUANT
							aSalAtu[mv_par10+1] -= Round(CUSTOTAL,aTamT[2])
							aSalAtu[7] -= ConvUm(SB1->B1_COD,QUANT,0,2)
						EndIf

						nSaldoT  := 0
						nTcusTot := 0

						If aSalAtu[1] != 0
							nSaldoT := Max(aSalAtu[mv_par10+1]/aSalAtu[1], 0)
							oSection3:Cell("nSALDQtd"):Show()
							oSection3:Cell("nSALDCus"):Show()
							oSection3:Cell("TcusTot") :Show()
							oSection3:Cell("nSALDQtd"):SetValue(aSalAtu[1])
							oSection3:Cell("nSALDCus"):SetValue(nSaldoT)
							nTcusTot:=Round(aSalAtu[mv_par10+1],aTamT[2])
							oSection3:Cell("TcusTot") :SetValue(nTcusTot)
						Else
							oSection3:Cell("nSALDQtd"):Show()
							oSection3:Cell("nSALDCus"):Show()
							oSection3:Cell("TcusTot") :Show()
							oSection3:Cell("nSALDQtd"):SetValue(0)
							oSection3:Cell("nSALDCus"):SetValue(0)
							oSection3:Cell("TcusTot") :SetValue(0)
						EndIf

			        	// Guarda o valor para o arquivo TXT
						RecLock("TRB",.F.)
						TRB->CUSTUNI  := nSaldoT
						TRB->CUSFINAL := nTcusTot
						TRB->(MsUnlock())
						cMovto := ""

						If TRB->TES > "500" .And. ALLTRIM(TRB->TIPODOC) $ "REM|NF|FAC"
							cMovto := OemToAnsi(STR0030) //"CLI"
						ElseIf TRB->TES > "500" .And. ALLTRIM(TRB->TIPODOC) $ "RE0|DE0|RE8|DE8|RE3"
							cMovto := OemToAnsi(STR0032) //"CC"
						ElseIf TRB->TES <= "500" .And. ALLTRIM(TRB->TIPODOC) $ "RE6|DE6"
							cMovto := OemToAnsi(STR0034) //"MAN"
						ElseIf TRB->TES <= "500" .And. ALLTRIM(TRB->TIPODOC) $ "RE8|DE8|DE3"
							cMovto := OemToAnsi(STR0032) //"CC"
						ElseIf TRB->TES <= "500" .And. ALLTRIM(TRB->TIPODOC) $ "REM|NF|FAC"
							cMovto := OemToAnsi(STR0031) //"PROV"
						Else
							cMovto := OemToAnsi(STR0033) //"OP"
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega os Tipos de Operacao ref. a tabela 12 da lei    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aArea:=Getarea()
						If ALLTRIM(TRB->TIPODOC) $ "RE4|DE4"
							cTP:=""
							cTP:="11"
							oSection3:Cell("TpOper"):SetValue(cTP)
						ElseIf ALLTRIM(TRB->TIPODOC) $ "REM|NF|FAC|RCN|RFN"
							DbSelectArea("SF4")
							Dbsetorder(1) //F4_FILIAL+F4_CODIGO
							If MsSeek(cFilialProd+TRB->TES) .Or. MsSeek(XFILIAL()+TRB->TES)
								If Alltrim(SF4->F4_TPOP) <> ""
									oSection3:Cell("TpOper"):SetValue(SF4->F4_TPOP)
								Else
									cTP:=""
									cTP:="99"
									oSection3:Cell("TpOper"):SetValue(cTP)
								EndIf
							EndIf
						Else
							cTP:=""
							cTP:="99"
							oSection3:Cell("TpOper"):SetValue(cTP)
						EndIf
						RestArea(aArea)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega os Tipos de Operacao ref. a tabela 10 da lei    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ALLTRIM(TRB->TIPODOC) $ "NDI/NCC"
							oSection3:Cell("TIPO"):SetValue("07")
			           	ElseIf ALLTRIM(TRB->TIPODOC) $ "FAC"
			           		oSection3:Cell("TIPO"):SetValue("01")
			           	ElseIf ALLTRIM(TRB->TIPODOC) $ "RCN/RTS/RTE/RCD"
			           		oSection3:Cell("TIPO"):SetValue("09")
			            ElseIf ALLTRIM(TRB->TIPODOC) $ "NDC"
			           		oSection3:Cell("TIPO"):SetValue("08")
			           	Else
			           		oSection3:Cell("TIPO"):SetValue("00")
			            EndIf

						oSection3:PrintLine()
						nContador += 1
						If lInverte
							Loop
						EndIf

					EndIf

					dbSelectArea("TRB")
					dbSkip()

				EndDo
			EndIf

			If nContador > 0
				oSection1:Finish()
				oSection3:Finish()
				oReport:ThinLine()
			EndIf

		EndDo
	EndIf

	If AllTrim(str(MV_PAR16)) $ "1|3"  // - IMPRESSÃO DO ARQUIVO MAGNETICO
		Processa({|| GerArq(AllTrim(MV_PAR17))}, STR0085, STR0086, .T. ) //"Espere..." - "Generando Archivo Magnético..."
	EndIf

	dbSelectArea("TRB")
	dbCloseArea()

	If lQuery
		If oTmpTable <> Nil
			oTmpTable:Delete()
			oTmpTable := Nil
		EndIf
	EndIf

	For nX := 1 to Len(aTmpFil)
		CtbTmpErase(aTmpFil[nX])
	Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR263NFExp ³ Autor ³Lucas				 ³ Data ³18/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arquivo TRB com resultado da Query                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR263                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function MTR263FillTrb(aCampos)
Local aOrdem	:= {}
Local aCodsPrds := {}
Local cTip,cId	:= ''
Local lNNRCmp	:= (FWModeAccess("NNR",3) == "C")

If Select("TRB") > 0
		TRB->(DbCloseArea())
EndIf
NNR->( dbSetOrder(1) )
If mv_par12 == 1
	aOrdem := {"PRODUTO", "XIDESTAB", "XLOCAL","XTPESTAB", "FILIAL","EMISSAO","NODIA","TES"}
Else
	aOrdem := {"PRODUTO","XIDESTAB","XLOCAL","XTPESTAB","FILIAL","SEQCALC","NODIA", "TES"}
Endif

oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields(aCampos)
oTmpTable:AddIndex("IN1", aOrdem)
oTmpTable:Create()

DbSelectArea("TRC")
DbGoTop()
While !TRC->(Eof())

	cTip:=''; cId:=''
	if	NNR->( MsSeek( IIf(lNNRCmp,xFilial("NNR"),FWxFilial("NNR",TRC->FILIAL))+TRC->XLOCAL ) )
	  	cTip:=NNR->NNR_TIPOES; cId:=NNR->NNR_IDSUNA
	 endif

		DbSelectArea("TRB")
		Reclock("TRB",.T.)
		 	FILIAL 		:=	TRC->FILIAL
		 	PRODUTO 	:=	TRC->PRODUTO
		 	EMISSAO 	:=	TRC->EMISSAO
		 	SEQCALC 	:=	TRC->SEQCALC
		 	NUMSEQ 		:=	TRC->NUMSEQ
		 	TES 		:=	TRC->TES
		 	CF 			:=	TRC->CF
		 	TIPODOC 	:=	If(AllTrim(TRC->TIPODOC) $ "FT|NF","FAC",TRC->TIPODOC)
		 	NUMDOC 		:=	TRC->NUMDOC
		 	SERIE 		:=	TRC->SERIE
		 	QUANT 		:=	TRC->QUANT
		 	CUSTOTAL 	:=	TRC->CUSTOTAL
		 	CLIFOR	 	:=	TRC->CLIFOR
		 	LOJA		:=	TRC->LOJA
		 	NODIA		:=	M264NodiaOrig(TRC->SERIE,TRC->NUMDOC,TRC->TIPODOC,TRC->CLIFOR,TRC->LOJA,TRC->NUMDOC,TRC->FILIAL)	//Rutina ubicada en PERXTMP
			SERIE2		:=    TRC->SERIE2
		 	DTDIGIT1	:=	TRC->DTDIGIT1
		 	XLOCAL 		:=	TRC->XLOCAL
		 	XTPESTAB	:=	cTip
		 	XIDESTAB	:=	cId
		 	XITEM 		:=	TRC->XITEM
		MsUnLock()

		If aScan(aCodsPrds, {|x| x[1]+x[2]+x[3]+x[4] == TRB->PRODUTO+TRB->FILIAL+TRB->XLOCAL+TRB->XIDESTAB }) == 0
			Aadd( aCodsPrds, {TRB->PRODUTO,TRB->FILIAL,TRB->XLOCAL,TRB->XIDESTAB} )
		EndIf

		DbSelectArea("TRC")
		TRC->(DbSkip())
	EndDo
	IF MV_PAR14 == 1
		M263SemMov(aCodsPrds)
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cabec263   ³ Autor ³ Bruno Schmidt       ³ Data ³ 15/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Cria o cabecalio da rotia		                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR262                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cabec263( oReport )

	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)  // caracter dummy para alinhamento do cabeçalho
	Local cDescrP6	:= ''
	Local cPERIODO	:= ''
	Local aEmpres:={}
	Local aConSX5:={}

	cPERIODO := dtoC(mv_par05)+" a "+DtoC(mv_par06)

	aEmpres:= FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC","M0_ENDCOB","M0_NOMECOM" } )

	aConSX5 := FWGetSX5( "P6",Alltrim( MV_PAR13 ),"ES" )
	cDescrP6 :=  SUBSTR(TRIM(aConSX5[1,4]),1,26)

	aCabec :=	{"__LOGOEMP__" , cChar + "         " + "         " + cChar + RptFolha +;
	 			TRANSFORM(oReport:Page(),'999999'), cChar + "         " + "         " + cChar, ;
				UPPER(AllTrim(titulo)), STR0054 + cPERIODO, " RUC.: " + aEmpres[1,2],;
				STR0061 +Trim( aEmpres[3,2]),;   // "Apellidos y nombres, Denominación o razón social: "####" / Filial:" + STR0062 + Trim(SM0->M0_FILIAL)
				STR0016 +Alltrim( MV_PAR13 )+' - '+AllTrim(cDescrP6)+cChar} // "Método de Valuación:"

	RestArea(aArea)

Return aCabec



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fTabla5  ³ Autor ³ Ricardo Berti         ³ Data ³12.11.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem cod. SUNAT Tabla 5 - Tipos de Existencia             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC2 := fTabla5(ExpC1)				                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Tipo de Material Protheus (SX5-Tab.02)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC2: Tipo de Existencia SUNAT      					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR263                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fTabla5(cTipo)

	Local cTipoS := ""
	Local aConSX5 := {}
	Local cDescX5 := ''

	Default cTipo := ""

	Do Case
		Case cTipo == "ME" // MERCADERIA
			cTipoS := "01"
		Case cTipo == "PA" // PRODUCTO TERMINADO
			cTipoS := "02"
		Case cTipo $ "MC|MP|PI|PP" // MATERIAS PRIMAS Y AUXILIARES - MATERIALES
			cTipoS := "03"
		Case cTipo == "EM" // ENVASES Y EMBALAJES
			cTipoS := "04"
		Case cTipo == "OI" // SUMINISTROS DIVERSOS
			cTipoS := "05"
		Otherwise 	// AI BN GG MO PV SL SP
			aConSX5 := FWGetSX5( "02",cTipo,"ES" )
			cDescX5 := aConSX5[1,4]
			cTipoS := "99 - " + Trim(cDescX5)
	EndCase

Return (cTipoS)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fTabla6  ³ Autor ³ Ricardo Berti         ³ Data ³12.11.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem codigo SUNAT Tabla 6 - Unidades de Medida 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC2 := fTabla6(ExpC1)				                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Unidade de Medida Protheus (SAH)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC2: Unidade de Medida SUNAT       					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR263                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fTabla6(cUMedida)

Local cUM := ""
Default cUMedida := ""

SAH->( dbSetOrder(1) )
IF SAH->( MsSeek( xFilial("SAH")+cUMedida) )
	cUM := Trim(SAH->AH_QPREF1)+" - "+Trim(SAH->AH_DESCES)
ENDIF

Return (cUM)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M263SemMov ³ Autor ³ MicroSiga           ³ Data ³28/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento para produtos sem movimento                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M263SemMov(aCodsPrds)
Local aArea		:= GetArea()
Local cAliasqry	:= GetNextAlias()
Local aFilLoc	:= {}
Local nX		:= 0

BeginSql Alias cAliasqry
	SELECT
        SB1.B1_COD
	FROM
        %table:SB1% SB1
	WHERE
        SB1.B1_FILIAL = %xfilial:SB1% AND
        SB1.B1_COD BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% AND
        SB1.B1_TIPO BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04% AND
        SB1.%notDel%
	ORDER BY %Order:SB1%
EndSql

dbSelectArea(cAliasqry)
(cAliasqry)->(dbGotop())

Do While (cAliasqry)->(!Eof())
	aFilLoc := M263FilLoc((cAliasqry)->B1_COD)

	For nX := 1 to Len(aFilLoc)
		// Busca PRODUCTO + ID SUNAT
		If aScan(aCodsPrds, {|x| x[1]+x[4] == (cAliasqry)->B1_COD+aFilLoc[nX,4] }) == 0
			RecLock("TRB",.T.)
			TRB->FILIAL		:= aFilLoc[nX,1]
			TRB->EMISSAO	:= MV_PAR06
			TRB->DTDIGIT1	:= MV_PAR06
			TRB->PRODUTO	:= (cAliasqry)->B1_COD
			TRB->NUMDOC		:= "*SINMOV*"
			TRB->XLOCAL		:= aFilLoc[nX,2]
			TRB->XTPESTAB	:= aFilLoc[nX,3]
			TRB->XIDESTAB	:= aFilLoc[nX,4]
			TRB->(MsUnlock())
			Aadd( aCodsPrds, {TRB->PRODUTO,TRB->FILIAL,TRB->XLOCAL,TRB->XIDESTAB} )
		EndIf
	Next nX

	(cAliasqry)->(dbSkip())
Enddo

(cAliasqry)->(dbCloseArea())
RestArea(aArea)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³                     ³ Data ³16.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Arquivo magnético do Registro de Inventário Valorizado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru - Registro de Inventário - Arquivo Magnetico   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir)

Local cLin     := ""
Local cSep     := "|"
Local nCont    := 0
Local cArq     := ""
Local dDtDigit := CTOD("  /  /  ")
Local cExisten := " "
Local nSecNodia		:= 0
Local cNodiaAnt		:= "XX"
Local nCusIni  := 0
Local cCusInic := 0
Local cFilialProd	:= ""
Local cProd	:= ""
Local cEstabProd	:= ""
Local cNodia := ""
Local cNodiaM:= ""
Local cNodia1:= ""
Local cNodia2:= ""
Local nCont1    := 0
Local lSerie2	:= GetNewPar("MV_LSERIE2",.F.)
Local aConSX5 := {}
Local lMTR263CO := If(ExistBlock( "MTR263CO" ), .T.,.F.)
Local lMTR263CM := If(ExistBlock( "MTR263CM" ), .T.,.F.)
Local lTipoRem	:= .F.
Local cTipoOp	:= ""
Local cCodBar	:= ""
Local lMovInv	:= .F.
Local cUniMed	:= ""
Local cCodProd	:= ""
Local cProdSAT	:= ""
Local cCatalogo	:= ""

Private lUsaCodBar  := SuperGetMv("MV_USACBAR" ,.F.,.F.)
Private lUsaTSX5	:= SuperGetMv("MV_USATSX5" ,.F.,.F.)
Private nHdl		:= 0
Private cQuantT		:= 0
Private cQuantTo	:= 0
Private nCustoTo	:= 0
Private nCorr      	:= 0

FOR nCont:=LEN(AllTrim(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1)=='\'
		cDir:=Substr(cDir,1,nCont)
		EXIT
	ENDIF
NEXT

// Nome do arquivo TXT a ser impresso
cArq += "LE"                            // Fixo  'LE'
cArq += AllTrim(SM0->M0_CGC)           // Ruc
cArq += AllTrim(Str(Year(MV_PAR06)))   // Ano
cArq += AllTrim(Strzero(Month(MV_PAR06),2))  // Mes
cArq += "00"                            // Fixo '00'
cArq += "130100"                         // Fixo '130100'
cArq += "00"                             // Fixo '00'
cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao

nHdl := fCreate(cDir+cArq)
If nHdl <= 0
	ApMsgStop(STR0087,"") //"Ha ocurrido un error al generar el archivo, intente nuevamente."
Else

	dbSelectArea("TRB")
	TRB->(dbGoTop())

	Do While TRB->(!EOF())

		cLin:=""

		If TRB->FILIAL <> cFilialProd
			cFilialProd := TRB->FILIAL
	    EndIF

		cProduto := TRB->PRODUTO
		lMovInv	:= !(Alltrim(TRB->NUMDOC) == "*SINMOV*")

		If ((cEstabProd <> TRB->XIDESTAB).Or.(AllTrim(TRB->PRODUTO) <> AllTrim(cProd))) .Or. !lMovInv
			// Cambio de establecimiento / producto, o producto solo con inventario inicial
			fSaldoIni(TRB->PRODUTO,TRB->FILIAL,TRB->XIDESTAB)
			If !lMovInv
				TRB->(DbSkip())
				Loop
			EndIf
			cEstabProd := TRB->XIDESTAB
			cProd := TRB->PRODUTO
		EndIf

		nCusto := 0
		dDtDigit := TRB->DTDIGIT1
		nCusIni  := 0
		cNodia := AllTrim(TRB->NODIA)
		nCont1++
		cNodiaM := "M"+ Strzero(nCont1,9)
		//Mudar o Numero do correlativo
		If lMTR263CO
			cNodia := Execblock('MTR263CO',.F.,.F.,cNodia1)
			cNodia1:= cNodia
		EndIf

		If lMTR263CM
			cNodiaM := Execblock('MTR263CM',.F.,.F.,cNodia2)
			cNodia2 := cNodiaM
		EndIf

		// - 01 Periodo
		cLin += SubStr(DTOS(Emissao),1,6)+"00"
		cLin += cSep

		// - 02 Código Único de la Operación (CUO)
		If lMTR263CO
			cLin +=cNodia
		Else
			If lMovInv
				If empty(TRB->NODIA)
					cLin += "CUO-VACIO"
				Else
					cLin += cNodia
				Endif
			Else
				cLin += "SLDINI"
			EndIf
		EndIf
		cLin += cSep

		// - 03 correlativo
		If lMTR263CM
			If !Empty (AllTrim(cNodiaM))
				cLin +=cNodiaM
			Else
				cLin += ""
			EndIf
		Else
			If !Empty(AllTrim(TRB->XITEM))
				cLin += "M"+StrZero(val(TRB->XITEM),5)
			Else
				If !Empty(AllTrim(TRB->NODIA)) .and. cNodiaAnt <> AllTrim(TRB->NODIA)
					cNodiaAnt := AllTrim(TRB->NODIA)
					nSecNodia := 0
					cLin += "M"+StrZero(++nSecNodia,5)
				ElseIf !Empty (AllTrim(TRB->NODIA)) .and. cNodiaAnt == AllTrim(TRB->NODIA)
					cLin += "M"+StrZero(++nSecNodia,5)
				Else
					cLin += "M"+StrZero(++nInd,5)	// Obligatorio
				Endif
			Endif
		EndIf
		cLin += cSep

		// - 04 Estabelecimento
		cLin += AllTrim(cEstabProd)
		cLin += cSep

		// - 05 Código del catálogo utilizado tabela 13 -  USAR 3(EAN) OU 9(OUTROS)
		cCodProd := Trim(cProduto)
	 	SB1->(DbSetOrder(1))	//B1_FILIAL+B1_COD
	 	If SB1->(MsSeek(xFilial("SB1")+cProduto))
			cCodBar  := StrTran(Trim(SB1->B1_CODBAR),"|","")
			cCodBar	 := StrTran(cCodBar,"/","")
			cProdSAT := Trim(SB1->B1_PRODSAT)
		Else
			cCodBar  := ""
			cProdSAT := ""
		EndIf

		If lUsaCodBar .and. cProdSAT <> "" .And. cProdSAT == cCodProd
			cCatalogo := "1"		// UNSPSC
		ElseIf lUsaCodBar .and. cCodBar <> "" .And. cCodBar == cCodProd
			cCatalogo := "3"		// GTIN
		Else
			cCatalogo := "9"		// otro
		Endif
		cLin += cCatalogo
		cLin += cSep

		// - 06 Tipo de existencia  - tabela 5, Creado en el UPDEST43
		cLin += AllTrim(SB1->B1_TIPOEX)
		cLin += cSeP

		// - 07 Código propio de la existencia correspondiente al catálogo señalado en el campo 5.
		If cCatalogo == "1"
			cLin += cProdSAT
		ElseIf cCatalogo == "3"
			cLin += cCodBar
		Else
			cLin += cCodProd
		EndIf
		cLin += cSep

		// - 08 Código del catálogo utilizado. Versión PLE > 5.1.5.0, aplica anexo_2 vigente a partir de 07/2020
		If lUsaCodBar .and. cProdSAT <> ""
			cCatalogo := "1"		// UNSPSC
		ElseIf lUsaCodBar .and. cCodBar <> ""
			cCatalogo := "3"		// GTIN
		Else
			cCatalogo := ""			// otro (9 no es válido)
		Endif

		If nPLEPeru > 5181
			cLin += cCatalogo
			cLin += cSep
		Endif

		// - 08/09 Código de la existencia, de acuerdo al Catálogo de Bienes, Servicios y Obras (*) - UPDEST43
		IF cCatalogo == "1"
			cLin += Trim(cProdSAT) + IIf( nPLEPeru > 5150, "00000000", "" )
		ElseIf cCatalogo == "3"
			cLin += cCodBar
		Else
			cLin += ""
		Endif
		cLin += cSep

		// - 09 Fecha de emisión del documento de traslado, comprobante de pago, documento interno o similar
		cLin += SubStr(DTOC(Emissao),1,6)+SubStr(DTOS(Emissao),1,4)
		cLin += cSeP

		// - 10 Tipo del documento de traslado, comprobante de pago, documento interno o similar TABELA 10
		lTipoRem := .F.
		If AllTrim(TRB->TIPODOC) $ "NDI/NCC"
          cLin +="07"
        ElseIf AllTrim(TRB->TIPODOC) $ "FT/NF/FAC"
			// ----------------------------------------------------------------------------------- //
			// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
			// Adicionada a serie 12 para series de etiquetadoras								   //
			// ----------------------------------------------------------------------------------- //
			If TRB->TES > "500" // Documentos de Salida
				SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE
				If SFP->( MsSeek( xFilial("SFP")+TRB->FILIAL+TRB->SERIE+"1" ) )
					If Len(Alltrim((SFP->FP_YSERIE))) <= 4
						cLin +="01"
					Else
						cLin +="12"
					EndIf
				Else
					If SFP->( MsSeek( xFilial("SFP")+TRB->FILIAL+TRB->SERIE+"6" ) )
						If Len(Alltrim((SFP->FP_YSERIE))) <= 4
							cLin +="03"
						Else
							cLin +="12"
						EndIf
					Else
						cLin +="01"
					EndIf
				EndIf
			Else
				if alltrim(Posicione("SA2",1,xFilial("SA2")+TRB->CLIFOR+TRB->LOJA,"A2_EST"))=="EX"
					cLin +="91"
				else
					cLin +="01"
				endif
			EndIf
        ElseIf AllTrim(TRB->TIPODOC) $ "RCN/RTS/RTE/RCD/RFN"
          cLin +="09"
          lTipoRem := .T.
        ElseIf AllTrim(TRB->TIPODOC) $ "NDC"
          cLin +="08"
	    Else
		  cLin +="00"
		EndIf
		cLin += cSeP

		// - 11 Número de serie del documento de traslado, comprobante de pago, documento interno o similar
		// ----------------------------------------------------------------------------------- //
		// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
		// ----------------------------------------------------------------------------------- //
		If lMovInv
			// Movimiento de inventario
			_cSerieNf := ""
			If TRB->TES > "500" // Documentos de Salida
				_cSerieNf := M264getSerie2("1/3/4/5/6/7") //Rutina ubicada en PERXTMP
			Else
				_cSerieNf := M264getSerie2("2") //Rutina ubicada en PERXTMP
			EndIf
			If Alltrim(TRB->NUMDOC) $ "INVENT" .AND. Alltrim(TRB->CF) $ "DE0|RE0"
		    	_cSerieNf :=  Alltrim(cSerKINV)
			Elseif Alltrim(TRB->CF) $ "DE0|DE1|DE4|DE6|ER0|PR0|RE0|RE1|RE4|RE6"
				_cSerieNf :=  Alltrim(cSerKTM)
			EndIf
			If Empty(_cSerieNf)
				If lSerie2 .And. !Empty(AllTrim(TRB->SERIE2))
					_cSerieNf := AllTrim(TRB->SERIE2)
				Elseif !Empty(AllTrim(TRB->SERIE))
					_cSerieNf := AllTrim(TRB->SERIE)
				Else
					_cSerieNf := "0000"
				EndIf
			Endif
			if alltrim(Posicione("SA2",1,xFilial("SA2")+TRB->CLIFOR+TRB->LOJA,"A2_EST"))=="EX"
				cLin += "0000"
			else
				If Len(Alltrim(_cSerieNf))==3
					cLin += "0"+_cSerieNf
				Else
					cLin += _cSerieNf
				EndIf
			endif
		Else
			cLin += "0"
		Endif
		cLin += cSeP

		// - 12 Número del documento de traslado, comprobante de pago, documento interno o similar
		If !Empty(AllTrim(TRB->NUMDOC)) .And. lMovInv
			// Movimiento de inventario
			// Modificado por Walmar de Freitas. 26092019: Agregado el filtro de Guias Despacho (091)- Los documentos max son de 08 Caracteres
			If _cSerieNf == "091" .Or. lTipoRem
				// En movimientos de Remisiones, versión PLE <= 5.1.5.0, solo acepta 8 caracteres en número de documento
				// Validar si en versión posterior del PLE ya no tiene esa limitante
				cLin += Right(AllTrim(TRB->NUMDOC),8)
			Else
				cLin += Right(AllTrim(TRB->NUMDOC),20)
			EndIf
		Else
			cLin += "0"
		EndIf
		cLin += cSeP

		// - 13 Tipo de operación efectuada - TABELA 12, Creado en el UPDEST43
		If lMovInv
			// Movimiento de inventario
			cTipoOp := ""
			If AllTrim(TRB->TIPODOC) $ "RE4|DE4"
				cTipoOp := "11"
			ElseIf AllTrim(TRB->TIPODOC) $ "REM|NF|FAC|RCN|RFN"
				aArea := Getarea()
				dbSelectArea("SF4")
				Dbsetorder(1) //F4_FILIAL+F4_CODIGO
				If MsSeek(cFilialProd+TRB->TES)
					cTipoOp := AllTrim(SF4->F4_TPOP)
				ElseIf MsSeek(xFilial("SF4")+TRB->TES)
					cTipoOp := AllTrim(SF4->F4_TPOP)
				EndIf
				RestArea(aArea)
			EndIf
			If Empty(cTipoOp)
				cTipoOp :="99"
			EndIf
		Else
			cTipoOp :="16"
		EndIf
		cLin += cTipoOp
		cLin += cSeP

		// - 14 Descripción de la existencia P7 - Tabela 05 da Existencia, Creado en el UPDEST43
		If lUsaTSX5
			aConSX5 := FWGetSX5( "P7",SB1->B1_TIPOEX,"ES" )
			cExisten := Trim(aConSX5[1,4])
		Else
			cExisten := Trim(Substr(SB1->B1_DESC,1,80))
		EndIf
		cLin += cExisten
		cLin += cSeP

		// - 15 Código Unidade de Medida TABELA 6, Creado en el UPDEST43
		cUniMed := Alltrim(Posicione("SB5",1,xFilial("SB5")+TRB->PRODUTO,"B5_UNSUNAT"))
		If !Empty(cUniMed)
			cLin += cUniMed
		Else
			cLin += alltrim(Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_CODERP"))
		EndIf
		cLin += cSeP

		// - 16 Código del Método de valuación de existencias aplicado - tabela 14
		cLin += AllTrim(STR(VAL(MV_PAR13)))
		cLin += cSeP

		// - 17 Cantidad de unidades físicas del bien ingresado
		If AllTrim(TRB->TES) <= "500" .Or. !lMovInv
			// Movimiento de entrada o saldo inicial
			cLin += AllTrim(StrTran(Transform(TRB->QUANT,"@E 999999999999.99"),",","."))
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 18 Costo unitario del bien ingresado. 1.	Obligatorio si campo 17 <> '0.00' / 2.	Positivo o '0.00'
		If TRB->QUANT != 0 .And. AllTrim(TRB->TES) <= "500" .Or. !lMovInv
			// Movimiento de entrada o saldo inicial
			nCusto := Max(Round(TRB->CUSTOTAL,aTamT[2])/TRB->QUANT, 0)
			cLin += AllTrim(StrTran(Transform(nCusto,"@E 999999999999.99"),",","."))
		ElseIf TRB->QUANT != 0 .And. AllTrim(TRB->TES) > "500"
			nCusto := Max(Round(TRB->CUSTOTAL,aTamT[2])/TRB->QUANT, 0)
			cLin += "0.00"
		Else
			cLin += "0.00"
		EndIf
		cLin += cSeP

		// - 19 Costo total del bien ingresado, 2.	Producto del campo 17 y del campo 18
		If AllTrim(TRB->TES) <= "500" .Or. !lMovInv
			// Movimiento de entrada o saldo inicial
			cLin += AllTrim(StrTran(Transform(TRB->CUSTOTAL,"@E 999999999999.99"),",","."))
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 20 Cantidad de unidades físicas del bien retirado. 2.	Negativo o '0.00' // validar se a TES atualiza estouque ou não
		If AllTrim(TRB->TES) > "500"
			cLin += (AllTrim(StrTran(Transform(TRB->QUANT * -1,"@E 999999999999.99"),",",".")))	//  ==> Salida negativo
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 21 Costo unitario del bien retirado. 1.	Obligatorio si campo 20 <> '0.00'
		If AllTrim(TRB->TES) > "500"
			cLin += AllTrim(StrTran(Transform(nCusto,"@E 999999999999.99"),",","."))
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 22 Costo total del bien retirado. 2.	Producto del campo 20 y del campo 21. 3.	Excepcionalmente puede ser positivo
		If AllTrim(TRB->TES) > "500"
			cLin += AllTrim(StrTran(Transform(TRB->CUSTOTAL * -1,"@E 999999999999.99"),",","."))	//  ==> Salida negativo
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 23 Cantidad de unidades físicas del saldo final. Excepcionalmente puede ser negativo
		If AllTrim(TRB->TES) <= "500" .Or. !lMovInv
			cQuantT  := TRB->QUANT
			cCusInic := 0
			cQuantTo += cQuantT += cCusInic
			nCustoTo += round(TRB->CUSTOTAL,aTamT[2])
			cLin += AllTrim(StrTran(Transform(cQuantTo,"@E 999999999999.99"),",","."))
		Else
			cQuantT  := TRB->QUANT
			cCusInic := 0
			cQuantTo -= cQuantT -= cCusInic
			nCustoTo -= round(TRB->CUSTOTAL,aTamT[2])
			cLin += AllTrim(StrTran(Transform(cQuantTo,"@E 999999999999.99"),",","."))
		EndIf
	 	cLin += cSeP

	 	If cQuantTo == 0
	 		// Cantidad 0, costo total podría ser negativo; informar costo unitario y costo total = 0
	 		nCustoUniT := 0
	 		nCustoTo := 0
	 	Else
	 		nCustoUniT := Max(round(nCustoTo/cQuantTo,aTamT[2]), 0)
	 	EndIf

	 	// - 24 Costo unitario del saldo final. Obligatorio si campo 23 <> '0.00'. Positivo o '0.00'
		cLin += AllTrim(StrTran(Transform( round(nCustoUniT,aTamT[2]),"@E 999999999999.99"),",","."))
	 	cLin += cSeP

	 	// - 25 Costo total del saldo final. Producto del campo 23 y del campo 24. Excepcionalmente puede ser negativo
	 	cLin += AllTrim(StrTran(Transform(nCustoTo,"@E 999999999999.99"),",","."))
	 	cLin += cSeP

		// - 26 Indica el estado de la operación
		//	'1' cuando la operación corresponde al periodo Registrar
		//	'8' cuando la operación corresponde a un periodo anterior y NO ha sido anotada en dicho periodo
		//	'9' cuando la operación corresponde a un periodo anterior y SI ha sido anotada en dicho periodo."
		If dDtDigit >= MV_PAR05 .And. dDtDigit <= MV_PAR06
			cLin += "1"
		Else
			cLin += "8"
		EndIf
		cLin += cSeP

		cLin += chr(13)+chr(10) // QUEBRA LINHA

		fWrite(nHdl,cLin)
		TRB->(DbSkip())

		cCusInic := 0
		If AllTrim(TRB->PRODUTO) <> AllTrim(cProduto)// Zera totalizadores do Custo Total
			cQuantT := 0
			cQuantTo:= 0
			nCustoTo := 0
		EndIf

	EndDo

	fClose(nHdl)
	MsgInfo(STR0080, STR0088) //"El archivo de texto, se ha generado correctamente." - "Generación de Archivo Magnético"
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZMATR263  ºAutor  ³Microsiga           ºFecha ³  12/16/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fSaldoIni(cCodProd,cCodeSuc,cEstmento)

	Local aAreaSb9	:= GetArea()
	Local cLin		:= ""
	Local cSep		:= "|"
	Local nX		:= 0
	Local aConSX5	:= {}
	Local cTexSB1	:= ""
	Local cPrdSAT	:= ""
	Local cDesSB1	:= ""
	Local cUMSB1	:= ""
	Local cCodBar	:= ""
	Local cUniMed	:= ""
	Local cCatalogo	:= ""

	cQuantTo := 0
	nCustoTo := 0

	aLocalFiR := M263LocFil(mv_par07,cCodeSuc,cCodProd,cEstmento) //Rutina ubicada en PERXTMP
	aSalAtu	:= {0, 0, 0, 0, 0, 0, 0}
	nQtini	:= 0
	nSalIni	:= 0

	For nX := 1 To Len(aLocalFiR)
		If aLocalFiR[nX,1] .And. (aLocalFiR[nX,2] <> cLocalTrans .Or. cEstmento == cEstabTrans)
			aSalAtu1 := M264fCalcEst(cCodProd,aLocalFiR[nX,2],MV_PAR05,cCodeSuc) ////Rutina ubicada en PERXTMP
			nQtIni	+= aSalAtu1[1]           // QUANTIDADE
			nSalIni	+= aSalAtu1[MV_PAR10+1]  // VALOR
		EndIf
	Next nX

	aSalAtu[1]          += nQtIni
	aSalAtu[mv_par10+1] += nSalIni

	If nQtIni > 0
		cLin:=""

		nCusto := 0
		nCusIni  := nSalIni

		// - 01 Periodo
		cLin += SubStr(DTOS(MV_PAR05),1,6)+"00"
		cLin += cSep

		// - 02 Código Único de la Operación (CUO)
		cLin += "SLDINI"
		cLin += cSeP

		// - 03 correlativo
		cLin += "M"+StrZero(++nInd,5)
		cLin += cSeP

		// - 04 Estabelecimento
		cLin += AllTrim(cEstmento)
		cLin += cSep

		// - 05 Código del catálogo utilizado tabela 13 -  USAR 3(EAN) OU 9(OUTROS)
		cCodBar	:= ''
		cTexSB1	:= ''
		cPrdSAT	:= ''
		cDesSB1	:= ''
		cUMSB1	:= ''
		SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
		IF SB1->(MsSeek(xFilial("SB1") + cCodProd))
			cCodBar := StrTran(Trim(SB1->B1_CODBAR),"|","")
			cCodBar	:= StrTran(cCodBar,"/","")
			cTexSB1 := SB1->B1_TIPOEX
			cDesSB1 := SB1->B1_DESC
			cUMSB1  := SB1->B1_UM
			cPrdSAT := Trim(SB1->B1_PRODSAT)
		ENDIF

		If lUsaCodBar .and. cPrdSAT <> "" .And. cPrdSAT == Trim(cCodProd)
			cCatalogo := "1"		// UNSPSC
		ElseIf lUsaCodBar .and. cCodBar <> "" .And. cCodBar == Trim(cCodProd)
			cCatalogo := "3"		// GTIN
		Else
			cCatalogo := "9"		// otro
		Endif
		cLin += cCatalogo
		cLin += cSep

		// - 06 Tipo de existencia  - tabela 5, Creado en el UPDEST43
		cLin += AllTrim(cTexSB1)
		cLin += cSeP

		// - 07 Código propio de la existencia correspondiente al catálogo señalado en el campo 5.
		If cCatalogo == "1"
			cLin += cPrdSAT
		ElseIf cCatalogo == "3"
			cLin += cCodBar
		Else
			cLin += Trim(cCodProd)
		EndIf
		cLin += cSep

		// - 08 Código del catálogo utilizado. Versión PLE > 5.1.5.0, aplica anexo_2 vigente a partir de 07/2020
		If nPLEPeru > 5181
			If lUsaCodBar .and. !(cCatalogo == "9")
				cLin += cCatalogo
			Else					// opcional
				cLin += ""
			EndIf
			cLin += cSep
		Endif

		// - 08/09 Código de la existencia, de acuerdo al Catálogo de Bienes, Servicios y Obras (*) - UPDEST43
		If cCatalogo == "1"
			cLin += Trim(cPrdSAT) + IIf( nPLEPeru > 5150, "00000000", "" )
		ElseIf cCatalogo == "3"
			cLin += cCodBar
		Else
			cLin += ""
		Endif
		cLin += cSep

		// - 09 Fecha de emisión del documento de traslado, comprobante de pago, documento interno o similar
		cLin += SubStr(DTOC(MV_PAR05),1,6)+SubStr(DTOS(MV_PAR05),1,4)
		cLin += cSeP

		// - 10 Tipo del documento de traslado, comprobante de pago, documento interno o similar TABELA 10
		cLin +="00"
		cLin += cSeP

		// - 11 Número de serie del documento de traslado, comprobante de pago, documento interno o similar
		cLin += "0"
		cLin += cSeP

		// - 12 Número del documento de traslado, comprobante de pago, documento interno o similar
		cLin += "0"
		cLin += cSeP

		// - 13 Tipo de operación efectuada - TABELA 12, Creado en el UPDEST43
		cLin +="16"
		cLin += cSeP

		// - 14 Descripción de la existencia P7 - Tabela 05 da Existencia, Creado en el UPDEST43
		If lusaTSX5
			aConSX5 := FWGetSX5( "P7",cTexSB1,"ES" )
			cExisten := aConSX5[1,4]
		Else
			cExisten := SUBSTR(cDesSB1,1,80)
		EndIf
		cLin += cExisten
		cLin += cSeP

		// - 15 Código Unidade de Medida TABELA 6, Creado en el UPDEST43
		cUniMed := Alltrim(Posicione("SB5",1,xFilial("SB5")+cCodProd,"B5_UNSUNAT"))
		If !Empty(cUniMed)
			cLin += cUniMed
		Else
			cLin += alltrim(Posicione("SAH",1,xFilial("SAH")+cUMSB1,"AH_CODERP"))
		EndIf
		cLin += cSeP

		// - 16 Código del Método de valuación de existencias aplicado - tabela 14
		cLin += AllTrim(STR(VAL(MV_PAR13)))
		cLin += cSeP

		// - 17 Cantidad de unidades físicas del bien ingresado
		If nQtIni <> 0
			cLin += AllTrim(StrTran(Transform(nQtIni,"@E 999999999999.99"),",","."))
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 18 Costo unitario del bien ingresado. 1.	Obligatorio si campo 17 <> '0.00' / 2.	Positivo o '0.00'
		If nQtIni != 0
			nCusto := Max( round(Round(nSalIni,aTamT[2])/nQtIni,aTamT[2]) , 0 )
			cLin += AllTrim(StrTran(Transform(nCusto,"@E 99999999.99"),",","."))
		Else
			cLin += "0.00"
		EndIf
		cLin += cSeP

		// - 19 Costo total del bien ingresado, 2.	Producto del campo 17 y del campo 18
		If nQtIni != 0
			cLin += AllTrim(StrTran(Transform(nSalIni,"@E 99999999.99"),",","."))
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 20 Cantidad de unidades físicas del bien retirado. 2.	Negativo o '0.00' // validar se a TES atualiza estouque ou não
		cLin += "0.00"
		cLin += cSeP

		// - 21 Costo unitario del bien retirado. 1.	Obligatorio si campo 20 <> '0.00'
		cLin += "0.00"
		cLin += cSeP

		// - 22 Costo total del bien retirado. 2.	Producto del campo 20 y del campo 21. 3.	Excepcionalmente puede ser positivo
		cLin += "0.00"
		cLin += cSeP

		// - 23 Cantidad de unidades físicas del saldo final. Excepcionalmente puede ser negativo
		cQuantT  := round(nQtIni,aTamT[2])
		cCusInic := round(nSalIni,aTamT[2])
		cQuantTo += cQuantT
		nCustoTo += cCusInic
		cLin += AllTrim(StrTran(Transform(cQuantTo,"@E 999999999999.99"),",","."))
		cLin += cSeP

		// - 24 Costo unitario del saldo final. Obligatorio si campo 23 <> '0.00' . Positivo o '0.00'
		nCustoUniT := Max( round(round(nCustoTo,aTamT[2])/cQuantTo,aTamT[2]) , 0 )
		cLin += AllTrim(StrTran(Transform( nCustoUniT,"@E 99999999.99"),",","."))
		cLin += cSeP

		// - 25 Costo total del saldo final. Producto del campo 23 y del campo 24. Excepcionalmente puede ser negativo
		cLin += AllTrim(StrTran(Transform(nCustoTo,"@E 99999999.99"),",","."))
		cLin += cSeP

		// - 26 Indica el estado de la operación
		//	'1' cuando la operación corresponde al periodo Registrar
		//	'8' cuando la operación corresponde a un periodo anterior y NO ha sido anotada en dicho periodo
		//	'9' cuando la operación corresponde a un periodo anterior y SI ha sido anotada en dicho periodo."
		cLin += "1"
		cLin += cSeP
		cLin += chr(13)+chr(10) // QUEBRA LINHA

		fWrite(nHdl,cLin)
	EndIf

    RestArea(aAreaSb9)

Return

/*/{Protheus.doc} M263FilLoc
//Determina productos por sucursal-establecimiento (almacen).
@author arodriguez
@since 08/06/2020
@version 1.0
@return aFilLoc, arrary, sucursales-establecimiento
@param cCod, characters, código producto
/*/
Static Function M263FilLoc(cCod)
Local aArea		:= GetArea()
Local cAliasqry	:= GetNextAlias()
Local aFilLoc	:= {}
Local cExpFil	:= "% SB9.B9_FILIAL " + cMVPar15 + " %"
Local cExpLoc	:= "% SB9.B9_LOCAL IN " + MV_PAR07 + " %"
Local cFechaBco := Space(8)
Local cFechaIni	:= DtoS(MV_PAR05-1)

BeginSql Alias cAliasqry
	SELECT
		B9_FILIAL, B9_COD, B9_LOCAL, NNR_TIPOES, NNR_IDSUNA
	FROM
        %table:SB9% SB9
	INNER JOIN
	    %table:NNR% NNR
	ON
		B9_LOCAL = NNR_CODIGO
	WHERE
        %Exp:cExpFil% AND
        %Exp:cExpLoc% AND
        SB9.B9_COD = %exp:cCod% AND
        (SB9.B9_DATA = %exp:cFechaIni% OR SB9.B9_DATA = %exp:cFechaBco%) AND
        SB9.B9_QINI > 0 AND
        SB9.%notDel% AND
        NNR.%notDel%
EndSql

dbSelectArea(cAliasqry)
(cAliasqry)->(dbGotop())

Do While (cAliasqry)->(!Eof())
	aAdd( aFilLoc , {(cAliasqry)->B9_FILIAL, (cAliasqry)->B9_LOCAL, (cAliasqry)->NNR_TIPOES, (cAliasqry)->NNR_IDSUNA} )
	(cAliasqry)->(dbSkip())
Enddo

(cAliasqry)->(dbCloseArea())
RestArea(aArea)

Return aFilLoc
