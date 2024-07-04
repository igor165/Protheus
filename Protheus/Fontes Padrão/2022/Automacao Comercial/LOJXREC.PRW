#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "LOJXREC.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FILEIO.CH"
#Include "FWBalloon.ch"
                                                                                                                                                                                                                                                                                                                                                                               
#DEFINE TIT_SELE  1			// Posicao logica.
#DEFINE TIT_PREF  2			// Prefixo do titulo.
#DEFINE TIT_NUME  3			// Titulo.
#DEFINE TIT_PARC  4			// Parcela.
#DEFINE TIT_VREA  5			// Vencimento real.
#DEFINE TIT_VALO  6			// Valor.
#DEFINE TIT_MULT  7			// Multa.
#DEFINE TIT_JURO  8			// Juros.
#DEFINE TIT_DESC  9			// Desconto.
#DEFINE TIT_RECE 10			// Recebimento.
#DEFINE TIT_TIPO 11 		// Tipo.
#DEFINE TIT_CONT 12			// Contrato.
#DEFINE TIT_CLIE 13			// Cliente.
#DEFINE TIT_LOJA 14			// Loja.
#DEFINE TIT_FILI 15       	// Filial.
#DEFINE TIT_RECN 16			// Recno.
#DEFINE TIT_ACRS 17			// Acrescimo financeiro.
#DEFINE TIT_CACR 18			// Posicao logica.
#DEFINE TIT_ABAT 19			// Abatimentos.
#DEFINE TIT_VENC 20			// Vencimento original.
#DEFINE TIT_LOCK 21			// Cod de uso do Registro
#DEFINE TIT_MOED 22			// Codigo da moeda do titulo
#DEFINE TIT_INTE 23			// Interes (Juros) - Posicao reservada
#DEFINE TIT_DTBX 24			// Dt. da baixa
#DEFINE TIT_SALD 25			// Saldo do titulo
#DEFINE TIT_VLIQ 26			// Valor Liquido

#DEFINE CRLF chr(13)+chr(10)
#DEFINE _FORMAPGTO	3  		//Posicao do campo Forma de Pgto no array aPgtos(Localizacoes)
#DEFINE PATH "\AUTOCOM\"  //Path dos arquivos que controlam a selecao dos titulos
#DEFINE DIRARQPFX "RECEB"+cEmpAnt+AllTrim(StrTran(cFilAnt, " "))+"_" //Prefixo do diretorio onde sao criados os arquivos que controlam a selecao dos titulos
#DEFINE TEF_SEMCLIENT_DEDICADO	"2"
#DEFINE TEF_COMCLIENT_DEDICADO	"3"
#DEFINE TEF_DISCADO             "4"
#DEFINE TEF_CLISITEF		 	"6"		//Utiliza a DLL CLISITEF
#DEFINE _FORMATEF				"CC;CD" //Formas de pagamento que utilizam operação TEF para validação
#DEFINE _FORMAPGDG				"PD/PX"	//Forma de pagamento considerado Pagamento Digital

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  *** Alteracoes no SX3                                                                                             |
//|  Apagar os campos                                                                                                  |
//|  Estes campos configuram um servidor alternativo para o carregamento de orcamento, que na 8.11 sera por WebService |
//|   LG_ORCSRV, LG_ORCPORT, LG_ORCENV, LG_ORCEMP, LG_ORCFIL                                                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static oSvc
Static aTitulo, oTitulo
Static cMV_LJRECEB
Static oNomeCli                                         	// Objeto do nome do cliente
Static cNomeCli   := ""
Static aTitBxSE5
Static aTitDelSE5
Static cCodCli, oCodCli
Static cLojCli
Static cCPF
Static cCPFTemp
Static cCartao, oCartao
Static cNum
Static cNumRA, oNumRA
Static cPrefixo
Static cTitulo
Static cParcela
Static nTotal, oTotal

Static nMulta, oMulta
Static nJuros, oJuros
Static nDescont, oDescont
Static nValRec, oValRec

Static lFinancComp                      //Controla se o SE1 e SE5 sao compartilhados
Static cOper         := "1"				//Operacao
Static lRecebTit	 := .F.				//Verifica se esta' executando a rotina de Recebimento de titulos
Static aValores      := {}				//Array com os valores para serem mudados
Static nCloneRec	 := 0				//Clone do valor de recebimento
Static aTitVazio	 := {  .F.,;		// 1. Posicao logica.
							"",;		// 2. Prefixo do titulo.
							"",;		// 3. Titulo.
							"",;		// 4. Parcela.
						 	CToD(""),;	// 5. Vencimento real.
						 	0,;			// 6. Valor.
						 	0,;			// 7. Multa.
						 	0,;			// 8. Juros.
						 	0,;			// 9. Desconto.
						 	0,;			// 10. Recebimento.
						 	"",;		// 11. Tipo.
						 	"",;		// 12. Contrato.
						 	"",;		// 13. Cliente.
						 	"",;		// 14. Loja.
						 	"",;		// 15. Filial.
						 	0,;			// 16. RecNo.
						 	0,;			// 17. Acrescimo financeiro.
						 	.F.,;		// 18. Posicao logica.
						 	0,;			// 19. Abatimento.
						 	CToD(""),;	// 20. Vencimento original.
						 	"",;		// 21. Chave do registro
						 	1 ,;		// 22. Codigo da moeda do titulo
						 	0 ,;		// 23. Interes (Juros) - Posicao reservada
						 	CToD(""),;	// 24. Data da Baixa
						 	0 ,;		// 25. Saldo do titulo
						 	0	}		// 26. Valor Liquido (ultimo valor baixado)

Static aDadosTef	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis usada para efetuar a analise de credito apos o recebimento caso o cartao do cliente que ³
//³realizou o pagamento esteja com SITUA = BOQUEADO                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static cCCodcli	  := ""														// Codigo do cliente
Static cCLojCli   := ""														// Loja
Static cGetCliDir      														// Guarda o caminho do rootPath
Static cProfStr1       														// Guarda o Retorno da Funcao GetPvProfString
Static lMvLjPdvPa := LjxBGetPaf()[2]										// Indica se é pdv
Static oSerieRec
Static oRecibo
Static nModOrigem := 0														// Indica o codigo do Modulo de origem usando em web service
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Essa variavel está sendo inicializada dentro das funcoes e Method's           ³
//³porque em caso de PAF(WS - sem preparein), o ambiente nao foi preparado ainda.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static cSerieRec	:= ""													// Essa variavel era inicializada por Criavar("EL_SERIE" )
Static cRecibo		:= ""                                                   // Essa variavel era inicializada por Criavar("EL_RECIBO" )

Static nOpSelBxa    := 0													// Guarda opcao com a sequencia a ser considerada no SE5, que foi escolhida pelo usuario no estorno da Recebimento
Static lLojxRec		:= .F.													// Utilizada na funcao A040DupRec para verificar se esta sendo recebido um titulo
Static lAddTitulos  := .F.													//Valida se deve adicionar titulos em várias pesquisas
Static nAcres		:= 0
Static lMFE			:= IIF(Type("CEMPANT") == "C" .AND. FindFunction("LjUsaMfe"), LjUsaMfe(), .F. )     //Se utiliza MFE
Static oCPFTemp		:= Nil
Static lLGPD 		:= Iif(ExistFunc("LjPDUse"),LjPDUse(),.F.) //Verifica se a funcionalidade de Dados Protegidos está sendo utilizada no sistema.
Static lRecebNFCE   := nil													//Controle de Performance - função LjModNFis()
Static dLJRECVER 	:= GetApoInfo("LJRECVER.PRW")[04]						// Pega a data do fonte LJRECVER caso exista (Fonte com User function da pasta "Automacao Comercial/Rotinas de Acrescimo" que será movido para obsoletos). Se não existir o fonte compilado no RPO, retorna vazio.
Static lLJRECVER 	:= ExistBlock("LJRECVER") .And. (Empty(dLJRECVER) .Or. dLJRECVER <> cTod("15/09/2021")) //Verifica se não existe o fonte compilado ou se a data do fonte é diferente de 15/09/2021. Data em que foi feita uma alteração por uma issue e o fonte acabou entrando no RPO padrão. Assim garante que não pare de funcionar o PE caso o cliente tenha compilado em seu RPO.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WebService³ WSTitulo ³ Autor ³ Cesar Eduardo Valadao ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT WSTitulo
	WSDATA Prefixo		AS String
	WSDATA NumTitulo	AS String
	WSDATA Parcela		AS String
	WSDATA Vencimento	AS Date						// Vencimento real.
	WSDATA Valor		AS Float
	WSDATA VlrMulta		AS Float
	WSDATA VlrJuros		AS Float
	WSDATA VlrDesconto	AS Float
	WSDATA VlrRecebido	AS Float
	WSDATA Tipo     	AS String
	WSDATA Contrato    	AS String
	WSDATA Cliente     	AS String
	WSDATA Loja        	AS String
	WSDATA FilTit      	AS String
	WSDATA NumRecno		AS Integer
	WSDATA VlrAcres		AS Float		OPTIONAL
	WSDATA ConcAcrs		AS Boolean		OPTIONAL
	WSDATA ValAbat   	AS Float		OPTIONAL
	WSDATA VencOri   	AS Date			OPTIONAL	// Vencimento original.
	WSDATA SELEAS 		As Boolean		OPTIONAL
	WSDATA Lock			AS String		OPTIONAL	// Cod de uso do Registro
	WSDATA Moeda		AS Integer		OPTIONAL	// Codigo da moeda do titulo
	WSDATA Interes		AS Float		OPTIONAL	// Interes (Juros) - Posicao reservada para fabrica (cliente Coppel)
	WSDATA DtBaixa		AS Date			OPTIONAL	// Data da Baixa
	WSDATA Saldo		AS Float		OPTIONAL	// Saldo do titulo
	WSDATA ValLiq		AS Float		OPTIONAL	// Valor Liquido
ENDWSSTRUCT
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WebService³  WSPgt   ³ Autor ³ Cesar Eduardo Valadao ³ Data ³20/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT 	WSPgt
	WSDATA	VENCTO	AS  DATE
	WSDATA	TIPO	AS  String
	WSDATA	VALOR	AS	Float
	WSDATA	BCOCHQ	AS	String
	WSDATA	AGECHQ	AS	String
	WSDATA	CTACHQ	AS	String
	WSDATA  CODADM  AS  String
	WSDATA  NUMERO	AS	String 	OPTIONAL
	WSDATA  DATACH	AS  Date	OPTIONAL
	WSDATA  COMPENS	AS  String	OPTIONAL
	WSDATA  RG		AS  String	OPTIONAL
	WSDATA  TEL		AS  String	OPTIONAL
	WSDATA  CheTer	AS  Boolean	OPTIONAL
	WSDATA  NSUTEF 	AS  String  OPTIONAL
	WSDATA  NSUDOC 	AS  String 	OPTIONAL
	WSDATA  CIDCART	AS  String 	OPTIONAL
	WSDATA  ECHETER	AS  String 	OPTIONAL
	WSDATA  AUTORIZ	AS  String 	OPTIONAL
ENDWSSTRUCT

WSSTRUCT WsPgtArr
	WSDATA VerArray AS ARRAY OF WsPgt
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WebService³  WSPgts  ³ Autor ³ Cesar Eduardo Valadao ³ Data ³20/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT 	WSPgtS
	WSDATA	FORMAST		AS  String
	WSDATA	PARCELAST	AS  Float
ENDWSSTRUCT

WSSTRUCT WsPgtArrS
	WSDATA VerArray AS ARRAY OF WsPgtS
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WebService³  WSTit   ³ Autor ³ Cesar Eduardo Valadao ³ Data ³20/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT 	WSTit
	WSDATA	TSELE	AS  Boolean
	WSDATA	TRECNO	AS  Float
	WSDATA  TTIPO	AS  String
	WSDATA  MODULO  AS  Float
ENDWSSTRUCT



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WebService³ WsEstTit ³ Autor ³ Vendas Crm            ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Auxilio estono de recebimento                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT WsEstTit
	WSDATA ValorTot 	  AS Float						OPTIONAL
	WSDATA SemErro  	  AS BOOLEAN					OPTIONAL
	WSDATA Erros		  AS String						OPTIONAL
	WSDATA VerArray 	  AS ARRAY OF  WsEstTitArray 	OPTIONAL
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WebService³WsEstTitA ³ Autor ³ Vendas Crm            ³ Data ³21/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Auxilio estono de recebimento                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT 	WsEstTitArray
	WSDATA	X		AS  String
	WSDATA	y		AS  String
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WebService³  TitEst  ³ Autor ³ Vendas CRM            ³ Data ³21/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Auxilio estono de recebimento                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT TitEst
	WSDATA VerArray AS ARRAY OF WSTitulo
ENDWSSTRUCT


WSSTRUCT WsTitS
	WSDATA VerArray AS ARRAY OF WsTit
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³WebService³WSStrutSLV³ Autor ³ Vendas CRM            ³ Data ³20/11/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Estrutura do array aDadosSLV                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSTRUCT WSStrutSLV
	WSDATA FORMA 	AS  String
	WSDATA VALOR 	AS  Float
	WSDATA DATATEF	AS  String
	WSDATA HORATEF	AS  String
	WSDATA DOCTEF	AS  String
	WSDATA AUTORIZ	AS  String
	WSDATA INSTITU	AS  String
	WSDATA NSUTEF	AS  String
	WSDATA TIPCART	AS  String
	WSDATA SEQOPER	AS  String
	WSDATA RECSE5	AS  Float
	WSDATA CANTEF	AS  Boolean
	WSDATA DOCCANC	AS  String
	WSDATA HORCANC	AS  String
	WSDATA DATCANC	AS  String	
	WSDATA BANDEIRA	AS  String
	WSDATA REDEAUT	AS  String
ENDWSSTRUCT

WSSTRUCT WsSLVArr
	WSDATA VerArray AS ARRAY OF WSStrutSLV
ENDWSSTRUCT


WSSERVICE LJReceb DESCRIPTION "Serviço de recebimento de parcelas (<b>Automação Comercial</b>)" NAMESPACE "http://webservices.microsiga.com.br"
	WSDATA MV_LJRECEB	  AS String
	WSDATA CodCli		  AS String
	WSDATA LojCli		  AS String
	WSDATA CPF			  AS String
	WSDATA Cartao		  AS String
	WSDATA NumRA		  AS String
	WSDATA Prefixo		  AS String
	WSDATA NumTitulo	  AS String
	WSDATA Parcela		  AS String
	WSDATA Vencimento	  AS Date
	WSDATA Valor		  AS Float
	WSDATA VlrMulta		  AS Float
	WSDATA VlrJuros		  AS Float
	WSDATA VlrDesconto	  AS Float
	WSDATA VlrRecebido	  AS Float
	WSDATA Tipo           AS String
	WSDATA aTitulos		  AS ARRAY OF WSTitulo
	WSDATA Banco          AS String
	WSDATA Agencia        AS String
	WSDATA Conta          AS String
	WSDATA Numero         AS String
	WSDATA Data           AS Date
	WSDATA Compensacao    AS String
	WSDATA RG             AS String
	WSDATA Telefone       AS String
	WSDATA ChequeTerceiro AS Boolean
	WSDATA cCartao        AS String		OPTIONAL
	WSDATA FilialTit      AS String
	WSDATA cTipoPgto	  AS String		OPTIONAL
	WSDATA cNomeUser  	  AS String		OPTIONAL
	WSDATA ValAbat   	  AS Float      OPTIONAL
	WSDATA EmpPdv   	  AS String     OPTIONAL
	WSDATA FilPdv   	  AS String     OPTIONAL
	WSDATA MvLjPdvPa   	  AS BOOLEAN    OPTIONAL
	WSDATA EmitenteCheTer AS String OPTIONAL

	WSDATA cFilialG		  AS String		OPTIONAL
	WSDATA cPrefixo       AS String     OPTIONAL
	WSDATA cNumero        AS String     OPTIONAL
	WSDATA cParcela       AS String     OPTIONAL
	WSDATA cTipo          AS String     OPTIONAL
	WSDATA lRet			  AS BOOLEAN	OPTIONAL
	WSDATA dDate		  AS DATE		OPTIONAL
	WSDATA aPgWs	 	  AS WsPgtArr	OPTIONAL
	WSDATA aPgWsS	 	  AS WsPgtArrS 	OPTIONAL
	WSDATA aTit			  AS WsTitS		OPTIONAL
	WSDATA TipOpe		  AS String		OPTIONAL
	WSDATA RetEsto		  AS WsEstTit	OPTIONAL
	WSDATA aTitEst 		  AS TitEst		OPTIONAL
	WSDATA ValorTot 	  AS Float		OPTIONAL
	WSDATA SemErro 		  AS BOOLEAN   	OPTIONAL
	WSDATA ERROS 		  AS String		OPTIONAL
	WSDATA SELEAS 		  As Boolean	OPTIONAL
	WSDATA MoedaTrc		  As Integer
	WSDATA ValTroco		  As Float		OPTIONAL
	WSDATA PrimBaixa	  As Boolean	OPTIONAL
	WSDATA TotReceb		  As Float		OPTIONAL
	WSDATA cChave		  AS String		OPTIONAL
	WSDATA cNumPdv		  AS String		OPTIONAL
	WSDATA cNumMov		  AS String		OPTIONAL
	WSDATA aDadosSLV	  AS WsSLVArr 	OPTIONAL
	WSDATA RecnoSE5 	  AS Float

	WSMETHOD GetTitulo		DESCRIPTION "Retornar as parcelas em aberto do cliente"
	WSMETHOD BaixaTitulo	DESCRIPTION "Baixar uma parcela do cliente"
	WSMETHOD GravaCheque	DESCRIPTION "Gravar o cheque do cliente, utilizado para o pagamento"
	WSMETHOD GeraTitRec		DESCRIPTION "Gera titulos referente o recebimento no SE1"
	WSMETHOD EstoTitRec		DESCRIPTION STR0135 //"Estorna titulo de recebimento"
	WSMETHOD GeraTroco		DESCRIPTION "Gera SE5 para o troco"
	WSMETHOD LjLockTit		DESCRIPTION "Cria um semaforo para o titulo de Recebimento"
	WSMETHOD LjDelTit		DESCRIPTION	"Deleta o semaforo criado pelo LjLockTit"
	WSMETHOD GravaTabSLV	DESCRIPTION "Grava registro na tabela SLV referente a Transacao TEF na baixa de Recebimento de titulos"


ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³GetTitulo ³ Autor ³ Cesar Eduardo Valadao ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD GetTitulo WSRECEIVE	MV_LJRECEB,		CodCli,		LojCli,		CPF,;
								Cartao,			NumRA,		Prefixo,	NumTitulo,;
								Parcela, 		EmpPdv, 	FilPdv, 	MvLjPdvPa, ;
								TipOpe WSSEND aTitulos WSSERVICE LJReceb
Local aRet
Local nI	:= 0	//controle de loop

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(::EmpPdv,::FilPdv)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Essa variavel está sendo inicializada dentro das funcoes e Method's           ³
//³porque em caso de PAF(WS - sem preparein), o ambiente nao foi preparado ainda.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSerieRec  := Criavar("EL_SERIE" )
cRecibo    := Criavar("EL_RECIBO" )

If !Empty(AllTrim(TipOpe))
	cOper := TipOpe
Else
	cOper := "1" 	// mantem Default
EndIf


TipOpe := "1"	// Zera propriedade

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno do LJRecLoad        ³
//³ 1 - Status                  ³
//³ 2 - Param 1 do SetSoapFault ³
//³ 3 - Param 2 do SetSoapFault ³
//³ 4 - Array com os Titulos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := LJRecLoad(	::MV_LJRECEB,	::CodCli,	::LojCli,	::CPF,;
					::Cartao,		::NumRA,	::Prefixo,	::NumTitulo,;
					::Parcela)

If aRet[1] == 0
	::aTitulos := Array(Len(aRet[4]))
	For nI := 1 To Len(aRet[4])
		::aTitulos[nI]				:= WSClassNew("WSTitulo")
		::aTitulos[nI]:Prefixo      := aRet[4][nI][TIT_PREF - 1]
		::aTitulos[nI]:NumTitulo    := aRet[4][nI][TIT_NUME - 1]
		::aTitulos[nI]:Parcela      := aRet[4][nI][TIT_PARC - 1]
		::aTitulos[nI]:Vencimento   := aRet[4][nI][TIT_VREA - 1]
		::aTitulos[nI]:Valor        := aRet[4][nI][TIT_VALO - 1]
		::aTitulos[nI]:VlrMulta     := aRet[4][nI][TIT_MULT - 1]
		::aTitulos[nI]:VlrJuros     := aRet[4][nI][TIT_JURO - 1]
		::aTitulos[nI]:VlrDesconto  := aRet[4][nI][TIT_DESC - 1]
		::aTitulos[nI]:VlrRecebido  := aRet[4][nI][TIT_RECE - 1]
		::aTitulos[nI]:Tipo         := aRet[4][nI][TIT_TIPO - 1]
		::aTitulos[nI]:Contrato     := aRet[4][nI][TIT_CONT - 1]
		::aTitulos[nI]:Cliente      := aRet[4][nI][TIT_CLIE - 1]
		::aTitulos[nI]:Loja         := aRet[4][nI][TIT_LOJA - 1]
		::aTitulos[nI]:FilTit       := aRet[4][nI][TIT_FILI - 1]
		::aTitulos[nI]:NumRecno     := aRet[4][nI][TIT_RECN - 1]
		::aTitulos[nI]:VlrAcres     := aRet[4][nI][TIT_ACRS - 1]
		::aTitulos[nI]:ConcAcrs     := aRet[4][nI][TIT_CACR - 1]
		::aTitulos[nI]:ValAbat      := aRet[4][nI][TIT_ABAT - 1]
		::aTitulos[nI]:VencOri      := aRet[4][nI][TIT_VENC - 1]
		::aTitulos[nI]:Lock			:= aRet[4][nI][TIT_LOCK - 1]
		::aTitulos[nI]:Moeda		:= aRet[4][nI][TIT_MOED - 1]
		::aTitulos[nI]:Interes		:= aRet[4][nI][TIT_INTE - 1]
		::aTitulos[nI]:DtBaixa		:= aRet[4][nI][TIT_DTBX - 1]
		::aTitulos[nI]:Saldo		:= aRet[4][nI][TIT_SALD - 1]
		::aTitulos[nI]:ValLiq		:= aRet[4][nI][TIT_VLIQ - 1]

	Next nI

	//Apaga arquivos de controle de semaforo de recebimento de titulos que foram selecionados em recebimentos realizados em dias anteriores
	LjDelArqs()

Else
	SetSoapFault(aRet[2], aRet[3])
	Return(.F.)
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³BaixaTitulo³ Autor³ Cesar Eduardo Valadao ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD BaixaTitulo WSRECEIVE	MV_LJRECEB, 	Prefixo,		NumTitulo,		Parcela,;
								Vencimento,		Valor,			VlrMulta,		VlrJuros,;
								VlrDesconto, 	VlrRecebido,	Tipo,			cCartao,;
								FilialTit,		cTipoPgto,		cNomeUser,		ValAbat,;
								EmpPdv, 		FilPdv,    		MvLjPdvPa, 		ValTroco,;
								PrimBaixa, 		TotReceb,		cNumMov  WSSEND RecnoSE5 WSSERVICE LJReceb

Local nRecnoSE5 := 0		// Recno do Registro da tabela SE5 (Neste caso, em ambiente OFF-Line eh considerado o recno da Retaguarda)
Local lRet		:= .T.

LjPreparaWs(::EmpPdv,::FilPdv)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Essa variavel está sendo inicializada dentro das funcoes e Method's           ³
//³porque em caso de PAF(WS - sem preparein), o ambiente nao foi preparado ainda.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSerieRec  := Criavar("EL_SERIE" )
cRecibo    := Criavar("EL_RECIBO" )

If !LJRecBXSE1(	::MV_LJRECEB,	::Prefixo,		::NumTitulo,	::Parcela,;
				::Vencimento,	::Valor,		::VlrMulta,		::VlrJuros,;
				::VlrDesconto,	::VlrRecebido,	::Tipo,			::cCartao,;
				::FilialTit,	::cTipoPgto,	::PrimBaixa,		NIL,;
				NIL,			NIL,			::TotReceb,		NIL,;
				NIL,			::cNomeUser,	::ValAbat,		NIL,;
				NIL,			NIL,			NIL,			::ValTroco,;
				NIL, 			@nRecnoSE5, 	.T.,			::cNumMov)


	SetSoapFault("Erro LJRecBXSE1", "Erro LJRecBXSE1")
	lRet := .F.
Endif

If lRet
	::RecnoSE5 := nRecnoSE5 //Atualiza o retorno deste metodo
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³GravaCheque³ Autor³ Cesar Eduardo Valadao ³ Data ³28/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD GravaCheque WSRECEIVE	Banco,		Agencia,			Conta,			Numero,;
								Valor,		Data,				Compensacao,	RG,;
								Telefone,	ChequeTerceiro,		Prefixo,		NumTitulo,;
								Parcela,	Tipo, 				EmpPdv, 		FilPdv, ;
								MvLjPdvPa,  EmitenteCheTer WSSEND CPF WSSERVICE LJReceb

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(::EmpPdv,::FilPdv)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Essa variavel está sendo inicializada dentro das funcoes e Method's           ³
//³porque em caso de PAF(WS - sem preparein), o ambiente nao foi preparado ainda.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSerieRec  := Criavar("EL_SERIE" )
cRecibo    := Criavar("EL_RECIBO" )
LJRecGrvCH(	::Banco,	::Agencia,			::Conta,		::Numero,;
			::Valor,	::Data,				::Compensacao,	::RG,;
			::Telefone,	::ChequeTerceiro,	::Prefixo,		::NumTitulo,;
			::Parcela,	::Tipo, ::EmitenteCheTer)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³EstoTitRec³ Autor ³ Vendas CRM            ³ Data ³21/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Estorna titulo                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD EstoTitRec WSRECEIVE 	ValorTot, SemErro, Erros, aTitEst,;
							 	cNomeUser, EmpPdv, FilPdv WSSEND RetEsto WSSERVICE LJReceb

Local aDadosEst := {} 	// Array de retorno de recebimento
Local nX		:= 0	// Contador
Local cDatVencOri:= ''	// Data vencimento

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao LjPreparaWs
If !Empty(::EmpPdv) .And. !Empty(::FilPdv)
	LjPreparaWs(::EmpPdv,::FilPdv)
EndIf

If Type("cEstacao") == "U"
	cEstacao := ""
EndIf

aTitulo := Array(Len( aTitEst:VERARRAY ) )

For nX := 1 To Len(aTitulo)

	aTitulo[nX] := Array( 26 )

	cDatVencOri  :=  DToC(aTitEst:VERARRAY[nX]:VencOri)

	aTitulo[nX][TIT_CLIE] := aTitEst:VERARRAY[nX]:Cliente
	aTitulo[nX][TIT_CONT] := aTitEst:VERARRAY[nX]:Contrato
	aTitulo[nX][TIT_FILI] := aTitEst:VERARRAY[nX]:FilTit
	aTitulo[nX][TIT_LOJA] := aTitEst:VERARRAY[nX]:Loja
	aTitulo[nX][TIT_NUME] := aTitEst:VERARRAY[nX]:NumTitulo
	aTitulo[nX][TIT_PARC] := aTitEst:VERARRAY[nX]:Parcela
	aTitulo[nX][TIT_PREF] := aTitEst:VERARRAY[nX]:Prefixo
	aTitulo[nX][TIT_TIPO] := aTitEst:VERARRAY[nX]:Tipo
	aTitulo[nX][TIT_VREA] := aTitEst:VERARRAY[nX]:Vencimento
	aTitulo[nX][TIT_VENC] := cDatVencOri//
	aTitulo[nX][TIT_CACR] := aTitEst:VERARRAY[nX]:Concacrs
	aTitulo[nX][TIT_RECN] := aTitEst:VERARRAY[nX]:NumRecno
	aTitulo[nX][TIT_ABAT] := aTitEst:VERARRAY[nX]:Valabat
	aTitulo[nX][TIT_VALO] := aTitEst:VERARRAY[nX]:Valor
	aTitulo[nX][TIT_ACRS] := aTitEst:VERARRAY[nX]:VlrAcres
	aTitulo[nX][TIT_DESC] := aTitEst:VERARRAY[nX]:VlrDesconto
	aTitulo[nX][TIT_MULT] := aTitEst:VERARRAY[nX]:VlrMulta
	aTitulo[nX][TIT_JURO] := aTitEst:VERARRAY[nX]:VlrJuros
	aTitulo[nX][TIT_RECE] := aTitEst:VERARRAY[nX]:VlrRecebido
	aTitulo[nX][TIT_SELE] := aTitEst:VERARRAY[nX]:SELEAS
	aTitulo[nX][TIT_DTBX] := aTitEst:VERARRAY[nX]:DtBaixa
	aTitulo[nX][TIT_SALD] := aTitEst:VERARRAY[nX]:Saldo
	aTitulo[nX][TIT_VLIQ] := aTitEst:VERARRAY[nX]:ValLiq

Next nX

Self:RetEsto:ValorTot 	:= ValorTot
Self:RetEsto:SemErro 	:= SemErro
Self:RetEsto:ERROS 		:= Erros

LjRecCancBx(	@Self:RetEsto:ValorTot,	@Self:RetEsto:SemErro,	@Self:RetEsto:ERROS, @aDadosEst, ;
				Nil, 					.T.,				 	@Self:cNomeUser)

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³ GeraTroco³ Autor ³ Vendas e CRM          ³ Data ³01/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera SE5 para troco.                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GeraTroco WSRECEIVE 	Valor, MoedaTrc, CodCli,;
							 	LojCli, aTitEst, cNomeUser,;
							 	EmpPdv, FilPdv WSSEND lRet WSSERVICE LJReceb
Local nX

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao LjPreparaWs
If !Empty(::EmpPdv) .And. !Empty(::FilPdv)
	LjPreparaWs(::EmpPdv,::FilPdv)
EndIf

aTitulo := Array(Len( aTitEst:VERARRAY ) )

For nX := 1 To Len(aTitulo)
	aTitulo[nX] := Array(26)

	aTitulo[nX][TIT_SELE] := aTitEst:VERARRAY[nX]:SELEAS
	aTitulo[nX][TIT_PREF] := aTitEst:VERARRAY[nX]:Prefixo
	aTitulo[nX][TIT_NUME] := aTitEst:VERARRAY[nX]:NumTitulo
	aTitulo[nX][TIT_PARC] := aTitEst:VERARRAY[nX]:Parcela
	aTitulo[nX][TIT_VREA] := aTitEst:VERARRAY[nX]:Vencimento
	aTitulo[nX][TIT_VALO] := aTitEst:VERARRAY[nX]:Valor
	aTitulo[nX][TIT_MULT] := aTitEst:VERARRAY[nX]:VlrMulta
	aTitulo[nX][TIT_JURO] := aTitEst:VERARRAY[nX]:VlrJuros
	aTitulo[nX][TIT_DESC] := aTitEst:VERARRAY[nX]:VlrDesconto
	aTitulo[nX][TIT_RECE] := aTitEst:VERARRAY[nX]:VlrRecebido
	aTitulo[nX][TIT_TIPO] := aTitEst:VERARRAY[nX]:Tipo
	aTitulo[nX][TIT_CONT] := aTitEst:VERARRAY[nX]:Contrato
	aTitulo[nX][TIT_CLIE] := aTitEst:VERARRAY[nX]:Cliente
	aTitulo[nX][TIT_LOJA] := aTitEst:VERARRAY[nX]:Loja
	aTitulo[nX][TIT_FILI] := aTitEst:VERARRAY[nX]:FilTit
	aTitulo[nX][TIT_RECN] := aTitEst:VERARRAY[nX]:NumRecno
	aTitulo[nX][TIT_DTBX] := aTitEst:VERARRAY[nX]:DtBaixa
	aTitulo[nX][TIT_SALD] := aTitEst:VERARRAY[nX]:Saldo
	aTitulo[nX][TIT_VLIQ] := aTitEst:VERARRAY[nX]:ValLiq

Next nX

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³ LJReceb  ³ Autor ³ Cesar Eduardo Valadao ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que realiza o pagamento de titulos, parcelas de     ³±±
±±³          ³ financiamento atraves de uma interface que sera utilizada  ³±±
±±³          ³ no Front Lojan e na Venda Assistida, sendo que no Front    ³±±
±±³          ³ Loja as transacoes serao realizadas via WebService.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJReceb(nTipoOper)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExprN : Tipo da Operacao                                   ³±±
±±³       	 ³         1 - Recebimentos (Default)                         ³±±
±±³       	 ³         2 - Estorno de Recebimentos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Front Loja e Venda Assistida                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJReceb( cCodCli, cLojaCli, cRecCart, cRecCPF, cRecCont, lOcioso )

Local cTitle                                           	// Titulo da janela de recebimento
Local aHeader                                          	// Cabecalho com o nome dos campos
Local oOk := LoadBitmap(GetResources(), "LBOK")       	// Objeto do selecao do titulo(OK)
Local oNo := LoadBitmap(GetResources(), "LBNO")       	// Objeto do selecao do titulo(NO)
Local oDlg                                             	// Objeto do Dialog
Local oFonte											//Objeto contendo a fonte
Local aRet := {0, {}}								   	// Retorno da LJReceb {nTotal, aTitulo}
Local oBtnImprime                                      	// Objeto do botao para imprimir boleto
Local lLJImpBol   := ExistBlock("LJIMPBOL",,.T.)      	// Verifica se existe o PE LJIMPBOL
Local lLJDesBAlt  := ExistBlock("LJBALTTI")		   	// Ponto de entrada que existindo desabilita o botao de edicao do titulo
Local xRet                                             	// Retorno de pontos de entrada
Local cPicE1_Val := PesqPict("SE1", "E1_VALOR", 13)	   	// Picture usada para a edicao dos valores do campo E1_VALOR
Local cPicE1_Mul := PesqPict("SE1", "E1_MULTA", 13)   	// Picture usada para a edicao dos valores do campo E1_MULTA
Local cPicE1_Jur := PesqPict("SE1", "E1_JUROS", 13)   	// Picture usada para a edicao dos valores do campo E1_JUROS
Local cPicE1_Des := PesqPict("SE1", "E1_DESCONT", 13) 	// Picture usada para a edicao dos valores do campo E1_DESCONT
Local cPicNumRA  := ""                                 	// Picture usada para a edicao dos valores do campo JA2_NUMRA
Local cPicMA6NUM := ""                                 	// Picture usada para a edicao dos valores do campo MA6_NUM
Local cPicMAHCON := ""                                 	// Picture usada para a edicao dos valores do campo MAH_CONTRA
Local lLJTelaRec := ExistBlock("LJTELAREC")   		// P.E. para customizar a tela de recebimento
Local aCampos	 := {} 	                            	// Retorno do ponto de entrada que contem a nova ordenacao dos campos a serem apresentados na tela de recebimento
Local aButtonUsr := {} 	                            	// Botao de Usuario no Recebimento.
Local lLJRECUSR  := ExistBlock("LJRECUSR")					// P.E. para adicionar um botao na tela de recebimento.
Local lLJRCBTUS  := !lLJRECUSR .AND. ExistBlock("LJRCBTUS")	// P.E. para adicionar um botao na tela de recebimento se o P.E. LJRECUSR nao existir.
Local lRecFilial := SuperGetMV("MV_LJRECFI",,.F. )
Local lTelaOk	 := .F.									// Controle do botao de confirmacao (OK) da janela
Local cBxRec	 := SuperGetMV("MV_VLBXREC",, "1")             //Validação da Baixa do Recebimento
Local nDecE1Tam	 := TamSX3("E1_VALOR")[1]
Local nDecE1Val  := TamSX3("E1_VALOR")[2]
Local lBscCliON  := SuperGetMV("MV_LJCLION", ,.F.)		// Identifica se o Front ira´ se conectar com a Retaguarda
Local lFCHCON    := .T.									// Indica se foi estabelecida a conexão com a Retaguarda para posteriormente ser fechada.
Local nConTcLnk  := 0

Local oCbBox	:= Nil 									// Objeto do ComboBox para pesquisar os titulos na grid
Local cFiltro	:= ""									// Variavel do ComboBox
Local aIndex	:= LjE1Indx()							// Array com as opcoes do ComboBox - Indices SE1
Local oSeek		:= Nil									// Objeto do Get para pesquisa de titulos na grid
Local cSeek		:= Space(110)							// Variavel do Get para pesquisa de titulos na grid
Local aCores	:= {}									// Array com a legenda
Local lMultCli	:= SuperGetMV("MV_LJMLTRC", NIL, .F.) 	// Parametro para habilitar o recebimento de titulos de diversos clientes
Local oAbert	:= Nil							  		// Objeto para legenda - Titulo em aberto
Local oVenc		:= Nil										// Objeto para legenda - Titulo em vencido
Local oParc 	:= Nil									// Objeto para legenda - Titulo em baixado parcialmente
Local oBaix   	:= Nil									// Objeto para legenda - Titulo baixado
Local cPicE1_Acr:= PesqPict("SE1", "E1_ACRESC", 13) 	// Picture usada para a edicao dos valores do campo E1_ACRES

Default cCodCli	 := Space(TamSx3("A1_COD")[1])					// Codigo do cliente
Default cLojaCli := Space(TamSx3("A1_LOJA")[1])					// Loja do cliente
Default cRecCart := Space(TamSX3("MA6_NUM")[1]) 				// Numero do cartao
Default cRecCPF  := Space(TamSX3("A1_CGC")[1]) 					// Numero do CNPJ/CPF do cliente
Default cRecCont := Space(TamSX3("MAH_CONTRA")[1]) 				// Numero do contrato
Default lOcioso  := .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Essa variavel está sendo inicializada dentro das funcoes e Method's           ³
//³porque em caso de PAF(WS - sem preparein), o ambiente nao foi preparado ainda.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSerieRec  := Criavar("EL_SERIE" )
cRecibo    := Criavar("EL_RECIBO" )

If lRecFilial
    If SE5->(ColumnPos("E5_MSFIL")) == 0
		Aviso(STR0001, STR0147, {STR0003})   //"Uso indevido na função de recebimentos" - "Necessário habilitar o campo Filial de Inclusão E5_MSFIL no módulo configurador" - "OK"
		Return(aRet)
    EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consiste se esta no mod. FrontLoja³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(LJGetStation("WSSRV")) .AND. ( (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa) )
    //"Uso Indevido da função de Recebimentos","É necessário preencher o campo LG_WSSRV com o IP e/ou porta do Web Service.","Ok"
	Aviso(STR0001, STR0002, {STR0003})
	Return(aRet)
Endif

aTitulo := {aTitVazio}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conteudo do MV_LJRECEB                 ³
//³ "1" - Financeiro                       ³
//³ "2" - Gestao Educacional               ³
//³ "3" - Fidelizacao e Analise de Credito ³
//³ "4" - EMS - Eletronic Market Solution  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMV_LJRECEB := LJRecSistCr() //Funcao que formata o parametro abaixo.

If Empty( cMV_LJRECEB )
	Return aRet
Endif

If Select("JA2") > 0
	cNumRA   := CriaVar("JA2_NUMRA")
	cPicNumRA  := PesqPict("JA2", "JA2_NUMRA")
Else
	cNumRA   := Space(10)
Endif
cCodCli  := CriaVar("A1_COD", .F.)
cLojCli  := CriaVar("A1_LOJA", .F.)
cCPF     := CriaVar("A1_CGC", .F.)
cCPFTemp := CriaVar("A1_CGC", .F.)
If Select("MA6") > 0
	cCartao  := CriaVar("MA6_NUM")
	cPicMA6NUM := PesqPict("MA6", "MA6_NUM")
Else
	cCartao  := Space(16)
Endif
cPrefixo := CriaVar("E1_PREFIXO", .F.)
If cMV_LJRECEB $ "3,4"	// Fidelizacao e Analise de Credito / EMS
	If Select("MAH") > 0
		cNum := CriaVar("MAH_CONTRA")
		cPicMAHCON := PesqPict("MAH", "MAH_CONTRA")
	Else
		cNum := Space(10)
	Endif
Else
	cNum := CriaVar("E1_NUM", .F.)
Endif
cParcela := CriaVar("E1_PARCELA", .F.)
nTotal   := 0
nMulta   := 0
nJuros   := 0
nDescont := 0
nAcres	 := 0
nValRec  := 0

If cMV_LJRECEB == "5"
	If ExistBlock("LJRECEB")
		LjGrvLog("RECEBIMENTO","Ponto de Entrada LJRECEB")
		ExecBlock("LJRECEB",.F.,.F.)
		LjGrvLog("RECEBIMENTO","Retorno do Ponto de Entrada LJRECEB")
	Else
		Return({})
	Endif
Else
	LJRecHeade(cMV_LJRECEB, @cTitle, @aHeader, @aCampos)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Ponto de entrada antes da chamada da tela de recebimento. Pode ser utilizado para                                  |
//| chamar outra rotina no lugar da padrao                                                                             |
//| Permite que o PE ja inicialize o cliente do recebimento de titulos												   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "LJRECVAL" )
	LjGrvLog("RECEBIMENTO","Ponto de Entrada LJRECVAL - Parametros", {cMV_LJRECEB})
	xRet  := ExecBlock( "LJRECVAL", .F., .F., {cMV_LJRECEB})
	LjGrvLog("RECEBIMENTO","Ponto de Entrada LJRECVAL - Retorno", xRet)
	If ValType(xRet) == "L"
		Return aRet
	ElseIf ValType(xRet) == "A" .AND. Len(xRet) > 1
		cCodCli  := xRet[1]
		cLojCli  := xRet[2]
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada antes da chamada da tela de recebimento para substituir a tela padrao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLJTelaRec

	// Verifica se o Front irá se conectar com a retaguarda.
	If lBscCliON
		If !FRTAABRCON(@nConTcLnk)
			lFCHCON := .F.
		Else
			// Seleciona/prepara a area da retaguarda para ser utilizada no Check-Out.
			FRTADEFTAB(Posicione("SX2", 1, "SA1", "AllTrim(X2_ARQUIVO)"), "SA1", nConTcLnk)
		EndIf
	EndIf

	If !U_LJTelaRec(@aRet		, cMV_LJRECEB	, @cRecCart	, @cRecCPF		,;
					@cRecCont	, lOcioso		, @aTitulo	, @cSerieRec	,;
					@cRecibo	, @cCodCli		, @cLojaCli	, @cLojCli		,;
					lFCHCON)

		// Finaliza a conexão com a retaguarda.
		If lBscCliON .And. lFCHCON
			FRTAFCHCON(nConTcLnk)
		EndIf

		Return(aRet)
	Endif

	// Finaliza a conexão com a retaguarda.
	If lBscCliON .And. lFCHCON
		FRTAFCHCON(nConTcLnk)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Legenda  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oAbert	:= LoadBitmap( GetResources(), "BR_VERDE" )
oVenc	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
oParc	:= LoadBitmap( GetResources(), "BR_AZUL" )
oBaix	:= LoadBitmap( GetResources(), "BR_CINZA" )

Aadd(aCores,oAbert)
Aadd(aCores,oVenc)
Aadd(aCores,oParc)
Aadd(aCores,oBaix)

DEFINE MSDIALOG oDlg FROM 0,0 TO 570,690 TITLE cTitle PIXEL STYLE DS_MODALFRAME

	cNomeCli := ""  //Limpa a variavel que apresenta o nome do cliente

	@ 05,05 TO If(cMV_LJRECEB == "2",41,56),270 LABEL "" PIXEL

	If cMV_LJRECEB == "1"	// Financeiro
		@ 08,08 SAY STR0004 SIZE 35,15 PIXEL OF oDlg   //"Cod. Cliente / Loja"
		@ 10,43 MSGET oCodCli VAR cCodCli SIZE 40,9 PIXEL F3 "SA1" OF oDlg PICTURE PesqPict("SA1", "A1_COD") ;
				VALID LjRecVldCli(@cCodCli, @cLojCli, @cCPF, .T., @cCPFTemp )  .AND. Iif(!Empty(cCodCli),LjPicCPFCNPJ( @cCPF, @cCPFTemp ),.T.)
		@ 10,85 MSGET oLojCli VAR cLojCli SIZE 15,9 PIXEL OF oDlg WHEN !Empty(cCodCli) PICTURE PesqPict("SA1", "A1_LOJA") ;
				VALID LjRecVldCli(@cCodCli, @cLojCli, @cCPF, .T., @cCPFTemp ) .AND. LjPicCPFCNPJ( @cCPF, @cCPFTemp )

		@ 10,110 SAY STR0113 SIZE 41,7 PIXEL OF oDlg   //"CNPJ/CPF"

		@ 10,145 MSGET oCPFTemp VAR cCPFTemp SIZE 80,9 PIXEL OF oDlg WHEN Empty(cCodCli) ;
				 VALID LjPicCPFCNPJ( @cCPF, @cCPFTemp ) .AND. LjRecVldCli(@cCodCli, @cLojCli, @cCPF, .F., @cCPFTemp )
		If lLGPD .And. LjPDCmpPrt("LQ_CGCCLI")
			LjPDOfuscar(oCPFTemp, "LQ_CGCCLI")
		EndIf

		@ 25,08 SAY STR0006 SIZE 35,7 PIXEL OF oDlg   //"Prefixo"
		@ 25,43 MSGET cPrefixo SIZE 10,9 PIXEL PICTURE PesqPict("SE1", "E1_PREFIXO") OF oDlg

		@ 25,70 SAY STR0007 SIZE 20,7 PIXEL OF oDlg    //"Título"
		@ 25,90 MSGET cNum SIZE 50,9 PIXEL PICTURE PesqPict("SE1", "E1_NUM") OF oDlg WHEN !Empty(cPrefixo)

		@ 25,145 SAY STR0008 SIZE 25,7 PIXEL OF oDlg    //"Parcela"
		@ 25,170 MSGET cParcela SIZE 10,9 PIXEL PICTURE PesqPict("SE1", "E1_PARCELA") OF oDlg WHEN !Empty(cNum)

		@ 40,08 SAY STR0009 SIZE 41,7 PIXEL OF oDlg    //"Cliente "
		@ 40,43 MSGET oNomeCli VAR cNomeCli SIZE IIf(cPaisLoc<>"BRA",80,178),9 PIXEL WHEN .F. OF oDlg
		If lLGPD .And. LjPDCmpPrt("LQ_NOMCLI")
			LjPDOfuscar(oNomeCli, "LQ_NOMCLI")
		EndIf

		If !(cPaisloc $ "BRA|MEX") .AND. !LjNfPtgNEcf(SM0->M0_CGC) //PTG / ANG e MEX sem ECF - Nao apresentara esses campos
		    cSerieRec := "X  "
		    cRecibo   := Space(TamSx3("EL_RECIBO")[1] )
   			@ 40,123 SAY STR0123  SIZE 18,7 PIXEL OF oDlg    //"Serie"
			@ 40,136 MSGET oSerieRec VAR cSerieRec SIZE 22,9 PIXEL WHEN .F. OF oDlg
   			@ 40,163 SAY STR0124  SIZE 20,7 PIXEL  OF oDlg    //"Recibo"
			@ 40,184 MSGET oRecibo VAR cRecibo SIZE 40,9 PIXEL WHEN .F. OF oDlg
		EndIf
	ElseIf cMV_LJRECEB == "2" // Gestao Educacional
		@ 10,08 SAY STR0010 SIZE 39,7 PIXEL OF oDlg    //"RA do Aluno"
		@ 10,53 MSGET oNumRA VAR cNumRA SIZE 80,9 PIXEL OF oDlg VALID !Empty(cNumRA) PICTURE cPicNumRA

		@ 25,08 SAY STR0011 SIZE 41,7 PIXEL OF oDlg   //"Aluno "
		@ 25,43 MSGET oNomeCli VAR cNomeCli SIZE 178,9 PIXEL WHEN .F. OF oDlg
		If lLGPD .And. LjPDCmpPrt("LQ_NOMCLI")
			LjPDOfuscar(oNomeCli, "LQ_NOMCLI")
		EndIf

	ElseIf cMV_LJRECEB $ "3,4" // Fidelizacao e Analise de Credito / EMS
		@ 10,08 SAY STR0012 SIZE 39,7 PIXEL OF oDlg PICTURE cPicMA6NUM   //"Cartão"
		@ 10,43 MSGET oCartao VAR cCartao SIZE 70,9 PIXEL OF oDlg

		@ 25,08 SAY STR0113 SIZE 41,7 PIXEL OF oDlg   //"CNPJ/CPF"
		@ 25,43 MSGET oCPFTemp VAR cCPFTemp SIZE 70,9 PIXEL OF oDlg WHEN Empty(cCartao) VALID LjPicCPFCNPJ( @cCPF, @cCPFTemp )
		If lLGPD .And. LjPDCmpPrt("LQ_CGCCLI")
			LjPDOfuscar(oCPFTemp, "LQ_CGCCLI")
		EndIf

		@ 10,120 SAY STR0013 SIZE 30,7 PIXEL OF oDlg   //"Contrato"
		@ 10,150 MSGET cNum SIZE 70,9 PIXEL OF oDlg WHEN Empty(cCartao) .AND. Empty(cCPF) PICTURE cPicMAHCON

		@ 40,08 SAY STR0009 SIZE 41,7 PIXEL OF oDlg   //"Cliente "
		@ 40,43 MSGET oNomeCli VAR cNomeCli SIZE 178,9 PIXEL WHEN .F. OF oDlg
		If lLGPD .And. LjPDCmpPrt("LQ_NOMCLI")
			LjPDOfuscar(oNomeCli, "LQ_NOMCLI")
		EndIf
	Endif

	DEFINE SBUTTON oBtnBusc FROM 10,280 TYPE 17 ENABLE ONSTOP STR0170 ACTION LJRecPesq( @oNomeCli, @cNomeCli, @cCodCli, @cLojCli,@cSerieRec,@cRecibo,oSerieRec,oRecibo,,@cSeek,oSeek )	// "Buscar"
	oBtnBusc:cCaption := STR0170	// "Pesquisar"

	If cMV_LJRECEB == "1" .AND. (nModulo == 12  .OR. nModulo == 5 .OR. nModulo == 72 .OR. nModulo == 23)//12=SIGALOJA //72=SIGAPHOTO //23=FRONTLOJA //5=FATURAMENTO
		DEFINE SBUTTON oBtnEst FROM 25,280 TYPE 8  ENABLE ONSTOP STR0015  ACTION LjRecEstorna( @oNomeCli, @cNomeCli, @cCodCli, @cLojCli )	  //"Estornar baixa..."
		oBtnEst:cCaption := STR0171		//"Estornar"
	EndIf

	If lMultCli
		DEFINE SBUTTON  oBtnIncr FROM 10,310 TYPE 8 ENABLE ONSTOP STR0172 WHEN lMultCli ACTION LjAddTit() .AND. LJRecPesq( @oNomeCli, @cNomeCli, @cCodCli, @cLojCli,@cSerieRec,@cRecibo,oSerieRec,oRecibo,,@cSeek,oSeek )  //"Adicionar Titulos"
		oBtnIncr:cCaption := STR0173	//"Adicionar"
	EndIf

	If lLJRECUSR
		DEFINE SBUTTON FROM 25,310 TYPE 17 ENABLE ONSTOP STR0016 ACTION ExecBlock("LJRECUSR",.F.,.F.,aTitulo)  //"Genérico..."
	EndIf

	If lLJRCBTUS
	    // Retorno.
	    // [1] Tipo de botao de 1 a 17.
	    // [2] Funcao do Action.
	    // [3] Descricao do botao (opcional).
		aButtonUsr := ExecBlock("LJRCBTUS",.F.,.F.) 
		If ValType(aButtonUsr) == "A" .AND. Len(aButtonUsr) >= 2
		    If Len(aButtonUsr) == 2
		    	aAdd(aButtonUsr, STR0016)
		    ElseIf ValType(aButtonUsr[3]) <> 'C' .OR. empty(aButtonUsr[3])
				aButtonUsr[3] := STR0016
			EndIf
		 	DEFINE SBUTTON FROM 40,280 TYPE aButtonUsr[1] ENABLE ONSTOP aButtonUsr[3];
		 	ACTION ExecBlock(aButtonUsr[2], .F., .F., {aTitulo, cCodCli, cLojCli})  //"Genérico..."
		EndIf
	Endif

    If cMV_LJRECEB == "3"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a linha com as informacoes do titulo. Se existir o ponto de entrada³
		//³ utiliza a ordem dos campos estipulada no retorno do ponto de entrada.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If ExistBlock("LJRECHEAD") .AND. Len(aCampos) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o aHeader atraves do retorno do ponto de entrada que contem³
			//³os campos e a ordenacao                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval( aCampos, { |x,y| aAdd(aHeader,x[1]) } )

			@ 60,05 LISTBOX oTitulo FIELDS aHeader SIZE 335,100 PIXEL OF oDlg

			oTitulo:bLine := {|| { If(aTitulo[oTitulo:nAt][1],oOk,oNo),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[2][2])],aCampos[2][3]),;
	 							   Transform(aTitulo[oTitulo:nAt][(aCampos[3][2])],aCampos[3][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[4][2])],aCampos[4][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[5][2])],aCampos[5][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[6][2])],aCampos[6][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[7][2])],aCampos[7][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[8][2])],aCampos[8][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[9][2])],aCampos[9][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[10][2])],aCampos[10][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[11][2])],aCampos[11][3]),;
								   Transform(aTitulo[oTitulo:nAt][(aCampos[12][2])],aCampos[12][3]) }}
		Else

			@ 60,05 LISTBOX oTitulo FIELDS FIELDSIZES 10,40,20,15,20,30,22,15,33,35,35,35,35,35 SIZE 335,100 PIXEL OF oDlg
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se for recebimento do SIGACRD mostra na 1a coluna o numero do contrato   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oTitulo:bLine := {|| { If(aTitulo[oTitulo:nAt][TIT_SELE],oOk,oNo),;
								   aTitulo[oTitulo:nAt][TIT_CONT],;
								   aTitulo[oTitulo:nAt][TIT_CLIE],;
								   aTitulo[oTitulo:nAt][TIT_LOJA],;
								   aTitulo[oTitulo:nAt][TIT_PREF],;
								   aTitulo[oTitulo:nAt][TIT_NUME],;
								   aTitulo[oTitulo:nAt][TIT_PARC],;
								   aTitulo[oTitulo:nAt][TIT_TIPO],;
								   aTitulo[oTitulo:nAt][TIT_VREA],;
								   Transform(aTitulo[oTitulo:nAt][TIT_VALO],cPicE1_Val),;
								   Transform(aTitulo[oTitulo:nAt][TIT_MULT],cPicE1_Mul),;
								   Transform(aTitulo[oTitulo:nAt][TIT_JURO],cPicE1_Jur),;
								   Transform(aTitulo[oTitulo:nAt][TIT_DESC],cPicE1_Des),;
								   Transform(aTitulo[oTitulo:nAt][TIT_RECE],cPicE1_Val) }}
		EndIf
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos para pesquisa do titulo na grid apos o filtro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
		If ExistBlock("LJRECPSQ")  //Ponto de entrada oara validar filtro de busca
	       
			@  64,05 MSCOMBOBOX oCbBox VAR cFiltro ITEMS aIndex SIZE 150,09 OF oDlg PIXEL

			@  64,160 MSGET oSeek VAR cSeek SIZE 140,09 Valid LjMtSeek(@oCbBox,@cSeek,@oSeek,@cCodCli,@cLojCli) PIXEL OF oDlg
			
			DEFINE SBUTTON FROM 64,310 TYPE 17 ENABLE 
				
			If 	SuperGetMV("MV_LJPESRE",,0) > 0
				oCbBox:nAt := SuperGetMV("MV_LJPESRE",, 16)    
				oSeek:SetFocus()
			EndIf	

		Else			
			@  64,05 MSCOMBOBOX oCbBox VAR cFiltro ITEMS aIndex SIZE 150,09 WHEN oTitulo:lActive OF oDlg PIXEL
			@  64,160 MSGET oSeek VAR cSeek SIZE 140,09 WHEN oTitulo:lActive PIXEL OF oDlg
	
			DEFINE SBUTTON FROM 64,310 TYPE 17 ENABLE ACTION LjMtSeek(oCbBox,cSeek)			
		EndIf	
		
		@ 79,05 LISTBOX oTitulo FIELDS FIELDSIZES 10,20,15,15,20,22,15,15,35,35,35,35,35 SIZE 335,100 PIXEL OF oDlg 		

		oTitulo:bLine := {|| { aCores[LjGetLeg(aTitulo[oTitulo:nAt])]	,;
							   If(aTitulo[oTitulo:nAt][TIT_SELE],oOk,oNo),;
							   aTitulo[oTitulo:nAt][TIT_CLIE],;
							   aTitulo[oTitulo:nAt][TIT_LOJA],;
							   aTitulo[oTitulo:nAt][TIT_PREF],;
							   aTitulo[oTitulo:nAt][TIT_NUME],;
							   aTitulo[oTitulo:nAt][TIT_PARC],;
							   aTitulo[oTitulo:nAt][TIT_TIPO],;
							   aTitulo[oTitulo:nAt][TIT_VREA],;
							   Transform(aTitulo[oTitulo:nAt][TIT_VALO],cPicE1_Val),;
							   Transform(aTitulo[oTitulo:nAt][TIT_ACRS],cPicE1_Acr),;
							   Transform(aTitulo[oTitulo:nAt][TIT_MULT],cPicE1_Mul),;
							   Transform(aTitulo[oTitulo:nAt][TIT_JURO],cPicE1_Jur),;
							   Transform(aTitulo[oTitulo:nAt][TIT_DESC],cPicE1_Des),;
							   Transform(aTitulo[oTitulo:nAt][TIT_RECE],cPicE1_Val),;
							   aTitulo[oTitulo:nAt][TIT_DTBX]}}							   
	EndIf
	oTitulo:Disable()
	oTitulo:SetArray(aTitulo)
	oTitulo:aHeaders := aHeader
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamada para o LjRetEntra, que³
	//³analisa o retorno do PE       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTitulo:bLDblClick := {|| LjRetEntra(aTitulo,oTitulo,lLJDesBAlt),;
								nMulta   := aTitulo[oTitulo:nAt][TIT_MULT],;
								nJuros   := aTitulo[oTitulo:nAt][TIT_JURO],;
								nDescont := aTitulo[oTitulo:nAt][TIT_DESC],;
								nAcres := aTitulo[oTitulo:nAt][TIT_ACRS]  ,;								
								nValRec :=  IIf(cOper=="1", aTitulo[oTitulo:nAt][TIT_VALO] + nMulta + nJuros + nAcres - nDescont,;
											IIf(NMODULO=23, aTitulo[oTitulo:nAt][TIT_VLIQ], aTitulo[oTitulo:nAt][TIT_RECE]) ),;			
								LjAtuArray(nMulta, nJuros, nDescont, aTitulo[oTitulo:nAt][TIT_VALO] + nMulta + nJuros - nDescont),;
								aTitulo[oTitulo:nAt][TIT_RECE] :=  nValRec,;
								oMulta:Disable(),;
								oJuros:Disable(),;
								oDescont:Disable(),;
								oValRec:Disable(),;
								oMulta:Refresh(),;
								oJuros:Refresh(),;
								oDescont:Refresh(),;
								oValRec:Refresh(),;
								If(aTitulo[oTitulo:nAt][TIT_SELE], ;
								   (IIf(lLJDesBAlt,IIf(ExecBlock("LJBALTTI", .F., .F., { aTitulo , oTitulo:nAt }), oBtnEdit:Enable(), oBtnEdit:Disable()),;
								                   IIf(cOper=="1",oBtnEdit:Enable(),NIL)), oBtnAtu:Disable()),;
								(oBtnEdit:Disable(),;
									oBtnAtu:Disable()) )}

	oTitulo:bChange :=  {|| nMulta		:= aTitulo[oTitulo:nAt][TIT_MULT]									,;
							nJuros 		:= aTitulo[oTitulo:nAt][TIT_JURO]									,;
							nDescont	:= aTitulo[oTitulo:nAt][TIT_DESC]									,;
							nAcres      := aTitulo[oTitulo:nAt][TIT_ACRS]                                   ,;
							IIf(aTitulo[oTitulo:nAt][TIT_RECE] > 0											,;
								nValRec  := aTitulo[oTitulo:nAt][TIT_RECE]									,;
							    nValRec  := aTitulo[oTitulo:nAt][TIT_VALO] + nMulta + nJuros + nAcres - nDescont)  ,;
							LjAtuArray(nMulta, nJuros, nDescont, aTitulo[oTitulo:nAt][TIT_VALO] + nMulta + nJuros - nDescont),;
							oMulta:Disable()																,;
							oJuros:Disable()																,;
							oDescont:Disable()																,;
							oValRec:Disable()																,;
							oMulta:Refresh()																,;
							oJuros:Refresh()																,;
							oDescont:Refresh()																,;
							oValRec:Refresh()																,;
							If(aTitulo[oTitulo:nAt][TIT_SELE], ;
							   (IIf(lLJDesBAlt,IIf(ExecBlock("LJBALTTI", .F., .F., { aTitulo , oTitulo:nAt }),;
							   						 oBtnEdit:Enable(), oBtnEdit:Disable()),;
							                   	IIf(cOper=="1",oBtnEdit:Enable(),NIL)), oBtnAtu:Disable()),;
													(oBtnEdit:Disable(),;
							 						 oBtnAtu:Disable()) ) }

	@ 185,05 FOLDER oFolder SIZE 335,55 OF oDlg PROMPTS "&Dados dos títulos" PIXEL  //"&Dados dos títulos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Objetos do FOLDER  - Dados dos titulos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 05,15 SAY STR0021 SIZE 45,07 OF oFolder:aDialogs[1] PIXEL   //"+ Multa"
	@ 05,60 MSGET oMulta VAR nMulta SIZE 50, 9 OF oFolder:aDialogs[1] PIXEL PICTURE cPicE1_Mul VALID LJRecVal(nMulta, "M")
	oMulta:Disable()
	oMulta:bLostFocus := {|| nValRec := LjRcAtuObj(nMulta,"M",nValRec) }

	@ 20,15 SAY STR0022 SIZE 45,07 OF oFolder:aDialogs[1] PIXEL   //"+ Juros"
	@ 20,60 MSGET oJuros VAR nJuros SIZE 50, 9 OF oFolder:aDialogs[1] PIXEL PICTURE cPicE1_Jur VALID LJRecVal(nJuros, "J")
	oJuros:Disable()
	oJuros:bLostFocus := {|| nValRec := LjRcAtuObj(nJuros,"J",nValRec) }

	@ 05,125 SAY STR0023 SIZE 45,07 OF oFolder:aDialogs[1] PIXEL   //"- Descontos"
	@ 05,170 MSGET oDescont VAR nDescont SIZE 50, 9 OF oFolder:aDialogs[1] PIXEL PICTURE cPicE1_Des VALID LJRecVal(nDescont, "D" , cBxRec)
	oDescont:Disable()
	oDescont:bLostFocus := {|| nValRec := LjRcAtuObj(nDescont,"D",nValRec) }

	@ 20,125 SAY STR0024 SIZE 45,07 OF oFolder:aDialogs[1] PIXEL   //"= Valor Recebido"
 	@ 20,170 MSGET oValRec VAR nValRec SIZE 50, 9 OF oFolder:aDialogs[1] PIXEL Picture cPicE1_Val Valid LJRecVal(nValRec, "V" , cBxRec)

	oValRec:Disable()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Botao onde o usuario libera a edicao dos valores de encargos para os titulos    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SBUTTON oBtnEdit FROM 03,300 TYPE 11 OF oFolder:aDialogs[1] ACTION LjRecEdBt()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Botao onde o usuario confirma os encargos a ser aplicado no valor total         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SBUTTON oBtnAtu FROM 15,300 TYPE 13 OF oFolder:aDialogs[1] ACTION ;
			IIF(LojxRVld(cBxREc							, nDecE1Tam							, nDecE1Val						, @nValRec						,;
				 		 @nMulta						, @nJuros							, @nDescont						, oValRec						,;
				 		 oMulta							, oJuros							, oDescont						, aTitulo[oTitulo:nAt][TIT_SALD],;
				 		 aTitulo[oTitulo:nAt][TIT_MULT]	, aTitulo[oTitulo:nAt][TIT_JURO]	, aTitulo[oTitulo:nAt][TIT_DESC]),;
					 (aTitulo[oTitulo:nAt][TIT_MULT] :=  nMulta	,;
					 aTitulo[oTitulo:nAt][TIT_JURO] :=  nJuros	,;
					 aTitulo[oTitulo:nAt][TIT_DESC] :=  nDescont,;
					 aTitulo[oTitulo:nAt][TIT_RECE] :=  nValRec,;
					 IF( lLJDesBAlt , if ( ExecBlock( "LJBALTTI", .F., .F.,  { aTitulo , oTitulo:nAt } ), oBtnEdit:Enable(), oBtnEdit:Disable() ) ,oBtnEdit:Enable() ) ,;
					 oBtnAtu:Disable()	,;
					 oMulta:Disable()	,;
					 oJuros:Disable()	,;
					 oDescont:Disable()	,;
					 oValRec:Disable()	,;
		 			 nTotal:=0			,;
					 Aeval(aTitulo, {|x| If(x[TIT_SELE],nTotal+=x[TIT_RECE],Nil)}),;
					 oTotal:Refresh() 	), )

	DEFINE SBUTTON oBtnImprime FROM 28,300 TYPE 06 ENABLE OF oFolder:aDialogs[1] ACTION (LJBoleto(), oDlg:End()) ONSTOP STR0020  //"Imprimir Boleto..."

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se o ponto de entrada nao estiver compilado nao habilita o botao|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lLJImpBol
		oBtnImprime:Disable()
	EndIf

	oFonte := TFont():New('Arial',,16,,.T.)

	TSay():New(246,08, {|| STR0019 }, oDlg,,oFonte,,,,.T.,,,100,7,,,,,) //"Total do(s) Recebimento(s)"

	oTotal := TGet():New(246,120, {|u| If(PCount() > 0,nTotal := u, nTotal)}, oDlg,105,9,"@E 999,999,999.99",;
			  					/*[abValid]*/,CLR_HRED,/*[anClrBack]*/,oFonte,,,.T.,,,,,,/*[abChange]*/,.T.,,,"nTotal",,,,)
	oTotal:Disable()

	If cMV_LJRECEB == "1"	// Financeiro
		DEFINE SBUTTON oBtnLeg FROM 265,250 TYPE 05 ONSTOP STR0174 ENABLE OF oDlg ACTION LjLegend()		//"Legenda"
		oBtnLeg:cCaption := STR0174		//"Legenda"
	EndIf

	DEFINE SBUTTON oBtnOk FROM 265,280 TYPE 01 OF oDlg ACTION (lTelaOk := .T., IIf(LjRecBtnOK(@aRet,.T.,cRecibo,cSerieRec),oDlg:End(),NIL))
	DEFINE SBUTTON FROM 265,310 TYPE 02 ENABLE OF oDlg ACTION (lTelaOk := .F., IIF(LjLimpaTit(lTelaOk),oDlg:End(), NIL))


    // Desabilita a tecla ESC
	oDlg:LESCCLOSE := .F.

ACTIVATE MSDIALOG oDlg CENTERED VALID LjLimpaTit(lTelaOk)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Estas variaveis contem, respectivamente, o numero do cartao, cpf ou contrato, informados na tela de recebimentos   |
//| no LOJXREC.                                                                                                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRecCart := cCartao
cRecCPF	:=	cCPF
cRecCont := cNum

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Atualizando as variavreis que serao utilizadas na analise de credito apos efetuar o recebimento de titulos |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCCodcli := cCodCli
cCLojCli := cLojCli
cLojaCli := cLojCli

lRecebNFCE   := nil								//Controle de Performance - função LjModNFis()

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³ LJRecVal ³ Autor ³ Cesar Eduardo Valadao ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos valores digitados                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJRecVal( nVal, cTipo , cTpBxRec)
Local lLJRECVLD	:= ExistBlock("LJRECVLD")	// Verifica a existencia do Ponto de Entrada
Local xRet 										// Retorno do Ponto de Entrada
Local lRet			:= .T.							// Retorno da funcao
Local lContinua	:= .T.							// Valida se continua o processo de validação
Local nPos			:= 0							// Posicao do array aValores

Default cTpBxRec := SuperGetMV("MV_VLBXREC",, "1")


// Procura no array a Valores a posicao "D" de desconto
If cTipo == "D"
	nPos := AScan( aValores, {|x| x[2] == cTipo} )
Endif

// Valida se Valor do Desconto nao e maior que o valor do Titulo
If (cTipo == "V" .AND. (nMulta+nJuros-nDescont) > nValRec) .OR. (cTipo == "D" .AND. (aTitulo[oTitulo:nAt][TIT_SALD]+nmulta+njuros - nval) <= 0)
	If cTpBxRec == "2"

		lContinua := MsgYesNo(STR0160 + CRLF + STR0161)//"Atenção ! O valor recebido é menor que a soma dos valores de juros, multa e desconto." ## "Deseja confirmar a baixa?"

	ElseIf cTpBxRec == "3"

		MsgAlert(STR0160 + CRLF + STR0162)  //"Atenção ! O valor recebido é menor que a soma dos valores de juros, multa e desconto." + CRLF + "Favor modificar os valores."
		lContinua := .F.
	EndIf

	lRet := lContinua

	If !lContinua
		nValRec := 0
		lRet := .F.
	EndIf
EndIf

If lRet .AND. lLJRECVLD
	xRet := ExecBlock("LJRECVLD",.F.,.F., { cTipo , nVal , aTitulo, oTitulo })
	If ValType (xRet) == "L"
		lRet := xRet
	Endif
Endif

If lRet .AND. nVal < 0
	Help(" ",1,"VALNEGAT")
	lRet := .F.
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LJRecPesq ³ Autor ³ Cesar Eduardo Valadao ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJRecPesq( oNomeCli, cNomeCli, cCodCli, cLojaCli, cSerieRec, cRecibo,oSerieRec,oRecibo, lViaTela,cSeek,oSeek )

Local aRet
Local nI												// Controle de loop
Local nJ												// Controle de loop
Local lRet        	:= .T.								// Retorno de funcao
Local lError      	:= .F.								// Controla se falta alguma informacao
Local aEMSHeader
Local aEMSContra
Local cMV_LJTPREC										// Conteudo do parametro MV_LJTPREC, que identifica os prefixos validos para recebimento
Local nRegValidos 	:= 0								// Quantidade de titulos cujos prefixos sao validos
Local cCliente 	  	:= Space(TamSx3("A1_COD")[1])      // Codigo do cliente
Local cLoja		  	:= Space(TamSx3("A1_LOJA")[1])     // Loja do cliente
Local aRegsSA1		:= {}								// Registro dos clientes pesquisados no SA1
Local lContinua		:= .F.								// Indica se continua ou não o processamento
Local lAtuCodCli    := .T.                             // Define se atualiza codigo do cliente com base no cartao/CPF/CNPJ
Local cPesqSA1		:= ""								// Chave de pesquisa na SA1
Local cIndSA1		:= ""								// Indice para pesquisa na SA1
Local aClientes		:= {}								// Array com os clientes encontrados
Local nX			:= 0								// Contador do For
Local nFor			:= 0 								// Contador do For
Local aCGCs			:= {} 								// Array com os CPFs processados
Local aCliTit		:= {}								// Array com os clientes selecionados
Local lMultCli		:= SuperGetMV("MV_LJMLTRC", NIL, .F.) 	// Parametro para habilitar o recebimento de titulos de diversos clientes
Local cCliBkp		:= cCodCli							// Armazena o cod. do cliente inicial
Local cLojBkp		:= cLojaCli 						// Armazena loja do cliente inicial
Local nLenRetCli	:= 0								// Informa o tamanho do array de selecao de clientes

Default lViaTela	:= .T.
Default cSeek		:= ""
Default oSeek		:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MV_LJFSEMA                                       ³
//³0 - Nao calcula juros para sabado e domingo      ³
//³1 - Calcula juros somente para o sabado          ³
//³2 - Calcula juros somente para o domingo         ³
//³3 - Calcula juros para sabado e domingo          ³
//³4 - Calcula juros para sab., dom. e feriados     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera as variaveis quando eh executado um novo³
//³pesquisar cliente                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Informa que é Recebimento ()
cOper := "1"
aValores  := {}
nCloneRec := 0
cNomeCli := ''

If cMV_LJRECEB == "1"
	If Empty(cCodCli) .AND. Empty(cCPF)
	    //"Campos necessários não preenchidos", "É necessário informar o código do cliente ou o CNPJ/CPF.", "Ok"
		Aviso(STR0025, STR0133, {STR0003})
		lError := .T.
	Endif
ElseIf cMV_LJRECEB $ "3,4"
	If Empty(cCartao) .AND. Empty(cCPF) .AND. Empty(cNum)
	    //"Campos necessários não preenchidos", "É necessário informar o número do cartão o CNPJ/CPF ou o número do contrato.", "Ok"
		Aviso(STR0025, STR0027, {STR0003})
		lError := .T.
	Endif
Endif

If cMV_LJRECEB == "1"
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para pesquisa sem a loja do cliente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cLojCli)
		cIndSA1 := "SA1->A1_FILIAL + SA1->A1_COD"
		cPesqSA1 := xFilial("SA1")+ cCodCli
	Else
		cIndSA1 := "SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA"
		cPesqSA1 := xFilial("SA1")+ cCodCli + cLojCli
	EndIf

	If !(SA1->(DbSeek(cPesqSA1,.T.)))	
	 	//³ Pesquisa o cliente via WS no RETAGUARDA. Se encontrar inclui o cliente no PDV                              ³
	 	if !Empty(cCPF) 
	 		aRegsSA1:= CRDCliR2Pdv( cCartao, cCPF, NIL, NIL, cNum )
	 		if Len( aRegsSA1 ) > 0 .and. ValType(aRegsSA1) == "A"	
	 			nPos := aScan(aRegsSA1[1],{|x| AllTrim(x[1]) == "A1_COD"})
				If nPos > 0
			   		cPesqSA1 := xFilial("SA1")+ aRegsSA1[1][nPos][2] 
			   		nPos := aScan(aRegsSA1[1],{|x| AllTrim(x[1]) == "A1_LOJA"})
			   		cPesqSA1 += aRegsSA1[1][nPos][2]
					cIndSA1 := "SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA"
					LjGrvLog("Recebimento_Titulo", "consulta WS para Inclusão do cliente no PDV ",cCPF)
				else
			   		Aviso("Erro ao encontrar cliente", "Verifique o cadastro do cliente",{"OK"})
					lError := .T.
				EndIf
			else
			 	Aviso(STR0189, STR0190,{STR0003}) //"Cliente não encontrado" - "Verifique se as configurações para consulta estão habilitadas corretamente. (Ex.: SigaCRD/WebService)"
				Return .F.
			EndIf     
	 	EndIf		
	EndIf
	
	If SA1->(DbSeek(cPesqSA1,.T.))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta array com os clientes encontrados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aClientes := {}

		While SA1->(!Eof()) .AND. (&(cIndSA1) == cPesqSA1)
			//Preenche a primeira posição pois somente permitirá que cliente com CNPJ/CPF cadastrado efetue a pesquisa
			If !Empty(SA1->A1_CGC) .OR. (Empty(SA1->A1_CGC) .AND. SA1->A1_TIPO == 'X')  // Caso cliente externo nao exige CPF/CNPJ
				Aadd(aClientes,{ IIF(Empty(AllTrim(SA1->A1_CGC)) ,.F., .T.),SA1->A1_FILIAL ,SA1->A1_COD,SA1->A1_LOJA,SA1->A1_CGC, "", cNum, SA1->A1_TIPO})
			EndIf
			SA1->( DbSkip() )
		End
		LjGrvLog("Recebimento_Titulo", " Alimentando o ARRAY de clientes com o retorno do SEEK ",aClientes)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para cada cliente encontrado, valida CPF/CNPJ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:= 1 to Len(aClientes)

		cCPF    := aClientes[nX][5]
		cCartao := LjRecSeekCart(aClientes[nX][3] , aClientes[nX][4])
		aClientes[nX][6] := cCartao
		cNum	:= aClientes[nX][7]

		If Empty(aClientes[nX][6]) .AND. (Empty(aClientes[nX][5]) .AND. aClientes[nX][8] <> 'X')

			Aviso(STR0025, STR0105, {STR0003})		//"Campos necessários não preenchidos", "O cliente selecionado deve ter CNPJ/CPF cadastrado ou um cartao ativo.", "Ok"
			lError := .T.
			Exit

		EndIf

	Next nX

	//Caso nao localize nenhum cliente com CPF, emite aviso padrao
	If !lError .AND. Len(aClientes) == 0
		Aviso(STR0025, STR0105, {STR0003})		//"Campos necessários não preenchidos", "O cliente selecionado deve ter CNPJ/CPF cadastrado ou um cartao ativo.", "Ok"
		lError := .T.
	EndIf
ElseIf cMV_LJRECEB $ "3,4"  .AND. !lError
	Aadd(aClientes,{.T.,"","","",cCPF,cCartao,cNum,""})
Endif

If lError .AND. lViaTela
	oBtnOk:Disable()
	If cMV_LJRECEB == "1" // Financeiro
		oCodCli:SetFocus()
	ElseIf cMV_LJRECEB == "2" // Gestao Educacional
		oNumRA:SetFocus()
	ElseIf cMV_LJRECEB $ "3,4" // Fidelizacao e Analise de Credito / EMS
		oCartao:SetFocus()
	Endif

	oTitulo:Disable()
	Return NIL
Endif

If cPaisLoc == "MEX" .AND. Empty(cCodCli + cLojCli)
	Aadd(aClientes,{.T.,"","","","","","",""})
EndIf

If !lAddTitulos
	aTitulo := {aTitVazio}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o array para busca dos titulos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:= 1 to Len(aClientes)

	If aClientes[nX][1] .OR. aClientes[nX][8] == 'X' //Valida a posição 1 do array, se o cliente tem um cpf ou eh Externo

		cCliBkp := cCodCli
		cLojBkp := cLojCli

		cCodCli := aClientes[nX][3]
		cLojCli := aClientes[nX][4]
		cCPF	:= aClientes[nX][5]
		cCartao := aClientes[nX][6]
		cNum	:= aClientes[nX][7]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foi processado o CPF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aCGCs,cCPF) > 0
			Loop
		Else
		 	aADD(aCGCs,cCPF)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa o cliente para ver se ha' mais de uma ocorrencia da mesma busca, ³
		//³ como 2 clientes diferentes com o mesmo CPF.                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRegsSA1 := CRDCliR2Pdv( cCartao, cCPF, NIL, NIL, cNum, NIL, NIL,  cCodCli, cLojCli,  aClientes[nX][8] )

		If cPaisLoc == "MEX"
		   lAtuCodCli  := Empty(cCodCli + cLojCli)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se foi encontrado mais de um cliente. Mostra uma tela para o usuario ³
		//³ escolher qual o cliente ele quer pesquisar. Se houver apenas 1 registro     ³
		//³ verifica se a variavel esta' com conteudo e define as variaveis cCliente e  ³
		//³ cLojaCli.                                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtuCodCli .AND. lViaTela

			If Len( aRegsSA1 ) >= 2

				aRetCli := CRDxTelaCl( aRegsSA1 )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona os cliente selecionados no array para busca do titulo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType( aRetCli ) == "A" .AND. Len(aRetCli) > 0

					nLenRetCli := Iif(lMultCli,Len(aRetCli),1)

					For nFor := 1 to nLenRetCli

						cCodCli 	:= Iif(lMultCli,aRetCli[nFor][1],aRetCli[1])
						cLojCli 	:= Iif(lMultCli,aRetCli[nFor][2],aRetCli[2])

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Tratamento para caso cancelar a selecao de clientes e informou a loja ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(cCodCli)
							cCodCli 	:= cCliBkp
							cLojCli 	:= cLojBkp
						EndIf

						If !Empty(cCodCli)

							aADD( aCliTit, 	{	aClientes[nX][1]	,; 		// Contem CPF
												aClientes[nX][2]	,;		// Filial
												cCodCli				,;		// Cod. do cliente
												cLojCli				,;		// Loja do cliente
												aClientes[nX][5]	,;		// CPF
												aClientes[nX][6]	,;		// Cartao
												cNum				,;		// Numero
												aClientes[nX][8]	})		// Tipo

						EndIf

					Next nFor

					If Len(aCliTit) > 0
						lContinua	:= .T.
					Else
						lContinua	:= .F.
						aRetCli		:= {}
						Loop
					EndIf

				Else
					lContinua := .F.
					Loop
				EndIf

			ElseIf Len( aRegsSA1 ) == 1

				nPosTmp := aScan( aRegsSA1[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_COD" } )

				If nPosTmp > 0
					cCodCli := aRegsSA1[1][nPosTmp][2]
				Else
					cCodCli := ""
				Endif

				nPosTmp := aScan( aRegsSA1[1], { |x| Alltrim( Upper ( x[1] ) ) == "A1_LOJA" } )
				If nPosTmp > 0
					cLojCli := aRegsSA1[1][nPosTmp][2]
				Else
					cLojCli := ""
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona os cliente selecionados no array para processamento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aADD( aCliTit	, { aClientes[nX][1]	,; 		// Contem CPF
							   		aClientes[nX][2]	,;		// Filial
									cCodCli				,;		// Cod. do cliente
									cLojCli				,;		// Loja do cliente
									aClientes[nX][5]	,;		// CPF
									aClientes[nX][6]	,;		// Cartao
									aClientes[nX][7] 	,;		// Numero
									aClientes[nX][8]	})		// Tipo

				If !Empty( cCodCli + cLojCli )
					lContinua := .T.
				Endif
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se nao encontrou o cliente nao continua o processamento         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCliente := ""
				cLojaCli := ""
				lContinua := .F.
				Loop
			Endif
		Else
			lContinua := .T.
		EndIf
	EndIf
Next nX

If !lContinua
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array conforme os clientes selecionados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lViaTela
	aClientes := aClone(aCliTit)
EndIf

LjGrvLog("RECEBIMENTO","Tipo de recebimento de titulos",cMV_LJRECEB)
LjGrvLog("RECEBIMENTO","Clientes a serem pesquisados",aClientes)

For nX:= 1 to Len(aClientes)

	If aClientes[nX][1] .OR. aClientes[nX][8] == 'X'
		cCodCli := aClientes[nX][3]
		cLojCli := aClientes[nX][4]
		cCPF	:= aClientes[nX][5]
		cCartao	:= aClientes[nX][6]
		cNum	:= aClientes[nX][7]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ EMS - Eletronic Market Solution ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMV_LJRECEB == "4" .AND. lViaTela
			lRet := LJEMSExtra(cCartao, cCPF, @aEMSHeader, @aEMSContra)

			If lRet
				aRet := {0, "", "", {}}
				For nI := 1 To aEMSHeader[5]
					For nJ := 1 To aEMSContra[nI][1][8]
						AAdd(aRet[4], { .F.                     , aEMSContra[nI][1][1]    , aEMSContra[nI][1][2]+"-"+aEMSContra[nI][1][3], ;
										aEMSContra[nI][2][nJ][1], aEMSContra[nI][2][nJ][2], aEMSContra[nI][2][nJ][3]                     , ;
										aEMSContra[nI][2][nJ][6], 0                       , aEMSContra[nI][2][nJ][7]                     , ;
										aEMSContra[nI][2][nJ][8], "CC" })
					Next nJ
				Next nI
			Endif

			If !lRet
				lContinua := .F.
				Return Nil
			Endif

			If Len(aTitulo) > 0 .AND. Empty(aTitulo[1][TIT_NUME])
				aTitulo := {}
			EndIf

            If LjRecVerTit(aTitulo,aRet[4])
				AAdd(aTitulo , aClone(aRet[4]))
			EndIf


		Else
			If nModulo == 23 .OR. (nModulo == 12 .AND. lMvLjPdvPa)
				oSvc      := WSLJRECEB():New()
                iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
				oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"

				//"Aguarde... Pesquisando Títulos em aberto..."
				LJMsgRun(STR0028,, {|oDlg| lRet := oSvc:GetTitulo(	cMV_LJRECEB,	cCodCli,	cLojCli,	cCPF,;
																	cCartao,		cNumRA,		cPrefixo,	cNum,;
																	cParcela, 		cEmpAnt,    cFilAnt,    lMvLjPdvPa )})
				If !lRet
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|*** Aqui devera ser melhor tratado as mensagens de erro...        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSvcError := GetWSCError()
					If Left(cSvcError,9) == "WSCERR048"
						cSoapFCode  := GetWSCError(2)
						cSoapFDescr := GetWSCError(3)
						MsgStop(cSoapFDescr, cSoapFCode)
					Else
						//"Sem comunicação com o WebService!", "Atenção!"
						MsgStop(STR0029,STR0030)
					EndIf

					lContinua := .F.
					Return Nil
				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//| Verificar se esta usando o fidelizacao e analise de creditos Microsiga|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cMV_LJRECEB == "3"

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Parametro que identifica os prefixos validos para o recebimento|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    	cMV_LJTPREC := SuperGetMV("MV_LJTPREC", NIL, "")

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Encontrar o numero de registros validos|
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    nRegValidos := 0
						For nI := 1 To Len(oSvc:oWSGetTituloResult:oWSWSTitulo)
							If Alltrim(oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cTipo) $ cMV_LJTPREC .OR. Empty(cMV_LJTPREC)
								nRegValidos ++
							Endif
						Next nI

						aRet := {0, "", "", Array(nRegValidos)}

						nRegValidos := 0

						For nI := 1 To Len(oSvc:oWSGetTituloResult:oWSWSTitulo)
							If Alltrim(oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cTipo) $ cMV_LJTPREC .OR. Empty(cMV_LJTPREC)
								nRegValidos ++

								aRet[4][nRegValidos] := { .F.,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cPrefixo,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cNumTitulo,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cParcela,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:dVencimento,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValor,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrMulta,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrJuros,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrDesconto,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrRecebido,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cTipo,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cContrato,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cCliente,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cLoja,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cFilTit,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nNumRecno, ;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrAcres, ;
								.F.                                              , ;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValAbat,  ;
								"",;
								"",;
								"",;
								"",;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:dDtBaixa 	,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nSaldo		,;
								oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValLiq		}

								cCliente 	:= oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cCliente
								cLoja		:= oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cLoja

								If Len(aTitulo) > 0 .AND. Empty(aTitulo[1][TIT_NUME])
									aTitulo := {}
								EndIf

                            	If LjRecVerTit(aTitulo,aRet[4][nRegValidos])
									AAdd(aTitulo , aClone(aRet[4][nRegValidos]))
								EndIf
							EndIf
						Next nI
					Else
						aRet := {0, "", "", Array(Len(oSvc:oWSGetTituloResult:oWSWSTitulo))}
						For nI := 1 To Len(oSvc:oWSGetTituloResult:oWSWSTitulo)
							aRet[4][nI] := { .F.,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cPrefixo,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cNumTitulo,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cParcela,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:dVencimento,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValor,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrMulta,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrJuros,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrDesconto,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrRecebido,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cTipo,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cContrato,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cCliente,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cLoja,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cFilTit,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nNumRecno, ;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrAcres, ;
							.F.                                              , ;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValAbat, ;
							"", ;
							"",	;
							"", ;
							"",	;
					 		oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:dDtBaixa	,;
					 		oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nSaldo		,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValLiq		}

							cCliente 	:= oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cCliente
							cLoja		:= oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cLoja

							If Len(aTitulo) > 0 .AND. Empty(aTitulo[1][TIT_NUME])
								aTitulo := {}
							EndIf

                            If LjRecVerTit(aTitulo,aRet[4][nI])
								AAdd(aTitulo , aClone(aRet[4][nI]))
							EndIf
						Next nI
					EndIf
				EndIf
			Else
			    cOper    := "1"

				If !lAddTitulos
					nTotal   := 0
					nMulta   := 0
					nJuros   := 0
					nDescont := 0
					nAcres	 := 0
					nValRec  := 0
				EndIf

				//"Aguarde... Pesquisando Títulos em aberto..."
				LJMsgRun(STR0028,, {|oDlg| aRet := LJRecLoad(	cMV_LJRECEB,	cCodCli,	cLojCli,	cCPF,;
																cCartao,		cNumRA,		cPrefixo,	cNum,;
																cParcela )})
				If Len(aRet[4]) > 0
					If Len(aTitulo) > 0 .AND. Empty(aTitulo[1][TIT_NUME])
						aTitulo := {}
					EndIf

					For nI := 1 To Len(aRet[4])
						ASize(aRet[4][nI], Len(aRet[4][nI])+1)
						AIns(aRet[4][nI], 1)
						aRet[4][nI][1] := .F.

						If LjRecVerTit(aTitulo,aRet[4][nI])
							AAdd(aTitulo , aClone(aRet[4][nI]))
						EndIf
					Next nI
				Endif
			Endif
		Endif
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para tratar a pesquisa dos³
//³titulos em aberto do cliente               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLJRECVER
	aTitulo := ExecBlock( "LJRECVER" ,.F.,.F.,{aTitulo} )
ElseIf ExistFunc("LjxRecver")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se trabalhar com o conceito de acrescimo separado, ³
	//³altera os titulos de financiamento com acrescimo   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTitulo := LjxRecver(aTitulo)
EndIf

If lViaTela
	oTitulo:aArray := aTitulo
	If aRet[1] == 0 .AND. (Len(aRet[4]) > 0 .OR. (Len(aClientes) > 1 .AND. Len(aTitulo) > 0))

		If Len(aClientes) > 1
			cCodCli		:= aClientes[1][3]
			cLojaCli	:= ""
			cNomeCli	:= ""
			cLojCli		:= Space(TamSx3("A1_LOJA")[1])
		Else
			cNomeCli := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_NOME")
			cCodCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_COD")
			cLojaCli := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_LOJA")
		EndIf

		oNomeCli:Refresh()

		oBtnOk:Enable()
		oTitulo:Enable()
		oTitulo:SetFocus()
		If cPaisLoc == "ARG"
			cSerieRec:= "X  "
			cRecibo  := LojxNxtRec()
			oSerieRec:Refresh()
			oRecibo  :Refresh()
		Endif
		oBtnEdit:Disable()
	ElseIf !lAddTitulos
		oBtnOk:Disable()
		If cMV_LJRECEB == "1" // Financeiro
			oCodCli:SetFocus()
		ElseIf cMV_LJRECEB == "2" // Gestao Educacional
			oNumRA:SetFocus()
		ElseIf cMV_LJRECEB $ "3,4" // Fidelizacao e Analise de Credito / EMS
			oCartao:SetFocus()
		Endif

		If ValType(cSeek) <> "U"
			cSeek := Space(110)
			If ValType(oSeek) <> "U"
				oSeek:Refresh()
			EndIf
		EndIf

		oTitulo:Disable()
	Endif

	//Atualiza a PICTURE do campo CPF/CNPJ
	LjPicCPFCNPJ( @cCpf, @cCPFTemp )
Endif

If lAddTitulos
	lAddTitulos := .F.
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LJRecLoad ³ Autor ³ Cesar Eduardo Valadao ³ Data ³26/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega os titulos a receber validos para recebimento       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJRecLoad( cMV_LJRECEB	, cCodCli, cLojCli	, cCPF,;
 				    cCartao		, cNumRA , cPrefixo	, cNum,;
				    cParcela 	, nRecno , dDataRef , cPDV,;
				    cUsrCaixa )

Local cChaveSE1		:= ""                              		// Chave de pesquisa no SE1
Local aRet			:= {0, "", "", {}}
Local cMVLJTPREC	:= SuperGetMV("MV_LJTPREC",,"")   		// Tipo de titulos validos para o recebimento
Local lRecFilial	:= SuperGetMV("MV_LJRECFI",,.F. ) 		// Controla se trata todas as filiais(Logico)
Local aFiliais		:= {} 					                // Armazena todas as filiais da empresa corrente
Local nX			:= 0                              		// Controle de loop
Local aFeriados		:= {}  								    // Armazena os feriados cadastrados
Local nValMulta		:= 0                              		// Valor da multa
Local nValJuros		:= 0                              		// Valor dos juros
Local nDias			:= 0                               		// Quantidade de dias para calculo dos juros
Local nMV_LJMULTA	:= SuperGetMV("MV_LJMULTA", NIL, 0)    // Percentual de multa para os titulos em atraso
Local nMV_LJJUROS	:= SuperGetMV("MV_LJJUROS", NIL, 0)    // Percentual de juros por dia para os titulos em atraso
Local dBase			:= {}									// Data base para calculo dos juros
Local cUsaFDS		:= SuperGetMV("MV_LJFSEMA", NIL, "0")	// Usa final de semana para calculo de juros
Local cTipoTit		:= "" 									// Tipos de titulos que nao podem ser recebidos por esta rotina
Local lLjRecFilt	:= ExistBlock("LJRECFILT")          	// Verifica se PE LJRECFILT existe
Local lBxParcial	:= .F.						    		// Verifica se houve baixa parcial para alterar a data de apuracao de juros
Local lLjValDesc	:= ExistFunc( "U_LJVALDESC" )		// Verifica se existe o PE para fazer o calculo do desconto
Local uRet													// Retorno do PE LJVALDESC
Local lMV_LJCALJM   := SuperGetMV("MV_LJCALJM", NIL, .F.)  // Define se calcula juros e multa dos titulos a receber
Local nValAbat      := 0                                    // Valor dos Abatimentos do titulo
Local lMV_LJRCABT   := SuperGetMV("MV_LJRCABT", NIL, .F.)   // Considera os Abatimentos a ser Recebido do titulo
Local cRecLock      := ""                                   // Controle do registro se esta sendo usado
Local lMV_LJSITTI   := SuperGetMV("MV_LJSITTI",,.F. )       // O parametro MV_LJSITTI indica se apresenta ou nao os titulos dependendo da sua situacao (E1_SITUACA)
Local cMVJurTipo	:= SuperGetMV("MV_JURTIPO",,"")         //Tipo de calculo de Juros do Financeiro
Local lMV_LJJUFIN   := SuperGetMV("MV_LJJUFIN",,.F. )      //Indica se o calculo de juros e multa, obedece a regra do modulo financeiro
Local lAcresVlTit	:= .F.									//Considera acrescimo no valor do título?
Local lMvLjIntFS 	:= SuperGetMv("MV_LJINTFS",,.F.) 		//Integracao com o Financial
Local nMvTxPer	 	:= SuperGetMV("MV_TXPER",,0)            //Taxa de Permanencia
Local nMvLjJuros 	:= SuperGetMv("MV_LJJUROS",,0)          //Taxa de Juros do Loja
Local cMVLjIFSJu 	:= SuperGetMV("MV_LJIFSJU", ,"")        //Tipo de Calculo de Juros do Sistema Externo (Financial)
Local nE1Desc		:= 0									// Desconto do Titulo
Local cIndE1		:= ""
Local cCondE1		:= ""
Local cPesqE1		:= ""
Local lSA1Exc  		:= FWModeAccess("SA1",3)== "E"			// Verifica se SA1 é excluiva
Local lListCli 		:= .T.									// Validação para mostrar os titulos quando SA1 for exclusivo
Local nEstorCX  	:= SuperGetMv("MV_LJESTCX",,1)			//Permite realizar o estorno de titulos recebidos em caixas diferentes
Local cAliasSE5		:=  ""
Local cQuery		:= ""
Local lAchouSE5		:= .F.
Local lMultNegoc    := SuperGetMv("MV_LJMULTN",,.F.)
Local cMNtolPg		:= SuperGetMv("MV_LJMNTPG",,"")  		// Tolerancia para o desconto Regrecivo para as parcelas da Multi-Negociacao
Local nDiasAtraz	:= 0									// Dias de atrazo das parcelas da Multi-negociacao
Local aMNTolPG		:= {}									// Array usado para montar as tolerancias de dias para tolerancia dos desconto
Local cMNPTPg		:= ""									// String com a porcetagem de Tolerancia de desconto para a Multi-Negociacao
Local lE1NUMCRD		:= SE1->( FieldPos("E1_NUMCRD") ) > 0
Local lMvArrefat	:= SuperGetMV("MV_ARREFAT",, "S") == "S"	//indica se o valor será arredondado ou nao
Local nValReceb     := 0    //Valor Recebido E1 no Estorno
Local lTotvsPDV 	:= IsInCallStack("STRECLOAD") 			//verifica se o LOJXREC foi chamado pelo TOTVS PDV 
Local nDescFin		:= 0 									// E1_DESCFIN
Local lDescFin 		:= .F.									//Se houve aplicação de E1_DESCFIN para ser utilizado no cálculo de baixas parciais em E5_DESCTO
Local nE1Multa 		:= 0									//Multa após cálculo de multa em baixas parciais da SE5
Local nE1Juros		:= 0									//Juros após cálculo de multa em baixas parciais da SE5
Local nE1Desct 		:= 0									//Desconto após cálculo de multa em baixas parciais da SE5 SE não aplicado o E1_DESCFIN

DEFAULT nRecno		:= 0  									// Recno do registro da tabela SE1
DEFAULT dDataRef	:= dDatabase			 				// Data de referencia para o calculo de juros, se nao for passada assume a database
DEFAULT cPDV 		:= ""									// Codigo da Estcao (PDV)
DEFAULT cUsrCaixa	:= ""									// Codigo do Usuario Caixa

//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Inicio
/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso esteja habilitada a integração do Protheus com o Financial³
//³Service, os parametros MV_TXPER e MV_LJLJUROS devem            ³
//³ser iguais para prosseguir com o recebimento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
If lMvLjIntFS
	If nMvTxPer <> nMvLjJuros

		Return({1, STR0001 ,STR0157 , {}}) //"Uso indevido na função de recebimentos"#"Necessário que os parâmetros de percentual de juros por dia para os títulos em atraso do Loja (MV_LJJUROS) e o de taxa de permanência diária do Contas a Receber gerado pelo Faturamento (MV_TXPER) estejam com conteúdo iguais, caso esteja habilitada a integração com o Financial Services"
	Else
		If !lMV_LJJUFIN
			Return({1, STR0001 , STR0158, {}}) //"Uso indevido na função de recebimentos"#"Necessário que o parâmetro que indica a realização de cálculo de juros pela regra do financeiro (MV_LJJUFIN) esteja habilitado na retaguarda, caso esteja habilitada a integração com o Financial Services."
		Else
			If !Empty(cMVJurTipo) .AND. cMVLjIFSJu <> cMVJurTipo
				Return({1, STR0001 , STR0159, {}})//"Uso indevido na função de recebimentos"# "Necessário que os parâmetros que indicam o tipo de cálculo de juros dos títulos a receber do sistema externo (MV_LJIFSJU) e do ERP (MV_JURTIPO) estejam com conteúdos iguais na retaguarda, caso esteja habilitada a integração com o Financial Services."
			EndIf
		EndIf
	EndIf
EndIf

lMV_LJJUFIN := lMV_LJJUFIN  .AND. cMVJurTipo <> "L"  //forma de calculo do financeiro
//Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Final

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o SE1 estah compartilhado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( xFilial("SE1") )
	aFiliais := { xFilial("SE1") }
Else
	aFiliais := LjFilVal(Nil, "SE1") // Armazena todas as filiais da empresa corrente
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estes tipos de titulos nao podem ser recebidos por esta rotina e     ³
//³ deverao ser compensados no financeiro. Esta rotina tem a finalidade  ³
//³ de receber titulos de vendas a credito e nao de fazer o papel do     ³
//³ financeiro (FINA100).                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTipoTit := "CH|CC|CD|VA|NCC"

LjGrvLog("RECEBIMENTO","Tipo de recebimento de titulos",cMV_LJRECEB)
LjGrvLog("RECEBIMENTO","Cod Cliente + Loja",cCodCli+" LOJA:"+cLojCli)
LjGrvLog("RECEBIMENTO","CPF informado ",cCPF)
LjGrvLog("RECEBIMENTO","Cartao informado ",cCartao)
LjGrvLog("RECEBIMENTO","Contrato informado ",cNumRA)
LjGrvLog("RECEBIMENTO","Prefixo informado ",cPrefixo)
LjGrvLog("RECEBIMENTO","Numero do titulo : ",cNum)
LjGrvLog("RECEBIMENTO","PDV :",cPDV)

If cMV_LJRECEB == "1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Financeiro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cPrefixo)
		cChaveSE1 := cPrefixo
		If !Empty(cNum)
			cChaveSE1 += cNum
			If !Empty(cParcela)
				cChaveSE1 += cParcela
			Endif
		Endif
	Endif

	DbSelectArea("SA1")
	If Empty(cCodCli)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a validade do CNPJ/CPF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA1->(DbSetOrder(3))
		If !Empty(cCPF) .AND. SA1->(DbSeek(xFilial("SA1")+AllTrim(cCPF)))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Incluir a tela para posicionar no cliente, caso o mesmo possuir mais de uma cadastro na base    ³
			//³Alimentar as variaveis 'cCodCli' e 'cLojCli'de acordo com o cliente selecionado.                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodCli := SA1->A1_COD
			cLojCli := SA1->A1_LOJA
		Elseif !IsInCallStack("STRECLOAD") // Somente se Totvs Pdv, não há obrigatoriedade de CPF -> não entra neste Elseif
		    //"CNPJ/CPF nao encontrado", "O CNPJ/CPF informado nao foi encontrado."
			Return({1, STR0114 , STR0115, {}})
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a validade do Cliente/Loja ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
		    //"Cliente nao encontrado", "O codigo do cliente informado nao foi encontrado."
			Return({1, STR0033, STR0034, {}})
		Endif
	Endif

	DbSelectArea("SE1")

	If !lRecFilial

		If Empty(cCpf) .AND. IsInCallStack("STRECLOAD")	// Somente se Totvs Pdv, não há obrigatoriedade de CPF
			cCondE1:= "SE1->E1_FILIAL"
			cIndE1 := xFilial("SE1")+cChaveSE1
			SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		Else
			cCondE1:= "SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA"
			cIndE1 := xFilial("SE1")+cCodCli+cLojCli+cChaveSE1
			SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		EndIf
		cPesqE1:= xFilial("SE1")+cCodCli+cLojCli
		
		LjGrvLog("RECEBIMENTO","Chave de Busca",cIndE1)
		LjGrvLog("RECEBIMENTO","Condição de Busca :",cPesqE1)
		
		

		SE1->(DbSeek(cIndE1))
		While SE1->(!EOF()) .AND. ( &(cCondE1) == cPesqE1 ) .AND.;
			If(!Empty(cPrefixo), E1_PREFIXO==cPrefixo, .T.) .AND.;
			If(!Empty(cNum), E1_NUM==cNum, .T.) .AND.;
			If(!Empty(cParcela), E1_PARCELA==cParcela, .T.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estes titulos nao podem ser recebidos, devem ser compensados no Financeiro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(E1_TIPO) $ cTipoTit
				SE1->(dbSkip())
				Loop
			Endif

			If IIf(lLjRecFilt,ExecBlock("LJRECFILT",.F.,.F.,{cOper,cPDV,cUsrCaixa}),.F.)
			   SE1->(DbSkip())
			   Loop
			Endif

			If lMV_LJSITTI
				If !(SE1->E1_SITUACA $ "0FG")
					SE1->(dbSkip())
					Loop
				Endif
			EndIf

			If IIf(cOper == "1",E1_SALDO > 0,(E1_SALDO < E1_VALOR .OR. !Empty(E1_BAIXA) ))
				If ALLTRIM(E1_TIPO)$cMVLJTPREC .OR. Empty(cMVLJTPREC) // Aceitar somente os titulos previamente escolhidos via parametro.

					If (SE1->E1_SALDO <> SE1->E1_VALOR) .OR. !Empty(SE1->E1_BAIXA)  	// Caso for baixa parcial nao deve trazer o desconto que foi concedido
						nE1Desc := 0                   									// no primeiro isso porque o desconto ficava para todas as parcelas
					Else
						// Se HOUVER valor de desconto
						If SE1->E1_DESCONT > 0
							
							// Transforma o valor em porcentagem e a grava no DESCFIN (assim como o Financeiro),
							// pois se o titulo sofrer baixas parciais, o E1_DESCONT sera apagado.
							If lMultNegoc .AND. SE1->E1_DESCFIN <= 0
								RecLock("SE1", .F.)
								If lMvArrefat 
									Replace SE1->E1_DESCFIN with Round( (SE1->E1_DESCONT / SE1->E1_VALOR) * 100, 2 )
								Else
									Replace SE1->E1_DESCFIN with NoRound( (SE1->E1_DESCONT / SE1->E1_VALOR) * 100, 2 )
								EndIf
								SE1->( MsUnlock() )
							EndIf

							nE1Desc := SE1->E1_DESCONT

						// Se um titulo COM desconto foi estornado totalmente, DESCFIN continua 
						// preenchido, e DESCONT sera gravado apos a primeira baixa
						ElseIf lMultNegoc .AND. SE1->E1_DESCFIN > 0								
							nE1Desc := (SE1->E1_DESCFIN/100) * SE1->E1_VALOR
	
						// Se NAO HA desconto
						Else
							nE1Desc := 0
						EndIf

					EndIf

					If cOper == "1"	//BAIXA
						If lMV_LJRCABT
							nValAbat := FaAbatCR( E1_PREFIXO, E1_NUM,    E1_PARCELA,  E1_MOEDA, ;
													NIL,        dDataBase,  E1_FILIAL )
						Else
							nValAbat := 0
						EndIf

						AAdd(aRet[4], { 	E1_PREFIXO			, E1_NUM		, E1_PARCELA	, E1_VENCREA	,;
				     						E1_SALDO - nValAbat	, E1_MULTA		, E1_JUROS		, nE1Desc	  	,;
				     						(E1_SALDO+E1_MULTA+E1_JUROS-nE1Desc-nValAbat)		, E1_TIPO		,;
				     						IIf( lE1NUMCRD, E1_NUMCRD, "" )		, E1_CLIENTE	, E1_LOJA		,;
				     						E1_FILIAL			, SE1->(Recno()), E1_SDACRES	, .F.			,;
											nValAbat			, E1_VENCTO		, cRecLock		, E1_MOEDA		,;
											Nil					, E1_BAIXA		, E1_SALDO		, E1_VALLIQ		})

					Else //ESTORNO
                        
					    lDescFin := .F.
                        If SE1->E1_DESCONT == 0 .AND. SE1->E1_DESCFIN > 0
                        	If lMvArrefat 
		                        nE1Desc :=	Round((SE1->E1_VALOR * SE1->E1_DESCFIN) / 100, 2 )
							Else
								nE1Desc := 	NoRound((SE1->E1_VALOR * SE1->E1_DESCFIN) / 100 , 2 )
							EndIf 
						    lDescFin := .T.
						Else
							 nE1Desc := SE1->E1_DESCONT
						EndIf
							
						//Leio as baixas distribuídas com juros/multa/desconto na SE5
						nE1Multa := SE1->E1_MULTA
						nE1Juros := SE1->E1_JUROS
						nE1Desct := nE1Desc
						LjSE5JMD(@nE1Multa,@nE1Juros,@nE1Desct,lDescFin)

						nValReceb := SE1->E1_VALOR - SE1->E1_SALDO - nE1Desct + nE1Multa + nE1Juros  //Valor de Recebimento
                      
                     ////////////////////////////////////////////////////////////////
                     //Tratamento para a soma do acrescimo ao valor total do título//
 						////////////////////////////////////////////////////////////////  
                     If (nModulo == 12 .Or. lTotvsPDV) .And. SE1->E1_ACRESC > 0
                     	nValReceb += SE1->E1_ACRESC
                     EndIf
                        
						AAdd(aRet[4], { 	E1_PREFIXO	, E1_NUM	, E1_PARCELA					, E1_VENCREA	,;
					 						E1_VALOR	, nE1Multa	, nE1Juros						, nE1Desct		,;
					 						nValReceb   , E1_TIPO	, IIf( lE1NUMCRD,E1_NUMCRD,"" )	, E1_CLIENTE	,;
					 						E1_LOJA		, E1_FILIAL	, SE1->(Recno())				, SE1->E1_ACRESC   ,;
					 						.F.			, nValAbat	, E1_VENCTO						, cRecLock		,;
					 						E1_MOEDA	, Nil		, E1_BAIXA						, E1_SALDO		,;
					 						E1_VALLIQ	 				})
					Endif

				Endif
			Endif
			SE1->( dbSkip() )
		End
	Else
		For nX := 1 to Len( aFiliais )

			If Empty(cCpf) .AND. IsInCallStack("STRECLOAD")		// Somente se Totvs Pdv, não há obrigatoriedade de CPF
				cIndE1 := aFiliais[nX]+cCodCli+cLojCli+cChaveSE1
				cCondE1:= "SE1->E1_FILIAL"
				cPesqE1:= aFiliais[nX]
				SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			Else
				cIndE1 := aFiliais[nX]+cCodCli+cLojCli+cChaveSE1
				cCondE1:= "SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA"
				cPesqE1:= aFiliais[nX]+cCodCli+cLojCli
				SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			EndIf
			
			LjGrvLog("RECEBIMENTO","Chave de Busca",cIndE1)
			LjGrvLog("RECEBIMENTO","Condição de Busca :",cPesqE1)
			LjGrvLog("RECEBIMENTO","Campos de Condição de Busca :",cCondE1)
			LjGrvLog("RECEBIMENTO","indice se1 :",SE1->(IndexKey()))

			

			SE1->(DbSeek(cIndE1))

			// Faz um filtro no cliente para mostrar apenas os títulos pertencentes ao CNPJ/CPF informado
			If lSA1Exc
				SA1->(DbSetOrder(1))
				lListCli := IIf(SA1->(DbSeek(aFiliais[nX]+cCodCli+cLojCli)) .and. SA1->A1_CGC == cCPF, .T., .F.)
			EndIf
			
			LjGrvLog("RECEBIMENTO","lListCli",lListCli)
			LjGrvLog("RECEBIMENTO","SE1(Found())",SE1->(Found()))
			

			While SE1->(!EOF()) .AND. ( &(cCondE1) == cPesqE1) .AND.;
				If(!Empty(cPrefixo), E1_PREFIXO==cPrefixo, .T.) .AND.;
				If(!Empty(cNum), E1_NUM==cNum, .T.) .AND.;
				If(!Empty(cParcela), E1_PARCELA==cParcela, .T.) .AND. lListCli
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Estes titulos nao podem ser recebidos, devem ser compensados no Financeiro ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AllTrim(E1_TIPO) $ cTipoTit
					SE1->(dbSkip())
					Loop
				Endif

				If IIf(lLjRecFilt,ExecBlock("LJRECFILT",.F.,.F.,{cOper,cPDV,cUsrCaixa}),.F.)
				   SE1->(DbSkip())
				   Loop
				Endif

				If lMV_LJSITTI
					If !(SE1->E1_SITUACA $ "0FG")
						SE1->(dbSkip())
						Loop
					Endif
				EndIf

				If nEstorCX = 0 .AND. cOper <> "1"

					cAliasSE5	:=  GetNextAlias()

					cQuery := "SELECT R_E_C_N_O_ RECSE5"
					cQuery += "  FROM " + RetSQLName("SE5")
					cQuery += " WHERE
					cQuery += "   E5_PREFIXO 	= '"+SE1->E1_PREFIXO+"'"
					cQuery += "   AND E5_NUMERO     = '"+SE1->E1_NUM+"'"
					cQuery += "   AND E5_PARCELA 	= '"+SE1->E1_PARCELA+"'"
					cQuery += "   AND E5_TIPO 		= '"+SE1->E1_TIPO+"'"
					cQuery += "   AND E5_BANCO 		<> '"+cUsrCaixa+"'"
					cQuery += "   AND D_E_L_E_T_ = ' ' "

					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.F.,.F.)

					lAchouSE5 := (cAliasSE5)->( !EoF() )

					If lAchouSE5
						SE1->(dbSkip())
						Loop
					EndIf

				EndIf

				If IIf(cOper == "1",SE1->E1_SALDO > 0,(SE1->E1_SALDO < SE1->E1_VALOR .or. !Empty(SE1->E1_BAIXA)))
					If ALLTRIM(SE1->E1_TIPO)$cMVLJTPREC .OR. Empty(cMVLJTPREC) // Aceitar somente os titulos previamente escolhidos via parametro.

						If (SE1->E1_SALDO <> SE1->E1_VALOR) .OR. !Empty(SE1->E1_BAIXA)  	// Caso for baixa parcial nao deve trazer o desconto que foi concedido no primeiro
							nE1Desc := 0                   									// isso porque o desconto ficava para todas as parcelas

						Else // Se PRIMEIRA baixa

							If SE1->E1_DESCONT > 0	.AND. (SE1->E1_DESCONT/SE1->E1_VALOR < 1) // Se HOUVER valor de desconto
								
								// Transforma o valor em porcentagem e a grava no DESCFIN (assim como o Financeiro)
								If lMultNegoc .AND. SE1->E1_DESCFIN <= 0
									RecLock("SE1", .F.)
									If lMvArrefat 
										nDescFin := Round((SE1->E1_DESCONT / SE1->E1_VALOR) * 100, 2)
									Else
										nDescFin := NoRound((SE1->E1_DESCONT / SE1->E1_VALOR) * 100, 2)
									EndIf

									Replace SE1->E1_DESCFIN with Min(nDescFin, 99.99)

									SE1->( MsUnlock() )
								EndIf

								nE1Desc := SE1->E1_DESCONT

							// Se um titulo COM DESCONTO foi baixado (com bx parciais) e estornado totalmente,
							// DESCFIN continua preenchido e DESCONT sera gravado apos a primeira baixa
							ElseIf lMultNegoc .AND. SE1->E1_DESCFIN > 0								
								nE1Desc := (SE1->E1_DESCFIN/100) * SE1->E1_VALOR

							// Se NAO HA desconto
							Else
								nE1Desc := 0
							EndIf

						EndIf

						If lMultNegoc .And. SE1->E1_VENCREA < dDatabase
							cMNPTPg := "" // Zero a variavel de controle de desconto.
							If !Empty(cMNtolPg) .And. At(";" , cMNtolPg ) > 0
								nDiasAtraz := dDatabase - SE1->E1_VENCREA
								cMNtolPg := Strtran(StrTran(AllTrim(cMNtolPg)," " ,""),"%","")  //removo os espacos e caso o sinal de Porcentagem
								aMNTolPG := Separa(cMNtolPg,";")
								aSort(aMNTolPG,,,{|x,y| SubStr(x,1,1) > SubStr(y,1,1)}) // Coloco em ordem decrescente para verificar a quantidade de dias maiores.
								For nX := 1 to Len(aMNTolPG)
									If Val(SubStr(aMNTolPG[nX],1,1)) >= nDiasAtraz
										cMNPTPg := 	SubStr(aMNTolPG[nX], At("=", aMNTolPG[nX])+1, Len(aMNTolPG[nX])  )
									EndIf
								Next nX
								If IsNumeric(cMNPTPg)
									nE1Desc := nE1Desc * ( Val(cMNPTPg) /100)
								Else
									nE1Desc := 0
								EndIf

							Else
								nE1Desc := 0
							EndIf
						EndIf

				  		If cOper == "1" //BAIXA
	       					If lMV_LJRCABT
	                        	nValAbat := FaAbatCR( SE1->E1_PREFIXO	, SE1->E1_NUM	, SE1->E1_PARCELA	, SE1->E1_MOEDA ,;
	                            	                  NIL				, dDataBase		, E1_FILIAL 		)
							Else
	      						nValAbat := 0
							EndIf								

							AAdd(aRet[4], {		SE1->E1_PREFIXO			, SE1->E1_NUM	, SE1->E1_PARCELA	, SE1->E1_VENCREA	,;
				         						(SE1->E1_SALDO-nValAbat), SE1->E1_MULTA	, SE1->E1_JUROS		, nE1Desc	  		,;
				         						(SE1->E1_SALDO + SE1->E1_MULTA + SE1->E1_JUROS - nE1Desc - nValAbat)			,;
				         						SE1->E1_TIPO		  	, IIf(lE1NUMCRD, SE1->E1_NUMCRD, ""), SE1->E1_CLIENTE	,;
				         						SE1->E1_LOJA			, SE1->E1_FILIAL, SE1->(Recno())	, SE1->E1_SDACRES	,; 
				         						.F.						, nValAbat		, SE1->E1_VENCTO    , cRecLock			,;
				         						SE1->E1_MOEDA			, Nil			, SE1->E1_BAIXA		, SE1->E1_SALDO		,;		
				         						SE1->E1_VALLIQ			})
						Else //ESTORNO
                            
                            lDescFin := .F.
							If SE1->E1_DESCONT == 0 .AND. SE1->E1_DESCFIN > 0
		                        If lMvArrefat 
		                        	nE1Desc :=	Round((SE1->E1_VALOR * SE1->E1_DESCFIN) / 100, 2 )
								Else
									nE1Desc := 	NoRound((SE1->E1_VALOR * SE1->E1_DESCFIN) / 100 , 2 )
								EndIf 
								lDescFin := .T.
							Else
								nE1Desc := SE1->E1_DESCONT
							EndIf
							
							//Leio as baixas distribuídas com juros/multa/desconto na SE5
							nE1Multa := SE1->E1_MULTA
							nE1Juros := SE1->E1_JUROS
							nE1Desct := nE1Desc
							LjSE5JMD(@nE1Multa,@nE1Juros,@nE1Desct,lDescFin)

							nValReceb := SE1->E1_VALOR - SE1->E1_SALDO - nE1Desct + nE1Multa + nE1Juros  //Valor de Recebimento
							
							////////////////////////////////////////////////////////////////
                     	//Tratamento para a soma do acrescimo ao valor total do título//
 							////////////////////////////////////////////////////////////////                      
                        If (nModulo == 12 .Or. lTotvsPDV) .And. SE1->E1_ACRESC > 0
                       		nValReceb += SE1->E1_ACRESC
                      	EndIf
							
							AAdd(aRet[4], { 	SE1->E1_PREFIXO		, SE1->E1_NUM	, SE1->E1_PARCELA		, SE1->E1_VENCREA	,;
					     						SE1->E1_VALOR		, nE1Multa		, nE1Juros				, nE1Desct			,;
					     						nValReceb		    , SE1->E1_TIPO	, IIf( lE1NUMCRD, SE1->E1_NUMCRD, "" )	    ,;
					     						SE1->E1_CLIENTE		, SE1->E1_LOJA	, SE1->E1_FILIAL		, SE1->(Recno())	,;
					     						SE1->E1_ACRESC    , .F.			, nValAbat				, SE1->E1_VENCTO	,;
					     						cRecLock			, SE1->E1_MOEDA	, Nil					, SE1->E1_BAIXA		,;
					     						SE1->E1_SALDO		, SE1->E1_VALLIQ})
						Endif

					Endif
				Endif
				SE1->( dbSkip() )
			End
		Next nX
	EndIf
ElseIf cMV_LJRECEB == "2"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gestao Educacional ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| *** Temporario     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //"Tabela JA2 nao implementada."
    Return({1, STR0035, STR0035 , {}})

	DbSelectArea("JA2")
	DbSetOrder(1)
	If !DbSeek(xFilial("JA2")+cNumRA)
	    //"Aluno nao encontrado", "O codigo do aluno informado nao foi encontrado."
		Return({1, STR0036, STR0037, {}})
	Endif

	DbSelectArea("SE1")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| *** Confirmar a Chave de Indice (Atentar as versoes 7.10 e 8.11)  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSetOrder(18)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| *** Chave de Indice: E1_FILIAL+E1_NUMRA+DTOS(E1_VENCTO)+E1_PREFIXO   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRecFilial
		DbSeek(xFilial("SE1")+cNumRA)
		While !EOF() .AND. E1_FILIAL+E1_NUMRA==xFilial("SE1")+cNumRA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estes titulos nao podem ser recebidos, devem ser compensados no Financeiro ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(E1_TIPO) $ cTipoTit
				dbSkip()
				Loop
			Endif

			If lMV_LJSITTI
				If !(SE1->E1_SITUACA $ "0FG")
					dbSkip()
					Loop
				Endif
			EndIf

			If SE1->E1_SALDO <> SE1->E1_VALOR  .OR. !Empty(SE1->E1_BAIXA)  	// Caso for baixa parcial nao deve trazer o desconto que foi concedido no primeiro
				nE1Desc := 0                   	// isso porque o desconto ficava para todas as parcelas
			Else								// e isso nao acontece no financeiro
				nE1Desc := SE1->E1_DESCONT
			EndIf

			If E1_SALDO > 0
				If CRDXINT() // Se o uso for com o sistema de creditos.
					If Alltrim(E1_TIPO)$cMVLJTPREC .OR. Empty(cMVLJTPREC) // Aceitar somente os titulos previamente escolhidos via parametro.
		                If lMV_LJRCABT
		                   nValAbat := FaAbatCR( E1_PREFIXO, E1_NUM,    E1_PARCELA,  E1_MOEDA, ;
		                                         NIL,        dDataBase,  E1_FILIAL )
		                Else
		                   nValAbat := 0
		                Endif
						AAdd(aRet[4], { 		E1_PREFIXO			, E1_NUM		, E1_PARCELA	, E1_VENCREA	,;
												E1_SALDO - nValAbat	, E1_MULTA		, E1_JUROS		, nE1Desc	  	,;
												E1_SALDO + E1_MULTA + E1_JUROS - nE1Desc - nValAbat	, E1_TIPO		,;
												IIf( lE1NUMCRD, E1_NUMCRD, "" )		, E1_CLIENTE	, E1_LOJA		,;
												E1_FILIAL			, SE1->(Recno()), E1_SDACRES	, .F.			,;
												nValAbat			, E1_VENCTO		, cRecLock		, E1_MOEDA		,;
												Nil					, E1_BAIXA		, E1_SALDO		, E1_VALLIQ		})
					Endif
	            Else
	            	If Alltrim(E1_TIPO)$cMVLJTPREC .OR. Empty(cMVLJTPREC) // Aceitar somente os titulos previamente escolhidos via parametro.
		                If lMV_LJRCABT
		                   nValAbat := FaAbatCR( E1_PREFIXO, E1_NUM,    E1_PARCELA,  E1_MOEDA, ;
		                                         NIL,        dDataBase,  E1_FILIAL )
		                Else
		                   nValAbat := 0
		                Endif
						AAdd(aRet[4], { 		E1_PREFIXO			, E1_NUM		, E1_PARCELA	, E1_VENCREA	,;
												E1_SALDO - nValAbat	, E1_MULTA		, E1_JUROS		, nE1Desc	  	,;
												(E1_SALDO+E1_MULTA+E1_JUROS-nE1Desc-nValAbat)		, E1_TIPO		,;
												IIf( lE1NUMCRD, E1_NUMCRD, "" )		, E1_CLIENTE	, E1_LOJA		,;
												E1_FILIAL			, SE1->(Recno()), E1_SDACRES	, .F.			,;
												nValAbat			, E1_VENCTO    	, cRecLock		, E1_MOEDA		,;
												Nil					, E1_BAIXA		, E1_SALDO		, E1_VALLIQ		})
					Endif
				Endif
			Endif
			dbSkip()
		End
	Else
		For nX := 1 to Len( aFiliais )
			DbSeek(aFiliais[nX]+cNumRA)
			While !EOF() .AND. E1_FILIAL+E1_NUMRA==aFiliais[nX]+cNumRA
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Estes titulos nao podem ser recebidos, devem ser compensados no Financeiro ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AllTrim(E1_TIPO) $ cTipoTit
					dbSkip()
					Loop
				Endif

				If lMV_LJSITTI
					If !(SE1->E1_SITUACA $ "0FG")
						dbSkip()
						Loop
					Endif
				EndIf

           		If SE1->E1_SALDO <> SE1->E1_VALOR   .OR. Empty(SE1->E1_BAIXA) 	// Caso for baixa parcial nao deve trazer o desconto que foi concedido no primeiro
					nE1Desc := 0                   	// isso porque o desconto ficava para todas as parcelas
				Else								// e isso nao acontece no financeiro
					nE1Desc := SE1->E1_DESCONT
				EndIf

				If E1_SALDO > 0
					If CRDXINT() // Se o uso for com o sistema de creditos.
						If Alltrim(E1_TIPO)$cMVLJTPREC .OR. Empty(cMVLJTPREC) // Aceitar somente os titulos previamente escolhidos via parametro.
			                If lMV_LJRCABT
			                   nValAbat := FaAbatCR( E1_PREFIXO, E1_NUM,    E1_PARCELA,  E1_MOEDA, ;
			                                         NIL,        dDataBase,  E1_FILIAL )
			                Else
			                   nValAbat := 0
			                Endif
							AAdd(aRet[4], {	E1_PREFIXO			, E1_NUM		, E1_PARCELA, E1_VENCREA,;
											(E1_SALDO-nValAbat)	, E1_MULTA		, E1_JUROS	, nE1Desc	,;
											(E1_SALDO+E1_MULTA+E1_JUROS-nE1Desc-nValAbat)	, E1_TIPO	,;
											IIf( lE1NUMCRD, E1_NUMCRD, "" )		, E1_CLIENTE, E1_LOJA	,; 
											E1_FILIAL			, SE1->(Recno()), E1_SDACRES, .F.		,;
											nValAbat			, E1_VENCTO		, cRecLock	, E1_MOEDA	,;
											Nil					, E1_BAIXA		, E1_SALDO	, E1_VALLIQ	})
						Endif
		            Else
		            	If Alltrim(E1_TIPO)$cMVLJTPREC .OR. Empty(cMVLJTPREC) // Aceitar somente os titulos previamente escolhidos via parametro.
			                If lMV_LJRCABT
			                   nValAbat := FaAbatCR( E1_PREFIXO, E1_NUM,    E1_PARCELA,  E1_MOEDA, ;
			                                         NIL,        dDataBase,  E1_FILIAL )
			                Else
			                   nValAbat := 0
			                Endif
							AAdd(aRet[4], { E1_PREFIXO				, E1_NUM		, E1_PARCELA, E1_VENCREA	,;
											(E1_SALDO - nValAbat)	, E1_MULTA		, E1_JUROS	, nE1Desc	  	,;
											(E1_SALDO+E1_MULTA+E1_JUROS-nE1Desc-nValAbat)		, E1_TIPO		,;
											IIf( lE1NUMCRD, E1_NUMCRD, "" )			, E1_CLIENTE, E1_LOJA		,;
											E1_FILIAL				, SE1->(Recno()), E1_SDACRES, .F.			,;
											nValAbat				, E1_VENCTO		, cRecLock	, E1_MOEDA		,;
											Nil						, E1_BAIXA		, E1_SALDO	, E1_VALLIQ		})
						Endif
					Endif
				Endif
				dbSkip()
			End
		Next nX
	Endif
ElseIf cMV_LJRECEB == "3"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fidelizacao e Analise de Credito ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCartao) .AND. Empty(cNum)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a validade do CNPJ/CPF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SA1")
		SA1->(DbSetOrder(3))
		If !Empty(cCPF) .AND. SA1->(DbSeek(xFilial("SA1")+AllTrim(cCPF)))
			cCodCli := SA1->A1_COD
			cLojCli := SA1->A1_LOJA
		Else
		    //"CNPJ/CPF nao encontrado", "O CNPJ/CPF informado nao foi encontrado."
			Return({1, STR0114, STR0115, {}})
		Endif
	ElseIf !Empty(cCartao)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a validade do Cartao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("MA6")
		MA6->(DbSetOrder(1))
		If !MA6->(DbSeek(xFilial("MA6")+cCartao))
		    //"Cartao nao encontrado", "O numero do cartao informado nao foi encontrado."
			Return({1, STR0038, STR0039, {}})
		Else
			cCodCli := MA6->MA6_CODCLI
			cLojCli := MA6->MA6_LOJA
		Endif
	ElseIf !Empty(cNum)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a validade do Contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("MAH")
		MAH->(DbSetOrder(1))
		If !MAH->(DbSeek(xFilial("MAH")+cNum))
		    //"Contrato nao encontrado", "O numero do contrato informado nao foi encontrado."
			Return({1, STR0040, STR0041, {}})
		Endif

		cCodCli := MAH->MAH_CODCLI
		cLojCli := MAH->MAH_LOJA
	Endif

	If !Empty(cCodCli)
		DbSelectArea("SE1")
		SE1->(DbSetOrder(2))

		If !lRecFilial
			SE1->(DbSeek( xFilial( "SE1" ) + cCodCli + cLojCli ))
			While !SE1->(EOF()) .AND. E1_FILIAL+E1_CLIENTE+E1_LOJA==xFilial( "SE1" ) + cCodCli + cLojCli
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Estes titulos nao podem ser recebidos, devem ser compensados no Financeiro ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AllTrim(E1_TIPO) $ cTipoTit
					SE1->(dbSkip())
					Loop
				Endif

				If lMV_LJSITTI
					If !(SE1->E1_SITUACA $ "0FG")
						SE1->(dbSkip())
						Loop
					Endif
				EndIf

				If SE1->E1_SALDO > 0
					If !Empty( cNum ) .AND. SE1->E1_NUMCRD <> cNum
						SE1->(dbSkip())
						Loop
					Endif

					If Alltrim(E1_TIPO)$cMVLJTPREC .OR. Empty(cMVLJTPREC) // Aceitar somente os titulos previamente escolhidos via parametro.

						If SE1->E1_SALDO <> SE1->E1_VALOR   .OR. !Empty(SE1->E1_BAIXA) 	// Caso for baixa parcial nao deve trazer o desconto que foi concedido no primeiro
							nE1Desc := 0                   	// isso porque o desconto ficava para todas as parcelas
						Else								// e isso nao acontece no financeiro
							nE1Desc := SE1->E1_DESCONT
						EndIf

		                If lMV_LJRCABT
		                   nValAbat := FaAbatCR( E1_PREFIXO, E1_NUM,    E1_PARCELA,  E1_MOEDA, ;
		                                         NIL,        dDataBase,  E1_FILIAL )
		                Else
		                   nValAbat := 0
		                Endif

						AAdd(aRet[4], { E1_PREFIXO			, E1_NUM		, E1_PARCELA	, E1_VENCREA,;
										(E1_SALDO-nValAbat)	, E1_MULTA		, E1_JUROS		, nE1Desc	,;
										(E1_SALDO+E1_MULTA+E1_JUROS-nE1Desc-nValAbat)		, E1_TIPO	,;
										IIf( lE1NUMCRD, E1_NUMCRD, "" )		, cCodCli		, cLojCli	,;
										E1_FILIAL			, SE1->(Recno()), E1_SDACRES	, .F.		,;
										nValAbat			, E1_VENCTO     , cRecLock		, E1_MOEDA	,;
										Nil					, E1_BAIXA		, E1_SALDO		, E1_VALLIQ	})
					Endif
				Endif
				SE1->(dbSkip())
			End
		Else
			For nX := 1 to Len( aFiliais )
				SE1->(DbSeek( aFiliais[nX] + cCodCli + cLojCli ))
				While !SE1->(EOF()) .AND. E1_FILIAL+E1_CLIENTE+E1_LOJA==aFiliais[nX] + cCodCli + cLojCli
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estes titulos nao podem ser recebidos, devem ser compensados no Financeiro ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If AllTrim(E1_TIPO) $ cTipoTit
						SE1->(dbSkip())
						Loop
					Endif

					If lMV_LJSITTI
						If !(SE1->E1_SITUACA $ "0FG")
							SE1->(dbSkip())
							Loop
						Endif
					EndIf

					If E1_SALDO > 0
						If !Empty( cNum ) .AND. SE1->E1_NUMCRD <> cNum
							SE1->(dbSkip())
							Loop
						Endif

						If Alltrim(E1_TIPO)$cMVLJTPREC .OR. Empty(cMVLJTPREC) // Aceitar somente os titulos previamente escolhidos via parametro.

							If SE1->E1_SALDO <> SE1->E1_VALOR  	// Caso for baixa parcial nao deve trazer o desconto que foi concedido no primeiro
								nE1Desc := 0                   	// isso porque o desconto ficava para todas as parcelas
							Else								// e isso nao acontece no financeiro
								nE1Desc := SE1->E1_DESCONT
							EndIf

			                If lMV_LJRCABT
			                   nValAbat := FaAbatCR( E1_PREFIXO, E1_NUM,    E1_PARCELA,  E1_MOEDA, ;
			                                         NIL,        dDataBase,  E1_FILIAL )
			                Else
			                   nValAbat := 0
			                Endif
							AAdd(aRet[4], { 	E1_PREFIXO			, E1_NUM		, E1_PARCELA	, E1_VENCREA,;
												(E1_SALDO-nValAbat)	, E1_MULTA		, E1_JUROS		, nE1Desc	,;
												(E1_SALDO+E1_MULTA+E1_JUROS-nE1Desc-nValAbat)		, E1_TIPO	,;
												IIf( lE1NUMCRD, E1_NUMCRD, "" )		, cCodCli		, cLojCli	,;
												E1_FILIAL			, SE1->(Recno()), E1_SDACRES	, .F.		,;
												nValAbat			, E1_VENCTO     , cRecLock		, E1_MOEDA	,;
												Nil					, E1_BAIXA		, E1_SALDO		, E1_VALLIQ	})
						Endif
					Endif
					SE1->(dbSkip())
				End
			Next nX
		Endif
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telecobranca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIF cMV_LJRECEB == "4"

    DbSelectArea("SE1")
	If nRecno > 0
		SE1->( Dbgoto(nRecno) )

		If lMV_LJRCABT
		   nValAbat := FaAbatCR(E1_PREFIXO	, E1_NUM	, E1_PARCELA,  E1_MOEDA	,;
								NIL			, dDataBase	, E1_FILIAL )
		Else
		   nValAbat := 0
		EndIf

		AAdd(aRet[4], 	{ 	SE1->E1_PREFIXO	, SE1->E1_NUM			, SE1->E1_PARCELA	, SE1->E1_VENCREA	,;
				 			SE1->E1_VALOR	, SE1->E1_MULTA			, SE1->E1_JUROS		, SE1->E1_DESCONT	,;
				 			(SE1->(E1_VALOR-E1_SALDO) - nValAbat)	, SE1->E1_TIPO		, IIF( lE1NUMCRD, SE1->E1_NUMCRD, "" ),;
				 			SE1->E1_CLIENTE	, SE1->E1_LOJA			, SE1->E1_FILIAL	, SE1->(Recno())	,;
				 			SE1->E1_SDACRES , .F.					, nValAbat			, E1_VENCTO     	,;
							cRecLock,		, E1_MOEDA				, Nil    			, E1_BAIXA			,;
							E1_SALDO		, E1_VALLIQ				})
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcular juros somente se for recebimento. Quando for estorno da baixa nao calcular³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOper == "1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  Retiro os dias de feriados cadastrados no sistema  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aFeriados := RetFeriados()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para tratar a tabela de feriados            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "LJRECFER" )
		aFeriados := Execblock( "LJRECFER", .F., .F., { aFeriados } )
	Endif

	For nX := 1 To Len(aRet[4])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso haja baixa parcial, a data referencia e' a data da baixa³
		//³e nao mais a data de geracao do titulo.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lBxParcial := .F.
        nValJuros  := 0
        nValMulta  := 0
		nDias	:= 0
        lAcresVlTit :=  .T.
        dBase := nil


	   	If aRet[4][nX,TIT_VREA-1] < dDataRef .OR. lMV_LJCALJM

			//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  -Inicio
	   		LojxDAtras (dDataRef,		@nDias,		@aFeriados,		@lBxParcial,;
						lMV_LJJUFIN,	cUsaFDS,	aRet[4][nX, TIT_PREF-1],;
						aRet[4][nX, TIT_NUME-1],	aRet[4][nX, TIT_PARC-1],	aRet[4][nX, TIT_TIPO-1], 	aRet[4][nX, TIT_CLIE-1],;
						aRet[4][nX, TIT_LOJA-1],	aRet[4][nX, TIT_VREA-1] ,	aRet[4][nX, TIT_VENC-1])
			//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Finaç

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  Ponto de entrada para recalculo dos dias de juros de acordo com regras customizadas  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock( "LJJUROS" )
				nDias := ExecBlock( "LJJUROS", .F., .F., {aRet[4], nDias, aFeriados} )
			Endif

			//Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Inicio
			nValMulta := LojxRMul(lMV_LJJUFIN,lAcresVlTit,  nMV_LJMULTA, aRet[4][nX, TIT_VALO-1],aRet[4][nX, TIT_ACRS-1],aRet[4][nX,TIT_VREA-1],dDataRef,lBxParcial, 0,.f.,,,,,,,,.T.)

			nValJuros := LojxRJur(lMV_LJJUFIN, lAcresVlTit, nMV_LJJUROS, nDias, ;
								aRet[4][nX, TIT_VALO-1],aRet[4][nX, TIT_ACRS-1],"SE1",aRet[4][nX, TIT_RECN -1],;
								aRet[4][nX, TIT_MOED -1 ],dDataRef,aRet[4][nX, TIT_VREA-1], lBxParcial ,;
								0, .F. )
			//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Final
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para recalculo do Valor da multa de acordo com regras customizadas                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistFunc( "U_LJVLMULT" )
				nValMulta := ExecBlock( "LJVLMULT", .F., .F., { aRet[4][nX] , nValMulta , nMV_LJMULTA } )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para recalculo do Valor dos juros de acordo com regras customizadas               |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjGrvLog("", "Valor do Juros calculado", nValJuros)
			If ExistFunc( "U_LJVLJURO" )
				nValJuros := ExecBlock( "LJVLJURO", .F., .F., { aRet[4][nX] , nValJuros , nMV_LJJUROS , nDias } )
				LjGrvLog("", "Valor de Juros retornado do PE LJVLJURO", nValJuros)
				If ValType(nValJuros) == "N"
					// o NoRound foi colocado, pois ele também é usado na função LojXRJur
					nValJuros := NORound(nValJuros, 2 /*decimais da moeda R$*/)
				Else
					nValJuros := 0
				EndIf
			Endif


	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se houve baixa parcial o valor dos juros deve ser gerado³
			//³a partir da data da baixa.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If lBxParcial .OR. ( lMV_LJJUFIN .and. cMvJurTipo <> "L")
	       		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Subtraio os juros que ja vem inserido no valor total do titulo.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        	aRet[4][nX,TIT_RECE-1]	-= aRet[4][nX,TIT_JURO-1]
	        	aRet[4][nX,TIT_JURO-1] := nValJuros

	        	If lBxParcial .OR. !lMvLjIntFs   //Se não calcular a Multa pelo Loja ou for baixa parcial, abate o valor da Multa
	        		aRet[4][nX,TIT_RECE-1]	-= aRet[4][nX,TIT_MULT-1]
	        		aRet[4][nX,TIT_RECE-1] -= nValMulta
	        		aRet[4][nX,TIT_MULT-1] := 0
	        	ElseIf !lBxParcial .AND. lMvLjIntFS //Se não for baixa parcial e tive multa, atribui oa multa
	        			aRet[4][nX,TIT_MULT-1] += nValMulta
	        	EndIf

	        Else
	        	aRet[4][nX,TIT_JURO-1] += nValJuros

	        	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Deve existir apenas uma multa, independente do numero        ³
				//³de dias em atraso. Sera' recalculada apenas para baixa total.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        	aRet[4][nX,TIT_MULT-1] += nValMulta
  	        Endif
	        aRet[4][nX,TIT_RECE-1] += nValMulta + nValJuros
		Else
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso do titulo nao estiver vencido e o parametro³
		//³ nao estiver habilitado nao carrega os juros       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRet[4][nX,TIT_RECE-1]	-= aRet[4][nX,TIT_JURO-1]
	       	aRet[4][nX,TIT_RECE-1]	-= aRet[4][nX,TIT_MULT-1]
	      	aRet[4][nX,TIT_MULT-1] := nValMulta
    	   	aRet[4][nX,TIT_JURO-1] := nValJuros
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³P.E. para calcular o desconto dos títulos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		If lLjValDesc
        	uRet := U_LjValDesc( aRet[4], nX )
        	If ValType( uRet ) == "N"
        		aRet[4][nX,TIT_DESC-1] := uRet
        		aRet[4][nX,TIT_RECE-1] -= aRet[4][nX,TIT_DESC-1]
        	EndIf
        EndIf
	Next nX
Endif

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ LJGrvRec ³ Autor ³ Cesar Eduardo Valadao ³ Data ³03/07/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava as informacoes refentes ao recebimento de titulos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array com as parcelas utilizadas para a baixa dos   ³±±
±±³			 ³titulos													  ³±±
±±³			 ³ExpL2 - Controla se tem transacao TEF realizada mas pendente³±±
±±³			 ³ExpA3 - Array com as informacoes TEF caso tenha que cancelar³±±
±±³			 ³alguma transacao ao final do recebimento					  ³±±
±±³			 ³ExpL4 - Indica se deve verificar se ha alguma transacao TEF ³±±
±±³			 ³pendente													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJGrvRec(	aPgtos		, lTEFPendRec, aBckTEFMult	, lVerTEFPend	,;
					aTitImpr	, nTroco     , aTitulo    	, cTotRecNFis	,;
					aNccRecSel	, lSelTefManu,lTefManual	, aPagDig		)

Local nI		    := 0                   					// Controle de loop
Local aTituloNB 	:= {}
Local lRet 			:= .T.									// Retorno da funcao
Local lLJGRVTIT   	:= ExistFunc("U_LJGRVTIT") 			// P.E. para substituir a gravacao dos titulos
Local cADM			:= ""									// Codigo da Administradora FINANCEIRA
Local cCodProduto   := ""									// Codigo do produto
Local cDescProduto  := ""                          			// Descricao do produto
Local aRetCrd		:= { 0, 0, 0, "" }             			// Retorno da integracao com SIGACRD
Local aParcVda      := {}                           		// Parcelas da venda - integracao com SIGACRD
Local aDadosCrd     := {}									// Dados do CRD
Local aProdCrd      := {}									// Dados do produto
Local nX			:= 0									// Controle de loop
Local lMV_CRDLCAR	:= SuperGetMV("MV_CRDLCAR",,.F.)		// Parametro que verifica se ira ou nao efetuar a analise de credito aopos o recebimento
Local cMsg 			:= STR0112	//"BLOQUEADO POR ATRASO"	// Mensagem de BLOQUEIO POR ATRASO
Local cVendPad		:= SuperGetMV( "MV_VENDPAD" )			// Paramerto que armazena o codigo do vendedor padrao
Local lContinua		:= .T.
Local aTitBx		:= {}									//Titulos do Recibo de pagamento
Local aFormPg		:= {}									//Forma de Pagamento do Recibo
Local nTotalPg		:= 0 
Local nCount		:= 0
Local lLOJRREC	:= ExistFunc("LOJRREC")				// Relatorio de impressao de Recibo (OBSOLETO)
Local lULOJRREC	:= ExistFunc("U_LOJRRecibo")			// Relatorio de impressao de Recibo (RDMAKE)
Local lIMPLJRE	:= SuperGetMV("MV_IMPLJRE",,.F.)		// Ativa impressão de recibo de pagamento, requer UPDLO166
Local aSE1Area	:= {}
Local lAutomato :=  If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local aTitBXNCC := {}
Local nPosTit	:= 0 //Valor do Título
Local nTotNCC	:= 0 //total da NCC
Local nValTit	:= 0 //Valor do Título
Local nValorNCC	:= 0

DEFAULT lTEFPendRec := .F.
DEFAULT aBckTEFMult := {}
DEFAULT lVerTEFPend := .F.
DEFAULT nTroco		:= 0
DEFAULT aTitImpr	:= {}
DEFAULT aNccRecSel  := {}
DEFAULT lSelTefManu	:= .F.									//Define se selecinou o TefManual para continuar operação de cartão
DEFAULT lTefManual	:= .F.									//Define se selecinou o TefManual para continuar operação de cartão
DEFAULT aPagDig 	:= {}									//Informações do Pagamento Digital

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a variavel aTitImp existir (como private), sobrepoe ³
//³a variavel aTitImpr local                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa) )
	If nModulo == 23 .AND. (Type("aTitImp") <> "U")
		aTitImpr	:= aClone(aTitImp)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para o Venda Assistida Off-Line, busca o retorno da variavel³
	//³static dentro do LOJA701 atraves da funcao de Get criada    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf nModulo ==12 .AND. lMvLjPdvPa
		If ExistFunc("Lj7aTitGet") .AND. ExistFunc("Lj7aTitSet")
			aTitImpr	:= aClone(Lj7aTitGet())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpa a variavel Estatica criada dentro do LOJA701³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj7aTitSet()
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o P.E. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLJGRVTIT
	If !U_LJGRVTIT(	aPgtos	, @lRet, aTitulo, cTotRecNFis ,;
					aTitImpr, @nTroco)
		lContinua := .F.
	Endif
Endif

If lContinua

	If lAutomato//PREPARACAO AUTOMACAO 
		aTituloNB := AClone(_LJGrvRec(aPgtos,lTEFPendRec,aBckTEFMult,lVerTEFPend,aTitImpr,aNccRecSel,nTroco,lSelTefManu, aTitulo, @aTitBXNCC, lTefManual, aPagDig ))
	Else
		//"Aguarde... Realizando a gravação dos Títulos"
		LJMsgRun(STR0042,, {|oDlg| aTituloNB := AClone(_LJGrvRec(	aPgtos   	, lTEFPendRec 	, aBckTEFMult	, lVerTEFPend,;
																	aTitImpr 	, aNccRecSel	, nTroco 		, lSelTefManu, ;
																	aTitulo		, @aTitBXNCC	, lTefManual	, aPagDig ))})
	Endif

	If Len(aTituloNB) > 0 .And. ValType(aTituloNB[1]) == "A"
		For nI := 1 To Len(aTituloNB)
			lRet := .F.
			//"Não foi possível baixar o título "
			MsgStop(STR0043+aTituloNB[nI][TIT_PREF]+"/"+aTituloNB[nI][TIT_NUME]+"/"+aTituloNB[nI][TIT_PARC]+".")
		Next nI
	EndIf

	If lMV_CRDLCAR
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe Integracao CRD³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CrdxInt(.T.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizacao da situacao do cartao apos efetuar o recebimento de titulos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a situacao do cartao esta' como BLOQUEADO³
			//³Caso esteja ATIVO, nao e' necessario realizar a      ³
			//³atualizacao da situacao do carto.                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSitCartao := CRDXNumCart(.T., cCCodcli, cCLojCli )//localizado no programa CRDXFUN
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posicoes do array aSitCartao:                    								      ³
			//³---------------------------------------------------------------------------------------³
			//³[1]   | .T. indica que o cartao esta bloqueado ou ativo						          ³
			//³[2]   | Numeracao do cartao                    								          ³
			//³[3]   | Mensagem  																	  ³
			//³---------------------------------------------------------------------------------------³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aSitCartao[1] .AND. aSitCartao[3] == cMsg
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetua a analise de credito.                     ³
				//³SOMENTE CONSULTA, nao ira' atualizar nenhum campo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//Capturando uma administradora financeira para a condicao de pagamento do tipo FI
			    DbSelectArea("SAE")
			    SAE->(DbSeek(xFilial("SAE"),.T.))//posiciona no primeiro registro da tabela
			    While !SAE->(EOF())
			    	If AllTrim(SAE->AE_TIPO) == "FI" .AND. SAE->AE_PLABEL =="1"
			    		cADM := SAE->AE_COD+" - "+SAE->AE_DESC
			    		Exit
			    	Else
			    		SAE->(DbSkip())
			    	Endif
			    End

				If nModulo == 23
					//Capturando um codigo e descricao do produto.
				    DbSelectArea("SBI")
				    SBI->(DbSeek(xFilial("SBI"),.T.))//posiciona no primeiro registro da tabela
		    		cCodProduto  := SBI->BI_COD
		    		cDescProduto := SBI->BI_DESC
		    	Elseif nModulo == 12 .OR. nModulo == 72 .OR. LJModNFis()  // SIGALOJA //SIGAPHOTO //SIGAFAT
					//Capturando um codigo e descricao do produto.
				    DbSelectArea("SB1")
				    SB1->(DbSeek(xFilial("SB1"),.T.))//posiciona no primeiro registro da tabela
		    		cCodProduto  := SB1->B1_COD
		    		cDescProduto := SB1->B1_DESC
	            Endif

				AAdd( aProdCrd, { "001",;     	 	//Item do Produto
				                  cCodProduto,;   	//Codigo do Produto
				                  cDescProduto,;	//Descricao do Produto
				                  1,;	     		//Quantidade de pecas vendidas
				                  0.01,;	    	//Valor unitario do produto
				                  0.01} )  			//Valor total da venda do item

		    	Aadd(aParcVda,{dDataBase,;                									  	// Data de vencimento
				               0.01		,;														// Valor da parcela
				     		   "FI"		,;				           								// Forma de pagamento
				     		   cADM		,;                										// Codigo da administradora ou numero do banco
				     		   ""		,;                										// Numero do cartao ou cheque
				               ""		,;														// Agencia do cheque
					 		   ""		,;														// Conta do cheque
					 		   ""		,;														// RG do cheque
					 		   ""		,;				  										// Telefone do portador do cheque
				     		   .F.		,;                 										//
					 		   IIf(cPaisLoc $ "BRA|MEX", 1, aParcelas[nX][11])	 })	           	// Moeda da parcela
				aAdd( aDadosCrd, If(nModulo == 23, cRecCart, cCartao ))															// 01 Numero do cartao
				aAdd( aDadosCrd, If(nModulo == 23, cRecCPF, cCPF))															// 02 CNPJ/CPF
				aAdd( aDadosCrd, 0.01 )																// 03 Valor da venda
				aAdd( aDadosCrd, 0.00 )																// 04 Juros da venda
				aAdd( aDadosCrd, 1 )																// 05 Numero de parcelas
				aAdd( aDadosCrd, 1 )																// 06 Venda forcada
				aAdd( aDadosCrd, "" )																// 07 Responsavel pela venda forcada
				aAdd( aDadosCrd, {} )																// 08 Dados das parcelas [n,1]=Data vencto [n,2]=Valor da parcela [n,3]=Forma de pagto
				aAdd( aDadosCrd, SM0->M0_CODIGO+"-"+FWGETCODFILIAL+"-"+Alltrim(SM0->M0_NOME)  )	// 09 Loja da venda
				aAdd( aDadosCrd, LjGetStation("LG_PDV"))											// 10 PDV
				aAdd( aDadosCrd, xNumCaixa() )														// 11 Caixa
				aAdd( aDadosCrd, "" )																// 12 Num. do orcamento
				aAdd( aDadosCrd, aProdCrd )															// 13 Produtos selecionados numa venda
				aAdd( aDadosCrd, aParcVda )															// 14 Parcelas de uma venda
				aAdd( aDadosCrd, FWGETCODFILIAL )													// 15 Filial do Caixa que esta sendo utilizado
				aAdd( aDadosCrd, cCCodcli )		   													// 16 Codigo do cliente
				aAdd( aDadosCrd, cCLojCli )													 		// 17 Loja do cliente
				aAdd( aDadosCrd, cUserName )														// 18 Nome do usuario
				aAdd( aDadosCrd, "FI")							  									// 19 Condicao de Pagamento
				aAdd( aDadosCrd, "FRT"     )												  		// 20 Modulo chamador
				aAdd( aDadosCrd, cVendPad )					 								  		// 21 Codigo do vendedor

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetua toda a analise de credito ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRetCrd := aClone(CrdxVenda( "1" , aDadosCrd, "" , .T.,;
				                              .F., "43" 	, .T.,    ,.T.))// localizado no programa CRDXFUN.prw
				If aRetCRD[1] == 0 // indica que esta OK
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se o Limite de Credito esta' maior que os   ³
					//³titulos em aberto                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If  aRetCRD[2] > aRetCRD[3]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao que atualize o campo MA6_SITUA para ATIVO ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						CrdxAtuMA6( cCCodcli, cCLojCli )// localizado no programa CRDXFUN.prw
					Endif
				Endif
			Endif
		Endif
	Endif

	For nCount := 1 To Len(aPgtos)
        nTotalPg += aPgtos[nCount][02]
	Next nCount
	
	//PREPARACAO PARA AUTOMACAO
	If lAutomato 
		aTitulo := aClone(aTitAuto)	
		cMV_LJRECEB := LJRecSistCr()
	Endif
	//FIM PREPARACAO AUTOMACAO
	
	For nCount := 1 To Len(aTitulo)
        If aTitulo[nCount][01] .And. nTotalPg < aTitulo[nCount][10]
        
            aTitulo[nCount][10] := nTotalPg
            
            nCount := Len(aTitulo)
        EndIf
        
    Next nCount

	//----------------------
	//Imprime o comprovante
	//----------------------
	If lIMPLJRE .And. lRet .And. (lLOJRREC .Or. lULOJRREC) .And. (Len(aTitulo) > 0 .And. ValType(aTitulo[1]) <> "N")
		aSE1Area := SL1->(GetArea())
		//Monta o Array do titulos pagos para o Recibo
		SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		For nI:=1 to Len(aTitulo)
			If  aTitulo[nI][TIT_SELE]
				SE1->(DbSeek(aTitulo[nI][TIT_FILI] + aTitulo[nI][TIT_CLIE] + aTitulo[nI][TIT_LOJA] + aTitulo[nI][TIT_PREF] +;
								aTitulo[nI][TIT_NUME] + aTitulo[nI][TIT_PARC] +  aTitulo[nI][TIT_TIPO] ))
								
				nValTit := aTitulo[nI][TIT_RECE]
				nValorNCC := 0
				If ( nValTit = 0 .OR.  nValTit < (aTitulo[nI][TIT_VALO] + aTitulo[nI][TIT_MULT] + aTitulo[nI][TIT_JURO] - aTitulo[nI][TIT_DESC])) .and. ( nPosTit := aScan( aTitBXNCC, { |x| x[TIT_RECN] == aTitulo[nI][TIT_RECN] }) ) > 0
					nValorNCC := aTitBXNCC[nPosTit][TIT_RECE] -  aTitulo[nI][TIT_RECE]
					nValTit += nValorNCC
					nTotNCC += nValorNCC
					
				EndIf

				aadd(aTitBx, {	aTitulo[nI][TIT_NUME]	,;	//01-Nro do Titulo
				       			aTitulo[nI][TIT_PREF]	,;	//02-Prefixo
				       			aTitulo[nI][TIT_PARC]	,;	//03-Parcela
				       			aTitulo[nI][TIT_TIPO]	,;	//04-Tipo
				       			aTitulo[nI][TIT_CLIE]	,;	//05-Cliente
				       			aTitulo[nI][TIT_LOJA]	,;	//06-Loja
				       			SE1->E1_EMISSAO			,;	//07-Emissao
				       			aTitulo[nI][TIT_VENC]	,;	//08-Vencimento
				       			aTitulo[nI][TIT_VALO]	,;	//09-Valor Original
				       			SE1->E1_SALDO				,;	//10-Saldo
				       			aTitulo[nI][TIT_MULT]	,;	//11-Multa
				       			aTitulo[nI][TIT_JURO]	,;	//12-Juros
				       			aTitulo[nI][TIT_DESC]	,;	//13-Desconto
				       			nValTit	,;	//14-Valor Recebido
				       			aTitulo[nI][TIT_ACRS]	})	//15-Valor do Acrescimo (E1_ACRESC)
			Endif
		Next

		RestArea(aSE1Area)

		For nI:=1 to Len(aPgtos)
			If aPgtos[nI][2] > 0 
				If ValType(aPgtos[nI][4]) == "A" .And. Len(aPgtos[nI][4]) > 0 .And. AllTrim(aPgtos[nI][3]) == "CH"
					aadd(aFormPg	,{	aPgtos[nI][3]		,;	//Forma de Pagamento
										aPgtos[nI][2]		,;	//Valor
										Dtos(aPgtos[nI][1])	,;	//Data do Pagamento
										aPgtos[nI][4][7]	,;	//Numero do Cheque
										aPgtos[nI][4][4]	,;	//Banco
										aPgtos[nI][4][5]	,;	//Agencia
										aPgtos[nI][4][6]	,;	//Conta Corrente
										""					})	//Nome do Terceiro
				Else
					aadd(aFormPg	,{	aPgtos[nI][3]		,;	//Forma de Pagamento
										aPgtos[nI][2]		,;	//Valor
										Dtos(aPgtos[nI][1])	,;	//Data do Pagamento
										""					,;	//Numero do Cheque
										""					,;	//Banco
										""					,;	//Agencia
										""					,;	//Conta Corrente
										""					})	//Nome do Terceiro
				EndIf
			EndIf
		Next
		If nTotNCC > 0
				aadd(aFormPg	,{	"CR"		,;	//Forma de Pagamento
									nTotNCC		,;	//Valor
									Dtos(Date())	,;	//Data do Pagamento
									""					,;	//Numero do Cheque
									""					,;	//Banco
									""					,;	//Agencia
									""					,;	//Conta Corrente
									""					})	//Nome do Terceiro		
		EndIf 
		If lULOJRREC
			//Fonte não será mais padrao mas sim um RDMake padrão.
			U_LOJRRecibo(cCCodcli, cCLojCli, aTitBx, aFormPg)
		Else
			LOJRREC(cCCodcli, cCLojCli, aTitBx, aFormPg)
		EndIf
	Endif
EndIf
lRecebNFCE   := nil								//Controle de Performance - função LjModNFis()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³_LJGrvRec ³ Autor ³ Cesar Eduardo Valadao ³ Data ³xx/xx/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava as informacoes refentes ao recebimento de titulos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array com as parcelas utilizadas para a baixa dos   ³±±
±±³			 ³titulos													  ³±±
±±³			 ³ExpL2 - Controla se tem transacao TEF realizada mas pendente³±±
±±³			 ³ExpA3 - Array com as informacoes TEF caso tenha que cancelar³±±
±±³			 ³alguma transacao ao final do recebimento					  ³±±
±±³			 ³ExpL4 - Indica se deve verificar se ha alguma transacao TEF ³±±
±±³			 ³pendente													  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function _LJGrvRec( 	aPgtos	, lTEFPendRec	, aBckTEFMult	, lVerTEFPend	,;
							aTitImpr, aNccRecSel	, nRelTroco   	, lSelTefManu	,;
							aTitSel , aTitBXNCC		, lTefManual	, aPagDig		)

Local nParc				:= 0 											// Variavel que controla as parcelas das formas de pagamento
Local aRet 				:= {}											// Array de retorno da funcao
Local lRet 				:= .T.											// Indica retorno de operacoes
Local cAux																// Variavel que guarda valores temporarios
Local nNumTit 			:= 0											// Nr. de titulos
Local nCntTit 			:= 0											// Contador de titulos
Local cSoapFCode  		:= ""											// Variavel usada pelo WebService
Local cSoapFDescr 		:= ""               							// Variavel usada pelo WebService
Local cMsgComprovante 	:= ""											// Texto do comprovante de recebimento
Local cMsgRecibo        := ""
Local nTotComprovante 	:= 0											// Total do comprovante
Local cCliente			:= Space(TamSx3("A1_COD")[2])					// Armazena o cod. do cliente
Local cLoja				:= Space(TamSx3("A1_LOJA")[2])					// Armazena a loja do cliente
Local cMvSimb1			:= SuperGetMV("MV_SIMB1")						// Simbolo da moeda
Local lLjRecComp        := ExistBlock("LJRECCOMP",,.T.)					// P.E. de impressao do comprovante
Local lFrtRecTit		:= ExistBlock("FRTRECTIT")				    	// P.E. FRTRECTIT
Local nX				:= 0											// Variavel utilizada em loop
Local nTamaPgtos		:= 0											// Tamanho do array aPgtos
Local aRecnoSE1			:= {}											// Array com os recnos dos titulos que foram baixados
Local aRecnoNCC			:= {}											// Array com as NCCs que foram selecionadas para pagamento
Local aFormasPago 		:= {}											// Totaliza os valores de cada forma de pagamento, exemplo R$X,XX em Dinheiro, R$YY,YY em CH
Local nPosFormaPg 		:= 0											// Posicao da forma de pagamento dentro da aFormasPago
Local nVlrTitulo 		:= 0											// Valor total do titulo. Variavel utilizada para controlar a baixa parcial do titulo ou com mais de uma forma de pagamento
Local bGravaMoeda														// Bloco de codigo que sera' utilizado para gravar o campo E5_MOEDA na compensacao das NCCs
Local cNumDocumento		:= ""											// Numero do documento que sera' impresso no comprovante de pagamento
Local nEspaco 			:= 0											// Quantidade de espacos em branco que ira' separar o numero do documento do valor no comprovante
Local cTotRecNFis		:= If(Type("cTotRecNFis")=="U","",cTotRecNFis)	// Totalizador nao fiscal para impressao do comprovante de recebimento
Local lCartao           := .F.											// Indica se ha recebimento em CC
Local nI				:= 0											// Variavel usada em lacos For..Next
Local cMV_TEFPEND       := SuperGetMV("MV_TEFPEND",,"0")               	// Define o tratamento a ser realizado quando uma ou mais transacoes TEF ficam pendentes
Local lTefMult		    := SuperGetMV("MV_TEFMULT", ,.F.)	            // Identifica se o cliente utiliza múltiplas transações TEF
Local lPrimBaixa        := .T.                                          // Controla se eh a primeira baixa do titulo
Local nPrimMulta        := 0                                            // Valor da multa da primeira baixa a ser gravado no SE1 e SE5
Local nPrimJuros        := 0                                            // Valor dos juros da primeira baixa a ser gravado no SE1 e SE5
Local nPrimDescon       := 0                                            // Valor do desconto da primeira baixa a ser gravado no SE1 e SE5
Local nRestMulta        := 0                                            // Para controle do valor restante do rateio da Multa
Local nRestJuros        := 0                                            // Para controle do valor restante do rateio do Juros
Local nRestDescon       := 0                                            // Para controle do valor restante do rateio do Desconto
Local nTotMulta        	:= 0                                            // Total da multa a ser gravado no SE1 e SE5
Local nTotJuros        	:= 0                                            // Total do juros a ser gravado no SE1 e SE5
Local nTotDescon       	:= 0                                            // Total do desconto a ser gravado no SE1 e SE5
Local nPercPagto		:= 0											// Percentual da forma de pagto do total pagto
Local nTotReceb         := 0                                            // Total recebido a ser gravado no campo E1_VALLIQ(valor pago)
Local aAreaE1			:= {}											// Salva area do SE1
Local cSimbCor			:= AllTrim(SuperGetMV("MV_SIMB1"))				// Simbolo da moeda corrente
Local lRetTef	  		:= .F.											// Retorno do Cancelamento do TEF
Local lErrCupTEF  		:= .F.											// Retorna se houve ou nao problema com o impressao do cupom TEF
Local nRecVias    		:= SuperGetMV("MV_RECVIAS",,2)					// numero de vias para impressao do comprovante de Recebimento
Local lRecNTef			:= .F.											// Pagamento de titulos via TEF ?
Local lChkslv			:= ChkFile("SLV")								// Retorna se o arquivo SLV foi criado
Local aSE5Dados			:= {}											// Guarda as informa do SE5 ao ser gerado
Local aSE5Bxas 			:= {}											// Guarda as informa do SE5 ao ser gerado não TEF
Local lPgTef			:= .F.											// Define se o pagamento eh em TEF
Local aAux				:= {}											// Array auxiliar
Local lRelGer			:= .F.											// Controla se imprime relatorio gerencial
Local cTpRec			:= SuperGetMV("MV_LJTPREC", ,"FI")				// Tipo permitido no recebimento
Local lErrSrv			:= .F.
Local lVAssist			:= .F.											// Se a funcao que chamou é a venda assistida
Local nPosFPgto	 		:= 0											// Posicao do pagto money no array
Local cNccSerie         := ""											// Armazena dados ref. a baixa da NCC
Local cNccDoc			:= ""											// Armazena dados ref. a baixa da NCC
Local cParcela			:= ""											// Armazena dados ref. a baixa da NCC
Local lTroco            := .F.                                          // Indica se esta habilitado ou nao o troco
Local nTotalPg          := 0                                            // Totaliza o valor pago
Local nCount            := 0                                            // Contador do loop
Local nValReceb         := 0                 	                        // Totaliza valor a receber
Local nCalcTroco        := 0                                            // Recebe o valor do troco
Local nTamSAE   		:= TamSx3("AE_COD")[1] 							// Tamanho do campo AE_COD
Local cNumCheque        := ""						                    // Numero do cheque
Local lLJRecGrv			:= ExistBlock("LJRecGrv")
Local aRetDNFH			:= {}
Local cMsgRecAux		:= ""
Local xRet
Local cMvTpRet      	:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS")
Local cTipoRecImp		:= "S"
Local lMultBaixa		:= .F.											// Verifica se baixa multipla de titulo
Local cMsgCompTitulo 	:= ""											// Texto do comprovante de recebimento
Local lEmiteComp		:= .F.											// Sinaliza se devera imprimir o comprovante
Local nValTroco			:= 0
Local aCopMoedas 		:= IIF( Type("aMoedas") == "A", aClone(aMoedas),{}) // Recebe o conteudo de aMoedas caso exista
Local aAntTit 	:= {}
Local aAuxTit 	:= {}
Local aVlrReceb := {}
Local aAuxNccSel:= {}
Local cRotPag	 		:= SuperGetMV("MV_LJRMPAG",,"LJPAGLOC" )   		// Verifica se habilita a impressão de Comprovante de Pagamento ***Roberto
Local lLjPagCol	 		:= ExistBlock(cRotPag)							// Verifica a utilização do ponto de entrada para a impressão do Comprovante de Pagamento ***Roberto

Local nPosRetCart		:= 0											// Posicao do cartao dentro do Array aRetCartao
Local cNSUTEFAux 		:= ""
Local cAutTEFAux 		:= ""
Local nPosAux 			:= 0
Local nRecnoSE5			:= 0											// Recno do Registro da tabela SE5 (em ambiente OFF-Line eh considerado o recno da Retaguarda)
Local cForma			:= ""
Local nPosArrSE5		:= 1
Local aPgtosId			:= {} 											// Array apagtos ordenado
Local lTEFD				:= ExistFunc("L010TefD")
Local nColId			:= IIF(nModulo == 12 .OR. nModulo == 5, 08, 12)
Local cNumMov			:= AllTrim(LJNumMov())
Local lRecFilial		:= SuperGetMV( "MV_LJRECFI", NIL, .F. )			// Define que o recebimento de título pode ser realizado entre filiais
Local lImpNaoFis		:= IIF(!Empty(LjGetStation("IMPFISC")),.T.,.F.) // Sinaliza recebimento em equipamento nao fiscal
Local lRecNaoFis		:= LJModNFis()									// Sinaliza recebimento por modulo não fiscal(sem ECF) *NFC-e, Venda Direta
Local nRet				:= 0
Local nVlrTitPago		:= 0											// Armazena o valores dos titulos que serao baixados
Local lINFCutPpr		:= ExistFunc('INFCutPpr')
Local cAdmDesc			:= ""											// Descricao da Administradora FINANCEIRA do REcebimento
Local aNSUVndTef		:= {}
Local aAuxDados			:= {}											// Variavel Generica de 7 posicoes que guarda valores do TEF: { Data,Hora,Doc,Autorizacao,Instituicao,NSU,Tipo do cartao } 
Local lIsDiscado		:= L010IsDirecao(L010GetGPAtivo())
Local nSaldoNCC			:= 0 											// Controle de saldo das NCCs para a impressão comprovante de recebimento 
Local cFilBkp			:= cFilAnt 
Local cDescRec 			:= ""											// Descrição comprovante de recebimento
Local cCodCaixa			:= ""
Local cCodAg			:= ""
Local cCodConta			:= ""
Local aAreaSA6			:= SA6->(GetArea())								// Area da Tabela SA6
Local lAutomato 		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local aImpTotCab		:= {}
Local nCabTot			:= 0
Local nS				:= 0
Local nTotPagto			:= 0
Local cCabImp			:= ""
Local nSpace			:= 0
Local lRetold           := .F.
Local nY                := 0 
Local cMsgCart 			:= ""     										// Mensagem de apresentação para Sitef
Local cFormaPgto		:= ""											// Guarda a forma de pagamento
Local cMoedaOld			:= ""											// backup da moeda para ser restaurada quando a forma de pagamento for R$
Local cMsgRet			:= ""											// Mensagem de Retorno após erro de impressão
Local cFunNameBk 		:= ""

DEFAULT lTEFPendRec 	:= .F.
DEFAULT aBckTEFMult 	:= {}
DEFAULT lVerTEFPend 	:= .F.
DEFAULT nRelTroco		:= 0											// Valor do troco do recebimento de titulo a ser impresso no Relatorio Gerencial (Valor Pago - Valor Recebimento = nRelTroco)
DEFAULT lSelTefManu		:= .F.											// Define se foi selecionado o TEFManual para concluir operação de cartão
DEFAULT aTitSel 		:= {}
DEFAULT	aTitBXNCC 		:= {}
DEFAULT lTefManual		:= .F.											// Define se foi selecionado o TEFManual para concluir operação de cartão
DEFAULT aPagDig 		:= {}											// Informações de Pagamento Digital

If len(aTitSel) > 0
	aTitulo := aClone(aTitSel)
Endif

If lSelTefManu .And. !IsBlind()	
	
	For nX := 1 To Len(aPgtos)
		If Alltrim(aPgtos[nX][3]) $ _FORMATEF
			nY := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][nColId]}) //Forma + ID
						
			If nY > 0
				aNSUVndTef[nY][3] += aPgtos[nX][2]
			Else
				Aadd(aNSUVndTef,{AllTrim(aPgtos[nX][3]),aPgtos[nX][nColId],aPgtos[nX][2],"",""}) //Forma , ID , Valor , NSU digitada, Autorização Digitada
			EndIf

			If lUsaTef .And. cTipTef == TEF_CLISITEF
				// Chama a LjVerAdm para ajustar o array aPgtos na posicao referente ao Cod Adm Financeira
				LjVerAdm(.F.,.T.,.T.,nX,lSelTefManu)
			EndIf

		EndIf
	Next nX

	If Len(aNSUVndTef) > 0
		LjGrvLog(Nil, "_LJGrvRec - Chamada da Tela para Digitação da NSU - TEF Manual")
		For nX := 1 to Len(aNSUVndTef)
			LjxTelaNSU(@aNSUVndTef[nX])
		Next nX
		LjGrvLog(Nil, "_LJGrvRec - Chamada da Tela para Digitação da NSU - Retorno:" , aNSUVndTef)
	EndIf
Else
	If  ((nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa) ) .AND. lUsaTef .And. cTipTEF == TEF_DISCADO .AND. lIsDiscado
		aPgtosId := LJLoadDTEF()
	EndIf
EndIf

If Empty( cTotRecNFis )
	/*Declara o conteudo da variavel para o uso na impressao do recebimento nao fiscal.
	Faz este tratamento de inicialiacao desta variavel porque estavamo evitando o uso
	de variaveis privates no sistema.
	O FrontLoja ja' utilizava a variavel como Private e optamos pelo Venda Assistida 
	utiliza'-la com local.*/
	If !lAutomato
		If cGetCliDir == NIL
			cGetCliDir := GetClientDir()
		EndIf
		If cProfStr1 == NIL
			cProfStr1 := GetPvProfString("Recebimento Titulos", "Totalizadores", "01", GetClientDir()+"SIGALOJA.INI")
		Endif
		cTotRecNFis   := cProfStr1
	Else
		cTotRecNFis := "\SIGALOJA.INI"
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao da variavel aFormasPago                                ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ aFormasPago[1] - Forma de pagto                                      ³
//³ aFormasPago[2] - Valor                                               ³
//³ aFormasPago[3] - Numero do Cheque                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamaPgtos := Len( aPgtos )
For nX := 1 to nTamaPgtos
	nPosFormaPg := aScan( aFormasPago, { |x| x[1] == aPgtos[nX][3] .AND.  IIF( lChkslv .And. lUsaTef .and. (x[1] $ _FORMATEF .Or. x[1] $ _FORMAPGDG) .AND. lTefMult, x[6] == aPgtos[nX][nColId] , .T.) } )
	If nPosFormaPg > 0
		aFormasPago[nPosFormaPg][2] += aPgtos[nX][2]
	Else
		If AllTrim(aPgtos[nX][3]) == AllTrim(MVCHEQUE)
			cNumCheque := aPgtos[nX][4][7]
		EndIf
		If cPaisLoc $ "BRA|CHI|COL|MEX"
			//Realiza a verificação da variável de troco e a forma de pagamento R$, dessa forma no momento da ordenação será sempre a última forma
			//Foi necessário esse tratamento, para que o valor do troco seja considerada na última forma (R$), independente de outras formas no momento do recebimento
			If nRelTroco > 0 .And. nRelTroco < aPgtos[nX][2] .And. IsMoney(aPgtos[nX][3]) // Dinheiro
				cFormaPgto	:= "ZZ"
				cMoedaOld	:= aPgtos[nX][3]
			Else
				cFormaPgto := aPgtos[nX][3]
			EndIf
			aAdd( aFormasPago, { cFormaPgto   ,	aPgtos[nX][2], 1            , aPgtos[nX][2] , cNumCheque,  aPgtos[nX,nColId]} )
		Else
			aAdd( aFormasPago, { aPgtos[nX][3], aPgtos[nX][2], aPgtos[nX][6], aPgtos[nX][10], cNumCheque,  aPgtos[nX,nColId]} )
		EndIf
	Endif
Next nX

//Realiza a ordenação pela forma de pagamento e menor valor
ASort(aFormasPago ,,, { |x,y| ( x[1] < y[1] ) .Or. ( x[1] == y[1] .And. x[2] < y[2] ) } )

//Volta a forma de forma de pagamento pra dinheiro que foi alterada anteriormente
For nX := 1 To Len(aFormasPago)
	If aFormasPago[nX][1] == "ZZ"
		aFormasPago[nX][1] := cMoedaOld	
		Exit
	EndIf
Next nX

// Retorna se o pagamento foi realizado em TEF
lCartao := LJXVERTEF(.F., @aPgtos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//PREPARACAO AUTOMACAO
If lAutomato
	aTitulo := aClone(aTitAuto)
	cMV_LJRECEB := LJRecSistCr()
	M->LQ_CLIENTE := aTitAuto[1][13]
	M->LQ_LOJA := aTitAuto[1][14]
	aPgtosSint := Lj7MontPgt(aPgtos)//Carrega o array que deveria ter sido carregado durante execução da tela de recebimentos.
Endif	

//FIM PREPARACAO AUTOMACAO
AEval( aTitulo, { |x| If( x[TIT_SELE], nNumTit++, Nil ) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os titulos serao pagos com NCC. Alimenta o array         ³
//³ aRecnoNCC com os recnos das NCC selecionadas pelo usuario.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("aNccItens") <> "U"
	aAuxNccSel := aNccItens
ElseIf nModulo == 23 .And. !Empty(aNccRecSel) //23=SIGAFRT
	aAuxNccSel := aNccRecSel
EndIf
If !Empty(aAuxNccSel)
	aEval( aAuxNccSel, { |x| If( x[1], aAdd( aRecnoNCC, x[5] ), Nil ) } )
	If !Empty( aRecnoNCC )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta o array aRecnoSE1 com os recnos dos titulos para utilizar   ³
		//³ na compensacao dos titulos com as NCCs selecionadas pelo usuario     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEval( aTitulo, { |x| If( x[TIT_SELE], aAdd( aRecnoSE1, x[TIT_RECN] ), Nil ) } )
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Varre o array de titulos para verificar baixa multipla               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCount := 0
For nI := 1 to Len(aTitulo)
	If aTitulo[nI][TIT_SELE]
		nCount += 1

		If nCount > 1
			Exit
		EndIf
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se baixa Multipla, para controle do tipo de emissao do 	 ³
//³ comprovante( IFRecebNFis ou IFRelGer )                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lMultBaixa := (nCount > 1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a compensacao das NCCs que foram utilizadas para pagamento dos   ³
//³ titulos                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( aRecnoSE1 ) .AND. !Empty( aRecnoNCC ) .AND. !lErrSrv

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria array com valores a serem recebidos      ³
	//³ de cada titulo. Necessario caso o recebimento ³
	//³ do titulo seja parcial.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:=1 To Len(aTitulo)
		If aTitulo[nI][TIT_SELE]
			aAdd( aVlrReceb,{aTitulo[nI][TIT_RECE], aTitulo[nI][TIT_MULT], aTitulo[nI][TIT_JURO], aTitulo[nI][TIT_DESC], aTitulo[nI][TIT_RECN]})
		EndIf
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a Baixa de NCC via WebService   ³
	//³ caso FrontLoja ou Venda Ass. modo PDV.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nModulo == 23 .OR. (nModulo == 12 .AND. lMvLjPdvPa)
		If ExistFunc("Lj7BxNccWS")
			Lj7BxNccWS(cNccDoc,cNccSerie,cParcela,aRecnoSE1,aVlrReceb)
		EndIf
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a atualizacao dos campos E1_MULTA, E1_JUROS e E1_DESCONT         ³
		//³ Se no recebimento houve digitacao dos mesmos                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI:=1 to Len(aVlrReceb)
			If aVlrReceb[nI][2]>0 .OR. aVlrReceb[nI][3]>0 .OR. aVlrReceb[nI][4]>0
				FrtAtuaSE1(aVlrReceb, nI)
			Endif
		Next nI

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o bloco de codigo que sera' utilizado para gravar o campo     ³
		//³ E5_MOEDA na compensacao das NCCs                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA6->(dbSetOrder(1))
	    If SA6->(dbSeek(xFilial("SA6") + Upper(Alltrim(xNumCaixa()))))
 			cCodCaixa := SA6->A6_COD
 			cCodAg    := SA6->A6_AGENCIA
			cCodConta := SA6->A6_CONTA
 			
        ElseIf SA6->(dbSeek(FWxFilial("SA6",cFilBkp) + Upper(Alltrim(xNumCaixa())))) // Caso SA6 exclusivo | Utilizado a validação do FWxFilial somente aqui para não impactar as rotinas no momento
  			cCodCaixa := SA6->A6_COD
  			cCodAg    := SA6->A6_AGENCIA
			cCodConta := SA6->A6_CONTA
	    EndIf
	
		RestArea(aAreaSA6)
		bGravaMoeda := { || (RecLock("SE5",.F.),;
							SE5->E5_MOEDA		:= "CR",;
							SE5->E5_BANCO		:= cCodCaixa,;
							SE5->E5_AGENCIA	:= Iif(!Empty(cCodCaixa) .And. !Empty(cCodAg)   ,cCodAg  ,"."),;
							SE5->E5_CONTA		:= Iif(!Empty(cCodCaixa) .And. !Empty(cCodConta),cCodConta,"."),;
							MsUnlock()) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a rotina para compensacao das NCC com parametro == 3 que eh a  ³
		//³ Compensacao de titulos de mesma carteira (RA/NCC), passando um array ³
		//³ com os titulos que deverao ser baixados e os titulos que serao       ³
		//³ compensados                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFunNameBk := FunName() //Faz backup do Programa em execução
		SetFunName("LOJXREC") //Seta LOJXREC como Programa em execução para que seja gravado no campo E5_ORIGEM dentro da função MaIntBxCR
		For nX := 1 To Len(aVlrReceb)
			MaIntBxCR( 	3, {aVlrReceb[nX][5]}, 	Nil, aRecnoNCC,	Nil, Nil, bGravaMoeda,Nil,;
					    Nil, Nil, aVlrReceb[nX][1], Nil, Nil, Nil, Nil  )
		Next nX
		SetFunName(cFunNameBk) //Seta de volta o Programa em execução inicial

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria copia do array de titulos selecionados. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAntTit	:= aClone(aTitulo)

	If Len(aTitulo) > 0
		cCliente 	:= aTitulo[1][TIT_CLIE]
		cLoja		:= aTitulo[1][TIT_LOJA]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama funcao de carregamento de titulos, ela ira atulizar o array de   ³
	//³ titulos retirando os que ja foram totalmente baixados por compensacao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LJRecPesq( ,, aAntTit[1][TIT_CLIE], aAntTit[1][TIT_LOJA],,,,, .F. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz copia do array de titulos, agora atualizado. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAuxTit	:= aClone(aTitulo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera array de titulos. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTitulo := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona titulos que foram selecionados pelo usuario, mas ainda ³
	//³ nao foram baixados totalmente.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:=1 To Len(aAuxTit)
		nRetPos := aScan( aAntTit, { |X| X[TIT_RECN] == aAuxTit[nI][TIT_RECN] .AND. X[TIT_SELE]})
		If nRetPos > 0
			//Registro não baixado pela compensação, ou seja, ainda é o mesmo titulo antes da compensação:
			If (aAntTit[nRetPos][TIT_VALO] - aAuxTit[nI][TIT_VALO]) == 0
				aAuxTit[nI] := aAntTit[nRetPos]
				aAuxTit[nI][TIT_SELE] := .T.

			//Titulo compensado porem ainda resta saldo a ser baixado:
			ElseIf (aAntTit[nRetPos][TIT_RECE] - (aAntTit[nRetPos][TIT_VALO] - aAuxTit[nI][TIT_VALO])) > 0
				aAuxTit[nI][TIT_SELE] := .T.
				aAntTit[nRetPos][TIT_MULT] := 0
				aAntTit[nRetPos][TIT_JURO] := 0
				aAntTit[nRetPos][TIT_DESC] := 0
				aAntTit[nRetPos][TIT_ACRS] := 0
			EndIf
			aAdd(aTitulo, aAuxTit[nI])
		EndIf
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria array com titulos que foram totalmente ou parcialmente ³
	//³ baixados por compensacao para impressao.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:=1 To Len(aAntTit)
		nRetPos := aScan( aAuxTit, { |X| X[TIT_RECN] == aAntTit[nI][TIT_RECN] })
		If aAntTit[nI][TIT_SELE]
			If nRetPos == 0
				aAdd(aTitBXNCC, aAntTit[nI])
			ElseIf aAntTit[nI][TIT_VALO] > aAuxTit[nRetPos][TIT_VALO]
				aAdd(aTitBXNCC, aAntTit[nI])
			EndIf
		EndIf // Faco a verificacao do valor do Desconto ou acrescimo para verificar se  nao foi removido indevidademente  
		nRetPos := aScan( aTitulo, { |X| X[TIT_RECN] == aAntTit[nI][TIT_RECN] })
		If 	nRetPos > 0 .And. (aAntTit[nI][TIT_DESC] > 0 .Or. aAntTit[nI][TIT_JURO] > 0 .Or. aAntTit[nI][TIT_MULT] > 0 )
			aTitulo[nRetPos][TIT_MULT] := aAntTit[nI][TIT_MULT]
			aTitulo[nRetPos][TIT_JURO] := aAntTit[nI][TIT_JURO]
			aTitulo[nRetPos][TIT_DESC] := aAntTit[nI][TIT_DESC]
			aTitulo[nRetPos][TIT_RECE] := aAntTit[nI][TIT_RECE]
		EndIf
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao de impressao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecebNFis(	@aTitBXNCC		, @lFiscal	, @lMultBaixa	, @nTotComprovante,;
				@cNumDocumento	, @nEspaco	, @nHdlECF		, @cMsgCompTitulo,;
				@cTotRecNFis	, @cMvSimb1	, @nCntTit		, @cMsgComprovante,;
				@cSimbCor)
EndIf

If cPaisLoc == "BRA"
	lTroco  := SuperGetMV("MV_LJTROCO",,.F.)
Else
	lTroco  := SuperGetMV("MV_LJTRLOC",,.F.)
EndIf

For nCount := 1 To Len(aPgtos)
	nTotalPg += aPgtos[nCount][2]
	
	///////////////////////////////////////////////////////////////////////////
	//Chamada da rotina para seleção do cartão quando se tratar do TEF manual//
	///////////////////////////////////////////////////////////////////////////
	If ValType( aPgtos[nCount][4] ) == "A" .AND. nModulo <> 23 .AND. Len(aPgtos[nCount][4]) > 0 .AND. !(AllTrim(aPgtos[nCount][_FORMAPGTO]) $ _FORMAPGDG)
		aPgtos[nCount][4][5]  := LJ7ConfAdm( aPgtos[nCount][4][5], Nil, .F., aPgtos[nCount][_FORMAPGTO] , aPgtos[nCount][8], Nil, Nil, Nil,;
											 lTefManual, Nil, Nil, Nil, Nil, Nil, lSelTefManu)
	EndIf
																		  
Next nCount

If lTroco
	If cPaisLoc == "BRA"
		For nI := 1 To Len(aTitulo)
			If aTitulo[nI][TIT_SELE]
	   			nValReceb   += aTitulo[nI][TIT_RECE]
	  		EndIf
		Next nI
		nCalcTroco := nTotalPg - nValReceb
	EndIf
EndIf

//Inicializa o contador do laco do array aFormasPago
nParc := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somente se existir formas de pagamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotalPg > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre o array de titulos para fazer a baixa dos que foram seleciona- ³
	//³ dos                                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aTitulo)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o titulo foi selecionado, faz a baixa                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTitulo[nI][TIT_SELE]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz um laco no aFormasPago para baixar os titulos conforme a forma de³
			//³ pagamento utilizada.                                                 ³
			//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
			//³ Exemplo: Se um titulo de R$100,00 for pago com R$50,00 em dinheiro e ³
	 		//³ R$50,00 em cheques deverá haver 2 baixas para este titulo. Cada re-  ³
	 		//³ gistro no SE5 tera a forma de pagamento pois estas informacoes serao ³
	 		//³ usadas no resumo de caixa.                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlrTitulo	:= aTitulo[nI][TIT_RECE]
			nVlrTitPago += aTitulo[nI][TIT_RECE]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o titulo se ja foi baixado ou nao no SE1, validando o E1_SALDO com o valor recebido e do titulo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaE1		:= SE1->( GetArea() )                        // Area atual do SE1
			SE1->( DbSetOrder( 1 ) )
			If SE1->( DbSeek( IIF(lRecFilial,aTitulo[nI][TIT_FILI],xFilial("SE1")) + aTitulo[nI][TIT_PREF] + aTitulo[nI][TIT_NUME] + aTitulo[nI][TIT_PARC] + aTitulo[nI][TIT_TIPO] ) )
				If SE1->E1_SALDO == 0 .AND. AllTrim(SE1->E1_TIPO) $ cTpRec 
					lRet := .F.
					MsgStop( STR0103 + aTitulo[nI][TIT_PREF] + " " + aTitulo[nI][TIT_NUME] + STR0104 ,STR0030)		//"O titulo " # " ja foi baixado ", "Atenção!"
					aTitulo[nI][TIT_SELE] := .F.
				Endif
			Endif
			RestArea( aAreaE1 )

			lPrimBaixa	:= .T.
			nTotReceb	:= 0
			Lj7Arred(1) // limpa array statico da função de arredondamento
			lEmiteComp	:= .T.

			While nParc <= Len( aFormasPago ) .AND. nVlrTitulo > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ EMS - Eletronic Market Solution                                      ³
				//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
				//³ Chama a funcao para baixar o titulo no servidor CCS.                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cMV_LJRECEB == "4"
					cAux := aTitulo[nI][TIT_PREF] + Substr(aTitulo[nI][TIT_NUME],1,Len(aTitulo[nI][TIT_NUME])-2) + Right(aTitulo[nI][TIT_NUME],1)
					lRet := LJEMSBaixa(cAux, aTitulo[nI][TIT_PARC], aTitulo[nI][TIT_RECE])
					If !lRet
						aAdd( aRet, AClone(aTitulo[nI]) )
					Endif
				Endif
				If lRet

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz uma copia do array aTitulo para trabalhar com o array aAux       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAux := AClone(aTitulo[nI])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se a forma de pagamento atual tem saldo para baixar o titulo³
					//³ completo, caso negativo, baixa apenas o valor que resta na forma de  ³
					//³ pagto atual e passa para a proxima forma para continuar baixando o   ³
					//³ titulo                                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If IIf(aFormasPago[nParc][3] > 1, (aFormasPago[nParc][4] >= nVlrTitulo), (aFormasPago[nParc][2] >= nVlrTitulo))

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Zera o valor do titulo pq sera baixado completo e abate o valor do   ³
						//³ titulo do array de formas de pagamento e ajusta quanto sera' recebido³
						//³ para os casos de pagamentos em mais de uma forma de pagamento        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nValReceb -= nVlrTitulo
						
						If nVlrTitulo > 0 .And. nValReceb == 0
							nValTroco := nCalcTroco 
						EndIf 

						aAux[TIT_RECE] := nVlrTitulo
						If ValType(aFormasPago[nParc][3]) == "N" .AND. aFormasPago[nParc][3] > 1
							aFormasPago[nParc][4] -= nVlrTitulo
						Else
							aFormasPago[nParc][2] -= nVlrTitulo
						EndIf

						nVlrTitulo := 0

					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Abate o valor da forma de pagamento do titulo e deixa fazer          ³
						//³ o looping para baixar o restante do titulo com outra forma de pagto. ³
						//³ Abate tambem o valor que sera' recebido no array aAux                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						aAux[TIT_RECE]	:= IIf(aFormasPago[nParc][3] > 1, aFormasPago[nParc][4], aFormasPago[nParc][2])
						nValReceb 		-= aAux[TIT_RECE]
						nVlrTitulo		-= IIf(aFormasPago[nParc][3] > 1, aFormasPago[nParc][4], aFormasPago[nParc][2])
						If aFormasPago[nParc][3] > 1
							aFormasPago[nParc][4] 	-= aFormasPago[nParc][4]
						Else
							aFormasPago[nParc][2] 	-= aFormasPago[nParc][2]
						EndIf

					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz o controle de multa, juros e descontos dos titulos               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTotReceb  += aAux[TIT_RECE]

					If !lPrimBaixa
						//Limpa valores de Multa,Juros,Desconto para que seja atualizado somente na primeira baixa com o respectivo valor total
					   	nPrimMulta   := 0
					   	nPrimJuros   := 0
					   	nPrimDescon  := 0
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Armazena os valores de Multa, Juros e Desconto para serem gravados no arquivo SE1 e Totais para calculo do Rateio ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					   	nPrimMulta	:= aAux[TIT_MULT]
					   	nPrimJuros	:= aAux[TIT_JURO]
					   	nPrimDescon	:= aAux[TIT_DESC]

					   	nTotMulta	:= aAux[TIT_MULT]
					   	nTotJuros   := aAux[TIT_JURO]
					   	nTotDescon  := aAux[TIT_DESC]

					   	//Para controle do valor restante do rateio
					   	nRestMulta	:= aAux[TIT_MULT]
					   	nRestJuros  := aAux[TIT_JURO]
					   	nRestDescon := aAux[TIT_DESC]
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quando possui Multa, Juros e/ou Desconto, faz rateio do valor por Forma de Pagto para serem gravados no arquivo SE5 ³
					//³ Se registro da ultima forma de Pagto, atribui valor restante para evitar erros de arredondamentos/diferenca centavos³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nParc == Len( aFormasPago )
					   	aAux[TIT_MULT]	:= nRestMulta
					   	aAux[TIT_JURO]	:= nRestJuros
					   	aAux[TIT_DESC]	:= nRestDescon
					Else
						nPercPagto	:= NoRound((aFormasPago[nParc][4] / nTotalPg) * 100)

					   	aAux[TIT_MULT]	:= Lj7Arred(2,1,nTotMulta  * (nPercPagto / 100) )
					   	aAux[TIT_JURO]	:= Lj7Arred(2,2,nTotJuros  * (nPercPagto / 100) )
					   	aAux[TIT_DESC]	:= Lj7Arred(2,3,nTotDescon * (nPercPagto / 100) )

					   	//Atualiza restante a ser registrado
					   	nRestMulta	-= aAux[TIT_MULT]
					   	nRestJuros  -= aAux[TIT_JURO]
					   	nRestDescon -= aAux[TIT_DESC]
					EndIf

					lPgTef := ( Alltrim(aFormasPago[nParc, 1]) $ _FORMATEF .Or. Alltrim(aFormasPago[nParc, 1]) $ _FORMAPGDG ) .AND. lChkslv .And. lUsaTef

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz um tratamento diferenciado se o modulo for FRONTLOJA ou Venda Assistida em modo PDV     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa) )
						If ValType(oSvc) <> "O"
							oSvc      := WSLJRECEB():New()
                            iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
							oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"
						Endif

						//Alimenta aqui uma parte do array aSE5Dados, devido estar executando via Web Service
						If lPgTef .And. Type("oSvc:oWsaDadosSLV") == "O" //Verifica se existe a estrutura aDadosSLV [apenas uma protecao caso o fonte WSC_LJRECEB.PRW (client deste WS) nao esteja atualizado as alteracoes necessarias]

							For nX := 1 To Len(aPgtos)

								cForma  := AllTrim(aPgtos[nX,3])

								//ID do Cartao               // CC;CD
								If (Empty(aPgtos[nX,nColId]) .AND. !(cForma $ _FORMATEF)) .Or. ( AllTrim(cForma) <> AllTrim(aFormasPago[nParc][1]) .OR. (aPgtos[nX][nColId] <> aFormasPago[nParc, 6] ) )
									Loop
								EndIf

								nPosRetCart := 0

								If cForma $ _FORMATEF .And. cTipTef == TEF_CLISITEF  .AND. lUsaTef
									nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgtos[nX][nColId] } ), 1)
								ElseIf lUsaTef .AND. cForma $ _FORMATEF .And. cTipTef == TEF_DISCADO 
									nPosRetCart := Iif(lTefMult, aScan(aTEFDados, {|x| x[19] == aPgtos[nX][nColId] } ), 1)	
								Endif
								
								LjxRTefDa(	@aAuxDados	, aPgtos	, aNSUVndTef	, lUsaTef	,;
											cTipTef 	, nColId	, nPosRetCart	, nX		,;
											aPagDig		)
								nY := Len(aAuxDados)
								cNSUTEFAux	:= aAuxDados[nY][6]
								cAutTEFAux	:= aAuxDados[nY][4]
								nPosAux		:= aScan(aSE5Dados , {|x| x[16] == cNSUTEFAux .And. x[14] == cAutTEFAux .And. x[19] == 0 } )

								If nPosAux == 0
									AADD(aSE5Dados,	{	""				, ;				//01-E5_PREFIXO
														"" 				, ;				//02-E5_NUMERO
														""				, ;				//03-E5_PARCELA
														""				, ;				//04-E5_TIPO
														""				, ;				//05-E5_SEQ
														""				, ;				//06-E5_FILORIG
														""				, ;				//07-E5_CLIENTE
														""				, ;				//08-E5_LOJA
														cForma			, ;				//09-Forma Pgto.
														aPgtos[nX, 2]	, ;				//10-Valor
														aAuxDados[nY][1], ; 			//11-Data
														aAuxDados[nY][2], ; 			//12-Hora
														aAuxDados[nY][3], ; 			//13-Doc
														aAuxDados[nY][4], ; 			//14-Autorizacao
														aAuxDados[nY][5], ; 			//15-Instituicao
														aAuxDados[nY][6], ; 			//16-NSU
														aAuxDados[nY][7], ; 			//17-Tipo do cartao
														"" 				, ;				//18-SEQOPER
														0				, ;				//19-RECSE5 - Recno do registro SE5
														"" 				, ;				//20-Doc Cancelamento TEF
														"" 				, ;				//21-Hora Cancelamento TEF
														"" 				, ;				//22-Data Cancelamento TEF
														Iif(Len(aAuxDados[nY])>=10,aAuxDados[nY][ 9],"")	,;	//23-Código da Bandeira
														Iif(Len(aAuxDados[nY])>=10,aAuxDados[nY][10],"")	,;	//24-Código Rede (Adquirência)
														Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][11],"")	,;	//25-Id da transação do Totvs Pagamento Digital (TRNID)
														Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][12],"")	,;	//26-Id da transação do processador do Totvs Pagamento Digital (TRNPCID)
														Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][13],"")	})	//27-Id externa da transação do Totvs Pagamento Digital (TRNEXID)
								Else
									aSE5Dados[nPosAux][10] += aPgtos[nX, 2] //10-Valor
								EndIf
							Next nX

						EndIf
						
						// Efetua a baixa do titulo via webservice
						For nY := 1 to 1  // Caso o WebService nao responda na primeira tento uma segunda vez 
							LjGrvLog("LojxRec" ,"Vai executar o baixa de titulo oSvc:BaixaTitulo" )
							lRet := oSvc:BaixaTitulo(	cMV_LJRECEB,	aAux[TIT_PREF],			aAux[TIT_NUME],		aAux[TIT_PARC],;
														aAux[TIT_VREA],	aAux[TIT_VALO],			aAux[TIT_MULT],		aAux[TIT_JURO],;
														aAux[TIT_DESC],	aAux[TIT_RECE], 		aAux[TIT_TIPO],		cCartao,;
								 						aAux[TIT_FILI],	aFormasPago[nParc][1],	cUserName,			aAux[TIT_ABAT],;
								 						cEmpAnt		  , cFilAnt				,   lMvLjPdvPa, 		nValTroco,;
								 						lPrimBaixa	  , nTotReceb,				cNumMov )
						
					 		If !lRet						    	
						    	LjGrvLog("LojxRec" ,"Não foi possivel concluir a baixa do titulo " )
						    	Sleep(15000)
						    	 
								// Faço um conexao Via Rpc para verificar se os Titulos Foram baixados
								LjGrvLog("LojxRec" ,"Vai executar a rotina via rpc para verificar a baixa" )
								lRet := LjxRecRpc(aTitulo)	
						
								If !lRet 	
									LjGrvLog("LojxRec" ,"Não Foi possivel Realizar a baixa do Titulo, Realize a Baixa novamente.",aTitulo )
								Else
									LjGrvLog("LojxRec" ,"Verificação via RPC achou o Titulo baixado" )								
								EndIf					
											    	
						    	If !lRet  .And. MsgYesNo( STR0199 + CRLF + STR0200 ) // "Não foi possivel Realizar a baixa do Título" .... "Deseja tentar novamente?"
						    		nY := 0
						    		LjGrvLog("LojxRec" ,"Vai executar a chamada da baixa de titulo novamente")
						    	EndIf
						    EndIf	
						Next nY											

						If lPgTef .And. Type("oSvc:nBaixaTituloResult") == "N" //Verifica se o retorno do WS eh do tipo numerico [apenas uma protecao caso o fonte WSC_LJRECEB.PRW (client deste WS) nao esteja atualizado as alteracoes necessarias]
							nRecnoSE5 := oSvc:nBaixaTituloResult
							//Atualiza o array aSE5Dados com o RECNO do registro SE5 gerado
							If nRecnoSE5 > 0
								For nX:=nPosArrSE5 To Len(aSE5Dados)
									aSE5Dados[nX][19] := nRecnoSE5
									nPosArrSE5++
								Next nX
							EndIf
						EndIf

						If ValType( lRet ) <> "L"
							lRet := .F.
						Endif
						 
						//Ponto de entrada executado depois do retorno do webservice
						If ExistBlock("LJXRECVLD")
							lRetold := lRet
							lRet := ExecBlock("LJXRECVLD", .F., .F.,{cOper, nTotal, aTitulo,lRet })
							
							LjGrvLog("LojxRec" ,"Retorno do ponto de entrada LJXRECVLD lRet :", lRet )
							
							If ValType( lRet ) <> "L"
								lRet := lRetold
							Endif
						EndIf
						If lRet

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se cupom ja foi impresso para este titulo. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nRetPos := aScan( aTitBXNCC, { |X| X[TIT_RECN] == aTitulo[nI][TIT_RECN] })
							If nRetPos == 0

								lPrimBaixa  := .F.
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Realiza o(s) Recebimento Nao-Fiscal e a Autenticacao do(s) documento(s) ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If aTitulo[nI][1] .AND. lEmiteComp .AND. (lFiscal .OR. LjNfPtgNEcf(SM0->M0_CGC)) //PTG e ANG sem ECF - ira efetuar a impressao do comprovante em uma impressora comum
									lEmiteComp	:= .F.

									If lFrtRecTit
										LjGrvLog("RECEBIMENTO",ProcName(0) + " - Ponto de Entrada FRTRECTIT" , { nI, aTitulo , nRelTroco} )
										ExecBlock( "FRTRECTIT", .F., .F., { nI, aTitulo, nRelTroco } )
										LjGrvLog("RECEBIMENTO",ProcName(0) + " - Saida do Ponto de Entrada FRTRECTIT" )
									ElseIf cPaisLoc <> "MEX"
										If  !lAutomato .AND. !IsBlind() .AND. !File( GetClientDir()+"SIGALOJA.INI" )
											WritePProString("Recebimento Titulos", "Totalizadores", "01", GetClientDir()+"SIGALOJA.INI")
										Endif

									   	If !Empty(aTitulo[nI][TIT_CONT])
											cMsgComprovante += aTitulo[nI][TIT_CONT] + "/" + aTitulo[nI][TIT_PARC] + Space(12) + cMvSimb1 + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)
			 							Else
											cNumDocumento	:= aTitulo[nI][TIT_PREF] + "/" + aTitulo[nI][TIT_NUME]
											nEspaco 		:= 40 - ( Len ( cNumDocumento ) + Len ( cMvSimb1 ) + Len ( aTitulo[nI][TIT_PARC] ) + 15  )
											cMsgComprovante += cNumDocumento + "/" + aTitulo[nI][TIT_PARC] + Space( nEspaco ) + cMvSimb1 + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)
										EndIf
										cCliente 		:= aTitulo[nI][TIT_CLIE]
										cLoja			:= aTitulo[nI][TIT_LOJA]

										If lMultBaixa
											//       "C O M P R O V A N T E"
											//   "D E   R E C E B I M E N T O"
											//"Cliente : "
										    //"Documento                         Valor"
										    //"T O T A L "
											
											///////////////////////////////////////////////////////////////////////////////////////////////////////////////								
											//Controlo os totais por títulos baixados para a correta impressão do cabeçalho do comprovante de recebimento//
											///////////////////////////////////////////////////////////////////////////////////////////////////////////////
											If Len(aImpTotCab) == 0 
												For nS := 1 To Len(aTitulo)
												
													nCabTot := aScan(aImpTotCab,{ |x| x[01] == aTitulo[nS,TIT_NUME] })
													
													If aTitulo[nS,TIT_SELE] .And.  nCabTot == 0 
														aAdd(aImpTotCab, {aTitulo[nS,TIT_NUME],aTitulo[nS,TIT_RECE]})
													ElseIf aTitulo[nS,TIT_SELE] .And.  nCabTot <> 0
														aImpTotCab[nCabTot,02] += aTitulo[nS,TIT_RECE]								 
													EndIf
													
												Next nS
											EndIf
											
											nTotPagto := aImpTotCab[aScan(aImpTotCab,{ |x| x[01] == aTitulo[nI,TIT_NUME] }),02] 
											nSpace := 40 - Len(cNumDocumento + &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Trans(nTotPagto,"@E 999,999,999.99"))//Variável para controle da impressão das colunas
											 									
											If Empty(cCabImp) .Or. cCabImp <> aTitulo[nI,TIT_NUME] 
												cMsgCompTitulo 	:= 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
																	Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
																	Chr(10) + Chr(10) +;
																	STR0055 + Posicione( "SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_NOME") +;
																	Chr(10) + Chr(10) +;
																	IIF(!Empty(aTitulo[nI][TIT_CONT]),STR0013,STR0056) + Chr(10) +;
																	Replicate("=",40) + Chr(10) +;
																	Chr(10) +;
																	cNumDocumento +;
																	&(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Space(nSpace) + Trans(nTotPagto,"@E 999,999,999.99") //aTitulo[nI][TIT_RECE] substituido pela varialvel nTotPagto, pois preciso imprimir o total a ser pago
											EndIf
											
																						//Tratamento para recebimento no Faturamento, permite receber sem impressora configurada
											If lRecNaoFis

												If lImpNaoFis
													If Empty(cCabImp) .Or. cCabImp <> aTitulo[nI,TIT_NUME]																						
														cMsgCompTitulo 	:= 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
																			Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
																			Chr(10) + Chr(10) +;
																			STR0055 + Posicione( "SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_NOME") +;
																			Chr(10) + Chr(10) +;
																			IIF(!Empty(aTitulo[nI][TIT_CONT]),STR0013,STR0056) + Chr(10) +;
																			Replicate("=",40) + Chr(10) +;
																			Chr(10) +;
																			cNumDocumento +;
																			&(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Space(nSpace) + Trans(nTotPagto,"@E 999,999,999.99") //aTitulo[nI][TIT_RECE] substituido pela varialvel nTotPagto, pois preciso imprimir o total a ser pago

													EndIf
													nRet := INFTexto(cMsgCompTitulo)  //Envia comando para a Impressora
													If nRet <> 0
														cMsgRet := STR0208 //"INFTexto: Erro na Impressão do Comprovante."
													EndIf
													
													If lINFCutPpr .And. Empty(cCabImp) .Or. cCabImp <> aTitulo[nI,TIT_NUME] 
														INFCutPpr()
													EndIf
													
													////////////////////////////////////////////////////////////////
													//Atualizando variavel para controle de impressão do cabeçalho//
													////////////////////////////////////////////////////////////////
													cCabImp := aTitulo[nI,TIT_NUME]
												Else
													nRet := 0 //Permite recebimento sem impressora no Faturamento
												EndIf
											Else
												nRet := IFRelGer( nHdlECF, cMsgCompTitulo, 1 )
												If nRet <> 0
													cMsgRet := STR0209 //"IFRelGer: Erro na Impressão do Relatório Gerencial."
												EndIf
											EndIf

											cMsgCompTitulo := ""
										Else
											If cPaisLoc == "BRA"

													If lRecNaoFis
														If lImpNaoFis
															
															nSpace := 40 - Len(cNumDocumento + &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99"))//Variavel para controle da impressão das colunas
															
															cMsgCompTitulo 	:= 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
																				Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
																				Chr(10) + Chr(10) +;
																				STR0055 + Posicione( "SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_NOME") +;
																				Chr(10) + Chr(10) +;
																				IIF(!Empty(aTitulo[nI][TIT_CONT]),STR0013,STR0056) + Chr(10) +;
																				Replicate("=",40) + Chr(10) +;
																				Chr(10) +;
																				cNumDocumento +;
																				&(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Space(nSpace) + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99")

															nRet := INFTexto(cMsgCompTitulo)  //Envia comando para a Impressora
															If nRet <> 0
																cMsgRet := STR0208 //"INFTexto: Erro na Impressão do Comprovante."
															EndIf
															If lINFCutPpr
																INFCutPpr()
															EndIf

														Else
															nRet := 0
														EndIf
													Else
														nRet := IFRecebNFis( nHdlECF, cTotRecNFis, aTitulo[nI][TIT_RECE], &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')))
														If nRet <> 0
															cMsgRet := STR0217	//"IFRecebNFis: Erro na Impressão do Recebimento Não-Fiscal."
														EndIf
													EndIf

											Else
												nRet := 0
											EndIf
										EndIf

										If nRet <> 0
											MsgStop(cMsgRet, STR0030)	//"Atenção!"
											LjGrvLog("Recebimento_Titulo", cMsgRet)
										Else
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Alimenta a msg para impressao do comprovante de recebimento com os dados³
											//³ dos titulos e do cliente e faz a somatoria de todos os pagamentos       ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											/*If !Empty(aTitulo[nI][TIT_CONT])//Trecho comentado para que não ocorra a duplicidade na impressão dos itens
												cMsgComprovante += aTitulo[nI][TIT_CONT] + "/" + aTitulo[nI][TIT_PARC] + Space(12) + cMvSimb1 + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)
			 								Else
												cNumDocumento	:= aTitulo[nI][TIT_PREF] + "/" + aTitulo[nI][TIT_NUME]
												nEspaco 		:= 40 - ( Len ( cNumDocumento ) + Len ( cMvSimb1 ) + Len ( aTitulo[nI][TIT_PARC] ) + 15  )
												cMsgComprovante += cNumDocumento + "/" + aTitulo[nI][TIT_PARC] + Space( nEspaco ) + cMvSimb1 + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)
											EndIf*/

											nTotComprovante += aTitulo[nI][TIT_RECE]
											cCliente 		:= aTitulo[nI][TIT_CLIE]
											cLoja			:= aTitulo[nI][TIT_LOJA]

											If SuperGetMV( "MV_CRDAUT", NIL, .T. ) .AND. !LJModNFis()
											    //"Autenticação do documento", "Insira o ", "o. documento, no valor de "
											    //" para autenticacäo...", "Autenticar", "Ignorar"
												nCntTit++
												If Aviso(STR0046, STR0047+AllTrim(Str(nCntTit))+STR0048+cSimbCor+" "+;
													AllTrim(Transform(aTitulo[nI][TIT_RECE], PesqPict("SE1", "E1_VALOR", 15)))+;
													STR0049, {STR0050, STR0051}) == 1
													IFAutentic( nHdlECF, "2", "", "")
												Endif
											Endif
										Endif
									Endif
								Endif
							EndIf

							If nRet <> 0

								AAdd(aRet, AClone(aTitulo[nI]))
								lRet := .F.
								cOper := "2"
								MsgStop(cMsgRet, STR0095)	// "Atenção"
								LjGrvLog("Recebimento_Titulo", cMsgRet)
								LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
								Return aRet

							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Este SE5 nao devera subir para a retaguarda. ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								Reclock("SE5",.T.)
								REPLACE SE5->E5_FILIAL	WITH xFilial("SE5")
								REPLACE SE5->E5_DATA	WITH dDataBase
								REPLACE SE5->E5_TIPO	WITH "FI"
								REPLACE SE5->E5_BANCO	WITH xNumCaixa()
								REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
								REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
								REPLACE SE5->E5_RECPAG	WITH "R"
								//"Recebimento do Titulo "
								REPLACE SE5->E5_HISTOR	WITH "LOJ-"+STR0044+aAux[TIT_PREF]+"/"+aAux[TIT_NUME]+"/"+cParcela
								REPLACE SE5->E5_TIPODOC	WITH "VL"
								REPLACE SE5->E5_MOEDA	WITH AllTrim(aFormasPago[nParc][1])
								REPLACE SE5->E5_FORMAPG	WITH AllTrim(aFormasPago[nParc][1])
								REPLACE SE5->E5_ORIGEM	WITH "LOJXREC"
								REPLACE SE5->E5_VALOR	WITH aAux[TIT_RECE]
								REPLACE SE5->E5_DTDIGIT	WITH dDataBase
								REPLACE SE5->E5_BENEF	WITH Space(15)
								REPLACE SE5->E5_DTDISPO	WITH SE5->E5_DATA
								REPLACE SE5->E5_NATUREZ	WITH &(SuperGetMV("MV_NATRECE"))			// RECEBIMENTO
								Replace SE5->E5_NUMMOV	WITH cNumMov
								REPLACE SE5->E5_PREFIXO	WITH aAux[TIT_PREF]
								REPLACE SE5->E5_NUMERO	WITH aAux[TIT_NUME]
								dbCommit()
								MsUnLock()
							EndIf

						Else
							AAdd(aRet, AClone(aTitulo[nI]))

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//| *** Aqui devera ser melhor tratado as mensagens de erro...|
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cSvcError := GetWSCError()
							lErrSrv   := .T.
							If Left(cSvcError,9) == "WSCERR048"
								cSoapFCode  := GetWSCError(2)
								cSoapFDescr := GetWSCError(3)
								MsgStop(cSoapFDescr, cSoapFCode)
							Else
								cSoapFCode  := GetWSCError(2)
								cSoapFDescr := GetWSCError(3)
								LjGrvLog("LojxRec" ,"Erro no WebService de Recebimento Mensagem :"+cSvcError)
								Conout("LojxRec - Erro no WebService de Recebimento Mensagem :"+cSvcError)
								If !Empty(cSoapFCode)
									LjGrvLog("LojxRec" ,"Erro no WebService de Recebimento Codigo :"+cSoapFCode)	
									Conout("LojxRec - Erro no WebService de Recebimento Codigo :"+cSoapFCode)
								EndIf
								If !Empty(cSoapFDescr)
									LjGrvLog("LojxRec" ,"Erro no WebService de Recebimento Descritivo :"+cSoapFDescr)
									Conout("LojxRec, Erro no WebService de Recebimento Descritivo :"+cSoapFDescr)
								EndIf								
							    //"Sem comunicação com o WebService!", "Atenção!"
							    MsgStop(STR0029,STR0030)
							    If  lUsaTef .And. cTipTEF == TEF_CLISITEF .AND. lCartao
							    	LjGrvLog("Doc: "+oTef:cCupom ,"Vai executar o Desfazimento da transacao - Cartoes :",oTef:aRetCartao )	
									oTef:FinalTrn(0)									
									If Len(oTef:aRetCartao) > 0 
										cMsgCart := ""
										For nY := 1 To Len(oTef:aRetCartao)
											cMsgCart += CRLF + STR0202 + oTef:aRetCartao[nY]:CDESCCART  //"Cartão "
											cMsgCart +=  STR0203 + AllTrim(Transform(oTef:aRetCartao[nY]:nVlrTrans, "@E 99,999,999.99")) //" | Valor: " 
										Next nY
									EndIf
									MsgAlert(STR0201 + cMsgCart )	//"Devido problema de comunicação com Web Service, o Recebimento do Título não foi concluído e a transação com cartão apresentada abaixo foi desfeita:"								
							    EndIf							     
							    LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
								Return aRet
							Endif
						Endif
					Else

						/* Verifica se esta' existe valor para baixa do titulo. Se estiver zera-
						 do, trata-se de pagamento com NCC*/
						If aAux[TIT_RECE] > 0
							If !LJRecBXSE1(	cMV_LJRECEB		, aAux[TIT_PREF]		, aAux[TIT_NUME]	, aAux[TIT_PARC]	,;
											aAux[TIT_VREA]	, aAux[TIT_VALO]		, aAux[TIT_MULT]	, aAux[TIT_JURO]	,;
											aAux[TIT_DESC]	, aAux[TIT_RECE]		, aAux[TIT_TIPO]	, ""				,;
											aAux[TIT_FILI]	, aFormasPago[nParc][1]	, lPrimBaixa		, nPrimMulta		,;
											nPrimJuros		, nPrimDescon			, nTotReceb			, @aSe5Dados		,;
											lPgTef			, cUserName				, aAux[TIT_ABAT]	, @aSE5Bxas			,;
											@aTitBxSE5		, aFormasPago[nParc][5]	, @aTitDelSE5		, nValTroco			,;
											aFormasPago[nParc][3],	Nil		 	    , .F.				, cNumMov			,;
											aNSUVndTef		, aFormasPago[nParc, 6]	, aPagDig			)

								AAdd(aRet, AClone(aTitulo[nI]))

							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Verifica se cupom ja foi impresso para este titulo. ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								nRetPos := aScan( aTitBXNCC, { |X| X[TIT_RECN] == aTitulo[nI][TIT_RECN] })	
								If nRetPos == 0

									lPrimBaixa  := .F.

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Realiza o(s) Recebimento Nao-Fiscal e a Autenticacao do(s) documento(s) ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If aTitulo[nI][1] .AND. lEmiteComp .AND. (lFiscal .OR. lRecNaoFis .OR. LjNfPtgNEcf(SM0->M0_CGC) ) //PTG e ANG sem ECF - ira efetuar a impressao do comprovante em uma impressora comum
										lEmiteComp	:= .F.

										If lFrtRecTit
											LjGrvLog("RECEBIMENTO",ProcName(0) + " - Ponto de Entrada FRTRECTIT" , { nI, aTitulo } )
											ExecBlock( "FRTRECTIT", .F., .F., { nI, aTitulo } )
											LjGrvLog("RECEBIMENTO",ProcName(0) + " - Saida do Ponto de Entrada FRTRECTIT" )
										ElseIf cPaisLoc <> "MEX"
											If !lAutomato .AND. !IsBlind() .AND. !File( GetClientDir()+"SIGALOJA.INI" )
												WritePProString("Recebimento Titulos", "Totalizadores", "01", GetClientDir()+"SIGALOJA.INI")
											Endif

										   	If !Empty(aTitulo[nI][TIT_CONT])
												cMsgComprovante += aTitulo[nI][TIT_CONT] + "/" + aTitulo[nI][TIT_PARC] + Space(12) + cMvSimb1 + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)
				 							Else
												cNumDocumento	:= aTitulo[nI][TIT_PREF] + "/" + aTitulo[nI][TIT_NUME]
												nEspaco 		:= 40 - ( Len ( cNumDocumento ) + Len ( cMvSimb1 ) + Len ( aTitulo[nI][TIT_PARC] ) + 15  )
												cMsgComprovante += cNumDocumento + "/" + aTitulo[nI][TIT_PARC] + Space( nEspaco ) + cMvSimb1 + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)
											EndIf
										   	
										   	cCliente 		:= aTitulo[nI][TIT_CLIE]
											cLoja			:= aTitulo[nI][TIT_LOJA]

											If lMultBaixa
												//       "C O M P R O V A N T E"
												//   "D E   R E C E B I M E N T O"
												//"Cliente : "
											    //"Documento                         Valor"
											    //"T O T A L "
												///////////////////////////////////////////////////////////////////////////////////////////////////////////////								
												//Controlo os totais por títulos baixados para a correta impressão do cabeçalho do comprovante de recebimento//
												///////////////////////////////////////////////////////////////////////////////////////////////////////////////
												If Len(aImpTotCab) == 0 
													For nS := 1 To Len(aTitulo)
													
														nCabTot := aScan(aImpTotCab,{ |x| x[01] == aTitulo[nS,TIT_NUME] })
														
														If aTitulo[nS,TIT_SELE] .And.  nCabTot == 0 
															aAdd(aImpTotCab, {aTitulo[nS,TIT_NUME],aTitulo[nS,TIT_RECE]})
														ElseIf aTitulo[nS,TIT_SELE] .And.  nCabTot <> 0
															aImpTotCab[nCabTot,02] += aTitulo[nS,TIT_RECE]								 
														EndIf
														
													Next nS
												EndIf
												
												nTotPagto := aImpTotCab[aScan(aImpTotCab,{ |x| x[01] == aTitulo[nI,TIT_NUME] }),02]
												nSpace := 40 - Len(cNumDocumento + &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Trans(nTotPagto,"@E 999,999,999.99"))//Variavel para controle da impressão das colunas
												
												If Empty(cCabImp) .Or. cCabImp <> aTitulo[nI,TIT_NUME]	
													cMsgCompTitulo 	:= 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
																		Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
																		Chr(10) + Chr(10) +;
																		STR0055 + Posicione( "SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_NOME") +;
																		Chr(10) + Chr(10) +;
																		IIF(!Empty(aTitulo[nI][TIT_CONT]),STR0013,STR0056) + Chr(10) +;
																		Replicate("=",40) + Chr(10) +;
																		Chr(10) +;
																		cNumDocumento +;
																		&(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Space(nSpace) + Trans(nTotPagto,"@E 999,999,999.99")

												EndIf
												
												If lRecNaoFis

													If lImpNaoFis
														If Empty(cCabImp) .Or. cCabImp <> aTitulo[nI,TIT_NUME]
															cMsgCompTitulo 	:= 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
																				Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
																				Chr(10) + Chr(10) +;
																				STR0055 + Posicione( "SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_NOME") +;
																				Chr(10) + Chr(10) +;
																				IIF(!Empty(aTitulo[nI][TIT_CONT]),STR0013,STR0056) + Chr(10) +;
																				Replicate("=",40) + Chr(10) +;
																				Chr(10) +;
																				cNumDocumento +;
																				&(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Space(nSpace) + Trans(nTotPagto,"@E 999,999,999.99")//aTitulo[nI][TIT_RECE]
														EndIf
														
														nRet := INFTexto(cMsgCompTitulo)  //Envia comando para a Impressora
														If nRet <> 0
															cMsgRet := STR0208 //"INFTexto: Erro na Impressão do Comprovante."
														EndIf

														If lINFCutPpr .And. Empty(cCabImp) .Or. cCabImp <> aTitulo[nI,TIT_NUME]
															INFCutPpr()
														EndIf
														
														////////////////////////////////////////////////////////////////
														//Atualizando variavel para controle de impressão do cabeçalho//
														////////////////////////////////////////////////////////////////
														cCabImp := aTitulo[nI,TIT_NUME]
													Else
														nRet := 0
													EndIf
												Else
													nRet := IFRelGer( nHdlECF, cMsgCompTitulo, 1 )
													If nRet <> 0
														cMsgRet := STR0209 //"IFRelGer: Erro na Impressão do Relatório Gerencial."
													EndIf
												EndIf

												cMsgCompTitulo := ""
											Else
												 If cPaisLoc == "BRA"
													If lRecNaoFis
														If lImpNaoFis
															
															nSpace := 40 - Len(cNumDocumento + &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99"))//Variavel para controle da impressão das colunas
															
															cMsgCompTitulo 	:= 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
																				Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
																				Chr(10) + Chr(10) +;
																				STR0055 + Posicione( "SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_NOME") +;
																				Chr(10) + Chr(10) +;
																				IIF(!Empty(aTitulo[nI][TIT_CONT]),STR0013,STR0056) + Chr(10) +;
																				Replicate("=",40) + Chr(10) +;
																				Chr(10) +;
																				cNumDocumento +;
																				&(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Space(nSpace) + Trans(aTitulo[nI][TIT_RECE],"@E 999,999,999.99")
															If lAutomato//PREPARACAO AUTOMACAO
																nRet := 0
															Else
																nRet := INFTexto(cMsgCompTitulo)  //Envia comando para a Impressora
																If nRet <> 0
																	cMsgRet := STR0208 //"INFTexto: Erro na Impressão do Comprovante."
																EndIf
															Endif
															If lINFCutPpr
																INFCutPpr()
															EndIf
														Else
															nRet := 0
														EndIf
													Else
														nRet := IFRecebNFis( nHdlECF, cTotRecNFis, aTitulo[nI][TIT_RECE], &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')))
														If nRet <> 0
															cMsgRet := STR0217 	//"IFRecebNFis: Erro na Impressão do Recebimento Não-Fiscal."
														EndIf
													EndIf
												Else
													nRet := 0
												EndIf
											EndIf

											If nRet <> 0
												MsgStop(cMsgRet, STR0030)	//"Atenção!"
												LjGrvLog("Recebimento_Titulo", cMsgRet)
											Else
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³ Alimenta a msg para impressao do comprovante de recebimento com os dados³
												//³ dos titulos e do cliente e faz a somatoria de todos os pagamentos       ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
												nTotComprovante += aTitulo[nI][TIT_RECE]
												cCliente 		:= aTitulo[nI][TIT_CLIE]
												cLoja			:= aTitulo[nI][TIT_LOJA]

												If !lRecNaoFis .AND. SuperGetMV( "MV_CRDAUT", NIL, .T. )
												    //"Autenticação do documento", "Insira o ", "o. documento, no valor de "
												    //" para autenticacäo...", "Autenticar", "Ignorar"
													nCntTit++
													If Aviso(STR0046, STR0047+AllTrim(Str(nCntTit))+STR0048+cSimbCor+" "+;
														AllTrim(Transform(aTitulo[nI][TIT_RECE], PesqPict("SE1", "E1_VALOR", 15)))+;
														STR0049, {STR0050, STR0051}) == 1
														IFAutentic( nHdlECF, "2", "", "")
													Endif
												Endif
											Endif
										Endif
									Endif
								EndIf

		 			            lPrimBaixa      := .F.
							Endif
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se esta forma de pagamento ja' foi toda utilizada para o pagamento   ³
					//³ do titulo, adiciona 1 no contador nParc para pegar a proxima forma de³
					//³ pagamento. Esta variavel deve ser atualizada apenas no final do laco ³
					//³ pois e' utilizada para baixar o titulo                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aFormasPago[nParc][2] == 0
						nParc ++
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Zera o troco, pois o mesmo ja foi usado para atualizar o saldo ³
					//³ do titulo na primeira baixa. Evita que seja atualizado         ³
					//³ novamente para o mesmo titulo.							       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nValTroco := 0
				Else
					nParc ++
				Endif
			End
		Endif
	Next nI
EndIf

nPosFPgto := aScan( aPgtos, { |x| !(IsMoney(x[3]) .OR. (AllTrim(x[3]) $ cMvTpRet) ) } )

If lRet .And. Len(aTitulo) > 0

	If nPosFPgto > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|	A GERACAO DOS REGISTROS REFERENTES A BAIXA DE TITULOS FOI ALTERADA                                  |
	//|	- PARA TITULOS BAIXADOS NA FILIAL DE ORIGEM:                                                        |
	//|		PAGAMENTO EM DINHEIRO GERA 2 REGISTROS NO SE5                                                   |
	//|			1 REGISTRO NO SE5 COM E5_TIPODOC "BA" E E5_MOTBX "LOJ"                                      |
	//|			1 REGISTRO NO SE5 COM E5_TIPODOC "VL" E E5_MOTBX "NOR"                                      |
	//|		PAGAMENTO DIFERENTE DE DINHEIRO GERA 1 REGISTRO NO SE5                                          |
	//|			1 REGISTRO NO SE5 COM E5_TIPODOC "BA" E E5_MOTBX "LOJ"                                      |
	//|	- PARA TITULOS BAIXADOS EM FILIAL DIFERENTE DA ORIGEM:                                              |
	//|		PAGAMENTO EM DINHEIRO GERA 2 REGISTROS NO SE5                                                   |
	//|			1 REGISTRO NO SE5 COM E5_TIPODOC "BA", E5_MOTBX "LOJ" E E5_FILORIG COM A FILIAL DE ORIGEM   |
	//|			1 REGISTRO NO SE5 COM E5_TIPODOC "VL", E5_MOTBX "NOR" E E5_FILORIG COM A FILIAL ATIVA       |
	//|		PAGAMENTO DIFERENTE DE DINHEIRO GERA 2 REGISTRO NO SE5                                          |
	//|			1 REGISTRO NO SE5 COM E5_TIPODOC "BA", E5_MOTBX "LOJ" E E5_FILORIG COM A FILIAL DE ORIGEM   |
	//|			1 REGISTRO NO SE5 COM E5_TIPODOC "BA", E5_MOTBX "LOJ" E E5_FILORIG COM A FILIAL ATIVA       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If (nModulo == 12 .OR. (nModulo <> 23 .AND. LJModNFis())) .AND. !lMvLjPdvPa

		LjxGrvMDX( "1"			, aPgtos		, aPgtosSint	, aTitulo	,;
					Nil			, Nil			, Nil			, Nil		,;
					Nil			, M->LQ_CLIENTE	, M->LQ_LOJA	, Nil		,;
					Nil			, Nil			, Nil			, Nil		,;
					aSE5Bxas	, aCopMoedas	, Nil			, aNSUVndTef,;
					aPagDig		)

	ElseIf ( (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicia conexao com o WebService para Gravacao do novo titulo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	oSvc      := WSLJRECEB():New()
        iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
		oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Passa para o WebService as variaveis necessarias para realizar a baixa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aTitulo)
			If aTitulo[nX][TIT_SELE]
				oSvc:ccFilialG	 	:= aTitulo[nX][TIT_FILI]
				oSvc:ccPrefixo	 	:= aTitulo[nX][TIT_PREF]
				oSvc:ccNumero 		:= aTitulo[nX][TIT_NUME]
				oSvc:ccParcela 		:= aTitulo[nX][TIT_PARC]
				oSvc:ccTipo	 		:= aTitulo[nX][TIT_TIPO]
				oSvc:cCodCli 		:= aTitulo[nX][TIT_CLIE]
				oSvc:cLojCli 		:= aTitulo[nX][TIT_LOJA]
				oSvc:ddDate			:= dDataBase
			EndIf
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o array dentro do metodo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aPgtosSint := Lj7MontPgt(aPgtos)

		oSvc:oWsAPGWS:OWSVERARRAY 	  					  		:= LJRECEB_ARRAYOFWsPgt():New()
		oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT 		 	 			:= Array( Len(aPgtos) )

		oSvc:oWsAPGWSS:OWSVERARRAY 	  					  		:= LJRECEB_ARRAYOFWsPgtS():New()
		oSvc:oWsAPGWSS:OWSVERARRAY:OWSWSPGTS 		 	 		:= Array( Len(aPgtosSint) )

		oSvc:oWsATIT:OWSVERARRAY 	  					  		:= LJRECEB_ARRAYOFWsTIT():New()
		oSvc:oWsATIT:OWSVERARRAY:OWSWSTIT 		 	 			:= Array( Len(aTitulo) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Antes de chamar o metodo, atribui os valores ³
		//³as propriedades (passagem de parametros)     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aPgtos)

			oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX] := LJRECEB_WSPGT():New()

				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cTIPO		:= aPgtos[nX][3]
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:dVENCTO		:= aPgtos[nX][1]
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:nVALOR		:= aPgtos[nX][2]
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cBCOCHQ		:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][4],"")
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cAGECHQ		:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][5],"")
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cCTACHQ		:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][6],"")
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNUMERO		:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][7],"")
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:dDATACH		:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][2],Date())
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:CCOMPENS		:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][8],"")
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cRG			:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][9],"")
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cTEL			:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][10],"")
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:LCHETER		:= IIf(aPgtos[nX][3] $ MVCHEQUE	,aPgtos[nX][4][12], .F.)
				oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cECHETER		:= IIf(aPgtos[nX][3] $ MVCHEQUE	 .And. aPgtos[nX][4][12] ,aPgtos[nX][4][14], "")

				If nModulo == 12 .OR. (nModulo <> 23 .AND. LJModNFis())
					If Len(aPgtos[nX][4]) > 0
						cAdmDesc := aPgtos[nX][4][5]
					EndIF
					oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cCODADM		:= IIf(aPgtos[nX][3] $ "CC|VA|CO|CD|FI" .OR. !Empty(cAdmDesc),SubStr(cAdmDesc,1,nTamSAE),"")
				Else
					If ValType(aPgtos[nX][4]) == "A"  // Cheque no Front
						cAdmDesc := aPgtos[nX][4][5]
					Else
						cAdmDesc := aPgtos[nX][4]    // # de CH
					EndIf
					oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cCODADM		:= IIf(aPgtos[nX][3] $ "CC|VA|CO|CD|FI" .OR. !Empty(cAdmDesc)	,cAdmDesc,"")
				EndIf

				If AllTrim(aPgtos[nX, 3]) $ _FORMATEF
					If Len(aNSUVndTef) > 0
						aAuxDados := {}
						LjxRTefDa(	@aAuxDados	,	aPgtos	,	aNSUVndTef	,	NIL ,;
									NIL			,	nColId	,	NIL 		, 	nX	,;
									aPagDig		)

						oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:CCIDCART	:= aAuxDados[1][8]
						oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUTEF	:= aAuxDados[1][6]
						oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUDOC	:= aAuxDados[1][3]
						oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cAUTORIZ	:= aAuxDados[1][4]

					ElseIf lUsaTef
						If	cTipTEF == TEF_CLISITEF
							nPosRetCart := 0
		
							If nModulo == 12 .OR. (nModulo <> 23 .AND. LJModNFis())
								nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgtos[nX][8] } ), 1)
							ElseIf nModulo == 23  	// SIGAFRT
								nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgtos[nX][12] } ), 1)
							Endif
		
							If nPosRetCart > 0
								oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:CCIDCART		:= oTEF:aRetCartao[nPosRetCart]:CIDCART
								oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUTEF		:= oTEF:aRetCartao[nPosRetCart]:CNSUSITEF
								oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUDOC		:= oTEF:aRetCartao[nPosRetCart]:CNSUAUTOR
								oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cAUTORIZ		:= oTEF:aRetCartao[nPosRetCart]:CAUTORIZA
							Endif
		
						ElseIf cTipTEF == TEF_DISCADO
							
							If lIsDiscado .AND. Len(aPgtosId) > 12
		
								nPosRetCart := aScan(aPgtosId, {|p| p[3] == aPgtos[nX][3] .AND. p[14] == IIF(!Empty(aPgtos[nX][nColId]), aPgtos[nX][nColId], "1") })
			
								If nPosRetCart > 0
									oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:CCIDCART		:= aPgtosId[nPosRetCart][14]
									oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUTEF		:= aPgtosId[nPosRetCart][13]   //NSU TEF
									oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUDOC		:= Right(aPgtosId[nPosRetCart][07],6)
									oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cAUTORIZ		:= Right(aPgtosId[nPosRetCart][07],6)
								Endif

							Else
								//TEF Pay&Go
								aPgtosId := L010TefD()

								If Len(aPgtosId) > 0 .AND. Len(aPgtosId[1]) >= 19
									
									nPosRetCart := aScan(aPgtosId, {|p| p[19] == IIF(!Empty(aPgtos[nX][nColId]), aPgtos[nX][nColId], "1") })

									If nPosRetCart > 0
										oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:CCIDCART := aPgtosId[nPosRetCart][19]
										oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUTEF	:= aPgtosId[nPosRetCart][09]
										oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUDOC	:= aPgtosId[nPosRetCart][05]
										oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cAUTORIZ	:= aPgtosId[nPosRetCart][05]
									EndIf
								EndIf

							EndIf

						EndIf
					Else
						If cTipTEF == TEF_DISCADO  .AND. lTEFD .AND. !lTefMult
							nPosRetCart := 1
							aPgtosId := L010TefD()
		
							oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:CCIDCART		:= "1"
							oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUTEF		:= Right(aPgtosId[1][4],6) //NSU TEF
							oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cNSUDOC		:= aPgtosId[1][9]
							oSvc:oWsAPGWS:OWSVERARRAY:OWSWSPGT[nX]:cAUTORIZ		:= aPgtosId[1][9]
						EndIf
					EndIf
				EndIf
		Next nX

		For nX := 1 To Len(aPgtosSint)

			oSvc:oWsAPGWSS:OWSVERARRAY:OWSWSPGTS[nX] := LJRECEB_WSPGTS():New()

			oSvc:oWsAPGWSS:OWSVERARRAY:OWSWSPGTS[nX]:cFORMAST		:= aPgtosSint[nX][1]
			oSvc:oWsAPGWSS:OWSVERARRAY:OWSWSPGTS[nX]:nParcelaSt		:= aPgtosSint[nX][2]

		Next nX

		For nX := 1 To Len(aTitulo)
			If aTitulo[nX][TIT_SELE] .AND. !IsMoney(aTitulo[nX][TIT_TIPO])
				oSvc:oWSATIT:OWSVERARRAY:OWSWSTIT[nX] := LJRECEB_WSTIT():New()

				oSvc:oWSATIT:OWSVERARRAY:OWSWSTIT[nX]:lTSELE				:= aTitulo[nX][TIT_SELE]
				oSvc:oWSATIT:OWSVERARRAY:OWSWSTIT[nX]:nTRECNO				:= aTitulo[nX][TIT_RECN]
				oSvc:oWSATIT:OWSVERARRAY:OWSWSTIT[nX]:cTTIPO				:= aTitulo[nX][TIT_TIPO]
				oSvc:oWSATIT:OWSVERARRAY:OWSWSTIT[nX]:nMODULO				:= nModulo
			EndIf
		Next nX

		oSvc:CCNOMEUSER 	:= xNumCaixa()
		oSvc:CEMPPDV 		:= cEmpAnt
		oSvc:CFILPDV 		:= cFilAnt
		oSvc:LMVLJPDVPA 	:= lMvLjPdvPa
		lRet				:= oSvc:GeraTitRec( )

		If !lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|*** Aqui devera ser melhor tratado as mensagens de erro...        |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
				cSoapFCode  := GetWSCError(2)
				cSoapFDescr := GetWSCError(3)
				MsgStop(cSoapFDescr, cSoapFCode)
			Else
				//"Sem comunicação com o WebService!", "Atenção!"
				MsgStop(STR0029,STR0030)
				AAdd(aRet, AClone(aTitulo) )
				LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
				Return aRet
			Endif
		EndIf
	EndIf
	ElseIf cPaisLoc <> "BRA" .AND. !(cPaisLoc $ "CHI|COL")
    	LjxGrvSEL( aTitulo, .T. )
    	LjxGrvSFE()
	EndIf

	aTitBxSE5 := {}
EndIf

If (lCartao .Or. Len(aPagDig) > 0) .AND. lChkslv .AND. lUsaTef .AND. !lErrSrv
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava na retaguarda via WebService      ³
	//³ caso FrontLoja ou Venda Ass. modo PDV.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa) )		
		If Type("oSvc:oWsaDadosSLV") == "O" //Verifica se existe a estrutura aDadosSLV [apenas uma protecao caso o fonte WSC_LJRECEB.PRW (client deste WS) nao esteja atualizado com as alteracoes necessarias]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Antes de chamar o metodo WS, atribui os valores ³
			//³as propriedades do array aDadosSLV.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSvc:oWsaDadosSLV:OWSVERARRAY 	  	:= LJRECEB_ARRAYOFWSStrutSLV():New()
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV	:= Array( Len(aSE5Dados) )

			For nX := 1 To Len(aSE5Dados)
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX] := LJRECEB_WSStrutSLV():New()
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cFORMA		:= aSE5Dados[nX][09]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:nVALOR		:= aSE5Dados[nX][10]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDATATEF	:= aSE5Dados[nX][11]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cHORATEF	:= aSE5Dados[nX][12]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDOCTEF		:= aSE5Dados[nX][13]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cAUTORIZ	:= aSE5Dados[nX][14]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cINSTITU	:= aSE5Dados[nX][15]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cNSUTEF		:= aSE5Dados[nX][16]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cTIPCART	:= aSE5Dados[nX][17]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cSEQOPER	:= aSE5Dados[nX][18]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:nRECSE5		:= aSE5Dados[nX][19]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:lCANTEF		:= .F. // Cancelamento TEF	
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDOCCANC	:= "" 	
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cHORCANC	:= "" 	
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDATCANC	:= "" 	
				If Len(aSE5Dados[nX])>=24
					oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cBANDEIRA	:= aSE5Dados[nX][23]
					oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cREDEAUT	:= aSE5Dados[nX][24]
				EndIf
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava tabela SLV via WebService         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			lRet := oSvc:GravaTabSLV( cEmpAnt, cFilAnt, lMvLjPdvPa )
			
			// Grava array com dados da transação TEF para utilizar no estorno do recebimento
			If lRet
				aDadosTef := aSE5Dados
			EndIf
			
			If !lRet
				cSvcError := GetWSCError()
				If Left(cSvcError,9) == "WSCERR048"
					cSoapFCode  := GetWSCError(2)
					cSoapFDescr := GetWSCError(3)
	 				MsgStop(cSoapFDescr, cSoapFCode)
				Else
					//"Sem comunicação com o WebService!", "Atenção!"
					MsgStop(STR0029,STR0030)
					AAdd(aRet, AClone(aTitulo))
					LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
					Return aRet
				Endif
			EndIf
		EndIf
	Else
		If !lSelTefManu .Or. Len(aPagDig) > 0  // Nao gerar SLV quando TEF manual
   			LJXGrvSLV( "I", @aSE5Dados )
  		Endif
	EndIf
EndIf

If Upper(FunName()) == "LOJA701" .OR. Upper(FunName()) == "FATA701"
	lTefOk 	:= .T.
	lVAssist := .T.
Endif
lRet 	:= .T.
If lUsaTef .AND. lCartao .AND. cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF .AND. !lErrSrv
   If lTefOk .AND. (lFiscal .OR. lRecNaoFis)
  	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Verificado se esta' configurado com CLISITEF ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If cTipTef == TEF_CLISITEF
			If lRet
				lRecebTit := .T.

				If cPaisLoc == "BRA" .And. lMultBaixa .AND. nHdlEcf <> -1
					//No caso de baixa Multipla, imprime o totalizador do RECEBIMENTO neste momento
					If !lRecNaoFis
						nRet := IFRecebNFis( nHdlECF, cTotRecNFis, nVlrTitPago, &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')))

						If nRet <> 0
							MsgStop(STR0217, STR0030)	//"IFRecebNFis: Erro na Impressão do Recebimento Não-Fiscal.", "Atenção!"
							LjGrvLog("Recebimento_Titulo", STR0217)	//"IFRecebNFis: Erro na Impressão do Recebimento Não-Fiscal."
						EndIf
					EndIf
				EndIf

				oTEF:ImpCupTef(nTotComprovante)
				lErrCupTEF 	:= !oTef:lImprimiu
				lTefOk 		:= oTEF:lTefOk
				If lErrCupTEF .AND. nModulo == 23
					lRetTef := FrtCancCup(.T.,lVAssist)

					If lRetTef
						HELP(' ',1,'FRT034')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
						// "É necessário efetuar Nota de Devolução."
					EndIf
				EndIf
			Else
				oTEF:FinalTrn(0) 				//Finaliza a TRN com parametro confirma = 1
				MsgInfo(STR0106) 			    //"Transação TEF não efetuada, favor reter o cupom!"
				If nModulo == 23
					lRetTef := FrtCancCup(.T.,lVAssist)
					If lRetTef
						HELP(' ',1,'FRT043')		//"A operacao de TEF não foi concluída com sucesso. O cupom será cancelado."
						// "É necessário efetuar Nota de Devolução."
					EndIf
				Endif
			EndIf
	   Else
           If lRet
           
		       lTefOk := LOJA010T( "I"   ,"V"                                        ,NIL           ,NIL   ,;
				                    NIL   ,&(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) ,lTEFPendRec   ,NIL,;   
				                    NIL	  , NIL, NIL,NIL,;
				                    NIL	  , NIL, NIL,NIL,;
				                    NIL	  , NIL, NIL,NIL,;
				                    NIL, ExistFunc("LjFTvd") .AND. LjFTVD() )
				                    

			   If !lTefOk
			       //"Transação TEF não efetuada, favor reter o cupom!"
				   MsgStop(STR0052)
				   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				   //³ Estorna a baixa do titulo pois a transacao Tef foi cancelada  ³
				   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		           cOper := "2"
				   LjRecBtnOK(aRet,.F.)

			   Endif
		   Else
		       lTefOk := LOJA010T( "F"    ,"N"   ,NIL   ,NIL   ,;
			                        NIL   ,NIL   ,NIL   ,NIL   )
			   If lTefOk
			       //"Transação TEF não efetuada, favor reter o cupom!"
			  	   MsgInfo(STR0052)
			   Endif
		   Endif
		Endif

	//³Se houver alguma transacao TEF pendente, deve cancelar no SiTef³
   ElseIf lVerTEFPend .AND. lTefMult .AND. cMV_TEFPEND $ "1|2"
      aTefMult  := AClone(aBckTEFMult)
	  If LEN(aTefMult) > 0
	     //HOMOLOGACAO: Enviar o desfazimento da operação TEF para impedir transações pendentes no Sitef
		 If TEF_lEnvDF()
		    If LOJA010T( "F"   ,"D"   ,NIL   ,NIL   ,;
			             NIL   ,NIL   ,NIL   ,NIL   )
			   MsgAlert(STR0094) 	//"Transação TEF cancelada!"
			Endif
			//Na versào 3.00 do TEF qdo quando ocorre erro nao e necessario cancelar enviei o desfazimento, respeito as versoes anteriores do Sitef
		 ElseIf !(SuperGetMV("MV_TEFVERS") == "03.00") .OR. lTefMult
		    If LOJA010T( "F"   ,"N"   ,NIL   ,NIL   ,;	//Antigamente esta função nao retornava verdadeiro ou falso
				         NIL   ,NIL   ,NIL   ,NIL   )
			   MsgAlert(STR0094) 	//"Transação TEF cancelada!"
		    Endif
		 Endif
	  Endif
   Endif
Else
	If cPaisLoc == "BRA" .And. lMultBaixa .AND. nHdlEcf <> -1
		//No caso de baixa Multipla, imprime o totalizador do RECEBIMENTO neste momento
		If !lRecNaoFis
			nRet := IFRecebNFis( nHdlECF, cTotRecNFis, nVlrTitPago, &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')))

			If nRet <> 0
				MsgStop(STR0217, STR0030)	//"IFRecebNFis: Erro na Impressão do Recebimento Não-Fiscal.", "Atenção!"
				LjGrvLog("Recebimento_Titulo", STR0217)	//"IFRecebNFis: Erro na Impressão do Recebimento Não-Fiscal."
			   aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
	          LjRecBtnOK(aRet,.F.)
	          Return aRet
			EndIf
		EndIf
	EndIf
	lTefOk := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o recebimento de titulos seja paga via TEF, imprime um        ³
//³ relatorio gerencial atrelado ao texto do Comprovante de RECEBIMENTO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lErrSrv
	lRelGer  := LJXVERTEF(.T.,aPgtos)
EndIf

If ExistFunc("LjImprimPD") .And. Len(aPagDig) > 0
	//Imprime o comprovante de Pagamento Digital
	LjImprimPD()
	
	//Caso o recebimento de titulos seja pago via Pagamento Digital (PD), seta a variavel lRelGer para imprimir
	//um relatorio gerencial atrelado ao texto do Comprovante de RECEBIMENTO, caso seja Impressora Fiscal (ECF).
	lRelGer := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a Impressao do Cheque. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(LjGetStation("IMPCHQ")) .AND. !Empty(LjGetStation("PORTCHQ")) .AND. !lErrSrv
	FRTImpCH()
Endif

If lGaveta .AND. !lErrSrv
	If (!Empty(LJGetStation("PORTGAV"))) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
		GavetaAci(nHdlGaveta, LJGetStation("PORTGAV"))
	Else
		IFGaveta(nHdlECF)
	Endif
Endif

If cPaisLoc $ "COL|CHI" .And. !lRelGer

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Impressao de Comprovante de Pagamento  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjPagCol
		If nTotComprovante > 0
			ExecBlock( cRotPag, .F., .F., {cCliente,cLoja,aTitulo, aPgtos,cMsgComprovante, nTotComprovante, cTotRecNFis,  aSE5Bxas} )
		Endif
	Endif
Endif

//tratamento para verificar se foi utilizado NCC
If len(aTitulo) > 0 
	cDescRec:= IIF(!Empty(aTitulo[1][12]),STR0013,STR0056)
Elseif len(aTitBXNCC) > 0
	cDescRec:= IIF(!Empty(aTitBXNCC[1][12]),STR0013,STR0056)
Endif

If lUsaTef .AND. lRelGer .AND. cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF .AND. !lErrSrv

	lRecNTef := .T.
	If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. lFiscal)

		If lFrtRecTit .And. !lLjRecComp
			//#"Ponto de Entrada LjRecComp não esta compilado para impressão dos comprovantes gerais"
			//#"Vide TDN: http://tdn.totvs.com/pages/viewpage.action?pageId=189301943 "
			Conout( STR0184 + CHR(10) + STR0185	)
			LjGrvLog(Nil,STR0184 + STR0185)
			cMsgComprovante := STR0053 + STR0107
		Else

			//       "C O M P R O V A N T E"
			//   "D E   R E C E B I M E N T O"
			//"Cliente : "
		    //"Documento                         Valor"
		    //"T O T A L "
			cMsgComprovante := 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
								Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
								Chr(10) + Chr(10) +;
								STR0055 + Posicione( "SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_NOME") +;
								Chr(10) + Chr(10) +;
								cDescRec + Chr(10) +;
								Replicate("=",40) + Chr(10) +;
								cMsgComprovante + ;
								Chr(10) +;
								STR0057 + Space(14) + cMvSimb1 + Trans(nTotComprovante,"@E 999,999,999.99")
		EndIf
	Endif

	If lLjRecComp
		LjGrvLog("RECEBIMENTO",ProcName(0) + " - Ponto de Entrada LJRECCOMP" , {cMsgComprovante, nTotComprovante, cTotRecNFis, aTitulo, aPgtos, aSE5Bxas} )
		ExecBlock( "LJRECCOMP", .F., .F., {cMsgComprovante, nTotComprovante, cTotRecNFis, aTitulo, aPgtos, aSE5Bxas} )
		LjGrvLog("RECEBIMENTO",ProcName(0) + " - Saida do Ponto de Entrada LJRECCOMP" )
	Else
		/*Imprime relatorio gerencial com o comprovante a ser impresso*/
		If lRecNaoFis
			If lImpNaoFis .And. !lFrtRecTit
				For nX := 1 To nRecVias

					nRet := INFTexto(cMsgComprovante)  //Envia comando para a Impressora
					If nRet <> 0
						cMsgRet := STR0208 //"INFTexto: Erro na Impressão do Comprovante."
					EndIf

					If lINFCutPpr
						INFCutPpr()
					EndIf
				Next nX
			Else
				nRet := 0
			EndIf
		Else
			nRet := IFRelGer( nHdlECF, cMsgComprovante, nRecVias )
			If nRet <> 0
				cMsgRet := STR0209 //"IFRelGer: Erro na Impressão do Relatório Gerencial."
			EndIf
		EndIf

		If nRet <> 0
			cOper := "2"
			 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
			LjRecBtnOK(aRet,.F.)
			MsgStop(cMsgRet, STR0095)	// "Atenção"
			LjGrvLog("Recebimento_Titulo", cMsgRet)
			Return aRet
		EndIf
	Endif
EndIf

//³ Faz a impressao do comprovante com os dados de todos os titulos   ³
If (!Empty(cMsgComprovante) .Or. (Empty(cMsgComprovante) .And. lFrtRecTit )) .AND. lTefOk .AND. !lRecNTef .AND. !lErrSrv
	If lFrtRecTit .And. !lLjRecComp
		//#"Ponto de Entrada LjRecComp não esta compilado para impressão dos comprovantes gerais"
		//#"Vide TDN: http://tdn.totvs.com/pages/viewpage.action?pageId=189301943 "
		Conout( STR0184 + CHR(10) + STR0185	)
		LjGrvLog(Nil,STR0184 + STR0185)
		cMsgComprovante := STR0053 + STR0107
	Else

		// "C O M P R O V A N T E"
		//   "D E   R E C E B I M E N T O"
		//"Cliente : "
	    //"Documento                         Valor"
	    //"T O T A L "
		cMsgComprovante := 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
							Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
							Chr(10)	+ Chr(10)	+;
							STR0055	+ Posicione( "SA1", 1, xFilial("SA1") + cCliente + cLoja, "SA1->A1_NOME") +;
							Chr(10)	+ Chr(10)	+;
							cDescRec + Chr(10) +;
							Replicate("=",40)	+ Chr(10) +;
							cMsgComprovante + ;
							Chr(10)

		If cPaisLoc == "ARG"
			cMsgComprovante += STR0141 + Space(14) + Trans(POSICIONE("SE1",1,xFilial("SE1") +  aAux[TIT_PREF]  + aAux[TIT_NUME] + aAux[TIT_PARC], "SE1->E1_SALDO" ),"@E 999,999,999.99")+ Chr(10)+ ;
							Replicate("-",40) + Chr(10) + ;
							STR0057 + Space(14) + cMvSimb1 + Trans(nTotComprovante,"@E 999,999,999.99")+ Chr(10)+ ;
							Replicate("-",40) + Chr(10) +;
							STR0142 + Space(14) +  Trans(POSICIONE("SE1",1,xFilial("SE1") +  aAux[TIT_PREF]  + aAux[TIT_NUME] + aAux[TIT_PARC], "SE1->E1_SALDO" )-nTotComprovante,"@E 999,999,999.99")+ Chr(10)
		Else
			cMsgComprovante += STR0057 + Space(14) + cMvSimb1 + Trans(nTotComprovante,"@E 999,999,999.99")

			//Imprimir valor de troco no Relatorio Gerencial
			If lTroco .And. nRelTroco > 0
				nSaldoNCC:= LjSldNCC(aRecnoNCC) //somar todos os saldos das NCCs
				//subtrair de nReltroco os saldos das NCC (somatoria E1_SALDO dos titulos aRecnoNCC[1])
				If nSaldoNCC > 0 
					nRelTroco:= nRelTroco - nSaldoNCC	
				EndIf
				cMsgComprovante += Chr(10) + STR0167 + Space(24-Len(STR0167)) + cMvSimb1 + Trans(nTotComprovante+nRelTroco,"@E 999,999,999.99") //#STR0167->"V A L O R    P A G O"
				If nRelTroco > 0
					cMsgComprovante += Chr(10) + STR0168 + Space(24-Len(STR0168)) + cMvSimb1 + Trans(nRelTroco,"@E 999,999,999.99")  //#STR0168->"T R O C O "
				EndIf								
			EndIf
		EndIf
	EndIf

	If lLjRecComp
		LjGrvLog("RECEBIMENTO",ProcName(0) + " - Ponto de Entrada LJRECCOMP" , {cMsgComprovante, nTotComprovante, cTotRecNFis, aTitulo, aPgtos, aSE5Bxas } )
		ExecBlock( "LJRECCOMP", .F., .F., {cMsgComprovante, nTotComprovante, cTotRecNFis, aTitulo, aPgtos, aSE5Bxas })
		LjGrvLog("RECEBIMENTO",ProcName(0) + " - Saida do Ponto de Entrada LJRECCOMP" )
	ElseIf lFiscal .OR. lRecNaoFis

		If LJAnalisaLeg(34)[1]

			If lRecNaoFis
				If lImpNaoFis .And. !lFrtRecTit

					nRet := INFTexto(cMsgComprovante)  //Envia comando para a Impressora
					If nRet <> 0
						cMsgRet := STR0208 //"INFTexto: Erro na Impressão do Comprovante."
					EndIf

					If lINFCutPpr
						INFCutPpr()
					EndIf
				Else
					nRet := 0
				EndIf
			Else
				nRet := IFRelGer( nHdlECF, cMsgComprovante, nRecVias )
				If nRet <> 0
					cMsgRet := STR0209 //"IFRelGer: Erro na Impressão do Relatório Gerencial."
				EndIf
			EndIf

			If nRet <> 0
				cOper := "2"
				MsgStop(cMsgRet, STR0095)	// "Atenção"
				LjGrvLog("Recebimento_Titulo", cMsgRet)
				 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
				LjRecBtnOK(aRet, .F., cRecibo, cSerieRec)
				Return aRet
			EndIf
		ElseIf cPaisLoc <> "ARG"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena o numero dos cheques		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc <> "BRA" .AND. Len(aPgtos) > 0
			   For nX := 1 to Len(aPgtos)
			       cMsgComprovante += Chr(10)+ If( aPgtos[nX][3]="CH", aPgtos[nX][4][7] + Chr(10) , "" + Chr(10) )
			   Next nX
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abre o cupom nao fiscal vinculado ao recebimento                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lRecNaoFis
				nRet := IFAbrCNFis( nHdlECF                            , &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')), ;
				                    Alltrim(Str(nTotComprovante,14,2)) , cTotRecNFis )
			EndIf

			If nRet <> 0
				cOper := "2"
				MsgStop(STR0210, STR0095)	// "IFAbrCNFis: Erro na Impressão da Abertura do Cupom Não-Fiscal.", "Atenção"
				LjGrvLog("Recebimento_Titulo", STR0210)	//"IFAbrCNFis: Erro na Impressão da Abertura do Cupom Não-Fiscal."
				 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
				LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
				Return aRet
			EndIf

			If !L010AskImp(.F., nRet)
				If lRecNaoFis
					If lImpNaoFis .And. !lFrtRecTit .AND. !lAutomato
						nRet := INFTexto(cMsgComprovante)  //Envia comando para a Impressora
						If nRet <> 0
							cMsgRet := STR0208 //"INFTexto: Erro na Impressão do Comprovante."
						EndIf

						If lINFCutPpr
							INFCutPpr()
						EndIf
					Else
						nRet := 0
					EndIf
				Else
					nRet := IFTxtNFis( nHdlECF, cMsgComprovante, nRecVias )
					If nRet <> 0
						cMsgRet := STR0211 //"IFTxtNFis: Erro na Impressão do Detalhe do Cupom Não-Fiscal."
					EndIf
				EndIf

				If nRet <> 0
					cOper := "2"
					MsgStop(cMsgRet, STR0095)	// "Atenção"
					LjGrvLog("Recebimento_Titulo", cMsgRet)
					 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
					LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
					Return aRet
				EndIf

				If !L010AskImp(.F.,nRet)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha o cupom nao fiscal vinculado                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lRecNaoFis

						nRet := IFFchCNFis( nHdlECF )

						If nRet <> 0
							cOper := "2"
							MsgStop(STR0212, STR0095)	// "IFFchCNFis: Erro na Impressão do Fechamento do Texto Não-Fiscal.", "Atenção"
							LjGrvLog("Recebimento_Titulo", STR0212)	//"IFFchCNFis: Erro na Impressão do Fechamento do Texto Não-Fiscal."
							 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
							LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
							Return aRet
						EndIf
					EndIf

					If L010AskImp(.F., nRet)
						Return Nil
					Endif
				Endif
			Endif
		Else

			SA1->(DbSetOrder(1))
			SA1->(DbSeek( xFilial("SA1") + cCliente + cLoja ))

			Do Case
				Case SA1->A1_TIPO = "X"
					cTipoCli := "E"									// Isento
				Case SA1->A1_TIPO = "F" .OR. Empty( SA1->A1_TIPO )
					cTipoCli := "C"									// Consumidor Final
				Case SA1->A1_TIPO = "S"
					cTipoCli := "A"									// Nao responsavel
				Case SA1->A1_TIPO = "Z"
					cTipoCli := "I"									// Responsavel Inscrito
				OtherWise
					cTipoCli := SA1->A1_TIPO
			EndCase

			If SA1->A1_TIPO == "F"
				cCNPJ	:= SA1->A1_RG
				cTipoID	:= "2"										// DNI - Documento Nacional de Identidad
			Else
				cCNPJ	:= AllTrim( SA1->A1_CGC )
				cTipoID	:= "C"										// CUIT
				If Empty(cCNPJ)
					MsgAlert(STR0034)								// "O cliente nao tem CUIT cadastrado. Nao sera gerada a nota fiscal. Atualize os dados do cliente!"
					GrabLogHsr(STR0035 + SL1->L1_NUM )				// "O cliente nao tem CUIT cadastrado "
					Return( .F. )
				EndIf
				If !Cuit(cCNPJ,"A1_CGC")
					MsgAlert(STR0036)								// "O cliente nao tem CUIT valido cadastrado. Nao sera gerada a nota fiscal. Atualize os dados do cliente!"
					GrabLogHsr(STR0037 + SL1->L1_NUM  )				// "O CUIT e invalido "
					Return( .F. )
				EndIf
			EndIf

			cLinCliente := AllTrim(SA1->A1_NOME) + "|" + StrTran(AllTrim(cCNPJ),"-","") + "|" + AllTrim(cTipoCli) + "|" + AllTrim(cTipoID) +;
							"|" + Padr(Substr(SA1->A1_END,1,40),40) + "|" + SA1->A1_MUN + "|" + SA1->A1_EST

            If SLG->(ColumnPos( "LG_TKTFACT" )) > 0
            	If !Empty(LjGetStation("LG_TKTFACT"))
            		cTipoRecImp := LjGetStation("LG_TKTFACT")
            	EndIf
            EndIf

            nRet := IFAbrirDNFH(nHdlECF, "x", cLinCliente, " ", LjGetStation("LG_PDV") + "-" + SubStr(cRecibo, 5, 8), @aRetDNFH, cTipoRecImp, Nil )

			If nRet <> 0
				cOper := "2"
				MsgStop(STR0213, STR0095)	// "IFAbrirDNFH: Erro na Impressão da Abertura de Documento Não-Fiscal Homologado.", "Atenção"
				LjGrvLog("Recebimento_Titulo", STR0213)	//"IFAbrirDNFH: Erro na Impressão da Abertura de Documento Não-Fiscal Homologado."
				If !LjLogRec( "LOJXREC - _LJGrvRec - IFAbrirDNFH", cSerieRec, cRecibo, cCliente, cLoja, nTotComprovante )
					IFCancCup( nHdlECF )
					 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
					LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
					Return aRet
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carregas as variaveis apenas para usar a funcao IFRegItem()³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodigo      := cSerieRec					// Nao precisa
			cDescricao   := cSerieRec+"/"+cRecibo		// Nao precisa
			cQtde	     := "1"
			cVlrUnit     := Alltrim( Str(nTotComprovante,12,4))
			cVlrDesconto := "0"
			cAliquota    := "0"
			cTotIt       := "0"
			cUnidMed     := "UN"
			cTipoTes     := "2"

			nRet := IFRegItem( nHdlECF , cCodigo     , cDescricao, cQtde,;
					cVlrUnit, cVlrDesconto, cAliquota , cTotIt,;
					cUnidMed, cTipoTes )
			If nRet <> 0
				cOper := "2"
				MsgStop(STR0214, STR0095)	// "IFRegItem: Erro na Impressão do Item da Venda.", "Atenção"
				LjGrvLog("Recebimento_Titulo", STR0214)	//"IFRegItem: Erro na Impressão do Item da Venda."
				If !LjLogRec( "LOJXREC - _LJGrvRec - IFRegItem", cSerieRec, cRecibo, cCliente, cLoja, nTotComprovante )
					IFCancCup( nHdlECF )
					 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
					LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
					Return aRet
				EndIf
			EndIf

			cMsgRecibo := ""

			For nX:=1 to len(aTitulo)
				If aTitulo[nX][TIT_SELE]
					cMsgRecibo += STR0143 + AllTrim(Str(aTitulo[nX][TIT_RECE])) + STR0144 + Extenso( aTitulo[nX][TIT_RECE], .F., nMoedaCor, Nil, Nil, .T., .F., .T., "1" ) +;
								STR0145 + aTitulo[nX][TIT_PREF]+"/"+aTitulo[nX][TIT_NUME] + "|"
				EndIf
			Next

			If ExistBlock("LJRECIMP")
				LjGrvLog("RECEBIMENTO",ProcName(0) + " - Ponto de Entrada LJRECIMP" , {aTitulo, cMsgRecibo } )
				xRet := ExecBlock("LJRECIMP", .F., .F., {aTitulo, cMsgRecibo })
				LjGrvLog("RECEBIMENTO",ProcName(0) + " - Ponto de Entrada LJRECIMP - Retorno " , xRet )
				If ValType(xRet) == "C"
					cMsgRecibo := xRet
				EndIf
			EndIf

			cMsgRecAux := cMsgRecibo
			While Len(cMsgRecAux) > 0
				nRet := IFRecibo( nHdlECF , SubStr(cMsgRecAux, 1, AT("|",cMsgRecAux)-1), @aRetDNFH )
				cMsgRecAux := SubStr(cMsgRecAux, AT("|",cMsgRecAux)+1, Len(cMsgRecAux))
				If nRet <> 0
					cOper := "2"
					MsgStop(STR0215, STR0095)	// "IFRecibo: Erro na Impressão do Recibo da Venda.", "Atenção"
					LjGrvLog("Recebimento_Titulo", STR0215)	//"IFRecibo: Erro na Impressão do Recibo da Venda."
					If !LjLogRec( "LOJXREC - _LJGrvRec - IFRecibo", cSerieRec, cRecibo, cCliente, cLoja, nTotComprovante )
						IFCancCup( nHdlECF )
						 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
						LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
						Return aRet
					EndIf
				EndIf
            End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fecha o cupom                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRet := IFFecharDNFH( nHdlECF, @aRetDNFH)

			If nRet <> 0
				cOper := "2"
				MsgStop(STR0216, STR0095)	// "IFFecharDNFH: Erro na Impressão do Fechamento de Documento Não-Fiscal Homologado.", "Atenção"
				LjGrvLog("Recebimento_Titulo", STR0216)	//"IFFecharDNFH: Erro na Impressão do Fechamento de Documento Não-Fiscal Homologado."
				If !LjLogRec( "LOJXREC - _LJGrvRec - IFFecharDNFH", cSerieRec, cRecibo, cCliente, cLoja, nTotComprovante )
					 aEval(aTitulo,{ |t| IIF(t[1], aAdd(aRet, aClone(t)),NIL )})
					LjRecBtnOK(aRet, .F., cRecibo, cSerieRec, .F.)
					Return aRet
				EndIf
			EndIf

		Endif
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta a variavel do tipo Static para False³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRecebTit := .F.

If lLJRecGrv
	U_LJRecGrv(@aTitulo, @aPgtos, @aSE5Bxas)
EndIf

aTitDelSE5 := {}

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³LJRecBXSE1³ Autor ³ Cesar Eduardo Valadao ³ Data ³04/07/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Geracao efetiva dos registros no SE5(Mov. Bancario) corres- ³±±
±±³			 ³pondentes a baixa dos titulos recebidos e atualizacao do ti-³±±
±±³			 ³tulo a receber(SE1)								          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJRecBXSE1( cMV_LJRECEB		, cPrefixo 		, cNum			, cParcela		,;
						    dVencimento		, nValor		, nVlrMulta		, nVlrJuros		,;
						    nVlrDesconto	, nVlrRecebido	, cTipo			, cCartFrt		,;
						    cFilialTit		, cFrmPag		, lPrimBaixa	, nPrimMulta	,;
						    nPrimJuros		, nPrimDescon	, nTotReceb		, aSE5Dados		,;
						    lPgTef			, cNomeUser		, nValAbat		, aSE5Bxas		,;
						    aTitBxSE5		, cNumCheque	, aTitDelSE5	, nValTroco		,;
						    nMoeda			, nRecnoSE5 	, lWS			, cNumMov		,;
						    aNsuVndTef		, cIdCart		, aPagDig						)

Local lAchou		:= .F.
Local lRet			:= .T.
Local lRecFilial	:= SuperGetMV( "MV_LJRECFI", NIL, .F. )
Local lTefMult		:= SuperGetMV("MV_TEFMULT",.F.)				// Verifica se esta configurado multiplas transacoes
Local aBaixa		:= {}
Local aDadosSE5		:= {}
Local aAreaSA6		:= SA6->(GetArea())							//Area da Tabela SA6
Local cFilAntBkp	:= cFilAnt
Local cNatureza		:= ""
Local cForma		:= ""										// Guarda forma de pagamento
Local cCodCaixa		:= ""										// Codigo do Caixa
Local cFilBkp		:= ""
Local cFilSA6		:= ""
Local nCount		:= SE5->( FCount() )
Local nRecnoSE1		:= 0										// Recno do titulo baixado
Local nX			:= 0
Local nY			:= 0										// Posicao da array de cartoes
Local cSeq			:= Space(TamSX3("E5_SEQ")[1])
Local cMvTpRec		:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS")
Local lAliasMDM		:= AliasIndic("MDM")		// indica se existe Alias MDM
Local lAliasMDN     := AliasIndic("MDN")		// indica se existe Alias MDN
Local lLjRecBxFim   := ExistBlock("LJRECBXFIM")					// Ponto de entrada chamado no final da gravacao na retaguarda
Local nPosRetCart 	:= 0
Local cNSUTEFAux 	:= ""
Local cAutTEFAux 	:= ""
Local nPosAux 		:= 0
Local lAcreDecre	:= .T.										//verifica se existem os campos de valores de acrescimo e decrescimo no SE5
Local lAjustaAcres	:= .F.										// Tratamento necessário para recebimentos com baixas parciais
Local nVlDiferenca	:= 0										// Tratamento necessário para recebimentos com baixas parciais
Local lAjustaJuros	:= .F.
Local nVlDifJuros	:= 0
Local aOrdSE5		:= {}
Local lF070TRAVA	:= ExistBlock("F070TRAVA")
Local lF040TRVSA1	:= ExistBlock("F040TRVSA1")
Local lTravaSA1		:= .T.										// Se trava ou não o registro de cliente para baixa do titulo
Local nValVL		:= 0
Local nLjTrDin		:= SuperGetMV("MV_LJTRDIN",,0)
Local aAuxDados		:= {}										//variavel Generica que guarda varios valores temporarios
Local lGestao       := FWSizeFilial() > 2
Local lSe1Exc       := lGestao .And. FWModeAccess("SE1",3) == "E"
Local cFilOrig      := "" 
Local lTroco		:= IIF(cPaisLoc == "BRA",SuperGetMV("MV_LJTROCO",,.F.),SuperGetMV("MV_LJTRLOC",,.F.))  
Local cCampo		:= ""

DEFAULT nPrimMulta  := 0
DEFAULT nPrimJuros  := 0
DEFAULT nPrimDescon := 0
DEFAULT nTotReceb   := 0
DEFAULT lPgTef		:= .F.
DEFAULT aSE5Dados   := {}
DEFAULT cNomeUser   := cUserName
DEFAULT nValAbat    := 0
DEFAULT aSE5Bxas    := {}
DEFAULT aTitBxSE5	:= {}
DEFAULT cNumCheque	:= ""
DEFAULT aTitDelSE5	:= {}
DEFAULT nValTroco	:= 0
DEFAULT nMoeda		:= 1
DEFAULT nRecnoSE5   := 0
Default lWs			:= .F.						// Informa se esta executando via Web Service
Default nVlrJuros	:= 0
Default cNumMov		:= ""
Default aNsuVndTef	:= {}
Default cIdCart		:= ""
Default aPagDig 	:= {}

cNatureza := SuperGetMV("MV_NATRECE", NIL, "")
LjGrvLog("Recebimento_Titulo", "Conteudo MV_NATRECE(Padrao = RECEBIMENTO). Utilizado na gravacao SE5->E5_NATUREZ:",cNatureza)
cNatureza := If(Empty(cNatureza),'RECEBIMENTO',&(cNatureza))

LjGrvLog("Recebimento_Titulo", "Conteudo Param: cMV_LJRECEB:",cMV_LJRECEB)

If lFinancComp == NIL
   lFinancComp := 	LjRecFinComp()
   LjGrvLog("Recebimento_Titulo", "Verifica SE1 e SE5 compatilhados. Se exclusivo deve gerar SE5 tipo BA na filial de origem do titulo. lFinancComp:",lFinancComp) 
Endif

If !Empty( cCartFrt )
	cCartao := cCartFrt
	nValRec := nVlrRecebido
Endif

DbSelectArea("SE1")
SE1->(DbSetOrder(1))
lAchou := SE1->(DbSeek(cFilialTit + cPrefixo + cNum + cParcela + cTipo))

cFilOrig := IIF(lSe1Exc, cFilialTit, SE1->E1_FILORIG)

LjGrvLog("Recebimento_Titulo","Pesquisa titulo: SE1->(DbSeek(cFilialTit + cPrefixo + cNum + cParcela + cTipo))->("+cFilialTit+"/"+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo+") lAchou:",lAchou)

If lAchou .And. SE1->(E1_SALDO) <= 0
	LjGrvLog("Recebimento_Titulo", "Titulo nao possui saldo:SE1->(E1_SALDO) <= 0")
	lAchou := .F.
	lRet	:= .F.
EndIf

If cMV_LJRECEB == "4"
	If ExistBlock("LJBXEMS")
		lRet := ExecBlock("LJBXEMS", .F., .F., {cPrefixo,		cNum,		cParcela,	dVencimento, ;
		                                          nValor,		nVlrMulta,	nVlrJuros,	nVlrDesconto, ;
		                                          nVlrRecebido,	cTipo })
	Endif
Endif

If lAchou
	//Ponto de entrada que indica se irá alocar o cliente para atualização dos seus valores ou ira ignorar a atualização.
	If lF070TRAVA .And. lF040TRVSA1
		LjGrvLog("Recebimento_Titulo","Antes da Chamada dos Pontos de Entrada:F070TRAVA e F040TRVSA1")
		lTravaSA1 := ExecBlock("F070TRAVA", .F., .F.) .Or. ExecBlock("F040TRVSA1", .F., .F.)
		LjGrvLog("Recebimento_Titulo","Apos a Chamada dos Pontos de Entrada:F070TRAVA e F040TRVSA1. Return(lTravaSA1)",lTravaSA1)
	Else
		LjGrvLog("Recebimento_Titulo", "Verifica se possui PE:F070TRAVA  - Permite baixa com registro SA1 alocado",lF070TRAVA)
		LjGrvLog("Recebimento_Titulo", "Verifica se possui PE:F040TRVSA1 - Permite baixa com registro SA1 alocado",lF040TRVSA1)
	EndIf
	
	//Rotinas do financeiro nao atualizam SA1 quando possui PE configurado.
	If lTravaSA1
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
			If SA1->(Rlock())		// Funcao que tenta alocar sem chamar tela
				SA1->(MsUnlock())
			Else
				lRet := .F.
				LjGrvLog("Recebimento_Titulo",	"Não foi possível alocar o cliente: " +;
											SA1->A1_FILIAL+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA+"|"+SA1->A1_NOME)
				LjGrvLog("Recebimento_Titulo",	"Verificar os pontos de entrada 'F070TRAVA' e 'F040TRVSA1' para baixa com cliente alocado.")
			EndIf
		EndIf
	EndIf
EndIf

If lAchou .AND. lRet
    nRecnoSE1  := SE1->(Recno())
    
    /* Capturo a filial aqui pois caso o cFilAnt seja 
     alterado e o  compartilhamento da SE1 <> SA6, 
     ele achará*/
    cFilSA6		:= xFilial("SA6")
    
	If !lRecFilial
	    If lAliasMDM .AND. lAliasMDN
			AAdd(aBaixa, TrazCodMot("LOJ"))
		Else
			AAdd(aBaixa, TrazCodMot("NOR"))
		EndIf
	Else
		If cFilAnt <> cFilOrig
			AAdd(aBaixa, TrazCodMot("LOJ"))
			cFilBkp    := cFilAnt

			If !Empty(cFilialTit)
				cFilAnt    := IIF(lSe1Exc,cFilialTit,cFilOrig)
				LjGrvLog("Recebimento_Titulo", "Filial do título | cFilAnt", cFilAnt)
			EndIf

			If xFilial("SA6") <> cFilSA6
				LjGrvLog("RECEBIMENTO"," Filial SA6 (backup):" + cFilSA6)
				LjGrvLog("RECEBIMENTO"," Filial SA6 (atual):" + xFilial("SA6"))
				LjGrvLog("RECEBIMENTO"," Filial SE1:" + cFilialTit)
			EndIf
		Else
		    If lAliasMDM .AND. lAliasMDN
				AAdd(aBaixa, TrazCodMot("LOJ"))
			Else
				AAdd(aBaixa, TrazCodMot("NOR"))
			EndIf
		Endif
	Endif

	SA6->(dbSetOrder(2))
	If SA6->(dbSeek(xFilial("SA6")+Upper(cNomeUser)))
 		cCodCaixa := SA6->A6_COD
 		LjGrvLog("RECEBIMENTO","Pesquisa do banco - Indice (Filial + Nome Caixa) :" + cFilSA6 + Upper(cNomeUser) + " / Retorno : " + cCodCaixa) 		
    ElseIf SA6->(dbSeek(xFilial("SA6",cFilBkp) + Upper(cNomeUser))) // Caso SA6 exclusivo ou "semi-compartilhado" com gestão de empresas via partes de cFilBkp
      	cCodCaixa := SA6->A6_COD
      	LjGrvLog("RECEBIMENTO","Pesquisa do banco - Indice (Filial + Nome Caixa) :" + cFilBkp + Upper(cNomeUser) + " / Retorno : " + cCodCaixa)
    EndIf

    // Tratamento para o estorno da baixa parcial com juros e com compensação
   	If nVlrJuros == 0 .And. SE1->E1_JUROS > 0
		aOrdSE5 := SE5->(GetArea())
		DbSelectArea("SE5")
		SE5->(DbSetOrder(2)) //E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ
		If SE5->(DbSeek(xFilial("SE5")+"CP"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
			LjGrvLog("Recebimento_Titulo", "Antes de atualizar SE5(Tratamento para o estorno da baixa parcial com juros e com compensacao) - SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)",SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
			If Reclock("SE5", .F.)
				SE5->E5_VLJUROS += SE1->E1_JUROS
				SE5->(MSUnlock())
			EndIf
			LjGrvLog("Recebimento_Titulo", "Apos atualizar SE5(Tratamento para o estorno da baixa parcial com juros e com compensacao)")			
		EndIf
		RestArea(aOrdSE5)
	EndIf

    // Tratamento necessário para recebimentos com baixas parciais e com descontos
	If SE1->E1_SDACRES > 0
		If nVlrRecebido < SE1->(E1_SALDO+E1_SDACRES-nVlrDesconto)
			lAjustaAcres := .T.
			nVlDiferenca := nVlrRecebido - SE1->E1_SALDO
			nVlDiferenca := SE1->E1_SDACRES - nVlDiferenca - nVlrDesconto
		Else
			lAjustaJuros := .T.
			nVlDifJuros	 := SE1->E1_SDACRES
			nVlrJuros += nVlDifJuros
		EndIf
	EndIf

	//Array com os dados para baixa
	AAdd(aBaixa, cCodCaixa)
	AAdd(aBaixa, PadR(SA6->A6_AGENCIA,TamSX3("A6_AGENCIA")[1]))
	AAdd(aBaixa, PadR(SA6->A6_NUMCON,TamSX3("A6_NUMCON ")[1]))
	AAdd(aBaixa, dDataBase)
	AAdd(aBaixa, dDataBase)
	//"Recebimento do Titulo "
	AAdd(aBaixa, "LOJ-"+STR0044+cPrefixo+"/"+cNum+"/"+cParcela)
	AAdd(aBaixa, nVlrDesconto)
	AAdd(aBaixa, nVlrMulta)
	AAdd(aBaixa, nVlrJuros)
	AAdd(aBaixa, 0)
	AAdd(aBaixa, nVlrRecebido)
	AAdd(aBaixa, SE1->E1_NUMBCO)

	DbSelectArea("SE1")

	Begin Transaction

	LjGrvLog("Recebimento_Titulo", "FaBaixaCR - Antes de executar rotina de baixa do financeiro")

	If cPaisLoc == "BRA"
		cSeq := FaBaixaCR({ nValAbat ,0,0}, aBaixa)  //Gera SE5
	Else
	 	cSeq := FaBaixaCR({ nVlrDesconto,0,0}, aBaixa) //Gera SE5
	EndIf
	
	LjGrvLog("Recebimento_Titulo", "FaBaixaCR - Apos executar rotina de baixa do financeiro")

	If nValTroco > 0 .And. nLjTrDin != 1 .AND. lTroco
        //Volta a filial do título para a filial corrente para não dar erro no troco que consulta o banco vinculado ao caixa
        If lRecFilial .AND. !Empty(cFilBkp) .And. cFilAnt <> cFilBkp
            cFilAnt    := cFilBkp
        Endif

		LjGrvLog("Recebimento_Titulo", "Antes de executar a funcao de geracao de troco")

		If ExistFunc("LjNewGrvTC") .And. LjNewGrvTC() //Verifica se o sistema está atualizado para executar o novo procedimento para gravação dos movimentos de troco.
			lRet :=  LjTrocoInc(nValTroco	, 1 			 , 3    		, dDatabase		 ,;
								cCodCaixa	, Nil			 , Nil			, SE1->E1_PREFIXO,;
								SE1->E1_NUM	, SE1->E1_PARCELA, Nil 			, Nil			 ,;
								Nil			, Nil			 , SE1->E1_LOJA , SE1->E1_CLIENTE )
			If !lRet
				Disarmtransaction()
			EndIf
		Else
			AtuaTroco(	nValTroco		,1				,3				,SE1->E1_CLIENTE	,;
						SE1->E1_LOJA	,/*aTitulo*/	,cCodCaixa 	,Nil				,;
						Nil				)
		EndIf
		LjGrvLog("Recebimento_Titulo", "Apos executar a funcao de geracao de troco")
		
		//Volta a filial do título
		If lRecFilial .AND. cFilAnt <> cFilialTit .AND. !lFinancComp
			cFilBkp    := cFilAnt

			If !Empty(cFilialTit)
				cFilAnt    := cFilialTit
				LjGrvLog("Recebimento_Titulo", "Volta a filial do título | cFilAnt",cFilAnt)
			EndIf

		Endif
	EndIf
	
	If lRet

		LjGrvLog("Recebimento_Titulo", "Antes de atualizar dados da Tabela SE5. SE5->(Recno()):",SE5->(Recno()) )
		
		RecLock("SE5",.F.)
		REPLACE SE5->E5_MOEDA	WITH AllTrim(cFrmPag)
		REPLACE SE5->E5_BANCO	WITH cCodCaixa
		REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
		REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
		REPLACE SE5->E5_FORMAPG	WITH AllTrim(cFrmPag)
		If cPaisLoc <> "BRA"
			REPLACE SE5->E5_ORDREC WITH LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)//cRecibo
			REPLACE SE5->E5_SERREC WITH cSerieRec
		EndIf
		If Empty(SE5->E5_FILORIG)
			REPLACE SE5->E5_FILORIG WITH cFilAntBkp
		EndIf
		If	AllTrim(cFrmPag) == AllTrim(MVCHEQUE) .And. ;
			!Empty(cNumCheque)
			REPLACE SE5->E5_NUMCHEQ WITH cNumCheque
		EndIf

		REPLACE SE5->E5_ORIGEM WITH "LOJXREC"

		If lAcreDecre
			Replace E5_VLACRES   With Round(NoRound(xMoeda(SE1->E1_SDACRES,SE1->E1_MOEDA,1,SE1->E1_MOVIMEN,3,SE1->E1_TXMOEDA),3),2)
			Replace E5_VLDECRE   With Round(NoRound(xMoeda(SE1->E1_SDDECRE,SE1->E1_MOEDA,1,SE1->E1_MOVIMEN,3,SE1->E1_TXMOEDA),3),2)
		Endif

		If nVlrMulta > 0
			Replace SE5->E5_VLMULTA With nVlrMulta
		Endif

		If nVlrJuros > 0
			Replace SE5->E5_VLJUROS With nVlrJuros
		Endif

		If nVlrDesconto > 0
			Replace SE5->E5_VLDESCO With nVlrDesconto
		Endif

		REPLACE SE5->E5_NUMMOV	WITH cNumMov

		SE5->( MsUnlock() )
		nRecnoSE5  := SE5->( Recno() )
		
		// Se tiver Juros, Multa e/ou Deconto grava a Forma de pagamento nos demais registros
		If nVlrMulta > 0 .OR. nVlrJuros > 0 .OR. nVlrDesconto > 0
		
		LjGrFormPg( nRecnoSE5, cFrmPag, SE5->E5_ORIGEM , SE5->E5_FILIAL )
		
		EndIf
		
		LjGrvLog("Recebimento_Titulo", "Apos de atualizar dados da Tabela SE5")

		SE1->(DbSetOrder(1))
		SE1->(DbGoto(nRecnoSE1))
		
		LjGrvLog("Recebimento_Titulo", "Antes de atualizar dados da Tabela SE1. SE1->(Recno()):",nRecnoSE1)
		Reclock("SE1",.F.)

		// Tratamento necessário para recebimentos com baixas parciais
		If lAjustaAcres
			nVlDiferenca := iIf(SE1->E1_SDACRES < nVlDiferenca, SE1->E1_SDACRES, nVlDiferenca)
			SE1->E1_SALDO += nVlDiferenca
		EndIf
		If lAjustaJuros
			SE1->E1_JUROS -= nVlDifJuros
		EndIf
		SE1->E1_SDACRES	:= 0
		SE1->( MsUnlock() )
		
		LjGrvLog("Recebimento_Titulo", "Apos atualizar dados da Tabela SE1. SE1->E1_SALDO",SE1->E1_SALDO)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza saldo do BANCO Caixa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IsMoney(SE5->E5_MOEDA)
			LjGrvLog("Recebimento_Titulo", "AtuSalBco - Antes de executar rotina AtuSalBco - Tabelas envolvidas: SA6 e SE8")
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,"+")
			LjGrvLog("Recebimento_Titulo", "AtuSalBco - Apos executar rotina AtuSalBco")
		EndIf	

		//Somente alimenta aqui o array aSE5Dados, caso nao seja executado via Web Service
		//Quando executado via Web Service, o array aSE5Dados eh alimentado em outro momento
		If lPgTef .AND. !lWS 

			For nX = 1 To Len(aPgtos)

				cForma  := AllTrim(aPgtos[nX,3])

				//ID do Cartao               // CC;CD
				If (Empty(aPgtos[nX, 8]) .AND. !(cForma $ _FORMATEF)) .Or. ( AllTrim(cForma) <> alltrim(cFrmPag) .OR. (cIdCart <> aPgtos[nX][8]) )
					Loop
				EndIf

				nPosRetCart := 0
				aAuxDados	:= {}

				If cForma $ _FORMATEF .And. cTipTef == TEF_CLISITEF  .AND. lUsaTef
					nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgtos[nX][8] } ), 1)
				ElseIf lUsaTef .AND. cForma $ _FORMATEF .And. cTipTef == TEF_DISCADO
					nPosRetCart := Iif(lTefMult, aScan(aTEFDados, {|x| x[19] == aPgtos[nX][8] } ), 1)
				EndIf

				LjxRTefDa(	@aAuxDados	,	aPgtos	,	aNSUVndTef	,	lUsaTef ,;
							cTipTef		,	8	 	,	nPosRetCart , 	nX		,;
							aPagDig		)

				nY			:= 1
				cNSUTEFAux	:= aAuxDados[nY][6]
				cAutTEFAux	:= aAuxDados[nY][4]
				nPosAux		:= aScan(aSE5Dados , {|x| (x[1]+x[2]+x[3]+x[4]+x[7]+x[8]+x[5]+x[16]+x[14]) ==;
								(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIENTE+SE5->E5_LOJA+SE5->E5_SEQ+cNSUTEFAux+cAutTEFAux) } )

				If nPosAux == 0
					AADD(aSE5Dados,	{	SE5->E5_PREFIXO		,;				//01-E5_PREFIXO
										SE5->E5_NUMERO 		,;				//02-E5_NUMERO
										SE5->E5_PARCELA		,;				//03-E5_PARCELA
										SE5->E5_TIPO		,;				//04-E5_TIPO
										SE5->E5_SEQ			,;				//05-E5_SEQ
										SE5->E5_FILORIG		,;				//06-E5_FILORIG
										SE5->E5_CLIENTE		,;				//07-E5_CLIENTE
										SE5->E5_LOJA		,;				//08-E5_LOJA
										cForma				,;				//09-Forma Pgto.
										aPgtos[nX, 2]		,;				//10-Valor
										aAuxDados[nY][1]	,;				//11-Data
										aAuxDados[nY][2]	,;				//12-Hora
										aAuxDados[nY][3]	,;				//13-Doc
										aAuxDados[nY][4]	,;				//14-Autorizacao
										aAuxDados[nY][5]	,;				//15-Instituicao
										aAuxDados[nY][6]	,;				//16-NSU
										aAuxDados[nY][7]	,;				//17-Tipo do cartao
										"" 					,;				//18-SEQOPER
										nRecnoSE5 			,;				//19-RECSE5 - Recno do registro SE5
										"" 					,; 				//20-Doc Cancelamento TEF
										"" 					,; 				//21-Hora Cancelamento TEF
										"" 					,; 				//22-Data Cancelamento TEF
										Iif(Len(aAuxDados[nY])>=10,aAuxDados[nY][ 9],"")	,;	//23-Código da Bandeira
										Iif(Len(aAuxDados[nY])>=10,aAuxDados[nY][10],"")	,;	//24-Código Rede (Adquirência)
										Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][11],"")	,;	//25-Id da transação do Totvs Pagamento Digital (TRNID)
										Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][12],"")	,;	//26-Id da transação do processador do Totvs Pagamento Digital (TRNPCID)
										Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][13],"")	})	//27-Id externa da transação do Totvs Pagamento Digital (TRNEXID)
				Else
					aSE5Dados[nPosAux][10] += aPgtos[nX, 2] //10-Valor
				EndIf
			Next nX
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Guarda o Recno dos registro de baixas gerados sendo ou noa TEF     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aSE5Bxas		, { SE5->( Recno() ) } )
		aAdd( aTitBxSE5		, { SE5->( Recno() ) } )
		aAdd( aTitDelSE5	, {	SE5->( Recno() )	, SE5->E5_PREFIXO	, SE5->E5_NUMERO	, SE5->E5_PARCELA	,;
								SE5->E5_TIPO		, SE5->E5_CLIFOR	, SE5->E5_LOJA		, SE5->E5_SEQ		} )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incluida a gravacao da moeda, para possibilitar a demonstracao dos ³
		//³ detalhes dos titulos Recebidos por essa rotina no Resumo de Caixa  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lRecFilial .AND. aBaixa[1] == TrazCodMot("LOJ") .AND. !Empty( cFilBkp ) ) .OR.;
			( cFilAnt == cFilialTit .AND. Empty( cFilBkp ) .AND. ( IsMoney(cFrmPag) .OR. (AllTrim(cFrmPag) $ cMvTpRec) ) ) .OR.;
			( lFinancComp .AND. cFilAnt <> cFilialTit .AND. ( IsMoney(cFrmPag) .OR. (AllTrim(cFrmPag) $ cMvTpRec) ) )

			LjGrvLog("Recebimento_Titulo", "Entrou na condicao para tratamento de baixa entre filiais - 1",cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo)
			
			DbSelectArea( "SE5" )
			SE5->(DbSetOrder( 2 ))
			SE5->(DbGoto(nRecnoSE5)) 		// Alteracao para pegar o correto alias

			If	( ( lRecFilial .AND. (cMV_LJRECEB == "3" .OR. cMV_LJRECEB == "1") ) .OR.;
				( lFinancComp .AND. !lRecFilial .AND. (cMV_LJRECEB == "3" .OR. cMV_LJRECEB == "1") ) ) .OR.;
				( ( xFilial( "SE5" ) == SE5->E5_FILORIG .And. IsMoney(SE5->E5_MOEDA) .And. (cMV_LJRECEB == "3" .OR. cMV_LJRECEB == "1") ) )
				// A condicao "E5_FILIAL=E5_FILORIG e E5_MOEDA=DINHEIRO e cMV_LJRECEB=1 OU 3",
				// segue as orientacoes acima descritas no fonte, para geracao dos registros "BA" e "VL",
				LjGrvLog("Recebimento_Titulo", "Entrou na condicao para tratamento de gravacao dos registros SE5 'BA' e 'VL'")
				
				While SE5->( !Eof() ) .AND. ;
					xFilial( "SE5" )	== xFilial( "SE5" ) 	.AND. ;
					"BA" 		 		== SE5->E5_TIPODOC		.AND. ;
					cPrefixo         	== SE5->E5_PREFIXO		.AND. ;
					cNum             	== SE5->E5_NUMERO 		.AND. ;
					cParcela         	== SE5->E5_PARCELA 		.AND. ;
					cTipo 		 		== SE5->E5_TIPO

					LjGrvLog("Recebimento_Titulo", "Entrou no While SE5 TIPODOC = BA. cPrefixo/cNum/cParcela/cTipo",cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Incluir um titulo para a filal corrente exatamente igual ao titulo tipo BA ³
					//³lancado para a filial que originou o titulo.                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (SE5->E5_VALOR <> nVlrRecebido .AND. ( (SE5->E5_VALOR - nVlrRecebido) > 0.01 .OR. (nVlrRecebido - SE5->E5_VALOR) > 0.01 ) ) .OR. nRecnoSE5 <> SE5->(Recno())
						LjGrvLog("Recebimento_Titulo", "Realizou SE5->(Dbskip()). SE5->(Recno()): ",SE5->(Recno()))
						SE5->(Dbskip())
						Loop
					Endif

					If SE5->E5_SITUACA <> "C" .AND. SE5->E5_RECPAG == "R"

						LjGrvLog("Recebimento_Titulo", "Entrou If SE5->E5_SITUACA <> 'C' .AND. SE5->E5_RECPAG == 'R'. Antes de Atualizar SE5")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//| Grava no mov. bancario (baixa) a filial que originou o titulo  |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE1->(DbGoto(nRecnoSE1))
						RecLock("SE5",.F.)
						SE5->E5_FILORIG := SE1->E1_FILORIG
						SE5->( MsUnlock() )
						LjGrvLog("Recebimento_Titulo", "Entrou If SE5->E5_SITUACA <> 'C' .AND. SE5->E5_RECPAG == 'R'. Apos Atualizar SE5")

						For nX := 1 to nCount
							cCampo := SE5->(FieldName(nX))
							If !Upper(RTrim(cCampo)) $ "E5_IDORIG\E5_MOVFKS\E5_TABORI"
								AAdd( aDadosSE5, {cCampo,SE5->(FieldGet(nX))} )
							EndIf
						Next nX

						If Len(aDadosSE5) > 0
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_FILIAL "} ) ][2] := FwxFilial("SE5",IIf( Empty( cFilBkp ), cFilialTit, cFilBkp))
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_TIPODOC"} ) ][2] := IIf( (IsMoney(cFrmPag) .OR. (AllTrim(cFrmPag) $ cMvTpRec) ), "VL", "BA" )
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_MOTBX  "} ) ][2] := IIf( (IsMoney(cFrmPag) .OR. (AllTrim(cFrmPag) $ cMvTpRec) ), TrazCodMot("NOR"), TrazCodMot("LOJ") )
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_FILORIG"} ) ][2] := IIf( Empty( cFilBkp ), cFilOrig, cFilBkp )
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_SEQ    "} ) ][2] := cSeq
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_MOEDA  "} ) ][2] := AllTrim(cFrmPag)
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_ORIGEM "} ) ][2] := "LOJXREC"
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_FORMAPG"} ) ][2] := AllTrim(cFrmPag)
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_KEY    "} ) ][2] := aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_PREFIXO",10)} ) ][2] + ;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_NUMERO",10)} ) ][2] + ;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_PARCELA",10)} ) ][2] + ;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_TIPO",10)} ) ][2] +;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_CLIENTE",10)} ) ][2] + ;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_LOJA",10)} ) ][2]
							nValVL := SE5->E5_VALOR 
							If nLjTrDin = 0 .AND. lTroco
								nValVL += nValTroco
							EndIf
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_VALOR  "} ) ][2] := IIF(nMoeda > 1, xMoeda(nValVL, 1, nMoeda, dDataBase, 3), nValVL)
							RecLock( "SE5",.T. )
							For nX := 1 to Len( aDadosSE5 )
								FieldPut( ColumnPos( aDadosSE5[nX][1] ) , aDadosSE5[nX][2] )
							Next nX
							SE5->( MsUnlock() )  
							
							//Gera FKs com base na SE5 gerada
							FINXSE5( SE5->( Recno() ) , 1 )	//Movimento Bancario

							//Compatibiliza as Fks com padrao do loja
							LjCompFKs()
	
							aAdd( aTitBxSE5		, { SE5->( Recno() ) } )
							aAdd( aTitDelSE5	, {	SE5->( Recno() )	, SE5->E5_PREFIXO	, SE5->E5_NUMERO	, SE5->E5_PARCELA	,;
													SE5->E5_TIPO		, SE5->E5_CLIFOR	, SE5->E5_LOJA		, SE5->E5_SEQ		} )	//
							Exit
						EndIf
					EndIf
					SE5->( DbSkip() )
				End
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os valores de desconto, multa e juros no titulo baixado. ³
		//³Preve a situacao em que duas ou mais parcelas baixam o mesmo   ³
		//³titulo - BOPS 90.118                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lPrimBaixa
		SE1->(DbSetOrder(1))
		SE1->(DbGoto(nRecnoSE1))
		Reclock("SE1",.F.)
		REPLACE SE1->E1_VALLIQ WITH nTotReceb
		If nPrimMulta > 0 .OR. nPrimJuros > 0 .OR. nPrimDescon > 0
			REPLACE SE1->E1_DESCONT WITH nPrimDescon
			REPLACE SE1->E1_MULTA   WITH nPrimMulta
			REPLACE SE1->E1_JUROS   WITH nPrimJuros
		Endif
		SE1->( MsUnlock() )
		Endif
	
	EndIf

	End Transaction

	cFilAnt   := cFilAntBkp
ElseIf cMV_LJRECEB == "4"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao encontrar o SE1 e for baixa de titulo EMS cria uma movimentacao bancaria SE5 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reclock("SE5",.T.)
	Replace SE5->E5_FILIAL	WITH xFilial("SE5")
	Replace SE5->E5_DATA	WITH dDataBase
	Replace SE5->E5_TIPO	WITH "FI"
	Replace SE5->E5_BANCO	WITH xNumCaixa()
	Replace SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
	Replace SE5->E5_CONTA	WITH SA6->A6_NUMCON
	Replace SE5->E5_RECPAG	WITH "R"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recebimento do Titulo                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Replace SE5->E5_HISTOR	WITH STR0106+cPrefixo+"/"+cNum+"/"+cParcela
	Replace SE5->E5_TIPODOC	WITH "VL"
	Replace SE5->E5_MOEDA	WITH AllTrim(cFrmPag)
	If SE5->(FieldPos("E5_FORMAPG")) > 0
		REPLACE SE5->E5_FORMAPG	WITH AllTrim(cFrmPag)
	EndIf
	If SE5->(FieldPos("E5_ORIGEM")) > 0
		REPLACE SE5->E5_ORIGEM	WITH "LOJXREC"
	EndIf
	Replace SE5->E5_VALOR	WITH nValRec
	Replace SE5->E5_DTDIGIT	WITH dDataBase
	Replace SE5->E5_BENEF	WITH Space(15)
	Replace SE5->E5_DTDISPO	WITH SE5->E5_DATA
	Replace SE5->E5_NATUREZ	WITH cNatureza

	If SE5->(FieldPos("E5_NUMMOV")) > 0
		REPLACE SE5->E5_NUMMOV	WITH cNumMov
	EndIf

	SE5->( dbCommit() )
	SE5->( MsUnLock() )
	lRet := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada chamado no final da gravacao na retaguarda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjRecBxFim
	ExecBlock( "LJRECBXFIM", .F., .F., { aSE5Bxas } )
Endif

SA6->(RestArea(aAreaSA6)) //Deve retornar a área da SA6 para evitar que na ExecAuto do FINA040 seja pesquisado um índice errado

LJGRVLOG( "RECEBIMENTO", "Fim da baixa do título: "+cFilialTit+"/"+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo, SE1->E1_SALDO)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³LJRecHeade³ Autor ³ Cesar Eduardo Valadao ³ Data ³15/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao generica para montagem do aHeader                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJRecHeade( cMV_LJRECEB, cTitle, aHeader, aCampos )

Local lLjRecHead:= ExistBlock("LJRECHEAD")	//Identifica se existe o ponto de entrada
Local aRefCpos	:= {}						//Array multidimensional que serve de modelo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aCampos:                      ³
//³                                                 ³
//³1- Descricao dos campos                          ³
//³2- Posicao do campo existente no array aTitulos  ³
//³3- Picture do campo                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjRecHead
	//"Recebimento de Títulos"
	cTitle := STR0058
	AAdd(aRefCpos,{""	  , TIT_SELE, ""})

	//"Código"
	AAdd(aRefCpos,{"Cliente", TIT_CLIE, ""})

	//"Loja"
	AAdd(aRefCpos,{"Loja", TIT_LOJA, ""})

	//"Prefixo"
	AAdd(aRefCpos,{STR0060, TIT_PREF, ""})
	//"Titulo"
	AAdd(aRefCpos,{STR0061, TIT_NUME, ""})
	//"Parcela"
	AAdd(aRefCpos,{STR0062, TIT_PARC, ""})
	//"Tipo"
	AAdd(aRefCpos,{STR0063, TIT_TIPO, ""})
	//"Vencimento"
	AAdd(aRefCpos,{STR0064, TIT_VREA, ""})
	//"Valor"
	AAdd(aRefCpos,{STR0065, TIT_VALO, PesqPict("SE1", "E1_VALOR"	, 13)})
	//"Multa"
	AAdd(aRefCpos,{STR0066, TIT_MULT, PesqPict("SE1", "E1_MULTA"	, 13)})
	//"Juros"
	AAdd(aRefCpos,{STR0067, TIT_JURO, PesqPict("SE1", "E1_JUROS"	, 13)})
	//"Desconto"
	AAdd(aRefCpos,{STR0068, TIT_DESC, PesqPict("SE1", "E1_DESCONT"	, 13)})
	//"Recebimento"
	AAdd(aRefCpos,{STR0069, TIT_RECE, PesqPict("SE1", "E1_VALOR"	, 13)})

	aCampos := ExecBlock("LJRECHEAD",.F.,.F.,{aRefCpos})
	aHeader	:= {}
	Return Nil
Endif

If cMV_LJRECEB == "1"	// Financeiro
    //"Recebimento de Títulos"
	cTitle := STR0058
				 //"Cliente","Loja",  "Prefixo", "Título", "Parcela", "Tipo", "Vencimento", "Valor", "Vlr Acres", "Multa", "Juros", "Desconto", "Valor Recebido", "Dt.Baixa"	            
	aHeader := {"","",STR0009,STR0180, STR0060, STR0061, STR0062, STR0063, STR0064, STR0065, STR0186, STR0066, STR0067, STR0068, STR0069, STR0169}
ElseIf cMV_LJRECEB == "2"	// Gestao Educacional
    //"Recebimento de Títulos"
	cTitle := STR0058
	            //"Cliente","Loja","Prefixo", "Título", "Parcela", "Tipo", "Vencimento", "Valor", "Multa", "Juros", "Desconto", "Valor Recebido"
	aHeader := {"",STR0009,STR0180, STR0060, STR0061, STR0062, STR0063, STR0064, STR0065, STR0066, STR0067, STR0068, STR0069}
ElseIf cMV_LJRECEB == "3"	// Fidelizacao e Analise de Credito
    //"Recebimento de Parcelas"
	cTitle := STR0059
	//"Contrato","Cliente","Loja", "Prefixo", "Título", "Parcela", "Tipo", "Vencimento", "Valor", "Multa", "Juros", "Desconto", "Valor Recebido"
	aHeader := {"",STR0009,STR0180, STR0013, STR0060, STR0061, STR0062, STR0063, STR0064, STR0065, STR0066, STR0067, STR0068, STR0069}
ElseIf cMV_LJRECEB == "4"	// EMS
    //"Recebimento de Parcelas"
	cTitle := STR0059
	//"Cliente","Loja","Prefixo", "Contrato", "Parcela", "Tipo", "Vencimento", "Valor", "Multa", "Juros", "Desconto", "Valor Recebido"
	aHeader := {"",STR0009,STR0180, STR0060, STR0013, STR0062, STR0063, STR0064, STR0065, STR0066, STR0067, STR0068, STR0069}
Endif

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LJEMSExtra³ Autor ³ Cesar Eduardo Valadao ³ Data ³19/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de consulta Extrato EMS por Cartao ou CPF           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJEMSExtra( cCartao, cCPF, aEMSHeader, aEMSContra )
Local lRet
Local aDadosEMS  := {}
Local cDadosEMS  := ""
Local cRet       := ""
Local nI         := 0	// controle de loop
Local nJ         := 0	// controle de loop
Local nContratos := 0
Local nParcelas  := 0
Local aRet 		 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Ponto de entrada para gerar LayOut customizado.  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock( "LJLAYTEMS" )
	aRet := ExecBlock( "LJLAYTEMS" , .F. , .F., {cCartao, cCPF } )
	lRet := aRet[1]
	If lRet
		aEmsHeader := aClone(aRet[2])
		aEmsContra := aClone(aRet[3])
	Endif
Else
	AAdd(aDadosEMS, "36")						// Codigo da rede C.C.S.
	If Empty(cCartao)
		AAdd(aDadosEMS, "03")					// Consulta Extrato CCS por CPF
		cDadosEMS := PadL(cCPF, 11, "1")		// CPF (11 Digitos)
	Else
		AAdd(aDadosEMS, "02")					// Consulta Extrato CCS por Cartao
		cDadosEMS := PadL(cCartao,  16, "0")	// Numero do cartao (16 Digitos)
	Endif
	AAdd(aDadosEMS, cDadosEMS)					// Dados da consulta

	lRet := Loja010T("P", "CO", @aDadosEMS, .F., .F.)

	If lRet
		cRet := Substr(aDadosEMS[1],3)
		aEMSHeader := {}
		aEMSContra := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  1 - Nome Cliente                      |
		//|  2 - Data de Referencia                |
		//|  3 - Data Limite Vencimento            |
		//|  4 - Quant. total contratos            |
		//|  5 - Quant. contratos                  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aEMSHeader, Substr(cRet,1,20))
		cRet := Substr(cRet, 21)
		AAdd(aEMSHeader, CToD(Substr(cRet,7,2)+'/'+Substr(cRet,5,2)+'/'+Substr(cRet,3,2)))
		cRet := Substr(cRet, 9)
		AAdd(aEMSHeader, CToD(Substr(cRet,7,2)+'/'+Substr(cRet,5,2)+'/'+Substr(cRet,3,2)))
		cRet := Substr(cRet, 9)
		AAdd(aEMSHeader, Val(Substr(cRet,1,2)))
		cRet := Substr(cRet, 3)
		AAdd(aEMSHeader, Val(Substr(cRet,1,2)))
		cRet := Substr(cRet, 3)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  1 - Local do Contrato EMS            |
		//|  2 - Contrato EMS                     |
		//|  3 - DV local/Contrato                |
		//|  4 - Perc. Juros Financiamento        |
		//|  5 - Perc. Juros Mora                 |
		//|  6 - Perc. Multa                      |
		//|  7 - Quant. Total Parcelas"           |
		//|  8 - Quant. Parcelas                  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		nContratos := aEMSHeader[5]
		For nI := 1 to nContratos
			AAdd(aEMSContra, { {Substr(cRet,1,3),;
								Substr(cRet,4,7),;
								Substr(cRet,11,1),;
								Val(Substr(cRet,12,7))/100,;
								Val(Substr(cRet,19,9))/10000,;
								Val(Substr(cRet,28,7))/100,;
								Val(Substr(cRet,35,2)),;
								Val(Substr(cRet,37,2))},;
							   {}})
			cRet := Substr(cRet,39)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  1 - Parcela EMS                     |
			//|  2 - Vencimento da Parcela           |
			//|  3 - Valor Nominal da Parcela        |
			//|  4 - Indicador Atraso                |
			//|  5 - N. Dias Atraso/Antecipacao      |
			//|  6 - Valor Total Encargos            |
			//|  7 - Valor Total Desconto            |
			//|  8 - Valor Total Parcela             |
			//|  9 - Documento EMS Resumido          |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			nParcelas := aEMSContra[nI][1][8]
	    	For nJ := 1 to nParcelas
			  	AAdd(aEMSContra[nI][2], {Substr(cRet,1,2),;
										CToD(Substr(cRet,9,2)+'/'+Substr(cRet,7,2)+'/'+Substr(cRet,5,2)),;
										Val(Substr(cRet,11,12))/100,;
										Substr(cRet,23,1),;
						          		Substr(cRet,24,4),;
						          		Val(Substr(cRet,28,12))/100,;
						          		Val(Substr(cRet,40,12))/100,;
						          		Val(Substr(cRet,52,12))/100,;
										Substr(cRet,64,13)})
				cRet := Substr(cRet,77)
		    Next nJ
		Next nI
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LJEMSBaixa³ Autor ³ Cesar Eduardo Valadao ³ Data ³19/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que realiza a transacao de baixa do titulo no EMS   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJEMSBaixa( cContrato, cParcela, nValor )
Local lRet
Local aDadosEMS:={}

AAdd(aDadosEMS, "36")						// Codigo da rede C.C.S.
AAdd(aDadosEMS, nValor)						// Valor do pagamento
AAdd(aDadosEMS, "01") 						// Tipo da informacao "01" - Numero do contrato
AAdd(aDadosEMS, cContrato+cParcela)			// Numero do contrato + Numero da parcela
AAdd(aDadosEMS, "R$" ) 						// Forma de Pgto

lRet := Loja010T("P", "PG", @aDadosEMS, .F.)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ LJBoleto ³ Autor ³ Cesar Eduardo Valadao ³ Data ³24/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que realiza a impressao do boleto                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJBoleto()
Local nI		 := 0                                // Controle de loop
Local lSeleciona := .F.                             // Verifica se algum boleto foi selecionado
Local lLJImpBol  := ExistBlock("LJIMPBOL",,.T.)    // Verifica se o PE LJIMPBOL existe

AEval(aTitulo, {|x| If(x[TIT_SELE],lSeleciona:=.T.,)})
If lSeleciona
	For nI := 1 To Len(aTitulo)
	    //"Impressão de Boleto", "Confirma a impressão do boleto para o título "
	    //" no valor de ", "Sim", "Não"
		If aTitulo[nI][TIT_SELE] .AND. Aviso(STR0070, STR0071+aTitulo[nI][TIT_PREF]+"/"+aTitulo[nI][TIT_NUME]+"/"+aTitulo[nI][TIT_PARC]+;
				STR0072+SuperGetMV("MV_SIMB1")+" "+AllTrim(Transform(aTitulo[nI][TIT_VALO],PesqPict("SE1", "E1_VALOR", 13))), {STR0073, STR0074}) == 1
			If lLJImpBol
				ExecBlock("LJIMPBOL", .F., .F., aTitulo[nI])
			Else
			    //"Impressão do boleto..."
				MsgStop(STR0075)
			Endif
		Endif
	Next nI
Else
    //"Impressão de Boleto", "Não há nenhum título selecionado para a impressão do boleto.", "Ok"
	Aviso(STR0070, STR0076, {STR0003})
Endif

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LJRecGrvCH³ Autor ³ Cesar Eduardo Valadao ³ Data ³26/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que realiza a gravacao do cheque                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJRecGrvCH( cBanco		, cAgencia	, cConta	, cNum		,;
                     nValor		, dData		, cCompensa	, cRG		,;
                     cTel		, lTerceiro	, cPrefixo	, cTitulo	,;
                     cParcela	, cTipo		, cCliente	, cLojaCli, cEmitTer	)
Local nRec											//Recno da empresa/filial corrente
Local lLjRecChq		:= ExistBlock("LJRECCHQ")		//Ponto de entrada na gravacao dos cheques
Local cCpfCnpj		:= Space(TamSx3("A1_CGC")[1])	//CPF ou CNPJ do cliente
Local cEmitente		:= Space(TamSx3("A1_NOME")[1])	//Emitente

DEFAULT cCliente	:= cCCodcli
DEFAULT cLojaCli	:= cCLojCli
DEFAULT cEmitTer	:= cCCodcli

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek( xFilial("SA1") + cCliente + cLojaCli )
	cCpfCnpj   := SA1->A1_CGC
	cEmitente  := SA1->A1_NOME
EndIf

DbSelectArea("SM0")
DbSetOrder(1)
nRec := Recno()
DbSeek(cEmpAnt+cFilAnt)

DbSelectArea("SEF")

RecLock("SEF", .T.)
Replace SEF->EF_FILIAL	WITH xFilial("SEF")
Replace SEF->EF_BANCO	WITH cBanco
Replace SEF->EF_AGENCIA	WITH cAgencia
Replace SEF->EF_CONTA	WITH cConta
Replace SEF->EF_NUM		WITH cNum
Replace SEF->EF_VALOR	WITH nValor
If SEF->(Fieldpos("EF_VALORBX") ) > 0
	Replace SEF->EF_VALORBX WITH nValor
EndIf
Replace SEF->EF_DATA	WITH dDatabase
Replace SEF->EF_VENCTO	WITH dData
Replace SEF->EF_COMP	WITH cCompensa
Replace SEF->EF_BENEF	WITH SM0->M0_NOMECOM
Replace SEF->EF_CART	WITH "R"
Replace SEF->EF_TEL		WITH cTel
Replace SEF->EF_RG		WITH cRG
Replace SEF->EF_PREFIXO	WITH cPrefixo
Replace SEF->EF_TITULO	WITH cTitulo
Replace SEF->EF_TIPO	WITH cTipo
Replace SEF->EF_PARCELA	WITH cParcela
Replace SEF->EF_CLIENTE	WITH cCliente
Replace SEF->EF_LOJACLI	WITH cLojaCli
Replace SEF->EF_TERCEIR	WITH lTerceiro

If lTerceiro
	Replace SEF->EF_EMITENT	WITH Padr(cEmitTer, TamSx3("EF_EMITENT")[1])
Else
	Replace SEF->EF_EMITENT	WITH cEmitente
EndIf

Replace SEF->EF_CPFCNPJ	WITH cCpfCnpj
Replace SEF->EF_ORIGEM	WITH "FINA040"
SEF->(MSUnlock())

If lLjRecChq
   ExecBlock("LJRECCHQ",.F.,.F.)
Endif

DbSelectArea("SM0")
dbGoto(nRec)

DbSelectArea("SEF")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRecSistCºAutor  ³Fernando Salvatori  º Data ³ 04/02/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado para retornar o conteudo padrao do parametro     º±±
±±º          ³ MV_LJRECEB                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJRecSistCr()
Local oDlg                  //Dialogo Principal
Local oCombo                //Objeto Combobox
Local cVal                  //Valor da combo
Local cLJReceb   := SuperGetMV( "MV_LJRECEB" ) //Parametro
//"Financeiro", "Gestao Educacional", "Fidelização e Análise de Crédito", "EMS"
Local aDefault   := {{"1",STR0077},{"2",STR0078},{"3",STR0079},{"4",STR0080}} //Configuracao Default do Parametro
Local aItens     := {}      //Itens do Combo
Local lOk        := .F.     //Confirmacao da alteracao
Local cCriaCombo := ""      //Variavel que formata o parametro para fazer a combobox
Local nX         := 0       //Contador do sistema
Local nPos       := 0       //Pesquisa em array aDefault
Local nPos2      := 0       //Pesquisa em array aItens

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o parametro nao seja igual a 6, retornar apenas seu conteudo.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SubStr( cLjReceb,1,1) <> "6"
	Return SubStr( cLjReceb,1,1)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retiro os sistemas do parametro para escolha em tela.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCriaCombo := AllTrim(SubStr( cLjReceb,3 ))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimento a array aItens pertencentes a Combobox com tratamentos.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While .T.
	If Empty( cCriaCombo )
		Exit
	Endif

	nPos2 := At(";",cCriaCombo)

	If nPos2 <= 0
		If !Empty( AllTrim( cCriaCombo) )
			AAdd( aItens, AllTrim(cCriaCombo) )
		Endif

		Exit

	Else
		AAdd( aItens, SubStr( cCriaCombo,1,nPos2 - 1) )
		cCriaCombo := AllTrim(SubStr( cCriaCombo,At(";",cCriaCombo)+1 ))
	Endif
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao existe itens ou tenha apenas 1, retorno sem opcao de escolha;     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( aItens )
	Return Nil
ElseIf Len( aItens ) == 1
	Return SubStr(aItens[1],1,1)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formatacao do aItens caso precise (texto default.)                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( aItens )
	If AT( "=" , aItens[ nX ] ) <= 0
		nPos := aScan( aDefault, { | ExpA1 | ExpA1[1] == AllTrim(aItens[ nX ]) } )
		If nPos > 0
			aItens[ nX ] := aDefault[nPos][1] + "=" + aDefault[nPos][2]
		Endif
	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dialogo principal.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0081 From 00,00 To 120,220 PIXEL  //"Forma de recebimento"

@ 05,05 TO 35,105 LABEL STR0082 PIXEL   //"Escolha o sistema de crédito"
@ 15,10 COMBOBOX oCombo VAR cVal ITEMS aItens PIXEL SIZE 90,50

DEFINE SBUTTON FROM	40,45 TYPE 1 ENABLE OF oDlg ACTION (lOk := .T., oDlg:End())
DEFINE SBUTTON FROM	40,77 TYPE 2 ENABLE OF oDlg ACTION (lOk := .F., oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso confirme a operacao, retorno o valor a ser trabalhado pelo sistema. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOk
	Return cVal
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRecDblClºAutor  ³Microsiga			 º Data ³ 			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Acao ao dar duplo clique no list box dos titulos  		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXREC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRecDblClick( lLJDesBAlt )
Local cChave 	:= ""    				// Arquivo para Travamento do LockByname
Local lModLoja  := IIf(nModulo == 12 .AND. !(lMvLjPdvPa),.T.,.F.)
Local lFront	:= nModulo == 23		//a principio so avaliaremos se o modulo e FrontLoja
Local lLock		:= .T.
Local lSel		:= aTitulo[oTitulo:nAt][TIT_SELE]
Local cSeek		:= ""
Local cNumPdv 	:= LjGetStation("LG_PDV")  	// Numero do PDV
Local cSvcError := "" 						// Armazena a mensagem de Erro do WebService
Local lVldTit   := .T.	 //Valida se o titulo já foi baixado pelo financeiro.

cSeek  	:=	aTitulo[oTitulo:nAt][TIT_FILI] + aTitulo[oTitulo:nAt][TIT_CLIE] + ;
            aTitulo[oTitulo:nAt][TIT_LOJA] + aTitulo[oTitulo:nAt][TIT_PREF] + ;
            aTitulo[oTitulo:nAt][TIT_NUME] + aTitulo[oTitulo:nAt][TIT_PARC] + ;
            aTitulo[oTitulo:nAt][TIT_TIPO]  //Seek para achar o SE1

If lModLoja
	SE1->(DbSetOrder(2))
	SE1->(DbSeek(cSeek ) )
	cChave := SE1->E1_CLIENTE + SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA
	lLock := LockByName(cChave ,.T.,.F.,.T.)
ElseIf lFront
	cChave:= 	aTitulo[oTitulo:nAt][TIT_CLIE] + aTitulo[oTitulo:nAt][TIT_FILI] + ;
				aTitulo[oTitulo:nAt][TIT_PREF] + aTitulo[oTitulo:nAt][TIT_NUME] + ;
				aTitulo[oTitulo:nAt][TIT_PARC]
	cChave = AllTrim(StrTran(cChave, " "))

	If !lSel
		oSvc:LjLockTit(cChave,cNumPdv)
		lLock := oSvc:lLjLockTitResult
	Else
		oSvc:LjDelTit(cChave,cNumPdv)
		lLock := oSvc:lLjDelTitResult
	EndIf

	cSvcError := GetWSCError()
	If Left(cSvcError,9) == "WSCERR044"	// "Nao foi possivel post em http:// ..."
	     MsgStop( STR0151 ) //"Não foi possível estabelecer conexão com o servidor. Não será possível concluir este recebimento."
	EndIf
EndIf

If cOper == "2"
	lVldTit := LjVldTit(aTitulo, oTitulo:nAt)
	If !lVldTit
		aTitulo[oTitulo:nAt][TIT_SELE] := .F.
		MsgAlert (STR0204 + CRLF + STR0205 )	// "O título selecionado foi baixado total ou parcialmente em outra filial, ou diretamente pelo módulo Financeiro." / "Solução: O estorno deverá ser feito através do módulo Financeiro"
		LjGrvLog("RECEBIMENTO", STR0204 + "/" + STR0205 )
	EndIf
EndIf

If lVldTit
	If lLock 
		aTitulo[oTitulo:nAt][TIT_SELE] := !aTitulo[oTitulo:nAt][TIT_SELE]
		nTotal := 0
		AEval(aTitulo, {|x| If(x[TIT_SELE], IIf(x[TIT_RECE] <> x[TIT_VALO], nTotal += x[TIT_RECE], ;
		                                                           nTotal += x[TIT_VALO]+x[TIT_MULT]+x[TIT_JURO]-x[TIT_DESC]) ; 
										   , NIL) })
		oTotal:Refresh()
		
		If aTitulo[oTitulo:nAt][TIT_SELE]
			IF( lLJDesBAlt , if ( execblock( "LJBALTTI", .F., .F., { aTitulo , oTitulo:nAt }  ), oBtnEdit:Enable(), oBtnEdit:Disable() ) ,oBtnEdit:Enable() )
			oBtnAtu:Disable()
			If cOper == "2"
			   oBtnEdit:Disable()
			Endif
		Else
			oBtnEdit:Disable()
			oBtnAtu:Disable()
		Endif
	Else
		If Empty(cSvcError)
			aTitulo[oTitulo:nAt][TIT_SELE] := .F.
			MsgAlert (STR0122) //"Titulo em uso por outro Caixa"
		EndIf
	EndIf
EndIf

If lModLoja .AND. !aTitulo[oTitulo:nAt][TIT_SELE] 
	UnLockByName(cChave,.T.,.F.,.T. )
ElseIf (lModLoja .OR. nModulo == 23) 
	aTitulo[oTitulo:nAt][TIT_LOCK] := cChave
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjRecFinCoºAutor  ³Fernando Machima    º Data ³ 27/09/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se os arquivos SE1 e SE5 sao compartilhados. Esta  º±±
±±º			 ³informacao sera utilizada para determinar se deve gerar um  º±±
±±º			 ³registro no SE5 do tipo BA(E5_TIPODOC) na filial em que foi º±±
±±º			 ³gerado o titulo a receber. Se forem exclusivos, deve gerar. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXREC                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LjRecFinComp()

Local lCompartil := .F.   //Verifica se os arquivos SE1 e SE5 sao compartilhados

lCompartil := FWModeAccess("SE1",3) == "C"
If lCompartil
	lCompartil := FWModeAccess("SE5",3) == "C"
Endif

Return lCompartil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LJRecEstor³ Autor ³ Fernando Machima      ³ Data ³11/10/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Estorna o recebimento dos titulos selecionados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³LJRecEstorna(ExpO1, ExpC2, ExpC3, ExpC4)					  ³±±
±±³	         ³ExpO1 - objeto do nome do cliente						      ³±±
±±³	         ³ExpC2 - nome do cliente						      		  ³±±
±±³	         ³ExpC3 - codigo do cliente						      		  ³±±
±±³	         ³ExpC4 - loja do cliente						      		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJRecEstorna( oNomeCli, cNomeCli, cCodCli, cLojCli )

Local lRet   	:= .T.	//Controle da validacao, retorno da funcao
Local nI     	:= 0  	//Controle de loop
Local aRet   	:= {} 	//Retorno da funcao LjRecLoad com os titulos selecionados
Local aClientes := {}	//contem os clientes
Local nZ	 	:= 0
Local cIndSA1	:= ""
Local cPesqSA1	:=""

If cMV_LJRECEB == "1"

	aTitulo := {aTitVazio}

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	If Empty(cLojCli)
		cIndSA1 := "SA1->A1_FILIAL + SA1->A1_COD"
		cPesqSA1 := xFilial("SA1")+ cCodCli
	Else
		cIndSA1 := "SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA"
		cPesqSA1 := xFilial("SA1")+ cCodCli + cLojCli
	EndIf

	If SA1->(DbSeek(cPesqSA1,.T.))
		aClientes := {}

		While SA1->(!Eof()) .AND. (&(cIndSA1) == cPesqSA1)
			//Preenche a primeira posição pois somente permitirá que cliente com CNPJ/CPF cadastrado efetue a pesquisa
			Aadd(aClientes,{ IIF(Empty(AllTrim(SA1->A1_CGC)) ,.F., .T.),SA1->A1_FILIAL ,SA1->A1_COD,SA1->A1_LOJA,SA1->A1_CGC, "", "", SA1->A1_TIPO})
			SA1->(DbSkip())
		EndDo
	EndIf

	For nZ:= 1 to Len(aClientes)

		If aClientes[nZ][1] .OR. aClientes[nZ][8] == 'X'   // Cliente com CPF/CNPJ ou Cliente Estrangeiro

			cCodCli	:= aClientes[nZ][3]
			cLojCli	:= aClientes[nZ][4]
			cCPF	:= aClientes[nZ][5]
			cOper	:= "2"

			If !((nModulo == 12 .AND. lMvLjPdvPa) .Or. nModulo == 23)

				If Empty(cCodCli) .OR. Empty(cLojCli)
					//"Campos necessários não preenchidos", "É necessário informar o código do cliente.", "Ok"
					Aviso(STR0025, STR0083 , {STR0003})
					lRet := .F.
					Exit
				EndIf

				If lRet
					cOper    := "2"
					nTotal   := 0
					nMulta   := 0
					nJuros   := 0
					nDescont := 0
					nAcres   := 0
					nValRec  := 0
					oTotal:Refresh()
					//"Aguarde... Pesquisando Títulos baixados..."
					LJMsgRun(STR0084,, {|oDlg| aRet := LJRecLoad(cMV_LJRECEB, cCodCli, cLojCli, cCPF, cCartao, cNumRA, cPrefixo, cNum, cParcela)})

					If Len(aTitulo) > 0 .AND. Empty(aTitulo[1][TIT_NUME])
						aTitulo := {}
					EndIf

					If Len(aRet[4]) > 0
						For nI := 1 To Len(aRet[4])
							ASize(aRet[4][nI], Len(aRet[4][nI])+1)
							AIns(aRet[4][nI], 1)
							aRet[4][nI][1] := .F.
							Aadd(aTitulo , AClone(aRet[4][nI]) )
						Next nI
					EndIf

					oTitulo:aArray := aTitulo

					oNomeCli:Refresh()
					oLojCli:Refresh()

					If Len(aRet[4]) > 0

						If Len(aClientes) > 1
							cCodCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_COD")
							cNomeCli := ""
							cLojCli  := Space(TamSx3("A1_LOJA")[1])
						Else
							cNomeCli := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_NOME")
							cCodCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_COD")
							cLojCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_LOJA")
						EndIf

						oNomeCli:Refresh()

						oBtnOk:Enable()
						oTitulo:Enable()
						oTitulo:SetFocus()

					ElseIf Len(aTitulo) > 0

						If Len(aClientes) > 1
							cCodCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_COD")
							cNomeCli := ""
							cLojCli  := Space(TamSx3("A1_LOJA")[1])
						Else
							cNomeCli := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_NOME")
							cCodCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_COD")
							cLojCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_LOJA")
						EndIf

						oNomeCli:Refresh()

					Else
						oBtnOk:Disable()
						oCodCli:SetFocus()
						oTitulo:Disable()
					Endif
				EndIf
			Else

				If Empty(cCodCli) .OR. Empty(cLojCli)
					//"Campos necessários não preenchidos", "É necessário informar o código do cliente.", "Ok"
					Aviso(STR0025, STR0083 , {STR0003})
					lRet := .F.
				EndIf

				If lRet
					If ValType(oSvc) <> "O"
						oSvc      := WSLJRECEB():New()
                        iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
						oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"
					Endif

					//"Aguarde... Pesquisando Títulos em aberto..."
					LJMsgRun(STR0028,, {|oDlg| lRet := oSvc:GetTitulo(	cMV_LJRECEB,	cCodCli,	cLojCli,	cCPF,;
																		cCartao,		cNumRA,		cPrefixo,	cNum,;
																		cParcela,       cEmpAnt,    cFilAnt,    lMvLjPdvPa,;
																		"2" )})
				EndIf

		   		If lRet
		   			aRet := {0, "", "", Array(Len(oSvc:oWSGetTituloResult:oWSWSTitulo))}
					For nI := 1 To Len(oSvc:oWSGetTituloResult:oWSWSTitulo)
						aRet[4][nI] := { .F.,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cPrefixo,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cNumTitulo,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cParcela,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:dVencimento,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValor,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrMulta,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrJuros,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrDesconto,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrRecebido,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cTipo,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cContrato,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cCliente,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cLoja,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cFilTit,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nNumRecno, ;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nVlrAcres, ;
							.F.                                              , ;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValAbat, ;
							"",;
							"",;
							"",;
							"",;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:dDtBaixa	,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nSaldo		,;
							oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:nValLiq		}

							cCliente 	:= oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cCliente
							cLoja		:= oSvc:oWSGetTituloResult:oWSWSTitulo[nI]:cLoja

						If Len(aTitulo) > 0 .AND. Empty(aTitulo[1][TIT_NUME])
							aTitulo := {}
						EndIf

						Aadd(aTitulo , AClone(aRet[4][nI]))
					Next nI

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada para tratar a pesquisa dos³
					//³titulos em aberto do cliente               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLJRECVER
						aTitulo := ExecBlock( "LJRECVER" ,.F.,.F.,{aTitulo} )
					ElseIf ExistFunc("LjxRecver")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se trabalhar com o conceito de acrescimo separado, ³
						//³altera os titulos de financiamento com acrescimo   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aTitulo := LjxRecver(aTitulo)
					EndIf

					oTitulo:aArray := aTitulo

					If aRet[1] == 0 .AND. Len(aRet[4])>0
						cNomeCli := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_NOME")
						cCodCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_COD")
						cLojCli  := Posicione( "SA1",1,xFilial("SA1")+cCodCli+cLojCli,"SA1->A1_LOJA")
						oNomeCli:Refresh()

						oBtnOk:Enable()
						oTitulo:Enable()
						oTitulo:SetFocus()
					Else
						oBtnOk:Disable()
						oCodCli:SetFocus()
						oTitulo:Disable()
					Endif

					//Atualiza a PICTURE do campo CPF/CNPJ
					LjPicCPFCNPJ( @cCpf, @cCPFTemp )
		   	    Else

					cSvcError := GetWSCError()
					If Left(cSvcError,9) == "WSCERR048"
						cSoapFCode  := GetWSCError(2)
						cSoapFDescr := GetWSCError(3)
						MsgStop(cSoapFDescr, cSoapFCode)
					Else
						//"Sem comunicação com o WebService!", "Atenção!"
						MsgStop(STR0029,STR0030)
					Endif

		   	   	EndIf
		  	EndIf
		EndIf
	Next nZ
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LjRecBtnOK³ Autor ³ Fernando Machima      ³ Data ³11/10/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Chamada da funcao para estorno dos recebimentos e emissao da³±±
±±³			 ³sangria no ECF											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³LjRecBtnOK(ExpA1)											  ³±±
±±³	         ³ExpA1 - array com total e titulos selecionados 			  ³±±
±±³	    	 ³ExpA2 - variavel que retorna a necessidade de estornar	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRecBtnOK( aRet		, lConfEst	, cRecibo	, cSerieRec	,;
							lSelecTit	)
Local lLjRecConf  := ExistBlock("LJRECCONF")	//Verifica se existe o PE LJRECCONF
Local lLjRecFim   := ExistBlock("LJRECFIM") 	//Verifica se o PE LJRECFIM existe. PE chamado tanto para recebimento quanto para estorno
Local lRet        := .T.                     	//Controle da validacao, retorno da funcao
Local lSemErro    := .T.                     	//Controla se alguma baixa teve erro no estorno automatico
Local nX          := 0                         	//Controle de loop
Local nRet	      := -1                      	//Controle da execucao do comando de sangria no ECF
Local nValorTot   := 0                       	//Valor total estornado
Local cPortaGav   := LJGetStation("PORTGAV") 	//Porta da gaveta cadastrada na estacao(SLG)
Local cErros      := ""                      	//Mensagem com os dados dos titulos caso ocorra erro no estorno automatico
Local aDadosEst   := {}                    		//Dados dos titulos estornados
Local xRet		  								//Trata o retorno de PE.
Local aLote		  :=  {} 						// Array com titulos do lote
Local nPosTit	  := 0							// posição do titulo
Local aMsg		  := {} 						// Array com titulos a serem exibidos na menssagem (lote)
Local cLote		  := ""							// codigo do lote
Local nPosLote	  := 0							// posição do lote
Local lAliasMDM		:= AliasIndic("MDM")		// indica se existe Alias MDM
Local lAliasMDN     := AliasIndic("MDN")		// indica se existe Alias MDN
Local nY			:= 0
Local nCont			:= 0
Local lRetRec		:= .T.
Local cNumEst		:= ""
Local cPrefEst		:= ""
Local lRecNaoFis	:= LJModNFis()	//Sinaliza recebimento por modulo não fiscal(sem ECF) *NFC-e, Venda Direta
Local cMsgComp		:= ""
Local lObrigaImp	:= .F.			// indica se obriga a impressao do comprovante nao fiscal
Local aMensagem		:= {}			// [1] cabecalho [2] corpo [3] texto do botao da funcao Aviso
Local lPOS			:= ExistFunc("STFIsPOS") .AND. STFIsPOS() 
Local lAutomato     :=  If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) //Variavel referente a automacao de testes

Default cSerieRec	:= ""
Default lSelecTit	:= .T.

//Caso o caixa esteja fechado, não sera possivel prosseguir com o estorno do titulo
//No caso do recebimento de titulo, o caixa eh validado no momento de finalizar o pagamento.
If !lAutomato .AND. cOper == '2' .AND. !LjCxAberto(.T.) 
	lRet := .F.
EndIf

If lRet .AND. cPaisLoc <> "BRA"
	If !LjNfPtgNEcf(SM0->M0_CGC) //PTG e ANG sem ECF - NAO VAI VALIDAR ISSO
		If Empty(cRecibo)
			lRet := .F.
			Return lRet
		EndIf
	Else
		If !lConfEst
			If Empty(cSerieRec)
				lRet := .F.
				MsgAlert (STR0025 + "( " + STR0123 +")" ) // "Campos necessários não preenchidos" + "Serie"
				Return lRet
			Endif
			If Empty(cRecibo)
				lRet := .F.
				MsgAlert (STR0025 + "( " + STR0124 +")" ) // "Campos necessários não preenchidos" + "recibo"
				Return lRet
			EndIf
		EndIf
	EndIf
Endif

If lRet .AND. lLjRecConf
   lRet := ExecBlock("LJRECCONF", .F., .F.,{cOper, nTotal, aTitulo})
Endif

// valida a comunicacao com o ECNF (emissor de cupom nao fiscal) 
If lRet .AND. lRecNaoFis	
	If ExistFunc("LJObgImpNF") .AND. ExistFunc("INFCon")	//LOJXFUNB.PRX e LOJXECF.PRX 
		// se obrigar a impressao, verifica se a impressora está conectada
		lObrigaImp := LjObgImpNF(1, @aMensagem)	//1-se obriga a impressao do comprovante de Recebimento de Títulos
		LjGrvLog("RECEBIMENTO_TITULO", "Obriga a impressão do Comprovante Nao-Fiscal?", lObrigaImp)		

		If lObrigaImp
			// testa comunicacao com ECNF
			lRet := INFCon(.T.)
			LjGrvLog("RECEBIMENTO TITULO", "Resultado do teste de conexão", lRet)
			If !lRet .AND. Len(aMensagem) > 0
				Aviso( aMensagem[1], aMensagem[2], {aMensagem[3]} )
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se ao menos um titulo foi selecionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
   lRet  := .F.
   For nX := 1 to Len(aTitulo)
      If aTitulo[nX][TIT_SELE]
			If cOper == "2" .AND. lAliasMDM .AND. lAliasMDN
				DBSelectArea( "MDM" )
				MDM->(DBSetOrder( 1 ))
				MDM->(DBSeek(	xFilial("MDM") + aTitulo[nX][TIT_FILI] + aTitulo[nX][TIT_PREF] + aTitulo[nX][TIT_NUME] +;
								aTitulo[nX][TIT_PARC] + aTitulo[nX][TIT_TIPO] + Replicate("Z", TamSx3("MDM_SEQ")[1]), .T. ))
				MDM->(DbSkip(-1))
				If !MDM->(EOF())
					If DBSeek(MDM->MDM_BXFILI + MDM->MDM_PREFIX + MDM->MDM_NUM + MDM->MDM_PARCEL + MDM->MDM_TIPO)
						If (SE1->E1_VALOR == SE1->E1_SALDO) .AND. !Empty(SE1->E1_BAIXA)
							lRet  := .F.
							Exit
						Else
							lRet  := .T.
						EndIf
					Else
						lRet  := .T.
						exit
					EndIf
				Else
					lRet  := .T.
					exit
				EndIf
			Else
				//Atualiza o cliente da venda
				If Empty(cCodCli)
					cCodCli := aTitulo[nX][TIT_CLIE]
				EndIf

				If Empty(cLojCli)
					cLojCli := aTitulo[nX][TIT_LOJA]
				EndIf

				If cPaisLoc <> "ARG"
					lRet  := .T.
					Exit
				Else
					lRet  := .T.
					nCont++
					If nCont > 9
						lRet	:= .F.
						lRetRec	:= .F.
						MsgStop( STR0136 ) // "É permitido o cancelamento de no máximo 9 recebimentos por recibo."
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
   Next nX
   If !lRet .AND. lRetRec
       MsgStop(STR0085 + CRLF + STR0116)     // "Selecione ao menos um titulo para a operacao!" # "Os Titulos gerados nao devem conter baixas!"
   Endif
Endif

If lRet .AND. cOper == "2"  .AND. lAliasMDM .AND. lAliasMDN
	For nX := 1 to Len(aTitulo)
		If aTitulo[nX][TIT_SELE]
			DBSelectArea( "MDM" )
			MDM->( DbSetOrder(1) )
			If MDM->( DBSeek(xFilial( "MDM" ) + aTitulo[nX][TIT_FILI] + aTitulo[nX][TIT_PREF] + aTitulo[nX][TIT_NUME] + ;
				aTitulo[nX][TIT_PARC] + aTitulo[nX][TIT_TIPO]) )

				While !MDM->(Eof()) .AND. (aTitulo[nX][TIT_FILI] + aTitulo[nX][TIT_PREF] + aTitulo[nX][TIT_NUME] + ;
				aTitulo[nX][TIT_PARC] + aTitulo[nX][TIT_TIPO]) == (MDM->MDM_BXFILI + MDM->MDM_PREFIX + MDM->MDM_NUM + ;
					MDM->MDM_PARCEL + MDM->MDM_TIPO)

					If MDM->MDM_ESTORN == '2'
						cLote := MDM->MDM_LOTE
						Exit
					Else
						MDM->( DBSkip() )
					EndIf
            	End
            EndIf

            DBSelectArea( "MDM" )
			MDM->( DbSetOrder(2) )
			If MDM->( DBSeek(xFilial( "MDM" ) + cLote) )
				While !MDM->(Eof()) .AND. MDM->MDM_LOTE == cLote
					 If MDM->MDM_ESTORN <> '1'
						nPosLote := aScan(aLote , {|x| (x[1]+x[2]+x[3]+x[4]+x[5]) == (MDM->MDM_PREFIX + MDM->MDM_NUM + MDM->MDM_PARCEL + MDM->MDM_LOTE + MDM->MDM_TIPO) } )
						If nPosLote == 0
							AAdd( aLote , { MDM->MDM_PREFIX , MDM->MDM_NUM , MDM->MDM_PARCEL , MDM->MDM_LOTE, MDM->MDM_TIPO } )
						EndIf
				     EndIf
					MDM->(DBSkip())
				End
			EndIf
		EndIf
	Next nX

	aMsg	:= {}
	For nX := 1 to Len(aLote)
		nPosTit := aScan(aTitulo , {|x| ( cValtoChar(x[TIT_PREF] + x[TIT_NUME] + x[TIT_PARC] + x[TIT_TIPO])) == (cValtoChar(aLote[nX][1] + aLote[nX][2] + aLote[nX][3] + aLote[nX][5])) } )
		If nPosTit > 0 .AND. !aTitulo[nPosTit][TIT_SELE]
			lRet	:= .F.
			AAdd(aMsg	, aLote[nX][1] + " " +aLote[nX][2] + " " + aLote[nX][3] + " " + aLote[nX][5] )
		EndIf
	Next nX

	If Len(aMsg) > 0
		cListBox := aMsg[1]

		DEFINE MSDIALOG oDlg FROM 5, 5 TO 16, 50 TITLE STR0015		// "Estornar baixa..."

		@  .5, 2 LISTBOX cListBox ITEMS aMsg SIZE 150 , 40 Font oDlg:oFont
		DEFINE SBUTTON FROM 055,139.1  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		@ 50,5 SAY STR0117 SIZE 135,100 PIXEL OF oDlg   // "Obs: Para a baixa do(s) titulo(s) selecionado(s), eh preciso selecionar tambem o(s) titulo(s) acima listado(s). Pois estes titulos foram baixados no mesmo lote."
		ACTIVATE MSDIALOG oDlg CENTERED
   Endif
Endif

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Recebimento de titulos                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOper == "1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chamada do Ponto de Entrada LJRECALT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("LJRECALT")
       		xRet := ExecBlock("LJRECALT",.F.,.F.,{nTotal,aTitulo})
			If 	Len(xRet) == 2 .AND. Valtype(xRet) == "A" .AND. ValType(xRet[1]) == "N" .AND. ;
				ValType(xRet[2]) == "A"
				nTotal := xRet[1]
				aTitulo:= aClone(xRet[2])
			EndIf
		ElseIf ExistFunc("LjxRecAlt")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se trabalhar com o conceito de acrescimo separado  ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			xRet := LjxRecAlt(nTotal, aTitulo)
			If 	Len(xRet) == 2 .AND. Valtype(xRet) == "A" .AND. ValType(xRet[1]) == "N" .AND. ;
				ValType(xRet[2]) == "A"
				nTotal := xRet[1]
				aTitulo:= aClone(xRet[2])
			EndIf
		Endif
		aRet  := {nTotal, aTitulo}
		lRet  := .T.
		nValorTot  := nTotal
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Estorno de recebimentos		                    |
		//|"Confirma a operação de ESTORNO do recebimento?" |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If	IIF(lConfEst, lRet := MsgYesNo(STR0086), .T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			    //| "Aguarde, realizando o estorno dos títulos..."  |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If LJAnalisaLeg(35)[1]
					dbSelectArea("SFI")
					dbSetOrder(1)

					If !dbSeek(xFilial("SFI") + DtoS(dDatabase) + LJGetStation("PDV"))

						If !( nModulo == 23 .OR. (nModulo ==12 .AND. lMvLjPdvPa) )

							LJMsgRun(STR0087,, {|oDlg| LjRecCancBx(@nValorTot, @lSemErro, @cErros, @aDadosEst)})

						Else

							If ValType(oSvc) <> "O"
								oSvc      := WSLJRECEB():New()
                                iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
								oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"
							Endif

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Cria o array dentro do metodo ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							oSvc:oWSaTitEst:OWSVERARRAY 						:= LJRECEB_ARRAYOFWSTITULO():New()
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO 			:= Array( Len(aTitulo) )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Antes de chamar o metodo, atribui os valores ³
							//³as propriedades (passagem de parametros)     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nY := 1 To Len(aTitulo)

								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY] := LJRECEB_WSTitulo():New()
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cCliente 		:= aTitulo[nY][TIT_CLIE]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cContrato		:= aTitulo[nY][TIT_CONT]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cFilTit			:= aTitulo[nY][TIT_FILI]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cLoja			:= aTitulo[nY][TIT_LOJA]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cNumTitulo      := aTitulo[nY][TIT_NUME]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cParcela		:= aTitulo[nY][TIT_PARC]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cPrefixo		:= aTitulo[nY][TIT_PREF]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cTipo			:= aTitulo[nY][TIT_TIPO]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:dVencimento		:= aTitulo[nY][TIT_VREA]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:dVencOri		:= cTod(aTitulo[nY][TIT_VENC] )
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:lConcacrs		:= aTitulo[nY][TIT_CACR]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nNumRecno		:= aTitulo[nY][TIT_RECN]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nValabat		:= aTitulo[nY][TIT_ABAT]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nValor			:= aTitulo[nY][TIT_VALO]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrAcres		:= aTitulo[nY][TIT_ACRS]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrDesconto	:= aTitulo[nY][TIT_DESC]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrMulta		:= aTitulo[nY][TIT_MULT]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrJuros		:= aTitulo[nY][TIT_JURO]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrRecebido	:= aTitulo[nY][TIT_RECE]
								oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrRecebido	:= aTitulo[nY][TIT_RECE]
					   			oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:lSELEAS			:= aTitulo[nY][TIT_SELE]
					   			oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:dDtBaixa		:= aTitulo[nY][TIT_DTBX]
					   			oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nSaldo			:= aTitulo[nY][TIT_SALD]
				   				oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nValLiq			:= aTitulo[nY][TIT_VLIQ]

							Next nY
							
							

							LJMsgRun(STR0134,, {|oDlg| lRet := oSvc:EstoTitRec(nValorTot, lSemErro, cErros, NIL ,;
																				xNumCaixa(), cEmpAnt, cFilAnt )})

	 						If Type('oSvc:OWSESTOTITRECRESULT:nValorTot') <> 'U'

	 							nValorTot 	:= 	oSvc:OWSESTOTITRECRESULT:nValorTot
								lSemErro  	:=  oSvc:OWSESTOTITRECRESULT:lSemErro
								cErros 		:=	oSvc:OWSESTOTITRECRESULT:cErros
		           		    Else
		           		    	nValorTot := 0
		           		    EndIf		           		    
						EndIf

	        	    Else
	            		LJMsgLeg(LjAnalisaLeg(35))
	           		EndIf
	           	Else

		           	If !( nModulo == 23 .OR. (nModulo ==12 .AND. lMvLjPdvPa) )
						LJMsgRun(STR0087,, {|oDlg| LjRecCancBx(@nValorTot, @lSemErro, @cErros, @aDadosEst, Nil , Nil, Nil, lSelecTit)})

					Else

						If ValType(oSvc) <> "O"
							oSvc      := WSLJRECEB():New()
                            iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
							oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Cria o array dentro do metodo ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oSvc:oWSaTitEst:OWSVERARRAY 						:= LJRECEB_ARRAYOFWSTITULO():New()
						oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO 			:= Array( Len(aTitulo) )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Antes de chamar o metodo, atribui os valores ³
						//³as propriedades (passagem de parametros)     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nY := 1 To Len(aTitulo)

							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY] := LJRECEB_WSTitulo():New()
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cCliente 		:= aTitulo[nY][TIT_CLIE]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cContrato		:= aTitulo[nY][TIT_CONT]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cFilTit			:= aTitulo[nY][TIT_FILI]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cLoja			:= aTitulo[nY][TIT_LOJA]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cNumTitulo      := aTitulo[nY][TIT_NUME]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cParcela		:= aTitulo[nY][TIT_PARC]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cPrefixo		:= aTitulo[nY][TIT_PREF]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:cTipo			:= aTitulo[nY][TIT_TIPO]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:dVencimento		:= aTitulo[nY][TIT_VREA]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:dVencOri		:= cTod(aTitulo[nY][TIT_VENC] )
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:lConcacrs		:= aTitulo[nY][TIT_CACR]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nNumRecno		:= aTitulo[nY][TIT_RECN]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nValabat		:= aTitulo[nY][TIT_ABAT]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nValor			:= aTitulo[nY][TIT_VALO]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrAcres		:= aTitulo[nY][TIT_ACRS]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrDesconto	:= aTitulo[nY][TIT_DESC]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrMulta		:= aTitulo[nY][TIT_MULT]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrJuros		:= aTitulo[nY][TIT_JURO]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrRecebido	:= aTitulo[nY][TIT_RECE]
							oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nVlrRecebido	:= aTitulo[nY][TIT_RECE]
				   			oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:lSELEAS			:= aTitulo[nY][TIT_SELE]
				   			oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:dDtBaixa		:= aTitulo[nY][TIT_DTBX]
				   			oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nSaldo	   		:= aTitulo[nY][TIT_SALD]
			   				oSvc:oWSaTitEst:OWSVERARRAY:OWSWSTITULO[nY]:nValLiq			:= aTitulo[nY][TIT_VLIQ]

							If aTitulo[nY][TIT_SELE] // Vai guardar o ultimo pref e num do titulo para gerar o SE5
								cNumEst	 :=	aTitulo[nY][TIT_NUME]
								cPrefEst :=	aTitulo[nY][TIT_PREF]
						    EndIf
						Next nY

						LJMsgRun(STR0134,, {|oDlg| lRet := oSvc:EstoTitRec(nValorTot, lSemErro, cErros, oSvc:oWSaTitEst ,;
																				xNumCaixa(), cEmpAnt, cFilAnt   )})

 						If Type('oSvc:OWSESTOTITRECRESULT:nValorTot') <> 'U'

 							nValorTot 	:= 	oSvc:OWSESTOTITRECRESULT:nValorTot
							lSemErro  	:=  oSvc:OWSESTOTITRECRESULT:lSemErro
							cErros 		:=	oSvc:OWSESTOTITRECRESULT:cErros
	           		    Else
	           		    	nValorTot := 0
	           		    EndIf

	           		EndIf

	           	EndIf
	           	
	           	// Faz o cancelamento da transação TEF
	            If !lPOS .And. lSemErro .And. Empty(cErros) .And. nValorTot > 0 .And. len(aDadosTef) > 0
	           		LjXCEstTef(nValorTot)
	           	EndIf
	           	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faz a sangria para registrar a saida de numerario no ECF³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  		If nValorTot > 0
		  			If !lRecNaoFis
		               	nRet := IFSupr( nHdlECF, 3, Str(nValorTot,14,2), '', '' )
		               	If nRet = 0
					      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					      //³Verifica se ha gaveta configurada na porta COM³
						  //³Caso nao tenha envia o comando pelo ECF       ³
						  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						  If lGaveta
						     nRet := GavetaAci( nHdlGaveta, cPortaGav )
						  Else
						     nRet := IFGaveta( nHdlECF )
						  Endif
						  If lSemErro
							 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						     //| "Estorno efetuado com sucesso!"                 |
							 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						 	 MsgInfo(STR0088)
						  ElseIf Len(cErros) > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						    //|"Não foi possível realizar o estorno dos títulos listados abaixo: "    |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						     MsgInfo(STR0089+CRLF+cErros)
						  Endif
					   	Else
						  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					      //| "As baixas foram estornadas, mas não foi possível registrar sangria no ECF.", "Atenção!"            |
						  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						  MsgInfo(STR0090, STR0030)
						Endif

						If nModulo == 23 .OR. (nModulo ==12 .AND. lMvLjPdvPa)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Para o PDV gera um registro total com o valor total do estorno para o fechamento de caixa ³
							//³ No futuro essa funcao pode ser implementada para gerar um E5 para cada tit estornado      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							SA6->(dbSetOrder(2))
							SA6->(dbSeek(xFilial("SA6")+Upper(cUserName)))

							Reclock("SE5",.T.)		// Este SE5 nao devera subir para a retaguarda.
							REPLACE SE5->E5_FILIAL	WITH xFilial("SE5")
							REPLACE SE5->E5_DATA	WITH dDataBase
							REPLACE SE5->E5_TIPO	WITH "FI"
							REPLACE SE5->E5_BANCO	WITH xNumCaixa()
							REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
							REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
							REPLACE SE5->E5_PREFIXO	WITH cPrefEst
							REPLACE SE5->E5_NUMERO	WITH cNumEst
							REPLACE SE5->E5_RECPAG	WITH "P"
							REPLACE SE5->E5_HISTOR	WITH "LOJ-"+IIf( Empty(cLote), STR0120, STR0121+cLote ) // Cancelamento de baixa###"Canc Baixa Lote "
							REPLACE SE5->E5_TIPODOC	WITH "ES"
							REPLACE SE5->E5_VALOR	WITH nValorTot
							REPLACE SE5->E5_DTDIGIT	WITH dDataBase
							REPLACE SE5->E5_BENEF	WITH Space(15)
							REPLACE SE5->E5_DTDISPO	WITH dDataBase
							REPLACE SE5->E5_NATUREZ	WITH &(SuperGetMV("MV_NATRECE"))			// RECEBIMENTO
							Replace SE5->E5_NUMMOV	WITH AllTrim(LJNumMov())
							REPLACE SE5->E5_SITUACA	WITH "C"
							DbCommit()
							SE5->(MsUnLock())
						EndIf
					Else
						//       "C O M P R O V A N T E"
						//   "D E   R E C E B I M E N T O"
						//	 "E S T O R N O"
						cMsgComp	 	:= 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
											Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
											Chr(10) + Chr(10) +;
											Space((40-Len(STR0183)) / 2) + STR0183 + Chr(10) +;
											Chr(10) + Chr(10) +;
											Replicate("=",40) + Chr(10) +;
											STR0182 + Space(14) + Trans(nValorTot,"@E 999,999,999.99")

						nRet := INFTexto(cMsgComp)

						If ExistFunc('INFCutPpr') //Corte de Papel e quebra de linhas
							INFCutPpr()
						EndIf

						If nRet == 0
							If lSemErro
								// "Estorno efetuado com sucesso!"
							 	 MsgInfo(STR0088)
							ElseIf Len(cErros) > 0
								// "Não foi possível realizar o estorno dos títulos listados abaixo: "
							     MsgInfo(STR0089+CRLF+cErros)
							EndIf
						Else
							MsgInfo(STR0181,STR0030) //"As baixas foram estornadas, mas não foi possível registrar sangria na Impressora","Atenção!"
						EndIf
					EndIf
				ElseIf Len(cErros) > 0
				   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 	   //|"Não foi possível realizar o estorno dos títulos listados abaixo: "|
				   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				   MsgInfo(STR0091+CRLF+cErros)
				Endif
			Endif
	Endif
	If lLjRecFim
       ExecBlock("LJRECFIM",.F.,.F.,{cOper, lRet, nValorTot, aTitulo, aDadosEst})
	Endif
Endif

//Tratamento para casos em que houver algum problema no WS e nao retornar um valor logico.
If ValType(lRet) <> "L"
	lRet := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LjRecCancB³ Autor ³ Fernando Machima      ³ Data ³11/10/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Estorna as baixas dos titulos selecionados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³LjRecCancBx(ExpN1, ExpL2, ExpC3, ExpA4, ExpL5)              ³±±
±±³	         ³ExpN1 - valor total das baixas estornadas					  ³±±
±±³	         ³ExpL2 - controla se houve erro no estorno de alguma baixa	  ³±±
±±³	         ³ExpC3 - dados dos titulos cujo estorno nao foi executado	  ³±±
±±³	         ³ExpA4 - dados dos recebimentos estornados                   ³±±
±±³	         ³ExpL5 - indica se e cancelam. de cupom Tef (opcional)    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRecCancBx(	nValorTot	, lSemErro	, cErros	, aDadosEst	,;
							 	lCancTef	, lWs		, cNomeUser	, lSelecTit	,;
							 	aVlCompEst	, aSe5Est	,aLotesMDM  , aListTit)

Local aBaixa     	:= {}                     	//Array do SE1 para chamada da rotina automatica
Local aBaixaTit  	:= {}                     	//Array com os dados das baixas de um mesmo titulo
Local aBxTit		:= {}
Local aAreaSE1		:= {}
Local aAreaSE5		:= {}
Local nX         	:= 0                        //Controle de loop
Local nY			:= 0
Local nOpBaixa   	:= 0                      	//Baixa selecionada quando ha mais de uma baixa para um mesmo titulo
Local nTamSE5Num 	:= TamSX3("E5_NUMERO")[1]  	//Tamanho do campo E5_NUMERO
Local cListBox                              	//List box com os dados dos titulos a receber que tem mais de uma baixa
Local oDlg                                  	//Caixa de dialogo quando ha mais de uma baixa para o titulo a receber
Local lFoundSE5  	:= .F.                     	//Controla se o registro da baixa do titulo foi encontrado
Local lChkslv     	:= ChkFile("SLV")			//Retorna se o arquivo SLV foi criado
Local cNumCaixa		:= xNumCaixa()				//Caixa que efetuou o estorno.
Local cMDMOper		:= "2"						// Tipo de gravacao no MDM 1=Inclusao 2= Alteracao
Local lRecFilial	:= SuperGetMV("MV_LJRECFI",,.F. ) 		// Controla se trata todas as filiais(Logico)
Local lAliasMDM		:= AliasIndic("MDM")
Local lAliasMDN     := AliasIndic("MDN")
Local cMDMLote		:= IIf(lAliasMDM, Space(TamSX3("MDM_LOTE")[1]), Space(6))
Local cTipoDoc		:= ""
Local lEstParc      := .F.                      //Verifica se foi feito estorno parcial
Local cOrdRec		:= ""
Local cSerRec		:= ""
Local nPosTit		:= 1
Local aBxSE5Bkp		:= {}
Local lTroco		:= .F.
Local nValTroco		:= 0
Local nPosDelSE5	:= 1
Local cLjOpEst		:= SuperGetMV("MV_LJOPEST",,"1" )// Controla se fara ou não o estorno de compesações de crédito
Local aTotaisBkp		:= IIF(Type("aTotais") == "A", aClone(aTotais), NIL) //Backup da variavel private aTotais
Local nEstTroco     := 0  //Guarda o Recno do Troco para usar após a conclusão do processo de estorno
Local lSelLot		:= .f. //Lote já selecionado
Local cMsgErro		:= "" //mensagem de erro do estorno TEF
Local aSE5Selec 	:= {}
Local lGestao       := FWSizeFilial() > 2
Local lSe1Exc       := lGestao .And. FWModeAccess("SE1",3) == "E"
Local lRetGrvMDX	:= .T. // Retorno da Função LjxGrvMDX
Local aTitBaixad	:= {}  // Array com Títulos Baixados que não podem ser Estornados
Local cTextBaix		:= ""  // Texto com Títulos já Baixados que será apresentado, após tentativa de Estorno
Local aTitEstorn	:= {}  // Array com Títulos Estornados
Local cTextEston 	:= ""  // Texto com Títulos Estornados será apresentado
Local nCountTit 	:= 0   // Contador For/Next Títulos que serão visualizados para Estorno	

Private lMsErroAuto := .F.                  	//Controle de erro na rotina automatica
Private aBaixaSE5   := {}                   	//Array utilizado na rotina de selecao das baixas para estorno do recebimento(FINA070)
Default lCancTef	:= .F.						// Indica se o estorno da baixa eh por motivo de cancelam. de cupom TEF
Default lWs			:= .F.						// Informa se está utilizando WS
Default lSelecTit	:= .T.
Default aVlCompEst	:= {}						//Valor de estorno da compensação de NCC
Default aSe5Est		:= {}						//SE5 que será estornadas pelo Totvs pdv
Default aLotesMDM	:= {}
Default aListTit	:= aClone(aTitulo)


If cPaisLoc == "BRA"
	lTroco  := SuperGetMV("MV_LJTROCO",,.F.)
Else
	lTroco  := SuperGetMV("MV_LJTRLOC",,.F.)
EndIf

If ValType(cNomeUser) <> "U"
	cNumCaixa := cNomeUser
EndIf

For nX := 1 to Len(aTitulo)
	lFoundSE5  := .F.
	DbSelectArea("SE1")
	SE1->( DbSetOrder(1) )
	If aTitulo[nX][TIT_SELE]
		aBaixa      := {}
		aBaixaSE5   := {}
		lMsErroAuto := .F.
		
		LjGrvLog( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "LjRecCancBx  - Processando titulo ")

		SE1->( DbGoto(aTitulo[nX][TIT_RECN]) )

		AADD(aBaixa , {"E1_FILIAL"    , SE1->E1_FILIAL		, NIL})
		AADD(aBaixa , {"E1_PREFIXO"   , SE1->E1_PREFIXO		, NIL})
		AADD(aBaixa , {"E1_NUM"       , SE1->E1_NUM			, NIL})
		AADD(aBaixa , {"E1_PARCELA"   , SE1->E1_PARCELA		, NIL})
		AADD(aBaixa , {"E1_TIPO"      , SE1->E1_TIPO		, NIL})
		AADD(aBaixa , {"E1_CLIENTE"   , SE1->E1_CLIENTE		, NIL})
		AADD(aBaixa , {"E1_LOJA"      , SE1->E1_LOJA		, NIL})
		AADD(aBaixa , {"E1_DESCONT"   , SE1->E1_DESCONT	, NIL})

   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao para estorno dos titulos que tem baixas por compensacao. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cLjOpEst == "1" // Processará estorno de todas as compensações referentes ao titulo
			aBaixaSE5 := {}
			Sel070Baixa( "CP"	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,   SE1->E1_TIPO	 ,NIL	  , .T.	, SE1->E1_CLIENTE,     SE1->E1_LOJA	  ,NIL ,NIL  ,NIL , NIL  ,.T. ,.T.	)
			If Len(aBaixaSE5) > 0
				aAdd(aVlCompEst, aClone(aBaixaSE5))
			EndIf
			aBaixaSE5 := {}
			EstoBxNCC(nX)

        ElseIf cLjOpEst == "2"  // Verifica se há titulos baixados e perguntará se processa estorno
			aBaixaTit := Sel070Baixa( "CP"	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,   SE1->E1_TIPO	 ,NIL	  , .T.	, SE1->E1_CLIENTE,     SE1->E1_LOJA	  ,NIL ,NIL  ,NIL , NIL  ,.T. ,.T.	)
			If Len(aBaixaTit) > 0
				If MsgYesNo(STR0155, STR0156)//"Há Baixas por Compensação no Financeiro , Processa o Estorno das compensações?","Atenção"
					EstoBxNCC(nX)
				Else
					cLjOpEst := "3" // Alterado para "3" Decosiderar a NCC, para que não seja feita a baixa total do Titulo do Cliente.
				EndIf
			EndIf
        EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca as baixas do titulo 						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		// Verifica se foi aplicado o update U_UPDLOJ33
		If lAliasMDM .AND. lAliasMDN
			If SE1->E1_FILIAL == xFilial("SE5")
				cTipoDoc := "V2 /BA /RA /CP /LJ /"
			Else
				cTipoDoc := "VL /V2 /BA /RA /CP /LJ /"
			EndIf
	    Else
			cTipoDoc := "VL /V2 /BA /RA /CP /LJ /"
		EndIf

		aBxTit := Sel070Baixa( cTipoDoc+MV_CRNEG						,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
									SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
									SE1->E1_LOJA						,NIL				,NIL			,NIL,;
									NIL									,.T.	)

		// Realiza tratamento para eliminar registros duplicados no array aBxTit.
		For nCountTit := 1 To Len( aBxTit )			
			nY		:= 1		
			cTitulo := aBxTit[nCountTit]
			For nY := 1 To Len(aBxTit)
				If nY <> nCountTit .AND. aBxTit[nY] == cTitulo 
					aDel( aBxTit, nCountTit )
					aSize( aBxTit, Len( aBxTit ) - 1 )
					nCountTit++
				EndIf
			Next nY
		Next nCountTit

		aBaixaSE5 := {}

		aBaixaTit := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
									SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
									SE1->E1_LOJA						,NIL				,NIL			,NIL,;
									NIL									,.T.	)		
		lSelLot := .f.							
		//Verifica se o título está vinculado a um lote de baixa
       If !lSelecTit
			If nPosDelSE5 <= Len(aTitDelSE5)
				nOpBaixa := aScan( aBaixaSE5 , { |x| ( x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[9] + x[25] ) == ( aTitDelSE5[nPosDelSE5][2] +;
												( aTitDelSE5[nPosDelSE5][3] + Iif( Len(aTitDelSE5[nPosDelSE5][3]) == TamSX3("E5_NUMERO")[1], Space(TamSX3("E5_NUMERO")[1]), "" ) ) +;
												aTitDelSE5[nPosDelSE5][4] + aTitDelSE5[nPosDelSE5][5] + aTitDelSE5[nPosDelSE5][6] + aTitDelSE5[nPosDelSE5][7] +;
												aTitDelSE5[nPosDelSE5][8] + "BA" ) } )
				nPosDelSE5 += 2
			EndIf
		Else
			If  (nPosLtMDM := aScan(aLotesMDM, { |l| l[1] == SE1->E1_FILIAL .AND. l[2] == SE1->E1_PREFIXO	 .AND. l[3] == SE1->E1_NUM	 .and. l[4] == SE1->E1_PARCELA .AND. l[5] ==  SE1->E1_TIPO })  ) > 0
				LjGrvLog( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "LjRecCancBx - Localizou lote de baixa "+ aLotesMDM[nPosLtMDM][7] + "Seq Baixa " + aLotesMDM[nPosLtMDM][6])
				//Localiza a sequencia da baixa
				nOpBaixa := aScan( aBaixaSE5 , { |x| ( x[1] +  Substr(x[2],1,nTamSE5Num)  + x[3] + x[4] + x[5] + x[6] + x[9] + x[25] ) == ( SE1->E1_PREFIXO +;
													 SE1->E1_NUM + SE1->E1_PARCELA +  SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA + aLotesMDM[nPosLtMDM, 06] +;
													 "BA" ) } )
				lSelLot :=  nOpBaixa  > 0

				LjGrvLog( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "LjRecCancBx - Posicao de baixa"+ aLotesMDM[nPosLtMDM][7] + "Seq Baixa " + cValToChar(nOpBaixa))
						
			EndIf

		EndIf
		
		aSort(aBaixaSE5,,, {|x,y| x[9] < y[9] } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Permite selecionar a sequencia da baixa do titulo, se tiver mais de uma³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSelecTit .AND. !lSelLot
			If Len(aBaixaTit) > 1 .AND. !lCancTef
				nOpBaixa := 1
				If !lWs
					If !lAliasMDM .AND. !lAliasMDN
						lEstParc := .T.
					EndIf
					cListBox := aBxTit[1]
					nOpBaixa := 0
					DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 55 TITLE STR0092  //"Escolha a Baixa"

					@  .5, 2 LISTBOX cListBox ITEMS aBxTit SIZE 170 , 40 Font oDlg:oFont
					DEFINE SBUTTON FROM 055,112    TYPE 1 ACTION (nOpBaixa := 1,oDlg:End()) ENABLE OF oDlg
					DEFINE SBUTTON FROM 055,139.1  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

					ACTIVATE MSDIALOG oDlg CENTERED
					If nOpBaixa == 0
						Loop
					Else
						aSE5Selec := LjEstSelE5(cListBox)

						nOpBaixa := aScan( aBaixaSE5 , { |x| ( x[1] + Substr(x[2],1,nTamSE5Num)  + x[3] + x[4] + x[5] + x[6] + x[9] ) ==;
						(aSE5Selec[1] + aSE5Selec[2]  + aSE5Selec[3] + aSE5Selec[4] + aSE5Selec[5] + aSE5Selec[6] + aSE5Selec[9] ) } )

						nOpSelBxa := Ascan(aBxTit,cListBox)
					EndIf

				Else
					// Tratamento necessário para recebimentos com baixas parciais
					aSort(aBaixaTit)
					nOpBaixa	:= Len(aBaixaTit)

				EndIf
			Else
				nOpBaixa := 1
			EndIf
		EndIf

		If Len(aBaixaSE5) == 0
			//Somente quando o total do recebimento foi feito via compensação
			If cLjOpEst == "1" .And. SE1->E1_SALDO == SE1->E1_VALOR .And. RecLock("SE1", .F.)
				SE1->E1_BAIXA	:= Ctod("  /  /  ")
				SE1->E1_MOVIMEN := Ctod("  /  /  ")
				SE1->E1_JUROS	:= 0
				SE1->E1_MULTA	:= 0
				SE1->E1_DESCONT := 0
				SE1->( MsUnlock() )
			EndIf
			LOOP
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se pode efetuar a baixa do titulo, pois nao e possivel efetuar o estorno    |
		//| se a filial do SE5 nao for a filial corrente.										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRecFilial .AND. Len(aBaixaSE5) > 0
	 		If !LJXBXSE5VL(aBaixa , 1, aBaixaSE5[nOpBaixa][9] )			// Pesquisa se pode fazer o cancelamento Filial do VL = xFilial("SE5")			 	
	 			Return Nil
	 		EndIf
		EndIf
		
		If lChkslv .AND. Len(aBaixaSE5) > 0
			DbSelectArea("SE5")
			DbSetOrder(7)
			If DbSeek(xFilial("SE5")+aBaixaSE5[nOpBaixa][1]+Substr(aBaixaSE5[nOpBaixa][2],1,nTamSE5Num)+aBaixaSE5[nOpBaixa][3]+;
				aBaixaSE5[nOpBaixa][4]+aBaixaSE5[nOpBaixa][5]+aBaixaSE5[nOpBaixa][6]+aBaixaSE5[nOpBaixa][9])
				//Verifique se título vinculado ao lote não foi processado para estornar o TEF, pois o estorno do TEF é por lote de recebimento
				cMsgErro := ""
				If (nPosLtMDM := aScan(aLotesMDM, { |l| l[1] == SE1->E1_FILIAL .AND. l[2] == SE1->E1_PREFIXO	 .AND. l[3] == SE1->E1_NUM	 .and. l[4] == SE1->E1_PARCELA .AND. l[5] ==  SE1->E1_TIPO })  ) = 0
					lSemErro 	:= LJXGrvSLV( "C", Nil,aBaixa[1][2], aListTit, nX, lUsaTef, @cMsgErro )
					LjGrvLog( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "LjRecCancBx - retorno da validação/cancelamento TEF [ "+cMsgErro + "]", lSemErro)
	
					If !lSemErro
						cErros   += SE1->E1_PREFIXO	+ "-" 		+ SE1->E1_NUM 	+ "/" + ;
									SE1->E1_PARCELA	+ STR0093 	+ SE1->E1_TIPO 	+ CRLF + CRLF + STR0197 + cMsgErro + "]" //" Mensagem ["
						Return Nil
					EndIf
				EndIf
			EndIf
        EndIf
        
        aBxSE5Bkp := aClone(aBaixaSE5)
        If lAliasMDM .AND. lAliasMDN
        	MDM->(DbSetOrder(1))//MDM_FILIAL+MDM_BXFILI+MDM_PREFIX+MDM_NUM+MDM_PARCEL+MDM_TIPO+MDM_SEQ+MDM_LOTE  
        	If MDM->(DBSeek( xFilial("MDM") + aBaixa[1][2] + aBaixaSE5[nOpBaixa][1] + Substr(aBaixaSE5[nOpBaixa][2],1,nTamSE5Num) + aBaixaSE5[nOpBaixa][3] + aBaixaSE5[nOpBaixa][4] + aBaixaSE5[nOpBaixa][9] ))
	        	cMDMLote	:= MDM->MDM_LOTE
				cMDMPrfNum	:= MDM->(MDM_PREFIX + MDM_NUM)
	        	lRetGrvMDX  := LjxGrvMDX(	cMDMOper				, NIL		, NIL, NIL,;
	        				NIL						, NIL		, NIL, NIL,;
	        				NIL			, NIL		, NIL, NIL,;
	        				NIL			, cMDMLote	)

				If lRetGrvMDX
					MDM->( DbSetOrder(2) )
					MDM->( DBSeek( xFilial("MDM") + cMDMLote ) )
					While !MDM->( EOF() ) .AND. MDM->MDM_LOTE == cMDMLote
					
						If MDM->(aScan(aLotesMDM, { |l| l[1] == MDM_BXFILI .AND. l[2] == MDM_PREFIX .AND. l[3] == MDM_NUM .and. l[4] == MDM_PARCEL .AND. l[5] ==  MDM_TIPO .and. l[6] == MDM_SEQ }) )  = 0
							MDM->( aAdd( aLotesMDM, { MDM_BXFILI, MDM_PREFIX, MDM_NUM, MDM_PARCEL, MDM_TIPO, MDM_SEQ, cMDMLote}) )
						EndIf
						If cPaisLoc == "ARG"
							cOrdRec := aBaixaSE5[nOpBaixa][27]
							cSerRec := aBaixaSE5[nOpBaixa][28]
							nPosTit := aScan( aBaixaSE5, { |x| x[9] == MDM->MDM_SEQ .AND. x[25] == "BA" .AND. cOrdRec == x[27] .AND. cSerRec == x[28] } )
							If nPosTit > 0
								nValorTot += aBaixaSE5[nPosTit][8]
								aAreaSE5 := SE5->( GetArea() )
								MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nPosTit )
								RestArea( aAreaSE5 )
								aBaixaSE5 := {}
								aBaixaTit := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
															SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
															SE1->E1_LOJA						,NIL				,NIL			,NIL,;
															NIL									,.T.	)
							EndIf
						Else

							For nY := 1 To Len(aBaixaSE5)
								If ( aBaixaSE5[nY][1] == MDM->MDM_PREFIX .AND. Substr(aBaixaSE5[nY][2],1,nTamSE5Num) == MDM->MDM_NUM .AND. aBaixaSE5[nY][3] == MDM->MDM_PARCEL .AND.;
										aBaixaSE5[nY][4] == MDM->MDM_TIPO .AND. aBaixaSE5[nY][9] == MDM->MDM_SEQ .AND.;
										( ( aBaixaSE5[nY][25] $ "BA" .AND. !LjxDMoney( "SE5", aBaixaSE5[nY][24], aBaixaSE5[nY][26] ) ) ) )
									MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nY )
									nValorTot  += aBaixaSE5[nY][8]
									If (lGestao .AND. !lSE1Exc) .AND. (SE1->E1_SALDO == SE1->E1_VALOR)	//Caso totalmente estornado ao utilizar gestão de empresas e tabela SE1 não exclusiva, evitando loops
										Exit
									EndIf
								EndIf
							Next nY
						EndIf
						MDM->( DBSkip() )
					End
					Aadd(aTitEstorn, Alltrim(aTitulo[nx][2]) + " - " + Alltrim(aTitulo[nx][3]) + " - " + Alltrim(aTitulo[nx][4]) + " - " + DtoC(aTitulo[nx][5]) + " - " + Str(aTitulo[nx][6],10,2))									
				Else
					Aadd(aTitBaixad, Alltrim(aTitulo[nx][2]) + " - " + Alltrim(aTitulo[nx][3]) + " - " + Alltrim(aTitulo[nx][4]) + " - " + DtoC(aTitulo[nx][5]) + " - " + Str(aTitulo[nx][6],10,2))
				EndIf	
			Else
				If cPaisLoc == "ARG"
					cOrdRec := aBaixaSE5[nOpBaixa][27]
					cSerRec := aBaixaSE5[nOpBaixa][28]
					cParcRec:= aBaixaSE5[nOpBaixa][3]
					cNumRec := aBaixaSE5[nOpBaixa][2]
					cSeqRec := aBaixaSE5[nOpBaixa][9]
					SE5->( DbSetOrder(8) )
					SE5->( DbSeek( xFilial("SE5") + cOrdRec + cSerRec ) )
					While !SE5->( EOF() ) .AND. SE5->E5_ORDREC == cOrdRec .AND. SE5->E5_SERREC == cSerRec
						If SE5->E5_TIPODOC == "BA"
							nPosTit := aScan( aBaixaSE5, { |x| x[9] == SE5->E5_SEQ .AND. x[25] == "BA" .AND. cOrdRec == x[27] .AND. cSerRec == x[28] } )
							If nPosTit > 0
								nValorTot += aBaixaSE5[nPosTit][8]
								aAreaSE5 := SE5->( GetArea() )
								MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nPosTit )
								RestArea( aAreaSE5 )
								aBaixaSE5 := {}
								aBaixaTit := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
															SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
															SE1->E1_LOJA						,NIL				,NIL			,NIL,;
															NIL									,.T.	)
							EndIf
						EndIf
						SE5->( DBSkip() )
					End
				Else
					MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nOpBaixa )
					nValorTot  += aBaixaSE5[nOpBaixa][8]
				EndIf
			EndIf
        Else
        	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa o Cancelamento da Baixa do Titulo                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nOpBaixa )
			If Len(aBaixaSE5) > 0
				nValorTot  += aBaixaSE5[nOpBaixa][8]
			EndIf
        EndIf
        aBaixaSE5 := aClone(aBxSE5Bkp)
        aSe5Est := aClone(aBaixaSE5) //utilizado para controlar o estorno no totvs pdv
        nEstTroco := 0
       	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alteracao necessaria para correcao do Saldo do Titulo,pois o fina070() atualiza o saldo  ³
		//³ com o valor do troco (somente para dinheiro) e eh necessario ajustar esse valor			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAliasMDM .AND. lAliasMDN .AND. lRetGrvMDX
			If (((nModulo == 12 .OR. nModulo == 23) .OR. (nModulo <> 23 .AND. LJModNFis()) .OR. FunName()$"RPC") .AND. lTroco .AND. cPaisLoc == "BRA")			
				nValTroco := ValTroco(aBaixa[2][2],aBaixa[3][2],aBaixa[4][2],aBaixa[5][2],aBaixa[6][2],aBaixa[7][2],aBaixaSE5[nOpBaixa][9],@nEstTroco)
				// Garante que esteja posicionado no registro correto
				DbSelectArea("SE1")
				DbGoto(aTitulo[nX][TIT_RECN])
				If nValTroco > 0
					Reclock("SE1",.F.)
					SE1->E1_SALDO := SE1->E1_SALDO - nValTroco
					MsUnLock()
				EndIf
			EndIf
		EndIf

		If lMsErroAuto
			lSemErro := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| "  Tipo: "   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cErros   += SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+STR0093+SE1->E1_TIPO+CRLF
			DisarmTransaction()
			LjGrvLog("Recebimento_Titulo", "LjRecCancBx - DisarmTransaction")
			MostraErro()
		Else
			If lRetGrvMDX
				aAreaSE1 := SE1->(GetArea())
				DBSelectArea("SE1")
				DbSetOrder(1)
				
				//Estorno do valor de acrescimo
				Dbseek( aBaixa[1][2] + aBaixa[2][2] + aBaixa[3][2] + aBaixa[4][2] + aBaixa[5][2] )
				
				If SE1->(Found()) .AND. SE1->E1_SDACRES > 0  .AND.  ( SE1->E1_SALDO  == SE1->E1_VALOR + SE1->E1_SDACRES)
					Reclock("SE1", .F.)
					SE1->E1_SALDO -= SE1->E1_SDACRES
					SE1->( MsUnlock() )
				EndIf
				
				If Dbseek( aBaixa[1][2] + aBaixa[2][2] + aBaixa[3][2] + aBaixa[4][2] + aBaixa[5][2] ) .AND. !lEstParc
					If SE1->E1_SALDO >= SE1->E1_VALOR .Or. (Len(aBxTit) == 1 .AND. cLjOpEst != "3") //Se Saldo for maior ou igual ao valor do titulo ou foi estornado o titulo por completo, zera os campos de multa, juros, desconto.
						Reclock("SE1", .F.)
						SE1->E1_BAIXA      := Ctod("  /  /  ")
						SE1->E1_MOVIMEN    := Ctod("  /  /  ")
						SE1->E1_JUROS      := 0
						SE1->E1_MULTA      := 0		
						SE1->E1_SALDO	   := SE1->E1_VALOR				
						SE1->( MsUnlock() )
					EndIf
				EndIf
				RestArea(aAreaSE1)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Efetua o estorno da baixa, foi criada esta rotina pois o FINA070³
				//³nao estorna o tilulo na filial de origem quando o recebimento do³
				//³titulo foi feito em uma filial diferente da que o gerou.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					If lRecFilial .AND. lAliasMDM .AND. lAliasMDN
						MDM->(DbSetOrder(2))
						If !Empty(cMDMLote) .AND. MDM->(DBSeek( xFilial("MDM") + cMDMLote ))
							While !MDM->(EOF()) .AND. MDM->MDM_LOTE == cMDMLote						  
								If MDM->MDM_PARCEL == aBaixa[4][2] .AND. MDM->(MDM_PREFIX + MDM_NUM) == cMDMPrfNum
									LJXBXSE5VL(aBaixa, 2, MDM->MDM_SEQ )
								EndIf
								MDM->(DBSkip())
							End
						Else
							If cPaisLoc == "ARG"
								SE5->( DbSetOrder(8) )
								SE5->( DbSeek( xFilial("SE5") + cOrdRec + cSerRec ) )
								While !SE5->( EOF() ) .AND. SE5->E5_ORDREC == cOrdRec .AND. SE5->E5_SERREC == cSerRec
									If SE5->E5_TIPODOC == "BA"
										aAreaSE5 := SE5->( GetArea() )
										LJXBXSE5VL(aBaixa, 2, SE5->E5_SEQ )
										RestArea( aAreaSE5 )
									EndIf
									SE5->( DBSkip() )
								End
							Else
								LJXBXSE5VL(aBaixa, 2, aBaixaSE5[nOpBaixa][9] )
							EndIf
						EndIf
					ElseIf Len(aBaixaSE5) > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executa o Cancelamento da Baixa do Titulo                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						LJXBXSE5VL(aBaixa, 2, aBaixaSE5[nOpBaixa][9] )
					EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Preenche o array aDadosEst com os dados dos recebimentos estornados ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SE5")
				DbSetOrder(7)
				If Len(aBaixaSE5) > 0
					DbSeek(xFilial("SE5")+aBaixaSE5[nOpBaixa][1]+Substr(aBaixaSE5[nOpBaixa][2],1,nTamSE5Num)+aBaixaSE5[nOpBaixa][3]+;
						aBaixaSE5[nOpBaixa][4]+aBaixaSE5[nOpBaixa][5]+aBaixaSE5[nOpBaixa][6]+aBaixaSE5[nOpBaixa][9])
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|     Filial              Prefixo                                Numero                            |
				//|        Parcela                   Tipo                      Cliente                   Loja        |
				//|     Sequencia                                                                                    |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aBaixaSE5) > 0
					While !Eof() 														.AND. ;
						xFilial("SE5")                             	== SE5->E5_FILIAL 	.AND. ;
						aBaixaSE5[nOpBaixa][1]                     	== SE5->E5_PREFIXO	.AND. ;
						Substr(aBaixaSE5[nOpBaixa][2],1,nTamSE5Num) == SE5->E5_NUMERO 	.AND. ;
						aBaixaSE5[nOpBaixa][3]                     	== SE5->E5_PARCELA	.AND. ;
						aBaixaSE5[nOpBaixa][4]                     	== SE5->E5_TIPO   	.AND. ;
						aBaixaSE5[nOpBaixa][5] 			    		== SE5->E5_CLIFOR  	.AND. ;
						aBaixaSE5[nOpBaixa][6]                     	== SE5->E5_LOJA   	.AND. ;
						aBaixaSE5[nOpBaixa][9]                     	== SE5->E5_SEQ

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o titulo foi estornado por um caixa diferente do caixa que o   ³
						//³baixou, o sistema tem que corrigir o banco. A funcao FINA070 cria ³
						//³o estorno para o banco que o baixou, quando deveria cria-lo para o³
						//³caixa local.                                                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SE5->E5_TIPODOC == "ES" .AND. SE5->E5_BANCO <> cNumCaixa
							AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dDataBase, SE5->E5_VALOR, "+")
							RecLock("SE5", .F.)
							REPLACE SE5->E5_BANCO WITH cNumCaixa
							MsUnLock()
							AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dDataBase, SE5->E5_VALOR, "-")
						Endif

						If !lFoundSE5 .AND. SE5->E5_TIPODOC == "VL"
							AADD(aDadosEst, {SE5->E5_PREFIXO ,;           //1.Prefixo
											SE5->E5_NUMERO  ,;           //2.Numero
											SE5->E5_PARCELA ,;           //3.Parcela
											SE5->E5_TIPO    ,;           //4.Tipo
											SE5->E5_CLIFOR  ,;           //5.Codigo do cliente
											SE5->E5_LOJA    ,;           //6.Loja do cliente
											SE5->E5_SEQ     ,;           //7.Sequencia de baixa
											SE5->E5_VALOR   ,;           //8.Valor da baixa
											SE5->E5_MOEDA   ,;           //9.Forma de recebimento
											SE5->E5_VLJUROS ,;           //10.Juros
											SE5->E5_VLMULTA ,;           //11.Multa
											SE5->E5_VLDESCO })           //12.Desconto

							lFoundSE5 := .T.
						Endif

						DbSkip()
					End
				EndIf
			Endif
		
            If nEstTroco > 0 .AND. lRetGrvMDX
                LJEstTroco(nEstTroco,1)
            EndIf
		Endif
	Endif
Next nX
aTitDelSE5 := {}

If Len(aTitBaixad) > 0
	cTextBaix := STR0220 + CRLF + CRLF				//   "Estorno não Permitido para o(s) seguinte(s) Título(s) já Baixado(s):"
	For nX := 1 to Len(aTitBaixad)
		cTextBaix += aTitBaixad[nX] + CRLF		
	Next

	MsgInfo( cTextBaix, STR0221)					// "Títulos não Estornados"

	If Len(aTitEstorn) > 0
		cTextEston += STR0222 + CRLF + CRLF   		// "Título(s) Estornado(s) com Sucesso: "
		For nX := 1 to Len(aTitEstorn)
			cTextEston += aTitEstorn[nX] + CRLF		
		Next

		MsgInfo( cTextEston, STR0223)    			// "Títulos Estornados"

	EndIf

Endif

//Restaura a variavel private aTotais, necessario pois Fina070 possui variavel com mesmo nome causando erro
//Acontece quando LP 527 esta habilitada na contabilizacao do estorno
//Esta variavel nao deve ser alterada no estorno de titulo, assim recupera valor original
If ValType(aTotaisBkp) <> NIL
	aTotais := aClone(aTotaisBkp)
Endif

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LjRecEdBt ³ Autor ³ Fernando Machima      ³ Data ³22/02/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Acao ao selecionar o botao Editar							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³LjRecEdBt()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRecEdBt()

Local lLjRecEdit  := ExistBlock("LJRECEDIT")	// Controla se o PE LJRECEDIT existe
Local xRet										// Retorno do PE LJRECEDIT
Local lRet        := .F.						// Verifica se retornou Verdadeiro em alguma das posicos da Array


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o retorno do PE eh um array e em caso positivo³
//³se o retorno for .T. para as posicoes abaixo, permite a   ³
//³edicao do campo:                                          ³
//³xRet[1] -> Multa, xRet[2] -> Juros            			 ³
//³xRet[3] -> Desconto, xRet[4] -> Valor Recebido			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lLjRecEdit
   xRet := ExecBlock("LJRECEDIT",.F.,.F.)
Endif

If ( ValType(xRet) == "L" .AND. xRet ) .OR. ValType(xRet) <> "A"
   oBtnEdit:Disable()
   oBtnAtu:Enable()
   oMulta:Enable()
   oMulta:SetFocus()
   oJuros:Enable()
   oDescont:Enable()
   oValRec:Enable()
Elseif ( ValType(xRet) == "A" ) .AND. Len(xRet) == 4
	If xRet[1]
		oMulta:Enable()
   		oMulta:SetFocus()
   		lRet := .T.
   	Endif
   	If xRet[2]
   		oJuros:Enable()
   		oJuros:SetFocus()
   		lRet := .T.
   	Endif
   	If xRet[3]
   		oDescont:Enable()
   		oDescont:SetFocus()
   		lRet := .T.
   	Endif
   	If xRet[4]
   		oValRec:Enable()
   		oValRec:SetFocus()
   		lRet := .T.
   	Endif
   	If lRet
	   oBtnEdit:Disable()
	   oBtnAtu:Enable()
   	Endif
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LjRecVldCl³ Autor ³ Fernando Machima      ³ Data ³09/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Busca o CPF/CNPJ do cliente desejado						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³LjRecVldCli(ExpC1, ExpC2, ExpC3, ExpL4, ExpC5)              ³±±
±±³			 ³ExpC1 - Codigo do cliente									  ³±±
±±³			 ³ExpC2 - Loja do cliente									  ³±±
±±³			 ³ExpC3 - CPF/CNPJ      									  ³±±
±±³			 ³ExpL4 - Busca o CPF/CNPJ?									  ³±±
±±³			 ³ExpC5 - CPF/CNPJ auxiliar									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRecVldCli(	cCodCli,	cLojCli,	cCPF,	lPesqCPF,;
								cCPFTemp )

Local nTamMA6_NUM  := TamSx3("MA6_NUM")[1]     // Tamanho do campo MA6_NUM
Local nTamA1_COD   := TamSx3("A1_COD")[1]      // Tamanho do campo A1_COD
Local nTamA1_LOJA  := TamSx3("A1_LOJA")[1]     // Tamanho do campo A1_LOJA
Local nTamA1_CGC   := TamSx3("A1_CGC")[1]      // Tamanho do campo A1_CGC

If lPesqCPF
	If !Empty(cCodCli) .AND. !Empty(cLojCli)
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+ cCodCli + cLojCli ))
			cCPF     := SA1->A1_CGC
			cCPFTemp := SA1->A1_CGC
			cCartao  := LjRecSeekCart(cCodCli , cLojCli)
		Else
			cCPF     := Space(nTamA1_CGC)
			cCPFTemp := Space(nTamA1_CGC)
			cCartao  := Space(nTamMA6_NUM)
		Endif
	Else
		If Empty(cCodCli) .AND. Empty(cLojCli)
		    cCartao  := Space(nTamMA6_NUM)
			cCPF     := Space(nTamA1_CGC)
			cCPFTemp := Space(nTamA1_CGC)
		ElseIf Empty(cCodCli) .AND. !Empty(cLojCli)
		    cLojCli  := Space(nTamA1_LOJA)
		    cCartao  := Space(nTamMA6_NUM)
			cCPF     := Space(nTamA1_CGC)
			cCPFTemp := Space(nTamA1_CGC)
		ElseIf !Empty(cCodCli) .AND. Empty(cLojCli)
		    cCartao  := Space(nTamMA6_NUM)
			cCPF     := Space(nTamA1_CGC)
			cCPFTemp := Space(nTamA1_CGC)
		Endif
	Endif
ElseIf !Empty(cCPF)
	  DbSelectArea("SA1")
	  SA1->(DbSetOrder(3))
	  If SA1->(DbSeek(xFilial("SA1")+ cCPF))
	     cCodCli  := SA1->A1_COD
	     cLojCli  := SA1->A1_LOJA
		 cCartao  := LjRecSeekCart(cCodCli , cLojCli)
	  Else
	     cCodCli  := Space(nTamA1_COD)
	     cLojCli  := Space(nTamA1_LOJA)
	     cCartao  := Space(nTamMA6_NUM)
	  Endif
Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LjRecEntra³ Autor ³ Danilo Calil          ³ Data ³22/02/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Trata o retorno do Ponto de Entrada LJRECSELE ou			  ³±±
±±³          ³da funcao LjxRecSel                               		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ LOJXREC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array com as parcelas utilizadas para a baixa dos   ³±±
±±³			 ³titulos													  ³±±
±±³			 ³ExpA2 - Objeto oTitulo                                      ³±±
±±³			 ³ExpL3 - Variavel logica                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpX1 - Pode ser logico ou arrayilizadas para a baixa dos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRetEntra( aTitulo, oTitulo, lLJDesBAlt )

Local xRet										//Retorno do Ponto de Entrda LJRECSELE ou da funcao LjxRecSele

If ExistBlock("LJRECSELE")
	xRet := ExecBlock("LJRECSELE",.F.,.F.,{aTitulo,oTitulo,cOper})
	If ValType(xRet) == "L"
		If xRet
			LJRecDblClick(lLJDesBAlt)
		Else
			xRet := NIL
		EndIf

	ElseIf ValType(xRet) == "A"
		aTitulo := aClone(xRet)

		If Len(aTitulo) > 0
			LJRecDblArray()
			xRet := .T.
		Else
			xRet := NIL
		EndIf
	EndIf
ElseIf  ExistFunc("LjxRecSele")  .AND. !Empty(aTitulo[oTitulo:nAt][TIT_CONT])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se trabalhar com o conceito de acrescimo separado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xRet := LjxRecSele(aTitulo,oTitulo,cOper)
	If ValType(xRet) == "L"
		If xRet
			LJRecDblClick(lLJDesBAlt)
		Else
			xRet := NIL
		EndIf

	ElseIf ValType(xRet) == "A"
		aTitulo := aClone(xRet)

		If Len(aTitulo) > 0
			LJRecDblArray()
			xRet := .T.
		Else
			xRet := NIL
		EndIf
	EndIf
Else
	LJRecDblClick(lLJDesBAlt)
EndIf

Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRecDblClºAutor  ³Danilo Calil		 º Data ³ 			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Acao ao dar duplo clique no list box dos titulos se o LjRet-º±±
±±º          ³Entra retornar um Array. Criado por necessidade do cliente  º±±
±±º          ³Dadalto.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXREC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJRecDblArray()

nTotal := 0											//Total da venda

AEval(aTitulo, {|x| If(x[TIT_SELE],nTotal+=IIF(cOper == "2", x[TIT_VLIQ] ,x[TIT_VALO]+x[TIT_MULT]+x[TIT_JURO]-x[TIT_DESC]+x[TIT_ACRS]),) })

oTotal:Refresh()

If aTitulo[oTitulo:nAt][TIT_SELE]
	oBtnEdit:Enable()
	oBtnAtu:Disable()
Else
	oBtnEdit:Disable()
	oBtnAtu:Disable()
Endif

oTitulo:Refresh()

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LjRecSeekCart³ Autor ³ Fernando Machima      ³ Data ³21/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o numero de um cartao ativo do cliente	 	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ LOJXREC                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do cliente									     ³±±
±±³			 ³ExpC2 - Loja do cliente 									     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 - Numero do cartao ativo 							     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjRecSeekCart( cCodCli, cLojCli )

Local nTamMA6_NUM	:= TamSx3("MA6_NUM")[1]     // Tamanho do campo MA6_NUM
Local cNumCart		:= Space(nTamMA6_NUM)       // Numero do cartao do cliente
Local lAchouMA6		:= .F.                      // Controla se encontrou o numero do cartao
Local aArea			:= GetArea()                // Area atual
Local cIndPesq		:= ""
Local cIndMA6		:= ""

cIndPesq:= "MA6->MA6_FILIAL + MA6->MA6_CODCLI + MA6->MA6_LOJA"
cIndMA6	:= xFilial("MA6")+ cCodCli + cLojCli

DbSelectArea("MA6")
MA6->(DbSetOrder(2))
MA6->(DbSeek(cIndMA6))
While MA6->(!Eof()) .AND. (cIndMA6 == &(cIndPesq)) .AND. !lAchouMA6

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Validar se cartao ativo           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If MA6->MA6_SITUA <> "1"
      MA6->(DbSkip())
	  Loop
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Desconsiderar cartao do dependente³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If !Empty(MA6->MA6_CODDEP)
      MA6->(DbSkip())
	  Loop
   Endif

   lAchouMA6 := .T.
   cNumCart  := MA6->MA6_NUM
End

RestArea(aArea)

Return cNumCart
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRecTef     ºAutor  ºThiago Honorato     ºData  º 26/06/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Verifica se esta' executando a rotina de Recebimento de Titulosº±±
±±º          ³e o pagamento realizado via TEF.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ LOJXTEF                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                            		   						     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1 - Executa rotina de recebimento (.T. ou .F.)		     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRecTef()
Local lRet := .F. //retorno da funcao

If lRecebTit
	lRet := .T.
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJXGrvSLV ºAutor  ³Marcio Lopes        º Data ³  08/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava informacaoo no arquivo SLV, no momento da baixa do   º±±
±±º          ³ titulo. Atualiza o arquivo SLV no momento do cancelamento  º±±
±±º			 ³ da transacao TEF. 			                              º±±
±±ºParametros³1.ExpC1 = "I" - Inclusao                                    º±±
±±º			 ³  	    "C" - Cancelamento da transacao                   º±±
±±º          ³2.ExpA1 = Contem as informacoes do arquivo SE5 para gravacaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1 - Retorna se localizou o titulo no SLV				  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJXGrvSLV( cFunc, aSE5Dados , cFilREc, aTitSel, nX, lEstTEF, cMsgErro, lJob, lVerCanTEF )

Local aTefTmp   	:= {}								   	//Array utilizada para pegar as informacoes do aTefTmp
Local cSeqTmp   	:= ""								   	//Utilizado para fazer cancelamento
Local nI        	:= 1								   	//Variavel do FOR
Local lRet      	:= .T.								   	//Retorno da Funcao
Local lConfirma 	:= .F.									//Controla se ao menos uma transacao TEF foi efetuada com Sucesso
Local nTamLvNum 	:= TamSx3("LV_NUMERO")[1]				// Tamanho de casas do LV_NUMERO
Local nTamLvPar 	:= TamSx3("LV_PARCELA")[1]				// Tamanho de casas do LV_PARCELA
Local lTefMult		:= SuperGetMV("MV_TEFMULT",.F.)			// Verfica se e multiplas
Local aDados    	:= {}
Local aRetCartBkp 	:= {}
Local lAppend 		:= .F.
Local cSeqOper    	:= ""									//Sequencia da operacao do SLV
Local cNsu			:= ""
Local nA			:= 1									//Variavel do Laço para cancelamento do TEF
Local cChvBaixa		:= "" 									//Chave da Baixa
Local aTefGrv		:= {} //Dados TEF a serem gravados
Local aPagtoCart	:= {}
Local cTpCanc 		:= ""
Local lAliasMDM		:= AliasIndic("MDM")  							// Verifica a existencia da tabela
Local lAliasMDN		:= AliasIndic("MDN")  							// Verifica a existencia da tabela
Local cMDMLote 		:= ""
Local nPos			:= 0
Local cTitAnt		:= "" //Titulo Anterior
Local lLjRecSlv     := ExistBlock("LJRECSLV") 	//Verifica se o PE LJRECSLV existe.
Local lLV_Bandeir   := SLV->( ColumnPos("LV_BANDEIR") ) > 0
Local lLV_RedeAut   := SLV->( ColumnPos("LV_REDEAUT") ) > 0
Local cMsgCanTrn 	:= ""
Local lUseTPD 		:= ExistFunc("LjUsePayHub") .And. LjUsePayHub() //Verifica se ambiente está configurado para uso do Totvs Pagamento Digital
Local aPagDig		:= {}
Local lLV_TRNID   	:= SLV->( ColumnPos("LV_TRNID") ) > 0
Local dDtCancTef	:= StoD(FwTimeUF(SM0->M0_ESTENT,,SuperGetMv("MV_HVERAO",.F.,.F.))[1])

Default cFilRec := nil
Default aTitSel := {}
Default nX := 0
Default cMsgErro := ""
Default lEstTEF := Type("lUsaTEF")="L" .AND. lUsaTEF
Default	lJob		:= .F.
Default lVerCanTEF	:= .F.

If Upper(cFunc) == "I"
	BEGIN TRANSACTION
	LjGrvLog("Recebimento_Titulo", "LJXGrvSLV - Begin Transaction")
	aSort(aSE5Dados,,,{|x,y|, x[16]<y[16]})
	SLV->(DbSetOrder(2) ) //LV_FILIAL + SLV_SEQOPER
	While nI <= Len(aSE5Dados)
		cNSU := aSE5Dados[nI, 16]
		
		While .T.
			cSeqOper := GetSXENum("SLV", "LV_SEQOPER")
			If __lSX8
				ConfirmSX8()
			EndIf
			If !SLV->(DbSeek(xFilial("SLV")+cSeqOper))
				Exit
			EndIf
		End
		
		While nI <= Len(aSE5Dados) .AND. cNSU == aSE5Dados[nI, 16]
			aSE5Dados[nI, 18] := cSeqOper
			++nI
		End
		
	End

	dbSelectArea("SLV")
	SLV->( dbSetOrder(1) ) //LV_FILIAL+LV_PREFIXO+LV_NUMERO+LV_PARCELA+LV_TIPO+LV_CLIENTE+LV_LOJA+LV_SEQ+LV_SEQOPER


	For nI := 1 To Len(aSE5Dados)
		
		lAppend := !SLV->( dbSeek(xFilial("SLV")+aSE5Dados[nI,1]+Substr(aSE5Dados[nI,2],1,nTamLvNum)+SubStr(aSE5Dados[nI,3],1,nTamLvPar)+;
		aSE5Dados[nI,4]+aSE5Dados[nI,7]+aSE5Dados[nI,8]+aSE5Dados[nI,5]+aSE5Dados[nI,18]))
		
		Reclock("SLV", lAppend)
		REPLACE LV_FILIAL 	WITH xFilial("SLV")
		REPLACE LV_PREFIXO	WITH aSE5Dados[nI, 1]
		REPLACE LV_NUMERO	WITH aSE5Dados[nI, 2]
		REPLACE LV_PARCELA	WITH aSE5Dados[nI, 3]
		REPLACE LV_TIPO		WITH aSE5Dados[nI, 4]
		REPLACE LV_SEQ		WITH aSE5Dados[nI, 5]
		REPLACE LV_FILORIG	WITH aSE5Dados[nI, 6]
		REPLACE LV_CLIENTE	WITH aSE5Dados[nI, 7]
		REPLACE LV_LOJA		WITH aSE5Dados[nI, 8]
		REPLACE LV_FORMA 	WITH aSE5Dados[nI, 9]
		REPLACE LV_VALOR 	WITH aSE5Dados[nI,10]
		REPLACE LV_DATATEF	WITH aSE5Dados[nI,11]
		REPLACE LV_HORATEF	WITH aSE5Dados[nI,12]
		REPLACE LV_DOCTEF	WITH aSE5Dados[nI,13]
		REPLACE LV_AUTORIZ	WITH aSE5Dados[nI,14]
		REPLACE LV_INSTITU	WITH aSE5Dados[nI,15]
		REPLACE LV_NSUTEF	WITH aSE5Dados[nI,16]
		REPLACE LV_TIPCART	WITH aSE5Dados[nI,17]
		REPLACE LV_SEQOPER	WITH aSE5Dados[nI,18]
		If lLV_BANDEIR .AND. Len(aSE5Dados[nI]) >= 24
			REPLACE LV_BANDEIR	WITH aSE5Dados[nI,23]
		EndIf
		If lLV_REDEAUT .AND. Len(aSE5Dados[nI]) >= 24
			REPLACE LV_REDEAUT	WITH aSE5Dados[nI,24]
		EndIf
		REPLACE LV_DATA		WITH dDataBase

		If lLV_TRNID .AND. Len(aSE5Dados[nI]) > 24
			REPLACE LV_TRNID	WITH aSE5Dados[nI,25]
			REPLACE LV_TRNPCID	WITH aSE5Dados[nI,26]
			REPLACE LV_TRNEXID	WITH aSE5Dados[nI,27]
		EndIf

		MsUnLock()
	Next nI
	SLV->(dbCommit())
	END TRANSACTION
	LjGrvLog("Recebimento_Titulo", "LJXGrvSLV - End Transaction")
Else
	DbSelectArea("SLV")
	SLV->(DbSetOrder(1) )     //LV_FILIAL+LV_PREFIXO+LV_NUMERO+LV_PARCELA+LV_TIPO+LV_CLIENTE+LV_LOJA+LV_SEQ


   If cFilRec <> nil .and. lAliasMDM .AND. lAliasMDN
    	MDM->(DbSetOrder(1))//MDM_FILIAL+MDM_BXFILI+MDM_PREFIX+MDM_NUM+MDM_PARCEL+MDM_TIPO+MDM_SEQ+MDM_LOTE 
    	
    	LjGrvLog("Recebimento_Titulo", "LJXGrvSLV - Chave ", xFilial("MDM") + cFilREc  + SE5->E5_PREFIXO  + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_SEQ) 
		If MDM->(DBSeek( xFilial("MDM") + cFilREc  + SE5->E5_PREFIXO  + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_SEQ ))
			cMDMLote := MDM->MDM_LOTE
			MDM->(DbSetOrder(2)) //MDM->MDM_FILIAL + MDM-MDM_LOTE
			MDM->(Dbseek(xFilial("MDM") + cMDMLote))
			
			LjGrvLog("Recebimento_Titulo", "LJXGrvSLV - Lote", cMDMLote)
			While !MDM->( EOF() ) .AND. MDM->MDM_LOTE == cMDMLote

				If MDM->MDM_ESTORN == "1"
					MDM->(DbSkip())
					Loop
				EndIf
							
				nPos := 0
				//Verifica no array de títulos se o mesmo foi selecionado e consta para Estorno
				If cTitAnt <> MDM->(MDM_BXFILI + MDM_PREFIX+ MDM_NUM +  MDM_PARCEL +  MDM_TIPO) 	
					If Len(aTitSel) > 0 .and. nX > 0 .AND. !MDM->(aTitSel[nX][TIT_FILI] == MDM_BXFILI .AND.  aTitSel[nX][TIT_PREF] == MDM_PREFIX  .AND. aTitSel[nX][TIT_NUME]  == MDM_NUM .AND. aTitSel[nX][TIT_PARC] ==  MDM_PARCEL  .AND. aTitSel[nX][TIT_TIPO] == MDM_TIPO  )
						If nX <  Len(aTitSel)
							nPos := MDM->(aScan(aTitSel, { |t| t[TIT_SELE] .and.  t[TIT_FILI] == MDM_BXFILI .AND.  t[TIT_PREF] == MDM_PREFIX  .AND. t[TIT_NUME]  == MDM_NUM .AND. t[TIT_PARC] ==  MDM_PARCEL  .AND. t[TIT_TIPO] == MDM_TIPO    }, nX + 1 )  ) 
						EndIf
						If nPos = 0
							cMsgErro += CRLF + MDM->(MDM_PREFIX	+ "-" 		+  MDM_NUM	+ "/" + ;
												MDM_PARCEL	+ STR0093 	+ MDM_TIPO) 	
						EndIf
					EndIf
					cTitAnt := 	MDM->(MDM_BXFILI + MDM_PREFIX+ MDM_NUM +  MDM_PARCEL +  MDM_TIPO)
				EndIf
				cChvBaixa	:= xFilial("SLV") + MDM->MDM_PREFIX	+ Left(MDM->MDM_NUM,nTamLvNum) + Left(MDM->MDM_PARCEL,nTamLvPar) + ;
								MDM->MDM_TIPO 	+ SE5->E5_CLIENTE	+ SE5->E5_LOJA	 + MDM->MDM_SEQ
				 			
				SLV->(DbSeek(cChvBaixa))
					
				While lEstTEF .AND. Empty(cMsgErro) .AND. SLV->(!Eof() .AND. LV_FILIAL+LV_PREFIXO+LV_NUMERO+LV_PARCELA+LV_TIPO+LV_CLIENTE+LV_LOJA+LV_SEQ	==  cChvBaixa )
					
					If Len(aDados) = 0 .OR. aScan(aDados, {|x| AllTrim(Upper(x[9] )) == AllTrim(SLV->LV_SEQOPER) }) = 0
						AAdd(aDados ,{ SLV->LV_FILIAL,;
						SLV->LV_PREFIXO,;
						SLV->LV_NUMERO,;
						SLV->LV_PARCELA,;
						SLV->LV_TIPO,;
						SLV->LV_CLIENTE,;
						SLV->LV_LOJA,;
						SLV->LV_SEQ,;
						SLV->LV_SEQOPER})
					EndIf
					SLV->(DbSkip()) 
				End
				MDM->(Dbskip(1))
			EndDo
		EndIf
	Else
		
		cChvBaixa	:= xFilial("SLV") + SE5->E5_PREFIXO 	+ Substr(SE5->E5_NUMERO,1,nTamLvNum) + SubStr(SE5->E5_PARCELA,1,nTamLvPar) + ;
				SE5->E5_TIPO 	+ SE5->E5_CLIENTE	+ SE5->E5_LOJA	 + SE5->E5_SEQ
		SLV->(DbSeek(cChvBaixa))
				
		While lEstTEF .AND. SLV->(!Eof() .AND. LV_FILIAL+LV_PREFIXO+LV_NUMERO+LV_PARCELA+LV_TIPO+LV_CLIENTE+LV_LOJA+LV_SEQ	==  cChvBaixa )
			
			If Len(aDados) = 0 .OR. aScan(aDados, {|x| AllTrim(Upper(x[9])) == AllTrim(SLV->LV_SEQOPER) }) = 0
				AAdd(aDados ,{ SLV->LV_FILIAL,;
				SLV->LV_PREFIXO,;
				SLV->LV_NUMERO,;
				SLV->LV_PARCELA,;
				SLV->LV_TIPO,;
				SLV->LV_CLIENTE,;
				SLV->LV_LOJA,;
				SLV->LV_SEQ,;
				SLV->LV_SEQOPER})
			EndIf
			SLV->(DbSkip()) 
		End
	EndIf
		
	If Empty(cMsgErro) 
		If lEstTEF
			SLV->(DbSetOrder(2) ) //LV_FILIAL + SLV_SEQOPER
			For nI := 1 to Len(aDados)
				cSeqTmp := aDados[nI][1]+ aDados[nI][9]
				If SLV->(DbSeek(cSeqTmp ))
					If Empty(SLV->LV_DOCCANC)

						If lUseTPD .And. AllTrim(SLV->LV_FORMA) $ _FORMAPGDG //Pagamento Digital
							cMsgCanTrn := "Confirma o Estorno da Transação de Pagamento Digital no valor de:" //"Confirma o Estorno da Transação de Pagamento Digital no valor de:"
						Else
							cMsgCanTrn := STR0108 //"Confirma o Estorno da Transação TEF no valor de:"
						EndIf
						cMsgCanTrn := cMsgCanTrn + Transform(SLV->LV_VALOR, "9,999.99") + CRLF + "NSU: " + SLV->LV_NSUTEF  +  " Doc:" + SLV->LV_DOCTEF+ "?"
						If !lVerCanTEF .And. (lJob .Or. MsgYesNo(cMsgCanTrn))

						/* Como o estorno da transação TEF no Front é executado no PDV devemos setar a varíavel lJob indicando que o processo é
						feito pelo WS, sendo assim, o cancelamento TEF foi iniciado pelo PDV e somente utilziamos o WS para atualizar o cancelamento na SLV.*/
							If lJob
								For nA := 1 To Len(aSE5Dados)
									While !Eof() .AND. xFilial("SLV") == SLV->LV_FILIAL .AND. cSeqTmp == SLV->LV_FILIAL+SLV->LV_SEQOPER
										Reclock("SLV", .F.)
										Replace SLV->LV_DOCCANC	WITH aSE5Dados[nA][20]
										Replace SLV->LV_HORCANC	WITH aSE5Dados[nA][21]
										Replace SLV->LV_DATCANC	WITH aSE5Dados[nA][22]
										MsUnLock()
										DbSkip()
									End
								Next nA
							Else

								If lUseTPD .And. AllTrim(SLV->LV_FORMA) $ _FORMAPGDG //Pagamento Digital
									aPagDig := {}
									Aadd(aPagDig, {} )
									nA := Len(aPagDig)
									Aadd(aPagDig[nA], Alltrim(SLV->LV_DOCTEF) ) 	//01-Número do DOCTEF
									Aadd(aPagDig[nA], SLV->LV_VALOR )				//02-Valor total da transação
									Aadd(aPagDig[nA], Alltrim(SLV->LV_TRNID	) ) 	//03-ID da Transação (Payment Hub)
									Aadd(aPagDig[nA], Alltrim(SLV->LV_TRNPCID) )	//04-ID Transação Processador (Payment Hub)
									Aadd(aPagDig[nA], Alltrim(SLV->LV_TRNEXID) )	//05-ID da Transação Externa (Payment Hub)
									Aadd(aPagDig[nA], SLV->LV_DATATEF )				//06-Data da Transação
									Aadd(aPagDig[nA], Alltrim(SLV->LV_FORMA) )		//07-Forma de pagamento
									Aadd(aPagDig[nA], "" )							//08-Id da forma de pagamento (Multi-TEF)
									Aadd(aPagDig[nA], Alltrim(SLV->LV_DOCCANC) )	//09-DOC Cancelamento da Transação
									Aadd(aPagDig[nA], Alltrim(SLV->LV_DATCANC) )	//10-Data Cancelamento da Transação
									Aadd(aPagDig[nA], Alltrim(SLV->LV_HORCANC) )	//11-Hora Cancelamento da Transação
									Aadd(aPagDig[nA], { SLV->(Recno()) } )			//12-Recnos da SLV referente a transação

									//Cancela transações de Pagamento Digital.
									If LjPDCanTrn(@aPagDig,2)
										lConfirma := .T.
									Else
										lRet  := .F.
									EndIf

								ElseIf cTipTEF $ TEF_CLISITEF
									aPagtoCart := {SLV->LV_DOCTEF,;
												SLV->LV_VALOR,;
												SLV->LV_DATATEF ,;
												SLV->LV_TIPCART,;
												"",;
												SLV->LV_NSUTEF,;
												0,;
												SLV->LV_AUTORIZ} 
												
									If AllTrim(SLV->LV_TIPCART) == "CC"
										cTpCanc := "CANCEL_CREDITO"
									ElseIf AllTrim(SLV->LV_TIPCART) == "CD"
										cTpCanc := "CANCEL_DEBITO"
									Else
										cTpCanc := "CANCEL_VENDA"
									EndIf							
									
									oTEF:Operacoes(cTpCanc, {} , , , , , , , , , ,aPagtoCart)
									lTefOk := oTef:lTefOk
									aRetCartBkp:=oTEF:ARETCARTAO
									If lTefOk
										oTEF:ImpCupTef()
										lTefOk	:= oTef:lTefOk
									EndIf

									If lTefOK
										IIf( !Empty(aRetCartBkp[1]:dDataCanRei), (dDtCancTef := aRetCartBkp[1]:dDataCanRei), (aRetCartBkp[1]:dDataCanRei := dDtCancTef) )

										While SLV->(!Eof() .AND. LV_FILIAL+LV_SEQOPER == cSeqTmp) 
											Reclock("SLV", .F.)
											Replace SLV->LV_DOCCANC	WITH aRetCartBkp[1]:CDOCCANREI
											Replace SLV->LV_HORCANC	WITH aRetCartBkp[1]:CHORATRANS
											Replace SLV->LV_DATCANC	WITH StrTran(DToC(dDtCancTef),"/","")
											SLV->(MsUnLock())
											SLV->(DbSkip())
										End
										lConfirma := .T.
									Else
										lRet  := .F.
									EndIf
									
								ElseIf	cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO
									aTefTmp := {}
									lTefOk	:= LOJA011T( .T., @aTefTmp, .T. )

									If lTefOK
										If Len(aTefTmp) > 0 .and. Len(aTefTmp[1]) > 6
											If lTEFMult
												If Len(aTefTmp[1][7]) > 0 
													aTefGrv := aClone(aTefTmp[1][7][1])
												EndIf
											Else
												aTefGrv := aClone(aTefTmp[1])
											EndIf
											If Len(aTefGrv) >= 12
												While SLV->(!Eof() .AND.  LV_FILIAL+LV_SEQOPER == cSeqTmp )
												
													Reclock("SLV", .F.)
				
													Replace SLV->LV_DOCCANC	WITH aTefGrv[6]
													Replace SLV->LV_HORCANC	WITH aTefGrv[7]
													Replace SLV->LV_DATCANC	WITH aTefGrv[12]
													SLV->(MsUnLock())
													
													SLV->(DbSkip())
												End
											EndIf
										EndIf
										lConfirma := .T.									
									Else
										lRet  := .F.
									EndIf
								EndIf
							Endif
						ElseIf lVerCanTEF
							lRet  := .T.	
						Else
							lRet  := .F.
						EndIf
					EndIf
				EndIf
			Next nI
		Else
			lRet := .T.
			lConfirma := .T.
		EndIf	
	Else
		lRet := .F.
		lConfirma := .F.
	EndIf

EndIf
If !lRet
	If lConfirma
		lRet := .T.
		// "O estorno do recebimento será feito porque, ao menos, uma operação de estorno TEF foi realizada."
		// "Utilize a rotina de Cancelamento Manual TEF para as demais transações."
		cMsgErro := STR0110 + CRLF + STR0111
		If !IsBlind()
			MSgAlert(cMsgErro)
			cMsgErro := ""
		EndIf
	Else
		If Empty(cMsgErro)
			If !IsBlind()
				lRet := MsgYesNo(STR0109) // "Nenhuma operação de Estorno TEF foi realizada. Confirma o estorno do recebimento mesmo assim?"
			Else
				lRet := .T.
			EndIf
		Else
			cMsgErro := STR0198 + ; //"O título a ser extornado está viculado a outros títulos que não foram selecionados. Selecione todos para realizar o estorno. " 
						cMsgErro 
			If !IsBlind()	
				MsgStop(cMsgErro)
				cMsgErro := ""
			EndIf
		EndIf
	EndIf
EndIf

If lLjRecSlv			//Ponto de Entrada LJRECSLV
	LjGrvLog("RECEBIMENTO","Ponto de Entrada LJRECSLV - Parâmetros", {aSE5Dados,lRet,lConfirma})
	ExecBlock("LJRECSLV",.F.,.F.,{aSE5Dados,lRet,lConfirma})
	LjGrvLog("RECEBIMENTO","Retorno do Ponto de Entrada LJRECSLV")
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJXVERTEF ºAutor  ³Marcio Lopes        º Data ³  30/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a transacao eh TEF, e retorna para variavel    º±±
±±º          ³ lCartao.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1 = Controla se valida se imprime ou nao a consulta de º±±
±±º			 ³ cheque 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL2 = Variavel utilizada para dizer se tem operacao TEF. º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJXVERTEF(lVldImpres, aParcPgto)

Local nI   := 0	    	//Variavel do FOR
Local lRet := .F.      //Retorno da funcao
Local aPagamentos :={}

DEFAULT aParcPgto  := {}

If FunName() == "FRTA271"
	aPagamentos	:= aClone(aParcPgto)
Else
	aPagamentos	:= aClone(aPgtos)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esta utilizando a variavel aPgtos private (venda³
//³assistida) ou enviada por parametro (front loja)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ++nI <= Len(aPagamentos) .AND. !lRet
   //Com a utilização da DLL ainda não existe a possibilidade do controle de milhas com o cartão CCS da EMS
	If cTipTef $ TEF_CLISITEF
       If AllTrim(aPagamentos[nI][3]) $ _FORMATEF    .OR. (AllTrim(aPagamentos[nI][3]) == AllTrim(MVCHEQUE) .AND. ;
		  At("S",LjGetStation("TEFCONS")) <> 0  .AND. IIf(lVldImpres,At("S",LjGetStation("IMPTEFC")) <> 0,.T.))
		   	 lRet := .T.
	   Endif
	ElseIf AllTrim(cTipTef) <> "1"		//Quando cTipTef = "1" não utiliza TEF
       If AllTrim(aPagamentos[nI][3]) $ _FORMATEF .OR. AllTrim(aPagamentos[nI][3]) == "MH" .OR. ;
	     (AllTrim(aPagamentos[nI][3]) == AllTrim(MVCHEQUE) .AND. (SuperGetMV("MV_INTEEMS") .OR. ;
	      At("S",LjGetStation("TEFCONS")) <> 0) .AND. IIf(lVldImpres,At("S",LjGetStation("IMPTEFC")) <> 0,.T.))
			 lRet := .T.
	   Endif
	EndIf
End

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRcAtuObjºAutor  ³Danilo Calil        º Data ³  10/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza os objetos de totais                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 = Valor do acrescimo (Multas, Juros ou Desconto).    º±±
±±º			 ³ ExpC2 = Que tipo ("M" Multa, "J" Juros, "D" Desconto       º±±
±±º			 ³ ExpN3 = Valor do Recebimento digitado				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpN4 = Valor atualizado do Recebimento                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRcAtuObj( nVlTp, cOpTp, nValRec )

Local nRet 		:= 0		// Retorno da funcao
Local nPesq 	:= 0		// Retorno de pesquisa no aValores
Local nX 		:= 0		// Contador de For
Local lAlteracao:= .F.    	// Se altera o valor de recebimento
Local nOp		:= 1		// Se vai somar ou subtrair

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se inclui um novo valor ou se ja existe³
//³no aValores (atualiza)                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := AScan( aValores, {|x| x[2] == cOpTp} )

If nPos > 0
	aValores[nPos][1] := nVlTp
Else
	Aadd(aValores,{nVlTp,cOpTp})
EndIf

If Len(aValores) > 0
	For nX := 1 To Len(aValores)
		If aValores[nX][2] == "J" .OR. aValores[nX][2] == "M"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Juros ou Multa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPesq += aValores[nX][1]
		Else
			//ÚÄÄÄÄÄÄÄÄ¿
			//³Desconto³
			//ÀÄÄÄÄÄÄÄÄÙ
			nPesq -= aValores[nX][1]
		EndIf
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o valor de encargos seja diferente do       ³
//³ultimo informado, seta a lAlteracao para True.   ³
//³Tambem define que operacao eh (soma ou subtracao)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPesq <> nCloneRec
	lAlteracao := .T.
	If nPesq < nCloneRec
		nOp := -1
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se altera o valor de recebimento, existe³
//³tratamento para quando                           ³
//³- Baixa Integral                                 ³
//³- Baixa Integral com Multa, Juros ou Desconto    ³
//³- Baixa Parcial                                  ³
//³- Baixa Parcial com Multa, Juros ou Desconto     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAlteracao .AND. nValRec > 0
	nRet := Abs(nValRec + ((Abs(nPesq - nCloneRec)) * nOp))
Else
	If (nValRec > 0) .AND. (nValRec <> nPesq + aTitulo[oTitulo:nAt][TIT_VALO])
		nRet := nValRec
	Else
		nRet := nPesq + aTitulo[oTitulo:nAt][TIT_VALO]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o ultimo valor dos encargos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCloneRec := nPesq

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjAtuArrayºAutor  ³Marcos R. Andrade   º Data ³  19/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializa o array a Valores                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 = "M" Multa                                          º±±
±±º			 ³ ExpN2 = "J" Multa                                          º±±
±±º			 ³ ExpN3 = "D" Desconto                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³  Nil                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjAtuArray(nMulta, nJuros, nDescont, nVlrTitulo)
Default nVlrTitulo := 0

nCloneRec	:= nMulta + nJuros - nDescont
aValores 	:= {}

Aadd(aValores,{nMulta,   "M", nVlrTitulo})
Aadd(aValores,{nJuros,   "J", nVlrTitulo})
Aadd(aValores,{nDescont, "D", nVlrTitulo})

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjPicCPFCNPJºAutor  ³Thiago Honorato     º Data ³  19/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera a PICTURE do campo apos a digitacao de CPF / CNPJ     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 = Numeracao do CPF / CNPJ digitado	                    º±±
±±º          ³ ExpC2 = CPF/CNPJ auxiliar 				                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³  .T.                         	                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamada   ³  Funcoes: LJReceb() / LJRecPesq()                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjPicCPFCNPJ( cCPF, cCPFTemp )
If !Empty(cCPFTemp) .AND. cPaisloc <> "MEX"
	cCPFTemp := StrTran(cCPFTemp,".","")
	cCPFTemp := StrTran(cCPFTemp,"-","")
	cCPFTemp := StrTran(cCPFTemp,"/","")
	If Len(AlLTrim(cCPFTemp)) < 12
		cCPFTemp := Transform(cCPFTemp,"@R 999.999.999-99" )
	Else
		cCPFTemp := Transform(cCPFTemp,"@R 99.999.999/9999-99")
	Endif
Endif

cCPF := cCPFTemp

If cPaisloc <> "MEX"
	cCPF := StrTran(cCPF,".","")
	cCPF := StrTran(cCPF,"-","")
	cCPF := StrTran(cCPF,"/","")
	cCPF := PadR(cCPF,TamSX3("A1_CGC")[1])
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxGrvMDX   ºAutor  ³Vendas Cliente      º Data ³  12/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava tabela Log de Titulos Baixados (MDM)                   º±±
±±º          | Log. de Titulos Gerados (MDN)   e Contas a Receber (SE1)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 	cOper : 1=Inclusao, 2=estorno			                    º±±
±±º          ³  				                    						º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjxGrvMDX(	cMDMOper	, aPgto		, aPgtoS	, aTit		,;
							cFilialG	, cPrefixo	, cNumero	, cParcela	,;
							cTipo		, cCdCLi	, cLjCli 	, dDate		,;
							cSeq		, cLote		, lRotinaWs	, cNumUse	,;
							aSE5Bxas	, aMoedas	, aTefpgto	, aNsuVndTef,;
							aPagDig		)

Local lTitGerado		:= .F.
Local aSE1	   			:= {}
Local aArea				:= {}
Local lRet          	:= .T.								// variavel de retorno da funcao
Local nX				:= 0 								// Veriavel para controle de loop
Local nY				:= 0 								// Veriavel para controle de loop
Local nZ				:= 0 								// Veriavel para controle de loop
Local cNumTitGer		:= ""								// Numero do titulo gerado.
Local cNumTitAux		:= ""											// Numero do titulo gerado. (auxiliar)
Local cPrefTit	 		:= ""								// Armazena o prefixo do titulo que sera gerado, quem eh configurado via parametro
Local nTamE1_PARCELA	:= 0							// Tamanho do campo E1_PARCELA
Local cNature			:= ""
Local cPortador			:= ""
Local nTamDoc			:= TamSx3("E1_NUM")[1]				   	// Tamanho do E1_NUM
Local nTamTipo			:= TamSx3("E1_TIPO")[1]				   	// Tamanho do E1_TIPO
Local aMDM				:= {}									// Armazena dados que serçao gravados na tabela MDN
Local aMDN				:= {}									// Armazena dados que serçao gravados na tabela MDM
Local cGRParc			:= "0"									// Numero de parcelas geradas
Local nPosFPgto			:= 0
Local cLoteBx			:= ""                                   // Armazena o numero do lote
Local nTamAeCod			:= TamSx3("AE_COD")[1]					// Tamanho do campo AE_COD
Local aPgtosL			:= {}									// aPgtos local
Local aPgtosSL			:= {}                                  // aPgtosSint local
Local aTituloL			:= {}									// aTitulo local
Local lAliasMDM			:= AliasIndic("MDM")					// Indica se existe a tabela do
Local lAliasMDN     	:= AliasIndic("MDN")
Local cCodCLi			:= ""
Local cLojCli			:= ""
Local cNomeCli			:= ""
Local nDias				:= 0
Local nTaxa				:= 0
Local nI                := 0
Local cMvTpRet      	:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS")
Local aAreaE1 			:= {} 									// Salva area do SE1
Local aX				:= {}									// Manipula titulo para aclone do aTit
Local nCont             := 0                                    // Contador
Local cTitNum			:= ""
Local nTroco			:= 0
Local lTroco			:= .F.
Local cCliOri			:= ""
Local cLojOri			:= ""
Local lTefMult		    := SuperGetMV("MV_TEFMULT", ,.F.)	            // Identifica se o cliente utiliza múltiplas transações TEF
Local nPosRetCart 		:= 0
Local lUsaTef			:= LJProFile(2)				// Configuracao do caixa
Local aPgtosId			:= {} //Array apagtos ordenado
Local lTEFD				:= ExistFunc("L010TefD")
Local cDocTEF			:= "" //Documento TEF
Local cNSUTEF			:= "" //NSU TEF
Local cAUTORIZ			:= ""
Local lGrvMEP			:= .F.                                  //Verifica se está sendo utilizada a tabela de parcelamentos SITEF
Local nParcMEP			:= 0									//Parcela SITEF
Local nTamParTEF		:= 0									//Tamanho do Campo Parcela SITEF
Local aCampMEP      	:= {}									//Array para retornar o tamanho do campo MEP_PARTEF
Local aOldPgtosSl		:= {}									//Backup do array aPgtosSL
Local nMaxParc			:= 0									//Numero de Parcelas da forma de pagamento
Local cCodSA2			:= ""									//codigo do fornecedor (SA2)
Local aVetorSE2			:= {}									//vetor com os campos para ExecAuto do Contas a Pagar
Local nValorTaxa		:= 0									//valor da taxa da administradora financeira
Local lMvLjGerTx		:= SuperGetMV( "MV_LJGERTX",, .F. )		//indica se deve-se descontar a taxa da adm do titulo a receber
Local dDataVenc			:= Nil
Local aAuxDados			:= {}
Local aDadosBanc 		:= {}									//array com dados de ag e conta CADASTRADOS NA SA6
Local nTxPagto		    := 0
Local aAdmValTax		:= {}
Local lNewMDM			:= .T.                                  //Controla novo registro pra alias MDM
Local aFina070			:= {}									// Array para a baixa automatica 
Local cTipoBx           := AllTrim(SuperGetMV( "MV_LJBXTIT",.F.,"" ))
Local cHistor			:= STR0207 //"BAIXA AUTOMATICA"
Local aParamLj 		    := {{"2"},{"2"}} 	// Mostra Lanc Contabil? 1=SIM, 2=NÃO / Contabiliza On-line? 1=SIM, 2=NÃO 
Local aTaxaAdm 			:= {}

Private	lMsErroAuto	:= .F.

DEFAULT	cFilialG 	:= ""
DEFAULT cPrefixo 	:= ""
DEFAULT cNumero 	:= ""
DEFAULT	cParcela	:= ""
DEFAULT	cTipo		:= ""
DEFAULT cCdCLi		:= ""
DEFAULT cLjCLi		:= ""
DEFAULT dDate		:= dDataBase
DEFAULT cSeq		:= Space(TamSX3("E5_SEQ")[1])
DEFAULT cLote		:= IIf(lAliasMDM, Space(TamSX3("MDM_LOTE")[1]), Space(6))
DEFAULT lRotinaWs	:= .F. 					// INDICA FOI chamaDA de ws
DEFAULT cNumUse		:= '' 					// Usuario
DEFAULT aSE5Bxas	:= {}
DEFAULT aMoedas		:= {}
DEFAULT aTefpgto	:= {}
DEFAULT aPagDig 	:= {}

If cPaisLoc == "BRA"
	lTroco  := SuperGetMV("MV_LJTROCO",,.F.)
Else
	lTroco  := SuperGetMV("MV_LJTRLOC",,.F.)
EndIf

If lAliasMDM .AND. lAliasMDN

	If cMDMOper == "1"
		// lLojxRec   := .T.---> Indica para funcao A040DupRec que esta sendo feito um Recebimento de Titulo
	    lLojxRec   := .T.
		aCampMEP:= TamSX3("MEP_PARTEF")

		If Len(aCampMEP) > 0
			lGrvMEP := .T.
			nTamParTEF := aCampMEP[1]
		EndIf

		If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs) .Or. (nModulo == 23 .And. !lRotinaWs) //Tratamento para o TOTVS PDV

			If  cTipTEF == TEF_DISCADO .AND. lUsaTef .AND. L010IsDirecao(L010GetGPAtivo())
				aPgtosId := LJLoadDTEF()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP¿
			//³Prepara array´s aPgtos, aPgtosSint e aTitulo para uso local          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄPÙ
			For nX := 1 to Len(aTit)
				AAdd( aTituloL , {	aTit[nX][TIT_SELE] , aTit[nX][TIT_RECN] , aTit[nX][TIT_TIPO] , aTit[nX][TIT_NUME] ,;
									aTit[nX][TIT_CLIE] , aTit[nX][TIT_LOJA] })
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Estrutura do array aPgtosL  ³
			//³1 - Vencimento 			   ³
			//³2 - Forma de pagamento 	   ³
			//³3 - Valor				   ³
			//³4 - Banco do cheque		   ³
			//³5 - Agencia do cheque	   ³
			//³6 - Conta do cheque 		   ³
			//³7 - Cod. adm.			   ³
			//³8 - Moeda 				   ³
			//³9 - Ult. Nr Comprov. ADM FIN³
			//³10- Número do Cartão/CH     ³
			//³11- NSUTEF				   ³
			//³12- NSUDOC                  ³
			//³13- ID do Cartao            ³
			//³14- Emitente do Cheque      ³
			//³15- Autorizacao             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to Len(aPgto)

				nPosRetCart := 0
				aAuxDados	:= {}
				cDocTEF		:= "" //Documento TEF
				cNSUTEF		:= "" //NSU TEF
				cAUTORIZ 	:= "" //Autorizacao

				If Alltrim(aPgto[nX][3]) $ _FORMAPGDG //Pagamento Digital
					LjxRTefDa(	@aAuxDados	,	aPgto	,	Nil		,	NIL 	,;
								NIL 		,	8	 	,	NIL 	, 	nX		,;
								aPagDig )
					cDocTEF	:= aAuxDados[1][3]
					cNSUTEF	:= aAuxDados[1][6]
					cAUTORIZ:= aAuxDados[1][3]
				ElseIf Len(aTefpgto) > 0

				  	If (nPosRetCart := aScan(aTefpgto, {|x| x[1] == aPgto[nX][08]})) > 0
				  		cDocTEF := aTefpgto[nPosRetCart][2]
				  		cNSUTEF := aTefpgto[nPosRetCart][3]
						cAUTORIZ:= IIf(Len(aTefpgto[nPosRetCart])>3,aTefpgto[nPosRetCart][4],aTefpgto[nPosRetCart][2])
				  	EndIf

				ElseIf Alltrim(aPgto[nX][3]) $ _FORMATEF
					If Len(aNsuVndTef) > 0 //a prioridade será o TEF manual (digitação do NSU)
						LjxRTefDa(	@aAuxDados	,	aPgto	,	aNSUVndTef	,	NIL 	,;
									NIL 		,	8	 	,	NIL 		, 	nX		)
						cDocTEF	:= aAuxDados[1][3]
						cNSUTEF	:= aAuxDados[1][6]
						cAUTORIZ:= aAuxDados[1][4]
				 
					ElseIf cTipTef == TEF_CLISITEF
						If (nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgto[nX][8] } ), 1) )  > 0
							cDocTEF := oTef:aRetcartao[nPosRetCart]:CNSUAUTOR
							cNSUTEF := oTef:aRetcartao[nPosRetCart]:CNSUSITEF
							cAUTORIZ:= oTef:aRetCartao[nPosRetCart]:CAUTORIZA
						EndIf

					ElseIf cTipTEF == TEF_DISCADO .AND. lUsaTef 
						If L010IsDirecao(L010GetGPAtivo()) .AND. Len(aPgtosId) > 12

						  	nPosRetCart := aScan(aPgtosId, {|p| p[14] == IIF(!Empty(aPgto[nX][08]), aPgto[nX][08], "1") })
		
							If nPosRetCart > 0
								cNSUTEF :=  aPgtosId[nPosRetCart][13]  //Autorizacao
								cDocTEF :=  Right(aPgtosId[nPosRetCart][7],6) //NSU TEF
								cAUTORIZ:=  Right(aPgtosId[nPosRetCart][7],6)
							Endif
							
						ElseIf lTEFD

							aPgtosId := L010TefD()

							If Len(aPgtosId) > 0 .AND. Len(aPgtosId[1]) >= 19
								
								nPosRetCart := aScan(aPgtosId, {|x| x[19] == IIF(!Empty(aPgto[nX][08]), aPgto[nX][08], "1") })

								If nPosRetCart > 0
									cNSUTEF := aPgtosId[nPosRetCart][09]
									cDocTEF := aPgtosId[nPosRetCart][05]
									cAUTORIZ:= aPgtosId[nPosRetCart][05]
								EndIf
		                    EndIf 
		                EndIf
		            EndIf
				Endif

				If Len(aPgto[nX][4]) > 0 .And. ValType(aPgto[nX][4][1]) == 'A' .AND. Len(aPgto[nX][4][1]) >= 11
					For nI := 1 To Len(aPgto[nX][4])
						AAdd(aPgtosL ,{	aPgto[nX][1] 													,;	//01-Vencimento
										aPgto[nX][3] 													,;	//02-Forma de pagamento
										aPgto[nX][2] 													,;	//03-Valor
						    			IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][nI][4], "") ,;	//04-Banco do cheque
						    			IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][nI][5], "") ,;	//05-Agencia do cheque
										IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][nI][6], "") ,;	//06-Conta do cheque
										IIf(AllTrim(aPgto[nX][3]) $ "CC|CD"  , aPgto[nX][4][nI][5], "") ,;	//07-Cod. Adm. Financeira
						   				aPgto[nX][6] 													,;	//08-Moeda
										"" 																,;	//09-Ult. Nr Comprov. ADM FIN
										IIf(AllTrim(aPgto[nX][3]) $ "CC|CD" , aPgto[nX][4][nI][4], "")	,;	//10-Número do Cartão/CH
						   				cNSUTEF															,;	//11-NSU TEF
						   				cDocTEF															,;	//12-NSU DOC
						   				aPgto[nX][8]													,;	//13-ID do Cartao
						   				IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE .And. aPgto[nX][4][nI][12], aPgto[nX][4][nI][14], ""),; //14-Emitente do Cheque
										cAUTORIZ } )														//15-Autorizacao
											
					Next
				Else
					AAdd(aPgtosL , {aPgto[nX][1] 														,;	//01-Vencimento
									aPgto[nX][3] 														,;	//02-Forma de pagamento
									aPgto[nX][2] 														,;	//03-Valor
					    			IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][4], "") 		,;	//04-Banco do cheque
					    			IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][5], "") 		,;	//05-Agencia do cheque
									IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][6], "") 		,;	//06-Conta do cheque
									IIf(AllTrim(aPgto[nX][3]) $ "CC|CD|PD|PX"  , aPgto[nX][4][5], "") 	,;	//07-Cod. Adm. Financeira
					   				aPgto[nX][6] 														,;	//08-Moeda
									"" 																	,;	//09-Ult. Nr Comprov. ADM FIN
									IIf(AllTrim(aPgto[nX][3]) $ "CC|CD" , aPgto[nX][4][4], "")			,;	//10-Número do Cartão/CH
					   				cNSUTEF																,;	//11-NSU TEF
					   				cDocTEF																,;	//12-NSU DOC
					   				aPgto[nX][8]														,;	//13-ID do Cartao
					   				IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE .And. aPgto[nX][4][12], aPgto[nX][4][14], ""),; //14-Emitente do Cheque
									cAUTORIZ } )															//15-Autorizacao
				EndIf

	   		Next nX

			For nX := 1 to Len(aPgtoS)
				AAdd(aPgtosSL , { aPgtoS[nX][1] , aPgtoS[nX][2] })
			Next nX
		Else
			For nX := 1 to Len(aTit:VerArray)
				AAdd( aTituloL , { aTit:VERARRAY[nX]:TSELE , aTit:VERARRAY[nX]:TRECNO , aTit:VERARRAY[nX]:TTIPO, "", "", "" } )
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega codigo do modulo de origem.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aTit:VerArray) > 0
				nModOrigem := aTit:VERARRAY[1]:MODULO
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega o aTit com dos valores do seu registro, para nao ocasionar erro mais a baixo na comparacao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTit  	:= {}
			aAreaE1 :=  SE1->( GetArea() )
			aX := aClone(aTituloL)
			DBSelectArea("SE1")
			For nX := 1 to Len(aTituloL)
				//Posiciona no registro requerido
				SE1->(DbGoto(aTituloL[nX][2]))

				aTitVazio[TIT_PREF] := SE1->E1_PREFIXO
				aTitVazio[TIT_NUME] := SE1->E1_NUM
				aTitVazio[TIT_PARC] := SE1->E1_PARCELA
				aTitVazio[TIT_TIPO] := SE1->E1_TIPO
				aTitVazio[TIT_CLIE] := SE1->E1_CLIENTE
				aTitVazio[TIT_LOJA] := SE1->E1_LOJA

				aX[nX] := aClone(aTitVazio)
				aTituloL[nX][4]	:= IIf (Empty(aTituloL[nX][4]) , SE1->E1_NUM, 	aTituloL[nX][4])
				aTituloL[nX][5]	:= IIf (Empty(aTituloL[nX][5]) , SE1->E1_CLIENTE, aTituloL[nX][5])
				aTituloL[nX][6]	:= IIf (Empty(aTituloL[nX][6]) , SE1->E1_LOJA, 	aTituloL[nX][6])
			Next nX

			RestArea(aAreaE1)

			aTit  := aClone(aX)

	 		For	nX := 1 to Len(aPgto:VerArray)
				AAdd( aPgtosL , { aPgto:VerArray[nX]:VENCTO 													,;	//01-Vencimento
								  aPgto:VerArray[nX]:TIPO   													,;	//02-Forma de pagamento
								  aPgto:VerArray[nX]:VALOR  													,;	//03-Valor
								  aPgto:VerArray[nX]:BCOCHQ 													,;	//04-Banco do cheque
								  aPgto:VerArray[nX]:AGECHQ														,;	//05-Agencia do cheque
								  aPgto:VerArray[nX]:CTACHQ 													,;	//06-Conta do cheque
								  aPgto:VerArray[nX]:CODADM 													,;	//07-Cod. Adm. Financeira
								  1  																			,;	//08-Moeda
								  "" 																			,;	//09-Ult. Nr Comprov. ADM FIN
								  aPgto:VerArray[nX]:NUMERO														,;	//10-Número do Cartão/CH
								  Iif(ValType(aPgto:VerArray[nX]:NSUTEF) <>"U", aPgto:VerArray[nX]:NSUTEF , "")	,;	//11-NSU TEF
								  Iif(ValType(aPgto:VerArray[nX]:NSUDOC) <>"U", aPgto:VerArray[nX]:NSUDOC , "")	,;	//12-NSU DOC
								  Iif(ValType(aPgto:VerArray[nX]:CIDCART)<>"U", aPgto:VerArray[nX]:CIDCART, "")	,;	//13-ID do Cartao
								  Iif(ValType(aPgto:VerArray[nX]:ECHETER)<>"U", aPgto:VerArray[nX]:ECHETER, "")	,;	//14-Emitente do Cheque
								  Iif(ValType(aPgto:VerArray[nX]:AUTORIZ)<>"U", aPgto:VerArray[nX]:AUTORIZ, "") })	//15-Autorizacao
			Next nX

			For nX := 1 to Len(aPgtoS:VerArray)
				AAdd(aPgtosSL , { aPgtoS:VerArray[nX]:FORMAST , aPgtoS:VerArray[nX]:PARCELAST } )
			Next nX


			SE1->(DbSetOrder(1))
			SE1->(DBSeek(cFilialG + cPrefixo + cNumero + cParcela + cTipo))
		EndIf

		cPrefTit := PadR( SuperGetMV( "MV_LJTITGR", Nil, "REC" ), TamSx3("E1_PREFIXO")[1] )

		nTamE1_PARCELA	:=	TamSX3("E1_PARCELA")[1]

		If lRotinaWs
			cPortador	:= cNumUse
		Else
			cPortador	:= xNumCaixa()
			If !Empty(cNumUse)
				cPortador := cNumUse
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP¿
		//³Gera numero do lote somando + 1 no ultimo lote encontrado            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄPÙ

		cLoteBx	:= GetSx8Num("MDN","MDN_LOTE",,2)

		Begin Transaction
		LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - Begin Transaction - 1")
			For nX := 1 to Len(aTituloL)
				If aTituloL[nX][1]
					cCliOri := aTituloL[nX][5]
					cLojOri := aTituloL[nX][6]
					cTitNum := aTituloL[nX][4]
					SE1->(DBGoTo(aTituloL[nX][2]))
					SE5->(DBSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
					SE5->(DBSeek(xFilial("SE5") + SE1->E1_PREFIXO +  SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA + Replicate("Z", TamSx3("E5_SEQ")[1]), .T. ))
					SE5->(DBSkip(-1))
					MDM->(DBSetOrder(1))
					While (	!SE5->(BOF()) .AND. SE5->E5_PREFIXO == aTit[nX][TIT_PREF] .AND. SE5->E5_NUMERO == aTit[nX][TIT_NUME] .AND. SE5->E5_PARCELA == aTit[nX][TIT_PARC] .AND.;
							SE5->E5_TIPO == aTit[nX][TIT_TIPO] .AND. SE5->E5_CLIFOR == aTit[nX][TIT_CLIE] .AND. SE5->E5_LOJA == aTit[nX][TIT_LOJA] )
						
						LjGrvLog(xFilial("SE5") + SE1->E1_PREFIXO +  SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "LjxGrvMDX - Lendo SE5",SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
						If (SE5->E5_FILIAL == xFilial("SE5")) .AND.;
							( ( SE5->E5_TIPODOC $ "BA" .AND. !LjxDMoney( "SE5", SE5->E5_MOEDA, NIL ) ) ) .AND.;
							!TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)) .AND.;
							!MDM->( DBSeek( xFilial("MDM") + xFilial("SE5") + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_SEQ ) ) .AND.;
							(ValType(aTitBxSE5) == "U" .OR. aScan(aTitBxSE5, { |x| x[1] == SE5->( Recno() ) } ) > 0)

							LjGrvLog(xFilial("SE5") + SE1->E1_PREFIXO +  SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "LjxGrvMDX - Gravando mdm",SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
							LjGrvLog(xFilial("SE5") + SE1->E1_PREFIXO +  SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "LjxGrvMDX - RECNO SE5: ",SE5->(Recno()) )


							Aadd( aMDM, {	{"MDM_FILIAL"	, xFilial( "MDM" )	},;
									{"MDM_BXFILI"	, SE1->E1_FILIAL				},;
									{"MDM_PREFIX"	, SE1->E1_PREFIXO				},;
									{"MDM_NUM"		, SE1->E1_NUM					},;
 									{"MDM_PARCEL"	, SE1->E1_PARCELA				},;
									{"MDM_TIPO"		, SE1->E1_TIPO					},;
									{"MDM_SEQ"		, SE5->E5_SEQ					},;
									{"MDM_DATA"		, dDate			  				},;
									{"MDM_LOTE"		, cLoteBx						},;
									{"MDM_ESTORN"	, "2"			  				}} )
						EndIf
						SE5->(DBSkip(-1))
					End

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP¿
					//³Grava informacoes na tabela MDM                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄPÙ
					For nY := 1 to Len(aMDM)
						DBSelectArea( "MDM" )
						MDM->(DBSetOrder( 1 ))//MDM_FILIAL+MDM_BXFILI+MDM_PREFIX+MDM_NUM+MDM_PARCEL+MDM_TIPO+MDM_SEQ+MDM_LOTE
						If DbSeek( aMDM[nY][1][2] + aMDM[nY][2][2] + aMDM[nY][3][2]+ aMDM[nY][4][2]+ aMDM[nY][5][2]+ aMDM[nY][6][2]+ aMDM[nY][7][2]+ aMDM[nY][9][2]   )
							lNewMDM := .F.
						Else
							lNewMDM := .T.
						EndIf
						
						If RecLock("MDM" , lNewMDM )
							For nZ := 1 To Len(aMDM[nY])
								REPLACE &("MDM->" + aMDM[nY][nZ][1])	WITH	aMDM[nY][nZ][2]
							Next nZ
							MDM->(MsUnlock())
						EndIf
							
					Next nY
					aMDM := {}
				EndIf
			Next nX

			If cPaisLoc <> "BRA"
				LjxGrvSEL( aTit )
			EndIf
			aArea	:= SE1->(GetArea())

			RestArea(aArea)
			aOldPgtosSl := aClone(aPgtosSL)

			For nX := 1 to Len(aPgtosL)

				If (aPgtosL[nX][2] $ cMvTpRet) .AND. cPaisLoc <> "BRA"

					cNumTitAux := GetNumSE1(cPrefTit)			// Alteracao para pegar numeracao SE1
					cNumTitGer	:= PadR( cNumTitAux , nTamDoc )

				ElseIf !IsMoney(AllTrim(aPgtosL[nX][2]))
				
					If AllTrim(aPgtosL[nX][2]) $ "CC|VA|CO|CD|FI|PD|PX" .OR. ( !Empty(aPgtosL[nX][7]) .AND. !AllTrim(aPgtosL[nX][2]) $ "CH")

						DbSelectArea("SAE")
						SAE->( DBSetOrder(1) )
						If SAE->( DBSeek(xFilial("SAE") + SubStr(aPgtosL[nX][7], 1, nTamAeCod)) )

							//se nao for Financiamento Proprio
							If SAE->AE_FINPRO == "N"

								If AllTrim(aPgtosL[nX][2]) $ "VA|CO"
									nDias := SAE->AE_DIAS
								ElseIf AllTrim(aPgtosL[nX][2]) $ "CC|CD" 
									dDataVenc	:= LJCalcVenc(Nil, aPgtosL[nX][1], .F.)
									nDias		:= dDataVenc - aPgtosL[nX][1]
								Else
									nDias := 0
								EndIf

                                If SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

                                    cCodCLi	 := SAE->AE_CODCLI
                                    cLojCli	 := SAE->AE_LOJCLI
                                Else

                                    //Inclui Administradora como cliente para geração do contas a receber
                                    L070IncSA1()

                                    cCodCLi	:= SAE->AE_COD
                                    cLojCli	:= "01"
                                EndIf
								cNomeCli	:= SAE->AE_DESC

								// inclui Administradora como Fornecedor para Geracao do Contas a Pagar
								If lMvLjGerTx .AND. AllTrim(aPgtosL[nX][2]) $ "CC|CD|PX"
									cCodSA2 := L070IncSA2()	//retorna o código do Fornecedor(SA2)
								EndIf

							Else
								cCodCLi		:= cCdCli
								cLojCli		:= cLjCli
								cNomeCli	:= ""
							EndIf
						
							nTxPagto := aScan(aOldPgtosSl, { |x| AllTrim(x[01]) ==  AllTrim(aPgtosL[nX,02]) })

							If ExistFunc("LjTxAdmFin")
								aTaxaAdm := LjTxAdmFin(SAE->AE_COD, aOldPgtosSl[nTxPagto,02])

								// Calcula o valor da Taxa da Adm. Financeira
								If aTaxaAdm[2] > 0
									nValorTaxa 	:= aTaxaAdm[2]
								Else
									nTaxa 		:= aTaxaAdm[1]
									nValorTaxa 	:= aPgtosL[nX][3] * ( nTaxa / 100 )
								EndIf		
							Else

								///////////////////////////////////////////////////////////////////////
								//Chamada da rotina LJ7_TxAdm para cálculo da taxa da Adm Financeira // 
								//de acordo com o cadastrado na tabela MEN							  //
								//Parâmetros utilizados:						    						  //
								// aOldPgtosSl[nTxPagto,02] - Quantidade de parcelas					  //
								// aOldPgtosSl[nX,03] - Valor total das parcelas						  //
								//////////////////////////////////////////////////////////////////////
								aAdmValTax := LJ7_TxAdm( SAE->AE_COD, aOldPgtosSl[nTxPagto,02], aPgtosL[nX,03] )
							
								nTaxa := Iif(aAdmValTax[03] > 0,aAdmValTax[03],SAE->AE_TAXA)

								nValorTaxa := (aPgtosL[nX][3] * nTaxa) / 100
							EndIf
						EndIf

					Else
						cCodCLi		:= cCdCli
						cLojCli		:= cLjCli
						cNomeCli	:= ""
						nDias		:= 0
						nTaxa		:= 0 
						nValorTaxa	:= 0
					EndIf

					// Tratamento para gerar um unico numero de titulo e suas parcelas
				 	If nPosFPgto > 0

				 		If nCont < nMaxParc
							cGRParc := AllTrim(Soma1(cGRParc, nTamE1_PARCELA))
							nCont++
				 		Else
				 			nPosFPgto := 0
				 		EndIf

				 	EndIf

					// Tratamento para gerar um unico numero de titulo e suas parcelas
				 	If nPosFPgto == 0
 					 	nCont		:= 1
					 	nPosFPgto	:= aScan( aPgtosSL, { |x| x[1] $ aPgtosL[nX][2] } )
 					 	nMaxParc	:= aPgtosSL[nPosFPgto][2]

						If nPosFPgto > 0
							aDel(aPgtosSL, nPosFPgto)
				    		aSize(aPgtosSL, Len(aPgtosSL)-1)
						EndIf

			 			cGRParc		:= StrZero( 1 , nTamE1_PARCELA)
			 			cNumTitAux	:= GetNumSE1(cPrefTit)			// Alteracao para pegar numeracao SE1
						cNumTitGer	:= PadR( cNumTitAux , nTamDoc )
				 	EndIf

				 	//Eh forma de pagamento de conciliador e alterou a forma, a administradora e  cartão, reinicia MEP
				  	If lGrvMEP .and. AllTrim(aPgtosL[nX][02]) $ "CC/CD" .and. nX > 1 .and.;
				  		!( aPgtosL[nX][02]   +	aPgtosL[nX][07]      + aPgtosL[nX][13] == ;
				  	       aPgtosL[nX - 1][02] +   aPgtosL[nX - 1][07] + aPgtosL[nX - 1][13])

						nParcMEP := 0
				  	EndIf

					aMDN:= {{"MDN_FILIAL"		, xFilial("MDN")			},;
							{"MDN_GRFILI"		, xFilial("SE1")			},;
							{"MDN_PREFIX"		, cPrefTit					},;
 							{"MDN_NUM"			, cNumTitGer				},;
							{"MDN_PARCEL"		, cGRParc					},;
							{"MDN_TIPO"			, aPgtosL[nX][2]			},;
							{"MDN_LOTE"			, cLoteBx					}}

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP¿
					//³Grava informacoes na tabela MDN                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄPÙ
					RecLock("MDN" , .T.)
					For nY := 1 to Len(aMDN)
						REPLACE &("MDN->" + aMDN[nY][1])	WITH	aMDN[nY][2]
					Next nY
					MDN->( MsUnlock() )
					aMDN := {}

					Do Case
						Case AllTrim(aPgtosL[nX][2]) == "VA"
							cNature	:= LjMExeParam("MV_NATVALE")
						Case AllTrim(aPgtosL[nX][2]) == "CC"
							cNature	:= LjMExeParam("MV_NATCART")
						Case AllTrim(aPgtosL[nX][2]) == "CH"
							cNature	:= LjMExeParam("MV_NATCHEQ")
						Case AllTrim(aPgtosL[nX][2]) == "CD"
							cNature	:= LjMExeParam("MV_NATTEF")
						Case AllTrim(aPgtosL[nX][2]) == "CO"
							cNature	:= LjMExeParam("MV_NATCONV")
						Case AllTrim(aPgtosL[nX][2]) == "FI"
							cNature := LjMExeParam("MV_NATFIN")
						Case AllTrim(aPgtosL[nX][2]) == "PD"
							cNature := LjMExeParam("MV_NATPGDG", .F. , "PAGDIGITAL")
						Case AllTrim(aPgtosL[nX][2]) == "PX"
							cNature := LjMExeParam("MV_NATPGPX", .F. , "PAGTOPIX")
						Otherwise
							cNature := LjMExeParam("MV_NATOUTR")
					EndCase

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP¿
					//³Monta o array com as informacoes para a gravacao do titulo           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄPÙ
					aSE1 := {{"E1_FILIAL"	,xFilial("SE1")											,Nil},;
							{"E1_PREFIXO"	,cPrefTit												,Nil},;
							{"E1_NUM"	  	,cNumTitGer												,Nil},;
							{"E1_PARCELA" 	,cGRParc 												,Nil},;
							{"E1_TIPO"	 	,PadR(aPgtosL[nX][2],nTamTipo)							,Nil},;
							{"E1_NATUREZ" 	,cNature												,Nil},;
							{"E1_PORTADO" 	,cPortador												,Nil},;
				    	   	{"E1_CLIENTE" 	,PadR(cCodCLi,TamSx3("E1_CLIENTE")[1])					,Nil},;
				    	   	{"E1_EMITCHQ"	,IIf(aPgtosL[nX][2] $ MVCHEQUE .And. !Empty(aPgtosL[nX][14]), PadR(aPgtosL[nX][14],TamSx3("E1_EMITCHQ")[1]), "" ), NIL},;
				        	{"E1_LOJA"	  	,cLojCli												,Nil},;
						    {"E1_EMISSAO" 	,dDate	 												,Nil},;
							{"E1_VENCTO"  	,(aPgtosL[nX][1] + nDias)								,Nil},;
							{"E1_VENCREA" 	,(aPgtosL[nX][1] + nDias)								,Nil},;
							{"E1_MOEDA" 	,1														,Nil},;
							{"E1_ORIGEM"	,"LOJA701"												,Nil},;
							{"E1_FLUXO"		,"S"													,Nil},;
							{"E1_VALOR"	  	,( aPgtosL[nX][3] - iIf(!lMvLjGerTx,nValorTaxa,0) )		,Nil},;
							{"E1_VLRREAL"  	,aPgtosL[nX][3]											,Nil},;
							{"E1_HIST"		,""														,Nil},;
							IIf (aPgtosL[nX][2] $ MVCHEQUE , {"E1_BCOCHQ" ,	aPgtosL[nX][4]	,Nil},  {"E1_BCOCHQ" 	, ""	,Nil}),;
							IIf (aPgtosL[nX][2] $ MVCHEQUE , {"E1_AGECHQ" ,	aPgtosL[nX][5]	,Nil},	{"E1_AGECHQ"	, ""	,Nil}),;
							IIf (aPgtosL[nX][2] $ MVCHEQUE , {"E1_CTACHQ" ,	aPgtosL[nX][6]	,Nil},  {"E1_CTACHQ"	, ""	,Nil}),;
							IIf (aPgtosL[nX][2] $ MVCHEQUE	.OR. aPgtosL[nX][2] $ "CC|CD",;
								{"E1_NUMCART",	aPgtosL[nX][10]	,Nil},  {"E1_NUMCART", "", Nil})}

					If cPaisLoc <> "BRA"
					   Aadd(aSE1, {"E1_RECIBO",cRecibo   ,Nil} )
					   Aadd(aSE1, {"E1_SERREC",cSerieRec ,Nil} )

						If Alltrim(aPgtosL[nX][2])=="CH"
					    	aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cPortador, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
					      
					    	aadd(aSE1, {"E1_AGEDEP", If(aPgtosL[nX][8]==1,PadR(aDadosBanc[1],TamSX3("E1_AGEDEP")[1]),MV_SIMB1 ), Nil})
					    	aadd(aSE1, {"E1_CONTA" , PadR(aDadosBanc[2],TamSX3("E1_CONTA")[1]) , NIL } )
						Endif
					Endif

					If Alltrim(aPgtosL[nX][2]) $ _FORMATEF .Or. Alltrim(aPgtosL[nX][2]) $ _FORMAPGDG
 					    Aadd(aSE1, {"E1_DOCTEF"	,	aPgtosL[nX][12]   ,Nil} )
					    Aadd(aSE1, {"E1_NSUTEF"	,	aPgtosL[nX][11]   ,Nil} )
						Aadd(aSE1, {"E1_CARTAUT",	aPgtosL[nX][15]   ,Nil} )
					Endif

					//Inclusao do Titulo a Receber
					MSExecAuto({|x,y| Fina040(x,y)},aSE1, 3) //Inclusao

					If lMsErroAuto
						DisarmTransaction()
						LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - DisarmTransaction() - Fina040(aSE1)")
						RollBackSx8()
						lRet := .F.

						If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs)	// Coloca o erro no console.log para ser visto quando eh frontloja
							MostraErro()
						Else
							Conout( MostraErro("\") )
						EndIf
					Else
						If AllTrim(SE1->E1_TIPO) $ cTipoBx
							If Len(aDadosBanc) == 0
								aDadosBanc :=  GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cPortador, 1, { ".", "."} )		// Busca AG e conta cadastrados na SA6
							EndIf	

							//Monta array para a ExecAuto
							aFina070 := {	{"E1_PREFIXO"  ,cPrefTit  ,Nil 	},;
							{"E1_NUM"      ,cNumTitGer	           ,Nil    	},;
							{"E1_TIPO"     ,PadR(aPgtosL[nX][2],nTamTipo)   ,Nil  	},;
							{"E1_PARCELA"  ,cGRParc			       ,Nil    	},;
							{"AUTMOTBX"    ,"NOR"                  ,Nil    	},;
							{"AUTBANCO"    ,cPortador 	           ,Nil    	},;
							{"AUTAGENCIA"  ,aDadosBanc[1]          ,Nil   	},;
							{"AUTCONTA"    ,aDadosBanc[2]          ,Nil    	},;
							{"AUTDTBAIXA"  ,dDate	     		   ,Nil    	},;
							{"AUTDTCREDITO",dDate		           ,Nil   	},;
							{"AUTHIST"     ,cHistor			       ,Nil   	},; 
							{"AUTJUROS"    ,0                      ,Nil		},;
							{"AUTVALREC"   ,(aPgtosL[nX][3] - iIf(!lMvLjGerTx,nValorTaxa,0)) ,Nil  }}

							//Chama ExecAuto FINA070 para baixa automatica do titulo	
							MSExecAuto({|a,b,c,d,e,f| Fina070(a,b,c,d,e,f)},aFina070, 3,,,, aParamLj)

							If lMsErroAuto
								DisarmTransaction()
								LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - DisarmTransaction() - Fina070(aFina070)")
								RollBackSx8()
								lRet := .F.
								
								If isblind()
									Conout( MostraErro("\") )
								Else									
									MostraErro()
								EndIf								
							EndIf

						EndIf
					EndIf

					
					If !Empty(cNomeCli)
						// Salva a área para não perder o registro salvo anteriormente
						// e para que a numeração dos títulos continue sequencial e correta evitando erro por inclusão de mesmo registro
						aArea	:= SE1->(GetArea())
						DbSelectArea("SE1")
						SE1->(DbSetOrder(1))
						If SE1->(DbSeek(aSE1[1][2] + aSE1[2][2] + aSE1[3][2] + aSE1[4][2] + aSE1[5][2]))
							RecLock( "SE1",.F.)
							SE1->E1_NOMCLI  := cNomeCli
							Aadd(aSE1, {"E1_NOMCLI"	,	cNomeCli   ,Nil} )
							SE1->( MsUnlock() )
						EndIf
						RestArea(aArea)
		    	    EndIf
					If ExistBlock("LJRECSE1")	 
						ExecBlock( "LJRECSE1", .F., .F., { aSE1,aTit} ) 
					Endif

					If !lMsErroAuto  .AND. lGrvMEP .and. AllTrim(aPgtosL[nX][02]) $ "CC/CD"
						//Realiza a gravacao da MEP
						nParcMEP++ //Incrementa o contador TEF
						SE1->( DbSetOrder(1) )
						If SE1->(DbSeek( aSE1[1][2] + aSE1[2][2] + aSE1[3][2] + PadR(aSE1[4][2],nTamE1_PARCELA) + aSE1[5][2] ))
					   		RecLock("MEP", .T.)
					   		REPLACE MEP->MEP_FILIAL WITH xFilial("MEP")
					   		REPLACE MEP->MEP_PREFIX WITH SE1->E1_PREFIXO
					   		REPLACE MEP->MEP_NUM 	WITH SE1->E1_NUM
					   		REPLACE MEP->MEP_PARCEL WITH SE1->E1_PARCELA
					   		REPLACE MEP->MEP_TIPO   WITH SE1->E1_TIPO
					   		REPLACE MEP->MEP_PARTEF WITH StrZero(nParcMEP, nTamParTEF)

					   		MEP->( MsUnLock() )
						EndIf
					EndIf

					//
					//indica que deve incluir um Titulo no Contas a Pagar (taxa da Administradora Financeira) MCL
					//
					If !lMsErroAuto .AND. !Empty(cCodSA2) .AND. lMvLjGerTx

						nValorTaxa := A410Arred( nValorTaxa, "L2_VRUNIT" )

						// Proteção para não deixar gerar o MSExecAuto do Fina050 (abaixo) sem valor.
						// A variável nValorTaxa chegará aqui zerada se o campo "Taxa de Cobrança" no SAE estiver 0(zero) e
						// o parametro MV_LJGERTX estiver = .T.
						If nValorTaxa > 0 
						
							aVetorSE2 :={	{"E2_PREFIXO"	, SE1->E1_PREFIXO		, Nil}	,;
											{"E2_NUM"	   	, SE1->E1_NUM    		, Nil}	,;
											{"E2_PARCELA"	, SE1->E1_PARCELA		, Nil}	,;
											{"E2_TIPO"		, SE1->E1_TIPO   		, Nil}	,;
											{"E2_NATUREZ"	, SE1->E1_NATUREZ		, Nil}	,;
											{"E2_FORNECE"	, cCodSA2	 			, Nil}	,;
											{"E2_LOJA"		, SE1->E1_LOJA   		, Nil}	,;
											{"E2_EMISSAO"	, DDATABASE      		, NIL}	,;
											{"E2_VENCTO"	, SE1->E1_VENCTO 		, NIL}	,;
											{"E2_VENCREA"	, SE1->E1_VENCREA		, NIL}	,;
											{"E2_VALOR"		, nValorTaxa 			, NIL}	,;
											{"E2_HIST"		, AllTrim(SE1->E1_NUM)	, NIL}	}

							lMsErroAuto := .F.
							cCodSA2		:= ""

							// Faz a INCLUSAO do CONTAS A PAGAR via ExecAuto
							MSExecAuto( {|x,y,z| FINA050(x,y,z)}, aVetorSE2, Nil, 3 )

							// Verifica se houve algum durante a execucao da rotina automatica
							If lMsErroAuto
								DisarmTransaction()
								LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - DisarmTransaction() - Fina050(aVetorSE2)" )
								RollBackSx8()
								lRet:= .F.

								If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs )
									MostraErro()
								Else
									conout( MostraErro() )
								EndIf
							EndIf
						Endif
					EndIf
					aSE1 := {}
				EndIf

				If cPaisLoc <> "BRA"
					nTroco := 0
					If lTroco
						nPosMoeda := ascan(aMoedas, { |x| x[6] == aPgtosL[nX][8]} )
						If nPosMoeda > 0
							nTroco := aMoedas[nPosMoeda][3]
						EndIf
					Else
						If IsMoney(aPgtosL[nX][2])
							If aPgtosL[nX][8] > 1
								nTroco := xMoeda(Lj7T_Troco(2), 1, aPgtosL[nX][8], dDataBase, 3)
							Else
								nTroco := Lj7T_Troco(2)
							EndIf
						EndIf
					EndIf

					If  ( aPgtosL[nX][3]-nTroco < 0 )
						nTroco := 0
					EndIf

					SEL->( RecLock("SEL",.T.) )
					SEL->EL_FILIAL		:= xFilial("SEL")
					SEL->EL_TIPODOC		:= AllTrim( aPgtosL[nX][2] )
					SEL->EL_PREFIXO		:= SE1->E1_PREFIXO
					SEL->EL_NUMERO		:= IIf( !( IsMoney(aPgtosL[nX][2]) .OR. (Alltrim(aPgtosL[nX][2]) $ cMvTpRet) ), SE1->E1_NUM, cTitNum )
					SEL->EL_PARCELA		:= SE1->E1_PARCELA
					SEL->EL_TIPO		:= AllTrim( aPgtosL[nX][2] )
					SEL->EL_BCOCHQ		:= SE1->E1_BCOCHQ
					SEL->EL_AGECHQ		:= SE1->E1_AGECHQ
					SEL->EL_CTACHQ		:= SE1->E1_CTACHQ
					SEL->EL_EMISSAO		:= SE1->E1_EMISSAO
					SEL->EL_EMISREC		:= dDataBase
					SEL->EL_DTDIGIT		:= dDataBase
					SEL->EL_DTVCTO		:= SE1->E1_VENCTO
					SEL->EL_NATUREZ		:= SE1->E1_NATUREZ
					SEL->EL_MOEDA		:= STRZERO(SE1->E1_MOEDA,2)
					SEL->EL_VLMOED1		:= IIf( IsMoney(aPgtosL[nX][2]), aPgtosL[nX][3]-nTroco, aPgtosL[nX][3] )
					SEL->EL_DESCONT		:= SE1->E1_DESCONT

				    If SEL->(FieldPos("EL_MULTA")) > 0
				       SEL->EL_MULTA	:= SE1->E1_MULTA
				    EndIf

				    If SEL->(FieldPos("EL_JUROS")) > 0
				       SEL->EL_JUROS	:= SE1->E1_VALJUR
				    EndIf

					SEL->EL_VALOR		:= IIf( IsMoney(aPgtosL[nX][2]), aPgtosL[nX][3]-nTroco, aPgtosL[nX][3] )
					SEL->EL_CLIENTE		:= SE1->E1_CLIENTE
					SEL->EL_LOJA		:= SE1->E1_LOJA
					SEL->EL_SERIE		:= cSerieRec
					SEL->EL_RECIBO		:= LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)
					SEL->EL_CLIORIG		:= cCliOri
					SEL->EL_LOJORIG		:= cLojOri

					SEL->( MsUnlock() )
				EndIf

				If Alltrim(aPgtosL[nX][2]) == "CH"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Quando for loja ou faturamento, não usar objeto de ws³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs) .Or. (nModulo == 23 .And. !lRotinaWs) //Tratamento para o TOTVS PDV
						If ValType(aPgto[nX][4][1]) == 'A' .AND. Len(aPgto[nX][4][1]) >= 11
							For nI := 1 To Len(aPgto[nX][4])
								LJRecGrvCH(aPgto[nX][4][nI][4]	,;	// Banco
											aPgto[nX][4][nI][5]	,;	// Agencia
											aPgto[nX][4][nI][6]	,;	// Conta
											aPgto[nX][4][nI][7]	,;	// Numero
											aPgto[nX][4][nI][1]	,;	// Valor
											aPgto[nX][4][nI][2]	,;	// Data
											aPgto[nX][4][nI][8]	,;	// Compensacao
											aPgto[nX][4][nI][9]	,;	// RG
											aPgto[nX][4][nI][10]	,;	// Telefone
											aPgto[nX][4][nI][12]	,;	// Chq Terceiro
											SE1->E1_PREFIXO		,;	// Prefixo 2
											SE1->E1_NUM			,;	// Titulo 3
											SE1->E1_PARCELA		,;	// Parcela 4
											SE1->E1_TIPO			,;	// Tipo
											SE1->E1_CLIENTE		,;	// Cliente
											SE1->E1_LOJA		,;	// Loja
											iif(Len(aPgto[nX][4][nI]) > 13, aPgto[nX][4][nI][14] , ""))	// Emitente Terceiro
							Next
						Else
							LJRecGrvCH( aPgto[nX][4][4] ,;	// Banco
										aPgto[nX][4][5],;	// Agencia
										aPgto[nX][4][6],;	// Conta
										aPgto[nX][4][7],;	// Numero
										aPgto[nX][4][1],;	// Valor
										aPgto[nX][4][2],;	// Data
										aPgto[nX][4][8],;	// Compensacao
										aPgto[nX][4][9],;	// RG
										aPgto[nX][4][10],;	// Telefone
										aPgto[nX][4][12],;	// Chq Terceiro
										SE1->E1_PREFIXO,;	// Prefixo 2
										SE1->E1_NUM,;		// Titulo 3
										SE1->E1_PARCELA,;	// Parcela 4
										SE1->E1_TIPO,;		// Tipo
										SE1->E1_CLIENTE,;	// Cliente
										SE1->E1_LOJA   ,;	// Loja
										iif(Len(aPgto[nX][4]) > 13, aPgto[nX][4][14] , ""))	// Emitente Terceiro
						EndIf
					Else
						LJRecGrvCH( aPgto:VerArray[nX]:BCOCHQ ,;	// Banco
									aPgto:VerArray[nX]:AGECHQ,;		// Agencia
									aPgto:VerArray[nX]:CTACHQ,;		// Conta
									aPgto:VerArray[nX]:NUMERO,;		// Numero
									aPgto:VerArray[nX]:VALOR,;		// Valor
									aPgto:VerArray[nX]:DATACH,;		// Data
									aPgto:VerArray[nX]:COMPENS,;	// Compensacao
									aPgto:VerArray[nX]:RG ,;		// RG
									aPgto:VerArray[nX]:TEL,;		// Telefone
									aPgto:VerArray[nX]:CHETER,;	// Chq Terceiro
									SE1->E1_PREFIXO,;			// Prefixo 2
									SE1->E1_NUM,;				// Titulo 3
									SE1->E1_PARCELA,;			// Parcela 4
									SE1->E1_TIPO,;				// Tipo
									SE1->E1_CLIENTE,;			// Cliente
									SE1->E1_LOJA   ,;			// Loja
									aPgto:VerArray[nX]:ECHETER)	// Emitente Terceiro
					EndIf
				EndIf

				If cPaisLoc <> "BRA"
					LjxGrvSFE()
				EndIf

			Next nX

			aPgtosSL := aClone(aOldPgtosSl)
			aSize(aOldPgtosSl, 0)
			aOldPgtosSl := Nil

		End Transaction
		LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - End Transaction - 1")
		ConfirmSX8()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retornando valor padrao de nModOrigem. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nModOrigem := 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retornando valor padrao de lLojxRec.	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lLojxRec   := .F.
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄP¿
		//³O estorno só é executado na venda assistida, por isto usa o aTitulo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄPÙ

		Begin Transaction
		LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - Begin Transaction - 2")

			DBSelectArea("MDM")
			MDM->(DBSetOrder(2))
			For nX := 1 to Len(aTitulo)
				If aTitulo[nX][TIT_SELE]
			MDM->(DBSeek(xFilial("MDM")+cLote))
			While !MDM->(Eof()) .AND. (MDM->MDM_LOTE == clote )
		
				If MDM->MDM_ESTORN == "1"
					MDM->(DbSkip())
					Loop
				EndIf

				RecLock("MDM" , .F.)
				//Adicionado tratamento para marcar como estornado apenas o cartao correto						
				REPLACE	MDM->MDM_ESTORN	WITH	"1"
				MDM->(MsUnlock())
				lTitGerado	:= .T.
				MDM->(DbSkip())
			End
				EndIf
			Next nX

			If lTitGerado
				DbSelectArea( "MDN" )
				MDN->(DbSetOrder( 2 ))
				If MDN->(DBSeek(xFilial( "MDN" ) + cLote ))
					While !MDN->(Eof()) .AND. MDN->MDN_LOTE == cLote

							DbSelectArea("SE1")
							SE1->(DbSetOrder(1))
							If SE1->(DBSeek(MDN->MDN_GRFILI + MDN->MDN_PREFIX + MDN->MDN_NUM + MDN->MDN_PARCEL + MDN->MDN_TIPO))
								While !SE1->(Eof()) .AND. (SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM ) ==;
									(MDN->MDN_GRFILI + MDN->MDN_PREFIX + MDN->MDN_NUM )
	
									aSE1  := {{"E1_FILIAL"	,xFilial("SE1")		,Nil},;
										{"E1_PREFIXO"	,SE1->E1_PREFIXO  		,Nil},;
										{"E1_NUM"	  	,SE1->E1_NUM			,Nil},;
										{"E1_PARCELA" 	,SE1->E1_PARCELA		,Nil},;
										{"E1_TIPO"	 	,AllTrim(SE1->E1_TIPO)	   		,Nil} }
																	
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Exclui registro do contas a pagar de			³//
									//³ taxa adminstrativa. parametro MV_LJGERTX = .T.³//
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If lMvLjGerTx
										Lj140ExCap()    
									EndIf
																	
									MSExecAuto({|x,y| Fina040(x,y)},aSE1, 5) // Exclusao
									
									If  lMsErroAuto
									    DisarmTransaction()
									    LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - DisarmTransaction() - Fina040()- 2")
										lRet:= .F.
										If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs)
											MostraErro()
										// Coloca o erro no console.log para ser visto quando eh frontloja
										Else
											Conout( MostraErro() )
										EndIf
									EndIf								
									
									SE1->(DBSkip())
								End
							EndIf
						MDN->(DBSkip())
					End
				EndIf
			EndIf
		End Transaction
		LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - End Transaction - 2")
	EndIf
EndIf

Return  lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  |GERATITRECºAutor  ³Microsiga           º Data ³  03/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera titulos no contas a receber (SE1) via WebService      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FrontLoja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GERATITREC WSRECEIVE cFilialG , cPrefixo , cNumero , cParcela ,;
							  cTipo    , CodCli   , LojCli  , dDate    ,;
							  aPgWS    , aPgWsS   , aTit    , EmpPdv   ,;
							  FilPdv   , MvLjPdvPa  WSSEND lRet WSSERVICE LJRECEB
Local lRet          := .F.								// variavel de retorno da funcao

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(::EmpPdv,::FilPdv)

If Type("cEstacao") == "U"
	cEstacao := ""
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Essa variavel está sendo inicializada dentro das funcoes e Method's           ³
//³porque em caso de PAF(WS - sem preparein), o ambiente nao foi preparado ainda.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSerieRec  := Criavar("EL_SERIE" )
cRecibo    := Criavar("EL_RECIBO" )

lRet	:= 	LjxGrvMDX( 	"1" 		, ::aPgWS 		, ::aPgWsS 	, ::aTit 	, ;
						::cFilialG 	, ::cPrefixo 	, ::cNumero , ::cParcela ,;
						::cTipo 	, ::CodCli 		, ::LojCLI 	, ::dDate,    ;
						Nil			, Nil			, .T.		, self:cNomeUser )

If !lRet
	SetSoapFault(STR0153,STR0154) //"Rotina Não Executada","Problemas encontrados na execução da Rotina Automática FINA040"
EndIf
lRecebNFCE   := nil							//Controle de Performance - função LjModNFis()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJXBXSE5VLºAutor  ³Microsiga           º Data ³  09/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Baixa Documento do Tipo VL no E5, para quando for estornado º±±
±±º          ³um titulo gerado em outra filial.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJXBXSE5VL(aBaixa, nOpcao, cSeq)
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaSE5		:= SE5->(GetArea())
Local lEstorna		:= .F.
Local cData			:= Space(TamSX3("E5_DATA")[1])

DEFAULT	aBaixa		:= {}
DEFAULT nOpcao 		:= 1		// 1 para pesquisa e 2 para gravacao
DEFAULT cSeq		:= Space(TamSX3("E5_SEQ")[1])

DBSelectArea("SE5")
SE5->( DBSetOrder(7) )

If SE5->(DbSeek(xFilial("SE5")	+ aBaixa[2][2] + aBaixa[3][2] + aBaixa[4][2] +;
	  			aBaixa[5][2]	+ aBaixa[6][2] + aBaixa[7][2] + cSeq) )

	While !SE5->(EOF()) .AND. SE5->E5_PREFIXO == aBaixa[2][2] .AND. SE5->E5_NUMERO == aBaixa[3][2] .AND. ;
						SE5->E5_PARCELA == aBaixa[4][2] .AND. SE5->E5_TIPO == aBaixa[5][2]

		If SE5->E5_TIPODOC $ "VL|BA"
			If nOpcao == 1
				If SE5->E5_FILIAL == xFilial("SE5")
					Return .T.
				Else
					MsgStop(STR0118 + CRLF + STR0119 , STR0030)	//# "Nao foi possivel estornar o titulo" # "pois a filial corrente nao e a filial que efetuou a baixa. # Atencao"
					Return .F.
				EndIf
			Else
				If SE5->E5_FILORIG == cFilAnt
					cData := DToS(SE5->E5_DATA)
					LJXESTORNA(SE5->E5_VALOR, cSeq)
					If !SE5->E5_FILIAL == SE1->E1_FILIAL .OR. LjxDMoney( "SE5", SE5->E5_MOEDA, NIL )
						lEstorna	:= .T.
					Else
						lEstorna	:= .F.
					EndIf
					Exit
				Else
					SE5->(DBSkip())
				EndIf
			EndIf
		Else
			SE5->(DBSkip())
		EndIf
	EndDo
EndIf



SE5->(DBSetOrder(2))
If SE5->(DBSeek(aBaixa[1][2] + "BA" + aBaixa[2][2] + aBaixa[3][2] + aBaixa[4][2] + aBaixa[5][2] + cDATA + aBaixa[6][2] + aBaixa[7][2] + cSeq))
	RecLock("SE5", .F.)
	REPLACE SE5->E5_SITUACA WITH "C"
	SE5->(MsUnlock())
EndIf

If cPaisLoc <> "BRA" .AND. nOpcao == 2
	SEL->( dbSetOrder(8) )
	If SEL->( dbSeek( xFilial("SEL") + SE5->E5_SERREC +  SE5->E5_ORDREC ) )
		While !SEL->(EOF()) .AND. SEL->EL_SERIE == SE5->E5_SERREC .AND. SEL->EL_RECIBO == SE5->E5_ORDREC
			RecLock("SEL" , .F.)
			SEL->EL_CANCEL := .T.
			SEL->( MsUnlock() )
			SEL->(DBSkip())
		End
	EndIf
	SFE->( dbSetOrder(6) )
	If SFE->( dbSeek( xFilial("SFE") + SE5->E5_ORDREC ) )
		While !SFE->(EOF()) .AND. SFE->FE_RECIBO == SE5->E5_ORDREC .AND. !Empty(SE5->E5_ORDREC)
			RecLock("SFE" , .F.)
			SFE->( DBDelete() )
			SFE->( MsUnlock() )
			SFE->( DBSkip() )
		End
	EndIf
EndIf

RestArea(aAreaSE1)
RestArea(aAreaSE5)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValTroco ºAutor  ³ Vendas eCRM 		 º Data ³  01/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o Valor do Troco Referente ao Título               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValTroco(cPrefixo,cNum,cParcela,cTipo,cCliente,cLoja,cSeq,nEstTroco)

Local aAreaAtu 	:= GetArea()      //Guarda area atual
Local aAreaSE5 	:= GetArea("SE5") //Guarda area da tabela SE5
Local nRet		:= 0              //Valor retornado pela função quando o titulo que gerou o troco for E5_TIPO = "VL"
Local nVlTroco  := 0              //Valor do troco encontrado na sequencia de baixas 
Local cChaveSE5 := xFilial("SE5")+cPrefixo+cNum+cParcela+Space(TamSX3("E5_TIPO")[1])
Local lAchouSE5 := .F.
Local cCodCli	:= cCliente
Local cCodLoj	:= cLoja

DbSelectArea("SE5")
SE5->( DbSetOrder(7) ) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
//Primeiro posiciona para procurar o registro de troco referente ao titulo
If !( lAchouSE5 := SE5->( DbSeek( cChaveSE5 + cCodCli + cCodLoj ) ) )
	
	//Se o sistema estiver atualizado com o novo tratamento de gravacao do troco, o troco não é mais gravado com informações do codigo do cliente e loja (os campos ficam em branco)
	If ExistFunc("LjNewGrvTC") .And. LjNewGrvTC() //Verifica se o sistema está atualizado para executar o novo procedimento para gravação dos movimentos de troco.
		//Faz a busca considerando o codigo do cliente e loja em branco
		cCodCli := Space(TamSX3("E5_CLIFOR")[1])
		cCodLoj := Space(TamSX3("E5_LOJA")[1])
		lAchouSE5 := SE5->( DbSeek( cChaveSE5 + cCodCli + cCodLoj ) )
	EndIf
EndIf

If lAchouSE5
	cChaveSE5 := cChaveSE5 + cCodCli + cCodLoj
    While !SE5->(Eof()) .AND. cChaveSE5 == SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA

        If SE5->E5_MOEDA <> "TC" .OR. SE5->E5_TIPODOC <> "VL" .OR.;
                SE5->E5_RECPAG <> "P" .OR. SE5->E5_SEQ <> cSeq
            SE5->(DbSkip())
            Loop
        EndIf

        nVlTroco  := SE5->E5_VALOR
        nEstTroco := SE5->(Recno())
        Exit
    EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Depois deve procurar se existe o registro do tipo "VL" ,pois			    ³
//³somente o registro VL deve atualizar o saldo subtraindo o valor do troco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE5")
SE5->(DbSetOrder(2))
If nVlTroco > 0 .And. SE5->(DbSeek(xFilial("SE5")+"VL"+cPrefixo+cNum+cParcela+cTipo))

	While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .and. ;
	SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="VL"+cPrefixo+cNum+cParcela+cTipo

		If SE5->E5_CLIFOR <> cCliente .OR. SE5->E5_LOJA <> cLoja .OR. SE5->E5_SEQ <> cSeq
			DbSkip()
			Loop
		EndIf

        nRet := nVlTroco

		Exit
	EndDo
EndIf

RestArea(aAreaSE5)
RestArea(aAreaAtu)

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SE1ValLiqºAutor  ³ Vendas e CRM		 º Data ³  10/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o valor da penultima baixa do titulo.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SE1ValLiq(cPrefixo,cNum,cParcela,cTipo,cCliente,cLoja)

Local aAreaAtu 		:= GetArea()
Local nBaixas		:= 0
Local nRet			:= 0
Local lAliasMDMN	:= AliasIndic("MDM") .AND. AliasIndic("MDN") // Tabelas MDM Titulos Baixados e MDN Titulos Gerados
Local cTipoDoc		:= ""
Local aAuxBxSE5     := {}  //Back-up do array aBaixaSE5

If lAliasMDMN .AND.( SE1->E1_FILIAL == xFilial("SE5") ) .AND. ( AlLTrim(cTipo) <> "VP" )
	cTipoDoc := "V2 /BA /RA /CP /LJ /" 
Else
	cTipoDoc := "VL /V2 /BA /RA /CP /LJ /"
EndIf


aAuxBxSE5 := aClone(aBaixaSE5)
// Limpa array
aBaixaSE5 := {}

// Retorna baixas do titulo
Sel070Baixa( 	cTipoDoc+MV_CRNEG	,cPrefixo	,cNum	,cParcela,;
	 			cTipo				,NIL		,NIL	,cCliente,;
  				cLoja				,NIL		,NIL	,NIL,;
 				NIL					,.T.	)

// Verifica totais de titulos
nBaixas := Len(aBaixaSE5)

// Verifica se existe penultima baixa
If nBaixas > 1
	If nOpSelBxa == 0
		nRet := aBaixaSE5[nBaixas-1,8]
	ElseIf nOpSelBxa > 1
		nRet := aBaixaSE5[nOpSelBxa-1,8]
	Else
		nRet := SE1->E1_VALLIQ - aBaixaSE5[nOpSelBxa,8]
	EndIf
EndIf
nOpSelBxa := 0

// Restauro o valor do array 
aBaixaSE5 := aClone(aAuxBxSE5)

RestArea(aAreaAtu)

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ WSAtTrocoºAutor  ³ Vendas e CRM		 º Data ³  02/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama Webservice para geracao de troco na retaguarda.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function WSAtTroco( nValor, nMoedaTrc, cCliente, cLoja, aTitulo, cNumCaixa )

Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia conexao com o WebService para Gravacao do novo titulo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvc      := WSLJRECEB():New()
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o array dentro do metodo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSvc:oWSATITEST:OWSVERARRAY 	  		:= LJRECEB_ARRAYOFWSTITULO():New()
oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO	:= Array( Len(aTitulo) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Antes de chamar o metodo, atribui os valores ³
//³as propriedades (passagem de parametros)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aTitulo)

	If aTitulo[nX][TIT_SELE] .AND. !IsMoney(aTitulo[nX][TIT_TIPO])

		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX] := LJRECEB_WSTITULO():New()

		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:lSELEAS			:= aTitulo[nX][TIT_SELE]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:cPrefixo  		:= aTitulo[nX][TIT_PREF]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:cNumTitulo		:= aTitulo[nX][TIT_NUME]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:cParcela 		:= aTitulo[nX][TIT_PARC]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:dVencimento		:= aTitulo[nX][TIT_VREA]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:nValor			:= aTitulo[nX][TIT_VALO]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:nVlrMulta 		:= aTitulo[nX][TIT_MULT]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:nVlrJuros		:= aTitulo[nX][TIT_JURO]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:nVlrDesconto	:= aTitulo[nX][TIT_DESC]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:nVlrRecebido	:= aTitulo[nX][TIT_RECE]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:cTipo 			:= aTitulo[nX][TIT_TIPO]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:cContrato		:= aTitulo[nX][TIT_CONT]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:cCliente  		:= aTitulo[nX][TIT_CLIE]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:cLoja	   		:= aTitulo[nX][TIT_LOJA]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:cFilTit  		:= aTitulo[nX][TIT_FILI]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:nNumRecno		:= aTitulo[nX][TIT_RECN]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:dDtBaixa		:= aTitulo[nX][TIT_DTBX]
		oSvc:oWSATITEST:OWSVERARRAY:oWSWSTITULO[nX]:nSaldo	   		:= aTitulo[nX][TIT_SALD]

	EndIf
Next nX

lRet := oSvc:GeraTroco(nValor, nMoedaTrc, cCliente, cLoja, nil, cNumCaixa, cEmpAnt, cFilAnt)

If !lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|*** Aqui devera ser melhor tratado as mensagens de erro...        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSvcError := GetWSCError()
	If Left(cSvcError,9) == "WSCERR048"
		cSoapFCode  := GetWSCError(2)
		cSoapFDescr := GetWSCError(3)
		MsgStop(cSoapFDescr, cSoapFCode)
	Else
		//"Sem comunicação com o WebService!", "Atenção!"
		MsgStop(STR0029,STR0030)
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EstoBxNCCºAutor  ³ Vendas e CRM		 º Data ³  03/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para estorno dos titulos que tem baixas por         º±±
±±º		     ³ compensacao.												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function EstoBxNCC(nPosTit)

Local aArea := GetArea()
Local lRet  := .T.

lMsErroAuto := .F.

DbSelectArea("SE5")
DbSetOrder(2)
If !DbSeek(xFilial("SE5")+"CP"+aTitulo[nPosTit][TIT_PREF]+aTitulo[nPosTit][TIT_NUME];
			+aTitulo[nPosTit][TIT_PARC]+aTitulo[nPosTit][TIT_TIPO])
	lRet := .F.
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no SE1 antes de executar o FINA330. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SE1")
	DbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se titulo esta selecionado. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aTitulo[nPosTit][TIT_SELE]
		If DbSeek(xFilial("SE1") + aTitulo[nPosTit][TIT_PREF] + aTitulo[nPosTit][TIT_NUME] +;
					 aTitulo[nPosTit][TIT_PARC] + aTitulo[nPosTit][TIT_TIPO])
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fina330        ³
			//³ 5  - Estorno  ³
			//³.T.- Automatico³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MSExecAuto({|x, y| Fina330(x, y)},5,.T.)

			If lMsErroAuto
				lSemErro := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| "  Tipo: "   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DisarmTransaction()
				LjGrvLog("Recebimento_Titulo", "EstoBxNCC - DisarmTransaction() - 2")
				MostraErro()

				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RecebNFisºAutor  ³ Vendas e CRM		 º Data ³  03/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para impressao de comprovante de recebimento de     º±±
±±º		     ³ titulo.													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RecebNFis(	aTitBXNCC		, lFiscal	, lMultBaixa, nTotComprovante,;
					cNumDocumento	, nEspaco	, nHdlECF	, cMsgCompTitulo,;
					cTotRecNFis		, cMvSimb1	, nCntTit	, cMsgComprovante,;
					cSimbCor)

Local nI
Local lINFCutPpr	:= ExistFunc('INFCutPpr')
Local lImpNaoFis	:= IIF(!Empty(LjGetStation("IMPFISC")),.T.,.F.)  	//Sinaliza recebimento em equipamento nao fiscal
Local lAutomato		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local cMsgRet		:= ""												//Mensagem de Retorno após erro de impressão

DEFAULT aTitBXNCC := aClone(aTitulos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o(s) Recebimento Nao-Fiscal e a Autenticacao do(s) documento(s) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:=1 To Len(aTitBXNCC)
	If aTitBXNCC[nI][TIT_SELE] .AND. (lFiscal .OR. LjNfPtgNEcf(SM0->M0_CGC)) //PTG e ANG sem ECF - ira efetuar a impressao do comprovante em uma impressora comum

		If ExistBlock( "FRTRECTIT" )
			ExecBlock( "FRTRECTIT", .F., .F., { nI, aTitBXNCC } )
		ElseIf cPaisLoc <> "MEX"

			If !lAutomato .AND. !IsBlind() .AND. !File( GetClientDir()+"SIGALOJA.INI" )
				WritePProString("Recebimento Titulos", "Totalizadores", "01", GetClientDir()+"SIGALOJA.INI")
			Endif

			cCliente 	:= aTitBXNCC[nI][TIT_CLIE]
			cLoja		:= aTitBXNCC[nI][TIT_LOJA]

			If lMultBaixa
				//       "C O M P R O V A N T E"
				//   "D E   R E C E B I M E N T O"
				//"Cliente : "
			    //"Documento                         Valor"
			    //"T O T A L "
			   	cNumDocumento	:= aTitBXNCC[nI][TIT_PREF] + "/" + aTitBXNCC[nI][TIT_NUME]
				nEspaco 		:= 40 - ( Len ( cNumDocumento ) + Len ( cMvSimb1 ) + Len ( aTitBXNCC[nI][TIT_PARC] ) + 15  )
				cNumDocumento	:= cNumDocumento + "/" + aTitBXNCC[nI][TIT_PARC] + Space( nEspaco ) + cMvSimb1 + Trans(aTitBXNCC[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)

				cMsgCompTitulo 	:= 	Space((40-Len(STR0053)) / 2) + STR0053 + Chr(10) +;
									Space((40-Len(STR0107)) / 2) + STR0107 + Chr(10) +;
									Chr(10) + Chr(10) +;
									STR0055 + Posicione( "SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_NOME") +;
									Chr(10) + Chr(10) +;
									IIF(!Empty(aTitBXNCC[nI][TIT_CONT]),STR0013,STR0056) + Chr(10) +;
									Replicate("=",40) + Chr(10) +;
									Chr(10) +;
									cNumDocumento +;
									&(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) + Space(12) + AllTrim(Trans(aTitBXNCC[nI][TIT_RECE],"@E 999,999,999.99"))

				If LJModNFis()
					If lImpNaoFis

						nRet := INFTexto(cMsgCompTitulo)  //Envia comando para a Impressora

						If lINFCutPpr
							INFCutPpr()
						EndIf
					Else
						nRet := 0 //Permite recebimento sem impressora no Faturamento
					EndIf
				Else
					nRet := IFRelGer( nHdlECF, cMsgCompTitulo, 1 )
					cMsgRet := STR0209 //"IFRelGer: Erro na Impressão do Relatório Gerencial."
				EndIf

				cMsgCompTitulo := ""
			Else
				nRet := IFRecebNFis( nHdlECF, cTotRecNFis, aTitBXNCC[nI][TIT_RECE], &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')))
				cMsgRet := STR0217		//"IFRecebNFis: Erro na Impressão do Recebimento Não-Fiscal."
			EndIf

			If nRet <> 0
				MsgStop(cMsgRet, STR0030)	//"Atenção!"
				LjGrvLog("Recebimento_Titulo", cMsgRet)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alimenta a msg para impressao do comprovante de recebimento com os dados³
				//³ dos titulos e do cliente e faz a somatoria de todos os pagamentos       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aTitBXNCC[nI][TIT_CONT])
					cMsgComprovante += aTitBXNCC[nI][TIT_CONT] + "/" + aTitBXNCC[nI][TIT_PARC] + Space(12) + cMvSimb1 + Trans(aTitBXNCC[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)
	 			Else
					cNumDocumento	:= aTitBXNCC[nI][TIT_PREF] + "/" + aTitBXNCC[nI][TIT_NUME]
					nEspaco 		:= 40 - ( Len ( cNumDocumento ) + Len ( cMvSimb1 ) + Len ( aTitBXNCC[nI][TIT_PARC] ) + 15  )
					cMsgComprovante += cNumDocumento + "/" + aTitBXNCC[nI][TIT_PARC] + Space( nEspaco ) + cMvSimb1 + Trans(aTitBXNCC[nI][TIT_RECE],"@E 999,999,999.99") + Chr(10)
				EndIf

				nTotComprovante += aTitBXNCC[nI][TIT_RECE]

				If SuperGetMV( "MV_CRDAUT", NIL, .T. ) .AND. !LJModNFis()
				    //"Autenticação do documento", "Insira o ", "o. documento, no valor de "
				    //" para autenticacäo...", "Autenticar", "Ignorar"
					nCntTit++
					If Aviso(STR0046, STR0047+AllTrim(Str(nCntTit))+STR0048+cSimbCor+" "+;
						AllTrim(Transform(aTitBXNCC[nI][TIT_RECE], PesqPict("SE1", "E1_VALOR", 15)))+;
						STR0049, {STR0050, STR0051}) == 1
						IFAutentic( nHdlECF, "2", "", "")
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nI

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJXREC   ºAutor  ³Microsiga           º Data ³  09/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJXESTORNA(nValor, cSeq)
Local nY			:= 1
Local aCopiaSE5		:= {}
Local aCpySE5		:= {}
Local aAreaSE5		:= SE5->( GetArea() )
Local cLote			:= SE5->E5_LOTE
Local lLjRecEst		:= ExistFunc("U_LJRECEST")
Local cCampo		:= ""
Local lGestao       := FWSizeFilial() > 2
Local lSe1Exc       := lGestao .And. FWModeAccess("SE1",3) == "E"

DEFAULT nValor		:= NIL
DEFAULT cSeq		:= IIf( FieldPos( "E5_SEQ" )>0, Space(TamSX3("E5_SEQ")[1]), Space(2) )

If AllTrim(SE5->E5_TIPODOC) $ "VL" .OR. AllTrim(SE5->E5_TIPODOC) $ "BA"

	//Se Gestão de Empresas e não for tabela SE1 totalmente exclusiva, e por algum motivo não gravar "C" em E5_SITUACA quando acontece estorno do título criada em outra filial
	If (lGestao .AND. !lSE1Exc) .AND. AllTrim(SE5->E5_TIPODOC) $ "BA" .AND. SE5->E5_SITUACA <> "C"
		RecLock("SE5", .F.)
		REPLACE SE5->E5_SITUACA WITH "C"
		SE5->(MsUnlock())
	EndIf

	For nY := 1 to FCount()
		cCampo :=  RTrim(FieldName(nY))
		If !Upper(cCampo) $ "E5_IDORIG\E5_MOVFKS\E5_TABORI"
	   		aadd(aCopiaSE5, { cCampo , SE5->&(cCampo)  } )
	   	EndIf
	Next nY

	aCpySE5 := aClone(aCopiaSE5)

	RecLock("SE5" , .T.)

	For nY := 1 To Len(aCopiaSE5)
		If Upper(aCopiaSE5[nY][1]) 		== "E5_TIPODOC"
			aCopiaSE5[nY][2] 			:= "ES"

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_FILIAL"
			aCopiaSE5[nY][2] 			:= xFilial("SE5")

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_MOEDA"
			aCopiaSE5[nY][2] 			:= ""

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_RECPAG"
			aCopiaSE5[nY][2] 			:= "P"

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_HISTOR"
			aCopiaSE5[nY][2]			:= IIf( Empty(cLote), STR0120, STR0121+cLote ) // Cancelamento de baixa###"Canc Baixa Lote "

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_MOTBX"
			aCopiaSE5[nY][2]			:= IIf( LjxDMoney( "SE5", SE5->E5_MOEDA, NIL), "NOR", "LOJ" )

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_DATA"
			aCopiaSE5[nY][2]			:= 	dDataBase

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_VALOR"
			If !Empty(nValor)
				aCopiaSE5[nY][2]		:= 	nValor
			EndIf

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_SEQ"
			If !Empty(cSeq)
				aCopiaSE5[nY][2]		:= cSeq
			EndIf

		ElseIf Upper(aCopiaSE5[nY][1]) == "E5_SITUACA"
			aCopiaSE5[nY][2]			:= 	"C"

		EndIf

		Replace &("SE5->" + aCopiaSE5[nY][1]) WITH aCopiaSE5[nY][2]

	Next nY
	If Empty(SE5->E5_KEY)
		Replace SE5->E5_KEY With SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIENTE+E5_LOJA)
	EndIf
	
	SE5->(MsUnlock())
EndIf

//Gera FKs com base na SE5 gerada
FINXSE5( SE5->( Recno() ) , 1 )	//Movimento Bancario

//Compatibiliza as Fks com padrao do loja
LjCompFKs()

If lLjRecEst
   U_LJRECEST( aCopiaSE5 )
EndIf

RestArea(aAreaSE5)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGetModOrºAutor  ³Vendas e Crm        º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o cod do modulo origem para ser usado em Web Serviceº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATXATU													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGetModOr()
Return(nModOrigem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGetLjRecºAutor  ³Vendas e Crm        º Data ³  11/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se esta sendo feito um recebimento de titulo        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATXATU													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjGetLjRec()
Return(lLojxRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjLimpaTitºAutor  ³Vendas e Crm        º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa controle de acesso aos registros de titulos a receber.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Sigaloja com Venda Assistida								  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjLimpaTit(lTelaOk)
	Local nCont  := 0 	// Contador
	Local cChave := ""

	If !lTelaOk //Se nao confirmou o recebimento dos titulos selecionados, limpa (semaforo) controle de acesso aos registros de titulos a receber
		cNomeCli := ''
		oNomeCli:Refresh()
		For nCont := 1 To Len(oTitulo:AARRAY)
			If Len(oTitulo:AARRAY[nCont]) >= TIT_LOCK
				cChave := oTitulo:AARRAY[nCont][TIT_LOCK]
				If !Empty(cChave)
					UnLockByName(cChave, .T., .F., .T.)
					If nModulo == 23
						LjRecUnChk()
					EndIf
				EndIf
			EndIf
		Next
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGrvSEL  ºAutor  ³Microsiga           º Data ³  06/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Como e chamado de varias vezes para chamar uma vez so       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjxGrvSEL( aTitulo, lGrvPgtos )

Local nX		:= 0
Local nTroco	:= 0
Local nTrocoLoc	:= 0

DEFAULT	lGrvPgtos 	:= .F.

If cPaisLoc <> "BRA"
	For nX := 1 to Len(aTitulo)
		If  aTitulo[nX][TIT_SELE]
			SE1->(DBGoTo(aTitulo[nX][TIT_RECN]))

			SEL->( RecLock("SEL", .T.) )
			SEL->EL_FILIAL		:= xFilial("SEL")
			SEL->EL_TIPODOC		:= "TB"
			SEL->EL_PREFIXO		:= SE1->E1_PREFIXO
			SEL->EL_NUMERO		:= SE1->E1_NUM
			SEL->EL_PARCELA		:= SE1->E1_PARCELA
			SEL->EL_TIPO		:= AllTrim(SE1->E1_TIPO)
			SEL->EL_BCOCHQ		:= SE1->E1_BCOCHQ
			SEL->EL_AGECHQ		:= SE1->E1_AGECHQ
			SEL->EL_CTACHQ		:= SE1->E1_CTACHQ
			SEL->EL_EMISSAO		:= SE1->E1_EMISSAO
			SEL->EL_DTDIGIT		:= SE1->E1_MOVIMEN
			SEL->EL_DTVCTO		:= SE1->E1_VENCTO
			SEL->EL_EMISREC		:= SE1->E1_MOVIMEN
			SEL->EL_NATUREZ		:= SE1->E1_NATUREZ
			SEL->EL_MOEDA		:= STRZERO(SE1->E1_MOEDA,2)
			SEL->EL_VLMOED1		:= aTitulo[nX][TIT_RECE]
			SEL->EL_DESCONT		:= aTitulo[nX][TIT_DESC]

			If SEL->(FieldPos("EL_MULTA")) > 0
				SEL->EL_MULTA	:= aTitulo[nX][TIT_MULT]
			EndIf

			If SEL->(FieldPos("EL_JUROS")) > 0
			   SEL->EL_JUROS	:=  aTitulo[nX][TIT_JURO]
			EndIf

			SEL->EL_VALOR		:= aTitulo[nX][TIT_RECE]
			SEL->EL_CLIENTE		:= SE1->E1_CLIENTE
			SEL->EL_LOJA		:= SE1->E1_LOJA
			SEL->EL_SERIE		:= cSerieRec
			SEL->EL_RECIBO		:= LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)
			SEL->EL_CLIORIG		:= aTitulo[nX][TIT_CLIE]
			SEL->EL_LOJORIG		:= aTitulo[nX][TIT_LOJA]

			SEL->( MsUnlock() )
		EndIf
	Next nX

	If lGrvPgtos
		For nX := 1 to Len(aPgtos)

			If IsMoney(aPgtos[nX][3]) .AND. nTroco == 0
				If aPgtos[nX][6] > 1
					nTrocoLoc := xMoeda(Lj7T_Troco(2), 1, aPgtos[nX][6], dDataBase, 3)
					nTroco := Lj7T_Troco(2)
					nTaxa := &("SM2->M2_MOEDA"+AllTrim(Str(aPgtos[nX][6])))
				Else
					nTroco := Lj7T_Troco(2)
				EndIf
			Else
				nTroco := 0
			EndIf

			SEL->( RecLock("SEL",.T.) )
			SEL->EL_FILIAL		:= xFilial("SEL")
			SEL->EL_TIPODOC		:= AllTrim( aPgtos[nX][3] )
			SEL->EL_PREFIXO		:= SE1->E1_PREFIXO
			SEL->EL_NUMERO		:= SE1->E1_NUM
			SEL->EL_PARCELA		:= SE1->E1_PARCELA
			SEL->EL_TIPO		:= AllTrim( aPgtos[nX][3] )
			SEL->EL_BCOCHQ		:= SE1->E1_BCOCHQ
			SEL->EL_AGECHQ		:= SE1->E1_AGECHQ
			SEL->EL_CTACHQ		:= SE1->E1_CTACHQ
			SEL->EL_EMISSAO		:= SE1->E1_EMISSAO
			SEL->EL_EMISREC		:= dDataBase
			SEL->EL_DTDIGIT		:= dDataBase
			SEL->EL_DTVCTO		:= SE1->E1_VENCTO
			SEL->EL_NATUREZ		:= SE1->E1_NATUREZ
			SEL->EL_MOEDA		:= STRZERO(SE1->E1_MOEDA,2)
			If aPgtos[nX][6] > 1
				SEL->EL_VLMOED1		:= IIf( IsMoney(aPgtos[nX][3]), aPgtos[nX][10]-nTroco, aPgtos[nX][2] )
			Else
				SEL->EL_VLMOED1		:= IIf( IsMoney(aPgtos[nX][3]), aPgtos[nX][2]-nTroco, aPgtos[nX][2] )
			EndIf
			SEL->EL_DESCONT		:= SE1->E1_DESCONT

			If SEL->(FieldPos("EL_MULTA")) > 0
				SEL->EL_MULTA	:= SE1->E1_MULTA
			EndIf

			If SEL->(FieldPos("EL_JUROS")) > 0
				SEL->EL_JUROS	:= SE1->E1_VALJUR
			EndIf

			If aPgtos[nX][6] > 1
				SEL->EL_VALOR		:= IIf( IsMoney(aPgtos[nX][3]), aPgtos[nX][2]-nTrocoLoc, aPgtos[nX][2] )
			Else
				SEL->EL_VALOR		:= IIf( IsMoney(aPgtos[nX][3]), aPgtos[nX][2]-nTroco, aPgtos[nX][2] )
			EndIf
			SEL->EL_CLIENTE		:= SE1->E1_CLIENTE
			SEL->EL_LOJA		:= SE1->E1_LOJA
			SEL->EL_SERIE		:= cSerieRec
			SEL->EL_RECIBO		:= LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)
			SEL->EL_CLIORIG		:= aTitulo[nX][TIT_CLIE]
			SEL->EL_LOJORIG		:= aTitulo[nX][TIT_LOJA]

			If aPgtos[nX][6] > 1
				&("SEL->EL_TXMOE0"+AllTrim(Str(aPgtos[nX][6]))) := nTaxa
			EndIf

			SEL->( MsUnlock() )
		Next nX
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LojxNxtRecºAutor  ³Microsiga           º Data ³  06/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retornar o numero do proximo recibo por nr de PDV           º±±
±±º          ³Faz a busca no SEL                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LojxNxtRec()

Local cNextRec := ""
Local cNumrPdv := LjGetStation("LG_PDV")

SEL->( DBSetOrder(8) )
SEL->( DBSeek(xFilial("SEL") + "X  " + cNumrPdv + Replicate("Z", TamSx3("EL_RECIBO")[1]-4), .T. ) )
SEL->( DBSkip(-1) )

cNextRec:= cNumrPdv + StrZero( Val(Substr(SEL->EL_RECIBO,5,8))+ 1 , 8 )

Return( cNextRec )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxGrvSFE ºAutor  ³Microsiga           º Data ³  22/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a tabela SFE (Retencoes)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjxGrvSFE()

Local nX		:= 0
Local cMvTpRet	:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS")

For nX := 1 to Len(aPgtos)
	If Alltrim(aPgtos[nX][3]) $ cMvTpRet
	   Do Case
			Case IsMoney(aPgtos[nX][3])					// Dinheiro
				 cTipPgtoEx := AllTrim(aPgtos[nX][3])
				 cTipoDocEx := "TB"
			Case AllTrim(aPgtos[nX][3]) == "CH"		// Cheque
			     cTipPgtoEx := AllTrim(aPgtos[nX][3])
			     cTipoDocEx := AllTrim(aPgtos[nX][3])
			Case (AllTrim(aPgtos[nX][3]) $"CC|CD|VA|CO") .OR. ( Alltrim(aPgtos[nX][3]) $ cMvTpRet )
				 cTipPgtoEx := AllTrim(aPgtos[nX][3])
			     cTipoDocEx := AllTrim(aPgtos[nX][3])
	    EndCase

	   If SFE->( !DbSeek(xFilial("SFE") + IIf( !EMPTY( aPgtos[NX][4]), aPgtos[nx][4][4], "" ) ) )
	      RecLock("SFE", .T.)
	      SFE->FE_FILIAL	:= xFilial("SFE")
	      SFE->FE_NROCERT	:= aPgtos[nX][4][4]								// Número do certificado
	      SFE->FE_EMISSAO	:= dDataBase										// Data da operacao
	      SFE->FE_CLIENTE	:= M->LQ_CLIENTE									// Cliente
	      SFE->FE_LOJCLI	:= M->LQ_LOJA										// Loja
	      SFE->FE_TIPO		:= Substr(aPgtos[nX][3],2,1)						// B(Ingresos Brutos); I(IVA); S(SUSS); G(Ganancias)
	      SFE->FE_RECIBO	:= LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)	// Numero do recibo
	      SFE->FE_NFISCAL	:= SE1->E1_NUM										// Numero do titulo do SE1
	      SFE->FE_PARCELA	:= SE1->E1_PARCELA
	      SFE->FE_RETENC	:= (aPgtos[nX][2] - ((aPgtos[nX][2] * IIf(!Empty(SAE->AE_TAXA), SAE->AE_TAXA , 0	)) /100) )	// Valor da retencao
	      SFE->( MsUnlock() )
	   Endif
	EndIf
Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxGrvSEF ºAutor  ³Microsiga           º Data ³  22/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a tabela SFE (Retencoes)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjLogRec( cFunc, cSerieRec, cRecibo, cCliente, cLoja, nTotComprovante )
Local lRet		:= .T.
Local cLogPath	:= "\AUTOCOM\TEF"+cEmpAnt+cFilAnt+"\"
Local aLog		:= {}

MsgAlert( STR0137 )
lRet := MsgYesNo( STR0138 )
aadd(aLog, cFunc + " - INÍCIO" )
aadd(aLog, STR0139 + cUserName )
aadd(aLog, STR0055 + cCliente)
aadd(aLog, STR0140 + cLoja)
aadd(aLog, STR0123 + ": " + cSerieRec)
aadd(aLog, STR0124 + ": " + cRecibo)
aadd(aLog, STR0065 + ": " + Alltrim( Str(nTotComprovante,12,4)))
aadd(aLog, STR0138)
aadd(aLog, IIf(lRet, STR0073, STR0074))
aadd(aLog, cFunc + " - FIM")
LjWriteLog(cLogPath + cSerieRec + cRecibo + '.TXT', aLog)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³LjLockTit	³ Autor ³ Vendas e CRM          ³ Data ³15/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera um arquivo de controle, quando um titulo for 		  |±±
±±³			 | selecionado											      |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LjLockTit WSRECEIVE cChave, cNumPdv WSSEND lRet WSSERVICE LJReceb

Local nHandle 	 := 0
Local cDirArqRec := "" // Diretorio onde sao criados os arquivos de controle de semaforo de recebimento de titulos
Local cBuffer    := ""
Local cHoraAtual := ""
Local cArqHora	 := ""
Local cArqMin	 := ""
Local cArqPdv	 := ""
Local nTimeDif   := 15 // Tempo (em minutos) de tolerancia permitido para que outro PDV possa selecionar o mesmo titulo, devido arquivo de semaforo ter sido criado na retaguarda e nao ter sido excluido caso a conexao tenha caido
Local cConteudAq := "" // Conteudo a ser gravado no arquivo
Local nTamArqv   := 0  // Tamanho do conteudo do arquivo se semaforo
Local cNomeArq 	 := "" // Nome do arquivo para controle de semaforo

If !ExistDir(PATH)
	MakeDir(PATH)
EndIf

LjSemafRec(Nil,@cDirArqRec,cChave,cNumPdv,@nTamArqv,@cConteudAq,@cNomeArq)

If !ExistDir(cDirArqRec)
	MakeDir(cDirArqRec)
EndIf

//Verifica se o arquivo existe
If !FILE(cNomeArq)
	nHandle := FCREATE(cNomeArq)

	If nHandle < 0
		SetSoapFault(STR0149 + CVALTOCHAR(FERROR()), STR0150) //"Erro: " | "Para maiores detalhes, consulte no portal do TDN o tópico sobre a função: FError"
		::lRet := .F.
	Else
		::lRet := .T.
		FWrite(nHandle, cConteudAq)
		FClose(nHandle)
	EndIf
Else
	If ( nHandle := FOpen( cNomeArq, FO_READWRITE ) ) > 0

		FRead(nHandle, @cBuffer, nTamArqv)

		cArqHora := SubStr(cBuffer,1,2)
		cArqMin  := SubStr(cBuffer,4,2)
		cArqPdv	 := SubStr(cBuffer,9,10)

		If cNumPdv <> AllTrim(cArqPdv)
			cHoraAtual := Time()

			//Se a diferenca de tempo for maior que "nTimeDif", permite outro PDV selecionar o titulo
			If ( Val(SubStr(cHoraAtual,1,2)+SubStr(cHoraAtual,4,2)) - Val(cArqHora+cArqMin) ) > nTimeDif
				FSEEK(nHandle, 0) //Posiciona no inicio do arquivo
				FWrite(nHandle, cConteudAq) //Substitui o conteudo do arquivo, com informacao do PDV atual
				::lRet := .T.
			Else
				::lRet := .F.
			EndIf
		Else
			FSEEK(nHandle, 0) //Posiciona no inicio do arquivo
			FWrite(nHandle, cConteudAq) //Atualiza o conteudo do arquivo, com informacao da hora atual
			::lRet := .T.
		EndIf
		FClose(nHandle)
	Else
		::lRet := .F.
	EndIf
Endif

Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³ LjDelTit	³ Autor ³ Vendas e CRM          ³ Data ³15/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Deleta o arquivo utilizado no controle de selecao dos	  ³±±
±±³			 | titulos de recebimento.									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD LjDelTit WSRECEIVE cChave, cNumPdv WSSEND lRet WSSERVICE LJReceb

Local nHandle	 := 0
Local cBuffer  	 := ""
Local cArqPdv	 := ""
Local nTamArqv   := 0  //Tamanho do conteudo do arquivo se semaforo
Local cNomeArq 	 := "" //Nome do arquivo para controle de semaforo

LjSemafRec(Nil,Nil,cChave,cNumPdv,@nTamArqv,Nil,@cNomeArq)

If FILE(cNomeArq)
	If ( nHandle := FOpen( cNomeArq, FO_READ ) ) > 0

		FRead(nHandle, @cBuffer, nTamArqv)
		FClose(nHandle)

		cArqPdv	 := SubStr(cBuffer,9,10)

		If cNumPdv == AllTrim(cArqPdv) //Apaga o arquivo se o PDV em questao eh o responsavel atual pelo Lock no titulo em questao
			nHandle := FERASE(cNomeArq)
			If nHandle > -1
				::lRet := .T.
			Else
				SetSoapFault(STR0149 + CVALTOCHAR(FERROR()), STR0150) //"Erro: " | "Para maiores detalhes, consulte no portal do TDN o tópico sobre a função: FError"
				::lRet := .F.
			EndIf
		Else
			::lRet := .T.
		EndIf

	EndIf
Else
	::lRet := .T.
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³GravaTabSLV³ Autor ³ Vendas e CRM          ³ Data ³21/11/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava registro na tabela SLV referente a Transacao TEF na   ³±±
±±³			 | baixa de Recebimento de titulos.	      					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD GravaTabSLV WSRECEIVE EmpPdv, FilPdv, MvLjPdvPa, aDadosSLV WSSEND lRet WSSERVICE LJReceb
Local nY 		:= 0
Local aSE5Dados := {}
Local nRecSE5 	:= 0
Local lDocCan	:= .F.
Local lDocCTEF	:= .F.
Local lAttBand 	:= .F.
Local lAttRede 	:= .F.

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao
LjPreparaWs(::EmpPdv,::FilPdv)

dbSelectArea("SE5")

//Armazena os dados da estrutura aDadosSLV no array aSE5Dados
For nY:=1 To Len(aDadosSLV:VERARRAY)
	//Posiciona no registro da tabela SE5
	nRecSE5 := aDadosSLV:VERARRAY[nY]:RECSE5
	SE5->(DbGoTo(nRecSE5))

	lAttBand := AttIsMemberOf(aDadosSLV:VERARRAY[nY], "BANDEIRA") 	//Verifica a existência do Atributo BANDEIRA no objeto
	lAttRede := AttIsMemberOf(aDadosSLV:VERARRAY[nY], "REDEAUT") 	//Verifica a existência do Atributo REDEAUT no objeto

	AADD(aSE5Dados,	{	SE5->E5_PREFIXO			  		, ;	//01-E5_PREFIXO
						SE5->E5_NUMERO 					, ;	//02-E5_NUMERO
						SE5->E5_PARCELA					, ;	//03-E5_PARCELA
						SE5->E5_TIPO					, ;	//04-E5_TIPO
						SE5->E5_SEQ						, ;	//05-E5_SEQ
						SE5->E5_FILORIG					, ;	//06-E5_FILORIG
						SE5->E5_CLIENTE					, ;	//07-E5_CLIENTE
						SE5->E5_LOJA					, ;	//08-E5_LOJA
						aDadosSLV:VERARRAY[nY]:FORMA	, ;	//09-Forma Pgto.
						aDadosSLV:VERARRAY[nY]:VALOR	, ;	//10-Valor
						aDadosSLV:VERARRAY[nY]:DATATEF	, ; //11-Data
						aDadosSLV:VERARRAY[nY]:HORATEF 	, ; //12-Hora
						aDadosSLV:VERARRAY[nY]:DOCTEF  	, ; //13-Doc
						aDadosSLV:VERARRAY[nY]:AUTORIZ  , ; //14-Autorizacao
						aDadosSLV:VERARRAY[nY]:INSTITU  , ; //15-Instituicao
						aDadosSLV:VERARRAY[nY]:NSUTEF  	, ; //16-NSU
						aDadosSLV:VERARRAY[nY]:TIPCART  , ; //17-Tipo do cartao
						aDadosSLV:VERARRAY[nY]:SEQOPER 	, ; //18-SEQOPER
						aDadosSLV:VERARRAY[nY]:RECSE5	, ; //19-RECSE5 - Recno do registro SE5
						aDadosSLV:VERARRAY[nY]:DOCCANC  , ; //20-Doc Cancelamento TEF
						aDadosSLV:VERARRAY[nY]:HORCANC 	, ; //21-Hora Cancelamento TEF
						aDadosSLV:VERARRAY[nY]:DATCANC  , ; //22-Data Cancelamento TEF
						iIf(lAttBand,aDadosSLV:VERARRAY[nY]:BANDEIRA,""),; 	//23-Código da Bandeira
						iIf(lAttRede,aDadosSLV:VERARRAY[nY]:REDEAUT,"")	}) 	//24-Código Rede (Adquirência)

	// Verifica se tem cancelamento TEF					
	If !lDocCan .And. (aDadosSLV:VERARRAY[nY]:CANTEF)
		lDocCan := .T.
	EndIf
	If lDocCan .And. !Empty(aDadosSLV:VERARRAY[nY]:DOCCANC)
		lDocCTEF := .T.
	EndIf
	
Next nY

If lDocCan .And. lDocCTEF
	LJXGrvSLV( "C", aSE5Dados,,,,.T.,,.T., .F. ) // Cancelamento TEF - SLV
ElseIf lDocCan
	LJXGrvSLV( "C", aSE5Dados,,,,.T.,,.T., .T. ) // Cancelamento TEF - SLV
ElseIf !LJXGrvSLV( "I", aSE5Dados )
	SetSoapFault("Erro LJXGrvSLV", "Erro LJXGrvSLV") // Inclusão TEF - SLV
	Return(.F.)
EndIf

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRecUnChkºAutor  ³Vendas e CRM        º Data ³  20/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apaga o(s) titulo(s) selecionados quando o recebimento for  º±±
±±º          ³cancelado pelo operador.                                    º±±
±±º          |                         									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXREC | FRTA271E                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjRecUnChk()

Local nI 		:= 0
Local lRet 		:= .T.
Local cSvcError := "" 	// Armazena a mensagem de Erro do WebService
Local cNumPdv 	:= ""  	// Numero do PDV

If nModulo == 23 .AND. ValType(oSvc) <> "U"
	cNumPdv := LjGetStation("LG_PDV") // Numero do PDV
	For nI := 1 to Len(aTitulo)
		If aTitulo[nI][TIT_SELE]
			aTitulo[nI][TIT_SELE] := .F. //Tira a Marca de selecao do Titulo
			If Empty(cSvcError)
				oSvc:LjDelTit(aTitulo[nI][TIT_LOCK],cNumPdv)
				cSvcError := GetWSCError()
				If oSvc:lLjDelTitResult
					lRet := .T.
				Else
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next nI
Else
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³LjDelArqs ³ Autor ³ Vendas e CRM          ³ Data ³14/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Apaga arquivos de controle de semaforo de titulos           ³±±
±±³          ³selecionados em outros recebimentos que ja foram realizados.³±±
±±³          ³Esse controle foi implementado para evitar acumulo de       ³±±
±±³          ³arquivos "lixo" no diretorio do Protheus (RETAGUARDA).  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJXREC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjDelArqs()
Local nHandle	 := 0
Local cDirArqOld := "" 	// Diretorio onde ficam os arquivos de controle de semaforo de recebimento de titulos
Local aFilesRec  := {}
Local nInd  	 := 0
Local cArqv  	 := ""
Local nNumDias   := 30 	// Numero de dias retroativos para verificar arquivos de controle de semaforo a serem excluidos
Local nCont		 := 1
Local lReturn  	 := .T.
Local cExtenArq  := "" 	// Extencao do Arquivo de semaforo

LjSemafRec( @cExtenArq )

While nCont <= nNumDias

	cDirArqOld := PATH + DIRARQPFX + DtoS(dDataBase - nCont) + "\"

	If ExistDir( cDirArqOld )

		//Verifica se existem arquivos no diretorio
		aFilesRec  := Directory(cDirArqOld + "*" + cExtenArq)

		For nInd:=1 to len(aFilesRec)
			cArqv := cDirArqOld + aFilesRec[nInd][1]

			nHandle := FERASE(cArqv)
			If nHandle == -1
				lReturn := .F.
			EndIf

		Next nInd

		If lReturn
			//Remove o diretorio da data em questao
			If DirRemove( cDirArqOld )
				lReturn := .T.
			Else
				lReturn := .F.
				Exit
			EndIf
		Else
			Exit
		Endif

	Endif

	nCont++
End

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³LjSemafRec³ Autor ³ Vendas e CRM          ³ Data ³15/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Atribui valor padrao nas variaveis passadas como referencia ³±±
±±³          ³no controle controle de semaforo de recebimento de titulo.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJXREC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjSemafRec(cExtensArq,cDirArqRec,cChvArq,cNumPdv,nTamArqv,cConteudAq,cNomeArq)

Default cConteudAq := ""

//Extencao do Arquivo de semaforo
cExtensArq := ".txt"

//Diretorio onde sera controlado o Semaforo dos titulos selecionados no recebimento de titulo
cDirArqRec := PATH + DIRARQPFX + DtoS(dDataBase) + "\"

//Conteudo a ser gravado no arquivo
If !Empty(cNumPdv)
	cConteudAq := Time()+cNumPdv
EndIf

//Tamanho do conteudo a ser gravado no Arquivo de semaforo de recebimento de titulos
nTamArqv := Max( Len(cConteudAq), Len(Time())+TamSx3("LG_PDV")[1] )

//Nome do arquivo para controle de semaforo
If !Empty(cChvArq)
	cNomeArq := cDirArqRec + cChvArq + cExtensArq
EndIf

Return Nil

//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Inicio
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LojxDAtrasºAutor  ³Microsiga           º Data ³  26/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retornar o número de dias de atraso do título               º±±
±±º          ³                                          º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LojxDAtras(ExprD1, ExprN1, ExprA1, ExprL1, ExprA2)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExprD1: Data Base                                          ³±±
±±³       	 ³ ExprN1: Numero de Dias de Atraso                           ³±±
±±³       	 ³ ExprA1: Feriados                                           ³±±
±±³       	 ³ ExprL1: Baixa Parcial                                      ³±±
±±³       	 ³ ExprL2: Calculo de Juros e Multa do Financeiro?            ³±±
±±³       	 ³ ExprC1: Conta Finais de semana                             ³±±
±±³       	 ³ ExprC2: Prefixo do título                                  ³±±
±±³       	 ³ ExprC3: Numero do título                                   ³±±
±±³       	 ³ ExprC4: Parcela do título                                  ³±±
±±³       	 ³ ExprC5: Cliente do título                                  ³±±
±±³       	 ³ ExprC6: Loja do Cliente do título                          ³±±
±±³       	 ³ ExprC7: Alias da WorkArea do Título (posicionada)          ³±±
±±³       	 ³ ExprD1: Data de Vencimento Real                            ³±±
±±³       	 ³ ExprD2: Data de Vencimento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LojxDAtras (	dDataRef,	nDias,		aFeriados,	lBxParcial,;
						lCalcFin ,	cUsaFDS   , cPrefixo,	cNumero, ;
						cParcela, 	cTipo,		cCliente,	cLoja,;
						dDtVencRea, dDtVenc)

Local aArea := GetArea()									//WorkArea Ativa
Local aSE5 := SE5->(GetArea())                              //WorkArea do SE5
Local lCalcLoja := .T.                                      //Calcula Juros, conforme regra do Loja?
Local lMV_LJCALJM   := SuperGetMV("MV_LJCALJM", NIL, .F.)	//Calcula Juros, conforme o financeiro
Local dBase := Ctod("")										//Data de cálculo
Local cMvJurTipo := SuperGetMv("MV_JURTIPO",,"")            //tipo de Calculo de Juros do Financeiro
Local lMvMulLoj	 := SuperGetMV("MV_LJINTFS", ,.F.)          //Calcula multa pelo Loja
Local nTolerDias := SuperGetMV("MV_TOLER", , 0)				//Tolerancia para calculo do juros

Default lBxParcial := .f.
Default nDias := 0
Default dDataRef := dDataBase
Default lCalcFin := SuperGetMV("MV_LJJUFIN",,.F. )
Default cUsaFDS  := SuperGetMV("MV_LJFSEMA", NIL, "0")

Default cPrefixo  := ""
Default cNumero := ""
Default cParcela := ""
Default cTipo := ""
Default cCliente := ""
Default cLoja:= ""

If aFeriados == Nil
	aFeriados := RetFeriados()
EndIf

lCalcLoja := !lCalcFin .OR. cMvJurTipo == "L" .OR. lMvMulLoj //Incluída a regra de calculo do parâmeto

If lCalcLoja //.OR. cMvJurTipo == "L"
	If !Empty(cPrefixo + cNumero + cParcela+ cTipo+ cCliente+ cLoja)
		DbSelectArea( "SE5" )
		DbSetOrder( 7 )
		If DbSeek( xFilial( "SE5" ) + cPrefixo  + cNumero +;
					 cParcela + cTipo + cCliente  + cLoja)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura todas as baixas e toma como referencia a ultima.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !Eof() .AND. xFilial( "SE5" ) == SE5->E5_FILIAL .AND.;
					cPrefixo == SE5->E5_PREFIXO .AND. cNumero == SE5->E5_NUMERO .AND.;
					cParcela == SE5->E5_PARCELA .AND. cTipo == SE5->E5_TIPO   .AND.;
					cCliente == SE5->E5_CLIFOR  .AND. cLoja == SE5->E5_LOJA

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica nao se tem cancelamento para este titulo.  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !TemBxCanc(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA + E5_SEQ)
					//Ajustado para não considerar lançamentos futuros, já que a função TemBxCanc não está considerando lançamento futuros
					//segundo parâmetro vazio = Falso
					dBase := If( dDtVencRea > E5_DATA,dDtVencRea,E5_DATA)
					nDias := MAX(dDataRef - dBase, 0)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Quando um titulo é oriundo de CNAB, é gerado um registro no SE5 do tipo DB (Despesa Bancária).³
					//³Esse registro do tipo DB, não poderá ser considerado como baixa parcial,						 ³
					//³caso contrário o sistema apresentará divergencias no valor da multa.	         				 ³
					//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If AllTrim(SE5->E5_SITUACA) <> "C" .AND. Empty(SE5->E5_CNABOC) 
						lBxParcial := .T.
					EndIf
				Endif
		  		DbSkip()
		    EndDo


		Endif

		If  dDtVencRea < dDataRef .OR. lMV_LJCALJM

			If !lBxParcial
				dBase := dDtVenc
				nDias := MAX(dDataRef - dBase, 0)
			Endif

			If nDias > nTolerDias

				While dBase <= dDataRef
					If cUsaFDS <> "4" .And. aScan(aFeriados,Dtos(dBase)) > 0 .AND. Dow(dBase) <> 7 .AND. Dow(dBase) <> 1
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|  Subtracao dos dias de vencimento  |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nDias--
					ElseIf Dow(dBase) == 7 .OR. Dow(dBase) == 1
						If cUsaFDS == "0"
							nDias--
						ElseIf cUsaFDS == "1" .AND. Dow(dBase) <> 7
							nDias--
						ElseIf cUsaFDS == "2" .AND. Dow(dBase) <> 1
							nDias--
						ElseIf cUsaFDS == "3" .AND. Dow(dBase) <> 7 .AND. Dow(dBase) <> 1
							nDias--
						Endif
					Endif
					dBase ++
				End
			Else
				nDias := 0
			EndIf
		EndIf

	EndIf

EndIf
RestArea(aSE5)
RestArea(aArea)

Return nDias


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LojxRJur  ºAutor  ³Microsiga           º Data ³  27/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retornar os juros do título                                 º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LojxDAtras(ExprL1, ExprL2, ExprN1, ExprN2,;                ³±±
±±³			 ³ 			  ExprN5, ExprA1)						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExprL1: Regra de cálculo do financeiro?                    ³±±
±±³       	 ³ ExprL2: Adiciona Acrescimo no Total?                       ³±±
±±³       	 ³ ExprN1: Percentual de Juros                                ³±±
±±³       	 ³ ExprN2: Dias de Atraso                                     ³±±
±±³       	 ³ ExprN3: Saldo do título                                    ³±±
±±³       	 ³ ExprN4: Acrescimo do título			                      ³±±
±±³       	 ³ ExprC1: Alias do Título                                    ³±±
±±³       	 ³ ExprN5: Recno do Título                                    ³±±
±±³       	 ³ ExprN6: Moeda título                                       ³±±
±±³       	 ³ ExprD1: Data de Referência                                 ³±±
±±³       	 ³ ExprD2: Data de Vencimento Real                            ³±±
±±³       	 ³ ExprL3: Baixa Parcial                                      ³±±
±±³       	 ³ ExprN7: Valor dos juros a ser somado  (E1_JUROS)           ³±±
±±³       	 ³ ExprL3: Considera abatimentos?                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LojxRJur(lRegraFin, lAcresVlTit, nPerJuros, nDias,;
 				 nSaldo, 	nAcrescimo, cAliasSE1,	nRecSE1,;
 				 nMoeda,	dDataRef,	dDtVencRea, lBxParcial,;
 				 nVlJuros, lAbat)

Local aArea := GetArea()				   					//WorkArea ativa
Local aAreaSE5 := SE5->(GetArea())		   					//WorkArea do SE5
Local aAreaSE1 := SE1->(GetArea())							//WorkArea do SE1
Local lCalcLoj := .T. 										//Calcula juros conforme o loja
Local nSaldoTit := 0					   					//Saldo do titulo
Local nValJuros := 0										//Valor de Juros
Local cMvJurTipo := SuperGetMV("MV_JURTIPO",,"") 			//Forma de calculo de Juros
Local lMV_LJCALJM   := SuperGetMV("MV_LJCALJM", NIL, .F.)  //Calcula Juros, conforme regra do Financeiro?
Local nVlAbat := 0						   					//Valor do Abatimento


Default lRegraFin := SuperGetMV("MV_LJJUFIN",,.F. )
Default lAcresVlTit := .T.
Default nPerJuros := SuperGetMV("MV_LJJUROS", NIL, 0)
Default nSaldo := 0
Default nAcrescimo := 0
Default cAliasSE1 := nil
Default nMoeda := 0
Default dDataRef := dDataBase
Default nVlJuros := 0
Default lAbat := SuperGetMV("MV_LJRCABT", NIL, .F.)
Default nRecSE1 := 0


If cAliasSE1 == Nil
	cAliasSE1 := "SE1"
EndIf

lCalcLoj := !lRegraFin .OR. cMvJurTipo == "L" //Incluído para calcular regra do loja

nSaldoTit :=  nSaldo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a loja trabalha com acrescimo financeiro, deve se incluir o³
//³valor do acrescimo no calculo de multas e juros. - DADALTO    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAcresVlTit
	nSaldoTit += nAcrescimo
EndIf

If lCalcLoj .OR. cMvJurTipo == "L"

	If dDtVencRea < dDataRef .OR.  lMV_LJCALJM

		If nDias == nil
			If !Empty(cAliasSE1)
			//Calculo do dias de atraso, seguindo a regra do Loja
				If nRecSE1 > 0 //Posiciona no SE1
				   (cAliasSE1)->(DbGoTo(nRecSE1))
				   nRecSE1 := 0
				EndIf
				nDias := LojxDAtras (dDataRef,		nDias,	,		@lBxParcial,;
								,	,	(cAliasSE1)->E1_PREFIXO,;
								(cAliasSE1)->E1_NUM,	(cAliasSE1)->E1_PARCELA,	(cAliasSE1)->E1_TIPO, 	(cAliasSE1)->E1_CLIENTE,;
								(cAliasSE1)->E1_LOJA,	(cAliasSE1)->E1_VENCREA ,	(cAliasSE1)->E1_VENCTO)
			Else
				nDias := 0
			EndIf

		EndIf

		If lAbat .and. !Empty(cAliasSE1) //Realiza Abatimentos?
			If nRecSE1 > 0 //Posiciona no SE1
			   (cAliasSE1)->(DbGoTo(nRecSE1))
			   nRecSE1 := 0
			EndIf

			//Calcula o Abatimento
			nVlAbat := FaAbatCR( (cAliasSe1)->E1_PREFIXO, (cAliasSe1)->E1_NUM, (cAliasSe1)->E1_PARCELA,  (cAliasSe1)->E1_MOEDA, ;
                            NIL,  (cAliasSe1)->E1_VENCTO,  (cAliasSe1)->E1_FILIAL )

			nSaldoTit -= nVlAbat
		EndIf

		nValJuros := (nSaldoTit * (nPerJuros * nDias)) / 100

		If !lBxParcial
			nValJuros += nVlJuros
		EndIf


	EndIf
Else

    If !Empty(cAliasSE1)
	    DbSelectArea(cAliasSE1)
		If nRecSE1 > 0 //Posiciona no SE1
			DbGoTo(nRecSE1)
			nValJuros := Fa070Juros(nMoeda )
		EndIf
	EndIf

EndIf

nValJuros := Round(nValJuros, 2)

RestArea(aAreaSE5)
RestArea(aAreaSE1)
RestArea(aArea)

Return  nValJuros

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LojxRMul  ºAutor  ³Microsiga           º Data ³  27/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retornar a multa de atraso do título                        º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LojxRMul( ExprL1, ExprL2, ExprN1, ExprN2,ExprN3)  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExprL1: Regra de cálculo do financeiro?                    ³±±
±±³       	 ³ ExprL2: Adiciona Acrescimo no Total?                       ³±±
±±³       	 ³ ExprN1: Percentual de Multa                                ³±±
±±³       	 ³ ExprN2: Saldo do  título                                   ³±±
±±³       	 ³ ExprN3: Valor de Acrescimo                                 ³±±
±±³       	 ³ ExprD1: Data de Vencimento Real                            ³±±
±±³       	 ³ ExprD2: Data de Pagamento                                  ³±±
±±³       	 ³ ExprL3: Baixa Parcial?                                     ³±±
±±³       	 ³ ExprN4: Valor da Multa E1_MULTA                            ³±±
±±³       	 ³ ExprL4: Abate valor?                                       ³±±
±±³       	 ³ ExprC1: Prefixo do título                                  ³±±
±±³       	 ³ ExprC2: Numero do título                                   ³±±
±±³       	 ³ ExprC3: Parcela do título                                  ³±±
±±³       	 ³ ExprC4: Cliente do título                                  ³±±
±±³       	 ³ ExprC5: Loja do Cliente do título                          ³±±
±±³       	 ³ ExprC6: Alias da WorkArea do Título (posicionada)          ³±±
±±³       	 ³ ExprL5: Chamado pelo Loja?                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LojxRMul(lRegraFin, lAcresVlTit, nPerMulta, nSaldo, ;
                  nAcrescimo, dDtVencRea, dDtPag,    lBxparcial, ;
                  nE1_Multa, lAbat,		  cPrefixo,  cNumero,;
                  cParcela,  cTipo,       cCliente,  cLoja, ;
                  cAliasSE1, lLoja)

Local aArea := GetArea() 									//WorkArea Ativa
Local lCalcLoj  := .T. 										//Calcula juros conforme o loja
Local nSaldoTit :=0    										//Saldo do titulo
Local nValMulta := 0   										//Valor da Multa
Local cMvJurTipo := SuperGetMv("MV_JURTIPO",,"")			//Tipo de calculo de Juros
Local lMV_LJCALJM   := SuperGetMV("MV_LJCALJM", NIL, .F.)  	//Calculo de Juros e Multa igual ao financeiro?
Local aAreaSE5 := nil   									//WorkArea do SE5
Local aAreaSE1 := SE1->(GetArea())    						//WorkArea do SE1
Local nValAbat := 0    										//Valor de abatimentos
Local nToleran := SuperGetMv("MV_TOLER",,0)				//Tolerancia para calculo de juros

Default lRegraFin := SuperGetMV("MV_LJJUFIN",,.F. )
Default lAcresVlTit := .T.
Default nPerMulta := SuperGetMV("MV_LJMULTA", NIL, 0)
Default nSaldo := 0
Default nAcrescimo := 0
Default dDtPag := dDataBase
Default dDtVencRea := CtoD("")
Default lBxParcial := Nil
Default nE1_Multa  := 0
Default cPrefixo := ""
Default cNumero := ""
Default cParcela := ""
Default cTipo := ""
Default cCliente := ""
Default cLoja := ""
Default lAbat := SuperGetMV("MV_LJRCABT", NIL, .F.)
Default lLoja := .f.


lCalcLoj := !lRegraFin .OR. cMvJurTipo == "L" .OR. SuperGetMv("MV_LJINTFS", ,.f.)   //Incluída a regra do financeiro


If lCalcLoj .AND. lBxParcial == Nil .AND. !Empty(cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)  //Chave do título
	//Apura se houve baixa parcial do título

	aAreaSE5 := SE5->(GetArea())
	lBxParcial := .F.
	DbSelectArea( "SE5" )
	DbSetOrder( 7 )
	If DbSeek( xFilial( "SE5" ) + cPrefixo  + cNumero + cParcela + cTipo + cCliente  + cLoja)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura todas as baixas e toma como referencia a ultima.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !Eof() .AND. xFilial( "SE5" ) == SE5->E5_FILIAL .AND.;
				cPrefixo == SE5->E5_PREFIXO .AND. cNumero == SE5->E5_NUMERO .AND.;
				cParcela == SE5->E5_PARCELA .AND. cTipo == SE5->E5_TIPO   .AND.;
				cCliente == SE5->E5_CLIFOR  .AND. cLoja == SE5->E5_LOJA

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica nao se tem cancelamento para este titulo.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE5->E5_MOTBX <> "LIQ"
				If !TemBxCanc(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA + E5_SEQ)
					lBxParcial := .T.
				Endif
	  		EndIf
	  		DbSkip()
	    EndDo
	EndIf
	RestArea(aAreaSE5)
EndIf


If lCalcLoj .and. !IsInCallStack("LjGrvTudo") //Calculo do loja ou financeiro apontando para o cálculo de loja   1

    If  (!lBxParcial .OR. lLoja)  .AND. ( (dDtVencRea + nToleran < dDtPag) .OR. lMV_LJCALJM )   //2
		nSaldoTit := nSaldo

		If lAbat
		    IF !Empty(cAliasSE1)
		    	nValAbat := FaAbatCR( (cAliasSe1)->E1_PREFIXO, (cAliasSe1)->E1_NUM, (cAliasSe1)->E1_PARCELA,  (cAliasSe1)->E1_MOEDA, ;
                            NIL,      (cAliasSe1)->E1_VENCTO,  (cAliasSe1)->E1_FILIAL )
		    Else
		       If !Empty(cPrefixo+cNumero+cParcela+cTipo)
		       		aAreaSE1 := SE1->(GetArea())
		       		SE1->(DbSetOrder(1))
		       		If  SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo))
		    			nValAbat := FaAbatCR( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,  SE1->E1_MOEDA, ;
                            		NIL,    SE1->E1_VENCTO, SE1->E1_FILIAL )
		       		EndIf
		       		RestArea(aAreaSE1)
		       EndIf
		    EndIf

			nSaldoTit -= nValAbat
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a loja trabalha com acrescimo financeiro, deve se incluir o³
		//³valor do acrescimo no calculo de multas e juros. - DADALTO    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAcresVlTit
			nSaldoTit += nAcrescimo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Só é somada a multa na primeira baixa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lBxParcial
			nE1_Multa := 0
		EndIf

	 	nValMulta	:= NoRound(( ( nSaldoTit * nPerMulta ) / 100 ), 2) += nE1_Multa

   EndIf

EndIf

RestArea(aArea)


Return  nValMulta


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LojxRVld  ºAutor  ³Microsiga           º Data ³  05/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retornar se o valor a receber e valido ou nao               º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LojxRVld(cBxRec, nDecE1Tam,	nDecE1Val, nValRec, ;		  ³±±
±±³      	 ³			nMulta, nJuros, nDescont, oValRec, ;		  	  ³±±
±±³      	 ³			oMulta, oJuros, oDescont, nValRecTit, ;		      ³±±
±±³      	 ³			nMultaTit, nJurosTit, nDescontTit)    		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExprC1: Tipo da Validação: Pergunta "2" ou Não "3"         ³±±
±±³       	 ³ ExprN1: Tamanho do campo E1_VALOR                          ³±±
±±³       	 ³ ExprN2: Decimais do campo E1_VALOR                         ³±±
±±³       	 ³ ExprN3: Valor da Multa                                     ³±±
±±³       	 ³ ExprN4: Valor dos Juros                                    ³±±
±±³       	 ³ ExprN5: Valor do Desconto                                  ³±±
±±³          ³ ExprO1: Objeto a Receber do Titulo                         ³±±
±±³       	 ³ ExprO2: Objeto da Multa  do Titulo                         ³±±
±±³       	 ³ ExprO3: Objeto dos Juros  do Titulo                        ³±±
±±³       	 ³ ExprO4: Objeto do Desconto do Titulo                       ³±±
±±³          ³ ExprN6: Valor a Receber do Titulo                          ³±±
±±³       	 ³ ExprN7: Valor da Multa  do Titulo                          ³±±
±±³       	 ³ ExprN8: Valor dos Juros  do Titulo                         ³±±
±±³       	 ³ ExprN9: Valor do Desconto do Titulo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LojxRVld(cBxRec		, nDecE1Tam	, nDecE1Val		, nValRec	,;
						 nMulta		, nJuros	, nDescont		, oValRec	,;
						 oMulta		, oJuros	, oDescont		, nValRecTit,;
						 nMultaTit	, nJurosTit	, nDescontTit 	)

Local lRet := .T.
Local nValDesc :=   IIf(nDescontTit -nDescont > 0 , nDescontTit-nDescont , 0 ) // Caso tenha desconto gravado abate o valor do nValRec

If Val(Str((nMulta + nJuros - nDescont), nDecE1Tam, nDecE1Val)) > Val(Str(nValRec, nDecE1Tam, nDecE1Val))
    If 	cBxRec == "2"

			If !MsgYesNo(STR0160 + CRLF + STR0161)//"Atenção ! O valor recebido é menor que a soma dos valores de juros, multa e desconto." ## "Deseja confirmar a baixa?"
				lRet := .F.
			EndIf

	ElseIf cBxRec == "3"

		MsgAlert(STR0160 + CRLF + STR0162)  //"Atenção ! O valor recebido é menor que a soma dos valores de juros, multa e desconto." + CRLF + "Favor modificar os valores."
		lRet := .F.

    EndIf
EndIf

//Valor recebido do titulo maior que o valor do titulo.
If lRet .And. Val(Str(nValRec - nValDesc, nDecE1Tam, nDecE1Val)) > Val(Str((nValRecTit + nMulta + nJuros + nAcres - nDescont), nDecE1Tam, nDecE1Val))
	Help(" ", 1, "VALORMAIOR")
	lRet := .F.
EndIf

If !lRet

	nValRec :=  nValRecTit
	nMulta := nMultaTit
	nJuros := nJurosTit
	nDescont := nDescontTit
	oValRec:Refresh()
	oMulta:Refresh()
	oJuros:Refresh()
	oDescont:Refresh()

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtAtuaSE1³ Autor ³ Venda Clientes        ³ Data ³01/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz a atualizacao dos campos E1_MULTA, E1_JUROS e E1_DESCON³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - E1_RECNO			      							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nil                         		      		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja / SIGALOJA										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FrtAtuaSE1(aVlrReceb, nX)

Local nRecAtuSE1 := SE1->(Recno())

LjGrvLog("Recebimento_Titulo", "Atualiza (E1_MULTA,E1_JUROS,E1_DESCONT) - FrtAtuaSE1 - RecNo antes da atualizacao(Inicio):", nRecAtuSE1 )
LjGrvLog("Recebimento_Titulo", "Atualiza (E1_MULTA,E1_JUROS,E1_DESCONT) - FrtAtuaSE1 - RecNo que sera atualizado:", aVlrReceb[nX][5] )

DbSelectArea("SE1")
DbSetOrder(1)
SE1->(DbGoto(aVlrReceb[nX][5]))

LjGrvLog("Recebimento_Titulo", "Atualiza E1_MULTA(Antes) :", SE1->E1_MULTA )
LjGrvLog("Recebimento_Titulo", "Atualiza E1_MULTA(Depois):", aVlrReceb[nX][2] )

LjGrvLog("Recebimento_Titulo", "Atualiza E1_JUROS(Antes) :", SE1->E1_JUROS)
LjGrvLog("Recebimento_Titulo", "Atualiza E1_JUROS(Depois):", aVlrReceb[nX][3] )

LjGrvLog("Recebimento_Titulo", "Atualiza E1_DESCONT(Antes) :", SE1->E1_DESCONT)
LjGrvLog("Recebimento_Titulo", "Atualiza E1_DESCONT(Depois):", aVlrReceb[nX][4] )

Reclock("SE1",.F.)
SE1->E1_MULTA		:= aVlrReceb[nX][2]
SE1->E1_JUROS		:= aVlrReceb[nX][3]
SE1->E1_DESCONT		:= aVlrReceb[nX][4]
SE1->( MsUnlock() )

// Retorna ao registro antes de iniciar atualizacao
SE1->(DbGoto(nRecAtuSE1))

LjGrvLog("Recebimento_Titulo", "Atualiza (E1_MULTA,E1_JUROS,E1_DESCONT) - FrtAtuaSE1 - (Fim)")
Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} STRecLoad()
Carrega a lista  de titulos em aberto/baixados por cliente ou titulo especifico,
sendo chamado do PDV e executado na retaguarda via compontente de comunicacao do POS
@param	cTypeOperatio	Tipo de operacao "1"-Recebimento de Titulos / "2"-Estorno do baixas
@param	aParams			Array com a lista de parametros da funcao
@author  Varejo
@version P11.8
@since   14/08/2013
@return	 aRetorno	Array com a lista de titulos
/*/
//--------------------------------------------------------
Function STRecLoad( cTypeOperation , aParams )

Local aRetorno 		:= {}	// Retorno da funcao
Local nI 			:= 0	// Contador
Local cParametros	:= ""	// Parametros

Default cTypeOperation 		:= ""
Default aParams        		:= {}

// Alterna tipo de operacao: Recebimento/Estorno
cOper := cTypeOperation

For nI := 1 To Len(aParams)
	cParametros += IIF(nI <> 1, ", ", "") + "aParams[" + AllTrim(Str(nI)) + "]"
Next nY

aRetorno := Eval(&("{|| LJRecLoad(" + cParametros + ")}"))


Return aRetorno


//--------------------------------------------------------
/*/{Protheus.doc} STReverseDropTitles()
Realiza o estorno de baixas, sendo chamado do PDV e executado na retaguarda via compontente de comunicacao do POS
@param	aListDropTitles	Array com a lista de titulos baixados que deseja estornar
@param	cCashier		Codigo do caixa
@author  Varejo
@version P11.8
@since   14/08/2013
@return	 .T.
/*/
//--------------------------------------------------------
Function STReverseDropTitles(aListDropTitles, cCashier, aMDMLote, aListTit)

Local lSemErro	:= .F.
Local nValor	:= 0
Local aVlCompEst:= {}
Local aSe5Est	:= {}
Local cErro		:= ""
Local aRetorno	:= {}

Default aListDropTitles   	:= {}
Default cCashier 			:= ""
Default aMDMLote			:= {}
Default aListTit			:= aClone(aListDropTitles)

// Alterna tipo de operacao: Recebimento/Estorno
cOper	:= "2"
aTitulo := Aclone(aListDropTitles)


LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Inicio - aListDropTitles",aListDropTitles)

LjRecCancBx(	@nValor		, lSemErro 	, @cErro		, {}	,;
				.F.			, .T.		, cCashier	, .T.	,;
				@aVlCompEst	, @aSe5Est	, aMDMLote  , aListTit)
				
LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Final  - aRetorno ",aRetorno)

aRetorno := {aVlCompEst,aSe5Est, cErro, aMDMLote, nValor}

Return aRetorno


//--------------------------------------------------------
/*/{Protheus.doc} STDropTitles()
Realiza a baixa de titulos, sendo chamado do PDV e executado na
retaguarda via compontente de comunicacao do POS

@param		aListDropTitles	Array com a lista de titulos a serem baixados
@author	Varejo
@version	P11.8
@since		14/08/2013
@return	lRetorno	.T. Quando executado com sucesso /
			.F. Quando houver falha no processo
/*/
//--------------------------------------------------------
Function STDropTitles(aListDropTitles	,aRecnoComp	,cCashier		,lTemFormaSE1		,;
						 aParamSE1			,aTitMDXSe1	,aSE5Relacao	,aMdlGrd			,;
						 cRequisicao		,lCtrlTrans	, lContingency, cTimeRec)

Local cRet			:= ""		//Retorno quando PDV Atualizado	(lCtrlTrans = .T.), para manter compatibilidade 
Local lRet			:= .F.		//Retorno quando PDV Desatualizado(lCtrlTrans = .F.), para manter compatibilidade
Local nI			:= 0	
Local bOldError	:= Nil		//Bloco de codigo realizado quando erro

//Variaveis para identificacao e validacao da baixa
Local cFilialTit	:= ""	
Local cPrefixo	:= ""
Local cNum			:= ""
Local cParcela	:= ""
Local cTipo		:= ""
Local cSaldo		:= 0
Local cCliPDV		:= "" //Cliente do Recebimento
Local cLojaPDV	:= "" //Loja do Cliente do Recebimento
Local cCPFCli		:= "" //CPF do Cliente
Local aTitulos	:= {} //Títulos Consultados
Local cMV_LJRECEB := "" //Tipo do recebimento
Local cPDV 		:= "" //PDV
Local aMovTitulos := {} //Movimento dos Títulos
Local aMovForma 	:= {} //Movimento das formas
Local nSaldoCr 	:= 0 //Saldo Credor
Local nTamDoc 	:= TamSx3("E1_NUM")[1] //Tamanho do Documento
Local cNatNcc		:= SuperGetMv("MV_NATNCC", Nil, "CREDITO") //Natureza da NCC gerada 
Local cPrefTit 	:= PadR( SuperGetMV( "MV_LJTITGR", Nil, "REC" ), TamSx3("E1_PREFIXO")[1]  ) //Prefixo do título
Local lMacroExec	:= .F. //Macroexecuta a natureza
Local nTamE1_PARCELA := TamSx3("E1_PARCELA")[1] //Tamanho do campo parcela
Local cNumTitAux	:= ""		// Alteracao para pegar numeracao SE1
Local cNumTitGer	:= ""		//Numero do título gerado
Local aSE1 		:= {} //titulo de NCC a ser gerado
Local aNumCheq 	:= {} //Array de Cheques
Local nC 			:= 0 //Contador 1
Local nX 			:= 0 //Contador 2
Local aFormas 	:= {} //Formas de pagamento do recebimento
Local cMvTpRec	:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS") //Tipo de Documento
Local aDadosSE5 	:= {} //Dados da baixa
Local dDtVencNCC 	:= Ctod("") //Data de Vencimento da NCC
Local aAreaSA6	:= {} //WorkArea do banco
Local lSemTitBx	:= .F. //Sem títulos para baixar
Local cBcoCx 		:= "" //Banco do Caixa
Local cAgCx 		:= "" //Agencia do Caixa
Local cCtaCx 		:= "" //Conta do Caixa
Local nValorRec 	:= 0 //Valor Recebido
Local nTamE1Pref	:= TamSx3("E1_PREFIXO")[1]
Local nTamE1Parc	:= TamSx3("E1_PARCELA")[1]
Local cDescTit		:= 0
Local cMultaTit		:= 0
Local cJurosTit		:= 0

Default aListDropTitles	:= {}	
Default aRecnoComp		:= {}
Default cCashier			:= ""
Default lTemFormaSE1		:= .F.							 
Default aParamSE1			:= {}			
Default aTitMDXSe1		:= {}
Default aSE5Relacao		:= {}
Default aMdlGrd			:= {}
Default cRequisicao		:= ""
Default lCtrlTrans		:= .F.		//Utilizado para manter compatibilidade entre PDV(STWReceiptTitle) e Retaguarda(LojxRec) quando rotina atualizada somente em uma das pontas. Se .T. utiliza metodo mais atual com controle de transacao
Default lContingency		:= .F. //Recebimento em contingência
Default cTimeRec			:= "" //DataHora título recebido



LjGrvLog("Recebimento_Titulo", "Inicio da Baixa")
LjGrvLog("Recebimento_Titulo", "Param: lCtrlTrans:", lCtrlTrans )
LjGrvLog("Recebimento_Titulo", "Param: cRequisicao:", cRequisicao ) 
LjGrvLog("Recebimento_Titulo", "Param: aListDropTitles(Titulos)", aListDropTitles )
LjGrvLog("Recebimento_Titulo", "Param: aRecnoComp", aRecnoComp)
LjGrvLog("Recebimento_Titulo", "Param: cCashier", cCashier)
LjGrvLog("Recebimento_Titulo", "Param: lTemFormaSE1", lTemFormaSE1)
LjGrvLog("Recebimento_Titulo", "Param: aParamSE1", aParamSE1)
LjGrvLog("Recebimento_Titulo", "Param: aTitMDXSe1", aTitMDXSe1)
LjGrvLog("Recebimento_Titulo", "Param: aSE5Relacao", aSE5Relacao)
LjGrvLog("Recebimento_Titulo", "Param: aMdlGrd", aMdlGrd)
LjGrvLog("Recebimento_Titulo", "Param: lContingency", lContingency)
LjGrvLog("Recebimento_Titulo", "Param: cRequisicao", cRequisicao)

If lContingency .AND. Len(aParamSE1) >= 21 .AND. lContingency
	//Busca em contingência habilita a busca do título
	cCliPDV		:= aParamSE1[10]
	cLojaPDV	:= aParamSE1[11]
	cCPFCli		:= aParamSE1[20] //CPF do Cliente
	cPDV 	:= aParamSE1[21]
	nI := 1
	
	cMV_LJRECEB :=  aListDropTitles[nI,01]
	cPrefixo	:= PadR(aListDropTitles[nI,02], nTamE1Pref)
	cNum		:= PadR(aListDropTitles[nI,03], nTamDoc)
	cParcela	:= PadR(aListDropTitles[nI,04], nTamE1Parc)
	nValorRec := aListDropTitles[nI,06] //Valor do título recebido
	
	
	LjGrvLog("Recebimento_Titulo", "Recebimento em contingência. CPF, Valor, Título:" +;
	cCPFCli + "," + cValToChar(nValorRec) + "," +cPrefixo+"/"+cNum+"/"+cParcela +  "Requisição: "+ cRequisicao)


	If !Empty(cPrefixo) .OR. !Empty(cNum) .OR. !Empty(cParcela)
		aTitulos := LJRecLoad( cMV_LJRECEB	, cCliPDV, cLojaPDV	, cCPFCli,;
 				    ""		, "" , cPrefixo	, cNum,;
				    cParcela 	, 0 , Ctod("") , cPDV,;
				    cCashier )
		LjGrvLog("Recebimento_Titulo", "Param: cCliPDV+cLojaPDV+cCPFCli+cPrefixo+cNum+cParcela", cCliPDV+cLojaPDV+cCPFCli+cPrefixo+cNum+cParcela)			    
		

	EndIf
	
	If Len(aTitulos) < 4  .OR. Len(aTitulos[4]) = 0
		If !Empty(cCliPDV) .OR. !Empty(cLojaPDV)
			aTitulos := LJRecLoad( cMV_LJRECEB	, cCliPDV, cLojaPDV	, cCPFCli,;
 				    					""		, "" , ""	, "",;
				    					"" 	, 0 , Ctod("") , cPDV,;
				    					cCashier )
			LjGrvLog("Recebimento_Titulo", "Param: cCliPDV+cLojaPDV+cCPFCli",cCliPDV+cLojaPDV+cCPFCli)			    

		EndIf
		
		If Len(aTitulos) < 4  .OR. Len(aTitulos[4]) = 0
			aTitulos := LJRecLoad( cMV_LJRECEB	, "", ""	, cCPFCli,;
 				    					""		, "" , ""	, "",;
				    					"" 	, 0 , Ctod("") , cPDV,;
				    					cCashier )			
			LjGrvLog("Recebimento_Titulo", "Param: cCPFCli", cCPFCli)	
		EndIf

	EndIf
	
	If Len(aTitulos) >= 4 .AND. Len(aTitulos[4]) > 0
	
		For nI := 1 To Len( aTitulos[4])
			ASize(aTitulos[4][nI], Len(aTitulos[4][nI])+1)
			AIns(aTitulos[4][nI], 1)
			aTitulos[4][nI][1] := .F.
		Next nI
		
		aSort( aTitulos[4], , , { |t1, t2| t1[TIT_VREA] < t2[TIT_VREA]} )

		aTitulos[4][1][1] := .T. //Marca o título como selecionado
		
		//Título selecionado
		aSize(aTitulos[4], 1)

		cCliPDV		:= aTitulos[4][1][TIT_CLIE]
		cLojaPDV	:= aTitulos[4][1][TIT_LOJA]
		
		LjGrvLog("Recebimento_Titulo", "Param: aTitulos", aTitulos)	
	Else
		//Não localizou títulos, então busca o código do cliente para gerar uma nCC
			//Busca o cliente pelo cnpj
		SA1->(DbSetOrder(3))
		If SA1->(DbSeek(xFilial("SA1") + cCPFCli))
			cCliPDV := SA1->A1_COD
			cLojaPDV := SA1->A1_LOJA
			
			
			cNumTitAux	:= GetNumSE1(cPrefTit)			// Alteracao para pegar numeracao SE1
			cNumTitGer	:= PadR( cNumTitAux , nTamDoc )
			cGRParc		:= StrZero( 1 , nTamE1_PARCELA)
		
			nSaldoCr := aListDropTitles[nI,06]
			aTitulos := Array(4)
			aTitulos[4] := {}
			aAdd( aTitulos[4], Array(25))
			aFill(aTitulos[4][1], 0)
			aTitulos[4][1][TIT_SELE] := .T.  		// Posicao logica.
			aTitulos[4][1][TIT_PREF] := cPrefTit	// Prefixo do titulo.
			aTitulos[4][1][TIT_NUME] :=	cNumTitGer	// Titulo.
			aTitulos[4][1][TIT_PARC] := cGRParc		// Parcela.
			aTitulos[4][1][TIT_VREA] := Ctod("") 	// Vencimento real.
			aTitulos[4][1][TIT_VALO] := nSaldoCr	// Valor.
			aTitulos[4][1][TIT_RECE] := nSaldoCr 	// Recebimento.
			aTitulos[4][1][TIT_TIPO] := ""			// Tipo.
			aTitulos[4][1][TIT_CONT] := ""			// Contrato.
			aTitulos[4][1][TIT_CLIE] :=	cCliPDV		// Cliente.
			aTitulos[4][1][TIT_LOJA] :=	cLojaPDV	// Loja.
			aTitulos[4][1][TIT_FILI] :=  ""     	// Filial.
			aTitulos[4][1][TIT_CACR] :=	.F.			// Posicao logica.
			aTitulos[4][1][TIT_VENC] := Ctod("") 	// Vencimento original.
			aTitulos[4][1][TIT_LOCK] := ""			// Cod de uso do Registro
			aTitulos[4][1][TIT_DTBX] :=	Ctod("")	// Dt. da baixa
			aTitulos[4][1][TIT_SALD] :=	nSaldoCr	// Saldo do titulo
			
			LjGrvLog("Recebimento_Titulo", "Título não localizado, sera gerado uma ncc ", cPrefTit+"/"+cNumTitGer+"/"+cGRParc )
			
			lSemTitBx := .T.
			

		Else
			cRet := "Não localizado títulos nem localizado o cliente CPF["  + cCPFCli + "]"
			LjGrvLog("Recebimento_Titulo", cRet)
			LjGrvLog("Recebimento_Titulo", "Fim da Baixa - cRet", cRet )
			LjGrvLog("Recebimento_Titulo", "Fim da Baixa - Requisicao:", cRequisicao )
			Return cRet
		EndIf

	EndIf
	
	aParamSE1[10] := cCliPDV 
	aParamSE1[11] := cLojaPDV
	
	If ExistFunc("STWRecArr")
		If Len(aParamSE1) >= 2
			For nC := 1 to Len(aParamSE1[2])
				//Posicao 9
				If aParamSE1[2][nC][3] == "CH" .AND. Len(aParamSE1[2][nC][4]) > 0 
					For nX := 1 to Len(aParamSE1[2][nC][4])
						If Len(aParamSE1[2][nC][4][nX]) >= 1 .AND. !Empty(aParamSE1[2][nC][4][nX][7])
							Aadd(aNumCheq, aParamSE1[2][nC][4][nX][7])	
						EndIf
					Next nX 
				EndIf
			Next
		EndIf
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - aNumCheq ", aNumCheq)
	
		aSE5Relacao := {}
		aMovForma := {}
		aListDropTitles := {} //Zera o array de títulos recebido
		aTitMDXSe1 := {}
		aMovTitulos := {}
		aRecnoComp[01] := {}
		//Função de tratamento do array de recebimento
		nSaldoCr := StwRecArr(aTitulos[4], @aRecnoComp[01], aMovTitulos, aRecnoComp[02], ;
				@aListDropTitles, @aSE5Relacao, aMdlGrd, aMovForma, ;
				cCashier, aNumCheq, cMV_LJRECEB, @aTitMDXSe1, ;
				.F., @cCliPDV, @cLojaPDV, NIL,;
				@aFormas, nValorRec)
				
		aParamSE1[4] := aClone(aTitMDXSe1)
				
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - Título selecionado ", aTitulos[4])		
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - saldo credor ", nSaldoCr)
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - aListDropTitles ", aListDropTitles)
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - aSE5Relacao ", aSE5Relacao)
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - aNumCheq ", aNumCheq)
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - aRecnoComp[01] ", aRecnoComp[01])
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - aParamSE1 ", aParamSE1)
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - nValorRec ", nValorREc)
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - aMovForma ", aMovForma)


		If lSemTitBx			
			aListDropTitles := {} 
			nSaldoCr := nValorRec
			nC := 0	
			For nC := 1 to Len(aMdlGrd)
				aAdd(aFormas,{	aMdlGrd[nC, 09]				,; // 9 Forma de pagamento
								aMdlGrd[nC, 10]				,; //10 Valor da forma de pagamento
								aMdlGrd[nC, 01]})		
									
			Next nC
		EndIf
	EndIf
	
EndIf

If lCtrlTrans

	If InTransaction()
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Iniciou processo com Transacao em aberto")
	EndIf
	
	SetAbendlock(.T.)	//Retornar erro em caso de falha no RecLock 
	
	bOldError := ErrorBlock( {|x| LjVerifErro(x,aListDropTitles,@cRet) } ) 
		
	Begin Transaction
	LjGrvLog("Recebimento_Titulo", "STDropTitles - Begin Transaction")

		Begin Sequence
			
			LjGrvLog("Recebimento_Titulo", "Antes de executar StartDropTit")
			lRet := StartDropTit(aListDropTitles	,aRecnoComp	,cCashier		,lTemFormaSE1	,;
									aParamSE1			,aTitMDXSe1	,aSE5Relacao	,aMdlGrd		,;
									cRequisicao		,cEmpAnt		,cFilAnt						)
									
			
			LjGrvLog("Recebimento_Titulo", "StartDropTit Retornou - lRet:",lRet)	
			
			//*** Realiza validação se a baixa foi concluida com sucesso ***//
			
			//1-Verifica se a transacao esta aberta, caso contrario retorna erro na baixa
			If lRet
				lRet := InTransaction()	//sinaliza se possui transacao aberta, controle de transacao pode falhar caso alguma rotina tenha realizado DisarmTransaction
				
				If !lRet
					LjGrvLog("Recebimento_Titulo", "StartDropTit Retornou >>>NC<<< - Nao estava com transacao aberta") //enfatiza Log quando ocorre algum problema na baixa
					cRet	:= "Nao foi possivel atualizar tabelas para a baixa de títulos (!InTransaction())"
				EndIf
			EndIf
				
			
			//2-Verifica se todos os titulos sofreram atualizacao 
			If lRet
			
				DbSelectArea("SE1")
				SE1->(DbSetOrder(1))
				
				For nI := 1 To Len(aListDropTitles)
				
					cFilialTit	:= aListDropTitles[nI,13]
					cPrefixo	:= aListDropTitles[nI,02]
					cNum		:= aListDropTitles[nI,03]
					cParcela	:= aListDropTitles[nI,04]
					cTipo		:= aListDropTitles[nI,11]
					cSaldo		:= aListDropTitles[nI,06]
					cDescTit	:= aListDropTitles[nI,09]
					cMultaTit	:= aListDropTitles[nI,07]
					cJurosTit	:= aListDropTitles[nI,08]
																			
					lRet := SE1->(DbSeek(cFilialTit + cPrefixo + cNum + cParcela + cTipo))
					LjGrvLog("Recebimento_Titulo","Processo de validacao do titulo (cFilialTit/cPrefixo/cNum/cParcela/cTipo)->("+cFilialTit+"/"+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo+") Retorno Seek SE1:",lRet)
					
					If !lRet
						LjGrvLog("Recebimento_Titulo","StartDropTit Retornou >>>NC<<< - Nao localizou o titulo para validacao")
						cRet	:= "Não localizou o Titulo Prefixo:"+cPrefixo+" Nr.:"+cNum+ " Parcela:"+cParcela+ ". Nao foi atualizado(SE1->E1_SALDO)." 				
					Else
						//Verifica se houve alteracao no saldo, sinalizando que a baixa foi realizada
						lRet := ( cSaldo + cMultaTit + cJurosTit - cDescTit ) <> SE1->E1_SALDO
						
						If !lRet
							LjGrvLog("Recebimento_Titulo","StartDropTit Retornou >>>NC<<< - Nao houve alteracao no Saldo(SE1->E1_SALDO), baixa nao foi concluida. SE1->E1_SALDO:",SE1->E1_SALDO)
							cRet	:= "Saldo do Titulo Prefixo:"+cPrefixo+" Nr.:"+cNum+ " Parcela:"+cParcela+ ". Nao foi atualizado(SE1->E1_SALDO)." 	
						EndIf 	
					EndIf				
					
					If !lRet							
						Break
					EndIf
					 
				Next nI				

			EndIf		
			
			lMacroExec := .T.
			If lContingency .AND. lRet .AND. nSaldoCr > 0
			
				//Gera uma NCC para o cliente
				If ValType(cNatNcc) == "C" .And. !Empty(AllTrim(cNatNcc))
				
					cNatNcc	:= AllTrim(cNatNcc)
					If SubStr(cNatNcc,1,1) == "&"
						xRet := SubStr(cNatNcc,2,Len(cNatNcc))
					
					ElseIf !(SubStr(cNatNcc,1,1) == "'" .Or. SubStr(cNatNcc,1,1) == '"')
						lMacroExec := .F.
					EndIf
				Else
					lMacroExec := .F.
				EndIf
												
				If lMacroExec
					cNatNcc := &(cNatNcc)
				EndIf
	 			
	 			If Empty(cNumTitAux) //Numero do título já gerado quando não localizado título
	 				cNumTitAux	:= GetNumSE1(cPrefTit)			// Alteracao para pegar numeracao SE1
	 				cNumTitGer	:= PadR( cNumTitAux , nTamDoc )
	 				cGRParc		:= StrZero( 1 , nTamE1_PARCELA)
				EndIf
				
				lMsErroAuto := .f.
				
				Private lAutoErrNoFile := .T. 
				
				dDtVencNCC := dDataBase + SuperGetMV("MV_LJDTNCC",,0)
				aSE1 := {{"E1_FILIAL"	,xFilial("SE1")											,Nil},;
							{"E1_PREFIXO"	,cPrefTit												,Nil},;
							{"E1_NUM"	  	,cNumTitGer												,Nil},;
							{"E1_PARCELA" 	,cGRParc 												,Nil},;
							{"E1_TIPO"	 	,"NCC"						,Nil},;
							{"E1_NATUREZ" 	,cNatNcc 												,Nil},;
							{"E1_CLIENTE" 	,PadR(cCliPDV,TamSx3("E1_CLIENTE")[1])					,Nil},;
				        	{"E1_LOJA"	  	,cLojaPDV												,Nil},;
						    {"E1_EMISSAO" 	,dDataBase	 												,Nil},;
						    {"E1_EMIS1" 	,dDataBase	 												,Nil},;
							{"E1_VENCTO"  	,dDtVencNCC    	 								,Nil},;
							{"E1_VENCREA" 	,dDtVencNCC	 ,Nil},;
							{"E1_MOEDA" 	,1														,Nil},;
							{"E1_ORIGEM"	,"LOJA701"												,Nil},;
							{"E1_FLUXO"		,"S"													,Nil},;
							{"E1_VALOR"	  	,nSaldoCr							,Nil},;
							{"E1_VLRREAL"  	,nSaldoCr											,Nil},;
							{"E1_HIST"		,"Rec Off " + cRequisicao														,Nil},;
							{ "E1_SITUACA","0", NIL } ,;  //CARTEIRA PADRÃO
							{ "E1_MULTNAT","2", NIL } ,;
							{ "E1_FILORIG",cFilAnt, NIL},;
							{"E1_STATUS", "A" , NIL } }						
				
				aAreaSA6 := SA6->(GetArea())
				SA6->(dbSetOrder(2))
				If SA6->(dbSeek(xFilial("SA6")+Upper(cCashier)))
					cBcoCx := SA6->A6_COD
					cAgCx := SA6->A6_AGENCIA
					cCtaCx := SA6->A6_NUMCON
					aadd(aSE1,	{"E1_PORTADO" ,cBcoCx	, ,Nil})//CODIGO DO CAIXA
					aadd(aSE1,{"E1_AGEDEP", cAgCx, Nil})
					aadd(aSE1,{"E1_CONTA" , cCtaCx , NIL})
			   EndIf

				RestArea(aAreaSA6)
				
				LjGrvLog("Recebimento_Titulo", "STDropTitles - Gerando ncc saldo credor ", nSaldoCr)
				
				//Gera o Titulo de NCC com MsExecAuto
				MsExecAuto({|x, y| Fina040(x, y)}, aSE1, 3) 
							
				//Verifica erros na gravacao
				If lMsErroAuto
					DisarmTransaction()
					//MostraErro()
					LjGrvLog("Recebimento_Titulo","Problemas na rotina automatica " + " FINA040 " , GetAutoGRLog())
					lRet := .F.
					Break
				Else
					
					//Agora que gerou uma NCC do saldo credor, gera uma entrada em dinheiro, caso
					//tenha recebido em dinheiro
					
					For nC := 1 to len(aFormas)
					
						If IsMoney(aFormas[nC, 01]) .OR. (AllTrim(aFormas[nC, 01]) $ cMvTpRec)
							
							aAdd(aDadosSE5, {"E5_FILIAL", xFilial("SE5") } ) 
							aAdd(aDadosSE5, {"E5_TIPODOC", "VL" } ) 
							aAdd(aDadosSE5, {"E5_MOTBX",  TrazCodMot("NOR") } )
							aAdd(aDadosSE5, {"E5_FILORIG",  cFilAnt } )
							
							If  SE5->(FieldPos( "E5_SEQ" )) > 0
								aAdd(aDadosSE5, {"E5_SEQ", StrZero(1, TamSX3("E5_SEQ")[1]) } )
							EndIf
							
							aAdd(aDadosSE5, {"E5_MOEDA",  aFormas[nC, 01] } )
							
							If  SE5->(FieldPos("E5_ORIGEM")) > 0
								aAdd(aDadosSE5, {"E5_ORIGEM",   "LOJXREC" })
							EndIf
							
							If SE5->(FieldPos("E5_FORMAPG")) > 0
								aAdd(aDadosSE5, {"E5_FORMAPG",  aFormas[nC, 01] } )
							EndIf
							
							aAdd(aDadosSE5, {"E5_VALOR",  aFormas[nC, 02] } )
							aAdd(aDadosSE5, {"E5_DATA",  dDataBase } )
							aAdd(aDadosSE5, {"E5_DTDIGIT",  dDataBase } )
							aAdd(aDadosSE5, {"E5_DTDISPO",  dDataBase } )
							aAdd(aDadosSE5, {"E5_TIPO",  "NCC" } )
							aAdd(aDadosSE5, {"E5_RECPAG",  "R" } )
							aAdd(aDadosSE5, {"E5_HISTOR",  "Rec Off " + cRequisicao + "-"+cPrefTit+"/"+cNumTitGer+"/"+cGRParc } )
							If !Empty(cBcoCx)
								aAdd(aDadosSE5, {"E5_BANCO",  cBcoCx } )
								aAdd(aDadosSE5, {"E5_AGENCIA",  cAgCx } )
								aAdd(aDadosSE5, {"E5_CONTA",  cCtaCx } )
							EndIf
							aAdd(aDadosSE5, {"E5_PREFIXO",  cPrefTit } )
							aAdd(aDadosSE5, {"E5_NUMERO",  cNumTitGer } )
							If SE5->(FieldPos("E5_PARCELA")) > 0
								aAdd(aDadosSE5, {"E5_PARCELA",  cGRParc } )
							EndIf						

							aAdd(aDadosSE5, {"E5_NATUREZ" 	,cNatNcc })
							aAdd(aDadosSE5, {"E5_CLIFOR" 	,PadR(cCliPDV,TamSx3("E1_CLIENTE")[1])	})
							aAdd(aDadosSE5, {"E5_CLIENTE" 	,PadR(cCliPDV,TamSx3("E1_CLIENTE")[1])	})
				        	aAdd(aDadosSE5, {"E5_LOJA"	  	,cLojaPDV})


							If SE5->(FieldPos("E5_FILORIG")) > 0
								aAdd(aDadosSE5, {"E5_FILORIG",  cFilAnt } )
							EndIf		
	
							LjGrvLog("Recebimento_Titulo", "STDropTitles - Recebimento offline - Gerando mov se5 forma/valor", aFormas[nC, 01] +"/" + cValToChar(aFormas[nC, 02]) )							
							RecLock( "SE5",.T. )
							For nX := 1 to Len( aDadosSE5 )
								SE5->&(aDadosSE5[nX, 01])  := aDadosSE5[nX, 02]
							Next nX
								
								
							If Empty(SE5->E5_KEY)
								Replace SE5->E5_KEY With SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIENTE+E5_LOJA)
							EndIf	
							SE5->( MsUnlock() )	
			
							
							//Gera FKs com base na SE5 gerada
							FINXSE5( SE5->( Recno() ) , 1 )	//Movimento Bancario
							
							//Compatibiliza as Fks com padrao do loja
							LjCompFKs()
						EndIf			
					Next nC 
					
				EndIf
				
			EndIf						
				
			If !lRet
				LjGrvLog("Recebimento_Titulo", "StartDropTit Retornou .F. - lRet = F -> DisarmTransaction()") //enfatiza Log quando ocorre algum problema na baixa
				Break	//envia para bloco Recover				
			Else
				cRet := "OK"
			EndIf
				
		Recover
	
			LjGrvLog("Recebimento_Titulo", "StartDropTit causou Exception - Recorver -> DisarmTransaction() ")	
			DisarmTransaction()
			SetAbendlock(.F.) 
		
		End Sequence
		
		SetAbendlock(.F.)
		
		ErrorBlock( bOldError )
	End Transaction
	
	//Realiza nova verificacao se ainda possui transacao aberta
	If InTransaction()
		LjGrvLog("Recebimento_Titulo", "STDropTitles - Transacao em aberto")
		DisarmTransaction()
		cRet := "Recebimento nao foi concluido. Controle de fluxo em aberto."
	EndIf
	
	LjGrvLog("Recebimento_Titulo", "STDropTitles - End Transaction")	
	
	LjGrvLog("Recebimento_Titulo", "Fim da Baixa - cRet", cRet )
	LjGrvLog("Recebimento_Titulo", "Fim da Baixa - Requisicao:", cRequisicao )
	
	Return cRet
Else
	LjGrvLog("Recebimento_Titulo", "Antes de executar DropTitOld(Rotina Anterior para Recebimento de Titulo) - Necessario atualizar STWReceiptTitle do PDV")
	lRet := DropTitOld(aListDropTitles, aRecnoComp, cCashier)
	LjGrvLog("Recebimento_Titulo", "Apos de executar DropTitOld(Rotina Anterior para Recebimento de Titulo) - Necessario atualizar STWReceiptTitle do PDV")
	Return lRet
EndIf

Return Nil //Return Nil nao sera utilizado, a rotina possui Return cRet quando utiliza controle de transacao ou lRet quando não possui(formato desatualizado)

//--------------------------------------------------------
/*/{Protheus.doc} StartDropTit()
Realiza a baixa de titulos, sendo chamado do PDV e executado na retaguarda via compontente de comunicacao do POS
@param	aListDropTitles	Array com a lista de titulos a serem baixados
@author  Varejo
@version P11.8
@since   14/08/2013
@return	 lRetorno	.T. Quando executado com sucesso / .F. Quando houver falha no processo
/*/
//--------------------------------------------------------
Static Function StartDropTit(	aListDropTitles	,aRecnoComp	,cCashier		,lTemFormaSE1	,;
									aParamSE1			,aTitMDXSe1	,aSE5Relacao	,aMdlGrd		,;
									cRequisicao		,cEmpAnt		,cFilAnt		)

Local nI 			:= 0	// Contador
Local bGravaMoeda	:= NIL	// Utilizada na compensação
Local aRecnoSE1	:= {}	// Para compensação
Local aTitSE1		:= {}	// Para atualização do SE1
Local aRecnoNCC	:= {}	// Recnos dos titulos a serem compensado
Local cCodCaixa	:= ""	//Codigo do caixa
Local cFilBkp		:= cFilAnt
Local aMDX			:= {}
Local aSLV			:= {}
Local lRet			:= .F.
Local cUserBkp    	:= ""
Local aDadosBanc 	:= {}			//array com dados de ag e conta CADASTRADOS NA SA6

Default aListDropTitles	:= {}		//Parametros da função de baixa
Default aRecnoComp		:= {}		//Numero dos Recnos das NCC a ser compensadas
Default cCashier			:= ""		//Nome do caixa
Default lTemFormaSE1		:= .F.		//Se tem formas de pgto que geram SE1 (CC/CD/CH...)
Default aParamSE1			:= {}		//Parametro para função STGrvMDX() 
Default aTitMDXSe1		:= {}		//Titulos que devem ser baixados
Default aSE5Relacao		:= {}		//Array para auxilia a geração da tabela SLV - para formas de pagamento igual a CC e CD
Default aMdlGrd			:= {}		//Array com as formas de pagamento (detalhada)
Default cRequisicao		:= ""		//ID da solicitação do PDV (comum entre PDV e Retagaurda)
	
Private lUsaTef := .F.	//Variavel necessário para nao imprimir TEF

LjGrvLog("Recebimento_Titulo", "StartDropTit - Inicio")

RPCSetType(3)  // 
RPCSETENV(cEmpAnt, cFilAnt,,,"FRT")

//Configura a variável cUserName para retornar na XNumCaixa o caixa do recebimento
cUserBkp    := cUserName

If Len(aRecnoComp) > 0
	LjGrvLog("Recebimento_Titulo", "Entrou Len(aRecnoComp) > 0 - Verifica se possui NCC para compensar.")
	aTitSE1	:= aRecnoComp[1]	//Titulos a serem compensados
	aRecnoNCC	:= aRecnoComp[2]	//Nccs a serem compensadas
EndIf 

//Compensa NCC
If Len(aTitSE1) > 0 .And. Len(aRecnoNCC) > 0

	SA6->(dbSetOrder(2))
	If SA6->(dbSeek(xFilial("SA6") + Upper(cCashier)))
 		cCodCaixa := SA6->A6_COD
    ElseIf SA6->(dbSeek(FWxFilial("SA6",cFilBkp) + Upper(cCashier))) // Caso SA6 exclusivo | Utilizado a validação do FWxFilial somente aqui para não impactar as rotinas no momento
  		cCodCaixa := SA6->A6_COD
	EndIf
	
	LjGrvLog("Recebimento_Titulo", "Dentro aRecnoComp - Conteudo do SA6->A6_COD que sera utilizado para gravacao da SE5->E5_BANCO",cCodCaixa)
	
	//Quando sofreu atualizacao/digitacao no PDV, faz a atualizacao dos campos E1_MULTA, E1_JUROS e E1_DESCONT
	For nI:=1 To Len(aTitSE1)
		aAdd(aRecnoSE1, aTitSE1[nI][5]) //Recno
		If aTitSE1[nI][2]>0 .OR. aTitSE1[nI][3]>0 .OR. aTitSE1[nI][4]>0
			FrtAtuaSE1(aTitSE1, nI)
		Endif
	Next nI
	aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cCodCaixa, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
		
	bGravaMoeda := { || (RecLock("SE5",.F.),;
							SE5->E5_MOEDA		:= "CR",;
							SE5->E5_BANCO		:= cCodCaixa,;
							SE5->E5_AGENCIA		:= Iif(!Empty(cCodCaixa),aDadosBanc[1],""),;
							SE5->E5_CONTA		:= Iif(!Empty(cCodCaixa),aDadosBanc[2],""),;
							MsUnlock()) }


	LjGrvLog("Recebimento_Titulo", "MaIntBxCR - Antes de executar MaIntBxCR para compensacao de NCC - Passa conteudo de aRecnoComp[1] - Titulos a serem compensados e aRecnoComp[2] - Nccs a serem compensadas")	

	// Chama a rotina para compensacao das NCC com parametro == 3 que eh a Compensacao de titulos de mesma carteira (RA/NCC), passando um array
	// com os titulos que deverao ser baixados e os titulos que serao compensados
	// Function MaIntBxCR nao possui tratamento de erro, caso a baixa nao seja realizada nao retorna .F. Exemplo: Deixar o registro da NCC em uso no momento da baixa
	// Foi utilizada variavel por referência lRetLoja para nao impactar demais rotinas do ERP  
	
	MaIntBxCR(	3	, 	aRecnoSE1	,	Nil				, 	aRecnoNCC	,;
				Nil	, 	Nil			,	bGravaMoeda	,	Nil			,;
				Nil	,	Nil			,	Nil				,	Nil			,;
				Nil	,	Nil			,	Nil  			,	Nil			,;
				Nil	,	@lRet )
								
	LjGrvLog("Recebimento_Titulo", "MaIntBxCR - Apos executar MaIntBxCR",lRet)	
Else
	lRet := .T.
EndIf

If lRet .AND. Len(aListDropTitles) > 0
	
	LjGrvLog("Recebimento_Titulo", "LJRecBXSE1 - Inicia baixa com base nos dados recebidos aTitMDXSe1")
	
	// Alterna tipo de operacao: Recebimento/Estorno
	For nI := 1 To Len(aListDropTitles)
				
		LjGrvLog("Recebimento_Titulo", "LJRecBXSE1 - Antes de executar LJRecBXSE1")
		LjGrvLog("Recebimento_Titulo", "LJRecBXSE1 - E1_PREFIXO:"	,aListDropTitles[nI,02])
		LjGrvLog("Recebimento_Titulo", "LJRecBXSE1 - E1_NUM:"		,aListDropTitles[nI,03])
		LjGrvLog("Recebimento_Titulo", "LJRecBXSE1 - E1_PARCELA:"	,aListDropTitles[nI,04])	
		
		lRet	:=	LJRecBXSE1(	aListDropTitles[nI,01], aListDropTitles[nI,02], aListDropTitles[nI,03], aListDropTitles[nI,04],;
									aListDropTitles[nI,05], aListDropTitles[nI,06], aListDropTitles[nI,07], aListDropTitles[nI,08],;
					    			aListDropTitles[nI,09], aListDropTitles[nI,10], aListDropTitles[nI,11], aListDropTitles[nI,12],;
					    			aListDropTitles[nI,13], aListDropTitles[nI,14], aListDropTitles[nI,15], aListDropTitles[nI,16],;
					    			aListDropTitles[nI,17], aListDropTitles[nI,18], aListDropTitles[nI,19], aListDropTitles[nI,20],;
					    			aListDropTitles[nI,21], aListDropTitles[nI,22], aListDropTitles[nI,23], aListDropTitles[nI,24],;
					    			aListDropTitles[nI,25], aListDropTitles[nI,26], aListDropTitles[nI,27], aListDropTitles[nI,28],;
					    			aListDropTitles[nI,29]	)
					    					
		LjGrvLog("Recebimento_Titulo", "LJRecBXSE1 - Apos executar LJRecBXSE1")
			
		//Se ocorrer erro na baixa de algum titulo, cancela toda a operacao que esta no controle de transacao na rotina STDropTitles 						
		If !lRet
			LjGrvLog("Recebimento_Titulo", "LJRecBXSE1 - Nao realizou o comando(lRet = .F.) - aListDropTitles[nI]",aListDropTitles[nI])
			Exit
		EndIf

	Next nI

Else
	LjGrvLog("Recebimento_Titulo", "Nao entrou executou rotina de baixa (LJRecBXSE1). Condicao: lRet .AND. Len(aListDropTitles) > 0. Retorno Log:{lRet,Len(aListDropTitles) > 0}",{lRet,Len(aListDropTitles) > 0} )
EndIf	

//Gera as tabelas de controles para formas de pagamento que geram SE1 (CC/CD/CH e etc) menos dinheiro.
If lRet .And. lTemFormaSE1
		
	LjGrvLog("Recebimento_Titulo", "STGrvMDX - Antes de executar STGrvMDX - Utiliza dados aParamSE1 e aTitMDXSe1")
	
	//Gera registros MDN e MDN
	aMDX := STGrvMDX("1", aParamSE1, aTitMDXSe1)
	
	LjGrvLog("Recebimento_Titulo", "STGrvMDX - Apos executar STGrvMDX ",aMDX)
	
	If Len(aMdlGrd) > 0 .And. Len(aMDX) > 0 .And. Len(aSE5Relacao) > 0 

		LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - Antes de executar LjxPSLVArray (Pagto Cartao)")
		//Ajusta array para geração da tabela SLV - para formas de pagamento igual a CC e CD
		aSLV := LjxPSLVArray(aMDX,aSE5Relacao,aMdlGrd)			
		LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - Apos executar LjxPSLVArray (Pagto Cartao)")
					
		//phlinha
		If Len(aSLV) > 0
			//Gera registro SLV
			LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - Antes de executar STGrvSLV (Pagto Cartao)")				
			lRet := STGrvSLV("I", aSLV)
			
			If lRet
				LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - Apos executar STGrvSLV (Pagto Cartao)")
			Else
				LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - >>>NC<<< Apos executar STGrvSLV (Pagto Cartao).aSLV:",aSLV)
			EndIf				
			
		Else
			LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - >>>NC<<< - Nao gerou aSLV")							
			LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - aMDX:",aMDX)
			LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - aSE5Relacao:",aSE5Relacao)
			LjGrvLog("Recebimento_Titulo", "LjxPSLVArray - aMdlGrd:",aMdlGrd)				
		EndIf
	EndIf
Else
	LjGrvLog("Recebimento_Titulo", "Nao entrou nem executou STGrvMDX - Utiliza dados aParamSE1 e aTitMDXSe1. Condicao: lRet .And. lTemFormaSE1. Retorno Log:{lRet,lTemFormaSE1}",{lRet,lTemFormaSE1} )
EndIf
	
LjGrvLog("Recebimento_Titulo", "StartDropTit - Fim")

//Volta o usuário corrente
cUserName := cUserBkp

Return lRet
   
/*/{Protheus.doc} LjxPSLVArray
Função responsável por retornar os registros a serem incluidos na tabela SLV na retaguarda.
@param		aSE5Baixas		- Baixas realizadas
			aSE5Relacao	- Array com as relações Forma de pagamento x titulos
			aMdlGrd		- Gride de formas de pagamento
@author	Varejo
@version	P11.8
@since		15/06/2015
@return	aRet - Array com informações a serem geradas na tabela SLV.
/*/
Static Function LjxPSLVArray(aSE5Baixas,aSE5Relacao,aMdlGrd)
Local aRet			:= {}
Local nI			:= 0
Local nY			:= 0
Local nPosRelacao	:= 0

For nI := 1 To Len(aSE5Baixas)

	For nY := 1 To Len(aSE5Baixas[nI])

		If AllTrim(aSE5Baixas[nI][nY][24]) $ "CC/CD/PX/PD"

			nPosRelacao := aScan(aSE5Relacao, {|x| AllTrim(x[1])+AllTrim(x[3])+AllTrim(x[4])+AllTrim(x[5]) ==;
							AllTrim(aSE5Baixas[nI][nY][24])+AllTrim(aSE5Baixas[nI][nY][1])+AllTrim(aSE5Baixas[nI][nY][2])+AllTrim(aSE5Baixas[nI][nY][3]) .And. ;
							x[2]==aSE5Baixas[nI][nY][8] })

			If nPosRelacao > 0

				nPosGrd :=  aScan(aMdlGrd, {|x| x[1] == aSE5Relacao[nPosRelacao][7] })
							
				If nPosGrd > 0
					aAdd(aRet,{aSE5Baixas[nI][nY][1],;				//01-PREFIXO
								aSE5Baixas[nI][nY][2],;				//02-NUMERO
								aSE5Baixas[nI][nY][3],;				//03-PARCELA
								aSE5Baixas[nI][nY][4],;				//04-TIPO
								aSE5Baixas[nI][nY][9],;				//05-E5_SEQ
								aSE5Relacao[nPosRelacao][6]	,;		//06-FILORIG
								aSE5Baixas[nI][nY][5],;				//07-CLIENTE
								aSE5Baixas[nI][nY][6],;				//08-LOJA
								aSE5Baixas[nI][nY][24],;				//09-Forma Pgto
								aSE5Baixas[nI][nY][8],;				//10-Valor
								aMdlGrd[nPosGrd][2],;				//11-Data
								aMdlGrd[nPosGrd][3],;				//12-Hora
								aMdlGrd[nPosGrd][4],;				//13-DOC
								aMdlGrd[nPosGrd][5],;				//14-Autorizacao
								aMdlGrd[nPosGrd][6],;				//15-Instituicao
								aMdlGrd[nPosGrd][7],;				//16-NSU
								iIf(!Empty(aMdlGrd[nPosGrd][8]), aMdlGrd[nPosGrd][8], aSE5Baixas[nI][nY][24]),;	//17-Tipo do cartao
								"",;									//18-SEQOPER
								0,;										//19-RECNO
								"",;									//20-Doc. Canc.
								"",;									//21-Data Canc.
								"",;									//22-Hora Canc.
								Iif(Len(aMdlGrd[nPosGrd])>=12,aMdlGrd[nPosGrd][11],""),;				//23-Bandeira Cartão
								Iif(Len(aMdlGrd[nPosGrd])>=12,aMdlGrd[nPosGrd][12],""),;					//24-Rede Autorizada (Adquirência)
								Iif(Len(aMdlGrd[nPosGrd])>=13,aMdlGrd[nPosGrd][13],""),;					//25-TRNID da Transação de Pagamento Digital 
								Iif(Len(aMdlGrd[nPosGrd])>=13,aMdlGrd[nPosGrd][14],""),;					//26-TRNPCID da Transação de Pagamento Digital 
								Iif(Len(aMdlGrd[nPosGrd])>=13,aMdlGrd[nPosGrd][15],"");					//27-TRNEXID da Transação de Pagamento Digital 
								} )
				EndIf
			EndIf
		EndIf
	Next
Next

Return aClone(aRet)


//--------------------------------------------------------
/*/{Protheus.doc} STGrvMDX()
Inclui ou estorna titulos SE1 referentes as condições de pagamentos.
@param		cTypeOperatio	Tipo de operacao "1"-Recebimento de Titulos / "2"-Estorno do baixas
@param		aParams			Array com a lista de parametros da funcao
@param		aTit			Array com as baixas realizadas
@author		Varejo
@version	P11.8
@since		08/06/2015
@return		aRetorno	Array com a lista de baixas dos titulos
/*/
//--------------------------------------------------------
Static Function STGrvMDX( cTypeOperation , aParams, aTit )

Local lRetorno 		:= .T.	// Retorno da funcao
Local aRet			:= {}	// Retorno da função com as baixas realizadas
Local nI 			:= 0	// Contador
Local cParametros	:= ""	// Parametros

Default cTypeOperation 	:= ""
Default aParams        	:= {}

// Alterna tipo de operacao: Recebimento/Estorno
cOper := cTypeOperation

For nI := 1 To Len(aParams)
	If nI!=20 .and. nI!=21 
		cParametros += IIF(nI <> 1, ", ", "") + "aParams[" + AllTrim(Str(nI)) + "]
	Endif 
Next nI

lRetorno := Eval(&("{|| LjxGrvMDX(" + cParametros + ")}"))

//Caso houve a baixa será retornado os registros da tabela SE5 para gravação
//da tabela SLV
If lRetorno
	aRet := aClone(STSelBaixa(aTit))
EndIf

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} STSelBaixa()
Função para recuperar as baixas realizadas dos titulos provinientes
do TOTVS PDV para que sejam gerados os registros da tabela SLV
@param		aTit		Titulos selecionados/baixados
@author		Varejo
@version	P11.8
@since		08/06/2015
@return		aRetorno	Array com a lista de baixas realizadas
/*/
//--------------------------------------------------------
Static Function STSelBaixa(aTit)
Local aRet		:= {}
Local nI		:= 0

Private AbaixaSE5 := {}

Default aTit	:= {}

For nI := 1 To Len(aTit)
	Sel070Baixa( "BA"		,aTit[nI,2]	,aTit[nI,3]	,aTit[nI,4]	,;
				aTit[nI,11]	,NIL		,NIL		,aTit[nI,13],;
				aTit[nI,14]	,NIL		,NIL		,NIL		,;
				NIL			,.T.	)
	aAdd(aRet, aClone(AbaixaSE5))
	AbaixaSE5 := {}
Next

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} STGrvSLV
Responsável por gerar os registros da tabelas SLV para as baixas
de titulos provinientes do TOTVS PDV.

@param		cTypeOperation	Tipo de operacao: "1"-Recebimento de Titulos
							/ "2"-Estorno do baixas
@param		aParams			Array com a lista de parametros da funcao
@author		Varejo
@version	P11.8
@since		08/06/2015
@return		aRetorno		Array com a lista de titulos
/*/
//--------------------------------------------------------
Static Function STGrvSLV( cTypeOperation , aParams  )
Local lRetorno	:= .T.	// Retorno da funcao

Default cTypeOperation	:= "I"
Default aParams			:= {}

// Alterna tipo de operacao: Recebimento/Estorno
cOper := iIf(AllTrim(cTypeOperation) == "I", "1","2")

lRetorno := Eval(&("{|| LJXGrvSLV( cTypeOperation, aParams )}"))

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LJModNFis ³ Autor ³ Venda Clientes        ³ Data ³22/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica recebimento por Modulo sem ECF					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Logico (.T. se modulo sem uso de ECF    		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja / SIGALOJA										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJModNFis( )
Local lAutomato		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local lRet := .F.

If (nModulo == 12 .OR. nModulo == 23)	//Recebimento pelo Loja/Front com NFC-e
	If lRecebNFCE == NIL				//Variável Static
		lRecebNFCE := Iif(!lAutomato .AND. GetAPOInfo("LOJA121.PRW")[4] >= Ctod("16/03/2017"),;
			 !(Lj121IsFis(LjGetStation("LG_IMPFISC"))),;		//Função do LOJA121.PRW - .T. retorna se Fiscal, mas o que estamos querendo é .T. se não-fiscal. Por isso o "!"
			  LjEmitNFCe())
	EndIf
	lRet := lRecebNFCE
ElseIf (nModulo == 5 .OR. nModulo == 6)		//Recebimento pelo Venda Direta
	lRet := .T.
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjAddTit()
Seta a variavel que define se é uma pesquisa incremental
@param	[nenhum]
@author  Varejo
@version P11.8
@since   03/07/2014
@return	 lRetorno	.T. Quando executado com sucesso / .F. Quando houver falha no processo
/*/
//--------------------------------------------------------
Static Function LjAddTit()
Local lRet := .T.

lAddTitulos := .T.

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjRecVerTit()
Efetua a pesquisa no array aTitulo comparando com o aReceb, para que
não seja adicionado no array um titulo que já foi pesquisado

@param	aTitulo : contem os titulos pesquisados
@param  aReceb  : contem os titulos retornados de uma nova pesquisa
@author  Varejo
@version P11.8
@since   03/07/2014
@return	 lRetorno	.T. Quando executado com sucesso / .F. Quando houver falha no processo
/*/
//--------------------------------------------------------
Static Function LjRecVerTit(aTitulo , aReceb)
Local lRet	:= .T.
Local nX	:= 0

For nX:= 1 to Len(aTitulo)
	//Pesquisa se o titulo já foi incluído no aTitulo baseado no indice da tabela SE1
	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If	aReceb[TIT_FILI]+aReceb[TIT_CLIE]+aReceb[TIT_LOJA]+aReceb[TIT_PREF]+aReceb[TIT_NUME]+aReceb[TIT_PARC]+aReceb[TIT_TIPO] == ;
		aTitulo[nX][TIT_FILI]+aTitulo[nX][TIT_CLIE]+aTitulo[nX][TIT_LOJA]+aTitulo[nX][TIT_PREF]+aTitulo[nX][TIT_NUME]+aTitulo[nX][TIT_PARC]+aTitulo[nX][TIT_TIPO]

		lRet := .F.
		Exit
	EndIf
Next nX

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjE1Indx()
Rotina para buscar os indices da SE1

@version P11.8
@since   10/07/2014
@return	 aIdxSE1		Array com os indices da SE1
/*/
//--------------------------------------------------------
Static Function LjE1Indx()

Local aArea		:= GetArea()   				// Armazena ultima area utilizada
Local aAreaSIX	:= SIX->( GetArea() )		// Armazena area SE1
Local aIdxSE1	:= {}						// Array com os indices da SE1

dbSelectArea("SIX")
SIX->( dbSetOrder(1) )

If SIX->( dbSeek("SE1") )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca todos os indices da SE1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While SIX->( !EOF() ) .AND. SIX->INDICE == "SE1"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente adiciona se mostrar na pesquisa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SIX->SHOWPESQ == "S"
			aADD(aIdxSE1,AllTrim(SIX->DESCRICAO) )
		EndIf

		SIX->( dbSkip() )

	End

EndIf

RestArea(aAreaSIX)
RestArea(aArea)

Return aIdxSE1

//--------------------------------------------------------
/*/{Protheus.doc} LjMtSeek()
Rotina para pesquisar um determinado titulo na grid

@version P11.8
@since   03/07/2014
@return	 aIdxSE1		Array com os indices da SE1
/*/
//--------------------------------------------------------
Static Function LjMtSeek(oCbBox,cSeek,oSeek,cCodCli,;
                         cLojCli)

Local aArea		:= GetArea()				// Armazena ultima area utilizada
Local aAreaSE1	:= SE1->( GetArea() )		// Armazena area SE1
Local nIdxSE1	:= oCbBox:nAt				// Indice informado para pesquisa
Local cSeekE1	:= AllTrim(cSeek)			// Chave informada para pesquisa
Local nRecSE1	:= 0						// Recno do registro na SE1
Local nPosTit	:= 0						// Posicao do titulo encontrado
Local lLJRECPSQ	:= ExistBlock("LJRECPSQ")	// Ponto de entrada pesquisa de titulos 
Local lRetRECPSQ := .F.				    //Guarda Retorno do Ponto de entrada LJRECPSQ
Local lbChange	:= .T.					//Executa bChange do titulo	

Default oSeek   := Nil
Default cCodCli := ""
Default cLojCli := ""

If !Empty(cSeekE1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca titulo na SE1 conforme parametros informados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE1")
	SE1->( dbSetOrder(nIdxSE1) )

	If	lLJRECPSQ
		lRetRECPSQ := ExecBlock( "LJRECPSQ", .F., .F., {nIdxSE1, cSeekE1})
		
		If lRetRECPSQ 
			nRecSE1 := SE1->( RECNO() )
			cCodCli := SE1->E1_CLIENTE
			cLojCli := SE1->E1_LOJA
			If nRecSE1 > 0 .AND. !Empty(cCodCli) .AND. !Empty(cLojCli)
				LjRecVldCli(	@cCodCli, @cLojCli, @cCPF, .T.,;
							 	@cCPFTemp )
				LJRecPesq(	@oNomeCli	, 	@cNomeCli	, @cCodCli	, @cLojCli, ;
							@cSerieRec	,	@cRecibo	, oSerieRec, oRecibo,;
							,@cSeek	,	oSeek )	
		
			EndIf	
		Else
			cCodCli := ""
			cLojCli := ""
			cCPF    := ""
			cCPFTemp :=""
			cNomeCli := ""
			nTotal   := 0
			nMulta   := 0
			nJuros   := 0
			nDescont := 0
			nAcres   := 0
			nValRec  := 0
			
			nRecSE1 := 0
			aTitulo := {aTitVazio}	
			oTitulo:aArray := aTitulo
			lbChange := .F.
			oTitulo:nAT := 1
		EndIf	
			
	ElseIf SE1->( dbSeek( FWXFilial("SE1") + cSeekE1) )
		nRecSE1 := SE1->( RECNO() )
	EndIf

	If nRecSE1 > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca titulo no array e posiciona na Grid ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosTit	:= aScan(aTitulo,{|x| x[16] == nRecSE1} )

		If nPosTit > 0
			oTitulo:nAT := nPosTit
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza grid ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	lLJRECPSQ .AND. lRetRECPSQ
		Eval(oTitulo:bLDblClick)		
	EndIf
	
	If lbChange
		Eval(oTitulo:bChange)
	EndIf
		
	oTitulo:Refresh()
	oTitulo:SetFocus()

EndIf

RestArea(aAreaSE1)
RestArea(aArea)

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} LjGetLeg()
Rotina para retornar a legenda do titulo

@version P11.8
@since   11/07/2014
@return	 aIdxSE1		Array com os indices da SE1
/*/
//--------------------------------------------------------
Static Function LjGetLeg(aTitAtu)

Local nLegend := 4			// Retorna a posicao da legenda

If Len(aTitAtu) > 0 .AND. !Empty(aTitAtu[TIT_NUME])

	If !Empty(aTitAtu[TIT_DTBX]) .AND. (aTitAtu[TIT_SALD] == 0)

		// Baixado
		nLegend := 4

	ElseIf !Empty(aTitAtu[TIT_DTBX]) .AND. (aTitAtu[TIT_SALD] > 0)

		// Baixado Parcialmente
		nLegend := 3

	ElseIf aTitAtu[TIT_VREA] < dDataBase

		// Titulo vencido
		nLegend := 2

	ElseIf Empty(aTitAtu[TIT_DTBX])

		// Verifica a data da baixa - Titulo em aberto
		nLegend := 1

	EndIf

EndIf

Return nLegend

//--------------------------------------------------------
/*/{Protheus.doc} LjLegend()
Rotina para mostrar a legenda da grid

@version P11.8
@since   11/07/2014

/*/
//--------------------------------------------------------
Static Function LjLegend()

Local aLegenda :={ {"BR_VERDE",	STR0175 },;		// "Titulo em aberto"
					{"BR_VERMELHO",	STR0176 },;		// "Titulo Vencido"
					{"BR_AZUL",		STR0177 },;		// "Baixado Parcialmente"
					{"BR_CINZA",	STR0178 } }		// "Título Baixado"

BrwLegenda(STR0179,STR0174,aLegenda)		//"Recebimentos" # "Legenda"

Return

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetNumSE1()
Rotina para retornar o proximo SE1 dependendo de um determinado preciso, utilizado para Recebimento do Loja

@version 	P11.8
@since   	25/09/2014
@autor		Vendas CRM
/*/
//------------------------------------------------------------------------------------------------------------
Function GetNumSE1(cPrefRec)

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )
	Local aAreaSX5		:= SX5->( GetArea() )
	Local cSe1Num		:= ""
	Local cQuery		:= ""
	Local cAlias		:= ""
	Local cFilSE1		:= xFilial("SE1")
	Local nTamE1Num		:= TamSx3("E1_NUM")[1]
	Local cTabelaSX5	:= "01"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ja existe a numeracao para o prefixo especifico. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX5")
	SX5->( DbSetOrder(1) )		//X5_FILIAL + X5_TABELA + X5_CHAVE
	If SX5->( DbSeek(cFilSE1 + cTabelaSX5 + cPrefRec) )

		cSe1Num := StrZero( Val(SX5->X5_DESCRI) + 1, nTamE1Num )
	Else

		cSe1Num := StrZero(1, nTamE1Num)

		//Cria o SX5 para controlar a numeracao do prefixo especificado
		RecLock("SX5", .T.)
			SX5->X5_FILIAL	:= cFilSE1
			SX5->X5_TABELA	:= cTabelaSX5
			SX5->X5_CHAVE	:= cPrefRec
			SX5->X5_DESCRI	:= cSe1Num
			SX5->X5_DESCSPA	:= cSe1Num
			SX5->X5_DESCENG	:= cSe1Num
		SX5->( MsUnlock() )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega a ultima numeracao ja utilizada para esse prefixo. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP

		cAlias	:= GetNextAlias()

		//Pega o ultimo numero utilizado mesmo estando deletado para nao utilizar mais
		cQuery	:= "SELECT MAX(E1_NUM) AS E1_NUM FROM " +RetSqlName("SE1")+ " WHERE 	 E1_FILIAL	= 	'" +cFilSE1		+ "' AND " +;
																						"E1_PREFIXO = 	'" +cPrefRec	+ "' AND " +;
																						"E1_NUM BETWEEN	'" +cSe1Num		+ "' AND '" +Replicate("9", nTamE1Num)+ "'" +;
																						" AND " + RetSqlName("SE1") + ".D_E_L_E_T_ <>'*'"


		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias)

		If !(cAlias)->( Eof() )

			If Val((cAlias)->E1_NUM) > Val(cSe1Num)
				cSe1Num := cValToChar( Val((cAlias)->E1_NUM) + 1 )
			EndIf
		EndIf
		(cAlias)->( DbCloseArea() )

	#ELSE

	    //Seta para aparecerem no DbSeek os registros deletados

   		//Pega o ultimo numero utilizado mesmo estando deletado para nao utilizar mais
		//Se a retaguarda for DBF a primeira execucao pode demorar um pouco, as demais nao
		DbSelectArea("SE1")
		SE1->( DbSetOrder(1) )		//E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		If SE1->( DbSeek(cFilSE1 + cPrefRec + cSe1Num) )

			While !SE1->( Eof() ) .AND. SE1->E1_FILIAL == cFilSE1 .AND. SE1->E1_PREFIXO == cPrefRec

				//Verifica se eh digito numerico
				If IsDigit(SE1->E1_NUM)
					cSe1Num := SE1->E1_NUM

				//Se ja chegou no caracteres alfanumerico eh por acabacou os digitos numericos
				Else
					Exit
				EndIf

				SE1->( DbSkip() )
			EndDo

			//Pega o proximo numero para E1_NUM
			cSe1Num := cValToChar( Val(cSe1Num) + 1 )
		EndIf

		//Restaura ambiente
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a numeracao no SX5 que sera utilizada. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX5")
	SX5->( DbSetOrder(1) )		//X5_FILIAL + X5_TABELA + X5_CHAVE
	If SX5->( DbSeek(cFilSE1 + cTabelaSX5 + cPrefRec) )

		cSe1Num := Padl(cSe1Num, nTamE1Num, "0")

		RecLock("SX5", .F.)
			SX5->X5_DESCRI	:= cSe1Num
			SX5->X5_DESCSPA	:= cSe1Num
			SX5->X5_DESCENG	:= cSe1Num
		SX5->( MsUnlock() )
	EndIf

	RestArea( aAreaSX5 )
	RestArea( aAreaSE1 )
	RestArea( aArea )

Return cSe1Num



//--------------------------------------------------------------------------------
/*/{Protheus.doc} LjxTelaNSU()
Tela para preenchimento do NSU e Código de Autorização da Venda TEF Manual que foi efetuada no P.O.S.,
quando o TEF do Protheus não estiver online
- Usado no LojxRec,Loja701c,Frta271

@type 		Function
@param		aParams , array , contem as informações da tela [Forma , ID , Valor , NSU digitada, Código de Autorização Digitada]
@version 	P12
@since   	12/09/2016
@autor		Varejo
@return		aRet , Array , Retorna um array com as informações de NSU e Código de Autorização da transação manual de cartão via POS
/*/
//---------------------------------------------------------------------------------
Function LjxTelaNSU(aParams,aIdPgtoMfe)
Local oDlg			:= Nil
Local oGroup 		:= Nil
Local oFontBold 	:= TFont():New(, , -11, .T., .T.)
Local oGetNSU		:= Nil
Local oGetAutori	:= Nil
Local oBalloon 		:= Nil
Local aRet 			:= {}
Local cNSU			:= Space(TamSx3("E1_DOCTEF")[1])
Local cAUTORIZ		:= Space(TamSx3("E1_CARTAUT")[1])
Local cTipoCart		:= ""
Local cIdCard 		:= ""
Local cValorCard	:= ""
Local lTemInfo		:= .F.
Local cTxtInfNSU	:= STR0224 //"Informe o Código da Transação que consta no comprovante da maquininha (POS). Geralmente essa informação está presente no comprovante como: NSU, DOC ou CV"
Local cTxtInfAut	:= STR0225 //"Informe o Código de Autorização que consta no comprovante da maquininha (POS). Geralmente essa informação está presente no comprovante como: AUT, AUTO ou AUTH"
Local uRetLJ7114	:= Nil
Local bValid 		:= { || Lj7VNSUDig(aParams, Alltrim(cNSU), Alltrim(cAUTORIZ)) }

Default aParams := {}

// Ponto de entrada para substituir a chamada da tela padrão do NSU
If ExistBlock("LJ7114")
	uRetLJ7114 := ExecBlock("LJ7114",.F.,.F.,aParams)
	If ValType(uRetLJ7114) == "A"
		//Novo retorno do PE LJ7114 é array
		cNSU 	:= uRetLJ7114[1]
		cAUTORIZ:= uRetLJ7114[2]
	Else
		//Antigo retorno do PE LJ7114 era apenas NSU (Caracter)
		cNSU 	:= uRetLJ7114
	EndIf
	lTemInfo := .T.
Else
	If Len(aParams) > 0
		If AllTrim(aParams[1]) == "CC"
			cTipoCart := STR0226 //"Cartao de Crédito"
		ElseIf AllTrim(aParams[1]) == "CD"
			cTipoCart := STR0227  //"Cartao de Débito"
		EndIf
		
		If !Empty(AllTrim(aParams[2]))
			cIdCard := " ID: " + aParams[2] 
		EndIf
		
		If aParams[3] > 0
			cValorCard := AllTrim(Transform(aParams[3],PesqPict("SL1","L1_VLRTOT")))
		EndIf
		
		lTemInfo := .T.
	EndIf

	oDlg 	:= MSDialog():New(0,0,200,450,STR0228,,,,,,,,,.T.) //"Informações da Transação Manual (POS)"
	oGroup 	:= TGroup():New(002, 002, 098, 226,"",oDlg,,,.T.)
	
	If lTemInfo
		//Tipo de Cartão 
		TSay():New(005,005,{||cTipoCart},oDlg,,oFontBold,,,,.T.,,,230,16)
		//ID do Cartão
		TSay():New(005,075,{||cIdCard},oDlg,,oFontBold,,,,.T.,CLR_HRED,,230,16)
		
		//Valor
		TSay():New(015,005,{||"Valor:"},oDlg,,oFontBold,,,,.T.,,,230,16)
		TSay():New(015,025,{||cValorCard},oDlg,,oFontBold,,,,.T.,CLR_HRED,,230,16)
	EndIf

	//"Código da Transação (NSU):"
	TSay():New(035,005,{||STR0229},oDlg,,,,,,.T.,CLR_BLACK,,230,16) //"Código da Transação (NSU):"
	oGetNSU := TGet():New(033,077,bSetGet(cNSU),oDlg,065,009,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cNSU,,,, )
	oGetNSU:bGotFocus := {|| ChgBalloon(oDlg, @oBalloon, STR0230, cTxtInfNSU, 003) } //"Código NSU"
	oGetNSU:cSx1Hlp:="L4_NSUTEF"

	//"Código de Autorização:"
	TSay():New(048,005,{||STR0231},oDlg,,,,,,.T.,CLR_BLACK,,230,16) //"Código de Autorização:"
	oGetAutori := TGet():New(046,077,bSetGet(cAUTORIZ),oDlg,065,009,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cAUTORIZ,,,,,,,,,,,)
	oGetAutori:bGotFocus := {|| ChgBalloon(oDlg, @oBalloon, STR0232, cTxtInfAut, 030) } //"Autorização"
	oGetAutori:cSx1Hlp:="L4_AUTORIZ"

	//Botão "OK"
	TButton():New( 080, 091, "OK", oDlg, {||oDlg:End()}, 045, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oGetNSU:SetFocus()

	oDlg:lEscClose := .F.
	oDlg:Activate(Nil, Nil, Nil, Nil, bValid)
Endif

cNsu 	 := AllTrim(cNsu)
cAUTORIZ := AllTrim(cAUTORIZ)

If lTemInfo
	aParams[4] := cNSU
	If Len(aParams) >= 5
		aParams[5] := cAUTORIZ
	EndIf
EndIf

aRet := {cNSU, cAUTORIZ}

Return aRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} LjVerifErro()
Rotina para controle de erro(Begin Sequence)
@type 		Function
@version 	P11.8
@since   	19/09/2016
@autor		Varejo
@return	lRet
/*/
//---------------------------------------------------------------------------------
Static Function LjVerifErro( e, aListDropTitles, cMsgErro )
Local lRet 		:= .F.

Default aListDropTitles 	:= {}	//Lista de titulos com solicitacao de baixa
Default cMsgErro			:= ""	//Guarda por referencia mensagem do erro para retornar ao PDV

IF e:gencode > 0  

	LjGrvLog( "Recebimento_Titulo","Error Block STDropTitles - Inicio")
	LjGrvLog( "Recebimento_Titulo","Error Block STDropTitles DESCRIPTION:", e:DESCRIPTION)				
	LjGrvLog( "Recebimento_Titulo","Error Block STDropTitles ERRORSTACK:", e:ERRORSTACK)
	LjGrvLog( "Recebimento_Titulo","Error Block STDropTitles Lista de Titulos(aListDropTitles):",aListDropTitles)
	LjGrvLog( "Recebimento_Titulo","Error Block STDropTitles - Fim")
	
	cMsgErro := "DESCRIPTION:"+e:DESCRIPTION+" - ERRORSTACK:"+SubStr(e:ERRORSTACK,1,50)+"..."
	
	lRet:=.T.   
	Break
EndIf

Return lRet


//--------------------------------------------------------------------------------
/*/{Protheus.doc} DropTitOld()
Rotina para manter compatibilidade com diferentes versoes de STDropTitles 
@type 		Function
@version 	P11.8
@since   	19/09/2016
@autor		Varejo
@return	lRet
/*/
//---------------------------------------------------------------------------------
Static Function DropTitOld(aListDropTitles, aRecnoComp, cCashier)

Local lRetorno 		:= .F.	// Retorno da funcao
Local nI 			:= 0	// Contador
Local nY 			:= 0	// Contador
Local cParametros	:= ""	// Parametros
Local bGravaMoeda	:= NIL	// Utilizada na compensação
Local aRecnoSE1		:= {}	// Para compensação
Local aTitSE1		:= {}	// Para atualização do SE1
Local aRecnoNCC		:= {}	// Recnos dos titulos a serem compensado
Local cCodCaixa		:= ""
Local cFilBkp		:= cFilAnt
Local aDadosBanc 	:= {}	//array com dados de ag e conta CADASTRADOS NA SA6

Default aListDropTitles := {}
Default aRecnoComp		:= {}
Default cCashier		:= ""

Private lUsaTef := .F.

/*
IMPORTANTE: Nao realizar manutencao nessa rotina, foi criada apenas para manter compatibilidade entre PDVxRetaguarda com LOJXREC diferentes
Rotina padrao responsavel pelo processamento do Recebimento de Titulos: StartDropTit 
*/

If Len(aRecnoComp) > 0
	aTitSE1		:= aRecnoComp[1]	//Titulos a serem compensados
	aRecnoNCC	:= aRecnoComp[2]	//Nccs a serem compensadas

	If Len(aTitSE1) > 0 .And. Len(aRecnoNCC) > 0

		SA6->(dbSetOrder(2))
		If SA6->(dbSeek(xFilial("SA6") + Upper(cCashier)))
	 		cCodCaixa := SA6->A6_COD
	    ElseIf SA6->(dbSeek(FWxFilial("SA6",cFilBkp) + Upper(cCashier))) // Caso SA6 exclusivo | Utilizado a validação do FWxFilial somente aqui para não impactar as rotinas no momento
      		cCodCaixa := SA6->A6_COD
    	EndIf

    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a atualizacao dos campos E1_MULTA, E1_JUROS e E1_DESCONT         ³
		//³ Se no recebimento houve digitacao dos mesmos                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI:=1 To Len(aTitSE1)
			aAdd(aRecnoSE1, aTitSE1[nI][5]) //Recno
			If aTitSE1[nI][2]>0 .OR. aTitSE1[nI][3]>0 .OR. aTitSE1[nI][4]>0
				FrtAtuaSE1(aTitSE1, nI)
			Endif
		Next nI
		aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cCodCaixa, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
		bGravaMoeda := { || (RecLock("SE5",.F.),;
								SE5->E5_MOEDA	:= "CR",;
								SE5->E5_BANCO	:= cCodCaixa,;
								SE5->E5_AGENCIA	:= Iif(!Empty(cCodCaixa),aDadosBanc[1],""),;
								SE5->E5_CONTA	:= Iif(!Empty(cCodCaixa),aDadosBanc[2],""),;
								MsUnlock()) }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a rotina para compensacao das NCC com parametro == 3 que eh a  ³
		//³ Compensacao de titulos de mesma carteira (RA/NCC), passando um array ³
		//³ com os titulos que deverao ser baixados e os titulos que serao       ³
		//³ compensados                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaIntBxCR( 	3, 		aRecnoSE1, 	Nil, 		aRecnoNCC,;
					Nil, 	Nil,		bGravaMoeda,Nil,;
					Nil,	Nil,		Nil,		Nil,;
					Nil,	Nil,		Nil  )
		lRetorno := .T.
	EndIf
EndIf

If Len(aListDropTitles) > 0

	// Alterna tipo de operacao: Recebimento/Estorno
	For nI := 1 To Len(aListDropTitles)
		cParametros := ""
		For nY := 1 To Len(aListDropTitles[nI])
			cParametros += IIF(nY <> 1, ", ", "") + "aListDropTitles[" + AllTrim(Str(nI)) + "][" + AllTrim(Str(nY)) + "]"
		Next nY

		lRetorno := Eval(&("{|| LJRecBXSE1(" + cParametros + ")}"))
		// Se houver falha, abandona a rotina
		If !lRetorno
			Exit
		EndIf
	Next nI
EndIf
Return lRetorno

//--------------------------------------------------------------------------------
/*/{Protheus.doc} LjxRTefDt()
Retorno dos dados do TEF
@type 		Function
@version 	P12
@since   	02/03/2017
@author		Varejo
@return	lRet
/*/
//---------------------------------------------------------------------------------
Function LjxRTefDa(	aAuxDados	,	aPagamentos	,	aNSUVndTef	,	lUsaTef		,;
					cTipTef		,	nColId	 	,	nPosRetCart , 	nPosPagto	,;
					aPagDig		)
Local cNSU			:= ""
Local nPosAux		:= 0
Local nY			:= 0
Local cAutoriz		:= ""

Default aAuxDados	:= {}	
Default aPagamentos	:= {}
Default aNSUVndTef	:= {}
Default lUsaTef		:= .F.
Default cTipTef		:= ""
Default nColId	 	:= 0
Default nPosRetCart	:= 0 
Default nPosPagto	:= 0
Default aPagDig 	:= {}	//Informações de Pagamentos Digitais

Aadd(aAuxDados , Array(10))
nY := Len(aAuxDados)
aFill(aAuxDados[nY], "")

If AllTrim(aPagamentos[nPosPagto][3]) $ _FORMAPGDG .And. Len(aPagDig) > 0 //Pagamento Digital
	
	nPosAux := aScan(aPagDig, {|x| AllTrim(x[1,2]) == aPagamentos[nPosPagto][nColId] }) //ID

	If nPosAux > 0
		aAuxDados[nY][ 1] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="DATATEF"	})][2]
		aAuxDados[nY][ 2] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="HORATEF"	})][2]
		aAuxDados[nY][ 3] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="DOCTEF"	})][2]
		aAuxDados[nY][ 4] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="AUTORIZ"	})][2]
		aAuxDados[nY][ 5] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="INSTITU"	})][2]
		aAuxDados[nY][ 6] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="NSUTEF"	})][2]
		aAuxDados[nY][ 7] := AllTrim(aPagamentos[nPosPagto][3])												// _FORMAPGDG
		aAuxDados[nY][ 8] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="FORMAID"	})][2]
		aAuxDados[nY][ 9] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="BANDEIR"	})][2]
		aAuxDados[nY][10] := aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="REDEAUT"	})][2]

		aAdd( aAuxDados[nY], aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="TRNID"	})][2] ) //11-TRNID (Payment Hub)
		aAdd( aAuxDados[nY], aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="TRNPCID"	})][2] ) //12-TRNPCID (Payment Hub)
		aAdd( aAuxDados[nY], aPagDig[nPosAux][aScan(aPagDig[nPosAux], {|x| AllTrim(x[1])=="TRNEXID"	})][2] ) //13-TRNEXID (Payment Hub)
	EndIf

ElseIf Len(aNSUVndTef) > 0

	nPosAux := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPagamentos[nPosPagto][3])+aPagamentos[nPosPagto][nColId]}) //Forma + ID
	If nPosAux > 0
		cNSU 	 := aNSUVndTef[nPosAux][4]
		cAutoriz := aNSUVndTef[nPosAux][5]
		aAuxDados[nY][ 1] := Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) //AAAAMMDD
		aAuxDados[nY][ 2] := StrTran(Time(),":","") //HHMMSS
		aAuxDados[nY][ 3] := cNSU 		//Doc TEF
		aAuxDados[nY][ 4] := cAutoriz 	//Autorização
		aAuxDados[nY][ 5] := ""	 		//Instituição
		aAuxDados[nY][ 6] := cNSU 		//Nsu TEF
		aAuxDados[nY][ 7] := aNSUVndTef[nPosAux][1]	//Tipo de Cartao
		aAuxDados[nY][ 8] := aNSUVndTef[nPosAux][2]	//ID
		aAuxDados[nY][ 9] := ""	//Código Adm.  (Bandeira)
		aAuxDados[nY][10] := ""	//Código Rede. (Adquirência)
	Else
		LjGrvLog(Nil,"Recebimento - Não existem dados de digitação manual do cartão",aNSUVndTef)
	EndIf
Else
	If lUsaTef
		 If cTipTef == TEF_CLISITEF .And. (nPosRetCart > 0)
		 	aAuxDados[nY][ 1] := Dtos(oTef:aRetCartao[nPosRetCart]:DDATATRANS)
		 	aAuxDados[nY][ 2] := oTef:aRetCartao[nPosRetCart]:CHORATRANS
			aAuxDados[nY][ 3] := oTef:aRetCartao[nPosRetCart]:CNSUAUTOR
			aAuxDados[nY][ 4] := oTef:aRetCartao[nPosRetCart]:CAUTORIZA
			aAuxDados[nY][ 5] := oTef:aRetCartao[nPosRetCart]:CDESCADM
			aAuxDados[nY][ 6] := oTef:aRetCartao[nPosRetCart]:CNSUSITEF
			aAuxDados[nY][ 7] := oTef:aRetCartao[nPosRetCart]:CFORMA
			aAuxDados[nY][ 8] := oTEF:aRetCartao[nPosRetCart]:CIDCART
			aAuxDados[nY][ 9] := oTef:aRetCartao[nPosRetCart]:CTIPCART
			aAuxDados[nY][10] := oTef:aRetCartao[nPosRetCart]:CCODREDE
		 ElseIf Len(aTefDados) > 0
		 	If nPosRetCart = 0
		 		nPosRetCart := 1
		 	EndIf
		 	aAuxDados[nY][ 1] := aTefDados[nPosRetCart][02]
		 	aAuxDados[nY][ 2] := aTefDados[nPosRetCart][03]
			aAuxDados[nY][ 3] := aTefDados[nPosRetCart][05]
			aAuxDados[nY][ 4] := aTefDados[nPosRetCart][05]
			aAuxDados[nY][ 5] := aTefDados[nPosRetCart][08]
			aAuxDados[nY][ 6] := aTefDados[nPosRetCart][09]
			aAuxDados[nY][ 7] := aTefDados[nPosRetCart][10]
			aAuxDados[nY][ 8] := aTefDados[nPosRetCart][14]
			aAuxDados[nY][ 9] := aTefDados[nPosRetCart][08]	//Código da Administradora	(Bandeira)
			aAuxDados[nY][10] := aTefDados[nPosRetCart][11]	//Código da Rede			(Adquirência)
		 EndIf
	EndIf
EndIf

Return aAuxDados

//-----------------------------------------------------------
/*/{Protheus.doc} LjEstTroco
@type Function
@description Estorna o movimento de troco da tabela SE5
@param nRecTroco - Registro referente ao movimento a ser estornado
@param nEstDel - Indica se o troco será estornado ou deletado da tabela SE5
@author cleyton.alves
@since 19/05/2017
@version 12.116
/*/
//-----------------------------------------------------------
Function LjEstTroco(nRecTroco,nEstDel)
Local lRet 		:= .T.
Local cHistEst  := ""               //Historico do estorno
Local cRecPag   := ""               //Receber ou Pagar
Local aEstSE5   := {}               //Estrutura da tabela SE5
Local nW        := 0                //Contador
Local aAreaSE5  := SE5->(GetArea()) //Guarda registro da SE5
Local aAreaTmp  := GetArea()        //Guarda registro atual
Local cMsgErro 	:= ""

Default nEstDel := 1                //1=Estorna; 2=Deleta

SE5->(dbGoto(nRecTroco))

If ExistFunc("LjNewGrvTC") .And. LjNewGrvTC() //Verifica se o sistema está atualizado para executar o novo procedimento para gravação dos movimentos de troco.
	lRet := LjTrocoExc(SE5->(Recno()), 6, @cMsgErro )
	If !lRet
		Final(cMsgErro)
	EndIf
Else
	If nEstDel == 2
		//Deleta registro da SE5
		RecLock("SE5",.F.)
		SE5->(dbDelete()) 
		SE5->(MsUnLock())
	Else
		cHistEst := STrTran(STR0183," ","")+"-"+SE5->E5_HISTOR //ESTORNO+Historico do troco
		cRecPag  := Iif(SE5->E5_RECPAG == "R","P","R")

		dbSelectArea("SE5")
		dbSetOrder(1)
		For nW := 1 to SE5->( Fcount() )
			AAdd( aEstSE5, SE5->( FieldGet(nW) ) )
		Next
		
		//?¨
		//? Grava o registro de estorno                         ?
		//??
		RecLock("SE5" ,.T.)
		For nW := 1 to SE5->(Fcount())
			SE5->( FieldPut( nW,aEstSE5[nW]))
		Next
		SE5->E5_FILIAL  := xFilial("SE5")
		SE5->E5_TIPODOC := "ES"
		SE5->E5_RECPAG  := cRecPag
		SE5->E5_HISTOR  := cHistEst  //"Cancel. de Compensacao"
		SE5->E5_DATA    := dDatabase
		SE5->E5_DTDIGIT := dDataBase
		SE5->E5_DTDISPO := dDataBase
		
		MsUnlock()
	
	EndIf
EndIf

RestArea(aAreaSE5)
RestArea(aAreaTmp)

Return lRet
//--------------------------------------------------------------------------------
/*/{Protheus.doc} LjxRecGTit()
Retorna o array statico de titulos "aTitulo"
@type 		Function
@version 	P11.8
@since   	11/03/2017
@autor		albertod
@return		aRet
/*/
//---------------------------------------------------------------------------------
Function LjxRecGTit() 
Return aTitulo

//-----------------------------------------------------------
/*/{Protheus.doc} LjSldNCC
@type Function
@description Rotina para acumular saldo das NCCs
@param aRecnoNCC - Array  referente a NCCs
@author rogerio.candisani
@since 31/08/2017
@version P12
/*/
//-----------------------------------------------------------
Function LjSldNCC(aRecnoNCC)

Local nSldNCC  := 0       //Saldo das NCCs
Local nx       := 0       //Contador
Local aAreaSE1  := SE1->(GetArea()) //Guarda registro da SE5

dbSelectArea("SE1")
SE1->(dbSetOrder(1))

//soma o saldo das NCCs
For nx := 1 to len(aRecnoNCC)
	SE1->(dbGoto(aRecnoNCC[1]))
	nSldNCC := nSldNCC + SE1->E1_SALDO
Next nx

RestArea(aAreaSE1)

Return nSldNCC

//--------------------------------------------------------
/*/{Protheus.doc} LjCompFKs
Altera os campos para utilizar o padrao do SigaLoja
	
@author  Leandro Kenji
@version P12.1.17
@since   13/11/2017
@return  n/a
/*/
//--------------------------------------------------------
Static Function LjCompFKs()

Local aArea			:= GetArea()
Local aAreaFKA		:= FKA->( GetArea() )
Local cProcFKA		:= FKA->FKA_IDPROC
Local cRotBx		:= "LOJXREC" 

//Atualiza campos das FKs
dbSelectArea("FKA")
FKA->( dbSetOrder(2) )
FKA->( dbSeek( xFilial("FKA") + cProcFKA ) )
While FKA->( !EOF() ) .AND. ( xFilial("FKA") + cProcFKA == FKA->FKA_FILIAL + FKA->FKA_IDPROC )

	If FKA->FKA_TABORI == "FK1"
	
		//Posiciona na tabela e altera os campos
		DbSelectArea("FK1")
		FK1->( dbSetOrder(1) )
		If FK1->( dbSeek( xFilial("FK1") + FKA->FKA_IDORIG ) )

			RecLock("FK1",.F.)
			FK1->FK1_ORIGEM := cRotBx
			FK1->( MsUnLock() )

		EndIf

	ElseIf FKA->FKA_TABORI == "FK5"

		//Posiciona na tabela e altera os campos
		DbSelectArea("FK5")
		FK5->( dbSetOrder(1) )
		If FK5->( dbSeek( xFilial("FK5") + FKA->FKA_IDORIG ) )

			RecLock("FK5",.F.)
			FK5->FK5_ORIGEM := cRotBx
			FK5->( MsUnLock() )

		EndIf

	ElseIf FKA->FKA_TABORI == "FK3"
	
		//Posiciona na tabela e altera os campos
		DbSelectArea("FK3")
		FK3->( dbSetOrder(1) )
		If FK3->( dbSeek( xFilial("FK3") + FKA->FKA_IDORIG ) )

			RecLock("FK3",.F.)
			FK3->FK3_ORIGEM := cRotBx
			FK3->( MsUnLock() )

		EndIf


	ElseIf FKA->FKA_TABORI == "FK4"

		//Posiciona na tabela e altera os campos
		DbSelectArea("FK4")
		FK4->( dbSetOrder(1) )
		If FK4->( dbSeek( xFilial("FK4") + FKA->FKA_IDORIG ) )

			RecLock("FK4",.F.)
			FK4->FK4_ORIGEM := cRotBx
			FK4->( MsUnLock() )

		EndIf


	EndIf

	FKA->( dbSkip() )

End

RestArea(aAreaFKA)
RestArea(aArea)

Return


//--------------------------------------------------------
/*/{Protheus.doc} LjGrFormPg
Responsável por gravar os campos E5_FORMAPG, E_ORIGEM e E5_FILORIG referene aos registros de Juros, Multa e Desconto
no Recebimento de Titulo
    
@author  João Marcos Martins
@version P12.1.17
@since   15/03/2018
@return  
/*/
//--------------------------------------------------------
Static Function LjGrFormPg( nRecnoSE5, cFrmPag, cOrigem ,cFilAntSE5 )

Local aAreaSE5 := SE5->( GetArea() )
Local cChave   := SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA

SE5->( dbSetOrder(7) )
    
If SE5->( dbSeek(cChave) )  
    
    While SE5->(!EOF()) .AND. SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA == cChave
        
        If Empty(SE5->E5_FORMAPG)           
            RecLock("SE5",.F.)
            SE5->E5_FORMAPG := AllTrim(cFrmPag)
            SE5->E5_ORIGEM  := cOrigem
            If Empty(SE5->E5_FILORIG)
                SE5->E5_FILORIG := cFilAntSE5
            EndIf
            SE5->( MsUnlock() ) 
        EndIf
        
        SE5->( dbSkip() )   
            
    EndDo
        
EndIf
        
RestArea( aAreaSE5 )

Return
//-----------------------------------------------------------
/*/{Protheus.doc} LjxRecRpc
@type Function
@description Rotina para criar uma conexao via Rpc para verificar os Titulos do recebimento
@param aTitulos - Array com os titulos pesquisados 
@author Vendas Varejo
@return	lRet - Caso o Titulos esteja em aberto na retaguarda o retorno será falso 
@since 20/02/2018
@version 11.8
/*/
//-----------------------------------------------------------
Static Function LjxRecRpc(aTitulos)
Local lRet     		:= .F.
Local aParRpc  		:= LjGetStation({"RPCSRV", "RPCPORT", "RPCENV", "RPCEMP","RPCFIL" })
Local cRPCServer	:= ""
Local nRPCPort      := 0
Local cRPCEnv       := ""
Local oRPConnect
Local lConnect      := .F.

If Len(aParRpc) >= 3 .And. Len(aTitulos) > 0
	cRPCServer	:= aParRpc[1]
	nRPCPort	:= Val(aParRpc[2])
	cRPCEnv		:= aParRpc[3]
	
	oRPConnect:=FwRpc():New( cRPCServer, nRPCPort , cRpcEnv ) 
	
	oRPConnect:SetRetryConnect(1)
	
	lConnect := oRPConnect:Connect()
	
	If ValType(lConnect) <> "L"
		lConnect := .F. 
	EndIf 
	
	If lConnect
		oRPConnect:CallProc("RPCSetType", 3 )
		oRPConnect:SetEnv(cEmpAnt, cFilAnt,"FRT")
		
		lRet := oRPConnect:CallProc("LjxVldSE1", aTitulos )
		
		If ValType(lRet) <> "L" 
			lRet := .F.
		EndIf 
		// Desconecta do servidor
		oRPConnect:Disconnect()
	Else
		LjGrvLog("LojxRec" ,"Não foi possivel realizar a conexão via RPC.",aTitulo )			
	EndIf 	
	
	oRPConnect := Nil  // Limpo o objeto
	
EndIf 

Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} LjxVldSE1
@type Function
@description Rotina para criar uma conexao via Rpc para verificar os Titulos do recebimento
@param aTitulos - Array com os titulos pesquisados 
@author Rene Julian
@return	lRet - Caso o Titulos esteja em aberto na retaguarda o retorno será falso 
@since 20/02/2018
@version 11.8
/*/
//-----------------------------------------------------------
Function LjxVldSE1(aTitulo)
Local lRet := .F.
Local nX   := 0

Default aTitulo := {}

If Len(aTitulo) > 0
	For nX := 1 To Len(aTitulo)
		If aTitulo[nX][1] 
			DbSelectarea("SE1")
			DbSetOrder (1)			
			If DbSeek(xFilial("SE1") + aTitulo[nX][2] + aTitulo[nX][3] +aTitulo[nX][4] + aTitulo[nX][11]) // Filial + Prefixo + Num Tit + Parcela + Tipo				
				If !Empty(SE1->E1_BAIXA) .AND. SE1->E1_BAIXA == dDataBase					
					lRet := .T.
				Else // Caso nao esteja baixado ou a baixa nao seja a mesma do dia o Retorno sera falso.					
					LjGrvLog("LOJXREC" ,"O titulo (PREFIXO: "+ aTitulo[nX][2]+ ", NUMERO:" + aTitulo[nX][3] + ", PARCELA:" + aTitulo[nX][4] + ", TIPO:"+ aTitulo[nX][11] + ") não foi BAIXADO na retaguarda." )
					lRet := .F.
					Exit
				EndIf
			Else 
				LjGrvLog("LOJXREC" ,"O titulo (PREFIXO: "+ aTitulo[nX][2]+ ", NUMERO:" + aTitulo[nX][3] + ", PARCELA:" + aTitulo[nX][4] + ", TIPO:"+ aTitulo[nX][11] + ") não foi encontrado na retaguarda." )					
			EndIf
		EndIf 
	Next nX
EndIf
LjGrvLog("LOJXREC" ,"Retorno da verificação do titulo na retaguarda. Retorno da função LjxVldSE1:",lRet )
Return (lRet) 

//--------------------------------------------------------------
/*/{Protheus.doc} LjXCEstTef
Chama o cancelamento do TEF no estorno do recebimento de títulos
	
@author  Ronaldo Tapia
@version P12.1.17
@since   05/01/2018
@return  n/a
/*/
//---------------------------------------------------------------
Static Function LjXCEstTef(nValorTot)
Local nX 			:= 1
Local aRetCartBkp 	:= {}
Local lRet 			:= .F.
Local lTefMult	 	:= SuperGetMV("MV_TEFMULT", ,.F.)	            // Identifica se o cliente utiliza múltiplas transações TEF
Local nValorTEF		:= 0
Local aTefTmp   	:= {}

Default nValorTot 	:= 0

/*
Preciso conectar duas vezes na webservice
1. Para verificar se existe a transação TEF na SLV e ela não esta cancelada
2. Caso exista transação, chama o cancelamento do TEF e alimento os campos do cancelamento no objeto oSvc:oWsaDadosSLV
*/

If nModulo == 23 .And. len(aDadosTef) > 0
	// Inicia conexao com o WebService
	If ValType(oSvc) <> "O"
		oSvc      := WSLJRECEB():New()
        iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
		oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"
	EndIf
			
	If Type("oSvc:oWsaDadosSLV") == "O" //Verifica se existe a estrutura aDadosSLV [apenas uma protecao caso o fonte WSC_LJRECEB.PRW (client deste WS) nao esteja atualizado com as alteracoes necessarias]
		// Antes de chamar o metodo WS, atribui os valores as propriedades do array aDadosSLV
		oSvc:oWsaDadosSLV:OWSVERARRAY := LJRECEB_ARRAYOFWSStrutSLV():New()
		oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV	:= Array( Len(aDadosTef) )
	
		For nX := 1 To Len(aDadosTef)
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX] := LJRECEB_WSStrutSLV():New()
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cFORMA		:= aDadosTef[nX][09]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:nVALOR		:= aDadosTef[nX][10]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDATATEF	:= aDadosTef[nX][11]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cHORATEF	:= aDadosTef[nX][12]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDOCTEF		:= aDadosTef[nX][13]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cAUTORIZ	:= aDadosTef[nX][14]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cINSTITU	:= aDadosTef[nX][15]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cNSUTEF		:= aDadosTef[nX][16]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cTIPCART	:= aDadosTef[nX][17]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cSEQOPER	:= aDadosTef[nX][18]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:nRECSE5		:= aDadosTef[nX][19]
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:lCANTEF		:= .T. // Cancelamento TEF
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDOCCANC	:= "" 	
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cHORCANC	:= "" 	
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDATCANC	:= "" 
			If Len(aDadosTef[nX])>=24
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cBANDEIRA	:= aDadosTef[nX][23]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cREDEAUT	:= aDadosTef[nX][24]
			EndIf
			
			nValorTEF += aDadosTef[nX][10]
			
		Next nX
		
		// Grava tabela SLV via WebService
		lRet := oSvc:GravaTabSLV( cEmpAnt, cFilAnt)
		If !lRet
			cSvcError := GetWSCError()
			If Left(cSvcError,9) == "WSCERR048"
				cSoapFCode  := GetWSCError(2)
				cSoapFDescr := GetWSCError(3)
		 		MsgStop(cSoapFDescr, cSoapFCode)
			Else
				//"Sem comunicação com o WebService!", "Atenção!"
				MsgStop(STR0029,STR0030)
			Endif
		EndIf
	EndIf
EndIf

If lRet .And. MsgYesNo(STR0108 + Transform(nValorTEF, "9,999.99") + "?")
	If cTipTEF $ TEF_CLISITEF
		oTEF:Operacoes("CANCEL_VENDA", {})
		lTefOk := oTef:lTefOk
		aRetCartBkp:=oTEF:ARETCARTAO
		If lTefOk
			oTEF:ImpCupTef()
			lTefOk	:= oTef:lTefOk
		EndIf					
	ElseIf	cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO
		lTefOk	:= LOJA011T( .T., @aTefTmp, .T. )
	EndIf

	If lTefOk .And. nModulo == 23
		// Inicia conexao com o WebService
		If ValType(oSvc) <> "O"
			oSvc      := WSLJRECEB():New()
            iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autenticação do Web Service
			oSvc:_URL := "http://"+LJGetStation("WSSRV")+"/LJRECEB.apw"
		EndIf
		
		If Type("oSvc:oWsaDadosSLV") == "O" //Verifica se existe a estrutura aDadosSLV [apenas uma protecao caso o fonte WSC_LJRECEB.PRW (client deste WS) nao esteja atualizado com as alteracoes necessarias]
			// Antes de chamar o metodo WS, atribui os valores as propriedades do array aDadosSLV
			oSvc:oWsaDadosSLV:OWSVERARRAY := LJRECEB_ARRAYOFWSStrutSLV():New()
			oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV	:= Array( Len(aDadosTef) )

			For nX := 1 To Len(aDadosTef)
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX] := LJRECEB_WSStrutSLV():New()
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cFORMA		:= aDadosTef[nX][09]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:nVALOR		:= aDadosTef[nX][10]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDATATEF	:= aDadosTef[nX][11]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cHORATEF	:= aDadosTef[nX][12]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDOCTEF		:= aDadosTef[nX][13]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cAUTORIZ	:= aDadosTef[nX][14]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cINSTITU	:= aDadosTef[nX][15]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cNSUTEF		:= aDadosTef[nX][16]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cTIPCART	:= aDadosTef[nX][17]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cSEQOPER	:= aDadosTef[nX][18]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:nRECSE5		:= aDadosTef[nX][19]
				oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:lCANTEF		:= .T. 		//Cancelamento TEF
				If Len(aDadosTef[nX])>=24
					oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cBANDEIRA	:= aDadosTef[nX][23]
					oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cREDEAUT	:= aDadosTef[nX][24]
				EndIf
				
				// Alimenta campos com dados do cancelamento TEF
				If cTipTEF $ TEF_CLISITEF
					oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDOCCANC	:= aRetCartBkp[1]:CDOCCANREI	
					oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cHORCANC	:= aRetCartBkp[1]:CHORATRANS	
					oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDATCANC	:= IIf(!Empty(aRetCartBkp[1]:DDATACANREI),DTOS(aRetCartBkp[1]:DDATACANREI),DTOS(aRetCartBkp[1]:DDATATRANS))
				ElseIf	cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO
					If lTefMult
						oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDOCCANC	:= aTefTmp[1][7][1][6]	
						oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cHORCANC	:= aTefTmp[1][7][1][7]
						oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDATCANC	:= aTefTmp[1][7][1][12]	
					Else
						oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDOCCANC	:= aTefTmp[1][6]
						oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cHORCANC	:= aTefTmp[1][7]
						oSvc:oWsaDadosSLV:OWSVERARRAY:OWSWSStrutSLV[nX]:cDATCANC	:= aTefTmp[1][12]
					EndIf		
				EndIf				
				
			Next nX
	
			// Grava tabela SLV via WebService
			lRet := oSvc:GravaTabSLV( cEmpAnt, cFilAnt)
			If !lRet
				cSvcError := GetWSCError()
				If Left(cSvcError,9) == "WSCERR048"
					cSoapFCode  := GetWSCError(2)
					cSoapFDescr := GetWSCError(3)
	 				MsgStop(cSoapFDescr, cSoapFCode)
				Else
					//"Sem comunicação com o WebService!", "Atenção!"
					MsgStop(STR0029,STR0030)
				Endif
			EndIf
		EndIf
	EndIf
Else
	MsgAlert(STR0052,STR0030) // "Transação TEF não efetuada, favor reter o cupom!", "Atenção"
EndIf

If !lTefOk
	MsgAlert(STR0052,STR0030) // "Transação TEF não efetuada, favor reter o cupom!", "Atenção"
EndIf

// Limpo array com os dados da transação TEF
aDadosTef := {}
	
Return

//--------------------------------------------------------------
/*/{Protheus.doc} LjXCEstTef
@type Function
@description - Verifica se foi dado baixa pelo financeiro
@author  Rene Julian
@since   27/08/2019
@version P12.1.17
@param aTitulo , array , contendo titulos do SE1 para baixa ou estorno
@param nPos , Numerico , Posição do titulo a ser selecionado.
@return  Logico, se não houve baixa pelo financeiro Verdadeiro 
/*/
//---------------------------------------------------------------

Static Function LjVldTit(aTitulo, nPos)
Local lRet		:= .T.
Local aAreaSE1	:= SE1->(Getarea())
Local aAreaSE5	:= SE5->(Getarea())
Local cTipoDoc	:= ""
Local aBxTit	:= {}
Local lcompensa := .F.
Local cQuery	:= ''				
Local cAliasSE5	:= GetNextAlias()	
Local cFilAtual	:= FWCodFil()		// Retorna Empresa + Unidade Negocio + Filial
Local lBxOutFil	:= .F.				// Indica baixa em outra Filial

If Len(aTitulo) > 0 .and. nPos > 0

	DbSelectArea("SE1") 
	DbSetOrder(1)	//Filial + Prefixo + Numero + Parcela + Tipo
	If DbSeek(aTitulo[nPos][TIT_FILI] + aTitulo[nPos][TIT_PREF] + aTitulo[nPos][TIT_NUME] + aTitulo[nPos][TIT_PARC] + aTitulo[nPos][TIT_TIPO] )

		If !Empty(SE1->E1_BAIXA) // já existe uma baixa parcial do Título 
	
			If SE1->E1_FILIAL == xFilial("SE5")
				cTipoDoc := "V2 /BA /RA /CP /LJ /"
			Else
				cTipoDoc := "VL /V2 /BA /RA /CP /LJ /"
			EndIf
			aBaixaSE5 := {}
			aBxTit := Sel070Baixa( cTipoDoc+MV_CRNEG						,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
										SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
										SE1->E1_LOJA						,NIL				,NIL			,NIL,;
										NIL									,.T.	)
			If Len(aBxTit) == 0	.And. Len(aBaixaSE5) == 0 // procuro um movimento de compesação pois a rotina do financeiro não retorna movimento de Ncc
				SE5->(DbSetOrder(2))	//E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
				If SE5->(DbSeek(xFilial("SE5")+"CP"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO ))

					If AllTrim(SE5->E5_ORIGEM) $ ("LOJA701 / LOJXREC")
						lCompensa := .T.
					Endif
				EndIf
			ElseIf Len(aBxTit) > 0 .OR. Len(aBaixaSE5) > 0 
				/* 	
					Faz a busca dos registros da baixa para confirmar se a baixa foi feita nesta filial ou em outra
					Para isso verifica a existência dos registro com E5_TIPODOC = BA também em outra filial
					caso exista somente o registro BA indica que o título foi pago em outra filial
				*/
				SE5->(DbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
				cChaveSE5 := xFilial("SE5") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA

				If SE5->(DbSeek( cChaveSE5 ))
					
					cQuery += "SELECT E5_FILIAL, E5_FILORIG, E5_PREFIXO, E5_NUMERO, "
					cQuery += "E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_TIPODOC "
					cQuery += "FROM " + RetSQLName('SE5') + " "
					cQuery += "WHERE E5_PREFIXO	= '" + SE1->E1_PREFIXO + "' "
					cQuery += "AND E5_NUMERO	= '" + SE1->E1_NUM + "' 	"
					cQuery += "AND E5_PARCELA	= '" + SE1->E1_PARCELA + "' "
					cQuery += "AND E5_TIPO		= '" + SE1->E1_TIPO + "' 	"
					cQuery += "AND E5_CLIFOR	= '" + SE1->E1_CLIENTE + "' "
					cQuery += "AND E5_LOJA		= '" + SE1->E1_LOJA + "' 	"					
					cQuery += "AND " + '( ' + "E5_TIPODOC	= 'VL' 	"	
					cQuery += "OR  E5_TIPODOC	= 'BA' " + ' )'	+ "						

					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.F.,.F.)

					While (cAliasSE5)->(!EOF())
						// E5_TIPODOC	= 'VL' - Filial onde foi recebido título
						If (Alltrim((cAliasSE5)->E5_TIPODOC) == "VL") .AND. (Alltrim((cAliasSE5)->E5_FILORIG) <> Alltrim(cFilAtual))
							lBxOutFil := .T.
							Exit
						EndIf						
						(cAliasSE5)->(dbSkip())
					EndDo

					If !lBxOutFil
						lCompensa := .T.
					EndIf

				EndIf

			EndIf

			lRet := lCompensa // Se houve baixa pelo loja
		
		EndIf
	EndIf		
	
	RestArea(aAreaSE1)
	RestArea(aAreaSE5)
	
EndIf

Return lRet

//--------------------------------------------------------------
/*/{Protheus.doc} LjEstSelE5
Transcreve de string para array, os dados de identificação do título que será estornado.

@type 		Function
@author  	Alberto Deviciente
@since   	30/03/2020
@version 	P12
@param 		cListBox, Caractere, String com os dados de identificação do título que será estornado.
@return  	Array, Array com os dados de identificação do título que será estornado. Estrutura do array de retorno:
					aRet[1] //01-Prefixo
					aRet[2] //02-Numero
					aRet[3] //03-Parcela
					aRet[4] //04-Tipo
					aRet[5] //05-Cliete
					aRet[6] //06-Loja
					aRet[7] //07-Data
					aRet[8] //08-Valor
					aRet[9] //09-Sequencia
/*/
//---------------------------------------------------------------
Static Function LjEstSelE5(cListBox)
Local aRet 		:= {}
Local nPosIni	:= 1
Local nPosFim 	:= 1
Local cCharDe 	:= Space(2)
Local cCharPara	:= Space(1) 	
Local nTamCampo := 0

nTamCampo 	:= TamSX3("E5_PREFIXO")[1]
aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //01-Prefixo
cListBox	:= SubStr(cListBox,nTamCampo+2)

nTamCampo 	:= TamSX3("E5_NUMERO")[1]
aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) )	//02-Numero
cListBox	:= SubStr(cListBox,(nTamCampo*2)+2) //Multiplica por 2 para considerar o dobro do tamanho do campo E5_NUMERO, pois é assim que vem da função Sel070Baixa do FINA070

nTamCampo 	:= TamSX3("E5_PARCELA")[1]
aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //03-Parcela
cListBox	:= SubStr(cListBox,nTamCampo+2)

nTamCampo 	:= TamSX3("E5_TIPO")[1]
aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //04-Tipo
cListBox	:= SubStr(cListBox,nTamCampo+2)

nTamCampo 	:= TamSX3("E5_CLIFOR")[1]
aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //05-Cliete
cListBox	:= SubStr(cListBox,nTamCampo+2)

nTamCampo 	:= TamSX3("E5_LOJA")[1]
aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //06-Loja
cListBox	:= SubStr(cListBox,nTamCampo+2)

//Substitui 2 espaços por apenas 1 espaço para facilitar e agilizar no laço while a seguir usando a função AT()
While ( At(cCharDe , cListBox ) ) > 0
	cListBox := Replace(cListBox,cCharDe,cCharPara)
End

cListBox := cListBox + " " //Adiciona um espaço no final como separador de conteúdo.

//Adiciona as posições 7, 8 e 9 no array aRet
While ( nPosFim := At(" " , cListBox, nPosIni ) ) > 0
	aAdd( aRet, SubStr(cListBox,nPosIni,nPosFim-nPosIni) )
	nPosFim ++
	nPosIni := nPosFim
End

aRet[9] := PadR(aRet[9], TamSX3("E5_SEQ"	)[1])	//09-Sequencia

Return aRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n   ³ GrabLogHsr³ Autor ³ Diego Fernando Rivero ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Grabacion de Log                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HASAR SMH/PL-8F y SMHP-PR4F                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GrabLogHsr( cText )
Local cFile	:= '\LOGHASAR\'

xNumCaixa()

cFile += SA6->A6_COD + SubStr(  Dtos( dDataBase ), 5 ) + '.LOG'

If !File(cFile)
	nHnd	:= FCreate( cFile )
Else
	nHnd	:= FOpen( cFile, 2 )
EndIf

FSeek( nHnd, 0, 2 )
FWrite( nHnd, Time() + '  ' + cText + Chr(13) + Chr(10) )

FClose( nHnd )

Return


//--------------------------------------------------------------
/*/{Protheus.doc} LjSE5JMD
@type Function
@description - Caso encontrado alguma baixa parcial com juros, multa ou desconto
               a partir de LjBuscaJMD(),
			   os parâmetros juros/multa/desconto, anteriormente gravados o que estavam em SE1,
			   serão substituídos pela soma de juros/multa/desconto em SE5.
			O registro SE1 deverá estar posicionado para pesquisa.
			Esta função foi criada justamente por ter dois fluxos idênticos (MV_LJRECFI = .T. e MV_LJRECFI = .F.)
@author  marisa.cruz
@since   20/04/2021
@version P12.1.27
@param	nE1Multa, Numérico, Valor da Multa no título recebida como Par. Referência
@param	nE1Juros, Numérico, Valor dos Juros no título recebida como Par. Referência
@param	nE1Desct, Numérico, Valor do Desconto no título recebida como Par. Referência
@param	lDescFin, Lógico, Se aplicado E1_DESCFIN (Desconto Financeiro) na Condição de Pagamento
@return  nil 
/*/
//---------------------------------------------------------------
Static Function LjSE5JMD(nE1Multa,nE1Juros,nE1Desct,lDescFin)

Local aInfoJMD := {}
Local nValDif	:= 0
Local aArea		:= GetArea()

Default nE1Multa := 0
Default nE1Juros := 0
Default nE1Desct := 0
Default lDescFin := .F.

aInfoJMD := LjBuscaJMD()	//Leitura de Juros, Multa e Desconto do tipo VL da SE5

If Len(aInfoJMD) >= 3 .AND. (aInfoJMD[1] <> 0 .OR. aInfoJMD[2] <> 0 .OR. aInfoJMD[3] <> 0)	//Caso encontrado juros/multa/desconto preenchidos na SE5
	nE1Juros := aInfoJMD[1]
	nE1Multa := aInfoJMD[2]
	nE1Desct := Iif(lDescFin, nE1Desct, aInfoJMD[3])
	nValDif := Round(SE1->E1_VALLIQ - (SE1->E1_VALOR + nE1Multa + nE1Juros - nE1Desct - SE1->E1_SALDO),2)

	//Balizador de Centavos
	//Distribuir a diferença de 1 a 3 centavos para igualar o valor líquido corretamente
	If ((nValDif >= 0.01) .AND. (nValDif <= 0.03)) .OR. ((nValDif <= -0.01) .AND. (nValDif >= -0.03))
		If nE1Desct >= Abs(nValDif)
			nE1Desct -= nValDif
		ElseIf nE1Juros >= Abs(nValDif)
			nE1Juros += nValDif
		ElseIf nE1Multa >= Abs(nValDif)
			nE1Multa += nValDif
		EndIf
	EndIf
EndIf		//Caso Contrário, manterá o que está gravado na SE1 pelos 3 parâmetros de referência nE1Multa, nE1Juros e nE1Desct.

RestArea(aArea)
Return nil


//--------------------------------------------------------------
/*/{Protheus.doc} LjBuscaJMD
@type Function
@description - Verifica, nas baixas da SE5, se foi gravado Juros, Multa ou Desconto.
			   Baseado na função LjVldTit()
			   O registro SE1 deverá estar posicionado para pesquisa.
@author  marisa.cruz
@since   20/04/2021
@version P12.1.27
@param nil
@return  Array, {Valor dos Juros SE5, Valor da Multa SE5, Valor do Desconto SE5} 
/*/
//---------------------------------------------------------------
Static Function LjBuscaJMD()
Local aArea		:= GetArea()
Local cTipoDoc	:= ""
Local aBxTit	:= {}							//Retorno do Título Baixado em Sel070Baixa()
Local cQuery	:= ''				
Local cAliasSE5	:= GetNextAlias()	
Local cChaveSE5 := ""
Local aRet		:= {0,0,0}						//Juros,Multa,Desconto

If !Empty(SE1->E1_BAIXA) // já existe uma baixa parcial do Título 

	If SE1->E1_FILIAL == xFilial("SE5")
		cTipoDoc := "V2 /BA /RA /CP /LJ /"
	Else
		cTipoDoc := "VL /V2 /BA /RA /CP /LJ /"
	EndIf
	aBaixaSE5 := {}
	aBxTit := Sel070Baixa( cTipoDoc+MV_CRNEG						,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
								SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
								SE1->E1_LOJA						,NIL				,NIL			,NIL,;
								NIL									,.T.	)
	If Len(aBxTit) > 0 .OR. Len(aBaixaSE5) > 0 
		/* 	
			Faz a busca dos registros da baixa se E5_TIPODOC = 'VL', para somar juros, multa e desconto
		*/
		SE5->(DbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
		cChaveSE5 := xFilial("SE5") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA

		If SE5->(DbSeek( cChaveSE5 ))
			
			cQuery += "SELECT E5_FILIAL, E5_FILORIG, E5_PREFIXO, E5_NUMERO, "
			cQuery += "E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_TIPODOC, "
			cQuery += "E5_MOTBX, E5_DTCANBX, E5_VLMULTA, E5_VLJUROS, E5_VLDESCO "
			cQuery += "FROM " + RetSQLName('SE5') + " "
			cQuery += "WHERE E5_FILORIG	= '" + SE1->E1_FILIAL  + "' "
			cQuery += "AND E5_PREFIXO	= '" + SE1->E1_PREFIXO + "' "
			cQuery += "AND E5_NUMERO	= '" + SE1->E1_NUM + "' 	"
			cQuery += "AND E5_PARCELA	= '" + SE1->E1_PARCELA + "' "
			cQuery += "AND E5_TIPO		= '" + SE1->E1_TIPO + "' 	"
			cQuery += "AND E5_CLIFOR	= '" + SE1->E1_CLIENTE + "' "
			cQuery += "AND E5_LOJA		= '" + SE1->E1_LOJA + "' 	"					
			cQuery += "AND E5_MOTBX  	= 'LOJ' 	"					
			cQuery += "AND E5_DTCANBX	= ' ' 	"					
			cQuery += "AND E5_TIPODOC	= 'BA' 	"
			cQuery += "AND D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.F.,.F.)

			While (cAliasSE5)->(!EOF())
				aRet[1] += (cAliasSE5)->E5_VLJUROS
				aRet[2] += (cAliasSE5)->E5_VLMULTA
				aRet[3] += (cAliasSE5)->E5_VLDESCO
				(cAliasSE5)->(dbSkip())
			EndDo

			(cAliasSE5)->(dbCloseArea())

		EndIf

	EndIf

EndIf

RestArea(aArea)
Return aRet

//--------------------------------------------------------------
/*/{Protheus.doc} ChgBalloon
Cria um balão informativo através do componente FWBalloon.

@type 		function
@author 	Alberto Deviciente
@since 		20/11/2012
@version 	P12

@param oDlg		, Objeto	, Objeto do tipo Dialog da interface onde será montado o FWBalloon
@param oBalloon	, Objeto	, Objeto referência do tipo FWBalloon
@param cTitle	, Caractere	, Título a ser exibido no FWBalloon
@param cText	, Caractere	, Texto a ser exibido no FWBalloon
@param nPosRow	, Numérico	, Posição da linha inicial onde será criado o FWBalloon

@return Nulo
/*/
//--------------------------------------------------------------
Static Function ChgBalloon(oDlg, oBalloon, cTitle, cText, nPosRow)

//Se tiver algum balão criado, fecha para abrir o novo balão que será criado
If oBalloon <> Nil
	oBalloon:Close()
EndIf

//Instacia o componente para criar o balão informativo
oBalloon := FWBalloon():New(nPosRow, 288, 160, 150, oDlg, cTitle, cText, FW_BALLOON_INFORMATION, BALLOON_POS_LEFT_MIDDLE)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STGETSLV
Retorna registro da SLV
@author  caio.okamoto
@since   14/06/2022
@version 12.1.33
@param 	cKey, caractere,  indice 01 da tabela (SLV SLV->LV_FILIAL+LV_PREFIXO+LV_NUMERO+LV_PARCELA)
@return array registro da SLV
/*/
//-------------------------------------------------------------------
Function STGETSLV(cKey)
Local aRet	:={} //array com registro da SLV
Local aArea	:= SLV->(GetArea())

DbSelectArea("SLV")
SLV->(DbSetOrder(1))//SLV->LV_FILIAL+LV_PREFIXO+LV_NUMERO+LV_PARCELA

If SLV->(DbSeek(cKey))			

	While !SLV->(Eof()) .AND. SLV->LV_FILIAL+SLV->LV_PREFIXO+SLV->LV_NUMERO+SLV->LV_PARCELA == cKey 

		Aadd(aRet, SLV->LV_DOCTEF)				//01-DOCTEF 	
		Aadd(aRet, SLV->LV_VALOR) 				//02-Valor Total da transação
		Aadd(aRet, Alltrim(SLV->LV_TRNID)) 		//03-ID da Transação (Payment Hub)
		Aadd(aRet, Alltrim(SLV->LV_TRNPCID)) 	//04-ID Transação Processador (Payment Hub)
		Aadd(aRet, Alltrim(SLV->LV_TRNEXID)) 	//05-ID da Transação Externa (Payment Hub)
		Aadd(aRet, SLV->LV_DATATEF)				//06-Data da Transação
		Aadd(aRet, SLV->LV_FORMA)				//07-Forma de Pagamento
		Aadd(aRet, SLV->(Recno()))				//08-Recnos relacionados a transação
		Aadd(aRet, SLV->LV_SEQOPER)				//09-sequencia da transação

		SLV->(DbSkip())

	EndDo
		
Endif 
SLV->(RestArea(aArea))

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STESTSLV
Grava o estorno do TEF e PD na SLV
@author  caio.okamoto
@since   14/06/2022
@version 12.1.33
@param  aDados, array, nome dos campos e respectivos valores
@param 	cLVSeqOper, caractere, valor do campo LV_SEQOPER 
/*/
//-------------------------------------------------------------------
Function STESTSLV(aDados, cLVSeqOper)

Local aArea	:= SLV->(GetArea())
Local cKey := xFilial("SLV") + cLVSeqOper 

DbSelectArea("SLV")
SLV->(DbSetOrder(2))//SLV->LV_FILIAL+LV_SEQOPER

If SLV->(DbSeek(cKey))			

	While !SLV->(Eof()) .AND. SLV->LV_FILIAL+SLV->LV_SEQOPER == cKey 
		
		Reclock("SLV", .F.)
		Replace SLV->LV_DOCCANC	WITH aDados[1][2]
		Replace SLV->LV_HORCANC	WITH aDados[2][2]
		Replace SLV->LV_DATCANC	WITH aDados[3][2]
		MsUnLock()
		DbSkip()

	EndDo

Endif 

SLV->(RestArea(aArea))

Return
//-----------------------------------------------------------------------
/*/{Protheus.doc} Lj7VNSUDig
Retorna NSC e Autorização digitados, não contém caracteres inválidos

@author  Gilmar Costa
@since 	 18/08/2022
@version P12.17

@param 	 cNSU, Caractere, NSU Digitado 
@param 	 cAutoriz, Caractere, Autorização Digitatada

@return  lRet, Lógico, NSU e Autorização válidos 
/*/
//-----------------------------------------------------------------------
Function Lj7VNSUDig(aParams, cNSU, cAUTORIZ)
Local lRet			:= .T.			// Retorno da Função
Local cCharValid 	:= "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
Local nI			:= 0			// Contador For/Next
Local cChar			:= ""			// Caractere de comparação da string cCharValid	

Default	cNSU		:= ""			// NSU Digitado
Default	cAUTORIZ	:= ""			// Autorização Digitada
Default	aParams		:= {}			// Arrya com informações digitadas

For nI := 1 to Len(cNSU)
	cChar := SubStr(cNSU, nI, 1)
	If !(cChar $ cCharValid)
		MsgAlert(STR0233)   // "Informação digitada no Campo NSU inválida!"
		lRet := .F.
		Exit
	EndIf
Next 

If lRet
	For nI := 1 to Len(cAUTORIZ)
		cChar := SubStr(cAUTORIZ, nI, 1)
		If !(cChar $ cCharValid)
			MsgAlert(STR0234) 	// "Informaçao digitada no Campo AUTORIZAÇÃO inválida!"
			lRet := .F.
			Exit			
		EndIf
	Next
EndIf	

//Ponto de Entrada para permitir customizar a validação quando fechar a tela de digitação do NSU e Cód. de Autorização
If lRet .AND. ExistBlock("LJVNSUAU")
	//Substitui o Valid padrão da tela pela validação do PE "LJVNSUAU"
	lRet := ExecBlock("LJVNSUAU",.F.,.F.,{aParams[1],aParams[2],aParams[3],cNSU,cAUTORIZ}) 
EndIf

Return lRet

