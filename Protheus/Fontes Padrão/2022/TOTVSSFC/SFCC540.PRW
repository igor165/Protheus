#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'   
#INCLUDE 'SFCC540.CH'
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC540
Tela de Análise de Parada

@param  nCZ4RecNo           (Obrigatório) Recno do Registro na Tabela CZ4

@author Ana Carolina Tome Klock
@since 29/03/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SFCC540( nCZ4RecNo )

	Local aCoors 		:= FWGetDialogSize( oMainWnd )     	  												// Tamanho da Tela
	Local aButtons   	:= {}                              													// Botões
	Local oDlg, oTFolder                                          		   									// Componentes da Tela
	Local aTFolder   	:= { STR0001, STR0002 } 															// Nome das Abas ## 'Dados' ## 'Gráfico'
	Local nWidthPnl    := ((aCoors[4]-20)/2)/3                   // Largura
	Local nHeigthPnl    := (aCoors[3]/2.82)-13                          									// Altura
	Local aCombo        := { STR0003, STR0004, STR0005, STR0006	}											// Valores do Combobox  ## "1=Motivo Parada" ## "2=Turno" ## "3=Diário" ## "4=Semanal"
	Local aUnidadeMed   := { SFCXUNIDME("06"), SFCXUNIDME("05") } 											// Unidades de Medida para Disp. Planejada e Disp. Real
	Private aTabBrw     := SFCC540TAB( 1 )						   										    // Array dos Campos da Temp Table
	Private oTabBrw    := SFCCriFWTa( aTabBrw )                  // Temp Table
	Private cTabBrw    := oTabBrw:GetAlias()   
	Private oChart 		:= FWChartBar():New()	                          									// Grafico
	Private cVisualiza  := aCombo[1]  																	    // Combobox       
	Private oTab       := SFCCriFWTa( SFCC540TAB( 2 ) )          // Temp Table do Gráfico
	Private cTab       := oTab:GetAlias()
	Default lAutoMacao := .F.

	// Busca na Tabela      
	SFCC540PRE( nCZ4RecNo )

	IF !lAutoMacao	
		Define MsDialog oDlg Title STR0007 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel              // 'Análise de Parada'
			
			// Divisão da Janela Principal
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDlg, .F., .T. )
			oFWLayer:AddLine('TOP'   , 20, .T. )
			oFWLayer:AddLine('BUTTON', 70, .T. )
			oFWLayer:AddCollumn('DETALHES', 100, .T. ,'TOP')
			oFWLayer:AddCollumn('DADOS'   , 100, .T. ,'BUTTON')
			oFWLayer:AddWindow('DETALHES', 'DETALHES_WINDOW', STR0007, 100, .T., .F.,, 'TOP',)                 // 'Análise de Parada'
			oFWLayer:AddWindow('DADOS'   , 'GRID_WINDOW'    , STR0008, 100, .T., .F.,, 'BUTTON',)              // 'Detalhes'
			
			// Layers que serão usadas
			oPanelUp := oFWLayer:GetWinPanel ( 'DETALHES','DETALHES_WINDOW', 'TOP' )
			oPanelGr := oFWLayer:GetWinPanel ( 'DADOS','GRID_WINDOW', 'BUTTON' )
			
			// Detalhe Superior
			oScroll := TScrollArea():New(oPanelUp,01,01,(nWidthPnl * 3), (nHeigthPnl/4) - 4,.T.,.T.,.T.)
			oScroll:Align := CONTROL_ALIGN_ALLCLIENT

			// Cria painel 
			aCoord := fwgetdialogsize()
					
			If aCoord[4] > 800
				nTam := nHeigthPnl * 0.2
			Else                                                 
				nTam := nHeigthPnl * 0.4 
			EndIf 

			oDetails := TPanel():New( 01, 01, /*cText*/, oScroll, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, (nWidthPnl * 3), nTam ) 

			// Define objeto painel como filho do scroll
			oScroll:SetFrame( oDetails )    
			
			TSay():New( 005, 010, { || STR0009			    		  	   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Estabelecimento"
			TGet():New( 013, 010, { || (cTabBrw)->CDES       		   	   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDES   )  
			TSay():New( 005, 070, { || STR0010			  				   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Área de Produção"
			TGet():New( 013, 070, { || (cTabBrw)->CDARPO     			   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDARPO ) 
			TSay():New( 005, 130, { || STR0011				 			   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Centro de Trabalho"
			TGet():New( 013, 130, { || (cTabBrw)->CDCETR     			   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDCETR ) 
			TSay():New( 005, 190, { || STR0012	            			   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Máquina"
			TGet():New( 013, 190, { || (cTabBrw)->CDMQ	   				   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDMQ   )
			TSay():New( 005, 250, { || aUnidadeMed[1] + STR0013			   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // " Disp. Planejada"
			TGet():New( 013, 250, { || cValToChar((cTabBrw)->VLDIPL)  	   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLDIPL) )  
			TSay():New( 005, 310, { || aUnidadeMed[2] + STR0014			   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // " Disp. Real"
			TGet():New( 013, 310, { || cValToChar((cTabBrw)->VLDIRY)  	   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLDIRY) )  
			TSay():New( 028, 010, { || STR0015	        				   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Tempo Útil"
			TGet():New( 036, 010, { || cValToChar((cTabBrw)->QTTEUT) 	   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTTEUT) )  
			TSay():New( 028, 070, { || STR0016			    			   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Tempo Extra"
			TGet():New( 036, 070, { || cValToChar((cTabBrw)->QTTEEX) 	   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTTEEX) )  
			TSay():New( 028, 130, { || STR0017							   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Parada Tempo Útil"
			TGet():New( 036, 130, { || cValToChar((cTabBrw)->VLSPUT)	   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLSPUT) ) 
			TSay():New( 028, 190, { || STR0018							   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Parada Tempo Extra"	
			TGet():New( 036, 190, { || cValToChar((cTabBrw)->VLSPEX) 	   }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLSPEX) )
			TSay():New( 028, 250, { || STR0019		       				   }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )   // "Visualizar:"
			oCombo := TComboBox():New( 036, 250, { |x| if( Pcount()>0, cVisualiza := x, cVisualiza )  }, aCombo, 70, 10, oDetails, , ;
									{|x| SFCC540GRA( ) } , , , , .T., , , , , , , , , 'cVisualiza' ) 

			// Folder Inferior
			@ 0,0 FOLDER oTFolder OF oFWLayer:GetWinPanel ( 'DADOS', 'GRID_WINDOW', 'BUTTON' ) PIXEL
			oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
			oTFolder:Hide()
			oTFolder:Show()
			oTFolder:AddItem(aTFolder[1])
			oTFolder:AddItem(aTFolder[2])
			oTFolder:SetOption( 1 )
			
			// Painel Inferior (Grid)
			oBrowse1 := SFCXAUXCRI( oTFolder:aDialogs[1], (cTabBrw), "cTabBrw", aTabBrw, .T., .F. )
								
			// Painel Inferior (Gráfico)
			oChart:Init( oTFolder:aDialogs[2] )
			oChart:setLegend( CONTROL_ALIGN_RIGHT )
			SFCC540GRA( cVisualiza )
			
		Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },,aButtons,,,,,, .F. )
	ENDIF

	oTabBrw:Delete()
	oTab:Delete()
	
Return NIL 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC540GRA
Monta o gráfico de acordo com a selecao                                            

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC540GRA()  
    Local nX := 0
    Default lAutoMacao := .T.

	IF !lAutoMacao
    	// Preenche a Temp Table
   		SFCC540REP( ) 
	ENDIF
   	
   	// Rotula a opção sendo mostrada   	   
   	If cVisualiza == "1"
		cVisualiza = STR0020 //"Motivo Parada"
   	ElseIf cVisualiza == "2"
		cVisualiza = STR0021 //"Turno"
   	ElseIf cVisualiza == "3"
		cVisualiza = STR0022 //"Dia"
	ElseIf cVisualiza == '4'
	    cVisualiza = STR0023 //"Semana"
	EndIf
   	
	IF !lAutoMacao
		// Reseta o gráfico e atualiza	       
		oChart:Reset()         
		oChart:setTitle( STR0024 + cVisualiza + STR0025, CONTROL_ALIGN_CENTER )    // "Paradas: " ## " de Produção"
		dbSelectArea( cTab )
		dbSetOrder( 1 )
		dbGoTop()
		While (cTab)->(!EOF())
			If cVisualiza != STR0022 .And. cVisualiza != STR0023 .And. AllTrim((cTab)->NOME) != "-" // "Dia" ## "Semana"
				oChart:addSerie( (cTab)->NOME, (cTab)->PARADA  )
				nX++
			ElseIf cVisualiza == STR0022 .And. !Empty((cTab)->DTBG) // "Dia"
				oChart:addSerie( cValToChar((cTab)->DTBG), (cTab)->PARADA  )
				nX++
			ElseIf cVisualiza == STR0023 // "Semana"
				oChart:addSerie( cValToChar((cTab)->DTBG) + STR0026 + cValToChar((cTab)->DTED), (cTab)->PARADA  ) // " até "
				nX++
			EndIf
			(cTab)->(dbSkip())
		End 
		
		// Aviso que a consulta não retornou resultados
		If nX = 0
			oChart:setTitle( STR0027 + cVisualiza, CONTROL_ALIGN_CENTER ) // "Sem resultados para consultas baseadas em "
		EndIf  
		oChart:Build()
	ENDIF

Return Nil    
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC540PRE
Preenche a tabela temporária da Grid

@param 	nCZ4RecNo 		(Obrigatório) Recno da Tabela

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC540PRE( nCZ4RecNo )
    
	// Realiza a busca na Tabela
	dbSelectArea( "CZ4" )
	dbSetOrder( 1 )	
	dbGoTo( nCZ4RecNo )
	RecLock( cTabBrw, .T.) 
		(cTabBrw)->CDES   := CZ4->CZ4_CDES
		(cTabBrw)->CDARPO := CZ4->CZ4_CDARPO
		(cTabBrw)->CDCETR := CZ4->CZ4_CDCETR
		(cTabBrw)->CDMQ   := CZ4->CZ4_CDMQ 
		(cTabBrw)->VLDIPL := Round( CZ4->CZ4_VLDIPL, 2 )
		(cTabBrw)->VLDIRY := Round( CZ4->CZ4_VLDIRY, 2 )
		(cTabBrw)->QTTEUT := Round( CZ4->CZ4_QTTEUT, 2 )
		(cTabBrw)->QTTEEX := Round( CZ4->CZ4_QTTEEX, 2 )
		(cTabBrw)->VLSPUT := Round( CZ4->CZ4_VLSPUT, 2 )
		(cTabBrw)->VLSPEX := Round( CZ4->CZ4_VLSPEX, 2 )
		(cTabBrw)->IDMEPO := CZ4->CZ4_IDMEPO
	MsUnlock() 
	CZ4->(dbCloseArea())

Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC540REP
Preenche a Temp Table com os dados que serão utilizados no gráfico                                           

@param  cTab           (Obrigatório) Temp Table que será preenchida

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC540REP( )
	Local cCampo, cGroup
	Default lAutoMacao := .F.

	IF !lAutoMacao
		// Limpa a Temp Table
		dbSelectArea(cTab)
		ZAP
	ENDIF
	
	// Define os campos para agrupamento
	If cVisualiza == "1" 
		cCampo := "CZ5.CZ5_CDSP"
		cGroup := "CZ5.CZ5_CDSP"
	ElseIf cVisualiza == "2" 
		cCampo := "CZ5.CZ5_CDTN"
		cGroup := "CZ5.CZ5_CDTN"
	Else
	   	cCampo := "CZ5.CZ5_DTED"
	   	cGroup := "CZ5.CZ5_DTED ORDER BY CZ5.CZ5_DTED"		
   	EndIf    
	
	IF !lAutoMacao
		// Realiza a busca na Tabela
		DbSelectArea("CZ5")
		cQuery := "SELECT " + cCampo + ", SUM(CZ5_QTSPRY) AS PARADA FROM " + RetSQLName( 'CZ5' ) + " CZ5 "
		cQuery += " WHERE CZ5.CZ5_FILIAL = '" + xFilial('CZ5')    + "' AND "
		cQuery += " 	  CZ5.CZ5_CDES   = '" + (cTabBrw)->CDES   + "' AND "
		cQuery += " 	  CZ5.CZ5_CDARPO = '" + (cTabBrw)->CDARPO + "' AND "
		cQuery += " 	  CZ5.CZ5_CDCETR = '" + (cTabBrw)->CDCETR + "' AND "
		cQuery += " 	  CZ5.CZ5_CDMQ   = '" + (cTabBrw)->CDMQ   + "' AND "  
		cQuery += " 	  CZ5.CZ5_IDMEPO = '" + (cTabBrw)->IDMEPO + "' AND "
		cQuery += " 	  CZ5.CZ5_TPMV   = '5' AND "
		cQuery += " CZ5.D_E_L_E_T_ = ' ' GROUP BY " + cGroup 
		cCZ5   := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cCZ5, .T., .F. )     
							
		// Preenche a tabela temporária
		While (cCZ5)->(!EOF() )
			If cVisualiza == "1" 
				RecLock( cTab, .T.)
				(cTab)->NOME   := AllTrim((cCZ5)->CZ5_CDSP) + " - " + POSICIONE("CYN",1,XFILIAL("CYN")+(cCZ5)->CZ5_CDSP, "CYN_DSSP")  
				(cTab)->PARADA := Round( (cCZ5)->PARADA, 2 )
				MsUnlock()
			ElseIf cVisualiza == "2"
				RecLock( cTab, .T.)
				(cTab)->NOME   := AllTrim((cCZ5)->CZ5_CDTN) + " - " + POSICIONE("CYM",1,XFILIAL("CYM")+(cCZ5)->CZ5_CDTN, "CYM_DSTN")  
				(cTab)->PARADA := Round( (cCZ5)->PARADA, 2 )
				MsUnlock()
			ElseIf cVisualiza == "3"
				RecLock( cTab, .T.)
				(cTab)->DTBG   := STOD((cCZ5)->CZ5_DTED)   
				(cTab)->PARADA := Round( (cCZ5)->PARADA, 2 )
				MsUnlock()
			Else
				If (cTab)->( dbSeek( DTOS(STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1)) )) 
					RecLock( cTab, .F.)
					(cTab)->PARADA += Round( (cCZ5)->PARADA, 2 )
					MsUnlock()
				Else
					RecLock( cTab, .T.)        
					(cTab)->NOME   := DTOS(STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1))
					(cTab)->DTBG   := STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1)
					(cTab)->DTED   := STOD((cCZ5)->CZ5_DTED) + (7-DOW(STOD((cCZ5)->CZ5_DTED))) 
					(cTab)->PARADA := Round( (cCZ5)->PARADA, 2 )
					MsUnlock()  
				EndIf
			EndIf  
			(cCZ5)->(dbSkip())
		End                 
		(cCZ5)->(dbCloseArea())
		
		dbSelectArea( (cTab) )
		While( (cTab)->(!EOF() ) )
			dbSkip()
		EndDo
	ENDIF
    
Return Nil 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC540TAB 
Cria as tabelas a serem usadas 

@param  nTab 	          (Obrigatório) Número da tabela que será criada

@author Ana Carolina Tome Klock
@since 29/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function SFCC540TAB( nTab )
Local aTabela 	:= {}
Local cChave 	:= ''
                           
If nTab == 1 
 	aTabela := {  { "CDES"  , "C", TamSX3("CZ4_CDES")[1]  , TamSX3("CZ4_CDES")[2]  , STR0009, .T., X3Picture("CZ4_CDES")   }, ;	// "Estabelecimento"
 	  	   		  { "CDARPO", "C", TamSX3("CZ4_CDARPO")[1], TamSX3("CZ4_CDARPO")[2], STR0010, .T., X3Picture("CZ4_CDARPO") }, ;  // "Área de Produção"
        		  { "CDCETR", "C", TamSX3("CZ4_CDCETR")[1], TamSX3("CZ4_CDCETR")[2], STR0011, .T., X3Picture("CZ4_CDCETR") }, ;  // "Centro de Trabalho"
        		  { "CDMQ"  , "C", TamSX3("CZ4_CDMQ")[1]  , TamSX3("CZ4_CDMQ")[2]  , STR0012, .T., X3Picture("CZ4_CDMQ")   }, ;  // "Máquina"
        		  { "VLDIPL", "N", TamSX3("CZ4_VLDIPL")[1], TamSX3("CZ4_VLDIPL")[2], STR0013, .F., X3Picture("CZ4_VLDIPL") }, ;  // " Disp. Planejada"
            	  { "VLDIRY", "N", TamSX3("CZ4_VLDIRY")[1], TamSX3("CZ4_VLDIRY")[2], STR0014, .F., X3Picture("CZ4_VLDIRY") }, ;  // " Disp. Real"
            	  { "QTTEUT", "N", TamSX3("CZ4_QTTEUT")[1], TamSX3("CZ4_QTTEUT")[2], STR0015, .T., X3Picture("CZ4_QTTEUT") }, ;  // "Tempo Útil"
            	  { "QTTEEX", "N", TamSX3("CZ4_QTTEEX")[1], TamSX3("CZ4_QTTEEX")[2], STR0016, .T., X3Picture("CZ4_QTTEEX") }, ;  // "Tempo Extra"
            	  { "VLSPUT", "N", TamSX3("CZ4_VLSPUT")[1], TamSX3("CZ4_VLSPUT")[2], STR0017, .T., X3Picture("CZ4_VLSPUT") }, ;  // "Parada em Tempo Útil"
            	  { "VLSPEX", "N", TamSX3("CZ4_VLSPEX")[1], TamSX3("CZ4_VLSPEX")[2], STR0018, .T., X3Picture("CZ4_VLSPEX") }, ;  // "Parada em Tempo Extra"
            	  { "IDMEPO", "C", TamSX3("CZ4_IDMEPO")[1], TamSX3("CZ4_IDMEPO")[2],'IDMEPO', .F., X3Picture("CZ4_IDMEPO") } }                                        
	cChave  := {"CDES","CDARPO"}                                                  
ElseIf nTab == 2        
 	aTabela := {  { "NOME"  , "C", 100, 0, STR0028   , .T., "!@" } , ;                 // "Nome" 
				  { "DTBG"  , "D", TamSX3("CZ5_DTBG")[1]  , TamSX3("CZ5_DTBG")[2]  , STR0029, .T., X3Picture("CZ5_DTBG"  ) } , ; // "Data Inicial"
				  { "DTED"  , "D", TamSX3("CZ5_DTED")[1]  , TamSX3("CZ5_DTED")[2]  , STR0030, .T., X3Picture("CZ5_DTED"  ) } , ; // "Data Final"
	 		  	  { "PARADA", "N", TamSX3("CZ5_QTSPRY")[1], TamSX3("CZ5_QTSPRY")[2], STR0031, .T., X3Picture("CZ5_QTSPRY") } }   // "Paradas"
	cChave := {"NOME"} 
EndIf

Return { aTabela, cChave}
