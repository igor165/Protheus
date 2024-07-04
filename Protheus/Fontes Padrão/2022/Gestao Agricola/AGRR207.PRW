#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGRR207   º Autor ³ Ricardo Tomasi     º Data ³  24/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio para impressão das quantidades previstas das     º±±
±±º          ³ aplicações.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cliente Microsiga                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGRR207()

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Cronograma previsto das aplicações."
	Local titulo         := "Cronograma Previsto"
	Local nLin           := 80
	
	//                                                                                                   1         1         1         1
	//         1         2         3         4         5         6         7         8         9         0         1         2         3
	//123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//Data Prevista    Fazenda               Talhao   Serviço
	//  ##/##/##       ####################    ##     ########################################
	//----------------------------------------------------------------------------------------
	//Tipo           Grupo                Produto                              UM      Qtd. Apl.     Total HAs    Qtd. Total      Media/HA
	//Mão-de-Obra -> #################### ###################################  ##     ###.###,##    ###.###,##    ###.###,##    ###.###,##
	//Equipamento -> #################### ###################################  ##     ###.###,##    ###.###,##    ###.###,##    ###.###,##
	//Produto     -> #################### ###################################  ##     ###.###,##    ###.###,##    ###.###,##    ###.###,##

	Local Cabec1         := "Safra: "
	Local Cabec2         := "Tipo           Grupo                Produto                              UM                    Total HAs    Qtd. Total      Media/HA"
	Local aOrd           := {"Data Previsto+Desc. Produto"}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "AGRR207"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private cPerg        := "AGR207"
	Private wnrel        := "AGRR207"
	Private cString      := "NP1"

	dbSelectArea("NP1")
	dbSetOrder(1)

	Pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
		Return()
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return()
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return()

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
	Local dData    := dDataBase

	Local cCodFaz  := ''
	Local cCodTal  := ''
	Local cCodSrv  := ''

	Local cFilNP1  := ''
	Local cIndNP1  := ''
	Local cChaNP1  := ''
	Local nIndNP1  := 0

	Cabec1 += AllTrim(Cabec1)+' '+MV_PAR01

	dbSelectArea('NP1')
	dbSetOrder(1)
	cFilNP1 += "NP1_SAFRA == '"      + MV_PAR01 +       "' .And. "
	cFilNP1 += "NP1_FAZ >= '"        + MV_PAR02 +       "' .And. NP1_FAZ <= '"        + MV_PAR03 +       "' .And. "
	cFilNP1 += "NP1_TALHAO >= '"     + MV_PAR04 +       "' .And. NP1_TALHAO <= '"     + MV_PAR05 +       "' .And. "
	cFilNP1 += "NP1_CODSRV >= '"     + MV_PAR06 +       "' .And. NP1_CODSRV <= '"     + MV_PAR07 +       "' .And. "
	cFilNP1 += "DToS(NP1_DATA) >= '" + DToS(MV_PAR08) + "' .And. DToS(NP1_DATA) <= '" + DToS(MV_PAR09) + "'"
	cFilNP1 += IIf(Empty(aReturn[7]),""," .And. "+aReturn[7])
	cIndNP1 := CriaTrab(Nil,.f.)
	cChaNP1 := 'NP1_FILIAL+DToS(NP1_DATA)+NP1_FAZ+NP1_TALHAO+NP1_CODSRV'
	IndRegua("NP1",cIndNP1,cChaNP1,,cFilNP1,"Selecionando Registros...")
	nIndNP1 := RetIndex("NP1")
	dbSelectArea("NP1")
	#IFNDEF TOP
	DbSetIndex(cIndNP1+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndNP1+1)
	dbGotop()

	While .Not. Eof()

		dData   := NP1_DATA
		While .Not. Eof() .And. NP1_DATA == dData

			If nLin > 55
				If nLin < 80
					Roda()
				EndIf
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			EndIf

			cCodFaz := NP1_FAZ
			cCodTal := NP1_TALHAO
			cCodSrv := NP1_CODSRV
			@ nLin, 000 PSay 'Data: '   + DToC(NP1_DATA)
			@ nLin, 018 PSay 'Fazenda: '+ Left(NP1_FAZ+'-'+NP1_FAZNOM,21)
			@ nLin, 050 PSay 'Talhão: ' + NP1_TALHAO
			@ nLin, 062 PSay 'Serviço: '+ Left(NP1_CODSRV+'-'+NP1_DESSRV,30)
			nLin++
			While .Not. Eof() .And. NP1_DATA == dData .And. NP1_FAZ == cCodFaz .And. NP1_TALHAO == cCodTal .And. NP1_CODSRV == cCodSrv

				dbSelectArea('NP2')
				dbSetOrder(2)
				dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'MO')
				While .Not. Eof() .And. NP1->NP1_CODIGO == NP2_CODIGO .And. NP2->NP2_TIPO == 'MO'

					If nLin > 55
						If nLin < 80
							Roda()
						EndIf
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					EndIf

					@ nLin, 000 PSay 'Mão-de-Obra ->'
					@ nLin, 036 PSay NP2->NP2_MONOM
					@ nLin, 074 PSay NP2->NP2_UM
					//@ nLin, 081 PSay Transform(NP2->NP2_QTDAPL,'@E 999,999.99')
					@ nLin, 095 PSay Transform(NP1->NP1_AREA  ,'@E 999,999.99')
					@ nLin, 109 PSay Transform(NP2->NP2_QTDTOT,'@E 999,999.99')
					@ nLin, 123 PSay Transform(NP2->NP2_QTDUNI,'@E 999,999.99')
					nLin++
					dbSelectArea('NP2')
					dbSkip()
				EndDo

				dbSelectArea('NP2')
				dbSetOrder(3)
				dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'EQ')
				While .Not. Eof() .And. NP1->NP1_CODIGO == NP2_CODIGO .And. NP2->NP2_TIPO == 'EQ'

					If nLin > 55
						If nLin < 80
							Roda()
						EndIf
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					EndIf

					@ nLin, 000 PSay 'Equipamento ->'
					@ nLin, 036 PSay NP2->NP2_EQNOM
					@ nLin, 074 PSay NP2->NP2_UM
					//@ nLin, 081 PSay Transform(NP2->NP2_QTDAPL,'@E 999,999.99')
					@ nLin, 095 PSay Transform(NP1->NP1_AREA  ,'@E 999,999.99')
					@ nLin, 109 PSay Transform(NP2->NP2_QTDTOT,'@E 999,999.99')
					@ nLin, 123 PSay Transform(NP2->NP2_QTDUNI,'@E 999,999.99')
					nLin++
					dbSelectArea('NP2')
					dbSkip()
				EndDo

				dbSelectArea('NP2')
				dbSetOrder(4)
				dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'PD')
				While .Not. Eof() .And. NP1->NP1_CODIGO == NP2_CODIGO .And. NP2->NP2_TIPO == 'PD'

					If nLin > 55
						If nLin < 80
							Roda()
						EndIf
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					EndIf

					dbSelectArea('SB1')
					dbSetOrder(1)
					dbSeek(xFilial('SB1')+NP2->NP2_PDCOD)
					If B1_COD < MV_PAR12 .Or. B1_COD > MV_PAR13
						dbSelectArea('NP2')
						dbSkip()
						Loop
					EndIf
					dbSelectArea('SBM')
					dbSetOrder(1)
					dbSeek(xFilial('SBM')+SB1->B1_GRUPO)
					If BM_GRUPO < MV_PAR10 .Or. BM_GRUPO > MV_PAR11
						dbSelectArea('NP2')
						dbSkip()
						Loop
					EndIf
					@ nLin, 000 PSay 'Produto     ->'
					@ nLin, 015 PSay Left(SBM->BM_DESC,15)
					@ nLin, 036 PSay NP2->NP2_PDNOM
					@ nLin, 074 PSay NP2->NP2_UM
					//@ nLin, 081 PSay Transform(NP2->NP2_QTDAPL,'@E 999,999.99')
					@ nLin, 095 PSay Transform(NP1->NP1_AREA  ,'@E 999,999.99')
					@ nLin, 109 PSay Transform(NP2->NP2_QTDTOT,'@E 999,999.99')
					@ nLin, 123 PSay Transform(NP2->NP2_QTDUNI,'@E 999,999.99')
					nLin++
					dbSelectArea('NP2')
					dbSkip()
				EndDo

				dbSelectArea('NP1')
				dbSkip()
			EndDo

			nLin += 1
			@ nLin, 001 PSay '------------------------------------------------------------------------------'
			nLin += 2

		EndDo

	EndDo

	Roda()

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return()

