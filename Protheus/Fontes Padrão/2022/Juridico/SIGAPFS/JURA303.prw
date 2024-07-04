#INCLUDE "JURA303.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA303
Histórico de Faturamento por ocorrência

@author Carolina Neiva Ribeiro
@since 30/09/2022
/*/
//-------------------------------------------------------------------
Function JURA303()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 )//"Histórico de Faturamento por ocorrência" 
oBrowse:SetAlias( "OI6" )
oBrowse:SetMenuDef( 'JURA303' )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "OI6" )
JurSetBSize( oBrowse )

oBrowse:SetFilterDefault( "OI6_FILIAL == '" + xFilial('OI6') + "' .AND. OI6_FATADI == '" + NVV->NVV_COD + "'" )

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

@author Carolina Neiva Ribeiro
@since 30/09/2022
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA303", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA303", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA303", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA303", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA303", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Modelo de dados de Histórico de Faturamento por ocorrência

@author Carolina Neiva Ribeiro
@since 30/09/2022
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA303" )
Local oStruct := FWFormStruct( 2, "OI6" )

JurSetAgrp( 'OI6',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA303_VIEW", oStruct, "OI6MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA303_VIEW", "FORMFIELD" )
oView:SetDescription(STR0001 ) //"Histórico de Faturamento por ocorrência" 
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Histórico de Faturamento por ocorrência

@author Carolina Neiva Ribeiro
@since 30/09/2022

@obs OI6MASTER - Dados do Histórico de Faturamento por ocorrência

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOI6 := FWFormStruct( 1, "OI6" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA303", /*Pre-Validacao*/, {|oX|JA303TOK(oX)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields( "OI6MASTER", NIL, oStructOI6, /*Pre-Validacao*/, /*Pos-Validacao*/ ) 
oModel:SetDescription( STR0001 ) //"Histórico de Faturamento por ocorrência" 
oModel:GetModel( "OI6MASTER" ):SetDescription( STR0001 ) //"Histórico de Faturamento por ocorrência"  

JurSetRules( oModel, 'OI6MASTER',, 'OI6' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA303Validação
Validação de dados do Histórico de Faturamento por ocorrência

@author Carolina Neiva Ribeiro
@since 30/09/2022
/*/
//-------------------------------------------------------------------
Static Function JA303TOK(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("OI6MASTER","OI6_COD")
Local nOpc := oModel:GetOperation()
Local dDtFin := oModel:GetValue("OI6MASTER", "OI6_DTFIM")
Local dDtIni := oModel:GetValue("OI6MASTER", "OI6_DTINI ")
  
	If nOpc == 3
		lRet := JurSetRest('OI6',cCod)
	EndIf

	If dDtIni > dDtFin
		lRet := .F.
		JurMsgErro( STR0008 ) // "A Data de referência Inicial deve ser menor ou igual a Final!"
	EndIf

Return lRet
