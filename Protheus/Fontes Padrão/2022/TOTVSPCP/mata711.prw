#INCLUDE "MATA711.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA711  ³ Autor ³ Ary Medeiros          ³ Data ³ 24/08/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ MRP                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS:		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³              |                  ³±±
±±³      02  ³Erike Yuri da Silva       ³10/04/2006    |00000096446       ³±±
±±³      03  ³                          ³              |                  ³±±
±±³      04  ³                          ³              |                  ³±±
±±³      05  ³                          ³              |                  ³±±
±±³      06  ³                          ³              |                  ³±±
±±³      07  ³                          ³              |                  ³±±
±±³      08  ³                          ³              |                  ³±±
±±³      09  ³                          ³              |                  ³±±
±±³      10  ³Erike Yuri da Silva       ³10/04/2006    |00000096446       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function MATA711()

LOCAL oDlg,oQual,oQual2,oUsado,nUsado,nQuantPer:="12",lPrazo,oChk1,nPrazoPag:="30",lPedido
LOCAL oOk := LoadBitmap( GetResources(), "LBOK")
LOCAL oNo := LoadBitmap( GetResources(), "LBNO")
LOCAL cVarQ := cVarQ2:="  "
Local cArqNtx:="",cArqNTX1:=""
LOCAL cSavAlias := Alias()
LOCAL nOk := 0, cFile
Local i

Private lA710Fil := ExistBlock("A710FIL")
Private cA710Fil := ""
PRIVATE aSalIniOPc :={{}}
PRIVATE cSelPer :="",cSelPerSC :=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No. Inicial da Op a ser gerada.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cNumOpDig

Private cArqLog := "MRP.OCR"

Private aSav650 := Array(20)
Private lConsNPT
Private lConsTerc

Pergunte("MTA650",.F.)
//Salvar variaveis existentes
aEval(aSav650, {|z, w| z := &("mv_par"+StrZero(w,2))})

lConsNPT  := (aSav650[14] == 1)
lConsTerc := !(aSav650[15] == 1)

fErase(cArqLog)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a permissao do programa em relacao aos modulos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AMIIn(04,10)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas na geracao de SCS aglutinadas por data  ³
	//³ de necessidade.                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pontos de entrada utilizados para geracao de OPs (MATA650)   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE lMT710C1 := (ExistBlock( "MT710C1" ) )
	PRIVATE lMT710C7 := (ExistBlock( "MT710C7" ) )
	PRIVATE lMT710TL := (ExistBlock( "MT710TL" ) )

	PRIVATE cCadastro := OemToAnsi(STR0001)	//"MRP"
	PRIVATE aTipo:={},cStrTipo,aGrupo:={},cStrGrupo,nIndex
	PRIVATE nTamTipo:=Len(SB1->B1_TIPO)
	PRIVATE nTamGrupo:=Len(SB1->B1_GRUPO)
	PRIVATE aPeriodos:={},aOpcoes[5][7],nNivel := 1,aDiversos:={}
	PRIVATE lGeraPI:= GETMV("MV_GERAPI")
	PRIVATE nTipo	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variaveis utilizadas para salvar parametros                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE nPar01,cAlmoxd,cAlmoxa,nPar02,nPar03,nPar04,nPar05,nPar06,dPar07,dPar08,nPar09,nPar10,nPar11
	PRIVATE lEmpenho,lGeraFirme,lApagaPrev,lConsSabDom,lConsSusp,lConsSacr,lCalcNivel


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a Tabela de Tipos                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Set Deleted ON
	dbSelectArea("SX5")
	dbSeek(xFilial("SX5")+"02")
	Do While (X5_filial == xFilial("SX5")) .AND. (X5_tabela == "02") .and. !Eof()
		cCapital := OemToAnsi(Capital(X5Descri()))
		AADD(aTipo,{.T.,SubStr(X5_chave,1,3)+cCapital})
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a Tabela de Grupos                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SBM")
	dbSeek(xFilial("SBM"))
	Do While (BM_FILIAL == xFilial("SBM")) .AND. !Eof()
		cCapital := OemToAnsi(Capital(BM_DESC))
		AADD(aGrupo,{.T.,SubStr(BM_GRUPO,1,5)+" "+cCapital})
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MV_PAR01     ->  tipo de alocacao        1-p/ fim   2-p/inicio   ³
	//³ MV_PAR02     ->  Geracao de SC.          1-p/OPs    2-p/necess.  ³
	//³ MV_PAR03     ->  Geracao de OP PIS       1-p/OPs    2-p/necess.  ³
	//³ MV_PAR04     ->  Qtd. nossa poder 3§,    1-Subtrai  2-Ignora     ³
	//³ MV_PAR05     ->  Qtd. 3§ em nosso poder, 1-Soma     2-Ignora     ³
	//³ MV_PAR06     ->  Periodo p/Gerar OP/SC   1-Junto    2-Separado   ³
	//³ MV_PAR07     ->  PV/PMP De  Data                                 ³
	//³ MV_PAR08     ->  PV/PMP Ate Data                                 ³
	//³ MV_PAR09     ->  Inc. Num. OP            1- Item	2- Numero    ³
	//³ MV_PAR10     ->  Gera OPs Aglutinadas    1- Sim     2- Nao       ³
	//³ MV_PAR11     ->  OPs Aglutinadas Opcionais 1 - Separa PAI - Nao  ³
	//³ MV_PAR12     ->  Considera Empenhos OPs  1- Sim     2- Nao       ³
	//³ MV_PAR13     ->  De Local                1- Sim     2- Nao       ³
	//³ MV_PAR14     ->  Ate Local               1- Sim     2- Nao       ³
	//³ MV_PAR15     ->  Gera OPs / SCs          1- Firme   2- Prevista  ³
	//³ MV_PAR16     ->  Apaga OPs/SCs Previstas 1- Sim     2- Nao       ³
	//³ MV_PAR17     ->  Considera Sab.?Dom.?    1- Sim     2- Nao       ³
	//³ MV_PAR18     ->  Considera OPs Suspensas 1- Sim     2- Nao       ³
	//³ MV_PAR19     ->  Considera OPs Sacrament 1- Sim     2- Nao       ³
	//³ MV_PAR20     ->  Recalcula Niveis   ?    1- Sim     2- Nao       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte("MTA710",.F.)
	nPar01  := mv_par01
	nPar02  := mv_par02
	nPar03  := mv_par03
	nPar04  := mv_par04
	nPar05  := mv_par05
	nPar06  := mv_par06
	dPar07  := mv_par07
	dPar08  := mv_par08
	nPar09  := mv_par09
	nPar10  := mv_par10
	nPar11  := mv_par11
	lEmpenho:= mv_par12 == 1
	cAlmoxd := mv_par13
	cAlmoxa := mv_par14
	lGeraFirme:= mv_par15 == 1
	lApagaPrev:= mv_par16 == 1
	lConsSabDom:=mv_par17 == 1
	lConsSusp:=mv_par18 == 1
	lConsSacr:=mv_par19 == 1
	lCalcNivel:=mv_par20 == 1

	pergunte("MTA650",.F.)
	If Type('cAlmoxD') == 'C'
		mv_par03 := cAlmoxD
		mv_par04 := cAlmoxA
	EndIf

	If lMT710TL
		ExecBlock("MT710TL",.F.,.F.)
	EndIf

	If !IsInCallStack("MAT711_001")
		DEFINE MSDIALOG oDlg TITLE cCadastro From 145,0 To 445,628 OF oMainWnd PIXEL
		@ 10,15 TO 129,115 LABEL OemToAnsi(STR0002) OF oDlg  PIXEL	//"Periodicidade do MRP"
		@ 25,20 RADIO oUsado VAR nUsado 3D SIZE 70,10 PROMPT  OemToAnsi(STR0003),;	//"Per¡odo Di rio"
			OemToAnsi(STR0004),;	//"Per¡odo Semanal"
			OemToAnsi(STR0005),;	//"Per¡odo Quinzenal"
			OemToAnsi(STR0006),;	//"Per¡odo Mensal"
			OemToAnsi(STR0007),;	//"Per¡odo Trimestral"
			OemToAnsi(STR0008),;	//"Per¡odo Semestral"
			OemToAnsi(STR0009) OF oDlg PIXEL	//"Per¡odos Diversos"
		@ 102,020 Say OemToAnsi(STR0010) SIZE 60,10 OF oDlg PIXEL	//"Quantidade de Per¡odos:"
		@ 102,085 MSGET nQuantPer Picture "99" SIZE 15,10 OF oDlg PIXEL
		@ 10,130 TO 47,300 LABEL "" OF oDlg PIXEL
		@ 18,135 CHECKBOX oChk1 VAR lPrazo PROMPT OemToAnsi(STR0011) SIZE 160, 10 OF oDlg PIXEL ;oChk1:oFont := oDlg:oFont	//"Utiliza o Prazo de Entrega para projetar o desembolso Financeiro"
		@ 32,135 Say OemToAnsi(STR0012) SIZE 70,10 OF oDlg PIXEL	//"Prazo M‚dio de Pagamento:"
		@ 32,205 MSGET nPrazoPag When IIf(lPrazo,.T.,.F.) Picture "99" SIZE 15,10 OF oDlg PIXEL
		@ 50,130 TO 73,300 LABEL "" OF oDlg PIXEL
		@ 58,135 CHECKBOX oChk2 VAR lPedido PROMPT OemToAnsi(STR0013) SIZE 80, 10 OF oDlg PIXEL ;oChk2:oFont := oDlg:oFont	//"Considera Pedidos em Carteira"
		@ 79,130 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0014)  SIZE 75,50 ON DBLCLICK (aTipo:=CA710Troca(oQual:nAt,aTipo),oQual:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual,oOk,oNo,@aTipo) NOSCROLL OF oDlg PIXEL	//"Tipos de Material"
		oQual:SetArray(aTipo)
		oQual:bLine := { || {If(aTipo[oQual:nAt,1],oOk,oNo),aTipo[oQual:nAt,2]}}
		@ 79,225 LISTBOX oQual2 VAR cVarQ2 Fields HEADER "",OemToAnsi(STR0015)  SIZE 75,50 ON DBLCLICK (aGrupo:=CA710Troca(oQual2:nAt,aGrupo),oQual2:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual2,oOk,oNo,@aGrupo) NOSCROLL OF oDlg  PIXEL	//"Grupos de Material"
		oQual2:SetArray(aGrupo)
		oQual2:bLine := { || {If(aGrupo[oQual2:nAt,1],oOk,oNo),aGrupo[oQual2:nAt,2]}}
		DEFINE SBUTTON FROM 137,196 TYPE 5 ACTION MTA711PERG() ENABLE OF oDlg
		DEFINE SBUTTON FROM 137,223 TYPE 1 ACTION (MTA711OK(@nOK,aTipo,aGrupo),IIf(nOk=1,oDlg:End(),)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 137,250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		nOk := 1
	EndIf 

	If nOk = 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta condicao default da projecao                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i:=1 to 7
			If nUsado = i
				aOpcoes[1][i] := "x"
			Else
				aOpcoes[1][i] := " "
			EndIf
		Next i
		aOpcoes[2][1] := Val(nQuantPer)  // Numero de Periodos
		IIf(lPrazo,aOpcoes[3][1] := "x",aOpcoes[3][1] := " ")   // Utiliza Prazo de Entrega para desembolso financeiro
		aOpcoes[4][1] := Val(nPrazoPag)  // Prazo Medio de pagamento
		IIf(lPedido,aOpcoes[5][1] := "x",aOpcoes[5][1] := " ")   // Considera Pedidos em Carteira

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Move aTipo para aStrTipo                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cStrTipo := Space(Len(SB1->B1_TIPO))+"|"
		FOR i:=1 TO LEN(aTipo)
			If aTipo[i,1]
				cStrTipo := cStrTipo+SubStr(aTipo[i,2],1,nTamTipo)+"|"
			EndIf
		Next i

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Move aGrupo para aStrGrupo                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cStrGrupo := Space(Len(SB1->B1_GRUPO))+"|"
		FOR i:=1 TO LEN(aGrupo)
			If aGrupo[i,1]
				cStrGrupo := cStrGrupo+SubStr(aGrupo[i,2],1,nTamGrupo)+"|"
			EndIf
		Next i

		If pergunte("MTA711",.T.)
			If mv_par01 == 1
				If nUsado = 7
					a710Diver()
				EndIf
				pergunte("MTA710",.F.)
				If !IsInCallStack("MAT711_001")
					/*A710Projecao(@cArqNtx,@cArqNtx1)*/
				EndIf
				A710GravaOco()
				If !Empty(cArqNtx)
					dbSelectArea("SC2")
					RetIndex("SC2")
					dbClearFilter()
					Ferase(cArqNtx+OrdBagExt())
				EndIf
			Else
				pergunte("MTA710",.F.)
				/*A710Visual()*/
			EndIf
			If Select("SH5") != 0
				/*A710Browse()*/
				dbSelectArea("OPC")
				dbCloseArea()
				dbSelectArea("SH5")
				dbClearFilter()
				dbCloseArea()
				SHF->(dbCloseArea())
				If !Empty(cArqNtx1)
					dbSelectArea("SHC")
					RetIndex("SHC")
					dbClearFilter()
					Ferase(cArqNtx1+OrdBagExt())
				EndIf
			EndIf
			dbSelectArea(cSavAlias)
		EndIf
	Endif
	DeleteObject(oOk)
	DeleteObject(oNo)

EndIf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A710GravaLog³ Autor ³Marcelo Antonio Iuspa  ³ Data ³ 21/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava arquivo de Log com ocorrencias MRP                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710GravaOco(cTexto)
Local cCr := Chr(13) + Chr(10)
Static nHdl
If nHdl == Nil .Or. ! File(cArqLog)
	nHdl := MSFCreate(cArqLog, 0)
Endif
If cTexto == Nil
	fClose(nHdl)
Else
	do While "  " $ cTexto
		cTexto := StrTran(cTexto, "  ", " ")
	Enddo
	fWrite(nHdl, cTexto + cCr)
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MTA711OK  ³ Autor ³Rodrigo de A. Sartorio ³ Data ³ 09/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Confirmacao antes de executar o MRP                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MTA711OK                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA711OK(nOK,aTipo,aGrupo)
LOCAL nAcho1,nAcho2
nAcho1:=Ascan(aTipo,{|x| x[1] == .T.})
nAcho2:=Ascan(aGrupo,{|x| x[1] == .T.})
If nAcho1 = 0 .Or. nAcho2 = 0
	Help(" ",1,"A710MENU")
	Return .F.
EndIf
Return IIf(MsgYesNo(OemToAnsi(STR0018),OemToAnsi(STR0019)),nOk:=1,nOk:=2)	//"Confirma o MRP ?"###"Aten‡„o"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA711PERG³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 10/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da funcao PERGUNTE                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA711PERG()
Pergunte("MTA710",.T.)
nPar01  := mv_par01
nPar02  := mv_par02
nPar03  := mv_par03
nPar04  := mv_par04
nPar05  := mv_par05
nPar06  := mv_par06
dPar07  := mv_par07
dPar08  := mv_par08
nPar09  := mv_par09
nPar10  := mv_par10
nPar11  := mv_par11
lEmpenho:= mv_par12 == 1
cAlmoxd := mv_par13
cAlmoxa := mv_par14
lGeraFirme:= mv_par15 == 1
lApagaPrev:= mv_par16 == 1
lConsSabDom:=mv_par17 == 1
lConsSusp:=mv_par18 == 1
lConsSacr:=mv_par19 == 1
RETURN NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710Diver  ³ Autor ³ Rosane Luciane Chene³ Data ³ 03/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona Periodos para opcao de apresentacao diversos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A710Diver()
LOCAL nTamArray := Len(aDiversos)
LOCAL dInicio   := dDataBase
Local nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ainda nao foi criado o Array   ³
//³ com as datas, ou se o numero de dias foi   ³
//³ alterado. Se nao foi criado sugere as datas³
//³ com a opcao de diario                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aDiversos) == 0 .Or. aOpcoes[2][1] != Len(aDiversos)
	If aOpcoes[2][1] > Len(aDiversos)
		If Len(aDiversos) == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O inicio do array e'a database             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dInicio := CTOD(DTOC(dDataBase),"ddmmyy")
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso tenha sido aumentado o numero de dias ³
			//³ ele mantem os dados que ja existiam e cria ³
			//³ os novos dias a partir da ultima data do   ³
			//³ array                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dInicio := cTod(aDiversos[Len(aDiversos)],"ddmmyy")
		EndIf
		For nI := 1 to (aOpcoes[2][1] - nTamArray)
			AADD(aDiversos,dToc(dInicio))
			dInicio ++
			While !lConsSabDom .And. ( DOW(dInicio) == 1 .or. DOW(dInicio) == 7 )
				dInicio++
			End
		Next
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso tenha sido diminuido o numero de dias ³
		//³ apaga os dias a mais (do fim para o comeco)³
		//³ e mantem os dados digitados                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI:=Len(aDiversos) to (aOpcoes[2][1]+1) Step -1
			aDel(aDiversos,nI)
			Asize(aDiversos,nTamArray-1)
			nTamArray:=Len(aDiversos)
		Next
	EndIf
EndIf
If !IsInCallStack("MAT711_004")
	/*A710PerDiv()*/
EndIf
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710ProjOP ³ Autor ³ Ary Medeiros        ³ Data ³ 25/08/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz projecao das  OP's em aberto                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710ProjOP()
Local nCusto,nSaldo,cPeriodo,cCampo
Local aNeedDate:={}, dDate, dLead
Local nTotal
Local cTmpSC2 := CriaTrab(,.F.)
Local cQuery  := ""
Local nIndSc2 := 0

dbSelectArea("SC2")
dbSeek(xFilial("SC2"))
nTotal := LastRec()
ProcRegua(nTotal)

dbSelectArea("SC2")
dbSetOrder(1)
cQuery := "C2_FILIAL=='"+xFilial("SC2")+"'.And."
cQuery += "Dtos(C2_DATRF)=='"+Space(8)+"'.And."
cQuery += "C2_LOCAL>='"+cAlmoxd+"'.And."
cQuery += "C2_LOCAL<='"+cAlmoxa+"'"
// Inclui condicao se nao considera OPs Suspensas
If !lConsSusp
	cQuery += ".And.C2_STATUS!='U'"
EndIf
// Inclui condicao se nao considera OPs Sacramentadas
If !lConsSacr
	cQuery += ".And.C2_STATUS!='S'"
EndIf

If lA710Fil
	cA710Fil := ExecBlock("A710FIL", .F., .F., {"SC2", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif

IndRegua("SC2",cTmpSC2,Indexkey(),,cQuery)

nIndSc2 := RetIndex("SC2")
dbSetOrder(nIndSc2+1)
dbGotop()

While ( !Eof() )
	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Tipo e Grupo do Produto                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+SC2->C2_PRODUTO)
	If M710AvalProd()
		dbSelectArea("SH5")
		If ( !dbSeek(SC2->C2_PRODUTO+"2") )
			/*A710Cria(SC2->C2_PRODUTO)*/
			dbSeek(SC2->C2_PRODUTO+"2")
		EndIf
		/*cPeriodo := A650DtoPer(A710DtOp())*/
		If !Empty(cPeriodo)
			If Len(cPeriodo)>2
				cPeriodo	:= SubStr(cPeriodo,2,2)
			EndIf
			cCampo := "H5_PER"+cPeriodo
			Replace &cCampo with &cCampo+Max(0,SC2->C2_QUANT-SC2->C2_QUJE-SC2->C2_PERDA)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao para Controle de Opcionais                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*A710Opc(cPeriodo,SC2->C2_PRODUTO,SC2->C2_OPC,-Max(0,SC2->C2_QUANT-SC2->C2_QUJE-SC2->C2_PERDA))*/
		EndIf
	EndIf
	dbSelectArea("SC2")
	DbSkip()
EndDo
dbSelectArea("SC2")
RetIndex("SC2")
Ferase(cTmpSC2+OrdBagExt())

RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710ProjPed³ Autor ³ Ary Medeiros        ³ Data ³ 25/08/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz projecao dos pedidos de venda (OP's nao geradas)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710ProjPed()
Local nCusto, nSaldo, cPeriodo, cCampo,i
Local dDate, dLead, nLastNivel, aNeedDate := {}
Local nTotal
Local cTmpSC6 := CriaTrab(,.F.)
Local cQuery  := ""
Local nIndSc6 := 0
// Variaveis criadas para prever tamanho de campo com erro - NAO MEXER
Local cComp1  := CriaVar("C6_BLQ")
Local cComp2  := "N"+Space(Len(cComp1)-1)

dbSelectArea("SC6")
dbSeek(xFilial("SC6"))
nTotal := LastRec()

ProcRegua(nTotal)

dbSelectArea("SC6")
dbSetOrder(1)
cQuery := "C6_FILIAL=='"+xFilial("SC6")+"'.And."
cQuery += "(C6_BLQ=='"+cComp1+"'.Or.C6_BLQ=='"+cComp2+"').And."
cQuery += "C6_LOCAL>='"+cAlmoxd+"'.And."
cQuery += "C6_LOCAL<='"+cAlmoxa+"'.And."
cQuery += "((C6_QTDVEN-C6_QTDENT)>0)"

If lA710Fil
	cA710Fil := ExecBlock("A710FIL", .F., .F., {"SC6", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif

IndRegua("SC6",cTmpSC6,IndexKey(),,cQuery)

nIndSc6 := RetIndex("SC6")
dbSetOrder(nIndSc6+1)
dbGotop()

While ( !Eof() )
	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o TES atualiza Estoque                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF4")
	dbSetOrder(1)
	If ( dbSeek(xFilial("SF4")+SC6->C6_TES) .And. SF4->F4_ESTOQUE == "S" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Tipo e Grupo do Produto                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
		If M710AvalProd()
			cPeriodo := A650DtoPer(SC6->C6_ENTREG)
			If Len(cPeriodo)>2
				cPeriodo	:= SubStr(cPeriodo,2,2)
			EndIf
			If RetFldProd(SB1->B1_COD,"B1_FANTASM")== "S" .And. !Empty(cPeriodo)
				MontStr(SC6->C6_PRODUTO,(SC6->C6_QTDVEN-SC6->C6_QTDENT),Val(cPeriodo),,.T.,SC6->C6_OPC)
			Else
				dbSelectArea("SH5")
				dbSetOrder(1)
				If !dbSeek(SC6->C6_PRODUTO+"3")
					/*A710Cria(SC6->C6_PRODUTO)*/
					dbSetOrder(1)
					dbSeek(SC6->C6_PRODUTO+"3")
				EndIf
				If !Empty(cPeriodo)
					cCampo := "H5_PER"+cPeriodo
					Replace &cCampo with &cCampo+(SC6->C6_QTDVEN-SC6->C6_QTDENT)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Funcao para Controle de Opcionais                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					/*A710Opc(cPeriodo,SC6->C6_PRODUTO,SC6->C6_OPC,(SC6->C6_QTDVEN-SC6->C6_QTDENT))*/
				EndIf
			EndIf
		EndIf
	EndIf
	dbSelectArea("SC6")
	dBSkip()
EndDo
dbSelectArea("SC6")
RetIndex("SC6")
Ferase(cTmpSC6+OrdBagExt())

RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710ProjPV ³ Autor ³ Ary Medeiros        ³ Data ³ 25/08/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz projecao da Previsao de Vendas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710ProjPV()
Local nCusto,nSaldo,cPeriodo,cCampo,i
Local dDate, dLead, nLastNivel, aNeedDate := {},nTotal

dbSelectArea("SC4")
dbSeek(xFilial("SC4"))
nTotal := LastRec()
ProcRegua(nTotal)

While !Eof() .And. SC4->C4_FILIAL == xFilial("SC4")
	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Tipo e Grupo do Produto                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+SC4->C4_PRODUTO)
	If M710AvalProd()
		dbSelectArea("SC4")
		If C4_FILIAL == xFilial("SC4") .And. C4_DATA >= dPar07 .And. C4_DATA <= dPar08;
				.And.	SC4->C4_LOCAL >= cAlmoxd .And. SC4->C4_LOCAL <= cAlmoxa
			dbSelectArea("SH5")
			dbSetOrder(1)
			dbSeek(SC4->C4_PRODUTO+"3")
			If !Found()
				/*A710Cria(SC4->C4_PRODUTO)*/
				dbSetOrder(1)
				dbSeek(SC4->C4_PRODUTO+"3")
			EndIf
			cPeriodo := A650DtoPer(SC4->C4_DATA)
			If !Empty(cPeriodo)
				If Len(cPeriodo)>2
					cPeriodo	:= SubStr(cPeriodo,2,2)
				EndIf
				cCampo := "H5_PER"+cPeriodo
				Replace &cCampo with &cCampo+SC4->C4_QUANT
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Funcao para Controle de Opcionais                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*A710Opc(cPeriodo,SC4->C4_PRODUTO,SC4->C4_OPC,SC4->C4_QUANT)*/
			EndIf
		EndIf
	EndIf
	dbSelectArea("SC4")
	DbSkip()
EndDo

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710ProjSC ³ Autor ³ Ary Medeiros        ³ Data ³ 08/10/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz projecao das Solicitacoes de compras                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710ProjSC()
Local cPeriodo,cCampo,nTotal
Local cTmpSC1 := CriaTrab(,.F.)
Local cQuery := ""
Local nIndSc1 := 0

dbSelectArea("SC1")
dbSeek(xFilial("SC1"))
nTotal := LastRec()

ProcRegua(nTotal)

dbSelectArea("SC1")
dbSetOrder(1)

cQuery := "C1_FILIAL=='"+xFilial("SC1")+"'.And."
cQuery += "C1_LOCAL>='"+cAlmoxd+"'.And."
cQuery += "C1_LOCAL<='"+cAlmoxa+"'.And."
cQuery += "C1_QUANT>C1_QUJE"

If lA710Fil
	cA710Fil := ExecBlock("A710FIL", .F., .F., {"SC1", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif

IndRegua("SC1",cTmpSC1,IndexKey(),,cQuery)
nIndSc1 := RetIndex("SC1")


dbSetOrder(nIndSc1+1)
dbGotop()

While ( !Eof() )
	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Tipo e Grupo do Produto                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+SC1->C1_PRODUTO)
	If M710AvalProd()
		// Verifica SC2 se nao considera OPs Suspensas ou se nao considera
		// OPs Sacramentadas
		If !lConsSusp .Or. !lConsSacr .And. !Empty(SC1->C1_OP)
			dbSelectArea("SC2")
			dbSetOrder(1)
			If dbSeek(xFilial("SC2")+SC1->C1_OP)
				// Verifica se considera OPs suspensas
				If !lConsSusp .And. C2_STATUS == "U"
					dbSelectArea("SC1")
					dbSkip()
					Loop
				EndIf
				// Verifica se considera OPs sacramentadas
				If !lConsSacr .And. C2_STATUS == "S"
					dbSelectArea("SC1")
					dbSkip()
					Loop
				EndIf
			EndIf
		EndIf
		dbSelectArea("SH5")
		If ( !dbSeek(SC1->C1_PRODUTO+"2") )
			/*A710Cria(SC1->C1_PRODUTO)*/
			dbSeek(SC1->C1_PRODUTO+"2")
		EndIf
		If nPar01 == 2
			If SC1->C1_DATPRF - CalcPrazo(SC1->C1_PRODUTO,SC1->C1_QUANT-SC1->C1_QUJE) < dDataBase
				cPeriodo := A650DtoPer(dDataBase)   // BOPS 71871     + CalcPrazo(SC1->C1_PRODUTO,SC1->C1_QUANT-SC1->C1_QUJE))
			Else
				cPeriodo := A650DtoPer(SC1->C1_DATPRF)
			EndIf
		Else
			cPeriodo := A650DtoPer(SC1->C1_DATPRF)
		EndIf
		If !Empty(cPeriodo)
			If Len(cPeriodo)>2
				cPeriodo	:= SubStr(cPeriodo,2,2)
			EndIf
			cCampo := "H5_PER"+cPeriodo
			Replace &cCampo with &cCampo+(SC1->C1_QUANT-SC1->C1_QUJE)
		EndIf
	EndIf
	dbSelectArea("SC1")
	DbSkip()
EndDo
dbSelectArea("SC1")
RetIndex("SC1")
Ferase(cTmpSC1+OrdBagExt())
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710ProjPC ³ Autor ³ Ary Medeiros        ³ Data ³ 08/10/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz projecao dos Pedidos de Compras                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710ProjPC()
Local cPeriodo,cCampo,nTotal,dDtPed
Local cTmpSC7 := CriaTrab(,.F.)
Local cQuery  := ""
Local nIndSc7 := 0

dbSelectArea("SC7")
dbSeek(xFilial("SC7"))
nTotal := LastRec()

ProcRegua(nTotal)

dbSelectArea("SC7")
dbSetOrder(1)

cQuery := "C7_FILIAL=='"+xFilial("SC7")+"'.And."
cQuery += "C7_QUANT-C7_QUJE>0.And."
cQuery += "C7_RESIDUO=='"+Space(Len(SC7->C7_RESIDUO))+"'.And."
cQuery += "C7_LOCAL>='"+cAlmoxd+"'.And."
cQuery += "C7_LOCAL<='"+cAlmoxa+"'"

If lA710Fil
	cA710Fil := ExecBlock("A710FIL", .F., .F., {"SC7", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif

IndRegua("SC7",cTmpSC7,IndexKey(),,cQuery)

nIndSc7 := RetIndex("SC7")
dbSetOrder(nIndSc7+1)
dbGotop()

While ( !Eof() )
	IncProc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Tipo e Grupo do Produto                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+SC7->C7_PRODUTO)
	If M710AvalProd()
		// Verifica SC2 se nao considera OPs Suspensas ou se nao considera
		// OPs Sacramentadas
		If !lConsSusp .Or. !lConsSacr .And. !Empty(SC7->C7_OP)
			dbSelectArea("SC2")
			dbSetOrder(1)
			If dbSeek(xFilial("SC2")+SC7->C7_OP)
				// Verifica se considera OPs suspensas
				If !lConsSusp .And. C2_STATUS == "U"
					dbSelectArea("SC7")
					dbSkip()
					Loop
				EndIf
				// Verifica se considera OPs sacramentadas
				If !lConsSacr .And. C2_STATUS == "S"
					dbSelectArea("SC7")
					dbSkip()
					Loop
				EndIf
			EndIf
		EndIf
		dbSelectArea("SH5")
		If ( !dbSeek(SC7->C7_PRODUTO+"2") )
			/*A710Cria(SC7->C7_PRODUTO)*/
			dbSeek(SC7->C7_PRODUTO+"2")
		EndIf
		dDtPed := SC7->C7_DATPRF
		If nPar01 == 2
			If aOpcoes[1][2] != " "  // Forca 2.Feira para semanal
				While Dow(dDtPed) != 2
					dDtPed--
				EndDo
			EndIf
			If dDtPed < dDataBase
				cPeriodo := A650DtoPer(dDataBase)
			Else
				cPeriodo := A650DtoPer(dDtPed)
			EndIf
		Else
			cPeriodo := A650DtoPer(dDtPed)
		EndIf
		If !Empty(cPeriodo)
			If Len(cPeriodo)>2
				cPeriodo	:= SubStr(cPeriodo,2,2)
			EndIf
			cCampo := "H5_PER"+cPeriodo
			Replace &cCampo with &cCampo+(SC7->C7_QUANT-SC7->C7_QUJE)
		EndIf
	EndIf
	dbSelectArea("SC7")
	DbSkip()
EndDo
dbSelectArea("SC7")
RetIndex("SC7")
Ferase(cTmpSC7+OrdBagExt())
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710Pagto  ³ Autor ³ Ary Medeiros        ³ Data ³ 25/08/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devolve nome do campo da necessidade financeira            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC1 := A710Pagto(ExpN2,ExpA3,ExpC4)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Retorna nome do campo                             ³±±
±±³          ³ ExpN2 := Numero do periodo atual                           ³±±
±±³          ³ ExpA3 := Array com periodos                                ³±±
±±³          ³ ExpC4 := Produto atual                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710Pagto(nPeriodo,aPeriodos,cProduto,nQuant)
Local dData, cRet,cPeriodo

dData := aPeriodos[nPeriodo]
If aOpcoes[3][1] == "x"
	dData += CalcPrazo(cProduto,nQuant)
EndIf
dData += aOpcoes[4][1]
cPeriodo := A650DtoPer(dData)
If Empty(cPeriodo)
	cRet := ""
Else
	If Len(cPeriodo)>2
		cPeriodo	:= SubStr(cPeriodo,2,2)
	EndIf
	cRet :="H5_PER"+cPeriodo
EndIf
Return cRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUN‡…O    ³ A710Lote   ³ AUTOR ³ ARY MEDEIROS        ³ DATA ³ 25/08/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRI‡…O ³ Devolve a quantidade considerendo lote econ.,min e toler.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SINTAXE   ³ ExpN1 := A710Lote(ExpN2,ExpC3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PARAMETROS³ ExpN1 := Retorna quantidade                                ³±±
±±³          ³ ExpN2:=  Quantidade a ser considerada                      ³±±
±±³          ³ ExpC3:= Produto a ser pesquisado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A710Lote(nQtdTotal,cProduto,nSaldo)
Local cAlias := Alias()
Local aQtdes := {}, nX
Local nQtdRet := 0

If nSaldo == Nil
	nSaldo := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Tem Sub-estrutura. Se encontrar calcula Lote    ³
//³ economico considerando tambem lote minimo de producao.      ³
//³ Caso contrario calculo LE considerando QTDE EMB para compra.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SG1")
dbSeek(xFilial("SG1")+cProduto)

If Found()
	aQtdes := CalcLote(cProduto,nQtdTotal,"F")
Else
	aQtdes := CalcLote(cProduto,nQtdTotal,"C")
EndIf

For nX := 1 to Len(aQtdes)
	nQtdRet += aQtdes[nX]
Next

dbSelectArea(cAlias)
Return nQtdRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710GeraSC³ Autor ³ Ary Medeiros          ³ Data ³ 04/09/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de geracao de SC's                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710GeraSC(nPeriodo,nQuant,cProduto,lPMP)
Local lRet := .F.
Local nNum:=0,nItem:=0
Local lQuant:=.F.
Local lData :=.F.
Local nQuantBaixa:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica se necessidade foi gerada por PMP                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lPMP:=IF(lPMP==NIL,.F.,lPMP)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto tem contrato de parceria             ³
//³ Se nao, gera solic.Compra; Se sim, gera Autor. de Entrega  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SB1->B1_CONTRAT $"N "
	lRet := A710GravC1(nPeriodo,nQuant,cProduto,,,,lPMP)
Else
	dbSelectArea("SC3")
	dbSetOrder(5)
	If dbSeek(xFilial("SC3")+SB1->B1_COD+SB1->B1_PROC+SB1->B1_LOJPROC)
		While !Eof() .And. SC3->C3_FILIAL+SC3->C3_PRODUTO+SC3->C3_FORNECE+SC3->C3_LOJA == xFilial("SC3")+SB1->B1_COD+SB1->B1_PROC+SB1->B1_LOJPROC
			lData:=.F.
			lQuant:=.F.
			lData:= !(aPeriodos[nPeriodo] >= SC3->C3_DATPRI  .And. ;
				aPeriodos[nPeriodo] <= SC3->C3_DATPRF)
			lQuant:=(SC3->C3_QUANT <= SC3->C3_QUJE .And. SC3->C3_ENCER =="E")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao Considera Contratos de Parceria Encerrados ou fora da data³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	lData .Or. lQuant
				dbSkip()
				Loop
			EndIf
			Exit
		EndDo
	EndIf
	If Eof() .Or. lData .Or. lQuant
		lRet := A710GravC1(nPeriodo,nQuant,cProduto,.T.,,,lPMP)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera P.C. somente do saldo disponivel no Contrato          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQuantBaixa:=If((SC3->C3_QUANT-SC3->C3_QUJE) <= nQuant,(SC3->C3_QUANT-SC3->C3_QUJE),nQuant)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem numero da proxima AE                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC7")
		dbSeek(xFilial("SC7")+"z",.T.)
		dbSkip(-1)
		If xFilial("SC7") == SC7->C7_FILIAL
			nNum := Val(C7_NUM)+1
		Else
			nNum := 1
		EndIf
		nItem := 1
		If A710GravC7(nNum,nItem,nPeriodo,nQuantBaixa,cProduto)
			If __lSX8
				ConFirmSX8()
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera S.C. da quantidade que nao foi atendida pelo Contrato ³
		//³ de Parceria                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nQuantBaixa < nQuant
			lRet := A710GravC1(nPeriodo,nQuant - nQuantBaixa,cProduto,.T.,.F.,.T.,lPMP)
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710GravC7³ Autor ³ Marcos Bregantim      ³ Data ³ 20/05/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de gravacao SC's                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710GravC7(nNum,nItem,nPeriodo,nQuant,cProduto)
Local cAlias := Alias(),cCpo, lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao Emite SC's para Mao-de-Obra                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !IsProdMod(SB1->B1_COD) .And. (SB1->B1_TIPO != "BN" .Or. (SB1->B1_TIPO == "BN" .And. MatBuyBN())) // nao gera para mao de obra e tipo = "BN" (Beneficiamento)

	Begin Transaction

		dbSelectArea("SC7")
		RecLock("SC7",.T.)
		Replace	C7_FILIAL  	With xFilial("SC7") ,;
				C7_NUMSC   	With SC3->C3_NUM    ,;
				C7_ITEMSC  	With SC3->C3_ITEM   ,;
				C7_PRECO   	With SC3->C3_PRECO  ,;
				C7_LOJA    	With SC3->C3_LOJA   ,;
				C7_TOTAL   	With nQuant*SC3->C3_PRECO,;
				C7_IPI     	With SC3->C3_IPI    ,;
				C7_COND	  	With SC3->C3_COND   ,;
				C7_CONTATO 	With SC3->C3_CONTATO,;
				C7_FILENT  	With SC3->C3_FILENT	,;
				C7_REAJUST 	With SC3->C3_REAJUST,;
				C7_FRETE   	With SC3->C3_FRETE  ,;
				C7_DATPRF  	With aPeriodos[nPeriodo],;
				C7_LOCAL   	With SC3->C3_LOCAL  ,;
				C7_FORNECE  With SC3->C3_FORNECE,;
				C7_PRODUTO 	With SC3->C3_PRODUTO,;
				C7_MSG	  	With SC3->C3_MSG    ,;
				C7_TPFRETE 	With SC3->C3_TPFRETE,;
				C7_OBS     	With SC3->C3_OBS    ,;
				C7_QUANT   	With nQuant         ,;
				C7_UM      	With SB1->B1_UM     ,;
				C7_SEGUM   	With SB1->B1_SEGUM  ,;
				C7_CONTA   	With SB1->B1_CONTA  ,;
				C7_CC 		With SB1->B1_CC     ,;
				C7_TIPO		With 2              ,;
				C7_DESCRI  	With SB1->B1_DESC   ,;
				C7_QTSEGUM 	With ConvUm(SB1->B1_COD,nQuant,0,2),;
				C7_NUM      With StrZero(nNum,Len(C7_NUM)),;
				C7_ITEM     With StrZero(nItem,Len(C7_ITEM)),;
				C7_QUJE	  	With 0              ,;
				C7_DESC1    With 0              ,;
				C7_DESC2   	With 0              ,;
				C7_DESC3    With 0              ,;
				C7_EMISSAO  With dDataBase      ,;
				C7_EMITIDO 	With "N"            ,;         // Emitido o relatorio de PC
				C7_QTDREEM 	With 0              ,;         // Qtde que foi emitido o PC
				C7_CODLIB  	With Space(Len(C7_CODLIB)) ,;  // Controle de Alcada
				C7_NUMCOT  	With Space(Len(C7_NUMCOT)) ,;  // Numero da Cotacao
				C7_TX       With Space(Len(C7_TX))     ,;  // Transmissao de Arquivos
				C7_CONTROL 	With Space(Len(C7_CONTROL)),;  // Controle de Alcadas
				C7_ENCER    With " "                   ,;  // " "- PC em aberto , "E" - PC encerrado
				C7_IPIBRUT 	With "B"                   ,;  // IPI calculado pelo Bruto
				C7_OP       With Space(Len(C7_OP))	   ,;
				C7_TPOP		With If(lGeraFirme,"F","P"),;
				C7_TIPCOM With MRetTipCom(,.T.,"PC") //-- Executa avaliação do tipo de Compra
		nQuant:=SC7->C7_QUANT
		If lMT710C7
			ExecBlock( "MT710C7",.F.,.F. )
		EndIf

		dbSelectArea("SC3")
		RecLock("SC3",.F.)
		Replace C3_QUJE 	With C3_QUJE + nQuant
		If C3_QUANT - C3_QUJE <= 0
			Replace C3_ENCER 	With "E"
		EndIf
		MsUnlock()

		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2")+cProduto+SC7->C7_LOCAL)
		If Eof()
			CriaSB2(cProduto,SC7->C7_LOCAL)
		EndIf
		GravaB2Pre("+",SC7->C7_QUANT,SC7->C7_TPOP)

		If !IsInCallStack("MAT711_013")
			If !Empty(nPeriodo)
				cCpo := "H5_PER"+StrZero(nPeriodo,2)
				dbSelectArea("SH5")
				dbSetOrder(1)
				dbSeek(cProduto+"2")
				RecLock("SH5",.F.)
				Replace &(cCpo) with &(cCpo)+nQuant
				dbSeek(cProduto+"5")
				dbSetOrder(2)
				RecLock("SH5",.F.)
				Replace &(cCpo) with &(cCpo)-nQuant
			EndIf
		EndIf

	End Transaction

Else

	lRet := .F.

EndIf

dbSelectArea(cAlias)

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710SalIni ³ Autor ³ Ary Medeiros        ³ Data ³ 08/10/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz analise dos saldos iniciais                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710SalIni()
Local cProduto, nTotal, nSaldo, nRec
Local aOpc    :={}
Local cTmpSB2 := ""
Local cQuery  := ""
Local nIndSb2 := 0
Local lMT710B2:= ExistBlock("MT710B2")
Local lM710NOPC:=ExistBlock("M710NOPC")
Local nz

cQuery := 'B2_FILIAL == "'+xFilial("SB2")+'".And.'
cQuery += 'B2_LOCAL >= "'+cAlmoxd+'" .and. B2_LOCAL <= "'+cAlmoxa+'"'

// Executa P.E. para tratar filtro do SB2
If lMT710B2
	cQuery:=ExecBlock("MT710B2",.F.,.F.,cQuery)
EndIf

cTmpSB2:= CriaTrab(,.F.)
IndRegua("SB2",cTmpSB2,"B2_FILIAL+B2_COD+B2_LOCAL",,cQuery,STR0088)	//"Gerando Indice Cond.Saldos"

nIndSb2 := RetIndex("SB2")
dbSetOrder(nIndSb2+1)

dbSelectArea("SB1")
dbSeek(xFilial("SB1"))
nTotal := LastRec()

ProcRegua(nTotal)


While !Eof() .And. B1_FILIAL == xFilial("SB1")
	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao utilize TOP ou AXS filtra registros aqui³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !M710AvalProd()
		dbSkip()
		Loop
	EndIf
	nRec := Recno()
	cProduto := SB1->B1_COD
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2")+cProduto)
	nSaldo := 0
	While !Eof() .And. B2_FILIAL+B2_COD == xFilial("SB2")+cProduto
		nSaldo += B2_QATU
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Considera quantidade nossa em poder de 3§   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPar04 == 1
			nSaldo += B2_QNPT
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Considera quantidade de 3§ em nosso poder   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPar05 == 1
			nSaldo -= B2_QTNP
		EndIf
		dbSkip()
	EndDo
	nSaldo -= CalcEstSeg( RetFldProd(SB1->B1_COD,"B1_ESTFOR") )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada MA710NOPC para Necessidade        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lM710NOPC
		aOpc := ExecBlock('M710NOPC',.F.,.F.,{SB1->B1_COD,nSaldo})
		If ValType(aOpc) == 'A'
			For nz:=1 to Len(aOpc)
				/*A710SIniOpc(SB1->B1_COD,aOPc[nz,1],aOPc[nz,2],"1")*/
			Next nz
		EndIf
	EndIf
	dbSelectArea("SH5")
	If !(dbSeek(cProduto+"1"))
		/*A710Cria(cProduto)*/
		dbSeek(cProduto+"1")
	EndIf
	Replace H5_PER01 with nSaldo
	dbSelectArea("SB1")
	DbGoto(nRec)
	DbSkip()
EndDo

dbSelectArea("SB2")
RetIndex("SB2")
Ferase(cTmpSB2+OrdBagExt())

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A710GetSa³ Autor ³ Ary Medeiros          ³ Data ³ 04/09/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar o Saldo do SB2.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A710GetSaldo(cProduto)
Local nSaldo, cAlias := Alias()
Local lMT710B2:= ExistBlock("MT710B2")
Local cQuery := "B2_LOCAL>='"+cAlmoxd+"'.And.B2_LOCAL<='"+cAlmoxa+"'"

// Executa P.E. para tratar filtro do SB2
If lMT710B2
	cQuery:=ExecBlock("MT710B2",.F.,.F.,cQuery)
EndIf

dbSelectArea("SB1")
dbSeek(xFilial("SB1")+cProduto)
dbSelectArea("SB2")
dbSeek(xFilial("SB2")+cProduto)
nSaldo := 0
Do While !SB2->(Eof()) .And. B2_COD == cProduto .and. B2_FILIAL == xFilial("SB2")
	If &(cQuery)
		nSaldo += B2_QATU
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Considera quantidade nossa em poder de 3§   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPar04 == 1
			nSaldo += B2_QNPT
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Considera quantidade de 3§ em nosso poder   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPar05 == 1
			nSaldo -= B2_QTNP
		EndIf
	EndIf
	SB2->(dBSkip())
EndDo
nSaldo -= CalcEstSeg( RetFldProd(SB1->B1_COD,"B1_ESTFOR") )
dbSelectArea(cAlias)
Return nSaldo

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MontStr  ³ Autor ³ Marcos Bregantim      ³ Data ³ 28/10/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta um array com a estrutura do produto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ MontStr(ExpC1,ExpN1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpN1 = Quantidade base a ser explodida                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function MontStr(cProduto,nQuant,nXi,nPrazo,lFant,cOpcionais)
LOCAL nOldRecno:=Recno(),nOldOrder:=IndexOrd(),cOldAlias:=Alias()
LOCAL nQuantItem,nRegFan,cTipo,cNivel,nTime
LOCAL cGravaOpc:="",nAchouOpc:=0
LOCAL aEstru:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcionais utilizados devem ser considerados em     ³
//³ todos os niveis da estrutura                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOpcionais:=IIF(cOpcionais == NIL,CriaVar("G1_OPC"),cOpcionais)
lFant := IIf(lFant == Nil,.F.,lFant)

If lFant
	nPrazo := IIf(nPrazo == Nil,0,nPrazo)
Else
	nPrazo := 0
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no produto desejado                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SG1")
dbSeek(xFilial("SG1")+cProduto)

While !Eof() .And. G1_FILIAL+G1_COD == xFilial("SG1")+cProduto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza necessidade dos componentes da estrutura  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQuantItem := ExplEstr(nQuant,aPeriodos[nXi],cOpcionais)
	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+SG1->G1_COMP)
	If (QtdComp(nQuantItem) == QtdComp(0)) .Or. !(Found()) .Or. (RetFldProd(SB1->B1_COD,"B1_MRP") == "N" .And. RetFldProd(SB1->B1_COD,"B1_FANTASM") != "S") .Or. !(SB1->B1_TIPO $ cStrTipo .and. SB1->B1_GRUPO$cStrGrupo) // Ignora os nao selecionados
		dbSelectArea("SG1")
		dbSkip()
		Loop
	EndIf
	dbSelectArea("SG1")
	nRegFan := SG1->(Recno())
	If dbSeek(xFilial("SG1")+SG1->G1_COMP)
		cNivel:= SG1->G1_NIV
		cTipo := "F"
	Else
		cNivel:="99"
		cTipo := "C"
	EndIf
	dbGoTo(nRegFan)

	If (RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S") .Or. (cTipo == "F" .And. !lGeraPI)
		If !lFant
			nTime := CalcPrazo(cProduto,nQuantItem)
		Else
			nTime := nPrazo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa variavel dos opcionais                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nQuantItem > 0 .And. !Empty(cOpcionais) .And. ;
				!Empty(SG1->G1_GROPC) .And. !Empty(SG1->G1_OPC) .And. ;
				(SG1->G1_GROPC+SG1->G1_OPC $ cOpcionais)
			cGravaOpc+=SG1->G1_GROPC+SG1->G1_OPC+"/"
		EndIf
		MontStr(SG1->G1_COMP,nQuantItem,nXi,nTime,.T.,cOpcionais)
	Else
		If nQuantItem > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incrementa variavel dos opcionais                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cOpcionais) .And. !Empty(SG1->G1_GROPC) .And. ;
					!Empty(SG1->G1_OPC) .And. (SG1->G1_GROPC+SG1->G1_OPC $ cOpcionais)
				cGravaOpc+=SG1->G1_GROPC+SG1->G1_OPC+"/"
			EndIf
			If !lFant
				nTime := CalcPrazo(cProduto,nQuantItem)
			Else
				nTime := 0
			EndIf
			dDate := aPeriodos[nXi] - (nTime + nPrazo)
			dbSelectArea("SH5")
			dbSetOrder(1)
			dbSeek(SG1->G1_COMP+"3")
			If !Found()
				/*A710Cria(SG1->G1_COMP)*/
				dbSetOrder(1)
				dbSeek(SG1->G1_COMP+"3")
			EndIf
			dbSetOrder(2)
			cPeriodo := A650DtoPer(dDate)
			If !Empty(cPeriodo)
				If Len(cPeriodo)>2
					cPeriodo	:= SubStr(cPeriodo,2,2)
				EndIf
				cCampo := "H5_PER"+cPeriodo
				nEntradas :=  &(cCampo)+nQuantItem
				Replace &(cCampo) with nEntradas
				/*A710NecEst(SG1->G1_COMP, cPeriodo, nQuantItem)*/
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao para Controle de Opcionais                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*A710Opc(cPeriodo,SG1->G1_COMP,cOpcionais,nQuantItem,SG1->G1_COD)*/
		EndIf
	EndIf
	dbSelectArea("SG1")
	dbGoTo(nRegFan)
	dbSkip()
Enddo
dbSelectArea(cOldAlias);dbSetOrder(nOldOrder);dbGoto(nOldRecno)
// Grava opcionais corretos no arquivo de opcionais
If !Empty(cOpcionais)
	Reclock("OPC",.F.)
	Replace OPCIONAL With IF(nPar10 == 1,cGravaOpc,cOpcionais)
	If nPar10 == 1 .And. nPar11 == 1
		// Salva area
		nOldRecno:=Recno();nOldOrder:=IndexOrd();cOldAlias:=Alias()
		aEstru:=Estrut(cProduto,nQuant)
		nAchouOpc:=ASCAN(aEstru,{|x| x[6]+x[7] $ Alltrim(cOpcionais)})
		If nAchouOpc > 0
			Reclock("OPC",.F.)
			Replace OPCIONAL With cOpcionais
		EndIf
		// Restaura area
		dbSelectArea(cOldAlias);dbSetOrder(nOldOrder);dbGoto(nOldRecno)
	EndIf
	If Empty(OPCIONAL)
		Reclock("OPC",.F.,.T.)
		dbDelete()
	EndIf
	MsUnlock()
EndIf
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710NivC2 ³ Autor ³ Marcos Bregantim      ³ Data ³ 30/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os niveis no SC2                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A710NivC2()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710NivC2(nTotal)
ProcRegua(nTotal)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acerta os niveis do arquivo de OP's (SC2)                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC2")
dbSeek(xFilial("SC2"))

While !Eof() .And. C2_FILIAL == xFilial("SC2")
	nTotal--
	IncProc()
	If SC2->C2_LOCAL >= cAlmoxd .And. SC2->C2_LOCAL <= cAlmoxa .And. If(!lConsSusp,C2_STATUS!="U",.T.) .And. If(!lConsSacr,C2_STATUS!="S",.T.)
		dbSelectArea("SG1")
		dbSeek(xFilial("SG1")+SC2->C2_PRODUTO)
		dbSelectArea("SC2")
		RecLock("SC2",.F.)
		Replace C2_NIVEL With StrZero(100-Val(SG1->G1_NIV),2)
		Msunlock()
	EndIf
	dbSkip()
EndDo

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ A710OPPMP ³ Autor ³ Wilson Junior         ³ Data ³ 14/12/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Faz MRP pelo Inicio de Op e PMP                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A710OPPMP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function A710OPPMP(cArqNtx,cArqNtx1)
Local nIndex,nTotal

nTotal := LastRec() * 2
dbSeek("SHC")
nTotal += LastRec() * 2

Processa({|lEnd| A710NivC2(@nTotal)},STR0089,OemToAnsi(STR0090),.F.)	//"Analise de OPs e PMPs"###"Analisando OPs e PMPs ..."
Processa({|lEnd| A710Proc(@cArqNtx,nIndex,@cArqNTX1,nTotal)},STR0089,OemToAnsi(STR0090),.F.)	//"Analise de OPs e PMPs"###"Analisando OPs e PMPs ..."

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710CALCDT³ Autor ³ Ary Medeiros          ³ Data ³ 04/09/92 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710CALCDT(cProd,nQuant)
Local cAlias := Alias(),nRegG1:=SG1->(Recno()),nRegB1:=SB1->(Recno())
Local nNeces:=0,dMin:=CTOD("  /  /  "),dCalc
dbSelectArea("SB1")
dbSeek(xFilial("SB1")+cProd)
dbSelectArea("SG1")
dbSeek(xFilial("SG1")+cProd)
Do While !Eof() .and. xFilial("SG1")+cProd == SG1->G1_FILIAL+SG1->G1_COD
	If A710NAOMRP(SG1->G1_COMP)
		dbSkip()
		Loop
	EndIf
	nNeces := ExplEstr(nQuant)
	If A710FANTASMA(SG1->G1_COMP)
		dMin := A710CALCDT(SG1->G1_COMP,nNeces)
	Else
		/*dCalc:= A710VESALDO(SG1->G1_COMP,nNeces)*/
		dMin := IIf(dMin > dCalc,dMin,dCalc)
	EndIf
	dbSelectArea("SG1")
	dbSkip()
EndDo
dMin := dMin  // +CalcPrazo(cProd,nQuant)
SB1->(dbGoto(nRegB1))
SG1->(dbGoto(nRegG1))
dbSelectArea(cAlias)
Return(dMin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710GRSH5  ³ Autor ³ Ary Medeiros         ³ Data ³ 04/09/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710GRSH5(cProduto,dDataProd,nQuant,cOpcionais,lOp)
Local cAlias := Alias()
Local dDataRec := dDataProd - CalcPrazo(cProduto,nQuant)
Local nRegG1:=SG1->(Recno()),nRegB1 := SB1->(Recno()),nRegG1A,lEof, nTenho
Local nNeces:=0
Local cPeriodo := A650DtoPer(dDataProd)

Static nRecursiva
nRecursiva := If(nRecursiva == Nil, 1, nRecursiva + 1)
If Len(cPeriodo)>2
	cPeriodo	:= SubStr(cPeriodo,2,2)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcionais utilizados devem ser considerados em     ³
//³ todos os niveis da estrutura                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOpcionais:=IIF(cOpcionais == NIL,CriaVar("G1_OPC"),cOpcionais)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se explode necessidades por empenho       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lOp:=IIF(lOp == NIL,.F.,lOp .And. lEmpenho)

If !lOp
	dbSelectArea("SB1")
	dbSeek(xFilial("SB1")+cProduto)
	dbSelectArea("SG1")
	dbSeek(xFilial("SG1")+cProduto)
	Do While !Eof() .and. xFilial("SG1")+cProduto == SG1->G1_FILIAL+SG1->G1_COD
		If A710NAOMRP(SG1->G1_COMP)
			dbSkip()
			Loop
		EndIf
		nNeces := ExplEstr(nQuant,dDataProd,cOpcionais)
		nRegG1A := Recno()
		dbSeek(xFilial("SG1")+SG1->G1_COMP)
		lEof:= Eof()
		dbGoto(nRegG1A)
		If A710FANTASMA(SG1->G1_COMP)
			A710GRSH5(SG1->G1_COMP,dDataRec,nNeces,cOpcionais)
		Else
			If !lEof
				/*nTenho := A710Saldo(SG1->G1_COMP,dDataRec-CalcPrazo(SG1->G1_COMP))*/
				If nNeces > nTenho
					/*A710ENTPI(SG1->G1_COMP,dDataRec,nNeces-nTenho)*/
					A710GRSH5(SG1->G1_COMP,dDataRec,nNeces-nTenho,cOpcionais)
				EndIf
			EndIf
			dbGoto(nRegG1A)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Funcao para Controle de Opcionais                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nRecursiva == 1 .Or. nPar01 == 1 .Or. A710FANTASMA(SG1->G1_COD)
				/*A710Opc(cPeriodo,SG1->G1_COMP,cOpcionais,nNeces,SG1->G1_COD)*/
				/*A710SH5SAI(SG1->G1_COMP,dDataRec,nNeces)*/
			Endif
		EndIf
		dbSelectArea("SG1")
		dbSkip()
	EndDo
	SB1->(dbGoto(nRegB1))
	SG1->(dbGoto(nRegG1))
	dbSelectArea(cAlias)
Else
	dbSelectArea("SD4")
	dbSetOrder(2)
	dbSeek(xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD)
	Do While !Eof() .And. D4_FILIAL+D4_OP == xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD
		If A710NAOMRP(SD4->D4_COD)
			SD4->(dbSkip())
			Loop
		EndIf
		/*A710SH5SAI(SD4->D4_COD,SD4->D4_DATA,SD4->D4_QUANT)*/
		SD4->(dbSkip())
	EndDo
EndIf
nRecursiva --
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710FANTASM³ Autor ³ Ary Medeiros         ³ Data ³ 04/09/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710FANTASMA(cProduto)
Local nRegB1 := SB1->(Recno()),lRet:=.F.,nRegG1:=SG1->(Recno())
SB1->(dbSeek(xFilial("SB1")+cProduto))

If RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S"
	lRet := .T.
ElseIf !lGeraPI
	SG1->(dbSeek(xFilial("SG1")+cProduto))
	lRet := SG1->(Found())
EndIf
SB1->(dbGoto(nRegB1))
SG1->(dbGoto(nRegG1))
Return(lRet)

Static Function CriaTr2()
Local aStru

IF Select("TR2") > 0
	dbSelectArea("TR2")
	dbCloseArea()
Endif

aStru:={}
AADD(aStru ,{"T2_PRODUTO","C",15,0})
AADD(aStru ,{"T2_PERIODO","C",2,0})
AADD(aStru ,{"T2_QTDE","N",18,5})
//cArquivo := CriaTrab(aStru,.T.)
//Use &cArquivo Alias TR2 Exclusive New Via __LocalDriver
//IndRegua("TR2",cArquivo,"T2_PRODUTO+T2_PERIODO",,,STR0057)	//"Selecionando Registros..."
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CalcPrazo2  ³ Autor ³Marcelo Antonio Iuspa  ³ Data ³ 22/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o Prazo de entrega baseando na estrutura e saldos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CalcPrazo1(cProduto, nNeces)
Local aEstru := {}, cSeek, x, nPos, nRet
dbSelectArea("SG1")
dbSetOrder(1)
dbSeek(cSeek := xFilial("SG1") + cProduto)
Do While ! Eof() .And. cSeek == G1_FILIAL + G1_COD
	Aadd(aEstru, {G1_COMP, G1_QUANT * nNeces, 0})
	dbSkip()
Enddo
For x := 1 to Len(aEstru)
	If dbSeek(cSeek := xFilial("SG1") + aEstru[x, 1])
		Do While ! Eof() .And. cSeek == G1_FILIAL + G1_COD
			If (nPos := aScan(aEstru, {|a| a[1] == G1_COMP})) = 0
				Aadd(aEstru, {G1_COMP, 0, 0})
				nPos := Len(aEstru)
			Endif
			aEstru[nPos, 2] += G1_QUANT * aEstru[x, 2]
			dbSkip()
		Enddo
	Endif
Next
For x := 1 to Len(aEstru)
	SB2->(dbSeek(xFilial("SB2") + aEstru[x,1]))
	If SaldoSB2() < aEstru[x, 2]
		aEstru[x, 3] := CalcPrazo(aEstru[x, 1], aEstru[x, 2])
	Endif
Next
aEstru := aSort(aEstru,,, {|a,b| a[3] > b[3]})
nRet := If(Len(aEstru)>0,aEstru[1,3],0)
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710OpenNec³ Autor ³ Marcelo Iuspa         ³ Data ³ 16/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria/Abre arquivo SHF e indices para controle de necessidade ³±±
±±³          ³por estrutura                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA710                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710OpenNec(lErase)
Local cArqSHF := "SHF" + Substr(cNumEmp,1,2)+"0"
Local aTamOP  := TamSX3("C2_QUANT")
Local aArea	 := GetArea()


RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³M710AvalProd³ Autor ³Rodrigo de A. Sartorio ³ Data ³ 29/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avalia se Produto devera ser Considerado ou Nao no MRP       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M710AvalProd()
Static lMT710B1
Local lRet:=(SB1->B1_TIPO$cStrTipo) .And. (SB1->B1_GRUPO$cStrGrupo) .And. (RetFldProd(SB1->B1_COD,"B1_MRP")$" S")

lMT710B1:=If(ValType(lMT710B1) == "L",lMT710B1,ExistBlock("MT710B1"))

// Executa P.E. para tratar filtro do SB1
If lRet .And. lMT710B1
	lRet:=ExecBlock("MT710B1",.F.,.F.,SB1->B1_COD)
	If ValType(lRet) # "L"
		lRet:=.T.
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710GravC1³ Autor ³ Marcos Bregantim      ³ Data ³ 20/05/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de gravacao SC's                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710GravC1(nPeriodo,nQuant,cProduto,lAutEnt,lSemData,lSemQuant,lPMP)
Static cUser

Local cAlias := Alias(),cCpo, lRet := .T.
Local cNum:=CriaVar("C1_NUM")
Local cItem:="01"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem usuario e grupo de compras utilizado                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cUser == NIL
	cUser 	:= RetCodUsr()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica se necessidade foi gerada por PMP                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lPMP:=IF(lPMP==NIL,.F.,lPMP)

lAutEnt := IIf(lAutEnt==NIL,.F.,lAutEnt)
lSemData:= IIf(lSemData==NIL,.F.,lSemData)
lSemQuant:= IIf(lSemQuant==NIL,.F.,lSemQuant)

If Empty(cNum)
	cNum := ProximoNum("SC1")
Else
	If __lSX8
		ConFirmSX8()
	EndIf
	dbSelectArea("SC1")
	dbSetOrder(1)
	While dbSeek(xFilial("SC1")+cNum,.F.)
		cNum:=GetSX8Num("SC1","C1_NUM")
		If __lSX8
			ConFirmSX8()
		EndIf
	End
EndIf

dbSelectArea("SB1")
dbSeek(xFilial("SB1")+cProduto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao Emite SC's para Mao-de-Obra                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !IsProdMod(SB1->B1_COD) .And. (SB1->B1_TIPO != "BN" .Or. (SB1->B1_TIPO == "BN" .And. MatBuyBN())) // nao gera para mao de obra e tipo = "BN" (Beneficiamento)

	Begin Transaction

		dbSelectArea("SC1")
		RecLock("SC1",.T.)
		Replace C1_FILIAL  With xFilial("SC1"),;
			C1_NUM     With cNum,;
			C1_ITEM    With cItem,;
			C1_PRODUTO With cProduto,;
			C1_DESCRI  With SB1->B1_DESC,;
			C1_UM      With SB1->B1_UM,;
			C1_SEGUM   With SB1->B1_SEGUM,;
			C1_LOCAL   With RetFldProd(SB1->B1_COD,"B1_LOCPAD"),;
			C1_CC      With SB1->B1_CC,;
			C1_FORNECE With SB1->B1_PROC,;
			C1_LOJA    With SB1->B1_LOJPROC,;
			C1_QUANT   With nQuant,;
			C1_QTSEGUM With ConvUm(SB1->B1_COD,nQuant,0,2),;
			C1_EMISSAO With dDataBase,;
			C1_DATPRF  With aPeriodos[nPeriodo],;
			C1_SOLICIT WITH "MRP",;
			C1_IMPORT With SB1->B1_IMPORT,;
			C1_TPOP With If(lGeraFirme,"F","P"),;
			C1_GRUPCOM With MaRetComSC(SB1->B1_COD,UsrRetGrp(),cUser),;
			C1_USER	 With cUser,;
			C1_TIPCOM With MRetTipCom(,.T.,"SC") //-- Executa avaliação do tipo de Compra

		If lMT710C1
			ExecBlock( "MT710C1",.F.,.F. )
		EndIf
		If lAutEnt
			If lSemData
				Replace C1_OBS With STR0086	//"FORA DA DATA CONTR. PARCERIA"
			ElseIf lSemQuant
				Replace C1_OBS With STR0093	//"QUANT. DO CONTRATO ESGOTADA"
			Else
				Replace C1_OBS With STR0087	//"SEM CONTRATO DE PARCERIA"
			EndIf
		EndIf

		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2")+cProduto+SC1->C1_LOCAL)
		If Eof()
			CriaSB2(cProduto,SC1->C1_LOCAL)
		EndIf
		GravaB2Pre("+",SC1->C1_QUANT,SC1->C1_TPOP)

		If !Empty(nPeriodo) .And. !lPMP
			cCpo := "H5_PER"+StrZero(nPeriodo,2)
			dbSelectArea("SH5")
			dbSetOrder(1)
			dbSeek(cProduto+"2")
			RecLock("SH5",.F.)
			Replace &(cCpo) with &(cCpo)+nQuant
			dbSeek(cProduto+"5")
			dbSetOrder(2)
			RecLock("SH5",.F.)
			Replace &(cCpo) with &(cCpo)-nQuant
		EndIf

	End Transaction

Else

	lRet := .F.

EndIf

dbSelectArea(cAlias)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A710NAOMRP ³ Autor ³ Ary Medeiros         ³ Data ³ 04/09/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A710NAOMRP(cProduto)
Local nRegB1 :=SB1->(Recno()),lRet := .F.
SB1->( dbSeek(xFilial("SB1")+cProduto) )
If !M710AvalProd()
	lRet := .T.
EndIf
SB1->( dbGoto(nRegB1) )
Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ A710Proc  ³ Autor ³ Wilson Junior         ³ Data ³ 14/12/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Processa MRP pelo Inicio de Op e PMP                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A710Proc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA711                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function a710Proc(cArqNtx,nIndex,cArqNTX1,nTotal)

LOCAL cCond
LOCAL cPeriodo
LOCAL cQuery:=""
// Inclui condicao se nao considera OPs Suspensas
If !lConsSusp
	cQuery += "C2_STATUS!='U'"
	If !lConsSacr
		cQuery += ".And."
	EndIf
EndIf
// Inclui condicao se nao considera OPs Sacramentadas
If !lConsSacr
	cQuery += "C2_STATUS!='S'"
EndIf

ProcRegua(nTotal)

dbSelectArea("SHC")
dbSetOrder(1)
dbSeek(xFilial("SHC"))

Do While !Eof() .and. xFilial("SHC") == HC_FILIAL
	If !Empty(HC_STATUS) .Or. A710NAOMRP(SHC->HC_PRODUTO)
		dbSkip()
		Loop
	EndIf
	IncProc()
	dbSelectArea("SG1")
	dbSeek(xFilial("SG1")+SHC->HC_PRODUTO)
	dbSelectArea("SHC")
	RecLock("SHC")
	Replace HC_NIVEL With Strzero(100-Val(SG1->G1_NIV),2)
	MsUnLock()
	dbSkip()
EndDo

dbSelectArea("SC2")
// GERACAO DA OP E SC DEVE SER PELO INVERSO DO NIVEL DO SH5

If lA710Fil
	cA710Fil := ExecBlock("A710FIL", .F., .F., {"SC2", cQuery})
	If ValType(cA710Fil) == "C"
		cQuery := cA710Fil
	Endif
Endif

cArqNtx := CriaTrab(,.F.)

IndRegua("SC2",cArqNtx,"C2_FILIAL+C2_NIVEL+Dtos(C2_DATRF)+C2_PRODUTO",,cQuery,STR0091)	//"Gerando Indice OP's"

nIndex := RETINDEX("SC2")
dbSetOrder(nIndex+1)
dbGoTop()
dbSelectArea("SC2")
dbSeek(xFilial("SC2"))

// Ordem inversa do nivel+dtos(data)
Do While !Eof() .and. xFilial("SC2") == C2_FILIAL
	IncProc()
	If !Empty(C2_DATRF) .or. (C2_QUANT-C2_QUJE-C2_PERDA) <=0 .Or. A710NAOMRP(SC2->C2_PRODUTO);
			.Or. SC2->C2_LOCAL < cAlmoxd .Or. SC2->C2_LOCAL > cAlmoxa
		dbSkip()
		Loop
	EndIf
	nQtd := C2_QUANT-C2_QUJE-C2_PERDA

	CriaTR2()                    // Recriar o TR2
	dbSelectArea("SC2")
	dPrazo := A710CALCDT(C2_PRODUTO,nQtd)
	/*dPrazo := IIf(A710DtOp() > dPrazo,A710DtOp(),dPrazo)*/
	cPeriodo := A650DtoPer(dPrazo)
	If Len(cPeriodo)>2
		cPeriodo	:= SubStr(cPeriodo,2,2)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao para Controle de Opcionais                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*A710Opc(cPeriodo,SC2->C2_PRODUTO,SC2->C2_OPC,-nQtd)*/
	A710GRSH5(C2_PRODUTO,dPrazo,nQtd,C2_OPC,.T.)
	RecLock("SC2")
	Replace C2_DTUPROG With dPrazo
	Replace C2_DATAJF With dPrazo
	Replace C2_DATAJI With dPrazo - CalcPrazo(C2_PRODUTO,nQtd)
	/*A710SH5ENT(C2_PRODUTO,dPrazo,nQtd)*/
	dbSelectArea("SC2")
	MsUnLock()
	dbSkip()
EndDo

dbSelectArea("SHC")
cArqNtx1 := CriaTrab(,.F.)
cCond:='HC_STATUS = "'+Space(LEN(SHC->HC_STATUS))+'" .And. HC_OP == "'+Space(Len(SHC->HC_OP))+'" .And. DTOS(HC_DATA)>="'+DTOS(dPar07)+'".And.DTOS(HC_DATA)<="'+DTOS(dPar08)+'"'
If lA710Fil
	cA710Fil := ExecBlock("A710FIL", .F., .F., {"SHC", cCond})
	If ValType(cA710Fil) == "C"
		cCond := cA710Fil
	Endif
Endif
IndRegua("SHC",cArqNtx1,"HC_FILIAL+HC_NIVEL+HC_DATA+HC_PRODUTO",,cCond,STR0092)	//"Gerando Indice PMP's"

nIndex := RETINDEX("SHC")
dbSetOrder(nIndex+1)
dbGoTop()
dbSeek(xFilial("SHC"))

// Ordem inversa do nivel+dtos(data)
Do While !Eof() .and. xFilial("SHC") == HC_FILIAL
	IncProc()
	If A710NAOMRP(SHC->HC_PRODUTO)
		dbSkip()
		Loop
	EndIf

	CriaTR2()     //Cria um TR2 NOVO

	dbSelectArea("SHC")
	dPrazo := A710CALCDT(HC_PRODUTO,HC_QUANT)
	dPrazo := IIf(dPrazo > HC_DATA,dPrazo,HC_DATA)
	cPeriodo := A650DtoPer(dPrazo)
	If Len(cPeriodo)>2
		cPeriodo	:= SubStr(cPeriodo,2,2)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao para Controle de Opcionais                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*A710Opc(cPeriodo,HC_PRODUTO,HC_OPC,HC_QUANT)*/
	A710GRSH5(HC_PRODUTO,dPrazo,A710Lote(HC_QUANT, HC_PRODUTO),HC_OPC)
	RecLock("SHC",.F.)
	Replace HC_DTAJU WITH dPrazo
	/*A710SH5ENT(HC_PRODUTO,dPrazo,HC_QUANT)*/
	dbSelectArea("SHC")
	MsUnLock()
	dbSkip()
EndDo
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ CA710Troca                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 09.01.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Troca marcador entre x e branco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaPCP ú Advanced                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CA710Troca(nIt,aArray)
aArray[nIt,1] := !aArray[nIt,1]
Return aArray