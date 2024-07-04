#Include "JURA282.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA282
Histórico de Alterações de Pedidos

@author Cristiane Nishizaka
@since 25/08/2020
/*/
//-------------------------------------------------------------------
Function JURA282()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias( "O13" )
	oBrowse:SetLocate()

	oBrowse:SetMenuDef('JURA282')
	oBrowse:SetDescription( STR0001 )  //"Histórico de Alterações de Pedidos"
	JurSetBSize( oBrowse )

	oBrowse:Activate()
	oBrowse:Destroy()

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

@author Cristiane Nishizaka
@since 25/08/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } )  //"Pesquisar"
	aAdd( aRotina, { STR0003 , "VIEWDEF.JURA282", 0, 2, 0, NIL } )  //"Visualizar"
	aAdd( aRotina, { STR0004 , "VIEWDEF.JURA282", 0, 3, 0, NIL } )  //"Incluir"
	aAdd( aRotina, { STR0005 , "VIEWDEF.JURA282", 0, 4, 0, NIL } )  //"Alterar"
	aAdd( aRotina, { STR0006 , "VIEWDEF.JURA282", 0, 5, 0, NIL } )  //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados.

@author Cristiane Nishizaka
@since 25/08/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel     := FWLoadModel( "JURA282" )
	Local oStructO13 := FWFormStruct( 2, "O13" )

	JurSetAgrp( 'O13',, oStructO13 )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "JURA282_VIEW", oStructO13, "O13MASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA282_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0001 ) // "Histórico de Alterações de Pedidos"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author Cristiane Nishizaka
@since 25/08/2020
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructO13 := FWFormStruct( 1, "O13" )
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA282", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "O13MASTER", NIL, oStructO13, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0001 ) // "Histórico de Alterações de Pedidos"
	oModel:GetModel( "O13MASTER" ):SetDescription( STR0001 ) // 'Histórico de Alterações de Pedidos'

	JurSetRules( oModel, 'O13MASTER',, 'O13' )

Return oModel
