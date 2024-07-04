#INCLUDE 'PROTHEUS.CH'
#include "fwmvcdef.ch"

Static cTitulo := "Projeção de consumo dieta confinamento"

User Function LVFATI01()
    Local aArea   		:= FwGetArea()
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  
    
    SetFunName("LVFATI01")
	
    oModel := FWMBrowse():New()
	oModel:SetAlias( "ZEF" )
	oModel:SetDescription( cTitulo )
	oModel:Activate()
	
    SetFunName(cFunBkp)
	FwRestArea(aArea)
Return 

Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.LVFATI01' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	//ADD OPTION aRot TITLE 'Incluir'    		ACTION 'U_Tela1Pesagem' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	//ADD OPTION aRot TITLE 'Alterar'    		ACTION 'U_Tela2Pesagem' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.LVFATI01' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.LVFATI01' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.LVFATI01' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot


Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStrCab   := FWFormStruct(1, 'ZEF')
	Local oStrGrid  := FWFormStruct(1, 'ZEG')
	Local aZEGRel		:= {}

	//aAdd(aGatilhos,FwStruTrigger(;
	//							"ZAV_NOTA" 	 ,; // Campo Dominio
	//							"ZAV_ORIGEM" ,; // Campo de Contradominio
	//							"'M'" 		 ,; // Regra de Preenchimento
	//							.F.   		 ,; // Se posicionara ou nao antes da execucao do gatilhos
	//							""    		 ,; // Alias da tabela a ser posicionada
	//							0     		 ,; // Ordem da tabela a ser posicionada
	//							""    		 ,; // Chave de busca da tabela a ser posicionada
	//							NIL   		 ,; // Condicao para execucao do gatilho
	//							"01" )		 ; // Sequencia do gatilho (usado para identificacao no caso de erro)
	//							)

	//Criando o FormModel, adicionando o CabeÃ§alho e Grid
	oModel := MPFormModel():New("FATI01",/* bVldPre */, /* bVldPos */ /*Pos-Validacao*/, /* bVldCom */ /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZEFMASTER",/*cOwner*/ ,oStrCab  )
	oModel:AddGrid('ZEGDETAIL','ZEFMASTER',oStrGrid,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence

    aAdd(aZEGRel, {'ZEF_FILIAL', 'ZEG_FILIAL' } )
	aAdd(aZEGRel, {'ZEF_CODIGO', 'ZEG_CODIGO' } )

    oModel:SetRelation('ZEGDETAIL', aZEGRel, ZEG->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('ZEGDETAIL'):SetUniqueLine({"ZEG_FILIAL","ZEG_CODIGO","ZEG_ITEM"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey( {"ZEG_FILIAL","ZEG_CODIGO"} )

	//Setando outras informaÃ§Ãµes do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZEFMASTER"):SetDescription("Dados da "+cTitulo)
	oModel:GetModel("ZEGDETAIL"):SetDescription("Grid da "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("LVFATI01")
	Local oStrCab   := FWFormStruct(2, 'ZEF')
	Local oStrGrid  := FWFormStruct(2, 'ZEG')
	Local oView     := FWFormView():New()

    //oModel :=
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZEF" , oStrCab  , "ZEFMASTER")
	oView:AddGrid('VIEW_ZEG' , oStrGrid , 'ZEGDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BOX_CAB', 50)
	oView:CreateHorizontalBox('BOX_GRID', 50)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZEF'  	,'BOX_CAB'	)
	oView:SetOwnerView('VIEW_ZEG'  	,'BOX_GRID'	)

	oView:SetCloseOnOk( { |oView| .T. } )

    oView:EnableTitleView('VIEW_ZEF', 'Cabeçalho' 		) 
    oView:EnableTitleView('VIEW_ZEG', 'Itens') 

Return oView


