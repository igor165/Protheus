#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA043.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA043()
Visualização de Logs de Eventos
 
@sample	GTPA043()
 
@return	oBrowse	Retorna o Log de Eventos
 
@author	Flavio Martins -  Inovação
@since		14/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA043()

Local oBrowse		:= Nil	

Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('GZ9')
oBrowse:SetDescription(STR0001) //Logs de Eventos	
oBrowse:AddLegend("GZ9_STATUS=='1'", "GREEN", STR0004) // Enviado
oBrowse:AddLegend("GZ9_STATUS=='2'", "RED", STR0005) // Inativo
oBrowse:Activate()

Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Flavio Martins -  Inovação
@since		14/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruGZ9	:= FWFormStruct(1,'GZ9')

oModel := MPFormModel():New('GTPA043', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields('GZ9MASTER',/*cOwner*/,oStruGZ9)
oModel:GetModel('GZ9MASTER'):SetDescription(STR0002) //Dados do Log de Eventos
oModel:SetPrimaryKey({"GZ9_FILIAL","GZ9_CODIGO"})

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	Flavio Martins -  Inovação
@since		14/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= ModelDef() 
Local oView		:= FWFormView():New()
Local oStruGZ9	:= FWFormStruct(2, 'GZ9')

oStruGZ9:RemoveField('GZ9_HASH')

oView:SetModel(oModel)
oView:SetDescription(STR0002) 
oView:AddField('VIEW_GZ9' ,oStruGZ9,'GZ9MASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_GZ9','TELA')

Return ( oView )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	Flavio Martins -  Inovação
@since		14/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003  ACTION 'VIEWDEF.GTPA043' OPERATION 2 ACCESS 0 // Visualizar

Return ( aRotina )