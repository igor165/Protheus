#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND013.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"
#INCLUDE	"MsGraphi.ch"

#DEFINE _nVersao 02 // Vers�o do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND013
Gr�fico Evolutivo de Indicadores.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@param cCodIndFil
	C�digo da Filial do Indicador * Opcional
@param cCodIndica
	C�digo do Indicador * Opcional

@return lExecute
/*/
//---------------------------------------------------------------------
Function NGIND013(cCodIndFil, cCodIndica)
	
	//------------------------------
	// Armazena as vari�veis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM(_nVersao)
	
	Local lExecute := .T. // Vari�vel para identificar se pode ou n�o executar esta rotina
	
	// Defaults
	Default cCodIndFil := ""
	Default cCodIndica := ""
	
	//-------------------------------
	// Valida a execu��o do programa
	//-------------------------------
	lExecute := NGIND007OP()
	
	If lExecute
		// Fun��o principal
		fMain(cCodIndFil, cCodIndica)
	EndIf
	
	//------------------------------
	// Devolve as vari�veis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMain
Fun��o Principal.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@param cCodIndFil
	C�digo da Filial do Indicador * Opcional
@param cCodIndica
	C�digo do Indicador * Opcional

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fMain(cCodIndFil, cCodIndica)
	
	// Vari�veis do Dialog
	Local oDlg013
	Local cDlg013 := OemToAnsi(STR0001) //"Gr�fico Evolutivo de Indicadores"
	Local lDlg013 := .F.
	Local oPnl013
	
	Local oPnlAll
	Local oTmpBtn
	Local oSeparador
	
	Local oFntBold := TFont():New(,,,,.T.)
	Local aNGColor := aClone( NGCOLOR() )
	Local nClrCabec := RGB(245,245,245)
	
	// Defaults
	Default cCodIndFil := ""
	Default cCodIndica := ""
	
	// Vari�vel que indica se os indicadores do gr�fico s�o provenientes do par�metro desta fun��o
	Private lIndsByPar := .F.
	
	// Dimensionamento da Janela
	Private aSize := MsAdvSize(.F.) // .T./.F. - Possui/N�o Possui EnchoiceBar
	
	// Painel Preto
	Private oBlackPnl
	
	// Vari�veis do Gr�fico
	Private oPnlCabec
	Private oPnlGraph
	Private aResults := {}
	Private oGrafico, aSeries := {}
	
	// Vari�veis de Configura��es
	Private aIndicadores := {}, aBtnIndics := {}
	Private aParametros  := {}
	Private dDeData := CTOD(""), dAteData := CTOD("")
	Private cGraf3D  := "1" // Sim
	Private cTipGraf := "1" // Linha
	Private cAgrupa  := "2" // Di�rio
	Private lMsgSeries := .T.
	
	// Carrega indicador espec�fico (caso exista)
	fChargeEsp(cCodIndFil, cCodIndica)
	
	//--------------------
	// Monta o Dialog
	//--------------------
	DEFINE MSDIALOG oDlg013 TITLE cDlg013 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		
		// Painel principal do Dialog
		oPnl013 := TPanel():New(01, 01, , oDlg013, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnl013:Align := CONTROL_ALIGN_ALLCLIENT
			
			//--------------------
			// Gr�fico
			//--------------------
			oPnlAll := TPanel():New(01, 01, , oPnl013, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT
				
				// Cabe�alho
				oPnlCabec := TPanel():New(01, 01, , oPnlAll, , , , nClrCabec, nClrCabec, 100, 020)
				oPnlCabec:Align := CONTROL_ALIGN_TOP
					
						// Separador
						oSeparador := TPanel():New(01, 01, , oPnlCabec, , , , nClrCabec, nClrCabec, 002, 002)
						oSeparador:Align := CONTROL_ALIGN_LEFT
					
					If !lIndsByPar
						// Bot�o: Indicadores
						oTmpBtn := TBtnBmp2():New(01, 01, 40, 40, "select", , , , {|| fSlcInds() }, oPnlCabec, OemToAnsi(STR0002 + " <F6>"), , .T.) //"Selecionar Indicadores"
						oTmpBtn:Align := CONTROL_ALIGN_LEFT
						
							// Separador
							oSeparador := TPanel():New(01, 01, , oPnlCabec, , , , nClrCabec, nClrCabec, 002, 002)
							oSeparador:Align := CONTROL_ALIGN_LEFT
					EndIf
					
					// Bot�o: Configura��es
					oTmpBtn := TBtnBmp2():New(01, 01, 40, 40, "cfgimg32", , , , {|| fConfig() }, oPnlCabec, OemToAnsi(STR0003 + " <F7>"), , .T.) //"Configura��es"
					oTmpBtn:Align := CONTROL_ALIGN_LEFT
					
						// Separador
						oSeparador := TPanel():New(01, 01, , oPnlCabec, , , , nClrCabec, nClrCabec, 002, 002)
						oSeparador:Align := CONTROL_ALIGN_LEFT
					
					If !lIndsByPar
						// Bot�o: Gr�fico
						oTmpBtn := TBtnBmp2():New(01, 01, 40, 40, "atalho", , , , {|| fIndsDisp() }, oPnlCabec, OemToAnsi(STR0004 + " <F8>"), , .T.) //"Indicadores Dispon�veis"
						oTmpBtn:Align := CONTROL_ALIGN_LEFT
						
							// Separador
							oSeparador := TPanel():New(01, 01, , oPnlCabec, , , , nClrCabec, nClrCabec, 002, 002)
							oSeparador:Align := CONTROL_ALIGN_LEFT
					EndIf
					
					// Bot�o: Atualizar
					oTmpBtn := TBtnBmp2():New(01, 01, 40, 40, "reload", , , , {|| fCriaGrafico() }, oPnlCabec, OemToAnsi(STR0005 + " <F5>"), , .T.) //"Atualizar"
					oTmpBtn:Align := CONTROL_ALIGN_LEFT
					
					// Separador
					oSeparador := TPanel():New(01, 01, , oPnlCabec, , , , nClrCabec, nClrCabec, 002, 002)
					oSeparador:Align := CONTROL_ALIGN_LEFT
						
					// Bot�o: Sair
					oTmpBtn := TBtnBmp2():New(01, 01, 40, 40, "ng_ico_final", , , , {|| oDlg013:End() }, oPnlCabec, OemToAnsi( "Sair" ), , .T. ) //"Sair"
					oTmpBtn:Align := CONTROL_ALIGN_LEFT
					
				// Gr�fico
				oPnlGraph := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlGraph:Align := CONTROL_ALIGN_ALLCLIENT
					
		// Painel Preto sobre a tela
		oBlackPnl := TPanel():New(0, 0, , oDlg013, , , , , SetTransparentColor(CLR_BLACK,70), aSize[6], aSize[5], .F., .F.)
		oBlackPnl:Hide()
		
		// Inicializa as teclas de atalho
		SetKey(VK_F5, {|| fCriaGrafico() }) // F5: Atualizar
		SetKey(VK_F7, {|| fConfig() }) // F7: Cofigura��es
		If !lIndsByPar
			SetKey(VK_F6, {|| fSlcInds() }) // F6: Indicadores
			SetKey(VK_F8, {|| fIndsDisp() }) // F8: Indicadores Dispon�veis
		EndIf
		
		// Ao iniciar o Dialog, se n�o houver nenhum indicador selecionado, abre a tela de sele��o de indicadores
		If Len(aIndicadores) == 0
			fSlcInds()
		Else
			// Cria o Gr�fico
			fCriaGrafico()
		EndIf
		
	ACTIVATE MSDIALOG oDlg013 CENTERED/*ON INIT EnchoiceBar(oDlg013, ;
		{|| lDlg013 := .T., oDlg013:End() }, ;
		{|| lDlg013 := .F., oDlg013:End() })*/ 
	
Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: CARREGA INDICADOR ESPEC�FICO                                                  ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fChargeEsp
Carrega um indicador espec�fico para a consulta.

@author Wagner Sobral de Lacerda
@since 07/01/2013

@param cCodIndFil
	C�digo da Filial do Indicador * Opcional
@param cCodIndica
	C�digo do Indicador * Obrigat�rio

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fChargeEsp(cCodIndFil, cCodIndica)
	
	// Vari�veis auxiliares
	Local aSelect := aClone( NGI8SlcCha() )
	Local nX := 0, nY := 0
	
	// Defaults
	Default cCodIndFil := xFilial("TZ5")
	Default cCodIndica := ""
	
	// Vari�vel dos Indicadores
	Private aClassific := aClone( aSelect[2] )
	
	// Verifica se Executa
	If Empty(cCodIndica)
		Return .F.
	EndIf
	
	// Seleciona o Indicador
	For nX := 1 To Len(aClassific)
		For nY := 1 To Len(aClassific[nX][3])
			If AllTrim(aClassific[nX][3][nY][1]) == AllTrim(cCodIndica)
				aClassific[nX][3][nY][6] := .T.
				lIndsByPar := .T.
				Exit
			EndIf
		Next nY
	Next nX
	
	// Carrega os Indicadores
	fSlcDefInds()
	
Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: SELECIONAR INDICADORES                                                        ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fSlcInds
Seleciona Indicadores para o Gr�fico Evolutivo.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fSlcInds()
	
	// Armazena conte�do anterior
	Local aNGBEGINPRM := NGBEGINPRM(_nVersao, "NGIND013")
	
	// Vari�veis da Janela
	Local oDlgSelect, lDlgSelect := .F.
	Local cDlgSelect := OemToAnsi(STR0006) //"Selecione os Indicadores"
	Local oPnlSelect
	
	Local oPnlMenu
	Local oPnlBrw
	
	Local oTmpPnl, oTmpBtn
	
	Local aColors  := aClone( NGCOLOR() )
	Local nClrText := aColors[1]
	Local nClrBack := aColors[2]
	
	// Vari�veis do Browse
	Local aSelect := aClone( NGI8SlcCha() )
	Local aColunas := {}, oColuna
	Local aHeader := {}, aFolder := {}
	Local lMark := .F., aMark := {}
	Local nX := 0, nY := 0, nScan := 0
	
	Local cArrTitulo := ""
	Local cArrTipo   := ""
	Local nArrTamanh := 0
	Local nArrDecima := 0
	Local cArrPictur := ""
	Local cSetData   := ""
	
	// Vari�veis PRIVATE do Browse
	Private oFolder
	Private aFWBrowse
	Private aClassific := aClone( aSelect[2] )
	
	// Cursor em Espera
	CursorWait()
	
	//--------------------
	// Monta a Janela
	//--------------------
	oBlackPnl:Show() // Mostra o Painel
	
	lDlgSelect := .F.
	DEFINE MSDIALOG oDlgSelect TITLE cDlgSelect FROM 0,0 TO 400,700 OF oMainWnd PIXEL
		
		// Painel principal do Dialog
		oPnlSelect := TPanel():New(01, 01, , oDlgSelect, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlSelect:Align := CONTROL_ALIGN_ALLCLIENT
			
			// Folder
			aSort(aClassific, , , {|x,y| x[1] < y[1] })
			aFolder := {}
			For nX := 1 To Len(aClassific)
				aAdd(aFolder, AllTrim(aClassific[nX][2]))
				aSort(aClassific[nX][3], , , {|x,y| x[1] < y[1] })
				For nY := 1 To Len(aClassific[nX][3])
					aClassific[nX][3][nY][6] := ( aScan(aIndicadores, {|x| AllTrim(x[1]) == AllTrim(aClassific[nX][3][nY][1]) }) > 0 )
				Next nY
			Next nX
			oFolder := TFolder():New(01, 01, aFolder, aFolder, oPnlSelect, 1, CLR_BLACK, CLR_WHITE, .T., , 100, 100)
			oFolder:Align := CONTROL_ALIGN_ALLCLIENT
			
			aFWBrowse := Array(Len(oFolder:aDialogs))
			For nX := 1 To Len(oFolder:aDialogs)
				// Painel do Menu Lateral
				oPnlMenu := TPanel():New(01, 01, , oFolder:aDialogs[nX], , , , nClrText, nClrBack, 012, 100, .F., .F.)
				oPnlMenu:Align := CONTROL_ALIGN_LEFT
					
					// Painel auxiliar para dar um espa�o
					oTmpPnl := TPanel():New(01, 01, , oPnlMenu, , , , nClrText, nClrBack, 100, 012)
					oTmpPnl:Align := CONTROL_ALIGN_TOP
					
					// Bot�o: Visualizar
					oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , &("{|| NGI8SlcViw(aFWBrowse[" + cValToChar(nX) + "], aClassific[" + cValToChar(nX) + "]) }"), oPnlMenu, OemToAnsi(STR0007), , .T.) //"Visualizar"
					oTmpBtn:Align := CONTROL_ALIGN_TOP
				
				// Painel do Browse
				oPnlBrw := TPanel():New(01, 01, , oFolder:aDialogs[nX], , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
				oPnlBrw:Align := CONTROL_ALIGN_ALLCLIENT
					
					//--------------------
					// Browse de Marca��o
					//--------------------
					aFWBrowse[nX] := FWBrowse():New()
					aFWBrowse[nX]:SetOwner(oPnlBrw)
					aFWBrowse[nX]:SetDataArray()
					
					aFWBrowse[nX]:SetLocate()
					aFWBrowse[nX]:SetDelete(.F., {|| .F.})
					
					// Colunas
					aFWBrowse[nX]:AddMarkColumns(&("{|| StaticCall(TNGPanel, fSlcBrwMrk, "+cValToChar(nX)+") }"), ;
													&("{|oBrowse| StaticCall(TNGPanel, fSlcBrwClk, "+cValToChar(nX)+") }"), ;
													&("{|oBrowse| StaticCall(TNGPanel, fSlcBrwClk, "+cValToChar(nX)+", .T.) }") )
					aFWBrowse[nX]:SetDoubleClick(&("{|| StaticCall(TNGPanel, fSlcBrwClk, "+cValToChar(nX)+") }"))
					
					aColunas := {}
					aHeader := aClone( aSelect[1] )
					For nY := 1 To Len(aHeader)
						cArrTitulo := aHeader[nY][1]
						cArrTipo   := aHeader[nY][2]
						nArrTamanh := aHeader[nY][3]
						nArrDecima := aHeader[nY][4]
						cArrPictur := aHeader[nY][5]
						
						oColuna := FWBrwColumn():New()
						oColuna:SetAlign( If(cArrTipo == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT) )
						
						cSetData := "{|| aClassific[" + cValToChar(nX) + "][3][aFWBrowse[" + cValToChar(nX) + "]:AT()][" + cValToChar(nY) + "] }"
						oColuna:SetData( &(cSetData) )
						
						oColuna:SetEdit( .F. )
						oColuna:SetSize( nArrTamanh + nArrDecima )
						oColuna:SetTitle( cArrTitulo )
						oColuna:SetType( cArrTipo )
						oColuna:SetPicture( cArrPictur )
						
						aAdd(aColunas, oColuna)
					Next nY
					aFWBrowse[nX]:SetColumns(aColunas)
					aFWBrowse[nX]:Activate()
					aFWBrowse[nX]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
					aFWBrowse[nX]:SetArray(aClassific[nX][3])
					aFWBrowse[nX]:Refresh()
			Next nX
		
		// Cursor Normal
		CursorArrow()
		
	ACTIVATE MSDIALOG oDlgSelect ON INIT EnchoiceBar(oDlgSelect, {|| lDlgSelect := .T., fSlcDefInds(), oDlgSelect:End() }, {|| lDlgSelect := .F., oDlgSelect:End() }) CENTERED
	
	// Se confirmou
	If lDlgSelect
		fCriaGrafico()
	EndIf
	
	oBlackPnl:Hide() // Esconde o Painel
	
	// Devolve conte�do anterior
	NGRETURNPRM(aNGBEGINPRM)
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSlcBrwMrk
Carrega a marca��o do browse.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@param nClass
	Indica o n�mero identificador da Classifica��o * Obrigat�rio

@return cRetMarca
/*/
//---------------------------------------------------------------------
Static Function fSlcBrwMrk(nClass)
	
	// Vari�veis de controle
	Local cComMarca := "LBOK"
	Local cSemMarca := "LBNO"
	Local cRetMarca := ""
	
	Local nATBrw := aFWBrowse[nClass]:AT()
	
	// Define a Marca
	cRetMarca := If(aClassific[nClass][3][nATBrw][6], cComMarca, cSemMarca)
	
Return cRetMarca

//---------------------------------------------------------------------
/*/{Protheus.doc} fSlcBrwClk
Executa o clique sobre a Marca��o.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@param nClass
	Indica o n�mero identificador da Classifica��o * Obrigat�rio
@param lHeadClick
	Indica se a a��o do clique � a do clique no Header * Opcional
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSlcBrwClk(nClass, lHeadClick)
	
	// Vari�veis de controle
	Local nATBrw := aFWBrowse[nClass]:AT()
	
	Local lMarca := .F.
	Local nScan := 0, nX := 0
	
	If !lHeadClick
		// Inverte a defini��o de marca��o
		aClassific[nClass][3][nATBrw][6] := !aClassific[nClass][3][nATBrw][6]
	Else
		nScan := aScan(aClassific[nClass][3], {|x| !x[6] })
		If nScan > 0
			lMarca := .T.
		EndIf
		
		// Atribui a defini��o de marca��o
		For nX := 1 To Len(aClassific[nClass][3])
			aClassific[nClass][3][nX][6] := lMarca
		Next nX
	EndIf
	
	// Atualiza o Browse
	If lHeadClick
		aFWBrowse[nClass]:GoTop()
		aFWBrowse[nClass]:Refresh()
	EndIf
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSlcBrwClk
Executa o clique sobre a Marca��o.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@param nClass
	Indica o n�mero identificador da Classifica��o * Obrigat�rio
@param lHeadClick
	Indica se a a��o do clique � a do clique no Header * Opcional
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSlcDefInds()
	
	// Vari�veis auxiliares
	Local cQryAlias := GetNextAlias()
	Local cQryDados := ""
	Local cQryInds  := ""
	Local uConteudo := Nil
	Local nX := 0, nY := 0
	Local nPar := 0
	
	//----------
	// Executa
	//----------
	//-- Indicadores
	aIndicadores := {}
	For nX := 1 To Len(aClassific)
		For nY := 1 To Len(aClassific[nX][3])
			If aClassific[nX][3][nY][6]
				// 1                   ; 2         ; 3
				// C�digo do Indicador ; Descri��o ; Selecionado?
				aAdd(aIndicadores, {aClassific[nX][3][nY][1], aClassific[nX][3][nY][2], .T.})
				cQryInds += If(!Empty(cQryInds), ",", "") + "'" + aClassific[nX][3][nY][1] + "'"
			EndIf
		Next nY
	Next nX
	
	//-- Par�metros
	aParametros := {}
	// SELECT
	cQryDados := "SELECT "
	cQryDados += " TZG.*
	// FROM "TZG"
	cQryDados += "FROM " + RetSQLName("TZG") + " TZG "
	// INNER JOIN "TZE"
	cQryDados += "INNER JOIN " + RetSQLName("TZE") + " TZE ON "  
	cQryDados += " ( "
	cQryDados += "  TZE.TZE_FILIAL = TZG.TZG_FILIAL "
	cQryDados += "  AND TZE.TZE_CODIGO = TZG.TZG_CODIGO "
	cQryDados += "  AND TZE.TZE_MODULO = " + ValToSQL(Str(nModulo,2)) + " "
	If !Empty(cQryInds)
		cQryDados += "  AND TZE.TZE_INDIC IN (" + cQryInds + ") "
	EndIf
	cQryDados += "  AND TZE.D_E_L_E_T_ <> '*' "
	cQryDados += " ) "
	// WHERE
	cQryDados += "WHERE "
	cQryDados += " TZG.TZG_FILIAL = " + ValToSQL(xFilial("TZG")) + " "
	cQryDados += " AND TZG.TZG_PARAM NOT LIKE '%_DATA%' "
	cQryDados += " AND TZG.D_E_L_E_T_ <> '*' "
	// ORDER BY
	cQryDados += "ORDER BY "
	cQryDados += " TZG.TZG_VARIAV, "
	cQryDados += " TZG.TZG_ORDEM, "
	cQryDados += " TZG.TZG_PARAM, "
	cQryDados += " TZG.TZG_CONTEU "
	// Verifica sintaxe da query
	cQryDados := ChangeQuery(cQryDados)
	// Executa
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryDados), cQryAlias, .F., .T.)
	dbSelectArea(cQryAlias)
	dbGoTop()
	While !Eof()
		nPar := aScan(aParametros, {|x| AllTrim(x[1]) == AllTrim((cQryAlias)->TZG_PARAM) })
		If nPar == 0
			// 1                   ; 2         ; 3            ; 4       ; 5           ; 6            ; 7                 ; 8
			// C�digo do Par�metro ; Descri��o ; Tipo de Dado ; Picture ; {Conte�dos} ; Selecionado? ; Conte�do Definido ; Op��es (ComboBox)
			aAdd(aParametros, {(cQryAlias)->TZG_PARAM, AllTrim((cQryAlias)->TZG_AUXTIT), (cQryAlias)->TZG_TIPDAD, AllTrim((cQryAlias)->TZG_AUXPIC), {}, .F., " ", AllTrim((cQryAlias)->TZG_AUXOPC)})
			nPar := Len(aParametros)
		EndIf
		uConteudo := NGI6CONVER(AllTrim((cQryAlias)->TZG_CONTEU), (cQryAlias)->TZG_TIPDAD, , , .T.)
		uConteudo := NGI6CONVER(uConteudo, "C", , , .T.)
		If aScan(aParametros[nPar][5], {|x| AllTrim(x) == uConteudo }) == 0
			aAdd(aParametros[nPar][5], uConteudo)
		EndIf
		dbSelectArea(cQryAlias)
		dbSkip()
	End
	(cQryAlias)->( dbCloseArea() )
	
Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: CONFIGURA��ES                                                                 ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fConfig
Configura��es para o Gr�fico Evolutivo.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fConfig()
	
	// Armazena conte�do anterior
	Local aNGBEGINPRM := NGBEGINPRM(_nVersao, "NGIND013")
	
	// Vari�veis da Janela
	Local oDlgConfig, lDlgConfig := .F.
	Local cDlgConfig := OemToAnsi(STR0008) //"Configura��o do Gr�fico"
	Local oPnlConfig
	
	Local oFntNorm := TFont():New(,,16,,.F.)
	Local oFntBold := TFont():New(,,16,,.T.)
	
	Local oPnlPeriod
	Local oFolder, aFolder := {STR0009, STR0010} //"Configura��es B�sicas" ## "Par�metros"
	Local oPnlBasics
	Local oPnlParams
	Local oCabec, oAll
	
	Local nClrCabec := RGB(245,245,245)
	
	// Vari�veis auxiliares
	Local nPar
	Local nLin, nCol
	Local lSelected
	Local aCombo := {}
	
	Local bChkSetGet
	Local bChkLClick
	
	Local bSayTitle
	
	Local bGetSetGet
	Local bGetPicture
	
	Local bBtnAction
	
	// Vari�veis PRIVATE necess�rias
	Private aObjsPars := {}
	
	// Cursor em Espera
	CursorWait()
	
	//--------------------
	// Monta a Janela
	//--------------------
	oBlackPnl:Show() // Mostra o Painel
	
	lDlgConfig := .F.
	DEFINE MSDIALOG oDlgConfig TITLE cDlgConfig FROM 0,0 TO 450,450 OF oMainWnd PIXEL
		
		// Painel principal do Dialog
		oPnlConfig := TPanel():New(01, 01, , oDlgConfig, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlConfig:Align := CONTROL_ALIGN_ALLCLIENT
			
			//------------------------------
			// Configura��es de Per�odo
			//------------------------------
			oPnlPeriod := TPanel():New(01, 01, , oPnlConfig, , , , CLR_BLACK, CLR_WHITE, 100, 030, .F., .F.)
			oPnlPeriod:Align := CONTROL_ALIGN_TOP
				
				// Cabe�alho
				oCabec := TPanel():New(01, 01, , oPnlPeriod, , , , CLR_BLACK, nClrCabec, 100, 012, .F., .F.)
				oCabec:Align := CONTROL_ALIGN_TOP
					@ 002,005 SAY OemToAnsi(STR0011) FONT oFntBold OF oCabec PIXEL //"Per�odo"
				// TODO
				oAll := TPanel():New(01, 01, , oPnlPeriod, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
				oAll:Align := CONTROL_ALIGN_ALLCLIENT
					@ 005,010 SAY OemToAnsi(STR0012+":") FONT oFntNorm OF oAll PIXEL //"De"
					@ 004,030 MSGET dDeData PICTURE "99/99/99" SIZE 050,008 VALID fCfgVldDt(1) OF oAll PIXEL HASBUTTON
					@ 005,090 SAY OemToAnsi(STR0013+":") FONT oFntNorm OF oAll PIXEL //"At�"
					@ 004,110 MSGET dAteData PICTURE "99/99/99" SIZE 050,008 VALID fCfgVldDt(2) OF oAll PIXEL HASBUTTON
			
			//------------------------------
			// Folder
			//------------------------------
			oFolder := TFolder():New(01, 01, aFolder, aFolder, oPnlConfig, 1, CLR_BLACK, CLR_WHITE, .T., , 100, 100)
			oFolder:Align := CONTROL_ALIGN_ALLCLIENT
				
				//------------------------------
				// Configura��es B�sicas
				//------------------------------
				oPnlBasics := TPanel():New(01, 01, , oFolder:aDialogs[1], , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
				oPnlBasics:Align := CONTROL_ALIGN_ALLCLIENT
					
					// Cabe�alho
					oCabec := TPanel():New(01, 01, , oPnlBasics, , , , CLR_BLACK, nClrCabec, 100, 012, .F., .F.)
					oCabec:Align := CONTROL_ALIGN_TOP
						@ 002,005 SAY OemToAnsi(STR0009) FONT oFntBold OF oCabec PIXEL //"Configura��es B�sicas"
					
					// TODO
					oAll := TScrollBox():New(oPnlBasics, 0, 0, 0, 0, .T., .T., .T.)
					oAll:Align := CONTROL_ALIGN_ALLCLIENT
					oAll:CoorsUpdate()
						
						// Tipo de Gr�fico
						@ 010,010 SAY OemToAnsi(STR0014) OF oAll PIXEL //"Tipo de Gr�fico"
						aCombo := {"1="+STR0015, "2="+STR0016, "3="+STR0017, "4="+STR0018} //"Linha" ## "Ponto" ## "�rea" ## "Barra"
						TComboBox():New(008, 080, {|u| If(PCount() > 0, cTipGraf := u, cTipGraf) }, aCombo, 040, 008, oAll, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .T. }/*bWhen*/)
						
						// Gr�fico em 3D
						@ 025,010 SAY OemToAnsi(STR0028) OF oAll PIXEL //"Gr�fico em 3D?"
						aCombo := {"1="+STR0019, "2="+STR0020} //"Sim" ## "N�o"
						TComboBox():New(023, 080, {|u| If(PCount() > 0, cGraf3D := u, cGraf3D) }, aCombo, 040, 008, oAll, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .T. }/*bWhen*/)
						
						// Tipo de Agrupamento
						@ 040,010 SAY OemToAnsi(STR0029) OF oAll PIXEL //"Tipo de Agrupamento:"
						aCombo := {"1="+STR0021, "2="+STR0022, "3="+STR0023, "4="+STR0024, "5="+STR0025, "6="+STR0026, "7="+STR0027} //"N�o Agrupar" ## "Di�rio" ## "Semanal" ## "Mensal" ## "Trimestral" ## "Semestral" ## "Anual"
						TComboBox():New(038, 080, {|u| If(PCount() > 0, cAgrupa := u, cAgrupa) }, aCombo, 060, 008, oAll, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .T. }/*bWhen*/)
				
				//------------------------------
				// Par�metros
				//------------------------------
				// Par�metros
				oPnlParams := TPanel():New(01, 01, , oFolder:aDialogs[2], , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
				oPnlParams:Align := CONTROL_ALIGN_ALLCLIENT
					
					// Cabe�alho
					oCabec := TPanel():New(01, 01, , oPnlParams, , , , CLR_BLACK, nClrCabec, 100, 012, .F., .F.)
					oCabec:Align := CONTROL_ALIGN_TOP
						@ 002,005 SAY OemToAnsi(STR0010) FONT oFntBold OF oCabec PIXEL //"Par�metros"
					
					// TODO
					oAll := TScrollBox():New(oPnlParams, 0, 0, 0, 0, .T., .T., .T.)
					oAll:Align := CONTROL_ALIGN_ALLCLIENT
					oAll:CoorsUpdate()
						
						nLin := 010
						nCol := 010
						aObjsPars := Array(Len(aParametros))
						For nPar := 1 To Len(aParametros)
							aObjsPars[nPar] := Array(3)
							
							// CheckBox
							lSelected := aParametros[nPar][6]
							bChkSetGet := "{|| aParametros[" + cValToChar(nPar) + "][6] }"
							bChkLClick := "{|| aParametros[" + cValToChar(nPar) + "][6] := !aParametros[" + cValToChar(nPar) + "][6], fCfgParSlc(" + cValToChar(nPar) + ") }"
							aObjsPars[nPar][1] := TCheckBox():New(nLin, nCol, "", &(bChkSetGet), oAll, 010, 008, , ;
													&(bChkLClick), , , , , , .T., , , )
							// Say
							bSayTitle := "{|| OemToAnsi('" + aParametros[nPar][2] + "') }"
							aObjsPars[nPar][2] := TSay():New(nLin, nCol+010, &(bSayTitle), oAll, , , , , , .T., ;
													If(lSelected,CLR_BLACK,CLR_GRAY), CLR_WHITE, 100, 008)
							aObjsPars[nPar][2]:bLClicked := &(bChkLClick)
							// Get
							bGetSetGet := "{|| fCfgParGet(" + cValToChar(nPar) + ") }"
							bGetPicture := "'" + aParametros[nPar][4] + "'"
							bBtnAction := "{|| fCfgParF3(" + cValToChar(nPar) + ") }"
							aObjsPars[nPar][3] := TGet():New(nLin, nCol+100, &(bGetSetGet), oAll, 080, 008, Nil/*&(bGetPicture)*/, {|| .T. }, If(lSelected,CLR_BLACK,CLR_GRAY), CLR_WHITE, ,;
													.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .T./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)
							aObjsPars[nPar][3]:bHelp := {|| Nil }
							aObjsPars[nPar][3]:bF3 := &(bBtnAction) // A��o do F3 do Get
							If !lSelected
								aObjsPars[nPar][3]:Disable()
							EndIf
							
							// Incrementa a Linha
							nLin += 015
						Next nPar
		
		// Cursor Normal
		CursorArrow()
		
	ACTIVATE MSDIALOG oDlgConfig ON INIT EnchoiceBar(oDlgConfig, {|| lDlgConfig := .T., oDlgConfig:End() }, {|| lDlgConfig := .F., oDlgConfig:End() }) CENTERED
	
	// Se confirmou
	If lDlgConfig
		fCriaGrafico()
	EndIf
	
	oBlackPnl:Hide() // Esconde o Painel
	
	// Devolve conte�do anterior
	NGRETURNPRM(aNGBEGINPRM)
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCfgVldDt
Valida o Per�odo.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@param nData
	Indica qual o par�metro a validar * Obrigat�rio
		1 - De Data
		2 - At� Data
		3 - Ambas

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCfgVldDt(nData)
	
	//----------
	// Valida
	//----------
	If nData == 1 .And. !Empty(dDeData)
		// comando...
	ElseIf nData == 2 .And. !Empty(dAteData)
		// comando...
	ElseIf nData == 3 .And. !Empty(dDeData) .And. !Empty(dAteData)
		If dAteData < dDeData
			Help(Nil, Nil, STR0030, Nil, STR0031, 1, 0) //"Aten��o" ## "A Data Final deve ser igual ou superior a Inicial."
			Return .F.
		EndIf
	EndIf
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCfgParSlc
Seleciona ou Deseleciona um par�metro.

@author Wagner Sobral de Lacerda
@since 03/01/2013

@param nSelectPar
	Indica qual o par�metro selecionado * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCfgParSlc(nSelectPar)
	
	// Vari�veis auxiliares
	Local lSelected := aParametros[nSelectPar][6]
	
	//-- Executa
	aObjsPars[nSelectPar][2]:SetColor(If(lSelected,CLR_BLACK,CLR_GRAY), )
	aObjsPars[nSelectPar][3]:SetColor(If(lSelected,CLR_BLACK,CLR_GRAY), )
	If lSelected
		aObjsPars[nSelectPar][3]:Enable()
	Else
		aObjsPars[nSelectPar][3]:Disable()
	EndIf
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCfgParGet
Define o conte�do do par�metro.

@author Wagner Sobral de Lacerda
@since 03/01/2013

@param nSelectPar
	Indica qual o par�metro selecionado * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCfgParGet(nSelectPar)
Return aParametros[nSelectPar][7]

//---------------------------------------------------------------------
/*/{Protheus.doc} fCfgParF3
Seleciona um conte�do do par�metro.

@author Wagner Sobral de Lacerda
@since 03/01/2013

@param nSelectPar
	Indica qual o par�metro selecionado * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCfgParF3(nSelectPar)
	
	// Armazena conte�do anterior
	Local aNGBEGINPRM := NGBEGINPRM(_nVersao, "NGIND013")
	
	// Vari�veis da Janela
	Local oDlgF3
	Local cDlgF3 := OemToAnsi(STR0032 + " - " + AllTrim(aParametros[nSelectPar][2])) //"Consulta de Conte�do"
	Local lDlgF3 := .F.
	Local oPnlF3
	
	// Vari�veis do Browse
	Local oBrwF3
	Local aHeader := {}, aCols := {}
	Local aColunas := {}, oColuna
	Local nHeader := 0, nCols := 0
	Local nRowSelected := 0
	
	Local cArrTitulo := ""
	Local cArrTipo   := ""
	Local nArrTamanh := ""
	Local nArrDecima := ""
	Local cArrPictur := ""
	
	Local lComboBox := !Empty(aParametros[nSelectPar][8])
	
	//-- Monta 'aHeader'
	aAdd(aHeader, {STR0033, "C", If(!lComboBox,50,15), 0, ""}) //"Conte�do"
	If lComboBox
		aAdd(aHeader, {STR0034, "C", 40, 0, ""}) //"Op��es"
	EndIf
	
	//-- Monta 'aCols'
	For nCols := 1 To Len(aParametros[nSelectPar][5])
		aAdd(aCols, {aParametros[nSelectPar][5][nCols], aParametros[nSelectPar][8]})
	Next nCols
	
	//--------------------
	// Monta a Janela
	//--------------------
	DEFINE MSDIALOG oDlgF3 TITLE cDlgF3 FROM 0,0 TO 350,600 OF oMainWnd PIXEL
		oBrwF3 := FWBrowse():New()
		oBrwF3:SetOwner(oDlgF3)
		oBrwF3:SetDataArray()
		
		oBrwF3:SetLocate()
		oBrwF3:SetDelete(.F., {|| .F.})
		
		// Colunas
		For nHeader := 1 To Len(aHeader)
			cArrTitulo := aHeader[nHeader][1]
			cArrTipo   := aHeader[nHeader][2]
			nArrTamanh := aHeader[nHeader][3]
			nArrDecima := aHeader[nHeader][4]
			cArrPictur := aHeader[nHeader][5]
			
			oColuna := FWBrwColumn():New()
			oColuna:SetAlign( If(cArrTipo == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT) )
			
			cSetData := "{|oFWBrowse| oFWBrowse:Data():GetArray()[oFWBrowse:AT()][" + cValToChar(nHeader) + "] }"
			oColuna:SetData( &(cSetData) )
			
			oColuna:SetEdit( .F. )
			oColuna:SetSize( nArrTamanh + nArrDecima )
			oColuna:SetTitle( cArrTitulo )
			oColuna:SetType( cArrTipo )
			oColuna:SetPicture( cArrPictur )
			
			aAdd(aColunas, oColuna)
		Next nHeader
		oBrwF3:SetColumns(aColunas)
		oBrwF3:Activate()
		oBrwF3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwF3:SetArray(aCols)
		oBrwF3:SetDoubleClick({|| lDlgF3 := .T., nRowSelected := oBrwF3:AT(), oDlgF3:End() })
		oBrwF3:Refresh()
	ACTIVATE MSDIALOG oDlgF3 ON INIT EnchoiceBar(oDlgF3, {|| lDlgF3 := .T., nRowSelected := oBrwF3:AT(), oDlgF3:End() }, {|| lDlgF3 := .F., oDlgF3:End() }) CENTERED
	
	If lDlgF3 .And. nRowSelected > 0
		aParametros[nSelectPar][7] := aCols[nRowSelected][1]
		aObjsPars[nSelectPar][3]:CtrlRefresh()
		aObjsPars[nSelectPar][3]:SetFocus()
	EndIf
	
	// Devolve conte�do anterior
	NGRETURNPRM(aNGBEGINPRM)
	
Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: MONTA OS INDICADORES SELECIONADOS                                             ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fIndsDisp
Indicadores Dipon�veis para apresentar no gr�fico.

@author Wagner Sobral de Lacerda
@since 03/01/2013

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fIndsDisp()
	
	// Armazena conte�do anterior
	Local aNGBEGINPRM := NGBEGINPRM(_nVersao, "NGIND013")
	
	// Vari�veis da Janela
	Local oDlgInds
	Local cDlgInds := OemToAnsi(STR0004) //"Indicadores Dispon�veis"
	
	// Vari�veis do Container
	Local oScroll
	Local oContainer
	Local oBordTop, oBordLef, oBordRig, oBordBot
	
	// Vari�veis auxiliares
	Local nIndic := 0
	
	//--------------------
	// Monta a Janela
	//--------------------
	DEFINE MSDIALOG oDlgInds TITLE cDlgInds FROM 0,0 TO 400,450 OF oMainWnd PIXEL
		
		oDlgInds:lEscClose := .T.
		
		//-- Monta Indicadores que podem ser apresentados no gr�fico
		oScroll := TScrollBox():New(oDlgInds, 0, 0, 0, 0, .T., .F., .T.)
		oScroll:Align := CONTROL_ALIGN_ALLCLIENT
		oScroll:CoorsUpdate()
			If Len(aBtnIndics) > 0
				aEval(aBtnIndics, {|x| If(ValType(x) == "O", MsFreeObj(x), ) })
			EndIf
			aBtnIndics := Array(Len(aIndicadores))
			For nIndic := 1 To Len(aIndicadores)
				// Container
				oContainer := TPanel():New(01, 01, , oScroll, , , , CLR_BLACK, CLR_WHITE, 100, 020, .F., .F.)
				oContainer:Align := CONTROL_ALIGN_TOP
					// Bordas
					oBordTop := TPanel():New(01, 01, , oContainer, , , , CLR_BLACK, CLR_WHITE, 001, 001, .F., .F.)
					oBordTop:Align := CONTROL_ALIGN_TOP
					oBordLef := TPanel():New(01, 01, , oContainer, , , , CLR_BLACK, CLR_WHITE, 001, 001, .F., .F.)
					oBordLef:Align := CONTROL_ALIGN_LEFT
					oBordRig := TPanel():New(01, 01, , oContainer, , , , CLR_BLACK, CLR_WHITE, 001, 001, .F., .F.)
					oBordRig:Align := CONTROL_ALIGN_RIGHT
					oBordBot := TPanel():New(01, 01, , oContainer, , , , CLR_BLACK, CLR_WHITE, 001, 001, .F., .F.)
					oBordBot:Align := CONTROL_ALIGN_BOTTOM
					
					// Bot�o
					aBtnIndics[nIndic] := TButton():New(001, 001, AllTrim(aIndicadores[nIndic][2]) + " [" + AllTrim(aIndicadores[nIndic][1]) + "]", oContainer, ;
									&("{|| fChangeInd(" + cValToChar(nIndic) + ") }"), 012, 012, , , .F., .T., .F., , .F., , , .F.)
					aBtnIndics[nIndic]:lCanGotFocus := .F.
					aBtnIndics[nIndic]:Align := CONTROL_ALIGN_ALLCLIENT
					// CSS do Bot�o
					fBtnIndCSS(If(aIndicadores[nIndic][3],1,0), aBtnIndics[nIndic])
			Next nIndic
		
	ACTIVATE MSDIALOG oDlgInds CENTERED
	
	// Devolve conte�do anterior
	NGRETURNPRM(aNGBEGINPRM)
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeInd
Executa a Sele��o do Indicador para o Gr�fico.

@author Wagner Sobral de Lacerda
@since 03/01/2013

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fChangeInd(nSelectInd)
	
	// Inverte Sele��o
	aIndicadores[nSelectInd][3] := !aIndicadores[nSelectInd][3]
	// Atualiza CSS do Bot�o
	fBtnIndCSS(If(aIndicadores[nSelectInd][3],1,0), aBtnIndics[nSelectInd])
	// Atualiza o Gr�fico
	fCriaGrafico()
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBtnIndCSS
Define o CSS dos bot�es de Indicadores.

@author Wagner Sobral de Lacerda
@since 03/01/2013

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBtnIndCSS(nEstilo, oObjBtn)
	
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
	cFontAlign  := "padding-left: 2px; text-align: left; "
	cBordRadius := "0"
	
	//-- Gradiente padr�o
	cUsaGrad1 := "#FAFAFA" // Cinza Claro -  Personalizado (RGB: 250,250,250)
	cUsaGrad2 := "#FDFDFD" // Cinza Claro -  Personalizado (RGB: 253,253,253)
	cUsaGrad3 := "#FDFDFD" // Cinza Claro -  Personalizado (RGB: 253,253,253)
	
	//----------------------------------------
	// Define as cores a serem utilizadas
	//----------------------------------------
	If nEstilo == 0
		
		//----------------------------------------
		// Bot�o em Espera
		//----------------------------------------
		
		cUsaBack1 := "#FFFFFF" // Branco
		cUsaBack2 := "#FAFAFA" // Cinza Claro
		cUsaBack3 := "#FAFAFA" // Cinza Claro
		
		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3
		
		cUsaFore1 := "#CCCCCC" // Cinza
		cUsaFore2 := "#808080" // Cinza
		cUsaFore3 := "#808080" // Cinza
		
		cUsaBord1 := cUsaBack1
		cUsaBord2 := "#D3D3D3" // Cinza Claro
		cUsaBord3 := "#808080" // Cinza
		
	ElseIf nEstilo == 1
		
		//----------------------------------------
		// Bot�o Selecionado
		//----------------------------------------
		
		cUsaBack1 := "#FFFFFF" // Cinza Claro
		cUsaBack2 := "#FAFAFA" // Cinza Claro
		cUsaBack3 := "#FAFAFA" // Cinza Claro
		
		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3
		
		cUsaFore1 := "#000000" // Preto
		cUsaFore2 := "#000000" // Preto
		cUsaFore3 := "#000000" // Preto
		
		cUsaBord1 := cUsaBack1
		cUsaBord2 := "#D3D3D3" // Cinza Claro
		cUsaBord3 := "#808080" // Cinza
		
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

/*/
############################################################################################
##                                                                                        ##
## FUN��ES: MONTA O GR�FICO                                                               ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaGrafico
Cria o Gr�fico.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@return lRetorno
/*/
//---------------------------------------------------------------------
Static Function fCriaGrafico()
	
	// Vari�vel do Retorno
	Local lRetorno := .T.
	
	// Vari�veis para o Objeto do Gr�fico
	Local cPeriodo := ""
	Local nSerie := 0, nTipoGraf := 0
	Local aClrSeries := {	RGB(70,130,180) , ; // SteelBlue
							RGB(34,139,34)  , ; // ForestGreen
							RGB(255,165,0)  , ; // Orange
							RGB(160,32,240) , ; // Purple
							RGB(255,255,0)  , ; // Yellow
							RGB(255,0,0)    , ; // Red
							RGB(112,128,144), ; // SlateGrey
							RGB(210,105,30) , ; // Chocolate
							RGB(230,230,250), ; // Lavender
							RGB(255,250,205)  ; // LemonChiffon
							}
	
	Local cTitle := ""
	Local aValue := {}
	Local nX, nY
	Local nScan := 0
	
	//-- Processa Resultados
	If !IsInCallStack("fIndsDisp")
		MsgRun(STR0035, STR0036, {|| fProcessa() }) //"Montando o Gr�fico..." ## "Por favor, aguarde...",
	EndIf
	
	//-- Define o Per�odo para o t�tulo do gr�fico
	If Empty(dDeData) .And. Empty(dAteData)
		cPeriodo := STR0037 //"Completo"
	ElseIf !Empty(dDeData) .And. Empty(dAteData)
		cPeriodo := STR0038 + " " + DTOC(dDeData) //"A partir de"
	ElseIf Empty(dDeData) .And. !Empty(dAteData)
		cPeriodo := STR0013 + " " + DTOC(dAteData) //"At�"
	ElseIf !Empty(dDeData) .And. !Empty(dAteData)
		cPeriodo := STR0012 + " " + DTOC(dDeData) + " " + STR0013 + " " + DTOC(dAteData) //"De" ## "At�"
	EndIf
	cPeriodo := STR0011 + ": " + cPeriodo //"Per�odo"
	
	//-- Define o Tipo do Gr�fico
	Do Case
		Case cTipGraf == "1"
			nTipoGraf := GRP_LINE
		Case cTipGraf == "2"
			nTipoGraf := GRP_POINT
		Case cTipGraf == "3"
			nTipoGraf := GRP_AREA
		Case cTipGraf == "4"
			nTipoGraf := GRP_BAR
		Otherwise
			nTipoGraf := GRP_LINE
	EndCase
	
	//--------------------
	// Monta o Gr�fico
	//--------------------
	//Caso o objeto j� exista destroi para atualizar. 
	If ValType(oGrafico) == "O"
		FreeObj(oGrafico)
	EndIf
	// Cria o Objeto
	oGrafico := TMSGraphic():New(0, 0, oPnlGraph, , , , 1000, 1000)
	oGrafico:SetTitle(cPeriodo, "", CLR_GRAY, A_CENTER, .F.)
	oGrafico:Align := CONTROL_ALIGN_ALLCLIENT
	
	// Deleta S�ries j� existentes
	For nX := 1 To Len(aSeries)
		oGrafico:DelSerie(aSeries[nX])
	Next nX
	aSeries := {}
	// Valida as S�ries
	If !fVldSeries()
		lRetorno := .F.
	EndIf
	// Cria as S�ries
	If lRetorno
		For nX := 1 To Len(aResults)
			nScan := aScan(aIndicadores, {|x| AllTrim(x[1]) == AllTrim(aResults[nX][1]) })
			If nScan > 0 .And. aIndicadores[nScan][3]
				nSerie := oGrafico:CreateSerie(nTipoGraf, AllTrim(aResults[nX][1]), 2)
				aAdd(aSeries, nSerie)
				For nY := 1 To Len(aResults[nX][2])
					oGrafico:Add(nSerie, aResults[nX][2][nY][2], aResults[nX][2][nY][1], If(Len(aSeries) <= Len(aClrSeries), aClrSeries[Len(aSeries)], CLR_HGRAY))
				Next nY
			EndIf
		Next nX
	EndIf
	//--------------------
	// Configura��es
	//--------------------
	// 3D
	oGrafico:l3D := ( cGraf3D == "1" ) // Sim?
	
Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldSeries
Valida se pode montar a Series do Gr�fico.

@author Wagner Sobral de Lacerda
@since 07/01/2013

@return lRetorno
/*/
//---------------------------------------------------------------------
Static Function fVldSeries()
	
	// Vari�vel do Retorno
	Local lRetorno := .T.
	
	// Vari�veis auxiliares
	Local aCompara := {}
	Local nX := 0, nY := 0
	Local nScan := 0
	
	//----------
	// Valida
	//----------
	For nX := 1 To Len(aResults)
		nScan := aScan(aIndicadores, {|x| AllTrim(x[1]) == AllTrim(aResults[nX][1]) })
		If nScan > 0 .And. aIndicadores[nScan][3]
			If Len(aCompara) == 0
				aEval(aResults[nX][2], {|x| aAdd(aCompara, x[1]) })
			Else
				If Len(aCompara) <> Len(aResults[nX][2])
					lRetorno := .F.
				Else
					For nY := 1 To Len(aResults[nX][2])
						If aCompara[nY] <> aResults[nX][2][nY][1]
							lRetorno := .F.
						EndIf
					Next nY
				EndIf
			EndIf
		EndIf
	Next nX
	
	// Mensagem
	If !lRetorno
		If !IsInCallStack("fIndsDisp")
			ShowHelpDlg(STR0030, ; //"Aten��o"
				{STR0039}, 2, ; //"Os Indicadores selecionados para o gr�fico apresentam diverg�ncia Cronol�gica de Hist�rico, e por isto n�o podem ser mesclados para uma mesma vis�o."
				{STR0040}, 2) //"Por favor, selecione apenas 1 (um) indicador, ou ent�o, indicadores que possuam uma mesma Linha Temporal no hist�rico."
		ElseIf lMsgSeries
			MsgInfo(STR0039 + ; //"Os Indicadores selecionados para o gr�fico apresentam diverg�ncia Cronol�gica de Hist�rico, e por isto n�o podem ser mesclados para uma mesma vis�o."
					CRLF + CRLF + ;
					STR0040 + CRLF + CRLF + ; //"Por favor, selecione apenas 1 (um) indicador, ou ent�o, indicadores que possuam uma mesma Linha Temporal no hist�rico."
					STR0041, STR0030) //"" ## "Aten��o"
			lMsgSeries := .F.
		EndIf
	EndIf
	
Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Processa os Dados (Resultados dos Indicadores selecionados).

@author Wagner Sobral de Lacerda
@since 03/01/2013

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fProcessa()
	
	// Vari�veis auxiliares
	Local cQryAlias := GetNextAlias()
	Local cQryDados := ""
	Local cQryInds  := ""
	
	Local aParcial := {}
	Local aAgrupa := {}
	Local nIndic := 0
	Local nX := 0, nScan := 0
	
	//-- Recebe Indicadores para a Query
	For nX := 1 To Len(aIndicadores)
		cQryInds += If(!Empty(cQryInds), ",", "") + "'" + AllTrim(aIndicadores[nX][1]) + "'"
	Next nX
	
	//----------
	// Processa
	//----------
	aResults := {}
	aParcial := {}
	If !Empty(cQryInds)
		// SELECT
		cQryDados := "SELECT "
		cQryDados += " TZE.TZE_INDIC, "
		cQryDados += " TZE.TZE_DATA, "
		cQryDados += " TZE.TZE_HORA, "
		cQryDados += " TZE.TZE_RESULT "
		// FROM "TZE"
		cQryDados += " FROM " + RetSQLName("TZE") + " TZE "
		If aScan(aParametros, {|x| x[6] }) > 0
			// INNER JOIN "TZG"
			cQryDados += "INNER JOIN " + RetSQLName("TZG") + " TZG ON "
			cQryDados += " ( "
			cQryDados += "  TZG.TZG_FILIAL = TZE.TZE_FILIAL "
			cQryDados += "  AND TZG.TZG_CODIGO = TZE.TZE_CODIGO "
			cQryDados += "  AND TZG.D_E_L_E_T_ <> '*'"
			For nX := 1 To Len(aParametros)
				If aParametros[nX][6]
					cQryDados += "  AND RTRIM(TZG.TZG_PARAM) = " + ValToSQL(AllTrim(aParametros[nX][1])) + " AND RTRIM(TZG.TZG_CONTEU) = " + ValToSQL(AllTrim(aParametros[nX][7])) + " "
				EndIf
			Next nX
			cQryDados += " ) "
		EndIf
		// WHERE
		cQryDados += "WHERE "
		cQryDados += " TZE.TZE_FILIAL = " + ValToSQL(xFilial("TZE")) + " "
		cQryDados += " AND TZE.TZE_MODULO = " + ValToSQL(Str(nModulo,2)) + " "
		cQryDados += " AND TZE.TZE_INDIC IN (" + cQryInds + ") "
		cQryDados += " AND TZE.D_E_L_E_T_ <> '*' "
		If !Empty(dDeData)
			cQryDados += " AND TZE.TZE_DATA >= " + ValToSQL(dDeData) + " "
		EndIf
		If !Empty(dAteData)
			cQryDados += " AND TZE.TZE_DATA <= " + ValToSQL(dAteData) + " "
		EndIf
		// ORDER BY
		cQryDados += "ORDER BY TZE.TZE_INDIC, "
		cQryDados += " TZE.TZE_DATA, "
		cQryDados += " TZE.TZE_HORA "
		// Verifica sintaxe da query
		cQryDados := ChangeQuery(cQryDados)
		// Executa
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryDados), cQryAlias, .F., .T.)
		dbSelectArea(cQryAlias)
		dbGoTop()
		While !Eof()
			nIndic := aScan(aParcial, {|x| AllTrim(x[1]) == AllTrim((cQryAlias)->TZE_INDIC) })
			If nIndic == 0
				// 1                   ; 2
				// C�digo do Indicador ; {Resultados}
				aAdd(aParcial, {(cQryAlias)->TZE_INDIC, {}})
				nIndic := Len(aParcial)
			EndIf
			aAdd(aParcial[nIndic][2], {STOD((cQryAlias)->TZE_DATA), (cQryAlias)->TZE_HORA, (cQryAlias)->TZE_RESULT})
			dbSkip()
		End
		(cQryAlias)->( dbCloseArea() )
	EndIf
	
	//--------------------
	// Agrupamento
	//--------------------
	If cAgrupa == "1" // N�o Agrupar
		
		// Resultado
		For nIndic := 1 To Len(aParcial)
			nScan := aScan(aResults, {|x| x[1] == aParcial[nIndic][1] })
			If nScan == 0
				aAdd(aResults, {aParcial[nIndic][1], {}})
				nScan := Len(aResults)
			EndIf
			For nX := 1 To Len(aParcial[nIndic][2])
				aAdd(aResults[nScan][2], {DTOC(aParcial[nIndic][2][nX][1]) + " - " + aParcial[nIndic][2][nX][2], aParcial[nIndic][2][nX][3]})
			Next nX
		Next nIndic
		
	ElseIf cAgrupa == "2" // Di�rio
		
		// Agrupa
		aAgrupa := Array(Len(aParcial))
		For nIndic := 1 To Len(aParcial)
			aAgrupa[nIndic] := {aParcial[nIndic][1], {}}
			For nX := 1 To Len(aParcial[nIndic][2])
				nScan := aScan(aAgrupa[nIndic][2], {|x| x[1] == aParcial[nIndic][2][nX][1] })
				If nScan == 0
					aAdd(aAgrupa[nIndic][2], {aParcial[nIndic][2][nX][1], 0, 0})
					nScan := Len(aAgrupa[nIndic][2])
				EndIf
				aAgrupa[nIndic][2][nScan][2] += aParcial[nIndic][2][nX][3] // Resultado
				aAgrupa[nIndic][2][nScan][3]++ // Quantidade
			Next nX
		Next nIndic
		
		// Resultado
		For nIndic := 1 To Len(aAgrupa)
			nScan := aScan(aResults, {|x| x[1] == aAgrupa[nIndic][1] })
			If nScan == 0
				aAdd(aResults, {aAgrupa[nIndic][1], {}})
				nScan := Len(aResults)
			EndIf
			For nX := 1 To Len(aAgrupa[nIndic][2])
				aAdd(aResults[nScan][2], {DTOC(aAgrupa[nIndic][2][nX][1]), aAgrupa[nIndic][2][nX][2]/aAgrupa[nIndic][2][nX][3]})
			Next nX
		Next nIndic
		
	ElseIf cAgrupa == "3" // Semanal
		
		// Agrupa
		aAgrupa := Array(Len(aParcial))
		For nIndic := 1 To Len(aParcial)
			aAgrupa[nIndic] := {aParcial[nIndic][1], {}}
			For nX := 1 To Len(aParcial[nIndic][2])
				nScan := aScan(aAgrupa[nIndic][2], {|x| x[1] == fGetSemana(aParcial[nIndic][2][nX][1]) .And. x[2] == Month(aParcial[nIndic][2][nX][1]) .And. x[3] == Year(aParcial[nIndic][2][nX][1]) })
				If nScan == 0
					aAdd(aAgrupa[nIndic][2], {fGetSemana(aParcial[nIndic][2][nX][1]), Month(aParcial[nIndic][2][nX][1]), Year(aParcial[nIndic][2][nX][1]), 0, 0})
					nScan := Len(aAgrupa[nIndic][2])
				EndIf
				aAgrupa[nIndic][2][nScan][4] += aParcial[nIndic][2][nX][3] // Resultado
				aAgrupa[nIndic][2][nScan][5]++ // Quantidade
			Next nX
		Next nIndic
		
		// Resultado
		For nIndic := 1 To Len(aAgrupa)
			nScan := aScan(aResults, {|x| x[1] == aAgrupa[nIndic][1] })
			If nScan == 0
				aAdd(aResults, {aAgrupa[nIndic][1], {}})
				nScan := Len(aResults)
			EndIf
			For nX := 1 To Len(aAgrupa[nIndic][2])
				aAdd(aResults[nScan][2], {cValToChar(aAgrupa[nIndic][2][nX][1]) + " " + SubStr(cMonth(CTOD("01/"+cValToChar(aAgrupa[nIndic][2][nX][2])+"/"+cValToChar(aAgrupa[nIndic][2][nX][3]))),1,3) + "/" + cValToChar(aAgrupa[nIndic][2][nX][3]), aAgrupa[nIndic][2][nX][4]/aAgrupa[nIndic][2][nX][5]})
			Next nX
		Next nIndic
		
	ElseIf cAgrupa == "4" // Mensal
		
		// Agrupa
		aAgrupa := Array(Len(aParcial))
		For nIndic := 1 To Len(aParcial)
			aAgrupa[nIndic] := {aParcial[nIndic][1], {}}
			For nX := 1 To Len(aParcial[nIndic][2])
				nScan := aScan(aAgrupa[nIndic][2], {|x| x[1] == Month(aParcial[nIndic][2][nX][1]) .And. x[2] == Year(aParcial[nIndic][2][nX][1]) })
				If nScan == 0
					aAdd(aAgrupa[nIndic][2], {Month(aParcial[nIndic][2][nX][1]), Year(aParcial[nIndic][2][nX][1]), 0, 0})
					nScan := Len(aAgrupa[nIndic][2])
				EndIf
				aAgrupa[nIndic][2][nScan][3] += aParcial[nIndic][2][nX][3] // Resultado
				aAgrupa[nIndic][2][nScan][4]++ // Quantidade
			Next nX
		Next nIndic
		
		// Resultado
		For nIndic := 1 To Len(aAgrupa)
			nScan := aScan(aResults, {|x| x[1] == aAgrupa[nIndic][1] })
			If nScan == 0
				aAdd(aResults, {aAgrupa[nIndic][1], {}})
				nScan := Len(aResults)
			EndIf
			For nX := 1 To Len(aAgrupa[nIndic][2])
				aAdd(aResults[nScan][2], {SubStr(cMonth(CTOD("01/"+cValToChar(aAgrupa[nIndic][2][nX][1])+"/"+cValToChar(aAgrupa[nIndic][2][nX][2]))),1,3) + "/" + cValToChar(aAgrupa[nIndic][2][nX][2]), aAgrupa[nIndic][2][nX][3]/aAgrupa[nIndic][2][nX][4]})
			Next nX
		Next nIndic
		
	ElseIf cAgrupa == "5" // Trimestral
		
		// Agrupa
		aAgrupa := Array(Len(aParcial))
		For nIndic := 1 To Len(aParcial)
			aAgrupa[nIndic] := {aParcial[nIndic][1], {}}
			For nX := 1 To Len(aParcial[nIndic][2])
				nScan := aScan(aAgrupa[nIndic][2], {|x| x[1] == fGetTrimes(aParcial[nIndic][2][nX][1]) .And. x[2] == Year(aParcial[nIndic][2][nX][1]) })
				If nScan == 0
					aAdd(aAgrupa[nIndic][2], {fGetTrimes(aParcial[nIndic][2][nX][1]), Year(aParcial[nIndic][2][nX][1]), 0, 0})
					nScan := Len(aAgrupa[nIndic][2])
				EndIf
				aAgrupa[nIndic][2][nScan][3] += aParcial[nIndic][2][nX][3] // Resultado
				aAgrupa[nIndic][2][nScan][4]++ // Quantidade
			Next nX
		Next nIndic
		
		// Resultado
		For nIndic := 1 To Len(aAgrupa)
			nScan := aScan(aResults, {|x| x[1] == aAgrupa[nIndic][1] })
			If nScan == 0
				aAdd(aResults, {aAgrupa[nIndic][1], {}})
				nScan := Len(aResults)
			EndIf
			For nX := 1 To Len(aAgrupa[nIndic][2])
				aAdd(aResults[nScan][2], {"Trimestre" + " " + cValToChar(aAgrupa[nIndic][2][nX][1]) + "/" + cValToChar(aAgrupa[nIndic][2][nX][2]), aAgrupa[nIndic][2][nX][3]/aAgrupa[nIndic][2][nX][4]})
			Next nX
		Next nIndic
		
	ElseIf cAgrupa == "6" // Semestral
		
		// Agrupa
		aAgrupa := Array(Len(aParcial))
		For nIndic := 1 To Len(aParcial)
			aAgrupa[nIndic] := {aParcial[nIndic][1], {}}
			For nX := 1 To Len(aParcial[nIndic][2])
				nScan := aScan(aAgrupa[nIndic][2], {|x| x[1] == fGetSemest(aParcial[nIndic][2][nX][1]) .And. x[2] == Year(aParcial[nIndic][2][nX][1]) })
				If nScan == 0
					aAdd(aAgrupa[nIndic][2], {fGetSemest(aParcial[nIndic][2][nX][1]), Year(aParcial[nIndic][2][nX][1]), 0, 0})
					nScan := Len(aAgrupa[nIndic][2])
				EndIf
				aAgrupa[nIndic][2][nScan][3] += aParcial[nIndic][2][nX][3] // Resultado
				aAgrupa[nIndic][2][nScan][4]++ // Quantidade
			Next nX
		Next nIndic
		
		// Resultado
		For nIndic := 1 To Len(aAgrupa)
			nScan := aScan(aResults, {|x| x[1] == aAgrupa[nIndic][1] })
			If nScan == 0
				aAdd(aResults, {aAgrupa[nIndic][1], {}})
				nScan := Len(aResults)
			EndIf
			For nX := 1 To Len(aAgrupa[nIndic][2])
				aAdd(aResults[nScan][2], {"Semestre" + " " + cValToChar(aAgrupa[nIndic][2][nX][1]) + "/" + cValToChar(aAgrupa[nIndic][2][nX][2]), aAgrupa[nIndic][2][nX][3]/aAgrupa[nIndic][2][nX][4]})
			Next nX
		Next nIndic
		
	ElseIf cAgrupa == "7" // Anual
		
		// Agrupa
		aAgrupa := Array(Len(aParcial))
		For nIndic := 1 To Len(aParcial)
			aAgrupa[nIndic] := {aParcial[nIndic][1], {}}
			For nX := 1 To Len(aParcial[nIndic][2])
				nScan := aScan(aAgrupa[nIndic][2], {|x| x[1] == Year(aParcial[nIndic][2][nX][1]) })
				If nScan == 0
					aAdd(aAgrupa[nIndic][2], {Year(aParcial[nIndic][2][nX][1]), 0, 0})
					nScan := Len(aAgrupa[nIndic][2])
				EndIf
				aAgrupa[nIndic][2][nScan][2] += aParcial[nIndic][2][nX][3] // Resultado
				aAgrupa[nIndic][2][nScan][3]++ // Quantidade
			Next nX
		Next nIndic
		
		// Resultado
		For nIndic := 1 To Len(aAgrupa)
			nScan := aScan(aResults, {|x| x[1] == aAgrupa[nIndic][1] })
			If nScan == 0
				aAdd(aResults, {aAgrupa[nIndic][1], {}})
				nScan := Len(aResults)
			EndIf
			For nX := 1 To Len(aAgrupa[nIndic][2])
				aAdd(aResults[nScan][2], {cValToChar(aAgrupa[nIndic][2][nX][1]), aAgrupa[nIndic][2][nX][2]/aAgrupa[nIndic][2][nX][3]})
			Next nX
		Next nIndic
		
	EndIf
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetSemana
Recebe a Semana do M�s.

@author Wagner Sobral de Lacerda
@since 04/01/2013

@return nSemana
/*/
//---------------------------------------------------------------------
Static Function fGetSemana(dData)
	
	// Vari�vel do Retorno
	Local nSemana := 0
	
	// Vari�veis auxiliares
	Local nDia := Day(dData)
	
	// Recebe
	If nDia >= 1 .And. nDia <= 7
		nSemana := 1
	ElseIf nDia >= 8 .And. nDia <= 15
		nSemana := 2
	ElseIf nDia >= 16 .And. nDia <= 23
		nSemana := 3
	ElseIf nDia >= 24 .And. nDia <= 31
		nSemana := 4
	EndIf
	
Return nSemana

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTrimes
Recebe o Trimestre do Ano.

@author Wagner Sobral de Lacerda
@since 04/01/2013

@return nTrimestre
/*/
//---------------------------------------------------------------------
Static Function fGetTrimes(dData)
	
	// Vari�vel do Retorno
	Local nTrimestre := 0
	
	// Vari�veis auxiliares
	Local nMes := Month(dData)
	
	// Recebe
	If nMes >= 1 .And. nMes <= 3
		nTrimestre := 1
	ElseIf nMes >= 4 .And. nMes <= 6
		nTrimestre := 2
	ElseIf nMes >= 7 .And. nMes <= 8
		nTrimestre := 3
	ElseIf nMes >= 10 .And. nMes <= 12
		nTrimestre := 4
	EndIf
	
Return nTrimestre

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetSemest
Recebe o Semestre do Ano.

@author Wagner Sobral de Lacerda
@since 04/01/2013

@return nSemestre
/*/
//---------------------------------------------------------------------
Static Function fGetSemest(dData)
	
	// Vari�vel do Retorno
	Local nSemestre := 0
	
	// Vari�veis auxiliares
	Local nMes := Month(dData)
	
	// Recebe
	If nMes >= 1 .And. nMes <= 6
		nSemestre := 1
	ElseIf nMes >= 7 .And. nMes <= 12
		nSemestre := 2
	EndIf
	
Return nSemestre
