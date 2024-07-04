#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA911.ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA911()
Cadastro de justificativas - TEF

@type Function

@author Pedro Pereira Lima
@since 04/10/2017
@version P12.1.19 

/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA911()
Local oBrowse As Object

oBrowse := BrowseDef()
oBrowse:Activate()

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()
Define o browse padrão para o cadastro de justificativas

@type Function

@author Pedro Pereira Lima
@since 04/10/2017
@version P12.1.19

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef() As Object
Local oBrowse As Object

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'FVX' )
oBrowse:SetDescription( STR0001 ) //"Cadastro de Justificativas TEF"
		
Return oBrowse

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Cria a estrutura a ser usada no Modelo de Dados

@type Function

@author Pedro Pereira Lima
@since	04/10/2017
@version P12.1.19
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object
Local oModel	As Object
Local oStruFVX	As Object
Local bWhen		As Codeblock
Local bValid	As Codeblock

oStruFVX := FWFormStruct( 1, 'FVX' )

bWhen	:= FWBuildFeature( STRUCT_FEATURE_WHEN	, 'INCLUI' 				) //Bloco de código para o when do campo FVX_CODIGO 
bValid	:= FWBuildFeature( STRUCT_FEATURE_VALID	, 'ExistChav( "FVX" )'	) //Bloco de código para o valid do campo FVX_CODIGO

oStruFVX:SetProperty( 'FVX_CODIGO', MODEL_FIELD_WHEN, bWhen )
oStruFVX:SetProperty( 'FVX_CODIGO', MODEL_FIELD_VALID, bValid )

oModel := MPFormModel():New( 'FINA911' )

oModel:SetDescription( STR0006 )
oModel:AddFields( 'FVXMASTER', , oStruFVX )

Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição de View do Sistema

@type Function

@author Pedro Pereira Lima
@since 04/10/2017
@version P12.1.19
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef() As Object
Local oModel	As Object
Local oStruFVX	As Object
Local oView		As Object

oModel		:= FWLoadModel( 'FINA911' )
oStruFVX	:= FWFormStruct( 2, 'FVX' )
oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'FVXMASTER', oStruFVX )

oView:CreateVerticalBox( 'BOXMAIN', 100 )
oView:SetOwnerView( 'FVXMASTER', 'BOXMAIN' )

Return oView

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição de Menu - MVC

@type Function

@author Pedro Pereira Lima
@since 04/10/2017
@version 12.1.19

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef() As Array
Local aRotina As Array

aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.FINA911' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.FINA911' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FINA911' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.FINA911' OPERATION 5 ACCESS 0 //'Excluir'                 

Return aRotina