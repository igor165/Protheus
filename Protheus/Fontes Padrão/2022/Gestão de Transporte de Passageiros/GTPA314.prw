#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA314.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA314()
Cadastro de Tipos de Escala Extraordinaria
 
@sample	GTPA314()
 
@return	oBrowse	Retorna o Cadastro de Plantões
 
@author	jacomo.fernandes
@since		16/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA314()

Local oBrowse := FWMBrowse():New()	

oBrowse:SetAlias('GZS')
oBrowse:SetDescription(STR0001)	//Cadastro de Tipos de Escala Extraordinaria

oBrowse:SetMenuDef('GTPA314')

oBrowse:Activate()

Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author		jacomo.fernandes
@since		16/02/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA314' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA314' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA314' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA314' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	jacomo.fernandes
@since		16/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= MPFormModel():New('GTPA314', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
Local oStruGZS	:= FWFormStruct(1,'GZS')

oModel:AddFields('GZSMASTER',/*cOwner*/,oStruGZS)
oModel:SetDescription(STR0001)	//Cadastro de Tipos de Escala Extraordinaria
oModel:GetModel('GZSMASTER'):SetDescription(STR0002)	//Dados do Tipos de Escala Extraordinaria


Return ( oModel )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	jacomo.fernandes
@since		16/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA314') 
Local oView		:= FWFormView():New()
Local oStruGZS	:= FWFormStruct(2, 'GZS')

oView:SetModel(oModel)
oView:AddField('VIEW_GZS' ,oStruGZS,'GZSMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_GZS','TELA')

oView:SetDescription(STR0001)

Return ( oView )
