#INCLUDE "TMKA280.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "FILEIO.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA280   ºAutor  ³ Vendas Clientes    º Data ³  12/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pre-atendimento para Telecobranca Ativa                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³lAuto - Se é entrada automática                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA280(lAuto)

Local cRegSel		:=TkPosto(TkOperador(),"U0_REGSEL")					// Regra de selecao do Operador 
Local cLockByName	:= "TMKSK1" + FWCodEmp( "SK1" )
Local cLockUser 	:= "TMK" + __cUserId
Private aTela1		:= {}												// Utilizada na montagem da Enchoice pela funcao MsMGet()
Private aTela2		:= {}												// Utilizada na montagem da Enchoice pela funcao MsMGet()
Private cCadastro	:= STR0001											// "Pré-atendimento da Telecobrança Ativa"
Private aRotina		:= MenuDef()										// Rotinas executadas no programa
DEFAULT lAuto 		:= .F.												// Se a flag de entrada automatica nao foi informada, assume .F.	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializo a variavel para tratamento de entrada automatica. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto
	If Type("lTk271Auto") == "U"
		Private lTk271Auto := .F.
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impede o uso da rotina se nao for criada a tabela SK4³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkFile("SKV")
	If !lTk271Auto
		MsgStop(STR0099, STR0078) //"Antes de executar a rotina de pré-atendimento, o administrador do sistema deve executar a rotina TmkUpdSKV para criação da tabela SKV no sistema."
	Else
		ConOut(STR0099) //"Antes de executar a rotina de pré-atendimento, o administrador do sistema deve executar a rotina U_TmkUpdSKV para criação da tabela SKV."
	EndIf
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao permite a abertura simultanea para o modelo MDI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LockByName( cLockUser, .T., .F. )
	Help("  ",1,"TMKPROMDI")//"Essa rotina nao pode ser executada em conjunto com as rotinas..."
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Semáforo para garantir a exclusividade quando executar a rotina TMKA180 - atualizacao da SK1   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LockByName( cLockByName, .T., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o USUARIO nao estiver cadastrado em OPERADORES e nao tiver    ³
//³um Grupo de Atendimento (SU0) associado ou se o Operador nao 	³
//³tiver acesso a rotina de Telecobranca ou Todas - nao entra nessa ³
//³rotina                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !TMKOPERADOR()
	Help("  ",1,"OPERADOR")//Esse usuario nao esta associado com um operador. Ou nao se trata de um operador valido..."
	Return(.F.)
Else     
	If	VAL(TkGetTipoAte()) == TELEVENDAS		.OR.;
		VAL(TkGetTipoAte()) == TELEMARKETING	.OR.;
		VAL(TkGetTipoAte()) == TMKTLV
		Help("  ",1,"TK280ACTLC")//"Esse operador nao possui acesso a rotina de telecobranca, definido no cadastro de operadores"
		Return(.F.)
	Endif
EndIf	

// Verifica se o Operador possui regra de selecao e de negociacao.
If Empty(TkPosto(TkOperador(),"U0_REGSEL")) .OR. Empty(TkPosto(TkOperador(),"U0_REGNEG"))
	Help("  ",1,"TK280REGRA")//"Esse operador nao possui as regras de selecao ou negociacao definidas para executar a rotina e Telecobrança"
	Return(.F.)
Else
	DbSelectArea("SK0")
	DbSetOrder(1) //Filial + Regra Selecao
	If DbSeek(xFilial("SK0")+cRegSel)
    	If SK0->K0_PRAZO == "999999"	// Trabalha com lista de contato
			MsgStop(STR0076,STR0065)	//"Não é permitido executar a rotina de Pré-Atendimento por operadores que possuam regra de seleção de Listas de Cobrança. Utilize a rotina Agenda do Operador para executar as Listas de Cobrança. "
			Return(.F.)
   		Endif
    Else
    	Help("  ",1,"TK280REGRA")//"Esse operador nao possui as regras de selecao ou negociacao definidas para executar a rotina e Telecobrança"
	    Return(.F.)
    Endif
Endif

// Verifica se o Operador realiza atendimento ATIVO
If TkPosto(TkOperador(),"U0_BOUND") == "1"		// Receptiva
	Help("  ",1,"TK280ATEND")//"Esse operador nao possui acesso para realizar essa operacao de atendimento"
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(,,,,"ACF")

UnLockByName( cLockByName, .T., .F. )
UnLockByName( cLockUser, .T., .F. )

Return(.T.)
 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Clientes       ³ Data ³11/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= {		{STR0002,	"AxPesqui"		,	0,	1 , , .F.},;	// "Pesquisa"
						{STR0003,	"AxVisual"		,	0,	2 , , .T.},;	// "Visualiza"
						{STR0004,	"TK280Cobranca"	,	0,	3 , , .T.}	}	// "Cobrança"					

							                                                     
							
							
Return(ARotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK280CobrancaºAutor ³ Vendas Clientes    º Data ³  12/05/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria o objeto principal do pre-atendimento que apresentara  º±±
±±º          ³todas as informacoes necessarias para o atendimento.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP8                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cAlias - Alias passado pela mBrowser                        º±±
±±º          ³nReg   - Recno passado pelo mBrowser                        º±±
±±º          ³nOpc   - Opcao de menu passado pelo mBrowser                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK280Cobranca(	cAlias,	nReg,	nOpc )

Local oExplorer	:= Nil							// Objeto que contem o tree e os panels
Local aResource	:= {}							// Contem todos os botoes que farao parte do tool bar
Local aKey		:= {}							// Seta as teclas de atalho para os botoes da Tool Bar
Local lRet		:= .F.							// Retorno da funcao
Local cOperador	:= ""			   				// Codigo do Operador 
Local nI		:= 0 							// Contador
Local aMemory	:= {}							// array com array das variaveis de memoria para refresh
Local aPanels	:= {}							// Objs principais de todos os panels
Local aRegras	:= {}							// Todas as regras de atendimento
Local nPos		:= 0			   				// Posicao do objeto no array
Local lTK280TB	:= ExistBlock("TK280TB")		// Ponto de entrada para incluir botoes na barra de ferramentas
Local nIni		:= 0							// Inicio do periodo de cobranca
Local nFim		:= 0							// Final do periodo de cobranca
Local lCredito	:= .F.							// Permicao de manipulacao de credito
Local cUltimo	:= SuperGetMV("MV_TMKSK1")		// Data e hora da ultima atualizacao
Local aBotoes	:= {}							// Botões adicionais incluídos no ponto de entrada TK280TB

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega um array com as regras de cobranca que serao utilizadas pela rotina³
//³Filtra todas as regras de selecao apenas da filial corrente. Pois se       ³
//³o cadastro de regras de selecao estiver compartilhado as regras irao  valer³
//³para todas as filiais da empresa corrente, caso contrario, se o cadastro   ³
//³estiver exclusivo, cada filial ira utilizar a sua regra.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SK0")
DbSetOrder(2)
DbSeek(xFilial("SK0"))
While !SK0->(Eof()) .AND. xFilial("SK0") == SK0->K0_FILIAL
	nIni := nFim + 1
	If SK0->K0_PRAZO == "999999"		// Trabalha com lista de contato
		nFim := nFim + 100000
	Else
		nFim := nFim + Val(SK0->K0_PRAZO)
	Endif
	Aadd(aRegras, {SK0->K0_REGSEL, nIni, nFim})
	SK0->(DbSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona nas regras de Negociacao do operador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SK2")
DbSetOrder(1)
If DbSeek(xFilial("SK2") + SU0->U0_REGNEG)
	If SK2->K2_CREDITO == "1"
		lCredito := .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³passa o nOpc para VISUALIZACAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpc := 2 //Visualizacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis que possuem conteudos que serao utilizados por toda rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOperador := TkOperador()

// Carrega as variaveis de memoria para todas as enchoices
ACF->(DbGoTo(0))
RegToMemory("ACF",.F.)
SA1->(DbGoTo(0))
RegToMemory("SA1",.F.)
SU5->(DbGoTo(0))
RegToMemory("SU5",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa ao gerenciador de múltiplos grupos de atendimento³
//³que a rotina pré-atendimento está em execução.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TK091Start( PREATENDIMENTO )

oExplorer := MSExplorer():New( STR0005 + " - " + TK091Titulo(cOperador)) //"Telecobrança Ativa"

Processa( {|| TK280PreTLC(oExplorer,cOperador,@aPanels,@aMemory,aRegras)}, STR0006) //"Criação dos Paineis"

// Define os botoes para a barra de ferramentas
Aadd( aResource, { "BMPINCLUIR"	, STR0008, {|| TK280Novo(oExplorer, cOperador, aRegras, @aPanels, @aMemory) }			,STR0058		,	.T. } )	// "Busca um novo Pré-atendimento para cobrança - (F6)" "Novo"
Aadd( aResource, { "SIMULACA"	, STR0009, {|| TK280Financ("010", oExplorer, aPanels, @aMemory, aKey) }					,STR0059		,	.T. } )	// "Consulta Posição Financeira do Cliente - (F7)" "Cliente"
Aadd( aResource, { "BUDGET"		, STR0010, {|| TK280Financ("040", oExplorer, aPanels, @aMemory, aKey) }					,STR0060		,	.T. } )	// "Consulta Posição Financeira do Titulo - (F8)" "Titulo"
Aadd( aResource, { "BAIXATIT"	, STR0011, {|| TK280Credito(lCredito, oExplorer, aPanels, @aMemory, aKey) }				,STR0061		,	.T. } )	// "Manipula o Crédito do Cliente - (F9)" "Credito"
Aadd( aResource, { "DISCAGEM"	, STR0012, {|| TK280Atend(oExplorer, @aPanels, @aRegras, cOperador, @aMemory, aKey)}	,STR0062		,	.T. } )	// "Executa a tela de atendimento - (F10)" "Cobrar"
Aadd( aResource, { "pesquisa"	, STR0069, {|| Tk280Pesq(oExplorer,@aPanels, @aRegras, cOperador)}						,"Pendencias"	,	.T. } )	// "Pesquisar Pendencia" "Pendencias"
Aadd( aResource, { "bmpuser"	, STR0068, {|| Tk280Contato(oExplorer,@aPanels)}										,"Contaots"		,	.T. } )	// "Cadastro de Contatos" "Contatos"

// Define as teclas de atalho dos botoes
Aadd(aKey, { VK_F6, {|| TK280Novo(oExplorer, cOperador, aRegras, @aPanels, @aMemory) } } )
Aadd(aKey, { VK_F7, {|| TK280Financ("010", oExplorer, aPanels, @aMemory, aKey) } } )
Aadd(aKey, { VK_F8, {|| TK280Financ("040", oExplorer, aPanels, @aMemory, aKey) } } )
Aadd(aKey, { VK_F9, {|| TK280Credito(lCredito, oExplorer, aPanels, @aMemory, aKey) } } )
Aadd(aKey, { VK_F10,{|| TK280Atend(oExplorer, @aPanels, @aRegras, cOperador, @aMemory, aKey) } } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O ponto de entrada TK280TB tem como objetivo incluir novos botoes³
//³na barra de ferramentas superior.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK280TB
	// Recebe via ponto de entrada os novos botoes. 
 	aBotoes := ExecBlock( "TK280TB", .F., .F. )
	
	// Verifica se o retorno eh um array 
	If ValType(aBotoes) <> "A" 
		Help("  ",1,"TK280PENTR")//"Ocorreu um retorno invalido no ponto de entrada TK280TB que impede a utilizacao do sistema"
		Return(.F.)
	Endif
	
	For nI := 1 To Len(aBotoes)
		If	ValType(aBotoes[nI][1]) <> "C"	.OR.;
			ValType(aBotoes[nI][2]) <> "C"	.OR.;
			ValType(aBotoes[nI][3]) <> "B"	.OR.;
			ValType(aBotoes[nI][4]) <> "C"	.OR.;
			ValType(aBotoes[nI][5]) <> "L"
			
			Help("  ",1,"TK280PENTR")//"Ocorreu um retorno invalido no ponto de entrada TK280TB que impede a utilizacao do sistema"
			Return(.F.)
		Endif
	Next nI
Endif

// Carrega todos os botoes padrao na barra de ferramentas
For nI := 1 To Len(aResource)
	If aResource[nI][5]
		oExplorer:AddDefButton( aResource[nI][1], aResource[nI][2], aResource[nI][3],,,, aResource[nI][4] )
		If nI <= 5
			SetKey(aKey[nI][1], aKey[nI][2] )
		Endif
	Endif
Next nI

// Carrega todos os botoes do ponto de entrada na barra de ferramentas
For nI := 1 To Len(aBotoes)
	If aBotoes[nI][5]
		oExplorer:AddDefButton( aBotoes[nI][1], aBotoes[nI][2], aBotoes[nI][3],,,, aBotoes[nI][4] )
	Endif
Next nI

// Este botao nao podera ser alterado
oExplorer:AddDefButton( "CANCEL_OCEAN", STR0013, {|| Tk280Fim(oExplorer, aKey) },,,, STR0063 ) //"Encerra o Pré-atendimento - (Alt F4)", "Cancelar"

// Define a funcao que sera executada no momento da troca dos panels
oExplorer:bChange := {|| Tk280Change(oExplorer, @aPanels, @aMemory, cOperador)}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa a enchoice dos dados cadastrais do cliente para comecar a trabalhar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk280Memory("SA1", @aMemory, .F.)
nPos := Ascan(aPanels, {|x| x[2]=="FOBJ02"} )
aPanels[nPos][1]:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkGrvSUV(__cUserId, "PRE0")

FATPDLogUser("TK280COBRA")
oExplorer:Activate(.T.,{|| .T. })
lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa ao gerenciador de múltiplos grupos de atendimento ³
//³que a rotina pré-atendimento não está mais em execução.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TK091End( PREATENDIMENTO )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK280PreTLCºAutor  ³ Vendas Clientes    º Data ³  12/05/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Direciona a criacao dos paineis que conterao as informacoes º±±
±±º          ³do pre atendimento.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³cOperador - Codigo do operador que esta trabalhando.        º±±
±±º          ³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³aMemory   - Vaiaveis de memoria utilizada pelas MSMGET.     º±±
±±º          ³aRegras   - Contem as regras de selecao dos titulos de todosº±±
±±º          ³            os operadores para validar qual titulo o opera- º±±
±±º          ³            dor corrente podera trabalhar.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP8                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK280PreTLC(	oExplorer,	cOperador,	aPanels,	aMemory,;
								aRegras )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pendencias Agendadas         ³
//³		Ultimo Atendimento      ³
//³		Titulos Negociados      ³
//³		Previsao de Cobranca    ³
//³                             ³
//³ Cobrancas de Hoje           ³
//³		Novo Atendimento        ³
//³		Pendencia Telemarketing ³
//³		Pedido no Televendas    ³
//³                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ProcRegua(8)

IncProc(STR0014) //"Pendências Agendadas"
Tk280TLC01(oExplorer, oExplorer:AddTree(PadR(STR0014,150),"FOLDER5","FOLDER6",PadR("TMK001",20)),@aPanels,@aMemory,cOperador,aRegras) //"Pendências Agendadas"
	IncProc(STR0015) //"Último Atendimento"
	Tk280TLC02(oExplorer, oExplorer:AddItem(Padr(STR0015,150),"NOTE", Padr("TMK002",20)),@aPanels,@aMemory) //"Último Atendimento"
	IncProc(STR0016) //"Títulos Negociados"
	Tk280TLC03(oExplorer, oExplorer:AddItem(Padr(STR0016,150),"NOTE", Padr("TMK003",20)),@aPanels) //"Títulos Negociados"
	IncProc(STR0017) //"Previsão de Cobrança"
	Tk280TLC04(oExplorer, oExplorer:AddItem(Padr(STR0017,150),"NOTE", Padr("TMK004",20)),@aPanels) //"Previsão de Cobrança"
oExplorer:EndTree()

IncProc(STR0018) //"Cobranças de Hoje"
Tk280TLC05(oExplorer, oExplorer:AddTree(Padr(STR0018,150),"FOLDER5","FOLDER6",Padr("TMK005",20)),@aPanels,@aMemory,cOperador) //"Cobranças de Hoje"
	IncProc(STR0019) //"Novo Pré-atendimento"
	Tk280TLC06(oExplorer, oExplorer:AddItem(Padr(STR0019,150),"RPMNEW", Padr("TMK006",20)),@aPanels,@aMemory) //"Novo Pré-atendimento"
	IncProc(STR0020) //"Histórico Telemarketing"
	Tk280TLC07(oExplorer, oExplorer:AddItem(Padr(STR0020,150),"RPMNEW", Padr("TMK008",20)),@aPanels) //"Pendência Telemarketing"
	IncProc(STR0021) //"Histórico Televendas"
	Tk280TLC08(oExplorer, oExplorer:AddItem(Padr(STR0021,150),"RPMNEW", Padr("TMK009",20)),@aPanels) //"Pedido no Televendas"
oExplorer:EndTree()

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280ChangeºAutor ³ Vendas Clientes    º Data ³  08/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao controla as acoes que devem ser realizadas quan-º±±
±±º          ³do um painel e trocado no pre-atendimento.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³aMemory   - Vaiaveis de memoria utilizada pelas MSMGET.     º±±
±±º          ³cOperador - Codigo do operador que esta trabalhando.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk280Change( oExplorer, aPanels, aMemory, cOperador )

Local oLbx			:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]	// Objeto com os itens da agenda do operador
Local nPosObj01 	:= 0													// Ponteiro de array
Local nPosObj02 	:= 0													// Ponteiro de array
Local nPCodigo		:= 0													// Ponteiro de array
Local nPos			:= 0													// Posicao do objeto no array.
Local nPTitulo		:= 0													// Posicao do campo numero do titulo no aCols.
Local oObjACG 		:= Nil
Local nPosSit		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o Painel com os dados do Cabecalho do Ultimo Atendimento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oExplorer:nPanel == 2
	If !aPanels[Ascan(aPanels, {|x| x[2]=="BOBJ01"} )][3]
		aPanels[Ascan(aPanels, {|x| x[2]=="BOBJ01"} )][3] := .T.
		DbSelectArea("ACF")
		DbSetOrder(1)
		If DbSeek(xFilial("ACF") + oLbx:aArray[oLbx:nAt][7])
			Tk280Memory("ACF", @aMemory, .T.)
			aPanels[Ascan(aPanels, {|x| x[2]=="BOBJ01"} )][1]:Refresh()
		Else
			Tk280Memory("ACF", @aMemory, .F.)
			aPanels[Ascan(aPanels, {|x| x[2]=="BOBJ01"} )][1]:Refresh()
		Endif	
			
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1") + oLbx:aArray[oLbx:nAt][2] + oLbx:aArray[oLbx:nAt][3])
			aPanels[Ascan(aPanels, {|x| x[2]=="BOBJ02"} )][1]:bSetGet := {|U| IF( PCOUNT() == 0, MSMM(SA1->A1_CODHIST), U )}
			aPanels[Ascan(aPanels, {|x| x[2]=="BOBJ02"} )][1]:Refresh()
	    Endif
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do Painel com os Titulos que foram cobrados antes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oExplorer:nPanel == 3
	If !aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][3]
		aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][3] := .T.
		
		Tk280ACG(@aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][1]:aHeader, @aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][1]:aCols, @aPanels[Ascan(aPanels, {|x| x[2]=="COBJ02"} )][1], oLbx:aArray[oLbx:nAt][7], oLbx:aArray[oLbx:nAt][2] , oLbx:aArray[oLbx:nAt][3])
	
		oObjACG	:= aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][1]
		
		nPosSit := aScan(oObjACG:aHeader, {|x| AllTrim(x[2]) == "ACG_DSITCB"}) 
		If nPosSit > 0
			nPosSit := aScan(oObjACG:aHeader, {|x| AllTrim(x[2]) == "ACG_SITUAC"})  
			If nPosSit > 0	
				oObjACG:aInfo[nPosSit][2] := " " 
				oObjACG:aInfo[nPosSit][6] := " "
				oObjACG:oBrowse:aColumns[nPosSit]:bData := {|| Transform(oObjACG:aCols[Iif( Len( oObjACG:aCols ) >= oObjACG:oBrowse:nAt, oObjACG:oBrowse:nAt, Len( oObjACG:aCols ) )][nPosSit],Trim(oObjACG:aHeader[nPosSit][3])) }
				oObjACG:Refresh()   
			EndIf 
		EndIf 
		
		aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][1]:Refresh()
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do Painel com os Titulos vencidos apos a cobranca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oExplorer:nPanel == 4
	If !aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ01"} )][3]
		aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ01"} )][3] := .T.
		DbSelectArea("ACF")
		DbSetOrder(1)
		If DbSeek(xFilial("ACF") + oLbx:aArray[oLbx:nAt][7])
		
			Tk280SK1(@aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ01"} )][1]:aHeader, @aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ01"} )][1]:aCols, @aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ02"} )][1],,,.F., ACF->ACF_DATA)
			aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ01"} )][1]:Refresh()
		Endif	
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do Painel dos Atendimento realizados no dia       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oExplorer:nPanel == 5
	nPosObj01	:= Ascan(aPanels, {|x| x[2]=="EOBJ01"} )
	nPosObj02	:= Ascan(aPanels, {|x| x[2]=="EOBJ02"} )
	nPCodigo	:= Ascan(aPanels[nPosObj01][1]:aHeader, {|x| AllTrim(x[2])=="ACF_CODIGO"} )
	
	If !aPanels[nPosObj01][3]
		aPanels[nPosObj01][3] := .T.
		
		Tk280ACF(@aPanels[nPosObj01][1]:aHeader, @aPanels[nPosObj01][1]:aCols, cOperador)
		aPanels[nPosObj01][1]:Refresh()
		
		If !Empty(aPanels[nPosObj01][1]:aCols[1][nPCodigo])
			Tk280ACG(@aPanels[nPosObj02][1]:aHeader, @aPanels[nPosObj02][1]:aCols,{},aPanels[nPosObj01][1]:aCols[1][nPCodigo], oLbx:aArray[oLbx:nAt][2] , oLbx:aArray[oLbx:nAt][3])
			
			oObjACG	:= aPanels[nPosObj02][1]
			nPosSit := aScan(oObjACG:aHeader, {|x| AllTrim(x[2]) == "ACG_DSITCB"}) 
			If nPosSit > 0
				nPosSit := aScan(oObjACG:aHeader, {|x| AllTrim(x[2]) == "ACG_SITUAC"}) 
				If nPosSit > 0	
					oObjACG:aInfo[nPosSit][2] := " " 
					oObjACG:aInfo[nPosSit][6] := " "
					oObjACG:oBrowse:aColumns[nPosSit]:bData := {|| Transform(oObjACG:aCols[Iif( Len( oObjACG:aCols ) >= oObjACG:oBrowse:nAt, oObjACG:oBrowse:nAt, Len( oObjACG:aCols ) )][nPosSit],Trim(oObjACG:aHeader[nPosSit][3])) }
					oObjACG:Refresh()  
				EndIf 
			EndIf 

			aPanels[nPosObj02][1]:Refresh()
		Endif
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa os dados do panel Novo Pre-atendimento quando ele for selecionado. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oExplorer:nPanel == 6
	//Verifica se NAO foi solicitado uma nova cobranca
	nPos		:= Ascan(aPanels, {|x| x[2]=="FOBJ04"} )		// Titulos a serem cobrados
	nPTitulo	:= Ascan(aPanels[nPos][1]:aHeader, {|x| AllTrim(x[2])=="E1_NUM"} )
	If (Len(aPanels[nPos][1]:aCols) == 0) .OR. (Len(aPanels[nPos][1]:aCols) > 0 .AND. Empty(aPanels[nPos][1]:aCols[1][nPTitulo]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Limpa as enchoices da tela Novo Pré-atendimento que se atualiza automaticamente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk280Memory("SA1", @aMemory, .F.)
		nPos := Ascan(aPanels, {|x| x[2]=="FOBJ02"} )
		aPanels[nPos][1]:Refresh()
			
		Tk280Memory("SU5", @aMemory, .F.)
		nPos := Ascan(aPanels, {|x| x[2]=="FOBJ03"} )
		aPanels[nPos][1]:Refresh()
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do Painel de pendencias no Telemarketing          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oExplorer:nPanel == 7
	nPosObj01	:= Ascan(aPanels, {|x| x[2]=="GOBJ01"} )
	nPosObj02	:= Ascan(aPanels, {|x| x[2]=="GOBJ02"} )
	nPCodigo	:= Ascan(aPanels[nPosObj01][1]:aHeader, {|x| AllTrim(x[2])=="UC_CODIGO"} )
	
	If !aPanels[nPosObj01][3]
		aPanels[nPosObj01][3] := .T.
		
		Tk280SUC(@aPanels[nPosObj01][1]:aHeader, @aPanels[nPosObj01][1]:aCols, M->A1_COD + M->A1_LOJA)
		aPanels[nPosObj01][1]:Refresh()
		
		If !Empty(aPanels[nPosObj01][1]:aCols[1][nPCodigo])
			Tk280SUD(@aPanels[nPosObj02][1]:aHeader, @aPanels[nPosObj02][1]:aCols, aPanels[nPosObj01][1]:aCols[1][nPCodigo])
			aPanels[nPosObj02][1]:Refresh()
		Endif
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do Painel de pendencias no Televendas             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oExplorer:nPanel == 8
	nPosObj01	:= Ascan(aPanels, {|x| x[2]=="HOBJ01"} )
	nPosObj02	:= Ascan(aPanels, {|x| x[2]=="HOBJ02"} )
	nPCodigo	:= Ascan(aPanels[nPosObj01][1]:aHeader, {|x| AllTrim(x[2])=="UA_NUM"} )
	
	If !aPanels[nPosObj01][3]
		aPanels[nPosObj01][3] := .T.
		
		Tk280SUA(@aPanels[nPosObj01][1]:aHeader, @aPanels[nPosObj01][1]:aCols, M->A1_COD, M->A1_LOJA)
		aPanels[nPosObj01][1]:Refresh()
		
		If !Empty(aPanels[nPosObj01][1]:aCols[1][nPCodigo])
			Tk280SUB(@aPanels[nPosObj02][1]:aHeader, @aPanels[nPosObj02][1]:aCols, aPanels[nPosObj01][1]:aCols[1][nPCodigo])
			aPanels[nPosObj02][1]:Refresh()
		Endif
	Endif
Endif

Return(.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK280FinancºAutor ³ Vendas Clientes    º Data ³  07/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza uma consulta financeira disponibilizada pelo modulo º±±
±±º          ³financeiro.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cTipo     - Tipo da consulta financeira que sera realizada. º±±
±±º          ³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±± 
±±º          ³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³aMemory   - Vaiaveis de memoria utilizada pelas MSMGET.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK280Financ( cTipo, oExplorer, aPanels, aMemory, aKey )

Local cCliente	:= ""													// Codigo do cliente
Local nPCliente	:= 0													// Posiçao do campo código do cliente no aCols
Local cLoja		:= ""													// Loja do cliente
Local nPLoja	:= 0													// Posiçao do campo loja do cliente no aCols
Local cPrefixo	:= ""													// Prefixo do título
Local nPPrefixo	:= 0													// Posiçao do campo prefixo no aCols
Local cTitulo	:= ""													// Número do título
Local nPTitulo	:= 0													// Posiçao do campo título no aCols
Local cParcela	:= ""													// Número da parcela
Local nPParcela	:= 0													// Posiçao da campo parcela no aCols
Local cTipoTit	:= ""													// Tipo do título
Local nPTipo	:= 0													// Posiçao do campo tipo do título no aCols
Local oLbx		:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]	// Objeto com dados da agenda
Local oNGD		:= aPanels[Ascan(aPanels, {|x| x[2]=="EOBJ01"} )][1]	// GetDados local de clientes
Local oCOB		:= aPanels[Ascan(aPanels, {|x| x[2]=="EOBJ02"} )][1]	// GetDados local de títulos cobrados
Local aArea		:= GetArea()											// Salva a area atual
Local nI		:= 0
Local aBkpKeys  := aClone(aKey)

DEFAULT aKey 	:= {}

For nI := 1 To Len(aKey)
	Set Key aKey[nI][1] to
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o cliente do folder relacionado e posiciona na base de dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Str(oExplorer:nPanel,1) $ "1234"
	cCliente	:= Eval(oLbx:bLine)[2]
	cLoja		:= Eval(oLbx:bLine)[3]
Endif

If oExplorer:nPanel == 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega os dados do cliente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPCliente	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACF_CLIENT"} )
	nPLoja		:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACF_LOJA"} )
	cCliente	:= oNGD:aCols[oNGD:nAt][nPCliente]
	cLoja		:= oNGD:aCols[oNGD:nAt][nPLoja]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega os dados do título cobrado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPPrefixo	:= Ascan(oCOB:aHeader, {|x| AllTrim(x[2])=="ACG_PREFIX"} )
	nPTitulo	:= Ascan(oCOB:aHeader, {|x| AllTrim(x[2])=="ACG_TITULO"} )
	nPParcela	:= Ascan(oCOB:aHeader, {|x| AllTrim(x[2])=="ACG_PARCEL"} )
	nPTipo		:= Ascan(oCOB:aHeader, {|x| AllTrim(x[2])=="ACG_TIPO"} )
	cPrefixo	:= oCOB:aCols[oCOB:nAt][nPPrefixo]
	cTitulo		:= oCOB:aCols[oCOB:nAt][nPTitulo]
	cParcela	:= oCOB:aCols[oCOB:nAt][nPParcela]
	cTipoTit	:= oCOB:aCols[oCOB:nAt][nPTipo]
Endif

If Str(oExplorer:nPanel,1) $ "678"
	cCliente	:= M->A1_COD
	cLoja		:= M->A1_LOJA
Endif

If !Empty(cCliente) .AND. !Empty(cLoja)
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SA1") + cCliente + cLoja)
		Help("  ",1,"TK280CLIEN")//"Não há nenhum cliente disponível para realizar essa operacao no painel selecionado, no momento"
		RestArea( aArea )
		Return(.F.)
	Endif
	
	Do Case
		Case cTipo == "010"
			If ( Pergunte("FIC010",.T.) )
				Fc010Con("SA1",SA1->(Recno()),2)
		    EndIf
		    
		Case cTipo == "040"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Localiza o título no SE1.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SE1")
			DbSetOrder(2)
			
			If DbSeek( xFilial("SE1") + cCliente + cLoja + 	cPrefixo + cTitulo + cParcela + cTipoTit ) 
				Fc040Con()
			EndIf
	Endcase
Else
	Help("  ",1,"TK280CLIEN")//"Não há nenhum cliente disponível para realizar essa operacao no painel selecionado, no momento"
Endif

For nI := 1 To Len(aKey)
	SetKey(aKey[nI][1], aBkpKeys[nI][2])
Next nI

RestArea( aArea )
	
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280Novo ºAutor  ³ Vendas Clientes    º Data ³  04/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que busca os titulos e o cliente para um operador reaº±±
±±º          ³lizar uma nova cobranca.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³cOperador - Codigo do operador que esta trabalhando.        º±±
±±º          ³aRegras   - Contem as regras de selecao dos titulos de todosº±±
±±º          ³            os operadores para validar qual titulo o opera- º±±
±±º          ³            dor corrente podera trabalhar.                  º±±
±±º          ³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³aMemory   - Variaveis de memoria utilizada pelas MSMGET.    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                            
Static Function Tk280Novo(	oExplorer, cOperador, aRegras, aPanels, ;
							aMemory )

Local nPos			:= 0													// Posicao do array
Local dIni			:= CtoD("//")											// Vencimento inicial dos titulos a cobrar
Local dFim			:= CtoD("//")											// Vencimento final dos titulos a cobrar
Local cOrdem		:= ""													// Ordem de prioridade dos grupos de atendimento
Local aOperad		:= {}													// Codigo e ordem dos Operadores cadastrados
Local cCliente		:= ""													// Codigo do cliente que sera selecionado para a proxima cobranca
Local cLoja			:= ""													// Loja do cliente do que sera selecionado para a proxima cobranca
Local cCliAux		:= ""													// Codigo do cliente auxiliar para avaliacao se pode ser cobrado ou nao
Local cLojAux		:= ""													// Loja do cliente auxiliar para avaliacao se pode ser cobrado ou nao
Local oLbx			:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]	// Agenda do operador
Local nI			:= 0													// Controle de laco
Local lNovo			:= .T.													// Define se o atendimetno e novo ou esta na agenda sem ligacao
Local oNGD			:= aPanels[Ascan(aPanels, {|x| x[2]=="FOBJ04"} )][1]	// Titulos que deverao ser cobrados
Local cSK1			:= "SK1"												// Alias temporario so SK1
Local cTpContat 	:= ""													// Tipo de contato 1- SAC, 2-VENDAS, 3- COBRANCA
Local cTpTel		:= GetNewPar("MV_TMKTPTE","4") 							// Tipo de telefone para geracao da pendencia de novo pre-atendimento. Se nao existir assume como padrao o Comercial1
Local lSelVal		:= GetNewPar("MV_TMKSELV",.F.)							// Indica se na solicitacao de novo pre-atendimento o sistema ira priorizar os titulos mais antigos de maior valor 
Local lSelValN		:= GetNewPar("MV_TMKSELN",.F.)							// Indica se na solicitacao de novo pre-atendimento o sistema ira priorizar os titulos mais novos de maior valor 
Local lRet			:= .F.													// Flag de retorno da funcao
Local nAuxLen 		:= 0	 	 											// Variavel auxiliar para ser usado com FOR - aumento de performance
Local aArea			:= {}													// Salva a area utilizada
Local cLista		:= ""													// Pendencia criada de solicitacao novo-pre atendimento
Local cContato		:= ""													// Codigo do contato para a pendencia de novo-pre atendimento
Local nLidos		:= 0                                                    // Numero de registros lidos no SK1
Local nGravados		:= 0                                                    // Numero de registros gravados com o codigo do operador no SK1
Local cPathLog		:= GetNewPar("MV_TMKDILG","")							// Indica o diretorio onde sera gravado o arquivo de log
Local cArqLog		:= ""													// Arquivo de log para controlar o cliente e loja solicitado em um novo pre-atendimento
Local nErase		:= -1											   		// Controla a delecao do arquivo
Local nHandle		:= 0                                                    // Controle de criacao do arquivo de log
Local lApaga		:= .F.													// Controle para permitir ou nao a delecao do arquivo
Local lTk280SU5		:= ExistBlock("TK280SU5")								// Ponto de entrada para substituir a pesquisa do contato relacionado ao cliente na solicitação de novo pré-atendimento
Local cNumSU4  		:= ""													// Numero sequencial do cabecalho da lista 
Local cNumSU6   	:= ""													// Numero sequencial do item da lista
Local cMay      	:= "" 													// Variavel de controle
Local lTkSeqLista 	:= ExistBlock("TKSeqLista")    							// Indica se a numeracao sequencial das listas (SU4-SU6) Serao geradas por funcao customizada	            
Local lForaFaixa	:= .F. 													// Indica se algum titulo da condicao para cobrar a conta que foi solicitada para o operador 
Local lCobraCli     := .F.                                                 	// Indica se o operador possui pelo menos um titulo dentro da sua faixa e pode cobrar o operador
Local cPrefixo 		:= ""                      								// Prefixo do titulo da regra de selecao
Local cNaturez 		:= ""													// Natureza do titulo da regra de selecao
Local cPortado 		:= ""													// Portador do titulo da regra de selecao
Local cSituaca 		:= ""													// Situacao do titulo da regra de selecao
Local lLimpa		:= .F.													// Flag para controle de variavel
Local lRegSelFlex	:= GetNewPar("MV_TMKREGF",.F.)							// Deixa os campos da regra de selecao flexivel para filtrar a informacao que estiver contida nos campos e nao exatamente igual ao conteudo informado
Local cOperadores	:= ""													// Operadores que possuem regra igual ou superior a do operador atual

Local lPend			:= .F.													// Identifica se o cliente foi encontrado como pendencia do operador no Novo Pre Atendimento
Local cCliPend 		:=""													// Armazena o codigo do cliente da pendencia
Local cLojaPend		:=""													// Armazena o codigo da loja da pendencia
Local nPosPendArr	:= 0 													// Armazena o numero da posicao da pendencia na lista de pendencias do operador
Local nDelTries		:= 0 													// Numero de tentativas para deletar arquivo
Local dMaiorAtraso  := dDataBase											// Armazena a data do titulo com maior atraso 
Local cNomeLock		:= ""													// Nome do Lock para controle de gravacao
Local l280VldNovo	:= ExistBlock("TK280NOV") 								// Ponto de Entrada para validar a execucao de um novo atendimento
Local nPTitulo		:= 0													// Posicao do campo Titulo no aCols
Local nPCliente		:= 0													// Posicao do campo Cliente no aCols
Local nPLoja		:= 0													// Posicao do campo Loja de origem no aCols
Local lRejeita		:= GetNewPar("MV_TMKREJE",.F.)							// Permite que o operador rejeite um atendimento na tela de pre-atendimento
Local aAgenda		:= {}													// Agenda das proximas ligacoes(temporario)
Local lTK280Fil		:= FindFunction("P_TK280QRY")							// Ponto de entrada para alterar o filtro dos títulos
Local cQryAp		:= ""													// Variável de apoio para a Project Function TK280FIL
Local lTK280SQL		:= ExistBlock("TK280SQL")								// Ponto de Entrada para adicionar expressão na query de seleção de títulos
Local cTK280SQL		:= ""													// Variavel para obter o retorno do ponto de entrada
Local nTamDSit		:= GetSx3Cache("ACG_DSITCB","X3_TAMANHO")
Local cSitNewTC		:= GetNewPar( 'MV_TSITCOB', '0|F|G' )					//Situacao dos Titulos Para Serem Considerados pelo Novo Modelo de TeleCobranca
Local lNewRolTLC 	:= IIf( FindFunction( 'Tk280NewTC' ), Tk280NewTC(), .F. )

#IFDEF TOP
	Local cQuery	:= ""													// Query de pesquisa no banco de dados
	Local aStruct	:= SK1->(DbStruct())									// Estrutura da tabela SK1
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o Path estiver com "", deixa em branco. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPathLog == '""'
	cPathLog := ""
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apaga os arquivos de controle criados por esta rotina.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
Tk280DelCB(cPathLog)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o tipo do telefone foi informado corretamente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(cTpTel) > 1) .AND. (At('"',cTpTel) <> 0)
	cTpTel	:= StrTran(cTpTel,'"','')
EndIf
If (Len(cTpTel) > 1) .AND. (At("'",cTpTel) <> 0)
	cTpTel	:= StrTran(cTpTel,"'",'')
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia se o usuario esta posicionado no folder de "NOVO ATENIDIMENTO"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oExplorer:nPanel <> 6
	//"Para solicitar uma nova cobrança é necessário estar posicionado no painel Novo pré-atendimento."
	Help("  ",1,"TK280NOVO")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida de existem follow-ups pendentes para o Operador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(oNGD:aCols) > 0
	nPTitulo	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_NUM"} )
	nPCliente	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_CLIENTE"} )
	nPLoja		:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_LOJA"} )
	If !Empty(oNGD:aCols[1][nPTitulo])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se permitir a rejeicao da cobranca atual, desfaz os rela- ³
		//³cionamentos criados para o cliente/titulo atual           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRejeita			
			Tk280Rejeicao(	cOperador	, oNGD:aCols[1][nPCliente]	, oNGD:aCols[1][nPLoja]	, @oLbx	,;
							@aMemory	, @aPanels					)		         
		Else 
			//"Antes de solicitar um Novo Pré-atendimento, é necessario concluir a solicitação que está 
			// pendente no painel Novo Pré-atendimento"
			Help("  ",1,"TK280NOVO2") 
			Return(lRet)
		EndIf
	Endif
Endif
                                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se tiver lista pra executar, nao pega Titulo novo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Tk280Lista(cOperador)
	//"Existe uma lista de cobrança pendente para ser executada antes de solicitar uma nova cobrança"
	Help("  ",1,"TK280LISTA")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa as enchoices da tela Novo Pré-atendimento que se atualiza automaticamente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk280Memory("SA1", @aMemory, .T.)
	nPos := Ascan(aPanels, {|x| x[2]=="FOBJ02"} )
	If nPos > 0
		aPanels[nPos][1]:Refresh()
	Endif	
		
	Tk280Memory("SU5", @aMemory, .T.)
	nPos := Ascan(aPanels, {|x| x[2]=="FOBJ03"} )
	If nPos > 0 
		aPanels[nPos][1]:Refresh()
	Endif	
	
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os status do painel de pendencias para verificar se pode ou nao pegar um novo pre-atendimento³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
Tk280SU6(@aPanels,.F.,"",.T.)

nAuxLen := Len(oLbx:aArray)				
For nI := 1 To nAuxLen
	// 7=Atendimento, 8=Data, 9=Hora, 10=Status          
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for um follow-up e estiver com o Status (SU4) igual a ATIVO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(oLbx:aArray[nI][7]) .AND. oLbx:aArray[nI][10] == "1"
		//Se a pendencia nao esta atrasada, pode pegar novo atendimento
		If oLbx:aArray[nI][8] <> dDataBase .OR. oLbx:aArray[nI][9] <= SubStr(Time(),1,5) .And. IIf( lNewRolTLC, !Tk280CanAtd( oLbx:aArray[nI][2], oLbx:aArray[nI][3], cOperador, aRegras,, oLbx:aArray ), .T. )

			//"Voce tem pendencia a ser cumprida na sua agenda e nao pode solicitar uma nova cobranca" 
			Help("  ",1,"TK280PEND")
			Return(lRet)
			
		Endif
	Endif
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para validar a execucao de um novo atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l280VldNovo
	aArea := GetArea() // Salva a area
	aAgenda	:= aClone(oLbx:aArray)

	lRet := U_TK280NOV( cOperador, @aAgenda )

	If ValType(aAgenda) == "A"
		oLbx:aArray := aClone(aAgenda)
	EndIf
	
	RestArea( aArea ) // Restaura a area
	
	// Verifica se o retorno eh logico
	If ValType( lRet ) <> "L" .OR. !lRet
		Return(.F.)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ao solicitar uma nova cobranca (Nova Solicitacao Telecobranca), se o  ³
//³operador ja possuir na agenda uma solicitacao que nao tenha sido      ³
//³executada, (U6_CODLIG em branco) nao disponibiliza nova conta,        ³
//³e executa ela primeiro.												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 2=Cliente, 7=Atendimento, 8=Data, 9=Hora, 10=Status
nPos := Ascan(oLbx:aArray, {|x| AllTrim(x[7])=="" .AND. x[10] == "1"})	// Pesquisa pendencia sem atendimento e com status de aberto
If nPos > 0 .AND. !Empty(oLbx:aArray[nPos][2]) .AND. oLbx:aArray[nPos][10] == "1"
	If oLbx:aArray[nPos][8] <> dDataBase .OR. oLbx:aArray[nPos][9] <= SubStr(Time(),1,5)
		cCliente	:= oLbx:aArray[nPos][2]
		cLoja		:= oLbx:aArray[nPos][3]
		cLista		:= oLbx:aArray[nPos][11]
		cCliPend := cCliente
		cLojaPend := cLoja
		nPosPendArr := nPos
		lPend		:= .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca a regra de selecao do operador logado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU7")
DbSetOrder(1)
If DbSeek(xFilial("SU7") + cOperador)

	DbSelectArea("SU0")
	DbSetOrder(1)
	If DbSeek(xFilial("SU0") + SU7->U7_POSTO)

		DbSelectArea("SK0")
		DbSetOrder(1)
		If DbSeek(xFilial("SK0") + SU0->U0_REGSEL)
			nPos	:= Ascan(aRegras, {|x| x[1] == SU0->U0_REGSEL })
			lRet	:= .T.	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se encontrou a Regra de Selecao do usuario pega os dados da regra do operador ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos > 0
				dIni		:= dDataBase - aRegras[nPos][3]		// -----60---------30--------Hoje----
				dFim		:= dDataBase - aRegras[nPos][2]		//      dIni       dFim      dDataBase
				cOrdem		:= SK0->K0_ORDEM
				cPrefixo	:= SK0->K0_PREFIXO
				cNaturez	:= SK0->K0_NATUREZ
				cPortado	:= SK0->K0_PORTADO
				cSituaca	:= SK0->K0_SITUACA
			Endif
		
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao encontrou o operador, o grupo e a regra - ou se a regra nao foi cadastrada - sai da rotina de busca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!lRet) .OR. (nPos <= 0)
	lRet := .F.
	MsgStop(STR0077, STR0078)  	//"O operador, o grupo de atendimento ou a regra de seleção desse usuário não foi localizado no sistema, contacte o Supervisor" , ATEnção
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Muda o cursor no processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o operador pode pegar um novo titulo vencido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lNovo
	DbSelectArea("SU7")
	DbSetOrder(1)
	If DbSeek(xFilial("SU7"))

		While !SU7->(Eof()) .AND. SU7->U7_FILIAL == xFilial("SU7")

			DbSelectArea("SU0")
			DbSetOrder(1)

			If DbSeek(xFilial("SU0") + SU7->U7_POSTO)
				DbSelectArea("SK0")
				DbSetOrder(1)

				If DbSeek(xFilial("SK0") + SU0->U0_REGSEL) .AND. SU0->U0_BOUND <> '1'
					Aadd( aOperad, { SU7->U7_COD, SK0->K0_ORDEM } )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Esses operadores estao no grupo do operador atual ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SK0->K0_ORDEM == cOrdem
						cOperadores+= SU7->U7_COD + ","
					Endif	
				Endif	

			Endif

			DbSelectArea("SU7")
			DbSkip()
		End	
	Endif
	
	If !Empty(cOperadores)
		cOperadores := Left(cOperadores,Len(cOperadores)-1) //Tira a ultima virgula da string
    Endif
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o parametro (de selecao de titulo de maior valor) estiver ligado o sistema  ³	
	//³troca  a chave de indice para fazer a selecao do proximo titulo inadimplemente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SK1")
	DbSetOrder(2)		// DTOS(K1_VENCREA)+K1_CLIENTE+K1_LOJA
	If lSelVal
		If Tk280Dic()//Verifica se o indice para ordenar o SK1 foi criado
			DbSelectArea("SK1")
			DbSetOrder(5)		// DTOS(K1_VENCREA)+STR(K1_SALDEC,17,0)+K1_CLIENTE+K1_LOJA
	    Else
	    	MsgStop(STR0079, STR0078)		//"O parametro MV_TMKSELV esta habilitado para buscar os titulos mais antigos de maior valor na solicitacao de novo pre-atendimento, mas o dicionario de dados nao foi ajustado. Entre em contato com o administrador do sistema." /Atencao
	    	Final(STR0080)			//"Ajustar dicionario de dados"
	    Endif
	Endif
		    
	#IFDEF TOP
		cSK1	:= "TMPSK1"				// Alias temporario do SK1
		cQuery	:=	" SELECT	* " +;
					" FROM " +	RetSqlName("SK1") + " SK1 " +;
					" WHERE	SK1.K1_FILIAL = '" + xFilial("SK1") + "' AND" +;
					"		SK1.K1_VENCREA BETWEEN '" + DtoS(dIni) + "' AND '" + DtoS(dFim) + "' AND"
		
		If !Empty(cPrefixo) 
			If !lRegSelFlex
				cQuery += " SK1.K1_PREFIXO = '" + cPrefixo + "' AND"
			Else
				cQuery += " SK1.K1_PREFIXO LIKE ('%" + Alltrim(cPrefixo) + "%') AND"			
			Endif
		Endif
		
		If !Empty(cNaturez)
			If !lRegSelFlex
				cQuery += " SK1.K1_NATUREZ = '" + cNaturez + "' AND"
			Else
				cQuery += " SK1.K1_NATUREZ LIKE ('%" + Alltrim(cNaturez) + "%') AND"
			Endif	
		Endif
		
		If !Empty(cPortado)
			If !lRegSelFlex
				cQuery += " SK1.K1_PORTADO = '" + cPortado + "' AND"
			Else
				cQuery += " SK1.K1_PORTADO LIKE ('%" + Alltrim(cPortado) + "%') AND"
			Endif	
		Endif
		
		If ( lNewRolTLC )
			cQuery += " SK1.K1_SITUACA IN "+ FormatIn( cSitNewTC , "|" ) +" AND "
		Else
			If !Empty(cSituaca)
				If nTamDSit <> Nil .Or. ( cSituaca <> Padr("7",TamSx3("K0_SITUACA")[1]) )		// Todos
					cQuery += " SK1.K1_SITUACA = '" + cSituaca + "' AND"
				EndIf
			Endif
		EndIf
		// Desconsidera os titulos marcados para nao serem cobrados.
		cQuery += " SK1.K1_OPERAD <> 'XXXXXX' AND"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura titulo novo apenas para os titulos que ainda nao foram cobrados. ³
		//³Se a ligacao nao foi realizada ao pedir um novo nao vai passar aqui.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cOperadores) .AND. !lPend
			If !( lNewRolTLC )
				cQuery +=" SK1.K1_OPERAD NOT IN " + FormatIn(cOperadores,",") + " AND "
			Else
				cQuery += " ( ( SK1.K1_OPERAD = '"+ CriaVar( 'K1_OPERAD', .F. ) +"' ) "
				cQuery += " OR "
				cQuery += "   ( SK1.K1_OPERAD = '"+ cOperador +"' AND "
				cQuery += "   NOT EXISTS( 	SELECT 1 "
				cQuery += "   				FROM "+ RetSQLName( 'ACG' ) +" ACG "
				cQuery += "   				WHERE ACG.ACG_FILORI = SK1.K1_FILIAL AND " 
				cQuery += "   					ACG.ACG_PREFIX = SK1.K1_PREFIXO AND "  
				cQuery += "   					ACG.ACG_TITULO = SK1.K1_NUM AND "  
				cQuery += "   					ACG.ACG_PARCEL = SK1.K1_PARCELA AND "  
				cQuery += "   					ACG.ACG_TIPO = SK1.K1_TIPO AND "  
				cQuery += "   					ACG.D_E_L_E_T_ = ' ' "  
				cQuery += " 			) )"
				cQuery += " ) AND SK1.K1_DTFRENE = '        ' AND SK1.K1_HRFRENE = '     ' AND "
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura apenas os titulos da pendencia, quando se aplica.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPend	
			cQuery +=" SK1.K1_CLIENTE = '" + cCliente + "' AND SK1.K1_LOJA = '" + cLoja + "' AND "
			If ( lNewRolTLC )
				cQuery +=" SK1.K1_DTFRENE = '        ' AND SK1.K1_HRFRENE = '     ' AND "
			EndIf
		EndIf
		
		//Verifica se o ponto de entrada e adiciona condições no Where
		If lTK280SQL
			cTK280SQL := ExecBlock("TK280SQL",.F.,.F.,{} )
			If !Empty(cTK280SQL)
				cQuery += cTK280SQL + " AND "
			EndIf	
		EndIf
		
		cQuery += 	" SK1.D_E_L_E_T_ 	= ' '	"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Elimina os registros do SK1 ja analisados para o dia atual³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("SKV") + " SKV"
		cQuery += " WHERE SKV.KV_CLIENTE = SK1.K1_CLIENTE AND SKV.KV_LOJA = SK1.K1_LOJA " 
		cQuery += " AND SKV.KV_FILIAL = '" + xFilial("SKV") + "'"
		cQuery += " AND SKV.KV_ORDEM = '" + cOrdem + "' AND SKV.D_E_L_E_T_ = ' '  )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Indica se vai priorizar os titulos mais NOVOS de maior valor na solicitacao de novo pre atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSelValN 
			cQuery +=	" ORDER BY K1_FILIAL, K1_VENCREA DESC, K1_SALDEC, K1_CLIENTE, K1_LOJA " 
		Else
			cQuery +=	" ORDER BY " + SqlOrder(IndexKey())
		Endif	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o ponto de entrada existe, se sim verifica se o retorno³
		//³do mesmo é caracter, se sim a variável cQuery recebe a do PE.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTK280Fil
			cQryAp := P_TK280QRY(dIni, dFim, cPrefixo, cNaturez,;
								cPortado, cSituaca, cOperadores, cCliente,;
								cLoja, cOrdem, lSelValN, lPend,;
								cQuery)
			If ValType(cQryAp) == "C"
				cQuery := cQryAp
			EndIf
		EndIf
		
		cQuery	:= ChangeQuery(cQuery)
		MemoWrite("TK280Novo.SQL", cQuery)

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSK1, .F., .T.)
	
		For nI := 1 To Len(aStruct)
			If aStruct[nI][2] $ "NDL"
				TCSetField(cSK1, aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
			Endif
		Next nI
	#ELSE
		If !lPend	                                    		                
			DbSeek(xFilial("SK1")+DtoS(dIni), .T.)		
		Else		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura apenas os titulos da pendencia, quando se aplica.                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSeek(xFilial("SK1")+DtoS(dIni)+cCliente+cLoja, .T.)		
		EndIf		
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se estiver procurando titulos de uma pendencia, limpa as variaveis de cliente |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPend	
		cCliente	:= ""
		cLoja		:= ""		
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera lista de clientes rejeitados para o operador atual³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRejeita	:= LeRejeicao(cPathLog,cOperador)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre os titulos selecionados do SK1 para verificar se estao dentro da regra e qual deles pode ser atribuido ao operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While	!(cSK1)->(Eof())						.AND.;
			(cSK1)->K1_FILIAL == xFilial("SK1")	.AND.;
			(cSK1)->K1_VENCREA >= dIni				.AND.;
			(cSK1)->K1_VENCREA <= dFim

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pula os clientes rejeitados pelo operador³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aRejeita) > 0 .AND. (aScan(aRejeita,{|x| x[1] == (cSK1)->K1_CLIENTE .AND. x[2] == (cSK1)->K1_LOJA}) > 0 )
			DbSelectArea(cSK1)
			DbSkip()
			Loop
		EndIf			

		If ( lNewRolTLC )
			If !lPend 
				If !Empty( (cSK1)->K1_DTFRENE ) .And. !Empty( (cSK1)->K1_HRFRENE )
					DbSelectArea(cSK1)
					DbSkip()
					Loop
				EndIf

				If !Tk280CanAtd( (cSK1)->K1_CLIENTE, (cSK1)->K1_LOJA, cOperador, aRegras,,oLbx:aArray )
					DbSelectArea(cSK1)
					DbSkip()
					Loop
				EndIf
			Else
				If !Empty( (cSK1)->K1_DTFRENE ) .And. !Empty( (cSK1)->K1_HRFRENE )
					DbSelectArea(cSK1)
					DbSkip()
					Loop
				EndIf
			EndIf
		EndIf			
		DbSelectArea("SKV")
		DbSetOrder(1) //KV_FILIAL+KV_DATA+KV_CLIENTE+KV_LOJA+KV_ORDEM

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Cria o arquivo com o seguinte nome: K0_ORDEM + K1_CLIENTE + K1_LOJA + DATE() + ".COB" |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		cNomeLock := cOrdem+(cSK1)->(K1_CLIENTE+K1_LOJA)+DtoS(Date())+".LCK"
		
		If SKV->(DbSeek(xFilial("SKV")+DtoS(Date())+(cSK1)->(K1_CLIENTE+K1_LOJA)+cOrdem))//File(cPathLog + cArqLog) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Se o arquivo ja existir, indica q ja foi analizado hoje por outro operador e resultou |
			//|que nao poderia ser cobrado conforme a regra de selecao associada a eles.             |				
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			            
			DbSelectArea(cSK1)
			DbSkip()
			Loop			
		Else                                                                                                        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Cria o arquivo de controle, desta maneira, nao permite que mais de um operador analise o mesmo cliente                  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			DbSelectArea("SKV")

			If Tk280Lock(cNomeLock,cPathLog) .AND. RecLock("SKV",.T.)
				
				Replace SKV->KV_FILIAL	With xFilial("SKV")
				Replace SKV->KV_ORDEM	With AllTrim(cOrdem)
				Replace SKV->KV_CLIENTE	With (cSK1)->K1_CLIENTE
				Replace SKV->KV_LOJA 	With (cSK1)->K1_LOJA
				Replace SKV->KV_DATA  	With Date()
				Replace SKV->KV_HORA 	With Time()
				Replace SKV->KV_OPERAD	With cOperador
				
				MsUnLock()
			    
			    Tk280UnLock(cNomeLock,cPathLog)
				
				lApaga := .F.					
			Else
				DbSelectArea(cSK1)
				DbSkip()
				Loop						
			EndIf				
		EndIf		
		
		#IFNDEF TOP
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for CODEBASE valida a selecao do titulo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			// Nao carrega titulos com marcas de excecao de cobranca
			If (cSK1)->K1_OPERAD == "XXXXXX"
				DbSelectArea(cSK1)
				DbSkip()
				Loop
			Endif

			If ( !Empty(cPrefixo) ) .AND. ( (cSK1)->K1_PREFIXO <> cPrefixo )
				DbSelectArea(cSK1)
				DbSkip()
				Loop
			Endif
			
			If ( !Empty(cNaturez) ) .AND. ( (cSK1)->K1_NATUREZ <> cNaturez )
				DbSelectArea(cSK1)
				DbSkip()
				Loop
			Endif
			
			If ( !Empty(cPortado) ) .AND. ( (cSK1)->K1_PORTADO <> cPortado )
				DbSelectArea(cSK1)
				DbSkip()
				Loop
			Endif
			
			If ( !Empty(cSituaca) .And. ( nTamDSit <> Nil .Or. cSituaca <> Padr("7",TamSx3("K0_SITUACA")[1]) ) .And. (cSK1)->K1_SITUACA <> cSituaca ) 
				DbSelectArea(cSK1)
				DbSkip()
				Loop
			Endif
			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Despreza os titulos em que o operador responsavel pertence ao mesmo grupo ou superior.|
			//| Se a ligacao nao foi realizada ao pedir um novo nao vai passar aqui.     			  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cOperadores) .AND. !lPend				
				If ( !Empty((cSK1)->K1_OPERAD) ) .AND. At((cSK1)->K1_OPERAD, cOperadores)>0 				
					DbSelectArea(cSK1)
					DbSkip()
					Loop				
				EndIf
			Endif				
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura apenas os titulos da pendencia, quando se aplica.                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lPend	
				If(	!((cSK1)->K1_CLIENTE ==cCliPend .AND. (cSK1)->K1_LOJA==cLojaPend))
					DbSelectArea(cSK1)
					DbSkip()
					Loop						
				EndIf
			EndIf
			
		#ENDIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Salva a area atual                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFNDEF TOP
			aArea := GetArea()					// Controle diferente para DBF por que nao utiliza arquivo temporario
		#ENDIF  

		If cCliAux == (cSK1)->K1_CLIENTE .AND. cLojAux == (cSK1)->K1_LOJA
			DbSelectArea(cSK1)
			DbSkip()
			Loop
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta um cliente pre-selecionado para validacao                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCliAux	:= (cSK1)->K1_CLIENTE		
			cLojAux	:= (cSK1)->K1_LOJA			
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa no SK1 se todos os titulos desse cliente satisfazem a regra de selecao do operador³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SK1")
		DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
		If DbSeek(xFilial("SK1") + cCliAux + cLojAux)
			cCliente	:= SK1->K1_CLIENTE
			cLoja		:= SK1->K1_LOJA
			lLimpa 		:= .F.			
	                                                                                                
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente analisa os clientes quando foi possivel criar o arquivo. Se o arquivo nao foi      |       
			//³criado, indica que ele pode estar sendo tratado por outro operador ao mesmo tempo.         |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	        	
        	lLimpa := Tk280ChkSE1(cCliente, cLoja, aRegras, cOrdem, dIni, dFim, aOperad, !lPend, .F.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o cliente nao atende as especificicacoes desse operador para |
			//|a cobranca.													   ³
			//³Nao ha titulos que se enquadrem na regra de selecao do operador ³ 
			//³ou ha um titulo na faixa superior.                              ³
			//³Verifica se o titulo de maior atraso esta fora da faixa do      |
			//|operador       												   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (!lLimpa)
				cCliente:= ""
				cLoja	:= ""
			Endif           						
		Endif
		
		#IFNDEF TOP
			RestArea(aArea)
		#ENDIF
		
		If !Empty(cCliente) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chegou neste ponto! O Cliente sera cobrado por este Operador.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Exit
		Endif  		
		
		DbSelectArea(cSK1)
		DbSkip()
	End                    
	
	#IFDEF TOP
		DbSelectArea(cSK1)
		DbCloseArea()
	#ENDIF 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa novamente a variavel apos as validacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := .F.   
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se estiver procurando titulos de uma pendencia, nao entra na rotina de alocacao de titulos para o operador |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPend 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Indica que a pendencia nao e mais valida	         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                             
		If Empty(cCliente) .AND. Empty(cLoja)     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Encerra a pendencia gerada para o operador        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                             		
            BEGIN TRANSACTION
            	DbSelectArea("SU4")
            	DbSetOrder(1) // U4_FILIAL+U4_LISTA
            	DbSeek(xFilial("SU4")+cLista)
            	If 	!SU4->(EOF()) .AND.;                 
            		SU4->U4_FILIAL == xFilial("SU4") .AND.;
            		SU4->U4_LISTA == cLista 
            		
            		RecLock("SU4", .F.)                       		
            		REPLACE SU4->U4_STATUS WITH "2"
            		MsUnlock()
            	EndIf     
            	
            	DbSelectArea("SU6")
            	DbSetOrder(1) // U6_FILIAL+U6_LISTA
            	DbSeek(xFilial("SU6")+cLista)
            	While 	!SU6->(EOF()) .AND.;
            			SU6->U6_FILIAL == xFilial("SU6") .AND.;
            			SU6->U6_LISTA == cLista;
            	                           
	            		RecLock("SU6", .F.)                       		
	            		REPLACE SU6->U6_STATUS WITH "3"
	            		MsUnlock()            	   		
            			DbSelectArea("SU6")
            			DbSkip()		
            	End            	            	    
            	cLista := ""            
            END TRANSACTION
            
            oLbx:aArray[nPosPendArr][1] := LoadBitmap( GetResources(), "BR_VERMELHO" )
            oLbx:aArray[nPosPendArr][10]:= "3"            
            oLbx:Refresh()
            Aviso(STR0094, STR0095 + CRLF + STR0096 + CRLF, {"OK"})// "Pendencias do Pré-Atendimento" # "A pendencia de novo pré-atendimento será encerrada por não mais se enquadrar nos critérios de cobrança do operador." # "Clique no botão 'Novo' e solicite uma nova cobrança."		
		Else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fecha a criacao do arquivo e habilita o flag para apagar no final do processo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lApaga := .T.		
		EndIf
	Else	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A gravacao do operador no SK1 esta sendo realizada antes de gerar a pendencia para evitar³
		//³que mais de um Operador cobre o mesmo cliente.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cCliente) .AND. !Empty(cLoja)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fecha a criacao do arquivo e habilita o flag para apagar no final do processo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lApaga := .T.
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Uma vez que o titulo sera atribuido ao operador atualiza o SK1 com essa informacao - para os outros titulos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SK1")
			DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
			If DbSeek(xFilial("SK1") + cCliente + cLoja)
			
				BEGIN TRANSACTION
	
					nLidos    := 0 
					nGravados := 0 
					
					While	!SK1->(Eof())					.AND.;
						SK1->K1_FILIAL 	== xFilial("SK1")	.AND.;
						SK1->K1_CLIENTE == cCliente			.AND.;
						SK1->K1_LOJA 	== cLoja
	
			            nLidos ++
			                
		                Reclock("SK1",.F.)
						REPLACE SK1->K1_OPERAD With cOperador
						MsUnLock()
						DbCommit()
	
						nGravados ++
															
						DbSelectArea("SK1")
						Dbskip()								
					End                 
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se para todos os registros lidos no SK1 foi gravado o codigo do operador gera a pendencia de novo pre-atendimento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nLidos == nGravados
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busca o proximo numero para a lista³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SU4")
						If lTkSeqLista  
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Executa um P.E. para atualizar o semaforo por rdmake - exclusivo para DADALTO³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cNumSU4:= U_TkSeqLista("SU4","U4_LISTA")
						Else
							cNumSU4:= Tk280Num("SU4","U4_LISTA")
						Endif		
											
						RecLock("SU4", .T.)
						REPLACE SU4->U4_FILIAL	With xFilial("SU4")
						REPLACE SU4->U4_LISTA	With cNumSU4
						REPLACE SU4->U4_DESC	With STR0022 //"NOVO PRE-ATENDIMENTO TELECOBRANCA"
						REPLACE SU4->U4_DATA	With dDataBase
						REPLACE SU4->U4_TIPO	With "2"		//Cobranca
						REPLACE SU4->U4_FORMA	With "5"		//Pendencia
						REPLACE SU4->U4_TELE	With "3"		//Telecobranca
						REPLACE SU4->U4_OPERAD	With cOperador
						REPLACE SU4->U4_TIPOTEL	With cTpTel	//Tipo de Telefone para geracao da pendencia. 
						REPLACE SU4->U4_STATUS	With "1"		//Ativa
						MsUnLock()
			            
			            cLista := cNumSU4
			            
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busca o proximo numero para a lista³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SU6")
						
						If lTkSeqLista                                            			
							cNumSU6:= U_TkSeqLista("SU6","U6_CODIGO")
						Else
							cNumSU6:= Tk280Num("SU6","U6_CODIGO") 
						Endif
								            
						RecLock("SU6", .T.)
						REPLACE SU6->U6_FILIAL	With xFilial("SU6")
						REPLACE SU6->U6_LISTA	With cLista
						REPLACE SU6->U6_CODIGO	With cNumSU6
						REPLACE SU6->U6_FILENT	With xFilial("SA1")
						REPLACE SU6->U6_ENTIDA	With "SA1"
						REPLACE SU6->U6_CODENT	With cCliente + cLoja
						REPLACE SU6->U6_ORIGEM	With "3"
						REPLACE SU6->U6_DATA	With dDataBase
						REPLACE SU6->U6_HRINI 	With Time()
						REPLACE SU6->U6_HRFIM	With "23:59"
						REPLACE SU6->U6_STATUS	With "1"

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava a database do sistema para o registro, independente³
						//³da data do retorno                                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						REPLACE SU6->U6_DTBASE	With dDataBase
						MsUnLock()
	
					Endif	
				
				END TRANSACTION 
			Endif	

		Endif	
    EndIf // lPend
Endif //lNovo
		
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apaga o arquivo de log se ja existir gravado apenas para o operador que o gravou³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApaga
	SKV->(DbSetOrder(1))
	If SKV->(DbSeek(xFilial("SKV")+DtoS(Date())+cCliente + cLoja+cOrdem))
		RecLock("SKV",.F.)
		DbDelete()
		MsUnLock()
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta o cursor apos o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CursorArrow()

If Empty(cCliente)
	DbSelectArea("SA1")
	DbGoTo(0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao exibe o help em caso de Pendencia. Ja foi exibido um Help antes, informando a situacao para o operador|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPend
		Help("  ",1,"TK280NCOBR")//"Não foi possível encontrar nenhuma cobrança para você relizar, considerando suas regras de seleção."
	EndIf	
	Return(lRet)
Endif
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do cliente que sera cobrado na enchoice.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1") + cCliente + cLoja)
	Tk280Memory("SA1", @aMemory, .T.)
	nPos := Ascan(aPanels, {|x| x[2]=="FOBJ02"} )
	If nPos > 0 
		aPanels[nPos][1]:Refresh()
    Endif
Endif
                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existir o ponto de entrada que retorna o codigo do contato para o cliente ³
//³substitiu a verificacao padrao                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTk280SU5
	cContato := U_TK280SU5(cCliente,cLoja)
	
	If !Empty(cContato)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valido se o contato esta relacionado com o cliente.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("AC8")
		DbSetOrder(1)
		If !DbSeek(xFilial("AC8") + cContato + "SA1" + xFilial("SA1") + cCliente + cLoja)
			cContato := ""
		Endif		
	Endif

Else                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza os dados do contato que sera cobrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AC8")
	DbSetOrder(2)
	If DbSeek(xFilial("AC8") + "SA1" + xFilial("SA1") + cCliente + cLoja)
	
		While 	!AC8->(Eof())					.AND.;
		     AC8->AC8_ENTIDA == "SA1"			.AND.;
			 AC8->AC8_FILENT == xFilial("SA1") 	.AND.;
		 	 TRIM(AC8->AC8_CODENT) == TRIM(cCliente + cLoja)
	
			DbSelectArea("SU5")
			DbSetOrder(1)
			If DbSeek(xFilial("SU5") + AC8->AC8_CODCON)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca o contato que tenha o campo U5_TIPO preenchido com ³
				//³3- COBRANCA, pois indica que o contato e de COBRANCA.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SU5->U5_TIPO == "3" //Cobranca
				   cTpContat:= "3"
				   cContato	:= SU5->U5_CODCONT 
				   
				   Exit
				Endif       
				
			Endif	
	
			DbSelectArea("AC8") 
			Dbskip()
		End	               
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao existirem contatos para o cliente do tipo COBRANCA, pega o primeiro cadastrado para realizar o contato ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cTpContat)
		DbSelectArea("AC8")
		DbSetOrder(2)
		If DbSeek(xFilial("AC8") + "SA1" + xFilial("SA1") + cCliente + cLoja)             
			DbSelectArea("SU5")
			DbSetOrder(1)
			If DbSeek(xFilial("SU5") + AC8->AC8_CODCON)
				cContato:= SU5->U5_CODCONT
			Endif	
		Endif	
	Endif
		
Endif	                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acabaram as validacoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o codigo do contato no follow-up (pendencia)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cContato) 
	nPos := Ascan(oLbx:aArray, {|x| AllTrim(x[2]) + AllTrim(x[3]) == Alltrim(cCliente) + Alltrim(cLoja) .And. IIf( lNewRolTLC, x[10] <> '3', .T. ) })
	If nPos > 0 
		cLista:= oLbx:aArray[nPos][11]
		If Empty(oLbx:aArray[nPos][5])
			oLbx:aArray[nPos][5]:=cContato
			oLbx:aArray[nPos][6]:=Posicione("SU5",1,xFilial("SU5")+cContato,"U5_CONTAT")
			oLbx:Refresh()  
		Endif	
    Endif
    
	If !Empty(cLista)
		DbSelectArea("SU6")
		DbSetOrder(1)
		If DbSeek(xFilial("SU6") + cLista)
			Reclock("SU6",.F.)
			REPLACE SU6->U6_CONTATO With cContato
			MsUnlock()
		Endif
	Endif	 
	
Endif
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do CONTATO na enchoice de acordo com o contato posicionado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cContato)
	//Nao inicializa os campos de variaveis de memoria da enchoice porque nao existe um contato
	//o operador ira incluir no pre-atendimento
	Tk280Memory("SU5", @aMemory, .F.) 
Else
	DbSelectArea("SU5")
	DbSetOrder(1)
	If DbSeek(xFilial("SU5")+cContato)
		Tk280Memory("SU5", @aMemory, .T.)
	Endif	
Endif

nPos := Ascan(aPanels, {|x| x[2]=="FOBJ03"} )
If nPos > 0
	aPanels[nPos][1]:Refresh()
Endif	
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do browser com os Titulos que deverao ser cobrados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan(aPanels, {|x| x[2]=="FOBJ04"} )
If nPos > 0 
	Tk280SK1(@aPanels[nPos][1]:aHeader, @aPanels[nPos][1]:aCols, @aPanels[Ascan(aPanels, {|x| x[2]=="FOBJ05"} )][1], cCliente, cLoja)
	aPanels[nPos][1]:Refresh()
Endif

// Prepara o painel de Pendencia no Telemarketing para ser atualizado na sua selecao
nPos := Ascan(aPanels, {|x| x[2]=="GOBJ01"} )                                                           
If nPos > 0
	aPanels[nPos][3] := .F.
Endif	

// Prepara o painel de Televendas pendente para ser atualizado na sua selecao
nPos := Ascan(aPanels, {|x| x[2]=="HOBJ01"} )
If nPos > 0
	aPanels[nPos][3] := .F.
Endif	

// Atualiza a agenda do operador depois que pediu uma nova cobranca
If lNovo
	Tk280SU6(@aPanels,lNovo,cLista,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkGrvSUV(__cUserId, "PRE1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta o cursor apos o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CursorArrow()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK280AtendºAutor  ³ Vendas Clientes    º Data ³  17/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a tela do atendimento baseada na tela do pre-atendi-º±±
±±º          ³mento.                                                      º±±
±±º          ³O atendimento podera ser novo ou retorno de agendamento.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³aRegras   - Contem as regras de selecao dos titulos de todosº±±
±±º          ³            os operadores para validar qual titulo o opera- º±±
±±º          ³            dor corrente podera trabalhar.                  º±±
±±º          ³cOperador - Codigo do operador que esta trabalhando.        º±±
±±º          ³aMemory   - Vaiaveis de memoria utilizada pelas MSMGET.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK280Atend(oExplorer, aPanels, aRegras, cOperador,;
						   aMemory	, aKey)

Local oLbx		:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]			// agend do operador
Local aRotAux	:= Aclone(aRotina)												// Copia do arotina
Local cTipoAte	:= TkGetTipoAte()												// Folders do atendimento
Local oNGD		:= aPanels[Ascan(aPanels, {|x| x[2]=="FOBJ04"} )][1]			// Titulo que serao cobrados
Local nPPrefixo	:= 0															// Posicao de array
Local nPTitulo	:= 0															// Posicao de array
Local nPParcela	:= 0	   														// Posicao de array
Local nPTipo	:= 0															// Posicao de array
Local aItens	:= {}															// Itens que serao enviados para o atendimento
Local nI		:= 0 															// Contador
Local cEncerra	:= GetNewPar("MV_TMKENC","")									// Codigo de Encerramento padrao para encerrar atendimentos telecobranca  
Local cMotivo	:= GetNewPar("MV_TMKMEMO","")									// Observacao padrao para motivo de encerramento 
Local cEntidade	:= "SA1"                                                       	// Entidade 
Local cItem		:= oLbx:aArray[oLbx:nAt][12]									// Codigo do item da lista (U6_CODIGO)
Local cLista    := oLbx:aArray[oLbx:nAt][11]                                  	// Codigo da lista
Local cCodCont	:= oLbx:aArray[oLbx:nAt][5]                                   	// Codigo do Contato
Local cCodCli 	:= oLbx:aArray[oLbx:nAt][2]							  	    // Codigo do cliente
Local cLojaCli	:= oLbx:aArray[oLbx:nAt][3]									// Loja do cliente
Local cCodLig	:= oLbx:aArray[oLbx:nAt][7]									// Codigo do Atendimento 
Local cDDD     	:= ""															// DDD do telefone do contato 			
Local cDDI      := ""															// DDI do telefone do contato 
Local cTel	    := ""															// Telefone do contato de acordo com o U4_TIPOTEL 
Local nPFilOrig	:= 0                                                           	// Filial de origem
Local nPos		:= 0															// Contador auxiliar para Array
Local lRet		:= .F.															// Retorno da funcao
Local nTel		:= 0															// Telefone que será usado para discagem
Local aAuxKey	:= aClone(aKey)													// Copia do array com os SETKEYS
Local nTipoTel	:= 0															// Tipo do telefone para contato
Local cTipoTel	:= GetNewPar("MV_TMKTPTE","4")									// Tipo do telefone para contato(quando lido via parametro)
Local lVldCobra	:= ExistBlock("TK280COB")										// Ponto de entrada executado para validar a cobranca
Local aAreaPE	:= {}															// Array utilizado para salvar ambiente antes do ponto de entrada
Local lExec		:= .T.
Local lForceAtd := .F.
Local lNewRolTLC 	:= IIf( FindFunction( 'Tk280NewTC' ), Tk280NewTC(), .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se estiver em qualquer um dos paineis que pertenca ao de pendencias agendadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Str(oExplorer:nPanel,1) $ "1234"
	// Valida se existe algum cliente para efetuar a discagem
	If Empty(cCodCli) .AND. Empty(cLojaCli)
		Help("  ",1,"TK280CLIEN")//Não há nenhum cliente disponível para realizar esta operação, no painel selecionado, no momento.
		Return(lRet)
	Endif
			  
	// 10-Status
	If oLbx:aArray[oLbx:nAt][10] <> "1"		// 1 = Pendente
		Help("  ",1,"TK280REALI")//O contato para este cliente já foi relizado.
		Return(lRet)
	Endif
	
	// 07-Atendimento em branco (U6_CODLIG) significa que foi solicitada uma nova cobranca mas nao foi executada
	If Empty(oLbx:aArray[oLbx:nAt][7])
		MsgStop(STR0066,STR0065)//"Esta agenda é referente a um novo pré-atendimento que foi solicitado e deverá ser executada pela tela de Novo Pré-atendimento")//Help("  ",1,"TK280TENTA")
		Return(lRet)
	Endif
	
	// 08-Data, 09-Hora
	If oLbx:aArray[oLbx:nAt][8] == dDataBase .AND. oLbx:aArray[oLbx:nAt][9] > SubStr(Time(),1,5)
		If !TMKOK(STR0023 + oLbx:aArray[oLbx:nAt][9] + STR0024 + SubStr(Time(),1,5) + STR0025) //"Este contato está agendado para às "###" h. e agora são "###" h. Deseja realizar o retorno agora."
			Return(lRet)
		Else
			lForceAtd := IIf( lNewRolTLC, .T., .F. )
		Endif
	Endif
	
	nPos := Ascan(aPanels, {|x| x[2]=="FOBJ04"} )
	If Len(aPanels[nPos][1]:aCols) > 0
		If !Empty(aPanels[nPos][1]:aCols[1][Ascan(aPanels[nPos][1]:aHeader, {|x| AllTrim(x[2])=="E1_NUM"} )])
			Help("  ",1,"TK280NOVO1")//Foi solicitado um Novo Pré-atendimento e o atendimento deverá ser executado para ele primeiro
			Return(lRet)
		Endif
	Endif

Endif

If Str(oExplorer:nPanel,1) $ "5678" .AND. Empty(M->A1_COD)
	Help("  ",1,"TK280CLIEN")//Não há nenhum cliente disponível para realizar esta operação, no painel selecionado, no momento.
	Return(lRet)
	
ElseIf Str(oExplorer:nPanel,1) $ "5678" 
	//Atualiza o codigo do contato e lista para o painel de pre-atendimento
	nPos	:= 0
	cCodCli := M->A1_COD
	cLojaCli:= M->A1_LOJA
	cCodCont:= M->U5_CODCONT
	nPos 	:= Ascan(oLbx:aArray, {|x| ( Alltrim(x[2]) + Alltrim(x[3]) == Alltrim(cCodCli) + Alltrim(cLojaCli) ) ;
								.AND.  ( Alltrim(x[5]) == Alltrim(cCodCont) );
								.AND. x[10] == "1" .AND. Empty(x[7]) }) //Mesmo cliente/ contato/ em aberto / sem atendimento
	If nPos > 0 
		cLista 	:= oLbx:aArray[nPos][11]
		cCodLig	:= oLbx:aArray[nPos][7]
		cItem	:= oLbx:aArray[nPos][12]
	Endif	
Endif

If ( lNewRolTLC )
	lExec := Tk280CanAtd( cCodCli, cLojaCli, cOperador, aRegras, lForceAtd )
EndIf

If !( lExec )
	Help(,,"TK280CANATD",,STR0124,1,0) //"Não e Possivel Entrar em Contato com Cliente Devido o Tempo de Retorno do Grupo de Atendimento ainda não ter Sido Concluido"
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega os campos que compoem o telefones no cadastro de contatos para realizar a discagem	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !Empty(cCodCont)

		nTipoTel := Val(Posicione("SU4",1,xFilial("SU4")+cLista,"U4_TIPOTEL"))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Certifica que o tipo do telefone esta gravado corretamente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipoTel == 0
			cTipoTel := StrTran(cTipoTel,'"','')
			cTipoTel := StrTran(cTipoTel,"'",'')
			nTipoTel := Val(cTipoTel)
		EndIf

		cDDD := AllTrim(TkDadosContato(cCodCont,8))
		cDDI := AllTrim(TkDadosContato(cCodCont,9))
		cTel := AllTrim(TkDadosContato(cCodCont,nTipoTel))

	Endif
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao existir telefone cadastrado, percorre o cadastro do contato a fim de identificar um telefone para discagem. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF Empty(cTel)                                
		If !Empty(cCodCont)
			For nTel:= 1 to 5
				cTel := AllTrim(TkDadosContato(cCodCont,nTel))
				If !Empty(cTel)
					Exit
				Endif	
			Next nTel                                          
		Endif
		
		If Empty(cTel)
			Aviso(STR0078, STR0090 ,{"OK"}) 		//"Atenção" /"O contato selecionado nao possui um telefone para efetuar a discagem. Por favor, informe um telefone no cadastro de contatos para realizar a discagem!"
			lRet:=.F.
			Return(lRet)
		Endif	
	Endif
	aRotina	:= {	{ STR0026	,"AxPesqui"        ,0,1 },; //"Pesquisar"
					{ STR0027	,"TK271CallCenter" ,0,2 },; //"Visualizar"
					{ STR0028	,"TK271CallCenter" ,0,3 },; //"Incluir"
					{ STR0028	,"TK271CallCenter" ,0,4 },; //"Incluir"
					{ STR0028	,"TK271CallCenter" ,0,5 },; //"Incluir"
					{ STR0028	,"TK271CallCenter" ,0,6 }} //"Incluir"
	INCLUI := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre somente o atendimento de Telecobranca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkGetTipoAte("3")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa o ponto de entrada antes de cobrar o cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVldCobra

		aAreaPE	:= GetArea()
		lRet 	:= U_TK280COB(cOperador,cCodCli, cLojaCli, cLista)
		RestArea(aAreaPE)

		// Verifica se o retorno eh logico
		If ValType( lRet ) <> "L" .OR. !lRet
			Return(.F.)
		Endif

		//Restaura o valor antigo de lRet
		lRet := .F.

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a funcao para verificar se o cliente pode ser cobrado pelo operador	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Tk280ChkSE1(cCodCli, cLojaCli, aRegras)
		
		nPos := Ascan(oLbx:aArray, {|x| ( Alltrim(x[2]) + Alltrim(x[3]) )  == ( Alltrim(cCodCli) + Alltrim(cLojaCli) )})
		If nPos > 0
			oLbx:aArray[nPos][10] := "2" 
			oLbx:Refresh()
		Endif
		
		BEGIN TRANSACTION
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Encerra a pendencia do operador para o atendimento que teve todos os titulos pagos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SU4")
			DbSetOrder(1)
			If DbSeek(xFilial("SU4") + cLista)
				RecLock("SU4", .F.)
				REPLACE SU4->U4_STATUS	With "2"
				REPLACE SU4->U4_DATA	With dDataBase		
				REPLACE SU4->U4_ROTINA With "TK280ATEND"
		
				MsUnLock()
				Conout("TK280ATEND 1 ->>" + Dtoc(dDataBase) + " - " + Time() + STR0091 + cLista + STR0092 + cOperador)		//"Encerrou a pendencia: " /"  do operador: "
			Endif        
			
			DbSelectArea("SU6")
			DbSetOrder(1)
			If DbSeek(xFilial("SU6") + cLista)
				RecLock("SU6", .F.)
				REPLACE SU6->U6_STATUS 	With "3"
				REPLACE SU6->U6_DATA	With dDataBase
				REPLACE SU6->U6_ROTINA With "TK280ATEND"

				MsUnLock()
				Conout("TK280ATEND 2 ->>" + Dtoc(dDataBase) + " - " + Time() + STR0091 + cLista + STR0092 + cOperador)      //"Encerrou a pendencia: " /"  do operador: "
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Encerra o atendimento, grava o codigo e o motivo de encerramento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cCodLig)
				DbSelectArea("ACF")
				DbSetOrder(1)
				If DbSeek(xFilial("ACF")+cCodLig)
					If Empty(cEncerra) .OR. Empty(cMotivo)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Exibe dialog para o operador informar o codigo de encerramento e o motivo³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Tk274Encerra(.F.,cCodLig,@cEncerra,@cMotivo)
					Endif
					Reclock("ACF",.F.)
					REPLACE ACF->ACF_STATUS With "3"		//Encerrado
					REPLACE ACF->ACF_CODENC	With cEncerra	//Codigo do Encerramento
					MSMM(,TamSx3("ACF_OBSMOT")[1],,cMotivo,1,,,"ACF","ACF_CODMOT")//Motivo do Encerramento
					MsUnlock()
				Endif	
			Endif
		END TRANSACTION 
		Aviso(STR0094, STR0097 + CRLF + STR0098 + CRLF, {"OK"})// "Pendencias do Pré-Atendimento" # "A pendencia será encerrada por não mais se enquadrar nos critérios de cobrança do operador." # "Clique no botão 'Novo' ou selecione outra pendencia."		
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para atualizar no SK1 os titulos para esse operador que ainda nao estao nomeados. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Tk280AtuSK1(cCodCli,cLojaCli,cOperador,aRegras)//2-Cliente,3-Loja,Operador,Regra
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a funcao para verificar se todos os titulos foram pagos	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Tk280Pago(cCodLig,cOperador,cCodCli,cLojaCli)//Atendimento,Operador,Cliente,Loja
			MsgStop(STR0064,STR0065)//"Todos os títulos que foram negociados para esse cliente foram pagos. A pendência e o atendimento serão encerrados","Atenção"
		
			nPos := Ascan(oLbx:aArray, {|x| ( Alltrim(x[2]) + Alltrim(x[3]) )  == ( Alltrim(cCodCli) + Alltrim(cLojaCli) )})
			If nPos > 0
				oLbx:aArray[nPos][10] := "2" 
				oLbx:Refresh()
			Endif
			
			BEGIN TRANSACTION
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerra a pendencia do operador para o atendimento que teve todos os titulos pagos.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SU4")
				DbSetOrder(1)
				If DbSeek(xFilial("SU4") + cLista)
					RecLock("SU4", .F.)
					REPLACE SU4->U4_STATUS	With "2"
					REPLACE SU4->U4_DATA	With dDataBase
					REPLACE SU4->U4_ROTINA With "TK280ATEND"

					MsUnLock()
					Conout("TK280ATEND 1 ->>" + Dtoc(dDataBase) + " - " + Time() + STR0091 + cLista + STR0092 + cOperador)		//"Encerrou a pendencia: " /"  do operador: "
				Endif        
				
				DbSelectArea("SU6")
				DbSetOrder(1)
				If DbSeek(xFilial("SU6") + cLista)
					RecLock("SU6", .F.)
					REPLACE SU6->U6_STATUS 	With "3"
					REPLACE SU6->U6_DATA	With dDataBase
					REPLACE SU6->U6_ROTINA With "TK280ATEND"
		
					MsUnLock()
					Conout("TK280ATEND 2 ->>" + Dtoc(dDataBase) + " - " + Time() + STR0091 + cLista + STR0092 + cOperador)      //"Encerrou a pendencia: " /"  do operador: "
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerra o atendimento, grava o codigo e o motivo de encerramento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cCodLig)
					DbSelectArea("ACF")
					DbSetOrder(1)
					If DbSeek(xFilial("ACF")+cCodLig)
						If Empty(cEncerra) .OR. Empty(cMotivo)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Exibe dialog para o operador informar o codigo de encerramento e o motivo³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Tk274Encerra(.F.,cCodLig,@cEncerra,@cMotivo)
						Endif
						Reclock("ACF",.F.)
						REPLACE ACF->ACF_STATUS With "3"		//Encerrado
						REPLACE ACF->ACF_CODENC	With cEncerra	//Codigo do Encerramento
						MSMM(,TamSx3("ACF_OBSMOT")[1],,cMotivo,1,,,"ACF","ACF_CODMOT")//Motivo do Encerramento
						MsUnlock()
					Endif	
				Endif
			END TRANSACTION
				
		Else 
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se estiver em qualquer um dos paineis que pertenca ao de pendencias agendadas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Str(oExplorer:nPanel,1) $ "1234" 
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa a funcao de telefonia antes de abrir o atendimento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Tk380Discar(cOperador,cDDI		,cDDD				,cTel,;
							cCodCont	,cEntidade	,cCodCli+cLojaCli	,cLista,;
							cItem)
			
					// Posiciona no Operador para ser utilizado no atendimento
					DbSelectArea("SU7")
					DbSetOrder(1)
					DbSeek(xFilial("SU7") + cOperador)
						
					// Atualiza o painel com os titulos a serem cobrados se ainda nao foi atualizado
					oExplorer:nPanel := 3
					Tk280Change(oExplorer, @aPanels, @aMemory)
						
					// Atualiza o painel com os titulos a serem cobrados se ainda nao foi atualizado
					oExplorer:nPanel := 4
					Tk280Change(oExplorer, @aPanels, @aMemory)
						
					// Devolve para o painel de origem
					oExplorer:nPanel := 1
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monta um array a partir dos titulos que foram carregados no             ³
					//³painel de titulos negociados e serao cobrados e passa para o atendimento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oNGD := aPanels[Ascan(aPanels, {|x| x[2]=="COBJ01"} )][1]
			
					nPPrefixo	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACG_PREFIX"} )
					nPTitulo	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACG_TITULO"} )
					nPParcela	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACG_PARCEL"} )
					nPTipo		:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACG_TIPO"} )
					nPFilOrig	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACG_FILORI"} )

			
					For nI := 1 To Len(oNGD:aCols)
						If !Empty(oNGD:aCols[nI][nPTitulo])
							Aadd(aItens, {	oNGD:aCols[nI][nPPrefixo],;
											oNGD:aCols[nI][nPTitulo],;
											oNGD:aCols[nI][nPParcela],;
											oNGD:aCols[nI][nPTipo],;
											IIf(nPFilOrig > 0,oNGD:aCols[nI][nPFilOrig],xFilial("SE1"));
											} )
						Endif
					Next nI
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monta um array  a partir dos titulos que foram carregados no painel de   ³
					//³previsao de cobranca que tambem serao cobrados e passa para o atendimento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oNGD := aPanels[Ascan(aPanels, {|x| x[2]=="DOBJ01"} )][1]
			
					nPPrefixo	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_PREFIXO"} )
					nPTitulo	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_NUM"} )
					nPParcela	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_PARCELA"} )
					nPTipo		:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_TIPO"} )
					nPFilOrig	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_FILIAL"} )
			
					For nI := 1 To Len(oNGD:aCols)
						If !Empty(oNGD:aCols[nI][nPTitulo]) 
							nPos:=Ascan(aItens, {|x| (	x[1] == oNGD:aCols[nI][nPPrefixo]	) 	.AND. ;
													(	x[2] == oNGD:aCols[nI][nPTitulo]	) 	.AND. ;
													( x[3] == oNGD:aCols[nI][nPParcela] 	) 	.AND. ;
													( x[4] == oNGD:aCols[nI][nPTipo] 	)	.AND. ;
													( x[5] == oNGD:aCols[nI][nPFilOrig]	)})
							If nPos == 0
								Aadd(aItens, {	oNGD:aCols[nI][nPPrefixo],;
												oNGD:aCols[nI][nPTitulo],;
												oNGD:aCols[nI][nPParcela],;
												oNGD:aCols[nI][nPTipo],;
												oNGD:aCols[nI][nPFilOrig];
												} )
							Endif					
						Endif
					Next nI
									
					// Atendimento agendado
					If Len(aItens) > 0
						INCLUI:= .F.
						DbSelectArea("ACF")
						TK271CallCenter("ACF"	,ACF->(RecNo())	,4			,Nil,;
										cCodCli	,cLojaCli		,cCodCont	,cEntidade,;
										aItens	,cLista			,.F.)
						If ( lNewRolTLC )
							Tk280GvSk1( ACG->ACG_CODIGO )
						EndIf
					Else
						MsgStop(STR0093 , STR0078) 		//"Nao foram encontrados os titulos para esse cliente. Por favor, entre em contato com o administrador do sistema" /"Atenção"
					Endif					
				Else
					Tk280Reagenda(@aPanels, oLbx:aArray[oLbx:nAt][11], cOperador, oExplorer, @aMemory, aRegras)
				Endif
			
			Else	//Painel de Novo Pre-Atendimento
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa a funcao de telefonia antes de abrir o atendimento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Tk380Discar(	cOperador	,cDDI	,cDDD					,cTel,;
								cCodCont	,"SA1"	,M->A1_COD + M->A1_LOJA	,cLista,;
								cItem)
				
						// Posiciona no Operador para ser utilizado no atendimento TMKA271
						DbSelectArea("SU7")
						DbSetOrder(1)
						DbSeek(xFilial("SU7") + cOperador)
					
						nPPrefixo	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_PREFIXO"} )
						nPTitulo	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_NUM"} )
						nPParcela	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_PARCELA"} )
						nPTipo		:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_TIPO"} )
						nPFilOrig	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="E1_FILIAL"} )
							
						// Monta um array com os titulos que serao cobrados e passa para o atendimento
						For nI := 1 To Len(oNGD:aCols)
							Aadd(aItens, {	oNGD:aCols[nI][nPPrefixo],;
											oNGD:aCols[nI][nPTitulo],;
											oNGD:aCols[nI][nPParcela],;
											oNGD:aCols[nI][nPTipo],;
											oNGD:aCols[nI][nPFilOrig];
											} )
						Next nI
						
						If Len(aItens) > 0	
							// Novo atendimento
							DbSelectArea("ACF")
							TK271CallCenter("ACF"		,ACF->(RecNo())	,3				,Nil,;
											M->A1_COD	,M->A1_LOJA		,SU5->U5_CODCONT,"SA1",;
											aItens		,cLista			,.F.)
							If ( lNewRolTLC )
								Tk280GvSk1( ACG->ACG_CODIGO )
							EndIf
						Else
							MsgStop(STR0093 , STR0078) 		//"Nao foram encontrados os titulos para esse cliente. Por favor, entre em contato com o administrador do sistema", "Atenção"
						Endif					
				Else
					Tk280Reagenda(@aPanels, cLista, cOperador, oExplorer, @aMemory, aRegras)
				Endif
			Endif
		Endif       
	EndIf

EndIf

// Restaura as condicoes normais
TkGetTipoAte(cTipoAte)
aRotina	:=  Aclone(aRotAux)
INCLUI	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura as teclas de atalho do Pre-Atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aAuxKey)
	SetKey(aAuxKey[nI][1], aAuxKey[nI][2] )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a agenda do operador depois que executa o atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk280SU6(@aPanels,.F.,cLista,.T.)

// Troca o flag do panel para ser atualizado na selecao
aPanels[Ascan(aPanels, {|x| x[2]=="EOBJ01"} )][3] := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa as enchoices da tela Novo Pré-atendimento que se atualiza automaticamente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk280Memory("SA1", @aMemory, .F.)
nPos := Ascan(aPanels, {|x| x[2]=="FOBJ02"} )
aPanels[nPos][1]:Refresh()
	
Tk280Memory("SU5", @aMemory, .F.)
nPos := Ascan(aPanels, {|x| x[2]=="FOBJ03"} )
aPanels[nPos][1]:Refresh()
	
// Se foi executado do painel 6, entao limpa os dados do restante da tela Novo Pre-atendimento
If Str(oExplorer:nPanel,1) $ "5678"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza os dados do browser com os Titulos que deverao ser cobrados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoAte $ "34"
		nPos := Ascan(aPanels, {|x| x[2]=="FOBJ04"} )
		Tk280SK1(@aPanels[nPos][1]:aHeader, @aPanels[nPos][1]:aCols, @aPanels[Ascan(aPanels, {|x| x[2]=="FOBJ05"} )][1],,,.T.)
		aPanels[nPos][1]:Refresh()
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa os dados do Painel de pendencias no Telemarketing             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoAte $ "145"
		nPos := Ascan(aPanels, {|x| x[2]=="GOBJ01"} )
		Tk280SUC(@aPanels[nPos][1]:aHeader, @aPanels[nPos][1]:aCols, "")
		aPanels[nPos][1]:Refresh()
		
		nPos := Ascan(aPanels, {|x| x[2]=="GOBJ02"} )
		Tk280SUD(@aPanels[nPos][1]:aHeader, @aPanels[nPos][1]:aCols, "")
		aPanels[nPos][1]:Refresh()
		
		// Prepara o painel de Pendencia no Telemarketing para NAO ser atualizado na selecao
		nPos := Ascan(aPanels, {|x| x[2]=="GOBJ01"} )
		aPanels[nPos][3] := .T.   
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa os dados do Painel de pendencias no Televendas                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoAte $ "245"
		nPos := Ascan(aPanels, {|x| x[2]=="HOBJ01"} )
		Tk280SUA(@aPanels[nPos][1]:aHeader, @aPanels[nPos][1]:aCols, "", "")
		aPanels[nPos][1]:Refresh()
		
		nPos := Ascan(aPanels, {|x| x[2]=="HOBJ02"} )
		Tk280SUB(@aPanels[nPos][1]:aHeader, @aPanels[nPos][1]:aCols, "")
		aPanels[nPos][1]:Refresh()
		
		// Prepara o painel de Televendas pendente para NAO ser atualizado na selecao
		nPos := Ascan(aPanels, {|x| x[2]=="HOBJ01"} )
		aPanels[nPos][3] := .T.
	EndIf
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkGrvSUV(__cUserId, "PRE0")
lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280ReagendaºAutor³ Vendas Clientes    º Data ³  25/07/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Em caso de falha na tentativa de realizar a ligacao para o  º±±
±±º          ³contato, o atendimento podera ser reagendado para depois.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³cLista    - Codigo da lista que ficara pendente para retornoº±±
±±º          ³            do operador de telecobranca.                    º±±
±±º          ³cOperador - Codigo do operador que esta trabalhando.        º±±
±±º          ³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³aMemory   - Vaiaveis de memoria utilizada pelas MSMGET.     º±±
±±º          ³aRegras   - Contem as regras de selecao dos titulos de todosº±±
±±º          ³            os operadores para validar qual titulo o opera- º±±
±±º          ³            dor corrente podera trabalhar.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk280Reagenda(	aPanels,	cLista,	cOperador,	oExplorer,;
								aMemory,	aRegras )

// Variaveis de controle
Local aArea		:= GetArea()
Local lRet		:= .T.
Local aTel		:= {}
Local dDtRet	:= dDataBase
Local cHRet		:= PadR(Time(),5)
Local nOk		:= 0
Local nTpTel	:= 1
Local cContato	:= ""
Local cCliente	:= ""
Local cLoja		:= ""

// Objetos
Local oFonte
Local oDlg
Local oAgenda	:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]	// Objeto com os itens da agenda do operador
Local oLbx
Local oDtRet
Local oHRet
                             
DEFINE FONT oFonte NAME "Arial" SIZE 0,14 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o cliente de acordo com o painel posicionado e pesquisa na base de dados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Str(oExplorer:nPanel,1) $ "1234"
	cContato:= oAgenda:aArray[oAgenda:nAt][5]
	cCliente:= oAgenda:aArray[oAgenda:nAt][2]
	cLoja	:= oAgenda:aArray[oAgenda:nAt][3]
Else
	cContato:= M->U5_CODCONT
	cCliente:= M->A1_COD
	cLoja	:= M->A1_LOJA
Endif
		
DbSelectArea("SU5")
DbSetOrder(1)
If !DbSeek(xFilial("SU5") + cContato)
	DbSelectArea("AC8")
	DbSetOrder(2)		// AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
	DbSeek(xFilial("AC8") + "SA1" + xFilial("SA1") + cCliente + cLoja)
	
	DbSelectArea("SU5")
	DbSetOrder(1)
	If !DbSeek(xFilial("SU5") + AC8->AC8_CODCON)
		Help("  ",1,"TK280REAG")//"O cliente selecionado para cobrança nao possui um contato relacionado para que seja efetuado o reagendamento"
		Return(.F.)
	Endif
Endif

Aadd(aTel,{STR0030,	PadR(SU5->U5_CODPAIS,3), SU5->U5_DDD, SU5->U5_FONE})		//"Residencial"
Aadd(aTel,{STR0031,	PadR(SU5->U5_CODPAIS,3), SU5->U5_DDD, SU5->U5_CELULAR})	//"Celular"
Aadd(aTel,{STR0032,	PadR(SU5->U5_CODPAIS,3), SU5->U5_DDD, SU5->U5_FAX})		//"FAX"
Aadd(aTel,{STR0033,	PadR(SU5->U5_CODPAIS,3), SU5->U5_DDD, SU5->U5_FCOM1})		//"Comercial 01"
Aadd(aTel,{STR0034,	PadR(SU5->U5_CODPAIS,3), SU5->U5_DDD, SU5->U5_FCOM2})		//"Comercial 02"

While nOk <> 1 

	DEFINE MSDIALOG oDlg TITLE STR0035 FROM 0,0 TO 230,380 PIXEL //"PRORROGACAO DE DATA E HORA DA AGENDA"
	
		@ 020,005 ListBox oLbx Fields Header STR0036, STR0037, STR0038, STR0039 Size 180,65 OF oDlg Pixel //"Tipo"###"DDI"###"DDD"###"Número"
		
		oLbx:SetArray(aTel)
		oLbx:bLine := {||{	aTel[oLbx:nAt][1],;
							aTel[oLbx:nAt][2],;
							aTel[oLbx:nAt][3],;
							aTel[oLbx:nAt][4];
							}}
		oLbx:bChange := { || (nTpTel:= oLbx:nAt) }
		
		@ 92,005 SAY STR0040 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		//" Data de Retorno"
		@ 90,055 GET oDtRet VAR dDtRet OF oDlg SIZE 40,10 PIXEL VALID Tk274Penden(dDtRet,cOperador)
		
		@ 92,105 SAY STR0041 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		//" Hora de Retorno"
		@ 90,155 GET oHRet VAR cHRet OF oDlg SIZE 30,10 PIXEL VALID	TK274HACF(@cHRet,dDtRet) PICTURE '99:99'
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| (IIF(Tk280VldTel(aTel[nTpTel][4],@nOk),oDlg:End(),"")) }, {|| oDlg:End() } ) 
	
	If nOk <> 1 
		Aviso(STR0065,STR0067,{"OK"})//"Atenção","Favor informar um numero de telefone valido!"
	EndIf
	
End
If nOk == 1
	BEGIN TRANSACTION
		DbSelectArea("SU4")
		DbSetOrder(1)
		If DbSeek(xFilial("SU4") + cLista)
			RecLock("SU4", .F.)
			REPLACE SU4->U4_DATA	With dDtRet
			REPLACE SU4->U4_TIPOTEL	With Str(nTpTel,1)		// 1=Residencial 2=Fax 3=Celular 4=Comercial 1 5=Comercial 2
			REPLACE SU4->U4_STATUS	With "1"				// Status da Lista 1=Pendente 2=Encerrada
			MsUnLock()
		Endif
	
		DbSelectArea("SU6")
		DbSetOrder(1)
		If DbSeek(xFilial("SU6") + cLista)
			RecLock("SU6", .F.)
			REPLACE SU6->U6_DATA	With dDtRet
			REPLACE SU6->U6_HRINI	With cHRet
			If Empty(SU6->U6_CONTATO)
				REPLACE SU6->U6_CONTATO With SU5->U5_CODCONT
			Endif
			MsUnLock()
		Endif
	END TRANSACTION

Else
	lRet:= .F.
Endif
                          
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ºTk280VldTelºAutor  ³ Vendas Clientes    º Data ³  09/01/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar se o numero informado na tela de reagendamento e    º±±
±±º          ³um numero valido.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nNumTel - Número informado                                  º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³nOk - Se o número foi validado ou não.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet - Se o número foi validado ou não.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk280VldTel( nNumTel, nOk )

Local lRet:= .T.

If Empty(nNumTel)
	lRet:= .F.
	nOk	:=	0
Else	
	nOk:=1
Endif	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280Fim  ºAutor  ³ Vendas Clientes    º Data ³  08/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Finaliza a tela de pre-atendimento e defaz as teclas de fun º±±
±±º          ³cao criadas como atalhos aos programas.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³aKey      - Array com todas as acoes das teclas de funcao.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk280Fim( oExplorer, aKey )

Local nI	:= 1	// Controle de laco

For nI := 1 To Len(aKey)
	SetKey(aKey[nI][1], {|| AllWaysTrue() } )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inibe o loop da dialog quando acessado um AxCadastro durante o processo de atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MBRCHGLOOP(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkGrvSUV(__cUserId, "")

oExplorer:Deactivate()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK280CreditoºAutor³ Vendas Clientes    º Data ³  17/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta uma tela que apresenta a situacao financeira do clien-º±±
±±º          ³te e permite altera-la.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³lAltera   - Define se o operador podera manipular o credito º±±
±±º          ³            do cliente ou nao.                              º±±
±±º          ³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³aMemory   - Vaiaveis de memoria utilizada pelas MSMGET.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK280Credito( lAltera, oExplorer, aPanels, aMemory, aKey )

// Variaveis que definen os objetos e seus conteudos apresentados na tela.
Local oDlg		:= Nil													// Diálogo com os objetos a serem exibidos
Local oFonte	:= Nil													// Fonte do diálogo
Local oCodigo	:= Nil													// Objeto com o código do cliente
Local cCodigo	:= ""													// Código do cliente
Local oLoja		:= Nil													// Objeto com a loja do cliente
Local cLoja		:= ""													// Loja do cliente
Local oNome		:= Nil													// Objeto com o nome do cliente
Local cNome		:= ""													// Nome do cliente
Local oRisco	:= Nil													// Objeto com o grau de risco do cliente
Local cRisco	:= ""													// Risco do cliente
Local aRisco	:= Tk280Box("A1_RISCO")									// Lista de seleção do grau de risco do cliente
Local oClasse	:= Nil													// Objeto com a classe de crédito do cliente
Local cClasse	:= ""													// Classe de crédito do cliente
Local aClasse	:= Tk280Box("A1_CLASSE")								// Lista de seleção da classe de crédito do cliente
Local oLC		:= Nil													// Objeto com o limite de crédito do cliente
Local nLC		:= 0													// Limite de crédito do cliente
Local nLCOri	:= 0													// Limite de crédito do cliente original
Local oVencLC	:= Nil													// Objeto com o vencimento do limite do crédito do cliente
Local dVencLC	:= CtoD("//")											// Vencimento do limite do crédito do cliente
Local oLCFin	:= Nil													// Objeto com o limite de crédito secundário do cliente
Local nLCFin	:= 0													// Limite de crédito secundário do cliente
Local oMoedaLC	:= Nil													// Objeto com a moeda do limite de crédito do cliente
Local nMoedaLC	:= 0													// Moeda do limite de crédito do cliente
Local oSalPedL	:= Nil													// Objeto com o saldo dos pedidos liberados do cliente
Local nSalPedL	:= 0													// Saldo pedidos liberados do cliente
Local oSPL		:= Nil													// Objeto que informa se o saldo dos pedidos liberados foi utilizado no cálculo do saldo do limite de crédito do cliente
Local lSPL		:= .T.													// Flag que controla se o saldo dos pedidos liberados foi utilizado no cálculo do saldo do limite de crédito do cliente
Local oSalPed	:= Nil													// Objeto com o saldo dos pedidos do cliente
Local nSalPed	:= 0													// Saldo pedidos liberados do cliente
Local oSP		:= Nil													// Objeto que informa se o saldo dos pedidos foi utilizado no cálculo do saldo do limite de crédito do cliente
Local lSP		:= .T.													// Flag que controla se o saldo dos pedidos foi utilizado no cálculo do saldo do limite de crédito do cliente
Local oSalDup	:= Nil													// Objeto com o saldo dos títulos do cliente
Local nSalDup	:= 0													// Saldo dos títulos do cliente
Local oSD		:= Nil													// Objeto que informa se o saldo dos títulos foi utilizado no cálculo do saldo do limite de crédito do cliente
Local lSD		:= .T.													// Flag que controla se o saldo dos títulos foi utilizado no cálculo do saldo do limite de crédito do cliente
Local oSaldoLC	:= Nil													// Objeto com saldo do limite de crédito do cliente
Local nSaldoLC	:= 0													// Saldo do limite de crédito do cliente
Local lOk		:= .F.													// Se saiu da tela apartir do clique no OK
Local nPCliente	:= 0													// Código do cliente selecionado
Local nPLoja	:= 0													// Loja do cliente selecionado
Local oLbx		:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]	// Agenda do operador
Local oNGD		:= aPanels[Ascan(aPanels, {|x| x[2]=="EOBJ01"} )][1]	// Titulos que deverao ser cobrados
Local nI		:= 0
Local aBkpKeys  := aClone(aKey)
Local lOfuscaCli:= .F.
Local lOfuscaRis:= .F.
Local lOfuscaLc := .F.
Local lOfuscaCla:= .F.
Local lOfuscaLcS:= .F.
Local aFieldsPD := {"A1_NOME","A1_RISCO","A1_LC","A1_CLASSE","A1_LCFIN"}

DEFAULT lAltera	:= .F.
DEFAULT aKey 	:= {}

FATPDLoad(Nil, Nil,aFieldsPD)
lOfuscaCli:= FATPDIsObfuscate("A1_NOME")
lOfuscaRis:= FATPDIsObfuscate("A1_RISCO")
lOfuscaLc := FATPDIsObfuscate("A1_LC")
lOfuscaCla:= FATPDIsObfuscate("A1_CLASSE")
lOfuscaLcS:= FATPDIsObfuscate("A1_LCFIN")

For nI := 1 To Len(aKey)
	Set Key aKey[nI][1] to
Next nI

DEFINE FONT oFonte NAME "Arial" SIZE 0,14 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o cliente do folder relacionado e posiciona na base de dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Str(oExplorer:nPanel,1) $ "1234"
	cCliente	:= Eval(oLbx:bLine)[2]
	cLoja		:= Eval(oLbx:bLine)[3]
Endif

If oExplorer:nPanel == 5
	nPCliente	:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACF_CLIENT"} )
	nPLoja		:= Ascan(oNGD:aHeader, {|x| AllTrim(x[2])=="ACF_LOJA"} )
	cCliente	:= oNGD:aCols[oNGD:nAt][nPCliente]
	cLoja		:= oNGD:aCols[oNGD:nAt][nPLoja]
Endif

If Str(oExplorer:nPanel,1) $ "678"
	cCliente	:= M->A1_COD
	cLoja		:= M->A1_LOJA
Endif

If !Empty(cCliente) .AND. !Empty(cLoja)
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SA1") + cCliente + cLoja)
		Help("  ",1,"TK280CLIEN")//"Nao há nenhum cliente disponivel para realizar essa operacao, no momento"
		Return(.F.)
	Endif
Else
	Help("  ",1,"TK280CLIEN")//"Nao há nenhum cliente disponivel para realizar essa operacao, no momento"
	Return(.F.)
Endif

cCodigo		:= FieldGet(FieldPos("A1_COD    "))
cLoja		:= FieldGet(FieldPos("A1_LOJA   "))
cNome		:= FieldGet(FieldPos("A1_NOME   "))
cRisco		:= FieldGet(FieldPos("A1_RISCO  "))
cClasse		:= FieldGet(FieldPos("A1_CLASSE "))
nLC			:= FieldGet(FieldPos("A1_LC     "))
nLCOri		:= FieldGet(FieldPos("A1_LC     "))
dVencLC		:= FieldGet(FieldPos("A1_VENCLC "))
nLCFin		:= FieldGet(FieldPos("A1_LCFIN  "))
nMoedaLC	:= FieldGet(FieldPos("A1_MOEDALC"))
nSalPedL	:= FieldGet(FieldPos("A1_SALPEDL"))
nSalPed		:= FieldGet(FieldPos("A1_SALPED "))
nSalDup		:= FieldGet(FieldPos("A1_SALDUP "))
nSaldoLC	:= nLC - (nSalPedL + nSalPed + nSalDup)


DEFINE MSDIALOG oDlg TITLE STR0042 FROM 0,0 TO 290,600 PIXEL		// "MANIPULACAO DO CREDITO DO CLIENTE"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados do cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 30, 05 To 55, 295 Label STR0043 Of oDlg Pixel		// "Cliente"
	
	@ 40,10 SAY STR0044 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Código/Loja"
	@ 40,43 GET oCodigo VAR cCodigo OF oDlg SIZE 30,09 PIXEL WHEN .F. PICTURE PesqPict("SA1", "A1_COD")
	@ 40,75 GET oLoja VAR cLoja OF oDlg SIZE 10,09 PIXEL WHEN .F. PICTURE PesqPict("SA1", "A1_LOJA")
	
	@ 40,123 SAY STR0045 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Nome"
	@ 40,123 GET oNome VAR cNome OF oDlg SIZE 165,09 PIXEL WHEN .F. PICTURE PesqPict("SA1", "A1_NOME")
	If FATPDActive() .And. FTPDUse(.T.)
		oNome:lObfuscate := lOfuscaCli
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manipulacao do credito do cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 55, 05 To 140, 295 Label STR0046 Of oDlg Pixel		// "Crédito"
	
	@ 65,10 SAY STR0047 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Risco"
	@ 65,60 MSCOMBOBOX oRisco VAR cRisco ITEMS aRisco OF oDlg SIZE 60,09 PIXEL WHEN lAltera
	If FATPDActive() .And. FTPDUse(.T.)
		oRisco:lObfuscate := lOfuscaRis
	Endif

	@ 65,155 SAY STR0048 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Classe"
	@ 65,205 MSCOMBOBOX oClasse VAR cClasse ITEMS aClasse OF oDlg SIZE 60,09 PIXEL WHEN lAltera
	If FATPDActive() .And. FTPDUse(.T.)
		oClasse:lObfuscate := lOfuscaCla
	Endif

	@ 80,10 SAY STR0049 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Limite de Crédito"
	@ 80,60	GET oLC VAR nLC OF oDlg SIZE 60,09 PIXEL WHEN lAltera PICTURE PesqPict("SA1", "A1_LC");
			VALID IIF(nLC <= nLCORI,;
			(nSaldoLC	:= nLC - ( IIF(lSPL,nSalPedL,0) + IIF(lSP,nSalPed,0) + IIF(lSD,nSalDup,0) ) ),.F.) 
	If FATPDActive() .And. FTPDUse(.T.)
		oLC:lObfuscate := lOfuscaLc		
	Endif

	@ 80,155 SAY STR0050 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Vencimento Limite"
	@ 80,205 GET oVencLC VAR dVencLC OF oDlg SIZE 40,09 PIXEL WHEN lAltera PICTURE PesqPict("SA1", "A1_VENCLC")
	
	@ 95,10 SAY STR0051 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Limite Secundário"
	@ 95,60 GET oLCFin VAR nLCFin OF oDlg SIZE 60,09 PIXEL WHEN lAltera PICTURE PesqPict("SA1", "A1_LCFIN")
	If FATPDActive() .And. FTPDUse(.T.)
		oLCFin:lObfuscate := lOfuscaLcS
	Endif

	@ 95,155 SAY STR0052 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Moeda do Limite"
	@ 95,205 GET oMoedaLC VAR nMoedaLC OF oDlg SIZE 15,09 PIXEL WHEN lAltera PICTURE PesqPict("SA1", "A1_MOEDALC")
	
	@ 110,010 SAY STR0053 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Saldo do Pedido Lib."
	@ 110,060 GET oSalPedL VAR nSalPedL OF oDlg SIZE 60,09 PIXEL WHEN .F. PICTURE PesqPict("SA1", "A1_SALPEDL")
	@ 110,120	CHECKBOX oSPL VAR lSPL SIZE 10,10 PIXEL OF oDlg PROMPT "";
				ON CHANGE ( (nSaldoLC := nSaldoLC + IIF(lSPL,(nSalPedL*-1),nSalPedL)), (oSaldoLC:Refresh()) )
	
	@ 110,155 SAY STR0054 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Saldo do Pedido"
	@ 110,205 GET oSalPed VAR nSalPed OF oDlg SIZE 60,09 PIXEL WHEN .F. PICTURE PesqPict("SA1", "A1_SALPED")
	@ 110,265 CHECKBOX oSP VAR lSP SIZE 10,10 PIXEL OF oDlg PROMPT "";
				ON CHANGE ( (nSaldoLC := nSaldoLC + IIF(lSP,(nSalPed*-1),nSalPed)), (oSaldoLC:Refresh()) )
	
	@ 125,010 SAY STR0055 COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Saldo dos Títulos"
	@ 125,060 GET oSalDup VAR nSalDup OF oDlg SIZE 60,09 PIXEL WHEN .F. PICTURE PesqPict("SA1", "A1_SALDUP")
	@ 125,120 CHECKBOX oSD VAR lSD SIZE 10,10 PIXEL OF oDlg PROMPT "";
				ON CHANGE ( (nSaldoLC := nSaldoLC + IIF(lSD,(nSalDup*-1),nSalDup)), (oSaldoLC:Refresh()) )
	
	@ 125,155 SAY STR0056 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		// "Saldo do Limite"
	@ 125,205 GET oSaldoLC VAR nSaldoLC OF oDlg SIZE 60,09 PIXEL WHEN .F. PICTURE PesqPict("SA1", "A1_LC")
	If FATPDActive() .And. FTPDUse(.T.)
		oSaldoLC:lObfuscate := lOfuscaLc
	Endif

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| (lOk:=.T.,oDlg:End()) }, {|| oDlg:End() } )

If lOk .AND. lAltera
	RecLock("SA1")
	REPLACE SA1->A1_RISCO	WITH cRisco
	REPLACE SA1->A1_CLASSE	WITH cClasse
	REPLACE SA1->A1_LC		WITH nLC
	REPLACE SA1->A1_VENCLC	WITH dVencLC
	REPLACE SA1->A1_LCFIN	WITH nLCFin
	REPLACE SA1->A1_MOEDALC	WITH nMoedaLC
	MsUnLock()
Endif

For nI := 1 To Len(aKey)
	SetKey(aKey[nI][1], aBkpKeys[nI][2])
Next nI

FATPDUnload()
Return(.T.)
                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280Pesq ºAutor  ³ Vendas Clientes    º Data ³  10/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa pesquisa das pendencias (follow-up) disponiveis no  º±±
±±º          ³painel de pendencias agendadas para hoje.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oExplorer - Objeto que contem os paineis com os dados do    º±±
±±º          ³            pre-atendimento.                                º±±
±±º          ³aPanels   - Todos objetos de todos paineis.                 º±±
±±º          ³aRegras   - Contem as regras de selecao dos titulos de todosº±±
±±º          ³cOperador - Codigo do operador que esta trabalhando.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk280Pesq( oExplorer, aPanels, aRegras, cOperador )

Local lRet		:= .T.                                                         	// Retorno da funcao
Local oLbx		:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]			// Agenda do operador
Local cCliente  := Space(TamSx3("A1_COD")[1])									// Codigo do cliente
Local cLoja		:= Space(TamSx3("A1_LOJA")[1])                                	// Codigo da Loja
Local cNome		:= Space(40)													// Nome do cliente
Local nPos		:= 0															// Posicao do array onde se encontra o cliente
Local oCliente,oLoja,oNome,oDlg,oFonte                                         	// Objetos da Dialog
Local lOfuscaCli  := FATPDIsObfuscate("A1_NOME",,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se estiver apenas no painel de pendencias agendadas, executa a pesquisa.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Str(oExplorer:nPanel,1) $ "1"

	DEFINE MSDIALOG oDlg TITLE STR0069 FROM 15,2 TO 200,300 PIXEL //"Pesquisar pendência"

		@ 002,002 TO 090,148 OF oDlg  PIXEL
	
		@ 010,010 SAY STR0072 + " :" FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		//"Codigo :"
		@ 010,035 GET oCliente VAR cCliente OF oDlg  Picture PesqPict("SA1", "A1_COD") SIZE 40,10 PIXEL ;
		VALID Tk280SelCli(cCliente,cLoja,@cNome,oNome)
		oCliente:cF3 := "CLT"
		
		@ 030,010 SAY STR0071 + " :" FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		//"Loja    :"
		@ 030,035 GET oLoja VAR cLoja OF oDlg SIZE 20,10 PIXEL  
		
		@ 050,010 SAY STR0045 + " :" FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oDlg PIXEL		//"Nome :"
		@ 050,035 GET oNome VAR cNome OF oDlg SIZE 80,10 PIXEL WHEN .F.
		If FATPDActive() .And. FTPDUse(.T.)
			oNome:lObfuscate := lOfuscaCli
		Endif
		
		DEFINE SBUTTON FROM 070,090 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
		
	ACTIVATE MSDIALOG oDlg CENTERED                  
	
	nPos:= Ascan(oLbx:aArray, {|x| x[2]+x[3]== cCliente+cLoja} )
	If nPos > 0
		oLbx:nAt:=nPos
		oLbx:Refresh()
	Endif

Else
	MsgStop(STR0073,STR0065)//"Para pesquisar uma pendência, é necessário estar posicionado no painel de pendencias agendadas!","Atenção")
	lRet:= .F.
Endif
	          
Return(lRet)              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280SelCli ºAutor  ³ Vendas Clientes  º Data ³  10/15/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posiciona no codigo do cliente e loja selecionado para      º±±
±±º          ³pesquisa e atualiza o nome do cliente.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk280SelCli( cCliente, cLoja, cNome, oNome )

Local aArea:= GetArea()		// Salva a area atual

If !Empty(cCliente) .AND. !Empty(cLoja)
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+cCliente+cLoja)
		cNome:= SA1->A1_NOME
		oNome:bSetGet := {|| cNome }
		oNome:Refresh()
	Endif
Endif

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280Contato ºAutor  ³ Vendas Clientes º Data ³  10/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro de contatos. Disponivel para inclusao e alteracao. º±±
±±º          ³Executado atraves do botao na barra de ferramentas.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk280Contato( oExplorer, aPanels )

Local aArea	  	:= GetArea()													// Salva a area atual
Local oLbx		:= aPanels[Ascan(aPanels, {|x| x[2]=="AOBJ01"} )][1]			// Agenda do operador
Local cContato	:= "" 						                                   	// Codigo do Contato
Local cCliente	:= ""															// Código do cliente
Local cLoja		:= ""															// Loja do cliente
Local cCad	  	:= cCadastro													// Salva o cCadastro atual
Local aRots   	:= aClone(aRotina)												// Salva o aRotinas atual
Local lInclui	:= INCLUI                                                      	// Salva a variavel de controle de inclusao
Local nOpcA	    := 0 															// Retorno da Inclusao ou Alteracao (OK - CANCELA)
Local lTMKALTA5	:= ExistBlock("TMKALTA5")   									// P.E  Antes da alteracao do contato.
Local lTMKALTU5	:= ExistBlock("TMKALTU5") 										// P.E  Depois da alteracao do contato.
Local lRet		:= .T.															// Retorno do P.E. 
Local aMemory	:= {}															// array com array das variaveis de memoria para refresh

aRotina	:= {	{ "Pesquisar"  	,"AxPesqui" ,0,1 },;
				{ "Visualizar" 	,"AxVisual" ,0,2 },;
				{ "Incluir"  	,"AxInclui" ,0,3 },; 
				{ "Alterar"  	,"AxAltera" ,0,4 }}  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se estiver em qualquer um dos paineis que compoem o de Pendencias Agendadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Str(oExplorer:nPanel,1) $ "1234"
	cContato:=	oLbx:aArray[oLbx:nAt][5]
	cCliente:= 	oLbx:aArray[oLbx:nAt][2]
	cLoja	:= 	oLbx:aArray[oLbx:nAt][3]
Else
	cContato:= M->U5_CODCONT
	cCliente:= M->A1_COD
	cLoja	:= M->A1_LOJA
Endif

If Empty(cCliente)
	Help("  ",1,"TK280CLIEN")//"Não há nenhum cliente disponível para realizar essa operacao no painel selecionado, no momento"
	Return(.F.)
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa o contato. Se existir executa a alteracao  ³
//³caso contrario executa a inclusao.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cContato)
	DbSelectArea("SU5")
	DbSetOrder(1)              
	If DbSeek(xFilial("SU5") + cContato)
		
		If lTMKALTA5
			lRet := U_TMKALTA5(SU5->(Recno()))
			
			// Se o retorno for .F. nao prossegue 
			If (ValType(lRet) <> "L")
				lRet := .F.
			Endif
		Endif
		
		If lRet
			INCLUI 	  := .F.
			cCadastro := STR0075 //"Alteracao de Contatos"
	
			nOpcA := AxAltera("SU5",SU5->(RecNo()),4)
			cContato:= SU5->U5_CODCONT	
			
			If nOpcA == 1	// OK
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa o P.E.     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTMKALTU5
					ExecBlock( "TMKALTU5", .F., .F. )
				Endif
			Endif
			
		Endif
	Endif	
Else
	INCLUI 	  := .T.
	cCadastro:= STR0074 //"Inclusao de Contatos"
	nOpcA:=AxInclui("SU5",1,3)
	cContato:= SU5->U5_CODCONT	
	
	If nOpcA == 1	// OK
		DbSelectArea("AC8")
		DbSetOrder(1)		// AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
		If !DbSeek(xFilial("AC8") + cContato + "SA1" + xFilial("SA1") + cCliente+cLoja )
			DbSelectArea("AC8")
			RecLock("AC8",.T.)
			REPLACE AC8->AC8_FILIAL With xFilial("AC8")              
			REPLACE AC8->AC8_FILENT With xFilial("SA1")
			REPLACE AC8->AC8_ENTIDA With "SA1"
			REPLACE AC8->AC8_CODENT With cCliente+cLoja
			REPLACE AC8->AC8_CODCON With cContato
			MsUnLock()
		Endif
	Endif
Endif			
	
If nOpcA == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o painel de pendencias agendadas com dados do contato.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Str(oExplorer:nPanel,1) $ "1234"
		oLbx:aArray[oLbx:nAt][5]:= cContato
		oLbx:aArray[oLbx:nAt][6]:= Posicione("SU5",1,xFilial("SU5")+cContato,"U5_CONTAT")
		oLbx:Refresh()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a MSMGET do painel de Novo Pre-Atendimento com os dados do contato³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		Tk280Memory("SU5", @aMemory, .T.)
		nPos := Ascan(aPanels, {|x| x[2]=="FOBJ03"} )
		aPanels[nPos][1]:Refresh()
	Endif
Endif

INCLUI 		:= lInclui
cCadastro	:= cCad
aRotina  	:= AClone(aRots)
RestArea(aArea)

Return(.T.) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280Dic  ºAutor  ³ Vendas Clientes    º Data ³  10/15/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o dicionario de dados esta preparado para       º±±
±±º          ³ordenar os titulos mais antigos de maior valor contidos na  º±±
±±º          ³tabela SK1.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA	                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tk280Dic()

Local aArea	:= GetArea()
Local lRet	:= .F.

DbSelectArea("SIX")
DbSetOrder(1)
If DbSeek("SK1"+"5")
	If Alltrim(CHAVE) == "K1_FILIAL+DTOS(K1_VENCREA)+STR(K1_SALDEC,17,0)+K1_CLIENTE+K1_LOJA"             
		lRet:= .T.
	Endif
Endif

RestArea(aArea)	
Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280Num  ºAutor  ³ Vendas Clientes    º Data ³  07/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validar o numero da lista SU4/SU6              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk280Num( cAlias, cCampo )

Local aArea		:= GetArea()    				//Salva a area atual
Local cNumAux	:= GetSxeNum(cAlias,cCampo) 	//Proximo numero da lista

cMay 	:= cAlias + ALLTRIM(xFilial(cAlias)) + cNumAux

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura um numero de lista que nao exista na base de dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (DbSeek(xFilial(cAlias) + cNumAux) .OR. !MayIUseCode(cMay))
	cNumAux := Soma1(cNumAux,Len(cNumAux))
	cMay 	:= cAlias + ALLTRIM(xFilial(cAlias)) + cNumAux
End 

// Confirma o codigo da lista
If __lSX8
	ConfirmSX8()
Endif

RestArea(aArea)
Return(cNumAux)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280DelCb ºAutor ³ Vendas Clientes    º Data ³  01/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de limpeza dos arquivos de semaforo para controle de º±±
±±º          ³cobranca dos clientes.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cPathLog - indica o diretorio a ser verificado              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk280DelCB(cPathLog)

Local aFiles 	   			//Armazena os arquivos a serem apagados
Local nHandle	   			//Handle do arquivo de controle
Local cArqCTL	   			//Nome do arquivo de controle desta rotina
Local cQuery				//Query para delecao no banco            
Local dData		   			//Data para comparacao
Local aRecnos	:= {}		//Registros que serao apagados em codebase
Local nX		   			//Auxiliar para controle de loop

cArqCTL := "Tk280DelCob" + Dtos(Date()) + ".COB"

If !File(cPathLog + cArqCTL)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Cria o arquivo de controle, desta maneira, nao permite que mais de um operador execute a  |
	//|rotina de remocao dos arquivos *.COB														 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nHandle := FCREATE(cPathLog + cArqCTL	 ,FC_READONLY)                                                
	If nHandle>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Abre o arquivo para leitura, desta maneira o arquivo ficara bloqueado enquanto a rotina   |
		//|e executada.																				 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		FOpen(cPathLog + cArqCTL		,FO_READWRITE)
		FWrite( nHandle, "tk280delcob" )                                           
	EndIf				
	
	If nHandle > 0

		dData := Date()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apaga os registros da SKV para o dia anterior³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP
			
			cQuery := "DELETE FROM " + RetSqlName("SKV")
			cQuery += " WHERE KV_DATA < '" + DtoS(dData)+ "'"
			
			TcSqlExec(cQuery)
			
		#ELSE          
		
			DbSelectArea("SKV")
			DbSetOrder(1)
			DbGoTop()
			
			While !SKV->(Eof()) .AND. SKV->KV_DATA < dData  
				AAdd(aRecnos,SKV->(Recno()))
				SKV->(DbSkip())
			End                           
			
			For nX := 1 to Len(aRecnos)
				SKV->(DbGoTo(aRecnos[nX]))
				RecLock("SKV",.F.)
				DbDelete()
				MsUnLock()
			Next nX
		
		#ENDIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Apaga os arquivos do dia anterior  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFiles := Directory(cPathLog + "*" + DToS(Date()-1) + ".COB")
		AEval(aFiles, {|aFile|FErase(cPathLog + aFile[1])})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Apaga os arquivos do mes anterior, garantindo que nao sobre arquivos |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFiles := Directory(cPathLog + "*" + SubStr(DToS(Date()-32),1,6) + "??.COB")
		AEval(aFiles, {|aFile|FErase(cPathLog + aFile[1])})
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apaga os arquivos de rejeicao dos operadores³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		aFiles := Directory(cPathLog + "rej*.COB")
		AEval(aFiles, {|aFile|FErase(cPathLog + aFile[1])})

		FClose(nHandle)
	EndIf
EndIf
		
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280ChkSE1ºAutor ³ Vendas Clientes    º Data ³  06/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o cliente pode ser cobrado pelo operador confor-º±±
±±º          ³-me a sua faixa de cobranca.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCliente - Cliente a ser cobrado                            º±±
±±º          ³cLoja - Loja                                                º±±
±±º          ³aRegras - Regras de Selecao existentes                      º±±
±±º          ³cOrdem - Regra de selecao utilizado pelo operador           º±±
±±º          ³dIni - Faixa inicial em que o operador trabalha             º±±
±±º          ³dFim - Faixa final em que o operador trabalha               º±±
±±º          ³aOperad - Array de operadores                               º±±
±±º          ³lVerOperad - Se deve analisar operador responsável pela     º±±
±±º          ³   cobrança                                                 º±±
±±º          ³lMesmoOper - Considera o operador atual na análise do       º±±
±±º          ³   operador responsável                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk280ChkSE1( cCliente		, cLoja		, aRegras	, cOrdem	,;
							 dIni			, dFim		, aOperad	, lVerOperad,;
							 lMesmoOper		)

Local cOperador		:= TkOperador()  	// Armazena o codigo do operador
Local lRet			:= .T.				// Retorno da funcao
Local lForaFaixa 	:= .F.				// Flag indicando se o cliente possui titulos fora da faixa do operador                                    
Local nPos        	:= 0		  		// Armazena a posicao em arrays
Local cFilOrig		:= ""				// Filial de origem dos titulos
Local aArea			:= GetArea()		// Salva a area atual
Local dMaiorAtraso	:= dDataBase  		// Maior atraso para o cliente

Default lVerOperad := .T.				
Default lMesmoOper		:= .T.


If Empty(dIni) .OR. Empty(dFim) .OR. Empty(cOrdem)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca a regra de selecao do operador logado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU7")
	DbSetOrder(1)
	If DbSeek(xFilial("SU7") + cOperador)
	
		DbSelectArea("SU0")
		DbSetOrder(1)
		If DbSeek(xFilial("SU0") + SU7->U7_POSTO)
	
			DbSelectArea("SK0")
			DbSetOrder(1)
			If DbSeek(xFilial("SK0") + SU0->U0_REGSEL)
				nPos	:= Ascan(aRegras, {|x| x[1] == SU0->U0_REGSEL })
						
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se encontrou a Regra de Selecao do usuario pega os dados da regra do operador ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPos > 0
					dIni		:= dDataBase - aRegras[nPos][3]		// -----60---------30--------Hoje----
					dFim		:= dDataBase - aRegras[nPos][2]		//      dIni       dFim      dDataBase
					cOrdem		:= SK0->K0_ORDEM
				Endif
			Endif
		Endif
	Endif 
EndIf      
    
If Empty(aOperad)
	aOperad := {}
	DbSelectArea("SU7")
	DbSetOrder(1)
	If DbSeek(xFilial("SU7"))

		While !SU7->(Eof()) .AND. SU7->U7_FILIAL == xFilial("SU7")

			DbSelectArea("SU0")
			DbSetOrder(1)

			If DbSeek(xFilial("SU0") + SU7->U7_POSTO)
				DbSelectArea("SK0")
				DbSetOrder(1)

				If DbSeek(xFilial("SK0") + SU0->U0_REGSEL) .AND. SU0->U0_BOUND <> '1'
					Aadd( aOperad, { SU7->U7_COD, SK0->K0_ORDEM } )
				Endif	

			Endif

			DbSelectArea("SU7")
			DbSkip()
		End	
	Endif
EndIf

DbSelectArea("SK1")
DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
If DbSeek(xFilial("SK1") + cCliente + cLoja)	
    dMaiorAtraso := dDatabase	    
    lForaFaixa := .F.
	While !SK1->(Eof())					.AND.;
		SK1->K1_CLIENTE == cCliente		.AND.;
		SK1->K1_LOJA   	== cLoja	  	.AND.;
        SK1->K1_FILIAL 	== xFilial("SK1")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe algum reagendamento para o cliente.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Tk280TemReag(cOperador,cCliente,cLoja)
			lForaFaixa := .T.
			Exit
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o Titulo ja pertence a um Operador, avalia se a Regra dele eh igual ou³
		//³maior a do operador logado, caso seja nao posso utilizar essa conta pois ³
		//³ja tem um dono.                                                          ³
		//³Se a ligacao nao foi realizada ao pedir um novo nao vai passar aqui.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  		If !Empty(SK1->K1_OPERAD) .AND. lVerOperad .AND. cOperador <> SK1->K1_OPERAD
			nPos := Ascan(aOperad, {|x| x[1] == SK1->K1_OPERAD })
			If nPos > 0
				If Val(aOperad[nPos][2]) == Val(cOrdem)
					lForaFaixa := .T.
					Exit
				EndIf
			Endif	
		Endif                 
										
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se os titulos do cadastro de referencia de titulos - SK1 - ja estao pagos. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilOrig	:= SK1->K1_FILORIG


		DbSelectArea("SE1")
		DbSetOrder(2) //Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
		If DbSeek(cFilOrig + SK1->K1_CLIENTE + SK1->K1_LOJA + SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO)
				
            If SE1->E1_VENCREA < dIni .AND. !Empty(SE1->E1_VENCREA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Esse titulo esta fora da faixa, nao pode pegar essa conta.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                								                                  	    						                
                lForaFaixa:= .T.  
                Exit
			ElseIf SE1->E1_SALDO > 0  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se todos os titulos da condicao para o operador, pode pegar essa conta. ³
				//³ A regra adotada segue o exemplo abaixo:		                            ³
				//³ Vencimento Real Maior (>) que dIni e Vencimento Real (<) Menor que dFim.³
				//³ -------|-------------------------|----------------------|               ³
				//³ (dIni)90DD ( Vencimento Real )  30DD (dFim)           Hoje              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
				If dMaiorAtraso > SE1->E1_VENCREA
					dMaiorAtraso := SE1->E1_VENCREA
				EndIf					
			Endif
        Endif
            	
		DbSelectArea("SK1")
		DbSkip()
	End  	
Else
	lForaFaixa := .T.
EndIf 
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o cliente nao atende as especificicacoes desse operador para |
//|a cobranca.													   ³
//³Nao ha titulos que se enquadrem na regra de selecao do operador ³ 
//³ou ha um titulo na faixa superior.                              ³
//³Verifica se o titulo de maior atraso esta fora da faixa do      |
//|operador       												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lForaFaixa .OR. (!(dMaiorAtraso >= dIni .AND. dMaiorAtraso <= dFim))
	lRet := .F.
Endif           						    
                                                                                             
RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280Lock    ºAutor³ Vendas Clientes    º Data ³  30/08/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria trava em arquivo para acesso unico a gravacao de regis-º±±
±±º          ³tros na tabela de controle de analise do SK1.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNomeLock - Nome do lock (arquivo) a ser criado             º±±
±±º          ³cPathLog  - Diretorio onde estao gravados os arquivos de logº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet      - .T. se conseguiu travar, .F. caso contrario     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA280                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk280Lock(cNomeLock,cPathLog)

Local nHandle	:= 0		// Handle da trava
Local lRet		:= .F.		// Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o arquivo nao existir cria a trava e verifica se esta foi³
//³criada                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File(cPathLog + cNomeLock)
	If (nHandle := FCREATE(cPathLog + cNomeLock	 ,FC_NORMAL)) > 0
		FClose(nHandle)
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280UnLock  ºAutor³ Vendas Clientes    º Data ³  30/08/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Remove a trava criada na Tk280Lock()                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNomeLock - Nome do lock (arquivo) a ser removido           º±±
±±º          ³cPathLog  - Diretorio onde estao gravados os arquivos de logº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA280                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk280UnLock(cNomeLock,cPathLog)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Checa se o arquivo existe e apaga-o ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cPathLog + cNomeLock)
	FErase(cPathLog + cNomeLock)
EndIf                  

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LeRejeicao   ºAutor³ Vendas Clientes    º Data ³  04/09/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de leitura dos clientes rejeitados para o operador,  º±±
±±º          ³devolvendo um array com cliente e loja rejeitados.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cOperador - Codigo do operador                              º±±
±±º          ³cPathLog  - Diretorio onde estao gravados os arquivos de logº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA280                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LeRejeicao(cPathLog,cOperador)

Local aArea		:= GetArea()								// Salva o posicionamento atual
Local aRet 		:= {}										// Array de retorno com clientes e lojas rejeitados
Local nLenCli	:= TamSx3("A1_COD")[1]						// Tamanho do campo A1_COD
Local nLenLoj	:= TamSx3("A1_LOJA")[1]						// Tamanho do campo A1_LOJA
Local nHandle	:= 0  										// Ponteiro do arquivo aberto
Local cFile		:= cPathLog + "REJ" + cOperador + ".COB"	// Nome do arquivo de rejeicoes para o operador
Local cCliente	:= ""										// Bloco de texto lido em cada loop, equivalente ao cliente + loja

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo e armazena seu conteudo no array aRet³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cFile) .AND. (nHandle := FOpen(cFile,FO_WRITE)) > 0
	While FRead(nHandle,@cCliente,nLenCli+nLenLoj+1) > 0
		AAdd(aRet,{SubStr(cCliente,1,nLenCli),SubStr(cCliente,nLenCli+1,nLenLoj)})
	End
EndIf

RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk280RejeicaoºAutor³ Vendas Clientes    º Data ³  04/09/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de rejeicao de atendimento, onde os vinculos do ope- º±±
±±º          ³rador sao desfeitos, liberando o atendimento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cOperador - Codigo do operador                              º±±
±±º          ³cCliente  - Codigo do cliente atendido pelo operador        º±±
±±º          ³cLoja     - Loja do cliente atendido pelo operador          º±±
±±º          ³oLbx      - Objeto com os itens da agenda do operador       º±±
±±º          ³aMemory   - Vaiaveis de memoria utilizada pelas MSMGET      º±±
±±º          ³aPanels   - Objs principais de todos os panels              º±±
±±º          ³lMsg      - Habilita/Desabilita a notificacao ao operador   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA280                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk280Rejeicao(	cOperador	, cCliente	, cLoja	, oLbx	,;
						aMemory		, aPanels	, lMsg	)
			   
Local lRet		:= .F.											// Retorno (conseguiu ou nao rejeitar)
Local aArea		:= GetArea()									// Salva posicionamento atual
Local aAreaSK1	:= SK1->(GetArea())							// Salva posicionamento do SK1
Local aAreaSU4	:= SU4->(GetArea())							// Salva posicionamento do SU4
Local aAreaSU6	:= SU6->(GetArea())							// Salva posicionamento do SU6
Local cFilSK1	:= xFilial("SK1")								// Filial do SK1
Local cFilSU6	:= xFilial("SU6")								// Filial do SU6
Local cFilACG	:= xFilial("ACG")								// Filial do ACG
Local cLista	:= SU4->U4_LISTA								// Codigo da lista
Local aRecnos	:= {}											// Lista de recnos para exclusao
Local nX   		:= 0											// Auxiliar de contadores e loops
Local cPathLog	:= GetNewPar("MV_TMKDILG","")					// Indica o diretorio onde sera gravado o arquivo de log
Local nHandle 	:= 0 											// Ponteiro de arquivo
Local cFile		:= cPathLog + "REJ" + cOperador + ".COB"		// Nome do arquivo com lista de clientes rejeitados pelo operador
Local nPos		:= 0											// Auxiliar de posicionamento de array
Local cCodLig	:= ""											// Codigo da ligacao
Local cOrdem	:= ""											// Ordem de selecao

Default lMsg 	:= .T.											// Controle para exibicao de mensagem

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o Path estiver com "", deixa em branco. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPathLog == '""'
	cPathLog := ""
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Confirma a acao do usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMsg .AND. !MsgNoYes(STR0100,STR0078)	//"Ao solicitar uma nova cobrança sem executar a cobrança atual, a mesma será desvinculada de seu operador. Confirma?" ### "Atencao"
	Return lRet
EndIf
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava arquivo de controle de rejeicoes para o operador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cFile)
	nHandle	:= FOpen(cFile,FO_WRITE)
Else                                     
	nHandle := FCreate(cFile ,FC_NORMAL)
EndIf
                                    
If nHandle > 0
	FSeek(nHandle,0,FS_END)
	FWrite(nHandle,cCliente + cLoja + ";")
	FClose(nHandle)
Else
	Return lRet
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica a ordem de selecao do operador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU7")
DbSetOrder(1)

DbSelectArea("SK0")
DbSetOrder(1)

DbSelectArea("SU0")
DbSetOrder(1)

If	SU7->(DbSeek(xFilial("SU7")+cOperador)) 		.AND.;
	SU0->(DbSeek(xFilial("SU0")+ SU7->U7_POSTO))	.AND.;
	SK0->(DbSeek(xFilial("SK0")+ SU0->U0_REGSEL))
	
	cOrdem	:= SK0->K0_ORDEM

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda os registros que deverao ser apagados na SU6³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU6")
DbSetOrder(1)//U6_FILIAL, U6_LISTA, U6_CODIGO
DbSeek(cFilSU6 + cLista)

While !SU6->(Eof())	 .AND.;
	SU6->U6_FILIAL	== cFilSU6	.AND.;
	SU6->U6_LISTA	== cLista

 	AAdd(aRecnos,SU6->(Recno()))

	SU6->(DbSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desfaz relacionamentos do titulo atual com o operador, limpando³
//³o SK1 e removendo SU4,SU6,SU8,ACG,ACF e SKV                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN TRANSACTION

	DbSelectArea("SK1")
	DbSetOrder(4)	//K1_FILIAL, K1_CLIENTE, K1_LOJA, K1_VENCREA
	DbSeek(cFilSK1 + cCliente + cLoja)
	
	While !SK1->(Eof()) .AND.;
		SK1->K1_FILIAL 	== cFilSK1	.AND.;
		SK1->K1_CLIENTE == cCliente	.AND.;
		SK1->K1_LOJA 	== cLoja
	
		RecLock("SK1",.F.)
		REPLACE SK1->K1_OPERAD WITH ""
		MsUnLock()
		SK1->(DbSkip())
	End   
	                 
	DbSelectArea("SU6")
	For nX := 1 to Len(aRecnos)
		SU6->(DbGoTo(aRecnos[nX]))
		RecLock("SU6",.F.)
		DbDelete()
		MsUnLock()
	Next nX       
	
	DbSelectArea("SU8")
	DbSetOrder(1)//U8_FILIAL, U8_CRONUM, U8_CONTATO
	If DbSeek(xFilial("SU8")+cLista)
		RecLock("SU8",.F.)
		DbDelete()
		MsUnLock()
	EndIf	
	
	DbSelectArea("SU4")
	DbSetOrder(1)//U4_FILIAL, U4_LISTA, U4_DATA	
	If DbSeek(xFilial("SU4") + cLista)
		cCodLig	:= SU4->U4_CODLIG
		RecLock("SU4",.F.)
		DbDelete()
		MsUnLock()
	EndIf
	                   
	aRecnos := {}
	DbSelectArea("ACG")
	DbSetOrder(1)//ACG_FILIAL, ACG_CODIGO, ACG_PREFIX, ACG_TITULO, ACG_PARCEL, ACG_TIPO, ACG_FILORI
	DbSeek(cFilACG+cCodLig)
	While !ACG->(Eof()) .AND.;
		ACG->ACG_FILIAL == cFilACG .AND.;
		ACG->ACG_CODIGO == cCodLig
		AAdd(aRecnos,ACG->(Recno()))
		ACG->(DbSkip())
	End
	
	For nX := 1 to Len(aRecnos)
		ACG->(DbGoTo(aRecnos[nX]))
		RecLock("ACG",.F.)
		DbDelete()
		MsUnLock()
	Next nX       
	
	DbSelectArea("ACF")
	DbSetOrder(1)//ACF_FILIAL, ACF_CODIGO
	If DbSeek(xFilial("ACF") + cCodLig)
		RecLock("ACF",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	DbSelectArea("SKV")
	DbSetOrder(1) //KV_FILIAL+KV_DATA+KV_CLIENTE+KV_LOJA+KV_ORDEM
	If SKV->(DbSeek( xFilial("SKV") + DtoS(Date()) + cCliente + cLoja + cOrdem ))
		RecLock("SKV",.F.)
		DbDelete()
		MsUnLock()
	EndIf
	
END TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Remove o agendamento da ligacao do Listbox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (oLbx <> NIL) .AND. (nPos := Ascan(oLbx:aArray, {|x| AllTrim(x[2])== cCliente .AND. x[3] == cLoja })) > 0

    ADel( oLbx:aArray, nPos )
	ASize( oLbx:aArray, Len(oLbx:aArray)-1 ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se zerou a agenda, adiciona um elemento vazio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If Len(oLbx:aArray) = 0
		aAdd(oLbx:aArray, {	LoadBitmap( GetResources(), "BR_CINZA" ),"","","","","","","","","","",""})
	Else
		Asort( oLbx:aArray,,, { |x,y| ( x[10] + DtoC(x[8]) + x[9] ) < ( y[10] + DtoC(y[8]) + y[9] ) } )
	Endif					

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa a enchoice da tela Novo Pre-atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aMemory <> NIL
	Tk280Memory("SA1", @aMemory, .F.)
	nPos := Ascan(aPanels, {|x| x[2]=="FOBJ02"} )
	aPanels[nPos][1]:Refresh()
	                                        
	Tk280Memory("SU5", @aMemory, .F.)
	nPos := Ascan(aPanels, {|x| x[2]=="FOBJ03"} )
	aPanels[nPos][1]:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados do browse de Titulos cobrados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aPanels <> NIL
	nPos := Ascan(aPanels, {|x| x[2]=="FOBJ04"} )
	Tk280SK1(@aPanels[nPos][1]:aHeader, @aPanels[nPos][1]:aCols, @aPanels[Ascan(aPanels, {|x| x[2]=="FOBJ05"} )][1],,,.T.)
	aPanels[nPos][1]:Refresh()
EndIf

RestArea(aAreaSK1)
RestArea(aAreaSU4)
RestArea(aAreaSU6)
RestArea(aArea)

lRet := .T.

Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
