#INCLUDE "pmsc400.ch"
#include "protheus.ch"
#include "pmsicons.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSC400  ³ Autor ³ Edson Maricate        ³ Data ³ 03-02-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa visualizador de arquivos grafico de gantt GGR       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC400()

Local nTop
Local nLeft
Local nBottom
Local nRight
Local oFont
Local oDlg
Local oBtn
Local oBar
Local dIni		:= MsDate()
Local nTsk		:= 1
Local aGantt	:= {}
Local aHeader	:= {}
Local aDependencia := {}
Local aCmbSeek	:= {}
Local cText		:= ""
Local aConfig	:= {6}
Local Nx		:= 0
Local lFWGetVersao := .T.
Local aButtons	:= {}

PRIVATE bRfshGantt := {|| Nil  } 
PRIVATE cCadastro	:= STR0001 //"Visualizador de Grafico de Gantt"

If PMSBLKINT()
	Return Nil
EndIf

RegToMemory("AFA",.T.)
RegToMemory("AFB",.T.)

DEFINE FONT oFont NAME "Arial" SIZE 0, -10     
oMainWnd:CoorsUpdate()
nTop     := oMainWnd:nTop+16
nLeft    := oMainWnd:nLeft+13
nBottom  := oMainWnd:nBottom-40
nRight   := oMainWnd:nRight-20

DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight 
	oDlg:lMaximized := .T.	   

If !lFWGetVersao .or. GetVersao(.F.) == "P10"

	DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
		
	@ 1000,38 BUTTON "." SIZE 35,12 ACTION {|| Nil} OF oDlg PIXEL 
		
	// abrir
	oBtn := TBtnBmp():NewBar(BMP_OPEN, BMP_OPEN,,, STR0002, {|| If(GanttLoad(@dIni,aGantt,aHeader,aDependencia,aCmbSeek,@cText,aConfig),Eval(bRfshGantt),Nil) },.T.,oBar,,, STR0002) //"Abrir"###"Abrir"
	oBtn:cTitle := STR0002 //"Abrir"

	// salvar
	oBtn := TBtnBmp():NewBar(BMP_SALVAR, BMP_SALVAR,,, STR0003, {|| GanttSave(@dIni,aGantt,aHeader,aDependencia,aCmbSeek,@cText,aConfig) },.T.,oBar,,, STR0003) //"Salvar"###"Salvar"
	oBtn:cTitle := STR0003 //"Salvar"

	oBtn := TBtnBmp():NewBar( BMP_INTERROGACAO,BMP_INTERROGACAO,, ,"Help" ,{|| HelProg() },.T.,oBar,, ,"Help")
	oBtn:cTitle := "Help"

	oBtn := TBtnBmp():NewBar(BMP_SAIR, BMP_SAIR,,, TIP_SAIR, {|| oDlg:End() },.T.,oBar,,, TIP_SAIR)
	oBtn:cTitle := TOOL_SAIR

Else	
	AADD(aButtons, {BMP_OPEN			, {|| If(GanttLoad(@dIni,aGantt,aHeader,aDependencia,aCmbSeek,@cText,aConfig),Eval(bRfshGantt),Nil) }, STR0002 })
	AADD(aButtons, {BMP_SALVAR			, {|| GanttSave(@dIni,aGantt,aHeader,aDependencia,aCmbSeek,@cText,aConfig) } ,STR0003 })
	AADD(aButtons, {BMP_INTERROGACAO	, {|| HelProg() } ,"Help" })
	EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons,,,,,.F.,.F.)
Endif
		
PmsGantt(aGantt,aConfig,@dIni,,oDlg,{14,1,(nBottom/2)-40,(nRight/2)-4},aHeader,@nTsk,aDependencia,@cText,,,aCmbSeek)

ACTIVATE MSDIALOG oDlg ON INIT (GanttLoad(@dIni,aGantt,aHeader,aDependencia,aCmbSeek,@cText,aConfig),Eval(bRfshGantt))

Return 