#INCLUDE "JURA054.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA054
Advg. Da Parte Contraria

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA054()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRS" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRS" )
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
@since 05/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA054", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA054", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA054", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA054", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA054", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Advg. Da Parte Contraria

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA054" )
Local oStruct := FWFormStruct( 2, "NRS" )

JurSetAgrp( 'NRS',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA054_VIEW", oStruct, "NRSMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA054_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Advg. Da Parte Contraria"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Advg. Da Parte Contraria

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0

@obs NRSMASTER - Dados do Advg. Da Parte Contraria

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NRS" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA054", /*Pre-Validacao*/, /*Pos-Validacao*/,{|oX|JA054Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRSMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Advg. Da Parte Contraria"
oModel:GetModel( "NRSMASTER" ):SetDescription( STR0009 ) // "Dados de Advg. Da Parte Contraria"

JurSetRules( oModel, 'NRSMASTER',, 'NRS' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA054Commit
Commit de dados de Advogado da parte contrária

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA054Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NRSMASTER","NRS_CADVPC")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NRS',cCod)
	EndIf

Return lRet