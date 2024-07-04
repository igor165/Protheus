#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FWBrowse.ch'
#Include 'FINA761.ch'

Static __oModelFVQ
Static __cFilModel
Static __cCodModel

//----------------------------------------------------------------------
/*/{Protheus.doc} FINA761OBR
Rotina de Ordens Bancárias

@author Pedro Pereira Lima
@since 25/05/2017
@version P12.1.17 

/*/
//----------------------------------------------------------------------
Function FINA761OBR( oView )

Local oModelThis	:= oView:GetModel()
Local oAuxFV0		:= oModelThis:GetModel('CABDI') 
Local oModelAux		:= oModelThis:GetModel('DETFVQ')
Local cFilModel		:= oAuxFV0:GetValue( 'FV0_FILIAL' )
Local cCodModel		:= oAuxFV0:GetValue( 'FV0_CODIGO' )

__oModelFVQ := oModelAux
__cFilModel := cFilModel
__cCodModel := cCodModel

FWExecView( STR0276 + ' - ' + oAuxFV0:GetValue('FV0_CODIGO'), 'FINA761OBR', MODEL_OPERATION_VIEW, /*oDlg*/, { || .T. }, /**/, 30, /**/, /**/ )

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author Pedro Pereira Lima
@since 25/05/2017
@version P12.1.17 

/*/
//----------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= MPFormModel():New('FINA761OBR',/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)
Local oStruFV0		:= FWFormStruct(1,'FV0')
Local oStruFVQ		:= FWFormStruct(1,'FVQ')

oModel:Addfields( 'FV0CAB', /*cOwner*/,oStruFV0, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:AddGrid( 'GRDFVQ', 'FV0CAB', oStruFVQ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, { |oModel,lCopy| LoadGrid( oModel, lCopy ) } )
oModel:SetRelation('GRDFVQ', {{'FVQ_FILIAL','xFilial("FVQ")'}, {'FVQ_CODPRO', 'FV0_CODIGO'}}, FVQ->(IndexKey(1)))

Return oModel

//----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados

@author Pedro Pereira Lima
@since 25/05/2017
@version P12.1.17 

/*/
//----------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel('FINA761OBR')
Local oView		:= FWFormView():New()
Local oStruFVQ	:= FWFormStruct(2,'FVQ')

oView:SetModel( oModel )
oView:AddGrid( 'FVQGRID', oStruFVQ, 'GRDFVQ' )
oView:CreateHorizontalBox( 'BOXVIEW', 100 )
oView:SetOwnerView( 'FVQGRID', 'BOXVIEW' )

oStruFVQ:RemoveField('FVQ_CODPRO')

Return oView

//----------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid
Carga dos dados da tabela FVQ, de acordo com o modelo de dados

@author Pedro Pereira Lima
@since 25/05/2017
@version P12.1.17 

/*/
//----------------------------------------------------------------------
Static Function LoadGrid( oModel, lCopy )

Local aLoadData		:= {}
Local nTamFVQ		:= __oModelFVQ:Length()
Local nX			:= 0

If nTamFVQ > 0
	For nX := 1 To nTamFVQ
		__oModelFVQ:GoLine(nX)
		If	!__oModelFVQ:IsDeleted() .And. __oModelFVQ:GetValue('FVQ_FILIAL') == __cFilModel .And. __oModelFVQ:GetValue('FVQ_CODPRO') == __cCodModel
			aAdd( aLoadData, { nX, { __oModelFVQ:GetValue('FVQ_FILIAL'), __oModelFVQ:GetValue('FVQ_CODPRO'), __oModelFVQ:GetValue('FVQ_CODOBR'),;
								__oModelFVQ:GetValue('FVQ_UGEMIT'), __oModelFVQ:GetValue('FVQ_VLRDOC'), __oModelFVQ:GetValue('FVQ_DTEMIS') } } )
		EndIf
	Next nX
Else
	aLoadData := { {0,'','','','','',''} }
EndIf

Return aLoadData
