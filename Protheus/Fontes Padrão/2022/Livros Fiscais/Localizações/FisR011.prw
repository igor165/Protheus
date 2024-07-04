#INCLUDE 'PROTHEUS.CH'
#Include "TopConn.ch"
#INCLUDE 'FISR011.CH'

Static cStartPath   := AllTrim(GetPvProfString(GetEnvServer(), 'StartPath', 'ERROR', GetADV97()) + If(Right(AllTrim(GetPvProfString(GetEnvServer(), 'StartPath', 'ERROR', GetADV97())), 1) == '\', '', '\'))
Static cPath        := If(Left(cStartPath, 1) <> '\', '\', '') + cStartPath

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FisR011   º Autor ³ Rodrigo M. Pontes  º Data ³  14/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatorio de impressão dos livros fiscais do Peru           º±±
±±º          ³Relatorio de registro de vendas e ingressos                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³gSantacruz  ³16/12/19³DMINA-7922³Modificaciones enviadas por Percy:    ³±±
±±³            ³        ³          ³Optimizacion de performance y pruebas ³±±
±±³            ³        ³          ³finales con RSM.                      ³±±
±±³Marco A. Glz³05/09/20³DMINA-9972³Se corrige error log al poner .F. en  ³±±
±±³            ³        ³          ³el parametro MV_LSERIE2, se corrige   ³±±
±±³            ³        ³          ³impresion de columna Tipo en informe y³±±
±±³            ³        ³          ³se aplicanbuenas practicas. (PER)     ³±±
±±³Marco A. Glz³21/09/20³DMINA-    ³Se modifica impresion de columna 6, la³±±
±±³            ³        ³     10122³cual se tomara del campo F2_TPDOC.    ³±±
±±³Eduardo Prz ³15/10/20³DMINA-    ³Se modifica la consulta sql para que  ³±±
±±³            ³        ³     10328³considere los registros de cliente ext³±±
±±³            ³        ³          ³para los campos F3_BASIMP1|F3_BASIMP2 ³±±
±±³            ³        ³          ³y se impriman en la columna 14        ³±±
±±³Oscar G.    ³09/12/20³DMINA-    ³Se ajusta impresion Opc. Planilla para³±±
±±³            ³        ³     10603³NCC muestre valor negativo, se ajusta ³±±
±±³            ³        ³          ³impresion de Archivo y Planilla.      ³±±
±±³ARodriguez  ³20/12/20³DMINA-    ³Incluir columna de ICBPER             ³±±
±±³            ³        ³     10545³                                      ³±±
±±³Oscar G.    ³22/07/21³DMINA-    ³Se ajusta func ReportDef y ReportPrint³±±
±±³            ³        ³     12762³para uso de secciones en impresion, en³±±
±±³            ³        ³          ³lugar de imprimir por coordenadas.    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISR011(nOpc)

Local uRet

Private oTmpTable 	:= Nil //Se utiliza en la función FISR011CT para creación de tabla temporal
Private lDev4		:= .F. //Impresion mediante opcion 4 - Planilla
Private lDev6		:= .F. //Impresion mediante opcion 6 - PDF
Private nColICB     := 4760 //Columna de impresión ICB
Private nColFin		:= 4950	//Columna final

default nOpc := 0

Do case
	case nOpc == 0
		uRet := execRel()
	case nOpc == 1
		uRet := f3Param()
	case nOpc == 2
		uRet := f3RetParam()
EndCase

Return uRet

/*/{Protheus.doc} execRel
Funcao para executar o relatorio
@type  Static Function
@author DS2U (SDA)
@since 14/09/2019
@version version
/*/
Static Function execRel()

	Local oReport
	Local aArea := GetArea()

	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef ³ Autor ³ Rodrigo M. Pontes     ³ Data | 30/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criação do objeto TReport para a impressão do relatorio.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport	:= NIL
Local oSection1	:= NIL
Local cPerg		:= 'FISR011'
Local cNomProg	:= 'FISR011'
Local cTitulo	:= STR0001	//-- Registros de Vendas e Ingressos
Local cDesc		:= STR0002	//-- Relatorio de registros de Vendas e Ingressos
Local cPict		:= "@E 999,999,999.99"

// -------------------------------------------------------------------------------
// PARAMETROS
// -------------------------------------------------------------------------------
// MV_PAR01 : DATA INICIAL
// MV_PAR02 : DATA FINAL
// MV_PAR03 : IMPRIME PAGINAS (1-SIM | 2-NAO)
// MV_PAR04 : No PAGINA INICIAL
// MV_PAR05 : SELECIONA FILIAIS (1-SIM | 2-NAO)
// MV_PAR06 : GERA RELATORIO, ARQUIVO OU AMBOS (1-RELATORIO | 2-ARQUIVO)
// MV_PAR07 : DIRETORIO P/ GERACAO DO ARQUIVO
// -------------------------------------------------------------------------------

Pergunte(cPerg, .T.)

// ---------------------------------------------------
// CRIA OBJETO TREPORT
// ---------------------------------------------------
oReport := TReport():New(cNomProg, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDesc)

oReport:SetLandscape()				//-- Formato paisagem
oReport:oPage:nPaperSize := 8		//-- Impressão em papel A3
oReport:lHeaderVisible   := .F.		//-- Nao imprime cabeçalho do protheus
oReport:lFooterVisible   := .F.		//-- Nao imprime rodapé do protheus
oReport:lParamPage       := .F.		//-- Nao imprime pagina de parametros
oReport:SetTotalPageBreak(.T.)
oReport:SetColSpace(0)

oSection1 := TRSection():New( oReport, "",,,,,,,,,,,,,0,.F.)

oSection1:SetTotalInLine(.F.)
oSection1:SetTotalText(STR0006) //"Totales:"

TRCell():New( oSection1, "CCORRELA"		,, STR0011+CRLF+STR0022+CRLF+STR0033+CRLF+STR0045+CRLF+STR0056	,/*Picture*/,15,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Numero"#"correlativo"#"del registro o"#"codigo unico"#"de la operacion "
TRCell():New( oSection1, "DEMISSAO"		,, STR0012+CRLF+STR0023+CRLF+STR0034+CRLF+STR0046+CRLF+STR0025	,/*Picture*/,12,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"De fecha"#"emisión del "#"comprobante"#"de pago"#"o doc.  "
TRCell():New( oSection1, "DVENCTORE"	,, STR0013+CRLF+STR0024+CRLF+STR0035+CRLF+STR0047				,/*Picture*/,12,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Fecha "#"de"#"vencimiento "#"y/o pago"
TRCell():New( oSection1, "CTPDOC"		,, CRLF+CRLF+CRLF+CRLF+STR0031									,/*Picture*/, 6,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Tipo"
TRCell():New( oSection1, "CSERIENF"		,, CRLF+CRLF+STR0036+CRLF+STR0048+CRLF+STR0057					,/*Picture*/,22,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Nºserie o"#"Nº de serie de la   "#"maquina registradora"
TRCell():New( oSection1, "CNFISCAL"		,, CRLF+CRLF+CRLF+CRLF+STR0011									,/*Picture*/,15,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Numero"
TRCell():New( oSection1, "CTIPODOC"		,, CRLF+CRLF+CRLF+CRLF+STR0031									,/*Picture*/, 5,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Tipo"
TRCell():New( oSection1, "CCGC"			,, CRLF+CRLF+CRLF+CRLF+STR0011									,/*Picture*/,18,, ,"CENTER"	, .T.,"CENTER",,0,.F.) //"Numero"
TRCell():New( oSection1, "CNOME"		,, CRLF+CRLF+STR0038+CRLF+STR0049+CRLF+STR0058					,/*Picture*/,41,, ,"LEFT"	, .T.,"CENTER",,0,.F.) //"Apellidos y nombres, "#"denominacion "#"o razon social"
TRCell():New( oSection1, "VALNFEXP"		,, CRLF+STR0016+CRLF+STR0026+CRLF+STR0039+CRLF+STR0050			,cPict		,15,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Valor"#"Facturado "#"de la   "#"exportacion "
TRCell():New( oSection1, "BASEIMPO"		,, STR0017+CRLF+STR0027+CRLF+STR0039+CRLF+STR0051+CRLF+STR0059	,cPict		,14,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Base"#"Imponible  "#"de la   "#"Operacion "#"Gravada"
TRCell():New( oSection1, "IMPTOTEXO"	,, CRLF+CRLF+CRLF+CRLF+STR0052									,cPict		,15,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Exonerada   "
TRCell():New( oSection1, "IMPTOTINA"	,, CRLF+CRLF+CRLF+CRLF+STR0053									,cPict		,15,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Inafecta"
TRCell():New( oSection1, "ISC"			,, CRLF+CRLF+CRLF+CRLF+STR0040									,cPict		,15,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"ISC"
TRCell():New( oSection1, "IGVIPM"		,, CRLF+CRLF+CRLF+CRLF+STR0041									,cPict		,15,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"IGV y/o IPM"
TRCell():New( oSection1, "OTROSTRIB"	,, STR0019+CRLF+STR0029+CRLF+STR0042+CRLF+STR0039+CRLF+STR0060	,cPict		,17,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Otros tributos"#"y cargos que"#"no forman parte"#"de la   "#"base imponible  "
TRCell():New( oSection1, "IMPCOMPPAG"	,, STR0020+CRLF+STR0030+CRLF+STR0043+CRLF+STR0034+CRLF+STR0046	,cPict		,17,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Importe"#"Total"#"del "#"comprobante"#"de pago"
TRCell():New( oSection1, "TPCAMBIO"		,, CRLF+CRLF+STR0031+CRLF+STR0024+CRLF+STR0054					,cPict		,13,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Tipo"#"de"#"cambio"
TRCell():New( oSection1, "FCHRCOMPGO"	,, CRLF+CRLF+CRLF+CRLF+STR0013									,/*Picture*/,12,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Fecha "
TRCell():New( oSection1, "TIPRCOMPGO"	,, CRLF+CRLF+CRLF+CRLF+STR0031									,/*Picture*/, 5,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Tipo"
TRCell():New( oSection1, "SERRCOMPGO"	,, CRLF+CRLF+CRLF+CRLF+STR0055									,/*Picture*/, 7,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Serie"
TRCell():New( oSection1, "NUMRCOMPGO"	,, CRLF+CRLF+STR0044+CRLF+STR0034+CRLF+STR0061					,/*Picture*/,15,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"Nº del "#"comprobante"#"de pago o docto.  "
TRCell():New( oSection1, "VALICB"		,, CRLF+CRLF+CRLF+CRLF+STR0077									,cPict		,15,, ,"RIGHT"	, .T.,"CENTER",,0,.F.) //"ICBPER"

BordCel(@oSection1)

TRFunction():New(oSection1:Cell("VALNFEXP")		,NIL, "SUM", /*oBreak*/, "", cPict	, /*uFormula*/, .T., .F.)
TRFunction():New(oSection1:Cell("BASEIMPO")		,NIL, "SUM", /*oBreak*/, "", cPict  , /*uFormula*/, .T., .F.)
TRFunction():New(oSection1:Cell("IMPTOTEXO")	,NIL, "SUM", /*oBreak*/, "", cPict  , /*uFormula*/, .T., .F.)
TRFunction():New(oSection1:Cell("IMPTOTINA")	,NIL, "SUM", /*oBreak*/, "", cPict   , /*uFormula*/, .T., .F.)
TRFunction():New(oSection1:Cell("ISC")			,NIL, "SUM", /*oBreak*/, "", cPict   , /*uFormula*/, .T., .F.)
TRFunction():New(oSection1:Cell("IGVIPM")		,NIL, "SUM", /*oBreak*/, "", cPict   , /*uFormula*/, .T., .F.)
TRFunction():New(oSection1:Cell("OTROSTRIB")	,NIL, "SUM", /*oBreak*/, "", cPict   , /*uFormula*/, .T., .F.)
TRFunction():New(oSection1:Cell("IMPCOMPPAG")	,NIL, "SUM", /*oBreak*/, "", cPict   , /*uFormula*/, .T., .F.)
TRFunction():New(oSection1:Cell("VALICB")		,NIL, "SUM", /*oBreak*/, "", cPict   , /*uFormula*/, .T., .F.)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportPrint³ Autor ³ V. RASPA                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Trata impressao e/ou geracao do arquivo txt                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)
Local aParams	:= {}
Local aFiliais	:= {}

Private nPLEPeru	:= SuperGetMv("MV_PLEPERU", .F., 5150)		// Número de versión del PLE, v5.1.5.0 vigente hasta Jun/2020, v5.1.8.1 vigente hasta Dic/2020
Private lICBPER		:= (SFB->(ColumnPos("FB_VALIMPU")) > 0)		// Usa impuesto al consumo de bolsas de plástico
Private cAliasPer	:= ""

lDev4 := (oReport:nDevice == 4)
lDev6 := (oReport:nDevice == 6)

// -------------------------------------------------
// GUARDA PARAMETROS INFORMADOS (DEVIDO MULTI-THREAD
// -------------------------------------------------
aAdd(aParams, MV_PAR01) //-- MV_PAR01 : DATA INICIAL
aAdd(aParams, MV_PAR02) //-- MV_PAR02 : DATA FINAL
aAdd(aParams, MV_PAR03) //-- MV_PAR03 : IMPRIME PAGINAS (1-SIM | 2-NAO)
aAdd(aParams, MV_PAR04) //-- MV_PAR04 : No PAGINA INICIAL
aAdd(aParams, MV_PAR05) //-- MV_PAR05 : SELECIONA FILIAIS (1-SIM | 2-NAO)
aAdd(aParams, MV_PAR06) //-- MV_PAR06 : GERA RELATORIO, ARQUIVO OU AMBOS (1-RELATORIO | 2-ARQUIVO )
aAdd(aParams, MV_PAR07) //-- MV_PAR07 : DIRETORIO P/ GERACAO DO ARQUIVO

// -----------------------------------------
// VERIFICA FILIAIS SELECIONADAS
// -----------------------------------------
aFiliais := MatFilCalc(MV_PAR05 == 1)	//-- Seleciona Filiais

// ------------------------------------------------
// PROCESSO DE IMPRESSAO E/OU GERACAO ARQUIVO TEXTO
// ------------------------------------------------
If aParams[6] == 1
	//-- REALIZA IMPRESSAO DO RELATORIO...
	FImpLivFis(oReport, aFiliais, aParams)
EndIf

If aParams[6] == 2
	Processa({|lEnd| FSR11GerArq(aFiliais, aParams, @lEnd)},, STR0063, .T.)
	MsgInfo(STR0064 + STR0070 + AllTrim(aParams[7]) + If(Right(AllTrim(aParams[7]), 1) == '\', '', '\'),"") //"!Archivo texto generado on exito!"' -  Directorio: '
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FImpLivFis³ Autor ³ Rodrigo M. Pontes     ³ Data | 30/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressão do relatorio.								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FImpLivFis(oReport, aFiliais, aParams)

Local nlExpo       := 0	//-- Total de exportação
Local nlBase       := 0	//-- Total de base do imposto
Local nlExon       := 0	//-- Total (isento do IGV e Exonerada)
Local nlInaf       := 0	//-- Total (isento do IGV e Inafecta)
Local nlIsc        := 0	//-- Total do Valor de ISC
Local nlIgv        := 0	//-- Total do Valor de IGV
Local nlTrib       := 0	//-- Total outros tributados
Local nlValC       := 0	//-- Total do Valor total do documento
Local nLinP        := 0	//-- Linha de impressão do total parcial
Local nlExpoPar    := 0	//-- Total parcial de exportação
Local nlBasePar    := 0	//-- Total parcial de base do imposto
Local nlExonPar    := 0	//-- Total parcial (isento do IGV e Exonerada)
Local nlInafPar    := 0	//-- Total parcial (isento do IGV e Inafecta)
Local nlOtrTrib    := 0	//-- Total parcial (isento do IGV e outros tributados)
Local nlIscPar     := 0	//-- Total parcial do Valor de ISC
Local nlIgvPar     := 0	//-- Total parcial do Valor de IGV
Local nlTribPar    := 0	//-- Total parcial outros tributados
Local nlValCPar    := 0	//-- Total parcial do Valor total do documento
Local nlF3Base     := 0	//-- Recebe o valor da base imponible
Local nTributo     := 0
Local nReg         := 0	//-- Contador de registros
Local nlTotReg     := 0	//-- Total de registros
Local nlTotRel     := 0	//-- Total geral de registros
Local nlTotPag     := 77	//-- 80
Local nCol         := 0
Local cTpDoc       := ""
Local lNotOri		:= .F.
Local nSinal		:= 1
Local cCorrela		:= ""
Local lImpri		:= .T.
Local nValcont		:= 0
Local cTipoDoc_Anu	:= ''
Local cAliasTrib	:= ''
Local lCpDoc		:= SF3->(ColumnPos("F3_TPDOC")) > 0
Local lSer3			:= SFP->(ColumnPos("FP_YSERIE")) > 0 //-- Impresion de la serie 2 (factura electrocnica - Peru)
Local lSerie2		:= SF1->(ColumnPos("F1_SERIE2")) > 0 .And. SF2->(ColumnPos("F2_SERIE2")) > 0 .And. SF3->(ColumnPos("F3_SERIE2")) > 0 .And. GetNewPar("MV_LSERIE2", .F.)
Local lSerOri		:= SF1->(ColumnPos("F1_SERORI")) > 0 .And. SF2->(ColumnPos("F2_SERORI")) > 0 .And. SF3->(ColumnPos("F3_SERORI")) > 0
Local lSerie2SFP	:= SFP->(ColumnPos("FP_SERIE2")) > 0
Local cFilSFP		:= xFilial("SFP")
Local nCount		:= 0
Local nNCExp		:= 1
Local nNCIna		:= 1
Local nValICB       := 0
Local nlICB         := 0
Local nlICBPar      := 0
Local nColAnt       := 0
Local nColTip		:= 0
Local lRComp		:= .F.
Local oSection1		:= oReport:Section(1)
Local nImpComPag	:= 0
Local nValNFExp		:= 0
Local nImpTotExo	:= 0
Local nImpTotIna	:= 0
Local nISC			:= 0
Local nIGVIPM		:= 0
Local nOtrTrib      := 0

// -----------------------------------------
// PROCESSA A QUERY PRINCIPAL
// -----------------------------------------
cAliasPer  := FISR011Qry(aFiliais, aParams)

// ---------------------------------------------
// PROCESSA ARQUIVO TEMPORARIO - OUTROS TRIBUTOS
// ---------------------------------------------
cAliasTrib := FISR011Trib(aFiliais, aParams)
If lDev4
	TitCelda(oSection1)
EndIf
// -------------------------------------------
// INICIA PROCESSO DE IMPRESSAO
// -------------------------------------------
If (cAliasPer)->(!EOF())
	oReport:SetPageNumber(aParams[4])
	FCabR011(oReport,nCol,,,,,,,,,, aParams)
	(cAliasPer)->(DBEval({|| nReg++}, {|| .T.}, {|| !Eof()}))
Endif
(cAliasPer)->(dbGoTop())
oReport:SetMeter(nReg)

While (cAliasPer)->(!Eof())
	//-- Trata eventual cancelamento da impressao...
	If oReport:Cancel()
		Exit
	EndIf

	If	lImpri
		nlTotRel++
	 	lImpri:=.F.
	EndIf

	cCorrela := (cAliasPer)->F2_NODIA
	If Empty((cAliasPer)->F2_NODIA)
		cCorrela := BuscaCorre((cAliasPer)->F3_FILIAL, (cAliasPer)->F3_NFISCAL, (cAliasPer)->F3_SERIE, (cAliasPer)->F3_CLIEFOR, (cAliasPer)->F3_LOJA, (cAliasPer)->F3_EMISSAO,(cAliasPer)->F3_ESPECIE)
	EndIf
	nSinal       := If(("NC" $ (cAliasPer)->F3_ESPECIE .OR. (cAliasPer)->CCL_CODGOV == '25'), -1, 1)
	cFil         := (cAliasPer)->F3_FILIAL
	cNFiscal     := (cAliasPer)->F3_NFISCAL
	cSerie       := (cAliasPer)->F3_SERIE
	cClifor      := (cAliasPer)->F3_CLIEFOR
	cLoja        := (cAliasPer)->F3_LOJA
	cEspecie     := (cAliasPer)->F3_ESPECIE
	cNome        := (cAliasPer)->A1_NOME
	cCGC         := (cAliasPer)->A1_CGC
	cPessFis     := (cAliasPer)->A1_PFISICA
	cTipoDoc     := (cAliasPer)->A1_TIPDOC
	cCodGov      := (cAliasPer)->CCL_CODGOV
	dEmissao     := (cAliasPer)->F3_EMISSAO

	If AllTrim(cCGC) <> 'Anulado'
		cTipoDoc_Anu := cCodGov
	Else
		cTipoDoc_Anu := If(lCpDoc, (cAliasPer)->F3_TPDOC, '')
	EndIf

	If AllTrim(cCGC) <> 'Anulado'
		nValcont1 := (cAliasPer)->F3_VALCONT - ((cAliasPer)->(EXONERADA + F3_BASIMP1 + F3_BASIMP2 + F3_VALIMP2 + F3_VALIMP1 + EXPORTACAO + INAFECTA))
		nTxMoeda  := (cAliasPer)->F2_TXMOEDA
		nExporta  := (cAliasPer)->EXPORTACAO
		nExonera  := (cAliasPer)->EXONERADA
		nInafecta := (cAliasPer)->INAFECTA
		nOtrTrib  := (cAliasPer)->OTROSTRIB
		nValimp2  := (cAliasPer)->F3_VALIMP2
		nValimp1  := (cAliasPer)->F3_VALIMP1
		nBase1    := (cAliasPer)->F3_BASIMP1
		nBase2    := (cAliasPer)->F3_BASIMP2
		nValICB   := (cAliasPer)->F3_VALICB
		nValcont  := 0

	Else
		nValcont  := 0
		nTxMoeda  := 0
		nExporta  := 0
		nExonera  := 0
		nInafecta := 0
		nOtrTrib  := 0
		nValimp2  := 0
		nValimp1  := 0
		nBase1    := 0
		nBase2    := 0
		nValICB   := 0

	EndIf

	dVenctoRe := (cAliasPer)->E1_VENCTO
	cSer2     := If(lSerie2, (cAliasPer)->F3_SERIE2, '')
	cSerOri   := If(lSerOri, (cAliasPer)->F3_SERORI, '')

	lImprime:=.T.
	If (cAliasPer)->(Eof())
		lImprime:=.F.
	EndIf

	(cAliasPer)->(DbSkip())
	nCount++


	If (cAliasPer)->(!Eof())
		nlTotRel++
	EndIf

	If nBase1 > 0 .And. nBase2 = 0
		nlBasePar += nBase1 * nSinal //Total parcial
		nlBase    += nBase1 * nSinal //Total geral
		nlF3Base  := nBase1 * nSinal //Campo para a impressão

	Elseif nBase1 = 0 .And. nBase2 > 0
		nlBasePar += nBase2 * nSinal //Total parcial
		nlBase    += nBase2 * nSinal //Total geral
		nlF3Base  := nBase2 * nSinal //Campo para a impressão

	Elseif nBase1 > 0 .And. nBase2 > 0
		nlBasePar += (nBase1 - nBase2) * nSinal //Total parcial
		nlBase    += (nBase1 - nBase2) * nSinal //Total geral
		nlF3Base  := (nBase1 - nBase2) * nSinal //Campo para a impressão

	Else
		nlBasePar += 0
		nlBase    += 0
		nlF3Base  := 0

	Endif

	If AllTrim(cCGC) <> 'Anulado'
		nlExpoPar += nExporta * nSinal //Total parcial
		nlExpo    += nExporta * nSinal //Total geral
		nlExonPar += nExonera * nSinal //Total parcial
		nlExon    += nExonera * nSinal//Total geral

		nlInafPar += nInafecta * nSinal //Total parcial
		nlInaf    += nInafecta * nSinal //Total geral

		nlOtrTrib += nOtrTrib * nSinal

		nlIscPar  += nValimp2 * nSinal //Total parcial
		nlIsc     += nValimp2 * nSinal //Total geral

		nlIgvPar  += nValimp1 * nSinal //Total parcial
		nlIgv     += nValimp1 * nSinal //Total geral

		nValcont  := nValcont + nValcont1 + nExporta + Abs(nlF3Base) + nExonera + nInafecta + nValimp2 + nValimp1

		nlValCPar += (nValcont1 + nExporta + Abs(nlF3Base) + nExonera + nInafecta + nValimp2 + nValimp1) * nSinal //Total parcial
		nlValC    += (nValcont1 + nExporta + Abs(nlF3Base) + nExonera + nInafecta + nValimp2 + nValimp1) * nSinal //Total geral

		nlICBPar  += nValICB * nSinal //Total parcial
		nlICB     += nValICB * nSinal //Total geral

		If (cAliasPer)->(!Eof()) .And. cFil+cNFiscal+cSerie+cCliFor+cLoja+cEspecie == (cAliasPer)->(F3_FILIAL+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_ESPECIE)
			lImprime:=.F.
		EndIf

	EndIf

	If lImprime
		nColTip:= 0

		oSection1:Cell("CCORRELA"):SetValue(cCorrela) //1
		oSection1:Cell("DEMISSAO"):SetValue(DtoC(dEmissao)) //2
		oSection1:Cell("DVENCTORE"):SetValue(DtoC(dVenctoRe)) //3

		If Alltrim(cEspecie) $ "NDP/NDE/NCI/NCC"
			SF1->(DbSetOrder(1))
			If SF1->(MsSeek(xFilial("SF1")+cNFiscal+cSerie+cClifor+cLoja))
				cTpDoc := AllTrim(SF1->F1_TPDOC)
			Else
				If Empty(cTipoDoc_Anu)
					cTpDoc := xNCCAnul(cFil,cNFiscal,cSerie,cClifor,cLoja)
				Else
					cTpDoc := AllTrim(cTipoDoc_Anu)
				EndIf
			EndIf
		Else
			If !Empty(cCodGov) .And. AllTrim(cCGC) <> 'Anulado'
				cTpDoc := Trim(cCodGov)
			ElseIf cTpDoc <> "12" .And. AllTrim(cCGC) <> 'Anulado'
				SF2->(DbSetOrder(1)) //--F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				If SF2->(MsSeek(cFil+cNFiscal+cSerie+cCliFor+cLoja))
					cTpDoc := AllTrim(SF2->F2_TPDOC)
				Else
					cTpDoc := Space(02)
				EndIf
			ElseIf  AllTrim(cCGC) == 'Anulado' .and. lCpDoc
				cTpDoc := AllTrim(cTipoDoc_Anu)
			ElseIf AllTrim(cCGC) == 'Anulado' .and. cTpDoc <> "12"
				cTpDoc:= Trim(BuscaTpDoc(cFil,cNFiscal,cSerie,cClifor,cLoja))
			EndIf
		EndIf
		IF Empty(Alltrim(cTpDoc))
			nColTip:= IIf(lDev6,25,30)
		EndIF
		cSerieNf := Alltrim(Iif(lSerOri .and. !Empty(cSerOri), RetNewSer(cSerOri), Iif(lSerie2 .and. Empty(cSerie), RetNewSer(cSer2), RetNewSer(cSerie))))
		cSerieNf := Padr(cSerieNf,TamSx3("FP_SERIE")[1])
		lTemSFP := .f.

		// ----------------------------------------------------------------------------------- //
		// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
		// ----------------------------------------------------------------------------------- //
		SFP->(dbSetOrder(5))	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
		If SFP->(MsSeek(xFilial("SFP")+cFil+cSerieNf+"1"))
			If lSer3 .And. !Empty(SFP->FP_YSERIE)
				If Len( Alltrim(SFP->FP_YSERIE) ) > 4
					cTpDoc := "12"
				EndIf
			EndIf
			if lSerie2SFP
				if !empty(SFP->FP_SERIE2)
					cSerieNf := SFP->FP_SERIE2
					lTemSFP := .t.
				endif
			endif
		Else
			If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"6"))
				If lSer3 .And. !Empty(SFP->FP_YSERIE)
					If Len( Alltrim(SFP->FP_YSERIE) ) > 4
						cTpDoc := "12"
					EndIf
				EndIf
			EndIf
		EndIf

		oSection1:Cell("CTPDOC"):SetValue(Trim(cTpDoc)) //4
		// ----------------------------------------------------------------------------------- //
		// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
		// ----------------------------------------------------------------------------------- //
		SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
		If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"1" ) )
			If lSer3 .And. !Empty(SFP->FP_YSERIE)
				cSerieNf := SFP->FP_YSERIE
				lTemSFP := .t.
			else
				if !empty(SFP->FP_SERIE2)
					cSerieNf := SFP->FP_SERIE2
					lTemSFP := .t.
				endif
			endif
		endif

		if !lTemSFP
			If SFP->( MsSeek( cFilSFP+cFil+cSerieNf+"6" ) )
				If lSer3 .And. !Empty(SFP->FP_YSERIE)
					cSerieNf := SFP->FP_YSERIE
					lTemSFP := .t.
				else
					if !empty(SFP->FP_SERIE2)
						cSerieNf := SFP->FP_SERIE2
						lTemSFP := .t.
					endif
				endif
			endif
		EndIf

		if !lTemSFP
			If SFP->( MsSeek( cFilSFP+cFil+cSerieNf+"3" ) )
				If lSer3 .And. !Empty(SFP->FP_YSERIE)
					cSerieNf := SFP->FP_YSERIE
					lTemSFP := .t.
				else
					if !empty(SFP->FP_SERIE2)
						cSerieNf := SFP->FP_SERIE2
						lTemSFP := .t.
					endif
				endif
			endif
		EndIf

		if !lTemSFP
			If SFP->( MsSeek( cFilSFP+cFil+cSerieNf+"2" ) )
				If lSer3 .And. !Empty(SFP->FP_YSERIE)
					cSerieNf := SFP->FP_YSERIE
					lTemSFP := .t.
				else
					if !empty(SFP->FP_SERIE2)
						cSerieNf := SFP->FP_SERIE2
						lTemSFP := .t.
					endif
				endif
			endif
		EndIf

		If lSer3
			oSection1:Cell("CSERIENF"):SetValue(Alltrim(cSerieNf)+Space(Len(SFP->FP_YSERIE)-Len(Alltrim(cSerieNf)))) //5
		Else
			If !Empty(cSer2) .And. Subs(cSer2,1,1) $ "B|E|F"
				cSerieNf := Alltrim(cSer2)
			Else
				cSerieNf := AllTrim(RetNewSer(cSerie))
			EndIf

			If len(cSerieNf)<=3
				cSerieNf := Replicate("0",4-Len(cSerieNf))+cSerieNf
			EndIf

			If AllTrim(cTpDoc)=='05'
				cSerieNf :=  "4"
			EndIf

			oSection1:Cell("CSERIENF"):SetValue(Alltrim(cSerieNf)) //5
		EndIf

		If lSer3
			oSection1:Cell("CNFISCAL"):SetValue(AllTrim(cNFiscal)) //6
		Else
			oSection1:Cell("CNFISCAL"):SetValue(AllTrim(cNFiscal)) //6
		EndIf

		IF AllTrim(cCGC) <> 'Anulado'
			oSection1:Cell("CTIPODOC"):SetValue(cTipoDoc) //7
		Else
			oSection1:Cell("CTIPODOC"):SetValue(SPACE(2)) //7
		EndIf

		oSection1:Cell("CCGC"):SetValue(IIF(!EMPTY(cCGC), cCGC, SUBSTR(cPessFis,1,14))) //8

		IF ALLTRIM( cCGC)<>'Anulado'
			oSection1:Cell("CNOME"):SetValue(Space(1) + Left(cNome,39)) //9
		Else
			oSection1:Cell("CNOME"):SetValue(SPACE(40)) //9
		ENDIF

		If lDev4 .And. ("NC" $ cEspecie) .And. AllTrim(cTpDoc) == '07'
			nNCExp := IIf(nlExpoPar > 0,-1,1)
			nNCIna := IIf(nlInafPar > 0,-1,1)
		Else
			nNCExp := nNCIna := nSinal
		EndIf

		nValNFExp	:= nlExpoPar * nNCExp
		nImpTotExo	:= nlExonPar * nSinal
		nImpTotIna	:= nlInafPar * nNCIna
		nISC		:= nValimp2 * nSinal
		nIGVIPM		:= nValimp1 * nSinal
		oSection1:Cell("VALNFEXP"):SetValue(nValNFExp) //10
		oSection1:Cell("BASEIMPO"):SetValue(nlF3Base) //11
		oSection1:Cell("IMPTOTEXO"):SetValue(nImpTotExo) //12
		oSection1:Cell("IMPTOTINA"):SetValue(nImpTotIna) //13
		oSection1:Cell("ISC"):SetValue(nISC) //14
		oSection1:Cell("IGVIPM"):SetValue(nIGVIPM) //15

		(cAliasTrib)->(DbSetOrder(1))
		If (cAliasTrib)->(MsSeek(cNFiscal+cSerie+cClifor+cLoja))
			IF nlOtrTrib > 0
				oSection1:Cell("OTROSTRIB"):SetValue(nlOtrTrib) //16
				nlTribPar += nlOtrTrib* nSinal //Total parcial
				nlTrib	  += nlOtrTrib * nSinal //Total geral
				nTributo  := 0
				nTributo  += nlOtrTrib
			Else
				oSection1:Cell("OTROSTRIB"):SetValue(0) //16
				nlTribPar += 0//nValimp2 + nValimp1 //Total parcial
				nlTrib	  += 0//nValimp2 + nValimp1 //Total geral
				nTributo  := 0
				nTributo  += nlInafPar + nlExonPar
			EndIf
		Else
			oSection1:Cell("OTROSTRIB"):SetValue(0) //16
		EndIf

		nImpComPag := nValcont * nSinal
		nVlICBPER := nValICB * nSinal
		oSection1:Cell("IMPCOMPPAG"):SetValue(nImpComPag) //17
		oSection1:Cell("TPCAMBIO"):SetValue(nTxMoeda) //18
		oSection1:Cell("VALICB"):SetValue(nVlICBPER) //23

		nColAnt := oReport:nCol
		oReport:nCol := nColAnt

		If Alltrim(cEspecie) $ "NDC/NCE/NCP/NDI"
			SD2->(DbSetOrder(3))
			If SD2->(MsSeek(xFilial("SD2") + cNFiscal + cSerie + cClifor + cLoja ))
				If Len(Trim(SD2->D2_NFORI)) > 0
					_cTpoDoc := ""			// SISTHEL

					SF2->(DbSetOrder(1))
					If SF2->(MsSeek(cfil+AvKey(cNFiscal,"F2_DOC")+AvKey(cSerie,"F2_SERIE")+AvKey(cClifor,"F2_CLIENTE")+AvKey(cLoja,"D2_LOJA")))
						oSection1:Cell("FCHRCOMPGO"):SetValue(Trim(DtoC(SF2->F2_EMISSAO))) //19
						_cTpoDoc := Trim(SF2->F2_TPDOC)		// SISTHEL
					Else
						oSection1:Cell("FCHRCOMPGO"):SetValue("      ",) //19
						_cTpoDoc := ""						// SISTHEL
					Endif

					// ----------------------------------------------------------------------------------- //
					// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
					// ----------------------------------------------------------------------------------- //
					SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
					If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"1" ) )
						If lSer3 .And. !Empty(SFP->FP_YSERIE)
							If Len( Alltrim(SFP->FP_YSERIE) ) > 4
								_cTpoDoc := "12"
							EndIf
						EndIf
					Else
						If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"6" ) )
							If lSer3 .And. !Empty(SFP->FP_YSERIE)
								If Len( Alltrim(SFP->FP_YSERIE) ) > 4
									_cTpoDoc := "12"
								EndIf
							EndIf
						EndIf
					EndIf

					oSection1:Cell("TIPRCOMPGO"):SetValue(Trim(_cTpoDoc)) //20

					Do While SD2->(!Eof()) .And. ALLTRIM(SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)==ALLTRIM(cNFiscal + cSerie + cClifor + cLoja)
						If !Empty(SD2->D2_NFORI+SD2->D2_SERIORI)
							oReport:nCol:=4450
							// ----------------------------------------------------------------------------------- //
							// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
							// ----------------------------------------------------------------------------------- //
							cSSerie := SD2->D2_SERIORI
							lTemSFP := .f.
							SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
							If SFP->( MsSeek( xFilial("SFP")+cFil+cSSerie+"1" ) )
								If lSer3 .And. !Empty(SFP->FP_YSERIE)
									cSSerie := Alltrim(SFP->FP_YSERIE)
									lTemSFP := .t.
								EndIf
								if lSerie2SFP .And. !empty(SFP->FP_SERIE2)
									cSSerie := Alltrim(SFP->FP_SERIE2)
									lTemSFP := .t.
								endif
							endif
							if !lTemSFP
								If SFP->( MsSeek( xFilial("SFP")+cFil+cSSerie+"6" ) )
									If lSer3 .And. !Empty(SFP->FP_YSERIE)
										cSSerie := Alltrim(SFP->FP_YSERIE)
										lTemSFP := .t.
									EndIf
								endif
								if lSerie2SFP .And. !empty(SFP->FP_SERIE2)
									cSSerie := Alltrim(SFP->FP_SERIE2)
									lTemSFP := .t.
								endif
							EndIf
							if !lTemSFP
								If SFP->( MsSeek( xFilial("SFP")+cFil+cSSerie+"3" ) )
									If lSer3 .And. !Empty(SFP->FP_YSERIE)
										cSSerie := Alltrim(SFP->FP_YSERIE)
										lTemSFP := .t.
									EndIf
								endif
								if lSerie2SFP .And. !empty(SFP->FP_SERIE2)
									cSSerie := Alltrim(SFP->FP_SERIE2)
									lTemSFP := .t.
								endif
							EndIf
							if !lTemSFP
								If SFP->( MsSeek( xFilial("SFP")+cFil+cSSerie+"2" ) )
									If lSer3 .And. !Empty(SFP->FP_YSERIE)
										cSSerie := Alltrim(SFP->FP_YSERIE)
										lTemSFP := .t.
									EndIf
								endif
								if lSerie2SFP .And. !empty(SFP->FP_SERIE2)
									cSSerie := Alltrim(SFP->FP_SERIE2)
									lTemSFP := .t.
								endif
							EndIf
							If Len(cSSerie)<=3
								cSSerie := Replicate("0",4-Len(cSSerie))+cSSerie
							EndIf

							oSection1:Cell("SERRCOMPGO"):SetValue(Trim(cSSerie)) //21
							oSection1:Cell("NUMRCOMPGO"):SetValue(Trim(SD2->D2_NFORI)) //22

							lNotOri:=.T.

						Endif
						SD2->(DbSkip())
					End
				ElseIf (cAliasPer)->(!Eof())
					lNotOri:=.F.
				EndIf
			Endif

			nlTotReg++

		ElseIf Alltrim(cEspecie) $ "NDP/NDE/NCI/NCC"
			SD1->(DbSetOrder(1))
			If SD1->(MsSeek(cfil + cNFiscal + cSerie + cClifor + cLoja))
				_cTpoDoc := ""		// SISTHEL

				SF2->(DbSetOrder(1))
				If SF2->(MsSeek(xFilial("SF2") + AvKey(SD1->D1_NFORI,"F2_DOC")+ AvKey(SD1->D1_SERIORI,"F2_SERIE")+AvKey(SD1->D1_FORNECE,"D2_CLIENTE")+AvKey(SD1->D1_LOJA,"D2_LOJA")))
					oSection1:Cell("FCHRCOMPGO"):SetValue(Trim(DtoC(SF2->F2_EMISSAO))) //19
					_cTpoDoc := Trim(SF2->F2_TPDOC)		// SISTHEL
				Else
					oSection1:Cell("FCHRCOMPGO"):SetValue("      ") //19
					_cTpoDoc := ""						// SISTHEL
				Endif
				// ----------------------------------------------------------------------------------- //
				// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
				// ----------------------------------------------------------------------------------- //
				SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
				If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"1" ) )
					If lSer3 .And. !Empty(SFP->FP_YSERIE)
						If Len( Alltrim(SFP->FP_YSERIE) ) > 4
							_cTpoDoc := "12"
						EndIf
					EndIf
				Else
					If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"6" ) )
						If lSer3 .And. !Empty(SFP->FP_YSERIE)
							If Len( Alltrim(SFP->FP_YSERIE) ) > 4
								_cTpoDoc := "12"
							EndIf
						EndIf
					EndIf
				EndIf

				oSection1:Cell("TIPRCOMPGO"):SetValue(Trim(_cTpoDoc)) //20

				Do While SD1->(!Eof()) .And. ALLTRIM(SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA) == ALLTRIM(cNFiscal + cSerie + cClifor + cLoja)
					If !Empty(SD1->D1_NFORI+SD1->D1_SERIORI)
						oReport:nCol:=4450

						// ----------------------------------------------------------------------------------- //
						// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
						// ----------------------------------------------------------------------------------- //
						cSSerie := SD1->D1_SERIORI
						lTemSFP := .f.
						SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
						If SFP->( MsSeek( xFilial("SFP")+cFil+cSSerie+"1" ) )
							If lSer3 .And. !Empty(SFP->FP_YSERIE)
								cSSerie := Alltrim(SFP->FP_YSERIE)
								lTemSFP := .t.
							EndIf
							if lSerie2SFP .And. !empty(SFP->FP_SERIE2)
								cSSerie := Alltrim(SFP->FP_SERIE2)
								lTemSFP := .t.
							endif
						endif

						if !lTemSFP
							If SFP->( MsSeek( xFilial("SFP")+cFil+cSSerie+"6" ) )
								If lSer3 .And. !Empty(SFP->FP_YSERIE)
									cSSerie := Alltrim(SFP->FP_YSERIE)
									lTemSFP := .t.
								EndIf
							endif
							if lSerie2SFP .And. !empty(SFP->FP_SERIE2)
								cSSerie := Alltrim(SFP->FP_SERIE2)
								lTemSFP := .t.
							endif
						EndIf

						if !lTemSFP
							If SFP->( MsSeek( xFilial("SFP")+cFil+cSSerie+"3" ) )
								If lSer3 .And. !Empty(SFP->FP_YSERIE)
									cSSerie := Alltrim(SFP->FP_YSERIE)
									lTemSFP := .t.
								EndIf
							endif
							if lSerie2SFP .And. !empty(SFP->FP_SERIE2)
								cSSerie := Alltrim(SFP->FP_SERIE2)
								lTemSFP := .t.
							endif
						EndIf

						if !lTemSFP
							If SFP->( MsSeek( cFilSFP+cFil+cSSerie+"2" ) )
								If lSer3 .And. !Empty(SFP->FP_YSERIE)
									cSSerie := Alltrim(SFP->FP_YSERIE)
									lTemSFP := .t.
								EndIf
							endif
							if lSerie2SFP .And. !empty(SFP->FP_SERIE2)
								cSSerie := Alltrim(SFP->FP_SERIE2)
								lTemSFP := .t.
							endif
						EndIf

						If Len(cSSerie)<=3
							cSSerie := Replicate("0",4-Len(cSSerie))+cSSerie
						EndIf

						oSection1:Cell("SERRCOMPGO"):SetValue(Trim(cSSerie)) //21
						oSection1:Cell("NUMRCOMPGO"):SetValue(Trim(SD1->D1_NFORI)) //22

						lNotOri:=.T.
						lRComp := .T.
					Endif
					SD1->(DbSkip())
				End
			Endif
			nlTotReg++
		Else
			nlTotReg++
		Endif



		If nReg <> nlTotRel
			nLinP    := oReport:Row()+32
			nlExpoPa := nlExpoPar
			nlBasePa := nlBasePar
			nlExonPa := nlExonPar
			nlInafPa := nlInafPar
			nlIscPa  := nlIscPar
			nlIgvPa  := nlIgvPar
			nlTribPa := nlTribPar
			nlValCPa := nlValCPar
			nlICBPa  := nlICBPar
		EndIf

		oReport:OnPageBreak({|| FCabR011(oReport,nCol,nlExpoPa,nlBasePa,nlExonPa,nlInafPa,nlIscPa,nlIgvPa,nlTribPa,nlValCPa,nlICBPa, aParams)})

		If nlTotReg > nlTotPag
			oReport:EndPage()
			nlTotReg :=0
		EndIf

		nlExpoPar := 0
		nlF3Base  := 0
		nlExonPar := 0
		nlInafPar := 0
		nlOtrTrib := 0
		nValcont  := 0

		oSection1:PrintLine()

	EndIf
	oReport:IncMeter()
EndDo
oSection1:Finish()

If nReg == 0
	oReport:PrintText(STR0004,oReport:Row(),oReport:Col()+0010)
EndIf


(cAliasPer)->(DbCLoseArea())

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCabR011  ³ Autor ³ Rodrigo M. Pontes     ³ Data | 30/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio.								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FCabR011(oReport,nCol,nlExpoPa,nlBasePa,nlExonPa,nlInafPa,nlIscPa,nlIgvPa,nlTribPa,nlValCPa,nlICBPa, aParams)

DEFAULT nlExpoPa :=0
DEFAULT nlBasePa :=0
DEFAULT nlExonPa :=0
DEFAULT nlInafPa :=0
DEFAULT nlIscPa  :=0
DEFAULT nlIgvPa  :=0
DEFAULT nlTribPa :=0
DEFAULT nlValCPa :=0
DEFAULT nlICBPa  :=0

If oReport:nDevice == 6
	oReport:oPrint:NPageWidth	:= 4960.5 + 200
	oReport:oPrint:NPageHeight	:= 3478
EndIf

nCol := oReport:Col() + 10
oReport:PrintText(STR0062)//"FORMATO 14.1 REGISTRO DE VENTAS E INGRESOS"
oReport:PrintText(STR0007+AllTrim(Str(Month(aParams[1])))+"/"+AllTrim(Str(Year(aParams[1]))) +" - " +	AllTrim(Str(Month(aParams[2])))+"/"+AllTrim(Str(Year(aParams[2]))), oReport:Row(), nCol) //Periodo
oReport:PrintText(STR0008+AllTrim(SM0->M0_CGC)					, oReport:Row()+35, nCol) //RUC
oReport:PrintText(STR0009+AllTrim(Capital(SM0->M0_NOMECOM))	, oReport:Row()+40, nCol) //Nome Contribuinte
If aParams[3] == 1
	oReport:PrintText(STR0010+AllTrim(Str(oReport:Page())),oReport:Row()+40,nCol) //Pagina
Endif
oReport:SkipLine(2)
oReport:Section(1):Init()
Return

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ FSR11GerArq   ³ Autor ³ Ivan Haponczuk ³ Data ³ 15.03.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Gera o arquivo magnético do livro de venda.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FSR11GerArq(aFiliais, aParams, cEmpresa, cFil, lEnd)
Local nHdl         := 0
Local nSinal       := 0
Local nlF3Bas      := 0
Local cLin         := ""
Local cSep         := "|"
Local cTipDoc      := ""
Local cSerie       := ""
Local cSerFre      := ""
Local cNumDoc      := ""
Local cOriser      := ""
Local dEmiss       := CtoD(Space(08))
Local cAliasPer    := ''
Local cAliasTrib   := ''
Local nT           := 1
Local nValorC      := 0
Local nTot1        := 1
Local nReg         := 0
Local lRet         := .T.
Local lCpDoc       := .F.
Local lSer3        := .F.
Local lSerie2      := .F.
Local lSerOri      := .F.
Local lCodSF1      := .F.
Local lCodSF2      := .F.
Local lSerie2SFP   := .F.
Local cArq         := ''
Local cTipoDoc_Anu := ""		// add por SISTHEL - 13/07/2018
Local aInfAnul     := {}
Local cPathUsr     := ""
Local nValICB      := 0
Local cCorrelAnt   := ""
Local nCorrela     := 0
Local nSecNodia    := 0

Default cEmpresa   := cEmpAnt
Default cFil       := cFilAnt
Default lEnd       := .F.

// -----------------------------------------
// PROCESSA A QUERY PRINCIPAL
// -----------------------------------------
cAliasPer  := FISR011Qry(aFiliais, aParams, .f.)

// ---------------------------------------------
// PROCESSA ARQUIVO TEMPORARIO - OUTROS TRIBUTOS
// ---------------------------------------------
cAliasTrib := FISR011Trib(aFiliais, aParams)

// ---------------------------------------
// TRATA DICIONARIO DE DADOS
// ---------------------------------------

lCpDoc     := SF3->(ColumnPos("F3_TPDOC")) > 0
lSer3      := SFP->(ColumnPos("FP_YSERIE")) > 0 //-- Impresion de la serie 2 (factura electrocnica - Peru)
lSerie2    := SF1->(ColumnPos("F1_SERIE2")) > 0 .And. SF2->(ColumnPos("F2_SERIE2")) > 0 .And. SF3->(ColumnPos("F3_SERIE2")) > 0 .And. GetNewPar("MV_LSERIE2", .F.)
lSerOri    := SF1->(ColumnPos("F1_SERORI")) > 0 .And. SF2->(ColumnPos("F2_SERORI")) > 0 .And. SF3->(ColumnPos("F3_SERORI")) > 0
lSerie2SFP := SFP->(ColumnPos("FP_SERIE2")) > 0

If SF1->(ColumnPos("F1_TPDOC")) > 0
	lCodSF1 := .T.
EndIf

If SF2->(ColumnPos("F2_TPDOC")) > 0
	lCodSF2 := .T.
Endif

// -----------------------------------------
// TRATA NOME DO ARQUIVO
// -----------------------------------------
cArq := ''
cArq += "LE"									//-- Fixo  'LE'
cArq +=  AllTrim(SM0->M0_CGC)					//-- Ruc
cArq +=  AllTrim(Str(Year(aParams[2])))	   		//-- Ano
cArq +=  AllTrim(Strzero(Month(aParams[2]),2))	//-- Mes
cArq +=  "00"									//-- Fixo '00'
cArq += "140100"								//-- Fixo '140100'
cArq += "00"									//-- Fixo '00'
cArq += "1"
cArq += If((cAliasPer)->(!Eof()), '1', '0')
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao

// Autor> DS2U (SDA)
// Data: 06/12/2019
// Definicao do path para geracao do arquivo
VarSetX('FISR011', 'cArq', cArq)
cPathUsr := AllTrim(aParams[7]) + If(Right(AllTrim(aParams[7]), 1) == '\', '', '\')
cPath := GetSrvProfString("StartPath","")   // Diretorio no servidor que sera utilizado para criar o arquivo  cuando es por JOB

// -------------------------------------------
// PROCESSA GERACAO DO ARQUIVO
// -------------------------------------------
nHdl := fCreate(cPathUsr + cArq,0,Nil,.F.)

If nHdl <= 0
	lRet := .F.
Else
	(cAliasPer)->(DBEval({|| nReg++}, {|| .T.}, {|| !Eof()}))
	(cAliasPer)->(DbGoTop())

	ProcRegua(nReg)
	Do While (cAliasPer)->(!EOF())
		cFil         := (cAliasPer)->F3_FILIAL
		cNFiscal     := (cAliasPer)->F3_NFISCAL
	    cSerie       := (cAliasPer)->F3_SERIE
	    cClifor      := (cAliasPer)->F3_CLIEFOR
	    cLoja        := (cAliasPer)->F3_LOJA
	    cEspecie     := (cAliasPer)->F3_ESPECIE
	    nValcont     := (cAliasPer)->F3_VALCONT
	    nTxMoeda     := (cAliasPer)->F2_TXMOEDA
	    nExporta     := (cAliasPer)->EXPORTACAO
	    nExonera     := (cAliasPer)->EXONERADA
	    nInafecta    := (cAliasPer)->INAFECTA
	    nValimp2     := (cAliasPer)->F3_VALIMP2
	    nValimp1     := (cAliasPer)->F3_VALIMP1
	    cNome        := (cAliasPer)->A1_NOME
	    cCGC         := (cAliasPer)->A1_CGC
	    cPessFis     := (cAliasPer)->A1_PFISICA
	    cTipoDoc     := (cAliasPer)->A1_TIPDOC
	    cCodGov      := (cAliasPer)->CCL_CODGOV
	    dEmissao     := (cAliasPer)->F3_EMISSAO
	    dVenctoRe    := (cAliasPer)->E1_VENCTO
	    nBase1       := (cAliasPer)->F3_BASIMP1
	    nBase2       := (cAliasPer)->F3_BASIMP2
	    nMoeda       := (cAliasPer)->F2_MOEDA
		nValICB      := (cAliasPer)->F3_VALICB

    	If AllTrim(cCGC) <> 'Anulado'
			cTipoDoc_Anu := cCodGov
		Else
			cTipoDoc_Anu := If(lCpDoc, (cAliasPer)->F3_TPDOC, '')
		EndIf
    	cSer2        := IIf(lSerie2, (cAliasPer)->F3_SERIE2, "")
	    cSerOri      := (cAliasPer)->F3_SERORI
	    nValorC      := (cAliasPer)->F3_VALCONT

		cCorrela     := If(Empty((cAliasPer)->F2_NODIA), BuscaCorre(cFil,cNFiscal,cSerie,cClifor,cLoja,dEmissao,cEspecie), (cAliasPer)->F2_NODIA)

		(cAliasPer)->(DbSkip())

		IncProc()

		If lEnd
			Exit
		EndIf

	    lImprime:=.T.
	    If cFil == (cAliasPer)->F3_FILIAL .And. cNFiscal == (cAliasPer)->F3_NFISCAL .And. cSerie == (cAliasPer)->F3_SERIE .And.;
	    	cClifor == (cAliasPer)->F3_CLIEFOR .And. cLoja == (cAliasPer)->F3_LOJA .And. cEspecie == (cAliasPer)->F3_ESPECIE .And. (cAliasPer)->(!Eof())
			lImprime:=.F.
	    EndIf

		If lImprime
			nSinal := Iif(("NC"$cEspecie .OR. cCodGov=='25' ),-1,1)
			cLin   := ""

			//01 - Periodo
			cLin += SubStr(DTOS(dEmissao),1,6)+"00"
			cLin += cSep

			//02 - Num correlativo
			If empty(cCorrela)
				cLin += "CUO-VACIO"
			Else
				cLin += AllTrim(cCorrela)
				If !(cCorrelAnt == cCorrela)
					cCorrelAnt := cCorrela
					nSecNodia := 0
				EndIf
			EndIf
			cLin += cSep

			//03 - Numero correlativo del registro
			If empty(cCorrela)
				cLin += "M"+StrZero(++nCorrela,9)
			ElseIf Alltrim(cEspecie) $ "NDP|NDE|NCI|NCC"
				IF ALLTRIM( cCGC) <> 'Anulado'
					SF1->( DbSetOrder(1) ) //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA
					If SF1->( MsSeek(cFil+cNFiscal+cSerie+cClifor+cLoja) )
							if !empty(SF1->F1_NODIA)
				    	        cLin += "M"+getLinCT2(AllTrim(SF1->F1_NODIA),SF1->F1_VALBRUT,SF1->F1_MOEDA,.T.,cFil)
				   			else
								cLin += "M"+StrZero(++nSecNodia,9)
				   			endif
					else
						cLin += "M"+StrZero(++nSecNodia,9)
					endif
				ELSE
					aInfAnul := xBusNFAnul(cFil,cNFiscal,cSerie,cClifor,cLoja,1)
		   			if len(aInfAnul) > 0
			   			cLin += "M"+getLinCT2(AllTrim(aInfAnul[1]),aInfAnul[2],aInfAnul[3],.f.,cFil)
			   		else
						cLin += "M"+StrZero(++nSecNodia,9)
			   		endif
				ENDIF
			else
				IF ALLTRIM( cCGC) <> 'Anulado'
			        SF2->( DbSetOrder(1) ) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
					If SF2->( MsSeek(cFil+cNFiscal+cSerie+cClifor+cLoja) )
							if !empty(cCorrela)
				    	        cLin += "M"+getLinCT2(AllTrim(cCorrela),SF2->F2_VALBRUT,SF2->F2_MOEDA,.f.,cFil)
				   			else
								cLin += "M"+StrZero(++nSecNodia,9)
				   			endif
		   			else
						cLin += "M"+StrZero(++nSecNodia,9)
		   			endif
		   		else
		   			aInfAnul := xBusNFAnul(cFil,cNFiscal,cSerie,cClifor,cLoja,2)
		   			if len(aInfAnul) > 0
			   			cLin += "M"+getLinCT2(AllTrim(aInfAnul[1]),aInfAnul[2],aInfAnul[3],.f.,cFil)
			   		else
						cLin += "M"+StrZero(++nSecNodia,9)
			   		endif
		   		endif
		   	endif
			cLin += cSep

			//04 - Fecha de emisión del Comprobante de Pago
			cLin += SubStr(DTOC(dEmissao),1,6)+SubStr(DTOS(dEmissao),1,4)
			cLin += cSep

			//05 - Fecha de Vencimiento o Fecha de Pago (1)
			// Alteração realizada em 08/02/13 para atender OAS - Regiane
			// Para NFs canceladas o campo 5 - tipo de documento = "00", sendo assim, este campo não é obrigatório

			cTpDoc := cTipoDoc_Anu
			if empty(cTpDoc)
				If Alltrim(cEspecie) $ "NDP|NDE|NCI|NCC"
					SF1->(DbSetOrder(1))
					If SF1->(MsSeek(cfil+cNFiscal+cSerie+cClifor+cLoja))
						cTpDoc := AllTrim(SF1->F1_TPDOC)
					Else
						// ------------------------------------------------------------------------- //
						// add por SISTHEL - 13/07/2018
						// El campo F3_TPDOC puede no existir en alguns antornos, el problema que
						// mismo existiendo este campo llega en blanco.
						// ------------------------------------------------------------------------- //
						if empty(cTipoDoc_Anu)
							cTpDoc := xNCCAnul(cFil,cNFiscal,cSerie,cClifor,cLoja)
						else
						    cTpDoc := AllTrim(cTipoDoc_Anu)
						endif
					EndIf
				Else
		           IF !EMPTY(cCodGov)
		 	          cTpDoc := cCodGov
	    		   ELSE
		              cTpDoc:=BuscaTpDoc(cFil,cNFiscal,cSerie,cClifor,cLoja)
				   ENDIF
				ENDIF
			endif

			If AllTrim(cTpDoc) == "14" .AND. ALLTRIM(cCGC) <> 'Anulado'
				If !Empty(AllTrim(cCodGov)) .AND. ! EMPTY(dVenctoRe)
					cLin += SubStr(DTOC(dVenctoRe),1,6)+SubStr(DTOS(dVenctoRe),1,4)
				Else
					cLin += "01/01/0001"
				EndIf
			Else
		        cLin += "01/01/0001"
			EndIf
			cLin += cSep

			//06 Tipo de Comprobante de Pago o Documento tabela 10
			// ----------------------------------------------------------------------------------- //
			// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
			// ----------------------------------------------------------------------------------- //
			cSerieNf := Alltrim(Iif(lSerOri .and. !Empty(cSerOri),RetNewSer(cSerOri),Iif(lSerie2 .and. Empty(cSerie),RetNewSer(cSer2),RetNewSer(cSerie)) ))
			cSerieNf := Padr(cSerieNf,TamSx3("FP_SERIE")[1])
			cLin += AllTrim(cTpDoc)
			cLin += cSep

			//07 Número serie del comprobante de pago o documento o número de serie de la maquina registradora
			nT := Len(cSerieNf)+1

			// ----------------------------------------------------------------------------------- //
			// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
			// ----------------------------------------------------------------------------------- //
			if empty(cSer2)
				lTemSFP := .f.
				SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
				If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"1" ) )
					If lSer3 .And. !Empty(SFP->FP_YSERIE)
						cSerieNf := Alltrim(SFP->FP_YSERIE)
						lTemSFP := .t.
					else
						if lSerie2SFP
							if !empty(SFP->FP_SERIE2)
								cSerieNf := Alltrim(SFP->FP_SERIE2)
								lTemSFP := .t.
							endif
						endif
					endif
				endif

				if !lTemSFP
					If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"6" ) )
						If lSer3 .And. !Empty(SFP->FP_YSERIE)
							cSerieNf := Alltrim(SFP->FP_YSERIE)
							lTemSFP := .t.
						else
							if lSerie2SFP
								if !empty(SFP->FP_SERIE2)
									cSerieNf := Alltrim(SFP->FP_SERIE2)
									lTemSFP := .t.
								endif
							endif
						endif
					endif
				EndIf

				if !lTemSFP
					If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"3" ) )
						If lSer3 .And. !Empty(SFP->FP_YSERIE)
							cSerieNf := Alltrim(SFP->FP_YSERIE)
							lTemSFP := .t.
						else
							if lSerie2SFP
								if !empty(SFP->FP_SERIE2)
									cSerieNf := Alltrim(SFP->FP_SERIE2)
									lTemSFP := .t.
								endif
							endif
						endif
					endif
				EndIf

				if !lTemSFP
					If SFP->( MsSeek( xFilial("SFP")+cFil+cSerieNf+"2" ) )
						If lSer3 .And. !Empty(SFP->FP_YSERIE)
							cSerieNf := Alltrim(SFP->FP_YSERIE)
							lTemSFP := .t.
						else
							if lSerie2SFP
								if !empty(SFP->FP_SERIE2)
									cSerieNf := Alltrim(SFP->FP_SERIE2)
									lTemSFP := .t.
								endif
							endif
						endif
					endif
				EndIf
			endif

			If Len(cSerieNf)<=3 .and. empty(cSer2)
				cSerieNf := Replicate("0",4-Len(cSerieNf))+cSerieNf
			elseIf Len(cSerieNf)==3 .and. !empty(cSer2)
				cSerieNf := cSer2
			else
				if !lTemSFP
					cSerieNf := cSer2
				endif
			EndIf
			// -------------------------------------------------------------------------[ Fim ]-- //
			If !lSer3
				If !Empty(cSer2) .And. Subs(cSer2,1,1) $ "B|E|F"
					cSerieNf := Alltrim(cSer2)
				Else
					cSerieNf := AllTrim(RetNewSer(cSerie))
				EndIf

				If LEN(cSerieNf)<=3
					cSerieNf := Replicate("0",4-Len(cSerieNf))+cSerieNf
				EndIf
			EndIf

			If AllTrim(cTpDoc)=='05'
				cLin +=  "4"
			Else
				cLin += AllTrim(cSerieNf)
			EndIf

			cLin += cSep

			//08 Número del comprobante de pago o documento.
			cLin += Right(AllTrim(cNFiscal),8)
			cLin += cSep

			//09   1. Para efectos del registro de tickets o cintas emitidos por máquinas registradoras que no otorguen
			//			derecho a crédito fiscal de acuerdo a las normas de Comprobantes de Pago y opten por anotar el importe total
			//			de las operaciones realizadas por día y por máquina registradora, registrar el número final (2).
			//		2. Se permite la consolidación diaria de las Boletas de Venta emitidas de manera electrónica
			// 			Alteração realizada em 08/02/13 para atender OAS - Regiane
			//			Peru trabalha de forma analitica não consolidada por isto registrar "0"
			If AllTrim(cTpDoc) == "03" .and. nValcont >= 700.00
				cLin += Right(AllTrim(cNFiscal),8)
			Else
				cLin += ""
			EndIf
			cLin += cSep

			//10 Tipo de Documento de Identidad del cliente
			If ALLTRIM(cCGC)=='Anulado'
				cLin += "0"
			Else
				cLin += IIF(!Empty(AllTrim(cTipoDoc)),strzero(Val(cTipoDoc),1),"0")
			EndIf
			cLin += cSep

			//11 - Número de Documento de Identidad del cliente
			if alltrim(cTipoDoc)$"6/06"
				cLin += IIF(!Empty(AllTrim( cCGC)),AllTrim( cCGC),"1")
			ELSE
			    cLin += IIF(!Empty(AllTrim(cPessFis)),AllTrim(cPessFis),"1")
			ENDIF
			cLin += cSep

			//12 Apellidos y nombres, denominación o razón social  del cliente.
			If AllTrim(cTpDoc) $ "00|05|06|07|08|11|12|13|14|15|16|18|19|23|26|28|30|34|35|36|37|55|56|87|88";
				.Or. ALLTRIM( cCGC)=='Anulado';
				.Or. (AllTrim(StrTran(Transform( nExporta* nSinal,"@E 999999999.99"),",",".")) > AllTrim(StrTran(Transform(0 * nSinal,"@E 999999999.99"),",",".")));
				.Or. (AllTrim(StrTran(Transform( nValcont* nSinal,"@E 999999999.99"),",",".")) < AllTrim(StrTran(Transform(0 * nSinal,"@E 999999999.99"),",",".")) .And. AllTrim(cTpDoc)$ "03|12");
				.Or. (AllTrim(cTpDoc)) <> ""

				cLin += AllTrim(cNome)

			Else
				cLin += ""
			EndIF
			cLin += cSep

			//13 Valor facturado de la exportación
  			cLin += AllTrim(StrTran(Transform( nExporta* nSinal,"@E 999999999.99"),",","."))
			cLin += cSep

			If  nBase1 > 0 .And.  nBase2 = 0
				nlF3Bas :=  nBase1 * nSinal
			ElseIf  nBase1 = 0 .And.  nBase2 > 0
				nlF3Bas := nBase2 * nSinal
			ElseIf  nBase1 > 0 .And.  nBase2 > 0
				nlF3Bas := ( nBase1 - nBase2) * nSinal
			Else
				nlF3Bas := 0
			EndIf

			//14 Base imponible de la operación gravada (4)
			dEmiss  := CTOD("  /  /  ")

			If alltrim(cTpDoc)$"07"
				dbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				If SD1->(MsSeek(cfil+cNFiscal+cSerie+cClifor+cLoja))
					SF2->(dbSelectArea("SF2"))
					SF2->(dbSetOrder(1))
					If SF2->(MsSeek(cfil+AvKey(SD1->D1_NFORI,"F2_DOC")+AvKey(SD1->D1_SERIORI,"F2_SERIE")+AvKey(SD1->D1_FORNECE,"D2_CLIENTE")+AvKey(SD1->D1_LOJA,"D2_LOJA")))
						dEmiss  := SF2->F2_EMISSAO
			        EndIf
			     EndIf

				If DtoS(dEmiss)<DtoS(aParams[1])
					cLin += ""
					cLin += cSep
				Else
					cLin += AllTrim(StrTran(Transform(nlF3Bas,"@E 999999999.99"),",","."))
					cLin += cSep
				EndIf

			Else
				cLin += AllTrim(StrTran(Transform(nlF3Bas,"@E 999999999.99"),",","."))
				cLin += cSep
			EndIF

			//15 Descuento de la Base Imponible
			If alltrim(cTpDoc)$"07"
				dbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				If SD1->(MsSeek(cfil+cNFiscal+cSerie+cClifor+cLoja))
					SF2->(dbSelectArea("SF2"))
					SF2->(dbSetOrder(1))
					If SF2->(MsSeek(cfil+AvKey(SD1->D1_NFORI,"F2_DOC")+AvKey(SD1->D1_SERIORI,"F2_SERIE")+AvKey(SD1->D1_FORNECE,"D2_CLIENTE")+AvKey(SD1->D1_LOJA,"D2_LOJA")))
						dEmiss  := SF2->F2_EMISSAO
			        EndIf
			     EndIf

				If DtoS(dEmiss)>=DtoS(aParams[1])
					cLin += ""
					cLin += cSep
				Else
					cLin += AllTrim(StrTran(Transform(nlF3Bas,"@E 999999999.99"),",","."))
					cLin += cSep
				EndIf
			Else
				cLin += ""
				cLin += cSep
			EndIf

			//16 Impuesto General a las Ventas y/o Impuesto de Promoción Municipal
			If alltrim(cTpDoc)$"07"
				If DtoS(dEmiss)<DtoS(aParams[1])
					cLin += ""
					cLin += cSep
				Else
					cLin += AllTrim(StrTran(Transform(nValimp1*nSinal,"@E 999999999.99"),",","."))
					cLin += cSep
				EndIF
			Else
				cLin += AllTrim(StrTran(Transform(nValimp1*nSinal,"@E 999999999.99"),",","."))
				cLin += cSep
			EndIf

			//17 Descuento del Impuesto General a las Ventas y/o Impuesto de Promoción Municipal
			If alltrim(cTpDoc)$"07"
				If DtoS(dEmiss)>=DtoS(aParams[1])
					cLin += ""
					cLin += cSep
				Else
					cLin += AllTrim(StrTran(Transform(nValimp1*nSinal,"@E 999999999.99"),",","."))
					cLin += cSep
				EndIF
			Else
				cLin += ""
				cLin += cSep
			EndIf

			//18 Importe total de la operación exonerada
			If nExonera > 0
				cLin += AllTrim(StrTran(Transform(nExonera*nSinal,"@E 999999999.99"),",","."))
			else
				cLin += AllTrim(StrTran(Transform(0,"@E 999999999.99"),",","."))
			endif
			cLin += cSep

			//19 Importe total de la operación inafecta
			if alltrim(Posicione("SA1",1,xFilial("SA1")+cClifor+cLoja,"SA1->A1_EST"))=="EX"
				cLin += "0.00"
			Else
				cLin += AllTrim(StrTran(Transform(nInafecta*nSinal,"@E 999999999.99"),",","."))
			EndIf
			cLin += cSep

			//20 Impuesto Selectivo al Consumo, de ser el caso.
			cLin += AllTrim(StrTran(Transform(nValimp2*nSinal,"@E 999999999.99"),",","."))
			cLin += cSep

			//21 Base imponible de la operación gravada con el Impuesto a las Ventas del Arroz Pilado
			cLin += ""
			cLin += cSep

			//22 Impuesto a las Ventas del Arroz Pilado
			cLin += ""
			cLin += cSep

			If nPLEPeru > 5181
				//23 Impuesto al Consumo de Bolsas de Plástico. RS 150-2019/SUNAT
				cLin += AllTrim(StrTran(Transform(nValICB*nSinal,"@E 999999999.99"),",","."))
				cLin += cSep
			EndIf

			//23 - Otros conceptos, tributos y cargos que no forman parte de la base imponible
			if (nExonera*nSinal) <= 0 .And. ALLTRIM(cCGC) <> 'Anulado'
				(cAliasTrib)->(DbSetOrder(1))
				If (cAliasTrib)->(MsSeek(cNFiscal+cSerie+cClifor+cLoja))
					cLin += AllTrim(StrTran(Transform((cAliasTrib)->TRIBUTO,"@E 999999999.99"),",","."))
				Else
					cLin += "0.00"
				Endif
			else
				cLin += "0.00"
			endif

			//cLin += AllTrim(StrTran(Transform(nOutTributos,"@E 999999999.99"),",","."))
			cLin += cSep

			//24 - Importe total del comprobante de pago

			if ALLTRIM(cCGC) <> 'Anulado'
				cLin += AllTrim(StrTran(Transform( nValorC * nSinal,"@E 999999999.99"),",","."))
			else
				cLin += "0.00"
			endif
			cLin += cSep

			// Tratamento para as notas "NDC|NCE|NCP|NDI"
			cSerFre := cSerie
			cTipDoc := ""
			cNumDoc := ""
			cOriser := ""
			dEmiss  := CTOD("  /  /  ")

			If Alltrim(cEspecie) $ "NDC|NCE|NCP|NDI"
				dbSelectArea("SD2")
				SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If SD2->(MsSeek(CFIL+cNFiscal+cSerie+cClifor+cLoja))
				  If Len(Trim(SD2->D2_NFORI)) > 0
				    dbSelectArea("SF2")
				    SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

                    If SF2->(MsSeek(CFIL+AvKey(SD2->D2_NFORI,"F2_DOC")+AvKey(SD2->D2_SERIORI,"F2_SERIE")+AvKey(SD2->D2_CLIENTE,"F2_CLIENTE")+AvKey(SD2->D2_LOJA,"D2_LOJA")))
						dEmiss  := SF2->F2_EMISSAO
						cTipDoc := SF2->F2_TPDOC
					EndIf
					Do While SD2->(!Eof()) .And. ALLTRIM(SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA) == ALLTRIM(cNFiscal+cSerie+cClifor+cLoja)
						If !Empty(SD2->D2_NFORI+SD2->D2_SERIORI)
							cOriSer  := SD2->D2_SERIORI
							cNumDoc := SD2->D2_NFORI
							exit
						Endif
						SD2->(DbSkip())
					EndDo
				  EndIf
				EndIf

			ElseIf Alltrim(cEspecie) $ "NDP|NDE|NCI|NCC"

				dbSelectArea("SD1")
				SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

				If SD1->(MsSeek(cFil+cNFiscal+cSerie+cClifor+cLoja))
					SF2->(dbSelectArea("SF2"))
					SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

					If SF2->( MsSeek( cFil+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA ) )
						dEmiss  := SF2->F2_EMISSAO
						cTipDoc := SF2->F2_TPDOC
						SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
						If SFP->( MsSeek( xFilial("SFP")+cFil+SD1->D1_SERIORI+"1" ) )
							If lSer3 .And. !Empty(SFP->FP_YSERIE)
								If Len( Alltrim(SFP->FP_YSERIE) ) > 4
									cTipDoc := "12"
								EndIf
							EndIf
						Else
							If SFP->( MsSeek( xFilial("SFP")+cFil+SD1->D1_SERIORI+"6" ) )
								If lSer3 .And. !Empty(SFP->FP_YSERIE)
									If Len( Alltrim(SFP->FP_YSERIE) ) > 4
										cTipDoc := "12"
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					Do While SD1->(!Eof()) .And. ALLTRIM(SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA) == ALLTRIM(cNFiscal+cSerie+cClifor+cLoja)
						If !Empty(SD1->D1_NFORI+SD1->D1_SERIORI)
							cOriSer  := SD1->D1_SERIORI
							cNumDoc := SD1->D1_NFORI

							_jAlias := getNextAlias()
							xqry := "SELECT F2_EMISSAO,F2_TPDOC"
							xqry += "  FROM "+RetSQLTab('SF2')
							xqry += " WHERE F2_DOC='"+SD1->D1_NFORI+"'"
							xqry += "   AND F2_SERIE='"+SD1->D1_SERIORI+"'"
							xqry += "   AND F2_CLIENTE='"+SD1->D1_FORNECE+"'"
							xqry += "   AND F2_LOJA='"+SD1->D1_LOJA+"'"

							dbUseArea( .T., "TOPCONN", TcGenQry( ,, xqry ), _jAlias,.T.,.T.)

							if (_jAlias)->( !eof() )
								dEmiss  := stod((_jAlias)->F2_EMISSAO)
								cTipDoc := (_jAlias)->F2_TPDOC
							endif
							(_jAlias)->( dbCloseArea() )
							exit
						Endif
						SD1->(DbSkip())
					EndDo
				EndIf

			EndIf

			//25 - Código  de la Moneda (Tabla 4)
			cLin += xFINDMO1(cFil,cNFiscal,cSerie,cClifor,cLoja,cEspecie)
			cLin += cSep

			//26 - Tipo de cambio (5)
			if nTxMoeda<=0
				nTxMoeda := yFINDMO2(cFil,cNFiscal,cSerie,cClifor,cLoja,cEspecie)		// SISTHEL - 24/08/2018
			endif
			cLin += AllTrim(StrTran(Transform(nTxMoeda,"@E 999999999.999"),",","."))
			cLin += cSep

			//27 - Fecha de emisión del comprobante de pago o documento original que se modifica (6)
			//		o documento referencial al documento que sustenta el crédito fiscal
			If !Empty(dEmiss)
				cLin += SubStr(DTOC(dEmiss),1,6)+SubStr(DTOS(dEmiss),1,4)
			Else
				cLin += ""
			EndIf
			cLin += cSep

			//28 - Tipo del comprobante de pago que se modifica (6)
			If AllTrim(cTpDoc) $ "06|07|08|87|88" .And. ALLTRIM( cCGC)<>'Anulado'
				If !Empty(cTipDoc)
					cLin += AllTrim(cTipDoc)
				Else
					cLin += AllTrim(cTipDoc)
				EndIf
			Else
				cLin += ""
			EndIf
			cLin += cSep

			//29 - Número de serie del comprobante de pago que se modifica (6) o Código de la Dependencia Aduanera
			If AllTrim(cTpDoc) $ "06|07|08|87|88" .And. ALLTRIM(cCGC)<>'Anulado'
				// ----------------------------------------------------------------------------------- //
				// Adicionado por SISTHEL para impresion de la serie 2 ( factura electrocnica - Peru ) //
				// ----------------------------------------------------------------------------------- //
				lTemSFP := .f.
				SFP->( dbSetOrder(5) )	//FP_FILIAL, FP_FILUSO, FP_SERIE, FP_ESPECIE, R_E_C_N_O_, D_E_L_E_T_

				If SFP->( MsSeek( xFilial("SFP")+cFil+cOriser+"1" ) )
					If lSer3 .And. !Empty(SFP->FP_YSERIE)
							cOriSer := Alltrim(SFP->FP_YSERIE)
						lTemSFP := .t.
					EndIf
					if lSerie2SFP
						if !empty(SFP->FP_SERIE2)
								cOriSer := Alltrim(SFP->FP_SERIE2)
							lTemSFP := .t.
						endif
					endif
				endif

				if !lTemSFP
					If SFP->( MsSeek( xFilial("SFP")+cFil+cOriser+"6" ) )
						If lSer3 .And. !Empty(SFP->FP_YSERIE)
							cOriSer := Alltrim(SFP->FP_YSERIE)
							lTemSFP := .t.
						EndIf
					endif
					if lSerie2SFP
						if !empty(SFP->FP_SERIE2)
							cOriSer := Alltrim(SFP->FP_SERIE2)
							lTemSFP := .t.
						endif
					endif
				EndIf

				if !lTemSFP
					If SFP->( MsSeek( xFilial("SFP")+cFil+cOriser+"3" ) )
						If lSer3 .And. !Empty(SFP->FP_YSERIE)
								cOriSer := Alltrim(SFP->FP_YSERIE)
							lTemSFP := .t.
						EndIf
					endif
					if lSerie2SFP
						if !empty(SFP->FP_SERIE2)
								cOriSer := Alltrim(SFP->FP_SERIE2)
							lTemSFP := .t.
						endif
					endif
				EndIf

				if !lTemSFP
					If SFP->( MsSeek( xFilial("SFP")+cFil+cOriser+"2" ) )
						If lSer3 .And. !Empty(SFP->FP_YSERIE)
								cOriSer := Alltrim(SFP->FP_YSERIE)
							lTemSFP := .t.
						EndIf
					endif
					if lSerie2SFP
						if !empty(SFP->FP_SERIE2)
								cOriser := Alltrim(SFP->FP_SERIE2)
							lTemSFP := .t.
						endif
					endif
				EndIf

				If Len(cOriSer)<=3
					cOriSer := Replicate("0",4-Len(cOriSer))+cOriSer
				EndIf

				// -------------------------------------------------------------------------[ Fim ]-- //
				If !Empty(cOriSer)
					cSerF := ""
					cSer  := Alltrim(cOriSer)
					nTot1 := Len(cSer)+1
					For nTot1 := Len(cSer)+1 to 4
						cSerF+="0"
					Next
					cSerF += cOriSer
					cLin += AllTrim(cSerF)
				Else
					cLin += "-"
				EndIf

			else
				cLin += ""
			EndIf
			cLin += cSep

			//30 - Número del comprobante de pago que se modifica (6) o Número de la DUA, de corresponder
			If AllTrim(cTpDoc) $ "06|07|08|87|88" .And. ALLTRIM( cCGC)<>'Anulado'
				If !Empty(cNumDoc)
					cLin += Right(AllTrim(cNumDoc),8)
				Else
					cLin += ""
				EndIf
			Else
				cLin += ""
			EndIF
			cLin += cSep

			//31 - Identificación del Contrato o del proyecto en el caso de los Operadores de las sociedades
			//     irregulares, consorcios, joint ventures u otras formas de contratos de colaboración empresarial,
			//     que no lleven contabilidad independiente.
			cLin += ""
			cLin += cSep

			//32 - Error tipo 1: inconsistencia en el tipo de cambio
			cLin += ""
			cLin += cSep

			//33 - Indicador de Comprobantes de pago cancelados con medios de pago
			cLin += ""
			cLin += cSep

			//34 - Estado que identifica la oportunidad de la anotación o indicación si ésta corresponde a alguna
			//     de las situaciones previstas en el inciso e del artículo 8°
			IF SubStr(DTOS(aParams[1]),1,6)==SubStr(DTOS(dEmissao),1,6)
				IF ALLTRIM( cCGC)=='Anulado'
					cLin += "2"
				Else
			   		cLin += "1"
			   	EndIf
			ELSEIF dEmissao >= aParams[1] - 365
				IF ALLTRIM( cCGC)=='Anulado'
					cLin += "2"
				Else
			   		cLin += "8"
			   	EndIf
			ENDIF
			cLin += cSep

			cLin += chr(13)+chr(10)
			fWrite(nHdl,cLin)
			nValorC := 0
		EndIf
	EndDo
	fClose(nHdl)
EndIf

If !lRet
	If aParams[6] == 2
		ApMsgStop(STR0071)//"Ocurrió un error al crear el archivo."
	EndIf
EndIf

FISR011ET() //BORRA TABLAS TEMPORALES

Return


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BuscaCorre³ Autor ³ Totvs                 ³ Data | Jan/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca Correlativo Caso em Branco                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BuscaCorre(cFil,cDoc,cSer,cForn,cLoj,dEmis,cEsp)
Local cSql003	:= ''
Local nRecno1	:= 0
Local cNodia	:= "  "
Local aArea		:= GetArea()
Local nTamDoc	:= 0
Local ntamcDoc	:= 0
Local cAliasCor	:= ""

If Alltrim(cEsp) $ "NDP|NDE|NCI|NCC"
	cSql003:= " SELECT MAX(R_E_C_N_O_) RECNO1  "
	cSql003+= " FROM "+ RetSqlName("SF1") + " SF1 "
	cSql003+= " WHERE SF1.F1_FILIAL  = '"+cFil+"' "
	cSql003+= "   AND SF1.F1_DOC     = '"+cDoc+"' "
	cSql003+= "   AND SF1.F1_SERIE   = '"+cSer+"' "
	cSql003+= "   AND SF1.F1_FORNECE = '"+cForn+"' "
	cSql003+= "   AND SF1.F1_LOJA    = '"+cLoj+"' "
	cSql003+= "   AND SF1.F1_NODIA<>'' "
//No se pone el campo D_e_l_e_t_e a proposito, pues es necesario encontrar los documentos cuando son borrados
else
	cSql003:= " SELECT MAX(R_E_C_N_O_) RECNO1  "
	cSql003+= " FROM "+ RetSqlName("SF2") + " SF2 "
	cSql003+= " WHERE SF2.F2_FILIAL  = '"+cFil+"' "
	cSql003+= "   AND SF2.F2_DOC     = '"+cDoc+"' "
	cSql003+= "   AND SF2.F2_SERIE   = '"+cSer+"' "
	cSql003+= "   AND SF2.F2_CLIENTE = '"+cForn+"' "
	cSql003+= "   AND SF2.F2_LOJA    = '"+cLoj+"' "
	cSql003+= "   AND SF2.F2_NODIA<>''"
//No se pone el campo D_e_l_e_t_e a proposito, pues es necesario encontrar los documentos cuando son borrados
endif
cAliasCor := GetNextAlias()
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql003 ), cAliasCor,.T.,.T.)
(cAliasCor)->(dBGotop())
IF (cAliasCor)->(! EOF())
	nRecno1:=(cAliasCor)->RECNO1
	if nRecno1 > 0
		(cAliasCor)->(DbCLoseArea())
		cSql003:= " SELECT CT2_NODIA  "
		cSql003+= " FROM "+ RetSqlName("CV3") + " CV3, "+ RetSqlName("CT2") + " CT2 "
		cSql003+= " WHERE CV3.CV3_FILIAL = '"+ cFil+"' "
		If Alltrim(cEsp) $ "NDP|NDE|NCI|NCC"
			cSql003+= "   AND CV3.CV3_TABORI  = 'SF1' "
		else
			cSql003+= "   AND CV3.CV3_TABORI  = 'SF2' "
		endif
		cSql003+= "   AND CV3.CV3_RECORI  = '"+ALLTRIM(str(nRecno1,17))+"' "
		cSql003+= "   AND CV3.D_E_L_E_T_ = ' ' "
		cSql003+= "   AND CV3.CV3_FILIAL  = CT2.CT2_FILIAL  "
		cSql003+= "   AND CV3.CV3_DTSEQ   = CT2.CT2_DATA  "
		cSql003+= "   AND CV3.CV3_SEQUEN  = CT2.CT2_SEQUEN  "
		cSql003+= "   AND CT2.CT2_NODIA <> '        '  "
		cSql003+= "   AND CT2.D_E_L_E_T_ = ' ' "
		cAliasCor := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql003 ), cAliasCor,.T.,.T.)
		(cAliasCor)->(dBGotop())
		IF (cAliasCor)->(!EOF()) .AND. !Empty((cAliasCor)->CT2_NODIA)
			cNodia:=(cAliasCor)->CT2_NODIA
		ENDIF
	endif
ENDIF
RestArea(aArea)
(cAliasCor)->(DbCLoseArea())
IF EMPTY(cNodia)
	nTamDoc:=(TamSX3("F2_NODIA")[1]-4)
	ntamcDoc:=(Len(ALLTRIM(cDoc)) - nTamDoc + 1)

	cNodia :=space(10)
ENDIF
Return(cNodia)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xFINDMO1  ºAutor  ³Microsiga           º Data ³  07/13/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna descricao da moeda                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xFINDMO1(cFil, cDoc, cSer, cForn, cLoj, cEspec, nRet)
Local cMoeda   := Space(03)
Local nMoeda   := 1

Local aArea    := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSF2 := SF2->(GetArea())
Local aAreaSX5 := SX4->(GetArea())


If Alltrim(cEspec) $ "NDP|NDE|NCI|NCC"
	SF1->(DbSetOrder(1)) //--F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->(MsSeek(cFil+cDoc+cSer+cForn+cLoj))
		nMoeda := SF1->F1_MOEDA
	EndIf

Else
	SF2->(DbSetOrder(1)) //--F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(MsSeek(cFil+cDoc+cSer+cForn+cLoj))
		nMoeda := SF2->F2_MOEDA
	EndIf

EndIf

SX5->(DbSetOrder(1)) //--X5_FILIAL+X5_TABELA+X5_CHAVE
If SX5->(MsSeek(xFilial('SX5')+'XQ'+AllTrim(Str(nMoeda))))
	cMoeda := AllTrim(SX5->X5_DESCSPA)
EndIf

//--RESTAURA AMBIENTE:
RestArea(aArea)
RestArea(aAreaSF1)
RestArea(aAreaSF2)
RestArea(aAreaSX5)

Return(cMoeda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³yFINDMO2  ºAutor  ³Microsiga           ºFecha ³  08/24/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna taxa da moeda                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function yFINDMO2(cFil, cDoc, cSer, cForn, cLoj, cEspec)
Local nMoeda   := 1

Local aArea    := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSF2 := SF2->(GetArea())

If Alltrim(cEspec) $ "NDP|NDE|NCI|NCC"
	SF1->(DbSetOrder(1)) //--F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->(MsSeek(cFil+cDoc+cSer+cForn+cLoj))
		nMoeda := SF1->F1_TXMOEDA
	EndIf

Else
	SF2->(DbSetOrder(1)) //--F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(MsSeek(cFil+cDoc+cSer+cForn+cLoj))
		nMoeda := SF2->F2_TXMOEDA
	EndIf

EndIf

//--RESTAURA AMBIENTE
RestArea(aArea)
RestArea(aAreaSF1)
RestArea(aAreaSF2)

Return(nMoeda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZFISR011  ºAutor  ³Microsiga           ºFecha ³  09/10/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function getLinCT2(cSegofi,nVal,nMda,lncc,cXFil)

	local cSql		:= ""
	local cMoeda	:= strzero(nMda,2)
	local cVlRed	:= alltrim(str(Round(nVal,0)))
	local _cAlias	:= getNextAlias()
	local bLinha	:= "000000000"

	cSql := " SELECT CT2_LINHA,CT2_CREDIT,CT2_DEBITO,ROUND(CT2_VALOR,0) CT2_VALOR"
	cSql += "   FROM "+ RetSqlName("CT2")
	cSql += "  WHERE CT2_FILIAL = '"+cXFil+"'"
	cSql += "    AND CT2_MOEDLC='"+cMoeda+"'"
	if !lncc
		cSql += "    AND ROUND(CT2_VALOR,0)="+cVlRed
	endif
	cSql += "    AND CT2_SEGOFI='"+cSegofi+"'"
	cSql += "    AND D_E_L_E_T_ <> '*' "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql ), _cAlias,.T.,.T.)

	If (_cAlias)->( !eof() )
		While (_cAlias)->( !eof() )

			if left((_cAlias)->CT2_DEBITO,2)=="12"
				bLinha := strzero(val((_cAlias)->CT2_LINHA),9)
				exit
			elseif left((_cAlias)->CT2_CREDIT,2)=="12"
				bLinha := strzero(val((_cAlias)->CT2_LINHA),9)
				exit
			endif
			(_cAlias)->( dbSkip() )
		End
	EndIf

	(_cAlias)->( dbCloseArea() )

Return(bLinha)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZFISR011  ºAutor  ³Microsiga           ºFecha ³  09/10/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xBusNFAnul(cFil,cDoc,cSer,cCli,cLoj,nTab)

	Local aArea		:= GetArea()
	local _cAlias	:= GetNextAlias()
	local cSql004	:= ""
	local aret		:= {}

	if nTab==2
		cSql004:= " SELECT F2_NODIA,F2_VALBRUT,F2_MOEDA  "
		cSql004+= " FROM "+ RetSqlName("SF2") + " SF2 "
		cSql004+= " WHERE SF2.F2_FILIAL  = '"+cFil+"' "
		cSql004+= "   AND SF2.F2_DOC     = '"+cDoc+"' "
		cSql004+= "   AND SF2.F2_SERIE   = '"+cSer+"' "
		cSql004+= "   AND SF2.F2_CLIENTE = '"+cCli+"' "
		cSql004+= "   AND SF2.F2_LOJA    = '"+cLoj+"' "
		cSql004+= "   AND SF2.D_E_L_E_T_ = '*' "
		cSql004+= "   AND SF2.R_E_C_N_O_ > 0"

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql004 ), _cAlias,.T.,.T.)
		IF (_cAlias)->( !EOF() )
		   Aadd( aret,(_cAlias)->F2_NODIA )
		   Aadd( aret,(_cAlias)->F2_VALBRUT )
		   Aadd( aret,(_cAlias)->F2_MOEDA )
		ENDIF
	else
		cSql004:= " SELECT F1_NODIA,F1_VALBRUT,F1_MOEDA  "
		cSql004+= " FROM "+ RetSqlName("SF1") + " SF1 "
		cSql004+= " WHERE SF1.F1_FILIAL  = '"+cFil+"' "
		cSql004+= "   AND SF1.F1_DOC     = '"+cDoc+"' "
		cSql004+= "   AND SF1.F1_SERIE   = '"+cSer+"' "
		cSql004+= "   AND SF1.F1_FORNECE = '"+cCli+"' "
		cSql004+= "   AND SF1.F1_LOJA    = '"+cLoj+"' "
		cSql004+= "   AND SF1.D_E_L_E_T_ = '*' "
		cSql004+= "   AND SF1.R_E_C_N_O_ > 0"

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql004 ), _cAlias,.T.,.T.)
		IF (_cAlias)->( !EOF() )
		   Aadd( aret,(_cAlias)->F1_NODIA )
		   Aadd( aret,(_cAlias)->F1_VALBRUT )
		   Aadd( aret,(_cAlias)->F1_MOEDA )
		ENDIF
	endif

	(_cAlias)->( dbCloseArea() )

	RestArea(aArea)

Return(aret)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FISR011Qry ³ Autor ³ V. RASPA                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Queries utilizadas no reltoario                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FISR011Qry(aFiliais, aParams, lMultiThread)
Local cQuery    := ''
Local cAliasQry := ''
Local cFiliais  := ''
Local lSerie2   := SF1->(ColumnPos("F1_SERIE2")) > 0 .And. SF2->(ColumnPos("F2_SERIE2")) > 0 .And. SF3->(ColumnPos("F3_SERIE2")) > 0 .And. GetNewPar("MV_LSERIE2", .F.)
Local lSerOri   := SF1->(ColumnPos("F1_SERORI")) > 0 .And. SF2->(ColumnPos("F2_SERORI")) > 0 .And. SF3->(ColumnPos("F3_SERORI")) > 0
Local lCpDoc    := SF3->(ColumnPos("F3_TPDOC")) > 0
Local lCodSF2   := SF2->(ColumnPos("F2_TPDOC")) > 0
Local cICBPER   := ""

Default lMultiThread := .F.

//-- Trata filiais selecionadas...
aEval(aFiliais, {|e| If(e[1], cFiliais += e[2] + '|', NIL)})
cFiliais += cFiliais + Space(TamSX3("F3_FILIAL")[1]) + '|'

// Campo del nuevo impuesto ICBPER
If lICBPER
	SFB->( dbGoTop() )
	Do While !SFB->( EoF() )
		If "M100ICB" $ SFB->FB_FORMENT .And. "M460ICB" $ Upper(SFB->FB_FORMSAI)
			cICBPER := SFB->FB_CPOLVRO
			Exit
		EndIf

		SFB->( DbSkip() )
	EndDo

	lICBPER := ( SF3->( ColumnPos("F3_VALIMP"+cICBPER) ) > 0 )
EndIf

// -------------------------------------------
// QUERY P/ CALCULAR O CAMPO "OUTROS TRIBUTOS"
// -------------------------------------------
cQuery := "SELECT F3_FILIAL,F3_ESPECIE,F3_EMISSAO,E1_VENCTO,CCL_CODGOV,"
If lSerie2
	cQuery += "F3_SERIE2,"
EndIf
cQuery += "F3_SERORI,F3_TPDOC,F3_SERIE,F3_NFISCAL,F3_CLIEFOR,F3_LOJA,F3_TIPO,A1_NOME,A1_EST,F2_TXMOEDA,F2_MOEDA,F2_NODIA,A1_TIPDOC,A1_CGC,A1_PFISICA,"
cQuery += "			SUM(EXPORTACAO) EXPORTACAO,SUM(F3_BASIMP1) F3_BASIMP1,SUM(F3_BASIMP2) F3_BASIMP2,SUM(EXONERADA) EXONERADA,SUM(INAFECTA) INAFECTA,SUM(OTROSTRIB) AS OTROSTRIB,SUM(F3_VALIMP2) F3_VALIMP2,SUM(F3_VALIMP1) F3_VALIMP1,SUM(F3_VALCONT) F3_VALCONT"
cQuery += ",SUM(F3_VALICB) F3_VALICB "
cQuery += "  FROM ("
cQuery += "SELECT DISTINCT "
cQuery += "       SF3.F3_FILIAL, "
cQuery += "       SF3.F3_ESPECIE, "
cQuery += "       SF3.F3_EMISSAO, "
cQuery += "       CASE WHEN SF3.F3_DTCANC =  ' ' THEN SE1.E1_VENCTO ELSE 'Anulado       ' END AS E1_VENCTO,  "
If !lCodSF2
	cQuery += " CCL.CCL_CODGOV, "
Else
    cQuery += " CASE WHEN SF3.F3_DTCANC = ' ' AND SF3.F3_TIPO = 'D' THEN F1_TPDOC
    cQuery += "      WHEN SF3.F3_DTCANC = ' ' AND SF3.F3_TIPO = 'N' THEN F2_TPDOC
    cQuery += "      WHEN SF3.F3_DTCANC = ' ' AND SF3.F3_TIPO = 'C' THEN F2_TPDOC
    cQuery += "      ELSE '01' END AS CCL_CODGOV, "
EndIf
if lSerie2
	cQuery += " CASE WHEN SF3.F3_SERIE2=' ' AND SF3.F3_TIPO = 'D' THEN F1_SERIE2
	cQuery += "      WHEN SF3.F3_SERIE2=' ' AND SF3.F3_TIPO = 'N' THEN F2_SERIE2
	cQuery += "      ELSE SF3.F3_SERIE2 END AS F3_SERIE2, "
endif
cQuery += If(lSerOri, " SF3.F3_SERORI, ", "")
cQuery += If(lCpDoc, " SF3.F3_TPDOC, ", "")
cQuery += "       SF3.F3_SERIE, "
cQuery += "       SF3.F3_NFISCAL, "
cQuery += "       SF3.F3_CLIEFOR, "
cQuery += "       SF3.F3_LOJA, "
cQuery += "       SF3.F3_TIPO, "
cQuery += "       SA1.A1_NOME, "
cQuery += "       SA1.A1_EST, "

cQuery += "       CASE WHEN SF3.F3_DTCANC = ' '  AND F3_ESPECIE='NCC' THEN SF1.F1_NODIA ELSE SF2.F2_NODIA END AS F2_NODIA, "
cQuery += "       CASE WHEN SF3.F3_DTCANC = ' ' THEN SA1.A1_TIPDOC ELSE SA1.A1_TIPDOC END AS A1_TIPDOC, "
cQuery += "       CASE WHEN SF3.F3_DTCANC = ' ' THEN SA1.A1_CGC ELSE 'Anulado       ' END AS A1_CGC, "
cQuery += "       CASE WHEN SF3.F3_DTCANC = ' ' THEN SA1.A1_PFISICA ELSE 'Anulado       ' END AS A1_PFISICA, "
cQuery += "       CASE WHEN (F3_DTCANC = ' ' AND A1_EST = 'EX' AND F4_CALCIGV <> '1') THEN SUM(F3_VALCONT) ELSE 0 END AS EXPORTACAO, "
cQuery += "       CASE WHEN F3_DTCANC = ' '  AND ((A1_EST<>'EX' AND F4_CALCIGV = '1') OR(A1_EST='EX' AND F4_CALCIGV <> '1')) THEN SUM(F3_BASIMP1) ELSE 0 END AS F3_BASIMP1, "
cQuery += "       CASE WHEN F3_DTCANC = ' '  AND ((A1_EST<>'EX' AND F4_CALCIGV = '1') OR(A1_EST='EX' AND F4_CALCIGV <> '1')) THEN SUM(F3_BASIMP2) ELSE 0 END AS F3_BASIMP2, "

cQuery += "       CASE WHEN F3_DTCANC = ' '  AND F4_CALCIGV = '2'  THEN SUM(F3_EXENTAS) ELSE 0 END AS EXONERADA, "
cQuery += "       CASE WHEN F3_DTCANC = ' '  AND F4_CALCIGV = '3'  THEN SUM(F3_EXENTAS) ELSE 0 END AS INAFECTA, "
cQuery += "       CASE WHEN F3_DTCANC = ' '  AND F4_CALCIGV = '4'  THEN SUM(F3_EXENTAS) ELSE 0 END AS OTROSTRIB, "
cQuery += "       CASE WHEN SF3.F3_DTCANC = ' ' THEN SUM(SF3.F3_VALIMP2) ELSE 0  END AS F3_VALIMP2, "
cQuery += "       CASE WHEN SF3.F3_DTCANC = ' ' THEN SUM(SF3.F3_VALIMP1) ELSE 0  END AS F3_VALIMP1, "
cQuery += "       CASE WHEN SF3.F3_DTCANC = ' ' THEN SUM(SF3.F3_VALCONT) ELSE 0  END AS F3_VALCONT, "
cQuery += "        CASE WHEN F3_DTCANC = ' '  AND F3_ESPECIE='NCC' THEN F1_TXMOEDA     ELSE F2_TXMOEDA  END AS F2_TXMOEDA, "
cQuery += "        CASE WHEN F3_DTCANC = ' '  AND F3_ESPECIE='NCC' THEN F1_MOEDA       ELSE F2_MOEDA  END AS F2_MOEDA "

If lICBPER
	cQuery += "        , CASE WHEN F3_DTCANC = ' ' THEN SUM(F3_VALIMP" + cICBPER + ") ELSE 0  END AS F3_VALICB "
Else
	cQuery += "        , 0 AS F3_VALICB "
EndIf

cQuery += "  FROM " + RetSQLTab('SF3')

cQuery += "  LEFT JOIN " + RetSQLTab('SE1')
cQuery += "    ON SE1.E1_FILIAL = SF3.F3_FILIAL "
cQuery += "   AND SE1.E1_EMISSAO = SF3.F3_ENTRADA "
cQuery += "   AND SE1.E1_NUM = SF3.F3_NFISCAL "
cQuery += "   AND SE1.E1_PREFIXO = SF3.F3_SERIE "
cQuery += "   AND SE1.E1_CLIENTE = SF3.F3_CLIEFOR "
cQuery += "   AND SE1.E1_LOJA = SF3.F3_LOJA "
cQuery += "   AND SE1.E1_TIPO IN ('NF','NCC','NDC')  "
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

If !lCodSF2
	cQuery += "  LEFT JOIN " + RetSQLTab('CCM')
	cQuery += "    ON CCM.CCM_COD42 = SF3.F3_ESPECIE "
	cQuery += "   AND CCM_FILIAL = '" + xFilial("CCM") + "' "
	cQuery += "   AND CCM.D_E_L_E_T_ <> '*' "

	cQuery += " LEFT JOIN " + RetSQLTab('CCL')
	cQuery += "   ON CCL.CCL_CODIGO = CCM_CODGOV "
	cQuery += "  AND CCL.CCL_FILIAL = '" + xFilial("CCL") + "' "
	cQuery += "  AND CCL.D_E_L_E_T_ = ' ' "
Endif

cQuery += "  LEFT JOIN " + RetSQLTab('SA1')
cQuery += "    ON SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += "   AND SA1.A1_LOJA = SF3.F3_LOJA "
cQuery += "   AND SA1.A1_COD = SF3.F3_CLIEFOR "
cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "

cQuery += "  LEFT JOIN " + RetSQLTab('SF4')
cQuery += "    ON SF4.F4_FILIAL = '" + xFilial("SF4") + "'"
cQuery += "   AND SF4.F4_CODIGO = SF3.F3_TES"
cQuery += "   AND SF4.D_E_L_E_T_ = ' ' "

cQuery += "  LEFT JOIN " + RetSQLTab('SF2')
cQuery += "    ON SF2.F2_FILIAL = SF3.F3_FILIAL "
cQuery += "   AND SF2.F2_DOC = SF3.F3_NFISCAL "
cQuery += "   AND SF2.F2_SERIE = SF3.F3_SERIE "
cQuery += "   AND SF2.F2_ESPECIE = SF3.F3_ESPECIE "
cQuery += "   AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR "
cQuery += "   AND SF2.F2_LOJA = SF3.F3_LOJA "
cQuery += "   AND SF2.D_E_L_E_T_ = ' ' "

cQuery += "  LEFT JOIN " + RetSQLTab('SF1')
cQuery += "    ON SF1.F1_FILIAL = SF3.F3_FILIAL "
cQuery += "   AND SF1.F1_DOC = SF3.F3_NFISCAL "
cQuery += "   AND SF1.F1_SERIE = SF3.F3_SERIE "
cQuery += "   AND SF1.F1_ESPECIE = SF3.F3_ESPECIE "
cQuery += "   AND SF1.F1_FORNECE = SF3.F3_CLIEFOR "
cQuery += "   AND SF1.F1_LOJA = SF3.F3_LOJA "
cQuery += "   AND SF1.D_E_L_E_T_ = ' ' "

cQuery += " WHERE SF3.F3_FILIAL IN " +  FormatIn(cFiliais, '|')
cQuery += "   AND SF3.F3_ENTRADA BETWEEN '" + DtoS(aParams[1]) + "' AND '" + DtoS(aParams[2]) + "' "
If !lCodSF2
	cQuery += " AND ((SF3.F3_TIPOMOV = 'V' AND SF3.F3_ESPECIE = 'NF') OR (SF3.F3_TIPOMOV = 'C' AND SF3.F3_FORMUL = 'S' AND SF3.F3_ESPECIE <> 'NF') OR (SF3.F3_TIPOMOV = 'V'  AND SF3.F3_FORMUL = 'S' AND SF3.F3_ESPECIE <> 'NF'))"
Else
	cQuery += " AND ((SF3.F3_TIPOMOV = 'V') OR (SF3.F3_TIPOMOV = 'C' AND SF3.F3_FORMUL = 'S') OR (SF3.F3_TIPOMOV = 'V' AND SF3.F3_FORMUL = 'S')) "
Endif
cQuery += "   AND SF3.D_E_L_E_T_ = ' ' "

cQuery += " GROUP BY F1_NODIA,F2_NODIA, "
cQuery += "       F3_EMISSAO, "
cQuery += "       F3_NFISCAL, "
cQuery += "       F3_FILIAL, "
cQuery += "       F3_SERIE, "
if lSerie2
	cQuery += " F1_SERIE2, "
	cQuery += " F2_SERIE2, "
	cQuery += " F3_SERIE2, "
endif
cQuery += If(lSerOri, " F3_SERORI, ", "")
cQuery += "       F3_CLIEFOR,"
cQuery += "       F3_LOJA,"
cQuery += "       F3_DTCANC,"
cQuery += "       E1_VENCTO,"

If !lCodSF2
	cQuery += "       CCL_CODGOV, "
Else
	cQuery += "       F2_TPDOC, "
	cQuery += "       F1_TPDOC, "
Endif

cQuery += "      A1_TIPDOC, "
cQuery += "      A1_CGC, "
cQuery += "      A1_PFISICA, "
cQuery += "      A1_NOME, "
cQuery += "      A1_EST, "
cQuery += "      F2_TXMOEDA, "
cQuery += "      F4_CALCIGV, "
cQuery += "      F3_ESPECIE, "
cQuery += "      F3_TIPO, "
cQuery += "       F1_TXMOEDA,"
cQuery += "       F1_MOEDA, "
cQuery += "       F2_MOEDA "
cQuery += If(lCpDoc, " ,F3_TPDOC ", "")
cQuery += " ) A"
cQuery += " GROUP BY F3_FILIAL,F3_ESPECIE,F3_EMISSAO,E1_VENCTO,CCL_CODGOV,"
If lSerie2
	cQuery += "F3_SERIE2,"
EndIf
cQuery += "F3_SERORI,F3_TPDOC,F3_SERIE,F3_NFISCAL,F3_CLIEFOR,F3_LOJA,F3_TIPO,A1_NOME,A1_EST,F2_TXMOEDA,F2_MOEDA,F2_NODIA,A1_TIPDOC,A1_CGC,A1_PFISICA"
cQuery += " ORDER BY CCL_CODGOV, F3_SERIE, F3_NFISCAL"

cQuery    := ChangeQuery(cQuery)

// -----------------------------------------------
// PROCESSA QUERY:
// -----------------------------------------------

cAliasQry := GetNextAlias()
If !lMultiThread
	MsgRun(STR0074, STR0075, {|| DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)}) //'Por favor espere...' - 'Selección de registros...'
Else
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
EndIf

// -----------------------------------------------
// COMPATIBILIZA CAMPOS:
// -----------------------------------------------
TCSetField(cAliasQry, "F3_EMISSAO", "D")
TCSetField(cAliasQry, "E1_VENCTO", "D")
TCSetField(cAliasQry, "F3_BASIMP1", "N", 14, 2)
TCSetField(cAliasQry, "F3_BASIMP2", "N", 14, 2)
TCSetField(cAliasQry, "F3_VALIMP1", "N", 14, 2)
TCSetField(cAliasQry, "F3_VALIMP2", "N", 14, 2)
TCSetField(cAliasQry, "F3_VALCONT", "N", 14, 2)
TCSetField(cAliasQry, "F3_VALICB",  "N", 14, 2)

Return(cAliasQry)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FISR011Trib³ Autor ³ V. RASPA                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta arquivo temporario p/ apurar "Outros Tributos"         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FISR011Trib(aFiliais, aParams)
Local cQuery   := ''
Local aKey     := {"F3_NFISCAL","F3_SERIE","F3_CLIEFOR","F3_LOJA"}
Local cFiliais	:= ''
Local lSerie2	:= SF1->(ColumnPos("F1_SERIE2")) > 0 .And. SF2->(ColumnPos("F2_SERIE2")) > 0 .And. SF3->(ColumnPos("F3_SERIE2")) > 0 .And. GetNewPar("MV_LSERIE2", .F.)
Local lSerOri	:= SF1->(ColumnPos("F1_SERORI")) > 0 .And. SF2->(ColumnPos("F2_SERORI")) > 0 .And. SF3->(ColumnPos("F3_SERORI")) > 0
Local cTmpTri	:= CriaTrab(Nil,.F.)

//-- Trata filiais selecionadas...

aEval(aFiliais, {|e| If(e[1], cFiliais += e[2] + '|', NIL)})
cFiliais += cFiliais + Space(TamSX3("F3_FILIAL")[1]) + '|'

// --------------------------------------------------
// MONTA QUERY P/ PROCESSAMENTO
// --------------------------------------------------
cQuery := "SELECT DISTINCT CASE WHEN SF3.F3_DTCANC = ' ' THEN SD2.D2_TOTAL ELSE 0 END AS TRIBUTO, "
cQuery += "       SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA "

cQuery += "  FROM " + RetSQLTab('SF3')

cQuery += "  LEFT JOIN " + RetSQLTab('SD2')
cQuery += "    ON SD2.D2_DOC = SF3.F3_NFISCAL "
cQuery += "   AND SD2.D2_SERIE = SF3.F3_SERIE "
cQuery += "   AND SD2.D2_CLIENTE = SF3.F3_CLIEFOR "
cQuery += "   AND SD2.D2_LOJA = SF3.F3_LOJA "
cQuery += "   AND SD2.D2_ESPECIE = SF3.F3_ESPECIE "
cQuery += "   AND SD2.D2_FILIAL = SF3.F3_FILIAL "
cQuery += "   AND SD2.D2_TES = SF3.F3_TES "
cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "

cQuery += " WHERE SF3.F3_FILIAL IN " +  FormatIn(cFiliais, '|')
cQuery += "   AND SF3.F3_EMISSAO BETWEEN '" + DtoS(aParams[1]) + "' AND '" + DtoS(aParams[2]) + "' "

cQuery += "   AND SF3.D_E_L_E_T_  =  ' ' "
cQuery += "   AND SF3.F3_TIPOMOV = 'V'"
cQuery += "   AND SF3.F3_TPDOC <> ''"
cQuery += "   AND ( SF3.F3_VALIMP1 = 0 AND SF3.F3_VALIMP2 = 0 )"

cQuery += " GROUP BY SF3.F3_NFISCAL"
cQuery += " ,        SF3.F3_DTCANC"
cQuery += " ,        SF3.F3_SERIE"
cQuery += If(lSerie2, " , SF3.F3_SERIE2", "")
cQuery += If(lSerOri, " , SF3.F3_SERORI", "")
cQuery += " ,        SF3.F3_CLIEFOR"
cQuery += " ,        SF3.F3_LOJA"
cQuery += " ,        SD2.D2_TOTAL"
cQuery += " ORDER BY SF3.F3_NFISCAL"

TcQuery cQuery New Alias "TRI"

TCSetField("TRI","D2_TOTAL","N",14,2)
TCSetField("TRI","TRIBUTO","N",14,2)

// ---------------------------------------
// GERA ARQUIVO TEMPORARIO
// ---------------------------------------

FISR011CT(cTmpTri,aKey)

Return(cTmpTri)

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BuscaTpDoc³ Autor ³ Totvs                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca Tipo de documento de nota cancelada                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BuscaTpDoc(cFil, cDoc, cSerie, cClieFor, cLoja)
Local cTpDoc    := Space(02)
Local cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry
	SELECT F2_TPDOC
	  FROM %Table:SF2% SF2
	 WHERE SF2.F2_FILIAL = %Exp:cFil%
	   AND SF2.F2_DOC = %Exp:cDoc%
	   AND SF2.F2_SERIE = %Exp:cSerie%
	   AND SF2.F2_CLIENTE = %Exp:cClieFor%
	   AND SF2.F2_LOJA = %Exp:cLoja%
EndSQL

If !(cAliasQry)->(Eof())
	cTpDoc := (cAliasQry)->F2_TPDOC
EndIf

(cAliasQry)->(DbCloseArea())

Return(cTpDoc)

Static Function f3Param()

cPath := cGetFile( STR0076 + " | ", STR0076, NIL , "" , .F. , GETF_LOCALHARD + GETF_RETDIRECTORY ) //"Seleccionar directorio"

Return .T.

Static Function f3RetParam()
Return cPath
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xNCCAnul  ºAutor  ³Percy Arias,SISTHEL º Data ³  07/13/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Se creo una busqueda directo en la tabla SF1 de la NCC     º±±
±±º          ³ Anulada, pues en la SF3 el TPDOC esta en blanco            º±±
±±º          ³ Apos correccion de este llamado retirar esta funcion       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xNCCAnul(cFil,cDoc,cSer,cForn,cLoj)

	Local cTpDoc	:= space(TAMSX3("F1_TPDOC")[1])
	Local aArea		:= GetArea()
	local _cAlias	:= GetNextAlias()
	local cSql004	:= ""

	cSql004:= " SELECT F1_TPDOC  "
	cSql004+= " FROM "+ RetSqlName("SF1") + " SF1 "
	cSql004+= " WHERE SF1.F1_FILIAL  = '"+cFil+"' "
	cSql004+= "   AND SF1.F1_DOC     = '"+cDoc+"' "
	cSql004+= "   AND SF1.F1_SERIE   = '"+cSer+"' "
	cSql004+= "   AND SF1.F1_FORNECE = '"+cForn+"' "
	cSql004+= "   AND SF1.F1_LOJA    = '"+cLoj+"' "
	cSql004+= "   AND SF1.D_E_L_E_T_ = '*' "
	cSql004+= "   AND SF1.R_E_C_N_O_ > 0"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql004 ), _cAlias,.T.,.T.)
	IF (_cAlias)->( !EOF() )
	   cTpDoc := (_cAlias)->F1_TPDOC
	ENDIF

	(_cAlias)->( dbCloseArea() )

	RestArea(aArea)

Return(cTpDoc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZFISR011  ºAutor  ³Microsiga           ºFecha ³  09/12/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Añade columnas en blanco al imprimir relatorio mediante    º±±
±±º          ³ opcion 4 - Planilla.                                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EspCabec(nEspacios)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nEspacios - Cantidad de espacios a insertar.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ FISR011                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function EspCabec(nEspacios, oReport)
	Local nX	:= 0

	For nX := 1 To nEspacios
		oReport:PrintText(Space(1),oReport:Row(),0010)
	Next nX
Return Nil

/*/{Protheus.doc} BordCel
Funcion para colocar bordes a encabezado y lineas impresas.
@type  Static Function
@author oscar.lopez
@since 22/07/2021
@version 1.0
@example BordCel()
@param oSection, Objeto, Objeto TRSection.
/*/
Static Function BordCel(oSection)
	Local nX		:= 0
	Local cNomCel	:= ""
	For nX := 1 to Len(oSection:aCell)
		cNomCel := oSection:aCell[nX]:cNAME
		oSection:Cell(cNomCel):SetBorder("BOTTOM"	, 1, 000000, .F.)

		oSection:Cell(cNomCel):SetBorder("TOP"		, 1, 000000, .T.)
		oSection:Cell(cNomCel):SetBorder("BOTTOM"	, 1, 000000, .T.)
		oSection:Cell(cNomCel):SetBorder("LEFT"		, 1, 000000, .T.)
	Next nX
	oSection:Cell(oSection:aCell[Len(oSection:aCell)]:cNAME):SetBorder("RIGHT"	, 1, 000000, .T.)
Return

/*/{Protheus.doc} TitCelda
Funcion para ajuste de impresión por opción Planilla.
@type Static Function
@author oscar.lopez
@since 22/07/2021
@version 1.0
@example TitCelda()
@param oSection, Objeto, Objeto TRSection.
/*/
Static Function TitCelda(oSection)
	oSection:Cell("CCORRELA"):SetTitle(STR0011+STR0022+STR0033+STR0045+STR0056) //"Numero"#"correlativo"#"del registro o"#"codigo unico"#"de la operacion "
	oSection:Cell("DEMISSAO"):SetTitle(STR0012+STR0023+STR0034+STR0046+STR0025) //"De fecha"#"emisión del "#"comprobante"#"de pago"#"o doc.  "
	oSection:Cell("DVENCTORE"):SetTitle(STR0013+STR0024+STR0035+STR0047 ) //"Fecha "#"de"#"vencimiento "#"y/o pago"
	oSection:Cell("CTPDOC"):SetTitle(STR0031) //"Tipo"
	oSection:Cell("CSERIENF"):SetTitle(STR0036+STR0048+STR0057) //"Nºserie o"#"Nº de serie de la   "#"maquina registradora"
	oSection:Cell("CNFISCAL"):SetTitle(STR0011) //"Numero"
	oSection:Cell("CTIPODOC"):SetTitle(STR0031) //"Tipo"
	oSection:Cell("CCGC"):SetTitle(STR0011) //"Numero"
	oSection:Cell("CNOME"):SetTitle(STR0038+STR0049+STR0058) //"Apellidos y nombres, "#"denominacion "#"o razon social"
	oSection:Cell("VALNFEXP"):SetTitle(STR0016+STR0026+STR0039+STR0050) //"Valor"#"Facturado "#"de la   "#"exportacion "
	oSection:Cell("BASEIMPO"):SetTitle(STR0017+STR0027+STR0039+STR0051+STR0059) //"Base"#"Imponible  "#"de la   "#"Operacion "#"Gravada"
	oSection:Cell("IMPTOTEXO"):SetTitle(STR0052) //"Exonerada   "
	oSection:Cell("IMPTOTINA"):SetTitle(STR0053) //"Inafecta"
	oSection:Cell("ISC"):SetTitle(STR0040) //"ISC"
	oSection:Cell("IGVIPM"):SetTitle(STR0041) //"IGV y/o IPM"
	oSection:Cell("OTROSTRIB"):SetTitle(STR0019+STR0029+STR0042+STR0039+STR0060) //"Otros tributos"#"y cargos que"#"no forman parte"#"de la   "#"base imponible  "
	oSection:Cell("IMPCOMPPAG"):SetTitle(STR0020+STR0030+STR0043+STR0034+STR0046) //"Importe"#"Total"#"del "#"comprobante"#"de pago"
	oSection:Cell("TPCAMBIO"):SetTitle(STR0031+STR0024+STR0054) //"Tipo"#"de"#"cambio"
	oSection:Cell("FCHRCOMPGO"):SetTitle(STR0013) //"Fecha "
	oSection:Cell("TIPRCOMPGO"):SetTitle(STR0031) //"Tipo"
	oSection:Cell("SERRCOMPGO"):SetTitle(STR0055) //"Serie"
	oSection:Cell("NUMRCOMPGO"):SetTitle(STR0044+STR0034+STR0061) //"Nº del "#"comprobante"#"de pago o docto.  "
	oSection:Cell("VALICB"):SetTitle(STR0077) //"ICBPER"
Return
