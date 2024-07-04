#include 'AGRA060.CH'
#include 'protheus.ch'
#include "fwmvcdef.ch"
#include "totvs.ch"

Static __aTab1220 := {"N8E"} //Release na 1220
Static __lLib1220 := Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRA060  º Autor ³ Ricardo Tomasi     º Data ³  21/07/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Tabela de Conversão de Unidades de Medida.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGRA060()
	Local oMBrowse := Nil
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NNX" )
	oMBrowse:SetMenuDef( "AGRA060" )
	oMBrowse:SetDescription( STR0001 ) //"Tabela de Conversão de Unidade de medidas"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return()


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA410 - Componentes de Preço
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.AGRA060", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "ViewDef.AGRA060", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005, "ViewDef.AGRA060", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006, "ViewDef.AGRA060", 0, 5, 0, Nil } ) //"Excluir"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Marlon Richard Trettin
@since: 	30/07/2014
@Uso: 		OGA410 - Componentes de Preço
*/
Static Function ModelDef()
	Local oStruNNX	:= FWFormStruct( 1, "NNX" )
	Local oStruN8E  := nil
	Local oModel


	If __lLib1220 == nil
		__lLib1220 := AGRTABDIC(__aTab1220) //verifica se array de tabelas existe no dicionario de dados - para proteção fonte SLC
	Endif	
	
	//Remove campo da tela
	if __lLib1220
		oStruN8E	:= FWFormStruct( 1, "N8E" )
		oStruNNX:SetProperty( 'NNX_FATOR', MODEL_FIELD_OBRIGAT, .f. )
		oStruN8E:RemoveField( "N8E_UMORIG" )
		oStruN8E:RemoveField( "N8E_UMDEST" )
	EndIF

	oModel:= MPFormModel():New( "AGRA060" , ,{| oModel | PosModelo( oModel ) })
	oModel:SetDescription( STR0007 ) //Dados Para conversão de Unidades de medida'                                                                                                                                                                                                                                                                                                                                                                                                                                                                        

	oModel:AddFields( "NNXMASTER", /*cOwner*/, oStruNNX, , /*bPost*/, /*bLoad */  )
	oModel:SetPrimaryKey( { "NNX_FILIAL", "NNX_UMORIG", "NNX_UMDEST" } )
	oModel:GetModel( "NNXMASTER" ):SetDescription( STR0007 ) //"Conversão de Unidades de Medida""

	IF __lLib1220
		oModel:AddGrid( "N8EDETAIL", "NNXMASTER", oStruN8E, {|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValLin(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)} /*bLinePre*/, /*bLinePost*/{|oModelGrid| fVallinN8E(oModelGrid)} , /*bPre*/,  /*bPost*/, /*bLoad*/ )
		oModel:GetModel( "N8EDETAIL" ):SetUniqueLine( { "N8E_ITEM" } )
		oModel:GetModel( "N8EDETAIL" ):SetOptional( .t. )
		oModel:SetRelation( "N8EDETAIL", { { "N8E_FILIAL", "xFilial( 'N8E' )" }, {"N8E_UMORIG", "NNX_UMORIG" }, { "N8E_UMDEST", "NNX_UMDEST" } }, N8E->( IndexKey( 1 ) ) )
		oModel:GetModel( "N8EDETAIL" ):SetDescription( STR0008 ) //"Fator de conversão por O produto"
	EndIF

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	AGRO
@since: 	05/12/2017
@Uso: 		AGRA060
*/
Static Function ViewDef()

	Local oStruNNX	:= FWFormStruct( 2, "NNX" )
	Local oStruN8E	:= nil
	Local oModel   	:= FWLoadModel( "AGRA060" )
	Local oView    	:= FWFormView():New()

	If __lLib1220 == nil
		__lLib1220 := AGRTABDIC(__aTab1220) //verifica se array de tabelas existe no dicionario de dados - para proteção fonte SLC
	Endif	

	IF __lLib1220
	    oStruN8E	:= FWFormStruct( 2, "N8E" )
		oStruN8E:RemoveField( "N8E_UMORIG" )
		oStruN8E:RemoveField( "N8E_UMDEST")
	End-IF

	oView:SetModel( oModel )
	oView:AddField( "VIEW_NNX", oStruNNX, "NNXMASTER" )
	
	
	IF __lLib1220
		oView:AddGrid( "VIEW_N8E" , oStruN8E, "N8EDETAIL" )
		oView:AddIncrementField( "VIEW_N8E", "N8E_ITEM" )
	
		oView:CreateVerticallBox( "TELANOVA" , 100 )
		oView:CreateHorizontalBox( "SUPERIOR" , 40, "TELANOVA" )
		oView:CreateHorizontalBox( "INFERIOR" , 60, "TELANOVA" )
		oView:SetOwnerView( "VIEW_NNX", "SUPERIOR" )
		oView:SetOwnerView( "VIEW_N8E", "INFERIOR" )
	EndIF


	oView:EnableTitleView( "VIEW_NNX" )
	IF __lLib1220
		oView:EnableTitleView( "VIEW_N8E" )
	EndIF	

	oView:SetCloseOnOk( {||.t.} )

Return( oView )




/** {Protheus.doc} fVallinN8E
Pos modelo validações

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    EC
@since:     05/12/17
@Uso:       fVallinN8E - Componente de Preço
*/
Static Function fVallinN8E( oModel )
	Local lRet 			:= .t.
	Local cProduto		:= oModel:GETVALUE('N8E_PRODUT')
	Local nFator		:= oModel:GETVALUE('N8E_FATOR')

	IF !Empty(cProduto) .or. nfator > 0
		Do Case
			Case Empty(cProduto)
			lRet := .f.
			Case nFator == 0
			lRet := .f.
		EndCase
		Help('',1,"AGRA060N8E")  
		//Help( ,, 'STR0012',,'Fator de conversão/produto invalido.É necessario informar o produto e o fator de conversão', 1, 0,)
	EndIF
Return(lret)


/** {Protheus.doc} 
Valida o Produto

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    EC
@since:     05/12/17
@Uso:       AGR060VPRO - Componente de Preço
*/
Function AGR060VPRO()
	Local oModel 		:= FWModelActive() 				// Obtém o Model Ativo
	Local oModelN8E 	:= nIl
	Local lJaTemProd	:= .f.
	Local cProd			:= ''
	Local nX			:= 0
	Local nlineAtu		:= 0
	Local aSaveLines	:= {}	
	lRet 				:= .t.


	IF ! VALTYPE(oModel) = 'U' .and. oModel:GetId()='AGRA060'
		oModelN8E 	:= oModel:GetModel("N8EDETAIL")
	Else
		Return .f.
	End-IF

	nLineAtu 	:= oModelN8E:GetLine()
	cProd 		:=  oModelN8E:GetValue('N8E_PRODUT', nLineAtu  )

	aSaveLines := FWSaveRows()

	For nX := 1 to oModelN8E:Length()
		oModelN8E:GoLine( nX )
		IF .Not. oModelN8E:IsDeleted() .and. .not. Nx = nLineAtu 
			IF AllTrim(oModelN8E:GetValue('N8E_PRODUT', nX ))== Alltrim(cProd)
				lJaTemProd := .t.
			EndIF
		EndIF
	Next nX
	FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids
	
	IF lJatemProd
		Help('',1,"AGRA060PROD") 
		//Help( ,, 'STR0012',, 'Não é possivel inserir mais de um fator de conversão para o mesmo produto. Insira outro produto', 1, 0,)
	    lRet := .f.
	EndIF
Return ( lRet )


	/*/{Protheus.doc} PreValLin(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
	Rotina de Pre validação do modelo COO(Solicitações)

	@author alexandre.gimenez
	@param oModelGrid Modelo
	@param nLinha Linha corrente
	@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
	@param cCampo Campo atualizado
	@param Vr. inserido no Campo
	@param Vr. que do Cpos antes da Inserção do novo vr.
	@return lRet
	@since 12/09/2013
	@version 1.1
	/*/
//------------------------------------------------------------------
Static Function PreValLin(oModelN8E, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	Local oModel        	:= FWModelActive()
	Local nOperation 		:= oModel:GetOperation()
	Local aSaveLines     	:= FWSaveRows()
//	Local oView				:= FwViewActive()
	Local lContinua			:=.t.
	Local nI				:= 0
	Local lJaTemProd		:=.f.

	IF lContinua .and. cAcao == 'UNDELETE'
		cProd 		:=  oModelN8E:GetValue('N8E_PRODUT', nLinha  )

		aSaveLines     	:= FWSaveRows()

		For nI := 1 to oModelN8E:Length()
			oModelN8E:GoLine( nI )
			IF .Not. oModelN8E:IsDeleted() 
				IF AllTrim(oModelN8E:GetValue('N8E_PRODUT', nI ))== Alltrim(cProd)
					lJaTemProd := .t.
				EndIF
			EndIF
		Next nX
		FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids

		IF lJatemProd
			Help('',1,"AGR060UNDL")
			//Help( ,, 'STR0012',, 'Não é possivel retornar a linha deletada. Produto já existe  no grid. Para retornar esta linha delete a linha com o mesmo porduto do grid.', 1, 0,)
			lcontinua := .f.
		EndIF
		
	EndIF

Return (lContinua)



/** {Protheus.doc} PosModelo
Pos modelo validações

@return:    lRetorno - .T. verdadeiro ou .F. falso
@author:    EC
@since:     05/12/17
@Uso:       PosModelo - Componente de Preço
*/
Static Function PosModelo( oModel )
	Local nOperation   	:= oModel:GetOperation()
	Local oModelNNX 	:= oModel:GetModel( "NNXMASTER" )
	Local oModelN8e		:= nil
	Local lRet			:= .T.
	Local cUMOrig		:= oModelNNX:GetValue('NNX_UMORIG')
	Local cUMDest		:= oModelNNX:GetValue('NNX_UMDEST')
	Local aSaveLines	:= {}
	Local nI			:= 0
	Local lFatorN8E     := .f.   

	Local aAreaAtu 		:= GetArea()
	Local aAreaNNX 		:= NNX->(GetArea())

	IF __lLib1220
		oModelN8E			:= oModel:GetModel( "N8EDETAIL" )
		aSaveLines 			:= FWSaveRows() 		// Salva a posição de todos os Grids
	EndIF

	If nOperation == MODEL_OPERATION_INSERT	
		NNX->( dbSetOrder( 1 ) )			
		If NNX->( dbSeek( fWxFilial( 'NNX' ) + cUMORIG + cUMDEST ) )
			Help('',1,"AGRA060NNX")  //"HELP"##"Já existe fator de conversão cadastrado para as unidades de medidas informadas. ###Verifique no brose o registro referente as unidades de medidas informadas."
			lRet := .f.
		EndIF
	EndIF

	IF __lLib1220 .and. lRet	
		For nI := 1 To oModelN8E:Length()
			oModelN8E:GoLine( nI )
			IF oModelN8E:IsDeleted()
				Loop
			EndIF
			IF oModelN8E:GetValue('N8E_FATOR') > 0
				lFatorN8e := .t.
				exit
			EndIF
		Next nI
		FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids
	EndIF

	IF Empty( oModelNNX:Getvalue('NNX_FATOR') ) .AND. ! lFatorN8E
		Help('',1,"AGRA060NNX1")  //"HELP"##'Fator de Conversão não Informado.###Favor informar fator de conversão'
		lRet := .f.
	EndIF
	
	 RestArea( aAreaAtu )
	 RestArea( aAreaNNX )
	
Return( lRet )    
