#INCLUDE "JURA064.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA064
Conf. Envio de E-mail

@author Ernani Forastieri
@since 01/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA064()
	Local oBrowse

	oBrowse := FWMBrowse():New() 
	oBrowse:SetDescription( STR0008 ) //"Conf. Envio de E-mail"
	oBrowse:SetAlias( "NRU" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "NRU" )
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

@author Ernani Forastieri
@since 01/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA064", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA064", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA064", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA064", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA064", 0, 8, 0, NIL } ) //"Imprimir"
	aAdd( aRotina, { STR0007, "VIEWDEF.JURA064", 0, 9, 0, NIL } ) //"Copiar"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Conf. Envio de E-mail

@author Ernani Forastieri
@since 01/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructNRU := FWFormStruct( 1, "NRU" )

	oModel:= MPFormModel():New( "JURA064", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "NRUMASTER", NIL, oStructNRU, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0009 ) //"Modelo de Dados de Conf. Envio de E-mail"
	oModel:GetModel( "NRUMASTER" ):SetDescription( STR0010 ) //"Dados de Conf. Envio de E-mail"

	JurSetRules( oModel, 'NRUMASTER',, 'NRU' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Conf. Envio de E-mail

@author Ernani Forastieri
@since 01/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView   := Nil
	Local oModel  := FWLoadModel( "JURA064" )
	Local oStruct := FWFormStruct( 2, "NRU" )

	JurSetAgrp( 'NRU',, oStruct )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA064_VIEW", oStruct, "NRUMASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA064_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0008 ) //"Conf. Envio de E-mail"
	oView:EnableControlBar( .T. )

	oView:AddUserButton( STR0014, 'BMPCPO'   , { | oView, oButton | JA64CPOSX3() } ) // "Campos"
	oView:AddUserButton( STR0015, 'SELECT'   , { | oView, oButton | JA64CPOINI() } ) // "Início Lista"
	oView:AddUserButton( STR0016, 'SELECTALL', { | oView, oButton | JA64CPOFIM() } ) // "Fim Lista"

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} JA64CPOSX3
Seleciona campos da SX3 para o corpo do e-mail

@author Ernani Forastieri
@since 01/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA64CPOSX3()
	Local cRet   := ''
	Local oModel := FWModelActive()

	If JURF3SX3( 'X3_ARQUIVO == "NXA"' )
		cRet := AllTrim( JURSX3->X3_CAMPO )
		If !oModel:SetValue( 'NRUMASTER', 'NRU_CORPO', oModel:GetValue( 'NRUMASTER', 'NRU_CORPO' ) + Chr( 171 ) + cRet + Chr( 187 ) )
			JurMsgErro( STR0011 ) //"Não foi possível atribuir o campo ao corpo do e-mail."
		EndIf
	EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA64CPOINI
Seleciona Inicio de Listapara o corpo do e-mail

@author Ernani Forastieri
@since 01/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA64CPOINI()
	If !JA64SIMLIS( Chr( 165 ) )
		JurMsgErro( STR0012 ) //"Não foi possível atribuir marca de inicio de lista corpo do e-mail."
	EndIf
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} JA64CPOFIM
Seleciona Final de Listapara o corpo do e-mail

@author Ernani Forastieri
@since 01/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA64CPOFIM()
	If !JA64SIMLIS( Chr( 166 ) )
		JurMsgErro( STR0013 ) //"Não foi possível atribuir marca de final de lista corpo do e-mail."
	EndIf
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} JA64SIMLIS
Rotina auxiliar de simbolos de Lista para o corpo do e-mail

@author Ernani Forastieri
@since 01/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA64SIMLIS( cChar )
	Local oModel := FWModelActive()
Return oModel:SetValue( 'NRUMASTER', 'NRU_CORPO', oModel:GetValue( 'NRUMASTER', 'NRU_CORPO' ) + cChar )

