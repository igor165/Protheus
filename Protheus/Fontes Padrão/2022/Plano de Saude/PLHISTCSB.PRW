#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#Include "PLHISTCSB.CH"

//-----------------------------------------------------------------------------
/*/{Protheus.doc} PLHISTCSB
@description Função principal que irá exibir o historico de transferência de
contrato e subcontrato de beneficiários

@author Thiago Guilherme
@since  15/08/2018
/*/
//-----------------------------------------------------------------------------
Function PLHISTCSB(cMatFami)

LOCAL   oBrowse 
DEFAULT cMatFami  := ""
PRIVATE aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.PLHISTCSB' OPERATION 2 ACCESS 0 //Visualizar 

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BQT' )
oBrowse:SetDescription( STR0002 ) //'Histórico de transferência de contrato/subcontrato' 
oBrowse:SetMenuDef("PLHISTCSB")
oBrowse:SetFilterDefault( "SUBSTR( BQT_MATRIC, 1, 14 ) == '" + cMatFami + "'" )
oBrowse:Activate()

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description Modelo de dados

@author Thiago Guilherme
@since  15/08/2018
/*/
//-----------------------------------------------------------------------------
Static Function ModelDef()

LOCAL oStruBQT := FWFormStruct( 1, 'BQT' )
LOCAL oModel 

oModel := MPFormModel():New( 'PLHISTCSB' )
oModel:AddFields( 'BQTMASTER',, oStruBQT )
oModel:SetDescription( STR0002 ) //'Histórico de transferência de contrato/subcontrato'
oModel:GetModel( STR0002 ) //'Histórico de transferência de contrato/subcontrato'

Return oModel

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description Responsável pela exibição da tela

@author Thiago Guilherme
@since  15/08/2018
/*/
//-----------------------------------------------------------------------------
Static Function ViewDef() 

LOCAL oModel   := FWLoadModel( 'PLHISTCSB' )
LOCAL oStruBQT := FWFormStruct( 2, 'BQT' )
LOCAL oView

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_BQT', oStruBQT, 'BQTMASTER' )

Return oView
