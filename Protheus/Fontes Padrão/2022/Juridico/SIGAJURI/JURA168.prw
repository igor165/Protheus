#INCLUDE "JURA168.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA168
Status Acordo

@author Antonio Carlos Ferreira
@since 07/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA168()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 ) // "Status Acordo"
oBrowse:SetAlias( "NYQ" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NYQ" )
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

@author Antonio Carlos Ferreira
@since 07/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA168", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA168", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA168", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA168", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA168", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Status Acordo

@author Antonio Carlos Ferreira
@since 07/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA168" )
Local oStruct := FWFormStruct( 2, "NYQ" )

JurSetAgrp( 'NYQ',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA168_VIEW", oStruct, "NYQMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA168_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Status Acordo"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Status Acordo

@author Antonio Carlos Ferreira
@since 07/02/14
@version 1.0

@obs NYQMASTER - Dados do Status Acordo

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NYQ" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA168", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA168Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NYQMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Status Acordo"
oModel:GetModel( "NYQMASTER" ):SetDescription( STR0009 ) // "Dados de Status Acordo"

JurSetRules( oModel, 'NYQMASTER',, 'NYQ' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} JA168Commit
Commit de dados de Acordo Jurídico 

@author Antonio Carlos Ferreira
@since 18/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA168Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NYQMASTER","NYQ_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NYQ',cCod)
	EndIf

Return lRet