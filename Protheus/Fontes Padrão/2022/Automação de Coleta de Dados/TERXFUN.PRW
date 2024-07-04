#INCLUDE "TERXFUN.ch"
#INCLUDE "PROTHEUS.CH"
#include "error.ch"
#include "apvt100.ch"



STATIC TERMINAL
STATIC COMUTADORA
STATIC LESC := .F.

STATIC oMemoDeb
STATIC cMemoDeb   := ""
STATIC oMemoPar
STATIC cMemoPar   := ""
STATIC oMemoSer
STATIC cMemoSer   := ""

STATIC LDEBUG     := .F.
STATIC oDlgDebTer
STATIC lExitTer   := .F.
STATIC cBufSimTer := ""
STATIC cLin0      := "                                        "
STATIC cLin1      := "                                        "
STATIC nPosLin    := 0
STATIC nPosCol    := 0
STATIC WAITT      := 0
STATIC KPIC
STATIC PPIC
STATIC KBD
STATIC lImpPar:=.f.
STATIC lImpSer:=.f.
STATIC _PROTOCOLO:="PROTHEUS"
STATIC __cModelo := "MT44" //MT16
STATIC __cIntBuffer:=""
Static __cLastKey := Chr(0)
Static __laBrwRefresh:= .f.
Static __lDbBrwRefresh:= .f.
Static __lGetFill := .t.
Static lVarGbl := .t.

/*
DOCUMENTACAO DAS FUNCOES NECESSARIAS PARA O DESENVOLVIMENTO DE UMA APLICACAO NO MICROTERMINAL.

Function TerCls()
   - limpa a tela

Function TerSay(nLin,nCol,cMsg)
   - Escreve no display do microterminal

Function TerInkey(nSecs)
   - Aguarda pressionamento de uma tecla no microterminal ou ate dar o tempo solicitado.

Function TerCBuffer()
   - Limpa o buffer do teclado do microterminal

Function TerGetRead(nLin,nCol,uVar,cPict,bValid,bWhen)
   - Faz um Get na tela do microterminal

Function TerEsc()
   - Retorna .T. caso tenha sido teclado DEL (ESC) no ultimo GET.

Function TerBeep(nVezes)
   - Faz um Beep no microterminal (precisa ter instalado o buzzer no microterminal).

Function TerNumTer()
   - Retorna o numero do microterminal.

Function TerSave(nLin1,nCol1,nLin2,nCol2)
   - Salva a tela do microterminal.

Function TerRestore(nLin1,nCol1,nLin2,nCol2,cTela)
   - Restaura a tela do microterminal.

Function TerPBegin(nTerm,cSerPar)
   - Inicia uma impressao (E' NECESSARIO INICIAR A IMPRESSAO ANTES DE USAR O COMANDO TERPRINT).

Function TerPrint( cString, lPula )
   - Imprime a string desejada em uma impressora conectada no microterminal

Function TerPEnd()
   - Finaliza impressao.

Function TerSet(nComu,nTerm)
   - Para compatibilizacao com programas do SIGALOJA.

Function TerIsQuit()
   - Funcao que verifica se o servidor do microterminal esta tentando finalizar este microterminal, esta funcao devera
     ser colocada em pontos da aplicacao em que a finalizacao nao afete o processamento.
Function TerModelo(cModelo)
   - Ajusta ou retorno o modelo do microterminal MT16 OU MT44

Function TerProtocolo(cProtocolo)
Function TerNumTer()
Function TeraChoice(nTop,nLeft,nBottom,nRight,aMenu,cFunct,nIniVetor,nIniW)
Function TerLastKey()
Function TeraBrowse(nTop,nLeft,nBottom,nRight,aCab,aItens,aSize,cFunct,nIniVetor)
Function TeraBrwRefresh()
Function TerDbBrowse(nTop,nLeft,nBottom,nRight,cAlias,aCab,aFields,aSizeFields,cFunct,cTop,cBottom)
Function TerDbBrwRefresh()
Function TerDispFile(cArquivo)
*/

Function TerProtocolo(cProtocolo)
If cProtocolo==NIL
	Return _Protocolo
EndIf
_Protocolo:=Upper(Alltrim(cProtocolo))
Return ''

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TerCls   ³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Limpa a tela do Microterminal                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerCls()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerCls()
Local cStrTer
Local nX:=1
If TerProtocolo()=="GRADUAL"
	cStrTer := "03"
	TerEnv(cStrTer)
ElseIf TerProtocolo()=="VT100"
	For nx:= 0 to VTMaxRow()
		VTSay(nX,0,Space(VtMaxCol()+1))
	Next
	VtSay(0,0,"")
EndIf
Return .T.

Function TerClear()
Return TerCls()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TerSetPos³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Posiciona o Cursor do Microterminal                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerSetPos(nLin,nCol)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLin - Linha a Posicionar                                  ³±±
±±³          ³ nCol - Coluna a Posicionar                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerSetPos( nLin, nCol )
Local cStrTer
If TerProtocolo()=="GRADUAL"
	cStrTer := "04"+Strzero(nLin,2)+Strzero(nCol,2)
	TerEnv(cStrTer)
ElseIf TerProtocolo()=="VT100"
	VTSay(nLin,nCol)
EndIf
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TerDevout³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Mostra uma mensagem na tela                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerDevout(cMsg)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMsg - Mensagem                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal e na funcao TERSAY              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerDevout( cMsg )
Local cStrTer
If TerProtocolo()=="GRADUAL"
	cStrTer := "05"+cMsg
	TerEnv(cStrTer)
ElseIf TerProtocolo()=="VT100"
	VTSay(VtRow(),VtCol(),cMsg)
EndIf
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TerSave  ³ Autor ³ Eduardo Motta         ³ Data ³ 26/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Salva a tela do MicroTerminal                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TerSave(nLin1,nCol1,nLin2,nCol2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerSave(nLin1,nCol1,nLin2,nCol2)
Local cStrTer
Local uRet
Local nMaxCol := If(TerModelo()=="MT16",19,39)
If TerProtocolo()=="GRADUAL"
	nLin1 := If(nLin1==NIL,00,nLin1)
	nLin2 := If(nLin2==NIL,01,nLin2)
	nCol1 := If(nCol1==NIL,00,nCol1)
	nCol2 := If(nCol2==NIL,nMaxCol,nCol2)
	cStrTer := "14"+StrZero(nLin1,1)+StrZero(nCol1,2)+StrZero(nLin2,1)+StrZero(nCol2,2)
	uRet:= (StrZero(nCol2-nCol1+1,2)+TerEnv(cStrTer))
ElseIf TerProtocolo()=="VT100"
	uRet:=VTSave(nLin1,nCol1,nLin2,nCol2)
EndIf
Return uRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerRestore³ Autor ³ Eduardo Motta         ³ Data ³ 26/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Restaura a tela do Microterminal                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TerRestore(nLin1,nCol1,nLin2,nCol2,cTela)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTela - Conteudo retornado pelo TerSave                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerRestore(nLin1,nCol1,nLin2,nCol2,cTela)
Local nTamLin
Local cStrTela
Local nMaxCol := If(TerModelo()=="MT16",19,39)

If TerProtocolo()=="GRADUAL"
	nTamLin := Val(SubStr(cTela,1,2))
	cStrTela := SubStr(cTela,3)

	nLin1 := If(nLin1==NIL,00,nLin1)
	nLin2 := If(nLin2==NIL,01,nLin2)
	nCol1 := If(nCol1==NIL,00,nCol1)
	nCol2 := If(nCol2==NIL,nMaxCol,nCol2)

	If nTamLin > (nCol2-nCol1+1)
		nTamCalc := (nCol2-nCol1+1)
	Else
		nTamCalc := nTamLin
	EndIf

	TerSay(nLin1,nCol1,SubStr(cStrTela,1,nTamCalc))

	If nLin1 # nLin2 .and. nLin2 <= 2
		TerSay(nLin2,nCol1,SubStr(cStrTela,nTamLin+1,nTamCalc))
	EndIf
ElseIf TerProtocolo()=="VT100"
	VTRestore(nLin1,nLin2,nCol1,nCol2,cTela)
EndIf
Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TerSay   ³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Mostra mensagem na tela do microterminal na linha e coluna ³±±
±±³          ³ especificada.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerSay(nLin,nCol,cMsg)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLin - Linha a mostrar a mensagem                          ³±±
±±³          ³ nCol - Coluna a mostrar a mensagem                         ³±±
±±³          ³ cMsg - Mensagem                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerSay(nLin,nCol,cMsg)
DEFAULT cMsg:=""
If TerProtocolo()=="GRADUAL"
	TerSetPos(nLin,nCol)
	TerDevout(cMsg)
ElseIf TerProtocolo()=="VT100"
	VtSay(nLin,nCol,cMsg)
EndIf
Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TerInkey ³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Aguarda o pressionamento de uma tecla no microterminal.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerInkey(nSecs)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nSecs - Numero de segundos a esperar                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerInkey(nSecs)
Local cTecla := Chr(0)
Local nSecAux
DEFAULT nSecs:=0

If TerProtocolo()=="GRADUAL"
	If Len(__cIntBuffer) == 0
		nSecAux:=Seconds()+nSecs
		While cTecla == Chr(0)
			cStrTer := "08"
			cStrTer :=TerEnv(cStrTer)
			Sleep(50)
			cTecla:=substr( cStrTer, 1, 1 )
			__cLastKey := cTecla
			If nSecs <> 0 .and. Seconds()>nSecAux
				Exit
			EndIf
		EndDo
	Else
		cTecla := Left(__cIntBuffer,1)
		__cIntBuffer := Subs(__cIntBuffer,2)
		__cLastKey := cTecla
	EndIf

	If cTecla == Chr(127)
		LESC := .T.
	Else
		LESC := .F.
	EndIf
ElseIf TerProtocolo()=="VT100"
	cTecla := VtInkey(nSecs)
	cTecla := chr(cTecla)
	If VtLastKey()==27
		LESC := .T.
	EndIf
EndIf
Return cTecla

Function TerKeyBoard(cBuffer)
If TerProtocolo()=="GRADUAL"
	If Asc(cBuffer) == 27
		cBuffer := chr(127)
	EndIf
	__cIntBuffer += cBuffer
Else
	VTKeyboard(cBuffer)
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerCBuffer³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Limpa o buffer do teclado do microterminal se houver.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerCBuffer()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerCBuffer()
Local cBuffer := "",cTecla := Space(01)
If TerProtocolo()=="GRADUAL"
	While cTecla # Chr(0)
		cStrTer := "08"
		cTecla := TerEnv(cStrTer)
		If cTecla # Chr(0)
			cBuffer+=cTecla
		EndIf
	EndDo
	LESC := .F.
ElseIf TerProtocolo()=="VT100"
	VtClearBuffer()
EndIf
Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerGetRead³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Executa um GET no microterminal                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerGetRead(nLin,nCol,@uVar,cPict,bValid,bWhen)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLin   - Linha a executar o Get                            ³±±
±±³          ³ nCol   - Coluna a executar o Get                           ³±±
±±³          ³ uVar   - Variavel **( DEVE SER PASSADO POR REFERENCIA @)** ³±±
±±³          ³ cPict  - Codigo da Picture                                 ³±±
±±³          ³ bValid - COD BLOCK da Validacao                            ³±±
±±³          ³ bWhen  - COD BLOCK do When                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerGetRead(nLin,nCol,uVar,cPict,bValid,bWhen)
Local nTam := 0
Local nDec := 0
Local uVarAnt:= uVar
Local cVar
Local lwhen
DEFAULT cPict:=""
DEFAULT bValid := {|| .t.}
DEFAULT bWhen := {|| .t.}

LESC := .F.
If TerProtocolo()=="VT100"
	If Right(cPict,1)=="@"
		cPict := Left(cPict,len(cPict)-1)
	EndIf
	cPict := StrTran(cPict,"X","!")
	lwhen :=eval(bWhen)
	While .t.
		If Right(cPict,1)=="*"
			@ nLin, nCol VTGet uVar PICT cPict when lWhen PASSWORD
		Else
			@ nLin, nCol VTGet uVar PICT cPict when lWhen
		EndIf
		VTRead
		If VTLastKey() == 27
			LESC := .t.
			Exit
		EndIf
		If !lWhen .or. Eval(bValid)
			Exit
		EndIf
	EndDo
	Return NIL
EndIf

If ValType(uVar) == "C"
	nTam := Len(cPict)
	If "@" $ cPict
		nTam--
	EndIf

	uVar := Padr(uVar,nTam)
ElseIf ValType(uVar) == "N"
	nTam := len(cPict)
	If "@" $ cPict
		nTam--
	EndIf
	nDec := At(".",cPict)
	If nDec >0
		nDec := nTam-nDec
	EndIf
EndIf

bValid := If(bValid#nil,bValid,{||.T.})
bWhen  := If(bWhen #nil,bWhen ,{||.T.})

If !Eval(bWhen)
	Return NIL
EndIf
While .T.
	If ValType(uVar) == "C"
		If __lGetFill
			TerSay(nLin,nCol,padr(AllTrim(uVar),nTam,"."))
		EndIf
		cVar := uVar
	ElseIf ValType(uVar) == "N"
		TerSay(nLin,nCol,Str(uVar,nTam,nDec))
		cVar := Str(uVar,nTam,nDec)
	ElseIf ValType(uVar) == "D"
		TerSay(nLin,nCol,DTOC(uVar))
		cVar := Dtoc(uVar)
	EndIf
	TerSetPos(nLin,nCol)
	cVar := TerGet(cPict,cVar)
	If SubStr(cVar,1,1) == Chr(127)
		LESC := .T.
		uVar := uVarAnt
		Exit
	EndIf
	If ValType(uVar) == "C"
		uVar := Left(cVar,nTam)
	ElseIf ValType(uVar) == "N"
		If nDec > 0
			uVar := Val(Alltrim(left(cVar,At(".",cPict)-1))+"."+Alltrim(Subs(cVar,At(".",cPict)+1)))
		Else
			uVar := Val(cVar)
		EndIf
	ElseIf ValType(uVar) == "D"
		If ! Empty(StrTran(cVar,"/","")) .and. Empty(ctod(cVar))
			Loop
		EndIf
		uVar := ctod(cVar)
	EndIf
	If Eval(bValid)
		Exit
	EndIf
EndDo
If ValType(uVar) == "C"
	If Right(cPict,1)=="*"
		TerSay(nLin,nCol,Repl("*",len(AllTrim(uVar))))
	Else
		//TerSay(nLin,nCol,padr(AllTrim(uVar),nTam," "))
	EndIf
ElseIf ValType(uVar) == "N"
	TerSay(nLin,nCol,Str(uVar,nTam,nDec))
EndIf
Return NIL



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerEsc    ³ Autor ³ Eduardo Motta         ³ Data ³ 29/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Verifica se ultima tecla pressionada foi o esc             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerEsc()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerEsc()
Local lRet
If TerProtocolo()=="GRADUAL"
	lRet:= LESC
ElseIf TerProtocolo()=="VT100"
	lRet:= VTLastkey()==27
EndIf
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerBeep   ³ Autor ³ Eduardo Motta         ³ Data ³ 06/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Faz um Beep no microterminal (PRECISA TER INSTALADO O      ³±±
±±³          ³ BUZZER NO MICROTERMINAL)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerBeep(nVezes)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVezes - Numeros de BEEPs                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerBeep(nVezes)
Local nI,cStrTer
DEFAULT nVezes :=1
If LDEBUG
	Return
EndIf
If TerProtocolo()=="GRADUAL"
	nVezes := If(nVezes==Nil,1,nVezes)
	For nI := 1 to nVezes
		cStrTer := "13"
		cStrTer :=TerEnv(cStrTer)
	Next
ElseIf TerProtocolo()=="VT100"
	VtBeep(nVezes)
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerNumTer ³ Autor ³ Eduardo Motta         ³ Data ³ 06/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Retorna o numero do microterminal                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerNumTer()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerNumTer()
If TerProtocolo()=="VT100"
	Return VTNumRF()
EndIf
Return TERMINAL

Function TerAlert(cMsg,cTitulo,nSleep,nBeep)
Local cTela
Local cConteudo
Local nMaxCol := If(TerModelo()=="MT16",19,39)
Local nLen,i,aMsg:={}
DEFAULT cTitulo := Left(cVersao,8)

If nBeep#NIL
	TerBeep(nBeep)
EndIf

cConteudo:= "["+Alltrim(cTitulo)+"] "+cMsg
nLen:= MlCount(cConteudo,nMaxCol)
For i := 1 To nLen
	Aadd(aMsg,MemoLine(cConteudo,nMaxCol,i))
Next
cTela := TerSave()
TerCls()
If nSleep#NIL
	TerKeyboard(chr(13))
EndIf
TeraChoice(,,,,aMsg)
If nSleep#NIL
	TerInkey(nSleep/1000)
EndIf
TerRestore(,,,,cTela)
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerGet    ³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao auxiliar para o TERGETREAD                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerGet( formato)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ formato- Picture                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Funcao TERGETREAD                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerGet(formato,cConteudo)
Local cStrTer
cStrTer := "06"+formato
TerEnv(cStrTer)
cStrTer := "15"+cConteudo
TerEnv(cStrTer)
cStrTer := "07"
Return TerEnv(cStrTer)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerEnv    ³ Autor ³ Eduardo Motta         ³ Data ³ 29/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao de comunicacao com o servidor do microterminal.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerEnv( cStrTer)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cStrTer - String a ser interpretada no microterminal       ³±±
±±³          ³ lAguRet - Verifica se envio tem retorno.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TERXFUN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TerEnv(cStrTer,lAguRet)
Local nH,nPos,cString:='',nterminal:=TERMINAL
Local cArquivo
DEFAULT lAguRet := .T.
If LDEBUG
	Return TerEnvDeb(cStrTer,lAguRet)
EndIf

If ! lVarGbl  // utilizando arquivos de controle
	cArquivo:='TER'+StrZero(COMUTADORA,2)+StrZero(nTerminal,2)+'.GRD'
	TerIsQuit("FIM")
	While  (nH := FCreate(cArquivo))  == -1
		TerIsQuit("FIM")
		SLEEP(10)
	End
	cStrTer := 'E'+cStrTer
	FWrite(nH,cStrTer,Len(cStrTer))
	FClose(nH)
	// resposta
	While lAguRet
		TerIsQuit("FIM")
		While  (nH:=fopen(cArquivo, 1 ))  == -1
			TerIsQuit("FIM")
			SLEEP(10)
		End
		nPos := FSeek(nH,0,2)
		FSeek(nH,0,0)
		cString := Space(nPos)
		FRead(nH,@cString,Len(cString))
		Fclose(nH)
		If Left(cString,1) =='R'
			Exit
		EndIf
		SLEEP(10)
	End
	If lAguRet
		FErase(cArquivo)
	EndIf
Else               // utilizando variaveis globais

	cArquivo:='TER'+StrZero(COMUTADORA,2)+StrZero(nTerminal,2)
	TerIsQuit("FIM")
	cStrTer := 'E'+cStrTer
	PutGlbValue(cArquivo,cStrTer)
	// resposta
	While lAguRet .and. !KillApp()
		TerIsQuit("FIM")
		cString := GetGlbValue(cArquivo)
		If Left(cString,1) =='R'
			Exit
		EndIf
		SLEEP(10)
	End
	If lAguRet
		PutGlbValue(cArquivo,"")
	EndIf
EndIf
Return If(Subs(cString,2)#NIL,Subs(cString,2,len(cString)-1),chr(0))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerPBegin ³ Autor ³ Eduardo Motta         ³ Data ³ 11/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao que faz o travamento para impressao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerPBegin(nTerm,cSerPar,nVeloc)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTerm   - Numero do microterminal a imprimir, se for NIL   ³±±
±±³          ³         assume o terminal definido no servidor.            ³±±
±±³          ³ cSerPar - 'S' (DEFAULT) porta serial  / 'P' porta paralela ³±±
±±³          ³ nVeloc  - 3  (DEFAULT)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerPBegin(nTerm,cSerPar,nVeloc)
Local cStrTer
If TerProtocolo()=="GRADUAL"
	nVeloc := If(nVeloc#nil,nVeloc,3)
	cStrTer := "09"+If(nTerm#NIL,StrZero(nTerm+1,2),Space(02))+cSerPar+StrZero(nVeloc,2)
	TerEnv(cStrTer)
ElseIf TerProtocolo()=="VT100"
	VTImpDef(cSerPar)
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerPEnd   ³ Autor ³ Eduardo Motta         ³ Data ³ 11/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao que destrava a impressora para outros microterminais³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerPEnd()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerPEnd()
Local cStrTer
If TerProtocolo()=="GRADUAL"
	cStrTer := "11"
	TerEnv(cStrTer)
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerPrint  ³ Autor ³ Eduardo Motta         ³ Data ³ 11/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao para imprimir no microterminal                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerPrint(cString, cSerPar, lPula, nTerm)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cString - String a imprimir                                ³±±
±±³          ³ lPula   - Se salta uma linha apos a impressao (DEF. .T.)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerPrint( cString, lPula)
Local cStrTer
lPula := If(lPula==Nil,.t.,lPula)
If TerProtocolo()=="GRADUAL"
	If ! LDEBUG
		cStrTer := "10"+cString+If(lPula,Chr(10)+Chr(13),"")
	Else
		cStrTer := "10"+cString+If(lPula,Chr(13),"")
	EndIf
	TerEnv(cStrTer)
ElseIf TerProtocolo()=="VT100"
	VTImp(cString+If(lPula,Chr(10)+Chr(13),""))
EndIf

Return .t.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerSet    ³ Autor ³ Eduardo Motta         ³ Data ³ 29/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao para compatibilizar com programas do SIGALOJA       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerSet(nComu,nTerm)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nComu   - Seta o numero da comutadora.                     ³±±
±±³          ³ nTerm   - Seta o numero do microterminal.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerSet(nComu,nTerm)
COMUTADORA := nComu
TERMINAL   := nTerm
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerIsQuit ³ Autor ³ Eduardo Motta         ³ Data ³ 29/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao para verificar se o servidor enviou mensagem de     ³±±
±±³          ³ finalizacao.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerIsQuit(cExt,lFim)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExt - Extensao a verificar                                ³±±
±±³          ³ lFim - se estiver .T. forca a finalizacao com o servidor   ³±±
±±³          ³        de microterminais.                                  ³±±
±±³          ³ lQuit- se o quit e' executado ou nao (.T. DEFAULT)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Aplicacao do Microterminal                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TerIsQuit(cExt,lFim,lQuit)
Local cArquivo
Local cStrTer
Local cConteudo
If TerProtocolo()=="VT100"
	Return
EndIf
cExt  := If(cExt==Nil,"AGU",cExt)
lFim  := If(lFim==Nil,.f.,lFim)
lQuit := If(lQuit==Nil,.T.,lQuit)
If ! lVarGbl
	cArquivo := "TER"+StrZero(COMUTADORA,2)+StrZero(TERMINAL,2)+"."+cExt
	If file(cArquivo) .or. lFim
		If cExt == "AGU"
			cStrTer := "12"
			TerEnv(cStrTer,.F.)
		EndIf
		ConOut(STR0001+StrZero(Terminal,2)+STR0002) //"Microterminal "###" finalizado."
		//fErase(cArquivo)
		If lQuit
			Quit
		EndIf
	EndIf
Else
	cArquivo := Upper(cExt)+StrZero(COMUTADORA,2)+StrZero(TERMINAL,2)
	cConteudo := GetGlbValue(cArquivo)

	If Alltrim(cConteudo)=="1" .or. lFim
		If cExt == "AGU"
			cStrTer := "12"
			TerEnv(cStrTer,.F.)
		EndIf
		ConOut(STR0002+StrZero(Terminal,2)+STR0002) //"Microterminal "###" finalizado."
		If lQuit
			Quit
		EndIf

	EndIf
EndIf
Return .F.


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// abaixo estao funcoes exclusivas que somente são usadas pelo servidor de microterminal, estas funcoes nao deverao//
// ser utilizadas em advpl                                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TerJob   ³ Autor ³ Eduardo Motta         ³ Data ³ 10/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Cria JOB no server para controlar o Microterminal          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerJob(cEmp,cFil,nTer,cFun,cModCon,uPar01)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEmp   - Empresa para iniciar o MicroTerminal              ³±±
±±³          ³ cFil   - Filial a iniciar o MicroTerminal                  ³±±
±±³          ³ cComu  - Numero da Comutadora                              ³±±
±±³          ³ cTer   - Numero do MicroTerminal(de 0 a 32)                ³±±
±±³          ³ cFun   - Nome da Funcao para iniciar o JOB                 ³±±
±±³          ³ cModCon- Modulo da aplicacao do Microterminal              ³±±
±±³          ³ cPar01 - Parametro a passar para a funcao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SERVIDOR DO MICROTERMINAL                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TerJob(cEmp,cFil,cComu,cTer,cFun,cModCon,uPar01,cModelo)
Local bBlockErr := ErrorBlock()
Local aModulos:={}
Local nPos
Private cModulo
Private nModulo

cEmp     := If(cEmp#nil,cEmp,"99")
cFil     := If(cFil#nil,cFil,"01")
cTer     := If(cTer#nil,cTer,"00")
cComu    := If(cComu#nil,cComu,"01")
If cModelo==NIL
	cModelo:='MT44'
	TerIsVarGbl(.f.)
Else
	TerIsVarGbl(.t.)
EndIf
TerProtocolo("GRADUAL")

TERMINAL   := Val(cTer)
COMUTADORA := Val(cComu)
RpcSetEnv( cEmp, cFil,,,'ACD',, )    // cria o enviroment com a abertura das tabelas
If ! Empty(cModCon)
	aModulos:= RetModName()
	nPos := Ascan(aModulos,{|x| x[2] == 'SIGA'+cModCon })
	If nPos == 0
		ConOut(STR0006+StrZero(TERMINAL,2)+STR0003+cModCon+STR0004) //" Modulo "###" nao existe" //"Microterminal : "
		TerIsQuit(,.t.)
		Return
	EndIf
	nModulo := aModulos[nPos,1]
	cModulo :=cModCon
Else
	nModulo := 46
	cModulo := 'ACD'
EndIf
fErase("TER"+StrZero(COMUTADORA,2)+StrZero(TERMINAL,2)+".FIM")
fErase("TER"+StrZero(COMUTADORA,2)+StrZero(TERMINAL,2)+".AGU")
fErase("TER"+StrZero(COMUTADORA,2)+StrZero(TERMINAL,2)+".GRD")
PtInternal(1,STR0016+cEmpAnt+"/"+cFIlAnt+STR0005+AllTrim(cFun)) //" Equip:Microterminal -" //"Emp :"
If FindFunction(cFun)
	ConOut(STR0006+StrZero(TERMINAL,2)+STR0007+cModulo+STR0008+cModelo) //"Microterminal : "###" Modulo : "###" Modelo:"
	TerModelo(cModelo)
	TerCBuffer()
	TerCls()
	ErrorBlock({|e| TerErro(e,bBlockErr)})
	&(cFun)(uPar01,,,,)  //deixar assim mesmo, passando esses outros parametros como NIL
	ErrorBlock(bBlockErr)
Else
	ConOut(STR0009+cFun+STR0010+StrZero(TERMINAL,2)) //"Funcao nao encontrada ("###"), definida no microterminal "
EndIf
TerIsQuit(,.t.)
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerRet    ³ Autor ³ Eduardo Motta         ³ Data ³ 29/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Faz a leitura para o servidor do microterminal.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerRet(cStr)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cStr - String que informa a comutadora e o terminal.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SERVIDOR DO MICROTERMINAL                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TerRet(cStr)
Local nH,nPos,cString:=''
Local nComu     := Val(SubStr(cStr,1,2))
Local nTerminal := Val(SubStr(cStr,3,2))
Local cArquivo

If ! lVarGbl
	cArquivo:='TER'+StrZero(nComu,2)+StrZero(nTerminal,2)+".GRD"
	While (nH:=fopen(cArquivo, 1 )) == -1
		Sleep(10)
	End
	nPos := FSeek(nH,0,2)
	FSeek(nH,0,0)
	cString := Space(nPos)
	FRead(nH,@cString,Len(cString))
	Fclose(nH)
Else
	cArquivo:='TER'+StrZero(nComu,2)+StrZero(nTerminal,2)
	cString := GetGlbValue(cArquivo)
EndIf
Return cString



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerCria   ³ Autor ³ Eduardo Motta         ³ Data ³ 29/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Faz a gravacao da resposta do servidor do microterminal.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerRet(cStr)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cStr - String que informa a comutadora e o terminal e a    ³±±
±±³          ³        resposta.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SERVIDOR DO MICROTERMINAL                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TerCria(cStr)
Local nComu     := Val(SubStr(cStr,1,2))
Local nTerminal := Val(SubStr(cStr,3,2))
Local cArquivo
Local cStrTer := SubStr(cStr,5)
If ! lVarGbl
	cArquivo:='TER'+StrZero(nComu,2)+StrZero(nTerminal,2)+'.GRD'
	While (nH := FCreate(cArquivo)) == -1
		Sleep(10)
	End
	FWrite(nH,cStrTer,Len(cStrTer))
	FClose(nH)
Else
	cArquivo:='TER'+StrZero(nComu,2)+StrZero(nTerminal,2)
	PutGlbValue(cArquivo,cStrTer)
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerAbort  ³ Autor ³ Eduardo Motta         ³ Data ³ 29/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Faz a gravacao do arquivo para finalizar o microterminal.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerAbort(cFile)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFile- Nome do arquivo (.fim ou .agu)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SERVIDOR DO MICROTERMINAL                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TerAbort(cFile)
Local nH
Local cVar
If ! lVarGbl
	While (nH := FCreate(cFile))  == -1
		Sleep(10)
	End
	FWrite(nH,"fim",3)
	FClose(nH)
Else
	cVar:= Right(cFile,3)+Subs(cFile,4,4)
	PutGlbValue(cVar,"1")
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerInicio ³ Autor ³ Eduardo Motta         ³ Data ³ 29/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Apaga arquivos para iniciar o microterminal (GRD,FIM,AGU)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerInicio(cFile)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFile - Nome do arquivo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SERVIDOR DO MICROTERMINAL                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerInicio(cFile)
If ! lVarGbl
	fErase(cFile+".GRD")
	fErase(cFile+".AGU")
	fErase(cFile+".FIM")
Else
	PutGlbValue(cFile,"")
	PutGlbValue("AGU"+Subs(cFile,4,4),"")
	PutGlbValue("FIM"+Subs(cFile,4,4),"")
	PutGlbValue("MON"+Subs(cFile,4,4),"")
EndIf
Return

Function TerErro(e,bBlockErr)
TerCls()
TerSay(00,00,STR0011) //"Erro de aplicacao."
TerSay(01,00,STR0012) //"Verifique ERROR.LOG"
TerIsQuit(,.t.,.f.)
Return "DEFAULTERRORPROC"

Function TerModelo(cModelo)
If cModelo ==NIL
	Return __cModelo
EndIf
__cModelo := cModelo
Return __cModelo


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// abaixo estao funcoes exclusivas que somente são usadas pelo controle de debug do microterminal                  //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerEnvDeb ³ Autor ³ Eduardo Motta         ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao de comunicacao para o debug do microterminal.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerEnvDeb( cStrTer,lAguRet)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cStrTer - String a ser interpretada no microterminal       ³±±
±±³          ³ lAguRet - Verifica se envio tem retorno.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TERXFUN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TerEnvDeb(cStrTer,lAguRet)
Local cEstado := SubStr(cStrTer,1,2)
Local uRet
Local nC1,nC2,nL1,nL2,cMsg

lAguRet := If(lAguRet=Nil,.t.,lAguRet)

TerIsQuit("FIM")
PROCESSMESSAGE()

If cEstado == "03"       // TerCls
	cLin0   := Space(Len(cLin0))
	cLin1   := Space(Len(cLin1))
	nPosCol := 0
	nPosLin := 0
	AtuTelDeb()
	Return .T.
ElseIf cEstado == "04"   // TerSetPos
	nPosLin := Val(SubStr(cStrTer,3,2))
	nPosCol := Val(SubStr(cStrTer,5,2))
	Return .T.
ElseIf cEstado == "05"   // TerDevout
	cMsg := SubStr(cStrTer,3)
	If nPosLin == 0
		cLin0 := Stuff(cLin0,nPosCol+1,Len(cMsg),cMsg)
		cLin0 := PadR(cLin0,40)
	ElseIf nPosLin == 1
		cLin1 := Stuff(cLin1,nPosCol+1,Len(cMsg),cMsg)
		cLin1 := PadR(cLin1,40)
	EndIf
	nPosCol+=Len(cMsg)
	AtuTelDeb()
	Return .T.
ElseIf cEstado == "06"   // TerGet (preparacao do get)
	TerDebGet(SubStr(cStrTer,3))
ElseIf cEstado == "07"   // TerGet (retorna o conteudo)
	Return TerDebGtr(.T.)
ElseIf cEstado == "08"   // TerInkey
	uRet      	:= SubStr(cBufSimTer,1,1)
	cBufSimTer 	:= SubStr(cBufSimTer,2)
	If Len(uRet) == 0
		uRet := Chr(0)
	EndIf
	Return uRet
ElseIf cEstado == "09"   // TerPBegin
	lImpPar:=subs(cStrTer,5,1)=="P"
	lImpSer:=subs(cStrTer,5,1)=="S"
	If lImpPar
		cMemoPar:=""
		oMemoPar:Refresh()
	EndIf
	If lImpSer
		cMemoSer:=""
		oMemoSer:Refresh()
	EndIf

ElseIf cEstado == "10"   // TerPrint
	If lImpPar
		cMemoPar+=subs(cStrTer,3)
		oMemoPar:Refresh()
	EndIf
	If lImpSer
		cMemoSer+=subs(cStrTer,3)
		oMemoSer:Refresh()
	EndIf
ElseIf cEstado == "11"   // TerPEnd
	If lImpPar
		cMemoPar+= STR0031+chr(13)+chr(10) //"------------- Término da impressão -------------------"
		oMemoPar:Refresh()
	EndIf
	If lImpSer
		cMemoSer+= STR0031+chr(13)+chr(10) //"------------- Término da impressão -------------------"
		oMemoSer:Refresh()
	EndIf
ElseIf cEstado == "12"   // TerIsQuit  (FINALIZA O MICROTERMINAL)
	oDlgDebTer:End()
	__cInternet:=NIL
	Final(STR0013) //"Simulador de Microterminal finalizado."
ElseIf cEstado == "13"   // TerBeep
ElseIf cEstado == "14"   // TerSave
	nL1 := Val(SubStr(cStrTer,3,1))
	nC1 := Val(SubStr(cStrTer,4,2))
	nL2 := Val(SubStr(cStrTer,6,1))
	nC2 := Val(SubStr(cStrTer,7,2))
	uRet := ""
	If nL1 = 0
		uRet+=SubStr(cLin0,nC1,nC2-nC1+1)
	EndIf
	If nL2 = 1
		uRet+=SubStr(cLin1,nC1,nC2-nC1+1)
	EndIf
	Return uRet
ElseIf cEstado == "15"    // Carrega Get
	TerDebVGet(SubStr(cStrTer,3))
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerSetDebug³ Autor ³ Eduardo Motta        ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Funcao que seta variavel de DEBUG do microterminal         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerSetDebug(lModDebug)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lModDebug - .t. seta para modo debug / .f. modo normal     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TerSetDebug(lModDebug)
LDEBUG := If(lModDebug==NIL,LDEBUG,lModDebug)
Return LDEBUG



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerDebug   ³ Autor ³ Eduardo Motta        ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Simula a tela do microterminal debugar o fonte pelo IDE    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TerDebug(cNomeProg)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFuncao - Funcao a executar quando ativar                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerSimula()
Return TerDebug()

Function TerDebug()
Local oFont
Local oFont2
Local lAtvEnable := .T.
Local oEnter
Local cCar,nI
Local bBlock
Local oUp,oDown
Local cEmp := "99"
Local cFil := "01"
Local cPar := PadR("",20)
Local cNomeProg := PadR("",10)
Local nTerm := 0
Local nComu := 0
Local cModCon := Space(03)
Local cModelo := "MT44"
Local nH
Local cLinha := Space(41)

Local aTitles
Local aPages
Local oFolder


If File("Terdebug.Ini")
	nH := FOpen("Terdebug.Ini")
	FRead(nH,@cLinha,Len(cLinha))
	FClose(nH)
	cEmp      := PadR(SubStr(cLinha,01,2),2)
	cFil      := PadR(SubStr(cLinha,03,2),2)
	cPar      := PadR(SubStr(cLinha,05,20),20)
	cNomeProg := PadR(SubStr(cLinha,25,10),10)
	nComu     := Val(SubStr(cLinha,35,2))
	nTerm     := Val(SubStr(cLinha,37,2))
	cModCon   := PadR(SubStr(cLinha,39,3),3)
	cModelo   := Padr(Subs(cLinha,42,4),4)
	If Empty(cModelo)
		cModelo := "MT44"
	EndIf
EndIf

oFont := TFont():New( "Courier New", 16, 40, .F.,.T.,,,,,,,,,,, )
oFont2 := TFont():New( "Courier New", 10, 26, .F.,.T.,,,,,,,,,,, )
DEFINE MSDIALOG oDlgDebTer FROM 0,0 TO 385,700  Pixel TITLE OemToAnsi(STR0017) //"Simulador Microterminal"
oDlgDebTer:lEscClose := .F.

@ 45,0 GET oMemoDeb  VAR cMemoDeb MEMO SIZE 350,50 OF oDlgDebTer PIXEL FONT oFont
oMemoDeb:lReadOnly := .T.


@ 01,005 Say STR0018 PIXEL Of oDlgDebTer //"Empresa"
@ 01,030 Say STR0019 PIXEL Of oDlgDebTer //"Filial"
@ 01,050 Say STR0020 PIXEL Of oDlgDebTer //"Comutadora"
@ 01,090 Say STR0021 PIXEL Of oDlgDebTer //"Microterminal"
@ 01,130 Say STR0022 PIXEL Of oDlgDebTer //"Programa"
@ 01,195 Say STR0023 PIXEL Of oDlgDebTer //"Parametros"
@ 01,280 Say STR0024 PIXEL Of oDlgDebTer //"Modulo"
@ 01,320 Say STR0025 PIXEL Of oDlgDebTer //"Modelo"


@ 10,005 MsGet cEmp			Picture "@!" PIXEL Of oDlgDebTer When lAtvEnable
@ 10,027 MsGet cFil 		Picture "@!" PIXEL Of oDlgDebTer When lAtvEnable
@ 10,060 MsGet nComu		Picture "99" PIXEL Of oDlgDebTer When lAtvEnable
@ 10,100 MsGet nTerm		Picture "99" PIXEL Of oDlgDebTer When lAtvEnable
@ 10,130 MsGet cNomeProg	Picture "@!" PIXEL Of oDlgDebTer When lAtvEnable
@ 10,195 MsGet cPar			Picture "@!" PIXEL Of oDlgDebTer When lAtvEnable SIZE 80,10
@ 10,280 MsGet cModCon		Picture "@!" PIXEL Of oDlgDebTer When lAtvEnable
@ 10,320 MsGet cModelo		Picture "@!" PIXEL Of oDlgDebTer When lAtvEnable valid cModelo =="MT44" .OR. cModelo=="MT16"

TButton():New( 025, 005, STR0014, oDlgDebTer, {|| AtivaDeb(@lAtvEnable,cNomeProg,oEnter,cEmp,cFil,cPar,nComu,nTerm,cModCon,cModelo)}, 38, 11,,, .F., .T., .F.,, .F., {|| lAtvEnable},, .F. ) //"Ativar"
TButton():New( 025, 055, STR0015, oDlgDebTer, {|| (TerEnv("12"),oDlgDebTer:End())}, 38, 11,,, .F., .T., .F.,, .F., {|| !lAtvEnable},, .F. ) //"Desativar"
TButton():New( 025, 105, STR0026, oDlgDebTer, {|| (TerTec(Space(01),oEnter))}, 40, 10,,, .F., .T., .F.,, .F.,,, .F. )   //"Espaco"
TButton():New( 025, 155, "Enter", oDlgDebTer, {|| (TerTec(Chr(13),oEnter))}, 40, 10,,, .F., .T., .F.,, .F.,,, .F. )   //"Espaco"


aTitles := {STR0027,STR0028} //"Saida Paralela"###"Saida Serial"
aPages  := {STR0027,STR0028} //"Saida Paralela"###"Saida Serial"
oFolder := TFolder():New(7.5,0,aTitles,aPages,oDlgDebTer,,,,.F.,.F.,350,95)

@ 0,0 GET oMemoPar  VAR cMemoPar MEMO SIZE 348,81 OF oFolder:aDialogs[1] PIXEL FONT oFont2
oMemoPar:lReadOnly := .T.

@ 0,0 GET oMemoSer  VAR cMemoSer MEMO SIZE 348,81 OF oFolder:aDialogs[2] PIXEL FONT oFont2
oMemoSer:lReadOnly := .T.



/// OS BOTOES ABAIXO NAO APARECEM NO DIALOGO
oUp    := TButton():New( 065, 1205, "UP", oDlgDebTer, , 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
oUp:bGotFocus := {|| oEnter:SetFocus()}

oEnter := TButton():New( 065, 1205, "ENTER", oDlgDebTer, {|| TerTec(Chr(13),oEnter)}, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

oDown  := TButton():New( 065, 1205, "DOWN", oDlgDebTer, , 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
oDown:bGotFocus := {|| oEnter:SetFocus()}

TButton():New( 095, 1205, "&"+Chr(27)+"ESC", oDlgDebTer, {|| TerTec(Chr(27),oEnter)}, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
TButton():New( 125, 1205, "&"+Chr(08)+"BACKSPACE", oDlgDebTer, {|| TerTec(Chr(08),oEnter)}, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

For nI := 0 to 9
	cCar := Str(nI,1)
	bBlock := &("{||TerTec('"+cCar+"',oEnter)}")
	TButton():New( 135+(nI*10), 1205, "&"+cCar, oDlgDebTer, bBlock, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
Next
For nI := 65 to 90
	cCar := Chr(nI)
	bBlock := &("{||TerTec('"+cCar+"',oEnter)}")
	TButton():New( 135+(nI*100), 1205, "&"+cCar, oDlgDebTer, bBlock, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
Next
For nI := 97 to 122
	cCar := Chr(nI)
	bBlock := &("{||TerTec('"+cCar+"',oEnter)}")
	TButton():New( 135+(nI*100), 1205, "&"+cCar, oDlgDebTer, bBlock, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )
Next

cCar := Chr(23)
bBlock := &("{||TerTec('"+cCar+"',oEnter)}")
TButton():New( 135+(nI*100), 1205, "&"+cCar, oDlgDebTer, bBlock, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

cCar := "."
bBlock := &("{||TerTec('"+cCar+"',oEnter)}")
TButton():New( 135+(nI*100), 1205, "&"+cCar, oDlgDebTer, bBlock, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

cCar := ","
bBlock := &("{||TerTec('"+cCar+"',oEnter)}")
TButton():New( 135+(nI*100), 1205, "&"+cCar, oDlgDebTer, bBlock, 38, 11,,, .F., .T., .F.,, .F.,,, .F. )

ACTIVATE MSDIALOG oDlgDebTer CENTERED

Return .t.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³AtivaDeb   ³ Autor ³ Eduardo Motta        ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Ativa a aplicacao do microterminal                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AtivaDeb(lAtvEnable,cNomeProg,oEnter,cEmp,cFil,cPar,nComu,  ³±±
±±³          ³         nTerm,cModCon)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TERDEBUG                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function AtivaDeb(lAtvEnable,cNomeProg,oEnter,cEmp,cFil,cPar,nComu,nTerm,cModCon,cModelo)
Local nH
Local cLinha
DEFAULT cModCon := "ACD"
If Empty(cModCon)
	cModCon := "ACD"
EndIf
cLinha    := cEmp+cFil+cPar+cNomeProg+StrZero(nComu,2)+StrZero(nTerm,2)+cModCon+cModelo
nH := FCreate("Terdebug.Ini")
FWrite(nH,@cLinha,Len(cLinha))
FClose(nH)
FErase("TER"+StrZero(nComu,2)+StrZero(nTerm,2)+".FIM")

RpcSetEnv( cEmp, cFil,,,cModCon, )    // cria o enviroment com a abertura das tabelas
TerSetDebug(.T.)
TerProtocolo("GRADUAL")
TerSet(nComu,nTerm)
TerModelo(cModelo)
oMemoDeb:nClrPane:=CLR_LIGHTGRAY
oMemoDeb:nClrText:=CLR_BLACK
lAtvEnable := .F.
oEnter:SetFocus()
cBufSimTer:=""
If FindFunction(cNomeProg)
	ConOut(STR0006+StrZero(TERMINAL,2)+STR0007+cModulo+STR0029) //"Microterminal : "###" Modulo : "###"     [EM MODO DEBUG/SIMULACAO]"
	&(cNomeProg)(cPar,,,,,)
	ConOut(STR0001+StrZero(TERMINAL,2)+STR0002) //"Microterminal "###" finalizado."
Else
	MsgStop(STR0030+cNomeProg+")") //"Nome da funcao nao encontrada. ("
EndIf
lAtvEnable:=.T.
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³AtuTelDeb  ³ Autor ³ Eduardo Motta        ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Atualiza a tela do TERDEBUG                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AtuTelDeb()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function AtuTelDeb()
cMemoDeb := cLin0+Chr(13)+Chr(10)
cMemoDeb += cLin1
oMemoDeb:Refresh()
oDlgDebTer:Refresh()
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerTec     ³ Autor ³ Eduardo Motta        ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Envia as teclas digitadas para o processamento             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TerTec(cGet,oGet)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function TerTec(cGet,oGet)
If	cGet == Chr(27)
	cGet := Chr(127)
EndIf
cBufSimTer+=cGet
oGet:SetFocus()
Return .f.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerDebGet  ³ Autor ³ Eduardo Motta        ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Prepara a tela e as variaveis para efetuar o GET           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TerDebGet(cPicture)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TerDebGet( cPicture)
If	WAITT==0
	KPIC	:=cPicture  // guarda o formato
	PPIC	:=1         // posiciona o ponteiro na 1a. posicao
	Return .T.
EndIf
Return .F.

Static Function TerDebVGet( cValor)
If	WAITT==0
	KBD	:=cValor
	WAITT	:=1         // liga o flag de espera de picture
	Return .T.
EndIf
Return .F.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³TerDebGtr  ³ Autor ³ Eduardo Motta        ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Efetua o Get retornando o conteudo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TerDebGTr(lNormal)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TerDebGtr(lNormal)
Local gTecla
Local gPict   := Space(01)
Local nLinG   := nPosLin
Local nColG   := nPosCol
Local nDec
Local nPosPonto
Local nTam

lNormal := IIf(lNormal==Nil,.T.,lNormal)

While WAITT == 1
	gtecla:=TerInkey(0)
	If	gtecla=="."
		If substr( KPIC, PPIC, 1 ) =="9" .and. At(".",KPIC) == 0
			Loop
		EndIf
	EndIf
	If	gtecla==Chr(127)   // ESC (a tecla DEL no microterminal e' tratada como ESC)
		KBD   := gTecla
		WAITT := 0
		Loop
	ElseIf gtecla==Chr(08)   // backspace
		If PPIC > 1
			gpict := SubStr(KPIC,PPIC-1,1)
			If gpict $ "/.-"
				nPosCol--
				PPIC--
			EndIf
			PPIC--
			KBD := Stuff(KBD,PPIC,1," ")
			If gpict == "*"
				TerSay(nLinG,nColG,Replicate("*",len(KBD)))
			Else
				TerSay(nLinG,nColG,If(lNormal,KBD,Replicate("*",len(KBD))))
			EndIf
		EndIf
	ElseIf gtecla==Chr(13) .or. gtecla==Chr(10)
		WAITT:=0
		Loop
	Else
		gpict=substr( KPIC, PPIC, 1 )
		nTam := Len(KPIC)
		If "@" $ KPIC
			nTam--
		EndIf
		nPosPonto := At(".",KPIC)
		nDec :=0
		If nPosPonto >0
			nDec:= nTam-nPosPonto
		EndIf
		If gpict=="X"
			KBD := Stuff(KBD,PPIC,1,gTecla)
			PPIC = PPIC + 1
			TerSay(nLinG,nColG,If(lNormal,KBD,Replicate("*",len(KBD))))
		ElseIf gpict=="*"
			KBD := Stuff(KBD,PPIC,1,gTecla)
			PPIC = PPIC + 1
			TerSay(nLinG,nColG,Replicate("*",len(KBD)))
		ElseIf gpict=="9"
			If gtecla>="0" .and. gtecla<="9" .or. gtecla=="."
				If gtecla=="." .and. nDec > 0
					KBD:= Padl(Alltrim(Left(KBD,nPosPonto-1)),nPosPonto-1)+Subs(KBD,nPosPonto)
					TerSay(nLinG,nColG,If(lNormal,KBD,Replicate("*",len(KBD))))
					nPosCol := nPosCol+(nPosPonto-PPIC)+1
					PPIC+=nPosPonto-PPIC+1
				Else
					If PPIC == 1
						If nDec > 0
							KBD := Stuff(Space(nTam),nPosPonto,1,".")
						Else
							KBD := Space(nTam)
						EndIf
						nCol := nPosCol
						nLin := nPosLin
						TerSay(nLinG,nColG,If(lNormal,KBD,Replicate("*",len(KBD))))
						nPosCol := nCol
						KBD := gTecla+Subs(KBD,2)
					Else
						KBD := Stuff(KBD,PPIC,1,gtecla)
					EndIf
					PPIC++
					TerSay(nLinG,nColG,If(lNormal,KBD,Replicate("*",len(KBD))))
				EndIf
			EndIf
		ElseIf gpict=="A"
			If gtecla>="A" .and. gtecla<="Z" .or. gtecla==" "
				KBD := Stuff(KBD,PPIC,1,gTecla)
				PPIC = PPIC + 1
				TerSay(nLinG,nColG,If(lNormal,KBD,Replicate("*",len(KBD))))
			EndIf
		EndIf
		gpict=substr( KPIC, PPIC, 1 )
		If gpict=="@"
			WAITT:=1
			Loop
		ElseIf gpict=="/"
			KBD := Stuff(KBD,PPIC,1,"/")
			TerSay(nLing,nColG+PPIC-1,"/")
			PPIC = PPIC + 1
			//Gecho("/")
		ElseIf gpict=="."
			KBD := Stuff(KBD,PPIC,1,".")
			PPIC = PPIC + 1
			TerSay(nLinG,nColG,If(lNormal,KBD,Replicate("*",len(KBD))))
		Else
			If Len(gpict) == 0
				WAITT := 0
			EndIf
			Loop
		EndIf
	EndIf
EndDo
Return KBD

Function TeraChoice(nTop,nLeft,nBottom,nRight,aMenu,cFunct,nIniVetor,nIniW)
Local nSelectDraw := 1
Local nSelectOld  := nSelectDraw
Local nPIniaMenu  := 1
Local aTela       :={}
Local nLenWindow  := 0
Local nLenString  := 0
Local nKey        := 0
Local nPosaMenu   := 1
Local nModo       := 0
Local nRetUser    := 2
Local nPosMAnt    := 0
Local nStart
Local nMaxCol := If(TerModelo()=="MT16",19,39)
Local cRetKey
Private cBufferaCh := ''
//Setando parametros default
Default nTop   :=0
Default nLeft  :=0
Default nBottom:=1
Default nRight := nMaxCol
Default nIniW  := 1
nLenWindow := nBottom-nTop+1
nLenString := nRight-nLeft

nIniVetor  := If(nIniVetor#NIL,nIniVetor-nIniW+1,1)
nIniVetor  := If(nIniVetor <=0,1,nIniVetor)
nPosAMenu  := nIniVetor

If	nIniVetor > nLenWindow
	nPIniaMenu := nIniVetor-nSelectDraw+1
	If nPIniaMenu > (len(aMenu)-nLenWindow)
		nPIniaMenu := (len(aMenu)-nLenWindow)+1
		nSelectDraw := nLenWindow-(len(aMenu)-nIniVetor)
		nSelectOld  := nSelectDraw
	EndIf
ElseIf nIniVetor-nLenWindow <=  0
	nSelectDraw := nIniVetor
	nSelectOld  := nSelectDraw
	nPIniaMenu := 1
EndIf

nPosMAnt := 0
nStart := 1

While .t.
	nKey := 0
	nModo:= 0
	nRetUser := 2
	If nPosAMenu # nPosMAnt
		aTela:=Aclone(TerLoadaMenu(aMenu,nLenWindow,nLenString,nPIniaMenu))
		TerSayachoice(nTop,nLeft,aTela,nSelectDraw,nSelectOld,nLenString)
		nStart := 1
	EndIf
	//TerSetPos(nSelectDraw,nLeft+nLenString-1)
	nPosMAnt := nPosAMenu
	cRetkey:= TerInkey(0)
	nSelectOld := nSelectDraw
	If TerESC()
		nModo :=3
		nRetUser := 0
	ElseIf Asc(cRetkey) == 13 // enter
		nModo := 3
		nRetUser := 1
	ElseIf cRetkey =="8" .or. Asc(cRetKey) == 5// Up
		If nSelectDraw = 1
			If (nPIniaMenu) > 1
				nPIniaMenu--
				nPosaMenu--
			Else
				nModo := 1
			EndIf
		Else
			nSelectDraw--
			nPosaMenu--
		EndIf
	ElseIf cRetKey=="2" .or. Asc(cRetKey) == 24// down
		If nSelectDraw = nLenWindow
			If (nPIniaMenu+nLenWindow) <= Len(aMenu)
				nPIniaMenu++
				nPosaMenu++
			Else
				nModo := 2
			EndIf
		Else
			If (nPosaMenu) < len(aMenu)
				nSelectDraw++
				nPosaMenu++
			EndIf
		EndIf
	EndIf
	If ValType(cFunct)=="C"
		nRetUser:= &cFunct.(nModo,nPosaMenu,nSelectDraw-1)
	EndIf
	If nRetUser == 0  // Esc
		nPosaMenu := 0
		Exit
	ElseIf nRetUser == 1 // Enter
		Exit
	EndIf
End
Return nPosaMenu
// funcao auxiliar do TeraChoice
Static Function TerLoadaMenu(aMenu,nLenWindow,nLenString,nPosIni)
Local aVetor:={}
Local cMenu
Local n
For n:= 1 to nLenWindow
	If nPosIni > len(aMenu)
		aadd(aVetor,Padr('',nLenString))
	Else
		cMenu := aMenu[nPosIni++]
		aadd(aVetor,cMenu)
	EndIf
Next
Return aVetor
// funcao auxiliar do TeraChoice
Static Function TerSayAchoice(nTop,nLeft,aTela,nSelect,nSelectOld,nLen,nStart)
Local nX :=0
Local nUl:=0,nUC:=0
Local cSay
If nSelect ==nSelectOld
	For nX:= 1 to Len(aTela)
		cSay := Padr(If(Len(aTela[nX]) > nLen,Subs(aTela[nX],1,nLen),aTela[nX]),nLen)
		If nSelect == nX
			If TerProtocolo()=="VT100"
				VtReverso(.t.)
			EndIf
			cSay := Left(cSay,len(cSay)-1)+"<"
			TerSay(nTop+nX-1,nLeft,cSay)
			If TerProtocolo()=="VT100"
				VtReverso(.f.)
			EndIf
			nUl:=nTop+nX-1
			nUc:=nLeft
		Else
			TerSay(nTop+nX-1,nLeft,cSay)
		EndIf
	Next
//	TerSay(nUl,nUc)
Else
	If TerProtocolo()=="VT100"
		VtReverso(.f.)
	EndIf
	cSay := Padr(If(Len(aTela[nSelectOld]) > nLen,Subs(aTela[nSelectOld],1,nLen),aTela[nSelectOld]),nLen)
	TerSay(nTop+nSelectOld-1,nLeft,cSay)
	If TerProtocolo()=="VT100"
		VtReverso(.t.)
	EndIf
	cSay := Padr(If(Len(aTela[nSelect])>nLen,Subs(aTela[nSelect],1,nLen),aTela[nSelect]),nLen)
	cSay := Left(cSay,len(cSay)-1)+"<"
	TerSay(nTop+nSelect-1,nLeft,cSay)
	If TerProtocolo()=="VT100"
		VtReverso(.f.)
	EndIf
//	TerSay(nTop+nSelect-1,nLeft)
EndIf
Return

Function TerLastKey()
Local nRet
If TerProtocolo()=="GRADUAL"
	nRet := Asc(__cLastKey)
	If nRet == 127
		LESC := .t.
		nRet := 27
	EndIf
ElseIf TerProtocolo()=="VT100"
	nRet := VTLastKey()
EndIf
Return nRet


Function TeraBrowse(nTop,nLeft,nBottom,nRight,aCab,aItens,aSize,cFunct,nIniVetor)
Local nSelectDraw  := 1
Local nSelectOld   := nSelectDraw
Local nPIniaMenu   := 1
Local aTela        :={}
Local nLenWindow   := 0
Local nLenString   := 0
Local nKey         := 0
Local nPosaMenu    := 1
Local nModo        := 0
Local nRetUser     := 2
Local nPosMAnt     := 0
Local nCol:= 1
Local nQtdCol:= 1
Local lMoveCol:=.f.
Local nMaxCol := If(TerModelo()=="MT16",19,39)
Local cRetkey
//nIniVetor := 3

//Setando parametros default
nTop   := If(nTop#NIL,nTop,0)
nLeft  := If(nLeft#NIL,nLeft,0)
nBottom:= If(nBottom#NIL,nBottom,1)
nRight := If(nRight#NIL,nRight,nMaxCol)
nIniVetor:= If(nIniVetor#NIl,nIniVetor+1,3)
nLenWindow := nBottom-nTop+1
nLenString := nRight-nLeft
nPosAMenu  := nIniVetor
If  nIniVetor > nLenWindow
	nSelectDraw := nLenWindow
	nSelectOld  := nSelectDraw
	nPIniaMenu  := nIniVetor-nLenWindow+1
ElseIf nIniVetor-nLenWindow <=  0
	nSelectDraw := nIniVetor
	nSelectOld  := nSelectDraw
	nPIniaMenu := 1
EndIf

nPosMAnt := 0
While .t.
	nKey := 0
	nModo:= 0
	nRetUser := 2
	If nPosAMenu # nPosMAnt .or. lMoveCol .or. __laBrwRefresh
		aTela:=Aclone(TerLoadaBrowse(aCab,aItens,aSize,nLenWindow,nLenString,nPIniaMenu,nCol,@nQtdCol))
		TerSayaBrowse(nTop,nLeft,aTela,nSelectDraw,nSelectOld,nLenString)
		lMoveCol:= .f.
		__laBrwRefresh:= .f.
	EndIf
	nPosMAnt := nPosAMenu
	//VtPos(VTRow(),VTMaxCol())
	cRetkey:= TerInkey(0)
	nSelectOld := nSelectDraw
	If Asc(cRetkey) == 27 .or. TerEsc()
		nModo :=3
		nRetUser := 0
	ElseIf Asc(cRetkey) == 13 // enter
		nModo := 3
		nRetUser := 1
	ElseIf Asc(cRetkey) == 5 .or. cRetkey $ '8MmAa'// Up
		If nSelectDraw == 2
			If (nPIniaMenu) > 1
				nPIniaMenu--
				nPosaMenu--
			Else
				nModo := 1
			EndIf
		Else
			nSelectDraw--
			nPosaMenu--
		EndIf
	ElseIf Asc(cRetkey) == 24 .or. cRetkey $ '2NnBb' // down
		If nSelectDraw == nLenWindow
			If (nPIniaMenu+nLenWindow) <= (Len(aItens)+1)
				nPIniaMenu++
				nPosaMenu++
			Else
				nModo := 2
			EndIf
		Else
			If (nPosaMenu) < (len(aItens)+1)
				nSelectDraw++
				nPosaMenu++
			EndIf
		EndIf
	ElseIf Asc(cRetkey) ==  4 .or. cRetkey $ '6LlFf' //Direita
		If ! empty(aItens) .and. nCol < Len(aItens[1])
			lMoveCol:= .t.
			nCol++
		EndIf
	ElseIf Asc(cRetkey) == 19 .or. cRetkey $ '4KkEe' //esquerda
		If nCol >1
			lMoveCol:= .t.
			nCol--
		EndIf
	EndIf
	If ValType(cFunct)=="C"
		nRetUser:= &cFunct.(nModo,nPosaMenu-1,nSelectDraw-1)
	EndIf
	If nRetUser == 0  // Esc
		nPosaMenu := 1
		Exit
	ElseIf nRetUser == 1 // Enter
		Exit
	EndIf
End
Return nPosaMenu-1
// funcao auxiliar do VTABrowse

Static Function TerLoadaBrowse(aCab,aMenu,aSize,nLenWindow,nLenString,nPosIni,nCol,nQtdCol)
Local aVetor:={}
Local sLinha:=''
Local nX,nLenLinha:=0
Local n
Local uConteudo
//descubrir qtde de colunhas que cab
nLenLinha:=0
nQtdCol:= 0
For nX := nCol to Len(aCab)
	nQtdCol++
	If nLenLinha+aSize[nx]+1 > nLenString
		Exit
	EndIf
	nLenLinha+=aSize[nx]+1
Next
sLinha:=''
For nX := 1 to nQtdCol
	sLinha += Padr(aCab[nCol+nX-1],aSize[nCol+nX-1])
	If nX < nQtdCol
		sLinha+='|'
	EndIf
Next
aadd(aVetor,sLinha)
For n:= 1 to nLenWindow-1
	If nPosIni > len(aMenu)
		aadd(aVetor,Padr('',nLenString))
	Else
		sLinha := ''
		For nX := 1 to nQtdCol
			uConteudo := aMenu[nPosIni,nCol+nX-1]

			If Valtype(uConteudo) =='C'
				uConteudo:= Padr(uConteudo,aSize[nCol+nX-1])
			ElseIf Valtype(uConteudo) =='N'
				uConteudo := Str(uConteudo)
				uConteudo := Padl(AllTrim(uConteudo),aSize[nCol+nX-1])
			ElseIf Valtype(uConteudo) =='D'
				uConteudo := Padc(Dtoc(uConteudo),aSize[nCol+nX-1])
			ElseIf Valtype(uConteudo) =='L'
				uConteudo := if(uConteudo,'T','F')
			ElseIf Valtype(uConteudo) =='M'
				uConteudo := 'MEMO'
			EndIf
			sLinha +=uConteudo
			If nX < nQtdCol
				sLinha+='|'
			EndIf
		Next
		nPosIni++
		aadd(aVetor,Padr(sLinha,nLenString))
	EndIf
Next
Return aVetor
// funcao auxiliar do TeraBrowser
Static Function TerSayaBrowse(nTop,nLeft,aTela,nSelect,nSelectOld,nLen)
Local nX :=0
Local nUl:=0,nUC:=0
Local cSay
If nSelect ==nSelectOld
	For nX:= 1 to Len(aTela)
		If nSelect == nX
			If TerProtocolo()=="VT100"
				VtReverso(.t.)
			EndIf
			cSay := Padr(aTela[nX],nLen)
			cSay := Left(cSay,len(cSay)-1)+"<"
			TerSAY(nTop+nX-1,nLeft,cSay)
			If TerProtocolo()=="VT100"
				VtReverso(.f.)
			EndIf
			nUl:=nTop+nX-1
			nUc:=nLeft
		Else
			TerSAY(nTop+nX-1,nLeft,Padr(aTela[nX],nLen))
		EndIf
	Next
	//VTPOS(nUl,nUc)
Else
	If TerProtocolo()=="VT100"
		VtReverso(.f.)
	EndIf
	TerSAY(nTop+nSelectOld-1,nLeft,aTela[nSelectOld])
	If TerProtocolo()=="VT100"
		VtReverso(.t.)
	EndIf
	cSay := Padr(aTela[nSelect],nLen)
	If VtMaxRow()==1
		cSay := Left(cSay,len(cSay)-1)+"<"
	EndIf
	TerSay(nTop+nSelect-1,nLeft,cSay)
	If TerProtocolo()=="VT100"
		VtReverso(.f.)
	EndIf
	//VTPOS(nTop+nSelect-1,nLeft)
EndIf
Return

Function TeraBrwRefresh()
__laBrwRefresh:= .t.
Return

///----Com DBbrose---------------------------
Function TerDbBrowse(nTop,nLeft,nBottom,nRight,cAlias,aCab,aFields,aSizeFields,cFunct,cTop,cBottom)
Local nSelectDraw  := 2
Local nSelectOld   := nSelectDraw
Local aTela        :={}
Local nLenWindow   := 0
Local nLenString   := 0
Local nKey         := 0
Local nModo        := 0
Local nRetUser     := 2
Local nPosMAnt     := 0
Local nCol:= 1
Local nQtdCol:= 1
Local lMoveCol:=.f.
Local aRecno:={}
Local cConteudo,cTop1,cBottom1
Local nMaxCol := If(TerModelo()=="MT16",19,39)
Local cRetkey
dbSelectArea(cAlias)

//Setando parametros default
nTop   := If(nTop#NIL,nTop,0)
nLeft  := If(nLeft#NIL,nLeft,0)
nBottom:= If(nBottom#NIL,nBottom,1)
nRight := If(nRight#NIL,nRight,nMaxCol)

nLenWindow := nBottom-nTop+1
nLenString := nRight-nLeft

nPosMAnt := 0
lMoveCol:= .t.
While .t.
	nKey := 0
	nModo:= 0
	nRetUser := 2
	If lMoveCol .or. __lDbBrwRefresh
		aTela:=Aclone(TerLoadDbBrowse(aCab,aFields,aSizeFields,nLenWindow,nLenString,nCol,@nQtdCol,aRecno,cBottom))
		TerSayaBrowse(nTop,nLeft,aTela,nSelectDraw,nSelectOld,nLenString)
		lMoveCol:= .f.
		__lDbBrwRefresh := .f.
	EndIf
	//VtPos(VTRow(),VTMaxCol())
	cRetkey:= TerInkey(0)
//	nKey := VTInkey(0)
	nSelectOld := nSelectDraw
	If Asc(cRetkey) == 27 .or. TerEsc()
		nModo :=3
		nRetUser := 0
	ElseIf Asc(cRetkey) == 13 // enter
		nModo := 3
		nRetUser := 1
	ElseIf Asc(cRetkey) == 5 .or. cRetkey $ '8MmAa'// Up
		If nSelectDraw = 2
			Dbskip(-1)
			cConteudo := &(Indexkey())
			If Valtype(cTop)=='C'
				cTop1 := &cTop
			EndIf
			If bof()  .or. (Valtype(cTop1)=='C' .and. cTop1 > Left(cConteudo,len(cTop1)))
				If ! Bof()
					Dbskip()
				EndIf
				lMoveCol:= .f.
				nModo := 1
			Else
				lMoveCol:= .t.
			EndIf
		Else
			lMoveCol:= .t.
			nSelectDraw--
		EndIf
	ElseIf  Asc(cRetKey) == 24 .or. cRetKey $ '2NnBb' // down
		If nSelectDraw = nLenWindow
			nRecAnt:= recno()
			dbgoto(aRecno[nSelectDraw-1])
			dbskip()
			cConteudo := &(Indexkey())
			If Valtype(cBottom)=='C'
				cBottom1 := &cBottom
			EndIf
			If EOF() .or. (Valtype(cBottom1)=='C' .and.  cBottom1 < Left(cConteudo,len(cBottom1)))
				dbgoto(nRecAnt)
				lMoveCol:= .f.
				nModo := 2
			Else
				lMoveCol:= .t.
				dbgoto(nRecAnt)
				dbskip()
			EndIf
		Else
			If nSelectDraw <len(aTela)
				lMoveCol:= .t.
				nSelectDraw++
			Else
				nModo := 2
			EndIf
		EndIf
	ElseIf Asc(cRetKey) ==  4 .or. cRetKey $ '6LlFf' //Direita
		If nCol < len(aFields)
			lMoveCol:= .t.
			nCol++
		EndIf
	ElseIf Asc(cRetKey) == 19 .or. cRetKey $ '4KkEe' //esquerda
		If nCol >1
			lMoveCol:= .t.
			nCol--
		EndIf
	EndIf
	If ValType(cFunct)=="C"
		nRetUser:= &cFunct.(nModo,aRecno[nSelectDraw-1],nSelectDraw-1)
	EndIf
	If nRetUser == 0  // Esc
		Exit
	ElseIf nRetUser == 1 // Enter
		dbgoto(aRecno[nSelectDraw-1])
		Exit
	EndIf
End
Return recno()
// funcao auxiliar do TerDbBrowse
Static Function TerLoadDbBrowse(aCab,aFields,aSizeFields,nLenWindow,nLenString,nCol,nQtdCol,aRecno,cBottom)
Local aVetor:={}
Local sLinha:=''
Local nX,nLenLinha:=0
Local n
Local nRecno:= Recno()
Local uConteudo
Local npos
Local aFieldNames := ARRAY(FCOUNT())
Local aTypes := ARRAY(FCOUNT())
Local aSizes := ARRAY(FCOUNT())
Local aDecimals := ARRAY(FCOUNT())
Local cConteudo, cBottom1
Local nTamanho


AFIELDS(aFieldNames, aTypes, aSizes, aDecimals)

//descubrir qtde de colunhas que cab
nLenLinha:=0
nQtdCol:= 0

For nX := nCol to Len(aFields)
	nQtdCol++
	If Valtype(aFields[nX])=='B'
		nTamanho := len(Eval(aFields[nX]))
		If nTamanho < len(aCab)
			nTamanho := len(aCab)
		EndIf
	Else
		nTamanho := aSizeFields[nX]
	EndIf
	If nLenLinha+nTamanho+1 > nLenString
		Exit
	EndIf
	nLenLinha+=nTamanho+1
Next
sLinha:=''
For nX := 1 to nQtdCol
	If Valtype(aFields[nX])=='B'
		nTamanho := len(Eval(aFields[nCol+nX-1]))
		If nTamanho < len(aCab)
			nTamanho := len(aCab)
		EndIf
	Else
		nTamanho := aSizeFields[nCol+nX-1]
	EndIf
	sLinha += Padr(aCab[nCol+nX-1],nTamanho)
	If nX < nQtdCol
		sLinha+='|'
	EndIf
Next
aadd(aVetor,sLinha)
aRecno:={}

For n:= 1 to nLenWindow-1
	sLinha := ''
	For nX := 1 to nQtdCol
		If Valtype(aFields[nCol+nX-1])=='B'
			uConteudo :=Eval(aFields[nCol+nX-1])
			If len(uConteudo) < len(aCab)
				uConteudo := Padr(uConteudo,len(aCab))
			EndIf
		Else
			uConteudo :=FieldGet(FieldPos(aFields[nCol+nX-1]))
			nPos := ASCAN(aFieldNames,aFields[nCol+nX-1])
			If aTypes[nPos] =='C'
				uConteudo:= Padr(uConteudo,aSizeFields[nCol+nX-1])
			ElseIf aTypes[nPos] =='N'
				uConteudo := Str(uConteudo,aSizes[nPos],aDecimals[npos])
				uConteudo := Padl(AllTrim(uConteudo),aSizeFields[nCol+nX-1])
			ElseIf Valtype(uConteudo) =='D'
				uConteudo := Padc(Dtoc(uConteudo),aSizeFields[nCol+nX-1])
			ElseIf Valtype(uConteudo) =='L'
				uConteudo := if(uConteudo,'T','F')
			ElseIf Valtype(uConteudo) =='M'
				uConteudo := 'MEMO'
			EndIf
		EndIf
		sLinha +=uConteudo
		If nX < nQtdCol
			sLinha+='|'
		EndIf
	Next
	aadd(aVetor,Padr(sLinha,nLenString))
	aadd(aRecno,recno())
	dbSkip()
	cConteudo := &(Indexkey())
	If Valtype(cBottom)=='C'
		cBottom1 := &cBottom
	EndIf
	If EOF()  .or. (Valtype(cBottom1)=='C' .and.  cBottom1 < Left(cConteudo,len(cBottom1)))
		Exit
	EndIf
Next
dbgoto(nRecno)
Return aVetor

/*
// A funcao abaixa esta sendo comentada no dia 01/09/2004, pois nao esta
// sendo usada neste programa. by Erike Yuri
// funcao auxiliar do TerDbBrowse
Static Function TerSayDbBrowse(nTop,nLeft,aTela,nSelect,nSelectOld,nLen)
Local nX :=0
Local nUl:=0,nUC:=0
Local cSay
If nSelect ==nSelectOld
	For nX:= 1 to Len(aTela)
		If nSelect == nX
			If TerProtocolo()=="VT100"
				VtReverso(.t.)
			EndIf
			cSay := Padr(aTela[nX],nLen)
			If VtMaxRow()==1
				cSay := Left(cSay,len(cSay)-1)+"<"
			EndIf
			TerSAY(nTop+nX-1,nLeft,cSay)
			If TerProtocolo()=="VT100"
				VtReverso(.f.)
			EndIf
			nUl:=nTop+nX-1
			nUc:=nLeft
		Else
			TerSAY(nTop+nX-1,nLeft,Padr(aTela[nX],nLen))
		EndIf
	Next
	//VTPOS(nUl,nUc)
Else
	If TerProtocolo()=="VT100"
		VtReverso(.f.)
	EndIf
	TerSAY(nTop+nSelectOld-1,nLeft,aTela[nSelectOld])
	If TerProtocolo()=="VT100"
		VtReverso(.t.)
	EndIf
	cSay := aTela[nSelect]
	cSay := Left(cSay,len(cSay)-1)+"<"
	TerSAY(nTop+nSelect-1,nLeft,cSay)
	If TerProtocolo()=="VT100"
		VtReverso(.f.)
	EndIf
//	VTPOS(nTop+nSelect-1,nLeft)
EndIf
Return
*/

Function TerDbBrwRefresh()
	__lDbBrwRefresh:= .t.
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TerDispFile ³ Autor ³ Sandro              ³ Data ³ 20/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra arq. texto no display do Microterminal              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cArquivo = nome do arquivo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TerxFun                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TerDispFile(cArquivo)
Local cString
Local cLine
Local nLen
Local aCab   :={cArquivo,cArquivo,cArquivo,cArquivo}
Local aSize  := {20,20,20,20}
Local aItens :={}
Local aScr := TerSave()
Local nMaxCol := If(TerModelo()=="MT16",19,39)
Local i

cString:= MemoRead(cArquivo)
If nMaxCol<>19
	aCab   :={cArquivo,cArquivo}
	aSize  := {40,40}
Else
	aCab   :={cArquivo,cArquivo,cArquivo,cArquivo}
	aSize  := {20,20,20,20}
EndIf

nLen := MlCount(cString,80)
For i := 1 To nLen
	cLine := MemoLine(cString,80,i)
	If nMaxCol == 19
		aadd(aItens,{Subst(cLine,1,20),Subst(cLine,20,20),Subst(cLine,39,20),Subst(cLine,58,20)})
	Else
		aadd(aItens,{Subst(cLine,1,40),Subst(cLine,40,40)})
	EndIf
Next
TerCBuffer()
TeraBrowse(0,0,1,nMaxCol,aCab,aItens,aSize)
TerRestore(,,,,aScr)

Return

Function TerYesNo(cMsg,cTitulo,cFunct)
Local nSelectDraw  := 1
Local nSelectOld   := nSelectDraw
Local nPIniaMsg    := 1
Local aTela        := {}
Local nLenWindow   := 2
Local nPosaMsg     := 1
Local nPosMAnt     := 0
Local nLen         := 0
Local cConteudo    := ""
Local aMsg         := {}
Local nIniVetor    := 1
Local lRet         := .F.
Local nMaxCol      := If(TerModelo()=="MT16",19,39)
Local cRetKey
Local aSavTela     := TerSave()
Local i            := 0

cConteudo:= "["+Alltrim(cTitulo)+"] "+cMsg+' - '+ STR0032 //"[S/N]"
nLen:= MlCount(cConteudo,nMaxCol-1)
For i := 1 To nLen
	Aadd(aMsg,MemoLine(cConteudo,nMaxCol-1,i))
Next

nPosaMsg  := nIniVetor

If  nIniVetor > nLenWindow
	nPIniaMsg := nIniVetor-nSelectDraw+1
	If nPIniaMsg > (len(aMsg)-nLenWindow)
		nPIniaMsg := (len(aMsg)-nLenWindow)+1
		nSelectDraw := nLenWindow-(len(aMsg)-nIniVetor)
		nSelectOld  := nSelectDraw
	EndIf
ElseIf nIniVetor-nLenWindow <=  0
	nSelectDraw := nIniVetor
	nSelectOld  := nSelectDraw
	nPIniaMsg := 1
EndIf

nPosMAnt := 0

While .t.

	If nPosaMsg # nPosMAnt
		aTela:=Aclone(TerLoadaMenu(aMsg,nLenWindow,nMaxCol,nPIniaMsg))
		TerSayachoice(0,0,aTela,nSelectDraw,nSelectOld,nMaxCol)
	EndIf

	nPosMAnt := nPosAMsg
	cRetkey:= TerInkey(0)
	nSelectOld := nSelectDraw
	If TerESC()   .OR. cRetkey  $ 'Nn'
		lRet		:= .F.
		Exit
	ElseIf cRetkey  $ 'SsYy5'
		lRet		:= .T.
		Exit
	ElseIf cRetkey =="8" .or. Asc(cRetKey) == 5// Up
		If nSelectDraw = 1
			If (nPIniaMsg) > 1
				nPIniaMsg--
				nPosaMsg--
			EndIf
		Else
			nSelectDraw--
			nPosaMsg--
		EndIf
	ElseIf cRetKey=="2" .or. Asc(cRetKey) == 24// down
		If nSelectDraw = nLenWindow
			If (nPIniaMsg+nLenWindow) <= Len(aMsg)
				nPIniaMsg++
				nPosaMsg++
			EndIf
		Else
			If (nPosaMsg) < len(aMsg)
				nSelectDraw++
				nPosaMsg++
			EndIf
		EndIf
	EndIf
End
TerRestore(,,,,aSavTela)
Return lRet
/*
   Esta funcao seta se o get vai ser preenchido com pontos para indentificar
   o tamanho do get somente para o tipo caracter
*/
Function TerGetFill(lModo)
DEFAULT lModo := .t.
__lGetFill:= lModo
Return

/*
   Esta funcao seta o modo de comunicacao entre as threads
   .t. por variaveis globais no server
   .f. por arquivo de controle do tipo TXT
   ATENCAO ESTA FUNCAO NAO PODE SER DIVULGADA
*/
Function TerIsVarGbl(lModo)
lVarGbl := lModo
Return
