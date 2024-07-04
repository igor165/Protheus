#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#include 'PLSA284.ch'

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA284
Tela de cadastro de Tipos de Lançamento
@since 02/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA284(lAutoma)
Local oBrowse
local cFiltro := ""
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

cFiltro := "@(BZ7_FILIAL = '" + xFilial("BZ7") + "') "

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BZ7')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetDescription(STR0001) //"Tipos de Lançamento"
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

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSA284' 	Operation 2 Access 0  //"Visualizar"
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSA284" 	Operation 3 Access 0  //"Incluir"
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSA284" 	Operation 4 Access 0  //"Alterar"
Add Option aRotina Title  STR0005	Action "VIEWDEF.PLSA284"	Operation 5 Access 0  //"Excluir"

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
Local oStrBZ7	:= FWFormStruct(1,'BZ7')

oModel := MPFormModel():New( 'PLSA284') 
oModel:AddFields( 'BZ7MASTER', /*cOwner*/, oStrBZ7 )
oModel:GetModel( 'BZ7MASTER' ):SetDescription(STR0001 ) //"Tipos de Lançamento"

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
Local oModel	:= FWLoadModel( 'PLSA284' ) // Cria as estruturas a serem usadas na View
Local oStrBZ7	:= FWFormStruct(2,'BZ7')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_BZ7', oStrBZ7, 'BZ7MASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'VIEW_BZ7', 'SUPERIOR' )

Return oView