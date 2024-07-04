#INCLUDE "TMKA360B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"

#DEFINE  PESQUISA "2" // UZ_FORMATO
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณTk360SimulacaบAutorณVendas Clientes     บ Data ณ  07/03/03   บฑฑ
ฑฑฬอออออออออุอออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณTela de simulacao o script dinamico. Permite a visualizacao  บฑฑ
ฑฑบ         ณdo script no formato de execucao.                            บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametroณ EXPN1: Opcao selecionada no Menu.                           บฑฑ
ฑฑบ         ณ EXPA2: Array com os dados do Tree.                          บฑฑ
ฑฑบ         ณ EXPO3: Objeto do Tree.                                      บฑฑ
ฑฑบ         ณ EXPA4: Array com os dados do cargo das respostas para       บฑฑ
ฑฑบ         ณ        controle de Itens.                                   บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ AP8-Call Center-Cadastro de Script                          บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK360Simulaca(nOpc,aTreeScript,oTreeScript,aAltCargo)

Local oDlgSimula	:= Nil	 					//Dialog de simulacao.

//Array com os panels objeto.
Local aPanel		:= {}						// Array com os panel para exibicao.
Local oPanel		:= Nil						// Objetos para exibicao do Panel
Local nPanel 		:= 1						// Contador do panel ativo.

//Array com os controles dos objetos.
Local aControl		:= {}	    	            // Array de controles do panel - armazena os dados executados.

// Objeto tree da simulacao
Local oTreeSimu		:= Nil						// Objeto tree de simulacao

// Size da Dialog
Local aSizeDlg   	:= MsAdvSize(.T.,.F.,400)	//Array com as dimensoes da tela
Local aSize      	:= {}						// Size da Dialog - Funcao de calculo para coordenadas de tela.
Local aObjects   	:= {} 						// Array de controle utilizado nos calculos de didmensao da Dialog

// Arrays de Posicionamento dos objetos
Local aPosSay   	:= {}						// Array com as posicoes para SAY
Local aPosCab   	:= {}						// Array com as posicoes para Score
Local aPostree  	:= {}						// Array com as posicoes para Tree
Local aPosPanel 	:= {}						// Array com as posicoes para panel
Local aPosLabel 	:= {}						// Array com as posicoes para label
Local aPosMemo  	:= {}						// Array com as posicoes para Memos
Local aPosButton	:= {}						// Array com as posicoes para Botoes

// Score da tela
Local oScore		:= Nil
Local cScore		:= ""

// Controle de largura do tree
Local nWidthTree	:= 0

//Blocos para Ok e Cancel
Local bOk			:= {||(oDlgSimula:End())}
Local bCancel		:= {||(oDlgSimula:End())}

// Variaveis de Memo da tela.
Local oMemoAsk		:= Nil
Local oMemoResp		:= Nil
Local cMemoAsk		:= ""
Local cMemoResp		:= ""

// Objetos do GROUP dos memos
Local oGrp1
Local oGrp2

// Objetos dos botoes de Anterior e Proximo
Local oAnterior
Local oProximo

Local aScript  := aClone(aTreeScript)			// Usa um espelho do tree original do cadastro de Script

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se existem Perguntas e respostas para a exibicao da tela. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Len(aScript) > 0
	MsgStop(STR0001) //"Nใo existem dados para exibicao do Script."
	Return(.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calcula automaticamente as dimensoes dos objetos            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณARRAY ASIZE - Tamanho da Dialog e Area de Trabalho										 ณ
ณ	1 - Linha inicial area trabalho 													 ณ
ณ	2 - Coluna inicial area trabalho													 ณ
ณ	3 - Linha final area trabalho														 ณ
ณ	4 - Coluna final area trabalho														 ณ
ณ	5 - Coluna final dialog																 ณ
ณ	6 - Linha final dialog																 ณ
ณ	7 - Linha inicial dialog															 ณ
ณ																						 ณ
ณARRAY AOBJECTS - Tamanho "Default" dos Objetos para o calculo das posicoes				 ณ
ณ	1 - Tamanho X																		 ณ
ณ	2 - Tamanho Y																		 ณ
ณ	3 - Dimensiona X																	 ณ
ณ	4 - Dimensiona Y																	 ณ
ณ	5 - Retorna dimensoes X e Y (SIZE) ao inves de linha / coluna final					 ณ
ณ																						 ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calcula as dimensoes do Label do cabecalho                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aObjects := {}

Aadd( aObjects, { 100, 20 , .T., .F. } )
Aadd( aObjects, { 300, 100, .T., .T. } )

aSize      := { aSizeDlg[ 1 ], aSizeDlg[ 2 ], aSizeDlg[ 3 ], aSizeDlg[ 4 ], 0, 0 }
aPosCab  := MsObjSize( aSize, aObjects, .T., .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calcula as dimensoes entre os campos do cabecalho:Nome,Entidade,Pontos e Telefone  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aObjects := {}

Aadd( aObjects, { 100, 100, .T., .T. } )

aSize      := { aPosCab[1,2], aPosCab[1,1], aPosCab[1,4], aPosCab[1,3], 0, 0 }
aPosSay    := MsObjSize( aSize, aObjects, .T., .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calcula as dimensoes para as areas que conterao o Tree e os Panels  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aObjects := {}

Aadd( aObjects, { 100, 100, .T., .T. } )
Aadd( aObjects, { 300, 100, .T., .T. } )

aSize      := { aPosCab[2,2], aPosCab[2,1], aPosCab[2,4], aPosCab[2,3], 0, 0 }
aPosTree   := MsObjSize( aSize, aObjects, .T., .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Divide a area do panel entre os objetos oPanel e buttons            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aObjects := {}

Aadd( aObjects, { 150, 100,.T., .T.,.T. } )
Aadd( aObjects, { 100, 50 ,.T., .F.,.F. } )
Aadd( aObjects, { 100, 15, .T., .F.,.T.} )

aSize      := { aPosTree[2,2], aPosTree[2,1], aPosTree[2,4], aPosTree[2,3], 0, 0 }
aPosPanel  := MsObjSize( aSize, aObjects, .T., .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calcula as dimensoes para os labels dos memos       			    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aObjects := {}

Aadd( aObjects, { 100, 100, .T., .T., .F.} )
Aadd( aObjects, { 100, 100, .T., .T., .F.} )

aSize      := { aPosPanel[2,2], aPosPanel[2,1], aPosPanel[2,4], aPosPanel[2,3], 0, 0 }
aPosLabel  := MsObjSize( aSize, aObjects, .T., .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Divide a area entre os memos de pergunta e resposta 				ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aObjects := {}

Aadd( aObjects, { 100, 100, .T., .T., .T.} )
Aadd( aObjects, { 100, 100, .T., .T., .T.} )

aSize      := { aPosPanel[2,2], aPosPanel[2,1], aPosPanel[2,4], aPosPanel[2,3], 0, 0 }
aPosMemo   := MsObjSize( aSize, aObjects, .T., .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Divide a area entre os botoes de navegacao       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aObjects := {}

Aadd( aObjects, { 35, 11, .F., .F., .T.} )
Aadd( aObjects, { 35, 11, .F., .F., .T.} )
Aadd( aObjects, { 35, 11, .F., .F., .T.} )

aSize      := { aPosPanel[3,2], aPosPanel[3,1], aPosPanel[3,4], aPosPanel[3,3], 0, 0 }
aPosButton := MsObjSize( aSize, aObjects, .T., .T. )


DEFINE MSDIALOG oDlgSimula FROM aSizeDlg[7], 000 TO aSizeDlg[6],aSizeDlg[5] TITLE STR0002 PIXEL //"Simulacao"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria os label para delimitar os objetos do cabecalho             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@aPosCab[1,1],aPosCab[1,2] TO aPosCab[1,3],aPosCab[1,4] LABEL "" OF oDlgSimula PIXEL
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria os say do cabecalho: Nome do Contato, Pontuacao, Entidade e Timer.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@aPosSay[1,1]+5,aPosSay[1,2]+10 SAY STR0003 OF oDlgSimula PIXEL //"Pontuacao: " //"Pontuacao"
	@aPosSay[1,1]+5,aPosSay[1,2]+40 SAY oScore VAR cScore Picture "999999" OF oDlgSimula PIXEL COLOR CLR_RED
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria o tree com as respostas dadas pelo cliente.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE DBTREE oTreeSimu FROM aPosTree[1,1],aPosTree[1,2] TO aPosTree[1,3], aPosTree[1,4] OF oDlgSimula CARGO
	
	nWidthTree := aPosTree[1,4]*2
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria os Panel e os seus respectivos objetosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aPanel := Tk360Panel( oDlgSimula ,aScript 	  ,@aControl   ,@aPosPanel,;
	@cMemoResp ,@oMemoResp  ,@oPanel)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria os memos para as perguntas e respostas.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@aPosLabel[1,1],aPosLabel[1,2] GROUP oGrp1 TO aPosLabel[1,3],aPosLabel[1,4] LABEL STR0004 COLOR CLR_RED  OF oDlgSimula PIXEL //"Observa็๕es da Pergunta"
	@aPosMemo[1,1]+7,aPosMemo[1,2]+5 GET oMemoAsk    VAR cMemoAsk    MEMO SIZE aPosMemo[1,3]-10,aPosMemo[1,4]-10 READONLY PIXEL OF oDlgSimula
	
	@aPosLabel[2,1],aPosLabel[2,2] GROUP oGrp2 TO aPosLabel[2,3],aPosLabel[2,4] LABEL STR0005 COLOR CLR_BLUE OF oDlgSimula PIXEL //"Observacoes da Resposta"
	@aPosMemo[2,1]+7,aPosMemo[2,2]+5 GET oMemoResp VAR cMemoResp MEMO SIZE aPosMemo[2,3]-10,aPosMemo[2,4]-10 READONLY PIXEL OF oDlgSimula
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria os botoes de navegacaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@aPosButton[1,1],aPosButton[1,2] BUTTON oAnterior   PROMPT STR0006  SIZE aPosButton[1,3],aPosButton[1,4]+3 OF oDlgSimula PIXEL ; //"<< Voltar"
	ACTION Tk360Show(	1			,@aPanel		,@nPanel	,oAnterior,;
						oProximo	,aScript 		,@oTreeSimu	,aControl,;
						@cMemoAsk  	,@oMemoAsk		,@cMemoResp	,@oMemoResp,;
						@cScore     ,@oScore) //"<< Voltar"
	
	@aPosButton[2,1],aPosButton[2,2] BUTTON oProximo   PROMPT STR0007  SIZE aPosButton[2,3],aPosButton[2,4]+3 OF oDlgSimula PIXEL ; //"Avancar >>"
	ACTION Tk360Show(	2			,@aPanel	 	,@nPanel		,oAnterior,;
						oProximo	,aScript 		,@oTreeSimu		,aControl,;
						@cMemoAsk   ,@oMemoAsk   	,@cMemoResp		,@oMemoResp,;
						@cScore     ,@oScore) //"Avancar >>"
	
	Tk360Show(	0				,@aPanel	 	,@nPanel	,oAnterior,;
				oProximo		,aScript 		,@oTreeSimu	,aControl,;
				@cMemoAsk   	,@oMemoAsk	  	,@cMemoResp	,@oMemoResp,;
				@cScore         ,@oScore)
	

ACTIVATE MSDIALOG oDlgSimula ON INIT (EnchoiceBar(oDlgSimula,bOk,bCancel))

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360Panel      ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria os panel's que conterao os objetos para simulacao.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณRetorno com um ARRAY de Panel - com a pergunta e respostas criadas    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPO1: Dialog de simulacao para (dialogo pai).               			บฑฑ
ฑฑบ          ณEXPA2: Array com as perguntas e respostas.                   			บฑฑ
ฑฑบ          ณEXPA3: Array com os controles das respostas dadas.           			บฑฑ
ฑฑบ          ณEXPA4: Array com as posicoes para criacao dos objetos.       			บฑฑ
ฑฑบ          ณEXPC5: Variavel para memo de resposta.                       			บฑฑ
ฑฑบ          ณEXPO6: Objeto do Memo de resposta.                           			บฑฑ
ฑฑบ          ณEXPO7: Objeto do Panel.                                      			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7-Call Center-Cadastro de Script                          			บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                Alteracoes desde sua criacao                                     บฑฑ
ฑฑฬออออออออออัอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ   DATA   ณ Programador   ณManutencao Efetuada                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ26/06/03  ณ RAFAEL Q.     ณTratamento de aspas nos textos de perguntas.          บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360Panel(	oDlgSimula ,aScript   ,aControl  ,aPosObj	,;
						cMemoResp  ,oMemoResp ,oPanel)

Local nItem     := 0				// Posicao dentro do ARRAY com as perguntas e respostas
Local oScroll	:= Nil				// Objeto SCROLL para rolagem da tela.
Local aMemos    := {}				// Array com os memos da tela.
Local aResultado:= {}				// Array com os objetos Panel criados de acordo com o numero de perguntas do script
Local cPergunta := ""				// Descricao da pergunta que sera criada para o panel
Local aResposta := {}				// Array com com as respostas da pergunta criada
Local cTpObj 	:= ""				// Tipo do objeto de resposta
Local bBlock	:= {||}				// Exeblock
Local oSay		:= Nil				// Objeto SAY que sera criado dinamicamente para cada Pergunta
Local aSaveScr  := aClone(aScript)	// Salva array para posterior restauracao.
Local cPergAux	:= ""				// Variavel auxiliar para tratamento de perguntas
Local nAspas	:= 0				// Variavel para For utilizado no tratamento das perguntas.

For nItem := 1 To Len(aScript)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria um panel para conter cada conjunto de perguntas e respostas.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/* 
	Painel criado atraves do construtor devido a necessidade da utilizacao do laco.
	
	  [ <oPanel> := ] TPanel():New( <nRow>, <nCol>, <cText>,;
										[<oWnd>], <oFont>, <.lCenter.>, <.lRight.>, ;
										<nClrText>, <nClrBack>, <nWidth>, <nHeight>, <.lLowered.>,;
										<.lRaised.> )
	*/
	oPanel:= &("oPanel"+ StrZero(nItem)):= TPanel():New(	aPosObj[1,1], aPosObj[1,2], "",;
															oDlgSimula, NIL, .T., .F.,;
															NIL, NIL, aPosObj[1,3], aPosObj[1,4], .F., .F. )
	oPanel:Cargo := ''
	
	Aadd(aResultado,oPanel)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria um scrollbox para conter os objetos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@00,00 SCROLLBOX oScroll VERTICAL SIZE aPosObj[1,4],aPosObj[1,3] OF oPanel BORDER
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria a pergunta do Script 				ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPergunta := ""         
	cPergAux  := ""
	
	If aScript[nItem][3] <> NIL
		cPergunta := aScript[nItem][3]
		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTratamento para o controle do texto da pergunta.            ณ
		//ณSe existirem aspas identicas a utilizada na Macro o sistema ณ
		//ณacusara erro de sintaxe.                                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nAspas:=1 To Len(cPergunta)
			If SubStr(cPergunta,nAspas,1)= "'"
				cPergAux += '"'
			Else
				cPergAux += SubStr(cPergunta,nAspas,1)
			EndIf
		Next	
		cPergunta := cPergAux
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria um objeto say para a pergunta com o texto em vermelho   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		bBlock  := &("{|| '" + AllTrim(cPergunta) + "'}")
		
		/*Cria as perguntas (Objeto SAY)
		
		Say criado atraves de Contrutor devido a utilizacao do bloco de codigo.
		
		[ <oSay> := ] TSay():New( <nRow>, <nCol>, <{cText}>,;
								[<oWnd>], [<cPict>], <oFont>, <.lCenter.>, <.lRight.>, <.lBorder.>,;
								<.lPixel.>, <nClrText>, <nClrBack>, <nWidth>, <nHeight>,;
								<.design.>, <.update.>, <.lShaded.>, <.lBox.>, <.lRaised.> )
		*/
		
		oSay:= TSay():New(	10, 5, bBlock,;
							oScroll, NIL, NIL, .F., .F., .F.,;
							.T., CLR_RED, NIL, 215, 60,;
							.F., .F., .F., .F., .F. )
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria as respostas do Script  			ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (aScript[nItem,5] <> NIL) .AND. !Empty(aScript[nItem,5])
		
		cIdResp		:= aScript[nItem][2]
		cTpObj  	:= aScript[nItem][5]
		aResposta 	:= aScript[nItem][6]
		
		Tk360Resposta(	aResposta	,cTpObj			,@oScroll	,@aControl,;
						cIdResp 	,aPosObj[1]		,@cMemoResp	,@oMemoResp,;
						nItem 		,@aMemos)
		
		aResposta := {}
	Endif
	
Next nItem
aScript  := aClone(aSaveScr)

Return(aResultado)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360Resposta   ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria as respostas para apresentacao no panel da tela de simulacao.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                          			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPA1: Array com as respostas.                               			บฑฑ
ฑฑบ          ณEXPC2: Tipo do objeto para respostas.                        			บฑฑ
ฑฑบ          ณEXPO3: Objeto Scroll.                                        			บฑฑ
ฑฑบ          ณEXPA4: Array de controle das respostas informadas.           			บฑฑ
ฑฑบ          ณEXPC5: Id de controle da resposta (cargo)                   			บฑฑ
ฑฑบ          ณEXPA6: Coordenada para Panel.                                			บฑฑ
ฑฑบ          ณEXPC7: Texto para memo de resposta.                          			บฑฑ
ฑฑบ          ณEXPO8: Objeto para memo de respostas.                        			บฑฑ
ฑฑบ          ณEXPN9: Item do tree onde esta posicionada a resposta.         		บฑฑ
ฑฑบ          ณEXPN10:Array de Memos para Resposta Aberta.	              			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360Resposta(	aResposta	,cTpObj		,oScroll	,aControl,;
						cIdResp		,aAreaPanel	,cMemoResp	,oMemoResp,;
						nItems      ,aMemos )

Local nResposta	:= 0					// Controle das respostas
Local nTop      := 50					// Posicicao para criacao dos objetos

Local aSaveResp := aClone(aResposta)	// Efetua backup das resposta para restauracao posterior.

Local bVar		:= {||}        			// Execblock
Local cControl  := ""					// Utilizado para calcular a linha da observa็ใo com maior tamanho

//Detalhes do Radio
Local oRadio	:= Nil					// Objeto RADIO da resposta
Local aIdResp 	:= {}					// Array icn os Textos das respostas
Local aIdMemo	:= {}					// Array com os Ids de Memo
Local nCont		:= 0					// Variavel auxiliar
Local nPos      := 0					// Variavel auxiliar
Local nFoundMM  := 0					// Variavel auxiliar

//Detalhes do CheckBox
Local aRespAux	:= {}					// Array utilizada para auxiliar no tratamento da resposta
Local oCheck	:= Nil  				// Objeto de CHEKBOX
Local oGet		:= Nil					// Objeto para o GET
Local cIdAnswer := ""					// Codigo da Resposta - Codigo do Cargo (TREE)
Local cAnswer   := ""					// Descricao da Resposta
Local nHeight   := 0					// Calculo da ALTURA
Local nWidth    := 0					// Calculo da LARGURA
Local nMaxWidth	:= 0					// Calculo da LARGURA mแxima
Local nTopAsk   := 0    				// Calculo do TOP
Local nString   := 0					// Contador
Local aString   := {}					// Se a resposta for muito grande ela serแ quebrada nessa array
Local bWhen     := {|| .T.} 			// Habilita get

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o tipo de objeto a ser criado ้ Multipla Escolha, jแ    ณ
//ณcalcula o tamanho mแximo da resposta, assim os complementosณ
//ณserใo apresentados de forma alinhada.                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (cTpObj == "2")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalcula o tamanho mแximo das respostas.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nCont:=1 To Len(aResposta)
		nMaxWidth := Max(Tk360CalcWidth(Alltrim(aResposta[nCont][2])+Space(5),aAreaPanel[3]), nMaxWidth)
	Next nCont	
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual o tipo do objeto a ser criado para cada resposta.ณ
//ณ1 - Radiobutton (Unica Escolha)                                ณ
//ณ2 - Checkbox (Multipla Escolha)                                ณ
//ณ3 - Memo (Dissertativa)                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (cTpObj == "3")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria um memo para a inclusao da resposta do cliente.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Tk360MemRes(@nTop,oScroll,@aControl,cIdResp,aAreaPanel)
	
Else
	
	For nResposta:= 1 To Len(aResposta)
		
		Do Case
			
			Case (cTpObj == "1") //Unica Escolha (Radio)
							
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria um radio unico com todas as respostas da pergunta.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Aadd(aMemos,{ ("oMemoRadio"+Alltrim(Transform(nItems,"99"))),""}) //Criacao de memos de acordo com a quantidade de panels
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAdiciona o objeto no array de controle			  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				/*
				ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				ณ1 - Id da Pergunta																		 ณ
				ณ2 - Id da Resposta																		 ณ
				ณ3 - Conteudo do Checkbox (.T. ou .F.)													 ณ
				ณ4 - Numero da Opcao do Radio Selecionado												 ณ
				ณ5 - Texto da resposta dissertativa														 ณ
				ณ6 - Texto do get de Complemento de Resposta											 ณ
				ณ7 - Tipo de objeto (C - Checkbox, R - Radiobutton M - Memo)							 ณ
				ณ																						 ณ
				ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				*/
				AAdd(aControl,{ cIdResp,;
									NIL,;
									NIL,;
									NIL,;
									Space(255),;
									NIL,;
									"R"})
				
				nPos := Len(aControl)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica o tamanho da string para ajusta-la		  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				aIdResp:= aClone(aResposta)
				For nCont := 1 TO LEN(aResposta)
					Aadd(aIdMemo,aResposta[nCont][5])
				Next nCont
				
				AEval(aResposta,{|x| x := x[2],nWidth:= MAX(GetTextWidth(0,x)/1.5,nWidth)})
				
				nWidth   := IIf(nWidth > 200,200,nWidth)
				
				aControl[Len(aControl)][4]:= 0
				cControl := AllTrim(Str(Len(aControl)))
				
				bVar     := &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][4],aControl["+cControl+"][4]:=x) }" )
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria um radiobutton para cada resposta da pergunta ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				/*
				
				Radio criado atraves do construtor devido a utilizacao do bloco de codigo.
				
				[ <oRadMenu> := ] TRadMenu():New(<nRow>, <nCol>, {<cItems>},;
												[bSETGET(<nVar>)], <oWnd>, [{<nHelpId>}], <{uChange}>,;
												<nClrFore>, <nClrBack>, <cMsg>, <.update.>, <{uWhen}>,;
												<nWidth>, <nHeight>, <{uValid}>, <.lDesign.>, <.lLook3d.>, <.lPixel.> )
				*/
				
				
				oRadio:= TRadMenu():New( 	nTop, 10, aResposta,;
											bVar, oScroll , NIL, {||(	Tk360ItemMemo(@cMemoResp,@oMemoResp,,aIDMemo,oRadio:nOption),;		//observacao da REPOSTA - Cadastro
											Tk360DesMemo(aResposta,@aMemos[nItems][1],oRadio:nOption))},; //Habilita/Desabilita o MEMO de RADIO
											CLR_BLUE, NIL, NIL, .F., {||.T.},;
											nWidth, 10, NIL, .F., .T., .T. )
				
				oRadio:bChange 	:= {||	Tk360ItemMemo(@cMemoResp,@oMemoResp,,aIdMemo,oRadio:nOption),;
				Iif(Ascan(aResposta,{|x| ALLTRIM(x) == UPPER(STR0008)})>0,(Tk360DesMemo(aResposta,@aMemos[nItems][1],oRadio:nOption)),"")} //"RESPOSTA ABERTA"
				
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAjusta o TOP do proximo objeto.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nTop+= 10
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria o objeto MEMO quando a descricao for "RESPOSTA ABERTA"ณ
				//ณNesse memo quando houver uma alteracao da descricao o ARRAYณ
				//ณsera atualizado na 5 posicao - Resposta Dissertativa       ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				Tk360CriaMemo(@aMemos,nTop,oScroll,aResposta,@aControl, nItems)
				
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica se existem respostas abertas, que caracterizam a criacao do objeto Memo para que a funcao de   ณ
				//ณabaixo seja executada.                      															   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nFoundMM := Ascan(aResposta,{|x| ALLTRIM(x) == UPPER(STR0008)})  //RESPOSTA ABERTA //"RESPOSTA ABERTA"
				If nFoundMM > 0
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณHabilita e desabilita o MEMO do RADIO                      ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					Tk360DesMemo(aResposta,@aMemos[nItems][1] ,oRadio:nOption)
					
				Endif	
				
				Exit
				
			Case (cTpObj == "2") //Multipla Escolha (Checkbox)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณReinicia as variแveis.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				aRespAux	:= aClone(aResposta[nResposta])		// Array com a resposta que serแ tratada
				cControl	:= ""								// N๚mero do controle
				cIdAnswer	:= ""								// Codigo da Resposta - Codigo do Cargo (TREE)
				cAnswer		:= ""								// Descricao da Resposta
				nHeight		:= 0								// Calculo da ALTURA
				nWidth		:= 0								// Calculo da LARGURA
				nTopAsk		:= 0								// Calculo do TOP
				nString		:= 0								// Contador
				aString		:= {}								// Texto da resposta dividido. Cada posi็ใo cont้m uma string com o mแximo permitido de caracteres.
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria um checkbox para cada resposta das perguntas.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cIdAnswer:= aRespAux[1]											// Codigo do Cargo (TREE)
				cAnswer	 := AllTrim(aRespAux[2])								// Descricao da Resposta
				nHeight  := Tk360CalcHeight(cAnswer,@aString,aAreaPanel[3])	// Calcula a ALTURA
				nWidth   := Tk360CalcWidth(cAnswer+Space(5),aAreaPanel[3])		// Calcula a LARGURA
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAdiciona o objeto no array de controle.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Aadd(aControl,{cIdResp,cIdAnswer,NIL,NIL,NIL,Space(40),"C"})
				
				cControl := AllTrim(Str(Len(aControl)))
				
				aControl[Len(aControl)][3]:= .F.
				
				bVar     := &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][3],aControl["+cControl+"][3]:=x) }" )
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria um checkbox para cada resposta da pergunta.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				/* 

				CheckBox criado atraves do construtor devido a utilizacao do bloco de codigo devido a criacao dinamica.

				 [ <oCbx> := ] TCheckBox():New(  <nRow>, <nCol>, <cCaption>,;
													[bSETGET(<lVar>)], <oWnd>, <nWidth>, <nHeight>, <nHelpId>,;  //Largura Altura
													[<{uClick}>], <oFont>, <{ValidFunc}>, <nClrFore>, <nClrBack>,;
													<.design.>, <.pixel.>, <cMsg>, <.update.>, <{WhenFunc}> )
				*/
				
				oCheck   := TCheckBox():New(	nTop, 10, aString[1],;
												bVar, oScroll, nWidth, 10, NIL,;
												&('{||Tk360ItemMemo(@cMemoResp,@oMemoResp,"'+aRespAux[5]+'")}'), NIL, NIL, CLR_BLUE, NIL,;
												.T., .T., NIL, .F., {||.T.} )
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe a RESPOSTA for muito grande, quebra em varias linha ณ
				//ณutilizando-se do Checbox para a primeira linha e do Sayณ
				//ณpara as outras linhas.                                 ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nTopAsk:= nTop
				For nString:= 2 To Len(aString)
					
					nTopAsk += 10
					
				Next nString
				
				If aRespAux[4] == "1"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณCria um get para as respostas complementares.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					aControl[Len(aControl)][6]:= Space(150)
					bVar:= &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][6],aControl["+cControl+"][6]:=x) }" )
				
					/*                      
					
					Get criado atraves do construtor devido a utilizacao do bloco de codigo.
					
					[ <oGet> := ] TGet():New( 	<nRow>, <nCol>, bSETGET(<uVar>),;
												[<oWnd>], <nWidth>, <nHeight>, <cPict>, <{ValidFunc}>,;
												<nClrFore>, <nClrBack>, <oFont>, <.design.>,;
												<oCursor>, <.pixel.>, <cMsg>, <.update.>, <{uWhen}>,;
												<.lCenter.>, <.lRight.>,[\{|nKey, nFlags, Self| <uChange>\}], <.readonly.>,;
												<.pass.>, [<.lNoBorder.>], <nHelpId> )
					*/
	
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe a resposta utilziar complemento  cria o get para complemento de respostas.     ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						oGet:= TGet():New( 	nTop, nMaxWidth, bVar,;
											oScroll, TamSX3("UK_COMPRES")[1], 6, "@!", NIL,;
											NIL, NIL, NIL, .F.,;
											NIL, .T., NIL, .F., bWhen,;
											.F., .F., NIL, .F., .F., NIL, NIL)
						
				EndIf
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAjusta o Top do proximo objeto.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nTop+= nHeight
		EndCase
		
	Next nResposta
Endif

aResposta := aClone(aSaveResp)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360ItemMemo   ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os textos nos memos para apresentacao.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                          			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณEXPC1:Variavel do objeto memo.                               			บฑฑ
ฑฑบ          ณEXPO2: Objeto memo de resposta.                              			บฑฑ
ฑฑบ          ณEXPC3: Texto para Memo.                                      			บฑฑ
ฑฑบ          ณEXPC4: Array com todos os textos de memo. Param. utilizado pelo radio.บฑฑ
ฑฑบ          ณEXPC5: Posicao selecionada no radio e que sera a mesma do array de memบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360ItemMemo(cMemoResp,oMemoResp,cMemoItem,aIdMemo,nPos)

cMemoResp:= ""		//Texto para memos
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAvalia se o array de memos esta preenchido.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If (aIdMemo) <> NIL
	cMemoResp := aIdMemo[nPos]
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o Memo de auxilio. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf  !Empty(cMemoItem)
	cMemoResp:= cMemoItem
Endif

oMemoResp:Refresh()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360MemRes     ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria os Memos para respostas dissertativas.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                          			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1: Coodenada para criacao do objeto.                     			บฑฑ
ฑฑบ          ณEXPO2: Objeto Scroll.                                        			บฑฑ
ฑฑบ          ณEXPA3: Array de controle das respostas informadas.           			บฑฑ
ฑฑบ          ณEXPC4: Id de controle da resposta (cargo)                   			บฑฑ
ฑฑบ          ณEXPA5: Coordenada para Panel.                                			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360MemRes(nTop,oScroll,aControl,cIdResp,aAreaPanel)

Local oMemo										//Objeto MEMO
Local bVar										//Execblock
Local cControl := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona o objeto no array de controle.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aControl,{cIdResp,NIL,NIL,NIL,Space(255),NIL,"M"})

nWidth   := aAreaPanel[3] - 15
nHeigth  := aAreaPanel[4] - nTop - 15
cControl := AllTrim(Str(Len(aControl)))
aControl[Len(aControl)][5]:= ""
bVar     := &( "{|x|If(ValType(x)=='U',aControl["+cControl+"][5],aControl["+cControl+"][5]:=x) }" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um memo para que possa ser armazenado a resposta dada  pelo   ณ
//ณcliente, ja que esta pergunta nใo possui respostas pre-formatadas  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
  MultiGet criado atraves do construtor devido a utilizacao do bloco de codigo e criacao dinamica.

   [ <oGet> := ] TMultiGet():New( <nRow>, <nCol>, bSETGET(<uVar>),;
									[<oWnd>], <nWidth>, <nHeight>, <oFont>, <.hscroll.>,;
									<nClrFore>, <nClrBack>, <oCursor>, <.pixel.>,;
									<cMsg>, <.update.>, <{uWhen}>, <.lCenter.>,;
									<.lRight.>, <.readonly.>, <{uValid}>,;
									[\{|nKey, nFlags, Self| <uChange>\}], <.lDesign.>,;
									[<.lNoBorder.>], [<.lNoVScroll.>] )

*/

oMemo:=	TMultiGet():New( 	nTop, 10, bVar,;
							oScroll, nWidth, nHeigth, NIL, .F.,;
							NIL, NIL, NIL, .T.,;
							NIL, .F., {||.T.}, .F.,;
							.F., NIL, NIL,;
							NIL, .F., NIL, NIL)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAjusta o TOP do proximo objeto.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTop:= nTop + 10

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360DesMemo    ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณHabilita e dasabilita os Memos de respostas abertas de acordo com a   บฑฑ
ฑฑบ          ณselecao do radio.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                          			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1: Array com as respostas disponiveis.                   			บฑฑ
ฑฑบ          ณEXPO2: Objeto Memo.                                          			บฑฑ
ฑฑบ          ณEXPN3: Selecao do radio.                                     			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function Tk360DesMemo(aResposta,oMemoRadio,nSel)

Local nContFor:= 0  // variavel auxiliar.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a existe resposta aberta.                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

nContFor := Ascan(aResposta,{|x| ALLTRIM(x) == UPPER(STR0008)}) //"RESPOSTA ABERTA"


If nContFor > 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se a resposta aberta foi selecionada.                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If nContFor == nSel
		oMemoRadio:Enable()
		oMemoRadio:SetFocus()
	Else
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSo permite a digitacao se usuario escolher o RADIO desse MEMO (o ultimo)ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oMemoRadio:Disable()
	Endif
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK360CriaMemoบAutorณVendas Clientes    บ Data ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o objeto Memo para as respostas abertas de Scripts    บฑฑ
ฑฑบ          ณde atendimento.                                             บฑฑ
ฑฑบ          ณ  O objeto memo e proveniente de um array pois a quantidade บฑฑ
ฑฑบ          ณde panels sao indefinidas de acordo com o cadastro.         บฑฑ
ฑฑบ          ณ  Para cada objeto MEMO existira uma posicao no array aMemosบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aMemos: Array com os objetos e Variaveis  dos MEMOS.       บฑฑ
ฑฑบ          ณ          aMemos[1]- objeto                                 บฑฑ
ฑฑบ          ณ          aMemos[2]- Conteudo do Memo                       บฑฑ
ฑฑบ          ณ nTop    :Variavel contendo a posicao TOP do primeiro Radio บฑฑ
ฑฑบ          ณ         do Panel                                           บฑฑ
ฑฑบ          ณoScroll: Panel                                              บฑฑ
ฑฑบ          ณaResposta: Array com os textos dos RADIOS.                  บฑฑ
ฑฑบ          ณaControl : Array de controle das acoes no Panel.            บฑฑ
ฑฑบ          ณnItems   : Panel para criacao do objeto.                    บฑฑ
ฑฑบ          ณnOpc     : Opcao selecionada no Menu.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360CriaMemo(	aMemos		,nTop	,oScroll	,aResposta,;
						aControl	,nItems)//nItems = panel
Local nContFor:= 0		//Variavel auxiliar do for


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se nas respostas do Panel existe a descricao RESPOSTA ABERTA.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

nContFor := Ascan(aResposta,{|x| ALLTRIM(x) == UPPER(STR0008)}) //"RESPOSTA ABERTA"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe existir uma resposta aberta cria o Memo para esta resposta.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nContFor > 0
	@ nTop+(Len(aResposta)*10), 10 GET (aMemos[nItems][1]) VAR  aMemos[nItems][2] OF oScroll MULTILINE   SIZE 250, 40 PIXEL VALID aControl[nItems][5] := aMemos[nItems][2]
	
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360CalcHeight ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a altura dos objetos.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico                                                     			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1: Texto                                                 			บฑฑ
ฑฑบ          ณEXPO2: Array de textos.                                      			บฑฑ
ฑฑบ          ณEXPN3: Largura possivel.                                     			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360CalcHeight(cCaption,aString,nWidthArea)

Local nHeight:= 0		//ALTURA
Local nWidth := 0		//LARGURA
Local nTam   := 0		//TAMANHO
Local cAux   := ""		//Variavel de auxilio

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula a altura dos objetos a serem criados para o script de pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nWidth:= GetTextWidth(0,cCaption)
nWidthArea+= (nWidthArea * 1.5)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o tamanho da string for maior que o tamanho maximo permitido, quebra a string em varias linhas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nWidth > nWidthArea)
	
	For nTam:= 1 To Len(cCaption)
		cAux+= SubStr(cCaption,nTam,1)
		
		If (GetTextWidth(0,cAux) >= nWidthArea)
			Aadd(aString,cAux)
			cAux:= ""
		Endif
	Next nTam
	
	Aadd(aString,cAux)
	nHeight:= 10 * Len(aString)
Else
	Aadd(aString,cCaption)
	nHeight:= 10
Endif

Return(nHeight)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360CalcWidth  ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a altura dos objetos.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico                                                     			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1: Texto                                                 			บฑฑ
ฑฑบ          ณEXPN2: Largura possivel.                                     			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360CalcWidth(cCaption,nWidthArea)

Local nWidth := 0		//LARGURA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula a altura dos objetos a serem criados para o script de pesquisa ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nWidth	:= GetTextWidth(0,cCaption)
nWidthArea += (nWidthArea * 4)

If nWidth > nWidthArea
	nWidth	:= nWidthArea
Else
	nWidth	:= nWidth
Endif

Return(nWidth)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360Show       ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe Panel com objetos.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                          			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1:  Botao selecionado.                                       		บฑฑ
ฑฑบ          ณEXPA2:  Array com os panel para exibicao.                     		บฑฑ
ฑฑบ          ณEXPN3:  Panel posicionado.                                      		บฑฑ
ฑฑบ          ณEXPO4:  Objeto do botao voltar.                               		บฑฑ
ฑฑบ          ณEXPO5:  Objeto do botao avancar.                              		บฑฑ
ฑฑบ          ณEXPA6:  Array com os itens para exibicao.                     		บฑฑ
ฑฑบ          ณEXPO7:  Objeto tree.                                          		บฑฑ
ฑฑบ          ณEXPA8:  Array de controle.                                    		บฑฑ
ฑฑบ          ณEXPC9:  Variavel para objeto memo da pergunta.                		บฑฑ
ฑฑบ          ณEXPO10: Objeto Memo de pergunta.                              		บฑฑ
ฑฑบ          ณEXPC11:  Variavel para objeto memo da resposta.                		บฑฑ
ฑฑบ          ณEXPC12: Objeto Memo das respostas .                              		บฑฑ
ฑฑบ          ณEXPO13: Variavel de controle da pontuacao do score             		บฑฑ
ฑฑบ          ณEXPC14: Objeto para atualizacoa do Score.                        		บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360Show(	nAction		,aPanel		,nPanel   	,oAnterior,;
					oProximo	,aScript	,oTreeSimu	,aControl,;
					cMemoAsk	,oMemoAsk	,cMemoResp	,oMemoResp,;
					cScore      ,oScore)

Local nWindow	:= nPanel		//Indica o panel
Local nI		:= 0            //Controle de contador
Local lNext		:= .F.			//Flag de controle
Local lNotChg   := .F.			//Variแvel de controle para troca de panel. Caso Nao seja
//selecionada nenhuma resposta nao podera ser selecionado o botใo Next.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual o panel que devera ser ativo, habilita e desabilita o atualณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHabilita o primeiro panel pois e a tela inicial ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case ( nAction == 0 )
		For nI := 2 To Len(aPanel)
			aPanel[nI]:Hide()
		Next nI
		
		aPanel[1]:Show()
		oAnterior:Disable()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณHabilita o panel ANTERIOR ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case ( nAction == 1 )
		Tk360Prev(@nWindow,aScript,aControl)
		oProximo:Enable()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณHabilita o PROXIMO panel  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case ( nAction == 2 )
		lNext := Tk360Next(@nWindow,aScript,aControl,@lNotChg)
		oAnterior:Enable()
		
EndCase



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nenhuma resposta for informada o panel nao sera alterado.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lNotChg
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ฟ
	//ณHabilita/Desabilita os botoes <<Voltar e >>Avancar.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ู
	If ( nWindow >= Len(aPanel) ) .OR. (lNext .AND. nPanel == nWindow)
		If !(lNext .AND. nPanel == nWindow)
			nWindow := Len(aPanel)
		Endif
		oProximo:Disable()
		oProximo:Refresh()
	Endif
	
	If ( nWindow <= 1 ) 
		nWindow := 1
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณHabilita o botao Voltar caso o usuario esteja no primeiro painel e nao ณ
		//ณexistam perguntas a serem executadas para a resposta selecionada.      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nAction == 2 //Botao Avancar
			oAnterior:Enable()
			oAnterior:Refresh()
		Else
			oAnterior:Disable()
			oAnterior:Refresh()
		Endif	
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o Memo da Pergunta ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMemoAsk:= ""
	If !Empty(aScript[nWindow,4])
		cMemoAsk:= aScript[nWindow,4]
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLimpa o Memo da Resposta    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMemoResp:= ""
	oMemoAsk:Refresh()
	oMemoResp:Refresh()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza os dados do historico das perguntas ja respondidas ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Tk360SiTree(nPanel,aScript,@oTreeSimu,aControl,@cScore,@oScore)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHabilita/Desabilita os panels. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aPanel[nPanel]:Hide()
	aPanel[nWindow]:Show()
	
	nPanel := nWindow
Endif
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360SiTree     ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza Tree de Simulacao com as respostas ja dadas.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                          			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1:  Painel posicionado.                                      		บฑฑ
ฑฑบ          ณEXPA2:  Array com os dados do Tree.                           		บฑฑ
ฑฑบ          ณEXPO3:  Objeto do Tree.                                         		บฑฑ
ฑฑบ          ณEXPA4:  Array com os controles de respostas.                  		บฑฑ
ฑฑบ          ณEXPO5:  Variavel de controle do score.                          		บฑฑ
ฑฑบ          ณEXPA6:  Objeto para score.                                    		บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360SiTree(	nPanel	,aScript	,oTreeSimu	,aControl,;
						cScore	,oScore)

Local nControl  := 0		//Controle da pergunta
Local nItem     := 0		//Laco do array aScript que possui os itens do tree.
Local nScore    := 0		//Score
Local nResposta := 0		//Controle das respostas
Local cAsk      := ""		//Texto da Pergunta
Local cAnswer   := ""		//Texto da Resposta
Local cCodAsk   := ""		//Codigo da pergunta
Local cCodAnswer:= ""		//codigo da resposta
Local cCodPai   := ""		//Codigo da pergunta pai
Local cTipoObj  := ""		//Tipo do objeto selecionado
Local lFirst    := .T.		//Flag de controle

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa o tree.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTreeSimu:Reset()
oTreeSimu:BeginUpdate()
CursorWait()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ฟ
//ณMonta o tree atraves do array com todas as perguntas e respostas.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ู
For nItem:= 1 To Len(aScript)
	cCodPai := aScript[nItem][1]
	cCodAsk := aScript[nItem][2]
	cAsk    := aScript[nItem][3]
	cTipoObj:= aScript[nItem][5]
	lFirst  := .T.
	
	Do Case
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe a resposta for um radiobutton verifica qual a opcao que foiณ
		//ณmarcada para montar o tree.                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case (cTipoObj == "1")        //RadioButton
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se existe a pergunta. ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nControl:= Ascan(aControl,{|aVal| aVal[1]== cCodAsk})
			If (nControl > 0)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica se foi selecionado alguma resposta.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nResposta:= aControl[nControl][4]
				If(nResposta > 0)
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAdiciona a Pergunta no Tree.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If oTreeSimu:TreeSeek(cCodPai)
						oTreeSimu:AddItem(Alltrim(cAsk) , cCodAsk, "FOLDER7","FOLDER8", , ,2)
					ElseIf (cCodPai=='0000000')
						oTreeSimu:AddItem(Alltrim(cAsk)+Space(10) , cCodAsk, "FOLDER7","FOLDER8", , ,1)
					Endif
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAdiciona a Resposta no Tree.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cCodAnswer:= aScript[nItem][6][nResposta][1]
					cAnswer   := AllTrim(aScript[nItem][6][nResposta][2])
					nScore    += aScript[nItem][6][nResposta][3]
					
					If oTreeSimu:TreeSeek(cCodAsk)
						oTreeSimu:AddItem(Alltrim(cAnswer),cCodAnswer, "FOLDER12","FOLDER13", , ,2)
					Endif
				Endif
			Endif
			
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe a resposta for um checkbox, exibe todas as respostasณ
			//ณque foram selecionadas.                                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case (cTipoObj == "2")        //Checkbox
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica quais as respostas que foram selecionadas.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nControl:= 1 To Len(aControl)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica se existe a pergunta. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If (aControl[nControl][1] == cCodAsk) .AND. aControl[nControl][3]
					nResposta:= Ascan(aScript[nItem][6],{|aVal| aVal[1]== aControl[nControl][2]})
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica se a resposta foi selecionada.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If (nResposta > 0)
						
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณImprime a peregunta somente uma vez.ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If lFirst
							
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณAdiciona a Pergunta no Tree.ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							If oTreeSimu:TreeSeek(cCodPai)
								oTreeSimu:AddItem(Alltrim(cAsk) , cCodAsk, "FOLDER7","FOLDER8", , ,2)
							Else
								oTreeSimu:AddItem(Alltrim(cAsk) , cCodAsk, "FOLDER7","FOLDER8", , ,1)
							Endif
							
							lFirst:= .F.
						Endif
						
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณAdiciona a Resposta no Tree.ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						cCodAnswer:= aScript[nItem][6][nResposta][1]
						cAnswer   := AllTrim(aScript[nItem][6][nResposta][2]) + " - "  + Alltrim(aControl[nControl][6])
						nScore    += aScript[nItem][6][nResposta][3]
						
						oTreeSimu:TreeSeek(cCodAsk)
						oTreeSimu:AddItem(Alltrim(cAnswer),cCodAnswer, "FOLDER12","FOLDER13", , ,2)
					Endif
				Endif
				
			Next nControl
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe a resposta for um memo exibe o que foi informado peloณ
			//ณcontato.                                                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Case (cTipoObj == "3")         //Memo
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se existe a pergunta. ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nControl:= Ascan(aControl,{|aVal| aVal[1]== cCodAsk})
			If (nControl > 0)
				If !Empty(aControl[nControl][5])
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAdiciona a Pergunta no Tree.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If oTreeSimu:TreeSeek(cCodPai)
						oTreeSimu:AddItem(Alltrim(cAsk) , cCodAsk, "FOLDER7","FOLDER8", , ,2)
					Else
						oTreeSimu:AddItem(Alltrim(cAsk) , cCodAsk, "FOLDER7","FOLDER8", , ,1)
					Endif
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAdiciona a Resposta no Tree.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cCodAnswer:= "M" + cCodAsk
					cAnswer   := AllTrim(aControl[nControl][5])
					nScore    += 0
					
					oTreeSimu:TreeSeek(cCodAsk)
					oTreeSimu:AddItem(Alltrim(cAnswer),cCodAnswer, "FOLDER12","FOLDER13", , ,2)
				Endif
			Endif
	EndCase
Next nItem

cScore:= AllTrim(Str(nScore))
oScore:Refresh()

oTreeSimu:EndUpdate()
CursorArrow()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360Next       ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAvanca panel                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                          			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1:  Painel posicionado.                                      		บฑฑ
ฑฑบ          ณEXPA2:  Array com os dados do Tree.                           		บฑฑ
ฑฑบ          ณEXPA3:  Array com os controles de respostas.                  		บฑฑ
ฑฑบ          ณEXPl4:  Flag que define se houve alteracao no objeto.         		บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360Next(nPanel,aItems,aControl,lNotChg)

Local nPos    := 0		//Variavel de auxilio, com base nesta variavel sera definido o proximo panel a ser exibido.
Local cSup    := ""		//Armazena a resposta efetuada.
Local nControl:= 0		//Contador
Local nOpcao  := 0      //Opcao selecionada.
Local nItem	  := 0 		//Contador
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual o proximo panel a ser exibido.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (M->UZ_FORMATO == PESQUISA)
	nPanel ++
Else
	
	For nControl:= 1 To Len(aControl)//Array de controle dos itens das respostas
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPesquisa em todas as perguntas a resposta efetuada atrav้s do ID que define a amarracao(aControl[X][1] )         ณ
		//ณPesquisa com base no panel (aControl[nPanel][1]) ja que os panels possuem a mesma ordem de criacao das perguntas.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		nPos:= Ascan(aItems,{|aVal| aVal[2]== aControl[nPanel][1]})
		If (nPos > 0)
			nOpcao:= aControl[nPos][4]
			Exit
		Endif
		
	Next nControl
	
	If (nOpcao > 0 )
		
		cSup  := aItems[nPanel][6][nOpcao][1]
		
		
		For nItem:= 1 To Len(aItems)
			
			If (aItems[nItem][1] == cSup)
				nPanel:= nItem
				Exit
			Endif
			
		Next nItem
		
	Else
		Aviso(STR0010,STR0009,{"OK"}) //"ATENCAO"###"Selecione uma resposta para prosseguir com o Script."
		lNotChg := .T.
	Endif
	
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk360Prev       ณ  AutorณVendas Clientes         ณData  ณ  24/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVolta panel.                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ.T.                                                          			บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1:  Painel posicionado.                                      		บฑฑ
ฑฑบ          ณEXPA2:  Array com os dados do Tree.                           		บฑฑ
ฑฑบ          ณEXPA3:  Array com os controles de respostas.                  		บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8-Call Center-Cadastro de Script                          			บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk360Prev(nPanel,aScript,aControl)

Local nPos := 0		//Armazena se foi ou nao encontrada a pergunta vigente
Local cSup := ""	//Armazena o codigo pai
Local nItem:= 0		//controle do laco.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual o panel anterior.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (M->UZ_FORMATO == PESQUISA)
	nPanel --
Else
	cSup  := aScript[nPanel][1]
	
	For nItem:= 1 To Len(aScript)
		
		nPos:= Ascan(aScript[nItem][6],{|aVal| aVal[1] == cSup})
		If (nPos > 0)
			nPanel:= nItem
			Exit
		Endif
		
	Next nItem
	
Endif

Return(.T.)
