#INCLUDE "TMSA870.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Tmsa870  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 21/12/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetuar a transferencia a partir das solicitacoes incluidas.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa870()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa870

Local cFilMbrow		:= ""
Local cFilMbrPE		:= ""

PRIVATE aRotina		:= MenuDef()
PRIVATE cCadastro	:= STR0007 //"Transferencia de debito"

If Pergunte("TMA870",.T.)
	If MV_PAR01 == 1 // Apenas solicitacoes em aberto
		cFilMbrow := "DVX_SITSOL='1'"
	EndIf

	If ExistBlock("TM870FIL")
		cFilMbrPE := ExecBlock("TM870FIL",.F.,.F.)
		If(Valtype(cFilMbrPE) = "C") .And. !Empty(cFilMbrPE)
			cFilMbrow := cFilMbrPE
		EndIf
	EndIf

	dbSelectArea("DVX")
	mBrowse(6,1,22,75,"DVX",,,,,,Tmsa870Leg(),,,,,,,,cFilMbrow)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa870Apv³ Autor ³ Claudio D. de Souza   ³ Data ³ 14/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aprovar solicitacoes de transferencia de debito.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa630Apv(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa870Apv(cAlias,nReg,nOpc)

Local nOpcA   := 0
Local aTit    := {}
Local nX      := 0
Local nSaldo  := 0
Local aAcho   := {}
Local cFilDt6 := FwFilial("DT6")
Local lRet    := .T.
Local cTmsERP := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP
Local aFldDVX := {}
Begin Sequence

	// Apenas solicitacoes em aberto podem ser aprovadas.
	If DVX->DVX_SITSOL != "1"
		Help(" ",1,"FIN63004") //"Esta solicitacao ja esta aprovada!"
		Break // Vai para proxima linha apos o End Sequence
	Endif

	// Nao eh permitido aprovar transferencias de titulos solicitados para outra filial.
	If cFilAnt != DVX->DVX_FILDEB
		Help(" ",1,"TMSA87001",,	STR0008 + DVX->DVX_FILDEB + CHR(13)+; //"Transferencia solicitada para filial: "
										STR0009 + cFilAnt, 4 , 0 ) //"Filial atual: "
		Break // Vai para proxima linha apos o End Sequence
	Endif

	// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do DVX caso o DT6
	// seja exclusivo ou xFilial se o DT6 for compartilhado
	cFilDt6 := If(!Empty(cFilDt6), DVX->DVX_FILORIG,xFilial("DT6"))
	Posicione("DT6",1,cFilDt6+DVX->(DVX_FILDOC+DVX_DOC+DVX_SERIE),"DT6_CLIDEV")

	If cTmsERP == '1' //-- ERP Datasul
		lRet:= .T.
	Else
		dbSelectArea("SE1")
		dbSetOrder(2)
		If SE1->(MsSeek(xFilial("SE1")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+DT6->DT6_PREFIX+DT6->DT6_NUM))
			If SE1->E1_ORIGEM <> 'TMSA850' .And. SE1->E1_ORIGEM <> 'TMSA880'
				// Se o docto. ja foi faturado e com Solicitação de Transferencia permite aprovacao
				If !Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO)) .And. !Empty(DT6->DT6_NUMSOL)
					lRet:= .F.
				Else
					lRet:= .T.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		// Se o docto. ja foi faturado, avisa e nao permite aprovacao
		If !Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO)) .Or. Empty(DT6->DT6_NUMSOL)
			Help(" ",1,"FIN63003",,	"Fatura número " + DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO), 4 , 0 ) //"Ctrc ja faturado, ou numero de solicitacao em branco. Aprovacao nao permitida"
			Break // Vai para proxima linha apos o End Sequence
		EndIf
	Endif
	
	aFldDVX := ApBuildHeader("DVX", {"DVX_HISREJ"})
	For nX := 1 To Len(aFldDVX)
		aAdd(aAcho, aFldDVX[nX][2])
	Next

	aSize(aFldDVX, 0)
	aFldDVX := Nil

	nOpca := AxVisual(cAlias,nReg,nOpc,aAcho)

	If nOpcA == 1
		// Grava a aprovacao
		Processa( { || Tm870GrvApv() } )
	Endif

End Sequence
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tm870GrvAp³ Autor ³ Claudio D. de Souza   ³ Data ³ 11/03/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava a aprovacao da solicitacao de transferencia de debito.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tm870Grvapv()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tm870GrvApv

Local cFilDt6    := FwFilial("DT6")
Local lRet       := .T.
Local lAltDT6    := .T.
Local cFilDeb    := ""
Local cCliDev    := ""
Local cLojDev    := ""
Local cFilAlt    := ""
Local cCliAlt    := ""
Local cLojAlt    := ""
Local dVenAlt    := CtoD('  /  /  ')
Local cFilOld    := cFilAnt
Local cParcela   := Space(TamSx3("E1_PARCELA")[1])
Local nRecNoSe1  := 0
Local nX         := 0
Local nY         := 0
Local nSaldo     := 0
Local aRecno     := {}
Local aTit       := {}
Local cFilSe1    := xFilial("SE1")
Local lTM870GRV  := ExistBlock("TM870GRV")
Local lTM870ALT  := ExistBlock("TM870ALT")
Local cTmsERP    := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP

Private lMsErroAuto:= .F. // variavel interna da rotina automatica

//-- Ponto de entrada para definir se deve efetuar alteracoes no documento de frete.
If lTM870ALT
	lAltDT6 := ExecBlock("TM870ALT",.F.,.F.)
	If Valtype(lAltDT6) <> "L"
		lAltDT6 := .T.
	EndIf
EndIf

// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do DVX caso o DT6
// seja exclusivo ou xFilial se o DT6 for compartilhado
cFilDt6 := If(!Empty(cFilDt6), DVX->DVX_FILORIG,xFilial("DT6"))

DT6->(DbSetOrder(1)) //DT6_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE
If DT6->(MsSeek(cFilDt6+DVX->(DVX_FILDOC+DVX_DOC+DVX_SERIE)))
	BEGIN TRANSACTION
		If RecLock("DVX",.F.)
			DVX->DVX_SITSOL := "2" // Solicitacao aprovada
			DVX->DVX_USRAPV := RetCodUsr() // Aprovador
			DVX->DVX_APVREJ := dDataBase // Data de aprovacao
			DVX->(MsUnlock())

			cFilDeb := DT6->DT6_FILDEB
			cCliDev := DT6->DT6_CLIDEV
			cLojDev := DT6->DT6_LOJDEV
			cFilAlt := DVX->DVX_FILDEB
			cCliAlt := DVX->DVX_CLIDEV
			cLojAlt := DVX->DVX_LOJDEV
			dVenAlt := DVX->DVX_VENCTO

			// Grava a transferencia
			If RecLock("DT6",.F.)
				DT6->DT6_NUMSOL := " " // Limpa o numero para que ele seja possivel nova solicitacao de transferencia
				If lAltDT6
					DT6->DT6_FILDEB := DVX->DVX_FILDEB
					DT6->DT6_CLIDEV := DVX->DVX_CLIDEV
					DT6->DT6_LOJDEV := DVX->DVX_LOJDEV
					DT6->DT6_VENCTO := DVX->DVX_VENCTO
					DW3->(DbSetOrder(1))
					If DW3->(MsSeek(xFilial("DW3") + DVX->DVX_CLIDEV + DVX->DVX_LOJDEV + DT6->DT6_TIPTRA))
						DT6->DT6_FILNEG := DW3->DW3_FILNEG
					Else
						DT6->DT6_FILNEG := Iif(DT6->DT6_TIPFRE == "1",DT6->DT6_FILDOC,DT6->DT6_FILDES)
					EndIf
					Do Case
						Case DT6->DT6_CLIREM+DT6->DT6_LOJREM == DT6->DT6_CLIDEV+DT6->DT6_LOJDEV
							DT6->DT6_DEVFRE := "1"
						Case DT6->DT6_CLIDES+DT6->DT6_LOJDES == DT6->DT6_CLIDEV+DT6->DT6_LOJDEV
							DT6->DT6_DEVFRE := "2"
						Case DT6->DT6_CLICON+DT6->DT6_LOJCON == DT6->DT6_CLIDEV+DT6->DT6_LOJDEV
							DT6->DT6_DEVFRE := "3"
						Case DT6->DT6_CLIDPC+DT6->DT6_LOJDPC == DT6->DT6_CLIDEV+DT6->DT6_LOJDEV
							DT6->DT6_DEVFRE := "4"
						OtherWise
							DT6->DT6_DEVFRE := "5"
					EndCase
				EndIf
				DT6->(MsUnlock())

				//-- Ponto de entrada apos gravacao DT6
				If lTM870GRV
					ExecBlock("TM870GRV",.F.,.F.)
				EndIf

				If cTmsERP == '0' //-- ERP Protheus (SIGATMS x SIGAFIN)
					//--- Atualização do SE1, gerando um novo título com o mesmo número.
					dbSelectArea("SE1")
					dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If SE1->(MsSeek(xFilial("SE1")+cCliDev+cLojDev+DT6->DT6_PREFIX+DT6->DT6_NUM))
	
						cParcela := SE1->E1_PARCELA
						cTipo    := SE1->E1_TIPO
	
						While SE1->(!EOF()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SE1")+cCliDev+cLojDev+DT6->DT6_PREFIX+DT6->DT6_NUM
							If !(SE1->E1_TIPO $ MVABATIM) .OR. ;
								((SE1->E1_TIPO $ MVABATIM) .AND. !(SE1->E1_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVISABT+"/"+MVFUABT+"/"+MVI2ABT))
								Aadd(aRecno, SE1->(Recno()))
	
								nAbatim:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA, cFilSe1)
								nSaldo := (SE1->E1_SALDO - nAbatim)
								nSaldo += SE1->E1_SDACRES
								nSaldo -= SE1->E1_SDDECRE
	
								// Incrementa a parcela para que nao haja registro duplicado na filial Debito
								cParcela:= SE1->E1_PARCELA
							Endif
							SE1->(DbSkip())
						Enddo
	
						aSort(aRecno)
						// Transfere todos os titulos agregados
						nY := 1
						While nY <= Len(aRecno)
	
							SE1->(MsGoto(aRecno[nY]))
	
							// Guarda o Recno para baixar o titulo na filial de origem
							nRecNoSe1 := SE1->(Recno())
	
							aTit := {}
							For nX := 1 To SE1->(fCount())
								AADD(aTit, { SE1->(FieldName(nX)), SE1->(FieldGet(nX)), NIL } )
							Next
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_FILIAL"})
							If nX > 0
								aTit[nX][2] := cFilAlt // Codigo da filial que recebera o titulo
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_CLIENTE"})
							If nX > 0
								aTit[nX][2] := cCliAlt // Codigo do cliente que recebera o titulo
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_LOJA"})
							If nX > 0
								aTit[nX][2] := cLojAlt // Codigo da loja do cliente que recebera o titulo
							Endif
	
							//Nao Parcelado, altera a data do vencimento, caso contrário permanece a Data do Vencimento do título
							If Len(aRecno) == 1
								nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_VENCTO"})
								If nX > 0
									aTit[nX][2] := dVenAlt // Vencimento do Título
								Endif
								nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_VENCREA"})
								If nX > 0
									aTit[nX][2] := dVenAlt // Vencimento do Título
								Endif
							EndIf
	
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_DESDOBR"})
							If nX > 0
								aTit[nX][2] := "2" 
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_NUMSOL"})
							If nX > 0
								aTit[nX][2] := "" 
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_TIPO"})
							If nX > 0
								cTipo := aTit[nX][2]
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_APLVLMN"})
							If nX > 0
								If(Empty(aTit[nX][2]),aTit[nX][2]:="1",.T.)
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_FLUXO"})
							If nX > 0
								If(Empty(aTit[nX][2]),aTit[nX][2]:="S",.T.)
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_MULTNAT"})
							If nX > 0
								If(Empty(aTit[nX][2]),aTit[nX][2]:="2",.T.)
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_MODSPB"})
							If nX > 0
								If(Empty(aTit[nX][2]),aTit[nX][2]:="1",.T.)
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_SCORGP"})
							If nX > 0
								If(Empty(aTit[nX][2]),aTit[nX][2]:="2",.T.)
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_RELATO"})
							If nX > 0
								If(Empty(aTit[nX][2]),aTit[nX][2]:="2",.T.)
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_PARCELA"})
							If nX > 0
								cParcela    := Soma1(cParcela)
								aTit[nX][2] := cParcela
							Endif
							nX := Ascan(aTit, {|e| AllTrim(e[1]) == "E1_RATFIN"})
							If nX > 0
								If(Empty(aTit[nX][2]),aTit[nX][2]:="2",.T.)
							Endif
	
							// Grava titulo na filial de debito destino
							SE1->( DbSetOrder(1) )
							MSExecAuto({|x, y| FINA040(x, y)}, aTit, 3)
							nY ++
	
							If lMsErroAuto
								MostraErro()
								DisarmTransaction()
								Break
							EndIf
	
							// Baixa do Titulo
							SE1->(MsGoto(nRecNoSe1))
							aTit := {}
							cFilAnt := cFilOld	// Altera para filial do titulo de origem para fazer a baixa  
	
							AADD(aTit , {"E1_PREFIXO"	, SE1->E1_PREFIXO	, NIL})
							AADD(aTit , {"E1_NUM"		, SE1->E1_NUM		, NIL})
							AADD(aTit , {"E1_PARCELA"	, SE1->E1_PARCELA	, NIL})
							AADD(aTit , {"E1_TIPO"		, SE1->E1_TIPO		, NIL})
							AADD(aTit , {"E1_CLIENTE"	, SE1->E1_CLIENTE	, NIL})
							AADD(aTit , {"E1_LOJA"		, SE1->E1_LOJA		, NIL})
							AADD(aTit , {"AUTMOTBX"		, "TRF"				, NIL})
							AADD(aTit , {"AUTDTBAIXA"	, dDataBase			, NIL})
							AADD(aTit , {"AUTDTCREDITO"	, dDataBase			, NIL})
							AADD(aTit , {"AUTHIST"		, STR0010 + cFilDeb + STR0011 + cFilAlt,NIL}) //"Bx. p/transf. da filial "###" p/"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Executa a Baixa do Titulo                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							MSExecAuto({|x, y| FINA070(x, y)}, aTit, 3)
	
							If lMsErroAuto
								MostraErro()
								DisarmTransaction()
								Break
							EndIf
						End
					EndIf
				EndIf
			Else
				lRet := .F.
				DisarmTransaction()
				Break
			Endif
		Else
			lRet := .F.
			DisarmTransaction()
			Break
		Endif
	END TRANSACTION
Else
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa630Rej ³ Autor ³ Claudio D. de Souza   ³ Data ³ 26/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rejeitar solicitacoes de transferencia de debito.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa630Rej(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa870Rej(cAlias,nReg,nOpc)

Local nOpcA
Local aAcho   := {}
Local aArea   := GetArea()
Local cFilDt6 := FwFilial("DT6")
Local aFldDVX 	:= {}
Local nX		:= 0

PRIVATE aMemos // Campos memos virtuais, utilizada na AxAltera.

// Apenas solicitacoes em aberto podem ser rejeitadas.
If DVX->DVX_SITSOL != "1"
	Help(" ",1,"FIN63001") //"Apenas solicitacoes em aberto podem ser rejeitadas"
	Return
Endif

// Nao eh permitido rejeitar transferencias de titulos solicitados para outra filial.
If cFilAnt != DVX->DVX_FILDEB
	Help(" ",1,"TMSA87001",,	STR0008 + DVX->DVX_FILDEB + CHR(13)+; //"Transferencia solicitada para filial: "
									STR0009 + cFilAnt, 4 , 0 ) //"Filial atual: "
	Return
Endif

aFldDVX := ApBuildHeader("DVX", {"DVX_HISTSO"})
For nX := 1 To Len(aFldDVX)
	aAdd(aAcho, aFldDVX[nX][2])
Next

aSize(aFldDVX, 0)
aFldDVX := Nil

aMemos := {{"DVX_CDHREJ","DVX_HISREJ"}}

nOpca := AxAltera(cAlias,nReg,nOpc,aAcho,{"DVX_HISREJ"})

If nOpcA == 1
	BEGIN TRANSACTION
		If RecLock("DVX",.F.)
			DVX->DVX_SITSOL := "3" // Solicitacao rejeitada
			DVX->DVX_USRAPV := RetCodUsr() // Rejeitado por
			DVX->DVX_APVREJ :=	dDataBase // Data de Rejeicao
			// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do DVX caso o DT6
			// seja exclusivo ou xFilial se o DT6 for compartilhado
			cFilDt6 := If(!Empty(cFilDt6), DVX->DVX_FILORIG,xFilial("DT6"))
			DT6->(DbSetOrder(1))
			If DT6->(MsSeek(cFilDt6+DVX->(DVX_FILDOC+DVX_DOC+DVX_SERIE))) .And.;
				RecLock("DT6",.F.)
				DT6->DT6_NUMSOL := " " // Limpa o numero para que ele seja possivel nova solicitacao de transferencia
				DT6->(MsUnlock())
			Endif
			DVX->(MsUnlock())
		Endif
	END TRANSACTION
EndIf
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa630Exc ³ Autor ³ Claudio D. de Souza   ³ Data ³ 27/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir solicitacoes de transferencia de debito em aberto. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa630Exc(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa870Exc(cAlias,nReg,nOpc)

Local cFilDt6 := FwFilial("DT6")

PRIVATE aMemos // Campos memos virtuais, utilizada na AxDeleta para excluir campos memo.

// Apenas solicitacoes em aberto podem ser excluidas.
If DVX->DVX_SITSOL != "1"
	Help(" ",1,"FIN63005") //"Apenas solicitacoes em aberto podem ser Excluidas"
	Return
Endif
aMemos := {	{"DVX_CDHSOL","DVX_HISTSOL"},;
			{"DVX_CDHREJ","DVX_HISREJ" }}

nOpca := AxDeleta(cAlias,nReg,nOpc)

If nOpcA == 2
	DT6->(DbSetOrder(1))
	// Filial a ser utilizada para localizar o titulo, FILIAL ORIGEM do DVX caso o DT6
	// seja exclusivo ou xFilial se o DT6 for compartilhado
	cFilDt6 := If(!Empty(cFilDt6), DVX->DVX_FILORIG,xFilial("DT6")) 
	If DT6->(MsSeek(cFilDt6+DVX->(DVX_FILDOC+DVX_DOC+DVX_SERIE))) .And.;
		RecLock("DT6",.F.)
		DT6->DT6_NUMSOL := " " // Limpa o numero para que ele seja possivel nova solicitacao de transferencia
		DT6->(MsUnlock())
	Endif
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa870Pes³ Autor ³ Claudio D. de Souza   ³ Data ³ 21/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa870Pes( )                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA870 / TMS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tmsa870Pes

Local nRecNo := RecNo()

AxPesqui()
If Eof() // Se estiver fora do filtro, posiciona no registro anterior antes da pesquisa
	Help(" ",1,"CPOFILTER") //"Nao foi encontrado nenhum registro referente a sua pesquisa"
	DbGoto(nRecNo)
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa630Leg    ³ Autor ³ Claudio D. de Souza ³ Data ³ 27.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA870                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tmsa870Leg(nReg)

Local aLegenda := {	{"BR_VERDE",    STR0012 },; //"Solicitacao em aberto"
					{"BR_AZUL",     STR0013 },; //"Solicitacao aprovada"
					{"BR_VERMELHO", STR0014 } } //"Solicitacao rejeitada"
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { "DVX_SITSOL == '1'"	, aLegenda[1][1] } )
	Aadd(uRetorno, { "DVX_SITSOL == '2'"	, aLegenda[2][1] } )
	Aadd(uRetorno, { "DVX_SITSOL == '3'"	, aLegenda[3][1] } )
Else
	BrwLegenda(cCadastro, STR0006,aLegenda) //"Legenda"
Endif

Return uRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional.                              ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina	:=	{	{STR0001, "Tmsa870Pes"	, 0, 1, 0, .F.},; //"Pesquisar"
						{STR0002, "AxVisual"	, 0, 2, 0, NIL},; //"Visualizar"
						{STR0003, "Tmsa870Apv"	, 0, 2, 0, NIL},; //"Aprovar"
						{STR0004, "Tmsa870Rej"	, 0, 4, 0, NIL},; //"Rejeitar"
						{STR0005, "Tmsa870Exc"	, 0, 5, 0, NIL},; //"Excluir"
						{STR0006, "Tmsa870Leg"	, 0, 5, 0, .F.} } //"Legenda"

If ExistBlock("TM870MNU")
	ExecBlock("TM870MNU",.F.,.F.)
EndIf

Return(aRotina)

