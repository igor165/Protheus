#INCLUDE "JURA240.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA240
Histórico Padrão.

@author Jorge Luis Branco Martins Junior
@since 04/07/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA240()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 ) // "Histórico Padrão"
oBrowse:SetAlias( "OHA" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "OHA" )
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

@author Jorge Luis Branco Martins Junior
@since 04/07/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA240", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA240", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA240", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA240", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA240", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Histórico Padrão

@author Jorge Luis Branco Martins Junior
@since 04/07/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView   := Nil
Local oModel  := FWLoadModel( "JURA240" )
Local oStruct := FWFormStruct( 2, "OHA" )

JurSetAgrp( 'OHA',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA240_VIEW", oStruct, "OHAMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA240_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Histórico Padrão"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Histórico Padrão

@author Jorge Luis Branco Martins Junior
@since 04/07/17
@version 1.0

@obs OHAMASTER - Dados do Histórico Padrão
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOHA := FWFormStruct( 1, "OHA" )

oModel:= MPFormModel():New( "JURA240", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "OHAMASTER", NIL, oStructOHA, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Histórico Padrão"
oModel:GetModel( "OHAMASTER" ):SetDescription( STR0009 ) // "Dados de Histórico Padrão"

JurSetRules( oModel, 'OHAMASTER',, 'OHA' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J240F3OHA
Filtro da consulta padrão de Histórico Padrão

@Return cRet   Filtro da consulta

@author Jorge Luis Branco Martins Junior
@since 28/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J240F3OHA()
Local cRet    := "@#"
Local cCampo  := ReadVar()

Do Case
Case cCampo == "M->OHB_CHISTP"
	cRet += " OHA->OHA_LANCAM == '1' "
	
Case cCampo == "M->OHD_CHISTP"
	cRet += " OHA->OHA_COBRAN == '1' "

Case cCampo == "M->OHF_CHISTP"
	cRet += " OHA->OHA_CTAPAG == '1' "

Case cCampo == "M->OHG_CHISTP"
	cRet += " OHA->OHA_CTAPAG == '1' "
EndCase

cRet += "@#"

Return cRet
