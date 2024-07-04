#INCLUDE "JURA079.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA079
Tipo de contrato do correspondente

@author Clóvis Eduardo Teixeira
@since 13/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA079()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NSQ" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NSQ" )
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

@author Clóvis Eduardo Teixeira
@since 13/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA079", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA079", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA079", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA079", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA079", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de contrato do correspondente

@author Clóvis Eduardo Teixeira
@since 13/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := FwLoadModel( "JURA079" )
Local oStructNSQ

//--------------------------------------------------------------
//Montagem da interface via dicionario de dados
//--------------------------------------------------------------
oStructNSQ := FWFormStruct( 2, "NSQ" )

//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
JurSetAgrp( 'NSQ',, oStructNSQ )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA079_VIEW", oStructNSQ, "NSQMASTER"  )

oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA079_VIEW", "FORMFIELD" )

oView:SetUseCursor( .T. )
oView:SetDescription( STR0007 ) // "Tipo de acesso - usuários"
oView:EnableControlBar( .T. )

Return oView
	
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de contrato do correspondente

@author Clóvis Eduardo Teixeira
@since 13/05/09
@version 1.0

@obs NSQMASTER - Cabecalho Tipo de acesso - usuários / NSIDETAIL - Itens Tipo de acesso - usuários

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructNSQ := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNSQ := FWFormStruct( 1, "NSQ" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MpFormModel():New( "JURA079", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA079Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NSQMASTER", /*cOwner*/, oStructNSQ, /*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:SetDescription( STR0008 ) // "Modelo de Dados da Tipo de acesso - usuários"

oModel:GetModel( "NSQMASTER" ):SetDescription( STR0009 ) // "Cabecalho Tipo de acesso - usuários"

JurSetRules( oModel, "NSQMASTER",, 'NSQ' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA079Commit
Commit de dados de Tipo de Contrato

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA079Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NSQMASTER","NSQ_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NSQ',cCod)
	EndIf

Return lRet