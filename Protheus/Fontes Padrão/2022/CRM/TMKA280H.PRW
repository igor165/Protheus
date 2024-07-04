#INCLUDE "TMKA280H.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk280TLC08บAutor  ณArmando M. Tessaroliบ Data ณ  16/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtendimentos pendentes no televendas.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoExplorer - Objeto que contem os paineis com os dados do    บฑฑ
ฑฑบ          ณ            pre-atendimento.                                บฑฑ
ฑฑบ          ณnPanel    - Nupero do painel corrente.                      บฑฑ
ฑฑบ          ณaPanels   - Todos objetos de todos paineis.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280TLC08(oExplorer, nPanel, aPanels)

// Definicao de variaveis de manipulacao
Local nRow		:= Int((oExplorer:aPanel[nPanel]:nHeight * .97) / 2)	// Tamanho da linha
Local nCol		:= Int((oExplorer:aPanel[nPanel]:nWidth * .985) / 2)	// Tamanho da coluna
Local aHeadNew	:= {}													// aHeader da MsNewGetDados
Local aColsNew	:= {}													// aCols da MsNewGetDados
Local nPosObj01	:= 0													// Posicao do objeto no vetor aPanels

// Definicao de variaveis para objetos
Local oFonte
Local oSay1
Local oSay2

DEFINE FONT oFonte NAME "Arial" SIZE 0,14 BOLD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParte 01 da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ (nRow*.010), (nCol*.010) TO (nRow*.48), nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.015), (nCol*.020) SAY oSay1 PROMPT STR0001 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Pedidos em Aberto no Televendas"
oSay1:lTransparent := .F.
oSay1:nHeight := 14
oSay1:nWidth  := (Len(STR0001) * 6.2) //" Pedidos em Aberto no Televendas"

// Atualiza os itens do atendimento
Tk280SUA(@aHeadNew,	@aColsNew, "",	"")


// Cria o objeto que contara os atendimentos agendados.
Aadd( aPanels, { MsNewGetDados():New((nRow*.05),(nCol*.02),(nRow*.46), (nCol*.98),0,,,,,,4096,,,,oExplorer:GetPanel(nPanel),aHeadNew,aColsNew), "HOBJ01", .T. } )


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParte 02 da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ (nRow*.530), (nCol*.010) TO nRow, nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.530), (nCol*.020) SAY oSay2 PROMPT STR0002 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Itens do Pedido Acima"
oSay2:lTransparent := .F.
oSay2:nHeight := 14
oSay2:nWidth  := (Len(STR0002) * 6.2) //" Itens do Pedido Acima"

// Atualiza os itens do atendimento
aHeadNew := {}
aColsNew := {}
Tk280SUB(@aHeadNew,	@aColsNew, "")

// Cria o objeto que contara os atendimentos agendados.
Aadd( aPanels, { MsNewGetDados():New((nRow*.57),(nCol*.02),(nRow*.98), (nCol*.98),0,,,,,,4096,,,,oExplorer:GetPanel(nPanel),aHeadNew,aColsNew), "HOBJ02" } )

// Seleciona o primeiro browser da tela e cria o evento de troca de linha para ele
nPosObj01 := Ascan(aPanels, {|x| x[2]=="HOBJ01"} )
aPanels[nPosObj01][1]:bChange := {|| Tk280IB1Change(@aPanels) }

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTk280IB1ChangeบAutorณArmando M. Tessaroliบ Data ณ 27/06/03  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que manipula a troca dos itens do browser.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaPanels   - Todos objetos de todos paineis.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280IB1Change(aPanels)

Local nPosObj01 := Ascan(aPanels, {|x| x[2]=="HOBJ01"} )									// Posicao do objeto HOBJ01 no vetor aPanels
Local nPosObj02 := Ascan(aPanels, {|x| x[2]=="HOBJ02"} )									// Posicao do objeto HOBJ02 no vetor aPanels
Local nPNum		:= Ascan(aPanels[nPosObj01][1]:aHeader, {|x| AllTrim(x[2])=="UA_NUM"} )	// Posicao do campo UA_NUM no aHeader
Local aColsBk	:= {}																		// Copia do aCols para restauracao posterior

If !Empty(aPanels[nPosObj01][1]:aCols[n][nPNum])

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArmazena o aCols atual, pois a rotina Tk280SUD cria umaณ
	//ณnova variavel aCols (na FillGetDados).                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aColsBk	:= aClone(aCols)

	Tk280SUB(@aPanels[nPosObj02][1]:aHeader, @aPanels[nPosObj02][1]:aCols, aPanels[nPosObj01][1]:aCols[n][nPNum])

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRestaura o aCols anterior e atualiza a GetDadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCols	:= aClone(aColsBk)
	aPanels[nPosObj02][1]:Refresh()

Endif

Return(.T.)
