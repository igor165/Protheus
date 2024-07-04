#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'VEIA164.CH'

Function VEIA164()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VJT')
	oBrowse:SetDescription( STR0001 ) // Campos configurados para alerta
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('VEIA164')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVJT := FWFormStruct(1, "VJT")

	oModel := MPFormModel():New('VEIA164',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oModel:AddFields('VJTMASTER',/*cOwner*/ , oStrVJT)
	oModel:SetPrimaryKey( { "VJT_FILIAL", "VJT_CODIGO" } )
	oModel:SetDescription( STR0001 ) // Campos configurados para alerta
	oModel:GetModel('VJTMASTER'):SetDescription( STR0002 ) // Dados dos campos configurados para alerta

	Return oModel

	Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVJT:= FWFormStruct(2, "VJT")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'VJT', 100)
	oView:AddField('VIEW_VJT', oStrVJT, 'VJTMASTER')
	oView:EnableTitleView('VIEW_VJT', STR0001 ) // Campos configurados para alerta
	oView:SetOwnerView('VIEW_VJT','VJT')

Return oView