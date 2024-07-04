#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#include 'PLSA285.ch'

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA285
Tela de cadastro de Motivos de Demissão
@since 02/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA285(lAutoma)
Local oBrowse
local cFiltro := ""
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

cFiltro := "@(BZ6_FILIAL = '" + xFilial("BZ6") + "') "

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BZ6')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetDescription(STR0001) //"Motivos de Demissão"
if !lAutoma
    oBrowse:Activate()
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 02/2020
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSA285' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSA285" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSA285" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action "VIEWDEF.PLSA285"	Operation 5 Access 0  //Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBZ6	:= FWFormStruct(1,'BZ6')

oModel := MPFormModel():New( 'PLSA285') 
oModel:AddFields( 'BZ6MASTER', /*cOwner*/, oStrBZ6 )
oModel:GetModel( 'BZ6MASTER' ):SetDescription(STR0001 ) //"Motivos de Demissão"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSA285' ) // Cria as estruturas a serem usadas na View
Local oStrBZ6	:= FWFormStruct(2,'BZ6')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_BZ6', oStrBZ6, 'BZ6MASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'VIEW_BZ6', 'SUPERIOR' )

Return oView