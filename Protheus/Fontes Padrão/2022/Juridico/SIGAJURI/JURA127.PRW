#INCLUDE "JURA127.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA127
Espécie
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA127()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Espécie"
oBrowse:SetAlias( "NWX" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NWX" )
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
aAdd( aRotina, { STR0003, "VIEWDEF.JURA127", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA127", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA127", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA127", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA127", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Espécie

@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA127" )
Local oStructNWX := FWFormStruct( 2, "NWX" )

JurSetAgrp( "NWX",, oStructNWX )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA127", oStructNWX, "NWXMASTER"  )
oView:CreateHorizontalBox( "NWXMASTER" , 100 )
oView:SetOwnerView( "JURA127", "NWXMASTER" )

oView:SetDescription( STR0001 )  //"Espécie"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Espécie
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
@obs NWXMASTER - Dados do Espécie

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNWX := FWFormStruct( 1, "NWX" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA127", /*Pre-Validacao*/, {|oX| JA127TOK(oX)} /*Pos-Validacao*/, { |oM| JA127Commit(oM) }/*Commit*/,/*Cancel*/)
oModel:AddFields( "NWXMASTER", NIL, oStructNWX, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Dados Espécie"

oModel:GetModel( "NWXMASTER" ):SetDescription( STR0009 ) //"Dados de Espécie"

JurSetRules( oModel, "NWXMASTER",, "NWX" )

Return oModel


//+--------------------------------------------------------------------------
/*/{Protheus.doc} JA127TOK
Valida o modelo antes de salvar

@author     rodrigo.guerato
@since      25/07/2013
@param      oExp1: Modelo a ser avaliado
@return     lRet1: Permite ou nao continuar com a operacao
@version    1.0
/*/
//+--------------------------------------------------------------------------
Function JA127TOK( oModel )
	Local lTrConc	:= SuperGetMv("MV_JTVCONC",,"2") == "1"   
	Local lRet 	    := .T.
	Local nOpc	 	:= oModel:GetOperation()
	
	If nOpc == 3 .or. nOpc == 4
		If lTrConc .and. Empty( oModel:GetValue("NWXMASTER","NWX_TIPO") )
			JurMsgErro(STR0010)
			lRet := .F.
		Endif
	Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA127Commit
Commit de dados de Especie

@author Rafael Rezende Costa
@since 18/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA127Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NWXMASTER","NWX_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NWX',cCod)
	EndIf

Return lRet