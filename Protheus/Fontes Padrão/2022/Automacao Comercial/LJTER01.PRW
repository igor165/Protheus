#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "LJTER01.CH"

//Posicoes da array aProds (Itens da venda)
#DEFINE ELEMENTOS_PRODUTO      10 //Quantidades de elementos da array aProds

#DEFINE CODIGO_PRODUTO          1
#DEFINE DESCRICAO_PRODUTO       2
#DEFINE PRECO_UNITARIO_PRODUTO  3
#DEFINE QUANTIDADE_PRODUTO      4
#DEFINE VALOR_DESCONTO_PRODUTO  5
#DEFINE VALOR_IPI_PRODUTO       6
#DEFINE TES_PRODUTO			     7
#DEFINE TABELA_PADRAO_PRODUTO   8
#DEFINE VALOR_ACRESCIMO_PRODUTO 9 
#DEFINE VALOR_IMPOSTO_PRODUTO   10

//Posicoes da array aParcelas  (Parcelas a pagar)
#DEFINE DATA_PARCELAS          1
#DEFINE VALOR_PARCELAS         2
#DEFINE FORMA_PAGTO_PARCELAS   3

Static cOpcaoMenC     := Iif(FwRetIdiom()=="en","S","C")
Static cOpcaoS     	  := Iif(FwRetIdiom()=="en","Y","S")
Static cOpcaoMenP     := "P"
Static cOpcaoN        := "N"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LJTER01  ³Autor  ³ Fernando Salvatori    ³ Data ³ 12/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa que efetua um orcamento no Micro-Terminal          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJTER01(void)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MICRO-TERMINAL                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Dolis         ³10/08/06³104230³Gravacao do campo L2_ITEMSD1             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJTER01()
Local lConsulta  := .F.             	   	//Variavel que controla a utilizacao da rotina de Consulta
Local lPreVenda  := .F.						//Variavel que controla a utilizacao da rotina de Pre-Venda
Local lMenu      := .T.                  	//Utilizada para o controle do Menu - Default Verdadeiro
Local lTerNumOrc := ExistBlock("LJNUMORC")  //Ponto de entrada que faz a solicitacao do numero do orcamento

Private cTipoMicro := ""					//Var. que guarda o parametro que configura a quantidade de caracteres da linha do MicroTerminal

cTipoMicro := Alltrim(GetMV("MV_LJTPMIC"))  //Determina o tipo de MicroTerminal(16 ou 40 Teclas)

//Caso for MicroTerminal de 16 teclas, o mesmo não possui teclas alfabeticas.
If cTipoMicro == "1"
	cOpcaoMenC := "1"
	cOpcaoMenP := "2"
	cOpcaoS    := "1"
	cOpcaoN    := "2"

EndIF

Do While lMenu
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamada do Menu Principal do Micro Terminal para 16 caracteres em uma linha³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMenu
		TerMenu( @lMenu,@lConsulta,@lPreVenda )
	EndIf
	
	If lConsulta     	//Caso selecionado a opcao de (C)onsulta
		TerConsulta(lTerNumOrc)
	ElseIf lPreVenda 	//Caso for selecionado a opcao de (P)re-Venda
		TerPreVenda(lTerNumOrc)
	Else
		lMenu := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que finaliza o Micro-Terminal caso seja feito pelo Monitor.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TerIsQuit()
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerConsultºAutor  ³Fernando Salvatori  º Data ³  12/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada dos processos de consulta da Venda                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TerConsulta(lTerNumOrc)
Local lLoop     := .T. 				//Variavel que controla o retorno para o Menu Principal.
//Cria Variaveis especificas de localizacoes
Local aImpsSL1 := {} //Arrays de Impostos Variaveis
Local aImpsSL2 := {}
Local nImpVarDisc := 0 //Total dos impostos variaves Discriminados
Local nImpVarIncl := 0 //Total dos impostos variaves Incluidos 
Local nImpTmpDisc := 0 //Total dos impostos variaves Discriminados - Consulta
Local nImpTmpIncl := 0 //Total dos impostos variaves Incluidos - Consulta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop principal para solicitacao dos dados para consulta         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Do While lLoop
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a consulta do codigo do produto e a verificacao do mesmo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TerProdut( ,@lLoop,,.F.,,@aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
	TerIsQuit()
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerPreVendºAutor  ³Fernando Salvatori  º Data ³  12/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamada dos processos de Pre-venda da Venda                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TerPreVenda(lTerNumOrc)
Local aProds     := {}              //Produtos da venda
Local aParcelas  := {}              //Array com as parcelas a pagar  (condicao pgto)
Local lCodVen    := !( lTerNumOrc )	//Variavel que controla a utilizacao da funcao TerVended.
Local lNumOrc    := lTerNumOrc 		//Variavel que controla a utilizacao do ponto de entrada para n. do orcamento.
Local lCodProd   := .F.  	    	//Variavel que controla a utilizacao da funcao TerProdut.
Local lCondPg    := .F.      		//Variavel que controla a utilizacao da funcao TerCondPg.
Local lGravaOrc  := .F.				//Variavel que controla a utilizacao da funcao de Gravacao do orcamento.
Local lDescTotal := .F. 			//Variavel que controla o desconto total no produto
Local lPasso2    := .F.            	//Variavel que sera utilizada no passo 2 da sequencia de perguntas
Local lLoop      := .T. 			//Variavel que controla o retorno para o Menu Principal.
Local cNumOrc    := "" 		  		//Variavel que guarda o numero do orcamento digitado pelo usuario
Local nTamE4     := TamSX3( "E4_CODIGO" )[1] // Variavel que armazena o tamanho do campo cod condicao de pagamento
Local cCodCpg    := Space( nTamE4 )         // Variavel que guarda o codigo da cond. de pagamento
Local nTamA3     := TamSX3( "A3_COD" )[1] // Variavel que armazena o tamanho do campo do cod do vendedor
Local cCodVend   := Space( nTamA3 )      // Variavel que guarda o codigo do Vendedor
Local nDescTotal := 0               //Valor do desconto do produto
Local nDescPer   := 0               //Valor do desconto total em percentual 

//Cria Variaveis especificas de localizacoes
Local aImpsSL1 := {} //Arrays de Impostos Variaveis
Local aImpsSL2 := {}
Local nImpVarDisc := 0 //Total dos impostos variaves Discriminados
Local nImpVarIncl := 0 //Total dos impostos variaves Incluidos 
Local nImpTmpDisc := 0 //Total dos impostos variaves Discriminados - Consulta
Local nImpTmpIncl := 0 //Total dos impostos variaves Incluidos - Consulta
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel lPasso2                                             ³
//³                                                             ³
//³Sera utilizada no envio do primeiro parametro                ³
//³da funcao que faz a pergunta do codigo do vendedor           ³
//³                                                             ³
//³Caso o usuario retorne a funcao anterior (ESC),se caso existe³
//³o ponto de entrada, ele retornará ao mesmo, casocontrario,   ³
//³retornara ao menu principal.                   			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop principal para solicitacao dos dados para consulta         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Do While lLoop
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa o ponto de entrada para solicitar o codigo do orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lTerNumOrc ) .And. ( lNumOrc )
		cNumOrc  := ExecBlock( "LJNUMORC",.F.,.F. )
		If !Empty( cNumOrc )
			lNumOrc  := .F.
			lCodVen := .T.
		Else
			lLoop    := .F.
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a pergunta do codigo do vendedor e a verificacao do mesmo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCodVen
		TerVended( @lPasso2,@lCodVen,@lCodProd,@cCodVend )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizacao do controle de Loop.									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTerNumOrc
			lNumOrc := lPasso2
		ElseIf !lCodVen
			lLoop   := !( lPasso2 )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a pergunta do codigo do produto e a verificacao do mesmo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCodProd
		TerProdut( @lCodVen,@lCodProd,@lDescTotal,.T.,@aProds,@aImpsSL1,@aImpsSL2,;
                   @nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
	EndIf       
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a pergunta do desconto total                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDescTotal
		TerCalcPro(aProds) //calculos
		TerDescTotal(@lCodProd,@lDescTotal,@lCondPg,@aProds,@nDescTotal,;
		             @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl,;
		             @nDescPer)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a pergunta do codigo da cond. de pagamento a verificacao do mesmo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCondPg       
		TerCondPg(@lDescTotal,@lCondPg,@lGravaOrc,@aProds,@cCodCpg,@aParcelas,@nDescTotal,;
		          @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que Grava o Orcamento do Cliente  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGravaOrc
		TerGravaOrc( @lCondPg,@lGravaOrc,@lLoop,cNumOrc,aProds,nDescTotal,cCodVend,cCodCpg,aParcelas,;
		             @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl,nDescPer)
	EndIf
	
	TerIsQuit()

EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerMenu   ºAutor  ³Fernando Salvatori  º Data ³  12/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que chama o menu principal do Terminal              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TerMenu( lMenu,lConsulta,lPreVenda )
Local cOpcao := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa a tela do Visor do Micro Terminal e o Buffer				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TerCls()
TerCBuffer()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia mensagens ao Terminal							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoMicro == "1"
	TerSay(00,00,Padr(STR0034,16)) //"(1)Consulta"
	TerSay(01,00,Padr(STR0035,16)) //"(2)Pre-Venda:"
ElseIf cTipoMicro == "2"
	TerSay(00,00,Padr(STR0001,40)) // "(C)onsulta  (P)re-venda"
	TerSay(01,00,Padr(STR0002,40)) // "Selecione a sua opcao: "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop que controla o Valor digitado pelo usuario e o monitor do MicroTerminal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While !( Trim(Upper(cOpcao)) $ (cOpcaoMenC + cOpcaoMenP) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera o valor digitado pelo usuario			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOpcao := TerInkey(0)
	TerIsQuit()
EndDo

cOpcao := Trim( Upper( cOpcao ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a opcao for de Consulta         			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOpcao == cOpcaoMenC
	lConsulta := .T. //Acessa a funcao de consulta
	lPreVenda := .F. //Desabilita a funcao do Pre Venda
ElseIf cOpcao == cOpcaoMenP
	lConsulta := .F. //Acessa a funcao de consulta
	lPreVenda := .T. //Desabilita a funcao do Pre Venda
EndIf

lMenu     := .T. //Utiliza o Menu para proxima venda ou Retorno

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerVended ºAutor  ³Fernando Salvatori  º Data ³  12/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que solicita o codigo do vendedor                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TerVended(lPasAnt,lPasAtu,lPasSeg,cCodVend)
Local cMensagem := "" 	  							//Mensagem do Programa
Local cFilSA3   := SA3->( xFilial("SA3") ) 		//Filial Cadastro de Clientes
Local cEspA3Cod	:= Space( TamSX3( "A3_COD" )[1] )	//Espaco do campo A3_COD

lPasAnt  := .T.
lPasAtu  := .F.
lPasSeg  := .F.

Do While .T.
	
   cCodVend := cEspA3Cod
   
	TerCls()
	TerCBuffer()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Solicita o Codigo do Produto										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TerSay(00,00,STR0003 + Space(1) ) //"Vendedor: "
	If cTipoMicro == "1"
		TerGetRead(01,00,@cCodVend,"XXXXXX@", {|| !Empty(cCodVend) } )
	ElseIf cTipoMicro == "2"
		TerGetRead(00,Len(STR0003) + 1,@cCodVend,"XXXXXX@", {|| !Empty(cCodVend) } )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Teclou Esc, sai da funcao e retorna ao passo anterior			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TerEsc()
		Return
	EndIf
	
	dbSelectArea("SA3")
	dbSetOrder(1)
	
	If dbSeek( cFilSA3 + cCodVend )
		If cTipoMicro == "1"
			cMensagem := Padr( A3_NOME,16 )
			TerSay( 01, 00, cMensagem )
		ElseIf cTipoMicro == "2"
			cMensagem := Padr( A3_COD + " - " + A3_NOME,40 )
			TerSay( 01, 00, cMensagem )
		EndIf
		
		TerInkey(0)
		
		//Se o usuario teclar Esc, perguntar novamente o vendedor
		If TerEsc()
			Loop
		EndIF
		
		Exit
	Else
		If cTipoMicro == "1"
			cMensagem := Padr(STR0036,16) //"Vendedor nao"
			TerSay( 00, 00, cMensagem )
			
			cMensagem := Padr(STR0037,16) //"cadastrado."
			TerSay( 01, 00, cMensagem )
		ElseIf cTipoMicro == "2"
			cMensagem := Padr(STR0004,40) //"Vendedor nao cadastrado"
			TerSay( 01, 00, cMensagem )
		EndIf
		TerInkey(0)
		TerIsQuit()
	EndIf
EndDo

lPasAnt  := .F.
lPasSeg  := .T.

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerProdut ºAutor  ³Fernando Salvatori  º Data ³  12/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que solicita o codigo do Produto                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TerProdut(lPasAnt,lPasAtu,lPasSeg,lPVenda,aProds,aImpsSL1,aImpsSL2,;
                          nImpVarDisc,nImpVarIncl,nImpTmpDisc,nImpTmpIncl)
Local nQtde     := 0 							//Quantidade de itens do produto
Local nTamB1    := TamSX3( "B1_COD" )[1] //Tamanho do campo cod produto
Local cProduto  := Space( nTamB1 )			//Codigo do Produto
Local cMensagem := ""                           //Mensagem padrao para as perguntas
Local nItem     := 1 							//Controle dos itens
Local cTabPad   := Trim(GetMV( "MV_TABPAD" )) 	//Retiro a tabela padrao de venda
Local cItemMenu := "" 							//Mensagem do menu
Local lMovimIt  := .F. 							//Variavel que indica que os intens do produto foi movimentado por PGUP(ESC) e PGDN(ENTER)
Local lExcluiu  := .F. 							//Funcao que indica que o item foi excluido
Local cOpcaoEx  := "" 							//Opcao de exclusao
Local cOpcaoAb  := ""							//Opcao de Aborto da operacao
Local cSimbMoed := GetMV("MV_SIMB1")            //Simbolo da moeda
Local nX

Local cFilSB0 := SB0->( xFilial("SB0") )//Cad. de Produtos (Tabela de venda)
Local cFilSB1 := SB1->( xFilial("SB1") )//Cadastro de Produtos
Local cFilSB2 := SB2->( xFilial("SB2") )//Produtos no Estoque
Local cFilSLK := SLK->( xFilial("SLK") )//Codigo de Barra por produto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a rotina executada for (P)re-Venda							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lPasAtu := .F.
If lPVenda
	lPasAnt := .T.
	lPasSeg := .F.
EndIf

Do While .T.
	nQtde     := 0
	cMensagem := ""
	lExcluiu  := .F.
	cOpcaoEx  := ""
	copcaoAb  := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa tela do MicroTerminal										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TerCls()
	TerCBuffer()
	
	If lPVenda
		If nItem == 0 //Retorno a pergunta anterior
			If Len( aProds ) > 0
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Solicito ao usuario, uma confirmacao para retornar ao passo anterior³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do While nItem == 0
					TerCls()
					TerCBuffer()
					
					If cTipoMicro == "1"
						TerSay(00,00,Padr(STR0038,16)) //"Deseja retornar?"
						TerSay(01,00,Padr(STR0039,16)) //"(1=S/2=N):"
					ElseIf cTipoMicro == "2"
						TerSay(00,00,Padr(STR0005,40)) //"Os produtos cadastrados serao perdidos. "
						TerSay(01,00,Padr(STR0006,40)) //"Deseja retornar? (S/N): "
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Loop que controla o Valor digitado pelo usuario e o monitor do MicroTerminal ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Do While !(Trim(Upper( cOpcaoAb )) $ ( cOpcaoS + cOpcaoN ))
						cOpcaoAb := Trim(Upper( TerInkey(0) ))
						TerIsQuit()
					EndDo
					
					TerIsQuit()
					
					If cOpcaoAb == cOpcaoS
						//Limpo os produtos para a proxima pergunta
						aProds := {}
						If cPaisLoc <> "BRA"
							aImpsSL1 := {}
							aImpsSL2 := {}
							nImpVarDisc := 0
							nImpVarIncl := 0						 
							nImpTmpDisc := 0
							nImpTmpIncl := 0						
						EndIf
						Return
					Else
						nItem += 1 //Posiciono no 1 item para o procedimento de venda
					EndIf
				EndDo
			Else
				Return //Saio da rotina para a pergunta anterior.
			EndIf
			
			Loop
			
		ElseIf nItem > Len( aProds ) .And. Len( aProds ) > 0 .And. Empty( cProduto) //Retorno para a Proxima pergunta
			aSize( aProds, Len( aProds ) - 1 )  //Removo o produto em branco
			Exit
		ElseIf nItem > Len( aProds ) //Pergunto mais um produto
			AAdd(aProds , Array( ELEMENTOS_PRODUTO ) )
		EndIf
		
		//Menu do Produto
		If Empty( aProds[nItem][CODIGO_PRODUTO] )
			If cTipoMicro == "1"
				cItemMenu := AllTrim(Str( nItem )) + "-" + STR0009  //"Produto:"
				cItemMenu := Padr( cItemMenu ,16)
				
				TerSay(00,00, cItemMenu )
				
				//Retiro o codigo do produto para preencher na array
				cProduto := Space( nTamB1 )
				lMovimIt := .F.
				TerGetRead(01,00,@cProduto,"XXXXXXXXXXXXXXX@", {|| IIf( Empty(aProds[1][CODIGO_PRODUTO]),!Empty(cProduto),.T.) })
			ElseIf cTipoMicro == "2"
				cItemMenu := STR0007 + AllTrim(Str( nItem )) + Space(1) + STR0008 + cTabPad  // "Item:" //"Tab.Preco:"
				cItemMenu := Padr( cItemMenu ,40)
				
				TerSay(00,00, cItemMenu )
				TerSay(01,00, STR0009) //"Produto:"
				
				//Retiro o codigo do produto para preencher na array
				cProduto := Space( nTamB1 )
				lMovimIt := .F.
				TerGetRead(01,Len(STR0009) + 1,@cProduto,"XXXXXXXXXXXXXXX@", {|| IIf( Empty(aProds[1][CODIGO_PRODUTO]),!Empty(cProduto),.T.) })
			EndIf
		Else
			//Apenas exibo o registro que foi selecionado
			If cTipoMicro == "1"
				cItemMenu := aProds[nItem][DESCRICAO_PRODUTO]
				TerSay(00,00, Padr( cItemMenu ,16) )
				
				cItemMenu := AllTrim(Str( nItem )) + " "
				cItemMenu += Alltrim(Str(aProds[nItem][QUANTIDADE_PRODUTO], 12, 2)) + " "
				cItemMenu += AllTrim(Transform(aProds[nItem][PRECO_UNITARIO_PRODUTO]+If(cPaisLoc<>"BRA",aProds[nItem][VALOR_IMPOSTO_PRODUTO],0),PesqPict("SL1","L1_VLRTOT")))
				TerSay(01,00, Padr( cItemMenu ,16) )
				
				//				cItemMenu := Iif( nItem == Len(aProds) .And. !Empty( aProds[nItem][CODIGO_PRODUTO] ),"-"+STR0011,"" ) //"Fim"
				//				TerSay(01,35,Padr(cItemMenu,5))
				
				lMovimIt := .T.
				cProduto := aProds[nItem][CODIGO_PRODUTO]
				cOpcaoEx := TerInkey(0) //Registro a tecla selecionada
			ElseIf cTipoMicro == "2"
				cItemMenu := STR0007 + AllTrim(Str( nItem )) + " " + aProds[nItem][CODIGO_PRODUTO] + "-" + aProds[nItem][DESCRICAO_PRODUTO] // "Item:"
				TerSay(00,00, Padr( cItemMenu ,40) )
				
				cItemMenu := STR0010 + Space(1) + Alltrim(Str(aProds[nItem][QUANTIDADE_PRODUTO], 12, 2)) + Space(2) + STR0012 + AllTrim(Transform(aProds[nItem][PRECO_UNITARIO_PRODUTO]+If(cPaisLoc<>"BRA",aProds[nItem][VALOR_IMPOSTO_PRODUTO],0),PesqPict("SL1","L1_VLRTOT"))) //"Qtde:" // "Val. Unit: "
				TerSay(01,00, Padr( cItemMenu ,34) )
				
				cItemMenu := Iif( nItem == Len(aProds) .And. !Empty( aProds[nItem][CODIGO_PRODUTO] ),"-"+STR0011,"" ) //"Fim"
				TerSay(01,35,Padr(cItemMenu,5))
				
				lMovimIt := .T.
				cProduto := aProds[nItem][CODIGO_PRODUTO]
				cOpcaoEx := TerInkey(0) //Registro a tecla selecionada
			EndIf
		EndIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o registro foi movimentado e teclado "," , indica que³
		//³o usuario optou por excluir o produto                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If ( lMovimIt ) .And. ( Trim(Upper( cOpcaoEx )) == "," )
			TerCls()
			TerCBuffer()
			
			If cTipoMicro == "1"
				TerSay(00,00,Padr(STR0040,16)) //"Excluir o Item?"
				TerSay(01,00,Padr(STR0039,16)) //"(1=S/2=N):"
			ElseIf cTipoMicro == "2"
				TerSay(00,00,Padr(STR0013,40)) //"Excluir o Item? (S/N): "
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Loop que controla o Valor digitado pelo usuario e o monitor do MicroTerminal ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do While !(Trim(Upper( cOpcaoEx )) $ ( cOpcaoS + cOpcaoN ))
				cOpcaoEx := Trim(Upper( TerInkey(0) ))
				TerIsQuit()
			EndDo
			
			TerIsQuit()
			
			If Trim(Upper( cOpcaoEx )) == cOpcaoS
				aDel(aProds, nItem) 				 //Removo o registro da array, e mando para a ultima posicao como nula
				aSize( aProds, Len( aProds ) - 1 )  //Removo o produto em branco
				                                 
   				//Realiza o recalculo dos impostos...
				If cPaisLoc <> "BRA"                
					aImpsSL1 := {}
					aImpsSL2 := {}         
					nImpVarDisc := 0
					nImpVarIncl := 0    				                        
					nImpTmpDisc := 0
					nImpTmpIncl := 0						

					TerCls()
					TerCBuffer()
					TerSay(00,00,STR0055) //"Aguarde"   
					TerInkey(0.1)         //Tempo necessario para atualizacao da mensagem...
					
					For nX := 1 To Len(aProds)
						TerImpsVar(aProds[nX][TES_PRODUTO],;
						           aProds[nX][QUANTIDADE_PRODUTO],;
						           aProds[nX][PRECO_UNITARIO_PRODUTO],;
						           aProds[nX][PRECO_UNITARIO_PRODUTO]*aProds[nX][QUANTIDADE_PRODUTO],,;
						           @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
						           
						MaFisEnd()
					Next nX
				EndIf
									
				lExcluiu  := .T.
				nItem := IIf( nItem == 1,2,nItem )  //Se for o 1 item a ser removido, mover a posicao
			EndIf
		EndIf
		
	Else
		cProduto := Space( nTamB1 )
		If cTipoMicro == "1"
			TerSay(00,00,STR0009 + Space(1)) //"Produto:"
			TerGetRead(01,00,@cProduto,"XXXXXXXXXXXXXXX@", {|| !Empty(cProduto) })
		ElseIf cTipoMicro == "2"
			TerSay(00,00,STR0009 + Space(1)) //"Produto:"
			TerGetRead(00,Len(STR0009)+1,@cProduto,"XXXXXXXXXXXXXXX@", {|| !Empty(cProduto) })
		EndIf
	EndIf
	
	If TerEsc() .Or. lExcluiu
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for Pre-Venda, remover um item e executar o Loop para simular PGUP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPVenda
			If ( Len(aProds) == nItem ) .And. ( Empty(aProds[nItem][CODIGO_PRODUTO]) )
				aSize( aProds, Len( aProds ) - 1 ) //Subtrair 1 item do produto, pois nao foi inserido.
			EndIf
			nItem -= 1
			Loop
		EndIf
		Return
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A Rotina sera executada caso o item for maior que 1 e for o ultimo item, dai ele ³
		//³vai pra proxima pergunta															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( cProduto )
			nItem += 1
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao que faz o tratamento do codigo do produto digitado                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TerCodProd(cFilSB1,cFilSLK,@cProduto)
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	If dbSeek( cFilSB1 + cProduto )
		If !lPVenda
			dbSelectArea("SB2")
			dbSetOrder(1)
			dbSeek( cFilSB2 + cProduto )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para consulta do produto, somo todo estoque do produto para exibicao na tela     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do While ( !Eof() ) .And. ( SB2->B2_FILIAL + SB2->B2_COD == cFilSB2 + cProduto )
				nQtde += B2_QATU
				dbSkip()
			EndDo
		EndIf
		
		dbSelectArea("SB0")
		dbSetOrder(1)
		dbSeek( cFilSB0 + cProduto )
		
		If lPVenda
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o produto digitado nao consta no Array, solicito as demais informacoes        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Empty( aProds[nItem][CODIGO_PRODUTO] )
			    If SB0->&("B0_PRV"+cTabPad) == 0
		           If cTipoMicro == "1"
		              TerCls()
			          cMensagem := Padr(STR0057,16) //"Produto sem "
			          TerSay( 00, 00, cMensagem )			
			          cMensagem := Padr(STR0058,16) //"preco de venda!"			
			          TerSay( 01, 00, cMensagem )
		           ElseIf cTipoMicro == "2"
			           cMensagem := Padr(STR0059,40) //"Produto sem preco de venda!"			
			           TerSay( 01, 00, cMensagem )
		           EndIf
		           TerInkey(0)		
			       If Len( aProds ) == 1
				      aProds := {}
			       Else
				      aSize( aProds, Len( aProds ) - 1 ) //Subtrair 1 item do produto, pois nao foi inserido.
			       EndIf		
		           TerIsQuit()
			       Loop
			    EndIf
				//Calculo o Imposto para informa o valor de venda correto...
				If cPaisLoc <> "BRA"
					TerCls()     
					TerCBuffer()
					TerSay(00,00,STR0055) //"Aguarde"   
					TerInkey(0.1)         //Tempo necessario para atualizacao da mensagem...
				
					TerImpsVar(IIf(Empty(RetFldProd(SB1->B1_COD,"B1_TS")),GetMv("MV_TESSAI"), RetFldProd(SB1->B1_COD,"B1_TS") ),;
					           1,;
					           SB0->&("B0_PRV"+cTabPad),;
					           SB0->&("B0_PRV"+cTabPad),;
					           .F.,;
					           @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
				EndIf

				TerCls()
				If cTipoMicro == "1"
					TerSay( 00, 00, Padr( SB1->B1_DESC,16 ) )
				ElseIf cTipoMicro == "2"
					TerSay( 00, 00, Padr( SB1->B1_COD + " - " + SB1->B1_DESC,40 ) )
				EndIf
	
				If cTipoMicro == "1"
					cMensagem := Alltrim(cSimbMoed) + Alltrim(Str(SB0->&("B0_PRV"+cTabPad)+If(cPaisLoc<>"BRA",nImpTmpDisc,0),14,2)+"-")
					TerSay(01,00,Padr(cMensagem,16))
					TerGetRead(01,Len(cMensagem)+1,@nQtde,"9999.99", {|| ( nQtde <> 0 .Or. TerEsc() ) } )
				ElseIf cTipoMicro == "2"
					cMensagem := Padr( cSimbMoed + Str(SB0->&("B0_PRV"+cTabPad)+If(cPaisLoc<>"BRA",nImpTmpDisc,0),14,2),40)
					TerSay(01,00,cMensagem)
					TerSay(01,21,STR0010) //"Qtde:"
					TerGetRead(01,21+Len(STR0010)+1,@nQtde,"9999.99", {|| ( nQtde <> 0 .Or. TerEsc() ) } )
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso teclou Esc no Codigo do Produto, sair da funcao			     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !TerEsc()
					aProds[nItem][CODIGO_PRODUTO]         := SB1->B1_COD
					aProds[nItem][DESCRICAO_PRODUTO]      := SB1->B1_DESC
					aProds[nItem][PRECO_UNITARIO_PRODUTO] := SB0->&("B0_PRV"+cTabPad)
					aProds[nItem][QUANTIDADE_PRODUTO]     := nQtde
					aProds[nItem][VALOR_DESCONTO_PRODUTO] := 0
					aProds[nItem][TES_PRODUTO]            := IIf(Empty(RetFldProd(SB1->B1_COD,"B1_TS")), GetMv("MV_TESSAI"), RetFldProd(SB1->B1_COD,"B1_TS") )
					aProds[nItem][TABELA_PADRAO_PRODUTO]  := cTabPad
					aProds[nItem][VALOR_ACRESCIMO_PRODUTO]:= 0 
					aProds[nItem][VALOR_IMPOSTO_PRODUTO]  := nImpTmpDisc

					//Executa a rotina de calculo de impostos variaveis...						
					If cPaisLoc <> "BRA"
						TerCls()
						TerCBuffer()
						TerSay(00,00,STR0056) //"Registrando..."   
						TerInkey(0.1)         //Tempo necessario para atualizacao da mensagem...
					
						TerImpsVar(aProds[nItem][TES_PRODUTO],;
						           aProds[nItem][QUANTIDADE_PRODUTO],;
						           aProds[nItem][PRECO_UNITARIO_PRODUTO],;
						           aProds[nItem][PRECO_UNITARIO_PRODUTO]*aProds[nItem][QUANTIDADE_PRODUTO],;
						           lPVenda,;
						           @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
				
						MaFisEnd()						           
					EndIf

					nItem += 1                                 
				Else
					nItem -= 1
				EndIf
			Else
				If TerEsc() .And. lPVenda
					nItem -= 1
				Elseif lPVenda
					nItem += 1
				EndIf
			EndIf
		Else
			//Calculo o Imposto para informa o valor de venda correto...
			If cPaisLoc <> "BRA"
				TerCls() 
				TerCBuffer()
				TerSay(00,00,STR0055) //"Aguarde"   
				TerInkey(0.1)         //Tempo necessario para atualizacao da mensagem...
			
				TerImpsVar(IIf(Empty(RetFldProd(SB1->B1_COD,"B1_TS")),GetMv("MV_TESSAI"), RetFldProd(SB1->B1_COD,"B1_TS") ),;
				           1,;
				           SB0->&("B0_PRV"+cTabPad),;
				           SB0->&("B0_PRV"+cTabPad),;
				           .F.,;
				           @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
				           
				MaFisEnd()
			EndIf

			TerCls()
			If cTipoMicro == "1"
				TerSay( 00, 00, Padr( SB1->B1_DESC,16 ) )
			ElseIf cTipoMicro == "2"
				TerSay( 00, 00, Padr( SB1->B1_COD + " - " + SB1->B1_DESC,40 ) )
			EndIf

			If cTipoMicro == "1"
				cMensagem := Alltrim(cSimbMoed) + Alltrim(Str(SB0->&("B0_PRV"+cTabPad)+If(cPaisLoc<>"BRA",nImpTmpDisc,0),14,2) ) 
				cMensagem += "-"+ Alltrim(Str(nQtde, 12, 2))
				TerSay(01,00,Padr(cMensagem,16))
			ElseIf cTipoMicro == "2"
				cMensagem := Padr( cSimbMoed + Str(SB0->&("B0_PRV"+cTabPad)+If(cPaisLoc<>"BRA",nImpTmpDisc,0),14,2),20 )
				cMensagem += Padr( STR0010 + Str(nQtde, 12, 2),20 ) //"Qtde:"
				TerSay(01,00,cMensagem)
			EndIf
			TerInkey(0)
			TerIsQuit()
		EndIf
		
		//Zera o valor dos impostos por se tratar somente de uma consulta...           
		If cPaisLoc <> "BRA"
			nImpTmpDisc := 0
			nImpTmpIncl := 0
		EndIf
	Else
		If cTipoMicro == "1"
			TerCls()
			TerSay( 00, 00, Padr(STR0042,16) ) //"Produto nao"
			TerSay( 01, 00, Padr(STR0043,16) ) //"cadastrado"
		ElseIf cTipoMicro == "2"
			cMensagem := STR0014 //"Produto nao cadastrado"
			TerSay( 01, 00, Padr(cMensagem,40) )
		EndIf
		TerInkey(0)
		
		If lPVenda
			If Len( aProds ) == 1
				aProds := {}
			Else
				aSize( aProds, Len( aProds ) - 1 ) //Subtrair 1 item do produto, pois nao foi inserido.
			EndIf
		EndIF
		
		TerIsQuit()
	EndIf
EndDo

If lPVenda
	lPasAnt := .F.
	lPasSeg := .T.
Else
	lPasAtu := .T.
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerDescTotºAutor  ³Fernando Salvatori  º Data ³  13/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que solicita o desconto do produto                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TerDescTotal(lPasAnt,lPasAtu,lPasSeg,aProds,nDescTotal,aImpsSL1,aImpsSL2,nImpVarDisc,nImpVarIncl,nImpTmpDisc,nImpTmpIncl,nDescPer)
Local nValorTotal := 0  //Valor Total da venda
Local nValTotAux  := 0  //Backup do valor total.
Local nValIPI     := 0  //Valor do IPI
Local nImpDiscAux := nImpVarDisc       //Backup do valor dos impostos discriminados
Local nImpInclAux := nImpVarIncl       //Backup do valor dos impostos incluidos
Local nDecs       := MsDecimais(1)
Local nValorBase  := 0            
Local nColuna     := IIf(cPaisLoc=="BRA",21,0)
Local aImpsSL1Bkp := aClone(aImpsSL1)  //Backup do array de impostos aImpsSL1
Local aImpsSL2Bkp := aClone(aImpsSL2)  //Backup do array de impostos aImpsSL2

lPasAnt   := .T.
lPasAtu   := .F.
lPasSeg   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faco a soma dos produtos com IPI                              	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval( aProds,    { |y| nValorTotal += Round(y[PRECO_UNITARIO_PRODUTO] * y[QUANTIDADE_PRODUTO],nDecs) + y[VALOR_IPI_PRODUTO] } )

nValorBase  := nValorTotal //Valor sem os impostos que serah base para o desconto no total     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somo ao total o valor dos impostos discriminados                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	nValorTotal += nImpVarDisc
EndIf

nDescTotal  := 0

//Registro na var aux, o valor total
nValTotAux := nValorTotal

Do While .T.
	
	TerCls()
	TerCBuffer()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra o valor total da venda   								     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoMicro == "1"
		TerSay(00,00,Padr(STR0015 + Alltrim(Transform( nValorTotal,PesqPict("SL1","L1_VLRTOT"))),20 ) ) //"Total:"
		If cPaisLoc == "BRA"
			TerSay(01,00,Padr(STR0017 + Alltrim(Transform( nValIpi,PesqPict("SL1","L1_VLRTOT"))), 20)) //"Total IPI:"
		EndIf
		TerInkey(0)
		If !TerEsc() 
		    If nDescTotal > 0  //O desconto jah foi digitado e deve sair do loop
		      Exit             
		    EndIf
		    
			TerCls()
			TerCBuffer()

			TerSay(00,00,Padr(STR0016 + Alltrim(Transform( nValTotAux,PesqPict("SL1","L1_VLRTOT"))),20 ) ) //"V.Base:"
			TerSay(01,00,STR0060) //"Desc%:"
			TerGetRead(01,Len(STR0060)+1,@nDescPer,"99.99@", {|| ( nDescPer >= 0 ) } )
			
			//Nao deve digitar desconto em valor caso tenha informado desconto em %
			If nDescPer == 0						
			   TerSay(01,00,STR0054) //"Desc: "
			   TerGetRead(01,Len(STR0054)+1,@nDescTotal,"999999.99@", {|| ( nDescTotal >= 0 ) .And. ( nDescTotal <= nValTotAux ) } )
			Else
			   //Informado o desconto em %, calcula o valor correspondente em valor
			   nDescTotal  := Round((nValorBase*nDescPer)/100,nDecs)   
			EndIf   
		EndIf
	ElseIf cTipoMicro == "2"
		TerSay(00,00,Padr(STR0015 + Alltrim(Transform( nValorTotal,PesqPict("SL1","L1_VLRTOT"))),20 ) ) //"Total:"				
		TerInkey(0)		
		If !TerEsc() 
		   If nDescTotal > 0  //O desconto jah foi digitado e deve sair do loop
		      Exit             
		   EndIf		    				
		   
		   TerSay(00,21,Padr(STR0016 + Alltrim(Transform( nValTotAux,PesqPict("SL1","L1_VLRTOT"))),20 ) ) //"V.Base:"
		   If cPaisLoc == "BRA"
			  TerSay(01,00,Padr(STR0017 + Alltrim(Transform( nValIpi,PesqPict("SL1","L1_VLRTOT"))), 20)) //"Total IPI:"
		   EndIf
		   TerSay(01,nColuna,STR0063) //"Desc(%):"
		   TerGetRead(01,nColuna+Len(STR0063)+1,@nDescPer,"99.99@", {|| ( nDescPer >= 0 ) } )
			
		   //Nao deve digitar desconto em valor caso tenha informado desconto em %
		   If nDescPer == 0								
		      TerSay(01,nColuna,STR0018) //"Desc:   "
		      TerGetRead(01,nColuna+Len(STR0018)+1,@nDescTotal,"999999.99@", {|| ( nDescTotal >= 0 ) .And. ( nDescTotal <= nValTotAux ) } )
		   Else 
		      //Informado o desconto em %, calcula o valor correspondente em valor
		      nDescTotal  := Round((nValorBase*nDescPer)/100,nDecs)   		
		   EndIf   
		EndIf   
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Teclou Esc, sai da funcao e retorna ao passo anterior			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TerEsc()
		If nDescTotal > 0 .Or. nDescPer > 0
			nValorTotal := nValTotAux
			nDescTotal  := 000000.00
			nDescPer    := 00.00
			If cPaisLoc <> "BRA"
				aImpsSL1 := aClone(aImpsSL1Bkp)
				aImpsSL2 := aClone(aImpsSL2Bkp)
				nImpVarDisc := nImpDiscAux
				nImpVarIncl := nImpInclAux
			EndIf
			Loop         
		EndIF
		Return
	EndIf
	
	If cPaisLoc <> "BRA"
		If ((nValorTotal - nImpVarDisc) + nDescTotal + nImpDiscAux ) == nValTotAux
			Exit
		Else
			//Retorno os valores originais pois o desconto pode estar sendo
			//recalculado...
			aImpsSL1 := aClone(aImpsSL1Bkp)
			aImpsSL2 := aClone(aImpsSL2Bkp)
			nImpVarDisc := nImpDiscAux
			nImpVarIncl := nImpInclAux
		EndIf
	Else
		If ( nValorTotal + nDescTotal ) == nValTotAux
			Exit
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o desconto for zerado, retorno o valor original, caso contrario, efetuo o desconto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nDescTotal == 0
		nValorTotal := nValTotAux
	Else
		//Executa rotina para calculo do desconto e recalculo dos impostos variaveis.
		If cPaisLoc <> "BRA"                      
			TerCls()
			TerCBuffer()
			TerSay(00,00,STR0055) //"Aguarde"   
			TerInkey(0.1)              //Tempo necessario para atualizacao da mensagem...
			nValorTotal := (nValTotAux - nImpVarDisc) - nDescTotal
			TerDescLoc(@aProds,nValTotAux-nImpVarDisc,nDescTotal,@nValorTotal,;
			           @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)			
		Else
			nValorTotal := nValTotAux - nDescTotal
		EndIf
	EndIF
	
EndDo

lPasAnt   := .F.
lPasAtu   := .F.
lPasSeg   := .T.

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerCondPg ºAutor  ³Fernando Salvatori  º Data ³  12/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que solicita o codigo da condicao de Pagamento      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TerCondPg(lPasAnt,lPasAtu,lPasSeg,aProds,cCodCpg,aParcelas,nDescTotal,;
                          aImpsSL1,aImpsSL2,nImpVarDisc,nImpVarIncl,nImpTmpDisc,nImpTmpIncl)
Local cMensagem   := ""  						//Mensagem do Programa
Local cFilSE4     := SE4->( xFilial("SE4") )	//Filial Cadastro de Clientes
Local cOpcao      := ""  						//Opcao para exibir parcelas
Local nX          := 0  					    //Var Auxiliar
Local nValorTotal := 0 							//Valor total da venda
Local nDecs       := MsDecimais(1)

lPasAtu   := .F.
lPasAnt   := .T.
lPasSeg   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faco a soma dos produtos             							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval( aProds,    { |y| nValorTotal += Round(y[PRECO_UNITARIO_PRODUTO] * y[QUANTIDADE_PRODUTO],nDecs) + y[VALOR_IPI_PRODUTO] } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetuo o desconto                    							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValorTotal -= nDescTotal

Do While .T.
	
	cCodCpg   := Space( TamSX3( "E4_CODIGO" )[1] )
	cOpcao    := ""
	aParcelas := {}
	
	TerCls()
	TerCBuffer()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Solicita o codigo da Condicao de Pagamento          			     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoMicro == "1"
		TerSay(00,00, STR0019 + Space(1)) //"Cond. Pagamento:"
		TerGetRead(01,00,@cCodCpg,"XXX@", {|| !Empty(cCodCpg) } )
	ElseIf cTipoMicro == "2"
//		TerSay(00,00,"Sub-Total:"+Transform(nValorTotal,PesqPict("SL1","L1_VLRTOT")))
		TerSay(00,00, STR0019 + Space(1)) //"Cond. Pagamento:"
		TerGetRead(00,Len(STR0019)+1,@cCodCpg,"XXX@", {|| !Empty(cCodCpg) } )
	EndIf
	
	If TerEsc()
		Return
	EndIf
	
	dbSelectArea("SE4")
	dbSetOrder(1)
	
	If dbSeek( cFilSE4 + cCodCpg )
		If cTipoMicro == "1"
			cMensagem := Padr( E4_DESCRI,16 )
			TerSay( 01, 00, cMensagem )
		ElseIf cTipoMicro == "2"
			cMensagem := Padr( E4_CODIGO + " - " + E4_DESCRI,20 ) + Padr( STR0020 ,20) //"Exibe parcelas?(S/N):"
			TerSay( 01, 00, cMensagem )
		EndIf
		
		cOpcao := Trim(Upper( TerInkey(0) ))
		
		//Se o usuário teclou Esc, perguntar novamente
		If TerEsc()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula parcelas com desconto	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !MontParc1(nValorTotal,SE4->E4_CODIGO,@aParcelas,@aProds,@nDescTotal,;
		              @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
			Return
		EndIF
		
		TerCls()
		TerCBuffer()
		
		If cOpcao == cOpcaoS .And. cTipoMicro <> "1"
			For nX := 1 to Len( aParcelas )
				
				cMensagem := DtoC( aParcelas[nX][DATA_PARCELAS] ) + "  "
				cMensagem += aParcelas[nX][FORMA_PAGTO_PARCELAS] + "  "
				cMensagem += Alltrim(Transform(aParcelas[nX][VALOR_PARCELAS],PesqPict("SL1","L1_VLRTOT")))
				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Controle para identificar ao usuario, quando estah na proxima parcela³
				//³ou no seu final                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( nX % 2 ) == 0 .Or. nX == Len( aParcelas )
					If nX <> Len( aParcelas )
						cMensagem += Space(1) + STR0021 //"Prox."
					Else
						cMensagem += Space(1) + STR0022 //"Fim"
					EndIf
				EndIf
				
				
				TerSay(IIf( ( nX % 2 ) == 1,00,01 ),00,Padr( AllTrim(Str( nX )) + " " +cMensagem,40))
				If ( nX % 2 ) == 0 .Or. nX == Len( aParcelas )
					TerInkey(0)
					If TerEsc()
						Exit
					EndIf
					
					TerCls()
					TerCBuffer()
				EndIF
			Next nX
		EndIf
		
		If TerEsc()
			Loop
		EndIf
		
		Exit
	EndIf
	
	If cTipoMicro == "1"
		TerCls()
		
		cMensagem := STR0044//"Condicao nao"
		TerSay( 00, 00, Padr(cMensagem,16) )
		
		cMensagem := STR0045//"cadastrada."
		TerSay( 01, 00, Padr(cMensagem,16) )
	ElseIf cTipoMicro == "2"
		cMensagem := STR0023 //"Condicao nao cadastrada"
		TerSay( 01, 00, Padr(cMensagem,40) )
	EndIf
	TerInkey(0)
	TerIsQuit()
EndDo

lPasAnt  := .F.
lPasSeg  := .T.

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerGravaOrºAutor  ³Fernando Salvatori  º Data ³  12/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que grava o Orcamento                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MICROTERMINAL                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TerGravaOrc(lPasAnt,lPasAtu,lPasSeg,cNumOrc,aProds,nDescTotal,;
							cCodVend,cCodCpg,aParcelas,aImpsSL1,aImpsSL2,nImpVarDisc,;
							nImpVarIncl,nImpTmpDisc,nImpTmpIncl,nDescPer)
Local lRet        := .F.                      //Retorno da Funcao
Local nI,nX       := 0                        //Var. Auxiliar
Local nValTot     := 0                        //Valor total da Venda
Local nVlRat      := 0                        //Valor rateado
Local nDescNF     := 0						  //Desconto em porcentagem para o campo L1_DESCNF
Local nTmpDescPro := 0                        //Var Auxiliar para rateio do desconto
Local cCliPad     := GetMV("MV_CLIPAD")       //CLiente Padrao
Local cLojaPad    := GetMV("MV_LOJAPAD")      //Loja Padrao
Local cItem       := ""                       //Item da venda
Local cGrava      := ""                       //Verifica o Orcamento
Local cImpCup     := ""                       //Variavel que guarda a informacao do usuario ao informar se
Local nValAcr     := 0                       //Valor do acrescimo
Local nDecs       := MsDecimais(1)           //Qtde de decimais da moeda corrente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

//deseja imprimir cupom fiscal
TerCls()
TerCBuffer()

lPasAnt := .T.
lPasAtu := .F.
lPasSeg := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pergunta se deseja gravar o orcamento para prosseguir com a gravacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoMicro == "1"
	TerSay(00,00,Padr(STR0046,16))//"Confirmar?"
	TerSay(01,00,Padr(STR0039,16))//"(1=S/2=N):"
ElseIf cTipoMicro == "2"
	TerSay(00,00,STR0024) //"Confirma operacao ? (S/N):"
EndIf

Do While !(Trim(Upper( cGrava )) $ ( cOpcaoS + cOpcaoN ))
	cGrava := TerInkey(0)
	If TerEsc()
		Return(lRet)
	EndIF
	TerIsQuit()
EndDo

If Trim(Upper( cGrava )) == cOpcaoS
	
	//Pego o total da venda 
	aEval( aProds,    { |y| nValTot += Round(y[PRECO_UNITARIO_PRODUTO] * y[QUANTIDADE_PRODUTO],nDecs) } )
	
	dbSelectArea("SL1")
	dbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o numero do orcamento for digitado inicialmente				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cNumOrc )
		If dbSeek( xFilial( "SL1" ) + cNumOrc )
			
			Do While .T.
				TerCls()
				TerCBuffer()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Solicita novamente o codigo do orcamento							   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cTipoMicro == "1"
					TerSay( 00,00,Padr( STR0041 ,16) )//"Numero ja existe"
					TerSay( 01,00,Padr( STR0047 ,16) )//"Orc:"
					cNumOrc := "      "
					TerGetRead( 01,Len(STR0047)+1,@cNumOrc,"XXXXXX@", {|| !Empty( cNumOrc ) } )
				ElseIf cTipoMicro == "2"
					TerSay( 00,00,Padr( STR0025 + " " + cNumOrc + " " + STR0026 + " " ,40) ) //"Orcamento" + "foi utilizado por outra"
					TerSay( 01,00,STR0027  ) //"estacao, reentre com o codigo:"
					cNumOrc := "      "
					TerGetRead( 01,Len(STR0027)+1,@cNumOrc,"XXXXXX@", {|| !Empty( cNumOrc ) } )
				EndIf
				
				If Len(Trim( cNumOrc )) < 6 .And. !TerEsc()
					Loop
				ElseIf TerEsc()
					Return( Nil )
				EndIf
				
				If !dbSeek( xFilial( "SL1" ) + cNumOrc )
					Exit
				EndIf
			EndDo
		EndIf
	Else
		
		Do While .T.
			cNumOrc := GetSxeNum("SL1","L1_NUM")
			
			If __lSx8
				ConfirmSx8()
			EndIf
			
			If !dbSeek( xFilial( "SL1" ) + cNumOrc )
				Exit
			EndIf
		EndDo
	EndIf
	
	TerCls()
	TerCBuffer()
	
	If cTipoMicro == "1"
		TerSay(00,00,STR0048)//"Aguarde, gravando"
		TerSay(01,00,STR0049)//"Orcamento..."
	ElseIf cTipoMicro == "2"
		TerSay(00,00,STR0028) //"Aguarde, gravando orcamento..."
	EndIf
	
	TerInkey(0.1) //Tempo suficiente para atualizacao da mensagem acima
	
	SA1->( dbSetOrder(1) )
	SA1->( dbSeek(xFilial("SA1") + cCliPad + cLojaPad ) )
	
	SE4->( dbSetOrder(1) )
	SE4->( dbSeek( xFilial("SE4") + cCodCpg ) )

	
	//Caso o desconto informado seja em valor, fazer o calculo de porcentagem para 
	//gravar o campo L1_DESCNF
	If nDescPer > 0
	   nDescNF := nDescPer
	Else   
	   nDescNF := Round( (nDescTotal * 100) / nValTot, nDecs )
	EndIf   
	
	Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o Header de or‡amentos - SL1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SL1->(RecLock("SL1", .T.))
	
	SL1->L1_FILIAL  := xFilial("SL1")
	SL1->L1_CLIENTE := cCliPad
	SL1->L1_LOJA    := cLojaPad
	SL1->L1_NUM     := cNumOrc
	SL1->L1_CONDPG  := cCodCpg
	SL1->L1_VEND    := cCodVend
	SL1->L1_TIPOCLI := SA1->A1_TIPO
	SL1->L1_DESCONT := nDescTotal
	SL1->L1_DESCNF  := nDescNF
	SL1->L1_EMISSAO := dDataBase
	SL1->L1_DTLIM   := dDataBase
	SL1->L1_IMPRIME := "1S" //Selecionara a opcao de Cupom fiscal no momento da finalizacao da venda
	SL1->L1_JUROS   := SE4->E4_ACRSFIN
	SL1->L1_TIPO    := "V"
	SL1->L1_HORA    := Time()	
	If cPaisLoc != "BRA"
	   SL1->L1_MOEDA   := 1
	   SL1->L1_TXMOEDA := 0	
	EndIf   
		
	SL1->( dbCommit() )
	SL1->( MsUnlock() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houve desconto no total, faco o rateio |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cPaisLoc == "BRA"
		nTmpDescPro := 0
		For nX := 1 to Len( aProds )
			nVlRat := ( aProds[nX][PRECO_UNITARIO_PRODUTO] * aProds[nX][QUANTIDADE_PRODUTO] )
			nVlRat := NoRound((nVlRat / nValTot ) * 100,2)
			aProds[nX][VALOR_DESCONTO_PRODUTO] := NoRound( (nDescTotal * nVlRat ) / 100 ,2)
			nTmpDescPro += aProds[nX][VALOR_DESCONTO_PRODUTO]
		Next nX
			
		If nTmpDescPro < nDescTotal
			Do While nTmpDescPro <> nDescTotal
				For nX := 1 to Len( aProds )
					aProds[nX][VALOR_DESCONTO_PRODUTO] += (1/(10^2))
					nTmpDescPro += (1/(10^2))
					If nTmpDescPro == nDescTotal
						Exit
					EndIf
				Next nX
			EndDo
		EndIf
	EndIf
	
	cItem := Replicate("0",TamSX3("L2_ITEM")[1])
	
	For nX := 1 To Len( aProds )
		
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek(xFilial("SB1")+aProds[nX][CODIGO_PRODUTO]) )
		
		SF4->( dbSetOrder(1) )
		SF4->( dbSeek(xFilial("SF4")+aProds[nX][TES_PRODUTO]) )
		
		SL2->(RecLock("SL2", .T.))
		
		SL2->L2_FILIAL  := xFilial("SL2")
		SL2->L2_NUM     := cNumOrc
		SL2->L2_PRODUTO := aProds[nX][CODIGO_PRODUTO]
		SL2->L2_DESCRI  := SB1->B1_DESC
		cItem           := SomaIt(cItem)
		SL2->L2_ITEM    := cItem
		SL2->L2_TABELA  := aProds[nX][TABELA_PADRAO_PRODUTO]
		SL2->L2_QUANT   := aProds[nX][QUANTIDADE_PRODUTO]
		SL2->L2_VRUNIT  := aProds[nX][PRECO_UNITARIO_PRODUTO] - (aProds[nX][VALOR_DESCONTO_PRODUTO]/aProds[nX][QUANTIDADE_PRODUTO])
		SL2->L2_VLRITEM := Round((SL2->L2_VRUNIT * SL2->L2_QUANT), nDecs) //Decimais..analisar configuracao
		SL2->L2_VALDESC := 0
		SL2->L2_DESCPRO := aProds[nX][VALOR_DESCONTO_PRODUTO]
		SL2->L2_TES     := aProds[nX][TES_PRODUTO]
		SL2->L2_CF      := SF4->F4_CF
		SL2->L2_EMISSAO := dDataBase
		SL2->L2_UM      := SB1->B1_UM
		SL2->L2_LOCAL   := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
		SL2->L2_PRCTAB  := aProds[nX][PRECO_UNITARIO_PRODUTO] //Verificar no LOJA010D o Proc.
		SL2->L2_VALIPI  := aProds[nX][VALOR_IPI_PRODUTO]
		If SL2->( FieldPos("L2_ITEMSD1")) > 0
			SL2->L2_ITEMSD1 := "000000"
		EndIf		
	    //Atualiza os dados referentes aos impostos variaveis no arquivo SL2...
		If cPaisLoc <> "BRA"
			SL2->L2_VLRITEM := Round(((aProds[nX][QUANTIDADE_PRODUTO] * aProds[nX][PRECO_UNITARIO_PRODUTO])-aProds[nX][VALOR_DESCONTO_PRODUTO])+aProds[nX][VALOR_ACRESCIMO_PRODUTO],nDecs)
			SL2->L2_VRUNIT  := Round(SL2->L2_VLRITEM / aProds[nX][QUANTIDADE_PRODUTO],nDecs+1)
			
			For nI := 1 To Len(aImpsSL2[nX][3])
				//Valor do Imposto
				nPosCpo := SL2->(FieldPos(aImpsSL2[nX][3][nI][6]))
				SL2->(FieldPut(nPosCpo, aImpsSL2[nX][3][nI][4]))
			                    
				//Base do Imposto		                                          
				nPosCpo := SL2->(FieldPos(aImpsSL2[nX][3][nI][7]))
				SL2->(FieldPut(nPosCpo, aImpsSL2[nX][3][nI][3]))
				
				//Aliquota do Imposto
				nPosCpo := SL2->(FieldPos("L2_ALQIMP"+SubStr(aImpsSL2[nX][3][nI][7],10,1)))
				SL2->(FieldPut(nPosCpo, aImpsSL2[nX][3][nI][2]))
			Next nI
		EndIf                       		
		
		SL2->( dbCommit() )
		SL2->( msUnlock() )
	Next nX

//	nValAcr := Round((nValTot * SE4->E4_ACRSFIN) / 100,2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando Valor Total da Venda   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SL1->( RecLock( "SL1", .F.) )

    //Atualiza os dados referentes aos impostos variaveis no arquivo SL1...
	If cPaisLoc <> "BRA"
		//Totaliza o acrescimo... 
		aEval(aProds,{|y| nValAcr += y[VALOR_ACRESCIMO_PRODUTO]})

		For nI := 1 To Len(aImpsSL1)
			//Valor do Imposto
			nPosCpo := SL1->(FieldPos(aImpsSL1[nI][2]))
			SL1->(FieldPut(nPosCpo, aImpsSL1[nI][3]))
			                    
			//Base do Imposto		                                          
			nPosCpo := SL1->(FieldPos(aImpsSL1[nI][4]))
			SL1->(FieldPut(nPosCpo, aImpsSL1[nI][5]))
		Next nI
	EndIf                       
	
	SL1->L1_VLRTOT  := nValTot + If(cPaisLoc<>"BRA",nImpVarDisc - nDescTotal + nValAcr,0)
	SL1->L1_VLRLIQ  := nValTot - nDescTotal + If(cPaisLoc<>"BRA",nValAcr,0)
	SL1->L1_VALBRUT := nValTot + If(cPaisLoc<>"BRA",nImpVarDisc - nDescTotal + nValAcr,0)
	SL1->L1_VALMERC := nValTot - nDescTotal + If(cPaisLoc<>"BRA",nValAcr,0)
	
	SL1->( dbCommit() )
	SL1->( MsUnlock() )
	
	For nX := 1 to Len( aParcelas )
		SL4->(RecLock( "SL4", .T. ))
		
		SL4->L4_FILIAL  := xFilial( "SL4" )
		SL4->L4_NUM     := cNumOrc
		SL4->L4_DATA    := aParcelas[nX][1]
		SL4->L4_VALOR   := aParcelas[nX][2]
		SL4->L4_FORMA   := aParcelas[nX][3]
		SL4->L4_TERCEIR := .F.
		If cPaisLoc != "BRA"
		   SL4->L4_MOEDA  := 1
		EndIf   
		
		SL4->(dbCommit())
		SL4->(MsUnlock())
	Next nX
	
	End Transaction
	
	dbCommitAll()
	MsUnlockAll()
	
	TerCls()
	TerCBuffer()

	//Zera os arrays referentes aos impostos variaveis...
	If cPaisLoc <> "BRA"
		aImpsSL1 := {}
		aImpsSL2 := {}
		nImpVarDisc := 0
		nImpVarIncl := 0  
		nImpTmpDisc := 0
		nImpTmpIncl := 0						
	EndIf
	
	If cTipoMicro == "1"
		TerSay(00,00,STR0050 ) //"Gravado!"
		TerSay(01,00,STR0030 + " " + cNumOrc+"...") //"Numero:"
	ElseIf cTipoMicro == "2"
		TerSay(00,00,STR0029 ) //"Orcamento gravado!"
		TerSay(01,00,STR0030 + " " + cNumOrc+"...") //"Numero:"
	EndIf
	TerInkey(2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para impressÆo do cupom ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("LJIMPCUP") )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pergunta se o usuário deseja imprimir o orcamento	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TerCls()
		TerCBuffer()
		
		If cTipoMicro == "1"	
			TerSay( 00,00,Padr(STR0051,16))//"Imprimir?"
			TerSay( 01,00,Padr(STR0039,16))//"(1=S/2=N):"
		ElseIf cTipoMicro == "2"
			TerSay( 00,00,STR0031 )  //"Deseja imprimir o orcamento? (S/N):"
		EndIf
		
		Do While !(Trim(Upper( cImpCup )) $ ( cOpcaoS + cOpcaoN ))
			cImpCup := TerInkey(0)
			TerIsQuit()
		EndDo
		
		If cImpCup == cOpcaoS
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pergunta se o usuário deseja imprimir o orcamento	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TerCls()
			TerCBuffer()
			
			If cTipoMicro == "1"
				TerSay(00,00,STR0052)//"Aguarde"
				TerSay(01,00,STR0053)//"Imprimindo..."
			ElseIf cTipoMicro == "2"
				TerSay(00,00,STR0032) //"Aguarde, imprimindo..."
			EndIf
			
			ExecBlock("LJIMPCUP",.F.,.F.,{cNumOrc,aProds,nDescTotal,cCodVend,cCodCpg})
		Endif
	EndIf
	
Else
	TerCls()
	TerCBuffer()
	
	If cTipoMicro == "1"
		TerSay(00,00,STR0061)  //"Orcamento "	
		TerSay(01,00,STR0062)  //"cancelado"			    	    
	ElseIf cTipoMicro == "2"
		TerSay(00,00,STR0033 ) //"Orcamento cancelado!"
	EndIf                                           
		
	If cPaisLoc <> "BRA"
		aImpsSL1 := {}
		aImpsSL2 := {}
		nImpVarDisc := 0
		nImpVarIncl := 0
		nImpTmpDisc := 0
		nImpTmpIncl := 0						
	EndIf	
	
	TerInkey(5)
EndIf

lPasSeg := .F.
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MontParc1³ Autor ³ F bio Pessoa / Gustavo³ Data ³ 02/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Array com as Parcelas 		    					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Exl1 := .T. ou .F.                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontParc1(nValorBase,cCondPg,aParcelas,aProds,nDesctotal,;
                          aImpsSL1,aImpsSL2,nImpVarDisc,nImpVarIncl,nImpTmpDisc,nImpTmpIncl)
Local j
Local nParcelas := 0
Local nResto	:= 0
Local cForma1	:= 0
Local cForma2	:= 0
Local cForma    := GetMv("MV_FORMPAD")
Local aParc 	:= {}
Local cSimbMoed := GetMV("MV_SIMB1")            //Simbolo da moeda
Local lRet		:= .T.
Local nEntrada, nFinanciado, nTxJuros := 0, nTxDesc := 0
Local nValorDesc:= 0
Local nValorTot := 0                           //Localizacoes

aParcelas := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a Condicao de Pagto escolhida ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SE4" )
dbSeek( xFilial("SE4") + cCondPg )

nEntrada 	:= 0
nFinanciado := 0
nTxJuros 	:= 0

/*//Define se o Acrescimo eh pelo valor Bruto (T) ou pelo Liquido (F)
If !(lAcrBru)
	nValorBase -= nDescTotal
EndIf*/

aParc 		:= Condicao( nValorBase+If(cPaisLoc<>"BRA",nImpVarDisc,0), cCondPg )
nParcelas	:= Len(aParc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o n£mero de parcelas e v lido 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nParcelas == 0
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe acr‚scimo financeiro              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( SE4->E4_ACRSFIN )
	nTxJuros  := SE4->E4_ACRSFIN
ElseIf !Empty( SE4->E4_DESCFIN )
	nTxDesc  := SE4->E4_DESCFIN
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a Forma de pagamento padrÆo                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SE4->E4_FORMA) .And. !(AllTrim(SE4->E4_FORMA) $ (Alltrim(cSimbMoed)+"/CH"))
	SAE->( dbSeek( xFilial() ) )
	While !(SAE->(Eof()))
		If SAE->AE_TIPO == Subs(SE4->E4_FORMA,1,2)
			cForma1 := Subs(SE4->E4_FORMA, 1, 2)
			cForma2 := Subs(SE4->E4_FORMA, 1, 2)
			Exit
		EndIf
		SAE->(dbSkip())
	EndDo
	If SAE->(Eof())
		cForma1 := cForma
		cForma2 := Iif(Upper(cForma) == Alltrim(cSimbMoed),"CH",cForma)
	EndIf
Else
	cForma1 := IIf(Empty(SE4->E4_FORMA),cForma,SubStr(SE4->E4_FORMA,1,2))
	
	If Empty(SE4->E4_FORMA)
		cForma2 := Iif(Upper(cForma) == Alltrim(cSimbMoed),"CH",cForma)
	ElseIf Empty(SubStr(SE4->E4_FORMA,3,2))
		cForma2 := Iif(Upper(SubStr(SE4->E4_FORMA,1,2)) == Alltrim(cSimbMoed),"CH",;
		SubStr(SE4->E4_FORMA,1,2))
	Else
		cForma2 := Iif(Upper(SubStr(SE4->E4_FORMA,3,2)) == Alltrim(cSimbMoed),"CH",;
		SubStr(SE4->E4_FORMA,3,2))
	EndIf
EndIf

If nTxJuros > 0  // Calcula Parcelamento com Juros
	aParc := MontParc2(aParc,Iif(nEntrada>0,.T.,.F.),nValorBase,nTxJuros,nEntrada,@nFinanciado,nParcelas,0,aProds,;
	                   @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
ElseIf nTxDesc > 0
	nValorDesc := ((nValorBase * nTxDesc) / 100)

	//O desconto financeiro eh tratado como um desconto no total da venda, pois
	//existe necessidade de recalculo dos impostos e consequentemente o valor
	//total da venda eh alterado.
	If cPaisLoc <> "BRA"
		nDesctotal+= nValorDesc
		nValorTot := nValorBase - nValorDesc
		TerCls()
		TerSay(00,00,STR0055) //"Aguarde"   
		TerInkey(0.1)         //Tempo necessario para atualizacao da mensagem...

		TerDescLoc(@aProds,nValorBase,nValorDesc,@nValorTot,@aImpsSL1,@aImpsSL2,;
		           @nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
		aParc := Condicao(nValorTot,cCondPg)
		
		TerCls()
		TerCBuffer()
		TerSay(00,00,Padr(STR0015 + Alltrim(Transform(nValorTot,PesqPict("SL1","L1_VLRTOT"))),20 ) ) //"Total:"
		TerInkey(0)
    Else
		For j := 1 to Len(aParc)
			aParc[j][2] -= Round((nValorDesc/Len(aParc)),2)
		Next j
	EndIf
EndIf

For j := 1 To nParcelas
	Aadd(aParcelas,{aParc[j][1],aParc[j][2],Iif(j==1,cForma1,cForma2)})
Next j

For j := 1 To nParcelas
	If aParcelas[j][1] > dDataBase
		nFinanciado += NoRound(aParcelas[j][2])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o tipo estiver dinheiro, coloca para cheque pois    ³
		//³ o pagamento ‚ a prazo								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aParcelas[j][3] == Alltrim(cSimbMoed)
			aParcelas[j][3] := "CH"
		EndIf
	Else
		nEntrada += NoRound(aParcelas[j][2])
	EndIf
Next j

nResto := nValorBase+If(cPaisLoc<>"BRA",nImpVarDisc,0) - ( nFinanciado + nEntrada )

If !nTxJuros > 0 .And. !nTxDesc > 0
	If nResto != 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajuste da £ltima parcela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParcelas[j-1][2] += nResto
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MontParc2 ºAutor  ³F bio Pessoa / Gustavoº Data ³ 02/11/00  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta array com parcelas de acordo com o digitado          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontParc2(aCondicoes,lEntrada,nValorBase,nTxJuros,nEntrada,nFinanciado,nParcelas,nIntervalo,aProds,;
                          aImpsSL1,aImpsSL2,nImpVarDisc,nImpVarIncl,nImpTmpDisc,nImpTmpIncl)
Local j
Local aParc       := {}
Local nValorTotal := 0.00
Local lPrice		:= IIf(GETMV("MV_PRICE")   == "S", .T., .F.)
Local lCalcFin 	:= IIf(GETMV("MV_CALCFIN") == "F", .T., .F.)
Local nI			:= 1
Local nValor, nDivisor, nPrestacao

If SL1->L1_VALBRUT != nValorBase
	If lPrice .and. nTxJuros > 0
		nValor	  := nValorBase
	Else
		//Subtrai os impostos incluidos para o calculo dos juros...
		If cPaisLoc == "BRA"
			If lCalcFin  // Calcula Juros pelo Valor Financiado
				// Verifica Se e Pagamento a Vista, Senao Abate a Entrada....
				nValor	  := Iif(Round(nValorBase,2)=Round(nEntrada,2),nValorBase,Round(nValorBase - nEntrada,2))
				// .. e Calcula Juros sobre Valor Final
				nValor	  := Iif(nTxJuros==0,nValor,Round(nValor+(nValor*nTxJuros/100),2))
				nFinanciado:= nValor
			Else
				// Calcula Juros pelo Montante
				nValor	  := Iif(nTxJuros==0,nValorBase,Round(nValorBase+(nValorBase*nTxJuros/100),2))
				// Verifica Se Calcula Juros Na Entrada
				nEntrada   := Iif(nTxJuros!=0 .And. GetMv("MV_TXVISTA")=="S",Round(nEntrada+(nEntrada*nTxJuros/100),2),nEntrada)
			Endif
		Else           
			TerCls()
			TerCBuffer()
			TerSay(00,00,STR0055) //"Aguarde"   
			TerInkey(0.1)         //Tempo necessario para atualizacao da mensagem...
		
			nValor := nValorBase			
			TerAcrsLoc(@aProds,nTxJuros,@nValor,@aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,;
			           @nImpTmpDisc,@nImpTmpIncl)
		EndIf
	Endif
Else
	nValor := nValorBase
Endif

// Se os Juros sao Pelo Montante Entao Abate, apos descontos, a entrada
If !lCalcFin
	nFinanciado := Round(nValor - nEntrada,2)
EndIf

If nEntrada != 0
	Aadd( aParc, { Iif(nIntervalo!=0 .or. !lEntrada,dDataBase,aCondicoes[1][1]) , Iif(nParcelas==1,nValor,nEntrada) } )
Endif

If !lCalcFin
	// Se Calcula Juros no Montante, entao monta a(s) outra(s) Parcela(s)
	If nEntrada != nValor
		For j:=nI+Iif(lEntrada .and. nParcelas>1,1,0) To nParcelas+Iif(lEntrada .and. nParcelas>1,Iif(nEntrada==0,1,0),Iif(nEntrada==0,0,-1))
			Aadd( aParc, { Iif(nIntervalo==0,aCondicoes[j][1],dDataBase+nIntervalo*(j-Iif(lEntrada .and. nParcelas>1,1,0))) , NoRound(nFinanciado/(nParcelas-Iif(nEntrada==0,0,1)))})
		Next j
	Endif
Else
	// Se Calcula Juros so no Financiamento, Entao Soma-se a Entrada
	// no Valor Financiado e Monta as demais Parcelas
	If nEntrada != (nValor+nEntrada)
		For j:=nI+Iif(lEntrada .and. nParcelas>1,1,0) To nParcelas+Iif(lEntrada .and. nParcelas>1,Iif(nEntrada==0,1,0),Iif(nEntrada==0,0,-1))
			Aadd( aParc, { Iif(nIntervalo==0,aCondicoes[j][1],dDataBase+nIntervalo*(j-Iif(lEntrada .and. nParcelas>1,1,0))) , NoRound(nFinanciado/(nParcelas-Iif(nEntrada==0,0,1)))})
		Next j
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se sera usado a tabela PRICE para	³
//³ calcular o valor das parcelas			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPrice .and. nTxJuros > 0
	nValTaxa := nTxJuros / 100
	nDivisor := (1 + nValTaxa) ** ( nParcelas - IIf(nEntrada>0,1,0) )
	If nTxJuros # 0
		nPrestacao := (nFinanciado * nDivisor) * nValTaxa / (nDivisor - 1)
	Else
		nPrestacao := nFinanciado / nParcelas
	Endif
	nFinanciado := 0
	For j  := IIf(nEntrada > 0 ,2,1) To Len(aParc)
		aParc[j,2]	:= Round(nPrestacao,2)
		nFinanciado += Round(nPrestacao,2)
	Next
Else
	If Len(aParc) > 1   // Nao sendo Pagamento a Vista...
		For j:=1 To Len(aParc)-1
			nValorTotal+=Round(aParc[j][2],2)
		Next j
		
		// Ajusta a Ultima Parcela, conforme Calculo de Juros
		If ! lCalcFin
			// Se Juros no Montante, Ajusta Normal....
			aParc[Len(aParc)][2]:=nValor-nValorTotal
		Else
			// Se Juros no Financiamento, Soma-se a Entrada ao Valor e Ajusta-se...
			aParc[Len(aParc)][2]:=(nValor+nEntrada)-nValorTotal
		EndIf
		
	Else
		// Se For a vista o Valor nao requer reajuste...
		aParc[Len(aParc)][2]:=nValor
	EndIf
EndIf
     
//Exibe o total da venda caso tenha acrescimo na venda...
If cPaisLoc <> "BRA"
	TerCls()
	TerCBuffer()
	TerSay(00,00,Padr(STR0015 + Alltrim(Transform(nValor,PesqPict("SL1","L1_VLRTOT"))),20 ) ) //"Total:"
	TerInkey(0)
EndIf

Return aParc



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerCalcProºAutor  ³Fernando Salvatori  º Data ³  19/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de calculos                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TerCalcPro(aProds)
Local nX   		:= 0                        //Var Auxiliar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faco a soma dos produtos com IPI                              	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( aProds )
	If cPaisLoc == "BRA"
		aProds[nX][VALOR_IPI_PRODUTO] := Lj010Ipi(aProds[nX][PRECO_UNITARIO_PRODUTO],;
		aProds[nX][QUANTIDADE_PRODUTO],;
		0,0,;
		aProds[nX][TES_PRODUTO],;
		nX,aProds[nX][CODIGO_PRODUTO])
	Else                                 
		aProds[nX][VALOR_IPI_PRODUTO] := 0
	EndIf
Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerCodPro ºAutor  ³Fernando Salvatori  º Data ³  22/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz as validacoes do codigo do produto e seu retorno       º±±
±±º          ³ para continuidade do processamento.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TerCodProd(cFilSB1,cFilSLK,cProduto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa por Codigo do Produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea( "SB1" )
dbSetOrder( 1 )
If !dbSeek( cFilSB1 + cProduto )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa por Codigo de Barra  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSetOrder( 5 )
	If !dbSeek( cFilSB1 + cProduto )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa por Codigo de Barra no Cad de Codigo de Barra  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SLK" )
		dbSetOrder( 1 )
		
		If !dbSeek( cFilSLK + cProduto )
			
			If ExistBlock("LJTCODPRO")
				cProduto := ExecBlock("LJTCODPRO",.F.,.F.,{cProduto})
			EndIf
			
		Else
			cProduto := SLK->LK_CODIGO
		EndIf
		
	Else
		cProduto := SB1->B1_COD
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerImpsVar ºAutor  ³Julio Cesar         º Data ³  26/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza o calculo dos impostos variaveis.                   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LJTER01                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TerImpsVar(cTES,nQuant,nVlrUnit,nVlrItem,lPVenda,aImpsSL1,;
                           aImpsSL2,nImpVarDisc,nImpVarIncl,nImpTmpDisc,nImpTmpIncl)

Local cIndImp   := ""
Local cCampoVal := ""
Local cCampoAlq := ""
Local aImposto    := {}
Local nDecs   := MsDecimais(1)
Local nValImp := 0
Local nI      := 0
Local nE      := 0

//Verifica os dados basicos para o calculo do imposto.
//Caso algum dos dados esteja inconsistente o impostos nao eh calculado... 
If Empty(cTes) .Or. ((nQuant == 0) .Or. (nVlrUnit == 0) .Or. (nVlrItem == 0))
	Return Nil
EndIf

If (lPVenda == Nil) .Or. !lPVenda
	MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "S", SA1->A1_TIPO,,, .F., "SBI")
	MaFisAdd(SB1->B1_COD, cTES, nQuant, nVlrUnit, 0, "", "",, 0, 0, 0, 0, nVlrItem, 0, SB1->(RecNo()))		
Else
	If MaFisRet(1,"IT_QUANT") <> nQuant
		MaFisAlt("IT_QUANT",nQuant,1)
	EndIf

	If MaFisRet(1,"IT_VALMERC") <> nVlrItem
		MaFisAlt("IT_VALMERC",nVlrItem,1)
	EndIf   
EndIf  

aImpsInf := TesImpInf(cTES)

If (lPVenda == Nil) .Or. lPVenda
	AAdd(aImpsSL2,{SB1->B1_COD,cTES,{}})
EndIf

For nI := 1 to Len(aImpsInf)                                                 
	If (lPVenda == Nil) .Or. lPVenda
		If (nE := Ascan( aImpsSL1,{|x| x[1] == aImpsInf[nI,1]})) == 0
			AAdd(aImpsSL1,{aImpsInf[nI][1],"L1_"+Substr(aImpsInf[nI][6],4,7),0,"L1_"+Substr(aImpsInf[nI][8],4,7),0,aImpsInf[nI][3],aImpsInf[nI][9]})		    		    
			nE := Len(aImpsSL1)
		EndIf
	EndIf   
	cIndImp   := Substr(aImpsInf[nI][2],10,1)               
	cCampoVal := "IT_VALIV"+cIndImp		    
	cCampoAlq := "IT_ALIQIV"+cIndImp	 
	nValImp   := Round(MaFisRet(1,cCampoVal),nDecs)		       	    		       
	If (lPVenda == Nil) .Or. lPVenda
		TerGeraImp(@aImposto,aImpsInf[nI],nValImp,nQuant,nVlrUnit,1,cIndImp,nDecs)			   
	   	AAdd(aImpsSL2[len(aImpsSL2)][3],aClone(aImposto))
	   	If aImposto[10,Val(Subs(aImposto[5],2,1))] == 1
			nImpVarDisc += nValImp // Total dos Impostos Discriminados
		Else
			nImpVarIncl += nValImp // Total dos Impostos Incluidos
		EndIf
		aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
		aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   
	Else
	   	If aImpsInf[nI][3] == "1"
			nImpTmpDisc += nValImp // Total dos Impostos Discriminados
		Else
			nImpTmpIncl += nValImp // Total dos Impostos Incluidos
		EndIf	
	EndIf
Next nI

Return Nil
		
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerGeraImpºAutor  ³Fernando Machima    º Data ³  01/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o array com os dados dos impostos incidentes em um    º±±
±±º          ³ determinado produto                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LjTer01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TerGeraImp(aImposto,aInfo,nValImp,nQuant,nVlrUnit,nX,cIndImp,nDecs)

Local cCpoVlrItem := ""
Local cCpoBaseIte := ""
Local cCpoVlrCab  := ""
Local cCpoBaseCab := ""
Local cCpoBas     := "IT_BASEIV"+cIndImp	 
Local nValBas     := Round(MaFisRet(nX,cCpoBas),nDecs)		       	    		       

cCpoVlrItem := "L2_"+Subs(aInfo[2],4,7)   //Campo de gravacao do valor do imposto no item
cCpoBaseIte := "L2_"+Subs(aInfo[7],4,7)   //Campo de gravacao da base do imposto no item
cCpoVlrCab  := "L1_"+Subs(aInfo[6],4,7)   //Campo de gravacao do valor do imposto no cabecalho
cCpoBaseCab := "L1_"+Subs(aInfo[8],4,7)   //Campo de gravacao da base do imposto no cabecalho

aImposto := {}                   //Limpa o array para que armazene somente os 
							      //dados do imposto que está sendo calculado

AAdd( aImposto, aInfo[1] )       //Codigo do imposto
AAdd( aImposto, aInfo[9] )       //Aliquota do imposto  
AAdd( aImposto, nValBas )        //Base do Imposto
AAdd( aImposto, nValImp  )                         //Valor do imposto
AAdd( aImposto, aInfo[4] + aInfo[3] + aInfo[5] )  //FC_INCDUPL/FC_INCNOTA/FC_CREDITA
AAdd( aImposto, cCpoVlrItem )
AAdd( aImposto, cCpoBaseIte )
AAdd( aImposto, cCpoVlrCab )
AAdd( aImposto, cCpoBaseCab )
AAdd( aImposto, {1,-1,0} )                
AAdd( aImposto, nQuant )  
AAdd( aImposto, nVlrUnit )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerDescLocºAutor  ³Julio Cesar         º Data ³  26/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rateia o desconto entre os itens da venda e executa a      º±±
±±º          ³ rotina de recalculo dos impostos                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LjTer01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TerDescLoc(aProds,nVlrMerc,nValorDesc,nValorTotal,aImpsSL1,;
                           aImpsSL2,nImpVarDisc,nImpVarIncl,nImpTmpDisc,nImpTmpIncl)
Local nX
Local aProdsTmp := aClone(aProds)
Local nDecs     := MsDecimais(1)
Local nPerVend  := 0
Local nSomPerVen:= 0
Local nDescPro  := 0
Local nVlrDescIt:= 0
Local nVlrTotIT := 0

aImpsSL1 := {}
aImpsSL2 := {}         
nImpVarDisc := 0
nImpVarIncl := 0
For nX := 1 To Len(aProdsTmp)
	//Verifica quanto esse item corresponde no total da venda
    //Nao arredondar para ter maior precisao nos resultados
	nPerVend  := ((aProdsTmp[nX][PRECO_UNITARIO_PRODUTO] * aProdsTmp[nX][QUANTIDADE_PRODUTO]) * 100) / nVlrMerc
	//Realiza esse calculo para evitar que o desconto nao seja dado na
	//sua totalidade
	nSomPerVen+= nPerVend
	If nX == Len(aProdsTmp) .and. nSomPerVen <> 100
		nPerVend += Iif(nSomPerVen < 100,(100-nSomPerVen),-1*(nSomPerVen-100))
	EndIf
	//Calcula a proporcao do desconto	                        
	nDescPro   := Round((nValorDesc * nPerVend) / 100,nDecs)
	nVlrDescIt := nDescPro
	aProds[nX][VALOR_DESCONTO_PRODUTO] := nDescPro
	//Calcula o novo valor unitario considerando o desconto proporcional
	aProdsTmp[nX][PRECO_UNITARIO_PRODUTO] := aProdsTmp[nX][PRECO_UNITARIO_PRODUTO] - (nDescPro / aProdsTmp[nX][QUANTIDADE_PRODUTO])
	//Calcula o novo valor do item
	nVlrTotIT := aProdsTmp[nX][PRECO_UNITARIO_PRODUTO] * aProdsTmp[nX][QUANTIDADE_PRODUTO]
                                                               
	//Executa a funcao para recalcular os impostos...
	TerImpsVar(aProdsTmp[nX][TES_PRODUTO],aProdsTmp[nX][QUANTIDADE_PRODUTO],;
			   aProdsTmp[nX][PRECO_UNITARIO_PRODUTO],nVlrTotIT,,;
			   @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
			   
	MaFisEnd()
Next nX   
//Soma o imposto recalculado...
nValorTotal += nImpVarDisc
                
Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TerAcrsLocºAutor  ³Julio Cesar         º Data ³  26/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rateia o acrescimo entre os itens da venda e executa a     º±±
±±º          ³ rotina de recalculo dos impostos                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LjTer01                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TerAcrsLoc(aProds,nTxJuros,nValorTotal,aImpsSL1,aImpsSL2,nImpVarDisc,;
                           nImpVarIncl,nImpTmpDisc,nImpTmpIncl)
Local nX
Local aProdsTmp := aClone(aProds)
Local nAcrsItem := 0
Local nAcrsTot  := 0
Local nVlrTotIT := 0
Local nDecs     := MsDecimais(1)

aImpsSL1 := {}
aImpsSL2 := {}         
nImpVarDisc := 0
nImpVarIncl := 0
For nX := 1 To Len(aProdsTmp)      
	nVlrTotIT := (aProdsTmp[nX][QUANTIDADE_PRODUTO] * aProdsTmp[nX][PRECO_UNITARIO_PRODUTO]) - aProds[nX][VALOR_DESCONTO_PRODUTO]
	nAcrsItem := NoRound((nVlrTotIT * nTxJuros)/100,nDecs)
	aProds[nX][VALOR_ACRESCIMO_PRODUTO] := nAcrsItem
	nAcrsTot  += nAcrsItem
	nVlrTotIT := Round(nVlrTotIT + nAcrsItem,nDecs)		
	aProdsTmp[nX][PRECO_UNITARIO_PRODUTO] := Round(nVlrTotIT / aProdsTmp[nX][QUANTIDADE_PRODUTO],nDecs+1)

	//Executa a funcao para recalcular os impostos...
	TerImpsVar(aProdsTmp[nX][TES_PRODUTO],aProdsTmp[nX][QUANTIDADE_PRODUTO],;
			   aProdsTmp[nX][PRECO_UNITARIO_PRODUTO],nVlrTotIT,,;
			   @aImpsSL1,@aImpsSL2,@nImpVarDisc,@nImpVarIncl,@nImpTmpDisc,@nImpTmpIncl)
			   
	MaFisEnd()
Next nX                   
//Soma o imposto recalculado e o acrescimo...
nValorTotal += (nImpVarDisc+nAcrsTot)

Return Nil
