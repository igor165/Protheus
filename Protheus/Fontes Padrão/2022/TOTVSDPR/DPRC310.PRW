#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'DPRC310.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} DPRC310
Tela de Comparativo Produto

@author Ana Carolina Tomé Klock
@since 25/07/2012
@version P12
/*/
//-----------------------------------------------------------------
Function DPRC310()
	Local lFicha		:= .F.
	Local oDlg, oPanelLeft, oPanelRight
	Local oTreeLeft, oTreeRight, nI
	Local aCoords		:= FWGetDialogSize( oMainWnd )
	Local aButtons		:= {{ STR0001 , { || If (!CallFiltro(), DPR310TREE( MV_PAR01, MV_PAR02, @oTreeLeft, MV_PAR03, MV_PAR04, @oTreeRight, If (MV_PAR05==1, .T., .F.) ) , { || } ) }, STR0001, STR0001 },; // 'Filtro'
							{ STR0002 , { || DPRDetalhe( oTreeLeft:GetCargo() ) }, STR0002, STR0002 },;     // 'Detalhar'
							{ STR0003 , { || DPRCustos( oTreeLeft:GetCargo() ) } , STR0003, STR0003 } }     // 'Custos'
	Local aTabs		:= { 	'aDG0', 'aDG1', 'aDG2', 'aDG3', 'aDG9', 'aDGN', ;
								'cDG0', 'cDG1',	'cDG2', 'cDG3', 'cDG9', 'cDGN' }
	Private cDG0, cDG1, cDG2, cDG3, cDG9, cDGN
	Private aDG0, aDG1, aDG2, aDG3, aDG9, aDGN
	Private aCampos     := {}
	Default lAutoMacao := .F.
	
	If FindFunction("DPRFicha")
		lFicha := DPRFicha(1)
	EndIf
	
	If lFicha
		aadd(aButtons, { STR0021 , { || DPRC310FIC( oTreeLeft:GetCargo() ) }, STR0021, STR0021 } ) // Comparar Ficha Técnica
	Endif
	
	// Se o filtro for executado
	
	If !CallFiltro()
		IF !lAutoMacao
			// Cria a tela para exibição dos dados
			Define MsDialog oDlg Title STR0004  FROM aCoords[1], aCoords[2] To aCoords[3]-2, aCoords[4]-2 Pixel  // 'Comparação de Produtos'
		
			// Cria uma layer em toda a tela
			oFWLayer := FWLayer():New()
			oFWLayer:Init( oDlg, .F., .T. )
		
			// Separa a tela ao meio
			oFWLayer:AddLine( 'ALL', 97, .F. )
			oFWLayer:AddCollumn( 'LEFT' , 50, .T., 'ALL' )
			oFWLayer:AddCollumn( 'RIGHT', 50, .T., 'ALL' )
			oPanelLeft  := oFWLayer:GetColPanel( 'LEFT'  , 'ALL' )
			oPanelRight := oFWLayer:GetColPanel( 'RIGHT' , 'ALL' )
		
			// Cria a tree lateral esquerda
			oTreeLeft  := DbTree():New( 0, 0, 0, 0, oPanelLeft , , , .T. )
			oTreeLeft:Align  := CONTROL_ALIGN_ALLCLIENT
		
			// Cria a tree lateral direita
			oTreeRight := DbTree():New( 0, 0, 0, 0, oPanelRight, , , .T. )
			oTreeRight:Align := CONTROL_ALIGN_ALLCLIENT
		
			// Ajusta as trees para serem sicronizadas
			DPR310TREE( MV_PAR01, MV_PAR02, @oTreeLeft, MV_PAR03, MV_PAR04, @oTreeRight, If (MV_PAR05==1, .T., .F.) )
			oTreeLeft:bChange  := { || oTreeRight:TreeSeek( oTreeLeft:GetCargo() ) }
			oTreeRight:bChange := { || oTreeLeft:TreeSeek( oTreeRight:GetCargo() ) }
		
			Activate Dialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },, aButtons )
		ENDIF
		// Fecha as tabelas
		aDG0[3]:Delete()
		aDG1[3]:Delete()
		aDG2[3]:Delete()
		aDG3[3]:Delete()
		aDG9[3]:Delete()
		aDGN[3]:Delete()
	
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CallFiltro
Chama o filtro para obter os produtos e versões do programa

@return		aRet		Retorna se
							[1] Produtos estão validos
							[2] Usuário desistiu de selecionar

@author 	Ana Carolina Tomé Klock
@since 		18/06/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CallFiltro()
Local lCancel := .F.

IF IsInCallStack('DPRA300')
	MV_PAR01 := DG0->DG0_CDACDV
	MV_PAR02 := DG0->DG0_NRVRAC
	MV_PAR03 := DG0->DG0_CDACDV
	MV_PAR04 := DG0->DG0_NRVRAC
	MV_PAR05 := 1
Else
	If Pergunte('DPRC310')	 	
		If	!(DG0->( dbSeek( xFilial('DG0')+MV_PAR01+MV_PAR02 )) .And. ;
			  DG0->( dbSeek( xFilial('DG0')+MV_PAR03+MV_PAR04 )) .And. ;
			  ( MV_PAR01 != MV_PAR03 .Or. MV_PAR02 != MV_PAR04 ))

 			DPRXError('DPRC310', 'DPRC310_INVAL', 3)
 			lCancel := .T.
 		EndIf
 	Else
 		lCancel := .T.
 	EndIf	
Endif

Return lCancel

//-------------------------------------------------------------------
/*/{Protheus.doc} DPR310TREE
Preenche as tabelas temporarias e atualiza árvores

@param 		cProduct1		Código do Produto Desenvolvido 1
@param		cVersion1		Número da Versão do Produto 1
@param		oTreeLeft		Objeto esquerdo onde a árvore será montada
@param 		cProduct2		Código do Produto Desenvolvido
@param		cVersion2		Número da Versão do Produto
@param		oTreeRight		Objeto direito onde a árvore será montada
@param		lDesce			Identifica se a árvore descerá níveis ou não

@author Ana Carolina Tomé Klock
@since 26/07/2012
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPR310TREE( cProduct1, cVersion1, oTreeLeft, cProduct2, cVersion2, oTreeRight, lDesce )
	Local lFicha	   := .F.
	Private nOrigem    := 1
	Default lDesce	   := .T.
	Default lAutoMacao := .F.
	
	If FindFunction("DPRFicha")
		lFicha := DPRFicha(1)
	EndIf
	
	IF !lAutoMacao
		// Inicia atualizacao
		oTreeLeft:BeginUpdate()
		oTreeRight:BeginUpdate()
		
		// Limpa árvores
		oTreeLeft:Reset()
		oTreeRight:Reset()
	ENDIF
	
	// Monta estrutura da arvore esquerda
	DPRASTRUCT( cProduct1, cVersion1, { .T., .T., .F., .F., lDesce, lFicha }, 1 ) 
	
	// Salva alias das tabelas da esquerda
	cDG0 := aDG0
	cDG1 := aDG1
	cDG2 := aDG2
	cDG3 := aDG3
	cDG9 := aDG9
	cDGN := aDGN
	
	// Monta estrutura da arvore direita
	DPRASTRUCT( cProduct2, cVersion2, { .T., .T., .F., .F., lDesce, lFicha }, 1 ) 
	
	// Define os pais das árvores
	(cDG0[1])->( dbGoTo( 1 ) )
	IF !lAutoMacao
		DPRAddItem( oTreeLeft, cDG0[1], 0 )
	ENDIF
	
	(aDG0[1])->( dbGoTo( 1 ) )
	IF !lAutoMacao
		DPRAddItem( oTreeRight, aDG0[1], 0 )
		
		// Ajusta arvores
		COMPARTREE( oTreeLeft, oTreeRight )
		
		// Finaliza atualizacao
		oTreeLeft:EndUpdate()
		oTreeRight:EndUpdate()
	ENDIF
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPARTREE
Compara as árvores da direita e da esquerda.

@Obs 		Necessário estarem criados os Alias das árvores

@author 	Ana Carolina Tomé Klock
@since 		26/07/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function COMPARTREE( oTreeLeft, oTreeRight )
Private nCount     := 1
Default lAutoMacao := .F.

// Limpa a numeração automática criada anteriormente (CARGO)
LimpaCargo( cDG1[1] )
LimpaCargo( aDG1[1] )
LimpaCargo( cDG9[1] )
LimpaCargo( aDG9[1] ) 
LimpaCargo( cDG2[1] )
LimpaCargo( aDG2[1] )                                   
LimpaCargo( cDGN[1] )
LimpaCargo( aDGN[1] )

IF !lAutoMacao
	// Monta a árvore relacionando os itens pelo CARGO
	AjustaTab( cDG0[1], cDG1[1], aDG1[1], cDG9[1], aDG9[1], cDGN[1], aDGN[1], cDG2[1], aDG2[1], oTreeLeft, oTreeRight )
	AjustaTab( aDG0[1], aDG1[1], cDG1[1], aDG9[1], cDG9[1], aDGN[1], cDGN[1], aDG2[1], cDG2[1], oTreeRight, oTreeLeft )
ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaTab
Adiciona os componentes na árvore

@param		cPai            (Obrigatório) Alias da tabela pai (DG0)
@param		cDG1Left      	(Obrigatório) Alias da tabela filho (DG1)
@param		cDG1Right		(Obrigatório) Alias da tabela comparada (DG1)
@param		cDG9Left      	(Obrigatório) Alias da tabela filho (DG9)
@param		cDG9Right		(Obrigatório) Alias da tabela comparada (DG9)
@param		cDG2Left      	(Obrigatório) Alias da tabela filho (DG2)
@param		cDG2Right		(Obrigatório) Alias da tabela comparada (DG2)
@param		oTreeLeft		(Obrigatório) Objeto dbTree original
@param 		oTreeRight		(Obrigatório) Objeto dbTree comparado

@author 	Ana Carolina Tomé Klock
@since 		20/03/2013
@version	P12
/*/
//-------------------------------------------------------------------
Static Function AjustaTab( cPai, cDG1Left, cDG1Right, cDG9Left, cDG9Right, cDGNLeft, cDGNRight, cDG2Left, cDG2Right, oTreeLeft, oTreeRight )
Local cNivel, nI := 1
Local lChange := .F.
Local cNivel2 := '2'+Space(3)
Local cImage

While ( nI <= (cPai)->(RecCount()) )
	// Pula linha e incrementa nível
	(cPai)->( dbGoTo(nI++) )
	cNivel := cValToChar(Val((cPai)->NIVEL)+1)
	cNivel += Space( len( (cPai)->NIVEL ) - len(cNivel))
	oTreeLeft:TreeSeek(  AjustaCargo( cPai, cDG1Left ) )
	oTreeRight:TreeSeek( AjustaCargo( cPai, cDG1Left ) )

	// Procura operacoes
	If (cDG9Left)->( dbSeek( cNivel+(cPai)->DG0_CDACDV+(cPai)->DG0_NRVRAC ) )
		While (cDG9Left)->( !EOF() )
			If 	(cDG9Left)->NIVEL       == cNivel 			  .And.;
				(cDG9Left)->DG9_CDACDV  == (cPai)->DG0_CDACDV .And.;
				(cDG9Left)->DG9_NRVRAC  == (cPai)->DG0_NRVRAC

				// Verifica se já foi adicionado na árvore
				If Val( (cDG9Left)->CARGO ) == 0

					// Procura equivalentes na outra árvore
					If 	(cDG9Right)->( dbSeek( cNivel+(cPai)->DG0_CDACDV+(cPai)->DG0_NRVRAC ) ) .Or. ;
						(cDG9Right)->( dbSeek( cNivel+(cPai)->DG0_CDACDV ) ) 					.Or. ;
						((cDG9Right)->( dbSeek( cNivel )) .And. cNivel == cNivel2)						
						lChange := .F.
						While (cDG9Right)->( !EOF() )
							If 	(cDG9Right)->NIVEL       == cNivel 			   							 .And.;
								( (cDG9Right)->DG9_CDACDV  == (cPai)->DG0_CDACDV .Or. cNivel == cNivel2) .And.;
								(cDG9Right)->DG9_CDAT    == (cDG9Left)->DG9_CDAT								
								cImage := ComparaItem( cDG9Left, cDG9Right, aDG9[2], 9, 3 )
								DPRAddItem( oTreeRight, cDG9Right, nCount, , cImage )
								lChange := .T.
								Exit	    		   	  			
							EndIf
							(cDG9Right)->( dbSkip() )
						End
						
						If !lChange
							cImage := 'PMSTASK6'
							DPRAddItem( oTreeRight, cDG9Right, nCount, (cDG9Left)->PROMP, 'BR_CANCEL', .T. )
						EndIf
					Else
						cImage := 'PMSTASK6'
						DPRAddItem( oTreeRight, cDG9Right, nCount, (cDG9Left)->PROMP, 'BR_CANCEL', .T. )
					EndIf
					DPRAddItem( oTreeLeft, cDG9Left, nCount++, , cImage )
	    			
					// Alternativos do Roteiro
					cNivelDG2 := cValToChar(Val((cPai)->NIVEL)+2)
					cNivelDG2 += Space( len( (cPai)->NIVEL ) - len(cNivelDG2))
	    			
					oTreeLeft:TreeSeek(  (cDG9Left)->CARGO )
					oTreeRight:TreeSeek( (cDG9Left)->CARGO )
	    			
					(cDG2Left)->(dbSetOrder(2))
					If (cDG2Left)->( dbSeek( cNivelDG2+(cDG9Left)->DG9_CDACDV+(cDG9Left)->DG9_NRVRAC+(cDG9Left)->DG9_IDAT ) )
						While (cDG2Left)->( !EOF() )
							If 	(cDG2Left)->NIVEL      == cNivelDG2 			  .And.;
								(cDG2Left)->DG2_CDACDV == (cDG9Left)->DG9_CDACDV .And.;
								(cDG2Left)->DG2_NRVRAC == (cDG9Left)->DG9_NRVRAC .AND.;
								(cDG2Left)->DG2_IDAT   == (cDG9Left)->DG9_IDAT
				    			
								if Val( (cDG2Left)->CARGO ) == 0
				    							    			
									// Procura equivalentes na outra árvore
									(cDG2Right)->(dbSetOrder(2))
									If (cDG2Right)->( dbSeek( cNivelDG2+(cDG9Right)->DG9_CDACDV+(cDG9Right)->DG9_NRVRAC ) )
										lChangeDG2 := .F.
										
										While (cDG2Right)->( !EOF() )
											If 	(cDG2Right)->NIVEL      == cNivelDG2 .And.;
												(cDG2Right)->DG2_CDACDV == (cDG9Right)->DG9_CDACDV .And.;
												(cDG2Right)->DG2_NRVRAC == (cDG9Right)->DG9_NRVRAC .And.;
												(cDG2Right)->DG2_IDAT   == (cDG9Right)->DG9_IDAT .And.;
												(cDG2Right)->DG2_CDMQ   == (cDG2Left)->DG2_CDMQ .And.;
												(cDG2Right)->DG2_CDFE   == (cDG2Left)->DG2_CDFE
																																	   			
												cImage := ComparaItem( cDG2Left, cDG2Right, aDG2[2], 9, 3 )
												DPRAddItem( oTreeRight, cDG2Right, nCount, , cImage )
												lChangeDG2 := .T.	
												Exit    		   	  			
											EndIf
											(cDG2Right)->( dbSkip() )
										End
										
										If !lChangeDG2
											cImage := 'PMSTASK2'
											DPRAddItem( oTreeRight, cDG2Right, nCount, (cDG2Left)->PROMP, 'BR_CANCEL', .T. )
										EndIf
									Else
										cImage := 'PMSTASK2'
										DPRAddItem( oTreeRight, cDG2Right, nCount, (cDG2Left)->PROMP, 'BR_CANCEL', .T. )
									EndIf
									DPRAddItem( oTreeLeft, cDG2Left, nCount++, , cImage )
				    			
								Endif
				    			
							Endif
				    		
							(cDG2Left)->( dbSkip() )
						End
					Endif
	   	  			
					oTreeLeft:TreeSeek(  AjustaCargo( cPai, cDG1Left ) )
					oTreeRight:TreeSeek( AjustaCargo( cPai, cDG1Left ) )
				Else
					cNivelDG2 := cValToChar(Val((cPai)->NIVEL)+2)
					cNivelDG2 += Space( len( (cPai)->NIVEL ) - len(cNivelDG2))
	    			
					oTreeLeft:TreeSeek(  (cDG9Left)->CARGO )
					oTreeRight:TreeSeek( (cDG9Left)->CARGO )
	    			
					(cDG2Left)->(dbSetOrder(2))
					If (cDG2Left)->( dbSeek( cNivelDG2+(cDG9Left)->DG9_CDACDV+(cDG9Left)->DG9_NRVRAC+(cDG9Left)->DG9_IDAT ) )
						While (cDG2Left)->( !EOF() )
							If 	(cDG2Left)->NIVEL      == cNivelDG2 			  .And.;
								(cDG2Left)->DG2_CDACDV == (cDG9Left)->DG9_CDACDV .And.;
								(cDG2Left)->DG2_NRVRAC == (cDG9Left)->DG9_NRVRAC .AND.;
								(cDG2Left)->DG2_IDAT   == (cDG9Left)->DG9_IDAT
				    			
								if Val( (cDG2Left)->CARGO ) == 0
				    							    			
									// Procura equivalentes na outra árvore
									(cDG2Right)->(dbSetOrder(2))
									If (cDG2Right)->( dbSeek( cNivelDG2+(cDG9Right)->DG9_CDACDV+(cDG9Right)->DG9_NRVRAC ) )
										lChangeDG2 := .F.
										
										While (cDG2Right)->( !EOF() )
											If 	(cDG2Right)->NIVEL      == cNivelDG2 .And.;
												(cDG2Right)->DG2_CDACDV == (cDG9Right)->DG9_CDACDV .And.;
												(cDG2Right)->DG2_NRVRAC == (cDG9Right)->DG9_NRVRAC .And.;
												(cDG2Right)->DG2_IDAT   == (cDG9Right)->DG9_IDAT .And.;
												(cDG2Right)->DG2_CDMQ   == (cDG2Left)->DG2_CDMQ .And.;
												(cDG2Right)->DG2_CDFE   == (cDG2Left)->DG2_CDFE
																																	   			
												cImage := ComparaItem( cDG2Left, cDG2Right, aDG2[2], 9, 3 )
												DPRAddItem( oTreeRight, cDG2Right, nCount, , cImage )
												lChangeDG2 := .T.	
												Exit    		   	  			
											EndIf
											(cDG2Right)->( dbSkip() )
										End
										
										If !lChangeDG2
											cImage := 'PMSTASK2'
											DPRAddItem( oTreeRight, cDG2Right, nCount, (cDG2Left)->PROMP, 'BR_CANCEL', .T. )
										EndIf
									Else
										cImage := 'PMSTASK2'
										DPRAddItem( oTreeRight, cDG2Right, nCount, (cDG2Left)->PROMP, 'BR_CANCEL', .T. )
									EndIf
									DPRAddItem( oTreeLeft, cDG2Left, nCount++, , cImage )
				    			
								Endif
				    			
							Endif
				    		
							(cDG2Left)->( dbSkip() )
						End
					Endif
	   	  			
					oTreeLeft:TreeSeek(  AjustaCargo( cPai, cDG1Left ) )
					oTreeRight:TreeSeek( AjustaCargo( cPai, cDG1Left ) )
				EndIf
			EndIf
			(cDG9Left)->( dbSkip() )
		End
	EndIf

	// Procura componentes
	If (cDG1Left)->( dbSeek( cNivel+(cPai)->DG0_CDACDV+(cPai)->DG0_NRVRAC ) )
		While (cDG1Left)->( !EOF() )
			If 	(cDG1Left)->NIVEL       == cNivel 			.And.;
				(cDG1Left)->DG1_CDACDV  == (cPai)->DG0_CDACDV .And.;
				(cDG1Left)->DG1_NRVRAC  == (cPai)->DG0_NRVRAC

				// Verifica se já foi adicionado na árvore
				If Val( (cDG1Left)->CARGO ) == 0
					// Procura equivalentes na outra árvore
					If 	(cDG1Right)->( dbSeek( cNivel+(cPai)->DG0_CDACDV+(cPai)->DG0_NRVRAC ) ) .Or. ;
						(cDG1Right)->( dbSeek( cNivel+(cPai)->DG0_CDACDV ) ) 					.Or. ;
						((cDG1Right)->( dbSeek( cNivel )) .And. cNivel == cNivel2)
						
						lChange := .F.
						While (cDG1Right)->( !EOF() )
							If 	(cDG1Right)->NIVEL       == cNivel 				.And.;
								( (cDG1Right)->DG1_CDACDV  == (cPai)->DG0_CDACDV .Or. cNivel == cNivel2) .And.;
								(cDG1Right)->DG1_CDMT    == (cDG1Left)->DG1_CDMT	.And.;
								(cDG1Right)->DG1_CDMTDV  == (cDG1Left)->DG1_CDMTDV
								
								cImage := ComparaItem( cDG1Left, cDG1Right, aDG1[2], 9, 1)
								DPRAddItem( oTreeRight, cDG1Right, nCount, , cImage )
								lChange := .T.
							EndIf
							(cDG1Right)->( dbSkip() )
						End
						
						If !lChange
							cImage := 'PMSTASK6'
							DPRAddItem( oTreeRight, cDG1Right, nCount, (cDG1Left)->PROMP, 'BR_CANCEL', .T. )
						EndIf
					Else
						cImage := 'PMSTASK6'
						DPRAddItem( oTreeRight, cDG1Right, nCount, (cDG1Left)->PROMP, 'BR_CANCEL', .T. )
					EndIf
					DPRAddItem( oTreeLeft, cDG1Left, nCount++, , cImage )
				EndIf
			EndIf
			(cDG1Left)->( dbSkip() )
		End
	EndIf
		
	// Adiciona Ficha
	If (cDGNLeft)->( dbSeek( cNivel+(cPai)->DG0_CDACDV+(cPai)->DG0_NRVRAC ) )
		While (cDGNLeft)->( !EOF() )
			If 	(cDGNLeft)->NIVEL       == cNivel 			.And.;
				(cDGNLeft)->DGN_CDACDV  == (cPai)->DG0_CDACDV .And.;
				(cDGNLeft)->DGN_NRVRAC  == (cPai)->DG0_NRVRAC

				// Verifica se já foi adicionado na árvore
				If Val( (cDGNLeft)->CARGO ) == 0
					// Procura equivalentes na outra árvore
					If 	(cDGNRight)->( dbSeek( cNivel+(cPai)->DG0_CDACDV+(cPai)->DG0_NRVRAC ) ) .Or. ;
						(cDGNRight)->( dbSeek( cNivel+(cPai)->DG0_CDACDV ) ) 					.Or. ;
						((cDGNRight)->( dbSeek( cNivel )) .And. cNivel == cNivel2)
						
						lChange := .F.
						While (cDGNRight)->( !EOF() )
							If 	(cDGNRight)->NIVEL       == cNivel 				.And.;
								( (cDGNRight)->DGN_CDACDV  == (cPai)->DG0_CDACDV .Or. cNivel == cNivel2) .And.;
								(cDGNRight)->DGN_CDMQ  == (cDGNLeft)->DGN_CDMQ .AND.;
								(cDGNRight)->DGN_CDMD  == (cDGNLeft)->DGN_CDMD
								
								cImage := ComparaItem( cDGNLeft, cDGNRight, aDGN[2], 9, 1)
								DPRAddItem( oTreeRight, cDGNRight, nCount, , cImage )
								lChange := .T.
							EndIf
							(cDGNRight)->( dbSkip() )
						End
						
						If !lChange
							cImage := 'PMSTASK6'
							DPRAddItem( oTreeRight, cDGNRight, nCount, (cDGNLeft)->PROMP, 'BR_CANCEL', .T. )
						EndIf
					Else
						cImage := 'PMSTASK6'
						DPRAddItem( oTreeRight, cDGNRight, nCount, (cDGNLeft)->PROMP, 'BR_CANCEL', .T. )
					EndIf
					DPRAddItem( oTreeLeft, cDGNLeft, nCount++, , cImage )
				Endif
			Endif

			(cDGNLeft)->( dbSkip() )
		End
	EndIf
End

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRAddItem
Coloca um novo número de cargo para o item e adiciona na árvore

@param		oTree		(Obrigatório) Objeto dbTree
@param		cAlias		(Obrigatório) Alias do item sendo adicionado
@param 		nCargo		(Obrigatório) Número sequencial
@param 		cPrompt		Descrição do item na árvore (caso não exista)
@param		cImage		Imagem do item na árvore (caso não exista)
@param		lNew		Define se está incluindo um novo (não salva no Alias)

@author 	Ana Carolina Tomé Klock
@since 		19/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function DPRAddItem( oTree, cAlias, nCargo, cPrompt, cImage, lNew )
Local   cCargo  := DPRXCount(len((cAlias)->CARGO), nCargo)
Default cPrompt := (cAlias)->PROMP
Default cImage  := (cAlias)->IMAGE
Default lNew	:= .F.

If !lNew
	RecLock( cAlias, .F. )
	(cAlias)->CARGO := DPRXCount(len((cAlias)->CARGO), nCargo)
	MsUnlock()
EndIf

oTree:AddItem( cPrompt, cCargo, cImage, cImage, /*cFile1*/, /*cFile2*/, 2 )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaCargo
Define o cargo do item pai baseado no item filho

@param		cPai		(Obrigatório) Alias da tabela pai (DG0)
@param		cAlias		(Obrigatório) Alias da tabela filho (DG1)

@author 	Ana Carolina Tomé Klock
@since 		20/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function AjustaCargo( cPai, cAlias )
Local aArea  := (cPai)->( GetArea() )
Local cCargo := (cPai)->CARGO

If (cAlias)->( dbSeek( (cPai)->NIVEL ))
	While (cAlias)->( !EOF() )
		If (cAlias)->NIVEL 		== (cPai)->NIVEL 		.And. ;
			(cAlias)->DG1_CDMTDV 	== (cPai)->DG0_CDACDV 	.And. ;
			(cAlias)->DG1_NRVRMT	== (cPai)->DG0_NRVRAC
			
			RecLock( (cPai), .F. )
			(cPai)->CARGO := (cAlias)->CARGO
			MsUnlock()
			cCargo := (cPai)->CARGO
		EndIf
		(cAlias)->( dbSkip() )
	End
EndIf

RestArea(aArea)

Return cCargo

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaCargo
Limpa o campo CARGO de todos os itens da tabela temporária

@param		cAlias		(Obrigatório) Alias da tabela

@author 	Ana Carolina Tomé Klock
@since 		20/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function LimpaCargo( cAlias )
Local nI

For nI := 1 to (cAlias)->(RecCount())
	(cAlias)->(dbGoTo(nI))
	RecLock( cAlias, .F.)
	(cAlias)->CARGO := Replicate( '0', len( (cAlias)->CARGO ) )
	MsUnlock()
Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRDetalhe
Monta a tela de detalhe

@param		cAlias		(Obrigatório) Alias da tabela

@author 	Ana Carolina Tomé Klock
@since 		20/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function DPRDetalhe( cCargo )
Local oDlg

// Atualiza aCampos
aCampos := {}
if GetDetail( cCargo ) > 1

	DEFINE DIALOG oDlg TITLE STR0005 FROM 180,180 TO 530,700 PIXEL    // 'Detalhe'
	
	// Cria Browse
	oBrowse := TCBrowse():New( 01 , 01, 260, 156,,{STR0006, STR0007, STR0008},{80,80,80},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  // 'Campo' ### 'Base' ### 'Comparado'
	
	// Seta array para o browse
	oBrowse:SetArray(aCampos)
	
	// Monta a linha a ser exibida no Browse
	oBrowse:bLine := { || { aCampos[oBrowse:nAt,2], aCampos[oBrowse:nAt,3], aCampos[oBrowse:nAt,4] } }
	
	// Cria botões com métodos básicos do Browse
	TButton():New( 160,  45, STR0009, oDlg, { || Imprimir( oBrowse ) }		,50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'Imprimir'
	TButton():New( 160, 100, STR0010, oDlg, { || ExibeDif( @oBrowse, .F. ) },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'Exibir tudo'
	TButton():New( 160, 155, STR0011, oDlg, { || ExibeDif( @oBrowse, .T. ) },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'Exibir diferenças'
	TButton():New( 160, 210, STR0012, oDlg, {|| oDlg:End() }				,50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'OK'
	
	ACTIVATE DIALOG oDlg CENTERED
Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExibeDif
Atualiza o browse com os registros selecionados

@param		oBrowse		(Obrigatório) Objeto TCBrowse
@param		lDif		Define se irá exibir apenas diferenças

@author 	Ana Carolina Tomé Klock
@since 		20/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ExibeDif( oBrowse, lDif )
Local nI, aDif 	    := {}
Default lDif 	    := .F.
Default lAutoMacao 	:= .F.

// Preenche vetor aDif com o que será exibido no oBrowse
If lDif
	For nI := 1 to len(aCampos)
		If ValType(aCampos[nI][3]) != ValType(aCampos[nI][4])
			aAdd( aDif, aCampos[nI] )
		ElseIf aCampos[nI][3] != aCampos[nI][4] .Or. ;
			   aCampos[nI][1] == 'DG0_CDACDV' 	.Or. ;
			   aCampos[nI][1] == 'DG0_NRVRAC'	.Or. ;
			 ( aCampos[nI][1] == 'DG1_CDMT' 	.And. (!Empty(aCampos[nI][3]+aCampos[nI][4])) ) .Or. ;
			 ( aCampos[nI][1] == 'DG1_CDMTDV' 	.And. (!Empty(aCampos[nI][3]+aCampos[nI][4])) ) .Or. ;
			 ( aCampos[nI][1] == 'DG1_NRVRMT' 	.And. (!Empty(aCampos[nI][3]+aCampos[nI][4])) ) .Or. ;
			 ( aCampos[nI][1] == 'DG9_DSAT'	 	.And. (!Empty(aCampos[nI][3]+aCampos[nI][4])) ) .OR. ;
			 ( aCampos[nI][1] == 'DGN_CDACDV'	.And. (!Empty(aCampos[nI][3]+aCampos[nI][4])) )
			
			aAdd( aDif, aCampos[nI] )
		EndIf
	Next nI
Else
	aDif := aCampos
EndIf

IF !lAutoMacao
	// Atualiza o vetor do oBrowse
	oBrowse:SetArray(aDif)

	// Monta a linha a ser exibida no Browse
	oBrowse:bLine := { || { aDif[oBrowse:nAt,2], aDif[oBrowse:nAt,3], aDif[oBrowse:nAt,4] } }
ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRemove
Lista dos campos a serem removidos

@author 	Samantha Preima
@since 		24/06/2015
@version	P11
/*/
//-------------------------------------------------------------------
Static Function GetRemove()
Local aRemove      := {}
Default lAutoMacao := .F.

// Define campos que não serão exibidos
aAdd( aRemove, 'DG0_DSFOPJ'	)
aAdd( aRemove, 'DG0_DSFOCS'	)
aAdd( aRemove, 'DG0_DSFOUT'	)
aAdd( aRemove, 'DG0_IDNV'  	)
aAdd( aRemove, 'DG1_CDACDV'	)
aAdd( aRemove, 'DG1_NRVRAC'	)
aAdd( aRemove, 'DG1_LGMTDV'	)
aAdd( aRemove, 'DG1_IDNV'  	)
aAdd( aRemove, 'DG9_CDACDV'	)
aAdd( aRemove, 'DG9_NRVRAC'	)
aAdd( aRemove, 'DG9_IDNVTU'	)
aAdd( aRemove, 'DG9_IDNV'  	)
aAdd( aRemove, 'DG9_IDAT' 	)
If DPRIntegra() == 1 .Or. lAutoMacao
	aAdd( aRemove, 'DG0_CDES'	)
	aAdd( aRemove, 'DG0_CDRE'  	)
	aAdd( aRemove, 'DG0_CDTBMT'	)
	aAdd( aRemove, 'DG0_DTPRBA'	)
	aAdd( aRemove, 'DG0_DTPRFI'	)
	aAdd( aRemove, 'DG0_VLPNRF'	)
	aAdd( aRemove, 'DG0_VLPRBA'	)
	aAdd( aRemove, 'DG0_VLPRFI'	)
	aAdd( aRemove, 'DG1_LGAV'   )
	aAdd( aRemove, 'DG1_TPSB'   )
	aAdd( aRemove, 'DG1_NRSRBG' )
	aAdd( aRemove, 'DG1_NRSRED'	)
	aAdd( aRemove, 'DG1_CDRE'   )
	aAdd( aRemove, 'DG1_QTAC'   )
	aAdd( aRemove, 'DG9_LGAV'   )
	aAdd( aRemove, 'DG9_VLPN'   )
	aAdd( aRemove, 'DG9_DTBG'   )
	aAdd( aRemove, 'DG9_DTED'   )
	aAdd( aRemove, 'DG9_LGATBG' )
	aAdd( aRemove, 'DG9_LGATED' )
	aAdd( aRemove, 'DG9_LGATVF' )
	aAdd( aRemove, 'DG9_CDATVF' )
	aAdd( aRemove, 'DG9_CDMOD'  )
	aAdd( aRemove, 'DG9_CDRE'   )
	aAdd( aRemove, 'DG9_TPAT'   )
	aAdd( aRemove, 'DG9_QTTERC' )
	aAdd( aRemove, 'DG9_CDUNAT' )
	aAdd( aRemove, 'DG9_NRATSM' )
EndIf

Return aRemove

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDetail
Busca a tabela onde está o Cargo passado por parâmetro

@param		cCargo		(Obrigatório) Numero sequencial da árvore

@author 	Ana Carolina Tomé Klock
@since 		22/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function GetDetail( cCargo )
Local aRemove := GetRemove()
Local nI := 1

// Procura na DG0
If Val( cCargo ) == 1
	FindDetail( cDG0[1], cDG0[2], cCargo )
	FindDetail( aDG0[1], aDG0[2], cCargo, .F.)
EndIf

// Procura na DG1
If len(aCampos) == 0
	FindDetail( cDG1[1], cDG1[2], cCargo )
	FindDetail( aDG1[1], aDG1[2], cCargo, .F.)
EndIf

// Procura na DG9
If len(aCampos) == 0
	FindDetail( cDG9[1], cDG9[2], cCargo )
	FindDetail( aDG9[1], aDG9[2], cCargo, .F.)
EndIf

// Procura na DGN
If len(aCampos) == 0
	FindDetail( cDGN[1], cDGN[2], cCargo )
	FindDetail( aDGN[1], aDGN[2], cCargo, .F.)
EndIf

While nI <= len(aCampos)
	If aScan(aRemove, { |x| AllTrim(x) ==  AllTrim(aCampos[nI,1]) } )  > 0
		aDel( aCampos, nI )
		aSize( aCampos, len(aCampos)-1 )
		If nI > len(aCampos)
			nI++
		EndIf
	Else
		nI++
	EndIf
End

Return nI

//-------------------------------------------------------------------
/*/{Protheus.doc} FindDetail
Preenche o vetor que será usado pelo browse

@param		cAlias		(Obrigatório) Alias da tabela a ser varrida
@param		aStruct		(Obrigatório) Definição de campos do cAlias
@param		cCargo		(Obrigatório) Número sequencial da árvore
@param		lFirst		Indica se está pesquisando na esquerda

@author 	Ana Carolina Tomé Klock
@since 		22/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function FindDetail( cAlias, aStruct, cCargo, lFirst )
Local nI, nJ
Default lFirst := .T.

For nI := 1 to (cAlias)->(RecCount())
	(cAlias)->( dbGoTo(nI) )
	If (cAlias)->CARGO == cCargo
		For nJ := 1 to len( aStruct )
			dbSelectArea( 'SX3' )
			SX3->( dbSetOrder( 2 ) )
			If SX3->( dbSeek( aStruct[nJ][1] ) )
				If lFirst
					aAdd( aCampos, { aStruct[nJ][1], X3DESCRIC(), (cAlias)->&( aStruct[nJ][1] ), ' ', .F. } )
				ElseIf (nJ-6) > len(aCampos)
					aAdd( aCampos, { aStruct[nJ][1], X3DESCRIC(), ' ', (cAlias)->&( aStruct[nJ][1]), .F.  } )
				Else
					aCampos[nJ-6][4] := (cAlias)->&( aStruct[nJ][1] )
					If Upper(AllTrim(aCampos[nJ-6][4])) == Upper(AllTrim(aCampos[nJ-6][3]))
						aCampos[nJ-6][5] := .T.
					EndIf
				EndIf

				If !lFirst .And. !Empty(X3CBox())
					aCampos[nJ-6][3] := X3Combo( aStruct[nJ][1] , aCampos[nJ-6][3] )
					aCampos[nJ-6][4] := X3Combo( aStruct[nJ][1] , aCampos[nJ-6][4] )
				EndIf
			EndIf
		Next nJ
	EndIf
Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRCustos
Monta a tela de custos

@param		cAlias		(Obrigatório) Alias da tabela

@author 	Ana Carolina Tomé Klock
@since 		22/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function DPRCustos( cCargo )
Local oDlg

// Atualiza aCampos
aCampos := {}
FindCosts( cDG0[1], cCargo, .T. )
FindCosts( aDG0[1], cCargo, .F. )

If len(aCampos) > 0
	DEFINE DIALOG oDlg TITLE STR0003 FROM 180,180 TO 530,700 PIXEL    // 'Custos'

	// Cria Browse
	oBrowse := TCBrowse():New( 01 , 01, 260, 156,,{STR0006, STR0007, STR0008},{80,80,80},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) // 'Campo' ### 'Base' ### 'Comparado'

	// Seta array para o browse
	oBrowse:SetArray(aCampos)

	// Monta a linha a ser exibida no Browse
	oBrowse:bLine := { || { aCampos[oBrowse:nAt,2], aCampos[oBrowse:nAt,3], aCampos[oBrowse:nAt,4] } }

	// Cria botões com métodos básicos do Browse
	TButton():New( 160, 155, STR0009, oDlg, { || Imprimir( oBrowse ) } ,50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'Imprimir'
	TButton():New( 160, 210, STR0012, oDlg, { || oDlg:End() }          ,50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'OK'

	ACTIVATE DIALOG oDlg CENTERED
Else
	alert(STR0013) // 'Apenas versões possuem custos para serem analisados'
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FindAtri
Carrega dados dos atributos de ficha técnica

@param		cAlias		(Obrigatório) Alias da tabela a ser varrida
@param		cCargo		(Obrigatório) Número sequencial da árvore
@param		lFirst		Indica se está pesquisando na esquerda

@author 	Samantha Preima
@since 		06/12/2013
@version	P12
/*/
//-------------------------------------------------------------------
Static Function FindAtri( cAlias, cCargo, lFirst )
Local nI
Local cTpAtrib     := ''
Local cValor
Local nPos         := 0
Local lAchou       := .T.
Default lFirst     := .T.

For nI := 1 to (cAlias)->(RecCount())
	(cAlias)->( dbGoTo(nI) )
	If (cAlias)->CARGO == cCargo
		IF lFirst
			aAdd( aCampos, { 'DGN_CDACDV', STR0023, (cAlias)->DGN_CDACDV, ' ', .F. } ) // 'Produto Desenvolvido'
			aAdd( aCampos, { 'DGN_NRVRAC', STR0024, (cAlias)->DGN_NRVRAC, ' ', .F. } ) // 'Versão'
			aAdd( aCampos, { 'DGN_CDMQ'  , STR0025, (cAlias)->DGN_CDMQ  , ' ', .F. } ) // 'Recurso'
			aAdd( aCampos, { 'DGN_CDMD'  , STR0026, (cAlias)->DGN_CDMD  , ' ', .F. } ) // 'Template'
		Else
			if Empty(aCampos)
				aAdd( aCampos, { 'DGN_CDACDV', STR0023, ' ', (cAlias)->DGN_CDACDV, .F. } ) // 'Produto Desenvolvido'
				aAdd( aCampos, { 'DGN_NRVRAC', STR0024, ' ', (cAlias)->DGN_NRVRAC, .F. } ) // 'Versão'
				aAdd( aCampos, { 'DGN_CDMQ'  , STR0025, ' ', (cAlias)->DGN_CDMQ  , .F. } ) // 'Recurso'
				aAdd( aCampos, { 'DGN_CDMD'  , STR0026, ' ', (cAlias)->DGN_CDMD  , .F. } ) // 'Template'
			Else
				aCampos[1][4] := (cAlias)->DGN_CDACDV
				aCampos[2][4] := (cAlias)->DGN_NRVRAC
				aCampos[3][4] := (cAlias)->DGN_CDMQ
				aCampos[4][4] := (cAlias)->DGN_CDMD
			Endif
		Endif

		nPos := 4

		dbSelectArea('DGO')
		DGO->(dbSetOrder(1))
		DGO->(dbSeek(xFilial('DGO')+(cAlias)->DGN_CDACDV+(cAlias)->DGN_NRVRAC+(cAlias)->DGN_CDMQ+(cAlias)->DGN_CDMD))
		
		While DGO->(!EOF()) .AND. DGO->DGO_CDACDV == (cAlias)->DGN_CDACDV .AND. DGO->DGO_NRVRAC == (cAlias)->DGN_NRVRAC .AND.;
								DGO->DGO_CDMQ   == (cAlias)->DGN_CDMQ   .AND. DGO->DGO_CDMD   == (cAlias)->DGN_CDMD

			cTpAtrib := Posicione('CZB',1,xFilial('CZB')+DGO->DGO_CDAB,'CZB_TPAB')

			Do Case
				Case cTpAtrib == "F" // Flag
					cValor := DGO->DGO_VLFG
				Case cTpAtrib == "C" // Caracter
					cValor := DGO->DGO_VLCH
				Case cTpAtrib == "N" // Número
					cValor := DGO->DGO_VLNR
				Case cTpAtrib == "D" // Data
					cValor := DGO->DGO_VLDT
				Case cTpAtrib == "L" // Lista
					cValor := DGO->DGO_VLTB
				Case cTpAtrib == "A" // Faixa
					cValor := DGO->DGO_VLFX
				Case cTpAtrib == "M" // Memo
					cValor := DGO->DGO_VLNV
				Case cTpAtrib == "R" // Fórmula
					cValor := DGO->DGO_VLFO
				Case cTpAtrib == "T" // Tabela
					cValor := DGO->DGO_VLTBSI
				Case cTpAtrib == "I" // Imagem
					cValor := DGO->DGO_BITMAP
				Case cTpAtrib == "O" // Tolerância
					cValor := ALLTRIM(STR(DGO->DGO_VLNR)) + ';' + ALLTRIM(STR(DGO->DGO_VLAFMI)) + ';' + ALLTRIM(STR(DGO->DGO_VLAFMX))
			EndCase

			if lFirst
				aAdd( aCampos, { 'DGN_CDAB', DGO->DGO_CDAB + ' - ' + Posicione('CZB', 1, xFilial('CZB')+DGO->DGO_CDAB, 'CZB_NMAB'), cValor, ' ', .F. } )
			Else
				lAchou := .F.

				For nPos := 5 to Len(aCampos)
					if Substr(aCampos[nPos][2],1,10) == DGO->DGO_CDAB
						aCampos[nPos][4] := cValor
						lAchou := .T.

						Exit
					Endif
				Next

				IF !lAchou
					aAdd( aCampos, { 'DGN_CDAB', DGO->DGO_CDAB + ' - ' + Posicione('CZB', 1, xFilial('CZB')+DGO->DGO_CDAB, 'CZB_NMAB'), ' ', cValor, .F. } )
				Endif
			Endif

			DGO->(dbSkip())
		End
	EndIf
Next nI

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRC310FIC
Monta a tela de detalhe ficha técnica

@param		cAlias		(Obrigatório) Alias da tabela

@author 	Samantha Preima
@since 		21/11/2013
@version	P12
/*/
//-------------------------------------------------------------------
Static Function DPRC310FIC( cCargo )

aCampos := {}

FindAtri(cDGN[1], cCargo)
FindAtri(aDGN[1], cCargo, .F.)

if !Empty(aCampos)

	DEFINE DIALOG oDlg TITLE STR0022 FROM 180,180 TO 530,700 PIXEL // Ficha Técnica

	// Cria Browse
	oBrowse := TCBrowse():New( 01 , 01, 260, 156,,{STR0006, STR0007, STR0008},{80,80,80},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  // 'Campo' ### 'Base' ### 'Comparado'

	// Seta array para o browse
	oBrowse:SetArray(aCampos)

	// Monta a linha a ser exibida no Browse
	oBrowse:bLine := { || { aCampos[oBrowse:nAt,2], aCampos[oBrowse:nAt,3], aCampos[oBrowse:nAt,4] } }

	// Cria botões com métodos básicos do Browse
	TButton():New( 160,  45, STR0009, oDlg, { || Imprimir( oBrowse ) }		,50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'Imprimir'
	TButton():New( 160, 100, STR0010, oDlg, { || ExibeDif( @oBrowse, .F. ) },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'Exibir tudo'
	TButton():New( 160, 155, STR0011, oDlg, { || ExibeDif( @oBrowse, .T. ) },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'Exibir diferenças'
	TButton():New( 160, 210, STR0012, oDlg, {|| oDlg:End() }				,50,010,,,.F.,.T.,.F.,,.F.,,,.F. )	// 'OK'

	ACTIVATE DIALOG oDlg CENTERED
Endif

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FindCosts
Preenche o vetor que será usado pelo browse de custos

@param		cAlias		(Obrigatório) Alias da tabela DG0 a ser varrida
@param		cCargo		(Obrigatório) Número sequencial da árvore
@param		lFirst		Indica se está pesquisando na esquerda

@author 	Ana Carolina Tomé Klock
@since 		22/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function FindCosts( cAlias, cCargo, lFirst )
Local nI, nJ, nK
Local aStruct := { 'DG0_CDACDV','DG0_NRVRAC','DG0_VLCSPO', 'DG0_VLULEN', 'DG0_VLPRRO' }
Default lAutoMacao := .F.

// Exibe certos campos apenas para Datasul
If DPRIntegra() == 2
	aAdd( aStruct, 'DG0_VLPRBA' )
	aAdd( aStruct, 'DG0_VLPRFI' )
EndIf

IF !lAutoMacao
	// Busca pelo cargo
	For nI := 1 to (cAlias)->(RecCount())
		(cAlias)->( dbGoTo(nI) )
		If (cAlias)->CARGO == cCargo

			// Preenche dados DG0
			If lFirst .Or. len(aCampos) == 0
				dbSelectArea('SX3')
				SX3->( dbSetOrder(2) )
				For nJ := 1 to len(aStruct)
					If SX3->( dbSeek(aStruct[nJ]) )
						If lFirst
							aAdd( aCampos, { aStruct[nJ], X3DESCRIC(), (cAlias)->&( aStruct[nJ] ), '0', .T. } )
						Else
							aAdd( aCampos, { aStruct[nJ], X3DESCRIC(), '0', (cAlias)->&( aStruct[nJ] ), .T. } )
						EndIf
					EndIf
				Next nJ
			Else
				For nJ := 1 to len(aStruct)
					aCampos[nJ][4] := (cAlias)->&( aStruct[nJ] )
				Next nJ
			EndIf

			// Preenche dados DG5
			If lFirst .Or. len(aCampos) == 0
				nJ := 1
				While !Empty( cCargo :=  X3COMBO('DG5_TPVLCS', cValToChar(nJ) ))
					nK := 1
					While !Empty( X3COMBO('DG5_TPCS', cValToChar(nK) ) )
						aAdd( aCampos, { cValToChar(nK)+cValToChar(nJ), cCargo + ' (' +  X3COMBO('DG5_TPCS', cValToChar(nK++) ) + ')', '0', '0', .T. } )
					End
					nJ++
				End
			EndIf
			dbSelectArea('DG5')
			For nJ := len(aStruct)+1 to len(aCampos)
				If DG5->( dbSeek( xFilial('DG5')+(cAlias)->DG0_CDACDV+(cAlias)->DG0_NRVRAC+aCampos[nJ][1] ) )
					If Val(DG5->DG5_CDMY) == 1 // Apenas moeda 1
						If lFirst
							aCampos[nJ][3] := DG5->DG5_VLCS
						Else
							aCampos[nJ][4] := DG5->DG5_VLCS
						EndIf
					EndIf
				EndIf
			Next nJ
		EndIf
	Next
ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Imprimir
Gera um arquivo CSV do conteuco do Browse

@param		oBrowse		(Obrigatório) Objeto TCBrowse

@author 	Ana Carolina Tomé Klock
@since 		22/03/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function Imprimir( oBrowse )
Local aCabExcel   := {}
Local aCols       := {}
Local nI
Default lAutoMacao := .F.

aAdd(aCabExcel, {STR0006, "C", 100, 0}) // 'CAMPO'
aAdd(aCabExcel, {STR0007, "C", 100, 0}) // 'BASE'
aAdd(aCabExcel, {STR0008, "C", 100, 0}) // 'COMPARADO'
aAdd(aCabExcel, {''     , "N",  14, 4})

IF !lAutoMacao
	For nI := 1 to len(oBrowse:aArray)
		aAdd( aCols, { oBrowse:aArray[nI][2], oBrowse:aArray[nI][3], oBrowse:aArray[nI][4], 0 } )
	Next nI

	MsgRun(STR0014, STR0015,{||DlgToExcel({{"GETDADOS",STR0004,aCabExcel,aCols}})}) // 'Favor Aguardar...' ### 'Exportando os Registros para o Excel' ### 'Comparação de Produtos'
ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ComparaItem
Compara itens da árvore

@param		cAliasEsq	(Obrigatório) Alias da Tree Esquerda
@param 		cAliasDir	(Obrigatório) Alias da Tree Direita
@param		aStruct		Campos dos Alias
@param		nInicio		Quantos campos iniciais devem ser desconsiderados
@param 		nFim		Quantos campos finais devem ser desconsiderados

@return		cImage		Imagem que será exibida na Tree

@author 	Ana Carolina Tomé Klock
@since 		16/04/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ComparaItem( cAliasEsq, cAliasDir, aStruct, nInicio, nFim )
Local nI
Local aRemove   := GetRemove()
Default nInicio := 9
Default nFim    := 0

For nI := nInicio to len( aStruct ) //-nFim
	if aScan(aRemove, { |x| AllTrim(x) ==  AllTrim(aStruct[nI][1]) } ) == 0	
		If (cAliasEsq)->&(aStruct[nI][1]) != (cAliasDir)->&(aStruct[nI][1])
			Return 'PMSTASK1'
		EndIf
	EndIf
Next

Return 'PMSTASK6'
