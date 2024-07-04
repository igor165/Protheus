#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPXGZV
Cadastro de De/Paras utilizado pelo módulo GTP
@type function
@author jacomo.fernandes
@since 14/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPXGZV()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('GZV')//Nome da tabela 
	oBrowse:SetDescription("Cadastro de De/Paras GTP")
	oBrowse:Activate()//Ativar o oBrowser

Return oBrowse
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@type function
@author jacomo.fernandes
@since 14/07/2018
@version 1.0
@return ${aRotina}, ${Array contendo as opções de Menu}
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {} //Criando uma variavel do tipo array para ser armazenado os botões criado

	ADD OPTION aRotina Title "Pesquisar"	Action 'VIEWDEF.GTPXGZV'	OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title "Visualizar"	Action 'VIEWDEF.GTPXGZV'	OPERATION 2 ACCESS 0 //"Visualizar"
	/*
	ADD OPTION aRotina Title "Incluir"		Action 'VIEWDEF.GTPXGZV'	OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title "Alterar"		Action 'VIEWDEF.GTPXGZV'	OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title "Excluir"		Action 'VIEWDEF.GTPXGZV'	OPERATION 5 ACCESS 0 //"Excluir"
	*/
	ADD OPTION aRotina Title "Vis. Origem"	Action 'GTPXG9XVW()'		OPERATION 2 ACCESS 0 
	
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@type function
@author jacomo.fernandes
@since 14/07/2018
@version 1.0
@return ${oModel}, ${Retorna o Modelo de Dados}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	
	Local oModel	:= MPFormModel():New('GTPXGZV',/*bPreValid*/, /*bPosValid*/,/*bCommit*/,/*bCancel*/) //Criando objeto da model 
	Local oStruGZV	:= FWFormStruct(1,'GZV') //Estrutura GZV
	
	//Adicionando componete de formulario
	oModel:AddFields('GZVMASTER',/* cOwner */,oStruGZV)
	
	oModel:SetPrimaryKey({"GZV_FILIAL","GZV_ALIAS","GZV_MARCA","GZV_EXTID"})
	
	//Adiciona descrição no modelo de dados 
	oModel:SetDescription("Cadatro de De/Para GTP")//Cadastro de Categorias
	
	//Adiciona descrição componente de dados 
	oModel:GetModel('GZVMASTER'):SetDescription("De/Para")
	
Return oModel
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da Interface
@type function
@author jacomo.fernandes
@since 14/07/2018
@version 1.0
@return ${oView}, ${Objeto da Interface}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= FWFormView():New()		//Criando o objeto da view
	Local oModel	:= FWLoadModel('GTPXGZV')	//Referencia um modelo nao pode caso tenha mais modelo 
	Local oStruGZV	:= FWFormStruct(2,'GZV')	//Fornece estrutura metadado do dicionario de dados
	
	//definindo o model que será utilizando na view
	oView:SetModel(oModel)
	
	//adicionando controle tipo formulario/campo do formulario seguindo a model 
	oView:AddField('VIEW_GZV',oStruGZV,'GZVMASTER')
	
	//cria uma caixa horizontal para receber os elementos da view 
	oView:CreateHorizontalBox('TELA_GZV',100)
	
	//Relaciona a view com box a que sera utilizado pelo ID criado acima
	oView:SetOwnerView('VIEW_GZV','TELA_GZV')

Return oView //Retonar objeto da view configurado

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPXUpdGZV
Função utilizada para criação do registro de de/para
@type function
@author jacomo.fernandes
@since 14/07/2018
@version 1.0
@param cAlias, character, Alias de Origem do Registro
@param cMarca, character, Marca de origem do registro
@param cExtId, character, ExternalId vindo da integração
@param nIndice, numérico, Indice de busca do registro
@param cChave, character, Chave de busca do Registros
@param aFld, array, Array contendo os dados de preenchimento da tabela GZV (Ex: {{'GZV_EXTGYN','0001|2018-07-14'}}
@param lDelete, logico, Informa se a operação é de deleção
@param cMvcObj, character, informa qual o objeto de visualização do registro
@return lRet, Informa se a operação foi com sucesso ou não
@example
GTPXUpdGZV("GIC",cMarca,cExtId,1,xFilial('GIC')+oMdlGIC:GetValue('GIC_CODIGO'),aDadosGZV,lDelete,"GTPA115")
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Function GTPXUpdGZV(cAlias,cMarca,cExtId,nIndice,cChave,aFld,lDelete,cMvcObj,lErroInt)
Local lRet			:= .T.
Local oModel		:= FwLoadModel('GTPXGZV')
Local oMdlGZV		:= oModel:GetModel('GZVMASTER')
Local oStrGZV		:= oMdlGZV:GetStruct() 
Local nOperation	:= MODEL_OPERATION_INSERT
Local cMsgErro		:= ""
Local n1			:= 0

Default cAlias		:= Alias()
Default cMarca		:= "PROTHEUS"
Default cExtId		:= ""
Default nIndice		:= 1
Default cChave		:= ""
Default aFld		:= {}
Default lDelete		:= .F.
Default cMvcObj		:= ""
Default lErroInt	:= .F.

If Empty(cExtId) .or. Empty(cChave)
	lRet		:= ""
	cMsgErro	:= "Não é possivel gravar um registro sem o ExternalId ou a Chave de busca" 
Endif
If lRet
	GZV->(DbSetOrder(1))//GZV_FILIAL+GZV_MARCA+GZV_ALIAS+GZV_EXTID
	If !lDelete .and. !GZV->(DbSeek(xFilial('GZV')+cAlias+Padr(cMarca,TamSx3('GZV_MARCA')[1])+cExtId))
		nOperation	:= MODEL_OPERATION_INSERT
	Else
		nOperation	:= If(!lDelete,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE) 
	Endif
	
	oModel:SetOperation(nOperation)
	
	If lRet	:= oModel:Activate()
		If nOperation <> MODEL_OPERATION_DELETE
			If nOperation == MODEL_OPERATION_INSERT
				oMdlGZV:SetValue('GZV_ALIAS'	,cAlias)
				oMdlGZV:SetValue('GZV_MARCA'	,cMarca)
				oMdlGZV:SetValue('GZV_EXTID'	,cExtId)
				oMdlGZV:SetValue('GZV_INDICE'	,nIndice)
				oMdlGZV:SetValue('GZV_CHAVE'	,cChave)
				oMdlGZV:SetValue('GZV_MVCOBJ'	,cMvcObj)
			Endif
			
			If oStrGZV:HasField('GZV_STATUS')
				oMdlGZV:SetValue('GZV_STATUS'	,If( lErroInt,'2','1'))
			Endif
			For n1	:= 1 To Len(aFld)
				If oStrGZV:HasField(aFld[n1][1])
					If !(lRet := oMdlGZV:SetValue(aFld[n1][1]	,aFld[n1][2]))
						Exit
					Endif
				Endif
			Next		
		Endif
		If lRet	.and. oModel:VldData()
			oModel:CommitData()
		Else
			lRet := .F.
			cMsgErro	:= GTPGetErrorMsg(oModel)
		Endif
		oModel:DeActivate()	
	Endif 
Endif

oModel:Destroy()

GTPDestroy(oModel)
GTPDestroy(aFld)

Return lRet


/*/{Protheus.doc} GTPXG9XVW
Abre a View do regitro de origem conforme definido pelo campo GZV_MVCOBJ (Exemplo: VIEWDEF.GTPA115)
@type function
@author jacomo.fernandes
@since 14/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPXG9XVW()
Local aArea	:= (GZV->GZV_ALIAS)->(GetArea())
(GZV->GZV_ALIAS)->(DbSetOrder(GZV->GZV_INDICE))
If (GZV->GZV_ALIAS)->(DbSeek(GZV->GZV_CHAVE))
	If !Empty(GZV->GZV_MVCOBJ) 
		FWExecView("Visualizar","VIEWDEF."+GZV->GZV_MVCOBJ, MODEL_OPERATION_VIEW,,{|| .T.})
	Else
		FwAlertHelp('Não foi possivel visualizar o registro pois não foi informado o Objeto de Visualização')
	Endif
Else
	FwAlertHelp('Não foi possivel encontrar o registro informado')
Endif

RestArea(aArea)
GTPDestroy(aArea)
Return