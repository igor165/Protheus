
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OFIA190.CH"

Static cNCpoVM1    := "VM1_CODVM0|"

Function OFIA190()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VM0')
	oBrowse:SetDescription(STR0001) // Conferência Nota Fiscal de Entrada
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA190')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVM0 := FWFormStruct(1, "VM0")
	Local oStrVM1 := FWFormStruct(1, "VM1")

	oModel := MPFormModel():New('OFIA190',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)


	oModel:AddFields('VM0MASTER',/*cOwner*/ , oStrVM0)
	oModel:SetPrimaryKey( { "VM0_FILIAL", "VM0_CODIGO" } )

	oModel:AddGrid("VM1DETAIL","VM0MASTER",oStrVM1)
	oModel:SetRelation( 'VM1DETAIL', { { 'VM1_FILIAL', 'xFilial( "VM1" )' }, { 'VM1_CODVM0', 'VM0_CODIGO' } }, VM1->( IndexKey( 2 ) ) )

	oModel:SetDescription(STR0001) // Conferência Nota Fiscal de Entrada
	oModel:GetModel('VM0MASTER'):SetDescription(STR0001) // Conferência Nota Fiscal de Entrada
	oModel:GetModel('VM1DETAIL'):SetDescription(STR0002) // Itens da Nota Fiscal de Entrada

	oModel:InstallEvent("OFIA190EVDF", /*cOwner*/, OFIA190EVDF():New("OFIA190"))

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVM0:= FWFormStruct(2, "VM0")
	Local oStrVM1:= FWFormStruct(2, "VM1", { |cCampo| !ALLTRIM(cCampo)+"|" $ cNCpoVM1 })

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVM0', 40)
	oView:AddField('VIEW_VM0', oStrVM0, 'VM0MASTER')
	oView:EnableTitleView('VIEW_VM0', STR0001) // Conferência Nota Fiscal de Entrada
	oView:SetOwnerView('VIEW_VM0','BOXVM0')

	oView:CreateHorizontalBox( 'BOXVM1', 60)
	oView:AddGrid("VIEW_VM1",oStrVM1, 'VM1DETAIL')
	oView:EnableTitleView('VIEW_VM1', STR0002) // Itens da Nota Fiscal de Entrada
	oView:SetOwnerView('VIEW_VM1','BOXVM1')

Return oView