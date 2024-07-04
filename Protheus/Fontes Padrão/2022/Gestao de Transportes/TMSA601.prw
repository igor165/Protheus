#INCLUDE "TMSA601.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/-----------------------------------------------------------
{Protheus.doc} TMSA601()
Índice de Pauta de Frete

Uso: SIGATMS

@sample
//TMSA601()

@author Felipe Barbiere.
@since 24/02/2021
@version 1.0
-----------------------------------------------------------/*/
Function TMSA601()
Local oBrowse		:= Nil
Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()   
oBrowse:SetAlias("DMC")			    			// Alias da tabela utilizada
oBrowse:SetMenuDef("TMSA601")					// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)   				//"Índice de Pauta de Frete"
	
oBrowse:Activate()
	
Return Nil

//---------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSA601" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSA601" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSA601" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSA601" OPERATION 5 ACCESS 0 // "Excluir"
	
Return aRotina

//---------------------------------------------------------

Static Function ModelDef()
Local oModel    := Nil
Local oStruDMC 	:= Nil 

oStruDMC := FwFormStruct(1,"DMC",,)

oModel := MPFormModel():New( "TMSA601",/*bPre*/,/*bPosValid*/,/*bCommit*/, /*bCancel*/ )

oModel:AddFields("DMC_MASTER",,oStruDMC ,/*bPreValid*/, /*bPosValid*/,/*Carga*/)
oModel:SetPrimaryKey({"DMC_INDICE", "DMC_DTAVLD"})

Return oModel   


//---------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel   := FwLoadModel("TMSA601")
Local oStruDMC := FwFormStruct(2,"DMC") 

oView := FwFormView():New()
oView:SetModel(oModel)  

oView:AddField('VIEW_DMC', oStruDMC , 'DMC_MASTER') 

oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_DMC','TELA')
                                                                     	
Return oView