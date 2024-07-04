#INCLUDE "JURA008.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA008
Campos Relat�rio

@author Cl�vis Eduardo Teixeira
@since 23/04/09
@version 1.0 
/*/
//-------------------------------------------------------------------
Function JURA008()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "NQ9" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "NQ9" )
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
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Cl�vis Eduardo Teixeira dos Santos
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA008", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA008", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA008", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA008", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA008", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados Campos do Relat�rio

@author Cl�vis Eduardo Teixeira dos Santos
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA008" )
Local oStruct := FWFormStruct( 2, "NQ9" )


	JurSetAgrp( 'NQ9',, oStruct )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA008_VIEW", oStruct, "NQ9MASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA008_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) //"Campos Relat�rio"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados Campos do Relat�rio

@author Cl�vis Eduardo Teixeira dos Santos
@since 23/04/09
@version 1.0

@obs NQ9MASTER - Dados do Campos do Relat�rio

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQ9 := FWFormStruct( 1, "NQ9" )

//-----------------------------------------
//Monta o modelo do formul�rio
//-----------------------------------------
	oModel:= MPFormModel():New( "JURA008", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "NQ9MASTER", NIL, oStructNQ9, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) //"Modelo de Dados de Campos Relat�rio"
	oModel:GetModel( "NQ9MASTER" ):SetDescription( STR0009 ) //"Dados de Campos Relat�rio"

	JurSetRules( oModel, 'NQ9MASTER',, 'NQ9' )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} JA008VlCPO
Valida��o de Campos
Uso Geral. 

@return lRet  Indica se a valida��o est� correta

@author Jorge Luis Branco Martins Junior
@since 11/12/14
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA008VlCPO()
Local aArea     := GetArea()
Local lRet      := .F.
Local cTabela   := ""
Local cTabelas  := 'NSZ|NTA|NT4' // Tabela que n�o s�o guias, mas podem ter configura��o de campos: Assuntos Jur�dicos, Follow Up e Andamento
Local cTabSec   := 'NUQ|NT9|NYP|NXY|NYJ' // Tabelas que s�o guias no cadastro de assunto jur�dico
Local cTabRel   := 'NSY|NT2|NT3' // Tabelas relacionadas que n�o s�o guias e n�o podem ter configura��o de campos: Valores em discuss�o, garantias e despesas

cTabela := SUBSTR(M->NQ9_CCAMPO, 1, 3)

	If cTabela $ cTabelas .Or. cTabela $ cTabSec .Or. cTabela $ cTabRel
		lRet := .T.
	Else
		lRet := .F.
		JurMsgErro(STR0023)//"Campo inv�lido"
	EndIf
	
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JA008F3CPO
Realiza o filtro de tabelas para busca dos campos usado no F3 de campos
Uso Geral. 

@return 

@author Jorge Luis Branco Martins Junior
@since 11/12/14
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA008F3CPO()
Local aArea   := GetArea()
Local lRet    := .F.
Local cFiltro := ""

cFiltro += "(X3_ARQUIVO=='NSZ'.OR."
cFiltro +=  "X3_ARQUIVO=='NT4'.OR."
cFiltro +=  "X3_ARQUIVO=='NTA'.OR."
cFiltro +=  "X3_ARQUIVO=='NUQ'.OR."
cFiltro +=  "X3_ARQUIVO=='NT9'.OR."
cFiltro +=  "X3_ARQUIVO=='NYP'.OR."
cFiltro +=  "X3_ARQUIVO=='NXY'.OR."
cFiltro +=  "X3_ARQUIVO=='NYJ'.OR."
cFiltro +=  "X3_ARQUIVO=='NSY'.OR."
cFiltro +=  "X3_ARQUIVO=='NT2'.OR."
cFiltro +=  "X3_ARQUIVO=='NT3'"
cFiltro +=  ").And.X3USO(X3_USADO)"

lRet := JURF3SX3(cFiltro)

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J008VDTPRE()
Valida a inclus�o dos par�metro dos relat�rios
assunto jur�dico  
Uso Geral. 

@return lRet

@author Wellington Coelho
@since 12/02/16
@version 1.0
/*/
//------------------------------------------------------------------- 
Function J008VDTPRE()
Local oModel    := FwModelActive()
Local cCodRel  := oModel:GetValue("NQ9MASTER","NQ9_CODRPT")
Local cTipoRel := ""
Local lRet      := .F.

cTipoRel  := JurGetDados("NQR", 1, xFilial("NQ9")+ cCodRel, "NQR_EXTENS")

If cTipoRel != '3'
	lRet := .T.
Else
	ApMsgInfo(STR0027)//"N�o � poss�vel criar par�metros para relat�rios com a extens�o PRW"
	lRet := .F.
EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J008FTPREL
Filtro da consulta padr�o NQR, para n�o apresentar rela�torios com a extens�o .PRW 
Uso Geral. 

@return 

@author Wellington Coelho
@since 12/02/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J008FTPREL()
Local cRet := "@#@#"

If !IsInCallStack('JURA014')
	cRet := "@#NQR->NQR_EXTENS <> '3'@#"
EndIf

Return cRet