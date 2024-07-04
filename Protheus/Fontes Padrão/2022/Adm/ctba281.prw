#INCLUDE "ctba281.ch"
#Include "PROTHEUS.Ch"
#Include "FWLIBVERSION.CH"

#Define CODIGOMOEDA 1
#Define SALDOATUA   1
#Define SALDOS      2


// 17/08/2009 -- Filial com mais de 2 caracteres

STATIC MAX_LINHA

STATIC __lCusto
STATIC __lItem
STATIC __lClVL

STATIC _lCpoEnt05 //Entidade 05
STATIC _lCpoEnt06 //Entidade 06
STATIC _lCpoEnt07 //Entidade 07
STATIC _lCpoEnt08 //Entidade 08
STATIC _lCpoEnt09 //Entidade 09

STATIC __lCT281Skip := EXISTBLOCK("CT281SKIP")
STATIC __lCT281Loop := EXISTBLOCK("CT281LOOP")
Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6" //Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ctba281  ³ Autor ³ Marcos S. Lobo        ³ Data ³ 04.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Este programa calcula os rateios Off-Line cadastrados      ³±±
±±³          ³ tomando por base a entidade do lançamento se estiver       ³±±
±±³          ³ em branco no rateio. (Rateio por combinacoes)	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ctba281(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ctba281(lAutomato)

Local nOpc

Private aSays    := {}
Private aButtons := {}
Private cCadastro := STR0001 //"Rateios Off-Line"

Default lAutomato := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros        ³
//³ mv_par01 // Data Inicial	                ³
//³ mv_par02 // Data Final			            ³
//³ mv_par03 // Numero do Lote			      	³
//³ mv_par04 // Numero do SubLote		        ³
//³ mv_par05 // Numero do Documento             ³
//³ mv_par06 // Cod. Historico Padrao           ³
//³ mv_par07 // Do Rateio 		        		|
//³ mv_par08 // Ate o Rateio               		³
//³ mv_par09 // Moedas? Todas / Especifica      ³
//³ mv_par10 // Qual Moeda?                  	³
//³ mv_par11 // Tipo de Saldo 				    ³
//³ mv_par12 // Conta Origem Inicial		    ³
//³ mv_par13 // Conta Origem Final 			    ³
//³ mv_par14 // C.Custo Origem Inicial		    ³
//³ mv_par15 // C.Custo Origem Final 			³
//³ mv_par16 // Item Origem Inicial		    	³
//³ mv_par17 // Item Origem Final 			    ³
//³ mv_par18 // Cl.Valor Origem Inicial		    ³
//³ mv_par19 // Cl.Valor Origem Final 			³
//³ mv_par20 // Reprocessa Antes/Entre/Final ?  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("CTB281",.F.)

If !lAutomato
	AADD(aSays,STR0002 ) //"Este programa tem o objetivo de efetuar os lan‡amentos referentes aos"
	AADD(aSays,STR0003 ) //"rateios off-line pre-cadastrados. Podera ser utilizado para ratear as"
	AADD(aSays,STR0004) //"despesas dos centros de custos improdutivos nos produtivos."
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o log de processamento                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogIni( aButtons )
	
	AADD(aButtons, { 5,.T.,{|| Pergunte("CTB281",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpc := 1, If( ConaOk(), FechaBatch(), nOpc:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons ,,,430)
Else
	nOpc := 1
EndIf
	
IF nOpc == 1                                                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")
	
	If MAX_LINHA = Nil
		MAX_LINHA := GetMv("MV_NUMMAN")
	Endif

	If !CTBSerialI("CTBPROC","OFF")
		Return
	Endif
	
	Processa({|lEnd| CTB281Proc(lAutomato)},cCadastro)

	CTBSerialF("CTBPROC","OFF")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")
Endif
	
Return
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTB281Proc³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Este programa calcula os rateios Off-Line cadastrados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB281Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ctba281                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB281Proc(lAutomato)
	
Local lRet 			:= .T.

Local aFormat 		:= {}
Local aSaldos		:= {}

Local aUSORI		:= {}	/// ARRAY INDICANDO O USO DAS ENTIDADES.
Local lRateou 		:= .F.
Local nX			:= 0

Local cFilCTQ := xFilial("CTQ")
Local aJaRatCTH := {}					//// CONTA,CUSTO,ITEM,CLVL,VALOR JA RATEADOS
Local aJaRatCTD := {}					//// CONTA,CUSTO,ITEM,VALOR JA RATEADOS
Local aJaRatCTT := {}					//// CONTA,CUSTO,VALOR JA RATEADOS
Local aJaRatCT1 := {}					//// CONTA,VALOR JA RATEADOS

Local nROriCTQ			:= 0			//// POSICAO (RECNO) DO REGISTRO ORIGEM NO RATEIO
Local nNxtRCTQ			:= 0			//// POSICAO (RECNO) DO PROXIMO RATEIO A PROCESSAR (DEPOIS DO CTQ2ARRAY())

Local lReprocA			:= .T.
Local lReprocE			:= .T.
Local lReprocF			:= .T.

Local l1StRat := .T.

Local lMSBLQL	:= IIF( CTQ->( ColumnPos( "CTQ_MSBLQL" )) > 0,.T.,.F.)
Local lSTATUS 	:= IIF( CTQ->( ColumnPos( "CTQ_STATUS" )) > 0,.T.,.F.)    
Local aEntAdPar	:= {}
Local aEntAdOri	:= {}

//Variavel lFirst criada para verificar se eh a primeira vez que esta incluindo o
//lancam. contabil. Se for a primeira vez (.T.),ira trazer 001 na linha. Se nao for
//a primeira vez e for para repetir o lancamento anterior, ira atualizar a linha
Private lFirst 		:= .T.
Private cLinha 		:= StrZero( 1, Len(CT2->CT2_LINHA) ) //"001"
Private nLinha 		:= 1
Private cSeqLan 	:= StrZero( 0, Len(CT2->CT2_SEQLAN) )  //"000"
Private cDoc
Private CTF_LOCK	:= 0
Private cHistCTQ 	:= ""
Private bHistCTQ

Private dDataIni	:= mv_par01
Private aRateio := {}
Private	lAtSldBase	:= Iif(SuperGetMv("MV_ATUSAL")== "S",.T.,.F.)

PRIVATE aCols		:= {} // Utilizada na conversao das moedas
Private dDataLanc   := mv_par01 // Utilizada na funcao CRIACONV() em CTBA101.PRW

Default lAutomato := .F.

// Sub-Lote somente eh informado se estiver em branco
mv_par04 := If(Empty(SuperGetMV("MV_SUBLOTE")), mv_par04, SuperGetMV("MV_SUBLOTE"))

If Empty(mv_par13)		//// SE A CONTA ORIGEM FINAL NAO FOI INFORMADA
	mv_par13 := Replicate("Z",len(mv_par13))		/// PREENCHE COM "ZZZ"
Endif
If Empty(mv_par15)		//// SE O C.CUSTO ORIGEM FINAL NAO FOI INFORMADA
	mv_par15 := Replicate("Z",len(mv_par15))		/// PREENCHE COM "ZZZ"
Endif
If Empty(mv_par17)		//// SE O IT.CONTABIL ORIGEM FINAL NAO FOI INFORMADO
	mv_par17 := Replicate("Z",len(mv_par17))		/// PREENCHE COM "ZZZ"
Endif
If Empty(mv_par19)		//// SE A CL.VLR. ORIGEM FINAL NAO FOI INFORMADA
	mv_par19 := Replicate("Z",len(mv_par19))		/// PREENCHE COM "ZZZ"
Endif
If Empty(mv_par20)
	mv_par20 := "111"
EndIf

lReprocA			:= If(Substr(mv_par20,1,1) $ "1",.T.,.F.)
lReprocE			:= If(Substr(mv_par20,2,1) $ "1",.T.,.F.)
lReprocF			:= If(Substr(mv_par20,3,1) $ "1",.T.,.F.)

// rotina de critica dos parametros do processamento do rateio e das entidades bloqueadas
// RFC - Retirada do procesamento principal afim de organizar a rotina
If ! CT281CRTOK()
	Return
Endif

If !lAutomato
	If !lReprocA .or. !lReprocE .or. !lReprocF			
		cTexto := STR0021+CRLF//"O reprocessamento esta configurado para não atualizar saldos:"
		If !lReprocA
			cTexto += STR0022+CRLF//"Antes de processar os rateios."
		EndIf
		If !lReprocE
			cTexto += STR0023+CRLF//"Entre rateios."
		EndIf
		If !lReprocF
			cTexto += STR0024+CRLF//"Apos o Final dos rateios."
		EndIf
		cTexto += CRLF+STR0025//"Deseja processar mesmo assim ?"
	    If MsgYesNo(cTexto,STR0026)//"ATENÇÃO - Atualização de saldos por reprocessamento !"
	    	lRet := .T.
	    Else
	    	lRet := .F.
	    EndIf
	EndIf
EndIf


If lRet // Parametros validos, posiciona o CT8 (Historico padrao)
	dbSelectArea("CT8")
	dbSetOrder(1)
	If dbSeek(xFilial("CT8")+mv_par06)
		cHistCTQ := ""
		If CT8->CT8_IDENT == 'C'
			cHistCTQ := CT8->CT8_DESC
			// Bloco para retornar a conta origem no historico
			bHistCTQ := {||Alltrim(cHistCTQ)+"-"+CTQ->CTQ_CTORI}
		Else
			aFormat := {}
			While !Eof() .And. CT8->CT8_HIST == mv_par06 .And. CT8->CT8_IDENT == 'I'
				Aadd(aFormat,CT8->CT8_DESC)
				dbSkip()
			Enddo
			cHistCTQ := MSHGetText(aFormat)
			bHistCTQ := {||AllTrim(cHistCTQ)}
		Endif
	Endif
Endif   

If __lCusto = Nil
	__lCusto 	:= CtbMovSaldo("CTT")
Endif
If __lItem = Nil
	__lItem	  	:= CtbMovSaldo("CTD")
Endif                                       
If __lCLVL = Nil
	__lCLVL	  	:= CtbMovSaldo("CTH")
Endif
If _lCpoEnt05 = Nil
	_lCpoEnt05	:= CtbMovSaldo("CT0",,'05')
Endif
If _lCpoEnt06 = Nil
	_lCpoEnt06	:= CtbMovSaldo("CT0",,'06')
Endif
If _lCpoEnt07 = Nil
	_lCpoEnt07	:= CtbMovSaldo("CT0",,'07')
Endif
If _lCpoEnt08 = Nil
	_lCpoEnt08	:= CtbMovSaldo("CT0",,'08')
Endif
If _lCpoEnt09 = Nil
	_lCpoEnt09	:= CtbMovSaldo("CT0",,'09')
Endif

If lRet
	CriaConv(.T.) // Para criar aCols que sera utilizada na conversao de moedas
	DbSelectArea("CTO")
	dbSeek(xFilial()+"01",.T.)
	If Len(aCols) <= 0 .or. Empty(aCols[1][1])			/// SE TIVER SOMENTE UMA MOEDA RETORNA ARRAY[1][5] COM A 1ª POSICAO EM BRANCO
		aCols := {}										/// ENTAO ZERA O ARRAY
		aAdd(aCols , { "01", " ", 0.00, "2", .F. })		/// ENTAO ADICIONA A MOEDA 01 PARA O "FOR-NEXT" DE MOEDAS
	Endif
	aSort(aCols,,,{|X,Y| x[1] < y[1] } )
	
	For nX := 1 To Len(aCols)
		Aadd(aCols[nX], 0)
	Next
	aSaldos	:= aClone(aCols)
	
	Private cSpCT1	:= SPACE(LEN(CT1->CT1_CONTA))
	Private cSpCTT	:= SPACE(LEN(CTT->CTT_CUSTO))
	Private cSpCTD	:= SPACE(LEN(CTD->CTD_ITEM))
	Private cSpCTH	:= SPACE(LEN(CTH->CTH_CLVL))
	
	ProcRegua(2)
	DbSelectarea("CTQ")
	MsSeek(cFilCTQ+mv_par07		,.T.)
	
	// Processa os rateios selecionados
	l1StRat := .T.
	While CTQ->(!Eof()) .And. CTQ->CTQ_FILIAL == cFilCTQ .And. CTQ->CTQ_RATEIO <= mv_par08

		DbSelectArea("CTQ")
		cCtq_Rateio	:= CTQ->CTQ_RATEIO
		
		If !(Isblind())
			If (l1StRat .and. lReprocA) .or. (!l1StRat .and. lReprocE)
				oProcess := MsNewProcess():New({|lEnd| CTBA190(.T.,dDataIni,mv_par02,xFilial("CT2"),xFilial("CT2"),mv_par11,mv_par09 == 2,mv_par10)		},"","",.F.)
				oProcess:Activate()
				l1StRat := .F.
			EndIf
		Else
			CTBA190(.T.,dDataIni,mv_par02,xFilial("CT2"),xFilial("CT2"),mv_par11,mv_par09 == 2,mv_par10)
			l1StRat := .F.
		Endif

		lRateou := .F.
		
		aUSORI	:= {{.T.,!Empty(CTQ->CTQ_CTORI)},;
					{__lCusto,!Empty(CTQ->CTQ_CCORI)},;
					{__lItem,!Empty(CTQ->CTQ_ITORI)},; // Movimento - Origem
					{__lClvl,!Empty(CTQ->CTQ_CLORI)},;
					{_lCpoEnt05,Iif(_lCpoEnt05,!Empty(CTQ->CTQ_E05ORI),.f.)},;
					{_lCpoEnt06,Iif(_lCpoEnt06,!Empty(CTQ->CTQ_E06ORI),.f.)},;
					{_lCpoEnt07,Iif(_lCpoEnt07,!Empty(CTQ->CTQ_E07ORI),.f.)},;
					{_lCpoEnt08,Iif(_lCpoEnt08,!Empty(CTQ->CTQ_E08ORI),.f.)},;
					{_lCpoEnt09,Iif(_lCpoEnt09,!Empty(CTQ->CTQ_E09ORI),.f.)} }
				
		lCt1Ori := aUsori[1,2]
		lCttOri := aUsori[2,2]
		lCtdOri := aUsori[3,2]
		lCthOri := aUsori[4,2]

		IncProc(STR0010+CTQ->CTQ_RATEIO)	//"Carregando Rateio..."

		nROriCTQ	:= CTQ->(Recno())			  /// REGISTRO COM A ORIGEM PARA O RATEIO
		aRateio 	:= Ctq2Array(CTQ->CTQ_RATEIO)/// CARREGA O ARRAY COM O RATEIO CADASTRADO.
		nNxtRCTQ	:= CTQ->(Recno())			  /// PROXIMO RATEIO A SER PROCESSADO
		
		CTQ->(dbGoTo(nROriCTQ))

		If __lCT281Skip
			If ! Execblock("CT281SKIP",.F.,.F.)
				CTQ->(dbGoTo(nNxtRCTQ))
				Loop
			Endif
		EndIf

		// restrição de bloqueio ou pelo status
		If lMSBLQL .Or. lSTATUS
			IF ( lMSBLQL .AND. CTQ->CTQ_MSBLQL == '1' ) .Or. ( lSTATUS .AND. CTQ->CTQ_STATUS <> '1' )
				CTQ->(dbGoTo(nNxtRCTQ))
				Loop
			ENDIF
		Endif

		If Len(aRateio) > 0
			
			aEntAdPar := {}
			
			//// TRATA O PREENCHIMENTO DA  CONTRA-PARTIDA (USA O MESMO DA ORIGEM SE ESTIVER EM BRANCO)
			
			cCT1PAR := CTQ->CTQ_CTPAR
			cCTTPAR := CTQ->CTQ_CCPAR
			cCTDPAR := CTQ->CTQ_ITPAR
			cCTHPAR := CTQ->CTQ_CLPAR		 
			
			Aadd(aEntAdPar, If(_lCpoEnt05,CTQ->CTQ_E05PAR,"")) //Entidade 05
			Aadd(aEntAdPar, If(_lCpoEnt06,CTQ->CTQ_E06PAR,"")) //Entidade 06
			Aadd(aEntAdPar, If(_lCpoEnt07,CTQ->CTQ_E07PAR,"")) //Entidade 07
			Aadd(aEntAdPar, If(_lCpoEnt08,CTQ->CTQ_E08PAR,"")) //Entidade 08
			Aadd(aEntAdPar, If(_lCpoEnt09,CTQ->CTQ_E09PAR,"")) //Entidade 09

			ProcRegua(CTQ->(RecCount()))
			IncProc(STR0011)//"Analisando combinacoes de entidades..."
			
			cQry := ""
			
			cQry := CTB281Qry(aUSORI)
				
			cQry := ChangeQuery(cQry)
				
			If Select("TRBCJ") > 0
				dbSelectArea("TRBCJ")
				TRBCJ->(dbCloseArea())
			Endif
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBCJ",.T.,.F.)
			dbSelectArea("TRBCJ")
			TRBCJ->(dbGoTop())
			
			aJaRatCTH := {}					//// CONTA,CUSTO,ITEM,CLVL,VALOR JA RATEADOS
			aJaRatCTD := {}					//// CONTA,CUSTO,ITEM,VALOR JA RATEADOS
			aJaRatCTT := {}					//// CONTA,CUSTO,VALOR JA RATEADOS
			aJaRatCT1 := {}					//// CONTA,VALOR JA RATEADOS


			While !TRBCJ->(Eof())

				If __lCT281Loop
					If !ExecBlock("CT281LOOP",.F.,.F.)
						TRBCJ->(DBSkip())
						Loop
					Endif
				Endif
				
				IncProc(STR0005+ALLTRIM(TRBCJ->CONTA)+"/"+ALLTRIM(TRBCJ->CUSTO)+"/"+ALLTRIM(TRBCJ->ITEM)+"/"+ALLTRIM(TRBCJ->CLVL)) //"Combinação:"

				If ( aUSORI[9,2] .or. aUSORI[8,2] .or. aUSORI[7,2] .or.;
						aUSORI[6,2] .or.aUSORI[5,2] )

					If ( aUSORI[9,1] .And. aUSORI[9,2] .And. !Empty(TRBCJ->ENT09) )
						aEntAdOri := {TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL, TRBCJ->ENT05, TRBCJ->ENT06, CTQ->CTQ_E07ORI, TRBCJ->ENT08, TRBCJ->ENT09}
					ElseIf ( aUSORI[8,1] .And. aUSORI[8,2] .And. !Empty(TRBCJ->ENT08) )
						aEntAdOri := {TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL, TRBCJ->ENT05, TRBCJ->ENT06, TRBCJ->ENT07, TRBCJ->ENT08}
					ElseIf ( aUSORI[7,1] .And. aUSORI[7,2] .And. !Empty(TRBCJ->ENT07) )
						aEntAdOri := {TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL, TRBCJ->ENT05, TRBCJ->ENT06, TRBCJ->ENT07}
					ElseIf ( aUSORI[6,1] .And. aUSORI[6,2] .And. !Empty(TRBCJ->ENT06) )
						aEntAdOri := {TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL, TRBCJ->ENT05, TRBCJ->ENT06}
					ElseIf ( aUSORI[5,1] .And. aUSORI[5,2] .And. !Empty(TRBCJ->ENT05) )
						aEntAdOri := {TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL, TRBCJ->ENT05}
					EndIf				

					Rat281EnAd(aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,@aJaRatCTH,@aJaRatCTD,@aJaRatCTT,@aJaRatCT1,aEntAdOri,aEntAdPar)				
				
				ElseIf __lClVl .and. !Empty(TRBCJ->CLVL)
			
					Rat281Class(TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,@aJaRatCTH,aEntAdPar)
				
				ElseIf __lItem .and. !Empty(TRBCJ->ITEM)
			
					Rat281Item(TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,@aJaRatCTH,@aJaRatCTD,aEntAdPar)
				
				ElseIf __lCusto .and. !Empty(TRBCJ->CUSTO)
			
					Rat281Custo(TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,@aJaRatCTH,@aJaRatCTD,@aJaRatCTT,aEntAdPar)
					
				ElseIf !Empty(TRBCJ->CONTA) .and. Empty(TRBCJ->CUSTO) .and. Empty(TRBCJ->ITEM) .and. Empty(TRBCJ->CLVL)
			
					Rat281Conta(TRBCJ->CONTA,TRBCJ->CUSTO,TRBCJ->ITEM,TRBCJ->CLVL,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,@aJaRatCTH,@aJaRatCTD,@aJaRatCTT,@aJaRatCT1,aEntAdPar)
			
				Endif
								
				TRBCJ->(dbSkip())
			EndDo
		Endif        	/// FECHA IF DO O TAMANHO DO RATEIO MAIOR QUE ZERO
		
		IncProc(STR0012+cCtq_Rateio+" "+Time())//"Localizando proximo rateio..."
		CTQ->(dbGoTo(nNxtRCTQ))
	Enddo
	
	If CTF_LOCK > 0					/// LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL
		dbSelectArea("CTF")
		dbGoTo(CTF_LOCK)
		CtbDestrava(mv_par02,mv_par03,mv_par04,cDoc,@CTF_LOCK)
	Endif
	
	/// ATUALIZA OS SALDOS AO FINAL DO PROCESSAMENTO
	If !(Isblind())//para nao quebrar por conta de telas, da automação do robo
		If lReprocF
			oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dDataIni,mv_par02,xFilial("CT2"),xFilial("CT2"),mv_par11,mv_par09 == 2,mv_par10)		},"","",.F.)
			oProcess:Activate()
		EndIf
	Else
		CTBA190(.T.,dDataIni,mv_par02,xFilial("CT2"),xFilial("CT2"),mv_par11,mv_par09 == 2,mv_par10)
	Endif
Endif

If lRet .And. __lMetric

	If lReprocA //Metrica de quantidade de usos antes do reprocessamento
		CTB281Metrics("01" /*cEvent*/,/*nStart*/, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
	Endif
	
	If lReprocE //Metrica de quantidade de uso entre o reprocessamento
		CTB281Metrics("01" /*cEvent*/,/*nStart*/, "002" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
	Endif
	
	If lReprocF //Metrica de quantidade de usos ao final do reprocessamento
		CTB281Metrics("01" /*cEvent*/,/*nStart*/, "003" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
	Endif

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA281   ºAutor  ³Microsiga           º Data ³  12/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Rat281Class(cCt1Ori,cCttOri,cCtdOri,cCthOri,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aJaRatCTH,aEntAdPar)

// Saldo da conta/centro de custo/Item/Classe de Valor
Local cMoeda := mv_par10
Local lSaldo := .F.
Local nX	 := 0
Local nJaRat
Local aVlrs	 	:= {}
Local aVlrJaRat := {}
Local nJaRatCTH	:= 0
Local nVlrs

Default aEntAdPar	:= {}

For nVlrs := 1 to Len(aSaldos)
	aAdd(aVlrs,0)
	aAdd(aVlrJaRat,0)
Next

For nJaRat := 1 to Len(aJaRatCTH)
	If aJaRatCTH[nJaRat,1] == cCT1Ori .and. aJaRatCTH[nJaRat,2] == cCTTOri .and. aJaRatCTH[nJaRat,3] == cCTDOri .and. aJaRatCTH[nJaRat,4] == cCTHOri
		For nX := 1 to Len(aJaRatCTH[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTH[nJaRat,5,nX]
		Next
		nJaRatCTH := nJaRat
	Endif
Next

For nX := 1 to Len(aSaldos)
	If mv_par09 == 2						/// SE O PARAMETRO DE MOEDAS ESTIVER PARA ESPECIFICA (2)
		nX := val(mv_par10)
	Else
		cMoeda := StrZero(nX,2)
	Endif
	If CTQ->CTQ_TIPO = "1"
		aSaldos[nX][3] := MovClass(cCt1Ori,cCttOri,cCtdOri,cCthOri,dDataIni,mv_par02,cMoeda,mv_par11, 3)
	Else
		aSaldos[nX][3] := SaldoCTI(cCt1Ori,cCttOri,cCtdOri,cCthOri,mv_par02,cMoeda,mv_par11)[1]
	Endif
	
	aSaldos[nX][3] := Round(NoRound(aSaldos[nX][3] * (CTQ->CTQ_PERBAS / 100),3),2)
	
	If aVlrJaRat[nX] <> 0						 /// SE HA DIFERENCA DE SALDO NAS ENTIDADES ANTERIORES
		If aVlrJaRat[nX] < 0 .And. aSaldos[nX][3] < 0   	/// VERIFICA SE OS VALORES SAO NEGATIVOS
			If Abs(aVlrJaRat[nX]) >= Abs(aSaldos[nX][3])
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		Else
			If aVlrJaRat[nX] >= aSaldos[nX][3]
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		EndIf
	Endif
	
	If aSaldos[nX][3] <> 0
		
		aVlrs[nX]		:= aSaldos[nX,3]
		lSaldo := .T.
		aCols[nX][Len(aCols[nX])] := 0
		aCols[nX][2] := If(cMoeda == "01", "1", "4")
	Else
		aCols[nX][2] := If(cMoeda == "01", "4", "5")
	Endif
	
	If mv_par09 == 2						/// SE FOR MOEDA ESPECIFICA EXECUTA APENAS UMA VEZ
		Exit
	Endif
Next

If lSaldo
	If GetNewPar( "MV_CT281CP" , .T. ) // verifica se utilizara a contra partida no lançamento
		If Empty(cCT1PAR) .and. !Empty(cCT1ORI)
			cCT1PAR := cCT1ORI
		Endif
		If Empty(cCTTPAR) .and. !Empty(cCTTORI)
			cCTTPAR := cCTTORI
		Endif
		If Empty(cCTDPAR) .and. !Empty(cCTDORI)
			cCTDPAR := cCTDORI
		Endif
		If Empty(cCTHPAR) .and. !Empty(cCTHORI)
			cCTHPAR := cCTHORI
		Endif
	Endif
	
	If nJaRatCTH > 0
		For nX := 1 To Len(aJaRatCTH[nJaRatCTH,5])
			aJaRatCTH[nJaRatCTH,5,nX] += aVlrs[nX]
		Next
	Else
		aAdd(aJaRatCTH,{cCt1Ori,cCttOri,cCtdOri,cCthOri,aVlrs})
	Endif
	
	GrvRatCtq(cCt1Ori,cCttOri,cCtdOri,cCthOri,cMoeda,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aEntAdPar)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA281   ºAutor  ³Microsiga           º Data ³  12/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Rat281Item(cCt1Ori,cCttOri,cCtdOri,cCThOri,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aJaRatCTH,aJaRatCTD,aEntAdPar)

Local cMoeda 	:= mv_par10
Local lSaldo 	:= .F.
Local nX	 	:= 0
Local aVlrs	 := {}
Local aVlrJaRat := {}
Local nJaRatCTD	:= 0
Local nJaRat
Local nVlrs

Default aEntAdPar	:= {}

For nVlrs := 1 to Len(aSaldos)
	aAdd(aVlrs,0)
	aAdd(aVlrJaRat,0)
Next

For nJaRat := 1 to Len(aJaRatCTH)
	If aJaRatCTH[nJaRat,1] == cCT1Ori .and. aJaRatCTH[nJaRat,2] == cCTTOri .and. aJaRatCTH[nJaRat,3] == cCTDOri
		For nX := 1 to Len(aJaRatCTH[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTH[nJaRat,5,nX]
		Next
	Endif
Next
For nJaRat := 1 to Len(aJaRatCTD)
	If aJaRatCTD[nJaRat,1] == cCT1Ori .and. aJaRatCTD[nJaRat,2] == cCTTOri .and. aJaRatCTD[nJaRat,3] == cCTDOri
		For nX := 1 to Len(aJaRatCTD[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTD[nJaRat,5,nX]
		Next
		nJaRatCTD := nJaRat
	Endif
Next

For nX := 1 to Len(aSaldos)
	If mv_par09 == 2						/// SE O PARAMETRO DE MOEDAS ESTIVER PARA ESPECIFICA (2)
		nX := val(mv_par10)
	Else
		cMoeda := StrZero(nX,2)
	Endif
	
	If CTQ->CTQ_TIPO = "1"
		aSaldos[nX][3] := MovItem(cCt1Ori,cCttOri,cCtdOri,dDataIni,mv_par02,cMoeda,mv_par11, 3)
	Else
		aSaldos[nX][3] := SaldoCT4(cCt1Ori,cCttOri,cCtdOri,mv_par02,cMoeda,mv_par11)[1]
	Endif
	
	aSaldos[nX][3] := Round(NoRound(aSaldos[nX][3] * (CTQ->CTQ_PERBAS / 100),3),2)
	
	If aVlrJaRat[nX] <> 0						/// SE HA DIFERENCA DE SALDO DE NIVEL MAIS BAIXO (ENTIDADE ABAIXO)
		If aVlrJaRat[nX] < 0 .And. aSaldos[nX][3] < 0   	/// VERIFICA SE OS VALORES SÃO NEGATIVOS
			If Abs(aVlrJaRat[nX]) >= Abs(aSaldos[nX][3])
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		Else
			If aVlrJaRat[nX] >= aSaldos[nX][3]
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		EndIf
	Endif
	
	If aSaldos[nX][3] <> 0
		aVlrs[nX]		:= aSaldos[nX,3]
		lSaldo := .T.
		aCols[nX][Len(aCols[nX])] := 0
		aCols[nX][2] := If(cMoeda == "01", "1", "4")
	Else
		aCols[nX][2] := If(cMoeda == "01", "4", "5")
	Endif
	
	If mv_par09 == 2						/// SE FOR MOEDA ESPECIFICA EXECUTA APENAS UMA VEZ
		Exit
	Endif
Next

If lSaldo
	If GetNewPar( "MV_CT281CP" , .T. ) // verifica se utilizara a contra partida no lançamento
		If Empty(cCT1PAR) .and. !Empty(cCT1ORI)
			cCT1PAR := cCT1ORI
		Endif
		If Empty(cCTTPAR) .and. !Empty(cCTTORI)
			cCTTPAR := cCTTORI
		Endif
		If Empty(cCTDPAR) .and. !Empty(cCTDORI)
			cCTDPAR := cCTDORI
		Endif
		If Empty(cCTHPAR) .and. !Empty(cCTHORI)
			cCTHPAR := cCTHORI
		Endif
	
	Endif
	
	If nJaRatCTD > 0
		For nX := 1 To Len(aJaRatCTD[nJaRatCTD,5])
			aJaRatCTD[nJaRatCTD,5,nX] += aVlrs[nX]
		Next
	Else
		aAdd(aJaRatCTD,{cCt1Ori,cCttOri,cCtdOri,cCthOri,aVlrs})
	Endif
	
	GrvRatCtq(cCt1Ori,cCttOri,cCtdOri,cSpCTH,cMoeda,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aEntAdPar)

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA281   ºAutor  ³Microsiga           º Data ³  12/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Rat281Custo(cCt1Ori,cCttOri,cCtdOri,cCthOri,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aJaRatCTH,aJaRatCTD,aJaRatCTT,aEntAdPar)

Local cMoeda := mv_par10
Local lSaldo := .F.
Local nX	 := 0
Local aVlrs	 := {}
Local aVlrJaRat := {}
Local nJaRatCTT	:= 0
Local nVlrs
Local nJaRat

Default aEntAdPar	:= {}

For nVlrs := 1 to Len(aSaldos)
	aAdd(aVlrs,0)
	aAdd(aVlrJaRat,0)
Next

For nJaRat := 1 to Len(aJaRatCTH)
	If aJaRatCTH[nJaRat,1] == cCT1Ori .and. aJaRatCTH[nJaRat,2] == cCTTOri
		For nX := 1 to Len(aJaRatCTH[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTH[nJaRat,5,nX]
		Next
	Endif
Next
For nJaRat := 1 to Len(aJaRatCTD)
	If aJaRatCTD[nJaRat,1] == cCT1Ori .and. aJaRatCTD[nJaRat,2] == cCTTOri
		For nX := 1 to Len(aJaRatCTD[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTD[nJaRat,5,nX]
		Next
	Endif
Next
For nJaRat := 1 to Len(aJaRatCTT)
	If aJaRatCTT[nJaRat,1] == cCT1Ori .and. aJaRatCTT[nJaRat,2] == cCTTOri
		For nX := 1 to Len(aJaRatCTT[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTT[nJaRat,5,nX]
		Next
		nJaRatCTT := nJaRat
	Endif
Next

For nX := 1 to Len(aSaldos)
	If mv_par09 == 2						/// SE O PARAMETRO DE MOEDAS ESTIVER PARA ESPECIFICA (2)
		nX := val(mv_par10)
	Else
		cMoeda := StrZero(nX,2)
	Endif
	
	// Saldo da conta/centro de custo
	If CTQ->CTQ_TIPO = "1"
		aSaldos[nX][3]	:= MovCusto(cCt1Ori,cCttOri,dDataIni,mv_par02,cMoeda,mv_par11, 3)
	Else
		aSaldos[nX][3]	:= SaldoCT3(cCt1Ori,cCttOri,mv_par02,cMoeda,mv_par11)[1]
	Endif
	
	aSaldos[nX][3] := Round(NoRound(aSaldos[nX][3] * (CTQ->CTQ_PERBAS / 100),3),2)
	
	If aVlrJaRat[nX] <> 0						 /// SE HA DIFERENCA DE SALDO NAS ENTIDADES ANTERIORES
		If aVlrJaRat[nX] < 0 .And. aSaldos[nX][3] < 0   	/// VERIFICA SE OS VALORES SAO NEGATIVOS
			
			/* Trecho comentado para issue DSERCTR1-30130, em rateios onde o saldo da entidade 
			acima (item) utilizado no rateio é maior que o saldo total a ratear, não rateia corretamente
			pois esta zerando no trecho abaixo */

			//If Abs(aVlrJaRat[nX]) >= Abs(aSaldos[nX][3])
			//	aSaldos[nX][3] := 0
			//Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			//Endif
		Else
			If aVlrJaRat[nX] >= aSaldos[nX][3]
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		EndIf
	Endif
	
	If aSaldos[nX][3] <> 0
		aVlrs[nX]		:= aSaldos[nX,3]    			/// O VALOR RATEADO SERA O JA SUBTRAIDO DAS ENTIDADES ANTERIORES
		lSaldo := .T.
		aCols[nX][Len(aCols[nX])] := 0
		aCols[nX][2] := If(cMoeda == "01", "1", "4")
	Else
		aCols[nX][2] := If(cMoeda == "01", "4", "5")
	Endif
	
	If mv_par09 == 2						/// SE FOR MOEDA ESPECIFICA EXECUTA APENAS UMA VEZ
		Exit
	Endif
Next

If lSaldo
	If GetNewPar( "MV_CT281CP" , .T. ) // verifica se utilizara a contra partida no lançamento
		If Empty(cCT1PAR) .and. !Empty(cCT1ORI)
			cCT1PAR := cCT1ORI
		Endif
		If Empty(cCTTPAR) .and. !Empty(cCTTORI)
			cCTTPAR := cCTTORI
		Endif
		If Empty(cCTDPAR) .and. !Empty(cCTDORI)
			cCTDPAR := cCTDORI
		Endif
		If Empty(cCTHPAR) .and. !Empty(cCTHORI)
			cCTHPAR := cCTHORI
		Endif
		
	Endif
	
	If nJaRatCTT > 0
		For nX := 1 To Len(aJaRatCTT[nJaRatCTT,5])
			aJaRatCTT[nJaRatCTT,5,nX] += aVlrs[nX]
		Next
	Else
		aAdd(aJaRatCTT,{cCt1Ori,cCttOri,cCtdOri,cCthOri,aVlrs})
	Endif
	
	GrvRatCtq(cCt1Ori,cCttOri,cSpCTD,cSpCTH,cMoeda,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aEntAdPar)

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA281   ºAutor  ³Microsiga           º Data ³  12/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Rat281Conta(cCt1Ori,cCttOri,cCtdOri,cCthOri,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aJaRatCTH,aJaRatCTD,aJaRatCTT,aJaRatCT1,aEntAdPar)

Local cMoeda := mv_par10
Local lSaldo := .F.
Local nX	 := 0
Local aVlrs	 := {}
Local aVlrJaRat := {}
Local nJaRatCT1	:= 0
Local nVlrs
Local nJaRat

Default aEntAdPar	:= {}

For nVlrs := 1 to Len(aSaldos)
	aAdd(aVlrs,0)
	aAdd(aVlrJaRat,0)
Next

For nJaRat := 1 to Len(aJaRatCTH)
	If aJaRatCTH[nJaRat,1] == cCT1Ori
		For nX := 1 to Len(aJaRatCTH[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTH[nJaRat,5,nX]
		Next
	Endif
Next
For nJaRat := 1 to Len(aJaRatCTD)
	If aJaRatCTD[nJaRat,1] == cCT1Ori
		For nX := 1 to Len(aJaRatCTD[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTD[nJaRat,5,nX]
		Next
	Endif
Next
For nJaRat := 1 to Len(aJaRatCTT)
	If aJaRatCTT[nJaRat,1] == cCT1Ori
		For nX := 1 to Len(aJaRatCTT[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTT[nJaRat,5,nX]
		Next
	Endif
Next
For nJaRat := 1 to Len(aJaRatCT1)
	If aJaRatCT1[nJaRat,1] == cCT1Ori
		For nX := 1 to Len(aJaRatCT1[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCT1[nJaRat,5,nX]
		Next
		nJaRatCT1 := nJaRat
	Endif
Next

For nX := 1 to Len(aSaldos)
	If mv_par09 == 2						/// SE O PARAMETRO DE MOEDAS ESTIVER PARA ESPECIFICA (2)
		nX := val(mv_par10)
	Else
		cMoeda := StrZero(nX,2)
	Endif
	
	// Saldo da conta/centro de custo
	If CTQ->CTQ_TIPO = "1"
		aSaldos[nX][3]	:= MovConta(cCt1Ori,dDataIni,mv_par02,cMoeda,mv_par11, 3)
	Else
		aSaldos[nX][3]	:= SaldoCT7(cCt1Ori,mv_par02,cMoeda,mv_par11)[1]
	Endif
	
	aSaldos[nX][3] := Round(NoRound(aSaldos[nX][3] * (CTQ->CTQ_PERBAS / 100),3),2)
	
	If aVlrJaRat[nX] <> 0						 /// SE HA DIFERENCA DE SALDO DE NIVEL MAIS BAIXO (ENTIDADE ABAIXO)
		If aVlrJaRat[nX] < 0 .And. aSaldos[nX][3] < 0   	/// VERIFICA SE OS VALORES SAO NEGATIVOS
			If Abs(aVlrJaRat[nX]) >= Abs(aSaldos[nX][3])
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		Else
			If aVlrJaRat[nX] >= aSaldos[nX][3]
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		EndIf
	Endif
	
	If aSaldos[nX][3] <> 0
		aVlrs[nX]		:= aSaldos[nX,3]
		lSaldo := .T.
		aCols[nX][Len(aCols[nX])] := 0
		aCols[nX][2] := If(cMoeda == "01", "1", "4")
	Else
		aCols[nX][2] := If(cMoeda == "01", "4", "5")
	Endif
	
	If mv_par09 == 2						/// SE FOR MOEDA ESPECIFICA EXECUTA APENAS UMA VEZ
		Exit
	Endif
Next

If lSaldo
	If GetNewPar( "MV_CT281CP" , .T. ) // verifica se utilizara a contra partida no lançamento
		If Empty(cCT1PAR) .and. !Empty(cCT1ORI)
			cCT1PAR := cCT1ORI
		Endif
		If Empty(cCTTPAR) .and. !Empty(cCTTORI)
			cCTTPAR := cCTTORI
		Endif
		If Empty(cCTDPAR) .and. !Empty(cCTDORI)
			cCTDPAR := cCTDORI
		Endif
		If Empty(cCTHPAR) .and. !Empty(cCTHORI)
			cCTHPAR := cCTHORI
		Endif
	Endif
	
	If nJaRatCT1 > 0
		For nX := 1 To Len(aJaRatCT1[nJaRatCT1,5])
			aJaRatCT1[nJaRatCT1,5,nX] += aVlrs[nX]
		Next
	Else
		aAdd(aJaRatCT1,{cCt1Ori,cCttOri,cCtdOri,cCthOri,aVlrs})
	Endif
	
	GrvRatCtq(cCt1Ori,cSpCTT,cSpCTD,cSpCTH,cMoeda,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aEntAdPar)

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA281   ºAutor  ³Microsiga           º Data ³  12/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvRatCTQ(cCt1Ori,cCttOri,cCtdOri,cCthOri,cMoeda,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aEntAdPar)

Local aCTQ := CTQ->(GetArea())
Local nRateio	:= 0
Local aEntAdc	:= {}
Local lHasEnt	:= .F.
Local nZ		:= 0
Local aRegMaior := {}

Default aEntAdPar	:= {}

If ( Len(aEntAdPar) > 0 )
	aEntAdc	:= Array(Len(aEntAdPar),3)
Endif

If Len(aRateio) < 1															/// O RATEIO PRECISA PELO MENOS DE 1 PARTIDA.
	Return																	/// CANCELA
Endif

lCT1ORI := aUSORI[1]					/// INDICA QUE A CONTA FOI PREENCHIDA NA ORIGEM DO RATEIO
lCTTORI := aUSORI[2]					/// INDICA QUE O C.CUSTO FOI PREENCHIDO NA ORIGEM DO RATEIO
lCTDORI := aUSORI[3]					/// INDICA QUE ITEM CONTABIL FOI PREENCHIDO NA ORIGEM DO RATEIO
lCTHORI := aUSORI[4]					/// INDICA QUE A CLASSE DE VALORES FOI PREENCHIDA NA ORIGEM DO RATEIO

For nRateio := 1 to Len(aRateio)
	
	cCT1CPAR := aRateio[nRateio,1]		/// VARIAVEIS DE CONTRA-PARTIDO CORRESPONDEM AS LINHAS DO RATEIO.
	cCTTCPAR := aRateio[nRateio,2]
	cCTDCPAR := aRateio[nRateio,3]
	cCTHCPAR := aRateio[nRateio,4]
	nPERCEN  := aRateio[nRateio,5]
	
	If ( Len(aEntAdc) > 0 )
	
		For nZ := 1 to Len(aEntAdPar)
		
			lHasEnt := &("_lCpoEnt" + STRZERO(nZ+4,2))
		
			If ( lHasEnt )
			
				aEntAdc[nz][1]	:= aRateio[nRateio,nZ+6] 	//contra partida
				aEntAdc[nz][2]	:= aEntAdPar[nZ] 			//partida
				
				If ( Len(aUSORI) > 4 ) 
					aEntAdc[nZ][3]	:= aUSORI[nZ+4]			//Se a entidade adicional foi preenchida na origem rateio
				Else
					aEntAdc[nZ][3]	:= .F.  
				EndIf
			
			Else
				aEntAdc[nz][1]	:= "" 	//contra partida
				aEntAdc[nz][2]	:= ""	//partida
				
			EndIf
			
		Next nZ
	
	EndIf
	 
	lCT1CPAR	:= !Empty(cCT1CPAR)
	lCTTCPAR	:= !Empty(cCTTCPAR)
	lCTDCPAR	:= !Empty(cCTDCPAR)
	lCTHCPAR	:= !Empty(cCTHCPAR)
	
	If GetNewPar( "MV_CT281CP" , .T. ) // verifica se utilizara a contra partida no lançamento
		If !lCT1CPAR															/// SE A CONTA NAO FOI INFORMADA NO RATEIO
			cCT1CPAR := cCT1ORI	   												/// USA A CONTA CONTABIL ORIGEM
		Endif
		If !lCTTCPAR/* .and. !lCTTORI*/												/// SE A CONTA NAO FOI INFORMADA NO RATEIO NEM NA C.PARTIDA
			cCTTCPAR := cCTTORI													/// USA O CENTRO DE CUSTO ORIGEM
		Endif
		If !lCTDCPAR/* .and. !lCTDORI*/												/// SE A CONTA NAO FOI INFORMADA NO RATEIO NEM NA C.PARTIDA
			cCTDCPAR := cCTDORI													/// USA O ITEM CONTABIL ORIGEM
		Endif
		If !lCTHCPAR/* .and. !lCTHORI*/												/// SE A CONTA NAO FOI INFORMADA NO RATEIO NEM NA C.PARTIDA
			cCTHCPAR := cCTHORI													/// USA A CLASSE DE VALOR ORIGEM
		Endif
	Endif
	
	CTQ->(DbGoTo(aRateio[nRateio][6]))
	
	If !Empty(cCT1PAR) .and. !Empty(cCT1CPAR)
		Ct281GerRat(@lFirst, @nLinha, @cLinha, @cDoc, @CTF_LOCK, @cSeqLan,;
		bHistCTQ, lAtSldBase, aSaldos,;
		cCT1CPAR,cCT1PAR,;
		cCTTCPAR,cCTTPAR,;
		cCTDCPAR,cCTDPAR,;
		cCTHCPAR,cCTHPAR,;
		nRateio = Len(aRateio),,nPERCEN,aEntAdc,aRegMaior)
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava tabela de historico de rateios off-line (CV9) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CtbHistRat( CTQ->CTQ_RATEIO, mv_par03, mv_par04, cDoc, mv_par01, "CTBA281", "CTQ" )

CTQ->(RestArea(aCTQ))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA281   ºAutor  ³Microsiga           º Data ³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctq2Array(cCodCTQ)

Local aRateio := {}
Local cFilCTQ := xFilial("CTQ")

Default cCodCTQ	:= '000001'

While CTQ->(!Eof()) .And. CTQ->CTQ_FILIAL == cFilCTQ .And. CTQ->CTQ_RATEIO == cCodCTQ

	cCtq_E05CP 	:= If(_lCpoEnt05,CTQ->CTQ_E05CP,"")
	cCtq_E06CP 	:= If(_lCpoEnt06,CTQ->CTQ_E06CP,"")
	cCtq_E07CP 	:= If(_lCpoEnt07,CTQ->CTQ_E07CP,"")
	cCtq_E08CP 	:= If(_lCpoEnt08,CTQ->CTQ_E08CP,"")
	cCtq_E09CP 	:= If(_lCpoEnt09,CTQ->CTQ_E09CP,"")
	
	Aadd(aRateio, {CTQ->CTQ_CTCPAR, CTQ->CTQ_CCCPAR, CTQ->CTQ_ITCPAR, CTQ->CTQ_CLCPAR, CTQ->CTQ_PERCEN, CTQ->(Recno()),;
	 				cCtq_E05CP, cCtq_E06CP, cCtq_E07CP, cCtq_E08CP, cCtq_E09CP})	
	
	CTQ->(dbSkip())
EndDo

Return(aRateio)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct281GerRat³ Autor ³ Marcos S. Lobo       ³ Data ³ 13.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o lancamento de rateio no CT2                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct281GerRat(lFirst, nLinha, cLinha, cDoc, CTF_LOCK, cSeqLan,³±±
±±³          ³            lUltimoLanc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lFirst   = Indica se esta efetuando o 1o Lancto.           ³±±
±±³          ³ nLinha   = Numero da linha atual que esta sendo gerado     ³±±
±±³          ³ USADA PARA COMPARACAO COM O NUMERO MAXIMO DE LINHAS P/ DOC ³±±
±±³          ³ cLinha   = Numero da linha atual utilizada para gravacao   ³±±
±±³          ³ cDoc     = Numero do Documento utilizado para gravacao     ³±±
±±³          ³ CTF_LOCK = Lock de semaforo do documento                   ³±±
±±³          ³ cSeqLan  = Sequencia do lancamento atual                   ³±±
±±³          ³ bHistCTQ = Historico do lancamento de rateio               ³±±
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
Static Function Ct281GerRat(lFirst, nLinha, cLinha, cDoc, CTF_LOCK, cSeqLan, bHistCTQ,;
lAtSldBase, aSaldos, cCt1CPar, cCt1Par, cCttCPar, cCttPar,;
cCtdCPar, cCtdPar, cCthCPar, cCthPar, lUltimoL, aPesos,nPERCEN, aEntAdc, aRegMaior)

Local nX         := 0
Local nSaldo     := 0
Local nValorLanc := 0
Local lCT281Hist := ExistBlock("CT281HIST")
Local cSeqold    := cSeqLan
Local lval0      := .F.
Local nXAux      := 0
Local lMoed1Zero := .F.
Local aCT2Moed1  := {}
Local nQElem     := 0
Local cPartAux   := ""
Local cCtParAux  := ""
Local lUnicVez   := .T.
Local lExcecao   := .F.
Local nMoeda     := 0
Local aArea		 := {}
Local nDifAtu	 := 0

Default aEntAdc  := {}
Default aRegMaior := {}

//Chamar a multlock
aTravas := {}
IF !Empty(cCT1PAR)
	AADD(aTravas,cCT1PAR)
Endif
IF !Empty(cCT1CPAR)
	AADD(aTravas,cCT1CPAR)
Endif

/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
If CtbCanGrv(aTravas,@lAtSldBase)
	
	BEGIN TRANSACTION
	If lFirst .Or. nLinha > MAX_LINHA
		Do While !ProxDoc(mv_par02,mv_par03,mv_par04,@cDoc,@CTF_LOCK)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o N§ do Doc estourou, incrementa o lote         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLote := CtbInc_Lot(cLote, cModulo)

		Enddo
		lFirst := .F.
		cLinha := StrZero( 1, Len(CT2->CT2_LINHA) ) //"001"
		nLinha := 1
	Endif
	cSeqLan := Soma1(cSeqLan)
	
	For nX := 1 To Len(aCols)
		nXAux := nX
		If mv_par09 == 2 .and. nX <> 1 .and. !lval0 
			nX := Val(mv_par10)
		Endif
		If aSaldos[nX][3] == 0		/// SE O VALOR ESTIVER ZERADO
			If mv_par09 == 2 			/// SE FOR MOEDA ESPECIFICA
				If mv_par10 == "01"			/// SE FOR MOEDA 01
					Loop						/// NAO GRAVA
				Endif					/// SE FOR OUTRA MOEDA ESPECIFICA DEVE GERAR O REG. NA MOEDA 01 ZERADO
			Else						/// SE FOR PARA TODAS AS MOEDAS
				If nX <> 1					/// REGISTRO DE "OUTRA MOEDA" COM VALOR ZERADO
					Loop						/// NAO GRAVA
				Endif
			Endif
		Endif
		nSaldo := aSaldos[nX][3]
		
		If nSaldo < 0
			nValorLanc := Round(NoRound((nSaldo*(-1))*(nPERCEN/100), 3), 2)
		Else
			nValorLanc := Round(NoRound(nSaldo*(nPERCEN/100), 3), 2)
		Endif
		
		If aPesos # Nil
			nValorLanc *= aPesos[nX] / aSaldos[nX][3]
		Endif
		
		// Calcula a diferenca de rateio e ajusta o valor do lancamento
		nDifAtu := aCols[nX][Len(aCols[1])]
		aCols[nX][Len(aCols[1])] += nValorLanc // Valor Lancamento
		nDif := Abs(nSaldo)-aCols[nX][Len(aCols[nX])]
		If lUltimoL
			If nDif < 0
				If ABS(nDif) < nValorLanc							/// SO RETIRA SE A DIFERENCA FOR MENOR QUE O VALOR DO LANC.
					nValorLanc -= Abs(nDif)                        /// PARA NAO GERAR LANC. COM VLR NEGATIVO
				Endif											   /// CASO CONTRARIO NAO EFETUA AJUSTE DA DIFERENCA
			Else
				nValorLanc += nDif
			Endif

			nDifAtu += nValorLanc - Abs(nSaldo)

			If (nValorLanc <= 0.01 .And. nValorLanc >= -0.01) .And. nDifAtu != 0
				lExcecao := .T.
			EndIf
		Endif
		aCols[nX][3] := nValorLanc // Valor Lancamento
		
		If nValorLanc <= 0 .And. ( !lExcecao )
			cSeqLan:= cSeqold
			lval0 := .T.
			If nXAux < Len(aCols)
				Loop
			EndIf	
		Else
			lval0 := .F.
		EndIf
				
		If lCT281Hist		/// P.E. PARA ALTERACAO DO HISTORICO
			cHistCTQ := ExecBlock("CT281HIST",.F.,.F.,{bHistCTQ})
			bHistCTQ := { || cHistCTQ }
		EndIf

		lMoed1Zero := nX > 1 .And. aSaldos[1][3] == 0 .And. aScan(aCT2Moed1, {|x| x == cLinha}) == 0 
		
		nMoeda := VAL(aCols[nX][1])
		If Len(aRegMaior) >= nMoeda
			If nValorLanc > aRegMaior[nMoeda,6]
				aRegMaior[nMoeda ,1] := mv_par02
				aRegMaior[nMoeda,2] := mv_par03
				aRegMaior[nMoeda,3] := mv_par04
				aRegMaior[nMoeda,4] := cDoc
				aRegMaior[nMoeda,5] := cLinha
				aRegMaior[nMoeda,6] := nValorLanc
			EndIf
		Else
			aAdd(aRegMaior,{mv_par02,mv_par03,mv_par04,cDoc,cLinha,nValorLanc})
		EndIf 

		If nPERCEN > 0 .And. nValorLanc > 0
			// Saldo origem negativo (saldo devedor), lanca a credito na partida e a debito na conta rateada (contra partida)
			If nSaldo < 0
				//Adiciona Lançamento para Moeda 01 quando a mesma estiver com valor zerado
				//e nao houver lançamento para ela, necessário pois Moeda 01 é obrigatória
				If lMoed1Zero
					GravaLanc(	mv_par02,mv_par03,mv_par04,cDoc,cLinha,"3",aCols[1][1],;
					mv_par06,cCt1CPar, cCt1Par, cCttCPar, cCttPar,;
					cCtdCPar, cCtdPar, cCthCPar, cCthPar,;
					0,Eval(bHistCTQ),mv_par11,cSeqLan,3,lAtSldBase,;
					aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA281",,,,,,,,,,CTQ->CTQ_INTERC,,,,aEntAdc) 

					//Adiciona linha para criar Moeda 01 zerada somente 1 vez por linha
					aAdd(aCT2Moed1, cLinha)
				EndIf
				
				GravaLanc(	mv_par02,mv_par03,mv_par04,cDoc,cLinha,"3",aCols[nX][1],;
				mv_par06,cCt1CPar, cCt1Par, cCttCPar, cCttPar,;
				cCtdCPar, cCtdPar, cCthCPar, cCthPar,;
				nValorLanc,Eval(bHistCTQ),mv_par11,cSeqLan,3,lAtSldBase,;
				aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA281",,,,,,,,,,CTQ->CTQ_INTERC,,,,aEntAdc) 			
			Else
				If lUnicVez  //INVERTE UMA UNICA VEZ
					//Inverter os elementos quando saldo a credito para as entidades adicionais	
					For nQElem := 1 TO Len(aEntAdc)
						//salva os elementos do array em variaveis
						cCtParAux := aEntAdc[nQElem][1]
						cPartAux := aEntAdc[nQElem][2]
						//inverte a posicao dos elementos do array
						aEntAdc[nQElem][1] := cPartAux
						aEntAdc[nQElem][2] := cCtParAux
					Next
					lUnicVez := .F.
				EndIf

				//Adiciona Lançamento para Moeda 01 quando a mesma estiver com valor zerado
				//e nao houver lançamento para ela, necessário pois Moeda 01 é obrigatória
				If lMoed1Zero
					GravaLanc(	mv_par02,mv_par03,mv_par04,cDoc,cLinha,"3",aCols[1][1],;
					mv_par06,cCt1Par, cCt1CPar, cCttPar, cCttCPar,;
					cCtdPar, cCtdCPar, cCthPar, cCthCPar, 0,Eval(bHistCTQ),;
					mv_par11,cSeqLan,3,lAtSldBase,aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA281",,,,,,,,,,CTQ->CTQ_INTERC,,,,aEntAdc)

					//Adiciona linha para criar Moeda 01 zerada somente 1 vez por linha
					aAdd(aCT2Moed1, cLinha)
				EndIf
				
				GravaLanc(	mv_par02,mv_par03,mv_par04,cDoc,cLinha,"3",aCols[nX][1],;
				mv_par06,cCt1Par, cCt1CPar, cCttPar, cCttCPar,;
				cCtdPar, cCtdCPar, cCthPar, cCthCPar, nValorLanc,Eval(bHistCTQ),;
				mv_par11,cSeqLan,3,lAtSldBase,aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA281",,,,,,,,,,CTQ->CTQ_INTERC,,,,aEntAdc)			
			Endif
		Endif
		
		If lExcecao
			aArea := GetArea()
			dbSelectArea("CT2")
			dbSetOrder(1)
			//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC                                                     
			If MsSeek(xFilial("CT2")+DTOS(aRegMaior[nMoeda,1])+aRegMaior[nMoeda,2]+aRegMaior[nMoeda,3]+aRegMaior[nMoeda,4]+aRegMaior[nMoeda,5]+ mv_par11+cEmpAnt+cFilAnt+aCols[nX][1])
				CT2->( Reclock("CT2", .F. ) )
				CT2->CT2_VALOR := aRegMaior[nMoeda,6] + nDif
				CT2->( MsUnlock() )
			EndIf

			RestArea(aArea)
			lExcecao := .F.
				 
		EndIf 

		If mv_par09 == 2 .and. (nX <> 1 .or. mv_par10 == "01")
			Exit
		Endif
	Next
	If !lval0
		cLinha 	:= Soma1(cLinha)
		nLinha ++
		cSeqLan := CT2->CT2_SEQLAN // Sequencia dp lancamento
	EndIf
	END TRANSACTION
	Ct1MUnLock()
	dbCommitAll()
EndIf

aSize(aArea,0)
aArea := nil 

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT280CRTOKºAutor  ³Renato F. Campos    º Data ³  08/18/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION CT281CRTOK()
Local aSaveArea	:= GetArea()
Local lRet 		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Antes de iniciar o processamento, verifico os parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte( "CTB281", .F. )

IF lRet .And. Empty(mv_par01) // Data de referencia Inicial nao preenchida.
	lRet := .F.
	Help(" ",1,"NOCTBDTLP")
	ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))
ENDIF

IF lRet .And. Empty(mv_par02) // Data de referencia Final nao preenchida.
	lRet := .F.
	Help(" ",1,"NOCTBDTLP")
	ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))
ENDIF

//Verificar se o calendario da data solicitada esta encerrado
IF lRet .And. ! CtbValiDt(1,mv_par01,,mv_par11)
	lRet := .F.
	ProcLogAtu("ERRO","CTBVALIDT","CTBVALIDT")
EndIf

//Verificar se o calendario da data solicitada esta encerrado
IF lRet .And. ! CtbValiDt(1,mv_par02,,mv_par11)
	lRet := .F.
	ProcLogAtu("ERRO","CTBVALIDT","CTBVALIDT")
EndIf

IF lRet .And. Empty(mv_par03)	// Lote nao preenchido
	lRet := .F.
	Help(" ",1,"NOCT280LOT")
	ProcLogAtu("ERRO","NOCT280LOT",Ap5GetHelp("NOCT280LOT"))
ENDIF

IF lRet .And. Empty(mv_par04) // Sub Lote nao preenchido
	lRet := .F.
	Help(" ",1,"NOCTSUBLOT")
	ProcLogAtu("ERRO","NOCTSUBLOT",Ap5GetHelp("NOCTSUBLOT"))
ENDIF

IF lRet .And. Empty(mv_par05)	// Documento nao preenchido.
	lRet := .F.
	Help(" ",1,"NOCT280DOC")
	ProcLogAtu("ERRO","NOCT280DOC",Ap5GetHelp("NOCT280DOC"))
ENDIF

IF lRet .And. Empty(mv_par06) // Historico Padrao nao preenchido
	lRet := .F.
	Help(" ",1,"CTHPVAZIO")
	ProcLogAtu("ERRO","CTHPVAZIO",Ap5GetHelp("CTHPVAZIO"))
ENDIF

If lRet
	//Historico Padrao nao existe no cadastro.
	dbSelectArea("CT8")
	dbSetOrder(1)
	
	IF ! dbSeek( xFilial( "CT8" ) + mv_par06 )
		lRet := .F.
		Help(" ",1,"CT280NOHP")
		ProcLogAtu("ERRO","CT280NOHP",Ap5GetHelp("CT280NOHP"))
	Endif
Endif

IF lRet .And. Empty(mv_par07) .And. Empty(mv_par08)// Rateio inicial e final nao preenchidos.
	lRet := .F.
	Help(" ",1,"NOCT280RT")
	ProcLogAtu("ERRO","NOCT280RT",Ap5GetHelp("NOCT280RT"))
ENDIF

IF lRet .And. mv_par09 == 2 .And. Empty(mv_par10) // Moeda especifica nao preenchida
	lRet := .F.
	Help(" ",1,"NOCTMOEDA")
	ProcLogAtu("ERRO","NOCTMOEDA",Ap5GetHelp("NOCTMOEDA"))
ENDIF

IF lRet .And. Empty(mv_par11) // Tipo de saldo nao preenchido
	lRet := .F.
	Help(" ",1,"NO280TPSLD")
	ProcLogAtu("ERRO","NO280TPSLD",Ap5GetHelp("NO280TPSLD"))
ENDIF

// Efetua a validação do rateio
IF lRet .And. ! CT280RTOK( mv_par07 , mv_par08 )
	lRet := .F.
Endif

IF lRet .And. ExistBlock( "CT281MVOK" )
	lRet := ExecBlock( "CT281MVOK", .F., .F. )
Endif

RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTB281Qry

Função para tratar a query antes da execução.

@param   aUSORI - Array com as informações das entidades contábeis (padrões + adicionais)

@author  Totvs
@version P12
@since   22/10/2018
@return  Query tratada de acordo com as parametrizações passadas no cadastro do rateio ou pelas perguntas
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function CTB281Qry(aUSORI)

Local cQry		:= ""
Local cEntAdc	:= ""
Local cOr		:= ""
Local cAnd		:= ""
Local cVar		:= ""
Local nX		:= 0
Local lHasEnAd	:= .F.

/*         	// Primeira posição: Verifica se a entidade esta como usada (Configurações contábeis)
 			// Segunda posição: Passa o conteúdo gravado na origem (cadastro do rateio)
aUSORI	:= {{.T.		,!Empty(CTQ->CTQ_CTORI)},;
			{__lCusto	,!Empty(CTQ->CTQ_CCORI)},;
			{__lItem	,!Empty(CTQ->CTQ_ITORI)},;
			{__lClvl	,!Empty(CTQ->CTQ_CLORI)},;
			{_lCpoEnt05	,Iif(_lCpoEnt05,!Empty(CTQ->CTQ_E05ORI),.f.)},;
			{_lCpoEnt06	,Iif(_lCpoEnt06,!Empty(CTQ->CTQ_E06ORI),.f.)},;
			{_lCpoEnt07	,Iif(_lCpoEnt07,!Empty(CTQ->CTQ_E07ORI),.f.)},;
			{_lCpoEnt08	,Iif(_lCpoEnt08,!Empty(CTQ->CTQ_E08ORI),.f.)},;
			{_lCpoEnt09	,Iif(_lCpoEnt09,!Empty(CTQ->CTQ_E09ORI),.f.)} }

*/

If ( Len(aUSORI) > 4 )
	
	lHasEnAd := ( aUSORI[5,2] .OR. aUSORI[6,2] .OR. aUSORI[7,2] .OR. aUSORI[8,2] .OR. aUSORI[9,2] ) // Verifica se alguma das entidades esta na origem
	
	//varre as entidades adicionais
	For nX := 5 to 9
	
		//checa se possui uma determinada entidade adicional	
		If ( nX <= Len(aUSORI) .And. aUSORI[nX,2]  )
			
			//campos do select das entidades adicionais
			cEntAdc 	+= " 	CVX_NIV" + STRZero(nX,2) + " ENT" + STRZero(nX,2) + ", "
			
			cVar := " CVX_NIV" + STRZero(nX,2) + " = " + " '" + CTQ->&("CTQ_E" + STRZero(nX,2) + "ORI") + "'"
			
			//tratamento de filtro dos campos das entidades adicionais 
			If ( nX == 5 )
				
				cOr 	+= cVar
				cAnd 	+= "	AND " + cVar				
			
			Else
				
				cOr 	+= "	OR " + cVar
				cAnd 	+= "	AND " + cVar
				
			EndIf	
		
		Else //se não possui entidade adicional, então o conteúdo será vazio
		
			If ( At("NIV"+StrZero(nX,2), cEntAdc) == 0 )
				cEntAdc += " 	' ' ENT" + STRZero(nX,2) + ", "
			EndIf
			
		EndIf
		
	Next nX
	
	If ( !Empty(cOr) )
	
		If ( At("OR",Upper(cOr)) > 0 )
			cOr := " AND (" + cOr
			cOr += " ) "
		Else
			cOr := " AND " + cOr
		Endif

	EndIf
	
EndIf

cEntAdc := Substr(cEntAdc,1,RAt(",",cEntAdc)-1)

// Verifica se a Classe de Valor esta como Usada ou foi informada na origem
If ( aUSORI[4,1] .OR. aUSORI[4,2] )	
				
	cQry += " SELECT "
	cQry += " CQ7_CONTA CONTA,CQ7_CCUSTO CUSTO,CQ7_ITEM ITEM,CQ7_CLVL CLVL"   
	
	If ( lHasEnAd )
		cQry += ", " + cEntAdc
	EndIf
		
	cQry += " FROM "+RetSqlName("CQ7") + " CQ7 "
	
	If ( lHasEnAd )
		
		cQry += " INNER JOIN "
		cQry += "	" + RetSQLName("CVX") + " CVX "
		cQry += " ON "
		cQry += " 	CVX_FILIAL = CQ7_FILIAL " 
		cQry += " 	AND CVX_NIV04 = CQ7_CLVL " 
		cQry += cAnd
		cQry += " 	AND CVX.D_E_L_E_T_ = '' ""
	
	EndIf
		
	cQry += " WHERE CQ7_FILIAL = '"+xFilial("CQ7")+"' "
	cQry += "  AND CQ7_DATA >= '"+DTOS(mv_par01)+"' "	//mv_par01
	cQry += "  AND CQ7_DATA <= '"+DTOS(mv_par02)+"' "
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// ADICIONA O FILTRO DOS PARAMETROS
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	If  ( aUSORI[4,2] ) //Classe de Valor Origem
		cQry += "  AND CQ7_CLVL = '"+CTQ->CTQ_CLORI+"' "
	Else
	
		If !Empty(mv_par18)
			cQry += "  AND CQ7_CLVL >= '"+mv_par18+"' "
		Endif
		
		If !Empty(mv_par19)  .and. Replicate("Z",Len(mv_par19)) <> UPPER(mv_par19)
			cQry += "  AND CQ7_CLVL <= '"+mv_par19+"' "
		Endif
	Endif
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	If mv_par09 == 2
		cQry += "  AND CQ7_MOEDA = '"+mv_par10+"' "
	Endif
	
	cQry += "  AND CQ7_TPSALD = '"+mv_par11+"' "
	
	If ( aUSORI[1,2] )	// Conta Contábil Origem
		cQry += "  AND CQ7_CONTA = '"+CTQ->CTQ_CTORI+"' "
	Else
		
		If !Empty(mv_par12)
			cQry += "  AND CQ7_CONTA >= '"+mv_par12+"' "
		Endif
		
		If !Empty(mv_par13) .and.  Replicate("Z",Len(mv_par13)) <> UPPER(mv_par13)
			cQry += "  AND CQ7_CONTA <= '"+mv_par13+"' "
		Endif
		
	Endif

	If ( aUSORI[2,2] ) //Centro de Custo Origem	
		cQry += "  AND CQ7_CCUSTO = '"+CTQ->CTQ_CCORI+"' "
	Else
		
		If !Empty(mv_par14)
			cQry += "  AND CQ7_CCUSTO >= '"+mv_par14+"' "
		Endif
		
		If !Empty(mv_par15) .and.  Replicate("Z",Len(mv_par15)) <> UPPER(mv_par15)
			cQry += "  AND CQ7_CCUSTO <= '"+mv_par15+"' "
		Endif
		
	Endif

	If ( aUSORI[3,2] )	//Item Contábil Origem
		cQry += "  AND CQ7_ITEM = '"+CTQ->CTQ_ITORI+"' "
	Else
	
		If !Empty(mv_par16)
			cQry += "  AND CQ7_ITEM >= '"+mv_par16+"' "
		Endif
		
		If !Empty(mv_par17) .and.  Replicate("Z",Len(mv_par17)) <> UPPER(mv_par17)
			cQry += "  AND CQ7_ITEM <= '"+mv_par17+"' "
		Endif
		
	Endif
	
	cQry += "  AND CQ7.D_E_L_E_T_ = ' ' "

Endif

// Verifica se o Item Contábil esta como Usado ou foi informado na origem
If ( aUSORI[3,1] .OR. aUSORI[3,2] ) 
	
	If ( !Empty(cQry) )
		cQry += " UNION "
	EndIf
	
	cQry += " SELECT "
	cQry += " CQ5_CONTA CONTA,CQ5_CCUSTO CUSTO,CQ5_ITEM ITEM,'"+CTQ->CTQ_CLORI+"' CLVL"
	
	If ( lHasEnAd )
		cQry += ", " + cEntAdc
	EndIf
	
	cQry += " FROM "+RetSqlName("CQ5") + " CQ5 "
	
	If ( lHasEnAd )
		
		cQry += " INNER JOIN "
		cQry += "	" + RetSQLName("CVX") + " CVX "
		cQry += " ON "
		cQry += " 	CVX_FILIAL = CQ5_FILIAL " 
		cQry += " 	AND CVX_NIV03 = CQ5_ITEM " 
		cQry += cAnd
		cQry += " 	AND CVX.D_E_L_E_T_ = '' ""
	
	EndIf
	
	cQry += " WHERE CQ5_FILIAL = '"+xFilial("CQ5")+"' "
	cQry += " AND CQ5_DATA >= '"+DTOS(mv_par01)+"' "
	cQry += " AND CQ5_DATA <= '"+DTOS(mv_par02)+"' "
	
	If ( aUSORI[3,2] ) //Item Contábil Origem
		cQry += " AND CQ5_ITEM = '"+CTQ->CTQ_ITORI+"' "
	Else
	
		If !Empty(mv_par16)
			cQry += "  AND CQ5_ITEM >= '"+mv_par16+"' "
		Endif
		
		If !Empty(mv_par17) .and.  Replicate("Z",Len(mv_par17)) <> UPPER(mv_par17)
			cQry += "  AND CQ5_ITEM <= '"+mv_par17+"' "
		Endif
		
	Endif
	
	If mv_par09 == 2
		cQry += "  AND CQ5_MOEDA = '"+mv_par10+"' "
	Endif
	
	cQry += " AND CQ5_TPSALD = '"+mv_par11+"' "
	
	If  ( aUSORI[1,2] )	//Conta Origem
		cQry += "  AND CQ5_CONTA = '"+CTQ->CTQ_CTORI+"' "
	Else
	
		If !Empty(mv_par12)
			cQry += "  AND CQ5_CONTA >= '"+mv_par12+"' "
		Endif
		
		If !Empty(mv_par13) .and. Replicate("Z",Len(mv_par13)) <> UPPER(mv_par13)
			cQry += "  AND CQ5_CONTA <= '"+mv_par13+"' "
		Endif
		
	Endif
	
	If  ( aUSORI[2,2] )	//Centro de Custo Origem
		cQry += " AND CQ5_CCUSTO = '"+CTQ->CTQ_CCORI+"' "
	Else
	
		If !Empty(mv_par14)
			cQry += "  AND CQ5_CCUSTO >= '"+mv_par14+"' "
		Endif
		
		If !Empty(mv_par15) .and.  Replicate("Z",Len(mv_par15)) <> UPPER(mv_par15)
			cQry += "  AND CQ5_CCUSTO <= '"+mv_par15+"' "
		Endif
		
	Endif

	cQry += "  AND CQ5.D_E_L_E_T_ = ' ' "

Endif

// Verifica se o Centro de Custo esta como Usado ou foi informado na origem
If ( aUSORI[2,1] .OR. aUSORI[2,2] ) 

	If ( !Empty(cQry) )
		cQry += " UNION "
	EndIf

	cQry += " SELECT "
	cQry += " CQ3_CONTA CONTA,CQ3_CCUSTO CUSTO,'"+CTQ->CTQ_ITORI+"' ITEM,'"+CTQ->CTQ_CLORI+"' CLVL "
	
	If ( lHasEnAd )
		cQry += ", " + cEntAdc
	EndIf
	
	cQry += " FROM "+RetSqlName("CQ3") + " CQ3 "
	
	If ( lHasEnAd )
		
		cQry += " INNER JOIN "
		cQry += "	" + RetSQLName("CVX") + " CVX "
		cQry += " ON "
		cQry += " 	CVX_FILIAL = CQ3_FILIAL " 
		cQry += " 	AND CVX_NIV03 = CQ3_CCUSTO " 
		cQry += cAnd
		cQry += " 	AND CVX.D_E_L_E_T_ = '' ""
	
	EndIf
	
	cQry += " WHERE CQ3_FILIAL = '"+xFilial("CQ3")+"' "
	cQry += " AND CQ3_DATA >= '"+DTOS(mv_par01)+"' "
	cQry += " AND CQ3_DATA <= '"+DTOS(mv_par02)+"' "

	If ( aUSORI[2,2] ) //Centro de Custo Origem
		cQry += " AND CQ3_CCUSTO = '"+CTQ->CTQ_CCORI+"' "
	Else
	
		If !Empty(mv_par14)
			cQry += "  AND CQ3_CCUSTO >= '"+mv_par14+"' "
		EndIf
		
		If !Empty(mv_par15) .and.  Replicate("Z",Len(mv_par15)) <> UPPER(mv_par15)
			cQry += "  AND CQ3_CCUSTO <= '"+mv_par15+"' "
		Endif
		
	Endif

	If mv_par09 == 2
		cQry += "  AND CQ3_MOEDA = '"+mv_par10+"' "
	Endif

	cQry += "  AND CQ3_TPSALD = '"+mv_par11+"' "

	If ( aUSORI[1,2] ) //Conta Origem
		cQry += "  AND CQ3_CONTA = '"+CTQ->CTQ_CTORI+"' "
	Else
	
		If !Empty(mv_par12)
			cQry += "  AND CQ3_CONTA >= '"+mv_par12+"' "
		Endif
		
		If !Empty(mv_par13) .and.  Replicate("Z",Len(mv_par13)) <> UPPER(mv_par13)
			cQry += "  AND CQ3_CONTA <= '"+mv_par13+"' "
		Endif
		
	Endif
	
	cQry += "  AND CQ3.D_E_L_E_T_ = ' ' "
	
Endif

// Verifica se a Conta Contábil esta como Usada ou foi informada na origem
If ( aUSORI[1,1] .OR. aUSORI[1,2] )   

	If ( !Empty(cQry) )
		cQry += " UNION "
	EndIf
	
	cQry += " SELECT "
	cQry += " CQ1_CONTA CONTA,'"+CTQ->CTQ_CCORI+"' CUSTO,'"+CTQ->CTQ_ITORI+"' ITEM,'"+CTQ->CTQ_CLORI+"' CLVL "
	
	If ( lHasEnAd )
		cQry += ", " + cEntAdc
	EndIf
	
	cQry += " FROM "+RetSqlName("CQ1") + " CQ1 "
	
	If ( lHasEnAd )
		
		cQry += " INNER JOIN "
		cQry += "	" + RetSQLName("CVX") + " CVX "
		cQry += " ON "
		cQry += " 	CVX_FILIAL = CQ1_FILIAL " 
		cQry += " 	AND CVX_NIV01 = CQ1_CONTA " 
		cQry += cAnd
		cQry += " 	AND CVX.D_E_L_E_T_ = '' ""
	
	EndIf
	
	cQry += " WHERE CQ1_FILIAL = '"+xFilial("CQ1")+"' "
	cQry += " AND CQ1_DATA >= '"+DTOS(mv_par01)+"' "
	cQry += " AND CQ1_DATA <= '"+DTOS(mv_par02)+"' "
	
	If ( aUSORI[1,2] )	//Conta Origem
		cQry += "  AND CQ1_CONTA = '"+CTQ->CTQ_CTORI+"' "
	Else
	
		If !Empty(mv_par12)
			cQry += "  AND CQ1_CONTA >= '"+mv_par12+"' "
		Endif
		
		If !Empty(mv_par13) .and.  Replicate("Z",Len(mv_par13)) <> UPPER(mv_par13)
			cQry += "  AND CQ1_CONTA <= '"+mv_par13+"' "
		Endif
		
	Endif
	
	If mv_par09 == 2
		cQry += "  AND CQ1_MOEDA = '"+mv_par10+"' "
	Endif
	
	cQry += "  AND CQ1_TPSALD = '"+mv_par11+"' "
	cQry += "  AND CQ1.D_E_L_E_T_ = ' ' "
	
Endif

// Verifica se alguma das entidades adicionais foram informadas na origem
If Len(aUSORI) >= 5 .AND. ( aUSORI[5,2] .OR. aUSORI[6,2] .OR. aUSORI[7,2] .OR. aUSORI[8,2] .OR. aUSORI[9,2] )	
			
	If ( !Empty(cQry) )
		cQry += " UNION "
	EndIf

	cQry += " SELECT "
	cQry += " 	CVX_NIV01 CONTA,
	cQry += " 	CVX_NIV02 CUSTO,
	cQry += " 	CVX_NIV03 ITEM,
	cQry += " 	CVX_NIV04 CLVL,
	
	//compondo as entidades adicionais ao Select da Query
	cQry += cEntAdc
	
	cQry += " FROM "+RetSqlName("CVX") + " CVX "
	cQry += " WHERE CVX_FILIAL = '"+xFilial("CVX") + "' "
	cQry += " AND CVX_DATA >= '"+DTOS(mv_par01)+"' "
	cQry += " AND CVX_DATA <= '"+DTOS(mv_par02)+"' "
	cQry += cOr	//demais entidades (as 'não padrões') do rateio
	
	//Verifica a Conta origem do rateio
	If ( aUSORI[1,2] )	
		cQry += "  AND CVX_NIV01 = '"+CTQ->CTQ_CTORI+"' "
	Else
	
		If !Empty(mv_par12)
			cQry += "  AND CVX_NIV01 >= '"+mv_par12+"' "
		Endif
		
		If !Empty(mv_par13) .and.  Replicate("Z",Len(mv_par13)) <> UPPER(mv_par13)
			cQry += "  AND CVX_NIV01 <= '"+mv_par13+"' "
		Endif
		
	Endif
	
	//verifica o Centro de Custo origem do rateio
	If ( aUSORI[2,2] )	
		cQry += "  AND CVX_NIV02 = '"+CTQ->CTQ_CCORI+"' "
	Else
	
		If !Empty(mv_par14)
			cQry += "  AND CVX_NIV02 >= '"+mv_par14+"' "
		Endif
		
		If !Empty(mv_par14) .and.  Replicate("Z",Len(mv_par15)) <> UPPER(mv_par15)
			cQry += "  AND CVX_NIV02 <= '"+mv_par15+"' "
		Endif
		
	Endif
	
	//Verifica Item Contábil origem do rateio
	If ( aUSORI[3,2] )	
		cQry += "  AND CVX_NIV03 = '"+CTQ->CTQ_ITORI+"' "
	Else
	
		If !Empty(mv_par16)
			cQry += "  AND CVX_NIV03 >= '"+mv_par16+"' "
		Endif
		
		If !Empty(mv_par17) .and.  Replicate("Z",Len(mv_par17)) <> UPPER(mv_par17)
			cQry += "  AND CVX_NIV03 <= '"+mv_par17+"' "
		Endif
		
	Endif
	
	//Verifica Classe de Valor origem do rateio
	If ( aUSORI[4,2] )	
		cQry += "  AND CVX_NIV04 = '"+CTQ->CTQ_CLORI+"' "
	Else
	
		If !Empty(mv_par18)
			cQry += "  AND CVX_NIV04 >= '"+mv_par18+"' "
		Endif
		
		If !Empty(mv_par19)  .and. Replicate("Z",Len(mv_par19)) <> UPPER(mv_par19)
			cQry += "  AND CVX_NIV04 <= '"+mv_par19+"' "
		Endif
		
	EndIf
		
	If mv_par09 == 2
		cQry += "  AND CVX_MOEDA = '"+mv_par10+"' " 
	Endif
	
	cQry += "  AND CVX_TPSALD = '"+mv_par11+"' "
	cQry += "  AND CVX.D_E_L_E_T_ = ' ' "				
	
Endif

///// DEFINE A ORDEM DE APRESENTACAO DOS REGISTROS (DEVE SER CRESCENTE DE CONTA E DECRESCENTE DAS DEMAIS ENTIDADES)
If !Empty(cQry) 
	cQry += " ORDER BY CONTA ASC,CLVL DESC,ITEM DESC,CUSTO DESC "
Endif	

Return(cQry)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Rat281EnAd   ºAutor  ³Microsiga           º Data ³  12/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Rat281EnAd(aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aJaRatCTH,aJaRatCTD,aJaRatCTT,aJaRatCT1,aEntAdOri,aEntAdPar)

Local cMoeda 	:= mv_par10

Local lSaldo 	:= .F.

Local aVlrs	 	:= {}
Local aVlrJaRat := {}
Local aSaldoAux	:= {}

Local nJaRatCT1	:= 0
Local nVlrs		:= 0
Local nJaRat	:= 0
Local nX	 	:= 0

For nVlrs := 1 to Len(aSaldos)

	aAdd(aVlrs,0)
	aAdd(aVlrJaRat,0)

Next nVlrs

For nJaRat := 1 to Len(aJaRatCTH)

	If ( aJaRatCTH[nJaRat,1] == aEntAdOri[1] ) 	//cCT1Ori

		For nX := 1 to Len(aJaRatCTH[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTH[nJaRat,5,nX]
		Next

	Endif

Next nJaRat

For nJaRat := 1 to Len(aJaRatCTD)

	If ( aJaRatCTD[nJaRat,1] == aEntAdOri[1] )	//cCT1Ori

		For nX := 1 to Len(aJaRatCTD[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTD[nJaRat,5,nX]
		Next nX

	Endif

Next nJaRat

For nJaRat := 1 to Len(aJaRatCTT)

	If ( aJaRatCTT[nJaRat,1] == aEntAdOri[1] ) //cCT1Ori

		For nX := 1 to Len(aJaRatCTT[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCTT[nJaRat,5,nX]
		Next nX

	Endif

Next 

For nJaRat := 1 to Len(aJaRatCT1)

	If ( aJaRatCT1[nJaRat,1] == aEntAdOri[1] )	//cCT1Ori

		For nX := 1 to Len(aJaRatCT1[nJaRat,5])
			aVlrJaRat[nX] += aJaRatCT1[nJaRat,5,nX]
		Next nX

		nJaRatCT1 := nJaRat

	Endif
	
Next nJaRat

For nX := 1 to Len(aSaldos)

	If mv_par09 == 2						/// SE O PARAMETRO DE MOEDAS ESTIVER PARA ESPECIFICA (2)
		nX := val(mv_par10)
	Else
		cMoeda := StrZero(nX,2)
	Endif
	
	If CTQ->CTQ_TIPO == "1"	//Movimento do mês
		
		aSaldoAux 		:= CtbSldCubo(aEntAdOri,aEntAdOri,dDataIni,mv_par02,aCols[nX][1],mv_par11,,,.T.)
		aSaldos[nX][3]	:= aSaldoAux[1] - aSaldoAux[6]

	Else	//Saldo Acumulado
		aSaldos[nX][3] := CtbSldCubo(aEntAdOri,aEntAdOri,CToD("//"),mv_par01,aCols[nX][1],mv_par11,,,.T.)[6]
	Endif
	
	aSaldos[nX][3] := Round(NoRound(aSaldos[nX][3] * (CTQ->CTQ_PERBAS / 100),3),2)
	
	If aVlrJaRat[nX] <> 0						 /// SE HA DIFERENCA DE SALDO DE NIVEL MAIS BAIXO (ENTIDADE ABAIXO)
		If aVlrJaRat[nX] < 0 .And. aSaldos[nX][3] < 0   	/// VERIFICA SE OS VALORES SAO NEGATIVOS
			If Abs(aVlrJaRat[nX]) >= Abs(aSaldos[nX][3])
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		Else
			If aVlrJaRat[nX] >= aSaldos[nX][3]
				aSaldos[nX][3] := 0
			Else
				aSaldos[nX][3] -= aVlrJaRat[nX]		/// SUBTRAI O SALDO REFERENTE A ESTAS ENTIDADES
			Endif
		EndIf
	Endif
	
	If aSaldos[nX][3] <> 0
		aVlrs[nX]		:= aSaldos[nX,3]
		lSaldo := .T.
		aCols[nX][Len(aCols[nX])] := 0
		aCols[nX][2] := If(cMoeda == "01", "1", "4")
	Else
		aCols[nX][2] := If(cMoeda == "01", "4", "5")
	Endif
	
	If mv_par09 == 2						/// SE FOR MOEDA ESPECIFICA EXECUTA APENAS UMA VEZ
		Exit
	Endif
Next

If lSaldo
	If GetNewPar( "MV_CT281CP" , .T. ) // verifica se utilizara a contra partida no lançamento
		If Empty(cCT1PAR) .and. !Empty(aEntAdOri[1])	//Conta
			cCT1PAR := aEntAdOri[1]	//Conta
		Endif
		If Empty(cCTTPAR) .and. !Empty(aEntAdOri[2])	//Centro Custo
			cCTTPAR := aEntAdOri[2] //Centro Custo
		Endif
		If Empty(cCTDPAR) .and. !Empty(aEntAdOri[3])	//Item
			cCTDPAR := aEntAdOri[3] //Item
		Endif
		If Empty(cCTHPAR) .and. !Empty(aEntAdOri[4])	//Classe de Valor
			cCTHPAR := aEntAdOri[4] //Classe de Valor
		Endif
	Endif
	
	If nJaRatCT1 > 0
		For nX := 1 To Len(aJaRatCT1[nJaRatCT1,5])
			aJaRatCT1[nJaRatCT1,5,nX] += aVlrs[nX]
		Next
	Else
		aAdd(aJaRatCT1,{aEntAdOri[1],aEntAdOri[2],aEntAdOri[3],aEntAdOri[4],aVlrs})
	Endif
	
	GrvRatCtq(aEntAdOri[1],cSpCTT,cSpCTD,cSpCTH,cMoeda,aSaldos,aCols,aRateio,cCT1PAR,cCTTPAR,cCTDPAR,cCTHPAR,aUSORI,aEntAdPar)

Endif

Return()


/*/{Protheus.doc} CTB281Metrics
	
	CTB281Metrics - Funcao utilizada para metricas no CTBR400

	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function CTB281Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

// Local nFim := 0

Local cIdMetric  := ""
Local dDateSend := CtoD("") 
Local nLapTime := 0
Local nTotal := ""

Default cEvent := ""
Default nStart := Seconds() //Caso futuramente exista metrica de tempo medio
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//Só capturar metricas se a vers?o da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" //Evento 01 - Metrica de tempo médio

		
		//Evento 01 - Metrica de quantidade total de gravacao do tipo 15 - AF012Grv15
		If cEvent == "01" 
			cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCCTBA281",cFunBkp)
			SetFunName(cFunMet)
			cSubRoutine := Alltrim(cSubRoutine)			
			nTotal := 1 //nTotal			
			dDateSend := LastDay( Date() )

			If cSubEvent == '001'
				//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
				cIdMetric  := "contabilidade-gerencial-protheus_rateio-com-antes-reprocessamento-qtd_total"
				FWCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, nTotal, dDateSend, nLapTime)
			EndIf

			If cSubEvent == '002'
				//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
				cIdMetric  := "contabilidade-gerencial-protheus_rateio-com-durante-reprocessamento-qtd_total"
				FWCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, nTotal, dDateSend, nLapTime)
			EndIf

			If cSubEvent == '003'
				//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
				cIdMetric  := "contabilidade-gerencial-protheus_rateio-com-final-reprocessamento-qtd_total"
				FWCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, nTotal, dDateSend, nLapTime)
			EndIf

		EndIf
	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return 
