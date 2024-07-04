#INCLUDE 'DPRA101.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA101
Tela de Cadastro de Preço do Produto Concorrente

@author Ana Carolina Tome Klock
@since 21/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA101()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA101', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DGA')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Preço do Produto Concorrente'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0   // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA101' OPERATION 2 ACCESS 0   // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA101' OPERATION 3 ACCESS 0   // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA101' OPERATION 4 ACCESS 0   // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA101' OPERATION 5 ACCESS 0   // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA101' OPERATION 8 ACCESS 0   // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRA101' OPERATION 9 ACCESS 0   // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDGA := FWFormStruct( 1, 'DGA', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDGI := FWFormStruct( 1, 'DGI', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA101', /*bPreValidacao*/, { |oModel| DPRA101POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DGAMASTER', /*cOwner*/, oStructDGA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'DGIDETAIL', 'DGAMASTER', oStructDGI, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'DGIDETAIL', { { 'DGI_FILIAL', 'xFilial( "DGI" )' }, { 'DGI_CDACDV' , 'DGA_CDACDV' }, { 'DGI_NRSQ' , 'DGA_NRSQ' } }, DGI->(IndexKey(1)) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'DGIDETAIL' ):SetUniqueLine( { 'DGI_CDJZ' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) // 'Modelo de Dados de Preço do Produto Concorrente'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DGAMASTER' ):SetDescription( STR0010 ) // 'Dados de Preço do Produto Concorrente'
oModel:GetModel( 'DGIDETAIL' ):SetDescription( STR0011 ) // 'Dados do Critério do Produto Concorrente'

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'DGIDETAIL' ):SetOptional(.T.)

// Torna o campo chave obrigatório
oModel:GetModel( 'DGAMASTER' ):GetStruct():SetProperty( 'DGA_CDACDV',  MODEL_FIELD_OBRIGAT,  .T. )

oModel:SetActivate( { |oModel| DPRA101PRE( oModel ) } )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA101' )
// Cria a estrutura a ser usada na View
Local oStructDGA := FWFormStruct( 2, 'DGA' )
Local oStructDGI := FWFormStruct( 2, 'DGI' )

// Cria o objeto de View
oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DGA', oStructDGA, 'DGAMASTER' )

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_DGI', oStructDGI, 'DGIDETAIL' )

// Cria um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Cria Folder na view
oView:CreateFolder( 'FOLDER', 'INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'FOLDER', 'TAB01', STR0012 )   // 'Critério'

// Cria um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'DGI', 100, , ,'FOLDER', 'TAB01' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_DGA', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_DGI', 'DGI' )

// Remove os campos repetidos da tela
oStructDGI:RemoveField( 'DGI_CDACDV' )
oStructDGI:RemoveField( 'DGI_DSACDV' )
oStructDGI:RemoveField( 'DGI_NRSQ'   )

Return oView

Static Function DPRA101PRE (oModel)
Local oModelDGI := oModel:GetModel('DGIDETAIL')
Local nI        := 0
Local nQtdLine  := oModelDGI:GetQtdLine()

If oModel:GetOperation() == 3

	IF nQtdLine > 1 .OR.;
	   nQtdLine == 1 .AND. !Empty(oModelDGI:GetValue('DGI_CDJZ'))

		For nI := 1 to nQtdLine
			oModelDGI:GoLine(nI)
			oModelDGI:DeleteLine()
		Next
	Endif

	oModelDGI:GoLine(1)
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA101POS
Realiza a pos-validacao dos dados da tela

@param 		oModel		Modelo de dados da tela
@return 	lRet		Informa se a tela está pronta para realizar o Commit

@author Ana Carolina Tome Klock
@since 26/06/2012
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRA101POS( oModel )
Local lRet      := .T.
Local oModelDGI := oModel:GetModel('DGIDETAIL')
Local nI        := 0

If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4
	For nI := 1 to oModelDGI:GetQtdLine()
		oModelDGI:GoLine(nI)

		If !oModelDGI:IsDeleted() .And. !Empty(oModelDGI:GetValue('DGI_CDJZ'))
			dbSelectArea('DGF')
			dbSetOrder(1)
			If !DGF->(dbSeek(xFilial('DGF')+oModel:GetValue('DGAMASTER','DGA_CDACDV')+oModelDGI:GetValue('DGI_CDJZ')))
				DPRXError( 'DPRA101', 'DPRA101_INCONS', 3 )
				lRet := .F.
				Exit
			Endif
		Endif
	Next

	dbSelectArea('DGA')
	dbSetOrder(2)
	If dbSeek( xFilial('DGA') + FwFldGet('DGA_CDACDV') + FwFldGet('DGA_NRAS') + DTOS( FwFldGet('DGA_DTPR') ))
		If DGA->DGA_NRSQ != FwFldGet('DGA_NRSQ')
			DPRXError( 'DPRA101', 'DPRA101_CONCOR', 3 )
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA101DAT
Atualiza as datas dos critérios de acordo com a data do concorrente

@author Samantha Preima
@since 15/02/2013
@version P11
/*/
//-------------------------------------------------------------------
Function DPRA101DAT()
Local oModel    := FwModelActive()
Local oModelDGI := oModel:GetModel('DGIDETAIL')
Local nI        := 0
Local oView     := FwViewActive()

If IsInCallStack('DPRA101')
	IF INCLUI
		For nI := 1 to oModelDGI:GetQtdLine()
			oModelDGI:GoLine(nI)
			oModelDGI:SetValue('DGI_DTJZ', M->DGA_DTPR)
		Next
	Endif
	oModelDGI:GoLine(1)
	oView:Refresh('DGIDETAIL')
EndIf

Return M->DGA_DTPR

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA101NSQ
Atualiza o numero da sequência do Produto Desenvolvido

@param 		cCDACDV		(Obrigatório) Código do Produto Desenvolvido
@return		cNRSQ		Número da próxima sequência do Produto

@author Ana Carolina Tome Klock
@since 05/06/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA101NSQ( cCDACDV )
Local cNRSQ
Local nLen      := TamSX3('DGA_NRSQ')[1]
Local nI        := 0
Local oModel    := FwModelActive()
Local oModelDGI := oModel:GetModel('DGIDETAIL')

If IsInCallStack('DPRA101')
	dbSelectArea('DGA')
	dbSetOrder(1)
	If DGA->(dbSeek( xFilial('DGA')+cCDACDV ))
		While DGA->(!EOF())
			If DGA->DGA_CDACDV == cCDACDV
				cNRSQ := DGA->DGA_NRSQ

			EndIf
			DGA->(dbSkip())
		End
		cNRSQ := DPRXCOUNT( nLen, Val(cNRSQ) )
	Else
		cNRSQ := DPRXCOUNT( nLen, 0 )
	EndIf
EndIf

For nI := 1 to oModelDGI:GetQtdLine()
	oModelDGI:GoLine(nI)
	oModelDGI:DeleteLine()
Next

nI := 0

dbSelectArea('DGF')
dbSetOrder(1)
If DGF->(dbSeek( xFilial('DGF')+cCDACDV ))
	While DGF->(!EOF()) .AND. DGF->DGF_CDACDV == cCDACDV
		nI++

		if nI > oModelDGI:GetQtdLine()
			oModelDGI:AddLine()
		Else
			oModelDGI:GoLine(nI)
			oModelDGI:UnDeleteLine()
		Endif

		oModelDGI:SetValue('DGI_CDJZ', DGF->DGF_CDJZ)

		DGF->(dbSkip())
	End
Endif

oModelDGI:GoLine(1)

Return cNRSQ