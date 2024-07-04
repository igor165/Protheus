#INCLUDE "JURA048.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA048
Subárea jurídica

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//---------------------------------- ---------------------------------
Function JURA048()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRL" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRL" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL
 

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

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA048", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA048", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA048", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA048", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA048", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Subarea Juridica

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA048" )
Local oStruct := FWFormStruct( 2, "NRL" )

JurSetAgrp( 'NRL',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA048_VIEW", oStruct, "NRLMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA048_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Subarea Juridica"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Subarea Juridica

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
 
@obs NRLMASTER - Dados do Subarea Juridica
 
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NRL" )
Local oCommit    := JA048COMMIT():New()

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA048", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRLMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Subarea Juridica"
oModel:GetModel( "NRLMASTER" ):SetDescription( STR0009 ) // "Dados de Subarea Juridica"

oModel:InstallEvent("JA048COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NRLMASTER',, 'NRL' )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA048COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA048COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA048COMMIT
Return

Method InTTS(oModel, cModelId) Class JA048COMMIT
    JFILASINC(oModel:GetModel(), "NRL", "NRLMASTER", "NRL_COD", "NRL_CAREA")
Return 