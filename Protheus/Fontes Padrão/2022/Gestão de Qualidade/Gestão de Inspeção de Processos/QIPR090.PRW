#INCLUDE "QIPR090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPR090  ³ Autor ³ Antonio Aurelio F C   ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relat¢rio de Referˆncia Cruzada : NC x Ord.Producao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaQIP                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³18/05/00³      ³Retirada da funcao de ajuste do SX1       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPR090
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oTempTable	:= NIL
Local cAlias  	:= Alias()
Local nOldOrder	:= IndexOrd()
Local cTitulo		:= OemToAnsi(STR0001)	//"Referencia Cruzada : NC x Ordem de Producao"
Private cMarca	:= GetMark()
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao para montar o Browse para escolha dos Laudos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M090BrwLau(cTitulo,@oTempTable)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao para montar o Browse para escolha das Classes NC  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M090BrwCla(cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario dos Laudos                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable:Delete()
dbSelectArea(cAlias)
dbSetOrder(nOldOrder)
Return NIL
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M090BrwLau ³ Autor ³ Marcelo Pimentel    ³ Data ³ 26/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta browse para a escolha dos Laudos - MarkBrowse        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M170BrwLau(ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIPr170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M090BrwLau(cTitulo,oTempTable)
Local nIndex
Local cKey
Local aStru := {}
Local nOpcA := 0
Local lRetu := .T.
Local aCpos := {}
Local oMark
Local oDlg
Private lInverte := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TB_OK"   	, "C",2,0} )
Aadd( aStru,{ "TB_CODFAT"	, "C",TamSX3("QPD_CODFAT")[1],0} )
Aadd( aStru,{ "TB_DESCRI"  , "C",TamSX3("QPD_DESCPO")[1],0} )

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_CODFAT"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCpos para utilizar no MarkBrow               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos := {{"TB_OK"		,"",OemToAnsi(STR0003)},;		//"Ok"
			{"TB_CODFAT"	,"",OemToAnsi(STR0004)},;		//"Fator"
			{"TB_DESCRI"	,"",OemToAnsi(STR0005)}}		//"Descricao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta com as opcoes de fatores de IQP                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPD->(dbGotop())

While !QPD->(Eof()) .And. QPD->QPD_FILIAL == xFilial("QPD")
	RecLock("TRB",.T.)
	Replace TB_CODFAT	With QPD->QPD_CODFAT
	Replace TB_DESCRI	With QPD->QPD_DESCPO
	MsUnlock()
	QPD->(dbSkip())
EndDo

dbSelectArea("TRB")
TRB->(dbGoTop())
If TRB->(BOF()) .and. TRB->(EOF())
	HELP(" ",1,"RECNO")
Else
	While .T.
		DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 To 26,62 OF oMainWnd
		oMark := MsSelect():New("TRB","TB_OK",,aCpos,lInverte,cMarca,{23,3,125,242})
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 				 := {|| M090Escol(cMarca,lInverte,oDlg)}
		oMark:oBrowse:bAllMark	 := {|| M090MarkAll(cMarca,oDlg)}
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(M090OK(),oDlg:End(),)},{||nOpcA:=0,oDlg:End()})
		If nOpcA <> 1
			lRetu := .f.
		Endif
		Exit
	EndDo
EndIf

Return(lRetu)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M090BrwCla ³ Autor ³ Antonio Aurelio F C ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta browse para a escolha das Classes de NC - MarkBrowse ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M090BrwCla(ExpC1,ExpC2,ExpL1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Revisao                                            ³±±
±±³          ³ ExpC2 = Titulo da Janela                                   ³±±
±±³          ³ ExpL1 = Indica se montou o Browse para escolha dos ensaios ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIPr090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M090BrwCla(cTitulo)
Local oTempTable := NIL
Local aStru := {}
Local nOpcA := 0
Local lRetu := .f.
Local aCpos := {}
Local oMark
Local oDlg
Private lInverte := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho.  Obs.: O QEE, mantem as classes de ³
//³  nao conformidades gen‚rico para os modulos QIE, QMT, QIP    ³                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEE")
Aadd( aStru,{ "TB_OK"   	, 	"C",2,0} )
Aadd( aStru,{ "TB_CLASSE"	,	"C",TamSX3("QEE_CLASSE")[1],0} )
Aadd( aStru,{ "TB_DESCRI"  ,  "C",TamSX3("QEE_DESCPO")[1],0} )

oTempTable := FWTemporaryTable():New( "TR1" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_CLASSE"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCpos para utilizar no MarkBrow               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos := {{"TB_OK"		,"",OemToAnsi(STR0003)},;		//"Ok"
  			 {"TB_CLASSE"	,"",OemToAnsi(STR0006)},;		//"Classe NC"
			 {"TB_DESCRI"	,"",OemToAnsi(STR0005)}}		//"Descricao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta arquivo temporario das Classes de Nao Conformidade  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QEE->(dbSeek(xFilial("QEE")))
While QEE->(!Eof()) .And. QEE->QEE_FILIAL == xFilial("QEE")
	RecLock("TR1",.T.)
	TR1->TB_CLASSE	:= QEE->QEE_CLASSE
	TR1->TB_DESCRI	:= QEE->QEE_DESCPO
	MsUnlock()
	QEE->(dbSkip())
EndDo

dbSelectArea("TR1")
TR1->(dbGoTop())
If TR1->(BOF()) .and. TR1->(EOF())
	HELP(" ",1,"RECNO")
Else
	While .T.
		DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 To 26,62 OF oMainWnd
		oMark := MsSelect():New("TR1","TB_OK",,acpos,lInverte,cMarca,{23,3,125,242})
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 		   	 := {|| M090Esc1(cMarca,lInverte,oDlg)}
		oMark:oBrowse:bAllMark	 := {|| M090M1All(cMarca,oDlg)}
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(M090OK(),oDlg:End(),)},{||nOpcA:=0,oDlg:End()})
		If nOpcA == 1
			lRetu := .T.
		Endif
		Exit
	EndDo
EndIf

If lRetu
	// Verifica se escolheu alguma classe
	TR1->(dbGoTop())
	
	If !TRepInUse()
		M090GerRC() // Executa versão anterior do fonte
	Else
		Pergunte("QPR090",.F.) 
	    oReport := ReportDef()
	    oReport:PrintDialog()
	EndIF    
	
EndIf

oTempTable:Delete() //-- Deleta Arquivo Temporario Classes de NC

Return(lRetu)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M090Escol  ³ Autor ³ Antonio Aurelio F C ³ Data ³ 08/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe os Ensaios                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Qipr090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M090Escol(cMarca,lInverte,oDlg)
If IsMark("TB_OK",cMarca,lInverte)
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
±±³Fun‡…o    ³ M090Esc1   ³ Autor ³ Antonio Aurelio F C ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe as Classes de NC                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIPr170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M090Esc1(cMarca,lInverte,oDlg)
IF IsMark("TB_OK",cMarca,lInverte)
	RecLock("TR1",.F.)
	If !lInverte
		TR1->TB_OK	:= cMarca
	Else
		TR1->TB_OK	:= "  "
	Endif
	MsUnlock()
Else
	RecLock("TR1",.F.)
	If !lInverte
		TR1->TB_OK	:= "  "
	Else
		TR1->TB_OK	:= cMarca
	Endif
	MsUnlock()
Endif
oDlg:Refresh()
Return .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M090MarkAll³ Autor ³Antonio Aurelio F C  ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inverte os Ensaios Marcados/Desmarcados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIPr090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M090MarkAll(cMarca,oDlg)
Local nRecno:=TRB->(Recno())
TRB->(dbGotop())
Do While TRB->(!Eof())
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
	TRB->(dbSkip())
EndDo
TRB->(dbGoto(nRecno))
oDlg:Refresh()
Return .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M090M1All  ³ Autor ³Antonio Aurelio F C  ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inverte as Classes NC Marcadas/Desmarcadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIPr090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M090M1All(cMarca,oDlg)
Local nRecno:=Recno()
TR1->(dbGotop())
Do While TR1->(!Eof())
	RecLock("TR1",.F.)
	If Empty(TR1->TB_OK)
		TR1->TB_OK	:= cMarca
	Else
		TR1->TB_OK	:= "  "
	Endif
	MsUnlock()
	TR1->(dbSkip())
EndDo
TR1->(dbGoto(nRecno))
oDlg:Refresh()
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ M090OK   ³ Autor ³ Antonio Aurelio F C   ³ Data ³ 24.08.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Mensagem de OK antes de executar o processamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPr090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M090OK()
Return (MsgYesNo(OemToAnsi(STR0007),OemToAnsi(STR0008)))		//"Confirma Sele‡„o?"###"Aten‡„o"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M090GerRC ³ Autor ³ Antonio Aurelio F C   ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Referˆncia Cruzada : NC x Ordem de Producao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M090GerRC(ExpC1,ExpL1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPr090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M090GerRC()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis do relatorio                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1   := STR0009	//"SerÆo relacionadas as NÆo Conformidades encontradas em cada ordem de produ‡Æo."
Local cDesc2   := ""
Local cDesc3 	:= ""
Local cString	:= "SC2"
Local cProg    := "QIPR090"
Local cTitulo	:= STR0010	//"Referencia Cruzada : NC x Ordem de Producao"
Local cTamanho := "M"

Private aReturn  := { STR0011, 1,STR0012, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
Private nLastKey := 0
Private cPerg    := "QPR090"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Da  Ordem de Producao     	         ³
//³ mv_par02            // Da  Lote                  	         ³
//³ mv_par03            // Da  Numero de Serie       	         ³
//³ mv_par04            // At‚ Ordem de Producao     	         ³
//³ mv_par05            // At‚ Lote                  	         ³
//³ mv_par06            // At‚ Numero de Serie       	         ³
//³ mv_par07            // Do  Produto             	             ³
//³ mv_par08            // At‚ Produto              	         ³
//³ mv_par09            // Da  Data da OP          	             ³
//³ mv_par10            // At‚ Data da OP          	             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)                                             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "QIPR090"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho)

If nLastKey == 27
	Set Filter To
	Return .F.
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter To
	Return .F.
Endif

RptStatus({|lEnd| M090Imp(@lEnd,wnrel,cString,cTitulo,cProg,cTamanho)},cTitulo)


Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M090Imp  ³ Autor ³ Antonio Aurelio F C   ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPr090			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M090Imp(lEnd,wnrel,cString,cTitulo,cProg,cTamanho)
Local CbTxt
Local cbCont	:=00
Local Cabec1	:=""
Local Cabec2	:=""
Local cComp 	:= GetMV("MV_COMP")
Local	cOp      := ""
Local	cProdut  := ""
Local	cDtEntr  := ""
Local	cLote    := ""
Local aCampos  := {}
Local cArqTemp := ""
Cabec1 := STR0013+Dtoc(mv_par09) + STR0014 + Dtoc(mv_par10)		//"Periodo de Producao : "###" a "

Cabec2 := PADR(TitSX3("QPR_OP")[1],12," ")
Cabec2 := Cabec2 + "    " 		+ PADR(TitSX3("QPR_PRODUT")[1],12," "	)
Cabec2 := Cabec2 + "      " 	+ PADR(TitSX3("QPR_DTENTR")[1],12," "	)
Cabec2 := Cabec2 + "  " 		+ PADR(TitSX3("QPR_LOTE")[1]	,12," "	)
Cabec2 := Cabec2 + "     " 	+ PADR(TitSX3("QPL_LAUDO")[1]	,5	," "	)
Cabec2 := Cabec2 + "  " 		+ PADR(TitSX3("QPU_NAOCON")[1],12," "	)
Cabec2 := Cabec2 + "  " 		+ PADR(TitSX3("QPU_CLASSE")[1],6	," "	)
Cabec2 := Cabec2 + "  " 		+ PADR(TitSX3("QPU_NUMNC")[1]	,10," "	)
Cabec2 := Cabec2 + "  " 		+ PADR(TitSX3("QPU_DEMIQI")[1],12," "	)
Cabec2 := Cabec2 + "  " 		+ PADR(TitSX3("QPR_NUMSER")[1],12," "	)

// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
//           1         2         3         4         5         6         7         8         9         10        11        12        13
//"Ordem Producao  Produto           Data Entrega  Lote              Laudo  Nao Conform  Classe  No. de NCs  Demerito IQI"
//"--------------  ----------------  ------------  ----------------  -----  -----------  ------  ----------  ------------"
// XXXXXXXXXXXX    XXXXXXXXXXXXXXXX    99/99/9999  XXXXXXXXXXXXXXXX    X    XXXXXXXXX         X       99999      XXX
// 012345678901    0123456789012345    99/99/9999  0123456789012345    0    012345678
cbtxt := Space(10)
Li    := 80
m_pag := 01 

aTam:=TamSX3("QPR_OP")		;AADD(aCampos,{"TRB_OP",		"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;AADD(aCampos,{"TRB_PRODUT",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;AADD(aCampos,{"TRB_DTENTR",	"D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;AADD(aCampos,{"TRB_LOTE",		"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPL_LAUDO")	;AADD(aCampos,{"TRB_LAUDO",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;AADD(aCampos,{"TRB_NAOCON",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_CLASSE")	;AADD(aCampos,{"TRB_CLASSE",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;AADD(aCampos,{"TRB_NUMNC",	"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_DEMIQI")	;AADD(aCampos,{"TRB_DEMIQI",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_NUMSER")	;AADD(aCampos,{"TRB_NUMSER",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;AADD(aCampos,{"TRB_REVI"  ,	"C",aTam[1],aTam[2]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho.                          			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable := FWTemporaryTable():New( "TR2" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_PRODUT"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da funcao para gerar arquivo de Trabalho.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPR->(dbSetOrder(1))
QPU->(dbSetOrder(1))

QPR090Gera()

dbSelectArea("TR2")
TR2->(dbGoTop())

SetRegua(TR2->(RecCount()))

While TR2->(!EOF())
	If LastKey() == 286    //ALT_A
		lEnd := .t.
	EndIf
	If lEnd
		@PRow()+1,001 PSAY STR0015		//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	IncRegua()
	If Li > 60
		cabec(cTitulo,cabec1,cabec2,cProg,cTamanho,cComp)
	EndIf

	If cOp				!= TR2->TRB_OP			.Or.;
		cProdut			!= TR2->TRB_PRODUT		.Or.;
		Dtos(cDtEntr)	!= Dtos(TR2->TRB_DTENTR)
        Li++
		@Li,00 PSAY TR2->TRB_OP		//Op
		@Li,16 PSAY TR2->TRB_PRODUT	//Produto
		@Li,36 PSAY TR2->TRB_DTENTR	//Dtentr
		@Li,48 PSAY TR2->TRB_LOTE		//Lote
		
		cOp     := TR2->TRB_OP
		cProdut := TR2->TRB_PRODUT
		cDtEntr := TR2->TRB_DTENTR
		cLote   := TR2->TRB_LOTE
	EndIf
	
	@Li,068 PSAY TR2->TRB_LAUDO		//Laudo (Sim/Nao)
	@Li,073 PSAY TR2->TRB_NAOCON
	@Li,091 PSAY TR2->TRB_CLASSE
	@Li,099 PSAY PADL(TR2->TRB_NUMNC,5," ")
	@Li,110 PSAY Iif(TR2->TRB_DEMIQI=="S",STR0016,STR0017)	//"Sim"###"Nao" 
	@Li,120 PSAY TR2->TRB_NUMSER
	Li++
	TR2->(dbSkip())
EndDo		

If Li != 80
	roda(CbCont,cbtxt)
EndIf

oTempTable:Delete() //-- Apaga indice e o arquivo de trabalho

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set device to Screen
If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return .T. 


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QPR090Gera³ Autor ³ Antonio Aurelio F C   ³ Data ³ 25.08.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera arquivo de Trabalho                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPR090Gera()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPR090Gera(lR4,oReport)
Local cChave	:=''
Local cKey		:=''
Local cNomArq	:=''
Local nIndex	:=0

Local	cCond := 'QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER >= "'+mv_par01+mv_par02+mv_par03+'" .And. QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER <= "'+mv_par04+mv_par05+mv_par06+'"'
		cCond += ' .And.QPR->QPR_PRODUT >= "'+mv_par07+'" .And. QPR->QPR_PRODUT <= "'+mv_par08+'"'
		cCond += ' .And.DTOS(QPR->QPR_DTENTR) >= "'+DTOS(mv_par09)+'" .And. DTOS(QPR->QPR_DTENTR) <= "'+DTOS(mv_par10)+'"'

Default lR4     := .F.
Default oReport := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o nome do arquivo de indice de trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QPR")
dbSetOrder(1)
cKey:= QPR->(IndexKey())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtro da personalizacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lR4
	If !Empty(AllTrim(oReport:Section(1):GetSQLExp("QPR")))
		cCond += " .AND. "+oReport:Section(1):GetSQLExp("QPR") 
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o indice de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq:=CriaTrab(NIL,.F.)
IndRegua("QPR",cNomArq,cKey,,cCond,STR0018) //"Selecionando Registros..."
nIndex := RetIndex("QPR")
dbSelectArea("QPR")

dbSetOrder(nIndex)
dbGoTop()
While !Eof() .And. xFilial("QPR") == QPR->QPR_FILIAL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Posicionar na Ordem de Producao			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SC2->(dbSetOrder(1))	
	SC2->(dbSeek(xFilial("SC2")+QPR->QPR_OP))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Posicionar no Laudo                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QPL->(dbSetOrder(3))	
	QPL->(dbSeek(xFilial("QPL")+QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER+SC2->C2_ROTEIRO+QPR->QPR_OPERAC+QPR->QPR_LABOR))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a escolha para Laudo.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRB->(dbSeek(QPL->QPL_LAUDO))
	If TRB->(Eof()) .Or. Empty(TRB->TB_OK)
		QPR->(dbSkip())
		Loop
	EndIf
	cChave := QPR->QPR_CHAVE
	If QPU->(dbSeek(xFilial("QPU")+cChave))
		While QPU->(!Eof()) .And. ;
			xFilial("QPU") == QPU->QPU_FILIAL .And. ;
			cChave == QPU->QPU_CODMED
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a escolha da Classe NC.                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TR1->(dbSeek(QPU->QPU_CLASSE))
			If TR1->(Eof()) .Or. Empty(TR1->TB_OK)
				QPU->(dbSkip())
				Loop
			EndIf
			RecLock("TR2",.T.)
			TR2->TRB_OP		:=QPR->QPR_OP
			TR2->TRB_PRODUT	:=QPR->QPR_PRODUT
			TR2->TRB_DTENTR	:=QPR->QPR_DTENTR
			TR2->TRB_LOTE	:=QPR->QPR_LOTE
			TR2->TRB_LAUDO	:=QPL->QPL_LAUDO 
			TR2->TRB_NAOCON	:=QPU->QPU_NAOCON
			TR2->TRB_CLASSE	:=QPU->QPU_CLASSE
			TR2->TRB_NUMNC	:=QPU->QPU_NUMNC
			TR2->TRB_DEMIQI	:=QPU->QPU_DEMIQI
			TR2->TRB_REVI	:=QPR->QPR_REVI
			MsUnLock()
			QPU->(dbSkip())
		EndDo
	EndIf
	dbSelectArea("QPR")
	dbSkip()
EndDo
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 25/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cTitulo	:= OemToAnsi(STR0001)	//"Referencia Cruzada : NC x Ordem de Producao"
Local cDesc1    := STR0009	//"SerÆo relacionadas as NÆo Conformidades encontradas em cada ordem de produ‡Æo."
Local oSection1 
Local aTam		:= {}
Local aCampos := {}
local cArqTemp

aTam:=TamSX3("QPR_OP")		;AADD(aCampos,{"TRB_OP",		"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;AADD(aCampos,{"TRB_PRODUT",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;AADD(aCampos,{"TRB_DTENTR",	"D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;AADD(aCampos,{"TRB_LOTE",		"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPL_LAUDO")	;AADD(aCampos,{"TRB_LAUDO",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;AADD(aCampos,{"TRB_NAOCON",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_CLASSE")	;AADD(aCampos,{"TRB_CLASSE",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;AADD(aCampos,{"TRB_NUMNC",	"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_DEMIQI")	;AADD(aCampos,{"TRB_DEMIQI",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_NUMSER")	;AADD(aCampos,{"TRB_NUMSER",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;AADD(aCampos,{"TRB_REVI"  ,	"C",aTam[1],aTam[2]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho.                          			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable := FWTemporaryTable():New( "TR2" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_PRODUT"} )
oTempTable:Create()

DEFINE REPORT oReport NAME "QIPR090" TITLE cTitulo PARAMETER "QPR090" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "TR2", "QPR"  TITLE TitSX3("QPR_OP")[1]
DEFINE CELL NAME "TRB_OP"      OF oSection1 ALIAS "TR2" TITLE TitSX3("QPR_OP")[1]     SIZE 12
DEFINE CELL NAME "TRB_PRODUT"  OF oSection1 ALIAS "TR2" TITLE TitSX3("QPR_PRODUT")[1] SIZE 12
DEFINE CELL NAME "TRB_DTENTR"  OF oSection1 ALIAS "TR2" TITLE TitSX3("QPR_DTENTR")[1] SIZE 12
DEFINE CELL NAME "TRB_LOTE"    OF oSection1 ALIAS "TR2" TITLE TitSX3("QPR_LOTE")[1]   SIZE 12
DEFINE CELL NAME "TRB_LAUDO"   OF oSection1 ALIAS "TR2" TITLE TitSX3("QPL_LAUDO")[1]  SIZE 05
DEFINE CELL NAME "TRB_NAOCON"  OF oSection1 ALIAS "TR2" TITLE TitSX3("QPU_NAOCON")[1] SIZE 12
DEFINE CELL NAME "TRB_CLASSE"  OF oSection1 ALIAS "TR2" TITLE TitSX3("QPU_CLASSE")[1] SIZE 06
DEFINE CELL NAME "TRB_NUMNC"   OF oSection1 ALIAS "TR2" TITLE TitSX3("QPU_NUMNC")[1]  SIZE 10 BLOCK{||PADL(TR2->TRB_NUMNC,5," ") }
DEFINE CELL NAME "cDEMIQI"     OF oSection1 ALIAS ""    TITLE TitSX3("QPU_DEMIQI")[1] SIZE 12 BLOCK{||Iif(TR2->TRB_DEMIQI=="S",STR0016,STR0017) } //"Sim"###"Nao" 
DEFINE CELL NAME "TRB_NUMSER"  OF oSection1 ALIAS "TR2" TITLE STR0019 SIZE 06 //"Numero de Serie"

TRPosition():New(oSection1,"QPR",9,{|| xFilial("QPR") +TR2->TRB_OP +TR2->TRB_LOTE + TR2->TRB_NUMSER })
Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 25/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rela‡ao de Padroes a Calibrar 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport) 
Local oTempTable:= NIL
Local oSection1 := oReport:Section(1)
Local cOp       := ""
Local cProdut   := ""
Local cDtEntr   := ""
Local cLote     := ""
Local aCampos   := {}
Local cArqTemp  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho			       				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("QPR_OP")		;AADD(aCampos,{"TRB_OP",		"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;AADD(aCampos,{"TRB_PRODUT",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;AADD(aCampos,{"TRB_DTENTR",	"D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;AADD(aCampos,{"TRB_LOTE",		"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPL_LAUDO")	;AADD(aCampos,{"TRB_LAUDO",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;AADD(aCampos,{"TRB_NAOCON",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_CLASSE")	;AADD(aCampos,{"TRB_CLASSE",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;AADD(aCampos,{"TRB_NUMNC",	"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_DEMIQI")	;AADD(aCampos,{"TRB_DEMIQI",	"C",aTam[1],aTam[2]}) 
aTam:=TamSX3("QPR_NUMSER")	;AADD(aCampos,{"TRB_NUMSER",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;AADD(aCampos,{"TRB_REVI"  ,	"C",aTam[1],aTam[2]})

oTempTable := FWTemporaryTable():New( "TR3" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_PRODUT"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da funcao para gerar arquivo de Trabalho.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPR->(dbSetOrder(1))
QPU->(dbSetOrder(1))

QPR090Gera(.T.,oReport)

dbSelectArea("TR2")
TR2->(dbGoTop())

dbSelectArea("QPR")
dbSetOrder(1)
oReport:SkipLine(1) 
oReport:ThinLine()
oReport:PrintText(STR0013+Dtoc(mv_par09) + STR0014 + Dtoc(mv_par10),oReport:Row(),025) //"Periodo de Producao : "###" a ")
oReport:SkipLine(1)	
oReport:ThinLine()


While TR2->(!EOF())
	If cOp				!= TR2->TRB_OP			.Or.;
		cProdut			!= TR2->TRB_PRODUT		.Or.;
		Dtos(cDtEntr)	!= Dtos(TR2->TRB_DTENTR)
		
		oSection1:Finish()
		oSection1:Init()			
		    
		oSection1:Cell("TRB_OP"):Show()
		oSection1:Cell("TRB_PRODUT"):Show()
		oSection1:Cell("TRB_DTENTR"):Show()
		oSection1:Cell("TRB_LOTE"):Show()
        
		cOp     := TR2->TRB_OP
		cProdut := TR2->TRB_PRODUT
		cDtEntr := TR2->TRB_DTENTR
		cLote   := TR2->TRB_LOTE
		
	Else
		If cOp			 = TR2->TRB_OP			  .And.;
		   cProdut		 = TR2->TRB_PRODUT		  .And.;
		   Dtos(cDtEntr) = Dtos(TR2->TRB_DTENTR) .And.;
		   cLote         = TR2->TRB_LOTE
				oSection1:Cell("TRB_OP"):Hide()
				oSection1:Cell("TRB_PRODUT"):Hide()
				oSection1:Cell("TRB_DTENTR"):Hide()
				oSection1:Cell("TRB_LOTE"):Hide()
		EndIf
	EndIf
	oSection1:PrintLine()
	TR2->(dbSkip())

EndDo		

TR2->(DbCloseArea())

Return NIL
