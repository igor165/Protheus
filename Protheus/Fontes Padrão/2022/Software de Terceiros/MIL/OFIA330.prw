#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OFIA330.CH"

Static cNCpoVM8    := "VM8_CODVM7|"

Function OFIA330()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VM7')
	oBrowse:SetDescription(STR0001) // Conferência de Entrada por Volume
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA330')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVM7 := FWFormStruct(1, "VM7")
	Local oStrVM8 := FWFormStruct(1, "VM8")

	oModel := MPFormModel():New('OFIA330',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)


	oModel:AddFields('VM7MASTER',/*cOwner*/ , oStrVM7)
	oModel:SetPrimaryKey( { "VM7_FILIAL", "VM7_CODIGO" } )

	oModel:AddGrid("VM8DETAIL","VM7MASTER",oStrVM8)
	oModel:SetRelation( 'VM8DETAIL', { { 'VM8_FILIAL', 'xFilial( "VM8" )' }, { 'VM8_CODVM7', 'VM7_CODIGO' } }, VM8->( IndexKey( 2 ) ) )

	oModel:SetDescription(STR0001) // Conferência de Entrada por Volume
	oModel:GetModel('VM7MASTER'):SetDescription(STR0001) // Conferência de Entrada por Volume
	oModel:GetModel('VM8DETAIL'):SetDescription(STR0002) // Itens do Volume

	oModel:InstallEvent("OFIA330EVDEF", /*cOwner*/, OFIA330EVDEF():New("OFIA330"))

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVM7:= FWFormStruct(2, "VM7")
	Local oStrVM8:= FWFormStruct(2, "VM8", { |cCampo| !ALLTRIM(cCampo)+"|" $ cNCpoVM8 })

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVM7', 40)
	oView:AddField('VIEW_VM7', oStrVM7, 'VM7MASTER')
	oView:EnableTitleView('VIEW_VM7', STR0001) // Conferência de Entrada por Volume
	oView:SetOwnerView('VIEW_VM7','BOXVM7')

	oView:CreateHorizontalBox( 'BOXVM8', 60)
	oView:AddGrid("VIEW_VM8",oStrVM8, 'VM8DETAIL')
	oView:EnableTitleView('VIEW_VM8', STR0002) // Itens do Volume
	oView:SetOwnerView('VIEW_VM8','BOXVM8')

Return oView