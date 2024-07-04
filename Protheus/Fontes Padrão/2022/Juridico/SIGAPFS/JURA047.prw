#INCLUDE "JURA047.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA047
Tipo da tab. serv tabelados

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA047()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRK" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRK" )
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
aAdd( aRotina, { STR0002, "VIEWDEF.JURA047", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA047", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA047", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA047", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA047", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo da Tab. Serv. Tabelados

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA047" )
Local oStruct := FWFormStruct( 2, "NRK" )

JurSetAgrp( 'NRK',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA047_VIEW", oStruct, "NRKMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA047_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Tipo da Tab. Serv. Tabelados"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo da Tab. Serv. Tabelados

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0

@obs NRKMASTER - Dados do Tipo da Tab. Serv. Tabelados

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NRK" )
Local oCommit    := JA047COMMIT():New()

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA047", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRKMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo da Tab. Serv. Tabelados"
oModel:GetModel( "NRKMASTER" ):SetDescription( STR0009 ) // "Dados de Tipo da Tab. Serv. Tabelados"

oModel:InstallEvent("JA047COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NRKMASTER',, 'NRK' )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA047COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA047COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA047COMMIT
Return

Method InTTS(oModel, cModelId) Class JA047COMMIT
    JFILASINC(oModel:GetModel(), "NRK", "NRKMASTER", "NRK_COD")
Return