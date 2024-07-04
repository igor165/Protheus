#include "GCPA160.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author guilherme.pimentel

@since 03/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
 
Local oStrCO1:= FWFormStruct(1,'CO1')
Local oStrCP2:= FWFormStruct(1,'CP2')
Local oStrCOW:= FWFormStruct(1,'COW')

oModel := MPFormModel():New('GCPA160')
oModel:SetDescription(STR0001)//'Visualização de Checklist'
oModel:addFields('MASTERCO1',,oStrCO1)
oModel:addGrid('DETAILCP2','MASTERCO1',oStrCP2)
oModel:addGrid('DETAILCOW','DETAILCP2',oStrCOW)

oModel:SetRelation('DETAILCP2', { { 'CP2_FILIAL','xFilial("CP2")' }, { 'CP2_CODEDT', 'CO1_CODEDT' }, { 'CP2_NUMPRO', 'CO1_NUMPRO' } }, CP2->(IndexKey(1)) )
oModel:SetRelation('DETAILCOW', { { 'COW_FILIAL','xFilial("COW")' }, { 'COW_CODEDT', 'CP2_CODEDT' }, { 'COW_NUMPRO', 'CP2_NUMPRO' }, { 'COW_ETAPA', 'CP2_ETAPA' } }, COW->(IndexKey(1)) )

oModel:SetPrimaryKey({'CO1_FILIAL'},{'CO1_CODEDT'},{'CO1_NUMPRO'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author guilherme.pimentel

@since 03/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()

Local oStrCO1:= FWFormStruct(2, 'CO1' , {|cCampo|  AllTrim(cCampo) $ "CO1_CODEDT, CO1_NUMPRO"})
Local oStrCP2:= FWFormStruct(2, 'CP2' , {|cCampo| !AllTrim(cCampo) $ "CP2_CODEDT, CP2_NUMPRO"})
Local oStrCOW:= FWFormStruct(2, 'COW' , {|cCampo| !AllTrim(cCampo) $ "COW_CODEDT, COW_NUMPRO"})
oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_CO1' , oStrCO1,'MASTERCO1' )

oView:AddGrid('VIEW_CP2' , oStrCP2,'DETAILCP2')
oView:AddGrid('VIEW_COW' , oStrCOW,'DETAILCOW')    

oView:CreateHorizontalBox( 'SUP', 20)
oView:CreateHorizontalBox( 'MEIO', 40)
oView:CreateHorizontalBox( 'INF', 40)

oView:SetOwnerView('VIEW_CO1','SUP')
oView:SetOwnerView('VIEW_CP2','MEIO')
oView:SetOwnerView('VIEW_COW','INF')

Return oView
