#INCLUDE "Protheus.ch"
#INCLUDE "Loja845.ch"

#DEFINE PESQUISAR			1 				// nomeia o parametro 1
#DEFINE VISUALIZAR		2				// nomeia o parametro 2
#DEFINE INCLUIR			3				// nomeia o parametro 3
#DEFINE ALTERAR	 		4				// nomeia o parametro 4
#DEFINE EXCLUIR	  		5				// nomeia o parametro 5

#DEFINE POS_MMODO			1				//Modo de abertura
#DEFINE POS_MRET			2       		//Modo de retorno
#DEFINE POS_MTPL			3				//Tipo da lista
#DEFINE POS_MNL			4				//Numero da lista (Filtro ME1)
#DEFINE POS_MONL			5				//Online
#DEFINE POS_MLNOM			6				//Entrar com nomes dos presenteadores
#DEFINE POS_MLENVM		7				//Enviar mensagem
#DEFINE POS_MLITAB		8				//Listar itens em aberto
#DEFINE POS_MORI			9				//Origem da lista (filtro ME1)
#DEFINE POS_MFILT			10				//Filtro (ME2)
#DEFINE POS_MMULT			11				//Multi-selecao
#DEFINE POS_MMTOD			12				//Marcar todos
#DEFINE POS_MQTDU			13				//Quantidade utilizada
#DEFINE POS_MLAQTD		14				//Alterar quantidade
#DEFINE POS_MAME			15				//Alterar modo de entrega
#DEFINE POS_MTPEVE		16				//Tipo de evento (filtro ME1)
#DEFINE POS_MSTAT			17	  			//Status da lista (filtro ME1)

Static nNumCols       	:= 200 			// numero de colunas
Static oGD01				  			//Getdados
Static nAltCont			:= 009			//Altera contador
Static nDistPad			:= 002			//variaveis para manipular o objeto getdados
Static nAltBot			:= 013			//variaveis para manipular o objeto getdados
Static cHK				:= "&"			//variaveis para manipular o objeto getdados
Static nDistAPad		:= 004			//variaveis para manipular o objeto getdados
Static aMainCfg			:= Array(17)	//Configuracao de operacoes
Static lUsaValUni		:= Nil 			//O campo ME2_VALUNI esta sendo usado para exibição.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Loja845   ºAutor  ³Vendas Cliente        º Data ³28/02/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para consulta de listas de presentes.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[N] : Comportamento rotina 1.Busca + Edicao 2.Busca + Retornoº±±
±±º          ³Exp02[N] : Disp.modo 2 define estrutura retorno de dados :        º±±
±±º          ³           1.Cabecalho 2.Itens 3.Cabecalho + Itens                º±±
±±º          ³Exp03[C] : Determinar o tipo de lista sera pesquisado (ME1_TIPO)  º±±
±±º          ³Exp04[C] : Numero da lista                                        º±±
±±º          ³           Modo 2 + Retorno 1 : retorno dados cab. sem interface  º±±
±±º          ³           Modo 2 + Retorno 2|3 : abrir componente sel.produtos   º±±
±±º          ³Exp05[L] : Determina se a pesquisa eh online ou por webservice    º±±
±±º          ³Exp06[L] : Abrir interface de digitacao de nomes                  º±±
±±º          ³Exp07[L] : Enviar mensagem aos atores (protagonistas)             º±±
±±º          ³Exp08[L] : Listar apenas itens com quantidade em aberto           º±±
±±º          ³Exp09[C] : Origem a ser considerado para os itens                 º±±
±±º          ³Exp10[C] : Filtro ME2                                             º±±
±±º          ³Exp11[C] : Multi-selecao                                          º±±
±±º          ³Exp12[C] : Marcar todos                                           º±±
±±º          ³Exp13[A] : Quantidade utilizada                                   º±±
±±º          ³Exp14[C] : Permite alterar quantidade?                            º±±
±±º          ³Exp15[C] : Permite alterar modo de entrega?                       º±±
±±º          ³Exp16[C] : Tipo de evento que a rotina devera pesquisar           º±±
±±º          ³Exp17[C] : Status da lista 1.Ativa 2.Inativa                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Loja845(	nModo	,nRetorno	,cTipoLst	,cNumLst	,;
					lOnline	,lNomesP	,lEnvMens	,lItAb		,;
					cOrigem	,cFiltro	,lMultiSel	,lMarcaT	,;
					aQtdeUt	,lAltQtde	,lAltME		,cTipoEven	,;
					cStatus)

Local lLstPre			:= SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)	//Lista de presente ativa?
Local uRet				:= .T.													//Retorno da rotina
Local cAlias01			:= "ME1"
Local lPAF				:= FindFunction("LjxBGetPaf") .AND. LjxBGetPaf()[2]		//PDV
Local lAbInterf			:= .T.													//Abrir interface
Local aLstCmpNL			:= {}													//Lista de campos para nao listar
Local oArea				:= FWLayer():New()                                     // objeto da area de trabalho
Local aCoord			:= FWGetDialogSize(oMainWnd)							//Coordenadas da tela
Local lMDI				:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) 		//Verifica se acessou via SIGAMDI
Local aLstOpc			:= {STR0001,STR0002,STR0003,STR0004,STR0005}			//Lista de opcoes de pesquisa
Local aLstOpcCmp		:= {"ME1_CODIGO","MEE_NOME","ME1_DTEVEN",;				//Campos da lista de opcao de pesquisa
							"ME1_LOCAL","A1_NOME"}
Local cTitulo			:= STR0006												//Titulo da rotina
Local nOpcFiltro		:= "1"													//Opcao de filtro
Local cFiltroP			:= Space(nNumCols)										//Filtro de pesquisa a ser adicionado
Local aLstFil			:= {}													//Lista de filtro - para visualizacao
Local aLstFilC			:= {}													//Lista de filtro completo - controle
Local nOpcFil			:= 0													//Opcao do filtro
Local lBaixaRes			:= IsInCallStack("FRTA271") .OR. cModulo == "FRT"		//Flag para tratamento de baixa resolucao
Local aTamObj			:= Array(4)												//Dimensoes do objeto
Local aTamObjGD			:= Array(4)												//Dimensoes do objeto da GD
Local aLstCmp01			:= {}													//Lista de campos da GD de listas
Local aDados01			:= {}													//Array de dados para o GD de listas
Local aLegenda			:= {}													//Array de cores de legendas
Local aCores			:= {}													//Array de regras e cores de legendas
Local aHeader01			:= {}													//Cabecalho de dados
Local cTMP				:= ""							 						//String temporaria
Local lHabIncl			:= .T.													//Habilitar a inclusao de dados
Local aCabRet			:= Array(8)												//Cabecalho de retorno
Local aItRet			:= {}													//Itens de retorno
Local nOpcA				:= 0													//Opcao de retorno
Local aAreaSX3			:= SX3->(GetArea())									//Workarea SX3
Local lTCBox			:= .T.													//Substituir valor de campos combobox pela desc. da opcao selecionada?
Local lMaximiza			:= .F.													//Maximixar tela?
Local nCoefDif			:= 1													//Coficiente de reducao de area da FWLayer
Local lRet				:= .T.													//Variável de Retorno

//Objetos graficos
Local oDlg																		//objeto de dialog
Local oPainel01											   						//Filtro para busca
Local oPainel02											   						//Resultado
Local oPainel03																	//Painel de destaque
Local oCont01																	//Tipo filtro
Local oCont02																	//Filtro
Local oCont03																	//Filtros utilizados
Local oCont04																	//GD de listas
Local oEtq01  																	// objeto de pesquisa
Local oEtq02																	// objeto de pesquisa
Local oEtq03																	// objeto de pesquisa
Local oBot01																	//Adicionar
Local oBot02																	//Remover
Local oBot03																	//Pesquisar
Local oBot04																	//Limpar lista
Local oBot05																	//Visualizar
Local oBot06																	//Incluir
Local oBot07																	//Alterar
Local oBot08																	//Excluir
Local oBot09																	//Imprimir
Local oBot10																	//Atores
Local oBot11																	//Entregas
Local aAuxCombo			:= RetSx3Box( Posicione("SX3", 2, PadR("ME1_STATUS",10), "X3CBox()" ),,, 1 )	//Array contendo os status da consulta de conta corrente
Local nEsqCont			:= 001													//
Local nLargBot			:= 040													//

Private aRotina			:= MenuDef()											// Rotina para manipulacao das tabelas

Default nModo       	:= 1													// modo de execucao
Default nRetorno		:= 0													// retorno
Default cTipoLst		:= ""													// tipo de lista
Default cNumLst			:= ""													// numero da lista
Default lOnline			:= !(cModulo == "FRT")									// variavel para checar se o sistema esta on-line
Default lNomesP			:= .F.													// checa assinaturas
Default lEnvMens		:= .T.													// checa envio de mensagem para convidado e organizador
Default lItAb			:= .F.													// variavel de configuracao de itens de kusta
Default cOrigem			:= ""													// origem do produto
Default cFiltro			:= ""                                                   // filtro da tabela
Default lMultiSel		:= .T.													// checa multi seleca
Default lMarcaT			:= .F.                                                 // marca item
Default aQtdeUt			:= {}                                                  // array com quantidade comprada
Default lAltQtde		:= .T.                                                 // verifica alteracao de quantidade
Default lAltME			:= .F.                                                 // verifica alteracao na tabela
Default cTipoEven		:= ""                                                  // tipo de evento
Default cStatus			:= ""                                                  // status da lista

If lUsaValUni == Nil //O campo ME2_VALUNI esta sendo usado para exibição.
	lUsaValUni := X3Uso(GetSx3Cache("ME2_VALUNI","X3_USADO")) 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de Presentes                                           ³
//³Inicializa valor das variáveis para que o tamanho dos objetos³
//³não fiquem mudando de tamanho cada vez que é aberto          ³
//³e fechada a tela de procura de listas                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nNumCols 				:= 200 													// numero de colunas
nAltCont 				:= 009 													//Altera contador
nDistPad 				:= 002 													//variaveis para manipular o objeto getdados
nAltBot 				:= 013 													//variaveis para manipular o objeto getdados
nDistAPad 				:= 004 													//variaveis para manipular o objeto getdados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se o pacote de lista de presente esta devidamente aplicado e/ou configurado.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lLstPre
	Help(" ",1,"LJLISPREA")
	Return !lRet
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacoes e definicoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Validar tipo de conexao
If lOnline .AND. (lPAF .OR. lBaixaRes)
	lOnline := !lOnline
Endif
//Validar o modo de operacao
If !lOnline .AND. nModo == 1
	nModo := 2
Endif
//Validar o tipo de retorno
If nModo == 1
	nRetorno := 0
Else
	If Empty(nRetorno)
		nRetorno := 1
	Endif
Endif
//Verificar se a interface devera ser aberta
If nModo == 2 .AND. !Empty(cNumLst) .AND. nRetorno == 1
	lAbInterf := !lAbInterf
Endif
If !lOnline
	//Se a conexao for offline, desativar a edicao do nome de presenteadores
	lNomesP 	:= .F.
Else
	//Se a conexao for online, desativar a exibicao e edicao do campo de modo de entrega 
	lAltME		:= .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimentar a variavel principal de configuracoes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMainCfg[POS_MMODO]		:= nModo
aMainCfg[POS_MRET]		:= nRetorno
aMainCfg[POS_MTPL]		:= cTipoLst
aMainCfg[POS_MNL]		:= cNumLst
aMainCfg[POS_MONL]		:= lOnline
aMainCfg[POS_MLNOM]		:= lNomesP
aMainCfg[POS_MLENVM]	:= lEnvMens
aMainCfg[POS_MLITAB]	:= lItAb
aMainCfg[POS_MORI]		:= cOrigem
aMainCfg[POS_MFILT]		:= cFiltro
aMainCfg[POS_MMULT]		:= lMultiSel
aMainCfg[POS_MMTOD]		:= lMarcaT
aMainCfg[POS_MQTDU]		:= aQtdeUt
aMainCfg[POS_MLAQTD]	:= lAltQtde
aMainCfg[POS_MAME]		:= lAltME
aMainCfg[POS_MTPEVE]	:= cTipoEven
aMainCfg[POS_MSTAT]		:= cStatus
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de campos da GD de lista de presentes   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLstCmpV := ""
SX3->(DbSeek(cAlias01))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias01
	If 	X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. aScan(aLstCmpNL,{|x| x == Upper(AllTrim(SX3->X3_CAMPO))}) == 0 .AND. ;
		SX3->X3_CONTEXT <> "V" .AND. SX3->X3_TIPO <> "M" .Or. AllTrim(SX3->X3_CAMPO) == "ME1_DESCCL"

		aAdd(aLstCmp01,SX3->X3_CAMPO)
		//Cabecalho para a GD de lista
		aAdd(aHeader01,{SX3->X3_CAMPO,SX3->X3_PICTURE,AllTrim(X3Titulo()),SX3->X3_TAMANHO,SX3->X3_TIPO})
	Endif
	SX3->(DbSkip())
EndDo
aDados01 := {Array(Len(aHeader01))}
//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
If lAbInterf
	//Verificar se o botao de inclusao deve ser utilizado
	If ExistBlock("LJ845INC")
		If ValType(lHabIncl := ExecBlock("LJ845INC",.F.,.F.,{})) # "L"
			lHabIncl := .T.
		Endif
	Endif

	//Incrementa o array de Legenda com os status disponiveis
	aAdd(aLegenda,{"ENABLE"		,aAuxCombo[1][3]})	//Credito Liberado
	aAdd(aLegenda,{"DISABLE"	,aAuxCombo[2][3]})	//Debito
	
	//Adiciono as regras de cores no array a Cores
	aAdd(aCores,{{"ME1_STATUS", 'ME1_STATUS == "' + Alltrim(aAuxCombo[1,3]) + '"'},aLegenda[1][1]})
	aAdd(aCores,{{"ME1_STATUS", 'ME1_STATUS == "' + Alltrim(aAuxCombo[2,3]) + '"'},aLegenda[2][1]})
	
	//Definir tamanho da tela
	If !lBaixaRes
		aCoord[3] := aCoord[3] * 0.9
		aCoord[4] := aCoord[4] * 0.7
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" PIXEL
	Else
		lMaximiza := .T.
		aCoord[1] := 001
		aCoord[2] := 001
		//Refazer dimensionamentos
		nAltCont	:= Int(nAltCont * 0.7)
		//Distancia entre controles
		nDistPad	:= Int(nDistPad * 0.9)
		nDistAPad	:= Int(nDistAPad * 0.9)
		//Botoes
		nLargBot	:= Int(nLargBot * 0.8)
		nAltBot		:= Int(nAltBot * 0.8)
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
	Endif
	oDlg:lMaximized := lMaximiza
	oDlg:lCentered := .T.
	//Inicializando FWLayer
	oArea:Init(oDlg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³Linha 01  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	oArea:AddLine("L01",40 * nCoefDif,.T.)
	oArea:AddCollumn("L01C01",100,.F.,"L01")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 01 - Dados do filtro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oArea:AddWindow("L01C01","L01C01P01",STR0007,100,.F.,.F.,,"L01")
	oPainel01 := oArea:GetWinPanel("L01C01","L01C01P01","L01")	
	//Dimensoes TOP|LEFT|WIDTH|HEIGHT
	aTamObj[1] := 000
	aTamObj[2] := nEsqCont
	aTamObj[3] := (oPainel01:nClientWidth / 2) * 0.3
	aTamObj[4] := nAltCont
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipo de pesquisa  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEtq01	:= tSay():New(aTamObj[1],aTamObj[2],{|| STR0008},oPainel01,,,,,,.T.,,,aTamObj[3],aTamObj[4])
	aTamObj[1] += nAltCont
	oCont01	:= tComboBox():New(aTamObj[1],aTamObj[2],{|x| If(PCount() > 0, nOpcFiltro := x,nOpcFiltro)},aLstOpc,aTamObj[3],aTamObj[4],oPainel01,,;
		{|| cFiltroP := Space(nNumCols),oCont02:Picture := Lj845Pict(1,nOpcFiltro,aLstOpcCmp),oCont02:Refresh(),oCont01:SetFocus()}/*Change*/,;
		/*Valid*/,,,.T.,,,,/*When*/,,,,,"nOpcFiltro")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtro de pesquisa  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTamObj[1] -= nAltCont
	aTamObj[2] := ((oCont01:nLeft + oCont01:nWidth) / 2) + nDistPad
	aTamObj[3] := (oPainel01:nClientWidth / 2) * 0.55
	oEtq02	:= tSay():New(aTamObj[1],aTamObj[2],{|| STR0009},oPainel01,,,,,,.T.,,,aTamObj[3],aTamObj[4])
	aTamObj[1] += nAltCont
	oCont02	:= tGet():New(aTamObj[1],aTamObj[2],{|x| If(PCount() > 0,cFiltroP := x,cFiltroP)},oPainel01,aTamObj[3],aTamObj[4],Lj845Pict(1,nOpcFiltro,aLstOpcCmp),;
		/*valid*/,,,/*font*/,,,.T.,,,/*when*/,,,/*change*/,.F.,.F.,,"cFiltroP")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criterios utilizados  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTamObj[1] += (nAltCont + nDistAPad)
	aTamObj[2] := nEsqCont
	aTamObj[3] := (oPainel01:nClientWidth / 2) * 0.55
	oEtq03	:= tSay():New(aTamObj[1],aTamObj[2],{|| STR0010},oPainel01,,,,,,.T.,,,aTamObj[3],aTamObj[4])
	//Painel de fundo
	aTamObj[1] += nAltCont
	aTamObj[3] := (oPainel01:nClientWidth / 2) * 0.85
	aTamObj[4] := (oPainel01:nClientHeight / 2) - aTamObj[1]
	oPainel03 := tPanel():New(aTamObj[1],aTamObj[2],"",oPainel01,,,,,CLR_HGRAY,aTamObj[3],aTamObj[4])
	//Lista de filtros utilizados
	aTamObj[1] := 001
	aTamObj[2] := 001
	aTamObj[3] := (oPainel03:nClientWidth / 2) * 0.995
	aTamObj[4] := (oPainel03:nClientHeight / 2) * 0.97
	oCont03	:= tListBox():New(aTamObj[1],aTamObj[2],{|x| If(PCount() > 0,nOpcFil := x,nOpcFil)},aLstFil,aTamObj[3],aTamObj[4],/*Change*/,oPainel03,;
		/*Valid*/,,,.T.,,/*DblClick*/,,,,/*When*/,,,,,/*RightClick*/)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Botoes de comando - Pesquisa  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//TOP+LEFT+WIDTH+HEIGHT
	aTamObj[1] := 000
	aTamObj[2] := (oPainel01:nClientWidth / 2) - nLargBot
	aTamObj[3] := nLargBot
	aTamObj[4] := nAltBot
	//Botao - Adicionar
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0011,oPainel01,{|| IIf(!Lj845LBAdd(aLstOpc[Val(nOpcFiltro)],aLstOpcCmp[Val(nOpcFiltro)],;
		cFiltroP,@aLstFilC,@oCont03),.T.,cFiltroP := Space(nNumCols)),oCont02:SetFocus(),oCont03:Select(Len(oCont03:aItems))},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	//Botao - Remover
	aTamObj[1] += (nAltBot + nDistPad)
	oBot02 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0012,oPainel01,{|| Lj845LBExc(@oCont03,oCont03:nAt,@aLstFilC)},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	//Botao - Pesquisar
	aTamObj[1] += (nAltBot + nDistPad)
	oBot03 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0013,oPainel01,{|| Lj845Busca(lOnline,/*Filial*/,@aHeader01,@aLstFilC,/*Ordem*/,@aDados01,@oPainel02,;
		@oCont04,aLegenda,aCores,@aTamObjGD,,lTCBox)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	If !lBaixaRes
		aTamObj[1] += (nAltBot + nDistPad)
		oBot04 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0014,oPainel01,{|| oCont03:Reset(),aLstFilC := Array(0)},;
			aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)	
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³Linha 02  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	oArea:AddLine("L02",60 * nCoefDif,.T.)
	oArea:AddCollumn("L02C01",100,.F.,"L02")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 02 - Listas           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oArea:AddWindow("L02C01","L02C01P01",STR0015,100,.F.,.F.,,"L02")
	oPainel02 := oArea:GetWinPanel("L02C01","L02C01P01","L02") 
	//Caso o modo de operacao seja 2 (retorno) e exista numero de lista definido
	If !Empty(aMainCfg[POS_MNL]) .AND. aMainCfg[POS_MMODO] == 2 .AND. aMainCfg[POS_MRET] # 0 .AND. cValtoChar(aMainCfg[POS_MRET]) $ "1|2|3"
		//Pesquisar lista sem interface
		Lj845Busca(lOnline,/*Filial*/,@aHeader01,@aLstFilC,/*Ordem*/,@aDados01,/*oPainel02*/,/*oCont04*/,/*aLegenda*/,/*aCores*/,/*aTamObjGD*/,.F.,lTCBox)	
	Endif	
	//Dimensoes da GD
	aTamObjGD[1] := 000
	aTamObjGD[2] := nEsqCont
	aTamObjGD[3] := (oPainel02:nClientWidth / 2) * 0.85
	aTamObjGD[4] := (oPainel02:nClientHeight / 2)
	//GD da lista de presentes
	LjMntBrw(	@oPainel02,;				//01 - Objeto Janela
				@aDados01,;					//02 - Alias ou Array de Dados
				{aTamObjGD[1],;				//03 - Array contendo as coordenadas
				aTamObjGD[2],;
				aTamObjGD[3],;
				aTamObjGD[4]},;	
				@oCont04,;					//04 - Objeto que sera criado
				.T.,;						//05 - Utilizar dicionario para compor colunas
				aHeader01,;					//06 - Lista de campos desejados
				Nil,;						//07 - Expressao para Legenda Automatica
				aLegenda,;					//08 - Codigo de cores para legenda automatica
				NIL,;						//09 - Expressao para posicionamento no inicio
				NIL,;						//10 - Expressao para posicionamento no final
				{|| NIL},;					//11 - Expressao ao clicar em um item da lista
				NIL,;						//12 - Coluna que ficara congelada na exibicao
				NIL,;						//13 - Classificacao por cabecalho (header)
				aCores,;					//14 - Array de Legenda
				.T.,;						//15 - Formatar dados com a picture informada (origem array)
				.F.)						//16 - A ordem dos campos deve respeitar o SX3 (origem alias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Botoes de comando - Listas    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//TOP+LEFT+WIDTH+HEIGHT
	aTamObj[1] := 000
	aTamObj[2] := (oPainel02:nClientWidth / 2) - nLargBot
	aTamObj[3] := nLargBot
	aTamObj[4] := nAltBot	
	If nModo == 1
		//Botao - Visualizar
		oBot05 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0016,oPainel02,{|| cTMP := "",cTMP := Lj845RetCol(2,"ME1_CODIGO",1,oCont04:nAt,aHeader01,aDados01),;
			IIf(!Empty(cTMP),Loja843(,,,,,VISUALIZAR,cTMP),.T.)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		//Botao - Incluir
		aTamObj[1] += (nAltBot + nDistPad)
		oBot06 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0017,oPainel02,{|| Loja843(,,,,,INCLUIR)},;
			aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| lHabIncl}/*When*/)
		//Botao - Alterar
		aTamObj[1] += (nAltBot + nDistPad)
		oBot07 := tButton():New(aTamObj[1],aTamObj[2],STR0027,oPainel02,{|| cTMP := "",cTMP := Lj845RetCol(2,"ME1_CODIGO",1,oCont04:nAt,aHeader01,aDados01),;
			IIf(!Empty(cTMP),Loja843(,,,,,ALTERAR,cTMP),.T.)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)	
		//Botao - Excluir
		aTamObj[1] += (nAltBot + nDistPad)
		oBot08 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0018,oPainel02,{|| cTMP := "",cTMP := Lj845RetCol(2,"ME1_CODIGO",1,oCont04:nAt,aHeader01,aDados01),;
			IIf(!Empty(cTMP),IIf(Loja843(,,,,,EXCLUIR,cTMP),Lj845Busca(lOnline,/*Filial*/,@aHeader01,@aLstFilC,/*Ordem*/,@aDados01,@oPainel02,;
				@oCont04,@aLegenda,@aCores,@aTamObjGD,,lTCBox),.T.),.T.)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		//Botao - Imprimir
		aTamObj[1] += (nAltBot + nDistPad)
		oBot09 := tButton():New(aTamObj[1],aTamObj[2],STR0019,oPainel02,{|| cTMP := Lj845RetCol(2,"ME1_CODIGO",1,oCont04:nAt,aHeader01,aDados01),;
		IIf(!Empty(cTMP),Iif(ExistBlock("LJ845REL"),ExecBlock("LJ845REL",.F.,.F.,{FWGETCODFILIAL,cTMP}),LOJR847(FWGETCODFILIAL,cTMP)),.T.)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	Else
		//Botao - Selecionar
		oBot13 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0020,oPainel02,{|| IIf(Lj845PesqI(Lj845RetCol(2,"ME1_CODIGO",1,oCont04:nAt,aHeader01,aDados01),;
			@aCabRet,@aItRet,lMDI,{aCoord[1],aCoord[2],aCoord[3],aCoord[4]}),Eval({|| oDlg:End(),nOpcA := 1}),.T.)},;
			aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	Endif
	//Botao - Atores
	aTamObj[1] += (nAltBot + nDistPad)
	oBot10 := tButton():New(aTamObj[1],aTamObj[2],STR0021,oPainel02,;
		{|| Lj845AbLst(2,lOnline,Lj845RetCol(2,"ME1_TIPO",1,oCont04:nAt,aHeader01,aDados01,.T.,.T.),;
		Lj845RetCol(2,"ME1_CODIGO",1,oCont04:nAt,aHeader01,aDados01),lMDI)},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)		
	//Botao - Entregas
	aTamObj[1] += (nAltBot + nDistPad)
	oBot11 := tButton():New(aTamObj[1],aTamObj[2],IIf(nModo == 2,cHK,"") + STR0022,oPainel02,;
		{|| Lj845AbLst(1,lOnline,Lj845RetCol(2,"ME1_TIPO",1,oCont04:nAt,aHeader01,aDados01),;
		Lj845RetCol(2,"ME1_CODIGO",1,oCont04:nAt,aHeader01,aDados01),lMDI)},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)		
	//Botao - Fechar
	aTamObj[1] := (oPainel02:nClientHeight / 2) - nAltBot
	aTamObj[2] := (oPainel02:nClientWidth / 2) - nLargBot
	aTamObj[3] := nLargBot
	aTamObj[4] := nAltBot
	oBot12 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0023,oPainel02,{|| oDlg:End()},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)	
		
	oDlg:Activate(,,,.T.,/*valid*/,,{|| oCont01:SetFocus()})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento de retorno  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1
		Do Case
			Case aMainCfg[POS_MRET] == 1
				uRet := {aCabRet,{}}
			Case aMainCfg[POS_MRET] == 2
				uRet := {{},aItRet}
			Otherwise
				uRet := {aCabRet,aItRet}
		EndCase
	Endif
Else
	If !Empty(aMainCfg[POS_MNL]) .AND. aMainCfg[POS_MMODO] == 2 .AND. aMainCfg[POS_MRET] # 0 .AND. cValtoChar(aMainCfg[POS_MRET]) $ "1|2|3"
		//Pesquisar lista sem interface
		Lj845Busca(lOnline,/*Filial*/,@aHeader01,@aLstFilC,/*Ordem*/,@aDados01,/*oPainel02*/,/*oCont04*/,/*aLegenda*/,/*aCores*/,/*aTamObjGD*/,.F.,lTCBox)
		//Caso dados tenham sido encontrados
		If Len(aDados01) > 0
			//Montar cabecalho de retorno
			aCabRet[1] := Lj845RetCol(2,"ME1_CODIGO",1,1,aHeader01,aDados01)			//Codigo
			aCabRet[2] := Lj845RetCol(2,"ME1_TIPO",1,1,aHeader01,aDados01,.T.,.T.)	//Tipo da lista
			aCabRet[3] := Lj845RetCol(2,"ME1_TPEVEN",1,1,aHeader01,aDados01)			//Tipo do evento
			aCabRet[4] := Lj845RetCol(2,"ME1_EMISSAO",1,1,aHeader01,aDados01)			//Emissao
			aCabRet[5] := Lj845RetCol(2,"ME1_DTEVEN",1,1,aHeader01,aDados01)			//Data do evento
			aCabRet[6] := Lj845RetCol(2,"ME1_CONTAT",1,1,aHeader01,aDados01)			//Contato
			aCabRet[7] := Lj845RetCol(2,"ME1_STATUS",1,1,aHeader01,aDados01,.T.,.T.)	//Status
			aCabRet[8] := Lj845RetCol(2,"ME1_DTVAL",1,1,aHeader01,aDados01)			//Validade
			If aMainCfg[POS_MRET] == 1
				//Retorno de cabecalho de lista especifica sem a interface
				uRet := {aCabRet,{}}
			Else
				//Foi solicitado o retorno de itens ou cabecalho + itens, sera necessario a abertura para selecao dos produtos desejados
				If !lBaixaRes
					aCoord[3] := aCoord[3] * 0.9
					aCoord[4] := aCoord[4] * 0.7
				Else
					aCoord[1] := 001
					aCoord[2] := 001
					//Refazer dimensionamentos
					nAltCont	:= Int(nAltCont * 0.7)
					//Distancia entre controles
					nDistPad	:= Int(nDistPad * 0.9)
					nDistAPad	:= Int(nDistAPad * 0.9)
					//Botoes
					nLargBot	:= Int(nLargBot * 0.8)
					nAltBot		:= Int(nAltBot * 0.8)					
				Endif	
				If Lj845PesqI(cNumLst,@aCabRet,@aItRet,lMDI,{aCoord[1],aCoord[2],aCoord[3],aCoord[4]})
					Do Case
						Case aMainCfg[POS_MRET] == 1
							uRet := {aCabRet,{}}
						Case aMainCfg[POS_MRET] == 2
							uRet := {{},aItRet}
						Otherwise
							uRet := {aCabRet,aItRet}
					EndCase				
				Endif
			Endif
		Endif
	Endif
Endif
RestArea(aAreaSX3)

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845BuscaºAutor  ³Vendas Cliente        º Data ³02/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para efetuar a busca mediante filtro definido              º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[L] : Online?                                                º±±
±±º          ³Exp02[C] : Filial de pesquisa                                     º±±
±±º          ³Exp03[A] : Cabecalho tabela                                       º±±
±±º          ³Exp04[A] : Array de filtros a aplicar                             º±±
±±º          ³Exp05[N] : Ordem do indice da tabela                              º±±
±±º          ³Exp06[A] : Array para armazenar o resultado da pesquisa           º±±
±±º          ³Exp07[O] : Objeto da interface                                    º±±
±±º          ³Exp08[O] : Objeto da grid de dados                                º±±
±±º          ³Exp09[A] : Array com os codigos de cores das legendas             º±±
±±º          ³Exp10[A] : Array com as regras para aplicacao das legendas        º±±
±±º          ³Exp11[A] : Dimensoes do objeto do tipo grid a ser criado          º±±
±±º          ³Exp12[L] : Exibir interface?                                      º±±
±±º          ³Exp13[L] : Substuir valor de campos combo pelo valor da opcao?    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj845Busca( lOnline ,cFil    ,aHeader01,aFiltro,;
							nOrdem  ,aDados01,oDlg     ,oGD01  ,;
							aLegenda,aCores  ,aTamObjGD,lExTela,;
							lTCBox)

Local aRet				:= {}				//Retorno
Local bErro				:= {}				//Bloco de codigo para tratamento de erro
Local cErro				:= ""				//Mensagem de erro
Local lErro				:= .F.				//Aponta existencia de erro no processamento
Local aLstCmp			:= {}				//Lista de campos para consulta
Local lAtObj			:= .T.				//Atualizar objeto GD
Local lRet				:= .F.				//Controle de retorno
Local aTMP				:= {}				//Array temporaria
Local ni				:= 0				//Contador
Local cDel				:= "|"				//Delimitador
Local oWS				:= Nil				//Objeto webservice
Local cRotina			:= "[LOJA845:LJ845BUSCA]"

Default lOnline		:= .T.					// verifica se o sistema esta on-line (PDV)
Default lExTela		:= .T.					// definicao de tela
Default lTCBox		:= .F.					// definicao de box
Default cFil    	:= ""					// Filial
Default aHeader01	:= {}					// cabecalho
Default aFiltro		:= {}					// filtro da tabela de itens
Default nOrdem  	:= 0					// Ordem dos campos
Default aDados01	:= {}					// array dos dados a incluir
Default oDlg		:= NIL					// objeto do dialog
Default oGD01		:= NIL					// objeto do dialog
Default aLegenda	:= {}					// array de legendas
Default aCores		:= {}					// array das cores da legenda
Default aTamObjGD	:= {}					// array com tamanho do objeto GD

//Montar lista de campos a partir do cabecalho
aEval(aHeader01,{|x| aAdd(aLstCmp,x[1])})
//Bloco de tratamento de erro
bErro := ErrorBlock({|e| VerErro(e,@lErro,@cErro)})
If lExTela
	If ValType(aFiltro) == "A" .AND. Len(aFiltro) > 0
		If ValType(aTamObjGD) # "A" .OR. Len(aTamObjGD) # 4 .OR. ValType(aLegenda) # "A" .OR. Len(aLegenda) == 0 .OR. ;
			ValType(aCores) # "A" .OR. Len(aCores) == 0
			
			lAtObj := .F.
		Endif
		If lOnline
			Begin Sequence
				MsAguarde({|| aRet := Lj845PesqC(cFil,aLstCmp,aFiltro,nOrdem,lTCBox)},STR0028,STR0029, .T.)
				If ValType(aRet) # "A" .OR. Len(aRet) == 0
					MsgAlert(STR0049)    //// "Nenhum registro foi encontrado!"
				Endif
				Recover
			End Sequence
			If lErro
				Alert(cErro)
				lRet := .F.
				aFiltro := aFiltroBckp
				Return aRet
			Endif
			ErrorBlock(bErro)
		Else
			//Verifica se o campo LG_WSSRV esta preenchido e alerta o usuario que a pesquisa nao vai retornar os dados da retaguarda
			If AllTrim(LjGetStation("WSSRV")) == ""
				MsgAlert(STR0065) //"O campo LG_WSSRV não esta preenchido e a pesquisa não retornará os dados desejados."
			EndIf

			oWS := WSWSLOJA845():New()
			iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
			//Definicao de parametros
			oWS:_URL		:= "http://" + AllTrim(LjGetStation("WSSRV")) + "/WSLOJA845.apw"
			oWS:cCEMP01		:= cEmpAnt
			oWS:cCFIL01		:= IIf(!Empty(cFil),cFil,cFilAnt)
			oWS:cCLSTCMP01	:= ArrTokStr(aLstCmp,cDel,0)
			oWS:cCFILTRO	:= ArrTokStr(aFiltro,cDel,0)
			oWS:nNORDEM01	:= nOrdem
			oWS:lLTCBOX01	:= lTCBox
			oWS:cCLCFG		:= ArrTokStr(aMainCfg,cDel,0)
			//Chamada do metodo de busca de listas de presentes
			MsAguarde({|| lRet := oWS:LJ845PESQC()},STR0028,STR0029, .T.)
			If ValType(lRet) == "L"
				If !lRet
					Lj845WSErr(cRotina)
					Return aRet
				Else
					If Len(oWS:oWSLJ845PESQCRESULT:oWSARETMOD) > 0 .AND. !Empty(oWS:oWSLJ845PESQCRESULT:oWSARETMOD[1]:cCRETORNO)
						For ni := 1 to Len(oWS:oWSLJ845PESQCRESULT:oWSARETMOD)
							aTMP := StrTokArr(oWS:oWSLJ845PESQCRESULT:oWSARETMOD[ni]:cCRETORNO,cDel)
							//Converter dados de acordo com o tipo de dado de cada campo utilizado
							aTMP := Lj845WSCon(aTMP,aHeader01,5)
							aAdd(aRet,aTMP)
						Next ni
					Endif
				Endif
			Else
				//Erro
				Return aRet
			Endif			
		Endif
	Endif
	If Len(aRet) == 0
		aDados01 := {Array(Len(aHeader01))}
	Else
		aDados01 := aClone(aRet)
	Endif
	If oDlg # Nil .AND. lAtObj
		//GD da lista de presentes
		LjMntBrw(	@oDlg,;						//01 - Objeto Janela
					@aDados01,;					//02 - Alias ou Array de Dados
					{aTamObjGD[1],;				//03 - Array contendo as coordenadas
					aTamObjGD[2],;
					aTamObjGD[3],;
					aTamObjGD[4]},;	
					@oGD01,;					//04 - Objeto que sera criado
					.T.,;						//05 - Utilizar dicionario para compor colunas
					aHeader01,;					//06 - Lista de campos desejados
					Nil,;						//07 - Expressao para Legenda Automatica
					aLegenda,;					//08 - Codigo de cores para legenda automatica
					Nil,;						//09 - Expressao para posicionamento no inicio
					Nil,;						//10 - Expressao para posicionamento no final
					{|| Nil},;					//11 - Expressao ao clicar em um item da lista
					Nil,;						//12 - Coluna que ficara congelada na exibicao
					Nil,;						//13 - Classificacao por cabecalho (header)
					aCores,;					//14 - Array de Legenda
					.F.,;						//15 - Formatar dados com a picture informada (origem array)
					.F.)						//16 - A ordem dos campos deve respeitar o SX3 (origem alias)
		If ValType(oGD01) == "O"
		//If oGD01 <> nil .and. Len(aDados01) > 0
			oGD01:Refresh()
		Endif
	Endif
Else
	If lOnline
		Begin Sequence
			MsAguarde({|| aRet := Lj845PesqC(cFil,aLstCmp,aFiltro,nOrdem,lTCBox)},STR0028,STR0029, .T.)
			If ValType(aRet) # "A" .OR. Len(aRet) == 0
				MsgAlert(STR0026)
			Endif
			Recover
		End Sequence
		If lErro
			Alert(cErro)
			lRet := .F.
			aFiltro := aFiltroBckp
			Return lRet
		Endif
		ErrorBlock(bErro)		
	Else
		//Verifica se o campo LG_WSSRV esta preenchido e alerta o usuario que a pesquisa nao vai retornar os dados da retaguarda
		If AllTrim(LjGetStation("WSSRV")) == ""
			MsgAlert(STR0065) //"O campo LG_WSSRV não esta preenchido e a pesquisa não retornará os dados desejados."
		EndIf

		oWS := WSWSLOJA845():New()
		iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
		//Definicao de parametros
		oWS:_URL		:= "http://" + AllTrim(LjGetStation("WSSRV")) + "/WSLOJA845.apw"
		oWS:cCEMP01		:= cEmpAnt
		oWS:cCFIL01		:= IIf(!Empty(cFil),cFil,cFilAnt)
		oWS:cCLSTCMP01	:= ArrTokStr(aLstCmp,cDel,0)
		oWS:cCFILTRO	:= ArrTokStr(aFiltro,cDel,0)
		oWS:nNORDEM01	:= nOrdem
		oWS:lLTCBOX01	:= lTCBox
		oWS:cCLCFG		:= ArrTokStr(aMainCfg,cDel,0)
		//Chamada do metodo de busca de listas de presentes
		MsAguarde({|| lRet := oWS:LJ845PESQC()},STR0028,STR0029, .T.)
		If ValType(lRet) == "L"
			If !lRet
				Lj845WSErr(cRotina)
				Return aRet
			Else
				If Len(oWS:oWSLJ845PESQCRESULT:oWSARETMOD) > 0 .AND. !Empty(oWS:oWSLJ845PESQCRESULT:oWSARETMOD[1]:cCRETORNO)
					For ni := 1 to Len(oWS:oWSLJ845PESQCRESULT:oWSARETMOD)
						aTMP := StrTokArr(oWS:oWSLJ845PESQCRESULT:oWSARETMOD[ni]:cCRETORNO,cDel)
						//Converter dados de acordo com o tipo de dado de cada campo utilizado
						aTMP := Lj845WSCon(aTMP,aHeader01,5)
						aAdd(aRet,aTMP)
					Next ni
				Endif
			Endif
		Else
			//Erro
			Return aRet
		Endif
	Endif
	If Len(aRet) == 0
		aDados01 := {Array(Len(aHeader01))}
	Else
		aDados01 := aClone(aRet)
	Endif
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845PesqCºAutor  ³Vendas Cliente        º Data ³28/02/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para consulta de listas de presentes.                      º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Filial de pesquisa                                     º±±
±±º          ³Exp02[C] : Numero da lista                                        º±±
±±º          ³Exp03[C] : Origem da lista                                        º±±
±±º          ³Exp04[C] : Status da lista                                        º±±
±±º          ³Exp05[A] : Lista de campos para pesquisa                          º±±
±±º          ³Exp06[A] : Array com os criterios de pesquisa                     º±±
±±º          ³Exp07[N] : Ordem de classificacao a ser utilizado                 º±±
±±º          ³Exp08[N] : Tratar valor de campos com combobox?                   º±±
±±º          ³Exp09[A] : Lista de configuracoes (apenas para webservice)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj845PesqC(cFil  ,aLstCmp,aFiltro,nOrdem,;
					lTCBox,aLCFG)

Local aRet				:= {}																//Array de retorno
Local cQry             	:= ""                                                              // Variavel para query da select
Local cAliasT			:= GetNextAlias()													// alias para Select
Local cAlias01			:= "ME1"                             								// area de trabalho
Local cAliasE			:= ""																//Alias de tabela estrangeira
Local ni				:= 0							  									//Contador
Local nx				:= 0							   									//Contador
Local nTotal			:= 0								  								//Totalizador
Local aAreaSX3			:= SX3->(GetArea())												// area do SX3
Local lTop				:= .T.                                                           	// Configura TOP
Local nCampos			:= 0                                                               	// Qtd campos no SX3
Local nPos				:= 0                                                               	// variavel de posicao na pesquisa de ascan
Local nPos02			:= 0                                                               	// variavel de posicao na pesquisa de ascan
Local aEstru			:= {}                                                              	// Array da estrutura da tabela
Local aContCUt			:= {}																//Contador de campos utilizados para montagem do criterio de pesquisa
Local cQryW				:= ""						 										//Criterios de pesquisa
Local cTMP				:= ""							 									//String temporaria
Local aRelTE			:= {{"SA1",{{"A1_COD","ME1_CODCLI"},{"A1_LOJA","ME1_LOJCLI"}}},;	//Relacionamento com a tabela estrangeira
							{"MEE",{{"MEE_CODLIS","ME1_CODIGO"}}}}
Local aLstCmpCB			:= {}																//Campos Combo
Local aCmpLiga			:= Array(2)													   		//Controle de campos de ligacao
Local aTMP				:= {}																//Array temporario
Local aMCFG				:= IIf(aLCFG == Nil,aClone(aMainCfg),aClone(aLCFG))				//Clone do array de configuracoes
Local cQryCFG			:= ""																//Restricoes provenientes do array de configuracoes
Local cRotina			:= "[LOJA845:LJ845PESQC] "											//Nome da rotina

Local POS_ALIAS		:= 1																//Posicao do ALIAS
Local POS_CMP			:= 2																//Posicao dos campos de relacionamento
Local POS_CMPR01		:= 2																//Primeiro campo de relacionamento (local)
Local POS_CMPR02		:= 1																//Segundo campo de relacionamento (estrangeiro)

Default cFil			:= "" 																// filial
Default aLstCmp			:= {}																// array campos da lista
Default aFiltro			:= {}																// filtro dos itens
Default nOrdem			:= 2																// Ordem do alias
Default lTCBox			:= .T.																//Tratar combobox
Default aLCFG			:= {}																//Lista de configuracoes (webservice)

#IFNDEF TOP
	lTop := !lTop
#ENDIF
If ValType(aLstCmp) # "A" .OR. Len(aLstCmp) == 0 .OR. !AliasInDic(cAlias01) .AND. !lTop
	Return aRet
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criando restricoes das configuracoes principais  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQryCFG := ""
If Len(aMCFG) > 0
	//Numero da lista
	If !Empty(aMCFG[POS_MNL])
		cQryCFG += "AND ME1.ME1_CODIGO = '" + PadR(aMCFG[POS_MNL],TamSX3("ME1_CODIGO")[1]) + "' "
	Endif
	//Origem da lista
	If !Empty(aMCFG[POS_MORI])
		cQryCFG += "AND ME1.ME1_ORIGEM = '" + PadR(aMCFG[POS_MORI],TamSX3("ME1_ORIGEM")[1]) + "' "
	Endif
	//Tipo de evento
	If !Empty(aMCFG[POS_MTPEVE])
		cQryCFG += "AND ME1.ME1_TPEVEN = '" + PadR(aMCFG[POS_MTPEVE],TamSX3("ME1_TPEVEN")[1]) + "' "
	Endif
	//Status da lista
	If !Empty(aMCFG[POS_MSTAT])
		cQryCFG += "AND ME1.ME1_STATUS = '" + PadR(aMCFG[POS_MSTAT],TamSX3("ME1_STATUS")[1]) + "' "
	Endif		
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao houver filtro definidos na configuracao principal e a  ³
//³lista de filtros estiver vazia, sair.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cQryCFG) .AND. (ValType(aFiltro) # "A" .OR. Len(aFiltro) == 0)
	Return aRet
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se necessario, levantar campos com valor de opcao (combobox)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTCBox
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	nTam := Len(SX3->X3_CAMPO)
	For ni := 1 to Len(aLstCmp)
		If SX3->(DbSeek(PadR(aLstCmp[ni],nTam)))
			If SX3->X3_TIPO == "C"
				If !Empty(cTMP := X3CBox())
					aAdd(aLstCmpCB,{aLstCmp[ni],RetSX3Box(cTMP,,,1)})
				Endif
			Endif
		Endif
	Next ni
Endif
cTMP := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento de filtro ³
//³---------------------³
//³ESTRUTURA aFiltro    ³
//³[1] ALIAS            ³
//³[2] CAMPO            ³
//³[3] CRITERIO         ³
//³[4] POSICAO LISTA    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Agrupar por tabela + campo
aSort(aFiltro,,,{|x,y| x[1] < y[1] .AND. x[2] < y[2]})
//Contar criterios utilizados por campo
For ni := 1 to Len(aFiltro)
	If (nPos := aScan(aContCUt,{|x| Upper(AllTrim(x[2])) == Upper(AllTrim(aFiltro[ni][2]))})) == 0
		aAdd(aContCUt,{aFiltro[ni][1],;	//Alias
						aFiltro[ni][2],;	//Campo
						"",;				//Armazenagem de criterio para tabelas estrangeiras
						1})					//Repeticao de uso
	Else
		aTail(aContCUt[nPos])++
	Endif
Next ni
//Montar filtro
nTotal := Len(aContCUt)
For ni := 1 to nTotal
	nEncont := 0
	lAliasEst := !(aContCUt[ni][1] == cAlias01)
	For nx := 1 to Len(aFiltro)
		If Upper(AllTrim(aContCUt[ni][2])) # Upper(AllTrim(aFiltro[nx][2]))
			Loop
		Endif
		nEncont++
		If (At("BETWEEN",aFiltro[nx][3]) > 0 .AND. aTail(aContCUt[ni]) == 1) .OR. aTail(aContCUt[ni]) == 1
			If !lAliasEst
				cQryW += aFiltro[nx][3]
			Else
				aContCUt[ni][3] += aFiltro[nx][3]
			Endif
		Else
			If nEncont == 1
				If !lAliasEst
					cQryW += "("
				Else
					aContCUt[ni][3] += "("
				Endif
			Endif
			If !lAliasEst
				cQryW += "(" + aFiltro[nx][3] + ")"
				If nEncont == aTail(aContCUt[ni])
					cQryW += ")"
				Else
					cQryW += " OR "
				Endif
			Else
				aContCUt[ni][3] += "(" + aFiltro[nx][3] + ")"
				If nEncont == aTail(aContCUt[ni])
					aContCUt[ni][3] += ")"
				Else
					aContCUt[ni][3] += " OR "
				Endif			
			Endif
		Endif
	Next nx
	If !lAliasEst .AND. ni < nTotal .AND. nTotal > 1
		cQryW += " AND "
	Endif
Next ni
If !Empty(cQryW) .AND. lAliasEst .AND. Right(RTrim(cQryW),3) == "AND"
	cQryW := Substr(cQryW,1,Len(cQryW) - 4)
Endif
cQryW += " "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar a existencia fisica das tabelas no banco de dados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !MsFile(RetSQLName(cAlias01),Nil,__cRDD)
	ChkFile(cAlias01)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao de variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cFil)
	cFil := xFilial(cAlias01) 
Endif
nCampos := Len(aLstCmp)
aEstru := (cAlias01)->(DbStruct())
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
//ÚÄÄÄÄÄÄÄ¿
//³Query  ³
//ÀÄÄÄÄÄÄÄÙ
cQry := "SELECT "
For ni := 1 to Len(aLstCmp)
	If SX3->(DbSeek(aLstCmp[ni]))
		cQry += cAlias01 + "." + AllTrim(aLstCmp[ni]) + ","
	Endif
Next ni
cQry := Substr(cQry,1,Len(cQry) - 1) + " "
cQry += "FROM " + RetSQLName(cAlias01) + " " + cAlias01 + " "
cQry += "WHERE " + RetSQLDel(cAlias01) + " AND ME1.ME1_FILIAL = '" + cFil + "' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando restricoes locais  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cQryW)
	cQry += "AND " + cQryW
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando restricoes das configuracoes principais  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cQryCFG)
	cQry += cQryCFG
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando restricoes estrangeiras  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aContCUt)
	//Caso seja tabela estrangeira                                                                               G
	If !(aContCUt[ni][1] == cAlias01)
		//Caso o relacionamento tenha sido declarado
		If (nPos := aScan(aRelTE,{|x| Upper(AllTrim(x[POS_ALIAS])) == Upper(AllTrim(aContCUt[ni][1]))})) > 0
			cAliasE := aRelTE[nPos][POS_ALIAS]
			aCmpLiga[1] := aRelTE[nPos][POS_CMP][1][POS_CMPR01]
			aCmpLiga[2] := aRelTE[nPos][POS_CMP][1][POS_CMPR02]
			//Montar clausula com subquery
			cTMP := "AND " + cAlias01 + "." + aCmpLiga[1] + " IN (SELECT " + cAliasE + "." + aCmpLiga[2] + " "
			cTMP += "FROM " + RetSQLName(cAliasE) + " " + cAliasE + " "
			cTMP += "WHERE " + RetSQLDel(cAliasE) + " AND " + cAliasE + "." + IIf(Substr(cAliasE,1,1) == "S",Right(cAliasE,2),cAliasE) + "_FILIAL = '" 
			cTMP +=	IIf(Empty(cFil),xFilial(cAliasE),cFil) + "' AND " + aContCUt[ni][3] + " "
			//Fazer o JOIN
			For nx := 1 to Len(aRelTE[nPos][2])
				cTMP += "AND " + cAliasE + "." + aRelTE[nPos][2][nx][POS_CMPR02] + " = " + cAlias01 + "." + aRelTE[nPos][2][nx][POS_CMPR01]
				cTMP += IIf(nx < Len(aRelTE[nPos][2]), " ", ") ")
			Next nx			
			//Confirmando
			cQry += cTMP
		Endif
	Endif
Next ni
cQry += "ORDER BY " + SqlOrder((cAlias01)->(IndexKey(nOrdem)))
DbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAliasT,.T.,.F.)
(cAliasT)->(DbGoTop())
AjustaTC(cAliasT,aEstru)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento dos resultados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasT)->(Eof())
	FechaArqT(cAliasT)
	ConOut(cRotina + STR0030)
	Return aRet
Endif
nPos := 0
While !(cAliasT)->(Eof())
	aAdd(aRet,Array(nCampos))
	nPos++
	For ni := 1 to nCampos
		If lTCBox
			If (nPos02 := aScan(aLstCmpCB,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aLstCmp[ni]))})) == 0
				aRet[nPos][ni] := (cAliasT)->(FieldGet(ni))
			Else
				aTMP := aLstCmpCB[nPos02][2]
				If (nPos02 := aScan(aTMP,{|x| x[2] == (cAliasT)->(FieldGet(ni))})) > 0
					If AllTrim((cAliasT)->(FieldName(ni))) == "ME1_TIPO"
						aRet[nPos][ni] := AllTrim(aTMP[nPos02][2]) // codigo do tipo da entrega
					Else
						aRet[nPos][ni] := AllTrim(aTMP[nPos02][3])
					EndIf
				Else
					aRet[nPos][ni] := (cAliasT)->(FieldGet(ni))
				Endif
			Endif
		Else
			aRet[nPos][ni] := (cAliasT)->(FieldGet(ni))
		Endif

		//Tratamento para exibir informação no campo ME1_DESCCL com o nome do organizador para facilitar a visualização da lista de presente
		If AllTrim((cAliasT)->(FieldName(ni))) == "ME1_DESCCL" .And. Empty(aRet[nPos][ni])
			aRet[nPos][ni] := Posicione('SA1',1,xFilial('SA1')+(cAliasT)->(FieldGet( (cAliasT)->(FieldPos("ME1_CODCLI")) ))+;
												(cAliasT)->(FieldGet( (cAliasT)->(FieldPos("ME1_LOJCLI")) )) ,'A1_NOME')
		EndIf
	Next ni
	(cAliasT)->(DbSkip())
End
FechaArqT(cAliasT)
RestArea(aAreaSX3)

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845PesqIºAutor  ³Vendas Cliente        º Data ³09/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para pesquisa,exibicao, selecao e edicao de itens da lista º±±
±±º          ³de presentes.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Numero da lista                                        º±±
±±º          ³Exp02[A] : Cabecalho de retorno da lista de presentes (ME1)       º±±
±±º          ³Exp03[A] : Itens de retorno da lista de prensentes (ME2)          º±±
±±º          ³Exp04[L] : Utiliza MDI?                                           º±±
±±º          ³Exp05[A] : Coordenadas da tela principal                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj845PesqI( cNumLst,aCabRet,aItRet,lMDI,;
							aTamTP)

Local lRet				:= .T.													//Controle de retorno
Local aCampos			:= {}													//Campos da tabela temporaria
Local aCamposBrw		:= {}													//Campos para browse
Local cAlias			:= GetNextAlias()
Local cArqTrab			:= ""													//Arquivo temporario
Local cChave			:= ""                                           		//Chave de pesquisa 
Local cMarca			:= "2e"                                          		//Marca item
Local lInverte			:= .F.                                           		//Inverte selecao
Local oArea				:= FWLayer():New()                               		//Area de trabalho
Local oArea02			:= FWLayer():New()                               		//Area de trabalho 02
Local oArea03			:= FWLayer():New()                               		//Area de trabalho 03
Local cTitulo			:= STR0031												//Titulo da janela a ser utilizada
Local aTamObj			:= Array(4)												//array com tam do objeto
Local cCoefDis			:= 0.005												//Coeficiente de reducao para distribuicao de objetos
Local nTotBot			:= 3													//Total de controles do tipo botao na tela
Local ni				:= 0													//Contador
Local nx				:= 0													//Contador 02
Local nPercUt			:= 0.9													//Percentual de utilizacao de tela
Local nQtdDispo			:= 0													//Controle de quantidade disponivel
Local nOpcA				:= 0													//Opcao de operacao da interface
Local aArea				:= {}													//array com alias 
Local aTabs				:= {"ME1","ME2","SB1","SX3","MED"}						//Lista de tabelas para controle de area
Local aTMP				:= {}													//Array temporaria
Local aTMP02			:= {}													//Array temporaria 02
Local aCmpAlter			:= {}													//Campos alteraveis na getdados
Local aEstru			:= {}													//array com estrutura da tabela
Local aHeader01			:= {}													//Cabecalho da GD de atores
Local cCmbBox			:= ""													//Controle de combobox
Local nPos				:= 0													//Posicionador
Local aCols01			:= {}													//Dados da GD de edicao de quantidade e modo de entrega
Local nUsado			:= 0													//Controle de campos utilizados
Local aLstCmp			:= {}													//Lista de campos da GD de edicao de quantidade e modo de entrega
Local lCmpAlter			:= .F.													//Existem campos alterados
Local aDados01			:= {}													//Array com retorno de dados da ME1
Local aDados02			:= {}													//Array com retorno de dados da ME2
Local aDados03			:= {}													//Array com retorno de dados da MED
Local lOnline			:= aMainCfg[POS_MONL]									//Pesquisa online
Local aLstC01			:= {}													//Lista de campos ME1
Local aLstC02			:= {}													//Lista de campos ME2
Local aLstC03			:= {}													//Lista de campos MED
Local lOk				:= .T.													//Controle de fluxo
Local cTMP				:= ""													//String temporaria
Local cCampo			:= ""													//Campo processado
Local cNomeComp			:= Space(TamSX3("L2_REVLPRE")[1])						//Nomes dos compradores
Local cMensComp			:= Space(TamSX3("L2_MSGLPRE")[1])						//Mensagem dos compradores
Local lExtra			:= .F.													//Aceita quantidades extras?
Local lListaItAb		:= .F.													//Listar apenas itens em aberto?
Local lTCBox			:= .T.													//Substituir valores de campos combobox
Local lNomPres			:= aMainCfg[POS_MLNOM]									//Nomes de presenteadores
Local lRet02			:= .F.													//Controle de retorno WS
Local cDel				:= "|"													//Delimitador WS
Local oWS				:= Nil													//Objeto webservice
Local cRotina			:= "[LOJA845:LJ845PESQI]"                        		//Nome rotina para WS
Local cSRVWS			:= ""													//Servidor de WS
Local cModoEnt			:= ""													//Modo de entrega
Local oTempTable		:= Nil 													//Objeto tabela temporaria 

//Objetos graficos
Local oDlg02																	//objeto dialog
Local oPainel																	//objeto do painel
Local oPainel02																	//objeto do segundo painel
Local oMarca																	//objeto de marca 
Local oBot01																	//Confirmar
Local oBot02																	//Fechar
Local oBot03																	//Pesquisar MED
Local oEtq01																	//objeto de tela
Local oEtq02																	//objeto de tela
Local oCont01																	//objeto de tela
Local oCont02																	//objeto de tela
Local cPTM				:= "@!"													//Formatacao para maiuscula

Local nTamCab			:= 8													//tamanho do cabec
Local nTamIt			:= 7													//tamanho do item
Local oSayCodBar		:= Nil													//objeto say codigo de barras
Local oGetCodBar		:= Nil													//objeto get codigo de barras
Local cGetCodBar		:= Space(TamSx3("B1_CODBAR")[1])						//variavel codigo de barras
Local cTpLst			:= ""													//descricao do tipo da lista

Default cNumLst			:= ""													//numero da lista
Default aCabRet			:= {}													//array dados do cabec
Default aItRet			:= {}													//array dados dos itens
Default lMDI			:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) 		//Verifica se acessou via SIGAMDI
Default aTamTP			:= {}													//array tamanho tela

//Armazenando dados da area de trabalho
For ni := 1 to Len(aTabs)
	aAdd(aArea,(aTabs[ni])->(GetArea()))
Next ni

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de Presentes                                      ³
//³Incluído DbSelectArea, para selecionar tabela ME2 e     ³
//³não gerar erro na Função RetTitle, que adiciona o título³
//³dos campos no array aCamposBrw.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ME2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do arquivo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aCampos,{"SEL"		,"C"	,2							,0})
aAdd(aCampos,{"ITEM"	,"C"	,TamSX3("ME2_ITEM")[1]		,0})
aAdd(aCampos,{"PROD"	,"C"	,TamSX3("ME2_PRODUT")[1]	,0})
aAdd(aCampos,{"DESCR"	,"C"	,TamSX3("ME2_DESCRI")[1]	,0})
If lUsaValUni
	aAdd(aCampos,{"VLR"		,"N"	,TamSX3("ME2_VALUNI")[1]	,TamSX3("ME2_VALUNI")[2]})
EndIf
aAdd(aCampos,{"UM"		,"C"	,TamSX3("ME2_UM")[1]		,0})
aAdd(aCampos,{"DISPO"	,"N"	,TamSX3("ME2_QTDSOL")[1]	,TamSX3("ME2_QTDSOL")[2]})
aAdd(aCampos,{"QTDE"	,"N"	,TamSX3("ME2_QTDSOL")[1]	,TamSX3("ME2_QTDSOL")[2]})
aAdd(aCampos,{"MODOENT"	,"C"	,30							,0})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura de campos para MsSelect  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aCamposBrw,{"SEL"		,,""						,""})
aAdd(aCamposBrw,{"ITEM"		,,RetTitle("ME2_ITEM")		,GetSX3Cache("ME2_ITEM","X3_PICTURE")})
aAdd(aCamposBrw,{"PROD"		,,RetTitle("ME2_PRODUT")	,GetSX3Cache("ME2_PRODUT","X3_PICTURE")})
aAdd(aCamposBrw,{"DESCR"		,,RetTitle("ME2_DESCRI")	,GetSX3Cache("ME2_DESCRI","X3_PICTURE")})
If lUsaValUni
	aAdd(aCamposBrw,{"VLR"		,,RetTitle("ME2_VALUNI")	,GetSX3Cache("ME2_VALUNI","X3_PICTURE")})
EndIf
aAdd(aCamposBrw,{"UM"		,,RetTitle("ME2_UM")		,GetSX3Cache("ME2_UM","X3_PICTURE")})
aAdd(aCamposBrw,{"DISPO"	,,STR0057					,GetSX3Cache("ME2_QTDSOL","X3_PICTURE")})   ///"Disponivel"
aAdd(aCamposBrw,{"QTDE"		,,STR0058					,GetSX3Cache("ME2_QTDSOL","X3_PICTURE")})   ///"Quantidade"
If !lOnline
	aAdd(aCamposBrw,{"MODOENT"	,,STR0059				,cPTM})   ///"Modo entrega"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando e indexando o arquivo temporario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqTrab := CriaTrab(Nil,.F.)
//Cria tabela temporaria
oTempTable := LjCrTmpTbl(cAlias, aCampos, {"ITEM"})
DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de campos ME1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek("ME1"))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "ME1"
	If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT # "V"
		aAdd(aLstC01,SX3->X3_CAMPO)
	Endif
	SX3->(DbSkip())
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de campos ME2  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DbSeek("ME2"))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "ME2"
	If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT # "V"	
		aAdd(aLstC02,SX3->X3_CAMPO)
	Endif
	SX3->(DbSkip())
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de campos MED  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SX3->(DbSeek("MED"))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "MED"
	If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT # "V"	
		aAdd(aLstC03,SX3->X3_CAMPO)
	Endif
	SX3->(DbSkip())
EndDo
lOk := .T.
If lOnline
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca de dados da ME1  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If Len(aDados01	 := Lj845RetD(xFilial("ME1"),"ME1","ME1.ME1_CODIGO = '" + cNumLst + "'",aLstC01,1,lTCBox)) == 0
		lOk := .F.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca de dados da ME2  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lOk
		If Len(aDados02 := Lj845RetD(xFilial("ME2"),"ME2","ME2.ME2_CODIGO = '" + cNumLst + "'",aLstC02,1,lTCBox)) == 0
			lOk := .F.
		Endif	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca de dados da MED  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lOk
		aDados03 := Lj845RetD(xFilial("MED"),"MED","",aLstC03,1,lTCBox)
	Endif
Else
	//Valida se o campo LG_WSSRV esta preenchido e alerta o usuario que a pesquisa nao vai retornar os dados da retaguarda
	If AllTrim(LjGetStation("WSSRV")) == ""
		MsgAlert(STR0065) //"O campo LG_WSSRV não esta preenchido e a pesquisa não retornará os dados desejados."
	EndIf

	cSRVWS := "http://" + AllTrim(LjGetStation("WSSRV")) + "/WSLOJA845.apw"
	oWS := WSWSLOJA845():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca de dados da ME1  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oWS:_URL 		:= cSRVWS
	oWS:cCEMP02		:= cEmpAnt
	oWS:cCFIL02		:= cFilAnt	
	oWS:cCALIAS01	:= "ME1"
	oWS:cCQRYW		:= "ME1.ME1_CODIGO = '" + cNumLst + "'"
	oWS:cCLSTCMP02	:= ArrTokStr(aLstC01,cDel,0)
	oWS:nNORDEM02	:= 1
	oWS:lLTCBOX02	:= lTCBox
	//Chamada do metodo de retorno de consulta
	lRet02 := oWS:LJ845RETD()
	If ValType(lRet02) == "L"
		If !lRet02
			Lj845WSErr(cRotina)
			lOk := .F.
		Else
			If Len(oWS:oWSLJ845RETDRESULT:oWSARETMOD) > 0 .AND. !Empty(oWS:oWSLJ845RETDRESULT:oWSARETMOD[1]:cCRETORNO)
				For ni := 1 to Len(oWS:oWSLJ845RETDRESULT:oWSARETMOD)
					aTMP := StrTokArr(oWS:oWSLJ845RETDRESULT:oWSARETMOD[ni]:cCRETORNO,cDel)
					//Converter dados de acordo com o tipo de dado de cada campo utilizado
					aTMP := Lj845WSCon(aTMP,aLstC01,0)
					aAdd(aDados01,aTMP)
				Next ni
			Endif
		Endif
	Else
		lOk := .F.
	Endif
	If lOk
		oWS:Reset()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca de dados da ME2  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		oWS:_URL 		:= cSRVWS
		oWS:cCEMP02		:= cEmpAnt
		oWS:cCFIL02		:= cFilAnt
		oWS:cCALIAS01	:= "ME2"
		oWS:cCQRYW		:= "ME2.ME2_CODIGO = '" + cNumLst + "'"
		oWS:cCLSTCMP02	:= ArrTokStr(aLstC02,cDel,0)
		oWS:nNORDEM02	:= 1
		oWS:lLTCBOX02	:= lTCBox
		//Chamada do metodo de retorno de consulta
		lRet02 := oWS:LJ845RETD()
		If ValType(lRet02) == "L"
			If !lRet02
				Lj845WSErr(cRotina)
				lOk := .F.
			Else
				If Len(oWS:oWSLJ845RETDRESULT:oWSARETMOD) > 0 .AND. !Empty(oWS:oWSLJ845RETDRESULT:oWSARETMOD[1]:cCRETORNO)
					For ni := 1 to Len(oWS:oWSLJ845RETDRESULT:oWSARETMOD)
						aTMP := StrTokArr(oWS:oWSLJ845RETDRESULT:oWSARETMOD[ni]:cCRETORNO,cDel)
						//Converter dados de acordo com o tipo de dado de cada campo utilizado
						aTMP := Lj845WSCon(aTMP,aLstC02,0)
						aAdd(aDados02,aTMP)
					Next ni
				Endif
			Endif
		Else
			lOk := .F.
		Endif
	Endif
	If lOk
		oWS:Reset()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca de dados da MED  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oWS:_URL 		:= cSRVWS
		oWS:cCEMP02		:= cEmpAnt
		oWS:cCFIL02		:= cFilAnt
		oWS:cCALIAS01	:= "MED"
		oWS:cCQRYW		:= ""
		oWS:cCLSTCMP02	:= ArrTokStr(aLstC03,cDel,0)
		oWS:nNORDEM02	:= 1
		oWS:lLTCBOX02	:= lTCBox
		//Chamada do metodo de retorno de consulta
		lRet02 := oWS:LJ845RETD()
		If ValType(lRet02) == "L"
			If !lRet02
				Lj845WSErr(cRotina)
			Else
				If Len(oWS:oWSLJ845RETDRESULT:oWSARETMOD) > 0 .AND. !Empty(oWS:oWSLJ845RETDRESULT:oWSARETMOD[1]:cCRETORNO)
					For ni := 1 to Len(oWS:oWSLJ845RETDRESULT:oWSARETMOD)
						aTMP := StrTokArr(oWS:oWSLJ845RETDRESULT:oWSARETMOD[ni]:cCRETORNO,cDel)
						//Converter dados de acordo com o tipo de dado de cada campo utilizado
						aTMP := Lj845WSCon(aTMP,aLstC03,0)
						aAdd(aDados03,aTMP)
					Next ni
				Endif
			Endif
		Endif
	Endif
Endif
//Caso os dados necessario nao existirem, sair
If !lOk
	//Restaurando a area de trabalho
	aEval(aArea,{|x| RestArea(x)})	
	Return !lRet	
Endif
lExtra := Lj845RetCol(2,"ME1_EXTRA",0,1,aLstC01,aDados01,.F.,lTCBox) == "1"
lListaItAb := aMainCfg[POS_MLITAB]
//Se estiver configurado para listar todos os itens, verificar se extras sao permitidos na lista, se nao for permitido bloquear a visualizacao de itens zerados
If !lListaItAb .AND. !lExtra
	lListItAb := .T.
Endif

//Recupera o tipo da lista
cTMP := Lj845RetCol(2,"ME1_TIPO",0,1,aLstC01,aDados01,.F.,lTCBox)
Do Case
	Case cTMP == "1" //Credito
		cModoEnt := STR0033
		cCmbBox := STR0034
	Case cTMP == "2" //Entrega
		cModoEnt := STR0035
		cCmbBox := STR0036
	Otherwise //Entrega programada
		cModoEnt := STR0035
		cCmbBox := STR0036
EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimentar arquivo temporario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aDados02)
	//Se de origem de comprador, saltar
	If Lj845RetCol(2,"ME2_ORIGEM",0,ni,aLstC02,aDados02,.F.,lTCBox) # "O"
		Loop
	Endif
	//Determinar quantidade disponivel
	nQtdDispo := Lj845RetCol(2,"ME2_QTDSOL",0,ni,aLstC02,aDados02,.F.) - Lj845RetCol(2,"ME2_QTDATE",0,ni,aLstC02,aDados02,.F.)
	If nQtdDispo > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do array de quantidades :  ³
		//³[01] Numero da lista                 ³
		//³[02] Item da lista                   ³
		//³[03] Quantidade utilizada            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aMainCfg[POS_MQTDU]) == "A" .AND. Len(aMainCfg[POS_MQTDU]) > 0
			For nx := 1 to Len(aMainCfg[POS_MQTDU])
				If Len(aMainCfg[POS_MQTDU][nx]) == 3
					If AllTrim(aMainCfg[POS_MQTDU][nx][1]) == AllTrim(cNumLst) .AND. AllTrim(aMainCfg[POS_MQTDU][nx][2]) == AllTrim(ME2->ME2_ITEM)
						If ValType(aTail(aMainCfg[POS_MQTDU][nx])) == "N" .AND. aTail(aMainCfg[POS_MQTDU][nx]) > 0
							nQtdDispo -= aTail(aMainCfg[POS_MQTDU][nx])
							Exit
						Endif
					Endif
				Endif
			Next nx
		Endif
	Endif
	If nQtdDispo < 0
		nQtdDispo := 0
	Endif
	//Somente itens em aberto
	If lListaItAb .AND. nQtdDispo <= 0
		Loop
	Endif
	
	RecLock(cAlias,.T.)
	(cAlias)->SEL 		:= Space(Len((cAlias)->SEL))
	(cAlias)->ITEM		:= Lj845RetCol(2,"ME2_ITEM",0,ni,aLstC02,aDados02,.F.)
	(cAlias)->PROD		:= Lj845RetCol(2,"ME2_PRODUT",0,ni,aLstC02,aDados02,.F.)
	(cAlias)->DESCR		:= Lj845RetCol(2,"ME2_DESCRI",0,ni,aLstC02,aDados02,.F.)
	If lUsaValUni
		(cAlias)->VLR		:= Lj845RetCol(2,"ME2_VALUNI",0,ni,aLstC02,aDados02,.F.)
	EndIf
	(cAlias)->UM			:= Lj845RetCol(2,"ME2_UM",0,ni,aLstC02,aDados02,.F.)
	(cAlias)->DISPO		:= nQtdDispo
	(cAlias)->QTDE		:= 1
	(cAlias)->MODOENT		:= cModoEnt
	MsUnlock()
Next ni
(cAlias)->(DbGoTop())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface 01 - Selecao de produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aTamTP)
	aTamTP[ni] := Int(aTamTP[ni] * nPercUt)
Next ni
DEFINE MSDIALOG oDlg02 TITLE cTitulo FROM aTamTP[1],aTamTP[2] TO aTamTP[3],aTamTP[4] OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
oArea:Init(oDlg02,!lMDI)
oArea:AddLine("L01",100,.T.)
oArea:AddCollumn("L01C01",100,.F.,"L01")
oArea:AddWindow("L01C01","L01C01P01",cTitulo,100,.F.,.F.,,"L01")
oPainel := oArea:GetWinPanel("L01C01","L01C01P01","L01")
//Dimensoes do objeto - MsSelect
aTamObj[1] := 000
aTamObj[2] := 000
aTamObj[3] := (oPainel:nClientWidth / 2)
aTamObj[4] := (oPainel:nClientHeight / 2) - ((nDistPad * 1) + nAltBot)
oMarca := MsSelect():New(cAlias,"SEL",,aCamposBrw,@lInverte,@cMarca,{aTamObj[1],aTamObj[2],aTamObj[4] - 25,aTamObj[3]},/*cTopFun*/,/*cBotFun*/,oPainel,,/*aColors*/)
oMarca:oBrowse:lCanAllmark := aMainCfg[POS_MMTOD]
oMarca:oBrowse:lHasMark = .T.
oMarca:bAval := {||	InverteSel(cAlias,1,cMarca,aMainCfg[POS_MMULT]),oMarca:oBrowse:Refresh(.T.)}
oMarca:oBrowse:bAllMark := {|| IIf(aMainCfg[POS_MMTOD],InverteSel(cAlias,2,cMarca),.T.),oMarca:oBrowse:Refresh(.T.)}

//Dimensoes do objeto - Botoes
aTamObj[1] := (oMarca:oBrowse:nBottom / 2) + nDistPad
aTamObj[2] := 000
aTamObj[3] := (oPainel:nClientWidth / 2) * ((1 - (cCoefDis * nTotBot)) / nTotBot)
aTamObj[4] := nAltBot

//Say Codigo de Barras
oSayCodBar := tSay():New(aTamObj[1], aTamObj[2], {|| "Código de Barras:"}, oPainel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 10)

//Get Codigo de Barras
oGetCodBar := TGet():New(aTamObj[1] + 10, aTamObj[2], {|u| If(PCount() > 0, cGetCodBar := u, cGetCodBar)}, oPainel,;								
								100, 10, "@!", { || .T. } ,,,,,,.T.,,, {|| },,,, .F.,,,)				

//Perda de foco do campo Codigo de Barras
oGetCodBar:bLostFocus := {|| IIF(Lj845CodBar(@cGetCodBar, oGetCodBar, cAlias),; 
										(InverteSel(cAlias, 1,, .T.), oMarca:oBrowse:Refresh(.T.)),;
										 Nil)}

//Botao - Incluir
oBot03 := tButton():New(aTamObj[1] + 25,aTamObj[2],cHK + STR0017,oPainel,{|| IIf(Lj845IncIt(cAlias,cMarca,cModoEnt),;
	Eval({|| Eval(oMarca:oBrowse:bGoBottom),Eval(oMarca:oBrowse:bGoTop),oMarca:oBrowse:Refresh()}),.T.)},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| lExtra})
//Botao - Confirmar
aTamObj[2] := (oBot03:nWidth / 2) + nDistPad
oBot01 := tButton():New(aTamObj[1] + 25,aTamObj[2],cHK + STR0037,oPainel,{|| oDlg02:End(),nOpcA := 1},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/)
//Botao - Fechar
aTamObj[2] := ((oBot01:nWidth + oBot01:nLeft) / 2) + nDistPad
oBot02 := tButton():New(aTamObj[1] + 25,aTamObj[2],cHK + STR0023,oPainel,{|| oDlg02:End()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/)
//Configuracoes e ativacao 
oDlg02:lMaximized := .F.
oDlg02:lCentered := .T.
oDlg02:Activate(,,,.T.,/*valid*/,,{|| oGetCodBar:SetFocus()})
nTotBot--
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcA == 1
	//Levantar estrutura
	aEstru := (cAlias)->(DbStruct())
	//Apagar registros nao marcados
	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())
		If !IsMark("SEL",cMarca)
			RecLock(cAlias,.F.)
			(cAlias)->(DbDelete())
			MsUnlock()
		Endif
		(cAlias)->(DbSkip())
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abrir interface com MsNewGetDados caso altere a quantidade ou unidade  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aMainCfg[POS_MAME] .OR. aMainCfg[POS_MLAQTD]
		nOpcA := 0
		(cAlias)->(DbGoTop())
		If aMainCfg[POS_MAME] .AND. aMainCfg[POS_MLAQTD]
			cTitulo := STR0038
			aCmpAlter := {"QTDE","MODOENT"}
		ElseIf aMainCfg[POS_MAME] .OR. !aMainCfg[POS_MLAQTD]
			cTitulo := STR0039
			aCmpAlter := {"MODOENT"}
		Else
			cTitulo := STR0040
			aCmpAlter := {"QTDE"}
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montar cabecalho  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ni := 1 to Len(aEstru)
			cCampo := Upper(AllTrim(aEstru[ni][1]))
			If cCampo $ "ITEM|PROD|DESC|UM|DISPO|QTDE|" + IIf(!lOnline,"MODOENT","") + iIf(lUsaValUni,"|VLR|","")
				aAdd(aLstCmp,cCampo)				
				//Cabecalho - Estrutura MsNewGetDados
				aAdd(aHeader01,{RTrim(aCamposBrw[ni][3]),;
								aEstru[ni][1],;
								aCamposBrw[ni][4],;
								aEstru[ni][3],;
								aEstru[ni][4],;
								/*X3_VALID*/,;
								/*X3_USADO*/,;
								aEstru[ni][2],;
								/*X3_F3*/,;
								/*X3_CONTEXT*/,;
								IIf(Upper(AllTrim(aEstru[ni][1])) == "MODOENT",cCmbBox,""),;
								/*X3_RELACAO*/,;
								/*X3_WHEN*/,;
								IIf(aScan(aCmpAlter,{|x| x == Upper(AllTrim(aEstru[ni][1]))}) == 0,"V",""),;
								/*X3_VLDUSER*/,;
								/*X3_PICTVAR*/,;
								/*X3_OBRIGAT*/})
			Endif
		Next ni	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alimentar informacoes  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols01 := Array(0)
		nUsado := Len(aHeader01)
		While !(cAlias)->(Eof())
			If (cAlias)->(Deleted())
				(cAlias)->(DbSkip())
				Loop
			Endif
			aAdd(aCols01,Array(nUsado + 1))
			nPos := Len(aCols01)
			If nPos > 0
				aTail(aCols01[nPos]) := .F.
				For ni := 1 to nUsado
					If Upper(AllTrim(aHeader01[ni][2])) == "MODOENT"
						aCols01[nPos][ni] := "1"
					Else
						aCols01[nPos][ni] := (cAlias)->(FieldGet(FieldPos(aHeader01[ni][2])))
					Endif
				Next ni
			EndIf
			(cAlias)->(DbSkip())
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface 02 - Definicao de quantidade e modo de entrega  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		DEFINE MSDIALOG oDlg02 TITLE cTitulo FROM aTamTP[1],aTamTP[2] TO aTamTP[3],aTamTP[4] OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
		oArea02:Init(oDlg02,!lMDI)
		oArea02:AddLine("L02",100,.T.)
		oArea02:AddCollumn("L02C01",100,.F.,"L02")
		oArea02:AddWindow("L02C01","L02C01P01",cTitulo,100,.F.,.F.,,"L02")
		oPainel := oArea02:GetWinPanel("L02C01","L02C01P01","L02")
		//Dimensoes do objeto - MsNewGetDados
		aTamObj[1] := 000
		aTamObj[2] := 000
		aTamObj[3] := (oPainel:nClientWidth / 2)
		aTamObj[4] := (oPainel:nClientHeight / 2) - ((nDistPad * 1) + nAltBot)		
		oGD01 := MsNewGetDados():New(aTamObj[1],aTamObj[2],aTamObj[4],aTamObj[3],GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",/*cIniPos*/,aCmpAlter,0,Len(aCols01),/*cFieldOk*/,"AllwaysFalse()","AllwaysFalse()",oPainel,@aHeader01,@aCols01)
		oGD01:lEditLine := .F.
		//Dimensoes do objeto - Botoes
		aTamObj[1] := (oGD01:oBrowse:nBottom / 2) + nDistPad
		aTamObj[2] := 000
		aTamObj[3] := (oPainel:nClientWidth / 2) * ((1 - (cCoefDis * nTotBot)) / nTotBot)
		aTamObj[4] := nAltBot
		//Botao - Confirmar
		oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0037,oPainel,{|| oDlg02:End(),nOpcA := 1},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/)
		//Botao - Fechar
		aTamObj[2] := (oBot01:nWidth / 2) + nDistPad
		oBot02 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0023,oPainel,{|| oDlg02:End()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/)
		//Configuracoes e ativacao 
		oDlg02:lMaximized := .F.
		oDlg02:lCentered := .T.
		oDlg02:Activate(,,,.T.,/*valid*/,,{|| oGD01:oBrowse:SetFocus()})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso confirmado, gravar alteracoes na tabela temporaria  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcA == 1		
			lCmpAlter := !lCmpAlter
			aCols01 := oGD01:aCols
			For ni := 1 to Len(aCols01)  
				If !Lj845VlQtd(oGD01,aCols01[ni][aScan(aHeader01,{|x| Upper(AllTrim(x[2])) == "QTDE"})],IIf(lExtra,"1","2"))
					MsgAlert (STR0064) //Quantidade informada superior ao disponível na lista			
					Return .F.
				EndIf
				cChave := aCols01[ni][aScan(aHeader01,{|x| Upper(AllTrim(x[2])) == "ITEM"})]
				If (cAlias)->(DbSeek(cChave))
					RecLock(cAlias,.F.)
					For nx := 1 to Len(aCmpAlter)
						If (nPos := aScan(aHeader01,{|x| Upper(AllTrim(x[2])) == Upper(AllTrim(aCmpAlter[nx]))})) > 0
							(cAlias)->&(aCmpAlter[nx]) := aCols01[ni][nPos]
						Endif
					Next nx
					(cAlias)->(MsUnlock())
				Endif
			Next ni
		Endif
    Endif
    
    If nOpcA == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envio de mensagem - compradores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Lj845RetCol(2,"ME1_ALERTA",0,1,aLstC01,aDados01,.F.,lTCBox) == "1"	
			If aMainCfg[POS_MLENVM]	 .AND. IIf(!lOnline,Len(aDados03) > 0,.T.)	//Parametro da funcao para enviar mensagem
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Sincronizar MED do PDV com o da retaguarda, se necessário  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aDados03) > 0
					DbSelectArea("MED")
					MED->(DbSetOrder(1))
					//Adicionar e alterar
					For ni := 1 to Len(aDados03)
						If MED->(DbSeek(xFilial("MED") + Lj845RetCol(2,"MED_CODIGO",0,ni,aLstC03,aDados03,.F.)))
							If PadR(AllTrim(MED->MED_DESCRI),TamSX3("MED_DESCRI")[1]) # ;
								PadR(AllTrim(Lj845RetCol(2,"MED_DESCRI",0,ni,aLstC03,aDados03,.F.)),TamSX3("MED_DESCRI")[1])
								If !Empty(Lj845RetCol(2,"MED_DESCRI",0,ni,aLstC03,aDados03,.F.)	) 
									RecLock("MED",.F.) 
									MED->MED_DESCRI := Lj845RetCol(2,"MED_DESCRI",0,ni,aLstC03,aDados03,.F.)
									MsUnlock()
								EndIf
							Endif
						Else
							RecLock("MED",.T.)
							MED->MED_FILIAL	:= xFilial("MED")
							MED->MED_CODIGO	:= Lj845RetCol(2,"MED_CODIGO",0,ni,aLstC03,aDados03,.F.)
							MED->MED_DESCRI	:= Lj845RetCol(2,"MED_DESCRI",0,ni,aLstC03,aDados03,.F.)
							MsUnlock()						
						Endif
					Next ni		
					//Remover codigos inexistentes
					If (nPos := Lj845RetCol(1,"MED_CODIGO",0,ni,aLstC03,aDados03,.F.)) > 0
						MED->(DbGoTop())
						While !MED->(Eof())
							If aScan(aDados03,{|x| AllTrim(x[nPos]) == AllTrim(MED->MED_CODIGO)}) == 0
								RecLock("MED",.F.)
								MED->(DbDelete())
								MsUnlock()
							Endif
							MED->(DbSkip())
						End
					Endif
				Endif
				If !lOnline
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Para ambiente offline, abrir apenas a consulta padrao do MED para a seleção da mensagem desejada  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					cTMP := ""
					If ConPad1(,,,"MEDC",/*cRet*/,,.F./*lOnlyView*/,/*Campo chamada*/,,/*Cont.Campo Antes Chamada*/)
						cMensComp := MED->MED_CODIGO
					Endif
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Interface 03 - Envio de mensagens  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTotBot++
					cTitulo := STR0041
					DEFINE MSDIALOG oDlg02 TITLE cTitulo FROM (aTamTP[1]* 0.5),(aTamTP[2]* 0.5) TO (aTamTP[3] * 0.5),(aTamTP[4] * 0.5) OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
					oArea03:Init(oDlg02,!lMDI)
					oArea03:AddLine("L01",100,.T.)
					oArea03:AddCollumn("L01C01",100,.F.,"L01")
					oArea03:AddWindow("L01C01","L01C01P01",cTitulo,100,.F.,.F.,,"L01")
					oPainel := oArea03:GetWinPanel("L01C01","L01C01P01","L01")
					//Nome dos compradores
					aTamObj[1] := 000
					aTamObj[2] := 000
					aTamObj[3] := (oPainel:nClientWidth / 2)
					aTamObj[4] := nAltCont
					oEtq01 	:= tSay():New(aTamObj[1],aTamObj[2],{|| STR0042},oPainel,/*pict*/,/*fonte*/,,,,.T.,,,aTamObj[3],aTamObj[4])
					aTamObj[1] += nAltCont
					oCont01 := tGet():New(aTamObj[1],aTamObj[2],{|x| If(PCount() > 0,cNomeComp := x,cNomeComp)},oPainel,aTamObj[3],aTamObj[4],cPTM,/*valid*/,;
						/*FColor*/,IIf(lNomPres,CLR_WHITE,CLR_HGRAY),/*font*/,,,.T.,,,{|| lNomPres}/*when*/,,,/*change*/,.F./*Read*/,.F./*Pwd*/,,"cNomeComp")
					//MENSAGEM
					aTamObj[1] += nAltCont + nDistAPad
					oEtq02 	:= tSay():New(aTamObj[1],aTamObj[2],{|| STR0043},oPainel,/*pict*/,/*fonte*/,,,,.T.,,,aTamObj[3],aTamObj[4])
					//Container para a mensagem (pois a borda nao aparece no objeto tMultiGet)
					aTamObj[1] += nAltCont
					aTamObj[4] := (oPainel:nClientHeight / 2) - (aTamObj[1] + nAltBot + nDistPad)
					oPainel02 := tPanel():New(aTamObj[1],aTamObj[2],"",oPainel,,,,,CLR_HGRAY,aTamObj[3],aTamObj[4])
	                //Caixa de mensagem
					aTamObj[1] := 001
					aTamObj[2] := 001
					aTamObj[3] := (oPainel02:nClientWidth / 2) * 0.99
					aTamObj[4] := (oPainel02:nClientHeight / 2) * 0.97								
					oCont02 := tMultiGet():New(aTamObj[1],aTamObj[2],{|x| If(PCount() > 0,cMensComp := x,cMensComp)},oPainel02,aTamObj[3],aTamObj[4],/*font*/,;
						.F./*HBar*/,/*FColor*/,/*BColor*/,,.T./*pixel*/,,,/*when*/,,,.F./*read*/,/*valid*/,,,.T./*NoBorda*/,.T./*VBar*/)
					oCont02:lWordWrap := .T.
					//Dimensoes do objeto - Botoes
					aTamObj[1] := (oPainel02:nBottom / 2) + nDistPad
					aTamObj[2] := 000
					aTamObj[3] := (oPainel:nClientWidth / 2) * ((1 - (cCoefDis * nTotBot)) / nTotBot)
					aTamObj[4] := nAltBot
					//Botao - Pesquisar
					oBot03 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0013,oPainel,;
						{|| IIf(ConPad1(,,,"MEDC",/*cRet*/,,.F.),Eval({|| cMensComp := MED->MED_DESCRI,oCont02:Refresh()}),.T.)},;
						aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/)
					//Botao - Confirmar
					aTamObj[2] += aTamObj[3] + nDistPad
					oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0037,oPainel,{|| oDlg02:End(),nOpcA := 1},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/)
					//Botao - Fechar
					aTamObj[2] += aTamObj[3] + nDistPad
					oBot02 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0023,oPainel,{|| oDlg02:End()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/)
					//Configuracoes e ativacao 
					oDlg02:lMaximized := .F.
					oDlg02:lCentered := .T.
					oDlg02:Activate(,,,.T.,/*valid*/,,{|| IIf(lNomPres,oCont01:SetFocus(),oCont02:SetFocus())})
					If nOpcA # 1
						cNomeComp	:= Space(TamSX3("L2_REVLPRE")[1])
						cMensComp	:= Space(TamSX3("L2_MSGLPRE")[1])
					Endif
				Endif
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizar itens de retorno  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		(cAlias)->(DbGoTop())
		While !(cAlias)->(Eof())
			If !(cAlias)->(Deleted())
				aTMP := Array(nTamIt)
				aTMP[1] := (cAlias)->ITEM
				aTMP[2] := (cAlias)->PROD
				aTMP[3] := (cAlias)->DISPO
				aTMP[4] := (cAlias)->QTDE
				If !lCmpAlter
					aTMP[5] := "1"
				Else
					aTMP02 := RetSX3Box(cCmbBox,,,1)
					If Len(AllTrim((cAlias)->MODOENT)) > 1 .AND. !IsDigit(Substr(AllTrim((cAlias)->MODOENT),1,1))
						aTMP[5] := aTMP02[aScan(aTMP02,{|x| Upper(AllTrim(x[3])) == Upper(AllTrim((cAlias)->MODOENT))})][2]
					Endif
				Endif
				aTMP[6] := PadR(cNomeComp,TamSX3("L2_REVLPRE")[1])
				aTMP[7] := PadR(cMensComp,TamSX3("L2_MSGLPRE")[1])
				aAdd(aItRet,aTMP)
			Endif
			(cAlias)->(DbSkip())
		End	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizar cabecalho de retorno  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cValToChar(aMainCfg[POS_MRET]) $ "1|3"
			aCabRet := Array(nTamCab)
			aCabRet[1] := Lj845RetCol(2,"ME1_CODIGO",0,1,aLstC01,aDados01,.F.)							//Codigo
			aCabRet[2] := Lj845RetCol(2,"ME1_TIPO",0,1,aLstC01,aDados01,.F.,lTCBox)						//Tipo da lista
			aCabRet[3] := Lj845RetCol(2,"ME1_TPEVEN",0,1,aLstC01,aDados01,.F.)							//Tipo do evento
			aCabRet[4] := Lj845RetCol(2,"ME1_EMISSA",0,1,aLstC01,aDados01,.F.)							//Emissao
			aCabRet[5] := Lj845RetCol(2,"ME1_DTEVEN",0,1,aLstC01,aDados01,.F.)							//Data do evento
			aCabRet[6] := Lj845RetCol(2,"ME1_CONTAT",0,1,aLstC01,aDados01,.F.)							//Contato
			aCabRet[7] := Lj845RetCol(2,"ME1_STATUS",0,1,aLstC01,aDados01,.F.,lTCBox)					//Status
			aCabRet[8] := Lj845RetCol(2,"ME1_DTVAL",0,1,aLstC01,aDados01,.F.)							//Validade
		Endif

		If lRet
			cTpLst := Lj845RetCol(2,"ME1_TIPO",0,1,aLstC01,aDados01,.F.,.F.)							//Nome do tipo da lista
			MsgInfo(STR0072 + cTpLst + STR0073,STR0074) //#"Item(ns) do tipo '" ##"' adicionado(s) na venda." ###"Atenção"
		Endif
	Else
		lRet := !lRet
	EndIf
Else
	lRet := !lRet
Endif
//Restaurando a area de trabalho
aEval(aArea,{|x| RestArea(x)})	

If( ValType(oTempTable) == "O")
  oTempTable:Delete()
  FreeObj(oTempTable)
  oTempTable := Nil
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InverteSel ºAutor  ³Vendas Clientes       º Data ³  14/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para inversao de selecao.                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InverteSel(cAlias,nOpc,cMarca,lMultiSel)

Local nPosREG		:= (cAlias)->(Recno())			// registro posicionado na tabela
Local lVarre		:= .F.							// verufuca varredura na tabela

Default cAlias		:= ""							//alias de trabalho
Default nOpc		:= 2							//opcao a executar
Default cMarca		:= "2e"							//marca atualizacao
Default lMultiSel	:= .F.							// multi selecao

Do Case
	Case nOpc == 1
		RecLock(cAlias,.F.) 
		If !IsMark("SEL",cMarca)
			(cAlias)->SEL := cMarca	
			lVarre := .T.
		Else
			(cAlias)->SEL := Space(Len((cAlias)->SEL))
		Endif
		MsUnlock(cAlias)
		If !lMultiSel .AND. lVarre
			(cAlias)->(DbGoTop())
			While !(cAlias)->(Eof())
				If (cAlias)->(Recno()) # nPosREG .AND. IsMark("SEL",cMarca)
					RecLock(cAlias,.F.)
					(cAlias)->SEL := Space(Len((cAlias)->SEL))
					MsUnlock(cAlias)
				Endif
				(cAlias)->(DbSkip())
			End
			(cAlias)->(DbGoTo(nPosREG))		
		Endif
	Otherwise
		(cAlias)->(DbGoTop())
		While !(cAlias)->(Eof())
			RecLock(cAlias,.F.)
			If !IsMark("SEL",cMarca)
				(cAlias)->SEL := cMarca
			Else 
				(cAlias)->SEL := Space(Len((cAlias)->SEL))
			Endif          
			MsUnlock(cAlias)
			(cAlias)->(DbSkip())
		End
		(cAlias)->(DbGoTo(nPosREG))
EndCase

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845Pict ºAutor  ³Vendas Cliente        º Data ³28/02/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para retornar mascara de formatacao e incializacao de      º±±
±±º          ³campos de acordo com o seu tipo de dados.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[N] : Modo operacao 1. Picture 2. Inicializacao              º±±
±±º          ³Exp02[N] : Posicao da combo de tipos de filtros                   º±±
±±º          ³Exp03[C] : Dados da lista de filtros                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj845Pict(nModo,nOpcFiltro,aLstOpcCmp)

Local cPict            	:= "" 						// mascara do campo
Local cBaseHex			:= "A"						// base hexadec
Local cTipo				:= ""						// tipo campo

Default nModo			:= 1						// modo de manipulacao
Default nOpcFiltro		:= 0						// opcao de filtro
Default aLstOpcCmp		:= {}						// array com campos lista

Do Case
	Case nModo == 1
		cPict := "@!"
	Otherwise
		cPict := Space(250)
EndCase
If Empty(nOpcFiltro) .OR. ValType(aLstOpcCmp) == "U" .OR. Len(aLstOpcCmp) == 0
	Return cPict
Endif
//Tratamento da posicao passada
nOpcFiltro := AllToChar(nOpcFiltro)
If IsAlpha(nOpcFiltro)
	nOpcFiltro := Upper(nOpcFiltro)
	nOpcFiltro := Asc(cBaseHex) - (Asc(nOpcFiltro) - Asc(cBaseHex))
Else
	nOpcFiltro := Val(nOpcFiltro)
Endif
If nOpcFiltro > Len(aLstOpcCmp)
	Return cPict
Endif
Do Case
	Case nModo == 1
		If Empty(cPict := GetSX3Cache(aLstOpcCmp[nOpcFiltro],"X3_PICTURE"))
			cPict := "@!"	
		Endif
	Otherwise
		cTipo := GetSX3Cache(aLstOpcCmp[nOpcFiltro],"X3_TIPO")
		Do Case
			Case cTipo == "D"
				cPict := CtoD("")
			Case cTipo == "N"
				cPict := 0
			Otherwise
				cPict := Space(250)
		EndCase
EndCase

Return cPict




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845LBAddºAutor  ³Vendas Cliente        º Data ³01/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para adicionar elementos aos filtros de pesquisa de listas º±±
±±º          ³de presente.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Descricao do filtro                                    º±±
±±º          ³Exp02[C] : Campo de pesquisa                                      º±±
±±º          ³Exp03[C] : Filtro digitado                                        º±±
±±º          ³Exp04[A] : Array de filtros utilizados                            º±±
±±º          ³Exp05[O] : Objeto de destino (listbox)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj845LBAdd( cCmp,cCmpF,cFiltro,aLstFilC,;
							oCont)

Local lRet			:= .T.					//Variavel de retorno
Local cCriterio		:= ""					//criterio de manipulacao
Local ni			:= 0					//contagem do FOR

Default cCmp		:= ""					//campos
Default cCmpF		:= ""					//campos
Default cFiltro		:= ""					//filtro
Default aLstFilC	:= {}					//array lista
Default oCont		:= NILL					//objeto da lista
						                                     
If Empty(cCmp) .OR. Empty(cCmpF) .OR. Empty(cFiltro) .OR. ValType(aLstFilC) # "A" .OR. ValType(oCont) # "O"
	Return !lRet
Endif
//Adicionar ao array de controle
If Empty(cCriterio := LjQryCrit(cCmpF,,cFiltro))
	Return !lRet
Endif
For ni := 1 to Len(aLstFilC)
	If PadR(Upper(RTrim(aLstFilC[ni][3])),nNumCols) == PadR(Upper(RTrim(cCriterio)),nNumCols)
		MsgAlert(STR0044)
		Return !lRet
	Endif
Next ni
//Adicionar item ao listbox
oCont:Add(Substr(cCmp,3,Len(cCmp)) + " = " + cFiltro)
//Atualizar a lista de filtros
aAdd(aLstFilC,{GetSX3Cache(cCmpF,"X3_ARQUIVO"),;	//Alias
				cCmpF,;								//Nome do campo
				cCriterio,;							//Criterio de pesquisa
				Len(oCont:aItems)})				//Posicao na lista de pesquisa
//Atualizar objeto
oCont:Refresh()

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjQryCrit ºAutor  ³Vendas Cliente        º Data ³01/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para montagem das clausulas de pesquisa                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Descricao do filtro                                    º±±
±±º          ³Exp02[C] : Campo de pesquisa                                      º±±
±±º          ³Exp03[C] : Filtro digitado                                        º±±
±±º          ³Exp04[A] : Array de filtros utilizados                            º±±
±±º          ³Exp05[O] : Objeto de destino (listbox)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjQryCrit( cCampo ,cTipo,cCriterio,cOpConj,;
					cOpDisj,lFrmtTC)

Local aAreaSX2		:= SX2->(GetArea())				// area dos campos
Local cRet			:= ""								// retorno da funcao
Local ni			:= 0								// contador do FOR
Local nx			:= 0								// contador do FOR
Local aLstCri		:= {}								// array da lista
Local nPos			:= 1								// posicao do ascan
Local cCarac		:= ""								// criterios
Local cTMP			:= ""								// temporario
Local nTam			:= 0								// tamanho 
Local cAlias		:= ""								// area de trabalho
Local aLstUNQ		:= {}								//Lista de campos de chave unica da tabela
                                                        	
Default cCampo		:= ""                              // campo manipulado
Default cTipo		:= ""                              // tipo do campo
Default cCriterio	:= ""                              // criterio
Default cOpConj		:= "+"                             // opcao para pesquisa
Default cOpDisj		:= "^"                             // opcao para pesquisa
Default lFrmtTC		:= .F.                            // opcao para pesquisa

If Empty(cCampo) .OR. Empty(cCriterio)
	Return cRet
Endif
If Empty(cTipo)
	If Empty(cTipo := GetSX3Cache(cCampo,"X3_TIPO"))
		Return cRet
	Endif
Endif
//Tamanho do campo
nTam 	:= GetSX3Cache(cCampo,"X3_TAMANHO")
cAlias 	:= GetSX3Cache(cCampo,"X3_ARQUIVO")
//Levantar campos da chave unica (que permitem que um campo chave pode ser pequisado por intervalo)
If cTipo == "C"
	aLstUNQ := StrTokArr(FWX2Unico(cAlias),"+")
Endif
//Montar array de criterios : [1]CAMPO [2]VALOR [3]OPERADOR
aAdd(aLstCri,{cCampo,"",""})
For ni := 1 to Len(cCriterio)
	cCarac := Substr(cCriterio,ni,1)
	Do Case 
		Case cCarac == cOpConj
			aTail(aLstCri[nPos]) := "AND"
			aAdd(aLstCri,{cCampo,"",""})
			nPos++
		Case cCarac == cOpDisj
			aTail(aLstCri[nPos]) := "OR"
			aAdd(aLstCri,{cCampo,"",""})
			nPos++
		Otherwise
			Do Case
				Case cTipo == "D"
					If !IsDigit(cCarac) .AND. !cCarac $ "/ "
						MsgAlert(STR0045)
						RestArea(aAreaSX2)
						Return cRet
					Endif
					aLstCri[nPos][2] += cCarac
				Otherwise
					aLstCri[nPos][2] += cCarac
			EndCase
	EndCase
Next ni
//Em caso de data, limitar a dois criterios (intervalo)
If cTipo == "D" .AND. Len(aLstCri) > 2
	nx := 0
	For ni := 3 to Len(aLstCri)
		aDel(aLstCri,ni)
		nx++
	Next ni
	aSize(aLstCri,Len(aLstCri) - nx)
Endif
//Caso existam mais de 02 criterios, descaracteriza um intervalo, zerar aLstUNQ
If cTipo == "C" .AND. Len(aLstCri) # 2 .AND. Len(aLstUNQ) > 0
	aLstUNQ := Array(0)
Endif
//Montar a expressao
For ni := 1 to Len(aLstCri)
	//Ajustar o tamanho do criterio de acordo com o tamanho do campo
	If cTipo $ "C|M" 
		If lFrmtTC .AND. !Empty(nTam)
			aLstCri[ni][2] := PadR(Substr(aLstCri[ni][2],1,nTam),nTam)
		Else
			If !Empty(nTam)
				aLstCri[ni][2] := Substr(RTrim(aLstCri[ni][2]),1,nTam)
			Else
				aLstCri[ni][2] := RTrim(aLstCri[ni][2])
			Endif
		Endif
	Endif	
	Do Case
		Case cTipo $ "C|M"
			If !Empty(aLstCri[ni])
				If ni > 1
					If Empty(aTail(aLstCri[ni - 1]))
						aTail(aLstCri[ni - 1]) := "+"
						cTMP += " AND "
					Else
						cTMP += " " + aTail(aLstCri[ni - 1]) + " "
					Endif
				Endif
				If Len(aLstUNQ) == 0 .OR. aScan(aLstUNQ,{|x| Upper(AllTrim(x)) ==  Upper(AllTrim(cCampo))}) == 0
					//Caso nao seja pesquisa de intervalo ou o campo nao faca parte da chave unica para pesquisa de intervalo
					If Len(aLstCri[ni][2]) == nTam
						cTMP += cAlias + "." + cCampo + " = '" + aLstCri[ni][2] + "'"
					Else
						cTMP += cAlias + "." + cCampo + " LIKE '%" + aLstCri[ni][2] + "%'"
					Endif
				Else
					//Caso seja pesquisa de intervalo
					If ni == 1
						If AllTrim(aTail(aLstCri[ni])) == "AND"
							cTMP += cAlias + "." + cCampo + " BETWEEN '" + PadR(aLstCri[ni][2],nTam) + "'"
						Else
							cTMP += cAlias + "." + cCampo + " = '" + PadR(aLstCri[ni][2],nTam) + "'"
						Endif
					Else
						If AllTrim(aTail(aLstCri[ni - 1])) == "AND"
							cTMP += "'" + PadR(aLstCri[ni][2],nTam) + "'"
						Else
							cTMP += cAlias + "." + cCampo + " = '" + PadR(aLstCri[ni][2],nTam) + "'"
						Endif
					Endif					
				Endif
			Endif
		Case cTipo == "D"
			If Empty(CtoD(aLstCri[ni][2]))
				MsgAlert(STR0045)
				RestArea(aAreaSX2)
				Return cRet
			Endif
			If !Empty(aLstCri[ni][2])
				If ni > 1
					If Empty(aTail(aLstCri[ni - 1]))
						aTail(aLstCri[ni - 1]) := "+"
						cTMP += " AND "
					Else
						cTMP += " " + aTail(aLstCri[ni - 1]) + " "
					Endif
				Endif
				If Len(aLstCri) == 1
					cTMP += cAlias + "." + cCampo + " = '" + DtoS(CtoD(aLstCri[ni][2])) + "'"
				Else
					If ni == 1
						If AllTrim(aTail(aLstCri[ni])) == "AND"
							cTMP += cAlias + "." + cCampo + " BETWEEN '" + DtoS(CtoD(aLstCri[ni][2])) + "'"
						Else
							cTMP += cAlias + "." + cCampo + " = '" + DtoS(CtoD(aLstCri[ni][2])) + "'"
						Endif
					Else
						If AllTrim(aTail(aLstCri[ni - 1])) == "AND"
							cTMP += "'" + DtoS(CtoD(aLstCri[ni][2])) + "'"
						Else
							cTMP += cAlias + "." + cCampo + " = '" + DtoS(CtoD(aLstCri[ni][2])) + "'"
						Endif
					Endif
				Endif
			Endif		
		Case cTipo == "N"
			If !Empty(aLstCri[ni])
				//Validar conteudo
				lOk := .T.
				For nx := 1 to Len(aLstCri[ni])
					If !Substr(aLstCri[ni],ni,1) $ "0123456789,.+-"
						lOk := .F.
					Endif
				Next nx
				//Se tudo ok, montar expressao
				If lOk
					If ni > 1
						If Empty(aTail(aLstCri[ni - 1]))
							aTail(aLstCri[ni - 1]) := "+"
							cTMP += " AND "
						Else
							cTMP += " " + aTail(aLstCri[ni - 1]) + " "
						Endif
					Endif
					cTMP += cAlias + "." + cCampo + " = " + cValToChar(GetDToVal(aLstCri[ni][2]))
				Endif
			Endif
	EndCase
Next ni
cRet := cTMP
RestArea(aAreaSX2)

Return cRet





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845LBExcºAutor  ³Vendas Cliente        º Data ³01/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para adicionar elementos aos filtros de pesquisa de listas º±±
±±º          ³de presente.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Descricao do filtro                                    º±±
±±º          ³Exp02[C] : Campo de pesquisa                                      º±±
±±º          ³Exp03[C] : Filtro digitado                                        º±±
±±º          ³Exp04[A] : Array de filtros utilizados                            º±±
±±º          ³Exp05[O] : Objeto de destino (listbox)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj845LBExc(oObj,nPos,aLstFilC)

Local lRet			:= .T.				 //variavel de retorn
Local lAtLista		:= .T.              //alteracao na lista
Local ni			:= 0                //contagem do for
Local nPos02		:= 0                //posicao do campo

Default nPos		:= 0				//posicao do campo
Default aLstFilC	:= {}              //array de lista
Default oObj		:= NILL            //objeto da lista

If Empty(nPos) .OR. ValType(aLstFilC) # "A" .OR. Len(aLstFilC) == 0
	Return !lRet
Endif
If oObj == Nil
	lAtLista := !lAtLista
Endif
//Remover item da lista de filtros
If nPos > Len(aLstFilC)
	Return !lRet
Endif
If (nPos02 := aScan(aLstFilC,{|x| aTail(x) == nPos})) > 0
	aDel(aLstFilC,nPos02)
	aSize(aLstFilC,Len(aLstFilC) - 1)
Else
	Return !lRet
Endif
//Reordenar posicao da lista
If Len(aLstFilC) > 0
	For ni := 1 to Len(aLstFilC)
		If aTail(aLstFilC[ni]) > nPos
			aTail(aLstFilC[ni])--
		Endif
	Next ni
Endif
//Atualizar lista
If lAtLista
	//Apagar registro
	oObj:Del(nPos)	
	//Reposicionar
	If oObj:Len() > 1
		oObj:nAt := 1
		oObj:Select(1)
	Endif
Endif

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaTC  ºAutor  ³Vendas Clientes       º Data ³28/02/11     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alterar o tipo de dados de campos criados por querys de acordoº±±
±±º          ³com o seu tipo de dados declarado no dicionario.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaTC(cAlias,aEstru)

Local ni		:= 0			//contagem do for
Local nPos		:= 0			// posicao do campo

Default cAlias	:= ""			//area de trabalho
Default aEstru	:= {}			//array de estrutura da tabela

If Empty(cAlias) .OR. ValType(aEstru) # "A" .OR. Len(aEstru) == 0
	Return Nil
Endif
For ni := 1 to (cAlias)->(FCount())
	If (nPos := aScan(aEstru,{|x| AllTrim(x[1]) == AllTrim((cAlias)->(FieldName(ni)))})) # 0
		If aEstru[nPos][2] # "C" .AND. aEstru[nPos][2] # "M"
			TcSetField(cAlias,aEstru[nPos][1],aEstru[nPos][2],aEstru[nPos][3],aEstru[nPos][4])
		Endif
	Endif
Next ni

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VerErro    ºAutor  ³Vendas Clientes       º Data ³02/03/11     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento de erro                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerErro(e,lErro,cErro)

Local lRet 		:= .F.				//Retorno

Default e		:= NIL				// objeto do erro
Default lErro	:= .F.				// trata erro
Default cErro	:= ""				// mensagem do erro

If e:Gencode > 0  
    cErro += "Descrição : " + e:Description + CRLF
    cErro += e:ErrorStack
    lErro := .T.
	lRet := .T.
	Break
EndIf

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845RetColºAutor  ³Vendas Cliente       º Data ³03/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para retornar posicao de campo ou o seu valor dentro do    º±±
±±º          ³seu cabecalho ou lista de dados correspondente.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[N] : Opcao 1. Posicao cabecalho 2. Dados                    º±±
±±º          ³Exp02[C] : Campo alvo                                             º±±
±±º          ³Exp03[N] : Posicao do X3_CAMPO no array de cabecalho              º±±
±±º          ³Exp04[N] : Posicao da linha na lista (GD)                         º±±
±±º          ³Exp05[A] : Array de cabecalho                                     º±±
±±º          ³Exp06[A] : Array de dados da lista (GD)                           º±±
±±º          ³Exp07[A] : Array de dados utiliza legenda na primeira coluna?     º±±
±±º          ³Exp08[L] : Retornar o valor de um campo alimentado com o valor    º±±
±±º          ³           de opcao de combobox                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj845RetCol(nOpc,cTarget,nPosN,nPosL,;
							aHead,aDados,lLegen,lTCBox)

Local uRet				:= ""		//retorno da funcao
Local nPos				:= 0		//posicionamento do campo
Local nDesloca			:= 0		//deslocamento
Local cTMP				:= ""		// temporario

Default nOpc			:= 1		//opcao de manipulacao
Default nPosN			:= 2		//posicao do campo
Default lLegen			:= .T.		//exibe legenda
Default lTCBox			:= .F.		//exibe box
Default cTarget         := ""
Default nPosL           := 0
Default aHead           := {}
Default aDados          := {}

Do Case
	Case nOpc == 1
		uRet := 0
	Otherwise
		uRet := ""
EndCase
If ValType(aHead) # "A" .OR. Len(aHead) == 0 .OR. ValType(aDados) # "A" .OR. Empty(cTarget) .OR. Empty(nPosL)
	Return uRet
Else
	//Se a opcao for de retorno de dado e o array de dados estiver vazio, sair
	If nOpc == 2 .AND. Len(aDados) == 0 
		Return uRet
	Endif
Endif
If lLegen
	nDesloca := 1
Endif
Do Case
	Case nOpc == 1
		If nPosN == 0
			uRet := aScan(aHead,{|x| Upper(AllTrim(x)) == Upper(AllTrim(cTarget))})
		Else
			uRet := aScan(aHead,{|x| Upper(AllTrim(x[nPosN])) == Upper(AllTrim(cTarget))})
		Endif
	Case nOpc == 2
		If nPosN == 0
			nPos := aScan(aHead,{|x| Upper(AllTrim(x)) == Upper(AllTrim(cTarget))})
		Else
			nPos := aScan(aHead,{|x| Upper(AllTrim(x[nPosN])) == Upper(AllTrim(cTarget))})
		Endif
		If nPos > 0
			If (uRet := aDados[nPosL][nPos + nDesloca]) == Nil
				uRet := ""
			Endif
		Endif
		//Caso se deseje retornar o valor original de um campo alimentado com os valores da combobox
		If lTCBox .AND. ValType(uRet) == "C" .AND. !Empty(uRet)
			If !Empty(cTMP := Lj845OpCmb(cTarget,uRet))
				uRet := cTMP
			Endif
		Endif
EndCase

Return uRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845AbLstºAutor  ³Vendas Cliente        º Data ³22/02/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para abrir lista de dados de tabelas relacionadas a lista  º±±
±±º          ³de presentes.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[N] : Opcao de pesquisa                                      º±±
±±º          ³Exp02[L] : Online                                                 º±±
±±º          ³Exp03[C] :                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj845AbLst( nOpc,lOnline,cTipo,cNumLst,;
							lMDI)

Local lRet				:= .T.													// retorno da funcao
Local cAlias			:= ""													// area de trabalho
Local oArea				:= FWLayer():New()                                     //Area de trabalho
Local aLstCmp			:= {}													//Lista de campos
Local aLstCmpNL			:= {"MEH_CODLIS","MEE_CODLIS"}							//Lista de campos para nao listar
Local aHeader01			:= {}													//Cabecalho da GD 
Local aDados01			:= {}													//Dados da GD 
Local aTamObj			:= Array(4)				 								//Dimensoes do objeto
Local cCoefDis			:= 0.003												//Coeficiente de reducao para distribuicao de objetos
Local cTitulo			:= ""													//Titulo da janela a ser utilizada
Local aTMP				:= {}													//Array temporaria
Local lRet02			:= .F.													//Controle de retorno WS
Local cDel				:= "|"													//Delimitador WS
Local oWS				:= Nil													//Objeto webservice
Local cRotina			:= "[LOJA845:LJ845PESQI]"                              	//Nome rotina para WS
Local cSRVWS			:= ""													//Servidor de WS
Local ni				:= 0													//Contador

Local oDlg02																	//Variaveis de objeto de interface
Local oPainel																	//Variaveis de objeto de interface
Local oGD02																		//Variaveis de objeto de interface
Local oBot01																	//Variaveis de objeto de interface

Local nTotBot			:= 1													//Total de controles do tipo botao na tela

Default nOpc			:= 1													//parametros de manipulacao
Default lOnline			:= .T.													//parametros de manipulacao
Default cTipo			:= ""													//parametros de manipulacao
Default cNumLst			:= ""													//parametros de manipulacao
Default lMDI			:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) 		//Verifica se acessou via SIGAMDI

Do Case 
	Case nOpc == 1
		cAlias := "MEH"	//Entregas programada
		cTitulo := STR0046
		//Pesquisar se a lista alvo eh do tipo de entrega programada
		If AllTrim(Lj845OpCmb("ME1_TIPO",cTipo)) # "3"
			MsgAlert(STR0047)
			Return !lRet
		Endif
	Case nOpc == 2
		cAlias := "MEE"	//Atores
		cTitulo := STR0048
	Otherwise
		Return !lRet
EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de campos e dados da GD  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias
	If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. aScan(aLstCmpNL,{|x| x == Upper(AllTrim(SX3->X3_CAMPO))}) == 0 .AND. ;
		SX3->X3_CONTEXT # "V"
	
		aAdd(aLstCmp,SX3->X3_CAMPO)
		//Cabecalho para a GD de lista
		aAdd(aHeader01,{SX3->X3_CAMPO,SX3->X3_PICTURE,AllTrim(X3Titulo()),SX3->X3_TAMANHO,SX3->X3_TIPO})		
	Endif
	SX3->(DbSkip())
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montar a lista de dados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOnline
	Do Case 
		Case nOpc == 1
			aDados01 := Lj845RetD(xFilial(cAlias),cAlias,"MEH.MEH_CODLIS = '" + cNumLst + "'",aLstCmp,1,.T.)
		Case nOpc == 2
			aDados01 := Lj845RetD(xFilial(cAlias),cAlias,"MEE.MEE_CODLIS = '" + cNumLst + "'",aLstCmp,1,.T.)
	End Case
Else
	//Valida se o campo LG_WSSRV esta preenchido e alerta o usuario que a pesquisa nao vai retornar os dados da retaguarda
	If AllTrim(LjGetStation("WSSRV")) == ""
		MsgAlert(STR0065) //"O campo LG_WSSRV não esta preenchido e a pesquisa não retornará os dados desejados."
	EndIf

	cSRVWS := "http://" + AllTrim(LjGetStation("WSSRV")) + "/WSLOJA845.apw"
	oWS := WSWSLOJA845():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWS),Nil) //Monta o Header de Autenticação do Web Service
	oWS:_URL 		:= cSRVWS
	oWS:cCEMP02		:= cEmpAnt
	oWS:cCFIL02		:= cFilAnt	
	oWS:cCALIAS01	:= cAlias
	Do Case 
		Case nOpc == 1
			oWS:cCQRYW := "MEH.MEH_CODLIS = '" + cNumLst + "'"
		Case nOpc == 2	
			oWS:cCQRYW := "MEE.MEE_CODLIS = '" + cNumLst + "'"
	EndCase		
	oWS:cCLSTCMP02	:= ArrTokStr(aLstCmp,cDel,0)
	oWS:nNORDEM02	:= 1
	oWS:lLTCBOX02	:= .T.
	//Chamada do metodo de retorno de consulta
	lRet02 := oWS:LJ845RETD()
	If ValType(lRet02) == "L"
		If !lRet02
			Lj845WSErr(cRotina)
		Else
			If Len(oWS:oWSLJ845RETDRESULT:oWSARETMOD) > 0 .AND. !Empty(oWS:oWSLJ845RETDRESULT:oWSARETMOD[1]:cCRETORNO)
				For ni := 1 to Len(oWS:oWSLJ845RETDRESULT:oWSARETMOD)
					aTMP := StrTokArr(oWS:oWSLJ845RETDRESULT:oWSARETMOD[ni]:cCRETORNO,cDel)
					//Converter dados de acordo com o tipo de dado de cada campo utilizado
					aTMP := Lj845WSCon(aTMP,aHeader01,5)
					aAdd(aDados01,aTMP)
				Next ni
			Endif
		Endif
	Endif
	oWS:Reset()
Endif
If ValType(aDados01) # "A" .OR. Len(aDados01) == 0
	MsgAlert(STR0026)
	Return !lRet
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg02 TITLE cTitulo FROM 000,000 TO 300,600 OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
oArea:Init(oDlg02,!lMDI)
oArea:AddLine("L01",100,.T.)
oArea:AddCollumn("L01C01",100,.F.,"L01")
oArea:AddWindow("L01C01","L01C01P01",cTitulo,100,.F.,.F.,,"L01")
oPainel := oArea:GetWinPanel("L01C01","L01C01P01","L01")
//Dimensoes do objeto - MsNewGetDados
aTamObj[1] := 000
aTamObj[2] := 000
aTamObj[3] := (oPainel:nClientWidth / 2)
aTamObj[4] := (oPainel:nClientHeight / 2) * 0.9
//GD das entregas programadas
LjMntBrw(	@oPainel,;					//01 - Objeto Janela
			@aDados01,;					//02 - Alias ou Array de Dados
			{aTamObj[1],;				//03 - Array contendo as coordenadas
			aTamObj[2],;
			aTamObj[3],;
			aTamObj[4]},;	
			@oGD02,;					//04 - Objeto que sera criado
			.T.,;						//05 - Utilizar dicionario para compor colunas
			aHeader01,;					//06 - Lista de campos desejados
			Nil,;						//07 - Expressao para Legenda Automatica
			{},;						//08 - Codigo de cores para legenda automatica
			Nil,;						//09 - Expressao para posicionamento no inicio
			Nil,;						//10 - Expressao para posicionamento no final
			{|| Nil},;					//11 - Expressao ao clicar em um item da lista
			Nil,;						//12 - Coluna que ficara congelada na exibicao
			Nil,;						//13 - Classificacao por cabecalho (header)
			{},;						//14 - Array de Legenda
			.T.,;						//15 - Formatar dados com a picture informada (origem array)
			.F.)						//16 - A ordem dos campos deve respeitar o SX3 (origem alias)
//Dimensoes do objeto - Botoes
aTamObj[1] := (oGD02:nBottom / 2) + 2
aTamObj[2] := 000
aTamObj[3] := (oPainel:nClientWidth / 2) * ((1 - (cCoefDis * nTotBot)) / nTotBot)
aTamObj[4] := 012
//Botao - Fechar
oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + STR0023,oPainel,{|| oDlg02:End()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,/*When*/)
//Configuracoes e ativacao 
oDlg02:lMaximized := .F.
oDlg02:Activate(,,,.T.,/*valid*/,,{|| oGD02:SetFocus()})

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845RetD ºAutor  ³Vendas Cliente        º Data ³04/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de retorno de dados de pesquisa, baseado em tabela e crite-º±±
±±º          ³rio de pesquisa                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Filial de pesquisa                                     º±±
±±º          ³Exp02[C] : Tabela de pesquisa                                     º±±
±±º          ³Exp03[C] : Clausula de restricao para a query                     º±±
±±º          ³Exp04[A] : Lista de campos de retorno                             º±±
±±º          ³Exp05[L] : Auto-substituir valor de campos combo                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aRet[A]  : Array com os dados encontrados                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj845RetD( cFil  ,cAlias01,cQryW,aLstCmp,;
					nOrdem,lTCBox, lMemo)

Local aRet				:= {}																//Array de retorno
Local cQry             	:= ""																// query da select
Local cAliasT			:= GetNextAlias()													//Alias temporario
Local nPos				:= 0																//Posicionador
Local nPos02			:= 0																//Posicionador 02
Local ni				:= 0																//Contador
Local aEstru			:= (cAlias01)->(DbStruct())										//Estrutura da tabela
Local nCampos			:= 0																//Numero de campos
Local aAreaSX3			:= SX3->(GetArea())												//Area do SX3
Local aLstCmpCB			:= {}																//Campos Combo
Local aTMP				:= {}																//Array temporario
Local aLstCmpMm		:= {}																//Array de Campos Memos
Local aArea01			:= {}																//Array da WorkArea

Default cFil			:= ""																//filial
Default cAlias01		:= ""																//area de trabalho
Default cQryW			:= ""																//query 
Default aLstCmp	   		:= {}																//campos da lista
Default nOrdem			:= 1																//ordem
Default lTCBox			:= .F.																//box a exibir]
Default lMemo				:= .F.																//campos memmos

If (nCampos := Len(aLstCmp)) == 0 .OR. Empty(cAlias01) .OR. !AliasInDic(cAlias01)
	Return aRet
Endif

aArea01 := (cAlias01)->(GetArea())

If Empty(cFil)
	cFil := xFilial(cAlias01) 
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se necessario, levantar campos com valor de opcao (combobox)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTCBox .or. lMemo
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	nTam := Len(SX3->X3_CAMPO)
	For ni := 1 to Len(aLstCmp)
		If SX3->(DbSeek(PadR(aLstCmp[ni],nTam)))
			If lTCBox .AND. SX3->X3_TIPO == "C"
				If !Empty(cTMP := X3CBox())
					aAdd(aLstCmpCB,{aLstCmp[ni],RetSX3Box(cTMP,,,1)})
				Endif
			ElseIf lMemo .AND. SX3->X3_TIPO == "M" 
					aAdd(aLstCmpMm, aLstCmp[ni])
			Endif
		Endif
	Next ni
Endif


cTMP := ""
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
cQry := "SELECT "

For ni := 1 to Len(aLstCmp)
	If SX3->(DbSeek(aLstCmp[ni]))
		cQry += cAlias01 + "." + AllTrim(aLstCmp[ni]) + ","
	Endif
Next ni

//Campo Memo insere o recno e posiciona na WorkArea principal
//Recno precisa ser o ultimo para não dar problemas no fieldget
If (lMemo := Len(aLstCmpMm) > 0)
	cQry += cAlias01 + ".R_E_C_N_O_ AS REGISTRO,"
EndIf

cQry := Substr(cQry,1,Len(cQry) - 1) + " "
cQry += "FROM " + RetSQLName(cAlias01) + " " + cAlias01 + " "
cQry += "WHERE " + RetSQLDel(cAlias01) + " AND " + cAlias01 + "." + cAlias01 + "_FILIAL = '" + cFil + "' "
If !Empty(cQryW)
	cQry += "AND " + cQryW + " "	
Endif
cQry += "ORDER BY " + SqlOrder((cAlias01)->(IndexKey(nOrdem)))

DbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAliasT,.T.,.F.)
(cAliasT)->(DbGoTop())
AjustaTC(cAliasT,aEstru)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento dos resultados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasT)->(Eof())
	FechaArqT(cAliasT)
	RestArea(aAreaSX3)
	Return aRet
Endif
nPos := 0
While !(cAliasT)->(Eof())
	aAdd(aRet,Array(nCampos))
	nPos++
	For ni := 1 to nCampos
		If lTCBox
			If (nPos02 := aScan(aLstCmpCB,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aLstCmp[ni]))})) == 0
				aRet[nPos][ni] := (cAliasT)->(FieldGet(ni))
			Else
				aTMP := aLstCmpCB[nPos02][2]
				If (nPos02 := aScan(aTMP,{|x| x[2] == (cAliasT)->(FieldGet(ni))})) > 0
					aRet[nPos][ni] := AllTrim(aTMP[nPos02][3])
				Else
					aRet[nPos][ni] := (cAliasT)->(FieldGet(ni))
				Endif
			Endif
		ElseIf lMemo .AND. (nPos02 := aScan(aLstCmpMm,{|x| Upper(AllTrim(x)) == Upper(AllTrim(aLstCmp[ni]))})) > 0
				(cAlias01)->(DbGoto((cAliasT)->(FieldGet(FieldPos("REGISTRO")))))
				aRet[nPos][ni] := (cAlias01)->(FieldGet(FieldPos(aLstCmpMm[nPos02])))
		Else
			aRet[nPos][ni] := (cAliasT)->(FieldGet(ni))
		Endif
	Next ni
	(cAliasT)->(DbSkip())
End
FechaArqT(cAliasT)
Restarea(aArea01)
RestArea(aAreaSX3)

Return aRet





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845OpCmbºAutor  ³Vendas Cliente        º Data ³04/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para retornar a opcao de lista selecionada a partir da     º±±
±±º          ³descricao de uma opcao selecionada.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Nome do campo                                          º±±
±±º          ³Exp02[C] : Descricao da opcao                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aRet[A]  : Array com os dados encontrados                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj845OpCmb(cCampo,cDescOpc)

Local aAreaSX3			:= SX3->(GetArea())		//area do SX3
Local cTMP				:= ""						//manipulacao de dados na SX3
Local aTMP				:= {}                      //manipulacao de dados na SX3
Local cRet				:= ""                      //retorno da funcao
Local nTam				:= 0                       //tamanho dos campos

Default cCampo			:= ""                     //campo para busca
Default cDescOpc		:= ""                     //campo para retorno

If Empty(cCampo) .OR. Empty(cDescOpc)
	Return cRet
Endif
cDescOpc := AllTrim(cDescOpc)
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If SX3->(DbSeek(PadR(cCampo,Len(SX3->X3_CAMPO))))
	nTam := Len(SX3->X3_CBOX)
	If SX3->X3_TIPO == "C"
		If !Empty(cTMP := X3CBox())
			aTMP := RetSX3Box(cTMP,,,1)
			If (nPos := aScan(aTMP,{|x| PadR(Upper(x[3]),nTam) == PadR(Upper(cDescOpc),nTam)})) > 0
				cRet := aTMP[nPos][2]
			Endif
		Endif
	Endif
Endif
RestArea(aAreaSX3)

Return cRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845VlQtdºAutor  ³Vendas Cliente        º Data ³09/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validar digitacao de quantidade                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Objeto do tipo GRID MsNewGetDados                      º±±
±±º          ³Exp02[C] : Quantidade digitada                                    º±±
±±º          ³Exp03[C] : Aceita quantidades extras alem do determinado na lista º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet[A]  : Retorno logico                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj845VlQtd(oGD,nQtde,cExtra)

Local lRet				:= .T.				//retorno da funcao
Local aHead				:= {}				//cabecalho
Local aCol				:= {}				//colunas
Local nPos				:= ""				//posicoes

Default oGD				:= NIL				//objeto da lista
Default nQtde			:= 0				//quantidade digitada
Default cExtra			:= "2"				//extras na quantidade

If oGD == Nil .OR. ValType(oGD) # "O" .OR. Empty(nQtde) .AND. ValType(cExtra) # "C" .OR. !AllTrim(cExtra) $ "1|2"
	Return !lRet
Endif
aHead	:= oGD:aHeader
aCol	:= oGD:aCols
If (nPos := aScan(aHead,{|x| Upper(AllTrim(x[2])) == "DISPO"})) > 0
	//Se a quantidade estiver a maior e a lista nao permitir quantidades extras, rejeitar
	If Empty(nQtde) .OR. (nQtde > aCol[oGD:nAt][nPos] .AND. AllTrim(cExtra) # "1")
		lRet := !lRet
	Endif
Endif

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845IncItºAutor  ³Vendas Cliente        º Data ³17/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusao de novos itens na lista de selecao                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Alias a ser editado                                    º±±
±±º          ³Exp02[C] : Marca de selecao                                       º±±
±±º          ³Exp03[C] : Modo de entrega                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet[L]  : Retorno logico                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj845IncIt(cAlias,cMarca,cModoEnt)

Local lRet				:= .T.						//retorno da funcao
Local lOnline			:= !(cModulo == "FRT") .OR. (FindFunction("LjxBGetPaf") .AND. LjxBGetPaf()[2])		// verifica se sistema esta online
Local aCodProd			:= Array(4)					//array dos produtos
Local aArea				:= (cAlias)->(GetArea())	//area de trabalho
Local xRet				:= Nil						//Retorno do Ponto de entrada
Local cCondPad			:= ""						//Nome da consulta a ser realizada
 
default cAlias			:= ""			//alias de trabalho
default cMarca			:= ""			//marca selecao
default cModoEnt		:= ""			//modo de entrega

If Empty(cAlias) .OR. Select(cAlias) == 0 .OR. Empty(cMarca) .OR. Empty(cModoEnt)
	Return !lRet
Endif

If ExistBlock("LJ845LPI")
	xRet := ExecBlock( "LJ845LPI", .F., .F. )
	If ValType(xRet) == "L" //Logico -> Exibe ou nao a consulta padrão.
		lRet := xRet
	ElseIf ValType(xRet) == "C" .And. !Empty(xRet) //Exibe a consulta solicitada pelo PE.
		cCondPad := AllTrim(xRet)
	EndIf	
Endif

If lRet
	If lOnline
		cCondPad := Iif(!Empty(cCondPad),cCondPad,"SB1")
		If !ConPad1(,,,cCondPad,/*cRet*/,,.F./*lOnlyView*/,/*Campo chamada*/,,/*Cont.Campo Antes Chamada*/)
			Return !lRet
		Endif
		aCodProd[1] := SB1->B1_COD
		aCodProd[2] := SB1->B1_DESC
		aCodProd[3] := SB1->B1_UM
	Else
		cCondPad := Iif(!Empty(cCondPad),cCondPad,"FRT")
		If !ConPad1(,,,cCondPad,/*cRet*/,,.F./*lOnlyView*/,/*Campo chamada*/,,/*Cont.Campo Antes Chamada*/)
			Return !lRet
		Endif
		aCodProd[1] := SBI->BI_COD
		aCodProd[2] := SBI->BI_DESC
		aCodProd[3] := SBI->BI_UM
	Endif
	//Adicionar registro
	RecLock(cAlias,.T.)
	(cAlias)->SEL 		:= cMarca	
	(cAlias)->ITEM		:= Space(TamSX3("ME2_ITEM")[1])
	(cAlias)->PROD		:= aCodProd[1]
	(cAlias)->DESCR		:= aCodProd[2]
	(cAlias)->UM		:= aCodProd[3]
	(cAlias)->DISPO		:= 1
	(cAlias)->QTDE		:= 1
	(cAlias)->MODOENT	:= cModoEnt
	MsUnlock()
	RestArea(aArea)
EndIf

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845WSErrºAutor  ³Vendas Cliente        º Data ³12/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para tratamento de erro de webservice (demonstrador)       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Nome da rotina de origem                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj845WSErr(cRotina)

Local cWSErro			:= ""			//mensagem de erro
Local cSoapErrCod		:= ""			//ocorrencia 
Local cSoapErrDesc		:= ""			//expectativa

Default cRotina	   		:= ""

cRotina := RTrim(AllTrim(cRotina) + Space(1))
cWSErro := GetWSCError(1)	//Retorno de string contendo o resumo do erro completo
If Substr(cWSErro,1,9)	 = "WSCERR048"
	cWSErro := GetWSCError(3)
	cSoapErrCod  := Alltrim(Substr(cWSErro,1,At(":",cWSErro)-1))
	cSoapErrDesc := Alltrim(Substr(cWSErro,At(":",cWSErro)+1,Len(cWSErro)))
	Conout(cRotina + STR0051 + cSoapErrCod + " -> " + cSoapErrDesc)           ///"ERRO WS : "
Else
	ConOut(cRotina + STR0050)   ////"Erro de comunicação com o WebService!"
Endif

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845WSConºAutor  ³Vendas Cliente        º Data ³12/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para conversao de tipo de dados de retorno de WS           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[A] : Array com os dados de um registro                      º±±
±±º          ³Exp02[A] : Header utilizado                                       º±±
±±ºParametros³Exp03[N] : Posicao do tipo de dado no header utilizado            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aRet[A]  : Array convertido                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA845                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj845WSCon(aDados,aHead,nPosTD)

Local aRet				:= aClone(aDados)		//Retorno de dados
Local nx				:= 0					//Contador
Local lPesqTD			:= Empty(nPosTD)		//Pesquisar tipo de dados?
Local cTPD				:= ""					//Tipo de dados

Default aDados			:= {}					//array dos dados de exibicao
Default aHead			:= {}					//cabecalho
Default nPosTD			:= 0					//posicao

If ValType(aDados) # "A" .OR. Len(aDados) == 0 .OR. ValType(aHead) # "A" .OR. Len(aHead) == 0
	Return aRet
Endif
aRet := Array(Len(aDados))
For nx := 1 to Len(aDados)
	If !lPesqTD
		cTPD := aHead[nx][nPosTD]
	Else
		cTPD := AllTrim(GetSX3Cache(Upper(AllTrim(aHead[nx])),"X3_TIPO"))
	Endif
	Do Case
		Case cTPD == "D"
			aRet[nx] := CtoD(aDados[nx])
		Case cTPD == "N"
			aRet[nx] := GetDToVal(aDados[nx])
		Case cTPD == "L"
			aRet[nx] := &(aDados[nx])
		Otherwise
			aRet[nx] := aDados[nx]
	EndCase
Next nx

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Vendas Cliente        º Data ³09/03/11         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para definicao das rotinas.                                º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRot	:=  {}

aAdd(aRot,{STR0052,"AxPesqui"	,0	,PESQUISAR	,0	,.F.}) 	    /// "Pesquisar"
aAdd(aRot,{STR0053,"Loja843"	,0	,VISUALIZAR	,	,.T.})		/// "Visualizar"
aAdd(aRot,{STR0054,"Loja843"	,0	,INCLUIR	,	,.T.}) 		/// "Incluir"
aAdd(aRot,{STR0055,"Loja843"	,0	,ALTERAR	,	,.T.})     /// "Alterar"
aAdd(aRot,{STR0056,"Loja843"	,0	,EXCLUIR	,	,.T.}) 	    /// "Excluir"

Return aRot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj845CodBarºAutor  ³Vendas Cliente        º Data ³13/04/15        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que realiza a busca do produto pelo codigo de barras.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj845CodBar(cCodSearch, oGetCodBar, cAliasTrb)

//Local aArea		:= GetArea()	
Local aAreaSLK	:= SLK->(GetArea()) //Area do SLK
Local aAreaSB1	:= SB1->(GetArea()) //Area do SB1
Local cProduct	:= ""
Local lRet 		:= .F.

Default cCodSearch 	:= Space(TamSx3("B1_CODBAR")[1]) 	//Variavel codigo de barras
Default oGetCodBar 	:= Nil									//Objeto get codigo de barras
Default cAliasTrb 	:= "" 									//Alias de trabalho

//Busca Codigo de Barras
If !Empty(cCodSearch)		
	//Busca Codigo do Produto
	Do Case
		Case !Empty(Posicione("SB1", 5, xFilial("SB1") + Padr(cCodSearch, TamSx3("B1_CODBAR")[1]), "B1_COD")) //Busca Codigo de Barras na SB1 		 
			cProduct := SB1->B1_COD
		Case !Empty(Posicione("SLK", 1, xFilial("SLK") + Padr(cCodSearch, TamSx3("LK_CODBAR")[1]), "LK_CODIGO")) //Busca Codigo de Barras na SLK 			
			cProduct := SLK->LK_CODIGO
		Case !Empty(Posicione("SB1", 1, xFilial("SB1") + Padr(cCodSearch, TamSx3("B1_COD")[1]), "B1_COD")) //Busca Codigo do Produto na SB1 			
			cProduct := SB1->B1_COD
		OtherWise
			cProduct := Space(TamSx3("B1_COD")[1])
	EndCase
				
	If !Empty(cProduct) 														
		(cAliasTrb)->(dbGoTop())
		
		//Verifica se produto existe e esta na lista	
		While (cAliasTrb)->(!Eof())
			If AllTrim((cAliasTrb)->PROD) == AllTrim(cProduct)								 								   			   			  
			   lRet := .T.
				Exit										
			EndIf
			
			(cAliasTrb)->(dbSkip())
		EndDo
		
		If !lRet
			MsgStop(STR0066) //"Produto nao encontrado na Lista de Presentes"				
		EndIf														
	Else		
		MsgStop(STR0067) //"Codigo de Barras nao encontrado" 		
	EndIf
	
	//Atualiza objetos de tela
	cCodSearch := Space(TamSx3("B1_CODBAR")[1])	
	oGetCodBar:Refresh()
	oGetCodBar:SetFocus()
EndIf

//Restaura areas
RestArea(aAreaSLK)
RestArea(aAreaSB1)
//RestArea(aArea)

Return lRet
