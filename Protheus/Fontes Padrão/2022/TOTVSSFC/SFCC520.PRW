#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'    
#INCLUDE 'MSGRAPHI.CH'
#INCLUDE 'SFCC520.CH'
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC520
Acompanhamento de Meta de Produção

@param  nCZ4RecNo           (Obrigatório) Recno do Registro na Tabela CZ4

@author  Israel Alcantara Possoli
@since 29/03/2011
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function SFCC520( nCZ4RecNo )  

	Local aCoors        := FWGetDialogSize( oMainWnd )               // Dimensionamento da Janela
	Local oPanelUp, oFWLayer                                         // Painéis 
	Local nWidthPnl  := ((aCoors[4]-20)/2)/3                      // Largura      
	Local nHeigthPnl 	:= (aCoors[3]/2.82)-13                       // Altura
	Local aButtons      := {}                                        // Botões
	Private cCDES, cCDARPO, cCDCETR, cCDMQ, cIdMePo, dDTRE, cHRRE    // Campos Chave
	Private nQTAPON, nQTAPRO, nVLBTS, nVLBTSS, nVLBTSV, nVLBTSM      // Quantidades
	Private aTabBrw		:= SFCC520DEF()                              // Estrutura da Temp Table
	Private oTabBrw  := SFCCriFWTa( aTabBrw )                     // Temp Table
	Private cTabBrw  := oTabBrw:GetAlias()
	Private oDlg                                                     // Janela Principal
	Private aUnidadeMed := { SFCXUNIDME("13"), SFCXUNIDME("12"), ;
							 SFCXUNIDME("10"), SFCXUNIDME("11")	 } 	 // Unidades de Medida 
	Default lAutoMacao := .F.
							 
	// Busca na Tabela
	SFCC520PRE( nCZ4RecNo )
	
	IF !lAutoMacao
		Define MsDialog oDlg Title STR0001  FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel    // 'Acompanhamento de Meta de Produção'
			
			// Divisão da Janela Principal
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDlg, .F., .T. )  
			oFWLayer:AddLine('TOP', 20, .T. )
			oFWLayer:AddLine('BUTTON', 77, .T. )     
			oFWLayer:AddCollumn('CAMPOS', 100, .T. ,'TOP')
			oFWLayer:AddCollumn('BROWSE', 100, .T. ,'BUTTON')  
			oFWLayer:AddWindow('CAMPOS', 'CAMPOS_WINDOW', STR0001,   100, .T., .F.,, 'TOP',)     // 'Acompanhamento de Meta de Produção'
			oFWLayer:AddWindow('BROWSE', 'BROWSE_WINDOW', STR0002, 100, .T., .F.,, 'BUTTON',)    // 'Detalhes'
			
			// Layers que serão usadas
			oPanelUp 	 := oFWLayer:GetWinPanel ( 'CAMPOS','CAMPOS_WINDOW', 'TOP' )
			oLayerBrowse := oFWLayer:GetWinPanel ( 'BROWSE','BROWSE_WINDOW', 'BUTTON' )
			
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
			
			TSay():New( 005, 010, { || STR0003			     				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // 'Estabelecimento'
			TGet():New( 013, 010, { || cCDES    			 				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDES    )  
			TSay():New( 005, 070, { || STR0004			    				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // 'Área de Produção'     
			TGet():New( 013, 070, { || cCDARPO   			 				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDARPO  ) 
			TSay():New( 005, 130, { || STR0005				  				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // 'Centro de Trabalho'
			TGet():New( 013, 130, { || cCDCETR   			 				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDCETR  ) 
			TSay():New( 005, 190, { || STR0006	             				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // 'Máquina'     
			TGet():New( 013, 190, { || cCDMQ 			     				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cCDMQ    ) 
			TSay():New( 005, 250, { || STR0007	 			 				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // 'Qt.Apont.'
			TGet():New( 013, 250, { || cValToChar(nQTAPON)   				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTAPON) ) 
			TSay():New( 005, 310, { || STR0008	            				}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // 'Qt.Aprov.'             
			TGet():New( 013, 310, { || cValToChar(nQTAPRO)   				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nQTAPRO) ) 
			TSay():New( 028, 010, { || aUnidadeMed[1] + STR0009	   			}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // ' BTS'
			TGet():New( 036, 010, { || cValToChar(nVLBTS)    				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLBTS)  )                                    
			TSay():New( 028, 070, { || aUnidadeMed[2] + STR0010			 	}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // ' BTS Sequência'
			TGet():New( 036, 070, { || cValToChar(nVLBTSS)   				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLBTSS) )                             
			TSay():New( 028, 130, { || aUnidadeMed[3] + STR0011		 		}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // ' BTS Volume'
			TGet():New( 036, 130, { || cValToChar(nVLBTSV)   				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLBTSV) )                                     
			TSay():New( 028, 190, { || aUnidadeMed[4] + STR0012 	    	}, oDetails, , , , , , .T., CLR_BLACK, CLR_WHITE )               // ' BTS Mix'
			TGet():New( 036, 190, { || cValToChar(nVLBTSM)   				}, oDetails, 43, 7, , {||}, , , , , , .T., , ,{||} , , ,{||} , .T., , , cValToChar(nVLBTSM) ) 
			
			// Browse para a Grid    
			oBrowse1 := SFCXAUXCRI( oLayerBrowse , (cTabBrw), "cTabBrw", aTabBrw, .T., .T., .F. )
			
		Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },,@aButtons,,,,,, .F. )
	ENDIF

	oTabBrw:Delete()
	
Return NIL

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC520DEF
Definição da Tabela Temporária

@author  Israel Alcantara Possoli
@since 22/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC520DEF()
    
aTabBrw := { {"TPMV"   , "C", 					  100, 						 0, STR0013, .T., "!@"                    } , ;    // 'Tipo Registro'
 	  	     {"CDAC"   , "C", TamSX3("CY4_CDAC")[1]  , TamSX3("CY4_CDAC")[2]  , STR0014, .T., X3Picture("CY4_CDAC")   } , ;    // 'Item'
		  	 {"CDRE"   , "C", TamSX3("CY4_CDRE")[1]  , TamSX3("CY4_CDRE")[2]  , STR0015, .T., X3Picture("CY4_CDRE")   } , ;    // 'Referência'
		  	 {"NRORPO" , "C", TamSX3("CY4_NRORPO")[1], TamSX3("CY4_NRORPO")[2], STR0016, .T., X3Picture("CY4_NRORPO") } , ;    // 'Ordem Produção'
		  	 {"NRSQME" , "C", TamSX3("CY4_NRSQME")[1], TamSX3("CY4_NRSQME")[2], STR0017, .T., X3Picture("CY4_NRSQME") } , ;    // 'Sequência'
		  	 {"IDATQO" , "C", TamSX3("CY4_IDATQO")[1], TamSX3("CY4_IDATQO")[2], STR0018, .T., X3Picture("CY4_IDATQO") } , ;    // 'Split'
		  	 {"NRTN"   , "C", TamSX3("CY4_NRTN")[1]  , TamSX3("CY4_NRTN")[2]  , STR0019, .T., X3Picture("CY4_NRTN")   } , ;    // 'Nr. Turno'
		  	 {"IDAT"   , "C", TamSX3("CY4_IDAT")[1]  , TamSX3("CY4_IDAT")[2]  , STR0020, .T., X3Picture("CY4_IDAT")   } , ;    // 'Operação SFC'
		  	 {"QTTEPL" , "N", TamSX3("CY4_QTTEPL")[1], TamSX3("CY4_QTTEPL")[2], STR0021, .T., X3Picture("CY4_QTTEPL") } , ;    // 'Horas Planejadas'
		  	 {"QTPLAT" , "N", TamSX3("CY4_QTPLAT")[1], TamSX3("CY4_QTPLAT")[2], STR0022, .T., X3Picture("CY4_QTPLAT") } , ;    // 'Qtd Prevista'
		  	 {"QTPLUN" , "N", TamSX3("CY4_QTPLUN")[1], TamSX3("CY4_QTPLUN")[2], STR0023, .T., X3Picture("CY4_QTPLUN") } , ;    // 'Qtd Prevista Unid.'
		  	 {"DTBGAT" , "D", TamSX3("CY4_DTBGAT")[1], TamSX3("CY4_DTBGAT")[2], STR0024, .T., X3Picture("CY4_DTBGAT") } , ;    // 'Data Inicial'
		  	 {"HRBGAT" , "C", TamSX3("CY4_HRBGAT")[1], TamSX3("CY4_HRBGAT")[2], STR0025, .T., X3Picture("CY4_HRBGAT") } , ;    // 'Hora Inicial'
		  	 {"DTEDAT" , "D", TamSX3("CY4_DTEDAT")[1], TamSX3("CY4_DTEDAT")[2], STR0026, .T., X3Picture("CY4_DTEDAT") } , ;    // 'Data Final'
		  	 {"HREDAT" , "C", TamSX3("CY4_HREDAT")[1], TamSX3("CY4_HREDAT")[2], STR0027, .T., X3Picture("CY4_HREDAT") } }      // 'Hora Final'
		  	 
Return { aTabBrw , {"TPMV", "CDAC"} }                         

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC520PRE
Preenche a tabela temporária 

@author Ana Carolina Tome Klock
@since 05/04/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC520PRE( nCZ4RecNo )
     
	dbSelectArea( "CZ4" )
	dbGoTo( nCZ4RecNo )
	cCDES   := CZ4->CZ4_CDES
	cCDARPO := CZ4->CZ4_CDARPO
	cCDCETR := CZ4->CZ4_CDCETR
	cCDMQ   := CZ4->CZ4_CDMQ
	cIDMEPO := CZ4->CZ4_IDMEPO
	dDTRE   := CZ4->CZ4_DTRE
	cHRRE   := CZ4->CZ4_HRRE
	nQTAPON := Round( CZ4->CZ4_QTRPRY - CZ4->CZ4_QTRFRY, 2 )                                			
    nQTAPRO := Round( CZ4->CZ4_QTRPRY, 2 )            			             			
	nVLBTS  := Round( CZ4->CZ4_VLBTS , 2 )   		
	nVLBTSS := Round( CZ4->CZ4_VLBTSS, 2 )
	nVLBTSM := Round( CZ4->CZ4_VLBTSM, 2 )
	nVLBTSV := Round( CZ4->CZ4_VLBTSV, 2 )
    
	// Realiza a busca na Tabela
	dbSelectArea( "CY4" )
	cQuery := "SELECT CY4.* FROM " + RetSQLName( 'CY4' )   + " CY4 "
		cQuery += " WHERE CY4.CY4_FILIAL = '" + xFilial('CY4') + "' AND "  // Filial
		cQuery += " 	  CY4.CY4_CDMQ   = '" + cCDMQ		   + "' AND "  // Máquina
		cQuery += " 	  CY4.CY4_IDMEPO = '" + cIDMEPO        + "' AND "  // Meta Máquina
		cQuery += " 	  CY4.CY4_DTRE   = '" + DTOS(dDTRE)    + "' AND "  // Data Referência
		cQuery += " 	  CY4.CY4_HRRE   = '" + cHRRE          + "' AND "  // Hora Referência
		cQuery += "       CY4.D_E_L_E_T_ = ' '"
		cCY4   := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cCY4, .T., .F. ) 
		                                                                
	// Preenche a tabela temporária
 	While (cCY4)->(!EOF()) 
		RecLock( cTabBrw, .T.)
			(cTabBrw)->TPMV   := X3COMBO("CZ5_TPMV", (cCY4)->CY4_TPMV )
			(cTabBrw)->CDAC   := (cCY4)->CY4_CDAC
			(cTabBrw)->CDRE   := (cCY4)->CY4_CDRE
			(cTabBrw)->NRORPO := (cCY4)->CY4_NRORPO
			(cTabBrw)->NRSQME := (cCY4)->CY4_NRSQME
			(cTabBrw)->IDATQO := (cCY4)->CY4_IDATQO
			(cTabBrw)->NRTN   := (cCY4)->CY4_NRTN
			(cTabBrw)->IDAT   := (cCY4)->CY4_IDAT
			(cTabBrw)->QTPLAT := Round( (cCY4)->CY4_QTPLAT, 2 )
			(cTabBrw)->QTPLUN := Round( (cCY4)->CY4_QTPLUN, 2 )
			(cTabBrw)->DTBGAT := STOD((cCY4)->CY4_DTBGAT)
			(cTabBrw)->HRBGAT := (cCY4)->CY4_HRBGAT
			(cTabBrw)->DTEDAT := STOD((cCY4)->CY4_DTEDAT)
			(cTabBrw)->HREDAT := (cCY4)->CY4_HREDAT
		MsUnlock()     
		
		(cCY4)->(dbSkip())  
	End
    (cCY4)->(dbCloseArea())  
	
Return Nil
