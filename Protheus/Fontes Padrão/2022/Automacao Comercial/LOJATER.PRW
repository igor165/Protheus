#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOJATER  ³ Autor ³ F bio F. Pessoa       ³ Data ³ 22/09/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Servidor de aplica‡„o para Microterminais - Gradual        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Trabalha em conjunto com o Sigaloja                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Dolis         ³10/08/06³104230³Gravacao do campo L2_ITEMSD1            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defines para os acessos indexados as vari veis gerenciais da rede ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define POS    posicao [terminal+1]  // posicao do programa
#define KPIC   pikture [terminal+1]  // picture de teclado
#define KBD    teclado [terminal+1]  // variavel com input de teclado
#define WAITT  waitkbd [terminal+1]  // flag de aguardo de entrada de dados
#define PPIC   pospic  [terminal+1]  // posicao a receber na picture de teclado
#define PPRN   pprinter[terminal+1]
#define SPRN   sprinter[terminal+1]
#define PINP   pinpos  [terminal+1]
#define PINS   sinpos  [terminal+1]
#define POUTP  poutpos [terminal+1]
#define POUTS  soutpos [terminal+1]
#define DESVIO nDesvio [terminal+1]
#define SEGANT aSegAnt [terminal+1]  // Segundos Anteriores
#define DELAY  NumDelay[terminal+1]  // N£mero de segundos que deseja-se esperar
#define PICANT aPicAnt [terminal+1]  // Picture Anterior

#define ESC 27
#define BKSP 8
#define SUBTOT  84		// Tecla T

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ #DEFINES para uso da aplica‡Æo.                                         ³
//³ Uma conven‡Æo adotada ‚ que toda a vari vel que conter um I no final do ³
//³ nome possui o controle de itens, ou seja, ‚ um array bi-dimensional.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define lNumOrc  alNumOrc [terminal+1]           // Pegou o N£mero do Or‡amento ?
#define lProcGra aProcGra [terminal+1]           // Est  em Processo de Grava‡Æo ?
#define nNumIt   aNumIt   [terminal+1]           // N£mero de itens
#define nNumPar  aNumPar  [terminal+1]          // N£mero de parcelas
#define sCodPro  aCodPro  [terminal+1]           // C¢digo do Produto
#define sNumOrc  aNumOrc  [terminal+1]           // N£mero do Or‡amento
#define sCodVen  aCodVen  [terminal+1]           // C¢digo do Vendedor
#define nDescTot aDescTot [terminal+1]           // Desconto Total
#define sCodPag  aCodPag  [terminal+1]           // Cond. de Pagamento
#define sImpCup  aPrnCup  [terminal+1]           // Imprime Cupom ?
#define nItPage  aItPage  [terminal+1]           // Item atual do PgDown / PgUp
#define nValTot  aValTot  [terminal+1]           // Valor Total
#define nValDesc aValDesc [terminal+1]           // Valor Total do Desconto
#define lOk      aOk      [terminal+1]           // Armazena retorno do dbSeek

#define sCodProI aCodProI [nNumIt] [terminal+1]  // C¢digo do Produto c/ ctrl. de itens
#define nQtdProI aQtdProI [nNumIt] [terminal+1]  // Quantidade do Produto
#define sTabelaI aTabelaI [nNumIt] [terminal+1]  // Tab. de pre‡o utilizada
#define nValUniI aValUniI [nNumIt] [terminal+1]  // Valor Unit rio do Ötem
#define nValIPII aValIPII [nNumIt] [terminal+1]  // Valor Unit rio do IPI

Function LOJATER(cEmp, cFilTrab)

Local Mv_MicTerm, lUsaTerm, cNumTer, cDelay, cPorta, aParam, nI, nHandle

fErase("LJMICTER.FIM") // Apaga arquivo de finalização pendente

If File("LJMICTER.WRK")
	ConOut("Controle de Microterminal ja estava rodando")
	Return .F.
Endif

nHandle := fCreate("LJMICTER.WRK")
If nHandle == -1
	ConOut("Nao consegui criar o arquivo LJMICTER.WRK para iniciar o Controle de Microterminais")
	Return (.F.)
Endif
fWrite(nHandle,"Controle de Microterminais iniciado.")
fClose(nHandle)

// Se a empresa esta vazia, entÆo o default ‚ 99
If cEmp == Nil
	cEmp := "99"
Endif

// Se a filial estiver vazia, entÆo o default ‚ 01
If cFilTrab == NIL
	cFilTrab := "01"
EndIf

ConOut ( "Iniciando Controle de Terminais (LOJATER)...")

RPCSETType(3)   //Nao Comer licensa Normal eh Microterminal
PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFilTrab TABLES "SB0" , "SB1" ,;
"SB2" , "SAE", "SA3" , "SE4" , "SL1" , "SL2" , "SL4", "SAH" , "SX5"

Mv_MicTerm := GetMV("MV_MICTERM")

lUsaterm := If(Substr(Mv_MicTerm,1,1)=="T",.T.,.F.)

If ! lUsaTerm
	fErase("LJMICTER.WRK")
	Return (.F.)
Endif

aParam := {}

If ! Right(Mv_MicTerm,1) == "/"
	Mv_MicTerm += "/"
Endif

For nI := 1 to 3
	
	Mv_MicTerm := Substr(Mv_MicTerm,At("/",Mv_MicTerm)+1,Len(Mv_MicTerm))
	aadd(aParam,Substr(Mv_MicTerm,1,At("/",Mv_MicTerm)-1))
	
Next nI

cNumTer := aParam[1]
cDelay  := aParam[2]
cPorta  := aParam[3]

PRIVATE Mv_LjPorIm  := GetMv("MV_LJPORIM") // Porta para impressÆo do cupom
PRIVATE MV_LjDcMax  := GetMv("MV_LJDCMAX") // Desconto máximo no Microterminal

PRIVATE nNumTer     := Val(cNumTer)
PRIVATE lMostrou    := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis uteis as LIBS do SIGA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lGetSxeNum := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa vari veis para uso da rede de microterminais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

waitkbd  := array(32)    // flag de aguardando entrada de teclado
teclado  := array(32)    // buffer de teclado
pikture  := array(32)    // picture de teclado
pospic   := array(32)    // posicao na picture de teclado
posicao  := array(32)    // posicao na execucao do programa
pprinter := array(32)    // area para armazenamento de impressao paralela
sprinter := array(32)    // area para armazenamento	 de impressao serial
pinpos   := array(32)    // posicao de entrada no array impressao paralela
sinpos   := array(32)    // posicao de entrada no array impressao serial
poutpos  := array(32)    // posicao de saida no array impressao paralela
soutpos  := array(32)    // posicao de saida no array impressao serial
nDesvio  := array(32)    // n£mero da pr¢xima POS que o fluxo deve ser desviado
aSegAnt  := array(32)    // Segundos Anteriores
NumDelay := array(32)    // N£mero de segundos que deseja-se esperar
aPicAnt  := array(32)    // Picture Anterior
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas pelas procedures ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
alNumOrc := array( 32 )       // Pegou o N£mero do Or‡amento
aProcGra := array( 32 )       // Processo de Grava‡Æo
aCodPro  := array( 32 )       // C¢digo do Produto
aNumOrc  := array( 32 )       // N£mero do Or‡amento
aCodVen  := array( 32 )       // C¢digo do Vendedor
aDescTot := array( 32 )       // Desconto Total %
aCodPag  := array( 32 )       // Condi‡Æo de Pagamento
aPrnCup  := array( 32 )       // Imprime Cupom ?
aNumIt   := array( 32 )       // N£mero de itens
aNumPar  := array(32)    // N£mero de parcelas
aItPage  := array( 32 )       // Item atual do Page
aValTot  := array( 32 )       // Valor Total
aValIPI  := array( 32 )       // Valor do IPI (Total)
aValDesc := array( 32 )       // Valor Total do Desconto
aOk      := array( 32 )       // Identifica se achou o dbSeek

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arrays Bi-dimensionais com controle de itens                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCodProI := array( 99, 32 )    // C¢digo do Produto c/ ctrl. de n£m. de itens
aQtdProI := array( 99, 32 )    // Quantidade do Produto
aTabelaI := array( 99, 32 )    // Tabela de Pre‡o
aValUniI := array( 99, 32 )    // Valor Unit rio
aValIPII := array( 99, 32 )    // Valor Unit rio do IPI
aDatParI := array( 99, 32 )    // Data da parcela
aValParI := array( 99, 32 )    // Valor da parcela
aFPgParI := array( 99, 32 )    // Forma de pagamento da parcela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotinas de inicializa‡Æo da estrutura de controle da rede de terminais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
terminal := 0           // Vari vel que indica o terminal que est  sendo
// tratado a cada instante. Se for usada como
// vari vel para indexa‡Æo dos vetores, permitir 
// que a programa‡Æo fique mais simples e que
// nÆo haja mistura dos dados entre os terminais

handle  := fopen( "gradevic", FO_READWRITE )
PRIVATE helpstr := "şT" + StrZero(Val(cDelay), 5, 0)	// Vari vel de apoio para a fun‡Æo GFLUSHPRN
fwrite( handle, helpstr, len(helpstr) )

// Seta qual a porta est  a comutadora
helpstr := "şP" + cPorta
fwrite( handle, helpstr, len(helpstr) )

CursorArrow()

Do While TERMINAL < nNumTer
	
	POS   := 1             // Define a posi‡Æo inicial de entrada no programa
	WAITT := 0             // Inicializa o buffer de teclado
	PINP  := 0             // Inicializa entrada de impressÆo paralela
	PINS  := 0             // Inicializa entrada de impressÆo serial
	POUTS := 0             // Inicializa saida de impressao paralela
	POUTP := 0             // Inicializa saida de impressÆo serial
	PPRN  := ""            // Inicializa o vetor de paralela
	SPRN  := ""            // Inicializa o vetor de serial
	GClear()               // Envia dois apagamentos de display para que o
	GClear()               // Terminal possa ficar sincronizado com o PC
	lNumOrc := .F.         // NÆo pegou o N£mero do Or‡amento
	SEGANT  := "00"        // Zera vari vel de controle do Delay
	DELAY   := 0           // Zera o tempo de espera
	sNumOrc := Space(6)    // Zera o N£mero de Or‡amento
	
	Terminal ++
	
EndDo

While .T.
	
	If KillApp() .or. File("LJMICTER.FIM")
		If FinTer()
			Exit
		Endif
	Endif
	
	Sleep(10)
	
	if ! lGetSxeNum
		Terminais()
	Endif
	
End

fErase("LJMICTER.FIM")
fErase("LJMICTER.WRK")

ConOut("Controle de Microterminais finalizado...")

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³Terminais ³ Autor ³ F bio F. Pessoa       ³ Data ³ 25/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Processa a fun‡Æo principal para os 32 terminais           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaTer                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Terminais()
Local i

// Promove o Polling de impressÆo
i := 0
Do While i < nNumTer
	Terminal := i
	GFlushPrn()
	i := i + 1
EndDo

// Promove o Polling dos terminais
i := 0
Do While i < nNumTer
	TER00(i)
	i := i + 1
EndDo

// Promove o Polling de impressÆo
i := 0
Do While i < nNumTer
	Terminal := i
	GFlushPrn()
	i := i + 1
EndDo

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³   Ter00  ³ Autor ³ F bio F. Pessoa       ³ Data ³ 22/09/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Programa principal, cont‚m 2 principais op‡äes:            ³±±
±±³          ³ (C)onsulta e (P)r‚-Venda                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ter00( NumTerm )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NumTerm - N£mero do Terminal                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ter00( NumTerm )

Terminal := NumTerm
GFlushPrn()
If POS == 1
	
	lNumOrc  := .F.         // Pode pegar o N£mero do Or‡amento
	lProcGra := .F.         // NÆo est  em processo de grava‡Æo
	
	If !GIsWill()           // Se nÆo ‚ Willbor, entÆo ‚ Terminal
		
		GClear()
		GDisplay( "(C)onsulta  (P)re-venda" + If( ExistBlock("LJTM003"), "(R)eimpressao", "" ) )
		GPosCur ( 1, 0 )
		GDisplay(  "Selecione a sua opcao: " )
		HelpStr := Time()
		GGet( "A@" )
		POS := 2
		
	Else
		POS := 61
	EndIf
	
ElseIf POS == 2
	
	If GtrTecla()
		
		If KBD == "C"
			POS := 3
		ElseIf KBD == "P"
			POS := 31
		ElseIf ExistBlock( "LJTM003" ) .And. KBD == "R"
			POS := 91
		Else
			POS := 1
		EndIf
		
	EndIf
	
ElseIf (POS >= 3) .And. (POS <= 30)     // Consulta
	
	Ter01()
	
ElseIf ((POS >= 31) .And. (POS <= 60)) .Or.;
	((POS >= 71) .And. (POS <= 90))    // Pr‚-venda
	
	Ter02()
	
ElseIf (POS >= 61) .And. (POS <= 70)    // Consulta Willbor
	
	Ter03()
	
ElseIf (POS >= 91) .And. (POS <= 91)		// Reimpressao do cumpom de orcamento
	
	Ter04()
	
ElseIf POS == 100
	If Gtrtecla()
		POS := 1
	EndIf
EndIf
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³   Ter01  ³ Autor ³ F bio F. Pessoa       ³ Data ³ 22/09/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Programa que cont‚m o controle do fluxo da op‡Æo Consulta. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ter01()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ter01()
LOCAL nQtde := 0

If POS == 3                       // Consulta
	
	GClear()
	GDisplay( "Produto: " )
	GGet( "XXXXXXXXXXXXXXX@" )
	POS := 4
	
ElseIf POS == 4                   // Efetua a consulta
	
	If GtrTecla()
		If KBD == CHR(ESC) .Or. KBD == ""
			POS := 1
		Else
			sCodPro := PadR( KBD, 15 )
			dbSelectArea("SB1")
			dbSetOrder(1)
			GClear()
			
			// Se nÆo encontrar tenta pelo c¢digo de barras
			lOk := dbSeek( xFilial("SB1") + sCodPro)
			If ! lOk
				dbSetOrder(5)
				If dbSeek( xFilial("SB1") + sCodPro)
					sCodPro := SB1->B1_COD
					dbSetOrder(1)
					lOk := dbSeek( xFilial("SB1") + sCodPro)
				EndIf
			EndIf
			
			If lOk
				GDisplay( SB1->B1_COD + " - " + Substr(SB1->B1_DESC,1,22))
				dbSelectArea("SB2")
				dbSetOrder(1)
				dbSeek( xFilial("SB2") + sCodPro)
				
				// Soma a quantidade de todos os locais
				While (!Eof()) .And. (SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2") + sCodPro)
					nQtde :=  nQtde + SB2->B2_QATU
					dbSkip()
				EndDo
				
				GPosCur ( 1, 0 )
				GDisplay( "Qtde. " + Str(nQtde, 12, 2) )
				
				GPosCur ( 1, 20 )
				dbSelectArea("SB0")
				dbSetOrder(1)
				If ! dbSeek( xFilial("SB0") + sCodPro)
					GDisplay( "R$           0.00")
				Else
					GDisplay("R$ " + Str(SB0->B0_PRV1,14,2))
				EndIf
			Else
				GDisplay( "Produto nao cadastrado ..." )
			EndIf
			
			GGet("X@")
			POS := 100
		EndIf
		
	EndIf
	
EndIf
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³   Ter02  ³ Autor ³ F bio F. Pessoa       ³ Data ³ 23/09/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Programa que cont‚m o controle do fluxo da op‡Æo Pr‚-venda ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ter02()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ter02()
LOCAL nCont
LOCAL lLJTM002 := ExistBlock("LJTM002")
Local nSaveSx8 := GetSx8Len()

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se estiver em Processo de Grava‡Æo para este terminal,nÆo ³
//³ continua, para evitar Stack Overflow                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lProcGra
	Return Nil
EndIf

dbSelectArea("SL1")
dbSetOrder(1)

If POS == 31                      // Pr‚-venda
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera as vari veis para a digita‡Æo de um novo or‡amento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	sNumOrc  := ""                  // N£mero do Or‡amento
	nNumIt   := 0                   // N£mero de itens
	nItPage  := nNumIt              // Item do Page atual
	sCodVen  := ""                  // C¢digo do Vendedor
	nDescTot := "0"                 // Desconto Total
	sCodPag  := ""                  // Cond. de Pagamento
	sImpCup  := ""                  // Imprime Cupom ?
	nValTot  := 0                   // Valor Total do Orcamento
	aValIPI  [terminal+1]  := 0    // Valor Total do IPI
	nValDesc := 0                   // Valor Total do Desconto
	
	For nCont := 1 To 99
		If aCodProI [nCont] [terminal+1] == NIL
			Exit
		EndIf
		aCodProI [nCont] [terminal+1] := NIL
		aQtdProI [nCont] [terminal+1] := NIL
		aTabelaI [nCont] [terminal+1] := NIL
		aValUniI [nCont] [terminal+1] := NIL
	Next
	
	GClear()
	POS := 32
	
ElseIf POS == 32                  // C¢digo do vendedor
	
	GClear()
	GDisplay( "Vendedor: " )
	GGet( "XXXXXX@" )
	POS := 33
	
ElseIf POS == 33                  // Valida‡Æo do c¢digo do vendedor
	
	If GtrTecla()
		If KBD == CHR(ESC) .Or. KBD == ""
			POS := 1
		Else
			sCodVen := PadR( KBD, 6 )
			GPosCur ( 1, 0 )
			dbSelectArea("SA3")
			dbSetOrder(1)
			
			If dbSeek( xFilial("SA3") + sCodVen)
				GDisplay(Substr(SA3->A3_NOME, 1, 37))
				DESVIO := 34              // Pr¢xima POS depois de digitada qualquer tecla
				PICANT := "XXXXXXXXXXXXXXX@"
			Else
				GDisplay( sCodVen + " - Vendedor nao cadastrado ...")
				DESVIO := 32              // Pr¢xima POS depois de digitada qualquer tecla
				PICANT := KPIC
			EndIf
			
			DELAY  := 5
			POS    := 60
			GGet("X@")
		EndIf
	EndIf
	
ElseIf POS == 34                  // C¢digo do produto
	
	GClear()
	GDisplay( "Produto: " )
	GGet( "XXXXXXXXXXXXXXX@")
	POS      := 35
	nNumIt   := nNumIt + 1
	nItPage  := nNumIt
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera as vari veis correspondentes aos produtos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	sCodProI := SPACE(15)                 // C¢digo do Produto c/ ctrl. de n£m. de itens
	nQtdProI := "1"                // Quantidade do Produto
	sTabelaI := "1"                // Tab. de pre‡o utilizada
	
ElseIf POS == 35                  // Valida‡Æo do c¢digo do produto
	
	If GtrTecla()
		
		If KBD == CHR(ESC) .And. nNumIt >= 2
			POS := 71                   // Vai p/ o Tratamento de PgDown e PgUp
		ElseIf (KBD == "") .And. (nNumIt == 1)
			POS := 31                   // Volta para o Vendedor
		ElseIf  KBD == ""
			POS := 40
		ElseIf AllTrim(KBD) == CHR(SUBTOT) // Permite ver sub-total
			nNumIt  := nNumIt - 1
			nItPage := nNumIt
			DESVIO  := 34
			PICANT  := KPIC
			POS     := 74
		Else
			GClear()
			sCodProI := padr(KBD,15)
			
			dbSelectArea("SB1")
			dbSetOrder(1)
			
			// Se nÆo encontrar tenta pelo c¢digo de barras
			lOk := dbSeek( xFilial("SB1") + sCodProI)
			If ! lOk
				dbSetOrder(5)
				If dbSeek( xFilial("SB1") + sCodProI)
					sCodProI := SB1->B1_COD
					dbSetOrder(1)
					lOk := dbSeek( xFilial("SB1") + sCodProI)
				EndIf
			EndIf
			
			If lOk
				POS    := 36              // Pr¢xima POS depois de digitada qualquer tecla
			Else
				GDisplay( sCodProI + "- Prod. nao cadastrado...")
				PICANT  := KPIC
				POS     := 60
				DESVIO  := 34
				DELAY   := 5
				nNumIt  := nNumIt - 1
				nItPage := nNumIt
				GGet("X@")
			EndIf
			
		EndIf
	EndIf
	
ElseIf POS == 36                  // Quantidade do produto
	
	GClear()
	GDisplay( SB1->B1_COD + " - " + Substr(SB1->B1_DESC,1,22))
	
	GPosCur( 1, 0 ); GDisplay(Replicate(" ", 40))
	GPosCur( 1, 0 ); GDisplay( "Qtde: 1" )
	
	GPosCur( 1, 6 )
	GGet( "X999.99@" )
	POS := 37
	
ElseIf POS == 37                  // Valida‡Æo da quantidade do produto
	
	If GtrTecla()
		
		If KBD == CHR(ESC)
			
			POS     := 34              // Volta para o Produto
			nNumIt  := nNumIt -1
			nItPage := nNumIt
			
		ElseIf IsAlpha( SubStr(KBD,1,1) ) .And.;    // Se digitou qualquer letra dirente de SUBTOT
			SubStr(KBD,1,1) # CHR( SUBTOT )
			POS := 36
			
		ElseIf Substr(KBD,1,1) == CHR(SUBTOT)		// Permite ver sub-total
			DESVIO := 36
			POS    := 74
			
		Else
			
			If KBD == ""
				KBD := "1"
			EndIf
			
			If Val(KBD) == 0
				POS := 36
			Else
				
				POS      := 38
				nQtdProI := KBD
				
			EndIf
			
		EndIf
		
	EndIf
	
ElseIf POS == 38                  // Defini‡Æo da tabela de Pre‡o
	
	GClear()
	GDisplay( SB1->B1_COD + " - " + Substr(SB1->B1_DESC,1,22))
	
	GPosCur( 1,  0 ); GDisplay(Replicate(" ", 40))
	GPosCur( 1,  0 ); GDisplay( "Qtde: " + nQtdProI )
	GPosCur( 1, 14 ); GDisplay(Replicate(" ", 26))
	
	GPosCur( 1, 14 )
	GDisplay( "Tab: 1" )
	GPosCur( 1, 19 )
	GGet( "X@" )
	POS := 39
	
ElseIf POS == 39                  // Valida‡Æo da tabela de pre‡o
	
	If GtrTecla()
		
		If KBD == CHR(ESC)
			POS     := 34              // Volta para o Produto
			nNumIt  := nNumIt -1
			nItPage := nNumIt
		ElseIf IsAlpha( KBD ) .And. KBD # CHR( SUBTOT )   // Se digitou qualquer letra dirente de SUBTOT
			POS := 38
		ElseIf Substr(KBD,1,1) == CHR(SUBTOT)		// Permite ver sub-total
			DESVIO := 38
			POS    := 74
		Else
			
			If KBD = "0"
				
				GPosCur( 1, 22 )
				GDisplay(Replicate(" ", 17))
				
				GPosCur( 1, 22 )
				GDisplay( "Tab. invalida ..." )
				
				PICANT := KPIC
				POS    := 60
				DESVIO := 38
				DELAY  := 5
				GGet("X@")
				
			Else
				
				If KBD == ""
					KBD := "1"
				EndIf
				
				sTabelaI := KBD
				If lLjTM002
					lGetSxeNum := .T.
					nValUniI    := ExecBlock("LJTM002",.F.,.F.,{sCodProI, sTabelaI})
					nPrcTab     := nValUniI
					POS         := 34
					nValTot    += NoRound( nValUniI * Val( nQtdProI ), 2)	 // Incrementa Total
					lGetSxeNum := .F.
				Else
					dbSelectArea("SB0")
					dbSetOrder(1)
					If dbSeek( xFilial("SB0") + sCodProI)
						
						sAux := "B0_PRV" + sTabelaI
						If &sAux <= 0
							
							GPosCur( 1, 22 )
							GDisplay(Replicate(" ", 17))
							
							GPosCur( 1, 22 )
							GDisplay( "Tab. invalida ..." )
							
							PICANT := KPIC
							POS    := 60
							DESVIO := 38
							DELAY  := 5
							GGet("X@")
							
						Else
							POS := 34
							nValUniI := &sAux
							nPrcTab  := nValUniI
							nValTot  += NoRound( nValUniI * Val( nQtdProI ), 2)  // Incrementa Total
						EndIf
					Else
						POS := 34
					EndIf
				EndIf
			EndIf
			
		EndIf
		
	EndIf
	
ElseIf POS == 40                  // Desconto Total
	
	GClear()
	GDisplay( "Desconto total (%): " )
	GGet( "X99.99@" )
	POS := 41
	
ElseIf POS == 41                  // Valida‡Æo do Desconto Total
	
	If GtrTecla()
		
		If KBD == CHR(ESC)
			POS     := 34              // Volta para o Produto
			nNumIt  := nNumIt -1
			nItPage := nNumIt
		ElseIf IsAlpha( SubStr( KBD, 1, 1 ) ) .And.;
			SubStr( KBD, 1, 1 ) # CHR( SUBTOT )   // Se digitou qualquer letra dirente de SUBTOT
			POS := 40
		ElseIf Substr(KBD,1,1) == CHR(SUBTOT)		// Permite ver sub-total
			DESVIO := 40
			POS    := 74
		Else
			
			nDescTot := KBD
			
			If ! Empty(nDescTot) .And. Val(nDescTot) > Mv_LjDcMax
				POS := 40
			Else
				nDescTot := KBD
				
				// Calcula o IPI (como pode ser sobre o liquido ou bruto o calculo foi colocado aqui)
				
				aValIPI [terminal +1] := 0
				For nCont := 1 To (nNumIt-1)
					
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+aCodProI [nCont] [terminal +1]))
					
					aValIPII [nCont] [terminal +1] := Lj010Ipi(aValUniI [nCont] [terminal+1],Val(aQtdProI [nCont] [terminal+1]),0,Val(nDescTot),If(Empty(RetFldProd(SB1->B1_COD,"B1_TS")), GetMv("MV_TESSAI"), RetFldProd(SB1->B1_COD,"B1_TS") ),nCont,aCodProI [nCont] [terminal +1])
					aValIPI [terminal +1] += aValIPII [nCont] [terminal +1]
					
				Next
				
				POS      := 42
			EndIf
			
		EndIf
		
	EndIf
	
ElseIf POS == 42                  // Condi‡Æo de Pagamento
	
	GClear()		 ;	GDisplay( "Desconto total (%): " + nDescTot )
	GPosCur ( 1, 0 );	GDisplay(Replicate(" ", 40))
	
	GPosCur( 1, 0 )
	GDisplay( "Cond. de Pagamento: " )
	GGet( "X99@" )
	POS := 43
	
ElseIf POS == 43                  // Valida‡Æo da Condi‡Æo de Pagamento
	
	If GtrTecla()
		If KBD == CHR(ESC) .Or. KBD == ""
			POS := 40                   // Volta para o Desconto Total
		ElseIf IsAlpha( SubStr( KBD, 1, 1 ) ) .And.;
			SubStr( KBD, 1, 1 ) # CHR( SUBTOT )   // Se digitou qualquer letra dirente de SUBTOT
			POS := 42
		ElseIf AllTrim(KBD) == CHR(SUBTOT)		// Permite ver sub-total
			DESVIO := 42
			POS    := 74
		Else
			
			GPosCur ( 1, 0 )
			GDisplay(Replicate(" ", 40))
			GPosCur ( 1, 0 )
			
			sCodPag := PadR( KBD, 3 )
			dbSelectArea("SE4")
			dbSetOrder(1)
			
			If dbSeek( xFilial("SE4") + sCodPag )
				GDisplay( SE4->E4_CODIGO + " - " + Substr(SE4->E4_DESCRI,1,31))
				DESVIO := 44
				PICANT := "A@"
			Else
				GDisplay( sCodPag + " - Cond. Pgto. nao cadastrada ...")
				DESVIO := 42              // Pr¢xima POS depois de digitada qualquer tecla
				PICANT := KPIC
			EndIf
			
			POS    := 60
			DELAY  := 5
			GGet("X@")
			
		EndIf
	EndIf
	
ElseIf POS == 44                  // Confirma opera‡Æo ?
	
	GClear()
	GDisplay( "Confirma operacao ? (S/N): " )
	GGet( "A@" )
	POS := 45
	
ElseIf POS == 45
	
	If GtrTecla()
		
		If KBD == "S"
			POS := 46
		ElseIf KBD == "N"
			POS := 40                 // Volta para Condi‡Æo de Pagamento
		Else
			POS := 44
		EndIf
		
	EndIf
	
ElseIf POS == 46                  // Imprime cupom
	
	GClear()
	GDisplay( "Imprime cupom ? (S/N): " )
	GGet( "A@" )
	POS := 47
	
ElseIf POS == 47
	
	If GtrTecla()
		
		If (KBD == "S") .Or. (KBD == "N")
			
			sImpCup := KBD
			If !lGetSxeNum
				
				lGetSxeNum := .T.
				If !lNumOrc
					
					lNumOrc  := .T.               // Pegou o N£mero do Or‡amento
					sNumOrc  := GetSxeNum("SL1")  // N£mero do Pr¢ximo Or‡amento
					If __lSx8
						While (GetSX8Len() > nSaveSx8)
							ConfirmSx8()
						End
					EndIf
					
				EndIf
				lGetSxeNum := .F.
				
			EndIf
			
			If Val(nDescTot) > 0
				nValDesc := NoRound( nValTot * ( Val(nDescTot) / 100 ), 2)
			Else
				nValDesc := 0
			EndIf
			
			GPosCur( 1, 0 )
			GDisplay( "Orcamento: " + sNumOrc +;
			"   Total: " + Transform( nValTot - nValDesc + aValIPI  [terminal+1], "@E 99,999,999.99" ) )
			
			GGet("A@")
			POS := 48
			
		Else
			POS := 46
		EndIf
		
	EndIf
	
ElseIf POS == 48
	
	If GtrTecla()
		lProcGra := .T.                // Processo de grava‡Æo
		
		GClear()
		GDisplay( "Aguarde gravando ..." )
		
		Begin Transaction
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Header de or‡amentos - SL1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		SL1->(RecLock("SL1", .T.))
		
		SL1->L1_FILIAL  := xFilial("SL1")
		SL1->L1_CLIENTE := GetMv("MV_CLIPAD")
		SL1->L1_LOJA    := GetMv("MV_LOJAPAD")
		SL1->L1_NUM     := sNumOrc
		SL1->L1_CONDPG  := sCodPag
		SL1->L1_VEND    := sCodVen
		SL1->L1_DESCONT := nValDesc
		SL1->L1_DESCNF  := Val(nDescTot)
		SL1->L1_EMISSAO := dDataBase
		SL1->L1_DTLIM   := dDataBase
		SL1->L1_VLRTOT  := nValTot + aValIPI  [terminal+1]     // Valor Total sem Descontos
		SL1->L1_VLRLIQ  := nValTot - nValDesc + aValIPI  [terminal+1]   // Valor Total - Desc. Total
		SL1->L1_IMPRIME := "1S"
		SL1->( dbCommit() )
		SL1->( msUnlock() )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava os Itens de or‡amentos - SL2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		For nCont := 1 To (nNumIt-1)
			
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aCodProI [nCont] [terminal +1]))
			
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+If(Empty(RetFldProd(SB1->B1_COD,"B1_TS")), GetMv("MV_TESSAI"), RetFldProd(SB1->B1_COD,"B1_TS") )))
			
			SL2->(RecLock("SL2", .T.))
			SL2->L2_FILIAL  := xFilial("SL2")
			SL2->L2_NUM     := sNumOrc
			SL2->L2_PRODUTO := aCodProI [nCont] [terminal +1]
			SL2->L2_DESCRI  := SB1->B1_DESC
			SL2->L2_ITEM    := StrZero(nCont, 2, 0)
			SL2->L2_TABELA  := aTabelaI     [nCont] [terminal+1]
			SL2->L2_QUANT   := Val(aQtdProI [nCont] [terminal+1])
			SL2->L2_VRUNIT  := aValUniI [nCont] [terminal+1]
			SL2->L2_VLRITEM := NoRound((SL2->L2_VRUNIT * SL2->L2_QUANT), 4)
			SL2->L2_VALDESC := 0
			SL2->L2_DESCPRO := 0
			SL2->L2_TES     := If(Empty(RetFldProd(SB1->B1_COD,"B1_TS")), GetMv("MV_TESSAI"), RetFldProd(SB1->B1_COD,"B1_TS") )
			SL2->L2_CF      := SF4->F4_CF
			SL2->L2_EMISSAO := dDataBase
			SL2->L2_UM      := SB1->B1_UM
			SL2->L2_LOCAL   := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
			SL2->L2_PRCTAB  := SL2->L2_VRUNIT
			SL2->L2_VALIPI  := aValIPII [nCont] [terminal +1]
			If SL2->( FieldPos("L2_ITEMSD1")) > 0
				SL2->L2_ITEMSD1 := "000000"
			EndIf
			SL2->( dbCommit() )
			SL2->( msUnlock() )
			
		Next
		
		// Gera parcelas a pagar do orçamento
		SL4->(dbSetOrder(1))
		If SL4->(dbSeek( xFilial("SL4") + sNumOrc ))
			While ! SL4->(EoF()) .and. SL4->L4_NUM == sNumOrc .and. xFilial("SL4") == SL4->L4_FILIAL
				SL4->(RecLock( "SL4", .F. ))
				SL4->(DBDelete())
				SL4->(DBSkip())
			EndDo
		EndIf
		
		// Recalcula parcelas com desconto
		MontParc1( nValTot - nValDesc )
		
		For nCont := 1 to nNumPar
			
			SL4->(RecLock( "SL4", .T. ))
			
			SL4->L4_FILIAL  := xFilial( "SL4" )
			SL4->L4_NUM     := sNumOrc
			SL4->L4_DATA    := aDatParI[ nCont ][ terminal + 1]
			SL4->L4_VALOR   := aValParI[ nCont ][ terminal + 1]
			SL4->L4_FORMA   := aFPgParI[ nCont ][ terminal + 1]
			SL4->L4_TERCEIR := .F.
			
			SL4->(dbCommit())
			SL4->(MsUnlock())
			
		Next
		
		End Transaction
		
		dbCommitAll()
		msUnlockAll()
		
		If sImpCup == "S"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para impressÆo do cupom ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ExistBlock("LJTM001") )
				GClear()
				GDisplay( "Aguarde imprimindo ..." )
				ExecBlock("LJTM001",.F.,.F.)
			Endif
			
		EndIf
		
		POS := 1
		
	Endif
	
ElseIf POS == 60                  // Provoca uma pausa at‚ que qualquer tecla seja digitada
	
	If GtrTecla()
		POS   := DESVIO
		DELAY := 0
	EndIf
	
	Calc_Delay()
	
ElseIf POS == 71                 // Tratamento do PgDown e PgUp p/ produtos
	
	nItPage := nItPage - 1
	If nItPage >= 1
		
		lProcess := .T.                // Est  em Processo no terminal atual
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbGoTop()
		dbSeek( xFilial("SB1") + aCodProI [nItPage][Terminal+1] )
		
		GClear()
		GDisplay( SB1->B1_COD + " - " + Substr(SB1->B1_DESC,1,22) )
		GPosCur ( 1, 0 )
		GDisplay( "Qtde. " + aQtdProI[nItPage][Terminal+1])
		GPosCur( 1, 14 )
		GDisplay( "Tab: " + aTabelaI[nItPage][Terminal+1])
		
		lProcess := .F.               // NÆo est  em Processo no terminal atual
		
		GGet("X@")
		POS := 72
	Else
		nNumIt := nNumIt - 1
		POS    := 32                  // Volta para o Vendedor
	EndIf
	
ElseIf POS == 72
	
	If GtrTecla()
		
		If KBD == CHR(ESC)
			POS := 71                   // Volta um item
		ElseIf KBD == ""
			
			nItPage := nItPage + 1      // Avan‡a + 1 item
			If nItPage == nNumIt
				nNumIt := nNumIt - 1
				POS    := 34              // Volta para o Produto
			Else
				nItPage := nItPage + 1
				POS     := 71             // Volta para o Tratamento de PgDown / PgUp
			EndIf
			
		ElseIf KBD == ","             // Apaga o Item
			
			GPosCur ( 1, 24 )
			GDisplay( "Apaga ? (S/N) ")
			
			GGet("X@")
			POS := 73
			
		Else
			nItPage := nItPage + 1      // Mostra o item atual novamente
			POS     := 71
		EndIf
		
	EndIf
	
ElseIf POS == 73
	
	If GtrTecla()
		
		If KBD == "S"
			
			//
			//	Subtrai valor total do item do total do orcamento
			//
			nValTot -= NoRound( aValUniI [nItPage] [terminal+1] * Val( aQtdProI [nItPage] [terminal+1] ), 2)
			
			For nCont := nItPage to 98
				
				aCodProI [nCont] [terminal+1] := aCodProI [nCont+1] [terminal+1]
				aQtdProI [nCont] [terminal+1] := aQtdProI [nCont+1] [terminal+1]
				aTabelaI [nCont] [terminal+1] := aTabelaI [nCont+1] [terminal+1]
				aValUniI [nCont] [terminal+1] := aValUniI [nCont+1] [terminal+1]
				If aCodProI [nCont] [terminal+1] == NIL  // Se acabou os itens, para
					Exit
				ElseIf nCont == 98
					aCodProI [99] [terminal+1] := NIL
					aQtdProI [99] [terminal+1] := NIL
					aTabelaI [99] [terminal+1] := NIL
					aValUniI [99] [terminal+1] := NIL
				EndIf
				
			Next i
			
			nNumIt  --      // Apaga o item
			POS     := 71
			
		Else
			nItPage ++      // Mostra o item atual novamente
			POS     := 71
		EndIf
		
		GPosCur ( 1, 24 )
		GDisplay( Replicate(" ",20) )
		
	EndIf
	
ElseIf POS == 74
	
	GClear()
	GDisplay( "Sub-Total: " + Transform( nValTot + aValIPI  [terminal+1], "@E 999,999,999.99" ) )
	POS    := 60
	DELAY  := 5
	GGet("X@")
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³   Ter03  ³ Autor ³ F bio F. Pessoa       ³ Data ³ 17/11/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Programa que cont‚m o controle do fluxo da op‡Æo Consulta  ³±±
±±³          ³ para o equipamento Wilbor.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ter03()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ter03()

If POS == 61                      // Consulta
	
	GClear()
	GDisplay( "Passe o seu Produto" )
	GPosCur ( 1, 0 )
	GGet( "XXXXXXXXXXXXXXX@" )
	POS := 62
	
ElseIf POS == 62                  // Efetua a consulta
	
	If GtrTecla()
		If KBD == CHR(ESC) .Or. KBD == ""
			POS := 1
		Else
			sCodPro := padr(KBD,15)
			dbSelectArea("SB1")
			dbSetOrder(1)
			GClear()
			
			// Se nÆo encontrar tenta pelo c¢digo de barras
			lOk := dbSeek( xFilial("SB1") + sCodPro)
			If ! lOk
				dbSetOrder(5)
				If dbSeek( xFilial("SB1") + sCodPro)
					sCodPro := SB1->B1_COD
					dbSetOrder(1)
					lOk := dbSeek( xFilial("SB1") + sCodPro)
				EndIf
			EndIf
			
			If lOk
				GDisplay( Substr(SB1->B1_DESC,1,20) )
				GPosCur ( 2, 1 )
				dbSelectArea("SB0")
				dbSetOrder(1)
				If ! dbSeek( xFilial("SB0") + sCodPro)
					GDisplay( "R$           0.00")
				Else
					GDisplay("R$ " + Str(SB0->B0_PRV1,14,2))
				EndIf
			Else
				GDisplay( "Produto nao cadastrado ..." )
			EndIf
			
			PICANT := KPIC
			POS    := 60
			DESVIO := 1
			DELAY  := 5
			GGet("X@")
			
		EndIf
		
	EndIf
EndIf
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³   Ter04  ³ Autor ³ Gustavo Henrique      ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Reimpressao do cupom de orcamento gerado pelo microterminal³±±
±±³          ³ Apenas habilita ponto de entrada LJTM003.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ter04()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ter04()

If POS == 91
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para reimpressao do cupom de orcamento gerado   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJTM003")
		GClear()
		ExecBlock("LJTM003",.F.,.F.)
	EndIf
	
	POS    := 1
	SOURCE := 0
	
EndIf

Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJINICTERM³ Autor ³ Edney Soares de Souza ³ Data ³ 15/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicia a aplica‡„o do MicroTerminal                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Trabalha em conjunto com o Sigaloja                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function LjInicTerm

Local cFuncName := "LOJATER"

If ExistBlock("LJFUNCTERM")
	
	cFuncName := ExecBlock("LJFUNCTERM",.F.,.F.)
	
	If ! Valtype(cFuncname) == "C"
		MsgAlert("O nome da função retornado pelo rdmake LJFUNCTERM é inválido!")
	Endif
	
	If ! FindFunction(cFuncName)
		MsgAlert("A função informada no rdmake LJFUNCTERM não existe!")
	Endif
	
Endif

// Function, Environment, Wait Thread, Par1, Par2, Parn, ...

StartJob(cFuncName,GetEnvServer(),.F.,cEmpAnt,cFilAnt)

MsgInfo("Controle de Microterminais inicializado com sucesso!")

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJFIMTERM ³ Autor ³ Edney Soares de Souza ³ Data ³ 15/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Finaliza a aplica‡„o do MicroTerminal                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Trabalha em conjunto com o Sigaloja                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function LjFimTerm

Local nHandle := fCreate("LJMICTER.FIM")

If nHandle == -1
	
	MsgAlert("Não consegui criar o arquivo LJMICTER.FIM para finalizar o controle de microterminais.")
	
	Return (.F.)
	
Endif

fWrite(nHandle,"Finaliza MicroTerminal")

fClose(nHandle)

ConOut("Recebida solicitacao para finalizar controle de microterminais...")

MsgInfo("Solicitação para finalizar Controle de Microterminais enviada com sucesso ao server!")

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ MontParc1³ Autor ³ F bio Pessoa / Gustavo³ Data ³ 02/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Array com as Parcelas 		    					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Exl1 := .T. ou .F.										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontParc1(nValorBase)

Local j
Local nCont
Local nParcelas := 0
Local nResto	:= 0
Local nLimSuper := 0
Local nLimInfer := 0
Local cForma1	:= 0
Local cForma2	:= 0
Local cForma    := GetMv("MV_FORMPAD")
Local aParc 	:= {}
Local aParcelas := {}
Local lRet		:= .T.
Local nEntrada, nFinanciado, nTxJuros

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa a Condicao de Pagto escolhida ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SE4" )
dbSeek( xFilial("SE4") + sCodPag )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os limites Inferiores e Superiores p/ esta condi‡ao ³
//³ e verifica se o valor base esta entre os dois.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLimSuper := SE4->E4_SUPER
nLimInfer := SE4->E4_INFER
If nValorBase > nLimSuper .And. nLimSuper <> 0
	lRet := .F.
ElseIf nValorBase < nLimInfer .And. nLimInfer <> 0
	lRet := .F.
EndIf

If lRet
	nEntrada 	:= 0
	nFinanciado := 0
	nTxJuros 	:= 0
	aParc 		:= Condicao( nValorBase , sCodPag )
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
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Forma de pagamento padrÆo                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SE4->E4_FORMA) .And. !(AllTrim(SE4->E4_FORMA) $ "R$/CH")
		SAE->( dbSeek( xFilial() ) )
		While !(SAE->(Eof()))
			If Len(SAE->AE_TIPO) == 2
				If SAE->AE_TIPO == Subs(SE4->E4_FORMA,1,2)
					cForma1 := Subs(SE4->E4_FORMA, 1, 2)
					cForma2 := Subs(SE4->E4_FORMA, 1, 2)
					Exit
				EndIf
			Else
				If SAE->AE_TIPO == AllTrim( SE4->E4_FORMA )
					cForma1 := AllTrim( SE4->E4_FORMA )
					cForma2 := AllTrim( SE4->E4_FORMA )
					Exit
				EndIf
			EndIf
			SAE->(dbSkip())
		EndDo
		If SAE->(Eof())
			cForma1 := cForma
			cForma2 := Iif(Upper(cForma) == "R$","CH",cForma)
		EndIf
	Else
		cForma1 := IIf(Empty(SE4->E4_FORMA),cForma,SubStr(SE4->E4_FORMA,1,2))
		
		If Empty(SE4->E4_FORMA)
			cForma2 := Iif(Upper(cForma) == "R$","CH",cForma)
		ElseIf Empty(SubStr(SE4->E4_FORMA,3,2))
			cForma2 := Iif(Upper(SubStr(SE4->E4_FORMA,1,2)) == "R$","CH",;
			SubStr(SE4->E4_FORMA,1,2))
		Else
			cForma2 := Iif(Upper(SubStr(SE4->E4_FORMA,3,2)) == "R$","CH",;
			SubStr(SE4->E4_FORMA,3,2))
		EndIf
	EndIf
	
	If nTxJuros > 0  // Calcula Parcelamento com Juros
		aParc := MontParc2(aParc,Iif(nEntrada>0,.T.,.F.),nValorBase,nTxJuros,nEntrada,@nFinanciado,nParcelas,0)
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
			If aParcelas[j][3] == "R$"
				aParcelas[j][3] := "CH"
			EndIf
		Else
			nEntrada += NoRound(aParcelas[j][2])
		EndIf
	Next j
	
	nResto := nValorBase - ( nFinanciado + nEntrada )
	
	If !nTxJuros > 0
		If nResto != 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajuste da £ltima parcela ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aParcelas[j-1][2] += nResto
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o array de Data e Parcelas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nNumPar := Len(aParcelas)
	
	For nCont := 1 To nNumPar
		aDatParI[nCont][terminal+1] := aParcelas[nCont][1]
		aValParI[nCont][terminal+1] := aParcelas[nCont][2]
		aFPgParI[nCont][terminal+1] := aParcelas[nCont][3]
	Next nCont
	
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ MontParc2³ Autor ³ F bio Pessoa / Gustavo³ Data ³ 02/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Monta Array com Parcelas de acordo com o digitado			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontParc2(aCondicoes,lEntrada,nValorBase,nTxJuros,nEntrada,nFinanciado,nParcelas,nIntervalo)

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
	Endif
	
Else
	nValor	  := nValorBase
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

Return aParc
