#INCLUDE "JURA165.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA165
Textos - Petições

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA165()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NYM" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NYM" )
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
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA165", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA165", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA165", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA165", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA165", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Textos - Petições

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA165" )
Local oStruct := FWFormStruct( 2, "NYM" )

JurSetAgrp( 'NYM',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA165_VIEW", oStruct, "NYMMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA165_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Texto - Petições"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Texto - Petições

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0

@obs NYMMASTER - Dados de Texto - Petições

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NYM" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA165", /*Pre-Validacao*/, {|oX|JA165TOK(oX)}/*Pos-Validacao*/,{|oX|JA165Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NYMMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Textos - Petições"
oModel:GetModel( "NYMMASTER" ):SetDescription( STR0009 ) // "Dados de Textos - Petições"

JurSetRules( oModel, 'NYMMASTER',, 'NYM' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA165Commit
Commit de dados de Textos - Petições

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA165Commit(oModel)
Local lRet := .T.

	FWFormCommit(oModel)
  
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA165TOK
Validação de dados de Textos - Petições

@author Jorge Luis Branco Martins Junior
@since 28/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA165TOK(oModel)
Local lRet  := .T.
Local nOpc  := oModel:GetOperation()
Local cNome := oModel:GetValue("NYMMASTER","NYM_NOME")

	If 	Alltrim(JurGetDados("NYN", 1, xFilial("NYN")+ cNome, "NYN_NOME")) != ""
		lRet := .F.
		JurMsgErro(STR0010) // Já existe uma variável cadastrada com esse nome. Verifique!
	EndIf
	
	If nOpc == 3 .And.	Alltrim(JurGetDados("NYM", 1, xFilial("NYM")+ cNome, "NYM_NOME")) != ""
		lRet := .F.
		JurMsgErro(STR0011) //Já existe um Texto cadastrado com esse nome. Verifique!
	EndIf

Return lRet