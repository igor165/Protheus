#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA912.ch'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA912()
Cadastro de motivos das operadoras- TEF

@type Function

@author Ana Paula N. Silva
@since 07/10/2017
@version P12.1.19 

/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA912()
	Local oBrowse As Object

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()
Define o browse padrão para o cadastro de motivos

@type Function

@author Ana Paula N. Silva
@since 07/10/2017
@version P12.1.19 

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef() As Object
	Local oBrowse As Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'FVY' )
	oBrowse:SetDescription(STR0001) // "Cadastro de Motivos das Operadoras"
		
Return oBrowse

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Cria a estrutura a ser usada no Modelo de Dados

@type Function
@author Ana Paula N. Silva
@since 07/10/2017
@version P12.1.19 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oModel	As Object
	Local oStruFVY	As Object
	Local bWhen		As Codeblock
	Local bValid	As Codeblock

	oStruFVY := FWFormStruct( 1, 'FVY' )

	oModel := MPFormModel():New( 'FINA912',,{||VldChav()})

	oModel:SetDescription( STR0002 )
	oModel:AddFields( 'FVYMASTER', , oStruFVY )
	
	bWhen	:= FWBuildFeature( STRUCT_FEATURE_WHEN	, 'INCLUI') //Bloco de código para o when do campo FVY_CODMOT

	oStruFVY:SetProperty('FVY_CODMOT',MODEL_FIELD_WHEN,bWhen)


Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição de View do Sistema

@type Function

@author Ana Paula N. Silva
@since 07/10/2017
@version P12.1.19 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel	As Object
	Local oStruFVY	As Object
	Local oView		As Object

	oModel		:= FWLoadModel( 'FINA912' )
	oStruFVY	:= FWFormStruct( 2, 'FVY' )
	oView		:= FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'FVYMASTER', oStruFVY )

	oView:CreateVerticalBox( 'BOXMAIN', 100 )
	oView:SetOwnerView( 'FVYMASTER', 'BOXMAIN' )

Return oView

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição de Menu - MVC

@type Function

@author Ana Paula N. Silva
@since 07/10/2017
@version P12.1.19 

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {}


	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.FINA912' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FINA912' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.FINA912' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.FINA912' OPERATION 4 ACCESS 0 //'Alterar'
              

Return aRotina
	

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldChav()
validação do campo de cod. operadora, para não duplicar

@type Function

@author Ana Paula N. Silva
@since 17/10/2017
@version P12.1.19 

/*/
//-------------------------------------------------------------------------------------------------------------

Function VldChav() As Logical
	Local lRet As Logical
	Local cCodMot As Character
	Local cCodOpe As Character

	cCodMot:= FwfldGet('FVY_CODMOT')
	cCodOpe:= FwfldGet('FVY_CODOPE')

	lRet:= ExistChav("FVY",cCodOpe+cCodMot,1) //Alterado posição da chave

Return lret

