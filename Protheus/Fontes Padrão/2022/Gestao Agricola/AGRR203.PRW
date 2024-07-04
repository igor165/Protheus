#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AgrR203   º Autor ³ Ricardo Tomasi     º Data ³  24/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para impressão da uma ou varias aplicações.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cliente Microsiga                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function AGRR203(cAlias, nReg)

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Aplicação na Lavoura"
	Local titulo         := "Aplicação na Lavoura"
	Local nLin           := 80
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local aOrd           := {}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "AGRR203" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private cPerg        := "AGR203"
	Private wnrel        := "AGRR203" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString      := "NP1"
	Private nRegistro    := nReg

	dbSelectArea("NP1")
	dbSetOrder(1)

	Pergunte(cPerg,.F.)

	If nRegistro != Nil
		cPerg := ""
	EndIf

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin, nRegistro) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  24/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin, nReg)

	Local cCondicao := ""
	Local cFazenda  := ""
	Local cDataApl  := ""
	Local cFase     := ""
	Local cSafra    := ""
	Local cProduto  := ""
	Local cTalhao   := ""
	Local cArea     := ""
	Local cServico  := ""
	Local lFechada  := .F.
	Local nTotalCC  := 0
	Local cDatFim   := ""
	Local cTotalCC  := ""


	Private cCodAnt := ""

	Cabec1 := "Codigo - Descricao               Qtd Indicada      Qtd Aplicada            Custo"

	dbSelectArea(cString)
	dbSetOrder(1)

	SetRegua(RecCount())

	dbGoTop()

	If nReg != Nil
		dbGoto(nReg)
		cCodAnt   := NP1->NP1_CODIGO
		cCondicao := "!Eof() .And. NP1->NP1_CODIGO == cCodAnt"
	Else
		dbSeek(xFilial("NP1")+MV_PAR01)
		cCondicao := "!Eof() .And. (NP1->NP1_CODIGO >= MV_PAR01 .And. NP1->NP1_CODIGO <= MV_PAR02)"
	EndIf

	While &cCondicao

		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		/*        1         2         3         4         5         6         7
		01234567890123456789012345678901234567890123456789012345678901234567890123456789
		Codigo - Descricao               Qtd Indicada      Qtd Aplicada            Custo

		+---------------------------------------------------+--------------------------+
		|                                                   |                          |
		| Fazenda da Queda Dagua                            | Data Aplicação: 01/01/04 |
		|                                                   |                          |
		+--------------------------+----------------+-------+--------------------------+
		|                          |                |                                  |
		| Fase: Preparação do Solo | Safra: 2005/01 | 0000000001 MILHO IN NATURA       |
		|                          |                |                                  |
		+--------------------------+----------------+----------------------------------+
		|                          |                                                   |
		| Talhao: 01 Proximo a Est | Area da Aplicação: 300 Hectares                   |
		|                          |                                                   |
		+--------------------------+---------------------------------------------------+
		|                                                                              |
		| Serviço: 000001 - CATA DE RAIZES                                             |
		|                                                                              |
		+------------------------------------------------------------------------------+

		--------------------------------- EQUIPAMENTOS ---------------------------------

		---------------------------------- MAO-DE-OBRA ---------------------------------

		----------------------------------- INSUMOS ------------------------------------

		---------------------------------- FECHAMENTO ----------------------------------

		*/
		lFechada := IIf(NP1->NP1_STATUS == "F",.T.,.F.)
		cFazenda := PadC("Fazenda: " + AllTrim(Posicione("NN2",2,xFilial("NN2")+NP1->NP1_FAZ,"NN2_NOME")),49) //49
		cDataApl := PadR("Data Aplicação: " + DToC(NP1->NP1_DATAPL),24) //24
		If NP1->NP1_FASE == "1"
			cFase    := PadR("Fase: Preparação do Solo",24) //24
		ElseIf NP1->NP1_FASE == "2"
			cFase    := PadR("Fase: Plantio",24) //24
		ElseIf NP1->NP1_FASE == "3"
			cFase    := PadR("Fase: Manutenção da Lavoura",24) //24
		ElseIf NP1->NP1_FASE == "4"
			cFase    := PadR("Fase: CoNP2ita",24) //24
		EndIf
		dbSelectArea("NN1")
		dbSetOrder(1)
		dbSeek(xFilial("NN1")+NP1->NP1_SAFRA,.T.)
		cSafra   := PadR("Safra: " + NN1->NN1_ANO + "/" + NN1->NN1_SEQ,14) //14
		cProduto := PadR("Produto: " + AllTrim(NN1->NN1_CODPRO) + " " + NN1->NN1_DESPRO,32) //32
		cTalhao  := PadR("Talhão: " + NP1->NP1_TALHAO + " " + Posicione("NN3",1,xFilial("NN3")+NP1->NP1_SAFRA+NP1->NP1_FAZ+NP1->NP1_TALHAO,"NN3_DESCRI"),24) //24
		cArea    := PadR("Area da Aplicação: " + Transform(NP1->NP1_AREA, X3Picture("NP1_AREA")) + " Hectares",49) //49
		cServico := PadR("Serviço a ser executado: " + AllTrim(NP1->NP1_CODSRV) + " " + NP1->NP1_DESSRV ,76) //76


		@ nLin, 00 PSay "+---------------------------------------------------+--------------------------+"; nLin++
		@ nLin, 00 PSay "|                                                   |                          |"; nLin++
		@ nLin, 00 PSay "| "  +               cFazenda                   + " | " +    cDataApl      + " |";	nLin++
		@ nLin, 00 PSay "|                                                   |                          |";	nLin++
		@ nLin, 00 PSay "+--------------------------+----------------+-------+--------------------------+";	nLin++
		@ nLin, 00 PSay "|                          |                |                                  |";	nLin++
		@ nLin, 00 PSay "| " +      cFase       + " | " + cSafra + " | " +        cProduto          + " |";	nLin++
		@ nLin, 00 PSay "|                          |                |                                  |";	nLin++
		@ nLin, 00 PSay "+--------------------------+----------------+----------------------------------+";	nLin++
		@ nLin, 00 PSay "|                          |                                                   |";	nLin++
		@ nLin, 00 PSay "| " +      cTalhao     + " | " +                cArea                      + " |";	nLin++
		@ nLin, 00 PSay "|                          |                                                   |";	nLin++
		@ nLin, 00 PSay "+--------------------------+---------------------------------------------------+";	nLin++
		@ nLin, 00 PSay "|                                                                              |";	nLin++
		@ nLin, 00 PSay "| " +                            cServico                                  + " |";	nLin++
		@ nLin, 00 PSay "|                                                                              |";	nLin++
		@ nLin, 00 PSay "+------------------------------------------------------------------------------+";	nLin++
		nLin++

		dbSelectArea("NP2")
		dbSetOrder(2) // Ordem por Aplicacao + Tipo
		dbSeek(xFilial("NP2")+NP1->NP1_CODIGO)

		While NP2->NP2_APLIC == NP1->NP1_CODIGO

			nLin += 1
			@ nLin, 00 PSay "--------------------------------- EQUIPAMENTOS ---------------------------------"
			nLin += 1

			While NP2->NP2_APLIC == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == "EQ"

				@ nLin, 00 PSay Subst(AllTrim(NP2->NP2_EQCOD) + " - " + AllTrim(NP2->NP2_EQNOM),1,26)
				@ nLin, 28 PSay NP2->NP2_QTDIND Picture X3Picture("NP2_QTDIND")
				@ nLin, 42 PSay " HR"
				If lFechada
					@ nLin, 46 PSay NP2->NP2_QTDAPL Picture X3Picture("NP2_QTDAPL")
					@ nLin, 60 PSay " HR"
					@ nLin, 64 PSay Subst(MV_SIMB1,1,2)
					@ nLin, 66 PSay NP2->NP2_CUSTO  Picture X3Picture("NP2_CUSTO")
					nTotalCC += NP2->NP2_CUSTO
				EndIf

				nLin := nLin + 1 // Avanca a linha de impressao

				dbSkip()
			EndDo

			nLin += 2
			@ nLin, 00 PSay "---------------------------------- MAO-DE-OBRA ---------------------------------"
			nLin += 1

			While NP2->NP2_APLIC == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == "MO"

				@ nLin, 00 PSay Subst(AllTrim(NP2->NP2_MOCOD) + " - " + AllTrim(NP2->NP2_MONOM),1,26)
				@ nLin, 28 PSay NP2->NP2_QTDIND Picture X3Picture("NP2_QTDIND")
				@ nLin, 42 PSay " HR"
				If lFechada
					@ nLin, 46 PSay NP2->NP2_QTDAPL Picture X3Picture("NP2_QTDAPL")
					@ nLin, 60 PSay " HR"
					@ nLin, 64 PSay Subst(MV_SIMB1,1,2)
					@ nLin, 66 PSay NP2->NP2_CUSTO  Picture X3Picture("NP2_CUSTO")
					nTotalCC += NP2->NP2_CUSTO
				EndIf

				nLin := nLin + 1 // Avanca a linha de impressao

				dbSkip()
			EndDo

			nLin += 2
			@ nLin, 00 PSay "----------------------------------- INSUMOS ------------------------------------"
			nLin += 1

			While NP2->NP2_APLIC == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == "PD"

				@ nLin, 00 PSay Subst(AllTrim(NP2->NP2_PDCOD) + " - " + AllTrim(NP2->NP2_PDNOM),1,26)
				@ nLin, 28 PSay NP2->NP2_QTDIND Picture X3Picture("NP2_QTDIND")
				@ nLin, 42 PSay " " + Subst(NP2->NP2_UM,1,2)
				If lFechada
					@ nLin, 46 PSay NP2->NP2_QTDAPL Picture X3Picture("NP2_QTDAPL")
					@ nLin, 60 PSay " " + Subst(NP2->NP2_UM,1,2)
					@ nLin, 64 PSay Subst(MV_SIMB1,1,2)
					@ nLin, 66 PSay NP2->NP2_CUSTO  Picture X3Picture("NP2_CUSTO")
					nTotalCC += NP2->NP2_CUSTO
				EndIf

				nLin := nLin + 1 // Avanca a linha de impressao

				dbSkip()
			EndDo

			If lFechada

				cDatFim  := PadR("Data do Fechamento: " + DToC(NP1->NP1_DATFIM),37)
				cTotalCC := PadL("Custo Total: " + Subst(MV_SIMB1,1,2) + " " + Transform(nTotalCC,X3Picture("NP2_CUSTO")),36)

				nLin += 2
				@ nLin, 00 PSay "+--------------------------------- FECHAMENTO ---------------------------------+"
				nLin++
				@ nLin, 00 PSay "|                                       |                                      |"
				nLin++
				@ nLin, 00 PSay "| " + cDatFim                       + " | " +                     cTotalCC + " |"
				nLin++
				@ nLin, 00 PSay "|                                       |                                      |"
				nLin++
				@ nLin, 00 PSay "+---------------------------------------+--------------------------------------+"

				nLin += 1

			EndIf

		EndDo

		dbSelectArea("NP1")

		If nReg != Nil
			Roda()
		Else
			Roda()
			nLin := 80
		EndIf

		dbSkip() // Avanca o ponteiro do registro no arquivo
	EndDo

	Set Filter To
	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
