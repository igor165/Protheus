#INCLUDE 'PROTHEUS.CH'      
#INCLUDE 'FWMVCDEF.CH'      
#INCLUDE 'SFCC530.CH'
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC530
Tela de Análise de Eficiência

@param  nCZ4Recno           (Obrigatório) Recno do Registro na Tabela CZ4

@author Ana Carolina Tome Klock
@since 28/03/2011
@version P11

/*/
//--------------------------------------------------------------------------------------------------------------------
Function SFCC530( nCZ4Recno )
Local aCoors 		:= FWGetDialogSize( oMainWnd )     	  											   				// Tamanho da Tela
Local aButtons   	:= {}                              												  				// Botões
Local oDlg, oTFolder                                          		   												// Componentes da Tela
Local aTFolder   	:= { STR0001, STR0002 } 																		// Nome das Abas ## 'Dados' ## 'Gráfico'
Local nWidthPnl     := ((aCoors[4]-16)/2)/3                     									    			// Largura
Local nHeigthPnl    := (aCoors[3]/2.82)-13                          								   				// Altura
Local aCombo        := { STR0003, STR0004, STR0005, STR0006, STR0007, STR0008, STR0009 }  							// Valores do Combobox ## "1=Operação" ## "2=Item" ## "3=Operador"
																													// "4=Turno" ##  "5=Ferramenta" ## "6=Diário" ## "7=Semanal"
Local aUnidadeMed   := { SFCXUNIDME("07"), SFCXUNIDME("08"), SFCXUNIDME("09"), SFCXUNIDME("03"), SFCXUNIDME("04") } // Unidades de Medida para NEE, OEE, TEEP, Ef e Ut
Private aTabBrw     := SFCC530TAB( 1 )						   													    // Array dos Campos da Temp Table
Private oTabBrw     := SFCCriFWTa( aTabBrw )                                              // Temp Table da Grid
Private cTabBrw     := oTabBrw:GetAlias()
Private oTab        := SFCCriFWTa( SFCC530TAB( 2 ) )                                      // Temp Table do Gráfico
Private cTab        := oTab:GetAlias()   
Private oChart 		:= FWChartBarComp():New()                          												// Grafico
Private cVisualiza  := aCombo[1]  																	    			// Combobox   
Default lAutoMacao  := .F.   

// Busca na Tabela
SFCC530PRE( nCZ4RecNo )

IF !lAutoMacao	
	Define MsDialog oDlg Title  STR0010  FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel   // 'Análise de Eficiência'
				
		// Divisão da Janela Principal
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlg, .F., .T. )
		oFWLayer:AddLine('TOP'   , 20, .T. )
		oFWLayer:AddLine('BUTTON', 70, .T. )
		oFWLayer:AddCollumn('DETALHES', 100, .T. ,'TOP')
		oFWLayer:AddCollumn('DADOS'   , 100, .T. ,'BUTTON')
		oFWLayer:AddWindow('DETALHES', 'DETALHES_WINDOW', STR0010, 100, .T., .F.,, 'TOP',)     // 'Análise de Eficiência'
		oFWLayer:AddWindow('DADOS'   , 'GRID_WINDOW'    , STR0011, 100, .T., .F.,, 'BUTTON',)  // 'Detalhes'
		
		// Layers que serão usadas
		oPanelUp := oFWLayer:GetWinPanel ( 'DETALHES','DETALHES_WINDOW', 'TOP' )
		oPanelGr := oFWLayer:GetWinPanel ( 'DADOS','GRID_WINDOW', 'BUTTON' )
		
		// Detalhe Superior 
		oScroll := TScrollArea():New(oPanelUp,01,01,(nWidthPnl * 3) - 4,(nHeigthPnl/5) - 4,.T.,.T.,.T.)
		oScroll:Align := CONTROL_ALIGN_ALLCLIENT

		// Cria painel 
		oDetails := TPanel():New( 01, 01, /*cText*/, oScroll, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, 350, 75 ) 
		
		// Define objeto painel como filho do scroll
		oScroll:SetFrame( oDetails )    
			
		TSay():New( 005, 010, { || STR0012				   			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // "Estabelecimento" 
		TGet():New( 013, 010, { || (cTabBrw)->CDES       			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDES   )  
		TSay():New( 005, 070, { || STR0013				   			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // "Área de Produção"
		TGet():New( 013, 070, { || (cTabBrw)->CDARPO     			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDARPO ) 
		TSay():New( 005, 130, { || STR0014							}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // "Centro de Trabalho" 
		TGet():New( 013, 130, { || (cTabBrw)->CDCETR     			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDCETR ) 
		TSay():New( 005, 190, { || STR0015	            			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // "Máquina"
		TGet():New( 013, 190, { || (cTabBrw)->CDMQ	   				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDMQ   ) 
		TSay():New( 005, 250, { || STR0016			       			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // "Tempo Projetado"
		TGet():New( 013, 250, { || cValToChar((cTabBrw)->QTATPA)   	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTATPA) )  
		TSay():New( 005, 310, { || STR0017			    			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // "Tempo Real"
		TGet():New( 013, 310, { || cValToChar((cTabBrw)->QTATRY)  	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTATRY) ) 
		TSay():New( 028, 010, { || aUnidadeMed[4] + STR0018			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // " Eficiencia"
		TGet():New( 036, 010, { || cValToChar((cTabBrw)->VLEF)		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLEF)   )
		TSay():New( 028, 070, { || aUnidadeMed[5] + STR0019			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // " Utilização"                                     
		TGet():New( 036, 070, { || cValToChar((cTabBrw)->VLUT)		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLUT)   ) 
		TSay():New( 028, 130, { || aUnidadeMed[1] + STR0020			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // " NEE" 
		TGet():New( 036, 130, { || cValToChar((cTabBrw)->VLNEE)  	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLNEE)  ) 
		TSay():New( 028, 190, { || aUnidadeMed[2] + STR0021  		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // " OEE"
		TGet():New( 036, 190, { || cValToChar((cTabBrw)->VLOEE)		}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLOEE)  )
		TSay():New( 028, 250, { || aUnidadeMed[3] + STR0022 		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // " TEEP"
		TGet():New( 036, 250, { || cValToChar((cTabBrw)->VLTEEP)	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLTEEP) )
		TSay():New( 051, 010, { || STR0023			       			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )    // "Visualizar:" 
		oCombo := TComboBox():New( 059, 010, { |x| if( Pcount()>0, cVisualiza := x, cVisualiza )  }, aCombo, 70, 10, oDetails, , ;
								{|x| SFCC530GRA( ) } , , , , .T., , , , , , , , , 'cVisualiza' ) 

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
		SFCC530GRA( cVisualiza )
			
	Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },,aButtons,,,,,, .F. )

ENDIF

oTabBrw:Delete()
oTab:Delete()

	
Return NIL 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC530GRA
Monta o gráfico de acordo com a selecao                                            

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC530GRA( )  
	Local nX      := 0
    Local aPadrao := {}
    Local aReal   := {}
    Default lAutoMacao := .F.
	
	IF !lAutoMacao
		// Preenche a Temp Table
		SFCC530REP( ) 
	ENDIF
   	
   	// Rotula a opção sendo mostrada   	   
   	If cVisualiza == "1"
		cVisualiza = STR0024 // "Operação"
   	ElseIf cVisualiza == "2"
		cVisualiza = STR0025 // "Item"
   	ElseIf cVisualiza == "3"
		cVisualiza = STR0026 // "Operador"
	ElseIf cVisualiza == '4'
	    cVisualiza = STR0027 // "Turno"
	ElseIf cVisualiza == "5"
		cVisualiza = STR0028 // "Ferramenta"
   	ElseIf cVisualiza == "6"
		cVisualiza = STR0029 // "Diário"
	Else
	    cVisualiza = STR0030 // "Semanal"
	EndIf    	        
	
	IF !lAutoMacao
		// Reseta o gráfico e atualiza	       
		oChart:Reset()         
		oChart:setTitle( STR0031 + cVisualiza , CONTROL_ALIGN_CENTER ) // "Tempo de Produção: "	
		dbSelectArea( cTab )
		dbGoTop()
		While (cTab)->(!EOF())
			If cVisualiza != STR0029 .And. cVisualiza != STR0030 .And. AllTrim((cTab)->NOME) != ":  -" .And. AllTrim((cTab)->NOME) != "-" // "Diário" ## "Semanal"
				Aadd(aPadrao, { (cTab)->NOME, (cTab)->PADRAO } )
				Aadd(aReal,   { (cTab)->NOME, (cTab)->OPERAC } )
				nX++
			ElseIf cVisualiza == STR0029 .And. !Empty((cTab)->DTBG) // "Diário"
				Aadd(aPadrao, { cValToChar((cTab)->DTBG), (cTab)->PADRAO } )
				Aadd(aReal,   { cValToChar((cTab)->DTBG), (cTab)->OPERAC } )
				nX++
			ElseIf cVisualiza == STR0030  // "Semanal"
				Aadd(aPadrao, { cValToChar((cTab)->DTBG) + STR0032 + cValToChar((cTab)->DTED), (cTab)->PADRAO } )     // " até "
				Aadd(aReal,   { cValToChar((cTab)->DTBG) + STR0032 + cValToChar((cTab)->DTED), (cTab)->OPERAC } )     // " até "
				nX++
			EndIf
			(cTab)->(dbSkip())
		End 
		
		// Aviso que a consulta não retornou resultados
		If nX = 0
			oChart:setTitle( STR0033 + cVisualiza, CONTROL_ALIGN_CENTER )  // "Sem resultados para consultas baseadas em "
		Else
			oChart:addSerie( STR0034, aPadrao )  // "Tempo Padrão"
			oChart:addSerie( STR0017,   aReal )  // "Tempo Real"
		EndIf 
		
		oChart:Build()
	ENDIF

Return Nil    
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC530PRE
Preenche a tabela temporária da Grid      

@param 		nCZ4Recno 		(Obrigatório) Recno do Registro na Tabela CZ4

@author 	Ana Carolina Tome Klock
@since 		06/04/2011
@version 	1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC530PRE( nCZ4Recno )
	    
dbSelectArea( "CZ4" )
dbGoTo( nCZ4Recno )	
	
// Preenche os dados do browse
RecLock( cTabBrw, .T.)    
	(cTabBrw)->DTRE   := DTOS(CZ4->CZ4_DTRE)
	(cTabBrw)->HRRE   := CZ4->CZ4_HRRE
	(cTabBrw)->CDES   := CZ4->CZ4_CDES
	(cTabBrw)->CDARPO := CZ4->CZ4_CDARPO
	(cTabBrw)->CDCETR := CZ4->CZ4_CDCETR
	(cTabBrw)->CDMQ   := CZ4->CZ4_CDMQ
	(cTabBrw)->DSMQ   := POSICIONE("CYB",1,XFILIAL("CYB")+CZ4->CZ4_CDMQ, "CYB_DSMQ") 
	(cTabBrw)->QTATPA := CZ4->CZ4_QTATPA
	(cTabBrw)->QTATRY := CZ4->CZ4_QTATRY                                                                  
	(cTabBrw)->QTRP   := CZ4->CZ4_QTRP
	(cTabBrw)->QTRPRY := CZ4->CZ4_QTRPRY
	(cTabBrw)->QTRFRY := CZ4->CZ4_QTRFRY
	(cTabBrw)->QTRTRY := CZ4->CZ4_QTRTRY
	(cTabBrw)->VLEF   := Round( CZ4->CZ4_VLEF, 2 )
	(cTabBrw)->VLUT   := Round( CZ4->CZ4_VLUT, 2 )
	(cTabBrw)->VLNEE  := Round( CZ4->CZ4_VLNEE, 2 )
	(cTabBrw)->VLOEE  := Round( CZ4->CZ4_VLOEE, 2 )
	(cTabBrw)->VLTEEP := Round( CZ4->CZ4_VLTEEP, 2 )   
	(cTabBrw)->IDMEPO := CZ4->CZ4_IDMEPO
MsUnlock()  
	
CZ4->(dbCloseArea())

Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC530REP
Preenche a Temp Table com os dados que serão utilizados no gráfico                                           

@param  cTab           (Obrigatório) Temp Table que será preenchida

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC530REP( )
	Local cCampo, cGroup, cQuery, cQueryCY9, cCZ5, cCY9  
	Default lAutoMacao := .F.
	
	IF !lAutoMacao
		// Limpa a Temp Table
		dbSelectArea(cTab)
		ZAP
	ENDIF
    
	// Define os campos para agrupamento                                 
   	If cVisualiza == "1"
		cCampo = "CZ5.CZ5_IDAT, CZ5.CZ5_NRORPO"
		cGroup = "CZ5.CZ5_IDAT, CZ5.CZ5_NRORPO"
	ElseIf cVisualiza == "2" 
   		cCampo = "CZ5.CZ5_CDAC"
   		cGroup = "CZ5.CZ5_CDAC"
	ElseIf cVisualiza == "3"
	   	cCampo = "CZ5.CZ5_CDOE"
	   	cGroup = "CZ5.CZ5_CDOE"
	ElseIf cVisualiza == "4"
  		cCampo = "CZ5.CZ5_CDTN"
  		cGroup = "CZ5.CZ5_CDTN"
 	ElseIf cVisualiza == "5"
 		cCampo = "CZ5.CZ5_CDFEPO"
 		cGroup = "CZ5.CZ5_CDFEPO"
 	Else          
  		cCampo = "CZ5.CZ5_DTED"
   		cGroup = "CZ5.CZ5_DTED ORDER BY CZ5.CZ5_DTED"
   	EndIf   
   	
    // Realiza a busca na Tabela
   	dbSelectArea("CZ5")
	CZ5->( dbSetOrder( 1 ) )	
	IF !lAutoMacao
		cQuery := "SELECT " + cCampo + ", SUM(CZ5_HRSUPA) AS PADRAO, SUM(CZ5_HRTEAT) AS OPERAC FROM " + RetSQLName( 'CZ5' ) + " CZ5 "
		cQuery += " WHERE CZ5.CZ5_FILIAL = '" + xFilial('CZ5')    + "' AND "
		cQuery += "       CZ5.CZ5_DTRE   = '" + (cTabBrw)->DTRE   + "' AND "
		cQuery += "       CZ5.CZ5_HRRE   = '" + (cTabBrw)->HRRE   + "' AND "
		cQuery += " 	  CZ5.CZ5_CDES   = '" + (cTabBrw)->CDES   + "' AND "
		cQuery += " 	  CZ5.CZ5_CDARPO = '" + (cTabBrw)->CDARPO + "' AND "
		cQuery += " 	  CZ5.CZ5_CDCETR = '" + (cTabBrw)->CDCETR + "' AND "
		cQuery += " 	  CZ5.CZ5_CDMQ   = '" + (cTabBrw)->CDMQ   + "' AND " 
		cQuery += " 	  CZ5.CZ5_IDMEPO = '" + (cTabBrw)->IDMEPO + "' AND "
		cQuery += " 	( CZ5.CZ5_TPMV   = '1' "
		If cVisualiza == '3'
			cQuery += " OR CZ5.CZ5_TPMV = '2' " 
		EndIf
		cQuery += ") AND CZ5.D_E_L_E_T_ = ' ' GROUP BY " + cGroup 
		cCZ5   := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cCZ5, .T., .F. )     

		// Preenche a tabela temporária
		While (cCZ5)->(!EOF() ) 
			If cVisualiza == "1"
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
						(cTab)->PADRAO += Round((cCZ5)->PADRAO, 2 )
						(cTab)->OPERAC += Round((cCZ5)->OPERAC, 2 )
						MsUnlock()    
					Else
						RecLock( cTab, .T.)                                                                                                                                                                      
						(cTab)->NOME   := AllTrim((cCY9)->CY9_DSAT)
						(cTab)->PADRAO := Round((cCZ5)->PADRAO, 2 )
						(cTab)->OPERAC := Round((cCZ5)->OPERAC, 2 )
						MsUnlock()    
					EndIf
					(cCY9)->(dbSkip())                                                     
				End  
				(cCY9)->(dbCloseArea())  
			ElseIf cVisualiza == "2"  
				RecLock( cTab, .T.)                                                            
				(cTab)->NOME   := AllTrim((cCZ5)->CZ5_CDAC) + " - " + POSICIONE("CZ3",1,XFILIAL("CZ3")+(cCZ5)->CZ5_CDAC, "CZ3_DSAC")   
			ElseIf cVisualiza == "3"
				RecLock( cTab, .T.)  
				(cTab)->NOME   := AllTrim((cCZ5)->CZ5_CDOE) + " - " + POSICIONE("CYH",1,XFILIAL("CYH")+"1"+(cCZ5)->CZ5_CDOE, "CYH_NMRC")    
			ElseIf cVisualiza == "4" 
				RecLock( cTab, .T.)  
				(cTab)->NOME   := AllTrim((cCZ5)->CZ5_CDTN) + " - " + POSICIONE("CYM",1,XFILIAL("CYM")+(cCZ5)->CZ5_CDTN, "CYM_DSTN")  
			ElseIf cVisualiza == "5"
				RecLock( cTab, .T.)  
				(cTab)->NOME   := AllTrim((cCZ5)->CZ5_CDFEPO) + " - " + POSICIONE("CYH",1,XFILIAL("CYH")+"2"+(cCZ5)->CZ5_CDFEPO, "CYH_NMRC")  
			ElseIf cVisualiza == "6"
				RecLock( cTab, .T.)  
				(cTab)->DTBG   := STOD((cCZ5)->CZ5_DTED)
				(cTab)->DTED   := STOD((cCZ5)->CZ5_DTED)
			Else 
				If (cTab)->( dbSeek( DTOS(STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1)) )) 
					RecLock( cTab, .F.)
					(cTab)->PADRAO += Round((cCZ5)->PADRAO, 2 )
					(cTab)->OPERAC += Round((cCZ5)->OPERAC, 2 )
					MsUnlock()
				Else
					RecLock( cTab, .T.)        
					(cTab)->NOME   := DTOS(STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1))
					(cTab)->DTBG   := STOD((cCZ5)->CZ5_DTED) - (DOW(STOD((cCZ5)->CZ5_DTED))-1)
					(cTab)->DTED   := STOD((cCZ5)->CZ5_DTED) + (7-DOW(STOD((cCZ5)->CZ5_DTED))) 
					(cTab)->PADRAO := Round((cCZ5)->PADRAO, 2 )
					(cTab)->OPERAC := Round((cCZ5)->OPERAC, 2 )
					MsUnlock()  
				EndIf
			EndIf
			If Val(cVisualiza) > 1 .And. Val(cVisualiza) < 7
				(cTab)->PADRAO := Round((cCZ5)->PADRAO, 2 )
				(cTab)->OPERAC := Round((cCZ5)->OPERAC, 2 )
				MsUnlock()   
			EndIf
			(cCZ5)->(dbSkip())
		End             
    	(cCZ5)->(dbCloseArea())
	ENDIF
    
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC530TAB 
Cria as tabelas a serem usadas 

@param  nTab 	          (Obrigatório) Número da tabela que será criada    
							1 = Tabela temporária do Browse
							2 = Tabela temporária do Gráfico

@author 	Ana Carolina Tome Klock
@since 		29/03/2011
@version 	1.0
/*///------------------------------------------------------------------------------------------------
Static Function SFCC530TAB( nTab )
Local aTabela := {}
Local cChave  := ''
                               
If nTab == 1                                                     
	aTabela := { { "DTRE"  , "C", 10, 0, 'DATA', .F. , "@!" 		  	   } , ; 
				 { "HRRE"  , "C", 08, 0, 'HORA', .F. , "@!" 		 	   } , ;   
				 { "CDES"  , "C", TamSX3("CZ4_CDES")[1]	 , TamSX3("CZ4_CDES")[2]  , STR0012, .T., X3Picture("CYA_CDES")   } , ;	// "Estabelecimento"
	  		     { "CDARPO", "C", TamSX3("CZ4_CDARPO")[1], TamSX3("CZ4_CDARPO")[2], STR0013, .T., X3Picture("CYA_CDARPO") } , ;	// "Área de Produção" 
    	         { "CDCETR", "C", TamSX3("CZ4_CDCETR")[1], TamSX3("CZ4_CDCETR")[2], STR0014, .T., X3Picture("CYI_CDCETR") } , ; // "Centro de Trabalho" 
    	         { "CDMQ"  , "C", TamSX3("CZ4_CDMQ")[1]  , TamSX3("CZ4_CDMQ")[2]  , STR0015, .T., X3Picture("CYB_CDMQ")   } , ; // "Máquina"
    	         { "DSMQ"  , "C", TamSX3("CYB_DSMQ")[1]  , TamSX3("CYB_DSMQ")[2]  , STR0035, .T., X3Picture("CYB_DSMQ")   } , ; // "Descrição Máquina"
       		     { "QTATPA", "N", TamSX3("CZ4_QTATPA")[1], TamSX3("CZ4_QTATPA")[2], STR0016, .T., X3Picture("CZ4_QTATPA") } , ; // "Tempo Projetado"
        	   	 { "QTATRY", "N", TamSX3("CZ4_QTATRY")[1], TamSX3("CZ4_QTATRY")[2], STR0017, .T., X3Picture("CZ4_QTATRY") } , ; // "Tempo Real" 
           		 { "QTRP"  , "N", TamSX3("CZ4_QTRP")[1]  , TamSX3("CZ4_QTRP")[2]  , STR0036, .T., X3Picture("CZ4_QTRP")   } , ; // "Quant. Projetada"
            	 { "QTRPRY", "N", TamSX3("CZ4_QTRPRY")[1], TamSX3("CZ4_QTRPRY")[2], STR0037, .T., X3Picture("CZ4_QTRPRY") } , ; // "Quant. Real"
            	 { "QTRFRY", "N", TamSX3("CZ4_QTRFRY")[1], TamSX3("CZ4_QTRFRY")[2], STR0038, .T., X3Picture("CZ4_QTRFRY") } , ; // "Quant. Refugo"
            	 { "QTRTRY", "N", TamSX3("CZ4_QTRTRY")[1], TamSX3("CZ4_QTRTRY")[2], STR0039, .T., X3Picture("CZ4_QTRTRY") } , ; // "Quant. Retrabalho"
            	 { "VLNEE" , "N", TamSX3("CZ4_VLNEE")[1] , TamSX3("CZ4_VLNEE")[2] , STR0020, .F., X3Picture("CZ4_VLNEE")  } , ; // " NEE"
            	 { "VLOEE" , "N", TamSX3("CZ4_VLOEE")[1] , TamSX3("CZ4_VLOEE")[2] , STR0021, .F., X3Picture("CZ4_VLOEE")  } , ; // " OEE"
            	 { "VLTEEP", "N", TamSX3("CZ4_VLTEEP")[1], TamSX3("CZ4_VLTEEP")[2], STR0022, .F., X3Picture("CZ4_VLTEEP") } , ; // " TEEP"
            	 { "VLEF"  , "N", TamSX3("CZ4_VLEF")[1]  , TamSX3("CZ4_VLEF")[2]  , STR0018, .F., X3Picture("CZ4_VLEF")   } , ; // " Eficiência"
            	 { "VLUT"  , "N", TamSX3("CZ4_VLUT")[1]  , TamSX3("CZ4_VLUT")[2]  , STR0019, .F., X3Picture("CZ4_VLUT")   } , ; // " Utilização" 
            	 { "IDMEPO", "C", TamSX3("CZ4_IDMEPO")[1], TamSX3("CZ4_IDMEPO")[2],'IDMEPO', .F., X3Picture("CZ4_IDMEPO") }}                                        
	cChave  := {"CDES", "CDARPO"}                                               	
Else                                                   
	aTabela	:= { { "NOME"  , "C", 40, 0, STR0040, .T., "!@" } , ;                  // "Nome"
				 { "DTBG"  , "D", 10, 0, STR0041, .T., "!@" } , ;                  // "Data Inicial"
				 { "DTED"  , "D", 10, 0, STR0042, .T., "!@" } , ;                  // "Data Final"	
	 		  	 { "PADRAO", "N", TamSX3("CZ5_HRSUPA")[1], TamSX3("CZ5_HRSUPA")[2], STR0034, .T., X3Picture("CZ5_HRSUPA") } , ;   // "Tempo Padrão"
	    	     { "OPERAC", "N", TamSX3("CZ5_HRTEAT")[1], TamSX3("CZ5_HRTEAT")[2], STR0017, .T., X3Picture("CZ5_HRTEAT") } }     // "Tempo Real"
	cChave  := {"NOME"}
EndIf

Return { aTabela, cChave }
