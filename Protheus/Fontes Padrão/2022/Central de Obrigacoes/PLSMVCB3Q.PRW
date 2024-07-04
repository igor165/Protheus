#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCDESP.CH'
#include 'COLORS.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCB3Q

Manutencao de Eventos X Despesas no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCB3Q(lAuto)
Local oBrowse	:= Nil
Default lAuto := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias('B3Q')
oBrowse:SetDescription(STR0001) //Eventos X Despesas 
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
aAdd( aRotina, { STR0003	, 'VIEWDEF.PLSMVCB3Q(.F.)'	, 0 , 2 , 0 , Nil } ) //Visualizar
//aAdd( aRotina, { STR0004	, 'VIEWDEF.PLSMVCB3Q(.F.)'	, 0 , 3 , 0 , Nil } ) //Incluir
//aAdd( aRotina, { STR0005	, 'VIEWDEF.PLSMVCB3Q(.F.)'	, 0 , 4 , 0 , Nil } ) //Alterar
aAdd( aRotina, { STR0006	, 'VIEWDEF.PLSMVCB3Q(.F.)'	, 0 , 5 , 0 , Nil } ) //Excluir
aAdd( aRotina, { STR0007	, 'VIEWDEF.PLSMVCB3Q(.F.)'	, 0 , 8 , 0 , Nil } ) //Imprimir

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B3Q

@return oModel	objeto model criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruB3Q := FWFormStruct( 1, 'B3Q', , )

oModel := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'B3QMASTER', Nil, oStruB3Q )
oModel:GetModel( 'B3QMASTER' ):SetDescription( STR0001 ) 
oModel:SetDescription( STR0001 )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3Q

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()  
Local oModel   := FWLoadModel( 'PLSMVCB3Q' )
Local oStruB3Q := FWFormStruct( 2, 'B3Q' ) 
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_B3Q' , oStruB3Q, 'B3QMASTER' )     
oView:CreateHorizontalBox( 'GERAL', 100 )
oView:SetOwnerView( 'VIEW_B3Q' , 'GERAL'  )

Return oView