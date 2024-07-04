#INCLUDE 'DPRA310.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA310
Tela de Cadastro de Estrutura

@author Ana Carolina Tome Klock
@since 18/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA310()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA310', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG1')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Estrutura'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA310' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA310' OPERATION 3 ACCESS 0    // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA310' OPERATION 4 ACCESS 0    // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA310' OPERATION 5 ACCESS 0    // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA310' OPERATION 8 ACCESS 0    // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRA310' OPERATION 9 ACCESS 0    // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDG1 := FWFormStruct( 1, 'DG1', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG4 := FWFormStruct( 1, 'DG4', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG6 := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA310', /*bPreValidacao*/, { |oModel| DPRA310POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DG1MASTER', /*cOwner*/, oStructDG1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'DG4DETAIL', 'DG1MASTER', oStructDG4, { |oModel| DPRA310DG4( oModel, 1 ) }, { |oModel| DPRA310DG4( oModel, 2 ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DG6DETAIL', 'DG1MASTER', oStructDG6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'DG4DETAIL', { { 'DG4_FILIAL', 'xFilial( "DG4" )' }, { 'DG4_CDACDV', 'DG1_CDACDV' }, { 'DG4_NRVRAC', 'DG1_NRVRAC' } , { 'DG4_NRSQ', 'DG1_NRSQ' }}, DG4->( IndexKey(1)) )
oModel:SetRelation( 'DG6DETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DG1_IDNV'   } }, DG6->( IndexKey(1)) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados da Estrutura'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DG1MASTER' ):SetDescription( STR0010 ) // 'Dados da Estrutura'
oModel:GetModel( 'DG4DETAIL' ):SetDescription( STR0011 ) // 'Dados do Componente Alternativo'
oModel:GetModel( 'DG6DETAIL' ):SetDescription( STR0012 ) // 'Dados da Narrativa'

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'DG4DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG6DETAIL' ):SetOptional(.T.)

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'DG6DETAIL' ):SetNoInsertLine()
oModel:GetModel( 'DG4DETAIL' ):SetUniqueLine( { 'DG4_CDMTAV' } )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA310' )
// Cria a estrutura a ser usada na View
Local oStructDG1 := FWFormStruct( 2, 'DG1' )
Local oStructDG4 := FWFormStruct( 2, 'DG4' )
Local oStructDG6 := FWFormStruct( 2, 'DG6' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DG1', oStructDG1, 'DG1MASTER' )

// Adiciona no nosso View um controle do tipo FormGrid (antiga newgetdados)
If DPRIntegra() == 2
	oView:AddGrid(  'VIEW_DG4', oStructDG4, 'DG4DETAIL' )
	oView:AddGrid(  'VIEW_DG6', oStructDG6, 'DG6DETAIL' )
EndIf

// Criar um "box" horizontal para receber algum elemento da view
If DPRIntegra() == 2
	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )
	oView:CreateFolder( 'FOLDER', 'INFERIOR' )
Else
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
EndIf

// Cria pastas nas folders
If DPRIntegra() == 2
	oView:AddSheet( 'FOLDER', 'TAB01', STR0013 )   // 'Componente Alternativo'
	oView:AddSheet( 'FOLDER', 'TAB02', STR0014 )   // 'Narrativa'
EndIf

// Cria um box horizontal para receber algum elemento da view
If DPRIntegra() == 2
	oView:CreateHorizontalBox( 'DG4', 100, , ,'FOLDER', 'TAB01' )
	oView:CreateHorizontalBox( 'DG6', 100, , ,'FOLDER', 'TAB02' )
EndIf

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DG1', 'SUPERIOR' )
If DPRIntegra() == 2
	oView:SetOwnerView( 'VIEW_DG4', 'DG4' )
	oView:SetOwnerView( 'VIEW_DG6', 'DG6' )
EndIf

// Remove o campo repetido da tela
oStructDG1:RemoveField('DG1_IDNV')
oStructDG1:RemoveField('DG1_LGAV')
oStructDG1:RemoveField('DG1_LGMTDV')
oStructDG1:RemoveField('DG1_CDMTDV')
oStructDG1:RemoveField('DG1_NRVRMT')
oStructDG4:RemoveField('DG4_CDACDV')
oStructDG4:RemoveField('DG4_NRVRAC')
oStructDG4:RemoveField('DG4_NRSQ')
oStructDG4:RemoveField('DG4_IDNV')
oStructDG6:RemoveField('DG6_IDNV')
If DPRIntegra() == 1
	oStructDG1:RemoveField('DG1_CDRE')
EndIf

// Permite apenas visualizar campos virtuais
If DPRIntegra() == 2
	oView:GetViewStruct('VIEW_DG4'):SetProperty('DG4_NRSQAV', MVC_VIEW_CANCHANGE , .F.)
EndIf

// Ajusta o tamanho da narrativa
oStructDG6:SetProperty( 'DG6_DSNV', MODEL_FIELD_TAMANHO, {15000} )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA310POS
Realiza a pos-validacao dos dados da tela

@author Ana Carolina Tome Klock
@since 26/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA310POS( oModel )
Local lRet := .T.

If !Empty(FwFldGet('DG6_DSNV')) .And. Empty(FwFldGet('DG1_IDNV'))
	lRet := FwFldPut('DG6_IDNV', GetSxeNum('DG6', 'DG6_IDNV', RetSQLName( 'DG6' ), 1 ) )
 	If lRet
 		lRet := oModel:GetModel('DG1MASTER'):LoadValue('DG1_IDNV', FwFldGet('DG6_IDNV'))
 	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA310DG4
Realiza a Pre/Pos validação da Linha/Modelo para a tabela DG4 (Componente)

@param 		oModel		Modelo de dados da tela
@param 		nValida		Identifica o tipo de validação (1=PreLine, 2=PosLine, 3=PosVal)
@return 	lRet		Se foi validado (.T.) ou não (.F.)

@author Ana Carolina Tome Klock
@since 27/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA310DG4( oModel, nValida )
Local lRet 		:= .T.

// PreLine
If nValida == 1
	If Empty( oModel:GetValue('DG4_NRSQAV') ) .And. DPRXVldMdl( oModel )
		lRet := DPRXSetVal( oModel, 'DG4_NRSQAV' )
		oModel:LoadValue('DG4_QTUT', 1)
	EndIf

// PosLine
ElseIf nValida == 2
	// Valida se o componente informado não é igual ao componente pai
	If FwFldGet('DG4_CDMTAV') == FwFldGet('DG1_CDMT')
		DPRXError('DPRA310', 'DPRA310_INCON1', 3 )
		lRet := .F.
	EndIf

	// Quando a quantidade do componente for positiva, altera Tipo de Sobra para "Normal"
	If FwFldGet('DG1_QTMT') >= 0  .And. FwFldGet('DG1_TPSB') != '4'
		lRet := FwFldPut('DG1_TPSB', '4')

	// Quando a quantidade do componente for negativa, exibe erro para que seja informado outro tipo de sobra
	ElseIf FwFldGet('DG1_QTMT') < 0  .And. FwFldGet('DG1_TPSB') == '4'
	 	DPRXError( 'DPRA310', 'DPRA300_COMPO5', 3 )
	 	lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA310ALT
Verifica se o Componente informado contém um Componente Alternativo

@param 		cCDACDV			Código do Produto Desenvolvido
@param 		cNRVRAC			Número do Versionamento do Produto
@param 		cNRSQ			Número da Sequência do Componente

@return		lExist			Se existe um componente alteranativo (.T.) ou não (.F.)

@author Ana Carolina Tome Klock
@since 25/04/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA310ALT( cCDACDV, cNRVRAC, cNRSQ )
Local lExist := '0'

dbSelectArea('DG4')
dbSetOrder(1)
If dbSeek( xFilial('DG4')+cCDACDV+cNRVRAC+cNRSQ )
	lExist := '1'
EndIf

Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} DPR_CDMTDV
Verifica se o componente pode ser filho do Produto

@param 		cCDMTDV		Código do Componente Desenvolvido
@param 		cNRVRMT		Número da Versão Componente Desenvolvido

@return		lRet			Se pode ser filho do produto atual

@author Ana Carolina Tome Klock
@since 24/09/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPR_CDMTDV( cCDMTDV, cNRVRMT )
Local lRet  := .T.
Local aArea
Local cCDACDV   := FwFldGet('DG0_CDACDV')
Default cCDMTDV := FwFldGet('DG1_CDMTDV')
Default cNRVRMT := FwFldGet('DG1_NRVRMT')

// Se estiver na tela de versão ou criando uma versão via produto desenvolvido
If IsInCallStack('DPRA300') .Or. IsInCallStack('DPRA100')

	// Verifica se o componente é igual ao Produto Desenvolvido
	If  cCDACDV == cCDMTDV
		DPRXError( 'DPR_CDMTDV', 'DPRA310_INCON2', 3 )
		lRet := .F.
	Else
		// Varre a árvore procurando por loops
		dbSelectArea( 'DG1' )
		DG1->( dbSetOrder(1) )
		If DG1->(dbSeek( xFilial('DG1') + cCDMTDV + cNRVRMT ))
			While DG1->(!EOF())
				If DG1->DG1_CDACDV == cCDMTDV .And. DG1->DG1_NRVRAC == cNRVRMT
					If DG1->DG1_CDMTDV == cCDACDV
						DPRXError( 'DPR_CDMTDV', 'DPRA310_INCON3', 3 )
						Return .F.
					ElseIf !Empty(DG1->DG1_CDMTDV) .And. !Empty(DG1->DG1_NRVRMT)
						aArea := DG1->( GetArea() )
						lRet  := DPR_CDMTDV( DG1->DG1_CDMTDV, DG1->DG1_NRVRMT )
						RestArea( aArea )
					EndIf
				EndIf
				DG1->(dbSkip())
			End
		EndIf
	EndIf
EndIf

Return lRet