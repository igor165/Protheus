#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "UBAA110.CH"

/*/{Protheus.doc} UBAA110
//-- Cadastro de Motivo de Parada

@author 	ana.olegini
@since 		10/07/2018
@version 	P12.1.23
/*/
Function UBAA110()
	Local oBrowse

	oBrowse	:= FWMBrowse():New()
	oBrowse:SetAlias("NBP")
	oBrowse:SetDescription(STR0001)	//"Cadastro de Motivo de Parada"
	oBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
@author 	ana.olegini
@since 		10/07/2018
@version 	P12.1.23
/*/
Static Function MenuDef()
	Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.UBAA110" OPERATION 2 ACCESS 0	//"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.UBAA110" OPERATION 3 ACCESS 0	//"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.UBAA110" OPERATION 4 ACCESS 0	//"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.UBAA110" OPERATION 5 ACCESS 0	//"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.UBAA110" OPERATION 8 ACCESS 0	//"Imprimir"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.UBAA110" OPERATION 9 ACCESS 0	//"Copiar"

Return aRotina

Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNBP	:= FWFormStruct(1,"NBP")

	oModel := MPFormModel():New("UBAA110")
	oModel:SetDescription(STR0001)	//"Cadastro de Motivo de Parada"

	oModel:AddFields("UBAA110_NBP", /*< cOwner >*/, oStruNBP, /*< bPre >*/, /*< bPost >*/, /*< bLoad >*/)
	oModel:GetModel("UBAA110_NBP"):SetDescription(STR0002)	//"Motivo de Parada"

Return oModel

Static Function ViewDef()
	Local oView		:= Nil
	Local oModel 	:= ModelDef()
	Local oStrZB2	:= FWFormStruct(2, "NBP")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("UBAA110_NBP" , oStrZB2,"UBAA110_NBP" ) 
	oView:CreateHorizontalBox( "BOX_UBAA110_NBP", 100)
	oView:SetOwnerView("UBAA110_NBP","BOX_UBAA110_NBP")

Return oView