#Include "PROTHEUS.CH"
#Include "REPORT.CH"
#Include "TOPCONN.CH"
#Include "FISR601.CH"

/*/   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ FISR601    ³ Autor ³ Luis Samaniego         ³ Data ³ 11/05/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Planilla demostrativa de los ingresos brutos totales y gastos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISR601()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISR601()
Local nOpcA    := 0
Local aSays    := {}
Local aButtons := {}
Local aArea    := GetArea()

Private dFchDesde  := CTOD("//")
Private dFchHasta  := CTOD("//")
Private nTipoCamb  := 0
Private nTipReport := 0
Private nSelectSuc := 0
Private nOrden     := 0
Private cPerg      := "FISR601"
Private oReport    := Nil
Private oSectionA  := Nil
Private cQrySD     := GetNextAlias()

Private aCposTmp   := {}
Private cMVDESCSAI := GetNewPar('MV_DESCSAI','1')
Private cTipoinf   := ""
	
	Pergunte( cPerg, .T. )
	aAdd(aSays, OemToAnsi( STR0001 ) ) 
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| IIf(VldParam(), (nOpcA := 1, o:oWnd:End()), Nil) }} )
	aAdd(aButtons, { 2,.T.,{ |o| nOpcA := 2, o:oWnd:End() }} )             
	FormBatch( oemtoansi(STR0001), aSays, aButtons ) 
	
	If nOpcA == 2
		Return
	Else
		dFchDesde  := MV_PAR01
		dFchHasta  := MV_PAR02
		nTipoCamb  := MV_PAR03
		nTipReport := MV_PAR04
		nSelectSuc := MV_PAR05
		nOrden     := MV_PAR06
		cTipoinf   := cValtochar(MV_PAR07)
		If nSelectSuc == 1
			aFilsCalc := MatFilCalc( nSelectSuc == 1, , , .T., , 0 )
		Else
			aFilsCalc := MatFilCalc( .F., {{.T.,Alltrim(FWGETCODFILIAL)}} , , .T., , 0 )
		EndIf
	EndIf
	
	ReportDef()
	oReport:PrintDialog()
	RestArea(aArea)
	
Return

/*/{Protheus.doc} ReportDef
Inicializa objetos para emitir informe.

@Type    Function
@Author  Luis Arturo Samaniego Guzman
@Since   11/05/2018
@Version P12.1.07
@Param   
@Return  oReport: Objeto del informe.
/*/
Static Function ReportDef()
Local cNomeProg := FunName()

	DEFINE REPORT oReport NAME cNomeProg TITLE STR0001 PARAMETER "" ACTION {|oReport| PrintReport(oReport) } DESCRIPTION STR0001
		oReport:SetTotalInLine(.F.)
		oReport:SetLandscape(.T.)	
	
	DEFINE SECTION oSectionA OF oReport TITLE STR0001 TABLE cQrySD
		DEFINE CELL NAME "ESPECIE" OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_ESPECIE") SIZE TamSX3("D1_ESPECIE")[1] HEADER ALIGN LEFT
		DEFINE CELL NAME "SERIE"   OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_SERIE")   SIZE TamSX3("D1_SERIE")[1]   HEADER ALIGN LEFT
		DEFINE CELL NAME "DOC"     OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_DOC")     SIZE TamSX3("D1_DOC")[1]     HEADER ALIGN LEFT
		DEFINE CELL NAME "EMISSAO" OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_EMISSAO") SIZE TamSX3("D1_EMISSAO")[1] HEADER ALIGN LEFT
		DEFINE CELL NAME "ACTDEC"  OF oSectionA ALIAS cQrySD TITLE fGetTitulo("B1_ACTDEC")  SIZE TamSX3("B1_ACTDEC")[1]  HEADER ALIGN LEFT
		DEFINE CELL NAME "CONTA"   OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_CONTA")   SIZE TamSX3("D1_CONTA")[1]   HEADER ALIGN LEFT
		DEFINE CELL NAME "CF"      OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_CF")      SIZE TamSX3("D1_CF")[1]      HEADER ALIGN LEFT
		DEFINE CELL NAME "TP"      OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_TP")      SIZE TamSX3("D1_TP")[1]      HEADER ALIGN LEFT
		DEFINE CELL NAME "GRUPO"   OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_GRUPO")   SIZE TamSX3("D1_GRUPO")[1]   HEADER ALIGN LEFT
		DEFINE CELL NAME "EST"     OF oSectionA ALIAS cQrySD TITLE fGetTitulo("A1_EST")     SIZE TamSX3("A1_EST")[1]     HEADER ALIGN LEFT
		DEFINE CELL NAME "PROVENT" OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_PROVENT") SIZE TamSX3("D1_PROVENT")[1] HEADER ALIGN LEFT
		DEFINE CELL NAME "ESTCOB"  OF oSectionA ALIAS cQrySD TITLE STR0002                  SIZE TamSX3("A1_EST")[1]     HEADER ALIGN LEFT
		DEFINE CELL NAME "FILIAL"  OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_FILIAL")  SIZE TamSX3("D1_FILIAL")[1]  HEADER ALIGN LEFT
		DEFINE CELL NAME "TOTAL"   OF oSectionA ALIAS cQrySD TITLE fGetTitulo("D1_TOTAL")   SIZE TamSX3("D1_TOTAL")[1] + TamSX3("D1_TOTAL")[2]   HEADER ALIGN CENTER
		oSectionA:SetTotalInLine(.T.)
		oSectionA:SetHeaderSection(.T.)
		
Return oReport

/*/{Protheus.doc} PrintReport
Obtiene datos y genera el informe.

@Type    Function
@Author  Luis Arturo Samaniego Guzman
@Since   11/05/2018
@Version P12.1.07
@Param   
@Return  
/*/
Static Function PrintReport(oReport)
Local nLoop     := 0
Local cQuery    := ""
Local oTmpTable := Nil
Local aOrdem    := {"FILIAL","ESPECIE","SERIE", "DOC"}
Local aFiliAct  := { FWGETCODFILIAL }
Local cESTCOB   := ""

	FISRTAB()
	
	dbSelectArea("SM0")
	dbSetOrder(1)
	
	For nLoop := 1 To Len(aFilsCalc)
		If aFilsCalc[nLoop][1] .And. (SM0->(msSeek(FwGrpCompany() + aFilsCalc[nLoop][2])))
		
			If 	cTipoinf $ "1"
			  	
			  	oSectionA:BeginQuery()
			  	
				cESTCOB := Alltrim(SM0->M0_ESTCOB)
				cQuery := " SELECT D1_ESPECIE AS ESPECIE, D1_SERIE AS SERIE, D1_DOC AS DOC, D1_EMISSAO AS EMISSAO, D1_CONTA AS CONTA, D1_CF AS CF, D1_TP AS TP, "
				cQuery += " D1_GRUPO AS GRUPO, D1_PROVENT AS PROVENT, D1_FILIAL AS FILIAL, B1_ACTDEC AS ACTDEC, A1_EST AS EST, '" + cESTCOB + "' AS ESTCOB, "
				cQuery += " CASE WHEN '" + cMVDESCSAI + "' = '1' THEN (D1_TOTAL * -1) ELSE ((D1_TOTAL - D1_VALDESC) * -1) END AS TOTAL, "
				cQuery += " F1_MOEDA AS MOEDA, F1_TXMOEDA AS TXMOEDA"
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 , " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SA1") + " SA1, " + RetSqlName("SF1") + " SF1"
				cQuery += " WHERE (D1_ESPECIE IN ('NDE',  'NCC') "
				cQuery += " AND (D1_EMISSAO BETWEEN '" + DTOS(dFchDesde) + "' AND '" + DTOS(dFchHasta) + "') "
				cQuery += " AND D1_FILIAL = '" + xFilial("SD1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D1_COD = B1_COD "
				cQuery += " AND B1_FILIAL = '" + xFilial("SB1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D1_FORNECE = A1_COD AND D1_LOJA = A1_LOJA"
				cQuery += " AND A1_FILIAL = '" + xFilial("SA1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND ((F1_FILIAL = '" + xFilial("SF1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE) "
				cQuery += " AND (F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA))"
				cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SF1.D_E_L_E_T_ = ' ' "
				cQuery += " UNION ALL "
				cQuery += " SELECT D2_ESPECIE AS ESPECIE, D2_SERIE AS SERIE, D2_DOC AS DOC, D2_EMISSAO AS EMISSAO, D2_CONTA AS CONTA, D2_CF AS CF, D2_TP AS TP, "
				cQuery += " D2_GRUPO AS GRUPO, D2_PROVENT AS PROVENT, D2_FILIAL AS FILIAL, B1_ACTDEC AS ACTDEC, A1_EST AS EST, '" + cESTCOB + "' ESTCOB, "
				cQuery += " CASE WHEN '" + cMVDESCSAI + "' = '1' THEN D2_TOTAL ELSE (D2_TOTAL) END AS TOTAL, "
				cQuery += " F2_MOEDA AS MOEDA, F2_TXMOEDA AS TXMOEDA"
				cQuery += " FROM " + RetSqlName("SD2") + " SD2 , " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SA1") + " SA1, " + RetSqlName("SF2") + " SF2"
				cQuery += " WHERE (D2_ESPECIE IN ('NF', 'NDC', 'NCE') "
				cQuery += " AND (D2_EMISSAO BETWEEN '" + DTOS(dFchDesde) + "' AND '" + DTOS(dFchHasta) + "')"
				cQuery += " AND D2_FILIAL = '" + xFilial("SD2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D2_COD = B1_COD "
				cQuery += " AND B1_FILIAL = '" + xFilial("SB1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA"
				cQuery += " AND A1_FILIAL = '" + xFilial("SA1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND ((F2_FILIAL = '" + xFilial("SF2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE) "
				cQuery += " AND (F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA))"
				cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery(cQuery)  
				SqlToTrb(cQuery,aCposTmp,cQrySD)
				
				oSectionA:SetParentQuery()
	
			ElseIf cTipoinf $ "2"
			
				oSectionA:BeginQuery()
			
				cESTCOB := Alltrim(SM0->M0_ESTCOB)
				cQuery := " SELECT D2_ESPECIE AS ESPECIE, D2_SERIE AS SERIE, D2_DOC AS DOC, D2_EMISSAO AS EMISSAO, D2_CONTA AS CONTA, D2_CF AS CF, D2_TP AS TP, "
				cQuery += " D2_GRUPO AS GRUPO, D2_PROVENT AS PROVENT, D2_FILIAL AS FILIAL, B1_ACTDEC AS ACTDEC, A2_EST AS EST, '" + cESTCOB + "' AS ESTCOB, "
				cQuery += " CASE WHEN '" + cMVDESCSAI + "' = '1' THEN (D2_TOTAL * -1) ELSE ((D2_TOTAL - D2_DESC) * -1) END AS TOTAL, "
				cQuery += " F2_MOEDA AS MOEDA, F2_TXMOEDA AS TXMOEDA"
				cQuery += " FROM " + RetSqlName("SD2") + " SD2 , " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SA2") + " SA2, " + RetSqlName("SF2") + " SF2"
				cQuery += " WHERE (D2_ESPECIE IN ('NDI',  'NCP') "
				cQuery += " AND (D2_EMISSAO BETWEEN '" + DTOS(dFchDesde) + "' AND '" + DTOS(dFchHasta) + "') "
				cQuery += " AND D2_FILIAL = '" + xFilial("SD2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D2_COD = B1_COD "
				cQuery += " AND B1_FILIAL = '" + xFilial("SB1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D2_CLIENTE = A2_COD AND D2_LOJA = A2_LOJA"
				cQuery += " AND A2_FILIAL = '" + xFilial("SA2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND ((F2_FILIAL = '" + xFilial("SF2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE) "
				cQuery += " AND (F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA))"
				cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
				cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
				cQuery += " UNION ALL " 
				cQuery += " SELECT D1_ESPECIE AS ESPECIE, D1_SERIE AS SERIE, D1_DOC AS DOC, D1_EMISSAO AS EMISSAO, D1_CONTA AS CONTA, D1_CF AS CF, D1_TP AS TP, "
				cQuery += " D1_GRUPO AS GRUPO, D1_PROVENT AS PROVENT, D1_FILIAL AS FILIAL, B1_ACTDEC AS ACTDEC, A2_EST AS EST, '" + cESTCOB + "' ESTCOB, "
				cQuery += " CASE WHEN '" + cMVDESCSAI + "' = '1' THEN D1_TOTAL ELSE (D1_TOTAL - D1_VALDESC) END AS TOTAL, "
				cQuery += " F1_MOEDA AS MOEDA, F1_TXMOEDA AS TXMOEDA"
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 , " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SA2") + " SA2, " + RetSqlName("SF1") + " SF1"
				cQuery += " WHERE (D1_ESPECIE IN ('NF', 'NCI', 'NDP') "
				cQuery += " AND (D1_EMISSAO BETWEEN '" + DTOS(dFchDesde) + "' AND '" + DTOS(dFchHasta) + "')"
				cQuery += " AND D1_FILIAL = '" + xFilial("SD1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D1_COD = B1_COD "
				cQuery += " AND B1_FILIAL = '" + xFilial("SB1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA"
				cQuery += " AND A2_FILIAL = '" + xFilial("SA2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND ((F1_FILIAL = '" + xFilial("SF1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE) "
				cQuery += " AND (F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA))"
				cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
				cQuery += " AND SF1.D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery(cQuery)  
				SqlToTrb(cQuery,aCposTmp,cQrySD)
				
				oSectionA:SetParentQuery()	
				
			Elseif cTipoinf $ "3"
			
				oSectionA:BeginQuery()
			
				cESTCOB := Alltrim(SM0->M0_ESTCOB)
				cQuery := " SELECT D1_ESPECIE AS ESPECIE, D1_SERIE AS SERIE, D1_DOC AS DOC, D1_EMISSAO AS EMISSAO, D1_CONTA AS CONTA, D1_CF AS CF, D1_TP AS TP, "
				cQuery += " D1_GRUPO AS GRUPO, D1_PROVENT AS PROVENT, D1_FILIAL AS FILIAL, B1_ACTDEC AS ACTDEC, A1_EST AS EST, '" + cESTCOB + "' AS ESTCOB, "
				cQuery += " CASE WHEN '" + cMVDESCSAI + "' = '1' THEN (D1_TOTAL * -1) ELSE ((D1_TOTAL - D1_VALDESC) * -1) END AS TOTAL, "
				cQuery += " F1_MOEDA AS MOEDA, F1_TXMOEDA AS TXMOEDA"
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 , " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SA1") + " SA1, " + RetSqlName("SF1") + " SF1"
				cQuery += " WHERE (D1_ESPECIE IN ('NDE',  'NCC') "
				cQuery += " AND (D1_EMISSAO BETWEEN '" + DTOS(dFchDesde) + "' AND '" + DTOS(dFchHasta) + "') "
				cQuery += " AND D1_FILIAL = '" + xFilial("SD1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D1_COD = B1_COD "
				cQuery += " AND B1_FILIAL = '" + xFilial("SB1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D1_FORNECE = A1_COD AND D1_LOJA = A1_LOJA"
				cQuery += " AND A1_FILIAL = '" + xFilial("SA1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND ((F1_FILIAL = '" + xFilial("SF1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE) "
				cQuery += " AND (F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA))"
				cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SF1.D_E_L_E_T_ = ' ' "
				cQuery += " UNION ALL "
				cQuery += " SELECT D2_ESPECIE AS ESPECIE, D2_SERIE AS SERIE, D2_DOC AS DOC, D2_EMISSAO AS EMISSAO, D2_CONTA AS CONTA, D2_CF AS CF, D2_TP AS TP, "
				cQuery += " D2_GRUPO AS GRUPO, D2_PROVENT AS PROVENT, D2_FILIAL AS FILIAL, B1_ACTDEC AS ACTDEC, A1_EST AS EST, '" + cESTCOB + "' ESTCOB, "
				cQuery += " CASE WHEN '" + cMVDESCSAI + "' = '1' THEN D2_TOTAL ELSE (D2_TOTAL) END AS TOTAL, "
				cQuery += " F2_MOEDA AS MOEDA, F2_TXMOEDA AS TXMOEDA"
				cQuery += " FROM " + RetSqlName("SD2") + " SD2 , " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SA1") + " SA1, " + RetSqlName("SF2") + " SF2"
				cQuery += " WHERE (D2_ESPECIE IN ('NF', 'NDC', 'NCE') "
				cQuery += " AND (D2_EMISSAO BETWEEN '" + DTOS(dFchDesde) + "' AND '" + DTOS(dFchHasta) + "')"
				cQuery += " AND D2_FILIAL = '" + xFilial("SD2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D2_COD = B1_COD "
				cQuery += " AND B1_FILIAL = '" + xFilial("SB1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA"
				cQuery += " AND A1_FILIAL = '" + xFilial("SA1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND ((F2_FILIAL = '" + xFilial("SF2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE) "
				cQuery += " AND (F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA))"
				cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
				
				cQuery += " UNION ALL"
				
				cQuery += " SELECT D2_ESPECIE AS ESPECIE, D2_SERIE AS SERIE, D2_DOC AS DOC, D2_EMISSAO AS EMISSAO, D2_CONTA AS CONTA, D2_CF AS CF, D2_TP AS TP, "
				cQuery += " D2_GRUPO AS GRUPO, D2_PROVENT AS PROVENT, D2_FILIAL AS FILIAL, B1_ACTDEC AS ACTDEC, A2_EST AS EST, '" + cESTCOB + "' AS ESTCOB, "
				cQuery += " CASE WHEN '" + cMVDESCSAI + "' = '1' THEN (D2_TOTAL * -1) ELSE ((D2_TOTAL - D2_DESC) * -1) END AS TOTAL, "
				cQuery += " F2_MOEDA AS MOEDA, F2_TXMOEDA AS TXMOEDA"
				cQuery += " FROM " + RetSqlName("SD2") + " SD2 , " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SA2") + " SA2, " + RetSqlName("SF2") + " SF2"
				cQuery += " WHERE (D2_ESPECIE IN ('NDI',  'NCP') "
				cQuery += " AND (D2_EMISSAO BETWEEN '" + DTOS(dFchDesde) + "' AND '" + DTOS(dFchHasta) + "') "
				cQuery += " AND D2_FILIAL = '" + xFilial("SD2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D2_COD = B1_COD "
				cQuery += " AND B1_FILIAL = '" + xFilial("SB1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D2_CLIENTE = A2_COD AND D2_LOJA = A2_LOJA"
				cQuery += " AND A2_FILIAL = '" + xFilial("SA2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND ((F2_FILIAL = '" + xFilial("SF2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE) "
				cQuery += " AND (F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA))"
				cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
				cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
				cQuery += " UNION ALL " 
				cQuery += " SELECT D1_ESPECIE AS ESPECIE, D1_SERIE AS SERIE, D1_DOC AS DOC, D1_EMISSAO AS EMISSAO, D1_CONTA AS CONTA, D1_CF AS CF, D1_TP AS TP, "
				cQuery += " D1_GRUPO AS GRUPO, D1_PROVENT AS PROVENT, D1_FILIAL AS FILIAL, B1_ACTDEC AS ACTDEC, A2_EST AS EST, '" + cESTCOB + "' ESTCOB, "
				cQuery += " CASE WHEN '" + cMVDESCSAI + "' = '1' THEN D1_TOTAL ELSE (D1_TOTAL - D1_VALDESC) END AS TOTAL, "
				cQuery += " F1_MOEDA AS MOEDA, F1_TXMOEDA AS TXMOEDA"
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 , " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SA2") + " SA2, " + RetSqlName("SF1") + " SF1"
				cQuery += " WHERE (D1_ESPECIE IN ('NF', 'NCI', 'NDP') "
				cQuery += " AND (D1_EMISSAO BETWEEN '" + DTOS(dFchDesde) + "' AND '" + DTOS(dFchHasta) + "')"
				cQuery += " AND D1_FILIAL = '" + xFilial("SD1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D1_COD = B1_COD "
				cQuery += " AND B1_FILIAL = '" + xFilial("SB1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA"
				cQuery += " AND A2_FILIAL = '" + xFilial("SA2", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND ((F1_FILIAL = '" + xFilial("SF1", aFilsCalc[nLoop][2]) + "') "
				cQuery += " AND (F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE) "
				cQuery += " AND (F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA))"
				cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
				cQuery += " AND SF1.D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery(cQuery)  
				SqlToTrb(cQuery,aCposTmp,cQrySD)
				 
				oSectionA:SetParentQuery()	
					
			Endif	
		EndIf		
	Next nLoop
	
	//Se posiciona sobre la filial activa
	SM0->(DbSeek(FwGrpCompany() + aFiliAct[1]))
	
 	If nTipReport == 2
 		oSectionA:Cell("ESPECIE"):Disable()
 		oSectionA:Cell("SERIE"):Disable()
 		oSectionA:Cell("DOC"):Disable()
 		oSectionA:Cell("EMISSAO"):Disable()
 	EndIf
 	oSectionA:Cell("TOTAL"):SetBlock({|| fTipoCam()})
  	oSectionA:Print() 
  	
  	(cQrySD)->(dbCloseArea())
  	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
	
	oSectionA:EndQuery()
Return

/*/{Protheus.doc} fTipoCam
Valor de Ítem en SD1/SD2 en moneda 1.

@Type    Function
@Author  Luis Arturo Samaniego Guzman
@Since   11/05/2018
@Version P12.1.07
@Param   
@Return  nVlrTotal: Valor de ítem.
/*/
Static Function fTipoCam()
Local nVlrTotal := 0
	
	If (cQrySD)->MOEDA != 1
		If nTipoCamb == 1 //Historico
			nVlrTotal := xMoeda((cQrySD)->TOTAL,(cQrySD)->MOEDA,1,(cQrySD)->EMISSAO,,)
		Else //Informado
			nVlrTotal := xMoeda((cQrySD)->TOTAL,(cQrySD)->MOEDA,1,,,(cQrySD)->TXMOEDA)
		EndIf
	Else
		nVlrTotal := (cQrySD)->TOTAL
	EndIf
	
Return nVlrTotal

/*/{Protheus.doc} fGetTitulo
Retorna el título del campo.

@Type    Function
@Author  Luis Arturo Samaniego Guzman
@Since   11/05/2018
@Version P12.1.07
@Param   cCampoSX3: Campo (SX3)
@Return  cTitulo: Título del campo.
/*/
Static Function fGetTitulo(cCampoSX3)
Local cTitulo := ""

	DbSelectArea("SX3")
	DbSetOrder(2)
	If SX3->(MsSeek(cCampoSX3))
		cTitulo := Alltrim(X3Titulo())
	EndIf
Return cTitulo

/*/{Protheus.doc} VldParam
Valida que sean informados los parámetros de fecha.

@Type    Function
@Author  Luis Arturo Samaniego Guzman
@Since   11/05/2018
@Version P12.1.07
@Param   
@Return  lRet: Verdadero si se informaron todos los parámetros.
/*/
Static Function VldParam()
Local lRet := .T.

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} FISRTAB
Cria as tabela temporaria.

@Type    Function
@Author  Danilo Santos
@Since   16/10/2018
@Version P12.1.17
@Param   
@Return  
/*/
Static Function FISRTAB()

 //Crea estructura de la tabla
	aAdd(aCposTmp, { "ESPECIE",   "C", TamSX3("D1_ESPECIE")[1],   TamSX3("D1_ESPECIE")[2] })
	aAdd(aCposTmp, { "SERIE",     "C", TamSX3("D1_SERIE")[1],     TamSX3("D1_SERIE")[2] })
	aAdd(aCposTmp, { "DOC",       "C", TamSX3("D1_DOC")[1],       TamSX3("D1_DOC")[2] })
	aAdd(aCposTmp, { "EMISSAO",   "D", TamSX3("D1_EMISSAO")[1],   TamSX3("D1_EMISSAO")[2] })
	aAdd(aCposTmp, { "ACTDEC",    "C", TamSX3("B1_ACTDEC")[1],    TamSX3("B1_ACTDEC")[2] })
	aAdd(aCposTmp, { "CONTA",     "C", TamSX3("D1_CONTA")[1],     TamSX3("D1_CONTA")[2] })
	aAdd(aCposTmp, { "CF",        "C", TamSX3("D1_CF")[1],        TamSX3("D1_CF")[2] })
	aAdd(aCposTmp, { "TP",        "C", TamSX3("D1_TP")[1],        TamSX3("D1_TP")[2] })
	aAdd(aCposTmp, { "GRUPO",     "C", TamSX3("D1_GRUPO")[1],     TamSX3("D1_GRUPO")[2] })
	aAdd(aCposTmp, { "EST",       "C", TamSX3("A1_EST")[1],       TamSX3("A1_EST")[2] })
	aAdd(aCposTmp, { "PROVENT",   "C", TamSX3("D1_PROVENT")[1],   TamSX3("D1_PROVENT")[2] })
	aAdd(aCposTmp, { "ESTCOB",    "C", TamSX3("A1_EST")[1],       TamSX3("A1_EST")[2]  })
	aAdd(aCposTmp, { "FILIAL",    "C", TamSX3("D1_FILIAL")[1],    TamSX3("D1_FILIAL")[2] })
	aAdd(aCposTmp, { "TOTAL",     "N", TamSX3("D1_TOTAL")[1],     TamSX3("D1_TOTAL")[2] })
	aAdd(aCposTmp, { "MOEDA",     "N", TamSX3("F1_MOEDA")[1],     TamSX3("F1_MOEDA")[2] })
	aAdd(aCposTmp, { "TXMOEDA",   "N", TamSX3("F1_TXMOEDA")[1],   TamSX3("F1_TXMOEDA")[2] })
	
	oTmpTable := FWTemporaryTable():New(cQrySD) 
	oTmpTable:SetFields( aCposTmp ) 
	If nOrden == 1
		oTmpTable:AddIndex("IN1", {"ESPECIE"})
	ElseIf nOrden == 2
		oTmpTable:AddIndex("IN2", {"SERIE"})
	ElseIf nOrden == 3
		oTmpTable:AddIndex("IN3", {"DOC"})
	EndIf
	oTmpTable:Create()

Return