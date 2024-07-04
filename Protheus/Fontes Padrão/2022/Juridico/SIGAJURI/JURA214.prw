#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "JURA214.CH"
#INCLUDE "TRYEXCEPTION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA214
Campos complementares Auditados

@author Rafael Tenorio da Costa
@since 28/11/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA214()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "O0B" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O0B" )
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
@since 28/11/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA214", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA214", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA214", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA214", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA214", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decisão

@author Rafael Tenorio da Costa
@since 28/11/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  := FWLoadModel( "JURA214" )
	Local oStruct := FWFormStruct( 2, "O0B" )
	
	JurSetAgrp( 'O0B',, oStruct )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA214_VIEW", oStruct, "O0BMASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA214_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) 					//"Campos complementares NV3"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author Rafael Tenorio da Costa
@since 28/11/17
@version 1.0

@obs O0BMASTER - Campos complementares NV3
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := NIL
	Local oStructO0B := FWFormStruct( 1, "O0B" )
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA214", /*Pre-Validacao*/, {|oModel| J214PosVal(oModel)}/*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields( "O0BMASTER", NIL, oStructO0B, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) 							//"Modelo de Dados dos campos complementares NV3"
	oModel:GetModel( "O0BMASTER" ):SetDescription( STR0009 ) 	//"Dados dos campos complementares NV3"
	
	JurSetRules( oModel, 'O0BMASTER', , 'O0B' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J214PosVal
Efetua as pos-valições do model 

@return	 oModel
@author  Rafael Tenorio da Costa
@since   30/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J214PosVal(oModel)

	Local aArea		:= GetArea()
	Local aAreaO0B	:= O0B->( GetArea() )
	Local lRetorno	:= .T.
	Local nOpc      := oModel:GetOperation()
	
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	
		O0B->( DbSetOrder(1) )	//O0B_FILIAL+O0B_CAMPO+O0B_FORMUL
		If O0B->( DbSeek(xFilial("O0B") + FwFldGet("O0B_CAMPO") + FwFldGet("O0B_FORMUL")) ) .And. oModel:GetModel("O0BMASTER"):GetDataID() <> O0B->( Recno() )
			lRetorno := .F.
			JurMsgErro(STR0011)		//"Configuração já existe"
		EndIf
		
		If lRetorno .And. Empty( FwFldGet("O0B_CAMPO") ) .And. Empty( FwFldGet("O0B_FORMUL") )
			lRetorno := .F.
			JurMsgErro(STR0012)		//"Configure o Campo ou Formula"
		EndIf
	EndIf
	
	RestArea(aAreaO0B)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J214VldCmp
Valida o campo

@author  Rafael Tenorio da Costa
@since 	 30/11/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J214VldCmp(cCampo, xConteudo)

	Local aArea		 := GetArea()
	Local lRetorno 	 := .T.
	Local xResultado := Nil
	Local oError	 := Nil
	
	DbSelectArea("NSZ")
	NSZ->( DbSetOrder(1) )	//NSZ_FILIAL+NSZ_COD
	
	xConteudo := AllTrim(xConteudo)
	
	If !Empty(xConteudo)
	
		//"O0B_CAMPO"
		If cCampo == "O0B_CAMPO"
		
			If Left(xConteudo, 3) <> "NSZ" .Or. !ExistCpo("SX3", xConteudo, 2)
				lRetorno := .F.
			EndIf
		
		//"O0B_FORMUL"
		Else
		
			TRY EXCEPTION
				//Condição que pode dar erro
				xResultado := &(xConteudo)
			CATCH EXCEPTION USING oError
				//Se ocorreu erro
				xResultado := Nil
			END TRY
	
			If ValType(xResultado) == "U" .Or. ValType(xResultado) == "O" .Or. ValType(xResultado) == "A"
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	
	If !lRetorno
		JurMsgErro(STR0010)		//"Campo inválido"
	EndIf
	
	RestArea(aArea)
		
Return lRetorno
