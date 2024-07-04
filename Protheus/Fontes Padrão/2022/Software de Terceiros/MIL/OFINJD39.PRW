
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFINJD39.ch'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/05/2016
/*/
Static cSGBD := TcGetDb()

Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "8"

/*/{Protheus.doc} OFINJD39 "Consulta de Zero Vendas PMM"

    Pontos de entrada:
		N/A		
	Parametros:
		N/A

    @author Vinicius Gati
    @since  12/05/2016
/*/
Function OFINJD39()
	Private oArrHlp     := DMS_ArrayHelper():New()
	Private oMetas      := DMS_MetasDeInteresseDAO():New()
	Private oSqlHlp     := DMS_SqlHelper():New()
	Private oDpm        := DMS_DPM():New()
	Private oUtil       := DMS_Util():New()
	Private aSizeAut    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Private cPrd        := SPACE(TAMSX3("B1_COD")[1])
	Private cFil        := SPACE(FWSizeFilial())
	Private cZVSN       := cOrig := "   "
	Private cCC         := "   "
	Private cDatabase   := "          "
	Private lSoArmVenda := .T.

	if ExistBlock("JD09001")
		lSoArmVenda := .F.
	endif

	FS_UILoad()
Return NIL

/*/{Protheus.doc} FS_UILoad

	@author       Vinicius Gati
	@since        12/05/2016
	@description  Desenha a interface com usuario

/*/
Static Function FS_UILoad()
	Local aObjects := {} , aPosObj := {} , aInfo := {}
	Local oGtPrd   := oCombo := oCombo2 := oCombo3 := oCombo4 := oFiltra := Nil
	cPrd        := SPACE(TAMSX3("B1_COD")[1])

	AAdd( aObjects, { 01 , 26 , .T. , .F. } ) // Filtro
	AAdd( aObjects, { 01 , 10 , .T. , .T. } ) // ListBox
	aInfo   := { aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize(aInfo, aObjects, .F.)

	//Consulta de Zero Vendas DPM John Deere
	DEFINE MSDIALOG oWindow TITLE STR0003 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	//
	@ aPosObj[1,1] + 002 , aPosObj[1,2] TO aPosObj[1,3] , aPosObj[1,4] LABEL STR0016 /*"Filtro"*/ OF oWindow PIXEL
	
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 008 SAY STR0009 /*Data base*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 035 MSCOMBOBOX oCombo VAR cDataBase ITEMS last12M() SIZE 055,10 OF oWindow PIXEL

	aFils := oArrHlp:Map(oDpm:GetFiliais(), {|aEl| aEl[1] })
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 0095 SAY STR0013 /*Filial*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 0110 MSCOMBOBOX oCombo2 VAR cFil ITEMS aFils SIZE 040,10 OF oWindow PIXEL

	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 0160 SAY STR0004 /*Zero Vendas? */ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 0199 MSCOMBOBOX oCombo3 VAR cZVSN ITEMS {STR0005/*"SIM"*/, STR0006/*"NÃO"*/} SIZE 040,10 OF oWindow PIXEL
	
	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 245 SAY STR0002 /*Produto*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 270 MSGET oGtPrd VAR cPrd F3 "SB1" SIZE 70,08 OF oWindow PIXEL HASBUTTON

	@ aPosObj[1,1] + 012 , aPosObj[1,2] + 340 SAY STR0017 /*Originais?*/ OF oWindow PIXEL
	@ aPosObj[1,1] + 011 , aPosObj[1,2] + 365 MSCOMBOBOX oCombo4 VAR cOrig ITEMS {STR0005/*"SIM"*/, STR0006/*"NÃO"*/, STR0021/*TODOS*/ } SIZE 040,10 OF oWindow PIXEL

	@ aPosObj[1,1] + 011 , aPosObj[1,4] - 060 BUTTON oFiltra PROMPT STR0008 /*Filtrar*/ OF oWindow SIZE 50,10 PIXEL ACTION FS_Buscar()
	//
	aLBHeader := {}
	@ aPosObj[2,1] + 000 , aPosObj[2,2] + 000 LISTBOX oLb ;
		FIELDS ;
		HEADER   STR0013 /*Filial*/, STR0014 /*Local*/,  STR0002 /*Produto*/, STR0018 /*Quantidade*/, STR0007 /*Custo Médio*/, STR0016/*Total*/, STR0011/*Prim. Ent.*/, STR0022,   STR0012/*Ult. Venda*/,   STR0012/*Ult. Venda*/ +" "+ STR0023 /*Historico*/, "";
		COLSIZES                 50,               50 ,                   50,                     50,                      50,               50,                    50,      50,                      50,                                                  50, 10;
		SIZE aPosObj[2,4] - 2,aPosObj[2,3] - aPosObj[2,1] - 15 OF oWindow PIXEL ;
		ON DBLCLICK FS_DblClick()
	oLb:SetArray({})
	oLb:bLine := FS_Valores()

	cValTot := "                      "
	@ aPosObj[2,3] - 011 , 10 SAY STR0001 /*"Total geral do filtro:"*/ OF oWindow PIXEL
	@ aPosObj[2,3] - 012 , 85 MSGET oGtTotNa VAR cValTot SIZE 60,08 OF oWindow PIXEL WHEN .F.

	@ aPosObj[2,3] - 012 , 150 BUTTON oFiltra PROMPT STR0019 /*Ger. Excel*/ OF oWindow SIZE 50,10 PIXEL ACTION Processa( {|| FS_GerExcel()}, STR0021 /*"Processando"*/, "", .T.)
	//
	ACTIVATE MSDIALOG oWindow ON INIT (EnchoiceBar(oWindow, {|| lOk:=.t., oWindow:End() }, { || oWindow:End() },,))
	//
Return .T.

/*/{Protheus.doc} FS_GerExcel

	@author       Vinicius Gati
	@since        13/05/2016
	@description  Evento double click do grid

/*/
Static Function FS_GerExcel()
	if LEN(oLb:aArray) >= 1
		ProcRegua(0)

		aHeader := {;
			STR0013 ,; // Filial
			STR0002 ,; // Produto
			STR0014 ,; // Almox
			STR0018 ,; // Quantidade
			STR0007 ,; // Custo Medio
			STR0016 ,; // Total
			STR0011 ,; // Prim. Entrada
			STR0022 ,; // Ult. Ent
			STR0012 ,; // Ult. Venda
			STR0012 + " "+ STR0023  ; // Ult. Venda Histórico
		}
		aDados := {}
		oArrHlp:Map( oLb:aArray, {|el| AADD(aDados, {;
			el:GetValue('FILIAL'),;
			el:GetValue('PRODUT'),;
			el:GetValue('ALMOXARIFE'),;
			STR(el:GetValue('QUANT')),;
			Transform(el:GetValue('CM'), "@E 999,999,999.99"),;
			Transform(el:GetValue('TOTAL'), "@E 999,999,999.99"),;
			OJD39FMTDT(el:GetValue('PE')),;
			OJD39FMTDT(el:GetValue('ULTENT')),;
			OJD39FMTDT(el:GetValue('UVDA')),;
			OJD39FMTDT(el:GetValue('ULTIMA_VENDA_FINAL')) ;
		})} )
		targetDir:= cGetFile( '*.html' , 'Local do arquivo', 1, ALLTRIM(' C:\ '), .F., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),.T., .T. )
		cfilname := "RELATORIO_ZERO_VENDAS_" + SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + "_" + cFil + ".HTML"
		oUtil:GerExcel(targetDir + cfilname, aHeader, aDados)
		IncProc(STR0020 + ": " + targetDir + cfilname)
		MSGINFO("Gerado com sucesso", "Informação")
	EndIf
Return .T.

/*/{Protheus.doc} FS_DblClick

	@author       Vinicius Gati
	@since        12/05/2016
	@description  Evento double click do grid

/*/
Static Function FS_DblClick()
Return .T.

/*/{Protheus.doc} FS_Valores

	@author       Vinicius Gati
	@since        12/05/2016
	@description  Indica os valores mostrados em cada coluna do listbox

/*/
Static Function FS_Valores()
Return { || IIF( LEN(oLb:aArray) < oLb:nAt,Array(10), ;
	{ ;
		oLb:aArray[oLb:nAt]:GetValue('FILIAL'),;
		oLb:aArray[oLb:nAt]:GetValue('ALMOXARIFE'),;
		oLb:aArray[oLb:nAt]:GetValue('PRODUT'),;
		oLb:aArray[oLb:nAt]:GetValue('QUANT'),;
		FG_AlinVlrs(Transform(oLb:aArray[oLb:nAt]:GetValue('CM'), "@E 999,999,999.99")),;
		FG_AlinVlrs(Transform(oLb:aArray[oLb:nAt]:GetValue('TOTAL'), "@E 999,999,999.99")),;
		OJD39FMTDT(oLb:aArray[oLb:nAt]:GetValue('PE')),;
		OJD39FMTDT(oLb:aArray[oLb:nAt]:GetValue('ULTENT')),;
		OJD39FMTDT(oLb:aArray[oLb:nAt]:GetValue('UVDA')),;
		OJD39FMTDT(oLb:aArray[oLb:nAt]:GetValue('ULTIMA_VENDA_FINAL')),;
		"" ;
	};
)}

/*/{Protheus.doc} FS_Buscar

	@author       Vinicius Gati
	@since        12/05/2016
	@description  Busca os dados de zero vendas

/*/
Static Function FS_Buscar()
	Local cQuery  := ""
	Local nIdx    := 0
	Local nSum    := 0.0
	Local cPreTbl := IIf(ALLTRIM(cSGBD) <> "ORACLE", " AS ", "")
	//
	cFilAnt    := cFil
	cDadosProd := GetNewPar("MV_MIL0054","SBZ")
	//
	If Empty(cCC)
		cCC := "%"
	EndIf
	//
	dDataBase  := CTOD(cDataBase)
	d1AnoAtras := dDatabase
	for nIdx := 1 to 11
		d1AnoAtras  := oUtil:RemoveMeses(d1AnoAtras, 1)
		d1AnoAtras  := oUtil:UltimoDia( YEAR(d1AnoAtras), MONTH(d1AnoAtras) )
	next
	d1AnoAtras := STOD( ALLTRIM(STR(YEAR(d1AnoAtras))) + ALLTRIM(STRZERO(MONTH(d1AnoAtras),2)) + '01' )

	cQuery := " SELECT TB3.* FROM ("
	cQuery += " SELECT TB2.*, CM*QUANT AS TOTAL, "
	cQuery += "        CASE WHEN ULTIMA_VENDA_COMPUTADA is null then "
	cQuery += "        ( "
	cQuery += "            SELECT MAX(" + oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'}) + ")" "
	cQuery += "              FROM "+oSqlHlp:NoLock('VB8')
	cQuery += "             WHERE " + oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'}) + " < '" + dtos(ddatabase) + "' "
	cQuery += "               AND ( VB8_VDAB > 0 OR VB8_VDAO > 0 OR VB8_VDAI > 0 ) "
	cQuery += "               AND VB8_PRODUT = PRODUT "
	cQuery += "               AND VB8.D_E_L_E_T_ = ' ' "
	cQuery += "        ) "
	cQuery += "        ELSE ULTIMA_VENDA_COMPUTADA end as ULTIMA_VENDA_FINAL, "
	cQuery += "        (SELECT MAX(SD1D.D1_DTDIGIT) FROM " + oSqlHlp:NoLock('SD1', 'SD1D') + " JOIN " + oSqlHlp:NoLock('SF4', 'SF4D') + "  ON SF4D.F4_FILIAL = '"+xFilial('SF4')+"' AND SF4D.F4_CODIGO = SD1D.D1_TES AND SF4D.F4_OPEMOV IN ('01', '03') AND SF4D.D_E_L_E_T_ = ' ' WHERE SD1D.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1D.D1_COD = PRODUT AND SD1D.D_E_L_E_T_ = ' ') ULTENT "
	cQuery += " FROM  "
	cQuery += " ( "
	cQuery += "     SELECT TB1.*, "
	cQuery += "            CASE WHEN TB1.DTADDED is null OR PE_CALC < TB1.DTADDED THEN PE_CALC "
	cQuery += "              ELSE TB1.DTADDED "
	cQuery += "            END AS PE, "
	cQuery += "            CASE WHEN TB1.UVDA is null OR TB1.UVDA = '' THEN TB1.ULTVDA ELSE TB1.UVDA END ULTIMA_VENDA_COMPUTADA"
	cQuery += "     FROM  "
	cQuery += "     ( "
	cQuery += "       SELECT inv.ALMOXE ALMOXARIFE, inv.PRODUT, inv.FILIAL, inv.CM, inv.QUANT, inv.DATAEX, ENT.DT_D1, FECH.DT_B9, "
	cQuery += "              CASE WHEN SBMINMAX.ULTVDA <= '"+dtos(ddatabase)+"' then SBMINMAX.ULTVDA else null end as ULTVDA, "
	cQuery += "              CASE WHEN SBMINMAX.DTADDED = ' ' then null else  SBMINMAX.DTADDED end as DTADDED, "
	cQuery += "              CASE WHEN FECH.DT_B9 IS NOT NULL AND FECH.DT_B9 < ENT.DT_D1 THEN FECH.DT_B9 "
	cQuery += "                 ELSE ENT.DT_D1 "
	cQuery += "              END AS PE_CALC, "
	cQuery += "              SAI.ULTVDA AS UVDA "
	cQuery += "         FROM MIL_DPM_CACHE_INVENTARIO inv "
	cQuery += "         JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND SB1.B1_COD   = inv.PRODUT     AND SB1.B1_CRICOD like '"+cCC+"' AND SB1.D_E_L_E_T_ = ' ' "
	if SBM->(FieldPos('BM_VAIDPM')) > 0
		cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND SBM.BM_VAIDPM    = '1'       AND SBM.D_E_L_E_T_ = ' ' "
	else
		cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND BM_GRUPO IN "+oDpm:GetInGroups()+"   AND SBM.D_E_L_E_T_ = ' ' "
	endif
	if NNR->(FieldPos('NNR_VDADMS')) > 0 .and. lSoArmVenda /* somente armazens de venda é padrao, isso foi feito pra maqnelson */
		cQuery += "       JOIN "+oSqlHlp:NoLock('NNR')+" ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO   = inv.ALMOXE     AND NNR_VDADMS       = '1'       AND NNR.D_E_L_E_T_ = ' ' "
	endif
	If cDadosProd == "SBZ"
		cQuery += " JOIN ( "
		cQuery += "   SELECT BZ_FILIAL, BZ_COD, MIN(BZ_PRIENT) DTADDED, MAX(BZ_ULTVDA) ULTVDA "
		cQuery += "     FROM "+oSqlHlp:NoLock('SBZ')+" "
		cQuery += "    WHERE SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY BZ_FILIAL, BZ_COD "
		cQuery += " ) SBMINMAX ON SBMINMAX.BZ_COD = B1_COD "
	Else
		cQuery += " LEFT JOIN ( "
		cQuery += "   SELECT B5_FILIAL, B5_COD, MIN(B5_DTADDED) DTADDED, MAX(B5_ULTVDA) ULTVDA "
		cQuery += "     FROM "+oSqlHlp:NoLock('SB5')+" "
		cQuery += "    WHERE SB5.B5_FILIAL = '"+xFilial('SB5')+"' AND SB5.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY B5_FILIAL, B5_COD "
		cQuery += " ) SBMINMAX ON SBMINMAX.B5_COD = B1_COD "
	Endif
	cQuery += " LEFT JOIN ( "
	cQuery += "   SELECT B9_FILIAL, B9_COD, MIN(B9_DATA) DT_B9 "
	cQuery += "     FROM "+oSqlHlp:NoLock('SB9')+" "
	cQuery += "    WHERE SB9.B9_FILIAL = '"+xFilial('SB9')+"' AND SB9.B9_DATA <> ' ' AND B9_QINI > 0 AND SB9.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY B9_FILIAL, B9_COD "
	cQuery += " ) FECH ON FECH.B9_COD = B1_COD "

	cQuery += " LEFT JOIN ( "
	cQuery += "   SELECT D1_FILIAL, D1_COD, MIN(SD1.D1_DTDIGIT) AS DT_D1 "
	cQuery += "    FROM "+oSqlHlp:NoLock('SD1')+" "
	cQuery += "    JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '"+xFilial('SF4')+"' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV IN ('01', '03') AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE SD1.D1_FILIAL  = '"+xFilial('SD1')+"' "
	cQuery += "      AND D1_DTDIGIT <= '"+dtos(ddatabase)+"' "
	cQuery += "      AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY D1_FILIAL, D1_COD "
	cQuery += " ) ENT ON ENT.D1_FILIAL = '"+xFilial('SD1')+"' AND D1_COD = B1_COD  "

	cQuery += " LEFT JOIN ( "
	cQuery += "     SELECT D2_FILIAL, D2_COD, MAX(SD2.D2_EMISSAO) AS ULTVDA "
	cQuery += "       FROM "+oSqlHlp:NoLock('SD2')+" "
	cQuery += "       JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '"+xFilial('SF4')+"'  AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV IN ('05') AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "      WHERE D2_FILIAL = '"+xFilial('SD2')+"' "
	cQuery += "        AND D2_EMISSAO <= '"+dtos(ddatabase)+"' "
	cQuery += "        AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += "   GROUP BY D2_FILIAL, D2_COD "
	cQuery += " ) SAI ON SAI.D2_FILIAL = '"+xFilial('SD2')+"' AND D2_COD = B1_COD "

	cQuery += " WHERE inv.FILIAL = '"+xFilial('SD2')+"' "
	cQuery += "   AND DATAEX = '"+dtos(ddatabase)+"' "
	cQuery += "   AND QUANT  > 0 "
	cQuery += "   AND CM     > 0 "

	if cOrig == STR0005 // "SIM"
		cQuery += "   AND SBM.BM_PROORI = '1' "
	elseif cOrig == STR0006 // "NAO"
		cQuery += "   AND SBM.BM_PROORI = '0' "
	endif

	if ! Empty(cPrd)
		cQuery += " AND inv.PRODUT = '"+cPrd+"' "
	EndIf
	cQuery += "   ) "+cPreTbl+" TB1 "
	cQuery += "  ) "+cPreTbl+" TB2 "
	cQuery += " ) "+cPreTbl+" TB3 "
	cQuery += " WHERE "

	if cZVSN == STR0005 /*SIM*/
		cQuery += " (ULTIMA_VENDA_FINAL < '"+dtos(d1AnoAtras)+"' OR ULTIMA_VENDA_FINAL is null OR ULTIMA_VENDA_FINAL = ' ') "
		cQuery += " AND  "
		cQuery += " (PE < '"+dtos(d1AnoAtras)+"' OR PE is null OR PE = ' ') "
	else
		cQuery += " (ULTIMA_VENDA_FINAL >= '"+dtos(d1AnoAtras)+"' OR PE   >= '"+dtos(d1AnoAtras)+"') " // + chr(13) + chr(10)
	EndIf

	aRegs := oSqlHlp:GetSelect({;
		{'campos', {"TOTAL", "ALMOXARIFE", "FILIAL", "DATAEX", "PRODUT", "CM", "QUANT", "UVDA", "PE", "ULTENT","ULTIMA_VENDA_FINAL"}},;
		{'query' , cQuery};
	})

	For nIdx := 1 to LEN(aRegs)
		nSum += aRegs[nIdx]:GetValue("TOTAL")
	Next
	
	cValTot := Transform(nSum, "@E 999,999,999.99")

	oLb:SetArray( aRegs )
	oLb:bLine := FS_Valores()
	oLb:Refresh()
Return .T.

/*/{Protheus.doc} last12M
    Retornar ultimos 12 meses em data e em array, todas no ultimo dia do mês

    @author Vinicius Gati
    @since  12/05/2016
/*/
Static Function last12M()
	aRegs := oSqlHlp:GetSelect({;
		{'campos', {"DATAEX"}},;
		{'query' , " SELECT DISTINCT DATAEX FROM MIL_DPM_CACHE_INVENTARIO WHERE D_E_L_E_T_ = ' ' AND FLAGP != ' ' ORDER BY DATAEX DESC "};
	})
Return oArrHlp:Map(aRegs, {|r| DTOC(STOD(r:GetValue('DATAEX'))) })

/*/{Protheus.doc} OJD39FMTDT
    Retornar ultimos 12 meses em data e em array, todas no ultimo dia do mês

    @author Vinicius Gati
    @since  12/05/2016
/*/
Static Function OJD39FMTDT(value)
	if VALTYPE(value) == "D"
		return DTOC(value)
	Elseif VALTYPE(value) == "C"
		return right(value, 2) + "/" + right(LEFT(value, 6), 2) + "/" + LEFT(value, 4)
	EndIf
Return " "
