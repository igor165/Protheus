#include "TECA011.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function TECA011()

Local oMBrowse

oMBrowse:= FWmBrowse():New() 
oMBrowse:SetAlias("TCZ")
oMBrowse:SetDescription(STR0001) //"Cadastro de Características"  
oMBrowse:Activate()
	
Return

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Relacionamentos - Cadastro de Caracterisiticas 

@Return 	model
@author 	Serviços
@since 		15/07/2015
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStrTCZ 	:= FWFormStruct(1,"TCZ")

oModel := MPFormModel():New("TECA011", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
oModel:AddFields("TCZMASTER",/*cOwner*/,oStrTCZ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0002) //"Cadastro de Caracteristicas" 
oModel:SetPrimaryKey({"TCZ_FILIAL","TCZ_COD"})
Return(oModel)
//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Cadastro de Caracteristicas 

@Return 	view
@author 	Serviços
@since 		15/07/2015
/*/
//----------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel  := FWLoadModel("TECA011")  
Local oStrTCZ := FWFormStruct( 2, "TCZ")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( 'VIEW_TCZ' , oStrTCZ, 'TCZMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_TCZ', 'TELA' )

//Fechar a janela apos a gravação
oView:SetCloseOnOk({|| .T.} )

Return oView

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Caracteristicas  

@Return 	MenuDef
@author 	Serviços
@since 		15/07/2015
/*/
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aRotina := FWMVCMenu( 'TECA011' )

Return(aRotina)