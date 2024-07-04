#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#Include "TryException.ch"


User Function Teste()
    Local oDlg1 := nil
    Local nTS1Row   , nTS1Col, nTSWidth
   // Local nTG1Row   , nTG1Col, nTGWidth
    Local nTBRow    , nTBCol , nTBWidth   

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    
    DEFINE DIALOG oDlg1 TITLE OemToAnsi("Definição do Caminhão") FROM 0,0 TO nLinFim:=470, nColFim:=622 PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME)
    
    /* https://tdn.totvs.com/display/tec/Construtor+TPanel%3ANew */
    oPanel := tPanel():New()
    /* https://tdn.totvs.com/display/tec/TControl%3AAlign */    
    oPanel:Align:= 5
    oPanel:SetCss("Qlabel {" + (__cCorFundo:= " background: #e6ffe6; " ) + "}")
    
    oSay := TSay():New(nTS1Row:=10, nTS1Col:= 100, {|| "Teste HTML"}, oPanel,/*cPicture*/, /*oFont*/, , , , .T., , , nTSWidth:=60, 30)
    oSay:SetCss("QLabel {" + __cCorFundo + "color: #00ff00; font-size: 15pt")

    /*  https://tdn.totvs.com/display/tec/Construtor+TGet%3ANew#
    TGet():New( [ nRow ], [ nCol ], [ bSetGet ], [ oWnd ], [ nWidth ], [ nHeight ], [ cPict ], [ bValid ], [ nClrFore ], [ nClrBack ], [ oFont ], [ uParam12 ], [ uParam13 ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ bWhen ], [ uParam18 ], [ uParam19 ], [ bChange ], [ lReadOnly ], [ lPassword ], [ uParam23 ], [ cReadVar ], [ uParam25 ], [ uParam26 ], [ uParam27 ], [ lHasButton ], [ lNoButton ], [ uParam30 ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ], [ cPlaceHold ], [ lPicturePriority ], [ lFocSel ] )  */
    /*  https://tdn.totvs.com/display/tec/Construtor+TGet%3ANew#
    TGet():New( [ nRow ], [ nCol ], [ bSetGet ], [ oWnd ], [ nWidth ], [ nHeight ], [ cPict ], [ bValid ], [ nClrFore ], [ nClrBack ], [ oFont ], [ uParam12 ], [ uParam13 ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ bWhen ], [ uParam18 ], [ uParam19 ], [ bChange ], [ lReadOnly ], [ lPassword ], [ uParam23 ], [ cReadVar ], [ uParam25 ], [ uParam26 ], [ uParam27 ], [ lHasButton ], [ lNoButton ], [ uParam30 ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ], [ cPlaceHold ], [ lPicturePriority ], [ lFocSel ] )  */
    oTGet := TGet():New( nTG1Row:=85 /*nRow*/, nTG1Col:=40/*nCol*/, {|u|If(PCount()>0,cPlacaTGet:=u,cPlacaTGet)} /*bSetGet*/, oPanel/*oWnd*/,;
        nTGWidth:=240/*nWidth*/, /*nHeight*/ 50, "@! AAA-9N99"/*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/,/*lPixel*/.T., /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*bChange*/, .F. /*lReadOnly*/, .F./*lPassword*/, /*uParam23*/,;
        "cPlacaTGet" /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, /*lHasButton*/,;
        /*lNoButton*/, /*uParam30*/, /*cLabelText*/, /*nLabelPos Indica a posição da label, sendo 1=Topo e 2=Esquerda*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/, /*lPicturePriority*/, /*lFocSel*/.F. )
    oTGet:SetCss("QLineEdit {" + __cCorFundo + "color: #000; font-weight: bold; font-size: 72pt;" + (__cBorderMB:=" border: 2px solid green; border-radius: 20px; ") + "}")

    oT1_1Button := tButton():New(nTBRow:=170, nTBCol:=30, "CONFIRMAR (F10)", oPanel,  {|| nOpcA := 1,  U_Tela2Pesagem(cAlias, nReg, nOpc)/*, oDlg1:End()*/}, nTBWidth:=120, 40/*nHeight*/,,,, .T./*lPixel*/)
    oT1_1Button:SetCss("QPushButton {background : #2C2; color#FFF; margin: 2px; font-weight: bold; font-size: 14pt; border-radius: 15px; }")
    
    oT1_2Button := tButton():New(nTBRow, nTBCol+nTBWidth+15, "SAIR (ESC)", oPanel, {|| nOpcA := 1,oDlg1:End() }, nTBWidth, 40/*nHeight*/,,,, .T./*lPixel*/)
    oT1_2Button:SetCss(oT1_1Button:GetCss())

    SetKey( VK_F10, {|| U_Tela2Pesagem(cAlias, nReg, nOpc)/* , oDlg1:End() */ } )

    ACTIVATE DIALOG oDlg1 CENTERED

    If nOpcA == 0
        cPlacaTGet   := CriaVar( 'DA3_PLACA' , .F.)
        nQualPesagem := 0
        // Else
        //      Alert('[T1] CONFIRMAR')
    EndIf 
RETURN nil


