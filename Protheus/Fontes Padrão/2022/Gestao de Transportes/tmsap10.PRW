#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAP10.CH"
#INCLUDE "FWMVCDEF.CH"

Static aAliasSon := {"DMJ","DMK","DML","DMM","DMN","DMT"}
Static aAliasVia := {"DMJ","DMK","DMT"}
Static lTipo1    := .F.
Static lTipo2    := .F.
Static lTipo3    := .F.
Static lTipo4    := .F.
Static oPnlInd01, oPnlInd02, oPnlInd03, oPnlInd04, oPnlInd05, oPnlInd06
Static oPnlInd11, oPnlInd12, oPnlInd13, oPnlInd14, oPnlInd15, oPnlInd16
Static oPnlInd21, oPnlInd22, oPnlInd23, oPnlInd24
Static oPnlInd31, oPnlInd32, oPnlInd33, oPnlInd34
Static oPnlInd41, oPnlInd42, oPnlInd43, oPnlInd44
Static oPnlInd51, oPnlInd52, oPnlInd53, oPnlInd54, oPnlInd55, oPnlInd56

/*{Protheus.doc} TMSAP10
    Conciliação de Pedágio
    @type Function
    @author Valdemar Roberto Mognon
    @since 31/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAP10()
    (examples)
    @see (links_or_references)
*/
Function TMSAP10()

oBrowse:= FwMBrowse():New()
oBrowse:SetAlias("DMI")
oBrowse:SetDescription(OemToAnsi(STR0001))	//-- "Conciliação de Pedágio"
oBrowse:AddStatusColumns({|| StatusConf()},{|| LegendConf()})
oBrowse:Activate()

lTipo1    := .F.
lTipo2    := .F.
lTipo3    := .F.
lTipo4    := .F.

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 31/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION  1 ACCESS 0	//-- "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAP10" OPERATION  2 ACCESS 0	//-- "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAP10" OPERATION  4 ACCESS 0	//-- "Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAP10" OPERATION  5 ACCESS 0	//-- "Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "TMSAP10Con(1)"   OPERATION 10 ACCESS 0	//-- "Conferir"
ADD OPTION aRotina TITLE STR0008 ACTION "TMSAP10Con(2)"   OPERATION 11 ACCESS 0	//-- "Estornar Conferência"
ADD OPTION aRotina TITLE STR0009 ACTION "TMSAP10Via"      OPERATION 12 ACCESS 0	//-- "Gerar Viagem"
ADD OPTION aRotina TITLE STR0010 ACTION "TMSAP10Ped(1)"   OPERATION 13 ACCESS 0	//-- "Gerar Pedido de Compra"
ADD OPTION aRotina TITLE STR0011 ACTION "TMSAP10Ped(2)"   OPERATION 14 ACCESS 0	//-- "Excluir Pedido de Compra"
ADD OPTION aRotina TITLE STR0044 ACTION "TMSAP10Man()"    OPERATION 15 ACCESS 0	//-- "Conciliação Manual"

Return aRotina

/*{Protheus.doc} ModelDef
    Definição do Modelo
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 31/08/2021
    @version P12 R12.1.20
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel
Local oStruDMI  := FwFormStruct(1,"DMI")
Local oStruDMJ  := FwFormStruct(1,"DMJ")
Local oStruDMK  := FwFormStruct(1,"DMK")
Local oStruDML  := FWFormStruct(1,"DML")
Local oStruDMM  := FwFormStruct(1,"DMM")
Local oStruDMN  := FwFormStruct(1,"DMN")
Local oStruDMT  := FwFormStruct(1,"DMT")

//-- Cria campo de legenda de conferência da passagem de pedágio
oStruDMJ:AddField(STR0026				, ;	//-- Titulo do campo
				  STR0026				, ;	//-- ToolTip do campo
				  "CONFPEDA"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMJ->DMJ_CONFER")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de tipo da passagem de pedágio
oStruDMJ:AddField(STR0027				, ;	//-- Titulo do campo
				  STR0027				, ;	//-- ToolTip do campo
				  "TIPOPEDA"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMJ->DMJ_TIPO")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de conferência do estacionamento
oStruDMK:AddField(STR0026				, ;	//-- Titulo do campo
				  STR0026				, ;	//-- ToolTip do campo
				  "CONFESTA"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMK->DMK_CONFER")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de tipo do estacionamento
oStruDMK:AddField(STR0027				, ;	//-- Titulo do campo
				  STR0027				, ;	//-- ToolTip do campo
				  "TIPOESTA"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMK->DMK_TIPO")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de conferência da mensalidade
oStruDML:AddField(STR0026				, ;	//-- Titulo do campo
				  STR0026				, ;	//-- ToolTip do campo
				  "CONFMENS"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DML->DML_CONFER")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de tipo da mensalidade
oStruDML:AddField(STR0027				, ;	//-- Titulo do campo
				  STR0027				, ;	//-- ToolTip do campo
				  "TIPOMENS"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DML->DML_TIPO")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de conferência do crédito
oStruDMM:AddField(STR0026				, ;	//-- Titulo do campo
				  STR0026				, ;	//-- ToolTip do campo
				  "CONFCRED"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMM->DMM_CONFER")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de tipo do crédito
oStruDMM:AddField(STR0027				, ;	//-- Titulo do campo
				  STR0027				, ;	//-- ToolTip do campo
				  "TIPOCRED"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMM->DMM_TIPO")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de conferência da adesão
oStruDMN:AddField(STR0026				, ;	//-- Titulo do campo
				  STR0026				, ;	//-- ToolTip do campo
				  "CONFADES"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMN->DMN_CONFER")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de tipo da adesão
oStruDMN:AddField(STR0027				, ;	//-- Titulo do campo
				  STR0027				, ;	//-- ToolTip do campo
				  "TIPOADES"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMN->DMN_TIPO")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de conferência do abastecimento
oStruDMT:AddField(STR0026				, ;	//-- Titulo do campo
				  STR0026				, ;	//-- ToolTip do campo
				  "CONFABAS"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMT->DMT_CONFER")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Cria campo de legenda de tipo do abastecimento
oStruDMT:AddField(STR0027				, ;	//-- Titulo do campo
				  STR0027				, ;	//-- ToolTip do campo
				  "TIPOABAS"			, ;	//-- Nome do Campo
				  "BT"					, ;	//-- Tipo do campo
				  20				 	, ;	//-- Tamanho do campo
				  0						, ;	//-- Decimal do campo
				  Nil					, ;	//-- Code-block de validação do campo
				  Nil					, ;	//-- Code-block de validação When do campo
				  {} 					, ;	//-- Lista de valores permitido do campo
				  .F.					, ;	//-- Indica se o campo tem preenchimento obrigatório
				  {|| AddCampo("DMT->DMT_TIPO")}	, ;	//-- Code-block de inicializacao do campo
				  Nil 		 			, ;	//-- Indica se trata de um campo chave
				  Nil 					, ;	//-- Indica se o campo pode receber valor em uma operação de update.
				  .T. 					)	//-- Indica se o campo é virtual

//-- Remove campos das estruturas
oStruDMJ:RemoveField("DMJ_MARK")
oStruDMK:RemoveField("DMK_MARK")
oStruDML:RemoveField("DML_MARK")
oStruDMM:RemoveField("DMM_MARK")
oStruDMN:RemoveField("DMN_MARK")
oStruDMT:RemoveField("DMT_MARK")

oModel := MpFormModel():New("TMSAP10",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:SetDescription(STR0001)	//-- "Conciliação de Pedágio"

//-- Cabeçalho da Conciliação
oModel:AddFields("MdFieldDMI",,oStruDMI,,,)
oModel:SetPrimaryKey({"DMI_NUMERO"})
oModel:GetModel("MdFieldDMI"):SetDescription(STR0001)	//-- "Conciliação de Pedágio"

//-- Grid dos Motoristas
oModel:AddGrid("MdGridDMJ","MdFieldDMI",oStruDMJ,/*bLinePre*/,/*bLinePos*/,,,)
oModel:SetRelation("MdGridDMJ",{{"DMJ_FILIAL","xFilial('DMJ')"},;
								{"DMJ_NUMCON","DMI_NUMERO"}},;
								DMJ->(IndexKey(1)))
oModel:GetModel("MdGridDMJ"):SetOptional(.T.)

//-- Grid dos Estacionamentos
oModel:AddGrid("MdGridDMK","MdFieldDMI",oStruDMK,/*bLinePre*/,/*bLinePos*/,,,)
oModel:SetRelation("MdGridDMK",{{"DMK_FILIAL","xFilial('DMK')"},;
								{"DMK_NUMCON","DMI_NUMERO"}},;
								DMK->(IndexKey(1)))
oModel:GetModel("MdGridDMK"):SetOptional(.T.)

//-- Grid das Mensalidades
oModel:AddGrid("MdGridDML","MdFieldDMI",oStruDML,/*bLinePre*/,/*bLinePos*/,,,)
oModel:SetRelation("MdGridDML",{{"DML_FILIAL","xFilial('DML')"},;
								{"DML_NUMCON","DMI_NUMERO"}},;
								DML->(IndexKey(1)))
oModel:GetModel("MdGridDML"):SetOptional(.T.)

//-- Grid dos Créditos
oModel:AddGrid("MdGridDMM","MdFieldDMI",oStruDMM,/*bLinePre*/,/*bLinePos*/,,,)
oModel:SetRelation("MdGridDMM",{{"DMM_FILIAL","xFilial('DMM')"},;
								{"DMM_NUMCON","DMI_NUMERO"}},;
								DMM->(IndexKey(1)))
oModel:GetModel("MdGridDMM"):SetOptional(.T.)

//-- Grid das Adesões
oModel:AddGrid("MdGridDMN","MdFieldDMI",oStruDMN,/*bLinePre*/,/*bLinePos*/,,,)
oModel:SetRelation("MdGridDMN",{{"DMN_FILIAL","xFilial('DMN')"},;
								{"DMN_NUMCON","DMI_NUMERO"}},;
								DMN->(IndexKey(1)))
oModel:GetModel("MdGridDMN"):SetOptional(.T.)

//-- Grid dos Abastecimentos
oModel:AddGrid("MdGridDMT","MdFieldDMI",oStruDMT,/*bLinePre*/,/*bLinePos*/,,,)
oModel:SetRelation("MdGridDMT",{{"DMT_FILIAL","xFilial('DMT')"},;
								{"DMT_NUMCON","DMI_NUMERO"}},;
								DMT->(IndexKey(1)))
oModel:GetModel("MdGridDMT"):SetOptional(.T.)

oModel:SetVldActivate({|oModel| TMSAP10Pre(oModel)})

Return oModel

/*{Protheus.doc} ViewDef
    Definição da View
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 31/08/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()
Local oView
Local oModel   := FwLoadModel("TMSAP10")
Local oStruDMI := FwFormStruct(2,"DMI")
Local oStruDMJ := FwFormStruct(2,"DMJ")
Local oStruDMK := FwFormStruct(2,"DMK")
Local oStruDML := FWFormStruct(2,"DML")
Local oStruDMM := FwFormStruct(2,"DMM")
Local oStruDMN := FwFormStruct(2,"DMN")
Local oStruDMT := FwFormStruct(2,"DMT")

//-- Cria campo de legenda de conferência da passagem de pedágio
oStruDMJ:AddField("CONFPEDA"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0026		, ; //-- Titulo do campo
				  STR0026		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de tipo da passagem de pedágio
oStruDMJ:AddField("TIPOPEDA"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0027		, ; //-- Titulo do campo
				  STR0027		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de conferência do estacionamento
oStruDMK:AddField("CONFESTA"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0026		, ; //-- Titulo do campo
				  STR0026		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de tipo do estacionamento
oStruDMK:AddField("TIPOESTA"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0027		, ; //-- Titulo do campo
				  STR0027		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de conferência da mensalidade
oStruDML:AddField("CONFMENS"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0026		, ; //-- Titulo do campo
				  STR0026		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de tipo da mensalidade
oStruDML:AddField("TIPOMENS"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0027		, ; //-- Titulo do campo
				  STR0027		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de conferência do crédito
oStruDMM:AddField("CONFCRED"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0026		, ; //-- Titulo do campo
				  STR0026		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de tipo do crédito
oStruDMM:AddField("TIPOCRED"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0027		, ; //-- Titulo do campo
				  STR0027		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de conferência da adesão
oStruDMN:AddField("CONFADES"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0026		, ; //-- Titulo do campo
				  STR0026		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de tipo da adesão
oStruDMN:AddField("TIPOADES"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0027		, ; //-- Titulo do campo
				  STR0027		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de conferência do abastecimento
oStruDMT:AddField("CONFABAS"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0026		, ; //-- Titulo do campo
				  STR0026		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Cria campo de legenda de tipo do abastecimento
oStruDMT:AddField("TIPOABAS"	, ; //-- Nome do Campo
				  "01"		 	, ; //-- Ordem
				  STR0027		, ; //-- Titulo do campo
				  STR0027		, ; //-- Descrição do campo
				  {" "}			, ; //-- Array com Help
				  "BT"			, ; //-- Tipo do campo
				  "@BMP"		, ; //-- Picture
				  Nil			, ; //-- Bloco de Picture Var
				  ""			, ; //-- Consulta F3
				  .F.			, ; //-- Indica se o campo é editável
				  Nil			, ; //-- Pasta do campo
				  Nil			, ; //-- Agrupamento do campo
				  { }			, ; //-- Lista de valores permitido do campo (Combo)
				  Nil			, ; //-- Tamanho Maximo da maior opção do combo
				  Nil			, ; //-- Inicializador de Browse
				  .T.			, ; //-- Indica se o campo é virtual
				  Nil			)   //-- Picture Variável

//-- Remove campos das estruturas
oStruDMJ:RemoveField("DMJ_MARK")
oStruDMK:RemoveField("DMK_MARK")
oStruDML:RemoveField("DML_MARK")
oStruDMM:RemoveField("DMM_MARK")
oStruDMN:RemoveField("DMN_MARK")
oStruDMT:RemoveField("DMT_MARK")

//-- Cria a View
oView := FwFormView():New()
oView:SetModel(oModel)

//-- Adiciona o Field da Conciliação
oView:AddField("VwFieldDMI",oStruDMI,"MdFieldDMI") 
oView:EnableTitleView("VwFieldDMI",STR0001)	//-- "Conciliação de Pedágio"

oView:AddOtherObject("View_Totais",{|oPanel| MontaInd(oPanel,DMI->DMI_NUMERO)},,)
 
//-- Define a tela principal
oView:CreateHorizontalBox("Pai",040)
oView:CreateFolder("Folder1","Pai")
oView:AddSheet("Folder1","Sheet1_Folder1",STR0055)	//-- "Principal"
oView:AddSheet("Folder1","Sheet2_Folder1",STR0056)	//-- "Totalizadores"
oView:CreateHorizontalBox("BoxPrincipal"     ,100,,,"Folder1","Sheet1_Folder1")
oView:CreateHorizontalBox("BoxTotalizadores" ,100,,,"Folder1","Sheet2_Folder1")
oView:SetOwnerView("VwFieldDMI" ,"BoxPrincipal")
oView:SetOwnerView("View_Totais","BoxTotalizadores")

//-- Adiciona os Grids da Conciliação
oView:CreateHorizontalBox("Filhos",060)

//-- Cria os Folders da tela principal
oView:CreateFolder("Folder2","Filhos")
oView:AddSheet("Folder2","Sheet1_Folder2",STR0012)	//-- "Praças de Pedágio"
oView:AddSheet("Folder2","Sheet2_Folder2",STR0013)	//-- "Estacionamentos"
oView:AddSheet("Folder2","Sheet3_Folder2",STR0014)	//-- "Mensalidades"
oView:AddSheet("Folder2","Sheet4_Folder2",STR0015)	//-- "Créditos"
oView:AddSheet("Folder2","Sheet5_Folder2",STR0016)	//-- "Adesões"
oView:AddSheet("Folder2","Sheet6_Folder2",STR0017)	//-- "Abastecimentos"

oView:CreateHorizontalBox("BoxPraca"         ,100,,,"Folder2","Sheet1_Folder2")
oView:AddGrid("VwGridDMJ",oStruDMJ,"MdGridDMJ")
oView:SetOwnerView("VwGridDMJ","BoxPraca")
oView:AddIncrementField("VwGridDMJ","DMJ_SEQUEN")
oView:SetViewProperty("VwGridDMJ","GRIDDOUBLECLICK",{{|oGrdView,cFieldName,nLineGrid,nLineModel| Legenda(oGrdView,cFieldName,nLineGrid,nLineModel)}})

oView:CreateHorizontalBox("BoxEstacionamento",100,,,"Folder2","Sheet2_Folder2")
oView:AddGrid("VwGridDMK",oStruDMK,"MdGridDMK")
oView:SetOwnerView("VwGridDMK","BoxEstacionamento")
oView:AddIncrementField("VwGridDMK","DMK_SEQUEN")
oView:SetViewProperty("VwGridDMK","GRIDDOUBLECLICK",{{|oGrdView,cFieldName,nLineGrid,nLineModel| Legenda(oGrdView,cFieldName,nLineGrid,nLineModel)}})

oView:CreateHorizontalBox("BoxMensalidade"   ,100,,,"Folder2","Sheet3_Folder2")
oView:AddGrid("VwGridDML",oStruDML,"MdGridDML")
oView:SetOwnerView("VwGridDML","BoxMensalidade")
oView:AddIncrementField("VwGridDML","DML_SEQUEN")
oView:SetViewProperty("VwGridDML","GRIDDOUBLECLICK",{{|oGrdView,cFieldName,nLineGrid,nLineModel| Legenda(oGrdView,cFieldName,nLineGrid,nLineModel)}})

oView:CreateHorizontalBox("BoxCredito"       ,100,,,"Folder2","Sheet4_Folder2")
oView:AddGrid("VwGridDMM",oStruDMM,"MdGridDMM")
oView:SetOwnerView("VwGridDMM","BoxCredito")
oView:AddIncrementField("VwGridDMM","DMM_SEQUEN")
oView:SetViewProperty("VwGridDMM","GRIDDOUBLECLICK",{{|oGrdView,cFieldName,nLineGrid,nLineModel| Legenda(oGrdView,cFieldName,nLineGrid,nLineModel)}})

oView:CreateHorizontalBox("BoxAdesao"        ,100,,,"Folder2","Sheet5_Folder2")
oView:AddGrid("VwGridDMN",oStruDMN,"MdGridDMN")
oView:SetOwnerView("VwGridDMN","BoxAdesao")
oView:AddIncrementField("VwGridDMN","DMN_SEQUEN")
oView:SetViewProperty("VwGridDMN","GRIDDOUBLECLICK",{{|oGrdView,cFieldName,nLineGrid,nLineModel| Legenda(oGrdView,cFieldName,nLineGrid,nLineModel)}})

oView:CreateHorizontalBox("BoxAbastecimento" ,100,,,"Folder2","Sheet6_Folder2")
oView:AddGrid("VwGridDMT",oStruDMT,"MdGridDMT")
oView:SetOwnerView("VwGridDMT","BoxAbastecimento")
oView:AddIncrementField("VwGridDMT","DMT_SEQUEN")
oView:SetViewProperty("VwGridDMT","GRIDDOUBLECLICK",{{|oGrdView,cFieldName,nLineGrid,nLineModel| Legenda(oGrdView,cFieldName,nLineGrid,nLineModel)}})

Return oView

/*{Protheus.doc} AddCampo
    Define as Legendas dos Filhos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 02/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Static Function AddCampo(cCampo)
Local cRet   := ""
Local cAlias := ""

Default cCampo := ""

If "CONFER" $ cCampo
	cRet := Iif(&(cCampo) == "1","BR_VERDE",Iif(&(cCampo) == "2","BR_VERMELHO","BR_AMARELO"))
ElseIf "TIPO" $ cCampo
	cAlias := Left(cCampo,3)
	If cAlias $ "DML:DMM:DMN"
		cRet := Iif(&(cCampo) == "1","BR_AZUL","BR_MARROM")
	Else
		cRet := Iif(&(cCampo) == "1","BR_AZUL",Iif(&(cCampo) == "2","BR_AMARELO",Iif(&(cCampo) == "3","BR_VERDE",Iif(&(cCampo) == "4","BR_MARROM",""))))
	EndIf
ElseIf "VIAGEM" $ cCampo
	cRet := Iif(!Empty(&(cCampo)),"BR_VERDE","BR_VERMELHO")
EndIf

Return cRet

/*{Protheus.doc} Legenda
    Exibe as Legendas dos Filhos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 02/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Static Function Legenda(oGrdView,cFieldName,nLineGrid,nLineModel)
Local aLegenda := {}
Local cMsg1    := ""
Local cMsg2    := ""
Local lRet     := .F.

If "CONF" $ cFieldName
	cMsg1 := STR0030	//-- "Conferência"
	cMsg2 := STR0026	//-- "Conferido?"
	aLegenda := {{"BR_VERDE"   ,STR0031},;	//-- "Conferido"
				 {"BR_VERMELHO",STR0032},;	//-- "Não Conferido"
				 {"BR_AMARELO" ,STR0080}}	//-- "Duplicidade"
	lRet := .T.
ElseIf "TIPO" $ cFieldName
	cMsg1 := STR0037	//-- "Tipo de Passagem"
	cMsg2 := STR0027	//-- "Tipo"
	If "MENS" $ cFieldName .Or. "CRED" $ cFieldName .Or. "ADES" $ cFieldName
		aLegenda := {{"BR_AZUL"   ,STR0054},;	//-- "Com Viagem"
					 {"BR_MARROM" ,STR0039}}	//-- "Particular"
	Else
		aLegenda := {{"BR_AZUL"   ,STR0029},;	//-- "Com Viagem"
					 {"BR_AMARELO",STR0034},;	//-- "Sem Viagem"
					 {"BR_VERDE"  ,STR0038},;	//-- "Viagem Vazia"
					 {"BR_MARROM" ,STR0039}}	//-- "Particular"
	EndIf
	lRet := .T.
ElseIf "VIAG" $ cFieldName
	cMsg1 := STR0035	//-- "Tipo de Viagem"
	cMsg2 := STR0036	//-- "Situação"
	aLegenda := {{"BR_VERDE"   ,STR0033},;	//-- "Com Viagem"
				 {"BR_VERMELHO",STR0034}}	//-- "Sem Viagem"
	lRet := .T.
EndIf

If lRet
	BrwLegenda(cMsg1,cMsg2,aLegenda)
EndIf

Return

/*{Protheus.doc} TMSAP10Con
    Concilia/Exclui a conciliação
    @type Function
    @author Valdemar Roberto Mognon
    @since 02/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Function TMSAP10Con(nAcao)
Local oTMSVIAFCL

Default nAcao := 0

oTMSVIAFCL := TMSBCAVIAFACIL():New()

If nAcao == 1	//-- Conciliar
	//-- Passagem em pedágio
	FwMsgRun(,{|| oTMSVIAFCL:ConcSemParar("DMJ",DMI->DMI_NUMERO)},STR0041,STR0042 + " " + STR0040)	//-- "Processando" # "Conciliando" # "Pedágio"
	//-- Estacionamento
	FwMsgRun(,{|| oTMSVIAFCL:ConcSemParar("DMK",DMI->DMI_NUMERO)},STR0041,STR0042 + " " + STR0013)	//-- "Processando" # "Conciliando" # "Estacionamentos"
	//-- Mensalidade
	FwMsgRun(,{|| oTMSVIAFCL:ConcMensalidade(DMI->DMI_NUMERO,DMI->DMI_CODTAG)},STR0041,STR0042 + " " + STR0014)	//-- "Processando" # "Conciliando" # "Mensalidade"
	//-- Crédito
	FwMsgRun(,{|| oTMSVIAFCL:ConcCredito(DMI->DMI_NUMERO)},STR0041,STR0042 + " " + STR0016)	//-- "Processando" # "Conciliando" # "Adesões"
	//-- Adesão
	FwMsgRun(,{|| oTMSVIAFCL:ConcAdesoes(DMI->DMI_NUMERO,DMI->DMI_CODTAG)},STR0041,STR0042 + " " + STR0016)	//-- "Processando" # "Conciliando" # "Adesões"
	//-- Abastecimento
	FwMsgRun(,{|| oTMSVIAFCL:ConcSemParar("DMT",DMI->DMI_NUMERO)},STR0041,STR0042 + " " + STR0017)	//-- "Processando" # "Conciliando" # "Abastecimentos"
	//-- Fecha Conciliação
	FwMsgRun(,{|| oTMSVIAFCL:FechaConc(DMI->DMI_NUMERO,DMI->DMI_VALFAT)},STR0041,STR0053)	//-- "Processando" # "Fechando Conciliação"
Else	//-- Excluir Conciliação
	FwMsgRun(,{|| oTMSVIAFCL:ExcluiConc(DMI->DMI_NUMERO)},STR0041,STR0043)	//-- "Processando" # "Excluindo Conciliação"
EndIf

Return

/*{Protheus.doc} TMSAP10Via
    Gera Viagem Vazia
    @type Function
    @author Valdemar Roberto Mognon
    @since 02/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Function TMSAP10Via()
Local aCoors   := FWGetDialogSize(oMainWnd)
Local nOpca    := 0
Local nTabela  := 0
Local cAlias   := ""
Local cMarkBrw := GetMark()
Local cTabela  := ""
Local cQuery   := ""
Local cPlaca   := Space(Len(DA3->DA3_PLACA))
Local dData    := CToD("")
Local oMrkBrw, oLayer, oPanelUp1, oPanelUp2, oPanelDown, oButton1, oButton2, oDlgPrinc

If (nTabela := TMSAP10Opc(2)) > 0
	cAlias := aAliasVia[nTabela]
EndIf

cTabela := Iif(cAlias == "DMJ",STR0012,;
		   Iif(cAlias == "DMK",STR0013,;
		   Iif(cAlias == "DMN",STR0016,STR0017)))

If !Empty(cAlias)

	DEFINE MSDIALOG oDlgPrinc TITLE STR0073 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL

		//-- Cria o Layer
		oLayer := FWLayer():New()
		oLayer:Init(oDlgPrinc,.F.,.T.)

		//-- Adiciona Linha	
		oLayer:AddLine("UP"  ,020,.F.)
		oLayer:AddLine("DOWN",070,.F.)

		//-- Adiciona Coluna
		oLayer:AddCollumn("COLUMN1",090,.T.,"UP")
		oLayer:AddCollumn("COLUMN2",010,.T.,"UP")
		oLayer:AddCollumn("ALL"    ,100,.F.,"DOWN")

		//-- Adiciona Janela
		oLayer:AddWindow("COLUMN1","WINDOW1",STR0046,100,.F.,.T.,,"UP",{||})	//-- "Campos"
		oLayer:AddWindow("COLUMN2","WINDOW1",STR0047,100,.F.,.T.,,"UP",{||})	//-- "Ações"

		//-- Adiciona Painel
		oPanelUp1  := oLayer:GetWinPanel("COLUMN1","WINDOW1","UP")
		oPanelUp2  := oLayer:GetWinPanel("COLUMN2","WINDOW1","UP")
		oPanelDown := oLayer:GetColPanel("ALL","DOWN")

		//-- Adiciona Campos para Marcação Rápida
		TSay():New(011,001,{|| STR0048},oPanelUp1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Placa : "
		TSay():New(011,080,{|| STR0049},oPanelUp1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Data : "
	
		TGet():New(010,022,{|u| Iif(PCount() > 0,cPlaca    := u,cPlaca)}   ,oPanelUp1,040,007,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"cPlaca")
		TGet():New(010,098,{|u| Iif(PCount() > 0,dData     := u,dData)}    ,oPanelUp1,050,007,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"dData")

		//-- Botões de Marcação/Desmarcação
		oButton1 := TButton():New(003,002,STR0051,oPanelUp2,{|| TMSAP10Mrk(cAlias,DMI->DMI_NUMERO,cMarkBrw,oMrkBrw,cPlaca,dData)},040,013,,,,.T.,,"",,,,.F.)	//-- "&Marcar"
		oButton2 := TButton():New(018,002,STR0052,oPanelUp2,{|| TMSAP10Mrk(cAlias,DMI->DMI_NUMERO,"  "    ,oMrkBrw,cPlaca,dData)},040,013,,,,.T.,,"",,,,.F.)	//-- "&Desmarcar"

		//-- Adiciona o MarkBrowse das Tabelas		
		oMrkBrw:= FWMarkBrowse():New()
		oMrkBrw:SetOwner(oPanelDown)
		oMrkBrw:SetDescription(cTabela)
		oMrkBrw:SetAlias(cAlias)
		oMrkBrw:SetMenuDef("")
		oMrkBrw:DisableDetails()
		oMrkBrw:AddFilter("MANUAL",cAlias + "->" + cAlias + "_CONFER == '2'",.T.,.T.)
		oMrkBrw:AddMarkColumns({|| Iif(Empty(&(cAlias + "->" + cAlias + "_MARK")),"LBNO","LBOK")},{|| MarkReg(cAlias,cMarkBrw)},{|| MarkAll(cAlias,oMrkBrw,cMarkBrw)})
		oMrkBrw:Activate()

	ACTIVATE MSDIALOG oDlgPrinc ON INIT EnchoiceBar(oDlgPrinc,{|| nOpca := 1,oDlgPrinc:End()},{||oDlgPrinc:End()}) CENTERED

	If nOpca == 1	//-- Salvar
		FwMsgRun(,{|| TMSAP10Ger(cAlias,DMI->DMI_NUMERO,cMarkBrw,DMI->DMI_VALFAT)},STR0041,STR0074)	//-- "Processando" # "Gerando Viagem Vazia"
	EndIf

	cQuery := " UPDATE " + RetSqlName(cAlias)
	cQuery += "    SET " + cAlias + "_MARK   = ' ' "
	cQuery += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cQuery += "    AND " + cAlias + "_NUMCON = '" + DMI->DMI_NUMERO + "' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)

EndIf

Return

/*{Protheus.doc} TMSAP10Ped
    Gera/Exclui pedido de compras
    @type Function
    @author Valdemar Roberto Mognon
    @since 02/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Function TMSAP10Ped(nAcao)
Local cNumero := ""
Local cCodPro := GetMV("MV_PRDCTC",,"")	//-- Produto utilizado para gerar pedido de compras e contrato de carreteiro pessoa jurídica
Local aAreas  := {SA2->(GetArea()),SB1->(GetArea()),GetArea()}
Local aCab    := {}
Local aItem   := {}

Private lMsErroAuto := .F.

If nAcao == 1 .And. DMI->DMI_VALFAT > 0 .And. DMI->DMI_CONFER == StrZero(1,Len(DMI->DMI_CONFER))	//-- Gerar
	cNumero := Criavar("C7_NUM",.T.)
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + cCodPro))
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2") + DMI->DMI_CODFOR + DMI->DMI_LOJFOR))
	
	aCab := {{"C7_NUM"    ,cNumero         ,NIL},;	//-- Numero do Pedido
			 {"C7_EMISSAO",dDataBase       ,NIL},;	//-- Data de Emissão
			 {"C7_FORNECE",SA2->A2_COD     ,NIL},;	//-- Fornecedor aqui
			 {"C7_LOJA"   ,SA2->A2_LOJA    ,NIL},;	//-- Loja do Fornecedor aqui
			 {"C7_CONTATO",SA2->A2_CONTATO ,NIL},;	//-- Contato aqui
			 {"C7_COND"   ,SA2->A2_COND    ,NIL},;	//-- Condicao de Pagamento aqui
			 {"C7_TIPO"   ,1               ,NIL}}	//-- Pedido de Compra

	aItem := {{"C7_ITEM"   ,StrZero(1,Len(SC7->C7_ITEM))       ,NIL},;	//-- Item
			  {"C7_PRODUTO",cCodPro                            ,NIL},;	//-- Produto
			  {"C7_QUANT"  ,1                                  ,NIL},;	//-- Quantidade
			  {"C7_UM"     ,SB1->B1_UM                         ,NIL},;	//-- Unidade de Medida Produto
			  {"C7_PRECO"  ,DMI->DMI_VALFAT                    ,NIL},;	//-- Valor do Frete (Unitario)
			  {"C7_TOTAL"  ,DMI->DMI_VALFAT                    ,NIL},;	//-- Valor do Frete (Total)
			  {"C7_DATPRF" ,dDataBase                          ,NIL},;	//-- DataBase
			  {"C7_LOCAL"  ,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),NIL},;	//-- Almoxarifado
			  {"C7_ORIGEM" ,"SIGATMS"                          ,Nil}}	//-- Origem

	MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,aCab,{aItem},3,.F.)

	If lMsErroAuto
		MostraErro()
	Else
		Aviso(STR0077,STR0076 + cNumero + STR0077 + STR0079,{"OK"},3)	//-- "Atenção" # "Pedido de Compras " # " Gerado " # "com Sucesso."
		RecLock("DMI",.F.)
		DMI->DMI_PEDCOM := cNumero
		DMI->(MsUnlock())
	EndIf

ElseIf nAcao == 2	//--  Cancelar
	SC7->(dbSetOrder(1))
	If SC7->(DbSeek(xFilial("SC7") + DMI->DMI_PEDCOM)) .And. SC7->C7_ENCER = " "
		aCab := {{"C7_NUM",DMI->DMI_PEDCOM,Nil}}	//-- Numero do Pedido

		MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,aCab,{},5,.F.)

		If lMsErroAuto
			MostraErro()
		Else
			Aviso(STR0077,STR0076 + DMI->DMI_PEDCOM + STR0078 + STR0079,{"OK"},3)	//-- "Atenção" # "Pedido de Compras " # " Excluído " # "com Sucesso."
			RecLock("DMI",.F.)
			DMI->DMI_PEDCOM := Space(Len(DMI->DMI_PEDCOM))
			DMI->(MsUnlock())
		EndIf
	Else
		Help("",1,"TMSAP1002")	//-- "Pedido já encerrado."
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMSAP10Ini
    Calcula o tempo de estadia em estacionamentos no inicializador padrão
    @type Function
    @author Valdemar Roberto Mognon
    @since 15/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Function TMSAP10Ini()
Local cRet   := ""

If !Empty(DMK->DMK_DATENT) .And. !Empty(DMK->DMK_HORENT) .And. !Empty(DMK->DMK_DATSAI) .And. !Empty(DMK->DMK_HORSAI)
	cRet := TmsTotHora(DMK->DMK_DATENT,DMK->DMK_HORENT,DMK->DMK_DATSAI,DMK->DMK_HORSAI)
EndIf

Return cRet

/*{Protheus.doc} TMSAP10Gat
    Calcula o tempo de estadia em estacionamentos no gatilho
    @type Function
    @author Valdemar Roberto Mognon
    @since 15/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Function TMSAP10Gat()
Local cRet   := ""

If !Empty(FwFldGet("DMK_DATENT")) .And. !Empty(FwFldGet("DMK_HORENT")) .And. !Empty(FwFldGet("DMK_DATSAI")) .And. !Empty(FwFldGet("DMK_HORSAI"))
	cRet := TmsTotHora(FwFldGet("DMK_DATENT"),FwFldGet("DMK_HORENT"),FwFldGet("DMK_DATSAI"),FwFldGet("DMK_HORSAI"))
EndIf

Return cRet

/*{Protheus.doc} TMSAP10Vld
    Valida campos
    @type Function
    @author Valdemar Roberto Mognon
    @since 15/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Function TMSAP10Vld(cCampo)
Local lRet := .T.

Default cCampo := ReadVar()

If "DMK_DATENT" $ cCampo .Or. "DMK_HORENT" $ cCampo .Or. "DMK_DATSAI" $ cCampo .Or. "DMK_HORSAI" $ cCampo
	If !Empty(FwFldGet("DMK_DATENT")) .And. !Empty(FwFldGet("DMK_HORENT")) .And. !Empty(FwFldGet("DMK_DATSAI")) .And. !Empty(FwFldGet("DMK_HORSAI"))
		If DTos(FwFldGet("DMK_DATENT")) + FwFldGet("DMK_HORENT") > DToS(FwFldGet("DMK_DATSAI")) + FwFldGet("DMK_HORSAI")
			Help("",1,"TMSAP1001")	//-- "Data e hora de entrada são superiores à data e hora de saída." # "Digite data e hora de entrada inferiores à data e hora de saída."
			lRet := .F.
		EndIf
	EndIF
EndIf

Return lRet

/*{Protheus.doc} TMSAP10Man
    Conciliação Manual
    @type Function
    @author Valdemar Roberto Mognon
    @since 15/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Function TMSAP10Man()
Local aCoors   := FWGetDialogSize(oMainWnd)
Local nOpca    := 0
Local nTabela  := 0
Local cAlias   := ""
Local cMarkBrw := GetMark()
Local cTabela  := ""
Local cQuery   := ""
Local cPlaca   := Space(Len(DA3->DA3_PLACA))
Local dData    := CToD("")
Local oMrkBrw, oLayer, oPanelUp1, oPanelUp2, oPanelDown, oButton1, oButton2, oDlgPrinc

If (nTabela := TMSAP10Opc(1)) > 0
	cAlias := aAliasSon[nTabela]
EndIf

cTabela := Iif(cAlias == "DMJ",STR0012,;
		   Iif(cAlias == "DMK",STR0013,;
		   Iif(cAlias == "DML",STR0014,;
		   Iif(cAlias == "DMM",STR0015,;
		   Iif(cAlias == "DMN",STR0016,STR0017)))))

lTipo1    := .F.
lTipo2    := .F.
lTipo3    := .F.
lTipo4    := .F.

If !Empty(cAlias)

	DEFINE MSDIALOG oDlgPrinc TITLE STR0044 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL

		//-- Cria o Layer
		oLayer := FWLayer():New()
		oLayer:Init(oDlgPrinc,.F.,.T.)

		//-- Adiciona Linha	
		oLayer:AddLine("UP"  ,020,.F.)
		oLayer:AddLine("DOWN",070,.F.)

		//-- Adiciona Coluna
		oLayer:AddCollumn("COLUMN1",090,.T.,"UP")
		oLayer:AddCollumn("COLUMN2",010,.T.,"UP")
		oLayer:AddCollumn("ALL"    ,100,.F.,"DOWN")

		//-- Adiciona Janela
		oLayer:AddWindow("COLUMN1","WINDOW1",STR0046,100,.F.,.T.,,"UP",{||})	//-- "Campos"
		oLayer:AddWindow("COLUMN2","WINDOW1",STR0047,100,.F.,.T.,,"UP",{||})	//-- "Ações"

		//-- Adiciona Painel
		oPanelUp1  := oLayer:GetWinPanel("COLUMN1","WINDOW1","UP")
		oPanelUp2  := oLayer:GetWinPanel("COLUMN2","WINDOW1","UP")
		oPanelDown := oLayer:GetColPanel("ALL","DOWN")

		//-- Adiciona Campos para Marcação Rápida
		TSay():New(011,001,{|| STR0048},oPanelUp1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Placa : "
		TSay():New(011,080,{|| STR0049},oPanelUp1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Data : "
	
		TGet():New(010,022,{|u| Iif(PCount() > 0,cPlaca    := u,cPlaca)}   ,oPanelUp1,040,007,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"cPlaca")
		TGet():New(010,098,{|u| Iif(PCount() > 0,dData     := u,dData)}    ,oPanelUp1,050,007,"@!",{||},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"dData")

		If cAlias $ "DMJ:DMK:DMT"
			TCheckBox():New(0025,022,STR0033,{|u| If(PCount()>0,lTipo1:=u,lTipo1)},oPanelUp1,090,008,,,,,,,,.T.,"Com Viagem",,)		//-- "Com Viagem"
			TCheckBox():New(0025,120,STR0034,{|u| If(PCount()>0,lTipo2:=u,lTipo2)},oPanelUp1,090,008,,,,,,,,.T.,"Sem Viagem",,)		//-- "Sem Viagem"
			TCheckBox():New(0025,218,STR0038,{|u| If(PCount()>0,lTipo3:=u,lTipo3)},oPanelUp1,090,008,,,,,,,,.T.,"Viagem Vazia",,)	//-- "Viagem Vazia"
			TCheckBox():New(0025,316,STR0039,{|u| If(PCount()>0,lTipo4:=u,lTipo4)},oPanelUp1,090,008,,,,,,,,.T.,"Particular",,)		//-- "Particular"
		Else
			TCheckBox():New(0025,022,STR0054,{|u| If(PCount()>0,lTipo1:=u,lTipo1)},oPanelUp1,090,008,,,,,,,,.T.,"Frota",,)			//-- "Frota"
			TCheckBox():New(0025,120,STR0039,{|u| If(PCount()>0,lTipo2:=u,lTipo2)},oPanelUp1,090,008,,,,,,,,.T.,"Particular",,)		//-- "Particular"
		EndIf

		//-- Botões de Marcação/Desmarcação
		oButton1 := TButton():New(003,002,STR0051,oPanelUp2,{|| TMSAP10Mrk(cAlias,DMI->DMI_NUMERO,cMarkBrw,oMrkBrw,cPlaca,dData)},040,013,,,,.T.,,"",,,,.F.)	//-- "&Marcar"
		oButton2 := TButton():New(018,002,STR0052,oPanelUp2,{|| TMSAP10Mrk(cAlias,DMI->DMI_NUMERO,"  "    ,oMrkBrw,cPlaca,dData)},040,013,,,,.T.,,"",,,,.F.)	//-- "&Desmarcar"

		//-- Adiciona o MarkBrowse das Tabelas		
		oMrkBrw:= FWMarkBrowse():New()
		oMrkBrw:SetOwner(oPanelDown)
		oMrkBrw:SetDescription(cTabela)
		oMrkBrw:SetAlias(cAlias)
		oMrkBrw:SetMenuDef("")
		oMrkBrw:DisableDetails()
		oMrkBrw:AddFilter("MANUAL",cAlias + "->" + cAlias + "_CONFER == '2'",.T.,.T.)
		oMrkBrw:AddMarkColumns({|| Iif(Empty(&(cAlias + "->" + cAlias + "_MARK")),"LBNO","LBOK")},{|| MarkReg(cAlias,cMarkBrw)},{|| MarkAll(cAlias,oMrkBrw,cMarkBrw)})
		oMrkBrw:Activate()

	ACTIVATE MSDIALOG oDlgPrinc ON INIT EnchoiceBar(oDlgPrinc,{|| nOpca := 1,oDlgPrinc:End()},{||oDlgPrinc:End()}) CENTERED

	If nOpca == 1	//-- Salvar
		FwMsgRun(,{|| TMSAP10Prc(cAlias,DMI->DMI_NUMERO,cMarkBrw,DMI->DMI_VALFAT)},STR0041,STR0044)	//-- "Processando" # "Conciliação Manual"
	EndIf

	cQuery := " UPDATE " + RetSqlName(cAlias)
	cQuery += "    SET " + cAlias + "_MARK   = ' ' "
	cQuery += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cQuery += "    AND " + cAlias + "_NUMCON = '" + DMI->DMI_NUMERO + "' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)

EndIf

Return

/*{Protheus.doc} MarkReg
Marca/Desmarca o registro posicionado
@type Static Function
@author Valdemar Roberto Mognon
@since 16/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function MarkReg(cAlias,cMarkBrw)

RecLock(cAlias,.F.)
&(cAlias + "->" + cAlias + "_MARK := Iif(" + cAlias + "->" + cAlias + "_MARK == cMarkBrw,'',cMarkBrw)")
&(cAlias + "->(MsUnlock())")

Return

/*{Protheus.doc} MarkAll
Marca/Desmarca todos os registros
@type Static Function
@author Valdemar Roberto Mognon
@since 16/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function MarkAll(cAlias,oMrkBrw,cMarkBrw)
Local aArea     := GetArea()
Local cQuery    := ""
Local cAliasQry := ""

cAliasQry := GetNextAlias()
cQuery := "SELECT COUNT(" + cAlias + "_PLACA) QTDREG "
cQuery += "  FROM " + RetSQLName(cAlias) + " " + cAlias + " "
cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cQuery += "   AND " + cAlias + "_NUMCON = '" + DMI->DMI_NUMERO + "' "
cQuery += "   AND " + cAlias + "_MARK <> ' ' "
cQuery += "   AND " + cAlias + ".D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

If (cAliasQry)->(!Eof()) .And. (cAliasQry)->QTDREG > 0
	cQuery := " UPDATE " + RetSqlName(cAlias)
	cQuery += "    SET " + cAlias + "_MARK   = ' ' "
	cQuery += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cQuery += "    AND " + cAlias + "_NUMCON = '" + DMI->DMI_NUMERO + "' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)
Else
	cQuery := " UPDATE " + RetSqlName(cAlias)
	cQuery += "    SET " + cAlias + "_MARK   = '" + cMarkBrw + "' "
	cQuery += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cQuery += "    AND " + cAlias + "_NUMCON = '" + DMI->DMI_NUMERO + "' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)
EndIf

(cAliasQry)->(DbCloseArea())

oMrkBrw:Gotop()
oMrkBrw:Refresh()

RestArea(aArea)

Return

/*{Protheus.doc} TMSAP10Prc
Processa as conciliações manuais
@type Static Function
@author Valdemar Roberto Mognon
@since 16/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function TMSAP10Prc(cAlias,cNumero,cMarkBrw,nValFat)
Local cQuery := ""
Local oTMSVIAFCL

Default cNumero  := DMI->DMI_NUMERO
Default cMarkBrw := ""
Default nValFat  := 0

cQuery := " UPDATE " + RetSqlName(cAlias)
cQuery += "    SET " + cAlias + "_CONFER = '1' "
cQuery += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cQuery += "    AND " + cAlias + "_NUMCON = '" + cNumero + "' "
cQuery += "    AND " + cAlias + "_MARK   = '" + cMarkBrw + "' "
cQuery += "    AND D_E_L_E_T_ = ' ' "
TCSqlExec(cQuery)

//-- Fecha Conciliação
oTMSVIAFCL := TMSBCAVIAFACIL():New()
FwMsgRun(,{|| oTMSVIAFCL:FechaConc(cNumero,nValFat)},STR0041,STR0053)	//-- "Processando" # "Fechando Conciliação"

Return

/*{Protheus.doc} TMSAP10Mrk
Marca por meio dos filtros manuais
@type Static Function
@author Valdemar Roberto Mognon
@since 17/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function TMSAP10Mrk(cAlias,cNumero,cMarkBrw,oMrkBrw,cPlaca,dData)
Local cQuery   := ""
Local cTipos   := ""
Local nMaximo  := Iif(cAlias $ "DMJ:DMK:DMT",4,2)
Local nCntFor1 := 0

Default cAlias   := ""
Default cNumero  := DMI->DMI_NUMERO
Default cMarkBrw := "  "

If !Empty(cAlias) .And. !Empty(cNumero)
	For nCntFor1 := 1 To nMaximo
		If &("lTipo" + StrZero(nCntFor1,1))
			cTipos += "'" + StrZero(nCntFor1,1) + "',"
		EndIf
	Next nCntFor1
	If !Empty(cTipos)
		cTipos := Left(cTipos,Len(cTipos) - 1)
	EndIf
	
	cQuery := " UPDATE " + RetSqlName(cAlias)
	cQuery += "    SET " + cAlias + "_MARK   = '" + cMarkBrw + "' "
	cQuery += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cQuery += "    AND " + cAlias + "_NUMCON = '" + cNumero + "' "
	If !Empty(cPlaca)
		cQuery += "    AND " + cAlias + "_PLACA  = '" + cPlaca + "' "
	EndIf
	If !Empty(dData) .And. cAlias $ "DMJ:DMK:DMM:DMT"
		cQuery += "    AND " + cAlias + "_DAT" + Iif(cAlias == "DMJ","PAS",;
												 Iif(cAlias == "DMK","ENT",;
												 Iif(cAlias == "DMM","CRE","ABA"))) + "  = '" + DTos(dData) + "' "
	EndIf
	If !Empty(cTipos)
		cQuery += "    AND " + cAlias + "_TIPO  IN (" + cTipos + ") "
	EndIf
	cQuery += "    AND " + cAlias + "_MARK   <> '" + cMarkBrw + "' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)

	oMrkBrw:Gotop()
	oMrkBrw:Refresh()
EndIf

Return

/*{Protheus.doc} TMSAP10Opc
Define a tabela para conciliar manualmente
@type Static Function
@author Valdemar Roberto Mognon
@since 20/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function TMSAP10Opc(nAcao)
Local aParambox := {}
Local aTabelas  := {}
Local aRet      := {}
Local nRet      := 0

If nAcao == 1	//-- Conciliação Manual
	aTabelas := {STR0012,STR0013,STR0014,STR0015,STR0016,STR0017}
	aAdd(aParamBox,{3,Iif(nAcao == 1,STR0044,STR0044),1,aTabelas,70,"",.T.})	//-- "Conciliação Manual"
	If ParamBox(aParamBox,Iif(nAcao == 1,STR0044,STR0044),@aRet)	//-- "Conciliação Manual"
		nRet := aRet[1]
	EndIf
Else	//-- Geração de Viagem Vazia
	aTabelas := {STR0012,STR0013,STR0017}
	aAdd(aParamBox,{3,Iif(nAcao == 1,STR0073,STR0073),1,aTabelas,70,"",.T.})	//-- "Gerar Viagem Vazia"
	If ParamBox(aParamBox,Iif(nAcao == 1,STR0073,STR0073),@aRet)	//-- "Gerar Viagem Vazia"
		nRet := aRet[1]
	EndIf
EndIf

Return nRet

Static Function MontaInd(oPanel,cNumero)
Local aRet := {}
Local oPanel2
Local oScroll

aRet := BuscaReg(cNumero)

//-- Cria objeto Scroll
oScroll := TScrollArea():New(oPanel,01,01,100,100)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT
 
//-- Cria painel
@ 000,000 MSPANEL oPanel2 OF oScroll SIZE 1000,1000 COLOR CLR_HRED

//-- Define objeto painel como filho do scroll
oScroll:SetFrame(oPanel2)
 
oPnlInd01 := TMSPainel():New(oPanel2,STR0018,aRet[01],{255,000,000},,005,005,070,035)	//-- "Pedag c/Viagem"
oPnlInd02 := TMSPainel():New(oPanel2,STR0019,aRet[02],{255,000,051},,080,005,070,035)	//-- "Pedag s/Viagem"
oPnlInd03 := TMSPainel():New(oPanel2,STR0020,aRet[03],{255,000,102},,155,005,070,035)	//-- "Pedag Viag Vaz"
oPnlInd04 := TMSPainel():New(oPanel2,STR0021,aRet[04],{255,000,153},,230,005,070,035)	//-- "Pedag Particul"
oPnlInd05 := TMSPainel():New(oPanel2,STR0022,aRet[05],{255,000,204},,305,005,070,035)	//-- "Pedag não Conf"
oPnlInd06 := TMSPainel():New(oPanel2,STR0081,aRet[06],{255,000,255},,380,005,070,035)	//-- "Pedag Duplic"

oPnlInd11 := TMSPainel():New(oPanel2,STR0023,aRet[07],{255,153,000},,005,045,070,035)	//-- "Estac c/Viagem"
oPnlInd12 := TMSPainel():New(oPanel2,STR0024,aRet[08],{255,153,051},,080,045,070,035)	//-- "Estac s/Viagem"
oPnlInd13 := TMSPainel():New(oPanel2,STR0025,aRet[09],{255,153,102},,155,045,070,035)	//-- "Estac Viag Vaz"
oPnlInd14 := TMSPainel():New(oPanel2,STR0057,aRet[10],{255,153,153},,230,045,070,035)	//-- "Estac Particul"
oPnlInd15 := TMSPainel():New(oPanel2,STR0058,aRet[11],{255,153,204},,305,045,070,035)	//-- "Estac não Conf"
oPnlInd16 := TMSPainel():New(oPanel2,STR0082,aRet[12],{255,153,204},,380,045,070,035)	//-- "Estac Duplic"

oPnlInd21 := TMSPainel():New(oPanel2,STR0059,aRet[13],{153,255,000},,005,085,070,035)	//-- "Mens Frota"
oPnlInd22 := TMSPainel():New(oPanel2,STR0060,aRet[14],{153,255,051},,080,085,070,035)	//-- "Mens Particul"
oPnlInd23 := TMSPainel():New(oPanel2,STR0061,aRet[15],{153,255,102},,155,085,070,035)	//-- "Mens não Conf"
oPnlInd24 := TMSPainel():New(oPanel2,STR0083,aRet[16],{153,255,102},,230,085,070,035)	//-- "Mens Duplic"

oPnlInd31 := TMSPainel():New(oPanel2,STR0062,aRet[17],{153,102,000},,005,125,070,035)	//-- "Cred Frota"
oPnlInd32 := TMSPainel():New(oPanel2,STR0063,aRet[18],{153,102,051},,080,125,070,035)	//-- "Cred Particul"
oPnlInd33 := TMSPainel():New(oPanel2,STR0064,aRet[19],{153,102,102},,155,125,070,035)	//-- "Cred não Conf"
oPnlInd34 := TMSPainel():New(oPanel2,STR0084,aRet[20],{153,102,102},,230,125,070,035)	//-- "Cred Duplic"

oPnlInd41 := TMSPainel():New(oPanel2,STR0065,aRet[21],{051,000,000},,005,165,070,035)	//-- "Adesão Frota"
oPnlInd42 := TMSPainel():New(oPanel2,STR0066,aRet[22],{051,000,051},,080,165,070,035)	//-- "Adesão Partic"
oPnlInd43 := TMSPainel():New(oPanel2,STR0067,aRet[23],{051,000,102},,155,165,070,035)	//-- "Ades não Conf"
oPnlInd44 := TMSPainel():New(oPanel2,STR0085,aRet[24],{051,000,102},,230,165,070,035)	//-- "Adesão Duplic"

oPnlInd51 := TMSPainel():New(oPanel2,STR0068,aRet[25],{000,102,000},,005,205,070,035)	//-- "Abast c/Viagem"
oPnlInd52 := TMSPainel():New(oPanel2,STR0069,aRet[26],{000,102,051},,080,205,070,035)	//-- "Abast s/Viagem"
oPnlInd53 := TMSPainel():New(oPanel2,STR0070,aRet[27],{000,102,102},,155,205,070,035)	//-- "Abast Viag Vaz"
oPnlInd54 := TMSPainel():New(oPanel2,STR0071,aRet[28],{000,102,153},,230,205,070,035)	//-- "Abast Particul"
oPnlInd55 := TMSPainel():New(oPanel2,STR0072,aRet[29],{000,102,204},,305,205,070,035)	//-- "Abast não Conf"
oPnlInd56 := TMSPainel():New(oPanel2,STR0086,aRet[30],{000,102,204},,380,205,070,035)	//-- "Abast Duplic"

Return

/*{Protheus.doc} BuscaReg
Busca valores das conciliações
@type Static Function
@author Valdemar Roberto Mognon
@since 21/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function BuscaReg(cNumero)
Local aRet      := Array(30)
Local cQuery    := ""
Local cAliasQry := ""

//-- Passagem em praças de pedágio
cAliasQry := GetNextAlias()
cQuery := "SELECT SUM (CASE WHEN DMJ_TIPO   = '1' THEN DMJ_VALPAS "
cQuery += "                 ELSE 0 END) AS TOTCOMVIA,"
cQuery += "       SUM (CASE WHEN DMJ_TIPO   = '2' THEN DMJ_VALPAS "
cQuery += "                 ELSE 0 END) AS TOTSEMVIA,"
cQuery += "       SUM (CASE WHEN DMJ_TIPO   = '3' THEN DMJ_VALPAS "
cQuery += "                 ELSE 0 END) AS TOTVIAVAZ,"
cQuery += "       SUM (CASE WHEN DMJ_TIPO   = '4' THEN DMJ_VALPAS "
cQuery += "                 ELSE 0 END) AS TOTPARTIC,"
cQuery += "       SUM (CASE WHEN DMJ_CONFER = '2' THEN DMJ_VALPAS "
cQuery += "                 ELSE 0 END) AS TOTNAOCON,"
cQuery += "       SUM (CASE WHEN DMJ_CONFER = '3' THEN DMJ_VALPAS "
cQuery += "                 ELSE 0 END) AS TOTDUPLIC "
cQuery += "  FROM  " + RetSQLName("DMJ") + " DMJ "
cQuery += "	 WHERE DMJ_FILIAL = '" + xFilial("DMJ") + "' "
cQuery += "    AND DMJ_NUMCON = '" + cNumero + "' "
cQuery += "    AND DMJ.D_E_L_E_T_ =  '' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
If (cAliasQry)->(!Eof())
	aRet[01] := AllTrim(TransForm((cAliasQry)->TOTCOMVIA,PesqPict("DMJ","DMJ_VALPAS")))
	aRet[02] := AllTrim(TransForm((cAliasQry)->TOTSEMVIA,PesqPict("DMJ","DMJ_VALPAS")))
	aRet[03] := AllTrim(TransForm((cAliasQry)->TOTVIAVAZ,PesqPict("DMJ","DMJ_VALPAS")))
	aRet[04] := AllTrim(TransForm((cAliasQry)->TOTPARTIC,PesqPict("DMJ","DMJ_VALPAS")))
	aRet[05] := AllTrim(TransForm((cAliasQry)->TOTNAOCON,PesqPict("DMJ","DMJ_VALPAS")))
	aRet[06] := AllTrim(TransForm((cAliasQry)->TOTDUPLIC,PesqPict("DMJ","DMJ_VALPAS")))
EndIf
(cAliasQry)->(DbCloseArea())

//-- Estacionamento
cAliasQry := GetNextAlias()
cQuery := "SELECT SUM (CASE WHEN DMK_TIPO   = '1' THEN DMK_VALOR "
cQuery += "                 ELSE 0 END) AS TOTCOMVIA,"
cQuery += "       SUM (CASE WHEN DMK_TIPO   = '2' THEN DMK_VALOR "
cQuery += "                 ELSE 0 END) AS TOTSEMVIA,"
cQuery += "       SUM (CASE WHEN DMK_TIPO   = '3' THEN DMK_VALOR "
cQuery += "                 ELSE 0 END) AS TOTVIAVAZ,"
cQuery += "       SUM (CASE WHEN DMK_TIPO   = '4' THEN DMK_VALOR "
cQuery += "                 ELSE 0 END) AS TOTPARTIC,"
cQuery += "       SUM (CASE WHEN DMK_CONFER = '2' THEN DMK_VALOR "
cQuery += "                 ELSE 0 END) AS TOTNAOCON,"
cQuery += "       SUM (CASE WHEN DMK_CONFER = '3' THEN DMK_VALOR "
cQuery += "                 ELSE 0 END) AS TOTDUPLIC "
cQuery += "  FROM  " + RetSQLName("DMK") + " DMK "
cQuery += "	 WHERE DMK_FILIAL = '" + xFilial("DMK") + "' "
cQuery += "    AND DMK_NUMCON = '" + cNumero + "' "
cQuery += "    AND DMK.D_E_L_E_T_ =  '' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
If (cAliasQry)->(!Eof())
	aRet[07] := AllTrim(TransForm((cAliasQry)->TOTCOMVIA,PesqPict("DMK","DMK_VALOR")))
	aRet[08] := AllTrim(TransForm((cAliasQry)->TOTSEMVIA,PesqPict("DMK","DMK_VALOR")))
	aRet[09] := AllTrim(TransForm((cAliasQry)->TOTVIAVAZ,PesqPict("DMK","DMK_VALOR")))
	aRet[10] := AllTrim(TransForm((cAliasQry)->TOTPARTIC,PesqPict("DMK","DMK_VALOR")))
	aRet[11] := AllTrim(TransForm((cAliasQry)->TOTNAOCON,PesqPict("DMK","DMK_VALOR")))
	aRet[12] := AllTrim(TransForm((cAliasQry)->TOTDUPLIC,PesqPict("DMK","DMK_VALOR")))
EndIf
(cAliasQry)->(DbCloseArea())

//-- Mensalidade
cAliasQry := GetNextAlias()
cQuery := "SELECT SUM (CASE WHEN DML_TIPO   = '1' THEN DML_VALOR "
cQuery += "                 ELSE 0 END) AS TOTFROTA,"
cQuery += "       SUM (CASE WHEN DML_TIPO   = '2' THEN DML_VALOR "
cQuery += "                 ELSE 0 END) AS TOTPARTIC,"
cQuery += "       SUM (CASE WHEN DML_CONFER = '2' THEN DML_VALOR "
cQuery += "                 ELSE 0 END) AS TOTNAOCON,"
cQuery += "       SUM (CASE WHEN DML_CONFER = '3' THEN DML_VALOR "
cQuery += "                 ELSE 0 END) AS TOTDUPLIC "
cQuery += "  FROM  " + RetSQLName("DML") + " DML "
cQuery += "	 WHERE DML_FILIAL = '" + xFilial("DML") + "' "
cQuery += "    AND DML_NUMCON = '" + cNumero + "' "
cQuery += "    AND DML.D_E_L_E_T_ =  '' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
If (cAliasQry)->(!Eof())
	aRet[13] := AllTrim(TransForm((cAliasQry)->TOTFROTA ,PesqPict("DML","DML_VALOR")))
	aRet[14] := AllTrim(TransForm((cAliasQry)->TOTPARTIC,PesqPict("DML","DML_VALOR")))
	aRet[15] := AllTrim(TransForm((cAliasQry)->TOTNAOCON,PesqPict("DML","DML_VALOR")))
	aRet[16] := AllTrim(TransForm((cAliasQry)->TOTDUPLIC,PesqPict("DML","DML_VALOR")))
EndIf
(cAliasQry)->(DbCloseArea())

//-- Crédito
cAliasQry := GetNextAlias()
cQuery := "SELECT SUM (CASE WHEN DMM_TIPO   = '1' THEN DMM_VALCRE "
cQuery += "                 ELSE 0 END) AS TOTFROTA,"
cQuery += "       SUM (CASE WHEN DMM_TIPO   = '2' THEN DMM_VALCRE "
cQuery += "                 ELSE 0 END) AS TOTPARTIC,"
cQuery += "       SUM (CASE WHEN DMM_CONFER = '2' THEN DMM_VALCRE "
cQuery += "                 ELSE 0 END) AS TOTNAOCON,"
cQuery += "       SUM (CASE WHEN DMM_CONFER = '3' THEN DMM_VALCRE "
cQuery += "                 ELSE 0 END) AS TOTDUPLIC "
cQuery += "  FROM  " + RetSQLName("DMM") + " DMM "
cQuery += "	 WHERE DMM_FILIAL = '" + xFilial("DMM") + "' "
cQuery += "    AND DMM_NUMCON = '" + cNumero + "' "
cQuery += "    AND DMM.D_E_L_E_T_ =  '' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
If (cAliasQry)->(!Eof())
	aRet[17] := AllTrim(TransForm((cAliasQry)->TOTFROTA ,PesqPict("DMM","DMM_VALCRE")))
	aRet[18] := AllTrim(TransForm((cAliasQry)->TOTPARTIC,PesqPict("DMM","DMM_VALCRE")))
	aRet[19] := AllTrim(TransForm((cAliasQry)->TOTNAOCON,PesqPict("DMM","DMM_VALCRE")))
	aRet[20] := AllTrim(TransForm((cAliasQry)->TOTDUPLIC,PesqPict("DMM","DMM_VALCRE")))
EndIf
(cAliasQry)->(DbCloseArea())

//-- Adesão
cAliasQry := GetNextAlias()
cQuery := "SELECT SUM (CASE WHEN DMN_TIPO   = '1' THEN DMN_VALOR "
cQuery += "                 ELSE 0 END) AS TOTFROTA,"
cQuery += "       SUM (CASE WHEN DMN_TIPO   = '2' THEN DMN_VALOR "
cQuery += "                 ELSE 0 END) AS TOTPARTIC,"
cQuery += "       SUM (CASE WHEN DMN_CONFER = '2' THEN DMN_VALOR "
cQuery += "                 ELSE 0 END) AS TOTNAOCON,"
cQuery += "       SUM (CASE WHEN DMN_CONFER = '3' THEN DMN_VALOR "
cQuery += "                 ELSE 0 END) AS TOTDUPLIC "
cQuery += "  FROM  " + RetSQLName("DMN") + " DMN "
cQuery += "	 WHERE DMN_FILIAL = '" + xFilial("DMN") + "' "
cQuery += "    AND DMN_NUMCON = '" + cNumero + "' "
cQuery += "    AND DMN.D_E_L_E_T_ =  '' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
If (cAliasQry)->(!Eof())
	aRet[21] := AllTrim(TransForm((cAliasQry)->TOTFROTA ,PesqPict("DMN","DMN_VALOR")))
	aRet[22] := AllTrim(TransForm((cAliasQry)->TOTPARTIC,PesqPict("DMN","DMN_VALOR")))
	aRet[23] := AllTrim(TransForm((cAliasQry)->TOTNAOCON,PesqPict("DMN","DMN_VALOR")))
	aRet[24] := AllTrim(TransForm((cAliasQry)->TOTDUPLIC,PesqPict("DMN","DMN_VALOR")))
EndIf
(cAliasQry)->(DbCloseArea())

//-- Abastecimento
cAliasQry := GetNextAlias()
cQuery := "SELECT SUM (CASE WHEN DMT_TIPO   = '1' THEN DMT_VALOR "
cQuery += "                 ELSE 0 END) AS TOTCOMVIA,"
cQuery += "       SUM (CASE WHEN DMT_TIPO   = '2' THEN DMT_VALOR "
cQuery += "                 ELSE 0 END) AS TOTSEMVIA,"
cQuery += "       SUM (CASE WHEN DMT_TIPO   = '3' THEN DMT_VALOR "
cQuery += "                 ELSE 0 END) AS TOTVIAVAZ,"
cQuery += "       SUM (CASE WHEN DMT_TIPO   = '4' THEN DMT_VALOR "
cQuery += "                 ELSE 0 END) AS TOTPARTIC,"
cQuery += "       SUM (CASE WHEN DMT_CONFER = '2' THEN DMT_VALOR "
cQuery += "                 ELSE 0 END) AS TOTNAOCON,"
cQuery += "       SUM (CASE WHEN DMT_CONFER = '3' THEN DMT_VALOR "
cQuery += "                 ELSE 0 END) AS TOTDUPLIC "
cQuery += "  FROM  " + RetSQLName("DMT") + " DMT "
cQuery += "	 WHERE DMT_FILIAL = '" + xFilial("DMT") + "' "
cQuery += "    AND DMT_NUMCON = '" + cNumero + "' "
cQuery += "    AND DMT.D_E_L_E_T_ =  '' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
If (cAliasQry)->(!Eof())
	aRet[25] := AllTrim(TransForm((cAliasQry)->TOTCOMVIA,PesqPict("DMT","DMT_VALOR")))
	aRet[26] := AllTrim(TransForm((cAliasQry)->TOTSEMVIA,PesqPict("DMT","DMT_VALOR")))
	aRet[27] := AllTrim(TransForm((cAliasQry)->TOTVIAVAZ,PesqPict("DMT","DMT_VALOR")))
	aRet[28] := AllTrim(TransForm((cAliasQry)->TOTPARTIC,PesqPict("DMT","DMT_VALOR")))
	aRet[29] := AllTrim(TransForm((cAliasQry)->TOTNAOCON,PesqPict("DMT","DMT_VALOR")))
	aRet[30] := AllTrim(TransForm((cAliasQry)->TOTDUPLIC,PesqPict("DMT","DMT_VALOR")))
EndIf
(cAliasQry)->(DbCloseArea())

Return aRet

/*{Protheus.doc} TMSAP10Ger
Prepara a geração das viagens vazias
@type Static Function
@author Valdemar Roberto Mognon
@since 21/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function TMSAP10Ger(cAlias,cNumero,cMarkBrw,nValFat)
Local aAreas    := {DTW->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasQry := ""
Local cDataBas  := ""
Local cPlacaBas := ""
Local cFilOri   := ""
Local cViagem   := ""
Local cNomMot   := ""
Local lCriou    := .T.
Local lCont     := .T.
Local oTMSVIAFCL

Default cNumero  := DMI->DMI_NUMERO
Default cMarkBrw := ""
Default nValFat  := 0

cAliasQry := GetNextAlias()
cQuery := "SELECT " + cAlias + "_PLACA PLACA,"
If cAlias == "DMJ"
	cQuery +=             cAlias + "_DATPAS DATPAS," + cAlias + "_HORPAS HORPAS,"
ElseIf cAlias == "DMK"
	cQuery +=             cAlias + "_DATENT DATENT," + cAlias + "_HORENT HORENT,"
	cQuery +=             cAlias + "_DATSAI DATSAI," + cAlias + "_HORSAI HORSAI,"
ElseIf cAlias == "DMT"
	cQuery +=             cAlias + "_DATABA DATABA," + cAlias + "_HORABA HORABA,"
EndIf
cQuery +=             cAlias + ".R_E_C_N_O_ REGISTRO "
cQuery += "  FROM " + RetSQLName(cAlias) + " " + cAlias + " "
cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cQuery += "   AND " + cAlias + "_NUMCON = '" + cNumero + "' "
cQuery += "   AND " + cAlias + "_MARK   = '" + cMarkBrw + "' "
cQuery += "   AND " + cAlias + "_CONFER = '2' "
cQuery += "   AND " + cAlias + "_TIPO   = '2' "
cQuery += "   AND " + cAlias + ".D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY PLACA,"
If cAlias == "DMJ"
	cQuery += "DATPAS,HORPAS"
ElseIf cAlias == "DMK"
	cQuery += "DATENT,HORENT"
ElseIf cAlias == "DMT"
	cQuery += "DATABA,HORABA"
EndIf
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->(!Eof())
	cPlacaBas := (cAliasQry)->PLACA
	If cAlias == "DMJ"
		cDataBas := (cAliasQry)->DATPAS
	ElseIf cAlias == "DMK"
		cDataBas := (cAliasQry)->DATENT
	ElseIf cAlias == "DMT"
		cDataBas := (cAliasQry)->DATABA
	EndIf
	
	//-- Chama a geração da viagem
	lCriou := GeraViag(cPlacaBas,@cFilOri,@cViagem,@cNomMot)

	//-- Chama o fechamento da viagem
	If lCriou
		lCont := FechaViag(cFilOri,cViagem)
	EndIf

	//-- Chama o apontamento de operações
	If lCont
		lCont := OperaViag(cFilOri,cViagem)
	EndIf
	
	//-- Chama o encerramento da viagem
	If lCont
		lCont := EncerViag(cFilOri,cViagem)
	EndIf
		
	//-- Atualiza os registros com a viagem gerada
	While (cAliasQry)->(!Eof()) .And. (cAliasQry)->PLACA == cPlacaBas .And. Iif(cAlias == "DMJ",(cAliasQry)->DATPAS,;
																			Iif(cAlias == "DMK",(cAliasQry)->DATENT,(cAliasQry)->DATABA)) == cDataBas
		If lCriou
			&(cAlias + "->(DbGoTo((cAliasQry)->REGISTRO))")
			RecLock(cAlias,.F.)
			&(cAlias + "->" + cAlias + "_FILORI := '" + cFilOri + "'")
			&(cAlias + "->" + cAlias + "_VIAGEM := '" + cViagem + "'")
			&(cAlias + "->" + cAlias + "_NOMMOT := '" + cNomMot + "'")
			&(cAlias + "->" + cAlias + "_TIPO   := '3'")	//-- Viagem Vazia
			&(cAlias + "->" + cAlias + "_CONFER := '1'")	//-- Sim
			&(cAlias + "->(MsUnlock())")
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
EndDo

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

//-- Fecha Conciliação
oTMSVIAFCL := TMSBCAVIAFACIL():New()
FwMsgRun(,{|| oTMSVIAFCL:FechaConc(cNumero,nValFat)},STR0041,STR0053)	//-- "Processando" # "Fechando Conciliação"

Return

/*{Protheus.doc} GeraViag
Geração das viagens vazias
@type Static Function
@author Valdemar Roberto Mognon
@since 21/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function GeraViag(cPlaca,cFilOri,cViagem,cNomMot)
Local aAreas     := {DA4->(GetArea()),DTR->(GetArea()),DA3->(GetArea()),DUT->(GetArea()),GetArea()}
Local aDadosDTR  := {}
Local aDadosDUP  := {}
Local aCab 		 := {} 
Local aMaster	 := {} 
Local aGrid   	 := {} 
Local cRotGEnt   := Padr(GetMv("MV_ROTGENT",,""),Len(DTQ->DTQ_ROTA))
Local lCont      := .T.

Aadd(aCab,{"DTQ_TIPVIA",StrZero(2,Len(DTQ->DTQ_TIPVIA)),Nil})	//-- Vazia
Aadd(aCab,{"DTQ_SERTMS",StrZero(3,Len(DTQ->DTQ_SERTMS)),Nil})	//-- Entrega
Aadd(aCab,{"DTQ_TIPTRA",StrZero(1,Len(DTQ->DTQ_TIPTRA)),Nil})	//-- Rodoviária
Aadd(aCab,{"DTQ_ROTA"  ,cRotGEnt,Nil})

DA3->(DbSetOrder(3))
If DA3->(DbSeek(xFilial("DA3") + cPlaca))
	Aadd(aDadosDTR,{})
	Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_ITEM"  ,StrZero(1,Len(DTR->DTR_ITEM)),Nil})
	Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_CODVEI",DA3->DA3_COD,Nil})
	DUT->(DbSetOrder(1))
	If DUT->(DbSeek(xFilial("DUT") + DA3->DA3_TIPVEI)) .And. DUT->DUT_CATVEI == StrZero(2,Len(DUT->DUT_CATVEI))	//-- Cavalo
		DTR->(DbSetOrder(4))
		If DTR->(DbSeek(xFilial("DTR") + DA3->DA3_COD))
			Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_CODRB1",DTR->DTR_CODRB1,Nil})
		Else
			lCont := .F.
		EndIf
	EndIf
Else
	lCont := .F.
EndIf

If lCont
	If !Empty(DA3->DA3_MOTORI)
		Aadd(aDadosDUP,{})
		Aadd(aDadosDUP[Len(aDadosDUP)],{"DUP_CODMOT",DA3->DA3_MOTORI,Nil})
		cNomMot := Posicione("DA4",1,xFilial("DA4") + DA3->DA3_MOTORI,"DA4_NOME")
	Else
		lCont := .F.
	EndIf
	
	If lCont
		Aadd(aMaster,{})
		Aadd(aMaster[Len(aMaster)],aClone(aCab))
		Aadd(aMaster[Len(aMaster)],"MdFieldDTQ")
		Aadd(aMaster[Len(aMaster)],"DTQ")
		
		If Len(aDadosDTR) > 0 
			Aadd(aGrid,{})
			Aadd(aGrid[Len(aGrid)],aClone(aDadosDTR))
			Aadd(aGrid[Len(aGrid)],"MdGridDTR")
			Aadd(aGrid[Len(aGrid)],"DTR")
			Aadd(aGrid[Len(aGrid)],.F.)	//-- Indica que a linha do GRID não será pesquisada para alteração
		EndIf
		
		If Len(aDadosDUP) > 0 
			Aadd(aGrid,{})
			Aadd(aGrid[Len(aGrid)],aClone(aDadosDUP))
			Aadd(aGrid[Len(aGrid)],"MdGridDUP")
			Aadd(aGrid[Len(aGrid)],"DUP")
			Aadd(aGrid[Len(aGrid)],.F.)	//-- Indica que a linha do GRID não será pesquisada para alteração
		EndIf
		
		If Len(aMaster) > 0 
			lCont := TMSExecAuto("TMSAF60",aMaster,aGrid,3,.T.)
			If lCont
				cFilOri := DTQ->DTQ_FILORI
				cViagem := DTQ->DTQ_VIAGEM
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lCont

/*{Protheus.doc} FechaViag
Fechamento das viagens vazias
@type Static Function
@author Valdemar Roberto Mognon
@since 22/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function FechaViag(cFilOri,cViagem)
Local lCont := .T.

If (Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem,"DTQ_STATUS") == StrZero(1,Len(DTQ->DTQ_STATUS)))	//-- Em Aberto
	lCont := TMSA310Mnt("DTQ",DTQ->(Recno()),3,,.F.)
Else
	lCont := (Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem,"DTQ_STATUS") == StrZero(5,Len(DTQ->DTQ_STATUS)))	//-- Fechada
EndIf

Return lCont

/*{Protheus.doc} OperaViag
Apontamento das operações das viagens vazias
@type Static Function
@author Valdemar Roberto Mognon
@since 22/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function OperaViag(cFilOri,cViagem)
Local lCont   := .T.
Local lTemDTW := .T.

Private aRotina   := {}
Private cCadastro := ""

SetFunName("TMSA350")
aRotina := {{"","",0,1},;
			{"","",0,2},;
			{"","",0,3},;
			{"","",0,4},;
			{"","",0,5}}
DTW->(DbSetOrder(4))
//-- Executa o apontamento da operação de saída da viagem
If (lTemDTW := (DTW->(DbSeek(xFilial("DTW") + cFilOri + cViagem + AllTrim(SuperGetMV("MV_ATIVSAI")))) .And. ;
				TMSA350Grv(3,DTW->DTW_FILORI,DTW->DTW_VIAGEM,DTW->DTW_ATIVID,dDataBase,SubStr(Time(),1,2) + SubStr(Time(),4,2),dDataBase,SubStr(Time(),1,2) + SubStr(Time(),4,2))))
	//-- Executa o apontamento da operação de chegada da viagem
	If (lTemDTW := (DTW->(DbSeek(xFilial("DTW") + cFilOri + cViagem + AllTrim(SuperGetMV("MV_ATIVCHG")))) .And. ;
					TMSA350Grv(3,DTW->DTW_FILORI,DTW->DTW_VIAGEM,DTW->DTW_ATIVID,dDataBase,SubStr(Time(),1,2) + SubStr(Time(),4,2),dDataBase,SubStr(Time(),1,2) + SubStr(Time(),4,2))))
	EndIf
EndIf
SetFunName("TMSAP10")
lCont := (Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem,"DTQ_STATUS") == StrZero(4,Len(DTQ->DTQ_STATUS)))	//-- Chegada em Filial

Return lCont

/*{Protheus.doc} EncerViag
Encerramento das viagens vazias
@type Static Function
@author Valdemar Roberto Mognon
@since 22/09/2021
@version P12 R12.1.29
@param 
@return
*/
Static Function EncerViag(cFilOri,cViagem)
Local lCont := .T.

Private aRotina   := {}
Private cCadastro := ""

SetFunName("TMSA340")
aRotina := {{"","",0,1},;
			{"","",0,2},;
			{"","",0,3},;
			{"","",0,4},;
			{"","",0,5}}
TMSA340Grv(.T.)
lCont := (Posicione("DTQ",2,xFilial("DTQ") + cFilOri + cViagem,"DTQ_STATUS") == StrZero(3,Len(DTQ->DTQ_STATUS)))	//-- Encerrada

Return lCont

/*{Protheus.doc} ValorTotal
    Soma o total da conciliação
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Static Function ValorTotal()
Local nCntFor1  := 0
Local nRet      := 0
Local cQuery    := ""
Local cAliasQry := ""
Local cTabelas  := "DMJDMKDMLDMMDMNDMT"
Local cAlias    := ""
Local cCampo    := ""

For nCntFor1 := 1 To 6
	cAlias := SubStr(cTabelas,nCntFor1 * 3 - 2,3)
	cCampo := "_VALOR"
	If cAlias == "DMJ"
		cCampo := "_VALPAS"
	ElseIf cAlias == "DMM"
		cCampo := "_VALCRE"
	EndIf
	cAliasQry := GetNextAlias()
	cQuery := "SELECT SUM(" + cAlias + cCampo + ") VALOR "
	cQuery += "  FROM " + RetSQLName(cAlias) + " " + cAlias + " "
	cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cQuery += "   AND " + cAlias + "_NUMCON = '" + DMI->DMI_NUMERO + "' "
	cQuery += "   AND " + cAlias + ".D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->VALOR > 0
		If cAlias == "DMM"
			nRet -= (cAliasQry)->VALOR
		Else
			nRet += (cAliasQry)->VALOR
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())
Next nCntFor1

Return nRet

/*{Protheus.doc} StatusConf
    Exibe o status da conciliação
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 28/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Static Function StatusConf()
Local cRet := Iif(DMI->DMI_CONFER == "1","BR_VERDE","BR_VERMELHO")

Return cRet

/*{Protheus.doc} LegendConf
    Exibe a legenda da conciliação
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 28/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Static Function LegendConf()
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE"   ,STR0031})		//-- "Conferido"
Aadd(aLegenda,{"BR_VERMELHO",STR0032})	//-- "Não Conferido"

BrwLegenda(STR0075,STR0075,aLegenda)

Return

/*{Protheus.doc} TMSAP10Pre
    Valida entrada da rotina
    @type Function
    @author Valdemar Roberto Mognon
    @since 04/10/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example 
    (examples)
    @see (links_or_references)
*/
Function TMSAP10Pre(oModel)
Local lRet       := .T.
Local nOperation := 0

Default oModel := FWModelActive()

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE
	If !Empty(DMI->DMI_PEDCOM)
		Help("",1,"TMSAP1003")	//-- "Conciliação com pedido do compras gerado." # "Exclua o pedido de compras."
		lRet := .F.
	EndIf
EndIf

Return lRet
