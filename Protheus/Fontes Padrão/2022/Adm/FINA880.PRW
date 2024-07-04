#Include "TOTVS.ch"
#Include "FwMVCDef.ch"
#Include "FINA880.CH"

/*/{Protheus.doc} FINA880
Cadastro chave Pix.

@author 	R. Melo
@since 		10/10/2020
@version 	1.0
/*/
Function FINA880()
	Local oBrowse As Object
	
	If !FwIsInCallStack("MATA070")
		Help(" ", 1, "FINA880INV",, STR0029, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0030})
		Return Nil
	EndIf
	
	oBrowse := FwMBrowse():New()
	oBrowse:SetAlias("F70")
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
Criação do menu MVC.

@author		R. Melo
@since		10/10/2020
@version	1.0
@return 	array, retorna vetor com as operações do menu
/*/
Static Function MenuDef() As Array
	Local aRot As Array
	
	//Inicializa variáveis.
	aRot := {}
	ADD OPTION aRot TITLE STR0002 ACTION "VIEWDEF.FINA880" OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRot TITLE STR0003 ACTION "VIEWDEF.FINA880" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRot TITLE STR0004 ACTION "VIEWDEF.FINA880" OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRot TITLE STR0005 ACTION "VIEWDEF.FINA880" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
Return aRot

/*/{Protheus.doc} MenuDef
Criação do modelo de dados MVC.

@author		R. Melo
@since 		10/10/2020
@version 	1.0
/*/
Static Function ModelDef() As Object
	Local oModel	As Object
	Local oStTmp	As Object
	Local oStFilho	As Object
	Local bVldPos	As Block
	Local bVldCom	As Block
	Local aF70Rel	As Array
	
	//Inicializa variáveis
	oModel		:= Nil
	oStTmp		:= FwFormModelStruct():New()
	oStFilho	:= FwFormStruct(1, "F70")
	bVldPos		:= {|| VldF70Tab()}
	bVldCom		:= {|| SaveF70()}
	aF70Rel		:= {}
	
	//Adiciona a tabela na estrutura temporária
	oStTmp:AddTable("F70", {"F70_FILIAL", "F70_COD", "F70_AGENCI", "F70_DVAGE", "F70_NUMCON", "F70_DVCTA"}, "Cabecalho F70")
	
	//Adiciona o campo de Filial
	oStTmp:AddField(;
		STR0007,;                                                                                  // [01]  C   Titulo do campo
		STR0007,;                                                                                  // [02]  C   ToolTip do campo
		"F70_FILIAL",;                                                                               // [03]  C   Id do Field
		"C",;                                                                                       // [04]  C   Tipo do campo
		TamSX3("F70_FILIAL")[1],;                                                                    // [05]  N   Tamanho do campo
		0,;                                                                                         // [06]  N   Decimal do campo
		Nil,;                                                                                       // [07]  B   Code-block de validação do campo
		Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
		{},;                                                                                        // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, F70->F70_FILIAL, FwxFilial('F70'))"),;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                                        // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Código do Banco
	oStTmp:AddField(;
		STR0008,;                                                                    // [01]  C   Titulo do campo
		STR0008,;                                                                    // [02]  C   ToolTip do campo
		"F70_COD",;                                                                  // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("F70_COD")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(INCLUI, SA6->A6_COD, F70->F70_COD)"),;   // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Agência
	oStTmp:AddField(;
		STR0009,;                                                                 // [01]  C   Titulo do campo
		STR0009,;                                                                 // [02]  C   ToolTip do campo
		"F70_AGENCI",;                                                                 // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("F70_AGENCI")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(INCLUI,SA6->A6_AGENCIA,F70->F70_AGENCI)"),;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de DV Aência
	oStTmp:AddField(;
		STR0010,;                                                                 // [01]  C   Titulo do campo
		STR0010,;                                                                 // [02]  C   ToolTip do campo
		"F70_DVAGE",;                                                                 // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("F70_DVAGE")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(INCLUI,SA6->A6_DVAGE,F70->F70_DVAGE)"),;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)

	//Adiciona o campo de Conta
	oStTmp:AddField(;
		STR0011,;                                                                 // [01]  C   Titulo do campo
		STR0011,;                                                                 // [02]  C   ToolTip do campo
		"F70_NUMCON",;                                                                 // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("F70_NUMCON")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(INCLUI,SA6->A6_NUMCON,F70->F70_NUMCON)"),;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)

	//Adiciona o campo de DV Conta
	oStTmp:AddField(;
		STR0012,;                                                                 // [01]  C   Titulo do campo
		STR0012,;                                                                 // [02]  C   ToolTip do campo
		"F70_DVCTA",;                                                                 // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("F70_DVCTA")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(INCLUI,SA6->A6_DVCTA,F70->F70_DVCTA)"),;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)
	
	//Setando as propriedades na grid, o inicializador, para não dar mensagem de coluna vazia
	oStFilho:SetProperty("F70_FILIAL", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	oStFilho:SetProperty("F70_COD", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	
	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("FINA880M", , bVldPos, bVldCom)
	oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
	oModel:AddGrid("FORDETAIL","FORMCAB",oStFilho)
	
	//Adiciona o relacionamento de Filho, Pai
	AAdd(aF70Rel, {"F70_FILIAL", 'Iif(!INCLUI, F70->F70_FILIAL, FwxFilial("F70"))'})
	aAdd(aF70Rel, {"F70_COD"   , 'Iif(!INCLUI, F70->F70_COD,  "")'})
	aAdd(aF70Rel, {"F70_AGENCI", 'Iif(!INCLUI, F70->F70_AGENCI,  "")'})
	aAdd(aF70Rel, {"F70_DVAGE" , 'Iif(!INCLUI, F70->F70_DVAGE,  "")'})
	aAdd(aF70Rel, {"F70_NUMCON", 'Iif(!INCLUI, F70->F70_NUMCON,  "")'})
	aAdd(aF70Rel, {"F70_DVCTA" , 'Iif(!INCLUI, F70->F70_DVCTA,  "")'})
	
	//Criando o relacionamento
	oModel:SetRelation("FORDETAIL", aF70Rel, F70->(IndexKey(1)))
	
	//Setando o campo único da grid para não ter repetição
	oModel:GetModel("FORDETAIL"):SetUniqueLine({"F70_CHVPIX"})
	oModel:GetModel("FORDETAIL"):SetMaxLine(20)
	oModel:GetModel("FORDETAIL"):SetLPost({|| VldPosGrid()})
	oModel:GetModel("FORDETAIL"):SetUseOldGrid(.T.)
	oModel:GetModel("FORDETAIL"):SetDelAllLine(.T.)
	
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(STR0001)
	oModel:SetPrimaryKey({})
	oModel:GetModel("FORMCAB"):SetDescription(STR0001)
Return oModel

/*/{Protheus.doc} MenuDef
Criação da visão MVC.

@author 	R. Melo
@since 		10/10/2020
@version	1.0
/*/
Static Function ViewDef() As Object
	Local oModel   As Object
	Local oStTmp   As Object
	Local oStFilho As Object
	Local oView    As Object

	//Inicializa variáveis.
	oModel   := FwLoadModel("FINA880")
	oStTmp   := FwFormViewStruct():New()
	oStFilho := FwFormStruct(2, "F70")
	oView    := Nil

	//Adicionando o campo Chave para ser exibido
	oStTmp:AddField(;
		"F70_COD",;                 // [01]  C   Nome do Campo
		"01",;                      // [02]  C   Ordem
		STR0008,;                   // [03]  C   Titulo do campo
		X3Descric("F70_COD"),;      // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("F70_COD"),;      // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.F.,; //Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStTmp:AddField(;
		"F70_AGENCI",;              // [01]  C   Nome do Campo
		"02",;                      // [02]  C   Ordem
		STR0009,;                 // [03]  C   Titulo do campo
		X3Descric("F70_AGENCI"),;   // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("F70_AGENCI"),;   // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.F.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStTmp:AddField(;
		"F70_DVAGE",;               // [01]  C   Nome do Campo
		"03",;                      // [02]  C   Ordem
		STR0010,;               // [03]  C   Titulo do campo
		X3Descric("F70_DVAGE"),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("F70_DVAGE"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.F.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStTmp:AddField(;
		"F70_NUMCON",;               // [01]  C   Nome do Campo
		"04",;                      // [02]  C   Ordem
		STR0011,;               // [03]  C   Titulo do campo
		X3Descric("F70_NUMCON"),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("F70_NUMCON"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.F.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStTmp:AddField(;
		"F70_DVCTA",;               // [01]  C   Nome do Campo
		"05",;                      // [02]  C   Ordem
		STR0012,;                // [03]  C   Titulo do campo
		X3Descric("F70_DVCTA"),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("F70_DVCTA"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.F.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FwFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
	oView:AddGrid("VIEW_FOR", oStFilho, "FORDETAIL")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("CABEC",20)
	oView:CreateHorizontalBox("GRID",80)

	//Amarrando a view com as box
	oView:SetOwnerView("VIEW_CAB","CABEC")
	oView:SetOwnerView("VIEW_FOR","GRID")

	//Habilitando título
	oView:EnableTitleView("VIEW_CAB", STR0008)
	oView:EnableTitleView("VIEW_FOR", STR0001)

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
	oStFilho:RemoveField("F70_FILIAL")
	oStFilho:RemoveField("F70_COD")
	oStFilho:RemoveField("F70_AGENCI")
	oStFilho:RemoveField("F70_DVAGE")
	oStFilho:RemoveField("F70_NUMCON")
	oStFilho:RemoveField("F70_DVCTA")
Return oView

/*/{Protheus.doc} VldF70Tab
função chamada na validação do botão Confirmar, para verificar se já existe a tabela digitada

@author		R. Melo
@since		14/01/2017
@version	1.0
@return 	logical, .T. se pode prosseguir e .F. se deve barrar
/*/
Static Function VldF70Tab() As Logical
	Local oModelDad  As  Object
	Local lRet		 As Logical
	Local nPosActive As Numeric
	Local nCntActive As Numeric
	Local nAtual     As Numeric
	Local nColsAux	 As Numeric
	Local aHeadAux	 As Array
	Local aColsAux	 As Array
	Local oModelGrid As Object
	Local nCntDel	 As Numeric
	Local lDeletado  As Logical 

	//Inicializa variáveis.
	oModelDad  := FwModelActive()
	oModelGrid := oModelDad:GetModel("FORDETAIL")
	lRet       := .T.
	aHeadAux   := oModelGrid:aHeader
	aColsAux   := oModelGrid:aCols
	nColsAux   := Len(aColsAux)
	nCntActive := 0
	nCntDel    := 0
	nAtual     := 0
	nPosActive := AScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("F70_ACTIVE")})
	lDeletado  := .F.

	//Modifico qualquer conteúdo do cabeçalho para não dar errorlog de campos não alterados
	oModelDad:SetValue("FORMCAB", "F70_DVAGE" , "*")
	oModelDad:SetValue("FORMCAB", "F70_DVCTA" , "*")

	//Salvo os dados do banco em seus respectivos campos da
	oModelDad:SetValue("FORMCAB", "F70_FILIAL", xFilial("F70"))
	oModelDad:SetValue("FORMCAB", "F70_COD"   , SA6->A6_COD)
	oModelDad:SetValue("FORMCAB", "F70_AGENCI", SA6->A6_AGENCIA)
	oModelDad:SetValue("FORMCAB", "F70_DVAGE" , SA6->A6_DVAGE)
	oModelDad:SetValue("FORMCAB", "F70_NUMCON", SA6->A6_NUMCON)
	oModelDad:SetValue("FORMCAB", "F70_DVCTA" , SA6->A6_DVCTA)

	//Verificar aqui se existe pelo menos 1 chave ativa
	For nAtual := 1 To nColsAux
		cActive   := aColsAux[nAtual][nPosActive]
		lDeletado := oModelGrid:IsDeleted(nAtual) 
		
		If !lDeletado .And. cActive == "1"
			nCntActive += 1
		ElseIf lDeletado
			nCntDel	+= 1
		Endif
	Next nAtual
	
	If nCntActive < 1 .And. nCntDel < nColsAux
		lRet := .F.
		oModelDad:SetErrorMessage("FINA880M", Nil, "FINA880M", Nil, Nil, STR0028, Nil, Nil, Nil)
	EndIf
Return lRet

/*/{Protheus.doc} SaveF70
função desenvolvida para salvar os dados

@author		R. Melo
@since 		14/01/2017
@version 	1.0
/*/
Static Function SaveF70() As Logical
	Local aArea      As Array
	Local oModelDad  As Object
	Local cFilF70    As Character
	Local cCodigo    As Character
	Local cAgenci    As Character
	Local cDvAge     As Character
	Local cNumCon    As Character
	Local cDvCta     As Character
	Local oModelGrid As Object
	Local aHeadAux   As Array
	Local aColsAux   As Array
	Local nPosTpChv  As Numeric
	Local nPosChvPix As Numeric
	Local nPosActive As Numeric
	Local nAtual     As Numeric
	Local nHeadAux	 As Numeric
	Local nAcolsAux	 As Numeric
	Local nRecF70    As Numeric

	aArea		:= {}
	oModelDad	:= FwModelActive()
	cFilF70		:= oModelDad:GetValue("FORMCAB", "F70_FILIAL")
	cCodigo		:= oModelDad:GetValue("FORMCAB", "F70_COD")
	cAgenci		:= oModelDad:GetValue("FORMCAB", "F70_AGENCI")
	cDvAge		:= oModelDad:GetValue("FORMCAB", "F70_DVAGE")
	cNumCon		:= oModelDad:GetValue("FORMCAB", "F70_NUMCON")
	cDvCta		:= oModelDad:GetValue("FORMCAB", "F70_DVCTA")
	oModelGrid	:= oModelDad:GetModel("FORDETAIL")
	aHeadAux	:= oModelGrid:aHeader
	aColsAux	:= oModelGrid:aCols
	nPosTpChv	:= AScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("F70_TPCHV")})
	nPosChvPix	:= AScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("F70_CHVPIX")})
	nPosActive	:= AScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("F70_ACTIVE")})
	nAtual		:= 0
	nHeadAux	:= 0
	nAcolsAux	:= 0
	nRecF70		:= 0

	If (nAcolsAux := Len(aColsAux)) > 0
		aArea     := GetArea()
		nHeadAux  := Len(aHeadAux)
		DbSelectArea("F70")

		Begin Transaction
			For nAtual := 1 To nAcolsAux
				oModelGrid:GoLine(nAtual)
				nRecF70 := oModelGrid:GetDataId()

				If nRecF70 > 0
					F70->(DbGoTo(nRecF70))
				EndIf

				If (aColsAux[nAtual][nHeadAux+1]) //linha deletada ou sem chave
					If nRecF70 > 0
						RecLock("F70")
						F70->(DbDelete())
						F70->(MsUnlock())
					EndIf
					Loop
				EndIf

				If !oModelGrid:IsUpdated(nAtual)
					Loop
				EndIf

				//Delete a linha alterada na grid
				If nRecF70 > 0
					RecLock("F70")
					F70->(DbDelete())
					F70->(MsUnlock())
				EndIf

				//Faça a inclusão de novo registro, com o valor alterado
				RecLock("F70", .T.)
				F70->F70_FILIAL  := cFilF70
				F70->F70_COD     := cCodigo
				F70->F70_AGENCI  := cAgenci
				F70->F70_DVAGE   := cDvAge
				F70->F70_NUMCON  := cNumCon
				F70->F70_DVCTA   := cDvCta
				F70->F70_TPCHV 	 := Iif(nPosTpChv  > 0, aColsAux[nAtual][nPosTpChv],  "")
				F70->F70_CHVPIX  := Iif(nPosChvPix > 0, aColsAux[nAtual][nPosChvPix], "")
				F70->F70_ACTIVE  := Iif(nPosActive > 0, aColsAux[nAtual][nPosActive], "")
				F70->(MsUnlock())
			Next
		End Transaction

		RestArea(aArea)
		FwFreeArray(aArea)
	EndIf

Return .T.

/*/{Protheus.doc} VldPosGrid
Validar linha da grid

@author 	R. Melo
@since 		14/01/2017
@version	1.0
/*/
Static Function VldPosGrid() As Logical
	Local lRet			As Logical
	Local oModelDad		As Object
	Local oModelGrid	As Object
	Local aHeadAux		As Array
	Local aColsAux		As Array
	Local nPosTpChv		As Numeric
	Local nPosChvPix	As Numeric
	Local nPosActive	As Numeric
	Local nAtual		As Numeric
	Local cChave		As Character
	Local cTpChave		As Character
	Local nContTpChv	As Numeric
	Local cDescTp		As Character
	Local cNumbPhone	As Character
	Local nNum			As Numeric
	Local nTotNum		As Numeric
	Local nCntActive	As Numeric
	Local cQuery		As Character
	Local cAliasQry		As Character
	Local nColsAux		As Numeric
	Local nTamChave		As Numeric
	Local cActive		As Character
	Local cTpChvAtu		As Character
	Local aArea			As Array
	Local cBanco		As Character
	Local cAgencia		As Character
	Local cDvAgen		As Character
	Local cConta		As Character
	Local cDvConta		As Character
	Local cChavBco		As Character
	Local nY			As Numeric
	Local nLenHeader	As Numeric
	Local cFilF70		As Character

	lRet		:= .T.
	oModelDad	:= FwModelActive()
	oModelGrid	:= oModelDad:GetModel("FORDETAIL")
	aHeadAux	:= oModelGrid:aHeader
	aColsAux	:= oModelGrid:aCols
	nPosTpChv	:= AScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("F70_TPCHV")})
	nPosChvPix	:= AScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("F70_CHVPIX")})
	nPosActive	:= AScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("F70_ACTIVE")})
	nAtual		:= 0
	cChave		:= ""
	cTpChave	:= ""
	nContTpChv	:= 0
	cDescTp		:= ""
	cNumbPhone	:= ("0/1/2/3/4/5/6/7/8/9")
	nNum		:= 0
	nTotNum		:= 0
	nCntActive	:= 0
	cQuery		:= ""
	cAliasQry	:= ""
	nColsAux	:= Len(aColsAux)
	nTamChave	:= 0
	cActive		:= ""
	cTpChvAtu	:= ""
	aArea		:= {}
	cChavBco	:= ""
	nY			:= 0
	nLenHeader	:= Len(aHeadAux)
	nLine		:= oModelGrid:GetLine()
	cFilF70 	:= oModelDad:GetValue("FORMCAB", "F70_FILIAL")
    cBanco      := oModelDad:GetValue("FORMCAB", "F70_COD")
    cAgencia   	:= oModelDad:GetValue("FORMCAB", "F70_AGENCI")
  	cDvAgen     := oModelDad:GetValue("FORMCAB", "F70_DVAGE")
    cConta   	:= oModelDad:GetValue("FORMCAB", "F70_NUMCON")
	cDvConta   	:= oModelDad:GetValue("FORMCAB", "F70_DVCTA")
	lRet        := (nLine > 0 .And. nColsAux > 0 .And. !oModelGrid:IsDeleted(nLine))
	
	If lRet
		If nPosChvPix > 0
			cChave := aColsAux[nLine][nPosChvPix]
		EndIf

		If nPosTpChv > 0
			cTpChvAtu := aColsAux[nLine][nPosTpChv]
		EndIf

		If nPosActive > 0
			cActive := aColsAux[nLine][nPosActive]
		EndIf

		If Empty(cActive)
			lRet := .F.
			oModelDad:SetErrorMessage("FINA880M", Nil, "FINA880M", Nil, Nil, STR0026, Nil, Nil, Nil)
		EndIf
	EndIf
	
	If lRet
		aArea := GetArea()
		DbSelectArea("F70")

		cQuery := "SELECT F70_FILIAL, F70_CHVPIX, F70_COD, F70_AGENCI, F70_DVAGE, F70_NUMCON, F70_DVCTA "
		cQuery += "FROM " + RetSQLName("F70") + " "
		cQuery += "WHERE F70_CHVPIX = '" + cChave + "' AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cAliasQry,.F.,.T.)

		cChavBco := AllTrim((cAliasQry)->(F70_FILIAL + F70_COD + F70_AGENCI + F70_DVAGE + F70_NUMCON + F70_DVCTA))

		If (cAliasQry)->(!Eof()) .And. !Empty(cChave)

			For nY := 1 To oModelGrid:Length()
				oModelGrid:Goline(nY)
				If cChavBco <> Alltrim(cFilF70+cBanco+cAgencia+cDvAgen+cConta+cDvConta) .And. lRet
					lRet := .F.
					Exit
				ElseIf oModelGrid:GetValue("F70_CHVPIX") == cChave .And. !oModelGrid:IsDeleted() .And. nY <> nLine .And. lRet
					lRet := .F.
					Exit
				EndIf
			Next nY
			If !lRet
				oModelDad:SetErrorMessage("FINA880M", Nil, "FINA880M", Nil, Nil, STR0013 + cChave, Nil, Nil, Nil)
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
		RestArea(aArea)
	EndIf
	
	If lRet
		For nAtual := 1 To nColsAux
			If aColsAux[nAtual][nLenHeader + 1]
				Loop
			EndIf

			cActive := aColsAux[nAtual][nPosActive]

			If cActive == "1"
				nCntActive += 1

				If nCntActive > 1
					lRet := .F.
					oModelDad:SetErrorMessage("FINA880M", Nil, "FINA880M", Nil, Nil, STR0014, Nil, Nil, Nil)
					Exit
				EndIf
			Endif
		Next
	EndIf
	
	If lRet
		//Varre todas as linhas da Grid para verificar se existe algum tipo de chave duplicado
		For nAtual := 1 To nColsAux
			cTpChave := aColsAux[nAtual][nPosTpChv]

			//Valida se possui mais de uma chave CPF/CNPJ
			If cTpChvAtu == cTpChave .AND. cTpChvAtu == "03"
				nContTpChv += 1
			Endif
		Next nAtual

		//Caso já exista mais de um tipo de chave 'Telefone' ou 'E-mail' ou 'CPF/CNPJ' o processo de inclusão da linha é barrado
		If nContTpChv > 1
			If cTpChvAtu == "03"
				cDescTp := STR0015
			Endif

			oModelDad:SetErrorMessage("FINA880M", Nil, "FINA880M", Nil, Nil, STR0016 + ":" + cDescTp + STR0017, Nil, Nil, Nil)
			lRet:= .F.
		Endif

		If lRet
			nTamChave := Len(Alltrim(cChave))

			If cTpChvAtu == "01"
				If (lRet := (SubStr(cChave, 1, 1) == "+"))
					For nNum := 2 To nTamChave
						If !SubStr(cChave, nNum, 1) $ cNumbPhone
							lRet := .F.
						Else
							nTotNum += 1
						Endif
					Next nNum

					If lRet .And. nTotNum <> 13
						lRet := .F.
					Endif
				Endif

				If !lRet
					oModelDad:SetErrorMessage("FINA880M", Nil, "FINA880M", Nil, Nil, STR0018, STR0019, Nil, Nil)
				Endif
			Elseif cTpChvAtu == "02"
				If !IsEmail(Alltrim(cChave))
					oModelDad:SetErrorMessage("FINA880M", Nil, "FINA880M", Nil, Nil, STR0020, STR0021, Nil, Nil)
					lRet:= .F.
				Endif
			Elseif cTpChvAtu == "03"
				If !CGC(Alltrim(cChave),,.F.)
					lRet:= .F.
					oModelDad:SetErrorMessage("FINA880M", , "FINA880M", Nil, Nil, STR0022, STR0027, Nil, Nil)
				Endif
			Elseif cTpChvAtu == "04" .And. nTamChave <> 36
				oModelDad:SetErrorMessage("FINA880M", Nil, "FINA880M", Nil, Nil, STR0023, STR0024, Nil, Nil)
				lRet:= .F.
			EndIf
		EndIf
	EndIf
Return lRet
