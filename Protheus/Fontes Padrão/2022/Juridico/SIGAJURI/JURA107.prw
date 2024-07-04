#INCLUDE "JURA107.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA107
Local de Trabalho

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA107()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NTB" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NTB" )
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
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA107", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA107", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA107", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA107", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Local de Trabalho

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA107" )
Local oStruct := FWFormStruct( 2, "NTB" )

JurSetAgrp( 'NTB',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA107_VIEW", oStruct, "NTBMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA107_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Local de Trabalho"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Local de Trabalho

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0

@obs NTBMASTER - Dados do Local de Trabalho

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NTB" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA107", /*Pre-Validacao*/, { |oX| JA107Commit(oX) }/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NTBMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Local de Trabalho"
oModel:GetModel( "NTBMASTER" ):SetDescription( STR0009 ) // "Dados de Local de Trabalho"

JurSetRules( oModel, 'NTBMASTER',, 'NTB' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} JA107Commit
Commit de dados do Local do Trabalho

@author Rafael Rezende Costa
@since 18/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA107Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NTBMASTER","NTB_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NTB',cCod)
	EndIf

Return lRet