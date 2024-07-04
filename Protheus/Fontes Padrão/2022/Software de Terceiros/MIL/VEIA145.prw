#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'VEIA145.CH'

Function VEIA145()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VJU')
oBrowse:SetDescription( STR0001 ) //'Relacionamento modelo JD X Protheus'
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('VEIA145')

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrVJU := FWFormStruct(1, "VJU")

oModel := MPFormModel():New('VEIA145',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VJUMASTER',/*cOwner*/ , oStrVJU)
oModel:SetPrimaryKey( { "VJU_FILIAL", "VJU_CODIGO" } )
oModel:SetDescription( STR0001 )
oModel:GetModel('VJUMASTER'):SetDescription( STR0002 ) //'Dados do relacionamento modelo JD X Protheus'
oModel:InstallEvent("VEIA145EVF", /*cOwner*/, VEIA145EVF():New("VEIA145"))

Return oModel

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrVJU:= FWFormStruct(2, "VJU")

oView := FWFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( 'VJU', 100)
oView:AddField('VIEW_VJU', oStrVJU, 'VJUMASTER')
oView:EnableTitleView('VIEW_VJU', STR0001 )
oView:SetOwnerView('VIEW_VJU','VJU')

Return oView