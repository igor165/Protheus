#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "Shopify.ch"
#INCLUDE "ShopifyExt.ch"


//Variáveis Estáticas
Static cTitulo := STR0063 //"Cadastro de fotos Shopify"

/*/{Protheus.doc} Shpint006
Cadastro Ur's fotos produtos SHOPIFY

@author Izo Cristiano Montebugnoli
@since 04/13/2020
@sample ShpInt006()
@return
@obs
/*/
Function ShpInt006()

	Local aArea   := GetArea()
	Local oBrowse

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SB1")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Ativa a Browse
	oBrowse:Activate()


	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Shpint006
Cadastro Ur's fotos produtos SHOPIFY
@author Izo Cristiano Montebugnoli
@since 04/13/2020
@sample MenuDef()
@return
@obs
/*/
Static Function MenuDef()

	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE STR0065 	ACTION 'VIEWDEF.ShpInt006' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE STR0064    ACTION 'VIEWDEF.ShpInt006' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4

Return aRot





/*/{Protheus.doc} Shpint006
Cadastro Ur's fotos produtos SHOPIFY

@author Izo Cristiano Montebugnoli
@since 04/13/2020
@sample ModelDef()
@return
@obs
/*/
Static Function ModelDef()

	Local oModel := Nil
	Local oStPai   := FWFormModelStruct():New()
	Local oStFilho := FWFormStruct(1, 'A1E')
	Local aA1ERel:= {}


	//Adiciona a tabela na estrutura temporária
	oStPai:AddTable('SB1', {'B1_FILIAL', 'B1_COD', 'B1_DESC'}, "Cabecalho SB1")
	
	//Adiciona o campo de Filial
	oStPai:AddField(;
		AllTrim(FWX3Titulo("B1_FILIAL")),;                                                                                  // [01]  C   Titulo do campo
		AllTrim(FWX3Titulo("B1_FILIAL")),;                                                                                  // [02]  C   ToolTip do campo
		"B1_FILIAL",;                                                                               // [03]  C   Id do Field
		"C",;                                                                                       // [04]  C   Tipo do campo
		TamSX3("B1_FILIAL")[1],;                                                                    // [05]  N   Tamanho do campo
		0,;                                                                                         // [06]  N   Decimal do campo
		Nil,;                                                                                       // [07]  B   Code-block de validação do campo
		Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
		{},;                                                                                        // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
		Nil,;    																					 // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Filial
	oStPai:AddField(;
		AllTrim(FWX3Titulo("B1_COD")),;                                                                                 	 // [01]  C   Titulo do campo
		AllTrim(FWX3Titulo("B1_COD")),;                                                                                 	 // [02]  C   ToolTip do campo
		"B1_COD",;                                                                              	 // [03]  C   Id do Field
		"C",;                                                                                       // [04]  C   Tipo do campo
		TamSX3("B1_COD")[1],;                                                                   	 // [05]  N   Tamanho do campo
		0,;                                                                                         // [06]  N   Decimal do campo
		Nil,;                                                                                       // [07]  B   Code-block de validação do campo
		Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
		{},;                                                                                        // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
		Nil,;    																					 // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                                        // [14]  L   Indica se o campo é virtual


	//Adiciona o campo de Filial
	oStPai:AddField(;
		AllTrim(FWX3Titulo("B1_DESC")),;                                                                               // [01]  C   Titulo do campo
		AllTrim(FWX3Titulo("B1_DESC")),;                                                                               // [02]  C   ToolTip do campo
		"B1_DESC",;                                                                              	 // [03]  C   Id do Field
		"C",;                                                                                       // [04]  C   Tipo do campo
		TamSX3("B1_DESC")[1],;                                                                   	 // [05]  N   Tamanho do campo
		0,;                                                                                         // [06]  N   Decimal do campo
		Nil,;                                                                                       // [07]  B   Code-block de validação do campo
		Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
		{},;                                                                                        // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
		Nil,;    																					 // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                                        // [14]  L   Indica se o campo é virtual


	//Criando o modelo e os relacionamentos	
	oModel := MPFormModel():New('ShpInt006M')
	oModel:AddFields('SB1MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('A1EDETAIL','SB1MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aA1ERel, {'A1E_FILIAL','B1_FILIAL'} )
	aAdd(aA1ERel, {'A1E_COD','B1_COD'}) 

	oModel:SetRelation('A1EDETAIL', aA1ERel, A1E->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('A1EDETAIL'):SetUniqueLine({"A1E_FILIAL","A1E_COD","A1E_SEQUEN"})//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})

	//Setando as descrições
	oModel:SetDescription(STR0063) //Imagens de produtos shopify
	oModel:GetModel('SB1MASTER'):SetDescription('Modelo Grupo')
	oModel:GetModel('A1EDETAIL'):SetDescription('Modelo Produtos')

Return oModel



/*/{Protheus.doc} Shpint006
Cadastro Ur's fotos produtos SHOPIFY

@author Izo Cristiano Montebugnoli
@since 04/13/2020
@sample ViewDef()
@return
@obs
/*/
Static Function ViewDef()

	Local oView:= Nil
	Local oModel:= FWLoadModel('ShpInt006')
	Local oStPai   := FWFormViewStruct():New()	
	Local oStFilho := FWFormStruct(2, 'A1E')

	//Adicionando o campo Chave para ser exibido
	oStPai:AddField(;
		"B1_COD",;                // [01]  C   Nome do Campo
		"02",;                    // [02]  C   Ordem
		"Code",;                   // [03]  C   Titulo do campo
		X3Descric('B1_COD'),;     // [04]  C   Descricao do campo
		Nil,;                     // [05]  A   Array com Help
		"C",;                     // [06]  C   Tipo do campo
		X3Picture("B1_COD"),;     // [07]  C   Picture
		Nil,;                     // [08]  B   Bloco de PictTre Var
		Nil,;                     // [09]  C   Consulta F3
		.F.,;     				  // [10]  L   Indica se o campo é alteravel
		Nil,;                     // [11]  C   Pasta do campo
		Nil,;                     // [12]  C   Agrupamento do campo
		Nil,;                     // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                     // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                     // [15]  C   Inicializador de Browse
		Nil,;                     // [16]  L   Indica se o campo é virtual
		Nil,;                     // [17]  C   Picture Variavel
		Nil)                      // [18]  L   Indica pulo de linha após o campo

	oStPai:AddField(;
		"B1_DESC",;               // [01]  C   Nome do Campo
		"03",;                    // [02]  C   Ordem
		"Description",;           		// [03]  C   Titulo do campo
		X3Descric('B1_DESC'),;    // [04]  C   Descricao do campo
		Nil,;                     // [05]  A   Array com Help
		"C",;                     // [06]  C   Tipo do campo
		X3Picture("B1_DESC"),;    // [07]  C   Picture
		Nil,;                     // [08]  B   Bloco de PictTre Var
		Nil,;                     // [09]  C   Consulta F3
		.F.,;                     // [10]  L   Indica se o campo é alteravel
		Nil,;                     // [11]  C   Pasta do campo
		Nil,;                     // [12]  C   Agrupamento do campo
		Nil,;                     // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                     // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                     // [15]  C   Inicializador de Browse
		Nil,;                     // [16]  L   Indica se o campo é virtual
		Nil,;                     // [17]  C   Picture Variavel
		Nil)                      // [18]  L   Indica pulo de linha após o campo

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_SB1',oStPai,'SB1MASTER')
	oView:AddGrid('VIEW_A1E',oStFilho,'A1EDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',20)
	oView:CreateHorizontalBox('GRID',80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_SB1','CABEC')
	oView:SetOwnerView('VIEW_A1E','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_SB1',STR0066)//'Products')
	oView:EnableTitleView('VIEW_A1E',STR0067)//'Urls Products')

	oView:AddIncrementField( 'VIEW_A1E', 'A1E_SEQUEN' )

	//Remove os campos de Filial e Tabela da Grid
	oStFilho:RemoveField('A1E_COD')
	
Return oView





