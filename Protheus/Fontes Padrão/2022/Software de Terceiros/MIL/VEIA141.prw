#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA141.CH"

Function VEIA141()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VJQ')
oBrowse:SetDescription(STR0001) //'Histórico de Importação CGPoll'
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('VEIA141')

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrVJQ := FWFormStruct(1, "VJQ")

oModel := MPFormModel():New('VEIA141',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VJQMASTER',/*cOwner*/ , oStrVJQ)
oModel:SetPrimaryKey( { "VJQ_FILIAL", "VJQ_CODIGO" } )
oModel:SetDescription(STR0001)
oModel:GetModel('VJQMASTER'):SetDescription(STR0002) //Dados do histórico de importação CGPoll

Return oModel

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrVJQ:= FWFormStruct(2, "VJQ")

oView := FWFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( 'VJQ', 100)
oView:AddField('VIEW_VJQ', oStrVJQ, 'VJQMASTER')
oView:EnableTitleView('VIEW_VJQ', STR0001)
oView:SetOwnerView('VIEW_VJQ','VJQ')

Return oView