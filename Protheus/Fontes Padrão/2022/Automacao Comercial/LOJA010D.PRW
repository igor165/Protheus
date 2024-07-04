#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "LOJA010D.CH"

#DEFINE _PICTURE	16
#DEFINE LOG_TEF Lj010LogTef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Este Log é um recurso a ser habilitado pelo departamento de desenvolvimento para averigua-³
//³ção de possíveis problemas de transações TEF.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Static cReq := ""
Static _aRecJur	:= {}
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LchoicBar ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra a EnchoiceBar na tela                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LchoicBar(	nOpcX	, cCliente	, bNumOrc	, bOk		, ;
					bCancel	, bVlrTot	, bVlrAcrs	, bVlrDesc	, ;
					nDescPer)

Local oBar
Local lOk
Local lLj010BU1  := ExistBlock("Lj010BU1")			//verifica a existencia do PE LJ010BU1
Local lLj010BU2  := ExistBlock("Lj010BU2")			//verifica a existencia do PE LJ010BU2
Local lLj010BU3T := ExistTemplate("Lj010BU3") 	   		//verifica a existencia do Template LJ010BU3
Local lLj010BU3  := ExistBlock("Lj010BU3")			//verifica a existencia do PE LJ010BU3
Local lLj010BU4T := ExistTemplate("Lj010BU4") 			//verifica a existencia do Template LJ010BU4
Local lLj010BU4  := ExistBlock("Lj010BU4")			//verifica a existencia do PE LJ010BU4
Local lLj010FRT  := ExistBlock("Lj010FRT")			//verifica a existencia do PE LJ010FRT
Local lL10HabFr  := ExistBlock("L10HabFr")			//verifica a existencia do PE L10HabFr
Local lRetFrete   := .F.
Local aRetB3     := {}
Local aRetB4     := {}

ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlgLoja,{||oDlgLoja:End()},{||oDlgLoja:End()},,) CENTERED
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP  ACTION Calculadora() PROMPT "Calc" TOOLTIP STR0004	// "Calculadora"
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP STR0006				// "Spool"
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar GROUP  ACTION HelProg() TOOLTIP STR0007		// "Ajuda"

DEFINE BUTTON oBtnEst RESOURCE "PLNPROP" OF oBar ACTION If(lLj010BU1,ExecBlock("Lj010BU1",.F.,.F.), Lj010Prod( aCols[n,aPosicoes[ 9,2] ],aCols[n][aPosicoes[14,2]]));
PROMPT STR0089 TOOLTIP STR0008	// "Estoque" ### "Estoques...(CTRL+E)"
SetKey(5,oBtnEst:bAction)
DEFINE BUTTON oBtnAut RESOURCE "CHAVE2" OF oBar ACTION Lj010Autor() ;
PROMPT STR0090 TOOLTIP STR0009  // "Desconto" ### "Autoriz. Desconto...(CTRL+A)"
SetKey(1,oBtnAut:bAction)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Para os estados Amazonas, Minas Gerais e Sao Paulo nao e permitido alterar           |
// o preco do produto no momento da venda para quem usa ECF                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LjAnalisaLeg(5)[1] .OR. (LjAnalisaLeg(5)[1] .AND. !lFiscal)
	DEFINE BUTTON oBtnTab RESOURCE "PRECO" OF oBar ACTION If(lLj010BU2,ExecBlock("Lj010BU2",.F.,.F.), Lj010Tabela());
	PROMPT STR0091 TOOLTIP STR0010  // "Tabela" ### "Tabelas Pre‡os...(CTRL+P)"
	SetKey(16,oBtnTab:bAction)
Endif

DEFINE BUTTON oBtnReserva RESOURCE "EDIT" OF oBar ACTION Lj010Reserva() PROMPT STR0092 TOOLTIP STR0063 // "Reserva" ### "Efetua Reserva"
DEFINE BUTTON oBtnConsRes RESOURCE "PESQUISA" OF oBar ACTION LjConsRes() PROMPT STR0093 TOOLTIP STR0064 // "Consulta" ### "Consulta Reserva"
IF cPaisLoc$"EUA|POR" 
	DEFINE BUTTON RESOURCE "AUTOM" OF oBar ACTION Lj010Lay() PROMPT STR0094 TOOLTIP STR0069      // "Lay-Away" ### "Consulta Lay-Away"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Botao para consulta TEF  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaTef .AND. SuperGetMv("MV_TEFGRT") <> "S"
	DEFINE BUTTON oBtnTef RESOURCE "BUDGET" OF oBar ACTION LOJA010T( "C" );
	PROMPT STR0095 TOOLTIP STR0096 // "TEF" ### "Consulta Eletrônica...(CTRL+S)"
	SetKey(19,oBtnTef:bAction)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para uso exclusivo de Template.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLj010BU3T
	aRetB3 := ExecTemplate( "Lj010BU3", .F., .F. )
	DEFINE BUTTON RESOURCE aRetB3[ 1 ] OF oBar ACTION ( Eval( aRetB3[ 2 ] ) );
	TOOLTIP aRetB3[ 3 ]
Endif

If lLj010BU3
	aRetB3 := ExecBlock( "Lj010BU3", .F., .F. )
	DEFINE BUTTON RESOURCE aRetB3[ 1 ] OF oBar ACTION ( Eval( aRetB3[ 2 ] ) );
	TOOLTIP aRetB3[ 3 ]
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para uso exclusivo de Template.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLj010BU4T
	aRetB4 := ExecTemplate( "Lj010BU4", .F., .F. )
	DEFINE BUTTON RESOURCE aRetB4[ 1 ] OF oBar ACTION ( Eval( aRetB4[ 2 ] ) );
	TOOLTIP aRetB4[ 3 ]
Endif

If lLj010BU4
	aRetB4 := ExecBlock( "Lj010BU4", .F., .F. )
	DEFINE BUTTON RESOURCE aRetB4[ 1 ] OF oBar ACTION ( Eval( aRetB4[ 2 ] ) );
	TOOLTIP aRetB4[ 3 ]
Endif

DEFINE BUTTON oBtnHist RESOURCE "LINE" OF oBar ACTION;
LjHistLoj( cCliente );
PROMPT STR0097 TOOLTIP STR0032  // "Histórico" ### "Consultr Histórico...(CTRL+H)"
SetKey( 8, oBtnHist:bAction )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Botao para inserir dados do frete  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE BUTTON oBtnTransp RESOURCE "CARGA" OF oBar ACTION If(lLj010FRT,ExecBlock("Lj010FRT",.F.,.F.,{bNumOrc}), Lj010Frete(bNumOrc,bVlrTot,bVlrAcrs,bVlrDesc,nDescPer));
PROMPT STR0098 TOOLTIP STR0033  // "Frete" ### "Frete............(CTRL+T)"
SetKey(20,oBtnTransp:bAction)

If SuperGetMv( "MV_ACATIVO" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  Botao para inserir dados do Requerimento  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE BUTTON oBtnReq RESOURCE "VENDEDOR" OF oBar ACTION (Eval({ || Lj010Req() }));
	PROMPT STR0099 TOOLTIP STR0065 // "Requerim" ### "Requerimento............(CTRL+R)"
	SetKey(18,oBtnReq:bAction)
	Lj010Req()
Endif

oBar:nGroups += 8

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  "Confirma" ### "Confirma Or‡amento - <Ctrl-O>"  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE BUTTON oBtOk RESOURCE "OK" OF oBar GROUP ACTION ( lOk := Eval(bOk)) PROMPT STR0100 TOOLTIP STR0011
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Durante o processo de troca o sistema nao pode permitir a gravacao do orcamento,    |
//| ou seja, o usuario deve finalizar todo o processo ou apenas cancelar.               |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTroca
	oBtOk:Disable()
Else
	SetKEY(15,oBtOk:bAction)
	oDlgLoja:bSet15 := oBtOk:bAction
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| "Sair" ### "Sair e N„o Gravar - <Ctrl-X>"  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( Eval(bCancel)) PROMPT STR0101 TOOLTIP STR0012
SetKEY(24,oBtCan:bAction)
oDlgLoja:bSet24 := oBtCan:bAction

oBar:bRClicked := {|| AllwaysTrue()}

If !lLj010FRT .AND. lFiscal .AND. ( nOpcX == 2 .OR. nOpcX == 3 )
	If lL10HabFr
		lRetFrete := ExecBlock( "L10HabFr", .F. , .F. )
		If ValType( lRetFrete ) <> "L"
			lRetFrete := .F.
		Endif
	Endif                                                 	

	If !lRetFrete
		oBtnTransp:Disable()
		Set Key 20 to
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existem lojas cadastradas, caso contrario nao habilita ³
//³o botao das reservas.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SLJ->(DbGotop())
If SLJ->(EOF())
	oBtnReserva:Disable()
	oBtnConsRes:Disable()
Endif
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Din  ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de negociacao de parcelas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010din(	aItens		, nVlrLiq	, oFnt2			, nEntrada	, ;
					nFinanciado	, oEntrada	, oFinanciado	, nLiq		, ;
					lUsouFator	, nTipoJur	, lLjMontP		, aMoeda,;
					cCondicao )
Local n
Local i
Local nValAteP
Local nValTot
Local nValAnt
Local nPos
Local oDlgLojaPag
Local oFont
Local oValor
Local oComboPag
Local cComboPag  := ""
Local oCheckPag
Local cComboAnt
Local aMatriz     := {}
Local lOk                                        := .T.
Local lCheckPag := .F.
Local dDataForm := aPgtos[oPgtos:nAt,1]
Local nDecs     := MsDecimais(aPgtos[oPgtos:nAt,4])
Local nValor    := Round(aPgtos[oPgtos:nAt,2],nDecs)
Local aCbxMoeda   := {}  //Combo Box das moedas
Local oComboMoeda
Local cMoedaTit := ""
Local aTmpPgtos := {}
Local lDinheiro := .F.
Local nPosMoeda1 := 0
Local lLj010Par  := ExistBlock("Lj010Par")
Local lRetPE     := .T.
Local lParcelas  := .F.  //Var que eh atualizada quando confirmada a alteracao das parcelas
Local cFormas	 := ""
Local aVal       := {}

Default cCondicao  := PADR(SuperGetMv( "MV_CONDPAD" ),3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao for permitido alterar as parcelas da venda, sai da rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! LjProfile(9)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  Caixa n„o autorizado  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgAlert( STR0026 )
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a parcela for diferente de dinheiro ou cheque e utilizar      ³
//³ Fator de multiplicacao, sai da rotina. 							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsouFator .AND. ( Alltrim(aPgtos[oPgtos:nAt,3]) <> cSimbCheq .AND. ;
	!IsMoney(aPgtos[oPgtos:nAt,3] ))
	MsgInfo(STR0025)  //"Num financiamento com fator nao se permitira a alteracao da forma de pagamento. Para alterar, escolha outra Condicao de Pagamento."
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Para evitar que o usuario tente alterar o valor de uma parcela  |
//| de uma compra sem valor.                                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLiq == 0
	Help(" ","1","SEMVALOR")
	Return .F.
Endif

If !lCombo
	Help(" ","1","TITULOS")
	Return .F.
Endif

If Len(aPgtos) == 0
	aPgtos:={{CtoD("  /  /  "),0,Space(15),nMoedaCor}}
	oPgtos:Refresh()
	aParcTef := aClone(aPgtos)
	Return .T.
ElseIf Empty(aPgtos[1][1])
	aPgtos:={}
	aPgtos:={{CtoD("  /  /  "),0,Space(15),nMoedaCor}}
	oPgtos:Refresh()
	aParcTef := aClone(aPgtos)
	Return .T.
Endif

If IsMoney(aPgtos[oPgtos:nAt,3])
	lDinheiro := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Posicao do simbolo da moeda 1 para ser usada de forma generica para todas as moedas  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosMoeda1 := AScan(aItens,{|aVal|AllTrim(aVal[2]) == AllTrim(SuperGetMv("MV_SIMB1"))})
Endif

nPos       := AScan(aItens,{|aVal|AllTrim(aVal[2]) == AllTrim(aPgtos[oPgtos:nAt,3])})

If !Empty(aPgtos)
	
	For n := 1 To Len(aItens)
		AAdd(aMatriz,aItens[n][1])
	Next n
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Soma o Valor total at‚ a parcela inferiormente a clicada  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValAteP := 0
	For i = 1 To oPgtos:nAt-1
		nValAteP := nValAteP + Round(xMoeda(aPgtos[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)
	Next i
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Soma o Valor total das parcelas  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValTot := 0
	For i = 1 To Len(aPgtos)
		nValTot := nValTot + Round(xMoeda(aPgtos[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)
	Next i
	
	If lDinheiro
		cComboPag := aItens[nPosMoeda1,1]  //Para todas as moedas, mostra a descricao Dinheiro
	ElseIf nPos > 0
		cComboPag := aItens[nPos,1]
	Endif
	cMoedaTit := SuperGetMv("MV_MOEDA"+Ltrim(Str(aPgtos[oPgtos:nAt,4])))
	
	nValAnt  := aPgtos[oPgtos:nAt,2]
	cComboAnt := aPgtos[oPgtos:nAt,3]
	dDataAnt  := aPgtos[oPgtos:nAt,1]
	If cPaisLoc <> "BRA"
		For i :=	1 To MoedFin()
			If(!(Empty(SuperGetMv("MV_MOEDA"+Ltrim(STR(i))))))
				AAdd(aCbxMoeda,SuperGetMv("MV_MOEDA"+Ltrim(STR(i))))
			Else
				Exit
			Endif
		Next i
		aTmpPgtos := aClone(aPgtos)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  Verifica se o CheckBox "Utiliza nas próximas parcelas" vira marcado ou desmarcado  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	lCheckPag := (AllTrim(aPgtos[oPgtos:nAt,3]) $ SuperGetMv("MV_PRXPARC"))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Forma de Pagamento   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgLojaPag FROM 12, 20 TO 25, 61 TITLE STR0018 ;
	STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
	
	DEFINE FONT oFont NAME "Arial" SIZE 5,15
	@ .3,1 TO 7,18.9 OF oDlgLojaPag
	
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//| Valor :  |
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	@ 3.0,2 Say STR0014 SIZE 10,1
	@ 3.0,7.5 MSGET oValor VAR nValor RIGHT SIZE 55,08 Picture PesqPict("SL1","L1_VLRTOT",_PICTURE) Valid(If(nValor>0,(If(cPaisLoc=="BRA",(nValor <= nEntrada+nFinanciado-nValAteP),If(lValTot,Lj010ValP(nValor,nValAteP,nValTot,cMoedaTit),.T.))),(MsgStop(STR0031),.F.)))
	
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//| Forma:  |
	//ÀÄÄÄÄÄÄÄÄÄÙ
	@ 4.0,2 Say STR0015 SIZE 10,1
	If cPaisLoc == "BRA"
		//ÚÄÄÄÄÄÄÄÄÄ¿
		//|  Data:  |
		//ÀÄÄÄÄÄÄÄÄÄÙ
		@ 2.0,2 Say STR0013 SIZE 10,1
		@ 2.0,7.5 MSGET dDataForm RIGHT Picture "99/99/99" SIZE 45,08 Valid dDataForm >= dDataBase.AND.;
		Lj010PJur(@nValor,@lOk,oDlgLojaPag,cComboPag,dDataForm)

		@ 4.0,7.5 MSCOMBOBOX oComboPag VAR cComboPag ITEMS aMatriz ON CHANGE Lj010CbFor(oCheckPag,@lCheckPag,aMatriz,cComboPag,aItens) OF oDlgLojaPag SIZE 75,55
	Else
		cFormas := cComboPag
		If ExistBlock("Lj010VAL")
			cFormas := ExecBlock("Lj010VAL",.F.,.F.)
		Endif

		dDataForm := aPgtos[oPgtos:nAt,1]
		dDataEmis := aPgtos[oPgtos:nAt,5]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  Vencimento:  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 1.0,2.0 	Say STR0081 SIZE 10,1
		@ 1.0,7.5 	MSGET 	dDataForm RIGHT Picture "99/99/99" SIZE 45,08 ;
				 	VALID Lj010DtVcto(dDataEmis,dDataForm,cComboPag,oPgtos,@aPgtos) .AND.;
						  Lj010PJur(@nValor,@lOk,oDlgLojaPag,cComboPag,dDataForm);
					WHEN If( AllTrim(Upper(cComboPag)) $ AllTrim(Upper(cFormas)),.T.,.F. )

		//ÚÄÄÄÄÄÄÄÄÄÄ¿
		//| Emissao  |
		//ÀÄÄÄÄÄÄÄÄÄÄÙ
		@ 2.0,2.0 	Say STR0078 SIZE 10,1
		@ 2.0,7.5 	MSGET dDataEmis RIGHT Picture "99/99/99" SIZE 45,08;
					VALID Lj010DtEmis(dDataEmis,dDataForm,cComboPag,oPgtos,@aPgtos);
					WHEN If( AllTrim(Upper(cComboPag)) $ AllTrim(Upper(cFormas)),.T.,.F. )

		@ 4.0,7.5 MSCOMBOBOX oComboPag VAR cComboPag ITEMS aMatriz;
				   ON CHANGE Lj010CbFor(oCheckPag,@lCheckPag,aMatriz,cComboPag,aItens);
				   VALID Lj010CbFrm(cComboPag,oPgtos,aPgtos,dDataEmis,dDataForm,aTmpPgtos);
				   OF oDlgLojaPag SIZE 50,55

		@ 4.0,13.8 	MSCOMBOBOX oComboMoeda VAR cMoedaTit ITEMS aCbxMoeda OF oDlgLojaPag SIZE 35,55
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| "Conversao"  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aMoeda) > 1
		   @ 37,115 BUTTON STR0083 SIZE 30,15 ACTION (Lj010RetVConv(@cMoedaTit,@oComboMoeda,;
		            @nValor,@oValor,aCbxMoeda,@aVal,"BALCAO","0")) OF oDlgLojaPag PIXEL 
		Endif            
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| &Utiliza nas pr¢ximas parcelas   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 64,16 CHECKBOX oCheckPag VAR lCheckPag PROMPT STR0016 SIZE 100,8 FONT oFont OF oDlgLojaPag
	
	DEFINE SBUTTON FROM 076,090 TYPE 1 ACTION (If( lLj010Par,lRetPE := _LJ010Par( dDataForm, nValor, cComboPag, @cCondicao ), lRetPE ),;
	If(lRetPE .AND. Lj010DtPag(cComboPag,oPgtos:nAt,aItens,dDataForm,lCheckPag) .AND.;
	(Lj010DinV(@nValor,@lOk,oDlgLojaPag,cComboPag,dDataForm)),;
	(lParcelas := .T.),(lParcelas := .F.))) ENABLE OF oDlgLojaPag
	
	DEFINE SBUTTON FROM 076,119.1 TYPE 2 ACTION (lOk := .T.,lParcelas := .F.,oDlgLojaPag:End(),aPgtos[oPgtos:nAt,1] := dDataAnt) ENABLE OF oDlgLojaPag
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
	//| DINHEIRO  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlgLojaPag ON INIT (If(Len(aPgtos) > 1,If(Upper(cComboPag) == STR0017,oCheckPag:Disable(),),oCheckPag:Disable()))
	
	If lParcelas
		Lj010Fill(	oComboPag		, cComboPag		, aItens	, dDataForm	,;
					lCheckPag		, nValor		, @nEntrada	, oEntrada	,;
					@nFinanciado	, oFinanciado	, cMoedaTit	, aTmpPgtos	,;
					nTipoJur		, nVlrLiq)
		If cPaisLoc <> "BRA"
			aPgtos[oPgtos:nAt,5] := dDataEmis
		EndIf
		lOk := .T.
		lLjMontP := .F.
		
		If ExistBlock("Lj010PGT")
			ExecBlock("Lj010PGT",.F.,.F.)
		Endif
		
	Else
		lOk := .F.
	Endif
	
Else
	Help(" ",1,"SemDados")
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010DinV ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se a tela pode ou nÆo ser fechada                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010DinV(	nValor,		lOk,	oDlgLojaPag,	cComboPag,;
					dDataForm )
Local lLj010Val := ExistBlock("Lj010Val")			// verifica a existencia do PE LJ010Val
Local lRet		:=.T.										// retorno da funcao

If lLj010Val
	lRet := ExecBlock("Lj010Val",.F.,.F.,{nValor,cComboPag,dDataForm})
Endif

IF lRet
	lOk:=.T.
	oDlgLojaPag:End()
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010tabel³ Autor ³ Vendas Clientes       ³ Data ³ 13.08.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega tabela de preco.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Tabela()
Local oDlgLojaTabela
Local oTabelas
Local oFont
Local nPosTabela:= aPosicoes[10][2]
Local nPosProd	:= aPosicoes[9][2]
Local nRegSX3	:= SX3->(Recno())
Local nOrdSX3	:= SX3->(indexOrd())
Local cAlias	:= Alias()
Local cOrdem	:= IndexOrd()
Local cCampo	:= CriaVar("B0_PRV1")
Local nReg		:= Recno()
Local nI		:= 0
Local lOk		:= .T.
Local lSaida	:= .F.
Local lBlomb1	:= ExistBlock("BLomb1")

If ChkPsw( 32 )
	If Empty(aCols[n][nPosProd])
		Help(" ","1","LJSEMPRODU")
		SetFocus(oGet:oBrowse:hWnd)
		Return( Nil )
	Endif

	If !Empty(aCols[n][nPosProd])
		oBtnTab:SetDisable(.T.)
		SetKey(16,Nil)	
	Endif
	
	If lBlomb1
		ExecBlock("Blomb1",.F.,.F.)
	Else
		DbSelectArea("SB0")
		DbSetOrder(1)
		If DbSeek(xFilial("SB0") + aCols[n][nPosProd])
			For nI := 1 To 9
				cCampo := "B0_PRV"+Str(nI,1)
				aTabelas[nI][2] := &("SB0->" + cCampo)
			Next nI
		Else
			Help(" ","1","NOPRECO")
			SetFocus(oGet:oBrowse:hWnd)
			Return( Nil )
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna o alias ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAlias)
	DbSetOrder(cOrdem)
	DbGoto(nReg)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Tabelas de Pre‡os  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgLojaTabela TITLE STR0019;
	From 12,20 To 25.5,55 STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
	
	DEFINE SBUTTON FROM 006,108 TYPE 1 ACTION (lOk := .T.,lSaida := .T.,nTabela := oTabelas:nAt,oDlgLojaTabela:End()) ENABLE OF oDlgLojaTabela
	DEFINE SBUTTON FROM 020,108 TYPE 2 ACTION (lOk := .F.,lSaida := .T.,nTabela := oTabelas:nAt,oDlgLojaTabela:End()) ENABLE OF oDlgLojaTabela
	
	DEFINE FONT oFont NAME "Arial" SIZE 0, -11
	
	oTabelas := TCBROWSE():New(5,5,100,80, , , , , , , , , ;
	{ || (lOk := .T.,lSaida := .T.,(lOk:=.T.,lSaida := .T.,nTabela := oTabelas:nAt,oDlgLojaTabela:End()))} ,;
	,oFont, , , , , .F. , , .T. , , .F. , ,)
	oTabelas:SetArray(aTabelas)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Tabela / Pre‡o  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ADD COLUMN TO oTabelas HEADER STR0020 OEM DATA {|| aTabelas[oTabelas:nAt,1] } SIZE 30 PIXELS
	ADD COLUMN TO oTabelas HEADER STR0021 OEM DATA {|| Transform(aTabelas[oTabelas:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor))} SIZE 30 PIXELS
	oTabelas:bLine := { || {aTabelas[oTabelas:nAT,1],aTabelas[oTabelas:nAT,2] } }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Duplo Click do mouse para escolher a tabela  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTabelas:cToolTip := STR0022
	oTabelas:lNoHScroll := .F.
	oTabelas:nFreeze := 1
	
	ACTIVATE MSDIALOG oDlgLojaTabela Valid lSaida
	
	oBtnTab:SetDisable(.F.)
	SetKey(16,oBtnTab:bAction)
	
	SetFocus(oGet:oBrowse:hWnd)
	
	If !lOk
		Return( Nil )
	Endif
	
	
	If n <> Nil .AND. n > 0
		aCols[n][nPosTabela] := nTabela
	Endif
	
	DbSelectArea("SX3")  // Dispara SX7
	DbSetOrder(2)
	DbSeek("L2_PRODUTO")
	
	If ExistTrigger("L2_PRODUTO") .AND. n <> Nil
		M->L2_PRODUTO := aCols[n][nPosProd]
		RunTrigger(2,n)
		oGet:oBrowse:DrawSelect()
		lRefresh:=.F.
		If cPaisLoc <> "BRA"
		   Lj010Imps()     //Executa o recalculo dos impostos variaveis
		Endif
	Endif
	
	DbSetOrder(nOrdSX3)
	DbGoto(nRegSX3)
	DbSelectArea(cAlias)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura CTRL-O E CTRL-X ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey(15,oBtOk:bAction)
	If !lTroca
		SetKey(24,oBtCan:bAction)
	Endif
	
Endif // Fim da validacao de acesso a rotina.

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010VerIc³ Autor ³ Vendas Clientes       ³ Data ³ 09/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de Verifica‡„o da Porcentagem de ICM                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010VerIcm( nEl,	nBase,	cTes,	cProduto )
LOCAL nPerRet      	:= 0						// Percentual de retorno
Local nPosProd     	:= aPosicoes[9][2]
Local nPosTes      	:= aPosicoes[5][2]
Local cAlias       	:= Alias( )
Local nRecnoA1     	:= 0

//ÚÄÄÄÄÄÄÄ¿
//| Grade |
//ÀÄÄÄÄÄÄÄÙ
Local nGrade
Local cGrade

Default cTes 		:= SL2->L2_TES
Default cProduto 	:= SL2->L2_PRODUTO

If cAlias == "SD1" .OR. __lPyme
	nGrade := 0
Else
	nGrade := AScan(aCampos,"L2_GRADE")
EndIf
If nGrade <> 0
	cGrade := aCols[n][nGrade]
Else
	cGrade := ""
EndIf
If cPaisLoc <> "BRA"
	Return( 0 )
Endif
If nEl == Nil
	nE1 := n
EndIf
If nBase == NIl
	If cGrade == "S"
		SB4->(DbSeek(xFilial("SB4")+aCols[nEl][nPosProd]))
	Else
		SB1->(DbSeek(xFilial("SB1")+aCols[nEl][nPosProd]))
	Endif
	DbSelectArea( "SF4" )
	DbSeek( cFilial+aCols[nEl][nPosTes])
	DbSelectArea( cAlias )
Else
	If cGrade == "S"
		SB4->(DbSeek(xFilial("SB4") + cProduto ))
	Else
		SB1->(DbSeek(xFilial("SB1") + cProduto ))
	Endif
	DbSelectArea( "SF4" )
	DbSeek( cFilial + cTes )
	DbSelectArea( cAlias )
Endif

If !Empty( cCliEntrega ) .AND. !Empty( cLojEntrega )
	nRecnoA1 := SA1->( RecNo() )
	SA1->( DbSetOrder( 1 ) )
	SA1->( DbSeek( xFilial( "SA1" ) + cCliEntrega + cLojEntrega ) )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso Calcule Icms  Chama a Fun‡„o do FISXFUN.PRX para retornar ³
//³ a Aliquota correta para c lculo do Icms                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SF4->F4_ICM == "S"
	nPerRet := AliqIcms("N","S",SA1->A1_TIPO,"I")
Endif

If !Empty( cCliEntrega ) .AND. !Empty( cLojEntrega )
	SA1->( DbGoto( nRecnoA1 ) )
Endif

Return(nPerRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010IPI  ºAutor  ³ Vendas Clientes     º Data ³  11/04/97   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de verificacao e calculo de IPI.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EnxpN1: Valor do Preco de Tabela                            º±±
±±º          ³ EnxpN2: Quantidade                                          º±±
±±º          ³ EnxpN3: Desconto                                            º±±
±±º          ³ EnxpN4: Valor de Acresicmo ou Decrescimo                    º±±
±±º          ³ EnxpC5: Tipo de Entrada e Saida                             º±±
±±º          ³ EnxpN6: Linha                                               º±±
±±º          ³ EnxpC7: Produto                                             º±±
±±º          ³ EnxpC8: Tipo de Retorno a ser utilizado                     º±±
±±º          ³ EnxpN9: Valor do Frete                                      º±±
±±º          ³ EnxpN10: Valor do Seguro                                    º±±
±±º          ³ EnxpN11: Valor do Desconto                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010IPI(	nPrcTab		, nQuant	, nDesc		, nDescNF	,;
					cTes		, nLinha	, cProduto	, cRet		,;
					nValFrete	, nValSeg	, nValDes )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No microterminal nao exites aCampos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTipoCalc   := SuperGetMv( "MV_IPIBRUT" )				//Captura o parametro MV_IPIBRUT
Local cGrade
Local cTabela
Local nGrade      := If( Alias() == "SD1" .OR. ! Type( "aCampos" ) == "A" .OR. __lPyme, 0, AScan( aCampos, "L2_GRADE" ) )
Local nAliq
Local nBasIpiUni
Local nValDesc
Local nValIpi     := 0
Local nPPrcTab
Local nPQuant
Local nPDesc
Local nPTes
Local nPProduto
Local nPValIpi
Local nPValDesc
Local nPTabela
Local nPValFrete
Local nPValSeg
Local nPValDes
Local lLinha      := ( nLinha == NIL )
Local nTamL2_PRC  := TamSX3( "L2_PRCTAB" )[2]	// Tamanho do campo L2_PRCTAB
Local nTamL2_VAL  := TamSX3( "L2_VALIPI" )[2]	// Tamanho do campo L2_VALIPI

DEFAULT cRet      := "V" // parametro utilizado para retornar "V"ALOR ou "B"ASE do IPI
DEFAULT nValFrete := 0
DEFAULT nValSeg   := 0
DEFAULT nValDes   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fora do Brasil nao possui IPI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aPosicoes nao existe no Microterminal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TYPE( "aPosicoes" ) == "A"
		nPPrcTab   	:= aPosicoes[13][2]
		nPQuant    	:= aPosicoes[11][2]
		nPDesc		:= aPosicoes[4][2]
		nPTes    	:= aPosicoes[5][2]
		nPProduto   := aPosicoes[9][2]
		nPValIpi	:= aPosicoes[7][2]
		nPValDesc 	:= aPosicoes[3][2]
		nPTabela    := aPosicoes[10][2]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o campo do IPI nao eh usado entao nao calcula³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPValIpi == 0
			Return ( 0 )
		Endif
	Endif
	
	If VALTYPE( nLinha ) == "U" .OR. VALTYPE( nLinha ) <> "N"
		nLinha := n
	Endif
	
	If TYPE( "aCampos" ) == "A" .AND. ( nPValFrete := AScan( aCampos, "L2_VALFRE" ) ) > 0
		nValFrete := If( ValType( aCols[nLinha][nPValFrete] ) <> "N", nValFrete, aCols[nLinha][nPValFrete] )
	Endif
	
	If TYPE( "aCampos" ) == "A" .AND. ( nPValSeg := AScan( aCampos, "L2_SEGURO" ) ) > 0
		nValSeg := If( ValType( aCols[nLinha][nPValSeg] ) <> "N", nValFrete, aCols[nLinha][nPValSeg] )
	Endif
	
	If TYPE( "aCampos" ) == "A" .AND. ( nPValDes := AScan( aCampos, "L2_DESPESA" ) ) > 0
		nValDes := If( ValType( aCols[nLinha][nPValDes] ) <> "N", nValFrete, aCols[nLinha][nPValDes] )
	Endif
	
	If VALTYPE( nQuant ) == "U" .OR. VALTYPE( nQuant ) <> "N"
		nQuant := aCols[nLinha][nPQuant]
	Endif
	
	If VALTYPE( nDesc ) == "U" .OR. VALTYPE( nDesc ) <> "N"
		nDesc := aCols[nLinha][nPDesc]
	Endif
	
	If VALTYPE( nDescNF ) == "U" .OR. VALTYPE( nDescNF ) <> "N"
		nDescNF := 0
	Endif
	
	If VALTYPE( cTes ) == "U" .OR. VALTYPE( cTES ) <> "C" .OR. VAL( cTES ) == 0
		cTes := aCols[nLinha][nPTES]
	Endif
	
	If VALTYPE( cProduto ) == "U" .OR. VALTYPE( cProduto ) <> "C"
		cProduto := aCols[nLinha][nPProduto]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No Microterminal nao possui aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Type( "aCols" ) == "A" .OR. VALTYPE( aCols[nLinha][nPTabela] ) == "U" .OR. EMPTY( aCols[nLinha][nPTabela] )
		cTabela := "1"
	Else
		cTabela := aCols[nLinha][nPTabela]
	Endif
	
	If VALTYPE( nPrcTab ) == "U" .OR. VALTYPE( nPrcTab ) <> "N"
		If lLinha
			If ( "L2_VRUNIT" $ ReadVar() )
				nPrcTab := Eval( MemVarBlock( ReadVar() ) )
			Else
				If aCols[nLinha][nPPrcTab] == 0
					SB0->( DbSetOrder( 1 ) )
					SB0->( DbSeek( xFilial( "SB0" ) + cProduto ) )
					nPrcTab := Eval( FieldBlock( "SB0->B0_PRV" + cTabela ) )
				Else
					nPrcTab := aCols[nLinha][nPPrcTab]
				Endif
			Endif
		Else
			nPrcTab := aCols[nLinha][nPPrcTab]
		Endif
	Endif
	
	If ! nGrade == 0
		cGrade := aCols[nLinha][nGrade]
	Else
		cGrade := "N"
	Endif

	If Empty(cTipoCalc)
		cTipoCalc := "S"
	EndIf

	SF4->( DbSetOrder( 1 ) )

	If SF4->( DbSeek( xFilial( "SF4" ) + cTes ) ) .AND. SF4->F4_IPI == "S"
		If !Empty(SF4->F4_TPIPI)
			cTipoCalc := SF4->F4_TPIPI
		EndIf
		
		If cGrade == "S"
			SB4->( DbSetOrder( 1 ) )
			SB4->( DbSeek( xFilial( "SB4" ) + cProduto ) )

			nAliq := SB4->B4_IPI
		Else
			SB1->( DbSetOrder( 1 ) )
			SB1->( DbSeek( xFilial( "SB1" ) + cProduto ) )

			nAliq	:= SB1->B1_IPI
			nValIPI	:= SB1->B1_VLR_IPI * nQuant
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se é IPI de Pauta³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nAliq <> 0 .OR. nValIPI > 0
			nBasIpiUni := Round( ( nPrcTab * nQuant ) * If( SF4->F4_BASEIPI > 0, SF4->F4_BASEIPI / 100, 1 ), nTamL2_PRC )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O Frete, o seguro e o desconto deve ser somado ao valor da base do IPI, e não ao preço de venda e ³
			//³depois multiplicado a qtde.                                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_IPIFRET == "S"
				nBasIPIUni += ( nValFrete + nValSeg + nValDes )
			Endif
			
			If !( cTipoCalc $ "SB" )
				If nDesc > 0 .AND. nDesc < 100
					nBasIpiUni *= ( 1 - ( nDesc / 100 ) )
				Endif
				If nDescNF > 0 .AND. nDescNF < 100
					nBasIpiUni *= ( 1 - ( nDescNF / 100 ) )
				Endif
				nBasIpiUni := NoRound( nBasIpiUni, nDecimais )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³No Microterminal nao possui aCols³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TYPE( "aCols" ) == "A"
				nValDesc := aCols[nLinha][nPValDesc]
			Else
				nValDesc := 0
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao for IPI de Pauta, faz o calculo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nValIPI == 0	
				nValIPI := NoRound( ( nBasIpiUni * nAliq ) / 100, nTamL2_VAL )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o valor do IPI do produto no aCols se o mesmo estiver diferente do valor atual calculado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If 	TYPE( "aCols" ) == "A" .AND. TYPE( "aPosicoes" ) == "A" .AND.;
				VALTYPE( aCols[nLinha][nPValIPI] ) <> "U" .AND. aCols[nLinha][nPValIPI] <> nValIPI
				
				aCols[nLinha][nPValIPI] := nValIPI

				oGet:oBrowse:Refresh()
			Endif
		Else
			Return ( 0 )
		Endif
	Else
		Return ( 0 )
	Endif
Else
	Return ( 0 )
Endif

Return If( cRet == "V", nValIPI, nBasIpiUni )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010MontPºAutor  ³ Vendas Clientes     º Data ³  06/03/97   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta array com parcelas                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA010                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010MontP(	aCondicoes	, cCombo     , oEntrada   , oNumParcelas   ,;
						oFinanciado	, nValorBase , cForma     , nEntrada       ,;
						nFinanciado	, nCondicao  , cCondicao  , nNumParcelas   ,;
						oTxJuros	, cComboAnt2 , nTxDescon  , oTxDescon      ,;
						nIntervalo	, nDescLoj   , lMudouCBox , nLiq           ,;
						nDescPer	, oVlrImpos  , nTipoJur   , cTipoJuros     ,;
						oTipoJuros	, oCombo     , oIntervalo , oVlrTotVen )

Local i				:= 0																			// Contador de For
Local j				:= 0																			// Contador de For
Local nX			:= 0																			// Contador de For
Local nParcelas 	:= 0																			// Numero de Parcelas
Local nResto      	:= 0																			// Resto da venda
Local cForma1     	:= 0																			// 1 forma
Local cForma2     	:= 0																			// 2 forma
Local aParc       	:= {}																			// Array com as parcelas
Local aParcelas   	:= {}																			// Parcelas
Local nLimSuper   	:= 0																			// Limite Superior
Local nLimInfer   	:= 0																			// Limite Inferior

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao executar a rotina na gravacao dos dados pois o usuario pode ter modificado as parcelas (Localizacoes)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet        	:= If( cPaisLoc == "BRA", .T., ( If( oFolder:nOption == 3, .F., .T. ) ) )	// Retorno	
Local lSemForma   	:= .T.																			// Condicao sem forma
Local nTot        	:= 0																			// Total
Local nPosDesc    	:= AScan( aHeader, { |x| Trim( x[2] ) == "L2_VALDESC" } )						// Posicao L2_VALDESC
Local nTotVenc	  	:= 0																			// Total no vencimento
Local nTotParc 		:= 0																			// Total parcela
Local nTotPgtos 	:= 0																			// Total pagamento
Local nDif     	 	:= 0																			// Total diferenca
Local nTamL4_VAL    := TamSX3( "L4_VALOR" )[2] 														// Tamanho do campo L4_VALOR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Se foi modificada a forma de pagamento pelo combo box  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMudouCBox == NIL
	lMudouCBox := .F.
EndIf
If cPaisLoc <> "BRA"
	nValorBase := nLiq
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a Condicao de Pagto escolhida ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SE4" )
DbSetOrder(1)
If !DbSeek( xFilial("SE4" ) + Substr(cCombo,1,3) ) .AND. !lLayAway 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se a Condicao e  Negociada, pois a mesma nao³
	//³e  cadastrada no SE4                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If SubStr(Upper(cCombo),1,2) == "CN"
		Lj010calsim(aCondicoes	,	@nValorBase		,	@nEntrada		,	@nFinanciado	,;
					@cForma		,	@nNumParcelas	,	@nIntervalo		,	oEntrada		,;
					oTxJuros	,	oNumParcelas	,	oFinanciado		,	/*lCalcEntrada*/,;
					@nEntrada	,	/*lTxJuros*/	,	/*nEntrOrig*/	,	aParcelas		,;
					@cCombo		,	oCombo			,	@nNumParcelas	,	@nVlrAcrs		,;
					oVlrAcrs	,	nVlrDesc		,	oVlrDesc		,	nTipoJur		,;
					nDescLoj	,	@nLiq			,	nDescPer		,	oVlrImpos)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Valores na Tela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oEntrada:Refresh()
		oFinanciado:Refresh()
		oTxJuros:Refresh()
		oNumParcelas:Refresh()
		oTipoJuros:Refresh()
		oIntervalo:Refresh()
		oVlrDesc:Refresh()
		oVlrAcrs:Refresh()
		oCombo:Refresh()			
	Endif
	
	Return .T.
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os limites Inferiores e Superiores para             |                                                           ³
//³ esta Condicao, e verifica se o valorbase esta entre os dois ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLimSuper:= SE4->E4_SUPER
nLimInfer:= SE4->E4_INFER
If nValorBase > nLimSuper .AND. nLimSuper <> 0
	Help(" ","1","LJLIMSUPER")
	lRet := .F.
ElseIf nValorBase < nLimInfer .AND. nLimInfer <> 0
	Help(" ","1","LJLIMINFER")
	lRet := .F.
Endif

If lRet
	nEntrada    := 0
	nFinanciado := 0
	If empty(cCombo)
		cCombo := aCondicoes[1]
	Endif

	If ( nCondicao := AScan( aCondicoes, cCombo) ) > 0
		cCondicao := SUBSTR( aCondicoes[nCondicao], 1, 3 )
	Endif
	nTxJuros                 := 0
	
	If cPaisLoc == "BRA"
		If nValorBase > 0
			aParc := Condicao( nValorBase, cCondicao,,, nRetICMS )
		Else
			Aadd(aParc,{dDataBase,nValorBase})
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando utilizar Roteiro de C lculo acrescentar o Array de impostos  ³
		//³ para a chamada fun‡„o Condicao                                                                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCondicao == "LAY" .AND. cPaisLoc $"EUA|POR"
			If cCalcImpV == "S"
				If nValorBase > 0
					aParc := Condicao( nValorBase , cCondicao,0.00,,0.00,aImpVarDup,{"LAY","0","1","D","",""})
				Else
					Aadd(aParc,{dDataBase,nValorBase})					
				EndIf
			Else
				If nValorBase > 0
					aParc := Condicao( nValorBase , cCondicao,,,,,{"LAY","0","1","D","",""} )
				Else
					Aadd(aParc,{dDataBase,nValorBase})									
				EndIf
			Endif
		Else			
			If cCalcImpV == "S"
				If nValorBase > 0
					aParc := Condicao( nValorBase , cCondicao,0.00,,0.00,aImpVarDup )
				Else	
					Aadd(aParc,{dDataBase,nValorBase})													
				EndIf				
			Else
				If nValorBase > 0				
					aParc := Condicao( nValorBase , cCondicao )
				Else
					Aadd(aParc,{dDataBase,nValorBase})																	
				EndIf
			Endif
		Endif
		For i:=1 to Len(aParc)-1
			aParc[i][2] := Round(aParc[i][2],MsDecimais(nMoedaCor))
			nTotVenc    += aParc[i][2]
		Next i
		aParc[Len(aParc)][2] := Round(nValorBase - nTotVenc,MsDecimais(nMoedaCor))
	Endif
	
	nParcelas                := Len(aParc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o numero de parcelas                          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nParcelas == 0
		Help(" ",1,"CONDICAO")
		Return .F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe acrescimo ou desconto na condicao. Trata o nValorBase ³
	//³ para so aplicar desconto ou acrescimo quando tiver algo a pagar (valor   ³
	//³ da venda maior que a NCC utilizada)                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case ValType( _aRecJur ) == "A" .AND. Len( _aRecJur ) > 0 .AND. ( _aRecJur[1] > 0 .OR. _aRecJur[2] > 0 )
			nTxJuros 	:= _aRecJur[1]
			nTxDescon 	:= _aRecJur[2]

		Case nValorBase > 0
			nTxJuros 	:= SE4->E4_ACRSFIN
			nTxDescon 	:= SE4->E4_DESCFIN

		Otherwise
			nTxJuros 	:= 0
			nTxDescon 	:= 0
	EndCase
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Forma de pagamento padrao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc $ "EUA|POR" .AND. cCondicao == "LAY"
		cForma1 := "NF "
		cForma2 := "NF "
	Else
		cForma1 := cForma

		If Empty( SE4->E4_FORMA )
			If nMoedaCor > 1 .AND. IsMoney( cForma1 )
			   cForma1  := SuperGetMv( "MV_SIMB" + Str( nMoedaCor, 1 ) )
			Endif
			
			If IsMoney( cForma )
				cForma2 := cSimbCheq
			Else
				cForma2 := cForma
			Endif
		Else
			cForma1 := Alltrim( SE4->E4_FORMA )
			cForma2 := Alltrim( SE4->E4_FORMA )

			SAE->( DbGotop() )

			While !( SAE->( EOF() ) )
				If AllTrim( SAE->AE_TIPO ) == Subs( AllTrim( SE4->E4_FORMA ), 1, 2 )
					cForma1 := Subs( SE4->E4_FORMA, 1, 2 )
					cForma2 := Subs( SE4->E4_FORMA, 1, 2 )

					Exit
				Endif

				SAE->( DbSkip() )
			End
		Endif
	Endif
	
	cForma := cForma1
	
	If ( nTxJuros > 0  .OR. nTxDescon > 0 ) .AND. !lTroca // Calcula Parcelamento com Juros
		aParc := MontParcelas(aParc,If(nEntrada>0,.T.,.F.),nValorBase,nEntrada,@nFinanciado,nTxDescon,nParcelas,nIntervalo,,nDescLoj,@nLiq,nDescPer)
	Else
		If cPaisLoc <> "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Zera o array aDadosJur  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AEval(aDadosJur,{|x,y| aDadosJur[y]:=0 })			
		Endif
	Endif
	
	For j := 1 To nParcelas
		AAdd(aParcelas,{aParc[j][1],aParc[j][2],If(j==1,cForma1,cForma2),nMoedaCor})
	Next j
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Condicao de pagamento sem forma de pagamento informada ?  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lSemForma := Empty( SE4->E4_FORMA )
	
	If lSemForma .AND. nParcelas > 1 .AND. lMudouCBox
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| N„o foi definida a forma de pagamento para a condi‡„o de pagamento selecionada.     |
		//| Ser  assumido Cheque como forma de pagamento para as pr¢ximas parcelas.             |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Help( " ", 1, "LJSEMFORMA" )
	Endif
	
	For j:=1 To nParcelas
		If aParcelas[j][1] > dDataBase
			nFinanciado += NoRound(aParcelas[j][2])
			
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ Se o tipo estiver dinheiro,coloca para cheque pois     ³
			*³ o pagamento ‚ a prazo                                  |                                                       ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If IsMoney(aParcelas[j][3])
				aParcelas[j][3]:= If(Empty(SE4->E4_FORMA),cSimbCheq,Alltrim(SE4->E4_FORMA))
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Se a forma de pagamento da condicao nao estiver especificada, assume cheque pois o  |
				//| pagamento eh a prazo.                                                               |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lSemForma .OR. IsMoney(SE4->E4_FORMA)
					aParcelas[j][3]:= cSimbCheq
				Else	//Tratamento para outras formas de pagto.
					aParcelas[j][3]:= SE4->E4_FORMA
				Endif
			Endif
			
		Else
			If aParcelas[j][3] == "FI" .AND. !lEntFin
				aParcelas[j][3]:= AllTrim(SuperGetMv("MV_SIMB1"))
			Endif
			
			nEntrada += NoRound(aParcelas[j][2])
		Endif
	Next j
	
	nResto := nValorBase - ( nFinanciado + nEntrada )
	If nTxDescon = 0 .AND. !nTxJuros > 0 .AND. nResto <> 0
		*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		*³ Ajuste da ultima parcela. Soma ajuste na ultima parcela ³
		*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParcelas[j-1][2] += nResto
	Endif
	nFinanciado := 0
	nEntrada    := 0
	*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	*³ Reajuste do financiamento  ³
	*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For j:=1 To nParcelas
		If aParcelas[j][1] > dDataBase
			nFinanciado += aParcelas[j][2]
		Else
			nEntrada += aParcelas[j][2]
		Endif
	Next j

	If Len(aPgtos) == Len(aParcelas) .AND. cCombo == cComboAnt2
    	For j:=1 to Len(aParcelas)
    		nTotParc	+= aParcelas[j][2]
    		nTotPgtos   += aPgtos[j][2]
    	Next j                      
    	If nTotParc <> nTotPgtos
			aPgtos := Aclone(aParcelas)	
	    Endif   		
	Else
		aPgtos := Aclone(aParcelas)	
    Endif
	
	If cPaisLoc == "BRA"
		If nValorBase < (nFinanciado + nEntrada)
			nVlrAcrs := (nFinanciado + nEntrada) - nValorBase
		Else
			nVlrAcrs := 0
		EndIf
		If nValorBase > (nFinanciado + nEntrada)
			nVlrDesc := nValorBase - (nFinanciado + nEntrada) + nDescLoj
		Else
			nVlrDesc := nDescLoj
		EndIf
		nVlrTxDesc 	:= ( nVlrDesc - nDescLoj ) * If( nVlrDesc > nDescLoj, 1, -1 )
	Else
		For nX := 1 To Len(aParcelas)
		   If Len(aPgtos[nX]) == 4
			  AAdd(aPgtos[nX],dDatabase)
		   Endif	  
		Next nX
		If nTxJuros  > 0
			nVlrAcrs := aDadosJur[1]
		Else
			nVlrAcrs := 0
		EndIf
		If nTxDescon > 0
			nVlrTxDesc := aDadosJur[9]
		Else
			nVlrTxDesc := 0
		EndIf
		If !lTroca
			AEval(aCols,{|x,y| nTot+=If(!aCols[y][Len(aHeader)+1],aCols[y][nPosDesc],0)}) 
			nVlrDesc := (nTot+nDescLoj)
		Endif
	Endif
	
	If SE4->E4_TIPO == '3'
		If SubStr(cCombo,Len(cCombo)-1) == ",0" .AND. SuperGetMv("MV_CNDTP3",.F.,.F.) .AND. Day(dDataBase) == 31
			For nX := 1 to Len(aPgtos)
				If Month(aPgtos[nX][1]) == 2 .AND. !AnoBissexto( Year(aPgtos[nX][1]))
					aPgtos[nX][1] := Ctod('01/03/'+ Str(Year(aPgtos[nX][1])))
				Endif
			Next nX		
		Endif
	Endif
	
	*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	*³ O n£mero de parcelas ‚ igual a Len do array de parcelas ³
	*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotPgtos := 0

	aEval( aPgtos, { |x| 	x[2] := Round( x[2], nTamL4_VAL ),;
	                    	nTotPgtos += x[2] } )

	nDif := ( nTotPgtos - ( nValorBase + nVlrAcrs - nVlrTxDesc ) )

	If nDif <> 0 .AND. Len( aPgtos ) > 0
		aPgtos[Len( aPgtos )][2] -= nDif
	Endif	
	
	nNumParcelas:= Len(aPgtos)
	oNumParcelas:refresh()
	
	oPgtos:SetArray( aPgtos )
	oPgtos:bLine := {||{aPgtos[oPgtos:nAt,1],;
	Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,aPgtos[oPgtos:nAt,4])),;
	aPgtos[oPgtos:nAt,3],aPgtos[oPgtos:nAt,4]}}
	oPgtos:Refresh()
	aParcTef := aClone(aPgtos)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para tratamento da aPgtos (parcelas da³
//³condicao de pagto)                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock("LJMONTP")
	ExecBlock("LJMONTP",.F.,.F.,{nValorBase,nFinanciado,nEntrada})
Endif

oPgtos:Refresh()
oTxJuros:Refresh()
oEntrada:Refresh()
oNumParcelas:Refresh()
oFinanciado:Refresh()
oTxDescon:Refresh()
oVlrAcrs:Refresh()
oVlrDesc:Refresh()

If cPaisLoc <> "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Atualiza o valor dos impostos variaveis na tela...   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oVlrImpos:Refresh() 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Atualiza o valor dos impostos variaveis na tela...    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oVlrTotVen:Refresh()
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Pos  ³ Autor ³ Vendas Clientes       ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica posicao das colunas.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Pos()

AAdd(aPosicoes,{"L2_VRUNIT"  ,AScan(aCampos,"L2_VRUNIT")})   //  1 -> Valor unitario
AAdd(aPosicoes,{"L2_VLRITEM" ,AScan(aCampos,"L2_VLRITEM")})  //  2 -> Valor do item
AAdd(aPosicoes,{"L2_VALDESC" ,AScan(aCampos,"L2_VALDESC")})  //  3 -> Valor do desconto
AAdd(aPosicoes,{"L2_DESC"    ,AScan(aCampos,"L2_DESC   ")})  //  4 -> Desconto do item
AAdd(aPosicoes,{"L2_TES"     ,AScan(aCampos,"L2_TES")})      //  5 -> Tipo de Entrada / Saida
AAdd(aPosicoes,{"L2_VALICM"  ,AScan(aCampos,"L2_VALICM")})   //  6 -> Valor de ICMS
AAdd(aPosicoes,{"L2_VALIPI"  ,AScan(aCampos,"L2_VALIPI")})   //  7 -> Valor de IPI
AAdd(aPosicoes,{"L2_VALISS"  ,AScan(aCampos,"L2_VALISS")})   //  8 -> Valor de ISS
AAdd(aPosicoes,{"L2_PRODUTO" ,AScan(aCampos,"L2_PRODUTO")})  //  9 -> Codigo do Produto
AAdd(aPosicoes,{"L2_TABELA"  ,AScan(aCampos,"L2_TABELA")})   // 10 -> Tabela de Preco
AAdd(aPosicoes,{"L2_QUANT"   ,AScan(aCampos,"L2_QUANT")})    // 11 -> Quantidade Vendida
AAdd(aPosicoes,{"L2_BASEICM" ,AScan(aCampos,"L2_BASEICM")})  // 12 -> Base do ICMS
AAdd(aPosicoes,{"L2_PRCTAB"  ,AScan(aCampos,"L2_PRCTAB")})   // 13 -> Preco de Tabela do Produto
AAdd(aPosicoes,{"L2_LOCAL"   ,AScan(aCampos,"L2_LOCAL" )})   // 14 -> Armazem do Produto
AAdd(aPosicoes,{"L2_ITEM"    ,AScan(aCampos,"L2_ITEM"  )})   // 15 -> Numero do item
AAdd(aPosicoes,{"L2_DESCPRO" ,AScan(aCampos,"L2_DESCPRO")})  // 16 -> Desconto proporcional na NF
AAdd(aPosicoes,{"L2_DESCRI"  ,AScan(aCampos,"L2_DESCRI")})   // 17 -> Descricao do Produto
nPco := aPosicoes[13][2]
Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Preco³ Autor ³ Vendas Clientes       ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega preco de venda de acordo com tabela.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Preco(cOrigem)
Local cAlias      := Alias()
Local nPosValDesc := aPosicoes[3][2]			// Armazena o valor do desconto
Local nPosDesc    := aPosicoes[4][2]			// Armazena o desconto do item
Local nPosProd    := aPosicoes[9][2]			// Armazena o codigo do produto
Local nPosTabela  := aPosicoes[10][2]			// Armazana a tabela de preco
Local nPosQuant   := aPosicoes[11][2]			// Armazena a qtde vendida
Local nPosPreco   := aPosicoes[1][2]			// Armazena valor unitario
Local nPosTotal   := aPosicoes[2][2]			// Armazena valor do item
Local nPosTES     := aPosicoes[5][2]			// Armazema o tipo de entrada e saida
Local nPosPrTab   := aPosicoes[13][2]			// Armazena o preco da tabela de produtp
Local lTrcMoeda   := SuperGetMv("MV_TRCMOED")	// Armazena o conteudo do parametro MV_TRCMOED 
Local lCalcImp    := .T.
Local nMoedaPrv   := 0
Local nPreco
local aTesImpInf  := {}
local nAliqImp    := 0
Local cProc       := " "
Local nX          := 0

*** Grade

If !lGradProd
	DbSelectArea( "SB1" )
	DbSetOrder( 1 )
	DbSeek( cFilial + m->l2_produto )
	
	DbSelectArea( "SB0" )
	DbSetOrder( 1 )
	
	If !(DbSeek( cFilial + m->l2_produto ) )
		Help( " ", 1, "NOPRECO" )
		DbSelectArea( cAlias )
		Return 0
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a rotina esta sendo chamada da Lj010FRETE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nX    := 0
	cProc := Upper(AllTrim(ProcName(nX)))
	While ! ( cProc == "" ) .AND. !("Lj010FRETE" $ cProc)
		nX++
		cProc := Upper(AllTrim(ProcName(nX)))
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a chamada veio da rotina de frete então pega a tabela ³
	//³ de precos da aCols                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "Lj010FRETE" $ cProc
		cTabela := If(ValType(aCols[n][nPosTabela])=="N",Str(aCols[n][nPosTabela]),aCols[n][nPosTabela])
	Else
		cTabela := Str(nTabela,1)
	Endif
	
	If Empty(&("SB0->B0_DATA" + cTabela)) .OR. dDatabase <= &("SB0->B0_DATA" + cTabela)
		aCols[n][nPosTabela] := cTabela
		If lTrcMoeda
			If SB0->&("B0_MOEDA" + cTabela)==0
				nMoedaPrv := 1
			Else
				nMoedaPrv := SB0->&("B0_MOEDA" + cTabela)
			EndIf
			If lTroca                                                                         
			   nPreco := Round(xMoeda(&("SB0->B0_PRV" + cTabela),nMoedaPrv,nMoedaTr,dDataBase,nDecimais+1,,If(cPaisLoc<>"BRA",nTxMoedaTr,0)),nDecimais)			
			Else			
			   nPreco := Round(xMoeda(&("SB0->B0_PRV" + cTabela),nMoedaPrv,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
			Endif   
		Else
			nPreco := &("SB0->B0_PRV" + cTabela)
		Endif
        If cPaisLoc == "SAL"
           lCalcImp    := SA1->A1_TIPO $ "1|2"
           aTesImpInf  := TesImpInf(aCols[n][nPosTES])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //| TES isento de imposto ou IVA 0%  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           If (Len(aTesImpInf) == 0 .OR. !lCalcImp .OR. Lj010ImpZero(aTesImpInf)) .AND.;
              aCols[n][nPosPrTab] > 0 
              
              SFB->(DbSetOrder(1))
              If SFB->(DbSeek(xFilial("SFB")+"IVA"))
                 nAliqImp  := SFB->FB_ALIQ
              Endif
              aCols[n][nPosPreco]  := Round((nPreco/(1+(nAliqImp/100))),nDecimais)
              aCols[n][nPosTotal]  := aCols[n][nPosPreco] * aCols[n][nPosQuant]
           Endif   
        Endif				
	Else
		nPreco := 0
	Endif
Else
	IF cOrigem == Nil
		DbSelectArea( "SB4" )
		DbSetOrder( 1 )
		If !(DbSeek( cFilial + m->l2_produto ) )
			Help( " ", 1, "NOPRECO" )
			DbSelectArea( cAlias )
			Return 0
		Endif
	Else
		DbSelectArea( "SB4" )
		DbSetOrder( 1 )
		If !(DbSeek( cFilial + aCols[n][nPosProd] ) )
			Help( " ", 1, "NOPRECO" )
			DbSelectArea( cAlias )
			Return 0
		End
	Endif
	
	cTabela := Str(nTabela,1)
	aCols[n][nPosTabela] := cTabela
	If lTrcMoeda
		nMoedaPrv := If(SB4->&("B4_MOEDA" + cTabela)==0,1,SB4->&("B4_MOEDA" + cTabela))
		If lTroca                                                                         
		   nPreco := Round(xMoeda(&("SB4->B4_PRV" + cTabela),nMoedaPrv,nMoedaTr,dDataBase,nDecimais+1,,If(cPaisLoc<>"BRA",nTxMoedaTr,0)),nDecimais)
		Else					
		   nPreco := Round(xMoeda(&("SB4->B4_PRV" + cTabela),nMoedaPrv,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
		Endif   
	Else
		nPreco := &("SB4->B4_PRV" + cTabela)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Se a balanca trabalha por preco  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPrecoBal
	M->L2_QUANT := NoRound(Val(cInfProBal) / 100 / nPreco, 3)
	aCols[n][nPosQuant]:= M->L2_QUANT
Endif

If lUsaDisplay
	MsgDisplay(5, {SB1->B1_COD, SB1->B1_CODBAR, SB1->B1_DESC, 1, nPreco, 0, ""})
Endif

DbSelectArea( cAlias )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Só podemos zerar o desconto se a Venda Balcão não trabalhar com concomitância³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lVendConc") == "L" .AND. !lVendConc
	IF aCols[n][nPosDesc] > 0 .OR. aCols[n][nPosValDesc] > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| O desconto desse produto foi zerado.   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsgStop(STR0060)
		aCols[n][nPosDesc] := 0
		aCols[n][nPosValDesc] := 0
	Endif
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a chamada veio da rotina de frete então pega a tabela ³
//³ de precos da aCols                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPreco == 0 .AND. aCols[n,nPosPreco] <> 0 .AND. "Lj010FRETE" $ cProc 
	nPreco 	:= aCols[n,nPosPreco]
Endif   
                
Return nPreco

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010DisTb³ Autor ³ Vendas Clientes       ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega tabela em Acols.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010DisTb( )
Local nX 			:= 0
Local cRet 			:= ""
Local cProc			:= ""
Local nPosTabela 	:= AScan( aHeader, { |x| Alltrim(Upper(x[2])) == "L2_TABELA" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a rotina estiver sendo chamada da tela do frete pega a tabela ³
//³ que esta no aCols.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nX    := 0
cProc := Upper(AllTrim(ProcName(nX)))
While ! ( cProc == "" ) .AND. !( "Lj010FRETE" $ cProc )
	nX++
	cProc := Upper(AllTrim(ProcName(nX)))
End
If "Lj010FRETE" $ cProc
	cRet := If(ValType(aCols[n][nPosTabela])=="N",Str(aCols[n][nPosTabela]),aCols[n][nPosTabela])
	If Empty( cRet )
		cRet := Str(nTabela,1,0)
	Endif
Else
	cRet := Str(nTabela,1,0)
Endif

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„     ³Lj010Desc ³ Autor ³ Vendas Clientes       ³ Data ³ 18.07.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica valor do desconto.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Desc()
Local lRet   	:= .T.
Local nPosTotal := aPosicoes[2][2]
Local nVlrItem 	:= aCols[n][nPosTotal]
Local aAreaX3   := SX3->( GetArea() )
Local aArea     := GetArea()
Local nPosValDesc:= AScan( aHeader,  { |x| Upper(Alltrim(x[2])) == "L2_VALDESC" } )

If "L2_VALDESC" $ Upper(ReadVar())
	nValor := &(ReadVar())
Else
	nValor := aCols[n][nPosValDesc]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Utilizado na Venda Balcão Concomitante³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lVendConc") == "L" .AND. lVendConc
	If nVlrItem > 0 .AND. nValor >= nVlrItem		//Se já existir valor no item dou a mens. caso contrário não
		Help(" ", 1, "DESCMAIOR")
		lRet := .F.	
	Endif
Else
	If nValor >= nVlrItem
		Help(" ", 1, "DESCMAIOR")
		lRet := .F.
	End
Endif

If Len(aAreaX3) > 0
	RestArea(aAreaX3)
Endif	
If Len(aArea) > 0
	RestArea(aArea)
Endif	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010calsi³ Autor ³ Vendas Clientes       ³ Data ³ 10/08/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Array com Parcelas de acordo com o digitado           ³±±
±±³          ³Utilizado apenas quando for Condicao de pagamento           ³±±
±±³          ³Negociada na hora da venda.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010calsim(	aCondicoes	, nValorBase	, nEntrada		, nFinanciado	, ;
						cForma		, nParcelas		, nIntervalo	, oEntrada		, ;
						oTxJuros	, oNumParcelas	, oFinanciado	, lCalcEntrada	, ;
						nEntrAnt	, lTxJuros		, nEntrOrig		, aParcelas		, ;
						cCombo		, oCombo		, nNumParcelas	, nVlrAcrs		, ;
						oVlrAcrs	, nVlrDesc		, oVlrDesc		, nTipoJur		, ;
						nDescLoj	, nLiq			, nDescPer		, oVlrImpos	)

Local nValor
Local aParc 		:= {}
Local aTmp  		:= {}
Local aE4 			:= {}
Local aParcDiaFixo	:= {}
Local nDe
Local nAte
Local dData
Local j
Local lAcrBru := SuperGetMv("MV_LJACBRU",.F.) // Define se o Acrescimo eh pelo valor Bruto (T) ou pelo Liquido (F)
Local lCalcFin := If(SuperGetMv("MV_TXVISTA") == "S",.F.,.T.)
Local nValImps := 0
Local nValBasOri := nValorBase
Local nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para efetuaar rateio o valor do frete   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nDescDif		:= 0
Local nValRateado 	:= 0
Local cSimbDup      := "DP "
Local cMvSimb1 		:= SuperGetMv("MV_SIMB1")
Local nDecs         := 2
 
If lTxJuros == Nil
	lTxJuros := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se cadastrou taxa de Juros retorna ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Os valores da venda tem que ser recalculados quando o pais eh diferente de Brasil.  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cPaisLoc <> "BRA") .AND. (FunName() == "LOJA010")
	nValImps   := Lj010RecVB(nValorBase,nTxJuros,0,nDescLoj,@nLiq,;
	nDescPer,nTipoJur,nNumParcelas,nEntrada)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Entrada esta maior que o valor a pagar e acerta o valor ³
//³ Isto pode ocorrer no caso de recalculo das parcelas na Cond. Negociada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nEntrada > nValorBase
	nEntrada := nValorBase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Limpa a tx. de juros (caso exista), pois neste caso o pagto sera a vista            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTxJuros > 0
		nTxJuros := 0
	Endif
Endif

If nTxJuros == 0
	If nEntrada > 0
		nFinanciado := Round(nValorBase - nEntrada - nVlrFSD,nDecimais)
		nValor := nValorBase
	Else
		nFinanciado := nValorBase
		nValor := nFinanciado
	Endif
Else
	If cPaisLoc == "BRA"
		nValor := nValorBase - nVlrFSD
	Else
		nValor := nLiq - nVlrFSD
	EndIf
	If SuperGetMv("MV_TXVISTA") == "N"
		nValor  := nValor - nEntrada
	Endif
	If lAcrBru
		nValor += nDescLoj
	Endif
	nFinanciado := nValor - nEntrada
	
	If nEntrada > 0
		If nTipoJur = 1  //Juros Simples
			If Round(NoRound(nEntrada,2),2) == Round(NoRound(nValorBase,2),nDecimais)
				nValor := nValor + (Round((nValor * nTxJuros) / 100,nDecimais))
				nFinanciado := 0
				If lAcrBru
					nValor -= nDescLoj
				Endif
			Else
				nValor := nValor + (Round((nValor * nTxJuros) / 100,2))
				nFinanciado := nValor
				If lAcrBru
					nFinanciado -= nDescLoj
				Endif
			Endif
		ElseIf nTipoJur = 2 //Juros Compostos
			If !lCalcFin //Round(NoRound(nEntrada,2),2) == Round(NoRound(nValorBase,2),2)
				nValor := Round(nValor * (( 1 + ( nTxJuros/100 ) ) ^ nNumParcelas) ,nDecimais)
				nFinanciado := 0
				If lAcrBru
					nValor -= nDescLoj
				Endif
			Else
				nValor := Round(nValor * (( 1 + ( nTxJuros/100 ) ) ^ (nNumParcelas - 1)) ,nDecimais)
				nFinanciado := nValor
				If lAcrBru
					nFinanciado -= nDescLoj
				Endif
			Endif
		Endif
	Else
		If nTipoJur = 1  //Juros Simples
			nValor := nValor + (Round((nValor * nTxJuros) / 100,nDecimais))
			nFinanciado := nValor
			If lAcrBru
				nFinanciado -= nDescLoj
			Endif
		ElseIf nTipoJur = 2     //Juros Composto
			nValor := Round(nValor * (( 1 + ( nTxJuros/100 ) ) ^ nNumParcelas) ,nDecimais)
			nFinanciado := nValor
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Recupera o valor base original, para a montagem das parcelas  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "BRA"
		If Round(nValor-nValorBase,nDecimais) > aDadosJur[1]
			nValor -= Round(nValor-nValorBase,nDecimais)
			nValor += aDadosJur[1]
		ElseIf Round(nValor-nValorBase,nDecimais) < aDadosJur[1] .AND. (nTipoJur == 2)
			aDadosJur[1] -= (aDadosJur[1] - (nValor-nValorBase))
		Endif
		nValorBase := nValBasOri
	Endif
	
	aParc := MontParcelas(aCondicoes,If(nEntrada>0,.T.,.F.),If(cPaisLoc=="BRA",nValorBase,nLiq),@nEntrada,;
	@nFinanciado,0,nParcelas,nIntervalo,nTipoJur,;
	nDescLoj,@nLiq,nDescPer,nTipoJur)
	
	For j := 1 to Len(aParc)
		If aParc[j][1] == If(aAltDtBase[1],aAltDtBase[2],dDataBase)
			AAdd(aTmp,{aParc[j][1],aParc[j][2],cMvSimb1,nMoedaCor})
		Else
			AAdd(aTmp,{aParc[j][1],aParc[j][2],If(Empty(cForma),cForma,If(cPaisLoc=="SAL",cSimbDup,cSimbCheq)),nMoedaCor})
		Endif
		If cPaisLoc == "ARG"
			AAdd(aTmp[j],aParc[j][1])
		ElseIf cPaisLoc <> "BRA"
			AAdd(aTmp[j],dDatabase)		    	
		Endif
	Next j
	
	If cPaisLoc <> "BRA"
		If nTxJuros > 0
			nVlrAcrs := aDadosJur[1]
		Else
			nVlrAcrs := 0
		EndIf
		nValorBase := aDadosJur[3]+nVlrAcrs+nValImps
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o tamanho da aTmp e igual ao aPgtos                ³
	//³Caso não seja serah considerada as formas de pagamento default ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aTmp) == Len(aPgtos)
		For j:=1 to Len(aTmp)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se a data da parcela for posterior ao dia de hoje e a forma de pagto for   ³
			//³ igual a R$ (MV_SIMB1) transforma a forma de pgto em CH.                    ³
			//³ Se a data da parcela for igual ao dia de hoje transforma em R$ (moeda1)    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aTmp[j][1] > If(aAltDtBase[1],aAltDtBase[2],dDataBase)	.AND. Alltrim(aPgtos[j][3]) == Alltrim(cMvSimb1)
				aTmp[j][3] := cSimbCheq
			ElseIf aTmp[j][1] == If(aAltDtBase[1],aAltDtBase[2],dDataBase)
				aTmp[j][3] := cMvSimb1
			Else
				aTmp[j][3] := aPgtos[j][3]
			Endif
		Next j
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se utiliza opção de cálculo com Dia Fixo, ³
	//³recalcula as datas das parcelas           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDiaFixo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de uso da opção Dia Fixo para vencimento das parcelas,   ³
		//³a variável nIntervalo é utilizada para armazenar o dia escolhido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cE4Cond:= Str(nParcelas)+',0,'+Str(nIntervalo)
		aE4 := {,cE4Cond, "3"," "," "," "}
		aParcDiaFixo := AvalCond( nFinanciado , , , , nRetICMS, ,aE4,nVlrAcrs,aE4, ,{0,nIntervalo} ) 

		For nX=1 to Len(aTmp)
			aTmp[nX][1] := aParcDiaFixo[nX][1]			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Há uma exceção para o mês de Fevereiro em anos não bissextos: Se a venda for               ³
			//³efetuada no dia 31, a data do vencimento deverá cair no dia 1º de março e não no dia 28/02.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Month(aTmp[nX][1]) == 2 .AND. nIntervalo == 31 .AND. !AnoBissexto( Year(aTmp[nX][1]) )
				aTmp[nX][1] := Ctod('01/03/'+ Str(Year(aTmp[nX][1])))
			Endif
		Next nX			
	Endif
	
	aPgtos := Aclone(aTmp)
	oPgtos:SetArray( aPgtos )
	oPgtos:bLine := {||{aPgtos[oPgtos:nAt,1],;
	Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,aPgtos[oPgtos:nAt,4])),;
	aPgtos[oPgtos:nAt,3],aPgtos[oPgtos:nAt,4]}}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Refresh no folder 2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPgtos:Refresh()
	aParcTef := aClone(aPgtos)
	oEntrada:Refresh()
	oNumParcelas:Refresh()
	oFinanciado:Refresh()
	oVlrAcrs:Refresh()
	oTxJuros:Refresh()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Atualiza a exibicao dos impostos variaveis  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "BRA"
		oVlrImpos:Refresh()
	Endif
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o valor total de acrescimo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Round(NoRound(nValorBase,2),2) > Round(NoRound(nFinanciado + nEntrada + nVlrFSD,2),2)
	nVlrAcrs := Round(nValorBase - (nFinanciado + nEntrada+ nVlrFSD),2)
Else
	nVlrAcrs := 0
Endif

If nEntrada # 0
	If cPaisLoc == "BRA"
		AAdd( aParc,{ If(nIntervalo<>0 .OR. Len(aParcelas)=0,dDataBase,;
					If(Len(aParcelas)>0,aParcelas[1][1],dDataBase)),;
					If(nParcelas==1 .AND. nFinanciado==0,nValor,nEntrada),;
					cForma,nMoedaCor})
	Else
		AAdd( aParc,{ If(nIntervalo<>0.OR.Len(aParcelas)=0,dDataBase,;
					If(Len(aParcelas)>0,aParcelas[1][1],dDataBase)),;
					If(nParcelas==1,nValor,nEntrada),cForma,nMoedaCor,;
					If(nIntervalo<>0.OR.Len(aParcelas)=0,dDataBase,;
					If(Len(aParcelas)>0,aParcelas[1][1],dDataBase))})
	Endif					
Endif

nTotal := 0

If nEntrada # nValor
	If nParcelas > 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o numero de parcelas for maior que '1' e existe entrada³
		//³as parcelas devem comecar a ser montadas partir da segunda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nEntrada <> 0
			nDE := 2
		Else
			nDE := 1
		EndIf
		nAte      := nParcelas
		dData     := dDataBase
		For j := nDe To nAte
			dData += nIntervalo
			If nEntrada == 0
				AAdd( aParc,{dData,NoRound(nFinanciado/nParcelas),If(cPaisLoc=="SAL",cSimbDup,cSimbCheq),nMoedaCor})
			Else
				AAdd( aParc,{dData,NoRound(nFinanciado/(nParcelas-1)),If(j>1,If(cPaisLoc=="SAL",cSimbDup,cSimbCheq),cForma),nMoedaCor})
			Endif
		    If cPaisLoc <> "BRA"							
			   nDecs  := MsDecimais(aParc[j][4])		    
			   AAdd(aParc[j],dDataBase)		    
			   aParc[j][2]  := Round(aParc[j][2],nDecs)
			   If cPaisLoc == "ARG"
				  aParc[j][5]  := dData
			   Endif	  
			Endif
			nTotal += aParc[j][2]
		Next j
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajuste da ultima parcela (arredondamento) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParc[j-1][2] += nFinanciado - nTotal
	Else
		AAdd( aParc,{dDataBase,nFinanciado,If(cPaisLoc=="SAL",cSimbDup,cSimbCheq),nMoedaCor})
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se eh necessario ratear o valor do frete ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVlrFSD > 0 .AND. nEntrada > 0 .AND. nParcelas > 1
	nDescDif 	:= 0
	nValRateado := NoRound(nVlrFSD / (Len(aParc)-1),2)
	For j := 2 to Len(aParc)
		aParc[j][2] += nValRateado
	Next j
	If (nValRateado * (Len(aParc)-1)) <> nVlrFSD
		aParc[Len(aParc)][2] += (nVlrFSD - (nValRateado * (Len(aParc)-1)))
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se utiliza opção de cálculo com Dia Fixo, ³
//³recalcula as datas das parcelas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDiaFixo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de uso da opção Dia Fixo para vencimento das parcelas,   ³
	//³a variável nIntervalo é utilizada para armazenar o dia escolhido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cE4Cond:= Str(nParcelas)+',0,'+Str(nIntervalo)
	aE4 := {,cE4Cond, "3"," "," "," "}
	aParcDiaFixo := AvalCond( nFinanciado , , , , nRetICMS, ,aE4,nVlrAcrs,aE4, ,{0,nIntervalo} ) 

	For nX=1 to Len(aParc)
		aParc[nX][1] := aParcDiaFixo[nX][1]			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Há uma exceção para o mês de Fevereiro em anos não bissextos: Se a venda for               ³
		//³efetuada no dia 31, a data do vencimento deverá cair no dia 1º de março e não no dia 28/02.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Month(aParc[nX][1]) == 2 .AND. nIntervalo == 31 .AND. !AnoBissexto( Year(aParc[nX][1]) )
			aParc[nX][1] := Ctod('01/03/'+ Str(Year(aParc[nX][1])))
		Endif
	Next nX			
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava no array do ListBox as parcelas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPgtos := Aclone(aParc)
oPgtos:SetArray( aPgtos )
oPgtos:bLine := {||{aPgtos[oPgtos:nAt,1],;
Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,aPgtos[oPgtos:nAt,4])),;
aPgtos[oPgtos:nAt,3],aPgtos[oPgtos:nAt,4]}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refresh no folder 2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPgtos:Refresh()
aParcTef := aClone(aPgtos)
oEntrada:Refresh()
oNumParcelas:Refresh()
oFinanciado:Refresh()
oVlrAcrs:Refresh()
oTxJuros:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WriteButto³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ ...                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WriteButton(x,oBtn1)

If x == 1
	oBtn1:SetEnable(.T.)
Else
	oBtn1:SetDisable(.T.)
Endif

Return( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010Fill ºAutor  ³Vendas Clientes      º Data ³  21/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche matriz de pagamentos com a forma escolhida.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Fill(	oComboPag	, cComboPag		, aItens		, dDataForm	,;
					lCheckPag	, nValor		, nEntrada		, oEntrada	,;
					nFinanciado	, oFinanciado	, cNomeMoeda	, aTmpPgtos	,;
					nTipoJur	, nValFat       )

Local cSimb		:= ""											// Simbolo da moeda utilizada na venda

Local nEl 		:= AScan( aItens, { |x| x[1] = cComboPag } )	// Posicao do conteudo cComboPag no aItens
Local nI		:= 0											// Variavel utilizada no For... Next
Local nZ		:= 0											// Variavel utilizada no For... Next
Local nValTot	:= 0											// Valor total
Local nValDif	:= 0											// Valor da diferenca
Local nValPar	:= 0											// Valor da parcela
Local nValTPed	:= 0											// Valor total do pedido
Local nPosMoeda := 0											// Posicao do campo moeda no aPgtos
Local nTmpEntr  := 0											// Valor de entrada
Local nTmpFinan := 0											// Valor do financiamento
Local nValTaxa	:= 0											// Valor da taxa
Local nDivisor1	:= 0											// Divisor
Local nParcelas	:= 0											// Quantidade de parcelas
Local nTmpJuros	:= 0											// Valor de Juros
Local nMoedaParc:= 0											// Moeda da parcela
Local nDecs     := MsDecimais(nMoedaCor)						// Casas decimais
Local nValParc  := 0											// Valor da parcela
Local nValNCC   := 0											// Valor da NCC
Local nTrocoTot := 0											// Valor total do troco

Local lSintVisu := If( Alltrim( Upper( FunName() ) ) == "FRTA010" .AND. SL4->( FieldPos( "L4_FORMAID" ) ) > 0, .T., .F. )	// Verifica se a visualizacao sintetica esta ativa
Local nPosObj	:= If( lSintVisu .AND. Type( "oPgtosAna" ) == "O", oPgtosAna:nAt, oPgtos:nAt )								// Linha que esta pintada

Local lRecalc   := .T.											// Verifica se deve recalcular os valores
Local lUsaTroco := ( SuperGetMV( "MV_LJTROCO",, .F. ) .AND. SL1->( FieldPos( "L1_TROCO1" ) ) > 0 .AND. cPaisLoc == "BRA" )  // Determina se usa troco para diversas formas de pagamento
Local lLjtrcloc := ( cPaisLoc <> "BRA" .AND. SuperGetMV("MV_LJTRLOC",, .F.)  .AND. SL1->( FieldPos( "L1_TROCO1" ) ) > 0 )   // Determina se usa troco localizado para diversas formas de pagamento
Local lAltera   := .F.

If lVendaRapida
	nPosMoeda := 11
Else
	nPosMoeda := 4
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Calcula o Total do Pedido  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValTPed := 0
For nI := 1 To Len(aPgtos)
	If cPaisLoc == "BRA"
		nValTPed := nValTPed + aPgtos[nI][2]
	Else
		nValTPed := nValTPed + xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
	Endif
Next nI

If cPaisLoc <> "BRA"
	For nI := 1 To MoedFin()
		If(!(Empty(SuperGetMv("MV_MOEDA"+Ltrim(STR(nI))))))
			If SuperGetMv("MV_MOEDA"+Ltrim(STR(nI))) == cNomeMoeda
				aPgtos[nPosObj][nPosMoeda] := nI
				Exit
			Endif
		Else
			Exit
		Endif
	Next nI
Endif

aPgtos[nPosObj][1]	:= dDataForm

If cPaisLoc <> "BRA"
	If lLjtrcloc .AND. aPgtos[nPosObj][2] <> nValor
		aPgtos[nPosObj][2] := nValor	
		lAltera := .T.
	Else
		If (nPosObj <> Len( aPgtos ) .OR. Len( aPgtos ) == 1) .AND. aPgtos[nPosObj][2] <> nValor
			aPgtos[nPosObj][2] := nValor	
			lAltera := .T.
		EndIf
	EndIf	
Else
	If lUsaTroco .AND. aPgtos[nPosObj][2] <> nValor
		aPgtos[nPosObj][2] := nValor	
		lAltera := .T.
	Else
		If (nPosObj <> Len( aPgtos ) .OR. Len( aPgtos ) == 1) .AND. aPgtos[nPosObj][2] <> nValor
			aPgtos[nPosObj][2] := nValor	
			lAltera := .T.
		EndIf
	EndIf
EndIf

aPgtos[nPosObj][3]	:= aItens[nEl][2]
nMoedaParc 			:= aPgtos[nPosObj][nPosMoeda]

If lAltera
	Lj010ReFill( nPosObj, nValTPed, aPgtos )
EndIf

If cPaisLoc <> "BRA" .AND. nMoedaParc > 1  //Mostra o simbolo da moeda correspondente para a parcela
	If IsMoney(aPgtos[nPosObj,3])
		cSimb := "MV_SIMB"+AllTrim(Str(nMoedaParc))
		aPgtos[nPosObj,3] := SuperGetMv(cSimb)
	Endif
Endif

nTmpEntr    := nEntrada
nTmpFinan   := nFinanciado

If cPaisLoc == "BRA"
	nEntrada := A410Arred( aPgtos[1][2], "L4_VALOR", nMoedaCor )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Caso utilize troco, nao retirar a entrada, caso contrario ficara com financiamento negativo   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTroco .AND. lVendaRapida .AND. FunName() <> "LOJA220"
		nFinanciado := 0
		aEval( aPgtos, { |ExpA1,nCnt| nFinanciado += If(nCnt == 1,0,ExpA1[2]) })
	Else                                        
		nFinanciado := Round(nValTPed - nEntrada, 2)
	Endif                                       
	
	If nFinanciado < 0
		nFinanciado := 0
	Endif

	If !lVendaRapida
		oEntrada:Refresh()
		oFinanciado:Refresh()
	Endif

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Calcular a entrada e o valor financiado considerando multi-moeda                    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nEntrada    := 0
	nFinanciado := 0
	For nI := 1 To Len(aPgtos)
		If aPgtos[nI,1] == dDataBase
			nEntrada    += xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
		Endif
		nValParc += xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
	Next nI
	nFinanciado := Max(Round(nValParc - nEntrada, nDecs),0)
	If !lVendaRapida
		oEntrada:Refresh()
		oFinanciado:Refresh()
	Endif
Endif

If Len(aPgtos) > nPosObj .AND. !(lUsaTroco .AND. lVendaRapida .AND. FunName() <> "LOJA220")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Calcula quanto ‚ o Valor Total at‚ a parcela alterada.                              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValTot := 0
	For nI := 1 To nPosObj
		If cPaisLoc == "BRA"
			nValTot := nValTot + aPgtos[nI][2]
		Else
			nValTot := nValTot + xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
		Endif
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Calcula a diferen‡a    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValDif := Max(nValTPed - nValTot,0)     //Localizacoes - permite valores das parcelas maior que valor da fatura
	nParcelas := (Len(aPgtos) - nPosObj) // Parcelas Restantes

	If nTxJuros == 0 .AND. nValorBase < nValTPed
		nTmpJuros := SE4->E4_ACRSFIN
	Else
		nTmpJuros := nTxJuros
	Endif
	
	If !SuperGetMv("MV_TXVISTA") == "S" .AND. !nTmpEntr == nEntrada .AND. nTmpJuros > 0
		nValDif := nValorBase - nEntrada
		nValTaxa := nTmpJuros / 100
		If SuperGetMv("MV_PRICE")   == "S"
			nDivisor1 := (1 + nValTaxa) ^ nParcelas
			nValDif := (nValDif * ((nDivisor1 * nValTaxa) / (nDivisor1 -1))) * nParcelas
		Else
			nValDif := nValorBase - nEntrada
			If nTipoJur = 1
				nValDif  := Round(nValDif + (nValDif * nValTaxa),2)
			ElseIf nTipoJur = 2
				nValDif  := Round(nValDif * (( 1 + nValTaxa ) ^ nParcelas) ,2)
			Endif
		Endif
		nFinanciado := nValDif
		nValTPed := nEntrada + nFinanciado
		nVlrAcrs := nValTPed - nValorBase
	Endif
	
	If Type("nParcAtual") == "N" 
		If nParcAtual == nValor
			lRecalc := .F.
		Endif
	Endif
	
	If lRecalc
		nValPar := NoRound(nValDif / nParcelas,nDecs)
		
		For nI := nPosObj+1 To Len(aPgtos)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Atualiza o valor da parcela considerando a moeda correspondente                     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aPgtos[nI][2] := xMoeda(nValPar,nMoedaCor,aPgtos[nI][nPosMoeda],dDatabase,,nTaxaMoeda)
		Next nI
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Calcula o Valor Total atual    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValTot := 0
		For nI := 1 To Len(aPgtos)
			If cPaisLoc == "BRA"
				nValTot := nValTot + NoRound(aPgtos[nI][2])
			Else
				nValTot := nValTot + xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
			Endif
		Next nI
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  Soma a diferen‡a na £ltima parcela   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			aPgtos[Len(aPgtos)][2] := aPgtos[Len(aPgtos)][2] + (nValTPed - nValTot)
		Else
			nValNCC := If(Type("nNccUsada") <> "N",0,nNccUsada)
			aPgtos[Len(aPgtos)][2] += xMoeda((nValTPed - nValNCC - nValTot),nMoedaCor,aPgtos[Len(aPgtos)][nPosMoeda],dDatabase,,nTaxaMoeda)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Apos o ajuste dos valores de acordo com a fatura atualizar os valores de entrada e financiado   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nEntrada    := 0
			nFinanciado := 0
			nValParc    := 0
			For nI := 1 To Len(aPgtos)
				If aPgtos[nI,1] == dDataBase
					nEntrada    += xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
				Endif
				nValParc += xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
			Next nI
			nFinanciado := Max(Round(nValParc - nEntrada, nDecs),0)
		Endif
	Endif
ElseIf lUsaTroco .AND. lVendaRapida .AND. FunName() <> "LOJA220" //Alimento a variavel nTroco, pois no front loja, eh responsavel pela impressao do troco.
	aEval(aPgtos,{|x| nTrocoTot += x[2]} )
	If Type("nTroco") == "N" .AND. Type("nTroco2") == "N"
		nTroco := nTroco2 := Abs( nTrocoTot - nValFat )
	Endif
Endif

If lCheckPag
	For nI := nPosObj To Len(aPgtos)
		aPgtos[nI][3] := aItens[nEl][2]
	Next nI
Endif

If cPaisLoc <> "BRA"
	For nI := 1 to Len(aPgtos)
		If aPgtos[nI][2] <= 0
			MsgStop(STR0031)  //"Nenhuma parcela pode ser menor ou igual a zero."
			For nZ:= nPosObj to Len(aPgtos)
				aPgtos[nZ][1] := aTmpPgtos[nZ][1]
				aPgtos[nZ][2] := aTmpPgtos[nZ][2]
				aPgtos[nZ][3] := aTmpPgtos[nZ][3]
				aPgtos[nZ][nPosMoeda] := aTmpPgtos[nZ][nPosMoeda]
			Next nZ
			nEntrada    := nTmpEntr
			nFinanciado := nTmpFinan
			If !lVendaRapida
				oEntrada:Refresh()
				oFinanciado:Refresh()
			Endif
			Exit
		Endif
	Next nI
Endif

oPgtos:Refresh()
aParcTef := aClone(aPgtos)

If Type("oPgtosAna") == "O"
	oPgtosAna:Refresh()
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjEntry   ³ Autor ³ Vendas Clientes       ³ Data ³ 12.06.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ponto de entrada acionado atrav‚s da tecla F11              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJENTRY()

If ExistBlock("Lj010FIN")
	ExecBlock("Lj010FIN",.F.,.F.)
Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ Lj010Tes ³ Autor ³Vendas Clientes        ³ Data ³ 09/11/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Validar o TES e disparar Roteiro de C lculo de Impostos... ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj010Tes()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Tes(	cTes,		oVlrTot,	oVlrliq,	nVlrTot,;
					nValorBase,	nVlrLiq	)
Local lRet   := .T.
Local nPosCF := 0
Local cCF    := ""

If cTes >= "500"
	SF4->( DbSetOrder(1) )
	SF4->( DbSeek(xFilial("SF4")+cTes) )
	If ! SF4->( Found() )
		lRet := .F.
	Else
		cCF := SF4->F4_CF
		If ( nPosCF := AScan( aHeader,{|x| Trim( x[2] ) == "L2_CF" } ) ) > 0
			aCols[n][nPosCF] := cCF
		Endif
	Endif
Endif
If !lRet
	Help(" ",1,"A100INVTES")
Endif
Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CalcComis ³ Autor ³ Vendas Clientes       ³ Data ³ 01/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula a ComissÆo para os Vendedores                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CalcComis(	nEmis,	nTotal,		nVend,		nQParcela,;
					cTipo,	nBaixa,		nBase,		nPerc	)
Local nComis:= 0
Local nDif      := 0

If (cTipo = "P")
	nComis                          := NoRound(((nEmis/nQParcela)/nTotal) * 100,2)
	aAComis[nVend][1] += nComis
	
	If (nNParc == nQParcela)
		nDif     := NoRound((nEmis/nTotal) * 100,2)- aAComis[nVend][1]
		
		If (nDif > 0)
			nComis += nDif
		Endif
	Endif
Else
	nComis:= (nBase * nPerc)/100
	aAComis[nVend][2] += nComis
	If (nNParc == nQParcela)
		nDif     := nBaixa - aAComis[nVend][2]
		
		If (nDif > 0)
			nComis += nDif
		Endif
	Endif
Endif

Return nComis



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Det  ³ Autor ³ Vendas Clientes       ³ Data ³ 08.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Acols para inclusao ou alteracao de orcamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Det(	cCliente,		cNumOrc,	lFirst,		lInclui,;
					oVlrItens,		nVlrItens	)

Local lRet		  := .T.	
Local aFirst[1][nUsado+1]
Local cProdRef    :=""
Local nRndFat     := MsDecimais(nMoedaCor)
Local nPosProd    := aPosicoes[9][2]	
Local nDif        := 0 
Local nUltIt      := 0
Local nColIcm     := 0
Local lImpOrc	  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Na inclusao -> cria uma matriz acols em branco. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := aClone(aFirst)

If lInclui
	nUsado := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona ponteiro do arquivo cabeca e inicializa variaveis  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek( "SL2" )
	While !EOF() .AND. x3_arquivo == "SL2"
		If x3Uso(x3_usado) .AND. cNivel >= x3_nivel .AND. !(alltrim(x3_campo)=="L2_NUM")
			nUsado++
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ Monta Array de 1 elemento ³
			*³ vazio. Se inclus†o.       ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF x3_tipo == "C"
				If X3_PROPRI == "U"
					aCOLS[1][nUsado] := Criavar( aHeader[nUsado][2] )
				Else
					aCOLS[1][nUsado] := SPACE(x3_tamanho)
				Endif
			ELSEIF x3_tipo == "N"
				aCOLS[1][nUsado] := 0
			ELSEIF x3_tipo == "D"
				aCOLS[1][nUsado] := dDataBase
			ELSE
				aCOLS[1][nUsado] := .F.
			Endif
		Endif
		DbSkip( )
	End
	aCOLS[1][nUsado+1] := .F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Na alteracao -> cria uma matriz acols preenchida.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCnt:=0
	DbSelectArea( "SL2" )
	DbSetOrder( 1 )
	DbSeek( xFilial("SL2") + cNumOrc )
	nRegistro := RecNo( )
	While !EOF( ) .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2") + cNumOrc
		If L2_VENDIDO == "S" .OR. Lj010Ver()
			DbSkip( )
			Loop
		Endif
		nCnt++
		IF nCnt > 1
			AAdd(aCols,Array(nUsado+1))
		Endif
		DbSkip( )
	End
	If nCnt == 0
		Help(" ",1,"VENDIDO" )
		lRet := .F.
		Return(lRet)
	Endif
	DbGoto( nRegistro )
	nCnt            := 0
	nUsado := 0
	nDif   := 0
	While !EOF( ) .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+cNumOrc

		If L2_VENDIDO == "S"
			DbSkip( )
			LOOP
		Endif
		nCnt++
		nUsado:=0
		
		If SuperGetMv("MV_VEICULO") == "S"		
			DbSelectArea("SX3")
			DbSetOrder(2)
			DbSeek( "L2_PRODUTO" )
			aCOLS[nCnt][nPosProd] := &("SL2->" + x3_campo)
		Endif
		
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek( "SL2" )
		
		While !EOF() .AND. x3_arquivo == "SL2"
			If x3Uso(x3_usado) .AND. cNivel >= x3_nivel .AND. !(alltrim(x3_campo)=="L2_NUM")
				nUsado++
				
				
				*------------ Inicio alteracao ------------------
				
				n:= nCnt
				If AllTrim(x3_campo) == "L2_VLRITEM"
					aCOLS[nCnt][nUsado] := &("SL2->" + x3_campo) + SL2->L2_DESCPRO
				ElseIf AllTrim(x3_campo) == "L2_VRUNIT"
					If SL2->L2_DESCPRO > 0
						If SuperGetMv("MV_ARREFAT") == "S"
							aCOLS[nCnt][nUsado] := Round((SL2->L2_VLRITEM + SL2->L2_DESCPRO) / SL2->L2_QUANT,nRndFat)
						Else
							aCOLS[nCnt][nUsado] := noRound((SL2->L2_VLRITEM + SL2->L2_DESCPRO) / SL2->L2_QUANT,nRndFat)
						Endif
					Else
						aCOLS[nCnt][nUsado] := &("SL2->" + x3_campo)
					Endif
				ElseIf AllTrim(x3_campo) == "L2_VALIPI"
					aCOLS[nCnt][nUsado] := Lj010Ipi(SL2->L2_PRCTAB,SL2->L2_QUANT,SL2->L2_DESC,SL1->L1_DESCNF,SL2->L2_TES,nCnt,SL2->L2_PRODUTO,,SL2->L2_VALFRE,SL2->L2_SEGURO,SL2->L2_DESPESA)
				ElseIf AllTrim(x3_campo) == "L2_VALICM"
					aCOLS[nCnt][nUsado]  := Lj010Icms(nCnt,@nDif)
					nUltIt		         := If(aCOLS[nCnt][nUsado] > 0,nCnt,nUltIt)
					nColIcm	             := nUsado
				ElseIf AllTrim(x3_campo) == "L2_VALISS"
					aCOLS[nCnt][nUsado] := Lj010Iss()
				Else
				    If X3_CONTEXT <> "V"
						aCOLS[nCnt][nUsado] := &("SL2->" + x3_campo)
					Else
						aCOLS[nCnt][nUsado] := &(x3_relacao)					
					Endif
				Endif
				
				*--------------- Fim Alteracao -------------
				
			Endif
			DbSkip()
		End

		aCols[nCnt][Len(aCols[nCnt])] := .F.

		DbSelectArea( "SL2" )
		If lGrade
			cProdRef := Substr(SL2->L2_PRODUTO,1,nTamRef)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o AcolsGrade e o AheadGrade para este item            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			a010Mont(nCnt,cProdRef,"N")
		Endif
		DbSkip()
	End

	nVlrDesc := SL1->L1_DESCONT
	nVlrFSD  := SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //| Calculo da diferenca de aliquota de ICMS   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDif := Noround(nDif,2)
	If nDif >= 0.01 .AND. nUltIt > 0 .AND. nColIcm > 0
		aCols[nUltIt][nColIcm] += nDif
	Endif

	n := 1
	oGet:oBrowse:Refresh()
	If Valtype(nVlrItens) == "N"
		nVlrItens := Len(aCols)
		oVlrItens:Refresh()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprimir itens do orçamento na Venda Concomitante                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("lVendConc") == "L" .AND. lVendConc
		LjMsgRun(STR0109 ,, {|| lImpOrc := Lj010ImpIt() }) // "Aguarde a Impressão dos Itens do Orçamento..."
	    If lImpOrc
	       lRet := .T.
	    Else
	       lRet := .F.
	    Endif
	Endif

Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010GravaºAutor  ³Vendas Clientes      º Data ³  08/06/94   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava as informacoes do orcamento.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja - Venda Balcao                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Grava(	cNumOrc		, cCliente	, cVendLoja	, nVlrTot	 ,;
						nDescloj	, nVlrLiq	, dDtlim	, cLoja		 ,;
						nCheck		, lCheck3	, cNroPCli	, nValorBase ,;
						nDescPer	, nLiq		, lFinalVend, lInclui	 ,;
						aCpoEnchoice, cLJDTORC	, lLJDTOrc	, aMoedas	 ,;
						nTxDescon )

Local nx			:= 1 
Local nC			:= 1 
Local nCntFor		:= 1
Local ny			:= 1
Local nI			:= 1
Local cX			:= "00"
Local nRegis
Local nRegAnt
Local nItem			:= 0
Local nVlrItem		:= 0
Local nValIcms		:= 0
Local nValIss		:= 0
Local nValIpi		:= 0
Local nBaseIcm		:= 0
Local nDif			:= 0
Local nUltIt		:= 0
Local nDesct		:= 0
Local cProduto 		
Local cCfo
Local cVar
Local cItenf	 	:= Repl( "0", TamSX3( "D2_ITEM" )[1] )
Local cConfVenda	:= Replicate( "S", 12 )
Local nPosValIcm	:= aPosicoes[6][2]
Local lSaci001T 	:= ExistTemplate( "SACI001" )
Local lSaci001  	:= ExistBlock( "SACI001" )
Local lTlsp001T 	:= ExistTemplate( "TLSP001" )
Local lTlsp001  	:= ExistBlock( "TLSP001" )
Local lRet          := .T.
Local i				:= 0 
Local cGrade		:= "N"
Local nGrade		:= 0
Local nRndFat		:= MsDecimais( nMoedaCor )
Local bCampo		:= { |x| FieldPos( x ) }
Local nCont			:= 1
Local nValMerc		:= 0
Local nValItens		:= 0
Local nDecs			:= MsDecimais( nMoedaCor )
Local nCredLj		:= 0
Local nPosCpo		:= 0
Local nValMercParc	:= 0
Local nItensParc	:= 0
Local nRndItem		:= If( nDecs == 0, nDecs, TamSX3( "L2_VRUNIT" )[2] ) //So ira ser zero nos casos em que a moeda corrente nao possui decimais
Local nPosReserva	:= AScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_RESERVA" } )
Local nPosTES		:= AScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_TES" } )
Local nPosVlrItem	:= AScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_VLRITEM" } )
Local nPosLoc		:= AScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_LOCAL" } )
Local nPosValFre	:= AScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_VALFRE" } )
Local nPosSeguro	:= AScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_SEGURO" } )
Local nPosDespesa	:= AScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_DESPESA" } )
Local lReserva		:= .F.
Local aDespFrete	:= Array( Len( aCols ), 3 )
Local nVlrTotFrt	:= 0
Local nPerTotal		:= 0
Local nVlrFrete		:= 0
Local nVlrSeguro	:= 0
Local nVlrDespesa	:= 0
Local nCountFrt		:= 0
Local nFrete		:= 0
Local nSeguro		:= 0
Local nDespesa		:= 0
Local nValMercAux	:= 0
Local nPosVend		:= AScan( aHeader, { |x| Alltrim( x[2] ) == "L2_VEND" } )
Local lEmptyVend	:= .T.
Local cVendAnt		:= ""
Local lFirst		:= .T. 
Local lDifVend		:= .F.
Local lEstoque		:= .T.					//Verifica se tem estoque disponivel
Local aProdutos		:= {}					//Array com todos os produtos que nao tem estoque
Local nItProd		:= 0					//Variavel para varrer o array com os produtos sem estoque
Local nPosProd		:= 0					//Variavel utilizada no AScan para verificar se o produto já existe no array
Local cProds		:= ""					//String com todos os produtos contidos no array para apresentar a mensagem na tela
Local aDadosCfo		:= {}
Local aFields		:= {	"L1_TRANSP"	,	"L1_ENDCOB" ,	"L1_ENDENT" ,	"L1_TPFRET" , "L1_BAIRROC"	,;
							"L1_CEPC"	,	"L1_MUNC"   ,	"L1_ESTC"   ,	"L1_BAIRROE", "L1_CEPE"		,;
							"L1_MUNE" 	, 	"L1_ESTE" 	,	"L1_FRETE"  ,	"L1_SEGURO" , "L1_PLIQUI" 	,;
							"L1_PBRUTO" ,	"L1_DESPESA",	"L1_ESPECIE",	"L1_VOLUME" , "L1_MARCA"	,;
							"L1_NUMERO" ,	"L1_PLACA"  ,	"L1_UFPLACA" }
Local nTamL2_DES 	:= TamSX3( "L2_DESCPRO")[2]		// Tamanho do campo L2_DESCPRO
Local nTamL1_DNF    := TamSX3( "L1_DESCNF" )[2]		// Tamanho do campo L1_DESCNF


Local nItensRT 		:= 0      				//Número itens que tiveram rateios de desconto.
Local nPRT     		:= 0      				//Porcentagem dos itens que não tiveram rateios devido a ser serviço e estar em MG.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao que faz a atualizacao do database.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LjECFxData()
	Return .F. 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a data do limite seja menor que o database, ajustar base³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDataBase > dDtLim
	dDtLim := dDataBase
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a parcela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( aPgtos )
	If aPgtos[nX][1] < dDataBase
		MsgStop( STR0087 , STR0088 )//"As datas de vencimento das parcelas é menor que a data do sistema, verifique !"###

		Return .F.
	Endif
Next nX

If Empty( cVendLoja )
   MsgStop( STR0112, STR0088 )//"Favor preencher o vendedor na primeira pasta!"###"Atenção"	    						

   Return .F.   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entrada   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTlsp001T    
	lRet := ExecTemplate( "TLSP001", .F., .F., { cNumOrc, lFinalVend } )
	If !lRet
		Return lRet
	Endif
Endif

If lTlsp001 
	lRet := ExecBlock( "TLSP001", .F., .F., { cNumOrc, lFinalVend } )
	If !lRet
		Return lRet
	Endif
Endif

//ÚÄÄÄÄÄ¿
//³GRADE³
//ÀÄÄÄÄÄÙ
If !__lPyme
	nGrade := AScan( aCampos, "L2_GRADE" )

	For i := 1 To Len( aCols )
		If aCols[i][nGrade] == "S"
			cGrade:= "S"	

			Exit
		Endif
	Next i
Endif

If lGrade .AND. cGrade == "S"
	a010GraGrd()
Endif

nValIcms := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o rateio do frete, seguro e desp.acessórias pelos itens vendidos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrTotFrt 	:= 0
nCountFrt	:= 0

For nI := 1 To Len( aCols )
	If !( aCols[nI][Len( aCols[nI] )] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se tem estoque do produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFinalVend
			lEstoque := Lj010Sld( .F., nI, "" )

			If !lEstoque
				nPosProd := AScan( aProdutos, aCols[nI][AScan( aHeader, { |x| Alltrim( x[2] ) == "L2_PRODUTO" } )] )

				If nPosProd == 0
					AAdd( aProdutos, aCols[nI][AScan( aHeader, { |x| Alltrim( x[2] ) == "L2_PRODUTO" } )] )
				Endif
			Endif
		Endif

		If Posicione( "SF4", 1, xFilial( "SF4" ) + aCols[nI][nPosTES], "SF4->F4_ISS" ) <> "S"
			nVlrTotFrt += aCols[nI][nPosVlrItem]
			nCountFrt ++
		Endif
	Endif
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o produto não tenha estoque, nao eh possivel finalizar a venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aProdutos ) > 0
	For nItProd := 1 To Len( aProdutos )
		cProds := cProds + Alltrim( aProdutos[nItProd] ) + If( nItProd <> Len( aProdutos ), " / ", "" )
	Next nItProd

	Aviso( STR0110, STR0111 + cProds, { "Ok" } )// "Saldo Insuficiente", "Não há saldo disponível nos produtos: "

	Return( .F. )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o rateio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( aDespFrete )
	aFill( aDespFrete[nI], 0 )
Next nI

For nI := 1 To Len( aCols )
	If !( aCols[nI][Len( aCols[nI] )] )
		If Posicione( "SF4", 1, xFilial( "SF4" ) + aCols[nI][nPosTES], "SF4->F4_ISS" ) <> "S"
			nPerTotal := aCols[nI][nPosVlrItem] / nVlrTotFrt

			If cPaisLoc == "BRA"
				aDespFrete[nI][1] := NoRound( nPerTotal * M->L1_FRETE, 2 )
				aDespFrete[nI][2] := NoRound( nPerTotal * M->L1_SEGURO, 2 )
				aDespFrete[nI][3] := NoRound( nPerTotal * M->L1_DESPESA, 2 )
			Else                                                          
				aDespFrete[nI][1] := Round( nPerTotal * M->L1_FRETE, nDecimais )
				aDespFrete[nI][2] := Round( nPerTotal * M->L1_SEGURO, nDecimais )
				aDespFrete[nI][3] := Round( nPerTotal * M->L1_DESPESA, nDecimais )
			Endif
		Endif
	Endif
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o arredondamento dos valores do frete, seguro e desp.acessorias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrFrete 	:= 0
nVlrSeguro	:= 0
nVlrDespesa	:= 0

aEval( aDespFrete, { |x| ( nVlrFrete += x[1], nVlrSeguro += x[2], nVlrDespesa += x[3] ) } )

If nCountFrt > 0
	nFrete 		:= Mod( ( M->L1_FRETE - nVlrFrete ), nCountFrt )
	nSeguro 	:= Mod( ( M->L1_SEGURO - nVlrSeguro ), nCountFrt )
	nDespesa 	:= Mod( ( M->L1_DESPESA - nVlrDespesa ), nCountFrt )
	
	aDespFrete[Len( aDespFrete )][1] += nFrete
	aDespFrete[Len( aDespFrete )][2] += nSeguro
	aDespFrete[Len( aDespFrete )][3] += nDespesa
	
	If cPaisLoc == "BRA"
		For nI := 1 To Len( aCols )
			aCols[nI][nPosValFre] 	:= aDespFrete[nI][1]
			aCols[nI][nPosSeguro] 	:= aDespFrete[nI][2]
			aCols[nI][nPosDespesa] 	:= aDespFrete[nI][3]
		Next nI
	Endif
	
	nVlrLiq    -= If( lVlrFSD, M->L1_FRETE + M->L1_DESPESA + M->L1_SEGURO, 0 )
	nValorBase -= If( lVlrFSD, M->L1_FRETE + M->L1_DESPESA + M->L1_SEGURO, 0 )
Endif

nValorBase += ( LJPCCRet() + npValISS )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recalcular total do ICMS - Caso Tenha ³
//³ Digitado cliente de outro estado.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 To Len( aCols )
	If !( aCols[nx][nUsado + 1] )
		For ny := 1 To Len( aHeader )
			If Trim( aHeader[ny][2] ) == "L2_VALICM" .AND. aCols[nx][nPosValIcm] > 0
				nValIcms		:= Lj010Icms( nx, @nDif, NIL, NIL, NIL, aDespFrete )
				aCols[nx][ny] 	:= nValIcms
				nUltIt  		:= If( nValIcms > 0, nx, nUltIt )
				nColIcm 		:= ny
			Endif

			If Trim( aHeader[ny][2] ) == "L2_CF"
				cCfo := aCols[nx][ny]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Venda para outros estados para consumidor final ³
				//³ nao contribuinte, o CFO = 618 e p/prod.Industr. ³
				//³ o CFO = 619 p/prod.nao industrializados conforme³
				//³ AJUSTE SINIEF No.6 de 11/12/1995.				³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				AAdd( aDadosCfo, { "OPERNF", "S" } )
				AAdd( aDadosCfo, { "TPCLIFOR", SA1->A1_TIPO } )
				AAdd( aDadosCfo, { "UFDEST", SA1->A1_EST } )
				AAdd( aDadosCfo, { "INSCR", SA1->A1_INSCR } )

				cCfo := MaFisCfo( NIL, cCfo, aDadosCfo )
				
				aCols[nx][ny] := cCfo
			Endif
		Next ny
	Endif
Next nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem itens que foram deletados no Orcamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len( aCols )
	cX := SomaIt( cX )

	If aCols[nx][nUsado + 1]
		DbSelectArea( "SL2" )
		DbSetOrder( 1 )

		If DbSeek( xFilial( "SL2" ) + cNumOrc + cX )
			Reclock( "SL2" ,.F.,.T. )
			DbDelete()
			MsUnlock()
		Endif
	Endif
Next nX

cX       := "00"
cItenf   := Replicate( "0", TamSX3( "D2_ITEM" )[1] )
nValIcms := 0        

For nX := 1 To Len( aCols )
	If !aTail( aCols[nX] ) .AND. !Empty( aCols[nX][nPosVend] )
		lEmptyVend := .F.

		Exit
	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da transacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN TRANSACTION

	DbSelectArea( "SL1" )
	DbSetOrder(1)

	If DbSeek( cFilial + cNumOrc )
		Reclock( "SL1" )
	Else
		Reclock( "SL1", .T. )
	End

	SL1->L1_FILIAL := cFilial
	SL1->L1_NUM    := cNumOrc
	
	MsUnlock()
	SL1->( FkCommit() )
	
	For nX := 1 To Len( aCols )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ignora os deletados. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cX := SomaIt( cX )

		If aCols[nX][nUsado + 1]
			Loop
		Endif
		
		For ny := 1 To Len( aHeader )
			cVar := Trim( aHeader[ny][2] )
			
			If Trim( aHeader[ny][2] ) == "L2_PRODUTO"
				cProduto := aCols[nx][ny]
			Endif

			If Trim( aHeader[ny][2] ) == "L2_VALICM"
				nValIcms += aCols[nx][ny]
			Endif

			If Trim( aHeader[ny][2] ) == "L2_VALISS"
				nValIss += aCols[nx][ny]
			Endif

			If Trim( aHeader[ny][2] ) == "L2_VALIPI"
				nValIpi += aCols[nx][ny]
			Endif

			If Trim( aHeader[ny][2] ) == "L2_BASEICM"
				nBaseIcm += aCols[nx][ny]
			Endif

			If Trim( aHeader[ny][2] ) == "L2_TABELA"
				cTabela := aCols[nx][ny]
			Endif
		Next ny
		
		If !Empty( cProduto )
			DbSelectArea( "SL2" )
			DbSetOrder( 1 )

			DbSeek( xFilial( "SL2" ) + cNumOrc + cX )

			Reclock( "SL2", !Found ( ) )  // Grava SL2

			For ny := 1 To Len( aHeader )
				cVar := Trim( aHeader[ny][2] )

				Replace &cVar. With aCols[nx][ny]
			Next ny
	
			If lEmptyVend
				SL2->L2_VEND := cVendLoja
			Else                       
				If lFirst
					cVendAnt := aCols[nX][nPosVend]
				Endif
				                
				If !lDifVend
					For nY := 1 To Len( aCols )
						If 	!aTail( aCols[nY] ) .AND. !Empty( aCols[nY][nPosVend] ) .AND.;
							( aCols[nY][nPosVend] <> cVendAnt .OR. ( aCols[nY][nPosVend] == cVendAnt .AND. lFirst ) )

							lDifVend := .T.

							Exit
						Endif
					Next nY
				Endif

				If lFirst
					lFirst := .F.		
				Endif
			Endif                   
			
			If !lDifVend
				SL2->L2_VEND := If( SuperGetMv( "MV_LJMOD3" ), M->L1_VEND, cVendLoja )
			Else
				SL2->L2_VEND := If( Empty( aCols[nX][nPosVend] ) .OR. aCols[nX][nPosVend] == SL1->L1_VEND, If( SuperGetMv( "MV_LJMOD3" ), M->L1_VEND, cVendLoja ), aCols[nX][nPosVend] )
			Endif   
	
			SL2->L2_LOCAL	:= aCols[nX][nPosLoc]

			nItem++

			SL2->L2_FILIAL	:= cFilial
			SL2->L2_NUM		:= cNumOrc
			cIteNF			:= SomaIt( cIteNf )
			SL2->L2_ITEM	:= cItenf
			SL2->L2_EMISSAO	:= dDataBase

			//ÚÄÄÄÄÄ¿
			//³GRADE³
			//ÀÄÄÄÄÄÙ
			If !__lPyme
				SL2->L2_GRADE := "N"
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existem os campso do frete para guardas as informacoes ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lFiscal
				SL2->L2_VALFRE 	:= aDespFrete[nX][1]
				SL2->L2_SEGURO 	:= aDespFrete[nX][2]
				SL2->L2_DESPESA	:= aDespFrete[nX][3]
			Endif
			
			If cPaisLoc <> "BRA"
				If lFiscal
					SL2->L2_PDV := SuperGetMv( "MV_NUMPDV" )
				Endif

				If nX <= Len( aImps )
					For nY := 1 To Len( aImps[nX][6] )
						nPosCpo := FieldPos( "L2_ALQIMP" + Subst( aImps[nX][6][nY][7], 10, 1 ) )
						FieldPut( nPosCpo, aImps[nX][6][nY][2] ) //Valor Aliquota

						nPosCpo := FieldPos( Alltrim( aImps[nX][6][nY][6] ) )
						FieldPut( nPosCpo, aImps[nX][6][nY][4] ) //Valor BASE

						nPosCpo := FieldPos( Alltrim( aImps[nX][6][nY][7] ) )
						FieldPut( nPosCpo, aImps[nX][6][nY][3] ) //Valor imposto
					Next nY
				Endif
			Endif

			MsUnlock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se ha reservas ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( aCols[nX][nPosReserva] )
				lReserva := .T.
			Endif
		Endif
	Next nx
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravando na configuracao se imprimiu NF ou Cupom Fiscal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cConfVenda := Subs( cConfVenda, 1, 7 ) + If( nCheck == 1, "S", "N" ) + If( nCheck == 2, "S", "N" )+;
	Subs( cConfVenda, 10, 3 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Em caso de desconto financeiro eh necessario somar o valor do mesmo ao valor dado³
	//³no desconto no total da venda, pois o desconto financeiro altera o valor do      ³
	//³item e forca o recalculo dos impostos - Localizacoes.                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SL1" )
	Reclock( "SL1" )

	Replace L1_VEND   	With cVendLoja		,;
			L1_CLIENTE 	With cCliente		,;
			L1_VLRTOT  	With Round( nValorBase + ( nNccUsada - nNccGerada), nRndFat ),;
			L1_DESCONT 	With Round( If( cPaisLoc <> "BRA", nDescloj + aDadosJur[9], nVlrDesc ), nRndFat ),; //Valor do desconto total
			L1_VLRLIQ  	With Round( ( ( nVlrliq + nDescLoj ) - nVlrDesc ) + ( nNccUsada - nNccGerada ), nRndFat ),; //Valor Liquido = Valor liquido + Valor do Desconto Manual - Valor do Desconto Total
			L1_LOJA     With cLoja			,;
			L1_DTLIM   	With dDtlim			,;
			L1_VALICM   With nValIcms		,;
			L1_VALISS  	With nValIss		,;
			L1_VALIPI   With nValIpi		,;
			L1_VEND2   	With SA3->A3_SUPER	,;
			L1_VEND3    With SA3->A3_GEREN	,;
			L1_COMIS   	With SA3->A3_COMIS	,;
			L1_DESCNF   With nDescPer + If( cPaisLoc <> "BRA", nTxDescon, 0 ),;
			L1_CONFVEN 	With cConfVenda		,;
			L1_IMPRIME 	With Str( nCheck, 1 ) + If( lCheck3, "S", "N" ),;
			L1_NROPCLI 	With cNroPCli		,;
			L1_RESERVA 	With If( lReserva, "S", "" ),;
			L1_CLIENT   With cCliEntrega	,;
			L1_LOJENT   With cLojEntrega
	
	If cLJDTORC == "S" .OR. lLJDTOrc
		Replace L1_EMISSAO With dDataBase
	Else                                                                     
		Replace L1_EMISSAO With If( Empty( L1_EMISSAO ), dDataBase, L1_EMISSAO )
	Endif
	
	Replace L1_BLCRED With If( ValType( cBlCred ) = "U", "", cBlCred )
	
	If nValorBase == 0
		If lTroca
			Replace L1_VLRTOT With Round( nCredito - nNccGerada + nNccUsada, nRndFat )
			Replace L1_VLRLIQ With Round( nCredito - nNccGerada + nNccUsada, nRndFat )
		Else
			Replace L1_VLRTOT With Round( ( nNccUsada - nNccGerada ) + L1_DESCONT, nRndFat )
			Replace L1_VLRLIQ With Round( ( nNccUsada - nNccGerada ), nRndFat)
		Endif
	Endif
	
	If lFinalVend
		If lTroca
			Replace L1_CREDITO With Round( nCredito - nNccGerada + nNccUsada, nRndFat )
		Else
			nCredLj := nNccUsada - nNccGerada

			Lj010RetPos( @nCredLj )

			Replace L1_CREDITO With Round( nCredLj, nRndFat )
		Endif
	Endif
	
	SA1->( DbSetOrder( 1 ) )
	SA1->( DbSeek( xFilial( "SA1" ) + cCliente + cLoja ) )
	
	Replace L1_TIPOCLI With SA1->A1_TIPO
	
	If cPaisLoc <> "BRA"
		Replace L1_HORA    With Time()
		Replace L1_MOEDA   With nMoedaCor
		Replace L1_TXMOEDA With nTaxaMoeda
		
		nValItens := nVlrLiq + Lj010VlrFSD() - nValTotIV
		
		For nC := 1 To Len( aImpVarSF2 )
			nPosCpo := SL1->( FieldPos( aImpVarSF2[nC][1] ) )

			SL1->( FieldPut( nPosCpo, 0 ) )
		Next nC
		
		For nC := 1 To Len( aImpVarSF2 )
			nPosCpo := SL1->( FieldPos( aImpVarSF2[nC][1] ) )

			SL1->( FieldPut( nPosCpo, aImpVarSF2[nC][2] + FieldGet( nPosCpo ) ) )
		Next nC                       
		
		For nC := 1 To Len( aMoedas )
			nPosCpo := SL1->( FieldPos( "L1_TROCO" + Alltrim( STR( nC ) ) ) )

			If ( nPosCpo > 0 ) .AND. ( ( nPos := AScan( aMoedas, { |x| x[6] == nC } ) ) > 0 )
				SL1->( FieldPut( nPosCpo, aMoedas[nPos][3] ) )
			Endif
		Next nC
	Endif
	
	Replace L1_ESTACAO With cEstacao
	                      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³So grava o Autor do Desconto se o valor do Desconto³
	//³for maior que zero.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If L1_DESCONT > 0
		Replace L1_LOGDESC With cAutorDesc
	Else
	   L1_LOGDESC:= ""
	Endif
	
	If GetMv( "MV_LJMOD3" )
		For nCntFor := 1 To Len( aCpoEnchoice )
			If Eval( bCampo, aCpoEnchoice[nCntFor] ) > 0
				FieldPut( Eval( bCampo, aCpoEnchoice[nCntFor] ), M->&( aCpoEnchoice[nCntFor] ) )
			Endif
		Next nCntFor
	Endif

	DbCommitAll()
	MsUnlock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao dos dados do frete³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj010GRFT()

	nRegAnt := RecNo()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se houve desconto geral na NF  e proporcionaliza nos itens.          ³
	//³                                                                              ³
	//³Devido a dificuldade de chegar nas conclusoes abaixo e tambem                 ³
	//³devido ao fato de que a codificacao abaixo envolve muitos cenarios,           ³
	//³foram incluidos um numero muito grande de comentarios para facilitar          ³
	//³futuras alteracoes e impedir que alguem altere indevidamente as regras abaixo.³
	//³Autor: Edney Souza - 1402 - 23/03/2001                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nItensRT := 0
	nPRT     := 0
	
	DbSelectArea( "SL2" )
	DbSetOrder( 1 )

	DbSeek( xFilial( "SL2" ) + cNumOrc )

	nRegis   := Recno()
	nPrimRec := nRegis
	
	SL2->( DBEval( { || 	If( Posicione( "SF4", 1, xFilial( "SF4" ) + SL2->L2_TES, "SF4->F4_ISS" ) == "S" .AND. LjAnalisaLeg( 8 )[1],;
							nPRT += If( SL1->L1_DESCONT > 0, NoRound( ( SL1->L1_DESCONT * ( ( L2_VLRITEM + L2_VALIPI ) / ( SL1->L1_VLRTOT + If( lTroca, SL1->L1_CREDITO, 0 ) ) ) ), nTamL2_DES ), 0 ),;
							nItensRT++ ) }, NIL,;
							{ || L2_FILIAL == xFilial( "SL2" ) .AND. L2_NUM == SL1->L1_NUM .AND. ! EOF() }, NIL, NIL, .T. ) )
	
	If nPRT > 0 .AND. nItensRT > 0
		nPRT := NoRound( ( nPRT / nItensRT ), nTamL2_DES )
	Else
		nPRT := 0
	Endif
	
	SL2->( DbGoto( nRegis ) )
	
	While SL2->L2_FILIAL == xFilial( "SL2" ) .AND. SL2->L2_NUM == SL1->L1_NUM .AND. !SL2->( EOF() )
		Reclock( "SL2", .F. )
		
		If cPaisLoc == "BRA"                                                                   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o item for serviço, em alguns estados não pode ser rateado o desconto no item.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !( Posicione( "SF4", 1, xFilial( "SF4" ) + SL2->L2_TES, "SF4->F4_ISS" ) == "S" .AND. LjAnalisaLeg( 8 )[1] )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tem de ser NoRound                                                        ³
				//³Se for Round pode ocorrer da soma do L2_DESCPRO ser maior que o L1_DESCONT³
				//³Se for menor nao tem problema pois ha' um ajuste abaixo.                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo do desconto quando utiliza-se somente o desconto³
				//³no total                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nDescLoj > 0 .AND. nDescPer > 0 .AND. SL1->L1_DESCONT > 0 .AND. SE4->E4_DESCFIN == 0
					SL2->L2_DESCPRO := NoRound( SL1->L1_DESCONT * ( ( SL2->L2_VLRITEM + SL2->L2_VALIPI ) / ( SL1->L1_VLRTOT + SL1->L1_DESCONT + If( lTroca, SL1->L1_CREDITO, 0 ) ) ), nTamL2_DES )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo do desconto quando utiliza-se o desconto no SE4 ³
				//³e no total                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf nDescLoj > 0 .AND. nDescPer > 0 .AND. SL1->L1_DESCONT > 0 .AND. SE4->E4_DESCFIN <> 0
					SL2->L2_DESCPRO := NoRound( SL1->L1_DESCONT * ( ( SL2->L2_VLRITEM + SL2->L2_VALIPI ) / ( (SL1->L1_VLRTOT * ( 1 - (SE4->E4_DESCFIN / 100) ) ) + SL1->L1_DESCONT + If( lTroca, SL1->L1_CREDITO, 0 ) ) ), nTamL2_DES )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo do desconto quando utiliza-se somente o desconto³
				//³no SE4                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf (nDescLoj == 0 .AND. nDescPer == 0) .AND. SL1->L1_DESCONT > 0
					SL2->L2_DESCPRO := NoRound( SL1->L1_DESCONT * ( ( SL2->L2_VLRITEM + SL2->L2_VALIPI ) /  (SL1->L1_VLRTOT + If( lTroca, SL1->L1_CREDITO, 0 ) ) ), nTamL2_DES )
				Else
					SL2->L2_DESCPRO := 0
				Endif

				SL2->L2_DESCPRO += nPRT
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo do desconto quando utiliza-se somente o desconto³
			//³no total                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SL2->L2_DESCPRO := If( SL1->L1_DESCONT > 0, Round( SL1->L1_DESCONT * ( SL2->L2_VLRITEM / ( nValItens + SL1->L1_DESCONT + If( lTroca, SL1->L1_CREDITO, 0 ) ) ), nRndFat ), 0 )
		Endif

		nValMercParc+= SL2->L2_VLRITEM
		nValMerc 	+= SL2->L2_VLRITEM

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Subtrai do Valor Total dos itens (VlrUnit*Qtd)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL2->L2_DESCPRO > 0
			SL2->L2_VLRITEM -= SL2->L2_DESCPRO

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O Valor da mercadoria é sem o desconto do L2_DESCPRO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SuperGetMV( "MV_ARREFAT" ) == "S"
				SL2->L2_VRUNIT := Max( Round( SL2->L2_VLRITEM / SL2->L2_QUANT, nRndItem ), 1 / ( 10 ^ nRndItem ) )
			Else
				SL2->L2_VRUNIT := Max( NoRound( SL2->L2_VLRITEM / SL2->L2_QUANT, nRndItem ), 1 / ( 10 ^ nRndItem ) )
			Endif
			
			If cPaisLoc <> "BRA"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Permitir o tratamento de valores negativos para os casos de adiantamento(Localizacoes)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SL2->L2_VLRITEM < 0
					SL2->L2_VRUNIT := SL2->L2_VRUNIT * ( -1 )
				Endif
			Endif
			
			If GetMv( "MV_ARREFAT" ) == "S"
				nVlrItem := Round( SL2->L2_VRUNIT * SL2->L2_QUANT, nRndFat )
			Else
				nVlrItem := NoRound( SL2->L2_VRUNIT * SL2->L2_QUANT, nRndFat )
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se houver diferenca entre o Unitario*Qtd e o Total do item                                ³
			//³Se a diferenca for menor pode ser devido ao NoRound cortar casas decimais:                ³
			//³1) O usuario pode alterar o MV_ARREFAT par "S"                                            ³
			//³2) Ou aumentar a configuracao de casas decimais para esta moeda (MsDecimais).             ³
			//³Se a diferenca for maior e porque:                                                        ³
			//³1) O unitario ajustado ficaria menor que 1 centavo, entao foi mantido em um centavo (Max).³
			//³2) O arredondamento no Unitario gerou a diferenca no Total.                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nVlrItem > SL2->L2_VLRITEM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Subtrai a diferenca do Desconto proporcional³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SL2->L2_DESCPRO -= ( nVlrItem - SL2->L2_VLRITEM )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Acerta o Total do Item³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SL2->L2_VLRITEM := nVlrItem
			ElseIf nVlrItem < SL2->L2_VLRITEM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Soma a diferenca do Desconto proporcional³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SL2->L2_DESCPRO += ( SL2->L2_VLRITEM - nVlrItem )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Acerta o Total do Item³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SL2->L2_VLRITEM := nVlrItem
			Endif
		Endif                      

		If cPaisLoc <> "BRA"
			nValMercAux +=	SL2->L2_VLRITEM
		Endif

		MsUnlock()
		DbSkip()

		nCont++
	End

	DbGoto( nRegis )

	nDesct := 0

	While SL2->L2_FILIAL == xFilial( "SL2" ) .AND. SL2->L2_NUM == SL1->L1_NUM .AND. !EOF()
		nDesct += SL2->L2_DESCPRO

		DbSkip()
	End
	
	nDif := SL1->L1_DESCONT - nDesct
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aplica a diferenca de modo que cada item nao fique menor que 0.01³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbGoto( nPrimRec )

	While !( nDif == 0 ) .AND. SL2->L2_FILIAL == xFilial( "SL2" ) .AND. SL2->L2_NUM == SL1->L1_NUM .AND. !EOF()
		If cPaisLoc <> "BRA"
			nValMercAux -=	SL2->L2_VLRITEM
		Endif

		Reclock( "SL2", .F. )

		If NoRound( ( SL2->L2_VLRITEM - nDif ) / SL2->L2_QUANT, nRndFat ) < ( 1 / ( 10 ** nRndFat ) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o valor do item e' pequeno faz o ajuste deixando 1 centavo no VrUnit³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SL2->L2_VRUNIT := ( 1 / ( 10 ** nRndItem ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Subtrai da variavel somente a diferenca que sera ajustada aqui.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDif -= ( SL2->L2_VLRITEM - ( L2_VRUNIT * L2_QUANT ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona ao desconto proporcional a diferenca que foi utilizada aqui.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SL2->L2_DESCPRO += ( SL2->L2_VLRITEM - ( SL2->L2_VRUNIT * SL2->L2_QUANT ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recalcula o valor total do item de acordo com o VrUnit*Qtd³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SL2->L2_VLRITEM := ( SL2->L2_VRUNIT * SL2->L2_QUANT )
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o valor do item permite entao faz o ajuste total                    ³
			//³Soma a diferenca no desconto desse item porque o ajuste sera feito aqui³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SL2->L2_DESCPRO += nDif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se aumentou o desconto entao diminui o valor do item na mesma proporcao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SL2->L2_VLRITEM -= nDif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recalcula o valor unitario do item de acordo com o VrTotItem/Qtd³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SL2->L2_VRUNIT := NoRound( SL2->L2_VLRITEM / SL2->L2_QUANT, nRndItem )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Como toda a diferenca foi utilizada entao zera a variavel para sair do laco (while)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDif := 0
		Endif

		MsUnlock()

		If cPaisLoc <> "BRA"
			nValMercAux += SL2->L2_VLRITEM
		Endif

		DbSkip()
	End
	
	If cPaisLoc <> "BRA"
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Ajustar os impostos apos o arredondamento dos itens feito acima    ³
	    //³Para Paraguai, os impostos ja estao acertados, considerando que nao³    
	    //³tem casas decimais                                                 ³        
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If SL1->L1_DESCONT > 0 .AND. cPaisLoc <> "PAR"  
	       Lj010AjImps( nRegis, nValMercAux, nDescLoj )
	    Endif

		SL1->( RecLock( "SL1", .F. ) )

		SL1->L1_VLRTOT   := nValMercAux + nValTotIV 
		SL1->L1_VALBRUT  := SL1->L1_VLRTOT
		SL1->L1_VALMERC  := nValMercAux 
		SL1->L1_VLRLIQ   := SL1->L1_VALMERC

		SL1->( MsUnlock() )
	Else
		SL1->( RecLock( "SL1", .F. ) )

		SL1->L1_VALMERC	 := nValMerc
		SL1->L1_VALBRUT	 := SL1->L1_VLRTOT

		SL1->( MsUnlock() )
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se apos varrer todos os itens ainda sobrar diferenca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! nDif == 0
		RecLock( "SL1", .F. )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajusta o desconto no total em valor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SL1->L1_DESCONT -= nDif
		nDescLoj 		:= SL1->L1_DESCONT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajusta o valor liquido em funcao do ajuste no desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SL1->L1_VLRLIQ += nDif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajusta o valor da mercadoria em funcao do ajuste no desconto (Bruno)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SL1->L1_VALMERC	+= nDif
		nVlrLiq 		+= nDif
		nLiq 			+= nDif
		nValorBase 		+= nDif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula o Percentual de desconto no total³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SuperGetMV( "MV_ARREFAT" ) == "S"
			SL1->L1_DESCNF := Round( ( SL1->L1_DESCONT / SL1->L1_VLRTOT ) * 100, nTamL1_DNF )
		Else
			SL1->L1_DESCNF := NoRound( ( SL1->L1_DESCONT / SL1->L1_VLRTOT ) * 100, nTamL1_DNF )
		Endif

		nDescPer := SL1->L1_DESCNF

		MsUnlock()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fim dos ajustes de desconto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recalcula os tributos caso tenha desconto no item ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SL1->L1_DESCONT > 0 .OR. SL1->L1_DESCNF > 0 ) .AND. cPaisLoc == "BRA"
		LjRecalTrib( 	"DESCONTO"	, .F.	, cNumOrc 	, NIL,;
						NIL			, NIL	, nValorBase, If( lTroca, nLiq, ( nVlrliq + nDescLoj ) - nVlrDesc ) ) //Valor Liquido = Valor Liquido + Desconto Manual - Valor do Desconto Total
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se todos itens foram deletados. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SL2" )
	DbSetOrder( 1 )
	If !( DbSeek( xFilial( "SL2" ) + cNumOrc ) )
		Reclock( "SL1", .F., .T. )
		DbDelete()
		MsUnlock()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utiliza as funcoes fiscais para gravar os valores de PIS/COFINS/CSLL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SL1" )
	If FieldPos( "L1_VALPIS" ) > 0 .AND. FieldPos( "L1_VALCOFI" ) > 0 .AND. FieldPos( "L1_VALCSLL" ) > 0
		
		MaFisIni( 	SA1->A1_COD	, SA1->A1_LOJA	, "C"	, "S"	,;
					SA1->A1_TIPO, NIL			, NIL	, .F.	,;
					"SB1" )

		SB1->( DbSetOrder( 1 ) )
		SF4->( DbSetOrder( 1 ) )
	
		DbSelectArea( "SL2" )
		DbSetOrder( 1 )

		DbSeek( xFilial( "SL2" ) + SL1->L1_NUM )
			
		nX := 0

		Do While !EOF() .AND. xFilial( "SL2" ) + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM
			nX += 1

			SB1->( DbSeek( xFilial( "SB1" ) + SL2->L2_PRODUTO ) )
			SF4->( DbSeek( xFilial( "SF4" ) + SL2->L2_TES ) )
				
			MaFisAdd(	SB1->B1_COD		, SF4->F4_CODIGO	, SL2->L2_QUANT	, SL2->L2_VRUNIT	,;
						0				, ""				, ""			, NIL				,;
						0				, 0					, 0				, 0					,;
						SL2->L2_VLRITEM	, 0					, SB1->( RecNo() ) )
				       
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso exista os campos no Itens do orcamento, gravo seus respectivos valores³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock( "SL2", .F. )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava valores para Retencao de PIS/COFINS/CSLL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If 	( FieldPos( "L2_VALPIS" )>0 .AND. FieldPos( "L2_VALCOFI" )>0 .AND.FieldPos( "L2_VALCSLL" )>0 ) .AND.;
			    (SA1->A1_RECPIS  == "S" .OR. SA1->A1_RECCOFI == "S" .OR. SA1->A1_RECCSLL == "S")
				Replace SL2->L2_VALPIS  With MaFisRet( nX, "IT_VALPIS" ) //Valor de Retencao do PIS
				Replace SL2->L2_VALCOFI With MaFisRet( nX, "IT_VALCOF" ) //Valor de Retencao do COFINS
				Replace SL2->L2_VALCSLL With MaFisRet( nX, "IT_VALCSL" ) //Valor de Retencao do CSLL
			Endif								
				                                                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava valores para Apuracao de PIS/COFINS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If FieldPos( "L2_VALPS2"  ) > 0 .AND. FieldPos( "L2_VALCF2"  ) > 0 .AND.;
				   FieldPos( "L2_BASEPS2" ) > 0 .AND. FieldPos( "L2_BASECF2" ) > 0 .AND.;
				   FieldPos( "L2_ALIQPS2" ) > 0 .AND. FieldPos( "L2_ALIQCF2" ) > 0 
					
					Replace SL2->L2_BASEPS2 With MaFisRet( nX, "IT_BASEPS2" ) //Base de Apuracao do PIS
					Replace SL2->L2_VALPS2  With MaFisRet( nX, "IT_VALPS2" )  //Valor de Apuracao do PIS
					Replace SL2->L2_ALIQPS2 With MaFisRet( nX, "IT_ALIQPS2" )  //Aliquota de Apuracao do PIS
					
					Replace SL2->L2_BASECF2 With MaFisRet( nX, "IT_BASECF2" ) //Base de Apuracao do COFINS
					Replace SL2->L2_VALCF2  With MaFisRet( nX, "IT_VALCF2" )  //Valor de Apuracao do COFINS
					Replace SL2->L2_ALIQCF2 With MaFisRet( nX, "IT_ALIQCF2" )  //Aliquota de Apuracao do COFINS
					
				Endif

				MsUnlock()
			
				DbSelectArea( "SL2" )
				DbSkip()
			End
			
			RecLock( "SL1", .F. )

			Replace SL1->L1_VALPIS  With If( LJPCCRet( 1 ) > 0, LJPCCRet( 1 ), MaFisRet( NIL,"NF_VALPIS" ) )
			Replace SL1->L1_VALCOFI With If( LJPCCRet( 2 ) > 0, LJPCCRet( 2 ), MaFisRet( NIL,"NF_VALCOF" ) )
			Replace SL1->L1_VALCSLL With If( LJPCCRet( 3 ) > 0, LJPCCRet( 3 ), MaFisRet( NIL,"NF_VALCSL" ) )
			                                    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se existir o campo L1_ABTOPCC (onde é gravado o valor de abatimento de PIS/COFINS/CSLL)³
			//³grava o valor abatido do total da venda.                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SL1->( FieldPos( "L1_ABTOPCC" ) ) > 0
				Replace SL1->L1_ABTOPCC With LJPCCRET()
			Endif
			
			MsUnlock()
			MaFisEnd()
	
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetuar o calculo do IRRF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( cPaisLoc == "BRA" ) .AND. !Empty( SA1->A1_NATUREZ )
		DbSelectArea( "SED" )
		DbSetOrder( 1 )

		If DbSeek( xFilial( "SED" ) + SA1->A1_NATUREZ )
			If SED->ED_CALCIRF == "S"
				DbSelectArea( "SL1" )
				If SL1->( FieldPos( "L1_VALIRRF" ) ) > 0
					RecLock( "SL1", .F. )

					Replace SL1->L1_VALIRRF With NoRound( SL1->L1_VALBRUT * ( If( SED->ED_PERCIRF > 0, SED->ED_PERCIRF, SuperGetMV( "MV_ALIQIRF" ) ) / 100 ), 2 )

					MsUnlock()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica primeiro o ED_PERCIRF (perc. de IRRF), caso este nao exista verifica o param. MV_ALIQIRF³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Endif
			Endif
		Endif	
	Endif
	
	DbSelectArea( "SL1" )
	For nI := 1 To Len( aFields )
		&( "M->" + aFields[nI] ) := FieldGet( FieldPos( aFields[nI] ) )
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSaci001T
		ExecTemplate( "SACI001", .F., .F., { lFinalVend } )
	Endif

	If lSaci001
		ExecBlock( "SACI001", .F., .F., { lFinalVend } )
	Endif
	
END TRANSACTION

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010CbPag³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Combo-Box com as opcoes de pagamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Lj010CbPag()                               	          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Array com as condicoes cadastradas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010CbPag(aCondicoes)

aCondicoes := Lj010CondP(aCondicoes)
If !(cPaisLoc $ "EUA|POR") .OR. !lLayAway
	AAdd(aCondicoes, ("CN " + " - " + STR0082))  //"Condicao Negociada"
Endif
Return aCondicoes


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Quan ³ Autor ³ Vendas Clientes       ³ Data ³26/04/99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza campo de % de desconto na digitacao da quantidade  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Lj010Quan()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³obs.: Retorna o percentual de desconto com a nova quantidade³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Quan()
Local lRet      := .T.
Local nDesc     := 0
Local nPosPDesc := AScan(aHeader,{|x| Trim(x[2]) == "L2_DESC"})
Local nPosDesc  := AScan(aHeader,{|x| Trim(x[2]) == "L2_VALDESC"})
Local nPosQuant := AScan(aHeader,{|x| Trim(x[2]) == "L2_QUANT"})
Local nPosUnit  := AScan(aHeader,{|x| Trim(x[2]) == "L2_VRUNIT"})
Local nPosPreco := AScan(aHeader,{|x| Trim(x[2]) == "L2_PRCTAB"})
Local aAreaX3   := SX3->( GetArea() )
Local aArea     := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa os gatilhos do L2_QUANT para recalcular os campos. Nao executa ³
//³quando for concomitante.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lVendConc") == "L" .AND. !lVendConc
	DbSelectArea( "SX3" )
	DbSetOrder( 2 )
	DbSeek( "L2_DESC   ")
	If ExistTrigger("L2_DESC")
		M->L2_DESC := aCols[n][nPosPDesc]
		RunTrigger(2,n)
		oGet:oBrowse:DrawSelect()
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não encontramos a finalidade desta alteração efetuada para BRTelecom                  ³
//³deixaremos comentado por estar provocando problemas qdo nao se utiliza a concomitancia³
//³todas as vz que alteramos a qtde o sistema zera o preço                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If Type("lVendConc") == "L" .AND. !lVendConc
	aCols[n][nPosUnit] := 0
Endif
*/

If aCols[n][nPosDesc]<=0 .OR. aCols[n][nPosQuant]<=0 .OR. aCols[n][nPosUnit]<=0
	lRet := .F.
Endif

If lRet .AND. Type("lVendConc") == "L" .AND. !lVendConc
	nDesc:=NoRound((aCols[n][nPosDesc]*100)/((aCols[n][nPosQuant]*;
	aCols[n][nPosUnit])+aCols[n][nPosDesc]),2)
Endif

If lUsaDisplay
	MsgDisplay(5, {SB1->B1_COD, SB1->B1_CODBAR, SB1->B1_DESC, aCols[n][nPosQuant],  aCols[n][nPosPreco],nDesc, ""})
Endif
                     
If Len(aAreaX3) > 0
	RestArea(aAreaX3)
Endif	
If Len(aArea) > 0
	RestArea(aArea)
Endif	

Return nDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Dados³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualizacao de arquivos.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Lj010Dados( )                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Dados(nEntrada	,	nFinanciado	,	nDescloj	,	cForma		, ;
					nValorBase	,	nCheck		,	lUsouFator	,	cNumOrc		, ;
					nTxDescon	,	nDescPer	,	nLiq		,		nTroco	, ;
					cCombo		,	cTipoDocCF	,	cNumDocCF	,	cClienteCF	, ;
					cEnderCF	,	cCodEnd		,	cCliente	,	cLoja		, ;
					cLjArq		,	aCloaCols	,	nHandle		,	cTipoCI)

Local j				:= 0
Local nI 			:= 0
Local cc 			:= 0
Local co 			:= 0
Local va 			:= 0
Local nFi			:= 0					// Variavel utilizada para controlar o numero da Parcela de Financiamento.
Local nMaxItens		:= 0
Local nValor		:= 0
Local nValorCheque	:= 0
Local nValorOut		:= 0
Local nBsIcmRetF2 	:= 0
Local nVlIcmRetF2 	:= 0
Local nSmIcmRetF2 	:= 0
Local nVlmF2		:= 0
Local nBsISSF2 		:= 0
Local nISSF2		:= 0
Local nDescF2		:= 0
Local dVenctoOut	:= 0
Local nIcmF2		:= 0
Local nBsIcmF2 		:= 0
Local nIPIF2		:= 0
Local nBsIPIF2 		:= 0
Local nDinheiro		:= 0
Local nValorCred 	:= 0
Local cDocCred 		:= ""
Local cDocNCC  		:= ""
Local nRecnoSE1 	:= 0
Local nValorConv	:= 0
Local nValorCart	:= 0
Local cAdmCar  		:= Space(3)
Local nValorFin		:= 0
Local nValorVale	:= 0
Local nOutros		:= 0
Local nValorDebi	:= 0
Local nTotTaxa 		:= 0
Local nCheques 		:= 0
Local cNatureza		:= " "
Local cTelefone		:= CriaVar("A1_TEL")
Local cRG			:= CriaVar("A1_RG")
Local cFirst, nItens:= 0
Local aCusto		:= {}
Local aCM			:= {}
Local lFirst		:= .T.
Local lEntrou		:= .F.		  // Quando multiplas notas s¢ pergunta uma vez se Imprime o CP fiscal
Local lImpCupFis	:= .F.		  // Se .T. Imprimir  o Cupom na Impressora fiscal
Local lVaBe001T		:= ExistTemplate("VABE001") 
Local lVaBe001 		:= ExistBlock("VABE001")
Local i
Local cIteNf		:= Repl("0",TamSX3("D2_ITEM")[1])
Local dSaeDias
Local dSaeVencto
Local dDataVencto
Local cTes
Local cMoeda
Local cBanco
Local cAgencia
Local cConta
Local cNumCheque
Local cComp
Local lSaida		:= .T.
Local cCodCliFin
Local cCliFin
Local lGravar		:= .T. //Criada  para ajudar no controle da Sweda Ifs7000
Local lFaturar 		:=.T.
Local lFinanceiro 	:=.T.
Local aVendedor		:= {}
Local nVend
Local nQParcela		:= 0
Local lLj10D2		:= ExistBlock("LJ10D2")
Local lLj10Ser 		:= ExistBlock("LJ10SER")
Local aRegSE1     	:= {}
Local nX, nY, nE, nC         // Localizacoes 19/05/2000
Local aIcmsSol 		:= {}
Local aLivro 		:= {}  //Localizacoes 19/05/2000
Local aGetBook
Local aCaixaFin     := {}
Local aTmpRegSE1    := {}
Local nMoedaBco 	:= 1  // Localizacoes 20/09/2000
Local nRndFat 		:= MsDecimais(nMoedaCor)
Local nRndMoed1 	:= MsDecimais(1)
Local nRndBco 		:= 1
Local nDecs
Local lCxEstrang 	:= .F.
Local cVinculado 	:= '0'
Local nRegCli
Local nPerJur    	:= SuperGetMv("MV_TXPER")
Local aGrvPar 		:= {}
Local aStruSL2
Local nImpIncNota   := 0
Local lResMLoja     := .T.                   //Variavel que indica reserva da mesma loja
Local lResOLoja     := .T.                   //Variavel que indica reserva de outra loja
Local cFilReserv    := ""                    //Filial utilizada no sistema
Local cFilAntBk     := ""                    //Backup do cFilAnt
Local cReserva      := ""                    //Codigo da Reserva
Local nItensVenda 	:= 0
Local aNotas 		:= {}
Local nQtdNotas		:= 0
Local nNotaAtu		:= 0
Local c1DUP         := SuperGetMv("MV_1DUP")
Local nValorDup
Local nTaxaAcFin	:= 0	// Taxa de limite de acrescimo financeiro
Local nVlrAcProp	:= 0	// Valor do acrescimo do item proporcional ao total
Local nVlrAcItem	:= 0	// Valor do acrescimo do item com a taxa de limite de acrescimo financeiro
Local nEntItem		:= 0	// Valor da entrada proporcional ao item
Local cLojaNF       := Alltrim(SuperGetMv("MV_LOJANF"))
Local nValMerc		:= 0
Local nPosValMerc	:= AScan( aHeader, {|x| Alltrim(Upper(x[2])) == "L2_VLRITEM" } )
Local nVlrIcmFre	:= 0
Local cAgenciaCx    := "."
Local cContaCx      := "."
Local cAliasNF		:= ""
Local cNumAnt       := Space(TamSX3("L1_DOC")[1])
Local lExiste       := .T.
Local nAltera       := SuperGetMv("MV_ALTNUM",,1)
Local nPosLay       := AScan(aHeader,{|x| Alltrim(x[2]) == "L2_NUMLAY"})
Local nPosItLw      := AScan(aHeader,{|x| Alltrim(x[2]) == "L2_ITEMLAY"})
Local nRecnoSL2     := 0
Local nModoPrint    := 1
Local cTipCliEntr   := "" //Tipo do CLiente entrega/normal
Local nVlrFreNota   := 0  //Valor do frete por nota fiscal gerada
Local nVlrSegNota   := 0  //Valor do seguro por nota fiscal gerada
Local nVlrDesNota   := 0  //Valor da despesa por nota fiscal gerada
Local lEmpenho      := .F. //Verifica se houve empenho
local nSize         := 0   // GRAVACAO DO LOG TEF
local cRBuffer      := ""  // GRAVACAO DO LOG TEF
Local lLog1       	:= Subs(LJGetProfile("LOGERRO"),1,1) == "S" // Tem Log de Erro
Local lLog4         := Subs(LJGetProfile("LOGERRO"),4,1) == "S" // Log de Recuperacao, grava as parcelas
Local lCriaSerie    := .F.
Local lTicket       := .F.
Local nRegSX5       
Local cTipoDoc      := ""
Local cSerAtu       := ""   
Local cProxNum      := ""
Local lErrCupTEF	:= .F.	// Indica que houve erro na impressao do cupom TEF e eh impossivel cancelar o cupom fiscal
Local lBaixarEmp	:= .T.
Local cRetorno      := " "
Local lMacro        := .F.
Local cDocSerie     := ""
Local lFoundSX5     := .F.
Local aPsCsCf       := {}
Local nTotNFPis     := 0
Local nTotNFCofins  := 0
Local nTotNFCSLL    := 0
Local nRestNFPis    := 0
Local nRestNFCofins := 0
Local nRestNFCSLL   := 0
Local nBasDup       := 0
Local nImpostos     := 0
Local lFirstDupRec  := .T.
Local nTotAbat      := 0
Local nRestDiv      := 0
Local cCliAbat      := ""
Local cLojAbat      := ""
Local cPrefAbat     := ""
Local cNumAbat      := ""
Local cParcelaAbat  := ""
Local cLoteAbat     := ""
Local cBaixaAbat    := ""
Local aRelImp       := MaFisRelImp("MT100",{ "SD2" })
Local nScanPis      := 0
Local nLoopParc     := 0
Local lTipFin       := .F.
Local lAbatDinh     := .T.
Local aAliasSE1     := {}
Local aRecNoSE1     := {}
Local nComisSE1		:= 0
Local nTotNFISS     := 0
Local nRestISS      := 0
Local nTotNFIRRF	:= 0
Local nRestIRRF		:= 0
Local nDecimal		:= TamSX3("E1_BASCOM1")[2] // N@ de decimais considerados no calculo
Local nRatFrete		:= 0
Local cMV_TPNRNFS	:= LjTpNrNFS()				// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local nRecnoSF2		:= 0 						// Controle do recno do SF2
Local nBasePS2      := 0						// Valor da Base PIS 2 (Apuracao)
Local nValPS2		:= 0						// Valor do PIS 2 (Apuracao)
Local nBaseCF2		:= 0						// Valor da Base Cofins 2 (Apuracao)
Local nValCF2		:= 0						// Valor do Cofins 2 (Apuracao)
Local nTamL1_SER 	:= TamSX3("L1_SERIE")[1] 	// Tamanho do campo L1_SERIE
Local nTamL1_DOC 	:= TamSX3("L1_DOC")[1]		// Tamanho do campo L1_DOC
Local nTamF2_DOC    := TamSX3("F2_DOC")[1]		// Tamanho do campo F2_DOC
Local nTamD2_ITE 	:= TamSX3("D2_ITEM")[1]		// Tamanho do campo D2_ITEM
Local nTamL2_RES 	:= TamSX3("L2_RESERVA")[1]	// Tamanho do campo L2_RESERVA
Local nTamE1_PRE 	:= TamSX3("E1_PREFIXO")[01]	// Tamanho do campo E1_PREFIXO
Local nTamDC_SEQ    := TamSX3("DC_SEQ")[1]		// Tamanho do campo DC_SEQ
Local nTamE1_PAR    := TamSX3("E1_PARCELA")[01]	// Tamanho do campo E1_PARCELA
Local nTamA6_AGE 	:= TamSX3("A6_AGENCIA")[1]	// Tamanho do campo A6_AGENCIA
Local nTamAE_COD	:= TamSX3("AE_COD")[1]		// Tamanho do Campo AE_COD
Local cNomCliSAE	:= ""						// Se inclui nome do cliente do SAE
Local cCodCliSAE	:= ""						// Se inclui codigo do cliente do SAE
Local cLojCliSAE	:= ""						// Se inclui a loja do cliente do SAE	
Local nIcmsDifer	:= 0						// Totalizador do ICMS Diferido
Local lAdmin		:= .F.											// Utilizada para quebrar ou nao o Titulo por Administradora.
Local aBkpRcb       := aClone(aReceb)								// Backup do Array aReceb, para restauracao apos criacao dos Titulos de Contas a Pagar.
Local cParcela		:= PadR(SuperGetMV("MV_1DUP"), nTamE1_PAR)		// Variavel utilizada para definicao da Parcela do Contas a Receber
Local lJurAdm		:= .F.
Local lRetorno      := .T.												// Recebe o Retorno do PE e da Funcao KEXF580

Private aVendas		:= {}
Private aAComis		:= Array(5,2)
Private nNParc 		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .AND. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .AND. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

If cPaisLoc == "GUA"
   Private aCerts	:=	{}   //Variavel utilizada para os certificados de retencoes
Endif

aImpVarSF2      	:=      {}

cNumNota :=Space( nTamL1_DOC )
cSerie   :=Space( nTamL1_SER )
If nPerJur == NIL
	nPerJur	 := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Inicializa o array acumulador de comissäes por vendedor   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aAComis, { |x| x[01] := 0, x[02] := 0 })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	IMPORTANTE	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O conceito de lFaturar e lFinanceiro foi criado para contemplar³
//³ a opcao de Pedidos e encomendas aproveitando o Loja010		   ³
//³																   ³
//³lFaturar: Fica .T. quando o cliente esta pedindo				   ³
//³a emissao da nota ou a emissao do cupom fiscal				   ³
//³																   ³
//³lFinanceiro: Fica .T. sempre da gravacao do pedido, pois 	   ³
//³quando o pedido eh gravado os titulos ja s o gerados, mesmo 	   ³
//³sem a emissao da nota que sera emitida(faturada) depois. 	   ³
//³																   ³
//³	ISTO EH AVALIADO PARA A OPCAO DE PEDIDO LOJA016, A VENDA BAL-  ³
//³	CAO CONTINUA NORMALMENTE.									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lFiscal .AND. nCheck == 1
	lImpCupFis := .T.
Else
	lImpCupFis := .F.
	lTicket    := (cPaisLoc == "GUA" .AND. nCheck == 3)	
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o numero da nota fiscal, se for o caso  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lImpCupFis
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|nCheck == 2 .OR. nCheck == 3 .OR. nCheck == 4                |
	//| Se for pedido, mas foi pedido a emissao de nota ou cupom    |
	//| entao, gera D2 e F2.                                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFaturar
		If Empty(cSerie)
			While .T.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se há multiplas notas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SL2->(DbSetOrder(1))
				SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				
				nItensVenda := 0
				aNotas      := {}
				
				SL2->(DBEval( { || nItensVenda ++ },, ;
				              { || SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. ! EOF() },,, .T. ))

				nMaxItens := SuperGetMV("MV_SER"+cSerie,.F.,SuperGetMV("MV_NUMITEN"))
				nQtdNotas := If( nItensVenda > nMaxItens, Int(( nItensVenda / nMaxItens )) + If( Mod(nItensVenda,nMaxItens) > 0, 1, 0 ), 1 )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //| Atribui a serie de acordo com o tipo do cliente desde que o parametro nao tenha     |
                //| chamada a um programa customizado                                                   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If cPaisLoc == "ARG" .AND. Substr(cLojaNF,1,1)<>"&" 
	               cLojaNF := Lj010SerArg()				   	         
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	            //| A impressao de ticket nao tem limitacao de itens - Loc. Guatemala  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            ElseIf lTicket
	               nMaxItens := 999
	               nQtdNotas := 1  
                Endif   								
	            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              	//³Verifica se existe um sinal de & (macro substituicao), dessa forma³
             	//³possibilita ao usuario montar um parametro o qual seja executada  ³
             	//³uma condicional.                                                  ³
             	//³Foi necessario fazer dessa forma, pois caso contrario acarretaria ³
            	//³erro na base de clientes ja implantada.                           ³
               	//³Solicitado por: Projeto Kodak                                     ³
            	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
            	lMacro  := Substr(cLojaNF,1,1)=="&"
            	If lMacro            	            	
	               cLojaNF  := &(Substr(cLojaNF,2,Len(cLojaNF)))
            	ElseIf cPaisLoc == "GUA"
                   If SX5->(DbSeek(xFilial("SX5")+"AB"+"NF "))
                      cLojaNF  := AllTrim(X5Descri())
                   Endif                             	                   
	            Endif
                 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Incluido a funcao PadR, para que, a variavel fique com o mesmo    ³
				//³tamanho do campo L1_SERIE evitando problemas com DbSeek.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
                cLojaNF  := PADR(cLojaNF, nTamL1_SER )
                
				If Lj010Nota(	@cLojaNF	, nCheck	, @lImpCupFis,	nQtdNotas	, ;
								@aNotas		, Nil		, @lCriaSerie, 	nItensVenda	, ;
								@nMaxItens	, lTicket	, @cDocSerie)
					oDlgLoja:Refresh()
					Exit
				Else
					lSaida := .F.
					Exit
				Endif
			End
		Endif
        If lSaida .AND. cPaisLoc <> "BRA"        
           DbSelectArea("SF2")
           DbSetOrder(1)
           cNumNota      := aNotas[1,2]         
           cNumNota      := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamF2_DOC )  
           cNumAnt       := cNumNota
           cAliasNF		 := "SF2"
           
           While lExiste
              lExiste:=  !aNumNaoExiste(cAliasNF,cSerie,cNumNota,SL1->L1_CLIENTE,SL1->L1_LOJA,cEspecie,"LOJ")              
              If lExiste 
		         cNumNota := PadR( StrZero(val(cNumNota)+1,Len(cNumNota)) , nTamF2_DOC ) 
		      Else
                 If cNumAnt <> cNumNota
                    nI := 1
                    aNotas  := {}
                    While nI <= nQtdNotas
	                   AAdd(aNotas,{cSerie,cNumNota})
		               If nI < nQtdNotas
			              cNumNota := PadR( StrZero(val(cNumNota)+1,Len(cNumNota)) , nTamL1_DOC )  
		               Endif	                   
	                   nI++
                    End              
                    cNumNota  := aNotas[1,2]
                    cNumNota  := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamL1_DOC )
	                If nAltera == 1                                             
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	                    //| " O Numero do Documento foi alterado de: " ### " para: " ### "Numero" 	  	        |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		               MsgInfo( STR0075 + cNumAnt + STR0076 + cNumNota, STR0077)		         
	                ElseIf nAltera == 2                                                                  
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		                //| " O documento no.: "  ### " ja existe, confirma alteracao da numeracao para: "	    |      
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		               lSaida := MsgYesNo(STR0071 + cNumAnt +STR0072 + cNumNota )
	                Else                                                                             
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			            //| " O documento no.: "  ### " ja existe " ### "Numero do Documento "					|		          
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		               MsgInfo(STR0071 + cNumAnt + STR0073,STR0074)
   		               lSaida := .F.
	                Endif
                 Endif
              Endif   
           End
		Endif		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna numero da nota fiscal para o arquivo de Tabelas  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMV_TPNRNFS <> "3"
			If lSaida
				cSerie := aNotas[1,1]
				cNumNota := aNotas[1,2]
                cNumNota := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamL1_DOC )              
				DbSelectArea("SX5")
				If cPaisLoc == "BRA" .OR. !SuperGetMv("MV_SEQESPE",,.F.)	
				   lFoundSX5  := DbSeek( cFilial+"01"+cSerie )
				Else 
				   lFoundSX5  := DbSeek( cFilial+"AC"+"NF "+cSerie )			
				Endif   
				nRegSX5  := Recno()			
				If lFoundSX5 			
				   RecLock("SX5",.F.)
				   IF Val(X5Descri()) <= Val(cNumNota)
				      REPLACE X5_DESCRI  WITH PadR( StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamL1_DOC )    
					  REPLACE X5_DESCSPA WITH PadR( StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamL1_DOC )
					  REPLACE X5_DESCENG WITH PadR( StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamL1_DOC )
				   Endif	  
				Endif
				MsUnlock( )
			Endif
		Endif
	Endif
Endif

SA1->( DbSetOrder( 1 ) )
SA1->( DbSeek( xFilial( "SA1" )+SL1->L1_CLIENTE+SL1->L1_LOJA ))

cTipCliEntr := SA1->A1_TIPO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Retiro o Tipo do cliente Entrega, caso seja selecionado  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cCliEntrega ) .AND. !Empty( cLojEntrega )
	SA1->( DbSeek( xFilial( "SA1" )+SL1->L1_CLIENT+SL1->L1_LOJENT ))
	cTipCliEntr := SA1->A1_TIPO                                     
	SA1->( DbSeek( xFilial( "SA1" )+SL1->L1_CLIENTE+SL1->L1_LOJA ))
Endif

If lSaida
	If lFiscal .AND. lImpCupFis
	   If cPaisLoc <> "ARG"
	      cSerie  := LjGetStation("SERIE")
	   Else
	      cSerie  := Lj010SerArg()
	   Endif   
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recalcula a tributa‡„o caso tenha desconto ³
	//³ ou acrescimo na Cond. Pag.				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nTxJuros > 0 .OR. nTxDescon > 0) .AND. !lTroca
		LjRecalTrib( 	"CONDPAG"	, lUsoufator, cNumOrc	, nTxDescon, ;
						nEntrada	, nDescloj	, nValorBase, nLiq	)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Imprime CP Fiscal n„o quebra o numero de nota ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpCupFis .OR. lTicket
		nMaxItens := 999
	Endif
	
	nValorCred := SL1->L1_CREDITO
	nLoopParc  := Len( aReceb )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Reajuste dos valores de Pis/COFInS nas parcelas	                                                               |
	//| Caso tenha npValISS (Valor de ISS onde A1_RECISS == "1" e MV_DESCISS == .T.) e o parâmetro MV_TPABISS == "1"   |
	//| o título será gravado sem o valor do ISS, caso contrário, soma o valor do ISS nas parcelas e será gerado um    |
	//| título de abatimento desse ISS (-IS) para cada parcela.                                                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( LJPCCRet() + If( ! lpTPAbISS, 0, npValISS ) ) > 0 .AND. ;
		( nLoopParc <> 1 .OR. (nLoopParc == 1 .AND. aReceb[1][2] > 0) )
		
		For nX := 1 to nLoopParc
			aReceb[nX][2] += NoRound(( ( LJPCCRet() + If( ! lpTPAbISS, 0, npValISS ) ) / nLoopParc ),nDecimais)
			nRestDiv += NoRound(( ( LJPCCRet() + If( ! lpTPAbISS, 0, npValISS ) ) / nLoopParc ),nDecimais)
			
			If lAbatDinh
				lAbatDinh := .F.
			Endif

		Next nX
		           
		If nRestDiv < ( LJPCCRet() + If( ! lpTPAbISS, 0, npValISS ) )
			aReceb[nLoopParc][2] += ( LJPCCRet() + If( ! lpTPAbISS, 0, npValISS ) ) - nRestDiv
		Endif
		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o valor em numerarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDecs := MsDecimais(nMoedaCor)
	For i:=1 To Len(aReceb)
		cMoeda := Trim(aReceb[i][3])
		If IsMoney(cMoeda)
			If cPaisLoc == "BRA"
				nDinheiro+=aReceb[i][2]
			Else
				nDinheiro+=Round(xMoeda(aReceb[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecs+1,,nTaxaMoeda),nDecs)
				Lj010RetPos(@nDinheiro)
			Endif
		Elseif "CC" $ cMoeda
			If cPaisLoc == "BRA"
				nValorCart+=aReceb[i][2]
			Else
				nValorCart+=Round(xMoeda(aReceb[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecs+1,,nTaxaMoeda),nDecs)
				Lj010RetPos(@nValorCart)
			Endif
			cAdmCar   := Substr(aReceb[i][4],1,3)
		Elseif cSimbCheq $ cMoeda
			If cPaisLoc == "BRA"
				nCheques+=aReceb[i][2]
			Else
				nCheques+=Round(xMoeda(aReceb[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecs+1,,nTaxaMoeda),nDecs)
				Lj010RetPos(@nCheques)
			Endif
		Elseif "VA" $ cMoeda
			If cPaisLoc == "BRA"
				nValorVale+=aReceb[i][2]
			Else
				nValorVale+=Round(xMoeda(aReceb[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecs+1,,nTaxaMoeda),nDecs)
				Lj010RetPos(@nValorVale)
			Endif
		Elseif "FI" $ cMoeda
			If cPaisLoc == "BRA"
				nValorFin  +=aReceb[i][2]
			Else
				nValorFin  +=Round(xMoeda(aReceb[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecs+1,,nTaxaMoeda),nDecs)
				Lj010RetPos(@nValorFin)
			Endif
		Elseif "CO" $ cMoeda
			If cPaisLoc == "BRA"
				nValorConv+=aReceb[i][2]
			Else
				nValorConv+=Round(xMoeda(aReceb[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecs+1,,nTaxaMoeda),nDecs)
				Lj010RetPos(@nValorConv)
			Endif
		Elseif "CD" $ cMoeda
			If cPaisLoc == "BRA"
				nValorDebi+=aReceb[i][2]
			Else
				nValorDebi+=Round(xMoeda(aReceb[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecs+1,,nTaxaMoeda),nDecs)
				Lj010RetPos(@nValorDebi)
			Endif
		Else
			If cPaisLoc == "BRA"
				nOutros+=aReceb[i][2]
			Else
				nOutros+=Round(xMoeda(aReceb[i][2],aPgtos[i][4],nMoedaCor,dDatabase,nDecs+1,,nTaxaMoeda),nDecs)
				Lj010RetPos(@nOutros)
			Endif
		Endif
	Next i
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Impressao do cupom fiscal			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCheck == 1 .AND. lFiscal
		lGravar := .T.
		If lGravar
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|Indica que sera emitido um cupom vinculado ao cupom fiscal emitido.                  |
			//| Especifico para impressora Urano versao 3.00                                        |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaTef .AND. lTefOk .AND. (nValorCart + nValorDebi + nCheques) > 0 .AND. ctipTEF $ "2;3;4" // Sem Client / Com Client / Discado
				cVinculado := '1'
			Endif
            nModoPrint    := 1			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³LOG TEF                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', Replicate('-',80) 		+ Chr(13) 	+ Chr(10) + ;
				                                            '0)  cEstacao = ' 		+ cEstacao 	+ Chr(13) + Chr(10) + ;
				                                            '1)  lFiscal = ' 		+ If(lFiscal,'.T.','.F.') + Chr(13) + Chr(10) + ;
				                                            '2)  cUsuario = ' 		+ cUserName + Chr(13) + Chr(10) + ;
				                                            '3)  xNumCaixa() = ' 	+ xNumCaixa() + Chr(13) + Chr(10) + ;
				                                            '4)  Antes da impressão do cupom fiscal')
			Endif	            

			lGravar := Lj010Fisc(	nDescLoj	, nDinheiro	, nValorCart, nCheques	, ;
									nValorVale	, nValorFin	, nValorConv, nOutros	, ;
									nTroco		, nValorDebi, cVinculado, cCombo	, ;
									nLiq		, nModoPrint )

			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '5)  lGravar = ' + If(lGravar, '.T.', '.F.') + Chr(13) + Chr(10) + ;
				                                            '6)  cNumNota = ' + cNumNota )
			Endif

			If Empty(cNumNota)
				lGravar := .F.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  HOMOLOGACAO: Verificar se existe cupom aberto   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lGravar
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³se exitir cupom aberto, faz o cancelamento e abre um novo.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				iRet := IFStatus( nHdlECF, '5', @cRetorno )
				If iRet = 7
					MsgInfo(STR0108) 	//"Foi detectado um problema e o cupom fiscal atual sera cancelado"
					iRet := IFCancCup( nHdlECF )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Da um tempo para a impressora fazer a impressao do cancelamento ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Inkey(8)   			
				Else
					L010AskImp(.F.,iRet)
				Endif
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faz a validacao do numero do cupom fiscal. Verifica se o numero jah existe ³
				//³na base (para o caso de zerar a numeracao do ECF)                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF2->(DbSetOrder(1))	// Filial + doc + serie + cliente + loja
                cNumNota := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamF2_DOC )
				If SF2->(DbSeek(xFilial("SF2")+cNumNota+cSerie))
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "6.1)  Encontrou o orcamento no SF2 = "+xFilial("SF2")+cNumNota+cSerie + Chr(13) + Chr(10) +;
																	"6.2)  lGravar = .F.")
					Endif
					lGravar := .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿¿
					//"Atenção"###"O cupom fiscal "###" já existe na base de dados e o mesmo será cancelado no ECF. Efetue a alteração no número de série no cadastro de estações. "###"Ok" 					
					Aviso(STR0088,STR0102 + cNumNota + " " + cSerie + STR0103, {STR0104} )					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Faz o cancelamento do cupom fiscal  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					iRet := IFCancCup( nHdlECF )
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '6.3)  IFCancCup = '+Str(iRet))
					Endif
				Endif
			Endif
			
		Endif
	
		lSaida  := lGravar
		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre a Gaveta de Dinheiro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGaveta
		AbreGaveta()
	Endif
	
	If !Empty(LOG_TEF)
		LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '7)  lSaida = ' + If( lSaida, '.T.', '.F.' ) + Chr(13) + Chr(10) + ;
		                                            '8)  lUsaTef = ' + If( lUsaTef, '.T.', '.F.' ) + Chr(13) + Chr(10) + ;
		                                            '9)  lTefOk = ' + If( lTefOk, '.T.', '.F.' ) + Chr(13) + Chr(10) + ;
		                                            '10) nValorCart = ' + Str(nValorCart,14,2) + Chr(13) + Chr(10) + ;
		                                            '11) nValorDebi = ' + Str(nValorDebi,14,2) + Chr(13) + Chr(10) + ;
		                                            '12) nCheques = ' + Str(nCheques,14,2) )
	Endif		
	If lUsaTef .AND. lTefOk .AND. (nValorCart + nValorDebi + nCheques) > 0 .AND. ctipTEF $ "2;3;4" // Sem Client / Com Client / Discado
		If lGravar
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Gravar a informação para identificação de operação TEF, no log principal "LJ"       |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLog1 .AND. lLog4
				If nHandle >= 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Vou desencriptar a string completa para poder gravar novamente                      |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSize    := Fseek(nHandle,0,2)
					cRBuffer := Space(nSize+5)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Trabalhando o arquivo   |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Fseek(nHandle,0,0)
					Fread(nHandle,@cRBuffer,nSize)
					cRBuffer	:= Encript(cRBuffer,1)+"#TEF#"
					Fseek(nHandle,0,0)
					Fwrite(nHandle,encript(cRBuffer,0))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Gravar o LOG para futura Recuperacao em caso nao finalizacao do processo            |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					LjGrLogT(	cNumOrc		, cNumNota	, xNumCaixa()	, aTefDados	, ;
								nDinheiro	, nCheques	, nValorCart 	, nValorDebi, ;
								nValorConv	, nValorVale, nValorFin		, nOutros	, ;
								nDescloj	, nDescPer 	, cNumPdv )
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Fim de Gravação                             |
			//| ENVIANDO OS COMANDOS PARA A TRANSACAO TEF   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( lGravar := LOJA010T( "I", "V" ))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Gravar a informação para identificação de operação TEF, no log principal "LJ"       |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLog1 .AND. lLog4 .AND. nHandle >= 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Vou desencriptar a string completa para poder gravar novamente                      |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSize    := Fseek(nHandle,0,2)
					cRBuffer := Space(nSize+5+4)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Trabalhando o arquivo   |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Fseek(nHandle,0,0)
					Fread(nHandle,@cRBuffer,nSize)
					cRBuffer	:= Encript(cRBuffer,1)+"#OK#"
					Fseek(nHandle,0,0)
					Fwrite(nHandle,encript(cRBuffer,0))
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Fim de Gravação   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				L010AtCartao()
			Else                    
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Indica que houve erro na Transacao TEF ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lErrCupTEF := .T.	
				lTefOK     := .F.
			Endif
		Else
			If LOJA010T( "F", "N" )
				MsgInfo(STR0107) 	//"Transação TEF não efetuada, favor reter o cupom!"
			Endif				
		Endif
	Endif
	
	If !Empty(LOG_TEF)
		LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '13) lGravar = ' + If( lGravar, '.T.', '.F.' ) )
	Endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  Se lErrCupTEF for .T., o lGravar tambem sera .T.                                   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGravar .OR. lErrCupTEF
		Begin Transaction

		If !Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '14) Begin Transaction - Inicio:'+Time() )
		Endif			

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
		//³ cMV_TPNRNFS for igual a "3" e nao for impressao de cupom             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMV_TPNRNFS == "3" .AND. !lImpCupFis
			aAdd( aNotas, { cLojaNF,  MA461NumNf( .T., cLojaNF ) } )
			cSerie 		:= aNotas[nNotaAtu+1][1]
			cNumNota 	:= aNotas[nNotaAtu+1][2]
            cNumNota    := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamL1_DOC )
		Endif
		nValMerc := 0
		AEVAL( aCols, {|x| nValMerc += If( ATAIL(x), 0, x[nPosValMerc] ) } )
		
		Reclock( "SL1", .F. )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso ocorra erro na transacao TEF, continua a gravacao do cupom, ³
		//³ pois o mesmo nao pode ser cancelado no ECF.                      ³
		//³ Neste caso sera necessario realizar uma NOTA DE DEVOLUCAO.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lErrCupTEF
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '14.1) Erro na transacao TEF - Reter o Cupom e Fazer DEVOLUCAO' )
			Endif			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Indica que houve erro na Transacao TEF ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SL1->L1_STATUS := "T"				
		Endif

		If lUsaTef .AND. lTefOk .AND. !lErrCupTEF .AND. cTipTef $ "2;3;4" // Sem Client / Com Client / Discado
			SL1->L1_VENDTEF:= "S"
			SL1->L1_DATATEF := aTefDados[1][2]
			SL1->L1_HORATEF := aTefDados[1][3]
			SL1->L1_DOCTEF  := aTefDados[1][4]
			SL1->L1_AUTORIZ := aTefDados[1][5]
			SL1->L1_INSTITU := aTefDados[1][8]
			SL1->L1_DOCCANC := aTefDados[1][6]
			SL1->L1_DATCANC := aTefDados[1][12]
			SL1->L1_HORCANC := aTefDados[1][7]
			SL1->L1_NSUTEF  := aTefDados[1][9]
			SL1->L1_TIPCART := aTefDados[1][10]
			If ! Empty(aTefDados[1][15])
				SL1->L1_FORMPG  := aTefDados[1][15]
			Endif
			If SL1->(FieldPos("L1_PARCTEF"))>0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SL1->L1_PARCTEF := aTefDados[1][16]+aTefDados[1][17]	
			Endif
		Else
			SL1->L1_VENDTEF := "N"
		Endif

		SL1->L1_DOC      := cNumNota
		If lImpCupFis .AND. cPaisLoc <> "ARG"
			SL1->L1_SERIE := ljGetStation("SERIE")
		Else
			SL1->L1_SERIE := cSerie
		EndIf
		SL1->L1_PDV      := cNumPdv
		If lImpCupFis
			SL1->L1_NUMCFIS := SL1->L1_DOC
		Else
			SL1->L1_NUMCFIS := ""
		EndIf
		SL1->L1_EMISNF   := dDataBase
		If cPaisLoc == "BRA"
			SL1->L1_VALBRUT := SL1->L1_VLRLIQ
			SL1->L1_VALMERC := nValMerc
		Else
			SL1->L1_VALBRUT := SL1->L1_VLRTOT
			SL1->L1_VALMERC := SL1->L1_VLRLIQ
		EndIf
		SL1->L1_TIPO     := "V"
		SL1->L1_DINHEIRO := nDinheiro
		SL1->L1_CHEQUES  := nCheques
		SL1->L1_CARTAO   := nValorCart
		SL1->L1_VLRDEBI  := nValorDebi
		SL1->L1_CONVENI  := nValorConv
		SL1->L1_VALES    := nValorVale
		SL1->L1_FINANC   := nValorFin
		SL1->L1_OUTROS   := nOutros
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera sempre com o desconto financeiro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc <> "BRA"
			SL1->L1_DESCONT := nDescloj + aDadosJur[9]
		Else
			SL1->L1_DESCONT := nVlrDesc
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma o percentual do desconto financeiro - Localizacoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SL1->L1_DESCNF   := nDescPer+If(cPaisLoc<>"BRA",nTxDescon,0)   
		SL1->L1_OPERADO  := xNumCaixa()
		SL1->L1_HORA     := SubStr(Time(),1,5)
		SL1->L1_NRDOC    := cReq
		
		If !Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '15) SL1->L1_NUM = ' + SL1->L1_NUM + Chr(13) + Chr(10) + ;
			                                            '16) SL1->L1_DOC = ' + SL1->L1_DOC + Chr(13) + Chr(10) + ;
			                                            '17) SL1->L1_SERIE = ' + SL1->L1_SERIE )
		Endif			


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Gera SE5 para os trocos dados...  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc <> "BRA"
		    If cPaisLoc == "PAR" .AND. !Empty(SL1->L1_BLCRED)
		       SL1->L1_BLCRED   := "10"  //Faturado
		    Endif   				
			For nC := 1 To MoedFin()
				If &("SL1->L1_TROCO"+Alltrim(Str(nC))) > 0
					AtuaTroco(&("SL1->L1_TROCO"+Alltrim(Str(nC))),nC)
				Endif
			Next nC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Grava tipo e numero de documento para Consumidor Final cuja venda seja              |
			//| superior ao determinado no parametro MV_LIMCFIS                                     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "ARG" .AND. !Empty(cCodEnd)
				RecLock("MAD",.T.)
				MAD->MAD_FILIAL := xFilial("MAD")
				MAD->MAD_CODEND := cCodEnd
				MAD->MAD_END    := cEnderCF
				MsUnlock()
				
				DbSelectArea("SLS")
			   	RecLock("SLS",.T.) 
			   	SLS->LS_FILIAL  := xFilial("SLS")
			   	SLS->LS_SERIE   := SL1->L1_SERIE
			   	SLS->LS_DOC     := SL1->L1_DOC
			   	SLS->LS_TIPO    := "N"
			   	SLS->LS_DOCCF   := cNumDocCF
			   	SLS->LS_TPDOCCF := cTipoDocCF			      
			   	SLS->LS_TIPOCI  := cTipoCI
			   	SLS->LS_CLIECF  := cClienteCF			      			   
			   	SLS->LS_CODEND  := cCodEnd
			   
			   	MsUnlock()
			Endif
		Endif    
		
		If lLj10Ser
			cSerie:=ExecBlock("LJ10SER",.F.,.F.)
		Endif
		
		aVendas := {}
		DbSelectArea( "SL2" )
		DbSetOrder( 1 )
		DbSeek( xFilial("SL2") + SL1->L1_NUM )
		nItens := 0
		cFirst := cNumNota
		cTes := SL2->L2_TES
		nRecnoSL2  := Recno()		
		While !EOF( ) .AND. xFilial("SL2") == L2_FILIAL .AND. L2_NUM == SL1->L1_NUM
		    AAdd(aVendas,{	L2_PRODUTO		,;
		    				L2_DESCPRO		,;
		    				L2_VALDESC		,;
		    				L2_TES			,;
		    				L2_UM			,;
				 			L2_QUANT		,;
				 			L2_VRUNIT		,;
				 			L2_VALICM		,;
				 			L2_CF			,;
				 			L2_DESC			,;
				 			L2_DOC			,;
				 			L2_EMISSAO		,;
				 			L2_SERIE		,;
				 			L2_BASEICM		,;
				 			L2_LOCAL		,;
				 			L2_ITEM			,;
				 			L2_VALIPI		,;
				 			L2_VALISS		,;
				 			L2_VLRITEM		,;
				 			SL2->(Recno())	,;
				 			0				,;
				 			SL2->L2_DESCPRO	,;
				 			SL2->L2_PRCTAB	,;
				 			L2_TABELA		,;
				 			L2_VALFRE		,;
				 			L2_SEGURO		,;
				 			L2_DESPESA})		
				 			
			If AScan( aVendedor, { |x| x[1] = SL1->L1_VEND } ) == 0
				AAdd(aVendedor, {SL1->L1_VEND, 0, 0, 0, 0, "", "", 0, {} } )
			Endif
			Reclock( "SL2" )
			If Empty(SL1->L1_DOC)
				SL2->L2_VENDIDO := " "
			Else
				SL2->L2_VENDIDO := "S"
			EndIf
			If lFiscal
				SL2->L2_DOC 		:= cNumNota
				SL2->L2_SERIE		:= cSerie
			Else
				SL2->L2_DOC 		:= aNotas[nNotaAtu+1][2]
				SL2->L2_SERIE		:= aNotas[nNotaAtu+1][1]
			Endif
			SL2->L2_PDV 		:= SL1->L1_PDV
			#IFDEF BTV
				DbGoto(recno())
			#Endif
			DbSkip()
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //|  Atualiza o status do Lay-Away  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc$"EUA|POR" .AND. lLayAway
		   SL2->(DbSetOrder(1))		
		   SL2->(DbGoto(nRecnoSL2))	          			  		
		   For nX := 1 to Len(aCols)
	          If (aCols[nX][Len(aCols[nX])])
		         Loop
	          Endif		      
			  If nPosLay > 0 .AND. nPosItLw > 0 .AND. !Empty(aCols[nX][nPosLay])
				 a800BxLay(aCols[nX][nPosLay],aCols[nX][nPosItLw],nX)  
				 lCompensa := .T.
			  Endif
	          SL2->(DbSkip())			  
		   Next nX
		Endif				    
		
		If lLj10D2
			ExecBlock("LJ10D2",.F.,.F.)
		Endif
		
		If lVlrFSD

			nVlrIcmFre := 0
			For nI := 1 to Len(aVendas)
				If SF4->(DbSeek(xFilial("SF4")+aVendas[nI][4]))
					If SF4->F4_ICM == "S"
						nVlrIcmFre += Lj010Icms(nI,,aVendas[nI][25])
					Endif
				Endif
			Next nI

		Endif

		cItenf:="00"
		nVlrFreNota := 0
		nVlrSegNota := 0
		nVlrDesNota := 0
		If lFaturar
		
			For nI := 1 to Len(aVendas)
				SL2->(DbGoto(aVendas[nI,20]))
				DbSelectArea( "SF4" )
				DbSeek( xFilial("SF4") + aVendas[nI,4] )
				If !EOF()
					nItens ++
					If nItens > nMaxItens
						cItenf := Repl("0", nTamD2_ITE )
						If !lFiscal .OR. !lImpCupFis
							nNotaAtu ++
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
							//³ cMV_TPNRNFS for igual a "3". Como ja' pegou o numero da nota no      ³
							//³ inicio da rotina, pega agora somente quando for outra NF (no caso da ³
							//³ quantidade de itens ser maior que a quantidade por nota.             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nNotaAtu > 1
								If cMV_TPNRNFS == "3"
									aAdd( aNotas, { cLojaNF,  MA461NumNf( .T., cLojaNF ) } )
								Endif
							Endif							
							cSerie	 := aNotas[nNotaAtu][1]
							cNumNota := aNotas[nNotaAtu][2]
                            cNumNota := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamF2_DOC )      
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Chama a funcao de gravacao do SF2 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						If !Empty(LOG_TEF)
							LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '18) Antes da geracao do SF2')
                        Endif
                        
						FechaSF2(	lFirst		, nICMF2	 ,	nBsICMF2	, nIPIF2		, ;
									nBSIPIF2	, nVlMF2	 ,	nBsISSF2	, nISSF2		, ;
									nDESCF2		, cFirst	 ,	Nil			, @lEntrou		, ;
									nVlIcmRetF2	, nBsIcmRetF2,	@lImpCupFis	, nImpIncNota	, ;
									nMoedaCor	, nSmIcmRetF2,	aNotas		, nNotaAtu		, ;
									nVlrIcmFre	, cTipoDocCF ,	cNumDocCF	, cClienteCF	, ;
									cEnderCF	, nVlrFreNota,	nVlrSegNota	, nVlrDesNota	, ;
									(nItens-1)	, cDocSerie  , 	nBasePS2	, nValPS2		, ;
									nBaseCF2	, nValCF2	,	nIcmsDifer )

						If !Empty(LOG_TEF)
							LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '19) SF2->SF2_DOC = ' + SF2->F2_DOC + Chr(13) + Chr(10) + ;
							                                            '20) SF2->SF2_SERIE = ' + SF2->F2_SERIE )
						Endif
													
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava o Arquivo de Livros Fiscais "SF3" c/Base na nova      ³
						//³ estrutura de gera‡Æo de Livro "aLivro" p/Clientes que utili-³
						//³ zam a Amarra‡Æo TesXImpostos e F¢rmula/Rotina de Apura‡Æo   ³
						//³ do Livro "F4_LIVRO"                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cPaisLoc <> "BRA"
						    If Len(aLivro) > 0
								GravaLivro(@aLivro,cSerie,cNumNota)
							Endif
							DbSelectArea("SF2")
							DbSetOrder(1)
                            cNumNota := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamF2_DOC )      
							DbSeek(xFilial("SF2")+cNumNota+cSerie)
							If Found()
								If lLancPad20
									nTotal += DetProva(nHdlPrv,"620","LOJA010",cLoteFat)
									If nTotal > 0
										RecLock("SF2",.F.)
										SF2->F2_DTLANC := dDatabase
										MsUnlock()
									Endif
								Endif
							Endif
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gravar Livro Fiscal com base no Pto de Entrada.             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|  LUCAS 06/09/99 MARISOL ARGENTINA   |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ExistBlock("Lj010SF3")
							ExecBlock("Lj010SF3",.F.,.F.)
						Endif
						nIcmf2  	:= 0
						nSmIcmRetF2 := 0
						nBsIcmF2 	:= 0
						nIPIF2  	:= 0
						nBsIPIF2 	:= 0
						nVlmF2  	:= 0
						nBsISSF2 	:= 0
						nISSF2  	:= 0
						nDescF2 	:= 0
						nBsIcmRetF2 := 0
						nVlIcmRetF2 := 0
						If lFirst
							RecLock("SL1")
							SL1->L1_MULTNOT := "S"
							MsUnlock()
						Endif
						nItens 		:= 1
						lFirst 		:= .F.
						aImpVarSF2  := {}
						nImpIncNota	:= 0
						nValor		:= 0
						nVlrFreNota := 0
						nVlrSegNota := 0
						nVlrDesNota := 0                        
						nBasePS2    := 0
						nValPS2		:= 0						   	
						nBaseCF2	:= 0							
						nValCF2		:= 0							
						aLivro  	:= {}
					Endif
					Reclock("SL2")
					SL2->L2_DOC := cNumNota
					MsUnlock()
					aCusto := {}
					DbSelectArea( "SB1" )
					DbSeek( cFilial + SL2 -> L2_PRODUTO )
					nVlrFreNota += aVendas[nI][25]
					nVlrSegNota += aVendas[nI][26]
					nVlrDesNota += aVendas[nI][27]   

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Descricao dos Itens do Array (aVendas)  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					/*
					01 - Produto
					02 - Descricao
					03 - Valor desconto
					04 - Tes
					05 - Unidade de Medida
					06 - Quantidade
					07 - Valor Unitario
					08 - Valor do Icm
					09 - Cf
					10 - Desconto em %
					11 - Numero da NF
					12 - Data de Emissao
					13 - Serie da nota
					14 - Base de Icm
					15 - Local
					16 - Item
					17 - Valor do Ipi
					18 - Valor do Iss
					19 - Valor total do item
					20 - recno do sl2
					21 - Zero
					22 - Desconto Proporcional
					23 - Preco de Tabela
					24 - Desconto no item unitario
					25 - Desconto no item unitario em percentual
					26 - Tabela de preco utilizada no item
					*/
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gravacao do SD2 para integracao com outros m¢dulos ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SF2->(DbSetOrder( 1 ))
                    cNumNota := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamF2_DOC )      
					If ! SF2->( DbSeek( xFilial( "SF2" )+ cNumNota + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA ) )
						RecLock( "SF2", .T. )
						SF2->F2_FILIAL  := xFilial( "SF2" )
						SF2->F2_DOC     := cNumNota
						SF2->F2_SERIE   := SL1->L1_SERIE
						SF2->F2_CLIENTE := SL1->L1_CLIENTE
						SF2->F2_LOJA    := SL1->L1_LOJA
						MsUnlock()
					Endif
					If cPaisloc == "BRA"
					
						cProxNum := ProxNum()
						Reclock( "SD2",.T.)
						SD2->D2_FILIAL := xFilial("SD2")
						SD2->D2_COD    := aVendas[nI,1]
						SD2->D2_UM     := aVendas[nI,5]
						SD2->D2_QUANT  := aVendas[nI,6]
						SD2->D2_VALIPI := aVendas[nI,17]
						SD2->D2_PRCVEN := aVendas[nI,07]
						SD2->D2_TOTAL  := aVendas[nI,19]
						SD2->D2_TES    := aVendas[nI,4]
						SD2->D2_CF     := aVendas[nI,9]
						SD2->D2_CLIENTE:= SL1->L1_CLIENTE
						SD2->D2_LOJA	:= SL1->L1_LOJA
						SD2->D2_DOC 	:= SL2->L2_DOC
						SD2->D2_PDV 	:= SL1->L1_PDV
						SD2->D2_EMISSAO:= dDataBase
						SD2->D2_GRUPO	:= SB1->B1_GRUPO
						SD2->D2_PESO 	:= SB1->B1_PESO 						
						SD2->D2_SERIE	:= SL1->L1_SERIE
						
						If SuperGetMV("MV_ARREFAT")== "S"
							SD2->D2_PRUNIT  := Round(aVendas[nI,23],nRndFat)
							SD2->D2_VALACRS := Round((aVendas[nI,07]-aVendas[nI,23]),nRndFat)
						Else
							SD2->D2_PRUNIT  := NoRound(aVendas[nI,23],nRndFat)
							SD2->D2_VALACRS := NoRound((aVendas[nI,07]-aVendas[nI,23]),nRndFat)
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Valor do acréscimo é igual ao preco com acréscimo - preço da tabela.   |
						//| Se for menor que 0, foi dado um desconto, portanto zera o acréscimo.   |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SD2->D2_VALACRS < 0
							SD2->D2_VALACRS := 0
						Endif
						
						SD2->D2_LOCAL	:= aVendas[nI,15]
						SD2->D2_TIPO	:= "N"
						cIteNf			:= SomaIt(cIteNF) //StrZero(nItens,2)	//SL2->L2_ITEM ver
						SD2->D2_ITEM	:= cIteNF
						SD2->D2_ITEMPV	:= SL2->L2_ITEM
						SD2->D2_IPI 	:= If( Posicione("SF4", 1, xFilial("SF4") + aVendas[nI,04], "F4_IPI") == "S", SB1->B1_IPI, 0 )
					    SD2->D2_BASEIPI	:= Lj010Ipi(SL2->L2_PRCTAB,SL2->L2_QUANT,SL2->L2_DESC,SL1->L1_DESCNF,SL2->L2_TES,nI,SL2->L2_PRODUTO, "B",SL2->L2_VALFRE,SL2->L2_SEGURO,SL2->L2_DESPESA)
						SD2->D2_TP		:= SB1->B1_TIPO
						SD2->D2_NUMSEQ 	:= cProxNum
						SD2->D2_EST 	:= SA1->A1_EST
						SD2->D2_DESCON	:= aVendas[nI,3] + aVendas[nI,22]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Evita 100% de desconto, desconto negativo e valores do tipo 0.0001                  |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SD2->D2_DESC	:= Min(Max(((SL2->L2_DESCPRO + SL2->L2_VALDESC) * 100) / (SL2->L2_PRCTAB * SL2->L2_QUANT),0.00),99.99)
						SD2->D2_CLASFIS	:= ( SubStr(SB1->B1_ORIGEM, 1, 1) + SF4->F4_SITTRIB )
						SD2->D2_ORIGLAN	:= "LO"

						If SF4->F4_ICM = "S"
							SD2->D2_PICM 	:= Lj010VerIcm(val(aVendas[nI,16]),aVendas[nI,14])
						Endif

						SD2->D2_BASEICM	:= aVendas[nI,14]
						SD2->D2_VALICM 	:= aVendas[nI,8]
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o totalizador de ICMS Diferido ³
						//³ que sera gravado no campo F2_ICMSDIF    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SF4->F4_ICMSDIF == "3" .AND. SF4->F4_PICMDIF > 0
							nIcmsDifer	+= ( NoRound(SD2->D2_BASEICM * SD2->D2_PICM / 100, 2) - SD2->D2_VALICM )
						EndIf
						
						If !lFiscal
							SD2->D2_SEGURO 	:= aVendas[nI][26]
							SD2->D2_VALFRE	:= aVendas[nI][25]
							SD2->D2_DESPESA	:= aVendas[nI][27]
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava TODOS os valores como Base, Aliquota e Valor de apuracao do PIS/COFINS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SL2->(FieldPos( "L2_VALPS2"  ))>0 .AND. SL2->(FieldPos( "L2_VALCF2"  ))>0 .AND.;
						   SL2->(FieldPos( "L2_BASEPS2" ))>0 .AND. SL2->(FieldPos( "L2_BASEPS2" ))>0 .AND.;
						   SL2->(FieldPos( "L2_ALIQPS2" ))>0 .AND. SL2->(FieldPos( "L2_ALIQCF2" ))>0 
			
							If !Empty( nScanPis := AScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_BASEPS2"} ) ) .AND. SL2->(FieldPos("L2_BASEPS2")) > 0
								SD2->&(aRelImp[nScanPis,2]) := SL2->L2_BASEPS2  
								nBasePS2  += SL2->L2_BASEPS2
							Endif
	
							If !Empty( nScanPis := AScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_VALPS2"} ) ) .AND. SL2->(FieldPos("L2_VALPS2")) > 0
								SD2->&(aRelImp[nScanPis,2]) := SL2->L2_VALPS2
								nValPS2  += SL2->L2_VALPS2
							Endif
	
							If !Empty( nScanPis := AScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_ALIQPS2"} ) ) .AND. SL2->(FieldPos("L2_ALIQPS2")) > 0
								SD2->&(aRelImp[nScanPis,2]) := SL2->L2_ALIQPS2
								
							Endif
	
							If !Empty( nScanPis := AScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_BASECF2"} ) ) .AND. SL2->(FieldPos("L2_BASECF2")) > 0
								SD2->&(aRelImp[nScanPis,2]) := SL2->L2_BASECF2   
								nBaseCF2 += SL2->L2_BASECF2
							Endif
	
							If !Empty( nScanPis := AScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_VALCF2"} ) ) .AND. SL2->(FieldPos("L2_VALCF2")) > 0
								SD2->&(aRelImp[nScanPis,2]) := SL2->L2_VALCF2      
								nValCF2 += SL2->L2_VALCF2
							Endif
							
							If !Empty( nScanPis := AScan(aRelImp,{|x| x[1]=="SD2" .AND. x[3]=="IT_ALIQCF2"} ) ) .AND. SL2->(FieldPos("L2_ALIQCF2")) > 0
								SD2->&(aRelImp[nScanPis,2]) := SL2->L2_ALIQCF2
							Endif
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Soma os totalizadores dos impostos ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SF4->F4_ISS = "S"
							SD2->D2_CODISS	:= SB1->B1_CODISS
                            If SB1->B1_ALIQISS > 0
                            	SD2->D2_ALIQISS := SB1->B1_ALIQISS
                            Else
                            	SD2->D2_ALIQISS := SuperGetMV("MV_ALIQISS")
                            EndIf
							SD2->D2_BASEISS	:= SD2->D2_TOTAL
							SD2->D2_VALISS	:= aVendas[nI,18]
							nBsISSF2		+= SD2->D2_TOTAL
							nIsSF2			+= aVendas[nI,18]
						Else
							nIcmF2  += SD2->D2_VALICM
							nBsIcmF2 += SD2->D2_BASEICM
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava numero da serial - atualizacao da localizacao  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SD2->D2_NUMSERIE   := SL2->L2_NSERIE
						SD2->D2_LOTECTL    := SL2->L2_LOTECTL
						SD2->D2_NUMLOTE    := SL2->L2_NLOTE
						SD2->D2_LOCALIZ    := SL2->L2_LOCALIZ
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³     * * * * CALCULO DO ICMS SOLIDARIO * * * * * *    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//³                  FORMA DE CALCULO                    ³
						//³  ICM   e' igual a ICM normal do produto              ³
						//³  ICMS  e' igual a ICM Solidario Calculado do Produto ³
						//³                                                      ³
						//³  nExpr         == Valor Mercadoria (com ou sem       ³
						//³                   IPI)                               ³
						//³  Base do Solidario == nExpr * (1 + margem lucro/100))³
						//³  ICMS              == Base Solidario * Aliq.interna  ³
						//³                       do Estado (17 ou 18%)          ³
						//³  RETIDO            == ICMS - ICM                     ³
						//³  Somar o RETIDO ao Valor Total da Nota Fiscal        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso Exista ICM Retido na Fonte e Cliente Tipo "S"olidario Grava ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SA1->( DbSetOrder( 1 ) )
						If cTipCliEntr $ SuperGetMv("MV_TPSOLCF") .OR. ( cTipCliEntr == "S" )
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se o conteudo de Cliente Entrega estiver preenchido, considerar³
							//³o imposto de ICMS do estado do cliente selecionado             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty( cCliEntrega ) .AND. !Empty( cLojEntrega )
								SA1->( DbSeek( xFilial( "SA1" )+SL1->L1_CLIENT+SL1->L1_LOJENT ))
							Endif

							aIcmsSol := LjIcmsSol(aVendas[nI,19],aVendas[nI,6],aVendas[nI,07])
							
							If !Empty( cCliEntrega ) .AND. !Empty( cLojEntrega )
								SA1->( DbSeek( xFilial( "SA1" )+SL1->L1_CLIENTE+SL1->L1_LOJA ))
							Endif							

							SD2->D2_BRICMS := aIcmsSol[1]
							SD2->D2_ICMSRET := aIcmsSol[2]
							nBsIcmRetF2     +=  SD2->D2_BRICMS
							nVlIcmRetF2     +=  SD2->D2_ICMSRET
						Endif
							
						If SA1->A1_RECPIS  == "S" .OR. ;
						   SA1->A1_RECCOFI == "S" .OR. ;
						   SA1->A1_RECCSLL == "S"

							aPsCsCf  := LjPsCfCs(aVendas[nI,19],aVendas[nI,6],aVendas[nI,07])
							
							nTotNFPis       += aPsCsCf[1]
							nTotNFCofins    += aPsCsCf[2]
							nTotNFCSLL      += aPsCsCf[3]
							nBasDup         += aPsCsCf[4]
						Endif
						
						If !SF4->F4_INCSOL == "N"
							nSmIcmRetF2     +=  SD2->D2_ICMSRET
						Endif

						If SD2->D2_IPI > 0
							If SuperGetMv("MV_IPIBRUT") == "S"
								nBsIPIF2 += ( SD2->D2_TOTAL + SD2->D2_DESCON )
							Else
								nBsIPIF2 += SD2->D2_TOTAL
							Endif
							nIPIF2  += SD2->D2_VALIPI
						Endif
						
						nVlmf2                   += SD2->D2_TOTAL
						nDescF2                  += SD2->D2_DESCON
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se deve calcular o valor de acrescimo a creditar do item.  |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Lj010VerCAF()
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//| Busca a taxa apenas uma vez, ou seja, se estiver zerada.                            |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nTaxaAcFin == 0
								nTaxaAcFin := Lj010TaxaCAF()
							Endif
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//| Calcula o valor do acrescimo do item proporcional ao total e o valor                |
							//| da entrada do item proporcional ao total.                                           |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nVlrAcProp := ( nVlrAcrs / SL1->L1_VLRLIQ ) * aVendas[ nI, 19 ]
							nEntItem   := ( nEntrada / SL1->L1_VLRLIQ ) * aVendas[ nI, 19 ]
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//| Calcula o valor do acrescimo a creditar do item  |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nVlrAcItem := ( aVendas[ nI, 19 ] - nVlrAcProp - nEntItem ) * ( nTaxaAcFin / 100 )
							nVlrAcItem := Min( nVlrAcProp, nVlrAcItem )
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//| Grava o valor do acrescimo a creditar  |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DbSelectArea( "SD2" )
							RecLock( "SD2", .F. )
							
							SD2->D2_VAC := nVlrAcItem
							
							MsUnlock()
							
						Endif
						
					Else
						lExibeNF := .F.
						
						Reclock( "SD2",.T.)
						SD2->D2_FILIAL := xFilial("SD2")
						SD2->D2_COD    := aVendas[nI,1]
						SD2->D2_UM     := aVendas[nI,5]
						SD2->D2_QUANT  := aVendas[nI,6]
						SD2->D2_PRCVEN := aVendas[nI,07]
						SD2->D2_TOTAL  := Round(aVendas[nI,19],nRndFat)
						SD2->D2_TES    := aVendas[nI,4]
						SD2->D2_CF     := aVendas[nI,9]
						SD2->D2_CLIENTE:= SL1->L1_CLIENTE
						SD2->D2_LOJA   := SL1->L1_LOJA
						SD2->D2_DOC    := SL2->L2_DOC
						SD2->D2_PDV    := SL1->L1_PDV
						SD2->D2_EMISSAO:= dDataBase
						SD2->D2_GRUPO  := SB1->B1_GRUPO
						SD2->D2_PESO   := SB1->B1_PESO 												
						SD2->D2_SERIE  := SL1->L1_SERIE
						If SuperGetMV("MV_ARREFAT") == "S"
							SD2->D2_PRUNIT := Round(aVendas[nI,23],nRndFat)
						Else
							SD2->D2_PRUNIT := noRound(aVendas[nI,23],nRndFat)
						EndIf
						SD2->D2_LOCAL  := aVendas[nI,15]
						SD2->D2_TIPO   := "N"
						SD2->D2_ORIGLAN:= "LO"
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Localizacoes 11/12/2000 - Marcello ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SD2->D2_CONTA   := SB1->B1_CONTA 
			            
			   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava numero da serial - atualizacao da localizacao  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SD2->D2_NUMSERIE   := SL2->L2_NSERIE
						SD2->D2_LOTECTL    := SL2->L2_LOTECTL
						SD2->D2_NUMLOTE    := SL2->L2_NLOTE
						SD2->D2_LOCALIZ    := SL2->L2_LOCALIZ
			
						cIteNf         := SomaIt(cIteNF) //StrZero(nItens,2)  //SL2->L2_ITEM ver
						SD2->D2_ITEM   := cIteNF
						SD2->D2_ITEMPV := SL2->L2_ITEM
						SD2->D2_TP     := SB1->B1_TIPO
						SD2->D2_NUMSEQ := ProxNum()
						SD2->D2_EST    := SA1->A1_EST
						SD2->D2_DESCON := Round(aVendas[nI,3] + aVendas[nI,22],nRndFat)
						If cPaisLoc == "SAL" .AND. lCredFisc .AND. SD2->D2_DESCON > 0
						   SD2->D2_DESC   := aVendas[nI,10]						
						Else
						   SD2->D2_DESC   := ((SL2->L2_DESCPRO + SL2->L2_VALDESC) * 100) / (SL2->L2_PRCTAB * SL2->L2_QUANT)
						Endif   						
						If lImpCupFis
							SD2->D2_ESPECIE := "CF"
						Else
							SD2->D2_ESPECIE := MVNOTAFIS
						EndIf
						SD2->D2_TIPODOC:= "01"						
						If !lFiscal
							SD2->D2_SEGURO 	:= aVendas[nI][26]
							SD2->D2_VALFRE	:= aVendas[nI][25]
							SD2->D2_DESPESA	:= aVendas[nI][27]
						Endif						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| incluido nas localizacoes para que fosse gravado os valores de totais no SF2        |
						//| Paulo Augusto  19/04/2000                                                           |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nVlmf2                   += SD2->D2_TOTAL
						nDescF2                  += SD2->D2_DESCON
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Recalcular os Impostos para considerar os descontos...      ³
						//³ MARISOL 22/07/99 Lucas                                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cTes := SL2->L2_TES
						If Empty(cTes)
							SB1->( DbSetOrder(1) )
							SB1->( DbSeek( xFilial("SB1")+SL2->L2_PRODUTO ) )
							
							cTes := RetFldProd(SB1->B1_COD,"B1_TS")
							
							SF4->( DbSetOrder(1) )
							SF4->( DbSeek( xFilial("SF4")+If(!Empty(SBI->BI_TS),Subs(SBI->BI_TS,1,3),cTes) ) )
						Endif
						
						RecLock("SL2",.F.)
						SL2->L2_TES := cTes
						SL2->L2_CUSTO1    := 0
						SL2->L2_CUSTO2    := 0
						MsUnlock()
						aStruSL2	:=	SL2->(DbStruct())
						DbSelectArea("SD2")
						For nY := 1 To Len(aStruSL2)
							If "L2_ALQIMP" $ aStruSL2[nY][1] .OR. "L2_BASIMP" $ aStruSL2[nY][1] .OR. "L2_VALIMP" $ aStruSL2[nY][1]
								FieldPut(FieldPos("D2_"+Alltrim(Substr(aStruSL2[nY][1],4))),SL2->(FieldGet(nY)))
							Endif
						Next nY
						aImpVarSD2	:=	Lj010SimSD2(SL2->L2_TES)
						For nY	:=	1	To	Len(aImpVarSD2[6])
							If ( nE := AScan( aImpVarSF2,{ |x| x[1] == aImpVarSD2[6][ nY ][8] } ) ) == 0
								AAdd( aImpVarSF2, { aImpVarSD2[6][nY][8], 0.00 } )
								nE := Len( aImpVarSF2 )
							Endif
							aImpVarSF2[nE,2] += aImpVarSD2[6][nY][4]
							
							If ( nE := AScan( aImpVarSF2,{ |x| x[1] == aImpVarSD2[6][ nY ][9] } ) ) == 0
								AAdd( aImpVarSF2, { aImpVarSD2[6][nY][9], 0.00 } )
								nE := Len( aImpVarSF2 )
							Endif
							aImpVarSF2[nE,2] += aImpVarSD2[6][nY][3]
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//| Alterado pelos novos padroes do SFC   |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nImpIncNota	+= aImpVarSD2[6][nY][4] * If(Subs(aImpVarSD2[6,nY,5],2,1) == "1",1,If(Subs(aImpVarSD2[6,nY,5],2,1) == "2",-1,0))
						Next nY
						
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Força o travamento, pois após sair do Lj010VERCAF ele retira a trava da tabela.     |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea( "SD2" )
					RecLock( "SD2", .F. )
					
					aEval(aVendedor, { |x,y| &("SD2->D2_COMIS"+Str(y,1)) := AvaliaComis(@aVendedor,y,SD2->D2_COD,SD2->D2_CLIENTE,SD2->D2_TOTAL) })
					
					MsUnlock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava arquivo de demandas SB3 ao gerar SD2 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					LjGrvSB3()
					
					
					If ExistTemplate("L10D2FIM")
						ExecTemplate("L10D2FIM",.F.,.F.)
					Endif
					If ExistBlock("L10D2FIM")
						ExecBlock("L10D2FIM",.F.,.F.)
					Endif
					
					If SF4->F4_ESTOQUE == "S"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Pega os 5 custos medios finais ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aCM := PegaCMAtu(SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_TIPO )
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava o custo da nota fiscal de entrada ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aCusto := GravaCusD2(aCM,SD2->D2_TIPO)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o saldo final (VFIM) com os dados do SD2           ³
						//³Verifica se ha ou nao reservas para baixar.                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lResMLoja     := (!Empty(SL2->L2_RESERVA) .AND. Empty(SL2->L2_LOJARES))
						lResOLoja     := (!Empty(SL2->L2_RESERVA) .AND. !Empty(SL2->L2_LOJARES))
						lEmpenho := Localiza( SL2->L2_PRODUTO )
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se houver reserva baixa do SC0            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lResMLoja .OR. lResOLoja
                                               
							cFilReserv := xFilial( "SC0" )                                 
							If lResOLoja      
								DbSelectArea( "SLJ" )
								DbSetOrder( 1 )
								If DbSeek( xFilial( "SLJ" ) + SL2->L2_LOJARES )
									cFilReserv := SLJ->LJ_RPCFIL
								Endif
							Endif

							DbSelectArea("SC0")
							DbSetOrder(1)
							If DbSeek(cFilReserv+SL2->L2_RESERVA+SL2->L2_PRODUTO+SL2->L2_LOCAL)
								cFilAntBk := cFilAnt
								cFilAnt   := cFilReserv
								cReserva  := SL2->L2_RESERVA

								RecLock("SL2")
								SL2->L2_RESERVA := Space( nTamL2_RES )
								MsUnlock()
								FkCommit()

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Volta o valor da quantidade de reserva em pedido (orcamento)  ³
								//³ para que a reserva possa ser baixada (cancelada)              ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								SC0->(DbSetOrder(1))	// C0_FILIAL+C0_NUM+C0_PRODUTO+C0_LOCAL
								If SC0->(DbSeek( xFilial("SC0")+cReserva+SL2->L2_PRODUTO+SL2->L2_LOCAL ))
									SC0->(RecLock("SC0",.F.))
									SC0->C0_QUANT  += SC0->C0_QTDPED
									SC0->C0_QTDPED -= SC0->C0_QUANT
									SC0->(MsUnlock())
								Endif 
				
								a430Reserv(	{3,"LJ","",cUserName,cFilReserv} ,;
											cReserva,SL2->L2_PRODUTO,SL2->L2_LOCAL,SL2->L2_QUANT,;
								{SL2->L2_NLOTE,SL2->L2_LOTECTL,SL2->L2_LOCALIZ,SL2->L2_NSERIE},{},{})
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//| na função a430Reserv, se houver reserva, ela sera baixada. Para isso foi criada a variável   |
								//| lBaixarEmp com o objetivo de setar se ainda deve ser baixado o empenho de reserva. Essa      |
								//| variável é utilizada mais adiante, na chamada da função B2AtuComD2.                          |
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								lBaixarEmp	:= .F.
								cFilAnt   := cFilAntBk
							Endif
						Endif

						If lEmpenho
						
							DbSelectArea( "SDC" )
							DbSetOrder( 1 )
							If !DbSeek( xFilial( "SDC" )	+	SL2->L2_PRODUTO	+	SL2->L2_LOCAL		+	"SL2"			+;
										SL2->L2_NUM			+	SL2->L2_ITEM	+	Space( nTamDC_SEQ )	+	SL2->L2_LOTECTL	+;
										SL2->L2_NLOTE		+   SL2->L2_LOCALIZ	+	SL2->L2_NSERIE )
							            
								GravaEmp(SL2->L2_PRODUTO, ; //-- 01.Codigo do Produto (Obrigatorio)
									SL2->L2_LOCAL, ;        //-- 02.Local             (Obrigatorio)
									SL2->L2_QUANT, ;        //-- 03.Quantidade        (Obrigatorio)
									0, ;                    //-- 04.Quantidade 2a UM  (Obrigatorio)
									SL2->L2_LOTECTL, ;      //-- 05.Lote de Controle  (Obrig. se Inf. Sub-Lote)
									SL2->L2_NLOTE, ;        //-- 06.Sub-Lote
									SL2->L2_LOCALIZ, ;      //-- 07.Localizacao
									SL2->L2_NSERIE, ;       //-- 08.Numero de Serie
									Nil, ;                  //-- 09.Ordem de Producao
									Space( nTamDC_SEQ ), ;             //-- 10.Sequencia do Empenho / Liberacao do Pedido de Venda
									SL2->L2_NUM, ;          //-- 11.Pedido de Venda
									SL2->L2_ITEM, ;         //-- 12.Item do Pedido de Venda
									"SL2",;                 //-- 13.Origem do Empenho
									Nil, ;                  //-- 14.Op original
									Nil, ;                  //-- 15.Data de Entrega do Empenho
									Nil, ;                  //-- 16.Array para o travamento dos saldos, caso nao seja informado nao havera travamento.
									.F., ;			    	//-- 17.Flag que indica se estorna empenho
									.F., ;                  //-- 18.Flag que indica se e chamada da Projecao de Estoques
									.F., ;    		        //-- 19.Flag que indica se empenha material do SB2
									.F., ;                  //-- 20.Flag que indica se grava registro no SD4
									!Empty(SL2->L2_LOTECTL+SL2->L2_NLOTE), ; //-- 21.Flag que indica se considera Lotes Vencidos
									.T., ;                  //-- 22.Flag que indica se empenha material no SB8/SBF
									.T.)                    //-- 23.Flag que indica se CRIA registros no SDC
							Endif
						Endif
							
						If lResOLoja
							cFilAntBk := cFilAnt
							cFilAnt   := cFilReserv	  
						Endif					

							B2AtuComD2(aCusto,,If(lEmpenho,{ {SL2->L2_NUM,SL2->L2_ITEM,Space( nTamDC_SEQ ),SL2->L2_QUANT,0}},NIL),((lBaixarEmp).AND.(lResMLoja .OR. lEmpenho)),,"SL2")

						If lResOLoja							
							cFilAnt   := cFilAntBk
						Endif
						
					Endif
					If cPaisLoc <> "BRA"
						If lImpCupFis
							cEspecie := "CF"
						Else
							cEspecie := MVNOTAFIS
						End
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona Array para geracao dos Livros Fiscais          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Qdo for pais Mexico nao podera ser gerado livro fiscal on-line                      |
						//| para cupom fiscal. A geracao sera feita na rotina de Factura                        |
						//| Global.                                                                             |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cPaisLoc <> "MEX" .OR. (cPaisLoc == "MEX" .AND. !lImpCupFis)
							aLivro := GetBook(@aGetBook,aImpVarSD2,"V",nTaxaMoeda,aLivro,"S",;
							          .T.,.F.)
						Endif
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gera Lancamento Contabeis a nivel de itens        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lLancPad10
							nTotal+=DetProva(nHdlPrv,"610","LOJA010",cLoteFat)
						Endif
					Endif
				Endif
				MsUnlockAll( )
			Next nI
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao de gravacao do SF2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nItens > 0 .AND. lFaturar
			If !lFiscal .OR. !lImpCupFis
				nNotaAtu ++
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
				//³ cMV_TPNRNFS for igual a "3"                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nNotaAtu > 1
					If cMV_TPNRNFS == "3"
						aAdd( aNotas, { cLojaNF,  MA461NumNf( .T., cLojaNF ) } )
					Endif
				Endif				
				cSerie := aNotas[nNotaAtu][1]
				cNumNota := aNotas[nNotaAtu][2]
                cNumNota := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamF2_DOC )              
			Endif
			
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '21) Antes da geracao do SF2')
			Endif				
			FechaSF2(	lFirst,			nICMF2,			nBsICMF2,		nIPIF2,;
						nBSIPIF2,		nVlMF2,			nBsISSF2,		nISSF2,;
						nDESCF2,		cFirst,			.T.,			@lEntrou,;
						nVlIcmRetF2,	nBsIcmRetF2,	@lImpCupFis,	nImpIncNota,;
						nMoedaCor,		nSmIcmRetF2,	aNotas,			nNotaAtu,;
						nVlrIcmFre,		cTipoDocCF,		cNumDocCF,		cClienteCF,;
						cEnderCF,		nVlrFreNota,	nVlrSegNota,	nVlrDesNota,;
						nItens,			cDocSerie, 		nBasePS2,      	nValPS2,;
						nBaseCF2,		nValCF2,		nIcmsDifer	)
						
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '22) SF2->SF2_DOC = ' + SF2->F2_DOC + Chr(13) + Chr(10) + ;
				                                            '23) SF2->SF2_SERIE = ' + SF2->F2_SERIE )
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o Arquivo de Livros Fiscais "SF3" c/Base na nova      ³
			//³ estrutura de gera‡Æo de Livro "aLivro" p/Clientes que utili-³
			//³ zam a Amarra‡Æo TesXImpostos e F¢rmula/Rotina de Apura‡Æo   ³
			//³ do Livro "F4_LIVRO"                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			if cPaisLoc <> "BRA"
 			    If Len(aLivro) > 0
					GravaLivro(@aLivro,cSerie,cNumNota)
				Endif
				DbSelectArea("SF2")
				DbSetOrder(1)
                cNumNota := PadR( StrZero(val(cNumNota),Len(cNumNota)) , nTamF2_DOC )   
				DbSeek(xFilial("SF2")+cNumNota+cSerie)
				if Found()
					If lLancPad20
						nTotal += DetProva(nHdlPrv,"620","LOJA010",cLoteFat)
						if nTotal > 0
							RecLock("SF2",.F.)
							SF2->F2_DTLANC := dDatabase
							MsUnlock()
						Endif
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar Livro Fiscal com base no Pto de Entrada.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| LUCAS 06/09/99 MARISOL ARGENTINA   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("Lj010SF3")
				ExecBlock("Lj010SF3",.F.,.F.)
			Endif
		Endif
		
		If !Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '24) Atualizando o SA1')		
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a gravacao do F2_NEXTDOC quando o parametro MV_TPNRNFS == "3"    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMV_TPNRNFS == "3" .AND. Len( aNotas ) > 1 .AND. !lImpCupFis
			nRecnoSF2 := SF2->( Recno() )
			SF2->( DbSetOrder( 1 ) )
		    For nX := 1 to Len( aNotas ) - 1
				If DbSeek( xFilial("SF2") + aNotas[nX][2] + aNotas[nX][1] )
					RecLock( "SF2", .F. )
					SF2->F2_NEXTDOC := aNotas[ nX + 1 ][2]
					SF2->( MsUnlock() )
				Endif
			Next nX 
			SF2->( dbGoTo ( nRecnoSF2 ) )
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo de PIS/COFINS/CSLL                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If ( LJPCCRet() + If( ! lpTPAbISS, 0, npValISS ) ) > 0 .AND. lAbatDinh
			nDinheiro += NoRound(( LJPCCRet() + If( ! lpTPAbISS, 0, npValISS ) ) /Len(aReceb),2 )
			lTipFin := .F.
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava‡ao da comissao do vendedor/ Gerente / Supervisor ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQParcela := Len(aReceb)
		If !lTipFin .AND. GetNewPar("MV_RTIPFIN",.F.)
			nImpostos := nQParcela
		Else
			nImpostos := 1
		EndIf
		                        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Antes da gravação dos títulos atualiza o valor do abatimento do PIS/COFINS/CSLL     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LJPCCAlt("SL", { , nTotNFPis, nTotNFCofins, nTotNFCSLL })
		
		If LJPCCRet(1) > 0
			nTotNFPis := LJPCCRet(1)
		Endif

		If LJPCCRet(2) > 0
			nTotNFCofins := LJPCCRet(2)
		Endif

		If LJPCCRet(3) > 0
			nTotNFCSLL := LJPCCRet(3)
		Endif
		
		nTotNFISS    := SL1->L1_VALISS
		If SL1->(FieldPos("L1_VALIRRF")) > 0
			nTotNFIRRF := SL1->L1_VALIRRF
		Else
			nTotNFIRRF := 0
		EndIf
		lFirstDupRec := .T.
		nNParc       := j := 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao de Contas a Receber ja' baixado ³
		//³ Foi tirada a condicao lfinanceiro para que  ³
		//³ em dinheiro E1 e E5 sejam atualizados       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If ExistBlock("LJTES",,.T.)
			lRetorno := ExecBlock("LJTES",.F.,.F.,cTes)
			If Valtype(lRetorno)<>'L' 
				lRetorno := .T.
			EndIf	
		EndIf
		
			If nDinheiro > 0 .AND. lFinanceiro .AND. lRetorno
		   		For i:=1 To nQParcela
				If IsMoney(aReceb[i][3])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cria caixa p/ tratamento multi-moeda  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lCxEstrang := .F.
					If cPaisLoc <> "BRA" .AND. aPgtos[i][4] > 1
						lCxEstrang := .T.
						VerifCaixa(aPgtos[i][4],xNumCaixa())
					Endif
					nNParc++
					j:=j+1
					nDecs := MsDecimais(aPgtos[i][4])
					Reclock( "SE1",.T.)
					SE1->E1_FILIAL	:= cFilial
					SE1->E1_PREFIXO	:= SF2->F2_PREFIXO
					SE1->E1_NUM		:= SL1->L1_DOC
					SE1->E1_EMISSAO	:= dDataBase
					SE1->E1_EMIS1	:= dDataBase
					SE1->E1_PORTADO	:= xNumCaixa()
					SE1->E1_CONTA	:= ".         "
					SE1->E1_PARCELA	:= " "       // "A"					
					If !lCxEstrang
						SE1->E1_AGEDEP  := ".    "
					Else
						SE1->E1_AGEDEP  := SuperGetMV("MV_SIMB"+AllTrim(Str(aPgtos[i][4])))
					Endif
					If cPaisLoc == "BRA"
						SE1->E1_VALOR	 := nDinheiro
						SE1->E1_VLRREAL  := nDinheiro
						SE1->E1_VLCRUZ  := nDinheiro
					Else
						SE1->E1_VALOR	 := Round(aPgtos[i][2],nDecs)
						SE1->E1_VLRREAL   :=Round(aPgtos[i][2],nDecs)
						SE1->E1_VLCRUZ  := Round(xMoeda(aPgtos[i][2],aPgtos[i][4],1,SE1->E1_EMISSAO,nRndMoed1+1,If(nMoedaCor == aPgtos[i][4],nTaxaMoeda,0)),nRndMoed1)
						SE1->E1_PARCELA  := LJParcela( j, c1DUP )						
					Endif
					SE1->E1_VENCTO  := aReceb[i,1]
					SE1->E1_VENCREA := DataValida(SE1->E1_VENCTO,.T.)
					SE1->E1_CLIENTE := SA1->A1_COD
					SE1->E1_NOMCLI  := SA1->A1_NREDUZ
					SE1->E1_TIPO	 := SuperGetMV("MV_SIMB"+Ltrim(Str(aPgtos[i][4])))
					SE1->E1_VENCORI := SE1->E1_VENCTO
					SE1->E1_SITUACA := IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM,SuperGetMV("MV_SIMB"+Ltrim(Str(aPgtos[i][4]))),xNumCaixa()),"0")
					SE1->E1_SALDO	 := 0
					SE1->E1_MOEDA   := aPgtos[i][4]
					SE1->E1_NATUREZ := &(SuperGetMV("MV_NATDINH"))
					SE1->E1_LOJA	 := SL1->L1_LOJA
					SE1->E1_NUMNOTA := SL1->L1_DOC
					SE1->E1_SERIE	 := SL1->L1_SERIE
					SE1->E1_FILORIG := cFilAnt
					SE1->E1_HIST	 := STR0027 				 // VENDA EM DINHEIRO
					SE1->E1_STATUS  := "B"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos          |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SED")
					DbSetOrder(1)
					DbSeek(xFilial("SED")+SE1->E1_NATUREZ)            
			
					If SED->ED_CALCISS=="S"
						SE1->E1_ISS     := NoRound(( nTotNFISS / nImpostos ), 2)
						nRestISS        += SE1->E1_ISS
						If i == nImpostos
							SE1->E1_ISS += ( nTotNFISS - nRestISS )
							nTotNFISS   := nRestISS := 0
						Endif
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetuar o calculo do IRRF conforme natureza         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE1->E1_IRRF := NoRound(nTotNFIRRF/nImpostos,2)
					nRestIRRF += SE1->E1_IRRF
					If i == nImpostos
						SE1->E1_IRRF += nTotNFIRRF - nRestIRRF
						nTotNFIRRF  := nRestIRRF := 0
					Endif
					SE1->E1_VEND1	:= SL1->L1_VEND			//Vendedor do cabecalho
					SE1->E1_COMIS1	:= SL1->L1_COMIS		//Comissao do vendedor do cabecalho
					SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ		//Base de comissao do vendedor

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Desconta Frete da base de calculo, caso esteja setado no cadastro de vendedores³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SA3->(DbSetOrder(1))
					If SA3->(DbSeek(xFilial("SA3")+SL1->L1_VEND))
						If ( SA3->A3_FRETE == "N" )
							nRatFrete		:= NoRound(SL1->L1_FRETE*SE1->E1_VLCRUZ/nLiq,nDecimal)
							SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ - nRatFrete
						Endif
					Endif

					SE1->E1_BAIXA	:= dDataBase
					SE1->E1_VALLIQ	:= SE1->E1_VALOR
					SE1->E1_ORIGEM	:= "LOJA010"
					SE1->E1_MULTNAT	:= "2"
					SE1->E1_FLUXO	:= "S"
					SE1->E1_NRDOC	:= cReq
					
					If cPaisLoc == "BRA" .AND. lFirstDupRec
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calculo para o valor do PIS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE1->E1_PIS := NoRound(nTotNFPis/nImpostos,2)
						nRestNFPis  += SE1->E1_PIS
						If i == nImpostos
							SE1->E1_PIS += nTotNFPis-nRestNFPis
							nTotNFPis  := nRestNFPis := 0
						Endif
						
						If SE1->(FieldPos("E1_SABTPIS")) > 0
							Replace SE1->E1_SABTPIS With SE1->E1_PIS
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calculo para o valor do Cofins³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE1->E1_COFINS := NoRound(nTotNFCofins/nImpostos,2)
						nRestNFCofins += SE1->E1_COFINS
						If i == nImpostos
							SE1->E1_COFINS += nTotNFCofins-nRestNFCofins
							nTotNFCofins  := nRestNFCofins := 0
						Endif
						
						If SE1->(FieldPos("E1_SABTCOF")) > 0
							Replace SE1->E1_SABTCOF With SE1->E1_COFINS
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calculo para o valor do CSLL  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE1->E1_CSLL := NoRound(nTotNFCSLL/nImpostos,2)
						nRestNFCSLL += SE1->E1_CSLL
						If i == nImpostos
							SE1->E1_CSLL += nTotNFCSLL-nRestNFCSLL
							nTotNFCSLL  := nRestNFCSLL := 0
						Endif

						If SE1->(FieldPos("E1_SABTCSL")) > 0
							Replace SE1->E1_SABTCSL With SE1->E1_CSLL
						Endif

					Endif
					
					SE1->( MsUnlock())
					
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '26) Gravacao do SE1  = ' + SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO )
					Endif						
					AAdd( aRegSE1, SE1->(Recno()) )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualizacao de titulos a receber, gerando todos os dados³
					//³complementares a uma implantacao de titulo.             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					A040DupRec(FunName(),(i == 1), nBasDup, ( LJPCCRet() > 0 ), lpTPAbISS, .F.)
						
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "26.1) Executou A040DupRec()")
					Endif
					MsUnlockAll()
					
					If lFirstDupRec
						If !Intransact()
							SF2->( RecLock("SF2", .F.) )
						Endif

						If !Empty(LOG_TEF)
							LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "26.2) Executou Lj010AtuSF2()" )
						Endif
						
						SF2->F2_VALPIS  += SE1->E1_PIS
						SF2->F2_VALCSLL += SE1->E1_CSLL
						SF2->F2_VALCOFI += SE1->E1_COFINS
						SF2->F2_VALIRRF += SE1->E1_IRRF
						SF2->( MsUnlock() )
						                         
						If lTipFin .OR. !GetNewPar("MV_RTIPFIN",.F.)
							lFirstDupRec := .F.
						Endif
					Endif
					
					If cPaisLoc <> "BRA"
						If !Empty(SE1->E1_PORTADO)
							SA6->(DbSetOrder(1))
							If SA6->(DbSeek( xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
								nMoedaBco := Max(SA6->A6_MOEDA,1)
								nRndBco := MsDecimais(nMoedaBco)
							Endif
						Endif
					Endif

					If SF2->F2_VALPIS + SF2->F2_VALCSLL + SF2->F2_VALCOFI > 0 .OR. npValISS > 0
					
						cCliAbat     := SE1->E1_CLIENTE
						cLojAbat     := SE1->E1_LOJA
						cPrefAbat    := SE1->E1_PREFIXO
						cNumAbat     := SE1->E1_NUM
						cParcelaAbat := SE1->E1_PARCELA
						cLoteAbat    := SE1->E1_LOTE
						
						aAliasSE1 := SE1->( GetArea() )

						nTotAbat := SumAbatRec(cPrefAbat,cNumAbat,cParcelaAbat,1,"S",dDataBase)
						If Select( "__SE1" ) <> 0
							DbSelectArea( "__SE1" )							
							dbCloseArea()
						Endif

						If !Empty(LOG_TEF)
							LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "26.3) Executou SumAbatRec()" )
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Apos rodar a funcao acima "SumAbatRec", o alias __SE1 eh criado                     |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SE1")
						SE1->(DbSetOrder(2))
						SE1->(DbSeek(xFilial("SE1")+cCliAbat+cLojAbat+cPrefAbat+cNumAbat+cParcelaAbat))
						
						While !EOF() .AND. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA == ;
										   xFilial( "SE1" )+cCliAbat+cLojAbat+cPrefAbat+cNumAbat+cParcelaAbat
										   
							IF E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT+"/"+MVPIABT+"/"+;
								MVCFABT+"/"+MVCSABT   
								cBaixaAbat   := E1_BAIXA
								RecLock( "SE1",.F. )
								Replace E1_SALDO	  With 0
								Replace E1_BAIXA	  With If(cBaixaAbat <= dDataBase, dDataBase, cBaixaAbat)
								Replace E1_LOTE	      With cLoteAbat
								Replace E1_MOVIMEN    With dDataBase
								Replace E1_STATUS     With "B"
								Replace E1_SDACRES    With 0
								Replace E1_SDDECRE    With 0
								MsUnlock()
							Endif
							DbSkip()
							
						End
						SE1->(DbSetOrder(1))
						
						RestArea( aAliasSE1 )
	
	     			Endif
	     			
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "26.4) Posicionando no SE1("+Str(aRegSE1[Len(aRegSE1)])+") = "+SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO )
					Endif
	     			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| A funcao A040DUPREC Abre o titulo porque não foi gerado o SE5 para ele, sendo assim |
					//| forco a baixa e recalculo dos abatimentos                                           |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea( "SE1" )
					DbGoto( aRegSE1[Len(aRegSE1)] )
					RecLock( "SE1", .F. )
					Replace E1_SALDO   With 0
					Replace E1_BAIXA   With If(E1_BAIXA <= dDataBase, dDataBase, E1_BAIXA)
					Replace E1_MOVIMEN With dDataBase
					Replace E1_STATUS  With "B"
					Replace E1_VALLIQ  With E1_VALOR - nTotAbat
                    MsUnlock() 
                    
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "26.5) Iniciando gravacao do SE5" )
					Endif
                    
					DbSelectArea( "SE5" )  
					
					Reclock("SE5" , .T. )
					SE5->E5_FILIAL  := xFilial("SE5")
					SE5->E5_FILORIG := SE1->( xFilial( "SE1" ))
					SE5->E5_TIPODOC := "LJ"   // Dinheiro (Caixa) "VL"
					If cPaisLoc == "BRA"
						SE5->E5_VALOR	 := SE1->E1_VALOR - nTotAbat
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Deve converter a partir do valor do SL1 devido ao problema de arredondamento na conversao para o SE1 |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE5->E5_VALOR	 := Round(xMoeda(aPgtos[i][2],aPgtos[i][4],nMoedaBco,dDataBase,nRndBco+1,If(aPgtos[i][4]==nMoedaCor,nTaxaMoeda,0),If(nMoedaBco==nMoedaCor,nTaxaMoeda,0)),nRndBco)
						SE5->E5_MOEDA	 :=	StrZero(nMoedaBco,2)
						SE5->E5_VLMOED2	 :=	SE1->E1_VALOR
					Endif
					SE5->E5_BANCO	:= xNumCaixa()
					If cPaisLoc == "BRA"
						SE5->E5_AGENCIA := "."
						SE5->E5_DATA    := dDataBase
					Else
						SE5->E5_AGENCIA := SE1->E1_AGEDEP
						SE5->E5_DATA    := aPgtos[i][5]
					EndIf
					SE5->E5_CONTA	:= "."
					SE5->E5_DTDIGIT	:= dDataBase
					SE5->E5_DTDISPO	:= SE1->E1_EMISSAO
					SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
					SE5->E5_NUMERO	:= SE1->E1_NUM
					SE5->E5_PARCELA	:= SE1->E1_PARCELA
					SE5->E5_TIPO	:= SE1->E1_TIPO
					SE5->E5_SEQ		:= "01"
					SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
					SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
					SE5->E5_CLIENTE	:= SE1->E1_CLIENTE
					SE5->E5_LOJA	:= SE1->E1_LOJA
					SE5->E5_RECPAG	:= "R"
					SE5->E5_HISTOR	:= STR0028 				 // BAIXA REF VENDA EM DINHEIRO
					SE5->E5_MOTBX	:= "NOR"
					MsUnlock()
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '27) Gravacao do SE5  = ' + SE5->E5_FILIAL+DTOS(SE5->E5_DATA)+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ )
					Endif						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza saldo do BANCO Caixa ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,;
					SE5->E5_DTDISPO,SE5->E5_VALOR,"+")
										
				Endif
			Next i
		Endif
		j:=0
		If nCheques > 0 .AND. lFinanceiro;
			.AND. If(ExistBlock("LJTES",,.T.),ExecBlock("LJTES",.F.,.F.,cTes),.T.)
			For i:=1 To nQParcela
				If cSimbCheq $ Trim(aReceb[i][3])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cria caixa p/ tratamento multi-moeda  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lCxEstrang := .F.
					If cPaisLoc <> "BRA" .AND. aPgtos[i][4] > 1
						lCxEstrang := .T.
						VerifCaixa(aPgtos[i][4],xNumCaixa())
					Endif
					
					nNParc++
					j:=j+1
					cBanco			  := aReceb[i][4]
					cNumCheque		  := aReceb[i][5]
					cConta			  := aReceb[i][6]
					cAgencia 		  := aReceb[i][7]
					cRG				  := aReceb[i][8]
					cTelefone		  := aReceb[i][9]
					nValorCheque	  := aReceb[i][2]
					dDataVencto 	  := aReceb[i][1]
					nDecs             := MsDecimais(aPgtos[i][4])
					Reclock( "SE1",.T.)
					SE1->E1_FILIAL   := cFilial
					SE1->E1_PREFIXO  := SF2->F2_PREFIXO
					SE1->E1_NUM 	  := SL1->L1_DOC
					SE1->E1_PORTADO  := xNumCaixa()
					If cPaisloc=="BRA"
						SE1->E1_EMISSAO	:= dDataBase
						SE1->E1_EMIS1 	:= dDataBase
					Else
						SE1->E1_EMISSAO	:= aPgtos[i][5]
						SE1->E1_EMIS1 	:= aPgtos[i][5]
					EndIf
					SE1->E1_CONTA	  := ".         "
					If !lCxEstrang
						SE1->E1_AGEDEP   := ".    "
					Else
						SE1->E1_AGEDEP  := SuperGetMV("MV_SIMB"+AllTrim(Str(aPgtos[i][4])))
					Endif
					SE1->E1_PARCELA  := LJParcela( j, c1DUP )
					If cPaisLoc == "BRA"
						SE1->E1_VALOR    := nValorCheque
						SE1->E1_VLRREAL  := nValorCheque
						SE1->E1_SALDO    := nValorCheque
						SE1->E1_VLCRUZ   := nValorCheque
					Else
						SE1->E1_VALOR    := Round(aPgtos[i][2],nDecs)
						SE1->E1_VLRREAL  := Round(aPgtos[i][2],nDecs)
						SE1->E1_SALDO    := Round(aPgtos[i][2],nDecs)
						SE1->E1_VLCRUZ   := Round(xMoeda(aPgtos[i][2],aPgtos[i][4],1,SE1->E1_EMISSAO,nRndMoed1+1,If(nMoedaCor == aPgtos[i][4],nTaxaMoeda,0)),nRndMoed1)
					Endif
					SE1->E1_MOEDA    := aPgtos[i][4]
					SE1->E1_VENCTO   := dDataVencto
					SE1->E1_VENCREA  := DataValida(dDataVencto,.T.)
					SE1->E1_CLIENTE  := SL1->L1_CLIENTE
					SE1->E1_NOMCLI   := SA1->A1_NREDUZ
					SE1->E1_TIPO	  := cSimbCheq
					SE1->E1_VENCORI  := dDataVencto
					SE1->E1_SITUACA  := IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM,cSimbCheq,xNumCaixa()),"0")
					SE1->E1_NATUREZ  := &(SuperGetMV("MV_NATCHEQ"))
					SE1->E1_LOJA	  := SL1->L1_LOJA
					SE1->E1_NUMNOTA  := SL1->L1_DOC
					SE1->E1_SERIE	  := SL1->L1_SERIE
					SE1->E1_FILORIG := cFilAnt
					SE1->E1_STATUS  := "A"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos			|		
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SED")
					DbSetOrder(1)
					DbSeek(xFilial("SED")+SE1->E1_NATUREZ)            
					
					If SED->ED_CALCISS=="S"					
						SE1->E1_ISS     := NoRound(( nTotNFISS / nImpostos ), 2)
						nRestISS        += SE1->E1_ISS
						If i == nImpostos
							SE1->E1_ISS += ( nTotNFISS - nRestISS )
							nTotNFISS   := nRestISS := 0
						Endif
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetuar o calculo do IRRF conforme natureza         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE1->E1_IRRF := NoRound(nTotNFIRRF/nImpostos,2)
					nRestIRRF += SE1->E1_IRRF
					If i == nImpostos
						SE1->E1_IRRF += nTotNFIRRF - nRestIRRF
						nTotNFIRRF  := nRestIRRF := 0
					Endif
					
					SE1->E1_BCOCHQ  := cBanco
					SE1->E1_AGECHQ  := cAgencia
					SE1->E1_CTACHQ  := cConta
					If cPaisLoc == "PAR" .AND. SE1->(FieldPos("E1_NUMCHQ")) > 0
					   SE1->E1_NUMCHQ := cNumCheque
					Endif					
					SE1->E1_VEND1	:= SL1->L1_VEND			//Vendedor do cabecalho
					SE1->E1_COMIS1	:= SL1->L1_COMIS		//Comissao do vendedor do cabecalho
					SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ		//Base de comissao do vendedor

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Desconta Frete da base de calculo, caso esteja setado no cadastro de vendedores³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SA3->(DbSetOrder(1))
					If SA3->(DbSeek(xFilial("SA3")+SL1->L1_VEND))
						If ( SA3->A3_FRETE == "N" )
							nRatFrete		:= NoRound(SL1->L1_FRETE*SE1->E1_VLCRUZ/nLiq,nDecimal)
							SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ - nRatFrete
						Endif
					Endif

					SE1->E1_ORIGEM	:= "LOJA010"
					SE1->E1_MULTNAT	:= "2"
					SE1->E1_FLUXO	:= "S"
					SE1->E1_NRDOC := cReq
					
					If cPaisLoc == "BRA" .AND. lFirstDupRec

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calculo para o valor do PIS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE1->E1_PIS := NoRound(nTotNFPis/nImpostos,2)
						nRestNFPis  += SE1->E1_PIS
						If i == nImpostos
							SE1->E1_PIS += nTotNFPis-nRestNFPis
							nTotNFPis  := nRestNFPis := 0
						Endif

						If SE1->(FieldPos("E1_SABTPIS")) > 0
							Replace SE1->E1_SABTPIS With SE1->E1_PIS
						Endif
										
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calculo para o valor do Cofins³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE1->E1_COFINS := NoRound(nTotNFCofins/nImpostos,2)
						nRestNFCofins += SE1->E1_COFINS
						If i == nImpostos
							SE1->E1_COFINS += nTotNFCofins-nRestNFCofins
							nTotNFCofins  := nRestNFCofins := 0
						Endif                             

						If SE1->(FieldPos("E1_SABTCOF")) > 0
							Replace SE1->E1_SABTCOF With SE1->E1_COFINS
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calculo para o valor do CSLL  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						SE1->E1_CSLL := NoRound(nTotNFCSLL/nImpostos,2)
						nRestNFCSLL += SE1->E1_CSLL
						If i == nImpostos
							SE1->E1_CSLL += nTotNFCSLL-nRestNFCSLL
							nTotNFCSLL  := nRestNFCSLL := 0
						Endif

						If SE1->(FieldPos("E1_SABTCSL")) > 0
							Replace SE1->E1_SABTCSL With SE1->E1_CSLL
						Endif

					Endif
					
					MsUnlock( )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualizacao de titulos a receber, gerando todos os dados³
					//³complementares a uma implantacao de titulo.             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					A040DupRec(FunName(),(i == 1), nBasDup, ( LJPCCRet() > 0 ), lpTPAbISS)
					
					MsUnlockAll()
					If lFirstDupRec
						If !Intransact()
							SF2->( RecLock("SF2", .F.) )
						Endif
                        
						SF2->F2_VALPIS  += SE1->E1_PIS
						SF2->F2_VALCSLL += SE1->E1_CSLL
						SF2->F2_VALCOFI += SE1->E1_COFINS
						SF2->F2_VALIRRF += SE1->E1_IRRF
						SF2->( MsUnlock() )

						If lTipFin .OR. !GetNewPar("MV_RTIPFIN",.F.)
							lFirstDupRec := .F.
						Endif
					Endif

					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '28) Gravacao do SE1  = ' + SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO )
					Endif						

					AAdd( aRegSE1, SE1->(Recno()) )
				Endif
			Next i
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao de Cheques ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		j:=0
		If nCheques > 0 .AND. lFinanceiro;
			.AND. If(ExistBlock("LJTES",,.T.),ExecBlock("LJTES",.F.,.F.,cTes),.T.)

			SA1->( DbSetOrder(1) )
			SA1->( DbSeek(xFilial("SA1")+SL1->L1_Cliente+SL1->L1_Loja) )
			
			For i:=1 To Len(aReceb)
				If cSimbCheq $ Trim(aReceb[i][3])
					j:=j+1
					cBanco       := aReceb[i][4]
					cNumCheque   := aReceb[i][5]
					cAgencia     := aReceb[i][6]
					cConta       := aReceb[i][7]
					cRG          := aReceb[i][8]
					cTelefone    := aReceb[i][9]
					cComp        := aReceb[i][18]
					nValorCheque := aReceb[i][2]
					dDataVencto  := aReceb[i][1]

					Reclock( "SEF" , .T. )
					SEF->EF_FILIAL	:= cFilial
					SEF->EF_NUM		:= cNumCheque
					SEF->EF_BANCO	:= cBanco
					SEF->EF_AGENCIA	:= cAgencia
					SEF->EF_CONTA	:= cConta
					SEF->EF_VALOR	:= nValorCheque
					SEF->EF_DATA	:= dDataBase
					SEF->EF_VENCTO	:= dDataVencto
					SEF->EF_BENEF	:= SM0->M0_NOMECOM
					SEF->EF_CART	:= "R"
					SEF->EF_TEL		:= cTelefone
					SEF->EF_RG		:= cRG
					SEF->EF_NUMNOTA	:= SL1->L1_DOC
					SEF->EF_SERIE	:= SL1->L1_SERIE
					SEF->EF_TITULO	:= SL1->L1_DOC
					SEF->EF_CLIENTE	:= SE1->E1_CLIENTE
					SEF->EF_LOJACLI	:= SE1->E1_LOJA
					SEF->EF_PREFIXO	:= SF2->F2_PREFIXO
					SEF->EF_TIPO	:= cSimbCheq
					SEF->EF_TERCEIR	:= aReceb[i][10]
					SEF->EF_HIST	:= ""    // para rdmake
					If SuperGetMV("MV_1DUP") == "1"
						SEF->EF_PARCELA	:= Str(j,1)
					Else
						SEF->EF_PARCELA	:= Chr(j+64)
					EndIf
					If cPaisLoc == "BRA"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Para uso de TEF ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SEF->EF_GARANT   := cGaranCh  
					EndIf

					SEF->EF_COMP := cComp
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Gravação dos dados do cliente no cheque  |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SEF->EF_CLIENTE := SA1->A1_COD
					SEF->EF_LOJACLI := SA1->A1_LOJA
					SEF->EF_CPFCNPJ := SA1->A1_CGC
					SEF->EF_EMITENT := If( aReceb[i,10], If(Empty(aReceb[i,16]),SA1->A1_NOME,aReceb[i,16]), SA1->A1_NOME ) 
					
					MsUnlock()
				Endif
			Next i
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao de Contas a Receber VA-CC-CO-CD-FI ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nValorCart > 0 .OR. nValorVale > 0 .OR. nValorConv > 0 .OR. nValorDebi > 0 .OR.;
			nValorFin > 0) .AND. lFinanceiro .AND.;
			If(ExistBlock("LJTES",,.T.),ExecBlock("LJTES",.F.,.F.,cTes),.T.)

			nValorBase -= (nDinheiro + nCheques)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Classifica o Array aReceb, em ordem de:                                           ³
			//³Forma de Pagamento + Administradora + Data de Vencimento, para efetuar a quebra do³
			//³titulo, caso a Administradora seja diferente entre as parcelas.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aSort(aReceb,,,{|x,y| 	x[3] + x[4] + DtoS(x[1]) <;
						 			y[3] + y[4] + DtoS(y[1])})

			For i := 1 To Len(aReceb)

				If !(AllTrim(aReceb[i][3]) $ "CC|VA|CO|CD|FI")
					Loop
				EndIf

				cSeek	:=	xFilial("SE1") 	+ PadR(SF2->F2_PREFIXO, nTamE1_PRE ) + SL1->L1_DOC + ;
							cParcela 		+ aReceb[i][3]

				nDecs	:=	MsDecimais(aReceb[i][11])

				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA))

			    SAE->(DbSetOrder(1))
				SAE->(DbSeek(xFilial("SAE") + Substr(aReceb[i][4],1,nTamAE_COD)))

				If SE4->E4_JURCART == "1" .OR. SAE->AE_FINPRO == "N"
					lJurAdm  := .T.
				Else 
					lJurAdm  := .F.
				Endif
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a Administradora for diferente         ³
				//³da parcela anterior, gera um novo titulo. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				lAdmin := .F.
				
				If i > 1
					If 	aReceb[i][4] <> aReceb[i - 1][4]
	    		        lAdmin 		:= .T.
			  		EndIf
			  	EndIf

				If 	lJurAdm .AND. !lAdmin .AND. SE1->(DbSeek(cSeek))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gerar so um titulo, juros pago pela administradora ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Reclock( "SE1",.F.)
                    SE1->E1_VALOR	+= Round(xMoeda	(nValor, 	nMoedaCor, 		aReceb[i][11], 	dDatabase,;
                    								 nDecs+1,	nTaxaMoeda) - ;
                    						(xMoeda(nValor,		nMoedaCor,		aReceb[i][11], dDatabase,;
                    								nDecs+1,	nTaxaMoeda) * ;
                    						(SAE->AE_TAXA / 100)), nDecs)
					SE1->E1_SALDO	:= SE1->E1_VALOR
					SE1->E1_VLRREAL	+= Round(xMoeda	(nValor,	nMoedaCor,		aReceb[i][11],	dDatabase,;
													 nDecs+1,	nTaxaMoeda),	nDecs)
					SE1->E1_VLCRUZ	:= Round(xMoeda	(	SE1->E1_SALDO,;
														SE1->E1_MOEDA,;
														1,;
														SE1->E1_EMISSAO,;
													 	nRndMoed1+1,;
													 	If (SE1->E1_MOEDA==nMoedaCor,nTaxaMoeda,0);
													 	),nRndMoed1)

					SE1->E1_VALJUR	+= Round(SE1->E1_VALOR * (nPerJur / 100),2)
                           
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos          |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SED")
					DbSetOrder(1)
					DbSeek(xFilial("SED")+cNatureza)
					
					If SED->ED_CALCISS=="S"
						SE1->E1_ISS     += NoRound(( nTotNFISS / nImpostos ), 2)
						nRestISS        += NoRound(( nTotNFISS / nImpostos ), 2)
						
						If i == nImpostos
							SE1->E1_ISS += ( nTotNFISS - nRestISS )
							nTotNFISS   := nRestISS := 0
						Endif                           
					Endif
					nTotTaxa := SE1->E1_VLRREAL - SE1->E1_VALOR

				Else

					If AllTrim(aReceb[i,3]) == "VA"
						va++
						cParcela	:= LJParcela( va, c1DUP )
						nValorVale	:= aReceb[i][2] - (aReceb[i][2] * SAE->AE_TAXA / 100)
						cNatureza	:= SuperGetMV("MV_NATVALE")
						nValor		:= aReceb[i][2]

					ElseIf AllTrim(aReceb[i,3]) == "CC"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso o juros do cartao de credito parcelado for calculado pela ³
						//³ Administradora, gera apenas um titulo com o valor total, caso  ³
						//³ contrario gera os titulos de acordo com o num de parcelas.	   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cc++
						cParcela	:= LJParcela( cc, c1DUP )
						nValorCart	:= aReceb[i][2] - (aReceb[i][2] * SAE->AE_TAXA / 100)
						cNatureza	:= SuperGetMV("MV_NATCART")
						nValor		:= aReceb[i][2]

					ElseIf AllTrim(aReceb[i,3]) == "CD"
						cc++
						cParcela	:= LJParcela( cc, c1DUP )
						nValorDebi	:= aReceb[i][2] - (aReceb[i][2] * SAE->AE_TAXA / 100)
						cNatureza	:= SuperGetMV("MV_NATTEF")
						nValor		:= aReceb[i][2]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se MV_NATTEF Iniciar com & passo o conteudo apartir do segundo byte para ser expandido via macro,  ³
						//³ senao passo o label para na expansao pegar o conteudo                                              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Substr(cNatureza,1,1) == "&"
							cNatureza := Substr(cNatureza,2,Len(cNatureza))
						Else
							cNatureza := 'SuperGetMV("MV_NATTEF")'
						EndIf

					ElseIf AllTrim(aReceb[i,3]) == "CO"
						co++
						cParcela	:= LJParcela( co, c1DUP )
						nValorConv	:= aReceb[i][2] - (aReceb[i][2] * SAE->AE_TAXA / 100)
						cNatureza	:= SuperGetMV("MV_NATCONV")
						nValor		:= aReceb[i][2]

					ElseIf AllTrim(aReceb[i,3]) == "FI"
						nFi++
						cParcela	:= LJParcela( nFi, c1DUP )
						nVlrFin		:= aReceb[i][2] - (aReceb[i][2] * SAE->AE_TAXA / 100)
						cNatureza	:= SuperGetMV("MV_NATFIN")
						nValor		:= aReceb[i][2]
					Endif

					If lJurAdm
						If Empty(SAE->AE_DIAS)
							dSaeDias := dDataBase
						Else
							If Month(dDataBase) == 2 .AND. SAE->AE_DIAS > 28
								dSaeDias := LastDay(CtoD( "01/02/" + Right(StrZero(Year(dDataBase),4),2),"ddmmyy"))
							Else
								dSaeDias :=	CtoD(StrZero(SAE->AE_DIAS,2) + "/" + StrZero(Month(dDataBase),2) + "/" +;
											Right(StrZero(Year(dDataBase),4),2),"ddmmyy")
							Endif
							If Empty(dSaeDias)
								dSaeDias :=	LastDay(CtoD("01/" + StrZero(Month(dDataBase),2) + "/" +;
											Right(StrZero(Year(dDataBase),4),2),"ddmmyy"))
							Endif
						Endif
						If Empty(SAE->AE_VENCTO)
							dSaeVencto := dDatabase + SAE->AE_DIAS
						Else
							If Month(dDataBase) == 2 .AND. SAE->AE_VENCTO > 28
								dSaeVencto := LastDay(CtoD("01/02/" + Right(StrZero(Year(dDataBase),4),2),"ddmmyy"))
							Else
								dSaeVencto :=	CtoD(StrZero(SAE->AE_VENCTO,2) + "/" + StrZero(Month(dDataBase),2) +;
												"/" + Right(StrZero(Year(dDataBase),4),2),"ddmmyy")
							Endif
					
							If Empty( dSaeVencto )
								dSaeVencto :=	LastDay(CtoD("01/" + StrZero(Month(dDataBase),2) + "/" +;
												Right(StrZero(Year(dDataBase),4),2),"ddmmyy"))
							Endif					
						Endif
						If (dSaeDias > dSaeVencto .OR. dDataBase > dSaeDias) .AND. ! Empty(SAE->AE_VENCTO)
							If Month(lastday(dSaeVencto)+1) == 2 .AND. SAE->AE_VENCTO > 28
								dSaeVencto := 	LastDay(CtoD("01/02/" +;
												Right(StrZero(Year(lastday(dSaeVencto) + 1),4),2),"ddmmyy"))
							Else
								dSaeVencto :=	CtoD(StrZero(SAE->AE_VENCTO,2) + "/" +;
												StrZero(Month(lastday(dSaeVencto)+1),2) + "/" +;
												Right(StrZero(Year(lastday(dSaeVencto)+1),4),2),"ddmmyy")
							Endif
					
							If Empty( dSaeVencto )
								dSaeVencto :=	LastDay(CtoD("01/" + StrZero(Month(dDataBase),2) + "/" +;
												Right(StrZero(Year(dDataBase),4),2),"ddmmyy"))
							Endif					
						Endif

					EndIf

					nNParc++

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cria caixa p/ tratamento multi-moeda  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lCxEstrang := .F.
					If cPaisLoc <> "BRA" .AND. aReceb[i][11] > 1
						lCxEstrang := .T.
						VerifCaixa(aReceb[i][11],xNumCaixa())
					Endif				

					Reclock( "SE1",.T.)
					SE1->E1_FILIAL	:= xFilial("SE1")
					SE1->E1_PREFIXO	:= SF2->F2_PREFIXO
					SE1->E1_NUM		:= SL1->L1_DOC
					SE1->E1_VALOR	:= Round(xMoeda(	nValor,;
														nMoedaCor,;
														aReceb[i][11],;
														dDatabase,;
														nDecs+1,;
														nTaxaMoeda) -;
											(xMoeda(	nValor,;
														nMoedaCor,;
														aReceb[i][11],;
														dDatabase,;
														nDecs+1,;
														nTaxaMoeda) * ;
														SAE->AE_TAXA / 100),nDecs)
					SE1->E1_VLRREAL	:= Round(xMoeda(	nValor,;
														nMoedaCor,;
														aReceb[i][11],;
														dDatabase,;
														nDecs+1,;
														nTaxaMoeda),nDecs)
					SE1->E1_PARCELA	:= cParcela
					SE1->E1_TIPO	:= aReceb[i,3]
					
					If AllTrim(aReceb[i,3]) == "FI" .AND. ExistBlock("LJGRVPAR")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Permite customizacao para utilizar mais de 35 parcelas                              |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aGrvPar := 	ExecBlock("LJGRVPAR",.F.,.F.,{SE1->E1_PARCELA,SE1->E1_TIPO})
						SE1->E1_PARCELA	:= aGrvPar[1]
						SE1->E1_TIPO	:= aGrvPar[2]
					Endif

					SE1->E1_PORTADO := xNumCaixa()

					If !lCxEstrang
						SE1->E1_AGEDEP  := ".    "
					Else
						SE1->E1_AGEDEP  := SuperGetMV("MV_SIMB" + AllTrim(Str(aReceb[i][11])))
					Endif

					SE1->E1_CONTA	 := ".         "

					If Empty(SL1->L1_EMISNF)
						REPLACE SE1->E1_EMISSAO	With dDatabase
						REPLACE SE1->E1_EMIS1	With dDatabase
					Else
						REPLACE SE1->E1_EMISSAO	With SL1->L1_EMISNF
						REPLACE SE1->E1_EMIS1	With SL1->L1_EMISNF
					EndIf

					If !lJurAdm
						SE1->E1_CLIENTE	:= SA1->A1_COD
						SE1->E1_NOMCLI	:= SA1->A1_NREDUZ
    					SE1->E1_LOJA	:= SA1->A1_LOJA
						SE1->E1_VENCTO  := aReceb[i][1]
						SE1->E1_VENCREA := DataValida(aReceb[i][1],.T.)
    					SE1->E1_VENCORI	:= aReceb[i][1]
					Else
						L070IncSA1()					// Inclui o cliente caso nao tenha sido cadastrado
						SE1->E1_CLIENTE	:= SAE->AE_COD
						SE1->E1_NOMCLI	:= SAE->AE_DESC
    					SE1->E1_LOJA	:= '01' 
						SE1->E1_VENCTO  := dSaeVencto
						SE1->E1_VENCREA := DataValida(dSaeVencto,.T.)
    					SE1->E1_VENCORI	:= dSaeVencto
						cCodCliSAE		:= SAE->AE_COD + Space(3)
						cNomCliSAE		:= SAE->AE_DESC
						cLojCliSAE		:= SE1->E1_LOJA
					EndIf
					SE1->E1_SITUACA	:= IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM,SE1->E1_TIPO,xNumCaixa()),"0")
					SE1->E1_SALDO	:= SE1->E1_VALOR
					SE1->E1_MOEDA	:= aReceb[i][11]
					SE1->E1_VLCRUZ	:= Round(	xMoeda(	SE1->E1_SALDO,;
														SE1->E1_MOEDA,;
														1,;
														SE1->E1_EMISSAO,;
														nRndMoed1+1,;
														If(SE1->E1_MOEDA==nMoedaCor,nTaxaMoeda,0);
							  					),nRndMoed1)
					SE1->E1_NATUREZ	:= &cNatureza
					SE1->E1_NUMNOTA	:= SL1->L1_DOC
					SE1->E1_SERIE	:= SL1->L1_SERIE
					SE1->E1_FILORIG	:= cFilAnt
					SE1->E1_ORIGEM	:= "LOJA010"
					SE1->E1_MULTNAT	:= "2"
					SE1->E1_FLUXO	:= "S"
					SE1->E1_NUMCART	:= aReceb[i][5] //Grava so no Windows
					SE1->E1_STATUS	:= "A"
					SE1->E1_PORCJUR	:= nPerJur
					SE1->E1_VALJUR	:= Round(SE1->E1_VALOR * (nPerJur / 100),2)
					SE1->E1_NRDOC	:= cReq
                    
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos          |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SED")
					DbSetOrder(1)
					DbSeek(xFilial("SED")+SE1->E1_NATUREZ)            
					
					If SED->ED_CALCISS=="S"
						SE1->E1_ISS     := NoRound(( nTotNFISS / nImpostos ), 2)
						nRestISS        += SE1->E1_ISS
						If i == nImpostos
							SE1->E1_ISS += ( nTotNFISS - nRestISS )
							nTotNFISS   := nRestISS := 0
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetuar o calculo do IRRF conforme natureza         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE1->E1_IRRF := NoRound(nTotNFIRRF/nImpostos,2)
					nRestIRRF += SE1->E1_IRRF
					If i == nImpostos
						SE1->E1_IRRF += nTotNFIRRF - nRestIRRF
						nTotNFIRRF  := nRestIRRF := 0
					Endif
					nTotTaxa		+= SE1->E1_VLRREAL - SE1->E1_VALOR
					SE1->E1_VEND1	:= SL1->L1_VEND			//Vendedor do cabecalho
					SE1->E1_COMIS1	:= SL1->L1_COMIS		//Comissao do vendedor do cabecalho
					SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ		//Base de comissao do vendedor

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Desconta Frete da base de calculo, caso esteja setado no cadastro de vendedores³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SA3->(DbSetOrder(1))
					If SA3->(DbSeek(xFilial("SA3")+SL1->L1_VEND))
						If ( SA3->A3_FRETE == "N" )
							nRatFrete		:= NoRound(SL1->L1_FRETE*SE1->E1_VLCRUZ/nLiq,nDecimal)
							SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ - nRatFrete
						Endif
					Endif

				Endif

				If cPaisLoc == "BRA" .AND. lFirstDupRec
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calculo para o valor do PIS³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE1->E1_PIS := NoRound(nTotNFPis/nImpostos,2)
					nRestNFPis  += SE1->E1_PIS
					If i == nImpostos
						SE1->E1_PIS += nTotNFPis-nRestNFPis
						nTotNFPis  := nRestNFPis := 0
					Endif						

					If SE1->(FieldPos("E1_SABTPIS")) > 0
						Replace SE1->E1_SABTPIS With SE1->E1_PIS
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calculo para o valor do Cofins³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE1->E1_COFINS := NoRound(nTotNFCofins/nImpostos,2)
					nRestNFCofins += SE1->E1_COFINS
					If i == nImpostos
						SE1->E1_COFINS += nTotNFCofins-nRestNFCofins
						nTotNFCofins  := nRestNFCofins := 0
					Endif                             

					If SE1->(FieldPos("E1_SABTCOF")) > 0
						Replace SE1->E1_SABTCOF With SE1->E1_COFINS
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calculo para o valor do CSLL  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
					SE1->E1_CSLL := NoRound(nTotNFCSLL/nImpostos,2)
					nRestNFCSLL += SE1->E1_CSLL
					If i == nImpostos
						SE1->E1_CSLL += nTotNFCSLL-nRestNFCSLL
						nTotNFCSLL  := nRestNFCSLL := 0
					Endif

					If SE1->(FieldPos("E1_SABTCSL")) > 0
						Replace SE1->E1_SABTCSL With SE1->E1_CSLL
					Endif

				Endif				

				MsUnlock( )

				If !Empty(LOG_TEF)
					LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '30) Gravacao do SE1  = ' + SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO )
				Endif

				If ( AScan(aRegSE1, { |x| x == SE1->(RecNo()) }) == 0 )
					AAdd( aRegSE1, SE1->(Recno()) )
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualizacao de titulos a receber, gerando todos os dados³
				//³complementares a uma implantacao de titulo.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AllTrim(aReceb[i,3]) <> "CC"
					A040DupRec(FunName(),(i == 1), nBasDup, ( LJPCCRet() > 0 ), lpTPAbISS)
				Endif

				MsUnlockAll()					
				
				If lFirstDupRec
					If !Intransact()
						SF2->( RecLock("SF2", .F.) )
					Endif
                        
					SF2->F2_VALPIS  += SE1->E1_PIS
					SF2->F2_VALCSLL += SE1->E1_CSLL
					SF2->F2_VALCOFI += SE1->E1_COFINS
					SF2->F2_VALIRRF += SE1->E1_IRRF
					SF2->( MsUnlock() )

					If lTipFin .OR. !GetNewPar("MV_RTIPFIN",.F.)
						lFirstDupRec := .F.
					Endif
				Endif
			Next i

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura a ordem do array aReceb. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aReceb := aClone(aBkpRcb)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizacao de titulos a receber, gerando todos os dados³
			//³complementares a uma implantacao de titulo.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval(aRegSE1, { |x| SE1->(DbGoto(x)), If( AllTrim(SE1->E1_TIPO) == "CC", A040DupRec(FunName(),(nQParcela == 1), nBasDup, ( LJPCCRet() > 0 ), lpTPAbISS), Nil ) })
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recupera o nome da Administradora para gravar no³
			//³campo E1_NOMCLI. Pois a funcao A40DupRec        ³
			//³Grava com o nome do Cliente da Venda            ³
			//³SE1 ja esta posicionado.                        ³			
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cNomCliSAE) .AND. !Empty(cCodCliSAE)
				DbSelectArea("SE1")
				DbSetOrder(2) // E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM
				If DbSeek(xFilial("SE1") + cCodCliSAE + cLojCliSAE + SF2->F2_PREFIXO + SF2->F2_DOC)
					While !EOF() .AND. 	(	E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == ;
											xFilial("SE1") + cCodCliSAE + cLojCliSAE + SF2->F2_PREFIXO + ;
											SF2->F2_DOC  )
						Reclock( "SE1",.F.)
						SE1->E1_NOMCLI  := cNomCliSAE
						MsUnlock( )
						DbSkip()
					End
				EndIf
			EndIf					
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza tipo de pagamento Outros ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOutros > 0 .AND. lFinanceiro;
			.AND. If(ExistBlock("LJTES",,.T.),ExecBlock("LJTES",.F.,.F.,cTes),.T.)
			For i:=1 To nQParcela
				If ! (AllTrim(aReceb[i,3]) $ "FI;CO;VA;CH;CC;CD" .OR. IsMoney(aReceb[i,3]))
					nNParc++
					nValorOut:=aReceb[i][2]
					dVenctoOut:= aReceb[i][1]
					If round(nValorOut,2) > 0
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Cria caixa p/ tratamento multi-moeda  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lCxEstrang := .F.
						If cPaisLoc <> "BRA" .AND. aPgtos[i][4] > 1
							lCxEstrang := .T.
							VerifCaixa(aPgtos[i][4],xNumCaixa())
						Endif
						nDecs := MsDecimais(aPgtos[i][4])
						Reclock( "SE1",.T.)
						j:=j+1
						SE1->E1_FILIAL  := cFilial
						SE1->E1_PREFIXO := SF2->F2_PREFIXO
						SE1->E1_NUM 	 := SL1->L1_DOC
						SE1->E1_PORTADO := xNumCaixa()
						SE1->E1_CONTA	 := ".         "
						If !lCxEstrang
							SE1->E1_AGEDEP  := ".    "
						Else
							SE1->E1_AGEDEP  := SuperGetMV("MV_SIMB"+AllTrim(Str(aPgtos[i][4])))
						Endif
						SE1->E1_PARCELA := LJParcela( j, c1DUP )
						SE1->E1_VALOR	 := Round(nValorOut,nDecs)
						SE1->E1_VENCTO  := dVenctoOut
						SE1->E1_VENCREA := DataValida(dVenctoOut,.T.)
						If cPaisloc=="BRA"
							SE1->E1_EMISSAO	:= dDataBase
							SE1->E1_EMIS1 	:= dDataBase
						Else
							SE1->E1_EMISSAO	:= aPgtos[i][5]
							SE1->E1_EMIS1 	:= aPgtos[i][5]
						EndIf
						SE1->E1_CLIENTE := SL1->L1_CLIENTE
						SE1->E1_NOMCLI  := SA1->A1_NREDUZ
						SE1->E1_TIPO	 := AllTrim(aReceb[i,3])
						SE1->E1_VENCORI := dVenctoOut
						SE1->E1_SITUACA := IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM,AllTrim(aReceb[i,3]),xNumCaixa()),"0")
						SE1->E1_SALDO	 := SE1->E1_VALOR
						SE1->E1_MOEDA	:= aPgtos[i][4]
						SE1->E1_VLCRUZ  := Round(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,nRndMoed1+1,If(nMoedaCor == SE1->E1_MOEDA,nTaxaMoeda,0)),nRndMoed1)
						SE1->E1_NATUREZ := &(SuperGetMV("MV_NATOUTR"))
						SE1->E1_LOJA	 := SL1->L1_LOJA
						SE1->E1_NUMNOTA := SL1->L1_DOC
						SE1->E1_SERIE	 := SL1->L1_SERIE
						SE1->E1_FILORIG := cFilAnt
						SE1->E1_STATUS  := "A"
						SE1->E1_PORCJUR := nPerJur
						SE1->E1_VALJUR  := Round(nValorOut * (nPerJur / 100),2)
						SE1->E1_VLRREAL := Round(aPgtos[i][2],nDecs)
                                   
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos          |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SED")
						DbSetOrder(1)
						DbSeek(xFilial("SED")+SE1->E1_NATUREZ)            
						
						If SED->ED_CALCISS=="S"
							SE1->E1_ISS     := NoRound(( nTotNFISS / nImpostos ), 2)
							nRestISS        += SE1->E1_ISS
							If i == nImpostos
								SE1->E1_ISS += ( nTotNFISS - nRestISS )
								nTotNFISS   := nRestISS := 0
							Endif
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Efetuar o calculo do IRRF conforme natureza         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE1->E1_IRRF := NoRound(nTotNFIRRF/nImpostos,2)
						nRestIRRF += SE1->E1_IRRF
						If i == nImpostos
							SE1->E1_IRRF += nTotNFIRRF - nRestIRRF
							nTotNFIRRF  := nRestIRRF := 0
						Endif
						SE1->E1_VEND1	:= SL1->L1_VEND			//Vendedor do cabecalho
						SE1->E1_COMIS1	:= SL1->L1_COMIS		//Comissao do vendedor do cabecalho
						SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ		//Base de comissao do vendedor

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Desconta Frete da base de calculo, caso esteja setado no cadastro de vendedores³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SA3->(DbSetOrder(1))
						If SA3->(DbSeek(xFilial("SA3")+SL1->L1_VEND))
							If ( SA3->A3_FRETE == "N" )
								nRatFrete		:= NoRound(SL1->L1_FRETE*SE1->E1_VLCRUZ/nLiq,nDecimal)
								SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ - nRatFrete
							Endif
						Endif

						SE1->E1_NUMCART := aReceb[i][5]
						SE1->E1_ORIGEM  := "LOJA010"
						SE1->E1_MULTNAT	:= "2"
						SE1->E1_FLUXO	:= "S"
						SE1->E1_NRDOC := cReq
						
						If cPaisLoc == "BRA" .AND. lFirstDupRec
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Calculo para o valor do PIS³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							SE1->E1_PIS := NoRound(nTotNFPis/nImpostos,2)
							nRestNFPis  += SE1->E1_PIS
							If i == nImpostos
								SE1->E1_PIS += nTotNFPis-nRestNFPis
								nTotNFPis  := nRestNFPis := 0
							Endif						

							If SE1->(FieldPos("E1_SABTPIS")) > 0
								Replace SE1->E1_SABTPIS With SE1->E1_PIS
							Endif

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Calculo para o valor do Cofins³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							SE1->E1_COFINS := NoRound(nTotNFCofins/nImpostos,2)
							nRestNFCofins += SE1->E1_COFINS
							If i == nImpostos
								SE1->E1_COFINS += nTotNFCofins-nRestNFCofins
								nTotNFCofins  := nRestNFCofins := 0
							Endif                             

							If SE1->(FieldPos("E1_SABTCOF")) > 0
								Replace SE1->E1_SABTCOF With SE1->E1_COFINS
							Endif
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Calculo para o valor do CSLL  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							SE1->E1_CSLL := NoRound(nTotNFCSLL/nImpostos,2)
							nRestNFCSLL += SE1->E1_CSLL
							If i == nImpostos
								SE1->E1_CSLL += nTotNFCSLL-nRestNFCSLL
								nTotNFCSLL  := nRestNFCSLL := 0
							Endif

							If SE1->(FieldPos("E1_SABTCSL")) > 0
								Replace SE1->E1_SABTCSL With SE1->E1_CSLL
							Endif

						Endif						
							
						MsUnlock( )

						If !Empty(LOG_TEF)
							LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '31) Gravacao do SE1  = ' + SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO )
						Endif
													
						AAdd( aRegSE1, SE1->(Recno()) )
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualizacao de titulos a receber, gerando todos os dados³
						//³complementares a uma implantacao de titulo.             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						A040DupRec(FunName(),(i == 1), nBasDup, ( LJPCCRet() > 0 ), lpTPAbISS)
						
						MsUnlockAll()													
						If lFirstDupRec
							If !Intransact()
								SF2->( RecLock("SF2", .F.) )
							Endif
	                        
							SF2->F2_VALPIS  += SE1->E1_PIS
							SF2->F2_VALCSLL += SE1->E1_CSLL
							SF2->F2_VALCOFI += SE1->E1_COFINS
							SF2->F2_VALIRRF += SE1->E1_IRRF
							SF2->( MsUnlock() )
	
							If lTipFin .OR. !GetNewPar("MV_RTIPFIN",.F.)
								lFirstDupRec := .F.
							Endif
						Endif
		
                        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			            //³ Grava as retencoes de IVA   ³
               			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
             			If cPaisLoc == "GUA"
			               If AllTrim(aReceb[i,3]) == "RI"
			                  Lj010GrvRet(nValorOut)
			               Endif
			            Endif												
		
					Endif
				Endif
			Next i
		Endif
		
		If !Intransact()
			SF2->( RecLock("SF2", .F.) )
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Cofins pode ser retido                     ³
		//³ Valor menor que MV_VRETCOF eh dispensado de recolhimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( SF2->F2_VALCOFI <= SuperGetMv("MV_VRETCOF")  )   
			SF2->F2_VALCOFI := 0							  
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Pis pode ser retido                       ³
		//³ Valor menor que MV_VRETPIS eh dispensado de recolhimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( SF2->F2_VALPIS <= SuperGetMv("MV_VRETPIS")  )    
			SF2->F2_VALPIS := 0							      
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfica se o Csll pode ser retido                       ³
		//³ Valor menor que MV_VRETCSL eh dispensado de recolhimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( SF2->F2_VALCSLL <= SuperGetMv("MV_VRETCSL")  )   
			SF2->F2_VALCSLL := 0							  
		Endif		                                        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfica se o Irrf pode ser retido                       ³
		//³ Valor menor que MV_VLRETIR eh dispensado de recolhimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( SF2->F2_VALIRRF <= SuperGetMv("MV_VLRETIR") )	
			SF2->F2_VALIRRF := 0							
		Endif
		SF2->( MsUnlock() )		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Gera o titulo referente ao valor pago em Credito (1)                                                                  |
		//| Preparar a geracao do titulo referente a NCC de Credito da Troca (2) - LJ020Saida                                     |
		//| Baixa o titulo referente ao valor pago em Credito (1) contra as NCC's ja existentes (3).                              |
		//| Baixa o(s) titulo(s) referente(s) as NCC's ja existentes (3) contra o titulo referente ao valor pago em Credito (1).  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If nValorCred > 0 .AND. lFinanceiro .AND. If(ExistBlock("LJTES",,.T.),ExecBlock("LJTES",.F.,.F.,cTes),.T.)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| 1 - Valor pago em Credito   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			cParcela := SuperGetMV("MV_1DUP")
			While SE1->(DbSeek(cFilial+SF2->F2_PREFIXO+SL1->L1_DOC+cParcela+"CR "))
				cParcela := CHR(ASC(cParcela)+1)
			End
			
			If nMoedaCor > 1
			   cAgenciaCx  := PadR(SuperGetMV("MV_SIMB"+Str(nMoedaCor,1)), nTamA6_AGE )
			   SA6->(DbSetOrder(1))
			   If SA6->(DbSeek(xFilial("SA6")+xNumCaixa()+cAgenciaCx))
			      cContaCx  := SA6->A6_NUMCON
			   Endif   
			Endif
			
			Reclock( "SE1",.T.)
			SE1->E1_FILIAL 		:= cFilial
			SE1->E1_PREFIXO 	:= SF2->F2_PREFIXO
			SE1->E1_NUM 		:= SL1->L1_DOC
			SE1->E1_PARCELA 	:= cParcela
			SE1->E1_TIPO 		:= "CR"
			SE1->E1_NUMNOTA 	:= SL1->L1_DOC
			SE1->E1_SERIE 		:= SL1->L1_SERIE
			SE1->E1_FILORIG 	:= cFilAnt
			SE1->E1_NATUREZ 	:= &(SuperGetMV("MV_NATCRED"))			// CREDITO
			SE1->E1_PORTADO 	:= xNumCaixa()
			SE1->E1_AGEDEP 		:= cAgenciaCx
			SE1->E1_CONTA 		:= cContaCx
			SE1->E1_MOEDA 		:= nMoedaCor
			SE1->E1_CLIENTE 	:= SL1->L1_CLIENTE
			SE1->E1_LOJA 		:= SL1->L1_LOJA
			SE1->E1_NOMCLI 		:= SA1->A1_NREDUZ
			SE1->E1_EMISSAO 	:= dDataBase
			SE1->E1_EMIS1 		:= dDataBase
			SE1->E1_VENCTO 		:= dDataBase
			SE1->E1_VENCREA 	:= DataValida(SE1->E1_VENCTO,.T.)
			SE1->E1_VENCORI		:= dDataBase
			SE1->E1_MOVIMEN	 	:= SE1->E1_BAIXA
			SE1->E1_VALOR 		:= nValorCred
			SE1->E1_SALDO 		:= SE1->E1_VALOR
			SE1->E1_STATUS 		:= "A"
			SE1->E1_VLCRUZ 		:= Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,nRndMoed1+1,If(nMoedaCor == SE1->E1_MOEDA,nTaxaMoeda,0)),nRndMoed1)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Tratamento da natureza ref. ao recolhimento de ISS na gravacao dos titulos           |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SED")
			DbSetOrder(1)
			DbSeek(xFilial("SED")+SE1->E1_NATUREZ)            
			
			If SED->ED_CALCISS=="S"
				SE1->E1_ISS     := NoRound(( nTotNFISS / nImpostos ), 2)
				nRestISS        += SE1->E1_ISS
				If i == nImpostos
					SE1->E1_ISS += ( nTotNFISS - nRestISS )
					nTotNFISS   := nRestISS := 0
				Endif                  
			Endif

			SE1->E1_VALLIQ 		:= SE1->E1_VALOR
			SE1->E1_SITUACA 	:= IIf(FindFunction("LjCartTit"),LjCartTit(SL1->L1_NUM,"CR",xNumCaixa()),"0")
			SE1->E1_ORIGEM 		:= "LOJA010"
			SE1->E1_MULTNAT		:= "2"
			SE1->E1_FLUXO		:= "S"
			SE1->E1_VEND1		:= SL1->L1_VEND			//Vendedor do cabecalho
			SE1->E1_COMIS1		:= SL1->L1_COMIS		//Comissao do vendedor do cabecalho
			SE1->E1_BASCOM1		:= SE1->E1_VLCRUZ		//Base de comissao do vendedor

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Desconta Frete da base de calculo, caso esteja setado no cadastro de vendedores³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA3->(DbSetOrder(1))
			If SA3->(DbSeek(xFilial("SA3")+SL1->L1_VEND))
				If ( SA3->A3_FRETE == "N" )
					nRatFrete		:= NoRound(SL1->L1_FRETE*SE1->E1_VLCRUZ/nLiq,nDecimal)
					SE1->E1_BASCOM1	:= SE1->E1_VLCRUZ - nRatFrete
				Endif
			Endif

			SE1->E1_NRDOC		:= cReq
			MsUnlock()
			
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '32) Gravacao do SE1  = ' + SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO )
			Endif				
			cDocCred := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA
			nRecnoSE1 := SE1->(Recno())
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Alimenta uma Static no LOJA020B com a Chave do titulo acima para compensa-lo ao lancar a NCC da Troca   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTroca .AND. nCredito > 0
				nValorCred -= nCredito
				If cPaisLoc == "BRA"
				   Lj020Saida(cDocCred,nRecnoSE1)
				Else 
				   Lj021Saida(cDocCred,nRecnoSE1)				
				Endif   
			Endif
		Endif
		
		If nValorCred > 0
			If cPaisLoc <> "BRA"
				If !Empty(SE1->E1_PORTADO)
					SA6->(DbSetOrder(1))
					If SA6->(DbSeek( xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
						nMoedaBco := Max(SA6->A6_MOEDA,1)
						nRndBco   := MsDecimais(nMoedaBco)
					Endif
				Endif
			Endif
			For i := 1 to Len(aNccItens)
				If aNccItens[i][1] .AND. nValorCred > 0
					SE1->(DbGoto(aNccItens[i][5]))
					
					cDocNCC := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA
					
					aNccItens[i][2] := Min(aNccItens[i][2],nValorCred)
					If cPaisLoc <> "BRA"
						aNccItens[i][6] := Round(xMoeda(aNccItens[i][2],nMoedaCor,SE1->E1_MOEDA,dDataBase,MsDecimais(SE1->E1_MOEDA)+1,nTaxaMoeda),MsDecimais(SE1->E1_MOEDA))
					Endif
					nValorCred -= aNccItens[i][2]

					RecLock("SE5",.T.)
					SE5->E5_FILIAL  := xFilial("SE5")
					SE5->E5_FILORIG := SE1->( xFilial( "SE1" ))
					SE5->E5_DATA	 := dDataBase
					SE5->E5_TIPO	:= SE1->E1_TIPO

					If SE1->E1_TIPO == "NCC"
						SE5->E5_TIPODOC	:= "BA"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Coloca o nome do cliente no E5_BENEF³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SA1->( DbSetOrder( 1 ) )
						If SA1->( DbSeek( xFilial( "SA1" ) + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
							SE5->E5_BENEF	:= SA1->A1_NOME
						Endif
					Else
						SE5->E5_TIPODOC	:= "CP"
					Endif

					If cPaisLoc == "BRA"
						SE5->E5_VALOR	 := xMoeda(aNccItens[i][2],SE1->E1_MOEDA,1)
						SE5->E5_VLMOED2	 :=	aNccItens[i][2]
					Else
						SE5->E5_VALOR	 := Round(xMoeda(aNccItens[i][6],SE1->E1_MOEDA,nMoedaBco,dDataBase,nRndBco+1,If(SE1->E1_MOEDA==nMoedaCor,nTaxaMoeda,0),If(nMoedaBco==nMoedaCor,nTaxaMoeda,0)),nRndBco)
						SE5->E5_MOEDA	 :=	StrZero(nMoedaBco,2)
						SE5->E5_VLMOED2	 :=	aNccItens[i][6]
					Endif
					SE5->E5_DTDIGIT	:= dDataBase
					SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
					SE5->E5_DTDISPO	:= SE5->E5_DATA
					SE5->E5_BANCO	:= SE1->E1_PORTADO
					SE5->E5_AGENCIA	:= If(cPaisLoc=="BRA",".",SE1->E1_AGEDEP)
					SE5->E5_CONTA	:= "."
					SE5->E5_DOCUMEN	:= cDocCred
					SE5->E5_RECPAG	:= "R"
					SE5->E5_MOTBX	:= "CMP"
					SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
					SE5->E5_NUMERO	:= SE1->E1_NUM
					SE5->E5_PARCELA	:= SE1->E1_PARCELA
					SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
					SE5->E5_CLIENTE	:= SE1->E1_CLIENTE
					SE5->E5_LOJA	:= SE1->E1_LOJA
					SE5->E5_HISTOR	:= STR0030
					MsUnlock()
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '33) Gravacao do SE5  = ' + SE5->E5_FILIAL+DTOS(SE5->E5_DATA)+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ )
					Endif
					
					RecLock("SE1",.F.)
					SE1->E1_SALDO := SE1->E1_SALDO - If(cPaisLoc=="BRA",aNccItens[i][2],aNccItens[i][6])
					If SE1->E1_SALDO = 0
						SE1->E1_STATUS	:= "B"
						SE1->E1_BAIXA	:= dDataBase
						SE1->E1_MOVIMEN	:= dDataBase
						SE1->E1_VALLIQ	:= SE1->E1_VALOR
					Endif
					MsUnlock()
					
					SE1->(DbGoto(nRecnoSE1))
					
					RecLock("SE5",.T.)
					SE5->E5_FILIAL  := xFilial("SE5")
					SE5->E5_FILORIG := SE1->( xFilial( "SE1" ))
					SE5->E5_DATA	 := dDataBase

					If SE1->E1_TIPO == "NCC"
						SE5->E5_TIPODOC	:= "BA"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Coloca o nome do cliente no E5_BENEF³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SA1->( DbSetOrder( 1 ) )
						If SA1->( DbSeek( xFilial( "SA1" ) + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
							SE5->E5_BENEF	:= SA1->A1_NOME
						Endif
					Else
						SE5->E5_TIPODOC	:= "CP"
					Endif

					If cPaisLoc == "BRA"
						SE5->E5_VALOR	 := xMoeda(aNccItens[i][2],SE1->E1_MOEDA,1)
					Else
						SE5->E5_VALOR	 := Round(xMoeda(aNccItens[i][2],SE1->E1_MOEDA,nMoedaBco,dDataBase,nRndBco+1,If(SE1->E1_MOEDA==nMoedaCor,nTaxaMoeda,0),If(nMoedaBco==nMoedaCor,nTaxaMoeda,0)),nRndBco)
						SE5->E5_MOEDA	 :=	StrZero(nMoedaBco,2)
					Endif
					SE5->E5_VLMOED2	:= aNccItens[i][2]
					SE5->E5_DTDIGIT	:= dDataBase
					SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
					SE5->E5_DTDISPO	:= SE5->E5_DATA
					SE5->E5_BANCO	:= SE1->E1_PORTADO
					SE5->E5_AGENCIA	:= If(cPaisLoc=="BRA",".",SE1->E1_AGEDEP)
					SE5->E5_CONTA	:= "."
					SE5->E5_DOCUMEN	:= cDocNCC
					SE5->E5_RECPAG	:= "R"
					SE5->E5_MOTBX	:= "CMP"
					SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
					SE5->E5_NUMERO	:= SE1->E1_NUM
					SE5->E5_PARCELA	:= SE1->E1_PARCELA
					SE5->E5_TIPO	:= SE1->E1_TIPO
					SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
					SE5->E5_CLIENTE	:= SE1->E1_CLIENTE
					SE5->E5_LOJA	:= SE1->E1_LOJA
					SE5->E5_HISTOR	:= STR0030
					MsUnlock()
					If !Empty(LOG_TEF)
						LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '34) Gravacao do SE5  = ' + SE5->E5_FILIAL+DTOS(SE5->E5_DATA)+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ )
					Endif
					
					RecLock("SE1",.F.)
					SE1->E1_SALDO := SE1->E1_SALDO - aNccItens[i][2]
					If SE1->E1_SALDO = 0
						SE1->E1_STATUS	:= "B"
						SE1->E1_BAIXA	:= dDataBase
						SE1->E1_MOVIMEN	:= dDataBase
						SE1->E1_VALLIQ	:= SE1->E1_VALOR
					Endif
					MsUnlock()
					
				Endif
			Next i
		Endif
		
		If GetMV("MV_TPCOMLJ") == "O"
			For i := 1 To Len(aRegSE1)
				DbSelectArea("SE1")
				SE1->(dbGoto(aRegSE1[i]))
		
				SA3->( DbSetOrder(1) )
				If SA3->( DbSeek( xFilial("SA3") + SE1->E1_VEND1 ) )
					If ( (	SA3->A3_ALBAIXA > 0 .AND. SE1->E1_SALDO < SE1->E1_VALOR ) .OR. ;
							SA3->A3_ALEMISS > 0 )
		
						SE1->(Fa440CalcE("MATA460",,,,.T.))
					Endif
				Endif
			Next I
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Zera os abatimentos de PIS/COFINS/CSLL caso tenha gerado os títulos de abatimentos no SE1   |
		//| Inicio ----------------------------------------------------------------------------------   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( LJPCCRet() > 0 ) .AND. SE1->(FieldPos("E1_SABTPIS")) > 0 .AND. ;
		   SE1->(FieldPos("E1_SABTCOF")) > 0 .AND. SE1->(FieldPos("E1_SABTCSL")) > 0
		
			aRecNoSE1 := aClone(aPISCofCSL[02,05])
			
			For i := 1 To Len(aRecNoSE1)

				DbSelectArea("SE1")			
				DbGoto(aRecNoSE1[i])

				RecLock("SE1", .F.)
				Replace SE1->E1_SABTPIS With 0, ;
				        SE1->E1_SABTCOF With 0, ;
				        SE1->E1_SABTCSL With 0
				MsUnlock()

			Next i

		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Zera os abatimentos de PIS/COFINS/CSLL caso tenha gerado os títulos de abatimentos no SE1	  |
		//| Fim -------------------------------------------------------------------------------------     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If cPaisLoc <> "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //| Busca caixa, agencia e conta logados   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   xNumCaixa()
		   aCaixaFin  := {SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //| Excluir do array os titulos referentes a dinheiro porque ja estao baixados          |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   aTmpRegSE1 := AClone(aRegSE1)
		   nX         := 1
		   While nX <= Len(aTmpRegSE1)
		      SE1->(DbGoto(aTmpRegSE1[nX]))
		      If IsMoney(SE1->E1_TIPO)
		         ADel(aTmpRegSE1,nX)   
		         aSize(aTmpRegSE1,Len(aTmpRegSE1)-1)		         		   		         
		      Else
		         nX++   
		      Endif 
		   End
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //| Baixa automatica dos titulos a vista, de acordo com a condicao de pagamento         |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   If Len(aTmpRegSE1) > 0
              BaixAutSE1(SL1->L1_CONDPG,aTmpRegSE1,aCaixaFin)		
           Endif   
		
		   If cPaisLoc == "ARG"
		      If lFiscal
				 nModoPrint := 2
                 lGravar := Lj010Fisc(nDescLoj,nDinheiro,nValorCart,nCheques,nValorVale,nValorFin,nValorConv,nOutros,nTroco;
			                ,nValorDebi,cVinculado,cCombo,nLiq,nModoPrint)				
			  Endif	 
		   Endif
		Endif	
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  Verifica se o Siga Loja esta integrado com o Gestão Hospitalar                     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If GetNewPar("MV_LOJAHSP",.F.)
           HS_ConfRAt(SL1->L1_NUM, SL1->L1_VLRTOT, SL1->L1_ENTRADA, SL1->L1_DESCONT, cSerie, cNumNota)
		Endif
		
		End Transaction
		FreeUsedCode()
		
		If !Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '35) End Transaction - Termino:'+Time() )
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 	//| Apos a geracao do titulo faz a verificacao de uso de lay-away                       |
	 	//| para esta venda e baixa o SLO caso necessario. - Esse trecho                        |
	 	//| foi colocado aqui para que fique fora da transacao...                               |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc$"EUA|POR" .AND. lFaturar .AND. lCompensa
			DbSelectArea("SE1")
			DbGoto(aRegSE1[Len(aRegSE1)])
			a800Titulo(5,nOutros,aNumLay)
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama a função LjDelLog pois neste ponto todo o processo de       ³
		//³gravacao do sistema foi concluido e nao podemos garantir o que    ³
		//³serah utilizado dentro do VABE001.                                ³
		//³A funcao LjDelLog tambem deverah continuar sendo chamada do       ³
		//³LOJA010A para garantir que se alguma validacao nao permitir que a ³
		//³venda seja finalizada, o arquivo de log devera continuar sendo    ³
		//³deletado por lah                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Subs(LJGetProfile("LOGERRO"),1,1) == "S" 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Identifica que faz o tratamento do Log de Erro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjDelLog(nHandle,aCloaCols,aCols,cLjArq,cNumOrc,nDescLoj,cCliente,cLoja)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estes parâmetros são passados para aumentar o controle ³
		//³da gravação e detecção de eventuais problemas nesse    ³
		//³processo, como por exemplo gravação do SL1/SL2 e não   ³
		//³gravação do SE1.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If lVaBe001T
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tomar cuidado com impressao dentro deste PE ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ExecTemplate("VABE001",.F.,.F., {cNumOrc, cNumNota, cSerie}) 
		Endif

		If !Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '36) Antes do VABE001' )
		Endif

		If lVaBe001
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tomar cuidado com impressao dentro deste PE ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			ExecBlock("VABE001",.F.,.F., {cNumOrc, cNumNota, cSerie}) 
		Endif                                
		
		If !Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '37) Depois do VABE001' )
		Endif			
		If cPaisLoc == "SAL" .AND. lCriaSerie		
		   SX5->(DbGoto(nRegSX5))
           cTipoDoc := Substr(SX5->X5_CHAVE,1,1)		      
	       cSerAtu  := Substr(SX5->X5_CHAVE,2,2)		      		      		   
		   LjCriaSerie(@cSerAtu,cTipoDoc,nRegSX5)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //|"Foi criada a serie "###" no arquivo de controle de numeracao do Documento de Saida."| 				 		
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   MsgStop(STR0105+cTipoDoc+cSerAtu+STR0106)
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Zera a variável com numero do Requerimento para aparecer em branco na próxima venda  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cReq := ""
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Se usar os modulos de gestao de concessionarias chama a funcao que grava os relacionamentos.  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SuperGetMV("MV_VEICULO") == "S" .AND. !Empty(SL1->L1_VEICTIP) .AND. !Empty(SL1->L1_VEIPESQ)
			FG_DEVLOJA(SL1->L1_VEICTIP,SL1->L1_VEIPESQ,cNumNota,cSerie)
		Endif
	Endif
Endif

If !Empty(LOG_TEF)
	LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '38) Fim da Lj010Dados - lSaida = ' + If(lSaida,'.T.','.F.')  )
Endif
Return lSaida

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010PJur ³ Autor ³ Vendas Clientes       ³ Data ³15/05/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a data digitada e executa PE, para acrescimo na     ³±±
±±³          ³ na parcela, por motivo de prorrogacao.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj010PJur((nValor,oDlgLojaPag,cComboPag,dDataForm)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Valor da parcela Atual                                 ³±±
±±³          ³ 2 - Objeto da tela de entrada de dado da parcela           ³±±
±±³          ³ 3 - Forma de pagamento                                     ³±±
±±³          ³ 4 - Data do Pagamento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[1]:= Logigo -> Verificacao da data esta correta       ³±±
±±³          ³ aRet[2]:= nValor -> Novo valor da parcela                  ³±±
±±³          ³ Obs: Qdo alterar o valor da parcela atualizar tb o array   ³±±
±±³          ³      aPagtos.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010pJur(	nValor,		lOk,	oDlgLojaPag,	cComboPag,;
					dDataForm )

Local lLj010Pror  := ExistBlock("Lj010Pror")
Local aRet		  := {.T.,nValor}

If lLj010Pror
	aRet:= ExecBlock("Lj010Pror",.F.,.F.,{nValor,cComboPag,dDataForm})
	nValor:=aRet[2]
Endif
oPgtos:Refresh()
Return aRet[1]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Frete³ Autor ³ Vendas Clientes       ³ Data ³01/06/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para dados do frete                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj010Frete(bNumero)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - CodBlock com o Numero do orcamento                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Frete(bNumOrc,	bVlrTot,	bVlrAcrs,	bVlrDesc,;
					nDescPer)
Local lRet 					:= .T.
Local oDlgPagto
Local lHabilita:=.T.
Local oTransp
Local oCob
Local oBairroC
Local oCidadeC
Local oCepC
Local oUfC
Local oEnt
Local oBairroE
Local oCidadeE
Local oCepE
Local oUfE
Local lOpcA
Local oEspecie
Local oPesLiq
Local oPesBruto
Local oTipFrete
Local oQuant
Local oMarca
Local oNumero
Local oPlaca
Local oUFPlaca
Local oValFrete
Local oValSeguro
Local oDespAces
Local lLJDFRTOK				:= ExistBlock("LJDFRTOK")
Local lL10Frete				:= ExistBlock("L10FRETE")			// Ponto de entrada antes da chamada da tela de frete
Local aVlrFrete				:= { {0,.T.},{0,.T.},{0,.T.} }   // Array retorno do P.E. L10FRETE
Local nVlrTot				:= Eval(bVlrTot) 					// Valor total (liquido) da venda (com acrescimos e descontos)
Local nVlrAcrs				:= Eval(bVlrAcrs)					// Valor de acrescimo da venda
Local nVlrDesc				:= Eval(bVlrDesc)					// Valor de desconto da venda
Local cNumOrc				:= Eval(bNumOrc)
Local nI := 0
Default nDescPer := 0

DbSelectArea('SL1')
If (DbSeek( xFilial('SL1')+ cNumOrc ) )
	If M->L1_CLIENTE==SL1->L1_CLIENTE
		M->L1_TRANSP  := SL1->L1_TRANSP
		M->L1_ENDCOB  := SL1->L1_ENDCOB
		M->L1_ENDENT  := SL1->L1_ENDENT
		M->L1_TPFRET  := If(SL1->L1_TPFRET="C",1,2)
		M->L1_BAIRROC := SL1->L1_BAIRROC
		M->L1_CEPC    := SL1->L1_CEPC
		M->L1_MUNC    := SL1->L1_MUNC
		M->L1_ESTC    := SL1->L1_ESTC
		M->L1_BAIRROE := SL1->L1_BAIRROE
		M->L1_CEPE    := SL1->L1_CEPE
		M->L1_MUNE    := SL1->L1_MUNE
		M->L1_ESTE    := SL1->L1_ESTE
	Endif
	M->L1_FRETE   := SL1->L1_FRETE
	M->L1_SEGURO  := SL1->L1_SEGURO
	M->L1_PLIQUI  := SL1->L1_PLIQUI
	M->L1_PBRUTO  := SL1->L1_PBRUTO
	M->L1_DESPESA := SL1->L1_DESPESA
	M->L1_ESPECIE := SL1->L1_ESPECIE
	M->L1_VOLUME  := SL1->L1_VOLUME
	M->L1_MARCA   := SL1->L1_MARCA
	M->L1_NUMERO  := SL1->L1_NUMERO
	M->L1_PLACA   := SL1->L1_PLACA
	M->L1_UFPLACA := SL1->L1_UFPLACA
Else
	LjDTransp(SA1->A1_TRANSP)
Endif

If ValType(M->L1_TPFRET) == "C" .AND. M->L1_TPFRET $ "C;F"
	M->L1_TPFRET := If( M->L1_TPFRET == "C", 1, 2 )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o ponto de entrada L10FRETE.                         ³
//³Esse ponto passa como parametro um array contendo:                      ³
//³[1] - Valor total (liquido) da venda                                    ³
//³[2] - Valor do acrescimo na venda                                       ³
//³[3] - Valor do desconto na venda                                        ³
//³                                                                        ³
//³E recebe como retorno um array contendo:                                ³
//³[1][1] - Vlr Frete                                                      ³
//³[2][1] - Seguro                                                         ³
//³[3][1] - Despesas                                                       ³
//³                                                                        ³
//³[1][2] - .T.                                                            ³
//³[2][2] - .T.                                                            ³
//³[3][2] - .T.                                                            ³
//³                                                                        ³
//³Onde: a 1a coluna indica os valores dos campos que ja virao preenchidos ³
//³      conforme retorno do rdmake                                        ³
//³      a 2a coluna indica se o campo serah ou nao editavel               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lL10Frete
	aVlrFrete := ExecBlock("L10FRETE",.F.,.F.,{ nVlrTot,nVlrAcrs,nVlrDesc } )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Zera a variavel aVlrFrete caso o retorno nao seja correto                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aVlrFrete) <> "A"
		aVlrFrete := { {0,.T.}, {0,.T.}, {0,.T.} }
	Else
		M->L1_FRETE		:= aVlrFrete[1][1]
		M->L1_SEGURO	:= aVlrFrete[2][1]
		M->L1_DESPESA	:= aVlrFrete[3][1]
	Endif
Endif

DEFINE MSDIALOG oDlgPagto FROM  23,80 TO 430,582 TITLE STR0058 PIXEL //"Dados do Frete"
@ 003,002 TO 085,248 LABEL STR0034 OF oDlgPagto  PIXEL //Transportadora

@ 012,004 SAY STR0035 OF oDlgPagto PIXEL  //"Codigo"
@ 013,045 MSGET oCodTransp VAR M->L1_TRANSP Picture "@!" F3 "SA4" VALID Existcpo("SA4",M->L1_TRANSP) .AND. Lj010Transp(M->L1_TRANSP)  SIZE 40,8 OF oDlgPagto PIXEL
@ 013,090 SAY oTransp      VAR SA4->A4_NOME Picture "@!" SIZE 120,8 OF oDlgPagto PIXEL COLOR CLR_BLUE

@ 028,004 SAY STR0036 OF oDlgPagto PIXEL  //"Cobranca"
@ 028,045 MSGET oCob VAR M->L1_ENDCOB  Picture "@!" SIZE 115,8  	OF oDlgPagto PIXEL When lHabilita

@ 028,167 SAY STR0037 OF oDlgPagto PIXEL //"Bairro"
@ 028,185 MSGET oBairroC VAR M->L1_BAIRROC Picture "@!" SIZE 60,8 OF oDlgPagto PIXEL When lHabilita

@ 043,004 SAY STR0038 OF oDlgPagto PIXEL //"Cidade"
@ 043,045 MSGET oCidadeC VAR M->L1_MUNC Picture "@!" SIZE 80,8 OF oDlgPagto PIXEL When lHabilita

@ 043,130 SAY STR0039 OF oDlgPagto PIXEL //"CEP"
@ 043,150 MSGET oCepC VAR M->L1_CEPC Picture "@R 99999-999" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

@ 043,200 SAY STR0040 SIZE 20,8 OF oDlgPagto PIXEL  //"Estado"
@ 043,220 MSGET oUfC VAR M->L1_ESTC Picture "@!" SIZE 12,8 VALID ExistCpo("SX5","12"+M->L1_ESTC) OF oDlgPagto PIXEL When lHabilita

@ 058,004 SAY STR0041 OF oDlgPagto PIXEL  //"Entrega"
@ 058,045 MSGET oEnt VAR M->L1_ENDENT Picture "@!" SIZE 115,8 OF oDlgPagto PIXEL When lHabilita

@ 058,167 SAY STR0037 OF oDlgPagto PIXEL //"Bairro"
@ 058,185 MSGET oBairroE VAR M->L1_BAIRROE Picture "@!" SIZE 60,8 OF oDlgPagto PIXEL When lHabilita

@ 073,004 SAY STR0038 OF oDlgPagto PIXEL //"Cidade"
@ 073,045 MSGET oCidadeE VAR M->L1_MUNE Picture "@!"  SIZE 80,8 OF 	oDlgPagto PIXEL When lHabilita

@ 073,130 SAY STR0039 OF oDlgPagto PIXEL //"CEP"
@ 073,150 MSGET oCepE VAR M->L1_CEPE  Picture "@R 99999-999"	SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

@ 073,200 SAY STR0040 SIZE 20,8 OF oDlgPagto PIXEL //"Estado"
@ 073,220 MSGET oUfE VAR M->L1_ESTE   Picture "@!" SIZE 12,8  VALID ExistCpo("SX5","12"+M->L1_ESTE) OF oDlgPagto PIXEL When lHabilita

//Dados Complementares
@ 089,002 TO 187,248 LABEL STR0042  OF oDlgPagto  PIXEL // "Dados Complementares"

@ 097,004 SAY STR0043 OF oDlgPagto PIXEL  //Quantidade
@ 096,045 MSGET oQuant VAR M->L1_VOLUME Picture "999999"  SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

@ 097,90  SAY STR0044 OF oDlgPagto PIXEL //Especie
@ 096,123 MSGET oEspecie VAR M->L1_ESPECIE Picture "@!" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

@ 097,170 SAY STR0045 OF oDlgPagto PIXEL //Marca
@ 096,200 MSGET oMarca VAR M->L1_MARCA Picture "@!" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

@ 114,004 SAY STR0046 OF oDlgPagto PIXEL //Numero
@ 112,045 MSGET oNumero VAR M->L1_NUMERO Picture "@!S1" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

@ 114,90  SAY STR0047 OF oDlgPagto PIXEL //'Peso Liquido
@ 112,123 MSGET oPesLiq VAR M->L1_PLIQUI Picture "9999.999" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

@ 114,170 SAY STR0048 OF oDlgPagto PIXEL  //'Peso Bruto'
@ 112,200 MSGET oPesBruto VAR M->L1_PBRUTO Picture "9999.999" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

//Valores
@ 127,004 TO 147,245 LABEL STR0049 OF oDlgPagto  PIXEL  //Valores

@ 135,010 SAY 'Frete' OF oDlgPagto PIXEL
@ 134,044 MSGET oValFrete VAR M->L1_FRETE Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita .AND. aVlrFrete[1][2]

@ 135,090 SAY STR0050 OF oDlgPagto PIXEL //'Seguro'
@ 134,123 MSGET oValSeguro VAR M->L1_SEGURO Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita .AND. aVlrFrete[2][2]

@ 135,170 SAY STR0051 SIZE 30,10 OF oDlgPagto PIXEL //'Desp/Aces.'
@ 134,200 MSGET oDespAces VAR M->L1_DESPESA Picture "@E 99,999,999.99" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita .AND. aVlrFrete[3][2]

//Quem paga o Frete
@ 150,004 TO 183,65 LABEL STR0052 OF oDlgPagto  PIXEL //"Frete por conta"
@ 156,010 RADIO oTipFrete VAR M->L1_TPFRET ITEMS STR0053,STR0054 SIZE 50,10 PIXEL OF oDlgPagto  //'Emitente' 'Destinatario'

//Dados do Veiculo
@ 150,070 TO 183,145 LABEL STR0055 OF oDlgPagto  PIXEL //"Veiculo"

@ 156,75 SAY STR0056 OF oDlgPagto PIXEL  //'Placa'
@ 157,90 MSGET oPlaca VAR M->L1_PLACA Picture "@!" SIZE 40,8 OF oDlgPagto PIXEL When lHabilita

@ 170,75 SAY STR0057 OF oDlgPagto PIXEL  //'UF'
@ 170,90 MSGET oUFPlaca VAR M->L1_UFPLACA Picture "@!" SIZE 12,8 VALID ExistCpo("SX5","12"+M->L1_UFPLACA) OF oDlgPagto PIXEL When lHabilita

DEFINE SBUTTON FROM 190,185 TYPE 1 ACTION (lOpcA:=If(lLJDFRTOK,ExecBlock("LJDFRTOK",.F.,.F.,{cNumOrc}),.T.),If(lOpca,oDlgPagto:End(),.F.)) ENABLE OF oDlgPagto
DEFINE SBUTTON FROM 190,220 TYPE 2 ACTION (oDlgPagto:End()) ENABLE OF oDlgPagto
ACTIVATE MSDIALOG oDlgPagto CENTERED
M->L1_TPFRET  := If(M->L1_TPFRET=1,"C", "F")
If lOpcA
    
	nVlrFSD := M->L1_FRETE + M->L1_SEGURO + M->L1_DESPESA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  Realiza o rateio dos valores de Frete para o item   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVlrFSD > 0 .AND. lVlrFSD
		LjRateioFret()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Recalcula o IPI, para o caso do F4_IPIFRET for igual a "S".  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI = 1 To Len(aCols)

			If aCols[nI,( nUsado + 1 )]
				aCols[nI,aPosicoes[07,02]] := Lj010Ipi(,,,nDescPer,,nI,,"V") //-- Recalcula o Valor.
			Endif

		Next nI
		
	Endif

	DbSelectArea('SL1')
	If (DbSeek( xFilial('SL1')+ cNumOrc ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Grava dados do Frete na tabela SL1, para casos de alteracao  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj010GRFT()
	Endif
		
	If cPaisLoc <> "BRA"
		lDetalhe := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para indicar se o valor do frete ira entrar no ³
	//³ total da venda                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJCOBFRT")
		lRet := ExecBlock("LJCOBFRT",.F.,.F.,{ nVlrFSD, M->L1_TPFRET } )
		If ValType(lRet) == "L"
			lVlrFSD := lRet
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ As funcoes abaixo sao para atualizar as variaveis de tela  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(oGet:oBrowse:bLostFocus)

	oFolder:nOption := 1
	oGet:oBrowse:SetFocus()
	Eval(oFolder:bSetOption, 1)
	
	oFolder:nOption := 2
	Eval(oFolder:bSetOption, 2)

Endif


Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010GRFT ³ Autor ³ Vendas Clientes       ³ Data ³01/06/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao dos dados do frete na tabela SL1                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010GRFT()

Reclock( "SL1",.F. )  // Grava dados do frete, ja esta posicionado.
SL1->L1_TRANSP  := M->L1_TRANSP
SL1->L1_ENDCOB  := M->L1_ENDCOB
SL1->L1_ENDENT  := M->L1_ENDENT
SL1->L1_TPFRET  := M->L1_TPFRET
SL1->L1_BAIRROC := M->L1_BAIRROC
SL1->L1_CEPC    := M->L1_CEPC
SL1->L1_MUNC    := M->L1_MUNC
SL1->L1_ESTC    := M->L1_ESTC
SL1->L1_BAIRROE := M->L1_BAIRROE
SL1->L1_CEPE    := M->L1_CEPE
SL1->L1_MUNE    := M->L1_MUNE
SL1->L1_ESTE    := M->L1_ESTE
SL1->L1_FRETE   := M->L1_FRETE
SL1->L1_SEGURO  := M->L1_SEGURO
SL1->L1_PLIQUI  := M->L1_PLIQUI
SL1->L1_PBRUTO  := M->L1_PBRUTO
SL1->L1_DESPESA := M->L1_DESPESA
SL1->L1_ESPECIE := M->L1_ESPECIE
SL1->L1_VOLUME  := M->L1_VOLUME
SL1->L1_MARCA   := M->L1_MARCA
SL1->L1_NUMERO  := M->L1_NUMERO
SL1->L1_PLACA   := M->L1_PLACA
SL1->L1_UFPLACA := M->L1_UFPLACA
DbCommitAll()
MsUnlock( )
Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjDTransp ³ Autor ³ Vendas Clientes       ³ Data ³01/06/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa as varaiaveis do frete com os dados do Cliente  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjDTransp(cCodTrans,oDlgPagto)

If Empty(M->L1_TRANSP)
	M->L1_TRANSP := cCodTrans
EndIf

DbSelectArea("SA4")
DbSeek(xFilial( "SA4" ) + M->L1_TRANSP)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso nao exista dados de frete, trazer os dados do cadastro de clientes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->L1_ENDCOB)
	M->L1_ENDCOB := SA1->A1_ENDCOB
EndIf
If Empty(M->L1_BAIRROC)
	M->L1_BAIRROC := SA1->A1_BAIRROC
EndIf
If Empty(M->L1_MUNC)
	M->L1_MUNC := SA1->A1_MUNC
EndIf
If Empty(M->L1_CEPC)
	M->L1_CEPC := SA1->A1_CEPC
EndIf
If Empty(M->L1_ESTC)
	M->L1_ESTC := SA1->A1_ESTC
EndIf
If Empty(M->L1_ENDENT)
	M->L1_ENDENT := SA1->A1_ENDENT
EndIf
If Empty(M->L1_BAIRROE)
	M->L1_BAIRROE := SA1->A1_BAIRROE
EndIf
If Empty(M->L1_MUNE)
	M->L1_MUNE := SA1->A1_MUNE
EndIf
If Empty(M->L1_CEPE)
	M->L1_CEPE := SA1->A1_CEPE
EndIf
If Empty(M->L1_ESTE)
	M->L1_ESTE := SA1->A1_ESTE
EndIf

If Valtype(oDlgPagto)=='O'
	oDlgPagto:Refresh()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para atualizacao dos dados acima caso seja necessario.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "LJDADOSFRE" )
	ExecBlock( "LJDADOSFRE", .F. , .F. , {oCliente:cText, oLoja:cText} )
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010RetPos ³ Autor ³ Vendas Clientes       ³ Data ³ 12/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna 0 para valores menores que zero                      ³±±
±±³          ³ Para Localizacoes e possivel faturas negativas, porem a      ³±±
±±³          ³ gravacao de alguns campos de valores deve ser zero           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Lj010RetPos(nValor)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Balcao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010RetPos(nValor)

If nValor < 0
	nValor := 0
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010ValP ³ Autor ³ Vendas Clientes       ³ Data ³ 16.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a parcela digitada considerando multi-moeda          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010ValP(nValor,nValAteP,nValTot,cMoedaTit)
Local lRet       := .F.
Local lAchou     := .F.
Local nI         := 0
Local nMoedaOrig := 1
Local nNumMoeda  := MoedFin()
Local nDif       := 0
Local nValorDig  := 0
Local nDifValor  := 0

nI++
While !lAchou .AND. nI <= nNumMoeda
	If cMoedaTit == SuperGetMV("MV_MOEDA"+LTrim(Str(nI)))
		nMoedaOrig  := nI
		lAchou := .T.
	Endif
	nI++
End

nValorDig := Round(xMoeda(nValor,nMoedaOrig,nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)

nDif := (1/(10**nDecimais))   //Intervalo de tolerancia para diferencas de arredondamento na conversao de valores
nDifValor := Abs(nValorDig+nValAteP - nValTot)
If nDifValor <= nDif  .AND. nDifValor > 0
	nValTot := nValorDig+nValAteP             //Ha uma diferenca de arredondamento
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Compara o valor digitado e as demais parcelas com o total da fatura, considerando multimoeda  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (nValorDig+nValAteP) <= nValTot

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010REQ  ºAutor  ³Vendas Clientes     º Data ³  02/21/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consiste o Requerimento para integração com o Academico    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - Venda Balcao                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Req
Local oDlg
Local nOpc := 0
Local cTmpReq

Local nJBFOrder := JBF->(IndexOrd())
Local nJBFRecno	:= JBF->(Recno())
Local nSB1Order := SB1->(IndexOrd())
Local nSB1Recno := SB1->(Recno())
Local nSE1Order := SE1->(IndexOrd())
Local nSE1Recno := SE1->(Recno())

Local nPosVrUni := aPosicoes[1][2]
Local nPosTotal := aPosicoes[2][2]
Local nPosTes	:= aPosicoes[5][2]		
Local nPosProd	:= aPosicoes[9][2]
Local nPosQtd	:= aPosicoes[11][2]
Local nPosPrc	:= aPosicoes[13][2]
Local nPosLocal	:= aPosicoes[14][2]
Local nPosItem	:= aPosicoes[15][2]
Local nPosDescr	:= aPosicoes[17][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .AND. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .AND. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Variavel cReq -> Estática (Static) nao mova esta funcao deste .PRW                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cReq)
	cReq := Space(TamSX3("JBH_NUM")[1])
Endif
cTmpReq := cReq

DEFINE MSDIALOG oDlg TITLE STR0065 FROM 13,21 TO 21,60 OF GetWNDDefault()
@ 06,12 SAY	 STR0066 SIZE 130,10 OF oDlg PIXEL
@ 06,88 MSGET	cTmpReq						SIZE 055,10 OF oDLG PIXEL PICTURE "@!" VALID ExistCpo("JBH",cTmpReq) F3 "JBH"
DEFINE SBUTTON FROM 35,090 TYPE 1 PIXEL ACTION ( nOpc:=1,oDlg:End() ) ENABLE OF oDlg
DEFINE SBUTTON FROM 35,120 TYPE 2 PIXEL ACTION ( nOpc:=2,oDlg:End() ) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

If nOpc == 1 .AND. ! Empty(cTmpReq)

	SE1->(DbSetOrder(15))
	if SE1->(DbSeek(xFilial("SE1")+cTmpReq))
		If SE1->E1_SALDO = 0
			MsgStop(STR0067)
		Else
			MsgSTop(STR0068)
		Endif
	Else
		JBF->(DbSetOrder(2))
		If JBF->(DbSeek(xFilial("JBF")+cTmpReq+"1"))

			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+JBF->JBF_CODPRO))
				
				cReq := cTmpReq

				aCols[1][nPosProd]		:= JBF->JBF_CODPRO       
				aCols[1][nPosQtd]		:= JBH->JBH_QUANT
				aCols[1][nPosPrc]		:= JBF->JBF_VALOR
				aCols[1][nPosTotal]	:= (JBF->JBF_VALOR * JBH->JBH_QUANT)
				aCols[1][nPosVrUni]	:= JBF->JBF_VALOR
				aCols[1][nPosTes]		:= SuperGetMV("MV_TESSAI")
				If Empty(aCols[1][nPosTes])
					aCols[1][nPosTes]   := RetFldProd(SB1->B1_COD,"B1_TS")
  				Endif
				aCols[1][nPosLocal]    := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
				If nPosItem > 0
					aCols[1][nPosItem]		:= "01"
				Endif
				If nPosDescr > 0
					aCols[1][nPosDescr]	:= SB1->B1_DESC
				Endif
				oGet:Refresh()
				Eval (bReq)
				
			Endif
		Endif
	Endif

	JBF->(DbSetOrder(nJBFOrder))
	JBF->(DbGoto(nJBFRecno))
	SB1->(DbSetOrder(nSB1Order))
	SB1->(DbGoto(nSB1Recno))
	SE1->(DbSetOrder(nSE1Order))
	SE1->(DbGoto(nSE1Recno))

Endif

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010AtCarto³ Autor ³ Vendas Clientes     ³ Data ³ 14.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a descricao da adiministrado de cartos em uma     ³±±
±±³          ³ transacao TEF, qdo e seleionado um carto e passado outo.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function L010AtCartao()
Local aArea 	:= GetArea()
Local nZ        := 1
Local cxFilial   :=xFilial("SL4")
Local cNumOrc   :=SL1->L1_NUM
Local lFlag     :=.F.
Local cCartao   

While nZ<= Len(aReceb)
   If Upper(Alltrim(Subs(aReceb[nZ][4],7)))<>Upper(Alltrim(aTefDados[1][8])).AND.;
      (Alltrim(aReceb[nZ][3])=='CC'.OR.Alltrim(aReceb[nZ][3])=='CD'  )
        lFlag  := .T.
        cCartao:=aReceb[nZ][4]
        Exit
   Endif
   nZ++
End

If lFlag
	DbSelectArea("SAE")
	DbGotop()
	While !EOF()
		If Upper(Alltrim(aTefDados[1][8]))==Alltrim(Upper(Left( AE_DESC, 16 )))
			Exit
		Endif
		DbSkip()
	End
	
	If !EOF()
		nZ:=1
		While nZ<= Len(aReceb)
			If aReceb[nZ][4] == cCartao .AND. (Alltrim(aReceb[nZ][3])=='CC'.OR.Alltrim(aReceb[nZ][3])=='CD'  )
				aReceb[nZ][4] := SAE->AE_COD+' - '+ SAE->AE_DESC
			Endif
			nZ++
		End
	Endif
	
	nZ:=1
	DbSelectArea( "SL4" )
	DbSetOrder( 1 )
	DbSeek(cxFilial + cNumOrc)
	While cxFilial == SL4->L4_FILIAL .AND. cNumOrc == SL4->L4_NUM .AND. !EOF()
		If Alltrim(SL4->L4_ADMINIST) == Alltrim(cCartao)
			Reclock("SL4")
			Replace SL4->L4_ADMINIST With aReceb[nZ][4]
			MsUnlock()
		Endif
		nZ++
		DbSkip()
	End
Endif
RestArea( aArea )

Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010Lay  ºAutor  ³Vendas Clientes     º Data ³  04/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a consulta de lay-away                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Lay()
Local oDlg
Local lAllLay	:= .T.
Local lItemaCols:= .F.
Local aArea 	:= GetArea()
Local cFilSLO 	:= xFilial("SLO")
Local aLays		:= {}
Local cCliente 	:= oCliente:cText
Local cLoja		:= oLoja:cText
Local aCab		:= {RetTitle("LO_NUMLAY"),RetTitle("LO_ITEM"),RetTitle("LO_PRODUTO"),RetTitle("B1_DESC"),RetTitle("LO_QUANT")}
Local aSizes	:= {}
Local bLine		:= { || {aLays[oLBx:nAT][1],aLays[oLBx:nAT][2],aLays[oLbx:nAT][3],aLays[oLbx:nAt][4],Transform(aLays[oLbx:nAt][5],PesqPict("SLO","LO_QUANT"))}}
Private cNumLay := ""
                     
AAdd(aSizes,Max(Len(aCab[1]),TamSX3("LO_NUMLAY")[1]) *4.1)
AAdd(aSizes,Max(Len(aCab[2]),TamSX3("LO_ITEM")[1])   *4.1)
AAdd(aSizes,Max(Len(aCab[3]),TamSX3("LO_PRODUTO")[1])*4.1)
AAdd(aSizes,Max(Len(aCab[4]),TamSX3("B1_DESC")[1])   *4.1)
AAdd(aSizes,Max(Len(aCab[5]),TamSX3("LO_QUANT")[1])  *4.1)
	
If Empty(cCliente) .OR. Empty(cLoja)
	Return( Nil )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Monta array com as informacoes   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SLO")
DbSetOrder(2)
DbSeek(cFilSLO+cCliente+cLoja,.T.)
While !EOF() .AND. LO_FILIAL+LO_CLIENTE+LO_LOJA == cFilSLO+cCliente+cLoja

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| A variavel cNumLay e usada no a800Total(). Nao retire.   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNumLay := LO_NUMLAY      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿¿
	// Filtra os vencidos, encerrados, excluidos e aqueles que ainda tem saldo
	If LO_STATUS <> "1" .OR. LO_DTENT < dDataBase .OR. LO_VALPAG < a800Total(.T.)
		DbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Verifica se o item ja esta no aCols    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    lItemaCols := LjItemLay(cNumLay,LO_ITEM)	
        
    If lItemaCols
	   DbSkip()
	   Loop        
    Endif
	
	AAdd(aLays,{LO_NUMLAY,LO_ITEM,LO_PRODUTO,a800DescB1(LO_PRODUTO),(LO_QUANT-LO_QUJE)})
	DbSkip()
End


RestArea(aArea)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Monta Dialog   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aLays)
	DEFINE MSDIALOG oDLG FROM 02,10 To 18,82.5 of oMainWnd
	oLbx := TWBrowse():New(0.5, 0.5,280,90,,aCab,aSizes,oDlg,,,,,,,,,,,, .F.,, .F.,, .F.,,, )
	oLbx:SetArray(aLays)
	oLbx:bLine := bLine
	IF SuperGetMV("MV_LWPARC",,.F.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Somente permite a escolha se o parametro permitir layaway parcial                   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 105,25 CHECKBOX oItem VAR lAllLay PROMPT STR0070 SIZE 90,8 OF oDlg  // Utiliza todo o Lay-Away
    Endif
	DEFINE  SButton FROM 100,215 TYPE 1 Action (LjFillLay(oLbx,lAllLay),oDlg:End() ) ENABLE OF oDlg  PIXEL
	DEFINE  SButton FROM 100,250 TYPE 2 Action (oDlg:End() ) ENABLE OF oDlg  PIXEL
	ACTIVATE DIALOG oDlg
Endif


Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjFillLay ºAutor  ³Vendas Clientes     º Data ³  04/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz o preenchimento do aCols de acordo com o que foi        º±±
±±º          ³selecionado pela Lj010Lay()                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjFillLay(oLbx,lAllLay)
Local aArea 	:= GetArea()
Local aColsTmp	:= {}
Local nNTmp		:= n
Local naCols    := 0
Local cItem		:= oLbx:aArray[oLbx:nAt][2]
Local lItemaCols:= .F.
Local lInsLinha := .F.
Private cNumLay	:= oLbx:aArray[oLbx:nAt][1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| DbSelectArea("SLO")    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SLO->(DbSetOrder(1))
If lAllLay
	SLO->(DbSeek(xFilial("SLO")+cNumLay,.T.))
	
	naCols := Len(aCols)
	aColsTmp := aClone(aCols[1])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  Preenche o aCols   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(SLO->(EOF())) .AND. xFilial("SLO")+cNumLay == SLO->LO_FILIAL+SLO->LO_NUMLAY
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿¿
		// Filtra os vencidos, encerrados, excluidos e aqueles que ainda tem saldo
		If SLO->LO_STATUS <> "1" .OR. SLO->LO_DTENT < dDataBase .OR. SLO->LO_VALPAG < a800Total(.T.)
			SLO->(DbSkip())
			Loop
		Endif

        lItemaCols  := LjItemLay(SLO->LO_NUMLAY,SLO->LO_ITEM)

        If lItemaCols
	       SLO->(DbSkip())
	       Loop        
        Endif
        
		If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_PRODUTO" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_PRODUTO
			M->L2_PRODUTO	    := SLO->LO_PRODUTO
			If ExistTrigger("L2_PRODUTO")
				RunTrigger(2,naCols,,"L2_PRODUTO")
			Endif
		Endif
                                                               
		If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_QUANT" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_QUANT - SLO->LO_QUJE
			M->L2_QUANT			:= SLO->LO_QUANT - SLO->LO_QUJE
			If ExistTrigger("L2_QUANT  ")
				RunTrigger(2,naCols,,"L2_QUANT  ")
			Endif                 
		Endif
                                                             
		If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_VRUNIT" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_VUNIT
			M->L2_VRUNIT	    := SLO->LO_VUNIT
			If ExistTrigger("L2_VRUNIT ")			
				RunTrigger(2,naCols,,"L2_VRUNIT ")
			Endif
		Endif
                                                              
		If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_VLRITEM" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_TOTAL
			M->L2_VLRITEM	    := SLO->LO_TOTAL       
			If ExistTrigger("L2_VLRITEM")			
	  			RunTrigger(2,n,,"L2_VLRITEM")
			Endif
		Endif
                                                               
		If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_LOCAL" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_LOCAL
			M->L2_LOCAL		    := SLO->LO_LOCAL       
			If ExistTrigger("L2_LOCAL  ")			
				RunTrigger(2,naCols,,"L2_LOCAL  ")
			Endif
		Endif
                                                             
		If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_UM" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_UM
			M->L2_UM		    := SLO->LO_UM          
			If ExistTrigger("L2_UM     ")						
				RunTrigger(2,naCols,,"L2_UM     ")
			Endif
		Endif
                                                          
		If ( nX := AScan(aHeader, { |x| ALLTRIM(x[2]) == "L2_DESC" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_DESC
			M->L2_DESC		    := SLO->LO_DESC
			If ExistTrigger("L2_DESC   ")						
				RunTrigger(2,naCols,,"L2_DESC   ")
			Endif
		Endif
			 
		If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_TES" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_TES
			M->L2_TES		    := SLO->LO_TES
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Posiciona o Tes antes do gatilho  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(DbSeek(xFilial("SF4")+M->L2_TES))
			If ExistTrigger("L2_TES    ")						
	  			RunTrigger(2,naCols,,"L2_TES    ")
	  		Endif
		Endif
		                                                             
		If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_NUMLAY" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_NUMLAY
			M->L2_NUMLAY	    := SLO->LO_NUMLAY
		Endif
					                                                     
    	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_ITEMLAY" } ) ) > 0
			aCols[naCols][nX]	:= SLO->LO_ITEM
			M->L2_ITEMLAY	    := SLO->LO_ITEM
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Certificar que o item selecionado do Lay-Away esteja como nao-deletado no aCols     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols[naCols][Len(aCols[naCols])]	:= .F.

		AAdd( aCols, aClone( aColsTmp ) )
		naCols 	  := naCols+1
		n		  := naCols
		lInsLinha := .T.
		DbSelectArea("SLO")
		DbSkip()
	End
	If lInsLinha
       naCols := Len(aCols)-1
       n      := naCols
	   Asize(aCols,naCols)
	Endif   
Else
	SLO->(DbSeek(xFilial("SLO")+cNumLay+cItem))
	
	naCols := Len(aCols)
	If ( nX := AScan( aHeader,{ |x| ALLTRIM(x[2]) == "L2_PRODUTO" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_PRODUTO
		M->L2_PRODUTO	    := SLO->LO_PRODUTO
		If ExistTrigger("L2_PRODUTO")
			RunTrigger(2,naCols,,"L2_PRODUTO")
		Endif
	Endif
                                                               
	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_QUANT" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_QUANT - SLO->LO_QUJE
		M->L2_QUANT			:= SLO->LO_QUANT - SLO->LO_QUJE
		If ExistTrigger("L2_QUANT  ")
			RunTrigger(2,naCols,,"L2_QUANT  ")
		Endif                 
	Endif
                                                             
	If ( nX := AScan( aHeader,{ |x| ALLTRIM(x[2]) == "L2_VRUNIT" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_VUNIT
		M->L2_VRUNIT	    := SLO->LO_VUNIT
		If ExistTrigger("L2_VRUNIT ")			
			RunTrigger(2,naCols,,"L2_VRUNIT ")
		Endif
	Endif
                                                              
	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_VLRITEM" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_TOTAL
		M->L2_VLRITEM	    := SLO->LO_TOTAL       
		If ExistTrigger("L2_VLRITEM")			
  			RunTrigger(2,n,,"L2_VLRITEM")
		Endif
	Endif
                                                               
	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_LOCAL" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_LOCAL
		M->L2_LOCAL		    := SLO->LO_LOCAL       
		If ExistTrigger("L2_LOCAL  ")			
			RunTrigger(2,naCols,,"L2_LOCAL  ")
		Endif
	Endif
                                                             
	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_UM" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_UM
		M->L2_UM		    := SLO->LO_UM          
		If ExistTrigger("L2_UM     ")						
			RunTrigger(2,naCols,,"L2_UM     ")
		Endif
	Endif
                                                          
	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_DESC" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_DESC
		M->L2_DESC		    := SLO->LO_DESC
		If ExistTrigger("L2_DESC   ")						
			RunTrigger(2,naCols,,"L2_DESC   ")
		Endif
	Endif
			 
	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_TES" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_TES
		M->L2_TES		    := SLO->LO_TES
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Posiciona o Tes antes do gatilho   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(DbSeek(xFilial("SF4")+M->L2_TES))
		If ExistTrigger("L2_TES    ")						
  			RunTrigger(2,naCols,,"L2_TES    ")
  		Endif
	Endif
		                                                             
	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_NUMLAY" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_NUMLAY
		M->L2_NUMLAY	    := SLO->LO_NUMLAY
	Endif
				                                                     
   	If ( nX := AScan( aHeader, { |x| ALLTRIM(x[2]) == "L2_ITEMLAY" } ) ) > 0
		aCols[naCols][nX]	:= SLO->LO_ITEM
		M->L2_ITEMLAY	    := SLO->LO_ITEM
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Seta a variavel lDetalhe como .F. para que sejam atualizados os impostos            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lDetalhe := .F.
oGet:Refresh()
SysRefresh()
Eval(oGet:oBrowse:bGotFocus)

oGet:Refresh()
SysRefresh()

RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| n := nNTmp   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010AjImps ³ Autor ³ Vendas Clientes     ³ Data ³ 03.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajustar os impostos apos o arredondamento dos items        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj010AjImps(nRecnoIt,nValMerc)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := Numero do registro do primeiro item do orcamento  ³±±
±±³          ³ ExpN2 := Valor Total das Mercadorias                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010AjImps(nRecnoIt,nValMerc,nDescLoj)
Local nCnt      := 1
Local nX
Local nY
Local nPosCpo   := 0
Local nTamaCols := 0
Local nPosTes   := Ascan(aHeader,{|X| Alltrim(x[2]) == "L2_TES" } )
Local nTotal    := Ascan(aHeader,{|X| Alltrim(X[2]) == "L2_VLRITEM" } )
Local nAliquota := 0
Local nPosUltImp:= 0
Local aUltImp   := {}

DbSelectArea("SL2")                                    
DbGoTo(nRecnoIt)  //Primeiro item do orcamento
If SL1->L1_DESCONT > 0
	nTamaCols := Len(aCols)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera o Valor da Base de Calculo  o Valor do Imposto e a     ³
	//³ Aliquota antes de Recalcular os Impostos.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To nTamaCols
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o Array aUltImp para identificar o ultimo item do   ³
		//³ aCols que esta contido o(s) Imposto(s) com Calculo P/Total  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aCols[nX][Len(aCols[nX])]
			SFC->(DbSeek(xFilial("SFC")+aCols[nX][nPosTes]))
			While SFC->FC_TES == aCols[nX][nPosTes] .AND. !SFC->(EOF())
				If SFC->FC_CALCULO == "T"
					SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
					nAliquota := If(SFC->FC_BASE==0, SFB->FB_ALIQ, SFB->FB_ALIQ  *  (SFC->FC_BASE/100) )
					nPosUltImp:=	Ascan(aUltImp,{|x| x[1] == SFC->FC_IMPOSTO .AND. x[4]==nAliquota} )
					If nPosUltImp == 0
						AADD(aUltImp,{SFC->FC_IMPOSTO,nX,aCols[nX][nTotal],nAliquota })
					Else
						aUltImp[nPosUltImp][2]  := nX                   // Ultima Posicao do Imposto
						aUltImp[nPosUltImp][3]  += aCols[nX][nTotal]   //  Base de Calculo
					Endif
				Endif
				SFC->(DbSkip())
			End
		Endif
	Next nX

   While SL2->L2_FILIAL == xFilial("SL2") .AND. SL2->L2_NUM == SL1->L1_NUM .AND. !EOF()
      aImpVarSD2[1] := SL2->L2_QUANT
	  aImpVarSD2[2] := SL2->L2_VRUNIT
	  aImpVarSD2[3] := SL2->L2_VLRITEM+SL2->L2_DESCPRO
	  aImpVarSD2[4] := 0.00
	  aImpVarSD2[5] := 0.00
	  aImpVarSD2[6] := {}
	  If cPaisLoc == "COL"
	     aImpVarSD2[7] := SA1->A1_CGC // NIT Terceros
      Endif
      CalcTesxIp( "S"      ,SL2->L2_VLRITEM+SL2->L2_DESCPRO    ,SL2->L2_VRUNIT*SL2->L2_QUANT    ,SL2->L2_PRODUTO   ,;
                   1       ,nCnt                                ,"BALCAO"                        ,SL2->L2_DESCPRO   ,;
                   nDescLoj,                                    ,aUltImp                         )
      If Len(aUltImp) == 0             
         aImps[nCnt]     := aClone(aImpVarSD2)      
      Endif   

	  Reclock("SL2",.F.) 
      If nCnt <= Len(aImps)
	     For nY := 1 To Len(aImps[nCnt][6])
		    nPosCpo  := FieldPos(Trim(aImps[nCnt][6][nY][7]))
		    FieldPut(nPosCpo,aImps[nCnt][6][nY][3]) //Valor base
		  
		    nPosCpo  := FieldPos(Trim(aImps[nCnt][6][nY][6]))
		    FieldPut(nPosCpo,aImps[nCnt][6][nY][4]) //Valor do imposto		  
         Next nY
	  Endif
	  MsUnlock()
      
      nCnt++      
      DbSkip()            
   End
Endif   
   
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LJHISTLOJ   ³ Autor ³ Vendas Clientes     ³ Data ³ 21.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama a rotina de consulta do Historico do Cliente.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJHISTLOJ()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjHistLoj( cCliente )
Local cNum
Local cVendedor
Local cLoja
Local cPedido
Local dValidade
Local dEmissao
Local lMod3     := SuperGetMV("MV_LJMOD3")

Default cCliente := ""

SetKey( 8, nil )

IF lMod3
	cNum      := M->L1_NUM
	cVendedor := M->L1_VEND
	cClie     := M->L1_CLIENTE
	cLoja     := M->L1_LOJA
	cPedido   := M->L1_NROPCLI
	dValidade := M->L1_DTLIM
	dEmissao  := M->L1_EMISSAO
Endif
	
	TkHistLoj( cCliente, If( aCols[ n, Len(aCols[n]) ], "", aCols[n,aPosicoes[9,2]] ) )
	
IF lMod3
	M->L1_NUM     := cNum
	M->L1_VEND    := cVendedor
	M->L1_CLIENTE := cClie
	M->L1_LOJA    := cLoja
	M->L1_NROPCLI := cPedido
	M->L1_DTLIM   := dValidade
	M->L1_EMISSAO := dEmissao
Endif          

SetKey( 8,{||LjHistLoj( cCliente )})

RETURN( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010CbFrm³ Autor ³Vendas Clientes        ³Data  ³ 12.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida forma do ComboBox 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 := Data de Emissao     				              ³±±
±±³          ³ ExpD1 := Data              				                  ³±±
±±³          ³ ExpC1 := Combo de pagamento				                  ³±±
±±³          ³ ExpO1 := Tela de pagamentos				                  ³±±
±±³          ³ ExpA1 := Matriz contendo as datas e valores para pagamentos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SigaLoja													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010CbFrm(cComboPag,		oPgtos,		aPgtos,		dDataEmis,;
					dDataForm,		aTmpPgtos)
Local lRet     := .T.

If FunName() == "LOJA220" .AND. ExistBlock("LJ220DATE")
	lRet := ExecBlock("LJ220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"COMBOPAG",oListForma,aFormas})
	If lRet
		aFormas[oListForma:nAT][01] := dDataForm	 
		aFormas[oListForma:nAT][12] := dDataEmis
	Else
		aFormas[oListForma:nAT][01] := aTmpFormas[oListForma:nAT][01]
		aFormas[oListForma:nAT][12] := aTmpFormas[oListForma:nAT][12]
		dDataForm := aTmpFormas[oListForma:nAT][01]
		dDataEmis := aTmpFormas[oListForma:nAT][12]
	Endif
ElseIf FunName() == "LOJA010" .AND. ExistBlock("Lj010DATE")
	lRet := ExecBlock("Lj010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"COMBOPAG",oPgtos,aPgtos})
	If lRet
		aPgtos[oPgtos:nAT][1] := dDataForm	 
		aPgtos[oPgtos:nAT][5] := dDataEmis
	Else	
		aPgtos[oPgtos:nAT][1] := aTmpPgtos[oPgtos:nAT][1]
		aPgtos[oPgtos:nAT][5] := aTmpPgtos[oPgtos:nAT][5]
		dDataForm := aTmpPgtos[oPgtos:nAT][1]
		dDataEmis := aTmpPgtos[oPgtos:nAT][5]
	Endif
Endif

Return( lRet )
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010DtEmis³ Autor ³Vendas Clientes        ³Data  ³12/11/02   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da data de emissao do cheque                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj010Imps(ExpD1,ExpD2,ExpC1,ExpO1,ExpA1)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 := Data de Emissao     				               ³±±
±±³          ³ ExpD1 := Data              				                   ³±±
±±³          ³ ExpC1 := Combo de pagamento				                   ³±±
±±³          ³ ExpO1 := Tela de pagamentos				                   ³±±
±±³          ³ ExpA1 := Matriz contendo as datas e valores para pagamentos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  											   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010DtEmis(	dDataEmis,		dDataForm,		cComboPag,		oPgtos,;
						aPgtos	)
Local lRet := .T.

If FunName() == "LOJA220" .AND.  ExistBlock("LJ220DATE")
	lRet := ExecBlock("LJ220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oListForma,aFormas})
ElseIf FunName() == "LOJA010" .AND. ExistBlock("Lj010DATE")
	lRet := ExecBlock("Lj010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oPgtos,aPgtos})
Else
	If dDataBase <= dDataEmis .AND. dDataForm >= dDataEmis
		lRet := .T.
	Else
		MsgStop(STR0079)
		lRet := .F.
	Endif
Endif			  

Return( lRet )	          

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010DtVcto³ Autor ³Vendas Clientes        ³Data  ³12/11/02   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da data de vencimento do cheque.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj010Imps(ExpD1,ExpD2,ExpC1,ExpO1,ExpA1)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 := Data de Vencimento  				               ³±±
±±³          ³ ExpD1 := Data              				                   ³±±
±±³          ³ ExpC1 := Combo de pagamento				                   ³±±
±±³          ³ ExpO1 := Tela de pagamentos				                   ³±±
±±³          ³ ExpA1 := Matriz contendo as datas e valores para pagamentos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  											   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010DtVcto(	dDataEmis,		dDataForm,		cComboPag,		oPgtos,;
						aPgtos	)
Local lRet := .T.

If FunName() == "LOJA220" .AND.  ExistBlock("LJ220DATE")
	lRet := ExecBlock("LJ220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oListForma,aFormas})
ElseIf FunName() == "LOJA010" .AND. ExistBlock("Lj010DATE")
	lRet := ExecBlock("Lj010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAFORM",oPgtos,aPgtos})
Else
	If dDataBase <= dDataForm .AND. dDataForm >= dDataEmis
		lRet := .T.
	Else
		MsgStop(STR0080)
		lRet := .F.
	Endif
Endif			  

Return( lRet )	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010RetVConv³ Autor ³Vendas Clientes        ³Data  ³29/01/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retornar o valor da parcela convertido para a moeda           ³±±
±±³          ³ selecionada.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010RetVConv(ExpC1,ExpO1,ExpN1,ExpO2,ExpA1,ExpA2)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Moeda da parcela     				                 ³±±
±±³          ³ ExpO1 := Objeto referente ao combo da moeda da parcela        ³±±
±±³          ³ ExpN1 := Valor da parcela				                     ³±±
±±³          ³ ExpO2 := Objeto do get do valor da parcela                    ³±±
±±³          ³ ExpA1 := Matriz utilizada no combo da moeda da parcela        ³±±
±±³          ³ ExpA2 := Matriz com o valor da parcela em diversas moedas     ³±±
±±³          ³ ExpC2 := origem da chamada da rotina("BALCAO" ou "FRONT")     ³±±
±±³          ³ ExpC3 := tipo da venda("0"-Balcao, "1"-Front, "2"-Rapida)     ³±±
±±³          ³ ExpC4 := Forma de pagamento ($, US$, R$...)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010RetVConv( cMoedaTit,	oComboMoeda,	nValor,		oValor,;
						aCbxMoeda,	aVal,			cOrigem,	cTipoVenda,;
						cSimbMoeda )
Local oDlgConv
Local oLbx
Local oOk  	  := LoadBitMap(GetResources(), "LBOK")
Local oNo	  := LoadBitMap(GetResources(), "LBNO")
Local aSizes  := {05,40,25}
Local aFields := {" ",STR0085,STR0086}  //Valor###Moeda
Local nI      := 0
Local nOpc    := 0  
Local nValParc:= 0
Local lIgual  := .F.

DEFAULT cOrigem  := "BALCAO"

If Empty(aVal)
	For nI := 1 To Len(aCbxMoeda)
		nValParc := Round(xMoeda(nValor,oComboMoeda:nAt,nI,dDataBase,MsDecimais(nI)+1),MsDecimais(nI))
		AAdd(aVal,{-1,nValParc,aCbxMoeda[nI],MsDecimais(nI),nValParc,SuperGetMV("MV_SIMB"+AllTrim(Str(nI)))})
	Next nI
Else
	If aVal[ AScan( aVal, { |x| TRIM(x[3]) == TRIM(cMoedaTit)})][5] == nValor
		lIgual := .T.
	Endif

	For nI := 1 To Len(aCbxMoeda)
		If lIgual
			aVal[nI,1] := -1
			aVal[nI,2] := aVal[nI,5]
		Else                             
			nValParc := Round(xMoeda(nValor,oComboMoeda:nAt,nI,dDataBase,MsDecimais(nI)+1),MsDecimais(nI))
			aVal[nI,1] := -1
			aVal[nI,2] := nValParc
			aVal[nI,5] := nValParc
		Endif
	Next nI
Endif

If cOrigem == "BALCAO"
   DEFINE MSDIALOG oDlgConv FROM 12,65 TO 25,95 TITLE STR0084;  //"Selecao do Valor e da Moeda" 
   STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
ElseIf cTipoVenda == "1"  //Front
   DEFINE MSDIALOG oDlgConv FROM 12,65 TO 25,95 TITLE STR0084;  //"Selecao do Valor e da Moeda" 
   STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgFRT
ElseIf cTipoVenda == "2"  //Rapida
   DEFINE MSDIALOG oDlgConv FROM 12,65 TO 25,95 TITLE STR0084;  //"Selecao do Valor e da Moeda" 
   STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgRapid
Endif
//                      LS  CE  CD  LI
oLBx := TWBrowse():New(010,004,110,060,,aFields,aSizes,oDlgConv,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBx:SetArray(aVal)       
oLBx:bLDblClick	:= {|| Lj010MkBrw(@aVal,@oLbx)}
oLBx:bLine := {|| {If(aVal[oLBx:nAt,1]==-1,oNo,oOk),TransForm(aVal[oLBx:nAt,2],Tm(aVal[oLBx:nAt,2],16,aVal[oLBx:nAt,4])),aVal[oLBx:nAt,3]}}

DEFINE SBUTTON FROM 075,058 TYPE 1 ACTION (nOpc:=1,oDlgConv:End()) ENABLE OF oDlgConv
DEFINE SBUTTON FROM 075,088 TYPE 2 ACTION (nOpc:=2,oDlgConv:End()) ENABLE OF oDlgConv

ACTIVATE MSDIALOG oDlgConv

If nOpc == 1
	If ( nI := AScan( aVal, { |x| x[1] == 1 } ) ) > 0
		nValor := aVal[nI,2]
		oValor:Refresh()
			
		cMoedaTit  := aVal[nI,3]
		oComboMoeda:nAt := AScan( oComboMoeda:aItems, { |x| TRIM(x) == TRIM(cMoedaTit) } )
		oComboMoeda:Refresh()
		
		cSimbMoeda := aVal[nI,6]
	Endif
Endif

Return(Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010MkBrw   ³ Autor ³Vendas Clientes        ³Data  ³29/01/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controla a marca/desmarca realizada na selecao do valor da    ³±±
±±³          ³ parcela convertido.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010MkBrw(ExpA1,ExpO1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := Matriz com o valor da parcela em diversas moedas     ³±±
±±³          ³ ExpO1 := Objeto referente ao TWBrowse                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Lj010MkBrw(aVal,oLbx)
Local nPosCol := oLBx:ColPos 
Local nValParc:= aVal[oLBx:nAt,1]
                                    
If nPosCol == 1
	aEval(aVal,{|x,y| x[1]:=If(y <> oLBx:nAt,-1,1)})
ElseIf aVal[oLBx:nAt,1] == 1
	oLBx:ColPos := 2
	MaFisEditCell(@nValParc,oLBx,PesqPict("SL4","L4_VALOR",_PICTURE,oLBx:nAt),2,'Lj010VldGet()') 
Endif

oLBx:ColPos := 1
SysRefresh()
oLBx:Refresh()

Return(Nil)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010VldGet  ³ Autor ³Vendas Clientes        ³Data  ³29/01/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao do valor informado pelo usuario no        ³±±
±±³          ³ TWBrowse.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj010VldGet()                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := .T. para o dado valido e .F. para o dado invalido    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010VldGet()
Local lRet := .T.

If M->CELL <= 0
	lRet := .F.
EndIf

Return(lRet)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010SerArg  ³ Autor ³Vendas Clientes        ³Data  ³03/02/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica a serie da fatura/cupom fiscal dependendo do tipo de   ³±±
±±³          ³ cliente(Loc. Argentina)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj010SerArg()                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 := Serie                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj010SerArg()
Local cTipoCli   := ""
Local cSerieDoc  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Relacao Tipo de Cliente x Serie  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Tipo Cliente      ³ Serie        ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³E(Exportacao)   	 ³ E		    ³
//³F(Cons. Final)    ³ B            ³
//³M(Monotrib.)      ³ B            ³
//³N(Resp.Nao Insc.) ³ B            ³
//³S(Nap Sujeito)    ³ B            ³
//³X(Isento) 	     ³ B            ³
//³I(Inscrito)       ³ A            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipoCli  := SA1->A1_TIPO 
If cTipoCli == "E"	        
   cSerieDoc := "E"	   
ElseIf cTipoCli $ "F|M|N|S|X"
   cSerieDoc := "B"	   
Else
   cSerieDoc := "A"	   	      
Endif   

Return (cSerieDoc)
                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010EntreºAutor  ³Vendas Clientes     º Data ³  22/05/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a atualizacao dos dados de entrega nas variaveis       º±±
±±º          ³ (Executado como X3_VALID dos campos L1_CLIENT E L1_LOJENT) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Entrega()
Local lRet  := .T.
Local lMod3 := SuperGetMV( "MV_LJMOD3" ) //Parametro para conversao da tela de venda balcao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  para utilizar enchoice.   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(Upper(FunName())) $ "LOJA010/LOJA020"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿¿
	//Permitir que o codigo seja apagado, pois seu campo nao eh obrigatorio
	If Empty( &(ReadVar()) )
		If Type( "cCliEntrega") == "C" .AND. Type( "cLojEntrega") == "C"
			cCliEntrega := M->L1_CLIENT
			cLojEntrega := M->L1_LOJENT
		Endif
		Return lRet
	Endif
	
	If ReadVar() == "M->L1_CLIENT"
		lRet := ExistCpo( "SA1",M->L1_CLIENT,1 )
	ElseIf ReadVar() == "M->L1_LOJENT"
		lRet := ExistCpo( "SA1",M->L1_CLIENT + M->L1_LOJENT,1 )
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se o mesmo for utilizado na tela de venda balcao, as variaveis abaixo serao Privates|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMod3 .AND. lRet .AND. Type( "cCliEntrega") == "C" .AND. Type( "cLojEntrega") == "C"
		cCliEntrega := M->L1_CLIENT
		cLojEntrega := M->L1_LOJENT
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010ImpItºAutora ³Vendas Clientes     º Data ³  04/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressão dos Itens do orçamento para a Venda Concomitante  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - Venda Balcao Concomitante                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj010ImpIt()
Local lRet			:= .T.
Local nPosProd    	:= aPosicoes[9][2]
Local cRetImp	  	:= ""
Local nCont		  	:= 0

For nCont := 1 To Len(aCols)
	cRetImp := Lj010PRCC(aCols[nCont][nPosProd],"F",nCont)
	If Empty(cRetImp) .AND. AllTrim(cRetImp) <> "@BOTEXC@"
		lRet := .F.
		Exit
	Endif		
Next nCont

Return(lRet)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjItemLay    ³ Autor ³Vendas Clientes        ³Data  ³27/06/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o item do Lay-Away ja esta no aCols               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := LjItemLay(cNumLay,cItemLay)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjItemLay(cNumLay,cItemLay)
Local lItemaCols := .F.
Local nX         := 1
Local nPosLay    := AScan(aHeader,{|x| Alltrim(x[2]) == "L2_NUMLAY"})
Local nPosItLw   := AScan(aHeader,{|x| Alltrim(x[2]) == "L2_ITEMLAY"})
Local nPosProd	 := AScan(aHeader,{|x| Alltrim(x[2]) == "L2_PRODUTO"})

While nX <= Len(aCols) .AND. !lItemaCols
   If (aCols[nX][Len(aCols[nX])]) .OR. Empty(aCols[nX][nPosProd])
      nX++
	  Loop
   Endif		      
   If nPosLay > 0 .AND. nPosItLw > 0
      If cNumLay == aCols[nX][nPosLay] .AND. cItemLay == aCols[nX][nPosItLw]
         lItemaCols := .T.
      Endif
   Endif
   nX++
End

Return (lItemaCols)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010GrvRet  ³ Autor ³Vendas Clientes        ³Data  ³22/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as retencoes de IVA - Loc. Guatemala                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010GrvRet()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010GrvRet(nValorRet)
Local cNroCert	:=	GetCert("IVA  ",SL1->L1_CLIENTE+SL1->L1_LOJA+"IVA")
Local nVlrBase  := 0
Local nAliqImp  := 0

SFB->(DbSetOrder(1))
If SFB->(DbSeek(xFilial("SFB")+"IVA"))
   nAliqImp  := SFB->FB_ALIQ
   nVlrBase  := &("SL1->L1_BASIMP"+SFB->FB_CPOLVRO)
Endif

RecLock("SFE",.T.)
FE_FILIAL	:=	xFilial("SFE")
FE_NROCERT	:=	cNroCert
FE_EMISSAO  :=	dDataBase
FE_FORNECE  :=	SL1->L1_CLIENTE
FE_LOJA     :=	SL1->L1_LOJA
FE_TIPO     :=	"I"       //IVA
FE_PARCELA	:=	SE1->E1_PARCELA
FE_NFISCAL 	:=	SL1->L1_DOC
FE_SERIE	:=	SL1->L1_SERIE
FE_VALBASE	:=	nVlrBase
FE_VALIMP	:=	nValorRet
FE_PORCRET	:=	nAliqImp
FE_RETENC	:=	nValorRet
MsUnlock()

Return .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao para carregar o diretorio com empresa e filial para log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Lj010LogTef()
Return If( File(GetClientDir()+"SIGALOJA.INI") .AND. ;
       GetPvProfString("Logs TEF","Habilita","01",GetClientDir()+"SIGALOJA.INI") == "01", ;
       "\AUTOCOM\TEF"+cEmpAnt+cFilAnt+"\", "" )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010Transp  ³ Autor ³Vendas Clientes        ³Data  ³16/11/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para posicionar a transportadora digitada        		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010Transp(cCodTransp)
Local aArea := GetArea()
Local lRet  := .T.

DbSelectArea( "SA4" )
DbSeek(xFilial()+cCodTransp)

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SetARecJurºAutor  ³Vendas Clientes      º Data ³  11/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seta a variavel para controle dos acrescimos e decrescimos  º±±
±±º          ³ na Venda Balcao utilizando o ponto de entrada L010RecJur.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SetARecJur( aRecJur )

_aRecJur := aRecJur

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetARecJurºAutor  ³Vendas Clientes      º Data ³  11/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a variavel para controle dos acrescimos e           º±±
±±º          ³ decrescimos na Venda Balcao utilizando o ponto de entrada   º±±
±±º          ³ L010RecJur.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetARecJur()

Return _aRecJur

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010ReFilºAutor  ³Vendas Clientes      º Data ³  21/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera os valores das parcelas para que nao haja inconsis-  º±±
±±º          ³ tencia nessas parcelas.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1: Parcela Alterada                                     º±±
±±º          ³ ExpN2: Total das parcelas                                   º±±
±±º          ³ ExpA3: Array de parcelas                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010ReFill( nParcAlt, nTotParc, aParcelas )
Local nI		:= 0								//Variavel de apoio
Local nTotTemp 	:= 0								//Total das parcelas menos o valor da parcela alterada e das anteriores
Local nVlrTemp	:= 0								//Valor das parcelas que nao foram alteradas
Local nNumParc	:= Len( aParcelas ) - nParcAlt		//Numero de parcelas que serao alteradas (Somente a partir da parcela atual)

If nParcAlt <> Len( aParcelas ) .OR. Len( aPgtos ) == 1
	nTotTemp := nTotParc
	For nI := 1 To nParcAlt
	
		nTotTemp -= aParcelas[nI][2]					//Soma o valor das parcelas que nao sofrerao alteracao
	Next nI
	
	nVlrTemp	:= nTotTemp / nNumParc					//Calcula o novo valor das parcelas
	
	For nI := nParcAlt+1 To Len( aParcelas )
	
		aParcelas[nI][2] 	:= A410Arred( nVlrTemp, "L4_VALOR", nMoedaCor )
		nTotTemp 			-= A410Arred( nVlrTemp, "L4_VALOR", nMoedaCor )
	Next nI
Endif

Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_LJ010Par ºAutor  ³Vendas Clientes      º Data ³  02/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada do ponto de entrada LJ010Par, considerando mais de  º±±
±±º          ³ uma posicao no retorno e fazendo o tratamento de erro de    º±±
±±º          ³ executacao.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpD1 - Data da forma de pagto.                             º±±
±±º          ³ ExpN1 - Valor da forma de pagto                             º±±
±±º          ³ ExpC1 - Combo com as formas de pagto.                       º±±
±±º          ³ ExpC2 - Condicao da forma de pagto.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _LJ010Par( dDataForm, nValor, cComboPag, cCondicao )
Local xRet							// Retorno do ponto de entrada      
Local lRetorno		:= .F.			// Retorno da funcao
Local bOldError						// Retorno da funcao de controle de erro

Default cCondicao  := PadR( SuperGetMv( "MV_CONDPAD" ),3 )

If ExistBlock( "LJ010PAR" )    
	bOldError := ErrorBlock( {|x| LjVerifErro(x) } ) // muda code-block de erro
	Begin Sequence
		xRet := ExecBlock("Lj010PAR", .F., .F., { dDataForm, nValor, cComboPag, cCondicao })
		If ValType( xRet ) == "L"
			lRetorno := xRet 
		Elseif ValType( xRet ) == "A"
			lRetorno := xRet[ 1 ]
			cCondicao := xRet[ 2 ]
		Else
			Conout( "O retorno do ponto de entrada LJ010PAR não está de conforme esperado. Consulte a documentação." )
		Endif
	Recover
		lRetorno := .F.
	End	Sequence   
	ErrorBlock( bOldError ) // Restaura rotina de erro anterior
Endif

Return( lRetorno )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVerifErrºAutor  ³Vendas Clientes      º Data ³  02/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz o tratamento em caso de erro na execucaodo ponto de     º±±
±±º          ³ entrada.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpO1 - Objeto do erro                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjVerifErro( e )
Local lRet := .F.	   		// Retorno da funcao 

If e:gencode > 0  
	Conout( "Ocorreu o erro: " + e:DESCRIPTION ) 
	Conout( "Pilha de chamada: " + e:ERRORSTACK ) 
    lRet := .T.
    Break
Endif  

Return( lRet )
