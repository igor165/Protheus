#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCABR

Manutencao de abrangencias no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCABR(lAuto)

    Local oBrowse := Nil
    Default lAuto := .F.
    
    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('B4X')
    oBrowse:SetDescription("Abrangências") //Produtos 
    oBrowse:SetMenuDef( 'PLSMVCABR' )
    If !lAuto
        oBrowse:Activate()    
    EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016    
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Private aRotina	:= {}

aAdd( aRotina, { "Pesquisar"	, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
aAdd( aRotina, { "Visualizar"	, 'VIEWDEF.PLSMVCABR'	, 0 , 2 , 0 , NIL } ) //Visualizar
aAdd( aRotina, { "Excluir"	, 'VIEWDEF.PLSMVCABR'	, 0 , 5 , 0 , NIL } ) //Excluir
aAdd( aRotina, { "Imprimir"	, 'VIEWDEF.PLSMVCABR'	, 0 , 8 , 0 , NIL } ) //Imprimir

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruB4X := FWFormStruct( 1, 'B4X', , )

oModel := MPFormModel():New( "Abrangências", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'B4XMASTER', NIL, oStruB4X )
oModel:GetModel( 'B4XMASTER' ):SetDescription( "Abrangências" ) 
oModel:SetDescription( "Abrangências" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B4X

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()  
Local oModel   := FWLoadModel( 'PLSMVCABR' )
Local oStruB4X := FWFormStruct( 2, 'B4X' ) 
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_B4X' , oStruB4X, 'B4XMASTER' )     
oView:CreateHorizontalBox( 'GERAL', 100 )
oView:SetOwnerView( 'VIEW_B4X' , 'GERAL'  )

Return oView