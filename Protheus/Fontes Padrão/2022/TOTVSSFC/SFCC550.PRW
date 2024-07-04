#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'SFCC550.CH'
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC550
Tela de Análise de Qualidade

@param  nCZ4RecNo           (Obrigatório)Recno do Registro na Tabela CZ4

@author Ana Carolina Tome Klock
@since 30/03/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SFCC550( nCZ4RecNo )
	
	Local aCoors 		:= FWGetDialogSize( oMainWnd )     	  														// Tamanho da Tela
	Local aButtons   	:= {}                              															// Botões
	Local oDlg, oTFolder                                          		   											// Componentes da Tela
	Local aTFolder   	:= { STR0001, STR0002 } 																	// Nome das Abas ## 'Dados' ## 'Gráfico'
	Local nWidthPnl     := ((aCoors[4]-20)/2)/3          // Largura
	Local nHeigthPnl    := (aCoors[3]/2.82)-13                          											// Altura
	Local aCombo        := { STR0003, STR0004, STR0005, STR0006, STR0007, STR0008 }  								// Valores do Combobox ## "1=Motivo Refugo" ## "2=Item" ## "3=Ferramenta"
																													// "4=Operação" ## "5=Diário" ## "6=Semanal"
	Private aUnidadeMed	:= { SFCXUNIDME("01"), SFCXUNIDME("02"), SFCXUNIDME("14") }								    // Unidades de Medida  
	Private aTabBrw     := SFCC550TAB( 1 )						   										    		// Array dos Campos da Temp Table
	Private oTabBrw     := SFCCriFWTa( aTabBrw )         // Temp Table da Grid
	Private cTabBrw     := oTabBrw:GetAlias()
	Private oTab        := SFCCriFWTa( SFCC550TAB( 2 ) ) // Temp Table do Gráfico
	Private cTab        := oTab:GetAlias()
	Private oChart 		:= FWChartBarComp():New()                          											// Grafico
	Private cVisualiza  := aCombo[4]                                                                                // Combobox
	Default lAutoMacao  := .F.  																	    		       

	// Busca na Tabela         
	SFCC550PRE( nCZ4RecNo )
	
	IF !lAutoMacao
		Define MsDialog oDlg Title  STR0009 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel   // 'Análise de Qualidade' 
			
			// Divisão da Janela Principal
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDlg, .F., .T. )
			oFWLayer:AddLine('TOP'   , 20, .T. )
			oFWLayer:AddLine('BUTTON', 70, .T. )
			oFWLayer:AddCollumn('DETALHES', 100, .T. ,'TOP')
			oFWLayer:AddCollumn('DADOS'   , 100, .T. ,'BUTTON')
			oFWLayer:AddWindow('DETALHES', 'DETALHES_WINDOW', STR0009, 100, .T., .F.,, 'TOP',)    // 'Análise de Qualidade' 
			oFWLayer:AddWindow('DADOS'   , 'GRID_WINDOW'    , STR0010, 100, .T., .F.,, 'BUTTON',) // 'Detalhes'
			
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
			
			TSay():New( 005, 010, { || STR0011      				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )  // "Estabelecimento" 
			TGet():New( 013, 010, { || (cTabBrw)->CDES       		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDES   )  
			TSay():New( 005, 070, { || STR0012			   			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )  // "Área de Produção"
			TGet():New( 013, 070, { || (cTabBrw)->CDARPO     		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDARPO ) 
			TSay():New( 005, 130, { || STR0013		 				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )  // "Centro de Trabalho"
			TGet():New( 013, 130, { || (cTabBrw)->CDCETR     		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDCETR ) 
			TSay():New( 005, 190, { || STR0014         				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )  // "Máquina"
			TGet():New( 013, 190, { || (cTabBrw)->CDMQ	   			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDMQ   )
			TSay():New( 028, 010, { || aUnidadeMed[1] + STR0015 	}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )  // " Qualidade"
			TGet():New( 036, 010, { || cValToChar((cTabBrw)->VLQL)  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLQL)   )  
			TSay():New( 028, 070, { || aUnidadeMed[2] + STR0016		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )  // " Qualidade Real"
			TGet():New( 036, 070, { || cValToChar((cTabBrw)->VLQLRY)}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLQLRY) )  
			TSay():New( 028, 130, { || aUnidadeMed[3] + STR0017		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )  // " Takt Time"
			TGet():New( 036, 130, { || cValToChar((cTabBrw)->VLTK)	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLTK)  ) 
			TSay():New( 028, 190, { || STR0018				   		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )  // "Visualizar:" 
			oCombo := TComboBox():New( 036, 190, { |x| if( Pcount()>0, cVisualiza := x, cVisualiza )  }, aCombo, 70, 10, oDetails, , ;
									{|x| SFCC550GRA() } , , , , .T., , , , , , , , , 'cVisualiza' ) 

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
			oChart:setLegend( CONTROL_ALIGN_RIGHT )
			SFCC550GRA( cVisualiza )
			
		Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },,aButtons,,,,,, .F. )
	ENDIF
	
	oTabBrw:Delete()
	oTab:Delete()
	
Return NIL 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC550GRA
Monta o gráfico de acordo com a selecao                                            

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC550GRA( )  
    Local nX := 0
    Local aRefugo := { }
    Local aRetrab := { }
    Default lAutoMacao := .T.

	IF !lAutoMacao
		// Preenche a Temp Table
		SFCC550REP( )
	ENDIF   
   	 	 
   	// Rotula a opção sendo mostrada   	   
   	If cVisualiza == "1"
		cVisualiza = STR0019 //"Motivo Refugo"
   	ElseIf cVisualiza == "2"
		cVisualiza = STR0020 //"Item"
   	ElseIf cVisualiza == "3"
		cVisualiza = STR0021 //"Ferramenta"
	ElseIf cVisualiza == '4'
	    cVisualiza = STR0022 //"Operação"
	ElseIf cVisualiza == "5"
		cVisualiza = STR0023 //"Diário"
	Else
	    cVisualiza = STR0024 //"Semanal"
	EndIf 

	IF !lAutoMacao
		// Reseta o gráfico e atualiza	       
		oChart:Reset()         
		oChart:setTitle( cVisualiza , CONTROL_ALIGN_CENTER )
		dbSelectArea( cTab )
		dbGoTop()
		While (cTab)->(!EOF())
			If cVisualiza != STR0023 .And. cVisualiza != STR0024.And. AllTrim((cTab)->NOME) != ":  -" .And. AllTrim((cTab)->NOME) != "-"    // "Diário" ## "Semanal" 
				Aadd(aRefugo, { (cTab)->NOME, (cTab)->REFUGO } )
				Aadd(aRetrab, { (cTab)->NOME, (cTab)->RETRAB } )
				nX++
			ElseIf cVisualiza == STR0023 .And. !Empty((cTab)->DTBG) // "Diário"
				Aadd(aRefugo, { cValToChar((cTab)->DTBG), (cTab)->REFUGO } )
				Aadd(aRetrab, { cValToChar((cTab)->DTBG), (cTab)->RETRAB } )
				nX++
			ElseIf cVisualiza == STR0024 // "Semanal"
				Aadd(aRefugo, { cValToChar((cTab)->DTBG) + STR0025 + cValToChar((cTab)->DTED), (cTab)->REFUGO } )  // " até "
				Aadd(aRetrab, { cValToChar((cTab)->DTBG) + STR0025 + cValToChar((cTab)->DTED), (cTab)->RETRAB } )  // " até "
				nX++
			EndIf
			(cTab)->(dbSkip())
		End 
		
		// Aviso que a consulta não retornou resultados
		If nX = 0
			oChart:setTitle( STR0026 + cVisualiza, CONTROL_ALIGN_CENTER )  // "Sem resultados para consultas baseadas em "
		Else
			oChart:addSerie( STR0027 , aRefugo ) // "Refugo"
			oChart:addSerie( STR0028 , aRetrab ) // "Retrabalho"
		EndIf        
		
		oChart:Build()
	ENDIF

Return Nil    
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC550PRE
Preenche a tabela temporária da Grid

@param 	nCZ4RecNo 		(Obrigatório) Recno da Tabela  

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC550PRE( nCZ4RecNo )

	// Realiza a busca na Tabela
	dbSelectArea( "CZ4" )
	dbGoTo( nCZ4RecNo )	
	
	// Preenche a tabela temporária                               
	RecLock( cTabBrw, .T.) 
		(cTabBrw)->CDES   := CZ4->CZ4_CDES
		(cTabBrw)->CDARPO := CZ4->CZ4_CDARPO
		(cTabBrw)->CDCETR := CZ4->CZ4_CDCETR
		(cTabBrw)->CDMQ   := CZ4->CZ4_CDMQ
		(cTabBrw)->DSMQ   := POSICIONE("CYB",1,XFILIAL("CYB")+CZ4->CZ4_CDMQ, "CYB_DSMQ") 
		(cTabBrw)->QTAP   := Round( CZ4->CZ4_QTRPRY, 2 )
		(cTabBrw)->QTRF   := Round( CZ4->CZ4_QTRFRY, 2 )
		(cTabBrw)->QTRT   := Round( CZ4->CZ4_QTRTRY, 2 )
		(cTabBrw)->VLQL   := Round( CZ4->CZ4_VLQL, 2 )
		(cTabBrw)->VLQLRY := Round( CZ4->CZ4_VLQLRY, 2 )
		(cTabBrw)->VLTK   := Round( CZ4->CZ4_VLTK, 2 )
		(cTabBrw)->IDMEPO := CZ4->CZ4_IDMEPO
	MsUnlock() 
		
	CZ4->(dbCloseArea()) 

Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC550REP
Preenche a Temp Table com os dados que serão utilizados no gráfico                                           

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC550REP( )
	Local cCampo, cGroup
	Default lAutoMacao := .T.

	IF !lAutoMacao
		// Limpa a Temp Table
		dbSelectArea(cTab)
		ZAP
	ENDIF
    
    // Define os campos para agrupamento 
    If cVisualiza == "1"
   		cCampo := "CZ5.CZ5_CDRF"
   		cGroup := "CZ5.CZ5_CDRF"
	ElseIf cVisualiza == "2"                                                              
		cCampo := "CZ5.CZ5_CDAC"
		cGroup := "CZ5.CZ5_CDAC"   
	ElseIf cVisualiza == "3"
   		cCampo := "CZ5.CZ5_CDFEPO" 
   		cGroup := "CZ5.CZ5_CDFEPO"
    ElseIf cVisualiza == "4"
		cCampo := "CZ5.CZ5_IDAT, CZ5.CZ5_NRORPO"
		cGroup := "CZ5.CZ5_IDAT, CZ5.CZ5_NRORPO"
   	Else
   		cCampo := "CZ5.CZ5_DTED"
   		cGroup := "CZ5.CZ5_DTED ORDER BY CZ5.CZ5_DTED"		
 	EndIf
    
	IF !lAutoMacao
		// Realiza a busca na Tabela
		dbSelectArea("CZ5")
		cQuery := "SELECT " + cCampo + ", SUM(CZ5_QTRT) AS QTRT, SUM(CZ5_QTRF) AS QTRF FROM " + RetSQLName( 'CZ5' ) + " CZ5 "
		cQuery += " WHERE CZ5.CZ5_FILIAL = '" + xFilial('CZ5')    + "'  AND "
		cQuery += " 	  CZ5.CZ5_CDES   = '" + (cTabBrw)->CDES   + "' AND "
		cQuery += " 	  CZ5.CZ5_CDARPO = '" + (cTabBrw)->CDARPO + "' AND "
		cQuery += " 	  CZ5.CZ5_CDCETR = '" + (cTabBrw)->CDCETR + "' AND "
		cQuery += " 	  CZ5.CZ5_CDMQ   = '" + (cTabBrw)->CDMQ   + "' AND "
		cQuery += " 	  CZ5.CZ5_IDMEPO = '" + (cTabBrw)->IDMEPO + "' AND "
		cQuery += "       CZ5.CZ5_TPMV   = '4' AND "
		cQuery += " CZ5.D_E_L_E_T_ = ' ' GROUP BY " + cGroup
		cCZ5   := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cCZ5, .T., .F. )     
		
		// Preenche a tabela temporária
		While (cCZ5)->(!EOF() ) 
			If cVisualiza == "1"
				RecLock( cTab, .T.)
				(cTab)->NOME   := (cCZ5)->CZ5_CDRF  
				(cTab)->REFUGO := Round((cCZ5)->QTRF, 2 )
				(cTab)->RETRAB := Round((cCZ5)->QTRT, 2 )
				MsUnlock()
			ElseIf cVisualiza == "2"                                                              
				RecLock( cTab, .T.)
				(cTab)->NOME   := AllTrim((cCZ5)->CZ5_CDAC) + " - " + POSICIONE("CZ3",1,XFILIAL("CZ3")+(cCZ5)->CZ5_CDAC, "CZ3_DSAC")  
				(cTab)->REFUGO := Round((cCZ5)->QTRF, 2 )
				(cTab)->RETRAB := Round((cCZ5)->QTRT, 2 )
				MsUnlock() 
			ElseIf cVisualiza == "3"
				RecLock( cTab, .T.)
				(cTab)->NOME   := AllTrim((cCZ5)->CZ5_CDFEPO) + " - " + POSICIONE("CYH",1,XFILIAL("CYH")+"2"+CZ5->CZ5_CDFEPO, "CYH_NMRC") 
				(cTab)->REFUGO := Round((cCZ5)->QTRF, 2 )
				(cTab)->RETRAB := Round((cCZ5)->QTRT, 2 )
				MsUnlock() 
			ElseIf cVisualiza == "4"
				dbSelectArea("CY9")
				cQueryCY9 := "SELECT CY9_DSAT FROM " + RetSQLName( 'CY9' ) + " CY9 "
				cQueryCY9 += " WHERE CY9.CY9_FILIAL = '" + xFilial('CY9') + "'  AND "
				cQueryCY9 += "       CY9.CY9_IDAT   = '" + (cCZ5)->CZ5_IDAT + "' AND "  
				cQueryCY9 += "		 CY9.CY9_NRORPO = '" + (cCZ5)->CZ5_NRORPO + "' AND "
				cQueryCY9 += "       CY9.D_E_L_E_T_ = ' ' GROUP BY CY9_DSAT ORDER BY CY9_DSAT "
				cCY9      := GetNextAlias()
				dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQueryCY9), cCY9, .T., .F. )                                                                                                                                                                                         
				While (cCY9)->(!EOF())
					If (cTab)->( dbSeek(AllTrim((cCY9)->CY9_DSAT))) 
						RecLock( cTab, .F.)                                                                                                                                                                      
						(cTab)->REFUGO += Round((cCZ5)->QTRF, 2 )
						(cTab)->RETRAB += Round((cCZ5)->QTRT, 2 )
						MsUnlock()    
					Else
						RecLock( cTab, .T.)                                                                                                                                                                      
						(cTab)->NOME   := AllTrim((cCY9)->CY9_DSAT)
						(cTab)->REFUGO := Round((cCZ5)->QTRF, 2 )
						(cTab)->RETRAB := Round((cCZ5)->QTRT, 2 )
						MsUnlock()    
					EndIf
					(cCY9)->(dbSkip())                                                     
				End  
				(cCY9)->(dbCloseArea())
			ElseIf cVisualiza == "5"
				RecLock( cTab, .T.)
				(cTab)->DTBG   := STOD((cCZ5)->CZ5_DTED)   
				(cTab)->REFUGO := Round((cCZ5)->QTRF, 2 )
				(cTab)->RETRAB := Round((cCZ5)->QTRT, 2 )
				MsUnlock()
			Else     
				If (cTab)->( dbSeek( DTOS(STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1)) )) 
					RecLock( cTab, .F.)
					(cTab)->REFUGO += Round((cCZ5)->QTRF, 2 )
					(cTab)->RETRAB += Round((cCZ5)->QTRT, 2 )
					MsUnlock()
				Else
					RecLock( cTab, .T.)        
					(cTab)->NOME   := DTOS(STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1))
					(cTab)->DTBG   := STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1)
					(cTab)->DTED   := STOD((cCZ5)->CZ5_DTED) + (7-DOW(STOD((cCZ5)->CZ5_DTED))) 
					(cTab)->REFUGO := Round((cCZ5)->QTRF, 2 )
					(cTab)->RETRAB := Round((cCZ5)->QTRT, 2 )
					MsUnlock()  
				EndIf
			EndIf
			(cCZ5)->(dbSkip())
		End                 
		(cCZ5)->(dbCloseArea())
	ENDIF
    
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC550TAB 
Cria as tabelas a serem usadas 

@param  nTab 	          (Obrigatório) Número da tabela que será criada

@author Ana Carolina Tome Klock
@since 29/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function SFCC550TAB( nTab )
Local aTabela	:= {}
Local cChave 	:= ''                              
	
If nTab == 1
	aTabela := { { "CDES"  , "C", TamSX3("CZ4_CDES")[1]  , TamSX3("CZ4_CDES")[2]  , STR0011, .T., X3Picture("CZ4_CDES")   }, ;  // "Estabelecimento"
	  	 		 { "CDARPO", "C", TamSX3("CZ4_CDARPO")[1], TamSX3("CZ4_CDARPO")[2], STR0012, .T., X3Picture("CZ4_CDARPO") }, ;  // "Área de Produção"
        		 { "CDCETR", "C", TamSX3("CZ4_CDCETR")[1], TamSX3("CZ4_CDCETR")[2], STR0013, .T., X3Picture("CZ4_CDCETR") }, ;  // "Centro de Trabalho"
        		 { "CDMQ"  , "C", TamSX3("CZ4_CDMQ")[1]  , TamSX3("CZ4_CDMQ")[2]  , STR0014, .T., X3Picture("CZ4_CDMQ")   }, ;  // "Máquina"
            	 { "DSMQ"  , "C", TamSX3("CYB_DSMQ")[1]  , TamSX3("CYB_DSMQ")[2]  , STR0029, .T., X3Picture("CYB_DSMQ")   }, ;  // "Descrição Máquina"
            	 { "QTAP"  , "N", TamSX3("CZ4_QTRPRY")[1], TamSX3("CZ4_QTRPRY")[2], STR0030, .T., X3Picture("CZ4_QTRPRY") }, ;  // "Quant. Aprovada"
            	 { "QTRF"  , "N", TamSX3("CZ4_QTRFRY")[1], TamSX3("CZ4_QTRFRY")[2], STR0031, .T., X3Picture("CZ4_QTRFRY") }, ;  // "Quant. Refugada"
            	 { "QTRT"  , "N", TamSX3("CZ4_QTRTRY")[1], TamSX3("CZ4_QTRTRY")[2], STR0032, .T., X3Picture("CZ4_QTRTRY") }, ;  // "Quant. Retrabalhada"
            	 { "VLQL"  , "N", TamSX3("CZ4_VLQL")[1]  , TamSX3("CZ4_VLQL")[2]  , STR0015, .T., X3Picture("CZ4_VLQL")   }, ;  // " Qualidade"
            	 { "VLQLRY", "N", TamSX3("CZ4_VLQLRY")[1], TamSX3("CZ4_VLQLRY")[2], STR0016, .T., X3Picture("CZ4_VLQLRY") }, ;  // " Qualidade Real"
            	 { "VLTK"  , "N", TamSX3("CZ4_VLTK")[1]  , TamSX3("CZ4_VLTK")[2]  , STR0017, .T., X3Picture("CZ4_VLTK")   }, ;  // " Takt Time"                                              
		  		 { "IDMEPO", "C", TamSX3("CZ4_IDMEPO")[1], TamSX3("CZ4_IDMEPO")[2],'IDMEPO', .F., X3Picture("CZ4_IDMEPO") } }    
	cChave := {"CDES","CDARPO"}                         
ElseIf nTab == 2 
	aTabela := { { "NOME"  , "C", 100, 0, STR0033  , .T., "!@" } , ; // "Nome"
		  		 { "DTBG"  , "D", TamSX3("CZ5_DTBG")[1], TamSX3("CZ5_DTBG")[2], STR0034, .T., X3Picture("CZ5_DTBG") }, ; // "Data Inicial"
				 { "DTED"  , "D", TamSX3("CZ5_DTED")[1], TamSX3("CZ5_DTED")[2], STR0035, .T., X3Picture("CZ5_DTED") }, ; // "Data Final"
	 		  	 { "REFUGO", "N", TamSX3("CZ5_QTRF")[1], TamSX3("CZ5_QTRF")[2], STR0027, .T., X3Picture("CZ5_QTRF") }, ; // "Refugo"
	    	     { "RETRAB", "N", TamSX3("CZ5_QTRT")[1], TamSX3("CZ5_QTRT")[2], STR0028, .T., X3Picture("CZ5_QTRT") } }  // "Retrabalho"  
	cChave := {"NOME"} 		
EndIf

Return { aTabela, cChave }
