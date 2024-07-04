#include "GCPA321.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA321()
Controle de Saldos - SRP - Lote
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA321()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CPE")
oBrowse:SetDescription(STR0001)		//"Controle de Saldos - SRP - Lote"


Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Controle de Saldos - SRP - Lote
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
 Local oModel
 // Cria a estrutura a ser usada no Modelo de Dados
Local oStruCPI := FWFormStruct( 1,'CPI' )
Local oStruCO1 := FWFormStruct( 1,'CO1' )
Local oStruCO2 := FWFormStruct( 1,'CO2' )
Local oStruCO3 := FWFormStruct( 1,'CO3' )
Local oStruCPE := FWFormStruct( 1,'CPE' )
Local oStruCP3 := FWFormStruct( 1,'CP3' )

oModel := MPFormModel():New('GCPA321', /*bPreValidacao*/, /*bPosValidacao*/, {|oModel|GCP320Grv(oModel)} /*bCommit*/, /*bCancel*/ )
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CPIMASTER',/*cOwner*/, oStruCPI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddFields( 'CO1MASTER', 'CPIMASTER', oStruCO1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )


oModel:AddGrid( 'CP3DETAIL', 'CPIMASTER', oStruCP3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CO2DETAIL', 'CP3DETAIL', oStruCO2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CO3DETAIL', 'CP3DETAIL', oStruCO3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPEDETAIL', 'CP3DETAIL', oStruCPE, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )


oModel:SetRelation('CO1MASTER', { {'CO1_FILIAL','xFilial("CO1")'},{ 'CO1_CODEDT', 'CPI_CODEDT' }, { 'CO1_NUMPRO', 'CPI_NUMPRO' } }, CO1->(IndexKey(1)) )
oModel:SetRelation('CO2DETAIL', { {'CO2_FILIAL','xFilial("CO2")'},{ 'CO2_CODEDT', 'CPI_CODEDT' }, { 'CO2_NUMPRO', 'CPI_NUMPRO' } }, CO2->(IndexKey(3)) )
oModel:SetRelation('CPEDETAIL', { {'CPE_FILIAL','xFilial("CPE")'},{ 'CPE_CODORG', 'CPI_CODORG' }, { 'CPE_TIPO', 'CPI_TIPO' }, { 'CPE_CODEDT', 'CPI_CODEDT' }, { 'CPE_NUMPRO', 'CPI_NUMPRO' }, { 'CPE_LOTE', 'CO2_LOTE' }, { 'CPE_CODPRO', 'CO2_CODPRO' } }, CPE->(IndexKey(1)) )
oModel:SetRelation('CO3DETAIL' , { {'CO3_FILIAL','xFilial("CO3")'},{ 'CO3_CODEDT', 'CPI_CODEDT' }, { 'CO3_NUMPRO', 'CPI_NUMPRO' }, { 'CO3_CODPRO', 'CO2_CODPRO' } }, CO3->(IndexKey(3)) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )	//"Controle de Saldos - SRP - Lote"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CPIMASTER' ):SetDescription( STR0002 )	//'Orgao'
oModel:GetModel( 'CO2DETAIL' ):SetDescription( STR0003 )	//'Produtos'
oModel:GetModel( 'CP3DETAIL' ):SetDescription( STR0004 )	//'Lote'
oModel:GetModel( 'CPEDETAIL' ):SetDescription( STR0001 )	//"Controle de Saldos - SRP - Lote"

oModel:GetModel( 'CPIMASTER' ):SetOnlyView(.T.)
oModel:GetModel( 'CO1MASTER' ):SetOnlyView(.T.)
oModel:GetModel( 'CO2DETAIL' ):SetOnlyView(.T.)
oModel:GetModel( 'CP3DETAIL' ):SetOnlyView(.T.)
oModel:GetModel( 'CO3DETAIL' ):SetOnlyView(.T.)

oModel:GetModel( 'CPEDETAIL' ):SetUniqueLine( { 'CPE_TIPDOC' } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} View
Controle de Saldos - SRP - Lote
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel300 := FWModelActive()
Local cOrgGeren := oModel300:GetValue('CPHMASTER','CPH_CODORG')
Local oModel := ModelDef()

Local oStrCPI:= FWFormStruct(2, 'CPI' , {|cCampo|  AllTrim(cCampo) $ "CPI_CODORG, CPI_DESORG, CPI_TIPO"})
Local oStrCO2:= FWFormStruct(2, 'CO2' , {|cCampo| !AllTrim(cCampo) $ "CO2_CODEDT, CO2_NUMPRO, CO2_REMAN, CO2_VLESTI, CO2_OBS, CO2_REVISA, CO2_STATUS, CO2_QTSEGU, CO2_SEGUM, CO2_TPBEM"})
Local oStrCPE:= FWFormStruct(2, 'CPE' , {|cCampo| !AllTrim(cCampo) $ "CPE_CODORG, CPE_DESORG, CPE_TIPO, CPE_CODEDT, CPE_NUMPRO, CPE_NUMATA, CPE_LOTE, CPE_CODPRO"})
//
Local oStrCO3:= FWFormStruct(2, 'CO3')
Local oStrCO1:= FWFormStruct(2, 'CO1')
oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_CPI' , oStrCPI,'CPIMASTER' )
oView:AddGrid('VIEW_CO2' , oStrCO2,'CO2DETAIL')
oView:AddGrid('VIEW_CPE' , oStrCPE,'CPEDETAIL')

oView:CreateHorizontalBox( 'SUP', 20)
oView:CreateHorizontalBox( 'MEIO', 40)
oView:CreateHorizontalBox( 'INF', 40)

oView:SetOwnerView('VIEW_CPI','SUP')
oView:SetOwnerView('VIEW_CO2','MEIO') 
oView:SetOwnerView('VIEW_CPE','INF')

If cOrgGeren == CPI->CPI_CODORG
	oStrCPE:RemoveField("CPE_DOCMOV")
EndIf

Return oView
