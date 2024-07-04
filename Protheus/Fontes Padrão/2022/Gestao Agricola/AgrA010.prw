#INCLUDE "AGRA010.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA010
Função Principal do programa, nela será chamado todos os recursos e
criado o objeto oBrowse
@author thiago.rover
@since 20/01/2017
@version P12
@type AGRA010()
/*/
//-------------------------------------------------------------------
Function AGRA010()
	Local aArea   := GetArea() //Salva o ambiente ativo
	Local oBrowse := Nil

	//Instancia o objeto Browse, seta a tabela e seta a descrição
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('NN3')
	oBrowse:SetDescription( STR0001 )

	//Definição da legenda
	oBrowse:AddLegend( "NN3_FECHAD=='N'", "GREEN", STR0008 )
	oBrowse:AddLegend( "NN3_FECHAD=='S'", "RED"  , STR0009 )


	//Ativa o Browse
	oBrowse:Activate()

	RestArea(aArea)
Return aArea

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função Menu que contém as ações que o user tode tomar no sistema
@author thiago.rover
@since 20/01/2017
@version P12
@type MenuDef()
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	Local nx      := 0

	ADD OPTION aRotina TITLE STR0002  ACTION 'VIEWDEF.AGRA010' OPERATION 1 ACCESS 0 // Pesquisa
	ADD OPTION aRotina TITLE STR0003  ACTION 'VIEWDEF.AGRA010' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004  ACTION 'VIEWDEF.AGRA010' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005  ACTION 'VIEWDEF.AGRA010' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006  ACTION 'VIEWDEF.AGRA010' OPERATION 5 ACCESS 0 // Excluir
	ADD OPTION aRotina TITLE STR0013  ACTION 'VIEWDEF.AGRA010' OPERATION 8 ACCESS 0 // Imprimir


	//Ponto de Entrada para ações relacionadas
	If ExistBlock('AGRA010P')
		aRetM := ExecBlock('AGRA010P', .F.,.F.)
		if Type("aRetM") == 'A'
			For nx := 1 To Len(aRetM)
				Aadd(aRotina,aRetM[nx])
			Next nx
		Endif
	Endif

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função Modelo que contém regra de negócio
@author thiago.rover
@since 20/01/2017
@version undefined
@type ModelDef()
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	//Cria a estrutura a ser usada no Modelo de Dados
	Local oStruNN4   := FWFormStruct( 1, 'NN4' ) // Variedade No Talhão
	Local oStruNN3   := FWFormStruct( 1, 'NN3' ) // Talhão (Tabela Pai)
	Local oModel 	 := Nil
	Local bCodPro    := "IIF(!INCLUI,Posicione('NN3',1,xFilial('NN3')+FwFldGet('NN4_SAFRA')+FwFldGet('NN4_FAZ')+FwFldGet('NN4_TALHAO'),'NN3_CODPRO'),'') "	

	If GetRpoRelease() >= "12.1.033"
   		oStruNN4:SetProperty( 'NN4_CODPRO', MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bCodPro))
	EndIf
	//Instancia o modelo de dados
	oModel := MPFormModel():New( 'AGRA010' , , , {|oModel| GrvModelo(oModel)})
	oModel:SetDescription( STR0002 )

	//Adiciona estrutura de campos no modelo de dados
	oModel:AddFields( 'AGRA010_NN3', /*cOwner*/, oStruNN3 )
	oModel:SetDescription( STR0003 )

	//Altera a obrigatoriedade do campo 
	oStruNN4:SetProperty( 'NN4_SAFRA'  , MODEL_FIELD_OBRIGAT , .F.)
	oStruNN4:SetProperty( 'NN4_FAZ'    , MODEL_FIELD_OBRIGAT , .F.)
	oStruNN4:SetProperty( 'NN4_TALHAO' , MODEL_FIELD_OBRIGAT , .F.)

	If oStruNN4:HasField("NN4_CODPRO") //liberado na release P12.1.033
		oStruNN4:AddTrigger( "NN4_CODVAR", "NN4_CODPRO", { || .T. }, { | x | fTrgCodPro( x ) } )
	EndIf


	//Cria o grid e pega o modelo  
	oModel:AddGrid( "AGRA010_NN4", "AGRA010_NN3", oStruNN4 )
	oModel:GetModel('AGRA010_NN4'):SetDescription( STR0017 )

	//Atribui um relacionamento de Pai X Filho
	oModel:SetRelation( 'AGRA010_NN4', {{'NN4_FILIAL', 'xFilial("NN4")'},{ 'NN4_SAFRA', 'NN3_SAFRA' },{ 'NN4_FAZ', 'NN3_FAZ' }, { 'NN4_TALHAO', 'NN3_TALHAO' }}, NN4 ->(IndexKey( 1 ) ) )

	//Obriga a informar tanto o cabeçalho quanto os dados da grid
	oModel:GetModel( "AGRA010_NN4" ):SetOptional( .F. )

	//Seta Chave Primária
	oModel:SetPrimaryKey( {"NN3_FILIAL","NN3_SAFRA","NN3_FAZ","NN3_TALHAO"} )

Return oModel



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função visual que contém toda parte gráfica de exibição em tela
@author thiago.rover
@since 20/01/2017
@version undefined
@type ViewDef()
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView       := Nil
	Local oModel      := FwLoadModel( "AGRA010" ) //Carrega o Modelo
	Local oStruNN4    := FwFormStruct( 2, "NN4",{|cCampo|!(Alltrim(cCampo) $ "NN4_SAFRA|NN4_FAZ|NN4_TALHAO|")}) //Oculta os campos no objeto oStruNN4 da estrutura 
	Local oStruNN3    := FwFormStruct( 2, "NN3" ) //Cria umn campo que fornece o objeto da estruturas 

	If NN3->(ColumnPos('NN3_ID')) > 0 
		oStruNN3:RemoveField('NN3_ID')
	EndIf

	//Instância modelo de visualização
	oView := FwFormView():New()

	//Seta o modelo de dados
	oView:SetModel( oModel )

	//Adiciona os campos na estrutura do modelo de dados
	oView:AddField("AGRA010_NN3",oStruNN3, "AGRA010_NN3")

	//Adiciona ao view um formulário do tipo FWFormGrid
	oView:AddGrid( "AGRA010_NN4", oStruNN4, "AGRA010_NN4" )

	//Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "SUPERIOR", 50 )
	oView:CreateHorizontalBox( "INFERIOR", 50 )

	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( "AGRA010_NN3", "SUPERIOR" )
	oView:SetOwnerView( "AGRA010_NN4" , "INFERIOR" )

	//Adiciona um campo para ser AutoIncremental em um FormGrid
	oView:AddIncrementField("AGRA010_NN4" , "NN4_ITEM" )

	//Cria um título para um formulário
	oView:EnableTitleView( "AGRA010_NN3" )
	oView:EnableTitleView( "AGRA010_NN4" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvModelo
Função que valida no momento do commit a soma das áreas dos hectares.
@author thiago.rover
@since 27/01/2017
@param oModel
@type GrvModelo(oModel)
/*/  
//-------------------------------------------------------------------
Static Function GrvModelo(oModel)
	Local lRetorno  := .T.
	Local nX        := 0
	Local nTotal    := 0
	Local oGridNN3  := oModel:GetModel('AGRA010_NN3') //Pega o modelo da Grid
	Local oGridNN4  := oModel:GetModel('AGRA010_NN4') //Pega o modelo da Grid
	Local oModel    := FWModelActive() // Model que se encontra Ativo

	//Loop para pegar o valor através do tampo da grid 
	For nX := 1 to oGridNN4:Length() 
		oGridNN4:Goline(nX)
				
		If	!oGridNN4:IsDeleted() 
			If !Empty(oGridNN4:GetValue("NN4_HECTAR"))
				nTotal += FwFldGet('NN4_HECTAR') // FwFlGet retorna o valor do campo
			Else
				oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0018, STR0019, "", "")
			Endif	  
			
			cProduto := Posicione('NNV',1,FwXFilial('NNV')+FwFldGet('NN3_CODPRO')+oGridNN4:GetValue('NN4_CODVAR'),"NNV_CODPRO")
			
			If Empty(cProduto)
				oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0020, STR0021, "", "")
				lRetorno := .F.
				Exit
			Endif
		Endif
	Next nX
	
	//Verificação se o valor da grid é diferente do cabeçalho
	If nTotal != oGridNN3:GetValue("NN3_HECTAR") .And. .Not. FwIsInCallStack("IntegDef")
		lRetorno := .F.
	EndIf

	//If que valida e gera o commit
	If lRetorno == .T.
		FwFormCommit(oModel, , {|oModel,cID,cAlias| .T.})
	Else
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0010, STR0022, "", "")
	Endif

Return lRetorno  


/*/{Protheus.doc} IntegDef
//Integracao de Talhoes
@author carlos.augusto
@since 09/10/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local aRet := {}
	
	If FindFunction("AGRI010")
		//a funcao integdef original foi transferida para o fonte AGRI010, conforme novas regras de mensagem unica.
		aRet:= AGRI010( cXml, nTypeTrans, cTypeMessage )
	EndIf
Return aRet


/** {Protheus.doc} fTrgCodPro
função de trigger para setar valor no campo NN4_CODPRO
Campo NN4_CODPRO liberado na release P12.1.033

@author claudineia.reinert	
@since 18/06/2021
@version 1.0
@type function
@return cReturn, valor para o campo

*/
Static Function fTrgCodPro( oParModel )
	Local oModel		:= oParModel:GetModel()
	Local oNN3			:= oModel:GetModel( "AGRA010_NN3" )
	Local cRetorno 		:= ""

	If !Empty(oParModel:GetValue( "NN4_CODVAR" )) 
		cRetorno := Posicione('NNV',1,FwXFilial('NNV')+oNN3:GetValue('NN3_CODPRO')+oParModel:GetValue('NN4_CODVAR'),"NNV_CODPRO")
	EndIf

Return( cRetorno )
