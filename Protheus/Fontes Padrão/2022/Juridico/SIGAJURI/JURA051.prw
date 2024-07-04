#INCLUDE "JURA051.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA051
Ato Processual

@author Raphael Zei Cartaxo Silva
@since 30/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA051()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRO" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NRO" )
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
@since 30/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA051", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA051", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA051", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA051", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA051", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Ato Processual

@author Raphael Zei Cartaxo Silva
@since 30/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA051" )
Local oStruct := FWFormStruct( 2, "NRO" )

JurSetAgrp( 'NRO',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA051_VIEW", oStruct, "NROMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA051_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Ato Processual"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Ato Processual

@author Raphael Zei Cartaxo Silva
@since 30/04/09
@version 1.0

@obs NROMASTER - Dados do Ato Processual

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NRO" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA051", /*Pre-Validacao*/, {|oX| JURA051TOK(oX)}/*Pos-Validacao*/,{|oX|JA051Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NROMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Ato Processual"
oModel:GetModel( "NROMASTER" ):SetDescription( STR0009 ) // "Dados de Ato Processual"

JurSetRules( oModel, 'NROMASTER',, 'NRO' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA051TOK
Valida as informações do ato processual
Uso no cadastro de Ato Processual.

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Antonio Carlos Ferreira
@since 11/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA051TOK(oModel)
Local lRet        := .T.
Local aArea       := GetArea()

If  (FwFldGet("NRO_TIPO") == "1" /*Decisao*/) .And. (Empty(FwFldGet("NRO_CCLASS")) .Or. Empty(FwFldGet("NRO_CDECIS")))
    JurMsgErro(STR0010)	// "Obrigatório o preenchimento do campo 'Classificacao' e 'Cod Decisao' quando o campo 'Tipo' for igual a Decisao."  
    lRet:= .F.
EndIf

If  (FwFldGet("NRO_TIPO") == "2" /*Liminar*/) .And. Empty(FwFldGet("NRO_CSTATL"))
    JurMsgErro(STR0011)	// "Obrigatório o preenchimento do campo 'Status' quando o campo 'Tipo' for igual a Liminar."  
    lRet:= .F.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA051Commit
Commit de dados de Ato Processual

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA051Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NROMASTER","NRO_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NRO',cCod)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J051ClrPrF()
Limpa campo de prazo fixo quando sugestão de modelo de Follow-up
estiver em branco.

@author Jorge Luis Branco Martins Junior
@since 07/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J051ClrPrF()
Local oModel := FWModelActive()

If Empty(AllTrim(M->NRO_CFWPAD))
	oModel:ClearField("NROMASTER","NRO_PRFIXO")
EndIf

Return .T.