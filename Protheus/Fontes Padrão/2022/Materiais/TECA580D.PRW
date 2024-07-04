#include "TECA580D.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------
/*/{Protheus.doc} TECA580D()
Relacionamentos - Gestão de Escalas 

@Return 	nil
@author 	Serviços
@since 		15/05/2014
/*/
//----------------------------------------------------------
Function TECA580D() 
Local oBrowse 

oBrowse := FwMBrowse():New()
oBrowse:SetAlias("TFF")
oBrowse:SetDescription(STR0001) // STR0001//"Relacionamento"
oBrowse:DisableDetails()
oBrowse:Activate()

Return(Nil) 

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Relacionamentos - Gestão de Escalas 

@Return 	MenuDef
@author 	Serviços
@since 		14/05/2014
/*/
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aRotina := FWMVCMenu( 'TECA580D' )

Return(aRotina)

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Relacionamentos - Gestão de Escalas 

@Return 	model
@author 	Serviços
@since 		14/05/2014
/*/
//----------------------------------------------------------
Static Function ModelDef()
Local oModel		:= Nil
Local oStrTFF 	:= FWFormStruct(1,"TFF") 
Local bCommit		:= {|oModel|Tec580GrvD(oModel)}

oModel := MPFormModel():New("TECA580D", /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/ )

oStrTFF:SetProperty('TFF_PRODUT',MODEL_FIELD_WHEN ,{||.F.})  
oStrTFF:SetProperty('TFF_CALEND',MODEL_FIELD_WHEN ,{||At680Perm( Nil, __cUserID, "014" )})
oStrTFF:SetProperty("TFF_DESCRI",MODEL_FIELD_INIT,{||Posicione("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC")})
oStrTFF:SetProperty("TFF_DSCALE",MODEL_FIELD_INIT,{||Posicione("AC0",1,xFilial("AC0")+TFF->TFF_CALEND,"AC0_DESC")})
oStrTFF:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oModel:AddFields("TFFMASTER",/*cOwner*/,oStrTFF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetDescription(STR0002) // STR0002 									  //"Relacionamento"

Return(oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Relacionamentos - Gestão de Escalas 

@Return 	view
@author 	Serviços
@since 		15/05/2014
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   	:= FWLoadModel("TECA580D")  
Local oStrTFF	:= FwFormStruct(2,"TFF", {|cCpo| AllTrim(cCpo)$'TFF_COD+TFF_CONTRT+TFF_PRODUT+TFF_DESCRI+TFF_LOCAL+TFF_CALEND+TFF_DSCALE' } )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TFF",oStrTFF,"TFFMASTER")

oView:CreateHorizontalBox( "TELA" , 100 )
oView:SetOwnerView( "VIEW_TFF", "TELA" ) 

//Fechar a janela apos a gravação
oView:SetCloseOnOk({|| .T.} )

Return(oView)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tec580GrvD

Gravação do Model

@author 	Serviços
@since 		08/04/2014
@version 	P12

/*/
//--------------------------------------------------------------------------------------------------------------------
Function Tec580GrvD(oModel)
Local nOpcx		:= oModel:GetOperation()
Local lRet			:= .T.

If nOpcx == MODEL_OPERATION_UPDATE .And. IsInCallStack('Tx580PxC') 
	lRet := FwFormCommit( oModel )
	
	If lRet
		Aviso( STR0003, STR0004, { STR0005 }, 2 )//"Atenção"//"Calendario Atualizado com sucesso!"//"OK"
	EndIf
	
EndIf

Return(lRet)