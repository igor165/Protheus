#INCLUDE "JURA169.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA169
Tipo de Outorga

@author Jorge Luis Branco Martins Junior
@since 31/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA169()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Tipo de Outorga"
oBrowse:SetAlias( "NYI" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NYI" )
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
@since 31/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA169", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA169", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA169", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA169", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA169", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de Dados de Tipo de Outorga

@author Jorge Luis Branco Martins Junior
@since 31/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA169" )
Local oStructNYI := FWFormStruct( 2, "NYI" )

JurSetAgrp( "NYI",, oStructNYI )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA169", oStructNYI, "NYIMASTER"  )
oView:CreateHorizontalBox( "NYIMASTER" , 100 )
oView:SetOwnerView( "JURA169", "NYIMASTER" )

oView:SetDescription( STR0001 )  //"Tipo de Outorga"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Negociação
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
@obs NYIMASTER - Dados de Tipo de Outorga

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNYI := FWFormStruct( 1, "NYI" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA169", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA169Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NYIMASTER", NIL, oStructNYI, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Dados de Tipo de Outorga"

oModel:GetModel( "NYIMASTER" ):SetDescription( STR0009 ) //"Dados de Tipo de Outorga"

JurSetRules( oModel, "NYIMASTER",, "NYI" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA169Commit
Commit de dados de Tipo de Outorga

@param 	  oModel      Modelo de dados de Tipo de Outorga

@return 	lRet        Indica se foi feita a restrição de cadastro básico
                       com sucesso

@author Jorge Luis Branco Martins Junior
@since 31/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA169Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NYIMASTER","NYI_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NYI',cCod)
	EndIf

Return lRet