#INCLUDE "JURA248.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA248
Prazo de estimativa de término

@author leandro.silva
@since 02/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA248()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )      //Prazo de estimativa de término
	oBrowse:SetAlias( "O0D" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O0D" )
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

@author leandro.silva
@since 02/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA248", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA248", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA248", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA248", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA248", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Prazo de estimativa de término

@author leandro.silva
@since 02/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  	 := FWLoadModel( "JURA248" )
	Local oStructO0D := FWFormStruct( 2, "O0D" )
	Local oStructNT9 := Nil
	
		
	JurSetAgrp( 'O0D',, oStructO0D )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 )		//"Prazo de estimativa de término" 													 
	
	oView:AddField( "JURA248_FIELD", oStructO0D, "O0DMASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100)
	oView:SetOwnerView( "JURA248_FIELD", "FORMFIELD" )
	oView:EnableTitleView( "JURA248_FIELD"  )
	
	oView:EnableControlBar( .T. )
	
	/*//Adiciona quebra de linha para melhor posicionar os campos do agrupamento de Valores
	If oStructO0D:HasField("O0D_TIPOAS")
    	oStructO0D:SetProperty('O0D_DASSJ',MVC_VIEW_INSERTLINE,.T.)
   	Endif
         */

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Prazo de estimativa de término

@author leandro.silva
@since 02/01/2018
@version 1.0

@obs O0DMASTER - Dados do Prazo de estimativa de término
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := NIL
	Local oStructO0D := FWFormStruct( 1, "O0D" )
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA248", /*Pre-Validacao*/, {|oX| JA248OK(oX)}, /*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0007 )		//"Modelo de Dados"                 			
	
	oModel:AddFields( "O0DMASTER", NIL, oStructO0D, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "O0DMASTER" ):SetDescription( STR0009 ) 	     //"Dados do Prazo de Estimativa de Término" 		
	JurSetRules( oModel, 'O0DMASTER',, 'O0D' ) 						
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA248TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author leandro.silva
@since 03/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA248OK(oModel)
Local lRet      := .T.
Local aArea     := GetArea()
Local cAssu     := FwFldGet('O0D_TIPOAS')
Local cArea     := FwFldGet('O0D_CAREAJ')
Local cAto      := FwFldGet('O0D_CATO')
Local cObj      := FwFldGet('O0D_COBJET')

	If oModel:GetOperation() == 3 .or. oModel:GetOperation() == 4
		
		O0D->( dbSetOrder(2) )
		
		IF (O0D->( dbSeek(xFilial("O0D")+cAssu + cArea + cAto + cObj) )) .And. oModel:GetModel("O0DMASTER"):GetDataID() <> O0D->( Recno() )
			lRet := .F.
			JurMsgErro(STR0008,,STR0010) //"Já existem registros com as informações utilizadas"
		EndIF   
		   
	Endif
		
Return(lRet)