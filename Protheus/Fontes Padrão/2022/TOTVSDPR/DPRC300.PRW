#INCLUDE 'DPRC300.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRC300
Tela de Histórico Aprovação/Liberação

@author Ana Carolina Tomé Klock
@since 01/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRC300()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRC300', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DGL')
oBrowse:SetDescription( STR0001 ) // 'Histórico de Aprovação/Liberação'
oBrowse:SetMenuDef( 'DPRC300' )
If IsInCallStack('DPRA341') .Or. IsInCallStack('DPRA342')
	oBrowse:SetFilterDefault( "DGL_CDACDV == '" + DG0->DG0_CDACDV + "' .AND. DGL_NRVRDV == '" + DG0->DG0_NRVRAC + "'" )
EndIf
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRC300' OPERATION 2 ACCESS 0  // 'Visualizar'
//ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRC300' OPERATION 3 ACCESS 0  // 'Incluir'
//ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRC300' OPERATION 4 ACCESS 0  // 'Alterar'
//ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRC300' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRC300' OPERATION 8 ACCESS 0  // 'Imprimir'
//ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRC300' OPERATION 9 ACCESS 0  // 'Copiar'
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDGL := FWFormStruct( 1, 'DGL', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRC300', /*bPreValidacao*/,  /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DGLMASTER', /*cOwner*/, oStructDGL, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) // 'Modelo de Dados do Histórico de Aprovação/Liberação'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DGLMASTER' ):SetDescription( STR0010 )  // 'Dados do Histórico de Aprovação/Liberação'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'DPRC300' )
// Cria a estrutura a ser usada na View
Local oStructDGL := FWFormStruct( 2, 'DGL' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DGL', oStructDGL, 'DGLMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_DGL', 'TELA' )

Return oView
