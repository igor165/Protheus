#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA917.ch'


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA917()
Logs de Importação - TEF

@type Function

@author Igor Fricks
@since 09/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA917()
	Local oBrowse As Object

	oBrowse := BrowseDef()
	oBrowse:Activate()

	Return

	//-------------------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} BrowseDef()
	Define o browse padrão para o cadastro de justificativas

	@type Function

	@author Igor Fricks
	@since 09/06/2018
	@version P12.1.17

	/*/
	//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef() As Object
	Local oBrowse As Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'FVR' )
	oBrowse:SetDescription( STR0001 )
	// Retirar o botão de Impressão
	// oBrowse:lOptionReport:=.F.
	oBrowse:AddLegend("FVR_STATUS == '0'","GREEN" 	,STR0004) //'Importado com sucesso'
	oBrowse:AddLegend("FVR_STATUS == '1'","RED"   	,STR0005) //'Arquivo já importado'
	oBrowse:AddLegend("FVR_STATUS == '2'","WHITE" 	,STR0006) //'Versão do arquivo imcompativel'
	oBrowse:AddLegend("FVR_STATUS == '3'","BROWN" 	,STR0007) //'Falha na abertura do arquivo'
	oBrowse:AddLegend("FVR_STATUS == '4'","YELLOW"	,STR0008) //'Importado parcialmente'
	oBrowse:AddLegend("FVR_STATUS == '5'","BLACK" 	,STR0009) //'Arquivo Inconsistente'
	oBrowse:AddLegend("FVR_STATUS == '6'","BLUE"  	,STR0010) //'Arquivo não Importado'
	oBrowse:AddLegend("FVR_STATUS == '7'","PINK" 	,STR0014) //'PIX - Falha na conexão com a API'
	oBrowse:AddLegend("FVR_STATUS == '8'","ORANGE"  ,STR0015) //'PIX - Falha de direitos'

	Return oBrowse

	//-------------------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ModelDef()
	Cria a estrutura a ser usada no Modelo de Dados

	@type Function

	@author Igor Fricks
	@since	09/06/2018
	@version P12.1.19
	/*/
	//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oStruFVR As Object
	Local oStruFV3 As Object
	Local oModel   As Object
	// Monta a estrutura do form conforme dicionário
	oStruFVR := FWFormStruct( 1, 'FVR' )
	oStruFV3 := FWFormStruct( 1, 'FV3' )

	oModel := MPFormModel():New('FINA917')

	oModel:AddFields( 'FVRMASTER', /*cOwner*/, oStruFVR)

	// Adiciona ao modelo estrutura de formulário de edição de grid
	oModel:AddGrid('FV3DETAIL','FVRMASTER',oStruFV3, /*bLinePre*/,,/*bPosValidacao*/ , /*BLoad*/)

	// Faz relacionamento entre componentes do model
	oModel:SetRelation('FV3DETAIL',{{'FV3_FILIAL','FVR_FILIAL'},{'FV3_IDPROC','FVR_IDPROC'}},FV3->(IndexKey(1))) //FV3_FILIAL+FV3_IDPROC+FV3_LINARQ

	oModel:SetDescription( STR0001 ) //'Logs Importação Sitef'
	// Adiciona a Descrição do componente do Modelo de Dados
	oModel:GetModel( 'FVRMASTER' ):SetDescription( STR0001 ) //'Logs Importação Sitef'
	oModel:GetModel( 'FV3DETAIL' ):SetDescription( STR0011 ) // Log Importação Sitef - Detalhe'

	// Validação para criação do model
	oModel:SetVldActivate( {|oModel| A917VLMod(oModel) } )

	// Define a inserção de um item no grid como opcional
	oModel:GetModel( 'FV3DETAIL'):SetOptional(.T.)

	// Configura grid para não permitir exclusão de linha
	oModel:GetModel("FV3DETAIL"):SetNoDeleteLine(.T.)

	// Configura grid para não permitir inclusão de linha
	oModel:GetModel("FV3DETAIL"):SetNoInsertLine(.T.)

	// Configura grid para não permitir alteração da linha
	oModel:GetModel("FV3DETAIL"):SetNoUpdateLine(.T.)

	// Define a chave unica da grid
	oModel:GetModel("FV3DETAIL"):SetUniqueLine({"FV3_FILIAL","FV3_IDPROC","FV3_LINARQ"})

	Return oModel

	//-------------------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ViewDef()
	Definição de View do Sistema

	@type Function

	@author Igor Fricks
	@since 09/06/2018
	@version P12.1.17
	/*/
	//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel 	As Object
	Local oStruFVR 	As Object
	Local oView 	As Object

	oModel   := FWLoadModel( 'FINA917' )
	oStruFVR := FWFormStruct( 2, 'FVR' )
	oStruFV3 := FWFormStruct( 2, 'FV3' )

	oStruFVR:RemoveField('FVR_STATUS')
	oStruFVR:RemoveField('FVR_IDPROC')
	oStruFVR:RemoveField('FVR_CODUSU')
	oStruFVR:RemoveField('FVR_CODOPE')

	// Remove campos do Field
	oStruFV3:RemoveField("FV3_IDPROC")
	oStruFV3:RemoveField("FV3_NOMARQ")
	oStruFV3:RemoveField("FV3_DTPROC")
	oStruFV3:RemoveField("FV3_HRPROC")

	// Cria Objeto da View
	oView := FWFormView():New()
	// Define qual o Modelo de dados
	oView:SetModel( oModel )
	// Adiciona a view de controle do tipo FormFields
	oView:AddField( 'VIEW_FVR', oStruFVR, 'FVRMASTER' )

	// Adiciona a view de controle do tipo FormGrid
	oView:AddGrid( 'VIEW_FV3', oStruFV3, 'FV3DETAIL' )

	// Cria Box Horizontal
	oView:CreateHorizontalBox( 'SUPERIOR' , 20 )
	oView:CreateHorizontalBox( 'INFERIOR' , 80 )

	//Relaciona o ID da View com o Box de Exibição
	oView:SetOwnerView( 'VIEW_FVR','SUPERIOR')
	oView:SetOwnerView( 'VIEW_FV3','INFERIOR')

	oView:SetViewProperty("VIEW_FV3", "GRIDSEEK", {.T.})
	oView:SetViewProperty("VIEW_FV3", "GRIDFILTER")

	//Habilita titulo da grid
	oView:EnableTitleView("VIEW_FV3", "Detalhes")

	//Habilita botoes no outras acoes
	oView:AddUserButton(STR0003, 'CLIPS', {|oVw| FINR917(FVR->FVR_IDPROC)}, , VK_F11, {MODEL_OPERATION_VIEW})

	//Habilita barra de progresso na montagem da view
	//oView:SetProgressBar(.T.)

	Return oView

	//-------------------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} MenuDef()
	Definição de Menu - MVC

	@type Function

	@author Igor Fricks
	@since 09/06/2018
	@version 12.1.17

	/*/
	//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef() As Array

	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'A917Visual' OPERATION 2 ACCESS 0  // 'Visualizar'
	ADD OPTION aRotina Title STR0003 Action 'FINR917()' OPERATION 8 ACCESS 0  // 'Imprimir'

	Return aRotina

	//-------------------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} A917Visual()
	Tela de Visualização dos registros

	@type Function

	@author Fernando Navarro
	@since 05/04/2019
	@version 12.1.23

	/*/
	//-------------------------------------------------------------------------------------------------------------
Function A917Visual()

	Local cTitulo  	 As Character
	Local cPrograma  As Character
	Local aEnableBut As Array

	cTitulo       := STR0001
	cPrograma     := "FINA917"
	//Retira todos os botões
	aEnableBut 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,},{.F.,},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }//"Confirmar" //"Fechar"

	FWExecView( cTitulo , cPrograma, MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, aEnableBut /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )

	Return


	//-------------------------------------------------------------------
	/*/{Protheus.doc} A917VLMod
	Realiza a validacao do modelo de dados do MVC

	@author Fernando Navarro

	@since 12/04/2019
	@version 1.0
	/*/
	//-------------------------------------------------------------------
Function A917VLMod(oModel) As Logical

	Local nOperation	As Numeric
	Local lRet			As Logical
	Local cAliasQry		As Character


	nOperation	:= oModel:GetOperation()
	lRet			:= .T.
	cAliasQry		:=GetNextAlias()


	If lRet .And. (nOperation == MODEL_OPERATION_VIEW )

		BeginSql Alias cAliasQry
			SELECT DISTINCT(FV3_IDPROC) FV3_IDPROC
			FROM %table:FV3%
			WHERE FV3_FILIAL = %xFilial:FV3%  AND
			FV3_IDPROC =  %Exp:FVR->FVR_IDPROC% AND
			%notDel%
		EndSql

		If (cAliasQry)->(Eof())
			//Help(" ",1,"A917NODET",,"Não há inconsistências a serem listadas" ,1,0,,,,,,{"Selecione um registro com inconsistências!"})
			Help(" ",1,"A917NODET",,STR0012 ,1,0,,,,,,{STR0013})
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	Return lRet
