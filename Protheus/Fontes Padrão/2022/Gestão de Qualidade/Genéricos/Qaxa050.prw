#INCLUDE "QAXA050.CH" 
#INCLUDE "PROTHEUS.CH" 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QAXA050    ³ Autor ³ Eduardo de Souza   ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Questionarios                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QAXA050()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QUALITY                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³  BOPS  ³ Programador ³ Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³12/11/02³  ----  ³ Eduardo S.  ³ Incluido a opcao "Duplicar", utilizada³±±
±±³        ³        ³             ³ para duplicar o questionario.         ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui"	,	0, 1,,.F.},; // "Pesquisar"
				 {OemToAnsi(STR0002),"QX050Telas",	0, 2},; // "Visualizar"
				 {OemToAnsi(STR0003),"QX050Telas",	0, 3},; // "Incluir"
				 {OemToAnsi(STR0004),"QX050Telas",	0, 4},; // "Alterar"
				 {OemToAnsi(STR0005),"QX050Telas",	0, 5},; // "Excluir"
				 {OemToAnsi(STR0012),"QX050Telas", 0, 6}}  // "Duplicar"

Return aRotina

Function QAXA050()

Private aRotina  := MenuDef()

DbSelectArea("QAG")
DbSetOrder(1)
DbGoTop()
mBrowse(006,001,022,075,"QAG")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX050Telas³ Autor ³ Eduardo de Souza      ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela Cadastro de Questionarios                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050Telas(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QUALITY                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050Telas(cAlias,nReg,nOpc,cDocto,cRvDoc,lAviso)

Local oDlg
Local nI        := 0
Local aColsAux  := {}
Local lDeleta   := .F.
Local lRet      := .F.
Local cFilQuest := ""
Local cCodQuest := ""
Local cRevQuest := ""
Local aHedAux	:= {}

Private lQuestDupl:= .F.
Private bCampo    := {|nCPO| Field( nCPO ) }
Private aHeader   := {}
Private aCols	  := {}
Private nOpcao    := If(nOpc == 6,4,nOpc)
Private lDlgEtapa := .F.
Private nEtapas   := 0
Private aTELA[0][0]
Private aGETS[0]            
Private aColRes   := {}
Private aHedRes   := {}

DbSelectArea("QAG")
DbSetOrder(1)

If nOpc == 3
   For nI := 1 To FCount()
       cCampo := Eval( bCampo, nI )
       lInit  := .F.
       If ExistIni( cCampo )
          lInit := .T.
          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, 'X3_RELACAO') )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, 'X3_TAMANHO') )
          EndIf
          If M->&( cCampo ) == Nil
             lInit := .F.
          EndIf
       EndIf
       If !lInit
          M->&( cCampo ) := FieldGet( nI )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
          ElseIf ValType( M->&( cCampo ) ) = "N"
             M->&( cCampo ) := 0
          ElseIf ValType( M->&( cCampo ) ) = "D"
             M->&( cCampo ) := CtoD( "  /  /  " )
          ElseIf ValType( M->&( cCampo ) ) = "L"
             M->&( cCampo ) := .f.
          EndIf
       EndIf
   Next nI
	M->QAG_FILIAL:= xFilial("QAG") 
Else
   For nI := 1 To FCount()
       M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
   Next nI
EndIf

If nModulo == 24 // SIGAQDO
	If lAviso
		Inclui:= .T.
		Altera:= .F.
		M->QAG_DOCTO:= cDocto
		M->QAG_RVDOC:= cRvDoc
	EndIf
	If (nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5) //Visualizacao/Alteracao/Exclusao
		If !QX50VldDoc()	// Verifica se usuario tem permissao para Alterar/Excluir.
			Return .F.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Duplicacao de Questionario.  				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 6
	cFilQuest := QAG->QAG_FILIAL
	cCodQuest := QAG->QAG_QUEST
	cRevQuest := QAG->QAG_RV
	lQuestDupl:= .T.
	nOpc:= 4
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica permissao para deletar linha do Acols. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 .Or. nOpc == 4
	lDeleta:= .T.
ElseIf nOpc == 2 .Or. nOpc == 5
	lDeleta:= .F.
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 000,000 TO 430,700 OF oMainWnd PIXEL //"Cadastro de Questionarios"

Enchoice("QAG",nReg,nOpc,,,,,{031,002,090,351})

@ 092,002 SAY OemToAnsi(STR0008) SIZE 100,010 OF oDlg COLOR CLR_HRED,CLR_WHITE  PIXEL // "Perguntas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QX050Ahead("QAH")
aHedAux:= aClone(aHeader)
QX050Acols(nOpc,"QAH")
aColsAux:= aClone(aCols)        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array das Respostas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF nOpc == 4
	QX050Ahead("QAI")
	aHedRes:=Aclone(aHeader)
	For nI:=1 To Len(aColsAux)
		QX050Acols(nOpc,"QAI",aColsAux[nI,1])
		AADD(aColREs,{M->QAG_QUEST+M->QAG_RV+aColsAux[nI,1],Aclone(aCols)})
	Next 
	aHeader:= aClone(aHedAux)
	aCols  := aClone(aColsAux)
Endif

lDlgEtapa := .T.

oGet := MSGetDados():New(099,002,212,351,nOpc,"QX050LinOk","","",lDeleta)

aButtons:= {{"BMPORD" ,{ || IF(!EMPTY(M->QAG_QUEST) .AND. !EMPTY(M->QAG_RV), QX050Resp(lDeleta,cFilQuest,cCodQuest,cRevQuest,aColRes,aHedRes),"") },OemToAnsi(STR0007)}} // "Respostas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Duplicacao de Questionario.  		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuestDupl
	Inclui:= .T.
	Altera:= .F.
	nOpc  := 3
	M->QAG_QUEST := Space(TamSx3("QAG_QUEST")[1])
	M->QAG_RV    := Space(TamSx3("QAG_RV")[1])	
	M->QAG_DOCTO := Space(TamSx3("QAG_DOCTO")[1])	
	M->QAG_RVDOC := Space(TamSx3("QAG_RVDOC")[1])	
EndIf

If nOpc == 3 .Or. nOpc == 4
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| ;
	IF(Obrigatorio(aGets,aTela) .AND. QX050TudOK() .AND. QX050LinOk() .AND. QX050VldPM(aColRes,aHedRes,nOpc), ;
	(lRet:=.T.,oDlg:End()),"") },{|| oDlg:End()},,aButtons) CENTERED
	
ElseIf nOpc == 2 .Or. nOpc == 5
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(nOpc == 5,QX050Dele(),),oDlg:End()},{|| oDlg:End()},,aButtons) CENTERED
EndIf
         
IF lRet                 
	Begin Transaction
		QX050GrvQ(nOpc,aColsAux,cFilQuest,cCodQuest,cRevQuest)
		For nI:=1 To Len(aColres)
		    cSeqPer:=RIGHT(aColRes[nI,1],TamSx3("QAI_SEQPER")[1] )
			QX050GrRes(nOpc,aColRes[nI,2],cSeqPer,aHedRes) 
		Next	
	End Transaction
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX050GrvQ ³ Autor ³ Eduardo de Souza      ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Questionario                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050GrvQ(ExpN1,ExpA1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ ExpA1 - Acols Auxiliar                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050GrvQ(nOpc,aColsAux,cFilQuest,cCodQuest,cRevQuest)

Local lRecLock 	:= .F.
Local nI       	:= 0
Local aUsrMat  	:= QA_USUARIO()
Local cMatFil  	:= aUsrMat[2]
Local cMatCod  	:= aUsrMat[3]
Local cMatDep  	:= aUsrMat[4]
Local nCnt     	:= 0
Local nPosSeq  	:= Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QAH_SEQPER"})
Local nPosMem  	:= Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QAH_MEMO1"})
Local aRespDupl	:= {}
Local aQaI     	:= {}
Local nCpo

If nOpc == 3
	lRecLock:= .T.
EndIf

Begin Transaction
	RecLock("QAG",lRecLock)
	For nI := 1 To FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	If nOpc == 3
		QAG->QAG_FILMAT:= cMatFil
		QAG->QAG_MAT   := cMatCod
		QAG->QAG_DEPTO := cMatDep
		QAG->QAG_DTGERA:= dDataBase
	EndIf
	QAG->(MsUnLock()) 
	FKCOMMIT()
	
	DbSelectArea("QAH")
	DbSetOrder(1)
	For nCnt:= 1 To Len(aCols)
		If !aCols[nCnt,Len(aHeader)+1] .And. !Empty(aCols[nCnt,nPosSeq])  // Verifica se o item foi deletado
			If nOpc == 4
				If QAH->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+Acols[nCnt,nPosSeq]))
					RecLock("QAH",.F.)
				Else
					RecLock("QAH",.T.)
				EndIf
			Else
				RecLock("QAH",.T.)
			EndIf
			If nCnt <= Len(AcolsAux)
				If !Empty(aColsAux[nCnt,nPosSeq])
					If aColsAux[nCnt,nPosSeq] <> Acols[nCnt,nPosSeq]
						If QAH->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+AcolsAux[nCnt,nPosSeq]))
							RecLock("QAH",.F.)
						Else
							RecLock("QAH",.T.)
						EndIf
					EndIf
				EndIf
			EndIf
			For nCpo := 1 To Len(aHeader)
				If aHeader[nCpo, 10] <> "V"
					QAH->(FieldPut(FieldPos(Trim(aHeader[nCpo,2])),aCols[nCnt,nCpo]))
				EndIf
				QAH->QAH_FILIAL:= xFilial("QAH")
				QAH->QAH_QUEST := M->QAG_QUEST
				QAH->QAH_RV    := M->QAG_RV
				If !Empty(aCols[nCnt,nPosMem]) .Or. nOpc == 4
					MSMM(QAH_DESPER,70,,aCols[nCnt,nPosMem],1,,,"QAH","QAH_DESPER")
				EndIf
			Next nCpo
			QAH->(MsUnlock())    
			FKCOMMIT()
		Else
			If QAH->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+Acols[nCnt,nPosSeq]))
				RecLock("QAH",.F.)
				QAH->(DbDelete())
				QAH->(MsUnlock())
				FKCOMMIT()
				MSMM(QAH->QAH_DESPER,,,,2)				
				If QAI->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+aCols[nCnt,nPosSeq]))
					While QAI->(!Eof()) .And. QAI->QAI_FILIAL+QAI->QAI_QUEST+QAI->QAI_RV+QAI->QAI_SEQPER == M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+aCols[nCnt,nPosSeq]
						RecLock("QAI",.F.)
						QAI->(DbDelete())
						QAI->(MsUnlock()) 
						FKCOMMIT()
						QAI->(DbSkip())
					EndDo
				EndIf
				QAH->(DbSkip())
			EndIf
		EndIf
	Next nCnt
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Baixa o Aviso de Inclusao de Questionario. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .And. nModulo == 24 // SIGAQDO
		QDS->(DbSetOrder(2))
		If QDS->(DbSeek(M->QAG_FILIAL+M->QAG_DOCTO+M->QAG_RVDOC+"QUE")) .OR. ;
			QDS->(DbSeek(xFilial("QDS")+M->QAG_DOCTO+M->QAG_RVDOC+"QUE"))
			
			While QDS->(!Eof()) .And. 	QDS->QDS_DOCTO+QDS->QDS_RV+QDS->QDS_TPPEND == ;
										M->QAG_DOCTO+M->QAG_RVDOC+"QUE"
				If QDS->QDS_PENDEN == "P"
					RecLock("QDS",.F.)
					QDS->QDS_PENDEN := "B"
					QDS->QDS_DTBAIX:= dDataBase
					QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
					QDS->QDS_FMATBX := cMatFil
					QDS->QDS_MATBX  := cMatCod
					QDS->QDS_DEPBX  := cMatDep
					QDS->(MsUnlock())
				EndIf
				QDS->(DbSkip())
			EndDo
		EndIf
	EndIf
End Transaction
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QX050Dele  ³ Autor ³ Eduardo de Souza   ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Exclusao do Questionario                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QX050Dele()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QAXA050                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050Dele()

Begin Transaction 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui o Questionario.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("QDH")
	DbSetOrder(1)
	If QDH->(DbSeek(xFilial("QDH")+QAG->QAG_DOCTO+QAG->QAG_RVDOC))
		If AllTrim(QDH->QDH_STATUS) <> "I" .AND. AllTrim(QDH->QDH_STATUS) <> "L" 
	   	   RecLock("QAG",.F.)
	 	   QAG->(DbDelete())
	       QAG->(MsUnlock())
	       QAG->(DbSkip())	
	       
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclui Perguntas do Questionario. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QAH->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV))
				While QAH->(!Eof()) .And. QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV == M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV
					RecLock("QAH",.F.)
					QAH->(DbDelete())
					QAH->(MsUnlock())
					MSMM(QAH->QAH_DESPER,,,,2)
					QAH->(DbSkip())
				EndDo
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclui Respostas do Questionario. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QAI->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV))
				While QAI->(!Eof()) .And. QAI->QAI_FILIAL+QAI->QAI_QUEST+QAI->QAI_RV == M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV
					RecLock("QAI",.F.)
					QAI->(DbDelete())
					QAI->(MsUnlock())
					QAI->(DbSkip())
				EndDo
			EndIf
	    Else 
	       Help(" ",1,"QAXA050DEL")	//"Avisa que o Questionario nao pode ser excluido"
		EndIf
	EndIf

End Transaction

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QX050Ahead ³ Autor ³Eduardo de Souza      ³ Data ³ 27/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050Ahead(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do Arquivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader:= {}

For nX := 1 To Len(aStruAlias)
	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") 
		aAdd(aHeader,{Trim(QAGetX3Tit(aStruAlias[nX,1])), ;
			aStruAlias[nX,1], ;
			GetSx3Cache(aStruAlias[nX,1], "X3_PICTURE"), ;
			GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"), ;
			GetSx3Cache(aStruAlias[nX,1], "X3_DECIMAL"), ;
			GetSx3Cache(aStruAlias[nX,1], "X3_VALID"), ;
			GetSx3Cache(aStruAlias[nX,1], "X3_USADO"), ;
			GetSx3Cache(aStruAlias[nX,1], "X3_TIPO"), ;
			GetSx3Cache(aStruAlias[nX,1], "X3_ARQUIVO"), ;
			GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") })
	EndIf
Next nX

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QX050Acols ³ Autor ³Eduardo de Souza      ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050Acols()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao no mBrowse                                   ³±±
±±³          ³ ExpC1 - Alias do Arquivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050Acols(nOpc,cAlias,cSeqPer)

Local nI     := 0
Local lAchou := .F.
Local nPosSeq:= Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QAH_SEQPER"})

Acols:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols               					      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 .And. cAlias == "QAH"
	aCols := Array(1,Len(aHeader)+1)
	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := CtoD("  /  /  ")
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI
	aCols[1,nPosSeq]:= "0001"
	aCols[1,Len(aHeader)+1]:= .F.
Else
	If cAlias == "QAH"
		DbSelectArea("QAH")
		DbSetOrder(1)
		If QAH->(DbSeek(QAG->QAG_FILIAL+QAG->QAG_QUEST+QAG->QAG_RV))
			While QAH->(!Eof()) .And. QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV == QAG->QAG_FILIAL+QAG->QAG_QUEST+QAG->QAG_RV
				aAdd(aCols,Array(Len(aHeader)+1))
				For nI := 1 To Len(aHeader)
					If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
						aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
					Else										// Campo Virtual
						cCpo := AllTrim(Upper(aHeader[nI,2]))
						aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
					Endif
				Next nI
				aCols[Len(aCols),Len(aHeader)+1] := .F.
				QAH->(DbSkip())
			EndDo
			lAchou:= .T.
		EndIf
	ElseIf cAlias == "QAI"
		DbSelectArea("QAI")
		DbSetOrder(1)
		If QAI->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+cSeqPer))
			While QAI->(!Eof()) .And. QAI->QAI_FILIAL+QAI->QAI_QUEST+QAI->QAI_RV+QAI->QAI_SEQPER == M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+cSeqPer
				aAdd(aCols,Array(Len(aHeader)+1))
				For nI := 1 To Len(aHeader)
					If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
						aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
					Else										// Campo Virtual
						cCpo := AllTrim(Upper(aHeader[nI,2]))
						aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
					Endif
				Next nI
				aCols[Len(aCols),Len(aHeader)+1] := .F.
				QAI->(DbSkip())
			EndDo
			lAchou:= .T.
		EndIf
	EndIf
	If !lAchou
		aCols := Array(1,Len(aHeader)+1)
		For nI = 1 To Len(aHeader)
			If aHeader[nI,8] == "C"
				aCols[1,nI] := Space(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
				aCols[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCols[1,nI] := CtoD("  /  /  ")
			ElseIf aHeader[nI,8] == "M"
				aCols[1,nI] := ""
			Else
				aCols[1,nI] := .F.
			EndIf
		Next nI
		If cAlias == "QAH"
			aCols[1,nPosSeq]:= "0001"
		EndIf
		aCols[1,Len(aHeader)+1] := .F.
	EndIf
Endif

If cAlias == "QAH"
	nEtapas := Len(aCols)
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QX050LinOk³ Autor ³ Eduardo de Souza     ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050LinOk()

Local lRet   := .t.
Local nCont  := 0
Local nPosSeq:= Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) == "QAH_SEQPER" })
Local nPosMem:= Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) == "QAH_MEMO1" })

If aCols[n,Len(aHeader)+1] == .F.
	If nPosMem <> 0
		If Empty(aCols[n,nPosMem])
			Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
			lRet:= .F.
		EndIf
	EndIf	
	If lRet
		If nPosSeq <> 0
			Aeval( aCols, { |X| If(X[Len(aHeader)+1] == .F. .And. X[nPosSeq] == aCols[N,nPosSeq] ,nCont++,nCont)})
			If nCont > 1
				Help(" ",1,"QALCTOJAEX") // "Informacao ja Cadastrada"
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QX050TudOk ³ Autor ³ Sergio S. Fuzinaka   ³ Data ³ 28.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Consistencia na gravacao TudoOk                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QAXA050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QX050TudOk()

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaQDH	:= QDH->(GetArea())

dbSelectArea("QDH")
dbSetOrder(1)
If !dbSeek(xFilial("QDH")+M->QAG_DOCTO+M->QAG_RVDOC)
	MsgStop(OemToAnsi(STR0014),OemToAnsi(STR0013))	//"Documento / Revisao nao encontrado!"#"Atencao!"
	lRet := .F.
Endif

RestArea( aAreaQDH)
RestArea( aArea )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QX050Resp ³ Autor ³ Eduardo de Souza     ³ Data ³ 28/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Respostas do Questionario.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050Resp(ExpL1,ExpL2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Deleta Linha aCols .T./.F.                         ³±±
±±³          ³ ExpL2 - Duplicacao de Questionario .T./.F.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050Resp(lDeleta,cFilQuest,cCodQuest,cRevQuest)

Local oDlgRes
Local aColsAux  := {}
Local aHeadPerg := {}
Local aColsPerg := {}
Local nPosSeqPer:= Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QAH_SEQPER"})
Local cSeqPer   := Acols[n,nPosSeqPer]
Local nPosPerGet:= n
Local aRespDupl := {}
Local aQAI      := {} 
Local nCnt
Local nC                              
Local nLib		:= 0
Local nPos		:= 0

DbSelectArea("QAI")
DbSetOrder(1)

If Empty(M->QAG_QUEST) .Or. Empty(M->QAG_RV)
	Return .F.
EndIf

DEFINE MSDIALOG oDlgRes TITLE OemToAnsi(STR0006)+" - "+OemToAnsi(STR0007) FROM 000,000 TO 285,625 OF oMainWnd PIXEL //"Cadastro de Questionarios" ### "Respostas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda Acols e aHeader do cadastro de perguntas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsPerg:= aClone(aCols)
aHeadPerg:= aClone(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Len(aHedRes) == 0 
	QX050Ahead("QAI")
	aHedRes:=Aclone(aHeader)
Else	
    aHeader:=Aclone(aHedRes)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Duplicacao das respostas do questionario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lQuestDupl
	nAt:=(TamSx3("QAG_QUEST")[1])+(TamSx3("QAG_QUEST")[1])
	nPos:=ASCAN(aColRes,{|x| subs(x[1],1,nAt)==M->QAG_QUEST+M->QAG_RV})
	IF nPos==0
		For nC:=1 To Len(aColRes)
			aColRes[nC,1]:=M->QAG_QUEST+M->QAG_RV+RIGHT(aColRes[nC,1],TamSx3("QAI_SEQPER")[1] )
		Next
	Endif
Endif

nPos:=ASCAN(aColRes,{|x| x[1]==M->QAG_QUEST+M->QAG_RV+cSeqPer})
IF nPos == 0
	QX050Acols(nOpcao,"QAI",cSeqPer)
Else
	aCols:=Aclone(aColRes[nPos,2])
Endif			                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Erro no Binario de Deletar a primeira linha do aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aCols[1,Len(aCols[1])]
	aCols[1,Len(aCols[1])]:=.F.
	lErroDel:= .T.
Else
	lErroDel:= .F.	
Endif	
	
oGetRes:= MSGetDados():New(033,002,140,312,nOpcao,"QXResLinOk","","",lDeleta)

IF lErroDel
	aCols[1,Len(aCols[1])]:=.T.
Endif
	
ACTIVATE MSDIALOG oDlgRes ON INIT EnchoiceBar(oDlgRes,{|| IF(QXResLinOk(),(nLib:=1,oDlgRes:End()),"")},{|| oDlgRes:End()}) CENTERED
                   
IF nLib==1
   	nPos:=ASCAN(aColRes,{|x| x[1]==M->QAG_QUEST+M->QAG_RV+cSeqPer})
    IF nPos==0 
		AADD(aColRes,{ALLTRIM(M->QAG_QUEST+M->QAG_RV+cSeqPer),aClone(aCols)})
	ELSE	  
		aColRes[nPos,2]:=aClone(aCols)
	Endif
	aColRes := aSort( aColRes,,,{ |x,y| x[1] < y[1] } )
Endif

Acols  := aClone(AcolsPerg)
aHeader:= aClone(aHeadPerg)
n:= nPosPerGet

Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QXResLinOk³ Autor ³ Eduardo de Souza     ³ Data ³ 28/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QXResLinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QXResLinOk()

Local lRet   := .t.
Local nCont  := 0
Local nPos01 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QAI_SEQRES"})
Local nPos02 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QAI_DESRES"})

If aCols[n,Len(aHeader)+1] == .F.
	If nPos02 <> 0
		If Empty(aCols[n,nPos02])
			Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
			lRet:= .F.
		EndIf
	EndIf	
	If lRet
		If nPos01 <> 0
			Aeval( aCols, { |X| If(X[Len(aHeader)+1] == .F. .And. X[nPos01] == aCols[N,nPos01],nCont++,nCont)})
			If nCont > 1
				Help(" ",1,"QALCTOJAEX") // "Informacao ja Cadastrada"
				lRet:= .F.
			EndIf
		EndIf
	Endif
	
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX050GrRes³ Autor ³ Eduardo de Souza      ³ Data ³ 04/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Respostas                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050GrRes(ExpN1,ExpA1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ ExpA1 - Acols Auxiliar                                     ³±±
±±³          ³ ExpC1 - Sequencia da Pergunta                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050GrRes(nOpc,aColsAux,cSeqPer,aHedAux)

Local nPos01  := GdFieldPos("QAI_SEQRES",aHedAux)
Local nCnt    := 0
Local nCpo    := 0
	
DbSelectArea("QAI")
DbSetOrder(1)
For nCnt:= 1 To Len(aColsAux)
	If !aColsAux[nCnt,Len(aHedAux)+1] //SE NAO DELETADO
		If QAI->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+cSeqPer+aColsAux[nCnt,nPos01]))
			RecLock("QAI",.F.)
		Else
			RecLock("QAI",.T.)
		EndIf
		For nCpo := 1 To Len(aHedAux)
			If aHedAux[nCpo, 10] <> "V"
				QAI->(FieldPut(FieldPos(Trim(aHedAux[nCpo,2])),aColsAux[nCnt,nCpo]))
			EndIf
			QAI->QAI_FILIAL:= xFilial("QAI")
			QAI->QAI_QUEST := M->QAG_QUEST
			QAI->QAI_RV    := M->QAG_RV
			QAI->QAI_SEQPER:= cSeqPer
		Next nCpo
		QAI->(MsUnlock())
	Else
		If QAI->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV+cSeqPer+aColsAux[nCnt,nPos01]))
			RecLock("QAI",.F.)
			QAI->(DbDelete())
			QAI->(MsUnlock())
			FKCOMMIT()
			QAI->(DbSkip())
		EndIf		
	EndIf
Next nCnt
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX050PSeq ³ Autor ³ Eduardo de Souza      ³ Data ³ 05/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Numero Sequencial das perguntas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050PSeq()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050PSeq()

Local nPosSeq:= Ascan(aHeader,{ |X| Upper(Alltrim(X[2])) == "QAH_SEQPER" })
Local nCnt   := 0
Local cSeqPer:= "0001"

For nCnt:= 1 To Len(aCols)
	If nCnt < n
		If !aCols[nCnt,Len(aHeader)+1]
			cSeqPer:= StrZero(Val(aCols[nCnt,nPosSeq])+1,4)
		EndIf
	Else
		Exit
	EndIf
Next nCnt

Return cSeqPer


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX050ChkQ ³ Autor ³ Eduardo de Souza      ³ Data ³ 18/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se questionario nao esta cadastrado.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050ChkQ()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050ChkQ()

Local lRet:= .T.

If QAG->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV))
	Help(" ",1,"QALCTOJAEX") // "Informacao ja Cadastrada"
	lRet:= .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX50VldDoc³ Autor ³ Eduardo de Souza      ³ Data ³ 18/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se Usuario pode cadastrar Quest. para o Documento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX50VldDoc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX50VldDoc()

Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]
Local cFiltro:= " "
Local lRet   := .F.

If Inclui
	cFiltro:= "QDH->QDH_FILIAL == '"+xFilial("QDH")+"' .And. QDH->QDH_OBSOL <> 'S' .And. QDH->QDH_CANCEL <> 'S'"
	DbSelectArea("QDH")
	Set Filter To &(cFiltro)
EndIf

If QDH->(DbSeek(xFilial("QDH")+M->QAG_DOCTO+M->QAG_RVDOC))
	If QD0->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
		While QD0->(!Eof()) .And. QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV
			If QD0->QD0_FLAG <> "I"
				If QD0->QD0_FILMAT+QD0->QD0_MAT == cMatFil+cMatCod
					If QD5->(DbSeek(xFilial("QD5")+QDH->QDH_CODTP+QD0->QD0_AUT))
						lRet:= If(QD5->QD5_ALT <> "S",.F.,.T.)
						If lRet
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			QD0->(DbSkip())
		EndDo
	EndIf
	If !lRet
		Help(" ",1,"QX50NQDOC") // "Usuario nao tem permissao para Visualizar/Incluir/Alterar/Excluir Questionario para o Documento Relacionado."
	EndIf
Else
	MsgStop(OemToAnsi(STR0014),OemToAnsi(STR0013))	//"Documento / Revisao nao encontrado!"#"Atencao!"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Documento ja esta cadastrado em outro Questionario. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. Inclui
	lRet:= QX50ChkDoc()
EndIf

DbSelectArea("QDH")
Set Filter To

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX50ChkDoc³ Autor ³ Eduardo de Souza      ³ Data ³ 18/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se Docto esta cadastrado em outro Questionario.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX50ChkDoc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX50ChkDoc()

Local lRet:= .T.

QAG->(DbSetOrder(2))
If QAG->(DbSeek(M->QAG_FILIAL+M->QAG_DOCTO+M->QAG_RVDOC))
	Help(" ",1,"QX50DCJAEX") // "Documento ja esta cadastrado em outro Questionario."
	lRet:= .F.
EndIf

QAG->(DbSetOrder(1))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX050VldPM³ Autor ³ Eduardo de Souza      ³ Data ³ 18/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida pontuacao minima na finalizacao do Questionario.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050VldPM()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050VldPM(aColRes,aHedRes,nOpc)

Local nPontos  := 0
Local lRet     := .T.
Local nI	   := 0
Local nX	   := 0
Local nPPonto  := GdFieldPos("QAI_PONTO",aHedRes)
Local aPerg    := {}
Local nResPonts:= 0

For nI:=1 to Len(aColRes)           
    For nX:=1 To Len(aColRes[nI,2])
		IF !aColRes[nI,2,nx,Len(aColRes[nI,2,nx])]
		    nPontos+= aColRes[nI,2,nX,nPPonto]
			nPos := Ascan(aPerg,{ |x| x[1] == aColRes[nI,1]})
				If nPos == 0
					AAdd(aPerg, {aColRes[nI,1],aColRes[nI,2,nX,nPPonto]})
		 		ElseIf aPerg[nPos][2] < aColRes[nI,2,nX,nPPonto]
					aPerg[nPos][2] := aColRes[nI,2,nX,nPPonto] 
				endIf 
	   	 Endif
   	Next
Next
		
For nI := 1 to Len(aPerg)
	nResPonts += aPerg[nI][2]
Next

IF nOpc == 4
	If QAI->(DbSeek(M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV))
		While QAI->(!Eof()) .And. QAI->QAI_FILIAL+QAI->QAI_QUEST+QAI->QAI_RV == M->QAG_FILIAL+M->QAG_QUEST+M->QAG_RV
			IF ASCAN(aColRes,{|X|  X[1]==QAI->QAI_QUEST+QAI->QAI_RV+QAI->QAI_SEQPER })== 0		
				nPontos+= QAI->QAI_PONTO
			Endif	
			QAI->(DbSkip())
		EndDo
	EndIf     
Endif	
If nResPonts < M->QAG_PONTMI
	Help(" ",1,"QX50PONTM") //"Pontuacao das respostas e menor que a pontuacao minima exigida para finalizar o Questionario."
	lRet:= .F.
elseIf nPontos < M->QAG_PONTMI
	Help(" ",1,"QX50PONTM") //"Pontuacao das respostas e menor que a pontuacao minima exigida para finalizar o Questionario."
	lRet:= .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX050QRes ³ Autor ³ Eduardo de Souza      ³ Data ³ 10/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de Questionario / Resposta.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050QRes(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Parametro 1                                        ³±±
±±³          ³ ExpC2 - Parametro 2                                        ³±±
±±³          ³ ExpC3 - Parametro 3                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Os parametros acima variam de Modulo para Modulo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050QRes(cParam1,cParam2,cParam3,nPontoAt)

Local oDlg
Local oPerg
Local oResp
Local bPergL1
Local bRespL1
Local oOK   := LoadBitmap(GetResources(),"ENABLE")
Local oNo   := LoadBitmap(GetResources(),"LBNO")
Local aQuest:= {}
Local cPerg := " "
Local cResp := " "

Local lRet  := .F.
Default nPontoAt := 0

If nModulo == 24
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe Questionario para o Documento relacionado. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QAG->(DbSetOrder(2))
	cParam1 := If(Empty(xFilial("QAG")), Space(FWSizeFilial()), cParam1) //Space(2)
	If !QAG->(DbSeek(cParam1+cParam2+cParam3))
		Return .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Questionario. 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QX050CarQ(QAG->QAG_FILIAL,QAG->QAG_QUEST,QAG->QAG_RV,@aQuest)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009)+" - "+AllTrim(QAG->QAG_TITULO) FROM 000,000 TO 450,625 OF oMainWnd PIXEL // "Questionario"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Perguntas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 033,003 SAY OemToAnsi(STR0008) SIZE 100,010 OF oDlg COLOR CLR_HRED,CLR_WHITE PIXEL // "Perguntas"
@ 040,003 LISTBOX oPerg VAR cPerg;
				FIELDS HEADER;
					TitSx3("QAH_SEQPER")[1],;
					TitSx3("QAH_DESPER")[1] ;
				SIZE 308,080 OF oDlg PIXEL;
				ON DBLCLICK QX050Perg(aQuest[oPerg:nAt,5])

bPergL1:= {||{aQuest[oPerg:nAt,4],AllTrim(MemoLine(MSMM(aQuest[oPerg:nAt,5],70),70))+"..."}}
oPerg:SetArray(aQuest)
oPerg:bLine:= bPergL1
oPerg:GoTop()
oPerg:cToolTip:= OemToAnsi(STR0010) //"Duplo click para visualizar a Pergunta"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Respostas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 123,003 SAY OemToAnsi(STR0007) SIZE 100,010 OF oDlg COLOR CLR_HRED,CLR_WHITE PIXEL // "Respostas"
@ 130,003 LISTBOX oResp VAR cResp;
				FIELDS HEADER " ",;
					TitSx3("QAI_SEQRES")[1],;
					TitSx3("QAI_DESRES")[1];
				SIZE 308,080 OF oDlg PIXEL;
				ON DBLCLICK FSelecCli(@aQuest,oPerg:nAt,@oResp)
				
bRespL1:= {|| {If (aQuest[oPerg:nAt,6,oResp:nAt,1],oOk,oNo),aQuest[oPerg:nAt,6,oResp:nAt,2],aQuest[oPerg:nAt,6,oResp:nAt,3]}}
oResp:SetArray(aQuest[oPerg:nAt,6])
oResp:bLine:= bRespL1
oPerg:bChange:= {|| oResp:SetArray(aQuest[oPerg:nAt,6]),oResp:bLine:= bRespL1,oResp:Gotop(),oResp:Refresh(.T.)}
oResp:cToolTip:= OemToAnsi(STR0011) //"Duplo click para marcar/desmarcar a resposta"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(QX50QRFim(aQuest,@nPontoAt),(lRet:= .T.,oDlg:End()),.F.)},{|| lRet:= .F.,oDlg:End()}) CENTERED

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX050CarQ ³ Autor ³ Eduardo de Souza      ³ Data ³ 10/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega array Questionario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX050CarQ(ExpC1,ExpC2,ExpC3,ExpA1)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Questionario                             ³±±
±±³          ³ ExpC2 - Codigo do Questionario                             ³±±
±±³          ³ ExpC3 - Revisao do Questionario                            ³±±
±±³          ³ ExpA1 - Array contendo Questionario                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX050CarQ(cFilQue,cCodQue,cRvQue,aQuest)

Local nCnt:= 1

If QAH->(DbSeek(cFilQue+cCodQue+cRvQue))
	While QAH->(!Eof()) .And. QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV == cFilQue+cCodQue+cRvQue
		If Ascan(aQuest,{|X| X[1]+X[2]+X[3]+X[4] == QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV+QAH->QAH_SEQPER}) == 0
			Aadd(aQuest,{QAH->QAH_FILIAL,QAH->QAH_QUEST,QAH->QAH_RV,QAH->QAH_SEQPER,QAH->QAH_DESPER,{}})
			If QAI->(DbSeek(QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV+QAH->QAH_SEQPER))
				While QAI->(!Eof()) .And. QAI->QAI_FILIAL+QAI->QAI_QUEST+QAI->QAI_RV+QAI->QAI_SEQPER == QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV+QAH->QAH_SEQPER
					If Ascan(aQuest[nCnt,6],{|X| X[2] == QAI->QAI_SEQRES}) == 0
						Aadd(aQuest[nCnt,6],{.F.,QAI->QAI_SEQRES,QAI->QAI_DESRES,QAI->QAI_PONTO})
					EndIf
					QAI->(DbSkip())
				EndDo
			EndIf
			If Len(aQuest[nCnt,6]) == 0
				Aadd(aQuest[nCnt,6],{.F.,Space(4),Space(150)})
			EndIf			
		EndIf
		QAH->(DbSkip())	
		nCnt++
	EndDo
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FSelecCli ³ Autor ³ Eduardo de Souza      ³ Data ³ 10/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratar o click da Resposta.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSelecCli(ExpO1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo os Questionarios                    ³±±
±±³          ³ ExpN1 - Posicao da Pergunta no Array                       ³±±
±±³          ³ ExpO1 - ListBox de Respostas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FSelecCli(aQuest,nPerg,oResp)

Local nI:= 0

aQuest[nPerg,6,oResp:nAt,1]:= !aQuest[nPerg,6,oResp:nAt,1]

If !aQuest[nPerg,6,oResp:nAt,1] .Or. (Len(aQuest[nPerg,6]) == 1 .And. Empty(aQuest[nPerg,6,oResp:nAt,2]))
	aQuest[nPerg,6,oResp:nAt,1]:= .F.
EndIf

For nI:= 1 To Len(aQuest[nPerg,6])
	If aQuest[nPerg,6,nI,1] .And. nI <> oResp:nAt
		aQuest[nPerg,6,nI,1]:= .F.
	EndIf
Next nI

oResp:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FSelecCli ³ Autor ³ Eduardo de Souza      ³ Data ³ 10/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratar o click da Resposta.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSelecCli(ExpO1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo os Questionarios                    ³±±
±±³          ³ ExpN1 - Posicao da Pergunta no Array                       ³±±
±±³          ³ ExpO1 - ListBox de Respostas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QX050Perg(cPerg)

Local oDlgPer
Local oMemo
Local oBtnOk
Local cMemo := MSMM(cPerg,70)

DEFINE MSDIALOG oDlgPer TITLE OemToAnsi(STR0008) FROM 000,000 TO 160,525 OF oMainWnd PIXEL // "Perguntas"

@ 003,003 GET oMemo VAR cMemo MEMO NO VSCROLL SIZE 258,060 OF oDlgPer PIXEL 
oMemo:lReadOnly:= .T.

DEFINE SBUTTON	oBtnOk FROM 065,003 ENABLE TYPE 1 OF oDlgPer;
			ACTION oDlgPer:End()

ACTIVATE MSDIALOG oDlgPer CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QX50QRFim ³ Autor ³ Eduardo de Souza      ³ Data ³ 11/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica finalizacao do Questionario Respondido.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QX50QRFim()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QX50QRFim(aQuest,nPontResp)

Local nCnt1    := 0
Local nCnt2    := 0
Default nPontResp := 0

nPontResp := 0
For nCnt1:= 1 To Len(aQuest)
	For nCnt2:= 1 To Len(aQuest[nCnt1,6])
		If aQuest[nCnt1,6,nCnt2,1]
			nPontResp+= aQuest[nCnt1,6,nCnt2,4]
		EndIf
	Next nCnt2
Next nCnt1

If nPontResp < QAG->QAG_PONTMI
	Help(" ",1,"QX50NPONT") // "Nao foi atingida a pontuacao minima exigida no Questionario. Responda novamente."
	Return .F.
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAX50INIMEM³ Autor ³ Aldo Marini Junior   ³ Data ³ 26/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Inicializacao padrao dos campos memo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAX50INIMEM(cExpC1,cExpN1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo que recebera a inicializacao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAX50INIMEM(cCampo)

If INCLUI
	cRet:= " "
Else
	If lDlgEtapa
		If nEtapas < n
			cRet:= " "
		Else
			cRet:= MSMM(cCampo,80)	
		EndIf
	Else
		cRet:= MSMM(cCampo,80)	
	Endif
EndIf

Return cRet