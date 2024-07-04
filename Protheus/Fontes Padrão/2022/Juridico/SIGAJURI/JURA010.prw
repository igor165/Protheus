#INCLUDE "JURA010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA010
Especialidade

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA010()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQB" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQB" )
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

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA010", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA010", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA010", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA010", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA010", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Especialidade

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA010" )
Local oStruct := FWFormStruct( 2, "NQB" )

JurSetAgrp( 'NQB',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA010_VIEW", oStruct, "NQBMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA010_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Especialidade"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Especialidade

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0

@obs NQBMASTER - Dados do Especialidade

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQB := FWFormStruct( 1, "NQB" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA010", /*Pre-Validacao*/, /*Pos-Validacao*/, { |oX|JA010Commit(oX) } /*Commit*/,/*Cancel*/)
oModel:AddFields( "NQBMASTER", NIL, oStructNQB, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Especialidade"
oModel:GetModel( "NQBMASTER" ):SetDescription( STR0009 ) //"Dados de Especialidade"

JurSetRules( oModel, 'NQBMASTER',, 'NQB' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA010Commit
Commit de dados de Especialidade

@author Rafael Rezende Costa
@since 18/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA010Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQBMASTER","NQB_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQB',cCod)
	EndIf

Return lRet