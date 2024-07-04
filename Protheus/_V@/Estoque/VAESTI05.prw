#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Crit�rios de avalia��o" 

User Function VAESTI05()
    Local aArea   		:= GetArea()
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  

    SetFunName("VAESTI05")

    oModel := FWMBrowse():New()
	oModel:SetAlias( "ZCP" )   
	oModel:SetDescription( cTitulo )
	oModel:Activate()
	
    SetFunName(cFunBkp)
	RestArea(aArea)
Return NIL  


Static Function MenuDef()
	Local aRot := {}
	//Adicionando op��es
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VAESTI05' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.VAESTI05' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.VAESTI05' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VAESTI05' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	//ADD OPTION aRot TITLE 'Copiar'    		ACTION 'VIEWDEF.VAFATI01' 			OPERATION 9						 ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
	Local oStZCP   := FWFormStruct(1, 'ZCP')
	//Local bVldPos  := {|| zVldZCPTab()}
	//Criando o FormModel, adicionando o Cabe�alho e Grid
	oModel := MPFormModel():New("ESTI05M")//,/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/,/* bVldCom Commit*/,/*Cancel*/)

	oModel:AddFields("ZCPMASTER",/*cOwner*/ ,oStZCP, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )

	oModel:SetPrimaryKey({ })

	//Setando outras informa��es do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZCPMASTER"):SetDescription("Formul�rio do Cadastro"+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel("VAESTI05")
    Local oStZCP     := FWFormStruct(2, "ZCP")
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_ZCP" , oStZCP  , "ZCPMASTER")
	//Habilitando t�tulo
	oView:EnableTitleView('VIEW_ZCP', cTitulo)

    oView:CreateHorizontalBox("SCREEN",100)
	//Tratativa padr�o para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )
	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_ZCP","SCREEN")

Return oView
