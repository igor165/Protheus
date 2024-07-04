
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OFIA190.CH"

Function OFIA191()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VM2')
	oBrowse:SetDescription(STR0001) // Conferência Nota Fiscal de Entrada
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA191')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVM2 := FWFormStruct(1, "VM2")

	oModel := MPFormModel():New('OFIA191',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)


	oModel:AddFields('VM2MASTER',/*cOwner*/ , oStrVM2)
	oModel:SetPrimaryKey( { "VM2_FILIAL", "VM2_CODIGO", "VM2_TIPO", "VM2_STATUS" } )

	oModel:SetDescription(STR0001) // Conferência Nota Fiscal de Entrada
	oModel:GetModel('VM2MASTER'):SetDescription(STR0001) // Conferência Nota Fiscal de Entrada

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVM2:= FWFormStruct(2, "VM2")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVM2', 100)
	oView:AddField('VIEW_VM2', oStrVM2, 'VM2MASTER')
	oView:EnableTitleView('VIEW_VM2', STR0001 ) // Conferência Nota Fiscal de Entrada
	oView:SetOwnerView('VIEW_VM2','BOXVM2')

Return oView

/*/{Protheus.doc} OA1910011_ExcluirVM2

@author Andre Luis Almeida
@since 27/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA1910011_ExcluirVM2( cCodVM2 , cTipo , cStatus )
VM2->(DbSetOrder(1))
If VM2->(DbSeek( xFilial("VM2") + cCodVM2 + cTipo + cStatus ))
	VM2->(RecLock("VM2",.f.))
	VM2->(dbDelete())
	VM2->(MsUnlock())
EndIf
Return