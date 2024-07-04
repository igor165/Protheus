#INCLUDE 'DPRA344.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA344
Tela de Ordens Protótipo relacionadas

@author Ana Carolina Tomé Klock
@since 20/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA344()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA344', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DGH')
oBrowse:SetDescription( STR0001 ) // 'Histórico das Ordens Protótipo Geradas'
oBrowse:AddLegend( 'DPRA344SC2( 1 )', 'BR_AMARELO' , STR0011 )  	// 'Prevista'
oBrowse:AddLegend( 'DPRA344SC2( 2 )', 'BR_VERDE'   , STR0012 )		// 'Em aberto'
oBrowse:AddLegend( 'DPRA344SC2( 3 )', 'BR_LARANJA' , STR0013 )      // 'Iniciada'
oBrowse:AddLegend( 'DPRA344SC2( 4 )', 'BR_CINZA'   , STR0014 )      // 'Ociosa'
oBrowse:AddLegend( 'DPRA344SC2( 5 )', 'BR_AZUL'	   , STR0015 )      // 'Encerrada Parcialmente'
oBrowse:AddLegend( 'DPRA344SC2( 6 )', 'BR_VERMELHO', STR0016 )     	// 'Encerrada Totalmente'
oBrowse:SetMenuDef( 'DPRA344' )
oBrowse:SetFilterDefault( 'DGH_CDACDV == "' + DG0->DG0_CDACDV + '" .And. DGH_NRVRAC = "' + DG0->DG0_NRVRAC + '"' )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         	OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA340' 	OPERATION 2 ACCESS 0  // 'Visualizar'
//ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA344' OPERATION 3 ACCESS 0  // 'Incluir'
//ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA344' OPERATION 4 ACCESS 0  // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA344' 	OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0017 ACTION 'DPRA340INT(4)'   	OPERATION 2 ACCESS 0  // 'Regerar'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA344' 	OPERATION 8 ACCESS 0  // 'Imprimir'
//ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRC300' OPERATION 9 ACCESS 0  // 'Copiar'
ADD OPTION aRotina TITLE STR0018 ACTION 'DPRA344LEG()' 		OPERATION 6 ACCESS 0  // 'Legenda'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDGH := FWFormStruct( 1, 'DGH', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA344', /*bPreValidacao*/, /*bPosValidacao*/, { |oModel| DPRA344COM( oModel ) }, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DGHMASTER', /*cOwner*/, oStructDGH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) // 'Modelo de Dados do Histórico das Ordens Protótipo Geradas'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DGHMASTER' ):SetDescription( STR0010 )  // 'Dados do Histórico das Ordens Protótipo Geradas'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'DPRA344' )
// Cria a estrutura a ser usada na View
Local oStructDGH := FWFormStruct( 2, 'DGH' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DGH', oStructDGH, 'DGHMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_DGH', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA344POS
Apaga a ordem no sistema legado

@author Ana Carolina Tome Klock
@since 25/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRA344COM( oModel )
Local lRet 		:= .T.

// Se estiver apagando, remove do SIGAPCP
If oModel:GetOperation() == 5 .And. DPRIntegra() == 1
	If DPRA340INT(5)
		FWFormCommit( oModel )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA344SC2
Valida se a ordem está com a situação passada por parâmetro

@param		nSituacao		(Obrigatório) Tipo da Situação
							1 = Prevista
							2 = Firme
							3 = Aberta
							4 = Ociosa
							5 = Encerrada parcialmente
							6 = Encerrada totalmente

@return		lRet			Retorna se a OP tem a situação do parâmetro

@author Ana Carolina Tome Klock
@since 20/02/2013
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA344SC2( nSituacao )
Local lRet := .F.

dbSelectArea('SC2')
SC2->( dbSetOrder(1) )
If SC2->( dbSeek(xFilial('SC2')+DGH->DGH_NRORPO ))
	If A650DefLeg( nSituacao )
		lRet := .T.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA344LEG
Tela de Legendas

@author Ana Carolina Tome Klock
@since 01/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA344LEG()

// Cria a legenda que identifica a estrutura
oLegend := FWLegend():New()

// Adiciona descrição para cada legenda
oLegend:Add( { || }, 'BR_AMARELO' , STR0011 )		// 'Prevista'
oLegend:Add( { || }, 'BR_VERDE'   , STR0012 )		// 'Em aberto'
oLegend:Add( { || }, 'BR_LARANJA' , STR0013 )		// 'Iniciada'
oLegend:Add( { || }, 'BR_CINZA'	  , STR0014 )       // 'Ociosa'
oLegend:Add( { || }, 'BR_AZUL'	  , STR0015 )  		// 'Encerrada Parcialmente'
oLegend:Add( { || }, 'BR_VERMELHO', STR0016 )   	// 'Encerrada Totalmente'

// Ativa a Legenda
oLegend:Activate()

// Exibe a Tela de Legendas
oLegend:View()

Return Nil
