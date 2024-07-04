#INCLUDE "JURA128.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA128
Área de Abrangência
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA128()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Área de Abrangência"
oBrowse:SetAlias( "NWY" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NWY" )
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
aAdd( aRotina, { STR0003, "VIEWDEF.JURA128", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA128", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA128", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA128", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA128", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Área de Abrangência Jurídico

@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA128" )
Local oStructNWY := FWFormStruct( 2, "NWY" )

JurSetAgrp( "NWY",, oStructNWY )

oView := FWFormView():New()
oView:SetModel( oModel )   
oView:AddField( "JURA128_VIEW", oStructNWY, "NWYMASTER"  ) 
oView:CreateHorizontalBox( "NWYMASTER" , 100 )
oView:SetOwnerView( "JURA128_VIEW", "NWYMASTER" )
oView:SetDescription( STR0001 )  //"Área de Abrangência"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Área de Abrangência Jurídico
@author Clovis Eduardo Teixeira
@since 10/10/09
@version 1.0
@obs NWYMASTER - Dados do Área de Abrangência Jurídico

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNWY := FWFormStruct( 1, "NWY" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA128", /*Pre-Validacao*/, {|oX| JA128TOK(oX)}/*Pos-Validacao*/, {|oX|JA128Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NWYMASTER", NIL, oStructNWY, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Dados do Área de Abrangência Jurídica"
oModel:GetModel( "NWYMASTER" ):SetDescription( STR0009 ) //"Dados do Área de Abrangência Jurídica"

JurSetRules( oModel, "NWYMASTER",, "NWY" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA128Commit
Commit de dados de Área de Abrangência Jurídica

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA128Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NWYMASTER","NWY_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NWY',cCod)
	EndIf

Return lRet

//+-------------------------------------------------------------------------- 
/*/ {Protheus.doc} JA128TOK
Valida o modelo antes de salvar

@author     rodrigo.guerato
@since      26/07/2013
@param      oExp1: Modelo a ser avaliado
@return     lRet1: Permite ou nao continuar com a operacao
@version    1.0
/*/
//+--------------------------------------------------------------------------
Function JA128TOK( oModel )
	Local lTrConc	:= SuperGetMv("MV_JTVCONC",,"2") == "1"   
	Local lRet 	:= .T.
	Local nOpc	 	:= oModel:GetOperation()
	
	If nOpc == 3 .or. nOpc == 4
		If lTrConc .and. Empty( oModel:GetValue("NWYMASTER","NWY_TIPO") )
			JurMsgErro(STR0010)
			lRet := .F.
		Endif
	Endif
	
Return lRet

