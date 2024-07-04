#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "GCPA200.CH"

#DEFINE CRLF Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@author guilherme.pimentel

@since 06/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'GCPA200' )
// Cria a estrutura a ser usada na View
Local oStruCO1 := FWFormStruct( 2, 'CO1', {|cCampo| !AllTrim(cCampo) $ "CO1_REVISA, CO1_REMAN, CO1_STATUS"} )
Local oStruCO2 := FWFormStruct( 2, 'CO2', {|cCampo| !AllTrim(cCampo) $ "CO2_CODEDT, CO2_NUMPRO, CO2_REVISA, CO2_LOTE, CO2_STATUS, CO2_SALDO"} )
Local oStruCO9 := FWFormStruct( 2, 'CO9', {|cCampo| !AllTrim(cCampo) $ "CO9_CODEDT, CO9_NUMPRO"} )
Local oStruCOW := FWFormStruct( 2, 'COW', {|cCampo| !AllTrim(cCampo) $ "COW_CODEDT, COW_NUMPRO, COW_REVISA"} )
Local oView

oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_CO1', oStruCO1,'CO1MASTER')
oView:AddGrid('VIEW_CO2' , oStruCO2,'CO2DETAIL') 
oView:AddGrid('VIEW_CO9' , oStruCO9,'CO9DETAIL')
oView:AddGrid('VIEW_COW' , oStruCOW,'COWDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
// Box Principais
oView:CreateHorizontalBox( 'CO1'  , 50 )
oView:CreateHorizontalBox( 'MEIO' , 50)

//Box auxiliares
//FLD MEIO
oView:CreateFolder( 'FLDMEIO', 'MEIO')

oView:AddSheet('FLDMEIO','FLDPRODUTO'	,STR0030)//'Produtos'
oView:AddSheet('FLDMEIO','FLDCHECKLIST',STR0033)//'Checklist'
oView:AddSheet('FLDMEIO','FLDCOMISS'	,STR0025)//'Comissão Licitação'

oView:CreateHorizontalBox( 'COW', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDCHECKLIST')

//Box dos modelos
oView:CreateHorizontalBox( 'CO9', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDCOMISS')
oView:CreateHorizontalBox( 'CO2', 100, /*owner*/, /*lUsePixel*/, 'FLDMEIO', 'FLDPRODUTO')

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_CO1','CO1')
oView:SetOwnerView('VIEW_CO2','CO2')
oView:SetOwnerView('VIEW_CO9','CO9')
oView:SetOwnerView('VIEW_COW','COW')   

// Campos incrementais
oView:AddIncrementField('VIEW_CO2' , 'CO2_ITEM' )
oView:AddIncrementField('VIEW_CO9' , 'CO9_ITEM' )

// Títulos
oView:EnableTitleView('VIEW_CO2' , STR0030 )//'Produtos'
oView:EnableTitleView('VIEW_CO9' , STR0032 )//'Comissão de Licitação'
oView:EnableTitleView('VIEW_COW' , STR0033 )//'CheckList'

//Bloqueia atualuaziar campos do checklist
oStruCOW:SetProperty('*', 	MVC_VIEW_CANCHANGE  ,.F.) //Desabilita os campos						
oStruCOW:SetProperty('COW_CHKOK', 	MVC_VIEW_CANCHANGE  ,.T.)

Return oView


