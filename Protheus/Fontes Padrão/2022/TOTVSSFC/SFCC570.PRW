#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'   
#INCLUDE 'SFCC570.CH'  
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC570
Tela de Evolução Histórica

@param  nCZ4RecNo           (Obrigatório) Recno do Registro na Tabela CZ4

@author Ana Carolina Tome Klock
@since 29/03/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Imprimi()
Default lAutoMacao := .F.

	cQuery := "SELECT CZ4.* FROM " + RetSQLName( 'CZ4' ) + " CZ4 "
	cQuery += "WHERE "
	cQuery += "	CZ4.CZ4_FILIAL = '" + xFilial('CZ4')+ "' AND "
	cQuery += "	CZ4.CZ4_IDMEPO = '" + cIdMePo		+ "' AND "
	cQuery += "	( "
	cQuery += "		( CZ4.CZ4_DTRE = '" + DTOS(dDataBG) + "' AND CZ4.CZ4_HRRE >= '" + cHoraBG + "' ) OR CZ4.CZ4_DTRE	> '" + DTOS(dDataBG) + "' "
	cQuery += "	) AND "
	cQuery += "	( "
	cQuery += "		( CZ4.CZ4_DTRE = '" + DTOS(dDataED) + "' AND CZ4.CZ4_HRRE <= '" + cHoraED + "' ) OR CZ4.CZ4_DTRE	< '" + DTOS(dDataED) + "' "
	cQuery += "	) AND "
	cQuery += "	CZ4.D_E_L_E_T_ = ' ' ORDER BY CZ4.CZ4_DTRE, CZ4.CZ4_HRRE" 

	cImprime := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cImprime, .T., .F. )
	IF !lAutoMacao
		SFCXExpTab(,,,cImprime)
	ENDIF
Return Nil
//--------------------------------------------------------------------------------------------------------------------
Function SFCC570( nCZ4RecNo )  

	Local aCoors 		:= FWGetDialogSize( oMainWnd )     	  												// Tamanho da Tela
	Local aButtons	:=	{;
		{ STR0001, { || SFCC570PAR() }, STR0001, STR0002 },; // Botões ## 'Parametros' ## 'Parametros' ## 'Gerenciar Parametros'
		{ "SFCXExpTab", {|| Imprimi() }, STR0055, STR0055, {|| .T.} }; // "Imprimir"
	}

	Local oDlg, oTFolder                                          		   									// Componentes da Tela
	Local aTFolder   	:= { STR0003, STR0004 } 															// Nome das Abas ## 'Dados' ## 'Gráfico'
	Local nWidthPnl   := ((aCoors[4]-20)/2)/3                                                  // Largura
	Local nHeigthPnl    := (aCoors[3]/2.82)-13                          									// Altura
	Private cCDES, cCDARPO, cCDCETR, cCDMQ, cIdMePo, dDTRE, cHRRE 											// Campos Chave
	Private nQTVMPL := 0, nQTTELZ := 0, nQTTEUT := 0, nQTSPEF := 0, nQTVMEV := 0, nQTVMRY := 0				// Quantidades
	Private aTabBrw     := SFCC570TAB(1)						   										    // Array dos Campos da Temp Table do Grid
	Private aTab	    := SFCC570TAB(2)						   										    // Array dos Campos da Temp Table do Gráfico
	Private oTabBrw   := SFCCriFWTa( aTabBrw )    // Temp Table do Grid
	Private cTabBrw   := oTabBrw:GetAlias()
	Private oTab      := SFCCriFWTa( aTab )       // Temp Table do Gráfico
	Private cTab      := oTab:GetAlias()
	Private oChart 		:= FWChartLine():New()                         								  		// Grafico
	Private cFunction   := '1'                                                                              // Tela de Parâmetros: Tipo do Gráfico (Percentual/Horas)
    Private dDataBG     			                                                                        // Tela de Parâmetros: Data inicial 
    Private dDataED    				                                                                        // Tela de Parâmetros: Data final
    Private cHoraBG     := "00:00:00"                                                                       // Tela de Parâmetros: Hora inicial
    Private cHoraED     			                                                                        // Tela de Parâmetros: Hora final
    Default lAutoMacao := .F.

    // Busca na Tabela
	dbSelectArea( "CZ4" )
	dbGoTo( nCZ4RecNo )
	cCDES   = CZ4->CZ4_CDES
	cCDARPO = CZ4->CZ4_CDARPO
	cCDCETR = CZ4->CZ4_CDCETR
	cCDMQ	= CZ4->CZ4_CDMQ
	cIdMePo = CZ4->CZ4_IDMEPO
	dDTRE   = CZ4->CZ4_DTRE
	cHRRE	= CZ4->CZ4_HRRE
	dDataED = dDTRE
	cHoraED = cHRRE 

	IF !lAutoMacao
		Define MsDialog oDlg Title  STR0005 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel         // 'Evolução Histórica'
			
			// Divisão da Janela Principal
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDlg, .F., .T. )
			oFWLayer:AddLine('TOP'   , 20, .T. )
			oFWLayer:AddLine('BUTTON', 73, .T. )
			oFWLayer:AddCollumn('DETALHES', 100, .T. ,'TOP')
			oFWLayer:AddCollumn('DADOS'   , 100, .T. ,'BUTTON')
			oFWLayer:AddWindow('DETALHES', 'DETALHES_WINDOW', STR0005, 100, .T., .F.,, 'TOP',)     // 'Evolução Histórica'
			oFWLayer:AddWindow('DADOS'   , 'GRID_WINDOW'    , STR0006, 100, .T., .F.,, 'BUTTON',)  // 'Detalhes'
			
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
			
			TSay():New( 005, 010, { || STR0007			       		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Estabelecimento"
			TGet():New( 013, 010, { || cCDES       			   		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDES   )  
			TSay():New( 005, 070, { || STR0008				   		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Área de Produção"
			TGet():New( 013, 070, { || cCDARPO     			   		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDARPO ) 
			TSay():New( 005, 130, { || STR0009				  		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Centro de Trabalho"
			TGet():New( 013, 130, { || cCDCETR     			   		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDCETR ) 
			TSay():New( 005, 190, { || STR0010	               		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Máquina"
			TGet():New( 013, 190, { || cCDMQ	   			   		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDMQ   )
			TSay():New( 028, 010, { || STR0011				  		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Capacidade do Projeto"
			TGet():New( 036, 010, { || cValToChar(nQTVMPL)    		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTVMPL) )
			TSay():New( 028, 070, { || STR0012				   		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Capacidade Efetiva"
			TGet():New( 036, 070, { || cValToChar(nQTVMEV)	   		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTVMEV) ) 
			TSay():New( 028, 130, { || STR0013			       		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Capacidade Real"
			TGet():New( 036, 130, { || cValToChar(nQTVMRY)			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTVMRY) )   
			TSay():New( 028, 190, { || STR0014				   		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Horas Disponíveis"
			TGet():New( 036, 190, { || cValToChar(nQTTELZ)     		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTTELZ) )  
			TSay():New( 028, 250, { || STR0015						}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Horas Trabalhadas" 
			TGet():New( 036, 250, { || cValToChar(nQTTEUT)	   		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTTEUT) ) 
			TSay():New( 028, 310, { || STR0016  					}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // " Eficiência"
			TGet():New( 036, 310, { || cValToChar(nQTSPEF)			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTSPEF) ) 


			// Folder Inferior
			@ 0,0 FOLDER oTFolder OF oFWLayer:GetWinPanel ( 'DADOS', 'GRID_WINDOW', 'BUTTON' ) PIXEL
			oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
			oTFolder:Hide()
			oTFolder:Show()
			oTFolder:AddItem(aTFolder[1])
			oTFolder:AddItem(aTFolder[2])
			oTFolder:SetOption( 1 )
			
			// Painel Inferior (Grid)
			oBrowse1 := SFCXAUXCRI( oTFolder:aDialogs[1], (cTabBrw), "cTabBrw", aTabBrw, .T., .T. )
								
			// Painel Inferior (Gráfico)
			oChart:Init( oTFolder:aDialogs[2] ) 
			oChart:setTitle( STR0005, CONTROL_ALIGN_CENTER )   // 'Evolução Histórica'
			oChart:setLegend( CONTROL_ALIGN_RIGHT ) 
			
			// Chama a tela de parametros do gráfico
			SFCC570PAR()  
			
		Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },,aButtons,,,,,, .F. )
		
		oTabBrw:Delete()
		oTab:Delete()
	ENDIF
	
Return NIL
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC570GRA
Monta o gráfico de acordo com a selecao                                            

@param  cVisualiza           (Obrigatório) Identifica qual tabela será preenchida

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC570GRA( )  
  	Local aVetor1  := {}			// % Disponibilidade Planejada ou Capacidade de Projeto ou Takt Time
  	Local aVetor2  := {}			// % Utilização 			   ou Capacidade Efetiva
  	Local aVetor3  := {}	 		// % Qualidade 				   ou Capacidade Real
  	Local aVetor4  := {}	 		// % Qualidade Real			   ou Tempo Preparação Padrão
  	Local aVetor5  := {}			// % Eficiência				   ou Tempo Operação Padrão
  	Local aVetor6  := {}	 		// % Eficiência Líquida		   ou Tempo Preparação Real
  	Local aVetor7  := {}			// % Eficiência Geral		   ou Tempo Operação Real
  	Local aVetor8  := {}	 		// % Produtividade 			   ou Horas Normais
  	Local aVetor9  := {}	 		// % Atendimento (BTS)         ou Horas Extras
  	Local aVetor10 := {}			// % Sequência                 ou Horas Sem Apontamento
  	Local aVetor11 := {}	 		// % Mix                       ou Horas Paradas
  	Local aVetor12 := {}			// % Volume                    ou Paradas Programadas
  	
   	// Reseta o gráfico e atualiza	       
	oChart:Reset()         
	dbSelectArea( cTab )
	dbGoTop()
    While (cTab)->(!EOF())
    	cDataHora := cValToChar((cTab)->DTRE) + " - " + (cTab)->HRRE
    	
  		If cFunction == '1'
	  		aAdd (aVetor1 , { cDataHora  , (cTab)->VLDIPL } )
		  	aAdd (aVetor2 , { cDataHora  , (cTab)->VLUT   } )
		  	aAdd (aVetor3 , { cDataHora  , (cTab)->VLQL   } )
		  	aAdd (aVetor4 , { cDataHora  , (cTab)->VLQLRY } )
		  	aAdd (aVetor5 , { cDataHora  , (cTab)->VLEF   } )
		  	aAdd (aVetor6 , { cDataHora  , (cTab)->VLNEE  } )
		  	aAdd (aVetor7 , { cDataHora  , (cTab)->VLOEE  } )
		  	aAdd (aVetor8 , { cDataHora  , (cTab)->VLTEEP } )
		  	aAdd (aVetor9 , { cDataHora  , (cTab)->VLBTS  } )
		  	aAdd (aVetor10, { cDataHora  , (cTab)->VLBTSS } )
		  	aAdd (aVetor11, { cDataHora  , (cTab)->VLBTSM } )
		  	aAdd (aVetor12, { cDataHora  , (cTab)->VLBTSV } ) 
		  	
		ElseIf cFunction == '2'
			aAdd (aVetor1 , { cDataHora  , (cTab)->QTVMPL } )
		  	aAdd (aVetor2 , { cDataHora  , (cTab)->QTVMEV } )
		  	aAdd (aVetor3 , { cDataHora  , (cTab)->QTVMRY } )
		  	aAdd (aVetor4 , { cDataHora  , (cTab)->QTSUPA } )
		  	aAdd (aVetor5 , { cDataHora  , (cTab)->QTATPA } )
		  	aAdd (aVetor6 , { cDataHora  , (cTab)->QTSURY } )
		  	aAdd (aVetor7 , { cDataHora  , (cTab)->QTATRY } )
		  	aAdd (aVetor8 , { cDataHora  , (cTab)->QTTEUT } )
		  	aAdd (aVetor9 , { cDataHora  , (cTab)->QTTEEX } )
		  	aAdd (aVetor10, { cDataHora  , (cTab)->QTTELZ } )
		  	aAdd (aVetor11, { cDataHora  , (cTab)->QTTESP } )
		  	aAdd (aVetor12, { cDataHora  , (cTab)->QTSPPL } )
		
		Else
			aAdd (aVetor1, { cDataHora  , (cTab)->VLTK } )
		EndIf 
		  
		(cTab)->(dbSkip())
	End  
	
	If cFunction == '1'
		oChart:addSerie( STR0017, aVetor1 )  // "% Disponibilidade Planejada"
		oChart:addSerie( STR0018, aVetor2 )  // "% Utilização"
		oChart:addSerie( STR0019, aVetor3 )  // "% Qualidade"	  			   
		oChart:addSerie( STR0020, aVetor4 )  // "% Qualidade Real"
		oChart:addSerie( STR0021, aVetor5 )  // "% Eficiência"				   
		oChart:addSerie( STR0022, aVetor6 )  // "% Eficiência Liquida (NEE)"  
		oChart:addSerie( STR0023, aVetor7 )  // "% Eficiência Geral (OEE)"    
		oChart:addSerie( STR0024, aVetor8 )  // "% Produtividade (TEEP)"  	   
		oChart:addSerie( STR0025, aVetor9 )  // "% Atendimento (BTS)"	       
		oChart:addSerie( STR0026, aVetor10 ) // "% Sequência"				   
		oChart:addSerie( STR0027, aVetor11 ) // "% Mix"	  				   
		oChart:addSerie( STR0028, aVetor12 ) // "% Volume"	  				   
		
	ElseIf cFunction == '2' 
   		oChart:addSerie( STR0029, aVetor1 )  // "Horas Capacidade de Projeto" 
		oChart:addSerie( STR0030, aVetor2 )  // "Horas Capacidade Efetiva"
		oChart:addSerie( STR0031, aVetor3 )  // "Horas Capacidade Real"
		oChart:addSerie( STR0032, aVetor4 )  // "Horas Preparação Padrão"
		oChart:addSerie( STR0033, aVetor5 )  // "Horas Operação Padrão"
		oChart:addSerie( STR0034, aVetor6 )  // "Horas Preparação Real"
		oChart:addSerie( STR0035, aVetor7 )  // "Horas Operação Real"
		oChart:addSerie( STR0036, aVetor8 )  // "Horas Normais"
		oChart:addSerie( STR0037, aVetor9 )  // "Horas Extras"
		oChart:addSerie( STR0038, aVetor10 ) // "Horas Sem Apontamento"
		oChart:addSerie( STR0039, aVetor11 ) // "Horas Paradas"			   
		oChart:addSerie( STR0040, aVetor12 ) // "Horas Paradas Programadas"   
		
	Else
	  	oChart:addSerie( STR0041, aVetor1 )  // "Takt Time"
	EndIf
	
	oChart:Build()

Return Nil                                                   
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC570PRE
Preenche a tabela temporária da Grid

@author Ana Carolina Tome Klock
@since 11/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC570PRE( ) 
Default lAutoMacao := .F.
    
	IF !lAutoMacao
		// Limpa as Temp Tables
		dbSelectArea( cTabBrw )
		ZAP   
		dbSelectArea( cTab )
		ZAP
	ENDIF   
    
    // Reseta os valores de quantidade                           
    nQTVMPL := 0
	nQTTELZ := 0
	nQTTEUT := 0 	 
	nQTSPEF := 0
	nQTVMEV := 0
	nQTVMRY := 0  
	nQTATRY := 0
	nQTATPA := 0
    
	// Realiza a busca na Tabela
	dbSelectArea("CZ4")
	cQuery := " SELECT CZ4.* FROM " + RetSQLName( 'CZ4' ) + " CZ4 "
	cQuery += " WHERE CZ4.CZ4_FILIAL = '" + xFilial('CZ4') + "'  AND "
	cQuery += " 	  CZ4.CZ4_IDMEPO = '" + cIdMePo + "' AND "
	cQuery += "( ( ( CZ4.CZ4_DTRE	 = '" + DTOS(dDataBG) + "' AND CZ4.CZ4_HRRE >= '" + cHoraBG + "' )  OR CZ4.CZ4_DTRE	> '" + DTOS(dDataBG) + "')   AND "
	cQuery += "  ( ( CZ4.CZ4_DTRE	 = '" + DTOS(dDataED) + "' AND CZ4.CZ4_HRRE <= '" + cHoraED + "' )  OR CZ4.CZ4_DTRE	< '" + DTOS(dDataED) + "') ) AND "
	cQuery += " CZ4.D_E_L_E_T_ = ' ' ORDER BY CZ4.CZ4_DTRE, CZ4.CZ4_HRRE" 
	cCZ4   := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cCZ4, .T., .F. ) 
	
   	// Preenche as tabelas temporárias
	While (cCZ4)->(!EOF())         
	
		RecLock( cTabBrw, .T.)
			(cTabBrw)->DTRE   := STOD((cCZ4)->CZ4_DTRE)
			(cTabBrw)->HRRE   := (cCZ4)->CZ4_HRRE
			(cTabBrw)->CDES   := (cCZ4)->CZ4_CDES
			(cTabBrw)->CDARPO := (cCZ4)->CZ4_CDARPO
			(cTabBrw)->CDCETR := (cCZ4)->CZ4_CDCETR
			(cTabBrw)->CDMQ   := (cCZ4)->CZ4_CDMQ
			(cTabBrw)->QTVMPL := Round( (cCZ4)->CZ4_QTVMPL, 2)
			(cTabBrw)->QTTELZ := Round( (cCZ4)->CZ4_QTTELZ, 2)
			(cTabBrw)->QTTEUT := Round( (cCZ4)->CZ4_QTTEUT, 2)
			(cTabBrw)->VLEF   := Round( (cCZ4)->CZ4_VLEF  , 2)
			(cTabBrw)->QTVMEV := Round( (cCZ4)->CZ4_QTVMEV, 2)
			(cTabBrw)->QTVMRY := Round( (cCZ4)->CZ4_QTVMRY, 2)
		MsUnLock()
		
		RecLock( cTab, .T.)    
			(cTab)->DTRE := STOD((cCZ4)->CZ4_DTRE)
			(cTab)->HRRE := (cCZ4)->CZ4_HRRE
			If cFunction == '1'
				(cTab)->VLBTS  := Round( (cCZ4)->CZ4_VLBTS, 2)
		        (cTab)->VLBTSS := Round( (cCZ4)->CZ4_VLBTSS, 2)
		        (cTab)->VLBTSM := Round( (cCZ4)->CZ4_VLBTSM, 2)
		        (cTab)->VLBTSV := Round( (cCZ4)->CZ4_VLBTSV, 2)
			    (cTab)->VLEF   := Round( (cCZ4)->CZ4_VLEF, 2)
	   		    (cTab)->VLNEE  := Round( (cCZ4)->CZ4_VLNEE, 2)
	        	(cTab)->VLOEE  := Round( (cCZ4)->CZ4_VLOEE, 2)
	        	(cTab)->VLTEEP := Round( (cCZ4)->CZ4_VLTEEP, 2)
	        	(cTab)->VLUT   := Round( (cCZ4)->CZ4_VLUT, 2)
		        (cTab)->VLQL   := Round( (cCZ4)->CZ4_VLQL, 2)
			    (cTab)->VLQLRY := Round( (cCZ4)->CZ4_VLQLRY, 2)
	   		    (cTab)->VLDIPL := Round( (cCZ4)->CZ4_VLDIPL, 2)
			Elseif cFunction == '2' 
				(cTab)->QTVMEV := Round( (cCZ4)->CZ4_QTVMEV, 2)
			    (cTab)->QTVMPL := Round( (cCZ4)->CZ4_QTVMPL, 2)
	   		    (cTab)->QTVMRY := Round( (cCZ4)->CZ4_QTVMRY, 2)
	        	(cTab)->QTATPA := Round( (cCZ4)->CZ4_QTATPA, 2)
	        	(cTab)->QTATRY := Round( (cCZ4)->CZ4_QTATRY, 2)
	        	(cTab)->QTSUPA := Round( (cCZ4)->CZ4_QTSUPA, 2)
		        (cTab)->QTSURY := Round( (cCZ4)->CZ4_QTSURY, 2)
			    (cTab)->QTSPPL := Round( (cCZ4)->CZ4_QTSPPL, 2)
	   		    (cTab)->QTTEUT := Round( (cCZ4)->CZ4_QTTEUT, 2)
	        	(cTab)->QTTEEX := Round( (cCZ4)->CZ4_QTTEEX, 2)
	        	(cTab)->QTTELZ := Round( (cCZ4)->CZ4_QTTELZ, 2)
	        	(cTab)->QTTESP := Round( (cCZ4)->CZ4_QTTESP, 2)
	      	Else
	      		(cTab)->VLTK   := Round( (cCZ4)->CZ4_VLTK, 2)
			EndIf            
		MsUnLock()
			
		// Preenche as quantidades dos detalhes
		nQTVMPL := Round( (cCZ4)->CZ4_QTVMPL, 2 )
		nQTTELZ := Round( (cCZ4)->CZ4_QTTELZ, 2 )
		nQTTEUT := Round( (cCZ4)->CZ4_QTTEUT, 2 )
		nQTATRY := (cCZ4)->CZ4_QTATRY
		nQTATPA := (cCZ4)->CZ4_QTATPA
		nQTVMEV := Round( (cCZ4)->CZ4_QTVMEV, 2 )
		nQTVMRY := Round( (cCZ4)->CZ4_QTVMRY, 2 ) 
		nQTSPEF := Round( (cCZ4)->CZ4_VLEF, 2)
		(cCZ4)->(dbSkip())
	End
	
	(cCZ4)->(dbCloseArea())    

	IF !lAutoMacao
		// Atualiza o Browse e seleciona a primeira linha
		oBrowse1:ShowData()
		oBrowse1:Refresh()
		oBrowse1:GoTo( 1 )
	ENDIF
    
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC570PAR
Abre a tela de parametros

@author Ana Carolina Tome Klock
@since 11/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC570PAR( )  
Default lAutoMacao := .F. 
    
    If Empty(dDataBG) .Or. Empty(dDataED)
	    cQuery := " SELECT CYU.CYU_TPME, CYU_CDMEPO FROM " + RetSQLName( 'CYU' ) + " CYU "
		cQuery += "    INNER JOIN " + RetSQLName( 'CY5' )  + " CY5 ON "
		cQuery += "        CY5.CY5_CDMEPO = CYU.CYU_CDMEPO AND "
		cQuery += "        CY5.CY5_IDMEPO = '" + cIdMePo + "' AND " 
		cQuery += "        CY5.CY5_FILIAL = '" + xFilial('CY5') + "' AND"
		cQuery += "        CY5.D_E_L_E_T_ = ' ' "
		cCYU   := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cCYU, .T., .F. ) 
		If (cCYU)->(!EOF())
	 		cTPME := (cCYU)->CYU_TPME
	 		(cCYU)->(dbSkip())
	    EndIf 
	    
	    If (cTPME == '1')
	    	dDataBG := dDTRE
	    ElseIf (cTPME == '2')
	  		dDataBG := SFCXDiaSem( dDTRE, 1 )
	    Else
	   		cAnoBG  := cValToChar(YEAR(dDTRE))
	   		cMesBG  := cValToChar(MONTH(dDTRE))
	   		dDataBG := CTOD("01/"+cMesBG+"/"+cAnoBG)
	    EndIf                                 
    EndIf
	
	IF !lAutoMacao
		Define MsDialog oDlg Title  STR0001  From 00,00 To 200, 350 Pixel    // 'Parâmetros'
		
			oPanel := tPanel():New(00,00,,oDlg,,,,,,200, 350,.F.,.F.)
			oPanel:Align := CONTROL_ALIGN_TOP 
			@ 011,010 Say STR0042 Of oPanel COLOR CLR_BLACK Pixel            // "Visualizar por: "
			@ 008,050 Combobox oFunction Var cFunction Items { STR0043, STR0044, STR0045 } Size 70,010 Pixel Of oPanel // "1=Porcentagem", "2=Horas", "3=Quantidade/Minuto"
			@ 025,028 Say STR0046    COLOR CLR_BLACK Pixel Of oPanel         // "Data de "
			@ 023,050 MsGet dDataBG       Size 50,10 Pixel Of oPanel      
			@ 025,103 Say STR0047    COLOR CLR_BLACK Pixel Of oPanel         // "Até"
			@ 023,115 MsGet dDataED       Size 50,10 Pixel Of oPanel   
			@ 039,028 Say STR0048    COLOR CLR_BLACK Pixel Of oPanel         // "Hora de "
			@ 038,050 MsGet cHoraBG  	  Size 50,10 Pixel Of oPanel Picture "@E 99:99:99"      
			@ 039,103 Say STR0047    COLOR CLR_BLACK Pixel Of oPanel 		 // "Até"
			@ 038,115 MsGet cHoraED 	  Size 50,10 Pixel Of oPanel Picture "@E 99:99:99" 
		
			@ 70, 80  BUTTON oBtnAvanca   PROMPT "Confirmar" SIZE 35, 14 ACTION { || SFCC570VAL(), oDlg:End() } OF oPanel PIXEL
			@ 70, 120 BUTTON oBtnCancelar PROMPT "Cancelar"  SIZE 35, 14 ACTION (oDlg:End())         OF oPanel PIXEL
			
		Activate MsDialog oDlg Centered /*On Init EnchoiceBar(oDlg,{||If(SFCC570VAL()  ,oDlg:End(),NIL)},{||,oDlg:End(),},,)*/
  	ENDIF

Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC570VAL
Valida os parâmetros informados

@author Ana Carolina Tome Klock
@since 11/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC570VAL()
    Local lRet         := .T.
	Default lAutoMacao := .F.
    
    // Valida os dados inseridos                                                                              
	If Empty(dDataBG) .Or. Empty(dDataED) .Or. cHoraBG == "  :  :  " .Or. cHoraED == "  :  :  "
		Help( ,, 'Help',, STR0049, 1, 0 )     // "Verifique se todos os parâmetros foram preenchidos"
		lRet := .F.
	ElseIf dDataED < dDataBG
		Help( ,, 'Help',, STR0050, 1, 0 )     // "A data inicial deve ser maior que a data final"
		lRet := .F.
	ElseIf ( Val(Substr(cHoraBG, 1, 2))> 23 .Or. Val(Substr(cHoraED, 1, 2))> 23 .Or. ;
	         Val(Substr(cHoraBG, 4, 2))> 59 .Or. Val(Substr(cHoraED, 4, 2))> 59 .Or. ;
	         Val(Substr(cHoraBG, 7, 2))> 59 .Or. Val(Substr(cHoraBG, 7, 2))> 59 )
   		Help( ,, 'Help',, STR0051, 1, 0 )     // "Verifique se o horário informado é válido"
		lRet := .F.  
	ElseIf dDataBG == dDataED .And. SFCXHourToSeg(cHoraED) < SFCXHourToSeg(cHoraBG) 
   		Help( ,, 'Help',, STR0052, 1, 0 )     // "A hora inicial deve ser maior que a hora final"
		lRet := .F. 
	Else
		// Preenche as Temp Tables e monta o Gráfico
		IF !lAutoMacao
			SFCC570PRE( )
			SFCC570GRA( )
		ENDIF
	EndIf
	 
Return lRet
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC570TAB 
Cria a tabela a ser usada 

@param  nTab          (Obrigatório) Número para especificar a tabela a ser criada

@author Ana Carolina Tome Klock
@since 11/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function SFCC570TAB( nTab )
    
If nTab == 1      
   	aTabela := { { "DTRE"  , "D", TamSX3("CZ4_DTRE")[1]  , TamSX3("CZ4_DTRE")[2]  , STR0053, .T., X3Picture("CZ4_DTRE")   }, ; // "Data Referência"
				 { "HRRE"  , "C", TamSX3("CZ4_HRRE")[1]  , TamSX3("CZ4_HRRE")[2]  , STR0054, .T., X3Picture("CZ4_HRRE")   }, ; // "Hora Referência"
				 { "CDES"  , "C", TamSX3("CZ4_CDES")[1]  , TamSX3("CZ4_CDES")[2]  , STR0007, .T., X3Picture("CZ4_CDRF")   }, ; // "Estabelecimento"
				 { "CDARPO", "C", TamSX3("CZ4_CDARPO")[1], TamSX3("CZ4_CDARPO")[2], STR0008, .T., X3Picture("CZ4_CDARPO") }, ; // "Área de Produção" 
	        	 { "CDCETR", "C", TamSX3("CZ4_CDCETR")[1], TamSX3("CZ4_CDCETR")[2], STR0009, .T., X3Picture("CZ4_CDCETR") }, ; // "Centro de Trabalho"
	        	 { "CDMQ"  , "C", TamSX3("CZ4_CDMQ")[1]  , TamSX3("CZ4_CDMQ")[2]  , STR0010, .T., X3Picture("CZ4_CDMQ")   }, ; // "Máquina"
	             { "QTVMPL", "N", TamSX3("CZ4_QTVMPL")[1], TamSX3("CZ4_QTVMPL")[2], STR0011, .T., X3Picture("CZ4_QTVMPL") }, ; // "Capacidade do Projeto"
	             { "QTTELZ", "N", TamSX3("CZ4_QTTELZ")[1], TamSX3("CZ4_QTTELZ")[2], STR0014, .T., X3Picture("CZ4_QTTELZ") }, ; // "Horas Disponíveis"
		         { "QTTEUT", "N", TamSX3("CZ4_QTTEUT")[1], TamSX3("CZ4_QTTEUT")[2], STR0015, .T., X3Picture("CZ4_QTTEUT") }, ; // "Horas Trabalhadas"
		         { "VLEF"  , "N", TamSX3("CZ4_VLEF")[1]  , TamSX3("CZ4_VLEF")[2]  , STR0016, .T., X3Picture("CZ4_VLEF")   }, ; // "% Eficiência"
	      	     { "QTVMEV", "N", TamSX3("CZ4_QTVMEV")[1], TamSX3("CZ4_QTVMEV")[2], STR0012, .T., X3Picture("CZ4_QTVMEV") }, ; // "Capacidade Efetiva"
	       	     { "QTVMRY", "N", TamSX3("CZ4_QTVMRY")[1], TamSX3("CZ4_QTVMRY")[2], STR0013, .T., X3Picture("CZ4_QTVMRY") } }  // "Capacidade Real"
	Return {aTabela, {"CDES","CDARPO"}}  
Else                                      
	aTabela := { { "DTRE"  , "D", TamSX3("CZ4_DTRE")[1]  , TamSX3("CZ4_DTRE")[2]  , STR0053, .T., X3Picture("CZ4_DTRE")   }, ; // "Data Referência"
				 { "HRRE"  , "C", TamSX3("CZ4_HRRE")[1]  , TamSX3("CZ4_HRRE")[2]  , STR0054, .T., X3Picture("CZ4_HRRE")   }, ; // "Hora Referência"	    
	        	 { "VLBTS" , "N", TamSX3("CZ4_VLBTS")[1] , TamSX3("CZ4_VLBTS")[2] , STR0025, .T., X3Picture("CZ4_VLBTS")  }, ; // "% BTS"			    
	        	 { "VLBTSS", "N", TamSX3("CZ4_VLBTSS")[1], TamSX3("CZ4_VLBTSS")[2], STR0026, .T., X3Picture("CZ4_VLBTSS") }, ; // "% BTS_S"			
	             { "VLBTSM", "N", TamSX3("CZ4_VLBTSM")[1], TamSX3("CZ4_VLBTSM")[2], STR0027, .T., X3Picture("CZ4_VLBTSM") }, ; // "% BTS_M"				
	             { "VLBTSV", "N", TamSX3("CZ4_VLBTSV")[1], TamSX3("CZ4_VLBTSV")[2], STR0028, .T., X3Picture("CZ4_VLBTSV") }, ; // "% BTS_V"			
		         { "VLEF"  , "N", TamSX3("CZ4_VLEF")[1]  , TamSX3("CZ4_VLEF")[2]  , STR0021, .T., X3Picture("CZ4_VLEF")   }, ; // "% Eficiencia"		
   		         { "VLNEE" , "N", TamSX3("CZ4_VLNEE")[1] , TamSX3("CZ4_VLNEE")[2] , STR0022, .T., X3Picture("CZ4_VLNEE")  }, ; // "% NEE"
        	     { "VLOEE" , "N", TamSX3("CZ4_VLOEE")[1] , TamSX3("CZ4_VLOEE")[2] , STR0023, .T., X3Picture("CZ4_VLOEE")  }, ; // "% OEE"	
        	     { "VLTEEP", "N", TamSX3("CZ4_VLTEEP")[1], TamSX3("CZ4_VLTEEP")[2], STR0024, .T., X3Picture("CZ4_VLTEEP") }, ; // "% TEEP"
        	     { "VLUT"  , "N", TamSX3("CZ4_VLUT")[1]  , TamSX3("CZ4_VLUT")[2]  , STR0018, .T., X3Picture("CZ4_VLUT")   }, ; // "% Utilização"			
	             { "VLQL"  , "N", TamSX3("CZ4_VLQL")[1]  , TamSX3("CZ4_VLQL")[2]  , STR0019, .T., X3Picture("CZ4_VLQL")   }, ; // "% Qualidade"			
		         { "VLQLRY", "N", TamSX3("CZ4_VLQLRY")[1], TamSX3("CZ4_VLQLRY")[2], STR0020, .T., X3Picture("CZ4_VLQLRY") }, ; // "% Qualidade Real"	
   		         { "VLDIPL", "N", TamSX3("CZ4_VLDIPL")[1], TamSX3("CZ4_VLDIPL")[2], STR0017, .T., X3Picture("CZ4_VLDIPL") }, ; // "% Disp. Planejada"	
        	     { "VLTK"  , "N", TamSX3("CZ4_VLTK")[1]  , TamSX3("CZ4_VLTK")[2]  , STR0041, .T., X3Picture("CZ4_VLTK")   }, ; // "Takt Time"			
        	     { "QTVMEV", "N", TamSX3("CZ4_QTVMEV")[1], TamSX3("CZ4_QTVMEV")[2], STR0029, .T., X3Picture("CZ4_QTVMEV") }, ; // "Horas Capac. Efetiva"
		         { "QTVMPL", "N", TamSX3("CZ4_QTVMPL")[1], TamSX3("CZ4_QTVMPL")[2], STR0030, .T., X3Picture("CZ4_QTVMPL") }, ; // "Horas Capac. Projeto"
   		         { "QTVMRY", "N", TamSX3("CZ4_QTVMRY")[1], TamSX3("CZ4_QTVMRY")[2], STR0031, .T., X3Picture("CZ4_QTVMRY") }, ; // "Horas Capac. Real"	
        	     { "QTATPA", "N", TamSX3("CZ4_QTATPA")[1], TamSX3("CZ4_QTATPA")[2], STR0033, .T., X3Picture("CZ4_QTATPA") }, ; // "Horas Oper. Planejad"	
        	     { "QTATRY", "N", TamSX3("CZ4_QTATRY")[1], TamSX3("CZ4_QTATRY")[2], STR0035, .T., X3Picture("CZ4_QTATRY") }, ; // "Horas Oper. Real"
        	     { "QTSUPA", "N", TamSX3("CZ4_QTSUPA")[1], TamSX3("CZ4_QTSUPA")[2], STR0032, .T., X3Picture("CZ4_QTSUPA") }, ; // "Horas Preparação Planejad"
	             { "QTSURY", "N", TamSX3("CZ4_QTSURY")[1], TamSX3("CZ4_QTSURY")[2], STR0034, .T., X3Picture("CZ4_QTSURY") }, ; // "Horas Preparação Real"		
		         { "QTSPPL", "N", TamSX3("CZ4_QTSPPL")[1], TamSX3("CZ4_QTSPPL")[2], STR0040, .T., X3Picture("CZ4_QTSPPL") }, ; // "Horas Paradas Progra"
   		         { "QTTEUT", "N", TamSX3("CZ4_QTTEUT")[1], TamSX3("CZ4_QTTEUT")[2], STR0036, .T., X3Picture("CZ4_QTTEUT") }, ; // "Horas Normais"		
        	     { "QTTEEX", "N", TamSX3("CZ4_QTTEEX")[1], TamSX3("CZ4_QTTEEX")[2], STR0037, .T., X3Picture("CZ4_QTTEEX") }, ; // "Horas Extras"		
        	     { "QTTELZ", "N", TamSX3("CZ4_QTTELZ")[1], TamSX3("CZ4_QTTELZ")[2], STR0038, .T., X3Picture("CZ4_QTTELZ") }, ; // "Horas sem Apontament"	
        	     { "QTTESP", "N", TamSX3("CZ4_QTTESP")[1], TamSX3("CZ4_QTTESP")[2], STR0039, .T., X3Picture("CZ4_QTTESP") } }  // "Horas Paradas"	
	Return {aTabela, {"DTRE", "HRRE"}}	
EndIf

Return Nil
