#INCLUDE 'SFCC580.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'     
#INCLUDE 'TOTVS.CH'

Static __lAutomacao := IsInCallStack("SFCC580_001")
 
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC580
Tela Gerencial de Produção

@author Ana Carolina Tome Klock
@since 10/01/2011
@version P11
/*/
//-------------------------------------------------------------------------------------------------------------------- 
Function SFCC580()     					                                            
Local aCoors    		:= FWGetDialogSize( oMainWnd )									
Local oFWLayer                                                                         
Local aButtons  		:= {{ STR0001, { || If ( SFCREFILTRO( aFiltro ) == .F., oDlg:End(), Nil) }, STR0001, STR0002 },;   	// 'Filtros' ### 'Gerenciar Filtro'
                           {'Imprimir Browse', { || oBrowseDo:Report() }, 'Imprimir Browse', 'Imprimir Browse' } }
Local lFechar 		:= .T.
Local aPanelGeral		:= {}
Local aFiltro			:= SFCC580VAR()									
Local oDlg
Private lSuccess 		:= .T.
Private aFieldsDisp 	:= {}                                                
Private aFieldsSel  	:= {}                                
Private aPanelUp    	:= array(60)				  					
Private aPanelDown  	:= array(100)
Private aLbxSint 		:= {}     			  							
Private aPanelShow  	:= {}     					  							                                  						
Private oBrowseUp, oBrowseDo, oColumn		   			
Private oPanelDown, oPanelUp                                                     			
Private aCampoSel   	:= {}											                     				   								
Private aField 		:= Array( 82 )  
Private nNivelMin		:= 1  

// Chamando filtro  
SFCC580FIL( @aFiltro )
	
// Fecha caso seja cancelado a primeira chamada de filtro   
If lSuccess == .F. .And. lFechar == .T.
	Return Nil                             
EndIf                                      
lFechar := .F.

If !__lAutomacao
	Define MsDialog oDlg Title STR0005  FROM aCoors[1], aCoors[2] To aCoors[3]-2, aCoors[4]-2 Pixel    // 'Gerencial de Produção'
		
		// Montando arrays baseados no filtro 					
		aPanelGeral 	:= SFCXGERENCIAL( aFiltro ) 
		aPanelUp 		:= aPanelGeral[1]
		aPanelDown 	:= aPanelGeral[2]  
		
		// Saindo da tela caso não encontre registros  
		If Empty( aPanelUp ) .Or. aPanelUp[1][1] > 1
			Alert( STR0006 ) // "Sua pesquisa não retornou resultados!"
			Return NIL
		EndIf
		
		// Monta Containers dos Componentes                                        
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlg, .F., .T. )
		oFWLayer:AddLine( 'EMCIMA' , 47, .F. )  
		oFWLayer:AddLine( 'EMBAIXO', 44.5, .F. )  
		oPanelUp   := oFWLayer:GetLinePanel( 'EMCIMA'  )  
		oPanelDown := oFWLayer:GetLinePanel( 'EMBAIXO' )
		
		//oFWLayer:Align := CONTROL_ALIGN_TOP
EndIf
	
	// Monta o Browse inferior e a Tree    
	SFCC580BRO( aFiltro[1][1][2] )
	SFCC580TRE( aFiltro[1][1][2], aFiltro )
	
If !__lAutomacao
	Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },, aButtons,,,,,, .F. ) 
EndIf
	
Return NIL  

//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Return aRotina  
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC580BRO
Monta a Tree

@author Ana Carolina Tome Klock
@since 28/02/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------ 
Function SFCC580BRO( cFunction )
Local nI := 0

oBrowseDo := FWBrowse():New( oPanelDown )      
oBrowseDo:SetDataArray(.T.)
oBrowseDo:SetColumns( SFCCAMPOS( cFunction ) )
oBrowseDo:SetArray(aPanelShow)
oBrowseDo:lHeaderClick:=.F. 
oBrowseDo:DisableConfig()
oBrowseDo:DisableReport()

If !__lAutomacao
	oBrowseDo:Activate()
	For nI := 1 To Len(oBrowseDo:aColumns)
		oBrowseDo:SetHeaderImage(nI,"") 
	Next  
EndIf
	
Return NIL                                                                                         
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC580TRE()
Monta a Tree

@author Ana Carolina Tome Klock
@since 28/02/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------ 
Function SFCC580TRE( cFunction, aFiltro )
Local nI := 0

For nI := 1 To Len( aPanelUp )
	If !__lAutomacao
		If aPanelUp[nI, 1] == 1
			aAdd( aLbxSint, aPanelUp[nI] )
		EndIf
		If aPanelUp[nI, 1] < Len(aLbxSint)
			aLbxSint[Len( aLbxSint )][2] := .T.
		ElseIf !Empty(aLbxSint)
			aLbxSint[Len( aLbxSint )][2] := .F.
		EndIf 
	EndIf
Next nI     
  		
oBrowseUp := FWBrowse():New( oPanelUp )
oBrowseUp:SetDataArray(.T.)
oBrowseUp:SetChange( { || SFCC580BUS( oBrowseDo, aPanelShow, aPanelDown, aLbxSint) } )      
oBrowseUp:SetDoubleClick( { || SFCC580ATU( oBrowseUp, aLbxSint, aPanelUp, nNivelMin ) } )
oBrowseUp:lHeaderClick:=.F.
oBrowseUp:SetColumns( SFCMETRICA( cFunction, aFiltro, aLbxSint ) )
oBrowseUp:DisableConfig()
oBrowseUp:DisableFilter()
oBrowseUp:DisableSeek()
oBrowseUp:DisableReport()
oBrowseUp:SetArray( aLbxSint )
If !__lAutomacao
	oBrowseUp:Activate()                          
EndIf
For nI := 1 To Len(oBrowseUp:aColumns)
	oBrowseUp:SetHeaderImage(nI,"") 
Next    
SFCC580ATU( oBrowseUp, aLbxSint, aPanelUp, nNivelMin )

oBrowseUp:Refresh()

Return NIL
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC580ATU
Atualiza a listbox abrindo e fechando seus níveis

@author Ana Carolina Tome Klock
@since 28/02/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------ 
Static Function SFCC580ATU( oBrowseUp, aLbxSint, aPanelUp, nNivelMin )
Local nI 		 := 0
Local nJ 	 	 := 0
Local nSubTrai := 0
Local nNivel   := 0
Local cQuebra  := ""
Local cGrupo 	 := ""
	
If !__lAutomacao
	nNivel   := aLbxSint[oBrowseUp:nAt][1]
	cQuebra  := Len( AllTrim( aLbxSint[oBrowseUp:nAt][3] ) )
	cGrupo 	 := AllTrim( SubStr( aLbxSint[oBrowseUp:nAt][3], 1, cQuebra ) )

	//-------------------------------------------------------------------
	// Limpa Grupo               
	//-------------------------------------------------------------------
	If aLbxSint[oBrowseUp:nAt][2]
		// Inverte True Animado
		nNivel := nNivel - 1
		aLbxSint[oBrowseUp:nAt][2] := !( aLbxSint[oBrowseUp:nAt][2] )
		
		// Limpa Itens com o mesmo Grupo ( 1o Caracter )
		nI := oBrowseUp:nAt + 1
		nJ := Len( aLbxSint ) - ( oBrowseUp:nAt )
		While nJ > 0
			If AllTrim( SubStr( aLbxSint[nI][3], 1, cQuebra ) ) == cGrupo .AND. aLbxSint[nI][1] > nNivel
				// Deleta linha da Array
				aDel( aLbxSint, nI )
				nSubtrai++
			EndIf
			nJ--
		EndDo

		aSize( aLbxSint, Len( aLbxSint ) -nSubtrai )
		
	//-------------------------------------------------------------------
	// Realimenta ListBox a partir do array
	//-------------------------------------------------------------------
	Else
		// Inverte True Animado
		nNivel  := nNivel + 1
		nNivel  := Max( nNivel, nNivelMin )
		aLbxSint[oBrowseUp:nAt][2] := !( aLbxSint[oBrowseUp:nAt][2] )
		
		For nI := 1 To Len( aPanelUp )
			// Verifica se faz parte do Grupo
			If AllTrim( SubStr( aPanelUp[nI][3], 1, cQuebra ) ) == cGrupo .AND. aPanelUp[nI][1] <= nNivel
				// Impede duplicacao do Grupo Principal
				If !( AllTrim( aPanelUp[nI][3] ) == cGrupo .AND. aPanelUp[nI][1] <= nNivel )
					aAdd( aLbxSint, aPanelUp[nI] )
					If aPanelUp[nI, 1] < nNivel
						aLbxSint[Len( aLbxSint )][2] := .T.
					Else
						aLbxSint[Len( aLbxSint )][2] := .F.
					EndIf				
				EndIf
			EndIf
		Next 
		
		// Ordena aLbxSint pelo Codigo
		aSort( aLbxSint,,, { | x, y | x[3] < y[3] } )
	EndIf
EndIf

// Refresh na ListBox
oBrowseUp:Refresh()

Return NIL
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCC580BUS
Realiza a busca no browse inferior e atualiza exibindo somente os dados relacionados ao item da Tree selecionado

@author Ana Carolina Tome Klock
@since 21/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCC580BUS( oBrowseDo, aPanelShow, aPanelDown, aLbxSint )
Local nI 		 := 0
Local cGrupo     := " "
Local nTam	     := 0  
Local nNivel 	 := 0
Local lRet		 := .T.

If !__lAutomacao
	cGrupo   := AllTrim(aLbxSint[oBrowseUp:nAt][3])
	nTam	 := Len(AllTrim(aLbxSint[oBrowseUp:nAt][3]))  
	nNivel 	 := aLbxSint[oBrowseUp:nAt][1] 
EndIf

If nNivel < Len( aFieldsSel )
	lRet := .F.
EndIf
	
aPanelShow := {} 
For nI := 1 To Len( aPanelDown )
	If (SubStr( AllTrim(aPanelDown[nI][1]) , 1, nTam) == cGrupo) .And. (Len(AllTrim(aPanelDown[nI][1])) > nTam) 
		aAdd( aPanelShow, aPanelDown[nI] ) 
	Elseif (lRet .And. (SubStr( AllTrim(aPanelDown[nI][1]) , 1, nTam) == cGrupo))
		aAdd( aPanelShow, aPanelDown[nI] ) 
	EndIf                              
Next      

If !__lAutomacao
	oBrowseDo:SetArray(aPanelShow)
	oBrowseDo:Refresh() 
EndIf
	
Return NIL                                    
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCMETRICA
Função que define as métricas a serem exibidas na tree de acordo com as métricas selecionadas no filtro.

@param 	cFunction		Funcionalidade selecionada no filtro
@param		aFiltro		Array contendo os valores do filtro

@return	aColumn		Array contendo as colunas do SFCC580TRE

@author Ana Carolina Tome Klock
@since 12/01/11
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function SFCMETRICA( cFunction, aFiltro, aLbxSint )
Local nI, aMaxNumber
Local aMetricSel := {} 
Local aColumn    := {}
Local aCampo     := {} 

If (cFunction == '1')  
	aAdd ( aMetricSel, { STR0007, 'CZ4_QTRPRY', 'aLbxSint[oBrowseUp:At()][8]'  } )                                     // 'Produção Real'
	aAdd ( aMetricSel, { STR0008, 'CZ4_QTRFPL', 'aLbxSint[oBrowseUp:At()][9]'  } )                                     // 'Refugo Previsto'
	aAdd ( aMetricSel, { STR0009, 'CZ4_VLRFPL', 'aLbxSint[oBrowseUp:At()][9] / aLbxSint[oBrowseUp:At()][8] * 100'  } )  // '% Refugo Previsto'
	aAdd ( aMetricSel, { STR0010, 'CZ4_QTRFRY', 'aLbxSint[oBrowseUp:At()][10]' } )                                     // 'Refugo Real'
	aAdd ( aMetricSel, { STR0011, 'CZ4_VLRFRY', 'aLbxSint[oBrowseUp:At()][10] / aLbxSint[oBrowseUp:At()][8] * 100' } )  // '% Refugo Real'
	aAdd ( aMetricSel, { STR0012, 'CZ4_VLPNRF', 'aLbxSint[oBrowseUp:At()][11]' } )                                     // '% Variação Refugo'
	aAdd ( aMetricSel, { STR0013, 'CZ4_QTRTPL', 'aLbxSint[oBrowseUp:At()][12]' } )                                     // 'Retrabalho Previsto'
	aAdd ( aMetricSel, { STR0014, 'CZ4_VLRTPL', 'aLbxSint[oBrowseUp:At()][12] / aLbxSint[oBrowseUp:At()][8] * 100' } )  // '% Retrabalho Previsto'
	aAdd ( aMetricSel, { STR0015, 'CZ4_QTRTRY', 'aLbxSint[oBrowseUp:At()][13]' } )                                     // 'Retrabalho Real'
	aAdd ( aMetricSel, { STR0016, 'CZ4_VLRTRY', 'aLbxSint[oBrowseUp:At()][13] / aLbxSint[oBrowseUp:At()][8] * 100' } )  // '% Retrabalho Real'
	aAdd ( aMetricSel, { STR0017, 'CZ4_VLPNRT', 'aLbxSint[oBrowseUp:At()][14]' } )                                     // '% Variação Retrabalho'
	aShow := {	aFiltro[4][1][2][1][2], aFiltro[4][1][2][2][2] , aFiltro[4][1][2][3][2] , aFiltro[4][1][2][4][2], ;
				aFiltro[4][1][2][5][2], aFiltro[4][1][2][6][2] , aFiltro[4][1][2][7][2] , aFiltro[4][1][2][8][2], ;
				aFiltro[4][1][2][9][2], aFiltro[4][1][2][10][2], aFiltro[4][1][2][11][2] }
ElseIf (cFunction == '2')  
	aAdd ( aMetricSel, { STR0018, 'CZ4_NRSP'  , 'aLbxSint[oBrowseUp:At()][15]' } )                                     // 'Número Paradas'
	aAdd ( aMetricSel, { STR0019, 'CZ4_NRSPPL', 'aLbxSint[oBrowseUp:At()][16]' } )                                     // 'Número Paradas Programadas'
	aAdd ( aMetricSel, { STR0020, 'CZ4_NRSPRY', 'aLbxSint[oBrowseUp:At()][17]' } )                                     // 'Número Paradas Progr. Efetivas'
	aAdd ( aMetricSel, { STR0021, 'CZ4_NRSPAI', 'aLbxSint[oBrowseUp:At()][18]' } )                                     // 'Número Paradas não Programadas'
	aAdd ( aMetricSel, { STR0022, 'CZ4_QTPL'  , 'aLbxSint[oBrowseUp:At()][19]' } )                                     // 'Horas Planejadas'
	aAdd ( aMetricSel, { STR0023, 'CZ4_QTPLAI', 'aLbxSint[oBrowseUp:At()][20]' } )                                     // 'Horas não Planejadas'
	aAdd ( aMetricSel, { STR0024, 'CZ4_QTSPTT', 'aLbxSint[oBrowseUp:At()][21]' } )                                     // 'Tempo Total Parada'
	aAdd ( aMetricSel, { STR0025, 'CZ4_VLPL'  , 'aLbxSint[oBrowseUp:At()][22]' } )                                     // '% Programado'
	aAdd ( aMetricSel, { STR0026, 'CZ4_VLAI'  , 'aLbxSint[oBrowseUp:At()][23]' } )                                     // '% Não Programado'
	aShow := {	aFiltro[4][2][2][1][2], aFiltro[4][2][2][2][2], aFiltro[4][2][2][3][2], aFiltro[4][2][2][4][2], ;
				aFiltro[4][2][2][5][2], aFiltro[4][2][2][6][2], aFiltro[4][2][2][7][2], aFiltro[4][2][2][8][2], ;
				aFiltro[4][2][2][9][2] }                              
ElseIf (cFunction == '3') 
	aAdd ( aMetricSel, { STR0027, 'CZ4_NRTTRP', 'aLbxSint[oBrowseUp:At()][24]' } )                                     // 'Número Apontamentos'
	aAdd ( aMetricSel, { STR0028, 'CZ4_QTSUPA', 'aLbxSint[oBrowseUp:At()][25]' } )                                     // 'Tempo Preparação Padrão'
	aAdd ( aMetricSel, { STR0029, 'CZ4_QTATPA', 'aLbxSint[oBrowseUp:At()][26]' } )                                     // 'Tempo Operação Padrão'
	aAdd ( aMetricSel, { STR0030, 'CZ4_QTSURY', 'aLbxSint[oBrowseUp:At()][27]' } )                                     // 'Tempo Preparação Real'
	aAdd ( aMetricSel, { STR0031, 'CZ4_QTATRY', 'aLbxSint[oBrowseUp:At()][28]' } )                                     // 'Tempo Operação Real'
	aAdd ( aMetricSel, { STR0032, 'CZ4_QTTEUT', 'aLbxSint[oBrowseUp:At()][29]' } )                                     // 'Horas Normais'
	aAdd ( aMetricSel, { STR0033, 'CZ4_QTTEEX', 'aLbxSint[oBrowseUp:At()][30]' } )                                     // 'Horas Extras'
	aAdd ( aMetricSel, { STR0034, 'CZ4_VLQL'  , 'aLbxSint[oBrowseUp:At()][31]' } )                                     // '% Qualidade'
	aAdd ( aMetricSel, { STR0035, 'CZ4_VLQLRY', 'aLbxSint[oBrowseUp:At()][32]' } )                                     // '% Qualidade Real'
	aAdd ( aMetricSel, { STR0036, 'CZ4_VLEF'  , 'aLbxSint[oBrowseUp:At()][33]' } )                                     // '% Eficiência'
  	aShow := {	aFiltro[4][3][2][1][2] , aFiltro[4][3][2][2][2] , aFiltro[4][3][2][4][2], aFiltro[4][3][2][5][2],; 
  				aFiltro[4][3][2][6][2] , aFiltro[4][3][2][7][2] , aFiltro[4][3][2][8][2], aFiltro[4][3][2][9][2],;
  				aFiltro[4][3][2][10][2], aFiltro[4][3][2][11][2] }                                                
Else       
	aAdd ( aMetricSel, { STR0037, 'CZ4_QTVMPL', 'aLbxSint[oBrowseUp:At()][34]' } )                                     // 'Capacidade do Projeto'
	aAdd ( aMetricSel, { STR0038, 'CZ4_QTVMEV', 'aLbxSint[oBrowseUp:At()][35]' } )                                     // 'Capacidade Efetiva'
   	aAdd ( aMetricSel, { STR0039, 'CZ4_QTVMRY', 'aLbxSint[oBrowseUp:At()][36]' } )                                     // 'Capacidade Real'
   	aAdd ( aMetricSel, { STR0040, 'CZ4_VLDIPL', 'aLbxSint[oBrowseUp:At()][37]' } )                                     // 'Disponibilidade Planej.'
   	aAdd ( aMetricSel, { STR0041, 'CZ4_VLDIRY', 'aLbxSint[oBrowseUp:At()][38]' } )                                     // 'Disponibilidade Real'
   	aAdd ( aMetricSel, { STR0042, 'CZ4_VLUT'  , 'aLbxSint[oBrowseUp:At()][39]' } )                       			  	  // '% Utilização'
   	aAdd ( aMetricSel, { STR0034, 'CZ4_VLQL'  , 'aLbxSint[oBrowseUp:At()][31]' } )                                     // '% Qualidade'
   	aAdd ( aMetricSel, { STR0035, 'CZ4_VLQLRY', 'aLbxSint[oBrowseUp:At()][32]' } )                                     // '% Qualidade Real'
   	aAdd ( aMetricSel, { STR0036, 'CZ4_VLEF'  , 'aLbxSint[oBrowseUp:At()][33]' } )                                     // '% Eficiência'
   	aAdd ( aMetricSel, { STR0028, 'CZ4_QTSUPA', 'aLbxSint[oBrowseUp:At()][25]' } )									  	  // 'Tempo Preparação Padrão'
   	aAdd ( aMetricSel, { STR0029, 'CZ4_QTATPA', 'aLbxSint[oBrowseUp:At()][26]' } )                                     // 'Tempo Operação Padrão'
   	aAdd ( aMetricSel, { STR0030, 'CZ4_QTSURY', 'aLbxSint[oBrowseUp:At()][27]' } )              			             // 'Tempo Preparação Real'
   	aAdd ( aMetricSel, { STR0031, 'CZ4_QTATRY', 'aLbxSint[oBrowseUp:At()][28]' } )                                     // 'Tempo Operação Real'
   	aAdd ( aMetricSel, { STR0032, 'CZ4_QTTEUT', 'aLbxSint[oBrowseUp:At()][29]' } )                                     // 'Horas Normais'
   	aAdd ( aMetricSel, { STR0033, 'CZ4_QTTEEX', 'aLbxSint[oBrowseUp:At()][30]' } )                                     // 'Horas Extras'
   	aAdd ( aMetricSel, { STR0043, 'CZ4_QTTELZ', 'aLbxSint[oBrowseUp:At()][40]' } )                                     // 'Horas sem Apontamento'
	aAdd ( aMetricSel, { STR0044, 'CZ4_QTTESP', 'aLbxSint[oBrowseUp:At()][56]' } )                                     // 'Horas Paradas'
   	aAdd ( aMetricSel, { STR0045, 'CZ4_QTSPPL', 'aLbxSint[oBrowseUp:At()][42]' } )                                     // 'Paradas Programadas'
   	aAdd ( aMetricSel, { STR0248, 'CZ4_QTSPEF', 'aLbxSint[oBrowseUp:At()][18]' } )                                     // 'Paradas Não Programadas'
   	aAdd ( aMetricSel, { STR0046, 'CZ4_VLLZ'  , 'aLbxSint[oBrowseUp:At()][43]' } )                                     // 'DownTime'
   	aAdd ( aMetricSel, { STR0047, 'CZ4_VLOEE' , 'aLbxSint[oBrowseUp:At()][44]' } )                                     // '% Eficiência Líq. (NEE)'
   	aAdd ( aMetricSel, { STR0048, 'CZ4_VLOEE' , 'aLbxSint[oBrowseUp:At()][45]' } )                                     // '% Eficiência Geral (OEE)'
	aAdd ( aMetricSel, { STR0049, 'CZ4_VLTEEP', 'aLbxSint[oBrowseUp:At()][46]' } )                                     // '% Produtividade (TEEP)'
   	aAdd ( aMetricSel, { STR0050, 'CZ4_VLTK'  , 'aLbxSint[oBrowseUp:At()][47]' } )                                     // 'Takt Time (Quant/Min)'
	aShow := {	aFiltro[4][4][2][1][2] , aFiltro[4][4][2][2][2] , aFiltro[4][4][2][3][2] , aFiltro[4][4][2][4][2] , ;
				aFiltro[4][4][2][5][2] , aFiltro[4][4][2][6][2] , aFiltro[4][4][2][7][2] , aFiltro[4][4][2][8][2] , ;
				aFiltro[4][4][2][9][2] , aFiltro[4][4][2][10][2], aFiltro[4][4][2][11][2], aFiltro[4][4][2][12][2], ;
				aFiltro[4][4][2][13][2], aFiltro[4][4][2][14][2], aFiltro[4][4][2][15][2], aFiltro[4][4][2][16][2], ;
				aFiltro[4][4][2][17][2], aFiltro[4][4][2][18][2], aFiltro[4][4][2][19][2], aFiltro[4][4][2][20][2], ;
				aFiltro[4][4][2][21][2], aFiltro[4][4][2][22][2], aFiltro[4][4][2][23][2], aFiltro[4][4][2][24][2] } 
EndIf                                                           
	
// Verifica o numero de niveis para ajustar o + / -
aMaxNumber := aClone( aPanelUp )

IF !__lAutomacao
	aSort( aMaxNumber, , , { | x, y | x[1] > y[1] } )     

	// Cria as colunas de imagem, tipo, código e descrição	
	Add Column oColumn DATA { || If( aLbxSint[oBrowseUp:At()][1] < aMaxNumber[1][1], If( aLbxSint[oBrowseUp:At()][2], 'PMSMENOS', 'PMSMAIS' ), '' ) } Title "" IMAGE Of oBrowseUp
	Add Column oColumn DATA { || Space( ( aLbxSint[oBrowseUp:At()][1]-1 ) * 1 ) + aLbxSint[oBrowseUp:At()][4] } Title STR0051	Size 20 Of oBrowseUp     // 'Tipo'
	Add Column oColumn DATA { || Space( ( aLbxSint[oBrowseUp:At()][1]-1 ) * 2 ) + aLbxSint[oBrowseUp:At()][5] } Title STR0052 	Size 20 Of oBrowseUp     // 'Código'
	Add Column oColumn DATA { || Space( ( aLbxSint[oBrowseUp:At()][1]-1 ) * 3 ) + aLbxSint[oBrowseUp:At()][6] } Title STR0053 	Size 60 Of oBrowseUp     // 'Descrição'

	// Cria os campos selecionados no filtro
	For nI  := 1 To Len(aMetricSel)
		If ( aShow[nI] )
			oColumn := FWBrwColumn():New()
			oColumn:SetData( &( '{ || ' + aMetricSel[nI][3] + ' }' ) )
			oColumn:SetTitle(aMetricSel[nI][1])
			aCampo := TamSx3(aMetricSel[nI][2])
			oColumn:SetType(aCampo[3])	// Tipo
			oColumn:SetSize(aCampo[1])	// Tamanho
			
			// Define máscara caso for um campo numérico	
			If aCampo[3] == 'N'
				oColumn:SetDecimal( aCampo[2] ) 						// Decimais
				oColumn:SetPicture( x3picture(aMetricSel[nI,2]) )	// Picture
			Endif
					
			aAdd(aColumn, oColumn)
		EndIf
	Next  
ENDIF

Return aColumn

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCCAMPOS
Função que define os campos a serem exibidos na tree de acordo com os campos selecionados no filtro.

@author Ana Carolina Tome Klock

@since 25/03/11
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function SFCCAMPOS( cFunction )
Local nI
Local aColumn    := {}
Local aCampo     := {} 
Local aCampoSel  := {}
    
If cFunction== '1' // Refugo/Retrabalho 
	aAdd ( aCampoSel, { STR0054, 'CZ3_CDES'  , 'aPanelShow[oBrowseDo:At()][3]'} )                                                 // 'Estabelecimento'
	aAdd ( aCampoSel, { STR0055, 'CZ3_DSES'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][12]), If(!Empty(aPanelShow[oBrowseDo:At()][3]), POSICIONE("CZ3",1,XFILIAL("CZ3")+aPanelShow[oBrowseDo:At()][12], "CZ3_DSES"),""), "")'} ) // 'Descrição Estabelecimento'
	aAdd ( aCampoSel, { STR0056, 'CYQ_NRORPO', 'aPanelShow[oBrowseDo:At()][4]'} )                                                 // 'Ordem Produção'
	aAdd ( aCampoSel, { STR0057, 'CYQ_CDUNNG', 'aPanelShow[oBrowseDo:At()][5]'} )                                                 // 'Unid. Negócio'
	aAdd ( aCampoSel, { STR0058, 'CYY_IDAT'  , 'aPanelShow[oBrowseDo:At()][6]'} )                                                 // 'Número Operação'
	aAdd ( aCampoSel, { STR0059, 'CYY_IDATQO', 'aPanelShow[oBrowseDo:At()][7]'} )                                                 // 'Split'
	aAdd ( aCampoSel, { STR0060, 'CYV_NRSQRP', 'aPanelShow[oBrowseDo:At()][8]'} )                                                 // 'Sequência Reporte'
	aAdd ( aCampoSel, { STR0061, 'CYO_CDRF'  , 'aPanelShow[oBrowseDo:At()][9]'} )                                                 // 'Motivo'
	aAdd ( aCampoSel, { STR0062, 'CYO_DSRF'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][9]),POSICIONE("CYO",1,XFILIAL("CYO")+ aPanelShow[oBrowseDo:At()][9],"CYO_DSRF"),"")'} ) // 'Descrição Motivo'
	aAdd ( aCampoSel, { STR0063, 'CYA_CDARPO', 'aPanelShow[oBrowseDo:At()][10]'} )                                                // 'Área de Produção'
	aAdd ( aCampoSel, { STR0064, 'CYA_DSARPO', 'If(!Empty(aPanelShow[oBrowseDo:At()][10]),POSICIONE("CYA",1,XFILIAL("CYA")+aPanelShow[oBrowseDo:At()][10],"CYA_DSARPO"), "")'} ) // 'Descrição Área de Produção'
	aAdd ( aCampoSel, { STR0065, 'CYI_CDCETR', 'aPanelShow[oBrowseDo:At()][11]'} )                                                // 'Centro de Trabalho'
	aAdd ( aCampoSel, { STR0066, 'CYI_DSCETR', 'If(!Empty(aPanelShow[oBrowseDo:At()][11]),POSICIONE("CYI",1,XFILIAL("CYI")+aPanelShow[oBrowseDo:At()][11],"CYI_DSCETR"), "")'} ) // 'Descrição Centro Trabalho'
	aAdd ( aCampoSel, { STR0067, 'CYB_CDMQ'  , 'aPanelShow[oBrowseDo:At()][44]'} )                                                // 'Máquina'
	aAdd ( aCampoSel, { STR0068, 'CYB_DSMQ'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][44]),POSICIONE("CYB",1,XFILIAL("CYB")+aPanelShow[oBrowseDo:At()][44],"CYB_DSMQ"), "")'} )   // 'Descrição Máquina'
	aAdd ( aCampoSel, { STR0069, 'CZ3_CDAC'  , 'aPanelShow[oBrowseDo:At()][12]'} )                                                // 'Item'
	aAdd ( aCampoSel, { STR0070, 'CZ3_DSAC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][12]),POSICIONE("CZ3",1,XFILIAL("CZ3")+aPanelShow[oBrowseDo:At()][12], "CZ3_DSAC"), "")'} )  // 'Descrição Item'
	aAdd ( aCampoSel, { STR0071, 'CY9_CDRT'  , 'aPanelShow[oBrowseDo:At()][13]'} )                                                // 'Roteiro'
	aAdd ( aCampoSel, { STR0072, 'CY9_CDAT'  , 'aPanelShow[oBrowseDo:At()][14]'} )                                                // 'Operação'
	aAdd ( aCampoSel, { STR0073, 'CY9_DSAT'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][14]), If(!Empty(aPanelShow[oBrowseDo:At()][4]), If (!Empty(aPanelShow[oBrowseDo:At()][6]), POSICIONE("CY9",1,XFILIAL("CY9")+aPanelShow[oBrowseDo:At()][4]+aPanelShow[oBrowseDo:At()][6], "CY9_DSAT"),""), ""), "")', 20 } ) // 'Descrição Operação'
	aAdd ( aCampoSel, { STR0074, 'CZ3_CDFA'  , 'aPanelShow[oBrowseDo:At()][15]'} )                                                //  'Família'
	aAdd ( aCampoSel, { STR0075, 'CY6_DSFA'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][15]), POSICIONE("CY6",1,XFILIAL("CY6")+aPanelShow[oBrowseDo:At()][15], "CY6_DSFA"),"")' } ) // 'Descrição Família'
	aAdd ( aCampoSel, { STR0076, 'CZ3_CDGR'  , 'aPanelShow[oBrowseDo:At()][16]'} )                                                // 'Grupo de Estoque'
	aAdd ( aCampoSel, { STR0077, 'CY7_DSGE'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][16]), POSICIONE("CY7",1,XFILIAL("CY7")+aPanelShow[oBrowseDo:At()][16], "CY7_DSGE"),"")' } ) // 'Descrição Grupo de Estoque'
	aAdd ( aCampoSel, { STR0078, 'CYQ_TPORPO', 'x3combo("CYQ_TPORPO",aPanelShow[oBrowseDo:At()][17])'} )                          // 'Tipo de Ordem'
	aAdd ( aCampoSel, { STR0079, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][18]'} )                                                // 'Quant. Reportada'
	aAdd ( aCampoSel, { STR0080, 'CYV_QTATAP', 'aPanelShow[oBrowseDo:At()][19]'} )                                                // 'Quant. Aprovada'
	aAdd ( aCampoSel, { STR0081, 'CYV_QTATRT', 'aPanelShow[oBrowseDo:At()][20]'} )                                                // 'Quant. Retrabalho'
	aAdd ( aCampoSel, { STR0082, 'CYV_QTATRF', 'aPanelShow[oBrowseDo:At()][21]'} )                                                // 'Quant. Refugada'
	aAdd ( aCampoSel, { STR0083, 'CYX_DTBGSP', 'aPanelShow[oBrowseDo:At()][22]'} )                                                // 'Início Preparação'
	aAdd ( aCampoSel, { STR0084, 'CYX_HRBGSP', 'aPanelShow[oBrowseDo:At()][23]'} )                                                // 'Hora Início Preparação'
	aAdd ( aCampoSel, { STR0085, 'CYX_DTEDSP', 'aPanelShow[oBrowseDo:At()][24]'} )                                                // 'Fim Preparação'
	aAdd ( aCampoSel, { STR0086, 'CYX_HREDSP', 'aPanelShow[oBrowseDo:At()][25]'} )                                                // 'Hora Fim Preparação'
	aAdd ( aCampoSel, { STR0087, 'CYV_DTRPBG', 'aPanelShow[oBrowseDo:At()][26]'} )                                                // 'Início Reporte'
	aAdd ( aCampoSel, { STR0088, 'CYV_HRRPBG', 'aPanelShow[oBrowseDo:At()][27]'} )                                                // 'Hora Início Reporte'
	aAdd ( aCampoSel, { STR0089, 'CYV_DTRPED', 'aPanelShow[oBrowseDo:At()][28]'} )                                                // 'Fim Reporte'
	aAdd ( aCampoSel, { STR0090, 'CYV_HRRPED', 'aPanelShow[oBrowseDo:At()][29]'} )                                                // 'Hora Fim Reporte'
	aAdd ( aCampoSel, { STR0091, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][30]'} )                                                // 'Tempo Operação'
	aAdd ( aCampoSel, { STR0092, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][31]'} )                                                // 'Tempo MOD'
	aAdd ( aCampoSel, { STR0093, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][32]'} )                                                // 'Tempo Extra'
	aAdd ( aCampoSel, { STR0094, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][33]'} )                                                // 'Tempo Parada'
	aAdd ( aCampoSel, { STR0095, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][34]'} )                                                // 'Operador'
	aAdd ( aCampoSel, { STR0096, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][34]),POSICIONE("CYH",1,XFILIAL("CYH")+"1"+aPanelShow[oBrowseDo:At()][34],"CYH_NMRC"),"")'} )	// 'Nome Operador'
	aAdd ( aCampoSel, { STR0170, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][98]'} )														// 'Ferramenta'
	aAdd ( aCampoSel, { STR0250, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][98]),POSICIONE("CYH",1,XFILIAL("CYH")+"2"+aPanelShow[oBrowseDo:At()][98],"CYH_NMRC"),"")'} )	 // 'Descrição Ferramenta'													// 'Ferramenta'
	aAdd ( aCampoSel, { STR0097, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][35]'} )                                                                                               // 'Equipe Produção'
	aAdd ( aCampoSel, { STR0098, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][35]),POSICIONE("CYH",1,XFILIAL("CYH")+"3"+aPanelShow[oBrowseDo:At()][35],"CYH_NMRC"),"")'} ) // 'Descrição Equipe Produção'
	aAdd ( aCampoSel, { STR0099, 'CYM_CDTN'  , 'aPanelShow[oBrowseDo:At()][36]'} )                                                                                               // 'Modelo Turno'
	aAdd ( aCampoSel, { STR0100, 'CYM_DSTN'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][36]),POSICIONE("CYM",1,XFILIAL("CYM")+aPanelShow[oBrowseDo:At()][36], "CYM_DSTN"),"")'} )    // 'Descrição Modelo Turno'
	aAdd ( aCampoSel, { STR0101, 'CYM_DSTN'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][37]), If (!Empty(aPanelShow[oBrowseDo:At()][36]), Posicione("CYF",,xFilial("CYF")+aPanelShow[oBrowseDo:At()][36]+aPanelShow[oBrowseDo:At()][37],"CYF_DSTN"),""), "")'} ) // 'Turno Produção'
	aAdd ( aCampoSel, { STR0166, 'CYQ_CDLIPO', 'aPanelShow[oBrowseDo:At()][101]'} )													  	// 'Linha de Produção'
	aAdd ( aCampoSel, { STR0167, 'CYQ_CDUSPL', 'aPanelShow[oBrowseDo:At()][102]'} )													  	// 'Planejador'
	aAdd ( aCampoSel, { STR0169, 'CYQ_CDDP'  , 'aPanelShow[oBrowseDo:At()][103]'} )													  	// 'Depósito'
	aAdd ( aCampoSel, { STR0102, 'CYV_NMUSOE', 'USRRETNAME(aPanelShow[oBrowseDo:At()][38])'} )                                     // 'Nome Usuário Reporte'
	aAdd ( aCampoSel, { STR0103, 'CYM_DSTN', 'if(!Empty(aPanelShow[oBrowseDo:At()][39]),If(aPanelShow[oBrowseDo:At()][39],"Sim","Não"),"")'} )                                // 'Liberado CQ'
	aAdd ( aCampoSel, { STR0104, 'CYM_DSTN', 'if(!Empty(aPanelShow[oBrowseDo:At()][40]),If(aPanelShow[oBrowseDo:At()][40],"Sim","Não"),"")'} )                                // 'Operação Final'
	aAdd ( aCampoSel, { STR0105, 'CYV_NRBG'  , 'aPanelShow[oBrowseDo:At()][41]'} )                                                // 'Início Contador'
	aAdd ( aCampoSel, { STR0106, 'CYV_NRED'  , 'aPanelShow[oBrowseDo:At()][42]'} )                                                // 'Fim Contador'
	aAdd ( aCampoSel, { STR0251, 'CYV_VLPNRY', 'aPanelShow[oBrowseDo:At()][104]'} )                                               // '% Avanço'
	aAdd ( aCampoSel, { STR0252, 'CYY_LGCERP', 'if(!Empty(aPanelShow[oBrowseDo:At()][105]),If(aPanelShow[oBrowseDo:At()][105],"Sim","Não"),"Não")'} ) // 'Reportado'
	aAdd ( aCampoSel, { STR0253, 'CYV_TPGGF' , 'x3combo("CYV_TPGGF",aPanelShow[oBrowseDo:At()][106])'} )                           // 'Tipo GGF'
	aAdd ( aCampoSel, { STR0254, 'CYV_TPMOD' , 'x3combo("CYV_TPMOD",aPanelShow[oBrowseDo:At()][107])'} )                           // 'Tipo MOB'
	aAdd ( aCampoSel, { STR0255, 'CYV_TPRF'  , 'x3combo("CYV_TPRF",aPanelShow[oBrowseDo:At()][108])'} )                            // 'Tipo Refugo'
	aAdd ( aCampoSel, { STR0256, 'CYQ_TPRPOR', 'x3combo("CYQ_TPRPOR",aPanelShow[oBrowseDo:At()][109])'} )                          // 'Tipo Apontamento'
	aAdd ( aCampoSel, { STR0257, 'CYV_NRRPOG', 'aPanelShow[oBrowseDo:At()][110]'} )                                                // 'Seq Origem'
ElseIf cFunction == '2' // Parada                                                            
	aAdd ( aCampoSel, { STR0107, 'CYX_TPSP'  , 'aPanelShow[oBrowseDo:At()][43]'} )                                                // 'Tipo Parada'
	aAdd ( aCampoSel, { STR0054, 'CZ3_CDES'  , 'aPanelShow[oBrowseDo:At()][3]'} )                                                 // 'Estabelecimento'
	aAdd ( aCampoSel, { STR0055, 'CZ3_DSES'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][3]),POSICIONE("CZ3",2,XFILIAL("CZ3")+aPanelShow[oBrowseDo:At()][3], "CZ3_DSES"),"")'} )	// 'Descrição Estabelecimento'
	aAdd ( aCampoSel, { STR0063, 'CYA_CDARPO', 'aPanelShow[oBrowseDo:At()][10]'} )  	                                             // 'Área de Produção'
	aAdd ( aCampoSel, { STR0064, 'CYA_DSARPO', 'If(!Empty(aPanelShow[oBrowseDo:At()][10]),POSICIONE("CYA",1,XFILIAL("CYA")+aPanelShow[oBrowseDo:At()][10],"CYA_DSARPO"), "")'} ) // 'Descrição Área de Produção'
	aAdd ( aCampoSel, { STR0065, 'CYI_CDCETR', 'aPanelShow[oBrowseDo:At()][11]'} )                                                // 'Centro de Trabalho'
	aAdd ( aCampoSel, { STR0066, 'CYI_DSCETR', 'If(!Empty(aPanelShow[oBrowseDo:At()][11]),POSICIONE("CYI",1,XFILIAL("CYI")+aPanelShow[oBrowseDo:At()][11],"CYI_DSCETR"), "")'} ) // 'Descrição Centro Trabalho'
	aAdd ( aCampoSel, { STR0067, 'CYB_CDMQ'  , 'aPanelShow[oBrowseDo:At()][44]'} )                                                // 'Máquina'
	aAdd ( aCampoSel, { STR0068, 'CYB_DSMQ'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][45]),POSICIONE("CYB",1,XFILIAL("CYB")+aPanelShow[oBrowseDo:At()][44], "CYB_DSMQ"), "")'} )  // 'Descrição Máquina'
	aAdd ( aCampoSel, { STR0108, 'CYN_CDSP'  , 'aPanelShow[oBrowseDo:At()][45]'} )                                                // 'Parada'
	aAdd ( aCampoSel, { STR0109, 'CYN_DSSP'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][45]),POSICIONE("CYN",1,XFILIAL("CYN")+aPanelShow[oBrowseDo:At()][45], "CYN_DSSP"), "")'} )  // 'Descrição Parada'
	aAdd ( aCampoSel, { STR0095, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][34]'} )                                                // 'Operador'
	aAdd ( aCampoSel, { STR0096, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][34]),POSICIONE("CYH",1,XFILIAL("CYH")+"1"+aPanelShow[oBrowseDo:At()][34],"CYH_NMRC"),"")'} )	 // 'Nome Operador'
	aAdd ( aCampoSel, { STR0097, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][35]'} )                                                // 'Equipe Produção'
	aAdd ( aCampoSel, { STR0098, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][35]),POSICIONE("CYH",1,XFILIAL("CYH")+"3"+aPanelShow[oBrowseDo:At()][35], "CYH_NMRC"),"")'} ) // 'Descrição Equipe Produção'
	aAdd ( aCampoSel, { STR0110, 'CYX_DTBGSP', 'aPanelShow[oBrowseDo:At()][46]'} )                                                // 'Data Início Parada'
	aAdd ( aCampoSel, { STR0111, 'CYX_HRBGSP', 'aPanelShow[oBrowseDo:At()][47]'} )                                                // 'Hora Início Parada'
	aAdd ( aCampoSel, { STR0112, 'CYX_DTEDSP', 'aPanelShow[oBrowseDo:At()][48]'} )                                                // 'Data Fim Parada'
	aAdd ( aCampoSel, { STR0113, 'CYX_HREDSP', 'aPanelShow[oBrowseDo:At()][49]'} )                                                // 'Hora Fim Parada'
	aAdd ( aCampoSel, { STR0114, 'CYX_DTRP'  , 'aPanelShow[oBrowseDo:At()][50]'} )                                                // 'Data Reporte'
	aAdd ( aCampoSel, { STR0115, 'CYX_HRRP'  , 'aPanelShow[oBrowseDo:At()][51]'} )                                                // 'Hora Reporte'
	aAdd ( aCampoSel, { STR0102, 'CYX_CDUSRP', 'aPanelShow[oBrowseDo:At()][38]'} )                                                // 'Usuário Reporte'
	aAdd ( aCampoSel, { STR0116, 'CYX_NMUSRP', 'USRRETNAME( aPanelShow[oBrowseDo:At()][38] )'} )                                  // 'Nome Usuário Reporte'
	aAdd ( aCampoSel, { STR0117, 'CYX_HRTEUT', 'aPanelShow[oBrowseDo:At()][52]'} )                                                // 'Tempo Útil'
	aAdd ( aCampoSel, { STR0093, 'CYX_HRTEUT', 'aPanelShow[oBrowseDo:At()][53]'} )                                                // 'Tempo Extra'
	aAdd ( aCampoSel, { STR0118, 'CZ2_NRSQSP', 'aPanelShow[oBrowseDo:At()][54]'} )                                                // 'Manutenção Programada'
	aAdd ( aCampoSel, { STR0119, 'CYX_IDSPTT', 'aPanelShow[oBrowseDo:At()][55]'} )                                                // 'Parada Geral'
	aAdd ( aCampoSel, { STR0099, 'CYM_CDTN'  , 'aPanelShow[oBrowseDo:At()][36]'} )                                                // 'Modelo Turno'
	aAdd ( aCampoSel, { STR0100, 'CYM_DSTN'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][36]),POSICIONE("CYM",1,XFILIAL("CYM")+aPanelShow[oBrowseDo:At()][36], "CYM_DSTN"),"")'} )                             // 'Descrição Modelo Turno'
	aAdd ( aCampoSel, { STR0101, 'CYF_DSTN'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][37]),Posicione("CYF",,xFilial("CYF")+aPanelShow[oBrowseDo:At()][36]+aPanelShow[oBrowseDo:At()][37],"CYF_DSTN"),"")'} ) // 'Turno Produção'
	aAdd ( aCampoSel, { STR0120, 'CZ2_NRORMN', 'aPanelShow[oBrowseDo:At()][56]'} )                                                // 'Nr. Ordem Manutenção'
	aAdd ( aCampoSel, { STR0121, 'CYM_CDTN'  , 'if(!Empty(aPanelShow[oBrowseDo:At()][83]),if(aPanelShow[oBrowseDo:At()][83],"Sim","Não"),"")'} )                                // 'Parada Programada'
	aAdd ( aCampoSel, { STR0122, 'CZ2_DTBGPL', 'aPanelShow[oBrowseDo:At()][57]'} )                                                // 'Início Programado'
	aAdd ( aCampoSel, { STR0123, 'CZ2_HRBGPL', 'aPanelShow[oBrowseDo:At()][58]'} )                                                // 'Hora Início Programado'
	aAdd ( aCampoSel, { STR0124, 'CZ2_DTEDPL', 'aPanelShow[oBrowseDo:At()][59]'} )                                                // 'Fim Programado'
	aAdd ( aCampoSel, { STR0125, 'CZ2_HREDPL', 'aPanelShow[oBrowseDo:At()][60]'} )                                                // 'Hora Fim Programado'
	aAdd ( aCampoSel, { STR0126, 'CZ2_QTTEMQ', 'aPanelShow[oBrowseDo:At()][61]'} )                                                // 'Tempo Programado'
	aAdd ( aCampoSel, { STR0127, 'CZ2_QTTEEX', 'aPanelShow[oBrowseDo:At()][62]'} )                                                // 'Extra Programado'
	aAdd ( aCampoSel, { STR0128, 'CYM_CDTN'  , 'if(!Empty(aPanelShow[oBrowseDo:At()][63]),if(aPanelShow[oBrowseDo:At()][63],"Sim","Não"),"")'} )                                                // 'Manutenção Ativa'
	aAdd ( aCampoSel, { STR0060, 'CYX_NRSQRP', 'aPanelShow[oBrowseDo:At()][8]'} )                                                 // 'Sequência Reporte'	
ElseIf (cFunction == '3') // Produção 
	aAdd ( aCampoSel, { STR0054, 'CZ3_CDES'  , 'aPanelShow[oBrowseDo:At()][3]'} )                                                 // 'Estabelecimento'
	aAdd ( aCampoSel, { STR0055, 'CZ3_DSES'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][12]), If(!Empty(aPanelShow[oBrowseDo:At()][3]), POSICIONE("CZ3",1,XFILIAL("CZ3")+aPanelShow[oBrowseDo:At()][12], "CZ3_DSES"),""), "")'} ) // 'Descrição Estabelecimento'
	aAdd ( aCampoSel, { STR0056, 'CYQ_NRORPO', 'aPanelShow[oBrowseDo:At()][4]'} )                                                 // 'Ordem Produção'
	aAdd ( aCampoSel, { STR0057, 'CYQ_CDUNNG', 'aPanelShow[oBrowseDo:At()][5]'} )                                                 // 'Unid. Negócio'
	aAdd ( aCampoSel, { STR0058, 'CYY_IDAT'  , 'aPanelShow[oBrowseDo:At()][6]'} )                                                 // 'Número Operação'
	aAdd ( aCampoSel, { STR0059, 'CYY_IDATQO', 'aPanelShow[oBrowseDo:At()][7]'} )                                                 // 'Split'
	aAdd ( aCampoSel, { STR0060, 'CYV_NRSQRP', 'aPanelShow[oBrowseDo:At()][8]'} )                                                 // 'Sequência Reporte'
	aAdd ( aCampoSel, { STR0061, 'CYO_CDRF'  , 'aPanelShow[oBrowseDo:At()][9]'} )                                                 // 'Motivo'
	aAdd ( aCampoSel, { STR0062, 'CYO_DSRF'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][9]),POSICIONE("CYO",1,XFILIAL("CYO")+ aPanelShow[oBrowseDo:At()][9],"CYO_DSRF"),"")'} ) // 'Descrição Motivo'
	aAdd ( aCampoSel, { STR0063, 'CYA_CDARPO', 'aPanelShow[oBrowseDo:At()][10]'} )                                                 // 'Área de Produção'
	aAdd ( aCampoSel, { STR0064, 'CYA_DSARPO', 'If(!Empty(aPanelShow[oBrowseDo:At()][10]),POSICIONE("CYA",1,XFILIAL("CYA")+aPanelShow[oBrowseDo:At()][10], "CYA_DSARPO"), "")'} ) // 'Descrição Área de Produção'
	aAdd ( aCampoSel, { STR0065, 'CYI_CDCETR', 'aPanelShow[oBrowseDo:At()][11]'} )                                                 // 'Centro de Trabalho'
	aAdd ( aCampoSel, { STR0066, 'CYI_DSCETR', 'If(!Empty(aPanelShow[oBrowseDo:At()][11]),POSICIONE("CYI",1,XFILIAL("CYI")+aPanelShow[oBrowseDo:At()][11], "CYI_DSCETR"), "")'} ) // 'Descrição Centro Trabalho'
	aAdd ( aCampoSel, { STR0067, 'CYB_CDMQ'  , 'aPanelShow[oBrowseDo:At()][44]'} )                                                 // 'Máquina'
	aAdd ( aCampoSel, { STR0068, 'CYB_DSMQ'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][44]),POSICIONE("CYB",1,XFILIAL("CYB")+aPanelShow[oBrowseDo:At()][44],"CYB_DSMQ"), "")'} )    // 'Descrição Máquina'
	aAdd ( aCampoSel, { STR0069, 'CZ3_CDAC'  , 'aPanelShow[oBrowseDo:At()][12]'} )                                                 // 'Item'
	aAdd ( aCampoSel, { STR0070, 'CZ3_DSAC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][12]),POSICIONE("CZ3",1,XFILIAL("CZ3")+aPanelShow[oBrowseDo:At()][12], "CZ3_DSAC"), "")'} )   // 'Descrição Item'
	aAdd ( aCampoSel, { STR0071, 'CY9_CDRT'  , 'aPanelShow[oBrowseDo:At()][13]'} )                                                 // 'Roteiro'
	aAdd ( aCampoSel, { STR0072, 'CY9_CDAT'  , 'aPanelShow[oBrowseDo:At()][14]'} )                                                 // 'Operação'
	aAdd ( aCampoSel, { STR0073, 'CY9_DSAT'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][14]), If(!Empty(aPanelShow[oBrowseDo:At()][4]), If (!Empty(aPanelShow[oBrowseDo:At()][6]), POSICIONE("CY9",1,XFILIAL("CY9")+aPanelShow[oBrowseDo:At()][4]+aPanelShow[oBrowseDo:At()][6], "CY9_DSAT"),""), ""), "")'} ) // 'Descrição Operação'  
	aAdd ( aCampoSel, { STR0074, 'CZ3_CDFA'  , 'aPanelShow[oBrowseDo:At()][15]'} )                                                 // 'Família'
	aAdd ( aCampoSel, { STR0075, 'CY6_DSFA'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][15]), POSICIONE("CY6",1,XFILIAL("CY6")+aPanelShow[oBrowseDo:At()][15], "CY6_DSFA"),"")' } ) // 'Descrição Família'		
	aAdd ( aCampoSel, { STR0076, 'CZ3_CDGR'  , 'aPanelShow[oBrowseDo:At()][16]'} )                                                 // 'Grupo de Estoque'
	aAdd ( aCampoSel, { STR0077, 'CY7_DSGE'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][16]), POSICIONE("CY7",1,XFILIAL("CY7")+aPanelShow[oBrowseDo:At()][16], "CY7_DSGE"),"")' } ) // 'Descrição Grupo de Estoque'
	aAdd ( aCampoSel, { STR0078, 'CYQ_TPORPO', 'x3combo("CYQ_TPORPO",aPanelShow[oBrowseDo:At()][17])'} )                           // 'Tipo de Ordem'
	aAdd ( aCampoSel, { STR0079, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][18]'} )                                                 // 'Quant. Reportada'
	aAdd ( aCampoSel, { STR0080, 'CYV_QTATAP', 'aPanelShow[oBrowseDo:At()][19]'} )                                                 // 'Quant. Aprovada' 
	aAdd ( aCampoSel, { STR0081, 'CYV_QTATRT', 'aPanelShow[oBrowseDo:At()][20]'} )                                                 // 'Quant. Retrabalho'
	aAdd ( aCampoSel, { STR0082, 'CYV_QTATRF', 'aPanelShow[oBrowseDo:At()][21]'} )                                                 // 'Quant. Refugada'
	aAdd ( aCampoSel, { STR0083, 'CYX_DTBGSP', 'aPanelShow[oBrowseDo:At()][22]'} )                                                 // 'Início Preparação'
	aAdd ( aCampoSel, { STR0084, 'CYX_HRBGSP', 'aPanelShow[oBrowseDo:At()][23]'} )                                                 // 'Hora Início Preparação'
	aAdd ( aCampoSel, { STR0085, 'CYX_DTEDSP', 'aPanelShow[oBrowseDo:At()][24]'} )                                                 // 'Fim Preparação'
	aAdd ( aCampoSel, { STR0086, 'CYX_HREDSP', 'aPanelShow[oBrowseDo:At()][25]'} )                                                 // 'Hora Fim Preparação'
	aAdd ( aCampoSel, { STR0087, 'CYV_DTRPBG', 'aPanelShow[oBrowseDo:At()][26]'} )                                                 // 'Início Reporte' 
	aAdd ( aCampoSel, { STR0088, 'CYV_HRRPBG', 'aPanelShow[oBrowseDo:At()][27]'} )                                                 // 'Hora Início Reporte'
	aAdd ( aCampoSel, { STR0089, 'CYV_DTRPED', 'aPanelShow[oBrowseDo:At()][28]'} )                                                 // 'Fim Reporte'
	aAdd ( aCampoSel, { STR0090, 'CYV_HRRPED', 'aPanelShow[oBrowseDo:At()][29]'} )                                                 // 'Hora Fim Reporte'
	aAdd ( aCampoSel, { STR0028, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][64]'} )                                                 // 'Tempo Preparação Padrão'
	aAdd ( aCampoSel, { STR0029, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][65]'} )                                                 // 'Tempo Operação Padrão'
	aAdd ( aCampoSel, { STR0129, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][66]'} )                                                 // 'Tempo Preparação'
	aAdd ( aCampoSel, { STR0091, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][30]'} )                                                 // 'Tempo Operação'
	aAdd ( aCampoSel, { STR0092, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][31]'} )                                                 // 'Tempo MOD'
	aAdd ( aCampoSel, { STR0093, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][32]'} )                                                 // 'Tempo Extra'
	aAdd ( aCampoSel, { STR0094, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][33]'} )                                                 // 'Tempo Parada'
	aAdd ( aCampoSel, { STR0034, 'CZ5_VLQL'  , 'aPanelShow[oBrowseDo:At()][67]'} )                                                 // '% Qualidade'
	aAdd ( aCampoSel, { STR0035, 'CZ5_VLQLRY', 'aPanelShow[oBrowseDo:At()][68]'} )                                                 // '% Qualidade Real'
	aAdd ( aCampoSel, { STR0036, 'CZ5_VLEF'  , 'aPanelShow[oBrowseDo:At()][69]'} )                                                 // '% Eficiência'
	aAdd ( aCampoSel, { STR0095, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][34]'} )                                                 // 'Operador'
	aAdd ( aCampoSel, { STR0096, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][34]),POSICIONE("CYH",1,XFILIAL("CYH")+"1"+aPanelShow[oBrowseDo:At()][34],"CYH_NMRC"),"")'} )	// 'Nome Operador'                                                                                              // 'Equipe Produção'
	aAdd ( aCampoSel, { STR0170, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][98]'} )														// 'Ferramenta'
	aAdd ( aCampoSel, { STR0250, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][98]),POSICIONE("CYH",1,XFILIAL("CYH")+"2"+aPanelShow[oBrowseDo:At()][98],"CYH_NMRC"),"")'} )	 // 'Descrição Ferramenta'													// 'Ferramenta'
	aAdd ( aCampoSel, { STR0097, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][35]'} )                                                                                               // 'Equipe Produção'
	aAdd ( aCampoSel, { STR0098, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][35]),POSICIONE("CYH",1,XFILIAL("CYH")+"3"+aPanelShow[oBrowseDo:At()][35],"CYH_NMRC"),"")'} ) // 'Descrição Equipe Produção'
	aAdd ( aCampoSel, { STR0099, 'CYM_CDTN'  , 'aPanelShow[oBrowseDo:At()][36]'} )                                                                                               // 'Modelo Turno'
	aAdd ( aCampoSel, { STR0100, 'CYM_DSTN'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][36]),POSICIONE("CYM",1,XFILIAL("CYM")+aPanelShow[oBrowseDo:At()][36], "CYM_DSTN"),"")'} )    // 'Descrição Modelo Turno'
	aAdd ( aCampoSel, { STR0101, 'CYM_DSTN'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][37]), If (!Empty(aPanelShow[oBrowseDo:At()][36]), Posicione("CYF",,xFilial("CYF")+aPanelShow[oBrowseDo:At()][36]+aPanelShow[oBrowseDo:At()][37],"CYF_DSTN"),""), "")'} ) // 'Turno Produção'
	aAdd ( aCampoSel, { STR0166, 'CYQ_CDLIPO', 'aPanelShow[oBrowseDo:At()][101]'} )													  	// 'Linha de Produção'
	aAdd ( aCampoSel, { STR0167, 'CYQ_CDUSPL', 'aPanelShow[oBrowseDo:At()][102]'} )													  	// 'Planejador'
	aAdd ( aCampoSel, { STR0169, 'CYQ_CDDP'  , 'aPanelShow[oBrowseDo:At()][103]'} )													  	// 'Depósito'
	aAdd ( aCampoSel, { STR0103, 'CYM_CDTN'  , 'if(!Empty(aPanelShow[oBrowseDo:At()][39]),If(aPanelShow[oBrowseDo:At()][39],"Sim","Não"),"")'} )                                 // 'Liberado CQ' 
	aAdd ( aCampoSel, { STR0104, 'CYM_CDTN'  , 'if(!Empty(aPanelShow[oBrowseDo:At()][40]),If(aPanelShow[oBrowseDo:At()][40],"Sim","Não"),"")'} )                                 // 'Operação Final'
	aAdd ( aCampoSel, { STR0105, 'CYV_NRBG'  , 'aPanelShow[oBrowseDo:At()][41]'} )                                                 // 'Início Contador'
	aAdd ( aCampoSel, { STR0106, 'CYV_NRED'  , 'aPanelShow[oBrowseDo:At()][42]'} )                                                 // 'Fim Contador'
	aAdd ( aCampoSel, { STR0251, 'CYV_VLPNRY', 'aPanelShow[oBrowseDo:At()][104]'} )                                                // '% Avanço'
	aAdd ( aCampoSel, { STR0252, 'CYY_LGCERP', 'if(!Empty(aPanelShow[oBrowseDo:At()][105]),If(aPanelShow[oBrowseDo:At()][105],"Sim","Não"),"Não")'} ) // 'Reportado'
	aAdd ( aCampoSel, { STR0253, 'CYV_TPGGF' , 'x3combo("CYV_TPGGF",aPanelShow[oBrowseDo:At()][106])'} )                           // 'Tipo GGF'
	aAdd ( aCampoSel, { STR0254, 'CYV_TPMOD' , 'x3combo("CYV_TPMOD",aPanelShow[oBrowseDo:At()][107])'} )                           // 'Tipo MOB'
	aAdd ( aCampoSel, { STR0255, 'CYV_TPRF'  , 'x3combo("CYV_TPRF",aPanelShow[oBrowseDo:At()][108])'} )                            // 'Tipo Refugo'
	aAdd ( aCampoSel, { STR0256, 'CYQ_TPRPOR', 'x3combo("CYQ_TPRPOR",aPanelShow[oBrowseDo:At()][109])'} )                          // 'Tipo Apontamento'
	aAdd ( aCampoSel, { STR0257, 'CYV_NRRPOG', 'aPanelShow[oBrowseDo:At()][110]'} )                                                // 'Seq Origem'
Else // Indicador
	aAdd ( aCampoSel, { STR0054, 'CZ3_CDES'  , 'aPanelShow[oBrowseDo:At()][3]'} )                                                  // 'Estabelecimento'
	aAdd ( aCampoSel, { STR0055, 'CZ3_DSES'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][12]), If(!Empty(aPanelShow[oBrowseDo:At()][3]), POSICIONE("CZ3",1,XFILIAL("CZ3")+aPanelShow[oBrowseDo:At()][12], "CZ3_DSES"),""), "")'} )	// 'Descrição Estabelecimento'
	aAdd ( aCampoSel, { STR0057, 'CYQ_CDUNNG', 'aPanelShow[oBrowseDo:At()][5]'} )                                                  // 'Unid. Negócio'
	aAdd ( aCampoSel, { STR0061, 'CYO_CDRF'  , 'aPanelShow[oBrowseDo:At()][9]'} )                                                  // 'Motivo'
	aAdd ( aCampoSel, { STR0062, 'CYO_DSRF'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][9]),POSICIONE("CYO",1,XFILIAL("CYO")+ aPanelShow[oBrowseDo:At()][9],"CYO_DSRF"),"")'} )	// 'Descrição Motivo'
	aAdd ( aCampoSel, { STR0063, 'CYA_CDARPO', 'aPanelShow[oBrowseDo:At()][10]'} )                                                 // 'Área de Produção'
	aAdd ( aCampoSel, { STR0064, 'CYA_DSARPO', 'If(!Empty(aPanelShow[oBrowseDo:At()][10]),POSICIONE("CYA",1,XFILIAL("CYA")+aPanelShow[oBrowseDo:At()][10], "CYA_DSARPO"), "")'} ) // 'Descrição Área de Produção'
	aAdd ( aCampoSel, { STR0065, 'CYI_CDCETR', 'aPanelShow[oBrowseDo:At()][11]'} )                                                 // 'Centro de Trabalho'
	aAdd ( aCampoSel, { STR0066, 'CYI_DSCETR', 'If(!Empty(aPanelShow[oBrowseDo:At()][11]),POSICIONE("CYI",1,XFILIAL("CYI")+aPanelShow[oBrowseDo:At()][11], "CYI_DSCETR"), "")'} ) // 'Descrição Centro Trabalho'
	aAdd ( aCampoSel, { STR0067, 'CYB_CDMQ'  , 'aPanelShow[oBrowseDo:At()][44]'} )                                                 // 'Máquina'
	aAdd ( aCampoSel, { STR0068, 'CYB_DSMQ'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][44]),POSICIONE("CYB",1,XFILIAL("CYB")+aPanelShow[oBrowseDo:At()][44],"CYB_DSMQ"), "")'} )    // 'Descrição Máquina'
	aAdd ( aCampoSel, { STR0095, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][34]'} )                                                 // 'Operador'
	aAdd ( aCampoSel, { STR0096, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][34]),POSICIONE("CYH",1,XFILIAL("CYH")+"1"+aPanelShow[oBrowseDo:At()][34],"CYH_NMRC"),"")'} )	// 'Nome Operador'
	aAdd ( aCampoSel, { STR0097, 'CYH_CDRC'  , 'aPanelShow[oBrowseDo:At()][35]'} )                                                                                               // 'Equipe Produção'
	aAdd ( aCampoSel, { STR0098, 'CYH_NMRC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][35]),POSICIONE("CYH",1,XFILIAL("CYH")+"3"+aPanelShow[oBrowseDo:At()][35],"CYH_NMRC"),"")'} ) // 'Descrição Equipe Produção'
	aAdd ( aCampoSel, { STR0056, 'CYQ_NRORPO', 'aPanelShow[oBrowseDo:At()][4]'} )                                                  // 'Ordem Produção'
	aAdd ( aCampoSel, { STR0058, 'CYY_IDAT'  , 'aPanelShow[oBrowseDo:At()][6]'} )                                                  // 'Número Operação'
	aAdd ( aCampoSel, { STR0059, 'CYY_IDATQO', 'aPanelShow[oBrowseDo:At()][7]'} )                                                  // 'Split'
	aAdd ( aCampoSel, { STR0060, 'CYV_NRSQRP', 'aPanelShow[oBrowseDo:At()][8]'} )                                                  // 'Sequência Reporte'
	aAdd ( aCampoSel, { STR0069, 'CZ3_CDAC'  , 'aPanelShow[oBrowseDo:At()][12]'} )                                                 // 'Item'
	aAdd ( aCampoSel, { STR0070, 'CZ3_DSAC'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][12]),POSICIONE("CZ3",1,XFILIAL("CZ3")+aPanelShow[oBrowseDo:At()][12], "CZ3_DSAC"),"")'} ) // 'Descrição Item'
	aAdd ( aCampoSel, { STR0130, 'CYQ_CDRE'  , 'aPanelShow[oBrowseDo:At()][70]'} )                                                 // 'Referência'
	aAdd ( aCampoSel, { STR0071, 'CY9_CDRT'  , 'aPanelShow[oBrowseDo:At()][13]'} )                                                 // 'Roteiro'
	aAdd ( aCampoSel, { STR0072, 'CY9_CDAT'  , 'aPanelShow[oBrowseDo:At()][14]'} )                                                 // 'Operação'
	aAdd ( aCampoSel, { STR0073, 'CY9_DSAT'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][14]), If(!Empty(aPanelShow[oBrowseDo:At()][4]), If (!Empty(aPanelShow[oBrowseDo:At()][6]), POSICIONE("CY9",1,XFILIAL("CY9")+aPanelShow[oBrowseDo:At()][4]+aPanelShow[oBrowseDo:At()][6], "CY9_DSAT"),""), ""), "")'} ) // 'Descrição Operação'		
	aAdd ( aCampoSel, { STR0074, 'CZ3_CDFA'  , 'aPanelShow[oBrowseDo:At()][15]'} )                                                 // 'Família'
	aAdd ( aCampoSel, { STR0075, 'CY6_DSFA'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][15]), POSICIONE("CY6",1,XFILIAL("CY6")+aPanelShow[oBrowseDo:At()][15], "CY6_DSFA"),"")', 30 } ) // 'Descrição Família'		
	aAdd ( aCampoSel, { STR0076, 'CZ3_CDGR'  , 'aPanelShow[oBrowseDo:At()][16]'} )                                                 // 'Grupo de Estoque'
	aAdd ( aCampoSel, { STR0077, 'CY7_DSGE'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][16]), POSICIONE("CY7",1,XFILIAL("CY7")+aPanelShow[oBrowseDo:At()][16], "CY7_DSGE"),"")', 30 } ) // 'Descrição Grupo de Estoque'
	aAdd ( aCampoSel, { STR0131, 'CZ5_TPMV'  , 'x3combo("CZ5_TPMV",aPanelShow[oBrowseDo:At()][71])'} )                             // 'Tipo Registro'
	aAdd ( aCampoSel, { STR0132, 'CYQ_TPORPO', 'x3combo("CYQ_TPORPO",aPanelShow[oBrowseDo:At()][17])'} )                           // 'Tipo de Ordem'
	aAdd ( aCampoSel, { STR0083, 'CYX_DTBGSP', 'aPanelShow[oBrowseDo:At()][22]'} )                                                 // 'Início Preparação'
	aAdd ( aCampoSel, { STR0084, 'CYX_HRBGSP', 'aPanelShow[oBrowseDo:At()][23]'} )                                                 // 'Hora Início Preparação'
	aAdd ( aCampoSel, { STR0085, 'CYX_DTEDSP', 'aPanelShow[oBrowseDo:At()][24]'} )                                                 // 'Fim Preparação'
	aAdd ( aCampoSel, { STR0086, 'CYX_HREDSP', 'aPanelShow[oBrowseDo:At()][25]'} )                                                 // 'Hora Fim Preparação'
	aAdd ( aCampoSel, { STR0133, 'CYV_DTRPBG', 'aPanelShow[oBrowseDo:At()][72]'} )                                                 // 'Data Início'
	aAdd ( aCampoSel, { STR0134, 'CYV_HRRPBG', 'aPanelShow[oBrowseDo:At()][73]'} )                                                 // 'Hora Início'
	aAdd ( aCampoSel, { STR0135, 'CYV_DTRPED', 'aPanelShow[oBrowseDo:At()][74]'} )                                                 // 'Data Fim'
	aAdd ( aCampoSel, { STR0136, 'CYV_HRRPED', 'aPanelShow[oBrowseDo:At()][75]'} )                                                 // 'Hora Fim'		
	aAdd ( aCampoSel, { STR0137, 'CYI_CDUNVM', 'aPanelShow[oBrowseDo:At()][76]'} )                                                 // 'Unidade Capacidade'
	aAdd ( aCampoSel, { STR0138, 'CZ5_QTDIVM', 'aPanelShow[oBrowseDo:At()][77] / 3600'} )                                          // 'Disponibilidade Horas'
	aAdd ( aCampoSel, { STR0139, 'CZ5_QTDIVM', 'aPanelShow[oBrowseDo:At()][78]'} )                                                 // 'Disponibilidade Capacidade'
	aAdd ( aCampoSel, { STR0140, 'CZ5_QTVMMQ', 'aPanelShow[oBrowseDo:At()][90]'} )                                                 // 'Capacidade Máquina'
	aAdd ( aCampoSel, { STR0079, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][18]'} )                                                 // 'Quant. Reportada'
	aAdd ( aCampoSel, { STR0080, 'CYV_QTATAP', 'aPanelShow[oBrowseDo:At()][19]'} )                                                 // 'Quant. Aprovada'
	aAdd ( aCampoSel, { STR0081, 'CYV_QTATRT', 'aPanelShow[oBrowseDo:At()][20]'} ) 
	aAdd ( aCampoSel, { STR0082, 'CYV_QTATRF', 'aPanelShow[oBrowseDo:At()][21]'} )                                                      // 'Quant. Retrabalho'
	aAdd ( aCampoSel, { STR0034, 'CZ5_VLQL'  , 'aPanelShow[oBrowseDo:At()][67]'} )                                                 // '% Qualidade'
	aAdd ( aCampoSel, { STR0035, 'CZ5_VLQLRY', 'aPanelShow[oBrowseDo:At()][68]'} )                                                 // '% Qualidade Real'
	aAdd ( aCampoSel, { STR0129, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][66]'} )                                                 // 'Tempo Preparação'
	aAdd ( aCampoSel, { STR0091, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][30]'} )                                                 // 'Tempo Operação'
	aAdd ( aCampoSel, { STR0093, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][32]'} )                                                 // 'Tempo Extra'
	aAdd ( aCampoSel, { STR0094, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][33]'} )                                                 // 'Tempo Parada'
	aAdd ( aCampoSel, { STR0028, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][64]'} )                                                 // 'Tempo Preparação Padrão'
	aAdd ( aCampoSel, { STR0029, 'CYV_QTATRP', 'aPanelShow[oBrowseDo:At()][65]'} )                                                 // 'Tempo Operação Padrão'
	aAdd ( aCampoSel, { STR0036, 'CZ5_VLEF'  , 'aPanelShow[oBrowseDo:At()][69]'} )                                                 // '% Eficiência'
	aAdd ( aCampoSel, { STR0141, 'CZ5_QTVMAT', 'aPanelShow[oBrowseDo:At()][79]'} )                                                 // 'Capacidade Operação'
	aAdd ( aCampoSel, { STR0142, 'CZ5_NRCNAT', 'aPanelShow[oBrowseDo:At()][80]'} )                                                 // 'Números Unidades Operação'
	aAdd ( aCampoSel, { STR0143, 'CZ5_QTRPEV', 'aPanelShow[oBrowseDo:At()][81]'} )    											  // 'Quantidade Processada'
	aAdd ( aCampoSel, { STR0107, 'CYX_TPSP'  , 'aPanelShow[oBrowseDo:At()][43]'} )                                                 // 'Tipo Parada'
	aAdd ( aCampoSel, { STR0108, 'CYN_CDSP'  , 'aPanelShow[oBrowseDo:At()][45]'} )                                                 // 'Parada'
	aAdd ( aCampoSel, { STR0109, 'CYN_DSSP'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][45]),POSICIONE("CYN",1,XFILIAL("CYN")+aPanelShow[oBrowseDo:At()][45], "CYN_DSSP"),"")'} ) // 'Descrição Parada'
	aAdd ( aCampoSel, { STR0144, 'CYM_CDTN'  , 'if(!Empty(aPanelShow[oBrowseDo:At()][82]),If(aPanelShow[oBrowseDo:At()][82],"Sim","Não"),"")'} ) // 'Altera Eficiência'
	aAdd ( aCampoSel, { STR0121, 'CYM_CDTN'  , 'if(!Empty(aPanelShow[oBrowseDo:At()][83]),If(aPanelShow[oBrowseDo:At()][83],"Sim","Não"),"")'} )                                 // 'Parada Programada'
	aAdd ( aCampoSel, { STR0145, 'CZ5_QTSPPL', 'aPanelShow[oBrowseDo:At()][84]'} )                                                 // 'Quant. Parada Program.'
	aAdd ( aCampoSel, { STR0146, 'CZ5_QTSPPU', 'aPanelShow[oBrowseDo:At()][85]'} )                                                 // 'Quant. Parada Program. Útil'
	aAdd ( aCampoSel, { STR0147, 'CZ5_QTSPRY', 'aPanelShow[oBrowseDo:At()][86]'} )                                                 // 'Quant. Parada Real'
	aAdd ( aCampoSel, { STR0148, 'CZ5_QTSPRU', 'aPanelShow[oBrowseDo:At()][87]'} )                                                 // 'Quant. Parada Real Útil'
	aAdd ( aCampoSel, { STR0149, 'CZ5_QTSPEF', 'aPanelShow[oBrowseDo:At()][88]'} )                                                 // 'Quant. Parada Alt. Efic.'
	aAdd ( aCampoSel, { STR0150, 'CZ5_QTSPAI', 'aPanelShow[oBrowseDo:At()][89]'} )                                                 // 'Quant. Parada não Alt. Efic.'
	aAdd ( aCampoSel, { STR0099, 'CYM_CDTN'  , 'aPanelShow[oBrowseDo:At()][36]'} )                                                 // 'Modelo Turno'
	aAdd ( aCampoSel, { STR0100, 'CYM_DSTN'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][36]),POSICIONE("CYM",1,XFILIAL("CYM")+aPanelShow[oBrowseDo:At()][36], "CYM_DSTN"),"")'} ) // 'Descrição Modelo Turno'
	aAdd ( aCampoSel, { STR0101, 'CYF_DSTN'  , 'If(!Empty(aPanelShow[oBrowseDo:At()][37]),Posicione("CYF",1,xFilial("CYF")+aPanelShow[oBrowseDo:At()][36]+aPanelShow[oBrowseDo:At()][37],"CYF_DSTN"),"")'} ) // 'Turno Produção'  
	aAdd ( aCampoSel, { STR0105, 'CYV_NRBG'  , 'aPanelShow[oBrowseDo:At()][41]'} )                                                 // 'Início Contador'
	aAdd ( aCampoSel, { STR0106, 'CYV_NRED'  , 'aPanelShow[oBrowseDo:At()][42]'} )                                                 // 'Fim Contador'
	aAdd ( aCampoSel, { STR0251, 'CYV_VLPNRY', 'aPanelShow[oBrowseDo:At()][104]'} )                                                // '% Avanço'
	aAdd ( aCampoSel, { STR0252, 'CYY_LGCERP', 'if(!Empty(aPanelShow[oBrowseDo:At()][105]),If(aPanelShow[oBrowseDo:At()][105],"Sim","Não"),"Não")'} ) // 'Reportado'
	aAdd ( aCampoSel, { STR0253, 'CYV_TPGGF' , 'x3combo("CYV_TPGGF",aPanelShow[oBrowseDo:At()][106])'} )                           // 'Tipo GGF'
	aAdd ( aCampoSel, { STR0254, 'CYV_TPMOD' , 'x3combo("CYV_TPMOD",aPanelShow[oBrowseDo:At()][107])'} )                           // 'Tipo MOB'
	aAdd ( aCampoSel, { STR0255, 'CYV_TPRF'  , 'x3combo("CYV_TPRF",aPanelShow[oBrowseDo:At()][108])'} )                            // 'Tipo Refugo'
	aAdd ( aCampoSel, { STR0256, 'CYQ_TPRPOR', 'x3combo("CYQ_TPRPOR",aPanelShow[oBrowseDo:At()][109])'} )                          // 'Tipo Apontamento'
	aAdd ( aCampoSel, { STR0257, 'CYV_NRRPOG', 'aPanelShow[oBrowseDo:At()][110]'} )                                                // 'Seq Origem'
EndIf                                                           

IF !__lAutomacao
	If cFunction == '1' .Or. cFunction == '3'
		Add Column oColumn DATA { || x3combo("CZ5_TPMV", aPanelShow[oBrowseDo:At()][2]) } Title STR0151 Size 20 Of oBrowseDo// "Tipo de Registro"
	EndIf

	For nI  := 1 To Len( aCampoSel )
		If (aField[nI])
			oColumn := FWBrwColumn():New()
			oColumn:SetData( &( '{ || ' + aCampoSel[nI,3] + ' }' ) )
			aCampo := TamSx3(aCampoSel[nI,2])
			oColumn:SetTitle(aCampoSel[nI,1])	// Label
			oColumn:SetType(aCampo[3])			// Tipo
			oColumn:SetSize(aCampo[1])			// Tamanho
			If aCampo[3] == 'N'
				oColumn:SetDecimal( aCampo[2] ) 					// Decimais
				oColumn:SetPicture( x3picture(aCampoSel[nI,2]) )	// Picture
			EndIf
			aAdd(aColumn, oColumn)
		EndIf
	Next    
ENDIF

Return aColumn 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCREFILTRO
Refiltra os dados conforme os dados informados

@param 	aFiltro	Array contendo os valores do filtro

@author 	Ana Carolina Tome Klock
@since 	24/03/2011
@version 	1.0
/*///------------------------------------------------------------------------------------------------
Static Function SFCREFILTRO( aFiltro )
Local aPanelGeral	:= {}
	
SFCC580FIL( @aFiltro, .T. )  

// Se confirmado
If lSuccess
	
	// Carrega dados
	aPanelGeral 	:= SFCXGERENCIAL( aFiltro ) 
	aPanelUp 		:= aPanelGeral[1]
	aPanelDown 	:= aPanelGeral[2]
	If Empty( aPanelUp ) .Or. aPanelUp[1][1] > 1
		Alert( STR0006 ) // "Sua pesquisa não retornou resultados!" 	
		Return .F.
	EndIf 
	aLbxSint 		:= {} 
	oBrowseUp:DeActivate(.T.)
	oBrowseDo:DeActivate(.T.)
	SFCC580BRO( aFiltro[1][1][2] )
	SFCC580TRE( aFiltro[1][1][2], aFiltro )
EndIf   

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCC580FIL
Função que cria uma tela aonde se pode ser incluidos ou alterados os parametros que existem na base

@param		aFiltro		Array contendo os valores do filtro
@param		lRefiltro		Indica se o filtro está sendo chamado pela função SFCREFILTRO

@author 	Ana Carolina Tome Klock
@since 	13/01/2011
@version 	1.0
/*/
//-------------------------------------------------------------------
Static Function SFCC580FIL( aFiltro, lRefiltro )
Local oDlgFilter
Local nFolder		:= 1
Local nI		  	:= 1
Local oFiltro		:= Array( 394 )
Local oBrowseLe, oBrowseRi
Local aButtons	:= { { STR0003, { || SFC580MARK(.T., nFolder, aFiltro, oFiltro ) }, STR0003, STR0003  } , ;  // 'Marcar Tudo'
					     { STR0004, { || SFC580MARK(.F., nFolder, aFiltro, oFiltro ) }, STR0004, STR0004  } }    // 'Desmarcar tudo'
Private oRefugo, oParada, oAponta, oIndica
Default lRefiltro := .F.

// Janela Principal 
If !__lAutomacao
	oDlgFilter := MsDialog():New( 0, 0, 540, 785, STR0152, , , , , CLR_BLACK, CLR_WHITE, , oMainWnd, .T. )  // Filtro Gerencial  
	oDlgFilter:lEscClose := .F.

		oSize := FWDefSize():New(.T.,,,oDlgFilter)
		oSize:AddObject("Panel1", 100, 100, .T., .T. ) //Panel 1 em 100% da tela
			
		oSize:lProp := .T. //permite redimencionar as telas de acordo com a proporção do AddObject
		oSize:Process() //executa os calculos
		
		oPanel := TPanel():New(oSize:GetDimension("Panel1","LININI"),;
							oSize:GetDimension("Panel1","COLINI"),,oDlgFilter,,,,,,;
							oSize:GetDimension("Panel1","XSIZE"),;
							oSize:GetDimension("Panel1","YSIZE"))
			
		// Folder
		aTFolder := { STR0153, STR0154, STR0155, STR0156, STR0157, STR0158 } // 'Seleção' ### 'Parâmetros' ### 'Metricas 1' ### 'Metricas 2' ### 'Dimensão' ### 'Campos'
		oTFolder := TFolder():New( 0, 0, aTFolder, { STR0153, STR0154, STR0155, STR0156, STR0157, STR0158 } , oPanel, , CLR_WHITE, , .T., , 390, 230 ) // 'Seleção' ### 'Parâmetros' ### 'Metricas 1' ### 'Metricas 2' ### 'Dimensão' ### 'Campos'
		oTFolder:bChange := {|| nFolder := oTFolder:nOption } 
			
		
		// Folder Seleção
		@  10, 10 Say aFiltro[1][1][1]                      		Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel   // 'Funcionalidade'
		@   8, 50 Combobox oFiltro[1] Var aFiltro[1][1][2]   	Items aFiltro[1][1][4]  Size 70,10 Pixel Of oTFolder:aDialogs[1]   
		oFiltro[1]:bChange := { || SFCC580VAL( aFiltro, oFiltro, nFolder, oBrowseLe, oBrowseRi ) }
		
		@  25, 10 Say aFiltro[2][1][1]                     	 	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Estabelecimento'
		@  23, 50 MsGet oFiltro[2]  Var aFiltro[2][1][2]   		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  25,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  23,115 MsGet oFiltro[3]  Var aFiltro[2][1][3]   		Size 50,10 Pixel Of oTFolder:aDialogs[1]    
		@  40, 10 Say aFiltro[2][2][1]                     		Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Área de Produção'
		@  38, 50 MsGet oFiltro[4]  Var aFiltro[2][2][2]   		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  40,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  38,115 MsGet oFiltro[5]  Var aFiltro[2][2][3]   		Size 50,10 Pixel Of oTFolder:aDialogs[1]                                
		@  55, 10 Say aFiltro[2][3][1]                     		Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Centro de Trabalho'
		@  53, 50 MsGet oFiltro[6]  Var aFiltro[2][3][2]   		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  55,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  53,115 MsGet oFiltro[7]  Var aFiltro[2][3][3]   		Size 50,10 Pixel Of oTFolder:aDialogs[1]                                                   
		@  70, 10 Say aFiltro[2][4][1]                     		Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Máquina'
		@  68, 50 MsGet oFiltro[8]  Var aFiltro[2][4][2]   		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  70,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  68,115 MsGet oFiltro[9]  Var aFiltro[2][4][3]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  85, 10 Say aFiltro[2][5][1]                     		Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Número da Ordem'
		@  83, 50 MsGet oFiltro[10] Var aFiltro[2][5][2]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  85,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  83,115 MsGet oFiltro[11] Var aFiltro[2][5][3]   		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 100, 10 Say aFiltro[2][6][1]                     		Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Linha de Produção'
		@  98, 50 MsGet oFiltro[12] Var aFiltro[2][6][2]   		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 100,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  98,115 MsGet oFiltro[13] Var aFiltro[2][6][3]   		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 115, 10 Say aFiltro[2][7][1]                     		Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Planejador'
		@ 113, 50 MsGet oFiltro[14] Var aFiltro[2][7][2]    	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 115,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 113,115 MsGet oFiltro[15] Var aFiltro[2][7][3]    	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 130, 10 Say aFiltro[2][8][1]                      	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Equipe'
		@ 128, 50 MsGet oFiltro[16] Var aFiltro[2][8][2]    	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 130,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 128,115 MsGet oFiltro[17] Var aFiltro[2][8][3]    	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                        
		@ 145, 10 Say aFiltro[2][9][1]                      	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Operador'
		@ 143, 50 MsGet oFiltro[18] Var aFiltro[2][9][2]    	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 145,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 143,115 MsGet oFiltro[19] Var aFiltro[2][9][3]    	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                                                  
		@ 160, 10 Say aFiltro[2][10][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Unidade de Negócio'
		@ 158, 50 MsGet oFiltro[20] Var aFiltro[2][10][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 160,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 158,115 MsGet oFiltro[21] Var aFiltro[2][10][3]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                                                                      
		@ 175, 10 Say aFiltro[2][11][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Grupo de Estoque'
		@ 173, 50 MsGet oFiltro[22] Var aFiltro[2][11][2]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 175,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 173,115 MsGet oFiltro[23] Var aFiltro[2][11][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                                                    
		@ 190, 10 Say aFiltro[2][12][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Família'
		@ 188, 50 MsGet oFiltro[24] Var aFiltro[2][12][2]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 190,103 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 188,115 MsGet oFiltro[25] Var aFiltro[2][12][3]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                        
			
		@  10,200 Say aFiltro[2][13][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Item'
		@   8,250 MsGet oFiltro[26] Var aFiltro[2][13][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  10,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@   8,315 MsGet oFiltro[27] Var aFiltro[2][13][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                        
		@  25,200 Say aFiltro[2][14][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Referência'
		@  23,250 MsGet oFiltro[28] Var aFiltro[2][14][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  25,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  23,315 MsGet oFiltro[29] Var aFiltro[2][14][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                        
		@  40,200 Say aFiltro[2][15][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Depósito'
		@  38,250 MsGet oFiltro[30] Var aFiltro[2][15][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  40,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  38,315 MsGet oFiltro[31] Var aFiltro[2][15][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  55,200 Say aFiltro[2][16][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Ferramenta'
		@  53,250 MsGet oFiltro[32] Var aFiltro[2][16][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  55,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  53,315 MsGet oFiltro[33] Var aFiltro[2][16][3]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                        
		@  70,200 Say aFiltro[2][17][1]                    	 	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Emitente'
		@  68,250 MsGet oFiltro[34] Var aFiltro[2][17][2]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  70,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  68,315 MsGet oFiltro[35] Var aFiltro[2][17][3]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                       
		@  85,200 Say aFiltro[2][18][1]                    	 	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Número do Pedido'
		@  83,250 MsGet oFiltro[36] Var aFiltro[2][18][2]  	 	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@  85,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  83,315 MsGet oFiltro[37] Var aFiltro[2][18][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                        
		@ 100,200 Say aFiltro[2][19][1]                    		Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Número do Turno'
		@  98,250 MsGet oFiltro[38] Var aFiltro[2][19][2]  		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 100,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@  98,315 MsGet oFiltro[39] Var aFiltro[2][19][3]  		Size 50,10 Pixel Of oTFolder:aDialogs[1]                                        
		@ 115,200 Say aFiltro[2][20][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Data do Apontamento'
		@ 113,250 MsGet oFiltro[40] Var aFiltro[2][20][2] 		Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 115,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 113,315 MsGet oFiltro[41] Var aFiltro[2][20][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]                                        
		@ 130,200 Say aFiltro[2][21][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Data da Ordem'
		@ 128,250 MsGet oFiltro[42] Var aFiltro[2][21][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 130,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 128,315 MsGet oFiltro[43] Var aFiltro[2][21][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]   
		@ 145,200 Say aFiltro[2][22][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Data Início Mais Cedo'
		@ 143,250 MsGet oFiltro[44] Var aFiltro[2][22][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 145,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 143,315 MsGet oFiltro[45] Var aFiltro[2][22][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]  
		@ 160,200 Say aFiltro[2][23][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Data Fim Mais Tarde'
		@ 158,250 MsGet oFiltro[46] Var aFiltro[2][23][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 160,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 158,315 MsGet oFiltro[47] Var aFiltro[2][23][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]  
		@ 175,200 Say aFiltro[2][24][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Motivo Parada'
		@ 173,250 MsGet oFiltro[48] Var aFiltro[2][24][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 175,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 173,315 MsGet oFiltro[49] Var aFiltro[2][24][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]
		@ 190,200 Say aFiltro[2][25][1]                     	Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'Motivo Refugo'
		@ 188,250 MsGet oFiltro[50] Var aFiltro[2][25][2]   	Size 50,10 Pixel Of oTFolder:aDialogs[1] 
		@ 190,303 Say STR0164              						Of oTFolder:aDialogs[1] COLOR CLR_BLACK Pixel // 'até'
		@ 188,315 MsGet oFiltro[51] Var aFiltro[2][25][3]   	Size 50,10 Pixel Of oTFolder:aDialogs[1]         

		// Folder Parâmetros                                                                                              
		@  10, 10 Say aFiltro[3][1][1]		                 		Of oTFolder:aDialogs[2] COLOR CLR_BLACK Pixel 	   						  			// "Tipo Reporte"
		@  18, 10 Checkbox oFiltro[52]  Var aFiltro[3][1][2][1][2]  PROMPT aFiltro[3][1][2][1][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]   	// "Ordem"  
		@  28, 10 Checkbox oFiltro[53]  Var aFiltro[3][1][2][2][2]  PROMPT aFiltro[3][1][2][2][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Operação" 
		@  38, 10 Checkbox oFiltro[54]  Var aFiltro[3][1][2][3][2]  PROMPT aFiltro[3][1][2][3][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Ponto Controle"
		@  56, 10 Say aFiltro[3][2][1]	            	          	Of oTFolder:aDialogs[2] COLOR CLR_BLACK Pixel                            			// "Tipo Parada"
		@  66, 10 Checkbox oFiltro[55]  Var aFiltro[3][2][2][1][2]  PROMPT aFiltro[3][2][2][1][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Programada"
		@  76, 10 Checkbox oFiltro[56]  Var aFiltro[3][2][2][2][2]  PROMPT aFiltro[3][2][2][2][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Não Programada"
		@  92, 10 Say aFiltro[3][3][1]			                 	Of oTFolder:aDialogs[2] COLOR CLR_BLACK Pixel                           	 		// "Motivo Parada"
		@ 102, 10 Checkbox oFiltro[57]  Var aFiltro[3][3][2][1][2]  PROMPT aFiltro[3][3][2][1][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Altera Eficiência"
		@ 112, 10 Checkbox oFiltro[58]  Var aFiltro[3][3][2][2][2]  PROMPT aFiltro[3][3][2][2][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Emite S.S."
		@ 122, 10 Checkbox oFiltro[59]  Var aFiltro[3][3][2][3][2]  PROMPT aFiltro[3][3][2][3][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "E-Mail Planejador"
		@ 132, 10 Checkbox oFiltro[60]  Var aFiltro[3][3][2][4][2]  PROMPT aFiltro[3][3][2][4][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Parada Preparação"
		@ 150, 10 Say aFiltro[3][4][1]					   		   	Of oTFolder:aDialogs[2] COLOR CLR_BLACK Pixel                            			// "Considera no Indicador"
		@ 160, 10 Checkbox oFiltro[61]  Var aFiltro[3][4][2][1][2]  PROMPT aFiltro[3][4][2][1][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Parada que altera eficiência"
		@ 170, 10 Checkbox oFiltro[62]  Var aFiltro[3][4][2][2][2]  PROMPT aFiltro[3][4][2][2][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Fator refugo"
		@ 180, 10 Checkbox oFiltro[63]  Var aFiltro[3][4][2][3][2]  PROMPT aFiltro[3][4][2][3][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Tempo Extra como Disponível"
		@ 190, 10 Checkbox oFiltro[64]  Var aFiltro[3][4][2][4][2]  PROMPT aFiltro[3][4][2][4][1]  Size 200,07 Pixel Of oTFolder:aDialogs[2]    	// "Considera Preparação nos Indicadores de Eficiência"
		@  10,110 Say aFiltro[3][5][1]		       	          		Of oTFolder:aDialogs[2] COLOR CLR_BLACK Pixel                            			// "Situação Ordem"
		@  18,110 Checkbox oFiltro[65]  Var aFiltro[3][5][2][1][2]  PROMPT aFiltro[3][5][2][1][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Não Iniciada"
		@  28,110 Checkbox oFiltro[66]  Var aFiltro[3][5][2][2][2]  PROMPT aFiltro[3][5][2][2][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Iniciada"
		@  38,110 Checkbox oFiltro[67]  Var aFiltro[3][5][2][3][2]  PROMPT aFiltro[3][5][2][3][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Terminada"
		@  48,110 Checkbox oFiltro[68]  Var aFiltro[3][5][2][4][2]  PROMPT aFiltro[3][5][2][4][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Finalizada"
		@  58,110 Checkbox oFiltro[69]  Var aFiltro[3][5][2][5][2]  PROMPT aFiltro[3][5][2][5][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Alocada"
		@  68,110 Checkbox oFiltro[70]  Var aFiltro[3][5][2][6][2]  PROMPT aFiltro[3][5][2][6][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Separada"
		@  78,110 Checkbox oFiltro[71]  Var aFiltro[3][5][2][7][2]  PROMPT aFiltro[3][5][2][7][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Liberada"
		@  88,110 Checkbox oFiltro[72]  Var aFiltro[3][5][2][8][2]  PROMPT aFiltro[3][5][2][8][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Requisitada"
		@  98,110 Say aFiltro[3][6][1]				         		Of oTFolder:aDialogs[2]  COLOR CLR_BLACK Pixel                           			// "Quantifica Apontamento"
		@ 108,110 Combobox oFiltro[73]  Var aFiltro[3][6][2][1]	   Items  aFiltro[3][6][2][2]  	  Size 90,10 Pixel Of oTFolder:aDialogs[2] 		//"1=Quantidade","2=Peso Líquido","3=Peso Bruto","4=Unid. Capac." 
		@  10,210 Say aFiltro[3][7][1]	                     		Of oTFolder:aDialogs[2] COLOR CLR_BLACK Pixel                            			// "Tipo de Ordem"
		@  18,210 Checkbox oFiltro[74]  Var aFiltro[3][7][2][1][2]  PROMPT aFiltro[3][7][2][1][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Interna"
		@  28,210 Checkbox oFiltro[75]  Var aFiltro[3][7][2][2][2]  PROMPT aFiltro[3][7][2][2][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Externa"
		@  38,210 Checkbox oFiltro[76]  Var aFiltro[3][7][2][3][2]  PROMPT aFiltro[3][7][2][3][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Interna/Externa"
		@  48,210 Checkbox oFiltro[77]  Var aFiltro[3][7][2][4][2]  PROMPT aFiltro[3][7][2][4][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Retrabalho"
		@  58,210 Checkbox oFiltro[78]  Var aFiltro[3][7][2][5][2]  PROMPT aFiltro[3][7][2][5][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Conserto"
		@  68,210 Checkbox oFiltro[79]  Var aFiltro[3][7][2][6][2]  PROMPT aFiltro[3][7][2][6][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Manutenção"
		@  78,210 Checkbox oFiltro[80]  Var aFiltro[3][7][2][7][2]  PROMPT aFiltro[3][7][2][7][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Ativo Fixo"
		@  88,210 Checkbox oFiltro[81]  Var aFiltro[3][7][2][8][2]  PROMPT aFiltro[3][7][2][8][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Ferramentaria"
		@  98,210 Checkbox oFiltro[82]  Var aFiltro[3][7][2][9][2]  PROMPT aFiltro[3][7][2][9][1]  Size 90,007 Pixel Of oTFolder:aDialogs[2]    	// "Reaproveitamento"
		
		// Folder Metricas
		@  10,  10 Say aFiltro[4][1][1]								Of oTFolder:aDialogs[3] COLOR CLR_BLACK Pixel 	                         		// 'Refugo e Retrabalho'
		@  18,  10 Checkbox oFiltro[83]  Var aFiltro[4][1][2][1][2]  PROMPT aFiltro[4][1][2][1][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]  	// 'Produção Real' 
		@  28,  10 Checkbox oFiltro[84]  Var aFiltro[4][1][2][2][2]  PROMPT aFiltro[4][1][2][2][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Refugo Previsto'
		@  38,  10 Checkbox oFiltro[85]  Var aFiltro[4][1][2][3][2]  PROMPT aFiltro[4][1][2][3][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Refugo Previsto'
		@  48,  10 Checkbox oFiltro[86]  Var aFiltro[4][1][2][4][2]  PROMPT aFiltro[4][1][2][4][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Refugo Real'
		@  58,  10 Checkbox oFiltro[87]  Var aFiltro[4][1][2][5][2]  PROMPT aFiltro[4][1][2][5][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Refugo Real'
		@  68,  10 Checkbox oFiltro[88]  Var aFiltro[4][1][2][6][2]  PROMPT aFiltro[4][1][2][6][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Variação Refugo'
		@  78,  10 Checkbox oFiltro[89]  Var aFiltro[4][1][2][7][2]  PROMPT aFiltro[4][1][2][7][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Retrabalho Previsto'
		@  88,  10 Checkbox oFiltro[90]  Var aFiltro[4][1][2][8][2]  PROMPT aFiltro[4][1][2][8][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]	// '% Retrabalho Previsto'
		@  98,  10 Checkbox oFiltro[91]  Var aFiltro[4][1][2][9][2]  PROMPT aFiltro[4][1][2][9][1]  Size 90,007 Pixel Of oTFolder:aDialogs[3]	// 'Retrabalho Real'
		@ 108,  10 Checkbox oFiltro[92]  Var aFiltro[4][1][2][10][2] PROMPT aFiltro[4][1][2][10][1] Size 90,007 Pixel Of oTFolder:aDialogs[3]  	// '% Retrabalho Real'
		@ 118,  10 Checkbox oFiltro[93]  Var aFiltro[4][1][2][11][2] PROMPT aFiltro[4][1][2][11][1] Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Variação Retrabalho'
		@  10, 110 Say aFiltro[4][2][1] 							Of oTFolder:aDialogs[3] COLOR CLR_BLACK Pixel 	                         		// 'Parada'
		@  18, 110 Checkbox oFiltro[94]  Var aFiltro[4][2][2][1][2]  PROMPT aFiltro[4][2][2][1][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Número Paradas' 
		@  28, 110 Checkbox oFiltro[95]  Var aFiltro[4][2][2][2][2]  PROMPT aFiltro[4][2][2][2][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Número Paradas Programadas'
		@  38, 110 Checkbox oFiltro[96]  Var aFiltro[4][2][2][3][2]  PROMPT aFiltro[4][2][2][3][1]	Size 99,007 Pixel Of oTFolder:aDialogs[3]   	// 'Número Paradas Progr. Efetivas'
		@  48, 110 Checkbox oFiltro[97]  Var aFiltro[4][2][2][4][2]  PROMPT aFiltro[4][2][2][4][1]	Size 99,007 Pixel Of oTFolder:aDialogs[3]   	// 'Número Paradas Não Programadas'
		@  58, 110 Checkbox oFiltro[98]  Var aFiltro[4][2][2][5][2]  PROMPT aFiltro[4][2][2][5][1] Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Horas Planejadas'
		@  68, 110 Checkbox oFiltro[99]  Var aFiltro[4][2][2][6][2]  PROMPT aFiltro[4][2][2][6][1] Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Horas Não Planejadas'
		@  78, 110 Checkbox oFiltro[100] Var aFiltro[4][2][2][7][2]  PROMPT aFiltro[4][2][2][7][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Tempo Total Parada'
		@  88, 110 Checkbox oFiltro[101] Var aFiltro[4][2][2][8][2]  PROMPT aFiltro[4][2][2][8][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Programado'
		@  98, 110 Checkbox oFiltro[102] Var aFiltro[4][2][2][9][2]  PROMPT aFiltro[4][2][2][9][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Não Programado'
		@  10, 210 Say aFiltro[4][3][1]        						Of oTFolder:aDialogs[3] COLOR CLR_BLACK Pixel 	                        		// 'Apontamento Produção'
		@  18, 210 Checkbox oFiltro[103] Var aFiltro[4][3][2][1][2]  PROMPT aFiltro[4][3][2][1][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Número Apontamentos'
		@  28, 210 Checkbox oFiltro[104] Var aFiltro[4][3][2][2][2]  PROMPT aFiltro[4][3][2][2][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Tempo Preparação Padrão'
		@  26, 293 COMBOBOX oFiltro[105] Var aFiltro[4][3][2][3][1]  ITEMS  aFiltro[4][3][2][3][2]	Size 90,010 Pixel Of oTFolder:aDialogs[3]   	// '1=Por Operação', '2=Por Split'
		@  38, 210 Checkbox oFiltro[106] Var aFiltro[4][3][2][4][2]  PROMPT aFiltro[4][3][2][4][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Tempo Operação Padrão'
		@  48, 210 Checkbox oFiltro[107] Var aFiltro[4][3][2][5][2]  PROMPT aFiltro[4][3][2][5][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Tempo Preparação Real'
		@  58, 210 Checkbox oFiltro[108] Var aFiltro[4][3][2][6][2]  PROMPT aFiltro[4][3][2][6][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Tempo Operação Real'
		@  68, 210 Checkbox oFiltro[109] Var aFiltro[4][3][2][7][2]  PROMPT aFiltro[4][3][2][7][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Horas Normais'
		@  78, 210 Checkbox oFiltro[110] Var aFiltro[4][3][2][8][2]  PROMPT aFiltro[4][3][2][8][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// 'Horas Extras'
		@  88, 210 Checkbox oFiltro[111] Var aFiltro[4][3][2][9][2]  PROMPT aFiltro[4][3][2][9][1]	Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Qualidade'
		@  98, 210 Checkbox oFiltro[112] Var aFiltro[4][3][2][10][2] PROMPT aFiltro[4][3][2][10][1] Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Qualidade Real'
		@ 108, 210 Checkbox oFiltro[113] Var aFiltro[4][3][2][11][2] PROMPT aFiltro[4][3][2][11][1] Size 90,007 Pixel Of oTFolder:aDialogs[3]   	// '% Eficiência'
		@  10,  10 Say aFiltro[4][4][1]        						Of oTFolder:aDialogs[4] COLOR CLR_BLACK Pixel 	                         	// 'Indicador'
		@  18,  10 Checkbox oFiltro[114] Var aFiltro[4][4][2][1][2]  PROMPT aFiltro[4][4][2][1][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Capacidade de Projeto'
		@  28,  10 Checkbox oFiltro[115] Var aFiltro[4][4][2][2][2]  PROMPT aFiltro[4][4][2][2][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Capacidade Efetiva'
		@  38,  10 Checkbox oFiltro[116] Var aFiltro[4][4][2][3][2]  PROMPT aFiltro[4][4][2][3][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Capacidade Real'
		@  48,  10 Checkbox oFiltro[117] Var aFiltro[4][4][2][4][2]  PROMPT aFiltro[4][4][2][4][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Disponibilidade Planejada'
		@  58,  10 Checkbox oFiltro[118] Var aFiltro[4][4][2][5][2]  PROMPT aFiltro[4][4][2][5][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Disponibilidade Real'
		@  68,  10 Checkbox oFiltro[119] Var aFiltro[4][4][2][6][2]  PROMPT aFiltro[4][4][2][6][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// '% Utilização'
		@  78,  10 Checkbox oFiltro[120] Var aFiltro[4][4][2][7][2]  PROMPT aFiltro[4][4][2][7][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// '% Qualidade'
		@  88,  10 Checkbox oFiltro[121] Var aFiltro[4][4][2][8][2]  PROMPT aFiltro[4][4][2][8][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// '% Qualidade Real'
		@  18, 110 Checkbox oFiltro[122] Var aFiltro[4][4][2][9][2]  PROMPT aFiltro[4][4][2][9][1]	Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// '% Eficiência'
		@  28, 110 Checkbox oFiltro[123] Var aFiltro[4][4][2][10][2] PROMPT aFiltro[4][4][2][10][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Tempo Preparação Padrão'
		@  38, 110 Checkbox oFiltro[124] Var aFiltro[4][4][2][11][2] PROMPT aFiltro[4][4][2][11][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Tempo Operação Padrão'
		@  48, 110 Checkbox oFiltro[125] Var aFiltro[4][4][2][12][2] PROMPT aFiltro[4][4][2][12][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Tempo Preparação Real'
		@  58, 110 Checkbox oFiltro[126] Var aFiltro[4][4][2][13][2] PROMPT aFiltro[4][4][2][13][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Tempo Operação Real'
		@  68, 110 Checkbox oFiltro[127] Var aFiltro[4][4][2][14][2] PROMPT aFiltro[4][4][2][14][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Horas Normais'
		@  78, 110 Checkbox oFiltro[128] Var aFiltro[4][4][2][15][2] PROMPT aFiltro[4][4][2][15][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Horas Extras'
		@  88, 110 Checkbox oFiltro[129] Var aFiltro[4][4][2][16][2] PROMPT aFiltro[4][4][2][16][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Horas Sem Apontamento'
		@  18, 210 Checkbox oFiltro[130] Var aFiltro[4][4][2][17][2] PROMPT aFiltro[4][4][2][17][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Horas Paradas'
		@  28, 210 Checkbox oFiltro[131] Var aFiltro[4][4][2][18][2] PROMPT aFiltro[4][4][2][18][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Paradas Programadas'
		@  38, 210 Checkbox oFiltro[132] Var aFiltro[4][4][2][19][2] PROMPT aFiltro[4][4][2][19][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Paradas Não Programadas'
		@  48, 210 Checkbox oFiltro[133] Var aFiltro[4][4][2][20][2] PROMPT aFiltro[4][4][2][20][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Down Time'
		@  58, 210 Checkbox oFiltro[134] Var aFiltro[4][4][2][21][2] PROMPT aFiltro[4][4][2][21][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// '% Eficiência Liquida (NEE)'
		@  68, 210 Checkbox oFiltro[135] Var aFiltro[4][4][2][22][2] PROMPT aFiltro[4][4][2][22][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// '% Eficiência Geral (OEE)'
		@  78, 210 Checkbox oFiltro[136] Var aFiltro[4][4][2][23][2] PROMPT aFiltro[4][4][2][23][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// '% Produtividade (TEEP)'
		@  88, 210 Checkbox oFiltro[137] Var aFiltro[4][4][2][24][2] PROMPT aFiltro[4][4][2][24][1] Size 90,007 Pixel Of oTFolder:aDialogs[4]   	// 'Takt Time (Quant/Min)' 
		
		// Folder Dimensão                             
		oBrowseLe := TWBrowse():New( 15 , 61, 130, 150,, { STR0222 },{30}, oTFolder:aDialogs[5], ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  // 'Campos Disponíveis'
		oBrowseLe:SetArray(aFieldsDisp)
		oBrowseLe:bLDblClick :=  { || SFCXMOVE(    @oBrowseLe, @oBrowseRi, @aFieldsDisp, @aFieldsSel ), oBrowseLe:Refresh(), oBrowseRi:Refresh()  } 
		oBrowseLe:bLine := {||{ If(Len(aFieldsDisp) > 0,  If(oBrowseLe:nAt < Len(aFieldsDisp), aFieldsDisp[oBrowseLe:nAt][1],) , ) } }
		
		TButton():New( 50,  196,  '>', oTFolder:aDialogs[5], {|| SFCXMOVE(    @oBrowseLe, @oBrowseRi, @aFieldsDisp, @aFieldsSel) }, 10,10,,,,.T.)
		TButton():New( 65,  196,  '<', oTFolder:aDialogs[5], {|| SFCXMOVE(    @oBrowseRi, @oBrowseLe, @aFieldsSel,  @aFieldsDisp) },10,10,,,,.T.)
		TButton():New( 80,  196, '>>', oTFolder:aDialogs[5], {|| SFCXALL(     @oBrowseLe, @oBrowseRi, @aFieldsDisp, @aFieldsSel) }, 10,10,,,,.T.)
		TButton():New( 95,  196, '<<', oTFolder:aDialogs[5], {|| SFCXALL(     @oBrowseRi, @oBrowseLe, @aFieldsSel,  @aFieldsDisp) },10,10,,,,.T.)
		TButton():New( 110, 196, '/\', oTFolder:aDialogs[5], {|| SFCXMOVEUP(  @oBrowseRi, @aFieldsSel) },10,10,,,,.T.)
		TButton():New( 125, 196, '\/', oTFolder:aDialogs[5], {|| SFCXMOVEDOWN(@oBrowseRi, @aFieldsSel) },10,10,,,,.T.)
		
		oBrowseRi := TWBrowse():New( 15 , 212, 130, 150,, { STR0223 },{30}, oTFolder:aDialogs[5], ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) // 'Campos Selecionados'
		oBrowseRi:SetArray(aFieldsSel)
		oBrowseRi:bLine := {||{ If(Len(aFieldsSel) > 0,aFieldsSel[oBrowseRi:nAt][1], ) } } 
		oBrowseRi:bLDblClick :=  { || SFCXMOVE(  @oBrowseRi, @oBrowseLe, @aFieldsSel,  @aFieldsDisp), oBrowseLe:Refresh(), oBrowseRi:Refresh() } 
	
		// Folder Campos
		//Regugo
		TelaRefugo(@oFiltro)
		//Parada
		TelaParada(@oFiltro)
		//Apontamento
		TelaApont(@oFiltro)
		//Indicadores
		TelaIndica(@oFiltro)
EndIf
	
    // Altera os valores padrões conforme funcionalidade  
	If !lRefiltro 
  		SFCC580VAL( aFiltro, oFiltro, nFolder, oBrowseLe, oBrowseRi )
	EndIf
	SFCC580HAB( aFiltro[1][1][2] )
	SFCC580VAL( aFiltro, oFiltro, nFolder, oBrowseLe, oBrowseRi, lRefiltro )
	
	If !__lAutomacao
		oDlgFilter:Activate( , , , .T. , , , { || EnchoiceBar(oDlgFilter, { || lSuccess:= .T., oDlgFilter:End() }, { || lSuccess := .F., oDlgFilter:End() } , , aButtons) }  )
	EndIf
Return NIL 
//-------------------------------------------------------------------
Static Function TelaRefugo(oFiltro)
	oRefugo			:= TPanel():New( 0, 0, , oTFolder:aDialogs[6], , , , , CLR_WHITE, 350, 235, .F., .F. )
	oRefugo:Align	:= CONTROL_ALIGN_TOP
	@  10,  10 Say STR0217        	Of oRefugo  COLOR CLR_BLACK Pixel 									// "Refugos e Retrabalhos"
  	@  18,  10 Checkbox oFiltro[138] Var aField[1]   PROMPT  STR0054  	Size 90,07 Pixel Of oRefugo // "Estabelecimento"
  	@  28,  10 Checkbox oFiltro[139] Var aField[2]   PROMPT  STR0055 	Size 90,07 Pixel Of oRefugo // "Nome Estabelecimento" 
  	@  38,  10 Checkbox oFiltro[140] Var aField[3]   PROMPT  STR0056 	Size 90,07 Pixel Of oRefugo // "Ordem Produção"
  	@  48,  10 Checkbox oFiltro[141] Var aField[4]   PROMPT  STR0057 	Size 90,07 Pixel Of oRefugo // "Unid. Negócio"
  	@  58,  10 Checkbox oFiltro[142] Var aField[5]   PROMPT  STR0058 	Size 90,07 Pixel Of oRefugo // "Número Operação"
  	@  68,  10 Checkbox oFiltro[143] Var aField[6]   PROMPT  STR0059	Size 90,07 Pixel Of oRefugo // "Split"
  	@  78,  10 Checkbox oFiltro[144] Var aField[7]   PROMPT  STR0060	Size 90,07 Pixel Of oRefugo // "Sequência Reporte"
  	@  88,  10 Checkbox oFiltro[145] Var aField[8]   PROMPT  STR0061	Size 90,07 Pixel Of oRefugo // "Motivo"
  	@  98,  10 Checkbox oFiltro[146] Var aField[9]   PROMPT  STR0062	Size 90,07 Pixel Of oRefugo // "Descrição Motivo"
  	@ 108,  10 Checkbox oFiltro[147] Var aField[10]  PROMPT  STR0063	Size 90,07 Pixel Of oRefugo // "Área de Produção"
  	@ 118,  10 Checkbox oFiltro[148] Var aField[11]  PROMPT  STR0064	Size 90,07 Pixel Of oRefugo // "Descrição Área de Produção"
  	@ 128,  10 Checkbox oFiltro[149] Var aField[12]  PROMPT  STR0065	Size 90,07 Pixel Of oRefugo // "Centro de Trabalho"
   	@ 138,  10 Checkbox oFiltro[150] Var aField[13]  PROMPT  STR0066  	Size 90,07 Pixel Of oRefugo // "Descrição Centro Trabalho"
   	@ 148,  10 Checkbox oFiltro[151] Var aField[14]  PROMPT  STR0067	Size 90,07 Pixel Of oRefugo // "Máquina"
  	@ 158,  10 Checkbox oFiltro[152] Var aField[15]  PROMPT  STR0068 	Size 90,07 Pixel Of oRefugo // "Descrição Máquina"
  	@  18, 100 Checkbox oFiltro[153] Var aField[16]  PROMPT  STR0069	Size 90,07 Pixel Of oRefugo // "Item"
  	@  28, 100 Checkbox oFiltro[154] Var aField[17]  PROMPT  STR0070 	Size 90,07 Pixel Of oRefugo // "Descrição Item"
  	@  38, 100 Checkbox oFiltro[155] Var aField[18]  PROMPT  STR0071	Size 90,07 Pixel Of oRefugo // "Roteiro"
  	@  48, 100 Checkbox oFiltro[156] Var aField[19]  PROMPT  STR0072	Size 90,07 Pixel Of oRefugo // "Operação" 
  	@  58, 100 Checkbox oFiltro[157] Var aField[20]  PROMPT  STR0073	Size 90,07 Pixel Of oRefugo // "Descrição Operação"
  	@  68, 100 Checkbox oFiltro[158] Var aField[21]  PROMPT  STR0074	Size 90,07 Pixel Of oRefugo // "Família" 
  	@  78, 100 Checkbox oFiltro[159] Var aField[22]  PROMPT  STR0075	Size 90,07 Pixel Of oRefugo // "Descrição Família"
  	@  88, 100 Checkbox oFiltro[160] Var aField[23]  PROMPT  STR0076	Size 90,07 Pixel Of oRefugo // "Grupo de Estoque"
  	@  98, 100 Checkbox oFiltro[161] Var aField[24]  PROMPT  STR0077	Size 90,07 Pixel Of oRefugo // "Descrição Grupo de Estoque"
  	@ 108, 100 Checkbox oFiltro[162] Var aField[25]  PROMPT  STR0078	Size 90,07 Pixel Of oRefugo // "Tipo de Ordem" 
  	@ 118, 100 Checkbox oFiltro[163] Var aField[26]  PROMPT  STR0079	Size 90,07 Pixel Of oRefugo // "Quantidade Reportada"
  	@ 128, 100 Checkbox oFiltro[164] Var aField[27]  PROMPT  STR0080	Size 90,07 Pixel Of oRefugo // "Quantidade Aprovada"
  	@ 138, 100 Checkbox oFiltro[165] Var aField[28]  PROMPT  STR0081	Size 90,07 Pixel Of oRefugo // "Quantidade Retrabalho"         
   	@ 148, 100 Checkbox oFiltro[166] Var aField[29]  PROMPT  STR0082	Size 90,07 Pixel Of oRefugo // "Quantidade Refugada"
   	@ 158, 100 Checkbox oFiltro[167] Var aField[30]  PROMPT  STR0083	Size 90,07 Pixel Of oRefugo // "Início Preparação"
  	@  18, 190 Checkbox oFiltro[168] Var aField[31]  PROMPT  STR0084	Size 90,07 Pixel Of oRefugo // "Hora Início Preparação"
  	@  28, 190 Checkbox oFiltro[169] Var aField[32]  PROMPT  STR0085	Size 90,07 Pixel Of oRefugo // "Fim Preparação"
  	@  38, 190 Checkbox oFiltro[170] Var aField[33]  PROMPT  STR0086	Size 90,07 Pixel Of oRefugo // "Hora Fim Preparação"
  	@  48, 190 Checkbox oFiltro[171] Var aField[34]  PROMPT  STR0087	Size 90,07 Pixel Of oRefugo // "Início Reporte"
  	@  58, 190 Checkbox oFiltro[172] Var aField[35]  PROMPT  STR0088	Size 90,07 Pixel Of oRefugo // "Hora Início Reporte"
  	@  68, 190 Checkbox oFiltro[173] Var aField[36]  PROMPT  STR0089	Size 90,07 Pixel Of oRefugo // "Fim Reporte"
  	@  78, 190 Checkbox oFiltro[174] Var aField[37]  PROMPT  STR0090	Size 90,07 Pixel Of oRefugo // "Hora Fim Reporte"
  	@  88, 190 Checkbox oFiltro[175] Var aField[38]  PROMPT  STR0091	Size 90,07 Pixel Of oRefugo // "Tempo Operação"
  	@  98, 190 Checkbox oFiltro[176] Var aField[39]  PROMPT  STR0092	Size 90,07 Pixel Of oRefugo // "Tempo MOD" 		
  	@ 108, 190 Checkbox oFiltro[177] Var aField[40]  PROMPT  STR0093	Size 90,07 Pixel Of oRefugo // "Tempo Extra"
  	@ 118, 190 Checkbox oFiltro[178] Var aField[41]  PROMPT  STR0094	Size 90,07 Pixel Of oRefugo // "Tempo Parada"  
  	@ 128, 190 Checkbox oFiltro[179] Var aField[42]  PROMPT  STR0095	Size 90,07 Pixel Of oRefugo // "Operador"
  	@ 138, 190 Checkbox oFiltro[180] Var aField[43]  PROMPT  STR0096	Size 90,07 Pixel Of oRefugo // "Nome Operador"
  	@ 148, 190 Checkbox oFiltro[181] Var aField[44]  PROMPT  STR0170	Size 90,07 Pixel Of oRefugo // "Ferramenta"
  	@ 158, 190 Checkbox oFiltro[182] Var aField[45]  PROMPT  STR0250	Size 90,07 Pixel Of oRefugo // "Descrição Ferramenta"
  	@  18, 280 Checkbox oFiltro[183] Var aField[46]  PROMPT  STR0097	Size 90,07 Pixel Of oRefugo // "Equipe Produção"
  	@  28, 280 Checkbox oFiltro[184] Var aField[47]  PROMPT  STR0098	Size 90,07 Pixel Of oRefugo // "Descrição Equipe" 
  	@  38, 280 Checkbox oFiltro[185] Var aField[48]  PROMPT  STR0099	Size 90,07 Pixel Of oRefugo // "Modelo Turno"
  	@  48, 280 Checkbox oFiltro[186] Var aField[49]  PROMPT  STR0100	Size 90,07 Pixel Of oRefugo // "Descrição Modelo Turno"
  	@  58, 280 Checkbox oFiltro[187] Var aField[50]  PROMPT  STR0101	Size 90,07 Pixel Of oRefugo // "Turno Produção"
  	@  68, 280 Checkbox oFiltro[188] Var aField[51]  PROMPT  STR0166	Size 90,07 Pixel Of oRefugo // "Linha de Produção"
  	@  78, 280 Checkbox oFiltro[189] Var aField[52]  PROMPT  STR0167	Size 90,07 Pixel Of oRefugo // "Planejador"
  	@  88, 280 Checkbox oFiltro[190] Var aField[53]  PROMPT  STR0169	Size 90,07 Pixel Of oRefugo // "Depósito"
  	@  98, 280 Checkbox oFiltro[191] Var aField[54]  PROMPT  STR0102 	Size 90,07 Pixel Of oRefugo // "Nome Usuário Reporte"
  	@ 108, 280 Checkbox oFiltro[192] Var aField[55]  PROMPT  STR0103	Size 90,07 Pixel Of oRefugo // "Liberado CQ"
  	@ 118, 280 Checkbox oFiltro[193] Var aField[56]  PROMPT  STR0104	Size 90,07 Pixel Of oRefugo // "Operação Final"
  	@ 128, 280 Checkbox oFiltro[194] Var aField[57]  PROMPT  STR0105	Size 90,07 Pixel Of oRefugo // "Início Contador"		
  	@ 138, 280 Checkbox oFiltro[195] Var aField[58]  PROMPT  STR0106	Size 90,07 Pixel Of oRefugo // "Fim Contador"  	
  	@ 148, 280 Checkbox oFiltro[196] Var aField[59]  PROMPT  STR0251	Size 90,07 Pixel Of oRefugo // "% Avanço"
	@ 158, 280 Checkbox oFiltro[377] Var aField[60]  PROMPT  STR0252	Size 90,07 Pixel Of oRefugo // "Reportado" 
	@ 168,  10 Checkbox oFiltro[378] Var aField[61]  PROMPT  STR0253	Size 90,07 Pixel Of oRefugo // "Tipo GGF" 
	@ 168, 100 Checkbox oFiltro[379] Var aField[62]  PROMPT  STR0254	Size 90,07 Pixel Of oRefugo // "Tipo MOB" 
	@ 168, 190 Checkbox oFiltro[380] Var aField[63]  PROMPT  STR0255	Size 90,07 Pixel Of oRefugo // "Tipo Refugo" 
	@ 168, 280 Checkbox oFiltro[381] Var aField[64]  PROMPT  STR0256	Size 90,07 Pixel Of oRefugo // "Tipo Apontamento" 
	@ 178,  10 Checkbox oFiltro[382] Var aField[65]  PROMPT  STR0257	Size 90,07 Pixel Of oRefugo // "Seq Origem" 
  	oFiltro[191]:bLClicked := { || If ( aField[54], alert('Ao selecionar "Nome Usuário Reporte", o carregamento dos dados será mais lento'), Nil), .T. }
Return Nil
//-------------------------------------------------------------------
Static Function TelaParada(oFiltro)
	oParada			:= TPanel():New( 0, 0, , oTFolder:aDialogs[6], , , , , CLR_WHITE, 350, 235, .F., .F. )
	oParada:Align	:= CONTROL_ALIGN_TOP
   	@  10,  10 Say STR0108          	Of oParada  COLOR CLR_BLACK Pixel               				// "Parada"
 	@  18,  10 Checkbox oFiltro[197] Var aField[1]   PROMPT STR0107	Size 90,07 Pixel Of oParada	// "Tipo Parada"				
  	@  28,  10 Checkbox oFiltro[198] Var aField[2]   PROMPT STR0054	Size 90,07 Pixel Of oParada // "Estabelecimento"
  	@  38,  10 Checkbox oFiltro[199] Var aField[3]   PROMPT STR0055	Size 90,07 Pixel Of oParada // "Nome Estabelecimento"
  	@  48,  10 Checkbox oFiltro[200] Var aField[4]   PROMPT STR0063	Size 90,07 Pixel Of oParada // "Área de Produção" 
  	@  58,  10 Checkbox oFiltro[201] Var aField[5]   PROMPT STR0064	Size 90,07 Pixel Of oParada // "Descrição Área de Produção"
  	@  68,  10 Checkbox oFiltro[202] Var aField[6]   PROMPT STR0065	Size 90,07 Pixel Of oParada // "Centro de Trabalho"
   	@  78,  10 Checkbox oFiltro[203] Var aField[7]   PROMPT STR0066   	Size 90,07 Pixel Of oParada // "Descrição Centro Trabalho"
  	@  88,  10 Checkbox oFiltro[204] Var aField[8]   PROMPT STR0067	Size 90,07 Pixel Of oParada // "Máquina"
  	@  98,  10 Checkbox oFiltro[205] Var aField[9]   PROMPT STR0068	Size 90,07 Pixel Of oParada // "Descrição Máquina"
	@ 108,  10 Checkbox oFiltro[206] Var aField[10]  PROMPT STR0108	Size 90,07 Pixel Of oParada // "Parada" 
	@  18, 100 Checkbox oFiltro[207] Var aField[11]  PROMPT STR0109	Size 90,07 Pixel Of oParada // "Descrição Parada"
	@  28, 100 Checkbox oFiltro[208] Var aField[12]  PROMPT STR0095	Size 90,07 Pixel Of oParada // "Operador"
  	@  38, 100 Checkbox oFiltro[209] Var aField[13]  PROMPT STR0096	Size 90,07 Pixel Of oParada // "Descrição Operador"
  	@  48, 100 Checkbox oFiltro[210] Var aField[14]  PROMPT STR0097	Size 90,07 Pixel Of oParada // "Equipe Produção"
  	@  58, 100 Checkbox oFiltro[211] Var aField[15]  PROMPT STR0098	Size 90,07 Pixel Of oParada // "Descrição Equipe"
  	@  68, 100 Checkbox oFiltro[212] Var aField[16]  PROMPT STR0110	Size 90,07 Pixel Of oParada // "Data Início Parada" 
  	@  78, 100 Checkbox oFiltro[213] Var aField[17]  PROMPT STR0111	Size 90,07 Pixel Of oParada // "Hora Início Parada"
  	@  88, 100 Checkbox oFiltro[214] Var aField[18]  PROMPT STR0112	Size 90,07 Pixel Of oParada // "Data Fim Parada"
  	@  98, 100 Checkbox oFiltro[215] Var aField[19]  PROMPT STR0113	Size 90,07 Pixel Of oParada // "Hora Fim Parada"
  	@ 108, 100 Checkbox oFiltro[216] Var aField[20]  PROMPT STR0114	Size 90,07 Pixel Of oParada // "Data Reporte" 
  	@  18, 190 Checkbox oFiltro[217] Var aField[21]  PROMPT STR0115	Size 90,07 Pixel Of oParada // "Hora Reporte"
  	@  28, 190 Checkbox oFiltro[218] Var aField[22]  PROMPT STR0116	Size 90,07 Pixel Of oParada // "Usuário Reporte"
   	@  38, 190 Checkbox oFiltro[219] Var aField[23]  PROMPT STR0102	Size 90,07 Pixel Of oParada // "Nome Usuário Reporte" 
  	@  48, 190 Checkbox oFiltro[220] Var aField[24]  PROMPT STR0117	Size 90,07 Pixel Of oParada // "Tempo Útil"  
  	@  58, 190 Checkbox oFiltro[221] Var aField[25]  PROMPT STR0093	Size 90,07 Pixel Of oParada // "Tempo Extra"
  	@  68, 190 Checkbox oFiltro[222] Var aField[26]  PROMPT STR0118 Size 90,07 Pixel Of oParada // "Manutenção Programada"
  	@  78, 190 Checkbox oFiltro[223] Var aField[27]  PROMPT STR0119 Size 90,07 Pixel Of oParada // "Parada Geral"
  	@  88, 190 Checkbox oFiltro[224] Var aField[28]  PROMPT STR0099	Size 90,07 Pixel Of oParada // "Modelo Turno" 
  	@  98, 190 Checkbox oFiltro[225] Var aField[29]  PROMPT STR0100 Size 90,07 Pixel Of oParada // "Descrição Modelo Turno"
  	@ 108, 190 Checkbox oFiltro[226] Var aField[30]  PROMPT STR0101	Size 90,07 Pixel Of oParada // "Turno Produção"
  	@  18, 280 Checkbox oFiltro[227] Var aField[31]  PROMPT STR0120 Size 90,07 Pixel Of oParada // "Nr Ordem Manutenção"	    
  	@  28, 280 Checkbox oFiltro[228] Var aField[32]  PROMPT STR0121	Size 90,07 Pixel Of oParada // "Parada Programada"  	    
  	@  38, 280 Checkbox oFiltro[229] Var aField[33]  PROMPT STR0122	Size 90,07 Pixel Of oParada // "Início Programado" 
  	@  48, 280 Checkbox oFiltro[230] Var aField[34]  PROMPT STR0123 Size 90,07 Pixel Of oParada // "Hora Programada Início"
  	@  58, 280 Checkbox oFiltro[231] Var aField[35]  PROMPT STR0124	Size 90,07 Pixel Of oParada // "Fim Programado"
  	@  68, 280 Checkbox oFiltro[232] Var aField[36]  PROMPT STR0125 Size 90,07 Pixel Of oParada // "Hora Programada Fim"
  	@  78, 280 Checkbox oFiltro[233] Var aField[37]  PROMPT STR0126	Size 90,07 Pixel Of oParada // "Tempo Programado" 
  	@  88, 280 Checkbox oFiltro[234] Var aField[38]  PROMPT STR0127	Size 90,07 Pixel Of oParada // "Extra Programado" 
  	@  98, 280 Checkbox oFiltro[235] Var aField[39]  PROMPT STR0128	Size 90,07 Pixel Of oParada // "Manutencao Ativa" 
  	@ 108, 280 Checkbox oFiltro[236] Var aField[40]  PROMPT STR0060	Size 90,07 Pixel Of oParada // "Sequência Reporte" 
  	oFiltro[218]:bLClicked := { || If ( aField[23], alert('Ao selecionar "Nome Usuário Reporte", o carregamento dos dados será mais lento'), Nil), .T. }
Return Nil
//-------------------------------------------------------------------
Static Function TelaApont(oFiltro)
	oAponta			:= TPanel():New( 0, 0, , oTFolder:aDialogs[6], , , , , CLR_WHITE, 350, 235, .F., .F. )
	oAponta:Align	:= CONTROL_ALIGN_TOP	
  	@  10,  10 Say STR0218		  	Of oAponta  COLOR CLR_BLACK Pixel           		   				// "Apontamento de Produção" 
  	@  18,  10 Checkbox oFiltro[237] Var aField[1]   PROMPT STR0054	Size 90,07 Pixel Of oAponta // "Estabelecimento" 
  	@  28,  10 Checkbox oFiltro[238] Var aField[2]   PROMPT STR0055 Size 90,07 Pixel Of oAponta // "Nome Estabelecimento"
  	@  38,  10 Checkbox oFiltro[239] Var aField[3]   PROMPT STR0056	Size 90,07 Pixel Of oAponta // "Ordem Produção"
  	@  48,  10 Checkbox oFiltro[240] Var aField[4]   PROMPT STR0057	Size 90,07 Pixel Of oAponta // "Unid. Negócio"
  	@  58,  10 Checkbox oFiltro[241] Var aField[5]   PROMPT STR0058 Size 90,07 Pixel Of oAponta // "Número Operação"
  	@  68,  10 Checkbox oFiltro[242] Var aField[6]   PROMPT STR0059	Size 90,07 Pixel Of oAponta // "Split"
  	@  78,  10 Checkbox oFiltro[243] Var aField[7]   PROMPT STR0060	Size 90,07 Pixel Of oAponta // "Sequência Reporte"
  	@  88,  10 Checkbox oFiltro[244] Var aField[8]   PROMPT STR0061	Size 90,07 Pixel Of oAponta // "Motivo"
  	@  98,  10 Checkbox oFiltro[245] Var aField[9]   PROMPT STR0062	Size 90,07 Pixel Of oAponta // "Descrição Motivo"
  	@ 108,  10 Checkbox oFiltro[246] Var aField[10]  PROMPT STR0063	Size 90,07 Pixel Of oAponta // "Área de Produção"
  	@ 118,  10 Checkbox oFiltro[247] Var aField[11]  PROMPT STR0064	Size 90,07 Pixel Of oAponta // "Descrição Área de Produção"
  	@ 128,  10 Checkbox oFiltro[248] Var aField[12]  PROMPT STR0065	Size 90,07 Pixel Of oAponta // "Centro de Trabalho"
   	@ 138,  10 Checkbox oFiltro[249] Var aField[13]  PROMPT STR0066	Size 90,07 Pixel Of oAponta // "Descrição Centro Trabalho"
   	@ 148,  10 Checkbox oFiltro[250] Var aField[14]  PROMPT STR0067	Size 90,07 Pixel Of oAponta // "Máquina"
  	@ 158,  10 Checkbox oFiltro[251] Var aField[15]  PROMPT STR0068	Size 90,07 Pixel Of oAponta // "Descrição Máquina"
  	@ 168,  10 Checkbox oFiltro[252] Var aField[16]  PROMPT STR0069	Size 90,07 Pixel Of oAponta // "Item"
  	@  18, 100 Checkbox oFiltro[253] Var aField[17]  PROMPT STR0070	Size 90,07 Pixel Of oAponta // "Descrição Item"
   	@  28, 100 Checkbox oFiltro[254] Var aField[18]  PROMPT STR0071	Size 90,07 Pixel Of oAponta // "Roteiro"
  	@  38, 100 Checkbox oFiltro[255] Var aField[19]  PROMPT STR0072	Size 90,07 Pixel Of oAponta // "Operação"
  	@  48, 100 Checkbox oFiltro[256] Var aField[20]  PROMPT STR0073	Size 90,07 Pixel Of oAponta // "Descrição Operação"
  	@  58, 100 Checkbox oFiltro[257] Var aField[21]  PROMPT STR0074	Size 90,07 Pixel Of oAponta // "Família" 	
  	@  68, 100 Checkbox oFiltro[258] Var aField[22]  PROMPT STR0075 Size 90,07 Pixel Of oAponta // "Descrição Família"
  	@  78, 100 Checkbox oFiltro[259] Var aField[23]  PROMPT STR0076	Size 90,07 Pixel Of oAponta // "Grupo de Estoque"
  	@  88, 100 Checkbox oFiltro[260] Var aField[24]  PROMPT STR0077	Size 90,07 Pixel Of oAponta // "Descrição Grupo de Estoque"
  	@  98, 100 Checkbox oFiltro[261] Var aField[25]  PROMPT STR0078	Size 90,07 Pixel Of oAponta // "Tipo de Ordem" 
  	@ 108, 100 Checkbox oFiltro[262] Var aField[26]  PROMPT STR0079	Size 90,07 Pixel Of oAponta // "Quantidade Reportada" 
  	@ 118, 100 Checkbox oFiltro[263] Var aField[27]  PROMPT STR0080 Size 90,07 Pixel Of oAponta // "Quantidade Aprovada"
  	@ 128, 100 Checkbox oFiltro[264] Var aField[28]  PROMPT STR0081 Size 90,07 Pixel Of oAponta // "Quantidade Retrabalho"
  	@ 138, 100 Checkbox oFiltro[265] Var aField[29]  PROMPT STR0082 Size 90,07 Pixel Of oAponta // "Quantidade Refugada"
  	@ 148, 100 Checkbox oFiltro[266] Var aField[30]  PROMPT STR0083	Size 90,07 Pixel Of oAponta // "Início Preparação"
  	@ 158, 100 Checkbox oFiltro[267] Var aField[31]  PROMPT STR0084	Size 90,07 Pixel Of oAponta // "Hora Início Preparação"
   	@ 168, 100 Checkbox oFiltro[268] Var aField[32]  PROMPT STR0085	Size 90,07 Pixel Of oAponta // "Fim Preparação" 
  	@  18, 190 Checkbox oFiltro[269] Var aField[33]  PROMPT STR0086	Size 90,07 Pixel Of oAponta // "Hora Fim Preparação"
  	@  28, 190 Checkbox oFiltro[270] Var aField[34]  PROMPT STR0087	Size 90,07 Pixel Of oAponta // "Início Reporte"
  	@  38, 190 Checkbox oFiltro[271] Var aField[35]  PROMPT STR0088	Size 90,07 Pixel Of oAponta // "Hora Início Reporte" 
  	@  48, 190 Checkbox oFiltro[272] Var aField[36]  PROMPT STR0089	Size 90,07 Pixel Of oAponta // "Fim Reporte" 
  	@  58, 190 Checkbox oFiltro[273] Var aField[37]  PROMPT STR0090	Size 90,07 Pixel Of oAponta // "Hora Fim Reporte"
  	@  68, 190 Checkbox oFiltro[274] Var aField[38]  PROMPT STR0028	Size 90,07 Pixel Of oAponta // "Tempo Padrão Preparação"
  	@  78, 190 Checkbox oFiltro[275] Var aField[39]  PROMPT STR0029	Size 90,07 Pixel Of oAponta // 'Tempo Operação Padrão'
  	@  88, 190 Checkbox oFiltro[276] Var aField[40]  PROMPT STR0129	Size 90,07 Pixel Of oAponta // "Tempo Preparação" 
  	@  98, 190 Checkbox oFiltro[277] Var aField[41]  PROMPT STR0091	Size 90,07 Pixel Of oAponta // "Tempo Operação"
  	@ 108, 190 Checkbox oFiltro[278] Var aField[42]  PROMPT STR0092	Size 90,07 Pixel Of oAponta // "Tempo MOD" 
  	@ 118, 190 Checkbox oFiltro[279] Var aField[43]  PROMPT STR0093	Size 90,07 Pixel Of oAponta // "Tempo Extra"
  	@ 128, 190 Checkbox oFiltro[280] Var aField[44]  PROMPT STR0094	Size 90,07 Pixel Of oAponta // "Tempo Parada"
  	@ 138, 190 Checkbox oFiltro[281] Var aField[45]  PROMPT STR0034	Size 90,07 Pixel Of oAponta // "% Qualidade" 
  	@ 148, 190 Checkbox oFiltro[282] Var aField[46]  PROMPT STR0035	Size 90,07 Pixel Of oAponta // "% Qualidade Real"
  	@ 158, 190 Checkbox oFiltro[283] Var aField[47]  PROMPT STR0036	Size 90,07 Pixel Of oAponta // "% Eficiência" 
  	@ 168, 190 Checkbox oFiltro[284] Var aField[48]  PROMPT STR0095	Size 90,07 Pixel Of oAponta // "Operador"
  	@  18, 280 Checkbox oFiltro[285] Var aField[49]  PROMPT STR0096	Size 90,07 Pixel Of oAponta // "Nome Operador"
	@  28, 280 Checkbox oFiltro[286] Var aField[50]  PROMPT STR0170	Size 90,07 Pixel Of oAponta // "Ferramenta"
  	@  38, 280 Checkbox oFiltro[287] Var aField[51]  PROMPT STR0250	Size 90,07 Pixel Of oAponta // "Descrição Ferramenta"
	@  48, 280 Checkbox oFiltro[288] Var aField[52]  PROMPT STR0097	Size 90,07 Pixel Of oAponta // "Equipe Produção"
  	@  58, 280 Checkbox oFiltro[289] Var aField[53]  PROMPT STR0098	Size 90,07 Pixel Of oAponta // "Descrição Equipe" 
  	@  68, 280 Checkbox oFiltro[290] Var aField[54]  PROMPT STR0099	Size 90,07 Pixel Of oAponta // "Modelo Turno"
  	@  78, 280 Checkbox oFiltro[291] Var aField[55]  PROMPT STR0100	Size 90,07 Pixel Of oAponta // "Descrição Modelo Turno"
  	@  88, 280 Checkbox oFiltro[292] Var aField[56]  PROMPT STR0101	Size 90,07 Pixel Of oAponta // "Turno Produção"
  	@  98, 280 Checkbox oFiltro[293] Var aField[57]  PROMPT STR0166	Size 90,07 Pixel Of oAponta // "Linha de Produção"
	@ 108, 280 Checkbox oFiltro[294] Var aField[58]  PROMPT STR0167	Size 90,07 Pixel Of oAponta // "Planejador"
  	@ 118, 280 Checkbox oFiltro[295] Var aField[59]  PROMPT STR0169	Size 90,07 Pixel Of oAponta // "Depósito"
  	@ 128, 280 Checkbox oFiltro[296] Var aField[60]  PROMPT STR0103	Size 90,07 Pixel Of oAponta // "Liberado CQ"
  	@ 138, 280 Checkbox oFiltro[297] Var aField[61]  PROMPT STR0104	Size 90,07 Pixel Of oAponta // "Operação Final"
  	@ 148, 280 Checkbox oFiltro[298] Var aField[62]  PROMPT STR0105	Size 90,07 Pixel Of oAponta // "Início Contador"
  	@ 158, 280 Checkbox oFiltro[299] Var aField[63]  PROMPT STR0106	Size 90,07 Pixel Of oAponta // "Fim Contador"  	
  	@ 168, 280 Checkbox oFiltro[300] Var aField[64]  PROMPT STR0251	Size 90,07 Pixel Of oAponta // "% Avanço"
	@ 178,  10 Checkbox oFiltro[383] Var aField[65]  PROMPT STR0252	Size 90,07 Pixel Of oAponta // "Reportado"
	@ 178, 100 Checkbox oFiltro[384] Var aField[66]  PROMPT STR0253	Size 90,07 Pixel Of oAponta // "Tipo GGF" 
	@ 178, 190 Checkbox oFiltro[385] Var aField[67]  PROMPT STR0254	Size 90,07 Pixel Of oAponta // "Tipo MOB" 
	@ 178, 280 Checkbox oFiltro[386] Var aField[68]  PROMPT STR0255	Size 90,07 Pixel Of oAponta // "Tipo Refugo" 
	@ 188,  10 Checkbox oFiltro[387] Var aField[69]  PROMPT STR0256	Size 90,07 Pixel Of oAponta // "Tipo Apontamento" 
	@ 188, 100 Checkbox oFiltro[388] Var aField[70]  PROMPT STR0257	Size 90,07 Pixel Of oAponta // "Seq Origem"  
Return Nil
//-------------------------------------------------------------------
Static Function TelaIndica(oFiltro)
	oScroll := TScrollArea():New(oTFolder:aDialogs[6],01,01,100,100)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
  
	oIndica			:= TPanel():New( 0, 0, , oTFolder:aDialogs[6], , , , , CLR_WHITE, 350, 235, .F., .F. )
	oIndica:Align	:= CONTROL_ALIGN_TOP
	
	oScroll:SetFrame( oIndica )
	
  	@  10,  10 Say STR0219	        Of oIndica COLOR CLR_BLACK Pixel                				// 'Indicadores'
  	@  18,  10 Checkbox oFiltro[301] Var aField[1]   PROMPT STR0054	Size 90,07 Pixel Of oIndica // "Estabelecimento"
  	@  28,  10 Checkbox oFiltro[302] Var aField[2]   PROMPT STR0055	Size 90,07 Pixel Of oIndica // "Nome Estabelecimento" 
  	@  38,  10 Checkbox oFiltro[303] Var aField[3]   PROMPT STR0057	Size 90,07 Pixel Of oIndica // "Unid. Negócio"
  	@  48,  10 Checkbox oFiltro[304] Var aField[4]   PROMPT STR0061	Size 90,07 Pixel Of oIndica // "Motivo"
  	@  58,  10 Checkbox oFiltro[305] Var aField[5]   PROMPT STR0062	Size 90,07 Pixel Of oIndica // "Descrição Motivo" 
  	@  68,  10 Checkbox oFiltro[306] Var aField[6]   PROMPT STR0063	Size 90,07 Pixel Of oIndica // "Área de Produção"
  	@  78,  10 Checkbox oFiltro[307] Var aField[7]   PROMPT STR0064 Size 90,07 Pixel Of oIndica // "Descrição Área de Produção"
  	@  88,  10 Checkbox oFiltro[308] Var aField[8]   PROMPT STR0065 Size 90,07 Pixel Of oIndica // "Centro de Trabalho" 
  	@  98,  10 Checkbox oFiltro[309] Var aField[9]   PROMPT STR0066	Size 90,07 Pixel Of oIndica // "Descrição Centro Trabalho"
  	@ 108,  10 Checkbox oFiltro[310] Var aField[10]  PROMPT STR0067	Size 90,07 Pixel Of oIndica // "Máquina"
  	@ 118,  10 Checkbox oFiltro[311] Var aField[11]  PROMPT STR0068	Size 90,07 Pixel Of oIndica // "Descrição Máquina"
  	@ 128,  10 Checkbox oFiltro[312] Var aField[12]  PROMPT STR0095	Size 90,07 Pixel Of oIndica // "Operador"
  	@ 138,  10 Checkbox oFiltro[313] Var aField[13]  PROMPT STR0096	Size 90,07 Pixel Of oIndica // "Nome Operador"
  	@ 148,  10 Checkbox oFiltro[314] Var aField[14]  PROMPT STR0097 Size 90,07 Pixel Of oIndica // "Equipe"
   	@ 158,  10 Checkbox oFiltro[315] Var aField[15]  PROMPT STR0098	Size 90,07 Pixel Of oIndica // "Descrição Equipe"
  	@ 168,  10 Checkbox oFiltro[316] Var aField[16]  PROMPT STR0056	Size 90,07 Pixel Of oIndica // "Ordem Produção"
  	@ 178,  10 Checkbox oFiltro[317] Var aField[17]  PROMPT STR0058 Size 90,07 Pixel Of oIndica // "Número Operação"
  	@ 188,  10 Checkbox oFiltro[318] Var aField[18]  PROMPT STR0059	Size 90,07 Pixel Of oIndica // "Split"
  	@ 198,  10 Checkbox oFiltro[319] Var aField[19]  PROMPT STR0060	Size 90,07 Pixel Of oIndica // "Sequência Reporte" 
   	@  18, 100 Checkbox oFiltro[320] Var aField[20]  PROMPT STR0069	Size 90,07 Pixel Of oIndica // "Item"
   	@  28, 100 Checkbox oFiltro[321] Var aField[21]  PROMPT STR0070	Size 90,07 Pixel Of oIndica // "Descrição Item"
  	@  38, 100 Checkbox oFiltro[322] Var aField[22]  PROMPT STR0130	Size 90,07 Pixel Of oIndica // "Refêrencia"
  	@  48, 100 Checkbox oFiltro[323] Var aField[23]  PROMPT STR0071	Size 90,07 Pixel Of oIndica // "Roteiro"
  	@  58, 100 Checkbox oFiltro[324] Var aField[24]  PROMPT STR0072 Size 90,07 Pixel Of oIndica // "Operação"
  	@  68, 100 Checkbox oFiltro[325] Var aField[25]  PROMPT STR0073	Size 90,07 Pixel Of oIndica // "Descrição Operação" 		
  	@  78, 100 Checkbox oFiltro[326] Var aField[26]  PROMPT STR0074	Size 90,07 Pixel Of oIndica // "Família"
  	@  88, 100 Checkbox oFiltro[327] Var aField[27]  PROMPT STR0075	Size 90,07 Pixel Of oIndica // "Descrição Família"
  	@  98, 100 Checkbox oFiltro[328] Var aField[28]  PROMPT STR0076	Size 90,07 Pixel Of oIndica // "Grupo de Estoque"
  	@ 108, 100 Checkbox oFiltro[329] Var aField[29]  PROMPT STR0077	Size 90,07 Pixel Of oIndica // "Descrição Grupo de Estoque"
  	@ 118, 100 Checkbox oFiltro[330] Var aField[30]  PROMPT STR0131	Size 90,07 Pixel Of oIndica // "Tipo Registro"
  	@ 128, 100 Checkbox oFiltro[331] Var aField[31]  PROMPT STR0132 Size 90,07 Pixel Of oIndica // "Tipo Ordem"
  	@ 138, 100 Checkbox oFiltro[332] Var aField[32]  PROMPT STR0083	Size 90,07 Pixel Of oIndica // "Data Início Preparação"
  	@ 148, 100 Checkbox oFiltro[333] Var aField[33]  PROMPT STR0084	Size 90,07 Pixel Of oIndica // "Hora Início Preparação"
  	@ 158, 100 Checkbox oFiltro[334] Var aField[34]  PROMPT STR0085	Size 90,07 Pixel Of oIndica // "Data Fim Preparação"
  	@ 168, 100 Checkbox oFiltro[335] Var aField[35]  PROMPT STR0086	Size 90,07 Pixel Of oIndica // "Hora Fim Preparação"		
  	@ 178, 100 Checkbox oFiltro[336] Var aField[36]  PROMPT STR0133	Size 90,07 Pixel Of oIndica // "Data Início"	 	
  	@ 188, 100 Checkbox oFiltro[337] Var aField[37]  PROMPT STR0134	Size 90,07 Pixel Of oIndica // "Hora Início"
  	@ 198, 100 Checkbox oFiltro[338] Var aField[38]  PROMPT STR0135	Size 90,07 Pixel Of oIndica // "Data Término"
  	@  18, 190 Checkbox oFiltro[339] Var aField[39]  PROMPT STR0136	Size 90,07 Pixel Of oIndica // "Hora Fim"
  	@  28, 190 Checkbox oFiltro[340] Var aField[40]  PROMPT STR0137	Size 90,07 Pixel Of oIndica // "Unidade Capacidade"
  	@  38, 190 Checkbox oFiltro[341] Var aField[41]  PROMPT STR0138	Size 90,07 Pixel Of oIndica // "Disponibilidade Horas"
  	@  48, 190 Checkbox oFiltro[342] Var aField[42]  PROMPT STR0139	Size 90,07 Pixel Of oIndica // "Disponibilidade Capacidade"		
  	@  58, 190 Checkbox oFiltro[343] Var aField[43]  PROMPT STR0140	Size 90,07 Pixel Of oIndica // "Capacidade Máquina"		
  	@  68, 190 Checkbox oFiltro[344] Var aField[44]  PROMPT STR0079	Size 90,07 Pixel Of oIndica // "Quantidade Reportada"
  	@  78, 190 Checkbox oFiltro[345] Var aField[45]  PROMPT STR0080 Size 90,07 Pixel Of oIndica // "Quantidade Aprovada"
  	@  88, 190 Checkbox oFiltro[346] Var aField[46]  PROMPT STR0081	Size 90,07 Pixel Of oIndica // "Quantidade Refugada"
  	@  98, 190 Checkbox oFiltro[347] Var aField[47]  PROMPT STR0082	Size 90,07 Pixel Of oIndica // "Quantidade Retrabalho"
  	@ 108, 190 Checkbox oFiltro[348] Var aField[48]  PROMPT STR0034	Size 90,07 Pixel Of oIndica // "% Qualidade"
  	@ 118, 190 Checkbox oFiltro[349] Var aField[49]  PROMPT STR0035	Size 90,07 Pixel Of oIndica // "% Qualidade Real"
  	@ 128, 190 Checkbox oFiltro[350] Var aField[50]  PROMPT STR0129	Size 90,07 Pixel Of oIndica // "Tempo Preparação"
  	@ 138, 190 Checkbox oFiltro[351] Var aField[51]  PROMPT STR0091	Size 90,07 Pixel Of oIndica // "Tempo Operação"
  	@ 148, 190 Checkbox oFiltro[352] Var aField[52]  PROMPT STR0093	Size 90,07 Pixel Of oIndica // "Tempo Extra"
  	@ 158, 190 Checkbox oFiltro[353] Var aField[53]  PROMPT STR0094	Size 90,07 Pixel Of oIndica // "Tempo Parada"
  	@ 168, 190 Checkbox oFiltro[354] Var aField[54]  PROMPT STR0028	Size 90,07 Pixel Of oIndica // "Tempo Padrão Preparação"
  	@ 178, 190 Checkbox oFiltro[355] Var aField[55]  PROMPT STR0029 Size 90,07 Pixel Of oIndica // 'Tempo Operação Padrão'
  	@ 188, 190 Checkbox oFiltro[356] Var aField[56]  PROMPT STR0036	Size 90,07 Pixel Of oIndica // "% Eficiência"
  	@ 198, 190 Checkbox oFiltro[357] Var aField[57]  PROMPT STR0141 Size 90,07 Pixel Of oIndica // "Capacidade Operação"
  	@  18, 280 Checkbox oFiltro[358] Var aField[58]  PROMPT STR0142	Size 90,07 Pixel Of oIndica // "Número Unidades Operação"
  	@  28, 280 Checkbox oFiltro[359] Var aField[59]  PROMPT STR0143	Size 90,07 Pixel Of oIndica // "Quantidade Processada"		
  	@  38, 280 Checkbox oFiltro[360] Var aField[60]  PROMPT STR0107	Size 90,07 Pixel Of oIndica // "Tipo Parada"		
  	@  48, 280 Checkbox oFiltro[361] Var aField[61]  PROMPT STR0108	Size 90,07 Pixel Of oIndica // "Parada"
  	@  58, 280 Checkbox oFiltro[362] Var aField[62]  PROMPT STR0109	Size 90,07 Pixel Of oIndica // "Descrição Parada"
  	@  68, 280 Checkbox oFiltro[363] Var aField[63]  PROMPT STR0144	Size 90,07 Pixel Of oIndica // "Altera Eficiência"
  	@  78, 280 Checkbox oFiltro[364] Var aField[64]  PROMPT STR0121	Size 90,07 Pixel Of oIndica // "Parada Programada" 
  	@  88, 280 Checkbox oFiltro[365] Var aField[65]  PROMPT STR0145	Size 90,07 Pixel Of oIndica // "Qtd Parada Programada"
  	@  98, 280 Checkbox oFiltro[366] Var aField[66]  PROMPT STR0146	Size 90,07 Pixel Of oIndica // "Qtd Parada Programada Útil"
  	@ 108, 280 Checkbox oFiltro[367] Var aField[67]  PROMPT STR0147	Size 90,07 Pixel Of oIndica // "Qtd Parada Real"
  	@ 118, 280 Checkbox oFiltro[368] Var aField[68]  PROMPT STR0148	Size 90,07 Pixel Of oIndica // "Qtd Parada Real Útil"
  	@ 128, 280 Checkbox oFiltro[369] Var aField[69]  PROMPT STR0149	Size 90,07 Pixel Of oIndica // "Qtd Parada Altera Efic"
  	@ 138, 280 Checkbox oFiltro[370] Var aField[70]  PROMPT STR0150	Size 90,07 Pixel Of oIndica // "Qtd Parada Não Altera Efic"
  	@ 148, 280 Checkbox oFiltro[371] Var aField[71]  PROMPT STR0099	Size 90,07 Pixel Of oIndica // "Modelo Turno"
  	@ 158, 280 Checkbox oFiltro[372] Var aField[72]  PROMPT STR0100	Size 90,07 Pixel Of oIndica // "Descrição Modelo Turno"
  	@ 168, 280 Checkbox oFiltro[373] Var aField[73]  PROMPT STR0101	Size 90,07 Pixel Of oIndica // "Turno Produção"
  	@ 178, 280 Checkbox oFiltro[374] Var aField[74]  PROMPT STR0105	Size 90,07 Pixel Of oIndica // "Descrição Modelo Turno"
  	@ 188, 280 Checkbox oFiltro[375] Var aField[75]  PROMPT STR0106	Size 90,07 Pixel Of oIndica // "Turno Produção"     
  	@ 198, 280 Checkbox oFiltro[376] Var aField[76]  PROMPT STR0251	Size 90,07 Pixel Of oIndica // "% Avanço"
	@ 208,  10 Checkbox oFiltro[389] Var aField[77]  PROMPT STR0252	Size 90,07 Pixel Of oIndica // "Reportado"
	@ 208, 100 Checkbox oFiltro[390] Var aField[78]  PROMPT STR0253	Size 90,07 Pixel Of oIndica // "Tipo GGF" 
	@ 208, 190 Checkbox oFiltro[391] Var aField[79]  PROMPT STR0254	Size 90,07 Pixel Of oIndica // "Tipo MOB" 
	@ 208, 280 Checkbox oFiltro[392] Var aField[80]  PROMPT STR0255	Size 90,07 Pixel Of oIndica // "Tipo Refugo" 
	@ 218,  10 Checkbox oFiltro[393] Var aField[81]  PROMPT STR0256	Size 90,07 Pixel Of oIndica // "Tipo Apontamento" 
	@ 218, 100 Checkbox oFiltro[394] Var aField[82]  PROMPT STR0257	Size 90,07 Pixel Of oIndica // "Seq Origem" 
 
    
Return NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCC580VAL
Preenche os valores padrões e habilita/desabilita campos de cada funcionalidade

@param 	aFiltro		Array contendo os valores do filtro
@param		oFiltro		Array com os objetos dos campos do filtro
@param 	nFolder		Número da folder posicionada
@param		oBrowseLe		Objeto com as dimensões disponíveis
@param		oBrowseRi		Objeto com as dimensões selecionadas

@author 	Ana Carolina Tomé Klock
@since	 	24/10/2012
@version 	1.0
/*/
//-------------------------------------------------------------------                                         
Static Function SFCC580VAL( aFiltro, oFiltro, nFolder, oBrowseLe, oBrowseRi, lRefiltro )
Local nI, nJ
Local cFunction := aFiltro[1][1][2]
Local nSFC      := SFCIntegra() 

// Habilita todos os campos
If !__lAutomacao
	For nI := 1 to len( oFiltro )
		oFiltro[nI]:Enable()
	Next
EndIf
	
// Caso mude a Funcionalidade
If cFunction != aFiltro[1][1][3]
	For nI := 1 to len( aField )
		aField[nI] := .F.
	Next

    SFC580MARK( .F., 6, aFiltro, oFiltro )
    // Limpa dimensões		    
	If (cFunction == '1')		
		if nSFC == 2
			aFieldsDisp := { {STR0224, ""}, {STR0225, ""}, {STR0226, ""}, {STR0227, ""}, {STR0228, ""}, {STR0229, ""}, {STR0230, ""},;  
						     {STR0231, ""}, {STR0232, ""}, {STR0233, ""}, {STR0236, ""}, {STR0237, ""},;
						     {STR0238, ""}, {STR0239, ""}, {STR0240, ""}, {STR0241, ""}, {STR0242, ""} }
						     // "02 Área de Produção" ## "05 Linha de Produção" ## "06 Planejador" ## "07 Equipe de Produção" ## "08 Operador" ## "09 Item" ## "10 Referência" 
						     // "11 Operação" ## "12 Família de Produto" ## "13 Grupo de Estoque" ## "16 Ferramenta" ## "17 Turno"
						     // "18 Período (Mensal)" ## "19 Período (Semana do Mês)" ## "21 Motivo de Refugo/Retrabalho" ## "22 Depósito" ## "24 Tipo de Ordem"
		Else
			aFieldsDisp := { {STR0224, ""}, {STR0227, ""}, {STR0228, ""}, {STR0229, ""}, {STR0230, ""},;  
						     {STR0231, ""}, {STR0232, ""}, {STR0233, ""}, {STR0236, ""}, {STR0237, ""},;
						     {STR0238, ""}, {STR0239, ""}, {STR0240, ""}, {STR0241, ""}, {STR0242, ""} }
						     // "02 Área de Produção" ## "05 Linha de Produção" ## "06 Planejador" ## "07 Equipe de Produção" ## "08 Operador" ## "09 Item" ## "10 Referência" 
						     // "11 Operação" ## "12 Família de Produto" ## "13 Grupo de Estoque" ## "16 Ferramenta" ## "17 Turno"
						     // "18 Período (Mensal)" ## "19 Período (Semana do Mês)" ## "21 Motivo de Refugo/Retrabalho" ## "22 Depósito" ## "24 Tipo de Ordem"
		Endif
		
		aFieldsSel  := { {STR0243, "CDES"}, {STR0244, "CDCETR"}, {STR0245, "CDMQ"} } // '01 Estabelecimento' ## '03 Centro de Trabalho' ## '04 Máquina' 
	ElseIf (cFunction == '2')
		aFieldsDisp := { {STR0224, ""}, {STR0227, ""}, {STR0228, ""}, {STR0237, ""},;
						 {STR0238, ""}, {STR0239, ""}, {STR0246, ""} }
						 // "02 Área de Produção" ## "07 Equipe de Produção" ## "08 Operador" ## "17 Turno"
						 // "18 Período (Mensal)" ## "19 Período (Semana do Mês)" ## "20 Motivo de Parada"
	   	aFieldsSel  := { {STR0243, "CDES"}, {STR0244, "CDCETR"}, {STR0245, "CDMQ"} } // '01 Estabelecimento' ## '03 Centro de Trabalho' ## '04 Máquina'
	 ElseIf (cFunction == '3')
	 	if nSFC == 2
	 		aFieldsDisp := { {STR0224, ""}, {STR0225, ""}, {STR0226, ""}, {STR0227, ""}, {STR0228, ""}, {STR0229, ""},;  
							 {STR0231, ""}, {STR0232, ""}, {STR0233, ""}, {STR0236, ""}, {STR0237, ""},;
							 {STR0238, ""}, {STR0239, ""}, {STR0241, ""}, {STR0242, ""} }
							 // "02 Área de Produção" ## "05 Linha de Produção" ## "06 Planejador" ## "07 Equipe de Produção" ## "08 Operador" ## "09 Item"  
							 // "11 Operação" ## "12 Família de Produto" ## "13 Grupo de Estoque" ## "16 Ferramenta" ## "17 Turno"
						     // "18 Período (Mensal)" ## "19 Período (Semana do Mês)" ## "22 Depósito" ## "24 Tipo de Ordem"
		Else
			aFieldsDisp := { {STR0224, ""}, {STR0227, ""}, {STR0228, ""}, {STR0229, ""},;  
							 {STR0231, ""}, {STR0232, ""}, {STR0233, ""}, {STR0236, ""}, {STR0237, ""},;
							 {STR0238, ""}, {STR0239, ""}, {STR0241, ""}, {STR0242, ""} }
							 // "02 Área de Produção" ## "07 Equipe de Produção" ## "08 Operador" ## "09 Item"  
							 // "11 Operação" ## "12 Família de Produto" ## "13 Grupo de Estoque" ## "16 Ferramenta" ## "17 Turno"
						     // "18 Período (Mensal)" ## "19 Período (Semana do Mês)" ## "22 Depósito" ## "24 Tipo de Ordem"
		Endif

		aFieldsSel  := { {STR0243, "CDES"}, {STR0244, "CDCETR"}, {STR0245, "CDMQ"} } // '01 Estabelecimento' ## '03 Centro de Trabalho' ## '04 Máquina'
	 ElseIf (cFunction == '4')
      	aFieldsDisp := { {STR0224, ""}, {STR0227, ""}, {STR0228, ""}, {STR0237, ""},;
						 {STR0238, ""}, {STR0239, ""}, {STR0247, ""} }
						 // "02 Área de Produção" ## "07 Equipe de Produção" ## "08 Operador" ## "17 Turno"
						 // "18 Período (Mensal)" ## "19 Período (Semana do Mês)" ## "25 Unidade Capacidade"
		aFieldsSel  := { {STR0243, "CDES"}, {STR0244, "CDCETR"}, {STR0245, "CDMQ"} } // '01 Estabelecimento' ## '03 Centro de Trabalho' ## '04 Máquina'
	EndIf
	
	If !__lAutomacao
		oBrowseLe:SetArray( aFieldsDisp )
		oBrowseLe:bLine := {||{ If(Len(aFieldsDisp) > 0,  aFieldsDisp[oBrowseLe:nAt][1], ) } }
		oBrowseRi:SetArray(aFieldsSel)
		oBrowseRi:bLine := {||{ If(Len(aFieldsSel) > 0,aFieldsSel[oBrowseRi:nAt][1], ) } }
		oBrowseLe:Refresh()
		oBrowseRi:Refresh() 
	EndIf
    aFiltro[1][1][3] := cFunction        
EndIf

// Funcionalidade: Refugo
If ( cFunction == "1" )
	if nSFC == 1
		oFiltro[12]:Disable()					// Seleção: Linha Produção Inicial 
		oFiltro[13]:Disable()					// Seleção: Linha Produção Final
		oFiltro[14]:Disable()					// Seleção: Planejador Inicial 
		oFiltro[15]:Disable()					// Seleção: Planejador Final
		
		oFiltro[188]:Disable()					// Campos: Linha de Produção
		oFiltro[189]:Disable()					// Campos: Planejador
	Endif
	
	If !__lAutomacao
		oFiltro[48]:Disable()					// Seleção: Motivo Parada Inicial   
		oFiltro[49]:Disable()					// Seleção: Motivo Parada Final
		For nI := 55 to 64						// Parâmetros: Tipo Parada, Motivo Parada e Considera Indicador
			oFiltro[nI]:Disable()				  
		Next
		For nI := 94 to 137			 			// Métricas: Parada, Apontamento e Indicador
			oFiltro[nI]:Disable()				  
		Next
	EndIf

	if !lRefiltro
		aField[3]  := .T.
		aField[4]  := .T.  
		aField[6]  := .T.
		aField[12] := .T.
		aField[16] := .T.
		aField[26] := .T.
		aField[27] := .T.
		aField[28] := .T.
		aField[29] := .T.
		aField[34] := .T.
		aField[35] := .T.
		aField[36] := .T.
		aField[37] := .T.
	Endif

// Funcionalidade: Parada  	
ElseIf ( cFunction == "2" )
	If !__lAutomacao
		For nI := 12 to 15					// Seleção: Linha de Produção e Planejador
			oFiltro[nI]:Disable()
		Next
		For nI := 22 to 37					// Seleção: Grupo Est, Famil, Item, Refer, Armaz, Ferr, Emiten, Nr. Pedido 
			oFiltro[nI]:Disable()
		Next
		For nI := 42 to 47					// Seleção: Data Ordem, Data IMC, Data FMT
			oFiltro[nI]:Disable()
		Next
		For nI := 50 to 51					// Seleção: Motivo Refugo
			oFiltro[nI]:Disable()
		Next
		For nI := 52 to 54					// Parâmetros: Tipo Reporte			
			oFiltro[nI]:Disable()
		Next
		For nI := 61 to 82					// Parâmetros: Considera Indic, Situação Ordem, Quant Apont e Tipo Ordem		
			oFiltro[nI]:Disable()
		Next
		For nI := 83 to 93					// Métricas: Refugo		
			oFiltro[nI]:Disable()
		Next
		For nI := 103 to 137					// Métricas: Apontamento e Indicador
			oFiltro[nI]:Disable()
		Next
	EndIf
	
	if !lRefiltro
		aField[1]  := .T.
		aField[6]  := .T.  
		aField[13] := .T.
		aField[15] := .T.
		aField[16] := .T.
		aField[17] := .T.
		aField[18] := .T.
		aField[26] := .T.
		aField[27] := .T.
		aField[31] := .T.
		aField[32] := .T.
		aField[33] := .T.
		aField[34] := .T.
	Endif

// Funcionalidade: Apontamento
ElseIf ( cFunction == "3" )
	if nSFC == 1
		oFiltro[12]:Disable()					// Seleção: Linha Produção Inicial 
		oFiltro[13]:Disable()					// Seleção: Linha Produção Final
		oFiltro[14]:Disable()					// Seleção: Planejador Inicial 
		oFiltro[15]:Disable()					// Seleção: Planejador Final
		oFiltro[292]:Disable()					// Campos: Linha de Produção
		oFiltro[293]:Disable()					// Campos: Planejador
	Endif
	
	If !__lAutomacao
		oFiltro[48]:Disable()					// Seleção: Motivo Parada Inicial   
		oFiltro[49]:Disable()					// Seleção: Motivo Parada Final
		For nI := 55 to 60						// Parâmetros: Tipo Parada, Motivo Parada
			oFiltro[nI]:Disable()				  
		Next
		oFiltro[73]:Disable()					// Parâmetros: Quantifica Apontamento
		For nI := 83 to 102						// Métricas: Refugo e Parada		
			oFiltro[nI]:Disable()
		Next
		For nI := 113 to 137						// Métricas: Indicador
			oFiltro[nI]:Disable()
		Next
	EndIf
	
	if !lRefiltro
		aField[3]  := .T.
		aField[4]  := .T.  
		aField[6]  := .T.
		aField[10] := .T.
		aField[14] := .T.
		aField[24] := .T.
		aField[25] := .T.
		aField[26] := .T.
		aField[27] := .T.
		aField[32] := .T.
		aField[33] := .T.
		aField[34] := .T.
		aField[35] := .T.
	Endif
  	
// Funcionalidade: Indicadores
Else
	If !__lAutomacao
		For nI := 10 to 15						// Seleção: Nr Ordem, Linha de Prod e Planejador
			oFiltro[nI]:Disable()
		Next
		For nI := 20 to 37						// Seleção: Un Neg, Gp Est, Fam, Item, Refer, Armaz, Ferr, Emit, Nr. Ped 
			oFiltro[nI]:Disable()
		Next
		For nI := 42 to 51						// Seleção: Data Ordem, Data IMC, Data FMT, Mot Parada e Mot Refugo
			oFiltro[nI]:Disable()
		Next
		oFiltro[73]:Disable()					// Parâmetros: Quantifica Apontamento
		For nI := 83 to 112						// Métricas: Refugo, Parada e Apontamento
			oFiltro[nI]:Disable()
		Next
	EndIf
	
	if !lRefiltro
		aField[1]   := .T.
		aField[8]   := .T.
		aField[24]  := .T.  
		aField[30]  := .T.
		aField[36]  := .T.
		aField[37]  := .T.
		aField[38]  := .T.
		aField[39]  := .T.
		aField[40]  := .T.
		aField[45]  := .T.
		aField[46]  := .T. 
		aField[47]  := .T.
		aField[51]  := .T.  
		aField[52]  := .T.
		aField[53]  := .T.
		aField[55]  := .T.
		aField[57]  := .T.
		aField[58]  := .T.
		aField[59]  := .T.
		aField[61]  := .T.
		aField[62]  := .T.
		aField[63]  := .T.
		aField[64]  := .T.
		aField[65]  := .T.
		aField[66]  := .T.
		aField[67]  := .T.
		aField[68]  := .T.
		aField[69]  := .T.
		aField[70]  := .T.
	Endif
EndIf

SFCC580HAB( aFiltro[1][1][2] )
 
Return Nil   

//-------------------------------------------------------------------
/*/{Protheus.doc} SFC580MARK
Marca ou Desmarca os campos conforme a folder atual   
         
@param 	lDefine	Define se será marcado ou desmarcado
@param		nFolder	Número da folder posicionada
@param 	aFiltro	Array contendo os valores do filtro
@param		oFiltro	Array com os objetos dos campos do filtro	

@author 	Ana Carolina Tomé Klock
@since 	18/04/2011
@version 	1.0
/*/
//-------------------------------------------------------------------
Static Function SFC580MARK( lDefine, nFolder, aFiltro, oFiltro )
Local nI, nJ  

// Folder: Parâmetros	
If nFolder == 2
	For nI := 1 to len( aFiltro[3] )
		For nJ := 1 to len( aFiltro[3][nI][2] )
			If nI == 6 
				Loop
			Else
				aFiltro[3][nI][2][nJ][2] := lDefine
			EndIf
		Next
	Next 

// Folder: Métricas 1
ElseIf nFolder == 3    
	For nI := 1 to len( aFiltro[4] )-1
		For nJ := 1 to len( aFiltro[4][nI][2] )
			If nI == 3 .And. nJ == 3
				Loop
			Else
				aFiltro[4][nI][2][nJ][2] := lDefine
			EndIf
		Next
	Next

// Folder: Métricas 2
ElseIf nFolder == 4
	For nI := 1 to len( aFiltro[4][len(aFiltro[4])][2] )
		aFiltro[4][len(aFiltro[4])][2][nI][2] := lDefine
	Next  

// Folder: Campos	
ElseIf nFolder == 6 
	If aFiltro[1][1][2] == '1' .And. lDefine .And. !aField[54]
		alert('Ao selecionar "Nome Usuário Reporte", o carregamento dos dados será mais lento')
	ElseIf aFiltro[1][1][2] == '2' .And. lDefine .And. !aField[23]
		alert('Ao selecionar "Nome Usuário Reporte", o carregamento dos dados será mais lento')
	EndIf
	For nI := 1 to len( aField )
		aField[nI] := lDefine
	Next nI      
	
	if SFCIntegra() == 1
		IF aFiltro[1][1][2] == '1'
			aField[51] := .F.
			aField[52] := .F.
		ElseIf aFiltro[1][1][2] == '3'
			aField[57] := .F.
			aField[58] := .F.
		Endif
	Endif
EndIf                                                             

IF !__lAutomacao
	// Atualiza os objetos
	For nI := 52 to len( oFiltro )
		If nI != 73 .And. nI != 105
			oFiltro[nI]:CtrlRefresh()
		EndIf
	Next
ENDIF
 
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCC580HAB
Habilita o painel conforme funcionalidade

@return 	cFunction		Funcionalidade do Combobox 

@author 	Ana Carolina Tome Klock
@since 	24/10/2012
@version 	1.0
/*/
//-------------------------------------------------------------------
Static Function SFCC580HAB( cFunction )

If !__lAutomacao
	oRefugo:Hide()
	oParada:Hide()
	oAponta:Hide()
	oIndica:Hide()

	If cFunction == '1'
		oRefugo:Show()
	ElseIf cFunction == '2'
		oParada:Show()	
	ElseIf cFunction == '3'
		oAponta:Show()
	Else
		oIndica:Show()
	EndIf

EndIf

Return Nil
 
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCC580VAR
Carrega a variavel com os dados padrões do filtro 

@return 	aFiltro		Retorna a variável com todos os campos do filtro  

@author 	Ana Carolina Tome Klock
@since 	22/10/2012
@version 	1.0
/*/
//-------------------------------------------------------------------
Static Function SFCC580VAR()
Local aFiltro := {}

// Seleção
aAdd(  aFiltro, {	{ STR0159, '1', '0', {STR0160, STR0161, STR0162, STR0163 } } } ) // Funcionalidade - '1=Refug/Retrab' ### '2=Parada' ### '3=Apontamento' ### '4=Indicador'  
aAdd(  aFiltro, { 	{ STR0054, PadR( "" , TamSx3('CYA_CDES')[1] )  , PadR( "", TamSx3('CYA_CDES')[1] , "Z" ) } , ;   // Estabelecimento
					{ STR0063, PadR( "" , TamSx3('CYA_CDARPO')[1] ), PadR( "", TamSx3('CYA_CDARPO')[1] , "Z" ) } , ; // Área de Produção
					{ STR0065, PadR( "" , TamSx3('CYI_CDCETR')[1] ), PadR( "", TamSx3('CYI_CDCETR')[1] , "Z" ) } , ; // Centro de Trabalho
					{ STR0067, PadR( "" , TamSx3('CYB_CDMQ')[1] )  , PadR( "", TamSx3('CYB_CDMQ')[1] , "Z" ) } , ; 	 // Máquina
					{ STR0165, PadR( "" , TamSx3('CYQ_NRORPO')[1] ), PadR( "", TamSx3('CYQ_NRORPO')[1] , "Z" ) } , ; // Número da Ordem
					{ STR0166, PadR( "" , TamSx3('CYQ_CDLIPO')[1] ), PadR( "", TamSx3('CYQ_CDLIPO')[1] , "9" ) } , ; // Linha de Produção  
					{ STR0167, PadR( "" , TamSx3('CYQ_CDUSPL')[1] ), PadR( "", TamSx3('CYQ_CDUSPL')[1] , "Z" ) } , ; // Planejador
					{ STR0168, PadR( "" , TamSx3('CYH_CDRC')[1] )  , PadR( "", TamSx3('CYH_CDRC')[1] , "Z" ) } , ; 	 // Equipe
					{ STR0095, PadR( "" , TamSx3('CYH_CDRC')[1] )  , PadR( "", TamSx3('CYH_CDRC')[1] , "Z" ) } , ; 	 // Operador
					{ STR0057, PadR( "" , TamSx3('CYQ_CDUNNG')[1] ), PadR( "", TamSx3('CYQ_CDUNNG')[1] , "Z" ) } , ; // Unidade de Negócio
					{ STR0076, PadR( "" , TamSx3('CZ3_CDGR')[1] )  , PadR( "", TamSx3('CZ3_CDGR')[1] , "Z" ) } , ; 	 // Grupo de Estoque
					{ STR0074, PadR( "" , TamSx3('CZ3_CDFA')[1] )  , PadR( "", TamSx3('CZ3_CDFA')[1] , "Z" ) } , ; 	 // Família
					{ STR0069, PadR( "" , TamSx3('CZ3_CDAC')[1] )  , PadR( "", TamSx3('CZ3_CDAC')[1] , "Z" ) } , ; 	 // Item
					{ STR0130, PadR( "" , TamSx3('CYQ_CDRE')[1] )  , PadR( "", TamSx3('CYQ_CDRE')[1] , "Z" ) } , ; 	 // Referência
					{ STR0169, PadR( "" , TamSx3('CYQ_CDDP')[1] )  , PadR( "", TamSx3('CYQ_CDDP')[1] , "Z" ) } , ; 	 // Depósito
					{ STR0170, PadR( "" , TamSx3('CYH_CDRC')[1] )  , PadR( "", TamSx3('CYH_CDRC')[1] , "Z" ) } , ; 	 // Ferramenta
					{ STR0171, PadR( "" , TamSx3('CYQ_NMSIFB')[1] ), PadR( "", TamSx3('CYQ_NMSIFB')[1] , "Z" ) } , ; // Emitente
					{ STR0172, PadR( "" , TamSx3('CYQ_CDPD')[1] )  , PadR( "", TamSx3('CYQ_CDPD')[1] , "Z" ) } , ; 	 // Número do Pedido
					{ STR0173, PadR( "" , TamSx3('CYR_NRTN')[1] )  , PadR( "", TamSx3('CYR_NRTN')[1] , "9" ) } , ; 	 // Número do Turno
					{ STR0174, ( Date()-30 )	 , Date() 				 } , ; 	// Data do Apontamento
					{ STR0175, CtoD("01/01/1001"), CtoD("30/12/9999") } , ; 	// Data da Ordem
					{ STR0176, CtoD("01/01/1001"), CtoD("30/12/9999") } , ; 	// Data Início Mais Cedo
					{ STR0177, CtoD("01/01/1001"), CtoD("30/12/9999") } , ; 	// Data Fim Mais Tarde 
					{ STR0178, PadR( "", TamSx3('CYN_CDSP')[1] )	 , PadR( "", TamSx3('CYN_CDSP')[1] , "Z" ) } , ; // Motivo Parada
					{ STR0179, PadR( "", TamSx3('CYO_CDRF')[1] )	 , PadR( "", TamSx3('CYO_CDRF')[1] , "Z" ) } } ) // Motivo Refugo/Retrabalho
					
// Parâmetros	
aAdd(  aFiltro,   {	{ STR0180, ; 														// Tipo do Reporte
					 		{	{ STR0181, .T. } , ;										// Ordem
								{ STR0072, .T. } , ;                             	// Operação
								{ STR0182, .T. } } } , ;									// Ponto Controle
			 			{ STR0107, ;														// Tipo da Parada
							{	{ STR0183, .T. } , ;										// Programada
								{ STR0184, .T. } } } , ;									// Não Programada
			 			{ STR0178, ;														// Motivo Parada
							{ 	{ STR0185, .T. } , ;										// Altera Eficiência
								{ STR0186, .T. } , ; 									// Emite Solicitação de Serviço
								{ STR0187, .T. } , ;										// Envia e-mail ao planejador
								{ STR0188, .T. } } } , ;									// É Preparação
						{ STR0189, ;					   	                            // Considera no Indicador
							{ 	{ STR0190, .F. } , ;										// Parada que altera eficiência
								{ STR0191, .F. } , ;		 		 						// Fator refugo
								{ STR0192, .F. } , ;										// Tempo Extra como Disponível
								{ STR0193, .F. } } } , ;									// Considera Preparação nos Indicadores de Eficiência
						{ STR0194, ;		        										// Situação Ordem
							{	{ STR0195, .T. } , ;			 			 				// Não Iniciada
								{ STR0196, .T. } , ; 									// Iniciada
								{ STR0197, .T. } , ;	 									// Terminada
								{ STR0198, .T. } , ; 									// Finalizada
								{ STR0199, .T. } , ;										// Alocada
								{ STR0200, .T. } , ; 									// Separada
								{ STR0201, .T. } , ;										// Liberada
								{ STR0202, .T. } } } , ;	 								// Requisitada
						{ STR0203, ;	                          						// Quantifica Apontamento
							{ 	'1', { STR0204, STR0205, STR0206, STR0207 } } }, ; 
						{ STR0132, ;                          							// Tipo de Ordem
							{	{ STR0208, .T. } , ; 									// Interna
								{ STR0209, .T. } , ; 									// Externa
								{ STR0210, .T. } , ; 									// Interna/Externa
								{ STR0211, .T. } , ; 									// Retrabalho
								{ STR0212, .F. } , ; 									// Conserto
								{ STR0213, .F. } , ; 									// Manutenção
								{ STR0214, .T. } , ; 									// Ativo Fixo
								{ STR0215, .T. } , ; 									// Ferramentaria
								{ STR0216, .F. } } } } ) 								// Reaproveitamento
						 								
// Métricas
aAdd( aFiltro, 	{  { STR0217, ;														// Refugo e Retrabalho 		
							{	{ STR0007, .T. } , ; 									// Produção Real 
								{ STR0008, .F. } , ; 									// Refugo Previsto
								{ STR0009, .F. } , ; 									// % Refugo Previsto
								{ STR0010, .T. } , ; 									// Refugo Real
								{ STR0011, .T. } , ; 									// % Refugo Real
								{ STR0012, .F. } , ; 									// % Variação Refugo
								{ STR0013, .F. } , ; 									// Retrabalho Previsto
								{ STR0014, .F. } , ; 									// % Retrabalho Previsto
								{ STR0015, .T. } , ; 									// Retrabalho Real
								{ STR0016, .T. } , ; 									// % Retrabalho Real
								{ STR0017, .F. } } } , ; 								// % Variação Retrabalho
					 	{ STR0108, ;  													// Parada
							{	{ STR0018, .T. } , ; 									// Número Paradas 
								{ STR0019, .T. } , ; 									// Número Paradas Programadas
								{ STR0020, .T. } , ; 									// Número Paradas Progr. Efetivas
								{ STR0021, .T. } , ; 									// Número Paradas Não Programadas
								{ STR0022, .T. } , ; 									// Horas Planejadas
								{ STR0023, .T. } , ; 									// Horas Não Planejadas
								{ STR0024, .T. } , ; 									// Tempo Total Parada
								{ STR0025, .F. } , ; 									// % Programado
								{ STR0026, .F. } } } , ;									// % Não Programado
						{ STR0218, ;  													// Apontamento Produção
							{	{ STR0027, .T. } , ; 									// Número Apontamentos
								{ STR0028, .T. } , ; 									// Tempo Preparação Padrão
								{ '1', { STR0220, STR0221 } } , ; 						// 1=Por Operação, 2=Por Split
								{ STR0029, .T. } , ; 									// Tempo Operação Padrão
								{ STR0030, .T. } , ; 									// Tempo Preparação Real
								{ STR0031, .T. } , ; 									// Tempo Operação Real
								{ STR0032, .T. } , ; 									// Horas Normais
								{ STR0033, .T. } , ; 									// Horas Extras
								{ STR0034, .T. } , ; 									// % Qualidade
								{ STR0035, .T. } , ; 									// % Qualidade Real
								{ STR0036, .T. } } } , ; 								// % Eficiência
						{ STR0219, ;  													// Indicador
							{	{ STR0037, .T. } , ; 									// Capacidade do Projeto
								{ STR0038, .F. } , ; 									// Capacidade Efetiva
								{ STR0039, .T. } , ; 									// Capacidade Real
								{ STR0040, .F. } , ; 									// Disponibilidade Planejada
								{ STR0041, .T. } , ; 									// Disponibilidade Real
								{ STR0042, .T. } , ; 									// % Utilização
								{ STR0034, .T. } , ; 									// % Qualidade
								{ STR0035, .T. } , ; 									// % Qualidade Real
								{ STR0036, .T. } , ; 									// % Eficiência
								{ STR0028, .F. } , ; 									// Tempo Preparação Padrão
								{ STR0029, .F. } , ; 									// Tempo Operação Padrão
								{ STR0030, .F. } , ; 									// Tempo Preparação Real
								{ STR0031, .F. } , ; 									// Tempo Operação Real
								{ STR0032, .F. } , ; 									// Horas Normais
								{ STR0033, .F. } , ; 									// Horas Extras
								{ STR0043, .F. } , ; 									// Horas Sem Apontamento
								{ STR0044, .F. } , ; 									// Horas Paradas
								{ STR0045, .F. } , ; 									// Paradas Programadas
								{ STR0248, .F. } , ; 									// Paradas Não Programadas
								{ STR0046, .F. } , ; 									// Down Time
								{ STR0047, .T. } , ; 									// % Eficiência Liquida (NEE)
								{ STR0048, .T. } , ; 									// % Eficiência Geral (OEE)
								{ STR0049, .T. } , ; 									// % Produtividade (TEEP)
								{ STR0050, .T. } } } }  )								// Takt Time (Quant/Min)
						
Return aFiltro
