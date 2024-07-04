#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA011.CH'


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA011
Cadastro de Categorias
 
@sample		GTPA011()
@return		Objeto oBrowse  
@author		Yuki
@since			
@version	12.1.7	
/*/
//--------------------------------------------------------------------------------------------------------
Function GTPA011()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('GYR')//Nome da tabela 
	oBrowse:SetDescription(STR0001)//Cadastro de Categorias
	oBrowse:Activate()//Ativar o oBrowser

Return oBrowse

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do Menu
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	//Criando uma variavel do tipo array para ser armazenado os botões criado
	Local aRotina := {}

	//Os numero do OPERATION está relacionada a funcionalidade basica de crud 
	//Mais alguma rotinas extras.
	ADD OPTION aRotina Title STR0007 Action 'PesqBrw' 		  OPERATION 1 ACCESS 0 //#Pesquisar
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.GTPA011' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.GTPA011' OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.GTPA011' OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.GTPA011' OPERATION 5 ACCESS 0 //Excluir
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	
	Local oStructGYR := FWFormStruct(1,'GYR') //Estrutura GYR
	Local bPosValid	:= {|oModel|TP011TdOK(oModel)}	
	Local oModel // criando objeto de modelo
	
	oModel := MPFormModel():New('GTPA011',/*pre validacao*/, bPosValid,/*bCommit*/,/*bCancel*/)
	//Criando objeto da model paramentro principal primeiro campo id da modelo 
	
	//adicionando componete de formulario
	//campo 1 id, compo 2 caso tiver pai referencia ele e campo 3 esrutura a ser usado
	oModel:AddFields('GYRMASTER',/* cOwner */,oStructGYR)
	
	//Adiciona descrição no modelo de dados 
	//Obs sempre utilizar strXXXX nenhum texto na fonte
	oModel:SetDescription(STR0001)//Cadastro de Categorias
	
	//Adiciona descrição componente de dados 
	//Obs sempre utilizar strXXXX nenhum texto na fonte
	oModel:GetModel('GYRMASTER'):SetDescription(STR0006)
	
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da Interface
 
@sample	ViewDef()
 
@return	oView - Objeto da Interface
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel := FWLoadModel('GTPA011') //Referencia um modelo nao pode caso tenha mais modelo 
	
	//Fornece estrutura metadado do dicionario de dados caso paramentro for 1 
	//Model caso parametro for 2 view
	Local oStruGYR := FWFormStruct(2,'GYR')
	
	//objeto da view
	Local oView 
	
	//Criando o objeto da view
	oView:= FWFormView():New()
	
	//definindo o model que será utilizando na view
	oView:SetModel(oModel)
	
	//adicionando controle tipo formulario/campo do formulario seguindo a model 
	//campo codigo da field, campo 2 estrutura e campo 3 id da field da model
	oView:AddField('VIEW_GYR',oStruGYR,'GYRMASTER')
	
	//cria uma caixa horizontal para receber os elementos da view pode fazer varias 
	//box uma dentro da outra de acordo com a necessidade  
	//Campo 1 id da box e campo 2 tamanho vai de 0 a 100 possui função vertical box
	oView:CreateHorizontalBox('TELA_GYR',100)
	
	//Relaciona a view com box a que sera utilizado pelo ID criado acima
	oView:SetOwnerView('VIEW_GYR','TELA_GYR')
//Retonar objeto da view configurado
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TP011TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP011TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGYR	:= oModel:GetModel('GYRMASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGYR:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGYR:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GYR", oMdlGYR:GetValue("GYR_CODIGO")))
		Help( ,, 'Help',"TP011TdOK", STR0008, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)
       

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}
aRet:= GTPI011( cXml, nTypeTrans, cTypeMessage )
Return aRet