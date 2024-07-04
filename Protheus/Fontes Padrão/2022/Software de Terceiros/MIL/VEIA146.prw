#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA146.CH"

Function VEIA146()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VJV')
	oBrowse:SetDescription( STR0001 ) //"Opcionais de máquinas John Deere"
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('VEIA146')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVJV := FWFormStruct(1, "VJV")
	Local lVJV_CODVJU := ( VJV->(ColumnPos("VJV_CODVJU")) > 0 )

	oModel := MPFormModel():New('VEIA146',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oModel:AddFields('VJVMASTER',/*cOwner*/ , oStrVJV)
	If lVJV_CODVJU
		oModel:SetPrimaryKey( { "VJV_FILIAL" , "VJV_CODIGO" , "VJV_CODVJU" } )
	Else
		oModel:SetPrimaryKey( { "VJV_FILIAL" , "VJV_CODIGO" } )
	EndIf
	oModel:SetDescription( STR0001 )
	oModel:GetModel('VJVMASTER'):SetDescription( STR0002 ) //'Dados do opcionais de máquinas John Deere'

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVJV:= FWFormStruct(2, "VJV")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'VJV', 100)
	oView:AddField('VIEW_VJV', oStrVJV, 'VJVMASTER')
	oView:EnableTitleView('VIEW_VJV', STR0001 )
	oView:SetOwnerView('VIEW_VJV','VJV')

Return oView