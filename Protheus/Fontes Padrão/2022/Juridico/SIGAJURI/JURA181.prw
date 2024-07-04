#INCLUDE "JURA181.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   

#DEFINE CAMPOSCAB 'NVJ_CASJUR|NVJ_DASJUR|'
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA181
Tipo Assunto X Pesquisa
@author Clovis E. Teixeira dos Santos
@since 24/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA181()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NVJ" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NVJ" )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
            [n,1] Nome a aparecer no cabecalho
            [[n,2] Nome da Rotina associada            
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

@author Clovis E. Teixeira dos Santos
@since 24/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA181", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA181", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA181", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA181", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo Assunto X Pesquisa

@author Clovis E. Teixeira dos Santos
@since 24/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel  := FWLoadModel('JURA181')
Local oStruct := FWFormStruct( 2, 'NVJ')

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA181_VIEW', oStruct, 'NVJMASTER'  )
oView:CreateHorizontalBox( 'FORMFIELD', 100 )
oView:SetOwnerView( 'JURA181_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0007 ) //"Tipo de Assunto Jurídico x Pesquisa"
oView:EnableControlBar( .T. )

Return oView     

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo Assunto X Pesquisa

@author Clovis E. Teixeira dos Santos
@since 24/09/09
@version 1.0
@obs NVJMASTER - Dados do Tipo Assunto X Pesquisa
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
oStruct := FWFormStruct( 1, 'NVJ')

oModel := MPFormModel():New( 'JURA181',, )
oModel:AddFields('NVJMASTER', NIL, oStruct, , )

oModel:SetDescription( STR0010 ) //"Modelo de Dados Tipo de Assunto Jurídico x Pesquisa"
oModel:GetModel( 'NVJMASTER' ):SetDescription( STR0008 ) //'Cabecalho Dados Tipo de Assunto Jurídico x Pesquisa'
JurSetRules( oModel, 'NVJMASTER',, 'NVJ' )

Return oModel 