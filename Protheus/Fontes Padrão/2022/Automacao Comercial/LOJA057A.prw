#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA057A.CH'

//--------------------------------------------------------
/*/{Protheus.doc} LOJA057A
Cadastro de conferência de caixa.
Utilizado para gravações via EAI.
@type function
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return	    Nil
/*/
//--------------------------------------------------------
Function LOJA057A(aAutoCab, aAutoItens, nOpcAuto)

Local	oBrowse		:= Nil
Local   lRotAuto 	:= aAutoCab <> Nil	   //Cadastro por rotina automatica
Private aRotina 	:= MenuDef()       		// Array com os menus disponiveis

Default aAutoCab 	:= {}
Default aAutoItens	:= {}
Default nOpcAuto	:= 3

If lRotAuto
	FWMVCRotAuto(ModelDef(), "SLW", nOpcAuto, {{"SLWMASTER", aAutoCab}, {"SLTDETAIL", aAutoItens}})	
Else
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'SLW' )
	oBrowse:SetDescription( STR0001 ) //"Conferência de Caixa"
	oBrowse:Activate()
EndIf	

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef MVC
@type function
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return	    aRotina - Rotinas disponiveis
/*/
//--------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina, { STR0002	, 'VIEWDEF.LOJA057A', 0, 2, 0, NIL } )//"Visualizar"
aAdd( aRotina, { STR0003 	, 'VIEWDEF.LOJA057A', 0, 3, 0, NIL } )//"Incluir" 
aAdd( aRotina, { STR0004 	, 'VIEWDEF.LOJA057A', 0, 4, 0, NIL } )//"Alterar" 
aAdd( aRotina, { STR0005	, 'VIEWDEF.LOJA057A', 0, 5, 0, NIL } )//"Excluir"
aAdd( aRotina, { STR0006 	, 'VIEWDEF.LOJA057A', 0, 8, 0, NIL } )//"Imprimir" 
aAdd( aRotina, { STR0007 	, 'VIEWDEF.LOJA057A', 0, 9, 0, NIL } )//"Copiar"

Return aRotina


//--------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef MVC
@type function
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return	    oModel - modelo de dados
/*/
//--------------------------------------------------------
Static Function ModelDef()

Local oStruSLW 	:= FWFormStruct( 1, 'SLW' ) // Cria as estruturas a serem usadas no Modelo de Dados
Local oStruSLT 	:= FWFormStruct( 1, 'SLT' )	// Cria as estruturas a serem usadas no Modelo de Dados
Local oModel 	:= Nil						// Modelo de dados construído

oModel := MPFormModel():New( 'LOJA057A') // Cria o objeto do Modelo de Dados

oModel:AddFields( 'SLWMASTER', /*cOwner*/, oStruSLW )// Adiciona ao modelo um componente de formulário

oModel:AddGrid( 'SLTDETAIL', 'SLWMASTER', oStruSLT )// Adiciona ao modelo uma componente de grid

oModel:SetRelation( 'SLTDETAIL', { { 'LT_FILIAL', 'xFilial( "SLT" )' }, { 'LT_DTMOV', 'LW_DTABERT' }, { 'LT_OPERADO', 'LW_OPERADO' }, ;
								   { 'LT_NUMMOV', 'LW_NUMMOV' }, { 'LT_PDV', 'LW_PDV' } }, SLT->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0001 )//"Conferência de Caixa"
oModel:GetModel( 'SLWMASTER' ):SetDescription( STR0008 )//"Movimento Processos de Venda"
oModel:GetModel( 'SLTDETAIL' ):SetDescription( STR0001 )//"Conferência de Caixa" 

Return oModel


//--------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef MVC
@type function
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return	    ViewDef - View do modelo
/*/
//--------------------------------------------------------
Static Function ViewDef()

Local oModel   	:= FWLoadModel( 'LOJA057A' )
Local oStruSLW 	:= FWFormStruct( 2, 'SLW' )
Local oStruSLT 	:= FWFormStruct( 2, 'SLT' )
Local oView		:= Nil    

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_SLW', oStruSLW, 'SLWMASTER' )
oView:AddGrid(  'VIEW_SLT', oStruSLT, 'SLTDETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 25 )
oView:CreateHorizontalBox( 'INFERIOR', 75 )

oView:SetOwnerView( 'VIEW_SLW', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_SLT', 'INFERIOR' )

Return oView


//--------------------------------------------------------
/*/{Protheus.doc} IntegDef
Rotina padrão para integração via mensagem unica
@type function
@param 		cXml, XML recebido pelo EAI Protheus
@param 		nType, Tipo de transação ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param 		cTypeMsg, Tipo da mensagem do EAI 
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return	    aRet - Array de retorno da execução 
/*/
//--------------------------------------------------------
Static Function IntegDef( cXml, nTypeTrans, cTypeMessage )

Local aRet := {} 

Default cXml			:= ""
Default nTypeTrans 		:= 0
Default cTypeMessage	:= ""

aRet:= LOJI057A(cXml, nTypeTrans, cTypeMessage)

Return aRet

