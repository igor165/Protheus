#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA243.CH"

Function VEIA243()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VQC')
oBrowse:SetDescription(STR0001) // Configura��o
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('VEIA243')

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrVQC := FWFormStruct(1, "VQC")
Local oStrVQD := FWFormStruct(1, "VQD")

oModel := MPFormModel():New('VEIA243',;
/*Pr�-Validacao*/,;
/*P�s-Validacao*/,;
/*Confirmacao da Grava��o*/,;
/*Cancelamento da Opera��o*/)

oModel:AddFields('VQCMASTER',/*cOwner*/ 	, oStrVQC)
oModel:AddGrid('VQDDETAIL'	,'VQCMASTER'	, oStrVQD, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )

oModel:SetRelation( 'VQDDETAIL', { { 'VQD_FILIAL', 'xFilial( "VQD" )' }, { 'VQD_CODVQC', 'VQC_CODIGO' } }, VQD->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey( { "VQC_FILIAL", "VQC_CODIGO" } )
oModel:SetDescription(STR0002) // Pacote de Configura��o
oModel:GetModel('VQCMASTER'):SetDescription(STR0003) // Dados da Configura��o
oModel:GetModel('VQDDETAIL'):SetDescription(STR0004) // Itens da Configura��o

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVQC:= FWFormStruct(2, "VQC")
	Local oStrVQD:= FWFormStruct(2, "VQD")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVQC', 40)
	oView:AddField('VIEW_VQC', oStrVQC, 'VQCMASTER')
	oView:EnableTitleView('VIEW_VQC',STR0003) // Dados da Configura��o
	oView:SetOwnerView('VIEW_VQC','BOXVQC')

	oView:CreateHorizontalBox( 'BOXVQD', 60)
	oView:AddGrid('VIEW_VQD', oStrVQD, 'VQDDETAIL')
	oView:EnableTitleView('VIEW_VQD',STR0004) // Itens da Configura��o
	oView:SetOwnerView('VIEW_VQD','BOXVQD')

Return oView