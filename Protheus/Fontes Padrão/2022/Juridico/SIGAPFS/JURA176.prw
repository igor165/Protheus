#INCLUDE "JURA176.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA176
Rotina para consulta de arquivos importados Equitrac
@author wellington.coelho

@since 07/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA176()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Consulta de arquivos importados"
oBrowse:SetAlias('NYW')
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NYW" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View da Rotina de consulta das informações importadas Equitrac
/*
//@author wellington.coelho

//@since 07/05/2014
//@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA176" )
Local oStructNYW := FWFormStruct(2, 'NYW')
Local oStructNYX := FWFormStruct(2, 'NYX')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField("JURA176_VIEW", oStructNYW,'NYWMASTER')
oView:AddGrid( "JURA176_NYX" , oStructNYX,'NYXDETAIL')
oView:createHorizontalBox("BOX_01_F01_A01",40,,,,)
oView:createHorizontalBox("BOX_02_F01_A01",60,,,,)
oView:SetOwnerView( "JURA176_VIEW" , "BOX_01_F01_A01" )
oView:SetOwnerView( "JURA176_NYX"  , "BOX_02_F01_A01" )
oView:SetDescription(STR0001) //"Consulta de arquivos importados"

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model da Rotina de consulta das informações importadas Equitrac

@author wellington.coelho

@since 07/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel     := NIL
Local oStructNYW := FWFormStruct(1, 'NYW')
Local oStructNYX := FWFormStruct(1, 'NYX') 

oModel := MPFormModel():New("JURA176",/*Pre-Validacao*/, /*Pos-Validacao*/, /*{|oX| J174COMMIT(oX)}*//*Commit*/,/*Cancel*/)
oModel:AddFields("NYWMASTER", NIL, oStructNYW, /*Pre-Validacao*/, /*Pos-Validacao*/)
oModel:AddGrid("NYXDETAIL", "NYWMASTER" /*cOwner*/, oStructNYX, /*bLinePre*/, /*bLinePost*/, /*bPre*/,  /*bPost*/)

oModel:SetRelation( "NYXDETAIL", { { 'NYX_CODARQ', 'NYW_COD' } } , NYX->( IndexKey( 1 ) ) )

oModel:SetDescription(STR0001) //"Consulta de arquivos importados"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Cristina Cintra
@since 20/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"         , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA176" , 0, 2, 0, NIL } ) //"Visualizar"

Return aRotina