#INCLUDE "Avprevi.ch"
/*
ÚÄ Programa ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Aplication: Preview for class TReport                                  ³
³         File: RPREVIEW.PRG                                               ³
³       Author: Ignacio Ortiz de Z£¤iga Echeverr¡a                         ³
³          CIS: Ignacio Ortiz (100042,3051)                                ³
³     Internet: http://ourworld.compuserve.com/homepages/Ignacio_Ortiz     ³
³         Date: 09/28/94                                                   ³
³         Time: 20:20:07                                                   ³
³    Copyright: 1994 by Ortiz de Zu¤iga, S.L.                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Last change:  US   26 Nov 97    4:34 pm
*/

//#include "FiveWin.ch"
#include "average.ch"

#define DEVICE      oWnd:cargo

#define GO_UP       1
#define GO_DOWN     2
#define GO_LEFT     1
#define GO_RIGHT    2
#define GO_PAGE    .T.

#define VSCROLL_RANGE  20*nZFactor
#define HSCROLL_RANGE  20*nZFactor

#define TXT_FIRST    STR0001 //"&Primeira Página"
#define TXT_PREVIOUS STR0002 //"Página &Anterior"
#define TXT_NEXT     STR0003 //"P&róxima Página"
#define TXT_LAST     STR0004 //"Ú&ltima Página"
#define TXT_ZOOM     STR0005 //"&Zoom"
#define TXT_UNZOOM   STR0006 //"&Normal"
#define TXT_TWOPAGES STR0007 //"&Duas Páginas"
#define TXT_ONEPAGE  STR0008 //"&Uma Página"
#define TXT_PRINT    STR0009 //"&Imprimir"
#define TXT_EXIT     STR0010 //"Sai&r"
#define TXT_FILE     STR0011 //"&Arquivo"
#define TXT_PAGE     STR0012 //"&Página"
#define TXT_PREVIEW  STR0013 //"Vizualição de Documentos"
#define TXT_PAGENUM  STR0014 //"Página Número: "
#define TXT_A_WINDOW_PREVIEW_IS_ALLREADY_RUNNING STR0015 //"Janela de Visualização ativa"
#define TXT_GOTO_FIRST_PAGE 		STR0016 //"Primeira Página"
#define TXT_GOTO_PREVIOUS_PAGE 		STR0017 //"Página Anterior"
#define TXT_GOTO_NEXT_PAGE 			STR0018 //"Próxima Página"
#define TXT_GOTO_LAST_PAGE 			STR0019 //"Última Página"
#define TXT_ZOOM_THE_PREVIEW 		STR0020 //"Zoom"
#define TXT_UNZOOM_THE_PREVIEW 		STR0021 //"Desfaz Zoom"
#define TXT_PREVIEW_ON_TWO_PAGES 	STR0022 //"Duas Páginas"
#define TXT_PREVIEW_ON_ONE_PAGE 	STR0023 //"Uma Página"
#define TXT_PRINT_CURRENT_PAGE 		STR0024 //"Imprime Página Atual"
#define TXT_EXIT_PREVIEW 			STR0025 //"Sair do Preview"
#define TXT_ZOOM_FACTOR 			STR0026 //"Muda o fator do Zoom"

//STATIC aFactor

#IFDEF PROTHEUS
#ELSE
STATIC oWnd, oBrush, oIcon, oBar, oFont, oCursor, oMeta1, oMeta2,;
       oPage, oTwoPages, oZoom, oFactor, oVScroll, oHScroll
STATIC nPage, nZFactor
STATIC lTwoPages, lZoom
#ENDIF
//STATIC cMarca , lInverte

#IFDEF PROTHEUS

#ELSE
//----------------------------------------------------------------------------//

FUNCTION AvPrevi(oDevice)

     LOCAL aFiles := oDevice:aMeta
		// LOCAL hOldRes:= hSigaRes   // GetResources()  mjb1197 // Ramalho
     LOCAL oSay
     LOCAL aWindows
     LOCAL nFor, oWndDef

     IF oWnd != NIL
        MsgStop(TXT_A_WINDOW_PREVIEW_IS_ALLREADY_RUNNING)
        RETU NIL
     ENDIF

     // SetResources("SIGAEIC.DLL")    // mjb1197 // Ramalho
     
     oWndDef:=GetWndDefault()
     aWindows := GetAllWin()

     FOR nFor := 1 TO nWindows()
          IF Valtype(aWindows[nFor]) == "O"
               IF aWindows[nFor]:hWnd == GetWndApp()
                    oIcon := aWindows[nFor]:oIcon
                    EXIT
               ENDIF
          ENDIF
     NEXT

     DEFINE FONT oFont NAME "Ms Sans Serif" SIZE 0,-12 BOLD

     DEFINE CURSOR oCursor RESOURCE "PESQUISA" /*"Lupa"*/

     DEFINE MSDIALOG oWnd FROM 0.1, 0 TO 28.5, 80 ;
           TITLE STR0028 + oDevice:cDocument ; //"SIGAEIC - "
           COLOR CLR_BLACK,CLR_LIGHTGRAY          ;
           ICON  oIcon                            ;
           Of oMainWnd // GetWndDefault()

     ACTIVATE MSDIALOG oWnd                      ;
          ON INIT      (AvPrevBar(oDevice,aFiles),SetFactor(nZFactor)) ;
          VALID        (oWnd:oIcon := NIL       ,;
                        oMeta1:End()            ,;
                        oMeta2:End()            ,;
                        oDevice:End()           ,; //                        SetResources(hOldRes)   ,; Ramalho
                        oWnd := NIL, .T.)

Return (NIL)
//----------------------------------------------------------------------------//

STATIC FUNCTION AvPrevBar(oDevice,aFiles)

   nPage     := 1
   nZFactor  := 2
   lTwoPages := .F.
   lZoom     := .F.

   oWnd:cargo := oDevice
      
   oBar := FWButtonBar():new()

   oBar:bRClicked := {|| NIL }

   DEFINE BUTTON RESOURCE "Eic_Top" OF oBar ;
         MESSAGE TXT_GOTO_FIRST_PAGE     ;
         ACTION TopPage()                ;
         TOOLTIP Strtran(TXT_FIRST,"&","")

   DEFINE BUTTON RESOURCE "Eic_Previous" OF oBar ;
         MESSAGE TXT_GOTO_PREVIOUS_PAGE       ;
         ACTION PrevPage()                    ;
         TOOLTIP Strtran(TXT_PREVIOUS,"&","")

   DEFINE BUTTON RESOURCE "Eic_Next" OF oBar ;
         MESSAGE TXT_GOTO_NEXT_PAGE       ;
         ACTION NextPage()                ;
         TOOLTIP Strtran(TXT_NEXT,"&","")

   DEFINE BUTTON RESOURCE "Eic_Bottom" OF oBar ;
         MESSAGE TXT_GOTO_LAST_PAGE         ;
         ACTION BottomPage()                ;
         TOOLTIP Strtran(TXT_LAST,"&","")

   DEFINE BUTTON oZoom RESOURCE "Eic_Zoom" OF oBar GROUP ;
         MESSAGE TXT_ZOOM_THE_PREVIEW                 ;
         ACTION Zoom()                                ;
         TOOLTIP Strtran(TXT_ZOOM,"&","")

   DEFINE BUTTON oTwoPages RESOURCE "Eic_Two_Pages" OF oBar  ;
         MESSAGE TXT_PREVIEW_ON_TWO_PAGES       ;
         ACTION TwoPages()                      ;
         TOOLTIP Strtran(TXT_TWOPAGES,"&","")

   DEFINE BUTTON RESOURCE "Eic_Printer" OF oBar GROUP ;
         MESSAGE TXT_PRINT_CURRENT_PAGE            ;
         ACTION AvPrintPage()                      ;
         TOOLTIP Strtran(TXT_PRINT,"&","")

   DEFINE BUTTON RESOURCE "Eic_Exit" OF oBar GROUP ;
         MESSAGE TXT_EXIT_PREVIEW               ;
         ACTION oWnd:End()                      ;
         TOOLTIP Strtran(TXT_EXIT,"&","")

   @ 9, 320 SAY oSay PROMPT STR0029 ; //"Fator:"
         SIZE 60, 15 PIXEL OF oBar FONT oFont

   @ 6, 365 COMBOBOX oFactor VAR nZFactor ;
         ITEMS {"1","2","3","4","5","6","7","8","9"} ;
         OF oBar FONT oFont PIXEL SIZE 45,200 ;
         ON CHANGE SetFactor(nZFactor)

   @ 9, 420 SAY oPAGE PROMPT TXT_PAGENUM+ltrim(str(nPage,4)) ;
         SIZE 160, 15 PIXEL OF oBar FONT oFont

   @ oWnd:nTop+70,oWnd:nRight-25 SCROLLBAR oVScroll VERTICAL  Of oWnd     ;
                                 SIZE 20,oWnd:nBottom-oWnd:nTop-100 PIXEL ;
                                 COLOR CLR_GRAY,CLR_LIGHTGRAY             ;
                                 ON UP        vScroll(GO_UP)              ;
                                 ON DOWN      vScroll(GO_DOWN)            ;
                                 ON PAGEUP    vScroll(GO_UP,GO_PAGE)      ;
                                 ON PAGEDOWN  vScroll(GO_DOWN,GO_PAGE)
               
   @ oWnd:nBottom-30,oWnd:nLeft+0.5 SCROLLBAR oHScroll HORIZONTAL Of oWnd  ;
                                    SIZE oWnd:nRight-oWnd:nLeft-25,20 PIXEL;
                                    COLOR CLR_BLACK,CLR_LIGHTGRAY          ;
                                    ON UP        hScroll(GO_UP)            ;
                                    ON DOWN      hScroll(GO_DOWN)          ;
                                    ON PAGEUP    hScroll(GO_UP,GO_PAGE)    ;
                                    ON PAGEDOWN  hScroll(GO_DOWN,GO_PAGE)

   oVScroll:SetRange(0,0)
   oHScroll:SetRange(0,0)

   SET MESSAGE OF oWnd TO TXT_PREVIEW CENTERED

   oFactor:Set3dLook()

   oMeta1 := TMetaFile():New(0,0,0,0,;
                              aFiles[1],;
                              oWnd,;
                              CLR_BLACK,;
                              CLR_WHITE,;
                              oDevice:nHorzRes(),;
                              oDevice:nVertRes())

   oMeta1:oCursor := oCursor
   oMeta1:blDblClicked := {|nRow, nCol, nKeyFlags| ;
                           SetOrg1(nCol, nRow, nKeyFlags)}

   oMeta1:bKeyDown := {|nKey,nFlags| CheckKey(nKey,nFlags)}

   oMeta2 := TMetaFile():New(0,0,0,0,;
                              "",;
                              oWnd,;
                              CLR_BLACK,;
                              CLR_WHITE,;
                              oDevice:nHorzRes(),;
                              oDevice:nVertRes())

   oMeta2:oCursor := oCursor
   oMeta2:blDblClicked := {|nRow, nCol, nKeyFlags| ;
                           SetOrg2(nCol, nRow, nKeyFlags)}
   oMeta2:hide()

   SetFactor(1)

   oBar:bRClicked:={||AllwaysTrue()} 

   PaintMeta()

Return NIL
//----------------------------------------------------------------------------//

STATIC Function PaintMeta()

     LOCAL oCoors1, oCoors2
     LOCAL aFiles := DEVICE:aMeta
     LOCAL nWidth, nHeight, nFactor

     IF IsIconic(oWnd:hWnd)
          RETU NIL
     ENDIF

     DO CASE
     CASE !lTwoPages

          IF !lZoom

               IF DEVICE:nHorzSize() >= ;        // Apaisado
                  DEVICE:nVertSize()
                    nFactor := .4
               ELSE
                    nFactor := .25
               ENDIF

          ELSE
               nFactor := .47
          ENDIF

          nWidth  := oWnd:nRight-oWnd:nLeft+1 - iif(lZoom,20 ,0 ) 
          nHeight := oWnd:nBottom-oWnd:nTop+1 - iif(lZoom,20 ,0 )
          oCoors1 := TRect():New(50,;
                                nWidth/2-(nWidth*nFactor),;
                                nHeight-80,;
                                nWidth/2+(nWidth*nFactor))
          oMeta2:Hide()
          oMeta1:SetCoors(oCoors1)

     CASE lTwoPages

          nFactor := .4
          aFiles  := DEVICE:aMeta

          nWidth  := oWnd:nRight-oWnd:nLeft+1
          nHeight := oWnd:nBottom-oWnd:nTop+1

          oCoors1 := TRect():New(50,;
                                (nWidth/4)-((nWidth/2)*nFactor),;
                                nHeight-80,;
                                (nWidth/4)+((nWidth/2)*nFactor))
          oCoors2 := TRect():New(50,;
                                (nWidth/4)-((nWidth/2)*nFactor)+(nWidth/2),;
                                nHeight-80,;
                                (nWidth/4)+((nWidth/2)*nFactor)+(nWidth/2))

          IF nPage == Len(aFiles)
               oMeta2:SetFile("")
          ELSE
               oMeta2:SetFile(aFiles[nPage+1])
          ENDIF

          oMeta1:SetCoors(oCoors1)
          oMeta2:SetCoors(oCoors2)
          oMeta2:Show()

     ENDCASE

     oMeta1:SetFocus()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function NextPage()


     LOCAL aFiles := DEVICE:aMeta

     IF nPage == len(aFiles)
          MessageBeep()
          RETU NIL
     ENDIF

     nPage++

     oMeta1:SetFile(aFiles[nPage])
     oPage:SetText(TXT_PAGENUM+ltrim(str(nPage,4)))

     oMeta1:Refresh()

     IF lTwoPages
          IF len(aFiles) >= (nPage+1)
               oMeta2:SetFile(aFiles[nPage+1])
          ELSE
               oMeta2:SetFile("")
          ENDIF
          oMeta2:Refresh()
     ENDIF

     oMeta1:SetFocus()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function PrevPage()


     LOCAL aFiles := DEVICE:aMeta

     IF nPage == 1
          MessageBeep()
          RETU NIL
     ENDIF

     nPage--

     oMeta1:SetFile(aFiles[nPage])
     oPage:SetText(TXT_PAGENUM+ltrim(str(nPage,4)))
     oMeta1:Refresh()

     IF lTwoPages
          IF len(aFiles) >= nPage+1
               oMeta2:SetFile(aFiles[nPage+1])
          ELSE
               oMeta2:SetFile("")
          ENDIF
          oMeta2:Refresh()
     ENDIF

     oMeta1:SetFocus()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function TopPage()


     LOCAL aFiles := DEVICE:aMeta

     IF nPage == 1
          MessageBeep()
          RETU NIL
     ENDIF

     nPage := 1

     oMeta1:SetFile(aFiles[nPage])
     oPage:SetText(TXT_PAGENUM+ltrim(str(nPage,4)))

     oMeta1:Refresh()

     IF lTwoPages
          IF len(aFiles) >= nPage+1
               oMeta2:SetFile(aFiles[nPage+1])
          ELSE
               oMeta2:SetFile("")
          ENDIF
          oMeta2:Refresh()
     ENDIF

     oMeta1:SetFocus()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC Function BottomPage()


     LOCAL aFiles := DEVICE:aMeta

     IF nPage == len(aFiles)
          MessageBeep()
          RETU NIL
     ENDIF

     nPage := len(aFiles)

     oMeta1:SetFile(aFiles[nPage])
     oPage:SetText(TXT_PAGENUM+ltrim(str(nPage,4)))

     oMeta1:Refresh()

     IF lTwoPages
          oMeta2:SetFile("")
          oMeta2:Refresh()
     ENDIF

     oMeta1:SetFocus()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION TwoPages()


     lTwoPages := !lTwoPages

     IF lTwoPages

          IF len(DEVICE:aMeta) == 1 // solo hay una pagina
             lTwoPages := !lTwoPages
             MessageBeep()
             RETU NIL
          ENDIF

          IF DEVICE:nHorzSize() >= ;        // Apaisado
             DEVICE:nVertSize()
             lTwoPages := !lTwoPages
             MessageBeep()
             RETU NIL
          ENDIF

          IF lZoom
             Zoom(.T.)
          ENDIF

          oTwoPages:FreeBitmaps()
          oTwoPages:LoadBitmaps("Eic_One_Page")
          oTwoPages:cMsg := TXT_PREVIEW_ON_ONE_PAGE
          oTwoPages:cTooltip := StrTran(TXT_ONEPAGE,"&","")

     ELSE

          oTwoPages:FreeBitmaps()
          oTwoPages:LoadBitmaps("Two_Pages")
          oTwoPages:cMsg     := TXT_PREVIEW_ON_TWO_PAGES
          oTwoPages:cTooltip := StrTran(TXT_TWOPAGES,"&","")

     ENDIF

     PaintMeta()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION Zoom()

     lZoom := !lZoom

     IF lZoom

          IF lTwoPages
               TwoPages(.T.)
          ENDIF

          oZoom:FreeBitmaps()
          oZoom:LoadBitmaps("Eic_Unzoom")
          oZoom:cMsg := TXT_UNZOOM_THE_PREVIEW
          oZoom:cTooltip := StrTran(TXT_UNZOOM,"&","")

          oVScroll:SetRange(1,VSCROLL_RANGE)
          oHScroll:SetRange(1,HSCROLL_RANGE)

          oMeta1:oCursor := NIL
          oMeta1:ZoomIn()

     ELSE

          oZoom:FreeBitmaps()
          oZoom:LoadBitmaps("Eic_Zoom")
          oZoom:cMsg := TXT_ZOOM_THE_PREVIEW
          oZoom:cTooltip := StrTran(TXT_ZOOM,"&","")

          oVScroll:SetRange(0,0)
          oHScroll:SetRange(0,0)

          oMeta1:oCursor := oCursor
          oMeta1:ZoomOut()

     ENDIF

     PaintMeta()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION VScroll(nType,lPage, nSteps)

     LOCAL nYfactor, nYorig, nStep

     DEFAULT lPage := .F.

     nYfactor := Int(DEVICE:nVertRes()/oVScroll:nMax)

     IF nSteps != NIL
          nStep := nSteps
     ELSEIF lPage
          nStep := oVScroll:nMax/10
     ELSE
          nStep := 1
     ENDIF

     IF nType == GO_UP
          nStep := -(nStep)
     ENDIF

     nYorig := nYfactor * (oVScroll:GetPos() + nStep)

     IF nYorig > DEVICE:nVertRes()
          nYorig := DEVICE:nVertRes()
     ENDIF

     IF nYorig < 0
          nYorig := 0
     ENDIF

     oMeta1:SetOrg(NIL,nYorig)

     oMeta1:Refresh()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION HScroll(nType,lPage, nSteps)

     LOCAL nXfactor, nXorig, nStep

     DEFAULT lPage := .F.

     nXfactor := Int(DEVICE:nHorzRes()/oHScroll:nMax)

     IF nSteps != NIL
          nStep := nSteps
     ELSEIF lPage
          nStep := oHScroll:nMax/10
     ELSE
          nStep := 1
     ENDIF

     IF nType == GO_LEFT
        nStep := -(nStep)
     ENDIF

     nXorig := nXfactor * (oHScroll:GetPos() + nStep)

     IF nXorig > DEVICE:nHorzRes()
        nXorig := DEVICE:nHorzRes()
     ENDIF

     IF nXorig < 0
        nXorig := 0
     ENDIF

     oMeta1:SetOrg(nXorig,NIL)

     oMeta1:Refresh()

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION SetOrg1(nX, nY)

     LOCAL oCoors
     LOCAL nXStep, nYStep, nXFactor, nYFactor,;
           nWidth, nHeight, nXOrg

     IF lZoom
        Zoom(.T.)
        RETU NIL
     ENDIF

     oCoors   := oMeta1:GetRect()
     nWidth   := oCoors:nRight - oCoors:nLeft + 1
     nHeight  := oCoors:nBottom - oCoors:nTop + 1
     nXStep   := Max(Int(nX/nWidth*HSCROLL_RANGE) - 9, 0)
     nYStep   := Max(Int(nY/nHeight*VSCROLL_RANGE) - 9, 0)
     nXFactor := Int(DEVICE:nHorzRes()/HSCROLL_RANGE)
     nYFactor := Int(DEVICE:nVertRes()/VSCROLL_RANGE)

     Zoom(.T.)
   
     IF !empty(nXStep)
        HScroll(2,,nxStep)
        oHScroll:SetPos(nxStep)
     ENDIF

     IF !empty(nYStep)
        VScroll(2,,nyStep)
        oVScroll:SetPos(nyStep)
     ENDIF

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION SetOrg2(nX, nY)

     LOCAL oCoors
     LOCAL aFiles
     LOCAL nXStep, nYStep, nXFactor, nYFactor,;
           nWidth, nHeight, nXOrg

     IF oMeta2:cCaption == ""
          RETU NIL
     ENDIF

     IF lZoom
        Zoom(.T.)
        RETU NIL
     ENDIF

     oCoors   := oMeta2:GetRect()
     nWidth   := oCoors:nRight - oCoors:nLeft + 1
     nHeight  := oCoors:nBottom - oCoors:nTop + 1
     nXStep   := Max(Int(nX/nWidth*HSCROLL_RANGE) - 9, 0)
     nYStep   := Max(Int(nY/nHeight*VSCROLL_RANGE) - 9, 0)
     nXFactor := Int(DEVICE:nHorzRes()/HSCROLL_RANGE)
     nYFactor := Int(DEVICE:nVertRes()/VSCROLL_RANGE)

     oMeta1:SetFile(oMeta2:cCaption)

     aFiles := DEVICE:aMeta

     IF nPage = len(aFiles)
          oMeta2:SetFile("")
     ELSE
          oMeta2:SetFile(aFiles[++nPage])
     ENDIF

     oPage:Refresh()

     Zoom(.T.)

     IF !empty(nXStep)
        HScroll(2,,nxStep)
        oHScroll:SetPos(nxStep)
     ENDIF

     IF !empty(nYStep)
        VScroll(2,,nyStep)
        oVScroll:SetPos(nyStep)
     ENDIF

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION CheckKey (nKey,nFlags) // Thanks to Joerg K.

     IF !lZoom
          DO CASE
             CASE nKey == VK_HOME
                  TopPage()
             CASE nKey == VK_END
                  BottomPage()
             CASE nKey == VK_PRIOR
                  PrevPage()
             CASE nKey == VK_NEXT
                  NextPage()
          ENDCASE
     ELSE
          DO CASE
             CASE nKey == VK_UP
                  oVScroll:GoUp()
             CASE nKey == VK_PRIOR
                  oVScroll:PageUp()
             CASE nKey == VK_DOWN
                  oVScroll:GoDown()
             CASE nKey == VK_NEXT
                  oVScroll:PageDown()
             CASE nKey == VK_LEFT
                  oHScroll:GoUp()
             CASE nKey == VK_RIGHT
                  oHScroll:GoDown()
             CASE nKey == VK_HOME
                  oVScroll:GoTop()
                  oHScroll:GoTop()
                  oMeta1:SetOrg(0,0)
                  oMeta1:Refresh()
             CASE nKey == VK_END
                  oVScroll:GoBottom()
                  oHScroll:GoBottom()
                  oMeta1:SetOrg(.8*DEVICE:nHorzRes(),.8*DEVICE:nVertRes())
                  oMeta1:Refresh()
          ENDCASE
     ENDIF

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION SetFactor(nValue)

     LOCAL lInit := .F.

     IF nValue == NIL
        nValue := nZFactor
        lInit  := .T.
     ENDIF

     oMeta1:SetZoomFactor(nZFactor, nZFactor*2)

     IF !lZoom .AND. !lInit
        Zoom(.T.)
     ENDIF

     IF lZoom
        oVScroll:SetRange(1,VSCROLL_RANGE)
        oHScroll:SetRange(1,HSCROLL_RANGE)
     ENDIF
   
     oMeta1:SetFocus()

RETURN NIL

#ENDIF

//----------------------------------------------------------------------------//
Function AvPrintPage(aPrint)

LOCAL oDlg
LOCAL nOption := 1 ,;
      nFirst  := 1 ,;
      nLast   := len(If(aPrint=NIL,DEVICE:aMeta,aPrint))
#IFDEF PROTHEUS
#ELSE
oRad, oPageIni, oPageFin
#ENDIF

If aPrint # NIL
   PrintPrv(oDlg, nOption, nFirst, nLast, aPrint)
   Return NIL
Endif

#IFDEF PROTHEUS
#ELSE
DEFINE MSDIALOG oDlg RESOURCE "AVPRNRANGE"

REDEFINE BUTTON ID 101 OF oDlg ;
     ACTION PrintPrv(oDlg, nOption, nFirst, nLast, aPrint)

REDEFINE BUTTON ID 102 OF oDlg ACTION oDlg:End()

REDEFINE RADIO oRad VAR nOption ID 103,104,105 OF oDlg ;
     ON CHANGE iif(nOption==3 ,;
                  (oPageIni:Enable(),oPageFin:Enable()) ,;
                  (oPageIni:Disable(),oPageFin:Disable()) )

REDEFINE GET oPageIni ;
     VAR nFirst ;
     ID 106 ;
     PICTURE "@K 99999" ;
     VALID iif(nFirst<1 .OR. nFirst>nLast,(MessageBeep(),.F.),.T.) ;
     OF oDlg

REDEFINE GET oPageFin ;
     VAR nLast ;
     ID 107 ;
     PICTURE "@K 99999" ;
     VALID iif(nLast<nFirst .OR. nLast>len(DEVICE:aMeta), ;
               (MessageBeep(),.F.),.T.) ;
     OF oDlg

oPageIni:Disable()
oPageFin:Disable()

ACTIVATE MSDIALOG oDlg CENTERED 
#ENDIF

RETURN NIL

//----------------------------------------------------------------------------//

STATIC FUNCTION PrintPrv(oDlg, nOption, nPageIni, nPageEnd, aPrint)

#IFDEF PROTHEUS
#ELSE
LOCAL nFor, hPrinter, cDoc, aFiles
#ENDIF

#IFDEF PROTHEUS
	MSGSTOP(STR0030 ) //"Impressao nao implementada no PROTHEUS!"
#ELSE                       

If aPrint = NIL 
   aFiles   := DEVICE:aMeta
   hPrinter := DEVICE:hDC
   cDoc     := DEVICE:cDocument
Else
   aFiles   := aPrint
   hPrinter := GetPrintDefault( GetActiveWindow() )
   cDoc     := SY0->Y0_DOC
   If(nOption=2,nOption:=1,)
Endif

CursorWait()

StartDoc(hPrinter, cDoc )

DO CASE

CASE nOption == 1                           // All

     FOR nFor := 1 TO len(aFiles)
          StartPage(hPrinter)
          hMeta := GetMetaFile(aFiles[nFor])
          PlayMetaFile( hPrinter, hMeta )
          DeleteMetafile(hMeta)
          EndPage(hPrinter)
     NEXT

CASE nOption == 2                           // Current page

     StartPage(hPrinter)
     hMeta := oMeta1:hMeta
     PlayMetaFile( hPrinter, hMeta )
     EndPage(hPrinter)

CASE nOption == 3                           // Range

     FOR nFor := nPageIni TO nPageEnd
          StartPage(hPrinter)
          hMeta := GetMetaFile(aFiles[nFor])
          PlayMetaFile( hPrinter, hMeta )
          DeleteMetafile(hMeta)
          EndPage(hPrinter)
     NEXT

ENDCASE

EndDoc(hPrinter)
*PrnPortrait(hPrinter)
If aPrint = NIL 
   AvGrvPrint(cDoc,aFiles)
   oDlg:End()
Endif
   
CursorArrow()
             
#ENDIF

RETURN NIL

