#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA711.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA711()
Cadastro de Tipos de Agência 
@sample	GTPA711() 
@return	oBrowse	Retorna o Cadastro de Tipos de Agência 
@author	GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA711()

Local oBrowse := FWMBrowse():New()	

oBrowse:SetAlias('GI5')
oBrowse:SetDescription(STR0001)	//Cadastro de Tipos de Agência

oBrowse:SetMenuDef('GTPA711')

oBrowse:Activate()

Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu 
@sample	MenuDef() 
@return	aRotina - Retorna as opções do Menu 
@author		GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.GTPA711' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.GTPA711' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.GTPA711' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.GTPA711' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados 
@sample	ModelDef() 
@return	oModel  Retorna o Modelo de Dados 
@author	GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= MPFormModel():New('GTPA711', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
Local oStruGI5	:= FWFormStruct(1,'GI5')

oStruGI5:SetProperty('*'			,MODEL_FIELD_OBRIGAT, .F. )
oStruGI5:SetProperty('GI5_CODIGO'	,MODEL_FIELD_OBRIGAT, .T. )
oStruGI5:SetProperty('GI5_TIPO'		,MODEL_FIELD_OBRIGAT, .T. )
oStruGI5:SetProperty('GI5_DESCRI'	,MODEL_FIELD_OBRIGAT, .T. )

oModel:AddFields('GI5MASTER',/*cOwner*/,oStruGI5)
oModel:SetDescription(STR0002)						//Cadastro de Tipos de Escala Extraordinaria
oModel:GetModel('GI5MASTER'):SetDescription(STR0003)	//Dados do Tipos de Agência

Return ( oModel )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface 
@sample	ViewDef() 
@return	oView  Retorna a View 
@author	GTP
@since		20/05/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA711') 
Local oView		:= FWFormView():New()
Local oStruGI5	:= FWFormStruct(2, 'GI5')

If oStruGI5:HasField("GI5_NOME")
	oStruGI5:RemoveField("GI5_NOME")
EndIf
If oStruGI5:HasField("GI5_CPF")
	oStruGI5:RemoveField("GI5_CPF")
EndIf
If oStruGI5:HasField("GI5_MOTORI")
	oStruGI5:RemoveField("GI5_MOTORI")
EndIf
If oStruGI5:HasField("GI5_NMOTOR")
	oStruGI5:RemoveField("GI5_NMOTOR")
EndIf
If oStruGI5:HasField("GI5_STATUS")
	oStruGI5:RemoveField("GI5_STATUS")
EndIf

oStruGI5:SetProperty("GI5_CODIGO" , MVC_VIEW_ORDEM, '01')
oStruGI5:SetProperty("GI5_DESCRI" , MVC_VIEW_ORDEM, '02')
oStruGI5:SetProperty("GI5_TIPO"	  , MVC_VIEW_ORDEM, '03')

oView:SetModel(oModel)
oView:AddField('VIEW_GI5' ,oStruGI5,'GI5MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_GI5','TELA')

oView:SetDescription(STR0004)

Return ( oView )
