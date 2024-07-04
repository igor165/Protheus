#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA012.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA012()
Cadastro de tipo de serviços extraordinarios - GYw
@sample		GTPA012()
@return		oBrowse  Retorna o Cadastro de Tipos de Servicos Extraordinarios
@author	Lucas.Brustolin
@since		06/10/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GTPA012()

Local oBrowse	:= Nil
Local aRotina	:= MenuDef()

oBrowse:=FWMBrowse():New()
oBrowse:SetAlias("GYW")
oBrowse:SetDescription(STR0005)		// "Tipos de Serviços Extraordinários"
oBrowse:Activate()

Return oBrowse

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel - Retorna o Modelo de dados 
@author	Lucas.Brustolin
@since		06/10/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= nil
Local oStruGYW	:= FWFormStruct(1,'GYW')//Tipos de Serviços Ext.
Local oStruGYM	:= FwFormStruct(1,'GYM')//Recurpos por trechos

oStruGYM:SetProperty('GYM_ORIGEM', MODEL_FIELD_INIT,{||  "GYW" } )

oModel := MPFormModel():New('GTPA012',,{|oModel|TP012TudOK(oModel)})

oModel:AddFields('GYWMASTER',/*cOwner*/,oStruGYW)
oModel:AddGrid('GYMDETAIL','GYWMASTER',oStruGYM)

oModel:SetRelation( 'GYMDETAIL', { { 'GYM_FILIAL', 'xFilial( "GYW" )' }, { 'GYM_CODENT'	, 'GYW_CODIGO' } } , GYM->(IndexKey(1))) 

//Não permite repetir incluir o mesmo recurso (colaborador).
oModel:GetModel('GYMDETAIL'):SetUniqueLine({'GYM_RECCOD'})

//Permite grid sem dados
oModel:GetModel('GYMDETAIL'):SetOptional(.T.)

oModel:SetDescription(STR0005)
oModel:GetModel('GYMDETAIL'):SetDescription(STR0006)	// "Tipos de Recursos"
oModel:SetPrimaryKey({"GYW_FILIAL","GYW_CODIGO"})

Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
@sample		ViewDef()
@return		oView - Retorna a View
@author	Lucas.Brustolin
@since		06/10/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= ModelDef() 
Local oView		:= FWFormView():New()
Local oStruGYW	:= FWFormStruct(2, 'GYW')
Local oStruGYM	:= FWFormStruct(2, 'GYM')

oStruGYM:RemoveField('GYM_CODIGO')
oStruGYM:RemoveField('GYM_QTD')
oStruGYM:RemoveField('GYM_ORIGEM')
oStruGYM:RemoveField('GYM_CODENT')

oView:SetModel(oModel)

oView:AddField('VIEW_GYW' ,oStruGYW,'GYWMASTER')
oView:AddGRID('VIEW_GYM' ,oStruGYM,'GYMDETAIL')

// Criar um box horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 35 )
oView:CreateHorizontalBox( 'INFERIOR', 65 )

oView:SetOwnerView('VIEW_GYW','SUPERIOR')
oView:SetOwnerView('VIEW_GYM','INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_GYW',STR0005)//"Tipos de Serviços Extraordinários"
oView:EnableTitleView('VIEW_GYM',STR0006)//"Tipos de Recursos"

Return( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
@sample		MenuDef()
@return		aRotina - Array de opções do menu
@author	Lucas.Brustolin
@since		06/10/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0001    ACTION 'VIEWDEF.GTPA012' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0002    ACTION 'VIEWDEF.GTPA012' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA012' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA012' OPERATION 5 ACCESS 0 // Excluir

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP012TudOK()
Validação do Modelo 
@sample	TP012TudOK(oModel)
@param		oModel   Modelo de Dados
@return	lRet - Retorna a validacao do modelo de dados (TudoOK)
@author	Inovação
@since		04/11/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP012TudOK(oModel)

Local nOperation	:= oModel:GetOperation()
Local cAliasTmp	:= GetNextAlias()  
Local cCodigo		:= ""
Local lRet			:= .T.

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GYW", oModel:GetModel('GYWMASTER'):GetValue("GYW_CODIGO")))
		Help( ,, 'Help',"TP012TdOK", STR0008, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return ( lRet )