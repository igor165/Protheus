#INCLUDE "DPRA102.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA102
Tela de cadastro de Atributo Extra

@author Ana Carolina Tomé Klock
@since 27/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA102()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA102', aValidaDPR[2], 3 )
EndIf

If DPRIntegra() != 1
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DGB')
	oBrowse:SetDescription( STR0001 ) // 'Cadastro de Atributo Extra'
	oBrowse:Activate()
Else
	DPRXError( 'DPRA102', 'DPRA102_DATASU', 3 )
EndIf

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA102' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA102' OPERATION 3 ACCESS 0  // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA102' OPERATION 4 ACCESS 0  // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA102' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA102' OPERATION 8 ACCESS 0  // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRA102' OPERATION 9 ACCESS 0  // 'Copiar'
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDGB := FWFormStruct( 1, 'DGB', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA102', /*bPreValidacao*/, { |oModel| DPRA102POS(oModel) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DGBMASTER', /*cOwner*/, oStructDGB, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados do Atributo Extra'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DGBMASTER' ):SetDescription( STR0010 )  //'Dados do Atributo Extra'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'DPRA102' )
// Cria a estrutura a ser usada na View
Local oStructDGB := FWFormStruct( 2, 'DGB' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DGB', oStructDGB, 'DGBMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_DGB', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA102POS
Realiza a pos-validacao dos dados da tela

@param 		oModel		Modelo de dados da tela
@return 	lRet		Informa se a tela está pronta para realizar o Commit

@author Ana Carolina Tomé Klock
@since 01/06/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA102POS( oModel )
Local lRet := .T.

// Se a operação for de inclusão ou alteração
If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4
	// Limpa a quantidade de decimais quando o atributo não for numérico
	If FwFldGet('DGB_TPAB') != '2'
		oModel:GetModel('DGBMASTER'):LoadValue('DGB_NRFM', 0)
	EndIf

// Se a operação for de exclusão
ElseIf oModel:GetOperation() == 5

	// Se existir um registro relacionado no Produto Desenvolvido
	dbSelectArea('DGK')
	dbSetOrder(2)
	If DGK->( dbSeek( xFilial('DGK')+oModel:GetValue('DGBMASTER','DGB_DSAB') ) )
		DPRXError( 'DPRA102', 'DPRA102_INCON1', 3 )
 		lRet := .F.
 	EndIf

 	// Se existir um registro relacionado na Versão do Produto
 	If lRet
	 	dbSelectArea('DGG')
		dbSetOrder(2)
		If DGG->( dbSeek( xFilial('DGG')+oModel:GetValue('DGBMASTER','DGB_DSAB') ) )
	  		DPRXError( 'DPRA102', 'DPRA102_INCON2', 3 )
	 		lRet := .F.
	 	EndIf
 	EndIf
EndIf

Return lRet
