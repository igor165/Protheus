#INCLUDE "qmtm420.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE NORMAL   "1"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTM420  ³ Autor ³ Wanderley Goncalves   ³ Data ³ 14/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exportacao das Cartas de Controle (SPC)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaQMT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 14/08/00 ³Consultar instr.+rev. no QMR ao inves do QMK.    ³±±
±±³Denis M.  ³ 14/05/01 ³Passar Limite Inferior e Superior para construcao³±±
±±³          ³          ³do grafico de histograma.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTM420
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAlias := Alias()
Local cTit := OemToAnsi(STR0004)	// "Cartas Individuais"
Local lCont := .t.

Private cIndex1
Private nIndex,nOpt1 := 1
Private cMarca := GetMark()
Private lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecao da geracao das Cartas de Controle:                   ³
//³ mv_par01: Instrumento                                        ³
//³ mv_par02: Revisao                                            ³
//³ mv_par03: Escala                                             ³
//³ mv_par04: Data de Medicao De                                 ³
//³ mv_par05: Data de Medicao Ate'                               ³
//³ mv_par06: Responsavel                                        ³
//³ mv_par07: Valores Iniciais / Valores Finais                  ³
//³ mv_par08: Todas as Medicoes / Media     // Eliminado         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("QM2")
DbSetOrder(1)

If Pergunte("QMM420",.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o Instrumento / Revisao                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QM2->(dbSeek(xFilial("QM2")+mv_par01+Inverte(mv_par02)))
		Help(" ",1,"QMTINSTNAO")	// "Instrumento/Revisao nao cadastrados."
		lCont := .f.
	EndIf

	If lCont
		QMR->(DbSetOrder(1))            
		If !QMR->(DbSeek(xFilial("QMR")+QM2->QM2_INSTR+QM2->QM2_REVINS+mv_par03))
			Help(" ",1,"QMTESCNAO")	// "Escala nao associada a familia do Instrumento"
			lCont := .f.
		EndIf					
	EndIf

	If lCont
		M420MontBrw(mv_par03,cTit)
	EndIf

Endif	

dbSelectArea(cAlias)

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M420MontBrw³ Autor ³ Wanderley Goncalves ³ Data ³ 14/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta browse para a escolha dos Pontos - MarkBrowse        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M420MontBrw(ExpC1,ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Escala                                             ³±±
±±³          ³ ExpC2 = Titulo da Janela                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMTM420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M420MontBrw(cRevi,cTit)

//Local aCAS := { OemToAnsi(STR0001), OemToAnsi(STR0003) }  //"Confirma" ### "Abandona"
Local aStru := {}
Local nOpcA := 0
Local aCpos := {}
Local oMark, oDlg
Local cDir := ""

Private lInverte := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TB_OK"   	, 	"C",02,0} )
Aadd( aStru,{ "TB_PONTO"	,	"C",TamSX3("QMC_PADRAO")[1],0} )

oTmpTable := FWTemporaryTable():New( "TRB" )
oTmpTable:SetFields( aStru )
oTmpTable:AddIndex("indice1", {"TB_PONTO"} )
oTmpTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCpos para utilizar no MarkBrow               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos := {{"TB_OK"		,"",OemToAnsi("Ok")},;
			{"TB_PONTO"	   ,"",OemToAnsi(STR0010)}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta arquivo temporario                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

QM9->(DbSetOrder(1))
If QM9->(DbSeek(xFilial("QM9")+QMR->QMR_ESCALA))
   If QM9->QM9_TIPAFE $ "4³8"
		QMG->(DbSetOrder(1))
		If QMG->((DbSeek(xFilial("QMG")+QM2->QM2_INSTR+QM2->QM2_REVINS)))
			Do While xFilial("QMG")+QMG->QMG_INSTR+QMG->QMG_REVINS ==;
						QM2->QM2_FILIAL+QM2->QM2_INSTR+QM2->QM2_REVINS
				RecLock("TRB",.T.)
				TRB->TB_PONTO :=  QMG->QMG_PONTO
				QMG->(DbSkip())
			EndDo
		EndIf
	ElseIf QM9->QM9_TIPAFE $ "1³2³3"
		QMC->(DbSetOrder(1))
		If QMC->((DbSeek(xFilial("QMC")+QM9->QM9_ESCALA+Inverte(QM9->QM9_REVESC))))
			Do While xFilial("QMC")+QMC->QMC_ESCALA+QMC->QMC_REVESC ==;
						QM9->QM9_FILIAL+QM9->QM9_ESCALA+QM9->QM9_REVESC
				RecLock("TRB",.T.)
				TRB->TB_PONTO :=  QMC->QMC_PADRAO
				QMC->(DbSkip())
			EndDo
		EndIf
	ElseIf QM9->QM9_TIPAFE == "5"
		QMA->(DbSetOrder(1))
		If QMA->((DbSeek(xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC)))
			Do While xFilial("QMA")+QMA->QMA_ESCALA+QMA->QMA_REVESC ==;
						QM9->QM9_FILIAL+QM9->QM9_ESCALA+QM9->QM9_REVESC
				RecLock("TRB",.T.)
				TRB->TB_PONTO :=  QMA->QMA_FAIXA
				cPonto := QMA->QMA_FAIXA
				Do while xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC+cPonto ==;
 				  			xFilial("QMA")+QMA->QMA_ESCALA+QMA->QMA_REVESC+QMA->QMA_FAIXA
					QMA->(DbSkip())
				EndDo
			EndDo
		EndIf
	EndIf
EndIf

dbSelectArea("TRB")
dbGoTop()
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem o diretorio para a criacao dos arquivos SPC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDir := GetMv("MV_QDIRGRA")
	While .T.
		DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To 26,62 OF oMainWnd
		oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{32,1,125,250})
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 			:= {| | M420Escol(cMarca,lInverte,oDlg)}
		oMark:oBrowse:bAllMark	:= {| | M420MarkAll(cMarca,oDlg)}
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(M420OK(),oDlg:End(),)},{||nOpcA:=0,oDlg:End()})
		If nOpcA == 1

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Rotina que gera os graficos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M420GerCC(cRevi,cDir)
		Endif
		Exit
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTmpTable:Delete()

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M420Marca  ³ Autor ³ Wanderley Goncalves ³ Data ³ 14/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Avalia Marca.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ qmtm420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M420Marca()

If LastKey() == K_ENTER
	RecLock("TRB",.F.)
	TRB->TB_OK := Iif(Empty(TRB->TB_OK),cMarca," ")
	MsUnlock()
ElseIf LastKey() == K_ALT_M				// Marca todos
	dbSelectArea("TRB")
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := cMarca
		MsUnlock()
		dbSkip()
	EndDo
	dbSelectArea("TRB")
	dbGotop()
ElseIf LastKey() == K_ALT_R				// Remove todas as marcas
	dbSelectArea("TRB")
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := " "
		MsUnlock()
		dbSkip()
	EndDo
	dbSelectArea("TRB")
	dbGotop()
EndIf
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M420Escol  ³ Autor ³ Wanderley Goncalves ³ Data ³ 14/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe os Pontos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ qmtm420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M420Escol(cMarca,lInverte,oDlg)
iF IsMark("TB_OK",cMarca,lInverte)
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
Else
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= "  "
	Else
		TRB->TB_OK	:= cMarca
	Endif
	MsUnlock()
Endif
oDlg:Refresh()
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M420MarkAll³ Autor ³Wanderley Goncalves  ³ Data ³ 14/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inverte os Pontos  Marcados/Desmarcados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ qmtm420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M420MarkAll(cMarca,oDlg)
Local nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ M420OK   ³ Autor ³ Wanderley Goncalves   ³ Data ³ 14.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Mensagem de OK antes de executar o processamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qmtm420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M420OK()
Return (MsgYesNo(OemToAnsi(STR0006),OemToAnsi(STR0007)))			//"Confirma Sele‡„o?"###"Aten‡„o"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M420GerCC ³ Autor ³ Wanderley Goncalves   ³ Data ³ 14/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquivo (SPC) para gerar o grafico                    ³±±
±±³          ³ Gera 1 arquivo para cada Ponto  selecionado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M420GerCC(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Revisao do Produto                                  ³±±
±±³          ³ ExpC2: Diretorio para a geracao dos arquivos SPC           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTM420                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M420GerCC(cRevi,cDir)

Local aPontos    := {}
Local cAlias     := Alias()
Local cLeg    
Local nPos    
Local nI 
Local cCpo
Local cPonto 
Local nQtde 
Local cModelo
Local nDec       :=0  
Local nCont      :=0
Local nLie
Local nLse
Local aMedicoes  := {}
Local aMed64     := {}
Local aStru      := {}
Local cArqSPC    := ""
Local nToler 
Local nEspec     := 0
Local aTabela    := {}
Local aLimites   := {}
Local nLoop      := 1
Local nLoopX     := 1
Local cSenhas    := "1"
Local oTmpTable	 := NIL
Local aTitCarCon := {"Media", "Amplitude"}
Local aMed       := {}
Local aCopMed    := {}
Local aMediaTES  := {}
Local aCalMedia  := {}
Local nMaior
Local nMenor
Local oDlg      

// Verifica se o diretorio do grafico e um  diretorio Local
If !QA_VerQDir(cDir) 
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para guardar as meds. dos pontos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TMP_PONTO"  ,   "C",TamSX3("QMC_PADRAO")[1],0} )
Aadd( aStru,{ "TMP_LEGEND"  ,  "C",06,0} )
Aadd( aStru,{ "TMP_DTMEDI"  ,  "D",08,0} )
Aadd( aStru,{ "TMP_HRMEDI"  ,  "C",05,0} )
Aadd( aStru,{ "TMP_MEDI01"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI02"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI03"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI04"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI05"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI06"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI07"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI08"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI09"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MEDI10"  ,  "C",10,0} )

oTmpTable := FWTemporaryTable():New( "TMP" )
oTmpTable:SetFields( aStru )
oTmpTable:AddIndex("indice1", {"TMP_PONTO"} )
oTmpTable:Create()

dbSelectArea("TRB")
dbGoTop()
Do While !Eof()
	If !Empty(TB_OK)
		Aadd(aPontos,{ TB_PONTO, .F., cArqSpc, "" })	// Ponto, Tem medicoes, Nome Arquivo, Modelo
	EndIf
	dbSkip()
EndDo

// Seleciona os pontos com medicoes no periodo
QM7->(dbSetOrder(1))
QM7->(dbSeek(xFilial("QM7")+mv_par01+mv_par02))
Do While !QM7->(Eof()) .And. QM7->QM7_FILIAL == xFilial("QM7") .And. ;	
	QM7->QM7_INSTR == mv_par01 
	If QM7->QM7_ESCALA == mv_par03 .And.;
		QM7->QM7_DATA >= mv_par04 .And. QM7->QM7_DATA <= mv_par05

		// Guarda as medicoes de acordo com o ponto, se ele foi escolhido
		nPos := Ascan(aPontos, { |x| x[1] == QM7->QM7_PONTO })
		If nPos <> 0
			// Atualiza aPontos p/ indicar que tem medicoes
			aPontos[nPos][2] := .T.
	
			// Monta a legenda da medicao
			cLeg := Left(Dtoc(QM7->QM7_DATA),5)	// Dia/Mes

			// Grava no arquivo auxiliar de medicoes
			RecLock("TMP", .T.)
			TMP->TMP_PONTO  := QM7->QM7_PONTO 
			TMP->TMP_DTMEDI := QM7->QM7_DATA
			TMP->TMP_HRMEDI := "00:00"        
			TMP->TMP_LEGEND := cLeg

			// Seleciona as medicoes no QM8
			QM8->(DbSetOrder(1))
			QM8->(dbSeek(xFilial("QM8")+QM7->QM7_INSTR+QM7->QM7_REVINS+;
							DtoS(QM7->QM7_DATA)+ QM7->QM7_CSEQ + QM7->QM7_ESCALA + QM7->QM7_REVESC+;
							QM7->QM7_PONTO + QM7->QM7_REVPAD))

			nI := 1
			Do While !QM8->(Eof()) .And. QM8->QM8_FILIAL+QM8->QM8_INSTR+QM8->QM8_REVINS+;
				DtoS(QM8->QM8_DATA)+ QM8->QM8_CSEQ +QM8->QM8_ESCALA+QM8->QM8_REVESC +;
				QM8->QM8_PADRAO + QM8->QM8_REVPAD == ;
				xFilial("QM8")+QM7->QM7_INSTR+QM7->QM7_REVINS+;
				DtoS(QM7->QM7_DATA) + QM7->QM7_CSEQ +QM7->QM7_ESCALA + QM7->QM7_REVESC +;
				QM7->QM7_PONTO + QM7->QM7_REVPAD
		
				// Grava as medicoes
				cCpo := "TMP_MEDI"+StrZero(nI,2)
				// Troca "," por "." pq. o WINCEP nao reconhece "," como decimal
				If mv_par07 == 1 // Valores Iniciais
					TMP->&(cCpo) := StrTran(QM8->QM8_VLRINI,",",".")
				Else
					TMP->&(cCpo) := StrTran(QM8->QM8_VLRFIM,",",".")
				EndIf
				nI++
				QM8->(dbSkip())
			EndDo
		EndIf
	EndIf
	QM7->(DbSkip())
	If QM9->QM9_TIPAFE == "3" .and. !QM7->(Eof()) //Se for do tipo pressao
		QM7->(DbSkip())
	EndIf
EndDo

// Gera os arquivos de grafico
TMP->(dbGoTop())
Do While !TMP->(Eof())
	cPonto := TMP->TMP_PONTO 
		// Define o modelo do grafico e a qtde de medicoes
	// Modelo 1=>XbarR, 2=>XbarS, 3=>XTilR, 4=>XIndR, 5=>P, 6=>NP, 7=>C, 8=>U
	If QM9->QM9_TIPAFE == "3" // Se for do tipo Pressao, pega subida e descida
		nQtde := QM9->QM9_NROMED * 2 // No. medicoes - dobra p/ tipo pressao
	Else
		nQtde := QM9->QM9_NROMED // Numero de medicoes
	EndIf

	cModelo := "1"  // XBR

	// Identifica o no. de casas decimais, Limites Engenharia e se Controla Min/Max
	If QM9->QM9_TIPAFE $ "4³8"
		QMG->(DbSeek(xFilial("QMG")+	QM2->QM2_INSTR+QM2->QM2_REVINS+cPonto))
		nDec := QA_NumDec(QMG->QMG_NOMIN)
		nLie := Val(QMG->QMG_ESCALI)
		nLse := Val(QMG->QMG_ESCALF)
	ElseIf QM9->QM9_TIPAFE == "5"
		nToler := SuperVal(QMA->QMA_TOLER)
		dbSelectArea("QMA")
		dbSetOrder(1)
		dbSeek(xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC+cPonto)
		While !Eof() .and. QMA_FILIAL == xFilial("QMA") .and. ;
			QM9->QM9_ESCALA+QM9->QM9_REVESC+cPonto == QMA->QMA_ESCALA+QMA->QMA_REVESC+QMA->QMA_FAIXA
			dbSelectArea("QM3")
			dbSetOrder(1)
			dbSeek(xFilial("QM3")+QMA->QMA_PADRAO)
	 		nEspec += SuperVal(QM3->QM3_ESPEC)
			If nDec < QA_NumDec(QM3->QM3_ESPEC)
				nDec := QA_NumDec(QM3->QM3_ESPEC)
			EndIf
         dbSelectArea("QMA")
			dbSkip()
		EndDo
		nLie := nEspec - nToler 
		nLse := nEspec + nToler
	ElseIf QM9->QM9_TIPAFE $ "1³2³3"
		QM3->(DbSeek(xFilial("QM3")+cPonto))
		nDec := QA_NumDec(QM3->QM3_ESPEC)
		nLie := SuperVal(QM3->QM3_ESPEC) - SuperVal(QM3->QM3_TOLER)
		nLse := SuperVal(QM3->QM3_ESPEC) + SuperVal(QM3->QM3_TOLER)
	EndIf
	
	// Monta vetor com os valores das medicoes e checa as menores/maiores datas
	aMedicoes := {}
	Aadd(aMediaTES, {})
	Do While TMP->TMP_PONTO == cPonto .And. !TMP->(Eof())
		Aadd(aMedicoes,"QACHART.DLL - NORMAL")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o LSE  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aMedicoes,"[USL]")
		Aadd(aMedicoes,StrTran(Str(SuperVal(nLse)),".",","))
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o LIE  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aMedicoes,"[LSL]")
		Aadd(aMedicoes,StrTran(Str(SuperVal(nLie)),".",","))
		
		Aadd(aMedicoes,"[INICIO DE DADOS]")

		Do While TMP->TMP_PONTO == cPonto .And. !TMP->(Eof())
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta vetor com os valores das medicoes ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMedi := StrZero(Day(TMP->TMP_DTMEDI),2)+"/"+;
						StrZero(Month(TMP->TMP_DTMEDI),2)+"/"+Str(Year(TMP->TMP_DTMEDI),4)+;
						TMP->TMP_HRMEDI
			Aadd(aMed,{})
			For nLoop := 1 to nQtde
				cCpo := "TMP_MEDI"+StrZero(nLoop,2)
				cMedicao := cMedi+StrTran(AllTrim(TMP->&cCpo),".",",")
				Aadd(aMedicoes,cMedicao)
				Aadd(aMed[LEN(aMed)],StrTran(AllTrim(TMP->&cCpo),".",","))
				Aadd(aMediaTES[LEN(aMediaTES)],StrTran(AllTrim(TMP->&cCpo),".",","))
			Next nLoop

			nCont+=1

			TMP->(dbSkip())
		EndDo
		Aadd(aMedicoes,"[FIM DE DADOS]")
	EndDo

	Aadd(aMedicoes,"[LANGUAGE]")
	Aadd(aMedicoes,Upper(__Language) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o tamanho do sub-grupo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[SUBGRUPO]")
	Aadd(aMedicoes,Str(nQtde,4))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o ponto apresenta mais de 2 sub-grupos de medicoes, ³
	//³ necessarios para a geracao dos graficos.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aMedicoes) > 5	// Header, Linha de Inicio e Fim de Dados

		nPos := Ascan(aPontos, { |x| x[1] == cPonto })
		If nPos <> 0
			// Atualiza aPontos indicando que tem medicoes suficientes p/ o grafico
			aPontos[nPos][2] := .T.
			
			// Identifica o modelo do grafico
			aPontos[nPos][4] := cModelo
		EndIf

		If !lExistChart
			// Gera o nome do arquivo SPC
			cArqSPC := M420NoArq(cDir)

			If !Empty(cArqSPC)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o arquivo SPC ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lGera := GeraTxt32(aMedicoes ,cArqSPC, cDir)
				If !lGera
					Exit
				EndIf
			
				// Atualiza o nome do arquivo SPC gerado no array de pontos
				If nPos <> 0
					aPontos[nPos][3] := cArqSpc
				EndIf
			EndIf
		Endif
	EndIf
EndDo

aCopMed := aClone(aMed)

// Calculo Minimo e Maximo
For nLoop := 1 to Len(aMed)

	For nLoopX := 1 to Len(aMed[nLoop]) 
		aCopMed[nLoop][nLoopX] := Val(aMed[nLoop][nLoopX])
	Next 

	ASORT(aCopMed[nLoop],,, { |x, y| x < y } )
	nMenor  := aCopMed[nLoop,1]
	nMaior  := aCopMed[nLoop,Len(aCopMed[nLoop])]

	Aadd(aCalMedia, ALLTRIM(STR(nMaior - nMenor)))

Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array para o ListBox somente os que estao marcados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := 1 to Len(aPontos)
	If aPontos[nLoop][2]
		Aadd( aTabela, { aPontos[nLoop][1], aPontos[nLoop][3], aPontos[nLoop][4] } )
		Aadd( aMed64 , { aMed, aCalMedia, aTitCarCon})
	EndIf
Next nLoop

If Len(aTabela) > 0

	nPosTar := ASCAN( aMedicoes, "[TARGET]" ) + 1
	nPosLSL := ASCAN( aMedicoes, "[LSL]" ) + 1
	nPosUSL := ASCAN( aMedicoes, "[USL]" ) + 1
	aLimites := {}
	aLimites := {SUPERVAL(aMedicoes[nPosTar]), SUPERVAL(aMedicoes[nPosLSL]), SUPERVAL(aMedicoes[nPosUSL])}

	DEFINE MSDIALOG oDlg FROM	18,16 TO 246,561 TITLE OemToAnsi(STR0013) PIXEL // "Dados gerados"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle para abertura do grafico. Caso o grafico fique aberto por mais de 3 minutos ³
	//³ nao perca a conexao.																 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PtInternal(9,"FALSE")
	If lExistChart
		@ 0.3,0.3 LISTBOX oLbx FIELDS HEADER OemToAnsi(STR0010),; // "Ponto/Faixa"
					OemToAnsi(STR0014);	// "Arquivo"
			SIZE 225,100 OF oDlg ON DBLCLICK (QIEMGRAFIC(aMed64[oLbx:nAt,2], 8, aMed64[oLbx:nAT,1], aMed64[oLbx:nAT,3], aLimites))
	Else
		@ 0.3,0.3 LISTBOX oLbx FIELDS HEADER OemToAnsi(STR0010),; // "Ponto/Faixa"
					OemToAnsi(STR0014);	// "Arquivo"
			SIZE 240,100 OF oDlg ON DBLCLICK Calldll32("ShowChart",aTabela[oLbx:nAt,2],aTabela[oLbx:nAt,3],cDir,NORMAL,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
	EndIf
	oLbx:SetArray( aTabela )
	oLbx:bLine := { || {aTabela[oLbx:nAT,1],aTabela[oLbx:nAT,2]} }

	If !lExistChart
		DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action Calldll32("ShowChart",aTabela[oLbx:nAt,2],aTabela[oLbx:nAt,3],cDir,NORMAL,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
	else
		DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action QIEMGRAFIC(aMed64[oLbx:nAt,2], 8, aMed64[oLbx:nAT,1], aMed64[oLbx:nAT,3], aLimites)
	Endif
	DEFINE SBUTTON FROM 18, 243 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	If lExistChart
		@ 031,228 BUTTON oBtn3 PROMPT OemToAnsi("Histrograma") OF oDlg PIXEL SIZE 45,13 ; //"Histograma"
		ACTION QIEMGRAFIC(aMed64[oLbx:nAt,2], 3, aMed64[oLbx:nAT,1], ,aLimites)

		oBtn3:lReadOnly := .F.
	Endif

	ACTIVATE MSDIALOG oDlg CENTERED
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui os arquivos (SPC) gerados agora ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A420DelSpc( cDir, aTabela )
	PtInternal(9,"TRUE")
Else
	MessageDlg(OemtoAnsi(STR0016),,3)	// "Não há pontos com medições suficientes para gerar o gráfico."
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o arquivo auxiliar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTmpTable:Delete()

dbSelectArea(cAlias)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³M420NoArq ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 05/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera nome do arquivo SPC											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTM420																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M420NoArq(cDir)

Local cArq	:= ""
Local nI 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o arquivo disponivel com extensao SPC ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to 99999
	cArq := "QMT" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI

Return cArq

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M420MoSPC³ Autor ³ Waderley Goncalves    ³ Data ³ 05/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra o arquivo SPC gerado para cada Ponto  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ M420MoCC(ExpA1)														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1: Array contendo os Pontos e seus resp. arqs. SPC	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTM420																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function M420MoSPC(aPontos)
Local oLbx, oDlg, nItem, cVarLbx, aHeaders := {}
Local nI
Local cRet := aPontos[1,3]

Private aTabela := {} // Array a ser exibido

For nI := 1 to Len(aPontos)
	// Somente mostra os pontos que tem medicoes
	If aPontos[nI][2]
		Aadd( aTabela, {	aPontos[nI][1], aPontos[nI][3] } )
	EndIf
Next nI

While Len(aTabela) > 0

	DEFINE MSDIALOG oDlg FROM	18,16 TO 246,561 TITLE OemToAnsi(STR0013) PIXEL // "Dados gerados"

	@ 0.3,0.3 LISTBOX oLbx FIELDS HEADER OemToAnsi(STR0010),; // "Ponto/Faixa"
												OemToAnsi(STR0014);	// "Arquivo"
										SIZE 240,100 OF oDlg ON DBLCLICK (cRet := aTabela[oLbx:nAt,2],oDlg:End())
	oLbx:SetArray( aTabela )
	oLbx:bLine := { || {aTabela[oLbx:nAT,1],aTabela[oLbx:nAT,2]} }

	DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action (cRet := aTabela[oLbx:nAt,2],oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

	Exit
EndDo

//Return(.t.)
Return( cRet )
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A420DelSpc³ Autor ³ Wanderley Goncalves   ³ Data ³ 05/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Deleta os arquivos SPC gerados 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Diretorio dos SPC									  ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A420DelSpc( cDir, aTabela )
AEval(aTabela, {|aFile| Ferase(cDir+aFile[2])})
Return Nil
