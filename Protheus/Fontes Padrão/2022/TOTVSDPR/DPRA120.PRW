#INCLUDE 'DPRA120.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA120
Tela de Cadastro de Peso do Critério por Produto

@author Ana Carolina Tome Klock
@since 30/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA120()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA120', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DGF')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Peso do Critério por Produto'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA120' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA120' OPERATION 3 ACCESS 0    // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA120' OPERATION 4 ACCESS 0    // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA120' OPERATION 5 ACCESS 0    // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA120' OPERATION 8 ACCESS 0    // 'Imprimir'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDGF := FWFormStruct( 1, 'DGF', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA120', /*bPreValidacao*/, { |oModel| DPRA120POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DGFMASTER', /*cOwner*/, oStructDGF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados do Peso do Critério por Produto'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DGFMASTER' ):SetDescription( STR0010 ) // 'Dados do Peso do Critério por Produto'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA120' )
// Cria a estrutura a ser usada na View
Local oStructDGF := FWFormStruct( 2, 'DGF' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DGF', oStructDGF, 'DGFMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA', 100 )

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DGF', 'TELA' )

// Cria obrigatoriedade no campo de Produto Desenvolvido
oView:GetStruct('DGFMASTER'):SetProperty('DGF_CDACDV', MODEL_FIELD_OBRIGAT, .T.)

// Impede alteração do Critério
If Altera
	oView:GetStruct('DGFMASTER'):SetProperty('DGF_CDJZ'  , MODEL_FIELD_NOUPD  , .T.)
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA120POS
Realiza a pos-validacao dos dados da tela

@param 		oModel		Modelo de dados da tela
@return 	lRet		Informa se a tela está pronta para realizar o Commit

@author Ana Carolina Tome Klock
@since 11/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA120POS( oModel )
Local lRet := .T.

If oModel:GetOperation() == 3
	dbSelectArea('DGF')
	dbSetOrder(1)
	If DGF->(dbseek( xFilial('DGF')+oModel:GetValue('DGFMASTER','DGF_CDACDV')+oModel:GetValue('DGFMASTER','DGF_CDJZ') ))
		DPRXError( 'DPRA120', 'DPRA120_INCON1' , 3 )
		lRet := .F.
	EndIf
EndIf

Return lRet