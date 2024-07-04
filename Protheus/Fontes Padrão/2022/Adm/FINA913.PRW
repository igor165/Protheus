#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA913.ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA913()
Cadastro de Filiais a Considerar - TEF

@type Function

@author Pedro Pereira Lima
@since 09/10/2017
@version P12.1.19 

/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA913()
Local oBrowse As Object

oBrowse := BrowseDef()
oBrowse:Activate()

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()
Define o browse padrão para o cadastro de filiais a considerar

@type Function

@author Pedro Pereira Lima
@since 09/10/2017
@version P12.1.19

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef() As Object
Local oBrowse As Object

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'FVZ' )
oBrowse:SetDescription( STR0001 ) //"Cadastro de Filiais a Considerar TEF
		
Return oBrowse

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Cria a estrutura a ser usada no Modelo de Dados

@type Function

@author Pedro Pereira Lima
@since	09/10/2017
@version P12.1.19
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object
Local oModel	As Object
Local oStruFVZ	As Object
Local bWhen		As Codeblock
Local bValid	As Codeblock

oStruFVZ := FWFormStruct( 1, 'FVZ' )

bValid	:= FWBuildFeature( STRUCT_FEATURE_VALID	, 'ExistChav( "FVZ" )'	) //Bloco de código para o valid do campo FVZ_CODIGO

oStruFVZ:SetProperty( 'FVZ_FILCON', MODEL_FIELD_VALID, bValid )

oModel := MPFormModel():New( 'FINA913' )

oModel:SetDescription( STR0005 )
oModel:AddFields( 'FVZMASTER', , oStruFVZ )

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
Local oStruFVZ	As Object
Local oView		As Object

oModel		:= FWLoadModel( 'FINA913' )
oStruFVZ	:= FWFormStruct( 2, 'FVZ' )
oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'FVZMASTER', oStruFVZ )

oView:CreateVerticalBox( 'BOXMAIN', 100 )
oView:SetOwnerView( 'FVZMASTER', 'BOXMAIN' )

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

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.FINA913' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.FINA913' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FINA913' OPERATION 5 ACCESS 0 //'Excluir'                 

Return aRotina