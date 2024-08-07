//Bibliotecas
#Include 'Protheus.ch'
#include 'totvs.ch'
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#INCLUDE "TOPCONN.CH"  


//Vari�veis Est�ticas
Static cTitulo := "Medicao Servicos/Produtos"

/*/{Protheus.doc} zMVCMd1
Fun��o para cadastro de Medicao de Servicos (SZ7), exemplo de Modelo 1 em MVC
@author Atilio (COLABORACAO)
@since 17/08/2015
@version 1.0
	@return Nil, Fun��o n�o tem retorno
	@example
	u_VACOMA04()
	@obs N�o se pode executar fun��o MVC dentro do f�rmulas
/*/

User Function VACOMA04()
	Local aArea   := GetArea()
	Local oBrowse
	Private aRotina := MenuDef()
	
	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SZ7")

	//Setando a descri��o da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Legendas
	oBrowse:AddLegend( "SZ7->Z7_STATUS == 'P'", "GREEN",	"Pendente" )
	oBrowse:AddLegend( "SZ7->Z7_STATUS == 'A'", "RED",		"Atendido" )
	oBrowse:AddLegend( "SZ7->Z7_STATUS == 'B'", "BLACK",	"Bloqueado" )
	
	//Ativa a Browse
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRotina := {}
	
	//Adicionando op��es
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VACOMA04' OPERATION  2 ACCESS 0//MODEL_OPERATION_VIEW   	ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.VACOMA04' OPERATION  3 ACCESS 0//MODEL_OPERATION_INSERT 	ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.VACOMA04' OPERATION  4 ACCESS 0//MODEL_OPERATION_UPDATE 	ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VACOMA04' OPERATION  5 ACCESS 0//MODEL_OPERATION_DELETE 	ACCESS 0 //OPERATION 5
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_C04Leg'      		OPERATION  6 ACCESS 0 //OPERATION X

Return aRotina



/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
	//Cria��o do objeto do modelo de dados
	Local oModel := Nil
	
	//Bloco de C�digo do Commit do Modelo
	Local b_Commit    := {|oMdl| C7Valid(oMdl)}

	//Bloco de C�digo do Commit do Modelo
	Local b_Pos    := {|oMdl| C7Valid(oMdl)}
	
	//Cria��o da estrutura de dados utilizada na interface
	Local oStSZ7 := FWFormStruct(1, "SZ7")
	
	//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("COMA04M",/*bPre*/, b_Pos, /*b_Commit*/ ,/*bCancel*/) 
	
	//Atribuindo formul�rios para o modelo
	oModel:AddFields("FORMSZ7",/*cOwner*/,oStSZ7)
	
	//Setando a chave prim�ria da rotina
	oModel:SetPrimaryKey({'Z7_FILIAL','Z7_PEDIDO','Z7_FORNECE','Z7_LOJA','Z7_SERVICO','Z7_DATA'})
	
	//Adicionando descri��o ao modelo
	oModel:SetDescription("Cadastro  "+cTitulo)
	
	//Setando a descri��o do formul�rio
	oModel:GetModel("FORMSZ7"):SetDescription("Formul�rio do Cadastro " + cTitulo)
Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o da vis�o MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
	//Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("VACOMA04")
	
	//Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStSZ7 := FWFormStruct(2, "SZ7")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	
	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_SZ7", oStSZ7, "FORMSZ7")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando t�tulo do formul�rio
	oView:EnableTitleView('VIEW_SZ7', 'Dados de Medicoes de Servicos/Produto' )  
	
	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})
	
	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_SZ7","TELA")
Return oView

/*/{Protheus.doc} COMA04Leg
Fun��o para mostrar a legenda das rotinas MVC com grupo de produtos
@author Atilio
@since 17/08/2015
@version 1.0
	@example
	COMA04Leg()
/*/

User Function C04Leg()
	Local aLegenda := {}
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Pendente"  })
	AADD(aLegenda,{"BR_VERMELHO",	"Atendido"})
	AADD(aLegenda,{"BR_PRETO",	    "Bloqueado"})
	BrwLegenda("Medicao Servicos/produtos", "Status", aLegenda)
Return



Static Function C7Valid(oModel)
	Local aArea 	:= GetArea()
	Local cQuery	:= ''
	Local n_Oper 	:= oModel:GetOperation() //Opera��o
	Local lRet		:= .T.
	LocAL nZ7Sld	:= 0 
	
	If n_Oper <> 3 .and. n_Oper <> 4
	  RestArea(aArea)
	  Return lRet
	Endif

	//Iniciando Transa��o
	//BeginTran()
	
	
		// Verificando se h� pedido para Diaria
		cQuery	:= " SELECT C7_NUM, SUM(C7_QUANT) AS C7_QUANT, SUM(C7_QUJE) AS C7_QUJE, SUM(C7_QUANT - C7_QUJE) as C7_SALDO   "
		cQuery	+= " FROM " + RetSqlName("SC7") + " SC7 "
		cQuery  += " LEFT JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON (B1_FILIAL ='" +xFILIAL("SB1")+ "'  AND C7_PRODUTO=B1_COD  AND SB1.D_E_L_E_T_='') "
		cQuery	+= " WHERE SC7.D_E_L_E_T_='' "
		cQuery	+= " AND C7_NUM 	= '"+M->Z7_PEDIDO+"'  "
		cQuery	+= " AND C7_FORNECE	= '"+M->Z7_FORNECE+ "'"
		cQuery	+= " AND C7_LOJA	= '"+M->Z7_LOJA+ "'"
		cQuery	+= " AND C7_PRODUTO = '"+M->Z7_SERVICO+ "'"
		cQuery	+= " AND B1_X_DIARI = 'S' "
		cQuery	+= " AND (C7_QUANT - C7_QUJE) > 0 "
		cQuery	+= " GROUP BY C7_NUM "
//		Memowrite("D:\TOTVS\VACOma04a.txt",cQuery)	

		
		If Select("SLDC7") > 0
			SLDC7->(DbCloseArea())
		EndIf
		TcQuery cQuery New Alias "SLDC7"
	
		If SLDC7->(Eof())
			Help( ,, 'HELP',, 'Pedido de Compras informado n�o existe!!!', 1, 0)    
 			//Alert('Pedido de Compras informado n�o existe!!!')
			lRet := .F.
		Else
			// Saldo de Di�rias Pendentes de Lancamentos em Documento de Entrada
			cQuery	:= " SELECT Z7_PEDIDO, SUM(Z7_QUANT) AS Z7_QUANT   "
			cQuery	+= " FROM " + RetSqlName("SZ7") + " SZ7 "
			cQuery	+= " WHERE SZ7.D_E_L_E_T_ = '' "
			cQuery	+= " AND  SZ7.Z7_PEDIDO 	=  '"+ M->Z7_PEDIDO + "'"
			cQuery	+= " AND  SZ7.Z7_SERVICO 	=  '"+ M->Z7_SERVICO + "'"
			cQuery	+= " AND  SZ7.Z7_FORNECE 	=  '"+ M->Z7_FORNECE + "'"
			cQuery	+= " AND  SZ7.Z7_LOJA 		=  '"+ M->Z7_LOJA + "'"
			cQuery	+= " AND  SZ7.Z7_COD 		<> '"+ M->Z7_COD + "'" // nao validar o codigo corrente (pode ser inclusao ou alteracao)
			cQuery  += " AND  SZ7.Z7_STATUS IN ('P') " // Avaliar somente pedidos pendentes
			cQuery	+= " GROUP BY Z7_PEDIDO "

//			Memowrite("D:\TOTVS\VACOma04b.txt",cQuery)	
			
			If Select("SLDZ7") > 0
				SLDZ7->(DbCloseArea())
			EndIf
			TcQuery cQuery New Alias "SLDZ7"
			
			// Saldo de Di�rias Pendentes
			If !SLDZ7->(Eof())
				nZ7Sld := SLDZ7->Z7_QUANT
			Endif
			
			
			// Valida Saldo do Pedido x Diarias Pendentes x Qtde de Di�rias Digitada
			If SLDC7->C7_SALDO < (M->Z7_QUANT + nZ7Sld)
				//Alert('Saldo do Pedido de Compras � insuficiente para esta Di�ria!!! Verique saldo do Pedido de Compras e/ou Di�rias Pendentes!!!')
				Help( ,, 'HELP',, 'Saldo do Pedido de Compras � insuficiente para esta Di�ria!!! Verique saldo do Pedido de Compras e/ou Di�rias Pendentes!!!', 1, 0)    
				lRet := .F.
			Endif
	
		Endif
		
	
		If Select("SLDC7") > 0
			SLDC7->(DbCloseArea())
		EndIf
		
		If Select("SLDZ7") > 0
			SLDZ7->(DbCloseArea())
		EndIf
	//Encerrando Transa��o
	//EndTran()
RestArea(aArea)
Return lRet
