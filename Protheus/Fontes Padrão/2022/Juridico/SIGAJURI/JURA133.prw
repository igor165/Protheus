#INCLUDE "JURA133.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA133
Tipo de Aditivo
@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA133()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Tipo de Aditivo"
oBrowse:SetAlias( "NXZ" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NXZ" )
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
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA133", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA133", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA133", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA133", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA133", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Aditivo

@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA133" )
Local oStructNXZ := FWFormStruct( 2, "NXZ" )

JurSetAgrp( "NXZ",, oStructNXZ )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA133", oStructNXZ, "NXZMASTER"  )
oView:CreateHorizontalBox( "NXZMASTER" , 100 )
oView:SetOwnerView( "JURA133", "NXZMASTER" )

oView:SetDescription( STR0001 )  //"Tipo de Aditivo"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Aditivo

@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNXZ := FWFormStruct( 1, "NXZ" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA133", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA133Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NXZMASTER", NIL, oStructNXZ, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Tipo de Aditivo"

oModel:GetModel( "NXZMASTER" ):SetDescription( STR0009 ) //"Dados de Tipo de Aditivo"

JurSetRules( oModel, "NXZMASTER",, "NXZ" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA133Commit
Commit de dados de Tipo de Aditivo

@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA133Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NXZMASTER","NXZ_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NXZ',cCod)
	EndIf

Return lRet