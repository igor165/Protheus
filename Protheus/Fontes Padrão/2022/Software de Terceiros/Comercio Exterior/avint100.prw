#include "AVINT100.CH"
#include "AVERAGE.CH"

/*
Programa   : AvInt100.prw
Objetivo   : Reúne funções de exibição do Log Viewer
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Obs        : 
*/

/*
Função     : AvLinkLog
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Exibe a tela principal do Log Viewer.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    : 
Obs.       :
*/
*------------------*
Function AvLinkLog()
*------------------*
Local nInc
Local oDlg
Local bOk     := {|| oDlg:End()},;
      bCancel := {|| oDlg:End()}
Local aButtons := {}, aSemSx3 := {}, aItemBrowse := {}
Private cTitulo := STR0006//"Action Log Viewer"
Private cNomArq1 := "", cNomArq2 := ""
Private aCampos := Array(EYF->(FCount()))
Private oSelActions

//Variáveis utilizadas nos filtros
Private cInt       := CriaVar("EYF_CODINT"),;
        lInt       := .F.,;
        cAction    := CriaVar("EYF_CODAC"),;
        lAction    := .F.,;
        aStatus    := {"", STR0029, STR0030, STR0031, STR0032},;//"Ação concluída"###"Ação não concluída"###"Contratação concluída"###"Contratação não concluída"     // GFP - 20/08/2012
        cStatus    := Space(20),;
        lStatus    := .F.,;
        cDesStatus := CriaVar("EYF_STATUS"),;
        dDt1       := CToD("  /  /  "),;
        lDt1       := .F.,;
        dDt2       := CToD("  /  /  "),;
        lDt2       := .F.,;
        cUser      := CriaVar("EYF_USER"),;
        lUser      := .F.

Begin Sequence
   
   aAdd(aSemSX3, {"TRB_ALI_WT", "C", 03, 0})
   aAdd(aSemSX3, {"TRB_REC_WT", "N", 10, 0})

   If Select("Wk_Action") == 0
      cNomArq1 := E_CriaTrab("EYF", aSemSx3, "Wk_Action")
   Else
      Wk_Action->(avzap())
   EndIf

   //aAdd(aButtons, {"AVG_DOC_VIEW", {|| AvLkDetMan() }, STR0007, STR0008})//"Service Log Viewer"###"Srv. Log"
   aAdd(aButtons, {"bmpvisual", {|| AvLkDetMan() }, STR0007, STR0008})//"Service Log Viewer"###"Srv. Log"
   //aAdd(aButtons, {"AVG_VIEW", {|| GetActions() }, STR0009, STR0010})//"Editar Opções de Filtro"##"Filtros"
   aAdd(aButtons, {"filtro1", {|| GetActions() }, STR0009, STR0010})//"Editar Opções de Filtro"##"Filtros"
   //aAdd(aButtons, {"AVG_PREF", {|| SrvLogPrefs() }, STR0011, STR0012})//"Alterar Preferências"###"Preferências"
   aAdd(aButtons, {"SelectAll", {|| SrvLogPrefs() }, STR0011, STR0012})//"Alterar Preferências"###"Preferências"

   aEval({"EYF_CODAC", "EYF_DESAC"}, {|x| aAdd(aItemBrowse, ColBrw(x, "Wk_Action"))})
   aEval(ArrayBrowse("EYF", "Wk_Action"), {|x| aAdd(aItemBrowse, x)} )   

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI;
                                        TO DLG_LIN_FIM-100,DLG_COL_FIM-100;
                                        OF oMainWnd PIXEL
        
    oSelActions := MsSelect():New("Wk_Action", , , aItemBrowse, , ,PosDlg(oDlg))
    oSelActions:bAval := {|| AvLkDetMan() }
    oSelActions:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    
   //A função GetActions alimenta a work com base nas opções de filtro escolhidas pelo usuário.
   Activate MsDialog oDlg On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons),GetActions()) CENTERED

End Sequence

If(File(cNomArq1+GetDBExtension()),FErase(cNomArq1+GetDBExtension()),)
If(File(cNomArq2+GetDBExtension()),FErase(cNomArq2+GetDBExtension()),)

Return Nil

/*
Função     : AvLkDetMan
Parâmetros : Nenhum
Retorno    : Nenhum
Objetivos  : Exibe os detalhes de uma ação registrada pelo log viewer
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    : 
Obs.       :
*/
*--------------------------*
Static Function AvLkDetMan()
*--------------------------*
Local bOk     := {|| oDlg:End()},;
      bCancel := {|| oDlg:End()}
Local oDlg
Local aOrd := SaveOrd("EYF"), aButtons := {}, aSemSx3 := {}, aItemBrowse := {}, aCposEnc := {}
Local nInc
Local oEnchoice, oMsSelect

Private cTitulo := STR0007//"Service Log Viewer"
Private aGets[0],aTela[0]

Begin Sequence
   
   If IsVazio("Wk_Action")
      MsgInfo(STR0028, STR0014)//"Nenhuma ação foi executada. Não será possível visualizar"###"Aviso"
      Break
   EndIf
   
   aAdd(aSemSX3, {"TRB_ALI_WT", "C", 03, 0})
   aAdd(aSemSX3, {"TRB_REC_WT", "N", 10, 0})
   
   If Select("Wk_Event") == 0
      cNomArq2 := E_CriaTrab("EYF", aSemSx3, "Wk_Event")
   Else
      Wk_Event->(avzap())
   EndIf

   EYF->(DbSetOrder(2))
   If EYF->(DbSeek(xFilial()+Wk_Action->EYF_ID))
      While EYF->(!Eof() .And. EYF_FILIAL+EYF_IDORI == xFilial()+Wk_Action->EYF_ID)
         If !Empty(EYF->EYF_CODEVE)
            Wk_Event->(DbAppend())
            AvReplace("EYF", "Wk_Event")
            Wk_Event->TRB_ALI_WT := "EYF"
            Wk_Event->TRB_REC_WT := EYF->(Recno())
         EndIf
         EYF->(DbSkip())
      EndDo
   EndIf
   Wk_Event->(DbGoTop())

   If IsVazio("Wk_Event")
      MsgInfo(STR0013, STR0014)//"Não foram executados eventos para a ação selecionada."###"Aviso"
      Break
   EndIf
   
   For nInc := 1 TO Wk_Action->(FCount())
      M->&(Wk_Action->(FieldName(nInc))) := Wk_Action->(FieldGet(nInc))
   Next nInc

   //Define botões da enchoice bar
   //aAdd(aButtons, {"AVG_SRV_VIEW", {|| LogViewer("DATA", STR0015) }, STR0015, STR0016})//"Data Log Viewer"###"Data Log"
   aAdd(aButtons, {"vernota", {|| LogViewer("DATA", STR0015) }, STR0015, STR0016})//"Data Log Viewer"###"Data Log"
   //aAdd(aButtons, {"AVG_ENV_VIEW", {|| LogViewer("ENVIRONMENT", STR0017) }, STR0017, STR0018})//"Environment Log Viewer"###"Env. Log"
   aAdd(aButtons, {"SduSeek", {|| LogViewer("ENVIRONMENT", STR0017) }, STR0017, STR0018})//"Environment Log Viewer"###"Env. Log"

   //Define campos da enchoice
   aCposEnc := {"EYF_ID", "EYF_CODAC", "EYF_DESAC", "EYF_DESSTA", "EYF_DATAI", "EYF_HORAI", "EYF_DATAF", "EYF_HORAF", "EYF_USER", "EYF_ARQXML"}
   //Define campos do browse
   aEval({"EYF_CODEVE", "EYF_CODSRV"}, {|x| aAdd(aItemBrowse, ColBrw(x, "Wk_Event"))})
   aEval(ArrayBrowse("EYF", "Wk_Event"), {|x| aAdd(aItemBrowse, x)} )
   
   
   EYF->(DbGoTo(Wk_Action->TRB_REC_WT))

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI;
                                        TO DLG_LIN_FIM-150,DLG_COL_FIM-150;
                                        OF oMainWnd PIXEL

    oEnchoice := MsMGet():New("EYF", Wk_Action->TRB_REC_WT, VISUALIZAR,,,, aCposEnc, PosDlgUp(oDlg))
    oEnchoice:oBox:Align := CONTROL_ALIGN_TOP
    
    oMsSelect := MsSelect():New("Wk_Event",,, aItemBrowse,,, PosDlgDown(oDlg))
    oMsSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

End Sequence

RestOrd(aOrd, .T.)

Return Nil

/*
Função     : GetActions(lNew)
Parâmetros : lNew - Indica se esta sendo executada pela primeira vez.
Retorno    : Nenhum
Objetivos  : Efetua query de filtros das ações registradas pelo Log Viewer
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    : 
Obs.       :
*/
*------------------------------*
Static Function GetActions(lNew)
*------------------------------*
Local aOrd := SaveOrd("EYF")
Local cQry := "", cCond := ""
Default lNew := .T.
Begin Sequence
   
   If !TelaGets()
      Break
   EndIf

   Wk_Action->(avzap())
   
  //GFP - 20/08/2012 - Ajuste para exibição de registro rejeitados. 
   #IfDef TOP
      cQry := "Select * From " + RetSqlName("EYF") + " Where " + If(!Empty(EYF->EYF_CODEVE)," EYF_CODEVE = '" + Space(AvSx3("EYF_CODEVE", AV_TAMANHO)) + "' And ","")
      
      cQry += " EYF_IDORI = '" + Space(AvSx3("EYF_IDORI", AV_TAMANHO)) + "' And "
      
      If lInt
         cQry += " EYF_CODAC In "
         cQry += "(Select EYF_CODAC From " + RetSqlName("EYF") + " Where EYF_FILIAL = '" + xFilial("EYF") + "' And "
         cQry += " EYF_CODINT = '" + cInt + "' And D_E_L_E_T_ <> '*') And "
      EndIf
      
      If lAction
         cQry += " EYF_CODAC = '" + cAction + "' And "
      EndIf
      
      If lStatus
         cQry += " EYF_DESSTA = '" + cStatus + "' And "
      EndIf
      
      If lDt1
         If !Empty(dDt1)
            cQry += " EYF_DATAI >= '" + DtoS(dDt1) + "' And "
         EndIf
      EndIf
      
      If lDt2
         If !Empty(dDt2)
            cQry += " EYF_DATAI <= '" + DtoS(dDt2) + "' And "
         EndIf
      EndIf
      
      If lUser
         cQry += " EYF_USER = '" + cUser + "' And "
      EndIf
      
      cQry += " EYF_FILIAL = '" + xFilial("EYF") + "' And D_E_L_E_T_ <> '*' "
      
      cQry := ChangeQuery(cQry)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QRY", .F., .T.)
      TCSetField("QRY", "EYF_DATAI", "D")
      TCSetField("QRY", "EYF_DATAF", "D")
      
      QRY->(DbEval({|| Wk_Action->(DbAppend(), AvReplace("QRY", "WK_Action"), TRB_ALI_WT := "EYF", TRB_REC_WT := QRY->(R_E_C_N_O_) ) }))
      QRY->(DbCloseArea())
      DbSelectArea("EYF")
   #Else
      EYF->(DbSeek(xFilial()))
      While EYF->(!Eof() .And. xFilial() == EYF_FILIAL)
         If lDt1 .And. !Empty(dDt1)
            EYF->(DbSetOrder(1))
            EYF->(DbSeek(xFilial()+DtoS(dDt1)), .T.)
            If EYF->(Eof())
               Exit
            EndIf
         EndIf
         
         If Empty(EYF->EYF_IDORI)
            EYF->(DbSkip())
            Loop
         EndIf
         
         If lDt2 .And. !Empty(dData2) .And. DToS(EYF->EYF_DATAI) > dData2
            If lDt1 .And. !Empty(dDt1)
               Exit
            Else
               EYF->(DbSkip())
               Loop
            EndIf
         EndIf
         
         If lAction .And. EYF->EYF_CODAC <> cAction
            EYF->(DbSkip())
            Loop
         EndIf
         
         If lInt .And. EYF->EYF_CODINT <> cCodInt
            EYF->(DbSkip())
            Loop
         EndIf
         
         If lUser .And. EYF->EYF_USER <> cCodUser
            EYF->(DbSkip())
            Loop
         EndIf
         
         If lStatus .And. EYF->EYF_STATUS <> cStatus
            EYF->(DbSkip())
            Loop
         EndIf
         
         Wk_Action->(DbAppend())
         AvReplace("EYF", "Wk_Action")
         Wk_Action->TRB_ALI_WT := "EYF"
         Wk_Action->TRB_REC_WT := EYF->(Recno())

         EYF->(DbSkip())
      EndDo
   #EndIf
   Wk_Action->(DbGoTop())
   oSelActions:oBrowse:Refresh()

End Sequence
RestOrd(aOrd, .T.)

Return Nil

/*
Função     : TelaGets
Parâmetros : Nenhum
Retorno    : Nenhum
Objetivos  : Exibe tela de opções de filtros do Log Viewer
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    : 
Obs.       :
*/
*-------------------------*
Static Function TelaGets()
*-------------------------*
Local lRet := .F.
Local nLin := 15, nCol1 := 12, nCol2 := 66
Local aBack
Local bSave := {|x| x[2]  := &(x[1]) }
Local bRest := {|x| &(x[1]) :=  x[2] }
Local bOk     := {|| lRet := .T., _oDlg:End() }
Local bCancel := {|| _oDlg:End() }
Private oCheck1, oCheck2, oCheck3, oCheck4, oCheck5, oCheck6
Private oEdit1, oEdit2, oEdit3, oEdit4, oEdit5
Private oCbBox1
Private _oDlg

aBack := {{"cInt"      ,},;
          {"lInt"      ,},;
          {"cAction"   ,},;
          {"lAction"   ,},;
          {"cStatus"   ,},;
          {"lStatus"   ,},;
          {"cDesStatus",},;
          {"dDt1"      ,},;
          {"lDt1"      ,},;
          {"dDt2"      ,},;
          {"lDt2"      ,},;
          {"cUser"     ,},;
          {"lUser"     ,}}

aEval(aBack, bSave)

//*** GFP 04/08/2011 - Alteração de tamanho de janela e posição de itens - M11.5
DEFINE MSDIALOG _oDlg TITLE cTitulo FROM 330,289 /*330,389*/ TO /*583,687*/ 643,687 OF oMainWnd PIXEL
    
    oPanel:= TPanel():New(0, 0, "", _oDlg,, .F., .F.,,, 90, 165) //MCF - 26/08/2015 - Ajustes Tela P12.
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
    
    @ nLin, 6 To 15*8, 195 /*145*/ Label STR0019 Of oPanel Pixel//"Opções de Filtro"
    nLin += 10
	@ nLin,nCol1 CheckBox oCheck1 Var lInt Prompt STR0020 ON CHANGE ObjChange("oCheck1") Size 048,008 PIXEL OF oPanel//"Integração"
	@ nLin,nCol2 MsGet    oEdit1  Var cInt  Size 087,009 PIXEL OF oPanel
	nLin += 15
	@ nLin,nCol1 CheckBox oCheck2 Var lAction Prompt STR0021  ON CHANGE ObjChange("oCheck2") Size 048,008 PIXEL OF oPanel//"Ação"
	@ nLin,nCol2 MsGet    oEdit2  Var cAction  Size 087,009 PIXEL OF oPanel
	nLin += 15
	@ nLin,nCol1 CheckBox oCheck3 Var lStatus Prompt STR0022 ON CHANGE ObjChange("oCheck3") Size 048,008 PIXEL OF oPanel//"Status"
	@ nLin,nCol2 ComboBox oCbBox1 Var cStatus Items aStatus Size 087,010 PIXEL OF oPanel
	nLin += 15
	@ nLin,nCol1 CheckBox oCheck4 Var lUser Prompt STR0023 ON CHANGE ObjChange("oCheck4") Size 048,008 PIXEL OF oPanel//"Usuário"
	@ nLin,nCol2 MsGet    oEdit3  Var cUser Size 087,009  PIXEL OF oPanel
	nLin += 15
	@ nLin,nCol1 CheckBox oCheck5 Var lDt1 Prompt STR0024 ON CHANGE ObjChange("oCheck5") Size 048,008 PIXEL OF oPanel//"Data Inicial"
	@ nLin,nCol2 MsGet    oEdit4  Var dDt1  Size 45,009 PIXEL OF oPanel HASBUTTON
	nLin += 15
	@ nLin,nCol1 CheckBox oCheck6 Var lDt2 Prompt STR0025 ON CHANGE ObjChange("oCheck6") Size 048,008 PIXEL OF oPanel//"Data Final"
	@ nLin,nCol2 MsGet    oEdit5  Var dDt2  Size 45,009 PIXEL OF oPanel HASBUTTON
	ObjChange(,.T.)

ACTIVATE MSDIALOG _oDlg On Init EnchoiceBar(_oDlg,bOk,bCancel) CENTERED

If !lRet
   aEval(aBack, bRest)
EndIf

Return lRet                                              

/*
Função     : ObjChange(cObj, lDisableAll)
Parâmetros : cObj - Nome do objeto
             lDisableAll - Desabilita todos os objetos
Retorno    : Nenhum
Objetivos  : Auxiliar na função TelaGets, controla alteração nas opções de tela
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    : 
Obs.       :
*/
*-------------------------------------------*
Static Function ObjChange(cObj, lDisableAll)
*-------------------------------------------*
Local aObj := {{"oCheck1", "lInt"   , "oEdit1" },;
               {"oCheck2", "lAction", "oEdit2" },;
               {"oCheck3", "lStatus", "oCbBox1"},;
               {"oCheck4", "lUser"  , "oEdit3" },;
               {"oCheck5", "lDt1"   , "oEdit4" },;
               {"oCheck6", "lDt2"   , "oEdit5" }}
Local i
Default lDisableAll := .F.

If lDisableAll
   For i := Len(aObj) To 1 Step -1
      ObjChange(aObj[i][1])
   Next
Else
   i := aScan(aObj, {|x| x[1] == cObj })
   If &(aObj[i][2])
      &(aObj[i][3] + ":Enable()" )
      &(aObj[i][3] + ":Refresh()")
      &(aObj[i][3] + ":SetFocus()")
   Else
      &(aObj[i][3] + ":Disable()")
      &(aObj[i][3] + ":Refresh()")
      &(aObj[i][1] + ":SetFocus()")
   EndIf
EndIf

Return Nil

/*
Função     : SrvLogPrefs
Parâmetros : Nenhum
Retorno    : Nenhum
Objetivos  : Exibe tela com opções de personalização de gravação de log, onde é possível definir se será gravado log do ambiente
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    : 
Obs.       :
*/
*-----------------------------*
Static Function SrvLogPrefs()
*-----------------------------*
Local nLin := 5, nCol := 12
Local lSystemLog := EasyGParam("MV_AVG0132",,.F.)
Local lRet := .F.
Local bOk := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local oDlg
Local oCheck1
Local oPanel

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 330,360 TO 485,730 OF oMainWnd PIXEL
    oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 26/08/2015 - Ajustes Tela P12.
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @ 5, 6 To 45, 182 Label STR0026 Of oPanel Pixel//"Preferências"
    
	@ 20,12 CheckBox oCheck1 Var lSystemLog Prompt STR0027 Size 160,08 PIXEL OF oPanel//"Gravar log do ambiente para os serviços não completados"

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

If lRet
   SetMv("MV_AVG0132", lSystemLog)
EndIf

Return Nil

/*
Função     : LogViewer(cLog, cTitTela)
Parâmetros : cLog - Tipo de log
             cTitTela - Título da tela exibida
Retorno    : Nenhum
Objetivos  : Exibe na tela o log escolhido pelo usuário
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    : ER - 25/09/2009. Tratamento para que as tabelas sejam carregadas
                              individualmete.
*/
*----------------------------------------*
Static Function LogViewer(cLog, cTitTela)
*----------------------------------------*
Default cTitTela := cTitulo

   EECView(AvLkGtLog(Wk_Event->EYF_ID, cLog), cTitTela)

Return Nil