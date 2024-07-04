#INCLUDE "JURA015.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA015
Especialista Juridico

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA015()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQL" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQL" )
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
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA015", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA015", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA015", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA015", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA015", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Especialista Juridico

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA015" )
Local oStruct := FWFormStruct( 2, "NQL" )
Local cParam	:= AllTrim( SuperGetMv('MV_JDOCUME',,'1'))  

JurSetAgrp( 'NQL',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA015_VIEW", oStruct, "NQLMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA015_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Especialista Juridico"
If !(cParam == '1' .AND. IsPlugin())      
	oView:AddUserButton( STR0010, "CLIPS", {| oView | JURANEXDOC("NQL","NQLMASTER",,"NQL_COD") } )
EndIf
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Especialista Juridico

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0

@obs NQLMASTER - Dados do Especialista Juridico

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQL := FWFormStruct( 1, "NQL" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA015", /*Pre-Validacao*/, {|oX| JURA015TOK(oX)} /*Pos-Validacao*/, {|oX|JA015Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NQLMASTER", NIL, oStructNQL, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Especialista Juridico"
oModel:GetModel( "NQLMASTER" ):SetDescription( STR0009 ) //"Dados de Especialista Juridico"

JurSetRules( oModel, 'NQLMASTER',, 'NQL' )

Return oModel          

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA015TOK
Valida informações ao salvar.
Uso no cadastro Especialista Jurídico.

@param 	oModel  	oModel a ser verificado	
@Return lRet		.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 18/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA015TOK(oModel)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()

If nOpc == 5
	
	lRet := JurExcAnex ('NQL',oModel:GetValue("NQLMASTER","NQL_COD"))
		 
EndIf    

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA015Commit
Commit de dados de Especialista Juridico

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA015Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQLMASTER","NQL_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQL',cCod)
	EndIf

Return lRet