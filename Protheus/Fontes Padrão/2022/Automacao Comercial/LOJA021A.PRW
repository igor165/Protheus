#Include "LOJA021A.CH"
#Include "PROTHEUS.CH"
#Include "COLORS.CH"
#Include "FONT.CH"

#DEFINE CONFIRMA  1
#DEFINE ABANDONA  2

#DEFINE VALMERC   	1	// Valor total do mercadoria
#DEFINE VALDESC 	2	// Valor total do desconto
#DEFINE FRETE   	3 	// Valor total do Frete
#DEFINE VALDESP 	4  	// Valor total da despesa
#DEFINE VALTROCA	5	// Valor da Troca
#DEFINE QTDEITEM	6	// Quantidade de Itens
#DEFINE SEGURO		7	// Valor total do seguro
#DEFINE VALBRUTO	8	// Valor Bruto da NF
#DEFINE PERCDESC   10   // Percentual de Desconto

#DEFINE IMPOSTOS 	9	// Array contendo Os Valores de Impostos Exibidos no ListBox

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Define do array aTitulos                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE _TIPO   	1	//Tipo do titulo
#DEFINE _PREFIXO   	2	//Prefixo do titulo
#DEFINE _NUMERO   	3	//Numero do titulo
#DEFINE _PARCELA   	4	//Parcela do titulo
#DEFINE _CLIENTE   	5	//Cod. Cliente do titulo
#DEFINE _LOJA   	6	//Loja do Cliente do titulo
#DEFINE _NOMCLI   	7	//Nome do Cliente do titulo
#DEFINE _MOEDA   	8	//Moeda do titulo
#DEFINE _VALOR   	9	//Valor do titulo
#DEFINE _VLCRUZ   10	//Valor do titulo em moeda 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Dados do array aInfCliente                                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE _NOMECLI     1
#DEFINE _TELCLI      2
#DEFINE _PRICOMCLI   3
#DEFINE _ULTCOMCLI   4
#DEFINE _ENDCLI      5
#DEFINE _ESTCLI      6
#DEFINE _CGCCLI      7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Dados do documento tipo "CR "(credito) gerado no LOJA010D. Este titulo ira compensar com a NCC de Troca             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static cSE5Documen    //SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA
Static nSE1Recno      //Recno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LOJA021	³ Autor ³ Vendas Clientes		³ Data ³ 27/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetuar Devolucoes,Trocas para outros paises               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LOJA021()								    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Loja021( nFuncao, xAutoCab, xAutoItens, nOpcAuto )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea  := GetArea()
Local aCores := {{'L1_STATUS=="D"  .AND. !Empty(L1_DOC)' ,"BR_VERMELHO"},;
				 {"Empty(L1_DOC)"                         ,"BR_AMARELO"},;				
				 {"Empty(L1_STATUS) .AND. !Empty(L1_DOC)" ,"BR_VERDE"}}

PRIVATE cConfCli   := GetMv("MV_CONFCLI")
PRIVATE cNumCupFis := Space(TamSx3("L1_DOC")[1])
PRIVATE cCadastro  := STR0001 // Troca de Mercadorias
PRIVATE cHistCh    := " "     //Utilizando em ponto de Entrada
PRIVATE cSenhaAnt  := cSenha
PRIVATE cNivelSup  := cNivel
PRIVATE cNivelSup2 := cNivel
PRIVATE cLoteFat   := ""
PRIVATE cVersaoBm  := ""     // Versao da impressora fiscal da BEMATECH
PRIVATE cNumPdv	   := Space(TamSX3("L1_PDV")[1])
PRIVATE cCartao    := Space(3)
PRIVATE cOrcamen   := ""
PRIVATE cCalcImpV  := GetMV("MV_GERIMPV")
PRIVATE cConcomit  := "N" //Por causa da concomitancia

PRIVATE l021Auto   := ( ValType(xAutoCab) == "A"  .AND. ValType(xAutoItens) == "A" )
PRIVATE lTroca 	   := .F.  //Troca na mesma loja ou em outra loja
PRIVATE lParcial   := .F.  //Devolucao Parcial
PRIVATE lTotal     := .F.  //Devolucao Total
PRIVATE lTrocaOut  := .F.  //Troca em Outra Loja
PRIVATE lDevoluca  := .F.  //Devolucao para Troca em Outra Loja
PRIVATE lFirst 	   := .F.
PRIVATE lPedido    := .F.
PRIVATE lCombo     := .T.
PRIVATE lGrade     := .F.   //Nao ha grade para troca
PRIVATE lGradProd  := .F.
PRIVATE lPrecoBal  := .F.
PRIVATE lSrvCns    := .F.
PRIVATE lLancPad10 := .F.
PRIVATE lLancPad20 := .F.
PRIVATE lVendaRapida := .F.
PRIVATE lNFManual  := .F. //Compatibilizacao com LOJA010

PRIVATE nPosProd    := 0
PRIVATE nPosVlrItem := 0
PRIVATE nPosUnit	:= 0
PRIVATE nPosVUnit	:= 0
PRIVATE nPosPrcTab	:= 0
PRIVATE nPosValDes  := 0
PRIVATE nPosDesc    := 0
PRIVATE nPosDescPro := 0
PRIVATE nPosTes     := 0
PRIVATE nPosCF      := 0
PRIVATE nPosDescri  := 0
PRIVATE nPosTabela  := 0
PRIVATE nPosQuant	:= 0
PRIVATE nPosLocal	:= 0
PRIVATE nPosItem    := 0
PRIVATE nPosUm	    := 0
PRIVATE nPco        := 0  //Por causa da concomitancia
PRIVATE nDescLoj    := 0
PRIVATE nCpos       := 0
PRIVATE nVlrTran	:= 0  //Valor total da troca ou devolver
PRIVATE nHdlPrv     := 1
PRIVATE nTotal      := 0
PRIVATE nMoedaTr    := 1
PRIVATE nTxMoedaTr  := 0
PRIVATE nDecimais   := MsDecimais(nMoedaTr)
PRIVATE nHdll

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Impressora fiscal (Compatibilizacao com Loja010) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTefDados   := {}
PRIVATE aTabelas    := {	{"1",0}, {"2",0}, {"3",0}, {"4",0},;
							{"5",0}, {"6",0}, {"7",0}, {"8",0},;
							{"9",0} }

PRIVATE aDescontos 	:= {}
PRIVATE aImps    	:= {}
PRIVATE aImpVarSF2 	:= {} 
PRIVATE aImpVarSD2 	:= {0,0,0,0,0,{}}
PRIVATE aImpVarSF1 	:= {}
PRIVATE aImpVarSD1 	:= {0,0,0,0,0,{}}
PRIVATE aImpCusto  	:= {} 
PRIVATE aImpVarDup 	:= {}
PRIVATE aTitulos 	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                 ****** Descric„o do Array aDevol *******               ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Dimensoes  ³ Descric„o						 					       ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ 	  1	   ³ Nome da Moeda		     		   						   ³
//³ 	  2	   ³ Saldo da Devolucao					 					   ³
//³ 	  3	   ³ Valor efetivamente devolvido (usuario vai informar )	   ³
//³ 	  4	   ³ Somatorio da devolucao convertido para a moeda corresp.   ³
//³ 	  5	   ³ Contem o valor original da devolucao (backup)      	   ³
//³ 	  6	   ³ Moeda                                           		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aDevol    := {}
PRIVATE nValTotIV := 0, nValBaseIV := 0

PRIVATE cCodAdm
PRIVATE aRotina := MenuDef()
Private lQuery  := .F.

DbSelectArea("SL1")
DbSetOrder(2)

cCadastro := cCadastro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Determina se está sendo utilizado TopConnect.                   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TCSrvType() <> "AS/400"
		lQuery := .T.
	EndIf
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 31 (ACS), verifica se o usu rio poder  ou n„o   ³
//³ efetuar uma Troca.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ChkPsw( 31 )
	mBrowse( 6, 1,22,75,"SL1",,,,,,aCores)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

Return 



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Vendas Clientes		³ Data ³08/12/06  ³±±
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

Local aRotina:= {		{ STR0003 , "AxPesqui" , 0  , 1 , , .F.},; 		//Pesquisar
						{ STR0004 , "Lj021Visual"   , 0 , 2 , , .T.},; 	//Visualizar
						{ STR0157 , "LJ021Trocas"   , 0 , 4 , , .T.},;		//"Troca da Loja"
						{ STR0158 , "LJ021TrcOut"   , 0 , 4 , , .T.},;		//"Outra Loja"
						{ STR0005 , "LJ021DevTotal" , 0 , 4 , , .T.},; 	//Dev. Total
						{ STR0006 , "LJ021DevParc"  , 0 , 4 , , .T.},;     //Dev. Parcial
						{ STR0101 , "Lj021Leg"      , 0 , 2 , , .T.}}      //Legenda


Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj021DevParcial³ Autor ³ Vendas Clientes	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Devolucao de Mercadoria do punto de Venda Local³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj021DevParcial											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021DevParcial(cAlias,nRecno,nOpcx)
Local aArea     := GetArea()

lParcial   := .T.
lTotal     := .F.
lTroca     := .F.
lDevoluca  := .F.
lTrocaOut  := .F.
LJ021DevLocal(cAlias,nRecno,nOpcx,.F.)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021DevTotal ³ Autor ³ Vendas Clientes	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Devolucao de Mercadoria do punto de Venda Local³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021DevTotal											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021DevTotal(cAlias,nRecno,nOpcx)
Local aArea := GetArea()

lTotal     := .T.
lParcial   := .F.
lTroca     := .F.
lDevoluca  := .F.
lTrocaOut  := .F.
LJ021DevLocal(cAlias,nRecno,nOpcx,.F.)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021Trocas   ³ Autor ³ Vendas Clientes	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Troca de Mercadoria do punto de Venda Local    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj021Trocas												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA     											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021Trocas(cAlias,nRecno,nOpcx)
Local aArea  := GetArea()

lTotal     := .F.
lParcial   := .F.
lTroca     := .T.
lDevoluca  := .F.
lTrocaOut  := .F.
LJ021DevLocal(cAlias, nRecno, nOpcx, .F.)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021TrcOut   ³ Autor ³ Vendas Clientes	³ Data ³ 31.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Troca de Mercadoria de outra Loja              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj021TrcOut(cAlias,nRecno,nOpcx)  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA     											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021TrcOut(cAlias,nRecno,nOpcx)
Local aArea  := GetArea()

lTotal     := .F.
lParcial   := .F.
lTroca     := .T.
lDevoluca  := .F.
lTrocaOut  := .T.
LJ021DevOut(cAlias,nRecno,nOpcx)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021DevLocal ³ Autor ³ Vendas Clientes	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Devolucao de Mercadoria do punto de Venda Local³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021DevLocal											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA 								    			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021DevLocal(cAlias, nRecno, nOpcx, lVisual)
Local aArea     := GetArea()
Local aPages	:= {"HEADER"}
Local aTitles	:= {	STR0010	,;	//"Totais"
						STR0011	,;	//"Inf. do Cliente"
						STR0012 ,;	//"Impostos"
						STR0111 }	//""Dados Financeiros"
Local aSizeAut
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosGet		:= {}
Local aPosObj		:= {}
Local aImposto      := {}
Local aEditCpos     := IIf(lTroca .OR. lParcial,{"L2_QUANT","L2_TES"},{"L2_TES"})
Local nI, nC
Local nUsado	   := 0
Local nX           := 0
Local nPosValImp   := 0
Local cNumAnt   := Space(TamSx3("L1_DOC")[1])
Local cSerAnt   := Space(3)
Local cCampo    := ""
Local cNomClie  := ""
Local cOrcamento:= SL1->L1_NUM
Local cMoeda    := GetMv("MV_MOEDA"+Str(Max(SL1->L1_MOEDA,1),1))
Local cScriptTro:= GetMv("MV_SCRTROC")
Local cLabelDoc := AllTrim(RetTitle("F2_DOC"))

Local lRet	   := .F.
Local lLoja020 := (ExistBlock("LOJA020"))

Local oBmp
Local oCliente
Local oLoja
Local oDescCompra
Local oNomClie
Local oOrcamento
Local oMoeda
Local oTxMoeda
Local oDlg
Local oCheckNFMan

Local xRet

PRIVATE aObj := Array(21)
PRIVATE oObj1
PRIVATE oObj2
PRIVATE oObj3
PRIVATE oObj4
PRIVATE oObj5
PRIVATE oObj6
PRIVATE oObj7
PRIVATE oObj8
PRIVATE oObj9

DEFAULT l021Auto := .F.
If !l021Auto
	aSizeAut := MsAdvSize(,.F.,400)
EndIf

PRIVATE aInfCliente	:= {"","",CTOD(""),CTOD(""),"","",""}
PRIVATE aValores	:= {0,0,0,0,0,0,0,0,{{'','',0,0,0}},0}
PRIVATE aMoeda      := {}
PRIVATE aPosicoes[0]
PRIVATE aHeader[0]
PRIVATE aCampos[0]
PRIVATE aFieldImpostos	:= {}
PRIVATE aHeadImpostos	:= {} 
PRIVATE aColsImpostos	:= {} 
PRIVATE aColsLbx2		:= {}
PRIVATE aColsFinanc  	:= {}
PRIVATE aQuantOrig    	:= {}
PRIVATE aPosImps  		:= {}

PRIVATE nCredito    := 0
PRIVATE nDesconto	:= 0
PRIVATE nMerc		:= 0
PRIVATE nLinGetdados:= 15
PRIVATE nFolder     := 1
PRIVATE nOpcA       := 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis PRIVATE inicializadas                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oDlg1
PRIVATE oGet

PRIVATE cNumNFDev  := CriaVar("L1_DOC") //Numero da Nota de Credito a ser gerada
PRIVATE cNumNota   := SL1->L1_DOC       //Numero da NF gerada pelo orcamento devolvido
PRIVATE cSerieDev  := AllTrim(GetMV("MV_LJNFTRO"))
PRIVATE cSerie 	   := SL1->L1_SERIE
PRIVATE cCond      := SL1->L1_CONDPG
PRIVATE cNumPdv	   := SL1->L1_PDV
PRIVATE cCliente   := SL1->L1_CLIENTE
PRIVATE cLoja	   := SL1->L1_LOJA
PRIVATE cVendedor  := SL1->L1_VEND
PRIVATE cEspecie   := "NCC"
PRIVATE cCliAnt     := ""
PRIVATE cLojAnt     := ""
PRIVATE cDescCli	:= ""
PRIVATE cx3Valid    := ""		// usado na MSGETDADOS
PRIVATE cTipo       := "N"
PRIVATE cFormProp   := "S"
PRIVATE cDevNCC     := GetMV("MV_DEVNCC")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 				  Opcoes do parametro MV_DEVNCC                        ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Conteudo   ³ Descric„o						 					       ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³    1	   ³ Gera devolucao em dinheiro se houve baixa do titulo       ³
//³    2	   ³ Gera NCC financeira se houve baixa do titulo 			   ³
//³    3	   ³ Pergunta se devolve em dinheiro ou gera NCC financeira se ³
//³    		   ³ houve baixa do titulo									   ³
//³    4	   ³ Sempre gera NCC financeira, independente do status do ti- ³
//³    		   ³ tulo da venda											   ³
//³    5	   ³ Gera titulo de abatimento (Loc. Argentina)				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cMotivo     := Space(6)
If cPaisLoc == "GUA"
	Private cNumResol := Space(TamSX3("FQ_RESOLUC")[1])
EndIf

PRIVATE dDtEmissao := SL1->L1_EMISSAO

PRIVATE lComprou	:=.T.
PRIVATE lCredFisc   := .F.
PRIVATE lExcluiTit  := .F.  //Se nenhum titulo da venda devolv./troc. foi baixado ou esta em poder de outro Caixa; excluir titulos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| LjReadvar("lLjTroca",.T.)                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lLjTroca := .T.

aDevol    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Presupuesto é tambem Nota Fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(SL1->L1_DOC)
	MsgStop( STR0065, STR0009 ) //Presupuesto no es una Factura... ### Atencao
	Return(.F.)
EndIf

If cPaisLoc == "SAL"
	SA1->(DbSetOrder(1))
	SA1->( DbSeek(xFilial("SA1")+cCliente+cLoja) )
	lCredFisc  := SA1->A1_TIPO $ "1|4"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a  Compra foi feita na mesma Loja                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL1")
DbSetOrder(2)
If ! DbSeek(xFilial("SL1")+cSerie+cNumNota)
	MsgStop( STR0014, STR0009 ) //Compra feita em outro local,usar a opcao Outras Sucursal ###Atención
	Return(.F.)
EndIf
DbSetOrder(1)
nMoedaTr   := SL1->L1_MOEDA
nTxMoedaTr := SL1->L1_TXMOEDA
nDecimais  := MsDecimais(nMoedaTr)
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o caixa esta aberto, senao nao deixa fazer a troca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! LjCxAberto()
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao inicial                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock("LJ021INI")
	xRet  := ExecBlock("LJ021INI",.F.,.F.)
	If ValType(xRet) == "L" .AND. !xRet
		Return (.F.)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader com os campos da troca                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado := 0

DbSelectArea("Sx2")
DbSeek("SL2")

DbSelectArea("Sx3")
DbSetOrder(1)
DbSeek( "SL2" )

While !Eof() .AND. (x3_arquivo == "SL2")
	IF (X3USO(X3_USADO) .AND. cNivel >= x3_nivel .AND. alltrim(x3_campo)<>"L2_NUM") .OR. Alltrim(X3_campo) == "L2_ITEM"
		nUsado++
		&('M->'+AllTrim(x3_campo)):=(" SL2->"+x3_campo)
		cx3Valid:=x3_Valid
		If  Alltrim(X3_Campo) = "L2_QUANT"
			cX3Valid := "LJ021Qtde() .AND. Lj021TESDev('Q')"
		Endif
		If Trim(X3_CAMPO) = "L2_TES"
			cX3Valid := "Lj021TESDev('T')"
		Endif
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, cX3Valid,;
		x3_usado, x3_tipo, x3_arquivo } )
		Aadd( aCampos, x3_campo )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Armazena as posicoes dos campos de impostos(bas e e valor) para posterior gravacao na fatura de compras              |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Substr(X3_CAMPO,4,6) == "BASIMP" .OR. Substr(X3_CAMPO,4,6) == "VALIMP")
			Aadd(aPosImps,{X3_CAMPO,nUsado})
		EndIf
	EndIf
	DbSkip()
End

PRIVATE aCOLS[1][nUsado+1], aQtde := {}
PRIVATE aFirst[1][nUsado+1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as Posicoes dos Campos no aHeader	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LJ021Pos()
LJ010Pos()

nUsado:=0
DbSelectArea("SX3")
DbSetOrder(1)

DbSeek( "SL2" )
While !Eof() .AND. x3_arquivo == "SL2"
	If (x3Uso(x3_usado) .AND. cNivel >= x3_nivel .AND.	alltrim(x3_campo)<>"L2_NUM") .OR. Alltrim(X3_campo) == "L2_ITEM"
		nUsado++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Array de 1 elemento vazio. Se inclus„o. 		           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If x3_tipo == "C"
			aCOLS[1][nUsado] := SPACE(x3_tamanho)
		ElseIf x3_tipo == "N"
			aCOLS[1][nUsado] := 0
		ElseIf x3_tipo == "D"
			aCOLS[1][nUsado] := dDataBase
		Else
			aCOLS[1][nUsado] := .F.
		EndIf
	EndIf
	DbSkip()
End
aCOLS[1][nUsado+1] := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com as moedas ativs para o Combo.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX	:=	1 To MoedFin()
	If(!(Empty(GetMV("MV_MOEDA"+Alltrim(STR(nX))))))
		AAdd(aMoeda,GetMV("MV_MOEDA"+Alltrim(STR(nX))))
	Else
		Exit
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando for feita manutencao em alguma VALIDACAO dos GETs,      ³
//³ atualize as funcoes que se encontram no array aValidGet        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l021Auto
	aObjects := {}
	AAdd( aObjects, { 0,    41, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
	{{10,40,95,140,200,234,268},;
	{10,40,111,140,223,268,60},;
	{5,70,160,205,295},;
	{6,34,200,215},;
	{6,34,80,113,160,175},;
	{6,34,245,268,260},;
	{10,50,150,190},;
	{273,130,190},;
	{8,45,80,103,139,173,200,235,270},;
	{133,190,144,190,289,293},;
	{142,293,140},;
	{9,47,188,148,9,146} } )
	
	nQtdItens := LJ021ACols(lVisual)
	If nQtdItens == 0 .AND. !lVisual
		Return(.F.)
	EndIf
	
	If !LJ021GetObj()
		MsgStop(STR0137) //"Nao e possivel fazer uma devolucao parcial para vendas com cheque."
		Return(.F.)
	EndIf
	LJ021Refresh("1")
	
	cDescCompra := STR0015  //"Comprou Aqui"
	
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))
	cNomClie := SA1->A1_NOME
	
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
	
	If File("Bombe.bmp")
		@	0.4,25 BITMAP oBmp FILE "BombE.bmp" OF oDlg NOBORDER SIZE 20,20
		oBmp:lStretch:=.T.
	EndIf
	
	@ 21,004 MSGET oDescCompra VAR cDescCompra  SIZE 60,8 OF oDlg PIXEL Picture "@!"	WHEN .F.
	
	@ 21,069 SAY STR0016   OF oDlg PIXEL              // Cliente
	@ 32,005 SAY STR0118   OF oDlg PIXEL              // Orcamento
	@ 32,085 SAY cLabelDoc OF oDlg PIXEL              // Nota Fiscal
	@ 32,175 SAY STR0018   OF oDlg PIXEL              // Serie
	@ 43,005 SAY STR0139   OF oDlg PIXEL              // Moeda
	@ 43,111 SAY STR0140   OF oDlg PIXEL              // Taxa Moeda
	
	
	@ 20,087 MSGET oCliente	VAR cCliente SIZE  38, 8	OF oDlg PIXEL Picture "@!"  WHEN .F.
	@ 20,127 MSGET oLoja 	VAR cLoja	 SIZE   8, 8   	OF oDlg PIXEL Picture "@!"  WHEN .F.
	@ 20,145 MSGET oNomClie	VAR cNomClie SIZE  150, 8  	OF oDlg PIXEL WHEN .F.
	
	@ 31,037 MSGET oOrcamento VAR cOrcamento SIZE  35, 8  OF oDlg PIXEL WHEN .F.
	@ 31,111 MSGET oNumNota   VAR cNumNota   SIZE  55, 8  OF oDlg PIXEL Picture PesqPict("SL1","L1_DOC")	WHEN .F.
	@ 31,190 MSGET oSerie     VAR cSerie     SIZE  10, 8  OF oDlg PIXEL Picture "@!"  WHEN .F.
	
	@ 42,037 MSGET oMoeda     VAR cMoeda     SIZE  55, 8  OF oDlg PIXEL WHEN .F.
	@ 42,147 MSGET oTxMoeda   VAR nTxMoedaTr SIZE  55, 8  OF oDlg PIXEL Picture PesqPict("SL1","L1_TXMOEDA") WHEN .F.
	
	If cPaisLoc == "GUA"
		@ 045, 210 CHECKBOX oCheckNFMan VAR lNFManual PROMPT STR0185 ;	 //"NF Manual?"
		SIZE 60,08 OF oDlg PIXEL
	EndIf
	
	If lTotal
		@ 13,001 TO 55,395 LABEL STR0020 OF oDlg PIXEL     	//Devolucion Total
	Else
		@ 13,001 TO 55,395 LABEL STR0021 OF oDlg PIXEL   	//Devolucion Parcial
	EndIf
	
	If lVisual
		oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],4,,,"",.T.,{},,,Len(aCols))
	Else
		oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],4,"LJ021LinOk","LJ021TudOk","",.T.,aEditCpos,,,Len(aCols),,,,"LJ021Del")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a area do rodape da rotina                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
	For nX := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder dos totais da rotina                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	@ 006,aPosGet[3,1] SAY STR0022 OF oFolder:aDialogs[1] PIXEL SIZE 055,009 // "Valor da Mercadoria"
	@ 005,aPosGet[3,2] MSGET oObj1 VAR aValores[VALMERC] PICTURE PesqPict('SL1','L1_VLRTOT',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
	
	@ 006,aPosGet[3,3] SAY STR0023 OF oFolder:aDialogs[1] PIXEL SIZE 049,009 // "Descontos"
	@ 005,aPosGet[3,4] MSGET oObj2 VAR aValores[PERCDESC]  PICTURE PesqPict('SL1','L1_DESCNF') OF oFolder:aDialogs[1] PIXEL ;
	WHEN .F. SIZE 080,009
	
	@ 020,aPosGet[3,1] SAY STR0024 OF oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Frete"
	@ 019,aPosGet[3,2] MSGET oObj3 VAR aValores[FRETE]  PICTURE PesqPict('SL1','L1_FRETE',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL WHEN .F.  SIZE 080,009
	
	@ 020,aPosGet[3,3] SAY STR0025 OF oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Despesas"
	@ 019,aPosGet[3,4] MSGET oObj4 VAR aValores[VALDESP]  PICTURE PesqPict('SL1','L1_DESPESA',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL WHEN .F.  SIZE 080,009
	
	@ 034,aPosGet[3,1] SAY STR0027 OF oFolder:aDialogs[1] PIXEL SIZE 050,009  	 // "Troca"
	@ 033,aPosGet[3,2] MSGET oObj5  VAR aValores[VALTROCA]  PICTURE PesqPict('SL1','L1_VLRTOT',14,nMoedaTr)	WHEN .F. OF oFolder:aDialogs[1] PIXEL SIZE 080,009
	
	@ 034,aPosGet[3,3] SAY STR0075 OF oFolder:aDialogs[1] PIXEL SIZE 050,009	//"Valor Desconto"
	@ 033,aPosGet[3,4] MSGET oObj6 VAR aValores[VALDESC]  PICTURE PesqPict('SL1','L1_DESCONT',14,nMoedaTr)	WHEN .F. OF oFolder:aDialogs[1] PIXEL SIZE 080,009
	
	@ 051,aPosGet[3,1] SAY STR0028 OF oFolder:aDialogs[1] PIXEL SIZE 050,009	//"Total de Itens"
	@ 049,aPosGet[3,2] MSGET oObj7   VAR aValores[QTDEITEM]  PICTURE "99999"	WHEN .F. OF oFolder:aDialogs[1] PIXEL SIZE 080,009
	
	@ 051,aPosGet[3,3] SAY STR0176 OF oFolder:aDialogs[1] PIXEL SIZE 058,009 		//"Total Documento"
	@ 049,aPosGet[3,4] MSGET oObj8   VAR aValores[VALBRUTO]  PICTURE PesqPict('SL1','L1_VALBRUT',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
	
	@ 043,003 TO 46 ,aPosGet[3,5] LABEL '' OF oFolder:aDialogs[1] PIXEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder com as informacoes do cliente                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:aDialogs[2]:oFont := oDlg:oFont
	@ 006,aPosGet[4,1] SAY STR0030 OF oFolder:aDialogs[2] PIXEL SIZE 037,009 // "Nome"
	@ 005,aPosGet[4,2] MSGET aObj[09] VAR aInfCliente[_NOMECLI] PICTURE PesqPict('SA1','A1_NOME');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 159,009
	@ 006,aPosGet[4,3] SAY STR0031 OF oFolder:aDialogs[2] PIXEL SIZE 023,009 // "Tel."
	@ 005,aPosGet[4,4] MSGET aObj[10] VAR aInfCliente[_TELCLI] PICTURE PesqPict('SA1','A1_TEL');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 074,009
	@ 043,aPosGet[5,1] SAY STR0032 OF oFolder:aDialogs[2] PIXEL SIZE 032,009 // "1a Compra"
	@ 042,aPosGet[5,2] MSGET aObj[13] VAR aInfCliente[_PRICOMCLI] PICTURE PesqPict('SA1','A1_PRICOM') ;
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 040,009
	@ 043,aPosGet[5,3] SAY STR0033 OF oFolder:aDialogs[2] PIXEL SIZE 036,009 // "Ult. Compra"
	@ 042,aPosGet[5,4] MSGET aObj[14] VAR aInfCliente[_ULTCOMCLI] PICTURE PesqPict('SA1','A1_ULTCOM');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 040,009
	@ 43 ,aPosGet[5,5] SAY RTrim(RetTitle("A1_CGC")) Of oFolder:aDialogs[2] PIXEL SIZE 21 ,9 // "cgc"
	@ 42 ,aPosGet[5,6] MSGET aObj[15] VAR aInfCliente[_CGCCLI] Picture PesqPict('SA1','A1_CGC');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 76 ,9
	@ 024,aPosGet[6,1] SAY STR0034 OF oFolder:aDialogs[2] PIXEL SIZE 049,009 // "Endereco"
	@ 023,aPosGet[6,2] MSGET aObj[11] VAR aInfCliente[_ENDCLI]  PICTURE PesqPict('SA1','A1_END');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 205,009
	@ 024,aPosGet[6,3] SAY STR0035 OF oFolder:aDialogs[2] PIXEL SIZE 032,009 // "Estado"
	@ 023,aPosGet[6,4] MSGET aObj[12] VAR aInfCliente[_ESTCLI]  PICTURE PesqPict('SA1','A1_EST');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 021,009
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder do resumo de impostos                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:aDialogs[3]:oFont := oDlg:oFont
	aObj[16] := Lj021Impostos(oFolder:aDialogs[3])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder dos dados financeiros                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:aDialogs[4]:oFont := oDlg:oFont
	aObj[17]  := Lj021Financ(oFolder:aDialogs[4])
	
	ACTIVATE MSDIALOG oDlg ON INIT (LJ021Bar(oDlg),IIf(lVisual,NIL,Lj021DelIt() .AND. Lj021Formul() .AND. ;
	LjCreCli(cCliente, cLoja, @cCliAnt, @cLojAnt, oDlg,,.T.))) CENTER
EndIf

If nOpcA <> 1 .OR. lVisual
	RestArea(aArea)
	Return(.F.)
EndIf

If lTroca
	For nI:=1 to Len(aCols)
		If !aCols[nI][Len(aCols[nI])]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considerar todos os impostos que incidem no Total da Nota ³
			//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCredito += aCols[nI][nPosVlrItem]
			cTesImp := aCols[nI][nPosTes]
			aImposto := DefImposto( cTesImp )
			For nC := 1 To Len(aImposto)
				cCampo := "L2_"+aImposto[nC][2]
				If aImposto[nC][3] == "1"  //Determina se imposto incide ou nao na nota
					nPosValImp := Ascan(aHeader,{|x| x[2] == cCampo})
					nCredito   +=  aCols[nI][nPosValImp]
				EndIf
			Next nC
		EndIf
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A ocorrencia 25 (ACS), verifica se o usu rio poder  ou n„o 	  ³
	//³ efetuar um Atendimento. (Para Criar um orcamento novo de troca³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ChkPsw( 25 )
		RestArea( aArea )
		Return( .F. )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A gravacao do motivo da devolucao eh Obrigatoriedade³
	//³ fiscal - Loc. Guatemala                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "GUA"
		If !Lj021MotDev()
			RestArea(aArea)
			Return .F.
		EndIf
	EndIf
	
	lTroca020 := .T. //Botao para desabilitar o botao de cancela da venda balcao
	cNumAnt   := cNumNota
	cSerAnt   := cSerie
	nVlrTran  := aValores[VALBRUTO]  //Valor a ser trocado
	
	If lj010ate("SL1",,3,,cCliente,cLoja,cVendedor)
		lTroca020 := .F.
		nVlrTran-=SL1->L1_VLRTOT
		LJ021Pos()
		lRet := LJ021VldDev(nRecno,cNumAnt,cSerAnt,nVlrTran)
	Else
		Help(" ",1,"NAOTROCADO")
	EndIf
ElseIf lParcial .OR. lTotal
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A gravacao do motivo da devolucao eh Obrigatoriedade³
	//³ fiscal - Loc. Guatemala                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "GUA"
		If !Lj021MotDev()
			RestArea(aArea)
			Return .F.
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recalculo da comissao para Devolu‡ao                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNumPdv    := SL1->L1_PDV
	nVlrTran   := aValores[VALBRUTO]  //Valor a ser devolvido
	cNumAnt    := cNumNota
	cSerAnt    := cSerie
	
	DbSelectArea("SL1")
	DbSetOrder(2)
	If DbSeek(xFilial("SL1") + cSerie + cNumNota + cNumPdv)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posicao do Parametro de Geracao de Comissao         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(SL1->L1_CONFVEN,11,1) <> "N"
			DbSelectArea("SE3")
			DbSetOrder(1)
			If DbSeek(xFilial("SE3")+cSerie+cNumNota)
				
				While (!Eof()) .AND. (!Empty(SL1->L1_VEND)) .AND.;
					(SL1->L1_SERIE + SL1->L1_DOC == E3_PREFIXO + E3_NUM)
					
					If ! Empty(E3_DATA)
						Help( " ",1,"A140COMIS")
						DbSkip()
						Loop
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza‡„o de Comiss”es									 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("SE3",.F.,.T.)
					DbDelete()
					MsUnlock()
					DbSkip()
				End
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validar a Devolucao de Vendas e chamar a funcao para gravar  ³
	//³ os dados financeiros e da Nota de Entrada/Devolucao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCntItens := 0
	For nI := 1 To Len(aCols)
		If ! aCols[nI][Len(aCols[1])]
			nCntItens ++
		EndIf
	Next nI
	If nCntItens > 0
		lRet  := LJ021VldDev(nRecno,cNumAnt,cSerAnt,nVlrTran)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a rotina de impressao da nota de credito. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. !Empty(cScriptTro)
	If cFormProp == "S"
		Lj021Imprime()
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada da troca devolucao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lLoja020
	ExecBlock("LOJA020",.F.,.F.,{nVlrTran})
EndIf

lTroca     := .F.
lParcial   := .F.
lTotal     := .F.
lDevoluca  := .F.
lTrocaOut  := .F.

RestArea( aArea )

aRotina[3][4] := 4

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LJ021Grava³ Autor ³ Vendas Clientes		³ Data ³ 27/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar os registros respectivos a Devolucoes ou Trocas     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021Grava()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA021A 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021Grava(	nRecno, lConfNcc, nVlrBaixa, cNumAnt, ;
						cSerAnt )


Local nT 		  :=0
Local nX 		  :=0
Local nY 		  :=0
Local nItem 	  :=0
Local nQtdCanc    := 0
Local nDecs       := 2
Local nVlrBaixaOrc:= 0
Local nDecs1      := MsDecimais(1)
Local nVlrTranMd1 := 0
Local nMoedaBco   := 1
Local nRndBco     := 2
Local nValorCred  := 0
Local nVlrTroca   := 0
Local nTamNF      := TamSx3("L1_DOC")[1]
Local nAltera     := GetMV("MV_ALTNUM",,1)
Local nModoPrint  := 1
Local cMoedaOrc   := GetMv("MV_MOEDA1")
Local cMoeda1     := GetMv("MV_MOEDA1")
Local cItem
Local cL2Num
Local cOrcNum       := ""
Local cParcela      := GetMV("MV_1DUP")
Local cNumNotaOri   := ""
Local cSerieOri     := ""
Local cClienteOri   := ""
Local cTES          := ""
Local cCaixa        := xNumCaixa()
Local cAgencia      := "."
Local cConta        := "."
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| "Deseja gerar o Titulo de Abatimento nesta mesma moeda?"###"Deseja gerar a Nota de Credito do Cliente nesta mesma moeda?"  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPerg         := IIf(cPaisLoc == "ARG",STR0144,STR0142)
Local cDocNCC
Local cTipContNF    := Iif(ValType(lFiscal)== "L" .AND. lFiscal,GetMV("MV_CONTNFI",,"I"),GetMV("MV_CONTNF"))
Local cNumAnterior  := Space(TamSx3("L1_DOC")[1])
Local cAliasNF      := ""
Local cChaveSX5     := ""
Local cNumDoc       := ""                         //Numero da NF de saida que estah sendo devolvida
Local cSerieDoc     := ""                         //Serie da NF de saida que estah sendo devolvida
Local lGeraComi     := .F.
Local lGravar       := .T.
Local lGeraSE1      := Iif(lTroca .AND. !lDevoluca ,.T.,.F.)
Local lNCCMoeda1    := .T.
Local lExpressao    := .F.
Local lExiste       := .T.
Local lValidNum     := .T.
Local lRet          := .F.
Local lContinua     := .T.
Local lLj021Aval    := (ExistBlock("LJ021AVAL"))
Local lAvalTit      := .T.
Local lSeqEspecie   := SuperGetMV("MV_SEQESPE",,.F.)
Local nI
Local aRecnoSE1     := {}
Local cMV_NatTEF	:= SuperGetMV("MV_NATTEF")		//Natureza Financeira para venda TEF com Cartao de Debito.
Local cFilSx5		:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5"))  // Retorna Filial SX5

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Tela de Numeracao da NCC                                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTrocaOut
	If cFormProp == "S" //Formulario Proprio(NCC)
		If !LJ021Nota(.T.)
			Return (lRet)
		EndIf
	Else
		If !Lj021NotaExt()  //Formulario do cliente - externo(NDE)
			Return (lRet)
		EndIf
	EndIf
EndIf

If cFormProp == "S"
	DbSelectArea("SF1")
	DbSetOrder(1)
	
	cChaveSX5     := IIf(lSeqEspecie,xFilial("SX5")+"AC"+"NCC"+cSerieDev,cFilSx5+"01"+cSerieDev)
	
	cNumAnterior  := cNumNFDev
	cAliasNF	  := "SF1"
	
	While lExiste  //Uso do MayIUseCode
		lExiste:=  !aNumNaoExiste(	cAliasNF, cSerieDev	, cNumNFDev, cCliente, ;
									cLoja	, cEspecie	,"LOJ" )
		If lExiste
			cNumNFDev := PadR( strzero(val(cNumNFDev)+1,len(cNumNFDev)) , TamSX3("F1_DOC")[1] )
		Else
			If cNumAnterior <> cNumNFDev
				If nAltera == 1
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|O Numero do Documento foi alterado de:" ### " para: " ### "Numero|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MsgInfo( STR0165 + cNumAnterior + STR0166 + cNumNFDev, STR0167 )
				ElseIf nAltera == 2
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|O documento no.: "#" ja existe, confirma alteracao da numeracao para:|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lContinua := MsgYesNo( STR0168 + cNumAnterior + STR0169 + cNumNFDev )
				ElseIf nAltera == 3
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|" O documento no.: "  ### " ja existe " ### "Numero do Documento"|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MsgInfo( STR0168 + cNumAnterior + STR0170, STR0171 )
					lContinua := .F.
				Else
					lContinua  := .T.
				EndIf
				If lContinua
					If cNumNFDev > cNumAnterior
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|Verifica se o numero esta registrado em alguma resolucao(SAT)    |
						//|Se nao estiver, nao grava a operacao                             |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !(lContinua  := Lj021ValSAT(cSerieDev,cNumNFDev))
							lRet  := .F.
							Exit
						EndIf
						DbSelectArea("SX5")
						If DbSeek(cChaveSX5)
							RecLock("SX5",.F.)
							Replace X5_DESCRI  With PadR( strzero(val(cNumNFDev)+1,len(cNumNFDev)) , TamSX3("F1_DOC")[1] )   // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)   Era: StrZero(Val(cNumNFDev)+1,TamSX3("F1_DOC")[1])
							Replace X5_DESCSPA With PadR( strzero(val(cNumNFDev)+1,len(cNumNFDev)) , TamSX3("F1_DOC")[1] )   // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)   Era: StrZero(Val(cNumNFDev)+1,TamSX3("F1_DOC")[1])
							Replace X5_DESCENG With PadR( strzero(val(cNumNFDev)+1,len(cNumNFDev)) , TamSX3("F1_DOC")[1] )   // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)   Era: StrZero(Val(cNumNFDev)+1,TamSX3("F1_DOC")[1])
							MsUnLock( )
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	End
Else
	DbSelectArea("SF3")
	DbSetOrder(5)
	While !Lj021VldDoc(cTipContNF) .AND. lValidNum
		MsgAlert(STR0119) //"Numero e Serie de Documento ja cadastrados! Selecione um novo numero."
		lValidNum  := Lj021NotaExt()
	End
EndIf

If !lValidNum .OR. !lContinua
	Return (lRet)
EndIf

For nX := 1 To Len(aCols)
	If ! aCols[nX][Len(aCols[nX])]
		If aCols[nX][nPosDescPro] > 0
			aCols[nX][nPosVlrItem] := aCols[nX][nPosVlrItem] - aCols[nX][nPosDescPro]
			aCols[nX][nPosVUnit] := (aCols[nX][nPosVlrItem]/aCols[nX][nPosQuant])
		EndIf
	EndIf
Next nX

DbSelectArea("SL1")
DbSetOrder(1)
DbGoto(nRecno)
cMoedaOrc   := GetMv("MV_MOEDA"+Str(nMoedaTr,1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Para orcamentos em moeda diferente da 1, permitir gerar NCC ou Titulo de Abatimento(ARG) na moeda 1 ou da NF          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lConfNcc .AND. nMoedaTr > 1
    //"Deseja gerar a Nota de Credito do Cliente nesta mesma moeda?"
    cPerg  := IIf(cPaisLoc == "ARG",STR0142,cPerg)
	//"A Nota Fiscal devolvida foi emitida em "
	If MsgYesNo(	STR0141 + cMoedaOrc	+ CRLF + cPerg + ;
					CRLF 	+ STR0143 	+ cMoeda1)               //"Caso contrario, sera gerada na moeda "
		lNCCMoeda1  := .F.
		nDecs       := MsDecimais(nMoedaTr)
		cAgencia    := GetMv("MV_SIMB"+Str(nMoedaTr,1))
		SA6->(DbSetOrder(1))
		If SA6->(DbSeek(xFilial("SA6")+cCaixa+cAgencia))
			cConta  := SA6->A6_NUMCON  //Busca o numero da conta do Caixa estrangeiro
		EndIf
	EndIf
EndIf

If ExistBlock('LJ021ANTGR')
	ExecBlock('LJ021ANTGR',.F.,.F.)
EndIf

BEGIN TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Avalia o RdMake e executa tambem o PE para impressao do Cupom   ³
//³ Fiscal, retornando um .T. se efetuado com sucesso.	            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nModoPrint := 1
If cPaisLoc == "ARG" .AND. ExistBlock("LJ021IMP")
	lGravar := ExecBlock("LJ021IMP",.F.,.F.,{nModoPrint})
EndIf

If lGravar
	If !lTrocaOut
		SL1->(DbGoto(nRecno))
		cOrcNum     := SL1->L1_NUM
		cNumNotaOri := SL1->L1_DOC
		cSerieOri   := SL1->L1_SERIE
		cClienteOri := SL1->L1_CLIENTE+SL1->L1_LOJA
		nVlrTroca   := SL1->L1_VLRTOT
        
		If lLj021Aval
			lAvalTit  := ExecBlock("LJ021AVAL",.F.,.F.,{nVlrBaixa})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancela todos os t¡tulos dessa venda, bem como o ³
		//³ cadastro de cheques.      			    		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nT := 1 To Len(aTitulos)
			lExpressao  := !IsMoney(aTitulos[nT][_TIPO]) .AND. lAvalTit .AND. lExcluiTit
			If lExpressao
				DbSelectArea("SE1")
				DbSetOrder(1)
				If DbSeek(xFilial("SE1") + SL1->L1_SERIE + SL1->L1_DOC)
					While !Eof() .AND.	SE1->E1_FILIAL 	== xFilial("SE1") 			.AND.;
										SE1->E1_PREFIXO	== aTitulos[nT][_PREFIXO] 	.AND.;
										SE1->E1_NUM 	== aTitulos[nT][_NUMERO]
						If SE1->E1_TIPO <> aTitulos[nT][_TIPO] .OR.;
							SE1->E1_PARCELA <> aTitulos[nT][_PARCELA] .OR.;
							SE1->E1_SALDO  == 0
							DbSkip()
							Loop
						EndIf
						
						If SE1->E1_SALDO > 0 .AND. SE1->E1_PORTADOR == xNumCaixa()
							
							If Trim(aTitulos[nT][_TIPO]) == "CH"
								DbSelectArea("SEF")
								DbSetOrder(3)
								If DbSeek(xFilial("SEF")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Apaga os cheques ligados aos t¡tulos / parcelas   ³
									//³ Devolver os Cheques							      ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									RecLock("SEF",.F.)
									DbDelete()
									MsUnlock()
								EndIf
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza dados do cliente, se nao for cliente padrao  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !GetMv("MV_CLIPAD")+GetMv("MV_LOJAPAD") == SE1->E1_CLIENTE+SE1->E1_LOJA
								AtuSalDup("-",SE1->E1_SALDO,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Apaga os t¡tulos gerados pela venda    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DbSelectArea("SE1")
							RecLock("SE1",.F.)
							DbDelete()
							MsUnlock()
							nQtdCanc++
						EndIf
						DbSkip()
					End
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Na Argentina se parametro MV_DEVNCC = "5" gera nota de abatimento ao inves NCC |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc == "ARG" .AND. cDevNCC == "5"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Só executa as rotinas caso seja TopConnect e a integridade      |
					//| referencial esteja ligada.                                      |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lQuery .AND. __lFkInUse
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Verifica se o tipo de titulo existe na tabela 05 do SX5,        |
						//| caso nao exista cria - Integridade Referencial.                 |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Lj021CriaTp(aTitulos[nT][_TIPO])
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Verifica se a natureza do titulo existe no arquivo SEd,         |
						//| caso nao exista cria - Integridade Referencial.                 |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Lj021CriaNat(aTitulos[nT][_TIPO])
					EndIf
					
					If AllTrim(aTitulos[nT][_TIPO]) == "NF"
						lGeraNCC := .T.
					Else
						If ExistBlock("LJ021FPAGO")
							lGeraNCC := ExecBlock("LJ021FPAGO",.F.,.F.)
						EndIf
					EndIf
					
					SA1->(DbSetOrder(1))
					SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))
					
					DbSelectArea("SE1")
					DbSetOrder(1)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|Nao acessar rotina de gravacao de titulo quando aTitulos estiver vazia |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( aTitulos[nT][_VALOR] )
						aRecnoSE1 := {}
						lGeraSE1  := .T.
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gerar titulo de abatimento no Financeiro, quando o mesmo ³
						//³ nao existir...                                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("SE1",.T.)
						REPLACE E1_FILIAL  	WITH xFilial("SE1")
						REPLACE E1_PREFIXO 	WITH cSerieDev
						REPLACE E1_NUM	    WITH cNumNFDev
						REPLACE E1_PARCELA 	WITH cParcela
						REPLACE E1_PORTADO 	WITH xNumCaixa()
						REPLACE E1_AGEDEP  	WITH cAgencia
						REPLACE E1_CONTA   	WITH cConta
						REPLACE E1_EMISSAO 	WITH dDataBase
						REPLACE E1_EMIS1   	WITH dDataBase
						If lTotal
							If lNCCMoeda1
								REPLACE E1_VALOR    WITH Round(xMoeda(aTitulos[nT][_VALOR],aTitulos[nT][_MOEDA],1,,nDecs1+1),nDecs1)
								REPLACE E1_VLCRUZ  	WITH E1_VALOR
								REPLACE E1_MOEDA   	WITH 1
							Else
								REPLACE E1_VALOR   	WITH aTitulos[nT][_VALOR]
								REPLACE E1_VLCRUZ  	WITH aTitulos[nT][_VLCRUZ]
								REPLACE E1_MOEDA   	WITH nMoedaTr
							EndIf
						ElseIf lParcial
							If lNCCMoeda1
								REPLACE E1_VALOR   	WITH Round(xMoeda(nVlrTran,nMoedaTr,1,,nDecs1+1,nTxMoedaTr),nDecs1)
								REPLACE E1_MOEDA   	WITH 1
							Else
								REPLACE E1_VALOR   	WITH nVlrTran
								REPLACE E1_MOEDA   	WITH nMoedaTr
							EndIf
							REPLACE E1_VLCRUZ  	WITH Round(xMoeda(nVlrTran,nMoedaTr,1,,nDecs1+1,nTxMoedaTr),nDecs1)
						EndIf
						REPLACE E1_VENCREA 	WITH dDataBase
						REPLACE E1_BAIXA	    WITH dDataBase
						REPLACE E1_VENCTO  	WITH dDataBase
						REPLACE E1_VENCORI 	WITH ddataBase
						REPLACE E1_CLIENTE 	WITH cCliente
						REPLACE E1_LOJA	 	WITH cLoja
						REPLACE E1_NOMCLI  	WITH SA1->A1_NREDUZ
						REPLACE E1_VEND1   	WITH cVendedor
						REPLACE E1_SITUACA 	WITH "0"
						REPLACE E1_ORIGEM  	WITH "LOJA021"
						If AllTrim(aTitulos[nT][_TIPO]) == "NF"
							If lGeraNCC
								REPLACE E1_TIPO	 	WITH "NCC"
								REPLACE E1_NATUREZ 	WITH &(GetMV("MV_NATNCC")) //"NOTA CREDITO"
								REPLACE E1_HIST	 	WITH STR0086 //"DEVOLUCAO EM CONTA"
								REPLACE E1_SALDO   	WITH nValorTran
							Else
								REPLACE E1_TIPO	 	WITH Subs(aTitulos[nT][_TIPO],1,2)+"-"
								REPLACE E1_NATUREZ 	WITH &(GetMV("MV_NATDINH")) //"DINHEIRO"
								REPLACE E1_HIST	 	WITH STR0088 //"DEVOLUCAO EM DINHEIRO"
								REPLACE E1_SALDO   	WITH 0.00
								REPLACE E1_BAIXA   	WITH dDataBase
							EndIf
						Else
							If AllTrim(aTitulos[nT][_TIPO]) == "CC"
								REPLACE E1_TIPO	 	WITH "CC-"
								REPLACE E1_NATUREZ 	WITH &(GetMV("MV_NATCART")) //"CARTAO DE CREDITO"
								REPLACE E1_HIST	 	WITH STR0090 //"DEVOL. CARTAO CREDITO"
								REPLACE E1_SALDO   	WITH 0.00
							ElseIf AllTrim(aTitulos[nT][_TIPO]) == "CD"  //"CARTAO DE DEBITO"
								REPLACE E1_TIPO	 	WITH "CD-"
								cMV_NatTEF := If( Substr(cMV_NatTEF,1,1)=="&", &(Substr(cMV_NatTEF,2,Len(cMV_NatTEF))), cMV_NatTEF )
								REPLACE E1_NATUREZ 	WITH cMV_NatTEF 	// Codigo da Natureza Financeira
								REPLACE E1_HIST	 	WITH STR0092 //"DEVOL. CARTAO DEBITO"
								REPLACE E1_SALDO   	WITH 0.00
							ElseIf AllTrim(aTitulos[nT][_TIPO]) == "VL"
								REPLACE E1_TIPO	 	WITH "VL-"
								REPLACE E1_NATUREZ 	WITH &(GetMv("MV_NATVALE")) //"VALE"
								REPLACE E1_HIST	 	WITH STR0094 //"DEVOL. EM VALES"
								REPLACE E1_SALDO   	WITH 0.00
							ElseIf AllTrim(aTitulos[nT][_TIPO]) == "PG"
								REPLACE E1_TIPO	 	WITH "PG-"
								REPLACE E1_NATUREZ 	WITH &(GetMv("MV_NATOUTR")) //"PAGARE"
								REPLACE E1_HIST	 	WITH STR0096 //"DEVOL. EM PAGARE"
								REPLACE E1_SALDO   	WITH 0.00
							ElseIf IsMoney(aTitulos[nT][_TIPO])
								REPLACE E1_TIPO	 	WITH Subs(aTitulos[nT][_TIPO],1,2)+"-"
								REPLACE E1_NATUREZ 	WITH &(GetMV("MV_NATDINH")) //"DINHEIRO"
								REPLACE E1_HIST	 	WITH STR0088 //"DEVOLUCAO EM DINHEIRO"
								REPLACE E1_SALDO   	WITH 0.00
								REPLACE E1_BAIXA   	WITH dDataBase
							Else
								REPLACE E1_TIPO	 	WITH Subs(aTitulos[nT][_TIPO],1,2)+"-"
								REPLACE E1_HIST	 	WITH STR0098+" "+aTitulos[nT][_TIPO] //"DEVOLUCAO"
								REPLACE E1_SALDO   	WITH 0.00
								REPLACE E1_BAIXA   	WITH dDataBase
							EndIf
						EndIf
						REPLACE E1_STATUS  	WITH Iif(SE1->E1_SALDO>0.01,"A","B")
						AADD(aRecnoSE1,Recno())
						MsUnlock()
					EndIf
				EndIf
			EndIf
			If ExistBlock("LJ021GRV")
				ExecBlock("LJ021GRV",.F.,.F.)
			EndIf
		Next nT
	EndIf
	lExpressao := IIf(lTroca .AND. !lDevoluca,(!Empty(cSE5Documen) .AND. !Empty(nSE1Recno)),;
	lConfNcc .AND. nVlrBaixa > 0)
	
	If lExpressao
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Titulo tipo CR gerado na Venda Balcao                           |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nSE1Recno <> NIL
			SE1->(DbGoto(nSE1Recno))
			nValorCred := SE1->E1_SALDO
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gerar titulo de NCC no Financeiro                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While SE1->(DbSeek(cFilial+cSerieDev+cNumNFDev+cParcela+"NCC"))
			cParcela := CHR(ASC(cParcela)+1)
		End
		
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))
		lGeraSE1  := .T.
		
		RecLock("SE1",.T.)
		REPLACE E1_FILIAL  WITH cFilial
		REPLACE E1_PREFIXO WITH cSerieDev
		REPLACE E1_NUM	  WITH cNumNFDev
		REPLACE E1_PARCELA WITH cParcela
		REPLACE E1_NATUREZ WITH STR0085    //"NOTA DE CREDITO"
		REPLACE E1_PORTADO WITH cCaixa
		REPLACE E1_AGEDEP  WITH cAgencia
		REPLACE E1_CONTA   WITH cConta
		If lNCCMoeda1
			REPLACE E1_VALOR   WITH Iif(lTroca .AND. !lDevoluca,IIf(lConfNCC,nCredito,nValorCred),nVlrBaixa)
			REPLACE E1_MOEDA   WITH 1
		Else
			REPLACE E1_VALOR   WITH Round(xMoeda(Iif(lTroca .AND. !lDevoluca,IIf(lConfNCC,nCredito,nValorCred),nVlrBaixa),1,nMoedaTr,,nDecs+1,,nTxMoedaTr),nDecs)
			REPLACE E1_MOEDA   WITH nMoedaTr
		EndIf
		REPLACE E1_SALDO   WITH E1_VALOR
		REPLACE E1_TIPO	  WITH "NCC"
		REPLACE E1_EMISSAO WITH dDataBase
		REPLACE E1_EMIS1   WITH dDataBase
		REPLACE E1_VENCTO  WITH dDataBase
		REPLACE E1_VENCORI WITH ddataBase
		REPLACE E1_VENCREA WITH dDataBase
		REPLACE E1_CLIENTE WITH cCliente
		REPLACE E1_LOJA	  WITH cLoja
		REPLACE E1_NOMCLI  WITH SA1->A1_NREDUZ
		REPLACE E1_VLCRUZ  WITH Iif(lTroca .AND. !lDevoluca,IIf(lConfNCC,nCredito,nValorCred),nVlrBaixa)
		REPLACE E1_STATUS  WITH "A"
		REPLACE E1_SITUACA WITH "0"
		REPLACE E1_ORIGEM  WITH "LOJA020"
		REPLACE E1_MULTNAT WITH "2"
		REPLACE E1_FLUXO   WITH "N"
		dbCommit()
		MsUnlock()
		AADD(aRecnoSE1,Recno())
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Compensacao da NCC com o valor pago em credito(gerado pelo LOJA010D)   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTroca .AND. !lDevoluca
			cDocNCC := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA
			
			RecLock("SE5",.T.)
			SE5->E5_FILIAL  := xFilial("SE5")
			SE5->E5_DATA	   := dDataBase
			SE5->E5_TIPODOC := "BA"
			If !Empty(SE1->E1_PORTADO)
				SA6->(DbSetOrder(1))
				If SA6->(DbSeek( xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
					nMoedaBco := Max(SA6->A6_MOEDA,1)
					nRndBco   := MsDecimais(nMoedaBco)
				EndIf
			EndIf
			SE5->E5_VALOR	    := 	Round(xMoeda(nValorCred,SE1->E1_MOEDA,nMoedaBco,dDataBase,nRndBco+1),nRndBco)
			SE5->E5_MOEDA	    :=	StrZero(nMoedaBco,2)
			SE5->E5_VLMOED2		:=	nValorCred
			SE5->E5_DTDIGIT   	:= 	dDataBase
			SE5->E5_NATUREZ   	:= 	SE1->E1_NATUREZ
			SE5->E5_DTDISPO   	:= 	SE5->E5_DATA
			SE5->E5_BANCO	    := 	SE1->E1_PORTADO
			SE5->E5_DOCUMEN   	:= 	cSE5Documen
			SE5->E5_RECPAG    	:= 	"R"
			SE5->E5_MOTBX	    := 	"CMP"
			SE5->E5_PREFIXO   	:= 	SE1->E1_PREFIXO
			SE5->E5_NUMERO    	:= 	SE1->E1_NUM
			SE5->E5_PARCELA   	:= 	SE1->E1_PARCELA
			SE5->E5_TIPO	    := 	SE1->E1_TIPO
			SE5->E5_CLIFOR    	:= 	SE1->E1_CLIENTE
			SE5->E5_LOJA      	:= 	SE1->E1_LOJA
			SE5->E5_HISTOR    	:= 	STR0152  //"COMP.P/ VENDA LOJA"
			MsUnLock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Atualizacao dos dados da NCC gerada acima                       |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SE1",.F.)
			SE1->E1_SALDO := SE1->E1_SALDO - nValorCred
			If SE1->E1_SALDO = 0
				SE1->E1_STATUS := "B"
				SE1->E1_BAIXA  := dDataBase
				SE1->E1_VALLIQ := nValorCred
			EndIf
			MsUnLock()
			
			SE1->(DbGoto(nSE1Recno))
			
			RecLock("SE5",.T.)
			SE5->E5_FILIAL 	:= xFilial("SE5")
			SE5->E5_DATA	:= dDataBase
			SE5->E5_TIPODOC	:= "CP"
			SE5->E5_VALOR  	:= Round(xMoeda(nValorCred,SE1->E1_MOEDA, nMoedaBco, dDataBase, nRndBco+1),nRndBco)
			SE5->E5_MOEDA  	:= StrZero(nMoedaBco,2)
			SE5->E5_VLMOED2	:= nValorCred
			SE5->E5_DTDIGIT	:= dDataBase
			SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
			SE5->E5_DTDISPO	:= SE5->E5_DATA
			SE5->E5_BANCO  	:= SE1->E1_PORTADO
			SE5->E5_DOCUMEN	:= cDocNCC
			SE5->E5_RECPAG 	:= "R"
			SE5->E5_MOTBX  	:= "CMP"
			SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
			SE5->E5_NUMERO 	:= SE1->E1_NUM
			SE5->E5_PARCELA	:= SE1->E1_PARCELA
			SE5->E5_TIPO	:= SE1->E1_TIPO
			SE5->E5_CLIFOR 	:= SE1->E1_CLIENTE
			SE5->E5_LOJA   	:= SE1->E1_LOJA
			SE5->E5_HISTOR 	:= STR0152  //"COMP.P/ VENDA LOJA"
			MsUnLock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Atualizacao do documento tipo "CR " gerado no LOJA010D          |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SE1",.F.)
			SE1->E1_SALDO := SE1->E1_SALDO - nValorCred
			If SE1->E1_SALDO = 0
				SE1->E1_STATUS := "B"
				SE1->E1_BAIXA  := dDataBase
			EndIf
			MsUnLock()
		EndIf
	EndIf
	If Len(aDevol) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criando registro de movimenta‡ao no SE5 para acerto do     ³
		//³ numer rio devolvido pelo Caixa, desde que nao gerou NCC    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aDevol)
			If aDevol[nX][3] > 0
				Lj021GeraSE5(nX)
			EndIf
		Next nX
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando Comissäes...								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGeraComi .AND. GETMV("MV_TPCOMIS") == "O"
		For nI := 1 To Len(aRecnoSE1)
			DbSelectArea("SE1")
			DbGoto(aRecnoSE1[nI])
			Fa440CalcE("MATA460","","999999",,.T.)
		Next nI
	EndIf
	
	If !lTrocaOut
	    nUltItem   := Lj021UltItem(cOrcNum)
		For nX := 1 To Len(aCols)
			nItem++
			cItem := StrZero(nUltItem + nItem,2)
			If ! aCols[nX][Len(aCols[nX])]
				DbSelectArea("SL2")
				DbSetOrder(1)
				
				If DbSeek(xFilial("SL2")+cOrcNum+aCols[nX][nPosItem]+aCols[nX][nPosProd])
					cL2Num    := SL2->L2_NUM
					cTES      := SL2->L2_TES
					cNumDoc   := SL2->L2_DOC
					cSerieDoc := SL2->L2_SERIE					
					
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+aCols[nX][nPosProd]))
					If L2_QUANT == aCols[nX][nPosQuant]
						Reclock("SL2",.F.)
						REPLACE L2_STATUS WITH "D"
						MsUnlock()
						DbSkip()
					Else
						RecLock("SL2",.F.)
						REPLACE L2_QUANT   	WITH Max(L2_QUANT   - aCols[nX][nPosQuant],0)
						REPLACE L2_VLRITEM 	WITH Max(L2_VLRITEM - aCols[nX][nPosVlrItem],0)
						REPLACE L2_VRUNIT  	WITH Max(L2_VLRITEM / L2_QUANT,0)
						REPLACE L2_VALDESC 	WITH Max(L2_VALDESC - aCols[nX][nPosValDes],0)
						REPLACE L2_DESC	  	WITH Max(L2_DESC	  - aCols[nX][nPosDesc],0)
						If SL2->L2_QUANT == 0
							REPLACE L2_STATUS	 WITH "D"
						EndIf
						Lj021GrvImp( cTes, nX, 'SL2', '-' ) //Grava Impostos ( valor e base )
						SL2->( dbCommit() )
						MsUnlock()
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava novo registro com os dados da devolu‡„o                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock("SL2",.T.)
						REPLACE L2_FILIAL  	WITH xFilial("SL2")
						REPLACE L2_DOC 	 	WITH cNumDoc
						REPLACE L2_SERIE	WITH cSerieDoc
						REPLACE L2_NUM 	 	WITH cL2Num
						REPLACE L2_PDV 	 	WITH cNumPdv
						REPLACE L2_VENDIDO 	WITH "S"
						REPLACE L2_ITEM	 	WITH cItem
						REPLACE L2_PRODUTO 	WITH aCols[nX][nPosProd]
						REPLACE L2_DESCRI  	WITH SB1->B1_DESC
						REPLACE L2_QUANT	WITH aCols[nX][nPosQuant]
						REPLACE L2_LOCAL	WITH aCols[nX][nPosLocal]
						REPLACE L2_UM		WITH aCols[nX][nPosUM]
						REPLACE L2_TES 	 	WITH aCols[nX][nPosTES]
						REPLACE L2_CF		WITH aCols[nx][nPosCF]
						REPLACE L2_TABELA  	WITH aCols[nX][nPosTabela]
						REPLACE L2_STATUS  	WITH "D"
						REPLACE L2_EMISSAO 	WITH dDataBase
						REPLACE L2_VLRITEM 	WITH aCols[nX][nPosVlrItem]
						REPLACE L2_VRUNIT  	WITH aCols[nX][nPosVUnit]
						REPLACE L2_VALDESC 	WITH aCols[nX][nPosValDesc]
						REPLACE L2_DESC	 	WITH aCols[nX][nPosDesc]
						REPLACE L2_VEND	 	WITH SL1->L1_VEND
						REPLACE L2_PRCTAB 	WITH aCols[nX][nPosPrcTab]
						REPLACE L2_DESCPRO 	WITH aCols[nX][nPosDescPro]
						If SL2->( FieldPos("L2_ITEMSD1")) > 0
							REPLACE L2_ITEMSD1 	WITH "000000"
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gravar os Impostos variaveis do Roteiro de C lculo...      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(aImps) > 0
							For nY := 1 To Len(aImps[nX][6])
								nCpo  := FieldPos("L2_ALQIMP"+Subst(aImps[nX][6][nY][7],10,1))
								If nCpo > 0
									If aImps[nX][6][nY][3] > 0
										FieldPut(nCpo,aImps[nX][6][nY][2]) //Valor Aliquota
									EndIf
								EndIf
								nCpo  := FieldPos(Alltrim(aImps[nX][6][nY][6]))
								If nCpo > 0
									FieldPut(nCpo,aImps[nX][6][nY][4]) //Valor BASE
								EndIf
								nCpo  := FieldPos(Alltrim(aImps[nX][6][nY][7]))
								If nCpo > 0
									FieldPut(nCpo,aImps[nX][6][nY][3]) //Valor imposto
								EndIf
							Next nY
						EndIf
						SL2->( dbCommit() )
						MsUnlock()
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o registro do arquivo SD2            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aCols[nX][nPosQuant] <> 0
					DbSelectArea("SD2")
					DbSetOrder(3)
					If DbSeek(	xFilial("SD2") 		+ cNumNotaOri + cSerieOri + cClienteOri + ;
								aCols[nX][nPosProd]	+ aCols[nX][nPosItem] )
						RecLock( "SD2", .F. )
						SD2->D2_QTDEDEV += aCols[nX][nPosQuant]
						SD2->D2_VALDEV  += aCols[nX][nPosVlrItem]
						MSUnlock()
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama fun‡„o de grava‡„o das entradas                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LJ021GrvNFE(lGeraSE1,cNumAnt,cSerAnt)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar L1_STATUS qdo a devolucao for igual a qtde original³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTrocaOut
		LJ021GrvSL1(cOrcNum)
	ElseIf cFormProp == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Atualiza do SX5 para troca de outra loja com formulario proprio |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX5")
		If SX5->(DbSeek( cChaveSX5,.F. ))
			RecLock("SX5",.F.)
            Replace SX5->X5_DESCRI  With PadR( strzero(val(cNumNFDev)+1,len(cNumNFDev)) , nTamNF )
			Replace SX5->X5_DESCSPA With PadR( strzero(val(cNumNFDev)+1,len(cNumNFDev)) , nTamNF )
			Replace SX5->X5_DESCENG With PadR( strzero(val(cNumNFDev)+1,len(cNumNFDev)) , nTamNF )
			MsUnLock()
		EndIf
	EndIf
	
	lRet  := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Avalia a funcao Lj010Fisc(), executa tambem o PE para impressao ³
//³ do Cupom Fiscal atraves do Parametro MV_SCRFIS retornando um .T.³
//³ se efetuado com sucesso.	                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "ARG" .AND. ExistBlock("LJ021IMP")
	nModoPrint := 2
	lGravar := ExecBlock("LJ021IMP",.F.,.F.,{nModoPrint})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso a impressora retorne erro, forcar um RollBack e fechar a   ³
	//³ Impressora Fiscal.									            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lGravar
		lRet    := .F.
	EndIf
EndIf

END TRANSACTION
FreeUsedCode()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada da troca devolucao                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock("LOJA021")
	ExecBlock("LOJA021",.F.,.F.)
EndIf

If !lTroca
	If nVlrBaixa > 0
		nVlrBaixaOrc  := Round(xMoeda(nVlrBaixa,1,nMoedaTr,,nDecs+1,,nTxMoedaTr),nDecs)
		If cPaisLoc <> "ARG" .OR. ( cPaisLoc == "ARG" .AND. cDevNCC <> "5" )
			If lConfNCC
				If nQtdCanc > 0
					MsgInfo(STR0133+Trim(Str(nQtdCanc))+STR0134)  //"Foram cancelados "###"titulos desta venda!"
				Else
					If lNCCMoeda1
						MsgInfo(STR0130+GetMV("MV_SIMB1")+Transform(nVlrBaixa,PesqPict("SE1","E1_VALOR")) + CRLF +; //"Foi gerada uma Nota de Credito no valor de "
						STR0136)  //"Nao foi cancelado nenhum titulo desta venda!"
					Else
						MsgInfo(STR0130+GetMV("MV_SIMB"+Str(nMoedaTr,1))+Transform(nVlrBaixaOrc,PesqPict("SE1","E1_VALOR")) + CRLF +; //"Foi gerada uma Nota de Credito no valor de "
						STR0136)  //"Nao foi cancelado nenhum titulo desta venda!"
					EndIf
				EndIf
			ElseIf nQtdCanc > 0
				MsgInfo(STR0133+Trim(Str(nQtdCanc))+STR0134)  //"Foram cancelados "###"titulos desta venda!"
			Else
				MsgInfo(STR0131+GetMV("MV_SIMB1")+Transform(nVlrBaixa,PesqPict("SE1","E1_VALOR")) + CRLF +; //"Foi registrada a devolucao em Dinheiro no valor total de "
				STR0136)  //"Nao foi cancelado nenhum titulo desta venda!"
			EndIf
		ElseIf nQtdCanc > 0
			If lNCCMoeda1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| "Gerado(s) titulo(s) de abatimento no valor total de "          |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsgInfo(STR0135+GetMV("MV_SIMB1")+Transform(nVlrBaixa,PesqPict("SE1","E1_VALOR")) + CRLF +;
				STR0133+Trim(Str(nQtdCanc))+STR0134)  //"Foram cancelados "###"titulos desta venda!"
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| "Gerado(s) titulo(s) de abatimento no valor total de "          |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsgInfo(STR0135+GetMV("MV_SIMB"+Str(nMoedaTr,1))+Transform(nVlrBaixaOrc,PesqPict("SE1","E1_VALOR")) + CRLF +;
				STR0133+Trim(Str(nQtdCanc))+STR0134)  //"Foram cancelados "###"titulos desta venda!"
			EndIf
		Else
			If lNCCMoeda1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| "Gerado(s) titulo(s) de abatimento no valor total de "          |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsgInfo(STR0135+GetMV("MV_SIMB1")+Transform(nVlrBaixa,PesqPict("SE1","E1_VALOR")) + CRLF +;
				STR0136)  //"Nao foi cancelado nenhum titulo desta venda!"
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| "Gerado(s) titulo(s) de abatimento no valor total de "          |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MsgInfo(STR0135+GetMV("MV_SIMB"+Str(nMoedaTr,1))+Transform(nVlrBaixaOrc,PesqPict("SE1","E1_VALOR")) + CRLF +;
				STR0136)  //"Nao foi cancelado nenhum titulo desta venda!"
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Nao havia titulos baixados para a venda, logo, todos foram cancelados |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cPaisLoc <> "ARG" .OR. ( cPaisLoc == "ARG" .AND. cDevNCC <> "5" )
		If nQtdCanc > 0
			MsgInfo(STR0133+Trim(Str(nQtdCanc))+STR0134)  //"Foram cancelados "###"titulos desta venda!"
		EndIf
	Else
		nVlrTranMd1  := Round(xMoeda(nVlrTran,nMoedaTr,1,,nDecs1+1,nTxMoedaTr),nDecs1)
		If lNCCMoeda1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| "Gerado(s) titulo(s) de abatimento no valor total de "          |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgInfo(STR0135+GetMV("MV_SIMB1")+Transform(nVlrTranMd1,PesqPict("SE1","E1_VALOR")) + CRLF +;
			STR0136)  //"Nao foi cancelado nenhum titulo desta venda!"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| "Gerado(s) titulo(s) de abatimento no valor total de "          |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgInfo(STR0135+GetMV("MV_SIMB"+Str(nMoedaTr,1))+Transform(nVlrTran,PesqPict("SE1","E1_VALOR")) + CRLF +;
			STR0136)  //"Nao foi cancelado nenhum titulo desta venda!"
		EndIf
	EndIf
Else  //Troca
	If nVlrTran > 0   //Se nVlrTran > 0 -> Valor da venda menor do que a devolucao, o cliente
		If lConfNcc    //tem um credito(NCC)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| "O cliente tem um credito(NCC) de "                             |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgInfo(STR0172+GetMV("MV_SIMB"+Str(nMoedaTr,1))+Transform(nVlrTran,PesqPict("SE1","E1_VALOR")))
		EndIf
	Endif
EndIf

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LJ021Nota ³ Autor ³Vendas Clientes		³ Data ³ 12/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de numeracao do documento                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021Nota()                  					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Troca/Devolucao											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ021Nota(lSomaSX5)
Local aSerie	 := {}
Local aArea      := GetArea()
Local nSerie	 := 0
Local nI 		 := 0
Local nContErr   := 0
Local nOpcao 	 	:= 2
Local oDlg
Local cCadastro 	:= STR0151
Local cVarQ			:= "  "
Local oQual  			//"Nota de Credito"
Local oDlgLojaNota
Local oNCCClie
Local aSerNf     	:= {}
Local lRet       	:= .T.
Local lMacro     := .F.
Local lSeqEspecie := SuperGetMV("MV_SEQESPE",,.F.)
Local lTudo 	 := .T.
Local nCntErro   := 0
Local nTamNF     := TamSx3("L1_DOC")[1]
Local nTamSerie  := TamSx3("L1_SERIE")[1]
Local aRecnosLK  := {}
Local cChaveSX5  := ""
Local cChaveSer  := ""
Local cSerieSX5  := ""
Local cFilSx5	 := If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5"))  // Retorna Filial SX5
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um sinal de & (macro substituicao), dessa forma³
//³possibilita ao usuario montar um parametro o qual seja executada  ³
//³uma condicional.                                                  ³
//³Foi necessario fazer dessa forma, pois caso contrario acarretaria ³
//³erro na base de clientes ja implantada.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lMacro  := Substr(cSerieDev,1,1)=="&"
If lMacro
	cSerieDev := &(Substr(cSerieDev,2,Len(cSerieDev)))
ElseIf cPaisLoc == "GUA"
	DbSelectArea("SX5")
	If DbSeek(xFilial("SX5")+"AB"+"NCC")
		cSerieDev  := Padr(X5Descri(),nTamSerie)
	EndIf
EndIf
If lSeqEspecie
	cChaveSX5  := xFilial("SX5") + "AC" + "NCC" + cSerieDev
	cChaveSer  := "AC"
Else
	cChaveSX5  := cFilSx5 + "01" + cSerieDev
	cChaveSer  := "01"
EndIf
If lNFManual
	cSerieDev  := Space(3)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o Parƒmetro MV_LJNFTRO estiver vazio, busca as ³
//³ series do documento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cSerieDev)
	If !lNFManual
		While .T.
			DbSelectArea("SX5")
			DbSeek(cFilial+cChaveSer )
			aSerNF	:= {}
			lTudo    := .T.
			While !Eof() .AND. cFilial+cChaveSer == X5_FILIAL+X5_TABELA
				
				If Substr(SX5->X5_CHAVE,1,3) == "CPF" .OR.;
					Substr(SX5->X5_CHAVE,1,3) == "CP"
					DbSkip()
					Loop
				EndIf
				
				If Substr(SX5->X5_CHAVE,1,3) <> "NCC"
					DbSkip()
					Loop
				EndIf
				
				If !MSRLock()
					lTudo := .F.
					Exit
				EndIf
				cSerieSX5  := IIf(lSeqEspecie,Substr(X5_CHAVE,4,nTamSerie),Padr(X5_CHAVE,nTamSerie))
				
				Aadd(aRecnosLK,Recno())
				AADD( aSerNF,{ cSerieSX5, StrZero(Val(X5Descri()),nTamNF ) } )
				
				DbSkip()
			End
			
			If !lTudo
				nContErr ++
				If nContErr > 10
					DbSeek( cFilial+cChaveSer )
					While !Eof() .AND. cFilial+cChaveSer == X5_FILIAL+X5_TABELA
						
						If Substr(SX5->X5_CHAVE,1,3) <> "NCC"
							DbSkip()
							Loop
						EndIf
						
						MsUnLock()
						DbSkip()
					End
					Help(" ",1,"NOTAPRESA")
					nContErr := 0
				EndIf
				Inkey(1)
				Loop
			EndIf
			Exit
		End
		
		If (Len(aSerNF) == 0)
			Help(" ",1,"A460FLOCK")
			lRet  := .F.
		Endif
	EndIf
	If lRet
		If !lNFManual
			DEFINE MSDIALOG oDlg TITLE cCadastro From 10,30 To 19,68 OF oMainWnd
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| "Serie"###"Nota de Credito"                                     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER STR0040, cCadastro SIZE 130,42 ON DBLCLICK (aSerNF:=Lj021TrcNum(oQual:nAt,@aSerNF),oQual:Refresh()) NOSCROLL
			oQual:SetArray(aSerNF)
			oQual:bLine := { || {aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2]}}
			
			DEFINE SBUTTON FROM 51,80	TYPE 1 ACTION (cSerieDev:=aSerNF[oQual:nAT,1],;
			cNumNFDev:=aSerNF[oQual:nAT,2],IIf(Lj021ValSAT(cSerieDev,cNumNFDev),;
			nOpcao:=1,nOpcao:=2),oDlg:End()) ENABLE OF oDlg
			
			DEFINE SBUTTON FROM 51,107 	TYPE 2 ACTION (nOpcao := 2,oDlg:End()) ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg
		Else
			DEFINE MSDIALOG oDlgLojaNota TITLE STR0186 From 10,30 To 17,58; //"Numeracao N.Credito"
			STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oMainWnd
			
			@ 1, 2 TO 30, 108 OF oDlgLojaNota PIXEL
			
			@ 7, 5 SAY STR0187 SIZE 22, 7 OF oDlgLojaNota PIXEL //"N.Cred."
			
			@ 6, 25 MSGET cSerieDev  PICTURE "@!";
			SIZE 15, 10 OF oDlgLojaNota PIXEL
			
			@ 6, 55 MSGET oNCCClie VAR cNumNFDev PICTURE PesqPict("SF1","F1_DOC");
			VALID Lj010Zera(@cNumNFDev) ;
			SIZE 47, 10 OF oDlgLojaNota PIXEL
			
			DEFINE SBUTTON FROM 33,73 TYPE 1 ACTION IIf(Lj021VldNCC(cSerieDev,cNumNFDev),;
			(nOpcao:=1,oDlgLojaNota:End()),nOpcao:=2) ENABLE OF oDlgLojaNota
			
			ACTIVATE MSDIALOG oDlgLojaNota VALID Lj021Exit(nOpcao) CENTERED
		EndIf
		lRet  := nOpcao == 1
	EndIf
	If !lNFManual
		cChaveSX5  := IIf(lSeqEspecie,xFilial("SX5")+"AC"+"NCC"+cSerieDev,cFilSx5+"01"+cSerieDev)
		
		If lRet .AND. SX5->(DbSeek( cChaveSX5,.F. ))
			RecLock("SX5",.F.)
            Replace SX5->X5_DESCRI  With PadR( strzero(val(cNumNFDev)+iif(lSomaSX5,1,0),len(cNumNFDev)) , nTamNF )
			Replace SX5->X5_DESCSPA With PadR( strzero(val(cNumNFDev)+iif(lSomaSX5,1,0),len(cNumNFDev)) , nTamNF )
			Replace SX5->X5_DESCENG With PadR( strzero(val(cNumNFDev)+iif(lSomaSX5,1,0),len(cNumNFDev)) , nTamNF )
			MsUnLock()
		EndIf
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o Numero de Serie/Nota for autom tico ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX5")
	DbSeek(cChaveSX5)
	If Eof()
		HELP(" ",1,"ERROSERIE")
		RestArea(aArea)
		Return .F.
	EndIf
	While !MsRLock(Recno())
		InKey(1)
		nContErr++
		If nContErr > 10
			Help(" ",1,"NOTAPRESA")
			nContErr := 0
			lRet     := .F.
		EndIf
	End
	If lRet
		AAdd(aRecnosLK,Recno())
		cNumNFDev := Substr(X5Descri(),1,nTamNF)
		lRet      := Lj021ValSAT(cSerieDev,cNumNFDev)
	EndIf
	DbSelectArea("SX5")
	If lRet
		If DbSeek(cChaveSX5)
			RecLock("SX5",.F.)
            SX5->X5_DESCRI := PadR( strzero(val(cNumNFDev)+iif(lSomaSX5,1,0),len(cNumNFDev)) , nTamNF )
			SX5->X5_DESCSPA:= PadR( strzero(val(cNumNFDev)+iif(lSomaSX5,1,0),len(cNumNFDev)) , nTamNF )
			SX5->X5_DESCENG:= PadR( strzero(val(cNumNFDev)+iif(lSomaSX5,1,0),len(cNumNFDev)) , nTamNF )
			MsUnlock()
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Liberando registros locados                                     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aRecnosLK)
	DbGoto(aRecnosLK[nI])
	MsUnLock()
Next nI

RestArea(aArea)

Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021VLoc³ Autor ³ Vendas Clientes		³ Data ³ 21.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Nao permitir finalizar a troca se a LOCALizacao de algum	  ³±±
±±³    		 ³ produto nao estiver preenchida.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ EXPL1 - Indica se deve ou nao verificar se todos os itens  ³±±
±±³    		 ³         que sao controlados por LOCALizacao estao com a    ³±±
±±³    		 ³         mesma preenchida. .F. (nao verif.) e' o padrao	  ³±±
±±³    		 ³ EXPL2 - Indica se esta validando apos o enter do campo	  ³±±
±±³    		 ³         LOCALiza da MsGetDados()		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021VLoc( lTodos, lColuna )
Local lRet 		// .T. (Padrao) se todos os produtos tiverem LOCALizacao
Local nCol      // Coluna do MSGetDados
Local nLin      // Linha  do MSGetDados
Local cProduto
Local cLOCALiz

lRet    := .T.
lTodos  := If( lTodos  == NIL, .F., lTodos )
lColuna := If( lColuna == NIL, .F., lColuna)

If lTodos
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica em todos os produtos que forem controlados por LOCALizacao se a    ³
	//³ LOCALizacao foi deixada em branco. Caso afirmativo, da mensagem e nao deixa ³
	//³ prosseguir.                                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLin := 1 to Len( aCols )
		
		For nCol := 1 to Len( aHeader )
			If LTrim( aHeader[nCol][2] ) == "L2_PRODUTO"
				cProduto := aCols[n][nCol]
			ElseIf LTrim( aHeader[nCol][2] ) == "L2_LOCALIZ"
				cLocaliz := aCols[n][nCol]
			EndIf
		Next nCol
		
		If LOCALiza( cProduto ) .AND. Empty( cLOCALiz )
			MsgStop( STR0044 + cProduto )  //"Almoxarifado nao pode ficar em branco. Produto: "
			lRet := .F.
			Exit
		EndIf
		
	Next nLin
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica apenas no produto atual, se for controlado por LOCALizacao, se a   ³
	//³ LOCALizacao foi deixada em branco. Caso afirmativo, da mensagem e nao deixa ³
	//³ prosseguir.                                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCol := 1 to Len( aHeader )
		If LTrim( aHeader[nCol][2] ) == "L2_PRODUTO"
			cProduto := aCols[n][nCol]
		ElseIf LTrim( aHeader[nCol][2] ) == "L2_LOCALIZ"
			cLOCALiz := aCols[n][nCol]
		EndIf
	Next nCol
	
	If LOCALiza( cProduto ) .AND. Empty( IIf( lColuna, M->L2_LOCALIZ, cLOCALiz ) )
		MsgStop( STR0044 + cProduto )  //"Almoxarifado nao pode ficar em branco. Produto: "
		lRet := .F.
	EndIf
	
EndIf
Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ LJ021Qtde³ Autor ³ Vendas Clientes		³ Data ³ 10/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Gatilhos do Campo Quantidade (L2_QUANT)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ021Qtde()
Local lRet := .T.
Local lExistNota  := .T.

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

If !lTrocaOut
	If aQuantOrig[n] < M->L2_QUANT
		Help(" ",1,"LJ021MAIOR")
		lRet  := .F.
	EndIf
EndIf

If lRet
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aCols[n][nPosProd]))
	
	If !lTrocaOut
		SL2->(DbSetOrder(1))
		SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+aCols[n][nPosItem]+aCols[n][nPosProd]))
		
		lExistNota	:= Iif(SL2->(Found()),.T.,.F.)
	EndIf
	If lExistNota
		M->L2_PRCTAB  := aCols[n][nPosPrcTab]
		M->L2_DESC	:= aCols[n][nPosDesc]
		M->L2_VALDESC := Round((M->L2_PRCTAB * M->l2_QUANT)*(M->L2_DESC/100),nDecimais)
		M->L2_VRUNIT  := Round(M->L2_PRCTAB-(M->L2_PRCTAB*M->L2_DESC/100),nDecimais)
		M->L2_VLRITEM := Round(M->L2_PRCTAB*M->L2_QUANT,nDecimais)-(M->L2_VALDESC)
		aCols[n][nPosQuant]   := M->L2_QUANT
		aCols[n][nPosValDes]  := M->L2_VALDESC
		aCols[n][nPosUnit]    := M->L2_VRUNIT
		aCols[n][nPosVlrItem] := M->L2_VLRITEM
	Else
		aCols[n][nPosLOCAL] := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
	EndIf
	
	If ExistBlock("LJ021TES")
		aCols[n][nPosTes] := ExecBlock("LJ021TES",.F.,.F.)
	EndIf
EndIf

Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ lj021Pos ³ Autor ³ Vendas Clientes		³ Data ³	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seta posicao dos campos 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LojA021													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021Pos()

nPosItem    := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_ITEM"})
nPosProd    := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_PRODUTO"})
nPosQuant   := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_QUANT"})
nPosLocal   := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_LOCAL"})
nPosUM	    := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_UM"})
nPosTES	    := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_TES"})
nPosCF	    := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_CF"})
nPosTabela  := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_TABELA"})
nPosVlrItem := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_VLRITEM"})
nPosUnit	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_VRUNIT"})
nPosVUnit	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_VRUNIT"})
nPosPrcTab  := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_PRCTAB"})
nPosValDesc	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_VALDESC"})
nPosDesc	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_DESC"})
nPosDescPro := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_DESCPRO"})

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021Refresh  ³ Autor ³ Vendas Clientes	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua um refresh nos Objetos...							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021Refresh()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := LJ021Refresh(ExpA2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021Refresh(cTime)
Local lRet      := .T.
Local aArea	    := GetArea()
Local aImposto  := {}
Local nImpostos := 0
Local nVlrItem  := 0
Local nC
Local nI
Local nPosImps  := 0
Local nDescTotal:= 0
Local nDescPro  := 0
Local cTES      := ""

Local nPosQuant   := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_QUANT"})
Local nPosVUnit	  := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_VRUNIT"})
Local nPosDescPro := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_DESCPRO"})

cTime :=IIf( PCount() == 0,"2","1")
aValores[VALMERC]  := 0
aValores[VALTROCA] := 0
aValores[VALBRUTO] := 0
aValores[VALDESC]  := 0
aValores[PERCDESC] := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Primeiro Folder...								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nImpostos := 0
For nI := 1 To Len(aCols)
	If !aCols[nI][Len(aCols[nI])]
		cTES  := aCols[nI][nPosTES]
		aImposto  := DefImposto(cTES)
		For nC := 1 to Len(aImposto)
			cCampo := "L2_"+aImposto[nC][2]
			nPosImps  := Ascan(aHeader,{|x| Trim(x[2]) == cCampo})
			If aImposto[nC][3] == "1" .AND. nPosImps > 0 //Determina se imposto incide ou nao na nota
				nImpostos += aCols[nI][nPosImps]
			EndIf
		Next nC
		aValores[VALMERC] += (aCols[nI][nPosQuant] * aCols[nI][nPosVUnit])
		If SL1->L1_DESCNF > 0
			If nPosDescPro > 0
				nDescTotal  += aCols[nI][nPosDescPro]
			Else
				nVlrItem := (aCols[nI][nPosQuant] * aCols[nI][nPosPrcTab])
				nDescPro := (nVlrItem * (SL1->L1_DESCNF/100))
				nDescTotal += nDescPro
			EndIf
		EndIf
	EndIf
Next nI
If nDescTotal > 0
	aValores[VALDESC]  := nDescTotal
	aValores[PERCDESC] := SL1->L1_DESCNF
EndIf
aValores[VALBRUTO] += aValores[VALMERC] + nImpostos - nDescTotal
aValores[VALTROCA] += aValores[VALBRUTO]

aValores[FRETE]    := 0
aValores[VALDESP]  := 0
aValores[SEGURO]   := 0
aValores[QTDEITEM] := LJ021QtdItem()

If cTime == "2"
	LJ021Header("1")
	aObj[16]:SetArray(aColsImpostos)
	aObj[16]:bLine:={|| LJ021bLine("I",aObj[16],aColsImpostos)}
	aObj[16]:Refresh()
	
	oObj1:Refresh()
	oObj2:Refresh()
	
	oObj3:Refresh()
	oObj4:Refresh()
	oObj5:Refresh()
	
	oObj6:Refresh()
	oObj7:Refresh()
	oObj8:Refresh()
EndIf
RestArea(aArea)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021GetObj   ³ Autor ³ Vendas Clientes	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa valores aos elementos do array aValores...	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021GetObj()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := LJ021GetObj()									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021GetObj()
Local aArea	:= GetArea()
Local lRet  := .T.

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Primeiro Folder...								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aValores[VALMERC]	:= SL1->L1_VLRLIQ
aValores[PERCDESC] 	:= SL1->L1_DESCNF
aValores[VALDESC]	:= SL1->L1_DESCONT

aValores[FRETE] 	:= SL1->L1_FRETE
aValores[VALDESP] 	:= SL1->L1_DESPESA
aValores[SEGURO] 	:= SL1->L1_SEGURO

aValores[QTDEITEM] 	:= Len(aCols)
aValores[VALTROCA] 	:= SL1->L1_VLRTOT
aValores[VALBRUTO] 	:= SL1->L1_VALBRUT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Segundo  Folder...									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aInfCliente[01] := SA1->A1_NOME
aInfCliente[02] := SA1->A1_TEL
aInfCliente[03] := SA1->A1_PRICOM
aInfCliente[04] := SA1->A1_ULTCOM
aInfCliente[05] := SA1->A1_END
aInfCliente[06] := SA1->A1_EST
aInfCliente[07] := SA1->A1_CGC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Acols para mostrar os dados financeiros no Folder    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SE1->(DbSetOrder(1))
If SE1->(DbSeek(xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC))
	While xFilial("SE1") == SE1->E1_FILIAL .AND. SL1->L1_SERIE+SL1->L1_DOC == SE1->E1_PREFIXO+SE1->E1_NUM
		
		If AllTrim(SE1->E1_TIPO) == "NCC" .OR. AllTrim(SE1->E1_TIPO) == "CR"   //Nao mostrar titulos de credito nem NCC
			SE1->(DbSkip())                    //gerados por devolucoes/trocas anteriores
			Loop
		EndIf
		
		If !(AllTrim(SE1->E1_TIPO) $ "CC|CD")
			If SL1->L1_CLIENTE+SL1->L1_LOJA <> SE1->E1_CLIENTE+SE1->E1_LOJA
				SE1->(DbSkip())
				Loop
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Nao permite devolucoes parciais para vendas efetuadas em cheque(Loc. Arg)    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "ARG" .AND. Trim(SE1->E1_TIPO) == "CH" .AND. lParcial
			lRet  := .F.
		EndIf
		Aadd(aColsFinanc,{	SE1->E1_NUM		, SE1->E1_PREFIXO	, SE1->E1_PARCELA, SE1->E1_TIPO, ;
							SE1->E1_VENCREA	, SE1->E1_VALOR		, SE1->E1_MOEDA })
		SE1->(DbSkip())
	End
EndIf
If Empty(aColsFinanc)
	Aadd(aColsFinanc,{"","","","",Ctod("  /  /    "),0,1})
EndIf
RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021Bar      ³ Autor ³ Vendas Clientes	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa valores aos elementos do array aValores...	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021Bar()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := LJ021Bar()										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021Bar(oDlg)
Local lRet 		:= .T.		//retorno da função 
Local xRetB1    := {}		//retorno do ponto de entrata LJ020BU1
Local xRetB2    := {}		//retorno do ponto de entrada LJ020BU2
Local aButtons	:= {}		// array contendo definições do botão

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| AAdd(aButtons, {"S4WB004N"    , {||A020Limp(.T.)}  , OemToAnsi(STR0045) }) //"Limpa a tela"  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aButtons, {"DBG06"       , {||Lj021Hist()}    , STR0046 }) //"Historico"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| AAdd(aButtons, {"SIMULACAO"   , {||Lj020Situac()}   , OemToAnsi(STR0047) }) //"Situacao"     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aButtons, {"DBG09"       , {||Lj020Car()} 	   , STR0048 }) //"Caracteristica"

If ExistBlock("LJ020BU1")
	xRetB1 := ExecBlock( "LJ020BU1" )		//Ponto de entrada para tratamento de botão
	If ValType(xRetB1) == "A"
		If Len(xRetB1) >= 3
			AAdd(aButtons, { xRetB1[ 1 ], xRetB1[ 2 ], xRetB1[ 3 ] } )
		Endif
	Endif
EndIf

If ExistBlock("LJ020BU2")					//Ponto de entrada para tratamento de botão
	xRetB2 := ExecBlock( "LJ020BU2" )
	If ValType(xRetB2) == "A"
		If Len(xRetB2) >= 3
			AAdd(aButtons, { xRetB2[ 1 ], xRetB2[ 2 ], xRetB2[ 3 ] } )
		Endif
	Endif
EndIf

EnchoiceBar(oDlg,{||If(oGet:TudoOk(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||nOpca:=0,oDlg:End()},,aButtons)

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021GrvNFE   ³ Autor ³ Vendas Clientes	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria um registro de entrada no SD1 e SF1, como uma NF de	  ³±±
±±³			 ³devolu‡„o, recalculando o saldo em estoque, bem como o custo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021GrvNFE(lGeraSE1,cNumAnt,cSerAnt)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ LJ021GrvNFE(lGeraSE1,cNumAnt,cSerAnt)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021GrvNFE(lGeraSE1,cNumAnt,cSerAnt)
Local nC 	     := 0														//Controle de For
Local nY 	     := 0														//Controle de For		
Local nItem      := 0														//Numero do item
Local nPosProduto:= Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_PRODUTO"})	//Ascan no aHeader
Local nPosLocal  := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_LOCAL"})		//Ascan no aHeader
Local aCustoEnt  := {}														//Array com custo de entrada
Local aLivro     := {}														//Array para Livro Fiscal
Local aGetBook   := {}														//Array para Livro
Local aCustoDev  := {}														//Array para custo de devolucao
Local aCusto     := {}														//Array para custo
Local cItemOri   := IIf(!Empty(cNumAnt),"01","")							//Item origem
Local cDupl      := IIf(lGeraSE1,cNumNFDev,"")								//Duplicata
Local aAreaSa1	 := {}														//Area do SA1
Local nMoedConv  := Val(GetMv("MV_MCUSTO"))									//Paramentro MV_MCUSTO
Local nTamD2_DOC := TamSx3("D2_DOC")[1]                              		//Tamanho Nota Fiscal

cNumAnt := PadR(cNumAnt,nTamD2_DOC)           

nPosTES	    := Ascan(aHeader,{|x| Trim(x[2]) == "L2_TES"})	
cEspecie    := "NCC"
cTipo       := "D"

If lTrocaOut  //Tratamento de custo quando nao ha NF original(troca de outra loja)
	For nY  := 1 to Len(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| O array a aCusto sempre tem que ser preenchido, independente da linha no aCols               |
		//| estar deletada ou nao, pois poderá ocorrer um caso em que o aCols esteja na                  |
		//| linha 3 e a posicao nao existir no aCusto...                                                 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aCols[nY][Len(aCols[nY])]
			AADD(aCusto, { 0 , 0 , 0 ," "," "," "," "," "," ", 0,0 } )
			aImpCusto  := {}
			For nC := 1 To Len( aImps[nY,6] )
				If aImps[nY] <> Nil .AND. Len(aImps[nY][6]) > 0
					If aImps[nY,6,nC,4] > 0
						AAdd(aImpCusto,{aImps[nY,6,nC,1],aImps[nY,6,nC,2],;
						aImps[nY,6,nC,3],aImps[nY,6,nC,4],;
						aImps[nY,6,nC,5],aImps[nY,6,nC,11],;
						aImps[nY,6,nC,12]})
					EndIf
				EndIf
			Next nC
			aCusto[nY][01] := aImps[nY,3]
			aCusto[nY][02] := AClone(aImpCusto)
			aCusto[nY][03] := 0
			aCusto[nY][04] := " "
			aCusto[nY][05] := " "
			aCusto[nY][06] := cNumAnt
			aCusto[nY][07] := cSerAnt
			aCusto[nY][08] := aCols[nY][nPosProduto]
			aCusto[nY][09] := aCols[nY][nPosLocal]
			aCusto[nY][10] := aImps[nY,1]
			aCusto[nY][11] := 0
		Else
			AADD(aCusto, { 0 , 0 , 0 ," "," "," "," "," "," ", 0,0 } )
		EndIf
	Next nY
Else
	For nY  := 1 to Len(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| O array a aCusto sempre tem que ser preenchido, independente da linha no aCols               |
		//| estar deletada ou nao, pois poderá ocorrer um caso em que o aCols esteja na                  |
		//| linha 3 e a posicao nao existir no aCusto...                                                 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aCusto, { 0 , 0 , 0 ," "," "," "," "," "," ", 0,0 } )
	Next nY
EndIf

If Len(aCols) > 0
	
	DbSelectArea("SA1")
	DbSeek(xFilial("SA1")+cCliente+cLoja)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar Registro de Devolucao em SD1 e SF1.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reclock("SF1",.T.)
	REPLACE F1_FILIAL	WITH xFilial("SF1")
	REPLACE F1_DOC   	WITH cNumNFDev
	REPLACE F1_DUPL  	WITH cDupl
	REPLACE F1_SERIE	WITH cSerieDev
	REPLACE F1_FORNECE 	WITH cCliente
	REPLACE F1_LOJA	 	WITH cLoja
	REPLACE F1_EMISSAO 	WITH dDataBase
	REPLACE F1_VALMERC 	WITH aValores[VALMERC]
	REPLACE F1_VALBRUT 	WITH aValores[VALBRUTO]
	REPLACE F1_DTDIGIT 	WITH dDataBase
	REPLACE F1_TIPO	 	WITH "D"
	REPLACE F1_ESPECIE 	WITH "NCC"
	REPLACE F1_DESCONT 	WITH aValores[VALDESC]
	REPLACE F1_EST 	 	WITH SA1->A1_EST
	REPLACE F1_FORMUL  	WITH cFormProp
	REPLACE F1_MOEDA  	WITH nMoedaTr
	REPLACE F1_TXMOEDA 	WITH nTxMoedaTr
	REPLACE F1_TIPODOC 	WITH "04"
	REPLACE F1_STATUS 	WITH "A"
	If cPaisLoc == "GUA"
		REPLACE F1_MOTIVO 	WITH cMotivo
		REPLACE F1_MANUAL    WITH Iif(lNFManual,"S","N")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os Impostos Gerados Atraves da Amarra‡Æo TesXImpostos ³
	//³ em SF1                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nC := 1 To Len( aImpVarSF1 )
		aImpVarSF1[nC,1] := "F1"+Subs(aImpVarSF1[nC,1],3,8)
	Next nC
	For nC := 1 To Len( aImpVarSF1 )
		If (aImpVarSF1[nC,2] > 0)
			nPosCpo := FieldGet(FieldPos(aImpVarSF1[nC,1]))+aImpVarSF1[nC,2]
			SF1->( FieldPut( FieldPos( aImpVarSF1[nC,1] ),nPosCpo ) )
		EndIf
	Next nC
	MsUnLock()
	
	If  ! GetMv( "MV_CLIPAD" )+ GetMv( "MV_LOJAPAD" ) == SF1->F1_FORNECE+ SF1->F1_LOJA
		aAreaSa1:=SA1->(GetArea())
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+ SF1->F1_FORNECE+ SF1->F1_LOJA))
		nMoedConv:= Iif(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, nMoedConv)
		RecLock("SA1",.F.)
		SA1->A1_VACUM-= xMoeda( SF1->F1_VALBRUT , SF1->F1_MOEDA,nMoedConv , SF1->F1_EMISSAO,, SF1->F1_TXMOEDA)
		MsUnlock()
		SA1->(RestArea(aAreaSa1))
	EndIf
	For nC := 1 To Len(aCols)
		If !aCols[nC][Len(aCols[nC])]
			
			nItem++
			
			cItem:=StrZero(nItem,2)
			
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+aCols[nC][nPosProd]))
			
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+aCols[nC][nPosTES]))
			
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek(xFilial("SD2")+cNumAnt+cSerAnt+SF1->F1_FORNECE+SF1->F1_LOJA+SB1->B1_COD))
				cItemOri := SD2->D2_ITEM
			Endif
			
			Reclock("SD1",.T.)
			REPLACE D1_FILIAL  	WITH xFilial("SD1")
			REPLACE D1_COD 	 	WITH aCols[nC][nPosProd]
			REPLACE D1_UM		WITH aCols[nC][nPosUM]
			REPLACE D1_GRUPO	WITH SB1->B1_GRUPO
			REPLACE D1_TIPO	 	WITH "D"
			REPLACE D1_ORIGLAN	WITH "LO"
			REPLACE D1_TP		WITH SB1->B1_TIPO
			REPLACE D1_NUMSEQ  	WITH ProxNum()
			REPLACE D1_QUANT	WITH aCols[nC][nPosQuant]
			REPLACE D1_VUNIT	WITH aCols[nC][nPosVUnit]
			REPLACE D1_TOTAL	WITH aCols[nC][nPosVlrItem]
			REPLACE D1_TES 	 	WITH aCols[nC][nPosTES]
			REPLACE D1_FORNECE 	WITH cCliente
			REPLACE D1_LOJA	 	WITH cLoja
			REPLACE D1_DOC 	 	WITH cNumNFDev
			REPLACE D1_SERIE	WITH cSerieDev
			REPLACE D1_EMISSAO 	WITH dDataBase
			REPLACE D1_DTDIGIT 	WITH dDataBase
			REPLACE D1_SERIE	WITH cSerieDev
			REPLACE D1_NFORI	WITH cNumAnt
			REPLACE D1_SERIORI 	WITH cSerAnt
			REPLACE D1_ITEMORI  WITH cItemOri
			REPLACE D1_NUMCQ   	WITH xNumCaixa()
			REPLACE D1_LOCAL	WITH aCols[nC][nPosLocal]
			REPLACE D1_ITEM	 	WITH cItem
			REPLACE D1_CF		WITH aCols[nC][nPosCF]
			REPLACE D1_DESC    	WITH aCols[nC][nPosDesc]
			REPLACE D1_VALDESC 	WITH aCols[nC][nPosValDesc]
			REPLACE D1_ESPECIE  WITH "NCC"
			REPLACE D1_FORMUL  	WITH cFormProp
			REPLACE D1_TIPODOC 	WITH "04"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar os Impostos variaveis do Roteiro de C lculo...      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aImps) > 0
				For nY := 1 To Len(aImps[nC][6])
					aImps[nC][6][nY][6] := "D1"+Subs(aImps[nC][6][nY][6],3,8)
					aImps[nC][6][nY][7] := "D1"+Subs(aImps[nC][6][nY][7],3,8)
					aImps[nC][6][nY][8] := "F1"+Subs(aImps[nC][6][nY][8],3,8)
					aImps[nC][6][nY][9] := "F1"+Subs(aImps[nC][6][nY][9],3,8)
				Next nY
				
				For nY := 1 To Len(aImps[nC][6])
					nCpo  := FieldPos("D1_ALQIMP"+Subst(aImps[nC][6][nY][7],10,1))
					If nCpo > 0
						If aImps[nC][6][nY][3] > 0
							FieldPut(nCpo,aImps[nC][6][nY][2]) //Valor Aliquota
						EndIf
					EndIf
					nCpo  := FieldPos(Alltrim(aImps[nC][6][nY][6]))
					If nCpo > 0
						FieldPut(nCpo,aImps[nC][6][nY][4]) //Valor BASE
					EndIf
					nCpo  := FieldPos(Alltrim(aImps[nC][6][nY][7]))
					If nCpo > 0
						FieldPut(nCpo,aImps[nC][6][nY][3]) //Valor imposto
					EndIf
				Next nY
			EndIf
			MsUnlock()
			aLivro := GetBook(@aGetBook, aImps[nC], "V", nTxMoedaTr, aLivro, "E" )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua estorno do estoque. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+SD1->D1_TES)
			
			If SF4->F4_ESTOQUE == "S"
				DbSelectArea("SD2")
				DbSetOrder(3)
				If !Empty(SD1->D1_NFORI) .AND. DbSeek(	xFilial("SD2") 	+ SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + ;
														SD1->D1_LOJA	+ SD1->D1_COD)
					aCustoDev := {	SD2->D2_CUSTO1/SD2->D2_QUANT 	, SD2->D2_CUSTO2/SD2->D2_QUANT	, SD2->D2_CUSTO3/SD2->D2_QUANT	, SD2->D2_CUSTO4/SD2->D2_QUANT	,;
									SD2->D2_CUSTO5/SD2->D2_QUANT 	, SD1->D1_NFORI				, SD1->D1_SERIORI				, SD1->D1_COD					,;
									SD1->D1_LOCAL					, SD1->D1_QUANT }
				Else
					aCustoDev := {	aCusto[nC][01], aCusto[nC][02], aCusto[nC][03]	, aCusto[nC][04]	,;
									aCusto[nC][05], SD1->D1_NFORI , SD1->D1_SERIORI, SD1->D1_COD		,;
									SD1->D1_Local , SD1->D1_QUANT }
				EndIf
				aCustoEnt := RetCusEnt(,{aCustoDev},"D")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava custo em todas moedas                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SD1")
				RecLock("SD1",.F.)
				REPLACE D1_CUSTO  WITH aCustoEnt[1][1]
				REPLACE D1_CUSTO2 WITH aCustoEnt[1][2]
				REPLACE D1_CUSTO3 WITH aCustoEnt[1][3]
				REPLACE D1_CUSTO4 WITH aCustoEnt[1][4]
				REPLACE D1_CUSTO5 WITH aCustoEnt[1][5]
				MsUnLock()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o saldo atual (VATU) com os dados do SD1     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			B2AtuComD1(1)
			SB2->(MsUnlock())
		EndIf 
        
		If ExistBlock('LJ021SD1')
			ExecBlock('LJ021SD1',.F.,.F.,{aCols,nC})
		EndIf
	Next nC
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar Registro nos Livros Fiscais...			           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nC := 2 To Len( aLivro )
		RecLock( "SF3",.T. )
		For nY := 1 To Len( aLivro[1] )
			SF3->( FieldPut(FieldPos(aLivro[1,nY]),aLivro[nC,nY]) )
		Next nY
		REPLACE F3_FILIAL  WITH xFilial("SF3")
		REPLACE F3_FORMUL  WITH cFormProp
		MsUnLock()
	Next nC
EndIf
Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ021Header ³ Autor ³ Vendas Clientes	³ Data ³ 27.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retornar o Array de Impostos...							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ aArray:=LJ021Header()                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJ021A							                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LJ021Header(cMov)
Local nI    := 0
Local nPos  := 0
Local nCpos := 0

aHeadImpostos  := {}
aFieldImpostos := {}
aFieldFinanc   := {}

aCpos := {"FB_CODIGO","FB_DESCR","ALIQUOTA","VALORBASE","VALORIMP"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader para utiliza‡Æo no Browse.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("Sx3")
DbSetOrder(2)

nCpos:=0
For nI := 1 To Len(aCpos)
	If aCpos[nI] == "ALIQUOTA"
		nCpos ++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| "Aliquota"                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aHeadImpostos,{ STR0049, "ALIQUOTA", PesqPict("SFB","FB_ALIQ",6,nMoedaTr),7,2,"AlwaysFalse()","S","N","   ","N"})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| "Aliquota"                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aFieldImpostos, STR0049 )
	ElseIf aCpos[nI] == "VALORBASE"
		nCpos ++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| "Valor Base"                                                    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aHeadImpostos,{ STR0050, "VALORBASE", PesqPict("SF1","F1_BASIMP1",18,nMoedaTr),16,2,"AlwaysFalse()","S","N","   ","N"})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//"Valor Base"                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aFieldImpostos, STR0050 )
	ElseIf aCpos[nI] == "VALORIMP"
		nCpos ++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  "Imposto"                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aHeadImpostos,{ STR0051, "VALORIMP", PesqPict("SF1","F1_VALIMP1",18,nMoedaTr),16,2,"A465ValImp(o)","S","N","   ","N"})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  "Imposto"                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aFieldImpostos, STR0051)
	Else
		If DbSeek(aCpos[nI])
			If x3uso(x3_usado) .AND. cNivel >= x3_nivel
				nCpos ++
				AADD(aHeadImpostos,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context} )
				AADD(aFieldImpostos, TRIM(x3_titulo))
			EndIf
		EndIf
	EndIf
Next nI

If cMov == "1" //Entrada
	If Len(aImpVarSF1) == 0
		aColsImpostos := Array(1,nCpos)
	Else
		aColsImpostos := Array(Len(aImpVarSF1)/2,nCpos)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols para utiliza‡Æo no Browse dentro do Folder.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCnt  := 0
	nUsado:= 0
	
	For nI := 1 To Len(aImpVarSF1) Step 2
		nCnt++
		SFB->(DbSeek(xFilial("SFB")+AllTrim(aImpVarSF1[nI][4])))
		nPos := Ascan(aColsImpostos,{|x| x[1] == aImpVarSF1[nI][4]})
		If aImpVarSF1[nI][2] > 0 .AND. aImpVarSF1[nI+1][2] > 0
			If nPos <> 0
				aColsImpostos[nPos][1] := aImpVarSF1[nI][4]
				aColsImpostos[nPos][2] := SFB->FB_DESCR
				aColsImpostos[nPos][3] := SFB->FB_ALIQ
				aColsImpostos[nPos][4] := aImpVarSF1[nI+1][2]
				aColsImpostos[nPos][5] := aImpVarSF1[nI][2]
			Else
				aColsImpostos[nCnt][1] := aImpVarSF1[nI][4]
				aColsImpostos[nCnt][2] := SFB->FB_DESCR
				aColsImpostos[nCnt][3] := SFB->FB_ALIQ
				aColsImpostos[nCnt][4] := aImpVarSF1[nI+1][2]
				aColsImpostos[nCnt][5] := aImpVarSF1[nI][2]
			EndIf
		EndIf
	Next nI
Else
	If Len(aImpVarSF2) == 0
		aColsImpostos := Array(1,nCpos)
	Else
		aColsImpostos := Array(Len(aImpVarSF2)/2,nCpos)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols para utiliza‡Æo no Browse dentro do Folder.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCnt  := 0
	nUsado:= 0
	
	For nI := 1 To Len(aImpVarSF2) Step 2
		nCnt++
		SFB->( DbSeek(xFilial("SFB")+AllTrim(aImpVarSF2[nI][1])) )
		nPos := Ascan(aColsImpostos,{|x| x[1] == aImpVarSF2[nI][1]})
		If aImpVarSF2[nI][3] > 0 .AND. aImpVarSF2[nI+1][3] > 0
			If nPos <> 0
				aColsImpostos[nPos][1] := aImpVarSF2[nI][1]
				aColsImpostos[nPos][2] := SFB->FB_DESCR
				aColsImpostos[nPos][3] := SFB->FB_ALIQ
				aColsImpostos[nPos][4] := aImpVarSF2[nI+1][3]
				aColsImpostos[nPos][5] := aImpVarSF2[nI][3]
			Else
				aColsImpostos[nCnt][1] := aImpVarSF2[nI][1]
				aColsImpostos[nCnt][2] := SFB->FB_DESCR
				aColsImpostos[nCnt][3] := SFB->FB_ALIQ
				aColsImpostos[nCnt][4] := aImpVarSF2[nI+1][3]
				aColsImpostos[nCnt][5] := aImpVarSF2[nI][3]
			EndIf
		EndIf
	Next nI
EndIf
aColsTmp := AClone(aColsImpostos)
aColsImpostos := {}
For nI := 1 To Len(aColsTmp)
	If !Empty(aColsTmp[nI][1])
		AADD(aColsImpostos,AClone(aColsTmp[nI]))
	EndIf
Next nI
If Len(aColsImpostos) == 0
	AADD(aColsImpostos,{Space(03),Space(30),0,0,0})
EndIf
DbSelectArea("SX3")
DbSetOrder(1)  

Return( .T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ021bLine  ³ Autor ³ Vendas Clientes	³ Data ³ 27/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar um array para Codigo Block do Methodo bLine do    ³±±
±±³          ³ LISTBOX (TWBrowse).                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aLine := LJ021bLine()								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021bLine(cTipo,oList,aTemp)
Local aLine := {}

If cTipo == "I" .AND. Len(aColsImpostos) > 0   //Impostos
	aLine:= {	aTemp[oList:nAt][1], aTemp[oList:nAt][2], TransForm(aTemp[oList:nAt][3]	, PesqPict("SL2","L2_ALQIMP1")), ;
				TransForm(aTemp[oList:nAt][4],PesqPict("SL2","L2_BASIMP1",15,nMoedaTr)), TransForm(aTemp[oList:nAt][5],PesqPict("SL2","L2_VALIMP1",15,nMoedaTr)) }
ElseIf cTipo = "F" .AND. Len(aColsFinanc) > 0  //Financeiro
	aLine:= {	aTemp[oList:nAt][1], aTemp[oList:nAt][2], aTemp[oList:nAt][3], aTemp[oList:nAt][4],;
				DTOC(aTemp[oList:nAt][5]), TransForm(aTemp[oList:nAt][6],PesqPict("SE1","E1_VALOR",15,nMoedaTr)), aTemp[oList:nAt][7]}
EndIf

Return( aLine )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ LJ021GetIp  ³ Autor ³ Vendas Clientes	³ Data ³ 27/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Preenche o Array do Folder...							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ021GetIp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LJ021GetIp()
Local aArea  	  := GetArea()
Local nI
Local nE
Local nC
Local nTotBaseImp := 0
Local nValorItem  := 0
Local nDescProp   := 0
Local cTes        := Space(3)
Local cProduto    := Space(15)

aImpVarSF1 := {}
aImps := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ler os Impostos calculados com base na amarra‡„o TesXip.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aCols)
	If aCols[nI][Len(aCols[nI])]
		AAdd(aImps,{0,0,0,0,0,{}})
		Loop
	Else
		SL2->(DbSetOrder(1))
		SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+StrZero(nI,2)+aCols[nI][1]))
		
		cProduto     := aCols[nI][nPosProd]
		cTES         := aCols[nI][nPosTES]
		nValorItem   := aCols[nI][nPosVlrItem]
		nTotBaseImp  += aCols[nI][nPosVlrItem]
		nDescProp    := aCols[nI][nPosDescPro]
		
		aImpVarSD1[1] := aCols[nI][nPosQuant]
		aImpVarSD1[2] := aCols[nI][nPosVUnit]
		aImpVarSD1[3] := aCols[nI][nPosVlrItem] - nDescProp
		aImpVarSD1[4] := 0
		aImpVarSD1[5] := 0
		aImpVarSD1[6] := {}
		
		SB1->( DbSetOrder(1) )
		SB1->( DbSeek(xFilial("SB1")+cProduto) )
		
		SF4->( DbSetOrder(1) )
		SF4->( DbSeek(xFilial("SF4")+cTES) )
		
		If SF4->(Found()) .AND. nValorItem <> 0
			nPosRow := nI
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Disparar rotina para executar o RdMake do c lculo dos Impostos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CalcTesxIp("E", nTotBaseImp, nValorItem,cProduto,0,nPosRow,"BALCAO")
			AAdd(aImps,aClone(aImpVarSD1))
		Else
			AAdd(aImps,{0,0,0,0,0,{}})
		EndIf
		
		For nC := 1 To Len( aImpVarSD1[6] )
			If (nE := aScan( aImpVarSF1,{|x| x[1] == aImpVarSD1[6,nC,8] } )) == 0
				AAdd( aImpVarSF1, { aImpVarSD1[6,nC,8], 0.00, aImpVarSD1[6,nC,2], aImpVarSD1[6,nC,1] } )
				nE := Len( aImpVarSF1 )
			EndIf
			aImpVarSF1[ nE,2 ] += aImpVarSD1[6,nC,4]
			
			If (nE := aScan( aImpVarSF1,{|x| x[1] == aImpVarSD1[6,nC,9] } )) == 0
				AAdd( aImpVarSF1, { aImpVarSD1[6,nC,9], 0.00, aImpVarSD1[6,nC,2], aImpVarSD1[6,nC,1] } )
				nE := Len( aImpVarSF1 )
			EndIf
			aImpVarSF1[ nE,2 ] += aImpVarSD1[6,nC,3]
		Next nC
	EndIf
Next nI
RestArea( aArea )
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ LJ021GrvSL1 ³ Autor ³ Vendas Clientes	³ Data ³ 27/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Gravar L1_STATUS em SL1...   							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ021GrvSL1(cNumOrc)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LJ021GrvSL1(cNumOrc)
Local lDevol  := .T.

If (lParcial .OR. lTroca)
	DbSelectArea("SL2")
	DbSetOrder(1)
	If DbSeek(xFilial("SL2")+cNumOrc)
		While xFilial("SL2")+cNumOrc == SL2->L2_FILIAL+SL2->L2_NUM .AND. lDevol
			If SL2->L2_STATUS <> "D" .AND. SL2->L2_QUANT > 0 .AND. SL2->L2_VLRITEM > 0
				lDevol  := .F.
			EndIf
			DbSkip()
		End
	EndIf
EndIf
If lDevol
	DbSelectArea("SL1")
	DbSetOrder(1)
	If DbSeek(xFilial("SL1")+cNumOrc)
		RecLock("SL1",.F.)
		REPLACE L1_STATUS WITH "D"
		MsUnLock()
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³Lj021TESDe³ Autor ³ Vendas Clientes		³ Data ³ 30/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Gatilho do Campo TES (L2_TES)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj021TESDev(cChamada)
Local nDescLoj   := 0
Local lRet       := .T.
Local cTES       := Iif(cChamada=="T",M->L2_TES,aCols[n][nPosTES])

SF4->(DbSetOrder(1))
If cTES < "500" .AND. SF4->(DbSeek(xFilial("SF4")+cTES))
	
	If cChamada == "T"
		aCols[n][nPosTES]:= M->L2_TES
		If SF4->(DbSeek(xFilial("SF4")+M->L2_TES))
			aCols[n][nPosCF]   := SF4->F4_CF
			M->L2_CF           := aCols[n][nPosCF]
		EndIf
	EndIf
	
	aImpVarSD1 := {aCols[n][nPosQuant],aCols[n][nPosUnit],aCols[n][nPosQuant]*aCols[n][nPosUnit],0,0,{}}
	
	aImps   := CalcImpDev(aCols[n][nPosVlrItem],@nDescLoj)
	
	LJ021Total()
	Lj021AtuImps()
Else
	HELP("",1,"INVTES")
	lRet := .F.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³Lj021AtuIm³ Autor ³ Vendas Clientes		³ Data ³ 31/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Atualiza o folder de impostos no rodape                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj021AtuImps()
Local nI
Local nX
Local nCnt      := 0
Local nPosImps  := 0

aColsImpostos := {}
For nI := 1 To Len(aImps)
	If Len(aImps[nI][6]) > 0
		nCnt++
		For nX := 1 to Len(aImps[nI][6])
			SFB->( DbSeek(xFilial("SFB")+Trim(aImps[nI][6][nX][1])))
			nPosImps := Ascan(aColsImpostos,{|x| x[1] == Trim(aImps[nI][6][nX][1]) .AND.;
			x[3]==aImps[nI][6][nX][2]})  //Verifica se jah existe o imposto com a aliquota
			If aImps[nI][6][nX][3] > 0  //Verifica se base > 0
				If nPosImps > 0
					aColsImpostos[nPosImps][4] += aImps[nI][6][nX][3]  //Base
					aColsImpostos[nPosImps][5] += aImps[nI][6][nX][4]  //Valor
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Codigo###Descricao###Aliquota###Base###Valor                    |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AAdd(aColsImpostos,{aImps[nI][6][nX][1],SFB->FB_DESCR,aImps[nI][6][nX][2],;
					aImps[nI][6][nX][3],aImps[nI][6][nX][4]})
				EndIf
			EndIf
		Next nX
	EndIf
Next nI
If Len(aColsImpostos) == 0
	Aadd(aColsImpostos,{"","",0,0,0})
EndIf
aObj[16]:SetArray(aColsImpostos)
aObj[16]:bLine:={|| LJ021bLine("I",aObj[16],aColsImpostos)}
aObj[16]:Refresh()

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ021Leg   | Autor ³ Vendas Clientes		³ Data ³08/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe uma legenda contendo as descricoes das cores dos     ³±±
±±³          ³ status dos orcamentos.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ021Leg()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021Leg()
Local aLegenda := { {"BR_VERMELHO",	STR0102},;	 //"Vendas devolvidas/trocadas"
					{"BR_AMARELO" ,	STR0103},;  //"Orcamentos em aberto"
                    {"BR_VERDE"   ,	STR0104}}   //"Vendas efetuadas"
BrwLegenda(STR0027,STR0101,aLegenda)		    // "Troca","Legenda"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021GeraSE5| Autor ³ Vendas Clientes		³ Data ³20/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao de registros no arq. Mov. Bancario para refletir a ³±±
±±³          ³ devolucao de Dinheiro.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj021GeraSE5(nX)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021GeraSE5(nX)
Local nDecs  := MsDecimais(nX)

RecLock("SE5",.T.)
REPLACE E5_FILIAL  	WITH xFilial("SE5")
REPLACE E5_DATA	 	WITH dDataBase
REPLACE E5_CLIFOR  	WITH cCliente
REPLACE E5_LOJA	 	WITH cLoja
REPLACE E5_AGENCIA 	WITH IIf (nX==1,".",GetMV("MV_SIMB"+Str(nX,1)))
REPLACE E5_TIPODOC 	WITH "LJ"
REPLACE E5_TIPO	 	WITH GetMv("MV_SIMB"+Str(nX,1))
REPLACE E5_VALOR	WITH aDevol[nX][3]
REPLACE E5_DTDIGIT 	WITH dDataBase
REPLACE E5_DTDISPO 	WITH SE5->E5_DATA
REPLACE E5_BANCO	WITH xNumCaixa()
REPLACE E5_CONTA	WITH "."
REPLACE E5_VENCTO  	WITH dDataBase
REPLACE E5_RECPAG  	WITH "P"
REPLACE E5_MOTBX	WITH "NOR"
REPLACE E5_BENEF	WITH cUserName
REPLACE E5_VLMOED2 	WITH Round(xMoeda(aDevol[nX][3],nX,1,SE5->E5_DATA,nDecs+1),nDecs)
REPLACE E5_HISTOR  	WITH STR0097 //"BAIXA REF. DEVOL. EM DINHEIRO"
If lTotal
	REPLACE E5_NATUREZ WITH STR0098 //"DEVOLUCAO"
ElseIf lParcial
	REPLACE E5_NATUREZ WITH STR0099 //"DEV/PARCIAL"
Else
	REPLACE E5_NATUREZ WITH STR0100 //"TROCA"
EndIf
MsUnLock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza saldo do BANCO Caixa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,"-")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021Visual   ³ Autor ³ Vendas Clientes	³ Data ³ 23.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualizacao dos dados da nota fiscal                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj021Visual(cAlias,nRecno,nOpcx)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021Visual(cAlias,nRecno,nOpcx)
Local aArea  := GetArea()

LJ021DevLocal(cAlias,nRecno,nOpcx,.T.)

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021Hist ³ Autor ³ Vendas Clientes		³ Data ³ 28.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Hist¢rico dos ultimos orcamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj021Hist()
Local oLbx
Local oLbx1
Local cIndex1
Local cIndex2
Local cKey
Local cCodPed
Local cFiltro
Local oHist
Local nHist
Local nCompl
Local aItems:={}

If Empty( cCliente )
	Help(" ",1,"SEM DADOS" )
	Return .T.
Endif

DbSelectArea( "SL1" )
DbSetOrder(6)
If !DbSeek(xFilial("SL1")+cCliente+cLoja)
	Help(" ",1,"SEM DADOS" )
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice Condicional para a selecao dos pedidos do cliente selecionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex1 := CriaTrab(Nil,.F.)
DbSelectArea("SL1")
DbSetOrder(6)
DbGotop()
cFiltro:='L1_FILIAL == "'+xFilial("SL1")+'" .AND. L1_CLIENTE == "'+cCliente+'".AND. L1_LOJA == "'+cLoja+'"'
cKey	 := IndexKey()
IndRegua("SL1",cIndex1,cKey,,cFiltro,STR0122)  //"Selecionando Historico"
DbGotop()

cCodPed:=SL1->L1_NUM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oHist FROM  48,171 TO 363,655 TITLE STR0046 PIXEL  //"Historico"

@	3,5 TO  136, 235 LABEL STR0123 OF oHist PIXEL //"Ultimos Orcamentos\Vendas"
@	10,8 LISTBOX oLbx VAR nHist FIELDS SL1->L1_NUM,SL1->L1_EMISSAO,;
Lj020NomVen(),Lj020TpOpe(),Transform(SL1->L1_VLRLIQ,PesqPict("SL1","L1_VLRLIQ",15,nMoedaTr));
HEADER STR0118,STR0124,STR0125,STR0126,STR0022; //"Orcamento"###"Data"###"Vendedor"###"Operacao"###"Valor de Mercadoria"
ALIAS "SL1";
SIZE 225,60 OF oHist	PIXEL

oLbx:bChange := {||Lj020CargaP(oLbx,@cIndex2,oLbx1,@aItems)}
oLbx:Refresh()
oLbx:SetFocus(.T.)

@ 75,8 LISTBOX oLbx1 VAR nCompl FIELDS SL2->L2_PRODUTO,Lj020NomPro(),Transform(SL2->L2_QUANT,"@E 99999.99");
HEADER STR0127,STR0128,STR0129; //"Produto"###"Descricao"###"Quantidade"
ALIAS "SL2";
SIZE 225,60 OF oHist PIXEL

oLbx1:SetArray(aItems)
oLbx1:bLine:={||{aItems[oLbx1:nAt,1],;
aItems[oLbx1:nAt,2],;
aItems[oLbx1:nAt,3]}}

oLbx1:bLDblClick := {|| Lj020ProVisu(nil,oLbx1,1)}
oLbx1:Refresh()

DEFINE SBUTTON FROM 142,180 TYPE 1 ENABLE OF oHist ACTION (DbSetOrder(1),oHist:End())

ACTIVATE MSDIALOG oHist CENTER

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario e Restaura os Indices Ativos	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL1")
Set Filter To
RetIndex("SL1")
DbSetOrder(1)
If File(cIndex1+OrdBagExt())
	Ferase(cIndex1+OrdBagExt())
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021Impostos³ Autor ³ Vendas Clientes	³ Data ³ 28/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de tratamento do folder dos impostos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj021Impostos(oDlg)   									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021Impostos(oDlg)
Local oLbx

oLbx :=	TWBrowse():New( 1.2,.8,385,60,,aFieldImpostos,{40,150,25,70,65},oDlg,,,,,,,,,,,, .F.,, .T.,, .F.,,, )
oLbx:SetArray(aColsImpostos)
oLbx:bLine:={|| LJ021bLine("I",oLbx,aColsImpostos)}
oLbx:lAutoEdit:=.F.

Return oLbx

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021Financ  ³ Autor ³ Vendas Clientes	³ Data ³ 28/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de tratamento do folder financeiro                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj021Financ(oDlg)   	    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021Financ(oDlg)
Local oLbx

oLbx := TWBrowse():New( 1.2,.8,385,60,,{ STR0105, STR0106, STR0107, STR0117, STR0108, STR0109, STR0110 },{45,20,20,20,45,90,10}, oDlg,,,,,,,,,,,, .F.,, .T.,, .F.,,, )  //"Numero"###"Prefixo"###"Parc."###"Tipo"###"Vencto"###"Valor"###"Moeda"
oLbx:SetArray(aColsFinanc)
oLbx:bLine:={|| LJ021bLine("F",oLbx,aColsFinanc)}
oLbx:lAutoEdit:=.F.

Return oLbx

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021DelIt   ³ Autor ³ Vendas Clientes	³ Data ³ 16/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Deleta os itens do aCols dependendo do parametro MV_LJDELTD³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj021DelIt()   	    								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021DelIt()
Local nI

If !lTotal .AND. GetMV("MV_LJDELTD") == "S"  //Determina se os itens aparecem excluidos, por DEFAULT
	For nI := 1 to Len(aCols)
		aCols[nI][len(aCols[nI])] := !aCols[nI][Len(aCols[nI])]
	Next nI
	LJ021GetIp()
	LJ021Refresh()
	
	oGet:oBrowse:Refresh()
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021Saida   ³ Autor ³ Vendas Clientes	³ Data ³ 28/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Alimenta as variaveis para futura compensacao dos titulos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj021Saida()   	    								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021Saida(cDocumen,nRecno)

cSE5Documen := cDocumen
nSE1Recno := nRecno

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021CriaTp  ³ Autor ³ Vendas Clientes	³ Data ³ 17/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria o tipo de titulo na tabela 05 do arquivo SX5.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj021Saida()   	    								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021 (Integridade Referencial)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj021CriaTp(cTipoTit)
Local aAreaAtu := GetArea()
Local aAreaSX5 := {}

If (AllTrim(cTipoTit) == "NF" .AND. !lGeraNCC) .OR. IsMoney(cTipoTit)
	cTipoTit := Subs(cTipoTit,1,2)+"-"
Else
	If AllTrim(cTipoTit) == "CC" .OR. AllTrim(cTipoTit) == "CD" .OR. ;
		AllTrim(cTipoTit) == "VL" .OR. AllTrim(cTipoTit) == "PG"
		cTipoTit := cTipoTit+"-"
	Else
		cTipoTit := Subs(cTipoTit,1,2)+"-"
	EndIf
EndIf

DbSelectArea("SX5")
aAreaSX5 := GetArea()
If !DbSeek(xFilial("SX5")+"05"+cTipoTit)
	RecLock("SX5",.T.)
	X5_FILIAL := xFilial("SX5")
	X5_TABELA := "05"
	X5_CHAVE  := cTipoTit
	X5_DESCRI := "DEVOLUCAO EM "+cTipoTit
	X5_DESCSPA:= "DEVOLUCION EN "+cTipoTit
	X5_DESCENG:= "RETURN IN "+cTipoTit
	dbCommit()
	MsUnlock()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Restaura as areas originais...                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSX5)
RestArea(aAreaAtu)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021CriaNat ³ Autor ³ Vendas Clientes	³ Data ³ 17/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria a natureza do titulo no arquivo SED.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj021Saida()   	    								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021 (Integridade Referencial)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj021CriaNat(cTipoTit)
Local aAreaAtu := GetArea()
Local aAreaSED := {}
Local cCodNat  := ""
Local cDescNat := ""

If AllTrim(cTipoTit) == "NF"
	If lGeraNCC
		cCodNat  := &(GetMV("MV_NATNCC"))
		cDescNat := STR0085 //"NOTA CREDITO"
	Else
		cCodNat  := &(GetMV("MV_NATDINH"))
		cDescNat := STR0087 //"DINHEIRO"
	EndIf
Else
	If AllTrim(cTipoTit) == "CC"
		cCodNat  := &(GetMV("MV_NATCART"))
		cDescNat := STR0089 //"CARTAO DE CREDITO"
	ElseIf AllTrim(cTipoTit) == "CD"
		cCodNat  := SuperGetMV("MV_NATTEF")
		cCodNat  := If( Substr(cCodNat,1,1)=="&", &(Substr(cCodNat,2,Len(cCodNat))), cCodNat )
		cDescNat := STR0091 //"CARTAO DE DEBITO"
	ElseIf AllTrim(cTipoTit) == "VL"
		cCodNat  := &(GetMv("MV_NATVALE"))
		cDescNat := STR0093 //"VALE"
	ElseIf AllTrim(cTipoTit) == "PG"
		cCodNat  := &(GetMv("MV_NATOUTR"))
		cDescNat := STR0095 //"PAGARE"
	ElseIf IsMoney(cTipoTit)
		cCodNat  := &(GetMV("MV_NATDINH"))
		cDescNat := STR0087 //"DINHEIRO"
	EndIf
EndIf

DbSelectArea("SED")
aAreaSED := GetArea()
If !DbSeek(xFilial("SED")+cCodNat)
	RecLock("SED",.T.)
	ED_FILIAL := xFilial("SED")
	ED_DESCRIC:= cDescNat
	MsUnLock()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Restaura as areas originais...                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSED)
RestArea(aAreaAtu)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021ValSA³ Autor ³ Vendas Clientes		³ Data ³ 15/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se o numero da NCC esta registrado em resolucao(SAT)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj021ValSAT(cSerieNCC,cNumNCC)           			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021ValSAT(cSerieNCC,cNumNCC)
Local lRet 		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se numeracao da NCC esta autorizada por resolucao   ³
//³(SAT)-Loc. Guatemala                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "GUA"
	lRet  := ValNumSAT(cSerieNCC,cNumNCC,"2",lNFManual)
	If !lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Atenção"###"Numeracao: "###" nao autorizada por resolucao. Entre em contato com a SAT."###"Ok |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aviso(STR0009,STR0178+cNumNCC+"/"+cSerieNCC+STR0179,{STR0150})
	EndIf
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021MotDe³ Autor ³ Vendas Clientes		³ Data ³ 19/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite indicar o motivo da devolucao - Loc. Guatemala     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021MotDev(cDescricao)
Local oDlgMotivo
Local oMotivo
Local oDescMot
Local cDescMot := Space(55)
Local lRet     := .T.

DEFAULT cDescricao := ""

DEFINE MSDIALOG oDlgMotivo FROM 200,200 TO 300,500 TITLE STR0183 PIXEL //"Motivo da Devolucao"
@ 0.5,01 SAY STR0184 SIZE 78,17 OF oDlgMotivo //"Motivo"
@ 1.2,01 MSGET oMotivo VAR cMotivo OF oDlgMotivo SIZE 35,08 F3 "O1" VALID Lj021DescMot(@cDescMot,oDescMot)

@ 1.2,05 MSGET oDescMot VAR cDescMot OF oDlgMotivo SIZE 110,08 WHEN .F.

DEFINE SBUTTON FROM 30,40 TYPE 1 ACTION {||(lRet:=.T.,cDescricao := cDescMot,oDlgMotivo:End())} ENABLE OF oDlgMotivo
DEFINE SBUTTON FROM 30,75 TYPE 2 ACTION {||(lRet:=.F.,oDlgMotivo:End())} ENABLE OF oDlgMotivo
ACTIVATE MSDIALOG oDlgMotivo

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021DescM³ Autor ³ Vendas Clientes		³ Data ³ 19/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca a descricao do motivo cadastrado na tabela O1 do SX5 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj021DescMot(ExpC1,ExpO1)                   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - descricao do motivo                 			      ³±±
±±³          ³ ExpO1 - objeto da descricao do motivo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj021DescMot(cDescMot,oDescMot)
Local lRet  := .T.

SX5->(DbSetOrder(1))
If lRet  := (SX5->(DbSeek(xFilial("SX5")+"O1"+cMotivo)))
	cDescMot  := X5Descri()
	oDescMot:Refresh()
Else
	cDescMot  := Space(55)
	oDescMot:Refresh()
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021VldNC³ Autor ³ Vendas Clientes		³ Data ³ 21/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a NCC ja se encontra na base de dados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj021VldNCC(ExpC1,ExpC2)                   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - serie da NCC Manual              			      ³±±
±±³          ³ ExpC2 - numero da NCC manual                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021VldNCC(cSerieNCC,cNumNCC)
Local lRet 		:= .T.
Local nRecSF1   := SF1->(Recno())
Local nOrderSF1 := SF1->(IndexOrd())

cSerieNCC	:= Padr(cSerieNCC,TamSx3("F1_SERIE")[1])
cNumNCC 	:= Padr(cNumNCC,TamSx3("F1_DOC")[1])

If Empty(cNumNCC)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| "Atencao"###"Digite a serie e o numero da Nota de Credito e confirme a operacao."###"Ok"     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso(STR0009,STR0188,{ STR0150 })
	Return .F.
EndIf

DbSelectArea("SF1")
DbSetOrder(1)
DbSeek(xFilial("SF1")+cNumNCC+cSerieNCC)
While !Eof() .AND. SF1->F1_DOC+SF1->F1_SERIE = cNumNCC+cSerieNCC .AND. lRet
	If SF1->F1_FORMUL <> "S" .OR. SF1->F1_TIPODOC <> "04"
		DbSkip()
		Loop
	EndIf
	lRet  := .F.
	DbSkip()
End

If !lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|"Atencao"###"O documento Nota de Credito numero "###" ja esta gravado na base dados."###"Ok"  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso(STR0009, STR0189 + cSerieNCC + "/" + cNumNCC + STR0190, { STR0150 })
EndIf
SF1->(DbGoto(nRecSF1))
SF1->(DbSetOrder(nOrderSF1))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021Exit ³ Autor ³ Vendas Clientes		³ Data ³ 21/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao para nao permitir sair da tela de selecao do     ³±±
±±³          ³ numero e serie da NCC quando NCC for manual                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj021Exit(ExpN1)                   			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - opcao selecionada                			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj021Exit(nOpcaoSel)
Local lRet  := .F.

lRet  := nOpcaoSel == 1

If !lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| "Atencao"###"Digite a serie e o numero da Nota de Credito e confirme a operacao."###"Ok"     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso(STR0009,STR0188,{ STR0150 })
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021UltIt³ Autor ³ Vendas Clientes		³ Data ³ 04/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca o ultimo item do orcamento. Quando se tratar de devo-³±±
±±³          ³ lucao/troca parcial em que gera registro no SL2 deve gravar³±±
±±³          ³ L2_ITEM a partir do ultimo item do orcamento. Implementacao³±±
±±³          ³ realizada devido a chave unica do SL2(orcamento+item)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN2 := Lj021UltItem(ExpC1)               			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Numero do orcamento                			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpN2 - Ultimo item do orcamento(numerico)  			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj021UltItem(cOrcNum)
Local nUltItem  := 1

DbSelectArea("SL2")
DbSetOrder(1)
DbSeek(xFilial("SL2")+cOrcNum+"ZZ",.T.)
DbSkip(-1)
If SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2")+cOrcNum
   nUltItem  := VAL(SL2->L2_ITEM)
EndIf

Return (nUltItem)
