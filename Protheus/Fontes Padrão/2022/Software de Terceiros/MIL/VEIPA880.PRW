#INCLUDE "veipa880.ch"

#Include "protheus.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPA880 ³ Autor ³ Andr‚                 ³ Data ³ 25/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Recalculo das Parcelas                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION VEIPA880

Local oGrupo1,oGrupo2

Local cGrupo1 := "00001"
Local cGrupo2 := "99999"
Local nOpca   := 0

cAlias  := "VP3"
cTitulo := STR0001   // //"Posicao dos Grupos"

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0002) FROM  02,04 TO 06,49 OF oMainWnd //"Recalculo das Parcelas"

@ 01,005 SAY STR0003 of oDlg PIXEL       //"Grupo Inicial" //"Grupo Inicial:"
@ 15,005 SAY STR0004  of oDlg PIXEL      //"Grupo Final" //"Grupo Final:"

@ 01,040 GET oGrupo1 VAR cGrupo1 OF oDlg PIXEL
@ 15,040 GET oGrupo2 VAR cGrupo2 OF oDlg PIXEL

DEFINE SBUTTON FROM 01,137 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 15,137 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

if nOpca # 1
   Return
Endif

DbSelectArea("VP1")
DbSetOrder(1)
DbGotop()
Set SoftSeek ON
DbSeek(xFilial("VP1")+cGrupo1)
Do While !EOF() .and. VP1->VP1_FILIAL == xFilial("VP1") .and. VP1_CODGRU >= cGrupo1 .and. VP1_CODGRU <= cGrupo2
   FG_GERPAR(VP1_CODGRU+VP1_NUMCOT+VP1_CODCLI+VP1_LOJA,2,.f.)
   DbSkip()
Enddo
Set SoftSeek OFF

Return(.t.)

