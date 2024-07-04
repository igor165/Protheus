#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//Vari�veis Est�ticas
Static cTitulo := "Analises NPK"

User Function VAFATI03()
	Local aArea   := GetArea()
	Local oBrowse 
	Local cFunBkp := FunName()

	SetFunName("VAFATI03")

	//Cria um browse para a ZNP, filtrando somente a tabela 00 (cabe�alho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZNP")
	oBrowse:SetDescription(cTitulo)
	// oBrowse:SetFilterDefault("ZNP->ZNP_CODIGO == '00'")
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil

Static Function ModelDef()
	Local oStZNP   := FWFormStruct(1, 'ZNP')

	//Criando o FormModel, adicionando o Cabe�alho e Grid
	oModel := MPFormModel():New("FATI03M")

	oModel:AddFields("ZNPMASTER",/*cOwner*/ ,oStZNP, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )

	oModel:SetPrimaryKey({ })

	//Setando outras informa��es do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZNPMASTER"):SetDescription("Formul�rio do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel("VAFATI03")
    Local oStZNP     := FWFormStruct(2, "ZNP")
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_ZNP" , oStZNP  , "ZNPMASTER")
	//Habilitando t�tulo
	oView:EnableTitleView('VIEW_ZNP','Analises NPK')

    oView:CreateHorizontalBox("SCREEN",100)
	//Tratativa padr�o para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )
	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_ZNP","SCREEN")

Return oView

Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VAFATI03' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VAFATI03' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VAFATI03' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VAFATI03' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

