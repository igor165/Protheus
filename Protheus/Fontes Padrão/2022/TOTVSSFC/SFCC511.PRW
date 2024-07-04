#INCLUDE 'SFCC511.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH    
#INCLUDE 'MSGRAPHI.CH' 
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC511
Tela de Detalhe de Monitoramento de Fábrica

@author Israel A Possoli
@since 22/03/2011
@version 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SFCC511( cCombo, nPos, aFiltro )
Local nI, nJ, cCombo1   
Local aCoors    := FWGetDialogSize( oMainWnd )
Local aButtons  := {} 
Local aFWLayer	:= Array(5)
Local aPainel	:= Array(5) 
Local oPanelInfo1, oPanelInfo2  
Default aFiltro  := {}       
Private oFaixa   := Array(3,5) 
Private oCombo1
Private oFWChart := Array(5) 
	      
// Browse
Private oBrwBTS_Proj,  oBrwBTS_Real
Private oBrwNEE
Private oBrwOEE
Private oBrwTEEP_Proj, oBrwTEEP_Real
Private oBrwTk
	
dbSelectArea('SX3')
	
// Tabelas Temporárias
Private oTabBrw      := SFCCriFWTa(DefTabBrw())	// Browse principal
Private cTabBrw      := oTabBrw:GetAlias()
Private oTabBTS_Proj := SFCCriFWTa(DefBTSProj())	// BTS Projetado
Private cTabBTS_Proj := oTabBTS_Proj:GetAlias()
Private oTabBTS_Real := SFCCriFWTa(DefBTSProj())	// BTS Realizado
Private cTabBTS_Real := oTabBTS_Real:GetAlias() 
Private oTabNEE      := SFCCriFWTa(DefNEE())		// NEE Projetado
Private cTabNEE      := oTabNEE:GetAlias()
Private oTabOEE      := SFCCriFWTa(DefOEE())		// OEE Projetado
Private cTabOEE      := oTabOEE:GetAlias()
Private oTabTEEP     := SFCCriFWTa(DefTEEP())		// TEEP Projetado
Private cTabTEEP     := oTabTEEP:GetAlias()
Private oTabTk       := SFCCriFWTa(DefTk())	    // Tk Realizado
Private cTabTk       := oTabTk:GetAlias()
Private oSwBTS_Proj  := SFCCriFWTa(DefBTSProj())	// BTS Projetado Exibido
Private cSwBTS_Proj  := oSwBTS_Proj:GetAlias() 
Private oSwBTS_Real  := SFCCriFWTa(DefBTSProj())	// BTS Realizado Exibido
Private cSwBTS_Real  := oSwBTS_Real:GetAlias()
Private oSwNEE       := SFCCriFWTa(DefNEE())		// NEE Projetado Exibido
Private cSwNEE       := oSwNEE:GetAlias()
Private oSwTEEP      := SFCCriFWTa(DefTEEP())		// TEEP Exibido
Private cSwTEEP      := oSwTEEP:GetAlias()
Private oSwTk        := SFCCriFWTa(DefTk())		// Tk Realizado Exibido
Private cSwTk        := oSwTk:GetAlias()
      
// Carrega dados conforme o filtro	
CarregaDados( aFiltro )

// Ajusta tamanho da tela
aCoord := FwGetDialogSize()          
If aCoord[4] > 800
	nFator := 1
Else                                                 
	nFator := 0.5    
EndIf 
	
// Janela Principal	
Define MsDialog oDlgPrincDet Title  STR0001  FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel   // 'Monitoramento de Fábrica'        
	aAdd( aButtons, {"DETALHEMONITOR", {|| TelasAnalises("SFCC512")}, STR0002, STR0002, {|| .T.}} )    // 'Detalhar Monitoramento'
	aAdd( aButtons, {"ACOMPANHAMENTO", {|| TelasAnalises("SFCC520")}, STR0003, STR0003, {|| .T.}} )    // 'Meta de Produção'       
	aAdd( aButtons, {"ANALISEEFICIEN", {|| TelasAnalises("SFCC530")}, STR0004, STR0004, {|| .T.}} )    // 'Análise Eficiência'   
	aAdd( aButtons, {"ANALISEPARADA" , {|| TelasAnalises("SFCC540")}, STR0005, STR0005, {|| .T.}} )    // 'Análise Parada'      
	aAdd( aButtons, {"ANALISEQUALIDA", {|| TelasAnalises("SFCC550")}, STR0006, STR0006, {|| .T.}} )    // 'Análise Qualidade' 
	aAdd( aButtons, {"ANALISERECURSO", {|| TelasAnalises("SFCC560")}, STR0007, STR0007, {|| .T.}} )    // 'Análise Máquina'    
	aAdd( aButtons, {"EVOLUCAOHISTOR", {|| TelasAnalises("SFCC570")}, STR0008, STR0008, {|| .T.}} )    // 'Evolução Histórica'
	aAdd( aButtons, {"Imprimi", {||Imprimi(aFiltro[09],aFiltro[10],aFiltro[11],aFiltro[07],aFiltro[08])}, STR0056, STR0056, {|| .T.}} )    // "Imprimir"
	
	// Layer Principal 
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrincDet, .F.)
	oFWLayer:AddLine('BROWSE', 40, .T. )
	oFWLayer:AddLine('GRAFICO', 49, .T. )
	oFWLayer:AddCollumn('BROWSE_COL', 100, .T. ,'BROWSE')
	oFWLayer:AddCollumn('GRAFICO_COL', 100, .T. ,'GRAFICO')
	oFWLayer:AddWindow('BROWSE_COL' , 'BROWSE_WINDOW' , STR0009, 100, .T., .T.,, 'BROWSE',)      // 'Monitoramento de Fábrica Detalhe'
	oFWLayer:AddWindow('GRAFICO_COL', 'GRAFICO_WINDOW', STR0010, 100, .T., .T.,, 'GRAFICO',)     // 'Detalhe Indicador'
		
	oLayerBrowse  := oFWLayer:GetWinPanel ( 'BROWSE_COL' , 'BROWSE_WINDOW' , 'BROWSE' )
	oLayerGrafico := oFWLayer:GetWinPanel ( 'GRAFICO_COL', 'GRAFICO_WINDOW', 'GRAFICO' )
	
	// Painéis com o detalhamento do gráfico 
   	oPanelCombo := tPanel():New(0,0,"",oLayerGrafico,,,,/*CLR_YELLOW*/,SetTransparentColor(CLR_WHITE, 1),00,20)
 	oPanelCombo:Align:= CONTROL_ALIGN_TOP
 	
   	oFWLayerCombo := FWLayer():New()
	oFWLayerCombo:Init( oPanelCombo, .F.)
	oFWLayerCombo:addCollumn( 'COMBO', 50, .T.)
	oFWLayerCombo:addCollumn( 'INFO1', 25, .T.)
	oFWLayerCombo:addCollumn( 'INFO2', 25, .T.)
 	
   	// Combobox de escolha do indicador
   	@ 5,1  Say STR0011 Of oFWLayerCombo:GetColPanel('COMBO') COLOR CLR_BLACK Pixel
   	cCombo1 := cCombo[1]
   	oCombo1 := TComboBox():New( 3, 30, { |u| If( PCount() > 0, cCombo1 := u, cCombo1 ) }, cCombo, 60, 20, oFWLayerCombo:GetColPanel('COMBO'),,;
   								{ || SFCC511COM(cCombo, aPainel) },,,, .T.,,,,,,,,, 'cCombo1' )	
	
	// Browse Principal (Parte Superior)
	oBrowse := SFCXAUXCRI( oLayerBrowse, cTabBrw, "cTabBrw", DefTabBrw(), .F., .F. )
	oBrowse:SetChange( {|| SFCC511COM(cCombo, aPainel) } )
	                                   
	// Parte Interior
	For nI := 1 to 5
		// Cria Painel
		aPainel[nI] := TPanel():New(0,20,,oLayerGrafico,,,,/*CLR_YELLOW*/,SetTransparentColor(CLR_WHITE, 1),00,00)
 		aPainel[nI]:Align := CONTROL_ALIGN_ALLCLIENT
 	
   		// Layers do detalhamento: Gráfico, Faixa e Grid
	   	aFWLayer[nI] := FWLayer():New()
		aFWLayer[nI]:Init( aPainel[nI], .F.)
		aFWLayer[nI]:AddCollumn( 'GRAFICO', 25, .T.)
		aFWLayer[nI]:AddCollumn( 'FAIXA'  , 25, .T.) 
		If nI == 1
			aFWLayer[nI]:AddCollumn( 'DETALHE1', 25, .T.)
			aFWLayer[nI]:AddCollumn( 'DETALHE2', 25, .T.) 
		Else
			aFWLayer[nI]:AddCollumn( 'DETALHE' , 50, .T.)
		EndIf
		
		// Gráficos
		oFWChart[nI] := FWChartFactory():New()
   		oFWChart[nI] := oFWChart[nI]:getInstance( BARCHART )
		oFWChart[nI]:Init( aFWLayer[nI]:GetColPanel('GRAFICO'), .T., .T. )
		oFWChart[nI]:setLegend( CONTROL_ALIGN_TOP )
       	
       	// Faixa  
       	For nJ := 1 to 3
       		oFaixa[nJ][nI] := TSay():New( nJ*nFator, 01, { || SPACE(40) }, aFWLayer[nI]:GetColPanel('FAIXA') )
       	Next
	Next

	// Labels dos Browses de Detalhe
	oPanelInfo1 := TPanel():New(0,0,STR0017,oFWLayerCombo:GetColPanel('INFO1'),,.T.,,CLR_BLACK,15524046,0,12) // "Projetado"
	oPanelInfo1:Align := CONTROL_ALIGN_BOTTOM
	oPanelInfo2 := TPanel():New(0,0,STR0018,oFWLayerCombo:GetColPanel('INFO2'),,.T.,,CLR_BLACK,15524046,0,12) // "Realizado"
	oPanelInfo2:Align := CONTROL_ALIGN_BOTTOM
	
	// Browsers de detalhe
    oBrwBTS_Proj  := CriaGrid( aFWLayer[1]:GetColPanel('DETALHE1'), "cSwBTS_Proj" , DefBTSProj()[1]  )
	oBrwBTS_Real  := CriaGrid( aFWLayer[1]:GetColPanel('DETALHE2'), "cSwBTS_Real" , DefBTSProj()[1]  )
	oBrwNEE  	  := CriaGrid( aFWLayer[2]:GetColPanel('DETALHE') , "cSwNEE"      , DefNEE()[1]      )
	oBrwOEE  	  := CriaGrid( aFWLayer[3]:GetColPanel('DETALHE') , "cTabOEE"     , DefOEE()[1]      )
	oBrwTEEP	  := CriaGrid( aFWLayer[4]:GetColPanel('DETALHE') , "cSwTEEP"	  , DefTEEP()[1] 	 )
	oBrwTk   	  := CriaGrid( aFWLayer[5]:GetColPanel('DETALHE') , "cSwTk"       , DefTk()[1]       )
	
	// Ativa o Browser Principal
	oBrowse:Activate()
	oCombo1:Select( nPos )
	
Activate MsDialog oDlgPrincDet Centered On Init EnchoiceBar( oDlgPrincDet, { || oDlgPrincDet:End() }, { || oDlgPrincDet:End() },,@aButtons,,,,,, .F. )
	
oTabBrw:Delete()
oTabBTS_Proj:Delete()
oTabBTS_Real:Delete()
oTabNEE:Delete()
oTabOEE:Delete()
oTabTEEP:Delete()
oTabTk:Delete()
oSwBTS_Proj:Delete()
oSwBTS_Real:Delete()
oSwNEE:Delete()
oSwTEEP:Delete()
oSwTk:Delete()
	
Return NIL
//-------------------------------------------------------------------------------
Static Function Imprimi(cMeta,cDataRef,cHoraRef,cIniMQ,cFimMQ)
Default lAutoMacao := .F.

	cQuery := "SELECT CZ5.* FROM " + RetSQLName( 'CZ5' ) + " CZ5 "
	cQuery += "	INNER JOIN  " + RetSQLName( 'CY5' )  + " CY5 ON CY5.CY5_IDMEPO = CZ5.CZ5_IDMEPO "
	cQuery += "WHERE "
	cQuery += "	CY5.CY5_FILIAL = '" + xFilial('CY5')+ "' AND "
	cQuery += "	CY5.CY5_CDMEPO = '" + cMeta	+ "' AND "
	cQuery += "	CY5.D_E_L_E_T_ = ' ' AND "
	cQuery += "	CZ5.CZ5_FILIAL = '" + xFilial('CZ5')+ "' AND "
	cQuery += "	CZ5.CZ5_CDMQ  >= '" + cIniMQ		+ "' AND "
	cQuery += "	CZ5.CZ5_CDMQ  <= '" + cFimMQ		+ "' AND "
	cQuery += "	CZ5.CZ5_DTRE   = '" + cDataRef		+ "' AND "
	cQuery += "	CZ5.CZ5_HRRE   = '" + cHoraRef		+ "' AND "
	cQuery += "	CZ5.D_E_L_E_T_ = ' '"

	cCZ5   := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cCZ5, .T., .F. )
	IF !lAutoMacao
		SFCXExpTab(,,,cCZ5)
	ENDIF

Return Nil
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaFaixas
Atualiza as faixas conforme indicado

@author Israel A Possoli
@since 13/04/2011
@version 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtualizaFaixas( aFaixa )
Local nPanel := 1
Default lAutoMacao := .F.
	
If aFaixa[1]
	If Val(aFaixa[3]) == 8 // BTS
		nPanel := 1
	ElseIf Val(aFaixa[3]) == 7	// NEE
		nPanel := 2
	ElseIf Val(aFaixa[3]) == 8 // OEE
 		nPanel := 3
	ElseIf Val(aFaixa[3]) == 9 // TEEP
		nPanel := 4
	ElseIf Val(aFaixa[3]) == 14 // TK 
		nPanel := 5
	EndIf

	IF !lAutoMacao
		// Atualiza faixas
		oFaixa[1][nPanel]:SetText(aFaixa[09] + "  " + aFaixa[4] + " - " + aFaixa[5])
		oFaixa[2][nPanel]:SetText(aFaixa[10] + "  " + aFaixa[5] + " - " + aFaixa[6])
		oFaixa[3][nPanel]:SetText(aFaixa[11] + "  " + aFaixa[6] + " - " + aFaixa[7])
	ENDIF
Else
	For nPanel := 1 to 5
		oFaixa[1][nPanel]:SetText( STR0019 ) // "Sem faixa Cadastrada"
		oFaixa[2][nPanel]:SetText("")
		oFaixa[3][nPanel]:SetText("")   
	Next
EndIf	
	      
Return Nil                                                                
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaGrafico
Atualização do gráfico do indicador

@author Israel A Possoli
@since 22/03/2011
@version 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtualizaGrafico( aFaixa )
Local nValores := { (cTabBrw)->VLQL,   (cTabBrw)->VLQLRY, (cTabBrw)->VLEF , (cTabBrw)->VLUT, ;
					(cTabBrw)->VLDIRY, (cTabBrw)->VLDIPL, (cTabBrw)->VLNEE, (cTabBrw)->VLOEE, (cTabBrw)->VLTEEP, ;
					(cTabBrw)->BTS_V,  (cTabBrw)->BTS_M,  (cTabBrw)->BTS_S, (cTabBrw)->VLBTS, (cTabBrw)->VLTK }    
Local aFaixas  := SFCXFAIXA( aFaixa[2] )
Local nPanel   := 0
Local cTipo    := ''  
Local nValor   := 0

If aFaixas[1]
	If Val(aFaixas[3]) == 13 	// BTS
		nPanel := 1  
		cTipo  := aFaixas[2] 
		nValor := (cTabBrw)->VLBTS 
	ElseIf Val(aFaixas[3]) == 7	// NEE
		nPanel := 2 
		cTipo  := aFaixas[2]    
		nValor := (cTabBrw)->VLNEE
	ElseIf Val(aFaixas[3]) == 8 // OEE
 		nPanel := 3  
 		cTipo  := aFaixas[2]
 		nValor := (cTabBrw)->VLOEE
	ElseIf Val(aFaixas[3]) == 9 // TEEP
		nPanel := 4  
		cTipo  := aFaixas[2]        
		nValor := (cTabBrw)->VLTEEP
	ElseIf Val(aFaixas[3]) == 14 // TK 
		nPanel := 5      
		cTipo  := aFaixas[2]  
		nValor := (cTabBrw)->VLTK
	EndIf

	If nPanel > 0 .And. nPanel < 6
		oFWChart[nPanel]:Reset()  
		oFWChart[nPanel]:SetTitle( AllTrim(aFaixas[2]) + SPACE(1) + cValToChar(nValor) + SPACE(1) + aFaixas[8], CONTROL_ALIGN_CENTER)
		If nPanel < 5
			SFCXIndSon( cTipo, oFWChart[nPanel], nValores ) 
		Else
			oFWChart[nPanel]:AddSerie( STR0027, (cTabBrw)->VLTKPL ) // "Projetado"
			oFWChart[nPanel]:AddSerie( STR0028, (cTabBrw)->VLTK )   // "Real"
		EndIf
		oFWChart[nPanel]:setMask( "*@* " + aFaixas[8] )
		oFWChart[nPanel]:Build()  
		oFWChart[nPanel]:Refresh()                					
	EndIf
EndIf
	
Return Nil 
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaDados
Atualização os dados da grid conforme máquina selecionada

@author Israel A Possoli
@since 27/04/2011
@version 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtualizaDados( aFaixa )
Local cCDMQ  := (cTabBrw)->CDMQ 
	
Do Case
	Case Val(aFaixa[3]) == 13 // BTS        
    	dbSelectArea( cSwBTS_Proj )
 		ZAP         
		dbSelectArea( cTabBTS_Proj )
		dbGoTop()
   		While !Empty((cTabBTS_Proj)->CDMQ)
   			If (cTabBTS_Proj)->CDMQ == cCDMQ
				RecLock(cSwBTS_Proj, .T.)
				(cSwBTS_Proj)->CDMQ			:= (cTabBTS_Proj)->CDMQ
			 	(cSwBTS_Proj)->SEQ 			:= (cTabBTS_Proj)->SEQ 
				(cSwBTS_Proj)->ITEM			:= (cTabBTS_Proj)->ITEM
				(cSwBTS_Proj)->QUANTIDADE   := (cTabBTS_Proj)->QUANTIDADE
				MsUnlock()   
			EndIf
			(cTabBTS_Proj)->(dbSkip())
		End
		oBrwBTS_Proj:Refresh()
		oBrwBTS_Proj:GoTop()
	
		dbSelectArea( cSwBTS_Real )
 		ZAP        
		dbSelectArea( cTabBTS_Real )
		dbGoTop()
   		While !Empty((cTabBTS_Real)->CDMQ) 
   			If (cTabBTS_Real)->CDMQ == cCDMQ
				RecLock(cSwBTS_Real, .T.)
				(cSwBTS_Real)->CDMQ			:= (cTabBTS_Real)->CDMQ
				(cSwBTS_Real)->SEQ 			:= (cTabBTS_Real)->SEQ 
				(cSwBTS_Real)->ITEM			:= (cTabBTS_Real)->ITEM
				(cSwBTS_Real)->QUANTIDADE   := (cTabBTS_Real)->QUANTIDADE
				MsUnlock()  
			EndIf
			(cTabBTS_Real)->(dbSkip())
		End
		oBrwBTS_Real:Refresh()
		oBrwBTS_Real:GoTop()  
	
	Case Val(aFaixa[3]) == 7  // NEE 
		dbSelectArea( cSwNEE )
 		ZAP         
		dbSelectArea( cTabNEE )
		dbGoTop()
   		While !Empty((cTabNEE)->CDMQ)
   			If (cTabNEE)->CDMQ == cCDMQ	
				RecLock(cSwNEE, .T.)
				(cSwNEE)->CDMQ			:= (cTabNEE)->CDMQ
				(cSwNEE)->ITEM 			:= (cTabNEE)->ITEM
				(cSwNEE)->TEMPO			:= (cTabNEE)->TEMPO
				(cSwNEE)->QUANT_PROJ    := (cTabNEE)->QUANT_PROJ
				(cSwNEE)->QUANT_REAL    := (cTabNEE)->QUANT_REAL
				(cSwNEE)->REFUGO    	:= (cTabNEE)->REFUGO
				(cSwNEE)->RETRAB    	:= (cTabNEE)->RETRAB
				MsUnlock()   
			EndIf
			(cTabNEE)->(dbSkip())
		End
		oBrwNEE:Refresh()
		oBrwNEE:GoTop()  
	
	Case Val(aFaixa[3]) == 8  // OEE
	   oBrwOEE:GoTop()
	
	Case Val(aFaixa[3]) == 9  // TEEP 
		dbSelectArea( cSwTEEP )
 		ZAP         
		dbSelectArea( cTabTEEP )
		dbGoTop()
   		While !Empty((cTabTEEP)->CDMQ)
   			If (cTabTEEP)->CDMQ == cCDMQ
				RecLock(cSwTEEP, .T.)
				(cSwTEEP)->CDMQ			:= (cTabTEEP)->CDMQ
			   	(cSwTEEP)->ITEM 		:= (cTabTEEP)->ITEM
				(cSwTEEP)->TEMPO		:= (cTabTEEP)->TEMPO
				(cSwTEEP)->UNIDADE      := (cTabTEEP)->UNIDADE
				(cSwTEEP)->CAPACIDADE   := (cTabTEEP)->CAPACIDADE
				(cSwTEEP)->QUANTIDADE  	:= (cTabTEEP)->QUANTIDADE
				MsUnlock() 
			EndIf
			(cTabTEEP)->(dbSkip())
		End
		oBrwTEEP:Refresh()
		oBrwTEEP:GoTop()  

	Case Val(aFaixa[3]) == 14 // TK 
		dbSelectArea( cSwTk )
 		ZAP      
		dbSelectArea( cTabTk )
		dbGoTop()
   		While !Empty((cTabTk)->CDMQ)
   			If (cTabTk)->CDMQ == cCDMQ
				RecLock(cSwTk, .T.)
				(cSwTk)->CDMQ			:= (cTabTk)->CDMQ
				(cSwTk)->CAPAC_PROJ		:= (cTabTk)->CAPAC_PROJ				
			   	(cSwTk)->CAPAC_REAL		:= (cTabTk)->CAPAC_REAL
			   	(cSwTk)->QUANT_PROJ 	:= (cTabTk)->QUANT_PROJ
			   	(cSwTk)->QUANT_REAL     := (cTabTk)->QUANT_REAL
				MsUnlock()                 
			EndIf
			(cTabTk)->(dbSkip())
		End  
		oBrwTk:Refresh()
		oBrwTk:GoTop()  
EndCase
	
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCC511COM
Mudança do Combobox

@author Israel A Possoli
@since 22/03/2011
@version 
/*/
//-------------------------------------------------------------------
Static Function SFCC511COM( cCombo, aPainel )
Local nI        
Local aFaixa   := SFCXFAIXAMAQ( (cTabBrw)->IDMEPO, Substr(cCombo[oCombo1:nAt], RAT('=', cCombo[oCombo1:nAt])+1 ) )

// Oculta abas
For nI := 1 to 5
	aPainel[nI]:Hide()
Next

// Atualiza dados
AtualizaGrafico( aFaixa )
AtualizaDados( aFaixa )
AtualizaFaixas( aFaixa )

// Mostra abas
If Val(aFaixa[3]) == 13 // BTS
	aPainel[1]:Show()		
ElseIf Val(aFaixa[3]) == 7  // NEE
	aPainel[2]:Show()
ElseIf Val(aFaixa[3]) == 8  // OEE
	aPainel[3]:Show()
ElseIf Val(aFaixa[3]) == 9  // TEEP
	aPainel[4]:Show()
ElseIf Val(aFaixa[3]) == 14 // TK
	aPainel[5]:Show()
EndIf
	
Return Nil 
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaDados
Obtem os dados necessários para preenchimento das tabelas temporárias que serão usadas

@author Israel A Possoli
@since 22/03/2011
@version 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function CarregaDados( aFiltro )
Local cQuery := ''
Local cTable := ''
Local aArea  := GetArea()
	
cQuery := "SELECT * FROM " + RetSQLName( 'CZ4' )  + " CZ4 "
cQuery += "  INNER JOIN  " + RetSQLName( 'CY5' )  + " CY5 ON CY5.CY5_IDMEPO = CZ4.CZ4_IDMEPO"
cQuery += "  WHERE CZ4.CZ4_FILIAL = '" + xFilial('CZ4') + "' AND CY5.CY5_CDMEPO = '" + aFiltro[9]  + "' AND "
cQuery += "        CY5.CY5_FILIAL = '" + xFilial('CY5') + "' AND CY5.D_E_L_E_T_ = ' ' AND "
cQuery += "        CZ4_CDES      >= '" + aFiltro[1]     + "' AND CZ4_CDES      <= '" + aFiltro[2]  + "' AND "
cQuery += "		   CZ4_CDARPO    >= '" + aFiltro[3]     + "' AND CZ4_CDARPO    <= '" + aFiltro[4]  + "' AND "
cQuery += "		   CZ4_CDCETR    >= '" + aFiltro[5]     + "' AND CZ4_CDCETR    <= '" + aFiltro[6]  + "' AND "
cQuery += "		   CZ4_CDMQ      >= '" + aFiltro[7]     + "' AND CZ4_CDMQ      <= '" + aFiltro[8]  + "' AND "
cQuery += "        CZ4_DTRE       = '" + aFiltro[10]    + "' AND CZ4_HRRE       = '" + aFiltro[11] + "' AND "
cQuery += "        CZ4.D_E_L_E_T_ = ' ' "
cTable := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTable, .T., .F. )
	
While( (cTable)->(!EOF()) ) 
	// Browse Principal
	RecLock((cTabBrw), .T.)
	(cTabBrw)->DTRE		:= STOD((cTable)->CZ4_DTRE)
	(cTabBrw)->HRRE		:= (cTable)->CZ4_HRRE
	(cTabBrw)->IDMEPO	:= (cTable)->CZ4_IDMEPO
	(cTabBrw)->CDES 	:= (cTable)->CZ4_CDES
	(cTabBrw)->CDARPO 	:= (cTable)->CZ4_CDARPO
	(cTabBrw)->CDCETR 	:= (cTable)->CZ4_CDCETR
	(cTabBrw)->CDMQ		:= (cTable)->CZ4_CDMQ
	(cTabBrw)->QTVMPL	:= ROUND((cTable)->CZ4_QTVMPL,2)
	(cTabBrw)->QTVMEV	:= ROUND((cTable)->CZ4_QTVMEV,2)
	(cTabBrw)->QTVMRY	:= ROUND((cTable)->CZ4_QTVMRY,2)
	(cTabBrw)->VLDIRY	:= ROUND((cTable)->CZ4_VLDIRY,2)
	(cTabBrw)->VLDIPL	:= ROUND((cTable)->CZ4_VLDIPL,2)
	(cTabBrw)->VLUT		:= ROUND((cTable)->CZ4_VLUT,2)
	(cTabBrw)->VLQL		:= ROUND((cTable)->CZ4_VLQL,2)
	(cTabBrw)->VLQLRY	:= ROUND((cTable)->CZ4_VLQLRY,2)
	(cTabBrw)->VLEF		:= ROUND((cTable)->CZ4_VLEF,2)
	(cTabBrw)->VLNEE	:= ROUND((cTable)->CZ4_VLNEE,2)
	(cTabBrw)->VLOEE	:= ROUND((cTable)->CZ4_VLOEE,2)
	(cTabBrw)->VLBTS	:= ROUND((cTable)->CZ4_VLBTS,2)
	(cTabBrw)->VLTK		:= ROUND((cTable)->CZ4_VLTK,2)
	(cTabBrw)->VLTEEP	:= ROUND((cTable)->CZ4_VLTEEP ,2)
	(cTabBrw)->BTS_S	:= ROUND((cTable)->CZ4_VLBTSS,2)
	(cTabBrw)->BTS_V	:= ROUND((cTable)->CZ4_VLBTSV,2)
	(cTabBrw)->BTS_M	:= ROUND((cTable)->CZ4_VLBTSM,2)
	(cTabBrw)->VLTKPL   := Round( If((cTable)->CZ4_QTRPPL > 0, (cTable)->CZ4_QTVMPL*60/(cTable)->CZ4_QTRPPL, 0 ), 2 ) 
	(cTabBrw)->RECNUM   := (cTable)->R_E_C_N_O_
	MsUnlock()
		
	// Eficiência Geral (OEE)
	RecLock(cTabOEE, .T.)
	(cTabOEE)->CDMQ	   		:= (cTable)->CZ4_CDMQ
	(cTabOEE)->CAPAC_PROJ 	:= ROUND((cTable)->CZ4_QTVMPL,2)
	(cTabOEE)->CAPAC_REAL 	:= ROUND((cTable)->CZ4_QTVMRY,2)
	(cTabOEE)->EFICIENCIA	:= ROUND((cTable)->CZ4_VLEF,2)
	(cTabOEE)->PARADA 		:= ROUND((cTable)->CZ4_QTTESP,2)
	MsUnlock()

	(cTable)->(dbSkip())
End
(cTable)->( dbCloseArea() )
	
cQuery := " SELECT * FROM " + RetSQLName( 'CY4' ) + " CY4 "
cQuery += "    INNER JOIN " + RetSQLName( 'CZ4' ) + " CZ4 ON"
cQuery += " 		 CY4.CY4_DTRE   = CZ4.CZ4_DTRE   AND"
cQuery += " 		 CY4.CY4_HRRE   = CZ4.CZ4_HRRE   AND"
cQuery += " 		 CY4.CY4_IDMEPO = CZ4.CZ4_IDMEPO "
cQuery += "    WHERE CZ4.CZ4_FILIAL = '" + xFilial('CZ4') + "' AND "
cQuery += "          CY4.CY4_FILIAL = '" + xFilial('CY4') + "' AND "
cQuery += " 	     CZ4.CZ4_DTRE   = '" + aFiltro[10]    + "' AND "
cQuery += "          CZ4.CZ4_HRRE   = '" + aFiltro[11]    + "' AND "
cQuery += "          CZ4.D_E_L_E_T_ = ' ' AND CY4.D_E_L_E_T_ = ' ' "
cTable := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTable, .T., .F. )
		
While( (cTable)->(!EOF()) )
	If !Empty((cTabBrw)->IDMEPO)  
		// Acompanhamento de Produção Projetado (BTS)
		RecLock(cTabBTS_Proj, .T.)
		(cTabBTS_Proj)->CDMQ		:= (cTable)->CY4_CDMQ
		(cTabBTS_Proj)->SEQ  		:= (cTable)->CY4_NRSQME
		(cTabBTS_Proj)->ITEM 		:= (cTable)->CY4_CDAC
		(cTabBTS_Proj)->QUANTIDADE	:= ROUND((cTable)->CY4_QTPLAT,2)
		MsUnlock()
	EndIf
	(cTable)->( dbSkip() )
End
(cTable)->( dbCloseArea() )
			
cQuery := " SELECT * FROM " + RetSQLName( 'CZ5' ) + " CZ5 " 
cQuery += "    INNER JOIN " + RetSQLName( 'CZ4' ) + " CZ4 ON "  
cQuery += "		     CZ5.CZ5_DTRE   = CZ4.CZ4_DTRE   AND "
cQuery += "		     CZ5.CZ5_HRRE   = CZ4.CZ4_HRRE   AND "
cQuery += "	  	     CZ5.CZ5_IDMEPO = CZ4.CZ4_IDMEPO "
cQuery += "    WHERE CZ4.CZ4_FILIAL = '" + xFilial('CZ4') + "' AND "
cQuery += "          CZ5.CZ5_FILIAL = '" + xFilial('CZ5') + "' AND "
cQuery += " 		 CZ4.CZ4_DTRE   = '" + aFiltro[10]    + "' AND "
cQuery += "		     CZ4.CZ4_HRRE   = '" + aFiltro[11]    + "' AND "
cQuery += "		     CZ5.CZ5_TPMV   = '1' AND "
cQuery += "		     CZ5.D_E_L_E_T_ = ' ' AND CZ4.D_E_L_E_T_ = ' '"    
cTable := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTable, .T., .F. )
	
While( (cTable)->(!EOF()) )
	// Acompanhamento de Produção Realizado (BTS)
	If !Empty((cTable)->CZ5_NRSQME)
		RecLock(cTabBTS_Real, .T.)
		(cTabBTS_Real)->CDMQ		:= (cTable)->CZ5_CDMQ				
		(cTabBTS_Real)->SEQ  		:= (cTable)->CZ5_NRSQME
		(cTabBTS_Real)->ITEM 		:= (cTable)->CZ5_CDAC
		(cTabBTS_Real)->QUANTIDADE 	:= ROUND((cTable)->CZ5_QTRP,2)
		MsUnlock()
	EndIf
	(cTable)->( dbSkip() )
End  
(cTable)->( dbCloseArea() )
	
cQuery := " SELECT CZ5.CZ5_CDAC, CZ5.CZ5_CDMQ, "
cQuery += "		   SUM(CZ5.CZ5_HRTEAT) AS CZ5_HRTEAT, " 
cQuery += " 	   SUM(CZ5.CZ5_QTRPPL) AS CZ5_QTRPPL, "
cQuery += "        SUM(CZ5.CZ5_QTRP)   AS CZ5_QTRP, "
cQuery += "		   SUM(CZ5.CZ5_QTRF)   AS CZ5_QTRF, "
cQuery += "		   SUM(CZ5.CZ5_QTRT)   AS CZ5_QTRT  "
cQuery += " 	   FROM " + RetSQLName( 'CZ5' ) + " CZ5 "
cQuery += "  INNER JOIN " + RetSQLName( 'CZ4' ) + " CZ4 ON "
cQuery += "		   CZ5.CZ5_DTRE   = CZ4.CZ4_DTRE AND "
cQuery += "		   CZ5.CZ5_HRRE   = CZ4.CZ4_HRRE AND "
cQuery += "		   CZ5.CZ5_IDMEPO = CZ4.CZ4_IDMEPO "
cQuery += "  INNER JOIN " + RetSQLName( 'CY5' ) + " CY5 ON "
cQuery += "		   CY5.CY5_IDMEPO = CZ4.CZ4_IDMEPO "	
cQuery += "  WHERE CZ4.CZ4_FILIAL = '" + xFilial('CZ4') + "' AND "
cQuery += " 	   CZ5.CZ5_FILIAL = '" + xFilial('CZ5') + "' AND "	
cQuery += " 	   CY5.CY5_FILIAL = '" + xFilial('CY5') + "' AND "	
cQuery += " 	   CZ4.CZ4_DTRE   = '" + aFiltro[10]    + "' AND "
cQuery += "        CZ4.CZ4_HRRE   = '" + aFiltro[11]    + "' AND "
cQuery += " 	   CY5.CY5_CDMEPO = '" + aFiltro[9]     + "' AND "
cQuery += "		  (CZ5.CZ5_TPMV   = '4' OR CZ5.CZ5_TPMV = '1') AND "
cQuery += " 	   CZ4.D_E_L_E_T_ = ' ' AND CZ5.D_E_L_E_T_ = ' ' AND CY5.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY CZ5.CZ5_CDAC, CZ5.CZ5_CDMQ "
cQuery += " ORDER BY CZ5.CZ5_CDAC"      
cTable := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTable, .T., .F. )
	   
While( (cTable)->(!EOF()) )
	// Eficiência Líquida (NEE)
	If !Empty( (cTable)->CZ5_CDAC )
		RecLock(cTabNEE, .T.)
		(cTabNEE)->CDMQ	      	:= (cTable)->CZ5_CDMQ					
		(cTabNEE)->ITEM 		:= (cTable)->CZ5_CDAC
		(cTabNEE)->TEMPO 		:= (cTable)->CZ5_HRTEAT
		(cTabNEE)->QUANT_PROJ 	:= ROUND((cTable)->CZ5_QTRPPL,2)
		(cTabNEE)->QUANT_REAL   := ROUND((cTable)->CZ5_QTRP,2)
		(cTabNEE)->REFUGO 		:= ROUND((cTable)->CZ5_QTRF,2)
		(cTabNEE)->RETRAB 		:= ROUND((cTable)->CZ5_QTRT,2)
		MsUnlock()	
	EndIf           
	(cTable)->(dbSkip())
End
(cTable)->(dbCloseArea())	
	
cQuery := " SELECT CZ5.CZ5_CDAC, CZ4.CZ4_QTVMRY, CZ4.CZ4_QTVMPL, CZ5.CZ5_CDMQ, "
cQuery += "        SUM(CZ5.CZ5_QTTEPL) AS CZ5_QTTEPL,	"
cQuery += "        SUM(CZ5.CZ5_QTRPPL) AS CZ5_QTRPPL,	"
cQuery += "        SUM(CZ5.CZ5_QTRPEV) AS CZ5_QTRPEV,	"
cQuery += "        SUM(CZ5.CZ5_QTRP) AS CZ5_QTRP 		"
cQuery += " 	  FROM " + RetSQLName( 'CZ5' ) + " CZ5 " 
cQuery += " INNER JOIN " + RetSQLName( 'CZ4' ) + " CZ4 ON "	
cQuery += "       CZ5.CZ5_DTRE   = CZ4.CZ4_DTRE AND "
cQuery += "       CZ5.CZ5_HRRE   = CZ4.CZ4_HRRE AND " 
cQuery += "       CZ5.CZ5_IDMEPO = CZ4.CZ4_IDMEPO   "
cQuery += " INNER JOIN " + RetSQLName( 'CY5' ) + " CY5 ON "
cQuery += "		  CY5.CY5_IDMEPO = CZ4.CZ4_IDMEPO "	
cQuery += " WHERE CZ4.CZ4_FILIAL = '" + xFilial('CZ4') + "' AND "
cQuery += "       CZ5.CZ5_FILIAL = '" + xFilial('CZ5') + "' AND "	
cQuery += " 	  CY5.CY5_FILIAL = '" + xFilial('CY5') + "' AND "
cQuery += " 	  CZ4.CZ4_DTRE   = '" + aFiltro[10]    + "' AND "
cQuery += "       CZ4.CZ4_HRRE   = '" + aFiltro[11]    + "' AND "
cQuery += " 	  CY5.CY5_CDMEPO = '" + aFiltro[9]     + "' AND "    
cQuery += "       CZ5.CZ5_TPMV   = '1' AND "
cQuery += "       CZ4.D_E_L_E_T_ = ' ' AND CZ5.D_E_L_E_T_ = ' ' AND CY5.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY CZ5.CZ5_CDMQ, CZ5_CDAC, CZ4.CZ4_QTVMRY, CZ4.CZ4_QTVMPL  "
cQuery += " ORDER BY CZ5.CZ5_CDAC "    
cTable := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTable, .T., .F. )                                  
	
While( (cTable)->(!EOF()) )
	// Produtividade (TEEP)
	RecLock(cTabTEEP, .T.)
	(cTabTEEP)->CDMQ		:= (cTable)->CZ5_CDMQ
	(cTabTEEP)->CAPACIDADE	:= ROUND( (cTable)->CZ4_QTVMRY, 2 )
   	(cTabTEEP)->ITEM 	  	:= (cTable)->CZ5_CDAC
	(cTabTEEP)->TEMPO		:= ROUND( (cTable)->CZ5_QTTEPL, 2 )  
	(cTabTEEP)->QUANTIDADE  := ROUND( (cTable)->CZ5_QTRP,   2 )  
	(cTabTEEP)->UNIDADE   	:= POSICIONE("CZ3",1,XFILIAL("CZ3")+(cTable)->CZ5_CDAC, "CZ3_CDUN")
	MsUnlock() 
	
	// Takt Time (Tk)                     
	RecLock(cTabTk, .T.)
	(cTabTk)->CDMQ			:= (cTable)->CZ5_CDMQ					
	(cTabTk)->CAPAC_PROJ	:= ROUND( (cTable)->CZ4_QTVMPL, 2 )				
	(cTabTk)->CAPAC_REAL	:= ROUND( (cTable)->CZ4_QTVMRY, 2 )
	(cTabTk)->QUANT_PROJ 	:= ROUND( (cTable)->CZ5_QTRPPL, 2 )
	(cTabTk)->QUANT_REAL 	:= ROUND( (cTable)->CZ5_QTRP,   2 )
	MsUnlock()
	
	(cTable)->(dbSkip())
End
(cTable)->(dbCloseArea())	

RestArea( aArea )
	
Return Nil 
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TelasAnalises
Chama as telas de Análises

@param	  cTela		(Obrigatório) Nome da Tela que será chamada

@author Israel A Possoli
@since 14/04/2011
@version 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TelasAnalises(cTela)
	
	&(cTela + "(" + cValToChar( (cTabBrw)->RECNUM ) + ")")

Return Nil
//-------------------------------------------------------------------------------
/* Cria a Grid Genericamente

@author Israel A Possoli
@since 22/03/2011
@version 
/*/
//-------------------------------------------------------------------------------
Static Function CriaGrid(oParent, cTab, cTabDef)
	
	Local aGrid       := TCBrowse():New(0,0,0,0,,,,oParent,,,,,,,,,,,,.F.,&("(" + cTab +")"),.T.,,.F.,,, )
	aGrid:Align       := CONTROL_ALIGN_ALLCLIENT
	aGrid:nScrollType := 0
	ColunasGrid(aGrid, cTab, cTabDef) 
	  
Return aGrid
//-------------------------------------------------------------------------------
/* Adiciona as colunas em um Grid com base na definição da tabela

@author Israel A Possoli
@since 22/03/2011
@version 
/*/
//-------------------------------------------------------------------------------
Static Function ColunasGrid(oGrid, cAlias, aTab)
	Local nCount  := 0
	
	For nCount := 1 To Len(aTab)
		If ( Len(aTab[nCount]) == 7 .AND. aTab[nCount,6] == .T.) .OR. Len(aTab[nCount]) < 6
			oGrid:AddColumn(TCColumn():New(aTab[nCount,5] ,&('{|| (' + cAlias + ')->' + aTab[nCount,1] + '}'),aTab[nCount,7],,,'LEFT',,.F.,.F.,,,,.F.,))		
		EndIf
	Next nCount
	
Return
//-------------------------------------------------------------------------------
/* Definição das Temp Tables

@author Israel A Possoli
@since 22/03/2011
@version 
/*/
//-------------------------------------------------------------------------------
Static Function DefTabBrw()
Local aDBF   := { { "DTRE"	    , "D", TamSX3("CZ4_DTRE")[1]  , TamSX3("CZ4_DTRE")[2]  , STR0029, .T., X3Picture("CZ4_DTRE")   } , ;    // "Data Referência"
				  { "HRRE"	    , "C", TamSX3("CZ4_HRRE")[1]  , TamSX3("CZ4_HRRE")[2]  , STR0030, .T., X3Picture("CZ4_HRRE")   } , ;    // "Hora Referência"
				  { "IDMEPO"	, "C", TamSX3("CZ4_IDMEPO")[1], TamSX3("CZ4_IDMEPO")[2], STR0031, .T., X3Picture("CZ4_IDMEPO") } , ;    // "ID Meta"
  				  { "CDES"  	, "C", TamSX3("CZ4_CDES")[1]  , TamSX3("CZ4_CDES")[2]  , STR0032, .T., X3Picture("CZ4_CDES")   } , ;    // "Estabelecimento"
				  { "CDARPO"	, "C", TamSX3("CZ4_CDARPO")[1], TamSX3("CZ4_CDARPO")[2], STR0033, .T., X3Picture("CZ4_CDARPO") } , ;    // "Área de Produção"
				  { "CDCETR"	, "C", TamSX3("CZ4_CDCETR")[1], TamSX3("CZ4_CDCETR")[2], STR0034, .T., X3Picture("CZ4_CDCETR") } , ;    // "Centro de Trabalho"                 
				  { "CDMQ"  	, "C", TamSX3("CZ4_CDMQ")[1]  , TamSX3("CZ4_CDMQ")[2]  , STR0035, .T., X3Picture("CZ4_CDMQ"  ) } , ;    // "Máquina"
				  { "QTVMPL"	, "N", TamSX3("CZ4_QTVMPL")[1], TamSX3("CZ4_QTVMPL")[2], STR0036, .T., X3Picture("CZ4_QTVMPL") } , ;    // "Cap. Projetada"
				  { "QTVMEV"	, "N", TamSX3("CZ4_QTVMEV")[1], TamSX3("CZ4_QTVMEV")[2], STR0037, .T., X3Picture("CZ4_QTVMEV") } , ;    // "Cap. Efetiva"
				  { "QTVMRY"	, "N", TamSX3("CZ4_QTVMRY")[1], TamSX3("CZ4_QTVMRY")[2], STR0038, .T., X3Picture("CZ4_QTVMRY") } , ;    // "Cap. Real"
				  { "VLDIRY"	, "N", TamSX3("CZ4_VLDIRY")[1], TamSX3("CZ4_VLDIRY")[2], STR0025, .T., X3Picture("CZ4_VLDIRY") } , ;    // "Disp. Real"
				  { "VLDIPL"	, "N", TamSX3("CZ4_VLDIPL")[1], TamSX3("CZ4_VLDIPL")[2], STR0025, .F., X3Picture("CZ4_VLDIPL") } , ;    // "Disp. Planejado"
				  { "VLUT"	    , "N", TamSX3("CZ4_VLUT")[1]  , TamSX3("CZ4_VLUT")[2]  , STR0026, .T., X3Picture("CZ4_VLUT")   } , ;    // "Utilização"
				  { "VLQL" 	    , "N", TamSX3("CZ4_VLQL")[1]  , TamSX3("CZ4_VLQL")[2]  , STR0039, .T., X3Picture("CZ4_VLQL")   } , ;    // "Qualidade"
				  { "VLQLRY"    , "N", TamSX3("CZ4_VLQLRY")[1], TamSX3("CZ4_VLQLRY")[2], STR0023, .T., X3Picture("CZ4_VLQLRY") } , ;    // "Qualidade Real" 
				  { "VLEF"	    , "N", TamSX3("CZ4_VLEF")[1]  , TamSX3("CZ4_VLEF")[2]  , STR0024, .T., X3Picture("CZ4_VLEF")   } , ;    // "Eficiência"
				  { "VLNEE"     , "N", TamSX3("CZ4_VLNEE")[1] , TamSX3("CZ4_VLNEE")[2] , STR0013, .T., X3Picture("CZ4_VLNEE")  } , ;    // "NEE"
				  { "VLOEE"     , "N", TamSX3("CZ4_VLOEE")[1] , TamSX3("CZ4_VLOEE")[2] , STR0014, .T., X3Picture("CZ4_VLOEE")  } , ;    // "OEE"
				  { "VLBTS"     , "N", TamSX3("CZ4_VLBTS")[1] , TamSX3("CZ4_VLBTS")[2] , STR0012, .T., X3Picture("CZ4_VLBTS")  } , ;    // "BTS"
				  { "VLTK"      , "N", TamSX3("CZ4_VLTK")[1]  , TamSX3("CZ4_VLTK")[2]  , STR0016, .T., X3Picture("CZ4_VLTK")   } , ;    // "Tk"
				  { "VLTEEP"    , "N", TamSX3("CZ4_VLTEEP")[1], TamSX3("CZ4_VLTEEP")[2], STR0015, .T., X3Picture("CZ4_VLTEEP") } , ;    // "TEEP"	
				  { "BTS_S"     , "N", TamSX3("CZ4_VLBTSS")[1], TamSX3("CZ4_VLBTSS")[2], STR0020, .F., X3Picture("CZ4_VLBTSS") } , ;    // "BTS Sequência"
				  { "BTS_V"     , "N", TamSX3("CZ4_VLBTSV")[1], TamSX3("CZ4_VLBTSV")[2], STR0021, .F., X3Picture("CZ4_VLBTSV") } , ;    // "BTS Volume"
				  { "BTS_M"     , "N", TamSX3("CZ4_VLBTSM")[1], TamSX3("CZ4_VLBTSM")[2], STR0022, .F., X3Picture("CZ4_VLBTSM") } , ;    // "BTS Mix"
				  { "VLTKPL"    , "N", TamSX3("CZ4_VLTK")[1]  , TamSX3("CZ4_VLTK")[2]  , STR0040, .F., X3Picture("CZ4_VLTK")   } , ;    // "Tk Planejado"
				  { "RECNUM"    , "N", 15, 0, "R_E_C_N_O" , .F. , "@!" 			   } }  
Return { aDBF , {"DTRE", "HRRE", "CDMQ"} } 

//-------------------------------------------------------------------------------
// Temp Table Acompanhamento Projetado (BTS)
//-------------------------------------------------------------------------------
Static Function DefBTSProj()                                  
Local aDBF   := { { "CDMQ"  		, "C", TamSX3("CY4_CDMQ")[1]  , TamSX3("CY4_CDMQ")[2]  , STR0035, .F., X3Picture("CY4_CDMQ")   } , ; // "Máquina"
				  { "SEQ"       	, "C", TamSX3("CY4_NRSQME")[1], TamSX3("CY4_NRSQME")[2], STR0041, .T., X3Picture("CY4_NRSQME") } , ; // "Sequência"
				  { "ITEM"      	, "C", TamSX3("CY4_CDAC")[1]  , TamSX3("CY4_CDAC")[2]  , STR0042, .T., X3Picture("CY4_CDAC")   } , ; // "Item"
				  { "QUANTIDADE"	, "N", TamSX3("CY4_QTPLAT")[1], TamSX3("CY4_QTPLAT")[2], STR0043, .T., X3Picture("CY4_QTPLAT") } }   // "Quantidade"
Return {aDBF, {"CDMQ"}}

//-------------------------------------------------------------------------------
// Temp Table Eficiência Líquida (NEE)
//-------------------------------------------------------------------------------
Static Function DefNEE()
Local aDBF   := { { "CDMQ"  		, "C", TamSX3("CZ5_CDMQ")[1]  , TamSX3("CZ5_CDMQ")[2]  , STR0035, .F., X3Picture("CZ5_CDMQ")   } , ; // "Máquina"
				  { "ITEM"      	, "C", TamSX3("CZ5_CDAC")[1]  , TamSX3("CZ5_CDAC")[2]  , STR0042, .T., X3Picture("CZ5_CDAC")   } , ; // "Item"
				  { "TEMPO"     	, "N", TamSX3("CZ5_HRTEAT")[1], TamSX3("CZ5_HRTEAT")[2], STR0044+' '+STR0028, .T., X3Picture("CZ5_HRTEAT") } , ;    // "Tempo" ### "Real"
				  { "QUANT_PROJ"	, "N", TamSX3("CZ5_QTRPPL")[1], TamSX3("CZ5_QTRPPL")[2], STR0045, .T., X3Picture("CZ5_QTRPPL") } , ; // "Quant. Projetada"
				  { "QUANT_REAL"	, "N", TamSX3("CZ5_QTRP")[1]  , TamSX3("CZ5_QTRP")[2]  , STR0046, .T., X3Picture("CZ5_QTRP")   } , ; // "Quant. Real"
				  { "REFUGO"    	, "N", TamSX3("CZ5_QTRF")[1]  , TamSX3("CZ5_QTRF")[2]  , STR0047, .T., X3Picture("CZ5_QTRF")   } , ; // "Refugo Real"
				  { "RETRAB"    	, "N", TamSX3("CZ5_QTRT")[1]  , TamSX3("CZ5_QTRT")[2]  , STR0048, .T., X3Picture("CZ5_QTRT")   } }   // "Retrabalho Real"				
Return {aDBF, {"CDMQ"}}  

//-------------------------------------------------------------------------------
// Temp Table Eficiência Geral (OEE)
//-------------------------------------------------------------------------------
Static Function DefOEE()
Local aDBF   := { { "CDMQ"  		, "C", TamSX3("CZ4_CDMQ")[1]  , TamSX3("CZ4_CDMQ")[2]  , STR0035, .T., X3Picture("CZ4_CDMQ")   } , ; // "Máquina"
				  { "CAPAC_PROJ"	, "N", TamSX3("CZ4_QTVMPL")[1], TamSX3("CZ4_QTVMPL")[2], STR0049, .T., X3Picture("CZ4_QTVMPL") } , ; // "Capac. Projetada"
                  { "CAPAC_REAL"	, "N", TamSX3("CZ4_QTVMRY")[1], TamSX3("CZ4_QTVMRY")[2], STR0050, .T., X3Picture("CZ4_QTVMRY") } , ; // "Capac. Real"
                  { "EFICIENCIA"	, "N", TamSX3("CZ4_VLEF")[1]  , TamSX3("CZ4_VLEF")[2]  , STR0024, .T., X3Picture("CZ4_VLEF")   } , ; // "Eficiência"
				  { "PARADA"    	, "N", TamSX3("CZ4_QTTESP")[1], TamSX3("CZ4_QTTESP")[2], STR0051, .T., X3Picture("CZ4_QTTESP") } }	  // "Parada"				  
Return {aDBF, {"CDMQ"}} 

//-------------------------------------------------------------------------------
// Temp Table Produtividade (TEEP)
//-------------------------------------------------------------------------------
Static Function DefTEEP()
Local aDBF   := { { "CDMQ"  		, "C", TamSX3("CZ5_CDMQ")[1]  , TamSX3("CZ5_CDMQ")[2]  , STR0035, .F., X3Picture("CZ5_CDMQ")   } , ;  // "Máquina"
				  { "ITEM"      	, "C", TamSX3("CZ5_CDAC")[1]  , TamSX3("CZ5_CDAC")[2]  , STR0042, .T., X3Picture("CZ5_CDAC")   } , ;    // "Item"
				  { "TEMPO"	 		, "N", TamSX3("CZ5_QTTEPL")[1], TamSX3("CZ5_QTTEPL")[2], STR0044, .T., X3Picture("CZ5_QTTEPL") } , ;    // "Tempo"
				  { "UNIDADE"		, "C", TamSX3("CZ3_CDUN")[1]  , TamSX3("CZ3_CDUN")[2]  , STR0052, .T., X3Picture("CZ3_CDUN")   } , ;    // "Unid. Medida"
				  { "CAPACIDADE"	, "N", TamSX3("CZ4_QTVMRY")[1], TamSX3("CZ4_QTVMRY")[2], STR0053, .T., X3Picture("CZ4_QTVMRY") } , ;    // "Capacidade"
				  { "QUANTIDADE"	, "N", TamSX3("CZ5_QTRP")[1]  , TamSX3("CZ5_QTRP")[2]  , STR0043, .T., X3Picture("CZ5_QTRP")   } }      // "Quantidade"
Return {aDBF, {"CDMQ"}}     

//-------------------------------------------------------------------------------
// Temp Table Takt Time (Tk)
//-------------------------------------------------------------------------------
Static Function DefTk()
Local aDBF   := { { "CDMQ"  		, "C", TamSX3("CZ5_CDMQ")[1]  , TamSX3("CZ5_CDMQ")[2]  , STR0035, .F., X3Picture("CZ5_CDMQ")   } , ; // "Máquina"				  
				  { "CAPAC_PROJ"	, "N", TamSX3("CZ4_QTVMPL")[1], TamSX3("CZ4_QTVMPL")[2], STR0049, .T., X3Picture("CZ4_QTVMPL") } , ; // "Capac. Projetada"
				  { "QUANT_PROJ"	, "N", TamSX3("CZ4_QTVMRY")[1], TamSX3("CZ4_QTVMRY")[2], STR0045, .T., X3Picture("CZ4_QTVMRY") } , ; // "Quant. Projetada"
				  { "CAPAC_REAL"	, "N", TamSX3("CZ5_QTRPPL")[1], TamSX3("CZ5_QTRPPL")[2], STR0054, .T., X3Picture("CZ5_QTRPPL") } , ; // "Capac. Real"
				  { "QUANT_REAL"	, "N", TamSX3("CZ5_QTRP")[1]  , TamSX3("CZ5_QTRP")[2]  , STR0055, .T., X3Picture("CZ5_QTRP")   } }   // "Quant. Real" 
Return {aDBF, {"CDMQ"}}
