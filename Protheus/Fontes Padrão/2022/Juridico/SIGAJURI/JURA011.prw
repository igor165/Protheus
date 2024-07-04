#INCLUDE "JURA011.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA011
Fase Processual

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA011()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQG" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQG" )
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
aAdd( aRotina, { STR0002, "VIEWDEF.JURA011", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA011", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA011", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA011", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA011", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Fase Processual

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA011" )
Local oStruct := FWFormStruct( 2, "NQG" )

JurSetAgrp( 'NQG',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA011_VIEW", oStruct, "NQGMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA011_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Fase Processual"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Fase Processual

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0

@obs NQGMASTER - Dados do Fase Processual

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQG := FWFormStruct( 1, "NQG" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA011", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA011Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NQGMASTER", NIL, oStructNQG, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Fase Processual"
oModel:GetModel( "NQGMASTER" ):SetDescription( STR0009 ) //"Dados de Fase Processual"

JurSetRules( oModel, 'NQGMASTER',, 'NQG' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA011Commit
Commit de dados de Fase Processual

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA011Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQGMASTER","NQG_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQG',cCod)
	EndIf

Return lRet
