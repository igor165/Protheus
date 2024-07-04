
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OFIA210.CH"

Static cNCpoVM4    := "VM4_CODVM3|"

Function OFIA211()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VM3')
	oBrowse:SetDescription(STR0001) // Solicita�ao de Pe�as Oficina
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA211')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVM3 := FWFormStruct(1, "VM3")
	Local oStrVM4 := FWFormStruct(1, "VM4")

	oModel := MPFormModel():New('OFIA211',;
	/*Pr�-Validacao*/,;
	/*P�s-Validacao*/,;
	/*Confirmacao da Grava��o*/,;
	/*Cancelamento da Opera��o*/)


	oModel:AddFields('VM3MASTER',/*cOwner*/ , oStrVM3)
	oModel:SetPrimaryKey( { "VM3_FILIAL", "VM3_CODIGO" } )

	oModel:AddGrid("VM4DETAIL","VM3MASTER",oStrVM4)
	oModel:SetRelation( 'VM4DETAIL', { { 'VM4_FILIAL', 'xFilial( "VM4" )' }, { 'VM4_CODVM3', 'VM3_CODIGO' } }, VM4->( IndexKey( 2 ) ) )

	oModel:SetDescription(STR0001) // Solicita�ao de Pe�as Oficina
	oModel:GetModel('VM3MASTER'):SetDescription(STR0026) // Dados da Conferencia da Solicita��o de Pe�as Oficina
	oModel:GetModel('VM4DETAIL'):SetDescription(STR0027) // Dados dos Itens da Solicita��o de Pe�as Oficina

	oModel:InstallEvent("OFIA211EVDF", /*cOwner*/, OFIA211EVDF():New("OFIA211"))

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVM3:= FWFormStruct(2, "VM3")
	Local oStrVM4:= FWFormStruct(2, "VM4", { |cCampo| !ALLTRIM(cCampo)+"|" $ cNCpoVM4 })

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVM3', 40)
	oView:AddField('VIEW_VM3', oStrVM3, 'VM3MASTER')
	oView:EnableTitleView('VIEW_VM3', STR0001 ) // Solicita��o de Pe�as Oficina
	oView:SetOwnerView('VIEW_VM3','BOXVM3')

	oView:CreateHorizontalBox( 'BOXVM4', 60)
	oView:AddGrid("VIEW_VM4",oStrVM4, 'VM4DETAIL')
	oView:EnableTitleView('VIEW_VM4', STR0028 ) // Itens da Solicita��o de Pe�as Oficina
	oView:SetOwnerView('VIEW_VM4','BOXVM4')

Return oView