#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA129.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'DBTREE.CH'

/*/{Protheus.doc} PCPA129
Man. (Manutenção) Processos Produtivos por Estrutura
@author brunno.costa
@since 20/06/2018
@version P12
@return Nil

@type Function
/*/

Static oDbTree
Static oMenu
Static l129Inclui
Static l129Altera
Static l129Exclui
Static l129Similar
Static cOldCargo
Static aCargos2Niv
Static asDbTree
Static aStructBkp	:= {}
Static nNivelTr
Static cFistCargo
Static lM200BMP
Static lA200rvPi
Static lMA200ORD
Static lM200TEXT
Static cMVSELEOPC
Static lPriUpdBtn	:= .F.
Static lPrimeiro	:= .T.
Static lUltimo		:= .F.

Function PCPA129()

	Local aArea 	:= GetArea()
	Local lExecuta	:= .T.
	Local aButtons	:= {{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.T.,STR0001},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil},{.F., Nil}} // STR0001 - Fechar

	Private Inclui	:= .F.
	Private Altera	:= .F.
	Private nIndex := 0

	//Tratamento de variáveis estáticas
	UpdStatics(1)

	//Executa pergunta de parâmetros da rotina
	lExecuta := ReloadPerg(1)

	If lExecuta
		FWExecView(STR0002, 'PCPA129', MODEL_OPERATION_UPDATE, , { || .T. }, , ,aButtons )	//STR0002 - Man. Processos Produtivos por Estrutura
	EndIf

	//Tratamento de variáveis estáticas
	UpdStatics(2)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author brunno.costa
@since 20/06/2018
@version P12
@return oModel, modelo da rotina

@type Function
/*/

Static Function ModelDef()
	Local oModel
	Local oEvent		:= PCPA129EVDEF():New()
	Local cChaveWhile	:= xFilial("SG2")+MV_PAR01

	If Type("Inclui") == "U"
		Private Inclui := .F.
	EndIf

	//Posiciona no PRIMEIRO roteiro deste produto
	PriRotSG2(cChaveWhile)

	oModel		:= FWLoadModel("PCPA124")
	oModel:DeActivate()

	oModel:InstallEvent("PCPA129EVDEF", /*cOwner*/, oEvent)
	oModel:SetDescription(STR0045)	//Consulta Roteiros
	nIndex		:= 0

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author brunno.costa
@since 20/06/2018
@version P12
@return oView, objeto da View

@type Function
/*/

Static Function ViewDef()

	Local oView			:= FWFormView():New()
	Local oModel		:= FWLoadModel("PCPA129")

	oView:CreateVerticalBox("B129_ESQUERDA"	,20)
	oView:CreateVerticalBox("B129_DIREITA"	,80)
	oView:CreateHorizontalBox("B129_CAB"	,105,"B129_DIREITA",.T.)	//105 Pixels
	oView:CreateHorizontalBox("BPCPA124_H"	,100,"B129_DIREITA")
	oView:CreateVerticalBox("BPCPA124_V"	,100,"BPCPA124_H")

	oView:SetModel(oModel)

	//Cria View da Tree
	oView:AddOtherObject("V_TREE", {|oPanel| MontaTree(oPanel, oModel)})
	oView:SetOwnerView("V_TREE" ,"B129_ESQUERDA")
	oView:EnableTitleView("V_TREE",STR0044)		//Estrutura do Produto

	//Chamada da ViewDef da PCPA124 para criação no oView atual
	//e adicionar todo o seu conteúdo dentro do Box B_CONTEUDO
	oView		:= PCPA124View( 'PCPA129', oView,'BPCPA124_V')
	oView:SetOwnerView("HEADER_SG2","B129_CAB")
	oView:EnableTitleView("HEADER_SG2",STR0043)	//Manutenção de Processos Produtivos

	//Adiciona botões visíveis
	oView:AddUserButton(STR0005	, "", {|| AcaoMenu(6, oDbTree:GetCargo() ) }, STR0006, , ,.T.)	//STR0005 Anterior - STR0006 Roteiro anterior do produto
	oView:AddUserButton(STR0007	, "", {|| AcaoMenu(7, oDbTree:GetCargo() ) }, STR0008, , ,.T.)	//STR0007 Próximo - STR0008 Próximo roteiro do produto
	oView:AddUserButton(STR0015	, "", {|| AcaoMenu(2, oDbTree:GetCargo() ) }, STR0016, , ,.T.)	//STR0015 Editar - STR0016 Edita o roteiro do produto selecionado
	oView:AddUserButton(STR0011	, "", {|| AcaoMenu(1, oDbTree:GetCargo() ) }, STR0012, , ,.T.)	//STR0011 Novo - STR0012 Incluir novo roteiro para este produto
	oView:AddUserButton(STR0050	, "", {|| AcaoMenu(9, oDbTree:GetCargo() ) }, STR0014, , ,.T.)	//STR0050 Salvar - STR0014 Salve a transação em andamento sem sair da tela (Inclusão, Edição ou Roteiro Similar)
	oView:AddUserButton(STR0051	, "", {|| AcaoMenu(8, oDbTree:GetCargo() ) }, STR0022, , ,.T.)	//STR0051 Cancelar - STR0022 Cancelar a transação pendente (Inclusão, Edição ou Roteiro similar) sem sair da tela

	//Adiciona botões Outras Ações
	oView:AddUserButton(STR0019 , "", {|| AcaoMenu(10,oDbTree:GetCargo() ) }, STR0020, , ,.F.)	//STR0019 Roteiro Similar - STR0020 Cria um novo roteiro com base no roteiro atual
	oView:AddUserButton(STR0017	, "", {|| AcaoMenu(3, oDbTree:GetCargo() ) }, STR0018, , ,.F.)	//STR0017 Excluir - STR0018 Exclui o roteiro do produto selecionado
	oView:AddUserButton(STR0023 , "", {|| ReloadPerg(2) }					, STR0026, , ,.F.)	//STR0023 Parâmetros - STR0024 Troca parâmetros da rotina
	oView:AddUserButton(STR0003	, "", {|| AcaoMenu(4, oDbTree:GetCargo() ) }, STR0004, , ,.F.)	//STR0003 Primeiro - STR0004 Primeiro roteiro do produto
	oView:AddUserButton(STR0009	, "", {|| AcaoMenu(5, oDbTree:GetCargo() ) }, STR0010, , ,.F.)	//STR0009 Último - STR0010 Último roteiro do produto

	oView:SetAfterViewActivate({|oView| ViewActiv(oView, oModel)})

	oView:showUpdateMsg(.F.)
	oView:showInsertMsg(.F.)

	//Limitação técnica, abertura de botões desativados
	oView:SetTimer(0.01, {|| RefreshBtn(oView, oModel) })

Return oView

/*/{Protheus.doc} ViewActiv
Função executada logo após ativar a View para preparar os componentes da tela
conforme posicionamento na SG2
@author brunno.costa
@since 21/06/2018
@version P12
@return Nil
@param oView, object, objeto da view
@param oModel, object, objeto do modelo
@type Function
/*/
Static Function ViewActiv(oView, oModel)

	//Marca todos os objetos como não editáveis na abertura de tela
	ReloadView(oModel, oView, SG2->G2_CODIGO, .T.)
Return

/*/{Protheus.doc} MontaTree
Inicia a criação da Tree de Estrutura com base na SG1
@author brunno.costa
@since 22/06/2018
@version P12
@return Nil
@param oView, object, objeto da view
@param oModel, object, objeto do modelo
@type Function
/*/
Static Function MontaTree(oPanel, oModel)

	Local aAreaSG1		:= SG1->(GetArea())
	Local cProduto		:= Iif(!SG1->(Eof()), SG1->G1_COD, MV_PAR01)
	Local cRevisao		:= MV_PAR02
	Local cCargo		:= ""

	If !SG1->(Eof())
		cProduto	:= SG1->G1_COD
		cCargo		:= SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(1, 9) + 'CODI'
	Else
		cProduto	:= MV_PAR01
		cCargo		:= cProduto + PadR("", GetSx3Cache("G1_TRT","X3_TAMANHO")) + PadR("", GetSx3Cache("G1_COMP","X3_TAMANHO")) + StrZero(0, 9) + StrZero(1, 9) + 'CODI'
	EndIf

	oDbTree				:= DbTree():New(0,0,100,100, oPanel,,,.T.)
	oDbTree:Align		:= CONTROL_ALIGN_ALLCLIENT
	oDbTree:bGotFocus	:= {|o,x,y| cOldCargo := oDbTree:GetCargo() }	// Posicao x,y em relacao a Dialog
	oDbTree:bChange		:= {|o,x,y| AcaoTreeCh() }				// Posicao x,y em relacao a Dialog

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da arvore de perguntas e respostas.             ³
	//³Ao clicar com o botao direito sera exibido o menu popup.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDbTree:bRClicked := {|o,x,y| oDbTree:Refresh(), (MostraMenu(oMenu, x, y)) } // Posicao x,y em relacao a Dialog
	oDbTree:cToolTip  := STR0025	//STR0025 Utilize o botao direito do mouse ou as opções de Outras Ações

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do Menu PopUp com as opcoes para a criacao da arvore ³
	//³de perguntas e respostas.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MENU oMenu POPUP  OF OMainWND

	MENUITEM STR0026	ACTION AcaoMenu(1, oDbTree:GetCargo() ) //STR0026 Novo Roteiro
	MENUITEM STR0027	ACTION AcaoMenu(2, oDbTree:GetCargo() ) //STR0027 Editar Roteiro
	MENUITEM STR0028	ACTION AcaoMenu(3, oDbTree:GetCargo() )	//STR0028 Excluir Roteiro
	MENUITEM STR0019	ACTION AcaoMenu(10,oDbTree:GetCargo() )	//STR0019 Roteiro Similar
	MENUITEM STR0013	ACTION AcaoMenu(9, oDbTree:GetCargo() )	//STR0013 Salvar
	MENUITEM STR0021	ACTION AcaoMenu(8, oDbTree:GetCargo() )	//STR0021 Cancelar Transação Pendente

	ENDMENU

	TreeRecurs(oPanel, cProduto, cRevisao, cCargo, SG1->G1_TRT, .T.)

	RestArea(aAreaSG1)
Return

/*/{Protheus.doc} MostraMenu
Exibe menu da Tree (botão direito)
@author brunno.costa
@since 21/06/2018
@version P12
@return Nil
@param oMenu, object, objeto oMenu
@param nCoorX, numeric, coordenada X
@param nCoorY, numeric, coordenada Y - com BUG
@param oArea, object, objeto oDbTree passado por referência
@type Function
/*/

Static Function MostraMenu( oMenu, nCoorX, nCoorY, oArea)

	oMenu:Activate( nCoorX, nCoorY)

Return Nil

/*/{Protheus.doc} AcaoMenu
Execução das ações do Menu
@author brunno.costa
@since 21/06/2018
@version P12
@return Nil
@param nOpc, numeric, ações:
1 - Novo Roteiro
2 - Editar Roteiro
3 - Excluir Roteiro
4 - Primeiro
5 - Último
6 - Anterior
7 - Próximo
8 - Cancelar Transação Pendente
9 - Confirmar
10 - Roteiro Similar
@param cCargo, characters, cCargo do item selecionado
@param cRoteiro, characters, roteiro posicionado relacionado a operação
@type Function
/*/
Static Function AcaoMenu(nOpc, cCargo, cRoteiro)

	Local oModel		:= FwModelActive()
	Local oCab124		:= oModel:GetModel("PCPA124_CAB")
	Local oView			:= FwViewActive()
	Local cProduto		:= RetPrdCarg(cCargo)
	Local cChaveWhile	:= xFilial("SG2")+cProduto
	Local aError
	Local cOldRoteiro	:= oCab124:GetValue("G2_CODIGO")
	Local lExibHelp		:= .F.
	Local aAreaSG2
	Local lReturn       := .T.

	Default lDestravad := .F.

	Default cRoteiro	:= cOldRoteiro

	Altera := l129Altera

	If nOpc == 1 //Novo Roteiro
		If !(l129Inclui .OR. l129Altera .OR. l129Similar)
			l129Inclui	:= .T.
			oModel:DeActivate()
			oView:oControlBar:cTitle	:= STR0046 + " - " + STR0002	//Inclusão de Roteiro - Man. Processos Produtivos por Estrutura
			oModel:setOperation(MODEL_OPERATION_INSERT)
			oView:setOperation(3)
			UpdAllMods(oView, oModel,.T.,.T.,.T.,cRoteiro)
			oModel:Activate()
			oCab124:LoadValue("G2_PRODUTO",cProduto)
			oCab124:LoadValue("CDESCPROD",Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))

			//Posiciona no último roteiro deste produto para identificar qual próximo código
			UltiRotSG2(cChaveWhile, cRoteiro)
			oCab124:LoadValue("G2_CODIGO",Soma1(SG2->G2_CODIGO))

		Else
			lExibHelp	:= .T.
		EndIf

	ElseIf nOpc == 2//Editar
		If !(l129Inclui .OR. l129Altera .OR. l129Similar) .AND. !Empty(cOldRoteiro)
			If SG2->(G2_PRODUTO+G2_CODIGO) != (cProduto+cOldRoteiro)
				SG2->(DbSetOrder(1))
				SG2->(DbSeek(xFilial("SG2")+cProduto+cOldRoteiro))
			EndIf

			aAreaSG2	:= SG2->(GetArea())
			l129Altera	:= .T.
			oModel:DeActivate()
			oView:oControlBar:cTitle	:= STR0047 + " - " + STR0002	//Alteração de Roteiro - Man. Processos Produtivos por Estrutura
			oModel:setOperation(MODEL_OPERATION_UPDATE)
			oView:setOperation(4)
			UpdAllMods(oView, oModel,.T.,.T.,.T.,cRoteiro)
			RestArea(aAreaSG2)
			oModel:Activate()

			//Força edição do modelo principal para garantir dialog ao clicar em Fechar
			oCab124:LoadValue("G2_CODIGO",oCab124:GetValue("G2_CODIGO"))

			//Chama Método AfterViewActivate da PCPA124
			StaticCall(PCPA124,a124AftAct,oView)

			//Força Refresh da grid superior para habilitar edição da Grid inferior
			IF !lDestravad
				oModel:GetModel("PCPA124_SG2"):ADDLINE()
				oView:Refresh()

				lDestravad := .T.
				AcaoMenu(8, cCargo, cRoteiro) //Cancelar Transação Pendente
				AcaoMenu(2, cCargo, cRoteiro) //Editar
			ENDIF

		Else
			lExibHelp	:= .T.
		EndIf
	ElseIf nOpc == 3//Excluir Roteiro
		If !(l129Inclui .OR. l129Altera .OR. l129Similar) .AND. !Empty(cOldRoteiro)
			If ApMsgYesNo(STR0029,STR0030)	// STR0029 Você tem certeza que deseja excluir o roteiro deste produto? - STR0030 Deseja excluir o roteiro?
				l129Exclui	:= .T.
				oModel:DeActivate()
				oView:oControlBar:cTitle	:= STR0045 + " - " + STR0002	//Consulta Roteiros - Man. Processos Produtivos por Estrutura
				oModel:setOperation(MODEL_OPERATION_DELETE)
				oView:setOperation(5)
				UpdAllMods(oView, oModel,.F.,.F.,.F.,cRoteiro)
				oModel:Activate()
				If FWFormCanDel(oModel) .AND. oModel:VldData(,.T.)
					FWFormCommit(oModel)

					//Posiciona no Próximo Roteiro da SG2
					ProxRotSG2(cChaveWhile, cRoteiro)

					If SG2->(Eof())
						//Posiciona no Roteiro Anterior da SG2
						AntRotSG2(cChaveWhile, cRoteiro)
					EndIf

				Else
					Help( Nil, Nil, STR0052, Nil,STR0053, 1, 0)
				EndIf

				//Reload View com base nos registros posicionados e parâmetros recebidos
				ReloadView(oModel, oView, SG2->G2_CODIGO)
			EndIf
		Else
			lExibHelp	:= .T.
		EndIf

	ElseIf nOpc == 4//Primeiro
		If !(l129Inclui .OR. l129Altera .OR. l129Similar)

			DbSelectArea("SG2")
			SG2->(DbSetOrder(1))
			If SG2->(DbSeek(xFilial("SG2")+cProduto))
				cRoteiro	:= SG2->G2_CODIGO
			EndIf

			//Reload View com base nos registros posicionados e parâmetros recebidos
			ReloadView(oModel, oView, cRoteiro)

			If !Empty(cOldRoteiro) .AND. !Empty(oCab124:GetValue("G2_CODIGO")) .AND. oCab124:GetValue("G2_CODIGO") == cOldRoteiro
				ApMsgInfo(STR0042,STR0041) //STR0041 Não existem mais roteiros neste sentido! - STR0042 ALERTA !!!
			Else
				cOldRoteiro	:= oCab124:GetValue("G2_CODIGO")
			EndIf
		Else
			lExibHelp	:= .T.
		EndIf

	ElseIf nOpc == 5//Último
		If !(l129Inclui .OR. l129Altera .OR. l129Similar)
			cRoteiro	:= If(Empty(cRoteiro),"",cRoteiro)

			//Posiciona no último roteiro deste produto
			UltiRotSG2(cChaveWhile, cRoteiro)

			//Reload View com base nos registros posicionados e parâmetros recebidos
			ReloadView(oModel, oView, SG2->G2_CODIGO)

			If !Empty(cOldRoteiro) .AND. !Empty(oCab124:GetValue("G2_CODIGO")) .AND. oCab124:GetValue("G2_CODIGO") == cOldRoteiro
				ApMsgInfo(STR0042,STR0041) //STR0041 Não existem mais roteiros neste sentido! - STR0042 ALERTA !!!
			Else
				cOldRoteiro	:= oCab124:GetValue("G2_CODIGO")
			EndIf
		Else
			lExibHelp	:= .T.
		EndIf

	ElseIf nOpc == 6//Anterior
		If !(l129Inclui .OR. l129Altera .OR. l129Similar)
			//Posiciona no Roteiro Anterior da SG2
			AntRotSG2(cChaveWhile, cRoteiro)

			//Reload View com base nos registros posicionados e parâmetros recebidos
			ReloadView(oModel, oView, SG2->G2_CODIGO)

			If oCab124:GetValue("G2_CODIGO") == cOldRoteiro
				ApMsgInfo(STR0042,STR0041) //STR0041 Não existem mais roteiros neste sentido! - STR0042 ALERTA !!!
			Else
				cOldRoteiro	:= oCab124:GetValue("G2_CODIGO")
			EndIf
		Else
			lExibHelp	:= .T.
		EndIf

	ElseIf nOpc == 7//Próximo
		If !(l129Inclui .OR. l129Altera .OR. l129Similar)
			//Posiciona no Próximo Roteiro da SG2
			ProxRotSG2(cChaveWhile, cRoteiro)

			//Reload View com base nos registros posicionados e parâmetros recebidos
			ReloadView(oModel, oView, SG2->G2_CODIGO)

			If oCab124:GetValue("G2_CODIGO") == cOldRoteiro
				ApMsgInfo(STR0042,STR0041) //STR0041 Não existem mais roteiros neste sentido! - STR0042 ALERTA !!!
			Else
				cOldRoteiro	:= oCab124:GetValue("G2_CODIGO")
			EndIf
		Else
			lExibHelp	:= .T.
		EndIf

	ElseIf nOpc == 8//Cancelar Transação Pendente
		If l129Inclui .OR. l129Similar
			//Reload View com base nos registros posicionados e parâmetros recebidos
			ReloadView(oModel, oView, cRoteiro)

			//Refaz Ação de Clique
			AcaoTreeCh()
		ElseIf l129Altera
			//Reposiciona no registro atual
			PriRotSG2(xFilial("SG2")+cProduto+cRoteiro)

			//Reload View com base nos registros posicionados e parâmetros recebidos
			ReloadView(oModel, oView, cRoteiro)
		EndIf

	ElseIf nOpc == 9//Confirmar Edição/Novo
		If l129Inclui .OR. l129Altera .OR. l129Similar
			//Valida o modelo
			If oModel:VldData()
				FWFormCommit(oModel)

				SG2->(DbSetOrder(1))
				SG2->(DbSeek(xFilial("SG2")+cProduto+cOldRoteiro))

				//Reload View com base nos registros posicionados e parâmetros recebidos
				ReloadView(oModel, oView, cOldRoteiro)
			Else
				aError	:= oModel:GetErrorMessage()
				Help( Nil, Nil, aError[5], Nil, aError[6], 1, 0, Nil, Nil, Nil, Nil, Nil, {aError[7]})
				oModel:GetErrorMessage(.T.)
				lReturn := .F.
			EndIf
		EndIf

	ElseIf nOpc == 10//Roteiro Similar
		If !(l129Inclui .OR. l129Altera .OR. l129Similar) .AND. !Empty(cOldRoteiro)
			l129Similar	:= .T.
			aAreaSG2	:= SG2->(GetArea())
			oModel:DeActivate()
			oView:oControlBar:cTitle	:= STR0019 + " - " + STR0002	//Roteiro Similar - Man. Processos Produtivos por Estrutura
			oView:setOperation(3)
			UpdAllMods(oView, oModel,.T.,.T.,.T.,cRoteiro)
			oModel		:= PCPA124RSM(oModel,.T.)

			//Posiciona no último roteiro deste produto para identificar qual próximo código
			UltiRotSG2(cChaveWhile, Nil)
			oCab124:LoadValue("G2_CODIGO",Soma1(SG2->G2_CODIGO))

			RestArea(aAreaSG2)

			oCab124:LoadValue("G2_PRODUTO",cProduto)
			oCab124:LoadValue("CDESCPROD",Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))
		Else
			lExibHelp	:= .T.
		EndIf
	EndIf

	If lReturn
		oView:Refresh()
	EndIf

	If lExibHelp
		If l129Inclui
			Help( Nil, Nil, STR0034, Nil, STR0035, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})	//STR0034 Inclusão em andamento! - STR0035 Operação de INCLUSÃO em andamento. - STR0036 Clique em 'Outras Ações + Salvar sem Sair' ou 'Outras Ações + Cancelar Transação Pendente' para prosseguir.
		ElseIf l129Altera
			Help( Nil, Nil, STR0037, Nil, STR0038, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})	//STR0037 Edição em andamento! - STR0038 Operação de EDIÇÃO em andamento. - STR0036 Clique em 'Outras Ações + Salvar sem Sair' ou 'Outras Ações + Cancelar Transação Pendente' para prosseguir."
		ElseIf l129Similar
			Help( Nil, Nil, STR0039, Nil, STR0040, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})	//STR0039 Roteiro Similar em andamento! - STR0040 Operação de ROTEIRO SIMILAR em andamento. - STR0036 Clique em 'Outras Ações + Salvar sem Sair' ou 'Outras Ações + Cancelar Transação Pendente' para prosseguir."
		EndIf
	EndIf

Return lReturn

/*/{Protheus.doc} UpdAllMods
Bloqueio/Liberação de objetos da tela
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param oView, object, View da rotina
@param oModel, object, Modelo da rotina
@param lInsert, logical, Indica se permite operação de inserção em Grid's
@param lUpdate, logical, Indica se permite operação de Update em Grid's e Field's
@param lDelete, logical, indica se permite operação de exclusão em Grid's
@type Function
/*/
Static Function UpdAllMods(oView, oModel, lInsert, lUpdate, lDelete, cRoteiro)

	Local aModels		:= oModel:aAllSubModels
	Local nX			:= 0
	Local oStructAux

	Private oControl
	Private oAux

	DEFAULT cRoteiro := SG2->G2_CODIGO

	For nX := 1 to Len(aModels)
		oAux := aModels[nX]
		If Type("oAux:nDataID") == "U"
	  		oModel:GetModel(aModels[nX]:cID):SetNoInsertLine(!lInsert)
			oModel:GetModel(aModels[nX]:cID):SetNoUpdateLine(!lUpdate)
			oModel:GetModel(aModels[nX]:cID):SetNoDeleteLine(!lDelete)

		ElseIf !("|"+AllTrim(aModels[nX]:cID)+"|" $ "|PCPA124_CAB|PCPA124_SGF_C|")//|PCPA124_SMX
			If !lUpdate
				If aScan(aStructBkp, {|x| x[1] == aModels[nX]:cID}) == 0
					aAdd(aStructBkp, {aModels[nX]:cID, aClone(oModel:GetModel(aModels[nX]:cID):GetStruct():aFields)})
				EndIf
				oModel:GetModel(aModels[nX]:cID):SetOnlyView()
			Else
				oStructAux := oModel:GetModel(aModels[nX]:cID):GetStruct()
				oStructAux:aFields := aClone(aStructBkp[aScan(aStructBkp, {|x| x[1] == aModels[nX]:cID})][2])
				oModel:GetModel(aModels[nX]:cID):Deactivate()
				oModel:GetModel(aModels[nX]:cID):SetStruct(oStructAux)
				oModel:GetModel(aModels[nX]:cID):Activate()
			EndIf

		EndIf
	Next nX

	//Atualiza variáveis de controle do Último e Primeiro roteiro
	UBtnUltPri(xFilial("SG2")+SG2->G2_PRODUTO, cRoteiro)

	If ProcName(1) != "VIEWACTIV"
		nX := Len(oView:oOwner:aControls)
		While nX > 0
			oControl := oView:oOwner:aControls[nX]
			If Type("oControl:cCaption") != "U"
				If Upper(AllTrim(STR0051)) $ Upper(oView:oOwner:aControls[nX]:cCaption)	//CANCELAR
					If !(l129Inclui .OR. l129Altera .OR. l129Similar)
						oView:oOwner:aControls[nX]:Disable()
					Else
						oView:oOwner:aControls[nX]:Enable()
					EndIf
					lPriUpdBtn	:= .T.
				ElseIf Upper(AllTrim(STR0050)) $ Upper(oView:oOwner:aControls[nX]:cCaption)	//SALVAR
					If !(l129Inclui .OR. l129Altera .OR. l129Similar)
						oView:oOwner:aControls[nX]:Disable()
					Else
						oView:oOwner:aControls[nX]:Enable()
					EndIf
					lPriUpdBtn	:= .T.
				ElseIf Upper(AllTrim(STR0011)) $ Upper(oView:oOwner:aControls[nX]:cCaption)	//NOVO
					If l129Inclui .OR. l129Altera .OR. l129Similar
						oView:oOwner:aControls[nX]:Disable()
					Else
						oView:oOwner:aControls[nX]:Enable()
					EndIf
					lPriUpdBtn	:= .T.
				ElseIf Upper(AllTrim(STR0015)) $ Upper(oView:oOwner:aControls[nX]:cCaption)	//EDITAR
					If (l129Inclui .OR. l129Altera .OR. l129Similar .OR. Empty(cRoteiro))
						oView:oOwner:aControls[nX]:Disable()
					Else
						oView:oOwner:aControls[nX]:Enable()
					EndIf
					lPriUpdBtn	:= .T.
				ElseIf Upper(AllTrim(STR0007)) $ Upper(oView:oOwner:aControls[nX]:cCaption)	//PRÓXIMO
					If l129Inclui .OR. l129Altera .OR. l129Similar .OR. lUltimo
						oView:oOwner:aControls[nX]:Disable()
					Else
						oView:oOwner:aControls[nX]:Enable()
					EndIf
					lPriUpdBtn	:= .T.
				ElseIf Upper(AllTrim(STR0005)) $ Upper(oView:oOwner:aControls[nX]:cCaption)	//ANTERIOR
					If l129Inclui .OR. l129Altera .OR. l129Similar .OR. lPrimeiro
						oView:oOwner:aControls[nX]:Disable()
					Else
						oView:oOwner:aControls[nX]:Enable()
					EndIf
					lPriUpdBtn	:= .T.
				EndIf
			EndIf
			nX--
		EndDo
	EndIf

Return

/*/{Protheus.doc} AcaoTreeCh
Execuções de ações durante clique/change na Tree
@author brunno.costa
@since 21/06/2018
@version P12
@return Nil

@type Function
/*/

Static Function AcaoTreeCh()

	Local oModel		:= FwModelActive()
	Local oView			:= FwViewActive()
	Local oCab124		:= oModel:GetModel('PCPA124_CAB')
	Local cCargo		:= oDbTree:GetCargo()
	Local cProduto		:= RetPrdCarg(cCargo)

	If l129Inclui
		oDbTree:TreeSeek( cOldCargo )
		Help( Nil, Nil, STR0034, Nil, STR0035, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})	//STR0034 Inclusão em andamento! - STR0035 Operação de INCLUSÃO em andamento. - STR0036 Clique em 'Outras Ações + SALVAR' ou 'Outras Ações + Cancelar Transação Pendente' para prosseguir.

	ElseIf l129Altera
		oDbTree:TreeSeek( cOldCargo )
		Help( Nil, Nil, STR0037, Nil, STR0038, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})	//STR0037 Edição em andamento! - STR0038 Operação de EDIÇÃO em andamento. - STR0036 Clique em 'Outras Ações + SALVAR' ou 'Outras Ações + Cancelar Transação Pendente' para prosseguir."

	Else

		oDbTree:cToolTip  := STR0025 +  Chr(13) + Chr(10) + "Seleção atual: " + oDbTree:GetPrompt()	//STR0025 Utilize o botao direito do mouse ou as opções de Outras Ações

		//Se estiver em transação de Roteiro Similar
		If l129Similar
			//Posiciona no último roteiro deste produto para identificar qual próximo código
			UltiRotSG2(xFilial("SG2")+cProduto, Nil)
			oCab124:LoadValue("G2_CODIGO",Soma1(SG2->G2_CODIGO))
			oCab124:LoadValue("G2_PRODUTO",cProduto)
			oCab124:LoadValue("CDESCPROD",Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))

		Else
			//Posiciona no primeiro roteiro do produto
			oCab124:LoadValue("G2_CODIGO","")
			AcaoMenu(4, cCargo, "")
			oCab124:LoadValue("G2_CODIGO",SG2->G2_CODIGO)

		EndIf

		//Somente para os PI's não abertos nos próximos dois níveis
		If !Empty(cCargo) .AND. aScan(aCargos2Niv,{|x| x == cCargo } ) == 0
			NextNivel(cCargo, 2)
		EndIf

		oView:Refresh()
	EndIf

Return

/*/{Protheus.doc} RetPrdCarg
Retorna o código do produto relacionado ao cCargo
@author brunno.costa
@since 21/06/2018
@version P12
@return cProduto, caracters, código do produto relacionado ao cCargo
@param cCargo, characters, descricao
@type Function
/*/

Static Function RetPrdCarg(cCargo)
	Local cProduto
	Local cTipo		:= Right(cCargo,4)

	If cTipo == "CODI"
		cProduto 	:= SubStr(cCargo,1, GetSx3Cache("G1_COD","X3_TAMANHO"))
	Else
		cProduto 	:= SubStr(cCargo,GetSx3Cache("G1_COD","X3_TAMANHO") + 4, GetSx3Cache("G1_COMP","X3_TAMANHO"))
	EndIf
Return cProduto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ma200Monta ³ Autor ³Fernando Joly/Eduardo³ Data ³19.05.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem do Arquivo Temporario para o Tree(Func.Recurssiva)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma200Monta(ExpO1,ExpO2,ExpC1,ExpC2,ExpC3,ExpN1,ExpC4,ExpC5)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*/{Protheus.doc} TreeRecurs
Operações recursivas - Montagem da Tree
@author brunno.costa
@since 25/06/2018
@version P12
@return lRet, logic, em desuso
@param oPanel, object, Box onde a Tree será montada
@param cProduto, characters, código do produto Pai da Estrutura
@param cRevisao, characters, Codigo da revisao
@param cCargo, characters, Cargo do Produto no Tree
@param cTRTPai, characters, Sequencia Pai
@param lOpc, logical, avalia opcionais
@type Function
/*/

Static Function TreeRecurs(oPanel, cProduto, cRevisao, cCargo, cTRTPai, lOpc)

	Local cComp		:= ''
	Local cPrompt	:= ''
	Local cFolderA	:= 'FOLDER5'
	Local cFolderB	:= 'FOLDER6'
	Local cRevPI	:= ""
	Local nRecCargo	:= 0
	Local dValIni	:= CtoD('  /  /  ')
	Local dValFim	:= CtoD('  /  /  ')
	Local lRet		:= .T.
	Local nQtdeSG1	:= 0
	Local nIndSG1	:= 1
	Local uRet		:= Nil
	Local lOpcAux	:= .T.
	Local cOpc		:= ""
	Local aOpc		:= {}
	Local cCargoPai	:= ""
	Local cOldCargL
	Local nRecAnt	:= 0
	Local aAreaSG1	:= SG1->(GetArea())

	Default lOpc := .T.

	lM200BMP	:= Iif(lM200BMP		== Nil, ExistBlock("M200BMP")	,lM200BMP)
	lA200rvPi	:= Iif(lA200rvPi	== Nil, ExistBlock("A200RVPI")	,lA200rvPi)
	lMA200ORD	:= Iif(lMA200ORD	== Nil, ExistBlock("MA200ORD")	,lMA200ORD)

	cMVSELEOPC	:= Iif(cMVSELEOPC	== Nil, SuperGetMV("MV_SELEOPC"),cMVSELEOPC)

	// -- Atualiza nivel da estrutura
	nNivelTr += 1

	If lMA200ORD
		nIndSG1 := ExecBlock("MA200ORD",.F.,.F.)
		If ValType(nIndSG1) # "N"
			nIndSG1 := 1
		EndIf
	EndIf

	//-- Posiciona no SB1
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + cProduto, .F.))
		cRevisao := Iif(Empty(cRevisao),SB1->B1_REVATU,cRevisao)
		If Empty(cRevisao)
			cPrompt := AllTrim(cProduto)
		Else
			cPrompt := AllTrim(cProduto) + " - " + STR0048 + ": " + cRevisao  //"Rev."
		EndIf
	EndIf

	//-- Define as Pastas a serem usadas
	cFolderA := 'FOLDER5'
	cFolderB := 'FOLDER6'

	SG1->(dbSetOrder(nIndSG1))
	If !SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))
		oDbTree:Refresh()
		oDbTree:SetFocus()
		lRet := .F.

		//Se for a primeira chamada e não possui estrutura, apenas exibe o produto pai na Tree
		If nIndex == 0
			cPrompt	:= AllTrim(cProduto) + " - " + STR0049	//SEM ESTRUTURA
			oDbTree:AddTree(cPrompt, .T., cFolderA, cFolderB, , , cCargo)
			oDbTree:EndTree()
		EndIf

	Else //If lRet
		cTRTPai := If(cTRTPai == Nil,SG1->G1_TRT,cTRTPai)

		dValIni := SG1->G1_INI
		dValFim := SG1->G1_FIM
		If cCargo == Nil
			cCargo := SG1->G1_COD + cTRTPai + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'CODI'
		ElseIf (nRecCargo := Val(SubStr(cCargo,Len(SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP) + 1, 9))) > 0
			nRecAnt := SG1->(Recno())
			SG1->(dbGoto(nRecCargo))
			dValIni := SG1->G1_INI
			dValFim := SG1->G1_FIM
			nQtdeSG1 := SG1->G1_QUANT
			If cMVSELEOPC == "S" .And. lOpc
				cOpc := Padr(SG1->G1_GROPC, GetSx3Cache("G1_GROPC","X3_TAMANHO")) + Padr(SG1->G1_OPC, GetSx3Cache("G1_OPC","X3_TAMANHO")) + "/"
				aOpc := aClone(ListOpc( Nil, Nil, cOpc))
			EndIf
			SG1->(dbGoto(nRecAnt))
		EndIf

		//-- Define as Pastas a serem usadas
		If Right(cCargo, 4) == 'COMP' .And. ;
		(dDataBase < dValIni .Or. dDataBase > dValFim)
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		If lM200BMP
			uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
			If ValType(uRet) == "A"
				cFolderA := uRet[1]
				cFolderB := uRet[2]
			EndIf
		EndIf

		//-- Adiciona o Pai na Estrutura
		cCargoPai	:= cCargo

		//Adiciona cCargo no array que controla a recarga da Tree
		aAdd(aCargos2Niv,cCargo)
		cPrompt	:= PromptTree(cPrompt, cCargo, nQtdeSG1,,aOpc)
		oDbTree:AddTree(cPrompt, .T., cFolderA, cFolderB, , , cCargo)
		cOldCargL	:= oDbTree:GetCargo()

		Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto
			nRecAnt  	:= SG1->(Recno())

			//-- Nao Adiciona Componentes fora da Revis„o
			If (cRevisao # Nil) .And. !(SG1->G1_REVINI <= cRevisao ;
			.And. (SG1->G1_REVFIM >= cRevisao .Or. SG1->G1_REVFIM = ' '))
				SG1->(dbSkip())
				Loop
			EndIf

			cComp    := SG1->G1_COMP
			cCargo   := SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(nIndex ++, 9) + 'COMP'
			nQtdeSG1 := SG1->G1_QUANT

			If Empty(SG1->G1_GROPC)
				lOpcAux := .F.
			Else
				lOpcAux := .T.
			EndIf

			If cMVSELEOPC == "S"
				cOpc := Padr(SG1->G1_GROPC, GetSx3Cache("G1_GROPC","X3_TAMANHO")) + Padr(SG1->G1_OPC, GetSx3Cache("G1_OPC","X3_TAMANHO")) + "/"
				aOpc := aClone(ListOpc( Nil, Nil, cOpc))
			EndIf

			If cFistCargo == Nil
				cFistCargo := cCargo
			EndIf

			//-- Define as Pastas a serem usadas
			cFolderA := 'FOLDER5'
			cFolderB := 'FOLDER6'
			If dDataBase < SG1->G1_INI .Or. dDataBase > SG1->G1_FIM
				cFolderA := 'FOLDER7'
				cFolderB := 'FOLDER8'
			EndIf

			//-- Posiciona no SB1
			cPrompt := cComp
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial('SB1') + cComp, .F.))
				cPrompt := AllTrim(cComp)
			EndIf

			If SG1->(dbSeek(xFilial('SG1') + SG1->G1_COMP, .F.))
				cRevPI := IIf(SB1->B1_REVATU = ' ','001',SB1->B1_REVATU)

				If lA200rvPi
					cRevPI := Execblock ("A200RVPI",.F.,.F.,{cProduto, cRevisao, SG1->G1_COD, cRevPI})
				EndIf

				If lM200BMP
					uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
					If ValType(uRet) == "A"
						cFolderA := uRet[1]
						cFolderB := uRet[2]
					EndIf
				EndIf
				aAdd(asDbTree,{cCargo, oDbTree:GetCargo()})
				cPrompt	:= PromptTree(cPrompt, cCargo, nQtdeSG1,,aOpc)
				oDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderB,,, 2)
				oDbTree:TreeSeek(cCargo)
				NextNivel(cCargo, 1)
				oDbTree:PTCollapse()
			Else
				aAdd(asDbTree,{cCargo, oDbTree:GetCargo()})
				cPrompt		:= PromptTree(cPrompt, cCargo, nQtdeSG1,,aOpc)
				oDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderB,,, 2)
			EndIf

			oDbTree:TreeSeek(cOldCargL)
			SG1->(dbGoto(nRecAnt))
			SG1->(dbSkip())
		EndDo
		oDbTree:EndTree()

		// --- Atualiza obj.dbtree apos processar a estrutura
		If nNivelTr == 1
			If( cCargoPai <> Nil )
				cCargo := cCargoPai
				cCargoPai := Nil
			EndIf
			oDbTree:TreeSeek(cCargo)
			oDbTree:Refresh()
			oDbTree:SetFocus()
		EndIf
	EndIf

	RestArea(aAreaSG1)

	// --- Atualiza nivel da estrutura
	nNivelTr -= 1

Return lRet

/*/{Protheus.doc} PromptTree
Gera o texto Prompt de exibição do item na Tree
@author brunno.costa
@since 21/06/2018
@version P12
@return cPrompt, chacacters, texto Prompt do item na Tree
@param cPrompt, characters, texto referência
@param cCargo, characters, cCargo do item
@param nQtdeSG1, numeric, quantidade do item na SG1
@param cProdAtu, characters, Produto relacionado ao item
@param aOpc, array, array de controle dos opcionais
@type Function
/*/
Static Function PromptTree(cPrompt, cCargo, nQtdeSG1, cProdAtu, aOpc)

	Local cTRT       := Space(Len(SG1->G1_TRT)+3)
	Local aTamQtde   := TamSX3("G1_QUANT")
	Local nTamCod    := GetSx3Cache("G1_COD","X3_TAMANHO")
	Local nTamTRT    := GetSx3Cache("G1_TRT","X3_TAMANHO")
	Local cQuant     := ""
	Local cRet       := ""
	Local cM200TEXT  := ""
	Local cOpc       := ""

	Default cProdAtu := ""
	Default nQtdeSG1 := 0
	Default aOpc     := { }

	lM200TEXT	:= Iif(lM200TEXT	== Nil, ExistBlock("M200TEXT")	,lM200TEXT)
	cMVSELEOPC	:= Iif(cMVSELEOPC	== Nil, SuperGetMV("MV_SELEOPC"),cMVSELEOPC)

	If ! (cCargo == Nil .Or. Empty(cCargo) .Or. Right(cCargo, 4) $ "CODI")
		If ! Empty(cTRT := SubStr(cCargo, nTamCod+1, nTamTRT))
			cTRT := " - " + cTRT
		EndIf
		cQuant   := " / "+STR0031+Str(nQtdeSG1,aTamQtde[1],aTamQtde[2])	//"QTDE: "
		If lM200TEXT
			cProdAtu := AllTrim(SubStr(cCargo, nTamCod+1+nTamTRT, nTamCod))
		EndIf
	EndIf

	If lM200TEXT .And. Empty(cProdAtu) .And. !(Empty(cCargo)) .And. Right(cCargo, 4) $ "CODI"
		cProdAtu := AllTrim(SubStr(cCargo, 1, nTamCod))
	EndIf

	If cMVSELEOPC == "S" .And. Len(aOpc) > 0
		cOpc := " / " + STR0032 + AllTrim(aOpc[1][3]) + " - " + AllTrim(aOpc[1][4]) + " / " + STR0033 + AllTrim(aOpc[1][5]) + " - " + AllTrim(aOpc[1][6])	//"OPC: " - "Item: "
	EndIf

	//cRet := Pad(AllTrim(cPrompt) + cTRT + cQuant + cOpc, nTamCod+nTamTRT+aTamQtde[1]+aTamQtde[2]+cOpc+60)
	cRet := Pad(AllTrim(AllTrim(cPrompt) + cTRT + cOpc), nTamCod+nTamTRT+50)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para manipular o texto a ser apresentado na estrutura ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lM200TEXT
		cM200TEXT := ExecBlock("M200TEXT", .F., .F., {cRet,;                                // Texto original
		AllTrim(Substr(cCargo, 1, nTamCod)),; // Codigo do item PAI
		SubStr(cCargo, nTamCod+1, nTamTRT),;  // TRT
		cProdAtu,;    // Codigo do componente/item inserido na estrutura
		nQtdeSG1})                            // Qtde. do item na estrutura
		If ValType(cM200TEXT) == "C"
			cRet := cM200TEXT
		EndIf
	EndIf

Return cRet

/*/{Protheus.doc} NextNivel
Processamento do próximo nível da estrutura
@author brunno.costa
@since 21/06/2018
@version P12
@return Nil
@param cCargo, characters, cCargo do item
@param nProximo, numeric, descricao
@type Function
/*/

Static Function NextNivel(cCargo, nProximo)
	Local cProduto 	:= Substr( cCargo, Len(SG1->G1_COD+SG1->G1_TRT) + 1, Len(SG1->G1_COMP))
	Local cOldCargL	:= oDbTree:GetCargo()
	Local aAreaSG1	:= SG1->(GetArea())
	Local nRecSG1	:= 0

	Default nProximo := 0

	If nProximo == 2
		//Adiciona cCargo no array que controla a recarga da Tree
		aAdd(aCargos2Niv,cCargo)
	EndIf

	nProximo--

	If Right(cCargo, 4) == 'COMP'
		SG1->(dbSetOrder(1))
		If SG1->(dbSeek(xFilial('SG1') + cProduto, .F.))

			Do While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto
				nRecSG1	:= SG1->(Recno())
				If ProcNxtNiv(cCargo, nProximo)
					SG1->(dbSkip())
					Loop
				EndIf
				SG1->(DbGoTo(nRecSG1))
				SG1->(dbSkip())
			EndDo

		EndIf

	EndIf

	oDbTree:TreeSeek(cOldCargL)
	RestArea(aAreaSG1)

Return

/*/{Protheus.doc} ProcNxtNiv
Processamento do Next Nivel - Loop
@author brunno.costa
@since 21/06/2018
@version P12
@return lLoop, logical, indica se deve dar loop no registro atual para não incluir na tree
@param cCargo, characters, cCargo do item
@param nProximo, numeric, controla os próximos níveis que serão processados
@type Function
/*/

Static Function ProcNxtNiv(cCargoPai, nProximo)

	Local cTRTPai  := ""
	Local cPrompt  := ""
	Local dValIni  := CtoD('  /  /  ')
	Local dValFim  := CtoD('  /  /  ')
	Local cFolderA
	Local cFolderB
	Local uRet     := Nil
	Local aOpc     := {}
	Local cOpc     := ""
	Local cOldCargL:= oDbTree:GetCargo()
	Local lLoop := .F.
	Local aAreaSG1 := SG1->(GetArea())
	Local cCargo
	Local naScan	:= 0

	lM200BMP	:= Iif(lM200BMP	 == Nil, ExistBlock("M200BMP")		,lM200BMP)
	cMVSELEOPC	:= Iif(cMVSELEOPC	== Nil, SuperGetMV("MV_SELEOPC"),cMVSELEOPC)

	//-- Posiciona no SB1 para descrição
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial('SB1') + SG1->G1_COMP, .F.))
		cPrompt := AllTrim(SG1->G1_COMP)// + " - " + SB1->B1_DESC + Space(Len(SB1->B1_COD) - Len(AllTrim(SG1->G1_COMP)))
	EndIf

	//-- Posiciona no SB1 para revisão
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial('SB1') + SG1->G1_COD, .F.))
	cRevisao := IIf (!(EOF()),IIF(SB1->B1_REVATU == '' .or. Empty(SB1->B1_REVATU),'001',SB1->B1_REVATU),'001')

	//-- Nao Adiciona Componentes fora da Revisao
	If (cRevisao # Nil) .And. !(SG1->G1_REVINI <= cRevisao .And. SG1->G1_REVFIM >= cRevisao)
		lLoop := .T.
		Return lLoop
	EndIf

	cTRTPai  := If(cTRTPai == Nil,SG1->G1_TRT,cTRTPai)
	dValIni  := SG1->G1_INI
	dValFim  := SG1->G1_FIM
	nQtdeSG1 := SG1->G1_QUANT

	//-- Define as Pastas a serem usadas
	cFolderA := 'FOLDER5'
	cFolderB := 'FOLDER6'
	If Right(cCargoPai, 4) == 'COMP' .And. ;
	(dDataBase < dValIni .Or. dDataBase > dValFim)
		cFolderA := 'FOLDER7'
		cFolderB := 'FOLDER8'
	EndIf

	If cMVSELEOPC == "S"
		cOpc := Padr(SG1->G1_GROPC, GetSx3Cache("G1_GROPC","X3_TAMANHO")) + ;
		Padr(SG1->G1_OPC, GetSx3Cache("G1_OPC","X3_TAMANHO")) + "/"
		aOpc := aClone(ListOpc( Nil, Nil, cOpc))
	EndIf

	If lM200BMP
		uRet := Execblock("M200BMP", .F., .F., {cPrompt, cFolderA, cFolderB})
		If ValType(uRet) == "A"
			cFolderA := uRet[1]
			cFolderB := uRet[2]
		EndIf
	EndIf

	cCargo	:= SG1->G1_COD
	cCargo	+= SG1->G1_TRT
	cCargo	+= SG1->G1_COMP
	cCargo	+= StrZero(SG1->(Recno()), 9)
	cCargo	+= StrZero(nIndex++, 9)  + 'COMP'

	//Verifica se já adicionou o item na Tree
	naScan	:= aScan(asDbTree,{|x| x[2] == cCargoPai .and.  Left(x[1],Len(cCargo)-13) == Left(cCargo,Len(cCargo)-13) } )
	If naScan > 0
		nIndex--
		cCargo	:= asDbTree[naScan][1]
	EndIf

	//Se não encontra o Cargo na Tree, adiciona
	If !oDbTree:TreeSeek(cCargo)
		aAdd(asDbTree,{cCargo, oDbTree:GetCargo()})
		cPrompt	:= PromptTree(cPrompt, cCargo, nQtdeSG1,,aOpc)
		oDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderB,,, 2)
	EndIf

	//Se necessário, processa o próximo nível
	If nProximo > 0
		oDbTree:TreeSeek(cCargo)
		NextNivel(cCargo, nProximo)
		oDbTree:PTCollapse()
	EndIf

	RestArea(aAreaSG1)
	oDbTree:TreeSeek(cOldCargL)

Return lLoop

/*/{Protheus.doc} UBtnUltPri
Atualiza status de variáveis que controlam os botões último e primeiro
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param cChaveWhile, characters, chave de pesquisa filial + produto
@type Function
/*/

Static Function UBtnUltPri(cChaveWhile, cRoteiro)
	lPrimeiro	:= Empty(cRoteiro) .OR. AvPrimeiro(cChaveWhile)
	lUltimo		:= Empty(cRoteiro) .OR. AvUltimo(cChaveWhile)
Return

/*/{Protheus.doc} AvPrimeiro
Avalia se o registro atual é o primeiro
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param cChaveWhile, characters, chave de pesquisa filial + produto
@type Function
/*/

Static Function AvPrimeiro(cChaveWhile)

	Local lRet			:= .F.
	local nRecAtual		:= SG2->(Recno())
	local cRoteiro		:= SG2->G2_CODIGO

	PriRotSG2(cChaveWhile)
	lRet := cRoteiro == SG2->G2_CODIGO

	If !lRet .or. SG2->(Eof())
		SG2->(DbGoTo(nRecAtual))
	EndIf

Return lRet

/*/{Protheus.doc} AvPrimeiro
Avalia se o registro atual é o último
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param cChaveWhile, characters, chave de pesquisa filial + produto
@type Function
/*/

Static Function AvUltimo(cChaveWhile)

	Local lRet			:= .F.
	local nRecAtual		:= SG2->(Recno())
	local cRoteiro		:= SG2->G2_CODIGO

	ProxRotSG2(cChaveWhile, cRoteiro)
	lRet := cChaveWhile != SG2->(G2_FILIAL+G2_PRODUTO) .OR. SG2->(Eof())

	If !lRet .or. SG2->(Eof())
		SG2->(DbGoTo(nRecAtual))
	EndIf

Return lRet

/*/{Protheus.doc} PriRotSG2
Posiciona a SG2 no primeiro roteiro referente produto da Tree
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param cChaveWhile, characters, chave de pesquisa filial + produto
@param cRoteiro, characters, roteiro atual para início da pesquisa - otimização de desempenho
@type Function
/*/

Static Function PriRotSG2(cChaveWhile)

	DbSelectArea("SG2")
	SG2->(DbSetOrder(1))
	SG2->(DbGoTop())//Força alteração do seek - Trata Bug
	SG2->(DbSeek(cChaveWhile))

Return

/*/{Protheus.doc} AntRotSG2
Posiciona a SG2 no roteiro anterior
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param cChaveWhile, characters, chave de pesquisa filial + produto
@param cRoteiro, characters, roteiro atual para início da pesquisa - otimização de desempenho
@type Function
/*/

Static Function AntRotSG2(cChaveWhile, cRoteiro)

	DbSelectArea("SG2")
	SG2->(DbSetOrder(1))
	SG2->(DbGoTop())//Força alteração do seek - Trata Bug
	If SG2->(DbSeek(cChaveWhile+cRoteiro,.T.))
		If cChaveWhile == SG2->(G2_FILIAL+G2_PRODUTO)
			While !SG2->(Bof()) .and. cChaveWhile == SG2->(G2_FILIAL+G2_PRODUTO)
				If cRoteiro	> SG2->G2_CODIGO
					cRoteiro	:= SG2->G2_CODIGO
					Exit
				ElseIf cRoteiro	<= SG2->G2_CODIGO
					SG2->(DbSkip(-1))
				EndIf
			EndDo
		Else
			SG2->(DbSkip(-1))
		EndIf
	EndIf

	If cChaveWhile != SG2->(G2_FILIAL+G2_PRODUTO)
		SG2->(DbGoTo(0))
	EndIf

Return

/*/{Protheus.doc} ProxRotSG2
Posiciona a SG2 no próximo roteiro
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param cChaveWhile, characters, chave de pesquisa filial + produto
@param cRoteiro, characters, roteiro atual para início da pesquisa - otimização de desempenho
@type Function
/*/

Static Function ProxRotSG2(cChaveWhile, cRoteiro)

	DbSelectArea("SG2")
	SG2->(DbSetOrder(1))
	SG2->(DbGoTop())//Força alteração do seek - Trata Bug
	If SG2->(DbSeek(cChaveWhile+cRoteiro,.T.))
		If cChaveWhile+cRoteiro == SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)
			While !SG2->(Eof()) .and. cChaveWhile == SG2->(G2_FILIAL+G2_PRODUTO)
				If cRoteiro	< SG2->G2_CODIGO
					cRoteiro	:= SG2->G2_CODIGO
					Exit
				ElseIf cRoteiro	>= SG2->G2_CODIGO
					SG2->(DbSkip())
				EndIf
			EndDo
		EndIf
	EndIf

	If cChaveWhile != SG2->(G2_FILIAL+G2_PRODUTO)
		SG2->(DbGoTo(0))
	EndIf

Return

/*/{Protheus.doc} UltiRotSG2
Posiciona a SG2 no último roteiro referente produto da Tree
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param cChaveWhile, characters, chave de pesquisa filial + produto
@param cRoteiro, characters, roteiro atual para início da pesquisa - otimização de desempenho
@type Function
/*/

Static Function UltiRotSG2(cChaveWhile, cRoteiro)

	Default cRoteiro	:= ""

	DbSelectArea("SG2")
	SG2->(DbSetOrder(1))
	SG2->(DbGoTop())//Força alteração do seek - Trata Bug
	If SG2->(DbSeek(cChaveWhile+cRoteiro))
		While !SG2->(Eof()) .and. cChaveWhile == SG2->(G2_FILIAL+G2_PRODUTO)
			SG2->(DbSkip())
		EndDo
	EndIf

	//Reposiciona no último (ou primeiro) registro da SG2 referente a chave passada
	ReposicSG2(cChaveWhile, SG2->(Recno()))

Return

/*/{Protheus.doc} ReposicSG2
Reposiciona no último (ou primeiro) registro da SG2 referente a chave passada
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param cChaveWhile, characters, chave de pesquisa filial + produto
@param nRecOld, characters, Recno posicionado anteriormente na SG2
@param lProximo, characters, indica ordem de posicionamento (.T. - A FRENTE, .F., PARA TRÁS)
@type Function
/*/
Static Function ReposicSG2(cChaveWhile, nRecOld, lProximo)

	Default lProximo	:= .T.

	If SG2->(Eof()) .OR. cChaveWhile != SG2->(G2_FILIAL+G2_PRODUTO)
		If lProximo
			//Reposiciona no registro anterior
			SG2->(DbSkip(-1))
			While (SG2->(Deleted()))
				SG2->(DbSkip(-1))
			EndDo
		Else
			//Reposiciona no registro posterior
			SG2->(DbSkip())
			While (SG2->(Deleted()))
				SG2->(DbSkip())
			EndDo
		EndIf
		//Se for outra chave, mantém desposicionado
		If cChaveWhile != SG2->(G2_FILIAL+G2_PRODUTO)
			SG2->(DbGoTo(nRecOld))
		EndIf
	EndIf
Return

/*/{Protheus.doc} ReloadView
Reload View com base nos registros posicionados e parâmetros recebidos
@author brunno.costa
@since 25/06/2018
@version P12
@return Nil
@param oModel, object, modelo da rotina
@param oView, object, view da rotina
@param cRoteiro, characters, código do roteiro do produto
@type Function
/*/

Static Function ReloadView(oModel, oView, cRoteiro, lAfterViewActivate)

	Local oCab124	:= oModel:GetModel("PCPA124_CAB")
	Local aAreaSG2	:= SG2->(GetArea())

	DEFAULT	lAfterViewActivate := .F.

	l129Altera	:= .F.
	l129Inclui	:= .F.
	l129Exclui	:= .F.
	l129Similar	:= .F.

	oModel:DeActivate()
	If !lAfterViewActivate
		oView:oControlBar:cTitle	:= STR0045 + " - " + STR0002	//Consulta - Man. Processos Produtivos por Estrutura
	EndIf
	oModel:setOperation(MODEL_OPERATION_VIEW)
	oView:setOperation(1)
	UpdAllMods(oView, oModel,.F.,.F.,.F.,cRoteiro)
	oModel:Activate()
	If Empty(cRoteiro)
		//Limpa campos do modelo
		oCab124:LoadValue("G2_CODIGO","")
		oCab124:LoadValue("G2_PRODUTO","")
		oCab124:LoadValue("CDESCPROD","")
	Else
		oCab124:LoadValue("G2_CODIGO",cRoteiro)
	EndIf

	RestArea(aAreaSG2)

Return

/*/{Protheus.doc} ReloadPerg
Troca de parâmetros da rotina e Processamentos
@author brunno.costa
@since 25/06/2018
@version P12
@return lPergConfirm
@param nOpc, numeric:
1 - Execução inicial;
2 - Troca de parâmetros em outras ações
@type Function
/*/

Static Function ReloadPerg(nOpc)

	Local lPergConfirm 	:= .T.
	Local oView			:= FwViewActive()
	Local cProduto		:= ""
	Local cRevisao		:= ""

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	If !(l129Inclui .OR. l129Altera .OR. l129Similar)
		If Pergunte("PCPA129",.T.)
			If !Empty(MV_PAR01) .and. !SB1->(DbSeek(xFilial("SB1")+MV_PAR01))
				Help('  ', 1, 'NOFOUNDSB1')
			EndIf
			While Empty(MV_PAR01) .OR. !SB1->(DbSeek(xFilial("SB1")+MV_PAR01))
				If !Pergunte("PCPA129",.T.)
					lPergConfirm := .F.
					Exit
				EndIf
				If !Empty(MV_PAR01) .and. !SB1->(DbSeek(xFilial("SB1")+MV_PAR01))
					Help('  ', 1, 'NOFOUNDSB1')
				EndIf
			EndDo
		Else
			lPergConfirm := .F.
		EndIf

		cProduto	:= Left(MV_PAR01,GetSX3Cache("B1_COD","X3_TAMANHO"))
		cRevisao	:= MV_PAR02

		DbSelectArea("SG1")
		SG1->(DbSetOrder(1))
		If SG1->(DbSeek(xFilial("SG1")+cProduto))
			cCargo		:= 	SG1->G1_COD + SG1->G1_TRT + SG1->G1_COMP + StrZero(SG1->(Recno()), 9) + StrZero(1, 9) + 'CODI'
		Else
			cCargo		:= cProduto + PadR("", GetSx3Cache("G1_TRT","X3_TAMANHO")) + PadR("", GetSx3Cache("G1_COMP","X3_TAMANHO")) + StrZero(0, 9) + StrZero(1, 9) + 'CODI'
		EndIf

		//Recarrega a Tree
		If lPergConfirm .AND. nOpc == 2
			If Empty(aCargos2Niv)
				aCargos2Niv	:= {}
			Else
				aSize(aCargos2Niv,0)
			EndIf
			oDbTree:Reset()
			aSize(asDbTree,0)
			aSize(aCargos2Niv,0)
			nIndex	:= 0

			TreeRecurs(oView:GetViewObj("V_TREE"), cProduto, cRevisao, cCargo, SG1->G1_TRT, .T.)
			AcaoTreeCh()
		EndIf

	Else
		If l129Inclui
			Help( Nil, Nil, STR0034, Nil, STR0035, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})	//STR0034 Inclusão em andamento! - STR0035 Operação de INCLUSÃO em andamento. - STR0036 Clique em 'Outras Ações + SALVAR' ou 'Outras Ações + Cancelar Transação Pendente' para prosseguir.
		ElseIf l129Altera
			Help( Nil, Nil, STR0037, Nil, STR0038, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})	//STR0037 Edição em andamento! - STR0038 Operação de EDIÇÃO em andamento. - STR0036 Clique em 'Outras Ações + SALVAR' ou 'Outras Ações + Cancelar Transação Pendente' para prosseguir."
		ElseIf l129Similar
			Help( Nil, Nil, STR0037, Nil, STR0038, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})	//STR0037 Roteiro Similar em andamento! - STR0038 Operação de ROTEIRO SIMILAR em andamento. - STR0036 Clique em 'Outras Ações + SALVAR' ou 'Outras Ações + Cancelar Transação Pendente' para prosseguir."
		EndIf
	EndIf

Return lPergConfirm

/*/{Protheus.doc} UpdStatics
Trata as variáveis estáticas
@author brunno.costa
@since 26/06/2018
@version P12
@return Nil
@param nOpc, numeric,
1 - Entrada na rotina
2 - Saída da rotina
@type Function
/*/
Static Function UpdStatics(nOpc)

	If nOpc == 1	//Entrada na rotina
		l129Inclui	:= .F.
		l129Altera	:= .F.
		l129Exclui	:= .F.
		l129Similar	:= .F.
		oDbTree		:= Nil
		oMenu		:= Nil
		cOldCargo	:= ""
		If Empty(aCargos2Niv)
			aCargos2Niv	:= {}
		Else
			aSize(aCargos2Niv,0)
		EndIf
		nNivelTr  := 0
		cFistCargo:= Nil
		If Empty(asDbTree)
			asDbTree	:= {}
		Else
			aSize(asDbTree,0)
		EndIf
	Else			//Saída da Rotina
		l129Inclui	:= Nil
		l129Altera	:= Nil
		l129Exclui	:= Nil
		l129Similar	:= Nil
		oDbTree		:= Nil
		oMenu		:= Nil
		cOldCargo	:= Nil
		If !Empty(aCargos2Niv)
			aSize(aCargos2Niv,0)
			aCargos2Niv	:= Nil
		EndIf
		nNivelTr  	:= Nil
		cFistCargo	:= Nil
		aSize(asDbTree,0)
		asDbTree	:= Nil
	EndIf

Return

/*/{Protheus.doc} RefreshBtn
Função executada para Refresh na View e atualização dos botões na Abertura da Tela
@author brunno.costa
@since 26/07/2018
@version P12
@return Nil
@type function
/*/
Static Function RefreshBtn(oView, oModel)
	If !lPriUpdBtn .And. oView != Nil .And. oView:oOwner != Nil .And. oView:IsActive()
		UpdAllMods(oView, oModel, .F., .F., .F.)
		If lPriUpdBtn
			oView:SetTimer(0, {|| })
		Endif
		oView:Refresh()
	EndIf
Return

/*/{Protheus.doc} ModoCheck
Indica o modo de edicao do campo Check do modelo PCPA124_SGF_C
@author brunno.costa
@since 27/05/2019
@version P12
@return modo de edicao do campo Check do modelo PCPA124_SGF_C
@type function
/*/
Static Function ModoCheck()
Return !IsInCallStack("PCPA129") .OR. l129Inclui .OR. l129Altera .OR. l129Exclui
