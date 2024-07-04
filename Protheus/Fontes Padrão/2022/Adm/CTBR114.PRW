#Include "CTBR114.Ch"
#Include "PROTHEUS.Ch"

// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR114  ³ Autor ³ Simone Mie Sato       ³ Data ³ 03.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Diario Geral aglutinado por conta.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR114()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR114()

Local WnRel
Local aCtbMoeda:={}
LOCAL cString	:= "CT2"
LOCAL cDesc1 	:= STR0001  //"Este programa ir  imprimir o Di rio Geral aglutinado por conta,"
LOCAL cDesc2 	:= STR0002  //"de acordo com os parametros sugeridos pelo usuario. "
LOCAL cDesc3	:= ""
Local Titulo 	:= STR0006	// Emissao do Diario Geral aglutinado por conta"
Local lRet		:= .T.

PRIVATE Tamanho	:= "M"
PRIVATE aReturn 	:= { STR0004, 1,STR0005, 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog	:= "CTBR114"
PRIVATE aLinha  	:= { }
PRIVATE nLastKey	:= 0
PRIVATE cPerg   	:= "CTR114"

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

wnrel :="CTBR114"

Pergunte("CTR114",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01  	      	// Data Inicial                          ³
//³ mv_par02            // Data Final                            ³
//³ mv_par03            // Moeda?                                ³
//³ mv_par04			// Set Of Books				    	     ³
//³ mv_par05			// Tipo Lcto? Real / Orcad / Gerenc / Pre³
//³ mv_par06  	        // Pagina Inicial                        ³
//³ mv_par07            // Pagina Final                          ³
//³ mv_par08            // Pagina ao Reiniciar                   ³
//³ mv_par09            // So Livro/Livro e Termos/So Termos     ³
//³ mv_par10            // Imprime Balancete                     ³
//³ mv_par11            // Imprime Plano de contas               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

If mv_par10 = 1
	Pergunte("CTR040",.T.)
	Pergunte("CTR114",.F.)	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par04)
	lRet := .F.
Else
	aSetOfBook := CTBSetOf(mv_par04)
EndIf

If lRet
	aCtbMoeda	:= CtbMoeda(mv_par03)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lRet := .F.
	EndIf	
EndIf

If !lRet	
	Set Filter To
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR114Imp(@lEnd,wnRel,cString,aSetOfBook,aCtbMoeda)})
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTR114IMP ³ Autor ³ Simone Mie Sato       ³ Data ³ 03/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do Diario Geral aglutinado por conta.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ CTR114Imp(lEnd,wnRel,cString,aSetOfBook,aCebMoeda)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅ±±
±±³Parametros ³ ExpL1   - A‡ao do Codeblock                                ³±±
±±³           ³ ExpC1   - T¡tulo do relat¢rio                              ³±±
±±³           ³ ExpC2   - Mensagem                                         ³±±
±±³           ³ ExpA1   - Matriz ref. Config. Relatorio                    ³±±
±±³           ³ ExpA2   - Matriz ref. a moeda                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR114Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt
Local Cbcont
Local Cabec1		:= STR0007	//"            C O N T A                     H I S T O R I C O                        NUMERO                         V  A  L  O  R"
Local Cabec2		:= STR0008	//"D E B I T O          C R E D I T O                                                 LANCTO                      DEBITO        CREDITO"
Local Titulo		:= ""
Local i				:= 0

Local cPicture
Local cDescMoeda

Local cSeparador	:= ""
Local cMascara

Local cLote			:= ""
Local cSubLote		:= ""
Local cDoc			:= ""
Local cArqTmp
Local cCancel		:= STR0012 //"***** CANCELADO PELO OPERADOR *****"

Local lData			:= .T.
Local lFirst		:= .T.

Local nTotDiaD		:= 0
Local nTotDiaC		:= 0
Local nTotMesD		:= 0
Local nTotMesC		:= 0
Local nTotDeb		:= 0
Local nTotCred	 	:= 0
Local nDia
Local nMes

Local nTamDeb		:= 15			// Tamanho da coluna de DEBITO
Local nTamCrd		:= 14			// Tamanho da coluna de CREDITO

Local nColDeb		:= 102			// Coluna de impressao do DEBITO
Local nColCrd		:= 118			// Coluna de impressao do CREDITO
Local dDataFim		:= mv_par02
Local lImpLivro		:=.t., lImpTermos:=.f.								
Local nPagIni		:= mv_par06
Local nPagFim		:= mv_par07
Local nReinicia		:= mv_par08
Local nBloco		:= 0                       
Local nBlCount		:= 0
Local LIMITE		:= If(TAMANHO=="G",220,If(TAMANHO=="M",132,80))
Local nInutLin		:= 1
m_pag    := 1

CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
								
Private cMoeda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
cMoeda	:= mv_par03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando definicoes para impressao -> Decimais, Picture,   ³
//³ Mascara da Conta                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara := RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 	:= aSetOfBook[4]

Titulo		:= 	STR0009 + DTOC(mv_par01) + STR0010 +;
				DTOC(mv_par02) + STR0011 + cDescMoeda + CtbTitSaldo(mv_par05)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao   					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTBR420Raz(oMeter,oText,oDlg,lEnd,@cArqTmp,"                    ","ZZZZZZZZZZZZZZZZZZZZ",;
			cMoeda,mv_par01,mv_par02,aSetOfBook,.F.,mv_par05,"6",,,,,,,,)},;
			STR0003,STR0006)

dbSelectAre("cArqTmp")
SetRegua(Reccount())
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Termo / Livro                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case mv_par09==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par09==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par09==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase		

While lImpLivro .And. !Eof() .and. DTOS(cArqTmp->DATAL) <= DTOS(mv_par02)

	IF lEnd
		@Prow()+1, 0 PSAY cCancel 
		Exit
	EndIF

	nMes := Month(cArqTmp->DATAL)
		
	While ! Eof() .And. DTOS(cArqTmp->DATAL) <= DTOS(mv_par02) .And.;
		Month(cArqTMP->DATAL) == nMes

		nDia := Day(cArqTmp->DATAL)
		lData:= .T.		
		While !Eof() .And. DTOS(cArqTmp->DATAL) <= DTOS(mv_par02) .And.;
			Month(cArqTmp->DATAL) == nMes .And. Day(cArqTmp->DATAL) == nDia

			IF lEnd
				@Prow()+1, 0 PSAY cCancel 
				Exit
			EndIF

			IncRegua()

			cDoc 		:= cArqTmp->DOC
			cLote		:= cArqTmp->LOTE
			cSubLote	:= cArqTmp->SUBLOTE

			// Loop para imprimir mesmo lote / documento / continuacao de historico
			While !Eof() .And. cArqTmp->DOC == cDoc .And. cArqTmp->LOTE == cLote .And.;
					cArqTmp->SuBLOTE == cSubLote .And. DTOS(cArqTmp->DATAL) <= DTOS(mv_par02) .And.;
					Month(cArqTmp->DATAL) == nMes .And. Day(cArqTmp->DATAL) == nDia
		
				If li > 55
					li++
					//	Imprime "a transportar ----->" ao final da pagina
					If !lFirst .And. (nTotDiaD <> 0 .or. nTotDiaC <> 0)
						@li,055 PSAY OemToAnsi(STR0013)						// A transportar
						If nTotDiaD <> 0
							ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
						EndIf
						If nTotDiaC <> 0
							ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
						EndIf                                               
						li++
					EndIF             

					CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. EFETUA QUEBRA
					CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho)
					// Imprime "de transporte -------->" no inicio da pagina
					If !lFirst .And. (nTotDiaD <> 0 .or. nTotDiaC <> 0)
						li++
						@li,055 PSAY OemToAnsi(STR0014)
						If nTotDiaD <> 0
							ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
						EndIf
						If nTotDiaC <> 0
							ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
						EndIf                                               
						li+=2
					EndIF
					lFirst := .F.
				EndIF

				If lData
					li++
					@ li, 000 PSAY DTOC(cArqTmp->DATAL)
					li++
					lData := .F.
				EndIf
				
				EntidadeCTB(cArqTmp->CONTAD,li,00,20,.F.,cMascara,cSeparador)
				EntidadeCTB(cArqTmp->CONTAC,li,21,20,.F.,cMascara,cSeparador)
				
				@ li, 042 PSAY Substr(cArqTmp->HISTORICO,1,40)
				@ li, 083 PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA
				If cArqTmp->TIPO $ "13"
					ValorCTB(cArqTmp->LANCDEB,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
					nTotDeb 	+= cArqTmp->LANCDEB
					nTotDiaD	+= cArqTmp->LANCDEB
					nTotMesD	+= cArqTmp->LANCDEB
				EndIf
				If cArqTmp->TIPO $ "23"
					ValorCTB(cArqTmp->LANCCRD,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
					nTotCred += cArqTmp->LANCCRD
					nTotdiaC += cArqTmp->LANCCRD
					nTotMesC += cArqTmp->LANCCRD
				EndIf

				// Procura pelo complemento de historico
				dbSelectArea("CT2")
				dbSetOrder(10)
				If dbSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
					dbSkip()
					If CT2->CT2_DC == "4"
						While !Eof() .And. CT2->CT2_FILIAL == xFilial() 			.And.;
											CT2->CT2_LOTE == cArqTMP->LOTE 		.And.;
											CT2->CT2_SBLOTE == cArqTMP->SUBLOTE 	.And.;
											CT2->CT2_DOC == cArqTmp->DOC 			.And.;
											CT2->CT2_SEQLAN == cArqTmp->SEQLAN 	.And.;
											CT2->CT2_EMPORI == cArqTmp->EMPORI	.And.;
											CT2->CT2_FILORI == cArqTmp->FILORI	.And.;
											CT2->CT2_DC == "4" 					.And.;
										   DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)                        
							li++
							@ li, 042 PSAY Substr(CT2->CT2_HIST,1,40)
							dbSkip()
						EndDo	
					EndIf	
				EndIf	

				dbSelectArea("cArqTmp")
				dbSkip()
				li++				
			Enddo
		EndDO                               
		
		If lEnd
			Exit
		Endif	
		IF (nTotDiad+nTotDiac)>0
			li++
			@li,055 PSAY OemToAnsi(STR0015)			// Totais do Dia
			ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
			ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
			nTotDiaD	:= 0
			nTotDiaC	:= 0
			li+=2
		EndIF
	EndDO
	If lEnd
		Exit
	End	
	// Totais do Mes
	IF (nTotMesd+nTotMesc) > 0
		@li,055 PSAY OemToAnsi(STR0016)				// Totais do Mes
		ValorCTB(nTotMesD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
		ValorCTB(nTotMesC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
		nTotMesD := 0
		nTotMesC := 0
		li+=2
	EndIF
EndDO

IF (nTotDiad+nTotDiac)>0 .And. !lEnd
	// Totais do Dia - Ultimo impresso
	li++
	@li,055 PSAY OemToAnsi(STR0015)				// Totais do Dia
	ValorCTB(nTotDiaD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
	ValorCTB(nTotDiaC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
	li++

	// Totais do Mes - Ultimo impresso
	@li,055 PSAY OemToAnsi(STR0016)  			// Totais do Mes
	ValorCTB(nTotMesD,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
	ValorCTB(nTotMesC,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
	li++
EndIF

// Total Geral impresso
IF (nTotDeb + nTotCred) > 0 .And. !lEnd
	li++
	@li,055 PSAY OemToAnsi(STR0017)				// Total Geral
	ValorCTB(nTotDeb ,li,nColDeb,nTamDeb,nDecimais,.F.,cPicture,"1")
	ValorCTB(nTotCred,li,nColCrd,nTamCrd,nDecimais,.F.,cPicture,"2")
EndIF

nLinAst := GetNewPar("MV_INUTLIN",0)
If li < 55 .and. nLinAst <> 0 .and. !lEnd
	For nInutLin := 1 to nLinAst
		li++
		@li,00 PSAY REPLICATE("*",LIMITE)	
		If li == 55
			Exit
		EndIf
	Next
EndIf

If li <= 60 .and. !lEnd .and. !lImpTermos
	Roda(,,Tamanho)
EndIf

dbSelectarea("CT2")
dbSetOrder(1)
Set Filter To  

If mv_par10 == 1
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()
	If Select("cArqTmp") == 0
	   FErase(cArqTmp+GetDBExtension())
	   FErase(cArqTmp+OrdBagExt())
	EndIf	

	Ctbr040(wnRel)
	Pergunte( "CTR114", .F. )
EndIf
If mv_par11 == 1
	Ctbr010(wnRel,mv_par02,mv_par03)
Endif

If lImpTermos 							// Impressao dos Termos

	Pergunte( "CTR114", .F. )
	
	cArqAbert:=GetMv("MV_LDIARAB")
	cArqEncer:=GetMv("MV_LDIAREN")

	dbSelectArea("SM0")
	aVariaveis:={}

	For i:=1 to FCount()	
		If FieldName(i)=="M0_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		Else
            If FieldName(i)=="M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek(Padr( "CTR114", Len( X1_GRUPO ) , ' ' ) +"01")

	While SX1->X1_GRUPO == Padr( "CTR114", Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Diario Geral.") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqAbert#NIL
		ImpTerm(cArqAbert,aVariaveis,AvalImp(132))
	Endif

	If cArqEncer#NIL
		ImpTerm(cArqEncer,aVariaveis,AvalImp(132))
	Endif	 
Endif

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End

If Select("cArqTmp") <> 0
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()        
	If Select("cArqTmp") == 0
	 	FErase(cArqTmp+GetDBExtension())
    	FErase(cArqTmp+OrdBagExt())
   EndIf
EndIf	

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctbr114Flt³ Autor ³ Simone Mie Sato       ³ Data ³ 03/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Realiza a "filtragem" dos registros do Diario aglut. conta  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³Ctbr114Flt(oMeter,oText,oDlg,lEnd,cMoeda,dDataIni,dDataFim, ³±±
±±³           ³           cSaldo)   	        						   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oMeter 		= Objeto oMeter                                ³±±
±±³           ³ oText  		= Objeto oText                                 ³±±
±±³           ³ oDlg   		= Objeto oDlg                                  ³±±
±±³           ³ lEnd   		= Acao do Codeblock                            ³±±
±±³           ³ cMoeda 		= Moeda                                        ³±±
±±³           ³ dDataIni 	= Data Inicial                                 ³±±
±±³           ³ dDataFim 	= Data Final                                   ³±±
±±³           ³ cSaldo		= Tipo de Saldo                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctbr114Flt(oMeter,oText,oDlg,lEnd,cMoeda,dDataIni,dDataFim,cSaldo)

oMeter:nTotal := CT2->(RecCount())

dbSelectArea("CT2")
dbSetOrder(1)
MsSeek(xFilial()+dtos(dDataIni),.T.)

While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And. ;
	CT2->CT2_DATA >= dDataIni .And. CT2->CT2_DATA <= dDataFim 

	IF CT2->CT2_VALOR == 0 .Or. CT2->CT2_TPSALD != cSaldo .Or. CT2->CT2_MOEDLC <> cMoeda
		dbSkip()
		Loop
	EndIF

	If CT2->CT2_DC == "1"
		Ctbr420Grv(cMoeda,cSaldo,"1","6")
	ElseIf CT2->CT2_DC == "2"
		Ctbr420Grv(cMoeda,cSaldo,"2","6")
	ElseIf CT2->CT2_DC == "3"     
		Ctbr420Grv(cMoeda,cSaldo,"3","6")
	EndIf
	
	dbSelectArea("CT2")
	dbSetOrder(1)
	dbSkip()
Enddo

Return                        
