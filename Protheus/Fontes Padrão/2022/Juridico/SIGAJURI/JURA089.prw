#INCLUDE "JURA089.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA089
Classe / Subclasse

@author Juliana Iwayama Velho
@since 23/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA089()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NSV" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NSV" )
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
@since 23/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA089", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA089", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA089", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA089", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA089", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Classe / Subclasse

@author Juliana Iwayama Velho
@since 23/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel      := FWLoadModel( "JURA089" )
Local oStruct     := FWFormStruct( 2, "NSV" )
Local oStructGrid := FWFormStruct( 2, "NSW" )
oStructGrid:RemoveField( "NSW_CCLASS" )

JurSetAgrp( 'NSV',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA089_VIEW", oStruct, "NSVMASTER"  )     
oView:AddGrid ( "JURA089_GRID", oStructGrid, "NSWDETAIL"  )

oView:CreateHorizontalBox( "FORMFIELD", 20 )
oView:CreateHorizontalBox( "FORMGRID", 80 )

oView:SetOwnerView( "JURA089_VIEW", "FORMFIELD" )      
oView:SetOwnerView( "JURA089_GRID", "FORMGRID" )

oView:SetDescription( STR0007 ) 
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Classe / Subclasse

@author Juliana Iwayama Velho
@since 23/03/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NSV" )     
Local oStructGrid:= FWFormStruct( 1, "NSW" )
oStructGrid:RemoveField( "NSW_CCLASS" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA089", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA089Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NSVMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) 
oModel:GetModel( "NSVMASTER" ):SetDescription( STR0009 ) 

oModel:AddGrid( "NSWDETAIL", "NSVMASTER" /*cOwner*/, oStructGrid, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NSWDETAIL" ):SetUniqueLine( { "NSW_COD" } )
oModel:SetRelation( "NSWDETAIL", { { "NSW_FILIAL", "XFILIAL('NSW')" }, { "NSW_CCLASS", "NSV_COD" } }, NSW->( IndexKey( 1 ) ) )

oModel:SetOptional( "NSWDETAIL" , .T. )     
oModel:GetModel( "NSWDETAIL" ):SetDelAllLine( .T. )  

JurSetRules( oModel, 'NSVMASTER',, 'NSV' )
JurSetRules( oModel, 'NSWDETAIL',, 'NSW' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA089Commit
Commit de dados de Classe

@author Jorge Luis Branco Martins Junior
@since 17/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA089Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NSVMASTER","NSV_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NSV',cCod)
	EndIf

Return lRet