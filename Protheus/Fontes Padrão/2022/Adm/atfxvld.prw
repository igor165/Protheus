#Include "Protheus.Ch"
#Include "AtfxVld.Ch"

Static __lStruPrj // Verifica se existe a estrutura de projetos no ambiente
Static __lBpiAtf	:= NIL
Static __lMargem	:= NIL
Static __lProvis	:= NIL
Static __lATF012SAL
STATIC lMultMoed := FindFunction("AtfMoedas")

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ATFVISUAL  ³ Autor ³ Vinicius Barreira     ³ Data ³ 27/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona o SN1 em fun‡Æo do SN3 para visualiza‡Æo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ATFVISUAL                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AtivoFixo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFVISUAL(cAlias,nReg,nOpc)
Return ATFXVISUAL(cAlias,nReg,nOpc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ATFXVISUAL ³ Autor ³ Vinicius Barreira     ³ Data ³ 27/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona o SN1 em fun‡Æo do SN3 para visualiza‡Æo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ATFVISUAL                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AtivoFixo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFXVISUAL(cAlias,nReg,nOpc)
	
	Local nSavRec := 0
	Local nOrdem  := 0
	Local cChave

	dbSelectArea("SN3")

	nSavRec := Recno()
	nOrdem  := IndexOrd()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o SN1 em fun‡Æo do SN3.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SN1")
	dbSetOrder(1)
	cChave := SN3->N3_CBASE + SN3->N3_ITEM
	If Alltrim(FunName()) == "ATFA030" .And. Trim(GetMv("MV_ATFCONT"))="N"
		cChave := SN4->N4_CBASE + SN4->N4_ITEM
	Endif
	dbSeek( xFilial("SN1") + cChave )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa fun‡Æo de visualiza‡Æo.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FWExecView("","ATFA012",/*Por padr? a opera?o ?Veiw*/, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura posi‡Æo do SN3.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SN3")
	dbSetOrder( nOrdem )
	dbGoTo( nSavRec )

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AtfJaCalc  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 04.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna se o Bem/Item/Tipo ja efetuou algum Calc. Depreciacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaAtf                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfJaCalc()
Return ATFXJACALC()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ATFXJACALC ³ Autor ³ TOTVS SA              ³ Data ³ 10.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna se o Bem/Item/Tipo ja efetuou algum Calc. Depreciacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaAtf                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFXJACALC()

	Local lRet := .T., nPosTipo	:= Ascan(aHeader, {|x| x[2] == "N3_TIPO"})

	If ALTERA .And. nPosTipo > 0
		SN4->(DbSeek(	xFilial() + M->N1_CBASE + M->N1_ITEM + aCols[n][nPosTipo], .T.))
		While 	SN4->N4_FILIAL = xFilial("SN4") .And. SN4->N4_CBASE = M->N1_CBASE .And.;
		SN4->N4_ITEM = M->N1_ITEM .And. SN4->N4_TIPO = aCols[n][nPosTipo] .And.;
		!	SN4->(Eof())
			If SN4->N4_OCORR <> "05"
				lRet := .F.
				Exit
			Endif
			SN4->(DbSkip())
		EndDo
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFXVlBxN1 ºAutor  ³Alvaro Camillo Neto º Data ³  08/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe algum SN3 Ativo para o bem e caso        º±±
±±º          ³não tenha, marca o SN1 como baixado                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFXVlBxN1(cBase,cItem,dBaixa)
	Local aArea    := GetArea()
	Local aAreaSN3 := SN3->(GetArea())
	Local aAreaSN1 := SN1->(GetArea())
	Local lRet	   := .T.
	Local lBaixa   := .F.

	SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
	SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

	If SN1->(dbSeek(xFilial("SN1") + cBase + cItem )) 
		If SN3->(dbSeek(xFilial("SN3") + cBase + cItem ))
			lBaixa := .T.
			While SN3->(!EOF()) .And. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) == xFilial("SN3") + cBase + cItem
				If SN3->N3_BAIXA == "0" .Or. Empty(SN3->N3_BAIXA) // Bem Ativo
					lBaixa := .F.
					Exit 
				EndIf
				SN3->(dbSkip())
			EndDo
			If lBaixa
				RecLock("SN1",.F.)
				SN1->N1_BAIXA	:= dBaixa
				MsUnLock()
			EndIf
		EndIf 
	EndIf                 

	RestArea(aAreaSN1)
	RestArea(aAreaSN3)
	RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtfBloqueio³ Autor ³ Wagner Mobile Costa   ³ Data ³ 16/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica o bloqueio do bem ou do grupo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AtfBloqueio(cChave)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave  - > Chave de busca no grupo de bens                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfBloqueio(cChave, dRetorno)

	Local cAlias := Alias(), lRet := .T.

	DbSelectArea("SN1")
	If N1_CBASE+N1_ITEM <> cChave
		MsSeek(xFilial() + cChave)
	Endif

	If !Empty(SN1->N1_DTBLOQ) .And. Dtos(SN1->N1_DTBLOQ)>= Dtos(dDataBase)
		lRet := .F.
	Endif

	If lRet .And. ! Empty(SN1->N1_GRUPO) .And. SNG->NG_GRUPO <> SN1->N1_GRUPO
		DbSelectArea("SNG")
		MsSeek(xFilial() + SN1->N1_GRUPO)
	Endif

	If 	lRet .And. ! Empty(SN1->N1_GRUPO) .And. ! Empty(SNG->NG_DTBLOQ) .And.;
	Dtos(SNG->NG_DTBLOQ)>= Dtos(dDataBase)
		lRet := .F.
	Endif

	If ! Empty(SN1->N1_DTBLOQ) .And. dRetorno # Nil
		dRetorno := SN1->N1_DTBLOQ
	ElseIf ! Empty(SN1->N1_GRUPO) .And. SNG->NG_GRUPO = SN1->N1_GRUPO .And. ! Empty(SNG->NG_DTBLOQ)
		dRetorno := SNG->NG_DTBLOQ
	Endif

	DbSelectArea(cAlias)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFCanCalcºAutor  ³ Marcelo Akama      º Data ³  28/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se pode efetuar o calculo da depreciacao          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFCanCalc(dUltProc, cAuxMes, cAuxDia)

	Local aArea		:= GetArea()
	Local lRet     	:= .T.
	Local nYear		:= 0
	Local cCalcDep	:= GetNewPar("MV_CALCDEP",'0')

	Default dUltProc := GetNewPar("MV_ULTDEPR", STOD("19800101"))
	Default cAuxMes  := "12"
	Default cAuxDia  := "31"

	If cCalcDep == '1'
		nYear 	:= Year(dUltProc)
		lRet 	:= dUltProc == Stod( cValtoChar(nYear)+cAuxMes+cAuxDia )  
	EndIf

	If !lRet
		Help(" ",1,"ATFHIBRER"+cCalcDep)
	EndIf

	RestArea(aArea)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtfVldMoedºAutor  ³ ------------------ º Data ³  ---------- º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o conteudo do SX6 quando preenchido com moeda       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfVldMoed(cMoeda)

	Local aGetArea	:= GetArea()	// Salva ambiente
	Local nQuantas	:= 5			// Valor Default
	Local lRet	:= .T.
	Local nMoeda	:= Val(cMoeda)

	//********************************
	// Controle de multiplas moedas  *
	//********************************
	nQuantas	:= CtbMoedas()
	nQuantas	:= If( nQuantas < 5, 5, nQuantas )

	DbSelectArea("SX3")
	dbsetOrder(2)
	If !dbSeek("N3_VORIG"+Alltrim(Str(nQuantas)))
		nQuantas	:= 5 // Caso não encontre o campo da maior moeda trata o padrao
	EndIf

	IF ValType(nMoeda) != "N"
		lRet:= .F.
	ELSEIF ValType(nMoeda) == "N" .AND. nMoeda <= 0
		lRet := .F.
	ELSEIF ValType(nMoeda) == "N" .AND. SX3->(!dbSeek("N3_VORIG"+Alltrim(cMoeda)))
		lRet := .F.
	ENDIF

	RestArea( aGetArea )
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldDeprec ³ Autor ³ Jair RIbeiro          ³ Data ³ 27/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Valida criterio de depreciacao				              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ VldDeprec()								                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldDeprec()

	Local cVar 			:= ReadVar()
	Local cConteudo		:= &(ReadVar())
	Local lRet			:= .T.
	Local nPosN3Tipo	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_TIPO"})
	Local nPosN3TpDp	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_CRIDEPR"})
	Local nPosN3ClDp	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_CALDEPR"})
	Local nPosFNGTip	:= aScan(aHeader,{|x| Alltrim(x[2]) == "FNG_TIPO"})
	Local nPosFNGTpD	:= aScan(aHeader,{|x| Alltrim(x[2]) == "FNG_CRIDEP"})
	Local nPosFNGClD	:= aScan(aHeader,{|x| Alltrim(x[2]) == "FNG_CALDEP"})
	Local nLin			:= n
	Local cTypesNM		:= IIF(lIsRussia,"|" + AtfNValMod({1,2}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main and recoverable models

	If "TIPO" $ cVar
		If "FNG" $ cVar .and. nPosFNGTip != 0 .and. nPosFNGTpD != 0
			If Alltrim(aCols[nLin,nPosFNGTpD]) $ "03|04"
				If !(Alltrim(cConteudo) $ "10|12"+cTypesNM)
					Help(" ",1,"VldDeprec",,STR0001,1,0)  //"Critério de depreciação não é valido para o tipo de ativo em questão"
					lRet:= .F.
				EndIf
			EndIf
		EndIf
	ElseIf "CRIDEP" $ cVar
		If "N3" $ cVar .and. nPosN3Tipo != 0 .and. nPosN3TpDp != 0 .and. nPosN3ClDp != 0
			If !(Alltrim(aCols[nLin,nPosN3Tipo]) $ "10|12"+cTypesNM) .and. !Empty(aCols[nLin,nPosN3Tipo])
				If Alltrim(cConteudo) $ "03|04"
					Help(" ",1,"VldDeprec",,STR0001,1,0)  //"Critério de depreciação não é valido para o tipo de ativo em questão"
					lRet:= .F.
				EndIf
			EndIf
			If !(Alltrim(cConteudo) $ "03|04")
				aCols[nLin,nPosN3ClDp] := space(TamSx3("N3_CALDEPR")[1])
			EndIf
		ElseIf "FNG" $ cVar .and. nPosFNGTip != 0 .and. nPosFNGTpD != 0
		If !(Alltrim(aCols[nLin,nPosFNGTip]) $ "10|12"+cTypesNM) .and. !Empty(aCols[nLin,nPosFNGTip])
				If Alltrim(cConteudo) $ "03|04"
					Help(" ",1,"VldDeprec",,STR0001,1,0)  //"Critério de depreciação não é valido para o tipo de ativo em questão"
					lRet:= .F.
				EndIf
			EndIf
			If !(Alltrim(cConteudo) $ "03|04")
				aCols[nLin,nPosFNGClD] := space(TamSx3("N3_CALDEPR")[1])
			EndIf
		EndIf
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldTipDepr³ Autor ³ Jair RIbeiro          ³ Data ³ 27/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ When para campos de criterio e calendario de depreciacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ VldTipDepr(cDescCpoCr,cDescCpoCl)		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDescCpoCr: Campo criterio N3_CRIDEPR,NG_CRIDEPR,FNG_TIDEP ³±±
±±³          ³ cDescCpoCl: Campo Calendario N3_CALDEPR,NG_CALDEPR,        ³±±
±±³          ³ FNG_CALDEP		                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldTipDepr(cDescCpoCr,cDescCpoCl)

	/*
	Premissa 01: Caso nao seja definido um conteudo para o parametro da funcao - cCampo o retorno da função sera .F.

	Premissa 02: Como a função poderá ser chamada de um cadastro simples (Enchoice) ou de uma Grid (MsGetDados) o conteudo
	do campo deverá ser recuperado com &(ReadVar())
	
	Premissa 03: No tratamento do campo _CALDEPR, deverá ser avaliado se a validação está em um Grid ou em uma Enchoice para que o
	conteúdo do campo _TIPDEPR seja recuperado adequadamente, pois para este campo nesta situacao nao podera ser usado o &(ReadVar()),
	pois ele não é o campo posicionado no momento.
	
	1.	Se o campo a ser validado for _TIPDEPR:
	1.1.	Verificar se o conteudo do parâmetro MV_TIPDEPR é diferente de "9" - Ficha do Ativo, aonde:
	1.1.1.	MV_TIPDEPR == 9 ' Retorno .T.
	1.1.2.	MV_TIPDEPR != 9 ' Retorno .F.
	
	2.	Se o campo a ser validado for _CALDEPR:
	2.1.	Verificar se o conteúdo do parâmetro MV_TIPDEPR é diferente de "9" - Ficha do Ativo, aonde:
	2.1.1.	MV_TIPDEPR == 9 ' Testa próxima situação
	2.1.2.	MV_TIPDEPR != 9 ' Retorno .F.
	
	2.2.	Verificar se o conteúdo do campo _TIPDEPR contém "03" - Exercício Completo ou "04" - Próximo Trimestre.
	2.2.1.	_TIPDEPR $ ("03|04") ' Retorno .T.
	2.2.2.	!(_TIPDEPR $ ("03|04")) ' Retorno .F.
	*/
	
	Local lRet			:= (Alltrim(SuperGetMv("MV_TIPDEPR",.F.,"")) == "9")
	Local aAreaSx3		:= SX3->(GetArea())
	Local nPos			:= If(Type('aHeader')== "A",Ascan(aHeader,{|x| Alltrim(x[2]) == cDescCpoCr}),0)
	Local nPosTp		:= If(Type('aHeader')== "A",Ascan(aHeader,{|x| Alltrim(x[2]) == "N3_TIPO"}),0)
	Default cDescCpoCr	:= ""
	Default cDescCpoCl	:= ""

	//Tipo 11 deve ter o mesmo calendario do tipo 01 e nao pode ser alterado
	If nPosTp > 0
		If (Alltrim(aCols[n,nPosTp]) $ "|11")
			lRet := .F.
		EndIf
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cDescCpoCr))
		If Empty(cDescCpoCr)
			lRet:=.F.
		EndIf
	Else
		lRet:=.F.
	EndIf
	If "_CALDEP" $ cDescCpoCl .and. lRet
		If SX3->(DbSeek(cDescCpoCl))
			If nPos > 0
				If Type('aCols') == "A"
					If !(Alltrim(aCols[n,nPos]) $ "03|04")
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
			ElseIf !(ALLTRIM(M->&(cDescCpoCr)) $ "03|04")
				lRet := .F.
				M->&(cDescCpoCr) := Space(TamSx3("NG_CRIDEPR")[1])
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
	SX3->(RestArea(aAreaSx3))
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |VldCriDeprºAutor  ³Jair Ribeiro	     º Data ³  06/24/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida campo N3_CRIDEPR                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VldCriDepr()
	
	Local lRet	:= .T.

	lRet := VldDeprec()

	If lRet
		lRet := AF012VLAEC()
	EndIf
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AtfVlTpSal  ³ Autor ³ Totvs                   ³ Data ³ 15/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o tipo de saldo informado                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTpSaldo - tipo do saldo a ser validado.                        ³±±
±±³          ³ cCharEsp - se permite o caracter * ou nao.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AtfVlTpSal( cTpSaldo, lCharEsp, lHelp )
	
	Local lret			:= .F.
	Default lCharEsp	:= .F.
	Default lHelp   	:= .T.


	If cTpSaldo == "*" .AND. lCharEsp
		lret := .T.
	Else
		lret := !Empty( Tabela( "SL", cTpSaldo, .F. ) )
	EndIf

	If !lRet .And. lHelp
		Help(" ",1,"ATFSLDINV")
	EndIf

Return lret

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFSALDEPRºAutor  ³Microsiga           º Data ³  10/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o tipo de saldo e tipo depreciacao no linha ok      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cTipo: Tipo do Ativo                                        º±±
±±º          ³cTpSald: Tipo de Saldo                                      º±±
±±º          ³cTpDepr: Metodo de depreciacao                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFSALDEPR(cTipo,cTpSald,cTpDepr)
	
	Local aConfig	:= {}
	Local aArea		:= {}
	Local aAreaGen	:= {}
	Local nPosConfig:= 0
	Local lRet		:= .T.

	Local cAllTipos	:= ""

	Default cTipo	:= ""
	Default cTpSald	:= ""
	Default cTpDepr	:= ""

	If __lATF012SAL == NIL
		__lATF012SAL := ExistBlock("ATF012SAL")  //verifica se existe PE
	EndIf

	If !Empty(cTipo)

		// Para todos os paise os tipos gerenciais podem ter todos os métodos de depreciação disponíveis

		AAdd(aConfig,	{"10|12|13|14|15|16|17"					,"*"		,"*"		})

		Do Case
			Case cPaisLoc == "ANG"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7"		})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			aAdd(aConfig,	{"41|42|43"						,"1|"		,"1|"		})

			Case cPaisLoc == "ARG"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7|8|9"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			aAdd(aConfig,	{"10|12|14|15|13"					,"*"		,"*"		})

			Case cPaisLoc == "BOL"
			fvldTipAct(@aConfig)

			Case cPaisLoc == "COL"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7"		})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			aAdd(aConfig,	{"50|51|52|53|54"				,"1|"		,"1|"		})

			Case cPaisLoc == "COS"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|3|6|7"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})

			Case cPaisLoc == "PTG"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7|B"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			aAdd(aConfig,	{"33"							,"1|"		,"1|7|B"	})

			Case cPaisLoc == "BRA"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7|8"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})

			Case cPaisLoc == "RUS"
			// CAZARINI - 10/03/2017 - add new valuations type
			aConfig[1][1] 	:= aConfig[1][1] + '|' + AtfNValMod({1,2,3,4},'|')  

	//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"		,"*"		,"1|2|N|F"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			OtherWise
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7"		})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})

		EndCase

		If __lATF012SAL      //se existe PE ATF012SAL
			aAux := ExecBlock("ATF012SAL",.F.,.F.,{aConfig})
			If ValType(aAux) == "A" .And. Len(aAux) > 0
				aConfig := aClone(aAux)
			EndIf
		EndIf

		nPosConfig := aSCan(aConfig,{|aX| AllTrim(cTipo) $ aX[1]})

		If nPosConfig != 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida Tipo de Saldo	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If !Empty(cTpSald) .and. aConfig[nPosConfig,2] != "*" // * = Todos Permitidos
				If !(cTpSald $ aConfig[nPosConfig,2])
					lRet := .F.
					Help(" ",1,"ATFNOTPSALDO",,STR0002,1,0)    //"Tipo de saldo invalido para o tipo de ativo em questao"
				EndIf

			ElseIf !Empty(cTpSald)
				aArea 	:= GetArea()
				aAreaGen := SX5->(GetArea())
				DbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				SX5->(MsSeek(xFilial("SX5")+"SL"))
				Do While !SX5->(EOF()) .and. xFilial("SX5")+"SL" == SX5->X5_FILIAL+SX5->X5_TABELA
					cAllTipos += IiF(Empty(cAllTipos),'','|')+ALLTRIM(SX5->X5_CHAVE)
					SX5->(DbSkip())
				EndDo
				SX5->(RestArea(aAreaGen))
				RestArea(aArea)
				If !(cTpSald $ cAllTipos)
					lRet := .F.
					Help(" ",1,"ATFNOTPSALDO",,STR0002,1,0)    //"Tipo de saldo invalido para o tipo de ativo em questao"
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida Metodo de depreciacao	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  !Empty(cTpDepr) .and. aConfig[nPosConfig,3] !=	 "*" .and. lRet
				If !(cTpDepr $ aConfig[nPosConfig,3])
					lRet := .F.
					Help(" ",1,"ATFNOTPDEPR",,STR0003,1,0) //"Metodo de depreciacao invalido para o tipo de ativo em questao"
				EndIf
			ElseIf !Empty(cTpDepr)
				aAreaGen	:= {}
				cAllTipos	:= ""
				aArea 		:= GetArea()
				aAreaGen 	:= SN0->(GetArea())

				DbSelectArea("SN0")
				SN0->(dbSetOrder(1))
				SN0->(MsSeek(xFilial("SN0")+"04"))
				Do While !SN0->(EOF()) .and. xFilial("SN0")+"04" == SN0->N0_FILIAL+SN0->N0_TABELA
					cAllTipos += IiF(Empty(cAllTipos),'','|')+ALLTRIM(SN0->N0_CHAVE)
					SN0->(DbSkip())
				EndDo
				SN0->(RestArea(aAreaGen))
				RestArea(aArea)
				If !(cTpDepr $ cAllTipos)
					lRet := .F.
					Help(" ",1,"ATFNOTPDEPR",,STR0003,1,0) //"Metodo de depreciacao invalido para o tipo de ativo em questao"
				EndIf
			EndIf
		Else
			lRet := .F.
			Help(" ",1,"ATFNOTIPOATF",,STR0004,1,0)     //"Tipo de ativo informado inválido"
		EndIf
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFXVerPrjºAutor  ³Alvaro Camillo Neto º Data ³  10/27/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o ativo está relacionado com um projeto do     º±±
±±º          ³ imobilizado                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFXVerPrj(cBase,cItem, lHelp)
	
	Local lRet 		:= .F.
	Local aArea	 	:= GetArea()
	Local aAreaSN1	:= SN1->(GetArea())
	Local aAreaFND	:= {}
	Local aAreaFNJ	:= {}
	Local cCodProj	:= ""
	Local cCodRev	:= ""

	Default lHelp := .F.

	If __lStruPrj == Nil
		__lStruPrj := ATFXStruPrj()
	EndIf

	If __lStruPrj .And. !( Alltrim(FunName()) $ "ATFA430/ATFA004/ATFA460" )

		SN1->(DBSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
		If SN1->(MsSeek( xFilial("SN1") + cBase + cItem))

			aAreaFND := FND->(GetArea())

			FND->(DBSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM

			If FND->(MsSeek( xFilial("FND") + SN1->(N1_PROJETO + N1_PROJREV + N1_PROJETP + N1_PROJITE) ))
				lRet		:= .T.
				cCodProj	:= SN1->N1_PROJETO
				cCodRev		:= SN1->N1_PROJREV
			EndIf

			RestArea(aAreaFND)

			//-----------------------------------------------------------------------
			// Valida se o ativo esta relacionado ao projeto como Ativos de Execucao
			//-----------------------------------------------------------------------
			aAreaFNJ := FNJ->(GetArea())

			FNJ->(DbSetOrder(3)) //FNJ_FILIAL+FNJ_CBAEXE+FNJ_ITEXE+FNJ_TAFEXE+FNJ_SLDEXE+FNJ_CODPRJ+FNJ_REVIS+FNJ_ETAPA+FNJ_ITEM+FNJ_LINHA+FNJ_TAFPRJ+FNJ_SLDPRJ
			If FNJ->(DbSeek( XFilial("FNJ") + SN1->(N1_CBASE+N1_ITEM)))
				lRet		:= .T.
				cCodProj	:= FNJ->FNJ_CODPRJ
				cCodRev		:= FNJ->FNJ_REVIS
			EndIf

			RestArea(aAreaFNJ)

		EndIf

	EndIf

	If lRet .And. lHelp
		Help(" ",1,"ATFPROJ",,STR0005 + cCodProj  + STR0006 + cCodRev + STR0007 ,1,0) //"Esse ativo está relacionado com o projeto : "##"  revisão:"##", por favor utilizar a rotina de Projeto Imobilizado para a manutenção "
	EndIf

	RestArea(aAreaSN1)
	RestArea(aArea)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFXStruPrjºAutor  ³Alvaro Camillo Neto º Data ³  25/07/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o ativo está relacionado com um projeto do     º±±
±±º          ³ imobilizado                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFXStruPrj()

	Local lRet := .T.

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFValInd   ºAutor  ³Renan Guedes      º Data ³  11/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a existência de uma taxa para o índice do bem        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFValInd(lBlind)

	Local lRet			:= .F.
	Local aTxDepr		:= {0,0,0,0,0}
	Local nX			:= 0

	Default lBlind		:= .F.

	If ValType(lBlind) != "L"
		lBlind := .F.
	EndIf

	ATFCalcIn(@aTxDepr)

	For nX := 1 To Len(aTxDepr)
		If aTxDepr[nX] > 0
			lRet := .T.
		EndIf
	Next nX

	If !lRet
		If !lBlind
			Help("",1,"ATFNOTAXIN")		//"Não existe(m) taxa(s) válida(s) para o índice e período da depreciação."##"Cadastre a(s) taxa(s) para o índice e período a depreciar."
		EndIf
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtClssVerº Autor ³ Marylly A. Silva   º Data ³  29/05/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que avalia o conteúdo do campo "Classificação" do   º±±
±±º          ³ ativo e verificação se a classificação é do tipo que sofre º±±
±±º          ³ depreciação ou não						                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ativo Fixo                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AtClssVer(cClassif)

	Local lRet		:= .F.
	Local cTpDepr	:= " |N|D|I|O|T|E"
	Local cTpNDepr	:= "S|A|C|P|R"
	Local lAtClssVer

	/*
	* cClassif
	* "N" -> Ativo Imobilizado
	* "S" -> Patrimônio Líquido
	* "A" -> Amortização
	* "C" -> Capital Social
	* "P" -> Patrimônio (Prejuízo)
	* "I" -> Ativo Intangível
	* "D" -> Ativo Diferido
	* "O" -> Orçamento
	* "V" -> Provisão
	* "T" -> Custos de Transação
	*/
	If cClassif != Nil
		// Ponto de entrada exclusivo para relatório ATFR110
		If FunName() == "ATFR110"
			If ExistBlock("AFCLDEPR")
				lAtClssVer := ExecBlock("AFCLDEPR",.F.,.F.,{cClassif})
			EndIf
		EndIf
		// Se não passar pelo PE, executa tratamento padrão
		If lAtClssVer == Nil
			// Classificações de Bens que sofrem o processo de depreciação
			If cClassif $ cTpDepr
				lRet := .T. // Sim, deprecia
				// Classificação de Bens que NÃO sofrem o processo de depreciação
			ElseIf cClassif $ cTpNDepr
				lRet := .F. // Não, NÃO deprecia
			EndIf
		Else
			lRet := lAtClssVer
		EndIf
	EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AFVldBpi   ³Autor  ³Mauricio Pequim Jr     ³ Data ³ 24/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a implementacao da Baixa de Provisao de Imobilizados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//BPI
Function AFVldBpi()

	If __lBpiAtf == NIL
		__lBpiAtf := ATFXStruPrj()
	Endif

Return __lBpiAtf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FaVRelPrj  ³Autor  ³Mauricio Pequim Jr     ³ Data ³ 24/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o relacionamento do imobilizado a um processo de    ³±±
±±³          ³ execucao de provisao de projeto                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//BPI
Function FaVRelPrj(nIndice,cChave)

	Local lRet := .F.
	Local aAreaFNJ := FNJ->(GetArea())

	DEFAULT nIndice := 1
	DEFAULT cChave := ""

	FNJ->(dbSetOrder(nIndice))
	If FNJ->(MsSeek(cChave))
		lRet := .T.
	Endif

	RestArea(aAreaFNJ)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFMrgAtf   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida existencia das informacoes necessarias para Margem    ³±±
±±³          ³ Gerencial na base Ativo Fixo 			 	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AFMrgAtf ()						                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//MRG
Function AFMrgAtf()

	Local lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)

	If __lMargem == NIL

		If lDefTop
			__lMargem := .T.
		Else
			__lMargem := .F.
		Endif
	Endif

Return __lMargem

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AFVerTp15 ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 11/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe tipo 15 ativo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AFVerTp15(cCBase,cItem,cTpSaldo)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01= Codigo base do bem                                 ³±±
±±³          ³ ExpC02= Item do bem              			              ³±±
±±³          ³ ExpC03= Tipo do saldo do tipo de bem                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//MRG
*/
Function AFVerTp15(cCBase,cItem,cTpSaldo)

	Local aArea		:= GetArea()
	Local aAreaSN3	:= SN3->(GetArea())
	Local nRecSN3	:= SN3->(RECNO())
	Local lRet		:= .F.

	DEFAULT cCbase := ""
	DEFAULT cItem	:= ""
	DEFAULT cTpSaldo := ""

	dbSelectArea("SN3")
	SN3->(DBSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
	If SN3->(MsSeek( xFilial("SN3")+cCBase+cItem+"15"+"0"+cTpSaldo ))
		lRet := .T.
	Endif

	RestArea(aAreaSN3)
	RestArea(aArea)

	SN3->(dbGoTo(nRecSN3))

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AfVerTp10   ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica a existencia de um tipo 10 baixado junto com um    ³±±
±±³          ³ tipo 15 na mesma data e processo de baixa                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA030/035                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cBase     = Codigo base do bem					           ³±±
±±³          ³ cItem     = Item do bem			                           ³±±
±±³          ³ cTipoSld  = Tipo de saldo do bem tipo 15      		       ³±±
±±³          ³ dDataBx   = data da baixa do bem tipo 15                    ³±±
±±³          ³ cIdMovSN4 = Id do movimento do SN4            		       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//MRG
Function AfVerTp10(cBase,cItem,cTipoSld,dDataBx,cIdMovSN4)

	Local lRet 		:= .F.
	Local cQuery 	:= ""
	Local aArea		:= GetArea()
	Local cAliasQry := "CHKTP1015"
	Local cTypes10	:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 30/03/2017 - If is Russia, add new valuations models - main models
	Local cTypes	:= "10|13" + cTypes10

	cQuery := " SELECT COUNT(*) SN4MARGEM "
	cQuery += " FROM " + RetSqlName("SN4") + " SN4 "
	cQuery += " WHERE SN4.N4_FILIAL  = '" + xFilial("SN4") + "' AND "
	cQuery += "       SN4.N4_CBASE   = '" + cBase          + "' AND "
	cQuery += "       SN4.N4_ITEM    = '" + cItem          + "' AND "
	cQuery += "       SN4.N4_TPSALDO = '" + cTipoSld       + "' AND "
	cQuery += "       SN4.N4_DATA    = '" + DTOS(dDataBx)  + "' AND "
	cQuery += "       SN4.N4_TIPO IN ('10','13') AND "
	cQuery += "       SN4.N4_OCORR   = '01' AND "
	cQuery += "       SN4.N4_IDMOV   = '" + cIdMovSN4      + "' AND "
	cQuery += "       SN4.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->SN4MARGEM > 0
		Help(" ",1,"AFVERTP10",, STR0008+CHR(10)+STR0009 ,1,0) //"Este registro de Tipo 15 foi baixado através de um Tipo 10. Somente será possivel cancelar sua baixa através do Tipo 10."###"Selecione o Tipo 10 e o Tipo 15 será selecionado automaticamente para o processo."

		lRet := .T.
	EndIf

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFVCustEmp  ³ Autor ³ Alvaro Camillo Neto ³ Data ³ 04/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o ativo foi gerado a partir de um custo de      ³±±
±±³          ³ emprestimo.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ativo                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AFVCustEmp(cBase,cItem,lHelp)
	
	Local lRet    := .F.
	Local aArea   := GetArea()
	Local aAreaSN1:= SN1->(GetArea())

	Default lHelp := .F.


	If !IsInCallStack("ATFA480")
		SN1->(dbSetOrder(1)) // N1_FILIAL + N1_CBASE + N1_ITEM
		If SN1->(MsSeek(xFilial("SN1") + cBase + cItem))
			If SN1->N1_PATRIM == "E" .And. !Empty(SN1->N1_BASESUP) .And. !Empty(SN1->N1_ITEMSUP)
				lRet := .T.
			EndIf

			If lRet .And. lHelp
				Help(" ",1,"AFVCustEmp",, STR0010 ,1,0) //"Ficha Gerada pelo Assistente de Custo de Empréstimo (ATFA480). Por favor utilizar a opção Estornar da rotina"
			EndIf

		EndIf
	EndIf

	RestArea(aAreaSN1)
	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFPrvAtf   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida existencia das informacoes necessarias para Controle  ³±±
±±³          ³ de Provisao na base Ativo Fixo 			 	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ AFPrvAtf ()						                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFPrvAtf()

	Local lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)

	If __lProvis == NIL

		If lDefTop
			__lProvis := .T.
		Else
			__lProvis := .F.
		Endif
	Endif

Return __lProvis

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ATFXPerDepr³ Autor ³ Luis Arturo           ³ Data ³ 01/11/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida el Periodo de Depreciacion.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Params.   ³ cPriDiaMes = Primer dia de cada mes					        ³±±
±±³          ³ cUltDiaMes = Ultimo dia de cada mes						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ A050Calc(), A070CALC() y ATFA080()                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFXPerDepr(cPriDiaMes, cUltDiaMes)
	
	Local lRet := .F.
	Local lAuxTipDep := (Alltrim(SuperGetMv("MV_TIPDEPR",.F.,"")) == "4")
	Local lAuxCalDep := (Alltrim(SuperGetMv("MV_CALCDEP",.F.,"")) == "1")
	Local cAuxCalDep := (Alltrim(SuperGetMv("MV_PERDEPR",.F.,"")))
	Local lAuxPerDep := !(Empty(cAuxCalDep))
	Local nPosPipe   := 0

	Default cPriDiaMes := ""
	Default cUltDiaMes := ""

	If lAuxTipDep .And. lAuxCalDep .And. lAuxPerDep
		lRet        := .T.
		nPosPipe    := At( "|" , cAuxCalDep )
		cPriDiaMes  := Replace(Substr( cAuxCalDep, 1, nPosPipe - 1 ), "/", "")
		cUltDiaMes  := Replace(Substr( cAuxCalDep, nPosPipe + 1, Len(cAuxCalDep) ), "/", "")
	EndIf

Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF010AVTIPºAutor  ³Alvaro Camillo Neto º Data ³  31/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do campo When do campo N3_TIPDEPR                 º±±
±±º          ³ Movida a partir do ATFA010A em 22/08/2017                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF010AVTIP(cTpDepr,nLinha)
Local lRet 			:= .F.
Local nPosN3Tipo 	:= Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TIPO" } )
Local nPosN3TpDp 	:= Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TPDEPR" } )
Local aPosN3TxDp	:= If(lMultMoed, AtfMultPos(aHeader,"N3_TXDEPR")				,;
{	Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR1" } )	,;
Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR2" } )	,;
Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR3" } )	,;
Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR4" } )	,;
Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR5" } ) 	})
Local cTipoGer   	:= ''
Local aArea			:= {}
Local aAreaSN0		:= {}
Local nPosTp01		:= 0
Local nI			:= 0
Local cTypes10		:= IIF(lIsRussia,"/" + AtfNValMod({1}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main models
Local cTypes12		:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable models

DEFAULT cTpDepr := IIf(nPosN3TpDp>0, aCols[n][nPosN3TpDp], '')
DEFAULT nLinha := n

If nPosN3Tipo>0 .And. nPosN3TpDp>0
	If FindFunction("ATFSALDEPR") .and. !(aCols[nLinha][nPosN3Tipo] $ '|11')
		lRet := ATFSALDEPR(aCols[nLinha][nPosN3Tipo],,IiF("N3_TPDEPR" $ ReadVar(),&(ReadVar()),aCols[nLinha][nPosN3TpDp]))
	Else
		If aCols[nLinha][nPosN3Tipo] $ '01,02'
			cTipoGer := '1,7,8,9'
			If !(cPaisLoc $ "ARG|BRA|COS")
				If nLinha == 1
					aCols[nLinha][nPosN3TpDp] := '1'
					cTpDepr := '1'
				Endif
			EndIf
		ElseIf aCols[nLinha][nPosN3Tipo] $ ('10/12' + cTypes10 + cTypes12)
			aArea := GetArea()
			aAreaSN0 := SN0->(GetArea())
			
			dbSelectArea("SN0")
			
			SN0->(dbSetOrder(1))
			SN0->( MsSeek( xFilial("SN0") + '04' ) )
			
			Do While !SN0->(Eof()) .And. xFilial("SN0") + '04' == SN0->N0_FILIAL + SN0->N0_TABELA
				cTipoGer += IIf(empty(cTipoGer),'',',') + SN0->N0_CHAVE
				SN0->(dbSkip())
			EndDo
			
			RestArea(aAreaSN0)
			RestArea(aArea)
		ElseIf aCols[nLinha][nPosN3Tipo] $ '|11'
			nPosTp01	:= aScan(aCols,{|aX| aX[nPosN3Tipo] $ "01"})
			If nPosTp01 > 0
				cTipoGer	:= aCols[nPosTp01][nPosN3TpDp]
			EndIf
		Else
			cTipoGer := '1'
		EndIf
		lRet := cTpDepr $ cTipoGer
		If !lRet
			If aCols[nLinha][nPosN3Tipo] == '11'
				Help(" ",1,"AF010AVTIP",,I18N(STR0011,{AllTrim(RetTitle("N3_TPDEPR"))}),1,0) //'A alteração do campo "#1[Tipo deprec.]#" da ampliação deve ocorrer por meio do tipo de ativo "Depreciação Fiscal".'
			Else
				Help( " ", 1, "AF010TIPDEP",, STR0012, 1, 0 ) // "Esse método de depreciação não é válido para esse tipo de ativo."
			EndIf
		EndIf
	EndIf
EndIf

If lRet .and. aCols[nLinha][nPosN3Tipo] == '01'
	For nI := 1 To Len(aCols)
		If aCols[nI,nPosN3Tipo] == "11"
			aCols[nI,nPosN3TpDp]	:= cTpDepr
		EndIf
	Next nI
	If (Type('lAtfAuto') == "U" .Or. ! lAtfAuto) .And. Type("__oGet") == "O"
		__oGet:Refresh()
	EndIf
EndIf

If lRet .And. (aCols[nLinha][nPosN3Tipo] $ ('10' + cTypes10) ) .And. (cTpDepr == 'A')
	For nI := 1 To Len(aPosN3TxDp)
		aCols[nLinha,aPosN3TxDp[nI]] := 0
	Next nI
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}ATFAdjFil

Ajusta expressão de filtro dos relatórios customizáveis (TReport) 
para efetuar a macro execução na varredura do arquivo que se deseja
filtrar

Example:	ATFAdjFilExp( @cFilterUser )	
			
@param		cFilterUser	= caractere, expressão que será ajustada para filtro
@return		nil
@author		Fernando Radu Muscalu
@since		09/08/2018
@version	12
/*/
//-------------------------------------------------------------------
Function ATFAdjFil(cFilterUser,lQuery)

Local cExp 	:= cFilterUser
Local cAux	:= ""

Local nI	:= 0

Default lQuery := .f.

cExp := StrTran(cFilterUser,"#","")

If ( At("FWMNTFIL",Upper(cExp)) > 0 )
	cExp := &(cExp)
EndIf

cExp := StrTran(cExp,chr(34),chr(39))

If ( lQuery )
	
	cExp := StrTran(cExp,"=="," = ")
	cExp := StrTran(Lower(cExp),".or."," OR ")
	cExp := StrTran(Lower(cExp),".and."," AND ")
	cExp := StrTran(Upper(cExp),"DTOS(", space(1))
	cExp := StrTran(cExp,")", space(1))
	cExp := StrTran(Upper(cExp),".T.", "T")
	cExp := StrTran(Upper(cExp),".F.", "F")

EndIf

cFilterUser := cExp


Return()
//-------------------------------------------------------------------
/*/{Protheus.doc}ATFNValMod
	Function used only for location Russia
	Function Moved to source code RU01XFUN_GENFUN 
	This call should be removed in next release./*/
//-------------------------------------------------------------------
Function ATFNValMod(aType, cSep)
Return _ATFNValMod(aType,cSep)


//-------------------------------------------------------------------
/*/{Protheus.doc}ATFNValNM
	Function used only for location Russia
	Function Moved to source code RU01XFUN_GENFUN 
	This call should be removed in next release./*/
//-------------------------------------------------------------------
Function ATFNValNM(cType10)
Return 	_ATFNValNM(cType10)
