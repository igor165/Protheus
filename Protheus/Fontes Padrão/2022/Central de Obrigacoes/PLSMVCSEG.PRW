#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCSEG

Manutencao de segmentações no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCSEG(lAuto)
    Local oBrowse := Nil
    Default lAuto := .F.

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('B4Y')
    oBrowse:SetDescription("Segmentações") 
    oBrowse:SetMenuDef( 'PLSMVCSEG' )
    if !lAuto
        oBrowse:activate()
    endif
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
    aAdd( aRotina, { "Visualizar"	, 'VIEWDEF.PLSMVCSEG'	, 0 , 2 , 0 , NIL } ) //Visualizar
    aAdd( aRotina, { "Excluir"	, 'VIEWDEF.PLSMVCSEG'	, 0 , 5 , 0 , NIL } ) //Excluir
    aAdd( aRotina, { "Imprimir"	, 'VIEWDEF.PLSMVCSEG'	, 0 , 8 , 0 , NIL } ) //Imprimir
Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oStruB4Y := FWFormStruct( 1, 'B4Y', , )
    oModel := MPFormModel():New( "Segmentações", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 
    oModel:AddFields( 'B4YMASTER', NIL, oStruB4Y )
    oModel:GetModel( 'B4YMASTER' ):SetDescription( "Segmentações" ) 
    oModel:SetDescription( "Segmentações" )
Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B4Y

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()  
    Local oModel   := FWLoadModel( 'PLSMVCSEG' )
    Local oStruB4Y := FWFormStruct( 2, 'B4Y' ) 
    Local oView    := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( 'VIEW_B4Y' , oStruB4Y, 'B4YMASTER' )     
    oView:CreateHorizontalBox( 'GERAL', 100 )
    oView:SetOwnerView( 'VIEW_B4Y' , 'GERAL'  )
Return oView