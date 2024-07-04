#INCLUDE "JURA261.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA261
Integrações

@author simone.oliveira
@since 23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA261()

Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 ) //Integrações
	oBrowse:SetAlias( "O0U" )
	oBrowse:SetMenuDef( 'JURA261' )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O0U" )
	JurSetBSize( oBrowse )
	oBrowse:Activate()

Return .T.

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

@author simone.oliveira	
@since 23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA261", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA261", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA261", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA261", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA261", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author simone.oliveira	
@since 23/04/2018
@version 1.0

@obs O0UMASTER - Dados das Configurações de Integração"
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructO0U := FWFormStruct( 1, "O0U" )
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA261", , , , )
	oModel:SetDescription( STR0007 )                         //Configuração de Integração                			
	oModel:AddFields( "O0UMASTER", NIL, oStructO0U, , )
	oModel:GetModel( "O0UMASTER" ):SetDescription( STR0008 ) //"Dados das Integrações" 		
	JurSetRules( oModel, 'O0UMASTER',, 'O0U' )
	oModel:SetPrimaryKey( { "O0U_FILIAL", "O0U_COD" } )
	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados 

@author simone.oliveira
@since 23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA261" )
Local oStructO0U := FWFormStruct( 2, "O0U" )
			
	JurSetAgrp( 'O0U',, oStructO0U )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 )		//Integrações
	
	//Adiciona quebra de linha para melhor posicionamento dos campos
	If oStructO0U:HasField("O0U_STATUS")
		oStructO0U:SetProperty('O0U_STATUS',MVC_VIEW_INSERTLINE,.T.)
	Endif

	If oStructO0U:HasField("O0U_TAGSTA")
		oStructO0U:SetProperty('O0U_TAGSTA',MVC_VIEW_INSERTLINE,.T.)
	Endif

	oView:AddField( "JURA261_FIELD", oStructO0U, "O0UMASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100)
	oView:SetOwnerView( "JURA261_FIELD", "FORMFIELD" )
	oView:EnableTitleView( "JURA261_FIELD"  )
	oView:EnableControlBar( .T. )

Return oView

