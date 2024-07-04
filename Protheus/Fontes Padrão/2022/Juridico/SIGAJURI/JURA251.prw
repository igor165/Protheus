#INCLUDE "JURA251.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
//------------------ -------------------------------------------------
/*/{Protheus.doc} JURA251
Tipo de Documento

@author Willian.Kazahaya
@since 23/01/2018  
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA251()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 )
oBrowse:SetAlias( "O0L" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "O0L" )
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

@author Willian.Kazahaya
@since 23/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA251", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA251", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA251", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA251", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA251", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Documentos

@author Willian.Kazahaya
@since 23/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA251" )
Local oStruct := FWFormStruct( 2, "O0L" )

oStruct:RemoveField( "O0L_COD" )
oStruct:RemoveField( "O0L_CPART" )

JurSetAgrp( 'O0L',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0001 )//"Tipo de Documentos"

oView:AddField( "JURA251_VIEW", oStruct , "O0LMASTER" )

oView:CreateHorizontalBox( "FORMMASTER", 100 )

oView:SetOwnerView( "O0LMASTER", "FORMMASTER" )

oView:AddUserButton( STR0009, "BUDGET", {| oView | J254Schedu()} )// "Criar Schedule" 

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Documentos

@author Willian.Kazahaya
@since 23/01/2018
@version 1.0

@obs O0LMASTER - Dados do Tipo de Documento

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructO0L := FWFormStruct( 1, "O0L" )
Local lWSTLegal  := JModRst()

	If lWSTLegal
		// Envia a sigla do participante para o TOTVS Legal
		oStructO0L:AddField( ;
			""                                , ;                                  // [01] Titulo do campo // "Sigla Part"
			""                                , ;                                  // [02] ToolTip do campo // "Sigla Part"
			'O0L__SIGLA'                      , ;                                  // [03] Id do Field
			'C'                               , ;                                  // [04] Tipo do campo
			6                                 , ;                                  // [05] Tamanho do campo
			0                                 , ;                                  // [06] Decimal do campo
			{|| .T.                         } , ;                                  // [07] Code-block de validação do campo // "Sigla Part"
			, ;                                                                    // [08] Code-block de validação When do campo
			, ;                                                                    // [09] Lista de valores permitido do campo
			.F.                               , ;                                  // [10] Indica se o campo tem preenchimento obrigatório
			{|| Posicione("RD0",1, xFilial("RD0")+M->O0L_CPART, "RD0_SIGLA") } , ;   // [11] Bloco de código de inicialização do campo.
			, ;                                                                    // [12] Indica se trata-se de um campo chave.
			, ;                                                                    // [13] Indica se o campo não pode receber valor em uma operação de update.
			.T. ;                                                                  // [14] Indica se o campo é virtual.
		)
	EndIf

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA251", /*Pre-Validacao*/, {|oX| JA251TOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "O0LMASTER", NIL, oStructO0L, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) //"Modelo de Dados de Tipo de Documentos"
	oModel:GetModel( "O0LMASTER" ):SetDescription( STR0001 ) //"Dados de Tipo de Documentos"

	JurSetRules( oModel, 'O0LMASTER',, 'O0L' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA251OK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Willian.Kazahaya
@since 26/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA251TOK(oModel)
Local lRet := .T.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J251VldSug(cQtdSugDia)
Valida o valor sugerido de dias

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Willian.Kazahaya
@since 01/03/2018
@version 1.0
@example J251VldSug(cQtdSugDia)
/*/
//-------------------------------------------------------------------
Function J251VldSug(cQtdSugDia)
Local lRet := .T.

	If cQtdSugDia < 0
		JurMsgErro("A sugestão de dias não pode ser negativa.")
		lRet := .F.
	EndIf
Return lRet                                                                                                      
