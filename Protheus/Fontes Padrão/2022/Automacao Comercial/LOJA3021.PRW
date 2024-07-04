#INCLUDE "LOJA3021.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Static cChaveMGB := NIL

Static cXBLoj0045 := "" //Consulta Padrao do LOJ005/LOJ005
Static cCRLF      := Chr(13) + Chr(10)     		// Pula linha
Static cProdItem	:= ""						// Armazena Código do produto do ITEM (MB8) ao chamar a janela ProdRelação (MGB) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ Loja3021 ³ Autor ³Vendas Clientes        ³ Data ³01.03.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de Manutencao das Regras de Desconto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Loja3021()                             			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigaloja                    									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador    ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 17/04/14 ³ Mauro Paladini ³Ajustes na tela (maximizado)                 ³±±
±±³          ³                ³Inclusao de barra de botoes e Panels         ³±±
±±³          ³                ³Alteracao no Folder Filiais Tabela MB3       ³±±
±±³          ³                ³BRINDES/BONIFICACAO/DESCONTOS Tabela MGB     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Loja3021()
Local aArea		:= GetArea()				// Posicionamento atual da tabela 
Local aCores	:= {}						// Array para Cores
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) // variavel que trata se foi chamado pelo Robo de Testes

Private aRotina := MenuDef()      	// Menu Def

cCadastro := OemToAnsi(STR0076)    	// "Manutencao das Regras de Desconto" 

If cChaveMGB = NIL
	cChaveMGB := FWX2Unico("MGB")
EndIf

cXBLoj0045 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereca para a funcao MBrowse                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("MEI")
dbSetOrder(1) //MEI_FILIAL+MEI_CODREG
DbSeek(xFilial("MEI"))
// Identificar a variavel de uso do robo e nao chamar a funcao do mBrowse
If !lAutomato
	mBrowse(06,01,22,75,"MEI",,,,,,aCores)    
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade da Rotina                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MEI")
dbSetOrder(1) //MEI_FILIAL+MEI_CODREG
dbClearFilter() 

cXBLoj0045 := "" 

RestArea(aArea)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³MenuDef   ³ Autor ³ 				        ³ Data ³01/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Private aRotina := {{ STR0077	,"AxPesqui"		,0,1,0,.F.},;			// "Pesquisar"   
{ STR0001	,"LJ3021MAN"		,0,2,0,NIL},;							// "Visualizar" 
{ STR0003	,"LJ3021MAN"		,0,3,0,NIL},;							// "Incluir" 
{ STR0004	,"LJ3021MAN"		,0,4,0,NIL},;							// "Alterar" 
{ STR0005	,"LJ3021MAN"		,0,5,0,NIL},; 							// "Excluir" 
{ STR0006	,"LJ3024MAN"	   	,0,6,0,NIL}} 							// "Prioridade"   

Return aRotina

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³LJ3021Man ³ Autor ³                       ³ Data ³ 31/03/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de Manutencao das - Regras de Desconto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ3021Man(cAlia,nReg,nOpc)                      			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: cAlia                                                 ³±±
±±³          ³ ExpN2: nReg                                                  ³±±
±±³          ³ ExpN3: nOpc                                                  ³±±
±±³          ³ ExpN4: lEncPriv                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigaloja                    									³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ3021Man(cAlia,nReg,nOpc,lEncPriv)
Local lNovRegDesc := SuperGetMv("MV_LJRGDES",,.F.) .And. RGVldTable() //Validacao da Nova Regra de Desconto Ativa
Local nSaveSx8  	:= GetSx8Len()	  						// Controle SX8
Local nOpcA     	:= 0		  								// Opção da tabela
Local aArea     	:= GetArea()		  						// Array p guardar area
Local lContinua 	:= .T.		  								// Variavel Controle do processo
Local aButtons	:= {}		  								// Array Botoes
Local aAlterMB3	:= {}										// Array auxiliar - tabela MB3
Local oHrIDom					  								// Objeto Hora inicial - Domingo
Local oHrISeg					  								// Objeto Hora inicial - Segunda-feira
Local oHrITer					  								// Objeto Hora inicial - Terça-feira
Local oHrIQua					  								// Objeto Hora inicial - Quarta-feira
Local oHrIQui					  								// Objeto Hora inicial - Quinta-feira
Local oHrISex					  								// Objeto Hora inicial - Sexta-feira
Local oHrISab					  								// Objeto Hora inicial - Sábado
Local oHrFDom					  								// Objeto Hora Final   - Domingo
Local oHrFSeg					  								// Objeto Hora Final   - Segunda-feira
Local oHrFTer					  								// Objeto Hora Final   - Terça-feira
Local oHrFQua					  								// Objeto Hora Final   - Quarta-feira
Local oHrFQui					  								// Objeto Hora Final   - Quinta-feira
Local oHrFSex					  								// Objeto Hora Final   - Sexta-feira
Local oHrFSab					  								// Objeto Hora Final   - Sábado
Local aSize													// Array para tamanho do dialog
Local aObjects		:= {}									// Array para objeto dialog
Local lAutomato		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) // variavel que trata se foi chamado pelo Robo de Testes

Default lEncPriv	:= .F.										// Define se a Enchoice usa agets e a tela private

////// ABA 02
Private _aLstFil := {}                							// Lista filiais
Private oLstFil													// Objeto filiais
Private oGetDdVlr												// Objeto 
Private oPanel_Item												// Objeto
Private oPanel_Negoc:= NIL 
Private oGetDFilial								 				// Objeto Grupo Filiais/Filiais
Private oGetD													// Objeto Produtos x Brindes
Private nOpcGetD	:= 0

Private aColsMB3	:= {}										// aCols objeto Filiais
Private aHeadMB3	:= {}										// AaHeader objeto Filiais
Private aProdRef	:= {}										// Referencia --> Produtos vinculados   

Private _cHrIDom := Space(05)									// Hora Inicial por dia da semana
Private _cHrISeg := Space(05)									// Hora Inicial por dia da semana
Private _cHrITer := Space(05)									// Hora Inicial por dia da semana
Private _cHrIQua := Space(05)									// Hora Inicial por dia da semana
Private _cHrIQui := Space(05)									// Hora Inicial por dia da semana
Private _cHrISex := Space(05)									// Hora Inicial por dia da semana
Private _cHrISab := Space(05)									// Hora Inicial por dia da semana
Private _cHrFDom := Space(05)									// Hora Final por dia da semana
Private _cHrFSeg := Space(05)									// Hora Final por dia da semana
Private _cHrFTer := Space(05)									// Hora Final por dia da semana
Private _cHrFQua := Space(05)									// Hora Final por dia da semana
Private _cHrFQui := Space(05)									// Hora Final por dia da semana
Private _cHrFSex := Space(05)									// Hora Final por dia da semana
Private _cHrFSab := Space(05)									// Hora Final por dia da semana


Private _lChkBx1 := .F.											// Controle Checkbox
Private _lChkBx2 := .F.											// Controle Checkbox
Private _lChkBx3 := .F.											// Controle Checkbox
Private _lChkBx4 := .F.											// Controle Checkbox
Private _lChkBx5 := .F.											// Controle Checkbox
Private _lChkBx6 := .F.											// Controle Checkbox
Private _lChkBx7 := .F.											// Controle Checkbox
Private _lChkBx8 := .F.											// Controle Checkbox
Private _lChkBx9 := .F.											// Controle Checkbox
Private _lChkBx10:= .F.											// Controle Checkbox
Private _lChkBx11:= .F.											// Controle Checkbox
Private _lChkBx20:= .F.											// Controle Checkbox
Private lChkPropor := .F.										// Controle Checkbox
Private _lSemana := .T.											// Controle semana                       
Private _lPainelAba2 := .F.										// Inicializacao do Painel quando Inclusao

// Privates do Folder Formas/Condicoes
Private _cCmbBxBIN										  		// ComboBox
Private _cCmbBxPro										  		// ComboBox
Private _aLstBxFrm := {}								  		// ListBox
Private _aLstBxCPg := {}								  		// ListBox
Private _aLstBxAdm := {}								  		// ListBox
Private Acols := {}										  		// Acols
Private oLstBxFrm										  		// Objeto List
Private oLstBxCPg										  		// Objeto List
Private oLstBxAdm										  		// Objeto List
Private _lChkBx12 := .F.								  		// ListBox
Private _lChkBx13 := .F.								  		// ListBox
Private _lChkBx14 := .F.								  		// ListBox

// Variaveis Private de uso Generico
Private oOk     := LoadBitmap( GetResources(), "LBOK")			// Ok
Private oNo     := LoadBitmap( GetResources(), "LBNO")			// Nao

// Variaveis de controle
Private VISUAL  := .F.											// Variaveis de controle VISUAL
Private INCLUI  := .F.											// Variaveis de controle INCLUI
Private ALTERA  := .F.											// Variaveis de controle ALTERA
Private DELETA  := .F.											// Variaveis de controle DELETA

Default cAlia := ""			// cAlia
Default nReg  := 0			// nReg
Default nOpc  := 0 			// nOpc

#IFDEF WCODB
	MsgAlert(STR0078) // "Para utilizar esta opcao e necessario estar na retaguarda"
	Return Nil
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³valida se parametro da nova regra ³
//³esta T e se o UPDATE foi aplicado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lNovRegDesc == .F.
	MsgInfo(STR0067) // "Para utilizar nova regra de desconto verificar MV_LJRGDES e Update"
	Return
ENDIF

If nOpc == 2
	VISUAL  := .T.
	INCLUI  := .F.
	ALTERA  := .F.
	DELETA  := .F.
ElseIf nOpc == 3
	VISUAL  := .F.
	INCLUI  := .T.
	ALTERA  := .F.
	DELETA  := .F.
ElseIf nOpc == 4
	VISUAL  := .F.
	INCLUI  := .F.
	ALTERA  := .T.
	DELETA  := .F.
ElseIf nOpc == 5
	VISUAL  := .F.
	INCLUI  := .F.
	ALTERA  := .F.
	DELETA  := .T.
EndIf


If nOpc == 2 .Or. nOpc == 5
	nOpcGetD := 0                      
Else
	nOpcGetD := GD_INSERT + GD_UPDATE + GD_DELETE
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa as variaveis da Enchoice                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI
	RegToMemory( "MEI", .T., .F. )
EndIf

If !INCLUI
	
	If SoftLock("MEI")  // Permite a reserva do registro posicionado na area de trabalho ativa
		RegToMemory( "MEI", .F., .F. )
	Else
		lContinua := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dimensoes                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
aSize := MsAdvSize()       

AAdd( aObjects, { 100, 050, .T., .T. } )
AAdd( aObjects, { 100, 050, .T., .T. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }	
aPosObj := MsObjSize( aInfo, aObjects,.T.)	

oDlg := TDialog():New(aSize[7],000,aSize[6],aSize[5],;
						STR0008,,,,;
						,,,,;
						oMainWnd,.T.)  //"Regra de desconto - Varejo"

//+----------------------------------------------------------------------------
//| Cria a Folder SUPERIOR
//+----------------------------------------------------------------------------
oPanelTop := TPanel():New(aPosObj[1][1],aPosObj[1][2],,oDlg,;
								,,,,;
								,aPosObj[1][4], aPosObj[1][3]-aPosObj[1][1],.F.,;
								.F.)

aTFolder := { STR0068, STR0069, STR0070, STR0071 } // Cadastro ### Dias da Semana ### Empresa / Filial ### Range de Valores
oTFolder := TFolder():New( 0,0,aTFolder,,;
								oPanelTop,,,,;
								.T.,,0,0)
oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
oTFolder:bSetOption := {|| LJ3021MdFolder(oTFolder:nOption),oTFolder:Refresh() }

//+----------------------------------------------------------------------------
//| ABA NUMERO 1 (CADASTRO)
//+----------------------------------------------------------------------------
aPos := {01,01,145,435}

If !lAutomato
		Enchoice(cAlia, nReg , nOpc, /*aCRA*/,;
		/*cLetra*/, /*cTexto*/,,{1,1,(oPanelTop:nClientHeight-aPosObj[1][1])/2,(oPanelTop:nClientWidth-aPosObj[1][2])/2},;
		,,/*nColMens*/,/*cMensagem*/,;
		/*cTudoOk*/, oTFolder:aDialogs[1],,,;
		,,,lEncPriv )
EndIf

If !INCLUI
	RecuperaReg(M->MEI_CODREG) //  recupera registros na consulta e alteraçao
Endif                                                                   


//+----------------------------------------------------------------------------
//| ABA NUMERO 2 (DIAS DA SEMANA)
//+----------------------------------------------------------------------------
///                                                              col,lin

oPanelAba02_01:= tPanel():New(01,01,"",oTFolder:aDialogs[2],,,,,,0,0)

oPanelAba02_01:Align := CONTROL_ALIGN_ALLCLIENT

@ C(002),C(010) CheckBox oChkBx1 Var _lChkBx1 Prompt STR0009 Size C(033),C(008) Valid(VldDia())             PIXEL OF oTFolder:aDialogs[2] //"Domingo"
@ C(002),C(045) Say STR0010 Size C(013),C(008) COLOR CLR_BLACK                                                  PIXEL OF oPanelAba02_01 //"Hora"
@ C(002),C(060) MsGet oHrIDom Var _cHrIDom Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx1 Valid LJ3021VldHr(_cHrIDom,_lChkBx1) PIXEL OF oTFolder:aDialogs[2]
@ C(002),C(085) Say STR0011 Size C(010),C(008) COLOR CLR_BLACK                                                   PIXEL OF oPanelAba02_01 //"Até"
@ C(002),C(095) MsGet oHrFDom Var _cHrFDom Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx1 Valid LJ3021VldHr(_cHrFDom,_lChkBx1) PIXEL OF oTFolder:aDialogs[2]

@ C(013),C(010) CheckBox oChkBx2 Var _lChkBx2 Prompt STR0012 Size C(033),C(008) Valid(VldDia())             PIXEL OF oTFolder:aDialogs[2] //"Segunda"
@ C(013),C(045) Say STR0010 Size C(013),C(008) COLOR CLR_BLACK                                                  PIXEL OF oPanelAba02_01 //"Hora"
@ C(013),C(060) MsGet oHrISeg Var _cHrISeg Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx2 Valid LJ3021VldHr(_cHrISeg,_lChkBx2) PIXEL OF oTFolder:aDialogs[2]
@ C(013),C(085) Say STR0011 Size C(010),C(008) COLOR CLR_BLACK                                                   PIXEL OF oPanelAba02_01 //"Até"
@ C(013),C(095) MsGet oHrFSeg Var _cHrFSeg Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx2 Valid LJ3021VldHr(_cHrFSeg,_lChkBx2) PIXEL OF oTFolder:aDialogs[2]

@ C(024),C(010) CheckBox oChkBx3 Var _lChkBx3 Prompt STR0013 Size C(030),C(008) Valid(VldDia())               PIXEL OF oTFolder:aDialogs[2] //"Terça"
@ C(024),C(045) Say STR0010 Size C(013),C(008) COLOR CLR_BLACK                                                  PIXEL OF oPanelAba02_01 //"Hora"
@ C(024),C(060) MsGet oHrITer Var _cHrITer Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx3 Valid LJ3021VldHr(_cHrITer,_lChkBx3) PIXEL OF oTFolder:aDialogs[2]
@ C(024),C(085) Say STR0011 Size C(010),C(008) COLOR CLR_BLACK                                                   PIXEL OF oPanelAba02_01 //"Até"
@ C(024),C(095) MsGet oHrFTer Var _cHrFTer Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx3 Valid LJ3021VldHr(_cHrFTer,_lChkBx3) PIXEL OF oTFolder:aDialogs[2]

@ C(035),C(010) CheckBox oChkBx4 Var _lChkBx4 Prompt STR0014 Size C(028),C(008) Valid(VldDia())              PIXEL OF oTFolder:aDialogs[2] //"Quarta"
@ C(035),C(045) Say STR0010 Size C(013),C(008) COLOR CLR_BLACK                                                  PIXEL OF oPanelAba02_01 //"Hora"
@ C(035),C(060) MsGet oHrIQua Var _cHrIQua Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx4 Valid LJ3021VldHr(_cHrIQua,_lChkBx4) PIXEL OF oTFolder:aDialogs[2]
@ C(035),C(085) Say STR0011 Size C(010),C(008) COLOR CLR_BLACK                                                   PIXEL OF oPanelAba02_01 //"Até"
@ C(035),C(095) MsGet oHrFQua Var _cHrFQua Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx4 Valid LJ3021VldHr(_cHrFQua,_lChkBx4) PIXEL OF oTFolder:aDialogs[2]

@ C(046),C(010) CheckBox oChkBx5 Var _lChkBx5 Prompt STR0015 Size C(028),C(008) Valid(VldDia())              PIXEL OF oTFolder:aDialogs[2] //"Quinta"
@ C(046),C(045) Say STR0010 Size C(013),C(008) COLOR CLR_BLACK                                                  PIXEL OF oPanelAba02_01 //"Hora"
@ C(046),C(060) MsGet oHrIQui Var _cHrIQui Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx5 Valid LJ3021VldHr(_cHrIQui,_lChkBx5) PIXEL OF oTFolder:aDialogs[2]
@ C(046),C(085) Say STR0011 Size C(010),C(008) COLOR CLR_BLACK                                                   PIXEL OF oPanelAba02_01 //"Até"
@ C(046),C(095) MsGet oHrFQui Var _cHrFQui Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx5 Valid LJ3021VldHr(_cHrFQui,_lChkBx5) PIXEL OF oTFolder:aDialogs[2]

@ C(057),C(010) CheckBox oChkBx6 Var _lChkBx6 Prompt STR0016 Size C(027),C(008) Valid(VldDia())               PIXEL OF oTFolder:aDialogs[2] //"Sexta"
@ C(057),C(045) Say STR0010 Size C(013),C(008) COLOR CLR_BLACK                                                  PIXEL OF oPanelAba02_01 //"Hora"
@ C(057),C(060) MsGet oHrISex Var _cHrISex Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx6 Valid LJ3021VldHr(_cHrISex,_lChkBx6) PIXEL OF oTFolder:aDialogs[2]
@ C(057),C(085) Say STR0011 Size C(010),C(008) COLOR CLR_BLACK                                                   PIXEL OF oPanelAba02_01 //"Até"
@ C(057),C(095) MsGet oHrFSex Var _cHrFSex Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx6 Valid LJ3021VldHr(_cHrFSex,_lChkBx6) PIXEL OF oTFolder:aDialogs[2]

@ C(068),C(010) CheckBox oChkBx7 Var _lChkBx7 Prompt STR0017 Size C(032),C(008) Valid(VldDia())              PIXEL OF oTFolder:aDialogs[2] //"Sabado"
@ C(068),C(045) Say STR0010 Size C(013),C(008) COLOR CLR_BLACK                                                  PIXEL OF oPanelAba02_01 //"Hora"
@ C(068),C(060) MsGet oHrISab Var _cHrISab Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx7 Valid LJ3021VldHr(_cHrISab,_lChkBx7) PIXEL OF oTFolder:aDialogs[2]
@ C(068),C(085) Say STR0011 Size C(010),C(008) COLOR CLR_BLACK                                                   PIXEL OF oPanelAba02_01 //"Até"
@ C(068),C(095) MsGet oHrFSab Var _cHrFSab Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99:99" When _lChkBx7 Valid LJ3021VldHr(_cHrFSab,_lChkBx7) PIXEL OF oTFolder:aDialogs[2]

//+----------------------------------------------------------------------------
//| ABA NUMERO 3 (EMPRESA/FILIAL)
//+----------------------------------------------------------------------------
//	LJ3021LstFil(oTFolder:aDialogs[3])    /// Monta  grid -Empresa/Filial

_aAreaSM0 := SM0->( GetArea() )
aNoFields   := { "MB3_CODREG" , "MB3_CODEMP" }
aAlterMB3	:= { "MB3_TIPO" , "MB3_CODGRU", "MB3_CODFIL" }
_lExist   	:= .F. 
_lTodFil  	:= .T.

dbSelectArea("MB3")
dbSetOrder(1) //MB3_FILIAL+MB3_CODREG

// Carrega informacao cadastrada
If Inclui
	FillGetDados(nOpc,"MB3",1,,,,aNoFields,,,,{||.T.},.T.,aHeadMB3)
Else
	_cQry := "SELECT * FROM " + RetSqlName("MB3")
	_cQry += " WHERE MB3_FILIAL = '" + xFilial("MB3") + "'"
	_cQry += "   AND MB3_CODREG = '" + M->MEI_CODREG + "'"
	_cQry += "   AND D_E_L_E_T_ = ' ' ORDER BY  MB3_CODREG, MB3_CODGRU, MB3_CODEMP, MB3_CODFIL"

	cSeek := xFilial("MB3")+M->MEI_CODREG
	cWhile:= "MB3->MB3_FILIAL +MB3->MB3_CODREG"         
	FillGetDados(nOpc ,"MB3" ,1   ,cSeek,{|| &(cWhile)},{|| .T. } ,aNoFields,;
			/*aYesFields*/,/*lOnlyYes*/,_cQry ,/*bMontaCols*/,INCLUI,aHeadMB3,@aColsMB3,, /*bBeforeCols*/,/*bAfterHeader*/, /*cAliasQry*/)
Endif

oGetDFilial := MsNewGetDados():New(0,0,0,0,nOpcGetD,"Lj3021LiLok()", "AllwaysTrue","",;
				aAlterMB3,,,"AllwaysTrue","","AllwaysTrue",oTFolder:aDialogs[3]/*oPanel_EmpFil*/,@aHeadMB3,@aColsMB3)
oGetDFilial:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//+----------------------------------------------------------------------------
//| ABA NUMERO 4 (RANGE DE VALORES)  - Tabela MB2  - oTFolder:aDialogs[4]
//+----------------------------------------------------------------------------
LJ3021DdVlr(M->MEI_CODREG)

//+----------------------------------------------------------------------------
//| Cria FOLDER - Inferior -
//+----------------------------------------------------------------------------

oPanFolder:= TPanel():New(aPosObj[2,1] ,aPosObj[2,2] ,,oDlg,,,,,,aPosObj[2,4] ,aPosObj[2,3]-aPosObj[2,1] ,.F.,.F.)

aTFolder1 := { STR0018, STR0019 } //'Item'###'Negociação'
oTFolderInf := TFolder():New( 0,0,aTFolder1,,oPanFolder,,,,.T.,,0,0 )
oTFolderInfr:Align := CONTROL_ALIGN_ALLCLIENT
oTFolderInf:bSetOption := {|| LJ3021MdFolder(oTFolderInf:nOption),oTFolderInf:Refresh() }  ///  faz validaçao na mudança de ABA..

//+----------------------------------------------------------------------------
//| ABA NUMERO 01 - FOLDER INFERIOR (ITENS) - CATERORIZACAO DE PRODUTOS REGRA DE DESCONTO
//+----------------------------------------------------------------------------

LJ3021CategProd(M->MEI_CODREG)

//+-----------------------------------------------------------------------------------------------
//| ABA NUMERO 02 - FOLDER INFERIOR ('Negociação') - CATERORIZACAO DE PRODUTOS - REGRA DE DESCONTO
//+-----------------------------------------------------------------------------------------------
oPanel_Negoc:= TScrollBox():New(oTFolderInf:aDialogs[2],01,01,440,145,.T.,.T.,.T.)
oPanel_Negoc:Align := CONTROL_ALIGN_ALLCLIENT

@ C(002),C(002) TO C(060),C(165) LABEL STR0020    PIXEL OF oPanel_Negoc //"Formas de Pagamento"
@ C(060),C(002) TO C(120),C(165) LABEL STR0021    PIXEL OF oPanel_Negoc //"Condição de Pagamento"
@ C(002),C(168) TO C(060),C(348) LABEL STR0022    PIXEL OF oPanel_Negoc //"Administradoras Financeiras"

LJ3021Formpg(oPanel_Negoc)   	/// monta o grid de forma de pagamento  (folder inferior - ABA 03)
LJ3021LstCPg(oPanel_Negoc)    	/// monta o grid de Condicao de Pagamento do Folder (negociaçoes)
LJ3021LstAdm(oPanel_Negoc)		/// monta grid com as administradoras de cartão.

@ C(071),C(172) CheckBox oChkBx1 Var lChkPropor Prompt STR0023 Size C(033),C(008) Valid(VldDia()) PIXEL OF oPanel_Negoc //"Proporcional"

AADD( aButtons, {STR0024, {|| LJ3023Tree(1)}, STR0025,STR0026,{|| .T.}} )   /// adicionar botao (PRODUTO) a EnchoiceBAR para abrir arvore. //"PRODUTO"###"Produtos..."###"Produtos"
AADD( aButtons, {STR0024, {|| LJ3023Tree(2)}, STR0027,STR0028,{|| .T.}} )   /// adicionar botao (ARVORE)  a EnchoiceBAR para abrir arvore. //"PRODUTO"###"Categoria..."###"Categoria"
LJ3021MdFolder()  /// Valida se por ITEM : desabilita a forma de pagamento e Habilita os itens e categorias.

// Monta array produtos Vinculados
MontaProdRef( { { oGetD:aCols , oGetD:aHeader } , { oGetDdVlr:aCols , oGetDdVlr:aHeader } } )   

If lAutomato
	nOpcA := 1 // Nao ativa o objeto, que é somente quando possui tela
Else
	oDlg:Activate(,,,,,, {|| EnchoiceBar( oDlg, {||nOpcA := 1 , IIF (LJ3021ValCad(nOpc) ,oDlg:End(),)} ,  {||nOpcA := 0,oDlg:End()} ,.F.,@aButtons,,) } )
EndIf

// -- Rotina de Gravacao das tabelas
If nOpcA == 1 .AND. nOpc > 2

	Begin Transaction
		GravaRegra(INCLUI)     //--  GRAVA REGRA DE DESCONTO.
		LOJA3022(M->MEI_CODREG,_aLstBxFrm,_aLstBxCPg,_aLstBxAdm)
		
		While (GetSx8Len() > nSaveSx8 )
			ConfirmSx8()
		EndDo
		EvalTrigger()
	End Transaction
EndIf

// -- Restaura a entrada da Rotina
While (GetSx8Len() > nSaveSx8 )
	RollBackSxE()
EndDo

MsUnLockAll()
FreeUsedCode()
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GravaRegraºAutor  ³                    º Data ³  04/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para gravar (excluir) a rega de desconto.			  º±±
±±º          ³ conto, zera a hora inicial e final desse dia.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloa                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravaRegra(INCLUI) 

Local aArea	:= GetArea()				// Posicionamento atual da tabela 
Local _nI 		:= 0						// Variavel de controle
Local nX		:= 0						// Contador
Local nP		:= 0						// Contador

/// grava range.
Local _aColsVlr:= oGetDdVlr:aCols                                                	// Array valores
Local _nPVRef  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_REFGRD"})	// Ref grade
Local _nPVLrI  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRINI"})	// Valor Inicial
Local _nPVlrF  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFIM"})	// Valor Final
Local _nPPDes  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_PDESC" })	// Pesc. Desconto 
Local _nPVlFx  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFX" })	// Valor Desconto
Local _nPTipo  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_TPREGR" })  	// Tipo de regra
Local _nPPgto  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_PGTO" })   	// Considera a forma de pagamento 
Local _cIDPrd  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_IDPROD" })   	// ID Produto Relação
Local aHeadMGB		:= {}

//// -- Grava itens (produtos e Categoria)
Local nPRefgrd  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_REFGRD"})			// Ref Grade			
Local nPCodPro	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CODPRO"})			// Produto
Local nPCatego  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CATEGO"})			// Categoria
Local nPDescpr  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_DESCPR"})			// Perc. Desconto 
Local nPDescvl  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_DESCVL"})			// Valor Desconto
Local nPGrupo  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_GRUPO"})			// Grupo do produto
Local nPTipo	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_TPREGR"})  	 	// Tipo da Regra (se desconto/Brinde/Bonificacao)
Local nPQtde	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_QTDPRO"})  	 	// Quantidade de produtos
Local nPIDProd  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_IDPROD"})			// ID do produto 
Local nPQtdMul	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_QTDMUL"})  	 	// Multiplo de Quantidade 
Local nDescTo	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_DESCTO"})  	 	// Desconto no Total  
Local nSeq		:= 1				  				// Contador sequencial
Local oPainel	:= Nil				  				// Objeto Painel
Local lPainel	:= .F.				  				// Se há painel
Local cLote		:= ""				  				// Lote
Local lGrava	:= .T.								// Variavel lógica de controle para validações específica quando a regra for igual a Desconto  

Local cREFGRD			:= StrZero(0,TamSx3("MB8_REFGRD")[1],0)
Local aCamposUsr		:= {} //Campos do Usuário
Local nI				:= 0
Local aAreaSX3			:= SX3->(GetArea())
Local aCamposMB8		:= {} //Campos do Usuário MB8
Local nPosMB8			:= 0 //Posicao do campo MB8
Local cTabela			:= "" //Alias da Tabela
 
Default INCLUI		:= .F.								// Variavel Logica Inclui	
// Criar aHeader da tela auxiliar de produtos vinculados
CriaHeader(aHeadMGB , Nil ,"MGB", {"MGB_HREXP"})

If INCLUI .or. ALTERA
	SX3->(DbSetOrder(1))
	
	cTabela := "MEI"
	SX3->(Dbseek(cTabela))
	
	While SX3->(!EoF()) .And. SX3->X3_ARQUIVO == cTabela
	
		If SX3->X3_PROPRI == "U" .And. X3USO(SX3->X3_USADO) .AND. cNivel>= SX3->X3_NIVEL
			aAdd(aCamposUsr, { AllTrim(SX3->X3_CAMPO), "M->"+AllTrim(SX3->X3_CAMPO)})
		EndIf
		SX3->(DbSkip())
	
	End
	
	cTabela := "MB8"
	SX3->(Dbseek(cTabela))
	
	While SX3->(!EoF()) .And. SX3->X3_ARQUIVO == cTabela
	
		If SX3->X3_PROPRI == "U" .And. X3USO(SX3->X3_USADO) .AND. cNivel>= SX3->X3_NIVEL
			aAdd(aCamposMB8, { AllTrim(SX3->X3_CAMPO), "M->"+AllTrim(SX3->X3_CAMPO)})
		EndIf
		SX3->(DbSkip())
	
	End
	
	RestArea(aAreaSX3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da enchoice ABA 01 - ( CADASTRO )                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If INCLUI
		RecLock("MEI",.T.) 
		M->MEI_FILIAL := xFilial("MEI") 
	Elseif ALTERA
		RecLock("MEI",.F.)
	Endif
	
	MEI->MEI_FILIAL		:= M->MEI_FILIAL
	MEI->MEI_CODREG		:= M->MEI_CODREG
	MEI->MEI_DESCRI		:= M->MEI_DESCRI
	MEI->MEI_CODCLI		:= M->MEI_CODCLI
	MEI->MEI_LOJA		:= M->MEI_LOJA
	MEI->MEI_CODTAB		:= M->MEI_CODTAB
	MEI->MEI_CONDPG		:= M->MEI_CONDPG
	MEI->MEI_FORMPG		:= M->MEI_FORMPG
	MEI->MEI_FAIXA		:= M->MEI_FAIXA
	MEI->MEI_MOEDA		:= M->MEI_MOEDA
	MEI->MEI_PERDES		:= M->MEI_PERDES
	MEI->MEI_CFAIXA		:= M->MEI_CFAIXA
	MEI->MEI_TPHORA		:= M->MEI_TPHORA
	MEI->MEI_HORADE		:= M->MEI_HORADE
	MEI->MEI_HORATE		:= M->MEI_HORATE
	MEI->MEI_DATDE		:= M->MEI_DATDE
	MEI->MEI_DATATE		:= M->MEI_DATATE
	MEI->MEI_GRPVEN		:= M->MEI_GRPVEN
	MEI->MEI_TPIMPD		:= M->MEI_TPIMPD
	MEI->MEI_DESFUN		:= M->MEI_DESFUN
	MEI->MEI_PRDMOS		:= M->MEI_PRDMOS
	MEI->MEI_PRDSLD		:= M->MEI_PRDSLD
	MEI->MEI_ACUMUL		:= M->MEI_ACUMUL
	MEI->MEI_ATIVA		:= M->MEI_ATIVA    //  1-REGRA ATIVA    E 2-REGRA NAO ATIVA		
	
	//Grava os campos do Usuário
	For nI := 1 to Len(aCamposUsr)
		MEI->(FieldPut( ColumnPos(aCamposUsr[nI, 01]) , &(aCamposUsr[nI, 02])))
	Next nI
		
	MsUnLock()                                                             

	// Inclui no painel de gestão se parametro estiver habilitado, fonte Loja303
	If ExistFunc("LJ302JOB")
		IF INCLUI 
			lPainel:=SuperGetMV("MV_LJGEPRE",.F.,.F.)`   // Passou "MV_LJGEPRE"
			IF lPainel
				oPainel	:=PainelPrecificacao():New()
				oPainel:Lj3PacRDes(M->MEI_DATDE,M->MEI_DATATE,M->MEI_FILIAL,M->MEI_CODREG)
				cLote := oPainel:cNroLote
				// inclui registro no MBA, porem é necessário ter o relacionamento na MBC através da funcao:: Loja077
			Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ABA 02 - Dias da Semana                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("MB7")
	dbSetOrder(1)	// MB7_FILIAL+MB7_CODREG
	If INCLUI
		RecLock("MB7",.T.)
	Else //If ALTERA
		dbSeek( xFilial("MB7") + M->MEI_CODREG )
		RecLock("MB7",.F.)
	EndIf

	MB7->MB7_FILIAL := M->MEI_FILIAL
	MB7->MB7_CODREG	:= M->MEI_CODREG
	
	MB7->MB7_HRDOMI	:= M->_cHrIDom
	MB7->MB7_HRDOMF	:= M->_cHrFDom
	
	MB7->MB7_HRSEGI	:= M->_cHrISeg
	MB7->MB7_HRSEGF	:= M->_cHrFSeg
	
	MB7->MB7_HRTERI	:= M->_cHrITer
	MB7->MB7_HRTERF	:= M->_cHrFTer
	
	MB7->MB7_HRQUAI	:= M->_cHrIQua
	MB7->MB7_HRQUAF	:= M->_cHrFQua
	
	MB7->MB7_HRQUII	:= M->_cHrIQui
	MB7->MB7_HRQUIF	:= M->_cHrFQui
	
	MB7->MB7_HRSEXI	:= M->_cHrISex
	MB7->MB7_HRSEXF	:= M->_cHrFSex
	
	MB7->MB7_HRSABI	:= M->_cHrISab
	MB7->MB7_HRSABF	:= M->_cHrFSab

	MsUnLock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava empresa/Filial                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	
	dbSelectArea("MB3")
	dbSetOrder(1)	//MB3_FILIAL + MB3_CODREG
	If MB3->( dbSeek( xFilial("MB3") +M->MEI_CODREG ) )
		While !MB3->( Eof() ) .And. MB3->MB3_FILIAL + MB3->MB3_CODREG == xFilial("MB3") + M->MEI_CODREG
			RecLock("MB3",.F.)
			MB3->( dbDelete() )
			MB3->( MsUnLock() )			
			MB3->( dbSkip() )
		End
	EndIf


	For _nI := 1 To Len(oGetDFilial:aCols)
	
		IF !oGetDFilial:aCols[_nI][Len(oGetDFilial:aHeader)+1]

			RecLock("MB3",.T.)
			MB3->MB3_FILIAL := xFilial("MB3")
			MB3->MB3_CODREG	:= M->MEI_CODREG 
			MB3->MB3_CODEMP	:= SubStr(cNumEmp,1,2)

			For nX := 1 To Len(oGetDFilial:aHeader)				
				IF MB3->( FieldPos(oGetDFilial:aHeader[nX,2]) ) <> 0
					MB3->( FieldPut( FieldPos(oGetDFilial:aHeader[nX,2]) , oGetDFilial:aCols[_nI,nX] ) )
				Endif				
			Next nX

			MB3->( MsUnLock() )

		Endif  
	
	Next _nI 

	//  Fim da Empresa / Filial
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVA O RANGE DE VALORES                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	dbSelectArea("MB2")
	dbSetOrder(1)	//MB2_FILIAL+MB2_CODREG+MB2_REFGRD
	If MB2->( dbSeek( xFilial("MB2") +M->MEI_CODREG ) )
		While !MB2->( Eof() ) .And. MB2_FILIAL + MB2_CODREG == xFilial("MB2") + M->MEI_CODREG
			
			RecLock("MB2",.F.)
			
			MB2->( dbDelete() )
			MB2->( MsUnLock() )
			
			// Deleta os produtos vinculados a esse range de valor
			MGB->( DbSetOrder(1) ) //MGB_FILIAL+MGB_CODREG+MGB_IDPROD
			IF MGB->( DbSeek( xFilial("MGB") + M->MEI_CODREG + MB2->MB2_REFGRD + "MB2" ) )
				While MGB->( !Eof() ) .And. Alltrim(MGB->MGB_FILIAL+MGB->MGB_CODREG+MGB->MGB_IDPROD) == Alltrim(xFilial("MGB") + M->MEI_CODREG + MB2->MB2_REFGRD + "MB2")
					RecLock("MGB",.F.)
					MGB->( dbDelete() )
					MGB->( MsUnLock() )				
					MGB->( DbSkip() )				
				End 			
			Endif 
						
			MB2->( dbSkip() )
			
		End
	EndIf
	
	If M->MEI_TPIMPD == 'T'
		For _nI := 1 to Len(_aColsVlr)
			
			If !_aColsVlr[_nI][Len(_aColsVlr[_nI])] 
			
		       If _aColsVlr[_nI][_nPTipo] == "1" //Desconto
		       	If  (_aColsVlr[_nI][_nPVlrF] > 0 .And. _aColsVlr[_nI][_nPPDes] > 0) .Or. (_aColsVlr[_nI][_nPVlrF] > 0 .And. _aColsVlr[_nI][_nPVlFx] > 0)
		       		lGrava := .T.
					Else
		       	 	lGrava := .F.
		       	Endif   
		       Endif
			       
				IF lGrava .And. _aColsVlr[_nI][LEN(_aColsVlr[_nI])] == .F.		//Registro não deletado
				
					RecLock("MB2",.T.)
				
					MB2->MB2_FILIAL := xFilial("MB2")
					MB2->MB2_CODREG := M->MEI_CODREG     
					MB2->MB2_REFGRD := _aColsVlr[_nI][_nPVRef]
					MB2->MB2_VLRINI := _aColsVlr[_nI][_nPVLrI]
					MB2->MB2_VLRFIM := _aColsVlr[_nI][_nPVlrF]
					MB2->MB2_PDESC  := _aColsVlr[_nI][_nPPDes]
					MB2->MB2_VLRFX  := _aColsVlr[_nI][_nPVlFx]
					MB2->MB2_TPREGR := _aColsVlr[_nI][_nPTipo]
					MB2->MB2_PGTO   := _aColsVlr[_nI][_nPPgto]
					MB2->MB2_IDPROD   := _aColsVlr[_nI][_cIDPrd]					
					MB2->( MsUnLock() )
	
					// Carrega todos os produtos vinculados a este range de valor informado
					aAuxMB2 := LeProdRef( "MB2" , _aColsVlr[_nI][_nPVRef] + "MB2" )
						
					IF Len(aAuxMB2) > 0
						
						For nP := 1 To Len(aAuxMB2)
	
							If !Atail(aAuxMB2[nP])//Inclusao ou Alteracao
								DBSelectArea("MGB")
								RecLock("MGB",.T.)
						
								MGB->MGB_FILIAL	:= xFilial("MGB")
								MGB->MGB_CODREG	:= M->MEI_CODREG 
								MGB->MGB_IDPROD	:= _aColsVlr[_nI][_nPVRef] + "MB2"
				
								For nX := 1 To Len(aHeadMGB)				
									If MGB->( FieldPos(aHeadMGB[nX,2]) ) <> 0
										MGB->( FieldPut( FieldPos(aHeadMGB[nX,2]) , aAuxMB2[nP,nX] ) )
									Endif				
								Next nX
										
								MGB->( MsUnLock() )
							Endif
															
						Next nP
													
					Endif			
						
				Endif
	
			EndIf
			
		Next _nI
	EndIf

	//Fim do Range de valores

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava intens de produtos e categorias                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    //// acols[1,1]  , acols[1,2]    , acols[1,3]   , acols[2,1]
	dbSelectArea("MB8")
	dbSetOrder(1)  //MB8_FILIAL + MB8_CODREG	
	
	If MB8->( dbSeek( xFilial("MB8") + M->MEI_CODREG ) )

		While !MB8->( Eof() ) .And.	xFilial("MB8") + M->MEI_CODREG == MB8->MB8_FILIAL + MB8->MB8_CODREG
			
			RecLock("MB8",.F.)
			MB8->( dbDelete() )
			MB8->( MsUnLock() )
			
			// Deleta os produtos vinculados a esse produto/categoria
			MGB->( DbSetOrder(1) ) //MGB_FILIAL+MGB_CODREG+MGB_IDPROD
			IF MGB->( DbSeek( xFilial("MGB") + M->MEI_CODREG + MB8->MB8_REFGRD + "MB8" ) )
				While MGB->( !Eof() ) .And. Alltrim(MGB->MGB_FILIAL+MGB->MGB_CODREG+MGB->MGB_IDPROD) == Alltrim(xFilial("MGB") + M->MEI_CODREG + MB8->MB8_REFGRD + "MB8")
					RecLock("MGB",.F.)
					MGB->( dbDelete() )
					MGB->( MsUnLock() )				
					MGB->( DbSkip() )				
				End 			
			Endif 			
			MB8->( dbSkip() )
		End
	EndIf
	
	If M->MEI_TPIMPD == 'I'  /// GRAVA SE TIPO = (ITEM)
		
		For _nI := 1 to Len(oGetD:Acols)
			
			If oGetD:Acols[_nI][LEN(oGetD:aHeader)+1] == .F.  /// se não for linha deletada     
				
				RecLock("MB8",.T.)
				MB8->MB8_FILIAL := xFilial("MB8")
				MB8->MB8_CODREG := M->MEI_CODREG
				If Empty(oGetD:Acols[_nI][nPRefGrd])		//Inclusão do Grid. Se vazio, adicionar sempre 1 acima do último registro no campo Item
					cREFGRD := SomaIt(cREFGRD)
					MB8->MB8_REFGRD	:= cREFGRD // Codigo do Item (sequencia)
				Else
					MB8->MB8_REFGRD	:= oGetD:Acols[_nI][nPRefGrd]	//Referência de Grade - na alteração, o número do item é mantido. Ex: Eu deletei o item 01 e mantive o item 02, logo o primeiro item da linha continua como 02 PARA NÃO PERDER O RELACIONAMENTO COM O MGB
					cREFGRD := oGetD:Acols[_nI][nPRefGrd]			//Manter o cREFGRD, para se o próximo registro for VAZIO, atribuir o SomaIt acima se Empty(oGetD:Acols[_nI][nPRefGrd])
				EndIf
				MB8->MB8_CODPRO	:= oGetD:Acols[_nI][nPCodPro]	/// Codigo do produto
				MB8->MB8_CATEGO := oGetD:Acols[_nI][nPCatego]	/// Categoria de produtos.
				MB8->MB8_DESCPR	:= oGetD:Acols[_nI][nPDescpr]	/// Percentual de Desconto
				MB8->MB8_DESCVL := oGetD:Acols[_nI][nPDescvl]	/// Valor de desconto				
				MB8->MB8_GRUPO := oGetD:Acols[_nI][nPGrupo]	/// Grupo do Produto				
				MB8->MB8_TPREGR	:= oGetD:Acols[_nI][nPTipo]    /// Tipo de regra(desconto/bonificacao/brinde)
				MB8->MB8_QTDPRO := oGetD:Acols[_nI][nPQtde]    /// Quantidade de produtos a serem vendidos para receber a promocao				
				MB8->MB8_IDPROD := oGetD:Acols[_nI][nPIDProd]    /// ID do Produto				
				MB8->MB8_QTDMUL := oGetD:Acols[_nI][nPQtdMul]  /// Multiplo de Quantidade ou seja a cada compra de mesma quantidade se consedera a promocao
				If nDescTo > 0
					MB8->MB8_DESCTO := oGetD:Acols[_nI][nDescTo]   /// Desconto no Total
				EndIf
				
				//Grava os campos do Usuário
				For nI := 1 to Len(aCamposMB8)
					If (nPosMB8	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])== aCamposMB8[nI, 01]})  )  > 0 .AND.;
					   !(aCamposMB8[nI, 01] $ "MB8_FILIAL|MB8_CODREG|MB8_REFGRD|MB8_CODPRO|MB8_CATEGO|MB8_DESCPR|MB8_DESCVL|MB8_TPREGR|MB8_QTDPRO|MB8_QTDMUL|MB8_DESCTO") 
						MB8->(FieldPut( FieldPos(aCamposMB8[nI, 01]) ,  oGetD:Acols[_nI][nPosMB8] ) )
					EndIf
				
				Next nI
				
				
				MB8->( MsUnLock() )
						
				// Carrega todos os produtos vinculados aos produtos/categoria
				aAuxMB8 := LeProdRef( "MB8" , oGetD:Acols[_nI][nPRefgrd] + "MB8" )
				
				If Len(aAuxMB8) > 0
				
					For nP := 1 To Len(aAuxMB8)

						If !Atail(aAuxMB8[nP])//Inclusao ou Alteracao, não deletados no grid
							DBSelectArea("MGB") 
							RecLock("MGB",.T.)
	
							MGB->MGB_FILIAL	:= xFilial("MGB")
							MGB->MGB_CODREG	:= M->MEI_CODREG
							MGB->MGB_IDPROD	:= oGetD:Acols[_nI][nPRefgrd] + "MB8" 
		
							For nX := 1 To Len(aHeadMGB)				
								If MGB->( FieldPos(aHeadMGB[nX,2]) ) <> 0
									MGB->( FieldPut( FieldPos(aHeadMGB[nX,2]) , aAuxMB8[nP,nX] ) )
								Endif				
							Next nX
								
							MGB->( MsUnLock() )
						Endif
					Next nP
											
				Endif			
				
			Endif
			
		Next _nI
		
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FINAL Grava intens de produtos e categorias                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava a prioridade da regra                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	
	M->MEJ_FILIAL := xFilial("MEJ") 

	If INCLUI
		// Se for inclusão grava todos os dados da tabela
		dbSelectArea("MEJ")
		dbSetOrder(1) 				//MEJ_FILIAL+MEJ_PRINUM+MEJ_CODREG
		MEJ->(dbGoBottom())
		// Ordenado por número da Prioridade
		// Incrementa 1 no valor da última Prioridade
		nSeq := val(MEJ->MEJ_PRINUM) + 1

		RecLock("MEJ",.T.)
		MEJ->MEJ_FILIAL  	:=  M->MEI_FILIAL
		MEJ->MEJ_CODREG  	:=  M->MEI_CODREG
		MEJ->MEJ_PRINUM  	:=  StrZero(nSeq,2)
		MEJ->MEJ_DATEDE  	:=  M->MEI_DATDE
		MEJ->MEJ_DATATE  	:=  M->MEI_DATATE
		MEJ->MEJ_ACUMUL  	:=  M->MEI_ACUMUL
	Else
		// Grava somente os dados que podem ser alterados
		// Desta forma, quando alterar qualquer dado da Regra, a Prioridade continuará a mesma
		dbSelectArea("MEJ")
		dbSetOrder(2)				//MEJ_FILIAL + MEJ_CODREG
		If MEJ->( dbSeek( xFilial("MEJ") + M->MEI_CODREG ) )
			RecLock("MEJ",.F.)
			MEJ->MEJ_DATEDE  	:=  M->MEI_DATDE
			MEJ->MEJ_DATATE  	:=  M->MEI_DATATE
			MEJ->MEJ_ACUMUL  	:=  M->MEI_ACUMUL
		EndIf	
	EndIf	
	
	MEJ->( MsUnLock() )
	
EndIf

// Exclui Regra de desconto
If ExistFunc("LJ3022EXRG") //Funcao utilizada no Venda Assistida (CRDXFUNE.PRW)
	If DELETA
		Begin Sequence
		Begin Transaction
		LJ3022EXRG(M->MEI_CODREG)    /// funçao para excluir regra , fonte LJ3022
		_lRet := .T.
		End Transaction
		End Sequence
		MEI->( dbGoTop() )
	Endif
EndIf

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldDia   ºAutor  ³Alessandro Santos   º Data ³  26/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verificacao se Dia da semana foi excluido da regra de des- º±±
±±º          ³ conto, zera a hora inicial e final desse dia.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Tellerina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldDia()

//Zera hora inicial e final dos dias da semana excluidos

//Domingo
If !_lChkBx1
	_cHrIDom := Space(05)
	_cHrFDom := Space(05)
EndIf

//Segunda
If !_lChkBx2
	_cHrISeg := Space(05)
	_cHrFSeg := Space(05)
EndIf

//Terca
If !_lChkBx3
	_cHrITer := Space(05)
	_cHrFTer := Space(05)
EndIf

//Quarta
If !_lChkBx4
	_cHrIQua := Space(05)
	_cHrFQua := Space(05)
EndIf

//Quinta
If !_lChkBx5
	_cHrIQui := Space(05)
	_cHrFQui := Space(05)
EndIf

//Sexta
If !_lChkBx6
	_cHrISex := Space(05)
	_cHrFSex := Space(05)
EndIf

//Sabado
If !_lChkBx7
	_cHrISab := Space(05)
	_cHrFSab := Space(05)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ3021VldHr ºAutor  ³Microsiga           º Data ³  03/28/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LJ3021VldHr                                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ3021VldHr(_cHora,_lOpc)

Local _lRet := .T. 			// Retorno

Default _cHora := ""        // _cHora
Default _lOpc  := .T.       // _lOpc

If (_cHora < "00:00" .Or. _cHora > "23:59") .And. !Empty(_cHora)
	MsgInfo(STR0029) //"Horário inválido"
	_lRet := .F.
ElseIf SubStr(_cHora,1,2) > "23" .Or. Empty(SubStr(_cHora,1,2))		//Validacao da Hora
	MsgInfo(STR0029) //"Horário inválido"
	_lRet := .F.
ElseIf SubStr(_cHora,4,2) > "59" .Or. Empty(SubStr(_cHora,4,2))		//Validacao do Minuto
	MsgInfo(STR0029) //"Horário inválido"
	_lRet := .F.
ElseIf SubStr(_cHora,3,1) <> ":"										//Validacao do :
	MsgInfo(STR0029) //"Horário inválido"
	_lRet := .F.
EndIf                      

Return _lRet


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupera registros para CONSULTAR e ALTERAR             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function RecuperaReg(cCodreg)  //  recupera registros na consulta e alteraçao

dbSelectArea("MB7")
dbSetOrder(1) //MB7_FILIAL+MB7_CODREG
dbSeek( xFilial("MB7") + cCodreg )

_lChkBx1  := (!Empty(MB7->MB7_HRDOMI) .And. !Empty(MB7->MB7_HRDOMF) )	//Domingo
_lChkBx2  := (!Empty(MB7->MB7_HRSEGI) .And. !Empty(MB7->MB7_HRSEGF) )	//Segunda
_lChkBx3  := (!Empty(MB7->MB7_HRTERI) .And. !Empty(MB7->MB7_HRTERF) )	//Terça
_lChkBx4  := (!Empty(MB7->MB7_HRQUAI) .And. !Empty(MB7->MB7_HRQUAF) )	//Quarta
_lChkBx5  := (!Empty(MB7->MB7_HRQUII) .And. !Empty(MB7->MB7_HRQUIF) )	//Quinta
_lChkBx6  := (!Empty(MB7->MB7_HRSEXI) .And. !Empty(MB7->MB7_HRSEXF) )	//Sexta
_lChkBx7  := (!Empty(MB7->MB7_HRSABI) .And. !Empty(MB7->MB7_HRSABF) )	//Sabado

_cHrIDom := Padr(IIf (_lChkBx1, MB7->MB7_HRDOMI,""),5)
_cHrFDom := Padr(IIf (_lChkBx1, MB7->MB7_HRDOMF,""),5)

_cHrISeg := Padr(IIf (_lChkBx2, MB7->MB7_HRSEGI,""),5)
_cHrFSeg := Padr(IIf (_lChkBx2, MB7->MB7_HRSEGF,""),5)

_cHrITer := Padr(IIf (_lChkBx3, MB7->MB7_HRTERI,""),5)
_cHrFTer := Padr(IIf (_lChkBx3, MB7->MB7_HRTERF,""),5)

_cHrIQua := Padr(IIf (_lChkBx4, MB7->MB7_HRQUAI,""),5)
_cHrFQua := Padr(IIf (_lChkBx4, MB7->MB7_HRQUAF,""),5)

_cHrIQui := Padr(IIf (_lChkBx5, MB7->MB7_HRQUII,""),5)
_cHrFQui := Padr(IIf (_lChkBx5, MB7->MB7_HRQUIF,""),5)

_cHrISex := Padr(IIf (_lChkBx6, MB7->MB7_HRSEXI,""),5)
_cHrFSex := Padr(IIf (_lChkBx6, MB7->MB7_HRSEXF,""),5)

_cHrISab := Padr(IIf (_lChkBx7, MB7->MB7_HRSABI,""),5)
_cHrFSab := Padr(IIf (_lChkBx7, MB7->MB7_HRSABF,""),5)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   |LJ3021LstFrm³ Autor ³					   ³ Data ³ 01/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da ListBox  de Forma de Pagamento do Folder Forma   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ3021Formpg(oObj)

Local _aAreaSX5 := SX5->( GetArea() )			// Array Guardar area
Local _lExist   := .F.                         	// lExist
Local _lTodFrm  := .T.                        	// lTodFrm

Default oObj 	:= Nil 							// Objeto	

@ C(012),C(003) ListBox oLstBxFrm Fields HEADER "",STR0030,STR0031 Size C(161),C(045) Of oObj Pixel; //"Forma"###"Descricaoo"
ColSizes 50,50 On DBLCLICK ( _aLstBxFrm[oLstBxFrm:nAt,1] := !(_aLstBxFrm[oLstBxFrm:nAt,1]), Lj3021VldFrm(),oLstBxFrm:Refresh() )
oLstBxFrm:SetArray(_aLstBxFrm)

dbSelectArea("SX5")
dbSetOrder(1)	//X5_FILIAL+X5_TABELA+X5_CHAVE

dbSelectArea("MB4")
dbSetOrder(1)	//MB4_FILIAL+MB4_CODREG+MB4_CODFRM

If SX5->( dbSeek( xFilial("SX5") + "24" ) )
	While !SX5->( Eof() ) .And. SX5->X5_FILIAL + SX5->X5_TABELA == xFilial("SX5") + "24"
		_lExist   := .F.
		If !INCLUI
			If MB4->( dbSeek( xFilial("MB4") + M->MEI_CODREG + SX5->X5_CHAVE) )
				_lExist   := .T.
				If MB4->MB4_PROPOR == "1"
					lChkPropor := .T.
				Endif                      
			EndIf
		EndIf
		If !_lExist
			_lTodFrm := .F.
		EndIf
		aAdd(_aLstBxFrm,{_lExist,SX5->X5_CHAVE,SX5->X5_DESCRI})
		SX5->( dbSkip() )
	End
Else
	aAdd(_aLstBxFrm,{.F.,"",""})
EndIf

_lChkBx12 := _lTodFrm	//Verifica se todas as Formas de Pagamento foram selecionadas

oLstBxFrm:bLine := {|| {If(_aLstBxFrm[oLstBxFrm:nAT,1],oOk,oNo),_aLstBxFrm[oLstBxFrm:nAT,02],_aLstBxFrm[oLstBxFrm:nAT,03]}}

RestArea(_aAreaSX5)    

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   |LJ3021LstCPg³ Autor ³   					   ³ Data ³01/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ ListBox de Condicao de Pagamento do Folder negociacoes       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ3021LstCPg(oObj)

Local aArea		:= GetArea()					// Posicionamento atual da tabela 
Local _lExist		:= .F.    						// Existência da condição
Local _lTodCpg	:= .F.    						// Todas as Condições de Pagamento selecionadas
Local _lCpoFrm	:= MB5->(ColumnPos("MB5_CODFRM")) > 0 	//  Controla se existem o campar par vincular a MB4 e a MB5

Default oObj  := Nil 	// Objeto

//l   , c                                                                   cOL   , LIN
@ C(070),C(003) ListBox oLstBxCPg Fields HEADER "",STR0032,STR0033 Size C(161),C(045) Of oObj Pixel; //"Condicao"###"Descricao"
ColSizes 50,50,50 On DBLCLICK ( _aLstBxCPg[oLstBxCPg:nAt,1] := !(_aLstBxCPg[oLstBxCPg:nAt,1]), oLstBxCPg:Refresh() )
oLstBxCPg:SetArray(_aLstBxCPg)

//Atualiza o List Box da Condicao de Pagamento do Folder Forma/Condicao
dbSelectArea("SE4")
dbSetOrder(1)	//SE4->E4_FILIAL+SE4->E4_CODIGO

dbSelectArea("MB5")
dbSetOrder(1)	//MB5_FILIAL+MB5_CODREG+MB5_CONDPG

_aLstBxCPg := {}

If SE4->( dbSeek( xFilial("SE4") ) )
	While !SE4->( Eof() ) .And. SE4->E4_FILIAL == xFilial("SE4")
		If aScan(_aLstBxFrm,{|x| x[1] == .T. .And. Alltrim(x[2]) == Alltrim(SE4->E4_FORMA)}) <> 0
			_lExist   := .F.
			If !INCLUI
				If MB5->( dbSeek( xFilial("MB5") + M->MEI_CODREG + SE4->E4_CODIGO) )
					_lExist   := .T.
				EndIf
			EndIf
			If !_lExist
				_lTodCpg := .F.
			EndIf
			Aadd(_aLstBxCPg,{_lExist,SE4->E4_CODIGO,SE4->E4_DESCRI,Iif(_lCpoFrm,SE4->E4_FORMA,"")})
		EndIf
		SE4->( dbSkip() )
	End
EndIf

If Len(_aLstBxCPg) == 0
	Aadd(_aLstBxCPg,{.F.,"","","",""})
Else
	_lChkBx13 := _lTodCpg	//Verifica se todas as Condicoes de Pagamento foram selecionadas
EndIf
oLstBxCPg:SetArray(_aLstBxCPg)
oLstBxCPg:bLine := {|| {If(_aLstBxCPg[oLstBxCPg:nAT,1],oOk,oNo),_aLstBxCPg[oLstBxCPg:nAT,02],_aLstBxCPg[oLstBxCPg:nAT,03]}}
oLstBxCPg:Refresh()

RestArea(aArea)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³LJ3021LstAdm  ³ Autor ³                    ³ Data ³ 01/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da ListBox Administradoras Financeiras do Folder    ³±±
±±³           ³ Forma														 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ3021LstAdm(oObj)

Local aArea		:= GetArea()					// Posicionamento atual da tabela 
Local _aAreaSAE	:= SAE->( GetArea() )		// Area para SAE
Local _lExist		:= .F.                 		// Se existe condição
Local _lTodAdm	:= .T.                 		// Verifica se todas as Administradoras Financeiras foram selecionadas

Default oObj  := Nil 	// Objeto

@ C(012),C(170) ListBox oLstBxAdm Fields HEADER "",STR0034,STR0031	Size C(175),C(045) Of oObj  Pixel; //"Codigo"###"Descrição"
ColSizes 50,50 On DBLCLICK ( _aLstBxAdm[oLstBxAdm:nAt,1] := !(_aLstBxAdm[oLstBxAdm:nAt,1]), oLstBxAdm:Refresh() )
oLstBxAdm:SetArray(_aLstBxAdm)

dbSelectArea("SAE")
dbSetOrder(1)	//AE_FILIAL+AE_COD

dbSelectArea("MB6")
dbSetOrder(1)	//MB6_FILIAL+MB6_CODREG+MB6_ADMFIN

If !INCLUI .And. SAE->( dbSeek( xFilial("SAE") ) )
	While !SAE->( Eof() ) .And. SAE->AE_FILIAL == xFilial("SAE")
		_lExist   := .F.
		If !INCLUI
			If MB6->( dbSeek( xFilial("MB6") + M->MEI_CODREG + SAE->AE_COD) )
				_lExist   := .T.
			EndIf
		EndIf
		If !_lExist
			_lTodAdm := .F.
		EndIf

		Aadd(_aLstBxAdm,{_lExist,SAE->AE_COD,SAE->AE_DESC})//SAE
		SAE->( dbSkip() )
	End
EndIf

If Len(_aLstBxAdm) == 0
	Aadd(_aLstBxAdm,{.F.,"",""})
Endif

_lChkBx14 := _lTodAdm	//Verifica se todas as Administradoras Financeiras foram selecionadas

oLstBxAdm:bLine := {|| {If(_aLstBxAdm[oLstBxAdm:nAT,1],oOk,oNo),_aLstBxAdm[oLstBxAdm:nAT,02],_aLstBxAdm[oLstBxAdm:nAT,03]}}

RestArea(_aAreaSAE)
RestArea(aArea)

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³LJ3021DdVlr ³ Autor ³     		      		   ³ Data ³04/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados de Valores do Folder "Range de valores "    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ3021DdVlr(_cCodReg)

Local aArea		:= GetArea()					// Posicionamento atual da tabela 
Local nX			:= 0                // Variavel de Controle
Local aCpoGDa      	:= {"MB2_REFGRD","MB2_TPREGR","MB2_VLRINI","MB2_VLRFIM",;
								"MB2_PDESC","MB2_VLRFX","MB2_IDPROD","MB2_PGTO"}	// Array List
Local aAlter       	:= {"MB2_REFGRD","MB2_TPREGR","MB2_VLRINI","MB2_VLRFIM",;
								"MB2_PDESC","MB2_VLRFX","MB2_IDPROD","MB2_PGTO"}	// Array List
Local nOpc         	:= GD_INSERT+GD_DELETE+GD_UPDATE										// nOpc
Local cLinhaOk     	:=	"LJ3021VALRG"  	// Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk      	:= "LJ3021MdFolder" //"AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local nFreeze      	:= 000              // Campos estaticos na GetDados.
Local nMax         	:= 9999             // Numero maximo de linhas permitidas. Valor padrao 99
Local cSuperApagar 	:= ""               // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cApagaOk     	:= "AllwaysTrue"    // Funcao executada para validar a exclusao de uma linha do aCols
Local aHeadRG    	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aColRG       	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols
Local _cQry         := ""				// Query que realizará os filtros para retorno dos campos na MsNewGetDados
Local cSeek         := ""               // Seek para FillGetDados
Local cWhile        := ""               // While para FillGetDados
Local aNoFields     := {"MB2_CODREG"}   // aNoFields
Local nPRefgrd		:= 0				// posicao do campo MB2_REFGRD no aHeader da GetDados

Default _cCodReg  	:= "" 				// Objeto

If INCLUI
	dbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aCpoGDa)
		If SX3->(DbSeek(aCpoGDa[nX]))
			Aadd(aHeadRG,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		Endif
	Next nX
	
	aAux := {}
	For nX := 1 to Len(aCpoGDa)
		If DbSeek(aCpoGDa[nX])
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aAux,.F.)
	Aadd(aColRg,aAux)
Else                  
	// Para que algum campo nao apareça na tela, sera necessário alimentar o mesmo no Array aNoFields
	_cQry := "SELECT * FROM " + RetSqlName("MB2")
	_cQry += " WHERE MB2_FILIAL = '" + xFilial("MB2") + "'"
	_cQry += "   AND MB2_CODREG = '" + M->MEI_CODREG + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"

	cSeek := xFilial("MB2")+M->MEI_CODREG
	cWhile:= "MB2->MB2_FILIAL + MB2->MB2_CODREG"         
	FillGetDados(nopc ,"MB2" ,1     ,cSeek,{|| &(cWhile)},{|| .T. } ,aNoFields,/*aYesFields*/,/*lOnlyYes*/,_cQry ,/*bMontaCols*/,INCLUI,@aHeadRG,@aColRg,{||LjItemMb2()}, /*bBeforeCols*/,/*bAfterHeader*/, /*cAliasQry*/)

EndIf

oGetDdVlr:= MsNewGetDados():New(0,0,0,0,nOpc,cLinhaOk,cTudoOk,"+MB2_REFGRD",aAlter,nFreeze,nMax,,cSuperApagar,cApagaOk,oTFolder:aDialogs[4],@aHeadRG,@aColRg)
oGetDdVlr:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//procuramos pela posicao do campo MB2_REFGRD no aHeader, pois precisaremos atribuir o valor 01 a ele, na primeira linha do aCols SE INCLUSÃO
nPRefgrd := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_REFGRD"})
If INCLUI .AND. nPRefGrd > 0 .AND. Empty(oGetDdVlr:ACOLS[1][nPRefGrd]) 
	oGetDdVlr:ACOLS[1][nPRefGrd] := "01"
EndIf

RestArea(aArea)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³LJ3021CategProd   ³ Autor ³                    ³ Data ³ 04/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados de Itens/CATEGORIA   						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ3021CategProd(_cCodReg)  
Local aArea      	:= GetArea()        // Posicionamento atual da tabela
Local aNoFields		:= {"MB8_FILIAL","MB8_CODREG"}
Local nOpc         	:= GD_INSERT+GD_DELETE+GD_UPDATE // Opções do FillGetDados
Local cLinhaOk		:=	"LJ3021Lok()"				// Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk		:=  "AllwaysTrue"				// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local nFreeze		:= 000							// Campos estaticos na GetDados.
Local nMax			:= 9999							// Numero maximo de linhas permitidas. Valor padrao 99
Local cSuperApagar	:= ""							// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cApagaOk		:= "AllwaysTrue"				// Funcao executada para validar a exclusao de uma linha do aCols
Local oWnd         	:= oTFolderInf:aDialogs[1]																// Objeto oWnd
Local aHeadRG		:= {}							// Array a ser tratado internamente na MsNewGetDados como aHeader
Local aColRG		:= {}							// Array a ser tratado internamente na MsNewGetDados como aCols
Local _cQry			:= ""							// Query que realizará os filtros para retorno dos campos na MsNewGetDados
Local cSeek			:= ""							// Seek para FillGetDados
Local cWhile		:= ""							// While para FillGetDados
Local lMensagem		:= .T.
Local lRet          := .T.
Local nPVlrF  		:= IIF(ValType(oGetDdVlr) <> "U", aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFIM"}) , 0 )	// Valor Final

Default _cCodReg  	:= "" 							// Código da Regra de Desconto

If ValType(oGetD) <> "U" .And.  Len(oGetD:Acols) > 0 .And. M->MEI_TPIMPD == "T"
	lMensagem := MsgYesno(STR0085 + cCRLF + STR0087 ) //"Alterando o campo tipo de desconto para Total as informações dos itens serão perdidas" ***** 	"Deseja Continuar"
	
EndIf	
If ValType(oGetDdVlr) <> "U" .And.  (Len(oGetDdVlr:aCols) > 0 .And. nPVlrF > 0 .And. oGetDdVlr:aCols[1][nPVlrF] > 0)  .And. M->MEI_TPIMPD == "I"
	lMensagem := MsgYesno(STR0086 + cCRLF + STR0087 ) //"Alterando o campo tipo de desconto para Item as informações dos Range serão perdidas" ***** "Deseja Continuar" 
	
EndIf
	
If !lMensagem
	lRet := .F.
Endif

If lRet
	If INCLUI
		//essa validacao so pode ser realizada quando eh regra de desconto por item, por total nao pode
		If M->MEI_TPIMPD == "I" 
			FillGetDados(nOpc,"MB8",1,,,,aNoFields,,,,{||.T.},.T.,@aHeadRG,@aColRg)	
		EndIf
	
	Else
	
		_cQry := "SELECT * FROM " + RetSqlName("MB8")
		_cQry += " WHERE MB8_FILIAL = '" + xFilial("MB8") + "'"
		_cQry += "   AND MB8_CODREG = '" + M->MEI_CODREG + "'"
		_cQry += "   AND D_E_L_E_T_ = ' '"
		
		cSeek  := 	xFilial("MB8")+M->MEI_CODREG
		cWhile :=	"MB8->MB8_FILIAL + MB8->MB8_CODREG"
	
		FillGetDados(nOpc , "MB8", 1, cSeek,;
						{||&(cWhile)}, {|| .T. }, aNoFields,/*aYesFields*/,;
						 /*lOnlyYes*/,_cQry, /*bMontAcols*/, INCLUI,;
						 @aHeadRG, @aColRg,{||Lj3021Item(nOpc)} , /*bBeforeCols*/,;
						 /*bAfterHeader*/, /*cAliasQry*/)
	EndIf
	
	oPanel_Item:= tPanel():New(01,01,””,oWnd,;
									,,,,;
									,440,145) // cria o painel
									
	oPanel_Item:Align := CONTROL_ALIGN_ALLCLIENT
	
	oGetD := MsNewGetDados():New(0,0,0,0,;
										nOpc,cLinhaOk,cTudoOk,"+MB8_REFGRD",;
										,nFreeze,nMax,,;
										cSuperApagar,cApagaOk,oPanel_Item,@aHeadRG,;
										@aColRg)
										
	oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//verifica	 o valor do campo MEI_TPIMPD, pois se for "T", o painel com a GetDados devera ser desabilitado
	If M->MEI_TPIMPD == "T"
		//habilita Total
		oTFolderInf:aDialogs[1]:Disable()	//desabilita aba Item
		oTFolderInf:aDialogs[2]:Enable()	//habilita aba Negociacao
		oTFolder:aDialogs[4]:Enable()	    //habilita RANGE DE VALORES
		
	Else 
		//habilita Itens
		oTFolderInf:aDialogs[1]:Enable()	//habilita aba Item
		oGetD:oBrowse:Refresh()
		oTFolderInf:aDialogs[2]:Disable()	//desabilita aba Negociacao
		oTFolder:aDialogs[4]:Disable()      //desabilita RANGE DE VALORES
	EndIf	
	oTFolder:aDialogs[1]:Refresh()
	RestArea(aArea) 
	
EndIf

Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJ3021ValCadº Autor ³        		       º Data ³  04/04/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida cadastro antes de gravar chamada no fonte loja3021  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ3021ValCad(nOpc,_lTravaVld)
Local aArea      	:= GetArea()        // Posicionamento atual da tabela
Local _lRet    		:= .T.  				// Variável de retorno
Local _nI      		:= 0  					// Contador
Local _lFilSel 		:= .F.  				// Há alguma filial selecionada
Local _nPVlrF  		:= aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFIM"})	// Valor Final
Local _nPPDes  		:= aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_PDESC" })	// % Desconto
Local _nPVlFx  		:= aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFX" })  // _nPVlFx
Local _nPTipo		:= aScan(oGetDdVlr:aHeader,{ |x| AllTrim(x[2]) == "MB2_TPREGR"})  // _nPTipo
Local _nPRefgrd  	:= aScan(oGetDdVlr:aHeader,{ |x| AllTrim(x[2]) == "MB2_REFGRD"})	// Ref Grade			
Local _cCodReg		:= M->MEI_CODREG  		// Código da regra de desconto
Local _oPainel		:= Nil						// Objeto Painel
Local _lPainel		:= .F.						// Se há Painel
Local _oGetDdVlr	:= oGetDdVlr:ACols			// GetDados de Valores do Folder
Local _lValLinha	:= .T.							// Verifica qual a linha esta no grid OK, e valida os campos    
Local _cTpRgr		:= "D"							// Tipo de Registro  
Local nPosMB3GPFil	:= aScan( oGetDFilial:aHeader ,{ |x| Alltrim(x[2]) == "MB3_TIPO" })
Local nPosMB3Fil	:= aScan( oGetDFilial:aHeader ,{ |x| Alltrim(x[2]) == "MB3_CODFIL" })
Local nPosMB3Grupo	:= aScan( oGetDFilial:aHeader ,{ |x| Alltrim(x[2]) == "MB3_CODGRU" })
Local nAtMB3		:= oGetDFilial:nAt                                                     
Local lMensagem     := .T.
Local nErro			:= 0
Local nP8RefGrd    	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_REFGRD"})    // Item Grade
Local nP8Prod    	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CODPRO"})    // Produto
Local nP8ValDes  	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_DESCVL"})    // VALOR DE DESCONTO EM R$
Local nP8PerDes  	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_DESCPR"})    // PERCENTUAL DE DESCONTO %
Local nP8Categ   	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CATEGO"})    // Categoria
Local nP8Tipo		:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_TPREGR"})  	 // Tipo da Regra (se desconto/Brinde/Bonificacao)
Local nP8Qtde		:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_QTDPRO"})  	// Quantidade de produtos
Local cItemGrd 		:= ""  					// Posição do Item da Grade para MostraErro
Local aProdBnf		:= {}					// Produtos de bonificação no mesmo código de cabeçalho MEI
Local lProdOk		:= .T.					// Produto de Bonificação ok, pronto para inclusão
Local _lValLnTp 	:= .T.					// Verifica se o Tipo de Regra foi cadastrado no range de valores    
Local cLinOcc		:= ""					// Linha da grade que ocorreu o erro no grid do range de valores
Local _lValLnBf 	:= .T.					// Verifica se foi selecionado 2-Bonificação no tipo de regra, o que não será possível

Default nOpc	 		:= 0
Default _lTravaVld 	:= .T.

_lPainel := SuperGetMV("MV_LJGEPRE",.F.,.F.)`   // Passou"MV_LJGEPRE"

LJ3021MdFolder()    // valida se grid do range for Dif de Zero , desabilita  os produtos categoria.

If _lRet .And. Empty(_cCodReg)
	IF   nOpc==3  .OR.  nOpc==4    // Inclui ou Altera
		MsgInfo(STR0035) //"Codigo da Regra de Desconto inválida"
	ENDIF
	_lRet := .F.
ElseIf _lRet .And. nOpc==3   // inclui
	dbSelectArea("MEI")
	dbSetOrder(1)  //MEI_FILIAL+MEI_CODREG
	If MEI->( dbSeek( xFilial("MEI") + _cCodReg) )
		MsgInfo(STR0036) //"Codigo da Regra de Desconto já existente, favor contatar o Depto de Informática"
		_lRet := .F.
	EndIf
EndIf

If _lRet .And. Empty(M->MEI_DESCRI)
	IF nOpc==3 .OR. nOpc==4
		MsgInfo(STR0037) //"Descricao da Regra de Desconto invalida"
	ENDIF
	_lRet := .F.
EndIf

If _lRet .And. (Empty(M->MEI_DATDE) .Or. Empty(M->MEI_DATATE))
	IF   nOpc==3  .OR.  nOpc==4
		MsgInfo(STR0038) //"Data de vigencia da Regra de Desconto inválida"
	ENDIF
	_lRet := .F.
ElseIf _lRet .And. M->MEI_DATATE < M->MEI_DATDE
	IF   nOpc==3  .OR.  nOpc==4
		MsgInfo(STR0039) //"Data limite da Regra de Desconto menor que a data inicial"
	ENDIF
	_lRet := .F.
EndIf

If _lRet .And. (Empty(M->MEI_HORADE) .Or. Empty(M->MEI_HORATE))
	IF   nOpc==3  .OR.  nOpc==4
		MsgInfo(STR0040) //"Hora de vigencia da Regra de Desconto inválida"
	ENDIF
	_lRet := .F.
ElseIf _lRet .And. M->MEI_HORATE < M->MEI_HORADE
	IF   nOpc==3  .OR.  nOpc==4
		MsgInfo(STR0041) //"Hora limite da Regra de Desconto menor que a Hora inicial"
	ENDIF
	_lRet := .F.
EndIf

If _lRet .And. !_lChkBx1 .And. !_lChkBx2 .And. !_lChkBx3 .And. !_lChkBx4 .And. !_lChkBx5 .And. !_lChkBx6 .And. !_lChkBx7
	IF   nOpc==3  .OR.  nOpc==4
		MsgInfo(STR0042) //"Não foi selecionado nenhum dia da semana para a Regra de Desconto"
	ENDIF
	_lRet := .F.
EndIf

If _lRet .And. _lChkBx1
	If Empty(_cHrIDom) .Or. Empty(_cHrFDom)
		IF INCLUI .OR. ALTERA
			MsgInfo(STR0043) //"Hora de vigencia da Regra de Desconto para Domingo inválida"
		ENDIF
		_lRet := .F.
	ElseIf _cHrFDom < _cHrIDom
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0044) //"Hora limite da Regra de Desconto para Domingo menor que a Hora inicial"
		ENDIF
		_lRet := .F.
	EndIf
EndIf

If _lRet .And. _lChkBx2
	If Empty(_cHrISeg) .Or. Empty(_cHrFSeg)
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0045 + IIF(_cTpRgr == "D",STR0046,STR0047) + STR0048) //"Hora de vigencia da Regra de "###"Desconto"###"Bonificação"###" para segunda-feira inválida"
		ENDIF
		_lRet := .F.
	ElseIf _cHrFSeg < _cHrISeg
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0049) //"Hora limite da Regra de Desconto  para segunda-feira menor que a Hora inicial"
		ENDIF
		_lRet := .F.
	EndIf
EndIf

If _lRet .And. _lChkBx3
	If Empty(_cHrITer) .Or. Empty(_cHrFTer)
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0050) //"Hora de vigencia da Regra de Desconto  para terça-feira inválida"
		ENDIF
		_lRet := .F.
	ElseIf _cHrFTer < _cHrITer
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0051) //"Hora limite da Regra de Desconto  para terça-feira menor que a Hora inicial"
		ENDIF
		_lRet := .F.
	EndIf
EndIf

If _lRet .And. _lChkBx4
	If Empty(_cHrIQua) .Or. Empty(_cHrFQua)
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0052) //"Hora de vigencia da Regra de Desconto  para quarta-feira inválida"
		ENDIF
		_lRet := .F.
	ElseIf _cHrFQua < _cHrIQua
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0053) //"Hora limite da Regra de Desconto  para quarta-feira menor que a Hora inicial"
		ENDIF
		_lRet := .F.
	EndIf
EndIf

If _lRet .And. _lChkBx5
	If Empty(_cHrIQui) .Or. Empty(_cHrFQui)
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0054) //"Hora de vigencia da Regra de Desconto  para quinta-feira inválida"
		ENDIF
		_lRet := .F.
	ElseIf _cHrFQui < _cHrIQui
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0055) //"Hora limite da Regra de Desconto  para quinta-feira menor que a Hora inicial"
		ENDIF
		_lRet := .F.
	EndIf
EndIf

If _lRet .And. _lChkBx6
	If Empty(_cHrISex) .Or. Empty(_cHrFSex)
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0056) //"Hora de vigencia da Regra de Desconto  para sexta-feira inválida"
		ENDIF
		_lRet := .F.
	ElseIf _cHrFSex < _cHrISex
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0057) //"Hora limite da Regra de Desconto  para sexta-feira menor que a Hora inicial"
		ENDIF
		_lRet := .F.
	EndIf
EndIf

If ALTERA .And. M->MEI_TPIMPD <> MEI->MEI_TPIMPD
	If M->MEI_TPIMPD == "T"
		lMensagem := MsgYesno(STR0085 + cCRLF + STR0087 ) //"Alterando o campo tipo de desconto para Total as informações dos itens serão perdidas" ***** 	"Deseja Continuar?" 
	Else
		lMensagem := MsgYesno(STR0086 + cCRLF + STR0087 ) //"Alterando o campo tipo de desconto para Item as informações dos Range serão perdidas" ***** "Deseja Continuar?"
	EndIf
	
	If !lMensagem
		_lRet := .F.
	EndIf	
EndIf


If _lRet .And. _lChkBx7
	If Empty(_cHrISab) .Or. Empty(_cHrFSab)
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0058) //"Hora de vigencia da Regra de Desconto  para sábado inválida"
		ENDIF
		_lRet := .F.
	ElseIf _cHrFSab < _cHrISab
		IF   nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0059) //"Hora limite da Regra de Desconto  para sábado menor que a Hora inicial"
		ENDIF
		_lRet := .F.
	EndIf
EndIf

//Valida Filial
//Ajuste da validacao de filiais para considerar os grupos de filiais informados

If _lRet

	For _nI := 1 To Len(oGetDFilial:aCols)
	
		If !oGetDFilial:aCols[_nI][Len(oGetDFilial:aHeader)+1]
			If !Empty( oGetDFilial:aCols[_nI][nPosMB3GPFil] )
			
				// Filial
				If oGetDFilial:aCols[nAtMB3][nPosMB3GPFil] == "1" ;
										.And. !Empty(oGetDFilial:aCols[nAtMB3][nPosMB3Fil])
					_lFilSel := .T.				
				
				// Grupo de Filiais
				Elseif oGetDFilial:aCols[nAtMB3][nPosMB3GPFil] == "2" ;
										.And. !Empty(oGetDFilial:aCols[nAtMB3][nPosMB3Grupo]) 
					_lFilSel := .T.
				
				Endif  
			
			Endif
		Endif  
	
	Next _nI 

	If !_lFilSel
		IF nOpc==3  .OR.  nOpc==4
			MsgInfo(STR0060) //"Nenhuma Filial foi selecionada"
		ENDIF
		_lRet := .F.
	Endif

EndIf

IF _lRet .And. _lPainel
	_oPainel:=PainelPrecificacao():New()
	
	Begin transaction
	If	nOpc==5   /// exclui regra - PAINEL DE GESTAO -
		_lRet := _oPainel:Lj3ExcRDes(M->MEI_DATDE,M->MEI_FILIAL,M->MEI_CODREG)
	Endif
	
	End transaction
	
Endif

// Valida grid de itens ( Produtos ou categorias)

If _lRet .AND. M->MEI_TPIMPD == 'I'		//Somente por item 

	For _nI := 1 to Len(oGetD:ACOLS)    /// Procura no Acols o CODIGO DO PRODUTO , se encontrar nao grava outro (para não duplicar)

		If !aTail(oGetD:aCols[_nI])		//Se não estiver deletado
			If _lRet .AND. Empty(oGetD:ACOLS[_nI,nP8Prod]) .AND. Empty(oGetD:ACOLS[_nI,nP8Categ])		//Produto ou Categoria
				_lRet := .F.
				nErro := 1
			Endif
	
			// Se for Tipo desconto tem que informar um valor de desconto ou percentual
			If _lRet .AND. Empty(oGetD:ACOLS[_nI,nP8PerDes]) .AND. Empty(oGetD:ACOLS[_nI,nP8ValDes]) .And. oGetD:ACOLS[_nI,nP8Tipo] == "1"		//Perc.Desc ou Val.Desc
				_lRet := .F.
				nErro := 2
			Endif
			
			//O Tipo de Regra não deverá estar em branco
			If _lRet .AND. Empty(oGetD:ACOLS[_nI,nP8Tipo])		//Tipo de Regra: Desconto, Bonificação ou Brinde
				_lRet := .F.
				nErro := 3
			ElseIf _lRet .AND. oGetD:ACOLS[_nI,nP8Tipo] = "2" .AND. oGetD:ACOLS[_nI,nP8Qtde] <= 0	//Tipo Bonificação e quantidade <= 0
				_lRet := .F.
				nErro := 4
			Endif
	
			If _lRet .AND. oGetD:ACOLS[_nI,nP8Tipo] = "2"		//Se Bonificação E O MESMO PRODUTO NO MESMO CABEÇALHO
				lProdOk := (aSCan(aProdBnf, { |p| RTrim(p) == RTrim(oGetD:ACOLS[_nI,nP8Prod])}) = 0 )
				aAdd(aProdBnf, RTrim(oGetD:ACOLS[_nI,nP8Prod]))
				If !lProdOk
					nErro := 5
					nItem := _nI
					_lRet := .F.
				EndIf
			EndIf
	
			If !_lRet		//Escape, direcionar até a última linha para sair do for/next
				cItemGrd:= oGetD:ACOLS[_nI,nP8RefGrd]
				_nI		:= Len(oGetD:ACOLS)
			EndIf
	
			If _lRet 
				If !LJ3021Lok( _nI )
					_lRet	:= .F.
					cItemGrd:= oGetD:ACOLS[_nI,nP8RefGrd]
					_nI		:= Len(oGetD:ACOLS)
					nErro   := 9		//Msg informada anteriormente em LJ3021LOk
				Endif				
			Endif
		EndIf
	Next
	
	If oTFolderInf:aDialogs[1]:lReadOnly == .T.    /// desabilitado as categorias , mas existe o RANGE.
		_lRet := .T.
	Endif
	
	IF _lRet == .F.
		//MsgInfo(STR0061) //"Lista de itens , obrigatórios Código do Produto ou Categoria, Percentual ou Valor Desc "
		Do Case
		Case nErro = 1
			MsgInfo(STR0018 + " " + Alltrim(cItemGrd)+ ": " + STR0093) 		//"Item"###"Obrigatório campos Código do Produto ou Categoria!"
		Case nErro = 2
			MsgInfo(STR0018 + " " + Alltrim(cItemGrd)+ ": " + STR0094)		//"Item"###"Obrigatório campos Perc.Desc ou Val.Desc!"
		Case nErro = 3
			MsgInfo(STR0018 + " " + Alltrim(cItemGrd)+ ": " + STR0092)		//"Item"###"Favor informar o campo Tipo Regra: 1-Desconto, 2-Bonificação, 3-Brinde."
		Case nErro = 4
			MsgInfo(STR0018 + " " + Alltrim(cItemGrd)+ ": " + STR0095)		//"Item"###"Após escolher o tipo Bonificação, obrigatório preencher a Quantidade!"
		Case nErro = 5
			MsgInfo(STR0018 + " " + Alltrim(cItemGrd)+ ": " + STR0090)		//"Item"###"Não é possível repetir o mesmo produto de bonificação!"
		EndCase			
	Endif

ElseIF _lRet

	For _nI := 1 to Len(_oGetDdVlr)
		IF _lValLinha .AND. _lValLnTp /// verifica qual a linha esta no grid OK, e valida os campos.
			If _oGetDdVlr[_nI][LEN(oGetDdVlr:aHeader)+1]==.F.
				If !empty(_oGetDdVlr[_nI][_nPVlrF]) .AND. _oGetDdVlr[_nI][LEN(oGetDdVlr:aHeader)+1]==.F.
				      If _oGetDdVlr[_nI][_nPTipo] == "1"
						If !(!empty(_oGetDdVlr[_nI][_nPPDes]) .OR. !empty(_oGetDdVlr[_nI][_nPVlFx]))
							_lValLinha 	:= .F.    ///Valida a linha UM do RANGE se OK, se existir DADOS deve desabilitar a ABA Categoria.
							cLinOcc := Alltrim(_oGetDdVlr[_nI][_nPRefGrd])   // Ref Grade			
						Endif
				      ElseIf _oGetDdVlr[_nI][_nPTipo] == "2"    //Bonificacao - não habilitar na Regra de Desconto Total
						_lValLnBf := .F.
						cLinOcc := Alltrim(_oGetDdVlr[_nI][_nPRefGrd])   // Ref Grade			
					  ElseIf Empty(_oGetDdVlr[_nI][_nPTipo])		//Se não preencheu o tipo de regra
						_lValLnTp := .F.
						cLinOcc := Alltrim(_oGetDdVlr[_nI][_nPRefGrd])   // Ref Grade			
					  Endif	   						   
				Endif
			Endif
		ENDIF
	Next _nI
	
	IF !_lValLinha   /// a regra é por TOTAL e não há uma linha no range, é obrigado para TOTAL.
		_lRet :=.F.
		MsgAlert(STR0071 + ", " + STR0018 + " " + cLinOcc + ": " + STR0062) //"Range de Valores"###"Item"###"Regra por TOTAL e não há uma linha no Range"
 	ElseIf !_lValLnBf 	//Bonificacao - não habilitar na Regra de Desconto Total
		MsgAlert(STR0071 + ", " + STR0018 + " " + cLinOcc + ": " + STR0096 )				//"Range de Valores"###"Item"###"O tipo de regra 2-Bonificação está habilitado somente na Aba Cadastros, opção Tipo=I-Item!"
		_lRet := .F.
	ElseIf !_lValLnTp	//Tipo de Regra em branco
		_lRet := .F.
		MsgAlert(STR0071 + ", " + STR0018 + " " + cLinOcc + ": " + STR0092)					//"Range de Valores"###"Item"###"Favor informar o campo Tipo Regra: 1-Desconto, 2-Bonificação, 3-Brinde."
	Endif
	
	LJ3021LimpaCategorias()

Endif

RestArea(aArea)
Return _lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj3021VldFrm     ºAutor  ³            º Data ³  06/04/211  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que filtra os registros para os List Box Condicao de º±±
±±º          ³pagamento e Administradora Financeira						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja    												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj3021VldFrm()         

Local aArea      		:= GetArea()			// Posicionamento atual da tabela
Local _lExist := .F.							// Condição de existência
Local _lTodAdm:= .F.   						// Verifica se todas as Administradoras Financeiras foram selecionadas
Local _lTodCpg:= .F.   						// Verifica se todas as Condições de Pagamento foram selecionadas
Local _lCpoFrm:= MB5->(FieldPos("MB5_CODFRM")) > 0 	//  Controla se existem o campar par vincular a MB4 e a MB5

//Atualiza o List Box da Condicao de Pagamento do Folder Forma/Condicao
dbSelectArea("SE4")
dbSetOrder(1)	//SE4->E4_FILIAL+SE4->E4_CODIGO

dbSelectArea("MB5")   ////PM4
dbSetOrder(1)	//MB5_FILIAL+MB5_CODIGO+MB5_CONDPG

_aLstBxCPg := {}

If SE4->( dbSeek( xFilial("SE4") ) )
	While !SE4->( Eof() ) .And. SE4->E4_FILIAL == xFilial("SE4")
		If aScan(_aLstBxFrm,{|x| x[1] == .T. .And. Alltrim(x[2]) == Alltrim(SE4->E4_FORMA)}) <> 0
			_lExist   := .F.
			If !INCLUI
				If MB5->( dbSeek( xFilial("MB5") + M->MEI_CODREG + SE4->E4_CODIGO) )
					_lExist   := .T.
				EndIf
			EndIf
			If !_lExist
				_lTodCpg := .F.
			EndIf
			Aadd(_aLstBxCPg,{_lExist,SE4->E4_CODIGO,SE4->E4_DESCRI,Iif(_lCpoFrm,SE4->E4_FORMA,"")})
		EndIf
		SE4->( dbSkip() )
	End
EndIf

If Len(_aLstBxCPg) == 0
	Aadd(_aLstBxCPg,{.F.,"","","",""})
Else
	_lChkBx13 := _lTodCpg	//Verifica se todas as Condicoes de Pagamento foram selecionadas
EndIf
oLstBxCPg:SetArray(_aLstBxCPg)
oLstBxCPg:bLine := {|| {If(_aLstBxCPg[oLstBxCPg:nAT,1],oOk,oNo),;
								_aLstBxCPg[oLstBxCPg:nAT,02],_aLstBxCPg[oLstBxCPg:nAT,03]}}
oLstBxCPg:Refresh()

//Atualiza o List Box da Administradora Financeira do Folder Forma/Condicao
_aLstBxAdm := {}
_lExist    := .F.
_lTodAdm   := .F.

dbSelectArea("SAE")
dbSetOrder(1)	//AE_FILIAL+AE_COD

dbSelectArea("MB6")
dbSetOrder(1)	//MB6_FILIAL+MB6_CODREG+MB6_ADMFIN

If SAE->( dbSeek( xFilial("SAE") ) )
	While !SAE->( Eof() ) .And. SAE->AE_FILIAL == xFilial("SAE")
		If aScan(_aLstBxFrm,{|x| x[1] == .T. .And. Alltrim(x[2]) == Alltrim(SAE->AE_TIPO)}) <> 0
			_lExist   := .F.
			If !INCLUI
				If MB6->( dbSeek( xFilial("MB6") + M->MEI_CODREG + SAE->AE_COD) )
					_lExist   := .T.
				EndIf
			EndIf
			If !_lExist
				_lTodAdm := .F.
			EndIf
			Aadd(_aLstBxAdm,{_lExist,SAE->AE_COD,SAE->AE_DESC})//SAE
		EndIf
		SAE->( dbSkip() )
	End
EndIf

If Len(_aLstBxAdm) == 0
	Aadd(_aLstBxAdm,{.F.,"",""})
	oLstBxAdm:lReadOnly := .T.
Else
	oLstBxAdm:lReadOnly := .F.
	_lChkBx14 := _lTodAdm	//Verifica se todas as Administradoras Financeiras foram selecionadas
EndIf
oLstBxAdm:SetArray(_aLstBxAdm)
oLstBxAdm:bLine := {|| {	IIF(oLstBxAdm:nAT<=LEN(_aLstBxAdm),IIF(_aLstBxAdm[oLstBxAdm:nAT,1],oOk,oNo),oNo),;
IIF(oLstBxAdm:nAT<=LEN(_aLstBxAdm),_aLstBxAdm[oLstBxAdm:nAT,02],''),;
IIF(oLstBxAdm:nAT<=LEN(_aLstBxAdm),_aLstBxAdm[oLstBxAdm:nAT,03],'')}}
oLstBxAdm:Refresh()

RestArea(aArea)
Return (Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJ3021MdFolder  ºAutor  ³Microsiga     º Data ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LJ3021MdFolder                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ3021MdFolder(_nFolder)
Local _lRet     	:= .T.  // Variável de retorno
Local _lValLinha 	:= .F.  // F = nao existir linhas no RANGE , em branco.
LOCAL _oGetDdVlr	:= oGetDdVlr:ACols  /// array do range oGetDdVlr:aHeader
Local _nPVLrI  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRINI"})  // 01
Local _nPVlrF  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFIM"})  // 02
Local _nPPDes  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_PDESC" })  // %
Local _nPVlFx  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFX" })  // R$
Local _nI			:= 0 	// Contador 
Local _nLinhaRange	:= 0    // Range da linha

Default _nFolder 	:= 0	// _nFolder
                                          
_lPainelAba2 := Iif(!M->MEI_TPIMPD=="I",.F., .T.)

If 	INCLUI .And. !_lPainelAba2
	
	IF M->MEI_HORADE =='00:00' .AND. M->MEI_HORATE == '00:00'
		
		_lSemana := .T.
	
	Else
	                                                                                                  
		_cHrIDom := M->MEI_HORADE
		_cHrISeg := M->MEI_HORADE
		_cHrITer := M->MEI_HORADE
		_cHrIQua := M->MEI_HORADE
		_cHrIQui := M->MEI_HORADE
		_cHrISex := M->MEI_HORADE
		_cHrISab := M->MEI_HORADE
		_cHrFDom := M->MEI_HORATE
		_cHrFSeg := M->MEI_HORATE
		_cHrFTer := M->MEI_HORATE
		_cHrFQua := M->MEI_HORATE
		_cHrFQui := M->MEI_HORATE
		_cHrFSex := M->MEI_HORATE
		_cHrFSab := M->MEI_HORATE		
		
		_lChkBx1 := .T.
		_lChkBx2 := .T.
		_lChkBx3 := .T.
		_lChkBx4 := .T.
		_lChkBx5 := .T.
		_lChkBx6 := .T.
		_lChkBx7 := .T.
		_lChkBx8 := .T.
		_lChkBx9 := .T.
		_lChkBx10:= .T.
		_lChkBx11:= .T.
		_lChkBx20:= .T.		
		_lSemana := .F.	                  	
		
	Endif
	
	For _nI := 1 to Len(_oGetDdVlr) /// verifica se existe pelo menos uma linha do RANGE que não deletada.
		If _oGetDdVlr[_nI][LEN(oGetDdVlr:aHeader)+1]==.F.
			_nLinhaRange 	:= _nLinhaRange + 1   /// se maior que UM , nao precisa validar LINHA , ja limpa os ITENS/CATEG
		Endif
	Next _nI
	
	IF _nLinhaRange >=1     // Se a linha da GRID do range for Maior q um  Desabilita o GRID DE ITENS....  (( se tiver RANGE , desliga o ITENS))
		If _nLinhaRange == 1
			For _nI := 1 to Len(_oGetDdVlr)
				IF _lValLinha == .F.  /// verifica qual a linha esta no grid OK, e valida os campos.
					If _oGetDdVlr[_nI][LEN(oGetDdVlr:aHeader)+1]==.F.
						If !empty(_oGetDdVlr[_nI][_nPVLrI]) .AND. !empty(_oGetDdVlr[_nI][_nPVlrF]) .AND. _oGetDdVlr[_nI][LEN(oGetDdVlr:aHeader)+1]==.F.  .AND.  (!empty(_oGetDdVlr[_nI][_nPPDes]) .OR. !empty(_oGetDdVlr[_nI][_nPVlFx]))
							_lValLinha 	:= .T.    ///Valida a linha UM do RANGE se OK, se existir DADOS deve desabilitar a ABA Categoria.
						Endif
					Endif
				ENDIF
			Next _nI
		Else
			
			For _nI := 1 to Len(_oGetDdVlr) /// verifica se existe pelo menos uma linha do RANGE que não deletada.
				If _oGetDdVlr[_nI][LEN(oGetDdVlr:aHeader)+1]==.F.
					_lValLinha 	:= .T.   /// se maior que UM , nao precisa validar LINHA , ja limpa os ITENS/CATEG
				Endif
			Next _nI
			
		Endif                  
		
			If _lValLinha     /// se T , é que existem linhas OK , no RANGE e deve limpar grid de itens e desabilita-lo. 
			
				If _lValLinha .and. M->MEI_TPIMPD == 'I'    // se existe uma linha válida do range e o tipo está (ITEM)
					MsgInfo(STR0075) // "Para incluir regra por itens, excluir os valores do range."
					M->MEI_TPIMPD := 'T'  // volta para T (total)  
				Else  
						LJ3021LimpaCategorias()
						oTFolderInf:aDialogs[1]:lReadOnly := .T.    // Itens - Produto ou categoria   (desabilita)
						
						If M->MEI_TPIMPD == 'I'
							oTFolderInf:aDialogs[2]:lReadOnly := .T.	//Folder de Formas/Condições
						Else
							oTFolderInf:aDialogs[2]:lReadOnly := .F.	//Folder de Formas/Condições
						Endif
				Endif		
			Endif
	Else
		If M->MEI_TPIMPD == 'I'
			oTFolderInf:aDialogs[1]:lReadOnly := .F.    // Itens - Produto ou categoria   (habilita)
			oTFolderInf:aDialogs[2]:lReadOnly := .T.	//Folder de Formas/Condições
		Else
			oTFolderInf:aDialogs[2]:lReadOnly := .F.	//Folder de Formas/Condições
		Endif
		_lValLinha 	:= .F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso seja selecionada a opcao de desconto no total e o flag³
	//³de utilizacao sem forma/condicao de pagamento vinculada    ³
	//³ou caso seja selecionada Desconto no Item limpa as formas  ³
	//³de pagamento ja usadas e trava o Folder.  (DESABILITA FORMA)    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _lValLinha == .F.
		If M->MEI_TPIMPD == 'I'
			Lj3021SelTd(.F.,@oLstBxFrm,@_aLstBxFrm)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sempre que limpar todas as Formas ³
			//³ de Pagamento, deve zerar os arrays de Condicoes e Administradoras.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj3021SelTd(.F.,@oLstBxCPg,@_aLstBxCPg,.T.)
			Lj3021SelTd(.F.,@oLstBxAdm,@_aLstBxAdm,.T.)
			oTFolderInf:aDialogs[2]:lReadOnly := .T.	//Folder de Formas/Condições
			oTFolderInf:aDialogs[1]:lReadOnly := .F.    // Itens - Produto ou categoria  (habiliata)
		Else     // Desabilita se for ITEM  e Valliha = F
			oTFolderInf:aDialogs[2]:lReadOnly := .F.	//Folder de Formas/Condições
			oTFolderInf:aDialogs[1]:lReadOnly := .T.    // Itens - Produto ou categoria (desabilita)
			LJ3021LimpaCategorias()    					// limpa grid dos itens / categoria.
		EndIf
	EndIf
Endif

Return _lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJ3021LimpaCategorias                  |      | 06/04/11    º±±             
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa o grid de itens, Categoria de vendas                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ3021LimpaCategorias()

Local	nProxRef	:=0            	// nProxRef
Local 	aArea      	:= GetArea()   // Guarda aArea

If INCLUI
	oGetD:ACOLS	:={}
	nProxRef 	:= nProxRef + 1
    LJ3021CategProd(M->MEI_CODREG)

ELSE                            

	// quando incluir um registro no range irá alterar o tipo de regra de (I)item para (T) total , e abaixo limprar a grid de itens.
	M->MEI_TPIMPD := 'T' 
		
	// desabilita a grid de itens
	oTFolderInf:aDialogs[1]:lReadOnly := .T. 

Endif

oGetD:Refresh()
RestArea(aArea) 

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  Lj3021SelTd  ºAutor  ³                  º Data ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lj3021SelTd                                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj3021SelTd(_lOpc, oObjOri, _aLstOri, _lOpcFrm) 
Local _nI := 0   				// Variavel Controle 
                                      
Default _lOpc 		:= .F.    	// _lOpc
Default oObjOri 	:= Nil    	// oObjOri
Default _aLstOri 	:= {}    	// _aLstOri
Default _lOpcFrm 	:= .F.    	// Opc form

For _nI := 1 to Len(_aLstOri)
	_aLstOri[_nI][1] := _lOpc
Next _nI

oObjOri:Refresh()

If _lOpcFrm
	Lj3021VldFrm()
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    |Lj3021Item  ºAutor ³Vendas Clientes      º Data ³ 11/04/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Inclui na primeira linha do acols o numero do item 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³												              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Regras de descontos                                   	  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj3021Item(nOpc)
Local nX := 0         	// Variavel de controle

Default nOpc := 0

If Len(Acols) == 1
	For nX := 1 To Len(aHeader)
		If AllTrim(aHeader[nX,2]) == "MB8_REFGRD" .AND. Empty(Acols[Len(Acols)][nX])		//Somente se Inclusão, se alteração permanece do jeito que está. Ex: se gravou anteriormente como 02, não posso atribuir como 01.
			Acols[Len(Acols)][nX] := StrZero(1,Len(MB8->MB8_REFGRD))
		EndIf
	Next nX
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    | LjItemMb2  ºAutor ³Vendas Clientes      º Data ³ 11/04/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Inclui na primeira linha do acols do range         		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³												              ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Regras de descontos                                   	  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjItemMb2()  

Local nX := 0                      // Contador

If Len(ACols) == 1
	For nX := 1 To Len(aHeader)
		If AllTrim(aHeader[nX,2]) == "MB2_REFGRD" .AND. Empty(Acols[Len(Acols)][nX])	//Somente se Inclusão, se alteração permanece do jeito que está. Ex: se gravou anteriormente como 02, não posso atribuir como 01.
			ACols[Len(ACols)][nX] := StrZero(1,Len(MB2->MB2_REFGRD))
		EndIf
	Next nX
EndIf     

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³LJ3021Lok ³ Autor ³                       ³ Data ³ abril/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da linha Ok                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   | LJ3021Lok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigaloja                    								    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ3021Lok(nLin)
Local aArea     := GetArea()			// Guarda area
Local lRetorno  := .T.                 	// retorno
Local nPProd    := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CODPRO"})    // Produto
Local nPValDes  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_DESCVL"})    // VALOR DE DESCONTO EM R$
Local nPPerDes  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_DESCPR"})    // PERCENTUAL DE DESCONTO %
Local nPCateg   := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CATEGO"})    // Categoria
Local nPTipo	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_TPREGR"})  	 // Tipo da Regra (se desconto/Brinde/Bonificacao)
Local nPQtde	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_QTDPRO"})  	 // Quantidade
Local nPRefGrd  := aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_REFGRD"})    // Ref. Grade
Local aColsMGB	:= {}

Default	nLin := oGetD:nAT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os campos obrigatorios                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Do Case

	Case oGetD:Acols[nLin][nPTipo] == "1"  // Descontos
	
		If Empty(oGetD:Acols[nLin][nPProd]) .AND. Empty(oGetD:Acols[nLin][nPCateg])
			Help(" ",1,"OBRIGAT",,RetTitle("MB8_CODPRO")+","+RetTitle("MB8_CATEGO"),4)
			lRetorno := .F.
		Elseif Empty(oGetD:Acols[nLin][nPValDes]) .AND.  Empty(oGetD:Acols[nLin][nPPerDes])
			Help(" ",1,"OBRIGAT",,RetTitle("MB8_DESCVLR")+","+RetTitle("MB8_DESCPRC"),4)
			lRetorno := .F.
		Endif
		
	Case oGetD:Acols[nLin][nPTipo] == "2"  // Bonificação

		If Empty(oGetD:Acols[nLin][nPProd]) .AND. Empty(oGetD:Acols[nLin][nPCateg])			//Bonificação preenchida mas não consta o produto/categoria
			Help(" ",1,"OBRIGAT",,RetTitle("MB8_CODPRO")+","+RetTitle("MB8_CATEGO"),4)
			lRetorno := .F.
		ElseIf oGetD:Acols[nLin][nPQtde] <= 0												//Não deverá quantidade vazia
			Help(" ",1,"OBRIGAT",,RetTitle("MB8_QTDPRO"),4)
			lRetorno := .F.
		EndIf
		aColsMGB := LeProdRef( "MB8", Alltrim(Alltrim(oGetD:Acols[nLin][nPRefgrd]))+ "MB8" )		//Carrego o conteúdo das relações em aProdRef
		If Len(aColsMGB) = 0		//Na Relação, eu vejo se foi preenchido algum produto vinculado/relacionado
			Help(" ",1,"OBRIGAT",,RetTitle("MB8_IDPROD"),4)
			lRetorno := .F.
		EndIf

	OtherWise
	
		If !Empty(oGetD:Acols[nLin][nPValDes]) .Or. !Empty(oGetD:Acols[nLin][nPPerDes])
			MsgAlert(STR0091)	//"Para informar um desconto ou um percentual de desconto, modifique o campo Tipo Regra para 1-Desconto."
			lRetorno := .F.
		ElseIf (!Empty(oGetD:Acols[nLin][nPProd]) .OR. !Empty(oGetD:Acols[nLin][nPCateg])) .AND. Empty(oGetD:Acols[nLin][nPTipo])		//Produto ou categoria preenchido, mas NAO preencheu o tipo de regra
			MsgAlert(STR0092)											//"Favor informar o campo Tipo Regra: 1-Desconto, 2-Bonificação, 3-Brinde."
			lRetorno := .F.
		Endif	
	
EndCase

RestArea(aArea)  

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ3021VALRG ºAutor³                    º Data ³  04/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de validacao da linha para o Folder RANGE DESNCONTO  º±±
±±º          ³rotina de Regras de Desconto no objeto oGetDdVlr            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ3021VALRG(lRet)   

Local _lRet   := .T.			// Variável de retorno
Local _nI     := 0	   		// Contador
Local _nVlrIni:= 0	   		// Valor Inicial                                       
Local _nPVLrI  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRINI"}) // Valor inicial
Local _nPVlrF  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFIM"}) // Valor Final
Local _nPPDes  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_PDESC" }) // Perc. Desconto
Local _nPVlFx  := aScan(oGetDdVlr:aHeader,{ |x| Alltrim(x[2]) == "MB2_VLRFX" }) // Valor Desconto
Local _nPTipo  := aScan(oGetDdVlr:aHeader,{ |x| AllTrim(x[2]) == "MB2_TPREGR"}) // nPTipo

Default lRet := .F.		// Retorno

LJ3021MdFolder()    	// valida se grid do range for Dif de Zero , desabilita  os produtos categoria.

If !ATail(oGetDdVlr:Acols[n]) //verifica se a linha do aCols nao esta deletada (ultima posicao do array)
	If oGetDdVlr:Acols[n][_nPTipo] == "1" //Desconto
		If oGetDdVlr:Acols[n][_nPVlrF] < oGetDdVlr:Acols[n][_nPVlrI]
			MsgInfo(STR0063) //"No cadastramento de Valores o valor final deve ser maior que o inicial da faixa"
			_lRet := .F.
		EndIf
		
		If (oGetDdVlr:Acols[n][_nPPDes] > 0 .And. oGetDdVlr:Acols[n][_nPVlFx] > 0) .Or. (oGetDdVlr:Acols[n][_nPPDes] == 0 .And. oGetDdVlr:Acols[n][_nPVlFx] == 0) .And. !Empty(oGetDdVlr:Acols[n][_nPTipo])
			MsgInfo(STR0064) //"No cadastramento de Valores deve-se escolher entre Percentual ou Valor Fixo."
			_lRet := .F.
		ElseIf oGetDdVlr:Acols[n][_nPPDes] < 0 .Or. oGetDdVlr:Acols[n][_nPVlFx] < 0
			MsgInfo(STR0065) //"No cadastramento de Valores deve-se escolher valores positivos"
			_lRet := .F.
		EndIf
	ElseIf oGetDdVlr:Acols[n][_nPTipo] == "2" .AND. !Empty(oGetDdVlr:Acols[n][_nPVlrF]) 	//Bonificacao - não habilitar na Regra de Desconto Total
		MsgAlert(STR0071 + ": " + STR0096 )											//"Range de Valores"###"O tipo de regra 2-Bonificação está habilitado somente na Aba Cadastros, opção Tipo=I-Item!"
		_lRet := .F.
	ElseIf Empty(oGetDdVlr:Acols[n][_nPTipo])		//Tipo Regra em branco
		If !Empty(oGetDdVlr:Acols[n][_nPVlrF]) .AND. Empty(oGetDdVlr:Acols[n][_nPTipo])		//Produto ou categoria preenchido, mas NAO preencheu o tipo de regra
			MsgAlert(STR0071 + ": " + STR0092)											//"Range de Valores"###"Favor informar o campo Tipo Regra: 1-Desconto, 2-Bonificação, 3-Brinde."
			_lRet := .F.
		EndIf
	Endif	
EndIf

If _lRet .AND. oGetDdVlr:Acols[n][_nPTipo] == "1" //Desconto
	If n > 1	//Verifica se existem mais de um item no Acols
		For _nI := 1 to Len(oGetDdVlr:Acols)
			If !ATail(oGetDdVlr:Acols[_nI])	//verifica se a linha do aCols nao esta deletada (ultima posicao do array)
				If _nVlrIni > 0 .And. _nVlrIni >= oGetDdVlr:Acols[_nI][_nPVlrI]
					MsgInfo(STR0066) //"No cadastramento de Valores o valor inicial deve ser maior que o final da faixa anterior"
					_lRet := .F.
				EndIf
				_nVlrIni:= oGetDdVlr:Acols[_nI][_nPVlrF]
			EndIf
		Next _nI
	EndIf
Endif

Return(_lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ3021VlTpºAutor	³                    º Data ³  26/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de validacao que verifica o valor do campo MEI_TPIMPDº±±
±±º			 | Se for "T", o grid de itens sera desabilitado, pois nao eh º±±
±±º			 | preciso informar itens nessa situacao.					  º±±
±±º			 |Essa funcao tambem eh usado no X3_VALID do campo MEI_TPIMPD.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ3021VlTp()


If M->MEI_TPIMPD == "T"
	//habilita Total
	oTFolderInf:aDialogs[1]:Disable()	//desabilita aba Item
	oTFolderInf:aDialogs[2]:Enable()	//habilita aba Negociacao
Else 
	//habilita Itens
	oTFolderInf:aDialogs[1]:Enable()	//habilita aba Item
	oTFolderInf:aDialogs[2]:Disable()	//desabilita aba Negociacao
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³sempre retornamos .T., pois essa funcao tambem eh uma validacao³
//³  de campo e toda validacao obriga um retorno logico           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} LJ3021MB3When
Faz a validacao dos campos do Folder Grupo/Filiais
	
@author Mauro Paladini
@since 24/04/2014
@version 1.0		
/*/
//-------------------------------------------------------------------
Function LJ3021MB3When( nTipo )

Local nPosTipo  := aScan( oGetDFilial:aHeader,{ |x| Alltrim(x[2]) == "MB3_TIPO"})	// Posição do Tipo
Local nLin		:= oGetDFilial:nAT															// Linha
Local lRet		:= .F.																			// Variável de retorno

Default nTipo := 1		// 1=Filial, 2=Grupo

If nTipo == 1 .And. oGetDFilial:aCols[nLin,nPosTipo] == "1"
	lRet := .T.
	
Elseif nTipo == 2 .And. oGetDFilial:aCols[nLin,nPosTipo] == "2"
	lRet := .T.	
	
Endif 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaHeader
Cria aHeader padrao para uso em objeto Getdados
	
@author Mauro Paladini
@since 24/04/2014
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function CriaHeader(aHeadGetD,aColsGetD,cAliasGD,aCposDel)

Local aArea		:= GetArea()		// Posicionamento atual da tabela
Local nY			:= 0				// Contador
Local lDelField	:= .F.				// Marca para deletar campo

Default aHeadGetD := {}
Default aColsGetD	:= {}
Default cAliasGD := ""
Default aCposDel	:= {}
	
lDelField	:= !Empty(aCposDel)

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAliasGD))
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita todos os campos usados menos os campos ³
//³ que estao na enchoice.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAliasGD

	If lDelField .And. Ascan(aCposDel,RTrim(SX3->X3_CAMPO)) <> 0
		SX3->( DbSkip() )
		Loop
	Endif

	If X3Uso(SX3->X3_USADO)    
		AddSx3(@aHeadGetD)
	EndIf

	SX3->(dbSkip())
		
Enddo
	
Aadd(aColsGetD,Array(Len(aHeadGetD)+1))

For ny := 1 to Len(aHeadGetD)
	aColsGetD[1][ny] := CriaVar(aHeadGetD[ny][2])
Next ny
aColsGetD[1][Len(aHeadGetD)+1] := .F.  
	
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddSx3
Adiciona campo em array auxiliar com caracteristicas do SX3.
Funcao auxiliar a funcao CriaHeader()
	
@author Mauro Paladini
@since 24/04/2014
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function AddSx3( aAux , cTitCampo , cCampo )

Default aAux := {}
Default cTitCampo	:= Trim(X3Titulo())
Default cCampo		:= SX3->X3_CAMPO

Aadd(aAux,{ AllTrim(X3Titulo()),;
	SX3->X3_CAMPO	,;
	SX3->X3_PICTURE,;
	SX3->X3_TAMANHO,;
	SX3->X3_DECIMAL ,;
	SX3->X3_VALID	,;
	SX3->X3_USADO	,;
	SX3->X3_TIPO	,;
	SX3->X3_F3 		,;
	SX3->X3_CONTEXT ,;
	SX3->X3_CBOX	,;
	SX3->X3_RELACAO })	
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LJ3021ProdV
Consulta F3 específica para ingressar os produtos vinculados como brinde ou bonificação
	
@author Mauro Paladini
@since 25/04/2014
@version 1.0		
/*/
//-------------------------------------------------------------------
Function LJ3021ProdV(oObjAux)                        

Local oDlgProd		:= Nil			// Objeto dialog Produto
Local oSBCancela		:= Nil			// Botão Cancela 
Local oSBConfirma  	:= Nil			// Botão Confirma
Local oGetProd		:= Nil			// Objeto GetProd
Local aHeadMGB		:= {}			// Array Cabeçalho MGB
Local aColsMGB		:= {}			// Array detalhe MGB
Local aAuxAcols		:= oObjAux:aCols												// Auxiliar Acols
Local nPosRefGrade	:= aScan( oObjAux:aHeader,{|x| Right(x[2],7) == "_REFGRD" })	// Posição Grade
Local cRefAux		:= aAuxAcols[oObjAux:nAt,nPosRefGrade]							// Auxiliar Grade
Local cAliasTab		:= Left(oObjAux:aHeader[1][2],3)								// Alias corrente
Local nPTipo		:= aScan(oObjAux:aHeader,{|x| AllTrim(x[2])=="MB8_TPREGR"})  	 // Tipo da Regra (se desconto/Brinde/Bonificacao)                                                                                                                                    
Local nPTipo2       := aScan(oObjAux:aHeader,{|x| AllTrim(x[2])=="MB2_TPREGR"})  	 // Tipo da Regra (se desconto/Brinde/Bonificacao)

Default oObjAux := nil

// Valida para o usuário não informar produtos quando a regra for desconto.
If nPTipo > 0 
	IF oObjAux:Acols[n][nPTipo] == "1" .And. cAliasTab == "MB8"
		Return .F.
	Endif
EndIf
  
  // Valida para o usuário não informar produtos quando a regra for desconto.
If nPTipo2 > 0                                                               
	If oObjAux:Acols[n][nPTipo2] == "1" .And. cAliasTab == "MB2"
		Return .F.
	Endif
Endif

aColsMGB := LeProdRef( cAliasTab , cRefAux + cAliasTab )
CriaHeader(aHeadMGB , IIF(Len(aColsMGB)== 0 , aColsMGB , Nil ) ,"MGB",{"MGB_HREXP"})

Define MsDialog oDlgProd TITLE STR0081 STYLE DS_MODALFRAME From 250,300 To 500,1050 OF oMainWnd PIXEL //"Produtos Vinculados"
	oGetProd  := MsNewGetDados():New(005,;
								005,;
								(oDlgProd:nClientHeight/2)-35,;
								(oDlgProd:nClientWidth/2)-8,;
								GD_UPDATE+GD_INSERT+GD_DELETE,;
								"AllwaysTrue",;
								"AllwaysTrue",;
								"",;
								/*aAlter*/,;
								,;
								999,;
								"AllwaysTrue",;
								"",;
								"AllwaysTrue",;
								oDlgProd,;
								@aHeadMGB,;
								@aColsMGB)      
								
	DEFINE SBUTTON oSBConfirma 	FROM (oDlgProd:nClientHeight/2)-30, (oDlgProd:nClientWidth/2)-80  TYPE 01 ACTION (  Lj3021Bt( cAliasTab,cRefAux, oGetProd, oDlgProd) ) ENABLE OF oDlgProd
	DEFINE SBUTTON oSBCancela 	FROM (oDlgProd:nClientHeight/2)-30, (oDlgProd:nClientWidth/2)-40  TYPE 02 ACTION (oDlgProd:End()) ENABLE OF oDlgProd

ACTIVATE MSDIALOG oDlgProd

cXBLoj0045 := cRefAux+cAliasTab		//Retorno (XB_TIPO = 5) do SXB de LOJ004 (X3_F3 de MB8_IDPROD) 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AddProdRef()
Adiciona um array com produtos vinculados ao array principal de produtos vinculados aProdRef 
Usado por todas os folders que tenham o campo Produto Relacionado

aProdRef
[x][1] Alias da tabela correspondente
[x][2] ID Item aCols
[x][3] Array Produtos
	
@author Mauro Paladini
@since 8/05/2014
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function AddProdRef( cAliasTab , cItemRef  , aProds )

Local nPosITRef	:= 0		// Posição do item referência

Default cAliasTab	:= ""
Default cItemRef	:= ""
Default aProds	:= {}

nPosITRef := aScan( aProdRef ,{ |x| Alltrim(x[1]+x[2])  == Alltrim(cAliasTab+cItemRef) })

IF nPosITRef == 0	
	aAdd( aProdRef , { cAliasTab , cItemRef , aProds } ) 
Else
	aProdRef[nPosITRef][3] := aClone(aProds) 
Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LeProdRef
Faz a leitura do array com produtos vinculados 

@author Mauro Paladini
@since 8/05/2014
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function LeProdRef( cAliasTab , cItemRef )

Local nPosITRef	:= 0			// Posição do Item de Referência
Local nPosProd    	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2])=="MB8_CODPRO"})    // Produto

Default cAliasTab	:= ""
Default cItemRef	:= ""

nPosITRef	:= aScan( aProdRef ,{ |x| Alltrim(x[1]+x[2])  == Alltrim(cAliasTab+cItemRef) })

If Type("N") = "N" .AND. n > 0 .AND. n <= Len(aCols) .AND. nPosProd > 0
	cProdItem := aCols[n][nPosProd]
Else
	cProdItem := ""
EndIf

Return( IIF( nPosITRef == 0 , {} , aProdRef[nPosITRef][3] ) ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaProdRef
Inicializa e monta o array aProdRef de todos os itens da regra de desconto.
Chamado no inicio da rotina para carregar os itens 

@author Mauro Paladini
@since 14/05/2014
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function MontaProdRef( aAux )

Local aArea			:= GetArea()			// Posicionamento atual da tabela 
Local nX			:= 0					// Contador
Local nI			:= 0					// Contador
Local nZ			:= 0					// Contador
Local aHeadMGB		:= {}					// Array MGB - Cabeçalho
Local aAuxProd		:= {}					// Array auxiliar Produto
Local aAuxaCols		:= {}					// Array auxiliar aCols
Local cRefGrade		:= ""					// Grade

Default aAux := {}

CriaHeader(aHeadMGB , Nil ,"MGB", {"MGB_HREXP"})

If AliasIndic( "MGB" )

	For nX := 1 to Len(aAux)

		aAuxProd	:= {}
		aAuxaCols	:= aClone(aAux[nX][1])
		aAuxaHeader	:= aClone(aAux[nX][2])
		cAliasTab	:= Left(aAuxaHeader[nX][2],3)
	
		For nI := 1 To Len(aAuxAcols)
	
			// Para cada linha do aCols carrega Array MGB
			DbSelectArea("MGB")
			MGB->( DbSetOrder(1) ) //MGB_FILIAL+MGB_CODREG+MGB_IDPROD	
			IF MGB->( DbSeek( xFilial("MGB") + M->MEI_CODREG ) )
		
				While MGB->( !Eof() .And. Alltrim(MGB->MGB_FILIAL+MGB->MGB_CODREG) ;
										== Alltrim(xFilial("MGB") + M->MEI_CODREG ) )

					If cRefGrade <> MGB->MGB_IDPROD .AND. !Empty(cRefGrade) 
						//Atualizar AddProdRef
						// Vincula produtos carregados
						If Len(aAuxProd) > 0
							AddProdRef( cAliasTab , cRefGrade  , aAuxProd )
							aAuxProd := {}
						Endif
					EndIf
					
					cRefGrade := MGB->MGB_IDPROD
					aAuxCpo := {}
					For nZ := 1 To Len(aHeadMGB)				
						If aHeadMGB[nZ][10] <> "V"
							Aadd(aAuxCpo, MGB->&(aHeadMGB[nZ][2]))
						ElseIf aHeadMGB[nZ][2] = "MGB_DESPRO"		//Preenche a descrição do prod no grid de itens
							Aadd(aAuxCpo, PadR(POSICIONE('SB1',1,XFILIAL('SB1') + MGB->MGB_CODPRO, 'B1_DESC'),Len(CriaVar(aHeadMGB[nZ][2]))))
						Else
							Aadd(aAuxCpo, CriaVar(aHeadMGB[nZ][2]))						
						Endif				
					Next nZ
			
					Aadd(aAuxCpo,.F.)
					Aadd(aAuxProd,aAuxCpo)
		
					MGB->( DbSkip() )
								
				End			 			
			Endif
		
			// Vincula produtos carregados
			If Len(aAuxProd) > 0
				AddProdRef( cAliasTab , cRefGrade  , aAuxProd )
				aAuxProd := {}
			Endif
		Next nI 
	
	Next nX 
	
Else
	MsgAlert(STR0079) // "Esta rotina depende de execução do update de base UPDLO140, verifique boletim técnico."
EndIf

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj3021LiLok()
Valida a linha da Getdados do Folder Filiais

@author Mauro Paladini
@since 14/05/2014
@version 1.0		
/*/
//-------------------------------------------------------------------
Function Lj3021LiLok()   

Local lRet  	:= .T.																				// Variável de retorno
Local nI		:= 0																				// Contador
Local nPosMB3Fil:= aScan( oGetDFilial:aHeader ,{ |x| Alltrim(x[2]) == "MB3_CODFIL" })	// Posição Filial MB3
Local nPosTipo	:= aScan( oGetDFilial:aHeader ,{ |x| Alltrim(x[2]) == "MB3_TIPO" })	// Posição Tipo MB3
Local nAt		:= oGetDFilial:nAT																// Posição
Local cFilAtual	:= oGetDFilial:Acols[nAT][nPosMB3Fil]										// Filial atual
Local cGrupoAtu	:= oGetDFilial:Acols[nAt][nPosTipo]										// Grupo atual

For nI := 1 to Len(oGetDFilial:Acols)

	If ( !aTail(oGetDFilial:Acols[nI]) .And. nI <> nAt )
		
		If oGetDFilial:Acols[nI][nPosTipo] == "1" 
		
			If oGetDFilial:Acols[nI][nPosMB3Fil] == cFilAtual
				MsgStop("Filial duplicada")
				lRet := .F.
			Endif
		
		ElseIf oGetDFilial:Acols[nI][nPosTipo] == "2" 
		
			If oGetDFilial:Acols[nI][nPosTipo] == cGrupoAtu
				MsgStop("Grupo duplicado")
				lRet := .F.
			Endif

		Endif

	EndIf

Next nI

Return(lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} Lj3021Bt()
Função para saída da Janela
@param  cAliasTab - Alias da Consulta
@param cRefAux - Referencia da Consulta
@param  oGetProd - MsGetDados do Produto
@param oDlgProd - Janela 
@author fabiana.silva
@since 27/10/2017
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function Lj3021Bt(cAliasTab,cRefAux, oGetProd, oDlgProd)

If Lj3021Gt(oGetProd:aHeader, oGetProd:aCols)
 	AddProdRef( cAliasTab , cRefAux+cAliasTab , oGetProd:aCols ) 
 	oDlgProd:End()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj3021Gt()
Valida a linha da Getdados do Cadastro de Produtos Relacionados
@param _aHeader - Cabeçalho da MsGetDados
@param _aCols - Coluna da MsGetDados
@author fabiana.silva
@since 27/10/2017
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function Lj3021Gt(_aHeader, _aCols)
Local lOk 		:= .T. //Retorno da rotina
Local nX 		:= 1	//Contador de Lihas
Local aProd 	:= {}	//Array de Produtos processados
Local nPosProd 	:= aScan(_aHeader , { |c| RTrim(c[2]) == "MGB_CODPRO" })		//Posicao da coluna de produtos
Local nErro		:= 0	//Número do erro
Local nItem		:= 0	//Número do item

Do While lOk .AND. (  nX <=  Len(_aCols)  )
	If !aTail(_aCols[nX]) .AND. nPosProd > 0			//o Ultimo elemento do array _aCols é .T. deletado ou .F. não deletado
		lOk := (aSCan(aProd, { |p| RTrim(p) == RTrim(_aCols[nX, nPosProd])}) = 0 )
		aAdd(aProd, RTrim(_aCols[nX, nPosProd]))
		If !lOk
			nErro := 1
			nItem := nX
		EndIf
		If lOk .AND. ( nPosQuant := aScan(_aHeader , { |c| RTrim(c[2]) == "MGB_QTDPRO" }) ) > 0	.AND. (_aCols[nX][nPosQuant] <= 0) //Quantidade menor que 0
			lOk := .F.
			nErro := 2
			nItem := nX
		EndIf
	EndIf
	nX++
EndDo	
If !lOk
	If nErro = 1
		MsgAlert(STR0084)//"Somente é possível vincular o produto ao Item somente uma vez."
	ElseIf nErro = 2
		MsgAlert( STR0018 + " " + Alltrim(Str(nItem)) + STR0088 )//"Item" + " " +  ": Não é possível aceitar quantidade menor ou igual a 0!"
	EndIf
EndIf	


Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ3021PR
Retorno da Consulta F3 específica para ingressar os produtos vinculados como brinde ou bonificação
	
@author fabiana.silva	
@since 27/10/2017
@version 1.0		
/*/
//-------------------------------------------------------------------
Function LJ3021PR()

Return cXBLoj0045

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C(nTam)
	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) // variavel que trata se foi chamado pelo Robo de Testes
	Local nHRes	:=	IIF(lAutomato, 640, oMainWnd:nClientWidth)	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

Return Int(nTam)
