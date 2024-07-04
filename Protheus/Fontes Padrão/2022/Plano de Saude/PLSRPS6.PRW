#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TOTVS.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 10/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
/*
Add Option aRotina Title 'Incluir'    Action 'VIEWDEF.PLSRPS6' Operation 3 Access 0
Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSRPS6' Operation 2 Access 0
Add Option aRotina Title 'Alterar'    Action 'VIEWDEF.PLSRPS6' Operation 4 Access 0
*/
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 10/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel // Modelo de dados construído
Local oStrB5B:= FWFormStruct(1,'B5B' )// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar

oModel := MPFormModel():New( 'PLSRPS6' ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterB5B',/*cOwner*/,oStrB5B)  // Adiciona ao modelo um componente de formulário

oModel:GetModel('MasterB5B'):SetDescription( 'Registros RPS' ) // Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {"B5B_FILIAL", "B5B_CODOPE", "B5B_NUMLOT", "B5B_CODRDA", "B5B_CODLOC", "Str(B5B_SEQVIN)"} )

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 10/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado

Local oView  // Interface de visualização construída
Local oModel := FWLoadModel( 'PLSRPS6' ) // Cria as estruturas a serem usadas na View
Local oStrB84:= FWFormStruct(2, 'B5B' )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewB5B' , oStrB84,'MasterB5B' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oView:CreateHorizontalBox( 'SUPERIOR' , 100 ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente

oView:SetOwnerView('ViewB5B','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibição

Return oView // Retorna o objeto de View criado
