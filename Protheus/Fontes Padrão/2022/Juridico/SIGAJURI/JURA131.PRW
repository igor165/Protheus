#INCLUDE "JURA131.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA131
Situação
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA131()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Situação"
oBrowse:SetAlias( "NXU" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NXU" )
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
aAdd( aRotina, { STR0003, "VIEWDEF.JURA131", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA131", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA131", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA131", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA131", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Situação

@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA131" )
Local oStructNXU := FWFormStruct( 2, "NXU" )

JurSetAgrp( "NXU",, oStructNXU )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA131", oStructNXU, "NXUMASTER"  )
oView:CreateHorizontalBox( "NXUMASTER" , 100 )
oView:SetOwnerView( "JURA131", "NXUMASTER" )

oView:SetDescription( STR0001 )  //"Situação"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Situação
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
@obs NXUMASTER - Dados do Situação

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNXU := FWFormStruct( 1, "NXU" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA131", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA131Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NXUMASTER", NIL, oStructNXU, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Dados Situação"

oModel:GetModel( "NXUMASTER" ):SetDescription( STR0009 ) //"Dados de Situação"

JurSetRules( oModel, "NXUMASTER",, "NXU" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA131Commit
Commit de dados de Situação

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA131Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NXUMASTER","NXU_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NXU',cCod)
	EndIf

Return lRet