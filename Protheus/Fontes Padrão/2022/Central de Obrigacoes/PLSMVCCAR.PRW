#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCCAR.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCCAR

Manutencao de carencias no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCCAR(lAuto)
    Local oBrowse := Nil
    Default lAuto := .F.

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('B3O')
    oBrowse:SetDescription(STR0001) //Carencias
    oBrowse:SetFilterDefault( "B3O_FILIAL=B3D->B3D_FILIAL .And. B3O_CODOPE=B3D->B3D_CODOPE .And. B3O_CDOBRI=B3D->B3D_CDOBRI .And. B3O_ANO=B3D->B3D_ANO .And. B3O_CDCOMP=B3D->B3D_CODIGO" )

    if lHabMetric .and. lLibSupFw .and. lVrsAppSw
        FWMetrics():addMetrics("Beneficiários Expostos", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
    endif

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

    aAdd( aRotina, { STR0002	, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
    aAdd( aRotina, { STR0003	, 'VIEWDEF.PLSMVCCAR'	, 0 , 2 , 0 , NIL } ) //Visualizar
    aAdd( aRotina, { STR0007	, 'VIEWDEF.PLSMVCCAR'	, 0 , 8 , 0 , NIL } ) //Imprimir
Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B3O

@return oModel	objeto model criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oStruB3O := FWFormStruct( 1, 'B3O', , )

    oModel := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields( 'B3OMASTER', NIL, oStruB3O )
    oModel:GetModel( 'B3OMASTER' ):SetDescription( STR0001 )
    oModel:SetDescription( STR0001 )
Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3O

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   := FWLoadModel( 'PLSMVCCAR' )
    Local oStruB3O := FWFormStruct( 2, 'B3O' )
    Local oView    := FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_B3O' , oStruB3O, 'B3OMASTER' )
    oView:CreateHorizontalBox( 'GERAL', 100 )
    oView:SetOwnerView( 'VIEW_B3O' , 'GERAL'  )
Return oView