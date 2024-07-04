#include "GCPA150.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//-------------------------------------------------------------------
/*{Protheus.doc} GCPA150
Cadastro de Orgao da Administracao Publica

@author Alex Egydio
@since 25/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCPA150()
Local oBrowse
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CPA")
oBrowse:SetDescription(STR0001)//"Orgão Público"
oBrowse:Activate()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} Menu
Cadastro de Orgao da Administracao Publica

@author Alex Egydio
@since 25/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.GCPA150' OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GCPA150' OPERATION 3 ACCESS 0//'Incluir'
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GCPA150' OPERATION 4 ACCESS 0//'Alterar'
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GCPA150' OPERATION 5 ACCESS 0//'Excluir'
ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GCPA150' OPERATION 8 ACCESS 0//'Imprimir'
ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.GCPA150' OPERATION 9 ACCESS 0//'Copiar'
Return aRotina
//-------------------------------------------------------------------
/*{Protheus.doc} Model
Cadastro de Orgao da Administracao Publica

@author Alex Egydio
@since 25/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCPA := FWFormStruct(1,'CPA')
Local oModel

// Verifica se o processo do Documento Hábil está sendo utilizado no módulo Financeiro - Documento Hábil - SIAFI
If GetNewPar( "MV_USADH", "2") == "2"
	oStruCPA:RemoveField("CPA_SISFIL")
EndIf

oModel := MPFormModel():New('GCPA150',/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields( 'CPAMASTER', /*cOwner*/, oStruCPA )
oModel:SetDescription( STR0008 )//'Orgão Público'
oModel:GetModel( 'CPAMASTER' ):SetDescription( STR0009 )//'Orgão Público'

Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} View
Cadastro de Orgao da Administracao Publica

@author Alex Egydio
@since 25/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel := FWLoadModel( 'GCPA150' )
Local oStruCPA := FWFormStruct( 2, 'CPA' )
Local oView

// Verifica se o processo do Documento Hábil está sendo utilizado no módulo Financeiro - SIAFI
If GetNewPar( "MV_USADH", "2") == "2"
	oStruCPA:RemoveField("CPA_SISFIL")
EndIf

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_CPA', oStruCPA, 'CPAMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_CPA', 'TELA' )
Return oView
