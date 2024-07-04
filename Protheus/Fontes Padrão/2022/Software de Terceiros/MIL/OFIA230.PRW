
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OFIA230.CH"

Static cNCpoVM6    := "VM6_CODVM5|"

Function OFIA230()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VM5')
	oBrowse:SetDescription(STR0001) // Conferência Orçamento
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA230')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVM5 := FWFormStruct(1, "VM5")
	Local oStrVM6 := FWFormStruct(1, "VM6")

	oModel := MPFormModel():New('OFIA230',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)


	oModel:AddFields('VM5MASTER',/*cOwner*/ , oStrVM5)
	oModel:SetPrimaryKey( { "VM5_FILIAL", "VM5_CODIGO" } )

	oModel:AddGrid("VM6DETAIL","VM5MASTER",oStrVM6)
	oModel:SetRelation( 'VM6DETAIL', { { 'VM6_FILIAL', 'xFilial( "VM6" )' }, { 'VM6_CODVM5', 'VM5_CODIGO' } }, VM6->( IndexKey( 2 ) ) )

	oModel:SetDescription(STR0001) // Conferência Orçamento
	oModel:GetModel('VM5MASTER'):SetDescription(STR0002) // Dados da Conferência Orçamento
	oModel:GetModel('VM6DETAIL'):SetDescription(STR0003) // Itens da Conferência Orçamento

	oModel:InstallEvent("OFIA230EVDF", /*cOwner*/, OFIA230EVDF():New("OFIA230"))

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVM5:= FWFormStruct(2, "VM5")
	Local oStrVM6:= FWFormStruct(2, "VM6", { |cCampo| !ALLTRIM(cCampo)+"|" $ cNCpoVM6 })

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVM5', 40)
	oView:AddField('VIEW_VM5', oStrVM5, 'VM5MASTER')
	oView:EnableTitleView('VIEW_VM5', STR0001) // Conferência Orçamento
	oView:SetOwnerView('VIEW_VM5','BOXVM5')

	oView:CreateHorizontalBox( 'BOXVM6', 60)
	oView:AddGrid("VIEW_VM6",oStrVM6, 'VM6DETAIL')
	oView:EnableTitleView('VIEW_VM6', STR0003) // Itens da Conferência Orçamento
	oView:SetOwnerView('VIEW_VM6','BOXVM6')

Return oView