#INCLUDE "JURA019.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA019
Decisão do Processo

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA019()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQQ" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQQ" )
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

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA019", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA019", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA019", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA019", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA019", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Decisão do Processo

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA019" )
Local oStruct := FWFormStruct( 2, "NQQ" )

JurSetAgrp( 'NQQ',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA019_VIEW", oStruct, "NQQMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA019_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Decisão do Processo"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Decisão do Processo

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0

@obs NQQMASTER - Dados do Decisão do Processo

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NQQ" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA019", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA019Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NQQMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Decisão do Processo"
oModel:GetModel( "NQQMASTER" ):SetDescription( STR0009 ) // "Dados de Decisão do Processo"

JurSetRules( oModel, 'NQQMASTER',, 'NQQ' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA019Commit
Commit de dados de Decisão

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA019Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQQMASTER","NQQ_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQQ',cCod)
	EndIf

Return lRet