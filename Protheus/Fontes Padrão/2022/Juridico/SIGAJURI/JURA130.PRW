#INCLUDE "JURA130.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA130
Negociação
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA130()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Negociação"
oBrowse:SetAlias( "NXT" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NXT" )
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

@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA130", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA130", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA130", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA130", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA130", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Negociação

@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA130" )
Local oStructNXT := FWFormStruct( 2, "NXT" )

JurSetAgrp( "NXT",, oStructNXT )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA130", oStructNXT, "NXTMASTER"  )
oView:CreateHorizontalBox( "NXTMASTER" , 100 )
oView:SetOwnerView( "JURA130", "NXTMASTER" )

oView:SetDescription( STR0001 )  //"Negociação"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Negociação
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
@obs NXTMASTER - Dados do Negociação

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNXT := FWFormStruct( 1, "NXT" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA130", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA130Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NXTMASTER", NIL, oStructNXT, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Dados Negociação"

oModel:GetModel( "NXTMASTER" ):SetDescription( STR0009 ) //"Dados de Negociação"

JurSetRules( oModel, "NXTMASTER",, "NXT" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA130Commit
Commit de dados de Negociação

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA130Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NXTMASTER","NXT_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NXT',cCod)
	EndIf

Return lRet