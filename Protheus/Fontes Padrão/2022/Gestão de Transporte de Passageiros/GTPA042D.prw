#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GTPA042A.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	jacomo.fernandes
@since		29/07/17
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := MPFormModel():New('GTPA042D', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
Local oStruGY5	:= FWFormStruct(1,'GY5')
Local xAux      := {}

xAux := FwStruTrigger( 'GY5_ENTIDA', 'GY5_DESCRI', 'GA042dTrig() ', .F. )
oStruGY5:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oStruGY5:SetProperty('GY5_ENTIDA',MODEL_FIELD_VALID,{|oModel,cField,xValue| Ga042VldEnt(oModel,cField,xValue) })
oStruGY5:SetProperty('GY5_ENTIDA',MODEL_FIELD_OBRIGAT,.T.)

oModel:AddFields('GY5MASTER',/*cOwner*/,oStruGY5)
oModel:SetDescription(STR0014)//'Entidade'
oModel:SetPrimaryKey({})

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	jacomo.fernandes
@since		29/07/17
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA042D')
Local oView		:= FWFormView():New()
Local oStruGY5	:= FWFormStruct(2, 'GY5')

oView:SetModel(oModel)

GTPXRmvFld(oStruGY5,'GY5_IDTREE')

oView:AddField('VIEW_GY5' ,oStruGY5,'GY5MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetDescription(STR0014)//'Entidade'
oView:SetOwnerView('VIEW_GY5','TELA')

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} trigger()
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function GA042dTrig()
Local cRet  := STR0014 +": "+GTPX2Name(FWFLDGET('GY5_ENTIDA'))
Return cRet


