#Include "PLSA711.CH"
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"

#define __aCdCri032 {"540",STR0005} //"Erro controlado SIGAPLS."

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA711  ³ Autor ³ Luzio Tavares        ³ Data ³ 10.04.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cobranca Retorativa dos Reajustes de Precos dos contratos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
REGRA:
E necessario existir o lote de reajuste cadastrado no sistema para que a rotina de cobranca retroativa
psssa ser executada, uma vez que nao houve nao existindo o reajuste significa que o reajuste ainda nao
ocorreu.
*/

Function PLSA711()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variavels da rotina...                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE aRotina   := MenuDef()
	PRIVATE cCadastro := "Cobranca Retroativa de Reajuste de Mensalidade"
	PRIVATE cAlias    := "BHZ"
	PRIVATE cCodLan   := GetNewPar("MV_PLCDPAR","190")
	PRIVATE lfirst	  := .F.
	PRIVATE nOpc      := 0
	PRIVATE lGeroBSQ  := .F.

	If BSQ->(Fieldpos("BSQ_TABORI")) == 0
		Help("",1,"PLSA711FE1")    //Campo nao criado
		Return
	EndIf

	If FindFunction("PLSCRIABFQ")
		PLSCRIABFQ()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define browse...                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BHZ->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BHZ"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fim da Rotina Principal...                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA711MOV ³ Autor ³ Luzio Tavares     ³ Data ³ 10.04.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cobranca Retroativa do Reajuste de Precos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA711MOV(cAlias,nReg,nOpc)
	LOCAL oDlg
	LOCAL nOpca     := 0
	LOCAL bOK       := {|| nOpca := 1,If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),(Processa({||Pls11Grava(nOpca,nopc)},"Cobranca Retroativa de Reajuste","Processando..."),oDlg:End()),nOpca := 2),If(nOpca == 2,oDlg:End(),.F.)}
	LOCAL bCancel   := {|| (oDlg:End(),nOpca:=2) }
	LOCAL oEnchoice
	LOCAL aButtons  := {}
	LOCAL nOpcGD
	LOCAL cCodInt   := ''
	Local cCodigo   := ''
	Local i			:=0
	Local lGrava	:=.F.

	Private aRetUsr := {}

	If lFirst
		lFirst := .F.
		Return()
	Endif

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 200, .T., .T. } )
	AAdd( aObjects, { 200, 100, .T., .T.,.T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	// Define dialogo...
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

	// Define dados da enchoice...
	If nOpc == 3
		RegToMemory( cAlias, .T., .F. )
		M->BHZ_CODIGO:= GetSx8Num("BHZ","BHZ_CODIGO")
	Else
		RegToMemory( cAlias, .F., .F. )
	Endif

	// Monta Enchoice...
	If nOpc == 2
		nOpcGD := 2
	Else
		nOpcGD := nOpc
	Endif

	oEnchoice := MSMGet():New(calias,BHZ->(Recno()),nOpcGD,,,,nil,aPosObj[1],nil,,,,,oDlg,,,.F.)


	// Ativa o dialogo...
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons,{||oDlg:End()})

	If nOpca=2
		BHZ->(RollBackSx8())
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA711PRO ³ Autor ³ Luzio Tavares     ³ Data ³ 10.04.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento da rotina de cobranca retorativa para PF e PJ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA711PRO(cCodigo,cNumLot,cCodOpe,cAno,cMes,cEmpDe,cEmpAte,cTipGru, cConDe, cConAte, cSubde, cSubate, cMatDe, cMatAte, cProd, cOpc, cTax, cUsrBlq, cTipPar, nQtdPar, lAuto)

	Local cSQL
	Local nX,nI	:= 0
	LOCAL lAbortPrint:= .F.
	Local aRetCom := {}
	Local aLancDeb := {}
	Local aBkaLancDeb:= {}
	Local cCodInt := Space(0)
	Local cCodEmp := Space(0)
	Local cMatric := Space(0)
	Local cTipReg := Space(0)
	Local cDigito := Space(0)
	Local nTotDif := 0
	Local nValDif := 0
	Local nQtdParInf:= nQtdPar
	Local nQtdMens:= 0
	Local cMesMen := Space(0)
	Local lValido := .T.
	Local cLocalExec:= "1"
	Local nVlMinPar	:= GetNewPar("MV_PLVLMPA",10)    //Valor minimo para parcelamento da Cobranca do Reajuste Retroativo
	Local aVlrFai:= {}
	Local cAnoAux := cAno  //Ano do primeiro lancamento de debito
	Local cMesAux := cMes  //Mes do primeiro lancamento de debito
	Local cTipo	:= ""
	Local cMesReajuste := "01"
	Local cMesOri := cMes
	Local cAnoOri := cAno
	Local lRetroat := Iif(BHZ->( FieldPos("BHZ_APLRET") ) > 0,(M->BHZ_APLRET<>'1'),.T.)
	Local aResumo := {} // Resumo dos registros gerados
	Local aNivBDK := {} // Determina se há cobrança especifica no beneficiario  BDK
	Local cMatricula :=''
	Local cAliasQry	:= GetNextAlias()

	Default lAuto := .F.

	cCodLan := Iif(M->BHZ_APLRET=='1',GetNewPar("MV_PLCDRET","192"),cCodLan) // Tratativa para atender retroativos para beneficiarios

	aRetCom := {}
	aRetCom := VALCODLAN(cCodLan, @lValido, cLocalExec)

	If Len(aRetCom) > 0
		Help("",1,"Existe mais de um lançamento")
		Return(.F.)
	Endif
	If !lValido
		Help("",1,"Não existem lançamentos")
		Return(.F.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca os usuarios que foram reajustados pelo lote informado...           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta da query...                                                		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT * "
	cSQL += "FROM "+RetSQLName("BHO")+" BHO WHERE "
	cSQL += "BHO_FILIAL = '"+xFilial("BHO")+"' AND "
	cSQL += "BHO_OPEREA = '"+cCodOpe+"' AND "
	cSQL += "BHO_CODREA = '"+cNumLot+"' AND "
	cSQL += "BHO_CODEMP >= '"+cEmpDe+"' AND "
	cSQL += "BHO_CODEMP <= '"+cEmpAte+"' AND "
	cSQL += "BHO_CONEMP >= '"+cConDe+"' AND "
	cSQL += "BHO_CONEMP <= '"+cConAte+"' AND "
	cSQL += "BHO_SUBCON >= '"+cSubDe+"' AND "
	cSQL += "BHO_SUBCON <= '"+cSubAte+"' AND "
	cSQL += "BHO_MATRIC >= '"+cMatDe+"' AND "
	cSQL += "BHO_MATRIC <= '"+cMatAte+"' AND "
	cSQL += "BHO_ANOREA = '"+cAno+"' AND "
	If cTipPar <> "2"
		cSQL += "BHO_MESREA = '"+cMes+"' AND "
	Endif	
	cSQL += "D_E_L_E_T_ = ' '"
	PLSQuery(cSQL,"TRBBHO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa dados da query...                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ! TRBBHO->(Eof())

		aLancDeb := {}

		// Restaura Mes/Ano
		cMes := cMesOri
		cAno := cAnoOri
		cMesAux := cMesOri
		cAnoAux := cAnoOri
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Testa cancelamento do processo...                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(lAbortPrint)
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe mensagem de processamento...                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BG9->(dbSetOrder(1))
		BG9->(msSeek(xFilial("BG9")+TRBBHO->(BHO_CODOPE+BHO_CODEMP)))

		If !lAuto
			IncProc("Analisando Grupo Empresa "+BG9->BG9_CODIGO+" ("+AllTrim(BG9->BG9_DESCRI)+")")
			ProcessMessage()

			// Exibe mensagem de processamento...
			IncProc("Analisando Familia "+TRBBHO->(BHO_CODOPE+'.'+BHO_CODEMP+'.'+BHO_MATRIC))
			ProcessMessage()
		EndIf

		cMatricFam := TRBBHO->(BHO_CODOPE+BHO_CODEMP+BHO_MATRIC)
		cMatUsu    := TRBBHO->(BHO_CODOPE+BHO_CODEMP+BHO_MATRIC+BHO_TIPREG)

		BDK->(DbSetOrder(1))
		If BDK->(DbSeek(xFilial("BDK")+cMatUsu))

			While ! BDK->(Eof()) .And. BDK->(BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG) == xFilial("BDK")+cMatUsu
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Apura o valor da faixa etaria reajustada...                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If BDK->BDK_ANOMES == TRBBHO->(BHO_ANOREA+BHO_MESREA)
					Aadd(aVlrFai,{BDK->(BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG),BDK->BDK_CODFAI, BDK->BDK_VALOR, BDK->BDK_VLRANT})

					//Determinado os beneficiario que tem forma de cobrança especifica na BDK
					If(Ascan(aNivBDK,BDK->(BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG))) = 0
						Aadd(aNivBDK,BDK->(BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG))
					EndIf
				EndIf
				BDK->(DbSkip())
			Enddo
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza faixa etaria da familia...                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BBU->(DbSetOrder(1))
			If BBU->(DbSeek(xFilial("BBU")+cMatricFam))
				While ! BBU->( Eof() ) .And. BBU->(BBU_FILIAL+BBU_CODOPE+BBU_CODEMP+BBU_MATRIC) == xFilial("BBU")+cMatricFam
					If BBU->BBU_ANOMES == TRBBHO->(BHO_ANOREA+BHO_MESREA)
						Aadd(aVlrFai,{BBU->(BBU_FILIAL+BBU_CODOPE+BBU_CODEMP+BBU_MATRIC), BBU->BBU_CODFAI, BBU->BBU_VALFAI, BBU->BBU_VLRANT})
					EndIf
					BBU->(DbSkip())
				Enddo
			EndIf
		EndIf

		nValdif 	:= 0
		cCodInt 	:= ""
		cCodEmp 	:= ""
		cMatric 	:= ""
		cTipReg 	:= ""
		cDigito 	:= ""
		cConEmp 	:= ""
		cVerCon 	:= ""
		cSubCon 	:= ""
		cVerSub 	:= ""
		cMesMen 	:= ""
		nTotDif 	:= 0
		nQtdMens 	:= 0
		cMesReajuste:= TRBBHO->BHO_MESREA
		cMesReaprox := cMesReajuste
		nMesAtraso 	:= 0

		If BG9->BG9_TIPO == '1' .And. GetNewPar("MV_PLSQMRA",2) > 0 //Pessoa Fisica
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Conforme RN 171/08 - Capitulo 1 - Pode retroagir somente 2 ou 3 meses    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta da query...                                                		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := "SELECT COUNT(*) BM1GERADO "
			cSQL += "FROM "+RetSQLName("BM1")+" BM1 WHERE "
			cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' AND "
			cSQL += "BM1_CODINT = '"+TRBBHO->BHO_OPEREA+"' AND "
			cSQL += "BM1_CODEMP = '"+TRBBHO->BHO_CODEMP+"' AND "
			cSQL += "BM1_CONEMP = '"+TRBBHO->BHO_CONEMP+"' AND "
			cSQL += "BM1_SUBCON = '"+TRBBHO->BHO_SUBCON+"' AND "
			cSQL += "BM1_MATRIC = '"+TRBBHO->BHO_MATRIC+"' AND "
			cSQL += "BM1_TIPREG = '"+TRBBHO->BHO_TIPREG+"' AND "

			If Upper(AllTrim(TcGetDB())) $ "DB2/ORACLE"
				cSQL += "BM1_ANO || BM1_MES >= '"+TRBBHO->BHO_ANOREA+cMesReajuste+"' AND "
			Else
				cSQL += "BM1_ANO+BM1_MES >= '"+TRBBHO->BHO_ANOREA+cMesReajuste+"' AND "
			Endif

			cSQL += "BM1_CODTIP = '101' AND "
			cSQL += "D_E_L_E_T_ = ' '"
			PLSQuery(cSQL,"TRBBM1")

			If TRBBM1->BM1GERADO > 0

				nMesGerado    := TRBBM1->BM1GERADO + VAL(cMesReajuste)
				nMesRetroagir := GetNewPar("MV_PLSQMRA",2)// Quantidade mes segundo ANS cobrar retroativo PF
				nMesAtraso	  := nMesGerado - VAL(cMesReajuste)

				If nMesAtraso > nMesRetroagir
					cMesReajuste := STRZERO(nMesgerado - nMesRetroagir,2)
				Endif

			Endif

			TRBBM1->(DbCloseArea())

		Endif

		aRetUsr:={}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se houve cobranca para os mes de reajuste...                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta da query...                                                		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT * "
		cSQL += "FROM "+RetSQLName("BM1")+" BM1 WHERE "
		cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' AND "
		cSQL += "BM1_CODINT = '"+TRBBHO->BHO_OPEREA+"' AND "
		cSQL += "BM1_CODEMP = '"+TRBBHO->BHO_CODEMP+"' AND "
		cSQL += "BM1_CONEMP = '"+TRBBHO->BHO_CONEMP+"' AND "
		cSQL += "BM1_SUBCON = '"+TRBBHO->BHO_SUBCON+"' AND "
		cSQL += "BM1_MATRIC = '"+TRBBHO->BHO_MATRIC+"' AND "
		cSQL += "BM1_TIPREG = '"+TRBBHO->BHO_TIPREG+"' AND "

		If Upper(AllTrim(TcGetDB())) $ "DB2/ORACLE"
			cSQL += "BM1_ANO || BM1_MES >= '"+TRBBHO->BHO_ANOREA+cMesReajuste+"' AND "
		Else
			cSQL += "BM1_ANO+BM1_MES >= '"+TRBBHO->BHO_ANOREA+cMesReajuste+"' AND "
		Endif

		cSQL += "BM1_CODTIP = '101' AND "
		cSQL += "D_E_L_E_T_ = ' '"
		PLSQuery(cSQL,"TRBBM1")

		TRBBM1->(DbGoTop())
		While !TRBBM1->(Eof())

			//Ano e Mes da Primeira Parcela a Partir de Competencia Faturada
			If ! Empty(TRBBM1->BM1_NUMTIT)

				cCodInt := TRBBM1->BM1_CODINT
				cCodEmp := TRBBM1->BM1_CODEMP
				cMatric := TRBBM1->BM1_MATRIC
				cTipReg := TRBBM1->BM1_TIPREG
				cDigito := TRBBM1->BM1_DIGITO
				cConEmp := TRBBM1->BM1_CONEMP
				cVerCon := TRBBM1->BM1_VERCON
				cSubCon := TRBBM1->BM1_SUBCON
				cVerSub := TRBBM1->BM1_VERSUB
				cCodFai := TRBBM1->BM1_CODFAI  //Identifica em qual faixa ocorreu a cobranca antes do reajuste
				cAno    := TRBBM1->BM1_ANO     //Ano da ultima cobranca gerada
				cMes    := TRBBM1->BM1_MES     //Mes da ultima cobranca gerada, sera lancado no mes cobraca posterior a esta

				nQtdMens += 1

				nPos := Ascan(aVlrFai,{ |x| x[1] == xFilial("BHO")+cMatUsu .And. x[2] == cCodFai})

				If nPos > 0

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica Desconto mensalidade ... 										 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nValReal 	:= aVlrFai[nPos,3]
					nValBM1 	:= TRBBM1->BM1_VALOR
					lValBM1     := GetNewPar("MV_PLSDBM1","0") == "1"
					//Caso tenha, adiciono desconto para o contrato
					BQC->(DbSetOrder(1))
					If BQC->( MsSeek(xFilial("BQC")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub)) .And. BQC->BQC_PERCON > 0
						nValReal:= nValReal - round(((nValReal * BQC->BQC_PERCON)/100),2)
					Endif

					If lRetroat // aplica retroativo com desconto contra  beneficiario
						aVetDes 	:= PLSMFPDeFai(TRBBM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG),,TRBBM1->BM1_TIPUSU,TRBBM1->BM1_GRAUPA,;
							TRBBM1->BM1_SEXO,TRBBM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC),,TRBBM1->BM1_CODFAI,TRBBM1->BM1_CODFAI,1)

						//Retorno aVetDes{Valor do Desconto, Percentual de Desconto, tipo Desconto}
						If Len(aVetDes)> 0
							For nI:=1 to Len(aVetDes)
								If aVetDes[nI,3] == "1" // tipo Desconto
									If aVetDes[nI,2] <> 0 // Percentual
										nValReal := nValReal - round(((nValReal * aVetDes[nI,2])/100),2)
										If lValBM1
											nValBM1 := nValBM1 - round(((nValBM1 * aVetDes[nI,2])/100),2)
										Endif
									Else
										nValReal := nValReal - aVetDes[nI,1]
										If lValBM1
											nValBM1 := nValBM1 - aVetDes[nI,1]
										Endif
									Endif
								Else //Tipo Acrescimo
									If aVetDes[nI,2] <> 0
										nValReal := nValReal + round(((nValReal * aVetDes[nI,2])/100),2)
										If lValBM1
											nValBM1 := nValBM1 + round(((nValBM1 * aVetDes[nI,2])/100),2)
										Endif
									Else
										nValReal := nValReal + aVetDes[nI,1]
										If lValBM1
											nValBM1 := nValBM1 + aVetDes[nI,1]
										Endif
									Endif
								Endif
							Next nI
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Acumula o valor da diferenca para cada mensalidade cobrada a menor...    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nValDif := (nValReal - nValBM1)

					Else
						nValDif := (nValBM1 - nValReal  )
					EndIf


					If nValDif > 0


						If cTipPar == "1"
							//Apura apenas a Quantidade de Parcelas a ser dividida a cobranca
							nQtdPar := 1
						EndIf

						//Acumula o valor da diferenca para dividir as parcelas e depois verificar a diferenca para ajustes na ultima parcela.
						nTotDif += nValDif

						//Acumula os meses que nao foram reajustados para que possa gravar no lanacamento de debito.
						cMesMen += cAno+"/"+cMes+", "

						// Acumula em um array para gerar relatorio
						aadd(aRetUsr,{cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cMes,cAno, TRBBM1->BM1_VALOR, aVlrFai[nPos,3], nValDif,cMes})

					EndIf
				EndIf
			Endif

			TRBBM1->(DbSkip())
		Enddo

		TRBBM1->(DbCloseArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validação Parcelamento da Cobranca Retroativa ...                          			   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTotDif > 0    //Len(aLancDeb) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Parcelamento do Reajuste de Mensalidade Retroativo...           						  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  cTipPar == "2"
				//Qtde Parcelas Atrasadas
				nQtdPar := Len(aRetUsr)
			ElseIf cTipPar == "3"    .and. lRetroat  //Numero de meses ate o proximo reajuste
				cDatIni := CtoD("30/"+cMes+"/"+cAno)
				cDatFim := CtoD("01/"+cMesReaprox+"/"+Str(Val(cAno)+1))
				nQtdPar := Int((cDatFim-cDatIni)/30)
			ElseIf cTipPar == "4"  .and. lRetroat     //Quantidade de Parcelas Informadas
				If nQtdPar > 0
					nQtdPar := nQtdParInf
				Else
					// Fecha area de trabalho temporaria...
					TRBBHO->(DbCloseArea())
					Return(.T.)
				EndIf
			ElseIf !lRetroat
				nQtdPar := nQtdMens //numero de meses que irá atender ago/set/out
				cMesAux := M->BHZ_MES
			EndIf

			nValDif := Round((nTotDif / nQtdPar),2)

			If lRetroat

				If nValDif < nVlMinPar
					//Se o valor da parcela for menor que o indicado no parametro
					nQtdPar := 1

					// Atualiza Parcela
					nValDif := Round((nTotDif / nQtdPar),2)
				Endif

				if Len(aRetUsr) > 0
					cAno := aRetUsr[Len(aRetUsr),7]
					cMes := aRetUsr[Len(aRetUsr),6]
				Else
					cAno := cAnoAux
					cMes := cMesAux
				Endif

				If cMes == "12"  // Mes da ultima cobranca gerada
					cMes := "01"
					cAno := Alltrim(Str(Val(cAno)+1))
				Else
					cMes := StrZero(Val(cMes)+1, 2)
				Endif
			Else
				If BHZ->(FieldPos("BHZ_ANOMES")) > 0 .And. ! Empty(M->BHZ_ANOMES)
					cMes := Substr(M->BHZ_ANOMES,(Len(M->BHZ_ANOMES)-1),(Len(M->BHZ_ANOMES)))
					cAno := Substr(M->BHZ_ANOMES,1,4)
				Else
					cMes 	:= StrZero(Val(cMesAux)+nQtdPar,2)
				Endif
			Endif


			cMatricUsr := cCodInt+cCodEmp+cMatric+cTipReg+cDigito

			BSQ->(DbSetOrder(2))

			For nX = 1 to nQtdPar

				If cTipPar == "2"  // - Qtde Parcelas Atrasadas
					nValDif:= aRetUsr[nx,10] //Pego a diferença da parcela atrasada não diluida
				Endif

				If !BSQ->(DbSeek(xFilial("BSQ")+cMatricUsr+cConEmp+cVerCon+cSubCon+cVerSub+cAno+cMes)) // Verificando se ja existe o lançamento BSQ
					aadd(aLancDeb,{cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cMes,cAno,nValDif,cMesAux,cAnoAux})
					aadd(aBkaLancDeb,{cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cMes,cAno,nValDif,cMesAux,cAnoAux})
					aadd(aResumo,{ cMatricUsr, Posicione("BA1",2,xFilial("BA1")+cMatricUsr,"BA1_NOMUSR"), cMes,cAno,nValDif,"Registro Processado"})
				Else
					aadd(aResumo,{ cMatricUsr,Posicione("BA1",2,xFilial("BA1")+cMatricUsr,"BA1_NOMUSR"), cMes,cAno,nValDif,"Registro se encontra processado"})
				Endif

				// Indica a proxima cobranca a ser gerada e que sera a primeira cobranca da parcela
				If cMes == "12"  // Mes da ultima cobranca gerada
					cMes := "01"
					cAno := Alltrim(Str(Val(cAno)+1))
				Else
					cMes := StrZero(Val(cMes)+1,2)
				Endif

				If cMesAux == "12"  // Mes da ultima cobranca gerada
					cMesAux := "01"
					cAnoAux := Alltrim(Str(Val(cAnoAux)+1))
				Else
					cMesAux := StrZero(Val(cMesAux)+1,2)
				Endif

			Next

			If Len(aLancDeb) > 0
				PLSPARLANC(cAlias, cMatricUsr, aLancDeb, nQtdPar, nTotDif, cTipo, cMes, cAno, cMesMen, cCodInt, cCodEmp, cMatric,;
					cTipReg, cDigito, cConEmp, cVerCon, cSubCon, cVerSub, cCodLan, cCodigo, cNumLot)
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha area de trabalho temporaria...                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TRBBHO->(DbSkip())
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha area de trabalho temporaria...                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRBBHO->(DbCloseArea())

	// Restaura Mes/Ano
	cMes := cMesOri
	cAno := cAnoOri

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a familia que foram reajustados pelo lote informado...            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT DISTINCT (BP7.R_E_C_N_O_),BP7.*, BM1.BM1_TIPREG,BM1.BM1_DIGITO "
	cSQL += " FROM "+RetSQLName("BP7")+ " BP7, " +RetSQLName("BM1")+ " BM1 "
	cSQL += " WHERE "
	cSQL += " BP7_CODOPE = BM1_CODINT AND "
	cSQL += " BP7_CODEMP = BM1_CODEMP AND "
	cSQL += " BP7_MATRIC = BM1_MATRIC AND "
	cSQL += " BP7_CODOPE = BM1_CODINT AND "
	cSQL += " BP7_CODFAI = BM1_CODFAI AND "
	cSQL += "BP7_FILIAL = '"+xFilial("BP7")+"' AND "
	cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' AND "
	cSQL += "BP7_OPEREA = '"+cCodOpe+"' AND "
	cSQL += "BP7_CODREA = '"+cNumLot+"' AND "
	cSQL += "BP7_CODEMP >= 		'"+cEmpDe+"' AND "
	cSQL += "BP7_CODEMP <= 		'"+cEmpAte+"' AND "
	cSQL += "BP7_MATRIC >=		'"+cMatDe+"' AND "
	cSQL += "BP7_MATRIC <= 		'"+cMatAte+"' AND "
	cSQL += "BP7.D_E_L_E_T_ = ' ' AND "
	cSQL += "BM1.D_E_L_E_T_ = ' ' "
	cSQL += "ORDER BY BM1_TIPREG "

	PLSQuery(cSQL,"TRBBP7")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa dados da query...                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ! TRBBP7->(Eof())

		aLancDeb := {}

		// Restaura Mes/Ano
		cMes := cMesOri
		cAno := cAnoOri

		If TRBBP7->(BP7_CODOPE+BP7_CODEMP+BP7_MATRIC+BM1_TIPREG+BM1_DIGITO) <> cMatricula

			//Verificando o ultimo mes de fatura da familial para determinar os proximos eses das faturas
			cAliasQry	:= GetNextAlias()
			cCond := "%('"+ MVDUPLIC +"'"+ ','+ "'"+MVFATURA+"')%"

			BeginSQL Alias cAliasQry
			SELECT E1_VENCREA
			FROM %Table:SE1%
			WHERE	E1_FILIAL	= %xfilial:SE1% 			AND
					E1_CODINT	= %exp:TRBBP7->(BP7_CODOPE)%	AND
					E1_CODEMP	= %exp:TRBBP7->(BP7_CODEMP)%	AND
					E1_MATRIC	= %exp:TRBBP7->(BP7_MATRIC)%	AND
					E1_TIPO		IN %Exp:cCond%					AND
					%NotDel%
					ORDER BY E1_VENCREA DESC
			EndSQL

			If (cAliasQry)->(!Eof())
				cMesAux := StrZero(Month(StoD(( cAliasQry )->E1_VENCREA))+1,2)
				cAnoAux := StrZero(Year(StoD(( cAliasQry )->E1_VENCREA)),4)
				If cMesAux > "12"  // Mes da ultima cobranca gerada
					cMesAux := "01"
					cAnoAux := Alltrim(Str(Val(cAnoAux)+1))
				Endif
			Else
				cMesAux := cMesOri
				cAnoAux := cAnoOri
			Endif	

			(cAliasQry)->(DbCloseArea())

			cMatricula:= TRBBP7->(BP7_CODOPE+BP7_CODEMP+BP7_MATRIC+BM1_TIPREG+BM1_DIGITO)
		Endif	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Testa cancelamento do processo...                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(lAbortPrint)
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe mensagem de processamento...                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BG9->(dbSetOrder(1))
		BG9->(DbSeek(xFilial("BG9")+TRBBP7->(BP7_OPEREA+BP7_CODEMP)) )

		If !lAuto
			IncProc("Analisando Grupo Empresa "+BG9->BG9_CODIGO+" ("+AllTrim(BG9->BG9_DESCRI)+")")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe mensagem de processamento...                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc("Analisando Familia "+TRBBP7->(BP7_CODOPE+'.'+BP7_CODEMP+'.'+BP7_MATRIC))
			ProcessMessage()
		EndIf

		cMatricFam := TRBBP7->(BP7_CODOPE+BP7_CODEMP+BP7_MATRIC)

		nValdif := 0
		cCodInt := ""
		cCodEmp := ""
		cMatric := ""
		cTipReg := ""
		cDigito := ""
		cConEmp := ""
		cVerCon := ""
		cSubCon := ""
		cVerSub := ""
		cMesMen := ""
		nTotDif := 0
		nQtdMens := 0
		aRetUsr :={}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca o contrato e o subcontrato do usuario                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta da query...                                                		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cSQL := "SELECT * "
		cSQL += "FROM "+RetSQLName("BA1")+" BA1 WHERE "
		cSQL += "BA1_FILIAL = '"+xFilial("BA1")+"' AND "
		cSQL += "BA1_CODINT = '"+TRBBP7->BP7_OPEREA+"' AND "
		cSQL += "BA1_CODEMP = '"+TRBBP7->BP7_CODEMP+"' AND "
		cSQL += "BA1_MATRIC = '"+TRBBP7->BP7_MATRIC+"' AND "
		cSQL += "BA1_TIPREG = '"+TRBBP7->BM1_TIPREG+"' AND "
		cSQL += "BA1_DIGITO = '"+TRBBP7->BM1_DIGITO+"' AND "
		cSQL += "D_E_L_E_T_ = ' '"
		PLSQuery(cSQL,"_TRBBA1")

		_TRBBA1->(DbGoTop())

		While !_TRBBA1->(Eof())
			cConEmp 	:=_TRBBA1->BA1_CONEMP
			cSubCon 	:=_TRBBA1->BA1_SUBCON
			cTipReg 	:=_TRBBA1->BA1_TIPREG
			nMesAtraso 	:= 0


			//Determinado os beneficiario que tem forma de cobrança especifica na BDK
			//Ao gerar a rotina de rajuste o sistema verifica primeiro nivel do usuario e atualizaza o BHO(Usuários Reajustados), apos atualizado ele atualiza BP7 (Faixas das Famílias Reajustes)
			If(Ascan(aNivBDK,_TRBBA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))) > 0
				_TRBBA1->(DbSkip())
				Loop
			EndIf


			If BA3->(DbSeek(xFilial("BA3")+TRBBP7->BP7_OPEREA+TRBBP7->BP7_CODEMP+_TRBBA1->BA1_MATRIC))
				cMesReajuste	:= BA3->BA3_MESREA
				cAnoReajuste  	:= Alltrim(M->BHZ_ANO)

				If Val(cMesReajuste) <  Val(M->BHZ_MES)   .and. !lRetroat // Não ira aplicar retroativo a favor do benefeciario se o mes de reajuste for menor que a informado no paramentro
					_TRBBA1->(DbSkip())
					Loop
				Endif
			Else
				_TRBBA1->(DbSkip())
				Loop
			Endif

			cMesReaprox   := cMesReajuste




			If BG9->BG9_TIPO == '1' .And. GetNewPar("MV_PLSQMRA",2) > 0 //Pessoa Fisica
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Conforme RN 171/08 - Capitulo 1 - Pode retroagir somente 2 ou 3 meses    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta da query...                                                		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cSQL := "SELECT COUNT(*) BM1GERADO "
				cSQL += "FROM "+RetSQLName("BM1")+" BM1 WHERE "
				cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' AND "
				cSQL += "BM1_CODINT = '"+TRBBP7->BP7_OPEREA+"' AND "
				cSQL += "BM1_CODEMP = '"+TRBBP7->BP7_CODEMP+"' AND "
				cSQL += "BM1_CONEMP = '"+_TRBBA1->BA1_CONEMP+"' AND "
				cSQL += "BM1_SUBCON = '"+_TRBBA1->BA1_SUBCON+"' AND "
				cSQL += "BM1_MATRIC = '"+_TRBBA1->BA1_MATRIC+"' AND "
				cSQL += "BM1_TIPREG = '"+_TRBBA1->BA1_TIPREG+"' AND "
				cSQL += "BM1_DIGITO = '"+_TRBBA1->BA1_DIGITO+"' AND "
				cSQL += "BM1_CODFAI = '"+TRBBP7->BP7_CODFAI+"' AND "

				If Upper(AllTrim(TcGetDB())) $ "DB2/ORACLE"
					cSQL += "BM1_ANO || BM1_MES >= '"+cAnoReajuste+cMesReajuste+"' AND "
				Else
					cSQL += "BM1_ANO+BM1_MES >= '"+cAnoReajuste+cMesReajuste+"' AND "
				Endif

				cSQL += "BM1_CODTIP = '101' AND "
				cSQL += "D_E_L_E_T_ = ' '"
	
				PLSQuery(cSQL,"TRBBM1")

				If TRBBM1->BM1GERADO > 0

					nMesGerado    := TRBBM1->BM1GERADO + VAL(cMesReajuste)
					nMesRetroagir := GetNewPar("MV_PLSQMRA",2)// Quantidade mes segundo ANS cobrar retroativo PF
					nMesAtraso	  := nMesGerado - VAL(cMesReajuste)

					If nMesAtraso > nMesRetroagir
						cMesReajuste := STRZERO(nMesgerado - nMesRetroagir,2)
					Endif

				Endif

				TRBBM1->(DbCloseArea())

			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se houve cobranca para os mes de reajuste...                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta da query...                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := "SELECT * "
			cSQL += "FROM "+RetSQLName("BM1")+" BM1 WHERE "
			cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' AND "
			cSQL += "BM1_CODINT = '"+TRBBP7->BP7_OPEREA+"' AND "
			cSQL += "BM1_CODEMP = '"+TRBBP7->BP7_CODEMP+"' AND "
			cSQL += "BM1_CONEMP = '"+_TRBBA1->BA1_CONEMP+"' AND "
			cSQL += "BM1_SUBCON = '"+_TRBBA1->BA1_SUBCON+"' AND "
			cSQL += "BM1_MATRIC = '"+_TRBBA1->BA1_MATRIC+"' AND "
			cSQL += "BM1_TIPREG = '"+_TRBBA1->BA1_TIPREG+"' AND "
			cSQL += "BM1_DIGITO = '"+_TRBBA1->BA1_DIGITO+"' AND "
			cSQL += "BM1_CODFAI = '"+TRBBP7->BP7_CODFAI+"' AND "

			If Upper(AllTrim(TcGetDB())) $ "DB2/ORACLE"
				cSQL += "BM1_ANO || BM1_MES >= '"+cAnoReajuste+cMesReajuste+"' AND "
			Else
				cSQL += "BM1_ANO+BM1_MES >= '"+cAnoReajuste+cMesReajuste+"' AND "
			Endif

			cSQL += "BM1_CODTIP = '101' AND "
			cSQL += "D_E_L_E_T_ = ' '"
			cSQL += "ORDER BY BM1_ANO,BM1_MES"
			PLSQuery(cSQL,"TRBBM1")

			TRBBM1->(DbGoTop())

			While !TRBBM1->(Eof())

				//Ano e Mes da Primeira Parcela a Partir de Competencia Faturada
				If ! Empty(TRBBM1->BM1_NUMTIT)

					cCodInt := TRBBM1->BM1_CODINT
					cCodEmp := TRBBM1->BM1_CODEMP
					cMatric := TRBBM1->BM1_MATRIC
					cTipReg := TRBBM1->BM1_TIPREG
					cDigito := TRBBM1->BM1_DIGITO
					cConEmp := TRBBM1->BM1_CONEMP
					cVerCon := TRBBM1->BM1_VERCON
					cSubCon := TRBBM1->BM1_SUBCON
					cVerSub := TRBBM1->BM1_VERSUB
					cCodFai := TRBBM1->BM1_CODFAI  //Identifica em qual faixa ocorreu a cobranca antes do reajuste
					cAno    := TRBBM1->BM1_ANO     //Ano da ultima cobranca gerada
					cMes    := TRBBM1->BM1_MES     //Mes da ultima cobranca gerada, sera lancado no mes cobraca posterior a esta

					nQtdMens += 1

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula o valor da diferenca para cada mensalidade cobrada a menor...    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If TRBBP7->BP7_CODFAI = TRBBM1->BM1_CODFAI

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica Desconto mensalidade ... 										 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nValReal 	:= TRBBP7->BP7_VLRREA
						//Caso tenha, adiciono desconto para o contrato
						BQC->(DbSetOrder(1))
						If BQC->( MsSeek(xFilial("BQC")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub)) .And. BQC->BQC_PERCON > 0
							nValReal:= nValReal - round(((nValReal * BQC->BQC_PERCON)/100),2)
						Endif

						nValBM1 	:= TRBBM1->BM1_VALOR
						lValBM1     := GetNewPar("MV_PLSDBM1","0") == "1"

						If lRetroat // aplica retroativo com desconto contra  beneficiario
							aVetDes 	:= PLSMFPDeFai(TRBBM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG),,TRBBM1->BM1_TIPUSU,TRBBM1->BM1_GRAUPA,;
								TRBBM1->BM1_SEXO,TRBBM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC),,TRBBM1->BM1_CODFAI,TRBBM1->BM1_CODFAI,1)

							//Retorno aVetDes{Valor do Desconto, Percentual de Desconto, tipo Desconto}
							If Len(aVetDes)> 0
								For nI:=1 to Len(aVetDes)
									If aVetDes[nI,3] == "1" // tipo Desconto
										If aVetDes[nI,2] <> 0 // Percentual
											nValReal := nValReal - round(((nValReal * aVetDes[nI,2])/100),2)
											If lValBM1
												nValBM1 := nValBM1 - round(((nValBM1 * aVetDes[nI,2])/100),2)
											Endif
										Else
											nValReal := nValReal - aVetDes[nI,1]
											If lValBM1
												nValBM1 := nValBM1 - aVetDes[nI,1]
											Endif
										Endif
									Else //Tipo Acrescimo
										If aVetDes[nI,2] <> 0
											nValReal := nValReal + round(((nValReal * aVetDes[nI,2])/100),2)
											If lValBM1
												nValBM1 := nValBM1 + round(((nValBM1 * aVetDes[nI,2])/100),2)
											Endif
										Else
											nValReal := nValReal + aVetDes[nI,1]
											If lValBM1
												nValBM1 := nValBM1 + aVetDes[nI,1]
											Endif
										Endif
									Endif
								Next nI
							Endif

							nValDif := (nValReal - nValBM1)
						Else
							//Verificando a diferença para creditar a favor do beneficiario
							If nValBM1 >= TRBBP7->BP7_VLRANT //Houve o faturamento com valor sem aplicação do reajuste
								nValDif := (TRBBP7->BP7_VLRANT - TRBBP7->BP7_VLRREA)
							Endif
						Endif



						If nValDif > 0

							If cTipPar == "1"   //Parcela Unica
								nQtdPar := 1    //Apura apenas a Quantidade de Parcelas a ser dividida a cobranca
							EndIf

							//Acumula o valor da diferenca para dividir as parcelas e depois verificar a diferenca para ajustes na ultima parcela.
							nTotDif += nValDif

							//Acumula os meses que nao foram reajustados para que possa gravar no lancamento de debito.
							cMesMen += cAno+"/"+cMes+", "

							
							If cTipPar == "2" // Parcelas atrasadas
								//O sistema ira geras as parcelas atrasadas a partir do proximo mes de fatura
								aadd(aRetUsr,{cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cMesAux,cAnoAux, TRBBM1->BM1_VALOR, TRBBP7->BP7_VLRREA, nValDif,cMesAux})
							Else 
								// Acumula em um array para gerar relatorio
								aadd(aRetUsr,{cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cMes,cAno, TRBBM1->BM1_VALOR, TRBBP7->BP7_VLRREA, nValDif,cMes})
							Endif	

						EndIf
					Else
						If lRetroat // aplica retroativo com desconto contra  beneficiario
							nPos := Ascan(aVlrFai,{ |x| x[2] == cCodFai})
							If nPos > 0 .And. aVlrFai[nPos,3]>0

								//Acumula os meses que nao foram reajustados para que possa gravar no lancamento de debito.
								cMesMen += cAno+"/"+cMes+", "

								// Acumula em um array para gerar relatorio
								aadd(aRetUsr,{cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cMes,cAno, TRBBM1->BM1_VALOR, aVlrFai[nPos,3], 0,cMes})

							EndIf
						Else
							//Verificando a diferença para creditar a favor do beneficiario
							If nValBM1 >= TRBBP7->BP7_VLRANT //Houve o faturamento com valor sem aplicação do reajuste
								nValDif := (TRBBP7->BP7_VLRANT - TRBBP7->BP7_VLRREA)
							Endif

						EndIF
					Endif
				Endif

				TRBBM1->(DbSkip())

			Enddo

			TRBBM1->(DbCloseArea())

			// Validação Parcelamento da Cobranca Retroativa ...
			If nTotDif > 0

				// Parcelamento do Reajuste de Mensalidade Retroativo...

				If  cTipPar == "2"
					//Qtde Parcelas Atrasadas
					nQtdPar := Len(aRetUsr)
				ElseIf	cTipPar == "3" .and. lRetroat

					//Numero de meses ate o proximo reajuste
					cDatIni := CtoD("30/"+cMes+"/"+cAno)
					cDatFim := CtoD("01/"+cMesReaprox+"/"+Str(Val(cAno)+1))
					nQtdPar := Int((cDatFim-cDatIni)/30)

					If nQtdPar <=0
						nQtdPar:=0
					Endif

				ElseIf cTipPar == "4"  .and. lRetroat

					//Quantidade de Parcelas Informadas
					If nQtdPar > 0
						nQtdPar := nQtdParInf
					Else
						// Fecha area de trabalho temporaria...
						TRBBP7->(DbCloseArea())
						Return(.T.)
					EndIf
				ElseIf !lRetroat
					nQtdPar := nQtdMens //numero de meses que irá atender ago/set/out
					cMesAux := M->BHZ_MES
				EndIf

				nValDif := Round((nTotDif / nQtdPar),2)

				If lRetroat

					If nValDif < nVlMinPar
						//Se o valor da parcela for menor que o indicado no parametro
						nQtdPar := 1

						// Atualiza Parcela
						nValDif := Round((nTotDif / nQtdPar),2)
					Endif

					if Len(aRetUsr) > 0
						cAno := aRetUsr[Len(aRetUsr),7]
						cMes := aRetUsr[Len(aRetUsr),6]
					Else
						cAno := cAnoAux
						cMes := cMesAux
					Endif

					If cMes == "12"  // Mes da ultima cobranca gerada
						cMes := "01"
						cAno := Alltrim(Str(Val(cAno)+1))
					Else
						cMes := StrZero(Val(cMes)+1, 2)
					Endif
				Else
					If BHZ->(FieldPos("BHZ_ANOMES")) > 0 .And. ! Empty(M->BHZ_ANOMES)
						cMes := Substr(M->BHZ_ANOMES,(Len(M->BHZ_ANOMES)-1),(Len(M->BHZ_ANOMES)))
						cAno := Substr(M->BHZ_ANOMES,1,4)
					Else
						cMes 	:= StrZero(Val(cMesAux)+nQtdPar,2)
					Endif
				Endif


				cMatricUsr := cCodInt+cCodEmp+cMatric+cTipReg+cDigito

				BSQ->(DbSetOrder(2))

				For nX = 1 to nQtdPar

					If cTipPar == "2"  // - Qtde Parcelas Atrasadas
						nValDif:= aRetUsr[nx,10] //Pego a diferença da parcela atrasada não diluida
					Endif

					If !BSQ->(DbSeek(xFilial("BSQ")+cMatricUsr+cConEmp+cVerCon+cSubCon+cVerSub+cAnoAux+cMesAux)) // Verificando se ja existe o lançamento BSQ

						If aScan(aBkaLancDeb,{|x| x[1] + x[2]+ x[3]+ x[4]+ x[5]+ x[6]+ x[7] == cCodInt+cCodEmp+cMatric+cTipReg+cDigito+cMesAux+cAnoAux})  == 0
							aadd(aLancDeb,{cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cMesAux,cAnoAux,nValDif,cMes,cAno})
							aadd(aBkaLancDeb,{cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cMesAux,cAnoAux,nValDif,cMes,cAno})

							aadd(aResumo,{ cMatricUsr,_TRBBA1->BA1_NOMUSR, cMesAux,cAnoAux,nValDif,"Registro Processado"})
						Endif

					Else
						aadd(aResumo,{ cMatricUsr,_TRBBA1->BA1_NOMUSR, cMesAux,cAnoAux,nValDif,"Registro se encontra processado"})
					Endif

					// Indica a proxima cobranca a ser gerada e que sera a primeira cobranca da parcela
					If cMes >= "12"  // Mes da ultima cobranca gerada
						cMes := "01"
						cAno := Alltrim(Str(Val(cAno)+1))
					Else
						cMes := StrZero(Val(cMes)+1,2)
					Endif

					If cMesAux >= "12"  // Mes da ultima cobranca gerada
						cMesAux := "01"
						cAnoAux := Alltrim(Str(Val(cAnoAux)+1))
					Else
						cMesAux := StrZero(Val(cMesAux)+1,2)
					Endif

				Next

				If Len(aLancDeb) > 0
					PLSPARLANC(cAlias, cMatricUsr, aLancDeb, nQtdPar, nTotDif, cTipo, cMes, cAno, cMesMen, cCodInt, cCodEmp, cMatric,;
						cTipReg, cDigito, cConEmp, cVerCon, cSubCon, cVerSub, cCodLan, cCodigo, cNumLot)
				EndIF
			Endif

			_TRBBA1->(DbSkip())

		Enddo

		_TRBBA1->(DbCloseArea())

		// Fecha area de trabalho temporaria...
		TRBBP7->(DbSkip())

	Enddo

	// Fecha area de trabalho temporaria...
	TRBBP7->(DbCloseArea())

	If !lAuto
		IF lGeroBsq
			If Len(aResumo)
				PLSCRIGEN(aResumo,{ {"Matricula ","@!",40}, {"Beneficiário ","@!",60}, {"Mes ","@!",10} , {"Ano ","@!",10},{"Valor","@E 999,999,999.99",50 }, {"Status ","@!",20}  }  ,"Ocorrencias do processamento ",Nil,Nil)
			Endif
			MsgInfo("Diferenca do Reajuste de Mensalidade gerada","Atenção")
		Else
			MsgStop("Diferenca do Reajuste de Mensalidade não gerada","Atenção")
		Endif
	EndIf

Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA711EXC ³ Autor ³ Luzio Tavares     ³ Data ³ 10.04.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui o lote de cobranca retorativa, excluindo os         ³±±
±±³          ³ lancamentos de debito                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA711EXC(cCodOpe,cCodigo,nOpc)
	LOCAL aErros   	:= {}

	// Monta da query...
	cSQL := "SELECT R_E_C_N_O_ AS BSQRECNO "
	cSQL += "FROM "+RetSQLName("BSQ")+" BSQ WHERE "
	cSQL += "BSQ_FILIAL = '"+xFilial("BSQ")+"' AND "
	cSQL += "BSQ_CODINT = '"+cCodOpe+"' AND "
	cSQL += "BSQ_SEQEST = '"+cCodigo+"' AND "
	cSQL += "BSQ_TABORI = '"+cAlias+"' AND "
	cSQL += "D_E_L_E_T_ = ' '"
	PLSQuery(cSQL,"TRBBSQ")

	TRBBSQ->( DbGoTop() )
	If !TRBBSQ->( EOF() )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia transacao...                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction

			While !TRBBSQ->(Eof())
				BSQ->( DbGoTo(TRBBSQ->BSQRECNO) )

				If Empty(AllTrim(BSQ->BSQ_PREFIX)) .and. Empty(AllTrim(BSQ->BSQ_NUMTIT))
					BSQ->(RecLock("BSQ",.F.))
					BSQ->(DbDelete())
					BSQ->(MsUnLock())
				Else
					aadd(aErros,{"Lancamento de debito "+ BSQ->(BSQ_CODSEQ) + " do beneficiario "+ BSQ->(BDQ_CODOPE+BSQ_CODEMP+BSQ_MATRIC) +" ja se encontra faturado. E necessario exclui-lo do faturamento."})
				Endif

				TRBBSQ->( DbSkip() )
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui lote de cobranca retroativa do reajuste...                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BHZ->(RecLock("BHZ",.F.))
			BHZ->(DbDelete())
			BHZ->(MsUnLock())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza Transacao...                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End Transaction
	EndIf

	// Fecha area de trabalho temporaria...
	TRBBSQ->(dbClosearea())

	// Exibe mensagem caso tenha criticas na exclusao...
	If Len(aErros) > 0
		PLSCRIGEN(aErros,{ {"Criticas","@C",300} },"Foi identificada criticas para esta exclusao de cobranca retroativa de reajuste...")
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Luzio Tavares         ³ Data ³10/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
	Private aRotina := {	{ "Pesquisar"  ,'AxPesqui'  ,  0 , 1  , 0, .F.},;
		{ "Visualizar" ,'PLSA711Mov',  0 , 2 , 0, Nil},;
		{ "Incluir"    ,'PLSA711Mov',  0 , 3 , 0, Nil},;
		{ "Excluir"    ,'PLSA711Mov',  0 , 4 , 0, Nil}}
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSPARLANC  ³ Autor ³Luzio Tavares        | Data ³ 12.04.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lancamento do Reajuste Retorativo das mensalidades    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSPARLANC(cAlias, cMatricUsr, aLancDeb, nQtdPar, nTotDif, cTipo, cMes, cAno, cMesMen, cCodInt, cCodEmp, cMatric, cTipReg, cDigito, cConEmp, cVerCon, cSubCon, cVerSub, cCodLan, cCodigo, cNumLot)
	Local nX := 0
	Local cCodLanBSQ := ""
	Local cCodSeq := ""
	Local cSql := ""
	Local _nH
	Local aNivel := {}
	Local lPL711GRBS := ExistBlock("PL711GRBSQ")

	Default cAlias := ""
	Default cCodigo := ""
	Default cCodLan := ""
	Default cNumLot := ""

	/*
Devido à ANS liberar o percentual de reajuste após a liberação da cobrança, não podemos efetuar o reajuste, porem
após a liberação do percentual podemos efetuar a cobrança retroativa dos meses que não foi reajustado.
Atualmente nosso sistema não faz esta cobrança retroativa, por isso necessitamos que seja revisada a rotina de
reajuste.

Exemplo:

O  mes de reajuste do usuario é o 01 porem a ANS só divulgou agora no mes 04 o indice de reajuste logo desde
janeiro o usuario nao foi reajustado devendo se agora no mes 04 quando tivemos conhecimento do indice.
Logicamente o ususario devera pagar o valor equivalente ao reajuste do mes 01,02,03 e 04 pois nestes meses
foi pago apenas as mensalidades sem reajustes.

Opção:

- Parcela Unica            - Próxima Cobranca: na parcela 05 o beneficiário pagará o valor da parcela 05 reajustado (R$ 110,00) mais a diferença (R$ 40,00) das parcelas 01, 02, 03 e 04, totalizando R$ 150,00.
- Qtde Parcelas Atrasadas  - Parcelas Atrasadas: dividir a diferença (R$ 40,00) em quatro vezes, ou seja, os meses 05, 06, 07 e 08 terao o acréscimo (R$ 10,00) do que não foi pago nos meses 01, 02, 03 e 04, mais o valor reajustado (R$ 110,00), totalizando R$ 120,00.
- Parcelas Prox. Reajuste  - Parcelas Futuras: todas as próximas parcelas (05 a 12) terao o valor reajustado (R$ 110,00) mais a diferença (R$ 40,00) dividida entre elas, totalizando R$ 115,00 (R$ 110, + (R$ 40,00 / 8 parcelas) ).
	*/

	// Pesquisa o codigo do tipo de deb/cred relacionado ao lanc. de
	// faturamento de parcelamento de Cobranca Retroativa de Reajuste de
	// Mensalidade (190)...
	cSql := "SELECT BSP_CODSER FROM "+RetSqlName("BSP")+" WHERE BSP_FILIAL = '"+xFilial("BSP")+"' "
	cSql += "AND BSP_CODLAN = '"+cCodLan+"' "
	cSql += "AND D_E_L_E_T_ = ' ' "
	PlsQuery(cSql, "TRBBSP")

	TRBBSP->( dbGotop() )
	cCodLanBSQ := TRBBSP->BSP_CODSER

	// Fecha area de Trabalho Temporaria...
	TRBBSP->(dbClosearea())

	BA3->(dbSetOrder(1))
	If BA3->(DbSeek(xFilial("BA3")+cMatricFam))  //Posicionando no BA3 com a Familia Usuário correspondente para retornar o nivel correto do PLSMFUN
		aNivel := PLSRETNCB(SubStr(cMatricUsr,1,4),SubStr(cMatricUsr,5,4),SubStr(cMatricUsr,9,6),Nil)
	EndiF

	cMensag := "Diferenca do Reajuste de Mensalidade dos meses "+cMesMen

	_nH := PLSAbreSem("PL711DB.SMF")


	For nX := 1 to len(aLancDeb)

		nVlrParcela := aLancDeb[nX,08]

		cMensag := "Diferenca do Reajuste de Mensalidade do mes "+aLancDeb[nX,09]+"/"+aLancDeb[nX,10] +" Reajuste: "+cNumLot+" "

		cCodSeq := PLSA625Cd("BSQ_CODSEQ","BSQ",1,"D_E_L_E_T_"," ")

		BSQ->(Reclock("BSQ",.T.))
		BSQ->BSQ_FILIAL := xFilial("BSQ")
		BSQ->BSQ_CODSEQ := cCodSeq
		BSQ->BSQ_USUARI := cMatricUsr
		BSQ->BSQ_CODINT := cCodInt
		BSQ->BSQ_CODEMP := cCodEmp
		BSQ->BSQ_CONEMP := cConEmp
		BSQ->BSQ_VERCON := cVerCon
		BSQ->BSQ_SUBCON := cSubCon
		BSQ->BSQ_VERSUB := cVerSub
		BSQ->BSQ_MATRIC := cMatric
		BSQ->BSQ_TIPO   := Posicione("BSP",1,xFilial("BSP")+cCodLanBSQ,"BSP_TIPSER")
		BSQ->BSQ_CODLAN := cCodLanBSQ
		BSQ->BSQ_VALOR  := nVlrParcela
		//Para permitir a exclusao do lancamento pelo lote
		BSQ->BSQ_GUIA   := ""

		BSQ->BSQ_ANO    := aLancDeb[nX,07]
		BSQ->BSQ_MES    := aLancDeb[nX,06]

		BSQ->BSQ_NPARCE := alltrim(strzero(nX,2))
		BSQ->BSQ_COBNIV	:= IIf(aNivel[1],aNivel[5],"")
		BSQ->BSQ_OBS    := cMensag
		BSQ->BSQ_SEQEST := cCodigo
		BSQ->BSQ_CHVEST := cCodInt+cCodigo

		If BSQ->(Fieldpos("BSQ_TABORI")) > 0
			BSQ->BSQ_TABORI      := cAlias
		EndIf
		If BSQ->(Fieldpos("BSQ_CDRETR")) >0
			BSQ->BSQ_CDRETR := M->BHZ_CODIGO
		Endif

		//Gravar na BSQ qual o tipo de empresa a partir da empresa que está selecionada.
		BSQ->BSQ_TIPEMP := BG9->BG9_TIPO

		BSQ->(MsUnlock())

		//Informa que gerou BSQ
		lGeroBsq:=.T.

		// Ativa o Ponto de Entrada logo após a gravação dos valores na BSQ...
		If lPL711GRBS
			ExecBlock("PL711GRBSQ",.F.,.F.)
		Endif

	Next nX

	PLSFechaSem(_nH,"PL711DB.SMF")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVALPARC  ³ Autor ³Luzio Tavarescccc    | Data ³ 12.04.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação de Parcelamento de Co-Participação            	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function VALCODLAN(cCodLan, lValido, cLocalExec)
	Local nCount      := 0
	Local aDados      := {}
	Local cCodLanBSQ  := ""
	Local cSql        := ""
	Local nI          := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa o codigo do tipo de deb/cred relacionado ao lanc. de       ³
	//³ faturamento de parcelamento de Co-Participação (181)...             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := "SELECT BSP_CODSER FROM "+RetSqlName("BSP")+" WHERE BSP_FILIAL = '"+xFilial("BSP")+"' "
	cSql += "AND BSP_CODLAN = '"+cCodLan+"' "
	cSql += "AND D_E_L_E_T_ = ' ' "
	PlsQuery(cSql, "TRBBSP")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Conta os registros obtidos... permitido no maximo 1 registro...     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRBBSP->( dbEval({|| nCount ++ }) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o retorno eh valido...                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCount == 0
		lValido := .F.  //"Não existe cadastrado nenhum TIPO DE LANC. DE DÉBITO relacionado ao código '190' referente DÉBITO, para gerar o Parcelamento do Reajuste Retorativo."
	ElseIf nCount > 1
		PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],cLocalExec)
		aadd(aDados,{{__aCdCri032[1],STR0002,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}}) //"Existe mais de um TIPO DE LANC. DE DÉBITO relacionado ao código '190'referente DÉBITO, para gerar o Parcelamento do Reajuste Retorativo."
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha area de trabalho temporaria...                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRBBSP->(dbClosearea())

Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA711   ºAutor  ³Microsiga           º Data ³  12/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Pls11Grava(nOpca,nopc,lAuto)

	Local i

	Default lAuto := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama funcao generica que realiza o processamento...                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nopc = 3
		If nOpca=1

			lFirst := .T.
			 
			If  !lAuto .AND. (empty(M->BHZ_ANO) .OR. empty(M->BHZ_MES)) 
				MsgInfo(STR0006) //Por favor, preencher o campo de Ano e Mês do reajuste.
				return .F.
			EndIf

			lGrava := PLSA711PRO(	M->BHZ_CODIGO, M->BHZ_CODREA, M->BHZ_CODINT, M->BHZ_ANO, M->BHZ_MES, M->BHZ_EMPDE, M->BHZ_EMPATE,;
				M->BHZ_TIPGRU, M->BHZ_CONDE,  M->BHZ_CONATE, M->BHZ_SUBDE, M->BHZ_SUBATE,;
				M->BHZ_MATDE,  M->BHZ_MATATE, M->BHZ_PROD,   M->BHZ_OPC, M->BHZ_TAX, M->BHZ_USRBLQ,;
				M->BHZ_TIPPAR, M->BHZ_QTDPAR, lAuto)

			//Grava o cabecalho da cobranca retroativa
			nTotCpo := BHZ->(FCount())

			BHZ->(RecLock("BHZ", .T.))

			For i := 1 to nTotCpo
				BHZ->(FieldPut(i, &("M->" + BHZ->(FieldName(i)))))
			Next i

			BHZ->BHZ_FILIAL := xFilial("BHZ")

			BHZ->(MSUnlock())

			BHZ->(ConfirmSX8())

		Endif
	ElseIf  nopc =4
		If nOpca=1
			lfirst:=.T.
			cSQL := "SELECT R_E_C_N_O_ AS REC "
			cSQL += "FROM "+RetSQLName("BSQ")+" BSQ WHERE "
			cSQL += "BSQ_FILIAL = '"+xFilial("BSQ")+"' AND "
			cSQL += "BSQ_SEQEST = '"+BHZ->BHZ_CODIGO+"' AND "
			cSQL += "BSQ_TABORI = 'BHZ' AND "
			cSQL += "D_E_L_E_T_ = ' '"
			PLSQuery(cSQL,"TRBBSQ")

			While ! TRBBSQ->(Eof())
				BSQ->(dbGoTo(TRBBSQ->REC))
				BSQ->(RecLock("BSQ", .F.))
				BSQ->(DbDelete())
				BSQ->(msUnlock())
				TRBBSQ->(DbSkip())
			Enddo

			TRBBSQ->(DbCloseArea())
			RecLock("BHZ", .F.)
			DbDelete()
			msUnlock()
		Endif
	Endif

Return .t.