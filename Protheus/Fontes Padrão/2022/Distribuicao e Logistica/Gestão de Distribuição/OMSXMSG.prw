#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FIVEWIN.CH"
#INCLUDE "OMSXMSG.CH"

#DEFINE MSG_INFO     0
#DEFINE MSG_WARNING  1
#DEFINE MSG_ERROR    2
#DEFINE MSG_QUESTION 3
#DEFINE MSG_CUSTOM   4
#DEFINE MSG_HELP     5
#DEFINE MAXHELP      40

Static _cMessage  := ""
Static _cTitle    := "SIGAOMS"
Static _nTipoMsg  := 0
Static _lExibeMsg := .T.

Function OmsMsgExibe(lExibe)
Local lOldExibe := _lExibeMsg
	If ValType(lExibe) == 'L'
		_lExibeMsg := lExibe
	EndIf
Return lOldExibe

Function OmsLastMsg()
Return _cMessage

Function OmsLastTit()
Return _cTitle

Function OmsMsgType()
Return _nTipoMsg

Function OmsQuestion(cMsg,cTitle)
Default cTitle := "SIGAOMS"
Return MsgYesNo(cMsg,cTitle)

Function OmsMessage(cMsg,cTitle,nTipo,lExibe,aBtns,cSolucao,nTamAvis)
Default cTitle   := "SIGAOMS"
Default nTipo    := MSG_INFO
Default lExibe   := _lExibeMsg
Default aBtns    := {"OK"}
Default cSolucao := ""
Default nTamAvis := 3

	_cMessage := cMsg
	_cTitle   := cTitle
	_nTipoMsg := nTipo

	If !lExibe
		Return Nil
	EndIf

	If nTipo != MSG_QUESTION .And. !Empty(cSolucao)
		OmsHelp(cMsg,cSolucao,cTitle)
	ElseIf nTipo == MSG_INFO
		MsgInfo(cMsg,cTitle)
	ElseIf nTipo == MSG_WARNING
		MsgAlert(cMsg,cTitle)
	ElseIf nTipo == MSG_ERROR
		MsgStop(cMsg,cTitle)
	ElseIf nTipo == MSG_QUESTION
		Return MsgYesNo(cMsg,cTitle)
	ElseIf nTipo == MSG_HELP
		OmsHelp(cMsg,cSolucao,cTitle)
	Else
		Return Aviso(cTitle,cMsg,aBtns,nTamAvis)
	EndIf

Return Nil

Function OmsFmtMsg(cMessage,aStrRepl)
Local nI      := 0
Local cRetMsg := cMessage

	For nI := 1 To Len(aStrRepl)
		If ValType(aStrRepl[nI]) == "A" .And. Len(aStrRepl[nI]) == 2
			cRetMsg := StrTran(cRetMsg,aStrRepl[nI][1],AllTrim(aStrRepl[nI][2]))
		EndIf
	Next

Return cRetMsg

Function OmsHelp(cProblema,cSolucao,cTitle)
Local aSolucao  := {}
Local nLines    := 0
Local nCnt      := 0
Default cTitle := "SIGAOMS"

	If Empty(cSolucao)
		Help( ,1,cTitle,,cProblema,1,0)
	Else
		nLines := MlCount(cSolucao, MAXHELP)
		For nCnt := 1 To nLines
			AAdd(aSolucao, MemoLine(cSolucao, MAXHELP, nCnt))
			//O máximo de linhas possíveis é 5
			If nCnt == 5
				Exit
			EndIf
		Next nCnt
		//Help - Ajuda para o campo ( [ uPar1 ] [ uPar2 ] [ cCampo ] [ cNome ] [ cMensagem ] [ nLinha1 ] [ nColuna ] [ lPop ] [ uPar9 ] [ uPar10 ] [ uPar11 ] [ lGravaLog ][aSoluc] )
		Help(,1,cTitle,,cProblema,1,0,,,,,,aSolucao)
		//ShowHelpDlg(cTitle,aProblema,Len(aProblema),aSolucao,Len(aSolucao))
	EndIf

Return Nil
//----------------------------------------
/*/{Protheus.doc} OmsShowWng
Monta tela para exibição dos erros/avisos
@author amanda.vieira
@since 29/10/2018
@version 1.0
/*/
//----------------------------------------
Function OmsShowWng(aAviso)
Local nCntFor := 0
Local cMemo   := ""
Local cMask   := STR0001 // Arquivos Texto (*.TXT) |*.txt|
Local cFile   := Space(100)
Local cTitle  := OemToAnsi(OemToAnsi(STR0002)) // Salvar Arquivo
	If OmsMsgExibe()
		If !Empty(aAviso)
			For nCntFor := 1 To Len(aAviso)
				If nCntFor == 1
					cMemo := aAviso[nCntFor]
				Else
					cMemo += CRLF+ cValToChar(aAviso[nCntFor])
				EndIf
			Next

			DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15	
			DEFINE MSDIALOG oDlg TITLE "SIGAOMS" From 3,0 to 340,717 PIXEL	
			
			@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 343,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
				
			DEFINE SBUTTON  FROM 153,325 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL // Apaga
			DEFINE SBUTTON  FROM 153,295 TYPE 13 ACTION (cFile:=cGetFile(cMask,cTitle),If(cFile="",.T.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL // Salva e Apaga //"Salvar Como..."

			ACTIVATE MSDIALOG oDlg CENTER
		EndIf
	Else
		OmsMessage(cMemo,"ShowWarnig")
	EndIf
Return
