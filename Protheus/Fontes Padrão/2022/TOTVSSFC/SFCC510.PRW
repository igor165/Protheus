#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MSGRAPHI.CH' 
#INCLUDE 'SFCC510.CH'

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC510
Tela de consulta de Monitoramento de Fábrica

@author Ana Carolina Tomé Klock
@since 04/01/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SFCC510()
Local oDlg, oFWLayer, oFWLayerGr, oFwLayerG[5], oScroll, oDetails, oScrollGrf, oPnlGraf	// Separações da Tela
Local oPanelDet, oPanelGraf, oPanGraf[5], oPanInfo[5]               // Separações de Dados
Local aCoors 	:= FWGetDialogSize()					   			// Dimensionamento/Posicionamento
Local nWidth  	:= ((aCoors[4]-16)/2)/3                     		// Largura
Local nHeigth 	:= (aCoors[3]/2.82)-13                      		// Altura
Local aButtons	:=	{;
							{ "SFCC510NOV", {|| If(SFCC510NOV(cCombo), , oDlg:End()) }, STR0003, STR0003, {|| .T.} },;
							{ "Imprimi", {|| Imprimi() }, STR0057, STR0057, {|| .T.} }; // "Imprimir"
						}
Local nJ, nI	:= 1
Local cCombo 	:= {}
Private oIndic[3][5], nFator
Private oFWChart[5], aCampos[18], aFiltro[11]
Private aUnidadeMed	:= { SFCXUNIDME("01"), SFCXUNIDME("02"), SFCXUNIDME("03"), SFCXUNIDME("04"), ;
						 SFCXUNIDME("05"), SFCXUNIDME("07"), SFCXUNIDME("08"), SFCXUNIDME("10"), ;
						 SFCXUNIDME("11"), SFCXUNIDME("12"), SFCXUNIDME("13"), SFCXUNIDME("14"), SFCXUNIDME("09") }
Private cCZ4			:= ""       // Alias do Banco Utilizado
Default lAutoMacao := .F.

If aCoors[4] > 800
	nFator := 1
Else
	nFator := 0.5
EndIf

SFCA009RES(.T.) // Se não existirem indicadores, deverá criar

// Carrega indicadores específicos no combo
dbSelectArea("CYJ")
CYJ->( dbGoTop() )
While CYJ->(!EOF())
	If  CYJ->CYJ_TPIN == '07' .Or. CYJ->CYJ_TPIN == '08' .Or. ;
		CYJ->CYJ_TPIN == '09' .Or. CYJ->CYJ_TPIN == '13' .Or. ;
		CYJ->CYJ_TPIN == '14' .Or. CYJ->CYJ_TPIN == '15'
  		aAdd( cCombo, GetCount(nI++) + '=' + CYJ->CYJ_CDIN )
	EndIf
	CYJ->(dbSkip())
End

// Verifica se o SFCFILTRO foi confirmado
If !SFCFILTRO()
	Return Nil
EndIf

Private  oPanel[5]

IF !lAutoMacao
	// Cria a janela principal
	Define MsDialog oDlg Title  STR0002  FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel // 'Monitoramento de Fábrica'

	// Divisão da Janela Principal
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )
	oFWLayer:AddLine('TOP', 25, .T. )
	oFWLayer:AddLine('BUTTON', 67, .T. )
	oFWLayer:AddCollumn('DETALHE', 100, .T. ,'TOP')
	oFWLayer:AddCollumn('GRAFICO', 100, .T. ,'BUTTON')
	oFWLayer:AddWindow('DETALHE', 'DETALHE_WINDOW', STR0055, 100, .T., .F.,, 'TOP'   ) // 'Detalhes'
	oFWLayer:AddWindow('GRAFICO', 'GRAFICO_WINDOW', STR0056, 100, .T., .F.,, 'BUTTON') // 'Gráfico'
	oPanelDet := oFWLayer:GetWinPanel( 'DETALHE','DETALHE_WINDOW', 'TOP' )
	oPanelGraf := TPanel():New(0, 0, , oFWLayer:GetWinPanel( 'GRAFICO','GRAFICO_WINDOW', 'BUTTON' ),,,,CLR_WHITE,CLR_WHITE)
	oPanelGraf:Align := CONTROL_ALIGN_ALLCLIENT

	oScrollGrf := TScrollArea():New( oPanelGraf, 01, 01, nWidth, aCoors[3]-nHeigth, .T., .T., .T. )
	oScrollGrf:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlGraf := TPanel():New( 01, 01, /*cText*/, oScrollGrf, , /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, nWidth, 200 )

	oScrollGrf:SetFrame( oPnlGraf )

	// Detalhe Superior
	oScroll := TScrollArea():New( oPanelDet, 01, 01, (nWidth * 3) - 4, (nHeigth/3) - 10, .T., .T., .T. )
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	// Cria painel
	oDetails := TPanel():New( 01, 01, /*cText*/, oScroll, , /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, 350, 62 )

	// Define objeto painel como filho do scroll
	oScroll:SetFrame( oDetails )

	@ 05, 010  Say STR0004			 				 	Of oDetails COLOR CLR_BLACK Pixel  // "Capacidade Proj."
	TGet():New(013, 010,{|| cValToChar(aCampos[16]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[16]))
	@ 05, 070  SAY STR0005							  	Of oDetails COLOR CLR_BLACK Pixel  // "Capacidade Efet."
	TGet():New(013, 070,{|| cValToChar(aCampos[17]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[17]))
	@ 05, 130  SAY STR0006			   					Of oDetails COLOR CLR_BLACK Pixel  // "Capacidade Real"
	TGet():New(013, 130,{|| cValToChar(aCampos[18]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[18]))
	@ 05, 190  SAY aUnidadeMed[5]  + STR0007			Of oDetails COLOR CLR_BLACK Pixel  //  " Disp. Real"
	TGet():New(013, 190,{|| cValToChar(aCampos[5]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[5]))
	@ 05, 250  SAY aUnidadeMed[3]  + STR0008			Of oDetails COLOR CLR_BLACK Pixel  // " Utilização"
	TGet():New(013, 250,{|| cValToChar(aCampos[4]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[4]))
	@ 05, 310  SAY aUnidadeMed[1]  + STR0009			Of oDetails COLOR CLR_BLACK Pixel  // " Qualidade"
	TGet():New(013, 310,{|| cValToChar(aCampos[1]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[1]))
	@ 05, 370  SAY aUnidadeMed[2]  + STR0010	 		Of oDetails COLOR CLR_BLACK Pixel  // " Qual. Real"
	TGet():New(013, 370,{|| cValToChar(aCampos[2]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[2]))
	@ 05, 430  SAY aUnidadeMed[4]  + STR0011			Of oDetails COLOR CLR_BLACK Pixel  // " Eficiência"
	TGet():New(013, 430,{|| cValToChar(aCampos[3]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[3]))
	@ 28, 010  SAY aUnidadeMed[6]  + STR0012  			Of oDetails COLOR CLR_BLACK Pixel  // " NEE"
	TGet():New(036, 010,{|| cValToChar(aCampos[7]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[7]))
	@ 28, 070  SAY aUnidadeMed[7]  + STR0013			Of oDetails COLOR CLR_BLACK Pixel  // " OEE"
	TGet():New(036, 070,{|| cValToChar(aCampos[8]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[8]))
	@ 28, 130  SAY aUnidadeMed[13] + STR0014			Of oDetails COLOR CLR_BLACK Pixel  // " TEEP"
	TGet():New(036, 130,{|| cValToChar(aCampos[9]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[9]))
	@ 28, 190  SAY aUnidadeMed[12] + STR0015	  		Of oDetails COLOR CLR_BLACK Pixel  // " Tk"
	TGet():New(036, 190,{|| cValToChar(aCampos[14]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[14]))
	@ 28, 250  SAY aUnidadeMed[11] + STR0016   			Of oDetails COLOR CLR_BLACK Pixel  // " BTS"
	TGet():New(036, 250,{|| cValToChar(aCampos[13]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[13]))
	@ 28, 310  SAY aUnidadeMed[10] + STR0017			Of oDetails COLOR CLR_BLACK Pixel  // " BTS S."
	TGet():New(036, 310,{|| cValToChar(aCampos[12]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[12]))
	@ 28, 370  SAY aUnidadeMed[8]  + STR0018	   		Of oDetails COLOR CLR_BLACK Pixel  // " BTS V."
	TGet():New(036, 370,{|| cValToChar(aCampos[10]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[10]))
	@ 28, 430  SAY aUnidadeMed[9]  + STR0019			Of oDetails COLOR CLR_BLACK Pixel  // " BTS M."
	TGet():New(036, 430,{|| cValToChar(aCampos[11]) } , oDetails, 43, 07, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,cValToChar(aCampos[11]))

	//
	oFwLayerGr := FWLayer():New()
	oFwLayerGr:Init( oPnlGraf, .F., .T. )
	For nI := 1 to 5
		// Separação entre gráficos
		oFwLayerGr:addCollumn( 'GRAFICO_' + cValToChar(nI) , 20, .T. )
		oFwLayerG[nI] := FWLayer():New()
		oFwLayerG[nI]:Init(oFwLayerGr:getColPanel('GRAFICO_' + cValToChar(nI) ), .F., .T. )
		oFwLayerG[nI]:AddLine( 'G' + cValToChar(nI) + '_GRAF', 70, .T.)
		oFwLayerG[nI]:AddLine( 'G' + cValToChar(nI) + '_INFO', 70, .T.)

		// Separação entre gráficos e detalhes
		oPanGraf[nI] := oFwLayerG[nI]:getLinePanel( 'G' + cValToChar(nI) + '_GRAF' )
		oPanInfo[nI] := oFwLayerG[nI]:getLinePanel( 'G' + cValToChar(nI) + '_INFO' )

		// Gráfico
		oFWChart[nI] := FWChartFactory():New()
		oFWChart[nI] := oFWChart[nI]:getInstance( BARCHART )
		oFWChart[nI]:Init( oPanGraf[nI], .F. )
		oFWChart[nI]:setLegend( CONTROL_ALIGN_TOP )

		// Detalhes
		oPanel[nI] := TPanel():New( 00, 00, , oPanInfo[nI], , .T., , CLR_BLACK, CLR_WHITE, 500, 500, .F., .F. )

		For nJ := 1 to 3
			oIndic[nJ][nI] := TSay():New( nJ * nFator, 01, { || SPACE(40) }, oPanel[nI] )
		Next

	Next

	// Atualiza os gráficos
	SFCGRAPHIC( cCombo )

	Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },,@aButtons,,,,,, .F. )
ENDIF

Return Nil
//-----------------------------------------------------------------
Static Function MenuDef()

Return {}
//-------------------------------------------------------------------------------
Static Function Imprimi()
Default lAutoMacao := .F.

	cQuery := "SELECT CZ4.* FROM " + RetSQLName( 'CZ4' )  + " CZ4 "
	cQuery += "	INNER JOIN  " + RetSQLName( 'CY5' )  + " CY5 ON CY5.CY5_IDMEPO = CZ4.CZ4_IDMEPO "
	cQuery += "WHERE "
	cQuery += "	CY5.CY5_FILIAL = '" + xFilial('CY5')+ "' AND "
	cQuery += "	CY5.CY5_CDMEPO = '" + aFiltro[09]	+ "' AND "
	cQuery += "	CY5.D_E_L_E_T_ = ' ' AND "
	cQuery += "	CZ4.CZ4_FILIAL = '" + xFilial('CZ4')+ "' AND "
	cQuery += "	CZ4_CDES      >= '" + aFiltro[01]	+ "' AND "
	cQuery += "	CZ4_CDES      <= '" + aFiltro[02]	+ "' AND"
	cQuery += "	CZ4_CDARPO    >= '" + aFiltro[03]	+ "' AND "
	cQuery += "	CZ4_CDARPO    <= '" + aFiltro[04]	+ "' AND"
	cQuery += "	CZ4_CDCETR    >= '" + aFiltro[05]	+ "' AND "
	cQuery += "	CZ4_CDCETR    <= '" + aFiltro[06]	+ "' AND"
	cQuery += "	CZ4_CDMQ      >= '" + aFiltro[07]	+ "' AND "
	cQuery += "	CZ4_CDMQ      <= '" + aFiltro[08]	+ "' AND"
	cQuery += "	CZ4_DTRE       = '" + aFiltro[10]	+ "' AND "
	cQuery += "	CZ4_HRRE       = '" + aFiltro[11]	+ "' AND"
	cQuery += "	CZ4.D_E_L_E_T_ = ' ' "

	cImprime := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cImprime, .T., .F. )
	IF !lAutoMacao
		SFCXExpTab(,,,cImprime)
	ENDIF
Return Nil
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCGRAPHIC
Atualiza gráficos e faixas

@author Israel A Possoli
@since 14/04/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function SFCGRAPHIC( cCombo )
Local aOpc := GetSequence( cCombo )

SFCC510ALG( cCombo[aOpc[1]], 1, cCombo )
SFCC510ALG( cCombo[aOpc[2]], 2, cCombo )
SFCC510ALG( cCombo[aOpc[3]], 3, cCombo )
SFCC510ALG( cCombo[aOpc[4]], 4, cCombo )
SFCC510ALG( cCombo[aOpc[5]], 5, cCombo )

Return Nil
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC510ALG
Altera o gráfico

@param 	cNome	Número Sequencial do Indicador
@param 	nPanel	Posicao em que será inserido (de 1 a 5)
@param  cCombo	Lista de opções do combo

@author Ana Carolina Tomé Klock
@since 17/06/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function SFCC510ALG( cNome, nPanel, cCombo )
Local oFunctio
Local cFunction 	:= SubStr( cNome, 1, 2 )
Local aFaixa 		:= SFCXFAIXA( Substr(cNome,4) )
Local DETAIL_BUTTON := ""

If aFaixa[1]

	@01, 01 Combobox oFunctio Var cFunction Items cCombo Size 70,10 Pixel Of oPanel[nPanel]
	oFunctio:bChange := { || SFCC510ALG( cCombo[oFunctio:nAt], nPanel, cCombo ) }

	// Informações
   	oIndic[1][nPanel]:SetText( aFaixa[09] + SPACE(4) + aFaixa[04] + ' - ' + aFaixa[05] )
	oIndic[2][nPanel]:SetText( aFaixa[10] + SPACE(4) + aFaixa[05] + ' - ' + aFaixa[06] )
	oIndic[3][nPanel]:SetText( aFaixa[11] + SPACE(4) + aFaixa[06] + ' - ' + aFaixa[07] )
	oIndic[1][nPanel]:CtrlRefresh()
	TButton():New(05*nFator, 02, STR0020, oPanel[nPanel], {|| SFCC511( cCombo, oFunctio:nAt, aFiltro )}, 40, 10,,,.F.,.F.)  // 'Detalhar'

	If ( Val(aFaixa[3]) >= 15 )
   		If ExistBlock( AllTrim( DETAIL_BUTTON ) ) .And. !Empty( DETAIL_BUTTON )
	   		TButton():New(05*nFator, 02, STR0020, oPanel[nPanel], {|| &( DETAIL_BUTTON + '()' )}, 40, 10,,,.F.,.F.)  // 'Detalhar'
		EndIf
	EndIf

	// Gráfico
	//oFWChart
	oFWChart[nPanel]:Reset()
	oFWChart[nPanel]:setTitle( AllTrim(aFaixa[2]) + SPACE(4) + cValToChar(aCampos[Val(aFaixa[3])]) + SPACE(4) + aFaixa[8], CONTROL_ALIGN_CENTER )
	oFWChart[nPanel]:setMask( "*@* " + aFaixa[8] )
	If aFaixa[3] != '14'
		SFCXIndSon( aFaixa[2], oFWChart[nPanel], aCampos)
		oFWChart[nPanel]:Build()
	// Tk
	Else
		oFWChart[nPanel]:setPicture( "@E 999,999.99" )
		oFWChart[nPanel]:addSerie( STR0034 , NoRound(aCampos[15],2))      // "Planejado"
		oFWChart[nPanel]:addSerie( STR0035 , NoRound(aCampos[14],2))      // "Real"
		oFWChart[nPanel]:Build()
	EndIf
Else
	oFWChart[nPanel]:setTitle( STR0025, CONTROL_ALIGN_CENTER )    // 'Sem faixa cadastrada'
	oFWChart[nPanel]:Build()
EndIf

Return Nil
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC510NOV
Chama o gráfico novamente

@author Ana Carolina Tomé Klock
@since 18/04/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function SFCC510NOV(cCombo)

If SFCFILTRO()
	SFCGRAPHIC(cCombo)
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCFILTRO
Chama o filtro da tela

@return 	lRet		Retorna se o filtro está correto para abrir a tela

@author Ana Carolina Tomé Klock
@since 07/01/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function SFCFILTRO()
Local nHor, nMin, nSeg
Local lRet := .F.

If !Pergunte('SFCC510')
	Return lRet
Else
	nHor  := Val(SubStr(MV_PAR03, 1, 2))
	nMin  := Val(SubStr(MV_PAR03, 4, 2))
	nSeg  := Val(SubStr(MV_PAR03, 7, 2))

	// Validação
	If Empty( MV_PAR01 )
		Help( ,, 'Help',, STR0047, 1, 0 )   // "A meta deve ser informada"
		lRet := .F.
	ElseIf Empty(MV_PAR02)
		Help( ,, 'Help',, STR0048, 1, 0 )   // "A data de referência deve ser informada"
		lRet := .F.
	ElseIf Substr(MV_PAR03,1,8) == "  :  :  "
		Help( ,, 'Help',, STR0049, 1, 0 )   // "A hora de referência deve ser informada"
		lRet := .F.
	ElseIf  (nHor < 0 .Or. nHor > 23) .Or. (nMin < 0 .Or. nMin > 59) .Or. (nSeg < 0 .Or. nSeg > 59)
		Help( ,, 'Help',, STR0050, 1, 0 )   // "Verifique se a hora de referência foi informada corretamente"
		lRet := .F.
	ElseIf ( MV_PAR04 > MV_PAR05 )
	 	Help( ,, 'Help',, STR0051, 1, 0 )   // "O estabelecimento inicial não deve ser maior que o estabelecimento final"
		lRet := .F.
	ElseIf ( MV_PAR06 > MV_PAR07 )
	 	Help( ,, 'Help',, STR0052, 1, 0 )   // "A área de produção inicial não deve ser maior que a área de produção final"
		lRet := .F.
	ElseIf ( MV_PAR08 > MV_PAR09 )
	 	Help( ,, 'Help',, STR0053, 1, 0 )   // "O centro de trabalho inicial não deve ser maior que o centro de trabalho final"
		lRet := .F.
	ElseIf ( MV_PAR10 > MV_PAR11 )
	 	Help( ,, 'Help',, STR0054, 1, 0 )   // "A máquina inicial não deve ser maior que a máquina final"
		lRet := .F.
	Else
		aFiltro[1]	:= MV_PAR04
		aFiltro[2]	:= MV_PAR05
		aFiltro[3]	:= MV_PAR06
		aFiltro[4]	:= MV_PAR07
		aFiltro[5]	:= MV_PAR08
		aFiltro[6]	:= MV_PAR09
		aFiltro[7]	:= MV_PAR10
		aFiltro[8]	:= MV_PAR11
		aFiltro[9]	:= MV_PAR01
		aFiltro[10]	:= MV_PAR02
		aFiltro[11]	:= MV_PAR03
		
		lRet := .T.
	EndIf
EndIf

If lRet .AND. SFCLOADDT( aFiltro ) == 0
	Help( ,, 'Help',, STR0001, 1, 0 ) // 'Sua pesquisa não retornou resultados!
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCLOADDT
Carrega dados com base no SFCFILTRO

@param		aFiltro 		Dados da tela de filtro para buscar os dados
@return		nCount			Quantidade de registros disponíveis

@author Israel A Possoli
@since 07/01/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function SFCLOADDT( aFiltro )
Local cQueryCZ4		:= ""       // Query do Banco Utilizado
Local aQTCZ4		:= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, .F., .F., .F.  }
Local nMinVMME 		:= 0
Local nI, nCount	:= 0

// Obtendo a data e hora de referência mais próximas da indicada durante a seleção
cQueryCZ4 := " SELECT * FROM " + RetSQLName( 'CZ4' ) + " CZ4 "
cQueryCZ4 += " INNER JOIN " + RetSQLName( 'CY5' )  + " CY5 ON CY5.CY5_IDMEPO = CZ4.CZ4_IDMEPO"
cQueryCZ4 += "     WHERE CY5.CY5_FILIAL = '" + xFilial('CY5') + "' AND "
cQueryCZ4 += "     		 CY5.CY5_CDMEPO = '" + aFiltro[09] + "' AND "
cQueryCZ4 += "     		 CY5.D_E_L_E_T_ = ' ' AND "
cQueryCZ4 += "     		 CZ4.CZ4_FILIAL = '" + xFilial('CZ4') + "' AND "
cQueryCZ4 += "     		 CZ4.D_E_L_E_T_ = ' ' AND "
cQueryCZ4 += "         ( CZ4.CZ4_DTRE   = '" + DTOS(aFiltro[10]) + "' AND "
cQueryCZ4 += "           CZ4.CZ4_HRRE  <= '" + aFiltro[11] + "') OR "
cQueryCZ4 += "			 CZ4.CZ4_DTRE  <  '" + DTOS(aFiltro[10]) + "' "
cQueryCZ4 += "  ORDER BY CZ4.CZ4_DTRE DESC, CZ4.CZ4_HRRE DESC "
cCZ4 := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQueryCZ4), cCZ4, .T., .F. )
If (cCZ4)->(!EOF())
	aFiltro[10] := (cCZ4)->CZ4_DTRE
	aFiltro[11] := (cCZ4)->CZ4_HRRE
Else
	Return nCount
EndIf

// Busca os dados para realizar o cálculo
cQueryCZ4 := "SELECT * FROM " + RetSQLName( 'CZ4' )  + " CZ4 "
cQueryCZ4 += "  INNER JOIN  " + RetSQLName( 'CY5' )  + " CY5 ON CY5.CY5_IDMEPO = CZ4.CZ4_IDMEPO"
cQueryCZ4 += "  WHERE CY5.CY5_FILIAL  = '" + xFilial('CY5') + "' AND "
cQueryCZ4 += "     	  CY5.CY5_CDMEPO  = '" + aFiltro[09] + "' AND "
cQueryCZ4 += "     	  CY5.D_E_L_E_T_  = ' ' AND "
cQueryCZ4 += "        CZ4.CZ4_FILIAL  = '" + xFilial('CZ4') + "' AND "
cQueryCZ4 += "        CZ4_CDES       >= '" + aFiltro[01] + "' AND CZ4_CDES    <= '" + aFiltro[02] + "' AND"
cQueryCZ4 += "		  CZ4_CDARPO     >= '" + aFiltro[03] + "' AND CZ4_CDARPO  <= '" + aFiltro[04] + "' AND"
cQueryCZ4 += "		  CZ4_CDCETR     >= '" + aFiltro[05] + "' AND CZ4_CDCETR  <= '" + aFiltro[06] + "' AND"
cQueryCZ4 += "		  CZ4_CDMQ       >= '" + aFiltro[07] + "' AND CZ4_CDMQ    <= '" + aFiltro[08] + "' AND"
cQueryCZ4 += "        CZ4_DTRE        = '" + aFiltro[10] + "' AND CZ4_HRRE    = '"  + aFiltro[11] + "' AND"
cQueryCZ4 += "        CZ4.D_E_L_E_T_  = ' ' "
cCZ4 := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQueryCZ4), cCZ4, .T., .F. )
While (cCZ4)->(!EOF())
	aQTCZ4[01] += (cCZ4)->CZ4_QTVMPL	// Horas Capacidade Projeto
	aQTCZ4[02] += (cCZ4)->CZ4_QTVMEV	// Horas Capacidade Efetiva
	aQTCZ4[03] += (cCZ4)->CZ4_QTVMRY 	// Horas Capacidade Real
	aQTCZ4[04] += (cCZ4)->CZ4_VLDIRY	// Disponibilidade Real
	aQTCZ4[05] += (cCZ4)->CZ4_QTATRY	// Horas Operação Real
	aQTCZ4[06] += (cCZ4)->CZ4_QTRTRY	// Quantidade Retrabalhada
	aQTCZ4[07] += (cCZ4)->CZ4_QTRPRY	// Quantidade Reportada
	aQTCZ4[08] += (cCZ4)->CZ4_QTRFRY	// Quantidade Refugada
	aQTCZ4[09] += (cCZ4)->CZ4_QTRPPL	// Quantidade Planejada
	aQTCZ4[10] += (cCZ4)->CZ4_QTATPA	// Tempo Padrão
	aQTCZ4[11] += (cCZ4)->CZ4_QTMIX		// Mix
	aQTCZ4[12] += (cCZ4)->CZ4_QTSQ		// Sequência
	aQTCZ4[13] += (cCZ4)->CZ4_QTVM		// Volume
	aQTCZ4[14] += (cCZ4)->CZ4_QTME		// Quantidade Meta
	aQTCZ4[15] += (cCZ4)->CZ4_QTSPEF    // Altera Eficiência
	aQTCZ4[16] += (cCZ4)->CZ4_QTSURY	// Quantidade Preparação Real
	aQTCZ4[17] += (cCZ4)->CZ4_QTSUPA    // Preparação Real
	aQTCZ4[18] := (cCZ4)->CZ4_LGSUEF    // Considera Setup na Eficiencia
	aQTCZ4[19] := (cCZ4)->CZ4_LGSPEF    // Considera Parada na Eficiencia
	aQTCZ4[20] := (cCZ4)->CZ4_LGPNRF	// Considera Fator Refugo
	nCount++
	(cCZ4)->(dbSkip())
End

// Realiza o cálculo
If nCount > 0
	aQTCZ4[18] := If(ValType(aQTCZ4[18]) == 'L', aQTCZ4[18], If (ValType(aQTCZ4[18])== 'C', If(aQTCZ4[18] == 'T', .T., .F.), .F.))
	aQTCZ4[19] := If(ValType(aQTCZ4[19]) == 'L', aQTCZ4[19], If (ValType(aQTCZ4[19])== 'C', If(aQTCZ4[19] == 'T', .T., .F.), .F.))
	aQTCZ4[20] := If(ValType(aQTCZ4[20]) == 'L', aQTCZ4[20], If (ValType(aQTCZ4[20])== 'C', If(aQTCZ4[20] == 'T', .T., .F.), .F.))

	aCampos[16]	:= aQTCZ4[01]   									   							// Capacidade Projetada
	aCampos[17]	:= aQTCZ4[02]   									   	   						// Capacidade Efetiva
	aCampos[18]	:= aQTCZ4[03]   										 						// Capacidade Real
	aCampos[5]	:= If( aQTCZ4[01] > 0, (aQTCZ4[03]/aQTCZ4[01])*100, 0 )  						// Disponibilidade Real
	aCampos[4]  := If( aQTCZ4[03] > 0, (aQTCZ4[05]/aQTCZ4[03])*100, 0 )   						// Utilização
	aCampos[6]  := If( aQTCZ4[01] > 0, (aQTCZ4[02]/aQTCZ4[01])*100, 0 )	 						// Disponibilidade Planejada
	aCampos[1]	:= If( aQTCZ4[07] > 0, ((aQTCZ4[07]-aQTCZ4[08])/aQTCZ4[07])*100, 0 )  			// Qualidade
	aCampos[2]	:= If( aQTCZ4[07] > 0, ((aQTCZ4[07]-aQTCZ4[08]-aQTCZ4[06])/aQTCZ4[07])*100, 0 )	// Qualidade Real

	// Considera Setup na eficiência
	If aQTCZ4[18]
		aQTCZ4[05] += aQTCZ4[16]
		aQTCZ4[10] += aQTCZ4[17]
	EndIf
	// Considera Parada na eficiência
	If aQTCZ4[19]
   		aQTCZ4[05] += aQTCZ4[15]
   	EndIf
	aCampos[3]	:= If( aQTCZ4[05] > 0, aQTCZ4[10] * 100 / aQTCZ4[05], 0 )					   			// Eficiência
	// Se considerar Fator Refugo, multiplica pela Qualidade
	If aQTCZ4[20]
		aCampos[3]  *= aCampos[1]
		aCampos[3]  /= 100
	EndIf

	aCampos[7]	:= (aCampos[2] * aCampos[3])/100			   			   						// Eficiência Líquida - NEE
	aCampos[8]  := ( aCampos[5] * aCampos[2] * aCampos[3] ) / 10000		   						// Eficiência Geral   - OEE
	aCampos[15] := If( aQTCZ4[09] > 0, (aQTCZ4[01]*60)/aQTCZ4[09], 0 ) 	   						// Takt Time Planejado
	aCampos[14]	:= If( aQTCZ4[07] > 0, (aQTCZ4[03]*60)/aQTCZ4[07], 0 )    						// Takt Time Real
	aCampos[9]	:= (aCampos[5]*aCampos[2]*aCampos[3]*aCampos[4])/1000000 						// Produtividade - TEEP
	nMinVMME 	:= Min( aQTCZ4[14], aQTCZ4[13] )   						   						// Quantidade Meta ou Capacidade Projetada
	aCampos[12] := If( aQTCZ4[11] > 0, (aQTCZ4[12]/aQTCZ4[11])*100, 0 )    						// Acompanhamento de Produção - Sequência
	aCampos[10] := If( aQTCZ4[14] > 0, (aQTCZ4[13]/aQTCZ4[14])*100, 0 )   						// Acompanhamento de Produção - Volume

	aCampos[11] := If( nMinVMME > 0, (aQTCZ4[11]/nMinVMME)*100, 0 )		    					// Acompanhamento de Produção - Mix
	aCampos[13]	:= (aCampos[12]*aCampos[10]*aCampos[11])/10000	 		   						// Acompanhamento de Produção

	// Arredonda o valor
	For nI := 1 to len(aCampos)
		aCampos[nI] := Round( aCampos[nI], 2 )
	Next
EndIf

Return nCount

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCount
Retorna o valor com uma quantidade de zeros à esquerda, conforme tamanho informado.

@param		nValor 		Valor que se deseja adicionar os zeros
@param 		nTamanho	Tamanho da string a ser retornada
@return		cValor		String com zeros e o valor desejado

@author		Ana Carolina Tomé Klock
@since 		23/05/2013
@version 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetCount( nValor, nTamanho )
Local cValor 	 := ''
Default nValor 	 := 1
Default nTamanho := 0

// Caso não informado tamanho, busca nos indicadores
If nTamanho == 0
	nTamanho := Len( cValToChar( CYJ->(RecCount()) ) )
EndIf

nTamanho -= Len( cValToChar(nValor) )
cValor  := Replicate( '0', nTamanho ) + cValToChar(nValor)

Return cValor

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCount
Retorna um vetor com as opções padrões de cada gráfico

@return		aOpc		Vetor com 5 posições que indicam os padrões de cada gráfico

@author		Ana Carolina Tomé Klock
@since 		23/05/2013
@version 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetSequence( cCombo )
Local nCombo 	:= { 0, 0, 0, 0, 0 }
Local nTamanho  := RAT('=', cCombo[1]) + 1
Local nI

// Define os valores padrões
For nI := 1  to len(cCombo)
	If AScan(nCombo,0) > 0
		CYJ->( dbSetOrder(1) )
		If CYJ->( dbSeek( xFilial('CYJ')+SubStr(cCombo[nI],nTamanho) ) )
			If CYJ->CYJ_TPIN == '07' .And. nCombo[2] == 0  		// NEE
				nCombo[2] := nI
			ElseIf CYJ->CYJ_TPIN == '08' .And. nCombo[3] == 0	// OEE
				nCombo[3] := nI
			ElseIf CYJ->CYJ_TPIN == '09' .And. nCombo[4] == 0	// TEEP
				nCombo[4] := nI
			ElseIf CYJ->CYJ_TPIN == '13' .And. nCombo[1] == 0   // BTS
				nCombo[1] := nI
			ElseIf CYJ->CYJ_TPIN == '14' .And. nCombo[5] == 0	// TK
				nCombo[5] := nI
			EndIf
		EndIf
	Else
		Exit
	EndIf
Next

// Preenche os demais com o primeiro encontrado
For nI := 1 to len(nCombo)
	If nCombo[nI] == 0
		nCombo[nI] := 1
	EndIf
Next

Return nCombo
