#INCLUDE 'DPRA340.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#DEFINE PULALINHA CHR(13)+CHR(10)

//-----------------------------------------------------------------
/*/{Protheus.doc} DPRA340
Tela de Geração de Ordem

@author Ana Carolina Tome Klock
@since 23/03/2012
@version P12
/*/
//-----------------------------------------------------------------
Function DPRA340()
Local aCampos := {{ STR0001, { || DG0->DG0_CDACDV }, 'C', '', TamSX3('DG0_CDACDV')[1] },  ;      // 'Prod Desenvolvido'
				   	{ STR0002, { || DG0->DG0_NRVRAC }, 'C', '', TamSX3('DG0_NRVRAC')[1] },  ;      // 'Versão Produto'
				   	{ STR0003, { || DG0->DG0_DSVR   }, 'C', '', TamSX3('DG3_DSACDV')[1] },  ;      // 'Descrição Produto'
				   	{ STR0004, { || X3Combo( 'DG0_TPST', DG0->DG0_TPST )  }, 'C', '', TamSX3('DG0_TPST'  )[1] },  ;      // 'Situação'
			       	{ STR0005, { || Posicione('DG3', 1, xFilial('DG3') + DG0->DG0_CDACDV, 'DG3_CDACPY') }	, 'C', '', TamSX3('DG3_CDACPY')[1] },  ;      // 'Produto Protótipo'
			       	{ STR0006, { || Posicione('CZ3', 1, xFilial('CZ3') + Posicione('DG3', 1, xFilial('DG3') + DG0->DG0_CDACDV, 'DG3_CDACPY'), 'CZ3_DSAC') }, 'C', '', TamSX3('CZ3_DSAC')[1] },  ;   // 'Desc Prod Protót'
			       	{ STR0007, { || Posicione('DG3', 1, xFilial('DG3') + DG0->DG0_CDACDV, 'DG3_CDUN'  ) }	, 'C', '', TamSX3('DG3_CDUN'  )[1] },;        // 'Unidade de Medida'
			       	{ STR0005, { || DG0->DG0_CDACPY }, 'C', '', TamSX3('DG0_CDACPY')[1] },; // 'Produto Protótipo'
			       	{ STR0006, { || Posicione('CZ3', 1, xFilial('CZ3') + DG0->DG0_CDACPY, 'CZ3_DSAC') }     , 'C', '', TamSX3('CZ3_DSAC')[1] }} // 'Desc Prod Protót'
Local aValidaDPR := ValidaDPR()

AjustaHelp()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA340', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG0')
oBrowse:SetOnlyFields( { '' } )
oBrowse:SetFields( aCampos )
oBrowse:AddLegend( '!Empty(DPExistDGH()[2])', 'BR_AZUL'		, STR0029 ) // 'Com ordens'
oBrowse:AddLegend( '!DPRA340VdO()'       , 'BR_LARANJA'	, STR0030 ) // 'Sem operações'
oBrowse:AddLegend( 'Empty(DPExistDGH()[2]) .And. DPRA340VdO()' , 'BR_BRANCO'	, STR0031 ) // 'Sem ordens'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0008, 'PesqBrw'		, 0, 1, 0, NIL } ) //'Pesquisar'
	aAdd( aRotina, { STR0009, 'DPRA340INT(3)'	, 0, 2, 0, .F.} ) //'Gerar Ordem'
	aAdd( aRotina, { STR0028, 'DPRA344()'		, 0, 2, 0, NIL } ) //'Ordens Relacionadas'
	aAdd( aRotina, { STR0034, 'DPRA340LEG()'	, 0, 6, 0, NIL } ) //'Legenda'
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDGH := FWFormStruct( 1, 'DGH', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG6 := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA340', /*bPreValidacao*/, { |oModel| DPRA340POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DGHMASTER', /*cOwner*/, oStructDGH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'DG6DETAIL', 'DGHMASTER', oStructDG6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'DG6DETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DGH_IDNV'   } }, DG6->(IndexKey(1)) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'DG6DETAIL' ):SetNoInsertLine()

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'DG6DETAIL' ):SetOptional(.T.)

// Inclui a obrigatoriedade dos campos quando estiver integrando com o PCP
If DPRIntegra() == 1
	oStructDG6:SetProperty( 'DG6_IDNV'  , MODEL_FIELD_OBRIGAT,  .F. )
EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA340' )
// Cria a estrutura a ser usada na View
Local oStructDGH := FWFormStruct( 2, 'DGH' )
Local oStructDG6 := FWFormStruct( 2, 'DG6' )

// Cria o objeto de View
oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DGH', oStructDGH, 'DGHMASTER' )

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_DG6', oStructDG6, 'DG6DETAIL' )

// Cria um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_DGH', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_DG6', 'INFERIOR' )

// Remove o campo repetido em tela
oStructDGH:RemoveField( 'DGH_IDNV'   )
oStructDG6:RemoveField( 'DG6_IDNV'   )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA100POS
Realiza a pos-validacao dos dados da tela

@param 		oModel		Modelo de dados da tela
@return 	lRet		Informa se a tela está pronta para realizar o Commit

@author Ana Carolina Tome Klock
@since 11/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA340POS( oModel )
Local lRet       := .T.

// Define o valor da narrativa
If oModel:GetOperation() == 3
 	oModel:GetModel('DGHMASTER'):LoadValue('DGH_IDNV', FwFldGet('DG6_IDNV') )
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA340INT
Realiza a criação da ordem nos sistemas integrados

@param		nOpc		Define o tipo de operação que será executada
						3 - Criação da Ordem
						4 - Alteração da Ordem
						5 - Exclusão da Ordem

@author Ana Carolina Tome Klock
@since 20/07/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA340INT( nOpc )
Local nI := 1, nJ 	:= 1, nK
Local nFinalStr		:= 0
Local cNRORPO, nAux	:= 1
Local cItem         := '01'
Local aCampos			:= {}
Local aMata650		:= {}
Local aMata380		:= {}
Local oLBNO   		:= LoadBitmap(GetResources(),'LBNO')
Local oLBTIK  		:= LoadBitmap(GetResources(),'LBTIK')
Local lClose			:= .T.
Local lRet				:= .T.
Local lGera			:= .T.
Local lSemProt		:= .F.
Local lSemRot			:= .F.
Local lSemCZ3			:= .F.
Local lComDG3			:= .F.
Local lSemOper		:= .F.
Local lMV_DPRQIP		:= SuperGetMV("MV_DPRQIP",.F.,.F.)
Local cLog := cIDNV	:= ''
Local cVerSemPro		:= ''
Local cProSemCZ3		:= ''
Local cProComDG3		:= ''
Local cVerSemRot		:= ''
Local cProSemOpe		:= ''
Local nTam 			:= TamSX3('C2_NUM')[1]+TamSX3('C2_ITEM')[1]
Local nQuant			:= 0
Local nTamOP            := TamSX3("D4_OP")[1]
Local oModel
Local cNewCR
Local cProt          := ''
Local cDepos         := ''
Local cFilDGH        := ''
Local cAliasDGP      := GetNextAlias()
Local aRetorno       := {}
Local aAreaDG0       := DG0->(GetArea())
Local lExistDP340SC2 := ExistBlock('DP340SC2')
Local nProd, nSeqProd
Local cSeqProd		 := ""
Private aDG1         := {}
Private lMsErroAuto  := .F.
Default lAutomacao 	 := .F.

// Cria a ordem apenas se as operações da versão estiverem aprovadas
If nOpc == 3
	If DPRIntegra() == 1
		If Val(DG0->DG0_TPST) < 4  .Or. DG0->DG0_TPST == '6'
			DPRXError( 'DPRA340', 'DPRA340_APROV', 3)  // A versão deve estar com as operações aprovadas para gerar a ordem. ## Verifique se a situação da versão está com as operações ou o processo aprovado.
			Return .T.
		ElseIf !DPRA340VdO()
			Help( ,, 'HELP', 'DPRA340', STR0044, 1, 0)//"Esta versão não possui operações cadastradas."
			Return .T.
		EndIf
	EndIf
EndIf

// Se estiver criando ou alterando
If nOpc == 3 .Or. nOpc == 4
	// Verifica se a criação de Ordem Protótipo é desaconselhada.
	If !SuperGetMV("MV_PCPATOR",.F.,.F.)
		If !lAutomacao
			If !MsgYesNo( STR0038 ,"DPRA340" )//Parâmetro MV_PCPATOR não está ativo. A criação de Ordem Protótipo é desaconselhada. Deseja continuar?
				Return .F.
			EndIf
		EndIf
	EndIf

	// Verifica se existem ordem para o produto encerrada
	If nOpc == 3
		If !GetSC2Open( DG0->DG0_CDACDV )

		  	DPRXError( 'DPRA340', 'DPRA340_OPABER', 3 )
			Return .T.
		EndIf
		cNRORPO := ''

		// Se já existir pendência, deverá criar para a mesma filial
		If DPRXComp(2)
			BeginSql Alias cAliasDGP

				Select * from %Table:DGP% DGP
					WHERE DGP.DGP_CDACDV=%Exp:DG0->DG0_CDACDV% AND
						  DGP.DGP_NRVRAC=%Exp:DG0->DG0_NRVRAC% AND
						  DGP.%NotDel%
			EndSql

			if !Empty((cAliasDGP)->DGP_IDIC) .AND. (cAliasDGP)->DGP_FILIAL != xFilial('DGP')
				// Avisar o usuário para trocar a empresa
				DPRXError( 'DPRA340', STR0046 + (cAliasDGP)->DGP_FILIAL, 1, STR0047 ) // Foi encontrada pendência na filial ## 'Acesse o módulo SIGADPR através desta filial.'

				Return .F.
			Else
				(cAliasDGP)->(dbCloseArea())
			Endif
		Endif
	EndIf

	// Verifica quantidade informada
	While ( nQuant <= 0 .And. lClose )
		lClose := Pergunt340() //Pergunte( 'DPRA340' )
		nQuant := lClose[2]
		cLog   := lClose[3]

		// Exibe erro ao informar quantidade invalida
		If nQuant <= 0
			DPRXError( 'DPRA340', 'DPRA340QTD', 3 )
		EndIf

		// Sai da tela ao fechar o pergunte
		If !lAutomacao	
			If !lClose[1]
				Return .T.
			EndIf
		EndIf
	End

	// Posiciona no item
	If nOpc == 4
		dbSelectArea('DG0')
		DG0->( dbSetOrder(1) )
		DG0->( dbSeek( xFilial('DG0') + DGH->DGH_CDACDV + DGH->DGH_NRVRAC ) )
	EndIf

	// Adiciona o produto pai no array de estrutura
	aAdd( aCampos, { .T., DG0->DG0_CDACDV, DG0->DG0_NRVRAC, nQuant, '' } )

	// Busca estrutura do produto pai
	DPRASTRUCT( DG0->DG0_CDACDV, DG0->DG0_NRVRAC, { .T., .F., .F., .F., .T., .F. } )

   	// Adiciona filhos no array de estrutura
	DbSelectArea( (aDG1[1]) )
	(aDG1[1])->(DBGOTOP())

	While ! (aDG1[1])->(EOF())
		If !Empty( (aDG1[1])->DG1_CDMTDV )
			//VALIDAR SE COMP JÁ EXISTE
			nPos	:= Ascan(aCampos, {|x| x[2]==(aDG1[1])->DG1_CDMTDV } )

			If nPos > 0
				aCampos[nPos][4] += nQuant * DPRXTRIG('340')
			Endif

			If  nPos = 0 .And. DPRA340VdO((aDG1[1])->DG1_CDMTDV,(aDG1[1])->DG1_NRVRMT)
				aAdd( aCampos, { .T., (aDG1[1])->DG1_CDMTDV, (aDG1[1])->DG1_NRVRMT, nQuant * DPRXTRIG('340'), (aDG1[1])->CHAVE } )
			EndIf

		Endif
		(aDG1[1])->(dbSkip())
	End

	(aDG1[1])->(dbCloseArea())

	// Abre a tela com todos os componentes desenvolvidos
	lClose := .T.
	If !lAutomacao	
		DEFINE DIALOG oDlg TITLE STR0011 FROM 180,180 TO 530,700 PIXEL    // 'Gerar Ordem Protótipo'

		// Cria Browse
		oBrowse := TCBrowse():New( 01 , 01, 260, 156,,{'',STR0012,STR0013,STR0014},{5,130,50,30},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  // 'Produto' ### 'Versão' ### 'Quantidade'

		// Seta array para o browse
		oBrowse:SetArray(aCampos)

		// Monta a linha a ser exibina no Browse
		oBrowse:bLine := { || { If (aCampos[oBrowse:nAt,1], oLBTIK, oLBNO ),;
									aCampos[oBrowse:nAt,2],;
									aCampos[oBrowse:nAt,3],;
								Transform(aCampos[oBrowse:nAT,4], GetSx3Cache("DG1_QTUT","X3_PICTURE")) } }

		// Evento de duplo click na celula
		oBrowse:bLDblClick  := { || If (oBrowse:nAt != 1, aCampos[oBrowse:nAt,1] := !aCampos[oBrowse:nAt,1], Nil), oBrowse:SetFocus() }

		// Cria botões com métodos básicos do Browse
		TButton():New( 160, 175, STR0015, oDlg,{|| lClose := .F., oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // 'Gerar Ordens'
		TButton():New( 160, 220, STR0016, oDlg,{|| oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )             // 'Cancelar'

		ACTIVATE DIALOG oDlg CENTERED
	EndIf

	// Quando integrado com SIGAPCP
	If !lClose .And. DPRIntegra() == 1
		If nOpc == 3
	   		For nI := 2 to len( aCampos )
				If aCampos[nI][1]
					aRetorno := DPExistDGH( aCampos[nI][2] )

					cFilDGH := aRetorno[1]
			   		cNRORPO := aRetorno[2]
					If !Empty( cNRORPO ) .And. !( DPExistSC2( 5, cFilDGH, cNRORPO ) .Or. DPExistSC2( 6, cFilDGH, cNRORPO ) )//Corrigida ordem dos parametros
					  	DPRXError( 'DPRA340', 'DPRA340_ABERTA', 3 )
						Return .T.
					EndIf
					cNRORPO := ''
				EndIf
			Next nI
		EndIf

		dbSelectArea('CZ3')
		CZ3->( dbSetOrder(1))
		dbSelectArea('DG3')
		DG3->( dbSetOrder(2))

		For nI := 1 to len( aCampos )
			If aCampos[nI][1]
				cCDACPY	:= POSICIONE( 'DG0', 1, xFilial('DG0')+aCampos[nI][2]+aCampos[nI][3], 'DG0_CDACPY' )
				//Se uma versão que não possui produto protótipo tiver sido marcada, informa ao usuário e interrompe a execução
				If Empty(cCDACPY)
					cVerSemPro	+= AllTrim(aCampos[nI][2]) + " " + AllTrim(aCampos[nI][3]) + PULALINHA
					lSemProt	:= .T.
				//Se uma versão que não possui produto protótipo cadastrado na CZ3 tiver sido marcada
				ElseIf !CZ3->( dbSeek(xFilial('CZ3')+cCDACPY))
					cProSemCZ3	+= AllTrim(aCampos[nI][2]) + " " + AllTrim(aCampos[nI][3]) + PULALINHA
					lSemCZ3	:= .T.
				//Se uma versão que não possui produto protótipo cadastrado na CZ3 tiver sido marcada
				ElseIf DG3->( dbSeek(xFilial('DG3')+cCDACPY))
					cProComDG3	+= AllTrim(aCampos[nI][2]) + " " + AllTrim(aCampos[nI][3]) + PULALINHA
					lComDG3	:= .T.
				//Se uma versão que não possui operações tiver sido marcada
				ElseIf !DPRA340VdO(aCampos[nI][2],aCampos[nI][3])
					cProSemOpe	+= AllTrim(aCampos[nI][2]) + " " + AllTrim(aCampos[nI][3]) + PULALINHA
					lSemOper	:= .T.
				//Se uma versão que não possui roteiro tiver sido marcada e o parametro MV_DPRQIP estiver ativo, informa ao usuário e interrompe a execução
				ElseIf Empty(POSICIONE( 'DG0', 1, xFilial('DG0')+aCampos[nI][2]+aCampos[nI][3], 'DG0_CDRT' ))
					cVerSemRot	+= AllTrim(aCampos[nI][2]) + " " + AllTrim(aCampos[nI][3]) + PULALINHA
					lSemRot	:= .T.
				EndIf
			EndIf
		Next

		If lSemProt
			Help( ,, 'HELP', 'DPRA340', STR0039+PULALINHA+cVerSemPro, 1, 0)//"A(s) versão(ões) selecionada(s) seguinte(s) não possui(em) produto protótipo cadastrado:"
			Return .F.
		EndIf
		If lSemCZ3
			Help( ,, 'HELP', 'DPRA340', STR0040+PULALINHA+cProSemCZ3, 1, 0)//"A(s) versão(ões) selecionada(s) seguinte(s) possui(em) um produto protótipo que não está cadastrado no módulo PCP:"
			Return .F.
		EndIf
		If lComDG3
			Help( ,, 'HELP', 'DPRA340', STR0041+PULALINHA+cProComDG3, 1, 0)//"A(s) versão(ões) selecionada(s) seguinte(s) possui(em) um produto protótipo cadastrado como produto destino:"
			Return .F.
		EndIf
		If lSemOper
			Help( ,, 'HELP', 'DPRA340', STR0045+PULALINHA+cProSemOpe, 1, 0)//"A(s) versão(ões) selecionada(s) seguinte(s) não possui(em) operações cadastradas:"
			Return .F.
		EndIf
		/*If lMV_DPRQIP .AND. lSemRot
			If !MsgYesNo(STR0042+PULALINHA+cVerSemRot+PULALINHA+STR0043 ,"DPRA340")//"A(s) versão(ões) selecionada(s) seguinte(s) não possui(em) roteiro informado para o produto protótipo cadastrado:" "Deseja Continuar?"
				Return .F.
			EndIf
		EndIf */

		BEGIN TRANSACTION

		// Pega o número da ordem a ser gerada
		If nOpc == 3
			cNRORPO := GetNumSC2()
			nAux := 0
		EndIf

		// Lê registros
		For nI := 1 to len( aCampos )
			If aCampos[nI][1]
		   		cCDACPY	:= POSICIONE( 'DG0', 1, xFilial('DG0')+aCampos[nI][2]+aCampos[nI][3], 'DG0_CDACPY' )
		   		//Alterado para resgatar roteiro de cada versão
		   		cCDRT		:= POSICIONE( 'DG0', 1, xFilial('DG0')+aCampos[nI][2]+aCampos[nI][3], 'DG0_CDRT' )
		   		cProduct	:= aCampos[nI][2]
		   		cVersion	:= aCampos[nI][3]

				// Verifica se existe uma ordem em aberto para o produto
				If nOpc == 3 .And. !GetSC2Open( cCDACPY, cVersion )
					DPRXError('DPRA340', 'DPRA340_ABERTA', 3 )
			    	DisarmTransaction()

			    	lRet := .F.

			    	Break
				EndIf

				// Regerar ordem de produção
				If nOpc == 4
				    // Procura ordem do produto pai
					If nI == 1
						aRetorno := DPExistDGH( cProduct, cVersion )
						cFilDGH  := aRetorno[1]
				   		cNRORPO  := aRetorno[2]

						// Caso não encontrar ordem para regerar
						If Empty( cNRORPO )
							DisarmTransaction()

							lRet := .F.

							Break
						EndIf
					// Gera as filhas
					Else
						aRetorno := DPExistDGH( cProduct, cVersion, cNRORPO )
						cFilDGH  := aRetorno[1]
				   		cNRORPO  := aRetorno[2]

				   		If DPRXComp(2)
							if cFilDGH != xFilial('DGH')
								DPRXError( 'DPRA340', STR0046 + (cAliasDGP)->DGP_FILIAL, 1, STR0047 ) // Foi encontrada pendência na filial ## 'Acesse o módulo SIGADPR através desta filial.'

								lRet := .F.

								Break
							Endif
						Endif
					EndIf

		        	// Se o tamanho da ordem estiver conforme a SC2
					If len( cNRORPO ) == TamSX3('C2_NUM')[1]+TamSX3('C2_ITEM')[1]+TamSX3('C2_SEQUEN')[1]
						// Apaga ordem
						If DPExistSC2( 0, cFilDGH, cNRORPO) .And. !DPDelSC2( cNRORPO )
							DisarmTransaction()

							lRet := .F.

							Break
						EndIf

						// Cria nova ordem
						aAdd( aMata650, {{'C2_SEQUEN', SubStr( cNRORPO, TamSX3('C2_ITEM')[1]+TamSX3('C2_NUM')[1]+1, TamSX3('C2_SEQUEN')[1] ), Nil}, ;
										 {'C2_NUM'	 , SubStr( cNRORPO, 1, TamSX3('C2_NUM')[1] )											, Nil}, ;
										 {'C2_ITEM'  , SubStr( cNRORPO, TamSX3('C2_NUM')[1]+1, TamSX3('C2_Item')[1] )		   				, Nil}} )
						cNRORPO := SubStr( cNRORPO, 1, TamSX3('C2_ITEM')[1]+TamSX3('C2_NUM')[1] )
					EndIf
				// Cria nova ordem
				Else

					nAux++

					cOrdemInfo := {}
					aAdd(cOrdemInfo,{'C2_SEQUEN', StrZero( nAux, TamSX3("C2_SEQUEN")[1] ), Nil})
					aAdd(cOrdemInfo,{'C2_NUM', cNRORPO, Nil})
					aAdd(cOrdemInfo,{'C2_ITEM', cItem, Nil})

					IF lExistDP340SC2
						If nAux == 1
							aRetPE := ExecBlock("DP340SC2",.f.,.f.,ACLONE(cOrdemInfo))
							If Valtype(aRetPE) == "A"
								cOrdemInfo:=ACLONE(aRetPE)

								nPos := Ascan(cOrdemInfo,{|x|Alltrim(x[1]) == 'C2_ITEM'})
								if nPos > 0
									cItem := cOrdemInfo[nPos][2]
								Else
									cItem := '01'
								Endif

								nPos := Ascan(cOrdemInfo,{|x|Alltrim(x[1]) == 'C2_SEQUEN'})
								if nPos > 0
									nAux := VAL(cOrdemInfo[nPos][2])
								Else
									nAux := 1
								Endif
							EndIf
						Endif
					EndIf

					aAdd( aMata650, cOrdemInfo )
				EndIf

				If AllTrim(cCDRT) == ""
					If ExistFunc("PCPA124")
						cNewCR := A124DPCod(cCDACPY)
					Else
						cNewCR := A632DPCod(cCDACPY)
					EndIf

					// Grava o roteiro protótipo do produto
					If !DPInsSG2PT( aCampos[nI,2], aCampos[nI,3],cNewCR )
						DisarmTransaction()
						lRet := .F.
						Break
					EndIf

				Else
					dbSelectArea("SG2")
					SG2->( dbSetOrder(1) )
					If SG2->( dbSeek(xFilial("SG2") + cCDACPY + cCDRT) )
						cNewCR := cCDRT
					Else
						DPRXError( 'DPRA340', 'DPRA340_NRTPCP', 3 )//O roteiro associado a esta versão não existe no módulo PCP.
						DisarmTransaction()

						lRet := .F.

						Break
					EndIf
				EndIf



				// Gera ordem de produção
				aAdd( aMata650[len(aMata650)], {'C2_PRODUTO', cCDACPY 												, Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_LOCAL'  , Posicione('SB1',1,xFilial('SB1')+cCDACPY ,'B1_LOCPAD'), Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_CC'     , Posicione('SB1',1,xFilial('SB1')+cCDACPY ,'B1_CC')   	, Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_QUANT'  , aCampos[nI][4]  										, Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_UM'     , Posicione('SB1',1,xFilial('SB1')+cCDACPY ,'B1_UM')    , Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_DATPRI' , Date()					    						, Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_DATPRF' , Date()					    						, Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_EMISSAO', Date()												, Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_TPOP'	, 'F'													, Nil} )
				//aAdd( aMata650[len(aMata650)], {'C2_ROTEIRO', Substr( 'DP', 1, TamSX3('C2_ROTEIRO')[1] )			, Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_OBS'    , Substr( cLog, 1, TamSX3('C2_OBS')[1] )		   		, Nil} )
				aAdd( aMata650[len(aMata650)], {'AUTEXPLODE', 'S'													, Nil} )
				aAdd( aMata650[len(aMata650)], {'C2_ROTEIRO', Substr(cNewCR, 1, TamSX3('C2_ROTEIRO')[1]) 			, nIL} )

				MSExecAuto( { |x,y| MATA650(x,y) }, aMata650[ len(aMata650) ], 3 )
				// Caso não consiga salvar SC2
				If lMsErroAuto
					MostraErro()
					DisarmTransaction()

					lRet := .F.

					Break
				// Salva histórico
				Else
					oModel := FwLoadModel('DPRA340')
					dbSelectArea( 'DGH' )
					DGH->( dbSetOrder(1) )

					If !DGH->( dbSeek( xFilial('DGH')+aCampos[nI][2]+aCampos[nI][3]+aMata650[len(aMata650),2,2]+aMata650[len(aMata650),3,2]+aMata650[len(aMata650),1,2] ) )
						oModel:SetOperation(3)
						oModel:Activate()
						oModel:SetValue('DGHMASTER', 'DGH_CDACDV' , aCampos[nI][2]								 										)
					   	oModel:SetValue('DGHMASTER', 'DGH_NRVRAC' , aCampos[nI][3]								 										)
						oModel:SetValue('DGHMASTER', 'DGH_NRORPO' , aMata650[len(aMata650),2,2]+aMata650[len(aMata650),3,2]+aMata650[len(aMata650),1,2]	)
					Else
			   			oModel:SetOperation(4)
						oModel:Activate()
					EndIf
					oModel:SetValue('DG6DETAIL', 'DG6_IDNV'   , GETSX8NUM("DG6","DG6_IDNV") )
					oModel:SetValue('DG6DETAIL', 'DG6_DSNV'   , cLog )

					If oModel:VldData()
						oModel:CommitData()

						ConfirmSX8()
					EndIf
					oModel:DeActivate()
				EndIf

				// Gera empenhos para a ordem
				aMata380 := {}
				dbSelectArea('DG1')
				DG1->( dbSetOrder(1) )
				If DG1->( dbSeek( xFilial('DG1') + aCampos[nI][2] + aCampos[nI][3] ) )
					While DG1->( !EOF() ) .AND. DG1->DG1_CDACDV == aCampos[nI][2] .And. DG1->DG1_NRVRAC == aCampos[nI][3]

						// Gera saldo inicial para o componente
						If Empty(DG1->DG1_CDMT)
							cProt  := Posicione('DG0',1,xFilial('DG0')+DG1->DG1_CDMTDV+DG1->DG1_NRVRMT,'DG0_CDACPY')
							cDepos := Posicione('SB1',1,xFilial('SB1')+cProt,'B1_LOCPAD')

							dbSelectArea("SB2")
							SB2->(dbSetOrder(1))
							If !SB2->( dbSeek(xFilial("SB2")+cProt+cDepos) )
								CriaSB2(cProt,cDepos )
								MsUnLock()
							EndIf

							aAdd( aMata380, {	{'D4_OP'  		, PadR(aMata650[len(aMata650),2,2]+aMata650[len(aMata650),3,2]+aMata650[len(aMata650),1,2],nTamOP)	, Nil}, ;
												{'D4_COD'	  	, cProt																					, Nil}, ;
												{'D4_LOCAL'  	, cDepos																					, Nil}, ;
												{'D4_DATA'  	, aMata650[len(aMata650),11,2]      													, Nil}, ;
												{'D4_QTDEORI'	, DG1->DG1_QTUT*aCampos[nI][4]															, Nil}, ;
												{'D4_QUANT'  	, DG1->DG1_QTUT*aCampos[nI][4] 															, Nil}} )

							// Ajuste Sequencial do Trt para nao dar erro nos empenhos
							If Empty(DG1->DG1_NRSQET)
								nSeqProd := 0
								If len(aMata380) > 1
									For nProd := 1 to len(aMata380)
										If aMata380[nprod][2][2] == cProt
											nSeqProd ++
										EndIf
									Next nProd
								EndIf

								If nSeqProd > 1
									cSeqProd := StrZero(nSeqProd,Tamsx3("D4_TRT")[1] )
								Else
									cSeqProd := DG1->DG1_NRSQET
								EndIf

								aadd(aMata380[Len(aMata380)], {'D4_TRT', cSeqProd, Nil})
							Else
								aadd(aMata380[Len(aMata380)], {'D4_TRT', DG1->DG1_NRSQET, Nil})
							EndIf


							If !Empty(DG1->DG1_CDATET)
								aadd(aMata380[Len(aMata380)], {'D4_PRODUTO', cCDACPY        , Nil})
								aadd(aMata380[Len(aMata380)], {'D4_ROTEIRO', cNewCR         , Nil})
								aadd(aMata380[Len(aMata380)], {'D4_OPERAC' , DG1->DG1_CDATET, Nil})
							Endif
						Else
							cDepos := Posicione('SB1',1,xFilial('SB1')+DG1->DG1_CDMT,'B1_LOCPAD')

							dbSelectArea("SB2")
							SB2->(dbSetOrder(1))
							If !SB2->(dbSeek(xFilial("SB2")+DG1->DG1_CDMT+cDepos))
								CriaSB2(DG1->DG1_CDMT, cDepos)
								MsUnLock()
							EndIf

							aAdd( aMata380, {	{'D4_OP'  		, PadR(aMata650[len(aMata650),2,2]+aMata650[len(aMata650),3,2]+aMata650[len(aMata650),1,2],nTamOP)	, Nil}, ;
												{'D4_COD'	  	, DG1->DG1_CDMT																			, Nil}, ;
												{'D4_LOCAL'  	, cDepos																					, Nil}, ;
												{'D4_DATA'  	, aMata650[len(aMata650),11,2]      													, Nil}, ;
												{'D4_QTDEORI'	, DG1->DG1_QTUT*aCampos[nI][4]															, Nil}, ;
												{'D4_QUANT'  	, DG1->DG1_QTUT*aCampos[nI][4] 															, Nil}} )

							aadd(aMata380[Len(aMata380)], {'D4_TRT', DG1->DG1_NRSQET, Nil})

							if !Empty(DG1->DG1_CDATET)
								aadd(aMata380[Len(aMata380)], {'D4_PRODUTO', cCDACPY        , Nil})
								aadd(aMata380[Len(aMata380)], {'D4_ROTEIRO', cNewCR         , Nil})
								aadd(aMata380[Len(aMata380)], {'D4_OPERAC' , DG1->DG1_CDATET, Nil})
							Endif
						Endif

						MsExecAuto( { |x,y| MATA380(x,y) }, aMata380[ len(aMata380) ] , 3 )
						If lMsErroAuto
							MostraErro()
							DisarmTransaction()

							lRet := .F.

							Break
						EndIf

						DG1->( dbSkip() )
					End

				EndIf
			EndIf
		Next
		END TRANSACTION
	EndIf

// Apaga Ordem
ElseIf nOpc == 5
	cNRORPO 	:= DGH->DGH_NRORPO

	dbSelectArea( 'DGH' )
	DGH->( dbSetOrder(2) )
	If DGH->( dbSeek( xFilial('DGH')+Substr( cNRORPO, 1, nTam ) ) )
		cLog  := STR0022 + CRLF // Existem ordens relacionadas a ordem selecionada:
		While DGH->( !EOF() )
			If Substr(DGH->DGH_NRORPO, 1, nTam ) == Substr( cNRORPO, 1, nTam ) .And. DGH->DGH_NRORPO != cNRORPO

				cLog += AllTrim( DGH->DGH_NRORPO ) + CRLF
				lGera := .F.

			EndIf
			DGH->( dbSkip() )
		End
		cLog += STR0023 + AllTrim(cNRORPO) + STR0024  // Deseja apagar a ordem ##  mesmo assim?
	EndIf

	If !lGera
		DEFINE MSDIALOG oDlg TITLE STR0025 From 0,0 TO 250,400 PIXEL // Ordens Relacionadas
		oMemo := TSimpleEditor():New( 5, 5, oDlg, 192, 100, cLog, .T., , , .T. )
		oMemo:Load( cLog )
		oMemo:lCanGotFocus:= .F.

		// Cria botões com métodos básicos do Browse
		TButton():New( 110, 115, STR0016, oDlg,{|| oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // 'Cancelar'
		TButton():New( 110, 158, STR0026, oDlg,{|| lGera := .T., oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Apagar ordem

		ACTIVATE MSDIALOG oDlg CENTER
	EndIf

	If lGera
		If !DPDelSC2( cNRORPO )
			DisarmTransaction()
			Return .F.
		EndIf
	Else
		Help( ,, 'HELP', 'DPRA344', STR0027, 1, 0) // Processo cancelado
		Return .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPExistDGH
Verifica se existe a ordem desejada

@param		cProduct		Produto a ser buscado
@param		cVersion		Versão do produto
@param		cNRORPO			Numero da ordem
@return 	cRet			Retorna a ordem encontrada

@author Ana Carolina Tome Klock
@since 26/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Function DPExistDGH( cProduct, cVersion, cNRORPO )
Local cRet			:= ''
Local nJ 			:= 0
Local cFilDGH       := ''
Local cAliasDGH     := GetNextAlias()
Default cProduct	:= DG0->DG0_CDACDV
Default cVersion 	:= DG0->DG0_NRVRAC
Default cNRORPO 	:= ''

// Verifica formato de compartilhamento
if DPRXCOMP(2)
	// Busca pelo produto
	If Empty( cNRORPO )
		BeginSql Alias cAliasDGH

			Select * from %Table:DGH% DGH
				WHERE DGH.DGH_CDACDV=%Exp:cProduct% AND
					  DGH.DGH_NRVRAC=%Exp:cVersion% AND
					  DGH.%NotDel%
		EndSql

		While (cAliasDGH)->(!EOF())
			cRet    := AllTrim((cAliasDGH)->DGH_NRORPO)
			cFilDGH := (cAliasDGH)->DGH_FILIAL

			(cAliasDGH)->(dbSkip())
		End

		(cAliasDGH)->(dbCloseArea())
	Else
		BeginSql Alias cAliasDGH

			Select * from %Table:DGH% DGH
				WHERE DGH.DGH_NRORPO=%Exp:cNRORPO% AND
					  DGH.%NotDel%
		EndSql

		While (cAliasDGH)->( !EOF() )
	  	    If Substr((cAliasDGH)->DGH_NRORPO, 1, TamSX3('C2_NUM')[1]+TamSX3('C2_ITEM')[1]) == cNRORPO
		    	If AllTrim((cAliasDGH)->DGH_CDACDV) == AllTrim(cProduct) .And. AllTrim((cAliasDGH)->DGH_NRVRAC) == AllTrim(cVersion)

		    		cRet    := AllTrim((cAliasDGH)->DGH_NRORPO)
					cFilDGH := (cAliasDGH)->DGH_FILIAL

					Exit
				Else
					nJ := Val(Substr((cAliasDGH)->DGH_NRORPO, TamSX3('C2_NUM')[1]+TamSX3('C2_ITEM')[1]+1, TamSX3('C2_SEQUEN')[1]))
				EndIf
		    EndIf
		    (cAliasDGH)->( dbSkip() )
		End

		cRet    := cNRORPO + DPRXCOUNT( TamSX3('C2_SEQUEN')[1], nJ )
		cFilDGH := (cAliasDGH)->DGH_FILIAL

		(cAliasDGH)->(dbCloseArea())
	Endif
Else

	dbSelectArea('DGH')
	// Busca pelo produto
	If Empty( cNRORPO )
		DGH->( dbSetOrder(1) )
		If DGH->( dbSeek( xFilial('DGH') + cProduct + cVersion ) )
			While DGH->( !EOF() )
				If DGH->DGH_FILIAL == xFilial('DGH') .AND. AllTrim(DGH->DGH_CDACDV) == AllTrim(cProduct) .And. ( AllTrim(DGH->DGH_NRVRAC) == AllTrim(cVersion) .Or. Empty(cVersion) )
					cRet    := AllTrim(DGH->DGH_NRORPO)
					cFilDGH := DGH->DGH_FILIAL
				EndIf
				DGH->( dbSkip() )
			End
	    EndIf

	// Busca pela ordem
	Else
		DGH->( dbSetOrder(2) )
		If DGH->( dbSeek( xFilial('DGH') + cNRORPO ) )
			While DGH->( !EOF() )
		  	    If Substr(DGH->DGH_NRORPO, 1, TamSX3('C2_NUM')[1]+TamSX3('C2_ITEM')[1]) == cNRORPO
			    	If AllTrim(DGH->DGH_CDACDV) == AllTrim(cProduct) .And. AllTrim(DGH->DGH_NRVRAC) == AllTrim(cVersion)

			    		cRet    := AllTrim(DGH->DGH_NRORPO)
						cFilDGH := (cAliasDGH)->DGH_FILIAL

						Exit
					Else
						nJ := Val(Substr(DGH->DGH_NRORPO, TamSX3('C2_NUM')[1]+TamSX3('C2_ITEM')[1]+1, TamSX3('C2_SEQUEN')[1]))
					EndIf
			    EndIf
			    DGH->( dbSkip() )
			End
		EndIf

		cRet    := cNRORPO + DPRXCOUNT( TamSX3('C2_SEQUEN')[1], nJ )
		cFilDGH := DGH->DGH_FILIAL
	EndIf

Endif

Return {cFilDGH, cRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSC2Open
Verifica se existe ordem aberta para o produto

@param		cProduct		Produto a ser buscado
@return 	lRet			Retorna se encontrou o registro

@author Ana Carolina Tome Klock
@since 28/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Function GetSC2Open( cProduct, cVersao )
	Local lRet		:= .T.
	Local cNRORPO	:= ''
	Local cFilDGH   := ''
	Local aRetorno  := ''
	Default cProduct	:= DG0->DG0_CDACDV
	Default cVersao	:= DG0->DG0_NRVRAC

	aRetorno := DPExistDGH(cProduct, cVersao)

	cFilDGH := aRetorno[1]
	cNRORPO := aRetorno[2]

	If !Empty(cNRORPO) .And. !(DPExistSC2( 5, cFilDGH, cNRORPO) .Or. DPExistSC2( 6, cFilDGH, cNRORPO) )//Corrigida ordem dos parametros
		lRet := .F.
	EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA340VdO
Função para validar se o produto possui operação para ser aprovado

@param 		cProduct		(Obrigatório) Código do Produto
@param		cVersao		(Obrigatório) Versão do Produto

@return 	lRet		Retorna .T. caso possua operações

@author Ezequiel Ramos
@since 01/07/2014
@version P11
/*/
//-------------------------------------------------------------------
Function DPRA340VdO( cProduct, cVersao )
	Local lRet := .T.
	Default cProduct	:= DG0->DG0_CDACDV
	Default cVersao	:= DG0->DG0_NRVRAC

	dbSelectArea("DG9")
	DG9->(dbSetOrder(1))
	lRet := DG9->(dbSeek(xFilial("DG9")+cProduct+cVersao))
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DPExistSC2
Verifica se existe a ordem desejada

@param		cProduct		Produto a ser buscado
@param		nStatus 		Estado da ordem
@param		cNRORPO			Numero da ordem
@return 	lRet			Retorna se encontrou o registro

@author Ana Carolina Tome Klock
@since 26/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPExistSC2( nStatus, cFilDGH, cNRORPO )
Default nStatus  := 0
Default cNRORPO  := ''
Default cVersao  := ''
Default cFilDGH  := ''

dbSelectArea( 'SC2' )
SC2->( dbSetOrder(1) )
If SC2->( dbSeek( cFilDGH+cNRORPO ) )
	While SC2->( !EOF() )
		// Busca por numero da ordem + estado da ordem
		If nStatus > 0
			If SC2->C2_FILIAL == cFilDGH .and. SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN == cNRORPO .And. A650DefLeg(nStatus)
				Return .T.
			EndIf
		// Busca apenas por numero da ordem
		Else
			If SC2->C2_FILIAL == cFilDGH .AND. SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN == cNRORPO
				Return .T.
			EndIf
		EndIf
		SC2->( dbSkip() )
	End
EndIf
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPInsSG2PT
Inclui as operações do protótipo

@param		cProduct		Produto que possui as operações
@param		cVersion		Versão do produto desejada
@return	lRet			Retorna se a inclusão ocorreu

@author Ana Carolina Tome Klock
@since 26/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPInsSG2Pt( cProduct, cVersion, cNewCR )
	Local nI := 0
	Local lRet       := .T.
	Local lRunPCP124 := ExistFunc('PCPA124')
	Local cModelId   := Iif(lRunPCP124,"PCPA124_CAB","MATA632_CAB")
	Local cCDACPY
	Local oModelRot, oMdlRotSG2, oModel300
	Local lQipMat	 := SuperGetMV("MV_QIPMAT",.F.,"N") == "S"

	cCDACPY := POSICIONE( 'DG0', 1, xFilial('DG0')+cProduct+cVersion, 'DG0_CDACPY' )

	//Antes de incluir as operações ao roteiro, exclui as que já possuia
	dbSelectArea('SG2')
	If lRunPCP124
		oModelRot := FWLoadModel('PCPA124')
	Else
		oModelRot := FWLoadModel('MATA632')
	EndIf
	SG2->( dbSetOrder(1) )
	If SG2->( dbSeek( xFilial('SG2') + cCDACPY + cNewCR ) ) //cProduct ou cCDACPY
		//Exclusao da Integracao PCP x QIP
		If lQipMat
			QAtuMatQIP(DG0->DG0_CDACPY,,cNewCR,"PCP",.T.)
		EndIf
		oModelRot:SetOperation(5)
		If oModelRot:Activate()
			If oModelRot:VldData()
				oModelRot:CommitData()
			EndIf
		EndIf
	EndIf

	Begin Transaction
		dbSelectArea('DG9')
		DG9->(dbSetOrder(1))
		If DG9->( dbSeek(xFilial('DG9') + cProduct + cVersion))
			If lRunPCP124
				oModelRot := FWLoadModel('PCPA124')
			Else
				oModelRot := FWLoadModel('MATA632')
			EndIf
			oModelRot:SetOperation(3)
			If oModelRot:Activate()

				If lRunPCP124
					oMdlRotSG2 := oModelRot:GetModel('PCPA124_SG2')
				Else
					oMdlRotSG2 := oModelRot:GetModel('MATA632_SG2')
				EndIf

				oModelRot:SetValue(cModelID,'G2_CODIGO' , cNewCR)
				oModelRot:SetValue(cModelID,'G2_PRODUTO', cCDACPY)

				While DG9->(!EOF()) .AND. DG9->DG9_CDACDV == cProduct .AND. DG9->DG9_NRVRAC == cVersion
					nI++

					IF nI > 1
						oMdlRotSG2:AddLine()
					Endif

					oMdlRotSG2:SetValue('G2_OPERAC' , DG9->DG9_CDATET)
					oMdlRotSG2:SetValue('G2_DESCRI' , Substr(DG9->DG9_DSAT,1,TamSX3("G2_DESCRI")[1]))
					oMdlRotSG2:SetValue('G2_RECURSO', ALLTRIM(DG9->DG9_CDMQ))
					oMdlRotSG2:SetValue('G2_FERRAM' , ALLTRIM(DG9->DG9_CDFE))
					oMdlRotSG2:SetValue('G2_TPALOCF', DG9->DG9_TPALFE)

					Do Case
						Case DG9->DG9_TPUNTE == '1'
							oMdlRotSG2:SetValue('G2_SETUP', DG9->DG9_QTTESU)
						Case DG9->DG9_TPUNTE == '2'
							oMdlRotSG2:SetValue('G2_SETUP', DG9->DG9_QTTESU / 60)
						Case DG9->DG9_TPUNTE == '3'
							oMdlRotSG2:SetValue('G2_SETUP', DG9->DG9_QTTESU / 3600)
						Case DG9->DG9_TPUNTE == '4'
							oMdlRotSG2:SetValue('G2_SETUP', DG9->DG9_QTTESU * 24)
					End Case

					oMdlRotSG2:SetValue('G2_FORMSTP', DG9->DG9_CDFOSU)
					oMdlRotSG2:SetValue('G2_LOTEPAD', DG9->DG9_NRUNAC)
					oMdlRotSG2:SetValue('G2_TEMPAD' , DG9->DG9_QTTEMQ)
					oMdlRotSG2:SetValue('G2_TPOPER' , If(DG9->DG9_TPTEAT=="3","4",DG9->DG9_TPTEAT))
					oMdlRotSG2:SetValue('G2_TPSOBRE', DG9->DG9_TPTEOV)
					oMdlRotSG2:SetValue('G2_TEMPSOB', DG9->DG9_QTTEOV)
					oMdlRotSG2:SetValue('G2_CTRAB'  , ALLTRIM(DG9->DG9_CDCETR))
					oMdlRotSG2:SetValue('G2_TEMPEND', DG9->DG9_QTTEPP)
					oMdlRotSG2:SetValue('G2_MAOOBRA', DG9->DG9_QTRC)

					// Busca os alterantivos da operação
					DG2->(dbSetOrder(1))
					if DG2->(dbSeek(xFilial('DG2')+DG9->DG9_IDAT))
						While DG2->(!EOF()) .AND. DG2->DG2_IDAT == DG9->DG9_IDAT

							RecLock('SH3',.T.)
							SH3->H3_FILIAL  := xFilial('SH3')
							SH3->H3_PRODUTO := cCDACPY
							SH3->H3_CODIGO  := cNewCR
							SH3->H3_OPERAC  := DG9->DG9_CDATET
							SH3->H3_RECPRIN := DG9->DG9_CDMQ
							SH3->H3_RECALTE := ALLTRIM(DG2->DG2_CDMQ)
							SH3->H3_TIPO    := DG2->DG2_TPMQ
							SH3->H3_EFICIEN := DG2->DG2_VLEF
							SH3->H3_FERRAM  := DG2->DG2_CDFE
							SH3->(MsUnLock())

							DG2->(dbSkip())
						End
					Endif

					DG9->(dbSkip())
				End

				if oModelRot:VldData()
					oModelRot:CommitData()
				Else
					aErro := oModelRot:GetErrorMessage()
					DPRXError( 'DPRA340', aErro[6] )
					lRet := .F.
				EndIf
				oModelRot:DeActivate()
			Else
				aErro := oModelRot:GetErrorMessage()
				DPRXError( 'DPRA340', aErro[6] )
				lRet := .F.
			Endif

		EndIf

		if lRet .AND. cNewCR != POSICIONE( 'DG0', 1, xFilial('DG0')+cProduct+cVersion, 'DG0_CDRT' )
			oModel300 := FwLoadModel('DPRA300')
			oModel300:SetOperation(4)
			if oModel300:Activate()

				oModel300:SetValue('DG0MASTER','DG0_CDRT',cNewCR)

				if oModel300:VldData()
					oModel300:CommitData()
				Endif
			Endif

			oModel300:DeActivate()
		Endif

		If !lRet
			DisarmTransaction()
		Endif

	End Transaction
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DPDelSC2
Apaga a ordem no PCP

@param		cNRORPO				Numero da ordem

@author Ana Carolina Tome Klock
@since 26/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPDelSC2( cNRORPO )
Local aMata650 := {}

// Cria o vetor do Mata650
aAdd( aMata650, {{'C2_SEQUEN' 	, SubStr( cNRORPO, TamSX3('C2_ITEM')[1]+TamSX3('C2_NUM')[1]+1, TamSX3('C2_SEQUEN')[1] )	, Nil}, ;
				 {'C2_NUM'	  	, SubStr( cNRORPO, 1, TamSX3('C2_NUM')[1] )												, Nil}, ;
				 {'C2_ITEM'   	, SubStr( cNRORPO, TamSX3('C2_NUM')[1]+1, TamSX3('C2_Item')[1] )		   				, Nil}} )

// Verifica se a ordem existe
dbSelectArea( 'SC2' )
SC2->( dbSetOrder(1) )
If SC2->( dbSeek( xFilial('SC2') + cNRORPO ) )
	// Apaga a ordem
	MSExecAuto( { |x,y| MATA650(x,y) }, aMata650[1], 5 )
	If lMsErroAuto
		MostraErro()
		Return .F.
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA340LEG
Tela de Legendas

@author Ana Carolina Tome Klock
@since 01/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA340LEG()
Default lAutomacao := .F.

// Cria a legenda que identifica a estrutura
oLegend := FWLegend():New()

// Adiciona descrição para cada legenda
oLegend:Add( { || }, 'BR_AZUL' 		, STR0029 )		// 'Com ordens'
oLegend:Add( { || }, 'BR_LARANJA'  , STR0030 )		// 'Sem operações'
oLegend:Add( { || }, 'BR_BRANCO' 	, STR0031 )		// 'Sem ordens'

// Ativa a Legenda
oLegend:Activate()

// Exibe a Tela de Legendas
If !lAutomacao 
	oLegend:View()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Pergunt340
Tela de Pergunte()

@author 	Ana Carolina Tome Klock
@since 		20/05/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function Pergunt340()

	Local oDlg, oPanel
	Local aReturn := { .F., 1, Substr( AllTrim(DG0->DG0_DSVR) + ' ' + AllTrim(DG0->DG0_NRVRAC), 1, TamSX3('C2_OBS')[1] ) }
	aReturn[3] += Space( TamSX3('C2_OBS')[1] - len(aReturn[3]) )
	Default lAutomacao := .F.

	If !lAutomacao
		oDlg 	:= MsDialog():New( 0, 0, 150, 350, STR0015, , , , , CLR_WHITE, CLR_WHITE, , , .T. )  // Gerar Ordem
		oPanel 	:= TPanel():New( 25, 0, , oDlg, , , , , CLR_WHITE, 150, 350, .F., .F. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@  15, 10 Say STR0014 Of oPanel COLOR CLR_BLACK Pixel // 'Quantidade'
		@  13, 50 MsGet oQuant  Var aReturn[2] Size 100,10 Pixel Of oPanel Picture "@R 9999999.999999"
		@  35, 10 Say STR0035 Of oPanel COLOR CLR_BLACK Pixel // 'Observação'
		@  33, 50 MsGet oObserv Var aReturn[3] Size 100,10 Pixel Of oPanel Valid NaoVazio(aReturn[3])

		@ 50, 60  BUTTON oBtnAvanca   PROMPT "Confirmar" SIZE 35, 14 ACTION { || aReturn[1] := .T., oDlg:End() } OF oDlg PIXEL
		@ 50, 100 BUTTON oBtnCancelar PROMPT "Cancelar"  SIZE 35, 14 ACTION (oDlg:End())         OF oDlg PIXEL

		oDlg:Activate( , , , .T. , , , /*{ || EnchoiceBar(oDlg, { || aReturn[1] := .T.,oDlg:End() }, { ||  oDlg:End() } , , ) }*/  )
	EndIf

Return aReturn
//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaHelp
Incluir um novo HELP

@author 	Michele Girardi
@since 		05/02/2014
/*/
//-------------------------------------------------------------------

Static Function AjustaHelp()

Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

aHelpPor := {"Existem ordens de produção abertas para" , "o produto desenvolvido ou para os", "componentes do produto selecionado."}
aHelpSpa := {"Existen ordenes de produccion abiertas" , "para producto desarrollado o" , "componentes del producto seleccionado."}

PutHelp("PDPRA340_ABERTA", aHelpPor, aHelpEng, aHelpSpa, .T.)

aHelpPor := {"Encerre as ordens abertas do produto" ,"desenvolvido ou dos componentes da" , "versão selecionada."}
aHelpSpa := {"Finalice las ordenes abiertas del" , "producto desarrollado o los componentes" , "de la version seleccionada."}

PutHelp("SDPRA340_ABERTA", aHelpPor, aHelpEng, aHelpSpa, .T.)

Return Nil