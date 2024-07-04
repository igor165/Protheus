#include "GCPA170.CH"
#include "GCPA170.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Taniel Balsanelli
@since 04/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel  
Local oStrCO1:= FWFormStruct(1,'CO1')
Local oStrCO7:= FWFormStruct(1,'CO7')

oModel := MPFormModel():New('GCPA170')
oModel:SetDescription(STR0001)//Histórico do Edital
oModel:addFields('CO1MASTER',,oStrCO1)
oModel:addGrid('CO7DETAIL','CO1MASTER',oStrCO7)

oModel:SetRelation('CO7DETAIL', { { 'CO7_FILIAL','xFilial("CO7")' }, { 'CO7_CODEDT', 'CO1_CODEDT' }, { 'CO7_NUMPRO', 'CO1_NUMPRO' } }, CO7->(IndexKey(1)) )

oModel:SetPrimaryKey({'CO1_FILIAL'},{'CO1_CODEDT'},{'CO1_NUMPRO'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Taniel Balsanelli
@since 04/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()

Local oStrCO1:= FWFormStruct(2, 'CO1' , {|cCampo|  AllTrim(cCampo) $ "CO1_CODEDT, CO1_NUMPRO"})
Local oStrCO7:= FWFormStruct(2, 'CO7' , {|cCampo| !AllTrim(cCampo) $ "CO7_CODEDT, CO7_NUMPRO"})

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_CO1' , oStrCO1,'CO1MASTER' )

oView:AddGrid('VIEW_CO7' , oStrCO7,'CO7DETAIL')
 
oView:CreateHorizontalBox( 'SUP', 20)
oView:CreateHorizontalBox( 'MEIO', 80)

oView:SetOwnerView('VIEW_CO1','SUP')
oView:SetOwnerView('VIEW_CO7','MEIO')

Return oView
