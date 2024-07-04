#include "protheus.ch"
#include "MATR481.ch"
#include "Birtdataset.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³DataSet   ³ MATR481  ³ Autor ³ alfredo.medrano     ³ Data ³  12/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Crea definición Data Set                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR481                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Crea, Filtra y Genera los registros apartir del Data Set   ³±±
±±³          ³ para integracion en el reporte BIRT                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marco Augusto³21/06/19³DMINA-6871 ³Se modifica la consulta a la tabla ³±±
±±³              ³        ³           ³SM0, por la funcion FWSM0Util().   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Dataset MATR481D
	title STR0001  //"Emision de los pedidos de compras"
	description STR0002  //"Data Set del Pedido de Compra SC7"
	PERGUNTE "MATR481"

COLUMNS
	DEFINE COLUMN C7_NUM 	 LIKE C7_NUM
	DEFINE COLUMN C7_ITEM 	 LIKE C7_ITEM
	DEFINE COLUMN C7_QUANT 	 LIKE C7_QUANT
	DEFINE COLUMN C7_UM 		 LIKE C7_UM
	DEFINE COLUMN B1_DESC 	 LIKE B1_DESC
	DEFINE COLUMN C7_PRECO 	 TYPE CHARACTER SIZE 30
	DEFINE COLUMN C7_TOTAL 	 TYPE CHARACTER SIZE 30
	DEFINE COLUMN C7_DATPRF	 TYPE CHARACTER SIZE 13
	DEFINE COLUMN C7_CC 		 LIKE C7_CC
	DEFINE COLUMN C7_NUMSC 	 LIKE C7_NUMSC
	DEFINE COLUMN C7_DESC1	 TYPE CHARACTER SIZE 15
	DEFINE COLUMN C7_DESC2	 TYPE CHARACTER SIZE 15
	DEFINE COLUMN C7_DESC3	 TYPE CHARACTER SIZE 15
	DEFINE COLUMN DESCPROD	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN NOMECOM	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN ENDENT	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN BAIRRO	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN CIDENT	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN ESTENT	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN CEPENT	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN TEL		 TYPE CHARACTER SIZE 100
	DEFINE COLUMN CGS		 TYPE CHARACTER SIZE 100
	DEFINE COLUMN A2_NOME	 LIKE A2_NOME
	DEFINE COLUMN A2_END		 LIKE A2_END
	DEFINE COLUMN A2_NR_END 	 TYPE CHARACTER SIZE 6  LABEL 'A2_NR_END'
	DEFINE COLUMN A2_NROINT	 TYPE CHARACTER SIZE 15 LABEL 'A2_NROINT'
	DEFINE COLUMN A2_BAIRRO	 LIKE A2_BAIRRO
	DEFINE COLUMN A2_EST		 TYPE CHARACTER SIZE 40 DECIMALS 0 LABEL "A2_EST"
	DEFINE COLUMN A2_MUN		 LIKE A2_MUN
	DEFINE COLUMN A2_PAIS	 TYPE CHARACTER SIZE 40 DECIMALS 0 LABEL "A2_PAISDES"
	DEFINE COLUMN A2_CEP		 LIKE A2_CEP
	DEFINE COLUMN A2_TEL		 LIKE A2_TEL
	DEFINE COLUMN LUGARENT	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN LUGARCOB	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN C7_EMISSAO	 TYPE CHARACTER SIZE 13
	DEFINE COLUMN E4_COND	 LIKE E4_COND
	DEFINE COLUMN TOTALMERC 	 TYPE CHARACTER SIZE 30
	DEFINE COLUMN TOTALIMP 	 TYPE CHARACTER SIZE 30
	DEFINE COLUMN TOTALFLETE	 TYPE CHARACTER SIZE 30
	DEFINE COLUMN TOTALGASTO	 TYPE CHARACTER SIZE 30
	DEFINE COLUMN TOTALSEGUR	 TYPE CHARACTER SIZE 30
	DEFINE COLUMN TOTALGRAL	 TYPE CHARACTER SIZE 30
	DEFINE COLUMN MSGBLOQUEO	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN REAJUSTE 	 TYPE CHARACTER SIZE 100
	DEFINE COLUMN IPI			 TYPE CHARACTER SIZE 50
	DEFINE COLUMN ICMS 		 TYPE CHARACTER SIZE 50
	DEFINE COLUMN OBSERVGRL 	 TYPE CHARACTER SIZE 300
	DEFINE COLUMN OBSERVFLE 	 TYPE CHARACTER SIZE 300
	DEFINE COLUMN NUMTIP 	 TYPE NUMERIC   SIZE 3
	DEFINE COLUMN E4_DESCRI 	 LIKE E4_DESCRI
	DEFINE COLUMN IMAGE		 TYPE CHARACTER SIZE 20   label "Imagen"

DEFINE QUERY 	"SELECT C7_NUM, C7_ITEM, C7_QUANT, C7_UM, B1_DESC, C7_PRECO, C7_TOTAL, C7_DATPRF, C7_CC, C7_NUMSC, IMAGE, " + ;
				"C7_DESC1, C7_DESC2, C7_DESC3, DESCPROD, NOMECOM, ENDENT, BAIRRO, CIDENT, ESTENT, CEPENT, TEL, CGS, A2_NOME, "+ ;
				"A2_END, A2_NR_END, A2_NROINT, A2_BAIRRO, A2_EST, A2_MUN, A2_PAIS, A2_CEP, A2_TEL, LUGARENT, LUGARCOB, C7_EMISSAO, E4_COND, TOTALMERC, " + ;
				"TOTALIMP, TOTALFLETE, TOTALGASTO, TOTALSEGUR, TOTALGRAL, MSGBLOQUEO, REAJUSTE, IPI, ICMS, OBSERVGRL, OBSERVFLE, NUMTIP, E4_DESCRI " + ;
				" FROM %WTable:1% "

PROCESS DATASET
	Local lEnd		:= .T.
	Local cDPed	:= self:execParamValue("MV_PAR01")
	Local cAPed	:= self:execParamValue("MV_PAR02")
	Local dDFec	:= self:execParamValue("MV_PAR03")
	Local dAFec	:= self:execParamValue("MV_PAR04")
	Local nSolN	:= self:execParamValue("MV_PAR05") //¿Solo los Nuevos ?
	Local cDesP	:= self:execParamValue("MV_PAR06") //¿Descripción Producto ?
	Local nCUnM	:= self:execParamValue("MV_PAR07") //¿Cuál Unidad de Medida?
	Local nImpr	:= self:execParamValue("MV_PAR08") //¿Imprime ?
	Local nNVia	:= self:execParamValue("MV_PAR09") //¿Número de vias?
	Local nImpP	:= self:execParamValue("MV_PAR10") //¿Imprime Pedidos ?
	Local nCSCs	:= self:execParamValue("MV_PAR11") //¿Considerar SCs ?
	Local nQMon	:= self:execParamValue("MV_PAR12") //¿Que moneda ?
	Local cDEnt	:= self:execParamValue("MV_PAR13") //¿Dirección de Entrega ?
	Local nList	:= self:execParamValue("MV_PAR14") //¿Que Lista ?

	Private cSC7Alias

	If ::isPreview()
		//utilize este método para verificar se esta em modo de preview
		//e assim evitar algum processamento, por exemplo atualização
		//em atributos das tabelas utilizadas durante o processamento
	EndIf

	//cria a tabela
	cSC7Alias := ::createWorkTable()
	//cria uma barra de progresso (opcional)
	Processa( {|lEnd| MTR481REP(@lEnd, cDPed, cAPed, dDFec, dAFec,nSolN,cDesp,nCUnM,nImpr,nNvia,nImpP,nCSCs,nQMon,cDEnt,nList)},;
	          OemToAnsi(STR0019),OemToAnsi(STR0020), .T. ) //"Favor de Aguardar....." + "Generando informe."

	If !lEnd
		//informa ao objeto BIRTReport o motivo do cancelamento
		MSGINFO(OemToAnsi(STR0023))//"No existen datos que satisfagan la condición de selección."
	ELSE
		MSGINFO(STR0022)
	EndIf

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MTR481REP ³ Autor ³ Alfredo Medrano       ³ Data ³20/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Llena el Data Set con los registros Filtrados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MTR481REP(@ExpL1,ExpC2, ExpC3, ExpD4, ExpD5)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 := Logico, Valor de Retorno .T. = ok                 ³±±
±±³          ³ ExpC2 := De Pedido (Num pedido)                            ³±±
±±³          ³ ExpC3 := A Pedido  (Num pedido)                            ³±±
±±³          ³ ExpC4 := De Fecha  (Fecha Emision)                         ³±±
±±³          ³ ExpC5 := A Fecha   (Fecha Emision)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Data Set del Reporte                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MTR481REP(lRet,cDPed, cAPed, dDFec, dAFec,nSolN,cDesp,nCUnM,nImpr,nNvia,nImpP,nCSCs,nQMon,cDEnt,nList)
	Local dFecha		:= Ctod(" / / ")
	Local aRecnoSave	:= {}
	Local cFiltro		:= ""
	Local aValIVA		:= {}
	Local lAuto			:= .F.
	Local nOrder		:= 1
	Local nX       		:= 0
	Local nVias			:= 0
	Local nY			:= 0
	Local nCnt			:= 0
	Local cDesProd		:= ""
	Local cCondBus		:= ""
	Local cTotImp		:= ""
	Local cImpDes		:= ""
	Local cReajus		:= ""
	Local cIPI			:= ""
	Local cICMS			:= ""
	Local cFlete		:= ""
	Local cGasto		:= ""
	Local cSeguro		:= ""
	Local cTotalG		:= ""
	Local cLiber		:= ""
	Local cObsFle		:= ""
	Local cPedBloq		:= ""
	Local cAprov		:= ""
	Local cObserv		:= ""
	Local cOPCC			:= ""
	Local cMSgPed		:= ""
	Local cLugarE		:= ""
	Local cLugarC		:= ""
	Local cProvNome		:= ""
	Local cProvDir		:= ""
	Local cProvNEx		:= ""
	Local cProvNIn		:= ""
	Local cProvCol		:= ""
	Local cProvEst		:= ""
	Local cProvMun		:= ""
	Local cProvPai		:= ""
	Local cProvCP		:= ""
	Local cProvTel		:= ""
	Local cCondPag		:= ""
	Local nret			:= 0
	Local nValIVA		:= 0
	Local cCont			:= ""
	Local aRegCom		:= {}
	Local cRespFil		:= ""
	Local aDatosEmp		:= {}
	Local aFieldSM0		:= {}

	Private cObs01		:= ""
	Private cObs02		:= ""
	Private cObs03  	:= ""
	Private cObs04  	:= ""
	Private cObs05  	:= ""
	Private cObs06  	:= ""
	Private cObs07  	:= ""
	Private cObs08  	:= ""
	Private cObs09  	:= ""
	Private cObs10  	:= ""
	Private cObs11  	:= ""
	Private cObs12  	:= ""
	Private cObs13  	:= ""
	Private cObs14  	:= ""
	Private cObs15  	:= ""
	Private cObs16  	:= ""

   If Type("lPedido") != "L"
		lPedido := .F.
	Endif

   Private cTmpPer	:= CriaTrab(Nil,.F.)
   default lRet := .T.

   chkFile(cTmpPer)
   dbSelectArea("SC7")

	If lPedido
		nQMon := MAX(SC7->C7_MOEDA,1)
	Endif

	If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
		If ( cPaisLoc$"ARG|POR|EUA" )
			cCondBus := "1"+StrZero(Val(cDPed),6)
			nOrder	 := 10 //C7_FILIAL+STR(C7_TIPO,1)+C7_NUM+C7_ITEM+C7_SEQUEN
		Else
			cCondBus := cDPed
			nOrder	 := 1 //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
		EndIf
	Else
		cCondBus := "2"+StrZero(Val(cDPed),6)
		nOrder	 := 10 //C7_FILIAL+STR(C7_TIPO,1)+C7_NUM+C7_ITEM+C7_SEQUEN
	EndIf

	If nList == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif nList == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	dbSelectArea("SC7")
	dbSetOrder(nOrder)
	dbSeek(xFilial("SC7")+cCondBus,.T.)
	cNumSC7 := SC7->C7_NUM

CursorWait()
//inicializa a barra de progreeso
ProcRegua(SC7->(RecCount()))
While !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM >= cDPed .And. SC7->C7_NUM <= cAPed

	If (SC7->C7_CONAPRO == "B" .And. nImpP == 1) .Or.;
		(SC7->C7_CONAPRO <> "B" .And. nImpP == 2) .Or.;
		(SC7->C7_EMITIDO == "S" .And. nSolN == 1) .Or.;
		((SC7->C7_EMISSAO < dDFec) .Or. (SC7->C7_EMISSAO > dAFec)) .Or.;
		((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. nImpr == 2) .Or.;
		(SC7->C7_TIPO == 2 .And. (nImpr == 1 .OR. nImpr == 3)) .Or. !MtrAValOP(nCSCs, "SC7") .Or.;
		(SC7->C7_QUANT > SC7->C7_QUJE .And. nList == 3) .Or.;
		((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. nList == 2 )

		dbSelectArea("SC7")
		dbSkip()
		Loop
	Endif

	MaFisEnd()
	MTR481FC(SC7->C7_NUM,,,cFiltro)

	cObs01    := " "
	cObs02    := " "
	cObs03    := " "
	cObs04    := " "
	cObs05    := " "
	cObs06    := " "
	cObs07    := " "
	cObs08    := " "
	cObs09    := " "
	cObs10    := " "
	cObs11    := " "
	cObs12    := " "
	cObs13    := " "
	cObs14    := " "
	cObs15    := " "
	cObs16    := " "

	IncProc(OemToAnsi(STR0021) + SC7->C7_NUM ) //"Procesando pedido de compra "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Roda a impressao conforme o numero de vias informado no nNVia    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nVias := 1 to nNVia

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dispara a cabec especifica do relatorio.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		nPagina  := 0
		nPrinted := 0
		nTotal   := 0
		nTotMerc := 0
		nDescProd:= 0
		nLinObs  := 0
		nRecnoSC7:= SC7->(Recno())
		cNumSC7  := SC7->C7_NUM

		While !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == cNumSC7

			If (SC7->C7_CONAPRO == "B" .And. nImpP == 1) .Or.;
				(SC7->C7_CONAPRO <> "B" .And. nImpP == 2) .Or.;
				(SC7->C7_EMITIDO == "S" .And. nSolN == 1) .Or.;
				((SC7->C7_EMISSAO < dDFec) .Or. (SC7->C7_EMISSAO > dAFec)) .Or.;
				((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. nImpr == 2) .Or.;
				(SC7->C7_TIPO == 2 .And. (nImpr == 1 .OR. nImpr == 3)) .Or. !MtrAValOP(nCSCs, "SC7") .Or.;
				(SC7->C7_QUANT > SC7->C7_QUJE .And. nList == 3) .Or.;
				((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. nList == 2 )
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Ascan(aRecnoSave,SC7->(Recno())) == 0
				AADD(aRecnoSave,SC7->(Recno()))
			Endif

    		nCnt++
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa o descricao do Produto conf. parametro digitado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDescPro :=  ""
			If Empty(cDesP)
				cDesP := "B1_DESC"
			EndIf

			If AllTrim(cDesP) == "B1_DESC"
				SB1->(dbSetOrder(1))
				SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
				cDescPro := SB1->B1_DESC
			ElseIf AllTrim(cDesP) == "B5_CEME"
				SB5->(dbSetOrder(1))
				If SB5->(dbSeek( xFilial("SB5") + SC7->C7_PRODUTO ))
					cDescPro := SB5->B5_CEME
				EndIf
			ElseIf AllTrim(cDesP) == "C7_DESCRI"
				cDescPro := SC7->C7_DESCRI
			EndIf

			If Empty(cDescPro)
				SB1->(dbSetOrder(1))
				SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
				cDescPro := SB1->B1_DESC
			EndIf

			SA5->(dbSetOrder(1))
			If SA5->(dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
				cDescPro := cDescPro + " ("+Alltrim(SA5->A5_CODPRF)+")"
			EndIf

			If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
				nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
			Else
				nDescProd+=SC7->C7_VLDESC
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializacao da Observacao do Pedido.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SC7->C7_OBS) .And. nLinObs < 17
				nLinObs++
				cVar:="cObs"+StrZero(nLinObs,2)
				Eval(MemVarBlock(cVar),SC7->C7_OBS)
			Endif

			nTxMoeda   := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
			nValTotSC7 := xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)

			nTotal     := nTotal + SC7->C7_TOTAL
			nTotMerc   := MaFisRet(,"NF_TOTAL")

			If nCUnM == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
				nVlUnitSC7 := xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
			ElseIf nCUnM == 1 .And. !Empty(SC7->C7_QUANT) .And. !Empty(SC7->C7_UM)
				nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
			Else
				nTamanCorr  :=143
				nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
			EndIf

			If  nImpr != 1 .OR. nImpr != 3
				If !Empty(SC7->C7_OP)
					cOPCC :=  SC7->C7_OP
				ElseIf !Empty(SC7->C7_CC)
					cOPCC :=  SC7->C7_CC
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona o Arquivo de Empresa SM0.                          ³
			//³ Imprime endereco de entrega do SM0 somente se o cDEnt =" "   ³
			//³ e o Local de Cobranca :                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRespFil := cFilAnt //Se respalda filial actual
			
			cFilAnt := SC7->C7_FILENT //Se setea filial entrega
			
			//Se configurar los campos a retornar
			aFieldSM0 := {"M0_CIDENT", "M0_CIDCOB", "M0_ENDENT", "M0_CEPENT"}
			
			aDatosEmp	:= FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0)
			
			/* Retorna array "aDatosEmp" con la siguiente estructura:
			 * aDatosEmp[1]		:= M0_CIDENT
			 * aDatosEmp[1][2]	:= Contenido
			 * aDatosEmp[2]		:= M0_CIDCOB
			 * aDatosEmp[2][2]	:= Contenido
			 * aDatosEmp[3]		:= M0_ENDENT
			 * aDatosEmp[3][2]	:= Contenido
			 * aDatosEmp[4]		:= M0_CEPENT
			 * aDatosEmp[4][2]	:= Contenido
			*/

			cCident := IIf(Len(aDatosEmp[1][2]) > 20, SubStr(aDatosEmp[1][2], 1, 15), aDatosEmp[1][2])
			cCidcob := IIf(Len(aDatosEmp[2][2]) > 20, SubStr(aDatosEmp[2][2], 1, 15), aDatosEmp[2][2])
			
			cFilAnt := cRespFil //Se retorna de nuevo a la filial actual
			
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))

				//ASIGNA NOMBRE PROVEEDOR
				cProvNome 	:=	Rtrim(SA2->A2_NOME) 		// Nombre Proveedor
				//ASIGNA DIRECCION PROVEEDOR
				cProvDir	:=	Rtrim(SA2->A2_END)  		// Dirección
				//ASIGNA NUM EXT PROVEEDOR
				cProvNEx 	:=	SA2->A2_NR_END  	// Número Exterior
				//ASIGNA NUM INT PROVEEDOR
				cProvNIn 	:=	If(cPaisLoc<>"ARG", SA2->A2_NROINT,"")  	// Número Interior
				//ASIGNA COL PROVEEDOR
				cProvCol 	:=	Rtrim(SA2->A2_BAIRRO)  	// Colonia
				//ASIGNA ESTADO PROVEEDOR
				cProvEst 	:=	Rtrim(POSICIONE("SX5",1,XFILIAL("SX5")+"12"+SA2->A2_EST,"X5_DESCSPA")) // Estado
				//ASIGNA MUNICIPIO PROVEEDOR
				cProvMun 	:=	Rtrim(SA2->A2_MUN)  		// Municipio
				//ASIGNA PAIS PROVEEDOR
				cProvPai 	:=	Rtrim(POSICIONE("SYA",1,XFILIAL("SYA")+SA2->A2_PAIS,"YA_DESCR"))  	// País
				//ASIGNA CP PROVEEDOR
				cProvCP 	:=	OemToAnsi(STR0003) + SA2->A2_CEP 	// CP
				//ASIGNA LADA + TELEFONO PROVEEDOR
				cProvTel 	:= "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) // Teléfono

			EndIf

			If Empty(cDEnt) //"Lugar de Entrega
				//ASIGNA LUGAR DE ENTREGA
				cLugarE := Rtrim(aDatosEmp[3][2]) +"  "+ Rtrim(aDatosEmp[1][2]) + Chr(13)+ Chr(10) + Rtrim(aDatosEmp[2][2]) +"   "+ OemToAnsi(STR0003);
				           +" "+ Trans(Alltrim(aDatosEmp[4][2]),PesqPict("SA2","A2_CEP"))
			Else
				//ASIGNA LUGAR DE ENTREGA
				cLugarE :=	cDEnt //"Lugar de Entrega  : " imprime o endereco digitado na pergunte
			Endif
			
			//Se configurar los campos a retornar
			aFieldSM0 := {"M0_NOME", "M0_ENDCOB", "M0_BAIRCOB", "M0_CIDCOB", "M0_ESTCOB", ;
			 				"M0_CEPCOB", "M0_NOMECOM", "M0_ENDENT", "M0_BAIRENT", "M0_CIDENT", ;
			 				"M0_ESTENT", "M0_CEPENT", "M0_TEL", "M0_CGC"}
			 				
			aDatosEmp	:= FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0)
			
			//ASIGNA LUGAR DE COBRANZA
			cLugarC := RTRIM(aDatosEmp[1][2]) + Chr(13)+ Chr(10) + Rtrim(aDatosEmp[2][2]) +"  "+ Rtrim(aDatosEmp[3][2]) + Chr(13)+ Chr(10) ;
			           + RTRIM(aDatosEmp[4][2]) + " " + aDatosEmp[5][2] +"  "+ OemToAnsi(STR0003) + "  "+ Trans(Alltrim(aDatosEmp[6][2]),PesqPict("SA2","A2_CEP"))
			           
			SE4->(dbSetOrder(1))//E4_FILIAL+E4_CODIGO
			SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))
			
			//ASIGNA CONDICION PAGO
			cCondPag		:= SE4->E4_CODIGO /*+ " - " + RTRIM(SE4->E4_DESCRI)*/

			// aRegCom
			//1 NUMERO DE PEDIDO
	        //2 ITEM
	        //3 CANTIDAD
	        //4 UNIDAD DE MEDIDA
	        //5 FECHA ENTREGA
	        //6 SOLICITUD DE COMPRA
			//7 FECHA DE EMISION
			//8 DESCRIPCIO DEL PRODUCTO
			//9 EL VALOR TOTAL
			//10 PRECIO UNITARIO
			//11 NUMERO DE CC O OP
			//12 NOMBRE SUCURSAL
		    //13 DIRECCION
		    //14 COLONIA
			//15 CIUDAD
			//16 ESTADO
			//17 CP
			//18 TEL
			//19 RFC
			//20 NOMBRE PROVEEDOR
			//21 DIRECCION PROVEEDOR
			//22 NUM EXT PROVEEDOR
			//23 NUM INT PROVEEDOR
			//24 COL PROVEEDOR
			//25 ESTADO PROVEEDOR
			//26 MUNICIPIO PROVEEDOR
			//27 PAIS PROVEEDOR
			//28 CP PROVEEDOR
			//29 LADA + TELEFONO PROVEEDOR
			//30 LUGAR DE ENTREGA
			//31 LUGAR DE COBRANZA
			//32 CONDICION PAGO
			//33 NUMERO DE IMPRESION

			AADD(aRegCom,;
							{;
							  SC7->C7_NUM, SC7->C7_ITEM, SC7->C7_QUANT, SC7->C7_UM, DTOC(SC7->C7_DATPRF), SC7->C7_NUMSC, DTOC(SC7->C7_EMISSAO), ;
							  cDescPro, Transform(nValTotSC7, tm(SC7->C7_TOTAL,14,MsDecimais(nQMon)) ), Transform(nVlUnitSC7, tm(SC7->C7_PRECO,14,MsDecimais(nQMon)) ),;
							  cOPCC, Rtrim(aDatosEmp[7][2]), Rtrim(aDatosEmp[8][2]), Rtrim(aDatosEmp[9][2]), ;
							  Rtrim(aDatosEmp[10][2]), aDatosEmp[11][2], OemToAnsi(STR0003) + aDatosEmp[12][2], OemToAnsi(STR0018) + aDatosEmp[13][2], ;
							  OemToAnsi(STR0017) + aDatosEmp[14][2], cProvNome, cProvDir, cProvNEx,cProvNIn, cProvCol, cProvEst, cProvMun,;
							  cProvPai, cProvCP, cProvTel, cLugarE, cLugarC, cCondPag, nVias;
							})

			nPrinted ++
			lImpri  := .T.
			dbSelectArea("SC7")
			dbSkip()

		EndDo

		SC7->(dbGoto(nRecnoSC7))

		cMensagem:= Formula(C7_MSG)
		If !Empty(cMensagem)
			//oReport:SkipLine()
			cDesProd := PadR(cMensagem,129)
		Endif

		cTotMer:= Transform(xMoeda(nTotal,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(nQMon)) )
		If cPaisLoc<>"BRA"
			aValIVA := MaFisRet(,"NF_VALIMP")
			nValIVA :=0
			If !Empty(aValIVA)
				For nY:=1 to Len(aValIVA)
					nValIVA+=aValIVA[nY]
				Next nY
			EndIf
			cImpDes := SubStr(SE4->E4_DESCRI,1,34)
			dFecha  := dtoc(SC7->C7_EMISSAO)
			cTotImp := Transform(xMoeda(nValIVA,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(nQMon)))
		Else
			cImpDes := SubStr(SE4->E4_DESCRI,1,34)
			dFecha  := dtoc(SC7->C7_EMISSAO)
			cTotImp := Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(nQMon)))
		Endif

		nTotIpi	:= MaFisRet(,'NF_VALIPI')
		nTotIcms  := MaFisRet(,'NF_VALICM')
		nTotDesp  := MaFisRet(,'NF_DESPESA')
		nTotFrete := MaFisRet(,'NF_FRETE')
		nTotSeguro:= MaFisRet(,'NF_SEGURO')
		nTotalNF  := MaFisRet(,'NF_TOTAL')

		SM4->(dbSetOrder(1))
		If SM4->(dbSeek(xFilial("SM4")+SC7->C7_REAJUST))
			 cReajus := OemToAnsi(STR0004) + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR  //"Reajuste :"
		EndIf

		If cPaisLoc == "BRA"
			cIPI := OemToAnsi(STR0005) + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) ,;
			        tm(nTotIpi ,14,MsDecimais(nQMon)))//"IPI      :"

			cICMS := OemToAnsi(STR0006) + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) ,;
			         tm(nTotIcms,14,MsDecimais(nQMon))) //"ICMS     :"
		EndIf

		cFlete := Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) ,;
		          tm(nTotFrete,14,MsDecimais(nQMon))) //"Frete    :"

		cGasto := Transform(xMoeda(nTotDesp ,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) ,;
		          tm(nTotDesp ,14,MsDecimais(nQMon))) //"Despesas :"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializar campos de Observacoes.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cObs02)
			If Len(cObs01) > 30
				cObs := cObs01
				cObs01 := Substr(cObs,1,30)
				For nX := 2 To 16
					cVar  := "cObs"+StrZero(nX,2)
					&cVar := Substr(cObs,(30*(nX-1))+1,30)
				Next nX
			EndIf
		Else
			cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<30,Len(cObs01),30))
			cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<30,Len(cObs01),30))
			cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<30,Len(cObs01),30))
			cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<30,Len(cObs01),30))
			cObs05:= Substr(cObs05,1,IIf(Len(cObs05)<30,Len(cObs01),30))
			cObs06:= Substr(cObs06,1,IIf(Len(cObs06)<30,Len(cObs01),30))
			cObs07:= Substr(cObs07,1,IIf(Len(cObs07)<30,Len(cObs01),30))
			cObs08:= Substr(cObs08,1,IIf(Len(cObs08)<30,Len(cObs01),30))
			cObs09:= Substr(cObs09,1,IIf(Len(cObs09)<30,Len(cObs01),30))
			cObs10:= Substr(cObs10,1,IIf(Len(cObs10)<30,Len(cObs01),30))
			cObs11:= Substr(cObs11,1,IIf(Len(cObs11)<30,Len(cObs01),30))
			cObs12:= Substr(cObs12,1,IIf(Len(cObs12)<30,Len(cObs01),30))
			cObs13:= Substr(cObs13,1,IIf(Len(cObs13)<30,Len(cObs01),30))
			cObs14:= Substr(cObs14,1,IIf(Len(cObs14)<30,Len(cObs01),30))
			cObs15:= Substr(cObs15,1,IIf(Len(cObs15)<30,Len(cObs01),30))
			cObs16:= Substr(cObs16,1,IIf(Len(cObs16)<30,Len(cObs01),30))
		EndIf

		cComprador:= ""
		cAlter	  := ""
		cAprov	  := ""
		lNewAlc	  := .F.
		lLiber 	  := .F.

		dbSelectArea("SC7")
		If !Empty(SC7->C7_APROV)

			cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")
			lNewAlc := .T.
			cComprador := UsrFullName(SC7->C7_USER)
			If SC7->C7_CONAPRO != "B"
				lLiber := .T.
			EndIf
			dbSelectArea("SCR")
			dbSetOrder(1)
			dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
			While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == cTipoSC7
				cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
				Do Case
					Case SCR->CR_STATUS=="03" //Liberado
						cAprov += "Ok"
					Case SCR->CR_STATUS=="04" //Bloqueado
						cAprov += "BLQ"
					Case SCR->CR_STATUS=="05" //Nivel Liberado
						cAprov += "##"
					OtherWise                 //Aguar.Lib
						cAprov += "??"
				EndCase
				cAprov += "] - "
				dbSelectArea("SCR")
				dbSkip()
			Enddo
			If !Empty(SC7->C7_GRUPCOM)
				dbSelectArea("SAJ")
				dbSetOrder(1)
				dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
				While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
					If SAJ->AJ_USER != SC7->C7_USER
						cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
					EndIf
					dbSelectArea("SAJ")
					dbSkip()
				EndDo
			EndIf
		EndIf

		//"Observaciones "
		cSeguro := Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotSeguro,14,MsDecimais(nQMon)))
		cObserv :=	cObs01 + Chr(13)+ Chr(10) + cObs02 + Chr(13)+ Chr(10) + cObs03 + Chr(13)+ Chr(10) + cObs04 + Chr(13)+ Chr(10) + cObs05 + Chr(13)+ Chr(10)
		cObserv +=	cObs06 + Chr(13)+ Chr(10) + cObs07 + Chr(13)+ Chr(10) + cObs08 + Chr(13)+ Chr(10) + cObs09 + Chr(13)+ Chr(10) + cObs10 + Chr(13)+ Chr(10)
		cObserv +=	cObs11 + Chr(13)+ Chr(10) + cObs12 + Chr(13)+ Chr(10) + cObs13 + Chr(13)+ Chr(10) + cObs14 + Chr(13)+ Chr(10) + cObs15 + Chr(13)+ Chr(10)
		cObserv +=	cObs16 + Chr(13)+ Chr(10)

		If !lNewAlc
			cTotalG := Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) ,;
			           tm(nTotalNF,14,MsDecimais(nQMon)))
		Else
			If lLiber
				cTotalG := Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) ,;
				           tm(nTotalNF,14,MsDecimais(nQMon)))
			Else                                                         //"P E D I D O   B L O Q U E A D O " -- "AUTORIZACION DE ENTREGA BLOQUEADA"
				cPedBloq := If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),OemToAnsi(STR0009),OemToAnsi(STR0010))
			EndIf
		EndIf

		cNota := ""
		If !lNewAlc
			cLiber := If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),OemToAnsi(STR0011),OemToAnsi(STR0012)) //"Liberacao do Pedido"##"Liber. Autorizacao "
			cObsFle := IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF",IF(SC7->C7_TPFRETE $ "T",OemToAnsi(STR0013)," " ) ))//Cuenta Terceros
			If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
				cNota := OemToAnsi(STR0014) //"NOTA: Solo aceptaremos la mercaderia si en la Factura consta el numero de nuestro Pedido de Compras."
			Else
				cNota := OemToAnsi(STR0015) //"NOTA: Solo aceptaremos la mercaderia si en la Factura consta el numero de la Autorizacion de Entrega."
			EndIf

		Else
																				//"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
			cMSgPed :=  If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3), If( lLiber ,OemToAnsi(STR0008)  , OemToAnsi(STR0009) ) ,;
			            If( lLiber , OemToAnsi(STR0016) , OemToAnsi(STR0010) ) ) //"PEDIDO BLOQUEADO" -- "AUTORIZACION DE ENTREGA BLOQUEADA"

			cObsFle :=  Substr(RetTipoFrete(SC7->C7_TPFRETE),3) //"Obs. do Frete "

			If (!empty(cNota), cNota := cNota + Chr(13)+ Chr(10), )
			If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
				cNota += OemToAnsi(STR0014) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
			Else
				cNota += OemToAnsi(STR0015) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
			EndIf
		EndIf
		cObserv += cNota +  Chr(13)+ Chr(10) + cLiber

		For nx:= 1 to Len(aRegCom)
			//Guarda los datos en la tabla temporal
			RecLock(cSC7Alias,.T.)
			//ASIGNA NUMERO DE PEDIDO
	        (cSC7Alias)->C7_NUM		:= aRegCom[nx, 1]
	        //ASIGNA ITEM
	        (cSC7Alias)->C7_ITEM 		:= aRegCom[nx, 2]
	        //ASIGNA CANTIDAD
	        (cSC7Alias)->C7_QUANT 	:= aRegCom[nx, 3]
	        //ASIGNA UNIDAD DE MEDIDA
	        (cSC7Alias)->C7_UM		:= aRegCom[nx, 4]
	        //ASIGNA FECHA ENTREGA
	        (cSC7Alias)->C7_DATPRF 	:= aRegCom[nx, 5]
	        //ASIGNA SOLICITUD DE COMPRA
	        (cSC7Alias)->C7_NUMSC 	:= aRegCom[nx, 6]
			//ASIGNA FECHA DE EMISION
			(cSC7Alias)->C7_EMISSAO	:= aRegCom[nx, 7]
			//ASIGNA DESCRIPCIO DEL PRODUCTO
			(cSC7Alias)->B1_DESC 	:= aRegCom[nx, 8]
			//ASIGNA EL VALOR TOTAL
			(cSC7Alias)->C7_TOTAL 	:= aRegCom[nx, 9]
			//ASIGNA PRECIO UNITARIO
			(cSC7Alias)->C7_PRECO 	:= aRegCom[nx, 10]
			//ASIGNA NUMERO DE CC O OP
			(cSC7Alias)->C7_CC		:= aRegCom[nx, 11]
			//ASIGNA NOMBRE SUCURSAL
			(cSC7Alias)->NOMECOM	:= aRegCom[nx, 12]
		   //ASIGNA DIRECCION
			(cSC7Alias)->ENDENT	:= aRegCom[nx, 13]
		   //ASIGNA COLONIA
			(cSC7Alias)->BAIRRO	:= aRegCom[nx, 14]
			//ASIGNA CIUDAD
			(cSC7Alias)->CIDENT	:= aRegCom[nx, 15]
			//ASIGNA ESTADO
			(cSC7Alias)->ESTENT 	:= aRegCom[nx, 16]
			//ASIGNA CP
			(cSC7Alias)->CEPENT 	:= aRegCom[nx, 17]
			//ASIGNA TEL
			(cSC7Alias)->TEL 		:= aRegCom[nx, 18]
			//ASIGNA RFC
			(cSC7Alias)->CGS 		:= aRegCom[nx, 19]
			//ASIGNA NOMBRE PROVEEDOR
			(cSC7Alias)->A2_NOME 	:= aRegCom[nx, 20]
			//ASIGNA DIRECCION PROVEEDOR
			(cSC7Alias)->A2_END 		:=	aRegCom[nx, 21]
			//ASIGNA NUM EXT PROVEEDOR
			(cSC7Alias)->A2_NR_END 	:=	aRegCom[nx, 22]
			//ASIGNA NUM INT PROVEEDOR
			(cSC7Alias)->A2_NROINT 	:=	aRegCom[nx, 23]
			//ASIGNA COL PROVEEDOR
			(cSC7Alias)->A2_BAIRRO 	:=	aRegCom[nx, 24]
			//ASIGNA ESTADO PROVEEDOR
			(cSC7Alias)->A2_EST 		:=	aRegCom[nx, 25]
			//ASIGNA MUNICIPIO PROVEEDOR
			(cSC7Alias)->A2_MUN 		:=	aRegCom[nx, 26]
			//ASIGNA PAIS PROVEEDOR
			(cSC7Alias)->A2_PAIS 	:=	aRegCom[nx, 27]
			//ASIGNA CP PROVEEDOR
			(cSC7Alias)->A2_CEP 		:=	aRegCom[nx, 28]
			//ASIGNA LADA + TELEFONO PROVEEDOR
			(cSC7Alias)->A2_TEL 		:= aRegCom[nx, 29]
			//ASIGNA LUGAR DE ENTREGA
			(cSC7Alias)->LUGARENT 	:= aRegCom[nx, 30]
			//ASIGNA LUGAR DE COBRANZA
			(cSC7Alias)->LUGARCOB 	:= aRegCom[nx, 31]
			//ASIGNA CONDICION PAGO
			(cSC7Alias)->E4_COND		:= aRegCom[nx, 32]
			//ASIGNA DESCRIPCION CONDICION PAGO
			(cSC7Alias)->E4_DESCRI	:= 	cImpDes
			//ASIGNA NUMERO DE IMPRESION
			(cSC7Alias)->NUMTIP		:= aRegCom[nx, 33]


			//*"D E S C O N T O S -->"*/
			//ASIGNA DESCUENTO 1
			(cSC7Alias)->C7_DESC1	:= TransForm(SC7->C7_DESC1,"999.99" ) + " %    "
			//ASIGNA DESCUENTO 2
			(cSC7Alias)->C7_DESC2	:= TransForm(SC7->C7_DESC2,"999.99" ) + " %    "
			//ASIGNA DESCUENTO 3
			(cSC7Alias)->C7_DESC3	:= TransForm(SC7->C7_DESC3,"999.99" ) + " %    "
			//ASIGNA DESCUENTO 3
			(cSC7Alias)->DESCPROD	:= TransForm(xMoeda(nDescProd,SC7->C7_MOEDA,nQMon,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) ,;
			                           PesqPict("SC7","C7_VLDESC",14, nQMon) )
			//ASIGNA TOTAL DE MERCANCIA
			(cSC7Alias)->TOTALMERC	:= cTotMer
			//ASIGNA TOTAL IMPUESTOS
			(cSC7Alias)->TOTALIMP	:= cTotImp
			//ASIGNA TOTAL IMPUESTOS
			(cSC7Alias)->REAJUSTE	:= cReajus //Reajuste
			//ASIGNA IPI
			(cSC7Alias)->IPI			:= cIPI //IPI
			//ASIGNA ICMS
			(cSC7Alias)->ICMS			:= cICMS //IPI
			//ASIGNA TOTAL GASTOS
			(cSC7Alias)->TOTALGASTO	:= cGasto //Gastos
			//ASIGNA TOTAL FLETE
			(cSC7Alias)->TOTALFLETE	:= cFlete //Flete
			//ASIGNA TOTAL SEGURO
			(cSC7Alias)->TOTALSEGUR	:= cSeguro //Seguro
			//ASIGNA TOTAL GENERAL
			(cSC7Alias)->TOTALGRAL	:= cTotalG //Total General
			//ASIGNA MSG DE BLOQUEO
			(cSC7Alias)->MSGBLOQUEO	:= cPedBloq + Chr(13)+ Chr(10) + cMSgPed   //Bloqueo
			//ASIGNA LAS OBSERVACIONES
			(cSC7Alias)->OBSERVGRL	:= cObserv //Observaciones
			//ASIGNA LAS OBSERVACIONES FLETE
			(cSC7Alias)->OBSERVFLE 	:= cObsFle //Observaciones
			//asigna la imagen
			(cSC7Alias)->IMAGE		:= "lgrl"+cEmpAnt+".bmp"

			(cSC7Alias)->(MSUNLOCK())

		Next
		aRegCom:= {}
		cPedBloq 	:= ""
		cMSgPed	:= ""
		cTotalG	:= ""
		cIPI		:= ""
		cICMS		:= ""
		cReajus	:= ""
		cLiber		:= ""

	Next nVias

	MaFisEnd()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SC7")
	If Len(aRecnoSave) > 0
		For nX :=1 to Len(aRecnoSave)
			dbGoto(aRecnoSave[nX])
			If(SC7->C7_QTDREEM >= 99)
				If nRet == 1
					RecLock("SC7",.F.)
					SC7->C7_EMITIDO := "S"
					MsUnLock()
				Elseif nRet == 2
					RecLock("SC7",.F.)
					SC7->C7_QTDREEM := 1
					SC7->C7_EMITIDO := "S"
					MsUnLock()
				Elseif nRet == 3
					//cancelar
				Endif
			Else
				RecLock("SC7",.F.)
				SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
				SC7->C7_EMITIDO := "S"
				MsUnLock()
			Endif
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbGoto(aRecnoSave[Len(aRecnoSave)])
	Endif

	//Aadd(aPedMail,aPedido)

	aRecnoSave := {}

	dbSelectArea("SC7")
	dbSkip()

EndDo

lRet := nCnt > 0

dbSelectArea("SC7")
dbClearFilter()
dbSetOrder(1)
CursorArrow()

return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MTR481FC ³ Autor ³ Alfredo Medrano       ³ Data ³20/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MTR481FC(ExpC1,ExpC2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Data Set del Reporte                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MTR481FC(cPedido,cItem,cSequen,cFiltro)

Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local cValid		:= ""
Local nPosRef		:= 0
Local nItem		:= 0
Local cItemDe		:= IIf(cItem==Nil,'',cItem)
Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
Local cRefCols	:= ''
DEFAULT cSequen	:= ""
DEFAULT cFiltro	:= ""

dbSelectArea("SC7")
dbSetOrder(1)
If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
	MaFisEnd()
	MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
	While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
			SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

		// Nao processar os Impostos se o item possuir residuo eliminado
		If &cFiltro
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf

		// Inicia a Carga do item nas funcoes MATXFIS
		nItem++
		MaFisIniLoad(nItem)
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek('SC7')
		While !EOF() .AND. (X3_ARQUIVO == 'SC7')
			cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
			cValid	:= StrTran(cValid,"'",'"')
			If "MAFISREF" $ cValid
				nPosRef  := AT('MAFISREF("',cValid) + 10
				cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
				// Carrega os valores direto do SC7.
				MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
			EndIf
			dbSkip()
		End
		MaFisEndLoad(nItem,2)
		dbSelectArea('SC7')
		dbSkip()
	End
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.
