#INCLUDE "JURA257.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA257
De / Para Ato Processual

@author Beatriz Gomes
@since 15/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA257()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 ) //Ato Processual Automatico para Publicação
	oBrowse:SetAlias( "O0O" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O0O" )
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

@author Beatriz Gomes
@since 16/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA257", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA257", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA257", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA257", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA257", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Prazo de estimativa de término

@author Beatriz Gomes
@since 16/01/2018
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel     := FWLoadModel( "JURA257" )
	Local oStructO0O := FWFormStruct( 2, "O0O" )
	Local oStructO0P := FWFormStruct( 2, "O0P" )

	If (oStructO0P:HasField( "O0P_CATOAU" ))
		oStructO0P:RemoveField('O0P_CATOAU')
	Endif
	 
	JurSetAgrp( 'O0O',, oStructO0O)
	
	oView := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 ) 
	
	oView:AddField( "JURA257_MASTER" , oStructO0O, "O0OMASTER"  )
	oView:AddGrid(  "JURA257_DETAIL" , oStructO0P, "O0PDETAIL" )
	
	oView:CreateHorizontalBox( "FORMMASTER" , 30 )
	oView:CreateHorizontalBox( "FORMDETAIL" , 70 )
		
	oView:SetOwnerView( "O0OMASTER" , "FORMMASTER" )
	oView:SetOwnerView( "O0PDETAIL" , "FORMDETAIL" )
	
	 oView:AddIncrementField("O0PDETAIL", "O0P_COD")
	
	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Prazo de estimativa de término

@author Beatriz Gomes
@since 15/02/2018
@version 1.0

@obs O0OMASTER - Ato Processual 
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructO0O := FWFormStruct( 1, "O0O" )
	Local oStructO0P := FWFormStruct( 1, "O0P" )
	Local lTLegal    := JModRst()
	Local bPosVld    := {|oMdl| ModelPosValid(oMdl)}

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA257", /*Pre-Validacao*/,bPosVld /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0007 )//"Modelo de Dados"
	
	If lTLegal
		oStructO0P:SetProperty('O0P_COD', MODEL_FIELD_INIT, {|oMdl|getsxenum('O0P','O0P_COD', cEmpAnt + cFilAnt + oMdl:GetModel():GetModel('O0OMASTER'):GetValue('O0O_COD'))})
	Endif

	//Atualiza validação do campo
	oStructO0P:SetProperty("O0P_COD", MODEL_FIELD_VALID, {|| ExistChav("O0P", FwFldGet("O0P_CATOAU") + FwFldGet("O0P_COD"), 1)})

	oModel:AddFields( "O0OMASTER", /*NIL*/, oStructO0O, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:AddGrid( "O0PDETAIL", "O0OMASTER" /*cOwner*/, oStructO0P, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

	oModel:GetModel("O0OMASTER"):SetDescription( STR0008 )  //"Regra do Follow-up Automático
	oModel:GetModel("O0PDETAIL"):SetDescription( STR0009  ) //modelos disparados
	
	If !lTLegal
		oModel:GetModel("O0PDETAIL"):SetUniqueLine( {"O0P_CPCHAV"} )
	EndIf
	
	oModel:SetRelation("O0PDETAIL", {{"O0P_FILIAL", "XFILIAL('O0P')" }, {"O0P_CATOAU", "O0O_COD" }}, O0P->( IndexKey( 1 ))) 
	
	oModel:GetModel("O0PDETAIL"):SetDelAllLine( .T. ) 
		
	JurSetRules( oModel, "O0PDETAIL",, "O0P" )
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Validação do modelo de dados

@param oModel, object, modelo de dados
@return lRet, retorno lógico
@since 08/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet := .T.

	If oModel:GetModel('O0OMASTER'):HasField('O0O_QTDOPC')
		lRet := VldQtdOpc(oModel)
	Endif


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Validação de quantidade de campos opcionais

@param oModel, object, modelo de dados
@return lRet, retorno lógico
@since 08/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldQtdOpc(oModel)
Local lRet    := .T.
Local oMdlO0O := oModel:GetModel('O0OMASTER')
Local oMdlO0P := oModel:GetModel('O0PDETAIL')
Local nQtdOpc := oMdlO0O:GetValue('O0O_QTDOPC')
Local nQtdAux := 0
Local n1      := 0

	//Se tiver informado o campo, valida a quantidade de campos opcionais
	If nQtdOpc > 0

		For n1 := 1 to oMdlO0P:Length()
			If !oMdlO0P:isDeleted(n1) .and. oMdlO0P:GetValue('O0P_OBRIGA', n1) == '2'
				nQtdAux++
			Endif
			//Se Encontrar mais palavras opcionais que o exigido, ja retorna verdadeiro
			If nQtdAux >= nQtdOpc
				exit
			Endif
		Next

		//Valida se possui menos palavras opcionais do que o exigido
		If nQtdAux < nQtdOpc
			lRet := .F.
			oModel:SetErrorMessage(oMdlO0O:GetId(),'O0O_QTDOPC',oMdlO0P:GetId(),'O0P_OBRIGA','VldQtdOpc', STR0011)//'O número de palavras opcionais listados é menor que a quantidade mínima de palavras opcionais'
		Endif

	Endif

Return lRet
