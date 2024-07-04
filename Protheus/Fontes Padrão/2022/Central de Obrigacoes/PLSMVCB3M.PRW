#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCB3M.CH'
#include 'COLORS.CH'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCB3M

Manutencao de SIP XML no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCB3M(lAuto,cFiltro)

    Local oBrowse := Nil
    Default lAuto := .F.
    Default cFiltro := ""

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('B3M')
    oBrowse:SetDescription("Detalhe XML SIP")
    oBrowse:setmenudef("PLSMVCB3M")
    If !Empty(cFiltro)
		oBrowse:SetFilterDefault(cFiltro)
	EndIf
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

    local aRotina	:= {}

    aAdd( aRotina, { STR0002, 'PesqBrw'				   , 0 , 1 , 0 , .T. } ) //Pesquisar
    aAdd( aRotina, { "Guias", 'staticcall(PLSMVCB3M, resSipGD)' , 0 , 2 , 0 , Nil } ) //Guias
    aAdd( aRotina, { STR0003, 'VIEWDEF.PLSMVCB3M(.F.)' , 0 , 2 , 0 , Nil } ) //Visualizar
    aAdd( aRotina, { STR0007, 'VIEWDEF.PLSMVCB3M(.F.)' , 0 , 8 , 0 , Nil } ) //Imprimir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B3M

@return oModel	objeto model criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

    Local oStruB3M := FWFormStruct( 1, 'B3M', , )

    oModel := MPFormModel():New( "Detalhe XML SIP" ) 
    oModel:AddFields( 'B3MMASTER', Nil, oStruB3M )
    oModel:GetModel( 'B3MMASTER' ):SetDescription( "Detalhe XML SIP" ) 
    oModel:SetDescription( "Detalhe XML SIP" )

Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3M

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

    Local oModel   := FWLoadModel( 'PLSMVCB3M' )
    Local oStruB3M := FWFormStruct( 2, 'B3M' ) 
    Local oView    := FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_B3M' , oStruB3M, 'B3MMASTER' )     
    oView:CreateHorizontalBox( 'GERAL', 100 )
    oView:SetOwnerView( 'VIEW_B3M' , 'GERAL'  )

Return oView


/*/{Protheus.doc} resSipGD
Chama a tela de guias referentes ao registro posicionado na tela de detalhes.

@author Gabriel H. Klok

@type static function
@since 18/06/2020
@version 1.0
/*/
static function resSipGD()
    local cWhere := "% B3L_UF = '" + B3M->B3M_UF + "' AND B3L_FORCON = '" + B3M->B3M_FORCON + "' AND B3L_SEGMEN = '" + B3M->B3M_SEGMEN + "' %"

    cenResSipG(.f., B3M->B3M_ITEM, cWhere)
return 
