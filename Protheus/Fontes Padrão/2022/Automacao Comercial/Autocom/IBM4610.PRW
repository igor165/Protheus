#INCLUDE "Protheus.ch"
#INCLUDE "IBM4610.CH"

Static oTimer

Function IBM4610_Dummy			// Funcao "Dummy" para poder gerar o Patch
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ LJIBM4610บAutor  ณ Cesar Valadao      บ Data ณ  24/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora IBM4610 para a biblioteca AUTOCOM     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ24/05/06 - 811 ณHomologacao da camada IBM4610 para funcionarบฑฑ
ฑฑบ          ณ               ณde maneira generica para outras impresoras. บฑฑ
ฑฑบ          ณ               ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
CLASS LJIBM4610
	DATA nHandle 		// Numero do Handle do equipamento
	DATA cBuffer		// Numero do Handle do equipamento
    DATA cPdv			// Numero do PDV, para a funcao IFEmulEcf
    DATA nValorPago		// Valor total das formas de pagamentos
    DATA nValorVenda	// Valor total das formas de pagamentos
    DATA nValorDesc		// Valor total de Descontos
    DATA cNumCaixa		// Numero do caixa
    DATA cNomeCaixa		// Nome do caixa
    DATA cNumCupom		// Numero sequencial de cupom
    DATA nItens			// Numero de Itens da Venda
    DATA nItemNumero	// Numero do Item atual
    DATA lVinculado		// Status da transcao Tef
	DATA nNumeroColunas	// Numero de colunas da impressora
	DATA cINIFile		// Caminho do arquivo IBM4610.INI
	DATA cFileLog		// Caminho do arquivo IBM4610.LOG
	DATA lFileLog		// Direciona todos os comandos para o arquivo IBM4610.LOG
	DATA cModelo		// Modelo da impressora homologada

	METHOD New()
    //Funcoes da Impressora Fiscal
	METHOD IFAbrir   	(cModelo, cPorta)
	METHOD IFFechar		(cPorta)
	METHOD IFAbrECF  	()
	METHOD IFFchECF		()
	METHOD IFLeituraX	()
	METHOD IFReducaoZ	(cMapaRes)
	METHOD IFStatus		(cTipo)	
	METHOD IFLeAliq  	()
	METHOD IFLeAliIss	() 
	METHOD IFLeConPag	() 
	METHOD IFMemFisc 	(cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo)	
	METHOD IFAdicAliq	(cAliquota, cTipo)
	METHOD IFAbrCNFis	(cCondicao, cValor, cTotalizador, cTexto)
	METHOD IFTxtNFis	(cTexto, nVias )
	METHOD IFFchCNFis	()
	METHOD IFAutentic	(cVezes, cValor, cTexto)
	METHOD IFSupr	 	(cTipo, cValor, cForma, cTotal, cModo)
	METHOD IFGaveta  	()	
	METHOD IFHrVerao	( cTipo )
	METHOD IFPegSerie	()
	METHOD IFPedido  	(cTef, cTexto, cValor)
	METHOD _Cabecalho 	()
	METHOD _Rodape		(cMensagem)
	METHOD IFAbreCup 	(cCliente)
	METHOD IFAlimProp	(cNumPdv, cNumCaixa, cNomeCaixa, cNumCupom)
	METHOD IFRegItem 	(cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt, cUnidade)
	METHOD IFPagto      (cPagto, cVinculado, nVlrTotal,aImpsSL1)
	METHOD IFFechaCup	(cMensagem , cVlrTotal )
	METHOD IFPegCupom	(cCancel)
	METHOD IFCancItem	(cNumItem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota ,cSupervisor, lImpIncl)
	METHOD IFCancCup	(cSupervisor)
	METHOD IFDescTot	(cVlrDesconto , cValorVenda)
	METHOD IFAcresTot	(cVlrAcrescimo)
	METHOD IFRelGer     (cTexto, nVias)
    //Funcoes da Impressora de cheque
	METHOD CHStatus		(cTipo)
	METHOD CHImprime	(cBanco, cValor, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso, cChancela )
	METHOD CHAbrir		(cModelo, cPorta)
	METHOD CHFechar		(cPorta )
    //Funcoes do PinPad
	METHOD PinpadAbr    (cModelo, cPorta )
	METHOD PinpadLeC    (cModalidade)
	METHOD PinpadFin    ()
	// Metodos auxiliares
	METHOD LeGravaINI	(cSecao, cVariavel, cConteudo)
ENDCLASS

METHOD New() CLASS LJIBM4610

::cINIFile := GetClientDir()+"ibm4610.ini"
::cFileLog := GetClientDir()+"ibm4610.log"
::lFileLog := (::LeGravaINI("Log", "Log dos Comandos", "0") == "1")

// Ticket de cancelamento padrao
::LeGravaINI("Ticket de Cancelamento", "L01", "C O M P R O B A N T E<Align>01</Align><Mode>00010000</Mode>")
::LeGravaINI("Ticket de Cancelamento", "L02", "Anulado<Align>01</Align><Mode>00010000</Mode>")

// Cabecalho do cupom
::LeGravaINI("Cabecalho", "L01", "Microsiga Intelligence - Mexico<Align>01</Align><Mode>00010000</Mode>")
::LeGravaINI("Cabecalho", "L02", "Privada de los Industriales, 106-110<Align>01</Align><Mode>10000000</Mode>")
::LeGravaINI("Cabecalho", "L03", "Jurica<Align>01</Align><Mode>10000000</Mode>")
::LeGravaINI("Cabecalho", "L04", "Queretaro - Mexico<Align>01</Align><Mode>10000000</Mode>")

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ IFAbrir  บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abertura da impressora fiscal                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAbrir(cModelo, cPorta) CLASS LJIBM4610
Local cCom		    := ::LeGravaINI("Comunicacao", "Port",		cPorta)
Local cBaud		    := ::LeGravaINI("Comunicacao", "Baud",		"9600")
Local cParity	    := ::LeGravaINI("Comunicacao", "Parity",	"NONE")
Local cDataBits	    := ::LeGravaINI("Comunicacao", "DataBits",	"8")
Local cStopBits	    := ::LeGravaINI("Comunicacao", "StopBits",	"2")
Local nRet			:= -1                                    // Retorno da Funcao

// Se o que esta no arquivo eh diferente do enviado, atualiza-o
cPorta := AllTrim(cPorta)
If cCom<>cPorta
	::LeGravaINI("Comunicacao", "Port", cPorta, .T.)
	cCom := cPorta
EndIf

If ::lFileLog
	// Direciona toda a saida en IBM4610.LOG
	nRet := 99999
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAbertura da porta de comunicacao                                              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ValType(oAutocom:oGaveta) <> 'O' .OR. oAutoCom:oGaveta:nHandle == NIL //Verifica se a porta ja nao foi aberta pela gaveta.
		nRet := CBOpenPort( cPorta    +":"+; 	//Porta
							cBaud     +","+;
							cParity   +","+;
							cDataBits +","+;
							cStopBits)
		
	Else
		nRet := oAutoCom:oGaveta:nHandle
	EndIf
EndIf
::nHandle := nRet

// Numero de colunas da impressora
::cModelo := AllTrim(cModelo)
If ::cModelo == "IBM 4610"
	::nNumeroColunas	:= Val(::LeGravaINI("Configuracao", "Numero de Colunas", "44"))
ElseIf cModelo == "EPSON TM-U220"
	::nNumeroColunas	:= Val(::LeGravaINI("Configuracao", "Numero de Colunas", "40"))
EndIf

Return(nRet)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFAcresTotบAutor  ณ Cesar Valadao      บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Acrescimo no total do cupom fiscal                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ26/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAcresTot(cVlrAcrescimo) CLASS LJIBM4610
Local nRet
Local cTexto
Local cMsgAcrescimo	:= ::LeGravaINI("Mensagens", "Acrescimo", "Acrescimo")

// Impressao da linha de acrescimo
cTexto := PadL(cMsgAcrescimo+Transform(Val(cVlrAcrescimo),PesqPict("SL1","L1_DESCONT")),::nNumeroColunas)
nRet := ImpIBM(cTexto)
If nRet == 0
	//Incrementa o valor do acrescimo no valor da venda
	::nValorVenda -= Val(cVlrAcrescimo)
EndIf   
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ IFDescTotบAutor  ณ Cesar Valadao      บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Desconto no total do cupom fiscal                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ26/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFDescTot(cVlrDesconto, cValorVenda) CLASS LJIBM4610
Local nRet
Local cTexto
Local cMsgDesconto 	:= ::LeGravaINI("Mensagens", "Desconto", "Descuento")
Local lExNormal 	:= .T.   	// Verifica se a execucao nao foi interrompida

DEFAULT cValorVenda :=  Nil

If ::nValorVenda == Nil
	lExNormal  := .F.
	::nValorVenda :=  Val(cValorVenda)
EndIf

// Impressao da linha de desconto
cTexto := PadL(cMsgDesconto+Transform(-1*Val(cVlrDesconto),PesqPict("SL1","L1_DESCONT")), ::nNumeroColunas)
nRet := ImpIBM(cTexto)
If nRet == 0 .AND. lExNormal 
	//Subtrae o valor do desconto no valor da venda
	::nValorVenda -= Val(cVlrDesconto)
EndIf   
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ IFCancCupบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cancelamento de cupom fiscal                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFCancCup(cSupervisor) CLASS LJIBM4610
Local nRet		:= 1
Local cTexto	:= "."
Local nI		:= 1  
Local cMsgSup	:= ::LeGravaINI("Mensagens", "Supervisor", "Supervisor")
DEFAULT ::nItens:= 0

// Se tem um cupom aberto nao imprime o cabecalho
If ::IFStatus("5") <> 7
	::_Cabecalho()								// Impressao do cabecalho do cupom fiscal
EndIf

ImpIBM("0A;")									// Pular uma linha

//Leitura do layout do Cupom de cancelamento
While !Empty(cTexto)
	cTexto := ::LeGravaINI("Ticket de Cancelamento", "L"+StrZero(nI,2), "")
	If !Empty(cTexto)
		nRet := ImpIBM(cTexto)
		nI++
	EndIf
End   
If nRet == 0
	cTexto := cMsgSup+" "+cSupervisor+"<Align>01</Align>"
	cTexto += CHR(10)
	cTexto += CHR(10)
	ImpIBM(cTexto)

	nRet := ::_Rodape()

	// Acerta o IBM4610.INI para informar que nao existe cupom aberto
	::LeGravaINI("Configuracao", "Cupom Aberto", "0", .T.)
EndIf
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFPegCupomบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retornar o numero do cupom fiscal                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPegCupom(cCancel) CLASS LJIBM4610
DEFAULT ::cNumCupom := StrZero(0,TamSx3("LG_COO")[1],0)

::cNumCupom := LJGetStation("COO")
oAutocom:cBuffer := ::cNumCupom

Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFCancItemบAutor  ณ Cesar Valadao      บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cancelar um item vendido                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ26/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFCancItem(	cNumItem		,cCodigo		,cDescricao		,cQtde			,;
				 	cVlrUnit		,cVlrDesconto	,cAliquota		,cSupervisor	,;
				 	lImpIncl		) CLASS LJIBM4610

Local nRet		:= 1
Local nVlrTot 	:= (Val(cQtde) * Val(cVlrUnit)) + Val(cVlrDesconto)
Local cTexto	:= ""
Local cMsgCancIT:= ::LeGravaINI("Mensagens", "Cancelamento de Item", "Articulo Anulado:")

DEFAULT cSupervisor :=  NIL
DEFAULT lImpIncl    := .T.


If cPaisLoc<>"BRA" 
	If !lImpIncl  
		// Recalcula o valor do item que sera cancelado (incluindo impostos)               
		nVlrTot	 := (nVlrTot * (1+Val(cAliquota)/100)) - Val(cVlrDesconto)   
	Else 
		nVlrTot  :=  nVlrTot - Val(cVlrDesconto)	
	EndIf			
Else
 	nVlrTot  := nVlrTot - Val(cVlrDesconto)
EndIf 	


//Impressao do cancelamento do item
cTexto	:= PadL(cMsgCancIT+" "+cNumItem+" "+Transform(-1*nVlrTot,PesqPict("SL2","L2_VLRITEM")), ::nNumeroColunas)
nRet := ImpIBM(cTexto)
If nRet == 0 .AND. ::nItens <> Nil
	::nItens		-= Val(cQtde)		//Subtrae o numero de itens vendidos
	::nValorVenda	-= nVlrTot			//Subtrae o valor do item da venda
EndIf   

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFFechaCupบAutor  ณ Cesar Valadao      บ Data ณ  24/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Finalizacao do cupom fiscal                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ24/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFFechaCup( cMensagem , cVlrTotal ) CLASS LJIBM4610
Local nRet		:= 1
Local cTexto	:= Repli("-",::nNumeroColunas)
Local nTroco	:= 0 
Local cMsgTroco	:= ::LeGravaINI("Mensagens",	"Troco",				"CAMBIO")
Local cMsgItems	:= ::LeGravaINI("Mensagens",	"Total de Items",		"Total de Articulos:")
Local lImpTotIT	:= ::LeGravaINI("Configuracao", "Imprime Total Items",	"1") == "1"

DEFAULT ::lVinculado 	:= .F.
DEFAULT cVlrTotal       := "" 

// Verifica se houve erro na gravacao
If ::nValorPago <> Nil .AND. ::nValorPago > Val(cVlrTotal) 
	nTroco := ::nValorPago - Val(cVlrTotal)
EndIf
   	
//As forma de pagamento feita nao paga a venda
If nTroco < 0
   Return(nRet)
EndIf   

// Imprime a linha de TROCO
If nTroco>0
	cTexto := Space(5)+cMsgTroco
	cTexto += PadL(AllTrim(Transform(nTroco,PesqPict("SL1","L1_VLRTOT"))), ::nNumeroColunas-Len(cTexto))
	nRet := ImpIBM(cTexto)
EndIf

If cPaisLoc == "MEX"
	// Imprime o valor por extenso
	ImpIBM(Chr(10)+Extenso(Val(cVlrTotal),,,,,,.T.)+Chr(10))
EndIf

// Imprimir numero de items
If lImpTotIT .AND. ::nItens <> Nil
	If nNumUltIt <> 0 // Caso a venda tenha sido retomada utiliza a numeracao do ultimo item impresso.
		ImpIBM(cMsgItems+" "+AllTrim(Str(nNumUltIt,6)))
	Else
		ImpIBM(cMsgItems+" "+AllTrim(Str(::nItens,6)))
	EndIf
EndIf 	

nNumUltIt	:= 0
nRet := ::_Rodape(cMensagem)

// Acerta o IBM4610.INI para informar que nao existe cupom aberto
::LeGravaINI("Configuracao", "Cupom Aberto", "0", .T.)

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ IFPagto  บAutor  ณ Cesar Valadao      บ Data ณ  24/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Registro das formas de pagamento na impressora fiscal      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ24/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPagto(cPagto, cVinculado, nVlrTotal,aImpsSL1) CLASS LJIBM4610
Local nRet		:= -1
Local cTexto	:= Repli("-",::nNumeroColunas)
Local aAuxiliar := {}
Local nI		:= 0
Local cMsgTotal	:= ::LeGravaINI("Mensagens",	"Total", "TOTAL")
Local cImpostos	:= ::LeGravaINI("Configuracao",	"Impostos Nao Imprime", "IVC")

//imprime linha deparacao itensxTotalXforma de pagamentos
ImpIBM(cTexto)

// Impressao do Total
cTexto := Space(5)+cMsgTotal
cTexto += PadL(AllTrim(Transform(nVlrTotal,PesqPict("SL1","L1_VLRTOT"))), ::nNumeroColunas-Len(cTexto))
ImpIBM(cTexto)

If cPaisLoc <> "BRA"
	//Impressao dos impostos no cupom
	aAreaSFB := SFB->(GetArea())
	SFB->(dbSetOrder(1))
	For nI := 1 To Len(aImpsSL1)
		// Verifica se os impostos devem ser impressos ou nao
		If !(aImpsSL1[nI][1] $ cImpostos)
			SFB->(MsSeek(xFilial("SFB")+aImpsSL1[nI][1]))
			cTexto := Space(5)+AllTrim(SubStr(SFB->FB_DESCR,1,20))
			cTexto += PadL(AllTrim(Transform(aImpsSL1[nI][3],PesqPict("SL1","L1_VLRTOT"))), ::nNumeroColunas-Len(cTexto))
			ImpIBM(cTexto)
		EndIf
	Next nI
EndIf

// Monta um array auxiliar com os pagamentos solicitados
aAuxiliar	:= AClone(MontArray(cPagto))
::nValorPago:= 0
::lVinculado:= cVinculado=="1" // Venda com TEF, 
cTexto		:= ""
nI			:= 1
While nI < Len(aAuxiliar)
	::nValorPago += Val(aAuxiliar[nI+1])

	//Impressao das linhas de pagamento
	cTexto := Space(5)+AllTrim(aAuxiliar[nI])
	cTexto += PadL(AllTrim(Transform(Val(aAuxiliar[nI+1]),PesqPict("SL1","L1_VLRTOT"))), ::nNumeroColunas-Len(cTexto))
	If ImpIBM(cTexto)==0
	   nRet := 0
	EndIf   
	nI += 2
End

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ IFRegItemบAutor  ณ Cesar Valadao      บ Data ณ  24/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Registro do item na impressora fiscal                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ24/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFRegItem(cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt, cUnidade) CLASS LJIBM4610
Local nRet				:= -1
Local cTexto			:= ""
Local cMsgDesconto		:= ::LeGravaINI("Mensagens", "Desconto", "Descuento")

DEFAULT	::nItens		:= 0
DEFAULT	::nItemNumero	:= 0
DEFAULT ::nValorVenda	:= 0

::nItens		+= Val(cQtde)						// Incrementa a propriedade do Numero de itens vendidos
::nItemNumero	+= 1								// Incrementa a propriedade do Numero do item
::nValorVenda	+= Val(cVlTotIt)					// Incrementa o valor vendido

cDescricao		:= AllTrim(cDescricao)

cQtde	:= If(Val(cQtde)-Int(Val(cQtde))==0, Str(Val(cQtde),7,0), PadL(cQtde,7))
cVlTotIt:= AllTrim(Trans(Val(cVlTotIt),PesqPict("SL2","L2_VLRITEM",13)))
// Impressao completa dos items
If ::LeGravaINI("Configuracao", "Impressao Completa", "1") == "1"
	//Impressao da 1a linha do item
    If nNumUltIt <> 0 // Caso a venda tenha sido retomada utiliza a numeracao do ultimo item impresso.
    	nNumUltIt++
    	cTexto	:= StrZero(nNumUltIt,3)+" "+;
				   Left(cCodigo,15)+;
				   cQtde+" "
    Else 
		cTexto	:= StrZero(::nItemNumero,3)+" "+;
				   Left(cCodigo,15)+;
				   cQtde+" "
	EndIf
	
	cTexto	+= PadL(cVlTotIt, ::nNumeroColunas-Len(cTexto))
	nRet := ImpIBM("1B;61;00;"+cTexto)

	// Impressao da 2a linha do item
	cTexto := "    "+Substr(cDescricao,1,::nNumeroColunas-4)
	nRet := ImpIBM("1B;61;00;"+cTexto)
	If Len(cDescricao) > ::nNumeroColunas-4
		// Impressao da 3a linha do item
		cTexto := "    "+Substr(cDescricao,::nNumeroColunas-4,999)
		nRet := ImpIBM("1B;61;00;"+cTexto)
	EndIf
Else
//Impressao simplificada do item - somente descricao e valor total do item
	cTexto	:= Substr(cDescricao,1,::nNumeroColunas-Len(cVlTotIt)-1)+" "+cVlTotIt
	nRet	:= ImpIBM("1B;61;00;"+cTexto)
EndIf

//Impressao da linha de desconto
If Val(cVlrDesconto)>0
	cTexto	:= PadL(cMsgDesconto+Transform(Val(cVlrDesconto),PesqPict("SL2","L2_VALDESC")),::nNumeroColunas)
	nRet	:= ImpIBM(cTexto)
EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ_CabecalhoบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao do cabecalho do cupom para todos os metodos      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD _Cabecalho() CLASS LJIBM4610
Local nRet
Local cTexto	:= "."
Local nI		:= 1
Local cLogo		:= ::LeGravaINI("Cabecalho", "Logo",	"")
Local cMsgPDV	:= ::LeGravaINI("Mensagens", "PDV",	"PDV:")
Local cMsgCOO	:= ::LeGravaINI("Mensagens", "COO",	"Folio:")
Local cAlign
Local cModo

DEFAULT ::cNomeCaixa	:= ""
DEFAULT ::cPDV			:= ""
DEFAULT	::cNumCupom		:= ""

cAlign 	:= FncTag("Align",@cLogo)
cModo	:= FncTag("Mode", @cLogo)

If !Empty(cLogo)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComando: Alinhar a impressao                                ณ
	//ณSyntax :'1B61;n'                                            ณ
	//ณwhere: n The type position                                  ณ
	//ณ       00 Align Left                                        ณ
	//ณ       01 Align Center                                      ณ
	//ณ       02 Align Rigth                                       ณ
	//ณ       04 Align Column Rigth                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nRet := IBMCmd("1B;61;"+cAlign+";") 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComando: Print predefined graphics (logo)                   ณ
	//ณSyntax : '1D2F;m;logo#'                                     ณ
	//ณwhere: m The dot-density:                                   ณ
	//ณ            00 Normal Print                                 ณ
	//ณ            01 Double wide                                  ณ
	//ณ            02 Double wide and high                         ณ
	//ณ.logo # The number associated with the logo that is stored. ณ
	//ณrange = 1 to 40 for all models except                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nRet := IBMCmd("1D;2F;"+cModo+";"+cLogo+";") // Pagina 154
EndIf

//Imprime um Texto no cabecalho do cupom
While !Empty(cTexto)
	cTexto := ::LeGravaINI("Cabecalho", "L"+StrZero(nI,2), "")
	If !Empty(cTexto)
		nRet := ImpIBM(cTexto)
		nI++
    EndIf
End

ImpIBM(Chr(10))						// Pula uma linha
nRet := IBMCmd("1B;61;00;")			// Alinha a esquerda

// Imprime Data/Hora/Usuario
cTexto := DToC(dDataBase)+Space(5)+Time()
cTexto += PadL(AllTrim(Substr(::cNomeCaixa,1,30)), ::nNumeroColunas-Len(cTexto))
nRet := ImpIBM(cTexto)

// Imprime PDV/COO
cTexto := PadL(cMsgPDV+" "+::cPdv+"     "+cMsgCOO+" "+::cNumCupom, ::nNumeroColunas)
nRet := ImpIBM(cTexto)

ImpIBM(Chr(10))						// Pula uma linha

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ _Rodape  บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao do rodape do cupom para todos os metodos         บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD _Rodape(cMensagem) CLASS LJIBM4610
Local nRet			:= 1
Local cTexto		:= "."
Local nI			:= 1
Local cMsgLoja		:= ::LeGravaINI("Mensagens", "Loja",	"Tienda:")
Local cMsgPDV 		:= ::LeGravaINI("Mensagens", "PDV",	"PDV:")

DEFAULT cMensagem	:= ""

// Imprime a mensagem de MV_LJFISMS ou LG_MSGCUP
If cMensagem<>""
	ImpIBM(Repli("-",::nNumeroColunas))
	ImpIBM(cMensagem)
EndIf
ImpIBM(Repli("-",::nNumeroColunas))

// Imprime Data/Hora/Loja/PDV
cTexto	:= DToC(dDataBase)+"  "+Time()+"  "+cMsgLoja+cFilAnt
cTexto	+= PadL(cMsgPDV+AllTrim(cEstacao), ::nNumeroColunas-Len(cTexto))
nRet	:= ImpIBM(cTexto)

While !Empty(cTexto)
	cTexto := ::LeGravaINI("Rodape", "L"+StrZero(nI,2), "")
	If cTexto<>""
		nRet := ImpIBM(cTexto)
		nI++
	EndIf
End   
ImpIBM(Repl("X",::nNumeroColunas))				// Linha para fechar o cupom
IBMCmd("0A;0A;0A;0A;0A;")						// Avancar o suficiente para cortar o papel

If ::LeGravaINI("Rodape", "Cortar Papel", "1") == "1"
	IBMCmd("1B;6D;")							// Cortar o papel
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ IFAbreCupบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abertura do cupom fiscal                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAbreCup(cCliente) CLASS LJIBM4610
Local nRet		:= -1
Local cMsgCabIT

// Impressao completa dos items
If ::LeGravaINI("Configuracao", "Impressao Completa", "1") == "1"
	cMsgCabIT := ::LeGravaINI("Cabecalho", "Items Completa",		"Art.Codigo         Cantidad       $Valor")
Else
	cMsgCabIT := ::LeGravaINI("Cabecalho", "Items Simplificada",	"Descripcion                       $Valor")                                      
EndIf
cMsgCabIt := PadR(cMsgCabIt, ::nNumeroColunas)

// Impressao do cabecalho do cupom
::_Cabecalho()

// Imprime linha de cabecalho dos itens com underline
nRet := IBMCmd("1B;2D;01;"+cMsgCabIT+";1B;2D;00;")
If nRet == 0
    // Se conseguiu abrir o cupom grava no IBM4610 que existe um cupom aberto. 1=Aberto 0=Fechado
	::LeGravaINI("Configuracao", "Cupom Aberto", "1", .T.)

	// Inicializa os valores das properties de acumulos de vanda
  	::nValorPago  := 0
  	::nValorVenda := 0
  	::nItens      := 0
  	::nItemNumero := 0

  	// Inicializa o arquivo de Log
  	// desenvolver um arquivo para que caso a venda seja interrompida continue de onde parou...
EndIf	
Return(nRet)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFAlimPropบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega propriedades 									  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAlimProp(cNumPDV, cNumCaixa, cNomeCaixa, cNumCupom) CLASS LJIBM4610
::cPDV       := cNumPDV
::cNumCaixa  := cNumCaixa
::cNomeCaixa := cNomeCaixa
::cNumCupom  := cNumCupom

Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFPegSerieบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Pega serie - nao disponivel								  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPegSerie() CLASS LJIBM4610

oAutocom:cBuffer := "Funcao nao disponivel"

Return(1)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFPedido  บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Pedido - nao disponivel 									  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPedido(cTef, cTexto, cValor) CLASS LJIBM4610

aBuff := ""

Return(0)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFHrVerao บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Horario de verao - nao disponivel 						  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFHrVerao( cTipo ) CLASS LJIBM4610

Return(0)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFGaveta  บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Horario de verao - nao disponivel 						  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFGaveta() CLASS LJIBM4610
Local nRet

If ::LeGravaINI("Gaveta", "Gaveta1", "1") == "1"
	nRet := IBMCmd("1B;70;31;28;A8;")						// Abertura da Gaveta 1
EndIf
If ::LeGravaINI("Gaveta", "Gaveta0", "1") == "1"
	nRet := IBMCmd("1B;70;30;28;A8;")						// Abertura da Gaveta 0
EndIf

Return (nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFTxtNFis บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime texto nao fiscal 								  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFTxtNFis(cTexto, nVias ) CLASS LJIBM4610
Local nRet	:=1
Local cLinha:=""
Local nC	:=0
Local nV	:=0
Local cAux	:=""

DEFAULT ::lVinculado 	:= .F.

For nV := 1 to nVias
	cAux:=cTexto
	While !empty(cAux)
		nC++
		If !(Subs(cAux,nC,1)=Chr(10).OR.Subs(cAux,nC,1)==CHR(13).OR.nC>40)
			cLinha+=Subs(cAux,nC,1)
		Else
			nRet := ImpIBM(cLinha)
			If nRet=1
				Exit
			EndIf
			cAux:=Subs(cAux,nC+1)
			nC	  :=0
			cLinha:=""
		EndIf
	End
    If ::lVinculado
       IBMCmd("0C;")
    EndIf	
Next nV

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFRelGer  บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio gerencial 										  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFRelGer(cTexto, nVias) CLASS LJIBM4610
Local nRet	:=1
Local cLinha:=""
Local nC	:=0
Local nV	:=0
Local cAux	:=""

::_Cabecalho()

For nV := 1 to nVias
	cAux:=cTexto
	While !empty(cAux)
		nC++
		If !(Subs(cAux,nC,1)=Chr(10).OR.Subs(cAux,nC,1)==CHR(13).OR.nC>40)
			cLinha += Subs(cAux,nC,1)
		Else
			nRet := ImpIBM(cLinha)
			If nRet=1
				Exit
			EndIf
			cAux:=Subs(cAux,nC+1)
			nC	  :=0
			cLinha:=""
		EndIf
	End
    //Comando de Cortar o Papel
    IBMCmd("0C;")
Next nV

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFSupr    บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Suprimentos - nao disponivel 							  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFSupr(cTipo, cValor, cForma, cTotal, cModo) CLASS LJIBM4610
Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFAutenticบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Autenticacao - nao disponivel 							  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAutentic(cVezes, cValor, cTexto) CLASS LJIBM4610
Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFFchCNFisบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fecha cupom nao fiscal  - nao disponivel 				  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFFchCNFis() CLASS LJIBM4610
Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFAbrCNFisบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abre cupom nao fiscal  									  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAbrCNFis(cCondicao, cValor, cTotalizador, cTexto) CLASS LJIBM4610
::_Cabecalho()
Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFAdicAliqบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Adiciona aliquota 										  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAdicAliq(cAliquota, cTipo) CLASS LJIBM4610
Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFMemFisc บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Leitura da memoria fiscal - nao disponivel 				  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFMemFisc(cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo)	CLASS LJIBM4610
Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFLeConPagบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Leitura da condicao de pagamento - nao disponivel 		  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFLeConPag() CLASS LJIBM4610
oAutocom:cBuffer:=""

Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFLeAliq  บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Leitura da aliquota 									      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFLeAliq() CLASS LJIBM4610
// esse retorno foi colocado dessa forma pq. o sistema estava pedindo uma
// aliquota para fazer a venda. Depois que for localizado a parte de impostos
// poderแ ser excluida daqui
oAutocom:cBuffer := ::LeGravaINI("Configuracao", "Aliquotas ICMS", "0.00|18.00|7.00|12.00|5.00")

Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFLeAliIssบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Leitura da aliquota ISS								      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFLeAliIss(aBuff) CLASS LJIBM4610
// esse retorno foi colocado dessa forma pq. o sistema estava pedindo uma
// aliquota para fazer a venda. Depois que for localizado a parte de impostos
// poderแ ser excluida daqui
oAutocom:cBuffer := ::LeGravaINI("Configuracao", "Aliquotas ISS", "0.00|5.00")

Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFReducaoZบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Reducao Z											      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFReducaoZ() CLASS LJIBM4610
oAutocom:cBuffer:=""

Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFLeituraXบAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Leitura X											      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFLeituraX() CLASS LJIBM4610
Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFFchECF  บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fecha ECF											      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFFchECF() CLASS LJIBM4610

Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณIFAbrECF  บAutor  ณ Cesar Valadao      บ Data ณ  25/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abre ECF											      	  บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ25/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAbrECF() CLASS LJIBM4610
Local nRet:=-1

If ::nHandle<>-1
  	nRet:=0
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณ IFStatus บAutor  ณ Cesar Valadao      บ Data ณ  26/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o status da impressora fiscal                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ26/05/06 - 811 ณHomologacao EPSON TM-U220                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFStatus(cTipo) CLASS LJIBM4610
Local nRet
//Tipo - Indica qual o status quer se obter da impressora
//  1 - Obtem a Hor da Impressora
//  2 - Obtem a Data da Impressora
//  3 - Verifica o Papel
//  4 - Verifica se ้ possํvel cancelar um ou todos os itens.
//  5 - Cupom Fechado ?
//  6 - Ret. suprimento da impressora
//  7 - ECF permite desconto por item
//  8 - Verifica se o dia anterior foi fechado
//  9 - Verifica o Status do ECF
// 10 - Verifica se todos os itens foram impressos.
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
// 13 - Verifica se o ECF Arredonda o Valor do Item
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
// 16 - Verifica se exige o extenso do cheque  
oAutocom:cBuffer := ""
If cTipo=="1" 		// Hora da Impressora
	oAutocom:cBuffer := Time()
	nRet := 0
ElseIf cTipo=="2" 	// Data Impressora
	oAutocom:cBuffer := DToC(dDataBase)
	nRet := 0
ElseIf cTipo=="3" 	// Verifica o Papel
	nRet := 0
ElseIf cTipo=="4" 	// Verifica se ้ possํvel cancelar um ou todos os itens.
	oAutocom:cBuffer := "Todos"
	nRet := 0
ElseIf cTipo=="5" 	// Cupom Fechado ?
	nRet := If(::LeGravaINI("Configuracao", "Cupom Aberto", "0")<>"0", 7, 0)
ElseIf cTipo=="6" 	// Ret. suprimento da impressora
	oAutocom:cBuffer := "0.00"
	nRet := 0
ElseIf cTipo=="7" 	// ECF permite desconto por item
    nRet := 11
ElseIf cTipo=="8" 	// Verifica se o dia anterior foi fechado
    nRet := 0
ElseIf cTipo=="9" 	// Verifica o Status do ECF
    nRet := 0
ElseIf cTipo=="10" 	// Verifica se todos os itens foram impressos.
    nRet := 0
ElseIf cTipo=="11" 	// Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
    nRet := 0
ElseIf cTipo=="12" 	// Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
    nRet := 1
ElseIf cTipo=="13" 	// Verifica se o ECF Arredonda o Valor do Item
    nRet := 1
ElseIf cTipo=="15" 	// Verifica se o ECF permite desconto apos registrar o item (0=Permite)
    nRet := 1
ElseIf cTipo=="16" 	// Verifica se exige o extenso do cheque
    nRet := 1
Elseif cTipo == "45"

        nRet := 0 

Elseif cTipo == "46"

        nRet := 0
Else
	nRet := 1
EndIf   

Return(nRet)


METHOD IFFechar(cPorta) CLASS LJIBM4610
Local nRet := -1

If FClose(::nHandle)
   ::nHandle:= NIL
   nRet		:= 0
EndIf   

Return(nRet)


//------------------------------------------------------------------------------------------------------
//Funcoes da Impressora de cheque
METHOD CHAbrir(cModelo, cPorta) CLASS LJIBM4610
Return(0)


METHOD CHImprime(cBanco, cValor, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso, cChancela) CLASS LJIBM4610
Local nRet		:= 1
Local cPosData	:= ::LeGravaINI("Cheque-"+cBanco, "Posicao da Data",		"10,45")
Local cPosFav	:= ::LeGravaINI("Cheque-"+cBanco, "Posicao do Favorecido",	"06,00")
Local cPosVal 	:= ::LeGravaINI("Cheque-"+cBanco, "Posicao do Valor",		"08,00")
Local cPosExt	:= ::LeGravaINI("Cheque-"+cBanco, "Posicao do Extenso",		"01,00")
Local cPosMsg	:= ::LeGravaINI("Cheque-"+cBanco, "Posicao da Mensagem",	"08,45")
Local cPosVers	:= ::LeGravaINI("Cheque-"+cBanco, "Posicao do Verso",		"02,00")
Local aAuxCh	:= {}
Local aImpCh	:= Array(10)
Local nI		:= 0
Local nPos		:= 0
Local nLin		:= 0

aFill(aImpCh,"")
//Inserindo no array as coordenadas de impressao e a informacao a ser impressa
aadd(aAuxCh,{Subs(cPosData,1,2),Subs(cPosData,4,2),cData})		//Data
aadd(aAuxCh,{Subs(cPosFav,1,2),Subs(cPosFav,4,2),cFavorec}) 	//Favorecido
aadd(aAuxCh,{Subs(cPosVal,1,2),Subs(cPosVal,4,2),Transform(Val(cValor),PesqPict("SL1","L1_VLRTOT"))}) 		//Valor
aadd(aAuxCh,{Subs(cPosExt,1,2),Subs(cPosExt,4,2),cExtenso}) 	//Extensao
aadd(aAuxCh,{Subs(cPosMsg,1,2),Subs(cPosMsg,4,2),cMensagem}) 	//Mensagem

//Ordenando a sequencia de impressao, pois posso imprimir mais de uma informacao em uma mesma linha
asort(aAuxCh,,,{|x,y| x[1]+x[2]< y[1]+y[2]})

// Inserir no array de linhas o que sera impresso em cada linha
For nI :=1 to Len(aAuxCh)
  nLin:=Val(aAuxCh[nI,1])
  nPos:=Val(aAuxCh[nI,2])
  aImpCh[If(nLin>Len(aImpCh),Len(aImpCh),nLin)]+=Space(nPos)+aAuxCh[nI,3]
Next nI
nRet:=IBMCmd("1B;63;30;08;")//Habilita impressao de cheque no modo Paisagem
//Faz a impressao do Cheque
For nI :=1 to Len(aImpCh)
	ImpIBM(aImpCH[nI])
Next nI
//Inicializando o Vetor, de impressao de linhas
//para colocar a impressao do verso, na linha especificada.
aFill(aImpCh,"")
nLin:=Val(Subs(cPosVers,1,2))
nPos:=Val(Subs(cPosVers,4,2))
aImpCh[If(nLin>Len(aImpCh),Len(aImpCh),nLin)]+=Space(nPos)+cVerso
//Faz a impressao do Verso do Cheque
If !empty(cVerso) 
   MsgInfo(STR0013) //"Insira o verso do Cheque e tecle <Enter>"
	For nI :=1 to Len(aImpCh)
		ImpIBM(aImpCH[nI])
	Next nI
EndIf
// Habilita impressao dos documento na impressora termica
nRet:=IBMCmd("1B;63;30;02;") 	

Return (nRet)


METHOD ChStatus(cTipo) CLASS LJIBM4610
Local nRet := 1                                             
//Tipo - Indica qual o status quer se obter da impressora
//  1 - necessแrio enviar o extenso do cheque para a SIGALOJA.DLL ?
//  0 - Sim      1 - Nใo
oAutocom:cBuffer:="" 

Return(nRet)

//------------------------------------------------------------------------------------------------------
//Funcoes do PinPad
METHOD PinpadFin() CLASS LJIBM4610
Return(0)

METHOD PinpadAbr(cModelo, cPorta ) CLASS LJIBM4610
Return(0)

METHOD PinpadLeC(cModalidade) CLASS LJIBM4610
Local nRet:=1

oAutocom:cBuffer:=IBMLerPinPad(cModalidade,@cBuffer)
nRet := IIf(Len(oAutocom:cBuffer)>10,0,1)

Return (nRet)

METHOD CHFechar(cPorta ) CLASS LJIBM4610
Return(0)                                  

//------------------------------------------------------------------------------------------------------
METHOD LeGravaINI(cSecao, cVariavel, cConteudo, lForcaGrv) CLASS LJIBM4610
Local cRet := GetPvProfString(cSecao+"-"+cEstacao, cVariavel, "ERROR", ::cINIFile)

If cRet == "ERROR" .OR. lForcaGrv			// Se nao existe a variavel ou esta forcando a gravacao,
	cRet := cConteudo						// Grava no arquivo IBM4610.INI
	If !Empty(cConteudo)
		WritePProString(cSecao+"-"+cEstacao, cVariavel, cConteudo, ::cINIFile)
	EndIf
EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณImpIBM       ณ Autor ณ Marcos Alves       ณ Data ณ 01/11/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Impressao de texto na impressora IBM 4610                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ ExpN1 := ImpIBM(ExpC1,ExpC2,ExpC3)                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 -> String a ser impressa                             ณฑฑ
ฑฑณ          ณ ExpC2 -> Alinhamento da impressao, onde:                   ณฑฑ
ฑฑณ          ณ          0 - Esquerda                                      ณฑฑ
ฑฑณ          ณ          1 - Central                                       ณฑฑ
ฑฑณ          ณ          2 - Direita                                       ณฑฑ
ฑฑณ          ณ ExpC3 -> Formato da impressao               		          ณฑฑ
ฑฑณ          ณ          Bit                          Bit=0 		Bit=1     ณฑฑ
ฑฑณ          ณ    LSB   0 - Caracter/Paginas 0		Tabela A	Tabela A  ณฑฑ
ฑฑณ          ณ          1 - Caracter/Paginas 1		Tabela A    Tabela A  ณฑฑ
ฑฑณ          ณ          2 - Fundo Preto/letraBranca Cancela		Habilita  ณฑฑ
ฑฑณ          ณ          3 - Negritro				Cancela		Habilita  ณฑฑ
ฑฑณ          ณ          4 - Dobro-altura			Cancela		Habilita  ณฑฑ
ฑฑณ          ณ          5 - Dobro-Largura			Cancela		Habilita  ณฑฑ
ฑฑณ          ณ          6 - Modo Invertido			Cancela		Habilita  ณฑฑ
ฑฑณ          ณ    MSB   7 - Sublinhado				Cancela		Habilita  ณฑฑ
ฑฑณ          ณ    MSB   7 - Sublinhado				Cancela		Habilita  ณฑฑ
ฑฑณ          ณ 		-----------------------------------------             ณฑฑ
ฑฑณ          ณ 		Tabela A:                                             ณฑฑ
ฑฑณ          ณ 		Bit 0	Bit 1	Termica 		Matricial			  ณฑฑ
ฑฑณ          ณ 		0		0		Font A			Font A				  ณฑฑ
ฑฑณ          ณ 		1		0		Font B			Font B				  ณฑฑ
ฑฑณ          ณ 		0		1		Font C			Font A				  ณฑฑ
ฑฑณ          ณ 		1		1		Reservado       Font B                ณฑฑ
ฑฑณ          ณ 		-----------------------------------------             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorna	 ณ ExpN1 -> Numero decimal 									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ LOJA010T 												  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpIBM(cTexto)
Local nRet		:=1
Local cAlign 	:= FncTag("Align",@cTexto)
Local cModo		:= FncTag("Mode",@cTexto)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConfigurar Alinhamento do Texto                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nRet := IBMCmd("1B;61;"+StrZero(Val(cAlign),2)+";") 	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConfigurar formato de impressao do texto                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(cModo) = 8
	cModo := Bin2Hex( cModo ) // Transformar em Hex.
Endif	
nRet := IBMCmd("1B;21;"+cModo+";") 	//Configurar formato
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImpressao do Texto   								       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nRet := IBMCmd(cTexto+";0A;")	//Imprime e salta uma linha

Return(nRet)


Static Function IBMCmd(cCmd)
Local nWrite	:= -1
Local cAux		:= ""
Local cCmdDec	:= ""
Local nPos		:= 0
Local nHandle	:= oAutocom:oImpFisc:nHandle
Local lImpIBMLog:= ExistBlock( "IMPIBMLOG" ) // Ponto de Entrada que permite controlar a impressao de log na IBM4610
Local lRet      := .T.                       // Verifica se a impressao sera realizada
Local xRet                                   // Retorno do ponto de entrada IMPIBMLOG

While Len(cCmd)>0
    //Verifica se ha texto a ser impresso
    //pq os comandos da impressora sao em hexadecimal de
    //dois bytes
    nPos:=At(";",cCmd)
    If nPos>3
       //Texto a ser impresso
       cCmdDec+=Subs(cCmd,1,nPos-1)
    ElseIf nPos==3
        //Comandos a ser executados
        cAux:=Subs(cCmd,1,nPos-1)
		cCmdDec+=CHR(L010Hex2Dec(cAux)) 
    EndIf
    cCmd:=Subs(cCmd,nPos+1)
End  


If lImpIBMLog
	xRet := ExecBlock("IMPIBMLOG", .F., .F., {@cCmdDec})
	If ValType( xRet ) == "L"
		lRet := xRet
	EndIf
EndIf

If lRet 
	If oAutocom:oImpFisc:lFileLog
		// Grava os comandos enviados a impressora no arquivo IBM4610.LOG
		LJWriteLog(oAutocom:oImpFisc:cFileLog, DToC(dDataBase)+" "+Time()+"  -> "+cCmdDec)
	Else
		//Escreve o texto e comando na impressora
		nWrite := FWrite(nHandle,cCmdDec)
	EndIf
EndIf	

Return 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณL010Hex2Dec()ณ Autor ณ Sergio / Luiz 	    ณ Data ณ 12/06/97 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Converte um numero Hexadecimal para decimal ate' 65535     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ ExpN1 := L010Hex2Dec( ExpC1 ) 							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 -> String a converter ( ate 4 bytes )				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorna	 ณ ExpN1 -> Numero decimal 									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ LOJA010T 												  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L010Hex2Dec(cVal)

Local cString := "0123456789ABCDEF"
Local nVal    := 0

If Len(cVal) < 4
	cVal:= Replicate("0", 4 - Len(cVal) ) + cVal
Endif
nVal := ( At( Left( cVal, 1 )   , cString ) - 1  ) * 4096
nVal += ( At( Substr( cVal, 2, 1 ), cString ) - 1  ) * 256
nVal += ( At( Substr( cVal, 3, 1 ), cString ) - 1  ) * 16
nVal += ( At( Substr( cVal, 4, 1 ), cString ) - 1  )

Return( nVal )

/*
//----------------------------------------------------------------------------
Static Function Hex2Bin( cHex )

LOCAL nX, cChar, nPos
LOCAL cRet := ''
LOCAL cAux := '0123456789ABCDEF'
LOCAL aHex := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
                '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }

For nX := 1 To Len( cHex )
	cChar := SubStr( cHex, nX, 1 )
	nPos  := At( cChar, cAux )
	If nPos <> 0
		cRet += aHex[nPos]
	EndIf
Next

Return( cRet )
*/

Static Function Bin2Hex( cBin )

Local cChar
Local nPos
Local cRet := ''
Local cAux := '0123456789ABCDEF'
Local aBin := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
                '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
While !Empty(cBin)
	cChar := SubStr( cBin,1,4)
	nPos:=Ascan(aBin,cChar)
	If nPos <> 0
		cRet += Subs(cAux,nPos,1)
	EndIf
	cBin:=Subs(cBin,5)
End

Return( cRet )


Static Function FncTag(cTag,cTexto)
Local cRet		:="01"
Local nPosIni	:=0
Local nPosFim	:=0
Local cAux		:=cTexto

nPosIni:=At("<"+Upper(cTag)+">",Upper(cAux))
If nPosIni<>0
	nPosFim:=At("</"+cTag+">",cAux)
	If nPosFim<>0
		cTexto:=Stuff(cTexto,nPosIni,(nPosFim+Len(cTag)+3)-nPosIni,"")
	    nPosIni+=Len(cTag)+2
	   cRet:=Subs(cAux,nPosIni,nPosFim-nPosIni)
	EndIf   
EndIf

Return (cRet)


Static Function IBMLerPinPad(cModalidade)

Local oDlgPinPad,oReadTrack,oBmpIBM
Local cTrack:=space(150)
Local cLixo:=space(1000)

oDlgPinPad := MSDIALOG():Create()
oDlgPinPad:cName := "oDlgPinPad"
oDlgPinPad:cCaption := STR0014 //"Leitura do cartao magnetico"
oDlgPinPad:nLeft := 0
oDlgPinPad:nTop := 0
oDlgPinPad:nWidth := 355
oDlgPinPad:nHeight := 280
oDlgPinPad:lShowHint := .F.
oDlgPinPad:lCentered := .T.


oReadTrack := TGET():Create(oDlgPinPad)
oReadTrack:cName := "oReadTrack"
oReadTrack:cCaption := "oGet4"
oReadTrack:nLeft := 0
oReadTrack:nTop := 0
oReadTrack:nWidth := 459
oReadTrack:nHeight := 10
oReadTrack:lShowHint := .F.
oReadTrack:lReadOnly := .F.
oReadTrack:Align := CONTROL_ALIGN_TOP
oReadTrack:cVariable := "cTrack"
oReadTrack:bSetGet := {|u| If(PCount()>0,cTrack:=u,cTrack) }
oReadTrack:lVisibleControl := .T.
oReadTrack:lPassword := .T.
oReadTrack:lHasButton := .F.
oReadTrack:bLostFocus:={|| oDlgPinPadPinPad:End()}

oReadLixo := TGET():Create(oDlgPinPad)
oReadLixo :cName := "oReadTrack"
oReadLixo :cCaption := "oGetX"
oReadLixo :nLeft := 0
oReadLixo :nTop := 0
oReadLixo :nWidth := 459
oReadLixo :nHeight := 10
oReadLixo :lShowHint := .F.
oReadLixo :lReadOnly := .F.
oReadLixo :Align := CONTROL_ALIGN_TOP
oReadLixo :cVariable := "cLixo"
oReadLixo :bSetGet := {|u| If(PCount()>0,cLixo:=u,cLixo) }
oReadLixo :lVisibleControl := .T.
oReadLixo :lPassword := .T.
oReadLixo :lHasButton := .F.
oReadLixo :bLostFocus:={|| oDlgPinPadPinPad:End()}



oBmpIBM := TBITMAP():Create(oDlgPinPad)
oBmpIBM:cName := "oBmpIBM"
oBmpIBM:cCaption := "IBM"
oBmpIBM:nLeft := 10
oBmpIBM:nTop := 100
oBmpIBM:nWidth := 500 //470
oBmpIBM:nHeight := 250 //200 //120
oBmpIBM:lShowHint := .F.
oBmpIBM:lReadOnly := .F.
oBmpIBM:Align := CONTROL_ALIGN_BOTTOM //CONTROL_ALIGN_ALLCLIENT
oBmpIBM:lVisibleControl := .T.
oBmpIBM:lStretch := .F.
oBmpIBM:lAutoSize := .F.     
oBmpIBM:cBmpFile:="K54P8790_1"

oSBtn1 := SBUTTON():Create(oDlgPinPadPinPad)
oSBtn1:cName := "oSBtn1"
oSBtn1:cCaption := "oSBtn1"
oSBtn1:nLeft := 444
oSBtn1:nTop := 73
oSBtn1:nWidth := 52
oSBtn1:nHeight := 22
oSBtn1:lShowHint := .F.
oSBtn1:lReadOnly := .F.
oSBtn1:Align := 0
oSBtn1:lVisibleControl := .T.
oSBtn1:nType := 1

oTimer := TTimer():New( 1, {|| IBMChangBmp(oBmpIBM,oReadTrack)}, oDlgPinPad)
oTimer:lActive   := .T.

oDlgPinPad:Activate()
cTrack:=Alltrim(cTrack)

Return Subs(cTrack,3,Len(cTrack)-3)


Static Function IBMChangBmp(oBmpIBM)

If oBmpIBM:cBmpFile=="K54P8790_1"
	oBmpIBM:cBmpFile:="K54P8790_2"
Else
	oBmpIBM:cBmpFile:="K54P8790_1"
EndIf
oBmpIBM:Refresh()

Return .T.
