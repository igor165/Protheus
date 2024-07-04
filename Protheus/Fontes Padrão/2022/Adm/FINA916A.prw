#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA916A.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA916A
Visualização Conciliação Vendas

@author Guilherme.Santos
@since 16/02/2018
@version 12.1.19
/*/
//-------------------------------------------------------------------
Function FINA916A()
	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("FIF")

	oBrowse:SetDescription(STR0001)		//"Conciliação Vendas"
	/*
	-------------------------------------------------------------------
	Legendas
	-------------------------------------------------------------------
	*/
	oBrowse:AddLegend("FIF_STVEND == '1'", "GREEN"	, STR0002)					//"Não Processado"
	oBrowse:AddLegend("FIF_STVEND == '2'", "RED"	, STR0003)					//"Conciliado Normal"
	oBrowse:AddLegend("FIF_STVEND == '3'", "GRAY"	, STR0004)					//"Venda Conciliada Parcialmente"
	oBrowse:AddLegend("FIF_STVEND == '4'", "YELLOW"	, STR0005)					//"Divergente"
	oBrowse:AddLegend("FIF_STVEND == '5'", "BLUE"	, STR0006)					//"Venda Conciliada com Critica"
	oBrowse:AddLegend("FIF_STVEND == '6'", "BROWN"	, STR0007)					//"Titulo sem Registro de Venda"
	oBrowse:AddLegend("FIF_STVEND == '7'", "BLACK"	, STR0008)					//"Registro de Venda sem Titulo"

	oBrowse:Activate()

	Return NIL

	//-------------------------------------------------------------------
	/*/{Protheus.doc} Menudef
	Definicoes do Menu

	@author Guilherme Santos
	@since 09/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function MenuDef() As Array

	Local aRotina As Array
	aRotina	:= {}

	ADD OPTION aRotina TITLE STR0009		ACTION "VIEWDEF.FINA916A"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0		//"Visualizar"
	ADD OPTION aRotina TITLE STR0010		ACTION "VIEWDEF.FINA916A"	OPERATION MODEL_OPERATION_INSERT	ACCESS 0		//"Incluir"
	ADD OPTION aRotina TITLE STR0011		ACTION "VIEWDEF.FINA916A"	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0		//"Alterar"
	ADD OPTION aRotina TITLE STR0012		ACTION "VIEWDEF.FINA916A"	OPERATION MODEL_OPERATION_DELETE	ACCESS 0		//"Excluir"

	Return aRotina

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ModelDef
	Definicao do Modelo de Dados

	@author Guilherme.Santos
	@since 16/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function ModelDef() As Object

	Local oModel 	As Object
	Local oStrHea	As Object

	oModel 	:= MPFormModel():New("FINA916A")
	oStrHea := FWFormStruct(1, "FIF")

	oStrHea:SetProperty("*",	MODEL_FIELD_OBRIGAT, 	.F.)

	oModel:AddFields("HEADER", NIL, oStrHea)

	oModel:SetPrimaryKey({""})

	oModel:GetModel("HEADER"):SetDescription(STR0001)		//"Conciliação Vendas"

	oModel:SetDescription(STR0001)		//"Conciliação Vendas"

	Return oModel

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ViewDef
	Definicao da View

	@author Guilherme.Santos
	@since 16/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function ViewDef() As Object

	Local oModel 	As Object
	Local oView  	As Object
	Local oStrHea	As Object

	oModel		:= FWLoadModel("FINA916A")
	oView		:= FWFormView():New()
	oStrHea 	:= FWFormStruct(2, "FIF")

	oView:SetModel(oModel)
	oView:AddField("VIEW_HEADER", oStrHea, "HEADER")
	oView:CreateHorizontalBox("SUPERIOR", 100)
	oView:SetOwnerView("VIEW_HEADER", "SUPERIOR")

	Return oView
