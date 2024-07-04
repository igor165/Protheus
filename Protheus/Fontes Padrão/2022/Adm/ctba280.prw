/*/PMC
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³ Nome          ³ Data     ³ PMCs ³  Detalhes                             									  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³ Eduardo Nunes ³ 09/12/05 ³ 2    ³  Checagem da utilizacao do conceito de Filiais.							  ±±
±±³ Eduardo Nunes ³ 09/12/05 ³ 4    ³  Garantir que todas as funcoes tenham apenas um ponto de saida.			  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³               ³          ³      ³                                      										  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#INCLUDE "ctba280.ch"
#Include "PROTHEUS.Ch"

#Define CODIGOMOEDA 1
#Define SALDOATUA   1
#Define SALDOS      2

// 17/08/2009 -- Filial com mais de 2 caracteres
STATIC MAX_LINHA

STATIC __lCusto
STATIC __lItem
STATIC __lClVL

STATIC __lCT280Skip := EXISTBLOCK("CT280SKIP")

STATIC __lCTB150
STATIC __lFKInUse
STATIC __lAS400		:= TcSrvType() == "AS/400"
STATIC __lAvisoSP
Static lFWCodFil	:= .T.
STATIC __lEnt05		:= CTQ->(ColumnPos("CTQ_E05ORI")) > 0
STATIC __lEnt06		:= CTQ->(ColumnPos("CTQ_E06ORI")) > 0
STATIC __lEnt07		:= CTQ->(ColumnPos("CTQ_E07ORI")) > 0
STATIC __lEnt08		:= CTQ->(ColumnPos("CTQ_E08ORI")) > 0
STATIC __lEnt09		:= CTQ->(ColumnPos("CTQ_E09ORI")) > 0

STATIC __lJobs	 		:= IsCtbJob()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ctba280  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Este programa calcula os rateios Off-Line cadastrados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba280(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba280(lDireto)
Local nOpc,;
aSays    := {},;
aButtons := {}

Private cCadastro	:= STR0001 //"Rateios Off-Line"

DEFAULT lDireto		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros        ³
//³ mv_par01 // Data de Referencia              ³
//³ mv_par02 // Numero do Lote			      	³
//³ mv_par03 // Numero do SubLote		         ³
//³ mv_par04 // Numero do Documento             ³
//³ mv_par05 // Cod. Historico Padrao           ³
//³ mv_par06 // Do Rateio 		        	      	³
//³ mv_par07 // Ate o Rateio               		³
//³ mv_par08 // Moedas? Todas / Especifica      ³
//³ mv_par09 // Qual Moeda?                  	³
//³ mv_par10 // Tipo de Saldo 				      ³
//³ mv_par11 // Seleciona Filiais?			      ³
//³ mv_par12 // Filial De ?					      ³
//³ mv_par13 // Filial Até?       			      ³
//³ mv_par14 // Atualiza saldo no final		      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//PE PARA PREPARAR O PROCESSAMENTO
IF ExistBlock ("CT280BEFORE")
	ExecBlock("CT280BEFORE",.F.,.F.)
ENDIF

If IsBlind() .Or. lDireto
	
	If MAX_LINHA = Nil
		MAX_LINHA :=  CtbLinMax(GetMv("MV_NUMLIN"))
	Endif
	
	BatchProcess( 	cCadastro, 	STR0002 + STR0003 + STR0004 +Chr(13) + Chr(10) ,"CTB280",; // "Este programa tem o objetivo de efetuar os lan‡amentos referentes aos"
	{ || Ctb280Proc(.T.) }, { || .F. }) 									//"rateios off-line pre-cadastrados. Podera ser utilizado para ratear as"
	//"despesas dos centros de custos improdutivos nos produtivos."
	Return .T.
Endif


Pergunte("CTB280",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Data de Referencia ?	mv_par01 ³
//³ Numero do Lote ?		mv_par02 ³
//³ Numero do Sub-Lote ?	mv_par03 ³
//³ Numero do Documento ?	mv_par04 ³
//³ Cod. Hist Padrao ? 		mv_par05 ³
//³ Do rateio ?				mv_par07 ³
//³ Ate o rateio ?			mv_par06 ³
//³ Moedas ?				mv_par08 ³
//³ Qual Moeda ?   			mv_par09 ³
//³ Tipo de Saldo ?			mv_par10 ³
//³ Seleciona Filiais ?		mv_par11 ³
//³ Filial de ?				mv_par12 ³
//³ Filial Ate ?   			mv_par13 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AADD(aSays,STR0002 ) //"Este programa tem o objetivo de efetuar os lan‡amentos referentes aos"
AADD(aSays,STR0003 ) //"rateios off-line pre-cadastrados. Podera ser utilizado para ratear as"
AADD(aSays,STR0004) //"despesas dos centros de custos improdutivos nos produtivos."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB280",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpc := 1, If( ConaOk(), FechaBatch(), nOpc:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons ,,,430)

IF nOpc == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu(STR0013)
	
	If MAX_LINHA = Nil
		MAX_LINHA :=  CtbLinMax(GetMv("MV_NUMLIN"))
	Endif
	
	If !CTBSerialI("CTBPROC","OFF")
		Return
	Endif

	If MV_PAR11 == 1 .And. !Empty(xFilial("CT2")) // Seleciona filiais
		Processa({|lEnd| Ctb280Fil(MV_PAR12,MV_PAR13)})
	Else
		Processa({|lEnd| Ctb280Proc()})
	EndIf
	
	CTBSerialF("CTBPROC","OFF")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu(STR0014)
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb280Fil ºAutor  ³Alvaro Camillo Neto º Data ³  21/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa o processamento para cada filial                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA280                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb280Fil(cFilDe,cFilAte)
Local cFilIni		:= cFIlAnt
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aSM0			:= AdmAbreSM0()
Local nContFil		:= 0
Local nTamHisCT2	:= TamSX3( "CT2_HIST" )[ 1 ]

Private cFilProces

For nContFil := 1 to Len(aSM0)

	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
		Loop
	EndIf

	//-------------------------------------------------------
	// Posiciona na SM0 para funcionamento do FWGetCodFilial
	//-------------------------------------------------------
	DBSelectArea("SM0")
	SM0->(DBSetOrder(1)) //M0_CODIGO+M0_CODFIL
	If SM0->(DBSeek(aSM0[nContFil][SM0_GRPEMP] + aSM0[nContFil][SM0_CODFIL] ) )

		cFilAnt := FWGETCODFILIAL

		cFilProces := aSM0[nContFil][SM0_CODFIL]

		ProcLogAtu("MENSAGEM",STR0025 + cFilAnt) // "EXECUTANDO A APURACAO DA FILIAL "

		Ctb280Proc(,nTamHisCT2)

	EndIf

Next nContFil

cFIlAnt := cFilIni

RestArea(aAreaSM0)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb280Proc³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Este programa calcula os rateios Off-Line cadastrados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb280Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb280Proc(lBat,nTamHisCT2)

Local lRet 			:= .F.
Local cDoc          := MV_PAR04
Local CTF_LOCK		:= 0
Local cLinha 		:= "001", nLinha := 0
Local cSeqLan 		:= "000"
Local cMoeda		:= ""
Local cHistorico 	:= ""
Local aFormat 		:= {}
Local aSaldos		:= {}

//Variavel lFirst criada para verificar se eh a primeira vez que esta incluindo o
//lancam. contabil. Se for a primeira vez (.T.),ira trazer 001 na linha. Se nao for
//a primeira vez e for para repetir o lancamento anterior, ira atualizar a linha
Local lFirst 		:= .T.
Local lAtSldBase	:= Iif(GetMv("MV_ATUSAL")=="S",.T.,.F.)
Local dDataIni		:= FirstDay(mv_par01), nX, lSaldo := .F., aRateio := {}, nRecnoCtq
Local aPesos		:= {}, lPesClVl, lPesItem, lPesCC, nTipoPeso := 0
Local cTpSald		:= mv_par10
Local lAtSldCmp		:= Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)
Local nInicio		:= If(mv_par08 = 1, 1, Val(mv_par09))
Local nFinal 		:= If(mv_par08 = 1, __nQuantas, Val(mv_par09)), dMinData := Ctod("")
Local lMoedaEsp		:= If(mv_par08 = 1,.F.,.T.)
Local nMoedas
Local nPesos
Local nRateio
Local xFilSLD		:= ""
Local lMudaHist		:= .F.
Local cEntOri 		:= ""
Local nXW			:= 1
Local lCT280FILP	:= ExistBlock("CT280FILP")
Local lCT280Hist	:= ExistBlock("CT280HIST")
Local lProc			:= .F.
Local cProcName     := ""
Local cFilCTQ		:= xFilial("CTQ")
Local lMSBLQL 		:= .T.
Local lSTATUS 		:= .T.
Local nK				:= 0
Local lDefTop 		:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local aEntid
Local lCtrlLinha	:= .F.
Local cDebito		:= ""
Local cCredito      := ""  
Local cProxLin		:= ""

PRIVATE aCols 		:= {} // Utilizada na conversao das moedas
PRIVATE cSubLote
PRIVATE dDataLanc   := mv_par01 // Utilizada na funcao CRIACONV() em CTBA101.PRW

DEFAULT lBat		:= .F.
DEFAULT nTamHisCT2 := TamSX3( "CT2_HIST" )[ 1 ]

If MV_PAR11 == 1 .And. Empty(xFilial("CT2")) 
	ProcLogAtu("MENSAGEM","TRATAMENTO MULTI FILIAL DESABILITADO: CT2 COMPARTILHADO") 
EndIf

// Ajusta parâmetro visando a gravação da tabela CQA 
MV_PAR14 := iIF( IsCtbJob() .and. mv_par14 == 1 , 2 , MV_PAR14 )

// Sub-Lote somente eh informado se estiver em branco
mv_par03 := If(Empty(GetMV("MV_SUBLOTE")), mv_par03, GetMV("MV_SUBLOTE"))
cSubLote := MV_PAR03

If __lCusto = Nil
	__lCusto 	:= CtbMovSaldo("CTT")
Endif

If __lItem == Nil
	__lItem	  	:= CtbMovSaldo("CTD")
EndIf

If __lCLVL == Nil
	__lCLVL	  	:= CtbMovSaldo("CTH")
EndIf

aCols := {}
// rotina de critica dos parametros do processamento do rateio e das entidades bloqueadas
// RFC - Retirada do procesamento principal afim de organizar a rotina
If ! CT280CRTOK()
	Return
Endif

// Parametros validos, posiciona o CT8 (Historico padrao)
dbSelectArea("CT8")
dbSetOrder(1)
dbSeek( xFilial( "CT8" ) + mv_par05 )

cHistorico := ""

If CT8->CT8_IDENT == 'C'
	cHistorico := ALLTRIM(CT8->CT8_DESC)
	lMudaHist := .T.
Else
	aFormat := {}
	While !Eof() .And. CT8->CT8_HIST == mv_par05 .And. CT8->CT8_IDENT == 'I'
		Aadd(aFormat,CT8->CT8_DESC)
		dbSkip()
	Enddo
	
	cHistorico := MSHGetText(aFormat)
	cHistorico := AllTrim(cHistorico)
Endif

If ! lAtSldBase	//Se os saldos nao foram atualizados na dig. lancamentos
	//Chama rotina de atualizacao de saldos basicos
	dIniRep := ctod("")
	
	If Need2Reproc(mv_par01,mv_par09,mv_par10,@dIniRep)
		//Chama Rotina de Atualizacao de Saldos Basicos.
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dIniRep,mv_par01,cFilAnt,cFilAnt,mv_par10,lMoedaEsp,mv_par09) },"","",.F.)
		oProcess:Activate()
	EndIf
EndIf

CriaConv() // Para criar aCols que sera utilizada na conversao de moedas

aColsM := AClone(aCols)
aCols  := {}

For nX := 1 To Len(aColsM)
	If ! Empty(aColsM[nX][1])
		Aadd(aCols, aColsM[nX])
	Endif
Next

DbSelectArea("CTO")
dbSeek( xFilial("CTO") + "01" ,.T.)

AADD(aCols, { "01", " ", 0.00, "2", .F. } )
aSort(aCols,,,{|X,Y| x[1] < y[1]})

aSaldos	:= aClone(aCols)
For nX := 1 To Len(aCols)
	Aadd(aCols[nX], 0)
Next

If !lBat
	ProcRegua(CTQ->(RecCount()))
EndIf

cProcName := "CTB068"    /// "Stored Procedure ainda não homologada no padrão"
cCredito  := CT2->CT2_CREDIT
cDebito   := CT2->CT2_DEBITO


If lDefTop .And. ExistProc( cProcName ) .And. ( TcSrvType() <> "AS/400" )
	lRet := Ct280TCSP( cProcName , mv_par06, mv_par07 , dDataIni , lMudaHist , cHistorico )
Else
	
	// Processa os rateios selecionados
	DbSelectarea("CTQ")
	MsSeek( cFilCTQ + mv_par06 , .T. )
	While CTQ->( ! Eof() ) .And. CTQ->CTQ_FILIAL == cFilCTQ .And. CTQ->CTQ_RATEIO <= mv_par07
		
		DbSelectArea("CTQ")
		cCtq_Rateio	:= CTQ->CTQ_RATEIO
		
		If __lCT280Skip
			If ! Execblock("CT280SKIP",.F.,.F.)
				CTQ->(MsSeek( cFilCTQ + Soma1( cCtq_Rateio ),.T.))
				Loop
			Endif
		EndIf
		
		// restrição de bloqueio ou pelo status
		If lMSBLQL .Or. lSTATUS
			IF ( lMSBLQL .AND. CTQ->CTQ_MSBLQL == '1' ) .Or. ( lSTATUS .AND. CTQ->CTQ_STATUS <> '1' )
				CTQ->(MsSeek( cFilCTQ + Soma1( cCtq_Rateio ),.T.))
				Loop
			ENDIF
		Endif
		
				// Localiza conta origem para exibir descricao da conta na moeda a ser processada
		DbSelectArea("CT1")
		MsSeek(xFilial("CT1")+CTQ->CTQ_CTORI)
		
		// RFC - Isolado a rotina para melhotar a manutenção
		// Retorna os saldos para o processamento
		GetSldRat( dDataIni , @aSaldos , @lSaldo , .T. )
		
		lUltimoLanc := .F.
		IncProc( STR0007 + CTQ->CTQ_CTORI + " " + CT1->&( "CT1_DESC" + aCols[1][1] )) //"Rateando conta: "
		
		If lSaldo // Se tiver saldo, processa os rateios cadastrados
			aRateio 	:= {}
			aPesos		:= {}
			lPesCC 		:= lPesItem := lPesClvl := .F.
			nTipoPeso	:= 0
			
			If lMudaHist
				// Bloco para retornar a conta origem no historico
				cEntOri := ""
				If !Empty(CTQ->CTQ_CTORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_CTORI)
				EndIf
				If !Empty(CTQ->CTQ_CCORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_CCORI)
				EndIf
				If !Empty(CTQ->CTQ_ITORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_ITORI)
				EndIf
				If !Empty(CTQ->CTQ_CLORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_CLORI)
				EndIf
				If __lEnt05 .And. !Empty(CTQ->CTQ_E05ORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_E05ORI)
				EndIf
				If __lEnt06 .And. !Empty(CTQ->CTQ_E06ORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_E06ORI)
				EndIf
				If __lEnt07 .And. !Empty(CTQ->CTQ_E07ORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_E07ORI)
				EndIf
				If __lEnt08 .And. !Empty(CTQ->CTQ_E08ORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_E08ORI)
				EndIf
				If __lEnt09 .And. !Empty(CTQ->CTQ_E09ORI)
					cEntOri += "-"+ALLTRIM(CTQ->CTQ_E09ORI)
				EndIf

			EndIf

			If Empty(CTQ->CTQ_CTPAR)
				lPesCC 	 	:= !Empty(CTQ->CTQ_CCPAR)
				lPesItem 	:= !Empty(CTQ->CTQ_ITPAR)
				lPesClvl 	:= !Empty(CTQ->CTQ_CLPAR)
				nTipoPeso   := If(CTQ->CTQ_TIPO = "1", 3, 4)
				
				For nX := 1 To Len(aSaldos)
					aSaldos[nX][3] := 0
				Next
				
				nX := 0
				For nX := 1 To Len(aCols)
					
					If lMoedaEsp // Moeda especifica
						If nX != Val(MV_PAR09)
							Loop
						EndIf
					Endif
					
					If lPesClVl
						dbSelectArea("CQ7")
						dbSetOrder(2) //CQ7_FILIAL+CQ7_CLVL+CQ7_MOEDA+CQ7_TPSALD+DTOS(CQ7_DATA) 
						cMoeda := StrZero(nX,2)
						xFilSLD:= xFilial("CQ7")
						
						MsSeek(xFilSLD+CTQ->CTQ_CLPAR+cMoeda+cTpSald,.F.) // Posiciona na primeira Cl. de Valor
						
						While !Eof() .And. CQ7->CQ7_FILIAL == xFilSLD .And. CQ7->CQ7_CLVL == CTQ->CTQ_CLPAR .and. CQ7->CQ7_MOEDA = cMoeda .and. CQ7->CQ7_TPSALD = cTpSald 
							
							cConta := CQ7->CQ7_CONTA
							cCusto := ""
							cItem  := ""
							While !Eof() .And. CQ7->CQ7_FILIAL == xFilSLD .And. CQ7->CQ7_CLVL == CTQ->CTQ_CLPAR .and. CQ7->CQ7_MOEDA = cMoeda .and. CQ7->CQ7_TPSALD = cTpSald .and. CQ7->CQ7_CONTA = cConta
								
					
								If CTQ->CTQ_TIPO = "1"				/// SE FOR RATEIO DE MOVIMENTO
									If CQ7->CQ7_DATA < dDataIni .or. CQ7->CQ7_DATA > mv_par01
										dbSkip()
										Loop
									EndIf
								Else								/// SE FOR RATEIO DE SALDO
									If CQ7->CQ7_DATA > mv_par01
										dbSkip()
										Loop
									EndIf
								EndIf
								
								If CQ7->CQ7_CCUSTO <> cCusto .or. CQ7->CQ7_ITEM <> cItem
									cCusto := CQ7->CQ7_CCUSTO
									cItem  := CQ7->CQ7_ITEM
									
									If (!lPesCC .or. CQ7->CQ7_CCUSTO == CTQ->CTQ_CCPAR) .And. (!lPesITEM .or. CQ7->CQ7_ITEM == CTQ->CTQ_ITPAR)
										If lCT280FILP
											If !ExecBlock("CT280FILP",.f.,.f.,{"CQ7"})
												dbSelectArea("CQ7")
												dbSkip()
												Loop
											EndIf
										EndIf
										
										If (nPesos := Ascan(aPesos, {|x| x[3] == CQ7->CQ7_CLVL+CQ7->(CQ7_CONTA+CQ7_CCUSTO+CQ7->CQ7_ITEM) })) <= 0
											Aadd(aPesos, {	Array(Len(aCols)) , CQ7->(Recno()) , CQ7->(CQ7_CLVL + CQ7_CONTA + CQ7_CCUSTO + CQ7_ITEM) ,CQ7->CQ7_CONTA })
											nPesos := Len(aPesos)
										Endif
										
										For nXW := 1 To Len(aCols)
											If lMoedaEsp // Moeda especifica
												If nXW != Val(MV_PAR09)
													Loop
												EndIf
											Endif
											If Empty(aPesos[nPesos][1][nXW]) .and. aPesos[nPesos][1][nXW] <> 0
												aPesos[nPesos][1][nXW] := MovClass(CQ7->CQ7_CONTA,CQ7->CQ7_CCUSTO,CQ7->CQ7_ITEM,CQ7->CQ7_CLVL,dDataIni,mv_par01,aCols[nXW][1],mv_par10, nTipoPeso)
												aPesos[nPesos][1][nXW] := Round(aPesos[nPesos][1][nXW] * (CTQ->CTQ_PERBAS / 100),4)
												aSaldos[nXW][3] += aPesos[nPesos][1][nXW]
											Endif
										Next
										
									EndIf
								Endif
								
								dbSkip()
							EndDo
						Enddo
						
					ElseIf lPesItem
						
						dbSelectArea("CQ5")
						dbSetOrder(2)
						cMoeda := StrZero(nX,2)
						xFilSLD:= xFilial("CQ5")
						MsSeek(xFilSLD+CTQ->CTQ_ITPAR+cMoeda+cTpSald,.T.) // Posiciona no primeiro Item Contabil
						
						While !Eof() .And. CQ5->CQ5_FILIAL == xFilSLD .And. CQ5->CQ5_ITEM == CTQ->CTQ_ITPAR .and. ;
								CQ5->CQ5_MOEDA = cMoeda .and. CQ5->CQ5_TPSALD = cTpSald 
							
							cConta := CQ5->CQ5_CONTA
							cCusto := ""
							
							While !Eof() .and. CQ5->CQ5_FILIAL == xFilSLD .And. CQ5->CQ5_ITEM == CTQ->CTQ_ITPAR .and.;
								 CQ5->CQ5_MOEDA = cMoeda .and. CQ5->CQ5_TPSALD = cTpSald .and. CQ5->CQ5_CONTA == cConta
				
								If CTQ->CTQ_TIPO = "1"				/// SE FOR RATEIO DE MOVIMENTO
									If CQ5->CQ5_DATA < dDataIni .or. CQ5->CQ5_DATA > mv_par01
										dbSkip()
										Loop
									EndIf
								Else								/// SE FOR RATEIO DE SALDO
									If CQ5->CQ5_DATA > mv_par01
										dbSkip()
										Loop
									EndIf
								EndIf
								
								If CQ5->CQ5_CCUSTO <> cCusto
									cCusto := CQ5->CQ5_CCUSTO
									
									If !lPesCC .or. CQ5_CCUSTO == CTQ->CTQ_CCPAR
										If lCT280FILP
											If !ExecBlock("CT280FILP",.f.,.f.,{"CQ5"})
												dbSelectArea("CQ5")
												dbSkip()
												Loop
											EndIf
										EndIf
										
										If (nPesos := Ascan(aPesos, { |x| x[3] == CQ5->(CQ5_ITEM+CQ5_CONTA+CQ5_CCUSTO) })) <= 0
											Aadd(aPesos, {Array(Len(aCols)),CQ5->(Recno()), CQ5_ITEM+CQ5_CONTA+CQ5_CCUSTO , CQ5->CQ5_CONTA })
											nPesos := Len(aPesos)
										Endif
										
										For nXW := 1 To Len(aCols)
											If lMoedaEsp // Moeda especifica
												If nXW != Val(MV_PAR09)
													Loop
												EndIf
											Endif
											If Empty(aPesos[nPesos][1][nXW]) .and. aPesos[nPesos][1][nXW] <> 0
												aPesos[nPesos][1][nXW] := MovItem(CQ5->CQ5_CONTA,CQ5->CQ5_CCUSTO, CQ5->CQ5_ITEM,dDataIni,mv_par01,aCols[nXW][1],mv_par10, nTipoPeso)
												aPesos[nPesos][1][nXW] := Round(aPesos[nPesos][1][nXW] * (CTQ->CTQ_PERBAS / 100),4)
												aSaldos[nXW][3] += aPesos[nPesos][1][nXW]
											Endif
										Next
										
									Endif
								Endif
								dbSkip()
							EndDo
						EndDo
						
					ElseIf lPesCC
						dbSelectArea("CQ3")
						dbSetOrder(2)
						cMoeda := StrZero(nX,2)
						xFilSLD := xFilial("CQ3")
						MsSeek(xFilSLD+CTQ->CTQ_CCPAR+cMoeda+cTpSald,.T.) // Posiciona na primeiro centro de Custo
						
						cConta := ""
						While !Eof() .And. CQ3->CQ3_FILIAL == xFilSLD .And. CQ3->CQ3_MOEDA  == cMoeda .And.;
							CQ3->CQ3_TPSALD == cTpSald .And. CQ3->CQ3_CCUSTO == CTQ->CTQ_CCPAR
							
							If CTQ->CTQ_TIPO = "1"				/// SE FOR RATEIO DE MOVIMENTO
								If CQ3->CQ3_DATA < dDataIni .or. CQ3->CQ3_DATA > mv_par01
									dbSkip()
									Loop
								EndIf
							Else								/// SE FOR RATEIO DE SALDO
								If CQ3->CQ3_DATA > mv_par01
									dbSkip()
									Loop
								EndIf
							EndIf
							
							
							If CQ3->CQ3_CONTA <> cConta
								cConta := CQ3->CQ3_CONTA
								If lCT280FILP
									If !ExecBlock("CT280FILP",.f.,.f.,{"CQ3"})
										dbSelectArea("CQ3")
										dbSkip()
										Loop
									EndIf
								EndIf
								
								If (nPesos := Ascan(aPesos, { |x| x[3] == CQ3->CQ3_CCUSTO+CQ3->CQ3_CONTA })) <= 0
									Aadd(aPesos, {	Array(Len(aCols)), CQ3->(Recno()), CQ3->(CQ3_CCUSTO+CQ3_CONTA), CQ3->CQ3_CONTA })
									nPesos := Len(aPesos)
								Endif
								
								For nXW := 1 To Len(aCols)
									If lMoedaEsp // Moeda especifica
										If nXW != Val(MV_PAR09)
											Loop
										EndIf
									Endif
									If Empty(aPesos[nPesos][1][nXW]) .and. aPesos[nPesos][1][nXW] <> 0
										aPesos[nPesos][1][nXW] := MovCusto(CQ3->CQ3_CONTA,CQ3->CQ3_CCUSTO,dDataIni,mv_par01,aCols[nXW][1],mv_par10, nTipoPeso)
										aPesos[nPesos][1][nXW] := Round(aPesos[nPesos][1][nXW] * (CTQ->CTQ_PERBAS / 100),4)
										aSaldos[nXW][3] += aPesos[nPesos][1][nXW]
									Endif
								Next
							Endif
							
							CQ3->(dbSkip())
						Enddo
					Endif
					
				Next
				
			Endif
			
 			While CTQ->(!Eof()) .And. CTQ->CTQ_FILIAL == cFilCTQ .And. CTQ->CTQ_RATEIO == cCtq_Rateio
				Aadd(aRateio, CTQ->(Recno()))
				
				DbSelectArea("CTQ")
				DbSkip()
			Enddo
			
			nRecnoCtq := CTQ->(Recno())

			If !lCT280Hist
				lCtrlLinha := CtrHistLng( cHistorico + cEntOri , nTamHisCT2 )
			EndIf
			
			For nRateio := 1 To Len(aRateio)
				CTQ->(DbGoto(aRateio[nRateio]))
				
				aEntid := GetAEntidades()
				
				If lCT280Hist		/// P.ENTRADA PARA ALTERAÇÃO DO HISTORICO
					cHistorico := ExecBlock("CT280HIST",.F.,.F.,{cHistorico})
					cHistorico := AllTrim(cHistorico)
					lCtrlLinha := CtrHistLng( cHistorico + cEntOri , nTamHisCT2 )
				EndIf
				
				
				If Len(aPesos) > 0
					For nPesos := 1 To Len(aPesos)
						Ct280GerRat(@lFirst, @nLinha, @cLinha, @cDoc, @CTF_LOCK, @cSeqLan,;
						cHistorico+cEntOri, lAtSldBase, aSaldos,;
						aPesos[nPesos][4],aPesos[nPesos][4],;
						CTQ->CTQ_CCCPAR,CTQ->CTQ_CCPAR,CTQ->CTQ_ITCPAR,;
						CTQ->CTQ_ITPAR,CTQ->CTQ_CLCPAR,CTQ->CTQ_CLPAR,;
						nRateio = Len(aRateio) .And.;
						nPesos = Len(aPesos), aPesos[nPesos][1], aEntid,lCtrlLinha,@cProxLin)
					Next nPesos
				Else
					cCTCPAR := CTQ->CTQ_CTCPAR
					
					If Empty(cCTCPAR)
						If !Empty(CTQ->CTQ_CTPAR)
							cCTCPAR := CTQ->CTQ_CTPAR
						ElseIf !Empty(CTQ->CTQ_CTORI)
							cCTCPAR := CTQ->CTQ_CTORI
						Else
							CTQ->(DbGoto(nRecnoCtq))
							Loop
						EndIf
					EndIf
							
					Ct280GerRat(@lFirst, @nLinha, @cLinha, @cDoc, @CTF_LOCK, @cSeqLan,;
					cHistorico+cEntOri, lAtSldBase, aSaldos,;
					cCTCPAR,CTQ->CTQ_CTPAR,;
					CTQ->CTQ_CCCPAR,CTQ->CTQ_CCPAR,CTQ->CTQ_ITCPAR,;
					CTQ->CTQ_ITPAR,CTQ->CTQ_CLCPAR,CTQ->CTQ_CLPAR,;
					nRateio = Len(aRateio),,aEntid,lCtrlLinha,@cProxLin)

				EndIf

				cLinha := cProxLin

			Next nRateio
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava tabela de historico de rateios off-line (CV9) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CtbHistRat( CTQ->CTQ_RATEIO, mv_par02, mv_par03, cDoc, mv_par01, "CTBA280", "CTQ" )
			
			CTQ->(DbGoto(nRecnoCtq))
		Else
			CTQ->(MsSeek(cFilCTQ+Soma1(cCtq_Rateio),.T.))
		Endif
	Enddo
	
	If mv_par14 == 1 .And. !__lJobs
		//atualiza saldo no final do processamento								  
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,mv_par01,mv_par01,cFilAnt,cFilAnt,mv_par10,lMoedaEsp,mv_par09) },"","",.F.)
		oProcess:Activate()
	EndIf
EndIf

If CTF_LOCK > 0					/// LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL
	dbSelectArea( "CTF" )
	dbGoTo( CTF_LOCK )
	CtbDestrava(mv_par01,mv_par02,mv_par03,cDoc,@CTF_LOCK)
Endif

If __lAvisoSP <> Nil .and. __lAvisoSP .and. !IsBlind()
	//'Erro na chamada do processo - Gravacao de Saldos - CTB150'
	MsgInfo(STR0010+ CRLF+CRLF+STR0012,cCadastro)//'Deve-se executar reprocessamento de saldos e verificar os rateios gerados.'
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct280GerRat³ Autor ³ Wagner Mobile Costa  ³ Data ³ 13.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o lancamento de rateio no CT2                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct280GerRat(lFirst, nLinha, cLinha, cDoc, CTF_LOCK, cSeqLan,³±±
±±³          ³            lUltimoLanc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lFirst   = Indica se esta efetuando o 1o Lancto.           ³±±
±±³          ³ nLinha   = Numero da linha atual que esta sendo gerado     ³±±
±±³          ³ USADA PARA COMPARACAO COM O NUMERO MAXIMO DE LINHAS P/ DOC ³±±
±±³          ³ cLinha   = Numero da linha atual utilizada para gravacao   ³±±
±±³          ³ cDoc     = Numero do Documento utilizado para gravacao     ³±±
±±³          ³ CTF_LOCK = Lock de semaforo do documento                   ³±±
±±³          ³ cSeqLan  = Sequencia do lancamento atual                   ³±±
±±³          ³ cHistorico = Historico do lancamento de rateio             ³±±
±±³          ³ lAtSldBase = Indica se devera gerar saldos basicos (CT7 ..)³±±
±±³          ³ aSaldos  = Array com os saldos por moeda                   ³±±
±±³          ³ cCt1CPar = Conta a debito do rateio						  ³±±
±±³          ³ cCt1Par = Conta a credito do rateio						  ³±±
±±³          ³ cCttCPar = Centro de custo a debito do rateio			  ³±±
±±³          ³ cCttPar = Centro de custo a credito do rateio			  ³±±
±±³          ³ cCtdCPar = Item Contabil a debito do rateio			  	  ³±±
±±³          ³ cCtdPar = Item Contabil a credito do rateio			  	  ³±±
±±³          ³ cCthCPar = Classe Valor a debito do rateio			  	  ³±±
±±³          ³ cCthPar = Classe de Valor a credito do rateio			  ³±±
±±³          ³ lUltimoL = Indica se eh a geracao do ultimo lancto rateio  ³±±
±±³          ³ aPesos   = Array com os pesos para cada moeda              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct280GerRat(lFirst, nLinha, cLinha, cDoc, CTF_LOCK, cSeqLan, cHistorico,;
lAtSldBase, aSaldos, cCt1CPar, cCt1Par, cCttCPar, cCttPar,;
cCtdCPar, cCtdPar, cCthCPar, cCthPar, lUltimoL, aPesos, aEntid, lCtrlLinha,cProxLin)

Local nX		:= 0
Local nDif
Local nSaldo
Local nValorLanc
Local cGrvM1 	:= "3"				/// SE DEVE GRAVAR O LANCAMENTO NA MOEDA 1 (P/ PROC. ESPECIFICO) 0=Nao / 1=Vlr < 0 / 2=Vlr > 0
Local nVlrMX 	:= 0
Local cSoma  	:= STRZERO(SuperGetMv("MV_SOMA"),1)
Local lDefTop 	:= IfDefTopCTB()// verificar se pode executar query (TOPCONN)
Local aOutros	:= {}
Local nEntid
Local cLinhaAux := cLinha
Local lRet      := .T. 
Local lCttPar   := .T.
Local lCtdPar   := .T.
Local lCthPar   := .T.
Local lCt1Par   := .T.
Local lCttCPar  := .T.
Local lCtdCPar  := .T.
Local lCthCPar  := .T.
Local lCt1CPar  := .T.
Local lEntD     := .T.
Local lEntC     := .T.
Private cSeqCorr := ""

Default aEntid := {}
Default lCtrlLinha := .F.
Default cProxLin	:= ""

// se seqlan 0 ou nao informado passa a ser 1, se informado incrementa
cSeqLan := IIf(Empty(cSeqLan), StrZero(1, Len(CT2->CT2_SEQLAN)), Soma1(cSeqLan))

If __lCTB150 == Nil
	If __lAS400
		__lCTB150	:= .F.
	Else
		__lCTB150	:= ExistProc("CTB150")
		__lFKInUse	:= FkInUse()
	EndIf
EndIf

//Chamar a multlock
aTravas := {}
IF !Empty(cCT1PAR)
	AADD(aTravas,cCT1PAR)
Endif
IF !Empty(cCT1CPAR)
	AADD(aTravas,cCT1CPAR)
Endif

lCttPar  := CTB105CC   (cCttPar)
lCtdPar  := Ctb105Item (cCtdPar)
lCthPar  := Ctb105ClVl (cCthPar)
lCt1Par  := Ctb105Cta  (cCt1Par)
lCttCPar := CTB105CC   (cCttCPar)
lCtdCPar := Ctb105Item (cCtdCPar)
lCthCPar := Ctb105ClVl (cCthCPar)
lCt1CPar := Ctb105Cta  (cCt1CPar)

For nX := 1 to Len(aEntid)
	lEntD := CTB105EntC(,aEntid[nX][1],,StrZero(nX+4, 2)) //Valida Débito
	lEntC := CTB105EntC(,aEntid[nX][2],,StrZero(nX+4, 2)) //Valida Crédito
Next

If !lCttPar .Or. !lCtdPar .Or. !lCthPar .Or. !lCt1Par .Or. !lCttCPar .Or. !lCtdCPar .Or. !lCthCPar .Or. !lCt1CPar .Or. !lEntD .Or. !lEntC 
	lRet 	:= .F.
	Return
EndIf

If lRet .And. STRZERO(VAL(cDoc),6) > "999000"
	MsgInfo(STR0028) //Número do Documento não permitido - Utilize no máximo o código 999000
	lRet 	:= .F.
Endif

/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
If lRet .And.  IIf(!__lJobs,CtbCanGrv(aTravas,@lAtSldBase),.T.) 
	
	BEGIN TRANSACTION
	
	For nX := 1 To Len(aCols)
		
		nSaldo := aSaldos[nX][3]
		
		If (mv_par08 == 2 .And. nX <> Val(mv_par09)) .And. nX <> 1
			Loop
		Endif
		
		If nSaldo == 0 .And. nX <> 1
			Loop
		Endif
		
		nValorLanc := Round( nSaldo * ( CTQ->CTQ_PERCEN / 100 ) , 4)
		
		If aPesos # Nil .and. aPesos[nX] # Nil
			nValorLanc *= ABS(aPesos[nX]) / ABS(aSaldos[nX][3])
		Endif
		
		If aPesos <> Nil .and. aPesos[nX] <> Nil
			If ( aPesos[nX] < 0 .and. nValorLanc > 0 ) .or. (aPesos[nX] > 0 .and. nValorLanc < 0)
				nValorLanc *= -1
			EndIf
		Else
			If (nSaldo < 0 .and. nValorLanc > 0) .or. (nSaldo > 0 .and. nValorLanc < 0)
				nValorLanc *= -1
			EndIf
		EndIf
		
		nValorLanc := Round( nValorLanc ,2 ) // faz o arredondamento para a gravação do lançamento
		
		// Calcula a diferenca de rateio e ajusta o valor do lancamento
		aCols[nX][Len(aCols[nX])] += nValorLanc // Valor Lancamento
		
		If lUltimoL
			nDif := nSaldo - aCols[nX][Len(aCols[nX])]
			
			IF ( nDif # 0 )
				nValorLanc := Round( nValorLanc + nDif , 2 )
			ENDIF
			
			/* 			If nDif < 0
			If nDif < nValorLanc						  /// SO RETIRA SE A DIFERENCA FOR MENOR QUE O VALOR DO LANC.
			nValorLanc -= ABS(nDif)                   /// PARA NAO GERAR LANC. COM VLR NEGATIVO
			Endif										  /// CASO CONTRARIO NAO EFETUA AJUSTE DA DIFERENCA
			Endif
			*/
		EndIf
		
		aCols[nX][3] := nValorLanc // Valor Lancamento
		
		// Saldo origem negativo, lanca a credito na conta partida e outro
		// a debito na conta rateada (contra partida)
		If ( nSaldo <> 0 .and. nValorLanc <> 0 ) .or. ( nX == 1 .and. mv_par08 == 2 .and. mv_par09 <> "01" )
			
			If (nX == 1 .and. mv_par08 == 2 .and. mv_par09 <> "01")/// SE FOR MOEDA ESPECIFICA DIFERENTE DE MOEDA 01
				nMoedaPar := val(mv_par09)
				
				nVlrMX := NoRound(aSaldos[nMoedaPar][3]*(CTQ->CTQ_PERCEN/100), 4)
				
				If aPesos # Nil .and. aPesos[nMoedaPar] # Nil
					nVlrMX *=  ABS(aPesos[nMoedaPar]) / ABS(aSaldos[nMoedaPar][3])
				Endif
				
				nVlrMX := Round(nVlrMX,2)
				
				If aPesos <> Nil .and. aPesos[nMoedaPar] <> Nil
					If ( aPesos[nMoedaPar] < 0 .and. nVlrMX > 0 ) .or. (aPesos[nMoedaPar] > 0 .and. nVlrMX < 0)
						nVlrMX *= -1
					EndIf
				Else
					If (aSaldos[nMoedaPar][3] < 0 .and. nVlrMX > 0) .or. (aSaldos[nMoedaPar][3] > 0 .and. nVlrMX < 0)
						nVlrMX *= -1
					EndIf
				EndIf
				
				If nVlrMX < 0
					cGrvM1 := "1"	 /// SO GRAVA NA MOEDA 1 SE HOUVER SALDO NA MOEDA ESPECIFICA
				ElseIf nVlrMX > 0
					cGrvM1 := "2"	 /// SO GRAVA NA MOEDA 1 SE HOUVER SALDO NA MOEDA ESPECIFICA
				Else
					cGrvM1 := "0"	 /// CASO CONTRARIO NAO IRA GRAVAR O LANCAMENTO
				EndIf
			Else
				cGrvM1 := "3"	 /// POR DEFAULT DEVE GRAVAR O LANCAMENTO
			Endif
						
			// Gravação do lancamento do rateio off
			If cGrvM1 <> "0"
			    
				If lFirst .Or.  nLinha >= MAX_LINHA 
	   				Do While !ProxDoc(mv_par01,mv_par02,mv_par03,@cDoc,@CTF_LOCK)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso o N§ do Doc estourou, incrementa o lote         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cLote := CtbInc_Lot(cLote, cModulo)
						
					Enddo
					lFirst := .F.
					nLinha := 1
					cSeqLan := StrZero(nLinha, Len(CT2->CT2_SEQLAN))
					cLinhaAux := cLinha := StrZero(nLinha, Len(CT2->CT2_LINHA))
				Endif
			  
				aCols[nX][3] := ABS(aCols[nX][3])
				
				If cPaisLoc == 'CHI' .and. nLinha < 2  // a partir da segunda linha do lanc., o correlativo eh o mesmo
					cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote) )
				EndIf
				
				nRecLan := 0
				nRecPos	:= 0
				
				aOutros := {}
				
				If nValorLanc < 0 .or. cGrvM1 == "1"    
					For nEntid := 1 to Len(aEntid)   //se valor a debito permanece aOutros 
						&("M->"+"CT2_EC"+StrZero(nEntid+4, 2)+"DB")	:= aEntid[nEntid][1]
						AADD(aOutros,"CT2_EC"+StrZero(nEntid+4, 2)+"DB")
						&("M->"+"CT2_EC"+StrZero(nEntid+4, 2)+"CR")	:= aEntid[nEntid][2]
						AADD(aOutros,"CT2_EC"+StrZero(nEntid+4, 2)+"CR")
					Next
					GravaLanc(	mv_par01,mv_par02,mv_par03,cDoc,cLinha,"3",aCols[nX][1],;
					mv_par05,cCt1CPar, cCt1Par, cCttCPar, cCttPar,;
					cCtdCPar, cCtdPar, cCthCPar, cCthPar,;
					ABS(nValorLanc),cHistorico,mv_par10,cSeqLan,3,lAtSldBase,;
					aCols,cEmpAnt,cFilAnt,0,;
					,,,, "CTBA280" ,,,aOutros,,@nRecLan,,,,, CTQ->CTQ_INTERC,,,@cProxLin)
					
				ElseIf nValorLanc > 0 .or. cGrvM1 == "2"
					For nEntid := 1 to Len(aEntid)  //se valor a credito inverte aOutros 
						&("M->"+"CT2_EC"+StrZero(nEntid+4, 2)+"DB")	:= aEntid[nEntid][2]
						AADD(aOutros,"CT2_EC"+StrZero(nEntid+4, 2)+"DB")
						&("M->"+"CT2_EC"+StrZero(nEntid+4, 2)+"CR")	:= aEntid[nEntid][1]
						AADD(aOutros,"CT2_EC"+StrZero(nEntid+4, 2)+"CR")
					Next
					GravaLanc(	mv_par01,mv_par02,mv_par03,cDoc,cLinha,"3",aCols[nX][1],;
					mv_par05,cCt1Par, cCt1CPar, cCttPar, cCttCPar,;
					cCtdPar, cCtdCPar, cCthPar, cCthCPar, nValorLanc,cHistorico,;
					mv_par10,cSeqLan,3,lAtSldBase,aCols,cEmpAnt,cFilAnt,0,;
					,,,, "CTBA280" ,,,aOutros,,@nRecLan,,,,, CTQ->CTQ_INTERC,,,@cProxLin)
				Endif
				
				// verifica se a rotina de gravacao gravou mais de uma linha
				If !Empty(CT2->CT2_LINHA) .And. cLinhaAux <= CT2->CT2_LINHA
					cLinhaAux := Soma1(CT2->CT2_LINHA)
				EndIf

				CT2->(dbCommit())										/// SOMENTE DEPOIS DE ATUALIZADA A LIB
				
				If lDefTop .And. !__lAS400 .and. __lCTB150
					nRecPos := CT2->(Recno())
					If nRecPos <> nRecLan
						CT2->(dbGoTo(nRecLan))
					EndIf
					
					aResult := TCSPEXEC( xProcedures('CTB150'), IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ), CT2->CT2_LOTE, CT2->CT2_SBLOTE,CT2->CT2_DOC, Dtos(CT2->CT2_DATA)	, "3"				 , cSoma 			   , CT2->CT2_LINHA, CT2->CT2_MOEDLC	,'0'						, If(__lFKInUse, '1' , '0' ))
					
					If Empty(aResult) .and. __lAvisoSP == Nil
						If !IsBlind()
							MsgAlert(STR0010)//'Erro na chamada do procedure - Gravacao de Saldos - CTB150'
							If MsgYesNo(STR0011)//"Deseja cancelar esta mensagem caso volte a ocorrer ? "
								__lAvisoSP := .T.
							EndIf
						EndIf
					Endif
					
					If nRecPos <> nRecLan
						CT2->(dbGoTo(nRecPos))
					EndIf
				ElseIf mv_par14 == 2 .And. !__lJobs 
					// efetua a gravação dos saldos para o lancamento de rareio
					If nValorLanc < 0 .or. cGrvM1 == "1"
						CtbGravSaldo(	mv_par02, mv_par03 , cDoc    , mv_par01, '3'    , aCols[nX][1] , cCt1CPar  ,;
									cCt1Par , cCttCPar , cCttPar , cCtdCPar, cCtdPar, cCthCPar     , cCthPar   ,;
									ABS(nValorLanc)    , mv_par10, 3  , "" , ""  , "" , "" , "" ,  "" , "" , "" , 0 ,;
									  " "," ", "  ", __lCusto, __lItem,__lClVL, Abs(nSaldo),,,,,,,,,,,,,,aEntid )
					ElseIf nValorLanc > 0 .or. cGrvM1 == "2"
						CtbGravSaldo(	mv_par02, mv_par03 , cDoc    , mv_par01, '3'    , aCols[nX][1] , cCt1Par,;
						cCt1CPar ,  cCttPar , cCttCPar , cCtdPar, cCtdCPar,  cCthPar, cCthCPar     ,;
						ABS(nValorLanc)    , mv_par10, 3  , "" , ""  , "" , "" , "" , "" , "" , "" , 0 , " ",;
						" ", "  ", __lCusto, __lItem,__lClVL, Abs(nSaldo),,,,,,,,,,,,,, aEntid )
					EndIf
				EndIf
			EndIf
		Endif
	Next
	
	cLinha := cLinhaAux
	nLinha := DecodSoma1(cLinhaAux)
	
	END TRANSACTION
	
EndIF

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT280CrtOkºAutor  ³Renato F. Campos    º Data ³  08/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Validação dos parametros                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT280CrtOk()
Local aSaveArea	:= GetArea()
Local lRet 		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de iniciar o processamento, verifico os parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte( "CTB280", .F. )

// Data de referencia nao preenchida.
IF lRet .And. Empty(mv_par01)
	lRet := .F.
	Help(" ",1,"NOCTBDTLP")
	ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))
Endif

// Lote nao preenchido
IF lRet .And. Empty(mv_par02)
	lRet := .F.
	Help(" ",1,"NOCT280LOT")
	ProcLogAtu("ERRO","NOCT280LOT",Ap5GetHelp("NOCT280LOT"))
Endif

// Sub Lote nao preenchido
IF lRet .And. Empty(mv_par03)
	lRet := .F.
	Help(" ",1,"NOCTSUBLOT")
	ProcLogAtu("ERRO","NOCTSUBLOT",Ap5GetHelp("NOCTSUBLOT"))
Endif

// Validacoes do Documento
IF lRet
	If Empty(MV_PAR04)
		lRet := .F.
		Help(" ",1,"NOCT280DOC")
		ProcLogAtu("ERRO","NOCT280DOC",Ap5GetHelp("NOCT280DOC"))
	Else
		If Type(MV_PAR04) == "N"
			MV_PAR04 := StrZero(Val(MV_PAR04),6)
		Else
			lRet := .F.
			Help(" ",1,"ProxDoc",,STR0026,1,0,,,,,,{STR0027}) //"O número do documento contábil não pode conter caracteres."###"Revise o número do documento contábil definido para processamento da rotina."
			ProcLogAtu("ERRO","CT280CrtOk",STR0026) //"O número do documento contábil não pode conter caracteres."
		EndIf
	EndIf
EndIf

// Historico Padrao nao preenchido
IF lRet .And. Empty(mv_par05)
	lRet := .F.
	Help(" ",1,"CTHPVAZIO")
	ProcLogAtu("ERRO","CTHPVAZIO",Ap5GetHelp("CTHPVAZIO"))
Endif

If lRet
	//Historico Padrao nao existe no cadastro.
	dbSelectArea("CT8")
	dbSetOrder(1)
	
	IF ! dbSeek( xFilial( "CT8" ) + mv_par05 )
		lRet := .F.
		Help(" ",1,"CT280NOHP")
		ProcLogAtu("ERRO","CT280NOHP",Ap5GetHelp("CT280NOHP"))
	Endif
Endif

// Rateio inicial e final nao preenchidos.
IF lRet .And. Empty(mv_par06) .And. Empty(mv_par07)
	lRet := .F.
	Help(" ",1,"NOCT280RT")
	ProcLogAtu("ERRO","NOCT280RT",Ap5GetHelp("NOCT280RT"))
Endif

// Moeda especifica nao preenchida
IF lRet .And. mv_par08 == 2 .And. Empty(mv_par09)
	lRet := .F.
	Help(" ",1,"NOCTMOEDA")
	ProcLogAtu("ERRO","NOCTMOEDA",Ap5GetHelp("NOCTMOEDA"))
Endif

// Tipo de saldo nao preenchido
IF lRet .And. Empty(mv_par10)
	lRet := .F.
	Help(" ",1,"NO280TPSLD")
	ProcLogAtu("ERRO","NO280TPSLD",Ap5GetHelp("NO280TPSLD"))
Endif

//Verificar se o calendario da data solicitada esta encerrado
IF lRet .And. ! CtbValiDt(1,mv_par01,,mv_par10)
	lRet := .F.
	ProcLogAtu("ERRO","CTBVALIDT","CTBVALIDT")
EndIf

// Efetua a validação do rateio
IF lRet .And. ! CT280RTOK( mv_par06 , mv_par07 )
	lRet := .F.
Endif

IF lRet .And. ExistBlock( "CT280MVOK" )
	lRet := ExecBlock( "CT280MVOK", .F., .F. )
Endif

RestArea(aSaveArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetSldRat ºAutor  ³Renato F. Campos    º Data ³  08/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetSldRat( dDataIni , aSaldos , lSaldo , lIncProc )
Local aSaveArea	:= GetArea()
Local nMoeda	:= 1
Local nX		:= 1
Local cFilback	:= cFilant
Local aSaldoAux	:= {}
Local aEnt		:= {}

DEFAULT lSaldo 		:= .T.
DEFAULT aSaldos		:= {}
DEFAULT lIncProc	:= .F.

If Type("cFilProces") == "U"
	cFilProces :=cFilant
EndIf

// tratativa para a Moeda Especifica
If MV_PAR08 == 2
	nMoeda := VAL( mv_par09 )
Endif
cFilant:= cFilProces

// percorro os itens da aCols
For nX := nMoeda To Len( aCols )

	IF lIncProc
		IncProc( STR0005 + CTQ->CTQ_CTORI + STR0006 + aCols[nX][1]+" "+aCols[nX][2]) //"Obtendo saldo da conta: " ## " moeda "
	Endif

	aSaldos[nX][3] := 0

	//--------------------------------------------------------------
	// Tratamento para obter o saldo quando há entidades adicionais
	//--------------------------------------------------------------
	If  __lEnt09 .And. !Empty(CTQ->CTQ_E09ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI, CTQ->CTQ_E06ORI, CTQ->CTQ_E07ORI, CTQ->CTQ_E08ORI, CTQ->CTQ_E09ORI}
	ElseIf  __lEnt08 .And. !Empty(CTQ->CTQ_E08ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI, CTQ->CTQ_E06ORI, CTQ->CTQ_E07ORI, CTQ->CTQ_E08ORI}
	ElseIf  __lEnt07 .And. !Empty(CTQ->CTQ_E07ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI, CTQ->CTQ_E06ORI, CTQ->CTQ_E07ORI}
	ElseIf  __lEnt06 .And. !Empty(CTQ->CTQ_E06ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI, CTQ->CTQ_E06ORI}
	ElseIf  __lEnt05 .And. !Empty(CTQ->CTQ_E05ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI}
	EndIf

	//-------------------------------------------------------------
	// Caso tenha entidades adicionais utiliza a função CTBSldCubo
	//-------------------------------------------------------------
	If Len(aEnt) > 4

		If CTQ->CTQ_TIPO = "1" //Movimento Mês
			aSaldoAux := CtbSldCubo(aEnt ,aEnt ,dDataIni ,mv_par01 ,aCols[nX][1] ,mv_par10 , , ,.T.)

			aSaldos[nX][3] := aSaldoAux[1] - aSaldoAux[6]

		Else  //Saldo Acumulado
			aSaldos[nX][3] := CtbSldCubo(aEnt ,aEnt ,CToD("//") ,mv_par01 ,aCols[nX][1] ,mv_par10 , , ,.T.)[6]

		EndIf

	ElseIf ! Empty(CTQ->CTQ_CTORI)

		If ! Empty(CTQ->CTQ_CLORI)

			// Saldo da conta/centro de custo/Item/Classe de Valor
			If CTQ->CTQ_TIPO = "1" //Movimento Mês
				aSaldos[nX][3] := MovClass(CTQ->CTQ_CTORI ,CTQ->CTQ_CCORI ,CTQ->CTQ_ITORI ,CTQ->CTQ_CLORI ,dDataIni ,mv_par01 ,aCols[nX][1] ,mv_par10 , 3)
			Else //Saldo Acumulado
				aSaldos[nX][3] := SaldoCTI(CTQ->CTQ_CTORI ,CTQ->CTQ_CCORI ,CTQ->CTQ_ITORI ,CTQ->CTQ_CLORI ,mv_par01 ,aCols[nX][1] ,mv_par10)[1]
			Endif

		ElseIf ! Empty(CTQ->CTQ_ITORI)

			// Saldo da conta/centro de custo/Item
			If CTQ->CTQ_TIPO = "1"
				aSaldos[nX][3] := MovItem(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,CTQ->CTQ_ITORI,dDataIni,mv_par01,aCols[nX][1],mv_par10, 3)
			Else
				aSaldos[nX][3] := SaldoCT4(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,CTQ->CTQ_ITORI,mv_par01,aCols[nX][1],mv_par10)[1]
			Endif

		ElseIf ! Empty(CTQ->CTQ_CCORI)

			// Saldo da conta/centro de custo
			If CTQ->CTQ_TIPO = "1"
				aSaldos[nX][3] := MovCusto(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,dDataIni,mv_par01,aCols[nX][1],mv_par10, 3)
			Else
				aSaldos[nX][3] := SaldoCT3(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,mv_par01,aCols[nX][1],mv_par10)[1]
			Endif

		Else
			// Saldo da conta
			If CTQ->CTQ_TIPO = "1"
				aSaldos[nX][3] := MovConta(CTQ->CTQ_CTORI,dDataIni,mv_par01,aCols[nX][1],mv_par10, 3)
			Else
				aSaldos[nX][3] := SaldoCT7(CTQ->CTQ_CTORI,mv_par01,aCols[nX][1],mv_par10)[1]
			Endif
		EndIf

	ElseIf 	!Empty(CTQ->CTQ_CLORI) // classe de valor
		aSaldos[nX][3] := MovClass(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,CTQ->CTQ_ITORI,CTQ->CTQ_CLORI,dDataIni,mv_par01,aCols[nX][1],mv_par10, If(CTQ->CTQ_TIPO = "1", 3, 4))
		
	ElseIf	!Empty(CTQ->CTQ_ITORI) // Item
		aSaldos[nX][3] := MovItem(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,CTQ->CTQ_ITORI,dDataIni,mv_par01,aCols[nX][1],mv_par10,If(CTQ->CTQ_TIPO = "1", 3, 4))
		
	ElseIf 	!Empty(CTQ->CTQ_CCORI) // Centro de custo
		aSaldos[nX][3] := MovCusto(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,dDataIni,mv_par01,aCols[nX][1],mv_par10, If(CTQ->CTQ_TIPO = "1", 3, 4))

	Endif

	aSaldos[nX][3] := Round( NoRound( aSaldos[nX][3] * (CTQ->CTQ_PERBAS / 100) , 4 ) , 4)

	lSaldo := aSaldos[nX][3] # 0 .Or. lSaldo

	aCols[nX][Len(aCols[nX])] := 0

	aCols[nX][2] := If(nX = 1, "1", "4")

	// Se for moeda especifica, simplesmente saio do loop
	If MV_PAR08 == 2
		EXIT
	Endif
Next

aCols[1][2]	:= If( aSaldos[1][3] = 0, "5", "1")

RestArea(aSaveArea)
cFilant :=cFilback

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct280TCSP ºAutor  ³Renato F. Campos    º Data ³  08/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ct280TCSP( cProcName , cRatIni , cRatFim, dDataIni , lMudaHist , cHistorico )
Local aResult
Local lRet := .T.

DEFAULT cProcName 	:= "CTB068"
DEFAULT cCtq_Rateio := ''
DEFAULT dDataIni 	:= dDataBase
DEFAULT cHistorico 	:= ''

aResult := TCSPExec( xProcedures(cProcName), IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),  cRatIni , cRatFim ,  mv_par02,;
mv_par03,   mv_par04,  mv_par09,  Iif(mv_par08 = 2, '1', '0'), dtos(dDataIni),;
dtos(mv_par01),  mv_par10,  Iif(lMudaHist, '1', '0'), cHistorico, mv_par05,;
IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ), SM0->M0_CODIGO )

If Empty(aResult)
	lRet := .F.
	ProcLogAtu( "ERRO",STR0015,STR0016 ) // "Stored Procedure" ## "Erro na chamada do processo Rateio Off-Line"
	
	If !Isblind()
		MsgAlert( STR0016,STR0015+" "+cProcName )//'Erro na chamada do processo Rateio Off-Line ' ## "Stored Procedure "
	Else
		CONOUT( STR0016+ " " + STR0015 + ' ' + cProcName  )
	EndIf
	
Elseif aResult[1] == "01" .or. aResult[1] == "1"
	lRet := .T.
	ProcLogAtu( "MENSAGEM",STR0015, STR0001 + " OK" ) // 'Rateio Offline OK'
	
	If !Isblind()
		MsgInfo( STR0001 + " OK" ) //'Rateio Offline OK'
	EndIf
Else
	lRet := .F.
	ProcLogAtu( "ERRO",STR0015,STR0017 )
	
	If !Isblind()
		MsgAlert( STR0017,STR0015+cProcName ) // 'Rateio Off-Line com erro '
	Else
		CONOUT( STR0017 + ' - '+ STR0015 + " " + cProcName  )
	EndIf
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct280RtOk ºAutor  ³Renato F. Campos    º Data ³  08/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação das entidades do rateio somente para topconn      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CT280RTOK(cRatIni, cRatFim)
Local lRet	  := .T.
Local cAliasE := "TMPENT"

DEFAULT cRatIni := ""
DEFAULT cRatFim := Replicate( "Z" , len( CTQ->CTQ_RATEIO ) )

// verifica se o parametro de validação das entidades está habilitado.
// lembrando que a execução dessa rotina é opcional
IF ! GetNewPar( "MV_VLENTRT" , .F. )
	ProcLogAtu( "MENSAGEM","MV_VLENTRT" , STR0019 ) // "Parametro de verificação das entidades está desligado!"
	RETURN .T.
ENDIF

// rotina de retorno dos rateios bloqueados
lRet := GetRtBlqEnt( cAliasE , cRatIni , cRatFim )

IF lRet
	DbSelectArea( cAliasE )
	DbGoTop()
	
	WHILE (cAliasE)->( ! Eof() )
		ProcLogAtu( "MENSAGEM","CT280RTOK" , STR0001 + " " + (cAliasE)->CTQ_RATEIO + STR0020 ) // "Rateio Off-Line" ## " com entidade(s) bloqueada(s)."
		Conout( STR0001 + " " + (cAliasE)->CTQ_RATEIO + STR0020 ) // "Rateio Off-Line" ## " com entidade(s) bloqueada(s)."
		
		(cAliasE)->( DbSkip() )
	ENDDO
	
	// verifica se o parametro de bloqueio do rateio está ativo caso encontre algum rateio com entidade bloqueada
	IF lRet .And. GetNewPar( "MV_BLQRAT" , .F. )
		lRet := Ct280BlqRt( cAliasE )
	ENDIF
ENDIF

// fecha o cursor utilizado pela rotina
If ( Select ( cAliasE ) <> 0 )
	dbSelectArea ( cAliasE )
	dbCloseArea ()
Endif

RETURN lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetRtBlqEntºAutor  ³Renato F. Campos   º Data ³  08/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna um cursor com os rateios bloqueados                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION GetRtBlqEnt( cAliasRT , cRatIni , cRatFim )
Local cQuery, cFrom, cWhere
Local lMSBLQL := .T.
Local lSTATUS := .T.
Local lret	  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RFC                                                       ³
//³	MONTAGEM DO WHERE                                         ³
//³                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// montagem do from padrão
cFrom  := " FROM " + RetSqlName( "CTQ" ) + " CTQ "

// montagem do where padrão
cWhere := " CTQ_FILIAL = '" + xFilial("CTQ") + "'"

IF ! Empty( cRatIni )
	cWhere += " AND CTQ_RATEIO >= '" + cRatIni + "'"
Endif

IF ! Empty( cRatFim )
	cWhere += " AND CTQ_RATEIO <= '" + cRatFim + "'"
Endif

IF lMSBLQL
	// somente rateios desbloqueados ou sem status de bloqueio
	cWhere += " AND CTQ_MSBLQL IN ( ' ','2' ) "
Endif

IF lSTATUS
	// somente rateios desbloqueados ou sem status de bloqueio
	cWhere += " AND CTQ_STATUS IN ( ' ','1' ) "
Endif

cWhere += " AND D_E_L_E_T_ = ' '"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RFC                                                       ³
//³	MONTAGEM DA QUERY PRINCIPAL                               ³
//³                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT CTQ_RATEIO FROM "
cQuery += " 		("

// Partidas
cQuery += " SELECT DISTINCT CTQ_RATEIO, CTQ_CTORI AS CONTA"

IF __lCusto
	cQuery += ", CTQ_CCORI AS CUSTO "
Endif
IF __lItem
	cQuery += ", CTQ_ITORI AS ITEM  "
Endif
IF __lClVL
	cQuery += ", CTQ_CLORI AS CLVL  "
Endif

cQuery += "   FROM " + RetSqlName( "CTQ" ) + " CTQ "
cQuery += "  WHERE " + cWhere

cQuery += " UNION "

// Contra-partidas
cQuery += " SELECT DISTINCT CTQ_RATEIO, CTQ_CTPAR AS CONTA"

IF __lCusto
	cQuery += ", CTQ_CCPAR AS CUSTO "
Endif
IF __lItem
	cQuery += ", CTQ_ITPAR AS ITEM  "
Endif
IF __lClVL
	cQuery += ", CTQ_CLPAR AS CLVL  "
Endif

cQuery += "   FROM " + RetSqlName( "CTQ" ) + " CTQ "
cQuery += "  WHERE " + cWhere

cQuery += " UNION "

// itens de contra partida
cQuery += " SELECT DISTINCT CTQ_RATEIO, CTQ_CTCPAR AS CONTA"

IF __lCusto
	cQuery += ", CTQ_CCCPAR AS CUSTO "
Endif
IF __lItem
	cQuery += ", CTQ_ITCPAR AS ITEM  "
Endif
IF __lClVL
	cQuery += ", CTQ_CLCPAR AS CLVL  "
Endif

cQuery += "   FROM " + RetSqlName( "CTQ" ) + " CTQ "
cQuery += "  WHERE " + cWhere

// alias para a tabela
cQuery += " 		) ENT "
cQuery += " WHERE ("

// filtro da conta
cQuery += " 		ENT.CONTA IN ( "
cQuery += "				SELECT CT1.CT1_CONTA	"
cQuery += "			 	  FROM " + RetSqlName( "CT1" ) + " CT1 "
cQuery += "			 	 WHERE CT1.CT1_FILIAL = '" + xFilial("CT1") + "' "
cQuery += "			 	   AND CT1.CT1_BLOQ = '1' "
cQuery += "			 	   AND CT1.D_E_L_E_T_ = ' '"
cQuery += " 	    	 )"

IF __lCusto
	cQuery += " 		OR"
	
	// filtro do custo
	cQuery += " 		ENT.CUSTO IN ( "
	cQuery += "				SELECT CTT.CTT_CUSTO	"
	cQuery += "			 	  FROM " + RetSqlName( "CTT" ) + " CTT "
	cQuery += "			 	 WHERE CTT.CTT_FILIAL = '" + xFilial("CTT") + "' "
	cQuery += "			 	   AND CTT.CTT_BLOQ = '1' "
	cQuery += "			 	   AND CTT.D_E_L_E_T_ = ' '"
	cQuery += " 	    	 )"
Endif

IF __lItem
	cQuery += " 		OR"
	
	// filtro do Item
	cQuery += " 		ENT.ITEM IN ( "
	cQuery += "				SELECT CTD.CTD_ITEM	"
	cQuery += "			 	  FROM " + RetSqlName( "CTD" ) + " CTD "
	cQuery += "			 	 WHERE CTD.CTD_FILIAL = '" + xFilial("CTD") + "' "
	cQuery += "			 	   AND CTD.CTD_BLOQ = '1' "
	cQuery += "			 	   AND CTD.D_E_L_E_T_ = ' '"
	cQuery += " 	    	 )"
Endif

IF __lClVL
	cQuery += " 		OR"
	
	// filtro do Classe de Valor
	cQuery += " 		ENT.CLVL IN ( "
	cQuery += "				SELECT CTH.CTH_CLVL	"
	cQuery += "			 	  FROM " + RetSqlName( "CTH" ) + " CTH "
	cQuery += "			 	 WHERE CTH.CTH_FILIAL = '" + xFilial("CTH") + "' "
	cQuery += "			 	   AND CTH.CTH_BLOQ = '1' "
	cQuery += "			 	   AND CTH.D_E_L_E_T_ = ' '"
	cQuery += " 	    	 )"
Endif

cQuery += "			)"
cQuery += " GROUP BY CTQ_RATEIO"

cQuery := ChangeQuery( cQuery )

If ( Select ( cAliasRT ) <> 0 )
	dbSelectArea ( cAliasRT )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRT,.T.,.F.)

If ( Select ( cAliasRT ) <= 0 )
	ProcLogAtu( "ERRO","GETRTBLQENT" , STR0024 ) // "Erro na criação do cursor das entidades bloqueadas."
	lRet := .F.
Endif

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct280BlqRtºAutor  ³Microsiga           º Data ³  08/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION Ct280BlqRt( cAliasE )
Local cFilCTQ 	:= xFilial( "CTQ" )
Local lRet		:= .T.
Local lMSBLQL 	:= .T.
Local lSTATUS 	:= .T.

IF !lMSBLQL .OR. !lSTATUS
	ProcLogAtu( "ERRO","CT280BLQRT", STR0021 + "," + STR0022 ) // "Erro na atualização dos campos de bloqueio" ## "campos não criados."
	RETURN .T.
ENDIF

dbSelectArea("CTQ")
dbSetOrder(1)

DbSelectArea( cAliasE )
DbGoTop()
WHILE (cAliasE)->( !Eof() )

	cQuery := "UPDATE "
	cQuery += RetSqlName( "CTQ" ) + " "
	cQuery += " SET   CTQ_MSBLQL = '1'"
	cQuery += "     , CTQ_STATUS = '3'"
	cQuery += " WHERE CTQ_FILIAL = '" + cFilCTQ + "' "
	cQuery += "   AND CTQ_RATEIO = '" + (cAliasE)->CTQ_RATEIO + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	
	IF TcSqlExec( cQuery ) <> 0
		UserException( STR0021 + RetSqlName("CTQ") + CRLF + STR0023 + CRLF + TCSqlError() ) //"Erro na atualização dos campos de bloqueio " ## "Processo Cancelado"
		ProcLogAtu( "ERRO","CT280BLQRT" , STR0021 + " " +  (cAliasE)->CTQ_RATEIO + " " + TCSqlError() )
		lRet := .F.
	ENDIF
	
	(cAliasE)->( DBSKIP() )

ENDDO

RETURN lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetAEntidadesºAutor  ³Totvs            º Data ³  02/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna um array com as novas entidades                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetAEntidades()
Local aArea		:= GetArea()
Local aAreaCT0	:= CT0->( GetArea() )
Local aReturn	:= {}

DbSelectArea( "CT0" )
CT0->( DbSetOrder( 1 ) )
CT0->( dbSeek(xFilial("CT0")) )
Do While CT0->CT0_FILIAL==xFilial("CT0") .And. !CT0->(Eof())
	// Desconsidera as 4 entidades do padrao
	If Val( CT0->CT0_ID ) > 4
		aAdd( aReturn, { 	CTQ->&("CTQ_E"+CT0->CT0_ID+"CP"),;
							CTQ->&("CTQ_E"+CT0->CT0_ID+"PAR"),;
							0,;
							0 } )
	EndIf
	
	CT0->( DbSkip() )
EndDo

RestArea( aAreaCT0 )
RestArea( aArea )

Return aReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtrHistLng  ³Totvs            º Data ³  13/05/15            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se será necessário o controle de linha pelo         º±±
±±º          ³ tamanho do histórico.                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtrHistLng( cHist , nTamHisCT2 )
Local lCtrlLinha := .F.

//Efetua as mesma verificações da função CtbQLinHis
cHist := StrTran( cHist , Chr(13) , ' ' )
cHist := StrTran( cHist , Chr(10) , ' ' )

//Só ocorre erro quando o histórico é longo o suficiente para gerar uma segunda linha de complemento
If mlCount( cHist , nTamHisCT2 ) > 2
	lCtrlLinha := .T.
EndIf

Return lCtrlLinha

//-------------------------------------------------------------------
/*/{Protheus.doc} ScheDef()

Definição de Static Function SchedDef para o novo Schedule

@author TOTVS
@since 03/06/2021
@version MP12
/*/
//-------------------------------------------------------------------

Static Function SchedDef()

Local aParam := {}

aParam := { "P",;            // Tipo R para relatório P para processo
			"CTB280",;       // Pergunte do relatório, caso não use, passar ParamDef
			,;               // Alias     
			,;               // Array de ordens
			STR0001 }        // Título 


Return aParam
