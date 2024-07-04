#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCBENE.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCB3M

Manutencao de beneficiarios no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSBENANS(lAuto)
    Local oBrowse	:= Nil

    Default lAuto   := .F.

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('B3W')
    oBrowse:SetDescription("Beneficiários ANS - CNX") 
    oBrowse:SetMenuDef( 'PLSMVCBENEANS' )
    oBrowse:SetProfileID( 'PLSMVCBENEANS' )
    oBrowse:ForceQuitButton()
    oBrowse:DisableDetails()
    oBrowse:SetWalkthru(.F.)
    oBrowse:SetAmbiente(.F.)

	If !lAuto
		oBrowse:Activate()		
	EndIf

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

Private aRotina	:= {}

aAdd( aRotina, { STR0002	, 'PesqBrw'				    , 0 , 1 , 0 , .T. } ) //Pesquisar
aAdd( aRotina, { STR0003	, 'VIEWDEF.PLSMVCBENEANS'	, 0 , 2 , 0 , NIL } ) //Visualizar
aAdd( aRotina, { STR0007	, 'VIEWDEF.PLSMVCBENEANS'	, 0 , 8 , 0 , NIL } ) //Imprimir
aAdd( aRotina, { "Import arq CNX"	, 'PLSSIBCNX("2")'	, 0 , 3 , 0 , NIL } ) //Imp. Beneficiarios
aAdd( aRotina, { "Validar ANS X Central(Todos)"	, 'PLSSIBESP()'	, 0 , MODEL_OPERATION_UPDATE , 0 , NIL } ) //Validar ANS X Central

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B3W

@return oModel	objeto model criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruB3W := FWFormStruct( 1, 'B3W', , )

oModel := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'B3WMASTER', NIL, oStruB3W )
oModel:GetModel( 'B3WMASTER' ):SetDescription( STR0001 ) 
oModel:SetDescription( STR0001 )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3W

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()  
Local oModel   := FWLoadModel( 'PLSMVCBENEANS' )
Local oStruB3W := FWFormStruct( 2, 'B3W' ) 
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_B3W' , oStruB3W, 'B3WMASTER' )     
oView:CreateHorizontalBox( 'GERAL', 100 )
oView:SetOwnerView( 'VIEW_B3W' , 'GERAL'  )


Return oView