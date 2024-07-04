#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBS410.CH'

//Compatibilização de fontes 30/05/2018

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS410
Cadastro do Bloco W - Relatorio Pais a Pais

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Function CTBS410()
Local oBrowse

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( 'CQM' )

oBrowse:SetDescription( STR0001 ) //Cadastro do Bloco W - Relatório País-a-País

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.CTBS410' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.CTBS410' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.CTBS410' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0011 Action 'VIEWDEF.CTBS410' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCQM := FWFormStruct(1,'CQM')
Local oStruCQN := FWFormStruct(1,'CQN')
Local oStruCQO := FWFormStruct(1,'CQO')
Local oStruCQP := FWFormStruct(1,'CQP')
Local oModel

oModel := MPFormModel():New('CTBS410')

oModel:AddFields('CQMMASTER',,oStruCQM)

oStruCQP:SetProperty('CQP_REG',MODEL_FIELD_OBRIGAT,.F.)

oModel:AddFields('CQPDETAIL','CQMMASTER',oStruCQP,,{|oModel| CQPPosVld(oModel)})

oModel:AddGrid('CQNDETAIL','CQMMASTER',oStruCQN, /*bLinePre*/, /*bLinePost*/{ || CQNLPOS() }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('CQODETAIL','CQNDETAIL',oStruCQO)

oModel:SetRelation('CQPDETAIL',{{'CQP_FILIAL','XFilial("CQP")'},{'CQP_CODID','CQM_CODID'}}, CQP->(IndexKey(1)) )
oModel:SetRelation('CQNDETAIL',{{'CQN_FILIAL','XFilial("CQN")'},{'CQN_CODID','CQM_CODID'}}, CQN->(IndexKey(1)) )
oModel:SetRelation('CQODETAIL',{{'CQO_FILIAL','XFilial("CQO")'},{'CQO_CODID','CQM_CODID'},{'CQO_ITEM','CQN_ITEM'}},CQO->(IndexKey(1)))

oModel:SetDescription('Modelo Bloco W')

oModel:GetModel('CQMMASTER'):SetDescription( STR0002 ) //"Registro W100: Grupo Multinacional e a Entidade Declarante"
oModel:GetModel('CQNDETAIL'):SetDescription( STR0003 ) //"Registro W200: Declaração País-a-País"
oModel:GetModel('CQODETAIL'):SetDescription( STR0004 ) //"Registro W250: Entidades Integrantes"
oModel:GetModel('CQPDETAIL'):SetDescription( STR0005 ) //"Registro W300: Observações adicionais"

oModel:GetModel( 'CQNDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'CQODETAIL' ):SetOptional( .T. )
oModel:GetModel( 'CQPDETAIL' ):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruCQM	:= FWFormStruct(2,'CQM')
Local oStruCQN	:= FWFormStruct(2,'CQN')
Local oStruCQO	:= FWFormStruct(2,'CQO')
Local oStruCQP	:= FWFormStruct(2,'CQP')
Local oModel		:= FWLoadModel('CTBS410')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CQM',oStruCQM,'CQMMASTER')
oView:AddField('VIEW_CQP',oStruCQP,'CQPDETAIL')

oView:AddGrid('VIEW_CQN',oStruCQN,'CQNDETAIL')
oView:AddGrid('VIEW_CQO',oStruCQO,'CQODETAIL')

oStruCQM:RemoveField('CQM_REG')
oStruCQN:RemoveField('CQN_REG')
oStruCQO:RemoveField('CQO_REG')
oStruCQO:RemoveField('CQO_ITEM')
oStruCQP:RemoveField('CQP_REG')
oStruCQP:RemoveField('CQP_FIMOBS')

// Cria Folder na view
oView:CreateFolder( 'BLOCOS' )

// Cria pastas nas folders
oView:AddSheet( 'BLOCOS', 'W100', 'W100' )
oView:AddSheet( 'BLOCOS', 'W300', 'W300' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' 	,  30,,, 'BLOCOS', 'W100' )
oView:CreateHorizontalBox( 'MEIO'		,  35,,, 'BLOCOS', 'W100' )
oView:CreateHorizontalBox( 'EMBAIXO'	,  35,,, 'BLOCOS', 'W100' )

oView:CreateHorizontalBox( 'GERAL'  , 100,,, 'BLOCOS', 'W300' )

oView:SetOwnerView('VIEW_CQM','EMCIMA'		)
oView:SetOwnerView('VIEW_CQN','MEIO'		)
oView:SetOwnerView('VIEW_CQO','EMBAIXO'	)

oView:SetOwnerView('VIEW_CQP','GERAL'		)

oView:EnableTitleView('VIEW_CQM')
oView:EnableTitleView('VIEW_CQN')
oView:EnableTitleView('VIEW_CQO')
oView:EnableTitleView('VIEW_CQP')

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_CQN', 'CQN_ITEM' )
oView:AddIncrementField( 'VIEW_CQO', 'CQO_SUBITE' )

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Validação sobre o preenchimento do Neto quando o filho estiver 
preenchido

@author TOTVS
@since 09/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function CQNLPOS()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

//----------------------------------------
// Valida se o bloco W250 esta preenchido
//----------------------------------------
If oModel:GetModel( 'CQODETAIL' ):IsEmpty()
	Help( , ,"CQNLPOS", ,STR0006,1,0,,,,,,{ STR0007 })	//"Cadastro do bloco W250 não preenchido!" ### 
																//"Para solucionar efetue o cadastro dos registros referente ao bloco W250"                    
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CQPPosVld
Pos-validacoes do submodelo CQP 

@author TOTVS
@since 29/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------
Function CQPPosVld(oModCQP)
Local lRet			:= .T.
Local nOperation	:= oModCQP:GetOperation()

//-------------------------------------------------------------------------------------
// Caso seja alteracao e a CQN esteja sendo preenchida agora, atribui o valor do campo
// CQP_REG e CQP_FIMOBS, pois o X3_RELACAO nao eh ativado (na CQN e CQO funciona)
//-------------------------------------------------------------------------------------
If nOperation == MODEL_OPERATION_UPDATE .And. oModCQP:IsModified() .And. Empty(oModCQP:GetValue("CQP_REG"))
	oModCQP:SetValue("CQP_REG",CriaVar("CQP_REG",.T.))
	oModCQP:SetValue("CQP_FIMOBS",CriaVar("CQP_FIMOBS",.T.))
EndIf

Return lRet


