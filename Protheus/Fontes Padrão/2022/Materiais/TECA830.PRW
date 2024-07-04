#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA830.CH"

//----------------------------------------------------------
/*/{Protheus.doc} TECA830()
Cadastro de Lista de emails 

@Return 	nil
@author 	Serviços
@since 		09/09/2013
/*/
//----------------------------------------------------------
Function TECA830()

Local oBrowse 

// Instanciamento da Classe de Browse
oBrowse := FwMBrowse():New()

// Definição da tabela do Browse
oBrowse:SetAlias("TEP")

// Titulo da Browse
oBrowse:SetDescription(STR0001) // Cadastro de Lista de Emails

//Desabilita tela de detalhes no momento de abertura do modulo
oBrowse:DisableDetails()

//Legendas para o browse
oBrowse:Addlegend("TEP_STATUS=='1'", "GREEN"	, STR0002) // Email Ativo
oBrowse:Addlegend("TEP_STATUS=='2'", "RED"	, STR0003) // Email Inativo

// Ativação da Classe
oBrowse:Activate()

Return(Nil) 


//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Lista de emails

@Return 	MenuDef
@author 	Serviços
@since 		09/09/2013
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0004 	ACTION "AxPesqui" 			OPERATION 1	ACCESS 0 	// "Pesquisar"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TECA830"		OPERATION 2 	ACCESS 0 	// "Visualizar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TECA830" 	OPERATION 3	ACCESS 0 	// "Incluir"
ADD OPTION aRotina TITLE STR0007	ACTION "VIEWDEF.TECA830"		OPERATION 4	ACCESS 0 	// "Alterar"

Return(aRotina)


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Cadastro de Lista de emails

@Return 	model
@author 	Serviços
@since 		09/09/2013
/*/
//----------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oModel	// Modelo de dados que será construido
Local oStruTEP := FWFormStruct(1,"TEP") 

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("TECA830", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo um componente de formulário, obrigatorio para o modelo
oModel:AddFields("TEPMASTER",/*cOwner*/,oStruTEP, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0008) // Lista de Emails 									  

Return(oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Cadastro de Lista de emails

@Return 	view
@author 	Serviços
@since 		09/09/2013
/*/
//----------------------------------------------------------
Static Function ViewDef()

// Interface de visualização construída
Local oView
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel   := FWLoadModel("TECA830")  
// Cria a estrutura a ser usada na View
Local oStruTEP := FWFormStruct(2,"TEP")

// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados será utilizado na View
oView:SetModel(oModel)
// Adiciona no nosso View um controle do tipo formulário
//(antiga enchoice)
oView:AddField("VIEW_TEP",oStruTEP,"TEPMASTER")
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( "TELA" , 100 ) // 100 = % utilizado da tela
// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( "VIEW_TEP", "TELA" ) 

Return(oView)