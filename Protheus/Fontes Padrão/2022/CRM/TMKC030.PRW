#INCLUDE "TMKC030.CH"
#INCLUDE "PROTHEUS.CH"

/*
Modelo da Arvore de Monitoracao - TREE
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³	  01 - Todos os Operadores de Call Center           ³
³		  A  - Operadores do grupo de atendimento 01    ³
³		  A  - Operadores do grupo de atendimento 02    ³
³		  A  - Operadores do grupo de atendimento n...  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKC030   ºAutor  ³Marcelo Kotaki      º Data ³  08/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a tela inicial da consulta                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fernando  ³12/12/06³9.12  ³Bops 115445 Alterado a array aRotina  para  ³±±
±±³          ³        |      ³ criação do menu funcional              	  ³±±
±±³          ³        ³      ³                                            ³±±
±±³          ³        ³      ³                                            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKC030()

Private aRotina := MenuDef()

Private cCadastro:= STR0003 //"Informações de monitoramento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(,,,,"SU0")

Return(.T.) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Fernando Amorim       ³ Data ³12/12/06  ³±±
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

Local aRotina:= {		{STR0001,	"AxPesqui",		0,	1 , , .F.},;	//"Pesquisar"
						{STR0002,	"TK030Monitor",	0,	2 , , .T.} }	//"Consulta"



							
							
Return(ARotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK030MonitorºAutor  ³Marcelo Kotaki    º Data ³  08/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta da tela de Monitoracao para o supervisor           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³06/04/04³811   ³- Incluido validacao para verificar se o    ³±±
±±³          ³        ³      ³Operador e um Supervisor para ter acesso a  ³±±
±±³          ³        ³      ³rotina.                                     ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK030Monitor()

Local oExplorer					// Objeto principal EXPLORER.
Local oTimer					// Objeto TIMER para atualizacao dos status dos grupos
Local nRow			:= 0		// Controle de coordenadas de linhas da tela.
Local nCol			:= 0		// Coordenadas de colunas da tela.
Local nPanel		:= 0		// Numero do painel atual
Local aMemory		:= {}		// Variaveis de memoria utilizadas pelas enchoices
Local aChoice		:= {}		// Contem o ponteiro dos objetos de enchoices das tabelas SU5 e SU0
Local lSupervisor	:= .F. 		// Flag para indicar que o usuario esta no cadastro de Operadores e se e um Supervisor
Local lRet			:= .T.		// Retorno da Funcao



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa o usuario no cadastro de operadores	e valida se e um SUPERVISOR³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lSupervisor := TmkOperador(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao encontrou o usuario no Cadastro de Operadores OU ele nao for um SUPERVISOR Nao executa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lSupervisor 
	Help(" ",1,"TK180NSUPE")  
	lRet:=.F.  
Endif

If lRet

	FATPDLoad(Nil,Nil,{"U7_NOME"}) 

	RegToMemory("SU7",.F.)
	RegToMemory("SU0",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define o Explorer - tela principal da tela de consulta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer := MsExplorer():New(STR0004) //"Tela de Monitoração dos Grupos de Atendimento"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Toolbar padrao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:DefaultBar()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Botoes especificos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddDefButton("BMPSERV1",	STR0005,	{ || Tkc030Change(oExplorer, @aMemory, aChoice) } ) //"Status"
	oExplorer:AddDefButton("FINAL",		STR0006,	{ || (SetKey(VK_F5, {|| AllWaysTrue() } ),oExplorer:DeActivate()) } ) //"Saida"
	
	SetKey(VK_F5, {|| Tkc030Change(oExplorer, @aMemory, aChoice) } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os Grupos de atendimento                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nPanel := oExplorer:AddTree(STR0007,"GROUP",,"00") //"Todos Operadores"
	nRow := Int((oExplorer:aPanel[nPanel]:nHeight * .97) / 2)
	nCol := Int((oExplorer:aPanel[nPanel]:nWidth * .985) / 2)
	
	Tkc030Painel(	oExplorer,		nPanel,		"00",		nRow,;
					nCol,			@aChoice,	@aMemory)
	
	DbSelectarea("SU0")
	DbSetOrder(1)
	MsSeek(xFilial("SU0"))
	While (!Eof()) .AND. (xFilial("SU0") == SU0->U0_FILIAL)
		
		oExplorer:AddItem(SU0->U0_NOME,"BMPUSER",SU0->U0_CODIGO,,.F.)	// Grupos de Atendimento
		
		DbSelectarea("SU0")
		DbSkip()
	End
	
	oExplorer:EndTree()
	
	DEFINE TIMER oTimer INTERVAL 5000 ACTION Tkc030Change(oExplorer, @aMemory, @aChoice)
	oExplorer:oDlg:bInit := { || oTimer:Activate() }
	
	oExplorer:bChange := {|| Tkc030Change(oExplorer, @aMemory, @aChoice)}
	
	FATPDLogUser('TKC030CHAN')	// Log de Acesso LGPD
	oExplorer:Activate()

	FATPDUnload()
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKC030   ºAutor  ³Armando M. Tessaroliº Data ³  13/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta todo o conteudo do painel que mostrara a monitoracao  º±±
±±º          ³dos operadores.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oExplorer - Objeto do MsExplorer                           º±±
±±º          ³ nPanel    - Numero do painel a ser trabalhado              º±±
±±º          ³ cGrupo    - Codigo do Grupo de Atendimento que sera atualizº±±
±±º          ³ nRow      - Valor maximo das linhas em pixel               º±±
±±º          ³ nCol      - Valor maximo das colunas em pixel              º±±
±±º          ³ aChoice   - Array de ponteiro dos objetos enchoice         º±±
±±º          ³ aMemory   - Variaveis de memoria das enchoices             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tkc030Painel(	oExplorer,	nPanel,		cGrupo,		nRow,;
								nCol,		aChoice,	aMemory)

Local aDados	:= {}		// Dados s serem mostrados do ListBox.
Local oListBox				// Objeto ListBox.
Local oFolder				// Folder de duas pastas com as enchoices das tabelas SU5 e SU0.
Local aCoord	:= {}		// Coordenadas de tela das enchoices.
Local aPDCols	:= {"","","","","U7_NOME",""} 

@ (nRow*.02),(nCol*.02) ListBox oListBox Fields Size (nCol*.98),(nRow*.4) Of oExplorer:GetPanel(nPanel) Pixel
oListBox:aHeaders	:= {"", STR0008, STR0009, STR0010, STR0011} //"Rotina"###"Ramal"###"início"###"Operador"
oListBox:Cargo		:= "LISTBOX"
oListBox:bChange	:= { || TKC030LBChange(oListBox, @aMemory, aChoice) }

Aadd( aDados, {	LoadBitmap( GetResources(), "BR_VERDE" ), Space(30), "", "", "", "" } )
oListBox:SetArray(aDados)
oListBox:bLine:={||{	aDados[oListBox:nAt][1],;
						aDados[oListBox:nAt][2],;
						aDados[oListBox:nAt][3],;
						aDados[oListBox:nAt][4],;
						aDados[oListBox:nAt][5],;
						aDados[oListBox:nAt][6];
						}}
oListBox:nAt := 1
oListBox:Refresh()

If FATPDActive() .And. FTPDUse(.T.)
	oListBox:aObfuscatedCols := FATPDColObfuscate(aPDCols)
EndIf

@ (nRow*.45),(nCol*.02) TO (nRow*.60),(nCol) Label STR0012 OF oExplorer:GetPanel(nPanel) PIXEL //"Legendas"

@ (nRow*.50), (nCol*.03) BITMAP RESOURCE "BR_VERDE" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.50), (nCol*.06) SAY STR0013 OF oExplorer:GetPanel(nPanel) PIXEL //"Atendimento Aberto"

@ (nRow*.55), (nCol*.03) BITMAP RESOURCE "BR_AMARELO" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.55), (nCol*.06) SAY STR0014 OF oExplorer:GetPanel(nPanel) PIXEL //"Falando com Cliente"

@ (nRow*.50), (nCol*.23) BITMAP RESOURCE "BR_AZUL" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.50), (nCol*.26) SAY STR0015 OF oExplorer:GetPanel(nPanel) PIXEL //"Executando Agenda"

@ (nRow*.55), (nCol*.23) BITMAP RESOURCE "BR_LARANJA" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.55), (nCol*.26) SAY STR0016 OF oExplorer:GetPanel(nPanel) PIXEL //"Pré-atendimento"

@ (nRow*.50), (nCol*.43) BITMAP RESOURCE "BR_VERMELHO" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.50), (nCol*.46) SAY STR0017 OF oExplorer:GetPanel(nPanel) PIXEL //"Novo Pré-atendimento"


@ (nRow*.63),(nCol*.02) FOLDER oFolder ITEMS STR0011, STR0018 SIZE (nCol*.98),(nRow*.33) OF oExplorer:GetPanel(nPanel) PIXEL //"Operador"###"Grupo"
nRow := (oFolder:nHeight*.9)/2
nCol := oFolder:nWidth/2

Aadd(aCoord, { (nRow*.02), (nCol*.02), (nRow*.90), (nCol*.98) } )
Aadd( aChoice, MsMGet():New("SU7",RecNo(),2,,,,,aCoord[1],,3,,,,oFolder:aDialogs[1]) )
Aadd( aChoice, MsMGet():New("SU0",RecNo(),2,,,,,aCoord[1],,3,,,,oFolder:aDialogs[2]) )

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk030StatusºAutor  ³Marcelo Kotaki     º Data ³  08/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Devolve o status do Flag (Situacao da Tela), Rotina, Ramal  º±±
±±º          ³e Tempo Inicial do atendimento - tudo baseado no SUV        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cGrupo - Codigo do Grupo de Atendimento que sera pesquisado º±±
±±º          ³cTipo  - Tipo de retorno esperado da funcao                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk030Status(cGrupo, cTipo)

Local oAberta	:= LoadBitmap( GetResources(), "BR_VERDE" )			// Objeto de cor da legenda
Local oCliente	:= LoadBitmap( GetResources(), "BR_AMARELO" )		// Objeto de cor da legenda
Local oAtivo	:= LoadBitmap( GetResources(), "BR_AZUL" )			// Objeto de cor da legenda
Local oPreAtend	:= LoadBitmap( GetResources(), "BR_LARANJA" )		// Objeto de cor da legenda
Local oNovoPre	:= LoadBitmap( GetResources(), "BR_VERMELHO" )		// Objeto de cor da legenda
Local xRet		:= ""												// Retorno devolvido pelo função

If cTipo == "3"  	// Ramal
	xRet := SUV->UV_RAMAL
Endif

If cTipo == "4"  	// Hora Inicial
	xRet := SUV->UV_HRINI
Endif

If cTipo $ "12"  // Status e Tela
	Do Case
		Case SUV->UV_ROTINA == "TMK0"
			If cTipo == "1"
				xRet := oAberta
			Else
				xRet := STR0019 //"Telemarketing"
			Endif
			
		Case SUV->UV_ROTINA == "TMK1"
			If cTipo == "1"
				xRet := oCliente
			Else
				xRet := STR0019 //"Telemarketing"
			Endif
			
		Case SUV->UV_ROTINA == "TLV0"
			If cTipo == "1"
				xRet := oAberta
			Else
				xRet := STR0020 //"Televendas"
			Endif
			
		Case SUV->UV_ROTINA == "TLV1"
			If cTipo == "1"
				xRet := oCliente
			Else
				xRet := STR0020 //"Televendas"
			Endif
			
		Case SUV->UV_ROTINA == "TLC0"
			If cTipo == "1"
				xRet := oAberta
			Else
				xRet := STR0021 //"Telecobrança"
			Endif
			
		Case SUV->UV_ROTINA == "TLC1"
			If cTipo == "1"
				xRet := oCliente
			Else
				xRet := STR0021 //"Telecobrança"
			Endif
			
		Case SUV->UV_ROTINA == "AGE0"
			If cTipo == "1"
				xRet := oAberta
			Else
				xRet := STR0022 //"Agenda"
			Endif
			
		Case SUV->UV_ROTINA == "AGE1"
			If cTipo == "1"
				xRet := oAtivo
			Else
				xRet := STR0022 //"Agenda"
			Endif
			
		Case SUV->UV_ROTINA == "PRE0"
			If cTipo == "1"
				xRet := oPreAtend
			Else
				xRet := STR0016 //"Pré-atendimento"
			Endif
			
		Case SUV->UV_ROTINA == "PRE1"
			If cTipo == "1"
				xRet := oNovoPre
			Else
				xRet := STR0017 //"Novo Pré-atendimento"
			Endif
	Endcase
Endif

Return(xRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKC030   ºAutor  ³Armando M. Tessaroliº Data ³  13/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os dados do painel principal de agordo com a troca º±±
±±º          ³dos itens do tree dentro do objeto Explorer.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oExplorer - Objeto do MsExplorer                           º±±
±±º          ³ aMemory   - Variaveis de memoria das enchoices             º±±
±±º          ³ aChoice   - Array de ponteiro dos objetos enchoice         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tkc030Change(oExplorer, aMemory, aChoice)

Local cGrupo	:= oExplorer:GetPanel(oExplorer:nPanel):Cargo	// Cargo do objeto que guarda o codigo do grupo de atendimento
Local aDados	:= {}		// Dados que serao apresentados no listbox
Local oListBox				// Objeto listbox
Local oSU5					// Enchoice da tabela SU5
Local oSU0					// Enchoice da tabela SU0
Local aTemp		:= {}		// Array temporario para localizar um objeto dentro do Explorer
Local nI		:= 0		// Controle de loop

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega os dados do item de telemarketing.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTemp := aClone(oExplorer:aPanel[1]:oWnd:aControls)
For nI := 1 To Len(aTemp)
	If ValType(aTemp[nI]) == "O" .AND. ValType(aTemp[nI]:Cargo) == "C" .AND. aTemp[nI]:Cargo == "LISTBOX"
		oListBox := aTemp[nI]
	Endif
	If ValType(aTemp[nI]) == "O" .AND. ValType(aTemp[nI]:Cargo) == "C" .AND. aTemp[nI]:Cargo == "SU5"
		oSU5 := aTemp[nI]
	Endif
	If ValType(aTemp[nI]) == "O" .AND. ValType(aTemp[nI]:Cargo) == "C" .AND. aTemp[nI]:Cargo == "SUO"
		oSU0 := aTemp[nI]
	Endif
	If ValType(oListBox) == "O" .AND. ValType(oSU5) == "O" .AND. ValType(oSU0) == "O"
		Exit
	Endif
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mantem o primeiro painel sempre ativo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oExplorer:SetPanel(1)

If !Empty(cGrupo)
	DbSelectarea("SUV")
	DbSetorder(1)
	MsSeek(xFilial("SUV"))
	While ! Eof() .AND. SUV->UV_FILIAL == xFilial("SUV")
		
		If Empty(SUV->UV_ROTINA)
			DbSelectArea("SUV")
			DbSkip()
			Loop
		Endif
		
		
		If cGrupo == "00"
			DbSelectarea("SU7")
			DbSetorder(4)		// U7_FILIAL+U7_CODUSU
			If MsSeek(xFilial("SU7")+SUV->UV_USUARIO)
				DbSelectarea("SUV")
				If DBRLOCK()
					SUV->UV_ROTINA  := ""
					DBRUNLOCK()
				EndIf
				Aadd( aDados, {	Tk030Status(cGrupo,"1"),;
								Tk030Status(cGrupo,"2"),;
								Tk030Status(cGrupo,"3"),;
								Tk030Status(cGrupo,"4"),;
								SU7->U7_NOME,;
								SUV->UV_USUARIO;
								} )
			Endif
		Else
			DbSelectarea("SU7")
			DbSetorder(4)		// U7_FILIAL+U7_CODUSU
			If MsSeek(xFilial("SU7")+SUV->UV_USUARIO)
				If SU7->U7_POSTO == cGrupo
					DbSelectarea("SUV")
					If DBRLOCK()
						SUV->UV_ROTINA  := ""
						DBRUNLOCK()
					EndIf
					Aadd( aDados, {	Tk030Status(cGrupo,"1"),;
									Tk030Status(cGrupo,"2"),;
									Tk030Status(cGrupo,"3"),;
									Tk030Status(cGrupo,"4"),;
									SU7->U7_NOME,;
									SUV->UV_USUARIO;
									} )
				Endif
			Endif
		Endif
		
		DbSelectArea("SUV")
		DbSkip()
	End
Endif

If Len(aDados) == 0
	Aadd( aDados, {	LoadBitmap( GetResources(), "BR_VERDE" ), Space(30), "", "", "", "" } )
Endif
oListBox:SetArray(aDados)
oListBox:bLine:={||{	aDados[oListBox:nAt][1],;
						aDados[oListBox:nAt][2],;
						aDados[oListBox:nAt][3],;
						aDados[oListBox:nAt][4],;
						aDados[oListBox:nAt][5],;
						aDados[oListBox:nAt][6];
						}}
oListBox:nAt := 1
oListBox:Refresh()
	
DbSelectArea("SU7")
DbSetOrder(4)
If MsSeek(xFilial("SU7") + aDados[oListBox:nAt][6])
	Tkc030Memory("SU7", @aMemory, .T.)
Else
	Tkc030Memory("SU7", @aMemory, .F.)
Endif
aChoice[1]:Refresh()
	
DbSelectArea("SU0")
DbSetOrder(1)
If MsSeek(xFilial("SU0") + SU7->U7_POSTO)
	Tkc030Memory("SU0", @aMemory, .T.)
Else
	Tkc030Memory("SU0", @aMemory, .F.)
Endif
aChoice[2]:Refresh()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tkc030MemoryºAutor ³Armando M. Tessaroliº Data ³ 14/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualizacao das variaveis de memoria que alimentam o objeto º±±
±±º          ³da enchoice com os dados da posicao atual.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cAlias  - Nome da tabela a ser trabalhada                   º±±
±±º          ³aMemory - Variaveis de memoria utilizadas pela enchoice     º±±
±±º          ³lDados  - Define se as veriaveis serao iniciadas com conteudº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tkc030Memory(cAlias, aMemory, lDados)

Local lRet		:= .T.		// Retorno da funcao
Local cCampo	:= ""		// Nome do campo
Local nPos		:= 0		// Posicao de objeto
Local nI		:= 0		// Contador de loop

Default lDados	:= .T.		// Define se cria as variaveis com dados ou em branco

nPos := Ascan(aMemory, {|x| x[1] == cAlias })
If nPos == 0
	DbSelectArea("SX3")
	DbSetOrder(1)
	MsSeek(cAlias)
	While ( !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == cAlias)
		If X3USO(SX3->X3_USADO)
			cCampo := ALLTRIM(SX3->X3_CAMPO)
			Aadd(aMemory, {cAlias, cCampo, X3_CONTEXT} )
			If lDados
				If (X3_CONTEXT # "V")
					M->&(cCampo) := (cAlias)->&(cCampo)
				Else
					M->&(cCampo) := CriaVar(cCampo, lDados)
				Endif
			Else
				M->&(cCampo) := CriaVar(cCampo, lDados)
			Endif
		Endif
		
		DbSkip()
	End
Else
	For nI := nPos To Len(aMemory)
		cCampo := AllTrim(aMemory[nI][2])
		If lDados
			If (aMemory[nI][3] # "V")
				M->&(cCampo) := (cAlias)->&(cCampo)
			Else
				M->&(cCampo) := CriaVar(cCampo, lDados)
			Endif
		Else
			M->&(cCampo) := CriaVar(cCampo, lDados)
		Endif
		
		If aMemory[nI][1] <> cAlias
			Exit
		Endif
	End
EndIf

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKC030   ºAutor  ³Armando M. Tessaroliº Data ³  14/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a atualizacao das enchoices pelo evento change dos º±±
±±º          ³itens do listbox com os operadores.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³oListBox - Objeto ListBox onde o evento sera tratado        º±±
±±º          ³aMemory  - Variaveis de memoria das enchoices SU5 e SU0     º±±
±±º          ³aChoice  - Referencia dos objetos das enchoices SU5 e SU0   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TKC030LBChange(oListBox, aMemory, aChoice)
	
DbSelectArea("SU7")
DbSetOrder(4)
If MsSeek(xFilial("SU7") + oListBox:aArray[oListBox:nAt][6])
	Tkc030Memory("SU7", @aMemory, .T.)
Else
	Tkc030Memory("SU7", @aMemory, .F.)
Endif

If Len(aChoice) > 0
	aChoice[1]:Refresh()
Endif
	
DbSelectArea("SU0")
DbSetOrder(1)
If MsSeek(xFilial("SU0") + SU7->U7_POSTO)
	Tkc030Memory("SU0", @aMemory, .T.)
Else
	Tkc030Memory("SU0", @aMemory, .F.)
Endif

If Len(aChoice) > 0
	aChoice[2]:Refresh()
Endif

Return(.T.)

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
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta função deve utilizada somente após a inicialização das variaveis 
    atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf

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
