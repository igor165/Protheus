#INCLUDE "TMKA280E.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk280TLC05บAutor  ณArmando m. Tessaroliบ Data ณ  16/05/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPainel que demonstra os itens do ultimo atendimento (Titulosบฑฑ
ฑฑบ          ณnegociados)                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoExplorer - Objeto que contem os paineis com os dados do    บฑฑ
ฑฑบ          ณ            pre-atendimento.                                บฑฑ
ฑฑบ          ณnPanel    - Nupero do painel corrente.                      บฑฑ
ฑฑบ          ณaPanels   - Todos objetos de todos paineis.                 บฑฑ
ฑฑบ          ณcOperador - Operador que est executando a cobranca.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMKA280                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk280TLC05(oExplorer, nPanel, aPanels, aMemory, cOperador)

// Definicao de variaveis de manipulacao
Local nRow		:= Int((oExplorer:aPanel[nPanel]:nHeight * .97) / 2)	// Tamanho da linha
Local nCol		:= Int((oExplorer:aPanel[nPanel]:nWidth * .985) / 2)	// Tamanho da coluna
Local aHeadNew	:= {}													// aHeader local da MsNewGetDados
Local aColsNew	:= {}													// aCols local da MsNewGetDados
Local nPosObj01	:= 0													// Posicao do objeto no vetor aPanels

// Definicao de variaveis para objetos
Local oFonte															// Fonte utilizada
Local oSay1																// Label de descricao
Local oSay2																// Label de descricao

DEFINE FONT oFonte NAME "Arial" SIZE 0,14 BOLD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParte 01 da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ (nRow*.010), (nCol*.010) TO (nRow*.48), nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.010), (nCol*.020) SAY oSay1 PROMPT STR0001 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Atendimentos Realizados Hoje"
oSay1:lTransparent := .F.
oSay1:nHeight := 14
oSay1:nWidth  := (Len(STR0001) * 6.2) //" Atendimentos Realizados Hoje"

// Atualiza os itens do atendimento
Tk280ACF(@aHeadNew,	@aColsNew, "")


// Cria o objeto que contara os atendimentos agendados.
Aadd( aPanels, { MsNewGetDados():New((nRow*.05),(nCol*.02),(nRow*.46), (nCol*.98),0,,,,,,4096,,,,oExplorer:GetPanel(nPanel),aHeadNew,aColsNew), "EOBJ01", .F.} )


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParte 02 da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ (nRow*.530), (nCol*.010) TO nRow, nCol OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.530), (nCol*.020) SAY oSay2 PROMPT STR0002 FONT oFonte COLORS CLR_BLACK, CLR_WHITE OF oExplorer:GetPanel(nPanel) PIXEL		// " Tํtulos Negociados no Atendimento Acima"
oSay2:lTransparent := .F.
oSay2:nHeight := 14
oSay2:nWidth  := (Len(STR0002) * 6.2) //" Tํtulos Negociados no Atendimento Acima"

// Atualiza os itens do atendimento
aHeadNew := {}
aColsNew := {}
Tk280ACG(@aHeadNew,	@aColsNew,{},"")

// Cria o objeto que contara os atendimentos agendados.
Aadd( aPanels, { MsNewGetDados():New((nRow*.57),(nCol*.02),(nRow*.98), (nCol*.98),0,,,,,,4096,,,,oExplorer:GetPanel(nPanel),aHeadNew,aColsNew), "EOBJ02" } )


// Seleciona o primeiro browser da tela e cria o evento de troca de linha para ele
nPosObj01 := Ascan(aPanels, {|x| x[2]=="EOBJ01"} )
aPanels[nPosObj01][1]:bChange := {|| Tk280EB1Change(@aPanels, @aMemory) }


Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTk280EB1ChangeบAutorณArmando M. Tessaroliบ Data ณ 27/06/03  บฑฑ
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
Function Tk280EB1Change(aPanels, aMemory)

Local nPosObj01 := Ascan(aPanels, {|x| x[2]=="EOBJ01"} )										// Posicao do Objeto no vetor aPanels
Local nPosObj02 := Ascan(aPanels, {|x| x[2]=="EOBJ02"} )										// Posicao do Objeto no vetor aPanels	
Local nPCodigo	:= Ascan(aPanels[nPosObj01][1]:aHeader, {|x| AllTrim(x[2])=="ACF_CODIGO"} )	// Posicao do campo ACF_CODIGO no aHeader
Local nPCliente	:= Ascan(aPanels[nPosObj01][1]:aHeader, {|x| AllTrim(x[2])=="ACF_CLIENT"} )	// Posicao do campo ACF_CLIENT no aHeader
Local nPLoja  	:= Ascan(aPanels[nPosObj01][1]:aHeader, {|x| AllTrim(x[2])=="ACF_LOJA"} )		// Posicao do campo ACF_LOJA no aHeader
Local nPos		:= Ascan(aPanels, {|x| x[2]=="FOBJ02"} )										// Posicao do Objeto no vetor aPanels
Local aColsBk	:= {}																			// Copia do aCols para restauracao posterior

If !Empty(aPanels[nPosObj01][1]:aCols[n][nPCodigo])
	If nPCliente > 0 .AND. nPLoja > 0

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazena o aCols atual, pois a rotina Tk280SUD cria umaณ
		//ณnova variavel aCols (na FillGetDados).                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aColsBk	:= aClone(aCols)

		Tk280ACG(@aPanels[nPosObj02][1]:aHeader, @aPanels[nPosObj02][1]:aCols,{},aPanels[nPosObj01][1]:aCols[n][nPCodigo],aPanels[nPosObj01][1]:aCols[n][nPCliente],aPanels[nPosObj01][1]:aCols[n][nPLoja] )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRestaura o aCols anterior e atualiza a GetDadosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aCols	:= aClone(aColsBk)
		aPanels[nPosObj02][1]:Refresh()      
		
	Endif	
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa a enchoice dos dados cadastrais do cliente que ficou posicionada pela pesquisa anteriorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Tk280Memory("SA1", @aMemory, .F.)
aPanels[nPos][1]:Refresh()

Return(.T.)
