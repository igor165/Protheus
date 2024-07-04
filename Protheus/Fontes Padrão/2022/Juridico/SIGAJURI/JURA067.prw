#INCLUDE "JURA067.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA067
Cad Funcao P/ Uso Cliente

@author Raphael Zei Cartaxo Silva
@since 08/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA067()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NS6" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NS6" )
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
@since 08/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA067", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA067", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA067", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA067", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA067", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Cad Funcao P/ Uso Cliente

@author Raphael Zei Cartaxo Silva
@since 08/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel        := FWLoadModel( "JURA067" )
Local oStructMaster := FWFormStruct( 2, "NS6" )
Local oStructDetail := FWFormStruct( 2, "NU8" )
oStructDetail:RemoveField( "NU8_CFUNC" )

JurSetAgrp( 'NS6',, oStructMaster )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA067_VIEW", oStructMaster, "NS6MASTER"  )
oView:AddGrid ( "JURA067_GRID", oStructDetail, "NU8DETAIL"  )

oView:CreateHorizontalBox( "FORMFIELD", 20 )
oView:CreateHorizontalBox( "FORMGRID", 80 )

oView:SetOwnerView( "JURA067_VIEW", "FORMFIELD" )
oView:SetOwnerView( "JURA067_GRID", "FORMGRID" )

oView:SetDescription( STR0007 ) // "Cad Funcao P/ Uso Cliente"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Cad Funcao P/ Uso Cliente

@author Raphael Zei Cartaxo Silva
@since 08/05/09
@version 1.0

@obs NS6MASTER - Dados do Cad Funcao P/ Uso Cliente

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel        := NIL
Local oStructMaster := FWFormStruct( 1, "NS6" )
Local oStructDetail := FWFormStruct( 1, "NU8" )
oStructDetail:RemoveField( "NU8_CFUNC" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA067", /*Pre-Validacao*/, {|oX| JA067TOK(oX)}/*Pos-Validacao*/, { |oX| JA067Commit(oX) }/*Commit*/,/*Cancel*/)
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Cad Funcao P/ Uso Cliente"

oModel:AddFields( "NS6MASTER", NIL, oStructMaster, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:GetModel( "NS6MASTER" ):SetDescription( STR0009 ) // "Dados de Cad Funcao P/ Uso Cliente"

oModel:AddGrid( "NU8DETAIL", "NS6MASTER" /*cOwner*/, oStructDetail, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NU8DETAIL" ):SetDescription( STR0010 ) //"Itens Objeto Juridico"

oModel:GetModel( "NU8DETAIL" ):SetUniqueLine( { "NU8_CCLIEN","NU8_CLOJA" } )
oModel:SetRelation( "NU8DETAIL", { { "NU8_FILIAL", "XFILIAL('NU8')" }, { "NU8_CFUNC", "NS6_COD" } }, NU8->( IndexKey( 1 ) ) )

JurSetRules( oModel, 'NS6MASTER',, 'NS6' )
JurSetRules( oModel, 'NU8DETAIL',, 'NU8' )

Return oModel                   


//-------------------------------------------------------------------
/*/{Protheus.doc} JA067TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA067TOK(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local cCliente := AllTrim(oModel:GetValue('NU8DETAIL','NU8_CCLIEN')) 
Local nOpc     := oModel:GetOperation()     

If nOpc == 3 .Or. nOpc == 4

	If Empty(cCliente)
		JurMsgErro(STR0011)
		lRet := .F.
	EndIf	
	
EndIf 
                      
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA057Commit
Commit de dados de Funções

@author Rafael Rezende Costa
@since 18/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA067Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NS6MASTER","NS6_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NS6',cCod)
	EndIf

Return lRet