#INCLUDE "JURA017.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA017
Resultado de Followup

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA017()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQN" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQN" )
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

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA017", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA017", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA017", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA017", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA017", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Resultado de Followup

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA017" )
Local oStruct := FWFormStruct( 2, "NQN" )

JurSetAgrp( 'NQN',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA017_VIEW", oStruct, "NQNMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA017_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Resultado de Followup"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Resultado de Followup

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0

@obs NQNMASTER - Dados do Resultado de Followup

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQN := FWFormStruct( 1, "NQN" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA017", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA017Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NQNMASTER", NIL, oStructNQN, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Resultado de Followup"
oModel:GetModel( "NQNMASTER" ):SetDescription( STR0009 ) //"Dados de Resultado de Followup"

JurSetRules( oModel, 'NQNMASTER',, 'NQN' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA017Commit
Commit de dados de Resultado do Follow-Up

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA017Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQNMASTER","NQN_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQN',cCod)
	EndIf

Return lRet
