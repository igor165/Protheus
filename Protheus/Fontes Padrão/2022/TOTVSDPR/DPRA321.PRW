#INCLUDE 'DPRA321.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA321
Tela de Cadastro de Operação Alternativa

@author Ana Carolina Tome Klock
@since 26/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA321()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA321', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG7')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Operação Alternativa'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA321' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA321' OPERATION 3 ACCESS 0    // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA321' OPERATION 4 ACCESS 0    // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA321' OPERATION 5 ACCESS 0    // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA321' OPERATION 8 ACCESS 0    // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRA321' OPERATION 9 ACCESS 0    // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDG7 := FWFormStruct( 1, 'DG7', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG2 := FWFormStruct( 1, 'DG2', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG8 := FWFormStruct( 1, 'DG8', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG6 := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructTUT := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA321', /*bPreValidacao*/, { |oModel| DPRA321POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DG7MASTER', /*cOwner*/, oStructDG7, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'DG2DETAIL', 'DG7MASTER', oStructDG2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DG8DETAIL', 'DG7MASTER', oStructDG8, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DG6DETAIL', 'DG7MASTER', oStructDG6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'TUTDETAIL', 'DG7MASTER', oStructTUT, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'DG2DETAIL', { { 'DG2_FILIAL', 'xFilial( "DG2" )' }, { 'DG2_IDAT', 'DG7_IDAT' }, { 'DG2_CDATAV', 'DG7_CDATAV' } }, DG2->( IndexKey(1)) )
oModel:SetRelation( 'DG8DETAIL', { { 'DG8_FILIAL', 'xFilial( "DG8" )' }, { 'DG8_IDAT', 'DG7_IDAT' }, { 'DG8_CDATAV', 'DG7_CDATAV' } }, DG8->( IndexKey(1)) )
oModel:SetRelation( 'DG6DETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DG7_IDNV'   } }, DG6->( IndexKey(1)) )
oModel:SetRelation( 'TUTDETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DG7_IDNVTU' } }, DG6->( IndexKey(1)) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados da Operação Alternativa'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DG7MASTER' ):SetDescription( STR0010 ) // 'Dados da Operação Alternativa'
oModel:GetModel( 'DG2DETAIL' ):SetDescription( STR0011 ) // 'Dados da Ferramenta'
oModel:GetModel( 'DG8DETAIL' ):SetDescription( STR0012 ) // 'Dados do Consumível'
oModel:GetModel( 'DG6DETAIL' ):SetDescription( STR0013 ) // 'Dados da Narrativa'
oModel:GetModel( 'TUTDETAIL' ):SetDescription( STR0014 ) // 'Dados do Tutorial'

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'DG2DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG8DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG6DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'TUTDETAIL' ):SetOptional(.T.)

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'DG6DETAIL' ):SetNoInsertLine()
oModel:GetModel( 'TUTDETAIL' ):SetNoInsertLine()

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA321' )
// Cria a estrutura a ser usada na View
Local oStructDG7 := FWFormStruct( 2, 'DG7' )
Local oStructDG2 := FWFormStruct( 2, 'DG2' )
Local oStructDG8 := FWFormStruct( 2, 'DG8' )
Local oStructDG6 := FWFormStruct( 2, 'DG6' )
Local oStructTUT := FWFormStruct( 2, 'DG6' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DG7', oStructDG7, 'DG7MASTER' )

// Adiciona no nosso View um controle do tipo FormGrid (antiga newgetdados)
oView:AddGrid(  'VIEW_DG2', oStructDG2, 'DG2DETAIL' )
oView:AddGrid(  'VIEW_DG8', oStructDG8, 'DG8DETAIL' )
oView:AddGrid(  'VIEW_DG6', oStructDG6, 'DG6DETAIL' )
oView:AddGrid(  'VIEW_TUT', oStructTUT, 'TUTDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Cria Folder na view
oView:CreateFolder( 'FOLDER', 'INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'FOLDER', 'TAB01', STR0015 )   // 'Ferramenta'
oView:AddSheet( 'FOLDER', 'TAB02', STR0016 )   // 'Consumível'
oView:AddSheet( 'FOLDER', 'TAB03', STR0017 )   // 'Narrativa'
oView:AddSheet( 'FOLDER', 'TAB04', STR0018 )   // 'Tutorial'

// Cria um box horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'DG2', 100, , ,'FOLDER', 'TAB01' )
oView:CreateHorizontalBox( 'DG8', 100, , ,'FOLDER', 'TAB02' )
oView:CreateHorizontalBox( 'DG6', 100, , ,'FOLDER', 'TAB03' )
oView:CreateHorizontalBox( 'TUT', 100, , ,'FOLDER', 'TAB04' )

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DG7', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_DG2', 'DG2' )
oView:SetOwnerView( 'VIEW_DG8', 'DG8' )
oView:SetOwnerView( 'VIEW_DG6', 'DG6' )
oView:SetOwnerView( 'VIEW_TUT', 'TUT' )

// Remove o campo repetido da tela
oStructDG7:RemoveField('DG7_IDAT'  )
oStructDG7:RemoveField('DG7_IDNV'  )
oStructDG7:RemoveField('DG7_IDNVTU')
oStructDG2:RemoveField('DG2_CDATAV')
oStructDG2:RemoveField('DG2_IDAT'  )
oStructDG2:RemoveField('DG2_IDNV'  )
oStructDG8:RemoveField('DG8_CDATAV')
oStructDG8:RemoveField('DG8_IDAT'  )
oStructDG8:RemoveField('DG8_IDNV'  )
oStructDG6:RemoveField('DG6_IDNV'  )
oStructTUT:RemoveField('DG6_IDNV'  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA321POS
Realiza a pos-validacao dos dados da tela

@author Ana Carolina Tome Klock
@since 08/11/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA321POS( oModel )
Local lRet 		:= .T.

If !Empty( oModel:GetModel('DG6DETAIL'):GetValue('DG6_DSNV') ) .And. Empty(FwFldGet('DG7_IDNV'))
	lRet := oModel:GetModel('DG6DETAIL'):LoadValue('DG6_IDNV', GetSxeNum('DG6', 'DG6_IDNV', RetSQLName( 'DG6' ), 1 ) )
	If lRet
		lRet := oModel:GetModel('DG7MASTER'):LoadValue('DG7_IDNV', oModel:GetModel('DG6DETAIL'):GetValue('DG6_IDNV') )
	EndIf
EndIf

If lRet .And. !Empty( oModel:GetModel('TUTDETAIL'):GetValue('DG6_DSNV') ) .And. Empty(FwFldGet('DG7_IDNVTU'))
	lRet := oModel:GetModel('TUTDETAIL'):LoadValue('DG6_IDNV', GetSxeNum('DG6', 'DG6_IDNV', RetSQLName( 'DG6' ), 2 ) )
 	If lRet
		lRet := oModel:GetModel('DG7MASTER'):LoadValue('DG7_IDNVTU', oModel:GetModel('TUTDETAIL'):GetValue('DG6_IDNV'))
	EndIf
EndIf

Return lRet
