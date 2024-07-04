#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND011.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"
#INCLUDE	"XMLXFUN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND011
Impress�o do Hist�rico de Indicadores.

@author Wagner Sobral de Lacerda
@since 19/09/2012

@param cCodFilTZE
	C�digo da Filial da tabela TZE * Opcional
@param cCodHisTZE
	C�digo do Hist�rico da tabela TZE * Opcional

@return lExecute
/*/
//---------------------------------------------------------------------
Function NGIND011(cCodFilTZE, cCodHisTZE)

	//------------------------------
	// Armazena as vari�veis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local lExecute := .T. // Vari�vel para identificar se pode ou n�o executar esta rotina

	// Defaults
	Default cCodFilTZE := ""
	Default cCodHisTZE := ""

	//-------------------------------
	// Valida a execu��o do programa
	//-------------------------------
	lExecute := NGIND007OP()
	If lExecute
		If Empty(cCodHisTZE)
			lExecute := fAskSX1(@cCodFilTZE, @cCodHisTZE)
		EndIf
	EndIf
	If lExecute
		If Empty(cCodHisTZE)
			Help(Nil, Nil, STR0001, Nil, STR0002 + CRLF + STR0003, 1, 0) //"Aten��o" ## "O Hist�rico a ser impresso n�o foi definido." ## "Impress�o abortada."
			lExecute := .F.
		EndIf
	EndIf

	If lExecute
		// Fun��o principal
		fMain(cCodFilTZE, cCodHisTZE)
	EndIf

	//------------------------------
	// Devolve as vari�veis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return lExecute

//---------------------------------------------------------------------
/*/{Protheus.doc} fAskSX1
Reliza a Pergunta do SX1.

@author Wagner Sobral de Lacerda
@since 03/12/2012

@param cCodFilTZE
	C�digo da Filial da tabela TZE * Obrigat�rio
@param cCodHisTZE
	C�digo do Hist�rico da tabela TZE * Obrigat�rio

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fAskSX1(cCodFilTZE, cCodHisTZE)

	// Vari�vel do Retorno
	Local lRetorno := .T.

	// Vari�veis da Pergunta
	Private cPerg := "NGIN11"

	// Executa a Pergunta do SX1
	lRetorno := Pergunte(cPerg, .T.)
	If lRetorno
		cCodFilTZE := xFilial("TZE")
		cCodHisTZE := MV_PAR01
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fMain
Fun��o Principal.

@author Wagner Sobral de Lacerda
@since 31/10/2012

@param cCodFilTZE
	C�digo da Filial da tabela TZE * Obrigat�rio
@param cCodHisTZE
	C�digo do Hist�rico da tabela TZE * Obrigat�rio

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fMain(cCodFilTZE, cCodHisTZE)

	// Vari�veis do Dialog
	Local oDlg011
	Local cDlg011 := OemToAnsi(STR0006) //"Impress�o de Hist�rico de Indicadores"
	Local lDlg011 := .F.
	Local oPnl011

	Local lDados := .T.

	Local aEncBtns := {}

	Local cAuxData := ""

	// Vari�veis Private necess�rias
	Private INCLUI := .F.
	Private ALTERA := .F.

	// Dimensionamento da Janela
	Private aSize := MsAdvSize(.F.) // .T./.F. - Possui/N�o Possui EnchoiceBar

	// Layer
	Private oLayer011

	// Paneis Principais (Containers)
	Private o011Hist
	Private o011Tipo
	Private o011Config

	Private oBlackPnl

	// Vari�veis carregadas do Hist�rico
	Private aVariaveis := {}, aBkpVars := {}
	Private aTabelas := {}, aBkpTbls := {}
	Private aCampos := {}, aBkpCpos := {}
	Private aParams := {}, aBkpPars := {}
		// Posi��es 'aVariaveis'
		Private nVarVARIAV := 1
		Private nVarVARNOM := 2
		Private nVarSize   := 2
		// Posi��es 'aTabelas'
		Private nTblVARIAV := 1
		Private nTblTABELA := 2
		Private nTblNOME   := 3
		Private nTblSELECT := 4
		Private nTblSize   := 4
		// Posi��es 'aCampos'
		Private nCpoTABELA := 1
		Private nCpoCAMPO  := 2
		Private nCpoORDEM  := 3
		Private nCpoTIPDAD := 4
		Private nCpoTITULO := 5
		Private nCpoTAMANH := 6
		Private nCpoDECIMA := 7
		Private nCpoPICTUR := 8
		Private nCpoOPCOES := 9
		Private nCpoREAL   := 10
		Private nCpoOBRIGA := 11
		Private nCpoSELECT := 12
		Private nCpoSize   := 12
		// Posi��es 'aParams'
		Private nParPARAM  := 1
		Private nParORDEM  := 2
		Private nParTIPDAD := 3
		Private nParCONTEU := 4
		Private nParTITULO := 5
		Private nParSize   := 5

	// Vari�veis dos Tipos de Impress�o
	Private aBotoes := {}
	Private nTipoImp := 0
		// Tipos de Impress�o
		Private nTipPROTHE := 1
		Private nTipWORD   := 2
		Private nTipEXCEL  := 3

	// Vari�veis de estilos de CSS
	Private nCSSTipEsp := 1
	Private nCSSTipSel := 2
	Private nCSSLink   := 3
	Private nCSSCarreg := 4

	// Vari�veis dos Browses
	Private oFoldVars
	Private oBrwTbls
	Private oBrwCpos
	Private lAutoLoad := .T.
	Private oBtnLoad

	// Vari�veis dos Modelos de Impress�o
	Private cUltModCod := ""
	Private cUltModDes := ""

	//-- Carrega dados do Hist�rico
	MsgRun(STR0007, STR0008, {|| lDados := fLoadHist(cCodFilTZE, cCodHisTZE) }) //"Carregando dados do hist�rico..." ## "Por favor, aguarde..."
	If !lDados
		ShowHelpDlg(STR0001, {STR0009}, 2, {STR0010}, 2) //"Aten��o" ## "N�o h� dados para imprimir." ## "A impress�o ser� abortada."
		Return .F.
	EndIf

	//-- Bot�es adicionais da EnchoiceBar
	aAdd(aEncBtns, {"reload", {|| fRestVars() }, STR0011, STR0011}) //"Restaurar" ## "Restaurar"
	aAdd(aEncBtns, {"bmpsdoc", {|| fModelos() }, STR0012, STR0012}) //"Modelos" ## "Modelos"

	//--------------------
	// Monta Dialog
	//--------------------
	dbSelectArea("TZE")
	dbSetOrder(1)
	dbSeek(cCodFilTZE + cCodHisTZE)
	RegToMemory("TZE", .F.)

	DEFINE MSDIALOG oDlg011 TITLE cDlg011 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

		// FWLayer
		oLayer011 := FWLayer():New()
		oLayer011:Init(oDlg011, .F.)
		fLayout() // Cria o Layout da Tela

		// Painel Preto sobre a tela de impress�o
		oBlackPnl := TPanel():New(0, 0, , oDlg011, , , , , SetTransparentColor(CLR_BLACK,70), aSize[6], aSize[5], .F., .F.)
		oBlackPnl:Hide()

	ACTIVATE MSDIALOG oDlg011 ON INIT EnchoiceBar(oDlg011, ;
		{|| lDlg011 := .T., If(fVldReport(),fExecReport(), lDlg011 := .F.) }, ;
		{|| lDlg011 := .F., oDlg011:End() }, , aEncBtns) CENTERED

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadHist
Carrega os dados do hist�rico para a mem�ria.

@author Wagner Sobral de Lacerda
@since 28/11/2012

@param cCodFilTZE
	C�digo da Filial da tabela TZE * Obrigat�rio
@param cCodHisTZE
	C�digo do Hist�rico da tabela TZE * Obrigat�rio

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fLoadHist(cCodFilTZE, cCodHisTZE)

	// Vari�veis da Query
	Local cQryAlias := GetNextAlias()
	Local cQryExec  := ""

	Local cWhereTZF := "WHERE TZF.TZF_FILIAL = " + ValToSQL(cCodFilTZE) + " AND TZF.TZF_CODIGO = " + ValToSQL(cCodHisTZE) + " AND TZF.D_E_L_E_T_ <> '*' "
	Local cWhereTZG := "WHERE TZG.TZG_FILIAL = " + ValToSQL(cCodFilTZE) + " AND TZG.TZG_CODIGO = " + ValToSQL(cCodHisTZE) + " AND TZG.D_E_L_E_T_ <> '*' "
	Local cWhereTZI := "WHERE TZI.TZI_FILIAL = " + ValToSQL(cCodFilTZE) + " AND TZI.TZI_CODIGO = " + ValToSQL(cCodHisTZE) + " AND TZI.D_E_L_E_T_ <> '*' "

	// Vari�veis auxiliares
	Local nCampo := 0, nParam := 0
	Local lObrigat := .F.
	Local nLen := 0
	Local nX := 0
	Local aOpcoes := {}, nOpcao := 0

	//------------------------------
	// Vari�veis
	//------------------------------
	aVariaveis := {}

	// SELECT
	cQryExec := "SELECT "
	cQryExec += " DISTINCT(TZI.TZI_VARIAV), "
	cQryExec += " TZI.TZI_VARNOM "
	// FROM
	cQryExec += "FROM " + RetSQLName("TZI") + " TZI "
	// WHERE
	cQryExec += cWhereTZI
	// ORDER BY
	cQryExec += "ORDER BY "
	cQryExec += " TZI.TZI_VARIAV "

	// Executa a Query
	cQryExec := ChangeQuery(cQryExec)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .T., .T.)

	// Armazena as Vari�veis
	dbSelectArea(cQryAlias)
	dbGoTop()
	While !Eof()
		aAdd(aVariaveis, Array(nVarSize))
		nLen := Len(aVariaveis)
			aVariaveis[nLen][nVarVARIAV] := (cQryAlias)->TZI_VARIAV // Vari�vel
			aVariaveis[nLen][nVarVARNOM] := fNoChar((cQryAlias)->TZI_VARNOM) // Nome da Vari�vel
		dbSelectArea(cQryAlias)
		dbSkip()
	End
	(cQryAlias)->( dbCloseArea() )
		// Ordena
		aSort(aVariaveis, , , {|x,y| x[nVarVARIAV] < y[nVarVARIAV] }) // Vari�vel

	//------------------------------
	// Tabelas
	//------------------------------
	aTabelas := {}

	// SELECT
	cQryExec := "SELECT "
	cQryExec += " TZF.TZF_VARIAV, "
	cQryExec += " TZF.TZF_TABELA "
	// FROM
	cQryExec += "FROM " + RetSQLName("TZF") + " TZF "
	// WHERE
	cQryExec += cWhereTZF
	// GROUP BY
	cQryExec += "GROUP BY "
	cQryExec += " TZF.TZF_VARIAV, "
	cQryExec += " TZF.TZF_TABELA "
	// ORDER BY
	cQryExec += "ORDER BY "
	cQryExec += " TZF.TZF_VARIAV, "
	cQryExec += " TZF.TZF_TABELA "

	// Executa a Query
	cQryExec := ChangeQuery(cQryExec)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .T., .T.)

	// Armazena as Tabelas
	dbSelectArea(cQryAlias)
	dbGoTop()
	While !Eof()
		aAdd(aTabelas, Array(nTblSize))
		nLen := Len(aTabelas)
			aTabelas[nLen][nTblVARIAV] := (cQryAlias)->TZF_VARIAV // Vari�vel
			aTabelas[nLen][nTblTABELA] := (cQryAlias)->TZF_TABELA // Tabela
			aTabelas[nLen][nTblNOME]   := FWX2Nome((cQryAlias)->TZF_TABELA) // Nome da Tabela
			aTabelas[nLen][nTblSELECT] := .F. // Selecionado?
		dbSelectArea(cQryAlias)
		dbSkip()
	End
	(cQryAlias)->( dbCloseArea() )
		// Ordena
		aSort(aTabelas, , , {|x,y| x[nTblVARIAV]+x[nTblTABELA] < y[nTblVARIAV]+y[nTblTABELA] }) // Vari�vel + Tabela

	//------------------------------
	// Campos
	//------------------------------
	aCampos := {}

	// SELECT
	cQryExec := "SELECT "
	cQryExec += " TZF.TZF_VARIAV, "
	cQryExec += " TZF.TZF_TABELA, "
	cQryExec += " TZF.TZF_CAMPO "
	// FROM
	cQryExec += "FROM " + RetSQLName("TZF") + " TZF "
	// WHERE
	cQryExec += cWhereTZF
	// GROUP BY
	cQryExec += "GROUP BY "
	cQryExec += " TZF.TZF_VARIAV, "
	cQryExec += " TZF.TZF_TABELA, "
	cQryExec += " TZF.TZF_CAMPO "
	// ORDER BY
	cQryExec += "ORDER BY "
	cQryExec += " TZF.TZF_VARIAV, "
	cQryExec += " TZF.TZF_TABELA, "
	cQryExec += " TZF.TZF_CAMPO "

	// Executa a Query
	cQryExec := ChangeQuery(cQryExec)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .T., .T.)

	// Armazena os Campos
	dbSelectArea(cQryAlias)
	dbGoTop()
	While !Eof()
		dbSelectArea("TZF")
		dbSetOrder(4)
		If dbSeek(cCodFilTZE + cCodHisTZE + (cQryAlias)->TZF_VARIAV + (cQryAlias)->TZF_TABELA + (cQryAlias)->TZF_CAMPO)
			lObrigat := X3Obrigat(TZF->TZF_CAMPO)
			nCampo := aScan(aCampos, {|x| x[1] == TZF->TZF_VARIAV .And. x[2] == TZF->TZF_TABELA })
			If nCampo == 0
				// 1          ; 2        ; 3
				// [Vari�vel] ; [Tabela] ; {Campos}
				aAdd(aCampos, {TZF->TZF_VARIAV, TZF->TZF_TABELA, {}})
				nCampo := Len(aCampos)
			EndIf
			aAdd(aCampos[nCampo][3], Array(nCpoSize))
			nLen := Len(aCampos[nCampo][3])
				aCampos[nCampo][3][nLen][nCpoTABELA] := TZF->TZF_TABELA // Tabela
				aCampos[nCampo][3][nLen][nCpoCAMPO]  := TZF->TZF_CAMPO // Campo
				aCampos[nCampo][3][nLen][nCpoORDEM]  := TZF->TZF_ORDEM // Ordem
				aCampos[nCampo][3][nLen][nCpoTIPDAD] := TZF->TZF_TIPDAD // Tipo de Dado
				aCampos[nCampo][3][nLen][nCpoTITULO] := fNoChar(TZF->TZF_AUXTIT) // T�tulo
				aCampos[nCampo][3][nLen][nCpoTAMANH] := TZF->TZF_AUXTAM // Tamanho
				aCampos[nCampo][3][nLen][nCpoDECIMA] := TZF->TZF_AUXDEC // Decimal
				aCampos[nCampo][3][nLen][nCpoPICTUR] := TZF->TZF_AUXPIC // Picture
				aCampos[nCampo][3][nLen][nCpoOPCOES] := TZF->TZF_AUXOPC // Op��es
				aCampos[nCampo][3][nLen][nCpoREAL]   := .T. // Real?
				aCampos[nCampo][3][nLen][nCpoOBRIGA] := lObrigat // Obrigat�rio?
				aCampos[nCampo][3][nLen][nCpoSELECT] := .F. // Selecionado?
		EndIf
		dbSelectArea(cQryAlias)
		dbSkip()
	End
	(cQryAlias)->( dbCloseArea() )
		// Ordena
		aSort(aCampos, , , {|x,y| x[1]+x[2] < y[1]+y[2] }) // Vari�vel + Tabela
		For nX := 1 To Len(aCampos)
			aSort(aCampos[nX][3], , , {|x,y| x[nCpoTABELA]+x[nCpoORDEM] < y[nCpoTABELA]+y[nCpoORDEM] }) // Tabela + Ordem
		Next nX

	//------------------------------
	// Par�metros
	//------------------------------
	aParams := {}

	// SELECT
	cQryExec := "SELECT "
	cQryExec += " TZG.TZG_VARIAV, "
	cQryExec += " TZG.TZG_PARAM, "
	cQryExec += " TZG.TZG_ORDEM, "
	cQryExec += " TZG.TZG_TIPDAD, "
	cQryExec += " TZG.TZG_CONTEU, "
	cQryExec += " TZG.TZG_AUXTIT, "
	cQryExec += " TZG.TZG_AUXTAM, "
	cQryExec += " TZG.TZG_AUXDEC, "
	cQryExec += " TZG.TZG_AUXPIC, "
	cQryExec += " TZG.TZG_AUXOPC "
	// FROM
	cQryExec += "FROM " + RetSQLName("TZG") + " TZG "
	// WHERE
	cQryExec += cWhereTZG

	// Executa a Query
	cQryExec := ChangeQuery(cQryExec)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .T., .T.)

	// Armazena os Par�metros
	dbSelectArea(cQryAlias)
	dbGoTop()
	While !Eof()
		nParam := aScan(aParams, {|x| x[1] == (cQryAlias)->TZG_VARIAV })
		If nParam == 0
			// 1          ; 2
			// [Vari�vel] ; {Par�metros}
			aAdd(aParams, {(cQryAlias)->TZG_VARIAV, {}})
			nParam := Len(aParams)
		EndIf
		aAdd(aParams[nParam][2], Array(nParSize))
		nLen := Len(aParams[nParam][2])
			aParams[nParam][2][nLen][nParPARAM]  := (cQryAlias)->TZG_PARAM // Par�metro
			aParams[nParam][2][nLen][nParORDEM]  := (cQryAlias)->TZG_ORDEM // Ordem
			aParams[nParam][2][nLen][nParTIPDAD] := (cQryAlias)->TZG_TIPDAD // Tipo de Dado
			aParams[nParam][2][nLen][nParCONTEU] := NGI6CONVER((cQryAlias)->TZG_CONTEU, (cQryAlias)->TZG_TIPDAD) // Conte�do
			aParams[nParam][2][nLen][nParTITULO] := fNoChar((cQryAlias)->TZG_AUXTIT) // T�tulo
			// Se possuir Op��es (ComboBox)
			If !Empty((cQryAlias)->TZG_AUXOPC)
				aOpcoes := StrTokArr(AllTrim((cQryAlias)->TZG_AUXOPC), ";")
				nOpcao := aScan(aOpcoes, {|x| SubStr(x,1,AT("=",x)-1) == AllTrim(aParams[nParam][2][nLen][nParCONTEU]) })
				If nOpcao > 0
					aParams[nParam][2][nLen][nParCONTEU] := aOpcoes[nOpcao]
				EndIf
			EndIf
		dbSelectArea(cQryAlias)
		dbSkip()
	End
	(cQryAlias)->( dbCloseArea() )
		// Ordena
		aSort(aParams, , , {|x,y| x[1] < y[1] }) // Vari�vel
		For nX := 1 To Len(aParams)
			aSort(aParams[nX][2], , , {|x,y| x[nParORDEM] < y[nParORDEM] }) // Ordem
		Next nX

	// BackUp
	aBkpVars := aClone(aVariaveis)
	aBkpTbls := aClone(aTabelas)
	aBkpCpos := aClone(aCampos)
	aBkpPars := aClone(aParams)

Return ( Len(aVariaveis) > 0 )

//---------------------------------------------------------------------
/*/{Protheus.doc} fLayout
Monta o Layout da Tela Principal.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLayout()

	// Vari�veis auxiliares da tela
	Local aScreen  := aClone( GetScreenRes() )
	//Local nAltura  := aScreen[1]
	Local nLargura := aScreen[2]
	Local nPixeTip := 200
	Local nPorcTip := ( (nPixeTip * 100) / nLargura )

	// Linhas
	oLayer011:AddLine("Linha_Report"/*cId*/, 097/*nPercHeight*/, .F./*lFixed*/)

		// Colunas
		oLayer011:AddCollumn("Coluna_Tipos"/*cId*/, nPorcTip/*nPercWidth*/, .F./*lFixed*/, "Linha_Report"/*cIDLine*/)
		oLayer011:AddCollumn("Coluna_Config"/*cId*/, (100-nPorcTip)/*nPercWidth*/, .F./*lFixed*/, "Linha_Report"/*cIDLine*/)

			// Janela dos Tipos de Impress�o
			oLayer011:AddWindow("Coluna_Tipos"/*cIDCollumn*/, "Janela_Tipos"/*cIDWindow*/, OemToAnsi(STR0013)/*cTitle*/, 100/*nPercHeight*/, ; //"Tipos de Impress�o"
								.F./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Report"/*cIDLine*/, /*bGotFocus*/)
			// Janela do Resumo do Hist�rico
			oLayer011:AddWindow("Coluna_Config"/*cIDCollumn*/, "Janela_Resumo"/*cIDWindow*/, OemToAnsi(STR0014)/*cTitle*/, 030/*nPercHeight*/, ; //"Hist�rico"
								.T./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Report"/*cIDLine*/, /*bGotFocus*/)
			// Janela das Configura��es de Impress�o
			oLayer011:AddWindow("Coluna_Config"/*cIDCollumn*/, "Janela_Config"/*cIDWindow*/, OemToAnsi(STR0015)/*cTitle*/, 070/*nPercHeight*/, ; //"Configura��es"
								.F./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Report"/*cIDLine*/, /*bGotFocus*/)

	// Objetos dos Pain�is
	o011Tipo   := oLayer011:GetWinPanel("Coluna_Tipos"/*cIDCollumn*/, "Janela_Tipos"/*cIDWindow*/, "Linha_Report"/*cIDLine*/)
	o011Hist   := oLayer011:GetWinPanel("Coluna_Config"/*cIDCollumn*/, "Janela_Resumo"/*cIDWindow*/, "Linha_Report"/*cIDLine*/)
	o011Config := oLayer011:GetWinPanel("Coluna_Config"/*cIDCollumn*/, "Janela_Config"/*cIDWindow*/, "Linha_Report"/*cIDLine*/)

	// Monta Pain�is
	fMontaTipo(o011Tipo)
	fMontaHist(o011Hist)
	fMontaConfig(o011Config)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaHist
Visualiza��o do Hist�rico.

@author Wagner Sobral de Lacerda
@since 07/12/2012

@param oObjPai
	Objeto Pai * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMontaHist(oObjPai)

	// Vari�veis auxiliares
	Local oHist
	Local aPosObj := {0,0,(oObjPai:nClientHeight*0.50),(oObjPai:nClientWidth*0.50)} // {"TOP","LEFT","BOTTOM","RIGHT"}
	Private aRotina := {}

	//-- Define 'aRotina'
	aAdd(aRotina, {"", "", 0, 1})
	aAdd(aRotina, {"", "", 0, 2})
	aAdd(aRotina, {"", "", 0, 3})
	aAdd(aRotina, {"", "", 0, 4})
	aAdd(aRotina, {"", "", 0, 5})

	//-- Monta
	oHist := MsMGet():New("TZE",RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aChoice*/,aPosObj/*aPos*/,/*aCpos*/,;
						  		3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oObjPai/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
								/*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/)
	oHist:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaTipo
Monta os Tipos de Impress�o.

@author Wagner Sobral de Lacerda
@since 28/11/2012

@param oObjPai
	Objeto Pai * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMontaTipo(oObjPai)

	// Vari�veis para a Montagem
	Local oPnlTipos
	Local aOpcoes := {}

	Local cTitulo := ""
	Local cAction := ""

	Local nX := 0

	Local oSeparador

	//----------
	// Monta
	//----------
	// Painel com os Tipos de Impress�o
	oPnlTipos := TPanel():New(01, 01, , oObjPai, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlTipos:Align := CONTROL_ALIGN_ALLCLIENT

		//-- Define as op��es de Impress�o
		aBotoes := {}
		aAdd(aBotoes, {"Protheus Report", nTipPROTHE, Nil})
		//aAdd(aBotoes, {"Documento Microsoft Word", nTipWORD, Nil})
		aAdd(aBotoes, {STR0016 + " " + "Microsoft Excel", nTipEXCEL, Nil}) //"Planilha"

		// Monta as Op��es
		For nX := 1 To Len(aBotoes)
			cTitulo := "'" + aBotoes[nX][1] + "'"
			cAction := "{|| fTipoBotao(" + cValToChar(aBotoes[nX][2]) + ") }"

			// Bot�o
			aBotoes[nX][3] := TButton():New(001, 001, &(cTitulo), oPnlTipos, &(cAction),;
	  						100, 015, , , .F., .T., .F., , .F., , , .F.)
			aBotoes[nX][3]:lCanGotFocus := .F.
			aBotoes[nX][3]:Align := CONTROL_ALIGN_TOP
			// CSS do Bot�o "Tipo de Impress�o"
			fSetCSS(nCSSTipEsp, aBotoes[nX][3])

			// Separador
			oSeparador := TPanel():New(01, 01, , oPnlTipos, , , , CLR_BLACK, RGB(212,225,238), 100, 001)
			oSeparador:Align := CONTROL_ALIGN_TOP
		Next nX

		// Inicializa no primeiro bot�o
		fTipoBotao(1)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fTipoBotao
Executa a A��o do Bot�o do Tipo de Impress�o.

@author Wagner Sobral de Lacerda
@since 01/10/2012

@param nBotao
	Indica qual o bot�o que foi clicado * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fTipoBotao(nBotao)

	// Vari�eis auxiliares
	Local nX := 0

	//----------
	// Executa
	//----------
	For nX := 1 To Len(aBotoes)
		// CSS do Bot�o "Tipo de Impress�o"
		fSetCSS(If(nBotao == aBotoes[nX][2], nCSSTipSel, nCSSTipEsp), aBotoes[nX][3])
	Next nX
	nTipoImp := nBotao

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaConfig
Monta as Configura��es de Impress�o.

@author Wagner Sobral de Lacerda
@since 28/11/2012

@param oObjPai
	Objeto Pai * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMontaConfig(oObjPai)

	// Vari�veis para a Montagem
	Local oPnlConfig
	Local aFoldVars := {}
	Local oSplitter

	Local oMainTbls, oPnlTbls
	Local oMainCpos, oPnlCpos
	Local oPnlBtns

	Local aMark := {}, aHeader := {}, aHeadClick := {}

	Local nVar := 0
	Local nX := 0

	Local cTitulo := ""

	//-- Recebe as Vari�veis para montar o Folder
	For nVar := 1 To Len(aVariaveis)
		aAdd(aFoldVars, aVariaveis[nVar][nVarVARIAV])
	Next nVar

	//----------
	// Monta
	//----------
	// Painel com os Configura��es da Impress�o
	oPnlConfig := TPanel():New(01, 01, , oObjPai, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlConfig:Align := CONTROL_ALIGN_ALLCLIENT

		// Monta o Folder
		oFoldVars := TFolder():New(01, 01, aFoldVars, aFoldVars, oPnlConfig, 1, CLR_BLACK, CLR_WHITE, .T., , 100, 025)
		oFoldVars:bChange := {|| fFolRepSel(aFoldVars[oFoldVars:nOption]) }
		oFoldVars:Align := CONTROL_ALIGN_TOP

			// T�tulo auxiliar nas abas
			For nX := 1 To Len(aFoldVars)
				cTitulo := "{|| '" + STR0017 + "' + ' ' + '" + AllTrim(aFoldVars[nX]) + ":' } " //"Selecione as tabelas para imprimir da vari�vel"
				TSay():New(003, 005, &(cTitulo), oFoldVars:aDialogs[nX], , , , ;
							, , .T., CLR_BLACK, CLR_WHITE, 200, 015)
			Next nX

		// Separador entre as Tabelas e os Campos
		oSplitter := TSplitter():New(01, 01, oPnlConfig, 10, 10)
		oSplitter:SetOrient(1) // Barra Horizontal
		oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

			//-- Painel Principal das Tabelas
			oMainTbls := TPanel():New(01, 01, , oSplitter, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oMainTbls:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel dos Bot�es
				oPnlBtns := TPanel():New(01, 01, , oMainTbls, , , , CLR_BLACK, CLR_WHITE, 100, 015)
				oPnlBtns:Align := CONTROL_ALIGN_TOP

					// Bot�o: Localizar
					oTmpBtn := TButton():New(003, 002, STR0018, oPnlBtns, {|| fBrwLocali(1) },; //"Localizar"
		  							028, 012, , , .F., .T., .F., , .F., , , .F.)
					oTmpBtn:lCanGotFocus := .F.
					// CSS do Bot�o "Tipo de Impress�o"
					fSetCSS(nCSSLink, oTmpBtn)

				// Painel das Tabelas
				oPnlTbls := TPanel():New(01, 01, , oMainTbls, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlTbls:Align := CONTROL_ALIGN_ALLCLIENT

					//--------------------
					// Browse das Tabelas
					//--------------------
					// Colunas de Marca��o
					aMark := {	{{|| fBrwSetMrk(1) }, {|| fBrwMrkClk(1, aFoldVars[oFoldVars:nOption]) }, {|| fBrwMrkClk(1, aFoldVars[oFoldVars:nOption], .T.) }} }
					// Colunas de Cabe�alho normais
					aHeader := {	{STR0019, "C", 10, "", nTblTABELA}, ; //"Tabela"
									{STR0020, "C", 30, "", nTblNOME} } //"Descri��o"
					// Clique no Cabe�alho das Colunas
					aHeadClick := { {|| fBrwMrkClk(1, aFoldVars[oFoldVars:nOption], .T.) } } // 1 - Mark
					// Browse
					oBrwTbls := fMontaBrowse(@oPnlTbls, aClone(aMark), aClone(aHeader), aClone(aHeadClick))
					oBrwTbls:SetDoubleClick({|| fBrwMrkClk(1, aFoldVars[oFoldVars:nOption]) })

			//-- Painel Principal dos Campos
			oMainCpos := TPanel():New(01, 01, , oSplitter, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oMainCpos:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel dos Bot�es 1
				oPnlBtns := TPanel():New(01, 01, , oMainCpos, , , , CLR_BLACK, CLR_WHITE, 100, 020)
				oPnlBtns:Align := CONTROL_ALIGN_TOP

					// Bot�o: Carregar Campos
					oBtnLoad := TButton():New(003, 005, STR0021, oPnlBtns, {|| fSetCampos(aFoldVars[oFoldVars:nOption]) },; //"Recarregar Campos"
		  							060, 015, , , .F., .T., .F., , .F., , , .F.)
					oBtnLoad:lCanGotFocus := .F.
					fSetCSS(nCSSCarreg, oBtnLoad)
					If lAutoLoad
						oBtnLoad:Disable()
					EndIf

					// CheckBox: Aglutinar campos das tabelas
					TCheckBox():New(008, 080, STR0022, {|| lAutoLoad }, oPnlBtns, 150, 015, , ; //"Carregar automaticamente os campos"
									{|| lAutoLoad := !lAutoLoad, If(lAutoLoad,fSetCampos(aFoldVars[oFoldVars:nOption]),), If(lAutoLoad,oBtnLoad:Disable(),oBtnLoad:Enable()) }, ;
									, , , , , .T., , ,)

				// Painel dos Bot�es 2
				oPnlBtns := TPanel():New(01, 01, , oMainCpos, , , , CLR_BLACK, CLR_WHITE, 100, 015)
				oPnlBtns:Align := CONTROL_ALIGN_TOP

					// Bot�o: Localizar
					oTmpBtn := TButton():New(003, 002, STR0018, oPnlBtns, {|| fBrwLocali(2) },; //"Localizar"
		  							026, 012, , , .F., .T., .F., , .F., , , .F.)
					oTmpBtn:lCanGotFocus := .F.
					// CSS do Bot�o "Tipo de Impress�o"
					fSetCSS(nCSSLink, oTmpBtn)
					// Bot�o: Adicionar Campos Virtuais
					oTmpBtn := TButton():New(003, 038, STR0023, oPnlBtns, {|| fBrwAddCpo(aFoldVars[oFoldVars:nOption]) },; //"Campos Virtuais"
		  							045, 012, , , .F., .T., .F., , .F., , , .F.)
					oTmpBtn:lCanGotFocus := .F.
					// CSS do Bot�o "Tipo de Impress�o"
					fSetCSS(nCSSLink, oTmpBtn)
					// Bot�o: Excluir Campo
					oTmpBtn := TButton():New(003, 093, STR0024, oPnlBtns, {|| fBrwDelCpo(aFoldVars[oFoldVars:nOption]) },; //"Excluir Desabilitados"
		  							055, 012, , , .F., .T., .F., , .F., , , .F.)
					oTmpBtn:lCanGotFocus := .F.
					// CSS do Bot�o "Tipo de Impress�o"
					fSetCSS(nCSSLink, oTmpBtn)

				// Painel dos Campos
				oPnlCpos := TPanel():New(01, 01, , oMainCpos, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlCpos:Align := CONTROL_ALIGN_ALLCLIENT

					//--------------------
					// Browse dos Campos
					//--------------------
					// Colunas de Marca��o
					aMark := {	{{|| fBrwSetMrk(2) }, {|| fBrwMrkClk(2, aFoldVars[oFoldVars:nOption]) }, {|| fBrwMrkClk(2, aFoldVars[oFoldVars:nOption], .T.) }} }
					// Colunas de Cabe�alho normais
					aHeader := {	{STR0019, "C", 010, "", nCpoTABELA}, ; //"Tabela"
									{STR0025, "C", 010, "", nCpoCAMPO }, ; //"Campo"
									{STR0020, "C", 030, "", nCpoTITULO}, ; //"Descri��o"
									{STR0026, "X", 010, "", nCpoREAL  }, ; //"Real?"
									{STR0027, "X", 010, "", nCpoOBRIGA} } //"Obrigat�rio?"
					// Clique no Cabe�alho das Colunas
					aHeadClick := {	{|| fBrwMrkClk(2, aFoldVars[oFoldVars:nOption], .T.) }, ; // 1 - Mark
									Nil, ; // 2 - Tabela
									Nil, ; // 3 - Campo
									Nil, ; // 4 - Descri��o
									{|| fBrwMrkClk(2, aFoldVars[oFoldVars:nOption], , 1) }, ; // 5 - Real?
									{|| fBrwMrkClk(2, aFoldVars[oFoldVars:nOption], , 2) } ; // 6 - Obrigat�rio?
									}
					// Browse
					oBrwCpos := fMontaBrowse(@oPnlCpos, aClone(aMark), aClone(aHeader), aClone(aHeadClick))
					oBrwCpos:SetDoubleClick({|| fBrwMrkClk(2, aFoldVars[oFoldVars:nOption]) })

			// Inicia o Folder
			Eval( oFoldVars:bChange )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRestVars
Restaura a Carga inicial das Vari�veis de Impress�o.
(Vari�veis, Tabelas e Campos)

@author Wagner Sobral de Lacerda
@since 25/10/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fRestVars()

	//----------
	// Executa
	//----------
	// Restaura Arrays
	aVariaveis := aClone(aBkpVars)
	aTabelas   := aClone(aBkpTbls)
	aCampos    := aClone(aBkpCpos)
	// Atualiza
	Eval(oFoldVars:bChange)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFolRepSel
Executa a Sele��o do Folder.

@author Wagner Sobral de Lacerda
@since 22/10/2012

@param cCodVariav
	C�digo da Vari�vel do Indicador * Obrigat�rio

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fFolRepSel(cCodVariav)

	//----------
	// Executa
	//----------
	// Carrega as Tabelas da Vari�vel
	fSetTabelas(cCodVariav)
	// Carrega os Campos das Tabelas Selecionadas
	fSetCampos(cCodVariav)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSetTabelas
Carrega as Tabelas no Browse.

@author Wagner Sobral de Lacerda
@since 22/10/2012

@param cCodVariav
	C�digo da Vari�vel do Indicador * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetTabelas(cCodVariav)

	// Vari�veis auxiliares
	Local aRetTbls := {}
	Local nX := 0

	Local nScanTbl := aScan(aTabelas, {|x| AllTrim(x[nTblVARIAV]) == AllTrim(cCodVariav) })

	//----------
	// Executa
	//----------
	// Cursor em Espera
	CursorArrow()
	If nScanTbl > 0
		// Carrega
		For nX := nScanTbl To Len(aTabelas)
			If AllTrim(aTabelas[nX][nTblVARIAV]) <> AllTrim(cCodVariav)
				Exit
			EndIf
			aAdd(aRetTbls, {aTabelas[nX][nTblTABELA], aTabelas[nX][nTblNOME], aTabelas[nX][nTblSELECT]})
		Next nX
	EndIf
	// Cursor Normal
	CursorArrow()

	// Seta o Array do Browse
	oBrwTbls:SetArray(aRetTbls)
	oBrwTbls:GoTop()
	oBrwTbls:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSetCampos
Carrega os Campos no Browse.

@author Wagner Sobral de Lacerda
@since 22/10/2012

@param cCodVariav
	C�digo da Vari�vel do Indicador * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetCampos(cCodVariav)

	// Vari�veis auxiliares
	Local aArrayTbls := aClone( oBrwTbls:Data():GetArray() )

	Local aRetCpos := {}
	Local nTbl := 0, nCpo := 0

	Local nScanVar := aScan(aCampos, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) })
	Local nScanCpo := 0

	//----------
	// Executa
	//----------
	// Cursor em Espera
	CursorArrow()
	If nScanVar > 0
		// Carrega os Campos das Tabelas que est�o Marcadas
		For nTbl := 1 To Len(aArrayTbls)
			// Se a Tabela estiver Selecionada
			If aArrayTbls[nTbl][3]
				// Carrega os Campo da Tabela
				nScanCpo := aScan(aCampos, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) .And. AllTrim(x[2]) == AllTrim(aArrayTbls[nTbl][1]) })
				If nScanCpo > 0
					For nCpo := 1 To Len(aCampos[nScanCpo][3])
						aAdd(aRetCpos, {aCampos[nScanCpo][3][nCpo][nCpoTABELA], aCampos[nScanCpo][3][nCpo][nCpoCAMPO], aCampos[nScanCpo][3][nCpo][nCpoTITULO], If(aCampos[nScanCpo][3][nCpo][nCpoREAL],"X"," "), If(aCampos[nScanCpo][3][nCpo][nCpoOBRIGA],"X"," "), aCampos[nScanCpo][3][nCpo][nCpoSELECT]})
					Next nCpo
				EndIf
			EndIf
		Next nTbl
	EndIf
	// Cursor Normal
	CursorArrow()

	// Seta o Array do Browse
	oBrwCpos:SetArray(aRetCpos)
	oBrwCpos:GoTop()
	oBrwCpos:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaBrowse
Monta a Window do Browse.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@param oParent
	Objeto Pai do Browse * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMontaBrowse(oParent, aMark, aHeader, aHeadClick)

	// Salva �reas atuais
	Local aAreaSX3 := SX3->( GetArea() )

	// Vari�vel do Browse
	Local oFWBrowse
	Local aColunas, oColuna
	Local cSetData

	Local oGrid
	Local cGridCSS

	// Vari�veis da tela
	Local aScreen := aClone( GetScreenRes() )
	Local nAltura := aScreen[1]
	Local nPixHeight := If(nAltura >= 1000, 25, 20)

	// Vari�veis auxiliares
	Local nHeader := 0

	// Defaults
	Default aMark      := {}
	Default aHeader    := {}
	Default aHeadClick := {}

	//-- Defini��es do 'aHeader'
	// 1      ; 2                ; 3       ; 4       ; 5
	// T�tulo ; Tipo de Conte�do ; Tamanho ; Picture ; Posi��o do Array de 'Data' (conte�do)

	//--------------------
	// Cria Browse
	//--------------------
	// Instancia a Classe
	oFWBrowse := FWBrowse():New(oParent)

	// Defini��es B�sicas do Objeto
	oFWBrowse:SetDataArray()
	oFWBrowse:SetInsert(.F.) // Desabilita a Inser��o de registros

	// Habilita/Desabilita op��es de Salvar, Imprimir, etc.
	oFWBrowse:DisableConfig() // Desabilita a Configura��o do browse
	oFWBrowse:DisableFilter() // Desabilita o Filtro
	oFWBrowse:DisableLocate() // Desabilita a Localiza��o
	oFWBrowse:DisableReport() // Desabilita o Relat�rio
	oFWBrowse:DisableSeek() // Desabilita a Pesquisa

	// Colunas de Status
	For nHeader := 1 To Len(aMark)
		oFWBrowse:AddMarkColumns(aMark[nHeader][1]/*bMark*/, aMark[nHeader][2]/*bLDblClick*/, aMark[nHeader][3]/*bHeaderClick*/)
	Next nHeader

	// Define as Colunas
	aColunas := {}
	For nHeader := 1 To Len(aHeader)
		// Instancia a Classe
		oColuna := FWBrwColumn():New()

		// Defini��es B�sicas do Objeto
		oColuna:SetAlign(If(aHeader[nHeader][2] == "N", CONTROL_ALIGN_RIGHT, If(aHeader[nHeader][2] == "X", CONTROL_ALIGN_NONE, CONTROL_ALIGN_LEFT)))
		oColuna:SetEdit(.F.)

		// Defini��es do Dado apresentado
		oColuna:SetSize(aHeader[nHeader][3])
		oColuna:SetTitle(aHeader[nHeader][1])
		oColuna:SetType(aHeader[nHeader][2])
		oColuna:SetPicture(aHeader[nHeader][4])

		cSetData := "{|oFWBrowse| oFWBrowse:Data():GetArray()[oFWBrowse:AT()][" + cValToChar(nHeader) + "] }"
		oColuna:SetData(&(cSetData))

		aAdd(aColunas, oColuna)
	Next nHeader
	oFWBrowse:SetColumns(aColunas)

	// Ativa o Objeto
	oFWBrowse:Activate()
	oFWBrowse:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	//--- CSS do Grid
	cGridCSS := "QTableView { "+;
						"background-color: #FFFFFF; "+; // Branco
						"color: #4D4D4D; "+; // Cinza Escuro
						"alternate-background-color: #FAFAFA; "+; // Cinza Claro
						"selection-background-color: #E5F5FF; "+; // Cinza Claro
						"selection-color: #000000; "+; // Preto
						"border: 1px solid #D3D3D3; "+; // Branco
						"font: bold 12px Arial; "+;
					"} "
	cGridCSS += "QHeaderView::Section { "+;
						"background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #FFFFFF, stop:0.3 #F2F2F2, stop:1 #D9D9D9); "+; // Cinza
						"color: #000000; "+; // Preto
						"border: 1px solid #D3D3D3; "+;
						"font: 12px Arial; "+;
						"font-weight: bold; "+;
						"height: " + cValToChar(nPixHeight) + "px; "+;
					" } "

	oGrid := oFWBrowse:Browse()
	oGrid:SetCSS(cGridCSS)
	oGrid:SetHeaderClick({|oGrid, nColumn| fBrwHeaClk(oGrid, nColumn, aHeadClick) })

	oFWBrowse:SetLineHeight(nPixHeight)
	For nHeader := 1 To ( Len(aHeader) + Len(aMark))
		oFWBrowse:SetHeaderImage(nHeader, "") // Limpa a Imagem do Header
	Next nHeader

	// Devolve as �reas
	RestArea(aAreaSX3)

Return oFWBrowse

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwHeaClk
Executa o Clique do Header do browse.

@author Wagner Sobral de Lacerda
@since 24/10/2012

@param oGrid
	Objeto do Grid * Obrigat�rio
@param nColumn
	Coluna do Header acionada * Obrigat�rio
@param aHeadClick
	Array com as a��es dos cliques nas colunas * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBrwHeaClk(oGrid, nColumn, aHeadClick)

	// Executa
	If nColumn <= Len(aHeadClick) .And. ValType(aHeadClick[nColumn]) == "B"
		Eval(aHeadClick[nColumn])
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwSetMrk
Marca��o do registro do Browse.

@author Wagner Sobral de Lacerda
@since 22/10/2012

@param nTipo
	Indica o Tipo do Status a selecionar: * Obrigat�rio
	   1 - Tabelas
	   2 - Campos

@return cImagem
/*/
//---------------------------------------------------------------------
Static Function fBrwSetMrk(nTipo)

	// Vari�vel da Imagem do Status
	Local cImagem := ""

	// Vari�veis do Browse
	Local aArray := {}
	Local nAT := 0

	//----------
	// Executa
	//----------
	If nTipo == 1
		//----------
		// Tabelas
		//----------
		// Recebe o Array
		aArray := aClone( oBrwTbls:Data():GetArray() )
		nAT := oBrwTbls:AT()

		// Define a Imagem
		If Len(aArray[nAT]) > 0 .And. ValType(aArray[nAT][1]) <> "U"
			If aArray[nAT][3] // Se Marcado
				cImagem := "checked_15"
			Else // Sen�o
				cImagem := "nochecked_15"
			EndIf
		EndIf
	ElseIf nTipo == 2
		//----------
		// Campos
		//----------
		// Recebe o Array
		aArray := aClone( oBrwCpos:Data():GetArray() )
		nAT := oBrwCpos:AT()

		// Define a Imagem
		If Len(aArray[nAT]) > 0 .And. ValType(aArray[nAT][1]) <> "U"
			If aArray[nAT][6] // Se Marcado
				cImagem := "enable"
			Else // Sen�o
				cImagem := "disable"
			EndIf
		EndIf
	EndIf

Return cImagem

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwMrkClk
Clique do registro de status do Browse.

@author Wagner Sobral de Lacerda
@since 22/10/2012

@param nTipo
	Indica o Tipo do Status a selecionar: * Obrigat�rio
	   1 - Tabelas
	   2 - Campos
@param cCodVariav
	C�digo da Vari�vel do Indicador * Obrigat�rio
@param lHeadClick
	Indica clique no Cabe�alho da Marca��o * Opcional
	   .T. - Cabe�alho
	   .F. - Normal
	Default: .F.
@param nHeadClick
	Indica o tipo de clique numa coluna * Opcional
	   0 - Normal
	   1 - Selecionar Reais
	   2 - Selecionar Obrigat�rios
	Default: 0

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBrwMrkClk(nTipo, cCodVariav, lHeadClick, nHeadClick)

	// Vari�veis auxiliares
	Local aArray := {}
	Local nAT := 0, nMax := 0
	Local nX := 0

	Local lSetEstado := Nil

	Local nScanTbl := 0, nScanCpo := 0

	// Defaults
	Default lHeadClick := .F.
	Default nHeadClick := 0

	//----------
	// Executa
	//----------
	If nTipo == 1
		//----------
		// Tabelas
		//----------
		// Recebe o Array
		aArray := oBrwTbls:Data():GetArray()

		// Define quais os itens que ser�o atualizados
		If lHeadClick
			nAT := 1
			nMax := Len(aArray)

			// O estado que ser� setado ser� sempre o contr�rio do que j� est� atualmente
			lSetEstado := aScan(aArray, {|x| x[3] }) > 0
			lSetEstado := !lSetEstado
		Else
			nAT := oBrwTbls:AT()
			nMax := nAT
		EndIf

		// Atualiza a Sele��o
		For nX := nAT To nMax
			If lHeadClick
				// Seta o Estado da Sele��o
				aArray[nX][3] := lSetEstado
			Else
				// Inverte o Estado da Sele��o
				aArray[nX][3] := !aArray[nX][3]
			EndIf

			// Atualiza o array principal
			nScanTbl := aScan(aTabelas, {|x| AllTrim(x[nTblVARIAV]) == AllTrim(cCodVariav) .And. AllTrim(x[nTblTABELA]) == AllTrim(aArray[nX][1]) })
			If nScanTbl > 0
				aTabelas[nScanTbl][nTblSELECT] := aArray[nX][3]
			EndIf
		Next nX

		// Atualiza o Browse
		If lHeadClick
			oBrwTbls:Refresh(.T.)
		EndIf

		// Atualiza os Campos
		If lAutoLoad
			fSetCampos(cCodVariav)
		EndIf
	ElseIf nTipo == 2
		//----------
		// Campos
		//----------
		// Recebe o Array
		aArray := oBrwCpos:Data():GetArray()

		// Define quais os itens que ser�o atualizados
		If lHeadClick .Or. nHeadClick > 0
			// Posiciona no primeiro registro
			oBrwCpos:GoTop()

			nAT := 1
			nMax := Len(aArray)

			// O estado que ser� setado ser� sempre o contr�rio do que j� est� atualmente
			If nHeadClick == 0
				lSetEstado := aScan(aArray, {|x| x[6] }) > 0
			Else
				If nHeadClick == 1
					lSetEstado := aScan(aArray, {|x| x[6] .And. x[4] == "X" }) > 0
				ElseIf nHeadClick == 2
					lSetEstado := aScan(aArray, {|x| x[6] .And. x[5] == "X" }) > 0
				EndIf
			EndIf
			lSetEstado := !lSetEstado
		Else
			nAT := oBrwCpos:AT()
			nMax := nAT
		EndIf
		// Atualiza a Sele��o
		For nX := nAT To nMax
			If lHeadClick .Or. nHeadClick > 0
				// Filtra
				If nHeadClick == 1 .And. aArray[nX][4] <> "X"
					Loop
				ElseIf nHeadClick == 2 .And. aArray[nX][5] <> "X"
					Loop
				EndIf

				// Seta o Estado da Sele��o
				aArray[nX][6] := lSetEstado
			Else
				// Inverte o Estado da Sele��o
				aArray[nX][6] := !aArray[nX][6]
			EndIf

			// Atualiza o array principal
			nScanTbl := aScan(aCampos, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) .And. AllTrim(x[2]) == AllTrim(aArray[nX][1]) })
			If nScanTbl > 0
				nScanCpo := aScan(aCampos[nScanTbl][3], {|x| AllTrim(x[nCpoCAMPO]) == AllTrim(aArray[nX][2]) })
				If nScanCpo > 0
					aCampos[nScanTbl][3][nScanCpo][nCpoSELECT] := aArray[nX][6]
				EndIf
			EndIf
		Next nX

		// Atualiza o Browse
		If lHeadClick .Or. nHeadClick > 0
			oBrwCpos:Refresh(.T.)
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwLocali
Localiza um Conte�do no Browse.

@author Wagner Sobral de Lacerda
@since 23/10/2012

@param nTipo
	Indica o Tipo do Status a selecionar: * Obrigat�rio
	   1 - Tabelas
	   2 - Campos

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fBrwLocali(nTipo)

	// Vari�veis do Dialog
	Local oDlgLoc
	Local cDlgLoc := OemToAnsi(STR0028 + " " + If(nTipo == 1, STR0029, STR0030)) //"Localizar em" ## "Tabelas" ## "Campos"
	Local lDlgLoc := .F.
	Local oPnlLoc

	// Vari�veis da Busca
	Local cBusca := Space(30)

	// Vari�veis auxiliares
	Local aArray := {}
	Local nArray := 0, nCol := 0
	Local nResult := 0

	// Mostra Painel Preto
	oBlackPnl:Show()

	//--------------------
	// Monta Dialog
	//--------------------
	DEFINE MSDIALOG oDlgLoc TITLE cDlgLoc FROM 0,0 TO 100,250 OF oMainWnd PIXEL

		// Painel principal do Dialog
		oPnlLoc := TPanel():New(01, 01, , oDlgLoc, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlLoc:Align := CONTROL_ALIGN_ALLCLIENT

			// Groupo: Busca
			TGroup():New(005, 005, (oPnlLoc:nClientHeight*0.50)-030, (oPnlLoc:nClientWidth*0.50)-005, STR0031, oPnlLoc, , , .T.) //"Busca"
				// Localizar
				TSay():New(017, 015, {|| OemToAnsi(STR0032) }, oPnlLoc, , , , ; //"Conte�do:"
											, , .T., CLR_BLACK, CLR_WHITE, 100, 015)
				TGet():New(016, 045, {|u| If(PCount() > 0, cBusca := u, cBusca) }, oPnlLoc, 070, 008, "@!", {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
				 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .F./*lHasButton*/)

			// Confirmar
			SButton():New((oPnlLoc:nClientHeight*0.50)-025, (oPnlLoc:nClientWidth*0.50)-061, 1, {|| lDlgLoc := .T., oDlgLoc:End() }, oDlgLoc, .T., , )
			// Cancelar
			SButton():New((oPnlLoc:nClientHeight*0.50)-025, (oPnlLoc:nClientWidth*0.50)-031, 2, {|| lDlgLoc := .F., oDlgLoc:End() }, oDlgLoc, .T., , )

	ACTIVATE MSDIALOG oDlgLoc CENTERED

	// Se confirmou
	If lDlgLoc
		//----------
		// Busca
		//----------
		If nTipo == 1
			//----------
			// Tabelas
			//----------
			// Recebe o Array
			aArray := oBrwTbls:Data():GetArray()
		ElseIf nTipo == 2
			//----------
			// Campos
			//----------
			// Recebe o Array
			aArray := oBrwCpos:Data():GetArray()
		EndIf
		For nArray := 1 To Len(aArray)
			For nCol := 1 To Len(aArray[nArray])
				If Upper(AllTrim(cBusca)) == Upper(AllTrim(aArray[nArray][nCol]))
					nResult := nArray
					Exit
				EndIf
			Next nCol
		Next nArray

		If nResult == 0
			MsgInfo(STR0033, STR0001) //"Registro n�o encontrado." ## "Aten��o"
		Else
			If nTipo == 1 ; oBrwTbls:GoTo(nResult) ; Else ; oBrwCpos:GoTo(nResult) ; EndIf
		EndIf
	EndIf

	// Esconde Painel Preto
	oBlackPnl:Hide()

Return ( nResult > 0 )

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwAddCpo
Adiciona um Campo para ser impresso na vari�vel.
APENAS CAMPOS VIRTUAIS PODEM SER ADICIONADOS!

@author Wagner Sobral de Lacerda
@since 24/10/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fBrwAddCpo(cCodVariav)

	// Salva �reas atuais
	Local aAreaSX3 := SX3->( GetArea() )
	Local aCampSX3 := {}

	// Vari�veis do Dialog
	Local oDlgAdd
	Local cDlgAdd := OemToAnsi(STR0034) //"Adicionar Campos Virtuais"
	Local lDlgAdd := .F.
	Local oPnlAdd

	// Vari�veis da �rvore
	Local oPnlTree
	Local oTree
	Local cNivMaster := ""

	// Vari�veis do Browse
	Local oPnlBrw
	Local aHeader := {}, nHeader
	Local aColunas := {}, oColuna
	Local aVirCampos := {}
	Local nVirTbl := 0
	Local lSelected := .F.

	// Vari�veis auxiliares
	Local nScanTbl := 0, nScanCpo := 0
	Local nX := 0, nY := 0
	Local nLen := 0

	// Vari�veis PRIVATE necess�rias
	Private oBrwVirtuais
	Private aVirtuais := {}

	// Mostra Painel Preto
	oBlackPnl:Show()

	//-- Recebe as tabelas selecionadas e os campos virtuais
	For nX := 1 To Len(aTabelas)
		If AllTrim(aTabelas[nX][nTblVARIAV]) == AllTrim(cCodVariav) .And. aTabelas[nX][nTblSELECT]
			aAdd(aVirtuais, {AllTrim(aTabelas[nX][nTblTABELA]), AllTrim(aTabelas[nX][nTblNOME]), {}})
			nVirTbl := Len(aVirtuais)
			aVirCampos := {}
			aCampSX3 := NGHeader( aTabelas[nX,nTblTABELA],,.F.)
			For nY := 1 To Len(aCampSX3)
				If aCampSX3[nY,10] == "V" // Caso campo seja Virtual.

					lSelected := .F.
					nScanTbl := aScan(aCampos, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) .And. AllTrim(x[2]) == AllTrim(aTabelas[nX][nTblTABELA]) })
					If nScanTbl > 0
						lSelected := ( aScan(aCampos[nScanTbl][3], {|x| AllTrim(x[nCpoCAMPO]) == AllTrim(aCampSX3[nY,2]) }) > 0)
					EndIf

					//| 1  | 2      | 3           |
					//| ID | T�tulo | Selecionado?|
					aAdd(aVirCampos, {AllTrim(aCampSX3[nY,2]), AllTrim(Posicione("SX3",2,aCampSX3[nY,2],"X3Descric()")), lSelected})

				EndIf
			Next nY
			aVirtuais[nVirTbl][3] := aClone( aVirCampos )
		EndIf
	Next nX

	//--------------------
	// Monta o Dialog
	//--------------------
	// Apenas campos VIRTUAIS podem ser adicionados porque os campos REAIS est�o gravados na tabela TZF, e qualquer conte�do que n�o esteja
	// nesta tabela n�o pode ser impresso. J� os campos virtuais s�o 'virtuais', ent�o n�o tem este problema, pois seu conte�do ser� recebido
	// dinamicamente atrav�s de uma fun��o.
	DEFINE MSDIALOG oDlgAdd TITLE cDlgAdd FROM 0,0 TO 450,700 OF oMainWnd PIXEL

		// Painel principal do Dialog
		oPnlAdd := TPanel():New(01, 01, , oDlgAdd, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlAdd:Align := CONTROL_ALIGN_ALLCLIENT
		oPnlAdd:CoorsUpdate()

			// Painel da �rvore com as Tabelas
			oPnlTree := TPanel():New(01, 01, , oPnlAdd, , , , CLR_BLACK, CLR_WHITE, 120, 100)
			oPnlTree:Align := CONTROL_ALIGN_LEFT
			oPnlTree:CoorsUpdate()

				// Monta �rvore
				oTree := DbTree():New(01, 01, 100, 100, oPnlTree, , , .T.)
				oTree:bChange := {|oObjTree| fBrwAddChg(oObjTree) }
				oTree:Align := CONTROL_ALIGN_ALLCLIENT

					// Inicia a atualiza��o da �rvore
					oTree:BeginUpdate()
					cNivMaster := "VIRTUAIS"
					oTree:AddTree(PADR(STR0029,40," "), .F., "cfgimg32", "cfgimg32", , , cNivMaster) //"Tabelas"
					For nX := 1 To Len(aVirtuais)
						cNivAtu := AllTrim(aVirtuais[nX][1])
						oTree:AddItem(AllTrim(aVirtuais[nX][1]) + " - " + AllTrim(aVirtuais[nX][2]), cNivAtu, "bmptable", "bmptable", , , 2)
						oTree:TreeSeek(cNivMaster)
					Next nX
					oTree:EndUpdate() // Finaliza a atualiza��o da �rvore
					oTree:PTRefresh() // Atualiza os N�veis
					oTree:EndTree() // Encerra a �rvore (� diferente de destruir)

			// Painel da �rvore com as Tabelas
			oPnlBrw := TPanel():New(01, 01, , oPnlAdd, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlBrw:Align := CONTROL_ALIGN_ALLCLIENT
			oPnlBrw:CoorsUpdate()

				//--------------------
				// Cria Browse
				//--------------------
				// Instancia a Classe
				oBrwVirtuais := FWBrowse():New(oPnlBrw)
				// Habilita/Desabilita op��es de Salvar, Imprimir, etc.
				oBrwVirtuais:DisableConfig() // Desabilita a Configura��o do browse
				oBrwVirtuais:DisableFilter() // Desabilita o Filtro
				oBrwVirtuais:DisableLocate() // Desabilita a Localiza��o
				oBrwVirtuais:DisableReport() // Desabilita o Relat�rio
				oBrwVirtuais:DisableSeek() // Desabilita a Pesquisa
				// Defini��es B�sicas do Objeto
				oBrwVirtuais:SetDataArray()
				oBrwVirtuais:SetInsert(.F.) // Desabilita a Inser��o de registros
				// Define as Colunas
				oBrwVirtuais:AddMarkColumns({|| fBrwAddMrk() }/*bMark*/, {|| fBrwAddClk(oTree) }/*bLDblClick*/, {|| fBrwAddClk(oTree, .T.) }/*bHeaderClick*/)
				aHeader := {	{STR0025, "C", 10, ""}, ; //"Campo"
								{STR0020, "C", 30, ""} } //"Descri��o"
				aColunas := {}
				For nHeader := 1 To Len(aHeader)
					// Instancia a Classe
					oColuna := FWBrwColumn():New()

					// Defini��es B�sicas do Objeto
					oColuna:SetAlign(If(aHeader[nHeader][2] == "N", CONTROL_ALIGN_RIGHT, If(aHeader[nHeader][2] == "X", CONTROL_ALIGN_NONE, CONTROL_ALIGN_LEFT)))
					oColuna:SetEdit(.F.)

					// Defini��es do Dado apresentado
					oColuna:SetSize(aHeader[nHeader][3])
					oColuna:SetTitle(aHeader[nHeader][1])
					oColuna:SetType(aHeader[nHeader][2])
					oColuna:SetPicture(aHeader[nHeader][4])

					cSetData := "{|oFWBrowse| oFWBrowse:Data():GetArray()[oFWBrowse:AT()][" + cValToChar(nHeader) + "] }"
					oColuna:SetData(&(cSetData))

					aAdd(aColunas, oColuna)
				Next nHeader
				oBrwVirtuais:SetColumns(aColunas)
				// Ativa o Objeto
				oBrwVirtuais:Activate()
				oBrwVirtuais:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
				oBrwVirtuais:SetDoubleClick({|| fBrwAddClk(oTree) })

		// Inicia a Tree
		Eval(oTree:bChange, oTree)
	ACTIVATE MSDIALOG oDlgAdd ON INIT EnchoiceBar(oDlgAdd, {|| lDlgAdd := .T., oDlgAdd:End() }, {|| lDlgAdd := .F., oDlgAdd:End() }) CENTERED

	//--------------------
	// Seta os Campos
	//--------------------
	If lDlgAdd
		For nX := 1 To Len(aVirtuais)
			nScanTbl := aScan(aCampos, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) .And. AllTrim(x[2]) == AllTrim(aVirtuais[nX][1]) })
			If nScanTbl > 0
				For nY := 1 To Len(aVirtuais[nX][3])
					nScanCpo := aScan(aCampos[nScanTbl][3], {|x| AllTrim(x[nCpoCAMPO]) == AllTrim(aVirtuais[nX][3][nY][1]) })
					If nScanCpo > 0 // Se existir o campo
						If !aVirtuais[nX][3][nY][3] // Se estiver DESMARCADO, exclui
							aDel(aCampos[nScanTbl][3], nScanCpo)
							aSize(aCampos[nScanTbl][3], (Len(aCampos[nScanTbl][3])-1))
						EndIf
					Else // Se n�o existir o campo
						If aVirtuais[nX][3][nY][3] // Se estiver MARCADO, inclui
							dbSelectArea("SX3")
							dbSetOrder(2)
							If dbSeek(aVirtuais[nX][3][nY][1])
								aAdd(aCampos[nScanTbl][3], Array(nCpoSize))
								nLen := Len(aCampos[nScanTbl][3])
									aCampos[nScanTbl][3][nLen][nCpoTABELA] := Posicione("SX3",2,aVirtuais[nX][3][nY][1],"X3_ARQUIVO") // Tabela
									aCampos[nScanTbl][3][nLen][nCpoCAMPO]  := aVirtuais[nX][3][nY][1]  // Campo
									aCampos[nScanTbl][3][nLen][nCpoORDEM]  := Posicione("SX3",2,aVirtuais[nX][3][nY][1],"X3_ORDEM") // Ordem
									aCampos[nScanTbl][3][nLen][nCpoTIPDAD] := Posicione("SX3",2,aVirtuais[nX][3][nY][1],"X3_TIPO") // Tipo de Dado
									aCampos[nScanTbl][3][nLen][nCpoTITULO] := AllTrim(X3Titulo()) // T�tulo
									aCampos[nScanTbl][3][nLen][nCpoTAMANH] := TAMSX3(aVirtuais[nX][3][nY][1])[1] // Tamanho
									aCampos[nScanTbl][3][nLen][nCpoDECIMA] := Posicione("SX3",2,aVirtuais[nX][3][nY][1],"X3_DECIMAL") // Decimal
									aCampos[nScanTbl][3][nLen][nCpoPICTUR] := PesqPict(Posicione("SX3",2,aVirtuais[nX][3][nY][1],"X3_ARQUIVO"), aVirtuais[nX][3][nY][1], ) // Picture
									aCampos[nScanTbl][3][nLen][nCpoOPCOES] := X3CBox() // Op��es
									aCampos[nScanTbl][3][nLen][nCpoREAL]   := .F. // Real?
									aCampos[nScanTbl][3][nLen][nCpoOBRIGA] := X3Obrigat(aVirtuais[nX][3][nY][1]) // Obrigat�rio?
									aCampos[nScanTbl][3][nLen][nCpoSELECT] := .T. // Selecionado?
							EndIf
						EndIf
					EndIf
				Next nY

				// Reordena o Array de campos
				aSort(aCampos[nScanTbl][3], , , {|x,y| x[nCpoTABELA]+x[nCpoORDEM] < y[nCpoTABELA]+y[nCpoORDEM] }) // Tabela + Ordem
			EndIf
		Next nX

		// Atualiza o Browse
		Eval(oFoldVars:bChange)
	EndIf

	// Esconde Painel Preto
	oBlackPnl:Hide()

	// Devolve as �reas
	RestArea(aAreaSX3)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwAddChg
Executa o bChange da �rvore de sele��o de campos virtuais.

@author Wagner Sobral de Lacerda
@since 30/10/2012

@param oObjTree
	Objeto DBTree * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBrwAddChg(oObjTree)

	// Vari�veis auxiliares
	Local cCargo := AllTrim( oObjTree:GetCargo() )
	Local nScanTbl := 0

	Local aSetCols := {}

	//----------
	// Busca
	//----------
	nScanTbl := aScan(aVirtuais, {|x| AllTrim(x[1]) == cCargo })
	If nScanTbl > 0
		aSetCols := aClone(aVirtuais[nScanTbl][3])
	EndIf
	oBrwVirtuais:SetArray(aSetCols)
	oBrwVirtuais:GoTop()
	oBrwVirtuais:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwAddMrk
Executa a Marca��o de um Campo no brow de Adicionar Campos Virtuais.

@author Wagner Sobral de Lacerda
@since 03/12/2012

@return cImagem
/*/
//---------------------------------------------------------------------
Static Function fBrwAddMrk()

	// Vari�vel da Imagem do Status
	Local cImagem := ""

	// Vari�veis do Browse
	Local aArray := {}
	Local nAT := 0

	//----------
	// Executa
	//----------
	// Recebe o Array
	aArray := aClone( oBrwVirtuais:Data():GetArray() )
	nAT := oBrwVirtuais:AT()

	// Define a Imagem
	If Len(aArray[nAT]) > 0 .And. ValType(aArray[nAT][1]) <> "U"
		If aArray[nAT][3] // Se Marcado
			cImagem := "lbok"
		Else // Sen�o
			cImagem := "lbno"
		EndIf
	EndIf

Return cImagem

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwAddClk
Executa a Marca��o de um Campo no brow de Adicionar Campos Virtuais.

@author Wagner Sobral de Lacerda
@since 03/12/2012

@param oObjTree
	Objeto DBTree * Obrigat�rio
@param lHeadClick
	Indica se foi um clique no cabe�alho (.T.) * Opcional
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBrwAddClk(oObjTree, lHeadClick)

	// Vari�veis auxiliares
	Local cCargo := AllTrim( oObjTree:GetCargo() )
	Local nScanTbl := 0, nScanCpo := 0

	// Vari�veis do Browse
	Local aArray := {}
	Local nAT := 0, nMax := 0
	Local nX := 0
	Local lSetEstado := .F.

	// Defaults
	Default lHeadClick := .F.

	//----------
	// Busca
	//----------
	nScanTbl := aScan(aVirtuais, {|x| AllTrim(x[1]) == cCargo })
	If nScanTbl > 0
		//----------
		// Executa
		//----------
		// Recebe o Array
		aArray := oBrwVirtuais:Data():GetArray()

		// Define Clique
		If Len(aArray[1]) > 0 .And. ValType(aArray[1][1]) <> "U"
			// Define quais os itens que ser�o atualizados
			If lHeadClick
				nAT := 1
				nMax := Len(aArray)

				// O estado que ser� setado ser� sempre o contr�rio do que j� est� atualmente
				lSetEstado := aScan(aArray, {|x| x[3] }) > 0
				lSetEstado := !lSetEstado
			Else
				nAT := oBrwVirtuais:AT()
				nMax := nAT
			EndIf

			// Atualiza a Sele��o
			For nX := nAT To nMax
				If lHeadClick
					// Seta o Estado da Sele��o
					aArray[nX][3] := lSetEstado
				Else
					// Inverte o Estado da Sele��o
					aArray[nX][3] := !aArray[nX][3]
				EndIf

				// Atualiza o array principal
				nScanCpo := aScan(aVirtuais[nScanTbl][3], {|x| AllTrim(x[1]) == AllTrim(aArray[nX][1]) })
				If nScanCpo > 0
					aVirtuais[nScanTbl][3][nScanCpo][3] := aArray[nX][3]
				EndIf
			Next nX

			// Atualiza o Browse
			If lHeadClick
				oBrwVirtuais:Refresh(.T.)
			EndIf
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwDelCpo
Adiciona um Campo para ser impresso na vari�vel.

@author Wagner Sobral de Lacerda
@since 24/10/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fBrwDelCpo(cCodVariav)

	// Vari�veis auxiliares
	Local nScanTbl := 0
	Local nScanCpo := 0

	Local aArray := {}
	Local nArray := 0

	// Mostra Painel Preto
	oBlackPnl:Show()

	//--------------------
	// Exclui os Campos
	//--------------------
	If MsgYesNo(STR0035, STR0001) //"Deseja excluir os campos desabilitados?" ## "Aten��o"
		// Recebe o Array
		aArray := oBrwCpos:Data():GetArray()

		// Cursor em Espera
		CursorArrow()
		// Exclui os Campos Desabilitados
		For nArray := 1 To Len(aArray)
			If !aArray[nArray][6]
				nScanTbl := aScan(aCampos, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) .And. AllTrim(x[2]) == AllTrim(aArray[nArray][1]) })
				If nScanTbl > 0
					nScanCpo := aScan(aCampos[nScanTbl][3], {|x| AllTrim(x[nCpoCAMPO]) == AllTrim(aArray[nArray][2]) })
					If nScanCpo > 0
						aDel(aCampos[nScanTbl][3], nScanCpo)
						aSize(aCampos[nScanTbl][3], (Len(aCampos[nScanTbl][3])-1))
					EndIf
				EndIf
			EndIf
		Next nArray
		// Cursor Normal
		CursorArrow()

		// Atualiza
		Eval(oFoldVars:bChange)
	EndIf

	// Esconde Painel Preto
	oBlackPnl:Hide()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSetCSS
Define um CSS para um bot�o.

@author Wagner Sobral de Lacerda
@since 24/09/2012

@param nEstilo
	Indica o estilo do CSS de acordo com o bot�o: * Obrigat�rio
	   nCSSTipEsp - Bot�o de Tipo de Impress�o em Espera
	   nCSSTipSel - Bot�o de Tipo de Impress�o Selecionado
	   nCSSLink   - Bot�o de Link
	   nCSSCarreg - Bot�o de Carregar alguma coisa
@param oObjBtn
	Referencia o Objeto do Bot�o (TButton) * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetCSS(nEstilo, oObjBtn)

	// Vari�veis das Cores em Hexadecimal a serem aplicadas
	Local cUsaBack1 := "", cUsaBack2 := "", cUsaBack3 := ""
	Local cUsaFore1 := "", cUsaFore2 := "", cUsaFore3 := ""
	Local cUsaBord1 := "", cUsaBord2 := "", cUsaBord3 := ""
	Local cUsaGrad1 := "", cUsaGrad2 := "", cUsaGrad3 := ""

	Local cAuxBord1 := "", cAuxBord2 := "", cAuxBord3 := ""

	// Vari�veis da Fonte
	Local cFontFamily := ""
	Local cFontSize   := ""
	Local cFontWeight := ""
	Local cFontAlign  := ""
	Local cBordRadius := ""

	// Vari�vel de Decora��es da Fonte
	Local lUnderline := .F.

	// Vari�vel de Bordas Arredondadas espec�ficas
	Local cAuxRadius := ""

	// Fonte Padr�o
	cFontFamily := "'Segoe UI', Tahoma, sans-serif"
	cFontSize   := "12"
	cFontWeight := "bold"
	cBordRadius := "3"

	//-- Gradiente padr�o
	cUsaGrad1 := "#FAFAFA" // Cinza Claro -  Personalizado (RGB: 250,250,250)
	cUsaGrad2 := "#FDFDFD" // Cinza Claro -  Personalizado (RGB: 253,253,253)
	cUsaGrad3 := "#FDFDFD" // Cinza Claro -  Personalizado (RGB: 253,253,253)

	//----------------------------------------
	// Define as cores a serem utilizadas
	//----------------------------------------
	If nEstilo == nCSSTipEsp

		//----------------------------------------
		// Bot�o de Tipo de Impress�o "em Espera"
		//----------------------------------------

		cFontWeight := "normal"
		cFontAlign  := "padding-left: 10px; text-align: left; "
		cBordRadius := "0"

		cUsaBack1 := "#FFFFFF" // Branco
		cUsaBack2 := "#A4C0D2" // Azul Claro -  Personalizado(RGB: 164,192,210)
		cUsaBack3 := "#A4C0D2" // Azul Claro -  Personalizado(RGB: 164,192,210)

		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3

		cUsaFore1 := "#004A77" // Azul M�dio -  Personalizado(RGB: 0,74,119)
		cUsaFore2 := "#004A77" // Azul M�dio -  Personalizado(RGB: 0,74,119)
		cUsaFore3 := "#004A77" // Azul M�dio -  Personalizado(RGB: 0,74,119)

		cUsaBord1 := cUsaBack1
		cUsaBord2 := cUsaBack2
		cUsaBord3 := cUsaBack3

	ElseIf nEstilo == nCSSTipSel

		//----------------------------------------
		// Bot�o de Tipo de Impress�o "Selecionado"
		//----------------------------------------

		cFontAlign := "padding-left: 10px; text-align: left; "
		cBordRadius := "0"

		cUsaBack1 := "#8AAEC5" // Azul M�dio -  Personalizado(RGB: 138,174,197)
		cUsaBack2 := "#8AAEC5" // Azul M�dio -  Personalizado(RGB: 138,174,197)
		cUsaBack3 := "#8AAEC5" // Azul M�dio -  Personalizado(RGB: 138,174,197)

		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3

		cUsaFore1 := "#FFFFFF" // Branco
		cUsaFore2 := "#FFFFFF" // Branco
		cUsaFore3 := "#FFFFFF" // Branco

		cUsaBord1 := cUsaBack1
		cUsaBord2 := cUsaBack2
		cUsaBord3 := cUsaBack3

	ElseIf nEstilo == nCSSLink

		//----------------------------------------
		// Bot�o de Link
		//----------------------------------------

		cFontSize   := "11"
		cFontWeight := "normal"
		cFontAlign  := "padding-left: 1px; text-align: left; "
		cBordRadius := "0"

		cUsaBack1 := "#FFFFFF" // Branco
		cUsaBack2 := "#FFFFFF" // Branco
		cUsaBack3 := "#FFFFFF" // Branco

		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3

		cUsaFore1 := "#5C5C5C" // Cinza
		cUsaFore2 := "#000000" // Preto
		cUsaFore3 := "#000000" // Preto

		cUsaBord1 := cUsaBack1
		cUsaBord2 := cUsaBack2
		cUsaBord3 := cUsaBack3

	ElseIf nEstilo == nCSSCarreg

		//----------------------------------------
		// Bot�o de Carregar alguma coisa
		//----------------------------------------

		cBordRadius := "2"

		cUsaBack1 := "#F5F5F5" // WhiteSmoke
		cUsaBack2 := "#E8E8E8" // Cinza Claro
		cUsaBack3 := "#E8E8E8" // Cinza Claro

		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3

		cUsaFore1 := "#9C9C9C" // Cinza
		cUsaFore2 := "#000000" // Preto
		cUsaFore3 := "#000000" // Preto

		cUsaBord1 := "#D3D3D3" // LightGray
		cUsaBord2 := "#BEBEBE" // Grey
		cUsaBord3 := "#BEBEBE" // Grey

	EndIf

	//--------------------
	// Seta o CSS
	//--------------------
	// Fam�la da Fonte
	If !Empty(cFontFamily)
		cFontFamily := "font-family: " + cFontFamily + "; "
	EndIf
	// Borda
	cAuxBord1 := "border: " + If(!Empty(cUsaBord1), "1px solid " + cUsaBord1, "0px") + "; "
	cAuxBord2 := "border: " + If(!Empty(cUsaBord2), "1px solid " + cUsaBord2, "0px") + "; "
	cAuxBord3 := "border: " + If(!Empty(cUsaBord3), "1px solid " + cUsaBord3, "0px") + "; "
	// Borda Arredondada
	cAuxRadius := "border-radius: " + cBordRadius + "px; "
	// Seta o CSS
	oObjBtn:SetCSS("QPushButton{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad1 + ", stop: 0.4 " + cUsaBack1 + "); color: " + cUsaFore1 + "; " + cFontFamily + "font-size: " + cFontSize + "px; font-weight: " + cFontWeight + "; " + cFontAlign + cAuxBord1 + cAuxRadius + If(lUnderline, "text-decoration: underline;", "") + " } " + ;
					"QPushButton:Hover{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad2 + ", stop: 0.4 " + cUsaBack2 + "); color: " + cUsaFore2 + "; " + cAuxBord2 + If(lUnderline, "text-decoration: underline;", "") + " } " + ;
					"QPushButton:Pressed{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad3 + ", stop: 0.4 " + cUsaBack3 + "); color: " + cUsaFore3 + "; " + cAuxBord3 + If(lUnderline, "text-decoration: underline;", "") + " } ")

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetRegis
Recebe um Array com os Registros da Tabela do Hist�rico.

@author Wagner Sobral de Lacerda
@since 25/09/2012

@param cCodVariav
	C�digo da Vari�vel * Obrigat�rio
@param cCodTabela
	C�digo da Tabela * Obrigat�rio

@return aRetorno
/*/
//---------------------------------------------------------------------
Static Function fGetRegis(cCodVariav, cCodTabela)

	// Vari�vel do Retorno
	Local aRetorno := {}
	Local aHeader := {}, aCols := {}

	// Vari�veis do Seek
	Local cSeekFil := ""
	Local cSeekHis := ""
	Local cSeekVar := ""
	Local cSeekTbl := ""

	// Vari�veis dos Campos
	Local nScanTbl := 0
	Local nCamp := 0
	Local nHeader := 0, nCols := 0

	Local aRegistros := {}
	Local nRegistro := 0
	Local nSequenc := 0
	Local nScan := 0

	Local aOpcoes := {}, nOpcao := 0

	Local nMaxSize := 30

	//----------
	// Executa
	//----------
	aRegist := {}

	cSeekFil := xFilial("TZF",TZE->TZE_FILIAL)
	cSeekHis := TZE->TZE_CODIGO
	cSeekVar := PADR(cCodVariav, TAMSX3("TZF_VARIAV")[1], " ")
	cSeekTbl := PADR(cCodTabela, TAMSX3("TZF_TABELA")[1], " ")

	// Define o Cabe�alho
	nScanTbl := aScan(aCampos, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) .And. AllTrim(x[2]) == AllTrim(cCodTabela) })
	If nScanTbl > 0
		For nCamp := 1 To Len(aCampos[nScanTbl][3])
			If aCampos[nScanTbl][3][nCamp][nCpoSELECT]
				aAdd(aHeader, {aCampos[nScanTbl][3][nCamp][nCpoCAMPO], aCampos[nScanTbl][3][nCamp][nCpoTITULO], aCampos[nScanTbl][3][nCamp][nCpoREAL]})
			EndIf
		Next nCamp
	EndIf

	// Busca os Registros
	If Len(aHeader) > 0
		dbSelectArea("TZF")
		dbSetOrder(2)
		dbSeek(cSeekFil + cSeekHis + cSeekVar + cSeekTbl, .T.)
		While !Eof() .And. TZF->TZF_FILIAL == cSeekFil .And. TZF->TZF_CODIGO == cSeekHis .And. ;
			TZF->TZF_VARIAV == cSeekVar .And. TZF->TZF_TABELA == cSeekTbl

			cSequenc := TZF->TZF_SEQUEN
			nSequenc := aScan(aRegistros, {|x| x[1] == cSequenc })
			If nSequenc == 0
				// 1         ; 2
				// Sequ�ncia ; {Registros}
				aAdd(aRegistros, {cSequenc, {}})
				nSequenc := Len(aRegistros)
			EndIf
			// 1     ; 2
			// Campo ; Coonte�do
			aAdd(aRegistros[nSequenc][2], {TZF->TZF_CAMPO, NGI6CONVER(TZF->TZF_CONTEU, TZF->TZF_TIPDAD)})
			nRegistro := Len(aRegistros[nSequenc][2])
			// Se possuir Op��es (ComboBox)
			If !Empty(TZF->TZF_AUXOPC)
				aOpcoes := StrTokArr(AllTrim(TZF->TZF_AUXOPC), ";")
				nOpcao := aScan(aOpcoes, {|x| SubStr(x,1,AT("=",x)-1) == AllTrim(aRegistros[nSequenc][2][nRegistro][2]) })
				If nOpcao > 0
					aRegistros[nSequenc][2][nRegistro][2] := aOpcoes[nOpcao]
				EndIf
			EndIf

			dbSelectArea("TZF")
			dbSkip()
		End
	EndIf

	// Define os Registros
	aCols := Array(Len(aRegistros))
	For nCols := 1 To Len(aCols)
		aCols[nCols] := Array(Len(aHeader))
		For nHeader := 1 To Len(aHeader)
			nScan := aScan(aRegistros[nCols][2], {|x| AllTrim(x[1]) == AllTrim(aHeader[nHeader][1]) })
			If nScan > 0
				aCols[nCols][nHeader] := aRegistros[nCols][2][nScan][2]
			Else
				If !aHeader[nHeader][3] // Caso seja campo Virtual.
					aCols[nCols,nHeader] := fGetX7(cSeekTbl, aClone(aCols[nCols]), aClone(aHeader), aHeader[nHeader][1])
				Else
					aCols[nCols,nHeader] := "--" // Preenche com um valor padr�o.
				EndIf
			EndIf
			// Tamanho m�ximo do conte�do
			If ValType(aCols[nCols,nHeader]) == "C" .And. Len(aCols[nCols,nHeader]) > nMaxSize
				aCols[nCols,nHeader] := SubStr(aCols[nCols,nHeader],1,nMaxSize)
			EndIf
		Next nHeader
	Next nCols

	// Define o Retorno
	aRetorno := {aClone(aHeader), aClone(aCols)}

Return aRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetX7
Executa o Gatilho para buscar o conte�do de um campo.

@param cGetAlias , Caracter, Alias da tabela.
@param aGetRegist, Array   , Array com registros.
@param aGetHeader, Array   , Estrutura de campos.
@param cGetField , Caracter, Campo que ser� verificado.

@author Wagner Sobral de Lacerda
@since 03/12/2012

@return cGatilho
/*/
//---------------------------------------------------------------------
Static Function fGetX7(cGetAlias, aGetRegist, aGetHeader, cGetField)

	// Salva as �reas atuais
	Local aAreaOld := GetArea()

	// Vari�vel do Retorno
	Local cGatilho := "--"

	// Vari�veis auxiliares
	Local nColuna  := 0

	// Vari�vies PRIVATE necess�rias
	Private INCLUI := .T.
	Private ALTERA := .F.

	// Inicializa a mem�ria dos campos com valores em branco.
	RegToMemory(cGetAlias, .T.,,.F.)

	For nColuna := 1 To Len(aGetHeader)
		If ValType(aGetRegist[nColuna]) <> "U"

			&("M->"+aGetHeader[nColuna,1]) := aGetRegist[nColuna]

			// Executa gatilhos enviando valor para mem�ria do campo.
			If ExistTrigger( aGetHeader[nColuna,1] )
				RunTrigger( 1,,,,aGetHeader[nColuna,1]  )
			EndIf

		EndIf
	Next nColuna

	// Busca valor de Mem�ria do campo.
	cGatilho := Iif(Empty(&("M->"+cGetField)),"--",&("M->"+cGetField))

	// Devolve as �reas
	RestArea(aAreaOld)

Return cGatilho

//---------------------------------------------------------------------
/*/{Protheus.doc} fNoChar
Fun��o para retirar as aspas de uma string.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@param cString
	String para ser avaliada * Obrigat�rio

@return cRetStr
/*/
//---------------------------------------------------------------------
Static Function fNoChar(cString)

	// Vari�vel do Retorno
	Local cRetStr := cString

	// Converte
	cRetStr := StrTran(cRetStr, "'", "")
	cRetStr := StrTran(cRetStr, '"', "")

Return cRetStr

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: PREPARA A IMPRESS�O                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldReport
Valida a Confirma��o da Impress�o.

@author Wagner Sobral de Lacerda
@since 22/10/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fVldReport()

	//----------
	// Valida
	//----------
	If nTipoImp == 0
		Help(Nil, Nil, STR0001, Nil, STR0036, 1, 0) //"Aten��o" ## "Por favor selecione uma op��o de impress�o."
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExecReport
Executa a Impress�o.

@author Wagner Sobral de Lacerda
@since 22/10/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fExecReport()

	// Vari�veis auxiliares
	Local nX := 0

	// Vari�veis de Impress�o
	Private aReport := {}
		// Posi��es 'aReport'
		Private nRepEMPRES := 1
		Private nRepFILIAL := 2
		Private nRepCODIGO := 3
		Private nRepDATA   := 4
		Private nRepHORA   := 5
		Private nRepINDICA := 6
		Private nRepTITULO := 7
		Private nRepRESULT := 8

		Private nRepMETA   := 9
		Private nRepMETDES := 10
		Private nRepFORMUL := 11
		Private nRepUSUARI := 12
		Private nRepUSUNOM := 13
		Private nRepFUNPAI := 14

		Private nRepSize := 14

	Private aCalculo   := {}
	Private cNewFormul := AllTrim(TZE->TZE_FORMUL)
	Private cNewResult := AllTrim(Transform(TZE->TZE_RESULT, PesqPict("TZE","TZE_RESULT",)))

	//-- Define algumas vari�veis para impress�o
	aCalculo := {}
	For nX := 1 To Len(aVariaveis)
		dbSelectArea("TZI")
		dbSetOrdeR(1)
		dbSeek(xFilial("TZI") + TZE->TZE_CODIGO + aVariaveis[nX][nVarVARIAV])
		aAdd(aCalculo, {AllTrim(TZI->TZI_VARIAV), AllTrim(fNoChar(TZI->TZI_VARNOM)), AllTrim(Transform(TZI->TZI_RESULT, PesqPict("TZI","TZI_RESULT",)))})
		cNewFormul := StrTran(cNewFormul, AllTrim(TZI->TZI_VARIAV), AllTrim(Transform(TZI->TZI_RESULT, PesqPict("TZI","TZI_RESULT",))))
	Next nX
	cNewFormul := StrTran(cNewFormul, "@", "")
	cNewFormul := StrTran(cNewFormul, "#", "")

	//----------
	// Executa
	//----------
	// Mostra Painel Preto
	oBlackPnl:Show()

	//-- Dados
	aReport := Array(nRepSize)
	aReport[nRepEMPRES] := {STR0037, SubStr(RetFullName("TZE"),4,2)} //"Empresa"
	aReport[nRepFILIAL] := {STR0038, TZE->TZE_FILIAL} //"Filial"
	aReport[nRepCODIGO] := {STR0014, TZE->TZE_CODIGO} //"Hist�rico"
	aReport[nRepDATA]   := {STR0039, DTOC(TZE->TZE_DATA)} //"Data"
	aReport[nRepHORA]   := {STR0040, TZE->TZE_HORA} //"Hora"
	aReport[nRepINDICA] := {STR0041, TZE->TZE_INDIC} //"Indicador"
	aReport[nRepTITULO] := {STR0042, Posicione("TZ5", 1, TZE->TZE_FILIAL+TZE->TZE_MODULO+TZE->TZE_INDIC, "TZ5_NOME")} //"T�tulo"
	aReport[nRepRESULT] := {STR0043, If(TZE->TZE_TIPVAL == "1", AllTrim(Transform(TZE->TZE_RESULT, PesqPict("TZE","TZE_RESULT",))), NTOH(TZE->TZE_RESULT))} // 1=Num�rico;2=Hor�rio //"Resultado"

	cAuxData := NGIND010X3( "TZE_TIPMET", TZE->TZE_TIPMET ) + " " + AllTrim(Transform(TZE->TZE_META,PesqPict("TZE","TZE_META",)))
	If TZE->TZE_TIPMET $ "5/6"
		cAuxData += " a " + AllTrim(Transform(TZE->TZE_META2,PesqPict("TZE","TZE_META2",)))
	EndIf
	aReport[nRepMETA]   := {AllTrim(RetTitle("TZE_META")), cAuxData}
	cAuxData := IIf( NGIND010MT( TZE->TZE_TIPMET, TZE->TZE_META, TZE->TZE_META2, TZE->TZE_RESULT ), STR0044, STR0045 ) //"Dentro da Meta" ## "Fora da Meta"
	cAuxData += " - " + cValToChar( ( TZE->TZE_RESULT/TZE->TZE_META)*100 ) + "% " + STR0046 //"em rela��o � meta inicial"
	aReport[nRepMETDES] := {STR0047, cAuxData} //"Desc. Meta"
	aReport[nRepFORMUL] := {AllTrim(RetTitle("TZE_FORMUL")), AllTrim(TZE->TZE_FORMUL)}
	aReport[nRepUSUARI] := {AllTrim(RetTitle("TZE_CODUSR")), TZE->TZE_CODUSR}
	aReport[nRepUSUNOM] := {AllTrim(RetTitle("TZE_NOMUSR")), UsrFullName(TZE->TZE_CODUSR)}
	aReport[nRepFUNPAI] := {AllTrim(RetTitle("TZE_FUNPAI")), TZE->TZE_FUNPAI}

	// Impresss�o
	If nTipoImp == nTipPROTHE
		fPReport()
	ElseIf nTipoImp == nTipEXCEL
		MsgRun(STR0048, STR0008, {|| fPlanilha() }) //"Gerando Planilha..." ## "Por favor, aguarde..."
	EndIf

	// Esconde Painel Preto
	oBlackPnl:Hide()

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: IMPRESS�O EM PROTHEUS REPORT                                                  ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fPReport
Imprime o Protheus Report.

@author Wagner Sobral de Lacerda
@since 04/12/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fPReport()

	Private oReport
	Private cTitVariav := ""
	Private cTitTabela := ""
	Private cSeqRegist := ""
	Private aImpConsul := {}

	//���������������������������������ͻ
	//� Realiza a Impressao do Cadastro �
	//���������������������������������ͼ
	oReport := fPRepDef()
	oReport:SetLandscape() // Default Paisagem
	oReport:PrintDialog()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPRepDef
Defini��o do Relat�rio Personaliz�vel.

@author Wagner Sobral de Lacerda
@since 05/12/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fPRepDef()

	Local oSection1, oSection2, oSection3, oSection4, oSection5, oSection6, oSection7, oSection8, oSection9, oSection10, oSection11
	Local oCell

	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�                                                                        �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oReport := TReport():New("NGIND011", STR0049, , {|oReport| fPRepPrt()}, STR0050) //"Hist�rico de Indicadores" ## "Impress�o do Hist�rico de Indicadores em Protheus Report."

	Pergunte(oReport:uParam,.F.)

	//������������������������������������������������������������������������Ŀ
	//�Criacao da secao utilizada pelo relatorio                               �
	//�                                                                        �
	//�TRSection():New                                                         �
	//�ExpO1 : Objeto TReport que a secao pertence                             �
	//�ExpC2 : Descricao da se�ao                                              �
	//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
	//�        sera considerada como principal para a se��o.                   �
	//�ExpA4 : Array com as Ordens do relat�rio                                �
	//�ExpL5 : Carrega campos do SX3 como celulas                              �
	//�        Default : False                                                 �
	//�ExpL6 : Carrega ordens do Sindex                                        �
	//�        Default : False                                                 �
	//�                                                                        �
	//��������������������������������������������������������������������������
	//������������������������������������������������������������������������Ŀ
	//�Criacao da celulas da secao do relatorio                                �
	//�                                                                        �
	//�TRCell():New                                                            �
	//�ExpO1 : Objeto TSection que a secao pertence                            �
	//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
	//�ExpC3 : Nome da tabela de referencia da celula                          �
	//�ExpC4 : Titulo da celula                                                �
	//�        Default : X3Titulo()                                            �
	//�ExpC5 : Picture                                                         �
	//�        Default : X3_PICTURE                                            �
	//�ExpC6 : Tamanho                                                         �
	//�        Default : X3_TAMANHO                                            �
	//�ExpL7 : Informe se o tamanho esta em pixel                              �
	//�        Default : False                                                 �
	//�ExpB8 : Bloco de c�digo para impressao.                                 �
	//�        Default : ExpC2                                                 �
	//�                                                                        �
	//��������������������������������������������������������������������������

	//������������������������������������ͻ
	//� Section 1 - T�tulo do Cabe�alho    �
	//������������������������������������ͼ
	oSection1 := TRSection():New(oReport, STR0051, {""} ) //"T�tulo do Cabe�alho"
		oCell := TRCell():New(oSection1, "TITULO", "" , STR0051, "", 60, .T./*lPixel*/, {|| STR0049 }/*code-block de impressao*/ ) //"T�tulo do Cabe�alho" ## "Hist�rico de Indicadores"

	//������������������������������������ͻ
	//� Section 2 - Dados do Cabe�alho     �
	//������������������������������������ͼ
	oSection2 := TRSection():New(oReport, STR0052, {""} ) //"Dados do Cabe�alho"
		oCell := TRCell():New(oSection2, "EMPRES"   , "" , aReport[nRepEMPRES][1], "", 20, .T./*lPixel*/, {|| aReport[nRepEMPRES][2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection2, "FILIAL"   , "" , aReport[nRepFILIAL][1], "", 20, .T./*lPixel*/, {|| aReport[nRepFILIAL][2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection2, "CODIGO"   , "" , aReport[nRepCODIGO][1], "", 40, .T./*lPixel*/, {|| aReport[nRepCODIGO][2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection2, "DATA"     , "" , aReport[nRepDATA][1]  , "", 20, .T./*lPixel*/, {|| aReport[nRepDATA][2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection2, "HORA"     , "" , aReport[nRepHORA][1]  , "", 20, .T./*lPixel*/, {|| aReport[nRepHORA][2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection2, "INDICADOR", "" , aReport[nRepINDICA][1], "", 30, .T./*lPixel*/, {|| aReport[nRepINDICA][2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection2, "TITULO"   , "" , aReport[nRepTITULO][1], "", 50, .T./*lPixel*/, {|| aReport[nRepTITULO][2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection2, "RESULTADO", "" , aReport[nRepRESULT][1], "", 40, .T./*lPixel*/, {|| aReport[nRepRESULT][2] }/*code-block de impressao*/ )

		oSection2:nLeftMargin := 2

	//������������������������������������ͻ
	//� Section 3 - T�tulo das Informa��es �
	//������������������������������������ͼ
	oSection3 := TRSection():New(oReport, STR0053, {""} ) //"T�tulo das Informa��es"
		oCell := TRCell():New(oSection3, "TITULO", "" , STR0053, "", 60, .T./*lPixel*/, {|| STR0054 }/*code-block de impressao*/ ) //"T�tulo das Informa��es" ## "Informa��es do Indicador"

	//������������������������������������ͻ
	//� Section 4 - Dados das Informa��es  �
	//������������������������������������ͼ
	oSection4 := TRSection():New(oReport, STR0055, {""} ) //"Dados das Informa��es"
		oCell := TRCell():New(oSection4, "META"   , "" , aReport[nRepMETA][1]  , "", 100, .T./*lPixel*/, {|| aReport[nRepMETA][2] + "(" + aReport[nRepMETDES][2] + ")" }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection4, "FORMULA", "" , aReport[nRepFORMUL][1], "", 100, .T./*lPixel*/, {|| aReport[nRepFORMUL][2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection4, "USUARIO", "" , aReport[nRepUSUARI][1], "", 60 , .T./*lPixel*/, {|| aReport[nRepUSUARI][2] + "(" + aReport[nRepUSUNOM][2] + ")" }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection4, "FUNPAI" , "" , aReport[nRepFUNPAI][1], "", 20 , .T./*lPixel*/, {|| aReport[nRepFUNPAI][2] }/*code-block de impressao*/ )

		oSection4:nLeftMargin := 2

	//������������������������������������ͻ
	//� Section 5 - Vari�veis e Resultados �
	//������������������������������������ͼ
	oSection5 := TRSection():New(oReport, STR0056, {""} ) //"Vari�veis e Resultados"
		oCell := TRCell():New(oSection5, "VARIAV"   , "" , STR0057, "", 30, .T./*lPixel*/, {|| aRepCalc[1] }/*code-block de impressao*/ ) //"Vari�vel"
		oCell := TRCell():New(oSection5, "NOME"     , "" , STR0020, "", 80, .T./*lPixel*/, {|| aRepCalc[2] }/*code-block de impressao*/ ) //"Descri��o"
		oCell := TRCell():New(oSection5, "RESULTADO", "" , STR0043, "", 40, .T./*lPixel*/, {|| aRepCalc[3] }/*code-block de impressao*/ ) //"Resultado"

		oSection5:nLeftMargin := 2

	//������������������������������������ͻ
	//� Section 6 - F�rmula (substitu�da)  �
	//������������������������������������ͼ
	oSection6 := TRSection():New(oReport, STR0058, {""} ) //"F�rmula (substitu�da)"
		oCell := TRCell():New(oSection6, "FORMULA", "" , STR0058, "", 100, .T./*lPixel*/, {|| cNewFormul }/*code-block de impressao*/ ) //"F�rmula (substitu�da)"

		oSection6:nLeftMargin := 2

	//������������������������������������ͻ
	//� Section 7 - Resultado Num�rico     �
	//������������������������������������ͼ
	oSection7 := TRSection():New(oReport, STR0059, {""} ) //"Resultado Num�rico"
		oCell := TRCell():New(oSection7, "RESULTADO", "" , STR0059, "", 40, .T./*lPixel*/, {|| cNewResult }/*code-block de impressao*/ ) //"Resultado Num�rico"

		oSection7:nLeftMargin := 2

	//������������������������������������ͻ
	//� Section 8 - T�tulo das Vari�veis   �
	//������������������������������������ͼ
	oSection8 := TRSection():New(oReport, STR0060, {""} ) //"Vari�veis"
		oCell := TRCell():New(oSection8, "TITULO", "" , STR0057, "", 80, .T./*lPixel*/, {|| cTitVariav }/*code-block de impressao*/ ) //"Vari�vel"

	//������������������������������������ͻ
	//� Section 9 - Par�metros             �
	//������������������������������������ͼ
	oSection9 := TRSection():New(oReport, STR0061, {""} ) //"Par�metros"
		oCell := TRCell():New(oSection9, "PARAMETRO", "" , STR0064, "", 60, .T./*lPixel*/, {|| aImpConsul[1] }/*code-block de impressao*/ ) //"Par�metro"
		oCell := TRCell():New(oSection9, "CONTEUDO" , "" , STR0065, "", 60, .T./*lPixel*/, {|| aImpConsul[2] }/*code-block de impressao*/ ) //"Conte�do"

		oSection9:nLeftMargin := 2

	//������������������������������������ͻ
	//� Section 10 - T�tulo das Tabelas    �
	//������������������������������������ͼ
	oSection10 := TRSection():New(oReport, STR0029, {""} ) //"Tabelas"
		oCell := TRCell():New(oSection10, "TITULO", "" , STR0019, "", 60, .T./*lPixel*/, {|| cTitTabela }/*code-block de impressao*/ ) //"Tabela"

		oSection10:nLeftMargin := 2

	//������������������������������������ͻ
	//� Section 11 - Registros             �
	//������������������������������������ͼ
	oSection11 := TRSection():New(oReport, STR0062, {""} ) //"Registros"
		oCell := TRCell():New(oSection11, "REGISTRO", "" , STR0063, "", 20, .T./*lPixel*/, {|| cSeqRegist }/*code-block de impressao*/ ) //"Registro"
		oCell := TRCell():New(oSection11, "COLUNA1" , "" , ""     , "", 120, .T./*lPixel*/, {|| aImpConsul[1] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection11, "COLUNA2" , "" , ""     , "", 120, .T./*lPixel*/, {|| aImpConsul[2] }/*code-block de impressao*/ )
		oCell := TRCell():New(oSection11, "COLUNA3" , "" , ""     , "", 120, .T./*lPixel*/, {|| aImpConsul[3] }/*code-block de impressao*/ )

		oSection11:nLeftMargin := 4

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} fPRepPrt
Impress�o do Relat�rio Personaliz�vel.

@author Wagner Sobral de Lacerda
@since 05/12/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fPRepPrt()

	// Vari�veis auxiliares
	Local oCabecTit := oReport:Section(1)
	Local oCabecDad := oReport:Section(2)
	Local oInfoTit  := oReport:Section(3)
	Local oInfoDad  := oReport:Section(4)
	Local oInfoVar  := oReport:Section(5)
	Local oInfoFor  := oReport:Section(6)
	Local oInfoRes  := oReport:Section(7)
	Local oVariavel := oReport:Section(8)
	Local oParametr := oReport:Section(9)
	Local oTabela   := oReport:Section(10)
	Local oRegistro := oReport:Section(11)
	Local nImpVar := 0, nImpPar := 0, nImpTbl := 0, nImpReg := 0, nImpCol := 0
	Local nScanPar := 0, nScanTbl := 0
	Local nImpCalc := 0

	Local aGetRegis := {}
	Local aHeader := {}, aCols := {}

	oReport:SetMeter(1 + Len(aVariaveis))

	//���������������������������������ͻ
	//� Cabe�alho                       �
	//���������������������������������ͼ
	oReport:IncMeter()

	oCabecTit:Init()
	oCabecTit:PrintLine()
	oCabecTit:Finish()

	oCabecDad:Init()
	oCabecDad:PrintLine()
	oCabecDad:Finish()

	//���������������������������������ͻ
	//� Informa��es                     �
	//���������������������������������ͼ
	oInfoTit:Init()
	oInfoTit:PrintLine()
	oInfoTit:Finish()

	oInfoDad:Init()
	oInfoDad:PrintLine()
	oInfoDad:Finish()

		//���������������������������������ͻ
		//� Vari�veis e Resultados          �
		//���������������������������������ͼ
		oInfoVar:Init()
		For nImpCalc := 1 To Len(aCalculo)
			aRepCalc := aClone(aCalculo[nImpCalc])
			oInfoVar:PrintLine()
		Next nImpCalc
		oInfoVar:Finish()

		//���������������������������������ͻ
		//� F�rmula (substitu�da)           �
		//���������������������������������ͼ
		oInfoFor:Init()
		oInfoFor:PrintLine()
		oInfoFor:Finish()

		//���������������������������������ͻ
		//� Resultado Num�rico              �
		//���������������������������������ͼ
		oInfoRes:Init()
		oInfoRes:PrintLine()
		oInfoRes:Finish()

	//���������������������������������ͻ
	//� Par�metros                      �
	//���������������������������������ͼ
	aImpConsul := {}

	//���������������������������������ͻ
	//� Vari�veis / Tabelas / Campos    �
	//���������������������������������ͼ
	For nImpVar := 1 To Len(aVariaveis)
		oReport:IncMeter()

		// Vari�vel
		cTitVariav := AllTrim(aVariaveis[nImpVar][nVarVARIAV]) + " - " + AllTrim(aVariaveis[nImpVar][nVarVARNOM])
		oVariavel:Init()
		oVariavel:PrintLine()

		// Busca Par�metros
		nScanPar := aScan(aParams, {|x| AllTrim(x[1]) == AllTrim(aVariaveis[nImpVar][nVarVARIAV]) })
		If nScanPar == 0
			oReport:PrintText(STR0066/*cText*/, /*nRow*/, oReport:Col()*(oParametr:nLeftMargin+1)/*nCol*/) //"N�o h� par�metros para exibir."
			oReport:SkipLine()
		Else
			oParametr:Init()
			For nImpPar := 1 To Len(aParams[nScanPar][2])
				// Par�metro
				aImpConsul := {aParams[nScanPar][2][nImpPar][nParPARAM], aParams[nScanPar][2][nImpPar][nParCONTEU]}
				oParametr:PrintLine()
			Next nImpPar
			oParametr:Finish()
		EndIf

		// Busca Tabelas
		nScanTbl := aScan(aTabelas, {|x| AllTrim(x[nTblVARIAV]) == AllTrim(aVariaveis[nImpVar][nVarVARIAV]) })
		If nScanTbl == 0
			oReport:SkipLine()
			oReport:PrintText(STR0067/*cText*/, /*nRow*/, oReport:Col()*(oTabela:nLeftMargin+1)/*nCol*/) //"N�o h� tabelas para exibir."
			oReport:SkipLine()
		Else
			For nImpTbl := nScanTbl To Len(aTabelas)
				If AllTrim(aTabelas[nImpTbl][nTblVARIAV]) <> AllTrim(aVariaveis[nImpVar][nVarVARIAV])
					Exit
				EndIf
				// Tabela
				cTitTabela := AllTrim(aTabelas[nImpTbl][nTblTABELA]) + " - " + AllTrim(aTabelas[nImpTbl][nTblNOME])
				oTabela:Init()
				oTabela:PrintLine()

				// Registro
				aGetRegis := fGetRegis(aTabelas[nImpTbl][nTblVARIAV], aTabelas[nImpTbl][nTblTABELA])
				aHeader   := aClone( aGetRegis[1] )
				aCols     := aClone( aGetRegis[2] )
				If Len(aCols) == 0
					oReport:PrintText(STR0068/*cText*/, /*nRow*/, oReport:Col()*(oRegistro:nLeftMargin+1)/*nCol*/) //"N�o h� registros para exibir."
					oReport:SkipLine()
				Else
					For nImpReg := 1 To Len(aCols)
						oRegistro:Init()
						oRegistro:Cell("REGISTRO"):Show()
						cSeqRegist := Transform(nImpReg, "@E 999,999")
						For nImpCol := 1 To Len(aHeader) Step 3
							aImpConsul := Array(3)
							aImpConsul[1] := PADR(AllTrim(aHeader[nImpCol][2]),26,".") + ": " + AllTrim(aCols[nImpReg][nImpCol])
							If Len(aHeader) >= (nImpCol+1)
								aImpConsul[2] := PADR(AllTrim(aHeader[nImpCol+1][2]),26,".") + ": " + AllTrim(aCols[nImpReg][nImpCol+1])
							Else
								aImpConsul[2] := " "
							EndIf
							If Len(aHeader) >= (nImpCol+2)
								aImpConsul[3] := PADR(AllTrim(aHeader[nImpCol+2][2]),26,".") + ": " + AllTrim(aCols[nImpReg][nImpCol+2])
							Else
								aImpConsul[3] := " "
							EndIf
							If nImpCol > 3
								oRegistro:Cell("REGISTRO"):Hide()
							EndIf
							oRegistro:PrintLine()
						Next nImpCol
						oRegistro:Finish()
					Next nImpReg
				EndIf

				oTabela:Finish()
			Next nImpTbl
		EndIf

		oVariavel:Finish()

	Next nImpVar

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: IMPRESS�O DA PLANILHA EM EXCEL                                                ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fPlanilha
Imprime a Planilha.

@author Wagner Sobral de Lacerda
@since 28/09/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fPlanilha()

	// Vari�veis para a Planilha
	Local cTempPath := GetTempPath()
	Local cArquivo := "NGIND010.xml"
	Local cFullArq := cTempPath + cArquivo
	Local nHandle := 0

	Local nMaxSize := 16

	Local oExcel

	Private cXML := ""

	Private cClrText := "#000000" // Padr�o (Preto)
	Private cClrBack := "#FFFFFF" // Padr�o (Branco)
	Private cTblText := cClrText
	Private cTblBack := cClrBack
	Private cTblBord := cClrBack
	Private cLinBack := cTblText

	Private cColumnWidth := "100"
	Private cMergeCells  := "3"

	//--------------------
	// Valida a Executa��o
	//--------------------
	If !ApOleClient("MSExcel")
		MsgAlert(STR0069 + CRLF + CRLF + ; //"Microsoft Excel n�o instalado."
				STR0010) //"A impress�o ser� abortada."
		Return .F.
	EndIf

	//-- Cria o arquivo
	nHandle := FCreate(cFullArq, 0)
	If nHandle < 0
		MsgAlert(STR0070 + " " + cFullArq + "." + CRLF + CRLF + ; //"N�o foi poss�vel abrir ou criar o arquivo:"
				STR0010) //"A impress�o ser� abortada."
		Return .F.
	Endif

	//-- Define a Cor adequada
	cClrText := "#3264C8" // Azul M�dio (RGB: 27,62,106)
	cClrBack := "#DBE5F1" // Azul Claro (RGB: 219,229,241)
	cTblText := "#595959" // Cinza Escuro (RGB: 89,89,89)
	cTblBack := "#CCCCCC" // Cinza Claro (RGB: 204,204,204)
	cTblBord := "#D9D9D9" // Cinza Claro (RGB: 217,217,217)
	cLinBack := "#F2F2F2" // Cinza Claro (RGB: 242,242,242)

	//--------------------
	// Executa
	//--------------------
	// Declara��o do XML
	cXML := '<?xml version="1.0"?>' + CRLF
	// In�cio
	cXML += '<ss:Workbook xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">' + CRLF
		//----------------------------------------
		// Estilos para as Planilhas
		//----------------------------------------
		cXML += '<ss:Styles>' + CRLF
			//----------------------------------------
			// Cabe�alho
			//----------------------------------------
			// Cabe�alho Principal
			cXML += '<ss:Style ss:ID="Text_Header">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize) + '" ss:Bold="1" ss:Color="' + cClrText + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + cClrBack + '" ss:Pattern="Solid"/>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Cabe�alho de cada Planilha
			cXML += '<ss:Style ss:ID="Text_Title">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-2) + '" ss:Bold="1" ss:Color="' + cClrText + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + cClrBack + '" ss:Pattern="Solid"/>' + CRLF
			cXML += '</ss:Style>' + CRLF
			//----------------------------------------
			// Textos em Geral
			//----------------------------------------
			// Texto Normal
			cXML += '<ss:Style ss:ID="Text_Normal">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-5) + '" ss:Bold="0"/>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de Impacto
			cXML += '<ss:Style ss:ID="Text_Impact">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-5) + '" ss:Bold="1"/>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de Complemento
			cXML += '<ss:Style ss:ID="Text_Complement">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-8) + '" ss:Bold="0"/>' + CRLF
			cXML += '</ss:Style>' + CRLF
			//----------------------------------------
			// Tabelas
			//----------------------------------------
			// Texto de Cabe�alho
			cXML += '<ss:Style ss:ID="Text_Table_Header">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="1" ss:Color="' + cTblText + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + cTblBack + '" ss:Pattern="Solid"/>' + CRLF
				cXML += '<ss:Alignment ss:Horizontal="CenterAcrossSelection"/>'+CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de C�lculo - Vari�veis (Cabe�alho)
			cXML += '<ss:Style ss:ID="Text_Calc_Var_Header">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="1" ss:Color="' + "#317D5B" + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + "#C4E8D8" + '" ss:Pattern="Solid"/>' + CRLF
				cXML += '<ss:Alignment ss:Horizontal="Justify"/>'+CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de C�lculo - Vari�veis (Linhas)
			cXML += '<ss:Style ss:ID="Text_Calc_Var_Row">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="1" ss:Color="' + "#000000" + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + "#E9F6F0" + '" ss:Pattern="Solid"/>' + CRLF
				cXML += '<ss:Alignment ss:Horizontal="Justify"/>'+CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de C�lculo - F�rmula (Cabe�alho)
			cXML += '<ss:Style ss:ID="Text_Calc_For_Header">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="1" ss:Color="' + "#1C7FA6" + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + "#D0EFFB" + '" ss:Pattern="Solid"/>' + CRLF
				cXML += '<ss:Alignment ss:Horizontal="Justify"/>'+CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de C�lculo - F�rmula (Linhas)
			cXML += '<ss:Style ss:ID="Text_Calc_For_Row">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="1" ss:Color="' + "#000000" + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + "#ECF6F9" + '" ss:Pattern="Solid"/>' + CRLF
				cXML += '<ss:Alignment ss:Horizontal="Justify"/>'+CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de C�lculo - Resultado (Cabe�alho)
			cXML += '<ss:Style ss:ID="Text_Calc_Res_Header">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="1" ss:Color="' + "#B83100" + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + "#FFDDD1" + '" ss:Pattern="Solid"/>' + CRLF
				cXML += '<ss:Alignment ss:Horizontal="Justify"/>'+CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de C�lculo - Resultado (Linhas)
			cXML += '<ss:Style ss:ID="Text_Calc_Res_Row">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="1" ss:Color="' + "#000000" + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + "#FFF0EB" + '" ss:Pattern="Solid"/>' + CRLF
				cXML += '<ss:Alignment ss:Horizontal="Justify"/>'+CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de Conte�do da Tabela
			cXML += '<ss:Style ss:ID="Text_Table_Normal">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="0" ss:Color="' + cTblText + '"/>' + CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de Conte�do da Tabela 2 (segunda linha)
			cXML += '<ss:Style ss:ID="Text_Table_Normal2">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="0" ss:Color="' + cTblText + '"/>' + CRLF
				cXML += '<ss:Interior ss:Color="' + cLinBack + '" ss:Pattern="Solid"/>' + CRLF
				cXML += '<ss:Borders>'+CRLF
					cXML += '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
					cXML += '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="' + cTblBord + '"/>'+CRLF
				cXML += '</ss:Borders>' + CRLF
			cXML += '</ss:Style>' + CRLF
			// Texto de T�tulo da Tabela
			cXML += '<ss:Style ss:ID="Text_Table_Title">' + CRLF
				cXML += '<ss:Font ss:Size="' + cValToChar(nMaxSize-6) + '" ss:Bold="1" ss:Color="' + cTblText + '"/>' + CRLF
			cXML += '</ss:Style>' + CRLF
		cXML += '</ss:Styles>' + CRLF
		//----------------------------------------
		// Planilha 01 - Indicador
		//----------------------------------------
		cXML += '<ss:Worksheet ss:Name="' + STR0041 + " " + AllTrim(TZE->TZE_INDIC) + '">' + CRLF //"Indicador"
			cXML += '<ss:Table ss:DefaultColumnWidth="' + cColumnWidth + '">' + CRLF
				// Cabe�alho
				fExcelHead()
				//----------------------------------------
				// Informa��es do Indicador
				//----------------------------------------
				// T�TULO
				fExcelTitle(STR0054) //"Informa��es do Indicador"

				//-- Meta
				cXML += '<ss:Row>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepMETA][1]+":" + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepMETA][2] + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
				cXML += '</ss:Row>' + CRLF
				cXML += '<ss:Row>' + CRLF
					cXML += '<ss:Cell/>' + CRLF // C�lula em Branco
					cXML += '<ss:Cell ss:StyleID="Text_Complement">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepMETDES][2] +'</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
				cXML += '</ss:Row>' + CRLF
				cXML += '<ss:Row/>' + CRLF // Linha em Branco
				//-- F�rmula
				cXML += '<ss:Row>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepFORMUL][1]+":" + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepFORMUL][2] + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
				cXML += '</ss:Row>' + CRLF
				cXML += '<ss:Row/>' + CRLF // Linha em Branco
				//-- Usu�rio
				cXML += '<ss:Row>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepUSUARI][1]+":" + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepUSUARI][2] + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepUSUNOM][2] + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
				cXML += '</ss:Row>' + CRLF
				cXML += '<ss:Row/>' + CRLF // Linha em Branco
				//-- Fun��o Pai
				cXML += '<ss:Row>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepFUNPAI][1]+":" + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + aReport[nRepFUNPAI][2] + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
				cXML += '</ss:Row>' + CRLF
			cXML += '</ss:Table>' + CRLF
		cXML += '</ss:Worksheet>' + CRLF
		//----------------------------------------
		// Planilha 02 - Vari�veis e Resultados (C�lculo)
		//----------------------------------------
		fExcelCalc()
		//----------------------------------------
		// Planilha 03+ - Vari�veis, Par�metros e Tabelas
		//----------------------------------------
		fExcelVars()
	// Final
	cXML += '</ss:Workbook>'
	// Codifica o XML em UTF8
	cXML := EncodeUTF8( cXML )

	// Escreve no Arquivo
	FWrite(nHandle, cXML)
	// Fecha o Arquivo
	FClose(nHandle)

	// Abre o Excel
	oExcel := MsExcel():New()
	oExcel:WorkBooks:Open( cFullArq ) // Abre a planilha
	oExcel:SetVisible(.T.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcelTitle
Imprime o T�tulo na Planilha.

@author Wagner Sobral de Lacerda
@since 01/10/2012

@param lHeader
	Indica se � o t�tulo do C abe�alho * Opcional
	   .T. - Cabe�alho
	   .F. - Normal
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExcelTitle(cTitle, lHeader)

	// Vari�veis auxiliares
	Local cAuxStyle := ""

	// Defaults
	Default lHeader := .F.

	//-- Define estilo do T�tulo
	cAuxStyle := If(lHeader, "Text_Header", "Text_Title")

	//----------
	// Imprime
	//----------
	cXML += '<ss:Row>' + CRLF
		cXML += '<ss:Cell ss:StyleID="' + cAuxStyle + '" ss:MergeAcross="' + cMergeCells + '">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + cTitle + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
	cXML += '</ss:Row>' + CRLF

	cXML += '<ss:Row/>' + CRLF // Linha em Branco

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcelHead
Imprime o Cabe�alho na Planilha.

@author Wagner Sobral de Lacerda
@since 01/10/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExcelHead()

	//----------
	// Imprime
	//----------
	//-- T�tulo da Consulta
	fExcelTitle(STR0049) //"Hist�rico de Indicadores"

	//-- Filial do Hist�rico
	cXML += '<ss:Row>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepEMPRES][1]+"/"+aReport[nRepFILIAL][1]+":" + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepEMPRES][2]+"/"+aReport[nRepFILIAL][2] + " (" + FWFilialName(aReport[nRepEMPRES][2], aReport[nRepFILIAL][2], 2) + ")" + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
	cXML += '</ss:Row>' + CRLF

	//-- C�digo do Hist�rico
	cXML += '<ss:Row>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepCODIGO][1]+":" + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepCODIGO][2] + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
	cXML += '</ss:Row>' + CRLF

	//-- Data e Hora
	cXML += '<ss:Row>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepDATA][1]+"/"+aReport[nRepHORA][1]+":" + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepDATA][2] + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepHORA][2] + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
	cXML += '</ss:Row>' + CRLF

	cXML += '<ss:Row/>' + CRLF // Linha em Branco

	//-- Indicador
	cXML += '<ss:Row>' + CRLF
    	cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepINDICA][1]+":" + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepINDICA][2] + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepTITULO][2] + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
	cXML += '</ss:Row>' + CRLF

	//-- Resultado
	cXML += '<ss:Row>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
			cXML += '<ss:Data ss:Type="String">' + aReport[nRepRESULT][1]+":" + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
		cXML += '<ss:Cell ss:StyleID="Text_Normal">' + CRLF
			cXML += '<ss:Data ss:Type="' + fExcelData(aReport[nRepRESULT][2]) + '">' + aReport[nRepRESULT][2] + '</ss:Data>' + CRLF
		cXML += '</ss:Cell>' + CRLF
	cXML += '</ss:Row>' + CRLF

	cXML += '<ss:Row/>' + CRLF // Linha em Branco

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcelData
Retorna o Tipo de Dado da vari�vel de acordo com as especifica��es
da Planilha.

@author Wagner Sobral de Lacerda
@since 28/09/2012

@return cDataType
/*/
//---------------------------------------------------------------------
Static Function fExcelData(uConteudo)

	// Vari�vel do Retorno
	Local cDataType := ""

	// Vari�veis auxiliares
	Local cValType := ValType(uConteudo)

	//------------------------------
	// Verifica o Tipo do Dado
	//------------------------------
	If cValType == "C" .Or. cValType == "D"
		cDataType := "String"
	ElseIf cValType == "N"
		cDataType := "Number"
	EndIf

Return cDataType

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcelVars
Imprime as Vari�veis na Planilha.

@author Wagner Sobral de Lacerda
@since 28/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExcelVars()

	// Vari�veis de impress�o din�mica
	Local nRow := 0

	Local cCodVar  := ""
	Local cNomeVar := ""

	//----------
	// Imprime
	//----------
	// Linhas
	For nRow := 1 To Len(aVariaveis)
		cCodVar  := AllTrim(aVariaveis[nRow][nVarVARIAV])
		cNomeVar := AllTrim(aVariaveis[nRow][nVarVARNOM])

		cXML += '<ss:Worksheet ss:Name="' + AllTrim(cCodVar) + '">' + CRLF
			cXML += '<ss:Table ss:DefaultColumnWidth="' + cColumnWidth + '">' + CRLF
				// Cabe�alho
				fExcelHead()
				// T�TULO
				fExcelTitle(AllTrim(cCodVar) + " - " + cNomeVar)
				// Imprime os Par�metros da Vari�vel
				fExcelPars(cCodVar)
				cXML += '<ss:Row/>' + CRLF // Linha em Branco
				// Imprime os Registros da Vari�vel
				fExcelRegs(cCodVar)
			cXML += '</ss:Table>' + CRLF
		cXML += '</ss:Worksheet>' + CRLF
	Next nRow

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcelCalc
Imprime o C�lculo na Planilha.

@author Wagner Sobral de Lacerda
@since 21/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExcelCalc()

	// Vari�veis de impress�o din�mica
	Local nRow := 0

	Local cCodVar  := ""
	Local cNomeVar := ""
	Local cResult  := ""

	//----------
	// Imprime
	//----------
	cXML += '<ss:Worksheet ss:Name="' +"C�lculo" + '">' + CRLF
		cXML += '<ss:Table ss:DefaultColumnWidth="' + cColumnWidth + '">' + CRLF
			// Cabe�alho
			fExcelHead()
			// T�tulo
			cXML += '<ss:Row/>' + CRLF // Linha em Branco
			fExcelTitle(STR0071) //"Defini��o do C�lculo"

			//------------------------------
			// Vari�veis e Resultados
			//------------------------------
			// Cabe�alho
			cXML += '<ss:Row>' + CRLF
				cXML += '<ss:Cell ss:StyleID="Text_Calc_Var_Header">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + STR0057 + '</ss:Data>' + CRLF //"Vari�vel"
				cXML += '</ss:Cell>' + CRLF
				cXML += '<ss:Cell ss:StyleID="Text_Calc_Var_Header" ss:MergeAcross="1">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + STR0020 + '</ss:Data>' + CRLF //"Descri��o"
				cXML += '</ss:Cell>' + CRLF
				cXML += '<ss:Cell ss:StyleID="Text_Calc_Var_Header">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + STR0043 + '</ss:Data>' + CRLF //"Resultado"
				cXML += '</ss:Cell>' + CRLF
			cXML += '</ss:Row>' + CRLF
			// Vari�veis e Resultados
			For nRow := 1 To Len(aCalculo)
				cCodVar  := aCalculo[nRow][1]
				cNomeVar := aCalculo[nRow][2]
				cResult := aCalculo[nRow][3]

				cXML += '<ss:Row>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Calc_Var_Row">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + cCodVar + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Calc_Var_Row" ss:MergeAcross="1">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + cNomeVar + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Calc_Var_Row">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + cResult + '</ss:Data>' + CRLF
					cXML += '</ss:Cell>' + CRLF
				cXML += '</ss:Row>' + CRLF
			Next nRow
			cXML += '<ss:Row/>' + CRLF // Linha em Branco

			//------------------------------
			// F�rmula (substitu�da)
			//------------------------------
			cXML += '<ss:Row>' + CRLF
				cXML += '<ss:Cell ss:StyleID="Text_Calc_For_Header" ss:MergeAcross="3">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + STR0058 + '</ss:Data>' + CRLF //"F�rmula (substitu�da)"
				cXML += '</ss:Cell>' + CRLF
			cXML += '</ss:Row>' + CRLF
			cXML += '<ss:Row>' + CRLF
				cXML += '<ss:Cell ss:StyleID="Text_Calc_For_Row" ss:MergeAcross="3">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + cNewFormul + '</ss:Data>' + CRLF
				cXML += '</ss:Cell>' + CRLF
			cXML += '</ss:Row>' + CRLF
			cXML += '<ss:Row/>' + CRLF // Linha em Branco

			//------------------------------
			// Resultado Num�rico
			//------------------------------
			cXML += '<ss:Row>' + CRLF
				cXML += '<ss:Cell ss:StyleID="Text_Calc_Res_Header" ss:MergeAcross="3">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + STR0059 + '</ss:Data>' + CRLF //"Resultado Num�rico"
				cXML += '</ss:Cell>' + CRLF
			cXML += '</ss:Row>' + CRLF
			cXML += '<ss:Row>' + CRLF
				cXML += '<ss:Cell ss:StyleID="Text_Calc_Res_Row" ss:MergeAcross="3">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + cNewResult + '</ss:Data>' + CRLF
				cXML += '</ss:Cell>' + CRLF
			cXML += '</ss:Row>' + CRLF

		cXML += '</ss:Table>' + CRLF
	cXML += '</ss:Worksheet>' + CRLF

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcelPars
Imprime as Par�metros na Planilha.

@author Wagner Sobral de Lacerda
@since 28/09/2012

@param cCodVariav
	C�digo da Vari�vel * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExcelPars(cCodVariav)

	// Vari�veis de impress�o din�mica
	Local cDataType := ""
	Local uValue := Nil
	Local nRow := 0, nCol := 0

	Local cAuxStyle := ""

	// Vari�veis de Busca
	Local nScanPar := 0

	// Vari�veis do Dicion�rio
	Local aCamposSX3 := {}

	//----------
	// Busca
	//----------
	nScanPar := aScan(aParams, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) })

	//----------
	// Imprime
	//----------
	If nScanPar > 0
		// T�tulo
		cXML += '<ss:Row>' + CRLF
			cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
				cXML += '<ss:Data ss:Type="String">' + FWX2Nome("TZG") + '</ss:Data>' + CRLF
			cXML += '</ss:Cell>' + CRLF
		cXML += '</ss:Row>' + CRLF
		cXML += '<ss:Row/>' + CRLF // Linha em Branco

		// Monta uma Tabela de Cabe�alho para os Par�metros
		aAdd(aCamposSX3, {"TZG_PARAM" , nParTITULO})
		aAdd(aCamposSX3, {"TZG_CONTEU", nParCONTEU})

		// Colunas da Tabela
		cXML += '<ss:Row>' + CRLF
			For nCol := 1 To Len(aCamposSX3)
				cXML += '<ss:Cell ss:StyleID="Text_Table_Header" ss:MergeAcross="1">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + AllTrim(RetTitle(aCamposSX3[nCol][1])) + '</ss:Data>' + CRLF
				cXML += '</ss:Cell>' + CRLF
			Next nCol
		cXML += '</ss:Row>' + CRLF
		// Linhas
		For nRow := 1 To Len(aParams[nScanPar][2])
			cAuxStyle := "Text_Table_Normal" + If(nRow % 2 == 0, "2", "")

			cXML += '<ss:Row>' + CRLF
			// Colunas
			For nCol := 1 To Len(aCamposSX3)
				// Valor da C�lula
				uValue := aParams[nScanPar][2][nRow][aCamposSX3[nCol][2]]
				cDataType := fExcelData(uValue)

				cXML += '<ss:Cell ss:StyleID="' + cAuxStyle + '" ss:MergeAcross="1">' + CRLF
					cXML += '<ss:Data ss:Type="' + cDataType + '">' + AllTrim(NGI6CONVER(uValue,"C",,,.T.)) + '</ss:Data>' + CRLF
				cXML += '</ss:Cell>' + CRLF
			Next nCol
			cXML += '</ss:Row>' + CRLF
		Next nRow
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcelRegs
Imprime os Registros na Planilha.

@author Wagner Sobral de Lacerda
@since 01/10/2012

@param cCodVariav
	C�digo da Vari�vel * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExcelRegs(cCodVariav)

	// Vari�veis de impress�o din�mica
	Local cDataType := ""
	Local uValue := Nil
	Local nRow := 0, nCol := 0

	// Vari�veis de Busca
	Local nScanVar := 0
	Local aImpTbls := {}
	Local nTbl := 0

	Local aGetRegis := {}
	Local aHeader := {}, aCols := {}

	//----------
	// Busca
	//----------
	nScanVar := aScan(aTabelas, {|x| AllTrim(x[nTblVARIAV]) == AllTrim(cCodVariav) })
	If nScanVar > 0
		For nTbl := nScanVar To Len(aTabelas)
			If AllTrim(aTabelas[nTbl][nTblVARIAV]) == AllTrim(cCodVariav) .And. aTabelas[nTbl][nTblSELECT]
				aAdd(aImpTbls, {AllTrim(aTabelas[nTbl][nTblTABELA]), AllTrim(aTabelas[nTbl][nTblNOME])})
			EndIf
		Next nTbl
	EndIf

	//----------
	// Imprime
	//----------
	If Len(aImpTbls) > 0
		// T�tulo
		cXML += '<ss:Row>' + CRLF
			cXML += '<ss:Cell ss:StyleID="Text_Impact">' + CRLF
				cXML += '<ss:Data ss:Type="String">' + FWX2Nome("TZF") + '</ss:Data>' + CRLF
			cXML += '</ss:Cell>' + CRLF
		cXML += '</ss:Row>' + CRLF
		cXML += '<ss:Row/>' + CRLF // Linha em Branco

		// Imprime as Tabelas
		For nTbl := 1 To Len(aImpTbls)
			// T�tulo
			cXML += '<ss:Row>' + CRLF
				cXML += '<ss:Cell ss:StyleID="Text_Table_Title">' + CRLF
					cXML += '<ss:Data ss:Type="String">' + STR0019 + ":" + " " + aImpTbls[nTbl][1] + " - " + aImpTbls[nTbl][2] + '</ss:Data>' + CRLF //"Tabela"
				cXML += '</ss:Cell>' + CRLF
			cXML += '</ss:Row>' + CRLF

			// Recebe os campos para imprimir
			aGetRegis := fGetRegis(cCodVariav, aImpTbls[nTbl][1])
			aHeader   := aClone( aGetRegis[1] )
			aCols     := aClone( aGetRegis[2] )

			If Len(aHeader) == 0
				cXML += '<ss:Row>' + CRLF
					cXML += '<ss:Cell ss:StyleID="Text_Table_Normal">' + CRLF
						cXML += '<ss:Data ss:Type="String">' + STR0072 + '</ss:Data>' + CRLF //"N�o h� dados para exibir."
					cXML += '</ss:Cell>' + CRLF
				cXML += '</ss:Row>' + CRLF
			Else
				// Colunas da Tabela
				cXML += '<ss:Row>' + CRLF
					For nCol := 1 To Len(aHeader)
						cXML += '<ss:Cell ss:StyleID="Text_Table_Header">' + CRLF
							cXML += '<ss:Data ss:Type="String">' + AllTrim(aHeader[nCol][2]) + '</ss:Data>' + CRLF
						cXML += '</ss:Cell>' + CRLF
					Next nCol
				cXML += '</ss:Row>' + CRLF
				// Linhas
				For nRow := 1 To Len(aCols)
					cXML += '<ss:Row>' + CRLF
					// Colunas
					For nCol := 1 To Len(aCols[nRow])
						// Valor da C�lula
						uValue := aCols[nRow][nCol]
						cDataType := fExcelData(uValue)

						cXML += '<ss:Cell ss:StyleID="Text_Table_Normal">' + CRLF
							cXML += '<ss:Data ss:Type="' + cDataType + '">' + AllTrim(NGI6CONVER(uValue,"C",,,.T.)) + '</ss:Data>' + CRLF
						cXML += '</ss:Cell>' + CRLF
					Next nCol
					cXML += '</ss:Row>' + CRLF
				Next nRow
			EndIf
			cXML += '<ss:Row/>' + CRLF // Linha em Branco
		Next nTbl
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: SALVAR/CARREGAR MODELOS DE IMPRESS�O                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fModelos
Salva ou Carrega um Modelo de Impress�o.

@author Wagner Sobral de Lacerda
@since 05/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fModelos()

	// Vari�veis do Dilaog
	Local oDlgModelo
	Local cDlgModelo := OemToAnsi(STR0073) //"Modelos de Impress�o"
	Local lDlgModelo := .F.
	Local oPnlModelo

	Local oFntBold := TFont():New(,,18,,.T.)

	Local oPnlCabec
	Local oPnlLeft
	Local oPnlAll
	Local oTmpPnl

	Local oPPanel
	Local cShape := "", nIDShape := 0
	Local aBotao := {}, nBotao := 0
	Local nWidth := 0, nHeight := 0
	Local nTop := 0, nHeiBtn := 0
	Local aClique := {}

	Local nClrBack := RGB(248,248,248)
	Local cClrBack := "#F8F8F8"

	Local oPnlSave
	Local oPnlLoad

	Local aHeadModel := {}
	Local aColsModel := {}

	// Vari�veis para Salvar/Carregar Modelo
	Local cBarra := If(IsSrvUnix(),"/","\")
	Local cPath := CurDir()
	Local cPasta := "SIGA" + cModulo
	Local cArquivo := "NGIND011_MODEL_<ARQUIVO>.xml"

	Private cFullPath := cPath + cPasta + cBarra
	Private cFullArq  := cFullPath + cArquivo

	Private cGetCodigo := "", nSizCodigo := 10
	Private cGetDescri := "", nSizDescri := 60
	Private oGetDados

	Private aModelos := {}

	// Mostra Painel Preto
	oBlackPnl:Show()

	// Conte�do inicial do Modelo Carregado
	cGetCodigo := PADR(cUltModCod, nSizCodigo, " ")
	cGetDescri := PADR(cUltModDes, nSizDescri, " ")

	//-- Define os bot�es
	aAdd(aBotao, {STR0074, "salvar.png"   , {|| fModelPnl("SAVE", oPnlSave, oPnlLoad) } }) //"Salvar Modelo"
	aAdd(aBotao, {STR0075, "sduimport.png", {|| fModelPnl("LOAD", oPnlSave, oPnlLoad) } }) //"Carregar Modelo"

	//-- Busca os Modelos j� existentes de acordo com as tabelas que existem nas vari�veis atuais
	// Cabe�alho
	// 1      ; 2     ; 3       ; 4       ; 5       ; 6         ; 7         ; 8    ; 9         ; 10
	// T�tulo ; Campo ; Picture ; Tamanho ; Decimal ; Valida��o ; Reservado ; Tipo ; Reservado ; Reservado
	aAdd(aHeadModel, {STR0076, "CODIGO", "@!", 10, 0, ".T.", Nil, "C", Nil, Nil}) //"Modelo"
	aAdd(aHeadModel, {STR0020, "DESCRI", ""  , 60, 0, ".T.", Nil, "C", Nil, Nil}) //"Descri��o"

	// Conte�do
	aColsModel := aClone( fModelGet() )

	//--------------------
	// Monta Dialog
	//--------------------
	DEFINE MSDIALOG oDlgModelo TITLE cDlgModelo FROM 0,0 TO 400,600 OF oMainWnd PIXEL

		// Painel principal do Dialog
		oPnlModelo := TPanel():New(01, 01, , oDlgModelo, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlModelo:Align := CONTROL_ALIGN_ALLCLIENT

			// Painel do Cabe�alho
			oPnlCabec := TPanel():New(01, 01, , oPnlModelo, , , , CLR_BLACK, nClrBack, 100, 045)
			oPnlCabec:Align := CONTROL_ALIGN_TOP

				// Grupo
				TGroup():New(005, 005, (oPnlCabec:nClientHeight*0.50)-005, (oPnlCabec:nClientWidth*0.50)-005, STR0077, oPnlCabec, , , .T.) //"�ltimo Modelo Carregado"

					// C�digo
					@ 015,010 SAY OemToAnsi(STR0078) OF oPnlCabec PIXEL //"C�digo"
					TGet():New(025, 010, {|| cUltModCod }, oPnlCabec, 060, 008, "@!", {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
				 				.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .F./*lHasButton*/)
					// Descri��o
					@ 015,080 SAY OemToAnsi(STR0020) OF oPnlCabec PIXEL //"Descri��o"
					TGet():New(025, 080, {|| cUltModDes }, oPnlCabec, 180, 008, "", {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
				 				.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .F./*lHasButton*/)

			// Painel de Espa�o
			oTmpPnl := TPanel():New(01, 01, , oPnlModelo, , , , CLR_BLACK, nClrBack, 100, 002)
			oTmpPnl:Align := CONTROL_ALIGN_TOP

			// Painel dos Bot�es
			oPnlLeft := TPanel():New(01, 01, , oPnlModelo, , , , CLR_BLACK, CLR_WHITE, 035, 100)
			oPnlLeft:Align := CONTROL_ALIGN_LEFT

				// TPaintPanel dos Bot�es
				oPPanel := TPaintPanel():New(0/*nRow*/, 0/*nCol*/, 1/*nWidth*/, 1/*nHeight*/, oPnlLeft/*oWnd*/, /*lCentered*/, /*lRight*/)
				oPPanel:Align := CONTROL_ALIGN_ALLCLIENT
				oPPanel:blClicked := {|x,y,lInit| fModelClk(oPPanel, aBotao, aClique, lInit) }

					nWidth  := oPPanel:nClientWidth
					nHeight := oPPanel:nClientHeight

					//-- Fundo
					cShape := "ID=" + cValToChar(++nIDShape) + ";Type=1;"
					cShape += "Left=" + cValToChar(0) + ";"
					cShape += "Top=" + cValToChar(0) + ";"
					cShape += "Width=" + cValToChar(nWidth) + ";"
					cShape += "Height=" + cValToChar(nHeight) + ";"
					cShape += "Gradient=1,0,0,0,0,0.0," + cClrBack + ";"
					cShape += "Pen-Width=1;Pen-Color=" + cClrBack + ";"
					cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=1;"
					// Adiciona Shape
					oPPanel:AddShape(cShape)

					//-- Bot�es
					nTop    := 2
					nHeiBtn := 045
					For nBotao := 1 To Len(aBotao)
						//-- Fundo 1
						cShape := "ID=" + cValToChar(++nIDShape) + ";Type=6;"
						cShape += "From-Left=" + cValToChar(0) + ";From-Top=" + cValToChar(nTop) + ";"
						cShape += "To-Left=" + cValToChar(nWidth) + ";To-Top=" + cValToChar(nTop) + ";"
						cShape += "Gradient=1,0,0,0,0,0.0,#B3B3B3;"
						cShape += "Pen-Width=1;Pen-Color=#B3B3B3;"
						cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=0;"
						// Adiciona Shape
						oPPanel:AddShape(cShape)
						//-- Fundo 2
						cShape := "ID=" + cValToChar(++nIDShape) + ";Type=6;"
						cShape += "From-Left=" + cValToChar(0) + ";From-Top=" + cValToChar(nTop+nHeiBtn) + ";"
						cShape += "To-Left=" + cValToChar(nWidth) + ";To-Top=" + cValToChar(nTop+nHeiBtn) + ";"
						cShape += "Gradient=1,0,0,0,0,0.0,#B3B3B3;"
						cShape += "Pen-Width=1;Pen-Color=#B3B3B3;"
						cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=0;"
						// Adiciona Shape
						oPPanel:AddShape(cShape)
						//-- Fundo 3
						cShape := "ID=" + cValToChar(++nIDShape) + ";Type=1;"
						cShape += "Left=" + cValToChar(0) + ";"
						cShape += "Top=" + cValToChar(nTop) + ";"
						cShape += "Width=" + cValToChar(nWidth) + ";"
						cShape += "Height=" + cValToChar(nHeiBtn) + ";"
						cShape += "Gradient=1,0,0,0,0,0.0,#F2F2F2;"
						cShape += "Pen-Width=0;"
						cShape += "Tooltip=" + aBotao[nBotao][1] + ";"
						cShape += "Can-Move=0;Can-Deform=0;Can-Mark=1;Is-Container=0;"
						// Adiciona Shape
						oPPanel:AddShape(cShape)
						aAdd(aClique, {nIDShape, nBotao, "EXECUTE"})
						//-- Container
						cShape := "ID=" + cValToChar(++nIDShape) + ";Type=1;"
						cShape += "Left=" + cValToChar(0) + ";"
						cShape += "Top=" + cValToChar(nTop) + ";"
						cShape += "Width=" + cValToChar(nWidth) + ";"
						cShape += "Height=" + cValToChar(nHeiBtn) + ";"
						cShape += "Gradient=1,0,0,0,0,0.0,#EBEBEB;"
						cShape += "Pen-Width=1;Pen-Color=#B3B3B3;"
						cShape += "Tooltip=" + aBotao[nBotao][1] + ";"
						cShape += "Can-Move=0;Can-Deform=0;Can-Mark=1;Is-Container=0;"
						// Adiciona Shape
						oPPanel:AddShape(cShape)
						aAdd(aClique, {nIDShape, nBotao, "CONTAINER"})
						//-- Bot�o
						cShape := "ID=" + cValToChar(++nIDShape) + ";Type=8;"
						cShape += "Left=" + cValToChar((nWidth/2)-12) + ";"
						cShape += "Top=" + cValToChar(nTop+(nHeiBtn/2)-12) + ";"
						cShape += "Width=25;"
						cShape += "Height=25;"
						cShape += "Image-File=rpo:" + aBotao[nBotao][2] + ";"
						cShape += "Tooltip=" + aBotao[nBotao][1] + ";"
						cShape += "Can-Move=0;Can-Deform=0;Can-Mark=1;Is-Container=0;"
						// Adiciona Shape
						oPPanel:AddShape(cShape)
						aAdd(aClique, {nIDShape, nBotao, "EXECUTE"})
							//-- Indica��o
							cShape := "ID=" + cValToChar(++nIDShape) + ";Type=5;"
							cShape += "Polygon=" + ; // Left:Top, Left:Top, Left:Top
												cValToChar(nWidth)+":"+cValToChar(nTop) + "," + ;
												cValToChar(nWidth)+":"+cValToChar(nTop+nHeiBtn) + "," + ;
												cValToChar(nWidth-012)+":"+cValToChar(nTop+(nHeiBtn/2)) + ";"
							cShape += "Gradient=1,0,0,0,0,0.0,#FFFFFF;"
							cShape += "Pen-Width=1;Pen-Color=#FFFFFF;"
							cShape += "Tooltip=" + aBotao[nBotao][1] + ";"
							cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=0;"
							// Adiciona Shape
							oPPanel:AddShape(cShape)
							aAdd(aClique, {nIDShape, nBotao, "INDICACAO"})

						nTop += ( nHeiBtn + 005 )
					Next nBotao

			// Painel TODO
			oPnlAll := TPanel():New(01, 01, , oPnlModelo, , , , CLR_BLACK, CLR_WHITE, 050, 100)
			oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel SALVAR
				oPnlSave := TPanel():New(01, 01, , oPnlModelo, , , , CLR_BLACK, CLR_WHITE, 050, 100)
				oPnlSave:Align := CONTROL_ALIGN_ALLCLIENT

					// Grupo
					TGroup():New(002, 002, (oPnlSave:nClientHeight*0.50)-015, (oPnlSave:nClientWidth*0.50)-002, STR0074, oPnlSave, , , .T.) //"Salvar Modelo"

						// C�digo
						@ 015,010 SAY OemToAnsi(STR0078) FONT oFntBold OF oPnlSave PIXEL //"C�digo"
						TGet():New(025, 010, {|u| If(PCount() > 0, cGetCodigo := u, cGetCodigo) }, oPnlSave, 060, 010, "@!", {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
					 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .F./*lHasButton*/)
						// Descri��o
						@ 045,010 SAY OemToAnsi(STR0020) FONT oFntBold OF oPnlSave PIXEL //"Descri��o"
						TGet():New(055, 010, {|u| If(PCount() > 0, cGetDescri := u, cGetDescri) }, oPnlSave, 220, 010, "", {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
					 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .F./*lHasButton*/)

					 	// Bot�o: Salvar
					 	TButton():New(075, 010, STR0079, oPnlSave, {|| fModelSav() },; //"Salvar"
										030, 012, , , .F., .T., .F., , .F., , , .F.)

				// Inicia Escondido
				oPnlSave:Hide()

				// Painel CARREGAR
				oPnlLoad := TPanel():New(01, 01, , oPnlModelo, , , , CLR_BLACK, CLR_WHITE, 050, 100)
				oPnlLoad:Align := CONTROL_ALIGN_ALLCLIENT

					// Grupo
					TGroup():New(002, 002, (oPnlLoad:nClientHeight*0.50)-015, (oPnlLoad:nClientWidth*0.50)-002, STR0075, oPnlLoad, , , .T.) //"Carregar Modelo"

						// GetDados com os Modelos
						oGetDados := MsNewGetDados():New(012/*nTop*/, 007/*nLeft*/, (oPnlLoad:nClientHeight*0.50)-035/*nBottom*/, (oPnlLoad:nClientWidth*0.50)-007/*nRight */, 0/*nStyle*/, ;
											"AllwaysTrue()"/*cLinhaOk*/, "AllwaysTrue()"/*cTudoOk*/, /*cIniCpos*/, /*aAlter*/, /*nFreeze*/, ;
											999/*nMax*/, /*cFieldOk*/, /*cSuperDel*/, /*cDelOk*/, oPnlLoad/*oWnd*/, ;
											aHeadModel/*aPartHeader*/, aColsModel/*aParCols*/, /*uChange*/, /*cTela*/)

						// Bot�o: Load
					 	TButton():New((oPnlLoad:nClientHeight*0.50)-030, 010, STR0080, oPnlLoad, {|| fModelLoa() },; //"Carregar"
										030, 012, , , .F., .T., .F., , .F., , , .F.)

				// Inicia Escondido
				oPnlLoad:Hide()

		// Inicializa os Cliques do TPaintPanel
		Eval(oPPanel:blClicked, 0, 0, .T.)

	ACTIVATE MSDIALOG oDlgModelo CENTERED

	// Esconde Painel Preto
	oBlackPnl:Hide()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fModelGet
Recebe os Modelos de Impress�o j� salvos.

@author Wagner Sobral de Lacerda
@since 07/12/2012

@return aGetModels
/*/
//---------------------------------------------------------------------
Static Function fModelGet()

	// Vari�vel do Retorno
	Local aGetModels := {}

	// Vari�veis auxiliares
	Local aGetTbls := {}
	Local nX := 0

	Local aDirectory := {}
	Local cPesqDir := StrTran(cFullArq, "<ARQUIVO>", "*")
	Local nDir := 0

	Local oXml, oTabela, oModelo, oCampo
	Local cError := ""
	Local cWarning := ""
	Local aModCpos := {}
	Local nModelo := 0, nCampo := 0
	Local nScanMod := 0, nAddCpo := 0, nScanCpo := 0

	// Zera o Array de Modelos
	aModelos := {}

	//-- Verifica quais as tabelas devem ser buscadas
	For nX := 1 To Len(aTabelas)
		If aScan(aGetTbls, {|x| AllTrim(x) == AllTrim(aTabelas[nX][nTblTABELA]) }) == 0
			aAdd(aGetTbls, aTabelas[nX][nTblTABELA])
		EndIf
	Next nX

	//-- Busca os arquivos no diret�rio
	/*
		posi��o		metas�mbolo		directry.ch
		1			cNome			F_NAME
		2			cTamanho		F_SIZE
		3			dData			F_DATE
		4			cHora			F_TIME
		5			cAtributos		F_ATT
	*/
	aDirectory := aClone( Directory( cPesqDir/*cDirEsp*/, /*cAtributos*/, Nil/*xParam3*/, .T./*lCaseSensitive*/) )
	For nDir := 1 To Len(aDirectory)
		oXml := XmlParserFile(cFullPath + aDirectory[nDir][1], "_", @cError, @cWarning)
		If ValType(oXml) == "O"
			oTabela := XmlGetChild (oXml/*oParent*/, 1/*nChild*/)
			If ValType(oTabela) == "O"
				nModelo := 1
				While ValType(oModelo := XmlGetChild(oTabela/*oParent*/, nModelo/*nChild*/)) == "O"
					aModCpos := {}
					nCampo := 1
					While ValType(oCampo := XmlGetChild(oModelo/*oParent*/, nCampo/*nChild*/)) == "O"
						aAdd(aModCpos, oCampo:RealName)
						nCampo++
					End
					nScanMod := aScan(aModelos, {|x| AllTrim(x[1]) == AllTrim(oModelo:RealName) })
					If nScanMod == 0
						// 1      ; 2         ; 3
						// C�digo ; Descri��o ; {Campos Habilitados}
						aAdd(aModelos, {oModelo:RealName, oModelo:Text, aClone(aModCpos)})
					Else
						For nAddCpo := 1 To Len(aModCpos)
							If aScan(aModelos[nScanMod][3], {|x| AllTrim(x) == AllTrim(aModCpos[nAddCpo]) }) == 0
								aAdd(aModelos[nScanMod][3], aModCpos[nAddCpo])
							EndIf
						Next nAddCpo
					EndIf
					nModelo++
				End
			EndIf
		EndIf
	Next nDir

	//-- Atribui o Conte�do para a GetDados
	For nX := 1 To Len(aModelos)
		aAdd(aGetModels, {aModelos[nX][1], aModelos[nX][2], .F.})
	Next nX
	If Len(aGetModels) == 0
		aGetModels := { {" ", " ", .F.} }
	EndIf

Return aGetModels

//---------------------------------------------------------------------
/*/{Protheus.doc} fModelClk
Clique do TPaintPanel do Modelo de Impress�o.

@author Wagner Sobral de Lacerda
@since 06/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fModelClk(oPPanel, aBotao, aClique, lInit)

	// Vari�veis auxiliares
	Local nShapeAtu := oPPanel:ShapeAtu
	Local nBotao := 0
	Local nX := 0, nScan := 0

	Local nExecute := 0

	// Defaults
	Default lInit := .F.

	// Busca o Bot�o
	If lInit
		nBotao := 1
	Else
		nScan := aScan(aClique, {|x| x[1] == nShapeAtu })
		nBotao := If(nScan > 0, aClique[nScan][2], 0)
	EndIf

	// Percorre todos os cliques poss�veis
	For nX := 1 To Len(aClique)
		If aClique[nX][2] == nBotao
			If aClique[nX][3] == "INDICACAO"
				oPPanel:SetVisible(aClique[nX][1], .T.)
			ElseIf aClique[nX][3] == "EXECUTE"
				nExecute := nBotao
			ElseIf aClique[nX][3] == "CONTAINER"
				oPPanel:SetVisible(aClique[nX][1], .T.)
			EndIf
		Else
			If aClique[nX][3] == "INDICACAO"
				oPPanel:SetVisible(aClique[nX][1], .F.)
			ElseIf aClique[nX][3] == "CONTAINER"
				oPPanel:SetVisible(aClique[nX][1], .F.)
			EndIf
		EndIf
	Next nX

	// Executa a a��o do Bot�o
	If nExecute > 0
		Eval(aBotao[nExecute][3])
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fModelPnl
Clique do TPaintPanel do Modelo de Impress�o.

@author Wagner Sobral de Lacerda
@since 06/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fModelPnl(cTipo, oPnlSave, oPnlLoad)

	//----------
	// Executa
	//----------
	If cTipo == "SAVE"
		oPnlSave:Show()
		oPnlLoad:Hide()
	ElseIf cTipo == "LOAD"
		oPnlSave:Hide()
		oPnlLoad:Show()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fModelSav
Salva o Modelo de Impress�o.

@author Wagner Sobral de Lacerda
@since 06/12/2012

@return lRetorno
/*/
//---------------------------------------------------------------------
Static Function fModelSav()

	// Vari�vel do Retorno
	Local lRetorno := .T.

	// Vari�veis do Arquivo
	Local cFullXml := ""

	// Vari�veis do XML
	Local cXML
	Local cError := ""
	Local cWarning := ""
	Local oNodeTable
	Local oNodeModel
	Local oNodeField

	// Vari�veix auxiliares
	Local cSavTbl := "", cSavCpo := ""
	Local nSavTbl := 0 , nSavCpo := 0
	Local nScan := 0

	Local cSetCodigo := AllTrim(cGetCodigo)
	Local cSetDescri := AllTrim(cGetDescri)

	Local cMsg := ""
	Local lSubstit := .F.

	// Objeto do XML
	Private oXML // Deve ser PRIVATE para poder ser visto pela Macro Execu��o -> &("oXML")

	/* FORMATO DO ARQUIVO XML:
		<Tabela> -> TAG identificadora da Tabela
			<Modelo> -> TAG identificadora do C�digo do Modelo
				<IDCampo> -> TAG identificadora dos Campos Habilitados
				</IDCampo>
			</Modelo>
		</Tabela>
	*/

	// Verifica se Deve executar
	If aScan(aTabelas, {|x| x[nTblSELECT] }) == 0
		MsgInfo(STR0081, STR0001) //"N�o � poss�vel salvar o modelo sem nenhuma tabela selecionada..." ## "Aten��o"
		lRetorno := .F.
	EndIf
	If lRetorno
		//------------------------------
		// Cria o XML
		//------------------------------
		// Caso ainda n�o exista, cria o CAMINHO
		MAKEDIR(cFullPath)
		// Percorre as Tabelas
		For nSavTbl := 1 To Len(aTabelas)
			If !aTabelas[nSavTbl][nTblSELECT] ; Loop ; EndIf
			cSavTbl := AllTrim(aTabelas[nSavTbl][nTblTABELA])
			cFullXml := StrTran(cFullArq, "<ARQUIVO>", cSavTbl)

			// Caso ainda n�o exista, cria o XML
			If !File(cFullXml)
				cXML := '<?xml version="1.0" encoding="utf-8"?>'
				cXML += '<' + cSavTbl + '>'
				cXML += '</' + cSavTbl + '>'

				oXML := XmlParser(cXML, "_", @cError, @cWarning)
				SAVE oXML XMLFILE cFullXml
			EndIf
			// Recebe o XML como um Objeto
			oXML := XmlParserFile(cFullXml, "_", @cError, @cWarning)

			//------------------------------
			// Cria Conte�do
			//------------------------------
			// Busca o N� (caso n�o encontre, cria)
			// Observa��o: Quando o objeto � criado, sempre � colocado um underline "_" (definido acima na fun��o 'XmlParserFile') a frente dos nomes dos n�s,
			// por�m, isto n�o � feito quando o n� acaba de ser criado, ficando somente com o seu nome mesmo (sem o "_"); o underline "_"
			// somente ser� colocado quando o objeto for criado novamente.
			If ValType(oXML) == "O"
				// Tabela
				oNodeTable := XmlChildEx(oXML, "_"+cSavTbl)
				If ValType(oNodeTable) <> "O"
					XmlNewNode(oXML, cSavTbl, cSavTbl, "NOD")
					oNodeTable := XmlChildEx(oXML, cSavTbl)
				EndIf

					// Modelo
					lSubstit := .T.

					oNodeModel := XmlChildEx(oNodeTable, "_"+cSetCodigo)
					If ValType(oNodeModel) <> "O"
						XmlNewNode(oNodeTable, cSetCodigo, cSetCodigo, "NOD")
						oNodeModel := XmlChildEx(oNodeTable, cSetCodigo)
					Else
						lSubstit := !MsgYesNo(STR0082 + CRLF + CRLF + STR0083, STR0001) //"J� existe um Modelo com este C�digo." ## "Deseja substitu�-lo?" ## "Aten��o"
					EndIf

					If lSubstit
						oNodeModel:Text := cSetDescri

						// Campos
						nScan := aScan(aCampos, {|x| AllTrim(x[1]) == AllTrim(aTabelas[nSavTbl][nTblVARIAV]) .And. AllTrim(x[2]) == AllTrim(aTabelas[nSavTbl][nTblTABELA]) })
						If nScan > 0
							For nSavCpo := 1 To Len(aCampos[nScan][3])
								If !aCampos[nScan][3][nSavCpo][nCpoSELECT] ; Loop ; EndIf
								cSavCpo := AllTrim(aCampos[nScan][3][nSavCpo][nCpoCAMPO])

								// ID dos Campos Habilitados
								oNodeField := XmlChildEx(oNodeModel, "_"+cSavCpo)
								If ValType(oNodeField) <> "O"
									XmlNewNode(oNodeModel, cSavCpo, cSavCpo, "NOD")
									oNodeField := XmlChildEx(oNodeModel, cSavCpo)
								EndIf
							Next nSavCpo
						EndIf
					EndIf

					// Salva o Arquivo XML
					SAVE oXML XMLFILE cFullXml
			EndIf
		Next nSavTbl

		// Retorno
		If lRetorno
			cMsg := STR0084 //"Modelo Salvo com sucesso!"
			cUltModCod := cGetCodigo
			cUltModDes := cGetDescri
			// Conte�do
			oGetDados:aCols := aClone( fModelGet() )
			oGetDados:GoTop()
			oGetDados:Refresh()
		Else
			cMsg := STR0085 //"N�o foi poss�vel salvar o modelo..."
		EndIf
		MsgInfo(cMsg, STR0001) //"Aten��o"
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fModelLoa
Carrega o Modelo de Impress�o.

@author Wagner Sobral de Lacerda
@since 06/12/2012

@return lRetorno
/*/
//---------------------------------------------------------------------
Static Function fModelLoa()

	// Vari�vel do Retorno
	Local lRetorno := .T.

	// Vari�veis da GetDados
	Local aCols := oGetDados:aCols
	Local nAT := oGetDados:nAT

	// Vari�veis auxiliares
	Local nModelo := 0
	Local nAtuTbl := 0, nCpo := 0
	Local nSeekTbl := 0, nSeekCpo := 0
	Local cMsg := ""
	Local lHabilitado := .F.

	//-- Carrega o Modelo
	nModelo := aScan(aModelos, {|x| AllTrim(x[1]) == AllTrim(aCols[nAT][1]) })
	If nModelo == 0
		lRetorno := .F.
	Else
		//-- Atualiza os Campos
		For nSeekTbl := 1 To Len(aCampos)
			lHabilitado := .F.
			For nSeekCpo := 1 To Len(aCampos[nSeekTbl][3])
				nCpo := aScan(aModelos[nModelo][3], {|x| AllTrim(x) == AllTrim(aCampos[nSeekTbl][3][nSeekCpo][nCpoCAMPO]) })
				aCampos[nSeekTbl][3][nSeekCpo][nCpoSELECT] := ( nCpo > 0 )
				If !lHabilitado .And. nCpo > 0
					lHabilitado := .T.
				EndIf
			Next nSeekCpo
			//-- Atualiza a Tabela
			nAtuTbl := aScan(aTabelas, {|x| AllTrim(x[nTblVARIAV]) == AllTrim(aCampos[nSeekTbl][1]) .And. AllTrim(x[nTblTABELA]) == AllTrim(aCampos[nSeekTbl][2]) })
			If nAtuTbl > 0
				aTabelas[nAtuTbl][nTblSELECT] := lHabilitado
			EndIf
		Next nSeekTbl
	EndIf

	// Retorno
	If lRetorno
		cMsg := STR0086 //"Modelo Carregado com sucesso!"
		cUltModCod := aModelos[nModelo][1]
		cUltModDes := aModelos[nModelo][2]
	Else
		cMsg := STR0087 //"N�o foi poss�vel carregar o modelo..."
	EndIf
	MsgInfo(cMsg, STR0001) //"Aten��o"

	// Atualiza o Folder
	Eval( oFoldVars:bChange )

Return .T.
