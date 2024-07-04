#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA019A.CH"

Static aItContrat:= {}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA019A
Rotina MVC Para Manutenção Dos Arquivos MRP Importados (TMS).
@author Eduardo Alberti
@version Versao P12
@since 27/Nov/2015
@return Nil
@obs . 
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA019A(cFilDDD)

	Local oMBrowse	:= Nil
	Local aArea		:= GetArea()

	Private aRotina	:= MenuDef(.t.)
	
	Default cFilDDD	:= ""
	
	//-- Validação Do Dicionário Utilizado
	If ! AliasInDic("DDD")
		MsgNextRel()	//-- É Necessário a Atualização Do Sistema Para a Expedição Mais Recente
		Return()
	EndIf	

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('DDD')
	oMBrowse:SetDescription( STR0001 + "- TMS " ) //-- "Importação MRP"
	oMBrowse:DisableDetails()
	
	//-- Executa Filtro Caso Informado
	If !Empty(cFilDDD)
		oMBrowse:SetFilterDefault( cFilDDD )
	EndIf	
	
	//-- Adiciona Legendas Padrão MVC No Browse
	oMBrowse:AddLegend( "DDD_STATUS == '2'", "GREEN"	, STR0010 	)	//-- "Pendente Processamento"
	oMBrowse:AddLegend( "DDD_STATUS == '3'", "RED"	, STR0011	)	//-- "Processado - Agendamento(s) Gerado(s)"
	oMBrowse:AddLegend( "DDD_STATUS == '1'", "YELLOW", STR0012	)	//-- "Importado - Erro Processamento"

	oMBrowse:Activate()

	RestArea(aArea)

Return NIL
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@autor		: Eduardo Alberti
Manutenção Dos Arquivos MRP Importados (TMS).
@descricao	: ModelDef
@since		: Nov./2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local aArea		:= GetArea()
	Local oStructCab 	:= Nil
	Local oStructGrd 	:= Nil
	Local oModel     	:= Nil

	//-----------------------------------------
	//--Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructCab := FWFormStruct(1,"DDD" )
	oStructGrd := FWFormStruct(1,"DDE" )

	//-----------------------------------------
	//--Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New("TMSA019A", /*Pré-Validação*/ , /*Pos-Validacao*/ , /*bCommit*/ , /*bCancel*/ )

	oModel:AddFields("TMSA019A_CAB",/*cOwner*/, oStructCab)

	oModel:SetPrimaryKey({"DDD_FILIAL","DDD_DATAGE","DDD_HORAGE","DDD_CLIDES","DDD_LOJDES","DDD_SQEDES","DDD_CLIREM","DDD_LOJREM","DDD_SQEREM"})

	oModel:GetModel("TMSA019A_CAB"):SetDescription( STR0001 ) //-- "Importação MRP"

	oModel:AddGrid("TMSA019A_GRD", "TMSA019A_CAB", oStructGrd,/*bLinePre*/, { |oMdlG,nLine| fGrdLinePos( oMdlG, nLine) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	oModel:GetModel("TMSA019A_GRD"):SetDescription( STR0002 ) //-- "Itens MRP"

	//-- Criação de relação entre as entidades do modelo
	oModel:SetRelation("TMSA019A_GRD",{	{"DDE_FILIAL",'xFilial("DDE")'},;
												{"DDE_DATAGE","DDD_DATAGE"    },;
												{"DDE_HORAGE","DDD_HORAGE"    },;
												{"DDE_CLIDES","DDD_CLIDES"    },;
												{"DDE_LOJDES","DDD_LOJDES"    },;
												{"DDE_SQEDES","DDD_SQEDES"    },;
												{"DDE_CLIREM","DDD_CLIREM"    },;
												{"DDE_LOJREM","DDD_LOJREM"    },;
												{"DDE_SQEREM","DDD_SQEREM"    } }, DDE->(IndexKey(1)))

	//-- Validação de linha duplicada
	oModel:GetModel( "TMSA019A_GRD" ):SetUniqueLine( {	"DDE_FILIAL",;
																"DDE_DATAGE",;
																"DDE_HORAGE",;
																"DDE_CLIDES",;
																"DDE_LOJDES",;
																"DDE_SQEDES",;
																"DDE_CLIREM",;
																"DDE_LOJREM",;
																"DDE_SQEREM",;
																"DDE_CODPRO" } )

	//-- Não permitir serem inseridas linhas no grid.
	oModel:GetModel("TMSA019A_GRD"):SetNoInsertLine(.T.)
	
	//-- Validação Da Model (Define Se Abre Ou Não)
	oModel:SetVldActivate( { |oMdl| DDDMdlAct( oMdl ) } )

	RestArea(aArea)

Return(oModel)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@autor		: Eduardo Alberti
@descricao	: Retorna a View (tela) da rotina
@since		: Nov./2015
@using		: Manutenção Dos Arquivos MRP Importados (TMS).
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local aArea		:= GetArea()
	Local oView		:= Nil
	Local oStructCAB	:= Nil
	Local oStructGrd	:= Nil
	Local oModel     	:= FWLoadModel("TMSA019A")

	oStructCab := FwFormStruct( 2,"DDD" )
	oStructGrd := FwFormStruct( 2,"DDE" )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)
	
	// Remoção de campos para não serem exibidos dos Grid Usuários
	oStructGrd:RemoveField( 'DDE_DATAGE' )
	oStructGrd:RemoveField( 'DDE_HORAGE' )
	oStructGrd:RemoveField( 'DDE_CLIDES' )
	oStructGrd:RemoveField( 'DDE_LOJDES' )
	oStructGrd:RemoveField( 'DDE_SQEDES' )
	oStructGrd:RemoveField( 'DDE_CLIREM' )
	oStructGrd:RemoveField( 'DDE_LOJREM' )
	oStructGrd:RemoveField( 'DDE_SQEREM' )

	oView:AddField( "TMSA019A_CAB",oStructCab)
	oView:CreateHorizontalBox("CABEC",30)
	oView:SetOwnerView( "TMSA019A_CAB","CABEC")

	oView:AddGrid("TMSA019A_GRD",oStructGrd)
	oView:CreateHorizontalBox("GRID",70)
	oView:SetOwnerView( "TMSA019A_GRD","GRID")

	RestArea(aArea)

Return oView

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@autor		: Eduardo Alberti
@descricao	: Funcao Para Montagem Do Menu Funcional Padrao Protheus
@since		: Oct./2014
@using		: MRP - Importações
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local	aRotina    := {}

	ADD OPTION aRotina TITLE STR0003	  	ACTION 'PesqBrw'          	OPERATION 1 ACCESS 0 DISABLE MENU 		// 'Pesquisar'
	ADD OPTION aRotina TITLE STR0004	 	ACTION 'VIEWDEF.TMSA019A' 	OPERATION 2 ACCESS 0 DISABLE MENU 		// 'Visualizar'
	ADD OPTION aRotina TITLE STR0005    	ACTION 'VIEWDEF.TMSA019A' 	OPERATION 3 ACCESS 0 					// 'Incluir'
	ADD OPTION aRotina TITLE STR0006    	ACTION 'VIEWDEF.TMSA019A' 	OPERATION 4 ACCESS 0 DISABLE MENU		// 'Alterar'
	ADD OPTION aRotina TITLE STR0007    	ACTION 'VIEWDEF.TMSA019A' 	OPERATION 5 ACCESS 0 DISABLE MENU		// 'Excluir'
	ADD OPTION aRotina TITLE STR0008		ACTION 'VIEWDEF.TMSA019A' 	OPERATION 8 ACCESS 0 DISABLE MENU		// 'Imprimir'
	ADD OPTION aRotina TITLE STR0009		ACTION 'VIEWDEF.TMSA019A' 	OPERATION 9 ACCESS 0 DISABLE MENU		// 'Copiar'
//	ADD OPTION aRotina TITLE "Legenda"		ACTION 'TMSA019Leg()'		OPERATION 2 ACCESS 0 DISABLE MENU		// 'Legenda'	

Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DDDMdlAct
@autor		: Eduardo Alberti
@descricao	: Validação da ativação do modelo
@since		: Dec./2015
@using		: Manutenção Dos Arquivos MRP Importados (TMS).
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function DDDMdlAct(oModel)

	Local lRet        := .T.
	Local aArea       := GetArea()
	Local nOperation  := oModel:GetOperation()
	Local cStatus     := DDD->DDD_STATUS 
	
	If nOperation == MODEL_OPERATION_INSERT // Inclusão
	
		Help("",1,"TMSA019A03",/*Titulo*/, STR0013 /*Mensagem*/,1,0) //-- "Inclusão Manual Não é Permitida Nesta Rotina. Inclua Diretamente Na Rotina De Agendamentos"
		lRet := .f.
	
	ElseIf nOperation == MODEL_OPERATION_UPDATE // Alteração
	
		If cStatus <> '2' //-- Pendente
			Help("",1,"TMSA019A04",/*Titulo*/, STR0014 /*Mensagem*/,1,0) //-- "Opção Disponível Somente Para Registros Com Status Pendente."
			lRet := .f.
		EndIf		
	
	ElseIf nOperation == MODEL_OPERATION_DELETE // Exclusão

		If cStatus <> '2' //-- Pendente
			Help("",1,"TMSA019A04",/*Titulo*/, STR0014 /*Mensagem*/,1,0) //-- "Opção Disponível Somente Para Registros Com Status Pendente."
			lRet := .f.
		EndIf		

	EndIf

	RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fGrdLinePos
@autor		: Eduardo Alberti
@descricao	: Funcao Para Validação Da Linha Do Grid Apos Digitacao
@since		: Oct./2014
@using		: Cadastro Rotinas X Bloqueios TMS
@review	:
/*/
//------------------------------------------------------------------------------------------------
Static Function fGrdLinePos( oModelGrid, nLinha)

	Local aArea		:= GetArea()
	Local lRet   		:= .T.
	Local oModel     	:= oModelGrid:GetModel()
	Local nOperation 	:= oModel:GetOperation()
	Local cRotDDV 	:= ''
	Local cCodBlq 	:= ''
	Local cPropri 	:= ''

	/*
	//-- Validação Da Linha Do Grid Apos Digitacao
	If nOperation == 4

		cRotDDV := oModel:GetValue( 'TMSA019A_CAB', 'DDX_ROTINA')
		cCodBlq := oModel:GetValue( 'TMSA019A_GRD', 'DDV_CODBLQ')
		cPropri := oModel:GetValue( 'TMSA019A_GRD', 'DDV_PROPRI')

		If cPropri == '1' // Registro Do Sistema

			// Se Posicionar Nao Foi Alterado o Código
			DbSelectArea("DDV")
			DbSetOrder(1) //-- DDV_FILIAL+DDV_ROTINA+DDV_CODBLQ
			If !MsSeek(xFilial("DDV") + cRotDDV + cCodBlq )

				Help( ,, 'HELP',, 'STR0012' , 1, 0)	// 'Somente Registros de Usuário Podem Ser Alterados!'
				lRet := .f.

			EndIf
		EndIf
	EndIf
	*/

	RestArea(aArea)

Return lRet
