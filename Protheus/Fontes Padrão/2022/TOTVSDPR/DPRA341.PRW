#INCLUDE 'DPRA341.CH'
#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} DPRA341
Tela de Aprova��o da Vers�o do Produto

@author Ana Carolina Tom� Klock
@since 01/02/2012
@version P12
/*/
//-----------------------------------------------------------------
Function DPRA341()
Local aValidaDPR := ValidaDPR()
Private oBrowse
Private aMark := {}

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA342', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG0')
oBrowse:AddMarkColumns( { || aAdd( aMark, .F.), 'LBNO' } ,  { || If (oBrowse:GetColumnData(1) == 'RPO_IMAGE=LBNO', oBrowse:ACOLUMNS[1]:BDATA := { || aMark[oBrowse:NCURSORPOS+1] := oBrowse:At(), 'LBTIK' }, oBrowse:ACOLUMNS[1]:BDATA := { || aMark[oBrowse:NCURSORPOS+1] := .F.,'LBNO'} )} )
oBrowse:SetDescription( STR0001 ) // Aprova��o de Vers�o Produto
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	If IsInCallStack('DPRA341')
		aAdd( aRotina, { STR0002, 'DPRA341SIT(3)'	, 0, 4, 0, .F. } ) //'Aprovar Estrutura'
		aAdd( aRotina, { STR0003, 'DPRA341SIT(4)'	, 0, 4, 0, .F. } ) //'Aprovar Opera��o'
		aAdd( aRotina, { STR0004, 'DPRA341SIT(5)'	, 0, 6, 0, .F. } ) //'Reabrir Estrutura'
		aAdd( aRotina, { STR0005, 'DPRA341SIT(6)'	, 0, 6, 0, .F. } ) //'Reabrir Opera��o'
		aAdd( aRotina, { STR0006, 'DPRA341SIT(2)'	, 0, 6, 0, .F. } ) //'Suspender'
		aAdd( aRotina, { STR0019, 'DPRA341SIT(1)'	, 0, 6, 0, .F. } ) //'Reabrir Suspens�o'
		aAdd( aRotina, { STR0007, 'DPRC300()'		, 0, 2, 0, NIL } ) //'Hist�rico Aprov.'
		aAdd( aRotina, { STR0020, 'VIEWDEF.DPRA300', 0, 4, 0, NIL } ) //'Verificar Crit�rios'
		aAdd( aRotina, { STR0008, 'VIEWDEF.DPRA341', 0, 8, 0, NIL } ) //'Imprimir'
	EndIf
Return aRotina
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDG0 := FWFormStruct( 1, 'DG0', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG1 := FWFormStruct( 1, 'DG1', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA341', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'DG0MASTER', /*cOwner*/, oStructDG0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'DG1DETAIL', 'DG0MASTER', oStructDG1, /*bPreLine*/, /*bPosLine*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'DG1DETAIL', { { 'DG1_FILIAL', 'xFilial( "DG1" )' }, { 'DG1_CDACDV', 'DG0_CDACDV' }, { 'DG1_NRVRAC', 'DG0_NRVRAC'} }, DG1->( IndexKey(1)) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados da Vers�o'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DG0MASTER' ):SetDescription( STR0010 ) // 'Dados da Vers�o'
oModel:GetModel( 'DG1DETAIL' ):SetDescription( STR0011 ) // 'Dados da Estrutura da Vers�o'

// Indica que � opcional ter dados informados na Grid
oModel:GetModel( 'DG1DETAIL' ):SetOptional(.T.)

Return oModel
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA341' )
// Cria a estrutura a ser usada na View
Local oStructDG0 := FWFormStruct( 2, 'DG0' )
Local oStructDG1 := FWFormStruct( 2, 'DG1' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DG0', oStructDG0, 'DG0MASTER' )

// Adiciona no nosso View um controle do tipo FormGrid (antiga newgetdados)
oView:AddGrid(  'VIEW_DG1', oStructDG1, 'DG1DETAIL' )

// Cria um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DG0', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_DG1', 'INFERIOR' )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} MudaSitVer
Fun��o para mudar a situa��o da vers�o

@param		nI			(Obrigat�rio) N�mero referente a posi��o da linha com o mark
			nTPST		(Obrigat�rio) Situa��o da vers�o
						2 = Suspens�o da Vers�o
						3 = Aprova��o de estrutura
						4 = Aprova��o de atividade
						5 = Reabrir estrutura
						6 = Reabrir atividade
			aProducts  (Obrigat�rio) Array com os produtos

@author Ezequiel Ramos
@since 14/11/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function MudaSitVer(nI,nTPST,aProducts)
	Local lHist	:= SuperGetMV('MV_DPRHIST',.F.,.F.)
	Local lRet		:= .T.

	If( nI != 0 )
		oBrowse:GoTo(aMark[nI], .F.)
	EndIf
	
	//Verficar se Existem Ordem Aberta
	If (nTPST == 5 .OR. nTPST == 6)
		If !GetSC2Open( DG0->DG0_CDACDV )
			DPRXError( 'DPRA340', 'DPRA340_OPABER', 3 )
			Return .T.
		EndIf
	Endif

	// Se tentar reabrir uma vers�o liberada e estiver salvando hist�rico
	If lHist .And. (nTPST == 5 .OR. nTPST == 6) .And. DG0->DG0_TPST > '5'
		DPRXError('DPRA341', 'DPRA341_HIST', 3 )
		lRet := .F.
	Endif

	// Realiza a valida��o para continuar
	If lRet .And. ( nTPST == 3 .Or. nTPST == 4 )
  		dbSelectArea( 'DG1' )
		dbSetOrder(1)
		If dbSeek( xFilial('DG1') + DG0->DG0_CDACDV + DG0->DG0_NRVRAC )
			While DG1->( !EOF() )
			   	If DG1->DG1_CDACDV == DG0->DG0_CDACDV .And. DG1->DG1_NRVRAC == DG0->DG0_NRVRAC .And. !Empty(DG1->DG1_CDMTDV)
				   	If !MsgYesNo(STR0012 + AllTrim(DG0->DG0_CDACDV) + STR0013 + AllTrim(DG0->DG0_NRVRAC) + '?','DPRA341') // Deseja replicar a a��o para os componentes relacionados ao produto  #  com vers�o #
						lRet := .F.
						DPRXError('DPRA341', 'DPRA341_COMPON', 3 )
					EndIf
					Exit
			   	EndIf
			   	DG1->( dbSkip() )
			End
			EndIf
	EndIf

	// Monta um vetor com todos os produtos a serem alterados
	If lRet
		DPR341FIND( cValToChar(nTPST), @aProducts )
	EndIf

	If( nI != 0 )
		// Limpa a marca��o
		oBrowse:ACOLUMNS[1]:BDATA := { || 'LBNO' }
		aMark[nI] := .F.
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA341SIT
Fun��o para mudar a situa��o da vers�o

@param 		nTPST		(Obrigat�rio) Situa��o da vers�o
						2 = Suspens�o da Vers�o
						3 = Aprova��o de estrutura
						4 = Aprova��o de atividade
						5 = Reabrir estrutura
						6 = Reabrir atividade

@author Ana Carolina Tom� Klock
@since 05/07/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA341SIT( nTPST )
	Local nI			:= 0
	Local lHist  		:= SuperGetMV('MV_DPRHIST',.F.,.F.)
	Local aProducts	:= {}
	Local aLinhas		:= {}
	//L� todas as linhas
	For nI := 1 to len( aMark )
		// Caso a linha tenha sido marcada, tem o Recno()
		If ValType( aMark[nI] ) == 'N'
			aAdd(aLinhas,nI)
		EndIf
	Next
	//Se n�o possuir nenhuma linha marcada, muda a situa��o da linha posicionada
	If Len(aLinhas) == 0
		MudaSitVer(0,nTPST,@aProducts)
	//Se houver, muda a situa��o de todas as linhas
	Else
		For nI := 1 to Len(aLinhas)
			MudaSitVer(aLinhas[nI],nTPST,@aProducts)
		Next
	EndIf
	//Posiciona na linha sem atualizar o browse
	If !Empty( aProducts )
		For nI := 1 to Len( aProducts )
			DPRA341SAV( aProducts[nI][1], aProducts[nI][2], aProducts[nI][3] )
			// Guarda o hist�rico de aprova��o
			If lHist
				DPRA341HIS( aProducts[nI][1], aProducts[nI][2], aProducts[nI][3] )
			EndIf
		Next
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} DPR341FIND
Busca todos os produtos que ser�o atualizados

@param		nTPST		(Obrigat�rio) Situa��o da vers�o
						1 - Aberto
						2 - Suspenso
						3 - Aprovado Estrutura
						4 - Aprovado Atividades
						5 - Reabrir Estrutura
						6 - Reabrir Atividade
@param 		aProducts	(Obrigat�rio) Vetor com os produtos atualizados

@author Ana Carolina Tom� Klock
@since 05/07/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPR341FIND( cTPST, aProducts )
	Local nI
	Local lRet 	:= .F.
	Local lFirst	:= !IsInCallStack("DPRA341SON")

	// Valida crit�rios se estiver aprovando
	If cTPST == '3' .Or. cTPST ==  '4'
	    lRet := DPRA341CRI( DG0->DG0_CDACDV, DG0->DG0_NRVRAC )
	    If !lRet
	    	DPRXError('DPRA341', 'DPRA341_CRIT', 3 ) 	// Os crit�rios do produto  #  com a vers�o  #  ainda est�o pendentes
	    	aProducts := {}
	    EndIf
	Else
		lRet := .T.
	EndIf

	// Procura se o produto j� foi modificado
	For nI := 1 to len( aProducts )
		If aProducts[nI][1] == DG0->DG0_CDACDV .And. aProducts[nI][2] == DG0->DG0_NRVRAC
			lRet := .F.
			Exit
		EndIf
	Next

	// Muda estado
	If lRet
		// Suspendendo uma vers�o aberta
		If 	( (DG0->DG0_TPST == '0' .OR. DG0->DG0_TPST == '1') .And. cTPST == '2')
			aAdd( aProducts, { DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cTPST } )
			DPRA341SON( cTPST, @aProducts )

	 	//Reabrindo vers�o suspensa
	 	ElseIf ( Val(DG0->DG0_TPST) == 2 .And. cTPST == '1' )
	 		aAdd( aProducts, { DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cTPST } )
	 		DPRA341SON( cTPST, @aProducts )

	 	// Reabrindo vers�o liberada
	 	ElseIf ( Val(DG0->DG0_TPST) > 5 .And. ( cTPST == '5' .Or. cTPST == '6' ) )
	   		aAdd( aProducts, { DG0->DG0_CDACDV, DG0->DG0_NRVRAC, '1' } )

		// Aprovando estrutura/opera��o/processo
		ElseIf 	(cTPST == '3' .Or. cTPST == '4') .And. ;
				((DG0->DG0_TPST == '1' .Or. DG0->DG0_TPST == '3' .Or. DG0->DG0_TPST == '4') .And. (DG0->DG0_TPST != cTPST))
			aAdd( aProducts, { DG0->DG0_CDACDV, DG0->DG0_NRVRAC, If (DG0->DG0_TPST == '1', cTPST, '5') } )
			DPRA341SON( cTPST, @aProducts )

		// Reabrindo estrutura
		ElseIf (cTPST == '5' .And. (DG0->DG0_TPST == '3' .Or. DG0->DG0_TPST == '5'))
			aAdd( aProducts, { DG0->DG0_CDACDV, DG0->DG0_NRVRAC, If (DG0->DG0_TPST == '3', '1', '4') } )
			DPRA341SON( cTPST, @aProducts )

		// Reabrindo opera��o
		ElseIf (cTPST == '6' .And. (DG0->DG0_TPST == '4' .Or. DG0->DG0_TPST == '5'))
			aAdd( aProducts, { DG0->DG0_CDACDV, DG0->DG0_NRVRAC, If (DG0->DG0_TPST == '4', '1', '3') } )
			DPRA341SON( cTPST, @aProducts )

		// Senao, avisa que foi imposs�vel
		ElseIf lFirst
			// Reaberturas
			If cTPST == '5' .Or. cTPST == '6'
				alert( AllTrim(DG0->DG0_CDACDV) + STR0024 + AllTrim(DG0->DG0_NRVRAC) + STR0026 ) // ' na vers�o ' ### ' n�o pode ser reaberta.'
				lRet := .F.
			// Demais
			Else
				//Se a situa��o estava suspensa e foi clicado em suspender, n�o precisa apresentar alerta
				If cTPST != "2" .Or. DG0->DG0_TPST != "2"
					alert( AllTrim(DG0->DG0_CDACDV) + STR0024 + AllTrim(DG0->DG0_NRVRAC) + STR0025 + X3COMBO('DG0_TPST', cTPST) + "'" )  // ' na vers�o ' ### ' n�o pode ter sua situa��o como "'
				EndIf
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA341SON
Fun��o que busca os filhos para adicionar ao vetor

@param		nTPST		(Obrigat�rio) Situa��o da vers�o
						1 - Aberto
						2 - Suspenso
						3 - Aprovado Estrutura
						4 - Aprovado Atividades
						5 - Reabrir Estrutura
						6 - Reabrir Atividade
@param 		aProducts	(Obrigat�rio) Vetor com os produtos atualizados

@author Ana Carolina Tom� Klock
@since 09/07/2012
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRA341SON( cTPST, aProducts )
Local oModelDG0	:= FWLoadModel( 'DPRA341' )
Local oModelDG1 := oModelDG0:GetModel():GetModel('DG1DETAIL')
Local nI, aAreaDG0, aAreaDG1
Local lRet		:= .T.

// Abre modelo
oModelDG0:SetOperation( 4 )
oModelDG0:Activate()

// Caso abertura ou aprova��o
If cTPST == '1' .Or. cTPST == '3' .Or. cTPST == '4'
	For nI := 1 to oModelDG1:Length()
		If !Empty( oModelDG1:GetValue('DG1_CDMTDV', nI) )
			lRet := .T.

			// Desce n�vel
			If lRet
				aArea := DG0->(GetArea())
				dbSelectArea('DG0')
				If DG0->(dbSeek( xFilial('DG0') + oModelDG1:GetValue('DG1_CDMTDV', nI) + oModelDG1:GetValue('DG1_NRVRMT', nI) ) )
					DPR341FIND( cTPST, @aProducts )
				EndIf
				RestArea( aArea )
			EndIf
		EndIf
	Next

// Caso suspens�o ou reabertura
ElseIf cTPST == '2' .Or. cTPST == '5' .Or. cTPST == '6'
	dbSelectArea('DG1')
	DG1->( dbSetOrder(2) )
	If dbSeek( xFilial('DG1') + DG0->DG0_CDACDV + DG0->DG0_NRVRAC )
		While DG1->( !EOF() )

			// Sobe n�vel
			If DG0->DG0_CDACDV == DG1->DG1_CDMTDV .And. DG0->DG0_NRVRAC == DG1->DG1_NRVRMT
				aAreaDG0 := DG0->(GetArea())
				aAreaDG1 := DG1->(GetArea())
				dbSelectArea('DG0')
				If DG0->( dbSeek( xFilial('DG0') + DG1->DG1_CDACDV + DG1->DG1_NRVRAC ))
			   		DPR341FIND( cTPST, @aProducts )
			 	EndIf
			 	RestArea( aAreaDG1 )
			 	RestArea( aAreaDG0 )
			EndIf
			DG1->( dbSkip() )
		End
	EndIf
EndIf

oModelDG0:DeActivate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA341SAV
Fun��o para salvar as modifica��es realizadas nas vers�es

@param 		cCDACDV		(Obrigat�rio) C�digo do Produto
@param		cNRVRAC		(Obrigat�rio) Vers�o do Produto
@param		cTPST		(Obrigat�rio) Situa��o do Produto

@param 		lRet		Retorna se a grava��o foi realizada com sucesso

@author Ana Carolina Tom� Klock
@since 15/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA341SAV( cCDACDV, cNRVRAC, cTPST )
Local lRet := .T.
Local oModelDG0

Begin Transaction

	// Busca na base de dados
	dbSelectArea('DG0')
	If DG0->( dbSeek( xFilial('DG0') + cCDACDV + cNRVRAC ) )
	
		// Salva altera��es
		oModelDG0 := FWLoadModel( 'DPRA341' )
		oModelDG0:SetOperation( 4 )
		oModelDG0:Activate()
		oModelDG0:SetValue( 'DG0MASTER', 'DG0_TPST', cTPST )
		If oModelDG0:VldData()
			
			//Se alterar a situa��o para 5, verifica se existe pendencia para ser aprovada
			If cTPST == "5"
				If FindFunction("DPRA350AVP")
					lRet := DPRA350AVP(cCDACDV,cNRVRAC)
				EndIf
			ElseIf cTPST == "2"
				If FindFunction("DPRA350SVP") .AND. !IsInCallStack("DPRA350SVP") .and. !IsInCallStack('DPRA350DLP')
					lRet := DPRA350SVP(cCDACDV,cNRVRAC)
				EndIf
			EndIf
			
			if lRet
				oModelDG0:CommitData()
			Endif
		Else
			aErro := oModelDG0:GetErrorMessage()
			DPRXError('DPRA341', aErro[6])
			lRet := .F.
		EndIf
		oModelDG0:DeActivate()
	EndIf
	
	if !lRet
		DisarmTransaction()
	Endif
	
End Transaction 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA341HIS
Fun��o para guardar o hist�rico da aprova��o da vers�o

@param 		cCDACDV		(Obrigat�rio) C�digo do Produto
@param		cNRVRAC		(Obrigat�rio) Vers�o do Produto
@param		cTPST		(Obrigat�rio) Situa��o do Produto

@return 	lRet		Retorna se a grava��o foi realizada com sucesso

@author Ana Carolina Tom� Klock
@since 10/07/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA341HIS( cCDACDV, cNRVRAC, cTPST )
Local oModel
Local lRet := .T.

oModel := FWLoadModel( 'DPRC300' )
oModel:SetOperation( 3 )
oModel:Activate()
oModel:SetValue( 'DGLMASTER', 'DGL_CDACDV', cCDACDV )
oModel:SetValue( 'DGLMASTER', 'DGL_NRVRDV', cNRVRAC )
oModel:SetValue( 'DGLMASTER', 'DGL_TPST'  , cTPST	)
If oModel:VldData()
	oModel:CommitData()
Else
	aErro := oModel:GetErrorMessage()
	DPRXError('DPRA341', aErro[6])
	lRet := .F.
EndIf
oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA341CRI
Fun��o para verificar se os crit�rios foram aprovados/rejeitados

@param 		cCDACDV		(Obrigat�rio) C�digo do Produto
@param		cNRVRAC		(Obrigat�rio) Vers�o do Produto

@return 	lRet		Retorna .T. caso n�o tenha crit�rios pendentes

@author Samantha Preima
@since 31/01/2013
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA341CRI( cCDACDV, cNRVRAC )
Local lRet := .T.

If GetMV('MV_DPRLIST',.F.,.F.) == .T.

	dbSelectArea('DGJ')
	DGJ->( dbSetOrder(1) )
	If DGJ->( dbSeek( xFilial('DGJ') + cCDACDV + cNRVRAC ) )

		While DGJ->(!EOF()) .And. DGJ->DGJ_CDACDV == cCDACDV .And. DGJ->DGJ_NRVRAC == cNRVRAC
			If DGJ->DGJ_TPAPJZ == '1'
				lRet := .F.
				Exit
			EndIf
			DGJ->(dbSkip())
		End

	EndIf

EndIf

Return lRet
