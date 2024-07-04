#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'DPRXTREE.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} DPRASEARCH
Adiciona a uma TreeView o processo de fabricação do produto

@param		oTree			(Obrigatório) Elemento onde a estrutura está sendo montada
@param 		nNivel			Nivel da árvore que será aberto
@param 		aConfig			Vetor com os parâmetros de montagem
							[1] Buscar componentes
							[2] Buscar operações
							[3] Buscar componentes alternativos
							[4] Buscar operações alternativas
							[5] Descer níveis
							[6] Buscar Ficha
@param		cChave			Chave da estrutura sendo montada

@author 	Ana Carolina Tome Klock
@since 		31/01/2013
@version 	P12
/*/
//-----------------------------------------------------------------
Function DPRASEARCH( oTree, nNivel, aConfig, cChave, nIntegra )
Local nJ
Local aAreaDG0, aAreaDG1 
Local aAreaDG3   := DG3->(GetArea())
Local aAreaCZ3   := CZ3->(GetArea())
Local cNivel	 := DPRNvlTree( (aDG0[1])->NIVEL, 1 )
Local aTemplate  := {}
Local aTemplate2 := {}
Local cChaveDGN  := ''
Default aConfig	 := { .F., .F., .F., .F., .F., .F. }
Default cChave	 := ""

// Marca o registro como utilizado
RecLock( (aDG0[1]), .F. )
(aDG0[1])->EXIBE := .T.
MsUnlock()

// Procura pelas operações do produto caso marcado
If aConfig[2]

	dbSelectArea(aDG9[1])
	(aDG9[1])->(dbSetOrder(2))
	if (aDG9[1])->(dbSeek(Padr(cValToChar(nNivel+1),4)+Padr(cChave+(aDG0[1])->DG0_CDACDV+(aDG0[1])->DG0_NRVRAC,800)))
		While (aDG9[1])->(!EOF()) .AND. AllTrim((aDG9[1])->NIVEL) == cValToChar(nNivel+1) .AND.;
										AllTrim((aDG9[1])->CHAVE) == AllTrim( cChave + (aDG0[1])->DG0_CDACDV+(aDG0[1])->DG0_NRVRAC)
											
											
			// Define que o filho é exibido na árvore
			RecLock( (aDG9[1]), .F. )
			(aDG9[1])->EXIBE := .T.
			MsUnlock()

			// Adiciona o filho na árvore
			oTree:AddItem( (aDG9[1])->PROMP, (aDG9[1])->CARGO, (aDG9[1])->IMAGE, (aDG9[1])->IMAGE, , , 2 )

			// Abre a operação para adicionar os filhos
			oTree:TreeSeek( (aDG9[1])->CARGO )

			// Sobe o nível para voltar ao produto pai
			oTree:TreeSeek( (aDG0[1])->CARGO )
		
			(aDG9[1])->(dbSkip())
		End
	EndIf
EndIf

// Procura pelos componentes do produto caso marcado
If aConfig[1]

	// Varre os componentes em busca de filhos da versão
	dbSelectArea(aDG1[1])
	(aDG1[1])->(dbSetOrder(2))
	if (aDG1[1])->(dbSeek(Padr(cValToChar(nNivel+1),4)+Padr(cChave+(aDG0[1])->DG0_CDACDV+(aDG0[1])->DG0_NRVRAC,800)))
		While (aDG1[1])->(!EOF()) .AND. AllTrim((aDG1[1])->NIVEL) == cValToChar(nNivel+1) .AND.;
										AllTrim((aDG1[1])->CHAVE) == AllTrim( cChave + (aDG0[1])->DG0_CDACDV+(aDG0[1])->DG0_NRVRAC)
											
											
			// Define que o filho é exibido na árvore
			RecLock( (aDG1[1]), .F. )
			(aDG1[1])->EXIBE := .T.
			MsUnlock()

			// Adiciona o filho na árvore
			oTree:AddItem( (aDG1[1])->PROMP, (aDG1[1])->CARGO, (aDG1[1])->IMAGE, (aDG1[1])->IMAGE, , , 2 )

			// Caso seja um componente que desça níveis
		  	If aConfig[5] .And. ( !Empty( (aDG1[1])->DG1_CDMTDV ) .Or. nOrigem == 2 )
				oTree:TreeSeek( (aDG1[1])->CARGO )
				aAreaDG0 := (aDG0[1])->( GetArea() )
				aAreaDG1 := (aDG1[1])->( GetArea() )

				dbSelectArea( (aDG0[1]) )
				(aDG0[1])->( dbsetOrder(2) )
				if (aDG0[1])->(dbSeek((aDG1[1])->NIVEL+Padr(cChave + (aDG1[1])->DG1_CDACDV+(aDG1[1])->DG1_NRVRAC,800)))
					While (aDG0[1])->(!EOF()) .AND. AllTrim((aDG0[1])->NIVEL) == AllTrim((aDG1[1])->NIVEL) .AND.;
													AllTrim((aDG0[1])->CHAVE) == AllTrim( cChave + (aDG1[1])->DG1_CDACDV+(aDG1[1])->DG1_NRVRAC )
														 
														 
						If (AllTrim((aDG0[1])->DG0_CDACDV)  == AllTrim((aDG1[1])->DG1_CDMTDV) .Or. ;
							AllTrim((aDG0[1])->DG0_CDACDV)  == AllTrim((aDG1[1])->DG1_CDMT)) .And. ;
							AllTrim((aDG0[1])->DG0_NRVRAC)  == AllTrim((aDG1[1])->DG1_NRVRMT)

							RecLock( (aDG0[1]), .F. )
							(aDG0[1])->CARGO := (aDG1[1])->CARGO
							MsUnlock()

							oTree:TreeSeek( (aDG0[1])->CARGO )

						   	DPRASEARCH( oTree, nNivel+1, aConfig, cChave + (aDG1[1])->DG1_CDACDV+(aDG1[1])->DG1_NRVRAC, nIntegra  )

						   	Exit
						EndIf
						
						(aDG0[1])->(dbSkip())								 
					End
				EndIf
				
				RestArea( aAreaDG0 )
				RestArea( aAreaDG1 )
			EndIf

			// Sobe o nível para voltar ao produto pai
			oTree:TreeSeek( (aDG0[1])->CARGO )
		
			(aDG1[1])->(dbSkip())
		End
	EndIf
EndIf

// Ficha Técnica
IF aConfig[6]
	cChaveDGN := AllTrim(cChave + (aDG0[1])->DG0_CDACDV + IF((aDG0[1])->DG0_TPST>'6',(aDG0[1])->DG0_NRVRAC,''))

	dbSelectArea( (aDGN[1]) )
	(aDGN[1])->( dbSetOrder(1) )
	If (aDGN[1])->( dbSeek( cNivel+(aDG0[1])->DG0_CDACDV ) )
	
		if nIntegra == 1 // DPR
				
			dbSelectArea('DG3')
			DG3->(dbSetOrder(1))
		
		 	if nNivel == 1						
				DG3->(dbSeek(xFilial('DG3')+DG0->DG0_CDACDV))
				
				aTemplate := PCPA104CTP(DG3->DG3_CDFA,DG3->DG3_CDGE,,)
			ElseIf (aDG0[1])->IMAGE == 'FOLDER13                 '
				DG3->(dbSeek(xFilial('DG3')+(aDG0[1])->DG0_CDACDV))
				
				aTemplate := PCPA104CTP(DG3->DG3_CDFA,DG3->DG3_CDGE,,)
			Endif
		ElseIf nIntegra == 2 // PCP
			// Verificar templates alocados para o produto PCP
			dbSelectArea('CZ3')
			CZ3->(dbSetOrder(1))
			CZ3->(dbSeek(xFilial('CZ3')+(aDG0[1])->DG0_CDACDV))
		
			if nNivel == 1 .OR. (aDG0[1])->IMAGE == 'FOLDER13                 '
				aTemplate := PCPA104CTP(CZ3->CZ3_CDFA,CZ3->CZ3_CDGR,,)
			Endif
			
			// Verificar templates alocados para o produto DP
			dbSelectArea('DG3')
			DG3->(dbSetOrder(1))
			
			IF nNivel == 1
				DG3->(dbSeek(xFilial('DG3')+DG0->DG0_CDACDV))
				
				aTemplate2 := PCPA104CTP(DG3->DG3_CDFA,DG3->DG3_CDGE,,)
			Elseif (aDG0[1])->IMAGE == 'FOLDER13                 '
				DG3->(dbSeek(xFilial('DG3')+(aDG0[1])->DG0_CDACDV))
				
				aTemplate2 := PCPA104CTP(DG3->DG3_CDFA,DG3->DG3_CDGE,,)
			Endif
		Endif
	
		(aDGN[1])->(dbSetOrder(2))
		if (aDGN[1])->(dbSeek(Padr(cValToChar(nNivel+1),4)+Padr(cChaveDGN,800)))
			While (aDGN[1])->(!EOF()) .AND. AllTrim((aDGN[1])->NIVEL) == cValToChar(nNivel+1) .AND.;
											AllTrim((aDGN[1])->CHAVE) == cChaveDGN
																								
				RecLock( (aDGN[1]), .F. )

				IF Empty(aTemplate)
					(aDGN[1])->EXIBE := .F.
				Else
					IF aScan(aTemplate,{|x| x[1] == (aDGN[1])->DGN_CDMD } ) == 0
						(aDGN[1])->EXIBE := .F.
					Else
						(aDGN[1])->EXIBE := .T.
					Endif
				Endif
				
				if nIntegra == 2
					IF Empty(aTemplate2)
						(aDGN[1])->EXIBE := .F.
					Else
						IF aScan(aTemplate2,{|x| x[1] == (aDGN[1])->DGN_CDMD } ) == 0
							(aDGN[1])->EXIBE := .F.
						Endif
					Endif
				Endif
				
				(aDGN[1])->IMAGE := 'PAPEL_ESCRITO'

				MsUnlock()

				// Adiciona o filho na árvore
				oTree:AddItem( (aDGN[1])->PROMP, (aDGN[1])->CARGO, if((aDGN[1])->EXIBE,'PAPEL_ESCRITO','BR_CANCEL'), if((aDGN[1])->EXIBE,'PAPEL_ESCRITO','BR_CANCEL'), , , 2 )
			
				(aDGN[1])->( dbSkip() )
			End
		Endif
	Endif
Endif

// Customização da árvore
If IsInCallStack('DPRA330')
	oTree:bLDblClick := { || TreeChange( oTree, oTree:GetCargo() ) }
EndIf

RestArea(aAreaDG3)
RestArea(aAreaCZ3)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TreeChange
Altera a imagem dos itens da árvore

@param  	oTree			Árvore sendo alterada
@param 		cCargo			Cargo posicionado na árvore
@param		lChange			Se o item pai está marcado/desmarcado

@author Ana Carolina Tome Klock
@since 14/09/2012
@version P12
/*/
//-------------------------------------------------------------------
Static Function TreeChange( oTree, cCargo, lChange )
Local nI, cIDTREE	:= ''
Local cImage 		:= 'BR_CANCEL'
Local aTabs  		:= { 'aDG0', 'aDG1', 'aDG9', 'aDGN' }
Default lChange 	:= .F.

// Verifica se pode alterar seleção
If oTree:Nivel() > 1 .And. (TreeCanChg(oTree) .Or. lChange)

	// Busca nas tabelas
	oTree:TreeSeek(cCargo)
	For nI := 1 to len( aTabs )
		dbSelectArea( (&(aTabs[nI]+'[1]')) )
		(&(aTabs[nI]+'[1]'))->(dbSetOrder(1))
		
		If (&(aTabs[nI]+'[1]'))->( dbSeek( DPRNvlTree( cValToChar(oTree:Nivel()) )))
			cCargo := Substr( cCargo, len(cCargo)-len((&(aTabs[nI]+'[1]'))->CARGO) )
			
			(&(aTabs[nI]+'[1]'))->(dbSetOrder(3))
			if (&(aTabs[nI]+'[1]'))->(dbSeek(cCargo))	
			
				While (&(aTabs[nI]+'[1]'))->( !EOF() ) .AND. (&(aTabs[nI]+'[1]'))->CARGO == cCargo
	
					// Altera registro
					RecLock( (&(aTabs[nI]+'[1]')), .F.)
					If !lChange
						(&(aTabs[nI]+'[1]'))->EXIBE := !(&(aTabs[nI]+'[1]'))->EXIBE
					Else
						(&(aTabs[nI]+'[1]'))->EXIBE := .F.
					EndIf
					MsUnlock()
	
					// Se estiver liberando, volta imagem anterior
					If (&(aTabs[nI]+'[1]'))->EXIBE
						cImage := (&(aTabs[nI]+'[1]'))->IMAGE
					// Se não, desce níveis
					Else
						oTree:TreeSeek(cCargo)
						cIDTREE := (oTree:cArqTree)->T_IDCODE
						(oTree:cArqTree)->( dbSetOrder(2) )
						If (oTree:cArqTree)->( dbSeek( cIDTREE ) )
							While (oTree:cArqTree)->( !EOF() )
						    	If (oTree:cArqTree)->T_IDTREE == cIDTREE .And. oTree:aBmps[(oTree:cArqTree)->T_BMP001][1] != cImage
						    		oTree:TreeSeek( (oTree:cArqTree)->T_CARGO )
						    		TreeChange( oTree, (oTree:cArqTree)->T_CARGO, .T. )
						    	EndIf
						    	(oTree:cArqTree)->( dbSkip() )
						    End
						EndIf
	
					EndIf
					oTree:TreeSeek( cCargo )
	
					(&(aTabs[nI]+'[1]'))->( dbSkip() )
				End
			Endif
		EndIf
	Next nI
	oTree:TreeSeek(cCargo)

	// Altera imagem
  	oTree:ChangeBmp( cImage, cImage, , , cCargo )
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TreeCanChg
Verifica se pode alterar o item na árvore

@param  	oTree			Árvore sendo alterada

@author Ana Carolina Tome Klock
@since 06/03/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function TreeCanChg( oTree )
Local cImage := 'BR_CANCEL'

If oTree:Nivel() > 1
	cIDTREE := (oTree:cArqTree)->T_IDTREE
	(oTree:cArqTree)->( dbSetOrder(3) )
	If (oTree:cArqTree)->( dbSeek( cIDTREE ) )
		While (oTree:cArqTree)->( !EOF() )
		   	If (oTree:cArqTree)->T_IDCODE == cIDTREE
		   		If oTree:aBmps[(oTree:cArqTree)->T_BMP001][1] == cImage
		   			Return .F.
		   		Else
			   		oTree:TreeSeek( (oTree:cArqTree)->T_CARGO )
			   		Return TreeCanChg( oTree )
			   	EndIf
		   	EndIf
		   	(oTree:cArqTree)->( dbSkip() )
		End
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXTela
Exibe a tela correspondente ao item (DPRA310 ou DPRA320)

@param  	oTree			Árvore sendo alterada
@param 		cCargo			Cargo posicionado na árvore

@author Ana Carolina Tome Klock
@since 25/03/2013
@version P12
/*/
//-------------------------------------------------------------------
Function DPRXTela( oTree, cCargo )
Local oModel, lExibe := .T.

// Procura nos componentes
dbSelectArea( aDG1[1] )
If (aDG1[1])->( dbSeek( DPRNvlTree( cValToChar(oTree:Nivel()) )))
	cCargo := Substr( cCargo, len(cCargo)-len( (aDG1[1])->CARGO ))
	
	(aDG1[1])->(dbSetOrder(3))
	(aDG1[1])->(dbSeek(cCargo))
	
	While (aDG1[1])->( !EOF() ) .AND. (aDG1[1])->CARGO == cCargo
		dbSelectArea( 'DG1' )
		If DG1->( dbSeek( xFilial('DG1')+(aDG1[1])->DG1_CDACDV+(aDG1[1])->DG1_NRVRAC+(aDG1[1])->DG1_NRSQ ) )
 			oModel := FwLoadModel( 'DPRA310' )
			oModel:Activate()
 			FWExecView( '', 'DPRA310', 2,, { || .T. },,,,,,, oModel )
 			lExibe := .F.
		EndIf

		(aDG1[1])->( dbSkip() )
	End
EndIf

// Procura nas atividades
If lExibe
	dbSelectArea( aDG9[1] )
	If (aDG9[1])->( dbSeek( DPRNvlTree( cValToChar(oTree:Nivel()) )))
		cCargo := Substr( cCargo, len(cCargo)-len( (aDG9[1])->CARGO ))
		
		(aDG9[1])->(dbSetOrder(3))
		(aDG9[1])->(dbSeek(cCargo))
		
		While (aDG9[1])->( !EOF() ) .AND. (aDG9[1])->CARGO == cCargo
			dbSelectArea( 'DG9' )
			If DG9->( dbSeek( xFilial('DG9')+(aDG9[1])->DG9_CDACDV+(aDG9[1])->DG9_NRVRAC+(aDG9[1])->DG9_CDAT ) )
	 			oModel := FwLoadModel( 'DPRA320' )
				oModel:Activate()
	 			FWExecView( '', 'DPRA320', 2,, { || .T. },,,,,,, oModel )
	 			lExibe := .F.
			EndIf

			(aDG9[1])->( dbSkip() )
		End
	EndIf
EndIf

// Procura na versão
If lExibe
	dbSelectArea( aDG0[1] )
	If (aDG0[1])->( dbSeek( DPRNvlTree( cValToChar(oTree:Nivel()) )))
		cCargo := Substr( cCargo, len(cCargo)-len( (aDG0[1])->CARGO ))
		
		(aDG0[1])->(dbSetOrder(3))
		(aDG0[1])->(dbSeek(cCargo))
	
		While (aDG0[1])->( !EOF() ) .AND. (aDG0[1])->CARGO == cCargo
			dbSelectArea( 'DG0' )
			If DG0->( dbSeek( xFilial('DG0')+(aDG0[1])->DG0_CDACDV+(aDG0[1])->DG0_NRVRAC ) )
	 			oModel := FwLoadModel( 'DPRA300' )
				oModel:Activate()
	 			FWExecView( '', 'DPRA300', 2,, { || .T. },,,,,,, oModel )
			EndIf

			(aDG0[1])->( dbSkip() )
		End
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRATYPE
Altera a imagem dos itens que estão na estrutura

@param 	 	cProduct		Produto de engenharia
@return 	cImage			Imagem que será exibida

@author Ana Carolina Tome Klock
@since 02/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRATYPE( cProduct )

// Se for um Item da Engenharia
dbSelectArea( 'CZ3' )
CZ3->(dbSetOrder(1))
cProduct := AllTrim(cProduct) + Replicate('', TamSX3('CZ3_CDAC')[1]-Len(AllTrim(cProduct)) )
If CZ3->(dbSeek( xFilial('CZ3') + cProduct ))
	// Comprado
	If CZ3->CZ3_TPAC == '1'
		Return 'PMSTASK4'
	// Fabricado
	Else
		Return 'PMSTASK6'
	EndIf
EndIf

Return 'RPMDES'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRASTRUCT
Preenche as tabelas temporárias conforme parâmetros do SIGADPR

@param 		cCDACDV		Código do Produto
@param		cNRVRAC		Número da Versão
@param		aConfig		Parâmetros para montar a árvore
@param		nIntegra	Informa a origem da árvore buscada
						[1] SIGADPR
						[2] SIGAPCP

@author Ana Carolina Tome Klock
@since 16/07/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRASTRUCT( cCDACDV, cNRVRAC, aConfig, nIntegra, tpRoteiro )
Local lRet := .T.
aDG0	:= CreateTemp( 'DG0', , .T.)
aDG1	:= CreateTemp( 'DG1', , .T.)
aDG2	:= CreateTemp( 'DG2', 'DG2_CDRT+DG2_CDAT', .T.)
aDG3	:= CreateTemp( 'DG3', , .F.)
aDG9	:= CreateTemp( 'DG9', 'DG9_CDACDV+DG9_NRVRAC', .T.)
aDGN	:= CreateTemp( 'DGN', , .T.)

Default cCDACDV 	:= aValor[1]
Default cNRVRAC 	:= aValor[2]
Default aConfig		:= { .F., .F., .F., .F., .F., .F. }
Default nIntegra 	:= 1

If nIntegra == 1
	DPRSearch( cCDACDV, cNRVRAC, aConfig )
ElseIf nIntegra == 2
	lRet := PCPSearch( cCDACDV, aConfig, tpRoteiro )
	
	if !lRet // Encerrar alias
		(aDG0[1])->(dbCloseArea())
		(aDG1[1])->(dbCloseArea())
		(aDG2[1])->(dbCloseArea())
		(aDG3[1])->(dbCloseArea())
		(aDG9[1])->(dbCloseArea())
		(aDGN[1])->(dbCloseArea())
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRSearch
Realiza a busca recursiva para montar a árvore do produto.
Essa função deve ser chamada SOMENTE após a criação das tabelas temporárias.

@param 		cCDACDV		Código do Produto
@param		cNRVRAC		Número da Versão
@param 		aConfig		Vetor com os parâmetros de montagem
						[1] Buscar componentes
						[2] Buscar operações
						[3] Buscar componentes alternativos
						[4] Buscar operações alternativas
						[5] Descer níveis
						[6] Buscar Ficha
@param		nCount		Contador para montar a árvore
@param 		nNivel		Nivel da árvore
@param		cChave		Chave da árvore

@author Ana Carolina Tome Klock
@since 28/01/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRSearch( cCDACDV, cNRVRAC, aConfig, nCount, nNivel, cChave )
Local aArea 	:= GetArea()
Local aAreaDG1
Local aAreaDG0
Default nCount 	:= 1
Default nNivel 	:= 1
Default cChave 	:= ""

// Preenche árvore
dbSelectArea( 'DG0' )
DG0->( dbSetOrder(1) )
If DG0->( dbSeek( xFilial('DG0') + cCDACDV + cNRVRAC ) )

	// Adiciona Produto Desenvolvido
	AddProduct( cCDACDV )

	// Adiciona Versão
	AddVersion( @nCount, nNivel, cChave )

	// Adiciona Operação
	If aConfig[2]
		dbSelectArea( 'DG9' )
		DG9->( dbSetOrder(1) )
		If DG9->( dbSeek( xFilial('DG9') + cCDACDV + cNRVRAC ) )
			While DG9->( !EOF() )
				If DG9->DG9_CDACDV == cCDACDV .And. DG9->DG9_NRVRAC == cNRVRAC
		   			AddOperat( @nCount, nNivel+1, cChave + cCDACDV + cNRVRAC )				

					// Adiciona Alternativos da Operação
					dbSelectArea( 'DG2' )
		   			DG2->( dbSetOrder(1) )
		   			If DG2->( dbSeek( xFilial('DG2') + DG9->DG9_IDAT) )
						While DG2->( !EOF()) .AND. DG2->DG2_IDAT == DG9->DG9_IDAT
					   	   	AddAltOper( @nCount, nNivel+2, cChave + cCDACDV + cNRVRAC + DG9->DG9_IDAT, 1 )
					   	   	
						   	DG2->( dbSkip() )
						End
					EndIf
				EndIf
				DG9->( dbSkip() )
			End
		EndIf
	EndIf

	// Adiciona Componente
	If aConfig[1]
		dbSelectArea( 'DG1' )
		DG1->( dbSetOrder(1) )
		If DG1->( dbSeek( xFilial('DG1') + cCDACDV + cNRVRAC ) )
			While DG1->( !EOF() )
				If DG1->DG1_CDACDV == cCDACDV .And. DG1->DG1_NRVRAC == cNRVRAC
		   			AddCompon( @nCount, nNivel+1, cChave + cCDACDV + cNRVRAC )

					If !Empty( DG1->DG1_CDMTDV ) .And. aConfig[5]
				   		aAreaDG1 := DG1->( GetArea() )
				   		aAreaDG0 := DG0->( GetArea() )
				   		DPRSearch( DG1->DG1_CDMTDV, DG1->DG1_NRVRMT, aConfig, @nCount, nNivel+1, cChave + cCDACDV + cNRVRAC )
						RestArea( aAreaDG1 )
						RestArea( aAreaDG0 )
					EndIf

		   		EndIf
		   		DG1->( dbSkip() )
		   	End
		EndIf
	EndIf

	// Ficha Técnica
	if aConfig[6]
		dbSelectArea('DGN')
		DGN->(dbSetOrder(1))

		if IsInCallStack('DPRC310')
			If DGN->(dbSeek(xFilial('DGN')+cCDACDV+cNRVRAC))

				While DGN->(!EOF()) .AND. DGN->DGN_CDACDV == cCDACDV .AND. DGN->DGN_NRVRAC == cNRVRAC
					AddFicha(@nCount, nNivel + 1, cChave + cCDACDV + cNRVRAC, .F.)

					DGN->(dbSkip())
				End
			Endif
		Else
			If DGN->(dbSeek(xFilial('DGN')+cCDACDV+if(DG0->DG0_TPST>'6',cNRVRAC,Padr('',tamSX3('DG0_NRVRAC')[1]))))

				While DGN->(!EOF()) .AND. DGN->DGN_CDACDV == cCDACDV .AND. DGN->DGN_NRVRAC == if(DG0->DG0_TPST>'6',cNRVRAC,Padr('',tamSX3('DG0_NRVRAC')[1]))
					AddFicha(@nCount, nNivel+1, cChave + cCDACDV + if(DG0->DG0_TPST>'6',cNRVRAC,Padr('',tamSX3('DG0_NRVRAC')[1])), .F.)

					DGN->(dbSkip())
				End
			Endif
		Endif
	Endif
EndIf

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPSearch
Realiza a busca para montar a árvore do produto.
Essa função deve ser chamada SOMENTE após a criação das tabelas temporárias.

@param 		cCDACDV		Código do Produto
@param 		aConfig		Vetor com os parâmetros de montagem
						[1] Buscar componentes
						[2] Buscar operações
						[3] Buscar componentes alternativos
						[4] Buscar operações alternativas
						[5] Descer níveis
						[6] Buscar Ficha

@author Ana Carolina Tome Klock
@since 28/01/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function PCPSearch( cCDACDV, aConfig, nRoteiro )
Local nI, nJ
Local nCount 	:= 1
Local nNivel 	:= 1
Local cChave 	:= ""
Local cVersion  := SPACE( TAMSX3('DG0_NRVRAC')[1] )
Local aArea, lCria
Local cRevisao  := ''
Local cRot      := ''
Local oTempTable := NIL
local lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)


// Busca estrutura no SIGAPCP
Estrut2( cCDACDV,,,@oTempTable )
If ESTRUT->(RecCount()) > 0
	dbSelectArea( 'ESTRUT' )
	ESTRUT->( dbGoTo(1) )
	
	// Quando marcado todos os roteiros e algum produto possuir a, deverá retornar erro
	IF nRoteiro == 4 // 'Todos'
		dbSelectArea('SGF')
		SGF->(dbSetOrder(1))
		if SGF->(dbSeek(xFilial('SGF')+ESTRUT->CODIGO))
			MsgInfo(STR0019 + alltrim(SGF->GF_ROTEIRO) + STR0020 + ALLTRIM(ESTRUT->CODIGO) + STR0021) // 'O Roteiro ' ## ' do Produto ' ## ', possui relação Componente x Operação. Não será possível a relação de Todos os Roteiros. Favor alterar o parâmetro de importação Roteiro.'
			
			ESTRUT->(dbCloseArea())
			
			Return .F.
		Endif
	Endif

	// Adiciona Versão
	AddProduct( ESTRUT->CODIGO, .T. )
	AddVersion( @nCount, nNivel, cChave, 1, .T. )

	// Adiciona Componentes
	If aConfig[1]
		For nI := 1 to ESTRUT->(RecCount())
			If !Empty( ESTRUT->COMP )
			
				// Quando marcado todos os roteiros e algum produto possuir a, deverá retornar erro
			If lPCPREVATU 
				cRevisao :=   PCPREVATU(ESTRUT->CODIGO)
			Else
				cRevisao := Posicione('SB1',1,xFilial('SB1')+ESTRUT->CODIGO,'B1_REVATU')
			Endif

				SG1->(dbGoTo(ESTRUT->REGISTRO))
				
				if SG1->G1_REVINI <= cRevisao .AND. SG1->G1_REVFIM >= cRevisao
				
					IF nRoteiro == 4 // 'Todos'
						dbSelectArea('SGF')
						SGF->(dbSetOrder(1))
						if SGF->(dbSeek(xFilial('SGF')+ESTRUT->CODIGO))
							MsgInfo(STR0019 + alltrim(SGF->GF_ROTEIRO) + STR0020 + ALLTRIM(ESTRUT->CODIGO) + STR0021) // 'O Roteiro ' ## ' do Produto ' ## ', possui relação Componente x Operação. Não será possível a selação de Todos os Roteiros. Favor alterar o parâmetro de importação Roteiro.'
							
							ESTRUT->(dbCloseArea())
							Return .F.
						Endif
					Endif

					If Val(ESTRUT->NIVEL) == 1
						cChave := '' + ESTRUT->CODIGO + cVersion
						nNivel := Val(ESTRUT->NIVEL)+1
				   		AddCompon( @nCount, nNivel, cChave, .T. )
					ElseIf aConfig[5]
						aArea := ESTRUT->( GetArea() )
						cChave := GetChavePCP()
						RestArea( aArea )
						ESTRUT->( dbGoTo(nI) )
						cChave += ESTRUT->CODIGO + cVersion
						nNivel := Val(ESTRUT->NIVEL)+1
						AddCompon( @nCount, nNivel, cChave, .T. )
					EndIf
	
					// Abre arvore para adicionar estrutura
					If aConfig[5]
						If (nJ := IsNodePCP( ESTRUT->COMP, cChave )) > 0
							ESTRUT->( dbGoTo(nJ) )
							AddProduct( ESTRUT->CODIGO, .T. )
							AddVersion( @nCount, nNivel, cChave, ESTRUT->QUANT, .T. )
						EndIf
					EndIf
				
				EndIf

			EndIf
			ESTRUT->( dbGoTo(nI+1) )
		Next
	EndIf

	ESTRUT->(dbCloseArea())
Else
	dbSelectArea( 'SG2' )
	SG2->( dbSetOrder(1) )
	If SG2->( dbSeek(xFilial('SG2')+cCDACDV) )
		AddProduct( cCDACDV, .T. )
		AddVersion( @nCount, nNivel, cChave, 1, .T., .F., cCDACDV )
	EndIf
EndIf

oTempTable:Delete()

// Adiciona operacoes
If aConfig[2]
	(aDG0[1])->( dbGoTop() )
	While (aDG0[1])->( !EOF() )
		cRot := AddOperat( @nCount, Val((aDG0[1])->Nivel)+1, (aDG0[1])->Chave, .T., (aDG0[1])->DG0_CDACDV, nRoteiro )
		
		RecLock((aDG0[1]),.F.)
		
		(aDG0[1])->DG0_CDRTOG := cRot
		
		(aDG0[1])->(MsUnLock())
		
		(aDG0[1])->( dbSkip() )
	End

	(aDG1[1])->( dbGoTop() )
	While (aDG1[1])->( !EOF() )
		lCria := .T.
		(aDG0[1])->( dbGoTop() )
		While (aDG0[1])->( !EOF() )
			If (aDG0[1])->DG0_CDACDV == (aDG1[1])->DG1_CDMT
				lCria := .F.
			EndIf
			(aDG0[1])->( dbSkip() )
		End
		If lCria
			cRot := AddOperat( @nCount, Val((aDG1[1])->Nivel)+1, (aDG1[1])->CHAVE, .T., (aDG1[1])->DG1_CDMT, nRoteiro )
			If (aDG9[1])->DG9_CDACDV == (aDG1[1])->DG1_CDMT
				AddProduct( (aDG1[1])->DG1_CDMT, .T. )
				AddVersion( Val((aDG1[1])->CARGO)-1, Val((aDG1[1])->NIVEL), (aDG1[1])->CHAVE, 1, .T., .F., (aDG1[1])->DG1_CDMT )
				
				RecLock((aDG0[1]),.F.)
		
				(aDG0[1])->DG0_CDRTOG := cRot
				
				(aDG0[1])->(MsUnLock())
			EndIf
		EndIf
		(aDG1[1])->( dbSkip() )
	End
EndIf

IF aConfig[6]
	(aDG0[1])->( dbGoTop() )
	While (aDG0[1])->( !EOF() )
		AddFicha( @nCount, Val((aDG0[1])->Nivel)+1, (aDG0[1])->Chave, .T., (aDG0[1])->DG0_CDACDV )
		(aDG0[1])->( dbSkip() )
	End
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProduct
Adiciona o produto desenvolvido na tabela temporária de produtos

@param 	cCDACDV		(Obrigatório) Código do Produto Desenvolvido
@param	lPCP		Define se o produto é originado no SIGAPCP

@author Ana Carolina Tome Klock
@since 28/01/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function AddProduct( cCDACDV, lPCP )
Local nI
Local aArea := GetArea()
Local aPCP  := {{ 'B1_COD'    , 'DG3_CDACDV' }, ;
				{ 'B1_DESC'   , 'DG3_DSACDV' }, ;
				{ 'B1_COD'    , 'DG3_CDACDE' }, ;
				{ 'B1_DESC'   , 'DG3_DSACDE' }, ;
				{ 'B1_UM'	  , 'DG3_CDUN'	 }, ;
				{ 'B1_UM'	  , 'DG3_CDUNDE' }, ;
				{ 'B1_SEGUM'  , 'DG3_CDUN2'	 }, ;
				{ 'B1_CONV'   , 'DG3_VLPN2'  }, ;
				{ 'B1_TIPCONV', 'DG3_TPPNUN' }, ;
				{ 'B1_FILIAL' , 'DG3_CDES'   }, ;
				{ 'B1_TIPO'   , 'DG3_CDFA'	 }, ;
				{ 'B1_LOCPAD' , 'DG3_CDDPPA' }, ;
				{ 'B1_GRUPO'  , 'DG3_CDGE'	 }}
Default lPCP := .F.

If lPCP
   	// Produto (SB1)
   	dbSelectArea( 'SB1' )
   	If SB1->( dbSeek( xFilial('SB1') + cCDACDV ) )
   		RecLock( (aDG3[1]), .T.)
   		dbSelectArea( 'SX3' )
		For nI := 1 to len( aPCP )
			SX3->( dbSetOrder( 2 ) )
			If SX3->( dbSeek( aPCP[nI][1] ) ) .And. ;
			   SX3->( dbSeek( aPCP[nI][2] ) )
			   
			   	If GetSx3Cache( aPCP[nI][2], 'X3_CONTEXT') != 'V'
					If aPCP[nI][1] == 'B1_TIPCONV'
						(aDG3[1])->&( aPCP[nI][2] ) := If (SB1->&( aPCP[nI][1] ) == 'M','1','2')
					Else
						(aDG3[1])->&( aPCP[nI][2] ) := SB1->&( aPCP[nI][1] )
					EndIf
				EndIf
			EndIf
		Next
		MsUnlock()
   	EndIf
Else
	// Produto Desenvolvido (DG3)
	dbSelectArea( 'DG3' )
	DG3->(dbSetOrder(1))
	If DG3->( dbSeek( xFilial('DG3') + cCDACDV  ) )
		RecLock( (aDG3[1]), .T.)
		For nI := 1 to len( aDG3[2] )
			dbSelectArea( 'SX3' )
			SX3->( dbSetOrder( 2 ) )
			If SX3->( dbSeek( aDG3[2][nI][1] ) )
			
				If GetSx3Cache( aDG3[2][nI][1], 'X3_CONTEXT') != 'V'
					(aDG3[1])->&( aDG3[2][nI][1] ) := DG3->&( aDG3[2][nI][1] )
				EndIf
			EndIf
		Next
		MsUnlock()
	EndIf
EndIf

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddVersion
Adiciona a versão do produto na tabela temporária de versão

@param 		nCount		(Obrigatório) Contador para o cargo da Tree
@param 		nNivel		(Obrigatório) Nível da Versão na Tree
@param 		cChave		(Obrigatório) Todos os pais da Versão
@param		nQuant		Quantidade do produto pai caso importado via SIGAPCP
@param		lPCP		Define se o produto é originado no SIGAPCP
@param 		lComp		Grava o componente ao inves do pai (apenas quando lPCP)
@param		cCodigo		Código do Produto PCP

@author Ana Carolina Tome Klock
@since 28/01/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function AddVersion( nCount, nNivel, cChave, nQuant, lPCP, lComp, cCodigo )
Local nI, cVersion
Local aPCP := {{ 'B1_COD'    , 'DG0_CDACDV' }, ;
				{ 'B1_DESC'   , 'DG0_DSVR' 	 }, ;
				{ 'B1_FILIAL' , 'DG0_CDES' 	 }, ;
				{ 'B1_CUSTD'  , 'DG0_VLPRRO' }, ;
				{ 'B1_UCALSTD', 'DG0_DTULRO' }, ;
				{ 'B1_UPRC'   , 'DG0_VLULEN' }, ;
				{ 'B1_UCOM'   , 'DG0_DTULEN' }, ;
				{ 'B1_QB'      ,'DG0_QTACEA' }}

Default nQuant 	:= 1
Default lPCP	:= .F.
Default lComp	:= .F.
Default cCodigo := If (lPCP, ESTRUT->CODIGO, '')

If lPCP
	If lComp
		cCodigo := ESTRUT->COMP
	EndIf

   	// Produto (SB1)
   	dbSelectArea( 'SB1' )
   	If SB1->( dbSeek( xFilial('SB1') + cCodigo ) )
   		RecLock( (aDG0[1]), .T.)
		(aDG0[1])->NIVEL      := cValToChar(nNivel)
		(aDG0[1])->CHAVE      := cChave
		(aDG0[1])->EXIBE      := .F.
		(aDG0[1])->CARGO      := DPRXCOUNT( 5, nCount++ )
		(aDG0[1])->IMAGE      := 'FOLDER13'
		(aDG0[1])->PROMP      := UPPER( AllTrim(cCodigo) + ' - ' + AllTrim(SB1->B1_DESC) + STR0001 + cValToChar(nQuant) ) //  - Quantidade:
		(aDG0[1])->DG0_TPST   := '1'
		(aDG0[1])->DG0_CDACPY := (aDG3[1])->DG3_CDACPY
		For nI := 1 to len( aPCP )
			dbSelectArea( 'SX3' )
			SX3->( dbSetOrder( 2 ) )
			If SX3->( dbSeek( aPCP[nI][1] ) ) .And. ;
			   SX3->( dbSeek( aPCP[nI][2] ) )
			   
				If GetSx3Cache( aPCP[nI][2], 'X3_CONTEXT') != 'V'
					(aDG0[1])->&( aPCP[nI][2] ) := SB1->&( aPCP[nI][1] )
				EndIf
			EndIf
		Next
		MsUnlock()
   	EndIf
Else
	// Versão do Produto (DG0)
	RecLock( (aDG0[1]), .T.)
	(aDG0[1])->NIVEL      := cValToChar(nNivel)
	(aDG0[1])->CHAVE      := cChave
	(aDG0[1])->EXIBE      := .F.
	(aDG0[1])->CARGO      := DPRXCOUNT( 5, nCount++ )
	(aDG0[1])->IMAGE      := 'FOLDER13'
	(aDG0[1])->PROMP      := UPPER( AllTrim(DG0->DG0_CDACDV) + STR0002 + DG0->DG0_NRVRAC + ' - ' + DG0->DG0_DSVR) //  - Versão
	(aDG0[1])->DG0_QTACEA := 1
	For nI := 7 to len( aDG0[2] )
		dbSelectArea( 'SX3' )
		SX3->( dbSetOrder( 2 ) )
		If SX3->( dbSeek( aDG0[2][nI][1] ) )
		
			If GetSx3Cache( aDG0[2][nI][1], 'X3_CONTEXT') != 'V' 
				(aDG0[1])->&( aDG0[2][nI][1] ) := DG0->&( aDG0[2][nI][1] )
			EndIf
		EndIf
	Next
	(aDG0[1])->DG0_CDRT   := ''
	(aDG0[1])->DG0_CDRTDE := ''
	(aDG0[1])->DG0_NROLD  := (aDG0[1])->DG0_NRVRAC
	MsUnlock()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFicha
Adiciona um componente na tabela temporária de ficha

@param 		nCount		(Obrigatório) Contador para o cargo da Tree
@param 		nNivel		(Obrigatório) Nível do Componente na Tree
@param 		cChave		(Obrigatório) Todos os pais do Componente
@param		lPCP		Define se o produto é originado no SIGAPCP
@param		cCodigo		Código do Produto

@author Samantha Preima
@since 18/11/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function AddFicha (nCount, nNivel, cChave, lPCP, cCodigo)
Local nI
Local aRetorno := {}
Local nTam     := TamSX3('DG0_CDACDV')[1] + TamSX3('DG0_NRVRAC')[1]

If lPCP
	aRetorno := Get_Ficha_Tecnica(cCodigo)

	For nI := 1 to Len(aRetorno)
		dbSelectArea(aDGN[1])
  		(aDGN[1])->(dbSetOrder(1))
   		If !(aDGN[1])->( dbSeek( Padr(cValToChar(nNivel),4)+Padr(aRetorno[nI][1],tamSX3("DGN_CDACDV")[1])+Padr('',tamSX3('DG0_NRVRAC')[1])+Padr(aRetorno[nI][2],tamSX3("DGN_CDMQ")[1])+Padr(aRetorno[nI][3],tamSX3("DGN_CDMD")[1]) ) )
   			RecLock( (aDGN[1]), .T.)
			(aDGN[1])->NIVEL := cValToChar(nNivel)
			(aDGN[1])->CHAVE := AllTrim( If (len(AllTrim(cChave))>0, Substr(cChave, 1, (Int(len(AllTrim(cChave))/nTam)+1)*nTam), '') + cCodigo )
			(aDGN[1])->EXIBE := .F.
			(aDGN[1])->CARGO := DPRXCOUNT( 5, nCount++ )			
			(aDGN[1])->IMAGE := 'PAPEL_ESCRITO'
			(aDGN[1])->PROMP := STR0012 + aRetorno[nI][1] + STR0013 + aRetorno[nI][2] +; // 'FICHA TÉCNICA ' ## ' - RECURSO: '
                                STR0014 + aRetorno[nI][3] // ' - TEMPLATE: '
			(aDGN[1])->DGN_CDACDV := aRetorno[nI][1]
			(aDGN[1])->DGN_CDMQ   := aRetorno[nI][2]
			(aDGN[1])->DGN_CDMD   := aRetorno[nI][3]
			(aDGN[1])->DGN_VRFH   := aRetorno[nI][4]
			MsUnlock()
		Endif
	Next
Else
	RecLock( (aDGN[1]), .T.)
	(aDGN[1])->NIVEL := cValToChar(nNivel)
	(aDGN[1])->CHAVE := cChave
	(aDGN[1])->EXIBE := .F.
	(aDGN[1])->CARGO := DPRXCOUNT( 5, nCount++ )
	(aDGN[1])->IMAGE := 'PAPEL_ESCRITO'
	(aDGN[1])->PROMP := STR0012 + alltrim(DGN->DGN_CDACDV) + ' - ' + alltrim(DGN->DGN_NRVRAC) + STR0013 + alltrim(DGN->DGN_CDMQ) +;// 'FICHA TÉCNICA ' ## ' - RECURSO: '
	                    STR0014 + alltrim(DGN->DGN_CDMD) // ' - TEMPLATE: '
	(aDGN[1])->DGN_NRVROR := DGN->DGN_NRVRAC

	For nI := 7 to len( aDGN[2] )
		dbSelectArea( 'SX3' )
		SX3->( dbSetOrder( 2 ) )
		If SX3->( dbSeek( aDGN[2][nI][1] ) )
		
			If GetSx3Cache( aDGN[2][nI][1], 'X3_CONTEXT') != 'V'
				(aDGN[1])->&( aDGN[2][nI][1] ) := DGN->&( aDGN[2][nI][1] )
			EndIf
		EndIf
	Next

	MsUnlock()
Endif

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddCompon
Adiciona um componente na tabela temporária de estrutura

@param 		nCount		(Obrigatório) Contador para o cargo da Tree
@param 		nNivel		(Obrigatório) Nível do Componente na Tree
@param 		cChave		(Obrigatório) Todos os pais do Componente
@param		lPCP		Define se o produto é originado no SIGAPCP

@author Ana Carolina Tome Klock
@since 28/01/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function AddCompon( nCount, nNivel, cChave, lPCP )
Local nI
Local aPCP := {{ 'G1_COD'    , 'DG1_CDACDV'}, ;
				{ 'G1_COMP'   , 'DG1_CDMT'  }, ;
				{ 'G1_QUANT'  , 'DG1_QTMT'  }, ;
				{ 'G1_PERDA'  , 'DG1_VLPNLS'}, ;
				{ 'G1_INI'    , 'DG1_DTBG'  }, ;
				{ 'G1_FIM'    , 'DG1_DTED'  }}
Default lPCP := .F.

If lPCP

   	// Estrutura (SG1)
	dbSelectArea( 'SG1' )
	SG1->(dbGoTo(ESTRUT->REGISTRO))
   	
	RecLock( (aDG1[1]), .T.)
	(aDG1[1])->NIVEL    := cValToChar(nNivel)
	(aDG1[1])->CHAVE    := cChave
	(aDG1[1])->EXIBE    := .F.
	(aDG1[1])->CARGO    := DPRXCOUNT( 5, nCount++ )
	(aDG1[1])->IMAGE    := 'PMSTASK6'
	(aDG1[1])->PROMP    := STR0022 + SG1->G1_TRT + ' - ' + UPPER( STR0003 + AllTrim(SG1->G1_COMP) + ' - ' + AllTrim(Posicione('SB1', 1, xFilial('SB1')+ESTRUT->COMP, 'B1_DESC')) + STR0001 + cValToChar(SG1->G1_QUANT) ) // 'Sequencia: ' ## Componente - Quantidade:
	(aDG1[1])->DG1_QTAC := 1
	(aDG1[1])->DG1_LGVI := '0'
	(aDG1[1])->DG1_TPVV := If(SG1->G1_FIXVAR == 'F', '2', '1')
	(aDG1[1])->DG1_VLPN := 100
	(aDG1[1])->DG1_NRSQET := SG1->G1_TRT
	
	For nI := 1 to len( aPCP )
		dbSelectArea( 'SX3' )
		SX3->( dbSetOrder( 2 ) )
		If SX3->( dbSeek( aPCP[nI][1] ) ) .And. ;
		   SX3->( dbSeek( aPCP[nI][2] ) )
		   
			If GetSx3Cache( aPCP[nI][2], 'X3_CONTEXT') != 'V'
				(aDG1[1])->&( aPCP[nI][2] ) := SG1->&( aPCP[nI][1] )
			EndIf
		EndIf
	Next		
	MsUnlock()
Else
	// Componente da Versão do Produto (DG1)
	RecLock( (aDG1[1]), .T.)
	(aDG1[1])->NIVEL := cValToChar(nNivel)
	(aDG1[1])->CHAVE := cChave
	(aDG1[1])->EXIBE := .F.
	(aDG1[1])->CARGO := DPRXCOUNT( 5, nCount++ )
	(aDG1[1])->IMAGE := If ( !Empty(DG1->DG1_CDMT), DPRATYPE(DG1->DG1_CDMT), 'RPMDES' )
	(aDG1[1])->PROMP := If ( !Empty(DG1->DG1_CDMT),	UPPER(STR0003 + AllTrim(DG1->DG1_CDMT) + ' - ' + AllTrim(Posicione( 'CZ3', 1, xFilial('CZ3')+DG1->DG1_CDMT, 'CZ3_DSAC' )) + STR0004 + cValToChar(DG1->DG1_QTMT) + ' ' + UPPER( AllTrim(Posicione('CZ3', 1, xFilial('CZ3')+DG1->DG1_CDMT, 'CZ3_CDUN')))), ; // 'Componente - ' ## ' - Qtd: '
			   		    			  					UPPER(STR0005 + AllTrim(DG1->DG1_CDMTDV) + ' - ' + AllTrim(DG1->DG1_NRVRMT) + ' - ' + AllTrim(Posicione( 'DG3', 1, xFilial('DG3')+DG1->DG1_CDMTDV, 'DG3_DSACDV' )) + STR0004 + cValToChar(DG1->DG1_QTMT) + ' ' + AllTrim(Posicione('DG3', 1, xFilial('DG3')+DG1->DG1_CDMTDV, 'DG3_CDUN'))) ) // 'Componente Desenvolvido - ' ## ' - Qtd: '

	For nI := 7 to len( aDG1[2] )
		dbSelectArea( 'SX3' )
		SX3->( dbSetOrder( 2 ) )
		If SX3->( dbSeek( aDG1[2][nI][1] ) )
		
			If GetSx3Cache( aDG1[2][nI][1], 'X3_CONTEXT') != 'V'
				(aDG1[1])->&( aDG1[2][nI][1] ) := DG1->&( aDG1[2][nI][1] )
			EndIf
		EndIf
	Next
	MsUnlock()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddOperat
Adiciona a operação da versão na tabela temporária de operação

@param 		nCount		(Obrigatório) Contador para o cargo da Tree
@param 		nNivel		(Obrigatório) Nível da Operação na Tree
@param 		cChave		(Obrigatório) Todos os pais da Operação
@param		lPCP		Define se o produto é originado no SIGAPCP
@param		cCodigo		Código do Produto PCP

@author 	Ana Carolina Tome Klock
@since 		28/01/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function AddOperat( nCount, nNivel, cChave, lPCP, cCodigo, nRoteiro )
Local nI
Local cAliasSG2
Local cRot := ''
Default lPCP	:= .F.
Default cCodigo := ''

If lPCP
	// Roteiro (SG2)
	dbSelectArea( 'SG2' )
	SG2->(dbSetOrder(1))

	// Busca de roteiro pelo informado em tela
	Do Case
		Case nRoteiro == 1 // Primeiro			
			If SG2->( dbSeek( xFilial('SG2') + cCodigo ) )
				cRot := SG2->G2_CODIGO 
				
				While SG2->( !EOF() ) .AND. SG2->G2_PRODUTO == cCodigo .AND. SG2->G2_CODIGO == cRot
					GeraOperac(@nCount,nNivel,cChave,cCodigo)
					SG2->(dbSkip())
				End
			Endif
		Case nRoteiro == 2 // Último
		
			cAliasSG2 := GetNextAlias()
			
			BeginSql Alias cAliasSG2
		
				SELECT G2_CODIGO FROM %Table:SG2% SG2
					WHERE SG2.G2_FILIAL=%xFilial:SG2% AND 
						  SG2.G2_PRODUTO=%Exp:cCodigo% AND
						  SG2.%NotDel% 
						  ORDER BY G2_CODIGO DESC
			
			EndSql
			
			cRot := (cAliasSG2)->G2_CODIGO
			
			If SG2->( dbSeek( xFilial('SG2') + cCodigo + cRot ) )			
				While SG2->( !EOF() ) .AND. SG2->G2_PRODUTO == cCodigo .AND. SG2->G2_CODIGO == cRot
					GeraOperac(@nCount,nNivel,cChave,cCodigo)
					SG2->(dbSkip())
				End
			Endif
			
			(cAliasSG2)->(dbCloseArea())
			
		Case nRoteiro == 3 // Padrão 			
			If SG2->( dbSeek( xFilial('SG2') + cCodigo + POSICIONE('SB1',1,xFilial('SB1')+cCodigo,'B1_OPERPAD') ) )
				cRot := SG2->G2_CODIGO
			
				While SG2->( !EOF() ) .AND. SG2->G2_PRODUTO == cCodigo .AND. SG2->G2_CODIGO == cRot
					GeraOperac(@nCount,nNivel,cChave,cCodigo)
					SG2->(dbSkip())
				End
			Endif
		Case nRoteiro == 4 // Todos
			SG2->(dbSetOrder(1))
			If SG2->( dbSeek( xFilial('SG2') + cCodigo ) )
				While SG2->( !EOF() ) .AND. SG2->G2_PRODUTO == cCodigo
					GeraOperac(@nCount,nNivel,cChave,cCodigo)
				
					SG2->(dbSkip())					
				End
			Endif
	EndCase

	// Adiciona Alternativos da Operação	
	IF nRoteiro == 4 // Todos
		dbSelectArea( 'SH3' )
		SH3->( dbSetOrder(1) )
		If SH3->( dbSeek( xFilial('SH3') + cCodigo) )
			While SH3->( !EOF()) .AND. SH3->H3_PRODUTO == cCodigo
		   	   	AddAltOper( @nCount, nNivel+1, cChave + cCodigo, if(lPCP, 2, 1), cCodigo )
		   	   	
			   	SH3->( dbSkip() )
			End
		EndIf
	Else // Primeiro, Último ou Padrão		
		dbSelectArea( 'SH3' )
		SH3->( dbSetOrder(1) )
		If SH3->( dbSeek( xFilial('SH3') + cCodigo + cRot) )
			While SH3->( !EOF()) .AND. SH3->H3_PRODUTO == cCodigo .AND. SH3->H3_CODIGO == cRot
		   	   	AddAltOper( @nCount, nNivel+1, cChave + cCodigo + cRot, if(lPCP, 2, 1), cCodigo )
		   	   	
			   	SH3->( dbSkip() )
			End
		EndIf
	Endif
	
	// Verificar componentes x operações
	if !Empty(cRot)
		dbSelectArea('SGF')
		SGF->(dbSetOrder(1))
		IF SGF->(dbSeek(xFilial('SGF')+cCodigo+cRot))
			While SGF->(!EOF()) .AND. SGF->GF_FILIAL == xFilial('SGF') .AND. SGF->GF_PRODUTO == cCodigo .and. SGF->GF_ROTEIRO == cRot
				For nI := 1 to (aDG1[1])->( RecCount() )
					(aDG1[1])->( dbGoTo(nI) )
					
					if (aDG1[1])->DG1_CDACDV == cCodigo .AND. (aDG1[1])->DG1_CDMT == SGF->GF_COMP .AND. (aDG1[1])->DG1_NRSQET == SGF->GF_TRT
						RecLock(aDG1[1],.F.)
						
						(aDG1[1])->DG1_CDATET := SGF->GF_OPERAC
						
						MsUnLock()
					Endif
				Next
			
				SGF->(dbSkip())
			End
		Endif
	Endif
Else
	// Operação da Versão do Produto (DG9)
	lErro := .F. 
	RecLock( (aDG9[1]), .T.)
		(aDG9[1])->NIVEL := cValToChar(nNivel)
		(aDG9[1])->CHAVE := cChave
		(aDG9[1])->EXIBE := .F.
		(aDG9[1])->CARGO := DPRXCOUNT( 5, nCount++ )
		(aDG9[1])->IMAGE := 'CLOCK01'
		(aDG9[1])->PROMP := UPPER( STR0007 + AllTrim(DG9->DG9_CDAT) + ' - ' + AllTrim(DG9->DG9_DSAT) + STR0017 + Alltrim(DG9->DG9_CDMQ) + STR0018 + cValToChar(DG9->DG9_QTTEMQ) + ' ' + X3Combo( 'DG9_TPUNTE', DG9->DG9_TPUNTE ) ) // 'Operação - ' ## ' - Máquina: ' ## ' - Tempo: '
		cMsg := " Erros: " 
		For nI := 7 to len( aDG9[2] )
			
			dbSelectArea( 'SX3' )
			SX3->( dbSetOrder( 2 ) )
			If SX3->( dbSeek( aDG9[2][nI][1] ) )
				If GetSx3Cache( aDG9[2][nI][1], 'X3_CONTEXT') != 'V'
					//Valida campos 
					
					IF aDG9[2][nI][1] == "DG9_CDCETR"
						
						IF  EMPTY(DG9->&( aDG9[2][nI][1])) 
							cMsg += STR0023 + ALLTRIM(GetSx3Cache( aDG9[2][nI][1], 'X3_DESCRIC') )  // "O campo..: " 
							cMsg += STR0024 //" não foi preenchido."

						ElseIf (! DPExistCpo("CYI", DG9->&( aDG9[2][nI][1])))
							cMsg +=  ALLTRIM(GetSx3Cache( aDG9[2][nI][1], 'X3_DESCRIC') ) 
							cMsg += STR0025 +DG9->&(aDG9[2][nI][1]) //" - Registro não econtrado...: "  
							lErro := .T.
						EndIf
					
					ElseIf ! EMPTY(DG9->&( aDG9[2][nI][1])) .AND. aDG9[2][nI][1] == "DG9_CDFOSU"
						IF ! DPExistCpo("SM4", DG9->&( aDG9[2][nI][1])) 
							cMsg +=  ALLTRIM(GetSx3Cache( aDG9[2][nI][1], 'X3_DESCRIC') ) 
							cMsg += STR0025 +DG9->&(aDG9[2][nI][1]) //" - Registro não econtrado...: "
							lErro := .T.
						EndIf
					
					ElseIf ! EMPTY(DG9->&( aDG9[2][nI][1])) .AND. aDG9[2][nI][1] == "DG9_CDUNAT"
						IF ! DPExistCpo("CZ9", DG9->&( aDG9[2][nI][1]))
							cMsg +=  ALLTRIM(GetSx3Cache( aDG9[2][nI][1], 'X3_DESCRIC') ) 
							cMsg += STR0025 +DG9->&(aDG9[2][nI][1]) //" - Registro não econtrado...: "
							lErro := .T.
						Endif
					
					ElseIf ! EMPTY(DG9->&( aDG9[2][nI][1])) .AND. aDG9[2][nI][1] == "DG9_CDFE"
						if ! DPExistCpo("CYH", "2"+DG9->&( aDG9[2][nI][1]))
							cMsg +=  ALLTRIM(GetSx3Cache( aDG9[2][nI][1], 'X3_DESCRIC') ) 
							cMsg += STR0025 +DG9->&(aDG9[2][nI][1]) //" - Registro não econtrado...: "
					
							lErro := .T.
						Endif
					
					// Nesse campo é necessário validar se o campo nao esta em branco, pois é obrigatório
					ElseIf aDG9[2][nI][1] == "DG9_CDMQ" 
						
						IF  EMPTY(DG9->&( aDG9[2][nI][1])) 
							cMsg += STR0023 + ALLTRIM(GetSx3Cache( aDG9[2][nI][1], 'X3_DESCRIC') ) 
							cMsg += STR0024

						ElseIf (! DPExistCpo("CYB", DG9->&( aDG9[2][nI][1])))
							cMsg +=  ALLTRIM(GetSx3Cache( aDG9[2][nI][1], 'X3_DESCRIC') ) 
							cMsg += STR0025 +DG9->&(aDG9[2][nI][1]) //" - Registro não econtrado...: "
							lErro := .T.
						EndIf
					
					EndIf
									
					(aDG9[1])->&(aDG9[2][nI][1]) := DG9->&(aDG9[2][nI][1])
				EndIf

			EndIf
		Next

		IF lErro
			(aDG9[1])->IMAGE := 'BR_CANCEL'
			(aDG9[1])->PROMP := UPPER( STR0007 + AllTrim(DG9->DG9_CDAT)) + ' - ' + cMsg
		Endif	
		
	MsUnlock()
EndIf

Return cRot

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraOperac
Adiciona a operação

@author Samantha Preima
@since 20/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function GeraOperac (nCount,nNivel,cChave,cCodigo)
Local nTam := TamSX3('DG0_CDACDV')[1] + TamSX3('DG0_NRVRAC')[1]
Local nI   := 0
Local aPCP := { { 'G2_PRODUTO'	, 'DG9_CDACDV'}, ;
				{ 'G2_DESCRI' 	, 'DG9_DSAT'  }, ;
				{ 'G2_CTRAB'  	, 'DG9_CDCETR'}, ;
				{ 'G2_RECURSO'	, 'DG9_CDMQ'  }, ;
				{ 'G2_LOTEPAD'	, 'DG9_NRUNAC'}, ;
				{ 'G2_SETUP'  	, 'DG9_QTTESU'}, ;
				{ 'G2_FORMSTP'	, 'DG9_CDFOSU'}, ;
				{ 'G2_TEMPAD' 	, 'DG9_QTTEMQ'}, ;
				{ 'G2_MAOOBRA'	, 'DG9_QTRC'  }, ;
				{ 'G2_FERRAM' 	, 'DG9_CDFE'  }, ;
				{ 'G2_TPALOCF'	, 'DG9_TPALFE'}, ;
				{ 'G2_TPSOBRE'	, 'DG9_TPTEOV'}, ;
				{ 'G2_TEMPSOB'	, 'DG9_QTTEOV'}, ;
				{ 'G2_TEMPEND'	, 'DG9_QTTEPP'}, ;
				{ 'G2_OPERAC'   , 'DG9_CDATET'}}

RecLock( (aDG9[1]), .T.)
(aDG9[1])->NIVEL      := cValToChar(nNivel)
(aDG9[1])->CHAVE      := AllTrim( If (len(AllTrim(cChave))>0, Substr(cChave, 1, (Int(len(AllTrim(cChave))/nTam)+1)*nTam), '') + cCodigo  )
(aDG9[1])->EXIBE      := .F.
(aDG9[1])->CARGO      := DPRXCOUNT( 5, nCount++ )
(aDG9[1])->IMAGE      := 'CLOCK01'
(aDG9[1])->PROMP      := STR0015 + AllTrim(SG2->G2_CODIGO) + STR0016 + UPPER( AllTrim(SG2->G2_OPERAC) + ' - ' + AllTrim(SG2->G2_DESCRI) + STR0017 +  AllTrim(SG2->G2_RECURSO)) // 'ROTEIRO: ' ## ' - OPERAÇÃO: ' ## ' - Máquina: '
(aDG9[1])->DG9_DTBG   := DATE()
(aDG9[1])->DG9_DTED   := STOD('99991231')
(aDG9[1])->DG9_LGATVF := '0'
(aDG9[1])->DG9_TPUNTE := '1'
(aDG9[1])->DG9_TPTEAT := If (SG2->G2_TPOPER == '3', '1', If(SG2->G2_TPOPER == '4', '3', SG2->G2_TPOPER))
(aDG9[1])->DG9_CDRT   := SG2->G2_CODIGO

For nI := 1 to len( aPCP )
	dbSelectArea( 'SX3' )
	SX3->( dbSetOrder( 2 ) )
	If SX3->( dbSeek( aPCP[nI][1] ) ) .And. ;
	   SX3->( dbSeek( aPCP[nI][2] ) )
	   
		If GetSx3Cache( aPCP[nI][2], 'X3_CONTEXT') != 'V'
			(aDG9[1])->&( aPCP[nI][2] ) := SG2->&( aPCP[nI][1] )
		EndIf
	EndIf
Next

MsUnlock()

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddAltOper
Adiciona a alternativos da operação 

@param 	nCount			(Obrigatório) Contador para o cargo da Tree
@param 	nNivel			(Obrigatório) Nível da Ferramenta na Tree
@param 	cChave			(Obrigatório) Todos os pais da Ferramenta

@author Ana Carolina Tome Klock
@since 28/01/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function AddAltOper( nCount, nNivel, cChave, nIntegra, cCodigo )
Local nTam := TamSX3('DG0_CDACDV')[1] + TamSX3('G2_OPERAC')[1]
Local nI
Local aPCP := {{'H3_FERRAM' , 'DG2_CDFE'}, ;
				{ 'H3_RECALTE', 'DG2_CDMQ'}, ;
				{ 'H3_TIPO'   , 'DG2_TPMQ'}, ;
				{ 'H3_EFICIEN', 'DG2_VLEF'}}

RecLock( (aDG2[1]), .T.)

if nIntegra == 1 // SIGADPR
	(aDG2[1])->NIVEL      := cValToChar(nNivel)
	(aDG2[1])->CHAVE      := cChave
	(aDG2[1])->EXIBE      := .T.
	(aDG2[1])->CARGO      := DPRXCOUNT( 5, nCount++ )
	(aDG2[1])->IMAGE      := 'INSTRUME'
	(aDG2[1])->DG2_CDACDV := DG0->DG0_CDACDV
	(aDG2[1])->DG2_NRVRAC := DG0->DG0_NRVRAC
	
	IF Empty(DG2->DG2_CDFE) // Então é Recurso Alternativo
		(aDG2[1])->PROMP := UPPER( 'RECURSO ' + IF(DG2->DG2_TPMQ == 'A', 'ALTERNATIVO ', 'SECUNDÁRIO ') + AllTrim(DG2->DG2_CDMQ) + ' - EFICIÊNCIA: ' + STR(DG2->DG2_VLEF))	
	Else // Então é Ferramenta Alternativa
		(aDG2[1])->PROMP := UPPER( 'FERRAMENTA ' + AllTrim(DG2->DG2_CDFE) )
	Endif
	
	For nI := 7 to len( aDG2[2] )
		dbSelectArea( 'SX3' )
		SX3->( dbSetOrder( 2 ) )
		If SX3->( dbSeek( aDG2[2][nI][1] ) ) .AND. GetSx3Cache( aDG2[2][nI][1], 'X3_CAMPO') == aDG2[2][nI][1]
		
			If GetSx3Cache( aDG2[2][nI][1], 'X3_CONTEXT') != 'V'
				(aDG2[1])->&( aDG2[2][nI][1] ) := DG2->&( aDG2[2][nI][1] )
			EndIf
		EndIf
	Next
ElseIf nIntegra == 2 // SIGAPCP
	(aDG2[1])->NIVEL    := cValToChar(nNivel)
	(aDG2[1])->CHAVE    := AllTrim( If (len(AllTrim(cChave))>0, Substr(cChave, 1, (Int(len(AllTrim(cChave))/nTam)+1)*nTam), '') + cCodigo + SH3->H3_CODIGO + SH3->H3_OPERAC)
	(aDG2[1])->EXIBE    := .T.
	(aDG2[1])->CARGO    := DPRXCOUNT( 5, nCount++ )
	(aDG2[1])->IMAGE    := 'INSTRUME'
	(aDG2[1])->DG2_CDRT := SH3->H3_CODIGO
	(aDG2[1])->DG2_CDAT := SH3->H3_OPERAC 	
	
	IF Empty(SH3->H3_FERRAM) // Então é Recurso Alternativo
		(aDG2[1])->PROMP := UPPER( 'RECURSO ' + IF(SH3->H3_TIPO == 'A', 'ALTERNATIVO ', 'SECUNDÁRIO ') + AllTrim(SH3->H3_RECALTE) + ' - EFICIÊNCIA: ' + STR(DG2->DG2_VLEF))	
	Else // Então é Ferramenta Alternativa
		(aDG2[1])->PROMP := UPPER( 'FERRAMENTA ' + AllTrim(SH3->H3_FERRAM) )
	Endif
	
	For nI := 1 to len( aPCP )
		dbSelectArea( 'SX3' )
		SX3->( dbSetOrder( 2 ) )
		If SX3->( dbSeek( aPCP[nI][1] ) ) .And. ;
		   SX3->( dbSeek( aPCP[nI][2] ) )
		   
			If GetSx3Cache( aPCP[nI][2], 'X3_CONTEXT') != 'V'
				(aDG2[1])->&( aPCP[nI][2] ) := SH3->&( aPCP[nI][1] )
			EndIf
		EndIf
	Next
Endif

MsUnlock()

Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateTemp
Definição da Tabela Temporária

@param		cTabela		(Obrigatório) Nome da tabela física
@param 		cChave		Chave única da tabela
@param 		lTree		Define se é usado na tree
@return   	aReturn		Array de duas posições
						aReturn[1] = Alias da tabela criada (Objeto)
						aReturn[2] = Campos da tabela criada (Array)

@author	Ana Carolina Tomé Klock
@since 	24/01/2013
@version 	v12
/*///------------------------------------------------------------------------------------------------
Static Function CreateTemp( cTabela, cChave, lTree )
Local aTab 		:= {}
Local cArquivo
Local cAlias := GetNextAlias()
Local aAux      := {}
Local oTabela
Local aChave := {}
Local cCampo
Local Struct := FWFormStruct(3,cTabela)
Local nI := 0
Local nPos := 0
Default cChave 	:= ""
Default lTree	:= .F.

// Ao utilizar tree, cria um campo sequencial
If lTree
	aAdd( aTab, { 'NIVEL', 'C',   4, 0, 'Nivel na Tree' , .T., "9999" 	} )
	aAdd( aTab, { 'CHAVE', 'C', 800, 0, 'Chave da Tree' , .T., "@!" 	} )
	aAdd( aTab, { 'EXIBE', 'L',   1, 0, 'Exibe na Tree?', .T., "@!"		} )
	aAdd( aTab, { 'CARGO', 'C',   5, 0, 'Cargo do Item' , .T., "9999"	} )
	aAdd( aTab, { 'IMAGE', 'C',  25, 0, 'Imagem do Item', .T., "@!"		} )
	aAdd( aTab, { 'PROMP', 'C', 250, 0, 'Prompt do Item', .T., "@!"		} )
Else
	aAdd( aTab, { 'EXIBE', 'L',   1, 0, 'Exibe na Tree?', .T., "@!"		} )
EndIf

For nI := 1 to Len(Struct[1])

	cCampo := Struct[1][nI][3]
	nPos := Ascan(Struct[3],{|x|Alltrim(x[1]) == cCampo})

	If nPos > 0
	
		// Cria campo
		aAdd( aTab, { cCampo, Struct[1][nI][4], Struct[1][nI][5], Struct[1][nI][6], Struct[1][nI][1], .T., Struct[3][nPos][7]} )

		if cCampo == 'DGN_NRVRAC'
			aAux := { 'DGN_NRVROR', Struct[1][nI][4], Struct[1][nI][5], Struct[1][nI][6], Struct[1][nI][1], .T., Struct[3][nPos][7] }
		Endif
		
		if cCampo == 'DG3_CDACDV'
			aadd(aAux, { 'DG3_DVNOVO', Struct[1][nI][4], Struct[1][nI][5], Struct[1][nI][6], Struct[1][nI][1], .T., Struct[3][nPos][7] })
			aadd(aAux, { 'DG3_DENOVO', Struct[1][nI][4], Struct[1][nI][5], Struct[1][nI][6], Struct[1][nI][1], .T., Struct[3][nPos][7] })
		Endif
		
		if cCampo == 'DG0_CDACDV'
			aadd(aAux, { 'DG0_DVNOVO', Struct[1][nI][4], Struct[1][nI][5], Struct[1][nI][6], Struct[1][nI][1], .T., Struct[3][nPos][7] })
			aadd(aAux, { 'DG0_DENOVO', Struct[1][nI][4], Struct[1][nI][5], Struct[1][nI][6], Struct[1][nI][1], .T., Struct[3][nPos][7] })
		Endif
		
		IF cCampo == 'DG0_NRVRAC'
			aadd(aAux, { 'DG0_NROLD' , Struct[1][nI][4], Struct[1][nI][5], Struct[1][nI][6], Struct[1][nI][1], .T., Struct[3][nPos][7] })
		Endif
	Endif

Next nI

if cTabela == 'DGN'
	aadd(aTab, aAux)
	
	aAux := tamsx3('CZG_VRFH')
	
	aAdd( aTab, { 'DGN_VRFH', aAux[3], aAux[1], aAux[2], 'Versão', .T., x3Picture('CZG_VRFH')} )
ElseIf cTabela == 'DG3' .OR. cTabela == 'DG0'
	AADD(aTab,aAux[1])
	AADD(aTab,aAux[2])
	
	IF cTabela == 'DG0'
		AADD(aTab,aAux[3])
	Endif
ElseIf cTabela == 'DG2'
	// Campos para poder fazer o relacionamento entre os registros
	aAux := tamsx3('G2_CODIGO')	
	aAdd( aTab, { 'DG2_CDRT', aAux[3], aAux[1], aAux[2], 'Roteiro', .T., x3Picture('G2_CODIGO')} )
	aAux := tamsx3('G2_OPERAC')	
	aAdd( aTab, { 'DG2_CDAT', aAux[3], aAux[1], aAux[2], 'Roteiro', .T., x3Picture('G2_OPERAC')} )
	
	aAux := tamsx3('DG0_CDACDV')	
	aAdd( aTab, { 'DG2_CDACDV', aAux[3], aAux[1], aAux[2], 'Produto', .T., x3Picture('DG0_CDACDV')} )
	aAux := tamsx3('DG0_NRVRAC')
	aAdd( aTab, { 'DG2_NRVRAC', aAux[3], aAux[1], aAux[2], 'Versão', .T., x3Picture('DG0_NRVRAC')} )
ElseIf cTabela == 'DG9'
	aAux := tamsx3('G2_CODIGO')	
	aAdd( aTab, { 'DG9_CDRT', aAux[3], aAux[1], aAux[2], 'Roteiro', .T., x3Picture('G2_CODIGO')} )		
Endif

// Busca chave
If Empty( cChave )
	dbSelectArea( cTabela )
	cChave := Substr( IndexKey(1), 12 )
EndIf

if AT('+',cChave)	> 0
	aChave := STRTOKARR(cChave,"+")
	ASIZE(aChave,Len(aChave)+1)
Else
	AADD(aChave, cChave )
Endif

// Adiciona nível, se for tree
If lTree
	aChave := aIns(aChave,1)
	aChave[1] := 'NIVEL'
EndIf

// Abrindo arquivo
oTabela := FWTemporaryTable():New( cAlias )		
oTabela:SetFields( aTab )
oTabela:AddIndex("1", aChave )

if cTabela == 'DG2'
	oTabela:AddIndex("2", {'NIVEL', 'DG2_CDACDV', 'DG2_NRVRAC', 'DG2_IDAT', 'DG2_CDMQ', 'DG2_CDFE'} )
ElseIf lTree
	oTabela:AddIndex("2", {'NIVEL','CHAVE'} )
	oTabela:AddIndex("3", {'CARGO'} )
	
	if cTabela == 'DG0'
		oTabela:AddIndex("4", {'DG0_CDACDV'} )		
	Endif
Endif
	
oTabela:Create()

Return { cAlias, aTab, oTabela }

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetChavePCP
Busca para montar a chave da tabela temporária

@param 		cCodigo 		Codigo do Produto
@return		cChave			Chave da Árvore

@author		Ana Carolina Tomé Klock
@since 		08/02/2013
@version	v12
/*///------------------------------------------------------------------------------------------------
Static Function GetChavePCP( cCodigo )
Local nI
Local cChave 	:= ''
Local cVersion  := SPACE( TAMSX3('DG0_NRVRAC')[1] )
Local nNivel	:= ESTRUT->NIVEL
Default cCodigo := ESTRUT->CODIGO

ESTRUT->(dbGoTo(1))
For nI := 1 to ESTRUT->(RecCount())
	If Val(ESTRUT->NIVEL) == Val(nNivel)-1 .And. ESTRUT->COMP == cCodigo
		cChave := ESTRUT->CODIGO + cVersion
		cChave := GetChavePCP( ESTRUT->CODIGO ) + cChave
	EndIf
	ESTRUT->(dbGoTo(nI+1))
Next

Return cChave

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IsNodePCP
Busca o produto para verificar se contem filhos

@param 		cCodigo 		(Obrigatório) Código do Produto
@param		cChave			(Obrigatório) Chave do Produto
@return		nRet			Retorna a linha que contem o produto como pai

@author		Ana Carolina Tomé Klock
@since 		08/02/2013
@version	v12
/*///------------------------------------------------------------------------------------------------
Static Function IsNodePCP( cCodigo, cChave )
Local nRet := 1
Local nI

// Verifica se o pai ja foi adicionado
(aDG0[1])->(dbGoTo(1))
For nI := 1 to (aDG0[1])->(RecCount())
	If 	AllTrim( (aDG0[1])->DG0_CDACDV ) == AllTrim(cCodigo) .And.;
		AllTrim( (aDG0[1])->CHAVE ) == AllTrim(cChave)
	   	nRet:= 0
	   	Exit
	EndIf
	(aDG0[1])->(dbGoTo(nI+1))
Next

// Procura a linha do pai para adicionar
If nRet > 0
	nRet := 0
	ESTRUT->(dbGoTo(1))
	For nI := 1 to ESTRUT->(RecCount())
		If ESTRUT->CODIGO == cCodigo
	    	nRet := nI
	    	Exit
		EndIf
		ESTRUT->(dbGoTo(nI+1))
	Next
EndIf

Return nRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DPRNvlTree
Pega o número da tree inferior

@param 		cNivel	 		(Obrigatório) Nível da arvore
@param		nIncrement		Incremento a partir do nível
@return		cRet			Retorna o nível formatado

@author		Ana Carolina Tomé Klock
@since 		01/03/2013
@version	v12
/*///------------------------------------------------------------------------------------------------
Function DPRNvlTree( cNivel, nIncrement )
Default nIncrement := 0

Return Pad( cValToChar(Val(cNivel)+nIncrement), len(cNivel) )

//-------------------------------------------------------------------
/*/{Protheus.doc} DPExistCpo
Parametros cAlias:	Alias para verificacao                           
		   cValor:	Chave                                            
           nOrdem:	Indice (default = 1)   
@author  Thiago kobi Zoppi
@since   date
/*/
//-------------------------------------------------------------------
Function DPExistCpo(cAlias,cValor,nOrdem)
	Local aArea		:= (cAlias)->(GetArea())
	Local lRet 		:= .T.
	DEFAULT nOrdem	:= 01
	
	dbselectArea(cAlias)
	dbSetOrder(nOrdem)
	If dbSeek(xFilial(cAlias)+cValor)
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	RestArea(aArea)

Return lRet