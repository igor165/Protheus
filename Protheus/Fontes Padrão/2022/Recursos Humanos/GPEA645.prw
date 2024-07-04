#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'GPEA645.ch'

Function GPEA645()

Local oBrw := FwMBrowse():New()

oBrw:SetAlias( 'TIQ' )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) // "Cadastro de Disciplinas"

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

Local aMenu := FWMVCMenu("GPEA645")

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
Local oStr1:= FWFormStruct(1,'TIQ')
Local oStr2:= FWFormStruct(1,'TIR')

oModel := MPFormModel():New("GPEA645")
oModel:SetDescription(STR0001)
oModel:addFields('TIQ',,oStr1)
oModel:SetPrimaryKey({ 'TIQ_FILIAL', 'TIQ_CODIGO' })

oStr2:RemoveField( 'TIR_CODTIQ' )

oStr2:SetProperty( 'TIR_DESCRI' , MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'IF( INCLUI, "", POSICIONE("TIQ", 1, XFILIAL("TIQ")+TIR->TIR_SUGEST, "TIQ_DESCR") )                                              '))
oModel:addGrid('TIR','TIQ',oStr2)

oModel:SetRelation('TIR', { { 'TIR_CODTIQ', 'TIQ_CODIGO' }, { 'TIR_FILIAL', 'xFILIAL("TIR")' } }, TIR->(IndexKey(1)) )
oModel:getModel('TIQ'):SetDescription(STR0001)//"Cadastro de Disciplinas"
oModel:getModel('TIR'):SetDescription(STR0002)//"Complemento de Disciplina"
oModel:GetModel( 'TIR' ):SetOptional( .T. )

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
Local oStr1:= FWFormStruct(2, 'TIQ')
Local oStr2:= FWFormStruct(2, 'TIR')

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('FORM1' , oStr1,'TIQ' )
oView:AddGrid('FORM3' , oStr2,'TIR')  
oView:CreateHorizontalBox( 'BOXFORM1', 49)
oStr2:RemoveField( 'TIR_CODTIQ' )
If nModulo == 7
	oStr2:RemoveField( 'TIR_PPERDA' )
EndIf
oView:CreateHorizontalBox( 'BOXFORM3', 51)
oView:SetOwnerView('FORM3','BOXFORM3')
oView:SetOwnerView('FORM1','BOXFORM1')
oView:AddIncrementField('FORM3' , 'TIR_CODIGO' ) 

Return oView