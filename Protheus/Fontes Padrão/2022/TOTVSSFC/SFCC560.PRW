#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'SFCC560.CH'  
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC560
Tela de Análise de Máquinas

@param  nCZ4RecNo           (Obrigatório) Recno do Registro na Tabela CZ4

@author Ana Carolina Tome Klock
@since 29/03/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SFCC560( nCZ4RecNo )
	
	Local aCoors 		:= FWGetDialogSize( oMainWnd )     	  												// Tamanho da Tela
	Local aButtons   	:= {}                              													// Botões
	Local oDlg, oTFolder                                          		   									// Componentes da Tela
	Local aTFolder   	:= { STR0001, STR0002 } 															// Nome das Abas ## 'Dados' ## 'Gráfico'
	Local nWidthPnl     := ((aCoors[4]-16)/2)/3                     									    // Largura 
	Local nHeigthPnl    := (aCoors[3]/2.82)-13                          									// Altura  
	Local aCombo        := { STR0003, STR0004 }			 													// Valores do Combobox ## "1=Percentual" ## "2=Horas"
	Private cVisualiza  := aCombo[1]
	Private aUnidadeMed := { SFCXUNIDME("01"), SFCXUNIDME("02"), SFCXUNIDME("04"), SFCXUNIDME("03"), ;
							 SFCXUNIDME("05"), SFCXUNIDME("06") } 											// Unidades de Medida para Q, Q_Real, U, E, D_Real, D_Planej                                    
	Private aTabBrw     := SFCC560TAB( )						   										    // Array dos Campos da Temp Table
	Private oTabBrw     := SFCCriFWTa( aTabBrw )  // Temp Table
	Private cTabBrw     := oTabBrw:GetAlias()  
	Private oChart 		:= FWChartBar():New()                          								  		// Grafico
	Default lAutoMacao  := .F.

	// Busca na Tabela
	SFCC560PRE( nCZ4RecNo )
	
	IF !lAutoMacao
		Define MsDialog oDlg Title STR0005 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel  // 'Análise de Máquina'
			
			// Divisão da Janela Principal
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDlg, .F., .T. )
			oFWLayer:AddLine('TOP'   , 20, .T. )
			oFWLayer:AddLine('BUTTON', 70, .T. )
			oFWLayer:AddCollumn('DETALHES', 100, .T. ,'TOP')
			oFWLayer:AddCollumn('DADOS'   , 100, .T. ,'BUTTON')
			oFWLayer:AddWindow('DETALHES', 'DETALHES_WINDOW', STR0005, 100, .T., .F.,, 'TOP',)      // 'Análise de Máquina'
			oFWLayer:AddWindow('DADOS'   , 'GRID_WINDOW'    , STR0006, 100, .T., .F.,, 'BUTTON',)   // 'Detalhes'
			
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
			
			TSay():New( 005, 010, { || STR0007				   			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Estabelecimento" 
			TGet():New( 013, 010, { || (cTabBrw)->CDES       			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDES   )  
			TSay():New( 005, 070, { || STR0008				  			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Área de Produção" 
			TGet():New( 013, 070, { || (cTabBrw)->CDARPO     			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDARPO ) 
			TSay():New( 005, 130, { || STR0009							}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Centro de Trabalho" 
			TGet():New( 013, 130, { || (cTabBrw)->CDCETR     			}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDCETR ) 
			TSay():New( 005, 190, { || STR0010		           			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Máquina" 
			TGet():New( 013, 190, { || (cTabBrw)->CDMQ	   				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , (cTabBrw)->CDMQ   )
			TSay():New( 005, 250, { || STR0011				 			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Capacidade Projetada"
			TGet():New( 013, 250, { || cValToChar((cTabBrw)->QTVMPL)   	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTVMPL) )  
			TSay():New( 005, 310, { || STR0012				   			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Capacidade Efetiva"
			TGet():New( 013, 310, { || cValToChar((cTabBrw)->QTVMEV)	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTVMEV) ) 
			TSay():New( 028, 010, { || STR0013			      		 	}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Capacidade Real"
			TGet():New( 036, 010, { || cValToChar((cTabBrw)->QTVMRY)	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTVMRY) )
			TSay():New( 028, 070, { || STR0014							}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Horas Trabalhadas"
			TGet():New( 036, 070, { || cValToChar((cTabBrw)->QTTEUT)	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTTEUT) ) 
			TSay():New( 028, 130, { || STR0015							}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Horas Disponíveis"
			TGet():New( 036, 130, { || cValToChar((cTabBrw)->QTTELZ) 	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTTELZ) )  
			TSay():New( 028, 190, { || aUnidadeMed[4] + STR0016			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // " Eficiência"
			TGet():New( 036, 190, { || cValToChar((cTabBrw)->QTSPEF)	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->QTSPEF) )
			TSay():New( 028, 250, { || aUnidadeMed[6] + STR0017			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // " Disp. Planejada"
			TGet():New( 036, 250, { || cValToChar((cTabBrw)->VLDIPL) 	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLDIPL) )  
			TSay():New( 028, 310, { || aUnidadeMed[5] + STR0018		    }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // " Disp. Real"
			TGet():New( 036, 310, { || cValToChar((cTabBrw)->VLDIRY)	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLDIRY) ) 
			TSay():New( 051, 010, { || aUnidadeMed[1] + STR0019		    }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // " Qualidade"
			TGet():New( 059, 010, { || cValToChar((cTabBrw)->VLQL)  	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLQL  ) )
			TSay():New( 051, 070, { || aUnidadeMed[2] + STR0020			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // " Qualidade Real"
			TGet():New( 059, 070, { || cValToChar((cTabBrw)->VLQLRY) 	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLQLRY) )  
			TSay():New( 051, 130, { || aUnidadeMed[3] + STR0021			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // " Utilização"
			TGet():New( 059, 130, { || cValToChar((cTabBrw)->VLUT  )	}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar((cTabBrw)->VLUT  ) )   
			TSay():New( 051, 190, { || STR0022		       				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Visualizar: "
			oCombo := TComboBox():New( 059, 190, { |x| if( Pcount()>0, cVisualiza := x, cVisualiza )  }, aCombo, 70, 10, oDetails, , ;
									{|x| SFCC560GRA( ) } , , , , .T., , , , , , , , , 'cVisualiza' ) 
			
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
			SFCC560GRA()
			
		Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },,aButtons,,,,,, .F. )
	ENDIF
	oTabBrw:Delete()
	
Return NIL 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC560GRA
Monta o gráfico de acordo com a selecao                                            

@author Ana Carolina Tome Klock
@since 06/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC560GRA( )    

	If cVisualiza == '1'
 		oChart:Reset()
		oChart:setTitle( STR0023, CONTROL_ALIGN_CENTER )   				// "Análise de Máquina: Porcentagem"
		oChart:addSerie( aUnidadeMed[4] + STR0016, (cTabBrw)->QTSPEF )  // " Eficiência"
		oChart:addSerie( aUnidadeMed[6] + STR0017, (cTabBrw)->VLDIPL )  // " Disp. Planejada"
		oChart:addSerie( aUnidadeMed[5] + STR0018, (cTabBrw)->VLDIRY )  // " Disp. Real"
		oChart:addSerie( aUnidadeMed[1] + STR0019, (cTabBrw)->VLQL   )  // " Qualidade"
		oChart:addSerie( aUnidadeMed[2] + STR0020, (cTabBrw)->VLQLRY )  // " Qualidade Real"
		oChart:addSerie( aUnidadeMed[3] + STR0021, (cTabBrw)->VLUT   )  // " Utilização"
		oChart:setLegend( CONTROL_ALIGN_RIGHT ) 
		oChart:Build()
	Else
   		oChart:Reset()
		oChart:setTitle( STR0024, CONTROL_ALIGN_CENTER )  //  "Análise de Máquina: Horas"
		oChart:addSerie( STR0011, (cTabBrw)->QTVMPL )     // "Capacidade Projetada"
		oChart:addSerie( STR0012, (cTabBrw)->QTVMEV )     // "Capacidade Efetiva"
		oChart:addSerie( STR0013, (cTabBrw)->QTVMRY )     // "Capacidade Real"
		oChart:addSerie( STR0015, (cTabBrw)->QTTELZ )     // "Horas Disponíveis"
		oChart:addSerie( STR0014, (cTabBrw)->QTTEUT )     // "Horas Trabalhadas"
		oChart:setLegend( CONTROL_ALIGN_RIGHT ) 
		oChart:Build()
	EndIf	 
	 
Return Nil                                               
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC560PRE
Preenche a tabela temporária da Grid
  
@param 	nCZ4RecNo 		(Obrigatório) Recno da Tabela  

@author Ana Carolina Tome Klock
@since 11/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC560PRE( nCZ4RecNo )

	// Realiza a busca na Tabela
	dbSelectArea( "CZ4" )
	dbGoTo( nCZ4RecNo )
 	
   	// Preenche a tabela temporária	    
	RecLock( cTabBrw, .T.) 
		(cTabBrw)->CDES   := CZ4->CZ4_CDES
		(cTabBrw)->CDARPO := CZ4->CZ4_CDARPO
		(cTabBrw)->CDCETR := CZ4->CZ4_CDCETR
		(cTabBrw)->CDMQ   := CZ4->CZ4_CDMQ
		(cTabBrw)->QTVMPL := Round(CZ4->CZ4_QTVMPL, 2)
		(cTabBrw)->QTVMEV := Round(CZ4->CZ4_QTVMEV, 2)
		(cTabBrw)->QTVMRY := Round(CZ4->CZ4_QTVMRY, 2)
		(cTabBrw)->QTTELZ := Round(CZ4->CZ4_QTTELZ, 2)
		(cTabBrw)->QTTEUT := Round(CZ4->CZ4_QTTEUT, 2)
		(cTabBrw)->QTSPEF := Round(CZ4->CZ4_QTSPEF, 2)
		(cTabBrw)->VLDIRY := Round(CZ4->CZ4_VLDIRY, 2)
		(cTabBrw)->VLDIPL := Round(CZ4->CZ4_VLDIPL, 2)
		(cTabBrw)->VLUT   := Round(CZ4->CZ4_VLUT,   2)
		(cTabBrw)->VLQL   := Round(CZ4->CZ4_VLQL,   2)
		(cTabBrw)->VLQLRY := Round(CZ4->CZ4_VLQLRY, 2)
	MsUnlock() 

	CZ4->(dbCloseArea()) 

Return Nil 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC560TAB 
Cria a tabela a ser usada 

@author Ana Carolina Tome Klock
@since 11/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function SFCC560TAB( )
    
aTabela := { { "CDES"  , "C", TamSX3("CZ4_CDES")[1]  , TamSX3("CZ4_CDES")[2]  , STR0007    				, .T., X3Picture("CZ4_CDES")   }, ; // "Estabelecimento"
			 { "CDARPO", "C", TamSX3("CZ4_CDARPO")[1], TamSX3("CZ4_CDARPO")[2], STR0008    		   		, .T., X3Picture("CZ4_CDARPO") }, ; // "Área de Produção" 
        	 { "CDCETR", "C", TamSX3("CZ4_CDCETR")[1], TamSX3("CZ4_CDCETR")[2], STR0009  		 		, .T., X3Picture("CZ4_CDCETR") }, ; // "Centro de Trabalho"
        	 { "CDMQ"  , "C", TamSX3("CZ4_CDMQ")[1]  , TamSX3("CZ4_CDMQ")[2]  , STR0010					, .T., X3Picture("CZ4_CDMQ")   }, ; // "Máquina"
             { "QTVMPL", "N", TamSX3("CZ4_QTVMPL")[1], TamSX3("CZ4_QTVMPL")[2], STR0011     			, .T., X3Picture("CZ4_QTVMPL") }, ; // "Capacidade Projetada"
             { "QTVMEV", "N", TamSX3("CZ4_QTVMEV")[1], TamSX3("CZ4_QTVMEV")[2], STR0012			   		, .T., X3Picture("CZ4_QTVMEV") }, ; // "Capacidade Efetiva"
             { "QTVMRY", "N", TamSX3("CZ4_QTVMRY")[1], TamSX3("CZ4_QTVMRY")[2], STR0013     			, .T., X3Picture("CZ4_QTVMRY") }, ; // "Capacidade Real" 
             { "QTTELZ", "N", TamSX3("CZ4_QTTELZ")[1], TamSX3("CZ4_QTTELZ")[2], STR0015					, .T., X3Picture("CZ4_QTTELZ") }, ; // "Horas Disponíveis"
             { "QTTEUT", "N", TamSX3("CZ4_QTTEUT")[1], TamSX3("CZ4_QTTEUT")[2], STR0014					, .T., X3Picture("CZ4_QTTEUT") }, ; // "Horas Trabalhadas"
             { "VLQL"  , "N", TamSX3("CZ4_VLQL")[1]  , TamSX3("CZ4_VLQL")[2]  , aUnidadeMed[1] + STR0019, .F., X3Picture("CZ4_VLQL")   }, ; // " Qualidade"
             { "VLQLRY", "N", TamSX3("CZ4_VLQLRY")[1], TamSX3("CZ4_VLQLRY")[2], aUnidadeMed[2] + STR0020, .F., X3Picture("CZ4_VLQLRY") }, ; // " Qualidade Real"
             { "VLUT"  , "N", TamSX3("CZ4_VLUT")[1]  , TamSX3("CZ4_VLUT")[2]  , aUnidadeMed[3] + STR0021, .F., X3Picture("CZ4_VLUT")   }, ; // " Utilização"
             { "QTSPEF", "N", TamSX3("CZ4_QTSPEF")[1], TamSX3("CZ4_QTSPEF")[2], aUnidadeMed[4] + STR0016, .T., X3Picture("CZ4_QTSPEF") }, ; // " Eficiência"
             { "VLDIRY", "N", TamSX3("CZ4_VLDIRY")[1], TamSX3("CZ4_VLDIRY")[2], aUnidadeMed[6] + STR0017, .F., X3Picture("CZ4_VLDIRY") }, ; // " Disp. Planejada"
             { "VLDIPL", "N", TamSX3("CZ4_VLDIPL")[1], TamSX3("CZ4_VLDIPL")[2], aUnidadeMed[5] + STR0018, .F., X3Picture("CZ4_VLDIPL") } }  // " Disp. Real"
   	                                                          
Return {aTabela, {"CDES", "CDARPO"}}
