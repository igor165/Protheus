#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA582.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA582()

Cadastro de limites de marcações 

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA582()

Local oBrowse

Private aRotina 	:= MenuDef() 
Private cCadastro	:= STR0001
 
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('TE3')
oBrowse:SetDescription(STR0001) //"Limites Marcações"
oBrowse:Activate()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Definição do MenuDef

@return ExpO:aRotina
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "TECA582" )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Definição do Model 

@return ExpO:oModel
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := NIL
Local oStruTE3	:= FWFormStruct(1,'TE3')

oModel := MPFormModel():New('TECA582',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields('TE3MASTER',/*cOwner*/,oStruTE3,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bField*/)

oModel:SetDescription(STR0001) //"Limites Marcações"

Return(oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

Definição da View 

@return ExpO:oView
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView     := NIL
Local oModel   	:= FWLoadModel('TECA582')
Local oStruTE3 	:= FWFormStruct(2,'TE3')

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_TE3', oStruTE3,'TE3MASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_TE3','TELA')

Return(oView)
