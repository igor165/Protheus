#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA134.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'DBTREE.CH'

Static oDbTree
Static asCargos2Niv
Static asDbTree
Static cFistCargo
Static slPCPREVATU
Static slPesRefre := .F.


/*/{Protheus.doc} PCPA134
Consulta onde o componente é Usado
@author brunno.costa
@since 08/10/2018
@version 1.0
@return NIL
@param lExecPerg
- TRUE - Executa pergunta;
- FALSE - Não executa pergunta, útil para quando o pergunte foi executado anteriormente em chamada externa

Pergunta PCPA134:
- MV_PAR01 - Componente de
- MV_PAR02 - Componente até
- MV_PAR03 - Quantidade de
- MV_PAR04 - Quandidade até
- MV_PAR05 - Validade de
- MV_PAR06 - Validade até
- MV_PAR07 - Armazém de consumo de
- MV_PAR08 - Armazém de consumo até
- MV_PAR09 - Considera revisão da estrutura?
- MV_PAR10 - Tipos do produto pai separados por virgula
/*/
Function PCPA134(lExecPerg)
	Local aArea 		:= GetArea()

	Default lExecPerg	:= .T.
	Private nIndex		:= 0

	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		HELP(' ',1,"Help" ,,STR0067,2,0,,,,,,) //"Rotina não disponível nesta release."
		Return
	EndIf

	DbSelectArea("SG1")
	If !lExecPerg .Or. Pergunte("PCPA134")
		FWExecView(STR0001, 'PCPA134', MODEL_OPERATION_VIEW, , { || .T. }, , ,/**/ )	//Consulta onde o componente é usado
	EndIf

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author brunno.costa
@since 08/10/2018
@version 1.0
@return oModel
/*/
Static Function ModelDef()
	Local oModel
	Local oStruMaster	:= Nil
	Local oStruSelec	:= Nil
	Local oStruSG1O		:= Nil	//Grid de Pais dos Componentes - Onde é Usado
	Local oEvent		:= PCPA134EVDEF():New()

	oStruMaster := FWFormStruct(1,"SG1",{|cCampo|   "|"+AllTrim(cCampo)+"|" $ "|G1_COD|"})		//Obrigatório - Não usado, sem vínculo com demais componentes
	oStruSelec 	:= FWFormStruct(1,"SG1",{|cCampo|   "|"+AllTrim(cCampo)+"|" $ "|G1_COMP|"})
	oStruSG1O 	:= FWFormStruct(1,"SG1",{|cCampo|   "|"+AllTrim(cCampo)+"|" $ "|G1_COMP|G1_COD|G1_REVINI|G1_REVFIM|G1_QUANT|G1_INI|G1_FIM|G1_LOCCONS|G1_OPC|G1_GROPC|G1_TRT|G1_FANTASM|G1_LISTA|"})

	CamposCab(.T., @oStruSG1O, @oStruSelec) //Adiciona Campos

	oModel := MPFormModel():New('PCPA134')
	oModel:InstallEvent("PCPA134EVDEF"	, /*cOwner*/, oEvent)

	oModel:AddFields("PCPA134_MASTER"	,	/*cOwner*/		, oStruMaster)
	oModel:addFields("FLD_SELECT_134"	,"PCPA134_MASTER"	, oStruSelec)
	oModel:AddGrid("GRID_ONDE"  		,"PCPA134_MASTER"	, oStruSG1O)
	oModel:GetModel("GRID_ONDE"  ):SetDescription(STR0002) 			//Onde é usado:
	oModel:GetModel("GRID_ONDE"):SetOnlyView()

	//Realiza carga do Modelo de Pesquisa
	oModel := StaticCall(PCPA134Pes, ModelDef, oModel, "PCPA134_MASTER")

	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author brunno.costa
@since 08/10/2018
@version 1.0
@return oView
/*/
Static Function ViewDef()

	Local oModel		:= Nil
	Local oView			:= Nil
	Local oStruSelec	:= Nil
	Local oStruSG1O		:= Nil	//Grid de Pais dos Componentes - Onde é Usado

	oStruSelec 	:= FWFormStruct(2,"SG1",{|cCampo|   "|"+AllTrim(cCampo)+"|" $ "|G1_COMP|"})
	oStruSG1O 	:= FWFormStruct(2,"SG1",{|cCampo|   "|"+AllTrim(cCampo)+"|" $ "|G1_COD|G1_REVINI|G1_REVFIM|G1_QUANT|G1_INI|G1_FIM|G1_LOCCONS|G1_OPC|G1_GROPC|G1_TRT|G1_FANTASM|G1_LISTA|"})

	oModel	:= FWLoadModel("PCPA134")
	oView	:= FWFormView():New()
	oView:SetModel(oModel)

	CamposCab(.F., @oStruSG1O, @oStruSelec)

	oView:SetUseCursor(.F.)
	oView:EnableControlBar(.T.)

	//Cria View da Tree
	//oView:AddOtherObject("V_TREE", {|oPanel| MontaTree(oPanel, oModel)})
	oView:AddOtherObject("V_TREE", {|o| oPanel := o, Processa({|| MontaTree(oPanel, oModel) }, STR0062, STR0063, .F.) }) //"Aguarde..." - "Selecionando os registros..."

	oView:addField("V_FLD_SELECT", oStruSelec, "FLD_SELECT_134")
	oView:AddGrid( "V_GRID_ONDE" , oStruSG1O , "GRID_ONDE")

	oView:EnableTitleView("V_TREE"		, STR0003)	//Componentes x Pai:
	oView:EnableTitleView("V_GRID_ONDE"	, STR0004)	//Onde se usa:

	oView:CreateVerticalBox("ESQ"	, 20)
	oView:CreateVerticalBox("DIR"	, 80)

	oView:CreateHorizontalBox("DIR_CIMA"	,  76, "DIR", .T.)
	oView:CreateHorizontalBox("DIR_BAIXO"	, 100, "DIR")

	oView:SetOwnerView("V_TREE"			,"ESQ")
	oView:SetOwnerView("V_FLD_SELECT"   ,"DIR_CIMA" )
	oView:SetOwnerView("V_GRID_ONDE"   	,"DIR_BAIXO" )

	//Outras Ações
	oView:AddUserButton(STR0005 + " " + STR0060, "", {|oView| ReloadPerg(oView:GetModel(), oView) }, , , MODEL_OPERATION_VIEW, .F.)     //Parâmetros [F12]
	oView:AddUserButton(STR0040 + " " + STR0059, "", {|oView| PCPA134Pes(oView, @asDbTree, oDbTree, @slPesRefre), LoadPesqVK(oView, 0) }, , , , .T.) //Pesquisa [F5]
	oView:AddUserButton(STR0068, ""                , {|oView| execAlt(oView) }, , , ) //"Modificar"

	LoadPesqVK(oView, 0)

Return oView

/*/{Protheus.doc} LoadPesqVK
Funções relacionadas as teclas de atalho F5, F6, F7 e F12
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oView, object , objeto da View
@param 02 nOpc , numeric, indicador de operação:
0 - Atribui teclas de atalho
1 - Abre tela de pesquisa
2 - Pesquisa anterior
3 - Pesqiosa o próximo
4 - Refaz a pesquisa
5 - Desabilita as teclas de atalho
/*/
Static Function LoadPesqVK(oView, nOpc)

	Local oViewActiv := FwViewActive()

	If nOpc == 0
		SetKey( VK_F5,  { || LoadPesqVK(oView, 1) } )
		SetKey( VK_F6,  { || LoadPesqVK(oView, 2) } )
		SetKey( VK_F7,  { || LoadPesqVK(oView, 3) } )
		SetKey( VK_F12, { || LoadPesqVK(oView, 4) } )
		slPesRefre := .F.
	ElseIf nOpc == 5
		SetKey( VK_F5,  Nil )
		SetKey( VK_F6,  Nil )
		SetKey( VK_F7,  Nil )
		SetKey( VK_F12, Nil )
	Else
		//Só permitirá acessar os atalhos quando estiver na view/modelo principal
		If aScan(oViewActiv:GetModelsIds(), "FLD_SELECT_134") > 0
			//Tecla F5 (Pesquisa)
			If nOpc == 1
				PCPA134Pes(oView, @asDbTree, oDbTree, @slPesRefre)
				SetKey( VK_F5, { || PCPA134Pes(oView, @asDbTree, oDbTree) } )
				LoadPesqVK(oView, 0)

			//Tecla F6 (Anterior)
			ElseIf nOpc == 2
				StaticCall(PCPA134Pes, Posiciona, oView, .T., .F., @slPesRefre)
				LoadPesqVK(oView, 0)

			//Tecla F7 (Próximo)
			ElseIf nOpc == 3
				StaticCall(PCPA134Pes, Posiciona, oView, .F., .T., @slPesRefre)
				LoadPesqVK(oView, 0)

			//Tecla F12 (Parâmetros)
			ElseIf nOpc == 4
				ReloadPerg(oView:GetModel(), oView)
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} ReloadPerg
Reabre Pergunta e recarrega a Tela
@author brunno.costa
@since 08/10/2018
@version 12
@type function
/*/
Static Function ReloadPerg(oModel, oView)

	If Pergunte("PCPA134")
		slPesRefre := .T.
		MontaTree(Nil, oModel, .F.)
		oView:Refresh()
	EndIf

Return

/*/{Protheus.doc} CamposCab
Monta estrutura de campo para modelo e view.
@author brunno.costa
@since 08/10/2018
@version 1.0
/*/
Static Function CamposCab(lModel, oStruSG1O, oStruSelec)

	Local aCposPai	:= {"B1_DESC","B1_UM","B1_TIPO"}
	Local aCposSel	:= {"B1_COD", "B1_DESC","B1_UM"}
	Local nAux		:= 0

	If lModel //Instância de modelo

		//Adiciona Campos na Estrutura da Grid PAI
		For nAux := 1 to Len(aCposPai)
			oStruSG1O:AddField(	RetTitle(aCposPai[nAux])					,;	// [01]  C   Titulo do campo  - Produto
								RetTitle(aCposPai[nAux])					,;	// [02]  C   ToolTip do campo - Código do Produto
								aCposPai[nAux]	   							,;	// [03]  C   Id do Field
								GetSx3Cache(aCposPai[nAux],"X3_TIPO")		,;	// [04]  C   Tipo do campo
								GetSx3Cache(aCposPai[nAux],"X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
								GetSx3Cache(aCposPai[nAux],"X3_DECIMAL")	,;	// [06]  N   Decimal do campo
								NIL									,;	// [07]  B   Code-block de validação do campo
								NIL							   		,;	// [08]  B   Code-block de validação When do campo
								NIL									,; 	// [09]  A   Lista de valores permitido do campo
								.F.									,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
								{|| }								,;	// [11]  B   Code-block de inicializacao do campo
								NIL									,;	// [12]  L   Indica se trata-se de um campo chave
								NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.									)   // [14]  L   Indica se o campo é virtual
		Next nAux

		//Adiciona o campo "Origem do Armazém"
		oStruSG1O:AddField(	STR0036		,;	// [01]  C   Titulo do campo  - "Origem Amz."
							STR0036		,;	// [02]  C   ToolTip do campo - "Origem Amz."
							"CORIGARM"	,;	// [03]  C   Id do Field
							"C"			,;	// [04]  C   Tipo do campo
							30			,;	// [05]  N   Tamanho do campo
                        	0			,;	// [06]  N   Decimal do campo
                        	NIL,NIL,NIL	,;
                        	.F.			,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
                        	{|| }		,;	// [11]  B   Code-block de inicializacao do campo
                        	NIL,NIL		,;
                        	.T.)			// [14]  L   Indica se o campo é virtual

		//Adiciona o campo "RECNO"
		oStruSG1O:AddField(	"RECNO"		,;	// [01]  C   Titulo do campo  - "Origem Amz."
							"RECNO"		,;	// [02]  C   ToolTip do campo - "Origem Amz."
							"RECNO"  	,;	// [03]  C   Id do Field
							"N"			,;	// [04]  C   Tipo do campo
							10			,;	// [05]  N   Tamanho do campo
                        	0			,;	// [06]  N   Decimal do campo
                        	NIL,NIL,NIL	,;
                        	.F.			,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
                        	{|| }		,;	// [11]  B   Code-block de inicializacao do campo
                        	NIL,NIL		,;
                        	.T.)			// [14]  L   Indica se o campo é virtual

		//Adiciona Campos na Estrutura da Field do produto selecionado
		For nAux := 1 to Len(aCposSel)
			//Descrição do produto
			oStruSelec:AddField(RetTitle(aCposSel[nAux])					,;	// [01]  C   Titulo do campo  - Produto
								RetTitle(aCposSel[nAux])					,;	// [02]  C   ToolTip do campo - Código do Produto
								aCposSel[nAux]	   							,;	// [03]  C   Id do Field
								GetSx3Cache(aCposSel[nAux],"X3_TIPO")		,;	// [04]  C   Tipo do campo
								GetSx3Cache(aCposSel[nAux],"X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
								GetSx3Cache(aCposSel[nAux],"X3_DECIMAL")	,;	// [06]  N   Decimal do campo
								NIL									,;	// [07]  B   Code-block de validação do campo
								NIL							   		,;	// [08]  B   Code-block de validação When do campo
								NIL									,; 	// [09]  A   Lista de valores permitido do campo
								.F.									,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
								{|| ""}								,;	// [11]  B   Code-block de inicializacao do campo
								NIL									,;	// [12]  L   Indica se trata-se de um campo chave
								NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.									)   // [14]  L   Indica se o campo é virtual
		Next nAux
		oStruSelec:RemoveField("G1_COMP")

	Else //Instância de view

		//Adiciona Campos na Estrutura da Grid PAI
		For nAux := 1 to Len(aCposPai)
			oStruSG1O:AddField(	aCposPai[nAux]							,;	// [01]  C   Nome do Campo
								"04"									,;	// [02]  C   Ordem
								RetTitle(aCposPai[nAux])				,;	// [03]  C   Titulo do campo
								RetTitle(aCposPai[nAux])				,;	// [04]  C   Descricao do campo
								NIL										,;	// [05]  A   Array com Help
								GetSx3Cache(aCposPai[nAux],"X3_TIPO")	,; 	// [06]  C   Tipo do campo
								""					,;	// [07]  C   Picture
								NIL					,;	// [08]  B   Bloco de Picture Var
								NIL					,;	// [09]  C   Consulta F3
								.F.					,;	// [10]  L   Indica se o campo é alteravel
								NIL					,;	// [11]  C   Pasta do campo
								NIL					,;	// [12]  C   Agrupamento do campo
								NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL					,;	// [15]  C   Inicializador de Browse
								.T.					,;	// [16]  L   Indica se o campo é virtual
								NIL					,;	// [17]  C   Picture Variavel
								NIL					)	// [18]  L   Indica pulo de linha após o campo
		Next nAux

		//Adiciona o campo "Origem do Armazém"
		oStruSG1O:AddField( "CORIGARM"			,;	// [01]  C   Nome do Campo
							"00"				,;	// [02]  C   Ordem
							STR0036				,;	// [03]  C   Titulo do campo    - "Origem Amz."
							STR0036				,;	// [04]  C   Descricao do campo - "Origem Amz."
							NIL					,;	// [05]  A   Array com Help
							"C"					,;	// [06]  C   Tipo do campo
							NIL,NIL,NIL			,;
							.F.					,;	// [10]  L   Indica se o campo é alteravel
							NIL,NIL,NIL,NIL,NIL	,;
							.T.					,;	// [16]  L   Indica se o campo é virtual
							NIL,NIL)

		//Adiciona Campos na Estrutura da Field do Produto Selecionado
		For nAux := 1 to Len(aCposSel)
			oStruSelec:AddField(aCposSel[nAux]							,;	// [01]  C   Nome do Campo
								GetSx3Cache(aCposSel[nAux],"X3_ORDEM")	,;	// [02]  C   Ordem
								RetTitle(aCposSel[nAux])				,;	// [03]  C   Titulo do campo
								RetTitle(aCposSel[nAux])				,;	// [04]  C   Descricao do campo
								NIL										,;	// [05]  A   Array com Help
								GetSx3Cache(aCposSel[nAux],"X3_TIPO")	,; 	// [06]  C   Tipo do campo
								""					,;	// [07]  C   Picture
								NIL					,;	// [08]  B   Bloco de Picture Var
								NIL					,;	// [09]  C   Consulta F3
								.F.					,;	// [10]  L   Indica se o campo é alteravel
								NIL					,;	// [11]  C   Pasta do campo
								NIL					,;	// [12]  C   Agrupamento do campo
								NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL					,;	// [15]  C   Inicializador de Browse
								.T.					,;	// [16]  L   Indica se o campo é virtual
								NIL					,;	// [17]  C   Picture Variavel
								NIL					)	// [18]  L   Indica pulo de linha após o campo
		Next nAux
		oStruSelec:RemoveField("G1_COMP")

		//Corrige Ordenação de Campos da Grid dos Produtos Pai
		oStruSG1O:SetProperty("G1_COD"		, MVC_VIEW_ORDEM, "01")
		oStruSG1O:SetProperty("B1_DESC"		, MVC_VIEW_ORDEM, "02")
		oStruSG1O:SetProperty("G1_TRT"		, MVC_VIEW_ORDEM, "03")
		oStruSG1O:SetProperty("B1_TIPO"		, MVC_VIEW_ORDEM, "04")
		oStruSG1O:SetProperty("G1_REVINI"	, MVC_VIEW_ORDEM, "05")
		oStruSG1O:SetProperty("G1_REVFIM"	, MVC_VIEW_ORDEM, "06")
		oStruSG1O:SetProperty("G1_QUANT"	, MVC_VIEW_ORDEM, "07")
		oStruSG1O:SetProperty("B1_UM"		, MVC_VIEW_ORDEM, "08")
		oStruSG1O:SetProperty("G1_FANTASM"	, MVC_VIEW_ORDEM, "09")
		oStruSG1O:SetProperty("G1_INI"		, MVC_VIEW_ORDEM, "10")
		oStruSG1O:SetProperty("G1_FIM"		, MVC_VIEW_ORDEM, "11")
		oStruSG1O:SetProperty("G1_LOCCONS"	, MVC_VIEW_ORDEM, "12")
		oStruSG1O:SetProperty("CORIGARM"	, MVC_VIEW_ORDEM, "13")
		oStruSG1O:SetProperty("G1_GROPC"	, MVC_VIEW_ORDEM, "14")
		oStruSG1O:SetProperty("G1_OPC"		, MVC_VIEW_ORDEM, "15")
		oStruSG1O:SetProperty("G1_LISTA"	, MVC_VIEW_ORDEM, "16")

		//Corrige Os Títulos dos Campos
		oStruSG1O:SetProperty("G1_COD"		, MVC_VIEW_TITULO, STR0006)	//Produto
		oStruSG1O:SetProperty("B1_DESC"		, MVC_VIEW_TITULO, STR0007)	//Descrição
		oStruSG1O:SetProperty("G1_TRT"		, MVC_VIEW_TITULO, STR0020)	//Seq.
		oStruSG1O:SetProperty("G1_REVINI"	, MVC_VIEW_TITULO, STR0008)	//Rev.Ini.
		oStruSG1O:SetProperty("G1_REVFIM"	, MVC_VIEW_TITULO, STR0009)	//Rev.Final
		oStruSG1O:SetProperty("G1_QUANT"	, MVC_VIEW_TITULO, STR0010)	//Qtde. Necessária
		oStruSG1O:SetProperty("B1_UM"		, MVC_VIEW_TITULO, STR0011)	//UM
		oStruSG1O:SetProperty("B1_TIPO"		, MVC_VIEW_TITULO, STR0012)	//Tipo
		oStruSG1O:SetProperty("G1_FANTASM"	, MVC_VIEW_TITULO, STR0013)	//Fantasma
		oStruSG1O:SetProperty("G1_INI"		, MVC_VIEW_TITULO, STR0014)	//Vld. Inicial
		oStruSG1O:SetProperty("G1_FIM"		, MVC_VIEW_TITULO, STR0015)	//Vld.Final
		oStruSG1O:SetProperty("G1_LOCCONS"	, MVC_VIEW_TITULO, STR0016)	//Amz.Consumo
		oStruSG1O:SetProperty("G1_GROPC"	, MVC_VIEW_TITULO, STR0018)	//Grp.Opc.
		oStruSG1O:SetProperty("G1_OPC"		, MVC_VIEW_TITULO, STR0019)	//Item Opc.
		oStruSG1O:SetProperty("G1_LISTA"	, MVC_VIEW_TITULO, STR0074)	//Lista

		//Corrige a largura dos Campos
		oStruSG1O:SetProperty("G1_COD"		, MVC_VIEW_WIDTH , 150)
		oStruSG1O:SetProperty("G1_TRT"		, MVC_VIEW_WIDTH , 60)
		oStruSG1O:SetProperty("G1_REVINI"	, MVC_VIEW_WIDTH , 55)
		oStruSG1O:SetProperty("G1_REVFIM"	, MVC_VIEW_WIDTH , 65)
		oStruSG1O:SetProperty("G1_QUANT"	, MVC_VIEW_WIDTH , 105)
		oStruSG1O:SetProperty("B1_UM"		, MVC_VIEW_WIDTH , 40)
		oStruSG1O:SetProperty("B1_TIPO"		, MVC_VIEW_WIDTH , 40)
		oStruSG1O:SetProperty("G1_FANTASM"	, MVC_VIEW_WIDTH , 70)
		oStruSG1O:SetProperty("G1_INI"		, MVC_VIEW_WIDTH , 70)
		oStruSG1O:SetProperty("G1_FIM"		, MVC_VIEW_WIDTH , 70)
		oStruSG1O:SetProperty("G1_LOCCONS"	, MVC_VIEW_WIDTH , 95)
		oStruSG1O:SetProperty("CORIGARM"	, MVC_VIEW_WIDTH , 95)
		oStruSG1O:SetProperty("G1_GROPC"	, MVC_VIEW_WIDTH , 65)
		oStruSG1O:SetProperty("G1_OPC"		, MVC_VIEW_WIDTH , 65)
		oStruSG1O:SetProperty("G1_LISTA"	, MVC_VIEW_WIDTH , 45)

	EndIf
Return

/*/{Protheus.doc} MontaTree
Cria Tree de Estrutura Invertida com base na SG1: do COMPONENTE ao PAI
@author brunno.costa
@since 08/10/2018
@version P12
@return Nil
@param oView, object, objeto da view
@param oModel, object, objeto do modelo
@type Function
/*/
Static Function MontaTree(oPanel, oModel, lFirst)

	Local cAliasTmp		:= CrAliasCmp()
	Local cComponente	:= Iif(!SG1->(Eof()), SG1->G1_COMP, MV_PAR01)
	Local cCompAnter	:= ""
	Local cCargo		:= ""
	Local cFirCarBkp	:= ""
	Local aLocal        := {}
	Local nTamCod    	:= GetSx3Cache("G1_COD","X3_TAMANHO")
	Local lVazio        := .T.

	Default lFirst := .T.

	cFistCargo	:= Nil

	//Seta regua infinita
	ProcRegua(0)

	If lFirst
		oDbTree				:= DbTree():New(0,0,100,100, oPanel,,,.T.)
		oDbTree:Align		:= CONTROL_ALIGN_ALLCLIENT
		oDbTree:bChange		:= {|o,x,y| AcaoTreeCh() }						// Posicao x,y em relacao a Dialog
	Else
		//Em caso de alteração de parâmetros, reseta a Tree e limpa variáveis de controle de índice e nível
		oDbTree:Reset()
		nIndex		:= 0
	EndIf

	If Empty(asCargos2Niv)
		asCargos2Niv	:= {}
	Else
		aSize(asCargos2Niv, 0)
	EndIf

	If Empty(asDbTree)
		asDbTree	:= {}
	Else
		aSize(asDbTree, 0)
	EndIf

	//Sem componentes válidos para regra de filtro
	If !(cAliasTmp)->(Eof())
		//Processa a Regua
		IncProc()

		cFirCarBkp	:= Nil
		cFistCargo	:= Nil

		//Percorre 1o Nível da Tree - Componentes
		While !(cAliasTmp)->(Eof())
			//Se o Local não está preenchido na estrutura e está sendo usado no filtro
			If Empty((cAliasTmp)->G1_LOCCONS) .And. (!Empty(MV_PAR07) .Or. !Empty(MV_PAR08))

				aLocal := PCPXLocCmp((cAliasTmp)->G1_COD   ,;
				                     (cAliasTmp)->G1_COMP  ,;
									 (cAliasTmp)->G1_TRT   ,;
									 (cAliasTmp)->G1_REVFIM)
				If aLocal[1] < MV_PAR07 .Or. aLocal[1] > MV_PAR08
					(cAliasTmp)->(DbSkip())
					Loop
				EndIf
			EndIf

			If !Empty(cCompAnter) .And. cCompAnter == (cAliasTmp)->G1_COMP
				(cAliasTmp)->(DbSkip())
				Loop
			EndIf
			cCompAnter := (cAliasTmp)->G1_COMP

			lVazio      := .F.
			aAreaAux 	:= (cAliasTmp)->(GetArea())
			cComponente	:= (cAliasTmp)->G1_COMP
			TreeRecInv(oPanel, cComponente, Nil/*cCargo*/, cAliasTmp)
			oDbTree:TreeSeek(cFistCargo)
			oDbTree:PTCollapse()		//Recolhe Pasta
			RestArea(aAreaAux)
			(cAliasTmp)->(DbSkip())
			If Empty(cFirCarBkp) .AND. !Empty(cFistCargo)
				cFirCarBkp	:= cFistCargo
				cFistCargo	:= Nil
			ElseIf !Empty(cFistCargo)
				cFistCargo	:= Nil
			EndIf
		EndDo

		If !Empty(cFirCarBkp)
			oDbTree:TreeSeek(cFirCarBkp)//Posiciona no primeiro Item
			oDbTree:PTCollapse()		//Recolhe Pasta
		EndIf
		AcaoTreeCh()
	EndIf

	If lVazio
		cComponente	:= ""
		cCargo		:= Space(nTamCod) +;
						Space(nTamCod) +;
						StrZero(0, 9) +;
						StrZero(0, 9) + 'CODI'

		TreeRecInv(oPanel, cComponente, cCargo, cAliasTmp)
	EndIf

	(cAliasTmp)->(DbCloseArea())
Return

/*/{Protheus.doc} CrAliasCmp
Cria alias com os dados dos componentes
@author brunno.costa
@since 08/10/2018
@version 12
@return aLoad
@type function
/*/

Static Function CrAliasCmp()

	Local cAliasTmp		:= GetNextAlias()
	Local cQuery		:= ""
	Local cCmplWhere	:= ""

	cQuery += " SELECT DISTINCT G1_COMP, SB1_COMP.B1_DESC, G1_COD, G1_TRT, G1_LOCCONS, G1_REVFIM"
	cQuery += " FROM " + RetSqlName("SG1") + ", " + RetSqlName("SB1") + " SB1_COMP, " + RetSqlName("SB1") + " SB1_PROD "
	cQuery += " WHERE " + RetSqlName("SG1") + ".D_E_L_E_T_=' ' AND "
	cQuery += " 	SB1_COMP.D_E_L_E_T_=' ' AND "
	cQuery += " 	SB1_PROD.D_E_L_E_T_=' ' AND "
	cQuery += " 	SB1_COMP.B1_COD = G1_COMP AND "
	cQuery += " 	SB1_PROD.B1_COD = G1_COD AND "
	cQuery += " 	SB1_COMP.B1_FILIAL = '"+ xFilial("SB1")+ "' AND "
	cQuery += " 	SB1_PROD.B1_FILIAL = '"+ xFilial("SB1")+ "' AND "
	cQuery += " 	G1_FILIAL = '"+ xFilial("SG1")+ "' "

	//Prepara variável cComplWhere com regras para filtro 1o Nível
	RgrFiltro(1, @cCmplWhere)
	cQuery += cCmplWhere

	cQuery += "ORDER BY G1_COMP "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	(cAliasTmp)->(DbGoTop())

Return cAliasTmp

/*/{Protheus.doc} TreeRecInv
Adiciona 1o (Componentes) e 2o (Pais) Nível na Tree
@author brunno.costa
@since 08/10/2018
@version P12
@return lRet, logic, em desuso
@param oPanel, object, Box onde a Tree será montada
@param cComponente, characters, código do produto Pai da Estrutura
@param cCargo, characters, Cargo do Produto no Tree
@type Function
/*/

Static Function TreeRecInv(oPanel, cComponente, cCargo, cAliasTmp)

	Local aAreaSG1	:= SG1->(GetArea())
	Local cPrompt	:= ''
	Local lRet		:= .T.
	Local nTamCod   := GetSx3Cache("G1_COD","X3_TAMANHO")
	Local oView		:= FwViewActive()

	SG1->(dbSetOrder(2))
	If Empty(cComponente) .OR. !SG1->(dbSeek(xFilial('SG1') + cComponente, .F.))
		oDbTree:Refresh()
		oDbTree:SetFocus()
		lRet := .F.

		//Se for a primeira chamada e não possui estrutura, apenas exibe o produto pai na Tree
		If nIndex == 0
			cPrompt	:= STR0017	//SEM RESULTADOS P/ FILTRO
			oDbTree:AddTree(cPrompt, .F., 'FOLDER5', 'FOLDER6', , , cCargo)
			oDbTree:EndTree()
			If !Empty(oView) .and. oView:isActive()
				AcaoTreeCh()
			EndIf
		EndIf

	Else

		//-- Posiciona no SB1
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial('SB1') + cComponente, .F.))

		If cCargo == Nil
			cCargo	:= (cAliasTmp)->G1_COMP + ;
						Space(nTamCod) + ;
						StrZero(SG1->(Recno()), 9) + ;
						StrZero(nIndex++, 9) + 'CODI'
		EndIf

		If cFistCargo == Nil
			cFistCargo := cCargo
		EndIf

		//Adiciona o Pai na Estrutura
		cPrompt 	:= PromptTree(Left(cCargo, nTamCod))
		oDbTree:AddTree(cPrompt, .F., 'FOLDER5', 'FOLDER6', , , cCargo)
		oDbTree:TreeSeek(cCargo)

		//Adiciona o Pai no array da Tree
		aAdd(asDbTree,{cCargo, ""})

		//Processa o Próximo Nível
		NextNivel(cCargo, 1)

		oDbTree:EndTree()

		//Atualiza obj.dbtree apos processar a estrutura
		oDbTree:TreeSeek(cCargo)
		oDbTree:Refresh()
		oDbTree:SetFocus()
	EndIf

	RestArea(aAreaSG1)

Return lRet

/*/{Protheus.doc} NextNivel
Processamento Next Nivel da Estrutura (Recursiva)
@author brunno.costa
@since 08/10/2018
@version P12
@return Nil
@param cCargo, characters, cCargo do item
@param nProximo, numeric, descricao
@type Function
/*/
Static Function NextNivel(cCargo, nProximo)

	Local aAreaSG1	:= SG1->(GetArea())
	Local cOldCargL	:= oDbTree:GetCargo()
	Local cProdSelec:= Left( cCargo, Len(SG1->G1_COD))
	Local nCont 	:= 0
	Local nRecSG1	:= 0

	Default nProximo 	:= 0

	SG1->(dbSetOrder(2))
	If SG1->(dbSeek(xFilial('SG1') + cProdSelec, .F.))
		If nProximo == 2
			//Adiciona cCargo no array que controla a recarga da Tree
			aAdd(asCargos2Niv,cCargo)
		EndIf
		nProximo--
		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COMP == xFilial("SG1")+cProdSelec
			//Bloco de validação de desempenho para não carregar na Tree todos os componentes do 2o nível (não visível)
			//Adiciona apenas um sub-item de 2o Nível para aplicar o [+] da Tree, adiciona os demais ao clicar nele
			If nProximo == 0 .AND. nCont > 0
				Exit
			Endif

			//Processa o próximo nível da estrutura - trecho de loop
			nRecSG1	:= SG1->(Recno())
			If ProcNxtNiv(cCargo, nProximo)
				SG1->(dbSkip())
				Loop
			EndIf

			nCont++
			SG1->(DbGoTo(nRecSG1))
			SG1->(dbSkip())
		EndDo

	EndIf

	oDbTree:TreeSeek(cOldCargL)
	RestArea(aAreaSG1)

Return

/*/{Protheus.doc} ProcNxtNiv
Processamento Next Nível Estrutura - Trecho de Loop (Recursiva)
@author brunno.costa
@since 08/10/2018
@version P12
@return lLoop, logical, indica se deve dar loop no registro atual para não incluir na tree
@param cCargo, characters, cCargo do item
@param nProximo, numeric, controla os próximos níveis que serão processados
@type Function
/*/
Static Function ProcNxtNiv(cCargoPai, nProximo)

	Local aAreaSG1 	:= SG1->(GetArea())
	Local cPrompt  	:= ""
	Local cFolderA := 'FOLDER5'
	Local cFolderB := 'FOLDER6'
	Local cCargo	:= ""
	Local cOldCargo	:= ""
	Local cOldCargL	:= oDbTree:GetCargo()
	Local lLoop 	:= .F.
	Local naScan	:= 0
	Local nTamCod	:= GetSx3Cache("G1_COD","X3_TAMANHO")
	Local lAddItem	:= .T.

	//-- Posiciona no SB1 do produto Pai
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial('SB1') + SG1->G1_COD, .F.))

	//Avalia regras de Filtro para Pular este Produto
	If !RgrFiltro(2)
		lLoop := .T.
		Return lLoop
	EndIf

	cCargo	:= SG1->G1_COD +;
				SG1->G1_COMP +;
				StrZero(SG1->(Recno()), 9) +;
				StrZero(nIndex++, 9) + 'COMP'

	//-- Define as Pastas a serem usadas
	If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
		cFolderA := 'FOLDER7'
		cFolderB := 'FOLDER8'
	EndIf

	//Verifica se já adicionou o item na Tree - Com Recno
	//naScan	:=	aScan(asDbTree,{|x| x[2] == cCargoPai .and.;
	//			Left(x[1],Len(cCargo)-13) == Left(cCargo,Len(cCargo)-13) } )

	//Verifica se já adicionou o item na Tree - Sem Recno
	naScan	:=	aScan(asDbTree,{|x| x[2] == cCargoPai .and.;
				Left(x[1],Len(cCargo)-22) == Left(cCargo,Len(cCargo)-22) } )

	If naScan > 0
		nIndex--
		cCargo	:= asDbTree[naScan][1]
	EndIf

	//Se não encontra o Cargo na Tree, adiciona
	cOldCargo := oDbTree:GetCargo()
	If !oDbTree:TreeSeek(cCargo)
		lAddItem	:= .T.
	ElseIf Len(AllTrim(oDbTree:GetCargo())) != Len(AllTrim(cCargo))
		lAddItem	:= .T.
	Else
		lAddItem	:= .F.
	EndIf
	oDbTree:TreeSeek(cOldCargo)

	If lAddItem
		If !oDbTree:TreeSeek(cCargo)
			aAdd(asDbTree,{cCargo, oDbTree:GetCargo()})
			cPrompt	:= PromptTree(Left(cCargo, nTamCod))
			oDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderB,,, 2)

		ElseIf Len(AllTrim(oDbTree:GetCargo())) != Len(AllTrim(cCargo))
			oDbTree:TreeSeek(cOldCargo)
			aAdd(asDbTree,{cCargo, oDbTree:GetCargo()})
			cPrompt	:= PromptTree(Left(cCargo, nTamCod))
			oDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderB,,, 2)
		EndIf
	EndIf

	//Se necessário, processa o próximo nível
	If nProximo > 0
		oDbTree:TreeSeek(cCargo)
		NextNivel(cCargo, nProximo)
		oDbTree:PTCollapse()
	EndIf

	oDbTree:TreeSeek(cOldCargL)

	RestArea(aAreaSG1)

Return lLoop

/*/{Protheus.doc} AcaoTreeCh
Execuções de ações durante clique/change na Tree
@author brunno.costa
@since 08/10/2018
@version P12
@return Nil
@type Function
/*/
Static Function AcaoTreeCh()

	Local cCargo		:= oDbTree:GetCargo()
	Local oView			:= FwViewActive()
	Local oModel		:= oView:GetModel()
	Local oGridOnde		:= oModel:GetModel("GRID_ONDE")

	//oDbTree:cToolTip  := "Seleção atual: " + oDbTree:GetPrompt()

	//Somente para os PI's não abertos nos próximos dois níveis
	If !Empty(cCargo) .AND. aScan(asCargos2Niv,{|x| x == cCargo } ) == 0
		NextNivel(cCargo, 2)
	EndIf

	//Reload Grid de Produtos Pai - Onte os Componentes são Usados
	oGridOnde:ClearData(.F., .F.)
	oGridOnde:DeActivate()
	oGridOnde:lForceLoad := .T.
	oGridOnde:bLoad := {|| bLoadOnde(cCargo, oModel)}
	oGridOnde:Activate()

	//Reload Field do componente selecionado
	LoadSelec(cCargo, oModel)

	If oView:isActive()
		oView:Refresh("V_GRID_ONDE")
		oView:Refresh("V_FLD_SELECT")
	EndIf

	oDbTree:SetFocus()

Return

/*/{Protheus.doc} RetPrdCarg
Retorna o código do produto selecionado referente o cargo
@author brunno.costa
@since 08/10/2018
@version P12
@return componente, caracters, código do produto relacionado ao cCargo
@param cCargo, characters, descricao
@type Function
/*/

Static Function RetPrdCarg(cCargo, lProdPai)
	Local cComponente
	Default lProdPai	:= .F.

	If !lProdPai
		cComponente 	:= SubStr(cCargo,1, GetSx3Cache("G1_COD","X3_TAMANHO"))
	Else
		cComponente 	:= Substr( cCargo, Len(SG1->G1_COMP) + 1, Len(SG1->G1_COD))
	EndIf
Return cComponente


/*/{Protheus.doc} PromptTree
Gera o texto Prompt de exibição do item na Tree
@author brunno.costa
@since 08/10/2018
@version P12
@return cPrompt, chacacters, texto Prompt do item na Tree
@param cProduto, characters, Produto relacionado ao item
@type Function
/*/
Static Function PromptTree(cProduto)

	Local aAreaSB1
	Local cRet      := ""
	Local nTamCod   := GetSx3Cache("G1_COD","X3_TAMANHO")

	If cProduto != SB1->B1_COD
		aAreaSB1	:= SB1->(GetArea())
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
	EndIf
	cRet := Pad(AllTrim(SB1->B1_COD), nTamCod)
	If !Empty(aAreaSB1)
		Restarea(aAreaSB1)
	EndIf

Return cRet

/*/{Protheus.doc} LoadSelec
Realiza a carga do registro selecionado na Fields
@author brunno.costa
@since 08/10/2018
@version P12
@return aLoad, array, array de carga da grid Onde se usa
@param cCargo, characters, cCargo referente seleção
@param oModel, modelo, modelo da tela
@type Function
/*/

Static Function LoadSelec(cCargo, oModel)

	Local cProdSelec 	:= RetPrdCarg(cCargo)
	Local oFldSelect	:= oModel:GetModel("FLD_SELECT_134")
	Local nIndCps		:= 0
	Local aFields		:= oFldSelect:oFormModelStruct:aFields
	Local aAreaSB1		:= SB1->(GetArea())

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial('SB1') + cProdSelec, .F.))
	For nIndCps := 1 to Len(aFields)
			oFldSelect:LoadValue(aFields[nIndCps][3], SB1->(&(aFields[nIndCps][3])))
	Next nIndCps

	RestArea(aAreaSB1)

Return

/*/{Protheus.doc} bLoadOnde
Retorna array com os dados para carga da grid Onde se usa
@author brunno.costa
@since 08/10/2018
@version P12
@return aLoad, array, array de carga da grid Onde se usa
@param cCargo, characters, cCargo referente seleção
@param oModel, modelo, modelo da tela
@type Function
/*/

Static Function bLoadOnde(cCargo, oModel)

	Local aAreaSG1		:= SG1->(GetArea())
	Local aLoad			:= {}
	Local aDefDados		:= {}
	Local cAlias		:= ""
	Local cProdSelec 	:= RetPrdCarg(cCargo)
	Local nIndCps		:= 0
	Local oGridOnde		:= oModel:GetModel("GRID_ONDE")
	Local aFields		:= oGridOnde:oFormModelStruct:aFields
	Local aLocal		:= {}
	Local nAddFields	:= Len(aFields)

	For nIndCps := 1 to nAddFields
		aAdd(aDefDados,Nil)
	Next nIndCps

	SG1->(dbSetOrder(2))
	If SG1->(dbSeek(xFilial('SG1') + cProdSelec, .F.))

		SB1->(dbSetOrder(1))
		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COMP == xFilial("SG1")+cProdSelec
			//-- Posiciona no SB1 do produto Pai
			SB1->(dbSeek(xFilial('SB1') + SG1->G1_COD, .F.))

			//Avalia regras de Filtro para Pular este Produto
			If !RgrFiltro(2)
				SG1->(dbSkip())
				Loop
			EndIf

			aLocal := PCPXLocCmp(SG1->G1_COD   ,;
				                 SG1->G1_COMP  ,;
								 SG1->G1_TRT   ,;
								 SG1->G1_REVFIM)

			For nIndCps := 1 to Len(aFields)
				cAlias	:= "S" + Left(aFields[nIndCps][3],2)
				If AllTrim(aFields[nIndCps][3]) == "G1_FANTASM"
					If AllTrim((cAlias)->(&(aFields[nIndCps][3]))) == "1"
						aDefDados[nIndCps]	:= STR0021	//Sim
					Else
						aDefDados[nIndCps]	:= STR0022	//Não
					EndIf

				ElseIf AllTrim(aFields[nIndCps][3]) == "G1_LOCCONS"
					aDefDados[nIndCps] := aLocal[1]

				ElseIf AllTrim(aFields[nIndCps][3]) == "RECNO"
					aDefDados[nIndCps] := SG1->(RECNO())

				ElseIf AllTrim(aFields[nIndCps][3]) == "CORIGARM"
					If aLocal[2] == 1
						aDefDados[nIndCps] := STR0037 //"Estrutura"
					ElseIf aLocal[2] == 2
						aDefDados[nIndCps] := STR0038 //"Centro de Trabalho"
					ElseIf aLocal[2] == 3
						aDefDados[nIndCps] := STR0121 //"Versão da Produção"
					Else
						aDefDados[nIndCps] := STR0039 //"Produto"
					EndIf
				Else
					aDefDados[nIndCps]	:= (cAlias)->(&(aFields[nIndCps][3]))
				EndIf
			Next nIndCps
			aAdd(aLoad,{0,aClone(aDefDados)})

			SG1->(dbSkip())
		EndDo

	EndIf
	RestArea(aAreaSG1)
Return aLoad

/*/{Protheus.doc} PromptTree
Regras de Filtro da Seleção
@author brunno.costa
@since 08/10/2018
@version P12
@return cPrompt, chacacters, texto Prompt do item na Tree
@param nOpc      , numérico, indica a origem da seleção
- 1: Select 1o Nível da Tree
- 2: Demais níveis Tree ou Load Grid Onde é Usado (Loop)
@param cWhere    , caractere, em caso de nOpc == 1, variável recebida por referência
@param lFilG1COMP, lógico   , indica se deve considerar o filtro de componente na query
@type Function
/*/

Static Function RgrFiltro(nOpc, cWhere, lFilG1COMP)

	Local cLocal       := ""
	Local lRet		   := .T.

	Default cWhere     := ""
	Default lFilG1COMP := .T.

	Pergunte("PCPA134", .F.)

	//Select 1o Nível da Tree
	If nOpc == 1
		//Filtro por Componente
		If lFilG1COMP
			If !Empty(MV_PAR01)
				cWhere += " 	AND G1_COMP >= '" + MV_PAR01 + "' "
			EndIf
			If!Empty(MV_PAR02)
				cWhere += " 	AND G1_COMP <= '" + MV_PAR02 + "' "
			EndIf
		Endif

		//Filtro por Quantidade
		If MV_PAR03<>0
			cWhere += " 	AND G1_QUANT >= " + cValToChar(MV_PAR03) + " "
		EndIf
		If MV_PAR04<>0
			cWhere += " 	AND G1_QUANT <= " + cValToChar(MV_PAR04) + " "
		EndIf

		//Filtro por Validade
		If !Empty(MV_PAR05)
			cWhere += " 	AND (G1_INI >= '" + DtoS(MV_PAR05) + "' OR G1_INI IS NULL OR G1_INI = ' ') "
		EndIf
		If !Empty(MV_PAR06)
			cWhere += " 	AND (G1_FIM <= '" + DtoS(MV_PAR06) + "' OR G1_FIM IS NULL OR G1_FIM = ' ') "
		EndIf

		//Filtro de Revisão Atual
		If MV_PAR09 == 1
			cWhere += " 	AND SB1_PROD.B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM "
		EndIf

		//Filtro Tipo do Produto Pai
		If !Empty(MV_PAR10)
			cWhere += " 	AND SB1_PROD.B1_TIPO IN ('"+StrTran(MV_PAR10,",","','")+"') "
		EndIf

	//Demais níveis Tree ou Load Grid Onde é Usado (Loop)
	Else

		//Filtro de Quantidade De-Até
		If (MV_PAR03<>0 .AND. SG1->G1_QUANT < MV_PAR03);
			.OR. (MV_PAR04<>0 .AND. SG1->G1_QUANT > MV_PAR04)
			lRet	:= .F.
		EndIf

		//Filtro de Validade De-Até
		If (!Empty(MV_PAR05) .AND. SG1->G1_INI < MV_PAR05);
			.OR. (!Empty(MV_PAR06) .AND. SG1->G1_FIM > MV_PAR06)
			lRet	:= .F.
		EndIf

		//Filtro de Armazém De-Até
		If !Empty(MV_PAR07) .Or. !Empty(MV_PAR08)
			If Empty(SG1->G1_LOCCONS)
				cLocal := PCPXLocCmp(SG1->G1_COD   ,;
				                     SG1->G1_COMP  ,;
				                     SG1->G1_TRT   ,;
				                     SG1->G1_REVFIM)[1]
			Else
				cLocal := SG1->G1_LOCCONS
			EndIf

			If cLocal < MV_PAR07 .Or. cLocal > MV_PAR08
				lRet	:= .F.
			EndIf
		EndIf

		//-- Pula Produtos Pai não correspondentes a revisão do Componente
		If MV_PAR09 == 1 .AND. !ValRevisao(SG1->G1_COD,SG1->G1_REVINI,SG1->G1_REVFIM)
			lRet	:= .F.
		EndIf

		//-- Pula Pais com Tipo diferente do filtro
		If !Empty(MV_PAR10) .AND. !("|"+SB1->B1_TIPO+"|"$"|"+StrTran(AllTrim(MV_PAR10),",","|")+"|")
			lRet	:= .F.
		EndIf

	Endif

Return lRet

/*/{Protheus.doc} LLoadOld
Valida a Revisao Atual do Produto
@author brunno.costa
@since 08/10/2018
@version 12
@return lRet
@type function
/*/
Static Function ValRevisao(cCod,cRevIni,cRevFim)
	Local aAreaSB1
	Local cAlias
	Local cRevAtu		:= ''
	Local lRet     		:= .T.

	slPCPREVATU	:= Iif(slPCPREVATU == Nil, FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.), slPCPREVATU)

	//Verifica Produto PAI do compomente
	If SB1->B1_COD != cCod
		cAlias   		:= Alias()
		aAreaSB1 		:= SB1->(GetArea())
		SB1->( MsSeek(xFilial("SB1")+cCod) )
	EndIf
	cRevAtu := IIF(slPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )
	If !(cRevAtu >= cRevIni .And. cRevAtu <= cRevFim)
		lRet :=.F.
	Endif

	If !Empty(cAlias)
		RestArea(aAreaSB1)
		dbSelectArea(cAlias)
	EndIf
Return lRet

/*/{Protheus.doc} PCPA134SB1
Função para validar se o produto é um componente (Usado na Consulta Padrão SB1CMP)
@author brunno.costa
@since 08/10/2018
@version 12
@return lRet, Lógico, Caso .T. adiciona o registro, caso .F. registro não é mostrado.
@type function
/*/
//-------------------------------------------------------------------
Function PCPA134SB1()

	Local aAreaSG1 	:= SG1->(GetArea()) // Salva área posicionada.
	Local cProduto 	:= SB1->B1_COD
	Local lRet     	:= .T.

	dbSelectArea("SG1")
	SG1->(dbSetOrder(2))
	If !SG1->(dbSeek(xFilial("SG1") + cProduto)) // Verifica se o produto é produzido.
		lRet := .F.
	EndIf

	RestArea(aAreaSG1) // Retorna área salva.
	DbSelectArea("SB1") //Retorna Alias SB1 como ativo para evitar error.log

Return lRet

/*/{Protheus.doc} execAlt
Abre a tela de modificação
@type  Static Function
@author lucas.franca
@since 01/02/2019
@version P12
@param oView, Object, Objeto da VIEW
@return lRet, Logical, Identifica se a view foi aberta.
/*/
Static Function execAlt(oView)

	Local lAbort     := .F.
	Local oOldView

	//Recarrega os componentes
	a134RecCmp(oView)

	//Remove as teclas de atalho
	LoadPesqVK(oView, 5)

	//Abre a tela de alteração
	lRet := PCPA134Alt(oView)

	//Atribui as teclas de atalho
	LoadPesqVK(oView, 0)

	//Se processou a alteração, recarrega os componentes em tela.
	If lRet
		oOldView   := FwViewActive()
		Processa({|| a134RecCmp(oView) }, STR0114, STR0115, lAbort) //"Recarregando..." - "Aguarde o término do processamento."
		If oOldView != Nil
			FwViewActive(oOldView)
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} a134RecCmp
Recarrega os componentes em tela.
@author brunno.costa
@since 04/04/2019
@version P12
@param 01 oView, object, objeto da View
/*/
Function a134RecCmp(oView)

	//Seta barra infinita
	ProcRegua(0)

	//Processa a Regua
	IncProc()

	//Execuções de ações durante clique/change na Tree
	AcaoTreeCh()

	//Processa a Regua
	IncProc()

	//Atualiza a imagem da TREE de acordo com a data de validade dos componentes.
	AtuImgTree(oView:GetModel())

Return

/*/{Protheus.doc} AtuImgTree
Atualiza a imagem da TREE de acordo com a data de validade dos componentes.
@type  Static Function
@author lucas.franca
@since 11/02/2019
@version P12
@param  oModel, Object, Modelo de dados da consulta Onde se Usa
@return Nil
/*/
Static Function AtuImgTree(oModel)
	Local oMdlGrid  := oModel:GetModel("GRID_ONDE")
	Local nIndex    := 0
	Local nPos      := 0
	Local cFolderA  := 'FOLDER5'
	Local cFolderB  := 'FOLDER6'
	Local cCargoPai := oDbTree:GetCargo()
	Local cCargoCmp := ""

	For nIndex := 1 To oMdlGrid:Length()
		//-- Define as Pastas a serem usadas
		If dDataBase < oMdlGrid:GetValue("G1_INI",nIndex) .Or. dDataBase > oMdlGrid:GetValue("G1_FIM",nIndex)
			//Componente vencido
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		Else
			//Componente dentro das datas de validade
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
		EndIf

		cCargoCmp := PadR(oMdlGrid:GetValue("G1_COD",nIndex) + oMdlGrid:GetValue("G1_COMP",nIndex),Len(cCargoPai))

		nPos := aScan(asDbTree, {|x| x[2] == cCargoPai .And. ;
		                             Left(x[1],Len(cCargoCmp)-22) == Left(cCargoCmp,Len(cCargoCmp)-22)})
		If nPos > 0
			oDbTree:ChangeBmp(cFolderA,cFolderB,,,asDbTree[nPos][1])
		End
	Next nIndex
Return
