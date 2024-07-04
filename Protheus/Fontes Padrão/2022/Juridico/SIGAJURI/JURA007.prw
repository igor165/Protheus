#INCLUDE "JURA007.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA007
Layout Relatório

@author Clóvis Eduardo Teixeira
@since 12/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA007()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0007)
oBrowse:SetAlias("NQK")
oBrowse:SetLocate()
JurSetLeg( oBrowse,"NQK")
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

@author Clóvis Eduardo Teixeira
@since 12/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA007", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA007", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA007", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA007", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA007", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Layout Relatório

@author Clóvis Eduardo Teixeira
@since 12/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA007" )
Local oStruct := FWFormStruct( 2, "NQK" )

JurSetAgrp( 'NQK',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA007_VIEW", oStruct, "NQKMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA007_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Layout Relatório"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Layout Relatório

@author Clóvis Eduardo Teixeira
@since 12/01/10
@version 1.0
@obs NQKMASTER - Dados do Layout Relatório

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQK := FWFormStruct( 1, "NQK" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA007", /*Pre-Validacao*/,{|oX| JA007OK(oX)} /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NQKMASTER", NIL, oStructNQK, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados Layout Relatório"
oModel:GetModel( "NQKMASTER" ):SetDescription( STR0009 ) //"Dados de Layout Relatório"
//oModel:GetModel( "NQKMASTER" ):SetUniqueLine( { "NQK_CCONF", "NQK_CCAMPO" } )
JurSetRules( oModel, 'NQKMASTER',, 'NQK' )

Return oModel      
       
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Layout Relatório

@author Clóvis Eduardo Teixeira
@since 12/01/10
@version 1.0
@obs NQKMASTER - Dados do Layout Relatório

/*/
//-------------------------------------------------------------------
Function JA007RPT(cCodConfig)
Local aArea := GetArea()
Local cAliasQry := GetNextAlias() 
Local cCodRpt   := ''

BeginSql Alias cAliasQry

  SELECT NQY_CRPT
    FROM %table:NQY% NQY
   WHERE NQY_COD = %Exp:cCodConfig%
   
EndSql   

dbSelectArea(cAliasQry)     
(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(EOF()) 
  cCodRpt := (cAliasQry)->NQY_CRPT
Endif
              
(cAliasQry)->( dbCloseArea() )  

RestArea( aArea )

Return cCodRpt


//-------------------------------------------------------------------
/*/{Protheus.doc} JA007TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Paulo Borges
@since 07/01/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA007OK(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local CCONF    := FwFldGet('NQK_CCONF')
Local CCAMPO   := FwFldGet('NQK_CCAMPO')


	If oModel:GetOperation() == 3
		
		NQK->( dbSetOrder(1) )
		IF (NQK->( dbSeek(xFilial("NQK")+CCONF+ CCAMPO) ))
		
			lRet := .F.
			JurMsgErro(STR0010) //"codigo Cadastrado ja existente
		EndIF   
		   
	Endif
		
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J007VDTPRE()
Valida para não permitir inclusão de layuot de relatórios com extensão PRW
Uso Geral. 

@return lRet

@author Wellington Coelho
@since 12/02/16
@version 1.0
/*/
//------------------------------------------------------------------- 
Function J007VDTPRE()
Local oModel    := FwModelActive()
Local cCodConf  := oModel:GetValue("NQKMASTER","NQK_CCONF")
Local cTipoRel  := ""
Local cCodRel   := ""
Local lRet      := .F.

cCodRel   := JurGetDados("NQY", 1, xFilial("NQK")+ cCodConf, "NQY_CRPT")

cTipoRel  := JurGetDados("NQR", 1, xFilial("NQK")+ cCodRel, "NQR_EXTENS")

If cTipoRel != '3'
	lRet := .T.
Else
	ApMsgInfo(STR0011)//"Não é possível incluir layout para relatórios com a extensão PRW"
	lRet := .F.
EndIf 

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} J007FTPREL()
Filtro da consulta padrão NQY, para não apresentar relatórios com a extensão .PRW 
Uso Geral. 

@return 

@author Wellington Coelho
@since 12/02/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J007FTPREL()
Local cRet := "@#@#"
Local cVal := ""

cRet := "@#NQY->NQY_CFGJUR <> '" + Space(TamSx3('NQY_CFGJUR')[1]) + "'@#"

Return cRet