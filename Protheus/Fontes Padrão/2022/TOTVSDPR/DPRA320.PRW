#INCLUDE 'DPRA320.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA320
Tela de Cadastro de Operações

@author Ana Carolina Tome Klock
@since 23/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA320()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA320', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG9')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Operação'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA320' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA320' OPERATION 3 ACCESS 0    // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA320' OPERATION 4 ACCESS 0    // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA320' OPERATION 5 ACCESS 0    // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA320' OPERATION 8 ACCESS 0    // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRA320' OPERATION 9 ACCESS 0    // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDG9 := FWFormStruct( 1, 'DG9', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG7 := FWFormStruct( 1, 'DG7', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG2 := FWFormStruct( 1, 'DG2', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG8 := FWFormStruct( 1, 'DG8', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructDG6 := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructTUT := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA320', /*bPreValidacao*/,  { |oModel| DPRA320POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DG9MASTER', /*cOwner*/, oStructDG9, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'DG7DETAIL', 'DG9MASTER', oStructDG7, { |oModel| DPRA320DG7(oModel,1) }, { |oModel| DPRA320DG7(oModel,2) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DG2DETAIL', 'DG9MASTER', oStructDG2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DG8DETAIL', 'DG9MASTER', oStructDG8, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DG6DETAIL', 'DG9MASTER', oStructDG6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'TUTDETAIL', 'DG9MASTER', oStructTUT, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'DG7DETAIL', { { 'DG7_FILIAL', 'xFilial( "DG7" )' }, { 'DG7_IDAT'  , 'DG9_IDAT'  } }, DG7->( IndexKey(1)) )
oModel:SetRelation( 'DG2DETAIL', { { 'DG2_FILIAL', 'xFilial( "DG2" )' }, { 'DG2_IDAT'  , 'DG9_IDAT'  }, {'DG2_CDATAV', 'SPACE( TamSX3("DG2_CDATAV")[1] )'} }, DG2->( IndexKey(1)) )
oModel:SetRelation( 'DG8DETAIL', { { 'DG8_FILIAL', 'xFilial( "DG8" )' }, { 'DG8_IDAT'  , 'DG9_IDAT'  }, {'DG8_CDATAV', 'SPACE( TamSX3("DG8_CDATAV")[1] )'} }, DG8->( IndexKey(1)) )
oModel:SetRelation( 'DG6DETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DG9_IDNV'  } }, DG6->( IndexKey(1)) )
oModel:SetRelation( 'TUTDETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DG9_IDNVTU'} }, DG6->( IndexKey(1)) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados da Operação'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DG9MASTER' ):SetDescription( STR0010 ) // 'Dados da Operação'
oModel:GetModel( 'DG7DETAIL' ):SetDescription( STR0011 ) // 'Dados da Operação Alternativa'
oModel:GetModel( 'DG2DETAIL' ):SetDescription( STR0012 ) // 'Dados da Ferramenta'
oModel:GetModel( 'DG8DETAIL' ):SetDescription( STR0013 ) // 'Dados do Consumível'
oModel:GetModel( 'DG6DETAIL' ):SetDescription( STR0014 ) // 'Dados da Narrativa'
oModel:GetModel( 'TUTDETAIL' ):SetDescription( STR0015 ) // 'Dados do Tutorial'

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'DG7DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG2DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG8DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG6DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'TUTDETAIL' ):SetOptional(.T.)

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'DG6DETAIL' ):SetNoInsertLine()
oModel:GetModel( 'TUTDETAIL' ):SetNoInsertLine()

// Retira a obrigatoriedade do campo Maquina
If DPRIntegra() == 2
	oModel:GetModel( 'DG9MASTER' ):GetStruct():SetProperty( 'DG9_CDMQ'  ,  MODEL_FIELD_OBRIGAT,  .F. )
EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA320' )
// Cria a estrutura a ser usada na View
Local oStructDG9 := FWFormStruct( 2, 'DG9' )
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
oView:AddField( 'VIEW_DG9', oStructDG9, 'DG9MASTER' )

// Adiciona no nosso View um controle do tipo FormGrid (antiga newgetdados)
If DPRIntegra() == 2
	oView:AddGrid( 'VIEW_DG7', oStructDG7, 'DG7DETAIL' )
	oView:AddGrid( 'VIEW_DG2', oStructDG2, 'DG2DETAIL' )
	oView:AddGrid( 'VIEW_DG8', oStructDG8, 'DG8DETAIL' )
	oView:AddGrid( 'VIEW_DG6', oStructDG6, 'DG6DETAIL' )
	oView:AddGrid( 'VIEW_TUT', oStructDG6, 'TUTDETAIL' )
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
	oView:AddSheet( 'FOLDER', 'TAB01', STR0016 )   // 'Alternativa'
	oView:AddSheet( 'FOLDER', 'TAB02', STR0017 )   // 'Ferramenta'
	oView:AddSheet( 'FOLDER', 'TAB03', STR0018 )   // 'Consumível'
	oView:AddSheet( 'FOLDER', 'TAB04', STR0019 )   // 'Narrativa'
	oView:AddSheet( 'FOLDER', 'TAB05', STR0020 )   // 'Tutorial'

	oView:CreateHorizontalBox( 'DG7', 100, , ,'FOLDER', 'TAB01' )
	oView:CreateHorizontalBox( 'DG2', 100, , ,'FOLDER', 'TAB02' )
	oView:CreateHorizontalBox( 'DG8', 100, , ,'FOLDER', 'TAB03' )
	oView:CreateHorizontalBox( 'DG6', 100, , ,'FOLDER', 'TAB04' )
	oView:CreateHorizontalBox( 'TUT', 100, , ,'FOLDER', 'TAB05' )
EndIf
// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DG9', 'SUPERIOR' )
If DPRIntegra() == 2
	oView:SetOwnerView( 'VIEW_DG7', 'DG7' )
	oView:SetOwnerView( 'VIEW_DG2', 'DG2' )
	oView:SetOwnerView( 'VIEW_DG8', 'DG8' )
	oView:SetOwnerView( 'VIEW_DG6', 'DG6' )
	oView:SetOwnerView( 'VIEW_TUT', 'TUT' )
EndIf

// Adiciona um botão para cadastro de operações alternativas
If DPRIntegra() == 2
	oView:AddUserButton( 'Detalhe Alternativa', 'DPRA321', { |oModel| DPRA320ALT(oModel) } )  // 'Operação Alternativa'
EndIf

// Remove o campo repetido da tela
oStructDG9:RemoveField('DG9_IDNV'  )
oStructDG9:RemoveField('DG9_IDNVTU')
oStructDG9:RemoveField('DG9_IDAT'  )
oStructDG7:RemoveField('DG7_IDNVTU')
oStructDG7:RemoveField('DG7_IDAT'  )
oStructDG7:RemoveField('DG7_IDNV'  )
oStructDG2:RemoveField('DG2_IDNV'  )
oStructDG2:RemoveField('DG2_LGFE'  )
oStructDG2:RemoveField('DG2_IDAT'  )
oStructDG2:RemoveField('DG2_CDATAV')
oStructDG8:RemoveField('DG8_IDNV'  )
oStructDG8:RemoveField('DG8_IDAT'  )
oStructDG8:RemoveField('DG8_CDATAV')
oStructDG6:RemoveField('DG6_IDNV'  )
oStructTUT:RemoveField('DG6_IDNV'  )
If DPRIntegra() == 1
	oStructDG9:RemoveField('DG9_CDRE')
EndIf

// Permite apenas visualizar campos virtuais
If DPRIntegra() == 2
	oView:GetViewStruct('VIEW_DG7'):SetProperty('DG7_CDATAV', MVC_VIEW_CANCHANGE , .F.)
EndIf

// Ajusta o tamanho da narrativa
oStructDG6:SetProperty( 'DG6_DSNV', MODEL_FIELD_TAMANHO, {15000} )
oStructTUT:SetProperty( 'DG6_DSNV', MODEL_FIELD_TAMANHO, {15000} )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA320DG7
Realiza a Pre/Pos validação da Linha/Modelo para a tabela DG7 (Operação)

@param 	oModel		Modelo de dados da tela
@param 	nValida	Identifica o tipo de validação (1=PreLine, 2=PosLine, 3=PosVal)
@return 	lRet		Se foi validado (.T.) ou não (.F.)

@author Ana Carolina Tome Klock
@since 27/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA320DG7( oModel, nValida )
Local lRet 		:= .T.

// PreLine
If nValida == 1
	If Empty( oModel:GetValue('DG7_CDATAV') ) .And. DPRXVldMdl( oModel )
		lRet := DPRXSetVal( oModel, 'DG7_CDATAV' )
	EndIf

// PosLine
ElseIf nValida == 2

	// Exige Centro de Trabalho quando Tipo da Operação for Interno
	If FwFldGet('DG7_TPAT') == '1'  .And. Empty(FwFldGet('DG7_CDCETR')) .And. !oModel:IsDeleted()
		DPRXError( 'DPRA320', 'DPRA300_OPER1', 3 )
		lRet := .F.

	// Limpa Centro de Trabalho quando Tipo da Operação for Externo
	ElseIf FwFldGet('DG7_TPAT') == '2' .And. !Empty(FwFldGet('DG7_CDCETR')) .And. !oModel:IsDeleted()
   		lRet := FwFldPut('DG7_CDCETR', '')

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA320POS
Realiza a pos-validacao dos dados da tela

@author Ana Carolina Tome Klock
@since 26/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA320POS( oModel )
Local nI        := 1
Local oModelIns
Local lRet 		:= .T.

// Lê todas as linhas
dbSelectArea('DG7')
dbSetOrder(1)
For nI := 1 to oModel:GetModel('DG7DETAIL'):Length()
	If oModel:GetModel('DG7DETAIL'):IsDeleted(nI) .Or. oModel:GetOperation() == 5
		// Elimina os filhos da operação se a operação já foi salva
		If dbSeek( xFilial('DG7') + FwFldGet('DG9_IDAT') + FwFldGet('DG7_CDATAV', nI) )
			oModelIns := FWLoadModel( 'DPRA321' )
			oModelIns:SetOperation(5)
			oModelIns:Activate()
			oModelIns:CommitData()
			oModelIns:Deactivate()
		EndIf
	EndIf
Next

// Caso esteja incluindo uma narrativa para um produto novo ou existente
If oModel:GetOperation() == 3 .Or. (oModel:GetOperation() == 4 .And. Empty(oModel:GetValue('DG6DETAIL','DG6_IDNV')) )
	lRet := oModel:GetModel('DG6DETAIL'):LoadValue('DG6_IDNV', GETSXENUM('DG6', 'DG6_IDNV', RetSQLName( 'DG6' ), 1 ) )
EndIf
If oModel:GetOperation() == 3 .Or. (oModel:GetOperation() == 4 .And. Empty(oModel:GetValue('TUTDETAIL','DG6_IDNV')) )
	lRet := oModel:GetModel('TUTDETAIL'):LoadValue('DG6_IDNV', GETSXENUM('DG6', 'DG6_IDNV', RetSQLName( 'DG6' ), 1 ) )
EndIf

If FwFldGet('DG9_IDNV') != oModel:GetValue('DG6DETAIL','DG6_IDNV')
	lRet := oModel:GetModel('DG9MASTER'):LoadValue('DG9_IDNV', oModel:GetValue('DG6DETAIL','DG6_IDNV') )
EndIf
If FwFldGet('DG9_IDNVTU') != oModel:GetValue('TUTDETAIL','DG6_IDNV')
	lRet := oModel:GetModel('DG9MASTER'):LoadValue('DG9_IDNVTU', oModel:GetValue('TUTDETAIL','DG6_IDNV') )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA320ALT
Cria uma operação alternativa para a operação

@author Ana Carolina Tome Klock
@since 28/05/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA320ALT( oModel )
Local oModelAlt
Local oModelDG7 := oModel:GetModel('DG7DETAIL')

// Verifica se o componente foi salvo
dbSelectArea('DG7')
dbSetOrder(1)
If dbSeek( xFilial('DG7') + FwFldGet('DG7_IDAT') + FwFldGet('DG7_CDATAV') ) .And. !oModelDG7:IsUpdated()

	// Chama o Modelo para Criar uma Versão
	oModelAlt:= FwLoadModel('DPRA321')

	// Define Operação de Inclusão de Registro
	oModelAlt:SetOperation(4)

	// Ativa o Modelo
	oModelAlt:Activate()

	// Seta valores para os campos do Modelo
	oModelAlt:SetValue('DG7MASTER', 'DG7_IDAT'  , oModelDG7:GetValue('DG7_IDAT')   )
	oModelAlt:SetValue('DG7MASTER', 'DG7_CDATAV', oModelDG7:GetValue('DG7_CDATAV') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_DSAT'  , oModelDG7:GetValue('DG7_DSAT')   )
	oModelAlt:SetValue('DG7MASTER', 'DG7_TPAT'  , oModelDG7:GetValue('DG7_TPAT')   )
	oModelAlt:SetValue('DG7MASTER', 'DG7_CDCETR', oModelDG7:GetValue('DG7_CDCETR') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_CDMOD' , oModelDG7:GetValue('DG7_CDMOD')  )
	oModelAlt:SetValue('DG7MASTER', 'DG7_NRUNAC', oModelDG7:GetValue('DG7_NRUNAC') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_TPUNTE', oModelDG7:GetValue('DG7_TPUNTE') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_QTTESU', oModelDG7:GetValue('DG7_QTTESU') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_QTTEMQ', oModelDG7:GetValue('DG7_QTTEMQ') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_QTTERC', oModelDG7:GetValue('DG7_QTTERC') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_CDUNAT', oModelDG7:GetValue('DG7_CDUNAT') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_NRATSM', oModelDG7:GetValue('DG7_NRATSM') )
	oModelAlt:SetValue('DG7MASTER', 'DG7_QTRC'  , oModelDG7:GetValue('DG7_QTRC')   )

	// Define o bloqueio de edição dos campos
	oModelAlt:GetModel('DG7MASTER'):GetStruct():SetProperty('*', MODEL_FIELD_NOUPD,.T.)

	// Executa o Modelo
	FWExecView('','DPRA321', 4,,{ || .T. },,,,,,, oModelAlt )

EndIf

Return Nil
