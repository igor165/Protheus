#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GTPA042B.CH"

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

Local oModel	:= FwLoadModel('GTPA042B')
Local oView		:= FWFormView():New()
Local oStruGY6	:= FWFormStruct(2, 'GY6')
Local aOperad   := NIL

oView:SetModel(oModel)

GTPXRmvFld(oStruGY6,'GY6_SEQ')
GTPXRmvFld(oStruGY6,'GY6_ENTID1')
GTPXRmvFld(oStruGY6,'GY6_ENTID2')
GTPXRmvFld(oStruGY6,'GY6_NOMEN2')
GTPXRmvFld(oStruGY6,'GY6_CAMPO2')
GTPXRmvFld(oStruGY6,'GY6_TITCP2')
GTPXRmvFld(oStruGY6,'GY6_DESCRI')
GTPXRmvFld(oStruGY6,'GY6_CONDIC')

oView:AddField('VIEW_GY6' ,oStruGY6,'GY6MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetDescription(STR0001)//'Filtros'

oView:SetOwnerView('VIEW_GY6','TELA')

Return ( oView )
