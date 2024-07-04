#Include "AVERAGE.CH"
#Include "EEC.cH"
#Include "Protheus.CH"

Function ESSRS403()
Local cTp := ""

If Type('cTpReg') == "C" .And. !Empty(cTpReg)
   If RS403Tela(cTpReg,@cTp)
      RS403ManFFC(cTpReg,cTp)
   EndIf
EndIf

Return .T.

/*
Programa   : RS401ManFFC()
Objetivo   : Manutenção FFC
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 22/10/2012 11:52 
Revisao    : 
*/ 

Static Function RS403ManFFC(cTipoReg,cTipo)
Local cSeqPag := ""
Local nTipo := 1
Local cFiltro := "EJY->EJY_TPPROC=='"+cTipoReg+"'"
Local cNrFFC := ""
Local aOrd := SaveOrd({"EEQ","EL1"})

Private lRet := .F.

If !Empty( EJW->( DBFilter() ) )
   EJW->(DbClearFilter())
EndIf
   
If !Empty(cFiltro)
   EJW->(dbSetFilter(&("{||"+cFiltro+"}"),cFiltro))
EndIf  

EECAF300(cTipoReg,cTipo,@cNrFFC)

EJY->(dbClearFilter()) 

RestOrd(aOrd,.T.)

Return


Static Function RS403Tela(cTipoReg,cTipo)
Local nLin    := 15, nCol := 12
Local lRet    := .T.
Local nOpc    := 0
Local bOk     := {|| nOpc := 1, oDlg:End() }
Local bCancel := {|| lRet := .F.,oDlg:End() }
Local oDlg
Local cTitulo := "Definição de Tipo de Cambio"
Local aTipos  := ComboX3Box("EEQ_TIPO")

   aAdd(aTipos , "")

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 320,400 TO 480,785 OF oMainWnd PIXEL

    @ nLin, 6 To 65, 189 Label "Tipo de Cambio" Of oDlg Pixel
    nLin += 10
    @ nLin,nCol Say AvSX3("EEQ_TIPO", AV_TITULO) Pixel
    @ nLin,nCol ComboBox cTipo Items aTipos Size 80, 08 Pixel Of oDlg

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If nOpc == 1
      If Empty(cTipo)
         MsgInfo("Defina o tipo de cambio.","Atenção") 
         lRet := .F.
      EndIf
   EndIf

Return lRet