#INCLUDE "TMKA380A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTMKA380A  บAutor  ณRafael M. Quadrotti บ Data ณ  01/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAgenda do operador. Marketing Ativo.                        บฑฑ
ฑฑบ          ณTela com os dados da agenda selecionada.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Call Center                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/            


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหออออออัอออออออออออออออออออหออออัอออออออออออปฑฑ
ฑฑบFuncao    ณTk380Execlista  บAutor ณRafael M. QuadrottiบDataณ12/17/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสออออออฯอออออออออออออออออออสออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณApresenta as informacoes da lista de contatos para execucao.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1: aItemSel - Array  com a atividade selecionada.      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ28/06/05ณ811   ณ- Ajuste na rotina.                         บฑฑ
ฑฑบConrado Q.ณ27/09/06ณ8.11  ณBOPS:107460 - Adicionado celular no painel  บฑฑ
ฑฑบ          ณ        ณ      ณde detalhes do contato.                     บฑฑ
ฑฑบConrado Q.ณ29/09/06ณ8.11  ณBOPS:107460 - Modificada a forma de referen-บฑฑ
ฑฑบ          ณ        ณ      ณcia ao campo U6_CONTATO na hora de mostrar  บฑฑ
ฑฑบ          ณ        ณ      ณno painel de detalhes do contato.           บฑฑ
ฑฑบTatiana C.ณ23/01/07ณ8.11  ณBOPS:117260 - Revisao da rotina de atendimenบฑฑ
ฑฑบ          ณ        ณ      ณto receptivo na agenda do operador, ajuste  บฑฑ
ฑฑบ          ณ        ณ      ณna op็ใo de rotinas do operador.            บฑฑ
ฑฑบHanna C.  ณ23/03/07ณ9.12  ณBOPS 121961 - Substituido o botao TK_ALTFIN บฑฑ
ฑฑบ          ณ        ณ      ณpor "note" e TK_NOVO por rpmnew             บฑฑ
ฑฑบHanna C.  |30/03/07|9.12  ณBops 118469 - Alterado o nome dos Bitmaps   ณฑฑ
ฑฑบ        	 ณ        |      ณdefinidos pela Engenharia para o Protheus 10ณฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380ExecLista(aItemSel)
Local lRet 		:= .F.          				// Retorno da Funcao
Local oDlgLista									// Dialog
Local aButtons  := {}							// Array com  os botoes adicionais da barra de ferramentas
Local aCols 	:= {}							// Array com as informacoes da GetDados
Local aHeader	:= {}							// Array com as informacoes da GetDados
Local lUserBtn  := ExistBlock("TMK380BTN") 		// Ponto de entrada para inserir novos botoes na agenda do operador.
Local cAlias	:= ""							// Alias da Lista. Unico alias para todos os registros.
Local nBtn		:= 0							// Variavel de controle do for.
Local nTamObs	:= GetSx3Cache("U5_OBS","X3_TAMANHO")
Local aCad_Panel:= {}							// Array com as inf. do painel de detalhes do contato.
Local oObj1,oObj2,oObj3,oObj4,oObj5,oObj6,oObj7,oObj8// Objetos do painel de detalhes.
Local oFont 	:= "" 							// Fonte para saudacao.
Local oFont2	:= "" 							// Fonte para saudacao.
Local cData		:= ""							// Data da lista de aniversแrio
Local aTele     := Tk380Box("U4_TELE")      	// Retorna array do combo box
Local oBmpV 									// Objeto para legenda de tela. Cor Verde.
Local oBmpVM									// Objeto para legenda de tela. Cor Vermelha.
Local lU4nsts	:= (Posicione("SX3",2,"U4_NSTATUS","X3_CONTEXT") == "R")
Local aSize 		:= {}
Local oFwLayer
Local oListas
Local oDetalhes1
Local oDetalhes2
Local oLegendas
Local oScrDet

Private oGetDados 								// Objeto da GetDados
Private aUserBtn  := {}							// Array com os botoes de usuario.

// Defines das Fontes utilizadas no codigo.
DEFINE FONT oFont   NAME "Tahoma" SIZE 0,20 BOLD    
DEFINE FONT oFont2  NAME "Tahoma" SIZE 0,14 BOLD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa informacoes do painel de detalhes do contato.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aCad_Panel,{STR0001,oObj1})  //"Nome: "
Aadd(aCad_Panel,{STR0002,oObj2}) //"Endere็o: "
Aadd(aCad_Panel,{STR0003,oObj3}) //"Estado: "
Aadd(aCad_Panel,{STR0004,oObj4}) //"Fone Res.: "
Aadd(aCad_Panel,{STR0005,oObj5}) //"Fone Com: "
Aadd(aCad_Panel,{STR0101,oObj6}) //"Celular: "
Aadd(aCad_Panel,{STR0006,oObj7})  //"E-mail: "
Aadd(aCad_Panel,{STR0104,oObj8})  //"Detalhes: "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotoes genericos para todos os tipos de lista.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AAdd(aButtons,{ "BMPUSER"  	,	{|| Tk380VisContato(oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| x[2] == "U6_CONTATO"})])}, STR0007,STR0008}) //"Altera็ใo de Contatos"###"Contato"
AAdd(aButtons,{ "FOLDER6"	,	{|| Tk380VisEntidade(cAlias,oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| ALLTRIM(x[2]) == "U6_CODENT"})]) 	}, STR0009,STR0010}) //"Altera็ใo de Entidade"###"Entidade"
AAdd(aButtons,{ "PRODUT2"   ,	{|| Tk380VisProduto(aItemSel[1])		}, STR0011,STR0012}) //"Consulta de Produtos"###"Produto"
AAdd(aButtons,{ "RPMNEW"   ,	{|| Tk380VisMidia(aItemSel[1])			}, STR0013,STR0014}) //"Consulta Midia"###"Midia"
AAdd(aButtons,{ "POSCLI"	,	{|| Tk380VisEvento(aItemSel[1])			}, STR0015,STR0016}) //"Consulta de Eventos"###"Eventos"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotoes para listas de Marketing.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aItemSel[7] == "1" .OR. aItemSel[7] == "4"
	AAdd(aButtons,{ "AUTOM"	,	{|| Tk380HTmk(cAlias,oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| ALLTRIM(x[2]) == "U6_CODENT"})],oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| x[2] == "U6_CONTATO"})])			}, STR0019,"TMK"})  //"Hist๓rico de Telemarketing"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotoes para listas de vendas.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aItemSel[7] == "2" .OR. aItemSel[7] == "4"
	AAdd(aButtons,{ "SIMULACAO" 	,	{|| Tk380SituaC(cAlias,oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| ALLTRIM(x[2]) == "U6_CODENT"})]) 	}, STR0020,STR0021}) //"Consulta Posi็ใo de Clientes"###"P. Cliente"
	AAdd(aButtons,{ "PRECO"		,	{|| OMSA010()										}, STR0022,STR0023}) //"Tabela de Pre็os"###"Pre็os"
	AAdd(aButtons,{ "HISTORIC"	,	{|| Tk380VisAcessorio(aItemSel[1])					}, STR0027,STR0028}) //"Consulta Acess๓rios"###"Acess๓rios"
	AAdd(aButtons,{ "AUTOM"		,	{|| Tk380HTlv(cAlias,oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| ALLTRIM(x[2]) == "U6_CODENT"})],oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| x[2] == "U6_CONTATO"})])						}, STR0029,STR0030})  //"Hist๓rico de Televendas"###"TLV"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotoes para listas de Cobranca. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aItemSel[7] == "3" .OR. aItemSel[7] == "4"
	AAdd(aButtons,{ "BUDGETY"	,	{|| Tk380Titulo(oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| ALLTRIM(x[2]) == "U6_CODENT"})],aItemSel[1])			}, STR0033,STR0034}) //"Consulta de Tํtulos"###"Tํtulos"
EndIf

If aItemSel[7] == "2" .OR. aItemSel[7] == "3" .OR. aItemSel[7] == "4"
	AAdd(aButtons,{ "NOTE"	,	{|| TmkC020A(,,.T.) }, STR0031,STR0032}) //"Hist๓rico de Cobran็as"###"Cobran็as"
EndIf	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada para adicionar novos botoes a tela de ณ
//ณMarketing Ativo.                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lUserBtn

	aUserBtn := ExecBlock( "TMK380BTN", .F., .F. )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFormato do Array de Retorno.ณ
	//ณ                            ณ
	//ณaUserBtn[nBtn,1]  RESOURCE  ณ
	//ณaUserBtn[nBtn,2]  ACTION    ณ
	//ณaUserBtn[nBtn,3]  TOOLTIP   ณ
	//ณaUserBtn[nBtn,4]  CTITLE    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInsere botoes de usuario na barra de ferramentas.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(aUserBtn) == "A"
		If Len(aUserBtn) > 0
			For nBtn := 1 To Len(aUserBtn)
				AAdd(aButtons,{ aUserBtn[nBtn][1],	&( "aUserBtn["+STRZERO(nBtn,2)+"][2]"),aUserBtn[nBtn][3],aUserBtn[nBtn][4]}) 
				//AAdd(aButtons,&("{ aUserBtn["+Str(nBtn)+"][1],	{|| aUserBtn["+STRZERO(nBtn,2)+"][2]},aUserBtn["+Str(nBtn)+"][3],aUserBtn["+Str(nBtn)+"][4]}")) 
			Next nBtn
		EndIf
	EndIf
EndIf

aSize := FWGetDialogSize(oMainWnd)

DEFINE MSDIALOG oDlgLista TITLE STR0035 + aItemSel[5]  FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL //"Lista de Contatos: "

	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlgLista,.F.)

	oFwLayer:addLine("LISTAS", 40, .F.)
	oFwLayer:addLine("DETALHES",35, .F.)
	oFwLayer:addLine("LEGENDAS",15, .F.)
	oFwLayer:addCollumn("DETALHES1",50,.T.,"DETALHES")
	oFwLayer:addCollumn("DETALHES2",50,.T.,"DETALHES")
	oFwLayer:addCollumn("LEGENDAS1",100,.T.,"LEGENDAS")
	
	oListas   := oFwLayer:getLinePanel("LISTAS")

	oFwLayer:addWindow("DETALHES1","WIN1",STR0037,100,.F.,.F.,/*[bAction]*/,"DETALHES",/*[bGotFocus]*/)	//'Detalhes do Contato'
	oFwLayer:addWindow("DETALHES2","WIN2",STR0038,100,.F.,.F.,/*[bAction]*/,"DETALHES",/*[bGotFocus]*/)	//'Detalhes da Lista'
	oFwLayer:addWindow("LEGENDAS1","WIN3",STR0098,100,.F.,.F.,/*[bAction]*/,"LEGENDAS",/*[bGotFocus]*/)	//'Legendas'
	
	oDetalhes1 := oFWLayer:GetWinPanel("DETALHES1","WIN1","DETALHES")
	oDetalhes2 := oFWLayer:GetWinPanel("DETALHES2","WIN2","DETALHES")
	oLegendas  := oFWLayer:GetWinPanel("LEGENDAS1","WIN3","LEGENDAS")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDocumenta็ใo da MsNewGetDados                                                                                                              ณ
	//ณ                                                                                                                                           ณ
	//ณMsNewGetDados():New                                                                                                                        ณ
	//ณ(nTop,nLeft,nBottom,nRight,nStyle,uLinhaOk,uTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,uSuperDel,uDelOk,oWnd,aParHeader,aParCols,uChange)ณ
	//ณ                                                                                                                                           ณ
	//ณnStyle - Substitui o nOpc                                                                                                                  ณ
	//ณ#define GD_INSERT	1                                                                                                                     ณ
	//ณ#define GD_UPDATE	2                                                                                                                     ณ
	//ณ#define GD_DELETE	4                                                                                                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	Processa({|lEnd|Tk380CFG(aItemSel[1],@aHeader,@aCols,@cAlias,.T.)},STR0036,,.T.)  //"Selecionando Itens da Lista..."
	
	oGetDados := MsNewGetDados():New(00,10,200,500,0,,,,,,4096,,,,oListas,aHeader,aCols)
	oGetDados:oBrowse:bChange := {||Tk380PCadastro(aCad_Panel,oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| x[2] == "U6_CONTATO"})],oPCadastro)}
	oGetDados:oBrowse:ALIGN:= CONTROL_ALIGN_ALLCLIENT
	    
	//Painel 1 - 'Detalhes do Contato'
	@ 0,0 MSPANEL oPCadastro VAR "" OF oDetalhes1 SIZE oDetalhes1:nClientWidth/2,oDetalhes1:nClientHeight/2

	oScrDet := TScrollBox():Create(oPCadastro,00,00,00,00,.T.,.F.,.F.)
	oScrDet:Align := CONTROL_ALIGN_ALLCLIENT
 
	@ 00, 00 SAY aCad_Panel[01,02] PROMPT STR0001 + FATPDObfuscate(aCad_Panel[01,01],"U5_CONTAT")	OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Nome: "
	@ 10, 00 SAY aCad_Panel[02,02] PROMPT STR0002 + FATPDObfuscate(aCad_Panel[02,01],"U5_END"	) 	OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Endere็o: "
	@ 20, 00 SAY aCad_Panel[03,02] PROMPT STR0003 + FATPDObfuscate(aCad_Panel[03,01],"U5_EST"	) 	OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Estado: "
	@ 30, 00 SAY aCad_Panel[04,02] PROMPT STR0004 + FATPDObfuscate(aCad_Panel[04,01],"U5_FONE"	)	OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Fone Res.: "
	@ 40, 00 SAY aCad_Panel[05,02] PROMPT STR0005 + FATPDObfuscate(aCad_Panel[05,01],"U5_FCOM1"	) 	OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Fone Com: "
	@ 50, 00 SAY aCad_Panel[06,02] PROMPT STR0101 + FATPDObfuscate(aCad_Panel[06,01],"U5_CELULAR") 	OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Celular: "
	@ 60, 00 SAY aCad_Panel[07,02] PROMPT STR0006 + FATPDObfuscate(aCad_Panel[07,01],"U5_EMAIL"	) 	OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"E-mail: "
	@ 70, 00 SAY aCad_Panel[08,02] PROMPT STR0104 + FATPDObfuscate(aCad_Panel[08,01],"U5_OBS"	)	OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,IIf(nTamObs > 50,30,10) //"Detalhes: "

	//Painel 2 - 'Detalhes da Lista'
	@ 05,05 MSPANEL oPLista VAR "" OF oDetalhes2 SIZE 290,60   

	oPLista:Align := CONTROL_ALIGN_ALLCLIENT

	Do Case
		Case VAL(aItemSel[9]) = VOZ
			
			If lU4nsts .And. (!Empty(Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_NSTATUS")))
				cData := Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_NSTATUS")
				cData := SubStr(cData,1,8) + " - " + SubStr(cData, 9)
			Else
				cData := Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_CONTATO") // Data da Lista de Aniversario
			EndIf
			@ 00, 000 SAY STR0039 + Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_FILTRO") OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10  //"Filtro da Lista: "
			@ 10, 000 SAY STR0040 + Iif(!Empty(cData),STR0041,STR0042) OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Lista de Aniversแrio: "###"Sim"###"Nใo"
			@ 10, 140 SAY STR0043 + cData  OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Data de Aniv.: "
			@ 20, 000 SAY STR0044 + Iif(Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_PROSPEC")='1',STR0041,STR0042) OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Periodicidade: "###"Sim"###"Nใo"
			@ 30, 000 SAY STR0045 OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Script: "
			
			DEFINE SBUTTON FROM 28 ,45 TYPE 15 PIXEL ACTION Tk380VisuScpt(aItemSel) ENABLE OF oPLista
			
		Case VAL(aItemSel[9]) = CROSSPOSTING
			If lU4nsts .And. (!Empty(Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_NSTATUS")))
				cData := Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_NSTATUS")
				cData := SubStr(cData,1,8) + " - " + SubStr(cData, 9)
			Else
				cData := Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_CONTATO") // Data da Lista de Aniversario
			EndIf
			@ 00, 000 SAY STR0039 + Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_FILTRO") OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10  //"Filtro da Lista: "
			@ 10, 000 SAY STR0040 + Iif(!Empty(cData),STR0041,STR0042) OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Lista de Aniversแrio: "###"Sim"###"Nใo"
			@ 10, 140 SAY STR0043 + cData  OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Data de Aniv.: "
			@ 20, 000 SAY STR0044 + Iif(Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_PROSPEC")='1',STR0041,STR0042) OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Periodicidade: "###"Sim"###"Nใo"
			@ 30, 000 SAY STR0046 OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Mensagem: "
			
			DEFINE SBUTTON FROM 28 ,45 TYPE 15 PIXEL ACTION Tk380VisuEmail(aItemSel) ENABLE OF oPLista

		Case VAL(aItemSel[9]) = MALADIRETA
			If lU4nsts .And. (!Empty(Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_NSTATUS")))
				cData := Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_NSTATUS")
				cData := SubStr(cData,1,8) + " - " + SubStr(cData, 9)
			Else
				cData := Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_CONTATO") // Data da Lista de Aniversario
			EndIf
			@ 00, 000 SAY STR0039 + Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_FILTRO") OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10  //"Filtro da Lista: "
			@ 10, 000 SAY STR0040 + Iif(!Empty(cData),STR0041,STR0042) OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Lista de Aniversแrio: "###"Sim"###"Nใo"
			@ 10, 140 SAY STR0043 + cData  OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Data de Aniv.: "
			@ 20, 000 SAY STR0044 + Iif(Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_PROSPEC")='1',STR0041,STR0042) OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 //"Periodicidade: "###"Sim"###"Nใo"
			@ 30, 000 SAY STR0047 + Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_MALADIR") OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 500,10 //"Arquivo: "
			@ 40, 000 SAY STR0048 OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	 //"Visualizar: "
			DEFINE SBUTTON FROM 38 ,45 TYPE 15 PIXEL ACTION Tk380VisuMala(aItemSel) ENABLE OF oPLista

		Case VAL(aItemSel[9]) = PENDENCIA
			@ 00, 000 SAY STR0039 + Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_FILTRO") OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10  //"Filtro da Lista: "
			@ 10, 000 SAY STR0049 + Posicione("SU4",1,xFilial("SU4")+aItemSel[1],"U4_CODLIG")+aTele[Val(aItemSel[7])] OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 			 //"Atendimento: "
			@ 40, 000 SAY STR0050 OF oPLista FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	 //"Hist๓rico: "
			DEFINE SBUTTON FROM 38 ,45 TYPE 15 PIXEL ACTION Tk380VisHist(aItemSel) ENABLE OF oPLista


	EndCase	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLegenda da tela de pre-atendimentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ 00,03 BITMAP oBmpVM ResName "BR_VERDE" OF oLegendas Size 10,10 NoBorder When .F. Pixel
	@ 00,15 SAY STR0099 OF oLegendas Color CLR_GREEN,CLR_WHITE PIXEL  	 //Contato disponivel

	@ 00,80 BITMAP oBmpV ResName "BR_VERMELHO" OF oLegendas Size 10,10 NoBorder When .F. Pixel 
	@ 00,90 SAY STR0100 OF oLegendas Color CLR_RED,CLR_WHITE PIXEL   //Contato em Uso

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o status da tabela de atendentes IN/OUT para o Monitorณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TkGrvSUV(__cUserId, "AGE1")

FATPDLogUser('TK380PCADA')	// Log de Acesso LGPD

ACTIVATE MSDIALOG oDlgLista CENTERED ON INIT;
	 EnchoiceBar(oDlgLista,	{|| Tk380OK(	aItemSel	,oGetDados:aCols	,oGetDados:aHeader	,oGetDados,; // Botao Ok
								   			oGetDados:nAt),;
								Processa({|lEnd|Tk380CFG(aItemSel[1],oGetDados:aHeader,oGetDados:aCols,@cAlias,.F.)},STR0036,,.T.),;  //"Selecionando Itens da Lista..."
								Iif(Len(oGetDados:aCols)=0,oDlgLista:End(),(oGetDados:Refresh(.T.),oDlgLista:Refresh(.T.),;
								Tk380PCadastro(aCad_Panel,oGetDados:aCols[oGetDados:nAt,Ascan(aHeader,{|x| x[2] == "U6_CONTATO"})],oPCadastro)))},;
							{||(TkGrvSUV(__cUserId, "AGE0"),oDlgLista:End())},,;// Botao Cancela
							aButtons)// Botoes adicionais.


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ'ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisContatoณAutor  ณRafael M. Quadrotti    ณData  ณ  23/12/03  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega a visualizacao dos dados do contato selecionado            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo do contato.                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAgenda do Operador                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                                บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ09/08/05ณ811   ณFNC 002607 - Criacao do array aRotina para ser     บฑฑ
ฑฑบ          ณ        ณ      ณutilizado na execucao da funcao axAltera.          บฑฑ
ฑฑบHenry  F. ณ16/08/05ณ811   ณFNC 002705 - Tratamento do array aRotina para ser  บฑฑ
ฑฑบ          ณ        ณ      ณutilizado na execucao da funcao axAltera.          บฑฑ 
ฑฑณFernando  |14/12/06| 9.12 ณBops 115439 Alterado a array aRotina  para 		 ณฑฑ
ฑฑณ        	 ณ        |      ณcria็ใo do menu funcional            	     		 ณฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380VisContato(cContato)

Local cCad	  		:= If( Type("cCadastro") == "U",Nil, cCadastro) 			// 	Salva o cCadastro atual
Local aRots   		:= If( Type("aRotina")   == "U",Nil, aClone(aRotina))		// 	Salva o aRotinas atual
Private cCadastro 	:= STR0051 				// "Manuten็ใo de Contato"

If Type("INCLUI")=="U"
	Private INCLUI := .T.
EndIf
If Type("ALTERA")=="U"
	Private ALTERA := .F.
EndIf

aRotina	:= MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe existir o contato, exibe os dados do cadastro.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cContato)
	DbSelectArea("SU5")
	DbSetOrder(1)

	If DbSeek(xFilial("SU5") + cContato)
		AxAltera("SU5",Recno(),4)
	Endif
Endif

If Type("cCadastro") <> "U" .And. Type("aRotina") <> "U" 
	cCadastro	:= cCad
	aRotina  	:= AClone(aRots)
Endif	

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |MenuDef	ณ Autor ณ Fernando Amorim       ณ Data ณ14/12/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de defini็ใo do aRotina                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRotina   retorna a array com lista de aRotina             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGATMK                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef() 

Local aRotina:= {	{ STR0055  	,"AxPesqui" ,0 , 1 , , .F.},;  //Pesquisar
					{ STR0056 	,"AxVisual" ,0 , 2 , , .T.},;  //Visualizar
			   		{ STR0102  	,"AxInclui" ,0 , 3 , , .T.},;  //Incluir
			   		{ STR0103  	,"AxAltera" ,0 , 4 , , .T.} }   //Alterar


				

							                                                     				
Return(ARotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisEntidadeณAutor  ณRafael M. Quadrotti    ณData  ณ  23/12/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณCarrega a visualizacao dos dados da entidade selecionada           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Alias da entidade.Ex.:SA1                                   บฑฑ
ฑฑบ          ณExpC2: Chave primaria da entidade.                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAgenda do Operador                                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                                บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ09/08/05ณ811   ณFNC 002607 - Criacao do array aRotina para ser     บฑฑ
ฑฑบ          ณ        ณ      ณutilizado na execucao da funcao axAltera.          บฑฑ
ฑฑบHenry  F. ณ16/08/05ณ811   ณFNC 002705 - Tratamento do array aRotina para ser  บฑฑ
ฑฑบ          ณ        ณ      ณutilizado na execucao da funcao axAltera.          บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380VisEntidade(cEntidade,cCodEnt)

Local nOpc 			:= 4
Local cCad	  		:= If( Type("cCadastro") == "U",Nil, cCadastro) 			// 	Salva o cCadastro atual
Local aRots   		:= If( Type("aRotina")   == "U",Nil, aClone(aRotina))		// 	Salva o aRotinas atual
Private cCadastro 	:= STR0052 				//	"Altera Entidade"
 
// Validacao para impedir acesso de usuarios que nao possuam acesso de "Alterar o Cadastro de Clientes" no Configurador
If !versenha(143) // 143 - "Alterar o Cadastro de Clientes"
	Help(" ",1,"SEMPERM")
	Return
Endif

If Type("INCLUI")=="U"
	Private INCLUI := .T.
EndIf
If Type("ALTERA")=="U"
	Private ALTERA := .F.
EndIf

aRotina	:= {	{ STR0055  	,"AxPesqui" ,0,1 },;           //"Pesquisar"
				{ STR0056 	,"AxVisual" ,0,2 },;           //"Visualizar"
				{ STR0091  	,"AxInclui" ,0,3 },;           //"Incluir"
				{ STR0092  	,"AxAltera" ,0,4 }}            //"Alterar"

// Para Clientes
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ A ocorrencia 82 (ACS), verifica se o usu rio poder  ou no alterar cadastros ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !ChkPsw(82)
	Help(" ",1,"TMKACETLV")  
	cCadastro := STR0053 //"Visualiza Entidade"
	nOpc := 2
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe existir a entidade exibe os dados do cadastro.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cEntidade)
	DbSelectArea(cEntidade)
	DbSetOrder(1)

	If DbSeek(xFilial(cEntidade) + cCodEnt)
		AxAltera(cEntidade,Recno(),nOpc)
	Endif
Endif

If Type("cCadastro") <> "U" .And. Type("aRotina") <> "U" 
	cCadastro	:= cCad
	aRotina  	:= AClone(aRots)
Endif	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk380VisEvento  ณ  AutorณRafael M. Quadrotti     ณData  ณ  23/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe o evento relacionado a Lista de Contatos        		        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo da Lista                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAgenda do Operador                                                 	บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380VisEvento(cLista)
Local aArea  := GetArea()
Local aSRotina := Iif(Type("aRotina")== "A",aClone(aRotina),{})
Private cCadastro := STR0054 									//	"Visualizao de Eventos"
PRIVATE aRotina := {  	{ STR0055 ,"AxPesqui"    , 0 , 1}  ,;	//	"Pesquisar"  //NAO PRECISA DE TRADUCAO //"Pesquisar"
						{ STR0056 ,"Tk340Eventos" , 0 , 2} }	//	"Visualizar" //CONTROLE INTERNO DO SISTEMA //"Visualizar"


INCLUI := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso esta lista tenha algum evento anexado, exibe os dados do evento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
If DbSeek(xFilial("SU4") + cLista,.T.)
	
	If !Empty(SU4->U4_EVENTO)
		DbSelectArea("ACD")
		DbSetOrder(1)
		
		If DbSeek(xFilial("ACD") + SU4->U4_EVENTO)
			Tk340Eventos("ACD",RECNO(),2)
		Else
			Help(" ",1,"SEMEVENTO") //Nao existe evento para esta campanha
		Endif
	Else
		Help(" ",1,"SEMEVENTO") //Nao existe evento para esta campanha
	Endif
Else
	Help(" ",1,"SEMLIGACAO") //Nao existe ligacoes para o operador
Endif

Iif(Len(aSRotina)>0,aRotina:=aClone(aSRotina),)
RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisProduto ณAutor  ณRafael M. Quadrotti     ณData  ณ  23/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe o produto relacionado a campanha da Lista de Contatos           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo da Lista                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAgenda do Operador                                                 	บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380VisProduto(cLista)
Local aArea  		:= GetArea()
Local aSRotina 		:= Iif(Type("aRotina")== "A",aClone(aRotina),{})
Local aProdutos 	:= {} 											// Array utilizado para listbox
Local nCont			:= 0											// Contador
Local oDlgProduto													// Tela para apresentacao dos produtos
Local oLbxProd														// Listbox dos produtos.
Local lHelp			:= .F.											// Variavel para nใo repetir a msg "SEMPRODUTO" caso nใo haja produto 

Private cCadastro := STR0057 //"Visualiza็ใo de Produtos"

INCLUI := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso esta lista tenha algum evento anexado, exibe os dados do evento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
If DbSeek(xFilial("SU4") + cLista,.T.)
	
	If !Empty(SU4->U4_CODCAMP)
		DbSelectArea("SUW")
		DbSetOrder(1)
   		If DbSeek(xFilial("SUW") + SU4->U4_CODCAMP)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLaco para selecionar todos os codigos de produto para visualizacao. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
			While 	!Eof() .AND. ;
					xFilial("SUW")==SUW->UW_FILIAL .AND. ;
					SUW->UW_CODCAMP == SU4->U4_CODCAMP
				
				If !Empty(SUW->UW_PRODUTO)
					Aadd(aProdutos,{SUW->UW_PRODUTO,""})
				EndIf
				DbSkip()
			End	
	
		Else
			Help(" ",1,"SEMPRODUTO") //Nao existe PRODUTO para esta campanha
			lHelp := .T.
		Endif
	Else
		Help(" ",1,"SEMPRODUTO") //Nao existe PRODUTO para esta campanha
		lHelp := .T.
	Endif
Else
	Help(" ",1,"SEMLIGACAO") //Nao existe ligacoes para o operador
Endif

If Len(aProdutos) > 0 
	DbSelectArea("SB1")
	DbSetOrder(1)
	For nCont := 1 To Len(aProdutos)
		If DbSeek(xFilial("SB1")+ aProdutos[nCont,1])
			aProdutos[nCont,2] := SB1->B1_DESC
	    Endif
    Next nCont

	DEFINE MSDIALOG oDlgProduto TITLE cCadastro FROM 00,00 TO 250,500 PIXEL	OF oMainWnd
		
		@02,02 TO 120,210 LABEL "" PIXEL OF oDlgProduto
		@05,04 LISTBOX oLbxProd FIELDS ;
			HEADER ;
			STR0012,;		 //"Produto"
			STR0058;	 //"Descri็ใo"
			SIZE 205,115 OF oDlgProduto PIXEL 
		
			oLbxProd:SetArray(aProdutos)
			oLbxProd:bLine:={||{aProdutos[oLbxProd:nAt,1],;
								aProdutos[oLbxProd:nAt,2]}}
			oLbxProd:Refresh()								
	
		DEFINE SBUTTON FROM 05,215 TYPE 1 ENABLE OF oDlgProduto ACTION (Posicione("SB1",1,xFilial("SB1")+aProdutos[oLbxProd:nAt,1],"B1_COD"),; //Posiciona registro
																		AxVisual("SB1",Recno(),2),;// Apresenta registro para visualizacao
																		oDlgProduto:End()) // Fecha Dlg
		DEFINE SBUTTON FROM 20,215 TYPE 2 ENABLE OF oDlgProduto ACTION oDlgProduto:End()
	
	ACTIVATE MSDIALOG oDlgProduto CENTERED
ElseIf !lHelp
	Help(" ",1,"SEMPRODUTO") //Nao existe PRODUTO para esta campanha
EndIf

Iif(Len(aSRotina)>0,aRotina:=aClone(aSRotina),)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisMidia   ณAutor  ณRafael M. Quadrotti     ณData  ณ  23/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a midia relacionada a Campanha da Lista de Contatos             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo da Lista                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAgenda do Operador                                                 	บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380VisMidia(cLista)
Local aArea  			:= GetArea()
Local aSRotina 		:= Iif(Type("aRotina")== "A",aClone(aRotina),{})
Local aMidias 		:= {}												// Array para listbox das midias.
Local nCont			:= 0												// Variavel para contador
Local oDlgMidia															// Interface para midias.
Local oLbxProd															// ListBox dos produtos.
Local lHelp			:= .F.												// Variavel para nใo repetir a msg "SEMMIDIA" caso nใo haja midia 														

Private cCadastro := STR0059 //"Visualiza็ใo de Midias"

INCLUI := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso esta lista tenha algum evento anexado, exibe os dados do evento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
If DbSeek(xFilial("SU4") + cLista,.T.)
	
	If !Empty(SU4->U4_CODCAMP)
		DbSelectArea("SUW")
		DbSetOrder(1)
   		If DbSeek(xFilial("SUW") + SU4->U4_CODCAMP)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLaco para selecionar todos os codigos de Midia para visualizacao. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
			While 	!Eof() .AND. ;
					xFilial("SUW")==SUW->UW_FILIAL .AND. ;
					SUW->UW_CODCAMP == SU4->U4_CODCAMP
				
				If !Empty(SUW->UW_MIDIA)
					Aadd(aMidias,{SUW->UW_MIDIA,""})
				EndIf
				DbSkip()
			End	
	
		Else
			Help(" ",1,"SEMMIDIA") //Nao existe Midia para esta campanha
			lHelp := .T.
		Endif
	Else
		Help(" ",1,"SEMMIDIA") //Nao existe Midia para esta campanha
		lHelp := .T.
	Endif
Else
	Help(" ",1,"SEMLIGACAO") //Nao existe ligacoes para o operador
Endif

If Len(aMidias) > 0 
	DbSelectArea("SUH")
	DbSetOrder(1)
	For nCont := 1 To Len(aMidias)
		If DbSeek(xFilial("SUH")+ aMidias[nCont,1])
			aMidias[nCont,2] := SUH->UH_DESC
	    Endif
    Next nCont

	DEFINE MSDIALOG oDlgMidia TITLE cCadastro FROM 00,00 TO 250,500 PIXEL	OF oMainWnd
		
		@02,02 TO 120,210 LABEL "" PIXEL OF oDlgMidia
		@05,04 LISTBOX oLbxProd FIELDS ;
			HEADER ;
			STR0014,;		 //"Midia"
			STR0058;	 //"Descri็ใo"
			SIZE 205,115 OF oDlgMidia PIXEL 
		
			oLbxProd:SetArray(aMidias)
			oLbxProd:bLine:={||{aMidias[oLbxProd:nAt,1],;
								aMidias[oLbxProd:nAt,2]}}
			oLbxProd:Refresh()								
	
		DEFINE SBUTTON FROM 05,215 TYPE 1 ENABLE OF oDlgMidia ACTION (Posicione("SUH",1,xFilial("SUH")+aMidias[oLbxProd:nAt,1],"UH_MIDIA"),; //Posiciona registro
																		AxVisual("SUH",Recno(),2),;// Apresenta registro para visualizacao
																		oDlgMidia:End()) // Fecha Dlg
		DEFINE SBUTTON FROM 20,215 TYPE 2 ENABLE OF oDlgMidia ACTION oDlgMidia:End()
	
	ACTIVATE MSDIALOG oDlgMidia CENTERED
ElseIf !lHelp
	Help(" ",1,"SEMMIDIA") //Nao existe Midia para esta campanha
EndIf

Iif(Len(aSRotina)>0,aRotina:=aClone(aSRotina),)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTk380SituaC ณ Autor ณRafael M. Quadrotti  ณ Data ณ 29/12/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณRotina para consultar a Situao Financeira do Cliente      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Alias da entidade. Ex: SA1                           บฑฑ
ฑฑบ          ณExpC2: Chave primaria da entidade                           บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณAgenda do Operador                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Tk380SituaC(cEntidade,cCodEnt)

Local aArea		:= GetArea()						//Salva a area atual
Local cCliente  := ""								//Codigo do Cliente 
Local cLoja     := ""                               //Loja do Cliente
Local cCadSave	:= ""          	  					//Salva o cCadastro
Local aRotSave	:= {}                       	    //Salva o aRotinas
Local lRet		:= .F.								//Retorno da funcao

cCadastro	:= STR0060 //"Consulta Posi็ใo Clientes"
aRotina		:= {	{ STR0055, "AxPesqui", 0, 1},;		//"Pesquisar" //"Pesquisar"
					{ STR0056, "AxVisual", 0, 2},;	//"Visualizar" //"Visualizar"
					{ STR0061, "FC010CON", 0, 2},;		//"Consultar" //"Consultar"
					{ STR0062, "FC010IMP", 0, 4}}		//"Impressใo" //"Impressใo"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsulta financeira somente para clientes            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (cEntidade <> "SA1")
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSeleciona o SF2 porque nao esta o MNU        			   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SF2")
	                                                    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe existir a entidade exibe os dados do cadastro			   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1") + cCodEnt)
	cCliente := SA1->A1_COD
	cLoja    := SA1->A1_LOJA
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se existe um cliente selecionado                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cCliente)
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso o Pergunte seja confirmado executa a consulta financeira.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Pergunte("FIC010",.T.)
	Fc010Con("SA1",SA1->(Recno()),2)
	lRet := .T.
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura o acols e aheader salvos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea(aArea)
cCadastro	:= cCadSave 	
aRotina		:= aClone(aRotSave)
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisAcessoriณAutor  ณRafael M. Quadrotti     ณData  ณ  23/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe os acessorios relacioandos ao produto definido na campanha.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Codigo da Lista                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAgenda do Operador                                                 	บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380VisAcessorio(cLista)
Local aArea  		:= GetArea()
Local aSRotina 		:= Iif(Type("aRotina")== "A",aClone(aRotina),{})
Local aProdutos 	:= {}
Local nCont			:= 0
Local oDlgProduto
Local oLbxProd
Local cProd			:= "" 	// Codigo do produto para verificacao dos acessorios.
Local cDAcess		:= "" 	// Descricao do Acessorio
Local aAcess		:= {} 	// Array com os itens do list box acessorios.	
Local aListaAcess	:= {} 
Local oDlgAcess				// Dialog para acessorios.

Private cCadastro := STR0063 //"Visualiza็ใo de Acess๓rios - Produto principal"

INCLUI := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso esta lista tenha algum evento anexado, exibe os dados do evento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
If DbSeek(xFilial("SU4") + cLista,.T.)
	
	If !Empty(SU4->U4_CODCAMP)
		DbSelectArea("SUW")
		DbSetOrder(1)
   		If DbSeek(xFilial("SUW") + SU4->U4_CODCAMP)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLaco para selecionar todos os codigos de produto para visualizacao. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
			While 	!Eof() .AND. ;
					xFilial("SUW")==SUW->UW_FILIAL .AND. ;
					SUW->UW_CODCAMP == SU4->U4_CODCAMP
				
				If !Empty(SUW->UW_PRODUTO)
					Aadd(aProdutos,{SUW->UW_PRODUTO,""})
				EndIf
				DbSkip()
			End	
	
		Else
			Help(" ",1,"SEMPRODUTO") //Nao existe PRODUTO para esta campanha
		Endif
	Else
		Help(" ",1,"SEMPRODUTO") //Nao existe PRODUTO para esta campanha
	Endif
Else
	Help(" ",1,"SEMLIGACAO") //Nao existe ligacoes para o operador
Endif

If Len(aProdutos) > 0 
	DbSelectArea("SB1")
	DbSetOrder(1)
	For nCont := 1 To Len(aProdutos)
		If DbSeek(xFilial("SB1")+ aProdutos[nCont,1])
			aProdutos[nCont,2] := SB1->B1_DESC
	    Endif
    Next nCont

	DEFINE MSDIALOG oDlgProduto TITLE cCadastro FROM 00,00 TO 250,500 PIXEL	OF oMainWnd
		
		@02,02 TO 120,210 LABEL "" PIXEL OF oDlgProduto
		@05,04 LISTBOX oLbxProd FIELDS ;
			HEADER ;
			STR0012,;		 //"Produto"
			STR0058;	 //"Descri็ใo"
			SIZE 205,115 OF oDlgProduto PIXEL 
		
			oLbxProd:SetArray(aProdutos)
			oLbxProd:bLine:={||{aProdutos[oLbxProd:nAt,1],;
								aProdutos[oLbxProd:nAt,2]}}
			oLbxProd:Refresh()								
	
		DEFINE SBUTTON FROM 05,215 TYPE 1 ENABLE OF oDlgProduto ACTION (cProd := aProdutos[oLbxProd:nAt,1],oDlgProduto:End()) // Fecha Dlg
		DEFINE SBUTTON FROM 20,215 TYPE 2 ENABLE OF oDlgProduto ACTION oDlgProduto:End()
	
	ACTIVATE MSDIALOG oDlgProduto CENTERED
Else
	Help(" ",1,"SEMPRODUTO") //Nao existe PRODUTO para esta campanha
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso selecionado um produto. Exibe os acessorios.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cProd)

	DbSelectarea("SUG")
	DbSetorder(2)
	If DbSeek(xFilial("SUG") + cProd)
		DbSelectarea("SU1")
		DbSetorder(1)
		If DbSeek(xFilial("SU1")+SUG->UG_CODACE)
			While ! Eof() .AND. U1_FILIAL == xFilial("SU1") .AND. U1_CODACE == SUG->UG_CODACE
			
				cDAcess := STR0064  //"Produto no encontrado"
				DbSelectarea("SB1")
				DbSetorder(1)
				If DbSeek(xFilial("SB1")+SU1->U1_ACESSOR)
					cDAcess := B1_DESC
				Endif
			
				DbSelectarea("SU1")
				cDACess	:=	LEFT(cDAcess,TAMSX3("B1_DESC")[1])
				Aadd(aAcess,{cDAcess,;						//Descricao do produto acessorio
							U1_LOCAL,;						//Local
							Transform(U1_QTD,"@E 999"),;	//Quantidade 	
							U1_OBS,;						//Observacao
							Tk380Box("U1_KIT")[Val(U1_KIT)]})						//KIT
							
				Aadd(aListaAcess,{	SU1->U1_ACESSOR,;			//Codigo do Acessorio
									SU1->U1_QTD})				//Quantidade
				SU1->(DbSkip())
			End
		Else
			Help(" ",1,"SEM ACESSO" )
		Endif
	Else
		Help(" ",1,"SEM ACESSO" )
	Endif
    
    If Len(aAcess)>0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Mostra dados dos Acessorios.    					         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE MSDIALOG oDlgAcess FROM  48,130 TO 250,740 TITLE STR0065 + cProd  PIXEL  //"Acess๓rios do produto "

			@ 3,5  TO  83,300 LABEL STR0066 OF oDlgAcess  PIXEL  //"Itens"
			@ 10,8 LISTBOX oLbxAcess FIELDS ;
					HEADER ;
					STR0012,; //"Produto"
					STR0067,;  //"Armazem"
					STR0068,;  //"Qtd."
					STR0069,;  //"Obs"
					STR0070 ; //"Kit"
				SIZE 290,70 OF oDlgAcess PIXEL;
					
			oLbxAcess:SetArray(aAcess)
			oLbxAcess:bLine:={|| {	aAcess[oLbxAcess:nAt,1],;				//Descricao do produto acessorio
					   				aAcess[oLbxAcess:nAt,2],;                //Local
									aAcess[oLbxAcess:nAt,3],;                //Quantidade
									aAcess[oLbxAcess:nAt,4],;                //Observacao
									aAcess[oLbxAcess:nAt,5]}}                //KIT
	
			DEFINE SBUTTON FROM 88,236 TYPE 1 ENABLE OF oDlgAcess ACTION oDlgAcess:End()  
			DEFINE SBUTTON FROM 88,268 TYPE 2 ENABLE OF oDlgAcess ACTION oDlgAcess:End()
        	
		ACTIVATE MSDIALOG oDlgAcess CENTER
	EndIf
EndIf

Iif(Len(aSRotina)>0,aRotina:=aClone(aSRotina),)
RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380HTmk บAutor  ณRafael M. Quadrotti บ Data ณ  30/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamada da funcao de historico de Tmk                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Alias da entidade. Ex: SA1                           บฑฑ
ฑฑบ          ณExpC2: Chave primaria da entidade                           บฑฑ
ฑฑบ          ณExpC3: Codigo do contato.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ01/04/05ณ811   ณ- BOPS 80627 - Atribuicao da variavel n na  บฑฑ
ฑฑบ          ณ        ณ      ณgetdados para compatibilizar com a chamada  บฑฑ
ฑฑบ          ณ        ณ      ณde historico de ligacoes do TLV.            บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

*/
Static Function Tk380HTmk(cEntidade,cChave,cCodCont)

Local nTipo  := 1 								// Tipo da Consulta 1 = Contato, 2 = Entidade
Local aArea  := GetArea()						// Salva a area atual
Local lRet	 := .F.            					// Retorno da funcao

Private aCols  	:= {}
Private aHeader := {}   
Private INCLUI	:= .F.
Private n		:= 1							// Posicao do aCols inicial
Private aRotina := {	{ ""  ,"" ,0,1 },; 	
						{ ""  ,"" ,0,2 },; 	
						{ ""  ,"" ,0,3 },; 	
						{ ""  ,"" ,0,4 },;  
						{ ""  ,"" ,0,2} } 	


DbSelectarea("SUC")
DbSetorder(2)
If !DbSeek(xFilial("SUC") + cEntidade + cChave)
	DbSetorder(6)
	If DbSeek(xFilial("SUC") + cCodCont)
		Aviso(STR0071,STR0072,{"OK"}) //"Aten็ใo""Sera exibido apenas o historico do Contato"
		nTipo := 1 
	Else
		Help(" ",1,"SEMDADOS" )
		Return(lRet)
	Endif
Endif	
RegToMemory( "SUC", .F., .F. ) // terceiro como false.

M->UC_ENTIDAD 	:= cEntidade
M->UC_CHAVE 	:= cChave
M->UC_CODCONT 	:= cCodCont
M->UC_DESCCHAV	:= TkEntidade(M->UC_ENTIDAD,M->UC_CHAVE,nTipo)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do aHeader                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SUD")
While ( !Eof() .AND. (SX3->X3_ARQUIVO == "SUD") )
	
	If ( X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL )

		Aadd(aHeader,{ 	AllTrim(X3Titulo())	,;	//01
						SX3->X3_CAMPO		,;	//02
						SX3->X3_PICTURE		,;	//03
						SX3->X3_TAMANHO		,;	//04
						SX3->X3_DECIMAL		,;	//05
						SX3->X3_VALID		,;	//06	
						SX3->X3_USADO		,;	//07
						SX3->X3_TIPO		,;	//08
						SX3->X3_F3			,;	//09
						SX3->X3_CONTEXT } )		//10
					Endif
	
	DbSelectArea("SX3")
	DbSkip()
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do aCols                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aCols,Array(Len(aHeader)+ 1))
aCols[Len(aCols)][Len(aHeader) + 1] := .F.

Tk272HTmk(	2	,.T.	,NIL	,NIL,;
			NIL	,NIL	,nTipo)

RestArea(aArea)
lRet := .T.

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380HTlv บAutor  ณRafael M. Quadrotti บ Data ณ  30/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamada da funcao de historico de Tlv                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Alias da entidade. Ex: SA1                           บฑฑ
ฑฑบ          ณExpC2: Chave primaria da entidade                           บฑฑ
ฑฑบ          ณExpC3: Codigo do contato.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMarcelo K.ณ23/02/05ณ8.11  ณBOPS:                                       บฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk380HTlv(cEntidade,cChave,cCodCont)
Local aArea 	 	:= GetArea()																	// Salva a area atual
Local cCliente	 	:= Substr(cChave,1,TAMSX3("UA_CLIENTE")[1])										// Codigo do Cliente/Prospect
Local cLoja		 	:= Rtrim(Substr(cChave,(TAMSX3("UA_CLIENTE")[1])+1,TAMSX3("UA_CLIENTE")[1]))		// Codigo da Loja
Local lRet			:= .F.																	// Retorno da funcao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCompatibilizacao com o TMKA271 - Fonte principal das rotinas de atendimentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lProspect	:= .T.																	// Flag que indica se e um prospect (.T.) ou nao (.F.)	
Private aCols  		:= {}																	// aCols do Televendas - SUB
Private aHeader 	:= {}																	// aHeader do Televendas - SUB
Private INCLUI		:= .F.																	// FLAG de INCLUSAO da ENCHOICE
Private n			:= 1																	// Posicao do aCols inicial

Private aRotina 	:= {	{ ""  ,"" ,0,1 },; 												// aRotinas
							{ ""  ,"" ,0,2 },; 	
							{ ""  ,"" ,0,3 },; 	
							{ ""  ,"" ,0,4 },;  
							{ ""  ,"" ,0,2} } 	


If cEntidade == "SUS"
	lProspect := .T.
ElseIf cEntidade == "SA1"
	lProspect := .F.
Else
	Help(" ",1,"TMK380ATTE")	//"O atendimento televendas ้ efetuado somente para Prospects ou Clientes"
	Return(lRet)
EndIf

DbSelectarea( "SUA" )
DbSetorder(7)
If !DbSeek(xFilial("SUA") + cCliente + cLoja)
	Help(" ",1,"SEMDADOS" )
	Return(lRet)
Endif

RegToMemory( "SUA", .F., .F. ) // terceiro como false.

M->UA_CLIENTE := cCliente
M->UA_LOJA    := cLoja
M->UA_DESCCLI := POSICIONE("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do aHeader                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SUB")
While ( !Eof() .AND. (SX3->X3_ARQUIVO == "SUB") )
	
	If ( X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL )

		Aadd(aHeader,{ 	AllTrim(X3Titulo())	,;	//01
						SX3->X3_CAMPO		,;	//02
						SX3->X3_PICTURE		,;	//03
						SX3->X3_TAMANHO		,;	//04
						SX3->X3_DECIMAL		,;	//05
						SX3->X3_VALID		,;	//06	
						SX3->X3_USADO		,;	//07
						SX3->X3_TIPO		,;	//08
						SX3->X3_F3			,;	//09
						SX3->X3_CONTEXT } )		//10
					Endif
	
	DbSelectArea("SX3")
	DbSkip()
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do aCols                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aCols,Array(Len(aHeader)+ 1))
aCols[Len(aCols)][Len(aHeader) + 1] := .F.

Tk273HTlv(	2	 	,.T.	,NIL	,NIL,;
			NIL	 	,NIL	,NIL	,NIL,;
			NIL	 	,NIL	,NIL	,NIL,;
			NIL	 	,NIL	,NIL	,NIL,;
			NIL	 	,NIL	,NIL	,NIL,;
			NIL	 	,NIL	,NIL	,NIL,;
			NIL  	,NIL	,NIL	,NIL,;
			NIL		,NIL)

RestArea(aArea)
lRet := .T.

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380TituloบAutor  ณMarcelo Kotaki     บ Data ณ  12/19/02   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Exibe os titulos vencidos do cliente                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametos ณExpC1: Codigo da entidade                                   บฑฑ
ฑฑบ          ณExpC2: Codigo da Lista de Contatos                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMKA380 - Agenda do Operador                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Tk380Titulo(cCodEnt,cLista)

Local aArea		:= GetArea()
Local nTitulo	:= 0                               			// Titulo selecionado
Local oVerd		:= LoadBitmap(GetResources(),"ENABLE")		// [0] Verde
Local oVerm		:= LoadBitmap(GetResources(),"DISABLE")	// [0] Vermelho
Local oDlg                                          		// Dialog com Titulos
Local oTitulos												// Listbox com titulos vencidos
Local aTitulos  := {}	    								// Array com os titulos do cliente que serao cobrados

#IFNDEF TOP
	Local nTotCham	:= 0										// Conta o total de chamadas realizadas
	Local aAreaAux	:= {}
#ENDIF

#IFDEF TOP
	Local cQuery	:= ""                          			// Query para TOP
#ENDIF

DbSelectArea("SU4")
DbSetOrder(1)
If DbSeek(xFilial("SU4") + cLista)
	If (SU4->U4_TIPO == "2") //Cobranca

		CursorWait()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSeleciona os titulos atrasados do cliente atual.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SE1")
		DbSetOrder(2)
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				cQuery :=	" SELECT E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_VENCREA, E1_SALDO, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_IRRF, " +;
							"        E1_TIPO, E1_EMISSAO, E1_VENCTO, E1_VENCORI, E1_VALOR, E1_DESCONT, E1_MULTA, E1_JUROS, E1_CORREC, E1_ISS " +;
							" FROM " + RetSqlName("SE1") + " SE1 " +;
							" WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND " +;
							"       SE1.E1_CLIENTE = '" + SubStr(AllTrim(cCodEnt),1,TamSx3("A1_COD")[1]) + "' AND " +;
							"       SE1.E1_LOJA    = '" + SubStr(AllTrim(cCodEnt),TamSx3("A1_COD")[1]+1,TamSx3("A1_LOJA")[1]) + "' AND "
				
				If !SuperGetMv("MV_TMKTLCT")
					cQuery += "    SE1.E1_VENCREA < '" + DtoS(dDataBase) + "' AND "
				Endif
				
				//ฺฤฤTELECOBRANCAฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณNeste ponto da query esta sendo tratando se a lista de inadimplentes eh diferenciada, ondeณ
				//ณa quantidade de cobrancas feitas para cada titulo eh considerada, pois influencia no trataณ
				//ณmento dado pelo operador que estah gerando a lista de inadimplencia.                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty(SU4->U4_LOJA)		// neste campo esta sendo gravado o nChamadas (quantidade de cobrancas feitas para cada titulo)
					cQuery+= SU4->U4_LOJA + " = (SELECT COUNT(*) "
					cQuery+= " FROM " + RetSqlName("ACG") + " ACG "
					cQuery+= " WHERE ACG.ACG_FILIAL   = '" + xFilial("ACG")  + "' AND "
					cQuery+= "       ACG.ACG_PREFIX   = SE1.E1_PREFIXO AND "
					cQuery+= "       ACG.ACG_TITULO   = SE1.E1_NUM AND "
					cQuery+= "       ACG.ACG_PARCEL   = SE1.E1_PARCELA AND "
					cQuery+= "       ACG.ACG_TIPO     = SE1.E1_TIPO AND "
					cQuery+= "       ACG.D_E_L_E_T_ <> '*') AND "
				EndIf
		
				cQuery +=	"       SE1.E1_SALDO > " + "0" + " AND " +;
							"       SE1.D_E_L_E_T_ <> '*' " +;
							" ORDER BY " + SqlOrder(IndexKey())
				
				cQuery := ChangeQuery(cQuery)
				// MemoWrite("Tk380Titulo.SQL", cQuery)
				DbSelectArea("SE1")
				DbCloseArea()
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)
				
				TCSetField('SE1', 'E1_EMISSAO', 'D')
				TCSetField('SE1', 'E1_VENCTO' , 'D')
				TCSetField('SE1', 'E1_VENCORI', 'D')
				TCSetField('SE1', 'E1_VENCREA', 'D')
				TCSetField('SE1', 'E1_VALOR'  , 'N', 14,2)
				TCSetField('SE1', 'E1_SALDO'  , 'N', 14,2)
				TCSetField('SE1', 'E1_DESCONT', 'N', 14,2)
				TCSetField('SE1', 'E1_MULTA'  , 'N', 14,2)
				TCSetField('SE1', 'E1_JUROS'  , 'N', 14,2)
				TCSetField('SE1', 'E1_CORREC' , 'N', 14,2)
				TCSetField('SE1', 'E1_IRRF'   , 'N', 14,2)
				TCSetField('SE1', 'E1_ISS'    , 'N', 14,2)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณValidacao de ambiente. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				lQuery := .T.
			Else
		#ENDIF
				DbSeek(xFilial("SE1") + ALLTRIM(cCodEnt))
		#IFDEF TOP
			Endif		
		#ENDIF	
		
		cCodEnt := SubStr(cCodEnt,1,TamSx3("A1_COD")[1])+SubStr(cCodEnt,TamSx3("A1_COD")[1]+1,TamSx3("A1_LOJA")[1])
		While !Eof() .AND. (SE1->E1_FILIAL == xFilial("SE1")) .AND. (SE1->E1_CLIENTE + SE1->E1_LOJA == cCodEnt)

			#IFNDEF TOP
				If SE1->E1_SALDO == 0
					DbSkip()
					Loop
				Endif
			
				If SuperGetMv("MV_TMKTLCT")
					If SE1->E1_VENCREA >= DtoS(dDataBase)
						DbSkip()
						Loop
					Endif
				Endif
				
				If !Empty(SU4->U4_LOJA)
					aAreaAux := GetArea()
					DbSelectArea("ACG")
					DbSetOrder(2)
					If DbSeek(xFilial("ACG") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
						While	!Eof() .and.;
								ACG->ACG_PREFIX == SE1->E1_PREFIXO .and.;
								ACG->ACG_TITULO == SE1->E1_NUM .and.;
								ACG->ACG_PARCEL == SE1->E1_PARCELA .and.;
								ACG->ACG_TIPO == SE1->E1_TIPO
								nTotCham++
								DbSkip()
						End
					EndIf
					If Val(SU4->U4_LOJA) <> nTotCham
						DbSkip()
						Loop
					EndIf
					nTotCham := 0
					RestArea(aAreaAux)
				EndIf
				
			#ENDIF
			
			If SE1->E1_VENCREA < dDataBase
				lVencido := .F.
			Else
				lVencido := .T.
			Endif
		
			AAdd( aTitulos, {	lVencido,;
								SE1->E1_PREFIXO,;
								SE1->E1_NUM,;
								SE1->E1_PARCELA,;
								SE1->E1_TIPO,;
								DTOC(SE1->E1_EMISSAO),;
								DTOC(SE1->E1_VENCTO),;
								DTOC(SE1->E1_VENCREA),;
								DTOC(SE1->E1_VENCORI),;
								TRANSFORM(SE1->E1_VALOR, PESQPICT("SE1", "E1_VALOR")),;
								TRANSFORM(SE1->E1_SALDO, PESQPICT("SE1", "E1_SALDO")),;
								TRANSFORM(SE1->E1_DESCONT, PESQPICT("SE1", "E1_DESCONT")),;
								TRANSFORM(SE1->E1_MULTA, PESQPICT("SE1", "E1_MULTA")),;
								TRANSFORM(SE1->E1_JUROS, PESQPICT("SE1", "E1_JUROS")),;
								TRANSFORM(SE1->E1_CORREC, PESQPICT("SE1", "E1_CORREC")),;
								TRANSFORM(SE1->E1_IRRF, PESQPICT("SE1", "E1_IRRF")),;
								TRANSFORM(SE1->E1_ISS, PESQPICT("SE1", "E1_ISS"));
							} )

			DbSkip()
		End           
		
		If (Len(aTitulos) == 0)
			AAdd(aTitulos,{.F., "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""} )
		Else
			Asort( aTitulos,,, { |x,y| CtoD(x[8]) < CtoD(y[8]) } )
		Endif
		
		CursorArrow()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria tela para a escolha do titulo a ser negociado.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DEFINE MSDIALOG oDlg TITLE STR0074 FROM 00,00 TO 250,500 PIXEL OF oMainWnd  //"Titulos"

			@ 05,04	LISTBOX oTitulos FIELDS;
					HEADER	"",;					// Vermelho: Vencido ou Verde: a vencer
						 	STR0075,; //"Prefixo"
							STR0076,; //"Numero"
							STR0077,; //"Parcela"
							STR0078,; 	 //"Tipo"
							STR0079,; 	 //"Emissao"
							STR0080,; //"Vencimento"
							STR0081,; 	 //"Venc.Real"
							STR0082,;	 //"Venc.Original"
							STR0083,;	 //"Valor"
							STR0084,; //"Saldo"
							STR0085,; //"Desconto"
							STR0086,; //"Multa"
							STR0087,; //"Juros"
							STR0088,; //"Correcao"
							STR0089,; //"IRRF"
							STR0090; //"ISS"
					ON CHANGE (nTitulo:= oTitulos:nAt) SIZE 205,115 OF oDlg PIXEL NOSCROLL
		
			oTitulos:SetArray(aTitulos)
			oTitulos:bLine:={||{IIf(aTitulos[oTitulos:nAt,1],oVerd,oVerm),;
							 	aTitulos[oTitulos:nAt,2],;
							 	aTitulos[oTitulos:nAt,3],;
							 	aTitulos[oTitulos:nAt,4],;
							 	aTitulos[oTitulos:nAt,5],;
							 	aTitulos[oTitulos:nAt,6],;
							 	aTitulos[oTitulos:nAt,7],;
							 	aTitulos[oTitulos:nAt,8],;
							 	aTitulos[oTitulos:nAt,9],;
							 	aTitulos[oTitulos:nAt,10],;
							 	aTitulos[oTitulos:nAt,11],;
							 	aTitulos[oTitulos:nAt,12],;
							 	aTitulos[oTitulos:nAt,13],;
							 	aTitulos[oTitulos:nAt,14],;
							 	aTitulos[oTitulos:nAt,15],;
							 	aTitulos[oTitulos:nAt,16],;
							 	aTitulos[oTitulos:nAt,17]}}
		
			oTitulos:Refresh()
	

			DEFINE SBUTTON FROM 05,215 TYPE 1 ENABLE OF oDlg ACTION (aTitulos:= {},oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED
		
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				DbSelectArea("SE1")
				DbCloseArea()
				ChkFile("SE1")
			Endif
		#ENDIF
	Else
		Help(" ",1,"SEMDADOS" )	
	Endif
Else
	Help(" ",1,"SEMDADOS" )
Endif

RestArea(aArea)

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380CallCenter บ Autor ณRafael M. Quadrotti     บData  ณ  14/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAciona a tela de atendimento									        บฑฑ
ฑฑบ          ณEssa tela deve sempre estar compatibilizada com o TMKA271		        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametos ณExpC1: Codigo do contato                                    			บฑฑ
ฑฑบ          ณExpC2: Entidade (alias)                               			    บฑฑ
ฑฑบ          ณExpC3: Chave primaria da entidade          			                บฑฑ
ฑฑบ          ณExpN4: Registro                       	                            บฑฑ
ฑฑบ          ณExpN5: Opcao da tela de atendimento.	                                บฑฑ
ฑฑบ          ณExpA6: Array com os dados do titulo para atendimento ATIVO DO TLC     บฑฑ
ฑฑบ          ณExpC7: Mensagem a Exibir na Tela de Atendimento                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA380 - Agenda do Operador                                       	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380CallCenter(cCodCont,cEntidade,cChave,nReg,nOpc,aTlc,cMens)
Local cCodigo   := ""		//Codigo do cliente
Local cLoja     := ""		//Codigo da loja	
Local cAlias 	:= "SU5"	//Alias Default para o atendimento = TODOS	
Local cVarAux   := ""		// Variavel auxiliar para tratamento do Tipo de Atendimento.
Default cMens	:= ""

SaveInter()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis de compatibilizacao com a tela de atendimento do CALL CENTERณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aRotina := {}                      
Private lRefresh:= .T.
Private cCadastro 	:= STR0017 // Atendimento Call Center Receptivo

If Type( "INCLUI" ) == "U"
	Private INCLUI := .F.
EndIf

If Type( "ALTERA" ) == "U"
	Private ALTERA := .F.
EndIf

If nOpc == 3    
	INCLUI := .T.
	ALTERA := .F.
ElseIf nOpc == 4
	INCLUI := .F.
	ALTERA := .T.
Else
	INCLUI := .F.
	ALTERA := .F.
EndIf

Do Case
	Case (TkGetTipoAte() $ "123") //Se o tipo de atendimento do Operador estiver com qualquer opcao
		aRotina	:= {	{ STR0055  ,"AxPesqui"        ,0,1 },;  //"Pesquisar"
						{ STR0056  ,"TK271CallCenter" ,0,2 },;  //"Visualizar"
						{ STR0091  ,"TK271CallCenter" ,0,3 },;  //"Incluir"
						{ STR0092  ,"TK271CallCenter" ,0,4 }}  //"Alterar"

		Do Case
			Case (TkGetTipoAte() == "1") //Telemarketing                
				cAlias := "SUC"
				
			Case (TkGetTipoAte() == "2") //Televendas
				cAlias := "SUA"
				
			Case (TkGetTipoAte() == "3") //Telecobranca
				cAlias := "ACF"
		EndCase

	Otherwise                                             
	    
		cVarAux := TkGetTipoAte()
		If (!(cVarAux $ "123"))
			Help(" ",1,"FALTA_OPER")
			Return(.F.)
		Endif	

	
		aRotina		:= {  	{ STR0055,"AxPesqui"       ,0,1 },; //"Pesquisar"
							{ STR0056,"AxVisual"       ,0,2 },; //"Visualizar"
							{ STR0093,"TK271CallCenter",0,3 }}   //"Chamadas"
EndCase
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSepara o Codigo e a Loja ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCodigo := SubStr(cChave,1,TamSX3("A1_COD")[1])
cLoja   := SubStr(cChave,TamSX3("A1_COD")[1]+1,TamSX3("A1_LOJA")[1])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a tela de atendimento.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TK271CallCenter(cAlias,nReg,nOpc,Nil,cCodigo,cLoja,cCodCont,cEntidade,aTlc,NIL,NIL,cMens)

RestInter()
	
Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออัออออออออออออออออออออหอออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisuScptบAutorณRafael M. Quadrotti บ Dataณ  01/14/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออฯออออออออออออออออออออสอออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apresenta informacoes do script dinamico.				  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Item selecionado na agenda                 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 Agenda do Operador                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK380VisuScpt(aItemSel)
Local aArea  := GetArea()
Local aSRotina := Iif(Type("aRotina")== "A",aClone(aRotina),{})

Private cCadastro := STR0094 //"Visualizao de Scripts"
PRIVATE aRotina := {  	{ STR0055 ,"AxPesqui"    , 0 , 1}  ,;//"Pesquisar"  //NAO PRECISA DE TRADUCAO //"Pesquisar"
						{ STR0056 ,"TK360Visual" , 0 , 2} }//"Visualizar" //CONTROLE INTERNO DO SISTEMA //"Visualizar"


INCLUI := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso esta lista tenha algum evento anexado, exibe os dados do evento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
If DbSeek(xFilial("SU4") + aItemSel[1],.T.)
	
	If !Empty(SU4->U4_SCRIPT)
		DbSelectArea("SUZ")
		DbSetOrder(1)
		
		If DbSeek(xFilial("SUZ") + SU4->U4_SCRIPT)
			TK360Visual("SUZ", RECNO(),2)
		Else
			Help(" ",1,"SEMDADOS") //Nao existem dados para a consulta
		Endif
	Else
		Help(" ",1,"SEMDADOS") //Nao existem dados para a consulta
	Endif
Else
	Help(" ",1,"SEMDADOS") //Nao existem dados para a consulta
Endif

Iif(Len(aSRotina)>0,aRotina:=aClone(aSRotina),)
RestArea(aArea)


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออออหออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisuEmailบAutorณRafael M. Quadrotti บDataณ  01/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออออสออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apresenta informacoes do email de Cross Posting	          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Item selecionado na agenda                 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 Agenda do Operador                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ26/07/05ณ8.11  ณBOPS:83480 - Exibir o arquivo anexo que seraบฑฑ
ฑฑบ          ณ        ณ      ณencaminhado no e-mail.                      บฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380VisuEmail(aItemSel)
Local aArea 		:= GetArea() 	//Salva a area para posterior restauracao.
Local cAssunto      := ""			//Informacao do assunto do e-mail
Local cAttach		:= ""			//Anexo do e-mail
Local cMensagem		:= ""			//Mensagem do e-mail
Local aAttach		:= {}			//Array com as informacoes do anexo.
Local nX 			:= 0			//Contador do For.
Local cAux			:= ""			//Variavel auxiliar para geracao do array com arquivos anexos.

DbSelectArea("SU4")
DbSetorder(1)
If DbSeek(xFilial("SU4")+aItemSel[1]) // Lista de Contatos.
    
	RegToMemory( "SU4", .F., .F. ) // terceiro como false.	

	cMensagem   := IIF(!Empty(SU4->U4_CODMENS),MSMM(SU4->U4_CODMENS,80),Space(400))
	cAssunto    := SU4->U4_ASSUNTO
	cAttach     := ALLTRIM(SU4->U4_ATTACH) + Chr(10)
	
	For nX:=1 To Len(cAttach)
		If SubStr(cAttach,nX,1) <> Chr(10)
			cAux += SubStr(cAttach,nX,1)
		Else
            Aadd(aAttach,cAux)
            cAux := ""
		EndIf
	Next nX
	
	Tk061Email(2,cMensagem,cAssunto,aAttach,cAttach)
Else
	Help(" ",1,"SEMDADOS") //Nao existem dados para a consulta
Endif
RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออออหออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisuMala บAutorณRafael M. Quadrotti บDataณ  01/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออออสออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apresenta informacoes do arquivo de Mala direta/Etiqueta   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 Agenda do Operador                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380VisuMala(aItemSel)
Local aArea := GetArea()
          
DbSelectArea("SU4")
DbSetorder(1)
If DbSeek(xFilial("SU4")+aItemSel[1]) // Lista de Contatos.
    
	RegToMemory( "SU4", .F., .F. ) // terceiro como false.	

	Tk061Visual()

Else
	Help(" ",1,"SEMDADOS") //Nao existem dados para a consulta
EndIf

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออออหออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk380VisHist  บAutorณRafael M. Quadrotti บDataณ  01/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออออสออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apresenta informacoes do historico do atendimento.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Item selecionado na agenda                 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 Agenda do Operador                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380VisHist(aItemSel)
Local aArea 	:= GetArea() 
Local cAlias	:= ""							//Alias do atendimento para pesquisa.
Local cHist		:= ""							//Texto com o hist๓rico do atendimento.
Local oHist	
Local oDlg		

DbSelectArea("SU4")
DbSetorder(1)
If DbSeek(xFilial("SU4")+aItemSel[1]) // Lista de Contatos.
	If !Empty(SU4->U4_CODLIG)
    	Do Case
    		Case SU4->U4_TELE == "1" //TeleMarketing.
    			cAlias := "SUC"
    		Case SU4->U4_TELE == "2" //TeleVendas.
    			cAlias := "SUA"
    		Case SU4->U4_TELE == "3" //TeleCobran็a.
    			cAlias := "ACF"
    	EndCase 
    	If !Empty(cAlias)
			DbSelectArea(cAlias)
			DbSetOrder(1)
			If DbSeek(xFilial(cAlias)+SU4->U4_CODLIG)
				If cAlias = "SUC"
					If !Empty(SUC->UC_CODOBS)
						cHist:= MSMM(SUC->UC_CODOBS,TamSx3("UC_OBS")[1])
					EndIf
				ElseIf cAlias = "SUA"
					If !Empty(SUA->UA_CODOBS)
						cHist:= MSMM(SUA->UA_CODOBS,TamSx3("UA_OBS")[1])					
					EndIf
				ElseIf cAlias = "ACF"
					If !Empty(ACF->ACF_CODOBS)
						cHist:= MSMM(ACF->ACF_CODOBS,TamSx3("ACF_OBS")[1])										
					EndIf
				EndIf
			EndIf
    	EndIf
    EndIf	
EndIf

If !Empty(cHist)
	DEFINE MSDIALOG oDlg FROM 0,0 TO 200,400 TITLE STR0095 PIXEL //"Hist๓rico do Atendimento"
		@ 05,05 GET oHist VAR cHist MULTILINE SIZE 190, 80 OF oDlg PIXEL WHEN .T. READONLY
		DEFINE SBUTTON FROM 85,170 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออออหออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTk380PCadastro บAutor  ณRafael M. QuadrottiบDataณ12/17/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออออสออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza painel de cadastro do contato.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as informacoes do painel 1 de cadastro.    บฑฑ
ฑฑบ          ณExpC1: Str com o codigo do contato.                         บฑฑ 
ฑฑบ          ณExpO1: Objeto do painel de pendecia.                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบConrado Q.ณ27/09/06ณ8.11  ณBOPS:107460 - Adicionado celular no painel  บฑฑ
ฑฑบ          ณ        ณ      ณde detalhes do contato.                     บฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380PCadastro(aCad_Panel,cContato,oPCadastro)
Local x := 0 // Contador para FOR
Local cChave := ""

DbSelectArea("SU5")
DbSetOrder(1)

If DbSeek(xFilial("SU5")+cContato)// Codigo do contato.
	cChave := xFilial("AGB") + "SU5" + PadR(cContato,GetSx3Cache("AGB_CODENT","X3_TAMANHO"))
	aCad_Panel[01,1] := SU5->U5_CONTAT 	//"Nome: "
	aCad_Panel[02,1] := SU5->U5_END 	//"Endere็o: "
	aCad_Panel[03,1] := SU5->U5_EST 	//"Estado: "
	aCad_Panel[04,1] := AllTrim(Posicione("AGB",1,cChave + "21","AGB_DDI")) +;
						" (" + AllTrim(Posicione("AGB",1,cChave + "21","AGB_DDD")) + ") " + SU5->U5_FONE 	//"Fone Res.: "
	aCad_Panel[05,1] := AllTrim(Posicione("AGB",1,cChave + "11","AGB_DDI")) +;
						" (" + AllTrim(Posicione("AGB",1,cChave + "11","AGB_DDD")) + ") " + SU5->U5_FCOM1 	//"Fone Com: "
	aCad_Panel[06,1] := AllTrim(Posicione("AGB",1,cChave + "51","AGB_DDI")) +;
						" (" + AllTrim(Posicione("AGB",1,cChave + "51","AGB_DDD")) + ") " + SU5->U5_CELULAR //"Celular: "	
	aCad_Panel[07,1] := SU5->U5_EMAIL 	//"E-mail: "
	aCad_Panel[08,1] := SU5->U5_OBS 	//"Detalhes: "
	
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa informacoes do painel de contatos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCad_Panel[01,1]:= "" //"Nome: "
	aCad_Panel[02,1]:= "" //"Endere็o: "
	aCad_Panel[03,1]:= "" //"Estado: "
	aCad_Panel[04,1]:= "" //"Fone Res.: "
	aCad_Panel[05,1]:= "" //"Fone Com: "                     
	aCad_Panel[06,1]:= "" //"Celular: "
	aCad_Panel[07,1]:= "" //"E-mail: "
	
EndIf	
	
For x := 1 To Len(aCad_Panel)
	aCad_Panel[x][2]:Refresh() 
Next x

oPCadastro:Refresh()

Return Nil 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

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
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

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
