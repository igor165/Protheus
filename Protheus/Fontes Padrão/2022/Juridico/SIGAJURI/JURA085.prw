#INCLUDE "JURA085.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA085
Tipo Objeto

@author Raphael Zei Cartaxo Silva
@since 14/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA085()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NSP" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NSP" )
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
@since 14/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA085", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA085", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA085", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA085", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA085", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo

@author Raphael Zei Cartaxo Silva
@since 14/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA085" )
Local oStruct    := FWFormStruct( 2, "NSP" )
Local oStructNQJ := FWFormStruct( 2, "NQJ" )

oStructNQJ:RemoveField( "NQJ_CPEDID" )

JurSetAgrp( 'NSP',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA085_VIEW", oStruct   , "NSPMASTER"  )
oView:AddGrid ( "JURA085_GRID", oStructNQJ, "NQJDETAIL"  )
oView:CreateHorizontalBox( "FORMFIELD", 20 )
oView:CreateHorizontalBox( "GRID"     , 80 )
oView:SetOwnerView( "JURA085_VIEW", "FORMFIELD" )
oView:SetOwnerView( "JURA085_GRID", "GRID"      )
oView:SetDescription( STR0007 ) // "Tipo"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo

@author Raphael Zei Cartaxo Silva
@since 14/05/09
@version 1.0

@obs NSPMASTER - Dados do Tipo

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NSP" )
Local oStructNQJ := FWFormStruct(1,"NQJ")

oStructNQJ:RemoveField( "NQJ_CPEDID" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA085", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA085Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NSPMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo"
oModel:GetModel( "NSPMASTER" ):SetDescription( STR0009 ) // "Dados de Tipo"
oModel:AddGrid( "NQJDETAIL", "NSPMASTER" /*cOwner*/, oStructNQJ, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NQJDETAIL" ):SetUniqueLine( { "NQJ_COBJET" } )
oModel:SetRelation( "NQJDETAIL", { { "NQJ_FILIAL", "XFILIAL('NQJ')" }, { "NQJ_CPEDID", "NSP_COD" } }, NQJ->( IndexKey( 1 ) ) )
oModel:GetModel( "NQJDETAIL" ):SetDescription( STR0010 ) //"Itens Tipo"

oModel:GetModel( "NQJDETAIL" ):SetDelAllLine( .T. )  

oModel:SetOptional( "NQJDETAIL" , .T. )

JurSetRules( oModel, 'NSPMASTER',, 'NSP' )
JurSetRules( oModel, 'NQJDETAIL',, 'NQJ' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA085Commit
Commit de dados de Tipo de Objeto

@author Jorge Luis Branco Martins Junior
@since 17/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA085Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NSPMASTER","NSP_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NSP',cCod)
	EndIf

Return lRet