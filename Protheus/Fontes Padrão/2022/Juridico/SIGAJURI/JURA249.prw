#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "JURA249.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA249
Cadastro das Marcas da Auditoria

@author Rafael Tenorio da Costa
@since 03/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA249()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )	//"Marcas da Auditoria"
	oBrowse:SetAlias( "O0E" )
	oBrowse:SetLocate()
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

@author Rafael Tenorio da Costa
@since 03/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        					, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA249"					, 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA249"					, 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "J249Manut(4, '" + STR0004 + "')"	, 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "J249Manut(5, '" + STR0005 + "')"	, 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA249"					, 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decisão

@author Rafael Tenorio da Costa
@since 03/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  := FWLoadModel( "JURA249" )
	Local oStruct := FWFormStruct( 2, "O0E" )
	
	JurSetAgrp( 'O0E',, oStruct )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA249_VIEW", oStruct, "O0EMASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA249_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) 					//"Marcas da Auditoria"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author Rafael Tenorio da Costa
@since 03/01/18
@version 1.0

@obs O0EMASTER - Marcas da Auditoria
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := NIL
	Local oStructO0E := FWFormStruct( 1, "O0E" )
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA249", /*Pre-Validacao*/, {|oModel| J249PosVal(oModel)}/*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields( "O0EMASTER", NIL, oStructO0E, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) 							//"Modelo de Dados das Marcas da Auditoria"
	oModel:GetModel( "O0EMASTER" ):SetDescription( STR0009 ) 	//"Dados das Marcas da Auditoria"
	
	JurSetRules( oModel, 'O0EMASTER', , 'O0E' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J249PosVal
Efetua as pos-valições do model 

@return	 oModel
@author  Rafael Tenorio da Costa
@since   03/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J249PosVal(oModel)

	Local aArea		:= GetArea()
	Local aAreaO0E	:= O0E->( GetArea() )
	Local lRetorno	:= .T.
	Local nOpc      := oModel:GetOperation()
	LocaL lProcessa := .F.
	
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	
		O0E->( DbSetOrder(1) )	//O0E_FILIAL+DTOS(O0E_MARCA)
		If O0E->( DbSeek( xFilial("O0E") + DtoS( FwFldGet("O0E_MARCA") ) ) ) .And. oModel:GetModel("O0EMASTER"):GetDataID() <> O0E->( Recno() )
			lRetorno := .F.
			JurMsgErro(STR0010)		//"Marca já existe"
		EndIf
	EndIf
	
	If nOpc == MODEL_OPERATION_DELETE
	
		If JurAuto() 
			lProcessa := .T.
		Else
			lProcessa := MsgYesNo(STR0012)
		EndIf

		If lProcessa //"Existe auditoria gerada com esta marca, deseja mesmo excluir a marca ?"
			Processa( {| | J112aExcAu("O0F", FwFldGet("O0E_MARCA"))}, STR0014)	//"Excluindo auditoria de Processo"
			Processa( {| | J112aExcAu("O0G", FwFldGet("O0E_MARCA"))}, STR0015)	//"Excluindo auditoria de Objeto"
			Processa( {| | J112aExcAu("O0H", FwFldGet("O0E_MARCA"))}, STR0016)	//"Excluindo auditoria de Garantia"
			Processa( {| | J112aExcAu("O0I", FwFldGet("O0E_MARCA"))}, STR0017)	//"Excluindo auditoria de Despesa"

			If FWAliasIndic("O0Y")
				Processa( {| | J112aExcAu("O0Y", FwFldGet("O0E_MARCA"))}, STR0018)	//"Excluindo auditoria de Pedidos"
			EndIf
		Else
			lRetorno := .F.
			JurMsgErro(STR0013)		//"Operação cancelada, marca não será excluída"		
		EndIf
	EndIf
	
	RestArea(aAreaO0E)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J249Manut
Efetua pré validações antes das operações de alteração e exclusão  

@return	 oModel
@author  Rafael Tenorio da Costa
@since   04/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J249Manut(nOpc, cTitTela)

	Local aArea := GetArea()

	//Verifica se a marca esta fechada e se é alteração\exclusão
	If O0E->O0E_STATUS == "2" .And. ( nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE ) 
		JurMsgErro(STR0011)		//"Operação não permitida, marca já esta fechada"	
	Else
		FWExecView(cTitTela, "JURA249", nOpc, , {|| .T.})
	EndIf

	RestArea( aArea )

Return Nil
