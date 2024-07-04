#INCLUDE 'DPRA322.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA322
Tela de Cadastro de Rede-Pert

@author Ana Carolina Tome Klock
@since 26/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA322()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA322', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG0')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Rede-Pert'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA322' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA322' OPERATION 3 ACCESS 0    // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA322' OPERATION 4 ACCESS 0    // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA322' OPERATION 5 ACCESS 0    // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA322' OPERATION 8 ACCESS 0    // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRA322' OPERATION 9 ACCESS 0    // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDG0 := FWFormStruct( 1, 'DG0', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDGD := FWFormStruct( 1, 'DGD', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA322', /*bPreValidacao*/, { |oModel| DPRA322DGD(oModel, 4) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DG0MASTER', /*cOwner*/, oStructDG0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'DGDDETAIL', 'DG0MASTER', oStructDGD, { |oModel| DPRA322DGD( oModel, 1 ) }, { |oModel| DPRA322DGD( oModel, 2 ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'DGDDETAIL', { { 'DGD_FILIAL', 'xFilial( "DGD" )' }, { 'DGD_CDACDV', 'DG0_CDACDV' }, { 'DGD_NRVRAC', 'DG0_NRVRAC'} }, DGD->( IndexKey(1)) )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'DGDDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados da Rede-Pert'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DG0MASTER' ):SetDescription( STR0010 ) // 'Dados da Rede-Pert'

// Seta valores para os campos principais
oModel:GetModel( 'DG0MASTER' ):GetStruct():SetProperty('DG0_CDACDV', MODEL_FIELD_INIT, { || DG0->DG0_CDACDV } )
oModel:GetModel( 'DG0MASTER' ):GetStruct():SetProperty('DG0_CDACDV', MODEL_FIELD_WHEN, { || .F. } )
oModel:GetModel( 'DG0MASTER' ):GetStruct():SetProperty('DG0_NRVRAC', MODEL_FIELD_INIT, { || M->DG0_NRVRAC } )
oModel:GetModel( 'DG0MASTER' ):GetStruct():SetProperty('DG0_DSVR'  , MODEL_FIELD_OBRIGAT, .F. )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA322' )
// Cria a estrutura a ser usada na View
Local oStructDG0 := FWFormStruct( 2, 'DG0' )
Local oStructDGD := FWFormStruct( 2, 'DGD' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona botões extras
oView:AddUserButton( STR0025, 'DPRA322', { |oModel| DPRA322DGD(oModel, 3) } )  // 'Gerar Rede-Pert'

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DG0', oStructDG0, 'DG0MASTER' )
oView:AddGrid(  'VIEW_DGD', oStructDGD, 'DGDDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 10 )
oView:CreateHorizontalBox( 'INFERIOR', 90 )

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DG0', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_DGD', 'INFERIOR' )

// Remove o campo repetido da tela
oStructDG0:SetNoGroups()
While Len( oStructDG0:GetFields() ) != 2
	oStructDG0:RemoveField( oStructDG0:GetFields()[3][1] )
End
oStructDGD:RemoveField( 'DGD_CDACDV' )
oStructDGD:RemoveField( 'DGD_NRVRAC' )
oStructDGD:RemoveField( 'DGD_IDATPV' )
oStructDGD:RemoveField( 'DGD_IDATNX' )

// Não permite edição do campo
oStructDGD:SetProperty( 'DGD_NRSQ'  , MVC_VIEW_CANCHANGE, .F. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA322DGD
Realiza a Pre/Pos validação da Linha/Modelo para a tabela DGD (Rede-Pert)

@param 		oModel		Modelo de dados da tela
@param 		nValida		Identifica o tipo de validação (1=PreLine, 2=PosLine, 3=Gerar, 4=Consistir)
@return 	lRet		Se foi validado (.T.) ou não (.F.)


@author Ana Carolina Tome Klock
@since 08/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA322DGD( oModel, nValida )
Local oModelDGD  := oModel:GetModel():GetModel("DGDDETAIL")
Local oCommit
Local nDGD 		:= oModelDGD:Length()
Local nDG9 		:= oModelDG9:Length()
Local nI	    	:= 0
Local nCount		:= 0
Local cPrevious 	:= ''
Local cNext 		:= ''
Local lRet 		:= .T.

// PreLine
If nValida == 1

	// Carrega um Número de Sequência automático
	If Empty( oModelDGD:GetValue('DGD_NRSQ') ) .And. DPRXVldMdl( oModelDGD )
		lRet := DPRXSetVal( oModelDGD, 'DGD_NRSQ' )
	EndIf

// PosLine
ElseIf nValida == 2
	dbSelectArea('DG9')
	dbSetOrder(1)

 	// Se a Operação Anterior for igual a Próxima Operação
	If FwFldGet('DGD_CDATPV') == FwFldGet('DGD_CDATNX') .And. !oModelDGD:IsDeleted()
		DPRXError( 'DPRA322', 'DPRA322_INCON1', 3 )
		lRet := .F.
	// Se a Operação Predecessora não foi cadastrada para a Versão
	ElseIf !oModelDGD:IsDeleted() .And. !dbSeek( xFilial('DG9')+FwFldGet('DG0_CDACDV')+FwFldGet('DG0_NRVRAC')+FwFldGet('DGD_CDATPV') )
		DPRXError( 'DPRA322', 'DPRA322_INCON2', 3 )
		lRet := .F.
	// Se a Operação Sucessora não foi cadastrada para a Versão
	ElseIf !oModelDGD:IsDeleted() .And. !dbSeek( xFilial('DG9')+FwFldGet('DG0_CDACDV')+FwFldGet('DG0_NRVRAC')+FwFldGet('DGD_CDATNX') )
		DPRXError( 'DPRA322', 'DPRA322_INCON3', 3 )
		lRet := .F.
	EndIf

// Gerar Rede-Pert
ElseIf nValida == 3

 	// Valida se a última operação é interna
	If oModelDG9:GetValue('DG9_TPAT', nDG9) == '1'
	   	For nI := 1 to nDG9-1
	   		If nDGD < nI
	   			oModelDGD:AddLine()
	   		Else
	   			oModelDGD:GoLine(nI)
	   		EndIf
	   		oModelDGD:SetValue('DGD_CDATPV', oModelDG9:GetValue('DG9_CDAT', nI)   )
	   		oModelDGD:SetValue('DGD_DSATPV', oModelDG9:GetValue('DG9_DSAT', nI)   )
	   		oModelDGD:SetValue('DGD_IDATPV', oModelDG9:GetValue('DG9_IDAT', nI)   )
	   		oModelDGD:SetValue('DGD_CDATNX', oModelDG9:GetValue('DG9_CDAT', nI+1) )
	   		oModelDGD:SetValue('DGD_DSATNX', oModelDG9:GetValue('DG9_DSAT', nI+1) )
	   		oModelDGD:SetValue('DGD_IDATNX', oModelDG9:GetValue('DG9_IDAT', nI+1) )
	   	Next
	   	For nI := nDG9 to nDGD
			oModelDGD:GoLine(nI)
			oModelDGD:DeleteLine()
   		Next
	Else
		DPRXError( 'DPRA322', 'DPRA322_INCON4', 3 )
	EndIf
	oModelDGD:GoLine(1)

// Consistir
ElseIf !IsInCallStack('DPRA330')

	// Valida se existe apenas uma operação final
	For nI := 1 to nDGD
		oModelDGD:GoLine(nI)
		If !oModelDGD:IsDeleted() .And. Empty(DPRA322VAL( oModelDGD, oModelDGD:GetValue('DGD_CDATNX'), 2 )) .And. oModelDGD:GetValue('DGD_CDATNX') != cNext
			cNext := oModelDGD:GetValue('DGD_CDATNX')
			nCount++
		EndIf
	Next
	If nCount > 1
		DPRXError('DPRA322', 'DPRA322_INCON5', 3 )
	    lRet := .F.
	EndIf

	If lRet .And. nCount > 0
		For nI := 1 to nDG9
			// Valida se todas as operações constam na Rede-Pert
		    If !oModelDGD:SeekLine( { { 'DGD_CDATPV', oModelDG9:GetValue('DG9_CDAT', nI) } } ) .And. ;
		   	   !oModelDGD:SeekLine( { { 'DGD_CDATNX', oModelDG9:GetValue('DG9_CDAT', nI) } } )
		   	    DPRXError('DPRA322', 'DPRA322_INCON6', 3 )
		   	    lRet := .F.
		   	    Exit
		 	// Valida se a operação final é interna
		   	ElseIf oModelDG9:GetValue('DG9_CDAT', nI) == cNext .And. oModelDG9:GetValue('DG9_TPAT', nI) != '1'
		   		DPRXError('DPRA322', 'DPRA322_INCON4', 3 )
		   	    lRet := .F.
		   	    Exit
		   	EndIf
		Next

		// Consiste a Rede Pert
		If lRet
			For nI := 1 to nDGD
		   		oModelDGD:GoLine(nI)
				If !oModelDGD:IsDeleted() .And. lRet
					// Valida Loop Direto (Existir 10 - 20 - 30 - 20)
					cPrevious := oModelDGD:GetValue('DGD_CDATPV')
					While !Empty( cPrevious := DPRA322VAL( oModelDGD, cPrevious, 1))
	   					If cPrevious == oModelDGD:GetValue('DGD_CDATPV')
	   						DPRXError('DPRA322', 'DPRA322_INCON6', 3 )
	   						lRet := .F.
							Exit
						EndIf
					End
					// Valida Loop Indireto (Existir 10 - 20 - 30 e 10 - 30)
					cNext     := oModelDGD:GetValue('DGD_CDATPV')
					While !Empty( cNext := DPRA322VAL( oModelDGD, cNext, 2))
	   					If cNext == oModelDGD:GetValue('DGD_CDATNX')
	   				   		DPRXError('DPRA322', 'DPRA322_INCON6', 3 )
	   						lRet := .F.
							Exit
						EndIf
					End
				EndIf
			Next
			lRet := .T.
		EndIf
	EndIf

	// Marca operação inicial e final
	If lRet
		For nI := 1 to nDG9
			dbSelectArea( 'DG9' )
			dbSetOrder(1)
			dbSeek( xFilial('DG9')+oModelDG9:GetValue('DG9_CDACDV',nI)+oModelDG9:GetValue('DG9_NRVRAC',nI)+oModelDG9:GetValue('DG9_CDAT',nI) )

			oCommit := FWLoadModel( 'DPRA320' )
			oCommit:SetOperation( 4 )
			oCommit:Activate()

			// Se for operação inicial
			If Empty(DPRA322VAL( oModelDGD, oModelDG9:GetValue('DG9_CDAT', nI), 1, .T. ))
				oCommit:SetValue( 'DG9MASTER', 'DG9_LGATBG', '1' )
			Else
				oCommit:SetValue( 'DG9MASTER', 'DG9_LGATBG', '0' )
			EndIf

			// Se for operação final
			If Empty(DPRA322VAL( oModelDGD, oModelDG9:GetValue('DG9_CDAT', nI), 2, .T. ))
				oCommit:SetValue( 'DG9MASTER', 'DG9_LGATED', '1' )
			Else
				oCommit:SetValue( 'DG9MASTER', 'DG9_LGATED', '0' )
			EndIf

			If oCommit:VldData()
				oCommit:CommitData()
			Else
				aErro := oCommit:GetErrorMessage()
				DPRXError('DPRA320', aErro[6])
				lRet := .F.
			EndIf

			oCommit:DeActivate()
		Next
	EndIf

	//oModelDG9:DeActivate()
	//oModelDG9:Activate()

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA322VAL
Obtem a operação predecessora ou sucessora conforme parâmetro

@param 		oModel		Modelo de dados da Rede-Pert
@param 		cCDAT		Código da Atividade a ser buscada
@param 		nValida		Identifica o tipo de validação (1=Suc/Pre, 2=Pre/Suc)
@param 		lCont		Identifica se valida a linha atual da DGD
@return 	lRet		Se foi validado (.T.) ou não (.F.)


@author Ana Carolina Tome Klock
@since 28/06/2012
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRA322VAL( oModelDGD, cCDAT, nValida, lCont )
Local nI      := 0
Local cRet    := ''
Default lCont := .F.

For nI := oModelDGD:Length() to 1 step -1
	If (nI != oModelDGD:GetLine() .Or. lCont) .And. !oModelDGD:IsDeleted(nI)
		If oModelDGD:GetValue('DGD_CDATNX', nI) == cCDAT .And. nValida == 1
			cRet := oModelDGD:GetValue('DGD_CDATPV', nI)
			Exit
		ElseIf oModelDGD:GetValue('DGD_CDATPV', nI) == cCDAT .And. nValida == 2
			cRet := oModelDGD:GetValue('DGD_CDATNX', nI)
			Exit
		EndIf
	EndIf
Next

Return cRet
