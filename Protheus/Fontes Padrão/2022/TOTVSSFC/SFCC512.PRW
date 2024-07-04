#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'   
#INCLUDE 'FWMVCDEF.CH'       
#INCLUDE 'SFCC512.CH'
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC512
Tela de consulta de Detalhe do Monitoramento de Fabrica

@param  nCZ4RecNo           (Obrigatório) Recno do Registro na Tabela CZ4

@author Ana Carolina Tome Klock
@since 22/03/2011
@version P11
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SFCC512( nCZ4RecNo )
	Local aCoors     := FWGetDialogSize( oMainWnd )     	  					// Tamanho da Tela
	Local oDlg, oFWLayer, oPanelUp, oPanelGr, oTFolder							// Componentes da Tela
	Local aTFolder   := { STR0001, STR0002, STR0003 }    	  					// Nome das Abas ## 'Apontamento' ## 'Parada' ## 'Item Controle'
	Local nWidthPnl  := ((aCoors[4]-20)/2)/3                            		// Largura do Painel
	Local nHeigthPnl := (aCoors[3]/2.82)-13                             		// Altura do Painel
	Local nQTVMPL, nQTVMEV, nQTVMRY, nVLDIRY, nVLUT, nVLQL, nVLQLRY, nVLEF 		// Quantidades
	Local nVLNEE, nVLOEE, nVLTk, nVLBTS, nVLBTSS, nVLBTSM, nVLBTSV   		 	// Quantidades
	Local   aApont, cRefug, aParad, aItemC, aShow, aApoIC, aParIC
	
	Private cApont, aRefug, cParad, cItemC, cShow, cApoIC, cParIC
	Private cCDES, cCDARPO, cCDCETR, cCDMQ, cIDMEPO, dDTRE, cHRRE				// Campos Chave 
	Private oObj 

	Private aUnidadeMed := {;
		SFCXUNIDME("04"), SFCXUNIDME("01"), ;
		SFCXUNIDME("02"), SFCXUNIDME("03"), ;
		SFCXUNIDME("07"), SFCXUNIDME("08"), ;
		SFCXUNIDME("14"), SFCXUNIDME("13"), ;
		SFCXUNIDME("12"), SFCXUNIDME("10"), ;
		SFCXUNIDME("11"), SFCXUNIDME("05");
	} 				// Unidades de Medida 

	Default lAutoMacao := .F.

	// Busca na Tabela
	dbSelectArea("CZ4")
	dbGoTo( nCZ4RecNo )
	cCDES		:= CZ4->CZ4_CDES
	cCDARPO		:= CZ4->CZ4_CDARPO
	cCDCETR		:= CZ4->CZ4_CDCETR
	cCDMQ		:= CZ4->CZ4_CDMQ
	cIDMEPO		:= CZ4->CZ4_IDMEPO
	dDTRE		:= CZ4->CZ4_DTRE
	cHRRE		:= CZ4->CZ4_HRRE
	nQTVMPL		:= Round( CZ4->CZ4_QTVMPL, 2 )
	nQTVMEV		:= Round( CZ4->CZ4_QTVMEV, 2 )
	nQTVMRY		:= Round( CZ4->CZ4_QTVMRY, 2 )
	nVLDIRY		:= Round( CZ4->CZ4_VLDIRY, 2 )
	nVLQL		:= Round( CZ4->CZ4_VLQL, 2 )
	nVLQLRY		:= Round( CZ4->CZ4_VLQLRY, 2 )
	nVLTk		:= Round( CZ4->CZ4_VLTk, 2 )
	nVLBTS		:= Round( CZ4->CZ4_VLBTS, 2 )
	nVLBTSS		:= Round( CZ4->CZ4_VLBTSS, 2 )
	nVLBTSM		:= Round( CZ4->CZ4_VLBTSM, 2 )
	nVLBTSV		:= Round( CZ4->CZ4_VLBTSV, 2 )
	nVLUT		:= Round( CZ4->CZ4_VLUT, 2 )
	nVLEF		:= Round( CZ4->CZ4_VLEF, 2 )
	nVLNEE		:= Round( CZ4->CZ4_VLNEE, 2 )
	nVLOEE		:= Round( CZ4->CZ4_VLOEE, 2 )

	cCZ5 := BuscaCZ5()

	oTabApo   := tabApo(@aApont,@cApont,cCZ5)
	oTabARef  := tabApoRef(@aRefug,@cRefug,cCZ5)
	oTabARefF := tabApoRefF(@aShow,@cShow)
	oTabStrIC := tabStrIC(@aApoIC,@cApoIC)

	oTabPar   := tabPar(@aParad,@cParad,cCZ5)
	oTabStIC2 := tabStrIC(@aParIC,@cParIC)

	oTabItCon := tabIteCon(@aItemC,@cItemC)

	IF !lAutoMacao

		Define MsDialog oDlg Title STR0004 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel  // 'Detalhe do Monitoramento de Fábrica'

			// Divisão da Janela Principal
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDlg, .F., .T. )
			oFWLayer:AddLine('TOP', 25, .T. )
			oFWLayer:AddCollumn('DETALHES', 100, .T. ,'TOP')
			oFWLayer:AddLine('BUTTON', 72, .T. )
			oFWLayer:AddCollumn('DADOS', 100, .T. ,'BUTTON')
			oFWLayer:AddWindow('DETALHES', 'DETALHES_WINDOW', STR0005, 100, .T., .F.,, 'TOP',)   // 'Monitoramento de Fábrica'
			oFWLayer:AddWindow('DADOS', 'GRID_WINDOW', STR0006, 100, .T., .F.,, 'BUTTON',)       // 'Detalhes'
			
			// Layers que serão usadas
			oPanelUp := oFWLayer:GetWinPanel ( 'DETALHES','DETALHES_WINDOW', 'TOP' )
			oPanelGr := oFWLayer:GetWinPanel ( 'DADOS','GRID_WINDOW', 'BUTTON' )
			
			// Detalhe Superior
			oScroll := TScrollArea():New(oPanelUp,01,01,(nWidthPnl * 3), (nHeigthPnl/4) - 4,.T.,.T.,.T.)
			oScroll:Align := CONTROL_ALIGN_ALLCLIENT

			aCoord := fwgetdialogsize()

			If aCoord[4] > 800
				nTam := nHeigthPnl * 0.35
			Else                                                 
				nTam := nHeigthPnl * 0.75 
			EndIf 

			// Cria painel 
			oDetails := TPanel():New( 01, 01, /*cText*/, oScroll, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, (nWidthPnl * 3), nTam ) 

			// Define objeto painel como filho do scroll
			oScroll:SetFrame( oDetails )    

			TSay():New( 005, 010, { || STR0007 				  	 	  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     //  "Estabelecimento"
			TGet():New( 013, 010, { || cCDES       					  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDES   )  
			TSay():New( 005, 070, { || STR0008		   				  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // "Área de Produção"
			TGet():New( 013, 070, { || cCDARPO   					  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDARPO ) 
			TSay():New( 005, 130, { || STR0009						  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // "Centro de Trabalho" 
			TGet():New( 013, 130, { || cCDCETR 						  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDCETR ) 
			TSay():New( 005, 190, { || STR0010            			  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // "Máquina"
			TGet():New( 013, 190, { || cCDMQ   					      }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDMQ   ) 
			TSay():New( 005, 250, { || STR0011	 					  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // "C. Projetado"
			TGet():New( 013, 250, { || cValToChar(nQTVMPL)   		  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTVMPL) ) 
			TSay():New( 005, 310, { || STR0012		  			      }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // "C. Efetivado" 
			TGet():New( 013, 310, { || cValToChar(nQTVMEV)			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTVMEV) )
			TSay():New( 005, 370, { || STR0013 						  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // "C. Real" 
			TGet():New( 013, 370, { || cValToChar(nQTVMRY) 		      }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTVMRY) )
			TSay():New( 028, 010, { || aUnidadeMed[12] + STR0014 	  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " Disp. Real"
			TGet():New( 036, 010, { || cValToChar(nVLDIRY)   		  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLDIRY) )                          
			TSay():New( 028, 070, { || aUnidadeMed[1] + STR0015 	  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " Utilização"
			TGet():New( 036, 070, { || cValToChar(nVLUT)	 		  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLUT)   )                          
			TSay():New( 028, 130, { || aUnidadeMed[2] + STR0016   	  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " Qualidade"                 
			TGet():New( 036, 130, { || cValToChar(nVLQL)   			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLQL)   )                    
			TSay():New( 028, 190, { || aUnidadeMed[3] + STR0017		  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " Qualidade Real"
			TGet():New( 036, 190, { || cValToChar(nVLQLRY) 			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLQLRY) )                   
			TSay():New( 028, 250, { || aUnidadeMed[4] + STR0018 	  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " Eficiência"
			TGet():New( 036, 250, { || cValToChar(nVLEF) 			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLEF)   )                             
			TSay():New( 028, 310, { || aUnidadeMed[5] + STR0019		  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " NEE"
			TGet():New( 036, 310, { || cValToChar(nVLNEE)  			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLNEE)  )                                  
			TSay():New( 028, 370, { || aUnidadeMed[6] + STR0020		  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " OEE" 
			TGet():New( 036, 370, { || cValToChar(nVLOEE)  			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLOEE)  )                                 
			TSay():New( 051, 010, { || aUnidadeMed[7] + STR0021		  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     //  " Tk"
			TGet():New( 059, 010, { || cValToChar(nVLTK)   			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLTK)   )                                   
			TSay():New( 051, 070, { || aUnidadeMed[8] + STR0022		  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " BTS" 
			TGet():New( 059, 070, { || cValToChar(nVLBTS)  			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLBTS)  )                                    
			TSay():New( 051, 130, { || aUnidadeMed[9] + STR0023		  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " BTS Sequência"
			TGet():New( 059, 130, { || cValToChar(nVLBTSS) 			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLBTSS) )                             
			TSay():New( 051, 190, { || aUnidadeMed[10] + STR0024 	  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " BTS Volume"
			TGet():New( 059, 190, { || cValToChar(nVLBTSV) 			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLBTSV) )                                     
			TSay():New( 051, 250, { || aUnidadeMed[11] + STR0025 	  }, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )     // " BTS Mix"
			TGet():New( 059, 250, { || cValToChar(nVLBTSM) 			  }, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLBTSM) )                                    

			// Browse que contem o Grid
			oTFolder  := TFolder():New( 0, 0, aTFolder, /*aDialogs*/, oPanelGr, 1, /*nClrFore*/, /*nClrBack*/, .T., /*uParam10*/,  (aCoors[4]-16)/2, aCoors[3]/3.2 )   

			//Folder Apontamento
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oTFolder:aDialogs[1], .F., .T. )
			oFWLayer:AddLine( 'ALL', 105, .T. )
			oFWLayer:AddCollumn('LEFT',  65, .T., 'ALL' )
			oFWLayer:AddCollumn('RIGHT', 35, .T., 'ALL' )
			oMainGrid1 := oFWLayer:GetColPanel( 'LEFT', 'ALL' )		
			
			oFWLayer:AddWindow( 'RIGHT', "RefApo", "Refugo", 50, .F., .F.,,'ALL')
			oFWLayer:AddWindow( 'RIGHT', "IteConApo", "Item Controle", 50, .F., .F.,,'ALL')

			oDetaGridU := oFWLayer:GetWinPanel('RIGHT','RefApo','ALL') //Apontamento Refugo
			oDetaGridD := oFWLayer:GetWinPanel('RIGHT','IteConApo','ALL') //Apontamento Item Controles

			//Folder Parada
			oFWLayer2 := FWLayer():New()
			oFWLayer2:Init( oTFolder:aDialogs[2], .F., .T. )
			oFWLayer2:AddLine( 'ALL', 105, .T. )
			oFWLayer2:AddCollumn('LEFT',  65, .T., 'ALL' )
			oFWLayer2:AddCollumn('RIGHT', 35, .T., 'ALL' )

			oFWLayer2:AddWindow( 'RIGHT', "wndParItemCtrl", "Item Controle", 100, .F., .F.,, 'ALL')

			oMainGrid2 := oFWLayer2:GetColPanel ( 'LEFT', 'ALL' )
			oDetaGrid2 := oFWLayer2:GetWinPanel('RIGHT','wndParItemCtrl','ALL')

			// Grids Apontamento
			oBrowse2	:= SFCXAUXCRI( oDetaGridU, (cShow), "cShow", aShow, .T., .T. )//Apontamento Refugo
			oBrowse6	:= SFCXAUXCRI( oDetaGridD, (cApoIC), "cApoIC", aApoIC, .T., .T. )//Apontamento Item Controles
			oBrowse1	:= SFCXAUXCRI( oMainGrid1, (cApont), "cApont", aApont, .F., .T. )//Apontamento

			oBrowse1:SetChange( { || FilApoRef(@cShow,cRefug), FilApoIC(@cApoIC,cItemC) } ) //Filtra os refugos pelo apontamento selecionado
			oBrowse1:Activate()
			
			//Grids Parada		
			oBrowse5	:= SFCXAUXCRI( oDetaGrid2, (cParIC) , "cParIC" , aParIC , .T., .T. )//Parada Item Controle
			oBrowse3	:= SFCXAUXCRI( oMainGrid2, (cParad), "cParad", aParad, .T., .T. )//Parada

			oBrowse3:SetChange( { || FilParIC(@cParIC,cItemC) })
			oBrowse3:Activate()

			//Item Controle
			oBrowse4	:= SFCXAUXCRI( oTFolder:aDialogs[3] , (cItemC),  "cItemC", aItemC, .T., .T. )//Item Controle

		Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },,,,,,,, .F. )
	
	ENDIF

	oTabApo:Delete()
	oTabARef:Delete()
	oTabARefF:Delete()
	oTabStrIC:Delete()
	oTabPar:Delete()
	oTabStIC2:Delete()
	oTabItCon:Delete()

Return NIL 
//---------------------------------------------------------------------------------------------------
Static Function BuscaCZ5()

	dbSelectArea( "CZ5" )
	cQuery := "SELECT CZ5.* FROM " + RetSQLName( 'CZ5' ) + " CZ5 "
	cQuery += "WHERE "
	cQuery += "	CZ5.CZ5_FILIAL = '" + xFilial('CZ5')+ "' AND "
	cQuery += "	CZ5.CZ5_CDMQ   = '" + cCDMQ			+ "' AND "
	cQuery += "	CZ5.CZ5_IDMEPO = '" + cIDMEPO		+ "' AND "
	cQuery += "	CZ5.CZ5_DTRE   = '" + DTOS(dDTRE)	+ "' AND "
	cQuery += "	CZ5.CZ5_HRRE   = '" + cHRRE			+ "' AND "
	cQuery += "	CZ5.D_E_L_E_T_ = ' '"
	cCZ5   := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cCZ5, .T., .F. )

Return cCZ5
//---------------------------------------------------------------------------------------------------
Static Function tabApo(aStruct,cObj,cCZ5)
	Local aCampos := { ;
		{ "NRRP"  , "C", TamSX3("CZ5_NRSQRP")[1], TamSX3("CZ5_NRSQRP")[2], STR0053, .T., X3Picture("CZ5_NRSQRP") }, ;   // 'Nr. Apontamento' 
		{ "NRORPO", "C", TamSX3("CZ5_NRORPO")[1], TamSX3("CZ5_NRORPO")[2], STR0052, .T., X3Picture("CZ5_NRORPO") }, ;   // 'Ordem de Produção'
		{ "CDAT"  , "C", TamSX3("CZ5_CDAT")[1]  , TamSX3("CZ5_CDAT")[2]  , STR0026, .T., X3Picture("CZ5_CDAT")   }, ;   // 'Operação'
		{ "IDATQO", "C", TamSX3("CZ5_IDATQO")[1], TamSX3("CZ5_IDATQO")[2], STR0027, .T., X3Picture("CZ5_IDATQO") }, ;   // 'Slipt'
		{ "CDAC"  , "C", TamSX3("CZ5_CDAC")[1]  , TamSX3("CZ5_CDAC")[2]  , STR0028, .T., X3Picture("CZ5_CDAC")   }, ;   // 'Item'
		{ "DSAC"  , "C", TamSX3("CZ3_DSAC")[1]  , TamSX3("CZ3_DSAC")[2]  , STR0029, .T., X3Picture("CZ3_DSAC")   }, ;   // 'Descrição Item'
		{ "DTBG"  , "D", TamSX3("CZ5_DTBG")[1]  , TamSX3("CZ5_DTBG")[2]  , STR0030, .T., X3Picture("CZ5_DTBG")   }, ;   // 'Data Inicial'
		{ "HRBG"  , "C", TamSX3("CZ5_DTED")[1]  , TamSX3("CZ5_DTED")[2]  , STR0031, .T., X3Picture("CZ5_DTED")   }, ;   // 'Hora Inicial'
		{ "DTED"  , "D", TamSX3("CZ5_HRBG")[1]  , TamSX3("CZ5_HRBG")[2]  , STR0032, .T., X3Picture("CZ5_HRBG")   }, ;   // 'Data Final'
		{ "HRED"  , "C", TamSX3("CZ5_HRED")[1]  , TamSX3("CZ5_HRED")[2]  , STR0033, .T., X3Picture("CZ5_HRED")   }, ;   // 'Hora Final'
		{ "QTTEDI", "N", TamSX3("CZ5_QTTEDI")[1], TamSX3("CZ5_QTTEDI")[2], STR0034, .T., X3Picture("CZ5_QTTEDI") }, ;   // 'Disp. Horas'
		{ "QTRP"  , "N", TamSX3("CZ5_QTRP")[1]  , TamSX3("CZ5_QTRP")[2]  , STR0035, .T., X3Picture("CZ5_QTRP")   }  ;   // 'Quant. Apont.'
	}

	aStruct := {aCampos,{"NRRP"}}
	oObj    := SFCCriFWTa(aStruct)
	cObj    := oObj:GetAlias() 

	(cCZ5)->(dbGoTop())

	While (cCZ5)->(!EOF())
		If (cCZ5)->CZ5_TPMV == '1'
			RecLock( cObj, .T.)
				(cObj)->NRRP	:= (cCZ5)->CZ5_NRSQRP
				(cObj)->NRORPO	:= (cCZ5)->CZ5_NRORPO
				(cObj)->CDAT	:= (cCZ5)->CZ5_CDAT						
				(cObj)->IDATQO	:= (cCZ5)->CZ5_IDATQO
				(cObj)->CDAC	:= (cCZ5)->CZ5_CDAC
				(cObj)->DSAC	:= POSICIONE("CZ3",1,XFILIAL("CZ3")+(cCZ5)->CZ5_CDAC, "CZ3_DSAC")  
				(cObj)->DTBG	:= STOD((cCZ5)->CZ5_DTBG)
				(cObj)->HRBG	:= (cCZ5)->CZ5_HRBG
				(cObj)->DTED	:= STOD((cCZ5)->CZ5_DTED)				
				(cObj)->HRED	:= (cCZ5)->CZ5_HRED
				(cObj)->QTTEDI	:= (cCZ5)->CZ5_QTTEDI / 3600
				(cObj)->QTRP	:= (cCZ5)->CZ5_QTRP
		 	MsUnlock()
		EndIf
		(cCZ5)->(dbSkip())
	End

	// Agrupa os campos conforme as chaves definidas e soma os valores
	SFCXAgrupaTab(cObj, {'CDAT','IDATQO','CDAC','DTBG','DTED','HRBG','HRED'}, {'QTTEDI', 'QTRP'})  

Return oObj
//---------------------------------------------------------------------------------------------------
Static Function tabApoRef(aStruct,cObj,cCZ5)
	Local oObj
	Local aCampos := { ;
		{ "CDAT"  , "C", TamSX3("CZ5_CDAT")[1]  , TamSX3("CZ5_CDAT")[2]  , STR0026, .F., X3Picture("CZ5_CDAT")   }, ;   // 'Operação'
		{ "NRORPO", "C", TamSX3("CZ5_NRORPO")[1], TamSX3("CZ5_NRORPO")[2], STR0052, .F., X3Picture("CZ5_NRORPO") }, ;   // 'Ordem de Produção'
		{ "NRRP"  , "C", TamSX3("CZ5_NRSQRP")[1], TamSX3("CZ5_NRSQRP")[2], STR0053, .F., X3Picture("CZ5_NRSQRP") }, ;   // 'Nr. Apontamento'
		{ "IDATQO", "C", TamSX3("CZ5_IDATQO")[1], TamSX3("CZ5_IDATQO")[2], STR0027, .F., X3Picture("CZ5_IDATQO") }, ;   // 'Split'
		{ "CDAC"  , "C", TamSX3("CZ5_CDAC")[1]  , TamSX3("CZ5_CDAC")[2]  , STR0028, .F., X3Picture("CZ5_CDAC")   }, ;   // 'Item'
		{ "DTBG"  , "D", TamSX3("CZ5_DTBG")[1]  , TamSX3("CZ5_DTBG")[2]  , STR0030, .F., X3Picture("CZ5_DTBG")   }, ;   // 'Data Inicial'
		{ "HRBG"  , "C", TamSX3("CZ5_HRBG")[1]  , TamSX3("CZ5_HRBG")[2]  , STR0031, .F., X3Picture("CZ5_HRBG")   }, ;   // 'Hora Inicial'
		{ "DTED"  , "D", TamSX3("CZ5_DTED")[1]  , TamSX3("CZ5_DTED")[2]  , STR0032, .F., X3Picture("CZ5_DTED")   }, ;   // 'Data Final'
		{ "HRED"  , "C", TamSX3("CZ5_HRED")[1]  , TamSX3("CZ5_HRED")[2]  , STR0033, .F., X3Picture("CZ5_HRED")   }, ;   // 'Hora Final'
		{ "CDRF"  , "C", TamSX3("CZ5_CDRF")[1]  , TamSX3("CZ5_CDRF")[2]  , STR0036, .T., X3Picture("CZ5_CDRF")   }, ;   // 'Motivo'
		{ "QTRF"  , "N", TamSX3("CZ5_QTRF")[1]  , TamSX3("CZ5_QTRF")[2]  , STR0037, .T., X3Picture("CZ5_QTRF")   }, ;   // 'Qt. Refugo'
		{ "QTRT"  , "N", TamSX3("CZ5_QTRT")[1]  , TamSX3("CZ5_QTRT")[2]  , STR0038, .T., X3Picture("CZ5_QTRT")   }  ;   // 'Qt. Retrabalho'   
	}
	aStruct := { aCampos, {"CDAT"} } 
	oObj    := SFCCriFWTa( aStruct )
	cObj    := oObj:GetAlias()

	(cCZ5)->(dbGoTop())

	While (cCZ5)->(!EOF())
		If (cCZ5)->CZ5_TPMV == '4'
			RecLock( cObj, .T.)
				(cObj)->CDAT	:= (cCZ5)->CZ5_CDAT
				(cObj)->NRORPO	:= (cCZ5)->CZ5_NRORPO
				(cObj)->NRRP	:= (cCZ5)->CZ5_NRSQRP
				(cObj)->IDATQO	:= (cCZ5)->CZ5_IDATQO
				(cObj)->CDAC	:= (cCZ5)->CZ5_CDAC
				(cObj)->DTBG	:= STOD((cCZ5)->CZ5_DTBG)
				(cObj)->HRBG	:= (cCZ5)->CZ5_HRBG
				(cObj)->DTED	:= STOD((cCZ5)->CZ5_DTED)
				(cObj)->HRED	:= (cCZ5)->CZ5_HRED
				(cObj)->CDRF	:= (cCZ5)->CZ5_CDRF
				(cObj)->QTRF	:= (cCZ5)->CZ5_QTRF
				(cObj)->QTRT	:= (cCZ5)->CZ5_QTRT
			MsUnlock()
		EndIf
		(cCZ5)->(dbSkip())
	End

Return oObj
//---------------------------------------------------------------------------------------------------
Static Function tabApoRefF(aStruct,cObj)
	Local oObj
	Local aCampos := { ;
		{ "CDRF"  , "C", TamSX3("CZ5_CDRF")[1]  , TamSX3("CZ5_CDRF")[2]  , STR0036, .T., X3Picture("CZ5_CDRF")   }, ;   // 'Motivo'
		{ "QTRF"  , "N", TamSX3("CZ5_QTRF")[1]  , TamSX3("CZ5_QTRF")[2]  , STR0037, .T., X3Picture("CZ5_QTRF")   }, ;   // 'Qt. Refugo'
		{ "QTRT"  , "N", TamSX3("CZ5_QTRT")[1]  , TamSX3("CZ5_QTRT")[2]  , STR0038, .T., X3Picture("CZ5_QTRT")   }  ;   // 'Qt. Retrabalho' 
	}
	aStruct := { aCampos, {"CDRF"} } 
	oObj    := SFCCriFWTa( aStruct )
	cObj    := oObj:GetAlias()
	
Return oObj
//---------------------------------------------------------------------------------------------------
Static Function tabStrIC(aStruct,cObj)
	Local oObj
	Local aCampos := { ;
		{ "CDVF", "C", TamSX3("CYT_CDVF")[1], TamSX3("CYT_CDVF")[2], "Item Controle", .T., X3Picture("CYT_CDVF")   }, ;   // 'Código Item Controle'
		{ "DSVF", "C", TamSX3("CYK_DSVF")[1], TamSX3("CYK_DSVF")[2], "Descrição"    , .T., X3Picture("CYK_DSVF")   }, ;   // 'Descrição Item Controle'
		{ "DSRS", "C", TamSX3("CYT_DSRS")[1], TamSX3("CYT_DSRS")[2], STR0049        , .T., X3Picture("CYT_DSRS")   }, ;   // 'Resultado'
		{ "DTRS", "D", TamSX3("CYT_DTRS")[1], TamSX3("CYT_DTRS")[2], STR0050        , .T., X3Picture("CYT_DTRS")   }, ;   // 'Resultado Data'
		{ "VLRS", "N", TamSX3("CYT_VLRS")[1], TamSX3("CYT_VLRS")[2], STR0051        , .T., X3Picture("CYT_VLRS")   }, ;   // 'Resultado Valor'
		{ "DTRP", "D", TamSX3("CYT_DTRP")[1], TamSX3("CYT_DTRP")[2], "Data Reporte" , .T., X3Picture("CYT_DTRP")   }, ;   // 'Data Reporte'
		{ "HRRP", "C", TamSX3("CYT_HRRP")[1], TamSX3("CYT_HRRP")[2], "Hora Reporte" , .T., X3Picture("CYT_HRRP")   }  ;   // 'Hora Reporte'
	}
	aStruct := { aCampos, {"CDVF"} } 
	oObj    := SFCCriFWTa( aStruct )
	cObj    := oObj:GetAlias()
	
Return oObj
//---------------------------------------------------------------------------------------------------
Static Function tabPar(aStruct,cObj,cCZ5)
	Local oObj
	Local aCampos := { ;
		{ "CDMQ"  , "C", TamSX3("CZ5_CDMQ")[1]  , TamSX3("CZ5_CDMQ")[2]  , STR0039, .T., X3Picture("CZ5_CDMQ")   }, ;   // 'Máquina'
		{ "DSMQ"  , "C", TamSX3("CYB_DSMQ")[1]  , TamSX3("CYB_DSMQ")[2]  , STR0040, .T., X3Picture("CYB_DSMQ")   }, ;   // 'Descrição Máquina'
		{ "CDSP"  , "C", TamSX3("CZ5_CDSP")[1]  , TamSX3("CZ5_CDAT")[2]  , STR0041, .T., X3Picture("CZ5_CDSP")   }, ;   // 'Parada'
		{ "DSSP"  , "C", TamSX3("CYN_DSSP")[1]  , TamSX3("CYN_DSSP")[2]  , STR0042, .T., X3Picture("CYN_DSSP")   }, ;   // 'Descrição Parada'
		{ "DTBG"  , "D", TamSX3("CZ5_DTBG")[1]  , TamSX3("CZ5_DTBG")[2]  , STR0030, .T., X3Picture("CZ5_DTBG")   }, ;   // 'Data Inicial'
		{ "HRBG"  , "C", TamSX3("CZ5_HRBG")[1]  , TamSX3("CZ5_HRBG")[2]  , STR0031, .T., X3Picture("CZ5_HRBG")   }, ;   // 'Hora Inicial'
		{ "DTED"  , "D", TamSX3("CZ5_DTED")[1]  , TamSX3("CZ5_DTED")[2]  , STR0032, .T., X3Picture("CZ5_DTED")   }, ;   // 'Data Final'
		{ "HRED"  , "C", TamSX3("CZ5_HRED")[1]  , TamSX3("CZ5_HRED")[2]  , STR0033, .T., X3Picture("CZ5_HRED")   }, ;   // 'Hora Final'
		{ "CDTN"  , "C", TamSX3("CZ5_CDTN")[1]  , TamSX3("CZ5_CDTN")[2]  , STR0043, .T., X3Picture("CZ5_CDTN")   }, ;   // 'Modelo Turno'
		{ "NRORMN", "C", TamSX3("CZ5_NRORMN")[1], TamSX3("CZ5_NRORMN")[2], STR0044, .T., X3Picture("CZ5_NRORMN") }  ;   // 'Ordem Manutenção'
	}
	aStruct := { aCampos, {"DTBG", "HRBG"} } 
	oObj    := SFCCriFWTa( aStruct )
	cObj    := oObj:GetAlias()

	(cCZ5)->(dbGoTop())

	While (cCZ5)->(!EOF())
		If (cCZ5)->CZ5_TPMV == '5'
			RecLock( cObj, .T.)
				(cObj)->CDMQ	:= (cCZ5)->CZ5_CDMQ
				(cObj)->DSMQ	:= POSICIONE("CYB",1,XFILIAL("CYB")+(cCZ5)->CZ5_CDMQ, "CYB_DSMQ")           
				(cObj)->CDSP	:= (cCZ5)->CZ5_CDSP
				(cObj)->DSSP	:= POSICIONE("CYN",1,XFILIAL("CYN")+(cCZ5)->CZ5_CDSP, "CYN_DSSP")
				(cObj)->DTBG	:= STOD((cCZ5)->CZ5_DTBG)
				(cObj)->HRBG	:= (cCZ5)->CZ5_HRBG
				(cObj)->DTED	:= STOD((cCZ5)->CZ5_DTED)
				(cObj)->HRED	:= (cCZ5)->CZ5_HRED
				(cObj)->CDTN	:= (cCZ5)->CZ5_CDTN
				(cObj)->NRORMN	:= (cCZ5)->CZ5_NRORMN
			MsUnlock()
		EndIf
		(cCZ5)->(dbSkip())
	End

Return oObj
//---------------------------------------------------------------------------------------------------
Static Function tabIteCon(aStruct,cObj)
	Local oObj
	Local dataini
	Local datafim := STOD(aFiltro[10])
	Local aCampos := { ;
		{ "CDMQ"  , "C",  TamSX3("CYT_CDMQ")[1]  , TamSX3("CYT_CDMQ")[2]  , STR0039, .T., X3Picture("CYT_CDMQ")   }, ;   // 'Máquina'
		{ "DSMQ"  , "C",  TamSX3("CYB_DSMQ")[1]  , TamSX3("CYB_DSMQ")[2]  , STR0040, .T., X3Picture("CYB_DSMQ")   }, ;   // 'Descrição Máquina'
		{ "CDVF"  , "C",  TamSX3("CYT_CDVF")[1]  , TamSX3("CYT_CDVF")[2]  , STR0045, .T., X3Picture("CYT_CDVF")   }, ;   // 'Controle'
		{ "DSVF"  , "C",  TamSX3("CYK_DSVF")[1]  , TamSX3("CYK_DSVF")[2]  , STR0046, .T., X3Picture("CYK_CDVF")   }, ;   // 'Descrição Controle'
		{ "DTBG"  , "D",  TamSX3("CYT_DTSQVF")[1], TamSX3("CYT_DTSQVF")[2], STR0047, .T., X3Picture("CYT_DTSQVF") }, ;   // 'Data'
		{ "HRBG"  , "C",  TamSX3("CYT_HRSQVF")[1], TamSX3("CYT_HRSQVF")[2], STR0048, .T., X3Picture("CYT_HRSQVF") }, ;   // 'Hora'
		{ "DSRS"  , "C",  TamSX3("CYT_DSRS")[1]  , TamSX3("CYT_DSRS")[2]  , STR0049, .T., X3Picture("CYT_DSRS")   }, ;   // 'Resultado'
		{ "DTRS"  , "D",  TamSX3("CYT_DTRS")[1]  , TamSX3("CYT_DTRS")[2]  , STR0050, .T., X3Picture("CYT_DTRS")   }, ;   // 'Resultado Data'
		{ "VLRS"  , "N",  TamSX3("CYT_VLRS")[1]  , TamSX3("CYT_VLRS")[2]  , STR0051, .T., X3Picture("CYT_VLRS")   }, ;   // 'Resultado Valor'
		{ "DTRP"  , "D",  TamSX3("CYT_DTRP")[1]  , TamSX3("CYT_DTRP")[2]  , "Data Reporte" , .T., X3Picture("CYT_DTRP")  }, ;   // 'Data Reporte'
		{ "HRRP"  , "C",  TamSX3("CYT_HRRP")[1]  , TamSX3("CYT_HRRP")[2]  , "Hora Reporte" , .T., X3Picture("CYT_HRRP")  }  ;   // 'Hora Reporte'
	}
	aStruct := { aCampos, {"DTBG", "HRBG"} } 
	oObj    := SFCCriFWTa( aStruct )
	cObj    := oObj:GetAlias()

	//Verifica o tipo da meta
	dbSelectArea("CYU")
	CYU->(dbSetOrder(1))
	CYU->( dbSeek(xFilial("CYU")+aFiltro[09]) )

	If CYU->CYU_TPME == "1" //Diário
		dataini := datafim
	ElseIf CYU->CYU_TPME == "2" //Semanal
		dataini := datafim
		dataini := dataini - DOW(dataini) + 1
	ElseIf CYU->CYU_TPME == "3" //Mensal
		dataini := datafim
		dataini := Substring(DTOS(dataini),1,6)+"01"
		dataini := STOD(dataini)
	EndIf

	// Realiza a busca na Tabela 
	dbSelectArea( "CYT" )
	CYT->(dbSetOrder(1))
	CYT->( dbSeek(xFilial("CZ4")+cCDMQ) )

	// Preenche a tabela temporária
	While CYT->(!Eof()) .And. CYT->CYT_FILIAL == xFilial("CZ4") .And. CYT->CYT_CDMQ == cCDMQ

		If (CYT->CYT_DTRP == datafim .And. CYT->CYT_HRRP <= aFiltro[11]) .Or. (CYT->CYT_DTRP < datafim .And. CYT->CYT_DTRP >= dataini)
			// Item Controle 
			RecLock( cItemC, .T.)
				(cItemC)->CDMQ := CYT->CYT_CDMQ
				(cItemC)->DSMQ := POSICIONE("CYB",1,XFILIAL("CYB")+CYT->CYT_CDMQ, "CYB_DSMQ")
				(cItemC)->CDVF := CYT->CYT_CDVF
				(cItemC)->DSVF := POSICIONE("CYK",1,XFILIAL("CYK")+CYT->CYT_CDVF,"CYK_DSVF")       
				(cItemC)->DTBG := CYT->CYT_DTSQVF
				(cItemC)->HRBG := CYT->CYT_HRSQVF
				(cItemC)->DSRS := CYT->CYT_DSRS
				(cItemC)->DTRS := CYT->CYT_DTRS
				(cItemC)->VLRS := CYT->CYT_VLRS
				(cItemC)->DTRP := CYT->CYT_DTRP
				(cItemC)->HRRP := CYT->CYT_HRRP
			MsUnlock()
		EndIf

		CYT->(dbSkip())
	End
	CYT->(dbCloseArea())

Return oObj
//---------------------------------------------------------------------------------------------------
Static Function FilApoRef(cFiltered,cAll)
	// Remove os registros existentes
	dbSelectArea( cFiltered )
	ZAP

	// Insere os registros relacionados
	dbSelectArea( cAll )
	dbGoTop() 

	While (cAll)->(!EOF())
		If ( (cAll)->NRRP == (cApont)->NRRP )  
			RecLock( cFiltered, .T.)
				(cFiltered)->CDRF   := (cAll)->CDRF
				(cFiltered)->QTRF	:= (cAll)->QTRF
				(cFiltered)->QTRT   := (cAll)->QTRT
			MsUnlock()  
		EndIf
		(cAll)->(dbSkip())
	End

	// Atualiza o Browse e seleciona a primeira linha
	oBrowse2:ShowData()
	oBrowse2:Refresh()
	oBrowse2:GoTop( )

Return Nil
//---------------------------------------------------------------------------------------------------
Static Function FilApoIC(cFiltered,cAll)
	// Remove os registros existentes
	dbSelectArea( cFiltered )
	ZAP

	// Insere os registros relacionados
	dbSelectArea( cAll )
	dbGoTop() 

	While (cAll)->(!Eof())
			If ( ;
				(cAll)->DTRP >= (cApont)->DTBG .And. (cAll)->DTRP <= (cApont)->DTED .And. ;
				(cAll)->HRRP >= (cApont)->HRBG .And. (cAll)->HRRP <= (cApont)->HRED ;
			)
				RecLock( cFiltered, .T.)
					(cFiltered)->CDVF   := (cAll)->CDVF
					(cFiltered)->DSVF	:= (cAll)->DSVF
					(cFiltered)->DSRS   := (cAll)->DSRS
					(cFiltered)->DTRS	:= (cAll)->DTRS
					(cFiltered)->VLRS	:= (cAll)->VLRS
					(cFiltered)->DTRP   := (cAll)->DTRP
					(cFiltered)->HRRP   := (cAll)->HRRP
				MsUnlock()
			EndIf
		(cAll)->(dbSkip())
	End

	// Atualiza o Browse e seleciona a primeira linha
	oBrowse6:ShowData()
	oBrowse6:Refresh()
	oBrowse6:GoTop( )

Return Nil
//---------------------------------------------------------------------------------------------------
Static Function FilParIC(cFiltered,cAll)
	// Remove os registros existentes
	dbSelectArea( cFiltered )
	ZAP

	// Insere os registros relacionados
	dbSelectArea( cAll )
	dbGoTop() 

	While (cAll)->(!Eof())
			If ( ;
				(cAll)->DTRP >= (cParad)->DTBG .And. (cAll)->DTRP <= (cParad)->DTED .And. ;
				(cAll)->HRRP >= (cParad)->HRBG .And. (cAll)->HRRP <= (cParad)->HRED ;
			)
				RecLock( cFiltered, .T.)
					(cFiltered)->CDVF   := (cAll)->CDVF
					(cFiltered)->DSVF	:= (cAll)->DSVF
					(cFiltered)->DSRS   := (cAll)->DSRS
					(cFiltered)->DTRS	:= (cAll)->DTRS
					(cFiltered)->VLRS	:= (cAll)->VLRS
					(cFiltered)->DTRP   := (cAll)->DTRP
					(cFiltered)->HRRP   := (cAll)->HRRP
				MsUnlock()
			EndIf
		(cAll)->(dbSkip())
	End

	// Atualiza o Browse e seleciona a primeira linha
	oBrowse5:ShowData()
	oBrowse5:Refresh()
	oBrowse5:GoTop( )

Return Nil
