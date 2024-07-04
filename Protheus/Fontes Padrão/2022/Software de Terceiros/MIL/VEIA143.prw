#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'VEIA143.CH'

Function VEIA143()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VJS')
oBrowse:SetDescription( STR0001 ) // "Histórico de alteração de pedido de máquina"
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('VEIA143')

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrVJS := FWFormStruct(1, "VJS")

oModel := MPFormModel():New('VEIA143',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VJSMASTER',/*cOwner*/ , oStrVJS)
oModel:SetPrimaryKey( { "VJS_FILIAL", "VJS_CODIGO" } )
oModel:SetDescription( STR0001 ) // "Histórico de alteração de pedido de máquina"
oModel:GetModel('VJSMASTER'):SetDescription( STR0002 ) //Dados do histórico de alteração de pedido de máquina

Return oModel

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrVJS:= FWFormStruct(2, "VJS")

oView := FWFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( 'VJS', 100)
oView:AddField('VIEW_VJS', oStrVJS, 'VJSMASTER')
oView:EnableTitleView('VIEW_VJS', STR0001 ) // "Histórico de alteração de pedido de máquina"
oView:SetOwnerView('VIEW_VJS','VJS')

Return oView