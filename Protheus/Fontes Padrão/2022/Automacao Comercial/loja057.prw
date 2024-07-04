#INCLUDE "Protheus.ch"
#INCLUDE "LOJA057.ch"

#DEFINE COL_RIGHT  		"column_right"
#DEFINE COL_CENTER 		"column_center"
#DEFINE COL_LEFT   		"column_left"
#DEFINE WND_SEARCH    	"wnd_search"
#DEFINE WND_BROWSE    	"wnd_browse"
#DEFINE WND_BROWSE02   	"wnd_browse02"
#DEFINE WND_OPERATIONS	"wnd_operations"
#DEFINE CLRTEXT			0
#DEFINE CLRBACK			12632256
#DEFINE CLRBACKCTR		16777215
#DEFINE TAMTOT			0
#DEFINE LRG_COL01		20 
#DEFINE LRG_COL02		70
#DEFINE LRG_COL03		10

Static lFWGetVersao 	:= FindFunction("GetVersao")
Static nAltBot			:= 015 
Static oGet01
Static lFlFilCorr		:= .F. // Filtro na filial corrente

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA057    บAutor  ณVendas Clientes       บ Data ณ07/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para consultar e editar confer๊ncia final de movimentos de บฑฑ
ฑฑบ          ณcaixa.                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LOJA057()

	Local oDlg
	Local oPanelSearch											//Painel de pesquisa
	Local oPanelSLT												//Painel de conferencias
	Local oPanelOp												//Painel de operacoes
	Local oBot01												//Botao de pesquisa
	Local oBot02												//Botao da conferencia
	Local oBot03												//Botao de fechamento
	Local oBot04												//Botใo de Detalhamento de vendas
	Local aCoors			:= FWGetDialogSize(oMainWnd)		//Coordenadas da tela
	Local lIsMDI 			:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) //Verifica se acessou via SIGAMDI
	Local lBotFecha			:= !(lIsMDI)						//Se a interface nao for MDI, exibir o botao fechar (icone canto direito superior)
	Local oFont01			:= tFont():New("Arial",,6,,.T.)		//Fonte
	Local aPergunte			:= {}								//Array para armazenar caracteristicas de cada campo do grupo de perguntas
	Local cAliasSLT			:= ""								//Alias temporario SLT
	Local cPerg				:= "LOJ057"							//Grupo de perguntas

	//Defini็ใo da variavel para controle do Robo de testes
	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	Static aCmpSLW 			:= {"LW_DTABERT","LW_OPERADO","LW_ESTACAO","LW_SERIE","LW_PDV","LW_NUMMOV","LW_NUMINI","LW_NUMFIM","LW_DTFECHA","LW_HRABERT",;
								"LW_HRFECHA"}
	Static aCmpSLT 			:= {"LT_FORMPG","LT_ADMIFIN","AE_DESC","LT_QTDE","LT_MOEDA","LT_VLRDIG","LT_VLRAPU","MBI_DESCRI"}

	Private oArea											//Area da tela
	Private aCfgSLT		:= {}
	Private oBrwSLW											//Browse da SLW
	Private aBrwSLT		:= {}								//Array com dados da SLT
	Private oBrwSLT											//Browse da SLT
	Private lConfCx		:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. IIf(FindFunction("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Utilizar conf. de fechamento
	Private lTrans		:= lConfCx .AND. SuperGetMV("MV_LJTRANS",.F.,.F.)	//Transferencia
	Private cTransNat	:= SuperGetMV("MV_LJTRNAT",.F.,"")	//Natureza da transferencia de portador
	Private lUsaMVD		:= SuperGetMV("MV_LJTRMVD",.F.,.F.)	//Utiliza detalhamento de movimento bancario da transferencia de caixas?
	Private aEstruSLT	:= {}
	Private oPanelSLW										//Painel de movimentos
	Private cStcSLT		:= GetNextAlias()					//Armazena estaticamente o alias temporario da SLT
	Private __oDlg  //Ariavel utilizada nas valida็๕es do Pergunte. Quando o pergunte nใo ้ na Dialog e sim no Panel, precisa ser declarada.

	cAliasSLT	:= cStcSLT


	//Se o pacote de conferencia de caixa nao estiver aplicado ou nao estiver ativo, sair
	If !lConfCx
		MsgAlert(STR0087)	//"Para que esta funcionalidade funcione, ้ necessแrio que a confer๊ncia de caixa esteja ativa (MV_LJCONFF) e que o compatibilizador UPDLOJ70 tenha sido aplicado!"
		Return Nil
	Endif
	//WS_VISIBLE e WS_POPUP sao codigo de controle contidos no include WINAPI
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL //"Conferencia final"

	oDlg:lMaximized := .T.
	oArea := FWLayer():New()
	oArea:Init(oDlg,lBotFecha)
	If oArea == Nil
		Return Nil
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPainel esquerdo : ณ
	//ณ1. Pergunte       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Painel01(oDlg,oArea,@oPanelSearch,@oBot01,@aPergunte,cPerg,@oPanelSLT,cAliasSLT)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFiltrar a SLW  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ExecFiltro(cPerg,"SLW","LW_FILIAL",aPergunte,,,.F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPainel central :  ณ
	//ณ1. Lista mov. SLW ณ
	//ณ2. Lista conf.SLT ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Painel02(oDlg,oArea,@oPanelSLW,@oPanelSLT,@oFont01,cAliasSLT)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPainel direito :  ณ
	//ณ1. Operacoes      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Painel03(oDlg,oArea,@oPanelOp,@oBot02,@oBot03,@oPanelSLT,cAliasSLT,@oBot04)

	If !lAutomato
		__oDlg := oDlg
		oDlg:Activate()
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLimpar os filtros  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SLW->(dbClearFilter())
	SLT->(dbClearFilter())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณPainel01   บAutor  ณVendas Clientes       บ Data ณ07/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para montar o painel de perguntas.                         บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Tela                                                   บฑฑ
ฑฑบ          ณExp02[O] : Area (FWLAYER)                                         บฑฑ
ฑฑบ          ณExp03[O] : Painel                                                 บฑฑ
ฑฑบ          ณExp04[O] : Botao                                                  บฑฑ
ฑฑบ          ณExp05[A] : Array de perguntas                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Painel01(oDlg,oArea,oPanelSearch,oBot,aPergunte,cPerg,oPanelSLT,cAliasSLT)

	Local cTitulo			:= STR0002 //"Pesquisa"
	Local cTitBot01			:= STR0003 //"Pesquisar"
	Local aTamObj			:= Array(4) //Dimensionamento da tela
	Local oPainelS01        := Nil //Painel do pergunte
	Local oPainelS02		:= Nil //Painel do botao de pesquisa

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriar painel do tipo PESQUISA ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArea:AddCollumn(COL_LEFT,LRG_COL01,.T.)
	oArea:SetColSplit(COL_LEFT,CONTROL_ALIGN_RIGHT)
	oArea:AddWindow(COL_LEFT,WND_SEARCH,cTitulo,100, .T., .F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefinir objeto de pesquisa    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPanelSearch := oArea:GetWinPanel(COL_LEFT,WND_SEARCH)

	//Painel 01 - Pergunte
	aTamObj[1] := 000
	aTamObj[2] := 000
	aTamObj[3] := (oPanelSearch:nClientHeight / 2) * 0.9
	aTamObj[4] := (oPanelSearch:nClientWidth / 2)

	oPainelS01 := TPanel():New(aTamObj[1],aTamObj[2],"",oPanelSearch,,.F.,.F.,,CLR_WHITE,aTamObj[4],aTamObj[3],.T.,.F.)

	Pergunte(cPerg,.T.,,,@oPainelS01,,@aPergunte,.T.,.F.) 

	//Painel 02 - Botao de pesquisa
	aTamObj[1] := (oPainelS01:nBottom / 2)
	aTamObj[2] := 000
	aTamObj[3] := (oPanelSearch:nClientHeight / 2) * 0.1
	aTamObj[4] := (oPanelSearch:nClientWidth / 2)

	oPainelS02 := TPanel():New(aTamObj[1],aTamObj[2],"",oPanelSearch,,.F.,.F.,,CLR_WHITE,aTamObj[4],aTamObj[3],.T.,.F.)

	//Botao de pesquisa
	aTamObj[1] := (oPainelS02:nHeight / 2) - nAltBot
	aTamObj[3] := nAltBot
	aTamObj[4] := ((oPainelS02:nWidth / 2) * 0.4)
	aTamObj[2] := (oPainelS02:nWidth / 2) - aTamObj[4]

	oBot := TButton():New(aTamObj[1],aTamObj[2],cTitBot01,oPainelS02,{|| ExecFiltro(cPerg,"SLW","LW_FILIAL",aPergunte,@oPanelSLT,cAliasSLT,.T.)},;
	aTamObj[4],aTamObj[3],,,.F.,.T.,.F.,,.F.,,,.F. )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณPainel02   บAutor  ณVendas Clientes       บ Data ณ07/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para montar o painel de movimentos e o de conferencia      บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Tela                                                   บฑฑ
ฑฑบ          ณExp02[O] : Area (FWLAYER)                                         บฑฑ
ฑฑบ          ณExp03[O] : Painel movimentos                                      บฑฑ
ฑฑบ          ณExp04[O] : Painel conferencias                                    บฑฑ
ฑฑบ          ณExp05[O] : Painel conferencia final                               บฑฑ
ฑฑบ          ณExp06[O] : Fonte                                                  บฑฑ
ฑฑบ          ณExp07[O] : Browse SLW                                             บฑฑ
ฑฑบ          ณExp08[O] : Browse SLT                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Painel02(oDlg,oArea,oPanelSLW,oPanelSLT,oFont01,cAliasSLT)

	Local cTitulo			:= STR0004 //"Movimentos de caixa"
	Local cTitulo02			:= STR0005 //"Confer๊ncias do movimento"
	Local aBotTexto			:= {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVisualizador SLW ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArea:AddCollumn(COL_CENTER,LRG_COL02,.T.)
	oArea:AddWindow(COL_CENTER,WND_BROWSE,cTitulo,50,.T.,.F.)
	oPanelSLW := oArea:GetWinPanel(COL_CENTER,WND_BROWSE)

	oBrwSLW	  := Lj057TSlw( .F. )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVisualizador SLT ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArea:AddWindow(COL_CENTER,WND_BROWSE02,cTitulo02,50,.T.,.F.)
	oPanelSLT := oArea:GetWinPanel(COL_CENTER,WND_BROWSE02)
	aBotTexto := {}
	AtuaConf(@oPanelSLT,SLW->(Recno()),,cAliasSLT)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento aplicado para quando o registro SLW for alterado  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oBrwSLW:bChange := {|| AtuaConf(@oPanelSLT,SLW->(Recno()),,cAliasSLT)}

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณPainel03   บAutor  ณVendas Clientes       บ Data ณ08/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para montar o painel de operacoes                          บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Tela                                                   บฑฑ
ฑฑบ          ณExp02[O] : Area (FWLAYER)                                         บฑฑ
ฑฑบ          ณExp03[O] : Painel                                                 บฑฑ
ฑฑบ          ณExp04[O] : Botao conferencia                                      บฑฑ
ฑฑบ          ณExp05[O] : Botao fechamento                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Painel03(oDlg,oArea,oPanelOp,oBotA,oBotB,oPanelSLT,cAliasSLT,oBotC)

	Local cTitulo			:= STR0006 //"Opera็๕es"
	Local cTitBot01			:= STR0007 //"Confer๊ncia"
	Local cTitBot02			:= STR0008 //"Fechar"
	Local aTamObj			:= Array(4) //Dimensionamento dos botoes

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriar painel do tipo OPERACAO ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArea:AddCollumn(COL_RIGHT,LRG_COL03,.T.)
	oArea:SetColSplit(COL_RIGHT,CONTROL_ALIGN_RIGHT)
	oArea:AddWindow(COL_RIGHT,WND_OPERATIONS,cTitulo,100, .T., .F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefinir objeto de pesquisa    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPanelOp := oArea:GetWinPanel(COL_RIGHT,WND_OPERATIONS)

	aTamObj[1] := 000
	aTamObj[2] := 000
	aTamObj[3] := nAltBot
	aTamObj[4] := (oPanelOp:nClientWidth / 2)

	//Botao Operacoes
	oBotA := TButton():New(aTamObj[1],aTamObj[2],cTitBot01,oPanelOp,{|| IIf(Lj057ExMov(),Lj057Conf(),.T.),oBrwSLW:Refresh(),AtuaConf(@oPanelSLT,SLW->(Recno()),,cAliasSLT)},;
	aTamObj[4],aTamObj[3],,,.F.,.T.,.F.,,.F.,,,.F. )

	//Exibir detalhamentos das formas de pagamentos.
	oBotC := TButton():New(aTamObj[1]+nAltBot+5,aTamObj[2],STR0088,oPanelOp,{|| IIf(Lj057ExMov(),DetVendas(),.T.)},; //#STR0088->"Det.Formas Pgtos"
	aTamObj[4],aTamObj[3],,,.F.,.T.,.F.,,.F.,,,.F. )

	//Botao Fechar
	aTamObj[1] := (oPanelOp:nClientHeight / 2) - nAltBot

	oBotB := TButton():New(aTamObj[1],aTamObj[2],cTitBot02,oPanelOp,{|| oDlg:End()},;
	aTamObj[4],aTamObj[3],,,.F.,.T.,.F.,,.F.,,,.F. )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLJ057Leg   บAutor  ณVendas Clientes       บ Data ณ07/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de legenda para o browse de movimentos                     บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Alias                                                  บฑฑ
ฑฑบ          ณExp02[N] : Registro                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณuRet[U] : Retorna filtro de legenda / Verdadeiro                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ057Leg(cAlias,nReg)

	Local aLegenda	:= {}
	Local uRet		:= .T.

	Default cAlias	:= "SLW"

	aAdd(aLegenda, {"BR_AZUL"		,STR0099	}) //Azul - #"Simplificado"
	aAdd(aLegenda, {"BR_AMARELO"	,STR0100	}) //Amarelo - #"Em Aberto"
	aAdd(aLegenda, {"BR_VERMELHO"	,STR0101	}) //Vermelho - #"Transferido/Pendente de Confer๊ncia"
	aAdd(aLegenda, {"BR_VERDE"		,STR0102	}) //Verde - #"Conferido"
	aAdd(aLegenda, {"BR_MARROM"		,STR0103	}) //Marrom - #"Subida incompleta"
	aAdd(aLegenda, {"BR_CINZA" 		,STR0104	}) //Cinza - #"Explosใo incompleta"
	aAdd(aLegenda, {"BR_PRETO"		,STR0105	}) //Preto - #"Problema na transfer๊ncia"

	cAlias := Upper(AllTrim(cAlias))
	Do Case 
		Case cAlias == "SLW"
		If nReg == Nil
			uRet := {}
			aAdd(uRet,{'IIf(Type("SLW->LW_TIPFECH")="U" .And. Type("SLW->LW_CONFERE")="U",.F., SLW->LW_TIPFECH  = "1" .And. SLW->LW_CONFERE = "2")' ,aLegenda[1][1]}) //Azul - #"Simplificado"
			aAdd(uRet,{'IIf(Type("SLW->LW_TIPFECH")="U" .And. Type("SLW->LW_CONFERE")="U",.F., SLW->LW_TIPFECH  = " " .And. SLW->LW_CONFERE = "1")' ,aLegenda[2][1]}) //Amarelo - #"Em Aberto"
			aAdd(uRet,{'IIf(Type("SLW->LW_TIPFECH")="U" .And. Type("SLW->LW_CONFERE")="U",.F., ((SLW->LW_TIPFECH  = "2" .And. SLW->LW_CONFERE <> "1") .Or. (SLW->LW_TIPFECH  = "1" .And. SLW->LW_CONFERE <> "2") .Or. (SLW->LW_TIPFECH  = "3" .And. SLW->LW_CONFERE <> "1")))',aLegenda[3][1]}) //Vermelho - "Transferido/Pendente de Confer๊ncia"
			aAdd(uRet,{'IIf(Type("SLW->LW_TIPFECH")="U" .And. Type("SLW->LW_CONFERE")="U",.F., (SLW->LW_TIPFECH  = "2" .Or. SLW->LW_TIPFECH  = "3") .And. SLW->LW_CONFERE = "1")' ,aLegenda[4][1]}) //Verde - Conferido
			aAdd(uRet,{'IIf(Type("SLW->LW_TIPFECH")="U",.F., SLW->LW_TIPFECH  = "4")',aLegenda[5][1]}) //Marrom - #"Subida incompleta"
			aAdd(uRet,{'IIf(Type("SLW->LW_TIPFECH")="U",.F., SLW->LW_TIPFECH  = "5")',aLegenda[6][1]}) //Cinza - #"Explosใo incompleta"
			aAdd(uRet,{'IIf(Type("SLW->LW_TIPFECH")="U",.F., SLW->LW_TIPFECH  = "6")',aLegenda[7][1]}) //Preto - #"Problema na transfer๊ncia"

		Else
			BrwLegenda(STR0011,STR0011,aLegenda,11) //"Legenda"###"Legenda"
		Endif
	EndCase

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณAtuaConf   บAutor  ณVendas Clientes       บ Data ณ07/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para atualizar o conteudo do browse de conferencias que    บฑฑ
ฑฑบ          ณesta atrelado ao de movimentos (SLW -> SLT)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Painel                                                 บฑฑ
ฑฑบ          ณExp02[N] : Registro                                               บฑฑ
ฑฑบ          ณExp03[L] : Refresh de lista (sem reposicionamento)                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AtuaConf(oPanel,nREG,lRefresh,cAlias)

	Local aAreaSLW			:= SLW->(GetArea())
	Local aAreaSX3			:= SX3->(GetArea())
	Local cFiltro			:= ""						//Filtro de pesquisa
	Local lQry				:= .F.						//Utilizar query
	Local cQry				:= ""						//Definicao da query
	Local ni				:= 0						//Contador
	Local nPos				:= 0						//Posicao
	Local lAtua				:= .F.						//Atualizacao
	Local cTMP				:= ""						//Variavel auxiliar
	Local aLstPict			:= ""						//Lista de pictures
	Local lEncReg			:= .F.						//Encontrou registros

	Default nREG 			:= 0
	Default lRefresh		:= .F.

	#IFDEF TOP
	lQry := !lQry
	#ENDIF
	//Validar configuracoes
	If Len(aCfgSLT) == 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEstrutura aCfgSLT :               ณ
		//ณ----------------------------------ณ
		//ณ[1] Campo                         ณ
		//ณ[2] Valor                         ณ
		//ณ[3] Picture                       ณ
		//ณ[4] Titulo                        ณ
		//ณ[5] Tamanho                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aEstruSLT := SLT->(dbStruct())
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		For ni := 1 to Len(aCmpSLT)
			If SX3->(dbSeek(Upper(AllTrim(aCmpSLT[ni]))))
				aAdd(aCfgSLT,Array(5))
				nPos := Len(aCfgSLT)
				aCfgSLT[nPos][1] := SX3->X3_CAMPO
				aCfgSLT[nPos][2] := SX3->X3_PICTURE
				Do Case
					Case Upper(AllTrim(aCmpSLT[ni])) == "MBI_DESCRI"
					aCfgSLT[nPos][3] := RetTitle("MBH_ACAO")
					OtherWise
					aCfgSLT[nPos][3] := X3Titulo()
				EndCase
				aCfgSLT[nPos][4] := SX3->X3_TAMANHO
				aCfgSLT[nPos][5] := SX3->X3_TIPO
			Endif
		Next ni
	Else
		lAtua := .T.
	Endif
	If Len(aCfgSLT) == 0
		Return Nil
	Endif

	If !lQry
		SLW->(dbGoto(nREG))
		//Caso o alias auxiliar nao esteja criado, criar
		If Select(cAlias) == 0
			ChkFile("SLT",.F.,cAlias)
		Endif
		dbSelectArea(cAlias)
		(cAlias)->(dbSetOrder(1))
		If Empty(nREG)
			cFiltro := "LT_FILIAL = 'ZZ'"
		Else
			cFiltro := "LT_FILIAL = '" + xFilial("SLT") + "' "
			cFiltro += ".AND. LT_OPERADO = '" + SLW->LW_OPERADO + "' "
			cFiltro += ".AND. LT_ESTACAO = '" + SLW->LW_ESTACAO + "' "
			cFiltro += ".AND. LT_PDV = '" + SLW->LW_PDV + "' "
			cFiltro += ".AND. DTOS(LT_DTFECHA) = '" + DtoS(SLW->LW_DTFECHA) + "' "
			cFiltro += ".AND. LT_NUMMOV = '" + SLW->LW_NUMMOV + "' "
			cFiltro += ".AND. DTOS(LT_DTMOV) >= '" + DtoS(SLW->LW_DTABERT) + "' .AND. DTOS(LT_DTMOV) <= '" + DtoS(SLW->LW_DTFECHA) + "' "
			cFiltro += ".AND. LT_CONFERE = '1' "
		Endif
		(cAlias)->(dbSetFilter({|| &cFiltro},cFiltro))
		(cAlias)->(dbGoTop())
	Else
		cQry := "SELECT DISTINCT LT_DTFECHA,"
		For ni := 1 to Len(aCfgSLT)
			If SLT->(FieldPos(aCfgSLT[ni][1])) > 0
				cQry += AllTrim(aCfgSLT[ni][1]) + ","
			Endif
		Next ni
		cQry := Substr(cQry,1,Rat(",",cQry) - 1) + " "
		cQry += "FROM " + RetSQLName("SLT") + " "
		cQry += "WHERE "
		If Empty(nREG)
			cQry += " LT_FILIAL = 'ZZ'"
		Else

			If lFlFilCorr
				cQry += " LT_FILIAL = '" + xFilial("SLT") + "' "
			Else
				cQry += " LT_FILIAL = '" + SLW->LW_FILIAL + "' "
			EndIf	
			cQry += "AND LT_OPERADO = '" + SLW->LW_OPERADO + "' "
			cQry += "AND LT_DTFECHA = '" + DtoS(SLW->LW_DTFECHA) + "' "
			cQry += "AND LT_ESTACAO = '" + SLW->LW_ESTACAO + "' "
			cQry += "AND LT_PDV = '" + SLW->LW_PDV + "' "
			cQry += "AND LT_NUMMOV = '" + SLW->LW_NUMMOV + "' "
			cQry += "AND LT_DTMOV BETWEEN '" + DtoS(SLW->LW_DTABERT) + "' AND '" + DtoS(SLW->LW_DTFECHA) + "' "
			cQry += "AND LT_CONFERE = '1' "
		Endif        
		cQry += " AND D_E_L_E_T_ = ' ' "
		cQry += "ORDER BY LT_FORMPG ASC,LT_ADMIFIN ASC,LT_MOEDA ASC"
		cQry := ChangeQuery(cQry)

		dbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAlias,.T.,.F.)

		//Ajustar os tipos de dados
		AjustaTC(cAlias,aEstruSLT)
	Endif
	aBrwSLT := {}
	If !(cAlias)->(Eof())
		lEncReg := .T.
		Do While !(cAlias)->(Eof())
			aAdd(aBrwSLT,Array(Len(aCfgSLT)))
			nPos := Len(aBrwSLT)
			For ni := 1 to Len(aBrwSLT[nPos])
				If (cAlias)->(FieldPos(aCfgSLT[ni][1])) > 0
					Do Case
						Case Upper(AllTrim(aCfgSLT[ni][1])) == "LT_MOEDA"
						aBrwSLT[nPos][ni] := SuperGetMV(AllTrim("MV_SIMB" + cValToChar((cAlias)->&(aCfgSLT[ni][1]))),.F.,"")
						OtherWise
						aBrwSLT[nPos][ni] := (cAlias)->&(aCfgSLT[ni][1])
					EndCase
				Else
					Do Case
						Case Upper(AllTrim(aCfgSLT[ni][1])) == "AE_DESC"
						aBrwSLT[nPos][ni] := IIf(Empty((cAlias)->LT_ADMIFIN),"",GetAdvFVal("SAE","AE_DESC",xFilial("SAE") + (cAlias)->LT_ADMIFIN,1))
						Case Upper(AllTrim(aCfgSLT[ni][1])) == "MBI_DESCRI"
						cTMP := ""
						If SLW->LW_CONFERE == "1"
							dbSelectArea("MBH")
							MBH->(dbSetOrder(1))	//MBH_FILIAL+MBH_OPERAD+DTOS(MBH_DATA)+MBH_FORMPG+MBH_PDV+MBH_NUMMOV+MBH_ADMFIN
							If MBH->(dbSeek(xFilial("MBH") + SLW->LW_OPERADO + DtoS((cAlias)->LT_DTFECHA) + (cAlias)->LT_FORMPG + ;
							SLW->(LW_PDV + LW_NUMMOV) + (cAlias)->LT_ADMIFIN))

								If !Empty(MBH->MBH_ACAO)
									cTMP := GetAdvfVal("MBI","MBI_DESCRI",xFilial("MBI") + MBH->MBH_ACAO,1)
								Endif							
							Endif
						Endif
						aBrwSLT[nPos][ni] := cTMP
						OtherWise
						aBrwSLT[nPos][ni] := ""
					EndCase				
				Endif
			Next ni
			(cAlias)->(dbSkip())
		EndDo
	Else
		aAdd(aBrwSLT,Array(Len(aCfgSLT)))
	Endif
	If ValType(oPanel) == "O"
		If !lAtua .OR. ValType(oBrwSLT) # "O"
			oBrwSLT := MntBrwWnd(@oPanel,,aBrwSLT,0,0,0,0,aCfgSLT,,,.F.,,,,.F.,.F.,,,,.T.)
		Endif
		oBrwSLT:SetArray(aBrwSLT)
		If ValType(oBrwSLT) == "O"
			Eval({|| aLstPict := {},aEval(aCfgSLT,{|x| aAdd(aLstPict,RTrim(x[2]))})})
			//Definir as linhas utilizadas no browse e sua formatacao
			oBrwSLT:bLine := &(LjBrwLine(oBrwSLT,"aBrwSLT","oBrwSLT",IIf(lEncReg,aLstPict,{}),.T.))
			oBrwSLT:Refresh()
		Endif		
	Endif
	If lQry
		FechaArqT(cAlias)
	Endif
	RestArea(aAreaSLW)
	RestArea(aAreaSX3)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMntBrwWnd  บAutor  ณVendas Clientes       บ Data ณ07/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para montar um browse contido em uma janela                บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Painel                                                 บฑฑ
ฑฑบ          ณExp02[O] : Browse                                                 บฑฑ
ฑฑบ          ณExp03[C] : Alias                                                  บฑฑ
ฑฑบ          ณExp04[N] : Linha inicial                                          บฑฑ
ฑฑบ          ณExp05[N] : Coluna inicial                                         บฑฑ
ฑฑบ          ณExp06[N] : Linha final                                            บฑฑ
ฑฑบ          ณExp07[N] : Coluna final                                           บฑฑ
ฑฑบ          ณExp08[A] : Lista de campos desejado                               บฑฑ
ฑฑบ          ณExp09[A] : Array com os botoes de texto para FWButtonBar          บฑฑ
ฑฑบ          ณExp10[A] : Array com os botoes graficos para FWButtonBar          บฑฑ
ฑฑบ          ณExp11[L] : Utilizar as formatacoes de campo do dicionario         บฑฑ
ฑฑบ          ณExp12[N] : Coluna(s) que ficarao congelada(s) na exibicao         บฑฑ
ฑฑบ          ณExp13[A] : Classificacao por cabecalho (header)                   บฑฑ
ฑฑบ          ณExp14[A] : Array de legenda                                       บฑฑ
ฑฑบ          ณExp15[L] : Utilizar botoes padrao da enchoice                     บฑฑ
ฑฑบ          ณExp16[L] : Utilizar botao de legenda                              บฑฑ
ฑฑบ          ณExp17[C] : Expressao para legenda automatica                      บฑฑ
ฑฑบ          ณExp18[C] : Inicio do intervalo para o filtro                      บฑฑ
ฑฑบ          ณExp19[C] : Fim do intervalo para o filtro                         บฑฑ
ฑฑบ          ณExp20[L] : Indica se a operacao eh de atualizacao de lista apenas บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณoBrw[O] : Objeto do tipo TCBrowse                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MntBrwWnd(oPanel,oBrw,cAlias,nLin1,nCol1,nLin2,nCol2,aCampos,aBotTexto,aBotGraf,lDic,;
				nFreeze,aHeadOrd,aLegenda,lEnchBot,lLegBot,cFun,cTopFun,cBotFun,lRefresh)

	Local nButtonSize 		:= 45

	Default aLegenda		:= Nil
	Default aCampos			:= {}
	Default aBotTexto 		:= {}
	Default aBotGraf 		:= {}
	Default lDic			:= .T.
	Default lEnchBot		:= .F.
	Default lRefresh		:= .F.

	If lDic
		dbSelectArea(cAlias)
		(cAlias)->(dbSeek(xFilial()))
	EndIf
	//Montar a browse atraves da LjMntBrw (LOJXFUNA)
	oBrw := LjMntBrw(@oPanel,cAlias,{2,nButtonSize+3,((nCol2-nCol1)/2)-nButtonSize-4,((nLin2-nLin1)/2-2)},oBrw,lDic,aCampos,cFun,cTopFun,;
	cBotFun,,{|| Nil},nFreeze,,aLegenda)
	If ValType(oBrw) == "O"
		oBrw:Align := CONTROL_ALIGN_ALLCLIENT
		If !lRefresh
			//Montar a barra de ferramentas
			If lEnchBot .OR. lLegBot
				LjMntEBar(@oPanel,Nil,Nil,aBotGraf,aBotTexto,lEnchBot,lLegBot,cAlias)
			Endif
		Endif
	Endif

Return oBrw

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณExecFiltro บAutor  ณVendas Clientes       บ Data ณ10/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para montar um filtro de pesquisa. A funcionalidade monta  บฑฑ
ฑฑบ          ณdinamicamente um filtro, porem eh OBRIGATORIO que em cada perguntaบฑฑ
ฑฑบ          ณesteja declarado no campo X1_CNT05 o nome do campo (SX3) corres-  บฑฑ
ฑฑบ          ณpondente.                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome do grupo de perguntas                             บฑฑ
ฑฑบ          ณExp02[C] : Alias da tabela na qual se aplicara o filtro           บฑฑ
ฑฑบ          ณExp03[C] : Campo de filial da tabela                              บฑฑ
ฑฑบ          ณExp04[A] : Array com a est. das perguntas (obtida pelo Pergunte())บฑฑ
ฑฑบ          ณExp05[C] : Alias do SLT                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ExecFiltro(cPerg,cAlias,cFilExp,aPergunte,oPanelSLT,cAliasSLT,lAtuConf)

	Local aPilhaPar			:= {}									//Pilha de parametros utilizados na pesquisa
	Local aFilAcess  		:= FWEmpLoad( .F. )						//Filiais que o usuario logado obtem acesso
	Local cFilAcess			:= ""									//Auxilia a aFilAcess
	Local ni 				:= 0									//Contador
	Local cExp 				:= ""									//Expressao
	Local aBackup 			:= {}									//Backup dos parametros mv_parXX
	Local cTMP				:= ""									//Temporaria
	Local nTotPerg			:= 0									//Numero de perguntas utilizadas na rotina
	Local aEstru			:= SX1->(dbStruct())					//Estrutura da tabela SX1
	Local cCampo			:= ""									//Campo contido no X1_CNT05
	Local aLstCmpInt		:= {{"LW_DTABERT",0},{"LW_OPERADO",0}}	//Lista de campos utilizados nos perguntes em intervalos
	Local nPos				:= 0									//Posicionador
	Local lErro				:= .F.									//Controle de erro
	Local nTamanhoMx		:= 1700

	Default lAtuConf		:= .T.

	LjGrvLog(Nil,"LOJA057 - ExecFiltro - Inicio do filtro",)

	If cPerg == Nil .OR. cAlias == Nil .OR. cFilExp == Nil .OR. aPergunte == Nil
		Return Nil
	Endif
	nTotPerg := RetTotPerg(cPerg)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFazer backup dos parametros ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 To nTotPerg
		cTMP := "mv_par" + StrZero(ni,2)
		If Type(cTMP) # "U"
			aAdd(aBackup,{cTMP,&(cTMP)})
		EndIf
	Next
	__SaveParam(cPerg,@aPergunte)	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณReinicializar as perguntas  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ResetMVRange()

	If nModulo == 5
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCriterios para o venda direta ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aAdd(aPilhaPar,"(LW_ORIGEM = 'FAT')")
	Endif

	If lConfCx .AND. nModulo <> 5
		For ni := 1 to Len(aFilAcess)
			cFilAcess := cFilAcess + "|" + aFilAcess[ni][3] 
		Next ni

		/*
			Prote็ใo para nใo exceder os 2000 bytes do filtro evitando ocorrer o erro a baixo:
			"Filter greater than 2000 bytes"
			Trata-se de uma limita็ใo do dbAccess.
			Caso exceda os 2000 bytes o filtro ้ feito somente na filial corrente
		*/ 
		If Len(cFilAcess) > nTamanhoMx
			LjGrvLog(Nil,"LOJA057 - ExecFiltro - Filtro na filial corrente.",)
			aAdd(aPilhaPar,"(LW_FILIAL = '"+xFilial("SLW")+"')")
			lFlFilCorr := .T.
		Else		
			aAdd(aPilhaPar,"(LW_FILIAL $ '"+cFilAcess+"')")
			lFlFilCorr := .F.
		EndIf
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMontar expressao (nao utilizar MakeAdvplExpr por performance)     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 to nTotPerg
		cTMP := "mv_par" + StrZero(ni,2)
		If Type(cTMP) # "U"
			//Se o campo de pesquisa (X1_CNT05) estiver preenchido, montar a expressao com o campo da tabela
			cCampo := GetAdvfVal("SX1","X1_CNT05",PadR(cPerg,aEstru[aScan(aEstru,{|x| x[1] == "X1_GRUPO"})][3]) + StrZero(ni,2),1)
			If !Empty(cCampo)
				cCampo := Upper(AllTrim(cCampo))
				//Verificar se o campo em questao eh utilizado em intervalos e controlar
				nPos := aScan(aLstCmpInt,{|x| x[1] == cCampo})
				If nPos > 0
					//Incrementar o contador de utilizacao
					aLstCmpInt[nPos][2]++
					//Validar conteudos
					If aLstCmpInt[nPos][2] == 1
						If aPergunte[ni][2] # "C"
							If Empty(aBackup[ni][2]) .AND. !Empty(aBackup[ni + 1][2])
								MsgAlert(STR0012 + AllTrim(aPergunte[ni][1]) + STR0013) //"O intervalo inicial do filtro ("###") precisa ser definido!"
								lErro := .T.
								Exit
							Endif
						Endif
						//Se o proximo parametro estiver vazio, considerar o parametro como exclusivo
						If Empty(aBackup[ni + 1][2]) .AND. Empty(aBackup[ni][2])
							nPos := 0
						Endif
						//Se o primeiro parametro do intervalo estiver maior que o segundo, alertar
						If !Empty(aBackup[ni][2]) .AND. !Empty(aBackup[ni + 1][2])
							If aBackup[ni][2] > aBackup[ni + 1][2]
								MsgAlert(STR0012 + AllTrim(aPergunte[ni][1]) + STR0014) //"O intervalo inicial do filtro ("###") nใo deve ser maior que o intervalo final!"
								lErro := .T.
								Exit
							Endif
						Endif
					Else
						If !Empty(aBackup[ni - 1][2]) .AND. Empty(aBackup[ni][2])
							MsgAlert(STR0015 + AllTrim(aPergunte[ni][1]) + STR0013) //"O intervalo final do filtro ("###") precisa ser definido!"
							lErro := .T.
							Exit
						Endif
						//Se o parametro anterior estiver vazio, considerar o parametro como exclusivo
						If Empty(aBackup[ni - 1][2]) .AND. Empty(aBackup[ni][2])
							nPos := 0
						Endif
					Endif
					//Retornar o campo para o campo anterior, para continuar montando a expressao
					If nPos > 0
						If aLstCmpInt[nPos][2] > 1
							//Limpar a variavel para que esta nao seja utilizada no filtro
							&(cTMP) := Nil
							cTMP := "mv_par" + StrZero(ni - 1,2)
						Endif
					Endif
				Endif
				If nPos == 0
					//Se o campo estiver vazio, saltar
					If Empty(&(cTMP))
						Loop
					Endif			
				Endif
				If Upper(AllTrim(aPergunte[ni][6])) == "C"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณTratamento para campos do tipo COMBO  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					Do Case
						Case cCampo == "LW_CONFERE"
						Do Case
							Case &(cTMP) == 2
							&(cTMP) := "(" + cCampo + " = '1')"	
							Case &(cTMP) == 3
							&(cTMP) := "(" + cCampo + " $ ' |2')"
							OtherWise
							&(cTMP) := ""
						EndCase
						OtherWise
						&(cTMP) := "(" + cCampo + " = '" + AllToChar(aBackup[ni][2]) + "')"
					EndCase
				Else
					Do Case
						Case aPergunte[ni][2] == "C"
						If nPos > 0
							If aLstCmpInt[nPos][2] == 1	
								&(cTMP) := "(" + AllTrim(cCampo)
								&(cTMP) += " >= '" + RTrim(Substr(aBackup[ni][2],1,aPergunte[ni][3])) + "' .AND. "
							Else
								&(cTMP) += AllTrim(cCampo)
								&(cTMP) += " <= '" + RTrim(Substr(aBackup[ni][2],1,aPergunte[ni][3])) + "')"
							Endif
						Else
							&(cTMP) := "(" + AllTrim(cCampo)
							&(cTMP) += " = '" + RTrim(Substr(aBackup[ni][2],1,aPergunte[ni][3])) + "')"					
						Endif
						Case aPergunte[ni][2] == "D"
						If nPos > 0
							If aLstCmpInt[nPos][2] == 1	
								&(cTMP) := "(DTOS(" + AllTrim(cCampo)
								&(cTMP) += ") >= '" + DtoS(IIf(ValType(aBackup[ni][2]) == "D",aBackup[ni][2],CtoD(aBackup[ni][2]))) + "' .AND. "
							Else
								&(cTMP) += "DTOS(" + AllTrim(cCampo)
								&(cTMP) += ") <= '" + DtoS(IIf(ValType(aBackup[ni][2]) == "D",aBackup[ni][2],CtoD(aBackup[ni][2]))) + "')"
							Endif
						Else
							&(cTMP) := "(DTOS(" + AllTrim(cCampo) + ")"
							&(cTMP) += " = '" + DtoS(IIf(ValType(aBackup[ni][2]) == "D",aBackup[ni][2],CtoD(aBackup[ni][2]))) + "')"
						Endif
						Case aPergunte[ni][2] == "N"
						If nPos > 0
							If aLstCmpInt[nPos][2] == 1	
								&(cTMP) := "(" + AllTrim(cCampo)
								&(cTMP) += " >= " + cValtoChar(aBackup[ni][2]) + " .AND. "
							Else
								&(cTMP) += AllTrim(cCampo)
								&(cTMP) += " <= " + cValToChar(CtoD(aBackup[ni][2])) + ")"
							Endif
						Else				
							&(cTMP) := "(" + AllTrim(cCampo)
							&(cTMP) += " = " + cValtoChar(aBackup[ni][2]) + ")"
						Endif
					EndCase
				Endif
			Endif
		Endif
	Next ni
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso tenha havido erro, restaurar valor dos parametros e sair  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lErro
		For ni := 1 To Len(aBackup)
			&(aBackup[ni][1]) := aBackup[ni][2]
		Next ni
		Return Nil
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEmpilhar os parametros existentes e nao sao vazios  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 To nTotPerg
		cTMP := "mv_par" + StrZero(ni, 2)
		If Type(cTMP) # "U" .AND. !Empty(&(cTMP))
			aAdd(aPilhaPar,&(cTMP))
		EndIf
	Next

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRestaurar parametros originais  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 To Len(aBackup)
		&(aBackup[ni][1]) := aBackup[ni][2]
	Next ni
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDesempilhar os parametros, criar a expressao de filtro e aplicar ou limpar filtro  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aPilhaPar) > 0
		cExp := aPilhaPar[1]
		For ni := 2 To Len(aPilhaPar)
			cExp += " .AND. " + aPilhaPar[ni]
		Next

		/*
			Prote็ใo para nใo exceder os 2000 bytes do filtro evitando ocorrer o erro a baixo:
			"Filter greater than 2000 bytes"
			Trata-se de uma limita็ใo do dbAccess.
			Caso exceda os 2000 bytes o filtro nใo ้ executado.
		*/ 
		If Len(cExp) > 2000
			LjGrvLog(Nil,"LOJA057 - ExecFiltro - Filtro excede os 2000 bytes, com isso nใo serแ realizado.",)
		Else		

			(cAlias)->(dbClearFilter())
			(cAlias)->(dbSetFilter({|| &cExp },cExp))
			(cAlias)->(dbGoTop())

		EndIf	

		If !oBrwSLW == NIL
			oBrwSLW	:= Lj057TSlw( .T. )
		EndIf
	Else
		(cAlias)->(dbClearFilter())
	EndIf
	If lAtuConf
		AtuaConf(@oPanelSLT,SLW->(Recno()),,cAliasSLT)
	Endif
	dbSelectArea(cAlias)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณRetTotPerg บAutor  ณVendas Clientes       บ Data ณ10/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que retorna o numero total de perguntas de um determinado  บฑฑ
ฑฑบ          ณgrupo.                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome do grupo de perguntas                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณnTotPerg[N] : Numero total de perguntas do grupo                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetTotPerg(cPerg)

	Local aAreaSX1			:= SX1->(GetArea())					//Workarea do SX1
	Local nTotPerg          := 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBuscar o numero de perguntas do grupo de perguntas  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	If SX1->(dbSeek(cPerg))
		While !SX1->(Eof()) .AND. Upper(Alltrim(X1_GRUPO)) == Upper(Alltrim(cPerg))
			nTotPerg++
			SX1->(dbSkip())
		Enddo
	Endif
	RestArea(aAreaSX1)						

Return nTotPerg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaTC  บAutor  ณPablo Gollan Carreras บ Data ณ  11/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlterar o tipo de dados de campos criados por querys de acordoบฑฑ
ฑฑบ          ณcom o seu tipo de dados declarado no dicionario.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AjustaTC(cAlias,aEstru)

	Local ni		:= 0
	Local nPos		:= 0

	If Empty(cAlias) .OR. ValType(aEstru) # "A" .OR. Len(aEstru) == 0
		Return Nil
	Endif
	For ni := 1 to (cAlias)->(FCount())
		If (nPos := aScan(aEstru,{|x| AllTrim(x[1]) == AllTrim((cAlias)->(FieldName(ni)))})) # 0
			If aEstru[nPos][2] # "C"
				TcSetField(cAlias,aEstru[nPos][1],aEstru[nPos][2],aEstru[nPos][3],aEstru[nPos][4])
			Endif
		Endif
	Next ni

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj057Conf  บAutor  ณVendas Clientes       บ Data ณ13/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para apresentacao das conferencias dos caixas locais para  บฑฑ
ฑฑบ          ณa realizacao da conferencia final                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj057Conf()

	Local aArea			:= GetArea()
	Local nOpca			:= 0				//Opcao de retornado da interface
	Local cCaixa			:= ""				//Caixa (operador)
	Local cEstacao		:= ""		   		//Estacao
	Local cSerie			:= ""				//Serie
	Local cPDV				:= ""				//PDV
	Local dDataAb			:= ""				//Data de abertura
	Local cHrAb			:= ""				//Hora de abertura
	Local dDataF			:= ""				//Data de fechamento
	Local cHrF				:= ""				//Hora de fechamento
	Local cEmpFil			:= AllTrim(cEmpAnt) + " - " + AllTrim(cFilAnt)	//Empresa + Filial
	Local aID				:= Array(4)		//Identificaca completa do caixa
	Local aRegSLT			:= {}				//Lista de registros da conferencia a ser realizada na retaguarda
	Local lEdita			:= .F.				//Controle de edicao
	Local lVisADM			:= .F.				//Operador visualizava adm financeira no fechamento?
	Local lVisVAP			:= .F.				//Operador visualizava valor apurado no fechamento?
	Local ni				:= 0				//Contador
	Local nTamMemo		:= 0				//Tamanho do campo memo
	Local cChave			:= ""				//Chave de pesquisa
	Local cMensErro		:= ""				//Mensagem de erro de retorno da funcao LjExecTrans
	Local cLock			:= ""				//Controle de semaforo
	Local cRespC			:= ""				//Responsavel pela conferencia final
	Local bImpAction		:= {|| ImpConf(lEdita,aID,dDataAb,cHrAb,dDataF,cHrF,@cRespC)}
	Local cFunc			:= ""
	Local oError			:= Nil
	Local bError			:= Nil
	Local cFIlAux			:= cFilAnt

	//Variaveis da interface e formatacoes
	Static oTela02
	Static oGrp01
	Static oGrp02
	Static oGrp03
	Static oGrp04
	Static oCaixa
	Static oEstacao
	Static oPDV
	Static oSerie
	Static oNumMov
	Static oDataAb
	Static oHrAb
	Static oDataF
	Static oHrF
	Static oSay01
	Static oSay02
	Static oSay03
	Static oSay04
	Static oSay05
	Static oSay06
	Static oSay07
	Static oSay08
	Static oSay09
	Static oSay13
	Static oSay15
	Static oSay16
	Static oSay17
	Static oSay18
	Static oSay19
	Static oSay20
	Static oSay21
	Static oBot01
	Static oBot02
	Static oBot03
	Static oBot04
	Static cPTM				:= "@!"
	Static cPTN01			:= "@E 99,999,999.99"
	Static cPTD				:= "@D"
	Static cPTH				:= "99:99"
	Static nLargS			:= 033
	Static nLargS02			:= 050
	Static nLargG			:= 090
	Static nLargC			:= 065
	Static nLargB			:= 030
	Static nAltura			:= 010
	Static nAltBot			:= 015
	Static aTotal			:= {}
	Static oFont01
	Static oEmpFil
	Static oVisADM
	Static oVisVAP

	//Posicionamento de colunas
	Private POS_FP			:= 0
	Private POS_DESCFP		:= 0
	Private POS_QTDE		:= 0
	Private POS_MOEDA		:= 0
	Private POS_VALDIG		:= 0
	Private POS_VALAPU		:= 0
	Private POS_CODADM		:= 0
	Private POS_DESADM		:= 0
	Private POS_ACAO		:= 0
	Private POS_DESACAO	    := 0
	Private POS_ACDETA		:= 0

	//Totalizadores
	Private oSay10
	Private oSay11
	Private oSay12
	Private oSay14
	Private cTot01			:= ""
	Private cTot02			:= ""
	Private cTot03			:= ""
	Private cTot04			:= ""

	//Variaveis de referencia
	Private cNumMov        := AllTrim(LjNumMov())				//Retorno o numero do movimento atual
	Private dDtMov			:= Nil								//Data do abertura do movimento
	Private dDtFMov		:= Nil								//Data de fechamento do movimento
	Private aCmp			:= {}								//Campos da GetDados
	Private aCmpAlter		:= {}								//Campos da GetDados habilitados para alterar
	Private cNomeUs		:= AllTrim(UsrRetName(__cUserID))	//Nome do usuario padrao
	Private aDadosOri		:= {}								//Lista de dados original, para conferencia

	If SLW->(Eof())
		Return Nil
	Endif
	If !lConfCx
		MsgAlert(STR0016) //"A confer๊ncia de caixa nao estแ ativa, opera็ใo cancelada!"
		Return Nil
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidar se existe ao menos uma acao cadastrada para cada tipo de acao.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty(Lj057Acao("1")) .OR. Empty(Lj057Acao("2")) .OR. Empty(Lj057Acao("3")) .OR. Empty(Lj057Acao("4"))
		MsgAlert(STR0086)	//"Ao menos um tipo de a็ใo estแ sem uma a็ใo cadastrada associada. Opera็ใo cancelada!"
		Return .T.
	Endif
	//Variaveis de referencia e tela
	If cFilAnt <> SLW->LW_FILIAL
		cFilAnt := SLW->LW_FILIAL
	EndIf
	aID[1]		:= SLW->LW_OPERADO
	aID[2]		:= SLW->LW_ESTACAO
	aID[3]		:= SLW->LW_SERIE
	aID[4]		:= SLW->LW_PDV
	dDtMov		:= SLW->LW_DTABERT
	dDtFMov		:= SLW->LW_DTFECHA
	cNumMov		:= SLW->LW_NUMMOV
	cCaixa		:= aID[1]
	cEstacao	:= aID[2]
	cSerie		:= aID[3]
	cPDV		:= aID[4]
	cNumMov		:= SLW->LW_NUMMOV
	dDataAb		:= DtoC(SLW->LW_DTABERT)
	cHrAb		:= SLW->LW_HRABERT
	dDataF		:= DtoC(SLW->LW_DTFECHA)
	cHrF		:= SLW->LW_HRFECHA
	lEdita		:= (SLW->LW_CONFERE # "1")
	lVisADM		:= SLW->LW_OPCEXIB $ "2|3"
	lVisVAP		:= SLW->LW_OPCEXIB $ "1|3"
	//Campos totalizadores
	aAdd(aTotal,{"oSay10","cTot01"})
	aAdd(aTotal,{"oSay11","cTot02"})
	aAdd(aTotal,{"oSay12","cTot03"})
	aAdd(aTotal,{"oSay14","cTot04"})
	//Fontes
	oFont01	:= TFont():New("Tahoma",,14,,.T.,,,,,.F.,.F.)
	//Tela de conferencia
	DEFINE MSDIALOG oTela02 TITLE STR0017 + IIf(!lEdita,STR0018,"") FROM 000, 000  TO 442,623 COLORS CLRTEXT,CLRBACK PIXEL //"Confer๊ncia final"###" (Visualiza็ใo)"
	//Grupos de campos
	oGrp01 	:= tGroup():New(004,004,088,148,STR0019,oTela02,CLRTEXT,CLRBACK,.T.) //"Dados da esta็ใo"
	oGrp02 	:= tGroup():New(004,153,088,309,STR0020,oTela02,CLRTEXT,CLRBACK,.T.)  //"Movimento"
	oGrp03	:= tGroup():New(176,004,220,100,STR0021,oTela02,CLRTEXT,CLRBACK,.T.) //"Opc.visual.operador fechamento"
	oGrp04	:= tGroup():New(176,105,220,309,STR0022,oTela02,CLRTEXT,CLRBACK,.T.) //"Totalizadores e comandos"
	//Campos do grupo 01
	oSay01 	:= tSay():New(015,008,{||STR0023},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Caixa"
	oCaixa 	:= tGet():New(015,044,{|x| If(PCount() > 0,cCaixa := x,cCaixa)},oTela02,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.T.,.F.,,"cCaixa")
	oSay02 	:= tSay():New(029,008,{||STR0024},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Esta็ใo"
	oEstacao:= tGet():New(029,044,{|x| If(PCount() > 0,cEstacao := x,cEstacao)},oTela02,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cEstacao")
	oSay03 	:= tSay():New(043,008,{||STR0025},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"S้rie"
	oSerie	:= tGet():New(043,044,{|x| If(PCount() > 0,cSerie := x,cSerie)},oTela02,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cSerie")
	oSay04 	:= tSay():New(057,008,{||STR0026},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"PDV"
	oPDV	:= tGet():New(057,044,{|x| If(PCount() > 0,cPDV := x,cPDV)},oTela02,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cPDV")
	oSay21 	:= tSay():New(071,008,{||STR0027},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Emp./Fil."
	oEmpFil	:= tGet():New(071,044,{|x| If(PCount() > 0,cEmpFil := x,cEmpFil)},oTela02,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cEmpFil")
	//Campos do grupo 02
	oSay05 	:= tSay():New(015,159,{||STR0020},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Movimento"
	oNumMov	:= tGet():New(015,205,{|x| If(PCount() > 0,cNumMov := x,cNumMov)},oTela02,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cNumMov")
	oSay06 	:= tSay():New(029,159,{||STR0028},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Dt.abertura"
	oDataAb	:= tGet():New(029,205,{|x| If(PCount() > 0,dDataAb := x,dDataAb)},oTela02,nLargG,nAltura,cPTD,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"dDataAb")
	oSay07 	:= tSay():New(043,159,{||STR0029},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Hr.abertura"
	oHrAb	:= tGet():New(043,205,{|x| If(PCount() > 0,cHrAb := x,cHrAb)},oTela02,nLargG,nAltura,cPTH,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cHrAb")
	oSay08 	:= tSay():New(057,159,{||STR0030},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Dt.fechamen."
	oDataF	:= tGet():New(057,205,{|x| If(PCount() > 0,dDataF := x,dDataF)},oTela02,nLargG,nAltura,cPTD,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"dDataF")
	oSay09 	:= tSay():New(071,159,{||STR0031},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Hr.fechamen."
	oHrF	:= tGet():New(071,205,{|x| If(PCount() > 0,cHrF := x,cHrF)},oTela02,nLargG,nAltura,cPTH,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cHrF")
	//Grid de formas de pagamento
	If !MontaGD(092,004,172,310,lEdita,@aRegSLT,aID,@cRespC)
		Return Nil
	Endif
	//Totalizadores
	Lj057ExTot({1,2,3,4})
	oSay16 	:= tSay():New(185,110,{||STR0032},oTela02,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)	 //"Quantid."
	oSay18 	:= tSay():New(185,140,{||":"},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,02,nAltura)
	oSay10 	:= tSay():New(185,143,{||cTot01},oTela02,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)
	oSay17 	:= tSay():New(193,110,{||STR0033},oTela02,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)  //"Digitado"
	oSay19 	:= tSay():New(193,140,{||":"},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,02,nAltura)
	oSay11 	:= tSay():New(193,143,{||cTot02},oTela02,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)
	oSay15 	:= tSay():New(201,110,{||STR0034},oTela02,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura) //"Apurado"
	oSay20 	:= tSay():New(201,140,{||":"},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,02,nAltura)
	oSay12 	:= tSay():New(201,143,{||cTot03},oTela02,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)
	oSay13 	:= tSay():New(209,110,{||STR0035},oTela02,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura) //"Saldo"
	oSay18 	:= tSay():New(209,140,{||":"},oTela02,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,02,nAltura)
	oSay14 	:= tSay():New(209,143,{||cTot04},oTela02,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)	
	//Formatar o saldo
	If Lj057LCalc(3,,.T.) >= 0
		oSay14:nClrText := CLR_BLUE
	Else
		oSay14:nClrText := CLR_RED
	Endif
	//Caixas de marcacao
	oVisADM := tCheckBox():New(184,008,STR0036,{|| lVisADM}	,oTela02,nLargC,nAltura,,{|| lVisADM := !lVisADM},,{|| .T.},CLRTEXT	,CLRBACKCTR,,.T.,STR0037,,{|| .F.}) //"Adm. Financeira"###"Visualizava Adm. Financeira"
	oVisVAP	:= tCheckBox():New(194,008,STR0038,{|| lVisVAP},oTela02,nLargC,nAltura,,{|| lVisVAP := !lVisVAP},,{|| .T.},CLRTEXT	,CLRBACKCTR,,.T.,STR0039,,{|| .F.}) //"Valores Apurados"###"Visualizava Valores Apurados"
	//Botoes de comando
	oBot01	:= tButton():New(202,198,STR0040,oTela02,{|| OpcOk(oTela02,@nOpca,lEdita)},nLargB,nAltBot,,,,.T.,,,,{|| lEdita}) //"Confirmar"

	If ExistBlock("LJ7098") //Ponto de entrada para impressใo de relatorio customizado.
		bImpAction := {|| ExecBlock("LJ7098",.F.,.F.,{oGet01}) }
	EndIf
	oBot02	:= tButton():New(202,235,STR0041,oTela02,bImpAction,nLargB,nAltBot,,,,.T.,,,,{|| .T.}) //"Imprimir"
	oBot03	:= tButton():New(202,272,IIf(lEdita,STR0042,STR0008),oTela02,{|| OpcCanc(oTela02,@nOpca,lEdita)},nLargB,nAltBot,,,,.T.,,,,{|| .T.}) //"Cancelar"

	If ExistBlock("LJ7092")
		oBot04 := tButton():New(183,198,STR0097,oTela02,{|| ExecBlock('LJ7092', .F., .F.,{oGet01})},nLargB,nAltBot,,,,.T.,,,,{|| .T.})                //"Ajustar"
	EndIf
	//Totalizadores
	ACTIVATE MSDIALOG oTela02 ON INIT(oGet01:oBrowse:SetFocus()) CENTERED

	If nOpca == 1 .AND. lEdita .AND. Len(aRegSLT) > 0
		aDadosOri := oGet01:aCols
		nTamMemo := TamSX3("MBH_ACDETA")[1]
		Begin Transaction
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGravacao follow-up fechamento (Conferencia Final)  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("MBH")
			MBH->(dbSetOrder(1))
			dbSelectArea("SLT")
			For ni := 1 to Len(aRegSLT)
				SLT->(dbGoTo(aRegSLT[ni]))
				If !SLT->(Eof())
					//Gravar follow-up do fechamento
					RecLock("MBH",.T.)
					MBH->MBH_FILIAL		:= xFilial("MBH")
					MBH->MBH_OPERAD		:= SLT->LT_OPERADO
					MBH->MBH_DATA		:= SLT->LT_DTFECHA
					MBH->MBH_FORMPG		:= SLT->LT_FORMPG
					MBH->MBH_PDV		:= SLT->LT_PDV
					MBH->MBH_NUMMOV		:= SLT->LT_NUMMOV
					MBH->MBH_ADMFIN		:= SLT->LT_ADMIFIN
					MBH->MBH_ESTACA		:= SLT->LT_ESTACAO
					MBH->MBH_MOEDA		:= SLT->LT_MOEDA
					MBH->MBH_ACAO		:= aDadosOri[ni][POS_ACAO]
					MBH->MBH_ACRESP		:= __cUserID
					MsUnlock()
					//Gravar campo memo
					If !Empty(aDadosOri[ni][POS_ACDETA])
						//Se o retorno for vazio, indica erro de gravacao do campo memo, abortar operacao
						If Empty(MSMM(MBH_CODMEM,,,aDadosOri[ni][POS_ACDETA],1,,,"MBH","MBH_CODMEM"))
							MsgAlert(cNomeUs + STR0043) //", houve um erro de grava็ใo do campo memorando, opera็ใo de grava็ใo cancelada!"
							DisarmTransaction()
							RestArea(aArea)	
							Return Nil					
						Endif				
					Endif

					cFunc := GetAdvfVal("MBI","MBI_FORGRV",xFilial("MBI") + MBH->MBH_ACAO,1)
					If !Empty(cFunc)
						bError := ErrorBlock( {|oError| Lj057Excecao(oError) } )

						BEGIN SEQUENCE

							&(cFunc)

							RECOVER

						END SEQUENCE

						//A partir desse ponto, as excecoes passam a ser tratadas pelo sistema novamente
						ErrorBlock( bError )
					EndIf

				Endif
			Next ni
			If lTrans .AND. !Empty(cTransNat)	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณExecucao da transferencia dos titulos associados a (0) carteira simples ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cChave := xFilial("FRA") + SLW->(LW_OPERADO + LW_ESTACAO + LW_PDV + LW_NUMMOV) + DtoS(SLW->LW_DTFECHA)
				dbSelectArea("FRA")
				FRA->(dbSetOrder(6))	//FRA_FILIAL+FRA_LJCXOR+FRA_LJESTA+FRA_LJPDV+FRA_LJMOV+FRA_LJDTFE+FRA_CRDEST	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerificar se o movimento jah nao havia sido transferido para a carteira simples, caso tenha sido, nao transferir  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !FRA->(dbSeek(cChave + "0"))
					cLock := "SLW" + SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + LW_ESTACAO) + DtoS(SLW->LW_DTABERT) + SLW->LW_NUMMOV		//Alias + Chave(05)
					If !MayIUseCode(cLock)
						MsgAlert(cNomeUs + STR0044) //", este movimento estแ sendo processado no momento, por favor, tente mais tarde."
						DisarmTransaction()
						RestArea(aArea)
						Return Nil
					Endif
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAtualizar SL1,SE1,SE5 e FRAณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					//Parametros : Carteira,Portador,Agencia,Conta,ID Caixa,Data Mov.,Mov.,Pesq.Orc?,Lista orc.,Mens Erro,Int.proc.orc.s/titulo?
					If !LjExecTrans("0",,,,aID,dDtMov,cNumMov,.T.,,@cMensErro,.F.,lUsaMVD)
						MsgAlert(cNomeUs + STR0045 + CRLF + cMensErro) //", erro no processamento da transferencia :"
						DisarmTransaction()
						Leave1Code(cLock)
						RestArea(aArea)
						Return Nil
					Endif
				Endif	
			Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณIndicar na SLW que a conferencia final do movimento foi realizada.  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RecLock("SLW",.F.)
			SLW->LW_CONFERE	:= "1"
			MsUnlock()
		End Transaction
		If !Empty(cLock)
			Leave1Code(cLock)
		Endif
	Endif
	cFilAnt := cFIlAux
	RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMontaGD    บAutor  ณVendas Clientes       บ Data ณ14/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para montar o grid de dados pertinente a conferencia de    บฑฑ
ฑฑบ          ณcaixa e conferencia final. (SLT + MBH)                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Objeto da grid                                         บฑฑ
ฑฑบ          ณExp02[N] : Posicao topo                                           บฑฑ
ฑฑบ          ณExp03[N] : Posicao esquerda                                       บฑฑ
ฑฑบ          ณExp04[N] : Posicao base                                           บฑฑ
ฑฑบ          ณExp05[N] : Posicao direita                                        บฑฑ
ฑฑบ          ณExp06[L] : Modo de edicao                                         บฑฑ
ฑฑบ          ณExp07[A] : Registros utilizados da SLT                            บฑฑ
ฑฑบ          ณExp08[A] : Identificacao completa do caixa                        บฑฑ
ฑฑบ          ณExp09[C] : Codigo de usuario do responsavel pelo fechamento       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L] : Indica se o objeto pode ser configurado                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MontaGD(nTop,nLeft,nBottom,nRight,lEdita,aRegSLT,aID,cRespC)

	Local lRet				:= .T.								//Retorno da funcao
	Local aArea				:= GetArea()						//Retrato da workarea
	Local aCab				:= {}								//Cabecalho
	Local aDados			:= {}								//Dados
	Local cLinOk			:= "AlwaysTrue()"					//Validacao de linha
	Local cTudoOk			:= "AlwaysTrue()"					//Validacao de todas linhas
	Local cFieldOk			:= "AlwaysTrue()"					//Validacao de campo
	Local cDelOk			:= "AlwaysFalse()"					//Validacao de exclusao
	Local cIniCpos			:= ""								//Inicializacao de campos
	Local nLimLin			:= 100								//Limite de linhas para a GetDados
	Local ni				:= 0								//Contador
	Local nx				:= 0								//Contador
	Local nCont				:= 0								//Contador
	Local cChave			:= ""								//Chave de pesquisa
	Local nPos				:= 0								//Posicionador
	Local cSimbC			:= SuperGetMV("MV_SIMB1",.F.,"")	//Moeda corrente
	Local cValid			:= ""								//Validacao
	Local aREG				:= {}								//Armazena a lista de registros da SLT que sao apresentadoa nas conf. feitas na retaguarda
	Local nTamAcDeta		:= TamSX3("MBH_ACDETA")[1]			//Tamanho da acao detalhada
	Local lLJ057Mem			:= ExistBlock("LJ057MEM")

	//Defini็ใo da variavel para controle do Robo de testes
	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	Default lEdita			:= .T.
	Default aRegSLT		:= {}
	Default aID			:= {}

	If nTop == Nil .OR. nLeft == Nil .OR. nBottom == Nil .OR. nRight == Nil .OR. Len(aID) # 4
		Return !lRet
	Endif
	//Redefinir os posicionamentos das colunas
	POS_FP			:= 1
	POS_DESCFP		:= 2
	POS_CODADM		:= 3
	POS_DESADM		:= 4
	POS_QTDE		:= 5
	POS_MOEDA		:= 6
	POS_VALDIG		:= 7
	POS_VALAPU		:= 8
	POS_ACAO		:= 9
	POS_DESACAO		:= 10
	POS_ACDETA		:= 11
	//Definicao dos campos
	aCmp := {"LT_FORMPG","LT_DESFORM","LT_ADMIFIN","AE_DESC","LT_QTDE","LT_MOEDA","LT_VLRDIG","LT_VLRAPU","MBH_ACAO","MBI_DESCRI","MBH_ACDETA"}
	If lEdita
		aCmpAlter := {"MBH_ACAO","MBH_ACDETA"}
	Else
		aCmpAlter := {"MBH_ACDETA"}
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefinir cabecalho  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For ni := 1 to Len(aCmp)
		SX3->(dbSeek(aCmp[ni]))
		If !SX3->(Found())
			MsgAlert(cNomeUs + STR0046 + AllTrim(aCmp[ni]) + STR0047) //", erro ao montar a lista de numerแrios! O campo "###" nao consta no dicionแrio de dados."
			RestArea(aArea)
			Return !lRet
		Endif
		Do Case
			Case aCmp[ni] == "MBH_ACAO"
			cValid := "Lj057VldAc()"
			OtherWise
			cValid := SX3->X3_VALID		
		EndCase
		aAdd(aCab,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cValid,SX3->X3_USADO,IIf(ni == 4,"C",SX3->X3_TIPO),SX3->X3_F3,;
		SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		nCont++
	Next ni
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLevantar registros do movimento + operador + estacao + PDV  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aREG := LjExConf({aID[1],aID[2],aID[3],aID[4]},dDtMov,dDtFMov,cNumMov,.F.,.T.)
	If Len(aREG) == 0
		MsgAlert(STR0048) //"Nenhuma confer๊ncia pode ser encontrada, opera็ใo cancelada."
		//Ajustar o movimento como tendo conferencia final
		RecLock("SLW",.F.)
		SLW->LW_CONFERE	:= "1"
		MsUnlock()
		Return !lRet
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณClassificar por forma de pagamento para apresentar os dados ณ
	//ณutilizando os registros selecionados na pesquisa anterior   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	If Len(aREG) > 0
		//Montar pesquisa		
		cChave := xFilial("SLT") + aID[1] + DtoS(dDtFMov)
		SLT->(dbSetOrder(1)) //LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG
		SLT->(dbSeek(cChave))
		Do While !SLT->(Eof()) .AND. (SLT->(LT_FILIAL + LT_OPERADO) + DtoS(LT_DTFECHA)) == cChave
			If aScan(aREG,{|x| x == SLT->(Recno())}) == 0
				SLT->(dbSkip())
				Loop
			Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaso seja visualizacao, carregar o registro da conferencia final MBH  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !lEdita
				dbSelectArea("MBH")
				MBH->(dbSetOrder(1))	//MBH_FILIAL+MBH_OPERAD+DTOS(MBH_DATA)+MBH_FORMPG+MBH_PDV+MBH_NUMMOV+MBH_ADMFIN
				MBH->(dbSeek(xFilial("MBH") + SLT->LT_OPERADO + DtoS(SLT->LT_DTFECHA) + SLT->(LT_FORMPG + LT_PDV + LT_NUMMOV + LT_ADMIFIN)))
				If MBH->(Found())
					If Empty(cRespC)
						cRespC := MBH->MBH_ACRESP
					Endif
				Endif
			Else
				If Empty(cRespC)
					cRespC := __cUserID
				Endif		
			Endif
			aAdd(aDados,Array(Len(aCmp) + 1))
			nPos := Len(aDados)
			For nx := 1 to Len(aCmp)
				If nx == POS_MOEDA
					If SLT->&(aCmp[nx]) == 1
						aDados[nPos][nx] := cSimbC
					Else
						aDados[nPos][nx] := SuperGetMV(AllTrim("MV_SIMB" + cValToChar(SLT->&(aCmp[nx]))),.F.,"")
					Endif
				ElseIf nx == POS_DESCFP
					If SLT->(FieldPos("LT_DESFORM")) == 0 .OR. X3NaoUsa("LT_DESFORM",.F.,.T.)
						aDados[nPos][nx] := Lj057DesFP(SLT->&(aCmp[POS_FP]))
					Else
						aDados[nPos][nx] := SLT->&(aCmp[nx])
					Endif
				ElseIf nx == POS_DESADM
					aDados[nPos][nx] := iIf(!Empty(SLT->&(aCmp[POS_CODADM])), GetAdvFVal("SAE","AE_DESC",xFilial("SAE") + RTrim(SLT->&(aCmp[POS_CODADM])),1), "")
				ElseIf nx == POS_ACAO 
					If !lEdita
						aDados[nPos][nx] := MBH->MBH_ACAO
					Else
						//Determinar a acao de acordo com a diferenca de saldo
						If Abs(SLT->LT_VLRDIG - SLT->LT_VLRAPU) == 0
							aDados[nPos][nx] := Lj057Acao("4")
						Else
							aDados[nPos][nx] := Lj057Acao("3")
						Endif
					Endif
				ElseIf nx == POS_DESACAO
					If !lEdita
						aDados[nPos][nx] := GetAdvfVal("MBI","MBI_DESCRI",xFilial("MBI") + RTrim(MBH->MBH_ACAO),1)
					Else
						aDados[nPos][nx] := GetAdvfVal("MBI","MBI_DESCRI",xFilial("MBI") + RTrim(aDados[nPos][POS_ACAO]),1)
					Endif
				ElseIf nx == POS_ACDETA
					If !lEdita
						aDados[nPos][nx] := MSMM(MBH->MBH_CODMEM,nTamAcDeta,,,3)
					Else
						If lLJ057Mem
							aDados[nPos][nx] :=  ExecBlock("LJ057MEM",.F.,.F.,{aDados})
						Else
							aDados[nPos][nx] := ""
						EndIf
					Endif
				Else
					aDados[nPos][nx] := SLT->&(aCmp[nx])
				Endif
			Next nx
			aDados[nPos][nx] := .F.
			//Adicionar o registro a lista de conferencias que sera repassadas a MBH
			aAdd(aRegSLT,SLT->(Recno()))
			SLT->(dbSkip())
		EndDo
	Endif
	aDadosOri := aDados

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMontar a GetDados  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oGet01 := MsNewGetDados():New(nTop,nLeft,nBottom,nRight,GD_UPDATE,cLinOk,cTudoOk,cIniCpos,aCmpAlter,1,nLimLin,cFieldOk,"",cDelOk,oTela02,aCab,aDados)
	oGet01:lUpdate := lEdita
	If lAutomato // se for chamado pelo robo de testes, nao exibe o MsNewGetDados
		oGet01:Hide()
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalcular os totalizadores em tela  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Lj057ExTot({1,2,3})

	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj057ExTot บAutor  ณVendas Clientes       บ Data ณ14/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizar uma determinada variavel totalizadora.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Array com as posicoes dos totalizadores a atualizar    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj057ExTot(aOpc)

	Local cVarT			:= ""			//Variavel totalizadora a atualizar
	Local nTotal		:= 0			//Totalizador
	Local ni			:= 0			//Contador
	Local aValores		:= Array(2)	//Array de valores
	Local nSaldo		:= 0			//Saldo

	//Defini็ใo da variavel para controle do Robo de testes
	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	Default aOpc		:= {1}

	If ValType(aOpc) # "A" .OR. Len(aOpc) == 0
		Return Nil
	Endif

	// desvio para o tratamento do Robo
	If lAutomato
		//Totalizadores	
		aAdd(aTotal,{"oSay10","cTot01"})
		aAdd(aTotal,{"oSay11","cTot02"})
		aAdd(aTotal,{"oSay12","cTot03"})
		aAdd(aTotal,{"oSay14","cTot04"})
	Endif


	nTotal := Len(aOpc)
	For ni := 1 to nTotal
		//Atualizar variavel
		cVarT := aTotal[aOpc[ni]][2]
		If Type(cVarT) # "U"
			&(cVarT) := Lj057LCalc(aOpc[ni],TAMTOT)
		Endif
		//Atualizar objeto
		cVarT := aTotal[aOpc[ni]][1]
		If Type(cVarT) # "U"
			&(cVarT):Refresh()
		Endif
	Next ni
	//Se nao for conferencia cega, calcular o saldo
	aValores[1]	:= Lj057LCalc(2,,.T.)
	aValores[2]	:= Lj057LCalc(3,,.T.)
	If aValores[1] # Nil .AND. aValores[2] # Nil
		nSaldo := aValores[1] - aValores[2]
		//Atualizar variavel e campo
		cVarT := aTotal[Len(aTotal)][2]
		If Type(cVarT) # "U"
			&(cVarT) := AllTrim(Transform(nSaldo,cPTN01))
		Endif
		//Atualizar objeto
		cVarT := aTotal[Len(aTotal)][1]
		If Type(cVarT) # "U"
			If nSaldo >= 0
				&(cVarT):nClrText := CLR_BLUE	
			Else
				&(cVarT):nClrText := CLR_RED
			Endif
			&(cVarT):Refresh()
		Endif
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj057LCalc บAutor  ณVendas Clientes       บ Data ณ14/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณGerar totalizadores da lista de apontamentos.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Opcao a totalizar                                      บฑฑ
ฑฑบ          ณExp02[N] : Tamanho de formatacao                                  บฑฑ
ฑฑบ          ณExp03[L] : Retornar em formato numerico                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj057LCalc(nOpc,nTam,lRetVal)

	Local cRet			:= ""				//Retorno
	Local aDados		:= oGet01:aCols		//Array com dados da GetDados
	Local ni			:= 0				//Contador
	Local nCol			:= 0				//Controle de coluna
	Local nTotal		:= 0				//Totalizador
	Local cCMP			:= ""				//Campo a calcular
	Local cMasc			:= ""				//Picture

	Default nOpc		:= 1
	Default nTam		:= 0
	Default lRetVal	:= .F.

	Do Case
		Case nOpc == 1		//Quantidade
		cCMP	:= "LT_QTDE"
		nCol 	:= POS_QTDE
		Case nOpc == 2		//Digitado
		cCMP	:= "LT_VLRDIG"
		nCol 	:= POS_VALDIG
		cMasc	:= PesqPict("SLT",cCMP)
		Case nOpc == 3		//Apurado
		cCMP	:= "LT_VLRAPU"
		nCol 	:= POS_VALAPU
		cMasc	:= PesqPict("SLT",cCMP)
		Otherwise
		Return cRet
	EndCase
	For ni := 1 to Len(aDados)
		//Caso seja a linha atual e o campo seja editavel, carregar a variavel de memoria correspondente ao campo
		If ni == IIf(Type("n") == "U",0,n) .AND. aScan(aCmpAlter,{|x| AllTrim(x) == cCMP}) > 0 .AND. Type(cCMP) # "U"
			nTotal += M->&(cCMP)
		Else
			nTotal += aDados[ni][nCol]
		Endif
	Next ni
	If !lRetVal
		If !Empty(cMasc)
			cRet += AllTrim(Transform(nTotal,cMasc))
		Else
			cRet += cValToChar(nTotal)
		Endif
		If !Empty(nTam)
			cRet := PadL(Right(cRet,nTam),nTam)	
		Endif
	Endif

Return IIf(!lRetVal,cRet,nTotal)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj057DesFP บAutor  ณVendas Clientes       บ Data ณ13/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRetornar descricao de forma de pagamento                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Forma de pagamento                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcRet[C] : Descricao da forma de pagamento                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj057DesFP(cFM)

	Local cChave			:= ""		//Chave de pesquisa
	Local cRet				:= ""		//Retorno

	Default cFM			:= ""

	If Empty(cFM)
		Return cRet
	Endif
	cChave := xFilial("SX5") + "24" + AllTrim(cFM)
	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))
	SX5->(dbSeek(cChave))
	If SX5->(Found())
		cRet := SX5->X5_DESCRI
	Endif

	If Empty(cRet)
		cFM := UPPER(AllTrim(cFM))

		Do Case
			Case cFM == "SG"
			cRet := STR0089 //"SANGRIA"

			Case cFM == "TC"
			cRet := STR0090 //"ENTRADA DE TROCO"

			Case cFM == "REC"
			cRet := STR0091 //"RECEBIMENTOS"

			Case cFM == "CB"
			cRet := STR0092 //"CORRESPONDENTES BANCARIOS"

			Case cFM == "RCE"
			cRet := STR0093 //"RECARGA DE CELULAR"
		EndCase

	EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj057Acao  บAutor  ณVendas Clientes       บ Data ณ14/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que retorna a primeira acao do tipo definido pelo parametroบฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Tipo de acao                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcCodAcao[C] : Codigo da acao                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj057Acao(cTipo)

	Local cCodAcao        	:= ""
	Local aAreaMBI			:= MBI->(GetArea())

	Default cTipo			:= "4"	//Aprovacao

	cChave := RTrim(xFilial("MBI") + cTipo)
	dbSelectArea("MBI")
	MBI->(dbSetOrder(1))
	MBI->(dbGoTop())
	Do While !MBI->(Eof())
		If RTrim(MBI->MBI_TIPACA) == RTrim(cTipo)
			cCodAcao := MBI->MBI_CODACA
			Exit
		Endif
		MBI->(dbSkip())
	EndDo
	RestArea(aAreaMBI)

Return cCodAcao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj057VldAc บAutor  ณVendas Clientes       บ Data ณ14/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validar a acao selecionada                            บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L] : Retorna se a acao selecionada eh valida                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Lj057VldAc()

	Local lRet			:= .F.
	Local aAreaMBI	:= MBI->(GetArea())
	Local cTMP			:= ""
	Local aValores	:= {0,0}
	Local cFunc		:= ""
	Local xRet			:= Nil
	Local bError		:= Nil
	Local oError		:= Nil

	If ValType(oGet01) # "O" .OR. Len(oGet01:aCols) == 0
		Return lRet
	Endif
	dbSelectArea("MBI")
	MBI->(dbSetOrder(1))
	If MBI->(dbSeek(xFilial("MBI") + M->MBH_ACAO))
		aValores[1] := oGet01:aCols[n][POS_VALDIG]
		aValores[2] := oGet01:aCols[n][POS_VALAPU]
		//Se a acao for de abono, desconto ou ajuste
		If MBI->MBI_TIPACA $ "1|2|3"
			//Se nao houver diferencas entre o apurado e digitado, perguntar se o usuario deseja realmente aplicar esta acao
			If (Empty(aValores[1]) .AND. Empty(aValores[2])) .OR. (Abs(aValores[1] - aValores[2]) == 0)
				If !ApMsgYesNo(STR0049 + IIf(MBI->MBI_TIPACA == "1",STR0050,; //"Foi selecionada uma a็ใo de "###"abono"
				IIf(MBI->MBI_TIPACA == "2",STR0051,; //"desconto"
				STR0052)) + STR0053 + CRLF + ; //"ajuste"###" para uma confer๊ncia sem diferen็a!"
				STR0054) //"Deseja utilizar esta a็ใo mesmo assim?"

					If Empty(cTMP := Lj057Acao("4"))
						M->MBH_ACAO := oGet01:aCols[n][POS_ACAO]
					Else
						M->MBH_ACAO := cTMP
					Endif
					//Relizar nova pesquisa para atualizar o campo de descricao da acao
					If !MBI->(dbSeek(xFilial("MBI") + M->MBH_ACAO))
						oGet01:aCols[n][POS_DESACAO] := Space(TamSX3("MBI_DESCRI")[1])
						Return lRet
					Endif
				Endif
			Endif
		Else
			If MBI->MBI_TIPACA $ "4" 
				If Abs(aValores[1] - aValores[2]) > 0
					If !ApMsgYesNo(STR0055 + CRLF + STR0054) //"Foi selecionada uma a็ใo de aprova็ใo para uma confer๊ncia com diferen็a!"###"Deseja utilizar esta a็ใo mesmo assim?"
						If Empty(cTMP := Lj057Acao("3"))
							M->MBH_ACAO := oGet01:aCols[n][POS_ACAO]
						Else
							M->MBH_ACAO := cTMP
						Endif
						//Relizar nova pesquisa para atualizar o campo de descricao da acao
						If !MBI->(dbSeek(xFilial("MBI") + M->MBH_ACAO))
							oGet01:aCols[n][POS_DESACAO] := Space(TamSX3("MBI_DESCRI")[1])
							Return lRet
						Endif
					Endif
				Endif
			Endif
		Endif
		lRet := !lRet
		oGet01:aCols[n][POS_DESACAO] := MBI->MBI_DESCRI
		//Verificar se o campo MEMO precisar ser apagado
		If AllTrim(GetAdvfVal("MBI","MBI_TIPACA",xFilial("MBI") + M->MBH_ACAO,1)) == "4"
			oGet01:aCols[n][POS_ACDETA] := Nil
			M->MBH_ACDETA := Nil
		Endif

		cFunc := AllTrim(MBI->MBI_FORCRI)
		If lRet .And. !Empty(cFunc)
			bError := ErrorBlock( {|oError| Lj057Excecao(oError) } )

			BEGIN SEQUENCE

				xRet := &(cFunc)

				If ValType(xRet) == "L"
					lRet := xRet
				EndIf

				RECOVER
				lRet := .F.

			END SEQUENCE

			//A partir desse ponto, as excecoes passam a ser tratadas pelo sistema novamente
			ErrorBlock( bError )

		EndIf

	Endif
	RestArea(aAreaMBI)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณOpcOk      บAutor  ณVendas Clientes       บ Data ณ15/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validar a acao selecionada                            บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Objeto da tela                                         บฑฑ
ฑฑบ          ณExp02[N] : Opcao de operacao                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function OpcOk(oTela02,nOpca,lEdita)

	Local cPerg				:= STR0056	//Pergunta //", confirma a grava็ใo desta confer๊ncia?"
	Local ni				:= 0											//Contador
	Local aDados			:= oGet01:aCols									//GetDados
	Local aLstInc			:= {{0,""},{0,""}}								//Lista de inconsistencias 1.Acoes nao definidas 2.Falta de justificativa [Total e Linhas]
	Local cMens				:= ""											//Mensagem de erro
	Local cTipAcao			:= ""

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFazer validacao dos dados  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lEdita
		For ni := 1 to Len(aDados)
			If Empty(aDados[ni][POS_ACAO])
				aLstInc[1][1]++
				aLstInc[1][2] += cValToChar(ni) + ","
			Else
				cTipAcao := GetAdvfVal("MBI","MBI_TIPACA",xFilial("MBI") + RTrim(aDados[ni][POS_ACAO]),1)
				If cTipAcao $ "1|2|3" .AND. Empty(aDados[ni][POS_ACDETA])
					aLstInc[2][1]++
					aLstInc[2][2] += cValToChar(ni) + ","
				Endif
			Endif
		Next ni
		If !Empty(aLstInc[1][1]) .OR. !Empty(aLstInc[2][1])
			cMens := cNomeUs + STR0057 //", existem diverg๊ncias na confer๊ncia dos dados : "
			If !Empty(aLstInc[1][1])
				cMens += CRLF + Space(5) + STR0058 + cValtoChar(aLstInc[1][1]) + CRLF + ; //"- Itens sem a็ใo definida : "
				Space(7) + STR0059 + Substr(aLstInc[1][2],1,Len(aLstInc[1][2]) - 1) + "]" //"[Linhas : "
			Endif
			If !Empty(aLstInc[2][1])
				cMens += CRLF + Space(5) + STR0060 + cValtoChar(aLstInc[2][1]) + CRLF + ; //"- Itens sem detalhamento da a็ใo definida : "
				Space(7) + STR0059 + Substr(aLstInc[2][2],1,Len(aLstInc[2][2]) - 1) + "]" //"[Linhas : "
			Endif
			MsgAlert(cMens)
			Return .T.
		Endif
	Endif
	If ApMsgYesNo(cNomeUs + cPerg)
		nOpca := 1
		oTela02:End()
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณOpcCanc    บAutor  ณVendas Clientes       บ Data ณ15/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validar a opcao de cancelamento de operacao           บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Objeto da tela                                         บฑฑ
ฑฑบ          ณExp02[N] : Opcao de operacao                                      บฑฑ
ฑฑบ          ณExp03[L] : Modo de edicao                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function OpcCanc(oTela02,nOpca,lEdita)

	Local ni			:= 0				//Contador
	Local nx			:= 0				//Contador
	Local aDados		:= oGet01:aCols		//Grade de dados atual
	Local aPosCmp		:= {}				//Posicao de campos alteraveis
	Local lAltera		:= .F.
	Local lLJ057CAN		:= ExistBlock("LJ057CAN")	

	If lEdita
		//Levantar a posicao dos campos editaveis
		For ni := 1 to Len(aCmpAlter)
			aAdd(aPosCmp,aScan(aCmp,{|x| Upper(AllTrim(x)) == Upper(AllTrim(aCmpAlter[ni]))}))
		Next ni
		//Verificar se os campos editaveis tiveram seus valores alterados
		For ni := 1 to Len(aDados)
			//Varrer campos editaveis
			For nx := 1 to Len(aPosCmp)
				//Linhas (alteracoes consolidadas), comparar valor com conteudo da posicao especifica da array
				If aDadosOri[ni][aPosCmp[nx]] # aDados[ni][aPosCmp[nx]]
					lAltera := .T.
					Exit
				Endif				
			Next nx
			If lAltera
				Exit
			Endif
		Next ni

		//Ponto de entrada no momento do cancelamento
		If lLJ057CAN
			ExecBlock("LJ057CAN",.F.,.F.,{aDados})
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerificar se houve alguma altera็ใo na grade de dados  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lAltera
			If ApMsgYesNo(cNomeUs + STR0061) //", houveram apontamentos feitos nesta confer๊ncia deseja realmente abandonar as confer๊ncias apontadas?"
				nOpca := 2
				oTela02:End()
			Endif
		Else
			nOpca := 2
			oTela02:End()	
		Endif
	Else
		nOpca := 2
		oTela02:End()
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณImpConf    บAutor  ณVendas Clientes       บ Data ณ16/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para impressao dos dados da conferencia final              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[L] : Modo de edicao                                         บฑฑ
ฑฑบ          ณExp02[A] : Identificacao completa de caixa                        บฑฑ
ฑฑบ          ณExp03[D] : Data de abertura                                       บฑฑ
ฑฑบ          ณExp04[C] : Hora de abertura                                       บฑฑ
ฑฑบ          ณExp05[D] : Data de fechamento                                     บฑฑ
ฑฑบ          ณExp06[D] : Hora de fechamento                                     บฑฑ
ฑฑบ          ณExp07[C] : Codigo do responsavel pela conf. final                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpConf(lEdita,aID,dDataAb,cHrAb,dDataF,cHrF,cRespC)

	Local oFrm											//Objeto para classe FrmtLay
	Local aTMP			:= {}							//Array temporario
	Local aCab			:= oGet01:aHeader				//Header da GetDados
	Local aDados		:= oGet01:aCols					//Dados da GetDados
	Local ni			:= 0							//Contador
	Local nx			:= 0							//Contador
	Local aCols			:= {}							//Lista das colunas que devem ser impressas
	Local aAliDif		:= {{"POS_MOEDA","C"},{"POS_VALDIG","R"},{	"POS_VALAPU","R"},{"POS_ACDETA","L"},;	//Lista de posicoes que possuem alinhamento diferenciado
	{"POS_DESACAO","L"},{"POS_ACAO","C"},{"POS_QTDE","L"}}
	Local aAlinha		:= {}							//Controle de alinhamento
	Local lOk			:= .T.							//Controle de processamento
	Local nPos			:= 0							//Posicionador
	Local nRet			:= 0							//Retorno
	Local lCSV			:= .F.							//Gerar arquivo CSV
	Local lFLDispo		:= FindFunction("LOJA0053")		//Classe FrmtLay disponivel?
	Local nTotDig		:= 0							//Total de valores digitados
	Local nTotApu		:= 0							//Total de valores apurados
	Local aTotTpAc		:= {0,0,0,0}					//Totais por tipo de acao
	Local aDesTpAc		:= {STR0062,STR0063,STR0064,STR0065}	//Lista de tipos de acoes possiveis //"Abonos"###"Descontos"###"Ajustados"###"Aprovados"
	Local cTipAcao		:= ""							//Tipo de acao utilizada
	Local nEspTot		:= 20							//Total de espacos utilizados na formatacao dos totalizadores

	//Defini็ใo da variavel para controle do Robo de testes
	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	If !lFLDispo
		Return .T.
	Endif
	conout('linha 2088 - ImpConf')
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณOpcao de impressao  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lAutomato // controle de execu็ใo automatica pelo robo
		nRet := AbTelaOpc()
	Else
		nRet := 2
	EndIf
	Do Case
		Case nRet == 0
		//Cancelar
		Return .T.
		Case nRet == 2
		lCSV := !lCSV
	EndCase
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVarrer o cabecalho para determinar quais campos serao impressos,    ณ
	//ณmontar o cabecalho do relatorio e montar o alinhamento das colunas  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 to Len(aCab)
		lOk := .T.
		//Definir a coluna como utilizada
		aAdd(aCols,ni)
		//Agregar ao cabecalho
		aAdd(aTMP,aCab[ni][1])
		//Verificando se a posicao possui um alinhamento diferenciado
		For nx := 1 to Len(aAliDif)
			If ni == &(aAliDif[nx][1])
				nPos := nx
				Exit
			Endif
		Next nx	
		If nPos > 0
			aAdd(aAlinha,aAliDif[nPos][2])
		Else
			aAdd(aAlinha,"L")
		Endif
	Next ni
	If !lCSV
		oFrm := LJCFrmtLay():New(2,,.F.,,,,,"L")		//R4
	Else
		If !lAutomato
		conout('linha 2130')
			oFrm := LJCFrmtLay():New(3,,.T.)		//CSV
		Else
		conout('linha 2133')
			oFrm := LJCFrmtLay():New(0,,.T.)		//TXT
		EndIf
	Endif
	oFrm:AddStruct(2,Len(aCols),.T.,.T.,,aAlinha,aTMP)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImprimir dados do caixa e fechamento  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oFrm:PrintText(STR0084)	//Dados do movimento
	oFrm:PrintText(STR0066 + aID[1]) //"Caixa : "
	oFrm:PrintText(STR0067 + aID[2]) //"Esta็ใo : "
	oFrm:PrintText(STR0068 + aID[3]) //"S้rie : "
	oFrm:PrintText(STR0069 + aID[4]) //"PDV : "
	oFrm:PrintText(STR0070 + cNumMov) //"Movimento : "
	oFrm:PrintText(STR0071 + dDataAb + " - " + cHrAb) //"Abertura : "
	oFrm:PrintText(STR0072 + dDataF + " - " + cHrF) //"Fechamento : "
	oFrm:PrintBlank()
	oFrm:PrintText(STR0085)	//Dados da confer๊ncia final
	oFrm:PrintText(STR0073 + DtoC(Date())) //"Data : "
	oFrm:PrintText(STR0074 + AllTrim(cRespC) + ") " + AllTrim(UsrFullName(AllTrim(cRespC)))) //"Responsแvel pela confer๊ncia final : ("
	oFrm:PrintBlank()
	oFrm:PrintLine()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImprimir formas de pagamento  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 to Len(aDados)
		If aTail(aDados[ni])
			Loop
		Endif
		aTMP := {}
		For nx := 1 to Len(aCmp)
			//Caso a coluna de dados esteja dentro de lista de colunas permitidas
			If aScan(aCols,{|x| x == nx}) > 0
				aAdd(aTMP,IIf(!Empty(aCab[nx][3]),Transform(aDados[ni][nx],aCab[nx][3]),aDados[ni][nx]))
			Endif
		Next nx
		//Totalizar por tipo de acao
		nTotDig += aDados[ni][POS_VALDIG]
		nTotApu += aDados[ni][POS_VALAPU]
		If !Empty(cTipAcao := GetAdvfVal("MBI","MBI_TIPACA",xFilial("MBI") + RTrim(aDados[ni][POS_ACAO]),1))
			If AllTrim(cTipAcao) $ "1|2|3"
				aTotTpAc[Val(cTipAcao)] += Abs(aDados[ni][POS_VALDIG] - aDados[ni][POS_VALAPU])
			Else
				aTotTpAc[Val(cTipAcao)] += aDados[ni][POS_VALAPU]
			Endif
		Endif
		oFrm:Add(2,aTMP)
	Next ni
	//ฺฤฤฤฤฤฤฤฤฟ
	//ณRodape  ณ
	//ภฤฤฤฤฤฤฤฤู
	oFrm:PrintLine()
	oFrm:PrintText(STR0075) //"Totais : "
	oFrm:PrintText(Space(10) + PadR(STR0076,nEspTot) + ": " + AllTrim(Transform(nTotDig,cPTN01))) //"- Digitado"
	oFrm:PrintText(Space(10) + PadR(STR0077,nEspTot) + ": " + AllTrim(Transform(nTotApu,cPTN01))) //"- Apurado"
	oFrm:PrintBlank()
	oFrm:PrintText(STR0078) //"Totais por tipo de a็ใo : "
	For ni := 1 to Len(aTotTpAc)
		oFrm:PrintText(Space(10) + PadR("- " + aDesTpAc[ni],nEspTot) + ": " + AllTrim(Transform(aTotTpAc[ni],cPTN01)))
	Next ni
	If !lCSV
		oFrm:SetTitle(STR0079) //"CONF. FINAL DE FECHAMENTO DE CAIXA"
		oFrm:Exec()
	Else
		If oFrm:FindFile()
			oFrm:Exec()
		Endif
	Endif
	oFrm:Finish()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณAbTelaOpc  บAutor  ณVendas Clientes       บ Data ณ16/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para apresentar tela de selecao de tipo de impressao da    บฑฑ
ฑฑบ          ณconferencia final.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณnOpcR[N] : Codigo da opcao selecionada                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AbTelaOpc()

	Local nOpcR			:= 0	//Retorno
	Local nRad01		:= 1	//Opcao de impressao escolhida na radio button
	Local nOpca			:= 0	//Acao selecionada na interface
	//Variaveis de interface
	Local oTela03
	Local oRad01
	Local oBot01
	Local oBot02

	DEFINE MSDIALOG oTela03 TITLE STR0080 FROM 000, 000  TO 196,293 COLORS CLRTEXT,CLRBACK PIXEL //"Impressใo"

	oGrp01 	:= tGroup():New(004,004,096,144,STR0081,oTela03,CLRTEXT,CLRBACK,.T.) //"Selecione a forma de impressใo"
	oRad01 	:= tRadMenu():New(015,009,{STR0082,STR0083},{|u|IIf(PCount() == 0,nRad01,nRad01 := u)},oTela03,,,CLRTEXT,CLRBACK,,,,100,012,,,,.T.) //"IMPRESSรO NORMAL"###"EXPORTAR PARA O EXCEL"
	oBot01	:= tButton():New(080,075,STR0040,oTela03,{|| nOpca := 1, oTela03:End()},030,012,,,,.T.,,,,{|| .T.}) //"Confirmar"
	oBot02	:= tButton():New(080,110,STR0042,oTela03	,{|| nOpca := 2, oTela03:End()},030,012,,,,.T.,,,,{|| .T.}) //"Cancelar"

	ACTIVATE MSDIALOG oTela03 CENTERED

	If nOpca == 1
		nOpcR := nRad01
	Endif

Return nOpcR
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLj057ExMov บAutor  ณVendas Clientes       บ Data ณ03/03/11        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validar se o movimento em questao possui movimentacoesบฑฑ
ฑฑบ          ณpara a realizacao da conferencia final, sena atualiza o movimento.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L]  : Retorna se existe ou nao movimento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj057ExMov()

	Local lRet				:= .T.								//Retorno de dados
	Local aID				:= Array(4)						//Identificacao completa do caixa
	Local cNumMov        	:= ""								//Retorno o numero do movimento atual
	Local dDtMov			:= Nil								//Data do abertura do movimento
	Local dDtFMov			:= Nil								//Data de fechamento do movimento
	Local lTransCart		:= lConfCx .And. (lTrans .AND. !Empty(cTransNat)) .AND. nModulo <> 5		//Usa Transferencia de carteira
	Local cFIlAux			:= cFilAnt
	If SLW->(Eof())
		Return !lRet
	Endif
	If cFilAnt <> SLW->LW_FILIAL
		cFilAnt := SLW->LW_FILIAL
	EndIf
	aID[1]		:= SLW->LW_OPERADO
	aID[2]		:= SLW->LW_ESTACAO
	aID[3]		:= SLW->LW_SERIE
	aID[4]		:= SLW->LW_PDV
	dDtMov		:= SLW->LW_DTABERT
	dDtFMov		:= SLW->LW_DTFECHA
	cNumMov		:= SLW->LW_NUMMOV

	If (!lTransCart .And. !(SLW->LW_TIPFECH == "2")) .Or. (lTransCart .And. !(SLW->LW_TIPFECH == "3"))
		MsgAlert(STR0106,STR0107) //#"Devido ao estatus deste movimento nใo serแ possํvel efetuar a confer๊ncia." ##"Aten็ใo"
		lRet := .F.
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLevantar registros do movimento + operador + estacao + PDV  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Len(aREG := LjExConf({aID[1],aID[2],aID[3],aID[4]},dDtMov,dDtFMov,cNumMov,.F.,.T.)) == 0
			MsgAlert(STR0048) //"Nenhuma confer๊ncia pode ser encontrada, opera็ใo cancelada."
			//Ajustar o movimento como tendo conferencia final
			RecLock("SLW",.F.)
			SLW->LW_CONFERE	:= "1"
			MsUnlock()
			lRet := .F.
		Endif
	EndIf
	cFilAnt := cFIlAux
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLj057TSlw บAutor  ณVendas Clientes       บ Data ณ29/08/13        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para criar o objeto da SLW e atualizar a tela 				บฑฑ
ฑฑบ			 ณ ao efetuar um pesquisa										    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณlRefresh :define se atualiza os bot๕es da tela                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณoObjRet  : Retorna o objeto da SLW                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Lj057TSlw( lRefresh )
	Local cTitBot01		:= STR0003 //"Pesquisar"
	Local aBotTexto		:= {}
	Local aBotGraf		:= {}
	Local oObjRet

	DEFAULT lRefresh 	:= .F.

	oBrwSLW := NIL
	aAdd(aBotTexto,{cTitBot01,cTitBot01,{|| dbSelectArea("SLW"),WndxPesqui(@oBrwSLW,Nil,"",.F.)}})
	oObjRet := MntBrwWnd(oPanelSLW,,"SLW",0,0,0,0,aCmpSLW,aBotTexto,aBotGraf,,,,LJ057Leg(),.T.,.T.,,,,lRefresh)
	oObjRet:bChange := {|| AtuaConf(@oArea:GetWinPanel('column_center','wnd_browse02'),SLW->(Recno()),,cStcSLT)}                

Return oObjRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDetVendas บAutor  ณVendas Clientes       บ Data ณ17/10/13   	    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de a็ใo do botใo Det. Formas Pgtos                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico: .T.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function DetVendas()
	Local aVendas		:= {}
	Local aOrd			:= SX5->(GetArea())
	Local cNumMov		:= SLW->LW_NUMMOV					//Numero do movimento de venda
	Local cOperador		:= SLW->LW_OPERADO					//Codigo do Operador
	Local dDataAbert	:= SLW->LW_DTABERT					//Data de Abertura
	Local dDataFecha	:= SLW->LW_DTFECHA					//Data de Fechamento
	Local cEstacao		:= SLW->LW_ESTACAO					// Estacao que foi feito a venda
	Local cForma		:= oBrwSLT:aArray[oBrwSLT:nAt, 1]	//Codigo da forma de pagto
	Local cAdmFin		:= oBrwSLT:aArray[oBrwSLT:nAt, 2]	//Codigo da Administradora da forma de pgto
	Local nVlrForma		:= oBrwSLT:aArray[oBrwSLT:nAt, 7]	//Valor Apurado
	Local cDescForma	:= AllTrim(cForma)+" ("+AllTrim(Lj057DesFP(cForma))+")" //Descri็ใo completa da forma de pagamento

	If nVlrForma > 0
		aVendas := MontaDetVenda(cNumMov, cForma, cAdmFin, cOperador, dDataAbert, dDataFecha, cEstacao) //Responsแvel por montar o array com as vendas da forma de pagamento/Administradora
	EndIf
	If Len(aVendas) > 0
		TelaDetVenda(aVendas, cDescForma) //Exibe tela com as movimenta็๕es
	Else
		MsgInfo(STR0094+cDescForma+"'.") //#STR0094->"Nใo hแ registros (Vendas) a serem exibidos para a forma de pagamento '"
	EndIf

	RestArea(aOrd)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMontaDetVenda บAutor  ณVendas Clientes       บ Data ณ17/10/13   	บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao responsแvel por selecionar os movimentos/vendas da forma   บฑฑ
ฑฑบ          ณde pagamentos selecionada                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcNumMov    : Numero do movimento da conferencia                   บฑฑ
ฑฑบ          ณcForma     : Codigo da forma de pagamentos selecionada            บฑฑ
ฑฑบ          ณcAdmFin    : Codigo da Administradora Financeira da forma de pgto บฑฑ
ฑฑบ          ณ             selecionada                                          บฑฑ
ฑฑบ          ณcOperador  : Operador da movimenta็ใo                             บฑฑ
ฑฑบ          ณdDataAbert : Data de Abertura da Conferencia (movimento)          บฑฑ
ฑฑบ          ณdDataFecha : Data de fechamento da Conferencia (movimento)        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaVendas : Array com os movimentos da forma de pagamentos          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MontaDetVenda(cNumMov, cForma, cAdmFin, cOperador, dDataAbert, dDataFecha, cEstacao)
	Local aVendas	:= {}									//Array com os movimentos da forma de pagamentos
	Local cQry		:= ""									//Comando SQL para Query
	Local cFilSL1	:= ""									//Filial do SL1
	Local cChaveSE5 := ""									//Chave de busca dos moviemntos que n	ao sใo vendas
	Local cAlias	:= "VEND"								//Alias da Query
	Local lVenda	:= !(AllTrim(cForma) $ "TC/SG/REC/CB/RCE")	//Verifica se o movimento ้ uma venda.
	Local cMoeda	:= AllTrim(SuperGetMV("MV_SIMB1",.F.,"R$"))
	Local lDetADMF	:= SuperGetMV("MV_LJDESM",.T.,.F.) .AND. SLT->(FieldPos("LT_ADMIFIN")) > 0	//Utiliza detalhamento por administradora financeira

	Default cNumMov	:= ""									//Numero do movimento
	Default cForma	:= ""									//Forma de pagamentos
	Default cAdmFin	:= ""									//Codigo da administradora financeira

	#IFDEF TOP

	If SuperGetMv("MV_LJOPCON",.F.,2) == 2 //Conferencia por forma de pagamento
		If AllTrim(cForma) == "CR"
			cQry := "SELECT L1_NUM NUMVENDA,L1_EMISSAO DATAVENDA,L1_CREDITO VALOR,'' ADMINIS,'' BANCO,'' AGENCIA,'' CONTA"
			cQry += " FROM " + RetSQLName("SL1") 
			cQry += " WHERE L1_CREDITO > 0"
			cQry += " AND L1_NUMMOV='"+ cNumMov +"'"
			cQry += " AND L1_FILIAL='"+ xFilial("SL1") +"'"
			cQry += " AND L1_OPERADO='"+ cOperador +"'"
			cQry += " AND L1_EMISSAO>='"+ DToS(dDataAbert) +"'"
			cQry += " AND L1_EMISSAO<='"+ DToS(dDataFecha) +"'"
			cQry += " AND L1_ORCRES=''"
			cQry += " AND L1_ESTACAO = '" + cEstacao + "'"
			cQry += " AND D_E_L_E_T_=' '"
			cQry += " ORDER BY L1_NUM"
		Else		
			cQry := "SELECT E5_NUMERO NUMVENDA, E5_DATA DATAVENDA,E5_VALOR VALOR,'' ADMINIS,E5_BANCO BANCO,E5_AGENCIA AGENCIA,E5_CONTA CONTA" 
			cQry += " FROM "+ RetSQLName("SE5")
			cQry += " WHERE E5_NUMMOV='"+ cNumMov + "'"
			cQry += " AND E5_FILIAL='" + xFilial("SE5") + "'"
			cQry += " AND E5_DATA='"+ DtoS(dDataAbert) + "'"
			cQry += " AND D_E_L_E_T_=' '"
			cQry += " AND (E5_ORIGEM = '" + cEstacao + "' OR E5_ORIGEM = '')"

			If AllTrim(cForma) == cMoeda //ENTRADA DE TROCO e SANGRIA
				cQry += " AND E5_TIPODOC='TR' AND E5_MOEDA IN ('TC','R$') AND E5_NATUREZ IN ('TROCO','SANGRIA')"
			Else
				If lVenda
					cQry += " AND E5_MOEDA='"+AllTrim(cForma)+"'"
				Endif
			EndIf		

			If !(AllTrim(cForma) == "CB")
				cQry += " AND E5_BANCO='"+ cOperador + "'"
			EndIf

			If AllTrim(cForma) == "REC"
				cQry += " AND (E5_TIPODOC='VL' AND E5_TIPO='FI' AND E5_NATUREZ='FINAN') OR (E5_NATUREZ='RECEBIMENT')"
			EndIf

			If AllTrim(cForma) == "CB"
				cQry += " AND E5_HISTOR='CORRESPONDENTE BANCARIO'"
			EndIf

			cQry += " UNION ALL"

			cQry += " SELECT SL4.L4_NUM NUMVENDA,SL4.L4_DATA DATAVENDA,SL4.L4_VALOR VALOR,SL4.L4_ADMINIS ADMINIS,SL4.L4_BANPRC BANCO,SL4.L4_AGENCIA AGENCIA,SL4.L4_CONTA CONTA
			cQry += " FROM " + RetSQLName("SL4") + " SL4 INNER JOIN " + RetSQLName("SL1") + " SL1 ON SL4.L4_NUM=SL1.L1_NUM AND SL4.L4_FILIAL=SL1.L1_FILIAL"
			cQry += " WHERE	SL1.L1_NUMMOV='" + cNumMov + "'"
			cQry += " AND SL1.L1_FILIAL='" + xFilial("SL1") + "'"
			cQry += " AND SL1.D_E_L_E_T_=' ' AND SL4.D_E_L_E_T_=' '"
			cQry += " AND SL1.L1_OPERADO='" + cOperador + "'"
			cQry += " AND SL1.L1_EMISSAO>='" + DToS(dDataAbert) + "'"
			cQry += " AND SL1.L1_EMISSAO<='" + DToS(dDataFecha) + "'"
			cQry += " AND (SL1.L1_DOC <> '' OR SL1.L1_DOCPED <> '')"
			cQry += " AND SL1.L1_ORCRES=''"
			cQry += " AND SL1.L1_ESTACAO = '" + cEstacao + "'"
			cQry += " AND SL4.L4_FILIAL='" + xFilial("SL4") + "'"
			cQry += " AND SL4.L4_FORMA='" + cForma + "'"

			//Verifica se detalhamento por administradora esta habilitado
			If lDetADMF
				If !(AllTrim(cForma) $ "CH|"+cMoeda)
					cQry += " AND SUBSTRING(SL4.L4_ADMINIS,1,3)='" + cAdmFin + "'"
				EndIf
			EndIf

			cQry += " ORDER BY NUMVENDA,DATAVENDA"
		EndIf
	Else
		If lVenda
			If AllTrim(cForma) == "CR"
				cQry := "SELECT L1_NUM NUMVENDA,L1_EMISSAO DATAVENDA,L1_CREDITO VALOR,'' ADMINIS,'' BANCO,'' AGENCIA,'' CONTA"
				cQry += " FROM " + RetSQLName("SL1") 
				cQry += " WHERE L1_CREDITO > 0"
				cQry += " AND L1_NUMMOV='"+ cNumMov +"'"
				cQry += " AND L1_FILIAL='"+ xFilial("SL1") +"'"
				cQry += " AND L1_OPERADO='"+ cOperador +"'"
				cQry += " AND L1_EMISSAO>='"+ DToS(dDataAbert) +"'"
				cQry += " AND L1_EMISSAO<='"+ DToS(dDataFecha) +"'"
				cQry += " AND L1_ORCRES=''"
				cQry += " AND L1_ESTACAO = '" + cEstacao + "'"
				cQry += " AND D_E_L_E_T_=' '"
				cQry += " ORDER BY L1_NUM"

			Else
				//Seleciona as vendas
				cQry := "SELECT SL4.L4_NUM NUMVENDA,SL4.L4_DATA DATAVENDA,SL4.L4_VALOR VALOR,"+;
				"SL4.L4_ADMINIS ADMINIS,SL4.L4_BANPRC BANCO,SL4.L4_AGENCIA AGENCIA,SL4.L4_CONTA CONTA"

				cQry += " FROM " + RetSQLName("SL1") + " SL1 INNER JOIN " + RetSQLName("SL4") + " SL4 ON L1_NUM=L4_NUM AND L1_FILIAL=L4_FILIAL"

				cQry += " WHERE SL1.L1_NUMMOV='"+ cNumMov + "'"
				cQry += " AND SL4.L4_FORMA='" + cForma + "'"

				//Verifica se detalhamento por administradora esta habilitado 
				If lDetADMF
					If !(AllTrim(cForma) $ "CH|"+cMoeda)
						cQry += " AND SUBSTRING(SL4.L4_ADMINIS,1,3)='" + cAdmFin + "'"
					EndIf
				EndIf

				cQry += " AND SL1.L1_FILIAL='" + xFilial("SL1") + "'"
				cQry += " AND SL1.D_E_L_E_T_=' '"
				cQry += " AND SL1.L1_OPERADO='" + cOperador + "'"
				cQry += " AND SL1.L1_EMISSAO>='" + DToS(dDataAbert) + "'"
				cQry += " AND SL1.L1_EMISSAO<='" + DToS(dDataFecha) + "'"
				cQry += " AND SL1.L1_ORCRES=''"
				cQry += " AND SL1.L1_ESTACAO = '" + cEstacao + "'"
				cQry += " AND SL4.L4_FILIAL='" + xFilial("SL4") + "'"
				cQry += " AND SL4.D_E_L_E_T_=' '"

				cQry += " ORDER BY L1_NUM"
			EndIf

		Else

			//Formas de pagamentos que nใo sใo de vendas (Ex.: Sangria, entrada de troco, recebimentos)
			cQry := "SELECT E5_NUMERO NUMVENDA, E5_DATA DATAVENDA,E5_VALOR VALOR,"+;
			"E5_BANCO BANCO,E5_AGENCIA AGENCIA,E5_CONTA CONTA"

			cQry += " FROM " + RetSQLName("SE5")

			cQry += " WHERE E5_NUMMOV='"+ cNumMov + "'"
			cQry += " AND E5_FILIAL='" + xFilial("SE5") + "'"
			cQry += " AND D_E_L_E_T_=' '"
			If !(AllTrim(cForma) == "CB")
				cQry += " AND E5_BANCO='"+ cOperador + "'"
			EndIf
			cQry += " AND E5_DATA='"+ DtoS(dDataAbert) + "'"

			If AllTrim(cForma) == "TC"
				cQry += " AND E5_TIPODOC='TR' AND E5_MOEDA='TC' AND E5_NATUREZ='TROCO'"
				cQry += " AND ( E5_ORIGEM = '" + cEstacao + "' OR E5_ORIGEM = '')"
			EndIf
			If AllTrim(cForma) == "SG"
				cQry += " AND E5_TIPODOC='TR' AND E5_NATUREZ='SANGRIA'"
				cQry += " AND ( E5_ORIGEM = '" + cEstacao + "' OR E5_ORIGEM = '')"
			EndIf
			If AllTrim(cForma) == "REC"
				cQry += " AND (E5_TIPODOC='VL' AND E5_TIPO='FI' AND E5_NATUREZ='FINAN') OR (E5_NATUREZ='RECEBIMENT')"
			EndIf
			If AllTrim(cForma) == "CB"
				cQry += " AND E5_HISTOR='CORRESPONDENTE BANCARIO'"
			EndIf
			cQry += " ORDER BY E5_DATA"

		EndIf
	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAlias,.T.,.F.)

	TCSetField(cAlias, "DATAVENDA", "D")

	While !(cAlias)->(Eof())

		aAdd(aVendas, { (cAlias)->(NUMVENDA)					,; //Numero da Venda
		(cAlias)->(DATAVENDA)					,; //Data da Venda
		(cAlias)->(VALOR)						,; //Valor da Venda
		iIf(lVenda, (cAlias)->(ADMINIS),  "")	,; //Administradora
		(cAlias)->(BANCO)		 				,; //Banco
		(cAlias)->(AGENCIA)						,; //Agencia
		(cAlias)->(CONTA)						,; //Conta
		.F.										} )

		(cAlias)->(DBSkip())
	End

	FechaArqT(cAlias) //Fecha a Alias da Query

	#ELSE


	If lVenda

		//Seleciona as vendas:
		cFilSL1 := xFilial("SL1")
		SL1->(DBSetOrder(5)) //L1_FILIAL+L1_OPERADO+Dtos(L1_EMISSAO)
		SL4->(DBSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM

		If SL1->(DBSeek(cFilSL1+cOperador+DToS(dDataAbert)))
			While SL1->(!EOF()) .And. SL1->L1_FILIAL == cFilSL1 .And. SL1->L1_OPERADO == cOperador .And. SL1->L1_EMISSAO <= dDataFecha

				If SL1->L1_NUMMOV == cNumMov
					If SL4->(DBSeek(xFilial("SL4")+SL1->L1_NUM))
						While SL4->(!EOF()) .And. SL1->L1_FILIAL+SL1->L1_NUM == SL4->L4_FILIAL+SL4->L4_NUM

							If AllTrim(SL4->L4_FORMA) == AllTrim(cForma) .And.;
							iIf(!(AllTrim(cForma) $ "CH"+cMoeda) , Left(SL4->L4_ADMINIS,3) == cAdmFin, .T.)

								aAdd(aVendas, { SL4->L4_NUM		,; //Numero da Venda
								SL4->L4_DATA	,; //Data da Venda
								SL4->L4_VALOR	,; //Valor da Venda
								SL4->L4_ADMINIS	,; //Administradora
								SL4->L4_BANPRC	,; //Banco
								SL4->L4_AGENCIA	,; //Agencia
								SL4->L4_CONTA	,; //Conta
								.F.				} )
							EndIf
							SL4->(DBSkip())
						End
					EndIf
				EndIf
				SL1->(DBSkip())
			End
		EndIf

	Else

		//Formas de pagamentos que nใo sใo de vendas (Ex.: Sangria, entrada de troco, recebimentos)
		cChaveSE5 := xFilial("SE5")+DtoS(dDataAbert)+cOperador
		SE5->(DbSetOrder(1)) //E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
		If SE5->( DbSeek( cChaveSE5 ) )
			While !SE5->(EOF()) .And. cChaveSE5 == SE5->(E5_FILIAL+DTOS(E5_DATA)+E5_BANCO)

				If AllTrim(SE5->E5_NUMMOV) == AllTrim(cNumMov)
					If (AllTrim(cForma) == "TC" .And. AllTrim(SE5->E5_TIPODOC) == "TR" .And. Upper(AllTrim(SE5->E5_MOEDA)) == "TC" .And. Upper(AllTrim(SE5->E5_NATUREZ)) == "TROCO") .Or.; //Troco
					(AllTrim(cForma) == "SG" .And. AllTrim(SE5->E5_TIPODOC) == "TR" .And. Upper(AllTrim(SE5->E5_NATUREZ)) == "SANGRIA") .Or.; //Sangria
					(AllTrim(cForma) == "REC" .And.(AllTrim(SE5->E5_TIPODOC) == "VL" .And. ( AllTrim(SE5->E5_TIPO) == "FI" .And. Upper(AllTrim(SE5->E5_NATUREZ)) == "FINAN" .Or.;
					Upper(AllTrim(SE5->E5_NATUREZ)) == "RECEBIMENT" ))) .Or.; //Recebimentos
					(AllTrim(cForma) == "CB" .And.Upper(AllTrim(SE5->E5_HISTOR)) == Upper(AllTrim("CORRESPONDENTE BANCARIO"))) //Correspondente Bancario

						aAdd(aVendas, { SE5->E5_NUMERO	,; //Numero da Venda
						SE5->E5_DATA	,; //Data da Venda
						SE5->E5_VALOR	,; //Valor da Venda
						""				,; //Administradora
						SE5->E5_BANCO	,; //Banco
						SE5->E5_AGENCIA	,; //Agencia
						SE5->E5_CONTA	,; //Conta
						.F.				} )
					EndIf
				EndIf
				SE5->(DBSkip())
			End
		EndIf

	EndIf

	#ENDIF

Return aVendas

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณTelaDetVenda บAutor  ณVendas Clientes       บ Data ณ17/10/13      บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao responsแvel por montar e exibir a tela com os movimentos / บฑฑ
ฑฑบ          ณvendas da forma de pagamentos selecionada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaVendas    : Array com os movimentos da forma de pagamentos       บฑฑ
ฑฑบ          ณcDescForma : Codigo+descri็ใo da forma de pagamentos selecionada  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA057                                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function TelaDetVenda(aVendas, cDescForma)
	Local aAdvSize  := MsAdvSize()										//Dimensionamento da tela
	Local bBotao	:= {|| oDlg:End()}									//Botoes da EnchoiceBar
	Local cTitulo	:= STR0096 //"Lan็amentos detalhados da forma de pagamento"
	Local aHeader 	:= {}
	Local oGetDados
	Local oDlg

	Default cDescForma := ""					//Descri็ใo detalhada da forma de pagamento

	cTitulo += " - " + cDescForma

	//             TITULO               , CAMPO       , PICTURE              , TAMANHO              , DECIMAL              ,                ,    , TIPO                 , ARQUIVO, CONTEXT
	Aadd(aHeader,{ STR0098   			, "L4_NUM"    , "@!"                 , 10  					, 0                    , "AllwaysTrue()", Nil, "C"                  , "SL4"  , Nil     })  //"Or็amento/Numero"
	Aadd(aHeader,{ STR0095              , "L4_DATA"   , AVSX3("L4_DATA",6)   , AVSX3("L4_DATA",3)   , AVSX3("L4_DATA",4)   , "AllwaysTrue()", Nil, AVSX3("L4_DATA",2)   , "SL4"  , Nil     }) //#STR0095->Data
	Aadd(aHeader,{ AVSX3("L4_VALOR",5)  , "L4_VALOR"  , AVSX3("L4_VALOR",6)  , AVSX3("L4_VALOR",3)  , AVSX3("L4_VALOR",4)  , "AllwaysTrue()", Nil, AVSX3("L4_VALOR",2)  , "SL4"  , Nil     })
	Aadd(aHeader,{ AVSX3("L4_ADMINIS",5), "L4_ADMINIS", AVSX3("L4_ADMINIS",6), AVSX3("L4_ADMINIS",3), AVSX3("L4_ADMINIS",4), "AllwaysTrue()", Nil, AVSX3("L4_ADMINIS",2), "SL4"  , Nil     })
	Aadd(aHeader,{ AVSX3("L4_BANPRC",5) , "L4_BANPRC" , AVSX3("L4_BANPRC",6) , AVSX3("L4_BANPRC",3) , AVSX3("L4_BANPRC",4) , "AllwaysTrue()", Nil, AVSX3("L4_BANPRC",2) , "SL4"  , Nil     })
	Aadd(aHeader,{ AVSX3("L4_AGENCIA",5), "L4_AGENCIA", AVSX3("L4_AGENCIA",6), AVSX3("L4_AGENCIA",3), AVSX3("L4_AGENCIA",4), "AllwaysTrue()", Nil, AVSX3("L4_AGENCIA",2), "SL4"  , Nil     })
	Aadd(aHeader,{ AVSX3("L4_CONTA",5)  , "L4_CONTA"  , AVSX3("L4_CONTA",6)  , AVSX3("L4_CONTA",3)  , AVSX3("L4_CONTA",4)  , "AllwaysTrue()", Nil, AVSX3("L4_CONTA",2)  , "SL4"  , Nil     })

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	oGetDados := MsNewGetDados():New(	aAdvSize[2],; 		// Linha Inicial
	aAdvSize[1],; 		// Coluna Inicial
	aAdvSize[4],; 		// Linha Final
	aAdvSize[3],; 		// Coluna Final
	0,;					// Permissใo de Inserir / Alterar / Deletar o Conteudo da Linha
	"Allwaystrue()",; 	// Valdia็ใo na mudan็a de Linha 
	"AllwaysTrue()",; 	// Valida็ใo na Confirma็ใo da Tela
	NIL,;				// Inicpos
	NIL,;				// InicHead
	NIL,;				// Congelamento de Colunas
	Len(aVendas),;		// Quantidade de linhas da GetDados
	NIL,;				// Valida็ใo do OK
	NIL,;				// Super dele็ใo
	NIL,; 				// Validacao p/ delecao
	oDlg,;          	// Nome do Objeto da Tela
	aHeader,;			// Array com os campos do aHeader
	aVendas;		  	// Array com o conteudo a ser exibido na GetDados
	)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar( oDlg , bBotao , bBotao ))

Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em tratar excecoes em tempo de execucao

@param		oError	Objeto contendo todas as informacoes do erro
@author	Vendas
@version	P11.8
@since		19/04/2016
@obs		
/*/
//----------------------------------------------------------
Static Function Lj057Excecao( oError )

	Local cError := oError:Description	//descricao do erro

	MsgAlert( "ERRO: " + cError )	//"ERRO: "
	Break

Return Nil
