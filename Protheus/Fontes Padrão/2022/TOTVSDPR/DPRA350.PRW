#INCLUDE 'DPRA350.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#DEFINE PULALINHA CHR(13)+CHR(10)
//-----------------------------------------------------------------
/*/{Protheus.doc} DPRA350
Pendência Desenvolvimento

@author Samantha Preima
@since 02/10/2013
@version P12
/*/
//-----------------------------------------------------------------
Function DPRA350()
	Local oBrowse
	Local aValidaDPR := ValidaDPR()
	Private oView
	Default lAutoMacao := .F.

	//Identificar se há diferença de exclusividade/compartilhamento entre as tabelas SG1 e SCK
	If !ValidFATDP()
		Return Nil
	EndIf

	// Valida se o programa pode ser aberto
	If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
		Final(aValidaDPR[2])
	ElseIf !Empty( aValidaDPR[2] )
		DPRXError( 'DPRA350', aValidaDPR[2], 3 )
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DGC')
	oBrowse:SetDescription( STR0001 ) //"Pendência Desenvolvimento"
	IF !lAutoMacao
		oBrowse:Activate()
	ENDIF
Return NIL
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA350'	OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA350'	OPERATION 4 ACCESS 0 // "Resolver"
	ADD OPTION aRotina TITLE STR0005 ACTION 'DPRA350APP()'		OPERATION 9 ACCESS 0 // "Atualizar"
Return aRotina
//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructDGC := FWFormStruct( 1, 'DGC', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGP := FWFormStruct( 1, 'DGP', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDG6 := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('DPRA350', {|oModel| DPRA350PRE( oModel )}, { |oModel| DPRA350POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'DGCMASTER', /*cOwner*/, oStructDGC, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'DGPDETAIL', 'DGCMASTER', oStructDGP, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DG6DETAIL', 'DGCMASTER', oStructDG6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'DGPDETAIL', { { 'DGP_FILIAL', 'xFilial( "DGP" )' }, { 'DGP_IDIC', 'DGC_IDIC'	} }, DGP->(IndexKey(3)) )
	oModel:SetRelation( 'DG6DETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV', 'DGC_IDNV'	} }, DG6->(IndexKey(1)) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'DG6DETAIL' ):SetNoInsertLine()

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0006 ) // "Modelo de Dados de Pendência Desenvolvimento"

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'DGCMASTER' ):SetDescription( STR0007 ) // "Dados de Pendência Desenvolvimento"
	oModel:GetModel( 'DGPDETAIL' ):SetDescription( STR0008 ) // "Versões Produto Desenvolvido"
	oModel:GetModel( 'DG6DETAIL' ):SetDescription( "Dados da Narrativa" ) // "Dados da Narrativa"

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'DGPDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DG6DETAIL' ):SetOptional(.T.)

	oModel:GetModel( 'DGPDETAIL' ):SetUniqueLine({"DGP_IDIC","DGP_CDACDV","DGP_NRVRAC"})

	oStructDG6:SetProperty('DG6_IDNV',MODEL_FIELD_OBRIGAT,.F.)

	oModel:SetVldActivate( { |oModel|  AbreTela( oModel ) } )
Return oModel
//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel     := FWLoadModel( 'DPRA350' )
	// Cria a estrutura a ser usada na View
	Local oStructDGC := FWFormStruct( 2, 'DGC' ) // Produto
	Local oStructDGP := FWFormStruct( 2, 'DGP' ) // Versão
	Local oStructDG6 := FWFormStruct( 2, 'DG6' ) // Narrativa

	oStructDGC:RemoveField("DGC_IDNV")

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_DGC', oStructDGC, 'DGCMASTER' )

	// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid( 'VIEW_DGP', oStructDGP, 'DGPDETAIL' )
	oView:AddGrid( 'VIEW_DG6', oStructDG6, 'DG6DETAIL' )

	// Cria um box horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )

	// Cria Folder na view
	oView:CreateFolder( 'FOLDER', 'INFERIOR' )

	// Cria pastas nas folders
	oView:AddSheet( 'FOLDER', 'TAB01', STR0036 )	// "Versões"
	oView:AddSheet( 'FOLDER', 'TAB02', STR0037 )	// "Narrativa"

	// Cria um box horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'DGP', 100, , ,'FOLDER', 'TAB01' )
	oView:CreateHorizontalBox( 'DG6', 100, , ,'FOLDER', 'TAB02' )

	// Relaciona o ID da View com o box para exibicao
	oView:SetOwnerView( 'VIEW_DGC', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_DGP', 'DGP' )
	oView:SetOwnerView( 'VIEW_DG6', 'DG6' )


	oStructDGP:RemoveField( 'DGP_IDIC' )
	oStructDGP:RemoveField( 'DGP_CDACDV' )

	oStructDG6:RemoveField( 'DG6_IDNV' )
Return oView
//-------------------------------------------------------------------
Static Function AbreTela( oModel )
	Local lRet := .T.
	If DGC->DGC_LGFTEV == "1" .AND. oModel:GetOperation()	== 4
		Help( ,, 'DPRA350', , STR0010, 1, 0)//"Esta pendencia já possui uma versão liberada."
		lRet := .F.
	EndIf
Return lRet
//-------------------------------------------------------------------
//Insere a Narrativa da pendencia, se houver, nas versões associadas
//-------------------------------------------------------------------
Static Function InsNarrat(cIDNV,cCDACDV,oModelDGP)
	Local nI
	Local oModel300
	Local aErro := {}
	Local cNar
	Default lAutoMacao := .F.
	//Verifica se a pendência tem alguma versão associada
	IF !lAutoMacao
		If AllTrim(cIDNV) != "" .AND. (oModelDGP:getQtdLine() != 1 .OR. AllTrim(oModelDGP:GetValue('DGP_NRVRAC')) != "")
			//Seleciona o Registro da Narrativa da Pendencia e resgata a descrição
			dbSelectArea( "DG6" )
			DG6->( dbSetOrder(1) )
			DG6->( dbSeek( xFilial( "DG6" ) + cIDNV ) )
			cNar := DG6->DG6_DSNV
			//Para cada versão atribui a descrição da narrativa da pendencia
			For nI:= 1 To oModelDGP:getQtdLine()
				oModelDGP:GoLine(nI)
				//Localiza a versão
				dbSelectArea( "DG0" )
				DG0->( dbSetOrder(1) )
				DG0->( dbSeek( xFilial( "DG0" ) + cCDACDV + oModelDGP:GetValue("DGP_NRVRAC") ) )
				//Se a versão Já possuir uma narrativa altera sua descrição, caso contrário cria uma narrativa nova
				If AllTrim(DG0->DG0_IDNV) != ""
					dbSelectArea( "DG6" )
					DG6->( dbSetOrder(1) )
					DG6->( dbSeek( xFilial( "DG6" ) + DG0->DG0_IDNV ) )
					//Altera a descrição da Narrativa
					RecLock("DG6",.F.)
					DG6->DG6_DSNV		:= cNar
					DG6->(MsUnlock())
				Else
					//Cria uma Narrativa
					cIDNV := GETSX8NUM("DG6","DG6_IDNV")
					RecLock("DG6",.T.)
					DG6->DG6_FILIAL	:= xFilial("DG6")
					DG6->DG6_IDNV		:= cIDNV
					DG6->DG6_DSNV		:= cNar
					DG6->(MsUnlock())
					//Associa a narrativa a versão
					oModel300	:= FWLoadModel( 'DPRA300' )
					oModel300:SetOperation( MODEL_OPERATION_UPDATE )
					oModel300:Activate()
					oModel300:SetValue("DG0MASTER","DG0_IDNV",cIDNV)
					If oModel300:VldData()
						oModel300:CommitData()
					Else
						aErro := oModel300:GetErrorMessage()
						alert( STR0027 + AllToChar( aErro[6] ) )//Mensagem do erro: x
					EndIf

					oModel300:DeActivate()
				EndIf
			Next
		EndIf
	ENDIF
Return Nil
//-------------------------------------------------------------------
//Validação da inclusão
//-------------------------------------------------------------------
Static Function DPRA350INC(cNRBU,cNRSQBU,cCDACBU,cNRPD,cNRSQPD,cCDACPD,cCDACDV,cIDIC,oModelDGP,cIDNV)
	//Se for informado um Produto Desenvolvido ou Versão
	If AllTrim(cCDACDV) != ""
		DPRXError( 'DPRA350', STR0011, 4 ) // "Não pode ser informado um Produto Desenvolvido no momento da inclusão."
		Return .F.
		//Se forem informados todas informações do orçamento
	ElseIf AllTrim(cNRBU) != "" .AND. AllTrim(cNRSQBU) != "" .AND. AllTrim(cCDACBU) != ""
		//Se foi informado alguma informação do pedido junto
		If AllTrim(cNRPD) != "" .OR. AllTrim(cNRSQPD) != "" .OR. AllTrim(cCDACPD) != ""
			DPRXError( 'DPRA350', STR0012, 4 )//"Não pode ser informado um Orçamento e um Pedido ao mesmo momento na inclusão."
			Return .F.
		EndIf

		//Verifica se o produto informado é válido
		dbSelectArea( "CZ3" )
		CZ3->(dbSetOrder( 1 ))
		If CZ3->( !dbSeek( xFilial('CZ3') + cCDACBU ) )
			DPRXError( 'DPRA350', STR0013, 4 )//"Produto informado não encontrado."
			Return .F.
		EndIf
		//Se forem informados todas informações do pedido
	ElseIf AllTrim(cNRPD) != "" .AND. AllTrim(cNRSQPD) != "" .AND. AllTrim(cCDACPD) != ""
		//Se foi informado alguma informação do orçamento junto
		If AllTrim(cNRBU) != "" .OR. AllTrim(cNRSQBU) != "" .OR. AllTrim(cCDACBU) != ""
			DPRXError( 'DPRA350', STR0012, 4 )//"Não pode ser informado um Orçamento e um Pedido ao mesmo momento na inclusão."
			Return .F.
		EndIf

		//Verifica se o produto informado é válido
		dbSelectArea( "CZ3" )
		CZ3->( dbSetOrder(1) )
		If CZ3->( !dbSeek( xFilial('CZ3') + cCDACPD ) )
			DPRXError( 'DPRA350', STR0013, 4 )//"Produto informado não encontrado."
			Return .F.
		EndIf
		//Se não foi preenchido todos os informações do orçamento ou pedido
	Else
		DPRXError( 'DPRA350', STR0014, 4 )//"É necessário Nr Orçam/Pedid, Nr Seq Orç/Ped e Prod Orçam/Pedid para fazer a inclusão de uma pendência."
		Return .F.
	EndIf

	//Verifica se existe alguma versão repetida
	If!VerifVersL(cCDACDV,oModelDGP)
		Return .F.
	Else
		InsNarrat(cIDNV,cCDACDV,oModelDGP)
	EndIf
Return .T.
//-------------------------------------------------------------------
//Verifica se existe alguma versão liberada
//-------------------------------------------------------------------
Static Function VerifVersL(cCDACDV,oModelDGP)
	Local cNRVRAC
	Local lCompaDGP := DPRXCOMP(1)
	Local lCompaDGH := DPRXCOMP(2)
	Local cIDIC     := ""
	Local cAliasDGP := GetNextAlias()
	Local cAliasDGH := GetNextAlias()
	Local lRet      := .T.
	Local nI		:= 0
	Local aDelete	:= {}
	Local cOrdProt  := ''
	Default lAutoMacao := .F.

	IF !lAutoMacao
		cIDIC := oModelDGP:GetValue('DGP_IDIC')

		//Se tiver apenas uma linha, e ela estiver vazia, não entra nesta condição
		If oModelDGP:getQtdLine() != 1 .OR. AllTrim(oModelDGP:GetValue('DGP_NRVRAC')) != ""
			dbSelectArea("DG0")
			DG0->(dbSetOrder(1))
			//Monta a condição do where para todas as versões associadas a pendencia
			For nI:= 1 To oModelDGP:getQtdLine()
				oModelDGP:GoLine(nI)

				if !oModelDGP:IsDeleted()
					cNRVRAC := oModelDGP:GetValue('DGP_NRVRAC')
					DG0->(dbSeek( xFilial("DG0") + cCDACDV + cNRVRAC ))

					If Val(DG0->DG0_TPST) >= 6
						DPRXError( 'DPRA350', STR0015 + cNRVRAC + STR0038, 4 )//A versão x já esta liberada

						lRet := .F.

						Exit
					EndIf

					// Verifica se existe um pendência em outra filial com o mesmo produto e versão
					if lCompaDGP

						BeginSql Alias cAliasDGP
							
							Select * from %Table:DGP% DGP
								WHERE DGP.DGP_CDACDV=%Exp:cCDACDV% AND
									DGP.DGP_NRVRAC=%Exp:cNRVRAC% AND
									DGP.%NotDel%
						EndSql

						While (cAliasDGP)->(!EOF())
							if (cAliasDGP)->DGP_IDIC != cIDIC
								// Então produto e versão já foi usado em outra pendência de desenvolvimento
								DPRXError( 'DPRA350', STR0039, 1, STR0040 ) // 'Já existe pendência de desenvolvimento utilizando este produto desenvolvido com esta versão' ## Selecione outro produto/versão'

								lRet := .F.

								Exit
							Endif

							(cAliasDGP)->(dbSkip())
						End

						(cAliasDGP)->(dbCloseArea())

						if !lRet
							Exit
						Endif
					Else
						dbSelectArea('DGP')
						DGP->(dbSetOrder(2))
						IF DGP->(dbSeek(xFilial('DGP')+cCDACDV+cNRVRAC)) .and. DGP->DGP_IDIC != cIDIC
							// Então produto e versão já foi usado em outra pendência de desenvolvimento
							DPRXError( 'DPRA350', STR0039, 1, STR0040 ) // 'Já existe pendência de desenvolvimento utilizando este produto desenvolvido com esta versão' ## Selecione outro produto/versão'

							lRet := .F.

							Exit
						Endif
					Endif

					if lCompaDGH

						// Verificar se existe ordem protótipo, se existir, pendência deverá ser da mesma filial
						BeginSql Alias cAliasDGH
							
							Select * from %Table:DGH% DGH
								WHERE DGH.DGH_CDACDV=%Exp:cCDACDV% AND
									DGH.DGH_NRVRAC=%Exp:cNRVRAC% AND
									DGH.%NotDel%
						EndSql

						if !Empty((cAliasDGH)->DGH_NRORPO) .AND. (cAliasDGH)->DGH_FILIAL != xFilial('DGH')
							DPRXError( 'DPRA350', STR0041 + (cAliasDGH)->DGH_FILIAL + STR0045 + (cAliasDGH)->DGH_NRORPO, 4) // 'Existe ordem protótipo para outra filial. Filial: ' ## ' Ordem Protótipo: '

							lRet := .F.
						Endif

						(cAliasDGH)->(dbCloseArea())

						if !lRet
							Exit
						Endif
					Endif
				Else
					aAdd(aDelete,nI)
				Endif
			Next

			//Verifica se possui ordem, pois se está eliminando a versão da pendência, deve avisar q já existe ordem protótipo
			If Len( aDelete ) > 0
				dbSelectArea( "DGH" )
				DGH->(dbSetOrder( 1 ))
				For nI := 1 To Len( aDelete )
					oModelDGP:GoLine(aDelete[nI])

					//Verifica se há algum uma ordem de prototipo cadastrada para a versão
					if DPRXCOMP(2)

						BeginSql Alias cAliasDGH
					
							Select * from %Table:DGH% DGH
								WHERE DGH.DGH_CDACDV=%Exp:oModelDGP:GetValue( "DGP_CDACDV" )% AND
									DGH.DGH_NRVRAC=%Exp:oModelDGP:GetValue( "DGP_NRVRAC" )% AND
									DGH.%NotDel%
						EndSql

						If( DGH->( dbSeek( (cAliasDGH)->DGH_FILIAL + oModelDGP:GetValue( "DGP_CDACDV" ) + oModelDGP:GetValue( "DGP_NRVRAC" ) ) ) )
							//Para todas as ordens de prototipo
							While DGH->( !EOF() ) .AND. DGH->DGH_FILIAL == (cAliasDGH)->DGH_FILIAL .AND. DGH->DGH_CDACDV == oModelDGP:GetValue( "DGP_CDACDV" ) .AND. DGH->DGH_NRVRAC == oModelDGP:GetValue( "DGP_NRVRAC" )
								//Concatena os números de ordens para apresentar na mensagem
								cOrdProt := cOrdProt + DGH->DGH_NRORPO
								DGH->( dbSkip() )
							End
							//Para cada versão associada apresenta esta mensagem
							alert( STR0015 + AllTrim(DGP->DGP_NRVRAC) + STR0016 + AllTrim(DGP->DGP_CDACDV) + STR0023 + AllTrim(cOrdProt) ) //"A versão x do produto x tem a(s) ordem(ns) protótipo: x "

							cOrdProt := ""
						EndIf

						(cAliasDGH)->(dbCloseArea())

					Else

						If( DGH->( dbSeek( xFilial( "DGH" ) + oModelDGP:GetValue( "DGP_CDACDV" ) + oModelDGP:GetValue( "DGP_NRVRAC" ) ) ) )
							//Para todas as ordens de prototipo
							While DGH->( !EOF() ) .AND. DGH->DGH_FILIAL == xFilial( "DGH" ) .AND. DGH->DGH_CDACDV == oModelDGP:GetValue( "DGP_CDACDV" ) .AND. DGH->DGH_NRVRAC == oModelDGP:GetValue( "DGP_NRVRAC" )
								//Concatena os números de ordens para apresentar na mensagem
								cOrdProt := cOrdProt + DGH->DGH_NRORPO
								DGH->( dbSkip() )
							End
							//Para cada versão associada apresenta esta mensagem
							alert( STR0015 + AllTrim(DGP->DGP_NRVRAC) + STR0016 + AllTrim(DGP->DGP_CDACDV) + STR0023 + AllTrim(cOrdProt) ) //"A versão x do produto x tem a(s) ordem(ns) protótipo: x "
							cOrdProt := ""
						EndIf
					Endif
				Next
			EndIf
		EndIf
	ENDIF
Return lRet

//-------------------------------------------------------------------
//Alteração da Pendencia
//-------------------------------------------------------------------
Static Function DPRA350UOP(cNRBU,cNRSQBU,cCDACBU,cNRPD,cNRSQPD,cCDACPD,cCDACDV,cIDIC,oModelDGP,cIDNV)
	If AllTrim(cNRBU) != "" .OR. AllTrim(cNRSQBU) != "" .OR. AllTrim(cCDACBU) != ""
		//Verifica se foi informado todas as informações do orçamento
		If AllTrim(cNRBU) == "" .OR. AllTrim(cNRSQBU) == "" .OR. AllTrim(cCDACBU) == ""
			DPRXError( 'DPRA350', STR0018, 4 )//"Não foi informado todas as informações do orçamento."
			Return .F.
		EndIf
		//Verifica se o produto informado é válido
		dbSelectArea( "CZ3" )
		CZ3->( dbSetOrder( 1 ) )
		If CZ3->( !dbSeek( xFilial( "CZ3" ) + cCDACBU ) )
			DPRXError( 'DPRA350', STR0018, 4 )//"Produto informado não encontrado."
			Return .F.
		EndIf
	EndIf
	//Se forem informados todas informações do pedido
	If AllTrim(cNRPD) != "" .OR. AllTrim(cNRSQPD) != "" .OR. AllTrim(cCDACPD) != ""
		//Verifica se foi informado todas as informações do pedido
		If AllTrim(cNRPD) == "" .OR. AllTrim(cNRSQPD) == "" .OR. AllTrim(cCDACPD) == ""
			DPRXError( 'DPRA350', STR0019, 4 )//"Não foi informado todas as informações do pedido."
			Return .F.
		EndIf
		//Verifica se o produto informado é válido
		dbSelectArea( "CZ3" )
		CZ3->( dbSetOrder( 1 ) )
		If CZ3->( !dbSeek( xFilial( "CZ3" ) + cCDACPD ) )
			DPRXError( 'DPRA350', STR0013, 4 )//"Produto informado não encontrado."
			Return .F.
		EndIf
	EndIf
	//Verifica se existe alguma versão liberada ou repetida
	If !VerifVersL(cCDACDV,oModelDGP)
		Return .F.
	Else
		InsNarrat(cIDNV,cCDACDV,oModelDGP)
	EndIf

Return .T.
//-------------------------------------------------------------------
//Exclusão de pendencia
//-------------------------------------------------------------------
Static Function DPRA350DLP(cNRBU,cNRSQBU,cCDACBU,cNRPD,cNRSQPD,cCDACPD)
	Local lHist		:= SuperGetMV('MV_DPRHIST',.F.,.F.)
	Local aProducts	:= {}
	Local cTipo		:= "PV"
	Local cOrdProt	:= ""
	Local nI
	Default lAutoMacao := .F.

	//Se forem informados todas informações do pedido
	If AllTrim(cNRPD) != "" .OR. AllTrim(cNRSQPD) != "" .OR. AllTrim(cCDACPD) != ""
		//Verifica se foi informado todas as informações do pedido
		If AllTrim(cNRPD) == "" .OR. AllTrim(cNRSQPD) == "" .OR. AllTrim(cCDACPD) == ""
			DPRXError( 'DPRA350', STR0019, 4 )//"Não foi informado todas as informações do pedido."
			Return .F.
		EndIf
	ElseIf AllTrim(cNRBU) != "" .OR. AllTrim(cNRSQBU) != "" .OR. AllTrim(cCDACBU) != ""
		//Verifica se foi informado todas as informações do orçamento
		If AllTrim(cNRBU) == "" .OR. AllTrim(cNRSQBU) == "" .OR. AllTrim(cCDACBU) == ""
			DPRXError( 'DPRA350', STR0018, 4 )//"Não foi informado todas as informações do orçamento."
			Return .F.
		EndIf
		cTipo := "ORC"
	EndIf

	//Aponta a pendencia, independente de pedido ou orçamento
	dbSelectArea( "DGC" )
	If cTipo == "PV"
		dbSetOrder(2)
		If DGC->( !dbSeek( xFilial( "DGC" ) + cNRPD + cNRSQPD + cCDACPD ) )
			DPRXError( 'DPRA350', STR0020, 4 )//"Não encontrou o pedido informado"
			IF !lAutoMacao
				Return .F.
			ENDIF
		EndIf
	Else
		dbSetOrder(3)
		If DGC->( !dbSeek( xFilial( "DGC" ) + cNRBU + cNRSQBU + cCDACBU ) )
			DPRXError( 'DPRA350', STR0021, 4 )//"Não encontrou o orçamento informado"
			Return .F.
		EndIf
	EndIf

	//Verifica as versões associadas a esta pendencia
	dbSelectArea( "DGP" )
	DGP->( dbSetOrder( 1 ) )

	If DGP->( dbSeek( xFilial( "DGP" ) + DGC->DGC_IDIC ) )
		//Para todas versões
		While DGP->( !EOF() ) .AND. DGP->DGP_FILIAL == xFilial( "DGP" ) .AND. DGP->DGP_IDIC == DGC->DGC_IDIC
			//Altera a situação de cada versão

			dbSelectArea( "DG0" )
			DG0->( dbSetOrder( 1 ) )
			DG0->( dbSeek( xFilial( "DG0" ) + DGP->DGP_CDACDV + DGP->DGP_NRVRAC ) )
			//Preenche a array com produtos
			if !DPR341FIND( "2", @aProducts )
				Return .F.
			Endif

			//Verifica se há algum uma ordem de prototipo cadastrada para a versão
			dbSelectArea( "DGH" )
			DGH->( dbSetOrder( 1 ) )

			If( DGH->( dbSeek( xFilial( "DGH" ) + DGP->DGP_CDACDV + DGP->DGP_NRVRAC ) ) )
				//Para todas as ordens de prototipo
				While DGH->( !EOF() ) .AND. DGH->DGH_FILIAL == xFilial( "DGH" ) .AND. DGH->DGH_CDACDV == DGP->DGP_CDACDV .AND. DGH->DGH_NRVRAC == DGP->DGP_NRVRAC
					//Concatena os números de ordens para apresentar na mensagem
					cOrdProt := cOrdProt + DGH->DGH_NRORPO
					DGH->( dbSkip() )
				End

				//Para cada versão associada apresenta esta mensagem
				alert( STR0015 + AllTrim(DGP->DGP_NRVRAC) + STR0016 + AllTrim(DGP->DGP_CDACDV) + STR0023 + AllTrim(cOrdProt) ) //"A versão x do produto x tem a(s) ordem(ns) protótipo: x "
			EndIf

			cOrdProt := ""
			DGP->( dbSkip() )
		End

		For nI := 1 To Len(aProducts)
			//Faz a alteração das situações
			DPRA341SAV( aProducts[nI][1], aProducts[nI][2], aProducts[nI][3] )
			// Guarda o histórico de aprovação
			If lHist
				DPRA341HIS( aProducts[nI][1], aProducts[nI][2], aProducts[nI][3] )
			EndIf
		Next

	EndIf
Return .T.

//-------------------------------------------------------------------
//Executa a função ExecAuto para integração com Faturamento - Aprova Pendencia
//-------------------------------------------------------------------
Static Function AprovaPend(cCodPend)
	Local lRet			:= .T.
	Local aHeadC6		:= {}
	Local aHeadD4		:= {}
	Local cCampo
	Local aStruSC6 := SC6->(DBStruct())
	Local aStruSD4 := SD4->(DBStruct())
	Local nCount := 0
	Private lMsErroAuto := .F.
	Private N

	DbSelectArea( "DGC" )
	DGC->( DbSetOrder( 1 ) )
	DGC->( dbSeek( xFilial( "DGC" ) + cCodPend ) )

	If AllTrim(DGC->DGC_NRPD) == ""
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHeader do SC6                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeadC6 := {}

		For nCount := 1 To Len(aStruSC6)
			cCampo := AllTrim(aStruSC6[nCount,1])

			If(((X3Uso(GetSx3Cache(cCampo,'X3_USADO')) .And. ;
					!( Trim(cCampo) == "C6_NUM" ) .And.;
					Trim(cCampo) != "C6_QTDEMP"  .And.;
					Trim(cCampo) != "C6_QTDENT") .And.;
					cNivel >= GetSx3Cache(cCampo,'X3_NIVEL')) .Or.;
					Trim(cCampo)=="C6_NUMORC" .Or. ;
					Trim(cCampo)=="C6_NUMOP"  .Or. ;
					Trim(cCampo)=="C6_ITEMOP" .Or. ;
					Trim(cCampo)=="C6_OP" .Or. ;
					Trim(cCampo)=="C6_OPC";
					)

				Aadd(aHeadC6,{TRIM(GetSx3Cache(cCampo,'X3_TITULO')),;
					cCampo,;
					X3PICTURE(cCampo),;
					aStruSC6[nCount,3],;
					aStruSC6[nCount,4],;
					If(Trim(cCampo)=="C6_NUMORC",".F.",GetSx3Cache(cCampo,'X3_VALID')),;
						X3Uso(GetSx3Cache(cCampo,'X3_USADO')),;
						aStruSC6[nCount,2],;
						"SC6",;
						GetSx3Cache(cCampo,'X3_CONTEXT') };
						)
				Endif

			Next nCount

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta aHeader do SD4                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCount := 1 To Len(aStruSD4)
				cCampo := AllTrim(aStruSD4[nCount,1])

				If X3Uso(GetSx3Cache(cCampo,'X3_USADO')) .And. cNivel >= GetSx3Cache(cCampo,'X3_NIVEL')

					Aadd(aHeadD4,{ Trim(GetSx3Cache(cCampo,'X3_TITULO')),;
						cCampo,;
						X3PICTURE(cCampo),;
						aStruSD4[nCount,3],;
						aStruSD4[nCount,3],;
						GetSx3Cache(cCampo,'X3_VALID'),;
						X3Uso(GetSx3Cache(cCampo,'X3_USADO')),;
						aStruSD4[nCount,2],;
						"SD4",;
						GetSx3Cache(cCampo,'X3_CONTEXT') })
				EndIf

			Next nCount

			MaBxOrc(AllTrim(DGC->DGC_NRBU),.F.,.F.,.T.,.F.,aHeadC6,aHeadD4,.F.)
		EndIf

		Return lRet
//-------------------------------------------------------------------
//Executa a função ExecAuto para integração com Faturamento - Altera Produto Pedido de Venda
//-------------------------------------------------------------------
Static Function AltProdPV(cNRPD,cNRSQPD,cProdDest,lAtualizaTipo)
	Local aStructSC5	:= {}
	Local aStructSC6	:= {}
	Local aHeader		:= {}
	Local aDetail		:= {}
	Local lRet          := .T.
	Local nI
	Local nX
	Local aArea         := GetArea()
	Local aAreaDGC      := DGC->(GetArea())
	Private lMsErroAuto := .F.

	// atribuindo valores ao cabecalho
	DbSelectArea( "SC5" )
	SC5->( DbSetOrder( 1 ) )
	If SC5->( DbSeek( xFilial("SC5") + cNRPD ) )
		aStructSC5 := SC5->(dbStruct())
		For nI := 1 To Len( aStructSC5 )
			aAdd( aHeader, { aStructSC5[nI][1], SC5->&(aStructSC5[nI][1]), Nil } )
		Next
		// atribuindo valores aos itens
		DbSelectArea( "SC6" )
		SC6->( DbSetOrder( 1 ) )
		If SC6->(DbSeek(xFilial("SC6") + AllTrim(cNRPD)))
			aStructSC6 := SC6->(dbStruct())
			nX := 1
			While SC6->(!Eof()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. AllTrim(SC6->C6_NUM) == AllTrim(cNRPD)

				//Incluindo SB2 para o produto desenvolvido
				dbSelectArea("DGC")
				DGC->(dbSetOrder(2))
				If DGC->(DbSeek(xFilial("DGC") + cNRPD))
					While DGC->(!Eof()) .AND. DGC->DGC_FILIAL == xFilial("DGC") .AND. AllTrim(DGC->DGC_NRPD) == AllTrim(cNRPD)
						CriaSB2( DGC->DGC_CDACPD,SC6->C6_LOCAL )
						CriaSB2( DGC->DGC_CDACDV,SC6->C6_LOCAL )
						DGC->( DbSkip() )
					EndDo
				EndIf

				aAdd( aDetail, {} )
				For nI := 1 To Len( aStructSC6 )
					If ( aStructSC6[nI][1] == "C6_ITEM" )
						aAdd( aDetail[nX], { aStructSC6[nI][1],SC6->C6_ITEM, Nil } )
					ElseIf AllTrim(SC6->C6_ITEM) == AllTrim(cNRSQPD) .AND. aStructSC6[nI][1] == "C6_PRODUTO"
						aAdd( aDetail[nX], { aStructSC6[nI][1], cProdDest, Nil } )
					ElseIf ( aStructSC6[nI][1] == "C6_SEGUM" )
						aAdd( aDetail[nX], { aStructSC6[nI][1], SC6->C6_UM, Nil } )
					ElseIf ( aStructSC6[nI][1] == "C6_TPPROD" )
						aAdd( aDetail[nX], { aStructSC6[nI][1], if(lAtualizaTipo,"1","2"), Nil } )
					ElseIf ( aStructSC6[nI][1] == "C6_PRCVEN" )
						aAdd( aDetail[nX], { aStructSC6[nI][1], SC6->C6_PRCVEN, Nil } )
					ElseIf X3Obrigat(aStructSC6[nI][1])
						aAdd( aDetail[nX], { aStructSC6[nI][1], SC6->&(aStructSC6[nI][1]), Nil } )
					EndIf
				Next nI
				nX++
				SC6->( DbSkip() )
			EndDo
		EndIf

		// Criando pedido de venda atraves do ExecAuto
		MSExecAuto( { |x, y, z, k| Mata410(x, y, z, /*lSimulacao*/,/*cRotina*/,/*cCodCli*/,/*cLoja*/,/*xRatCTBPC*/,/*xAdtPC*/,/*xParamAuto*/, k) }, aHeader, aDetail, 4, .T. )
		//Trata erro na ExecAuto
		If ( lMsErroAuto )
			lRet := .F.
			//MostraErro()
			//aLog := GetAutoGRLog()
			//msginfo(aLog[1])
			// Não adianta o mostraerro, o erro é lido com GetAutoGRLog no DPRA342
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaDGC)

Return lRet
//-------------------------------------------------------------------
//Executa a função ExecAuto para integração com Faturamento - Altera Produto Orçamento
//-------------------------------------------------------------------
Static Function AltProdOrc(cNRBU,cNRSQBU,cProdDest)
	Local aStructSCJ	:= {}
	Local aStructSCK	:= {}
	Local aHeader		:= {}
	Local aDetail		:= {}
	Local lRet := .T.
	Local nI
	Local nX
	Private lMsErroAuto := .F.
	Default lAutoMacao := .F.

	// atribuindo valores ao cabecalho
	DbSelectArea( "SCJ" )
	SCJ->( DbSetOrder( 1 ) )
	If SCJ->( DbSeek( xFilial("SCJ") + AllTrim(cNRBU) ) )
		aStructSCJ := SCJ->( dbStruct() )
		For nI := 1 To Len( aStructSCJ )
			aAdd( aHeader, { aStructSCJ[nI][1], SCJ->&(aStructSCJ[nI][1]), Nil } )
		Next
		// atribuindo valores aos itens
		DbSelectArea( "SCK" )
		SCK->( DbSetOrder( 1 ) )
		If SCK->( DbSeek( xFilial( "SCK" ) + AllTrim( cNRBU ) ) )
			aStructSCK := SCK->( dbStruct() )
			nX := 1
			While SCK->( !Eof() ) .AND. SCK->CK_FILIAL == xFilial( "SCK" ) .AND. AllTrim(SCK->CK_NUM) == AllTrim(cNRBU)
				aAdd( aDetail, {} )
				For nI := 1 To Len( aStructSCK )
					If AllTrim(SCK->CK_ITEM) == AllTrim(cNRSQBU) .AND. aStructSCK[nI][1] == "CK_PRODUTO"
						aAdd( aDetail[nX], { aStructSCK[nI][1], cProdDest, Nil } )
					ElseIf ( aStructSCK[nI][1] <> "CK_FILVEN") .And. ((aStructSCK[nI][1] <> "CK_FILENT") )
						aAdd( aDetail[nX], { aStructSCK[nI][1], SCK->&(aStructSCK[nI][1]), Nil } )
					EndIf
				Next
				nX++
				SCK->( DbSkip() )
			EndDo
		EndIf
		MSExecAuto( { |x, y, z, w, k| Mata415(x, y, z, w, k) }, aHeader, aDetail, 4, .F., .T. )
		//Trata erro na ExecAuto
		If ( lMsErroAuto )
			lRet := .F.
			IF !lAutoMacao
				MostraErro()
			ENDIF
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------
//Resgata o produto destino pelo produto Desenvolvido e verifica se existe na CZ3
//-------------------------------------------------------------------
Static Function RVProdDest(cProdDesenv)
	Local cProdDest := ""

	//Carrega o produto destino do produto desenvolvido
	dbSelectArea( "DG3" )
	DG3->( dbSetOrder( 1 ) )
	If DG3->( dbSeek( xFilial( "DG3" ) + cProdDesenv ) )
		//Verifica se o produto destino está cadastrado na CZ3
		dbSelectArea( "CZ3" )
		CZ3->( dbSetOrder( 1 ) )
		If CZ3->( dbSeek( xFilial( "CZ3" ) + DG3->DG3_CDACDE ) )
			cProdDest := DG3->DG3_CDACDE
		Else
			alert( STR0024 + AllTrim(DG3->DG3_CDACDE) + STR0025 + AllTrim(DG3->DG3_DSACDE) + STR0026)//O produto de código x e descrição x não está cadastrado como item.
		EndIf
	EndIf
Return cProdDest
//-------------------------------------------------------------------
//Verifica se é um orçamento ou pedido de venda e chama a função conforme o necessário
//-------------------------------------------------------------------
Static Function AlteraProd( cCodPend, lAtualizaTipo )
	Local oModel350	:= FWLoadModel( 'DPRA350' )
	Local cProdDest := ""
	Local aErro := {}

	//Localiza Pendencia
	DbSelectArea( "DGC" )
	DGC->( DbSetOrder( 1 ) )
	DGC->( DbSeek( xFilial( "DGC" ) + cCodPend ) )

	//Se forem informados todas informações do pedido
	If AllTrim(DGC->DGC_NRPD) != "" .OR. AllTrim(DGC->DGC_NRSQPD) != "" .OR. AllTrim(DGC->DGC_CDACPD) != ""
		//Verifica se foi informado todas as informações do pedido
		If AllTrim(DGC->DGC_NRPD) == "" .OR. AllTrim(DGC->DGC_NRSQPD) == "" .OR. AllTrim(DGC->DGC_CDACPD) == ""
			DPRXError( 'DPRA350', STR0019, 4 )//"Não foi informado todas as informações do pedido."
			Return .F.
		EndIf
		//Verifica se possui um produto destino valido no produto desenvolvido
		cProdDest := RVProdDest(DGC->DGC_CDACDV)
		If AllTrim(cProdDest) != ""
			//Se alterar o código do produto no pedido de venda do faturamento, altera na pendencia tambem
			If( AltProdPV( DGC->DGC_NRPD,DGC->DGC_NRSQPD,cProdDest,lAtualizaTipo ) )
				oModel350:SetOperation( MODEL_OPERATION_UPDATE )
				oModel350:Activate()
				oModel350:SetValue("DGCMASTER","DGC_CDACPD",cProdDest)
				// Valida o modelo
				If oModel350:VldData()
					oModel350:CommitData()
				Else
					aErro := oModel350:GetErrorMessage()
					DPRXError( 'DPRA350', STR0027 + AllToChar( aErro[6] ), 4 )//Mensagem do erro: x
					Return .F.
				EndIf

				oModel350:DeActivate()
			Else
				Return .F.
			EndIf
		Else
			DPRXError( 'DPRA350', STR0028 , 4 )//"Não foi encontrado nenhum produto destino"
			Return .F.
		EndIf

		//Se forem informados todas informações do orçamento
	ElseIf AllTrim(DGC->DGC_NRBU) != "" .OR. AllTrim(DGC->DGC_NRSQBU) != "" .OR. AllTrim(DGC->DGC_CDACBU) != ""
		//Verifica se foi informado todas as informações do orçamento
		If AllTrim(DGC->DGC_NRBU) == "" .OR. AllTrim(DGC->DGC_NRSQBU) == "" .OR. AllTrim(DGC->DGC_CDACBU) == ""
			DPRXError( 'DPRA350', STR0018 , 4 )//"Não foi informado todas as informações do orçamento."
			Return .F.
		EndIf
		//Verifica se possui um produto destino valido no produto desenvolvido
		cProdDest := RVProdDest(DGC->DGC_CDACDV)
		If AllTrim(cProdDest) != ""
			//Se alterar o código do produto no orçamento do faturamento, altera na pendencia tambem
			If( AltProdOrc( DGC->DGC_NRBU,DGC->DGC_NRSQBU,cProdDest ) )
				oModel350:SetOperation( MODEL_OPERATION_UPDATE )
				oModel350:Activate()
				oModel350:SetValue("DGCMASTER","DGC_CDACBU",cProdDest)
				// Valida o modelo
				If oModel350:VldData()
					oModel350:CommitData()
				Else
					aErro := oModel350:GetErrorMessage()
					DPRXError( 'DPRA350', STR0027 + AllToChar( aErro[6] ) , 4 )//"Mensagem do erro: x "
					Return .F.
				EndIf

				oModel350:DeActivate()
			Else
				Return .F.
			EndIf
		Else
			DPRXError( 'DPRA350', STR0028 , 4 )//"Não foi encontrado nenhum produto destino"
			Return .F.
		EndIf
	EndIf
Return .T.

//-------------------------------------------------------------------
//Executa a função ExecAuto para integração com Faturamento - Exclui Pendencia
//-------------------------------------------------------------------
Static Function ExcluiOrc(cCodPend)
	Local aStructSCJ	:= {}
	Local aStructSCK	:= {}
	Local aHeader		:= {}
	Local aDetail		:= {}
	Local nI
	Local nX

	dbSelectArea( "DGC" )
	DGC->( dbSetOrder( 1 ) )
	DGC->( dbSeek( xFilial( "DGC" ) + cCodPend ) )

	// atribuindo valores ao cabecalho
	DbSelectArea( "SCJ" )
	SCJ->( DbSetOrder( 1 ) )
	If SCJ->( DbSeek( xFilial( "SCJ" ) + AllTrim(DGC->DGC_NRBU) ) )

		aStructSCJ := SCJ->(dbStruct())

		For nI := 1 To Len( aStructSCJ )
			aAdd( aHeader, { aStructSCJ[nI][1], SCJ->&(aStructSCJ[nI][1]), Nil } )
		Next

		// atribuindo valores aos itens
		DbSelectArea( "SCK" )
		SCK->( DbSetOrder( 1 ) )

		If SCK->( DbSeek( xFilial( "SCK" ) + AllTrim( DGC->DGC_NRBU ) ) )
			aStructSCK := SCK->( dbStruct() )
			nX := 1
			While SCK->(!Eof()) .AND. SCK->CK_FILIAL == xFilial("SCK") .AND. AllTrim(SCK->CK_NUM) == AllTrim(DGC->DGC_NRBU)
				aAdd(aDetail, {})
				For nI := 1 To Len( aStructSCK )
					If (aStructSCK[nI][1] <> "CK_FILVEN") .And. ((aStructSCK[nI][1] <> "CK_FILENT"))
						aAdd( aDetail[nX], { aStructSCK[nI][1], SCK->&(aStructSCK[nI][1]), Nil } )
					EndIf
				Next
				nX++
				SCK->(DbSkip())
			EndDo
		EndIf
		MSExecAuto( { |x, y, z, w, k| Mata415(x, y, z, w, k) }, aHeader, aDetail, 5, .F., .T.  )
	EndIf

Return .T.
//-------------------------------------------------------------------
//Pre-validação do Model, insere o código do produto e pendencia na versão
//-------------------------------------------------------------------
Static Function DPRA350PRE(oModel)
	Local var			:= 0
	Local oModelDGP	:= oModel:GetModel('DGPDETAIL')
	Local oModelDGC	:= oModel:GetModel('DGCMASTER')

	//Se tiver apenas uma linha, e ela estiver vazia, não entra nesta condição
	If oModel:GetOperation() != 1 .AND. (oModelDGP:getQtdLine() != 1 .OR. AllTrim(oModelDGP:GetValue('DGP_NRVRAC')) != "")
		//Seta o produto desenvolvido da pendencia em todas as versões
		For var:= 1 To oModelDGP:getQtdLine()
			oModelDGP:GoLine(var)
			oModelDGP:SetValue('DGP_IDIC',oModelDGC:GetValue('DGC_IDIC'))
			oModelDGP:SetValue('DGP_CDACDV',oModelDGC:GetValue('DGC_CDACDV'))
		Next
	EndIf
Return .T.
//-------------------------------------------------------------------
//Pos-validacao do Model
//-------------------------------------------------------------------
Static Function DPRA350POS(oModel)
	Local lRet := .T.
	Local nOpc := oModel:GetOperation()
	Local aValidaDPR := ValidaDPR()
	Local nI         := 0

	Local cIDIC   := oModel:GetValue('DGCMASTER','DGC_IDIC')		//Código Pendencia
	Local cCDACDV := oModel:GetValue('DGCMASTER','DGC_CDACDV')	//Produto Desenvolvido
	Local cIDNV   := oModel:GetValue('DGCMASTER','DGC_IDNV')		//Produto Desenvolvido
	Local cNRBU   := oModel:GetValue('DGCMASTER','DGC_NRBU')		//Número Orçamento
	Local cNRSQBU := oModel:GetValue('DGCMASTER','DGC_NRSQBU')	//Número Sequencial Orçamento
	Local cCDACBU := oModel:GetValue('DGCMASTER','DGC_CDACBU')	//Produto Orçamento
	Local cNRPD   := oModel:GetValue('DGCMASTER','DGC_NRPD')		//Número Pedido
	Local cNRSQPD := oModel:GetValue('DGCMASTER','DGC_NRSQPD')	//Número Sequencial Pedido
	Local cCDACPD := oModel:GetValue('DGCMASTER','DGC_CDACPD')	//Produto PedidoADM
	Local cLGFTEV := oModel:GetValue('DGCMASTER','DGC_LGFTEV')	//Confirma Fat

	Local oModelDGP := oModel:GetModel('DGPDETAIL')

	if IsInCallStack('DPRA342LIB') .OR. IsInCallStack('AlteraProd')
		Return .T.
	Endif

	//Identificar se há diferença de exclusividade/compartilhamento entre as tabelas SG1 e SCK
	If !ValidFATDP()
		Return .F.
	EndIf

	// Valida se o programa pode ser aberto
	If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
		Final(aValidaDPR[2])
		Return .F.
	ElseIf !Empty( aValidaDPR[2] )
		DPRXError( "DPRA350", aValidaDPR[2], 3 )
		Return .F.
	EndIf

	// Define o valor da narrativa
	If !Empty( FwFldGet('DG6_DSNV') ) .And. Empty( FwFldGet('DG6_IDNV') )
		oModel:GetModel('DG6DETAIL'):LoadValue("DG6_IDNV", GETSXENUM('DG6', 'DG6_IDNV', RetSQLName( 'DG6' ), 1 ) )
		oModel:GetModel('DGCMASTER'):LoadValue("DGC_IDNV", FwFldGet('DG6_IDNV') )
	EndIf

	//Verifica se a pendencia possui uma versão liberada
	If cLGFTEV == "1"
		DPRXError( 'DPRA350', STR0010, 4 ) // "Esta pendencia já possui uma versão liberada."
		Return .F.
	EndIf

	//Se não for exclusão
	If nOpc != 5
		//Verifica se já existe um orçamento com os mesmos codigos
		If AllTrim(cNRBU) != "" .OR. AllTrim(cNRSQBU) != "" .OR. AllTrim(cCDACBU) != ""
			DbSelectArea( "DGC" )
			DGC->( DbSetOrder( 3 ) )
			If DGC->( DbSeek(xFilial("DGC") + cNRBU + cNRSQBU + cCDACBU ) )
				If nOpc == 4
					While DGC->( !EOF() ) .AND. DGC->DGC_NRBU == cNRBU .AND. DGC->DGC_NRSQBU == cNRSQBU .AND. DGC->DGC_CDACBU == cCDACBU
						nI++
						If nI >= 2
							DPRXError( 'DPRA350', STR0030, 4 ) // "Já existe um orçamento com este código item e produto"
							Return .F.
						EndIf
						DGC->(dbSkip())
					End
				Else
					DPRXError( 'DPRA350', STR0030, 4 ) // "Já existe um orçamento com este código item e produto"
					Return .F.
				EndIf
			EndIf
		EndIf
		nI := 0
		//Verifica se já existe um pedido com os mesmos codigos
		If AllTrim(cNRPD) != "" .OR. AllTrim(cNRSQPD) != "" .OR. AllTrim(cCDACPD) != ""
			DbSelectArea( "DGC" )
			DGC->( DbSetOrder( 2 ) )
			If DGC->( DbSeek(xFilial("DGC") + cNRPD + cNRSQPD + cCDACPD ) )
				If nOpc == 4
					While DGC->( !EOF() ) .AND. DGC->DGC_FILIAL == xFilial('DGC') .and. DGC->DGC_NRPD == cNRPD .AND. DGC->DGC_NRSQPD == cNRSQPD .AND. DGC->DGC_CDACPD == cCDACPD
						nI++
						If nI >= 2
							DPRXError( 'DPRA350', STR0031, 4 ) // "Já existe um pedido de venda com este código item e produto"
							Return .F.
						EndIf
						DGC->(dbSkip())
					End
				Else
					DPRXError( 'DPRA350', STR0031, 4 ) // "Já existe um pedido de venda com este código item e produto"
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf

	if lRet
		Begin Transaction
			//Se for operação de inclusão de pendencia
			if nOpc == 3
				//Valida inclusão
				lRet	:= DPRA350INC(cNRBU,cNRSQBU,cCDACBU,cNRPD,cNRSQPD,cCDACPD,cCDACDV,cIDIC,oModelDGP,cIDNV)
				//Se for operação de alteração de pendencia
			ElseIf nOpc == 4
				//Se não foi enviado produto desenvolvido nem versão
				lRet	:= DPRA350UOP(cNRBU,cNRSQBU,cCDACBU,cNRPD,cNRSQPD,cCDACPD,cCDACDV,cIDIC,oModelDGP,cIDNV)
				//Se for operação de exclusao de pendencia
			ElseIf nOpc == 5
				//Cancelamento
				lRet	:= DPRA350DLP(cNRBU,cNRSQBU,cCDACBU,cNRPD,cNRSQPD,cCDACPD)
			Endif

			if !lRet
				DisarmTransaction()
			Endif

		End Transaction
	Endif

Return lRet
//------------------------------------------------------------------
//Valida Produto Desenvolvido
//Gatilho do campo Produto Desenvolvido
//------------------------------------------------------------------
Function DPRA350VPD()
	Local oModel		:= FWModelActive()
	Local oModelDGP	:= oModel:GetModel('DGPDETAIL')
	Local oModelDGC	:= oModel:GetModel('DGCMASTER')
	Local lRet			:= .T.

	If oModelDGC:GetValue('DGC_CDACDV') != oModelDGP:GetValue('DGP_CDACDV') .AND. (oModelDGP:getQtdLine() != 1 .OR. AllTrim(oModelDGP:GetValue('DGP_NRVRAC')) != "")
		DPRXError( 'DPRA350', STR0032 , 4 )//"Você não pode alterar o produto desenvolvido sem remover as versões associadas a ele antes."
		lRet := .F.
	EndIf
Return lRet
//------------------------------------------------------------------
//Valida Versão Pendencia
//Gatilho do campo Versão Pendencia
//------------------------------------------------------------------
Function DPRA350VVP()
	Local oModel	:= FWModelActive()
	Local lRet		:= .T.
	Local oModelDGP

	If AllTrim(oModel:GetValue("DGPDETAIL","DGP_NRVRAC")) != ""
		DPRA350PRE(oModel)
	EndIf
	//Se for informado alguma versão, verifica se existe na DG0
	If AllTrim(M->DGP_NRVRAC) != ""
		dbSelectArea("DG0")
		DG0->( dbSetOrder(1) )
		If DG0->( dbSeek( xFilial( "DG0" ) + oModel:GetValue("DGCMASTER","DGC_CDACDV") + M->DGP_NRVRAC ) )

			if DG0->DG0_TPST == '2'
				DPRXError( 'DPRA350', 'Versão está suspensa' , 4 )
				lRet := .F.
			Else
				oModelDGP := oModel:GetModel("DGPDETAIL")
				oModelDGP:LoadValue("DGP_DSVR",DG0->DG0_DSVR)
			Endif
		Else
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------
//Suspende Versão do produto desenvolvido
//-------------------------------------------------------------------
Function DPRA350SVP(cProdDv,cNrVersao)
	Local oModel350	:= FWLoadModel( 'DPRA350' )
	Local cPend		:= ""
	Local lPossuiVr	:= .F.
	Local cAliasDGP := GetNextAlias()
	Local lRet      := .T.

	if DPRXCOMP(1)
		BeginSql Alias cAliasDGP
		    	
			Select * from %Table:DGP% DGP
				WHERE DGP.DGP_CDACDV=%Exp:cProdDv% AND
					  DGP.DGP_NRVRAC=%Exp:cNrVersao% AND
					  DGP.%NotDel%
		EndSql

		IF !Empty((cAliasDGP)->DGP_IDIC) .AND. (cAliasDGP)->DGP_FILIAL != xFilial('DGP')
			DPRXError( 'DPRA350', STR0042 + (cAliasDGP)->DGP_FILIAL, 1, STR0043 ) // 'Foi encontrada pendência na filial ' ## 'Acesse o módulo SIGADPR através desta filial.'
			Return .F.
		Else
			(cAliasDGP)->(dbCloseArea())
		Endif
	Endif

	dbSelectArea( "DGP" )
	DGP->( dbSetOrder(2) )
	//Se possuir uma pendencia
	If DGP->( dbSeek( xFilial( "DGP" ) + cProdDv + cNrVersao ) )
		cPend := DGP->DGP_IDIC
		DGP->( dbSetOrder(1) )
		DGP->( dbSeek( xFilial( "DGP" ) + cPend ) )
		//Verifica todas as versões da pendencia
		While DGP->( !EOF() ) .AND. DGP->DGP_FILIAL == xFilial( "DGP" ) .AND. DGP->DGP_IDIC == cPend
			//Verifica se a versão é diferente da atual
			If DGP->DGP_NRVRAC != cNrVersao
				//Verifica as informações da versão associada
				dbSelectArea( "DG0" )
				DG0->( dbSetOrder(1) )
				If DG0->( dbSeek( xFilial( "DG0" ) + cProdDv + DGP->DGP_NRVRAC ) )
					//Se houver uma versão no orçamento que não está suspensa, sai do while
					If DG0->DG0_TPST != "2"
						lPossuiVr := .T.
						Exit
					EndIf
				EndIf
			EndIf
			DGP->(dbSkip())
		End

		//Se possui outra versão, somente suspende esta, caso contrário, remove o orçamento
		If !lPossuiVr
			dbSelectArea( "DGC" )
			DGC->( dbSetOrder( 1 ) )
			DGC->( dbSeek( xFilial( "DGC" ) + cPend ) )

			oModel350:SetOperation( MODEL_OPERATION_DELETE )
			oModel350:Activate()

			// Valida o modelo
			If oModel350:VldData()
				if AllTrim(DGC->DGC_NRPD) != "" .OR. AllTrim(DGC->DGC_NRSQPD) != "" .OR. AllTrim(DGC->DGC_CDACPD) != ""
					DPRXError( 'DPRA350', STR0044, 4) // 'Existe pedido relacionado à esta versão. Elimine-o através do faturamento'
					lRet := .F.
				Else
					ExcluiOrc((cAliasDGP)->DGP_FILIAL + (cAliasDGP)->DGP_IDIC )
				Endif

				oModel350:CommitData()
			Else
				DPRXError( 'DPRA350', STR0029 + STR0015 + cNrVersao + STR0016 + cProdDv + STR0022 , 4 )//"O orçamento não pode ser excluido. A versão x do produto x não pode ser suspensa"
				lRet := .F.
			EndIf

			oModel350:DeActivate()
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------
//Aprova Versão do produto desenvolvido
//-------------------------------------------------------------------
Function DPRA350AVP(cProdDv,cNrVersao)
	Local lRet := .T.
	Local cAliasDGP := GetNextAlias()

	//Verifica se aprova a pendencia na aprovação apartir do parametro MV_DPRAPFT (0=Aprovação da Versão;1=Liberação da Versão)
	IF SuperGetMV("MV_DPRAPFT",.F.,0) == 0

		if DPRXCOMP(1)

			BeginSql Alias cAliasDGP
		
				Select * from %Table:DGP% as DGP
					WHERE DGP.DGP_CDACDV = %exp:cProdDv% AND 
						  DGP.DGP_NRVRAC = %exp:cNrVersao% AND 
					      DGP.%NotDel%
			EndSql

			IF !Empty((cAliasDGP)->DGP_IDIC) .and. (cAliasDGP)->DGP_FILIAL != xFilial('DGP')
				DPRXError( 'DPRA350', STR0042 + (cAliasDGP)->DGP_FILIAL, 1, STR0043 ) // 'Foi encontrada pendência na filial ' ## 'Acesse o módulo SIGADPR através desta filial.'
				Return .F.
			Else
				(cAliasDGP)->(dbCloseArea())
			Endif
		Endif

		// Instancia o modelo
		dbSelectArea( "DGP" )
		DGP->( dbSetOrder( 2 ) )

		If DGP->(dbSeek( xFilial( "DGP" ) + cProdDv + cNrVersao ))
			lRet := AprovaPend(DGP->DGP_IDIC)
		EndIf
	Endif

Return lRet
//-------------------------------------------------------------------
//Atualiza produto pendencia do faturamento
//-------------------------------------------------------------------
Function DPRA350APP()
	//Verifica se a pendencia já possui uma versão liberada
	If DGC->DGC_LGFTEV == "1"
		DPRXError( 'DPRA350', STR0010 , 4 )//"Esta pendencia já possui uma versão liberada."
		Return .F.
	EndIf
	//Exige que haja pelo menos uma versão cadastrada
	DbSelectArea( "DGP" )
	DGP->( DbSetOrder( 1 ) )
	If DGP->( DbSeek( xFilial( "DGP" ) + DGC->DGC_IDIC ) )
		//Altera o produto destino no faturamento
		AlteraProd(DGC->DGC_IDIC,.F.)
	Else
		alert( STR0033 )//"A pendência deve ter pelo menos uma versão associada."
	End
Return .T.
//-------------------------------------------------------------------
//Libera versão pendencia
//-------------------------------------------------------------------
Function DPRA350LVP(cProdDv,cNrVersao)
	Local cPend
	Local lRet      := .T.
	Local cAliasDGP := GetNextAlias()
	Local aAreaDG0  := DG0->(GetArea())
	Local lHist     := SuperGetMV('MV_DPRHIST',.F.,.F.)

	if DPRXCOMP(1)

		BeginSql Alias cAliasDGP
		    	
			Select * from %Table:DGP% DGP
				WHERE DGP.DGP_CDACDV=%Exp:cProdDv% AND
					  DGP.DGP_NRVRAC=%Exp:cNrVersao% AND
					  DGP.%NotDel%
		EndSql

		IF !Empty((cAliasDGP)->DGP_IDIC) .and. (cAliasDGP)->DGP_FILIAL != xFilial('DGP')
			DPRXError( 'DPRA350', STR0042 + (cAliasDGP)->DGP_FILIAL, 1, STR0043 ) // 'Foi encontrada pendência na filial ' ## 'Acesse o módulo SIGADPR através desta filial.'
			Return .F.
		Else
			(cAliasDGP)->(dbCloseArea())
		Endif
	Endif

	//Verifica se existe pendencia
	dbSelectArea( "DGP" )
	DGP->( dbSetOrder( 2 ) )
	If DGP->( DbSeek( xFilial( "DGP" ) + cProdDv + cNrVersao ) ) .AND. (DGP->DGP_LGFTEV='0')
		cPend := DGP->DGP_IDIC

		dbSelectArea( "DGC" )
		DGC->( dbSetOrder( 1 ) )
		DGC->( DbSeek( xFilial( "DGC" ) + cPend ) )

		//Verifica se aprova a pendencia na liberação apartir do parametro MV_DPRAPFT (0=Aprovação da Versão;1=Liberação da Versão)
		If SuperGetMV("MV_DPRAPFT",.F.,0) == 1 .OR. AllTrim(DGC->DGC_NRPD) == ""
			// Caso o usuário tenha alterado o parametro no meio do processo, verifica se já possui pedido, caso contrário.
			// Gera o pedido na liberação, independente de parametro
			AprovaPend(cPend)
		EndIf
		//Altera o produto destino no faturamento
		if AlteraProd(cPend, .T.)
			DGP->( dbGoTop() )
			DGP->( dbSetOrder( 1 ) )
			//Suspende versões que não foram alteradas e confirma faturamento
			DGP->( DbSeek( xFilial( "DGP" ) + cPend ) )

			While DGP->(!Eof()) .AND. DGP->DGP_FILIAL == xFilial( "DGP" ) .AND. DGP->DGP_IDIC == cPend
				//Se for a versão recebida por parametro, confirma faturamento da versão associada selecionada
				If DGP->DGP_NRVRAC == cNrVersao
					RecLock("DGP",.F.)
					DGP->DGP_LGFTEV := "1"
					DGP->(MSUnlock())

					dbSelectArea( "DGC" )
					DGC->( dbSetOrder( 1 ) )
					If DGC->( DbSeek( xFilial( "DGC" ) + cPend ) )
						RecLock("DGC",.F.)
						DGC->DGC_LGFTEV := "1"
						DGC->(MSUnlock())
					EndIf
					//Se não for a versão recebi por paremtro, suspende a versão
				Else
					dbSelectArea('DG0')
					DG0->(dbSetOrder(1))
					if DG0->(dbSeek(xFilial('DG0')+DGP->DGP_CDACDV+DGP->DGP_NRVRAC))
						RecLock("DG0",.F.)
						DG0->DG0_TPST := "2"
						DG0->(MSUnlock())

						if lHist
							DPRA341HIS(DG0->DG0_CDACDV, DG0->DG0_NRVRAC, '2')
						Endif
					Endif
				EndIf

				DGP->(DbSkip())
			EndDo
		Else
			lRet := .F.
		Endif
	EndIf

	RestArea(aAreaDG0)
Return lRet

//----------------------------------------------------------------------------------------------------------------------
//   Retorna true se o produto e versão em questão já foram liberados em alguma pendência, false se não foi liberado
//----------------------------------------------------------------------------------------------------------------------
Function DRAP350PFa( cProd, cVers )
	Local aArea      := GetArea()

	dbSelectArea('DGP')
	DGP->(dbSetOrder(2))
	DGP->(dbSeek(xFilial('DGP')+cProd+cVers))

	while( (!DGP->(eof())) .AND. ((DGP->DGP_FILIAL+DGP->DGP_CDACDV+DGP->DGP_NRVRAC)==(xFilial('DGP')+cProd+cVers)) )
		if(DGP->DGP_LGFTEV =="1")
			AADD(aPrdLib, {cProd, cVers, DGP->DGP_IDIC})          //Variavel declarada no DPRA342
		endif

		DGP->(Dbskip())
	enddo

Return Nil

/*/{Protheus.doc} DRAP350MM
	Utilizada no inicializador padrão do campo DGC_DSNV
	@type  Static Function
	@author mauricio.joao
	@since 16/07/2020
	@version 1.0
	/*/
Function DRAP350MM()
	Local cDSNV := ""

	cDSNV := POSICIONE("DG6",1,XFILIAL("DG6")+DGC->DGC_IDNV,"DG6_DSNV")

Return cDSNV
