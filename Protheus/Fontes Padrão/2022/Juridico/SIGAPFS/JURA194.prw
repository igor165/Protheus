#INCLUDE "JURA194.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA194
Países para integração com o LegalDesk.

@author Cristina Cintra
@since 25/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA194()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Países - Integração LegalDesk"
oBrowse:SetAlias( "SYA" )
oBrowse:SetLocate()
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

@author Cristina Cintra
@since 25/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA194", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View dos países para integração com o LegalDesk.

@author Cristina Cintra
@since 25/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel( "JURA194" )
Local oStructSYA
Local oView

oStructSYA := FWFormStruct( 2, "SYA" )

JurSetAgrp( 'SYA',, oStructSYA )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "SYAMASTER", oStructSYA, "SYAMASTER"  )   
                                                   
oView:CreateHorizontalBox( "PRINCIPAL" , 100 )

oView:SetOwnerView( "SYAMASTER" , "PRINCIPAL" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Integração com o Equitrac.

@author Cristina Cintra
@since 02/05/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructSYA := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructSYA := FWFormStruct(1,"SYA")

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA194", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "SYAMASTER", /*cOwner*/, oStructSYA,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Load*/) 
oModel:GetModel( "SYAMASTER" ):SetDescription( STR0001 ) //"Países - Integração LegalDesk"

Return oModel