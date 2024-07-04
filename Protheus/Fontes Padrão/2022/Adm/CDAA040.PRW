#include "Protheus.ch"
#include "CDAA040.ch"

Static _oCDAA0401 := Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CDAA040  ³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 12/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de fechamento de mes, controle de Royalty         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico - controle de royalty (direito autoral)         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CDAA040
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL nOpca := 0, oDlg
	LOCAL nQtdPed, lSomar, cSaveMenuh, nSoma, nQtde, cSavTit
	LOCAL aCRA:={ STR0016, STR0017, STR0018 } //"Confirma"###"Redigita"###"Abandona"
	LOCAL cCadastro := OemtoAnsi(STR0001) //"Fechamento do Mes D.A."
	Local cPerg := "CDA040" +Replicate(" ",10 - Len("CDA040"))
	Local cTabela := SuperGetMv("MV_CDANUME",.F.,"H2")
	
	PRIVATE aRotina := { { STR0002, "AxPesqui", 0 , 1},; //"Pesquisar"
	{ STR0003,"AxVisual", 0 , 2},; //"Visualizar"
	{ STR0004,   "AxInclui", 0 , 3} } //"Incluir"
	
	Private cNumero
	Private cTipoTit, cNaturez
	
	PRIVATE nKey := 0         // Aceita as teclas
	PRIVATE tOpc := ""
	PRIVATE inclui:=.F.
	PRIVATE altera:=.F.
	PRIVATE nPosBco:=1
	PRIVATE nX := 0
	PRIVATE cCpoBase:=""
	Private lGeraTit := .T.
	
	aSays := {}
	
	AADD(aSays,OemToAnsi( STR0005 ) ) //"  Este programa tem como objetivo executar o fechamento do mes dos calculos do D.A."
	AADD(aSays,OemToAnsi( STR0006 ) ) //"atualizar os saldos de adiantamentos e acumulados do contrato e opcionalmente gerar"
	AADD(aSays,OemToAnsi( STR0007 ) ) //"os titulos a pagar aos autores. " 
	AADD(aSays, "" )
	AADD(aSays,OemToAnsi( STR0020 ) +DTOC(GetMV("MV_CDAFECH")) )	//"Data do ultimo fechamento :"
	aButtons := {}

	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, Iif( CD040Ok(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tela de processamento.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FormBatch( cCadastro, aSays, aButtons ,,200,510)
		
	If (nOpca == 1)
	
		cTipoTit := mv_par01
		cNaturez := mv_par02
		lGeraTit := Iif(mv_par04==1,.T.,.F.)
		
		If lGeraTit
			cNumero := CD040NoDoc()
			
			If ValType( cNumero ) == "L"
				nOpcA := 3
			Endif
		Endif
	EndIf
	
	If nOpcA == 1
		Processa({|lEnd| CD040Processa()},STR0001,(STR0008),.F.) //"Fechamento de mes"###"Fechando o mes ..."
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna numero do titulo (royalty) p/ o arq. de Tabelas      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA != 3
		If lGeraTit
			FwPutSX5(,cTabela,'RYI',cNumero,cNumero,cNumero,cNumero)
		End If
	Endif
Return .T.
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CD040PROCE³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 12/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento - fechamento do mes do direito autoral.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CDAA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CD040Processa()
Local cAlias := Alias()
Local dPerIni, dPerFim
Local aRecAH6	:= {}   
Local	aStru	:=	{}
Local	cAls	:=	""    
Local bTitForn := GetNewPar ("MV_TITFORN", .T.)
Local lAglutina := GetNewPar ("MV_AGLUCDA", .F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Periodo de processamento, do dia 01 do mes e ano informados  ³
	//³ ate o ultimo dia do mes.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dPerIni := Ctod("01/"+StrZero(Month(mv_par03), 2)+"/"+Str(Year(mv_par03)))
	dPerFim := LastDay(dPerini)
	
	If dPerFim <= GetMv("MV_CDAFECH")
		Help(" ",1,"CD040Fecha")   // fechamento invalido.
		Return .F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aTabela := CD040AbrIR()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa a regua de processamento.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua( AH6->(RecCount()) * 3 )

	If lAglutina .And. !bTitForn
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao da tabela temporaria para que o titulo sejam algutinado os titulos por Fornecedor    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd (aStru, {"FORNEC",		"C",	TamSx3("AH6_FORNEC")[1],0})
		aAdd (aStru, {"LOJA",		"C",	TamSx3("AH6_LOJAFO")[1],0})
		aAdd (aStru, {"DTFIM",		"C",	08,	0})
		aAdd (aStru, {"MOEDA",		"C",	01,	0})
		aAdd (aStru, {"DTPFIM",		"D",	08,	0})
		aAdd (aStru, {"VTOTAL",		"N",	11,	2})
		aAdd (aStru, {"VIRRF",		"N",	11,	2})
		aAdd (aStru, {"VMOEDA",		"N",	01,	0})
		aAdd (aStru, {"PRAZO",		"C",	TamSx3("AH1_PRZOPA")[1],0})

		If _oCDAA0401 <> Nil
			_oCDAA0401:Delete()
			_oCDAA0401:=Nil
		EndIf

		_oCDAA0401 := FWTemporaryTable():New("TRT")
		_oCDAA0401:SetFields(aStru)
		_oCDAA0401:AddIndex("1",{"FORNEC","LOJA","DTFIM","MOEDA","PRAZO"})
		_oCDAA0401:Create()

	EndIf

	
	dbSelectArea("AH4")
	dbSetOrder(3)     // AH4_FILIAL+AH4_PRODUT+AH4_FORNEC+AH4_LOJAFO+Dtos(AH4_DTPRES)
	
	dbSelectArea("AH5")
	dbSetOrder(3)   // AH5_FILIAL+AH5_PRODUT+AH5_FORNEC+AH5_LOJAFO+Dtos(AH5_DTPRES)+Str(AH5_FXFINA,9)+Str(AH5_PRECOU,14,3)
	
	dbSelectArea("AH6")
	dbSetOrder(2)      // AH6_FILIAL + AH6_FORNEC + AH6_LOJAFO + AH6_PRODUT
	dbSeek(xFilial())
	While AH6->(!Eof()) .And. xFilial("AH6") == AH6->AH6_FILIAL
		
		cForneced := AH6->AH6_FORNEC + AH6->AH6_LOJAFO
		cProduto  := AH6->AH6_PRODUT
		nTotForne := 0
		cChave:= Iif(bTitForn,AH6->AH6_FORNEC + AH6->AH6_LOJAFO, AH6->AH6_FORNEC + AH6->AH6_LOJAFO + AH6->AH6_PRODUT)
        bWhile := { || Iif(bTitForn,AH6->AH6_FORNEC + AH6->AH6_LOJAFO, AH6->AH6_FORNEC + AH6->AH6_LOJAFO + AH6->AH6_PRODUT) }
        
		While cChave == Eval(bWhile) .And. AH6->(!Eof()).And. xFilial("AH6")==AH6->AH6_FILIAL
			
			IncProc()
			
			If AH6->AH6_DTPRXD > dPerFim .Or. !Empty(AH6->AH6_DTPRES)
				dbSelectArea("AH6")
				dbSkip()
				Loop
			Endif
			
			cProduto  := AH6->AH6_PRODUT
			nValAcum  := 0
			nQtdAcum  := 0
			nValIRRF  := 0
			nSaldo    := 0
			nSalQtd   := 0
			
			dbSelectArea("AH1")
			dbSeek( xFilial("AH1") + cProduto + cForneced )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o periodo est  dentro do contrato.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Eof() .Or. (dPerFim > LastDay(AH1->AH1_DATAFI) .And. ;
				!Empty(AH1->AH1_DATAFI)) .Or. dPerFim < AH1->AH1_INICVI
				dbSelectArea("AH6")
				dbSkip()
				Loop
			Endif
			
			cProdMast := AH1->AH1_MASTER
			
			dbSelectArea("SB1")
			dbSeek( xFilial("SB1") + cProduto )
			If Eof()
				dbSelectArea("AH6")
				dbSkip()
				Loop
			Endif
			
			dbSelectArea("AH8")
			dbSeek( xFilial() + cProdMast )
			If Eof()
				dbSelectArea("AH6")
				dbSkip()
				Loop
			Endif
			
			cMdaRoy := AllTrim(Str(AH1->AH1_MOEDRO,2))
			cMdaOri := Iif(AH1->AH1_MOEDA == "1","1",GetMv("MV_MCUSTO"))
			
			If Type("AH6->AH6_LICITA") != "U"
				dbSelectArea("AH4")
				dbSeek( xFilial("AH4") + cProduto + cForneced + Dtos(dPerFim) + AH6->AH6_LICITA )
				
				dbSelectArea("AH5")
				dbSeek( xFilial() + cProduto + cForneced + Dtos(dPerFim) )
				While AH5->(!Eof()) .And. xFilial("AH5") + cProduto + cForneced == ;
					AH5->AH5_FILIAL + AH5->AH5_PRODUT + AH5->AH5_FORNEC + AH5->AH5_LOJAFO ;
					.And. AH5->AH5_DTPRES == dPerFim
					
					If AH5->AH5_LICITA == AH6->AH6_LICITA
						nQtdAcum += AH5->AH5_QTDACU
						If AH5->AH5_PERCDA == 0.00 .Or. AH1->AH1_MOEDRO == 1
							nValAcum += AH5->AH5_VALORD
						Else
							nValAcum += Round(xMoeda(AH5->AH5_VALORD,Val(cMdaOri),Val(cMdaRoy),AH4->AH4_DTPREST),2)
						Endif
					Endif
					dbSelectArea("AH5")
					dbSkip()
				End
				
			Else
				dbSelectArea("AH4")
				dbSeek( xFilial("AH4") + cProduto + cForneced + Dtos(dPerFim) )
				
				dbSelectArea("AH5")
				dbSeek( xFilial() + cProduto + cForneced + Dtos(dPerFim) )
				While AH5->(!Eof()) .And. xFilial("AH5") + cProduto + cForneced == ;
					AH5->AH5_FILIAL + AH5->AH5_PRODUT + AH5->AH5_FORNEC + AH5->AH5_LOJAFO ;
					.And. AH5->AH5_DTPRES == dPerFim
					
					nQtdAcum += AH5->AH5_QTDACU
					If AH5->AH5_PERCDA == 0.00 .Or. AH1->AH1_MOEDRO == 1
						nValAcum += AH5->AH5_VALORD
					Else
						nValAcum += Round(xMoeda(AH5->AH5_VALORD,Val(cMdaOri),Val(cMdaRoy),AH4->AH4_DTPREST),2)
					Endif
					dbSelectArea("AH5")
					dbSkip()
				End
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Geracao de titulo no contas a pagar.                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc()                
			                      
			nValAcum := Round(nValAcum,2)
			If nValAcum >= 0
				If nValAcum > AH1->AH1_SALDOA
					nTotForne += nValAcum - AH1->AH1_SALDOA
				Endif
			Else
				nTotForne += nValAcum
			Endif
			

			dbSelectArea("AH1")
			If nValAcum > 0
				nSaldo := AH1->AH1_SALDOA - nValAcum
			Else
				nSaldo := AH1->AH1_SALDOA
			Endif
			If AH1->AH1_SALDQT > 0
				nSalQtd := AH1->AH1_SALDQT - nQtdAcum
			Else
				nSalQtd := AH1->AH1_SALDQT
			Endif
			
			RecLock("AH1",.F.)
			Replace AH1_SALDOA With Iif(nSaldo  > 0, nSaldo,  0)
			Replace AH1_SALDQT With Iif(nSalQtd > 0, nSalQtd, 0)
			Replace AH1_QTDEVD With AH1_QTDEVD + nQtdAcum
			If AH6->AH6_DTPRXD <= dPerFim
				Replace AH1_DTULTP With AH6->AH6_DTPRXD
			Endif
			MsUnLock()


			dbSelectArea("AH6")
			If AH6->AH6_DTPRXDA <= dPerFim
				dSavUlt	  := AH6->AH6_DTULTIM
				dUltPrest := AH6->AH6_DTPRXDA
				dPrxPrest := CD030DtPrx(dUltPrest,cProduto,cForneced)
				RecLock("AH6",.F.)
				Replace AH6_DTULTIM With dUltPrest, AH6_DTPRXDA With dPrxPrest
				MsUnLock()
			Endif

			aAuxArea	:= AH6->(GetArea())
			RecLock("AH6",.T.)
			AH6->AH6_FILIAL := xFilial("AH6")
			AH6->AH6_PRODUT := AH1->AH1_PRODUT
			AH6->AH6_FORNEC := AH1->AH1_FORNEC
			AH6->AH6_LOJAFO := AH1->AH1_LOJAFO
			AH6->AH6_DTPRXD := CD030DtPrx(CTOD(SPACE(08)),cProduto,cForneced)
			AH6->AH6_DTULTIM:= dSavUlt
			If (AH6->(FieldPos("AH6_CODANT")) > 0)
				AH6->AH6_CODANT := AH1->AH1_CODANT
			EndIf
			AH6->AH6_DTPRXDA := dPrxPrest
			AH6->AH6_DTPRES	:= dPerFim
			If nValAcum > AH1->AH1_SALDOA
				AH6->AH6_VALORD := nValAcum - AH1->AH1_SALDOA

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula IR se a natureza mandar  				    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValIRRF := 0
				
				SED->( dbSeek( xFilial("SED") + cNaturez ) )
				If !SED->(Eof()) .And. SED->ED_CALCIRF == "S"
					SA2 -> ( dbSeek( xFilial("SA2") + cForneced ) )
					If SA2->A2_TIPO == "F"   // pessoa fisica
						nValIRRF := CD040CalIR(AH6->AH6_VALORD,aTabela,dPerFim,.F.)
						If SA2->A2_TXTRIBU > 0.00
							nValIRRF := nValIRRF + Round(nTotForne * SA2->A2_TXTRIBU / 100,2)
						Endif
					Endif
				Endif
	
				AH6->AH6_DESCIR := nValIrrf
			EndIf
			MsUnLock()
			aAdd(aRecAH6,AH6->(RecNo()) )
			RestArea(aAuxArea)
			dbSkip()
		End
		
		If lGeraTit
			If nTotForne > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula IR se a natureza mandar  					  	  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValIRRF := 0
				
				SED->( dbSeek( xFilial("SED") + cNaturez ) )
				If !SED->(Eof()) .And. SED->ED_CALCIRF == "S"
					SA2 -> ( dbSeek( xFilial("SA2") + cForneced ) )
					If SA2->A2_TIPO == "F"   // pessoa fisica
						nValIRRF := CD040CalIR(nTotForne,aTabela,dPerFim,.F.)
					Endif
					If SA2->A2_TXTRIBU > 0.00
						nValIRRF := nValIRRF + Round(nTotForne * SA2->A2_TXTRIBU / 100,2)
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Geracao de titulo no contas a pagar.                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nMoedTit := Iif( AH1->AH1_MOEDA == "1", 1, Val( GetMv("MV_MCUSTO") ) )
				cTipoTit := mv_par01
				If lAglutina .And. !bTitForn					
					If !TRT->(DbSeek (AH1->AH1_FORNEC+AH1->AH1_LOJAFO+dtos(dPerFim)+Alltrim(Str(nMoedTit))+AH1->AH1_PRZOPA))
						RecLock ("TRT", .T.)
						TRT->FORNEC	:=	AH1->AH1_FORNEC   
						TRT->LOJA	:=	AH1->AH1_LOJAFO
						TRT->MOEDA  :=  Alltrim(Str(nMoedTit))
						TRT->DTFIM	:=	dtos(dPerFim)
						TRT->DTPFIM	:=	dPerFim
						TRT->VTOTAL	:=	nTotForne
						TRT->VIRRF	:=	nValIrrf
						TRT->VMOEDA	:=	nMoedTit
						TRT->PRAZO	:=	AH1->AH1_PRZOPA
					Else
						RecLock ("TRT", .F.) 
						TRT->VTOTAL	+=	nTotForne
						TRT->VIRRF	+=	nValIrrf
					EndIf     
				
					MsUnLock()
				Else
			  		CD040CtPag(nTotForne,nValIRRF,AH1->AH1_FORNEC,AH1->AH1_LOJAFO,nMoedTit,AH1->AH1_PRZOPA,"CDAA040",dPerFim,aRecAH6)
	            EndIf
			Else
				If nTotForne < 0 .And. (!Empty(GetMv("MV_CDATNEG",,"")))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quando o total do DA para o fornecedor for menor que zero    ³
					//³ so ira gerar titulo caso o parametro MV_CDATNEG esteja       ³
					//³ preenchido com o tipo do titulo a ser gerado                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTotForne := -1*nTotForne
					nValIRRF  := 0
					nMoedTit  := Iif( AH1->AH1_MOEDA == "1", 1, Val( GetMv("MV_MCUSTO") ) )
					cTipoTit  := GetMv("MV_CDATNEG")
					If lAglutina .And. !bTitForn					
						If !TRT->(DbSeek (AH1->AH1_FORNEC+AH1->AH1_LOJAFO+dtos(dPerFim)+Alltrim(Str(nMoedTit))+AH1->AH1_PRZOPA))
							RecLock ("TRT", .T.)
							TRT->FORNEC	:=	AH1->AH1_FORNEC   
							TRT->LOJA	:=	AH1->AH1_LOJAFO 
							TRT->MOEDA  :=  Alltrim(Str(nMoedTit))
							TRT->DTFIM	:=	dtos(dPerFim)
							TRT->DTPFIM	:=	dPerFim
							TRT->VTOTAL	:=	nTotForne
							TRT->VIRRF	:=	nValIrrf
							TRT->VMOEDA	:=	nMoedTit
							TRT->PRAZO	:=	AH1->AH1_PRZOPA
						Else
							RecLock ("TRT", .F.) 
							TRT->VTOTAL	+=	nTotForne
							TRT->VIRRF	+=	nValIrrf
						EndIf     
						MsUnLock()
					Else
					  	CD040CtPag(nTotForne,nValIRRF,AH1->AH1_FORNEC,AH1->AH1_LOJAFO,nMoedTit,AH1->AH1_PRZOPA,"CDAA040",dPerFim,aRecAH6)
		            EndIf

				EndIf

				If ExistBlock("DIRA170")
					ExecBlock("DIRA170", .F., .F. ,{nTotForne,dPerFim})
				Endif
			Endif
		Endif
		
		dbSelectArea("SB1")
		dbSeek( xFilial("SB1") + cProduto )
		
		If Type('B1_QTDINIC') <> 'U' .and. Type('B1_QTDACUM') <> 'U'
			RecLock("SB1",.F.)
			Replace B1_QTDINIC With B1_QTDACUM
			MsUnLock()
		EndIf
		
		AH1 -> ( dbSeek( xFilial("AH1")+cProduto+cForneced))
		
		#IFNDEF TOP
			dbSelectArea("AH8")
			dbSeek( xFilial("AH8") + AH1->AH1_MASTER )
			RecLock("AH8",.F.)
			Replace AH8_QTDINI With AH8_QTDACU
			MsUnLock()
		#ENDIF
		
		dbSelectArea("AH6")
		aRecAH6	:= {}
		
	End                   
	
	If lAglutina .And. !bTitForn    
		dbSelectArea("TRT")
		TRT->(dbGoTop())
	    While !Eof()
			CD040CtPag(TRT->VTOTAL,TRT->VIRRF,TRT->FORNEC,TRT->LOJA,TRT->VMOEDA,TRT->PRAZO,"CDAA040",TRT->DTPFIM,aRecAH6)
			TRT->(dbSkip())		            
		End
	EndIf	
	
	
	#IFDEF TOP
		dbSelectArea("AH8")
		dbGoTop()
		While !Eof()
			RecLock("AH8",.F.)
			Replace AH8_QTDINI With AH8_QTDACU
			MsUnLock()
			dbSkip()
		End
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava a data de fechamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX6")
	PutMv("MV_CDAFECH", Dtoc(dPerFim))

	dbSelectArea("AH8")
	dbGoTop()
	While AH8->(!Eof())
		RecLock("AH8",.F.)
		Replace AH8_QTDINIC With AH8_QTDACUM
		MsUnLock()
		dbSkip()
	End
	
	If lAglutina .Or. _oCDAA0401 <> Nil
		dbSelectArea("TRT")
		dbCloseArea()
		_oCDAA0401:Delete()
		_oCDAA0401:=Nil
	EndIf

	dbSelectArea( cAlias )
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ CD040Ok  ³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 05/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Mensagem de OK antes de executar o processamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CDAA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CD040Ok()

If !CD040Perg()
	Return .F.
EndIf

Return (MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0010))) //"Confirma fechamento do Dir.Autoral ?"###"Atencao"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CD040CtPag³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 13/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera titulo de prestacao de D.A. no contas a pagar.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CD040CtPag(ExpN1,ExpN2,ExpC1,ExpC2,ExpN3,ExpC3,ExpC4)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := valor do titulo a ser gerado                      ³±±
±±³          ³ ExpN2 := valor do IRRF do titulo                           ³±±
±±³          ³ ExpC1 := codigo do fornecedor                              ³±±
±±³          ³ ExpC2 := loja do fornecedor                                ³±±
±±³          ³ ExpN3 := numero da moeda do titulo                         ³±±
±±³          ³ ExpC3 := condicao de pagamento                             ³±±
±±³          ³ ExpC4 := nome do programa origem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CDAA040 e CDAA020                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CD040CtPag(nValAcum,nValIRRF,cCodForn,cLojaFor,nMoedTit,cCodPraz,cPrograma,dDataTit,aRecAH6)
Local nI		:=	0	
Local aArea		:=	GetArea()	
Local cHistorico:=	""
Local aGrvSe2	:=	{}

Private lMsErroAuto := .F.

DEFAULT aRecAH6	:=	{}

aVenc := Condicao((nValAcum),cCodPraz,,dDataTit)

SA2 -> ( dbSeek( xFilial("SA2") + cCodForn + cLojaFor ) )

cHistorico := Iif(cPrograma=="CDAA020","Adiantamento","Pagamento de D.A.")

For nI := 1 To Len(aVenc)
	nMoedTit := Iif(ValType(nMoedTit) == "N", nMoedTit, Val(nMoedTit))
	
	aGrvSe2	:=	{	{ "E2_FILIAL"	, xFilial("SE2")											, Nil },;
						{ "E2_PREFIXO"	, Iif(SA2->A2_TIPO=="X","RYE","RYI")				, Nil },;
						{ "E2_NUM"		, cNumero													, Nil },;
						{ "E2_TIPO"		, cTipoTit													, Nil },;
						{ "E2_NATUREZ"	, cNaturez													, Nil },;
						{ "E2_PORTADO"	, SA2->A2_BANCO				   						, Nil },;
						{ "E2_FORNECE"	, cCodForn				 									, Nil },;
						{ "E2_LOJA"   	, cLojaFor													, Nil },;
						{ "E2_NOMFOR"	, SA2->A2_NREDUZ 											, Nil },;
						{ "E2_EMISSAO"	, dDataTit													, Nil },;
						{ "E2_VENCTO"	, aVenc[nI][1]												, Nil },;
						{ "E2_VENCORI"	, aVenc[nI][1]												, Nil },;
						{ "E2_VENCREA"	, DataValida(aVenc[nI][1])								, Nil },;
						{ "E2_VALOR"  	, aVenc[nI][2]												, Nil },;
						{ "E2_SALDO"  	, aVenc[nI][2]												, Nil },;
						{ "E2_BCOPAG" 	, SA2->A2_BANCO					     					, Nil },;
						{ "E2_EMIS1"  	, dDataBase													, Nil },;
						{ "E2_MOEDA"	, nMoedTit												, Nil },;
						{ "E2_VLCRUZ" 	, xMoeda((aVenc[nI][2]-nValIRRF),nMoedTit,1,dDataTit)	, Nil },;
						{ "E2_HIST"   	, cHistorico												, Nil },;
						{ "E2_PARCELA"	, StrZero(nI, Len(SE2->E2_PARCELA))	 			, Nil },; 			
						{ "E2_ORIGEM" 	, cPrograma											  		, Nil },;
						{ "E2_IRRF" 	, nValIRRF											  		, Nil }	}
 
	If cTipoTit $ MVPAGANT .And. !Empty(SA2->A2_BANCO)
		SA6->(DbSetOrder(1))
		If SA6->(DbSeek(xFilial("SA6")+SA2->(A2_BANCO+A2_AGENCIA+A2_NUMCON))) .And. SA6->A6_MOEDA == nMoedTit
			Aadd(aGrvSe2, {"AUTBANCO",   SA2->A2_BANCO,   Nil})
			Aadd(aGrvSe2, {"AUTAGENCIA", SA2->A2_AGENCIA, Nil})
			Aadd(aGrvSe2, {"AUTCONTA",   SA2->A2_NUMCON,  Nil})
		EndIf					
	EndIf	
	
	lMsErroAuto := .F.
	MsExecAuto({ | a,b,c | Fina050(a,b,c) },aGrvSe2,,3)
	If lMsErroAuto
		Help(" ", 1, "ERROGERACP")
		Exit
	Endif
Next

cNumero := StrZero(Val(cNumero)+1,TamSX3("F2_DOC")[1])

RestArea(aArea)
Return(SE2->E2_PREFIXO + SE2->E2_NUM)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CD040NoDoc³ Autor ³ Claudinei M. Benzi    ³ Data ³ 11.02.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recebe o proximo numero do contas a pagar com o prefixo de ³±±
±±³          ³ royalty (RYI).                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CDAA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CD040NoDoc()
	Local oDlg,cCadastro := OemToAnsi(STR0011),cVarQ:="  ",oQual //"Titulo"
	Local oOk 		:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
	Local aTitRoy   := {}, nOPca := 0
	PRIVATE lSX5Troca := .F.
	PRIVATE cSerie := "RYI"
	
	vNumero :=""
	dbSelectArea("SX5")
	dbSeek( xFilial()+GetMv("MV_CDANUME"))
	While xFilial()+GetMv("MV_CDANUME") == X5_FILIAL+X5_TABELA
		If SX5->X5_DESCRI = "*"
			dbSkip()
			Loop
		Endif
		AADD(aTitRoy,{Trim(X5_CHAVE),StrZero(Val(X5_DESCRI),TamSX3("F2_DOC")[1])})
		dbSkip()
	End
	
	If Len(aTitRoy) == 0
		Help(" ",1,"CD040FLOCK")
		Return(.T.)
	Endif
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From 10,30 To 19,68 OF oMainWnd
//	@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER OemToAnsi(STR0012),OemToAnsi(cCadastro) SIZE 130,42 ON DBLCLICK (aTitRoy:=aSX5Troca(oQual:nAt,aTitRoy,20),oQual:Refresh()) NOSCROLL //"Serie"
	@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER OemToAnsi(STR0012),OemToAnsi(cCadastro) SIZE 130,42  NOSCROLL //"Serie"
	oQual:SetArray(aTitRoy)
	oQual:bLine := { || {aTitRoy[oQual:nAT,1],aTitRoy[oQual:nAT,2]}}
	DEFINE SBUTTON FROM 51,108		TYPE 1 ACTION (cNumero := aTitRoy[oQual:nAt,2], ;
	cSerie := aTitRoy[oQual:nAt,1], ;
	nOpca := 1,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg
	IF nOpca == 0
		Return (.t.)
	Endif
	
	If !lSX5Troca
		vNumero := cNumero
	Endif
	If Len(aTitRoy) == 0
		Help(" ",1,"CD040FLOCK")
		Return(.T.)
	Endif
	
	dbSeek( xFilial()+GetMv("MV_CDANUME") + cSerie )
	nRegx5:=Recno()
	dbSeek(xFilial()+GetMv("MV_CDANUME") + cSerie )
	If Found() .And. Val(SubStr(X5_DESCRI,1,Len(cNumero))) != Val(vNumero) .Or. X5_DESCRI == "*"
		Help(" ",1,"OUTRAEST")
		MsUnlock()
		Return(.T.)
	Endif
Return cNumero


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CD040AbrIR³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 27/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que le o arquivo de I.R.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpA1 := CD040AbrIR()                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := array com a tabela do I.R. pessoa fisica          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CDAA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CD040AbrIR()
	Local nBytes := 0, nHdlIrf
	Local aTabela  := {}, cArquivo, nTamArq, xBuffer
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura do arquivo configurador                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArquivo:="SIGAADV.IRF"
	IF !FILE(cArquivo)
		Help(" ",1,"CD040NTab")
		Return aTabela
	Else
		nHdlIrf:=FOPEN(cArquivo,0+64)
	EndIF
	
	nTamArq:=FSEEK(nHdlIrf,0,2)	// Verifica tamanho do arquivo
	FSEEK(nHdlIrf,0,0)	     	// Volta para inicio do arquivo
	
	While nBytes<nTamArq
		
		xBuffer:=Space(40)
		FREAD(nHdlIrf,@xBuffer,40)
		IF Empty(xBuffer)
			AADD(aTabela, { 0, 0, 0 } )
		Else
			AADD(aTabela,{ Val(SubStr(xBuffer,01,15)), Val(SubStr(xBuffer,17,6)), ;
			Val(SubStr(xBuffer,24,15)) } )
		EndIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Este IF Len( aTabela ) == 5 foi implementado pelo fato  ³
		//³ de que a grava‡Æo feita pelo for windows dava uma       ³
		//³ diferen‡a de 1 byte na grava‡Æo do final do arquivo.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aTabela ) == 5
			Exit
		Endif
		nBytes+=40
	EndDO
Return aTabela


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CD040CalIR³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 27/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o valor de I.R. para pessoa fisica, conforme tabela.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 := CD040CalIR(ExpN2,ExpA1)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := valor calculado do I.R.                           ³±±
±±³          ³ ExpN2 := valor total a ser calculado o I.R.                ³±±
±±³          ³ ExpA1 := array com a tabela do I.R.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CDAA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CD040CalIR(nValAcum, aTabela, dPerFim, lGrava)
	Local nValIRRF := 0
	Local cAlias   := Alias(), nRecNoAH4 := AH4->(Recno())
	Local nOrdAH4  := AH4->(IndexOrd())
	Local nValAc   := 0
	Local i := 0
	
	lGrava := Iif(lGrava==Nil,.F.,lGrava)
	If !lGrava
		nValAc := nValAcum
	Else
		dbSelectArea("AH4")
		dbSetOrder(3)   // AH4_FILIAL + AH4_PRODUT + AH4_FORNEC + AH4_LOJAFO + Dtos(AH4_DTPREST)
		dbSeek(xFilial("AH4") + AH1->AH1_PRODUT + AH1->AH1_FORNEC + AH1->AH1_LOJAFO + Dtos(dPerFim))
		
		While AH4->(!Eof()) .And. xFilial("AH4") + AH1->AH1_PRODUT + AH1->AH1_FORNEC + ;
			AH1->AH1_LOJAFO == AH4->AH4_FILIAL + AH4->AH4_PRODUT + AH4->AH4_FORNEC + ;
			AH4->AH4_LOJAFO .And. AH4->AH4_DTPREST <= dPerFim
			
			nValAc += AH4->AH4_VALORDA
			
			dbSelectArea("AH4")
			dbSkip()
		End
	Endif
	For i := 1 To Len(aTabela)
		If nValAc <= aTabela[i][1]
			nValIRRF := (nValAc * aTabela[i][2]/100) - aTabela[i][3]
			Exit
		Endif
	Next
	
	nValIRRF := Iif(nValIRRF < 0,0,nValIRRF)
	
	If lGrava
		dbSelectArea("AH4")
		dbSeek(xFilial("AH4") + AH1->AH1_PRODUT + AH1->AH1_FORNEC + AH1->AH1_LOJAFO + Dtos(dPerFim))
		While AH4->(!Eof()) .And. xFilial("AH4") + AH1->AH1_PRODUT + AH1->AH1_FORNEC + ;
			AH1->AH1_LOJAFO == AH4->AH4_FILIAL + AH4->AH4_PRODUT + AH4->AH4_FORNEC + ;
			AH4->AH4_LOJAFO .And. AH4->AH4_DTPRES <= dPerFim
			
			dbSelectArea("AH4")
			dbSkip()
		End
	Endif
	
	dbSelectArea("AH4")
	dbSetOrder( nOrdAH4 )
	dbGoTo( nRecNoAH4 )
	dbSelectArea( cAlias )
Return nValIRRF

Function CD040Perg()
Local lRet	:= .T.
Local lOk	:= .F.

While !lOk 
	If !Pergunte("CDA040",.T.)
		lRet := .F.
		Exit		
	EndIf
	lOk := ExistCpo("SX5","05"+mv_par01)
    If lOk
		lOk := ExistCpo("SED",mv_par02)
	EndIf
End

Return lRet
