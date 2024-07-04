#include 'GPEA936A.ch'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := STR0001  //"Cópia Tabela"
Static lcTabela	  := !ChkFile("RJ7") .And. !ChkFile("RJ8")

Function GPEA936A()
	Local aArea   	:= GetArea()
	Local cFunBkp 	:= FunName()
	Local cMsgDesatu:= ""
	Local oBrowse
	
	SetFunName("GPEA936A")
	
	If lcTabela
 	cMsgDesatu := CRLF + OemToAnsi(STR0012) + CRLF //"Tabela RJ7 e RJ8 não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
 	EndIf

 	If !Empty(cMsgDesatu)
		//ATENCAO"###"Tabela RJ9 não encontrada na base de dados. Execute o UPDDISTR."
		//ATENCAO"###
		Help( " ", 1, OemToAnsi(STR0013),, cMsgDesatu, 1, 0 )
		Return 																	
	EndIf
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("RJ8")
	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Legendas
	oBrowse:AddLegend( "RJ8->RJ8_STATUS == '0'", "YELLOW" ,	STR0002 ) //"Não Processado"
	oBrowse:AddLegend( "RJ8->RJ8_STATUS == '1'", "GREEN",	STR0003 ) //"Processado"
	oBrowse:AddLegend( "RJ8->RJ8_STATUS == '2'", "RED"  ,	STR0004 ) //"Erro"
	
	//Ativa a Browse
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea)
	
Return Nil

Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.GPEA936A' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1 ##'Visualizar'
	ADD OPTION aRot TITLE STR0006 ACTION 'U_GP936AL()'      OPERATION 6                      ACCESS 0 //OPERATION X ##'Legenda'
	ADD OPTION aRot TITLE STR0007 ACTION 'VIEWDEF.GPEA936A' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3 ##'Incluir'
	ADD OPTION aRot TITLE STR0008 ACTION 'VIEWDEF.GPEA936A' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4 ##'Alterar'
	ADD OPTION aRot TITLE STR0009 ACTION 'VIEWDEF.GPEA936A' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 ##'Excluir'
Return aRot

Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil
	
	//Criação da estrutura de dados utilizada na interface
	Local oStRJ8 := FWFormStruct(1, "RJ8")
	
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("GPEA936AM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMRJ8",/*cOwner*/,oStRJ8)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'RJ8_FILIAL','RJ8_FILPAR','RJ8_TABELA','RJ8_CONTEU','RJ8_DATA','RJ8_HORA'})
	
	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMRJ8"):SetDescription(cTitulo)
Return oModel

Static Function ViewDef()
	Local aStruRJ8	:= RJ8->(DbStruct())
	
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("GPEA936A")
	
	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStRJ8 := FWFormStruct(2, "RJ8")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZZ1_NOME|SZZ1_DTAFAL|'}
	
	//Criando oView como nulo
	Local oView := Nil
	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_RJ8", oStRJ8, "FORMRJ8")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	oView:EnableTitleView('VIEW_RJ8', STR0010+cTitulo ) //'Dados - '  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_RJ8","TELA")
	
	
Return oView

/*/{Protheus.doc} GP935AL
Função para mostrar a legenda
@author SAMUEL DE VINCENZO
@since 09/06/2019
@version 1.0
	
/*/
User Function GP936AL()
	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",		STR0003  }) //"Processado"
	AADD(aLegenda,{"BR_VERMELHO",	STR0004  }) //"Erro"
	AADD(aLegenda,{"BR_AMARELO"   , STR0002  }) //"Não Processado"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	
	
	BrwLegenda(cTitulo, STR0011, aLegenda) //Status
Return