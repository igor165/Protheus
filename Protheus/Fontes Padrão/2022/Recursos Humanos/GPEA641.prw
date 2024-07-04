#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'GPEA641.ch'

Function GPEA641()

Local oBrw := FwMBrowse():New()

oBrw:SetAlias( 'TIS' )
oBrw:SetMenudef( "GPEA641" )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) // "Cadastro dos Tipo de Disciplina"

oBrw:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Rotina para construção do menu
@sample 	Menudef() 
@since		06/09/2013  
@version 	P11.90
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := FWMVCMenu("GPEA641")

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author arthur.colado

@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel 
Local oStr1:= FWFormStruct(1,'TIS')

oModel := MPFormModel():New('GPEA641')
oModel:SetDescription(STR0001)
oModel:addFields('TIS',,oStr1)
oModel:SetPrimaryKey({ 'TIS_FILIAL', 'TIS_CODIGO' })
oModel:getModel('TIS'):SetDescription(STR0002)	//Tipo de Disciplina

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author arthur.colado

@since 04/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef() 
Local oStr1:= FWFormStruct(2, 'TIS') 
Local oStr2:= FWFormStruct(2, 'TIS')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM1' , oStr2,'TIS' ) 
oView:CreateHorizontalBox( 'BOXFORM1', 100)
oView:SetOwnerView('FORM1','BOXFORM1')

Return oView