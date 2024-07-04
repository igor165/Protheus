#include 'totvs.ch'
#include 'Average.cH'
#include 'protheus.ch'
#include 'EDCAP400.ch'
#define GENERICO      "06"
#define NCM_GENERICA  "99999999"
#define KILOGRAMA     "KG"
#define KILOGRAMA2    "10"

Function EDCAP400()

Local aAlias := {"EDD","ED3","ED4","ED8","ED9"}
Local cAto := ""
Local cCpoFlag := "WORK_FLAG"

Local nOpc := 0
Local bOk := {|| nOpc := 1, oDlgApu:End()}
Local bCancel := {|| nOpc := 0, oDlgApu:End(), lRet := .T.}
Local lRet := .T.
Local oDlgApu
Local oFldExp, oFldImp, oFldInsCom, oFldInsImp, oPanel
Local aFolder1 := {STR0001,STR0002}//"Saldos Exportação","Saldos Insumos"
Local aFldInsumos := {STR0003,STR0004}//"Saldos Importados","Saldos Compras Nacionais"
Local aFolder2 := {STR0005,STR0006}//"Relação Importação X Exportação - Comprovados","Relação Importação X Exportação - Não Comprovados"
Private lInverte := .F.
Private cMarca := GetMark()
Private oMsSelExp, oMsSelImp, oMsSelComp, oMsSelC, oMsSelNC
Private oFolder, oFolder1, oFldInsumos
Private lCompNac := AvFlags("SEQMI")
Private lIndED9EDD := AvFlags("INDICEED9") .And. AvFlags("INDICEEDD")
Private lMsErroAuto := .F.
Private lMarcou := .F.
Private oEasyApuracao
Private lMultiFil:= AC400MultiFil()

Begin Sequence

   If !lIndED9EDD
      Return Nil
   EndIf

   aEstrutura := EstruturaWork(cCpoFlag)

   // Classe EasyWorks utilizada para criação das works
   If !FindFunction("EasyWorks")
      lRet := .F.
      Break
   EndIf

   cAto := SelectAto()
   If Empty(cAto)
      Break
   EndIf

   oEasyApuracao := EasyApuracao():New(cAto,aEstrutura,cCpoFlag)

   // Fecha as tabelas físicas
   oEasyApuracao:FechaTabelas(aAlias)

   If !oEasyApuracao:Reapurar()
      If !lMsErroAuto
         MsgInfo(STR0007,STR0008)//"Não foram encontrados divergencias nos saldos","Atenção"
      EndIf
      nOpc := 0
      Break
   EndIf

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlgApu TITLE STR0009 + AllTrim(cAto) FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Reapuração do Ato Concessório: "
      dbSelectArea(oEasyApuracao:oSldED3:cAlias)

      // Definindo o Painel
      oPanel := TPanel():New(0, 0, ,oDlgApu, , .F., .F., , , 10, 10, , )
      oPanel:Align:=CONTROL_ALIGN_ALLCLIENT

      // Definindo os Folders de apresentação do saldos
      oFolder := TFolder():New(,,aFolder1,aFolder1,oPanel,,,,.T.,.F.,,)
      aEval(oFolder:aControls,{|x| x:SetFont(oDlgApu:oFont) })
      oFolder:Align := CONTROL_ALIGN_ALLCLIENT
      //oFolder:bSetOption := {|| RefreshAba(1)}
      oFolder:bChange := {|| RefreshAba(1)}
      oFldExp := oFolder:aDialogs[1] // Folder de exportação
      oFldImp := oFolder:aDialogs[2] // Folder de importação

      // Definindo os Foldes de apresentação das importações
      oFldInsumos := TFolder():New(,,aFldInsumos,aFldInsumos,oFldImp,,,,.T.,.F.,,)
      oFldInsumos:Align := CONTROL_ALIGN_ALLCLIENT
      //oFldInsumos:bSetOption := {|| RefreshAba(2)}
      oFldInsumos:bChange := {|| RefreshAba(2)}
      oFldInsImp := oFldInsumos:aDialogs[1] // Folder dos produtos importados
      oFldInsCom := oFldInsumos:aDialogs[2] // Folder dos produtos compras nacionais

      // Definindo os Foldes de apresentação das comprovações
      oFolder1 := TFolder():New(,,aFolder2,aFolder2,oPanel,,,,.T.,.F.,,)
      aEval(oFolder1:aControls,{|x| x:SetFont(oDlgApu:oFont) })
      oFolder1:Align := CONTROL_ALIGN_BOTTOM
      //oFolder1:bSetOption := {|| RefreshAba(3)}
      oFolder1:bChange := {|| RefreshAba(3)}
      oFldRelC := oFolder1:aDialogs[1] // Folder das comprovados
      oFldRelNC := oFolder1:aDialogs[2] // Folder das não comprovados

      // MsSelect para saldo exportação
      oMsSelExp := MsSelect():New(oEasyApuracao:oSldED3:cAlias,cCpoFlag,,CposSaldos(2),@lInverte,@cMarca,PosDlg(oFldExp),,,oFldExp)
      oMsSelExp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelExp:bAval := {|| MarcaDesmarca(cCpoFlag)}

      // MsSelect para saldo dos produtos das Importaçãos
      oMsSelImp := MsSelect():New(oEasyApuracao:oSldED4:cAlias,cCpoFlag,,CposSaldos(1),@lInverte,@cMarca,PosDlg(oFldImp),,,oFldInsImp)
      oMsSelImp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelImp:bAval := {|| MarcaDesmarca(cCpoFlag)}

      // MsSelect para saldo dos produtos das Compras Nacionais
      oMsSelComp := MsSelect():New(oEasyApuracao:oSldED4:cAlias,cCpoFlag,,CposSaldos(3),@lInverte,@cMarca,PosDlg(oFldImp),,,oFldInsCom)
      oMsSelComp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oMsSelComp:bAval := {|| MarcaDesmarca(cCpoFlag)}

      // MsSelect para exportação X importação - Comprovados
      oMsSelC := MsSelect():New(oEasyApuracao:oWorkComp:cAlias,,,CposSaldos(0),@lInverte,@cMarca,PosDlg(oFldRelC),,,oFldRelC)
      oMsSelC:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

      // MsSelect para exportação X importação - Não Comprovados
      oMsSelNC := MsSelect():New(oEasyApuracao:oWorkComp:cAlias,,,CposSaldos(0),@lInverte,@cMarca,PosDlg(oFldRelNC),,,oFldRelNC)
      oMsSelNC:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

      /*Eval(oFolder:bSetOption)
      Eval(oFldInsumos:bSetOption)
      Eval(oFolder1:bSetOption)*/
      Eval(oFolder:bChange)
      Eval(oFldInsumos:bChange)
      Eval(oFolder1:bChange)

      //oFldInsumos:bChange := oFldInsumos:bSetOption
      //oFolder1:bChange := oFolder1:bSetOption

   ACTIVATE MSDIALOG oDlgApu ON INIT EnchoiceBar(oDlgApu,bOk,bCancel,,oEasyApuracao:aButtons)

   If nOpc == 1 .And. lMarcou .And. MsgYesNo(STR0010,STR0008)//"Deseja atualizar os saldos marcados?","Atenção"
      If (lRet := oEasyApuracao:SalvarSaldo())
         MsgInfo(STR0011,STR0008)//"Alteração realizada com sucesso.","Atenção"
      EndIf
   EndIf

End Sequence

// Deleta todas as Works de apresentação
If ValType(oEasyApuracao) == "O"
   oEasyApuracao:oWorks:CloseWorks()
EndIf

Return Nil

/*
Programa   : SelectAto()
Objetivo   : Janela de escolha do ato para reapuração dos saldos
Retorno    : cAto - Ato selecionado pelo usuário
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function SelectAto()
Local bOk := {|| lRet := ValidAto(cAto), If(lRet,oDlg:End(),nil)}
Local bCancel := {|| lRet := .F., oDlg:End()}
Local cAto := Space(AvSx3("ED0_AC",3))
Local nInferior := 130
Local nDireita := 380
Local nLin := 3.2
Local nCol := 2
Local oDlg
Local lRet := .T.

Begin Sequence

   Define MsDialog oDlg Title STR0012 From 0, 0 To nInferior, nDireita Pixel Of oMainWnd //"Seleção do Ato Concessório"
 	  @ nLin   ,nCol SAY STR0013//"Ato Concessório"
      @ nLin++ ,nCol+6 MSGET cAto SIZE 100,08 OF oDlg F3 "ED0A"
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

   If !lRet
      cAto := Space(AvSx3("ED0_AC",3))
   Endif

End Sequence

Return cAto

/*
Programa   : ValidAto()
Parametro  : cAto - Ato selecionado pelo usuário
Objetivo   : Validação do ato concessorio
Retorno    : lRet - .T. Ok.
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function ValidAto(cAto)
Local lRet := .F.
Local aOrd := SaveOrd({"ED0"})
Local cMsg := ""

Begin Sequence

   If Empty(cAto)
      Break
   EndIf

   ED0->(DbSetOrder(2))
   If !ED0->(DbSeek(xFilial("ED0")+AvKey(cAto,"ED0_AC")))
      Break
   ElseIf !Empty(ED0->ED0_DT_ENC)
      cMsg := CHR(13)+CHR(10)+STR0014//"Ato Concessório encerrado."
      Break
   EndIf

   lRet := .T.

End Sequence

If !lRet
   Msginfo(STR0016 + cMsg,STR0008)//"Informe um Ato Concessório correto."//"Atenção"
EndIf

RestOrd(aOrd)

Return lRet

/*
Programa   : MarcaDesmarca(cCampo,lTodos)
Parametros : cAlias - Tabela de apresentação dos saldos
             cCampo - Campo de flag
             lTodos - Marca ou desmarca todos os registros
Objetivo   : Janela de escolha do saldo que será atualizado
Retorno    : -
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function MarcaDesmarca(cCampo,lTodos)
Local nRec := 0
Local cAtribui
Local cAlias
Default lTodos := .F.

Begin Sequence

If oFolder:nOption == 1
   cAlias := oEasyApuracao:oSldED3:cAlias
ElseIf oFolder:nOption == 2
   cAlias := oEasyApuracao:oSldED4:cAlias
EndIf

If lTodos

   nRec    := (cAlias)->(RecNo())

   cAtribui := Space(2)

    If Empty((cAlias)->&(cCampo))
       cAtribui := cMarca
       lMarcou  := .T.
    EndIf

    (cAlias)->(dbGotop())
    While (cAlias)->(!Eof())
       (cAlias)->&(cCampo) := cAtribui
       (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbGoTo(nRec))

Else


   If !Empty((cAlias)->&(cCampo))
      (cAlias)->&(cCampo) := Space(2)
   Else
      If !Empty(cMarca) .And. !(cAlias)->(EOF())
         (cAlias)->&(cCampo) := cMarca
         lMarcou := .T.
      EndIf
   EndIf

EndIf

End Sequence

Return Nil

/*
Programa   : RefreshAba(nFolder)
Parametros : nFolder - Folder de apresentação - 1: Folder dos saldos de exportação (ED3)
                                                2: Folder dos saldos da importação (ED4)
                                                3: Folder das relações de exportação e importação (EDD)
Objetivo   : Atualiza as MsSelect dos folders
Retorno    : -
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function RefreshAba(nFolder)
Local cCond := ""

Begin Sequence

   If nFolder == 1 .Or. nFolder == 2

      If oFolder:nOption == 1

         oMsSelExp:oBrowse:Hide()
         oMsSelExp:oBrowse:Refresh()
         oMsSelExp:oBrowse:Show()
         (oMsSelExp:oBrowse:cAlias)->(DbGoTop())
         oMsSelExp:oBrowse:Refresh()

      ElseIf oFolder:nOption == 2

         If oFldInsumos:nOption == 1  // Produtos importados
            (oMsSelImp:oBrowse:cAlias)->(DbGoTop())
            If !Empty((oMsSelImp:oBrowse:cAlias)->(DBFilter()))
               (oMsSelImp:oBrowse:cAlias)->(DBCLEARFILTER())
            EndIf
            cCond := oMsSelImp:oBrowse:cAlias+"->WORKCOMPRA == 'N' "
            (oMsSelImp:oBrowse:cAlias)->(DBSetFilter({|| &cCond}, cCond ))
            Eval(oMsSelImp:oBrowse:bGoTop)
            oMsSelImp:oBrowse:Refresh()
            oMsSelImp:oBrowse:Show()
         ElseIf oFldInsumos:nOption == 2 // Compra Nacionais
            (oMsSelComp:oBrowse:cAlias)->(DbGoTop())
            If !Empty((oMsSelComp:oBrowse:cAlias)->(DBFilter()))
               (oMsSelComp:oBrowse:cAlias)->(DBCLEARFILTER())
            EndIf
            cCond := oMsSelComp:oBrowse:cAlias+"->WORKCOMPRA == 'S' "
            (oMsSelComp:oBrowse:cAlias)->(DBSetFilter({|| &cCond}, cCond ))
            Eval(oMsSelComp:oBrowse:bGoTop)
            oMsSelComp:oBrowse:Refresh()
            oMsSelComp:oBrowse:Show()
         EndIf
      EndIf
   EndIf

   If nFolder == 3
      If oFolder1:nOption == 1  // Produtos importados
         (oMsSelC:oBrowse:cAlias)->(DbGoTop())
         If !Empty((oMsSelC:oBrowse:cAlias)->(DBFilter()))
            (oMsSelC:oBrowse:cAlias)->(DBCLEARFILTER())
         EndIf
         cCond := oMsSelC:oBrowse:cAlias+"->EDD_COMPRO == 'S' "
         (oMsSelC:oBrowse:cAlias)->(DBSetFilter({|| &cCond}, cCond ))
         Eval(oMsSelC:oBrowse:bGoTop)
         oMsSelC:oBrowse:Refresh()
         oMsSelC:oBrowse:Show()
      ElseIf oFolder1:nOption == 2 // Compra Nacionais
         (oMsSelNC:oBrowse:cAlias)->(DbGoTop())
         If !Empty((oMsSelNC:oBrowse:cAlias)->(DBFilter()))
            (oMsSelNC:oBrowse:cAlias)->(DBCLEARFILTER())
         EndIf
         cCond := oMsSelNC:oBrowse:cAlias+"->EDD_COMPRO == 'N' "
         (oMsSelNC:oBrowse:cAlias)->(DBSetFilter({|| &cCond}, cCond ))
         Eval(oMsSelNC:oBrowse:bGoTop)
         oMsSelNC:oBrowse:Refresh()
         oMsSelNC:oBrowse:Show()
      EndIf
   EndIf

End Sequence

Return Nil

/*
Programa   : CposSaldos(nMsSelect)
Parametros : nMsSelect - MsSelect que esta sendo usado
Objetivo   : Campos da work de apresentação da MsSelect dos saldos de exportação e importação
Retorno    : aCampos - {Nome do campo, "" , Nome da coluna da MsSelect}
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function CposSaldos(nMsSelect)
Local aCampos := {}

Begin Sequence

   If nMsSelect == 2 // Saldos Exportação
      aAdd(aCampos,{"WORK_FLAG"   ,"","",AvSX3("ED0_OK",6)})
      aAdd(aCampos,{"ED3_PROD"    ,"",AvSX3("ED3_PROD",5),AvSX3("ED3_PROD",6)})
      aAdd(aCampos,{"ED3_SEQSIS"  ,"",AvSX3("ED3_SEQSIS",5),AvSX3("ED3_SEQSIS",6)})
      aAdd(aCampos,{"ED3_UMPROD"  ,"",AvSX3("ED3_UMPROD",5),AvSX3("ED3_UMPROD",6)})
      aAdd(aCampos,{"ED3_QTD"     ,"",AvSX3("ED3_QTD",5),AvSX3("ED3_QTD",6)})
      aAdd(aCampos,{"ED3_NCM"     ,"",AvSX3("ED3_NCM",5),AvSX3("ED3_NCM",6)})
      aAdd(aCampos,{"ED3_UMNCM"   ,"",AvSX3("ED3_UMNCM",5),AvSX3("ED3_UMNCM",6)})
      aAdd(aCampos,{"ED3_QTDNCM"  ,"",AvSX3("ED3_QTDNCM",5),AvSX3("ED3_QTDNCM",6)})
      aAdd(aCampos,{"WORKTITULO"  ,"",STR0017,AvSX3("X3_TITULO",6)})//"Campo"
      aAdd(aCampos,{"ED3_VAL_SE"   ,"",AvSX3("ED3_VAL_SE",5),AvSX3("ED3_VAL_SE",6)})
      aAdd(aCampos,{"WORKVLDSEO"   ,"",STR0049,AvSX3("ED3_VAL_SE",6)})//"Vl. Calc. s/Cob"
      aAdd(aCampos,{"ED3_VAL_CO"   ,"",AvSX3("ED3_VAL_CO",5),AvSX3("ED3_VAL_CO",6)})
      aAdd(aCampos,{"WORKVLDCCO"   ,"",STR0050,AvSX3("ED3_VAL_CO",6)})//"Vl. Calc. c/Cob"
      aAdd(aCampos,{"ED3_SAL_CO"   ,"",AvSX3("ED3_SAL_CO",5),AvSX3("ED3_SAL_CO",6)})
      aAdd(aCampos,{"WORKSLDCCO"  ,"",STR0018,AvSX3("ED3_SAL_CO",6)})//"Vl.Calc.c/Cob"
      aAdd(aCampos,{"ED3_SAL_SE"   ,"",AvSX3("ED3_SAL_SE",5),AvSX3("ED3_SAL_SE",6)})
      aAdd(aCampos,{"WORKSLDCSE"  ,"",STR0019,AvSX3("ED3_SAL_SE",6)})//"Vl.Calc.s/Cob"
      aAdd(aCampos,{"WORKSALDO"   ,"",STR0020,AvSX3("ED3_QTD",6)})//"Saldo"
      aAdd(aCampos,{"WORKSLDCAL"  ,"",STR0021,AvSX3("ED3_QTD",6)})//"Saldo Calcul."
   ElseIf nMsSelect == 1// Saldos Importação
      aAdd(aCampos,{"WORK_FLAG"   ,"","",AvSX3("ED0_OK",6)})
      aAdd(aCampos,{"ED4_ITEM"    ,"",AvSX3("ED4_ITEM",5),AvSX3("ED4_ITEM",6)})
      aAdd(aCampos,{"ED4_SEQSIS"  ,"",AvSX3("ED4_SEQSIS",5),AvSX3("ED4_SEQSIS",6)})
      aAdd(aCampos,{"ED4_UMITEM"  ,"",AvSX3("ED4_UMITEM",5),AvSX3("ED4_UMITEM",6)})
      aAdd(aCampos,{"ED4_QTD"     ,"",AvSX3("ED4_QTD",5),AvSX3("ED4_QTD",6)})
      aAdd(aCampos,{"ED4_QTDCAL"  ,"",AvSX3("ED4_QTDCAL",5),AvSX3("ED4_QTDCAL",6)})
      aAdd(aCampos,{"ED4_VL_DI"  ,"",AvSX3("ED4_VL_DI",5),AvSX3("ED4_VL_DI",6)})
      aAdd(aCampos,{"WORKVLRCDI"  ,"",STR0022,AvSX3("ED4_VL_DI",6)})//"Vl.Calc. DI"
      aAdd(aCampos,{"ED4_VL_LI"  ,"",AvSX3("ED4_VL_LI",5),AvSX3("ED4_VL_LI",6)})
      aAdd(aCampos,{"WORKVLRCLI"  ,"",STR0023,AvSX3("ED4_VL_LI",6)})//"Vl.Calc. LI"
      aAdd(aCampos,{"ED4_NCM"     ,"",AvSX3("ED4_NCM",5),AvSX3("ED4_NCM",6)})
      aAdd(aCampos,{"ED4_UMNCM"   ,"",AvSX3("ED4_UMNCM",5),AvSX3("ED4_UMNCM",6)})
      aAdd(aCampos,{"ED4_QTDNCM"  ,"",AvSX3("ED4_QTDNCM",5),AvSX3("ED4_QTDNCM",6)})
      aAdd(aCampos,{"WORKTITULO"  ,"",STR0019,AvSX3("X3_TITULO",6)})//"Campo"
      aAdd(aCampos,{"WORKSALDO"   ,"",STR0020,AvSX3("ED4_QTD",6)})//"Saldo"
      aAdd(aCampos,{"WORKSLDCAL"  ,"",STR0021,AvSX3("ED4_QTD",6)})//"Saldo Calcul."
   ElseIf nMsSelect == 3 // Saldos Compra Nacionais
      aAdd(aCampos,{"WORK_FLAG"   ,"","",AvSX3("ED0_OK",6)})
      aAdd(aCampos,{"ED4_ITEM"    ,"",AvSX3("ED4_ITEM",5),AvSX3("ED4_ITEM",6)})
      If lCompNac
         aAdd(aCampos,{"ED4_SEQMI"  ,"",AvSX3("ED4_SEQMI",5),AvSX3("ED4_SEQMI",6)})
      Else
         aAdd(aCampos,{"ED4_SEQSIS"  ,"",AvSX3("ED4_SEQSIS",5),AvSX3("ED4_SEQSIS",6)})
      EndIf
      aAdd(aCampos,{"ED4_UMITEM"  ,"",AvSX3("ED4_UMITEM",5),AvSX3("ED4_UMITEM",6)})
      aAdd(aCampos,{"ED4_QTD"     ,"",AvSX3("ED4_QTD",5),AvSX3("ED4_QTD",6)})
      aAdd(aCampos,{"ED4_QTDCAL"  ,"",AvSX3("ED4_QTDCAL",5),AvSX3("ED4_QTDCAL",6)})
      aAdd(aCampos,{"ED4_VL_DI"  ,"",AvSX3("ED4_VL_DI",5),AvSX3("ED4_VL_DI",6)})
      aAdd(aCampos,{"WORKVLRCDI"  ,"","Vl.Calc. DI",AvSX3("ED4_VL_DI",6)})
      aAdd(aCampos,{"ED4_VL_LI"  ,"",AvSX3("ED4_VL_LI",5),AvSX3("ED4_VL_LI",6)})
      aAdd(aCampos,{"WORKVLRCLI"  ,"","Vl.Calc. LI",AvSX3("ED4_VL_LI",6)})
      aAdd(aCampos,{"ED4_NCM"     ,"",AvSX3("ED4_NCM",5),AvSX3("ED4_NCM",6)})
      aAdd(aCampos,{"ED4_UMNCM"   ,"",AvSX3("ED4_UMNCM",5),AvSX3("ED4_UMNCM",6)})
      aAdd(aCampos,{"ED4_QTDNCM"  ,"",AvSX3("ED4_QTDNCM",5),AvSX3("ED4_QTDNCM",6)})
      aAdd(aCampos,{"WORKTITULO"  ,"",STR0019,AvSX3("X3_TITULO",6)})//"Campo"
      aAdd(aCampos,{"WORKSALDO"   ,"",STR0020,AvSX3("ED4_QTD",6)})//"Saldo"
      aAdd(aCampos,{"WORKSLDCAL"  ,"",STR0021,AvSX3("ED4_QTD",6)})//"Saldo Calcul."
   ElseIf nMsSelect == 0 // Comprovações
      aAdd(aCampos,{"EDD_AC","",AvSX3("EDD_AC",5),AvSX3("EDD_AC",6)})
      aAdd(aCampos,{"EDD_PD","",AvSX3("EDD_PD",5),AvSX3("EDD_PD",6)})
      aAdd(aCampos,{"EDD_HAWB","",AvSX3("EDD_HAWB",5),AvSX3("EDD_HAWB",6)})
      aAdd(aCampos,{"EDD_PO_NUM","",AvSX3("EDD_PO_NUM",5,AvSX3("EDD_PO_NUM",6))})
      aAdd(aCampos,{"EDD_INVOIC","",AvSX3("EDD_INVOIC",5),AvSX3("EDD_INVOIC",6)})
      aAdd(aCampos,{"EDD_ITEM","",AvSX3("EDD_ITEM",5),AvSX3("EDD_ITEM",6)})
      aAdd(aCampos,{"EDD_POSICA","",AvSX3("EDD_POSICA",5),AvSX3("EDD_POSICA",6)})
      aAdd(aCampos,{"EDD_SEQSII","",AvSX3("EDD_SEQSII",5),AvSX3("EDD_SEQSII",6)})
      If lCompNac
         aAdd(aCampos,{"EDD_SEQMI","",AvSX3("EDD_SEQMI",5),AvSX3("EDD_SEQMI",6)})
      EndIf
      aAdd(aCampos,{"EDD_PROD","",AvSX3("EDD_PROD",5),AvSX3("EDD_PROD",6)})
      aAdd(aCampos,{"EDD_PREEMB","",AvSX3("EDD_PREEMB",5),AvSX3("EDD_PREEMB",6)})
      aAdd(aCampos,{"EDD_PEDIDO","",AvSX3("EDD_PEDIDO",5),AvSX3("EDD_PEDIDO",6)})
      aAdd(aCampos,{"EDD_SEQUEN","",AvSX3("EDD_SEQUEN",5),AvSX3("EDD_SEQUEN",6)})
      aAdd(aCampos,{"EDD_SEQSIE","",AvSX3("EDD_SEQSIE",5),AvSX3("EDD_SEQSIE",6)})
      aAdd(aCampos,{"EDD_QTD","",AvSX3("EDD_QTD",5),AvSX3("EDD_QTD",6)})
      aAdd(aCampos,{"EDD_DTREG","",AvSX3("EDD_DTREG",5),AvSX3("EDD_DTREG",6)})
      aAdd(aCampos,{"EDD_DTRE","",AvSX3("EDD_DTRE",5),AvSX3("EDD_DTRE",6)})
      aAdd(aCampos,{"EDD_QTD_OR","",AvSX3("EDD_QTD_OR",5),AvSX3("EDD_QTD_OR",6)})
      aAdd(aCampos,{"EDD_QTD_EX","",AvSX3("EDD_QTD_EX",5),AvSX3("EDD_QTD_EX",6)})
      aAdd(aCampos,{"EDD_LEAD","",AvSX3("EDD_LEAD",5),AvSX3("EDD_LEAD",6)})
      aAdd(aCampos,{"EDD_PGI_NU","",AvSX3("EDD_PGI_NU",5),AvSX3("EDD_PGI_NU",6)})
   EndIf
End Sequence

Return aClone(aCampos)

/*
Programa   : EstruturaWork(cCpoFlag)
Parametros : cCpoFlag - Campo da flag da work de apresentação
Objetivo   : Estrutura das Works dos saldos
Retorno    : aCampos - {cAlias, aCampos, aIndice}
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function EstruturaWork(cCpoFlag)
Local aEstrutura := {}
Local aWorkED3 := {}
Local aWorkED4 := {}
Local aIndexED3 := {}
Local aIndexED4 := {}
Local aCposED3 := {}
Local aCposED4 := {}
Local aRelED3ED4 := {}
Local aWorkComp := {}
Local aIndexComp := {}

Begin Sequence

   aAdd(aWorkComp,{"EDD_COMPRO",{"C",1,0}})
   aAdd(aIndexComp,"EDD_COMPRO")

   aAdd(aWorkED3,{cCpoFlag,"ED0_OK"})
   aAdd(aWorkED3,{"ED0_PD","ED3_PD"})
   aAdd(aWorkED3,{"ED3_CNPJIM","ED3_CNPJIM"})
   aAdd(aWorkED3,{"ED3_DT_VAL","ED3_DT_VAL"})
   aAdd(aWorkED3,{"ED0_AC","ED3_AC"})
   aAdd(aWorkED3,{"ED3_NCM","ED3_NCM"})
   aAdd(aWorkED3,{"ED3_UMNCM","ED3_UMNCM"})
   aAdd(aWorkED3,{"ED3_PROD","ED3_PROD"})
   aAdd(aWorkED3,{"ED3_UMPROD","ED3_UMPROD"})
   aAdd(aWorkED3,{"ED3_SEQSIS","ED3_SEQSIS"})
   aAdd(aWorkED3,{"ED3_ANEXO","ED3_ANEXO"})
   aAdd(aWorkED3,{"ED3_PESO","ED3_PESO"})
   aAdd(aWorkED3,{"ED3_ALTERA","ED3_ALTERA"})
   aAdd(aWorkED3,{"ED3_VAL_EM","ED3_VAL_EM"})
   aAdd(aWorkED3,{"ED3_PERCAG","ED3_PERCAG"})
   aAdd(aWorkED3,{"ED3_VALCOM","ED3_VALCOM"})
   aAdd(aWorkED3,{"ED3_VAL_CO","ED3_VAL_CO"})
   aAdd(aWorkED3,{"ED3_VAL_SE","ED3_VAL_SE"})
   aAdd(aWorkED3,{"WORKVLDCCO","ED3_VAL_CO"})
   aAdd(aWorkED3,{"WORKVLDSEO","ED3_VAL_SE"})
   aAdd(aWorkED3,{"ED3_QTD","ED3_QTD"})
   aAdd(aWorkED3,{"ED3_QTDNCM","ED3_QTDNCM"})
   aAdd(aWorkED3,{"WORKALIAS","X2_ARQUIVO"})
   aAdd(aWorkED3,{"WORKDESC","X2_NOME"})
   aAdd(aWorkED3,{"WORKCAMPO","X3_CAMPO"})
   aAdd(aWorkED3,{"WORKTITULO","X3_TITULO"})
   aAdd(aWorkED3,{"WORKSALDO","ED3_SALDO"})
   aAdd(aWorkED3,{"WORKSLDCAL","ED3_SALDO"})
   aAdd(aWorkED3,{"ED3_SAL_CO","ED3_SAL_CO"})
   aAdd(aWorkED3,{"WORKSLDCCO","ED3_SAL_CO"})
   aAdd(aWorkED3,{"ED3_SAL_SE","ED3_SAL_SE"})
   aAdd(aWorkED3,{"WORKSLDCSE","ED3_SAL_SE"})
   aAdd(aIndexED3,"ED0_PD+ED3_NCM+ED3_PROD+STR(ED3_PERCAG,5,2)+ED3_UMNCM")
   aAdd(aIndexED3,"ED0_AC+ED3_SEQSIS")
   aAdd(aIndexED3,"ED3_CNPJIM+ED3_PROD+DTOS(ED3_DT_VAL)")
   aAdd(aIndexED3,"ED3_CNPJIM+ED3_NCM+ED3_PROD+DTOS(ED3_DT_VAL)")
   aAdd(aIndexED3,"ED0_PD+ED3_ANEXO")
   aAdd(aIndexED3,"ED0_PD+ED3_UMNCM+ED3_NCM+ED3_PROD+STR(ED3_PERCAG,5,2)")
   aAdd(aIndexED3,"ED0_PD+ED3_NCM+ED3_PROD+ED3_UMNCM")
   aAdd(aIndexED3,"ED0_PD+ED3_PROD")

   aAdd(aWorkED4,{cCpoFlag,"ED0_OK"})
   aAdd(aWorkED4,{"ED0_PD","ED4_PD"})
   aAdd(aWorkED4,{"ED4_CNPJIM","ED4_CNPJIM"})
   aAdd(aWorkED4,{"ED4_DT_VAL","ED4_DT_VAL"})
   aAdd(aWorkED4,{"ED0_AC","ED4_AC"})
   aAdd(aWorkED4,{"ED4_NCM","ED4_NCM"})
   aAdd(aWorkED4,{"ED4_ITEM","ED4_ITEM"})
   aAdd(aWorkED4,{"ED4_SEQSIS","ED4_SEQSIS"})
   If lCompNac
      aAdd(aWorkED4,{"ED4_SEQMI","ED4_SEQMI"})
   EndIf
   aAdd(aWorkED4,{"ED4_QTD","ED4_QTD"})
   aAdd(aWorkED4,{"ED4_QTDCAL","ED4_QTDCAL"})
   aAdd(aWorkED4,{"ED4_UMITEM","ED4_UMITEM"})
   aAdd(aWorkED4,{"ED4_VALEMB","ED4_VALEMB"})
   aAdd(aWorkED4,{"ED4_VALCAL","ED4_VALCAL"})
   aAdd(aWorkED4,{"ED4_PERCPE","ED4_PERCPE"})
   aAdd(aWorkED4,{"ED4_VL_LI","ED4_VL_LI"})
   aAdd(aWorkED4,{"ED4_VL_DI","ED4_VL_DI"})
   aAdd(aWorkED4,{"ED4_QTDNCM","ED4_QTDNCM"})
   aAdd(aWorkED4,{"ED4_CAMB","ED4_CAMB"})
   aAdd(aWorkED4,{"ED4_UMNCM","ED4_UMNCM"})
   aAdd(aWorkED4,{"ED4_ANEXO","ED4_ANEXO"})
   aAdd(aWorkED4,{"ED4_PESO","ED4_PESO"})
   aAdd(aWorkED4,{"ED4_ALTERA","ED4_ALTERA"})
   aAdd(aWorkED4,{"WORKALIAS","X2_ARQUIVO"})
   aAdd(aWorkED4,{"WORKDESC","X2_NOME"})
   aAdd(aWorkED4,{"WORKCAMPO","X3_CAMPO"})
   aAdd(aWorkED4,{"WORKTITULO","X3_TITULO"})
   aAdd(aWorkED4,{"WORKSALDO"  ,"ED4_QT_LI"})
   aAdd(aWorkED4,{"WORKSLDCAL","ED4_QT_LI"})
   aAdd(aWorkED4,{"WORKVLRCLI","ED4_VL_LI"})
   aAdd(aWorkED4,{"WORKVLRCDI","ED4_VL_DI"})
   aAdd(aWorkED4,{"WORKCOMPRA",{"C",1,0}})
   aAdd(aIndexED4,"ED0_PD+ED4_NCM+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2)+ED4_UMNCM")
   aAdd(aIndexED4,"ED0_AC+ED4_SEQSIS")
   aAdd(aIndexED4,"ED4_CNPJIM+ED4_ITEM+ED4_CAMB+DTOS(ED4_DT_VAL)")
   aAdd(aIndexED4,"ED4_CNPJIM+ED4_NCM+ED4_ITEM+ED4_CAMB+DTOS(ED4_DT_VAL)")
   aAdd(aIndexED4,"ED0_PD+ED4_ANEXO")
   aAdd(aIndexED4,"ED0_PD+ED4_UMNCM+ED4_NCM+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2)")
   aAdd(aIndexED4,"ED0_PD+ED4_NCM+ED4_ITEM+ED4_UMNCM")

   // Campos de Dados da ED3
   aAdd(aCposED3,{"HEADER",{"ED0_PD","ED3_PD"}})
   aAdd(aCposED3,{"HEADER",{"ED3_CNPJIM","ED3_CNPJIM"}})
   aAdd(aCposED3,{"HEADER",{"ED3_DT_VAL","ED3_DT_VAL"}})
   aAdd(aCposED3,{"HEADER",{"ED0_AC","ED3_AC"}})
   aAdd(aCposED3,{"HEADER",{"ED3_NCM","ED3_NCM"}})
   aAdd(aCposED3,{"HEADER",{"ED3_UMNCM","ED3_UMNCM"}})
   aAdd(aCposED3,{"HEADER",{"ED3_PROD","ED3_PROD"}})
   aAdd(aCposED3,{"HEADER",{"ED3_UMPROD","ED3_UMPROD"}})
   aAdd(aCposED3,{"HEADER",{"ED3_SEQSIS","ED3_SEQSIS"}})
   aAdd(aCposED3,{"HEADER",{"ED3_ANEXO","ED3_ANEXO"}})
   aAdd(aCposED3,{"HEADER",{"ED3_PESO","ED3_PESO"}})
   aAdd(aCposED3,{"HEADER",{"ED3_ALTERA","ED3_ALTERA"}})
   aAdd(aCposED3,{"HEADER",{"ED3_VAL_EM","ED3_VAL_EM"}})
   aAdd(aCposED3,{"HEADER",{"ED3_PERCAG","ED3_PERCAG"}})
   aAdd(aCposED3,{"HEADER",{"ED3_VALCOM","ED3_VALCOM"}})
   aAdd(aCposED3,{"HEADER",{"ED3_VAL_CO","ED3_VAL_CO"}})
   aAdd(aCposED3,{"HEADER",{"ED3_SAL_CO","ED3_SAL_CO"}})
   aAdd(aCposED3,{"HEADER",{"WORKSLDCCO","ED3_SAL_CO"}})
   aAdd(aCposED3,{"HEADER",{"ED3_VAL_SE","ED3_VAL_SE"}})
   aAdd(aCposED3,{"HEADER",{"ED3_SAL_SE","ED3_SAL_SE"}})
   aAdd(aCposED3,{"HEADER",{"WORKSLDCSE","ED3_SAL_SE"}})
   aAdd(aCposED3,{"HEADER",{"ED3_QTD","ED3_QTD"}})
   aAdd(aCposED3,{"HEADER",{"ED3_QTDNCM","ED3_QTDNCM"}})
   aAdd(aCposED3,{"HEADER",{"WORKSLDVCO","ED3_SAL_CO"}})
   aAdd(aCposED3,{"HEADER",{"WORKSLDVSE","ED3_SAL_SE"}})
   aAdd(aCposED3,{"HEADER",{"WORKVLDCCO","ED3_VAL_CO"}})
   aAdd(aCposED3,{"HEADER",{"WORKVLDSEO","ED3_VAL_SE"}})

   //Campos de interno da ED3
   aAdd(aCposED3,{"INTERNO",{"WORKALIAS",""}})
   aAdd(aCposED3,{"INTERNO",{"WORKDESC",""}})
   aAdd(aCposED3,{"INTERNO",{"WORKCAMPO",""}})
   aAdd(aCposED3,{"INTERNO",{"WORKTITULO",""}})

   //Campos de Saldo da ED3
   aAdd(aCposED3,{"DETAIL",{"WORKSALDO","ED3_SALDO" },{"WORKSLDCAL","ED3_SALDO"}})
   aAdd(aCposED3,{"DETAIL",{"WORKSALDO","ED3_SALNCM"},{"WORKSLDCAL","ED3_SALNCM"}})

   // Campos de Dados da ED4
   aAdd(aCposED4,{"HEADER",{"ED0_PD","ED4_PD"}})
   aAdd(aCposED4,{"HEADER",{"ED4_CNPJIM","ED4_CNPJIM"}})
   aAdd(aCposED4,{"HEADER",{"ED4_DT_VAL","ED4_DT_VAL"}})
   aAdd(aCposED4,{"HEADER",{"ED0_AC","ED4_AC"}})
   aAdd(aCposED4,{"HEADER",{"ED4_NCM","ED4_NCM"}})
   aAdd(aCposED4,{"HEADER",{"ED4_ITEM","ED4_ITEM"}})
   aAdd(aCposED4,{"HEADER",{"ED4_SEQSIS","ED4_SEQSIS"}})
   If lCompNac
      aAdd(aCposED4,{"HEADER",{"ED4_SEQMI","ED4_SEQMI"}})
   EndIf
   aAdd(aCposED4,{"HEADER",{"ED4_QTD","ED4_QTD"}})
   aAdd(aCposED4,{"HEADER",{"ED4_QTDCAL","ED4_QTDCAL"}})
   aAdd(aCposED4,{"HEADER",{"ED4_UMITEM","ED4_UMITEM"}})
   aAdd(aCposED4,{"HEADER",{"ED4_VALEMB","ED4_VALEMB"}})
   aAdd(aCposED4,{"HEADER",{"ED4_VALCAL","ED4_VALCAL"}})
   aAdd(aCposED4,{"HEADER",{"ED4_PERCPE","ED4_PERCPE"}})
   aAdd(aCposED4,{"HEADER",{"ED4_VL_LI","ED4_VL_LI"}})
   aAdd(aCposED4,{"HEADER",{"ED4_VL_DI","ED4_VL_DI"}})
   aAdd(aCposED4,{"HEADER",{"ED4_QTDNCM","ED4_QTDNCM"}})
   aAdd(aCposED4,{"HEADER",{"ED4_CAMB","ED4_CAMB"}})
   aAdd(aCposED4,{"HEADER",{"ED4_UMNCM","ED4_UMNCM"}})
   aAdd(aCposED4,{"HEADER",{"ED4_ANEXO","ED4_ANEXO"}})
   aAdd(aCposED4,{"HEADER",{"ED4_PESO","ED4_PESO"}})
   aAdd(aCposED4,{"HEADER",{"ED4_ALTERA","ED4_ALTERA"}})
   aAdd(aCposED4,{"HEADER",{"WORKVLRCLI","ED4_VL_LI"}})
   aAdd(aCposED4,{"HEADER",{"WORKVLRCDI","ED4_VL_DI"}})

   //Campos de interno da ED4
   aAdd(aCposED4,{"INTERNO",{"WORKALIAS",""}})
   aAdd(aCposED4,{"INTERNO",{"WORKDESC",""}})
   aAdd(aCposED4,{"INTERNO",{"WORKCAMPO",""}})
   aAdd(aCposED4,{"INTERNO",{"WORKTITULO",""}})

   // Campos de Saldo da ED4
   aAdd(aCposED4,{"DETAIL",{"WORKSALDO","ED4_QT_LI"},{"WORKSLDCAL","ED4_QT_LI"}})
   aAdd(aCposED4,{"DETAIL",{"WORKSALDO","ED4_QT_DI"},{"WORKSLDCAL","ED4_QT_DI"}})
   aAdd(aCposED4,{"DETAIL",{"WORKSALDO","ED4_SNCMLI"},{"WORKSLDCAL","ED4_SNCMLI"}})
   aAdd(aCposED4,{"DETAIL",{"WORKSALDO","ED4_SNCMDI"},{"WORKSLDCAL","ED4_SNCMDI"}})
   aAdd(aCposED4,{"DETAIL",{"WORKSALDO","ED4_SQTDEX"},{"WORKSLDCAL","ED4_SQTDEX"}})
   aAdd(aCposED4,{"DETAIL",{"WORKSALDO","ED4_SNCMEX"},{"WORKSLDCAL","ED4_SNCMEX"}})

   aAdd(aRelED3ED4,aCposED3)
   aAdd(aRelED3ED4,aCposED4)

   aAdd(aEstrutura,{"ED3","WKSLDED3",aWorkED3,aIndexED3})
   aAdd(aEstrutura,{"ED4","WKSLDED4",aWorkED4,aIndexED4})
   aAdd(aEstrutura,{"EDD","WKCOMPRO",aWorkComp,aIndexComp})
   aAdd(aEstrutura,{"RELACAO",aRelED3ED4})

End Sequence

Return aClone(aEstrutura)

/*
Classe    : EasyApuracao
Objetivo  : Realizar a manutenção de apuração de saldos do Drawback
Autor     : Bruno Akyo Kubagawa
Data/Hora : 17/10/11
Obs.      :
*/
Class EasyApuracao From AvObject

   Data oWorks // Todos os objetos da works criadas
   Data oTabelas // Todos os objetos das tabelas

   // Objeto da work de apresentação dos saldos
   Data oSldED3 // Work dos saldos ED3
   Data oSldED4 // Work dos saldos ED4
   Data oWorkComp // Work das comprovações
   Data oSldSW5
   Data oSldSW8

   // Objetos das works que serão cópias das tabelas
   Data oWorkEDD // Relação Exportação P/ Import
   Data oWorkED3 // Saldos dos Produtos a Exportar
   Data oWorkED4 // Saldos dos Itens a Importar
   Data oWorkED8 // Manut de DI Externa
   Data oWorkED9 // Manut de RE Externa
   Data oWorkEDH // Baixas insumos a comprovar
   Data oWKEYU // Work Dados Fabr. Itens Embarque Exp
   Data oWorkSW5
   Data oWorkSW8 // Itens de Invoices
   Data oWorkEYU // Dados Fabr. Itens Embarque Exp
   Data oWorkIp // Itens Embarque
   Data oWorkEDG

   Data aWorks // Vetor com nome da Alias, nome da Work, filtro, indice do filtro
   Data aAlias
   Data aDadosEDC // Armazena a data da vinculação, alias, recno
                  // Obs.:No caso de manutenção de DI ou no RE Externos está sendo armazenados o ato e a sequencia
   Data aDadosEEC // Armazena a data da vinculação, alias, Ato
   Data aDadosEIC // Armazena a data da vinculação, alias, Ato

   Data aButtons // Botoes da EnchoiceBar
   Data aDescTabelas // Vetor com as descrições das tabelas
   Data cAto // Ato escolhido pelo usuario
   Data cPd // PEdido do Drawback
   Data cModalidade // Modalidade do Ato
   Data cSldED3 // Nome da Work de saldo da ED3
   Data aCposED3 // Campo da Work de saldo da ED3
   Data aIndED3 // indice da Work de saldo da ED3
   Data cSldED4 // Nome da Work de saldo da ED4
   Data aCposED4 // Nome da Work de saldo da ED4
   Data aIndED4 // indice da Work de saldo da ED4
   Data cWorkComp // Nome da Work de comprovações
   Data aCposComp // Campo da Work de comprovações
   Data aIndComp // Índice da Work de comprovações
   Data aRelED3ED4 // Relação de campos para apresentação
   Data cCpoFlag // Campo da Flag
   Data aDadosEDD // Dados que restaram na Work para excluir na tabela
   Data aItens // Itens importados
   Data lItFabric // Flag para Itens do embarque Fabricante

   Method New(cAto,aEstrutura) Constructor
   Method CriarWork() // Cria a Work de saldos
   Method CarregaWork() // Carrega a Work de saldos
   Method CriarTabelas() // Cria as cópias das tabelas ED3, ED4, ED8, ED9, EDD.
   Method CarregaTabelas() // Realiza a cópia das tabelas fisícas para as works de acordo com o ato selecionado
   Method ZapWorks() // Limpa as works

   Method CarregaRegistro(cAlias) // Carrega o registro para a função do execauto
   Method FechaTabelas(aAlias) // Fecha todas as tabelas físicas

   Method RetButtons() // Retorna aButtons para enchoiceBar
   Method SalvarSaldo() // Salva o saldo selecionado
   Method SalvarEDF() // Salva a tabela EDF
   Method Reapurar() // Realiza a reapuracao dos saldos
   Method EasyDesEDC() // Desvincula todos as comprovações Drawback
   Method EasyVinEDC() // Vincula todos as comprovações Drawback
   Method EasyDesEEC() // Desvincula todos as comprovações Exportação
   Method EasyVinEEC() // Vincula todos as comprovações Exportação
   Method EasyDesEIC() // Desvincula todos as comprovações Importação
   Method EasyVinEIC() // Vincula todos as comprovações Importação
   Method LimpaSldo() // Limpa saldo e valores
   Method RetStatus() // Retorna se o item é importado ou compra nacional de acordo com o vetor aItens
   Method ComparaEDD() // Retorna .T. se estiver igual ou .F. se houver divergencia
   Method CargaEYUEDG()

EndClass

//------------------------------------------------------------------------------------------------------------------
Method New(cAto,aEstrutura,cCpoFlag) Class EasyApuracao
Local nPos
Default cAto := ""
Default aEstrutura := {}

   // Herança
   _Super:New()

   // Metodo da Classe AvObjet para indicara a Classe
   Self:setClassName("EasyApuracao")
   Self:aButtons := Self:RetButtons()
   Self:aWorks := {}
   Self:aAlias := {}
   Self:cAto := cAto
   Self:aDescTabelas := {}
   Self:cModalidade := ""
   Self:cPd := ""
   Self:cCpoFlag := cCpoFlag
   Self:aDadosEDC := {}
   Self:aDadosEEC := {}
   Self:aDadosEIC := {}
   Self:aDadosEDD := {}
   Self:aItens := {}
   Self:lItFabric := EasyGParam("MV_AVG0138",,.F.)

   If (nPos := aScanInfo(aEstrutura,1,"ED3")) > 0
      Self:cSldED3 := aEstrutura[nPos][2]
      Self:aCposED3 := aEstrutura[nPos][3]
      Self:aIndED3 := aEstrutura[nPos][4]
   EndIf

   If (nPos := aScanInfo(aEstrutura,1,"ED4")) > 0
      Self:cSldED4 := aEstrutura[nPos][2]
      Self:aCposED4 := aEstrutura[nPos][3]
      Self:aIndED4 := aEstrutura[nPos][4]
   EndIf

   If (nPos := aScanInfo(aEstrutura,1,"EDD")) > 0
      Self:cWorkComp := aEstrutura[nPos][2]
      Self:aCposComp := aEstrutura[nPos][3]
      Self:aIndComp := aEstrutura[nPos][4]
   EndIf

   If (nPos := aScanInfo(aEstrutura,1,"RELACAO")) > 0
      Self:aRelED3ED4 := aEstrutura[nPos][2]
   EndIf

   // Criação das works de apresentação
   // Criação das cópias das tabelas
   Processa({|| Self:CriarWork(),Self:CriarTabelas()},STR0024)//"Criando arquivos de trabalho..."

Return Self

//------------------------------------------------------------------------------------------------------------------
//Revisão: wfs - 18/12/13
//         tratamento multifilial
Method CriarTabelas() Class EasyApuracao
Local cDriver := "DBFCDX"

Begin Sequence

   Self:oTabelas := EasyWorks()

   //Criando work da tabela EDD
   Self:oWorkEDD := Self:oTabelas:NewWork()
   Self:oWorkEDD:cAlias := "RepEDD"
   Self:oWorkEDD:lFilial := .T.
   Self:oWorkEDD:aCampos := {{"EDD_RECOLD" ,"N", 10, 0,""}}
   Self:oWorkEDD:cTabela := "EDD"
   Self:oWorkEDD:lAddIndex := .T.
   Self:oWorkEDD:aIndex := {}
   Self:oWorkEDD:cDriver := cDriver
   Self:oWorkEDD:lVirtuais := .F.
   Self:oWorkEDD:lMemo := .F.
   Self:oWorkEDD:lShared  := .F.
   Self:oWorkEDD:Create()
   aAdd(Self:aAlias,{Self:oWorkEDD:cTabela,Self:oWorkEDD:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkEDD:cTabela,Self:oWorkEDD:cAlias,xFilial("EDD") + AvKey(Self:cAto,"ED0_AC"),"EDD_FILIAL+EDD_AC",1,"_RECOLD"}) //EDD_FILIAL+EDD_AC+EDD_PREEMB+EDD_ITEM+DTOS(EDD_DTREG) //comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkEDD:cTabela,Self:oWorkEDD:cAlias, AvKey(Self:cAto,"ED0_AC"),"EDD_FILIAL+EDD_AC",1,"_RECOLD"}) //EDD_FILIAL+EDD_AC+EDD_PREEMB+EDD_ITEM+DTOS(EDD_DTREG)

   //Criando work da tabela ED3
   Self:oWorkED3 := Self:oTabelas:NewWork()
   Self:oWorkED3:cAlias := "RepED3"
   Self:oWorkED3:lFilial := .T.
   Self:oWorkED3:aCampos := {{"ED3_RECNO" ,"N", 10, 0,""}}
   Self:oWorkED3:cTabela := "ED3"
   Self:oWorkED3:lAddIndex := .T.
   Self:oWorkED3:aIndex := {}
   Self:oWorkED3:cDriver := cDriver
   Self:oWorkED3:lVirtuais := .F.
   Self:oWorkED3:lMemo := .F.
   Self:oWorkED3:lShared  := .F.
   Self:oWorkED3:Create()
   aAdd(Self:aAlias,{Self:oWorkED3:cTabela,Self:oWorkED3:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkED3:cTabela,Self:oWorkED3:cAlias,xFilial("ED3") + AvKey(Self:cAto,"ED0_AC"),"ED3_FILIAL+ED3_AC",2,"_RECNO"}) //ED3_FILIAL+ED3_AC+ED3_SEQSIS //comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkED3:cTabela,Self:oWorkED3:cAlias,AvKey(Self:cAto,"ED0_AC"),"ED3_FILIAL+ED3_AC",2,"_RECNO"}) //ED3_FILIAL+ED3_AC+ED3_SEQSIS

   //Criando work da tabela ED4
   Self:oWorkED4 := Self:oTabelas:NewWork()
   Self:oWorkED4:cAlias := "RepED4"
   Self:oWorkED4:lFilial := .T.
   Self:oWorkED4:aCampos := {{"ED4_RECNO" ,"N", 10, 0,""}}
   Self:oWorkED4:cTabela := "ED4"
   Self:oWorkED4:lAddIndex := .T.
   Self:oWorkED4:aIndex := {}
   Self:oWorkED4:cDriver := cDriver
   Self:oWorkED4:lVirtuais := .F.
   Self:oWorkED4:lMemo := .F.
   Self:oWorkED4:lShared  := .F.
   Self:oWorkED4:Create()
   aAdd(Self:aAlias,{Self:oWorkED4:cTabela,Self:oWorkED4:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkED4:cTabela,Self:oWorkED4:cAlias,xFilial("ED4") + AvKey(Self:cAto,"ED0_AC"),"ED4_FILIAL+ED4_AC",2,"_RECNO"}) //ED4_FILIAL+ED4_AC+ED4_SEQSIS // comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkED4:cTabela,Self:oWorkED4:cAlias,AvKey(Self:cAto,"ED0_AC"),"ED4_FILIAL+ED4_AC",2,"_RECNO"}) //ED4_FILIAL+ED4_AC+ED4_SEQSIS
   //Criando work da tabela ED8
   Self:oWorkED8 := Self:oTabelas:NewWork()
   Self:oWorkED8:cAlias := "RepED8"
   Self:oWorkED8:lFilial := .T.
   Self:oWorkED8:aCampos := {{"ED8_RECNO" ,"N", 10, 0,""}}
   Self:oWorkED8:cTabela := "ED8"
   Self:oWorkED8:lAddIndex := .T.
   Self:oWorkED8:aIndex := {}
   Self:oWorkED8:cDriver := cDriver
   Self:oWorkED8:lVirtuais := .F.
   Self:oWorkED8:lMemo := .F.
   Self:oWorkED8:lShared  := .F.
   Self:oWorkED8:Create()
   aAdd(Self:aAlias,{Self:oWorkED8:cTabela,Self:oWorkED8:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkED8:cTabela,Self:oWorkED8:cAlias,xFilial("ED8") + AvKey(Self:cAto,"ED0_AC"),"ED8_FILIAL+ED8_AC",3,"_RECNO"}) //ED8_FILIAL+ED8_AC+ED8_SEQSIS //comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkED8:cTabela,Self:oWorkED8:cAlias,AvKey(Self:cAto,"ED0_AC"),"ED8_FILIAL+ED8_AC",3,"_RECNO"}) //ED8_FILIAL+ED8_AC+ED8_SEQSIS

   //Criando work da tabela ED9
   Self:oWorkED9 := Self:oTabelas:NewWork()
   Self:oWorkED9:cAlias := "RepED9"
   Self:oWorkED9:lFilial := .T.
   Self:oWorkED9:aCampos := {{"ED9_RECNO" ,"N", 10, 0,""}}
   Self:oWorkED9:cTabela := "ED9"
   Self:oWorkED9:lAddIndex := .T.
   Self:oWorkED9:aIndex := {}
   Self:oWorkED9:cDriver := cDriver
   Self:oWorkED9:lVirtuais := .F.
   Self:oWorkED9:lMemo := .F.
   Self:oWorkED9:lShared  := .F.
   Self:oWorkED9:Create()
   aAdd(Self:aAlias,{Self:oWorkED9:cTabela,Self:oWorkED9:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkED9:cTabela,Self:oWorkED9:cAlias,xFilial("ED9") + AvKey(Self:cAto,"ED0_AC"),"ED9_FILIAL+ED9_AC",3,"_RECNO"}) //ED9_FILIAL+ED9_AC+ED9_POSICA //comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkED9:cTabela,Self:oWorkED9:cAlias, AvKey(Self:cAto,"ED0_AC"),"ED9_FILIAL+ED9_AC",3,"_RECNO"}) //ED9_FILIAL+ED9_AC+ED9_POSICA

   //Criando work da tabela EDH
   Self:oWorkEDH := Self:oTabelas:NewWork()
   Self:oWorkEDH:cAlias := "RepEDH"
   Self:oWorkEDH:lFilial := .T.
   Self:oWorkEDH:aCampos := {}
   Self:oWorkEDH:cTabela := "EDH"
   Self:oWorkEDH:lAddIndex := .T.
   Self:oWorkEDH:aIndex := {}
   Self:oWorkEDH:cDriver := cDriver
   Self:oWorkEDH:lVirtuais := .F.
   Self:oWorkEDH:lMemo := .F.
   Self:oWorkEDH:lShared  := .F.
   Self:oWorkEDH:Create()
   aAdd(Self:aAlias,{Self:oWorkEDH:cTabela,Self:oWorkEDH:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkEDH:cTabela,Self:oWorkEDH:cAlias,xFilial("EDH") + AvKey(Self:cAto,"ED0_AC"),"EDH_FILIAL+EDH_AC",2,""}) // EDH_FILIAL+EDH_AC+EDH_SEQSIS+DTOS(EDH_DTOCOR) //comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkEDH:cTabela,Self:oWorkEDH:cAlias, AvKey(Self:cAto,"ED0_AC"),"EDH_FILIAL+EDH_AC",2,""}) // EDH_FILIAL+EDH_AC+EDH_SEQSIS+DTOS(EDH_DTOCOR)

   //Retorna possiveis erros encontrados
   Self:Error(Self:oWorkEDD:aError)
   Self:Error(Self:oWorkED3:aError)
   Self:Error(Self:oWorkED4:aError)
   Self:Error(Self:oWorkED8:aError)
   Self:Error(Self:oWorkED9:aError)
   Self:Error(Self:oWorkEDH:aError)

   //Criando work da tabela SW5
   Self:oWorkSW5 := Self:oTabelas:NewWork()
   Self:oWorkSW5:cAlias := "RepSW5"
   Self:oWorkSW5:lFilial := .T.
   Self:oWorkSW5:aCampos := {{"SW5_RECOLD" ,"N", 10, 0,""}}
   Self:oWorkSW5:cTabela := "SW5"
   Self:oWorkSW5:lAddIndex := .T.
   Self:oWorkSW5:aIndex := {}
   Self:oWorkSW5:cDriver := cDriver
   Self:oWorkSW5:lVirtuais := .F.
   Self:oWorkSW5:lMemo := .F.
   Self:oWorkSW5:lShared  := .F.
   Self:oWorkSW5:Create()
   aAdd(Self:aAlias,{Self:oWorkSW5:cTabela,Self:oWorkSW5:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkSW5:cTabela,Self:oWorkSW5:cAlias,xFilial("SW5") + AvKey(Self:cAto,"ED0_AC"),"W5_FILIAL+W5_AC",9,"_RECOLD"}) // W5_FILIAL+W5_AC+W5_COD_I //comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkSW5:cTabela,Self:oWorkSW5:cAlias, AvKey(Self:cAto,"ED0_AC"),"W5_FILIAL+W5_AC",9,"_RECOLD"}) // W5_FILIAL+W5_AC+W5_COD_I

   //Criando work da tabela SW8
   Self:oWorkSW8 := Self:oTabelas:NewWork()
   Self:oWorkSW8:cAlias := "RepSW8"
   Self:oWorkSW8:lFilial := .T.
   Self:oWorkSW8:aCampos := {{"SW8_RECOLD" ,"N", 10, 0,""}}
   Self:oWorkSW8:cTabela := "SW8"
   Self:oWorkSW8:lAddIndex := .T.
   Self:oWorkSW8:aIndex := {}
   Self:oWorkSW8:cDriver := cDriver
   Self:oWorkSW8:lVirtuais := .F.
   Self:oWorkSW8:lMemo := .F.
   Self:oWorkSW8:lShared  := .F.
   Self:oWorkSW8:Create()
   aAdd(Self:aAlias,{Self:oWorkSW8:cTabela,Self:oWorkSW8:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkSW8:cTabela,Self:oWorkSW8:cAlias,xFilial("SW8") + AvKey(Self:cAto,"ED0_AC"),"W8_FILIAL+W8_AC",5,"_RECOLD"}) // W8_FILIAL+W8_AC+W8_COD_I //comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkSW8:cTabela,Self:oWorkSW8:cAlias, AvKey(Self:cAto,"ED0_AC"),"W8_FILIAL+W8_AC",5,"_RECOLD"}) // W8_FILIAL+W8_AC+W8_COD_I

   //Criando work da tabela WorkIp
   Self:oWorkIp := Self:oTabelas:NewWork()
   Self:oWorkIp:cAlias := "RepEE9"
   Self:oWorkIp:lFilial := .T.
   Self:oWorkIp:aCampos := {{"EE9_RECOLD" ,"N", 10, 0,""}}
   Self:oWorkIp:cTabela := "EE9"
   Self:oWorkIp:lAddIndex := .T.
   Self:oWorkIp:aIndex := {}
   Self:oWorkIp:cDriver := cDriver
   Self:oWorkIp:lVirtuais := .F.
   Self:oWorkIp:lMemo := .F.
   Self:oWorkIp:lShared  := .F.
   Self:oWorkIp:Create()
   aAdd(Self:aAlias,{"WorkIp",Self:oWorkIp:cAlias})
   //aAdd(Self:aWorks,{Self:oWorkIp:cTabela,Self:oWorkIp:cAlias,xFilial("EE9") + AvKey(Self:cAto,"ED0_AC"),"EE9_FILIAL+EE9_ATOCON",10,"_RECOLD"}) // EE9_FILIAL+EE9_ATOCON+EE9_FASEDR+EE9_COD_I //comentado por wfs em 18/12/13
   aAdd(Self:aWorks,{Self:oWorkIp:cTabela,Self:oWorkIp:cAlias, AvKey(Self:cAto,"ED0_AC"),"EE9_FILIAL+EE9_ATOCON",10,"_RECOLD"}) // EE9_FILIAL+EE9_ATOCON+EE9_FASEDR+EE9_COD_I

   //Criando work da tabela EYU
   Self:oWorkEYU := Self:oTabelas:NewWork()
   Self:oWorkEYU:cAlias := "RepEYU"
   Self:oWorkEYU:lFilial := .T.
   Self:oWorkEYU:aCampos := {}
   Self:oWorkEYU:cTabela := "EYU"
   Self:oWorkEYU:lAddIndex := .T.
   Self:oWorkEYU:aIndex := {}
   Self:oWorkEYU:cDriver := cDriver
   Self:oWorkEYU:lVirtuais := .F.
   Self:oWorkEYU:lMemo := .F.
   Self:oWorkEYU:lShared  := .F.
   Self:oWorkEYU:Create()
   aAdd(Self:aAlias,{Self:oWorkEYU:cTabela,Self:oWorkEYU:cAlias})

   //Criando work da tabela WKEYU
   Self:oWKEYU := Self:oTabelas:NewWork()
   Self:oWKEYU:cAlias := "RepWKEYU"
   Self:oWKEYU:lFilial := .T.
   Self:oWKEYU:aCampos := {}
   Self:oWKEYU:cTabela := "EYU"
   Self:oWKEYU:lAddIndex := .T.
   Self:oWKEYU:aIndex := {}
   Self:oWKEYU:cDriver := cDriver
   Self:oWKEYU:lVirtuais := .F.
   Self:oWKEYU:lMemo := .F.
   Self:oWKEYU:lShared  := .F.
   Self:oWKEYU:Create()
   aAdd(Self:aAlias,{"WKEYU",Self:oWKEYU:cAlias})

   // Criando work da tabela EDG
   Self:oWorkEDG := Self:oTabelas:NewWork()
   Self:oWorkEDG:cAlias := "RepEDG"
   Self:oWorkEDG:lFilial := .T.
   Self:oWorkEDG:aCampos := {{"EDG_RECNO"  ,"N", 10, 0,""},;
                             {"EDG_FLAG"   ,"L", 01, 0,""}}
   Self:oWorkEDG:cTabela := "EDG"
   Self:oWorkEDG:lAddIndex := .T.
   Self:oWorkEDG:aIndex := {"EDG_SEQEMB+EDG_ITEM"}
   Self:oWorkEDG:cDriver := cDriver
   Self:oWorkEDG:lVirtuais := .F.
   Self:oWorkEDG:lMemo := .F.
   Self:oWorkEDG:lShared  := .F.
   Self:oWorkEDG:Create()
   aAdd(Self:aAlias,{"WorkEDG",Self:oWorkEDG:cAlias})

   Self:Error(Self:oWorkIp:aError)
   Self:Error(Self:oWorkSW5:aError)
   Self:Error(Self:oWorkSW8:aError)
   Self:Error(Self:oWorkEYU:aError)
   Self:Error(Self:oWKEYU:aError)
   Self:Error(Self:oWorkEDG:aError)

End Sequence

Return Nil

//------------------------------------------------------------------------------------------------------------------
//Revisão: wfs - 18/12/13
//         tratamento multifilial
Method CarregaTabelas() Class EasyApuracao
Local j := 0
Local k := 0
Local cAlias := ""
Local cAliasWork := ""
Local aOrd := SaveOrd({"SX2"})
Local lSeek := .F.
Local nOrder := 0
Local cChave := ""
Local aFil:= {}

Begin Sequence

   If Empty(Self:aWorks)
      Break
   EndIf

   SX2->(DBSetOrder(1))
   For j := 1 To Len(Self:aWorks)
      cAlias := Self:aWorks[j][1]
      cAliasWork := Self:aWorks[j][2]
      //cSeek := Self:aWorks[j][3] //comentado por wfs 18/12/13
      cChave := Self:aWorks[j][4]
      nOrder := Self:aWorks[j][5]
      cCampoRec := Self:aWorks[j][6]

      If !Self:ZapWorks(cAliasWork)
         Break
      EndIf

      If !Empty(cAlias) .And. (lSeek := SX2->(DbSeek(AvKey(cAlias,"X2_CHAVE"))))
         DbSelectArea(cAlias)
         DbSelectArea(cAliasWork)

         // Guardando as descrições das tabelas para gravar na tabela EDF
         aAdd(Self:aDescTabelas,{cAlias,AllTrim(X2Nome())})

         (cAlias)->(DbSetOrder(nOrder))

         //Tratamento multifilial
         aFil:= iif(lMultiFil, AClone(AvgSelectFil(.F., cAlias)), {xFilial(cAlias)})

         For k:= 1 To Len(aFil)
         	cSeek := aFil[k] + Self:aWorks[j][3]
         	If (cAlias)->(DbSeek(cSeek))

            	Do While (cAlias)->(!Eof()) .And. (cAlias)->&(cChave) == cSeek
               		If RecLock(cAliasWork,.T.)
                  		AvReplace(cAlias,cAliasWork)

                  		//(cAliasWork)->&(cAlias+"_FILIAL") := xFilial(cAlias) //comentado por wfs em 18/12/13
                        (cAliasWork)->&(cAlias+"_FILIAL") := aFil[k]
                  		If (cAliasWork)->(FieldPos(cAlias+cCampoRec)) > 0
                     		(cAliasWork)->&(cAlias+cCampoRec) := (cAlias)->(Recno())
                  		EndIf
                  		(cAliasWork)->(MsUnLock())
               		EndIf
               		(cAlias)->(DbSkip())
            	EndDo

         	EndIf
         Next
      EndIf

   Next j

End Sequence

RestOrd(aOrd)

Return Nil

//------------------------------------------------------------------------------------------------------------------
Method CargaEYUEDG() Class EasyApuracao
Local cAliasEYU := Self:oWorkEYU:cTabela
Local cAliasEDG := Self:oWorkEDG:cTabela
Local cAliasWork := Self:oWorkEYU:cAlias
Local cAliasWKEYU := Self:oWKEYU:cAlias
Local cAliasWkEDG := Self:oWorkEDG:cAlias
Local cAliasEE9 := Self:oWorkIp:cAlias

Begin Sequence

   If Select(cAliasEYU) == 0
      DbSelectArea(cAliasEYU)
   EndIf

   If Select(cAliasEDG) == 0
      DbSelectArea(cAliasEDG)
   EndIF

   (cAliasEE9)->(DbGoTop())
   (cAliasEYU)->(DbSetOrder(1)) // EYU_FILIAL+EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3
   (cAliasEDG)->(DbSetOrder(1)) // EDG_FILIAL+EDG_PREEMB+EDG_SEQEMB+EDG_ITEM
   Do While !(cAliasEE9)->(Eof())

      If (cAliasEYU)->(DbSeek(xFilial("EYU") + (cAliasEE9)->(EE9_PREEMB+EE9_SEQEMB)))
         If !(AllTrim((cAliasEE9)->EE9_ATOCON) ==  AllTrim((cAliasEYU)->EYU_ATOCON) .And. AllTrim((cAliasEE9)->EE9_SEQED3) == AllTrim((cAliasEYU)->EYU_SEQED3))
            (cAliasEE9)->(DbSkip())
         EndIf
         If RecLock(cAliasWork,.T.)
            AvReplace(cAliasEYU,cAliasWork)
           (cAliasWork)->&(cAliasEYU+"_FILIAL") := xFilial(cAliasEYU)
           (cAliasWork)->(MsUnLock())
         EndIf
         If RecLock(cAliasWKEYU,.T.)
            AvReplace(cAliasEYU,cAliasWKEYU)
           (cAliasWKEYU)->&(cAliasEYU+"_FILIAL") := xFilial(cAliasEYU)
           (cAliasWKEYU)->(MsUnLock())
         EndIf
      EndIf

      If (cAliasEDG)->(DbSeek(xFilial("EDG") + (cAliasEE9)->(EE9_PREEMB+EE9_SEQEMB+EE9_COD_I) ))
         If RecLock(cAliasWkEDG,.T.)
            AvReplace(cAliasEDG,cAliasWkEDG)
           (cAliasWkEDG)->&(cAliasEDG+"_FILIAL") := xFilial(cAliasEDG)
           (cAliasWkEDG)->(MsUnLock())
         EndIf
      EndIf

      (cAliasEE9)->(DbSkip())
   EndDo

End Sequence

Return Nil

//------------------------------------------------------------------------------------------------------------------
Method CriarWork() Class EasyApuracao
Local cDriver := "DBFCDX"

Begin Sequence

   Self:oWorks := EasyWorks()

   Self:oSldED3 := Self:oWorks:NewWork()
   Self:oSldED3:cAlias := Self:cSldED3
   Self:oSldED3:aCampos := RetCampos(Self:aCposED3)
   Self:oSldED3:cTabela := ""
   Self:oSldED3:lAddIndex := .T.
   Self:oSldED3:aIndex := Self:aIndED3
   Self:oSldED3:cDriver := cDriver
   Self:oSldED3:lVirtuais := .F.
   Self:oSldED3:lMemo := .F.
   Self:oSldED3:lShared  := .F.
   Self:oSldED3:Create()

   Self:oSldED4 := Self:oWorks:NewWork()
   Self:oSldED4:cAlias := Self:cSldED4
   Self:oSldED4:aCampos := RetCampos(Self:aCposED4)
   Self:oSldED4:cTabela := ""
   Self:oSldED4:lAddIndex := .T.
   Self:oSldED4:aIndex := Self:aIndED4
   Self:oSldED4:cDriver := cDriver
   Self:oSldED4:lVirtuais := .F.
   Self:oSldED4:lMemo := .F.
   Self:oSldED4:lShared  := .F.
   Self:oSldED4:Create()

   Self:oSldSW5 := Self:oWorks:NewWork()
   Self:oSldSW5:cAlias := "WorkSW5"
   Self:oSldSW5:aCampos := {}
   Self:oSldSW5:cTabela := "SW5"
   Self:oSldSW5:lAddIndex := .T.
   Self:oSldSW5:aIndex := {}
   Self:oSldSW5:cDriver := cDriver
   Self:oSldSW5:lVirtuais := .F.
   Self:oSldSW5:lMemo := .F.
   Self:oSldSW5:lShared  := .F.
   Self:oSldSW5:Create()

   Self:oSldSW8 := Self:oWorks:NewWork()
   Self:oSldSW8:cAlias := "WorkSW8"
   Self:oSldSW8:aCampos := {}
   Self:oSldSW8:cTabela := "SW8"
   Self:oSldSW8:lAddIndex := .T.
   Self:oSldSW8:aIndex := {}
   Self:oSldSW8:cDriver := cDriver
   Self:oSldSW8:lVirtuais := .F.
   Self:oSldSW8:lMemo := .F.
   Self:oSldSW8:lShared  := .F.
   Self:oSldSW8:Create()

   Self:oWorkComp := Self:oWorks:NewWork()
   Self:oWorkComp:cAlias := Self:cWorkComp
   Self:oWorkComp:aCampos := RetCampos(Self:aCposComp)
   Self:oWorkComp:cTabela := "EDD"
   Self:oWorkComp:lAddIndex := .T.
   Self:oWorkComp:aIndex := Self:aIndComp
   Self:oWorkComp:cDriver := cDriver
   Self:oWorkComp:lVirtuais := .F.
   Self:oWorkComp:lMemo := .F.
   Self:oWorkComp:lShared  := .F.
   Self:oWorkComp:Create()

   Self:Error(Self:oSldSW5:aError)
   Self:Error(Self:oSldSW8:aError)
   Self:Error(Self:oSldED3:aError)
   Self:Error(Self:oSldED4:aError)
   Self:Error(Self:oWorkComp:aError)

End Sequence

Return Nil

//------------------------------------------------------------------------------------------------------------------
Method ZapWorks(cAlias) Class EasyApuracao
Local lRet := .F.

Begin Sequence

   If Select(cAlias) > 0
      (cAlias)->(avzap())
      lRet := .T.
   EndIf

End Sequence

Return lRet

//------------------------------------------------------------------------------------------------------------------
Method Reapurar() Class EasyApuracao
Local i := 0
Local lRet := .T.
Local cWorkED9 := ""
Local cWorkED8 := ""
Local cWorkEDD := ""
Private cMsgAuto := ""

Begin Sequence

   // Carga das tabelas
   Self:CarregaTabelas()

   // Carga de tabelas específicas
   Self:CargaEYUEDG()

   cWorkED9 := Self:oWorkED9:cAlias
   cWorkED8 := Self:oWorkED8:cAlias
   cWorkEDD := Self:oWorkEDD:cAlias
   If (cWorkEDD)->(EasyRecCount()) == 0 .And. (cWorkED8)->(EasyRecCount()) == 0 .And. (cWorkED9)->(EasyRecCount()) == 0  //AOM - 09/05/2012
      lRet := .F.
      Break
   EndIf

   If !Self:ZapWorks(Self:oSldED3:cAlias) .Or. ;
      !Self:ZapWorks(Self:oSldED4:cAlias) .Or. ;
      !Self:ZapWorks(Self:oSldSW5:cAlias) .Or. ;
      !Self:ZapWorks(Self:oSldSW8:cAlias) .Or. ;
      !Self:ZapWorks(Self:oWorkComp:cAlias)
      lRet := .F.
      Break
   EndIf

   ED0->(DbSetOrder(2))
   If ED0->(DbSeek(xFilial("ED0")+AvKey(Self:cAto,"ED0_AC")))
      Self:cModalidade := ED0->ED0_MODAL
      Self:cPD := ED0->ED0_PD
   Else
      lRet := .F.
      Break
   EndIf

   // Trocando o apelido das works para o nome da tabela física
   For i := 1 To Len(Self:aAlias)
      // Fechando a Work
      If Select(Self:aAlias[i][2]) > 0
         (Self:aAlias[i][2])->(dbCloseArea())// RepED9->(dbCloseArea())
      EndIf
      // Fechando a Tabela Fisica
      If Select(Self:aAlias[i][1]) > 0
         (Self:aAlias[i][1])->(dbCloseArea())
      EndIf
      // Abrindo a Work com o nome da Tabela Física - {Nome da Work, Nome da tabela}
      Self:oTabelas:AbreWork(Self:aAlias[i][2],Self:aAlias[i][1])
   Next


   // Desvinculando DrawBack
   Processa({|| Self:EasyDesEDC()},STR0025)//"Verificando Saldos..."

   If !lMsErroAuto
      // Limpando o saldo e valores das works ED3 e ED4
      // Vinculando DrawBack
      Processa({|| Self:LimpaSldo(), lRet := Self:EasyVinEDC()},STR0025)//"Verificando Saldos..."
   EndIf

   // Trocando o apelido das works para o nome de criação
   For i := 1 To Len(Self:aAlias)
      If Select(Self:aAlias[i][1]) > 0
         (Self:aAlias[i][1])->(dbCloseArea())// ED9->(dbCloseArea())
      EndIf
      ChkFile(Self:aAlias[i][1]) // ChkFile("ED9")
      Self:oTabelas:AbreWork(Self:aAlias[i][2]) //oTabelas:AbreWork("RepED9")
   Next

   If lMsErroAuto
      EECVIEW(cMsgAuto, STR0051,,,, .T.) //"Apuração de Saldos do Ato Concessório"
      lRet := .F.
      Break
   EndIf

   // Carregando a Work
   If lRet .And. !Self:CarregaWork()
      lRet := .F.
      Break
   EndIf

End Sequence

// Deleta todas as cópias das tabelas
Self:oTabelas:CloseWorks()

Return lRet

//------------------------------------------------------------------------------------------------------------------
Method EasyDesEDC() Class EasyApuracao
Local aCampos := {}
Local dData
Local nPos := 0
Local lCompraNacio := AvFlags("SEQMI")
Local nOrdOldEDH := 0
Local nRecno := 0

// Rotina de Vendas para exportadores
Private aRotina := {}
Private lVEPrevia    := .F. //Sempre falso
Private lAcaoVincula := .T. //Habilita a ação de vinculação/desvincução de ato.
Private lVincula     := .F. //.T. ->Vincula / .F. ->Desvincula ato concessorio.
Private lRevincula   := .F. //Desvincula o ato anterior e vincula o novo ato.
Private lVendasExp   := .F. //Manutenção de Vendas p/ Exportadores

Begin Sequence

   Self:aDadosEDC := {}

   ProcRegua(ED9->(EasyRecCount())+ED8->(EasyRecCount()))
   ED9->(DbGoTop())
   nOrdOldED9 := ED9->(IndexOrd())
   Do While !ED9->(Eof())
      nRecno := ED9->(RECNO())

      aCampos := Self:CarregaRegistro("ED9")

      // Desvinculando Re's Externos
      If ED9->(FieldPos("ED9_RE")) > 0 .And. !Empty(ED9->ED9_RE)

         If AllTrim(EasyGParam("MV_ANT_EXP",,"1")) == "1" .And. ED9->(FieldPos("ED9_EMISSA")) > 0 .And. !Empty(ED9->ED9_EMISSA)
            dData := ED9->ED9_EMISSA
         ElseIf AllTrim(EasyGParam("MV_ANT_EXP",,"1")) == "2" .And. ED9->(FieldPos("ED9_DTEMB")) > 0 .And. !Empty(ED9->ED9_DTEMB)
            dData := ED9->ED9_DTEMB
         EndIf

         aAdd(Self:aDadosEDC,{dData,"ED9",ED9->ED9_RECNO,"1",aClone(aCampos)})

         aCampos[aScanInfo(aCampos,1,"ED9_AC")][2] := ""
         aCampos[aScanInfo(aCampos,1,"ED9_SEQSIS")][2] := ""

         MSExecAuto({|a,b,c,d| EDCRE400(a,b,c,d)},aCampos,.F.,.F.,6)

         If !Empty(ED9->(DBFilter()))
            ED9->(DBCLEARFILTER())
         EndIf
         ED9->(DbSetOrder(nOrdOldED9))
         ED9->(DbGoTo(nRecno))

         If lMsErroAuto
            cMsgAuto := STR0026 + CHR(13) + CHR(10)+;//"Encontrado inconsistencia na desvinculação do Re's Externos."
                         STR0027 + RetInforma(aCampos,1,"ED9_RE",2) +CHR(13) + CHR(10)+;//"RE: "
                         STR0028 + RetInforma(aCampos,1,"ED9_POSICA",2) + CHR(13) + CHR(10)+;//"Posicao: "
                         STR0029 + RetInforma(aCampos,1,"ED9_PROD",2)  + CHR(13) + CHR(10)//"Produto: "
            cMsgAuto += MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
            Break
         EndIf

      // Desvinculando Venda para exportador
      ElseIf ED9->(FieldPos("ED9_PEDIDO")) > 0 .And. !Empty(ED9->ED9_PEDIDO)

		 cCampos := "ED9_FILIAL/ED9_RE/ED9_EXPORT/ED9_DTRE/ED9_DT_INT/ED9_DTAVRB/ED9_VALORI/ED9_DTEMB/ED9_VAL_SE/ED9_SALISE/ED9_VALCOM"
		 aCampos := Self:CarregaRegistro("ED9",cCampos)
         aAdd(Self:aDadosEDC,{ED9->ED9_EMISSA,"ED9",ED9->ED9_RECNO,"2",aClone(aCampos)})

         lVendasExp   := .T.

         aCampos[aScanInfo(aCampos,1,"ED9_AC")][2] := ""
         aCampos[aScanInfo(aCampos,1,"ED9_SEQSIS")][2] := ""

         MSExecAuto({|a,b| EDCVE400(a,b)},aCampos,4)

         If !Empty(ED9->(DBFilter()))
            ED9->(DBCLEARFILTER())
         EndIf
         ED9->(DbSetOrder(nOrdOldED9))
         ED9->(DbGoTo(nRecno))

         If lMsErroAuto
            cMsgAuto := STR0030 + CHR(13) + CHR(10)+;//"Encontrado inconsistencia na desvinculação do Venda para exportadores."
                         STR0031 + RetInforma(aCampos,1,"ED9_PEDIDO",2) + CHR(13) + CHR(10)+;//"Pedido: "
                         STR0029 + RetInforma(aCampos,1,"ED9_PROD",2) + CHR(13) + CHR(10)//"Produto: "
            cMsgAuto += MemoRead(NomeAutoLog())
            Break
         EndIf

      EndIf

      IncProc()
      ED9->(DbSkip())
   EndDo

   // Desvinculando o EEC
   Self:EasyDesEEC()

   EDH->(DBGoTop())
   nOrdOldEDH := EDH->(IndexOrd())
   Do While !EDH->(Eof())
      nRecno := EDH->(Recno())
      aCampos := Self:CarregaRegistro("EDH")

      aAdd(Self:aDadosEDC,{EDH->EDH_DTOCOR,"EDH",,"",aClone(aCampos)})
      MSExecAuto({|a,b| EDCBA400(a,b)},aCampos,5)

      If !Empty(EDH->(DBFilter()))
         EDH->(DBCLEARFILTER())
      EndIf
      EDH->(DbSetOrder(nOrdOldEDH))
      EDH->(DbGoTo(nRecno))

      If lMsErroAuto
         cMsgAuto := STR0033 + BSCXBOX("EDH_TPOCOR",RetInforma(aCampos,1,"EDH_TPOCOR",2)) + "." + CHR(13) + CHR(10)+;//"Encontrado inconsistencia na desvinculação da rotina "
                      STR0034 + RetInforma(aCampos,1,"EDH_DI_NUM",2)  + CHR(13) + CHR(10)+;//"Numero da DI: "
                      STR0035 + RetInforma(aCampos,1,"EDH_PO_NUM",2) + CHR(13) + CHR(10)+;//"Numero do PO: "
                      STR0036 + RetInforma(aCampos,1,"EDH_POSICA",2) + CHR(13) + CHR(10)+;//"Posicao do PO: "
                      STR0037 + RetInforma(aCampos,1,"EDH_COD_I",2) + CHR(13) + CHR(10)//"Item: "
         cMsgAuto += MemoRead(NomeAutoLog())
         FErase(NomeAutoLog())
         Break
      EndIf
      IncProc()
      EDH->(DbSkip())
   EndDo

   ED8->(DbGoTop())
   nOrdOldED8 := ED8->(IndexOrd())
   Do While !ED8->(Eof())
      nRecno := ED8->(RECNO())
      aCampos := Self:CarregaRegistro("ED8")

      If ED8->(FieldPos("ED8_DI_NUM")) > 0 .And. !Empty(ED8->ED8_DI_NUM)

         If AllTrim(EasyGParam("MV_ANT_IMP",,"1")) == "1" .And. ED8->(FieldPos("ED8_EMISSA")) > 0 .And. !Empty(ED8->ED8_EMISSA)
            dData := ED8->ED8_EMISSA
         ElseIf AllTrim(EasyGParam("MV_ANT_IMP",,"1")) == "2" .And. ED8->(FieldPos("ED8_DTREG")) > 0 .And. !Empty(ED8->ED8_DTREG)
            dData := ED8->ED8_DTREG
         EndIf

         aAdd(Self:aDadosEDC,{dData,"ED8",ED8->ED8_RECNO,"1",aClone(aCampos)})
         aAdd(Self:aItens,{"1",ED8->ED8_COD_I})

         aCampos[aScanInfo(aCampos,1,"ED8_AC")][2] := ""
         aCampos[aScanInfo(aCampos,1,"ED8_SEQSIS")][2] := ""

         nPos := aScan(aCampos,{|X| AllTrim(X[1]) == "ED8_SEQMI"})
         If lCompraNacio .And. nPos > 0
            aCampos[nPos][2] := ""
         EndIf

         MSExecAuto({|a,b,c,d,e| EDCMN400(a,b,c,d,e)},,,,aCampos,6)

         If !Empty(ED8->(DBFilter()))
            ED8->(DBCLEARFILTER())
         EndIf
         ED8->(DbSetOrder(nOrdOldED8))
         ED8->(DbGoTo(nRecno))

         If lMsErroAuto
            cMsgAuto := STR0038+CHR(13) + CHR(10)+;//"Encontrado inconsistencia na desvinculação da rotina DI Externas."
                         STR0034+ RetInforma(aCampos,1,"ED8_DI_NUM",2) + CHR(13) + CHR(10)+;//"Numero da DI: "
                         STR0047 + RetInforma(aCampos,1,"ED8_COD_I",2)  + CHR(13) + CHR(10)//"Item: "
            cMsgAuto += MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
            Break
         EndIf

      ElseIf ED8->(FieldPos("ED8_PEDIDO")) > 0 .And. !Empty(ED8->ED8_PEDIDO)

         aAdd(Self:aDadosEDC,{ED8->ED8_EMISSA,"ED8",ED8->ED8_RECNO,"2",aClone(aCampos)})
         aAdd(Self:aItens,{"2",ED8->ED8_COD_I})

         aCampos[aScanInfo(aCampos,1,"ED8_AC")][2] := ""
         aCampos[aScanInfo(aCampos,1,"ED8_SEQSIS")][2] := ""

         nPos := aScan(aCampos,{|X| AllTrim(X[1]) == "ED8_SEQMI"})
         If lCompraNacio .And. nPos > 0
            aCampos[nPos][2] := ""
         EndIf

         //Desvinculando Compra Nacionais
         MSExecAuto({|a,b| EDCNF400(a,b)},aCampos,4)

         If !Empty(ED8->(DBFilter()))
            ED8->(DBCLEARFILTER())
         EndIf
         ED8->(DbSetOrder(nOrdOldED8))
         ED8->(DbGoTo(nRecno))

         If lMsErroAuto
            cMsgAuto := STR0041+CHR(13) + CHR(10)+;//"Encontrado inconsistencia na desvinculação da rotina Compras Nacionais."
                     STR0035 + RetInforma(aCampos,1,"ED8_PEDIDO",2) + CHR(13) + CHR(10)+;//"Numero do PO: "
                     STR0036 + RetInforma(aCampos,1,"ED8_POSDI",2) + CHR(13) + CHR(10)+;//"Posicao do PO: "
                     STR0037 + RetInforma(aCampos,1,"ED8_COD_I",2) + CHR(13) + CHR(10)
            cMsgAuto += MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
            Break
         EndIf

      EndIf

      IncProc()
      ED8->(DbSkip())
   EndDo

   // Desvinculando EIC
   Self:EasyDesEIC()

End Sequence

Return nil

//------------------------------------------------------------------------------------------------------------------
Method EasyVinEDC() Class EasyApuracao
Local aDados := {}, aExportacoes := {}
Local i := 0
Local lRet := .F.

// Rotina de Vendas para exportadores
Private aRotina := {}
Private lVEPrevia    := .F. //Sempre falso
Private lAcaoVincula := .T. //Habilita a ação de vinculação/desvincução de ato.
Private lVincula     := .T. //.T. ->Vincula / .F. ->Desvincula ato concessorio.
Private lRevincula   := .F. //Desvincula o ato anterior e vincula o novo ato.
Private lVendasExp   := .F. //Manutenção de Vendas p/ Exportadores

Begin Sequence

   // Vinculando EIC
   Self:EasyVinEIC()

   //aDados := EasyAsort(Self:aDados,,,{|X,Y| X[1] < Y[1]})
   aDados := aSort(Self:aDadosEDC,,,{|X,Y| X[1] < Y[1]})
   ProcRegua(Len(aDados))
   For i := 1 To Len(aDados)

      If aDados[i][2] == "ED8"

         // Comprovando Manutenção de DI
         If aDados[i][4] == "1"

            If !Empty(ED8->(DBFilter()))
               ED8->(DBCLEARFILTER())
            EndIf

            MSExecAuto({|a,b,c,d,e| EDCMN400(a,b,c,d,e)},,,,aDados[i][5],6)

            If lMsErroAuto
               cMsgAuto := STR0043+CHR(13) + CHR(10)+;//"Encontrado inconsistencia na vinculação da rotina DI Externas."
                            STR0034 + RetInforma(aDados[i][5],1,"ED8_DI_NUM",2) + CHR(13) + CHR(10)+;//"Numero da DI: "
                            STR0037 + RetInforma(aDados[i][5],1,"ED8_COD_I",2)  + CHR(13) + CHR(10)//"Item: "
               cMsgAuto += MemoRead(NomeAutoLog())
               FErase(NomeAutoLog())
               Break
            EndIf
         EndIf

         // Comprovando Compra Nacionais
         If aDados[i][4] == "2"

            If !Empty(ED8->(DBFilter()))
               ED8->(DBCLEARFILTER())
            EndIf

            MSExecAuto({|a,b| EDCNF400(a,b)},aDados[i][5],4)

            If lMsErroAuto
               cMsgAuto := STR0042+CHR(13) + CHR(10)+;//"Encontrado inconsistencia na vinculação da rotina Compras Nacionais."
                            STR0035 + RetInforma(aDados[i][5],1,"ED8_PEDIDO",2) + CHR(13) + CHR(10)+;//"Numero do PO: "
                            STR0036 + RetInforma(aDados[i][5],1,"ED8_POSDI",2) + CHR(13) + CHR(10)+;//"Posicao do PO: "
                            STR0037 + RetInforma(aDados[i][5],1,"ED8_COD_I",2) + CHR(13) + CHR(10)//"Item: "
               cMsgAuto += MemoRead(NomeAutoLog())
               FErase(NomeAutoLog())
               Break
            EndIf
         EndIf

      ElseIf aDados[i][2] == "EDH"

         If !Empty(EDH->(DBFilter()))
            EDH->(DBCLEARFILTER())
         EndIf

         MSExecAuto({|a,b| EDCBA400(a,b)},aDados[i][5],3)

         If lMsErroAuto
            cMsgAuto := STR0044 + BSCXBOX("EDH_TPOCOR",RetInforma(aDados[i][5],1,"EDH_TPOCOR",2)) + "." +CHR(13) + CHR(10)+;//"Encontrado inconsistencia na vinculação da rotina "
                         STR0034 + RetInforma(aDados[i][5],1,"EDH_DI_NUM",2)  + CHR(13) + CHR(10)+;//"Numero da DI: "
                         STR0035 + RetInforma(aDados[i][5],1,"EDH_PO_NUM",2) + CHR(13) + CHR(10)+;//"Numero do PO: "
                         STR0036 + RetInforma(aDados[i][5],1,"EDH_POSICA",2) + CHR(13) + CHR(10)+;//"Posicao do PO: "
                         STR0037 + RetInforma(aDados[i][5],1,"EDH_COD_I",2) + CHR(13) + CHR(10)//"Item: "
            cMsgAuto += MemoRead(NomeAutoLog())
            FErase(NomeAutoLog())
            Break
         EndIf

      Else
        aAdd(aExportacoes,aDados[i])
      EndIf

      IncProc()
   Next

   lRet := Self:EasyVinEEC()
   If !lRet
      Break
   EndIf

   For i := 1 To Len(aExportacoes)

      If aExportacoes[i][2] == "ED9"

         // Comprovando RE Externo
         If aExportacoes[i][4] == "1"

            If !Empty(ED9->(DBFilter()))
               ED9->(DBCLEARFILTER())
            EndIf

            MSExecAuto({|a,b,c,d| EDCRE400(a,b,c,d)},aExportacoes[i][5],.F.,.T.,6)

            If lMsErroAuto
               cMsgAuto := STR0045 + CHR(13) + CHR(10)+;//"Encontrado inconsistencia na vinculação do Re's Externos."
                            STR0027 + RetInforma(aExportacoes[i][5],1,"ED9_RE",2) +CHR(13) + CHR(10)+;//"RE: "
                            STR0028 + RetInforma(aExportacoes[i][5],1,"ED9_POSICA",2) + CHR(13) + CHR(10)+;//"Posicao: "
                            STR0029 + RetInforma(aExportacoes[i][5],1,"ED9_PROD",2)  + CHR(13) + CHR(10)//"Produto: "
               cMsgAuto += MemoRead(NomeAutoLog())
               FErase(NomeAutoLog())
               Break
            EndIf
         EndIf

         // Comprovando Vendas para Exportadores
         If aExportacoes[i][4] == "2"

            If !Empty(ED9->(DBFilter()))
               ED9->(DBCLEARFILTER())
            EndIf

            lVendasExp   := .T.
            MSExecAuto({|a,b| EDCVE400(a,b)},aExportacoes[i][5],4)

            If lMsErroAuto
               cMsgAuto := STR0046 + CHR(13) + CHR(10)+;//"Encontrado inconsistencia na vinculação do Venda para exportadores."
                            STR0031 + RetInforma(aExportacoes[i][5],1,"ED9_PEDIDO",2) + CHR(13) + CHR(10)+;//"Pedido: "
                            STR0029 + RetInforma(aExportacoes[i][5],1,"ED9_PROD",2) + CHR(13) + CHR(10)//"Produto: "
               cMsgAuto += MemoRead(NomeAutoLog())
               Break
            EndIf
         EndIf

      EndIf

      IncProc()
   Next

End Sequence

Return lRet

//------------------------------------------------------------------------------------------------------------------
//Revisão: wfs 18/12/13
//         tratamento multifilial
Method EasyDesEEC() Class EasyApuracao
Local aOrd := SaveOrd({"EEC","EE9"})
Local cFilOld:= cFilAnt
Private Inclui := .F.
Private CFILEDD := xFilial("EDD")
Private lDrawSC := ChkFile("EDG")   //Verifica se a tabela para Draw Back sem cobertura cambial existe (EDG)
Private cFilED3 := xFilial("ED3")

Private lItFabric := Self:lItFabric
Private lExistEDD := .T.

Begin Sequence

   If Select("EEC") == 0
      DbSelectArea("EEC")
   EndIf

   If Select("EE9") == 0
      DbSelectArea("EE9")
   EndIf

   Self:aDadosEEC := {}

   WorkIp->(DbGoTop())
   EEC->(DbSetOrder(1))
   EE9->(DbSetOrder(2))
   EDD->(DbSetOrder(3)) // EDD_FILIAL+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_PROD+EDD_AC+EDD_SEQSIE
   EEM->(dbSetOrder(2))
   Do While !WorkIp->(Eof())

      //wfs em 18/12/13
      If lMultiFil
         cFilAnt:= WorkIp->EE9_FILIAL
      EndIf

      EEC->(DbSeek(xFilial("EEC")+WorkIp->EE9_PREEMB))
      //M->EEC_CALCEM := "1"
      //M->EEC_CODUSU := __cUserid
      RegToMemory("EEC",.F.)
      // M->EEC_COBCAM := EEC->EEC_COBCAM
      EE9->(DbSeek(xFilial("EE9")+WorkIp->(EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN)))

      RegToMemory("EE9",.F.)

      aAdd(Self:aDadosEEC,{WorkIp->(EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN),;
                           WorkIp->EE9_ATOCON,;
                           WorkIp->EE9_SEQED3,;
                           WorkIp->EE9_COD_I,;
                           WorkIp->EE9_SEQUEN,;
                           M->EEC_DTEMBA,;
                           WorkIp->EE9_SLDINI,;
                           WorkIp->EE9_PEDIDO,;
                           WorkIp->EE9_SEQEMB,;
                           EEC->EEC_COBCAM,;
                           EEC->EEC_PREEMB,;
                           EEC->EEC_FILIAL})
      WorkIp->EE9_ATOCON := ""

      SaldosED3()

      IncProc()
      WorkIp->(DbSkip())
   EndDo

End Sequence

RestOrd(aOrd)
cFilAnt:= cFilOld

Return Nil

//------------------------------------------------------------------------------------------------------------------
//Revisão: wfs 18/12/13
//         Tratamento multifilial
Method EasyVinEEC() Class EasyApuracao
Local aOrd := SaveOrd({"EEC","EE9"})
Local i := 0
Local lRet := .T.
Local cFilOld:= cFilAnt
Private Inclui := .T.
Private lDrawSC := ChkFile("EDG")   //Verifica se a tabela para Draw Back sem cobertura cambial existe (EDG)
Private cFilED3 := xFilial("ED3")

Private lItFabric := Self:lItFabric
Private CFILEDD := xFilial("EDD")
Private cFilED0 := xFilial("ED0")
Private cFilED1 := xFilial("ED1")
Private cFilED2 := xFilial("ED2")

Private FWorkAnt, FWorkAnt2, FWorkAnt3, FWorkAnt4  // AAF - 23/09/2013

Begin Sequence

   If Empty(Self:aDadosEEC) //AOM - 09/08/2012
      Break
   EndIf

   EEC->(DbSetOrder(1)) //EEC_FILIAL+EEC_PREEMB
   WorkIp->(DbSetOrder(2)) // EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN
   For i := 1 To Len(Self:aDadosEEC)

      //wfs 18/12/13
      If lMultiFil
         cFilAnt:= Self:aDadosEEC[i][12]
      EndIf

      EEC->(DbSeek(xFilial("EEC")+Self:aDadosEEC[i][1]))
      RegToMemory("EEC",.F.)

      WorkIp->(DbSeek(xFilial("EE9")+Self:aDadosEEC[i][1]))
      If RecLock("WorkIp",.F.)
         WorkIp->EE9_ATOCON := Self:aDadosEEC[i][2]
         WorkIp->EE9_SEQED3 := Self:aDadosEEC[i][3]
         WorkIp->(MsUnLock())
      EndIf

      SaldosED3()
      lRet := AEGrvWKAnt(Self:aDadosEEC[i][2],AvKey(Self:aDadosEEC[i][4],"EDD_PROD"),Self:aDadosEEC[i][5],Self:aDadosEEC[i][6],Self:aDadosEEC[i][7],Self:aDadosEEC[i][8],,Self:aDadosEEC[i][9],.F.)
      If lRet
         RE400GrvEDD(WorkIp->EE9_RE)

         If Select("WorkAnt") > 0    // AAF - 23/09/2013
            AvZap("WorkAnt")
         EndIf
      EndIf
      IncProc()
   Next

End Sequence

If Select("WorkAnt") > 0   // AAF - 23/09/2013
   /*
   WorkAnt->(dbCloseArea())

   FErase(FWorkAnt)
   FErase(FWorkAnt2)
   FErase(FWorkAnt3)
   FErase(FWorkAnt4)
   */
   WorkAnt->(E_EraseArq(FWorkAnt, FWorkAnt2, FWorkAnt3))
   FErase(FWorkAnt4)
EndIf

RestOrd(aOrd)
cFilAnt:= cFilOld

Return .T.//lRet  // AAF - 23/09/2013

//------------------------------------------------------------------------------------------------------------------
//Revisão: wfs 19/12/13
//         tratamento multifilial
//------------------------------------------------------------------------------------------------------------------
Method EasyDesEIC() Class EasyApuracao
Local aOrd := SaveOrd({"SW8"})
Local dData
Local cFilOld:= cFilAnt

Begin Sequence

   Self:aDadosEIC := {}

   If Select("SW6") == 0
      DbSelectArea("SW6")
   EndIf

   SW8->(DbGoTop())
   SW6->(DbSetOrder(1)) // W6_FILIAL+W6_HAWB
   Do While !SW8->(Eof())

   	  //wfs 19/12/13
   	  If lMultiFil
   	     cFilAnt:= SW8->W8_FILIAL
   	  EndIf

      SW6->(DbSeek(xFilial("SW6")+SW8->W8_HAWB))
      RegToMemory("SW6",.F.,.F.)
      dData := SW6->W6_DTREG_D

      aAdd(Self:aDadosEIC,{SW8->W8_HAWB,SW8->W8_PO_NUM,SW8->W8_INVOICE,SW8->W8_COD_I,SW8->W8_POSICAO,SW8->W8_PGI_NUM,SW8->W8_QT_AC,dData,SW8->W8_AC,SW8->W8_SEQSIS,Self:cPD,SW8->W8_QT_AC2})
      DIGrvAnt(2,SW8->W8_HAWB,SW8->W8_PO_NUM,SW8->W8_INVOICE,SW8->W8_COD_I,SW8->W8_POSICAO,SW8->W8_PGI_NUM)
      aAdd(Self:aItens,{"1",SW8->W8_COD_I})
      IncProc()
      SW8->(DbSkip())
   EndDo
End Sequence

RestOrd(aOrd)
cFilAnt:= cFilOld

Return Nil

//------------------------------------------------------------------------------------------------------------------
//Revisão: wfs 18/12/13
//         tratamento multifilial
Method EasyVinEIC() Class EasyApuracao
Local cFilOld:= cFilAnt

Begin Sequence

   // AAF - 23/09/2013
   SW8->(DbGoTop())
   SW6->(DbSetOrder(1)) // W6_FILIAL+W6_HAWB
   ED4->(dbSetOrder(2)) // ED4_FILIAL+ED4_AC+ED4_SEQSIS
   Do While !SW8->(Eof())

   	  //wfs 18/12/13
   	  If lMultiFil
   	     cFilAnt:= SW8->W8_FILIAL
   	  EndIf

      If ED4->(dbSeek(xFilial("ED4")+SW8->W8_AC+SW8->W8_SEQSIS))

         ED4->(RecLock("ED4",.F.))

         If ED4->(FieldPos("ED4_SNCMEX")) > 0
            ED4->ED4_SNCMEX += SW8->W8_QT_AC2//Self:aDadosEIC[i][12]
         EndIf

         If ED4->(FieldPos("ED4_SQTDEX")) > 0
            ED4->ED4_SQTDEX += SW8->W8_QT_AC//Self:aDadosEIC[i][12]
         EndIf
         ED4->(msUnlock())

         SW6->(DbSeek(xFilial("SW6")+SW8->W8_HAWB))
         dData := SW6->W6_DTREG_D

         DIGrvAnt(1,SW8->W8_HAWB,SW8->W8_PO_NUM,SW8->W8_INVOICE,SW8->W8_COD_I,SW8->W8_POSICAO,SW8->W8_PGI_NUM,SW8->W8_QT_AC,dData,SW8->W8_AC,SW8->W8_SEQSIS,Self:cPD)
      EndIf

      IncProc()

      SW8->(DbSkip())
   EndDo

End Sequence

cFilAnt:= cFilOld
Return Nil

//------------------------------------------------------------------------------------------------------------------
Method LimpaSldo() Class EasyApuracao
Local aValores := {}
Local bBlockSW5 := { |x| SW5->( DBGoTo(x[2]) ),   ;
                      RecLock("SW5",.F.),      ;
                      SW5->W5_QT_AC  := x[3],  ;
                      SW5->W5_QT_AC2 := x[4],  ;
                      SW5->W5_VL_AC  := x[5],  ;
                      SW5->( MSUnLock() )         } ;

      bBlockSW8 := { |x| SW8->( DBGoTo(x[2]) ),   ;
                      RecLock("SW8",.F.),      ;
                      SW8->W8_QT_AC  := x[3],  ;
                      SW8->W8_QT_AC2 := x[4],  ;
                      SW8->W8_VL_AC  := x[5],  ;
                      SW8->( MSUnLock() )         }
Private aSW5 := {}   ,;
        aSW8 := {}
Begin Sequence

   EDD->(DbGoTop())
   Do While !EDD->(Eof())
      aAdd(Self:aDadosEDD,EDD->EDD_RECOLD)
      EDD->(DbSkip())
   EndDo
   Self:ZapWorks("EDD")

   ED3->(DbGoTop())
   Do While !ED3->(Eof())
      If RecLock("ED3",.F.)
         ED3->ED3_SALDO  := ED3->ED3_QTD
         ED3->ED3_SALNCM := ED3->ED3_QTDNCM
         ED3->ED3_SAL_CO := ED3->ED3_VAL_CO
         ED3->ED3_SAL_SE := ED3->ED3_VAL_SE
         ED3->(MsUnLock())
      EndIf
      ED3->(DbSkip())
   EndDo

   ED4->(DbGoTop())
   Do While !ED4->(Eof())

      aValores := ApuraBaixa()
      If Len(aValores) > 0 .And. RecLock("ED4",.F.)
         ED4->ED4_QT_LI := RetInforma(aValores,1,"ED4_QT_LI",2)
         ED4->ED4_VL_LI := RetInforma(aValores,1,"ED4_VL_LI",2)
         ED4->ED4_SNCMLI:= RetInforma(aValores,1,"ED4_SNCMLI",2)
         ED4->ED4_QT_DI := RetInforma(aValores,1,"ED4_QT_DI",2)
         ED4->ED4_VL_DI := RetInforma(aValores,1,"ED4_VL_DI",2)
         ED4->ED4_SNCMDI:= RetInforma(aValores,1,"ED4_SNCMDI",2)
         If ED4->(FieldPos("ED4_SNCMEX")) > 0
            ED4->ED4_SNCMEX := 0
         EndIf
         If ED4->(FieldPos("ED4_SQTDEX")) > 0
            ED4->ED4_SQTDEX := 0
         EndIf
         ED4->(MsUnLock())
      EndIf

      AEval( aSW5, { |x| IIF( x[1] == ED4->(ED4_AC+ED4_SEQSIS) , Eval(bBlockSW5,x), ) } )
      AEval( aSW8, { |x| IIF( x[1] == ED4->(ED4_AC+ED4_SEQSIS) , Eval(bBlockSW8,x), ) } )

      ED4->(DbSkip())
   EndDo

End Sequence

Return Nil

//------------------------------------------------------------------------------------------------------------------
Method CarregaRegistro(cWork,cCampos) Class EasyApuracao
Local aDados := {}
Local nOrdX3
Local cCampo:= ""
Default cCampos := ""

Begin Sequence

   If Select(cWork) == 0
      DbSelectArea(cWork)
   EndIf

   nOrdX3 := SX3->(Indexord())
   SX3->(dbSetOrder(1))
   SX3->(dbSeek(cWork))
   Do While SX3->(!EoF() .AND. X3_ARQUIVO == cWork)
      If SX3->X3_CONTEXT <> "V" .AND. !AllTrim(SX3->X3_CAMPO) $ cCampos
         cCampo:= AllTrim(SX3->X3_CAMPO)
         aAdd(aDados,{cCampo,&(cWork+"->" + cCampo),Nil}) // Adicionando no vetor todos os dados do registro da tabela
      EndIf

      SX3->(dbSkip())
   EndDo
   SX3->(dbSetOrder(nOrdX3))

End Sequence

Return aClone(aDados)

//------------------------------------------------------------------------------------------------------------------
Method CarregaWork() Class EasyApuracao
Local i := 0
Local j := 0
Local aCposED3 := {}
Local aCposED4 := {}
Local cWorkED3 := ""
Local cWorkED4 := ""
Local aHeaderED3 := {}
Local aHeaderED4 := {}
Local aDetailED3 := {}
Local aDetailED4 := {}
Local cSldED3 := ""
Local cSldED4 := ""
Local cSldSW5 := ""
Local cSldSW8 := ""
Local lDiverED3 := .F.
Local lDiverED4 := .F.
Local lDivergente := .F.

Begin Sequence

   If Empty(Self:aRelED3ED4)
      Break
   EndIf

   aCposED3 := Self:aRelED3ED4[1]
   aCposED4 := Self:aRelED3ED4[2]
   cWorkSW5 := Self:oWorkSW5:cAlias
   cWorkSW8 := Self:oWorkSW8:cAlias
   cWorkED3 := Self:oWorkED3:cAlias
   cWorkED4 := Self:oWorkED4:cAlias
   cWorkEDD := Self:oWorkEDD:cAlias

   cSldSW5 := Self:oSldSW5:cAlias
   cSldSW8 := Self:oSldSW8:cAlias
   cSldED3 := Self:oSldED3:cAlias
   cSldED4 := Self:oSldED4:cAlias
   cWorkComp := Self:oWorkComp:cAlias

   For i := 1 To Len(aCposED3)
      If AllTrim(Upper(aCposED3[i][1])) == "HEADER" .Or. AllTrim(Upper(aCposED3[i][1])) == "INTERNO"
         aAdd(aHeaderED3,{aCposED3[i][2][1],aCposED3[i][2][2]}) // ED3
      ElseIf AllTrim(Upper(aCposED3[i][1])) == "DETAIL"
        aAdd(aDetailED3,{{aCposED3[i][2][1],aCposED3[i][2][2]},{aCposED3[i][3][1],aCposED3[i][3][2]}}) // Campo do saldo - Campo do saldo calculado
      EndIf
   Next

   For i := 1 To Len(aCposED4)
      If AllTrim(Upper(aCposED4[i][1])) == "HEADER" .Or. AllTrim(Upper(aCposED4[i][1])) == "INTERNO"
         aAdd(aHeaderED4,{aCposED4[i][2][1],aCposED4[i][2][2]}) // ED3
      ElseIf AllTrim(Upper(aCposED4[i][1])) == "DETAIL"
        aAdd(aDetailED4,{{aCposED4[i][2][1],aCposED4[i][2][2]},{aCposED4[i][3][1],aCposED4[i][3][2]}}) // Campo do saldo - Campo do saldo calculado
      EndIf
   Next

   If Select("ED3") == 0
      DbSelectArea("ED3")
   EndIf

   (cWorkED3)->(DbGoTop())
   ED3->(DbSetOrder(1)) // ED3_FILIAL+ED3_PD+ED3_NCM+ED3_PROD+STR(ED3_PERCAG,5,2)+ED3_UMNCM
   Do While !(cWorkED3)->(Eof())
      For i := 1 To Len(aDetailED3)
         ED3->(DbSeek(xFilial("ED3")+(cWorkED3)->(ED3_PD+ED3_NCM+ED3_PROD+STR(ED3_PERCAG,5,2)+ED3_UMNCM)))
         If ED3->&(aDetailED3[i][1][2]) <> (cWorkED3)->&(aDetailED3[i][2][2])
            (cSldED3)->(RecLock(cSldED3, .T.))
            (cSldED3)->&(Self:cCpoFlag) := Space(2)
            (cSldED3)->&(aDetailED3[i][1][1]) := ED3->&(aDetailED3[i][1][2]) // Campo do Saldo
            (cSldED3)->&(aDetailED3[i][2][1]) := (cWorkED3)->&(aDetailED3[i][2][2]) // Campo do Saldo Calculado
            For j := 1 To Len(aHeaderED3)
               If !Empty(aHeaderED3[j][2])
                  If "ED3_SAL_CO" == AllTrim(Upper(aHeaderED3[j][1])) .Or. "ED3_SAL_SE" == AllTrim(Upper(aHeaderED3[j][1])) // Valor da tabela
                     (cSldED3)->&(aHeaderED3[j][1]) := ED3->&(aHeaderED3[j][2])
                  ElseIf "ED3_VAL_CO" == AllTrim(Upper(aHeaderED3[j][1])) .Or. "ED3_VAL_SE" == AllTrim(Upper(aHeaderED3[j][1]))
                     (cSldED3)->&(aHeaderED3[j][1]) := ED3->&(aHeaderED3[j][2])
                  Else
                     (cSldED3)->&(aHeaderED3[j][1]) := (cWorkED3)->&(aHeaderED3[j][2])
                  EndIf

               Else  // Campos internos
                  If "WORKALIAS" == aHeaderED3[j][1]
                     (cSldED3)->&(aHeaderED3[j][1]) := "ED3"
                  ElseIf "WORKCAMPO" == aHeaderED3[j][1]
                     (cSldED3)->&(aHeaderED3[j][1]) := aDetailED3[i][1][2]
                  ElseIf "WORKTITULO" == aHeaderED3[j][1]
                     (cSldED3)->&(aHeaderED3[j][1]) := AvSx3(aDetailED3[i][1][2],5)
                  ElseIf "WORKDESC" == aHeaderED3[j][1]
                    (cSldED3)->&(aHeaderED3[j][1]) := RetInforma(Self:aDescTabelas,1,"ED3",2)
                  EndIf
               EndIf
            Next
            lDiverED3 := .T.
            (cSldED3)->(MsUnlock())
         EndIf
      Next
      (cWorkED3)->(DbSkip())
   EndDo

   If Select("ED4") == 0
      DbSelectArea("ED4")
   EndIf

   (cWorkED4)->(DbGoTop())
   ED4->(DbSetOrder(1)) // ED4_FILIAL+ED4_PD+ED4_NCM+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2)+ED4_UMNCM
   Do While !(cWorkED4)->(Eof())
      For i := 1 To Len(aDetailED4)
         ED4->(DbSeek(xFilial("ED4")+(cWorkED4)->(ED4_PD+ED4_NCM+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2)+ED4_UMNCM)))
         If (cWorkED4)->&(aDetailED4[i][2][2]) <> ED4->&(aDetailED4[i][1][2])
            (cSldED4)->(RecLock(cSldED4, .T.))
            (cSldED4)->&(Self:cCpoFlag) := Space(2)
            (cSldED4)->&(aDetailED4[i][1][1]) := ED4->&(aDetailED4[i][1][2]) // Campo do Saldo
            (cSldED4)->&(aDetailED4[i][2][1]) := (cWorkED4)->&(aDetailED4[i][2][2]) // Campo do Saldo Calculado
            For j := 1 To Len(aHeaderED4)
               If !Empty(aHeaderED4[j][2])
                  If "ED4_VL_LI" == AllTrim(Upper(aHeaderED4[j][1])) .Or. "ED4_VL_DI" == AllTrim(Upper(aHeaderED4[j][1]))
                     (cSldED4)->&(aHeaderED4[j][1]) := ED4->&(aHeaderED4[j][2])
                  Else
                     (cSldED4)->&(aHeaderED4[j][1]) := (cWorkED4)->&(aHeaderED4[j][2])
                  EndIf

                  // Verificando se o item é importado ou compra nacional
                  If "ED4_ITEM" == AllTrim(Upper(aHeaderED4[j][1]))
                     (cSldED4)->WORKCOMPRA := Self:RetStatus((cSldED4)->ED4_ITEM)
                  EndIf
               Else
                  If "WORKALIAS" == aHeaderED4[j][1]
                     (cSldED4)->&(aHeaderED4[j][1]) := "ED4"
                  ElseIf "WORKCAMPO" == aHeaderED4[j][1]
                     (cSldED4)->&(aHeaderED4[j][1]) := aDetailED4[i][1][2]
                  ElseIf "WORKTITULO" == aHeaderED4[j][1]
                     (cSldED4)->&(aHeaderED4[j][1]) := AvSx3(aDetailED4[i][1][2],5)
                  ElseIf "WORKDESC" == aHeaderED4[j][1]
                     (cSldED4)->&(aHeaderED4[j][1]) := RetInforma(Self:aDescTabelas,1,"ED4",2)
                  EndIf
               EndIf
            Next
            lDiverED4 := .T.
            (cSldED4)->(MsUnlock())
         EndIf

      Next
      (cWorkED4)->(DbSkip())
   EndDo

   If lDiverED3 .Or. lDiverED4
      (cWorkSW5)->(DbGoTop())
      Do While !(cWorkSW5)->(Eof())
         If RecLock(cSldSW5,.T.)
            AvReplace(cWorkSW5,cSldSW5)
            (cSldSW5)->(MsUnLock())
         EndIf
         (cWorkSW5)->(DbSKip())
      EndDo

      (cWorkSW8)->(DbGoTop())
      Do While !(cWorkSW8)->(Eof())
         If RecLock(cSldSW8,.T.)
            AvReplace(cWorkSW8,cSldSW8)
            (cSldSW8)->(MsUnLock())
         EndIf
         (cWorkSW8)->(DbSKip())
      EndDo
   EndIf

   If (lDivergente := (lDiverED3 .Or. lDiverED4 .Or. !Self:ComparaEDD()))
      (cWorkEDD)->(DbGoTop())
      Do While !(cWorkEDD)->(Eof())
         If RecLock(cWorkComp,.T.)
            AvReplace(cWorkEDD,cWorkComp)
            If (!Empty((cWorkEDD)->EDD_HAWB) .Or. !Empty((cWorkEDD)->EDD_PO_NUM)) .And. ;
               (!Empty((cWorkEDD)->EDD_PREEMB) .Or. !Empty((cWorkEDD)->EDD_PEDIDO))
               (cWorkComp)->EDD_COMPRO := "S"
            Else
               (cWorkComp)->EDD_COMPRO := "N"
            EndIf
            (cWorkComp)->(MsUnLock())
         EndIf
         (cWorkEDD)->(DbSkip())
      EndDo
   EndIf

End Sequence

Return lDivergente

//------------------------------------------------------------------------------------------------------------------
Method ComparaEDD() Class EasyApuracao
Local lRet := .F.
Local cWorkEDD := Self:oWorkEDD:cAlias

Begin Sequence

   If Select("EDD") == 0
      DbSelectArea("EDD")
   EndIf

   (cWorkEDD)->(DbGoTop())
   Do While !(cWorkEDD)->(Eof())
      If lCompNac .And. !Empty((cWorkEDD)->EDD_SEQMI) .And. Empty((cWorkEDD)->EDD_SEQSII)
         EDD->(DbSetOrder(4))//EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB
         If lIndED9EDD
            cSeek := xFilial("EDD")+(cWorkEDD)->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN)
         Else
            cSeek := xFilial("EDD")+(cWorkEDD)->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB)
         EndIf
      Else
         EDD->(DbSetOrder(2))//EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB
         If lIndED9EDD
            cSeek := xFilial("EDD")+(cWorkEDD)->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN)
         Else
             cSeek := xFilial("EDD")+(cWorkEDD)->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB)
         EndIf
      EndIf

      lRet := EDD->(DbSeek(cSeek))

      If lRet
         If (cWorkEDD)->EDD_QTD == EDD->EDD_QTD
            lRet := .T.
         Else
            lRet := .F.
            Break
         EndIf
      Else
         lRet := .F.
         Break
      EndIf

      (cWorkEDD)->(DbSkip())
   EndDo

End Sequence

Return lRet

//------------------------------------------------------------------------------------------------------------------
Method SalvarSaldo() Class EasyApuracao
Local cSldED3 := ""
Local cSldED4 := ""
Local cSldSW5 := ""
Local cSldSW8 := ""
Local cWorkComp := ""
Local aValores := {}
Local aSaldos := {}
Local lRet := .T.
Local cSeek := ""
Local lSeek := .F.
Local i := 0

Begin Transaction

   cSldSW5 := Self:oSldSW5:cAlias
   cSldSW8 := Self:oSldSW8:cAlias
   cSldED3 := Self:oSldED3:cAlias
   cSldED4 := Self:oSldED4:cAlias
   cWorkComp := Self:oWorkComp:cAlias

   If !Empty((cSldSW5)->(DBFilter()))
      (cSldSW5)->(DBCLEARFILTER())
   EndIf

   If !Empty((cSldSW8)->(DBFilter()))
      (cSldSW8)->(DBCLEARFILTER())
   EndIf

   If !Empty((cSldED3)->(DBFilter()))
      (cSldED3)->(DBCLEARFILTER())
   EndIf

   If !Empty((cSldED4)->(DBFilter()))
      (cSldED4)->(DBCLEARFILTER())
   EndIf

   If !Empty((cWorkComp)->(DBFilter()))
      (cWorkComp)->(DBCLEARFILTER())
   EndIf

   If Select("SW5") == 0
      DbSelectArea("SW5")
   EndIf

   If Select("SW8") == 0
      DbSelectArea("SW8")
   EndIf

   If Select("ED3") == 0
      DbSelectArea("ED3")
   EndIf

   If Select("ED4") == 0
      DbSelectArea("ED4")
   EndIf

   If Select("EDD") == 0
      DbSelectArea("EDD")
   EndIf

   (cSldED3)->(DbGoTop())
   ED3->(DbSetOrder(2)) //ED3_FILIAL+ED3_AC+ED3_SEQSIS
   Do While !(cSldED3)->(Eof())
      If !Empty((cSldED3)->&(Self:cCpoFlag))
         If ED3->(DbSeek(xFilial("ED3")+AvKey((cSldED3)->ED0_AC,"ED3_AC")+AvKey((cSldED3)->ED3_SEQSIS,"ED3_SEQSIS")))
            If RecLock("ED3",.F.)

               // Alterando os outros campos
               //AvReplace(cSldED3,"ED3")

               If aScan(aSaldos,{ |X| X[1] == (cSldED3)->ED3_PROD .And. ((X[2] == (cSldED3)->ED3_SAL_CO .And. X[3] == (cSldED3)->WORKSLDCCO) .Or. (X[2] == (cSldED3)->ED3_SAL_SE .And. X[3] == (cSldED3)->WORKSLDCSE))}) == 0
                  //Alterando os valores de cobertura
                  If (cSldED3)->ED3_SAL_CO <> (cSldED3)->WORKSLDCCO
                     RegistroCampo(cSldED3,"ED3","WORKSLDCCO","ED3_SAL_CO")
                     Self:SalvarEDF(cSldED3,"ED3_SAL_CO",AllTrim(Str((cSldED3)->ED3_SAL_CO)),AllTrim(Str((cSldED3)->WORKSLDCCO)))
                     aAdd(aSaldos,{(cSldED3)->ED3_PROD,(cSldED3)->ED3_SAL_CO,(cSldED3)->WORKSLDCCO})
                  EndIf

                  If (cSldED3)->ED3_SAL_SE <> (cSldED3)->WORKSLDCSE
                     RegistroCampo(cSldED3,"ED3","WORKSLDCSE","ED3_SAL_SE")
                     Self:SalvarEDF(cSldED3,"ED3_SAL_SE",AllTrim(Str((cSldED3)->ED3_SAL_SE)),AllTrim(Str((cSldED3)->WORKSLDCSE)))
                     aAdd(aSaldos,{(cSldED3)->ED3_PROD,(cSldED3)->ED3_SAL_SE,(cSldED3)->WORKSLDCSE})
                  EndIf
               EndIf


               If aScan(aValores,{ |X| X[1] == (cSldED3)->ED3_PROD .And. ((X[2] == (cSldED3)->ED3_VAL_SE .And. X[3] == (cSldED3)->WORKVLDSEO) .Or. (X[2] == (cSldED3)->ED3_VAL_CO .And. X[3] == (cSldED3)->WORKVLDCCO))}) == 0
                  //Alterando os valores de cobertura
                  If (cSldED3)->ED3_VAL_SE <> (cSldED3)->WORKVLDSEO
                     RegistroCampo(cSldED3,"ED3","WORKVLDSEO","ED3_VAL_SE")
                     Self:SalvarEDF(cSldED3,"ED3_VAL_SE",AllTrim(Str((cSldED3)->ED3_VAL_SE)),AllTrim(Str((cSldED3)->WORKVLDSEO)))
                     aAdd(aValores,{(cSldED3)->ED3_PROD,(cSldED3)->ED3_VAL_SE,(cSldED3)->WORKVLDSEO})
                  EndIf

                  If (cSldED3)->ED3_VAL_CO <> (cSldED3)->WORKVLDCCO
                     RegistroCampo(cSldED3,"ED3","WORKVLDCCO","ED3_VAL_CO")
                     Self:SalvarEDF(cSldED3,"ED3_VAL_CO",AllTrim(Str((cSldED3)->ED3_VAL_CO)),AllTrim(Str((cSldED3)->WORKVLDCCO)))
                     aAdd(aValores,{(cSldED3)->ED3_PROD,(cSldED3)->ED3_VAL_CO,(cSldED3)->WORKVLDCCO})
                  EndIf
               EndIf

               // Alterando os saldos
               RegistroCampo(cSldED3,"ED3","WORKSLDCAL",(cSldED3)->WORKCAMPO)
               Self:SalvarEDF(cSldED3,(cSldED3)->WORKCAMPO,AllTrim(Str((cSldED3)->WORKSALDO)),AllTrim(Str((cSldED3)->WORKSLDCAL)))

               ED3->(MsUnLock())
               //lRet := .T.  // AAF - 23/09/2013
            EndIf
         EndIf
      EndIf
      (cSldED3)->(DbSkip())
   EndDo

   (cSldED4)->(DbGoTop())
   Do While !(cSldED4)->(Eof())
      If lCompNac .And. Empty((cSldED4)->ED4_SEQSIS) .And. !Empty((cSldED4)->ED4_SEQMI)
         ED4->(DbSetOrder(8)) //ED4_FILIAL+ED4_AC+ED4_SEQMI
         cSequencia := (cSldED4)->ED4_SEQMI
      Else
         ED4->(DbSetOrder(2)) //ED4_FILIAL+ED4_AC+ED4_SEQSIS
         cSequencia := (cSldED4)->ED4_SEQSIS
      EndIf
      If !Empty((cSldED4)->&(Self:cCpoFlag))
         If ED4->(DbSeek(xFilial("ED4")+AvKey((cSldED4)->ED0_AC,"ED4_AC")+cSequencia))
            If RecLock("ED4",.F.)

               // Alterando os outros campos
               //AvReplace(cSldED4,"ED4")

               If aScan(aValores,{ |X| X[1] == (cSldED4)->ED4_ITEM .And. ((X[2] == (cSldED4)->ED4_VL_LI .And. X[3] == (cSldED4)->WORKVLRCLI) .Or. (X[2] == (cSldED4)->ED4_VL_DI .And. X[3] == (cSldED4)->WORKVLRCDI))}) == 0

                  If (cSldED4)->ED4_VL_LI <> (cSldED4)->WORKVLRCLI
                     //Alterando os valores de Li e Di
                     RegistroCampo(cSldED4,"ED4","WORKVLRCLI","ED4_VL_LI")
                     Self:SalvarEDF(cSldED4,"ED4_VL_LI", AllTrim(Str((cSldED4)->ED4_VL_LI)),AllTrim(Str((cSldED4)->WORKVLRCLI)))
                     aAdd(aValores,{(cSldED4)->ED4_ITEM,(cSldED4)->ED4_VL_LI,(cSldED4)->WORKVLRCLI})
                  EndIf

                  If (cSldED4)->ED4_VL_DI <> (cSldED4)->WORKVLRCDI
                     RegistroCampo(cSldED4,"ED4","WORKVLRCDI","ED4_VL_DI")
                     Self:SalvarEDF(cSldED4,"ED4_VL_DI", AllTrim(Str((cSldED4)->ED4_VL_DI)),AllTrim(Str((cSldED4)->WORKVLRCDI)))
                     aAdd(aValores,{(cSldED4)->ED4_ITEM,(cSldED4)->ED4_VL_DI,(cSldED4)->WORKVLRCDI})
                  EndIf
               EndIf

               // Alterando os saldos
               RegistroCampo(cSldED4,"ED4","WORKSLDCAL",(cSldED4)->WORKCAMPO)
               Self:SalvarEDF(cSldED4,(cSldED4)->WORKCAMPO,AllTrim(Str((cSldED4)->WORKSALDO)),AllTrim(Str((cSldED4)->WORKSLDCAL)))

               ED4->(MsUnLock())
               //lRet := .T.  // AAF - 23/09/2013
            EndIf
         EndIf
      EndIf
      (cSldED4)->(DbSkip())
   EndDo

   //If lRet   // AAF - 23/09/2013

      (cSldSW5)->(DbGoTop())
      //SW5->(DbSetOrder(9))
      SW5->(dbSetOrder(8)) //Indice da chave unica: W5_FILIAL+W5_PGI_NUM+W5_PO_NUM+W5_POSICAO
      Do While !(cSldSW5)->(Eof())
         //If SW5->(DbSeek(xFilial("SW5") + (cSldSW5)->(W5_AC+W5_COD_I)))
         If SW5->(DbSeek(xFilial("SW5") + (cSldSW5)->(W5_PGI_NUM+W5_PO_NUM+W5_POSICAO)))
            SW5->(RecLock("SW5",.F.))
            AvReplace(cSldSW5,"SW5")
            SW5->W5_FILIAL := xFilial("SW5")
            SW5->(MsUnLock())
         EndIf
         (cSldSW5)->(DbSkip())
      EndDo

      (cSldSW8)->(DbGoTop())
      //SW8->(DbSetOrder(5))
      SW8->(dbSetOrder(6))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
      Do While !(cSldSW8)->(Eof())
         //If SW8->(DbSeek(xFilial("SW8") + (cSldSW8)->(W8_AC+W8_COD_I)))
         If SW8->(DbSeek(xFilial("SW8") + (cSldSW8)->(W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)))
            SW8->(RecLock("SW8",.F.))
            AvReplace(cSldSW8,"SW8")
            SW8->W8_FILIAL := xFilial("SW8")
            SW8->(MsUnLock())
         EndIf
         (cSldSW8)->(DbSkip())
      EndDo

      If !Empty((cWorkComp)->(DBFilter()))
         (cWorkComp)->(DBCLEARFILTER())
      EndIf

      For i := 1 To Len(Self:aDadosEDD)
         EDD->(DbGoTo(Self:aDadosEDD[i]))
         If RecLock("EDD",.F.)
            EDD->(DbDelete())
            EDD->(MsUnLock())
         EndIf
      Next

      (cWorkComp)->(DbGoTop())
      Do While !(cWorkComp)->(Eof())

         If lCompNac .And. !Empty((cWorkComp)->EDD_SEQMI) .And. Empty((cWorkComp)->EDD_SEQSII)
            EDD->(DbSetOrder(4))//EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB
            If lIndED9EDD
               cSeek := xFilial("EDD")+(cWorkComp)->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN)
            Else
               cSeek := xFilial("EDD")+(cWorkComp)->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB)
            EndIf
         Else
            EDD->(DbSetOrder(2))//EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB
            If lIndED9EDD
               cSeek := xFilial("EDD")+(cWorkComp)->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN)
            Else
               cSeek := xFilial("EDD")+(cWorkComp)->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB)
            EndIf
         EndIf

         lSeek := EDD->(DbSeek(cSeek))
         If RecLock("EDD",!lSeek)
            AvReplace(cWorkComp,"EDD")
            EDD->(MsUnLock())
            //lRet := .T.  // AAF - 23/09/2013
         EndIf
         (cWorkComp)->(DbSkip())
      EndDo
   //EndIf
End Transaction

Return lRet

//------------------------------------------------------------------------------------------------------------------
Method SalvarEDF(cWork,cCampo,cSaldo,cSaldoCalc) Class EasyApuracao

Begin Sequence

   If Select("EDF") == 0
      DbSelectArea("EDF")
   EndIf

   If Select("ED8") == 0
      DbSelectArea("ED8")
   EndIf

   If Select("ED9") == 0
      DbSelectArea("ED9")
   EndIf

   If RecLock("EDF",.T.)
      EDF->EDF_FILIAL := xFilial("EDF")
      EDF->EDF_PD := (cWork)->ED0_PD
      EDF->EDF_MODAL := Self:cModalidade
      EDF->EDF_TABELA := (cWork)->WORKALIAS
      //EDF->EDF_DESC := (cWork)->WORKDESC
      EDF->EDF_TIPO := "A"
      EDF->EDF_DATA := Date()
      EDF->EDF_HORA := Time()
      EDF->EDF_USUARI := cUserName
      EDF->EDF_CAMPO := cCampo
      //EDF->EDF_DESCAM := (cWork)->WORKTITULO
      EDF->EDF_DE := cSaldo
      EDF->EDF_PARA := cSaldoCalc

      If AllTrim(Upper(cWork)) == Self:oSldED3:cAlias
         EDF->EDF_PROD := (cWork)->ED3_PROD
         EDF->EDF_SEQ := (cWork)->ED3_SEQSIS
         EDF->EDF_NCM := (cWork)->ED3_NCM
      EndIf

      If AllTrim(Upper(cWork)) == Self:oSldED4:cAlias
         EDF->EDF_ITEM := (cWork)->ED4_ITEM
         EDF->EDF_SEQ := (cWork)->ED4_SEQSIS
         EDF->EDF_NCM := (cWork)->ED4_NCM
      EndIf
   EndIf

End Sequence

Return Nil

//------------------------------------------------------------------------------------------------------------------
Method FechaTabelas(aAlias) Class EasyApuracao
Local i := 0

   For i := 1 To Len(aAlias)
      If Select((aAlias[i])) > 0
         (aAlias[i])->(DbCloseArea())
      EndIf
   Next

Return Nil

//-------------------------------------------------------------------------------------------------------------
Method RetButtons() Class EasyApuracao
Local aButtons := {}

Begin Sequence

   aButtons := {{"LBTIK",{||MarcaDesmarca(Self:cCpoFlag,.T.)} ,STR0047}}//"Marca/Desmarca Exportação"
                //{"LBTIK",{||MarcaDesmarca(Self:oSldED4:cAlias,Self:cCpoFlag,.T.)} ,STR0048}//"Marca/Desmarca Importação"

End Sequence

Return aClone(aButtons)

//-------------------------------------------------------------------------------------------------------------
Method RetStatus(cDado) Class EasyApuracao
Local cStatus := ""
Local nPos := 0

/* Default: importação (N)
   Quando não houver compras nacionais, assume-se que é item importado.
   Quando em fase de P.L.I./ L.I., não há carga no array. */
cStatus:= "N"
Begin Sequence

   nPos := aScan(Self:aItens,{ |X| AllTrim(Upper(X[2])) == AllTrim(Upper(cDado))})
   If nPos > 0
      If Self:aItens[nPos][1] == "1"  // Manutenção de DI
         cStatus := "N"
      ElseIf Self:aItens[nPos][1] == "2" // Compra nacionais
         cStatus := "S"
      EndIf
   EndIf
End Sequence

Return cStatus

/*
Programa   : RegistroCampo(cAliasOri,cAliasDest,cFieldOri,cFieldDes)
Parametros : cAliasOri - Tabela original
             cAliasDest - Tabela destino
             cFieldOri - Campo de origem
             cFieldDes - Campo de destino
Objetivo   : Carrega um determinado campo
Retorno    : -
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function RegistroCampo(cAliasOri,cAliasDest,cFieldOri,cFieldDes)
Local nPosOri := 0
Local nPosDes := 0
Local cDado
Default cFieldDes := cFieldOri

Begin Sequence

   nPosOri := (cAliasOri)->(FieldPos(cFieldOri))
   If nPosOri > 0
      cDado := (cAliasOri)->(FieldGet(nPosOri))
      nPosDes := (cAliasDest)->(FieldPos(cFieldDes))
      If nPosDes > 0
         (cAliasDest)->(FieldPut(nPosDes,cDado))
       EndIf
   EndIf

End Sequence

Return Nil

/*
Programa   : RetCampos(aEstrutura)
Parametros : aEstrutura - Estrutura dos campos
Objetivo   : Retorna a estrutura do campo para work
Retorno    : aCampos - estrutura para work
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function RetCampos(aEstrutura)
Local aCampos := {}
Local i := 0

Begin Sequence
   For i := 1 To Len(aEstrutura)
      If Valtype(aEstrutura[i][2])  == "C"// Campo para estrutura
         aAdd(aCampos,{aEstrutura[i][1],AvSx3(aEstrutura[i][2],2)   ,AvSx3(aEstrutura[i][2],3)   ,AvSx3(aEstrutura[i][2],4)})
       ElseIf Valtype(aEstrutura[i][2])  == "A"
         aAdd(aCampos,{aEstrutura[i][1],aEstrutura[i][2][1] , aEstrutura[i][2][2] , aEstrutura[i][2][3]})
      EndIf
   Next
End Sequence

Return aClone(aCampos)

/*
Programa   : aScanInfo(aDados,nPos,cCampo)
Parametros : aDados - Vetor que sera varrido
             nPos - posição do vetor
             cCampo - informação procurada
Objetivo   : Retorna informação de um vetor
Retorno    : nPos - retorna posicação do dado no vetor
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function aScanInfo(aDados,nPos,cCampo)
Local nPosRet := 0
Default nPos := 1

Begin Sequence
  nPosRet :=  aScan(aDados,{ |X| AllTrim(Upper(X[nPos])) == AllTrim(Upper(cCampo))})
End Sequence

Return nPosRet

/*
Programa   : RetInforma(aDados,nPos,cCampo)
Parametros : aDados - Vetor que sera varrido
             nPos - posição do vetor
             cCampo - informação procurada
Objetivo   : Retorna informação de um vetor
Retorno    : xInfo - retorna dado no vetor
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
*/
Static Function RetInforma(aDados,nPos,cCampo,nPosInfo)
Local nPosDado := 0
Local xInfo

Begin Sequence

  nPosDado := aScanInfo(aDados,nPos,cCampo)
  If nPosDado > 0 .And. nPosInfo > 0
     xInfo := aDados[nPosDado][nPosInfo]
  EndIf

End Sequence

Return xInfo

/*
Programa   : ApuraBaixa()
Parametros :
Objetivo   : Retorna informação de um vetor
Retorno    : aValores - Vetor com os valores dos saldos
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 17/10/11
Obs.       :
Revisão    : wfs 18/12/13 - tratamento multifilial
*/
Static Function ApuraBaixa()
Local aValores  := {}   ,;
      lConvert  := .T.  ,;
      nQtdLI    := 0    ,;
      nQtdNCMLI := 0    ,;
      nValLI    := 0    ,;
      nAuxLI    := 0    ,;
      nAuxNCMLI := 0    ,;
      nAuxValLI := 0    ,;
      nQtdDI    := 0    ,;
      nQtdNCMDI := 0    ,;
      nValDI    := 0    ,;
      nAuxDI    := 0    ,;
      nAuxNCMDI := 0    ,;
      nAuxValDI := 0    ,;
      nDecLI    := 0    ,;
      nDecNcmLI := 0    ,;
      nDecValLI := 0    ,;
      nDecDI    := 0    ,;
      nDecNcmDI := 0    ,;
      nDecValDI := 0    ,;
      cUnid     := ""   ,;
      i          := 0    ,;
      cFilOld   := cFilAnt,;
      aFil      := {}

   nDecLI    := AvSX3( "ED4_QT_LI" , AV_DECIMAL )
   nDecNcmLI := AvSX3( "ED4_SNCMLI", AV_DECIMAL )
   nDecValLI := AvSX3( "ED4_VL_LI" , AV_DECIMAL )
   nDecDI    := AvSX3( "ED4_QT_DI" , AV_DECIMAL )
   nDecNcmDI := AvSX3( "ED4_SNCMDI", AV_DECIMAL )
   nDecValDI := AvSX3( "ED4_VL_DI" , AV_DECIMAL )

   ChkFile("SW6")

   //wfs 18/12/13 - Tratamento multifilial
   If lMultiFil
   		aFil:= AClone(AvgSelectFil(.F.))
   Else
   		AAdd(aFil, {xFilial("SX5")})
   EndIf

   //wfs 18/12/13 - Tratamento multifilial
   For i:= 1 To Len(aFil)

   		If lMultiFil
		   cFilAnt:= aFil[i]
   		EndIF

   		SW6->( DBSetOrder(1) )
   		SW5->( DBSetOrder(9) )

   		If SW5->( DBSeek(xFilial("SW5")+ED4->ED4_AC) )
   			Do While lConvert  .And.  SW5->( !EoF()  .And.  W5_FILIAL == xFilial("SW5")  .And.  W5_AC == ED4->ED4_AC )

      			If SW5->( W5_SEQSIS == ED4->ED4_SEQSIS  .And.  W5_SEQ == 0 )

         			If ED0->ED0_TIPOAC <> GENERICO  .Or.  ED4->ED4_NCM <> NCM_GENERICA
	            		cUnid := BUSCA_UM(SW5->(W5_COD_I+W5_FABR+W5_FORN),SW5->(W5_CC+W5_SI_NUM))
    	     		EndIf

         			If ( ED0->ED0_TIPOAC == GENERICO  .And.  ED4->ED4_NCM == NCM_GENERICA )  .Or.  cUnid == ED4->ED4_UMITEM
            			nAuxLI := SW5->W5_QTDE
         			ElseIf ED4->ED4_UMITEM == KILOGRAMA  .Or.  ED4->ED4_UMITEM == KILOGRAMA2
	            		nAuxLI := SW5->W5_PESO * SW5->W5_QTDE
         			Else
	            		nAuxLI := AVTransUnid(cUnid,ED4->ED4_UMITEM,SW5->W5_COD_I,SW5->W5_QTDE,.T.)
         			EndIf

         			If ( ED0->ED0_TIPOAC == GENERICO  .And.  ED4->ED4_NCM == NCM_GENERICA )  .Or.  cUnid == ED4->ED4_UMNCM
	            		nAuxNcmLI := SW5->W5_QTDE
    	     		ElseIf ED4->ED4_UMNCM == KILOGRAMA .or. ED4->ED4_UMNCM == KILOGRAMA2
            			nAuxNcmLI := SW5->W5_PESO * SW5->W5_QTDE
         			ElseIf ED4->ED4_UMITEM == ED4->ED4_UMNCM
	            		nAuxNcmLI := nAuxLI
         			Else
	            		nAuxNcmLI := AVTransUnid(cUnid,ED4->ED4_UMNCM,SW5->W5_COD_I,SW5->W5_QTDE,.T.)
            			If Empty(nAuxNcmLI)  .And.  !Empty(nAuxLI)
	               			nAuxNcmLI := AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,SW5->W5_COD_I,nAuxLI,.T.)
            			EndIf
         			EndIf

         			nAuxValLI := ApuraValor()

         			If nAuxLI == NIL
	            		//cMens := "Não há conversão entre as Unidades de Medida do Item Importado "+AllTrim(SW5->W5_COD_I)+" ("+cUnid+") e do Ato Concessório ("+ED4->ED4_UMITEM+")."
    	        		lConvert := .F.
        	    		Exit
         			ElseIf nAuxNcmLI == NIL
            			//cMens := "Não há conversão entre as Unidades de Medida do Item Importado "+AllTrim(SW5->W5_COD_I)+" ("+cUnid+") e do Ato Concessório ("+ED4->ED4_UMNCM+")."
            			lConvert := .F.
            			Exit
         			Else
	            		nAuxLI    := Round( nAuxLI   , nDecLI )
            			nAuxNcmLI := Round( nAuxNcmLI, nDecNcmLI )
            			nAuxValLI := Round( nAuxValLI, nDecValLI )

            			nQtdLI    += nAuxLI
            			nQtdNcmLI += nAuxNcmLI
            			nValLI    += nAuxValLI
            			AAdd( aSW5, { ED4->ED4_AC+ED4->ED4_SEQSIS, SW5->(Recno()), nAuxLI, nAuxNcmLI, nAuxValLI } )
         			EndIf

      			EndIf

      			SW5->( DBSkip() )
   			EndDo


	   		SW5->( DBSetOrder(8) )
   			SW8->( DBSetOrder(5) )  // AAF - 23/09/2013
   			SW8->( DBSeek(xFilial("SW8")+ED4->ED4_AC) )
   			Do While SW8->( !EoF()  .And.  W8_FILIAL == xFilial("SW8")  .And.  W8_AC == ED4->ED4_AC)

      			If SW8->W8_SEQSIS == ED4->ED4_SEQSIS  .And.  SW6->( DBSeek(xFilial("SW6")+SW8->W8_HAWB) )  .And.  !Empty(SW6->W6_DI_NUM)
	         		If SW5->(dbSeek(xFilial("SW5")+SW8->(W8_PGI_NUM+W8_PO_NUM+W8_POSICAO))) .AND. (nPos := aScan(aSW5,{|x| x[2] == SW5->(Recno())})) > 0

    	        		nCoef := SW8->W8_QTDE / SW5->W5_QTDE

        	    		If ED0->ED0_TIPOAC <> GENERICO  .Or.  ED4->ED4_NCM <> NCM_GENERICA
            	   			nAuxDI    := nCoef * aSW5[nPos][3]//nAuxLI
               				nAuxNcmDI := nCoef * aSW5[nPos][4]//nAuxNcmLI
            			EndIf

            			nAuxValDI := nCoef * aSW5[nPos][5]//nAuxValLI

            			nAuxDI    := Round( nAuxDI   , nDecDI )
            			nAuxNcmDI := Round( nAuxNcmDI, nDecNcmDI )
            			nAuxValDI := Round( nAuxValDI, nDecValDI )

            			nQtdDI    += nAuxDI
            			nQtdNcmDI += nAuxNcmDI
            			nValDI    += nAuxValDI
            			AAdd( aSW8, { ED4->ED4_AC+ED4->ED4_SEQSIS, SW8->(Recno()), nAuxDI, nAuxNcmDI, nAuxValDI } )
         			EndIf
      			EndIf

      			SW8->( DBSkip() )
   			EndDo
   			//SW5->( DBSetOrder(9) )  // AAF - 23/09/2013

   			If lConvert
      			aValores := {}
      			AAdd( aValores,{"ED4_QT_LI" , ED4->ED4_QTDCAL - nQtdLI    })
      			AAdd( aValores,{"ED4_SNCMLI", Round(ED4->( ED4_QTDNCM * ED4_QTDCAL / ED4_QTD ),nDecNcmLI) - nQtdNcmLI })
      			AAdd( aValores,{"ED4_VL_LI" , ED4->ED4_VALCAL - nValLI    })
      			AAdd( aValores,{"ED4_QT_DI" , ED4->ED4_QTDCAL - nQtdDI    })
      			AAdd( aValores,{"ED4_SNCMDI", Round(ED4->( ED4_QTDNCM * ED4_QTDCAL / ED4_QTD ),nDecNcmDI) - nQtdNcmDI })
      			AAdd( aValores,{"ED4_VL_DI" , ED4->ED4_VALCAL - nValDI    })
   			Else
	      		aValores := {}
      			AAdd( aValores,{"ED4_QT_LI" , ED4->ED4_QTDCAL })
      			AAdd( aValores,{"ED4_SNCMLI", ED4->ED4_QTDNCM })
      			AAdd( aValores,{"ED4_VL_LI" , ED4->ED4_VALCAL })
      			AAdd( aValores,{"ED4_QT_DI" , ED4->ED4_QTDCAL })
      			AAdd( aValores,{"ED4_SNCMDI", ED4->ED4_QTDNCM })
      			AAdd( aValores,{"ED4_VL_DI" , ED4->ED4_VALCAL })
   			EndIf
   		EndIf
	Next

	cFilAnt:= cFilOld
Return aValores

*----------------------------------------------------------------------------------------------*
Static Function ApuraValor()
*----------------------------------------------------------------------------------------------*

 Local nValor, nRecAux:=SW5->(Recno()), nPesoTot:=0, nValAux:=0

   ChkFile("SW4")
   SW5->( DBSetOrder(1) )
   SW4->( DBSetOrder(1) )
   SW4->( DBSeek(xFilial("SW4")+SW5->W5_PGI_NUM) )

   IF SW4->W4_FREINC == "1"  .And.  AllTrim(SW4->W4_INCOTERM) $ "CFR,CPT,DES,DEQ,DDU"
      SW5->( DBSeek(xFilial("SW5")+SW4->W4_PGI_NUM) )
      Do While SW5->( !EoF()  .And.  W5_FILIAL+W5_PGI_NUM == xFilial("SW5")+SW4->W4_PGI_NUM )
         If SW5->W5_SEQ == 0
            nPesoTot += SW5->W5_PESO * SW5->W5_QTDE
         EndIf
         SW5->( DBSkip() )
      EndDo
      SW5->( DBGoTo(nRecAux) )
      nValAux := (SW5->W5_QTDE * SW5->W5_PRECO) - (SW4->W4_FRETEIN*((SW5->W5_PESO * SW5->W5_QTDE)/nPesoTot))
   ElseIf AllTrim(SW4->W4_INCOTERM) $ "EXW"
      nPrecoTot := 0
      SW5->( DBSeek(xFilial("SW5")+SW4->W4_PGI_NUM) )
      Do While SW5->( !EoF()  .And.  W5_FILIAL+W5_PGI_NUM == xFilial("SW5")+SW4->W4_PGI_NUM )
         If SW5->W5_SEQ == 0
            nPrecoTot += SW5->W5_QTDE * SW5->W5_PRECO
         EndIf
         SW5->( DBSkip() )
      EndDo
      SW5->( DBGoTo(nRecAux) )                           //SVG
      nValAux := (SW5->W5_QTDE * SW5->W5_PRECO) + (((SW4->W4_INLAND+SW4->W4_PACKING + SW4->W4_OUT_DES-SW4->W4_DESCONT3)*((SW5->W5_PESO * SW5->W5_QTDE)/nPrecoTot)))
   Else
      nValAux := SW5->W5_QTDE * SW5->W5_PRECO
   EndIf

   nValor := Round( ConvVal(SW4->W4_MOEDA,nValAux,,,.T.) ,2)

   SW5->( DBSetOrder(9) )
   SW5->( DBGoTo(nRecAux) )

Return nValor
