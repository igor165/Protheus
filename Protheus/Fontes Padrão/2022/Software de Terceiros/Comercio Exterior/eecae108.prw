#INCLUDE "eecae108.ch"
#include "EEC.CH"

#define ENTER CHR(13)+CHR(10)
#define FRETE     1
#define SEGURO    2
#define OUTDESP   3
#define DESCONTO  4
#define SLDINI    5

/*
Programa        : EECAE108.PRW
Objetivo        : Proc. Embarque - Rotinas Off-Shore em vários níveis(Multi Off-Shore)
Autor           : João Pedro Macimiano Trabbold
Data/Hora       : 09/03/05 - 13:22
Obs.            :
*/


/*
Funcao      : Ae108MultiOff
Parametros  :
Retorno     :
Objetivos   : Apresentar tela para informar nro. do processo Off-Shore que será replicado
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 09/03/05 - 14:00
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function Ae108MultiOff(cAlias,nReg,nOpc)
*--------------------------------------*
Local cProcOrigem := EEC->EEC_PREEMB,cNivelOffShore, lRet := .f.,i,nLinha1 := 22,nLinha2 := 20, nColuna := 6, nInc := 38, n := 14
Local bOk, bCancel, oDlg, aPosEnc, aOb := Array(10)
Local aEnc := {"EEC_PREEMB","EEC_CLIENT","EEC_CLLOJA","EEC_CLIEDE","EEC_EXPORT",;
               "EEC_EXLOJA","EEC_EXPODE","EEC_COND2" ,"EEC_DIAS2" ,"EEC_INCO2"}

Ap100InitFil()

Private aDadosOffShore := {}, lAltera := .t.

If Type("lNotShowScreen") <> "L" // JPM - 04/04/06 - Para não mostrar tela
   Private lNotShowScreen := .F.
EndIf

Begin Sequence

   If lNotShowScreen
      lRet := .T.
   Else
      If cFilEx <> EEC->EEC_FILIAL
         MsgInfo(STR0001,STR0002) //"Não pode haver replicação de um embarque da Filial Brasil."###"Aviso"
         Break
      EndIf

      // by jbj - 09/05/05 - O sistema não deverá permitir replicação de processos cancelados.
      If EEC->EEC_STATUS == ST_PC
         MsgStop(STR0011,STR0008) //"Este processo está cancelado e não poderá ser replicado."###"Atenção"
         Break
      EndIf

      //Se o importador for igual ao cliente final, então já está no último nível de Off-Shore, impossibilitando a replicação.
      If EEC->EEC_IMPORT == EEC->EEC_CLIENF
         MsgInfo(STR0009,STR0002)
         //"A replicação não poderá ser feita pois este embarque já se encontra no último nível de Off-Shore, visto que o Importador é igual ao Cliente Final.","Aviso"
         Break
      EndIf

      // Verifica se o embarque já foi replicado.
      EEC->(DbSetOrder(14))
      EEC->(DbSeek(xFilial()+cProcOrigem))
      While EEC->(!EoF()) .And. (xFilial("EEC")+cProcOrigem) == EEC->(EEC_FILIAL+EEC_PEDREF)
         If !Empty(EEC->EEC_NIOFFS)
            MsgInfo(STR0003,STR0002) //"Um mesmo embarque não pode ser replicado mais de uma vez. Replique o embarque gerado."###"Aviso"
            EEC->(DbGoTo(nReg))
            Break
         EndIf
         EEC->(DbSkip())
      EndDo
      EEC->(DbGoTo(nReg))

      // Embarques com Data de Embarque preenchida não podem ser replicados
      If !Empty(EEC->EEC_DTEMBA)
         MsgInfo(STR0010,STR0002)
         //"O embarque não poderá ser replicado pois já está com a data de embarque preenchida.","Aviso"
         Break
      EndIf

      For i := 1 to Len(aEnc)
         M->&(aEnc[i]) := CriaVar(aEnc[i])
      Next

      /*
      SA2->(DbSetOrder(1))
      If SA2->(DbSeek(xFilial()+EEC->(EEC_IMPORT+EEC_IMLOJA)))
         M->EEC_EXPORT := EEC->EEC_IMPORT
         M->EEC_EXLOJA := EEC->EEC_IMLOJA
         M->EEC_EXPODE := Posicione("SA2",1,XFILIAL("SA2")+M->EEC_EXPORT+M->EEC_EXLOJA,"A2_NOME")
      EndIF

      M->EEC_PREEMB := EEC->EEC_PREEMB
      M->EEC_COND2  := EEC->EEC_CONDPA
      M->EEC_DIAS2  := EEC->EEC_DIASPA
      M->EEC_INCO2  := EEC->EEC_INCOTE
      */
         /*aPosEnc := PosDlg(oDlg)

         oEnchoice := MsMGet():New(cAlias, nReg, INCLUIR ,,,,aEnc,aPosEnc,,,,,,oDlg,,,,,.t.)
         EnChoice(cAlias,nReg,ALTERAR,,,,aEnc,aPosEnc,,,,,,oDlg,,,,,.t.)

         oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT*/

      Define MsDialog oDlg Title STR0004 FROM 1,1 To 240,340 STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd Pixel //"Informe os dados do processo Off-Shore"

         oDlg:lEscClose := .F.
         AvBorda()
         //{"EEC_PREEMB","EEC_CLIENT","EEC_CLLOJA","EEC_CLIEDE","EEC_EXPORT",;
         //         "EEC_EXLOJA","EEC_EXPODE","EEC_COND2" ,"EEC_DIAS2" ,"EEC_INCO2"}

         @ nLinha1,nColuna         Say AvSx3("EEC_PREEMB",AV_TITULO) Pixel COLOR CLR_HBLUE
         @ nLinha2,nColuna+nInc    MsGet aOb[1] Var M->EEC_PREEMB Size 80,7 Pixel Picture AvSx3("EEC_PREEMB",AV_PICTURE) Valid .t.

         @ nLinha1+=n,nColuna      Say AvSx3("EEC_CLIENT",AV_TITULO) Pixel COLOR CLR_HBLUE
         @ nLinha2+=n,nColuna+nInc MsGet aOb[2] Var M->EEC_CLIENT Size 37,7 Pixel Picture AvSx3("EEC_CLIENT",AV_PICTURE);
                                   F3 AvSx3("EEC_CLIENT",8) Valid (Vazio() .Or. ExistCpo("SA1",M->EEC_CLIENT) );
                                   ON CHANGE (M->EEC_CLLOJA := Posicione("SA1",1,xFilial("SA1")+M->EEC_CLIENT,"A1_LOJA"),;
                                              M->EEC_CLIEDE := SA1->A1_NOME )

         @ nLinha1,nColuna+2*nInc+20  Say AvSx3("EEC_CLLOJA",AV_TITULO) Pixel COLOR CLR_HBLUE
         @ nLinha2,nColuna+3*nInc+15  MsGet aOb[3] Var M->EEC_CLLOJA Size 10,7 Pixel Picture AvSx3("EEC_CLLOJA",AV_PICTURE);
                                      Valid (Vazio() .Or. ExistCpo("SA1",M->(EEC_CLIENT+EEC_CLLOJA)) );
                                      ON CHANGE (M->EEC_CLIEDE := Posicione("SA1",1,xFilial("SA1")+M->(EEC_CLIENT+EEC_CLLOJA),"A1_NOME"))

         @ nLinha1+=n,nColuna      Say AvSx3("EEC_CLIEDE",AV_TITULO) Pixel
         @ nLinha2+=n,nColuna+nInc MsGet aOb[4] Var M->EEC_CLIEDE Size 120,7 Pixel Picture AvSx3("EEC_CLIEDE",AV_PICTURE) When .f. Valid .t.

         @ nLinha1+=n,nColuna      Say AvSx3("EEC_EXPORT",AV_TITULO) Pixel COLOR CLR_HBLUE
         @ nLinha2+=n,nColuna+nInc MsGet aOb[5] Var M->EEC_EXPORT Size 37,7 Pixel Picture AvSx3("EEC_EXPORT",AV_PICTURE);
                                   F3 AvSx3("EEC_EXPORT",8) Valid (Vazio() .Or. ExistCpo("SA2",M->EEC_EXPORT) );
                                   ON CHANGE (M->EEC_EXLOJA := Posicione("SA2",1,xFilial("SA2")+M->EEC_EXPORT,"A2_LOJA"),;
                                              M->EEC_EXPODE := SA2->A2_NOME )

         @ nLinha1 ,nColuna+2*nInc+20 Say AvSx3("EEC_EXLOJA",AV_TITULO) Pixel COLOR CLR_HBLUE
         @ nLinha2 ,nColuna+3*nInc+15 MsGet aOb[6] Var M->EEC_EXLOJA Size 10,7 Pixel Picture AvSx3("EEC_EXLOJA",AV_PICTURE);
                                      Valid (Vazio() .Or. ExistCpo("SA2",M->(EEC_EXPORT+EEC_EXLOJA)) );
                                      ON CHANGE (M->EEC_EXPODE := Posicione("SA2",1,xFilial("SA2")+M->(EEC_EXPORT+EEC_EXLOJA),"A2_NOME"))

         @ nLinha1+=n,nColuna      Say AvSx3("EEC_EXPODE",AV_TITULO) Pixel
         @ nLinha2+=n,nColuna+nInc MsGet aOb[7] Var M->EEC_EXPODE Size 120,7 Pixel Picture AvSx3("EEC_EXPODE",AV_PICTURE) When .f. Valid .t.

         @ nLinha1+=n,nColuna      Say AvSx3("EEC_COND2" ,AV_TITULO) Pixel COLOR CLR_HBLUE
         @ nLinha2+=n,nColuna+nInc MsGet aOb[8] Var M->EEC_COND2  Size 37,7 Pixel Picture AvSx3("EEC_COND2",AV_PICTURE);
                                   F3 AvSx3("EEC_COND2",8) Valid (Vazio() .Or. ExistCpo("SY6",M->EEC_COND2) );
                                   ON CHANGE (M->EEC_DIAS2 := Posicione("SY6",1,xFilial("SY6")+M->EEC_COND2,"Y6_DIAS_PA"))

         @ nLinha1 ,nColuna+2*nInc+20 Say AvSx3("EEC_DIAS2" ,AV_TITULO) Pixel COLOR CLR_HBLUE
         @ nLinha2 ,nColuna+3*nInc+15 MsGet aOb[9] Var M->EEC_DIAS2  Size 10,7 Pixel Picture AvSx3("EEC_DIAS2",AV_PICTURE);
                                      Valid (Vazio() .Or. ExistCpo("SY6",M->(EEC_COND2+STR(EEC_DIAS2,3,0))) )

         @ nLinha1+=n,nColuna      Say AvSx3("EEC_INCO2" ,AV_TITULO) Pixel COLOR CLR_HBLUE
         @ nLinha2+=n,nColuna+nInc MsGet aOb[10] Var M->EEC_INCO2  Size 8,7 Pixel Picture AvSx3("EEC_INCO2",AV_PICTURE);
                                   F3 AvSx3("EEC_INCO2",8) Valid (Vazio() .Or. ExistCpo("SYJ",M->EEC_INCO2) )

         bOk     := {|| If(Ae108ValGet(aEnc,aOb),(lRet := .t.,oDlg:End()),Nil)  }
         bCancel := {|| oDlg:End() }

      Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) Centered

   EndIf

   If lRet
      If Empty(EEC->EEC_NIOFFS)
         cNivelOffShore := "02"
      Else
         cNivelOffShore := StrZero(Val(EEC->EEC_NIOFFS)+1,2)
      EndIf

      aDadosOffShore := { {"EEC_PEDREF",""          ,cProcOrigem,EEC->(RecNo())},;
                          {"EEC_PREEMB",""          ,M->EEC_PREEMB},;
                          {"EEC_NIOFFS",""          ,cNivelOffShore},;
                          {"EEC_IMPORT","EEC_CLIENT",M->EEC_CLIENT},;
                          {"EEC_IMLOJA","EEC_CLLOJA",M->EEC_CLLOJA},;
                          {"EEC_IMPODE",""          ,M->EEC_CLIEDE},;
                          {"EEC_FORN"  ,"EEC_EXPORT",M->EEC_EXPORT},;
                          {"EEC_FOLOJA","EEC_EXLOJA",M->EEC_EXLOJA},;
                          {"EEC_FORNDE",""          ,M->EEC_EXPODE},;
                          {"EEC_CONDPA","EEC_COND2" ,M->EEC_COND2},;
                          {"EEC_DIASPA","EEC_DIAS2" ,M->EEC_DIAS2},;
                          {"EEC_INCOTE","EEC_INCO2" ,M->EEC_INCO2},;
                          {""          ,"EEC_INTERM","1"      } }

      EEC->(MsUnlock())
      lRet := AE100MAN(cAlias,nReg,ALTERAR)
   EndIf

End Sequence

If Len(aDadosOffShore) > 0
   EEC->(DbSeek(xFilial()+aDadosOffShore[2][3]))
   If EEC->(Eof())
      EEC->(DbGoTo(aDadosOffShore[1][4]))
   EndIf
EndIf

If EECFlags("ORD_PROC")
   EEC->(DbSetOrder(13))
Else
   EEC->(DbSetOrder(1))
EndIf

Return lRet

/*
Funcao      : Ae108ValGet
Parametros  :
Retorno     : .t. ou .f.
Objetivos   : Validar nº do processo Off-Shore
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 09/03/05 - 14:56
Revisao     :
Obs.        :
*/
*--------------------------------------*
Static Function Ae108ValGet(aEnc,aOb)
*--------------------------------------*
Local nRec := EEC->(RecNo()), lRet := .t., i

Begin Sequence

   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))
      Help(" ",1,"JAGRAVADO")
      lRet := .f.
      Break
   EndIf

  For i := 1 to Len(aOb)
      If !Eval(aOb[i]:bValid)
         lRet := .f.
         Break
      EndIf
   Next

   For i := 1 to len(aEnc)
      If Empty(&("M->"+aEnc[i])) .And. aEnc[i] <> "EEC_DIAS2"
         MsgInfo(STR0005,STR0002) //"Preencha todos os campos."###"Aviso"
         lRet := .f.
         Break
      EndIf
   Next

End Sequence

EEC->(DbGoTo(nRec))

Return lRet

/*
Funcao      : Ae108AtuSld
Parametros  : lSoma : .t. - Adiciona ao saldo
                      .f. - Subtrai do saldo
Retorno     :
Objetivos   : Atualizar saldo do pedido para embarque replicado, para que o saldo do pedido não seja atualizado
              incorretamente.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 09/03/05 - 14:00
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function Ae108AtuSld(lSoma)
*--------------------------------------*
Local lRet := .t., aOrd := SaveOrd({"EE8","EE9"}), nValor

Begin Sequence

   EE8->(DbSetOrder(1))

   WorkIp->(DbGoTop())
   While WorkIp->(!EoF())

      If !Empty(WorkIp->WP_FLAG)
         EE8->(DbSeek(xFilial()+WorkIp->(EE9_PEDIDO+EE9_SEQUEN)))
         EE8->(RecLock("EE8",.f.))
         nValor := If(lSoma,WorkIp->EE9_SLDINI,-(WorkIp->EE9_SLDINI))
         EE8->EE8_SLDATU += nValor
      EndIf

      WorkIp->(DbSkip())

   EndDo

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : Ae108TrataWorks
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Atualizar o campos de amarração com o embarque das works
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 11/03/05 - 16:30
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function Ae108TrataWorks()
*--------------------------------------*
Local aFiles  := {"EE9"   ,"EET"   ,"EEN"   ,"EEB"   ,"EEJ"   }
Local aFilesW := {"WorkIP","WorkDe","WorkNo","WorkAg","WorkIn"}
Local nRec, nRecAtual,i

Begin Sequence

   For i:=1 To Len(aFiles)

      (aFilesW[i])->(DbGoTop())
      While (aFilesW[i])->(!Eof())
         nRecAtual:=(aFilesW[i])->(RecNo())
         (aFilesW[i])->(DbSkip())
         nRec:=(aFilesW[i])->(RecNo())
         (aFilesW[i])->(Dbgoto(nRecAtual))

         If aFiles[i] == "EE9"
            WorkIp->EE9_PREEMB := M->EEC_PREEMB //Muda o processo
            WorkIP->WP_RECNO   := 0 // Limpa o Recno
         Else
            (aFilesW[i])->&(If(aFiles[i] # "EEN","_PEDIDO","_PROCES")) := M->EEC_PREEMB //Muda o processo
            (aFilesW[i])->&(If(aFiles[i] # "EET","WK_RECNO","EET_RECNO")) := 0 //Limpa o recno
         EndIf

         (aFilesW[i])->(Dbgoto(nRec))
      Enddo

   Next

End Sequence

Return Nil

/*
Funcao      : Ae108LimpaInterm()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Limpa os campos de intermediação do processo de origem
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 12/03/05 - 11:18
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function Ae108LimpaInterm()
*--------------------------------------*
Local i, aOrd := SaveOrd({"EEC"}), nRec

Begin Sequence
   nRec := EEC->(RecNo())

   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(xFilial()+EEC->EEC_PEDREF))
      If EEC->(RecLock("EEC",.f.))
         For i := 1 To Len(aInterm)
            EEC->&(aInterm[i]) := CriaVar(aInterm[i])
         Next

         EEC->EEC_INTERM := ""
         EEC->EEC_CLIENT := ""
         EEC->EEC_CLLOJA := ""
         EEC->EEC_EXPORT := ""
         EEC->EEC_EXLOJA := ""
         EEC->EEC_COND2  := ""
         EEC->EEC_DIAS2  := 0
         EEC->EEC_INCO2  := ""
         EEC->(DbGoTo(nRec))
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return Nil

/*
Funcao      : Ae108VldSelPed().
Parametros  : cPed - Nro do pedido selecionado.
Retorno     : .t./.f.
Objetivos   : Validar a seleção do pedido de referência (campo pedido de referência e
              tela de seleção de pedido, na rotina de marcação/desmarcação de itens).
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/04/05 - 17:20
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108VldSelPed(cProc)
*----------------------------*
Local lRet := .t.
Local aOrd := SaveOrd({"EE7"})
Local lIncItem := .T.  // PLB 12/09/06 - Verifica se a chamada foi feita pelo Pedido de Referencia ou pela inclusao de Itens

Default cProc := M->EEC_PEDREF

// PLB 12/09/06
If ReadVar() == "M->EEC_PEDREF"
   lIncItem := .F.
EndIf

Begin Sequence

   EE7->(DbSetOrder(1))
   If lConsign .And. EE7->(DbSeek(xFilial()+cProc))
      If (cTipoProc == PC_VR .Or. cTipoProc == PC_VB)
         If EE7->EE7_TIPO <> PC_VC
            MsgInfo(STR0056,STR0008)//"O pedido informado não pode ser utilizado pois é de tipo diferente do Embarque."###"Atenção"
            lRet := .F.
            Break
         EndIf
      ElseIf EE7->EE7_TIPO <> cTipoProc
         MsgInfo(STR0056, STR0008)//"O pedido informado não pode ser utilizado pois é de tipo diferente do Embarque."###"Atenção"
         lRet := .F.
         Break
      EndIf
   EndIf

   /* A rotina abaixo só realiza os tratamentos para ambientes com a rotina de intermediação habilitada e
      para a filial do exterior. */

   If !lIntermed .Or. Empty(cProc) //.Or. AvGetM0Fil() == cFilBr
      Break
   EndIf

   cProc := AvKey(Upper(AllTrim(cProc)),"EE7_PEDIDO")

   If AvGetM0Fil() == cFilEx
      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(cFilBr+cProc))
         MsgStop(AllTrim(AvSx3("EE7_PEDIDO",AV_TITULO))+STR0006+; //" deverá ser embarcado na filial Brasil, visto que o mesmo possui "
                 STR0007,STR0008) //"tratamentos de off-shore"###"Atenção"
         lRet:=.f.
         Break
      EndIf

   //** PLB 12/09/06 - Validacao de Pedidos com e sem Off-Shore
   ElseIf AvGetM0Fil() == cFilBr  .And.  lIncItem
      EE7->( DBSetOrder(1) )
      If EE7->( DBSeek(cFilBr+cProc) )  .And.  EE7->EE7_INTERM != M->EEC_INTERM
         If M->EEC_INTERM $ cSim
            MsgStop(STR0113,STR0008)  //"O pedido informado nao pode ser utilizado pois nao possui tratamentos de off-shore e o embarque possui tratamentos de off-shore."###"Atenção"
         Else
            MsgStop(STR0114,STR0008)  //"O pedido informado nao pode ser utilizado pois possui tratamentos de off-shore e o embarque nao possui tratamentos de off-shore."
         EndIf
         lRet := .F.
         Break
      EndIf
   EndIf
   //**

End Sequence

RestOrd(aOrd,.t.)

Return lRet


/*
Funcao      : AE108InvGrv().
Parametros  : lGRVs  -> .T. ->GERA WORK
                        .F. ->GRAVA "EXP","EXR"
              cTipo -> "CAPA" - Grava e le o "EXP"
                       "DETALHE" - Grave e le o "EXR"
Retorno     : Nenhum
Objetivos   : Grava a Work das Invoices
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 - 10:30
Revisao     :
Obs.        :
*/
*----------------------------*
Function AE108InvGrv(lGrv,cTipo,lIntegracao)
*----------------------------*
Local nInc , cCpo , nPos

Begin Sequence

   If cTipo == "CAPA"

      IF !lGRV

         For nInc:=1 to LEN(aCInvDeletados)
            EXP->(dbGoto(aCInvDeletados[nInc]))
            RecLock("EXP",.F.)
            EXP->(DBDELETE())
            EXP->(MsUnlock())
         Next nInc

        WorkInv->(DBGOTOP())

        While ! WorkInv->(EOF())
            //LGS-13/01/2016
            If IsLocked("EXP")
               EXP->(MsUnlock())
            EndIf

            If WorkInv->EXP_RECNO # 0
               EXP->(DBGOTO(WorkInv->EXP_RECNO))
               RecLock("EXP",.F.)
            Else
               RecLock("EXP",.T.)  // bloquear e incluir registro vazio
            EndIf

            AVReplace("WorkInv","EXP")

            EXP->EXP_PREEMB := M->EEC_PREEMB
            EXP->EXP_FILIAL := xFilial("EXP")
            EXP->(MsUnlock())

            WorkInv->(DBSKIP())

         Enddo

      Else
         AVReplace("EXP","WorkInv")
         WorkInv->EXP_RECNO := EXP->(RECNO())
      EndIf

   ElseIf cTipo == "DETALHE"

      IF !lGRV

         For nInc:=1 to LEN(aDInvDeletados)
            EXR->(dbGoto(aDInvDeletados[nInc]))
            RecLock("EXR",.F.)
            EXR->(DBDELETE())
            EXR->(MsUnlock())
         Next nInc

        WorkDetInv->(DBGOTOP())

        While ! WorkDetInv->(EOF())
            //LGS-13/01/2016
            If IsLocked("EXR")
               EXP->(MsUnlock())
            EndIf

            If WorkDetInv->EXR_RECNO # 0
               EXR->(DBGOTO(WorkDetInv->EXR_RECNO))
               RecLock("EXR",.F.)
            Else
               RecLock("EXR",.T.)  // bloquear e incluir registro vazio
            EndIf

            AVReplace("WorkDetInv","EXR")

            EXR->EXR_PREEMB := M->EEC_PREEMB
            EXR->EXR_FILIAL := xFilial("EXR")
            EXR->(MsUnlock())

            WorkDetInv->(DBSKIP())

         Enddo

      Else

         WorkIP->(dbSetOrder(2))
         WorkIp->(dbSeek(EXR->EXR_SEQEMB))

         For nInc := 1 TO WorkDetInv->(FCount())
            cCpo := WorkDetInv->(FieldName(nInc))
            cCpo := "EE9"+SubStr(AllTrim(cCpo),4)
            If ( nPos := WorkIp->(FieldPos(cCpo))) # 0
               WorkDetInv->(FieldPut(nInc,WorkIp->(FieldGet(FieldPos(cCpo))) ))
            EndIf
         Next nInc
         AVReplace("EXR","WorkDetInv")
         /*WHRS TE-5406 508979 / MTRADE-674 - Ao selecionar o item da invoice, não apresenta o preço unitário e número do pedido*/
         	WorkDetInv->EXR_PEDIDO := WorkIp->EE9_PEDIDO
         	WorkDetInv->EXR_COD_I  := WorkIp->EE9_COD_I
         	WorkDetInv->EXR_FORN   := WorkIp->EE9_FORN
         	WorkDetInv->EXR_FOLOJA := WorkIp->EE9_FOLOJA
         	WorkDetInv->EXR_FABR   := WorkIp->EE9_FABR
         	WorkDetInv->EXR_FALOJA := WorkIp->EE9_FALOJA
         	WorkDetInv->EXR_PRECO  := WorkIp->EE9_PRECO
         	WorkDetInv->EXR_PSLQUN := WorkIp->EE9_PSLQUN
         	WorkDetInv->EXR_PSBRUN := WorkIp->EE9_PSBRUN
         	WorkDetInv->EXR_LC_NUM := WorkIp->EE9_LC_NUM
         /*FIM WHRS*/
         WorkDetInv->EXR_RECNO := EXR->(RECNO())
      EndIf

   EndIf

End Sequence

Return Nil

/*
Funcao      : Ae108ManutInv().
Parametros  : nOpc
Retorno     : Nenhum
Objetivos   : Manutencao de Invoices
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 - 10:30
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108ManutInv(nOpc)
*----------------------------*
Local nOldArea := Select()
Local oDlg, oMark_Inv
Local lInverte := .F.
Local nOpcao := 0
Local bOk  := {|| nOpcao := 1 , oDlg:End() }
Local bCancel  := {|| nOpcao := 0 , oDlg:End() }
Local aButtons := {}
Local cFileBak1 := "", cFileBak2 := "", cFilebak3 := "", cFileBak4 := ""
Local nRecIP := WorkIp->(RecNo())
Local cFile
Local aCapDelete := aClone(aCInvDeletados)
Local aDetDelete := aClone(aDInvDeletados)

Private aTela[0][0],aGets[0],aHeader[0]
Private aEnchEECInv := {"EEC_PREEMB","EEC_DTPROC","EEC_TOT_PED","EEC_INCOTE","EEC_FRPREV",;
                        "EEC_SEGPRE","EEC_DESPIN","EEC_DESCON"}

//Para permitir alterar invoices já embarcadas (habilitar via Rdmake)
Private lAlteraEmb := .F.

aSemSx3 := {{"WK_FLAG" ,"C",2,0}}

WorkIP->(dbSetOrder(2))

aHeader := {}
aCampos := Array(EXR->(FCount()))
cFile := E_CriaTrab("EXR",aSemSx3,"WrkSldInv")
IndRegua("WrkSldInv",cFile+TEOrdBagExt(),"EXR_PEDIDO+EXR_SEQUEN" /*"EXR_SEQEMB"*/) //LGS-12/01/2016

Begin Sequence

   If EasyEntryPoint("EECAE108")
      ExecBlock("EECAE108", .F., .F., "MANUTINV_INI")
   EndIf

   If WorkIp->(Eof() .And. Bof())
      Help(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
      Break
   EndIf

   cFileBak1 := CriaTrab(,.f.)
   dbSelectArea("WorkInv")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   //Copy to (cFileBak1+GetdbExtension())
   TETempBackup(cFileBak1) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   cFileBak2 := CriaTrab(,.f.)
   dbSelectArea("WorkDetInv")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   //Copy to (cFileBak2+GetdbExtension())
   TETempBackup(cFileBak2) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   If EECFlags("CAFE")
      cFileBak3:=CriaTrab(,.F.)
      dbSelectArea("WKEXZ")
      //Copy to (cFileBak3+GetdbExtension())
      TETempBackup(cFileBak3) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      cFileBak4:=CriaTrab(,.F.)
      dbSelectArea("WKEY2")
      //Copy to (cFileBak4+GetdbExtension())
      TETempBackup(cFileBak4) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
   EndIf

   aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| Ae108CapInv(VIS_DET,oMark_Inv)},STR0012}) //"Visualizar"
   If lAlteraEmb
      aAdd(aButtons,{"EDIT",{|| Ae108CapInv(ALT_DET,oMark_Inv)},STR0014}) //"Alterar"
   EndIf

   If nOpc # VISUALIZAR .And. nOpc # EXCLUIR .And. Empty(M->EEC_DTEMBA)  .And.  !lLockInv  // PLB 20/09/06 - Var lLockInv verifica se o Processo com tratamento Off-Shore possui Data de Embarque na filial Exterior

      aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/   ,{|| Ae108CapInv(INC_DET,oMark_Inv)},STR0013}) //"Incluir"
      aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/,{|| Ae108CapInv(ALT_DET,oMark_Inv)},STR0014}) //"Alterar"
      aAdd(aButtons,{"EXCLUIR",{|| Ae108CapInv(EXC_DET,oMark_Inv)},STR0015}) //"Excluir"
      aAdd(aButtons,{"FORM"   ,{|| If(!WorkInv->(Eof() .And. Bof()),;
                                   If(WrkSldInv->(Eof() .And. Bof()),;
                                   Ae108ApDesp(.T.),MsgInfo(STR0120,STR0021)),;//STR0120	"Há Itens com saldo não vinculados a Invoices, rateio não será realizado"//STR0021 	"Atenção"
                                   MsgInfo(STR0121,STR0122)), oMark_Inv:oBrowse:Refresh() },STR0016}) //"Ratear Despesas" //STR0121	"Não há Invoices Cadastradas"//STR0122	"Informação"

      Processa({|| Ae108SldInv() },STR0017)             //"Lendo Itens..."

   EndIf

   WorkInv->(dbGoTop())

   Define MsDialog oDlg Title STR0018 From ; //"Manunteção de Invoices"
                  DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM STYLE Of oMainWnd Pixel

      EnChoice("EEC",,3, , , ,aEnchEECInv,PosDlgUp(oDlg),{},3,,,,,,,,,.T.)

      oMark_Inv := MsSelect():New("WorkInv",,,aInvBrowse,@lInverte,@cMarca,PosDlgDown(oDlg))
      oMark_Inv:bAval := {|| Ae108CapInv(VIS_DET,oMark_Inv)}

      oDlg:lMaximized := .T.

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   If nOpcao == 0 //Cancelar

      aCInvDeletados := aClone(aCapDelete)
      aDInvDeletados := aClone(aDetDelete)

      dbSelectArea("WorkInv")
      AvZap()
      TERestBackup(cFileBak1)

      dbSelectArea("WorkDetInv")
      AvZap()
      TERestBackup(cFileBak2)

      If EECFlags("CAFE")
         dbSelectArea("WKEXZ")
         AvZap()
         TERestBackup(cFileBak3)

         dbSelectArea("WKEY2")
         AvZap()
         TERestBackup(cFileBak4)

      EndIf

   Else
      Ae108ApDesp(.F.)
   EndIf

   FErase(cFileBak1+GetDBExtension())
   FErase(cFileBak2+GetDBExtension())

   If EECFlags("CAFE")
      If( File(cFileBak3+GetDbExtension()),FErase(cFileBak3+GetDBExtension()),)
      If( File(cFileBak4+GetDBExtension()),FErase(cFileBak4+GetDBExtension()),)
   EndIf

End Sequence

WrkSldInv->(E_EraseArq(cFile))

WorkIp->(dbGoTo(nRecIP))

dbSelectArea(nOldArea)

Return

/*
Funcao      : Ae108CapInv().
Parametros  : nTipoDS := INC_DET/VIS_DET/ALT_DET/EXC_DET
Retorno     : .T.
Objetivos   : Detalhes das Invoices
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 - 10:30
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108CapInv(nTipoDS,oMark_Inv)
*----------------------------*
Local lRet:=.T.,cOldArea:=select(),oDlg,nInc,nOpcA:=0,nRECNO
Local nRecOld := WorkInv->(RecNo())
Local oMark_Det, lInverte:=.F.
//Local aButtons := {}
Local bOk := {|| nOpcA:=1,If(Ae108ValInv(nTipoDS,nRECNO),oDlg:End(),nOpcA:=0)}
Local bCancel := {|| nOpcA:=0,oDlg:End()}
Local cFileBak1 := "", cFileBak2 := "", cFileBak3 := "", cFileBak4 := ""
Local cTitulo := STR0036 //"Invoice"
Private aTela[0][0],aGets[0],aHeader[0]
Private lAltNrInv := .F.
Private aButtons := {}   // By JPP - 05/01/2010
Private nOpcInv := nTipoDS, lRetPE := .T.  // GFP - 16/10/2013 - Variavel para PE

If EECFlags("CAFE")
   Private cPrefix := AllTrim("002"+EasyGParam("MV_AVG0120",,""))
EndIf

Begin Sequence

   IF nTipoDS # INC_DET
      IF WorkInv->(Eof() .And. Bof())
         Help(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
         Break
      Endif
   Endif

   IF nTipoDS == INC_DET
      If WrkSldInv->(Eof() .And. Bof())
         MsgInfo(STR0123,STR0122)//STR0123	"Não há Itens com saldo a vincular, Invoice não poderá ser incluida" //STR0122	"Informação"
         Break
      EndIf
      WorkInv->(dbGoBottom())
      WorkInv->(dbSkip())
      lAltNrInv := .T.
   Endif

   cFileBak1 :=CriaTrab(,.F.)
   dbSelectArea("WorkDetInv")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   //Copy to (cFileBak1+GetdbExtension())
   TETempBackup(cFileBak1) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   cFileBak2 :=CriaTrab(,.F.)
   dbSelectArea("WrkSldInv")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   //Copy to (cFileBak2+GetdbExtension())
   TETempBackup(cFileBak2) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   If EECFlags("CAFE")
      cFileBak3:=CriaTrab(,.F.)
      dbSelectArea("WKEXZ")
      //Copy to (cFileBak3+GetdbExtension())
      TETempBackup(cFileBak3) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      cFileBak4:=CriaTrab(,.F.)
      dbSelectArea("WKEY2")
      //Copy to (cFileBak4+GetdbExtension())
      TETempBackup(cFileBak4) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
   EndIf

   If ! (Str(nTipoDS,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1))
      If EECFlags("CAFE")
         aAdd(aButtons,{"VINCULA1",{|| Ae108VincInv(oMark_Det)},STR0104})  //"Vincular OIC´s"
      Else
         aAdd(aButtons,{"VINCULA1",{|| Ae108VincInv(oMark_Det)},STR0019})  //"Vincular Itens"
      EndIf

   EndIf

   nRECNO:=WorkInv->(RECNO())
   SX3->(dbSetOrder(2))

   For nInc := 1 TO WorkInv->(FCount())
      If nTipoDS == INC_DET
         If SX3->(dbSeek(WorkInv->(FieldName(nInc))))
            M->&(WorkInv->(FieldName(nInc))) := CriaVar(WorkInv->(FieldName(nInc)))
         EndIf
      Else
         M->&(WorkInv->(FieldName(nInc))) := WorkInv->(FieldGet(nInc))
      EndIf
   Next nInc

   If nTipoDS == INC_DET
      cTitulo += STR0124 //STR0124	" - Incluir"
   ElseIf nTipoDS == ALT_DET
      cTitulo += STR0125 //STR0125	" - Alterar"
   ElseIf nTipoDS == VIS_DET
      cTitulo += STR0126 //STR0126	" - Visualizar"
   ElseIf nTipoDS == EXC_DET
      cTitulo += STR0127 //STR0127	" - Excluir"

   EndIf

   WorkDetInv->(dbSetOrder(1))

   dbSelectArea("WorkDetInv")
   Set Filter to WorkDetInv->EXR_NRINVO = M->EXP_NRINVO

   WorkDetInv->(dbGoTop())

   If EasyEntryPoint("EECAE108")  // By JPP - 05/01/2010
      ExecBlock("EECAE108",.F.,.F.,{"ANTES_ENCHOICE_EXP",nTipoDS})
   Endif

   IF(EasyEntryPoint("EECAE108"),ExecBlock("EECAE108",.F.,.F.,"VALIDA_INVOICE"),)  // GFP - 16/10/2013
   IF !lRetPE
      Return lRetPE
   ENDIF

   Define MsDialog oDlg Title cTitulo From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel

      EnChoice("EXP", , 3, , , ,aInvEnchoice , PosDlgUp(oDlg),IF(STR(nTipoDS,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},) , 3 )

      oMark_Det := MsSelect():New("WorkDetInv",,,aDetInvBrowse,@lInverte,@cMarca,PosDlgDown(oDlg))
      oMark_Det:bAval := {|| Ae108DetInv() }

      oDlg:lMaximized := .T.

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   dbSelectArea("WorkDetInv")
   Set Filter to

   If nOpcA != 0

      If nTipoDS == INC_DET
         WorkInv->(DBAPPEND())
      EndIf

      If ! (Str(nTipoDS,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1))
         AVReplace("M","WorkInv")
      EndIf

   Else //Se Cancelar a Manutencao

      dbSelectArea("WorkDetInv")
      AvZap()
      TERestBackup(cFileBak1)

      dbSelectArea("WrkSldInv")
      AvZap()
      TERestBackup(cFileBak2)

      If EECFlags("CAFE")
         dbSelectArea("WKEXZ")
         AvZap()
         TERestBackup(cFileBak3)

         dbSelectArea("WKEY2")
         AvZap()
         TERestBackup(cFileBak4)

      EndIf

      IF nTipoDS == INC_DET
         WorkInv->(dbGoto(nRecOld))
      Endif
   EndIf

   FErase(cFileBak1+GetDBExtension())
   FErase(cFileBak2+GetDBExtension())

   If EECFlags("Cafe")
      If( File(cFileBak3+GetDbExtension()),FErase(cFileBak3+GetDBExtension()),)
      If( File(cFileBak4+GetDBExtension()),FErase(cFileBak4+GetDBExtension()),)
   EndIf

   oMark_Inv:oBrowse:Refresh()

End Sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao      : Ae108ValInv()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Valida Invoice
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function  Ae108ValInv(nTipo,nRecno)
*----------------------------*

   Local lRet:=.T., nInc, x, aSldOic := {}, aOicDesv := {}

   Begin Sequence

      If EasyEntryPoint("EECAE108")  // By JPP - 24/11/2006 - 11:50 - Passagem do ponto de entrada para o sistema padrão.
         lRet := ExecBlock("EECAE108",.F.,.F.,{"VALINV",nTipo})
         If ValType(lRet) == "L"
            If !lRet
               Break
            EndIf
         Else
            lRet := .T.
         EndIf
      EndIf

      If nTipo == INC_DET .OR. nTipo = ALT_DET
         lRet:=Obrigatorio(aGets,aTela)

         If lRet
            WorkDetInv->(dbSetOrder(1))
            If !WorkDetInv->(dbSeek(M->EXP_NRINVO))
               MsgStop(STR0020,STR0021) //"Não há itens vinculados com a Invoice"###"Atenção"
               lRet := .F.
            EndIf
         EndIf

      ElseIf nTIPO==EXC_DET .AND. MsgNoYes(STR0037,STR0038) //'Confirma Exclusao ? '###'Excluir'

         WorkDetInv->(dbSetOrder(1))
         WorkDetInv->(dbSeek(WorkInv->EXP_NRINVO))
         Do While !WorkDetInv->(Eof()) .And. ;
                  WorkDetInv->EXR_NRINVO == WorkInv->EXP_NRINVO

            If !Empty(WorkDetInv->EXR_RECNO)
               Aadd(aDInvDeletados,WorkDetInv->EXR_RECNO)
            EndIf

            If !WrkSldInv->(dbSeek(WorkDetInv->(EXR_PEDIDO+EXR_SEQUEN) ))//LGS-14/01/2016
               WrkSldInv->(dbAppend())
               AvReplace("WorkDetInv","WrkSldInv")
               WrkSldInv->EXR_SALDO := 0 //FJH 08/09/05 Quando o item não tem saldo entra aqui.
                                         //saldo igual a 0 para não errar o valor do saldo
            EndIf
            WrkSldInv->EXR_SALDO  += WorkDetInv->EXR_SLDINI

            WorkDetInv->(dbDelete())
            WorkDetInv->(dbSkip())

         EndDo

         If EECFlags("CAFE")//RMD - 25/11/05 - Manutenção de OIC´s - Exclui os vinculos entre a Invoice e os OIC´s.
            WKEY2->(DbGoTop())
            While WKEY2->(!Eof() )

               If WKEY2->EY2_NRINVO == WorkInv->EXP_NRINVO
                  aAdd(aSldOic, {WKEY2->(EY2_OIC+EY2_SAFRA), WKEY2->EY2_SEQEMB, WKEY2->EY2_QTDE, WKEY2->(Recno())})
                  WKEXZ->(DbSetOrder(1))
                  WKEXZ->(DbSeek(WKEY2->(EY2_OIC+EY2_SAFRA)))
                  WKEXZ->WK_SLDINV += WKEY2->EY2_QTDE
               ElseIf Empty(WKEY2->EY2_NRINVO)
                  aAdd(aOicDesv, {WKEY2->(EY2_OIC+EY2_SAFRA), WKEY2->EY2_SEQEMB, WKEY2->(Recno())})
                  WKEXZ->(DbSetOrder(1))
                  WKEXZ->(DbSeek(WKEY2->(EY2_OIC+EY2_SAFRA)))
                  WKEXZ->WK_SLDINV += WKEY2->EY2_QTDE
               EndIf

            WKEY2->(DbSkip())
            EndDo
            WKEY2->(DbSetOrder(1))
            For nInc := 1 To Len(aSldOic)
               If (x := aScan(aOicDesv, {|x| x[1] == aSldOic[nInc][1] .And. x[2] == aSldOic[nInc][2]})) > 0
                  WKEY2->(DbGoTo(aOicDesv[x][3]))
                  WKEY2->EY2_QTDE += aSldOic[nInc][3]
                  WKEY2->(DbGoTo(aSldOic[nInc][4]))
                  If(!Empty(WKEY2->WK_RECNO), aAdd(aDetOICDel, WKEY2->WK_RECNO),)
                  WKEY2->(DbDelete())
               Else
                  WKEY2->(DbGoTo(aSldOic[nInc][4]))
                  WKEY2->EY2_NRINVO := Criavar("EY2_NRINVO")
               EndIf
            Next
         EndIf

         If !Empty(WorkInv->EXP_RECNO)
            Aadd(aCInvDeletados,WorkInv->EXP_RECNO)
         EndIf

         WorkInv->(dbDelete())

         WorkInv->(dbSkip(-1))
         IF WorkInv->(Bof())
            WorkInv->(dbGoTop())
         Endif

      EndIf

   End Sequence

Return lRet

/*
Funcao      : Ae108VincInv()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Vincula Itens das Invoices
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108VincInv(oMark_Det)
*----------------------------*
Local lRet := .T. , nOldArea := Select()
Local oDlg, oMark_Sld, lInverte:=.F.
Local nOpcao := 0
Local bOk := {|| nOpcao:=1 , oDlg:End() }
Local bCancel := {|| nOpcao:=0 , oDlg:End() }
Local aTbCampos := {}
Local aButtons, bMarca, bMarcaAll
Local cFileBak1 := "", cFileBack2 := "", cFileback3 := "", cWork := "WrkSldInv"
Local cTitle := STR0025 + " - " + Trans(M->EXP_NRINVO,AvSx3("EXP_NRINVO",AV_PICTURE))
Private cArqOic1 := ""

Begin Sequence

   cFileBak1:=CriaTrab(,.F.)
   dbSelectArea("WrkSldInv")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   //Copy to (cFileBak1+GetdbExtension())
   TETempBackup(cFileBak1) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   If EECFlags("CAFE")
      WKEXZ->(DbGoTop())
      WKEXZ->(dbEval({|| WKEXZ->WK_FLAG := Space(2) },,{|| WKEXZ->(!Eof()) }))
      WKEXZ->(DbGoTop())
      While WKEXZ->(!Eof())
         WKEY2->(DbSetOrder(1))
         If WKEY2->(DbSeek(WKEXZ->(EXZ_OIC+EXZ_SAFRA)))
            While WKEY2->(!Eof() .And. WKEY2->EY2_OIC == WKEXZ->EXZ_OIC .And. WKEY2->EY2_SAFRA == WKEXZ->EXZ_SAFRA)
               If WKEY2->EY2_NRINVO == M->EXP_NRINVO
                  WKEXZ->WK_FLAG := cMarca
                  Exit
               EndIf
               WKEY2->(DbSkip())
            EndDo
         EndIf
         WKEXZ->(DbSkip())
      EndDo
      //FSM - 19/07/2012
      //WKEXZ->(DbSetFilter({|| WKEXZ->WK_SLDINV > 0 .Or. WKEXZ->WK_FLAG == cMarca},"WKEXZ->WK_SLDINV > 0 .Or. WKEXZ->WK_FLAG == cMarca"))
      cCond := "WK_SLDINV > 0 .Or. WK_FLAG == '" + cMarca +"'"
      WKEXZ->(DbSetFilter({|| &cCond }, cCond))


      aSemSx3 := {{"WK_RECNO" ,"N", 10, 0},;
                  {"WK_TOTIT" ,"N", 15, 3},;
                  {"WK_TOTVIN","N", 15, 3},;
                  {"WK_FLAG"  ,"C",  2, 0}}

      Ae109Works("CREATE", {{"WKITOIC","EY2","cArqOic1",,,aSemSx3,,}})

      cFileBak2:=CriaTrab(,.F.)
      dbSelectArea("WKEXZ")
      //Copy to (cFileBak2+GetdbExtension())
      TETempBackup(cFileBak2) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      cFileBak3:=CriaTrab(,.F.)
      dbSelectArea("WKEY2")
      //Copy to (cFileBak3+GetdbExtension())
      TETempBackup(cFileBak3) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      cTitle := STR0128 + " - " + Trans(M->EXP_NRINVO,AvSx3("EXP_NRINVO",AV_PICTURE))//STR0128	"Seleção de OIC´s Invoice"

   Endif

   If Empty(M->EXP_NRINVO)
      MsgStop(STR0022,STR0021) //"É necessário digitar o Nr. da Invoice."###"Atenção"
      Break
   EndIf

   WorkDetInv->(dbSetOrder(1))
   WorkDetInv->(dbSeek(M->EXP_NRINVO))

   // MPG - 09/10/2018 - CORREÇÃO DOS VALORES DAS INVOICES
   WrkSldInv->(dbEval({|| WrkSldInv->WK_FLAG    := "" , WrkSldInv->EXR_SLDINI := 0 /*, WrkSldInv->EXR_PRCTOT := 0*/ }))

   Do While !WorkDetInv->(Eof()) .And. ;
            WorkDetInv->EXR_NRINVO == M->EXP_NRINVO

      If !WrkSldInv->(dbSeek(WorkDetInv->(EXR_PEDIDO+EXR_SEQUEN) ))//LGS-14/01/2016
         WrkSldInv->(dbAppend())
      EndIf
      AvReplace("WorkDetInv","WrkSldInv")
      WrkSldInv->WK_FLAG    := cMarca
      WorkDetInv->(dbSkip())

   EndDo

   Aadd(aTbCampos,{"WK_FLAG"    ,, "  "})
   Aadd(aTbCampos,{"EXR_PEDIDO" ,"",AvSx3("EXR_PEDIDO",AV_TITULO),AvSx3("EXR_PEDIDO",AV_PICTURE) })
   //LGS-13/01/2016
   /*Aadd(aTbCampos,{"EXR_SEQEMB" ,"",AvSx3("EXR_SEQEMB",AV_TITULO),AvSx3("EXR_SEQEMB",AV_PICTURE) })*/
   Aadd(aTbCampos,{"EXR_SEQUEN" ,"",AvSx3("EXR_SEQUEN",AV_TITULO),AvSx3("EXR_SEQUEN",AV_PICTURE) })
   Aadd(aTbCampos,{"EXR_COD_I"  ,"",AvSx3("EXR_COD_I" ,AV_TITULO),AvSx3("EXR_COD_I" ,AV_PICTURE) })
   Aadd(aTbCampos,{{|| MEMOLINE(WrkSldInv->EXR_VM_DES,60,1)}  ,"",AvSx3("EXR_VM_DES",AV_TITULO)  })
   Aadd(aTbCampos,{"EXR_SLDINI" ,"",AvSx3("EXR_SLDINI",AV_TITULO),AvSx3("EXR_SLDINI",AV_PICTURE) })
   Aadd(aTbCampos,{"EXR_PRECO"  ,"",AvSx3("EXR_PRECO" ,AV_TITULO),AvSx3("EXR_PRECO",AV_PICTURE)  })
   //Aadd(aTbCampos,{{|| TRANSF(WrkSldInv->(EXR_PRECO*EXR_SLDINI),AvSx3("EXR_PRCTOT",AV_PICTURE))} ,"",AvSx3("EXR_PRCTOT",AV_TITULO) })
   Aadd(aTbCampos,{ "EXR_PRCTOT","",AvSx3("EXR_PRCTOT",AV_TITULO),AvSx3("EXR_PRCTOT",AV_PICTURE) }) // MPG - 09/10/2018 - CORREÇÃO DOS VALORES DAS INVOICES
   Aadd(aTbCampos,{"EXR_SALDO"  ,"",AvSx3("EXR_SALDO" ,AV_TITULO),AvSx3("EXR_SALDO" ,AV_PICTURE)  })

   WrkSldInv->(dbGoTop())

   bMarca    := {|| Ae108MarkInv("ITEM") , oMark_Sld:oBrowse:Refresh() }

   bMarcaAll := {|| Ae108MarkInv("TODOS") , oMark_Sld:oBrowse:Refresh()  }

   If EECFlags("CAFE")
      cWork := "WKEXZ"
      WKEXZ->(DbGoTop())
      aTbCampos := aClone(aEXZBrowse)
      aAdd(aTbCampos,Nil)
      aIns(aTbCampos,1)
      aTbCampos[1] := {"WK_FLAG",""," "}
      Aadd(aTbCampos,{{|| TRANSF(WKEXZ->WK_SLDINV,AvSx3("EXZ_QTDE",AV_PICTURE))} ,"","Saldo a Vinc." })
      bMarca    := {|| AE108ItOIC() , oMark_Sld:oBrowse:Refresh() }
      bMarcaAll := {|| Ae108MarkOIC("TODOS_OIC"), oMark_Sld:oBrowse:Refresh()  }

      DEFINE MSDIALOG oDlg TITLE cTitle FROM DLG_LIN_INI+(DLG_LIN_FIM/4),DLG_COL_INI+(DLG_COL_FIM/4);//"Seleção de OIC´s Invoice -"
                                           TO DLG_LIN_FIM-(DLG_LIN_FIM/4),DLG_COL_FIM-(DLG_COL_FIM/4);
   						                   OF oMainWnd PIXEL

   Else
      Define MsDialog oDlg Title cTitle From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Seleção de Itens Invoice"
   EndIf

         aButtons := {{"LBTIK",bMarcaAll,STR0024}} //"Marca/Desmarca Todos"

         //by CRF 13/10/2010 - 15:53
         aTbCampos := AddCpoUser(aTbCampos,"EXR","2")


         oMark_Sld := MsSelect():New(cWork,"WK_FLAG",,aTbCampos,@lInverte,@cMarca,PosDlg(oDlg))
         oMark_Sld:bAval := bMarca

         oDlg:lMaximized := .T.

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   dbSelectArea("WorkDetInv")
   Set Filter to

   If EECFlags("CAFE")
      WKEXZ->(DbClearFilter())
      Ae109Works("ZAP", {{"WKITOIC","EY2","cArqOic1",,,,,}})
      WKEXZ->(DbGoTop())
      WKEXZ->(dbEval({|| WKEXZ->WK_FLAG := Space(2) },,{|| WKEXZ->(!Eof()) }))
   EndIf

   If nOpcao == 1

      WorkDetInv->(dbSetOrder(1))

      M->EXP_PESLIQ := 0
      M->EXP_PESBRU := 0
      //LGS-14/01/2016
      M->EXP_FRPREV := 0
      M->EXP_SEGPRE := 0
      M->EXP_DESPIN := 0
      M->EXP_DESCON := 0
      M->EXP_VLFOB  := 0
      M->EXP_TOTPED := 0

      WrkSldInv->(dbGoTop())

      Do While !WrkSldInv->(Eof())

         If Empty(WrkSldInv->WK_FLAG)

            //Caso tenha sido desmarcado
            If WorkDetInv->(dbSeek(M->EXP_NRINVO+WrkSldInv->(EXR_PEDIDO+EXR_SEQUEN) ))//LGS-14/01/2016
               If !Empty(WorkDetInv->EXR_RECNO)
                  Aadd(aDInvDeletados,WorkDetInv->EXR_RECNO)
               EndIf
               WorkDetInv->(dbDelete())
            EndIf

         Else

            lAltNrInv := .F. // Nao alterar nr. da invoice apos vincular

            If !WorkDetInv->(dbSeek(M->EXP_NRINVO+WrkSldInv->(EXR_PEDIDO+EXR_SEQUEN) ))//LGS-14/01/2016
               WorkDetInv->(dbAppend())
            EndIf

            AvReplace("WrkSldInv","WorkDetInv")
            WorkDetInv->EXR_NRINVO := M->EXP_NRINVO

            WorkIP->(dbSetOrder(2))
            WorkIp->(dbSeek(WorkDetInv->EXR_SEQEMB))

            M->EXP_PESLIQ += AvTransUnid(WorkIp->EE9_UNPES,M->EEC_UNIDAD,WorkIp->EE9_COD_I,WorkDetInv->EXR_PSLQTO,.F.)

            M->EXP_PESBRU += AvTransUnid(WorkIp->EE9_UNPES,M->EEC_UNIDAD,WorkIp->EE9_COD_I,WorkDetInv->EXR_PSBRTO,.F.)

            M->EXP_LC_NUM := WorkDetInv->EXR_LC_NUM // ** assumir o nr. da L/C para a Capa da Invoice.
            //LGS-14/01/2016
            M->EXP_FRPREV += WorkDetInv->EXR_VLFRET
            M->EXP_SEGPRE += WorkDetInv->EXR_VLSEGU
            M->EXP_DESPIN += WorkDetInv->EXR_VLOUTR
            M->EXP_DESCON += WorkDetInv->EXR_VLDESC
            M->EXP_VLFOB  += WorkDetInv->EXR_PRCINC
            M->EXP_TOTPED += WorkDetInv->EXR_PRCTOT

         EndIf

         If WrkSldInv->EXR_SALDO = 0
            WrkSldInv->(dbDelete())
         EndIf

         WrkSldInv->(dbSkip())

      EndDo
      Ae108ApDesp(.F.,.F.) //LGS-14/01/2016
   Else //Se Cancelar nao altera o saldo.

      dbSelectArea("WrkSldInv")
      AvZap()
      TERestBackup(cFileBak1)

      If EECFlags("CAFE")

         dbSelectArea("WKEXZ")
         AvZap()
         TERestBackup(cFileBak2)

         dbSelectArea("WKEY2")
         AvZap()
         TERestBackup(cFileBak3)

      EndIf
   EndIf

   If (File(cFileBak1+GetDBExtension()),FErase(cFileBak1+GetDBExtension()),)

   If EECFlags("CAFE")
      If(File(cFileBak2+GetDBExtension()),FErase(cFileBak2+GetDBExtension()),)
      If(File(cFileBak3+GetDBExtension()),FErase(cFileBak3+GetDBExtension()),)
   EndIf

   dbSelectArea("WorkDetInv")
   Set Filter to WorkDetInv->EXR_NRINVO = M->EXP_NRINVO

End Sequence

WorkDetInv->(dbGoTop())
oMark_Det:oBrowse:Refresh()

dbSelectArea(nOldArea)

Return lRet

/*
Funcao      : Ae108SldInv()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Grava a Work com o Saldo do Itens a Vincular
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108SldInv()
*----------------------------*
Local lRet := .T., lWrkSldInv := .F. //LGS-12/01/2016
Local cCpo , nPos, nInc
local aOrd := SaveOrd({"WorkDetInv"}) //LGS-12/01/2016
Local aValores := {} //LRS - 16/08/2017 
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)
Local nDespesas
Local nDecTot := EasyGParam("MV_AVG0110",, 2)

ProcRegua(WorkIp->(EasyRecCount("WorkIp")))

WorkIp->(dbGoTop())

Do While !WorkIp->(Eof())

   IncProc(STR0017) //"Lendo Itens..."

   aValores := Ae108ItSldInv(WorkIp->(EE9_PEDIDO+EE9_SEQUEN)/*EE9_SEQEMB*/)   //LGS-12/01/2016
   //LRS - 16/08/2017  
   If aValores[1][1] > 0 

      //LGS-12/01/2016
      lWrkSldInv := WrkSldInv->(dbSeek(WorkIp->(EE9_PEDIDO+EE9_SEQUEN) ))

      If !lWrkSldInv
         WrkSldInv->(dbAppend())
      EndIf

      For nInc := 1 TO WrkSldInv->(FCount())
         cCpo := WrkSldInv->(FieldName(nInc))
         cCpo := "EE9"+SubStr(AllTrim(cCpo),4)
         If ( nPos := WorkIp->(FieldPos(cCpo))) # 0
            WrkSldInv->(FieldPut(nInc,  WorkIp->(FieldGet(FieldPos(cCpo))) ))
         EndIf
      Next nInc

      //LRS - 16/08/2017  
      WrkSldInv->EXR_SLDINI:= 0
      WrkSldInv->EXR_SALDO  := aValores[1][1]
      WrkSldInv->EXR_VLFRET := aValores[1][2]
      WrkSldInv->EXR_VLSEGU := aValores[1][3]
      WrkSldInv->EXR_VLOUTR := aValores[1][4]
      WrkSldInv->EXR_VLDESC := aValores[1][5]
      //WrkSldInv->EXR_PRCTOT := aValores[1][6]
      //WrkSldInv->EXR_PRCINC := aValores[1][7]
      If M->EEC_PRECOA $ cSim
         nDespesas := WrkSldInv->EXR_VLFRET + WrkSldInv->EXR_VLSEGU + WrkSldInv->EXR_VLOUTR// - WrkSldInv->EXR_VLDESC
      Else
         nDespesas := WrkSldInv->EXR_VLFRET + WrkSldInv->EXR_VLSEGU + WrkSldInv->EXR_VLOUTR// + WrkSldInv->EXR_VLDESC
      EndIf

      If M->EEC_PRECOA $ cSim
         WrkSldInv->EXR_PRCTOT := Round((WrkSldInv->EXR_PRECO * WrkSldInv->EXR_SALDO) + nDespesas - WrkSldInv->EXR_VLDESC,nDecTot) //Total do item
         WrkSldInv->EXR_PRCINC := Round(WrkSldInv->EXR_PRECO * WrkSldInv->EXR_SALDO,nDecTot) //FOB
      Else
        
         If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
            WrkSldInv->EXR_PRCTOT := Round(WrkSldInv->EXR_PRECO * WrkSldInv->EXR_SALDO - WrkSldInv->EXR_VLDESC ,nDecTot) //Total do item
            WrkSldInv->EXR_PRCINC := Round((WrkSldInv->EXR_PRECO * WrkSldInv->EXR_SALDO) - nDespesas,nDecTot) //FOB
         Else
            WrkSldInv->EXR_PRCTOT := Round(WrkSldInv->EXR_PRECO * WrkSldInv->EXR_SALDO ,nDecTot) //Total do item
            WrkSldInv->EXR_PRCINC := Round((WrkSldInv->EXR_PRECO * WrkSldInv->EXR_SALDO) - nDespesas + WrkSldInv->EXR_VLDESC,nDecTot) //FOB
         EndIf
         
      Endif

   EndIf

   WorkIp->(dbSkip())

EndDo
RestOrd(aOrd,.T.)
Return lRet

/*
Funcao      : Ae108ItSldInv()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Saldo o saldo do Itens nas Invoices.
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108ItSldInv(cChave)//cSeqEmb //LGS-12/01/2016
*----------------------------*
Local nSaldo := nFrete := nSeguro := nOutras := nDesconto := nPrecoTot := nPrecoFob := 0 //WorkIp->EE9_SLDINI //LGS-12/01/2016 //LRS - 16/08/2017  
Local aOrd := SaveOrd({"WorkIP"})
Local aValores := {} //LRS - 16/08/2017 
//LGS-12/01/2016
WorkIP->(DbSetOrder(1))
WorkIp->(DbSeek(cChave))

Do While WorkIp->(!Eof()) .And. WorkIp->(EE9_PEDIDO+EE9_SEQUEN) ==  cChave
   If Empty(WorkIP->WP_FLAG)
      nSaldo += IF(EMPTY(WorkIP->WP_OLDINI),WorkIP->WP_SLDATU,WorkIP->WP_OLDINI)
   Else
      nSaldo += WorkIp->EE9_SLDINI
   EndIf
      //LRS - 16/08/2017 
      nFrete    += WorkIp->EE9_VLFRET
      nSeguro   += WorkIp->EE9_VLSEGU
      nOutras   += WorkIp->EE9_VLOUTR
      nDesconto += WorkIp->EE9_VLDESC
      nPrecoTot += WorkIP->EE9_PRCTOT
      nPrecoFob += WorkIP->EE9_PRCINC

   WorkIp->(DbSkip())
EndDo


WorkDetInv->(dbSetOrder(2))

WorkDetInv->(dbSeek(cChave))//LGS-12/01/2016

Do While !WorkDetInv->(Eof()) .And. ;
         WorkDetInv->(EXR_PEDIDO+EXR_SEQUEN) == cChave //LGS-12/01/2016

   nSaldo -= WorkDetInv->EXR_SLDINI

   WorkDetInv->(dbSkip())

EndDo
//LRS - 16/08/2017  
AADD(aValores,{nSaldo,nFrete,nSeguro,nOutras,nDesconto,nPrecoTot,nPrecoFob})

WorkDetInv->(dbSetOrder(1))
RestOrd(aOrd,.T.)

Return aValores


/*
Funcao      : Ae108DetInv
Parametros  :
Retorno     : .T.
Objetivos   : Marca e desmarcar Itens na vinculacao da Invoice.
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108DetInv()
*----------------------------*
Local lRet := .T.
Local oDlg
Local bOk := {|| oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local nInc
Private aTela[0][0],aGets[0],aHeader[0]

Begin Sequence

   For nInc := 1 TO WorkDetInv->(FCount())
      M->&(WorkDetInv->(FieldName(nInc))) := WorkDetInv->(FieldGet(nInc))
   Next nInc

   Define MsDialog oDlg Title STR0026 + Trans(M->EXP_NRINVO,AvSx3("EXP_NRINVO",AV_PICTURE)) ; //"Item Invoice - "
          From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel

      EnChoice("EXR", , 3, , , ,aDetInvEnchoice,PosDlg(oDlg),{},3)

      oDlg:lMaximized := .T.

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

End Sequence

Return lRet


/*
Funcao      : Ae108MarkInv
Parametros  : cTipo = "ITEM" - Marca item 1 a 1 .
              cTipo = "TODOS" - Marca todos os Itens.
Retorno     : .T.
Objetivos   : Marca e desmarcar Itens na vinculacao da Invoice.
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108MarkInv(cTipo)
*----------------------------*
Local lRet := .T.
Local oDlg  
Local nOpcao := 0
Local bOk := {|| If(Ae108ValCpo("VINCULA_ITEM"),(nOpcao:=1,oDlg:End()),) }
Local bCancel := {|| nOpcao:=0 , oDlg:End() }
Local nRecNo,nInc,aPos
Local nDecTot := EasyGParam("MV_AVG0110",, 2)

Private aTela[0][0],aGets[0],aHeader[0]

Begin Sequence

   If EasyEntryPoint("EECAE108")  // By JPP - 24/11/2006 - 11:50 - Passagem do ponto de entrada para o sistema padrão.
      lRet := ExecBlock("EECAE108",.F.,.F.,{"MARKINV",cTipo})
      If ValType(lRet) == "L"
         If !lRet
            Break
         EndIf
      Else
         lRet := .T.
      EndIf
   EndIf

   Do Case

      Case cTipo == "ITEM"

         If Empty(WrkSldInv->WK_FLAG) // Marcar

            For nInc := 1 TO WrkSldInv->(FCount())
            	IF FieldName(nInc) == "EXR_NRINVO" ///*WHRS     TE-5406 508979 / MTRADE-674 - Ao selecionar o item da invoice, não apresenta o preço unitário e número do pedido*/ 
            		M->&(WrkSldInv->(FieldName(nInc))) := M->EXP_NRINVO
            	ELSE
               		M->&(WrkSldInv->(FieldName(nInc))) := WrkSldInv->(FieldGet(nInc))
              	ENDIF
            Next nInc

            M->EXR_SLDINI := WrkSldInv->EXR_SALDO

            If !Empty(M->EXR_QE)
               If (M->EXR_SLDINI % M->EXR_QE) != 0
                  M->EXR_QTDEM1 := Int(M->EXR_SLDINI/M->EXR_QE)+1 //QUANT.DE EMBAL.
               Else
                  M->EXR_QTDEM1 := Int(M->EXR_SLDINI/M->EXR_QE) //QUANT.DE EMBAL.
               Endif
            Endif

            //Ap101CalcPsBr("INV",.T.,,.T.)
            ae108ValCpo("EXR_SLDINI",.F.)
            If !EECFlags("CAFE")
               Define MsDialog oDlg Title STR0025 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Seleção de Itens Invoice"

                  aPos := PosDlg(oDlg) //FJH 08/09/05 Correcao no posicionamento dos campos em baixa resolucao
                  nTamCol := (aPos[4]-aPos[2])/3

                  nLinha := aPos[1]+5
                  nCol1  := aPos[2]+10
                  nCol2  := nCol1 + nTamCol
                  nCol3  := nCol2 + nTamCol

                  @ aPos[1],aPos[2] To aPos[1]+19,aPos[4] Of oDlg Pixel

                  @ nLinha+2,nCol1 Say AvSx3("EXP_NRINVO",AV_TITULO) Of oDlg Pixel
                  @ nLinha,nCol1+45 Get M->EXP_NRINVO Picture AvSx3("EXP_NRINVO",AV_PICTURE) When .F. Size 60,7 Of oDlg Pixel

                  @ nLinha+2,nCol2 Say AvSx3("EXP_DTINVO",AV_TITULO) Of oDlg Pixel
                  @ nLinha,nCol2+45 Get M->EXP_DTINVO Picture AvSx3("EXP_DTINVO",AV_PICTURE) When .F. Size 60,7 Of oDlg Pixel

                  @ nLinha+2,nCol3 Say AvSx3("EXR_SALDO",AV_TITULO) Of oDlg Pixel
                  @ nLinha,nCol3+40 Get M->EXR_SALDO Picture AvSx3("EXR_SALDO",AV_PICTURE) When .F. Size 60,7 Of oDlg Pixel


                  aPos[1]+=20

                  EnChoice("EXR", , 3, , , ,aDetInvEnchoice,aPos,aAltDetInv,3)

                  oDlg:lMaximized := .T.  

               Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

            Else
               nOpcao := 1
               M->EXR_SLDINI := WKEY2->EY2_QTDE
            EndIf

            If nOpcao = 1

               AVReplace("M","WrkSldInv")
               WrkSldInv->WK_FLAG    := cMarca
               WrkSldInv->EXR_SALDO  -= WrkSldInv->EXR_SLDINI
               //WrkSldInv->EXR_PRCTOT := Round(WrkSldInv->EXR_SLDINI*WrkSldInv->EXR_PRECO,nDecTot)
               /*RMD - Retirado tratamento desnecessário, neste ponto os pesos já foram recalculados na validação do campo "EXR_SLDINI", além disso a função
                       tenta acessar dados do arquivo de trabalho "WorkDetInv", que ainda não foi atualizada neste ponto.

               Ap101CalcPsBr("INV",.T.)
               */
            EndIf

         Else // Desmarca

            WrkSldInv->WK_FLAG    := ""
            WrkSldInv->EXR_SALDO  += WrkSldInv->EXR_SLDINI    // Ao Desmarca retorna o saldo do Item.
            WrkSldInv->EXR_SLDINI := 0
            //WrkSldInv->EXR_PRCTOT := 0

         EndIf


      Case cTipo == "TODOS"

         nRecNo := WrkSldInv->(RecNo())

         If Empty(WrkSldInv->WK_FLAG) // Marcar
            WrkSldInv->(dbGoTop())
            WrkSldInv->(dbEval({|| WrkSldInv->WK_FLAG    := cMarca ,;
                                   WrkSldInv->EXR_SLDINI := WrkSldInv->EXR_SALDO ,;   // Ao Marca todos assume o saldo do Item.
                                   WrkSldInv->EXR_SALDO  := 0,;
                                   CalcPrcTot("WrkSldInv") }))
                                   //WrkSldInv->EXR_PRCTOT := Round(WrkSldInv->EXR_SLDINI*WrkSldInv->EXR_PRECO,nDecTot) },{|| Empty(WrkSldInv->WK_FLAG) }))
								   // MPG - 09/10/2018 - CORREÇÃO DOS VALORES DAS INVOICES
         Else // Desmarca
            WrkSldInv->(dbGoTop())
            WrkSldInv->(dbEval({|| WrkSldInv->WK_FLAG    := "" ,;
                                   WrkSldInv->EXR_SALDO  += WrkSldInv->EXR_SLDINI,;  // Ao Desmarca retorna o saldo do Item.
                                   WrkSldInv->EXR_SLDINI := 0 }))
                                   //WrkSldInv->EXR_PRCTOT := 0 })) // MPG - 09/10/2018 - CORREÇÃO DOS VALORES DAS INVOICES
         EndIf

         WrkSldInv->(dbGoTo(nRecNo))

   End Case

End Sequence

Return lRet


/*
Funcao      : Ae108ValCpo()
Parametros  : cCampo
Retorno     : .T.
Objetivos   : Validacao do EXP e EXR.
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108ValCpo(cCampo,lTela)
*----------------------------*
Local lRet := .T.
Local cLCNUM, nRecSld, aOrd := SaveOrd({"EXP","WorkIp","WorkDetInv"})
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)
Default lTela := .T.
Begin Sequence

   Do Case

      Case cCampo == "GRAVA_EMBARQUE"

         If !WorkInv->(Eof() .And. Bof()) .And. !Empty(M->EEC_DTEMBA) // Se houver alguma Invoice Cadastrada
            nRecWorkIp := WorkIp->(RecNo())
            Processa({|| lRet := Ae108SldVal() })
            WorkIp->(dbGoTo(nRecWorkIp))
            If !lRet
               MsgStop(STR0027,STR0021) //"Há saldo de Itens não vinculados a Invoices."###"Atenção"
               Break
            EndIf

            WorkInv->(dbGoTop())
            Do While !WorkInv->(Eof())
               EXP->(dbSetOrder(2))
               If EXP->(dbSeek(xFilial("EXP")+WorkInv->EXP_NRINVO)) .And. EXP->EXP_PREEMB <> M->EEC_PREEMB
                  MsgStop(STR0028 + AllTrim(TRANS(WorkInv->EXP_NRINVO,AvSx3("EXP_NRINVO",AV_PICTURE))) +; //"Invoice "
                          STR0029,STR0021) //" já cadastrada em outro processo."###"Atenção"
                  lRet := .F.
                  Break
               EndIf
               WorkInv->(dbSkip())
            EndDo

            If lRefazRateio
               Ae108ApDesp(.F.)
            EndIf

         EndIf

      Case cCampo == "VINCULA_ITEM"

         lRet := Obrigatorio(aGets,aTela)

         If lRet //.And. !Empty(WrkSldInv->EXR_LC_NUM)

            nRecSld := WrkSldInv->(RecNo())
            cLCNUM  := WrkSldInv->EXR_LC_NUM

            // ** Nao deixar vincular na mesma invoice itens com L/C diferentes.
            WrkSldInv->(dbGoTop())
            Do While !WrkSldInv->(Eof())
               If Empty(WrkSldInv->WK_FLAG)
                  WrkSldInv->(dbSkip()); Loop
               EndIf
               If cLCNUM <> WrkSldInv->EXR_LC_NUM
                  lRet := .f.
                  MsgStop(STR0039,STR0021) //"Não pode ser vinculado Item de outra Carta de Crédito."###"Atenção"
                  Break
               EndIf
               WrkSldInv->(dbSkip())
            EndDo
            WrkSldInv->(dbGoTo(nRecSld))
         EndIf

      Case cCampo == "EXP_NRINVO"

         If WorkInv->(dbSeek(M->EXP_NRINVO))
            MsgStop(STR0030,STR0021) //"Invoice já cadastrada neste processo."###"Atenção"
            lRet := .F.
            Break
         EndIf

         EXP->(dbSetOrder(2))
         If EXP->(dbSeek(xFilial("EXP")+M->EXP_NRINVO))
            MsgStop(STR0031,STR0021) //"Invoice já cadastrada em outro processo."###"Atenção"
            lRet := .F.
            Break
         EndIf

      Case cCampo == "EXP_FRPREV"

         lRefazRateio := .T.

      Case cCampo == "EXP_SEGPRE"

         lRefazRateio := .T.

      Case cCampo == "EXP_DESPIN"

         lRefazRateio := .T.

      Case cCampo == "EXP_DESCON"

         lRefazRateio := .T.

      Case cCampo == "EXR_SLDINI"

         If lTela .And. M->EXR_SLDINI > M->EXR_SALDO
            MsgStop(STR0032,STR0033) //"Quantidade selecionada maior que o saldo disponível"###"Atençao"
            lRet := .F.
            Break
         EndIf

         If lTela .And. !Empty(M->EXR_QE)
            If (M->EXR_SLDINI % M->EXR_QE) != 0
               Help(" ",1,"AVG0000637") //MsgStop("Quantidade informada não e multipla pela quantidade na Embalagem !","Aviso")
               M->EXR_QTDEM1 := Int(M->EXR_SLDINI/M->EXR_QE)+1 //QUANT.DE EMBAL.
            Else
               M->EXR_QTDEM1 := Int(M->EXR_SLDINI/M->EXR_QE) //QUANT.DE EMBAL.
            Endif
         Endif

         Ap101CalcPsBr("INV",.T.,,.T.)

            // MPG - 09/10/2018 - CORREÇÃO DOS VALORES DAS INVOICES
         CalcPrcTot("M")

         lRefazRateio := .T.

   EndCase

End Sequence

RestOrd(aOrd)

Return lRet


/*
Funcao      : Ae108ApDesp()
Parametros  :
Retorno     : .T.
Objetivos   : Apura os totais da Invoices se houver alteracao nos Itens.
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*------------------------------------*
Function Ae108ApDesp(lTela,lCalcWork) //LGS-12/01/2016
*------------------------------------*
Local cOldArea := Select()
Local aOrd := SaveOrd({"WorkIP","WorkDetInv"})
Local nRecIp := WorkIP->(RecNo())
Local nRecInv := WorkInv->(RecNo())
Local lAcerto  := EasyGParam("MV_AVG0092",,.t.)//Define se haverá acerto nos itens ao final.
//Local nDecTot  := AvSx3("EXR_PRCTOT",AV_DECIMAL)
//Local nDecPrc := EasyGParam("MV_AVG0109",, 4) WFS 21/10/08
Local nDecTot := EasyGParam("MV_AVG0110",, 2)

Local nRecUltReg,aVlInvDesp,nRateio,nDespesas,nQtd
Local lDelCapa, l_OK := .T.
Local lRateioOk := .F.
Local nPreco := 0
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)
Local aVlCampos := {}
Default lCalcWork := .T. //LGS-12/01/2016

If Type("lConvUnid") == "U"
   lConvUnid := (EEC->(FieldPos("EEC_UNIDAD")) # 0) .And. (EE9->(FieldPos("EE9_UNPES")) # 0) .And.;
                (EE9->(FieldPos("EE9_UNPRC"))  # 0)
EndIf

WorkDetInv->(dbSetOrder(2))
WorkIP->(dbSetOrder(1)) //2 //LGS-12/01/2016

//If !WorkInv->(Eof() .And. Bof())// Somente se existir invoice cadastrada. // MPG - 09/10/2018 - CORREÇÃO DOS VALORES DAS INVOICES

   If lCalcWork .And. Select("WrkSldInv") > 0 //LGS-12/01/2016
      If !WrkSldInv->(Eof() .And. Bof())   // ** Nao realizar o Rateio qnd houver saldo de Itens.
         Return
      EndIf
   EndIf

   WorkIp->(dbGoTop())
   //WorkInv->(dbGoTop()) // MPG - 09/10/2018 - CORREÇÃO DOS VALORES DAS INVOICES

/*NOPADO - 30/01/2019 - Sempre deve apurar as despesas e totais para as Invoices
   If lTela
      l_OK := MsgYesNo(STR0034,STR0021) //"Deseja apurar as despesas e totais para as Invoices? "###"Atenção"
   EndIf
*/
   If l_OK

      Do While !WorkIp->(Eof())

         aVlInvDesp := {0,0,0,0}
         nRecUltReg := 0

         If WorkDetInv->(dbSeek(WorkIp->(EE9_PEDIDO+EE9_SEQUEN) /*EE9_SEQEMB*/))//LGS-12/01/2016

            // ** Acerta os precos da Invoices
            Do While !WorkDetInv->(Eof()) .And.;
                     WorkDetInv->(EXR_PEDIDO+EXR_SEQUEN) == WorkIp->(EE9_PEDIDO+EE9_SEQUEN)/*EE9_SEQEMB*/ //LGS-12/01/2016
               aVlCampos := Ae108SumCpo()
               nRateio := WorkDetInv->EXR_SLDINI / aVlCampos[SLDINI] //LGS-12/01/2016

               WorkDetInv->EXR_VLFRET := aVlCampos[FRETE] * nRateio //LGS-12/01/2016
               WorkDetInv->EXR_VLSEGU := aVlCampos[SEGURO] * nRateio //LGS-12/01/2016
               WorkDetInv->EXR_VLOUTR := aVlCampos[OUTDESP] * nRateio //LGS-12/01/2016
               WorkDetInv->EXR_VLDESC := aVlCampos[DESCONTO] * nRateio //LGS-12/01/2016

               aVlInvDesp[1] += WorkDetInv->EXR_VLFRET
               aVlInvDesp[2] += WorkDetInv->EXR_VLSEGU
               aVlInvDesp[3] += WorkDetInv->EXR_VLOUTR
               aVlInvDesp[4] += WorkDetInv->EXR_VLDESC


               /* WFS - 21/10/08: Correção para cálculo das despesas na Invoice, considerando
                                  preço aberto e fechado*/
               If M->EEC_PRECOA $ cSim
                  nDespesas := WorkDetInv->(EXR_VLFRET + EXR_VLSEGU + EXR_VLOUTR /*- EXR_VLDESC*/ )
               Else
                  nDespesas := WorkDetInv->(EXR_VLFRET + EXR_VLSEGU + EXR_VLOUTR /*+ EXR_VLDESC*/ )
               EndIf
               nPreco := WorkIp->EE9_PRECO

               //Cálculo da quantidade quando se usa a conversão de unidade de medidas
               If lConvUnid
                  nQtd := AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkDetInv->EXR_SLDINI,.F.)
               Else
                  nQtd := WorkDetInv->EXR_SLDINI
               EndIf

               If M->EEC_PRECOA $ cSim
                  WorkDetInv->EXR_PRCTOT := Round((nPreco*nQtd)+nDespesas - WorkDetInv->EXR_VLDESC,nDecTot) //Total do item
                  WorkDetInv->EXR_PRCINC := Round(nPreco*nQtd,nDecTot) //FOB
               Else
                  
                  If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
                     WorkDetInv->EXR_PRCTOT := Round(nPreco*nQtd - WorkDetInv->EXR_VLDESC,nDecTot) //Total do item
                     WorkDetInv->EXR_PRCINC := Round((nPreco*nQtd)-nDespesas ,nDecTot) //FOB
                  Else
                     WorkDetInv->EXR_PRCTOT := Round(nPreco*nQtd ,nDecTot) //Total do item
                     WorkDetInv->EXR_PRCINC := Round((nPreco*nQtd)-nDespesas + WorkDetInv->EXR_VLDESC,nDecTot) //FOB
                  EndIf
               Endif

               //----- WFS - 21/10/08

               //AR - 12/01/10
               If EasyEntryPoint("EECAE108")
                  ExecBlock("EECAE108", .F., .F., "RATEIO_INVOICE")
               EndIf

               lRateioOk:= .T.

               nRecUltReg := WorkDetInv->(RecNo())

               WorkDetInv->(dbSKip())

            EndDo

           If lAcerto .And. nRecUltReg <> 0

               // ** Acerta a Diferenca entre o Total q esta nas Invoices com o que esta no Item.
               WorkDetInv->(dbGoTo(nRecUltReg))
               aVlCampos := Ae108SumCpo()

               If ( nVlDiff := aVlCampos[FRETE] - aVlInvDesp[1] ) <> 0 //LGS-12/01/2016
                 WorkDetInv->EXR_VLFRET += nVlDiff
               EndIf
               If ( nVlDiff := aVlCampos[SEGURO] - aVlInvDesp[2] ) <> 0 //LGS-12/01/2016
                  WorkDetInv->EXR_VLSEGU += nVlDiff
               EndIf
               If ( nVlDiff := aVlCampos[OUTDESP] - aVlInvDesp[3] ) <> 0 //LGS-12/01/2016
                  WorkDetInv->EXR_VLOUTR += nVlDiff
               EndIf
               If ( nVlDiff := aVlCampos[DESCONTO] - aVlInvDesp[4] ) <> 0 //LGS-12/01/2016
                  WorkDetInv->EXR_VLDESC += nVlDiff
               EndIf

            EndIf

         EndIf

         WorkIp->(dbSkip())

      EndDo

   EndIf

If !WorkInv->(Eof() .And. Bof())// Somente se existir invoice cadastrada. // MPG - 09/10/2018 - CORREÇÃO DOS VALORES DAS INVOICES
   WorkDetInv->(dbSetOrder(1))
   WorkInv->(dbGoTop())

   Do While !WorkInv->(Eof())

      // ** Apura os Totais da Invoice e se algum item foi excluido.

      WorkInv->EXP_FRPREV := 0
      WorkInv->EXP_SEGPRE := 0
      WorkInv->EXP_DESPIN := 0
      WorkInv->EXP_DESCON := 0
      WorkInv->EXP_VLFOB  := 0
      WorkInv->EXP_TOTPED := 0

      If EasyEntryPoint("EECAE108")  // By PLB - 14/01/2010
         ExecBlock("EECAE108", .F., .F., "RATEIO_CAPA_INI")
      EndIf

      WorkDetInv->(dbSeek(WorkInv->EXP_NRINVO))
      lDelCapa := .T.

      Do While !WorkDetInv->(Eof()) .And. ;
               WorkDetInv->EXR_NRINVO == WorkInv->EXP_NRINVO

         If !WorkIp->(dbSeek(WorkDetInv->(EXR_PEDIDO+EXR_SEQUEN) )) .Or. Empty(WorkIp->WP_FLAG) //LGS-12/01/2016
            WorkDetInv->(dbDelete())
            If lDelCapa
                Aadd(aDInvDeletados,WorkDetInv->EXR_RECNO) //WHRS 06/07/2017 TE-5995 519182 - MTRADE-1013 / 1230-Duplicação Itens da Invoice
            ENDIF
            WorkDetInv->(dbSkip()) ; Loop
         EndIf

         WorkInv->EXP_FRPREV += WorkDetInv->EXR_VLFRET
         WorkInv->EXP_SEGPRE += WorkDetInv->EXR_VLSEGU
         WorkInv->EXP_DESPIN += WorkDetInv->EXR_VLOUTR
         WorkInv->EXP_DESCON += WorkDetInv->EXR_VLDESC
         WorkInv->EXP_VLFOB  += WorkDetInv->EXR_PRCINC
         WorkInv->EXP_TOTPED += WorkDetInv->EXR_PRCTOT
         lDelCapa := .F.

         If EasyEntryPoint("EECAE108")  // By PLB - 14/01/2010
            ExecBlock("EECAE108", .F., .F., "RATEIO_CAPA_LOOP")
         EndIf

         WorkDetInv->(dbSkip())

      EndDo

      If lDelCapa  // Deleta a Capa da Invoice se nao for encontrado nenhum Item.
         WorkInv->(dbDelete())
         Aadd(aCInvDeletados,WorkInv->EXP_RECNO) //WHRS 06/07/2017 TE-5995 519182 - MTRADE-1013 / 1230-Duplicação Itens da Invoice
      Endif

      WorkInv->(dbSkip())

   EndDo
/* NOPADO - 30/01/2019 - Sempre deve apurar as despesas e totais para as Invoices
   If lRateioOk .And. lTela
      MsgInfo(STR0129,STR0122) //STR0129	"Despesas rateadas entre as Invoices  " //STR0122	"Informação"

   EndIf
*/
   WorkIP->(dbGoTo(nRecIp))
   WorkInv->(dbGoTo(nRecInv))

EndIf

RestOrd(aOrd,.T.) //LGS-12/01/2016
dbSelectArea(cOldArea)


Return


/*
Funcao      : Ae108DelInv()
Parametros  :
Retorno     : .T.
Objetivos   : Deleta Itens da Invoice caso o Item do Embarque for Excluido.
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108DelInv()
*----------------------------*
Local lRet := .T.
Local aInvoices := {}, nPos

WorkDetInv->(dbSetOrder(2))

WorkDetInv->(dbSeek(WorkIP->(EE9_PEDIDO+EE9_SEQUEN)/*EE9_SEQEMB*/)) //LGS-12/01/2016
Do While !WorkDetInv->(Eof()) .And. ;
         WorkDetInv->(EXR_PEDIDO+EXR_SEQUEN) == WorkIP->(EE9_PEDIDO+EE9_SEQUEN)/*EE9_SEQEMB*/ //LGS-12/01/2016

   If !Empty(WorkDetInv->EXR_RECNO)
      Aadd(aDInvDeletados,WorkDetInv->EXR_RECNO)
   EndIf

   If aScan(aInvoices,WorkDetInv->EXR_NRINVO) = 0
      aAdd(aInvoices,WorkDetInv->EXR_NRINVO)
   EndIf

   WorkDetInv->(dbDelete())
   WorkDetInv->(dbSkip())

EndDo

For nPos := 1 To Len(aInvoices) // Deletar Capa da Invoice se nao houver Items

   If !WorkDetInv->(dbSeek(aInvoices[nPos]))
      If WorkInv->(dbSeek(aInvoices[nPos]))
         If !Empty(WorkInv->EXP_RECNO)
            Aadd(aCInvDeletados,WorkInv->EXP_RECNO)
         EndIf
         WorkInv->(dbDelete())
      EndIf
   EndIf

Next

WorkDetInv->(dbSetOrder(1))

Return lRet


/*
Funcao      : Ae108SldVal()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Valida o saldo na gravacao do Embarque.
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ae108SldVal()
*----------------------------*
Local lRet := .T.
Local aValores := {} //LRS - 16/08/2017

ProcRegua(WorkIp->(EasyRecCount("WorkIp")))

WorkIp->(dbGoTop())

Do While !WorkIp->(Eof())

   IncProc(STR0017) //"Lendo Itens..."

   aValores := Ae108ItSldInv(WorkIp->(EE9_PEDIDO+EE9_SEQUEN)/*EE9_SEQEMB*/)   //LGS-12/01/2016

   If aValores[1][1] > 0
      lRet := .F.
      Exit
   EndIf

   WorkIp->(dbSkip())

EndDo

Return lRet

/*
Funcao      : Ae108AltItem()
Parametros  : cCampo - Nome do Campo
              _ValAnt - Valor anterior do campo
              _ValAtual - Valor atual do campo
Retorno     : .T.
Objetivos   : Chamada quando ha alteração no Item do Embarque. Tem que refletir na Invoice.
Autor       : Osman Medeiros Jr.
Data/Hora   : 17/06/05 12:42
Revisao     :
Obs.        :
*/
*---------------------------------------------*
Function Ae108AltItem(cCampo,_ValAnt,_ValAtual)
*---------------------------------------------*
Local lRet := .T.
Local aValores := {} //LRS - 16/08/2017

Do Case

   Case cCampo == "EE9_SLDINI"

       If (_ValAnt - _ValAtual) > 0
          aValores := Ae108ItSldInv(WorkIp->(EE9_PEDIDO+EE9_SEQUEN)/*EE9_SEQEMB*/) //LGS-12/01/2016         
          If (_ValAnt - _ValAtual) > aValores[1][1]  
             MsgStop(STR0035,STR0021) //"Quantidade nas Invoices maior que a quantidade informada"###"Atenção"
             lRet := .F.
          EndIf
       EndIf

End Case

Return lRet

/*
Funcao      : Ae108ChkArm(cImp, cImpLoja, cPreemb, cPedido, cSeq)
Parametros  : cImp -> Código do Importador, cImpLoja -> Loja do Importador, cPreemb -> Número do Embarque,
              cPedido -> Número do Pedido, cSeq -> Sequencia do item no embarque
Retorno     : lRet -> .F. - Não possui itens vinculados, .T. - Possui itens vinculados
Objetivos   : Verifica se um ou mais itens do estoque de produtos em consignação possui vinculação
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 04/05/06
Revisao     :
Obs.        :
*/

Function Ae108ChkArm(cImp, cImpLoja, cPreemb, cPedido, cSeq)
Local lRet := .F.
Local aOrd := SaveOrd({"EY5"})

Default cPedido := "", cSeq := ""

Begin Sequence

   If ValType(cImp) <> "C" .Or. ValType(cImpLoja) <> "C" .Or. ValType(cPreemb) <> "C"
      Break
   EndIf
   EY5->(DbSetOrder(1))
   If EY5->(DbSeek(xFilial()+cImp+cImpLoja+cPreemb+cPedido+cSeq))
      While EY5->(!Eof() .And. EY5_IMPORT == cImp ;
                  .And. EY5_IMLOJA == cImpLoja ;
                  .And. EY5_PREEMB == cPreemb ;
                  .And. If(!Empty(cPedido), EY5_PEDIDO == cPedido, .T.)) ;
                  .And. If(!Empty(cSeq), EY5_SEQUEN == cSeq, .T.)
         If EY5->(EY5_SLDINI <> EY5_SLDATU)
            lRet := .T.
            Break
         EndIf
         EY5->(DbSkip())
      EndDo
   EndIf

End Sequence
RestOrd(aOrd, .T.)

Return lRet

/*
Função          : Ae108AtuEstoque()
Objetivo        : Atualizar a tabela de produtos estocados em consignação.
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 04/05/06
Parametros      : nOpc
Retorno         : Nenhum
Obs.            :
Revisão         : WFS 01/08/2016
                  Restauração de saldo quando o ambiente está configurado para permitir embarque sem item.
                  Considerar que o item do embarque, que possui um R.E., foi desmarcado. Considerar também que
                  podem haver N itens no processo, todos com R.E. e associados a mesma nota fiscal de saída. Ao
                  desmarcar um único item, todos os demais serão desmarcados.
                  Considerar que, mesmo com o parâmetro MV_AVG0008 desabilitado, pode haver este cenário, desde que no embarque
                  permaneça, ao menos, um item.

*/
*------------------------------------*
Function Ae108AtuEstoque(nOpc, cTipo)
*------------------------------------*
Local nRecnoIp := WorkIp->(Recno())

Begin Sequence

   Do Case
      Case Empty(cTipo) .Or. cTipo == PC_RC .Or. cTipo == PC_BC //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
         If nOpc == EXCLUIR
            WorkIp->(DbGoTop())
            EY6->(DbSetOrder(2))
            While WorkIp->(!Eof())
               If !Empty(WorkIp->EE9_RE)
                  If EY6->(DbSeek(xFilial()+WorkIp->EE9_RE))
                     EY6->(RecLock("EY6", .F.))
                     //EY6->EY6_SLDATU += WorkIp->EE9_SLDINI
                     EY6->EY6_SLDATU += AvTransUnid(WorkIp->EE9_UNIDAD, EY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
                     If EER->(DbSeek(xFilial()+Left(Workip->EE9_RE, 9))) .And. EER->EER_MANUAL <> "S"
                        EY6->EY6_PREEMB := SI101SeqRE()
                        EER->(RecLock("EER", .F.))
                        EER->EER_MANUAL := "S"
                        EER->(MsUnlock())
                     EndIf
                     EY6->(MsUnlock())
                  EndIf
                  If WorkIp->WP_RECNO <> 0
                     EE9->(DbGoTo(WorkIp->WP_RECNO))
                     EE9->(RecLock("EE9", .F.))
                     EE9->EE9_RE := ""
                     EE9->EE9_DTRE := CToD("  \  \  ")
                     EE9->(MsUnlock())
                  EndIf
               EndIf
               WorkIp->(DbSkip())
            EndDo

         Else
            WorkIp->(DbGoTop())
            EY5->(DbSetOrder(1))
            While WorkIp->(!Eof()) .And. (cTipo == PC_RC .Or. cTipo == PC_BC) //LGS-18/08/2015
              //If EY5->(DbSeek(xFilial()+M->(EEC_IMPORT+EEC_IMLOJA+EEC_PREEMB)+WorkIp->(EE9_PEDIDO+EE9_SEQEMB)))
              If EY5->(DbSeek(xFilial()+M->(EEC_IMPORT+EEC_IMLOJA+EEC_PREEMB)+WorkIp->(EE9_PEDIDO+EE9_SEQUEN))) //ER - 20/06/2007
                  If Empty(M->EEC_DTEMBA) .Or. Empty(WorkIp->WP_FLAG) .Or. nOpc == EXCLUIR
                     EY5->(RecLock("EY5", .F.))
                     EY5->(DbDelete())
                     EY5->(MsUnlock())
                  ElseIf M->EEC_DTREC <> EY5->EY5_DTREC .Or. EY5->EY5_SLDINI <> WorkIp->EE9_SLDINI .Or. EY5->EY5_INVOIC <> WorkIp->EE9_INVPAG .Or. EY5->EY5_RE <> WorkIp->EE9_INVPAG
                     EY5->(RecLock("EY5", .F.))
                     EY5->EY5_RE     := WorkIp->EE9_RE
                     EY5->EY5_DTRE   := WorkIp->EE9_DTRE
                     EY5->EY5_UNIDAD := WorkIp->EE9_UNIDAD
                     EY5->EY5_SLDINI := WorkIp->EE9_SLDINI
                     EY5->EY5_INVOIC := WorkIp->EE9_INVPAG
                     EY5->EY5_DTREC  := M->EEC_DTREC
                     If cTipoProc == PC_RC
                        EY5->EY5_ORIGEM := "1"
                     ElseIf cTipoProc == PC_BC
                        EY5->EY5_ORIGEM := "2"
                     EndIf
                     EY5->(MsUnlock())
                  EndIf
               ElseIf !Empty(M->EEC_DTEMBA) .And. !Empty(WorkIp->WP_FLAG) .And. nOpc <> EXCLUIR
                  EY5->(RecLock("EY5", .T.))
                  EY5->EY5_FILIAL := xFilial("EY5")
                  EY5->EY5_IMPORT := M->EEC_IMPORT
                  EY5->EY5_IMLOJA := M->EEC_IMLOJA
                  EY5->EY5_PREEMB := M->EEC_PREEMB
                  EY5->EY5_PEDIDO := WorkIp->EE9_PEDIDO
                  EY5->EY5_SEQUEN := WorkIp->EE9_SEQUEN
                  EY5->EY5_COD_I  := WorkIp->EE9_COD_I
                  EY5->EY5_RE     := WorkIp->EE9_RE
                  EY5->EY5_DTRE   := WorkIp->EE9_DTRE
                  EY5->EY5_UNIDAD := WorkIp->EE9_UNIDAD
                  EY5->EY5_SLDINI := WorkIp->EE9_SLDINI
                  EY5->EY5_SLDATU := WorkIp->EE9_SLDINI
                  EY5->EY5_INVOIC := WorkIp->EE9_INVPAG
                  EY5->EY5_DTREC  := M->EEC_DTREC
                  EY5->EY5_ID := GetNewId()
                  If cTipoProc == PC_RC
                     EY5->EY5_ORIGEM := "1"
                  ElseIf cTipoProc == PC_BC
                     EY5->EY5_ORIGEM := "2"
                  EndIf
                  EY5->(MsUnlock())
               EndIf
               WorkIp->(DbSkip())
            EndDo
            If Empty(cTipo) .Or. cTipo == PC_RC //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
               //Atualiza o saldo do RE
               WkEY6->(DbGoTop())
               EY6->(DbSetOrder(2))
               EER->(DbSetOrder(3))
               While WkEY6->(!Eof())
                  If EY6->(DbSeek(xFilial()+WkEY6->EY6_RE))
                     EY6->(RecLock("EY6", .F.))
                     EY6->EY6_SLDATU := WkEY6->EY6_SLDATU
                  EndIf
                  If WkEY6->WK_ALTIPO == "1" .And. EER->(DbSeek(xFilial()+Left(WkEY6->EY6_RE, 9)))
                     EY6->EY6_PREEMB := SI101SeqRE()
                     EER->(RecLock("EER", .F.))
                     EER->EER_MANUAL := "S"
                     EER->(MsUnlock())
                  EndIf
                  EY6->(MsUnlock())
                  WkEY6->(DbSkip())
               EndDo

               /* Restaurar o saldo dos itens desmarcados, que tiveram associação com o R.E.*/
               WorkIp->(DbGoTop())
               While WorkIp->(!Eof())
                  If !Empty(WorkIp->EE9_RE) .And. Empty(WorkIp->WP_FLAG)
                     If EY6->(DbSeek(xFilial()+WorkIp->EE9_RE))
                        EY6->(RecLock("EY6", .F.))
                        EY6->EY6_SLDATU += AvTransUnid(WorkIp->EE9_UNIDAD, EY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->WP_OLDINI, .F.)
                        EY6->(MsUnlock())
                     EndIf
                     If WorkIp->WP_RECNO <> 0
                        EE9->(DbGoTo(WorkIp->WP_RECNO))
                        EE9->(RecLock("EE9", .F.))
                        EE9->EE9_RE := ""
                        EE9->EE9_DTRE := CToD("  \  \  ")
                        EE9->(MsUnlock())
                     EndIf
                  EndIf
                  WorkIp->(DbSkip())
               EndDo

            EndIf

         EndIf

      Case cTipo == PC_VR .Or. cTipo == PC_VB
         If nOpc == EXCLUIR
            WkEY7->(DbGoTop())
            While WkEY7->(!Eof())
               If EY5->(DbSeek(xFilial()+WkEY7->(EY7_IMPORT+EY7_IMLOJA+EY7_PREEMB+EY7_PEDIDO+EY7_SEQUEN+EY7_COD_I+EY7_RE+EY7_INVOIC)))
                  EY5->(RecLock("EY5", .F.))
                  EY5->EY5_SLDATU += WkEY7->EY7_SLDINI
                  EY5->(MsUnlock())
               EndIf
               If !Empty(WkEY7->WK_RECNO)
                  EY7->(DbGoTo(WkEY7->WK_RECNO))
                  EY7->(RecLock("EY7", .F.))
                  EY7->(DbDelete())
                  EY7->(MsUnlock())
               EndIf
               WkEY7->(DbSkip())
            EndDo

         Else
            WkEY5->(DbGoTop())
            While WkEY5->(!Eof())
               If !Empty(WkEY5->WK_CHANGE)
                  EY5->(DbGoTo(WkEY5->WK_RECNO))
                  EY5->(RecLock("EY5", .F.))
                  AvReplace("WkEY5", "EY5")
                  EY5->(MsUnlock())
               EndIf
               WkEY5->(DbSkip())
            EndDo
         EndIf

   End Case

End Sequence
WorkIp->(DbGoTo(nRecnoIp))
//RestOrd(aOrd, .T.)

Return Nil

/*
Funcao      : Ae108CSGrava
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Grava a tabela de vinculação entre embarques e produtos estocados em armazéns por consignação.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 11/05/06 - 11:30
Revisao     :
Obs.        :
*/
*----------------------*
Function Ae108CSGrava()
*----------------------*
Local nInc

Begin Sequence

   For nInc := 1 To Len(aEY7Deletados)
      EY7->(DbGoTo(aEY7Deletados[nInc]))
      EY7->(RecLock("EY7", .F.))
      EY7->(DbDelete())
      EY7->(MsUnlock())
   Next

   WkEY7->(DbGoTop())
   While WkEY7->(!Eof())
      If(!Empty(WkEY7->WK_RECNO), EY7->(DbGoTo(WkEY7->WK_RECNO)),)
      EY7->(RecLock("EY7", Empty(WkEY7->WK_RECNO)))
      AvReplace("WkEY7", "EY7")
      EY7->(MsUnlock())
      WkEY7->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
Funcao      : Ae108SelItArm
Parametros  : nOpc
Retorno     : Nenhum
Objetivos   : Permite a vinculação do embarque com quantidades armazenadas em consignação.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 09/05/06 - 09:40
Revisao     :
Obs.        :
*/
*---------------------------*
Function Ae108SelItArm(nOpc)
*---------------------------*
Local aOrd := SaveOrd({"WkEY5", "WkEY7"}),;
      aButtons := {},;
      aPos
Local bOk  := {|| lOk := .T. , oDlg:End() },;
      bCancel  := {|| lOk := .F. , oDlg:End() }
Local cOldArea := Select(),;
      cFileBak1 := "", cFileBak2 := ""
Local lOk := .F.,;
      lAltera := nOpc == INCLUIR .Or. nOpc == ALTERAR .And. Empty(M->EEC_DTEMBA),;
      lInverte := .F.
Local aAlias := {{"WKEY5", }, {"WKEY7", }}, aRegs := {}
Local nInc, nInc2, nInc3
Local oDlg, oMsSelectEY5, oPanel
Private oGetQtdVin
Private aBrowse := {}
Private nDlgLinIni := DLG_LIN_INI+(DLG_LIN_FIM/8),;
        nDlgLinFim := DLG_LIN_FIM-(DLG_LIN_FIM/8),;
        nDlgColIni := DLG_COL_INI+(DLG_COL_FIM/8),;
        nDlgColFim := DLG_COL_FIM-(DLG_COL_FIM/8)

Begin Sequence

   If Empty(M->EEC_ARM) .Or. Empty(M->EEC_IMLOJA)
      MsgInfo(STR0054, STR0002)//"Não é possível vincular itens sem informar um armazém na aba 'Transporte'."###"Aviso"
      Break
   EndIf

   If WorkIp->(Bof() .And. Eof())
      MsgInfo(STR0075, STR0002)//"Não há itens selecionados para vinculação de remessas."###"Aviso"
      Break
   EndIf

   If lAltera
      aAdd(aButtons,{"EDIT"  ,{|| Ae108VincProd(Empty(WkEY5->WK_MARCA)) }, STR0049})//"Vincular"
   EndIf

   /*
   cFileBak1 :=CriaTrab(,.F.)
   aAlias[aScan(aAlias, {|x| x[1] == "WKEY5" })][2] := cFileBak1
   dbSelectArea("WkEY5")
   //Copy to (cFileBak1+GetdbExtension())

   cFileBak2 :=CriaTrab(,.F.)
   aAlias[aScan(aAlias, {|x| x[1] == "WKEY7" })][2] := cFileBak2
   dbSelectArea("WkEY7")
   //Copy to (cFileBak2+GetdbExtension())
   */
   For nInc := 1 to Len(aAlias)
      aAlias[nInc][2] := CriaTrab(,.F.)
      dbSelectArea(aAlias[nInc][1])
      //Copy to (aAlias[nInc][2]+GetdbExtension())
      TETempBackup(aAlias[nInc][2]) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
   Next


   WkEY7->(DbGoTop())

   If cTipoProc == PC_VB
      aBrowse := {{"WK_MARCA", "", ""}, "EY5_PREEMB", "EY5_COD_I", "EY5_IMPORT", "EY5_IMLOJA", "EY5_INVOIC", "EY5_UNIDAD", "EY5_SLDINI", "EY5_SLDATU", {{|| Transf(WkEY5->WK_QTDVIN, AvSx3("EY5_SLDATU", AV_PICTURE))}, "", STR0055}}
   ElseIf cTipoProc == PC_VR
      aBrowse := {{"WK_MARCA", "", ""}, "EY5_PREEMB", "EY5_COD_I", "EY5_IMPORT", "EY5_IMLOJA", "EY5_RE", "EY5_DTRE", "EY5_UNIDAD", "EY5_SLDINI", "EY5_SLDATU", {{|| Transf(WkEY5->WK_QTDVIN, AvSx3("EY5_SLDATU", AV_PICTURE))}, "", STR0055} }//"Qtd. Vinc."
   EndIf

   For nInc := 1 To Len(aBrowse)
      If ValType(aBrowse[nInc]) == "C"
         If Len(AvSx3(aBrowse[nInc], AV_PICTURE)) > 0
            aBrowse[nInc] :=  { &("{|| Transf(WkEY5->" + aBrowse[nInc] + ", '" + AvSx3(aBrowse[nInc], AV_PICTURE) + "') }"),"", AvSx3(aBrowse[nInc], AV_TITULO)}
         Else
            aBrowse[nInc] :=  { &("{|| WkEY5->" + aBrowse[nInc] + " }"),"", AvSx3(aBrowse[nInc], AV_TITULO)}
         EndIf
      EndIf
   Next

   /*
   WkEY5->(DbSetFilter({|| WkEY5->(EY5_IMPORT == M->EEC_ARM .And. EY5_IMLOJA == M->EEC_ARLOJA .And. EY5_COD_I == WorkIp->EE9_COD_I)},;
                           "WkEY5->(EY5_IMPORT == M->EEC_ARM .And. EY5_IMLOJA == M->EEC_ARLOJA  .And. EY5_COD_I == WorkIp->EE9_COD_I)"))
   */
   If EasyEntryPoint("EECAE108")
      ExecBlock("EECAE108", .F., .F., "ADD_MSSELECT_ITARM")
   EndIf

   WkEY5->(DbSetFilter({|| WkEY5->(EY5_IMPORT == M->EEC_ARM .And. EY5_IMLOJA == M->EEC_ARLOJA .And. EY5_COD_I == WorkIp->EE9_COD_I)},;
                           "WkEY5->(EY5_IMPORT == M->EEC_ARM .And. EY5_IMLOJA == M->EEC_ARLOJA  .And. EY5_COD_I == WorkIp->EE9_COD_I)"))
   WkEY5->(DbGoTop())
   While WkEY5->(!Eof())
      If !WkEY5->(EY5_IMPORT == M->EEC_ARM .And. EY5_IMLOJA == M->EEC_ARLOJA .And. EY5_COD_I == WorkIp->EE9_COD_I)
         WKEY5->(DbDelete())
         WkEY5->(DbSkip())
         Loop
      EndIf
      If WkEY7->(DbSeek(WkEY5->(EY5_PREEMB+EY5_PEDIDO+EY5_SEQUEN+EY5_COD_I+EY5_RE+EY5_INVOIC)+WorkIp->EE9_SEQEMB))
         WkEy5->WK_MARCA := cMarca
      EndIf
      WkEY5->(DbSkip())
   EndDo
   WkEY5->(DbGoTop())
   //30/11/21 - Deve filtrar pelo item ativo na WorkIP WkEY5->(DbClearFilter())//ACB - 07/12/2010 - Incluido tratamento para que possam ser limpos os filtros ativos

   If IsVazio("WkEY5")
      MsgInfo(STR0057, STR0002)//"Não existem remessas deste produto disponíveis para vinculação no armazém informado."###"Aviso"
      //WkEY5->(DbClearFilter())
      Break
   EndIf

   If EasyEntryPoint("EECAE108")
      ExecBlock("EECAE108", .F., .F., "ALT_DLG_ITARM")
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0050 FROM nDlgLinIni,nDlgColIni;//"Produtos em estoque"
 					                    TO nDlgLinFim,nDlgColFim;
   						      			OF oMainWnd PIXEL

   oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 14/09/2015
   oPanel:Align:= CONTROL_ALIGN_TOP

   @ 17,6 Say AvSx3("EE9_COD_I", AV_TITULO) Of oPanel Pixel
   @ 16,45 Get WorkIp->EE9_COD_I When .F. Size 60,7 Of oPanel Pixel

   @ 17,110 Say AvSx3("EE9_SEQEMB", AV_TITULO) Of oPanel Pixel
   @ 16,150 Get WorkIp->EE9_SEQEMB When .F. Size 20,7 Of oPanel Pixel

   @ 30,6 Say AvSx3("EE9_SLDINI", AV_TITULO) Of oPanel Pixel
   @ 29,45 Get WorkIp->EE9_SLDINI Picture AvSx3("EE9_SLDINI", AV_PICTURE) When .F. Size 60,7 Of oPanel Pixel

   @ 31,110 Say STR0130 Of oPanel Pixel //STR0130	"Qtde. Vinc."
   @ 30,150 MsGet oGetQtdVin VAr WorkIp->WK_QTDREM Picture AvSx3("EE9_SLDINI", AV_PICTURE) When .F. Size 60,7 Of oPanel Pixel

   aPos := PosDlg(oDlg)
   aPos[1] += 45
   oMsSelectEY5 := MsSelect():New("WkEY5","WK_MARCA",,aBrowse,@lInverte,@cMarca,aPos,,,oDlg)
   oMsSelectEY5:oBrowse:Align:= CONTROL_ALIGN_BOTTOM
   oMsSelectEY5:bAval := {|| If(lAltera,Ae108VincProd(Empty(WkEY5->WK_MARCA)),) }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   If !lOk .Or. nOpc == VISUALIZAR
      For nInc := 1 To Len(aAlias)
         DbSelectArea(aAlias[nInc][1])
         AvZap()
         cFileBak1 := aAlias[nInc][2]
         TERestBackup(cFileBak1)
      Next
   Else
      For nInc := 1 To Len(aAlias)
         /* RMD - 30/11/21 - Não é necessário restaurar o backup, somente deve apagar os arquivos
         aRegs := {}
         (aAlias[nInc][1])->(DbGoTop())
         While (aAlias[nInc][1])->(!Eof())
             aAdd(aRegs, {{"RECNO", (aAlias[nInc][1])->(Recno())}})
            For nInc2 := 1 To (aAlias[nInc][1])->(FCount())
               aAdd(aRegs[Len(aRegs)], {(aAlias[nInc][1])->(FieldName(nInc2)), (aAlias[nInc][1])->(FieldGet(nInc2))})
            Next
            (aAlias[nInc][1])->(DbSkip())
         EndDo

         DbSelectArea(aAlias[nInc][1])
         AvZap()
         cFileBak1 := aAlias[nInc][2]
         TERestBackup(cFileBak1)

         For nInc2 := 1 To Len(aRegs)
            For nInc3 := 1 To Len(aRegs[nInc2])
               If nInc3 == 1
                  (aAlias[nInc][1])->(DbGoTo(aRegs[nInc2][1][2]))
                  If (aAlias[nInc][1])->(Eof())
                     (aAlias[nInc][1])->(DbAppend())
                  EndIf
               Else
                  (aAlias[nInc][1])->&(aRegs[nInc2][nInc3][1]) := aRegs[nInc2][nInc3][2]
               EndIf
            Next
         Next
         */
         TETempBuffer(, aAlias[nInc][2],, .T.)
      Next
      
      
   EndIf

   WkEy5->(DbGoTop())
   While WkEY5->(!Eof())
      WkEy5->WK_MARCA := Space(2)
      WkEY5->(DbSkip())
   EndDo
   WkEY5->(DbClearFilter())

End Sequence
dbSelectArea(cOldArea)
RestOrd(aOrd, .T.)
//If(File(cFileBak1+GetDBExtension()),FErase(cFileBak1+GetDBExtension()),)
//If(File(cFileBak2+GetDBExtension()),FErase(cFileBak2+GetDBExtension()),)

Return Nil

/*
Funcao      : Ae108ConsistArm
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Verifica se todos os produtos do embarque possuem vinculação com produtos estocados em armazéns e se a quantidade vinculada é igual.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 09/05/06 - 11:00
Revisao     :
Obs.        :
*/
*------------------------*
Function Ae108ConsistArm()
*------------------------*
Local lRet := .T.
Local nRecno := WorkIp->(Recno())
Local aErro := {}

Begin Sequence
   WorkIp->(DbGoTop())
   While WorkIp->(!Eof())
      If !Empty(WorkIp->WP_FLAG) .And. WorkIp->(WK_QTDREM <> EE9_SLDINI)
         aAdd(aErro, WorkIp->({EE9_COD_I, EE9_SEQEMB, EE9_SLDINI, WK_QTDREM}))
      EndIf
      WorkIp->(DbSkip())
   EndDo
   WorkIp->(DbGoTo(nRecno))
   If Len(aErro) > 0
      EECView(EECBrkLine(STR0077) + ENTER +;//"Não é possível prosseguir porque os seguintes itens embarcados não possuem vinculação com itens estocados no armazém selecionado:"
              EECMontaMsg({{"EE9_COD_I" ,,,,,},;
                           {"EE9_SEQEMB",,,,,},;
                           {"EE9_SLDINI",,,,,},;
                           {"EE9_SLDINI",,STR0055,,,}}, aErro))//"Qtd. Vinc."
      lRet := .F.
      Break
   EndIf

End Sequence

Return lRet

/*
Funcao      : Ae108VincProd
Parametros  : lMarca -> Indica se o produto está sendo vinculado/desvinculado
Retorno     : Nenhum
Objetivos   : Vincula um produto estocado em consignação ao embarque
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 09/05/06 - 14:00
Revisao     :
Obs.        :
*/
*-----------------------------*
Function Ae108VincProd(lMarca)
*-----------------------------*
Local nQtd := 0, nInc
Local cFieldOri, cFieldDest
Local bGetSetOri, bGetSetDest

Begin Sequence

   If lMarca
      If WorkIp->(EE9_SLDINI == WK_QTDREM)
         MsgInfo(STR0078, STR0021)//"O item não possui saldo disponível para vinculação."###"Atenção"
         Break
      EndIf
      If (nQtd := Ae108GetQtd(AvTransUnid(WkEY5->EY5_UNIDAD, WorkIp->EE9_UNIDAD, WorkIp->EE9_COD_I, WkEY5->EY5_SLDATU, .F.), WorkIp->(EE9_SLDINI - WK_QTDREM))) > 0
         WkEy5->WK_MARCA   := cMarca
         WorkIp->WK_QTDREM += nQtd
         nQtd := AvTransUnid(WorkIp->EE9_UNIDAD, WkEY5->EY5_UNIDAD, WorkIp->EE9_COD_I, nQtd, .F.)
         WKEy5->WK_QTDVIN  += nQtd
         WkEY5->EY5_SLDATU -= nQtd
         WkEY5->WK_CHANGE  := cMarca
         WkEY7->(DbAppend())
         For nInc := 1 To WkEY5->(FCount())
            cFieldOri   := WkEY5->(FieldName(nInc))
            bGetSetOri  := FieldWBlock(cFieldOri,Select("WkEY5"))
            cFieldDest  := "EY7"+SubStr(AllTrim(cFieldOri),4)
            bGetSetDest := FieldWBlock(cFieldDest, Select("WkEY7"))
            If (WkEY7->(FieldPos(cFieldDest))#0)
               Eval(bGetSetDest,Eval(bGetSetOri))
            Endif
         Next nInc
         WkEY7->EY7_EMBVIN := M->EEC_PREEMB
         WkEY7->EY7_SEQEMB := WorkIp->EE9_SEQEMB
         WkEY7->EY7_SLDINI := nQtd
      EndIf
   Else
      WkEY5->WK_MARCA := Space(2)
      WkEY7->(DbSeek(WkEY5->(EY5_PREEMB+EY5_PEDIDO+EY5_SEQUEN+EY5_COD_I+EY5_RE+EY5_INVOIC)+WorkIp->EE9_SEQEMB))
      WorkIp->WK_QTDREM  -= AvTransUnid(WkEY7->EY7_UNIDAD, WorkIp->EE9_UNIDAD, WorkIp->EE9_COD_I, WkEY7->EY7_SLDINI, .F.)
      WkEY5->EY5_SLDATU  += WkEY7->EY7_SLDINI
      WkEY5->WK_QTDVIN   -= WkEY7->EY7_SLDINI
      WkEY5->WK_CHANGE   := cMarca
      If(!Empty(WkEY7->WK_RECNO),aAdd(aEY7Deletados, WkEY7->WK_RECNO),)
      WkEY7->(DbDelete())
   EndIf
   oGetQtdVin:Refresh()
End Sequence

Return Nil

/*
Funcao      : GetQtd
Parametros  : Saldo -> Indica o saldo a ser vinculado
              nQtdMax -> Quantidade máxima permitida para vinculação
Retorno     : nQtde -> Quantidade vinculada, definida pelo usuário
Objetivos   : Exibe tela para que o usuário informe uma quantidade a partir do saldo informado
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 09/05/06 - 14:30
Revisao     :
Obs.        :
*/
*---------------------------------------------------*
Function Ae108GetQtd(nSaldo, nQtdeMax, lAuto, lRetSaldo,cWork)
*---------------------------------------------------*
Local oDlg
Local lOk       := .F.
// BAK - Tratamento para quebra do produto na estufagem - 13/02/2013
//Local bOk       := {|| If ((Eval(bValidSup) .And. Eval(bValidSup)),(lOk := .T., oDlg:End()), )}
Local bOk       := {|| If ((Eval(bValidSup) .And. Eval(bValidSup) .And. Ae108EmbPeso(cWork,nQtde)),(lOk := .T., oDlg:End()), )}
Local bCancel   := {|| oDlg:End() }
Local bValidSup := {|| (If ((nQtde > nSaldo),(MsgInfo(STR0043, STR0002),.F.),.T.))}//"Quantidade superior ao saldo disponível" ### "Aviso"
Local bValidInf := {|| (If ((nQtde < 1),(MsgInfo(STR0044, STR0002),.F.),.T.))}//"Quantidade não permitida" ### "Aviso"
Local nQtde     := nSaldo
Default nQtdeMax := nSaldo
Default lRetSaldo := .F.
Default cWork := ""

Begin Sequence

    If lAuto
       lOk := .T.
    Else
      DEFINE MSDIALOG oDlg TITLE STR0045 FROM 1,1 To /*100*/190,380 OF oMainWnd Pixel//"Controle de Saldo"    //*** GFP 15/09/2011 - Ajuste de tela para versão 11.5

      oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 14/09/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 14,4  To 48,175 Label STR0131 Pixel OF oPanel //"Indique a quantidade a ser vinculada" //STR0131	"Indique a quantidade"
      @ 23,25  Say STR0047 Pixel Of oPanel //"Saldo:"
      @ 22,75 MsGet nSaldo Size 70,07 Picture "@E 999,999,999,999.99" When .F. Pixel Of oPanel
      @ 35,25  Say STR0048 Pixel Of oPanel //"Total a vincular:"
      @ 34,75 MsGet nQtde  Size 70,07 Picture "@E 999,999,999,999.99" Valid Positivo(nQtde) .And. If(nQtde > nQtdeMax, (MsgInfo(STR0074, STR0021), .F.),.T.) Pixel Of oPanel //"A quantidade informada é superior a quantidade do item."###"Atenção"

      Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered
   EndIf

   If !lOk
      If lRetSaldo
         nQtde := nSaldo
      Else
         nQtde := 0
      EndIf
      Break
   EndIf

End Sequence

Return nQtde

/*
Funcao      : Ae108EmbPeso(cWork,nQtde)
Parametros  : cWork -> Work da estufagem
              nQtde -> Quantidade vinculada
Retorno     : lRet
Objetivos   : Validação da quebra do produto na rotina de estufagem
Autor       : Bruno Akyo Kubagawa
Data/Hora   : 10/05/06 - 14:30
Revisao     :
Obs.        :
*/
Static Function Ae108EmbPeso(cWork,nQtde)
Local lRet := .T.
Local aOrd := SaveOrd("EE5")
Local nPeso := 0
Local nDecimal := 0
Default cWork := ""
Default nQtde := 0

Begin Sequence

   // Retorna .T. quando nao estiver aberta a WK_NE da rotina de estufagem
   If Empty(cWork) .Or. (Select(cWork) == 0 .And. nQtde > 0)
      Break
   EndIf

   // Verifica o peso da embalagem quando for zero poderá realizar a quebra do produto pela quantidade vinculada
   EE5->(DbSetOrder(1))
   If EE5->(DbSeek(xFilial("EE5")+(cWork)->EYH_CODEMB))
      nPeso := EE5->EE5_PESO
   EndIf

   If nQtde < 1
      nDecimal := nQtde
   Else
      nDecimal := nQtde%Int(nQtde)
   EndIf

   // Caso seja o decimal igual a Zero, significa que foi informado a quantidade inteira.
   If nDecimal == 0
      Break
   Else
      If nDecimal > 0 .And. nDecimal < 1 .And. nPeso > 0
         lRet := .F.
         MsgInfo("Para realizar a quebra do produto informe uma embalagem com peso igual a zero.","Atenção")
         Break
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet


/*
Funcao      : Ae108VldConsig(cCampo)
Parametros  : cCampo -> Campo a ser validado
Retorno     : lRet
Objetivos   : Validação dos campos de consignação
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/05/06 - 14:30
Revisao     :
Obs.        :
*/
*------------------------------*
Function Ae108VldConsig(cCampo)
*------------------------------*
Local lRet := .T.
Local nRecno

Begin Sequence
   Do Case
      Case cCampo == "EEC_ARM"
         If !Empty(M->EEC_ARM)
            SA1->(DbSetOrder(1))
            If !(lRet := SA1->(dbSeek(xFilial("SA1")+M->EEC_ARM+If(!Empty(M->EEC_ARLOJA),M->EEC_ARLOJA,""))))
               MsgInfo(STR0051, STR0021)//"O código informado não é um código de armazém válido."###"Atenção"
               Break
            EndIf
            M->EEC_ARLOJA := SA1->A1_LOJA
         EndIf
         lRet := Ae108VldConsig("ARMAZEM")

      Case cCampo == "EEC_ARLOJA"
         If !Empty(M->EEC_ARM) .And. !Empty(M->EEC_ARLOJA)
            lRet := SA1->(dbSeek(xFilial("SA1")+M->EEC_ARM+M->EEC_ARLOJA))
            If !lRet
               MsgInfo(StrTran(STR0052, "###", AllTrim(M->EEC_ARLOJA)), STR0021)//"O código da loja informada não é valido para o armazém ###."###"Atenção"
               Break
            EndIf
         EndIf
         lRet := Ae108VldConsig("ARMAZEM")

      Case cCampo == "ARMAZEM"
         If !(WkEY7->EY7_IMPORT <> M->EEC_ARM .Or. WkEY7->EY7_IMLOJA <> M->EEC_ARLOJA)
            Break
         EndIf
         If !IsVazio("WkEY7")
            nRecno := WkEY7->(Recno())
            WkEY7->(DbGoTop())
            If !(lRet := MsgYesNo(STR0053, STR0021))//"Confirma alteração do armazém? A vinculação de itens com o armazém anterior será desfeita."###"Atenção"
               WkEY7->(DbGoTo(nRecno))
               Break
            EndIf
            While WkEY7->(!Eof())
               WkEY5->(DbSeek(WkEY7->(EY7_IMPORT+EY7_IMLOJA+EY7_PREEMB+EY7_PEDIDO+EY7_SEQUEN+EY7_COD_I+EY7_RE+EY7_INVOIC)))
               WkEY5->WK_MARCA     := Space(2)
               WkEY5->(EY5_SLDATU += WK_QTDVIN)
               WorkIp->WK_QTDREM  -= WkEY5->WK_QTDVIN
               WkEY5->WK_QTDVIN   := 0
               WkEY5->WK_CHANGE := cMarca
               If(!Empty(WkEY7->WK_RECNO),aAdd(aEY7Deletados, WkEY7->WK_RECNO),)
               WkEY7->(DbDelete())
               WkEY7->(DbSkip())
            EndDo
         EndIf
         If !Empty(M->EEC_ARM) .And. EY5->(DbSeek(xFilial()+M->(EEC_ARM+EEC_ARLOJA)))
            While EY5->(!Eof() .And. xFilial() == EY5_FILIAL .And. EY5_IMPORT == EEC_ARM .And. EY5_IMLOJA == EEC_ARLOJA)
               If !WkEY5->(DbSeek(EY5->(EY5_IMPORT+EY5_IMLOJA+EY5_PREEMB+EY5_PEDIDO+EY5_SEQUEN+EY5_COD_I+EY5_RE+EY5_INVOIC)));
                  .And. !Empty(EY5->EY5_DTREC)
                  /* RMD - 25/11/21 - Não valida mais o RE/INVOICE, validando somente a data de recebimento
                  .And. ((cTipoProc == PC_VR .And. EY5->EY5_ORIGEM == "1" .And. !Empty(EY5->EY5_RE));
                  .Or. (cTipoProc == PC_VB .And. EY5->EY5_ORIGEM == "2" .And. !Empty(EY5->EY5_INVOIC)));
                  .And. !Empty(EY5->EY5_DTREC)*/

                  WkEY5->(DbAppend())
                  AvReplace("EY5", "WkEY5")
                  WkEY5->WK_RECNO := EY5->(Recno())
               EndIf
               EY5->(DbSkip())
            EndDo
         EndIf

      Case cCampo == "RE"
         If !Empty(WorkIp->EE9_RE)
            If WkEY6->(DbSeek(WorkIp->EE9_RE))
               WkEY6->EY6_SLDATU += AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
            Else
               EY6->(DbSetOrder(2))
               If EY6->(DbSeek(xFilial()+WorkIp->EE9_RE))
                  WkEY6->(DbAppend())
                  AvReplace("EY6", "WkEY6")
                  WkEY6->EY6_SLDATU += AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
                  EER->(DbSetOrder(3))
                  If EER->(DbSeek(xFilial()+Left(WorkIp->EE9_RE, 9))) .And. EER->EER_MANUAL <> "S"
                     WkEY6->WK_ALTIPO := "1"
                  EndIf
               EndIf
            EndIf
            WorkIp->EE9_RE := ""
            WorkIp->EE9_DTRE := CToD("  \  \  ")
         EndIf

      Case cCampo == "OK_BUSCAARM"
         If Empty(cArm) .And. Empty(cLjArm) .And. Empty(cInv) .And. Empty(cRe)
            MsgInfo(STR0070, STR0008)//"Favor informar ao menos um parâmetro para pesquisa."###"Atenção"
            lRet := .F.
            Break
         EndIf

      Case cCampo == "EY8_SLDINI"
         If Type("cOpcao") == "C" .And. cOpcao == "BAIXA"
            If M->EY8_SLDINI > EY5->EY5_SLDATU
               MsgInfo(STR0043, STR0008)//"Quantidade superior ao saldo disponível"###"Atenção"
               lRet := .F.
               Break
            EndIf
         EndIf

      Case cCampo == "EY5_SLDINI"
         If Type("cOpcao") == "C" .And. cOpcao == "TRANSFERENCIA"
            If M->EY5_SLDINI > M->EY5_SLDATU
               MsgInfo(STR0043, STR0008)//"Quantidade superior ao saldo disponível"###"Atenção"
               lRet := .F.
               Break
            EndIf
         EndIf

      Case cCampo == "EY8_CODMOT"
       //ASK 15/08/2007 - Alterada no SX5 a tabela Z1 para YO
       //If Empty(M->EY8_CODMOT) .Or. Empty(Tabela("Z1", M->EY8_CODMOT))
         If Empty(M->EY8_CODMOT) .Or. Empty(Tabela("YO", M->EY8_CODMOT))
            lRet := .F.
            Break
         EndIf
         M->EY8_DSCMOT := Tabela("YO", M->EY8_CODMOT)

      Case cCampo == "EY5_IMPORT"
         If !Empty(M->EY5_IMPORT)
            If !(lRet := M->EY5_IMPORT <> EY5->EY5_IMPORT)
               MsgInfo(STR0071, STR0021)//"Para transferir, favor informar um armazém diferente do original."###"Atenção"
               Break
            EndIf
            SA1->(DbSetOrder(1))
            If !(lRet := SA1->(dbSeek(xFilial("SA1")+M->EY5_IMPORT+If(!Empty(M->EY5_IMLOJA),M->EY5_IMLOJA,""))))
               MsgInfo(STR0051, STR0021)//"O código informado não é um código de armazém válido."###"Atenção"
               Break
            EndIf
            M->EY5_IMLOJA := SA1->A1_LOJA
         EndIf

      Case cCampo == "EY5_IMLOJA"
      /* If !(lRet := SA1->(dbSeek(xFilial("SA1")+M->EY5_IMPORT+If(!Empty(M->EY5_IMLOJA),M->EY5_IMLOJA,""))))
               MsgInfo(STR0051, STR0021)//"O código informado não é um código de armazém válido."###"Atenção"*///SVG - Ch. 705417
         If !Empty(M->EY5_IMPORT) .And. !Empty(M->EY5_IMLOJA)
            lRet := SA1->(dbSeek(xFilial("SA1")+M->EY5_IMPORT+M->EY5_IMLOJA)) //SVG - Ch. 705417
            If !lRet
               MsgInfo(StrTran(STR0052, "###", AllTrim(M->EY5_IMLOJA)), STR0021)//"O código da loja informada não é valido para o armazém ###."###"Atenção"
               Break
            EndIf
         EndIf

   End Case
End Sequence

Return lRet

/*
Funcao      : Ae108ArmBaixa()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Manutenção de quantidades estocadas em armazém por regime de consignação.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/05/06 - 09:30
Revisao     :
Obs.        :
*/
*-----------------------*
Function Ae108ArmBaixa()
*-----------------------*
Local aOrd := SaveOrd({"EY5", "SX3"})
Private aCposEnch := {}
Private cAlias := "EY5",;
        cOpcao := "BAIXA",;
        cTitulo := STR0061,;//"Baixa de Remessa"
        cTitBotao := STR0060,;//"Baixar"
        cNomArq1 := ""
Private aRotina := MenuDef(ProcName())
Private cCadastro := alltrim(FWX2Nome(cAlias)) + " - " + cTitulo

SX3->(DbSetOrder(1))
If SX3->(DbSeek("EY8"))
   While SX3->(!Eof() .And. X3_ARQUIVO == "EY8")
      If (!(AllTrim(SX3->X3_CAMPO) $ "EY8_DTBX/EY8_HRBX/EY8_USERBX") .And. X3Uso(SX3->X3_USADO)) .Or. SX3->X3_PROPRI == "U"
         aAdd(aCposEnch, SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
   EndDo
EndIf

mBrowse(6, 1, 22, 75, cAlias)

RestOrd(aOrd, .F.)
If(File(cNomArq1+GetDBExtension()),FErase(cNomArq1+GetDBExtension()),)

Return Nil

/*
Funcao      : Ae108ArmEstorno
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Estornar baixa de remessa estocada em consignação.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/05/06 - 09:30
Revisao     :
Obs.        :
*/
*-----------------------*
Function Ae108ArmEstorno()
*-----------------------*
Local aOrd := SaveOrd({"EY8"})

Private aCposEnch := {}
Private aRotina := MenuDef(ProcName())
Private cAlias := "EY8",;
        cOpcao := "ESTORNO",;
        cTitulo := STR0063,;//"Estorno de Baixa de Remessa"
        cTitBotao := STR0062,;//Estornar
        cNomArq1 := ""
        cCadastro := alltrim(FWX2Nome(cAlias)) + " - " + cTitulo

SX3->(DbSetOrder(1))
If SX3->(DbSeek("EY8"))
   While SX3->(!Eof() .And. X3_ARQUIVO == "EY8")
      If (!(AllTrim(SX3->X3_CAMPO) $ "EY8_SLDATU") .And. X3Uso(SX3->X3_USADO)) .Or. SX3->X3_PROPRI == "U"
         aAdd(aCposEnch, SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
   EndDo
EndIf

mBrowse(6, 1, 22, 75, cAlias)

RestOrd(aOrd, .F.)
If(File(cNomArq1+GetDBExtension()),FErase(cNomArq1+GetDBExtension()),)

Return Nil

/*
Funcao      : Ae108ArmTransf
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Transferir quantidades de remessas estocadas em consignação.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/05/06 - 09:30
Revisao     :
Obs.        :
*/
*-----------------------*
Function Ae108ArmTransf()
*-----------------------*
Local aOrd := SaveOrd({"EY5"})

Private aRotina := MenuDef(ProcName())
Private cAlias := "EY5",;
        cOpcao := "TRANSFERENCIA",;
        cTitulo := STR0065,;//"Transferência de Remessas"
        cTitBotao := STR0064,;//"Transferir"
        cNomArq1 := ""
        cCadastro := alltrim(FWX2Nome(cAlias)) + " - " + cTitulo 

mBrowse(6, 1, 22, 75, cAlias)

RestOrd(aOrd, .F.)
If(File(cNomArq1+GetDBExtension()),FErase(cNomArq1+GetDBExtension()),)

Return Nil

/*
Funcao      : Ae108ArmMan()
Parametros  : cAlias -> Alias do arquivo corrente.
              nOpc -> Ação a ser executada
              nPos -> Posição do botão escolhido no array aRotina
Retorno     : Nenhum.
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/05/06 - 09:30
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function Ae108ArmMan(cAlias, nReg, nOpc)
*--------------------------------------*
Local aOrd := SaveOrd({cAlias}), aEnchoice
Local oDlg
Local cOpc := ""
Local bOk     := {|| If(lOk := (Obrigatorio(aGets,aTela) .And. ArmManValid(cOpcao)),oDlg:End(),)},;
      bCancel := {|| oDlg:End()}
Local nInc
Local cAliasEnc
Private nOpcao := nOpc
Private lOk := .F.
Private aGets[0],aTela[0]

Begin Sequence

   If cOpcao == "BAIXA" .And. nOpc == INCLUIR
      If !(EY5->EY5_SLDATU > 0)
         MsgInfo(STR0073, STR0008)//"A remessa selecionada não possui saldo disponível."###"Atenção"
         Break
      EndIf
      For nInc := 1 To EY8->(FCount())
         M->&(EY8->(FieldName(nInc))) := CriaVar(EY8->(FieldName(nInc)))
      Next
      For nInc := 1 To (cAlias)->(FCount())
         cField := (cAlias)->(FieldName(nInc))
         M->EY8_SLDATU := EY5->EY5_SLDATU
         If Type("M->EY8_" + Right(cField, Len(cField)-4)) == Type(cAlias + "->" + cField)
            M->&("EY8_" + Right(cField, Len(cField)-4)) := (cAlias)->&(FieldName(nInc))
         EndIf
      Next nInc
      M->EY8_SLDINI := 0
      cAliasEnc := "EY8"
      aEnchoice := aCposEnch
   ElseIf (cOpcao == "BAIXA" .And. nOpc == VISUALIZAR) .Or. cOpcao == "ESTORNO" .Or. cOpcao == "TRANSFERENCIA"
      If cOpcao == "TRANSFERENCIA" .And. nOpc == INCLUIR .And. !(EY5->EY5_SLDATU > 0)
         MsgInfo(STR0073, STR0008)//"A remessa selecionada não possui saldo disponível."###"Atenção"
         Break
      EndIf
      For nInc := 1 To (cAlias)->(FCount())
         M->&((cAlias)->(FieldName(nInc))) := (cAlias)->(FieldGet(nInc))
      Next nInc
      cAliasEnc := cAlias
      If cOpcao == "ESTORNO"
         M->EY8_VM_OBS :=  MSMM(EY8->EY8_OBS,AVSX3("EY8_VM_OBS",AV_TAMANHO))
         aEnchoice := aCposEnch
      EndIf
      If cOpcao == "TRANSFERENCIA"
         If nOpc == INCLUIR
            M->EY5_IMPORT := CriaVar("EY5_IMPORT")
            M->EY5_IMLOJA := CriaVar("EY5_IMLOJA")
            M->EY5_SLDINI := 0
         EndIf
      EndIF
   Else
      Break
   EndIf


   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,636 OF oMainWnd PIXEL

    EnChoice(cAliasEnc, nReg, nOpc,,,, If(ValType(aEnchoice) == "A", aEnchoice, Nil),PosDlg(oDlg),)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If !lOk .Or. nOpc == VISUALIZAR
      Break
   EndIf
   Ae108Armazens(cAlias, nOpc)

End Sequence
RestOrd(aOrd, .T.)

Return lOk

*---------------------------------
Static Function ArmManValid(cOpc)
Private cOpcao := cOpc
Private lRet := .T.

If EasyEntryPoint("EECAE108")
   ExecBlock("EECAE108", .F., .F., "ARMMANVALID")
End

Return lRet

/*
Funcao      : Ae108ArmBusca()
Parametros  : cAlias, nReg, nOpc
Retorno     : Nenhum.
Objetivos   : Buscar remessas ou transferências.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/05/06 - 09:30
Revisao     :
Obs.        :
*/
*----------------------------------------*
Function Ae108ArmBusca(cAlias, nReg, nOpc)
*----------------------------------------*
Local nLin := 18, nCol1 := 8, nCol2 := 40, nInc := 12
Local lOk := .F.
Local bOk, bCancel
Local aButtons := {{"BMPINCLUIR" /*"EDIT"*/    , {|| If(Ae108Armazens(cAliasWk, INCLUIR), QryArmazens(),) }, cTitBotao},;
                   {"BMPVISUAL" /*"ANALITICO"*/, {|| Ae108Armazens(cAliasWk, VISUALIZAR)}, STR0059}}
Local aOrd := SaveOrd({cAlias})

Private cAliasWk := "Wk" + cAlias, cOpc := "", cQry,;
        cArm := Space(AvSx3(cAlias + "_IMPORT", AV_TAMANHO)),;
        cLjArm := Space(AvSx3(cAlias + "_IMLOJA", AV_TAMANHO)),;
        cRe  := Space(AvSx3(cAlias + "_RE"    , AV_TAMANHO)),;
        cInv := Space(AvSx3(cAlias + "_INVOIC", AV_TAMANHO)),;
        cCadastro

Private aHeader := {},;
        aCampos := Array((cAlias)->(FCount())),;
        aBrowse := {}

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE cTitulo From 1,1 To 142,260 Of oMainWnd PIXEL

    @ nLin+1,nCol1 Say AvSx3("EEC_ARM", AV_TITULO) Size 40, 08 Of oDlg Pixel
    @ nLin,  nCol2 MsGet cArm Size Len(cArm)*4, 08 F3 "ER5" Picture AvSx3("EEC_IMPORT", AV_PICTURE) Valid (Empty(cArm) .Or. ExistCpo("SA1", cArm)) Of oDlg Pixel
    nLin +=nInc
    @ nLin+1,nCol1 Say AvSx3("EEC_ARLOJA", AV_TITULO) Size 40, 08 Of oDlg Pixel
    @ nLin,  nCol2 MsGet cLjArm Size Len(cLjArm)*4, 08 Of oDlg Pixel
    nLin +=nInc
    @ nLin+1,nCol1 Say AvSx3("EE9_RE", AV_TITULO) Size 40, 08  Of oDlg Pixel
    @ nLin,nCol2 MsGet cRe Size Len(cRe)*4, 08 Picture AvSx3("EE9_RE", AV_PICTURE) Of oDlg Pixel
    nLin += nInc
    @ nLin+1,nCol1 Say AvSx3("EE9_INVPAG", AV_TITULO) Size 40, 08 Of oDlg Pixel
    @ nLin,nCol2 MsGet cInv Size Len(cInv)*4, 08 Picture AvSx3("EE9_INVPAG", AV_PICTURE) Of oDlg Pixel
    AvBorda()
    bOk := {|| If(lOk := Ae108VldConsig("OK_BUSCAARM"),oDlg:End(),) }
    bCancel := {|| oDlg:End()}

   ACTIVATE MSDIALOG oDlg Centered On Init EnchoiceBar(oDlg,bOk,bCancel)

   If !lOk .Or. !QryArmazens()
      MsgInfo(STR0072, STR0002)//"Não foram encontradas remessas que se satisfaçam as condições de filtro informadas."###"Aviso"
      Break
   EndIf

   //Define os campos do Browse, independente do alias (campos com nomes iguais)
   aEval({"_IMPORT", "_IMLOJA", "_RE", "_INVOIC", "_COD_I", "_SLDINI"},;
         {|x| aAdd(aBrowse, ColBrw(cAlias + x, cAliasWk))})

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,750 OF oMainWnd PIXEL

    oMsSelect := MsSelect():New(cAliasWk,,,aBrowse,,,PosDlg(oDlg))
    oMsSelect:bAval := {|| Ae108Armazens(cAliasWk, VISUALIZAR) }

   Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| (oDlg:End())}, {|| (oDlg:End())},,aButtons)

End Sequence

Return Nil

/*
Funcao      : QryArmazens
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Efetua query para função Ae108ArmBusca.
Autor       : Rodrigo Mendes Diaz
Data/Hora   :
Revisao     :
Obs.        :
*/
Static Function QryArmazens()
Local cQry := ""
Local lRet := .T.

Begin Sequence

   cQry := "Select " + cAlias + "_IMPORT, " + cAlias + "_IMLOJA, " + cAlias + "_RE, " + cAlias + "_INVOIC, ";
           + cAlias + "_COD_I, " + cAlias + "_SLDINI, " + "R_E_C_N_O_ As WK_RECNO " + " From " + RetSqlName(cAlias) + " Where "
   cQry += "D_E_L_E_T_ <> '*' "
   If !Empty(cArm)
      cQry += "And " + cAlias + "_IMPORT = '" + cArm + "' "
   EndIf
   If !Empty(cLjArm)
      cQry += "And " + cAlias + "_IMLOJA = '" + cLjArm + "' "
   Endif
   If !Empty(cRe)
      cQry += "And " + cAlias + "_RE = '" + cRe + "' "
   EndIf
   If !Empty(cInv)
      cQry += "And " + cAlias + "_INVOIC = '" + cInv + "' "
   EndIf
   If cAlias == "EY5"
      cQry += "And " + cAlias + "_DTREC <> '" + DToS(CToD("  /  /  ")) + "' "
   EndIf

   cQry := ChangeQuery(cQry)
   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "WkQry", .F., .T.)
   If WkQry->(Bof() .And. Eof())
      MsgInfo(STR0132)//STR0132	"Não encontrado"
      WkQry->(DbCloseArea())
      lRet := .F.
      Break
   EndIf
   If Select(cAliasWk) == 0
      cNomArq1 := E_CriaTrab(cAlias,{{"WK_RECNO","N",10,0}},cAliasWk)
   Else
      (cAliasWk)->(AvZap())
   EndIf
   While WkQry->(!Eof())
      (cAliasWk)->(DbAppend())
      AvReplace("WkQry", cAliasWk)
      WkQry->(DbSkip())
   EndDo
   WkQry->(DbCloseArea())
   (cAliasWk)->(DbGoTop())

End Sequence

Return lRet

/*
Funcao      : Ae108Armazens
Parametros  : cAlias, nOpc
Retorno     : Nenhum.
Objetivos   : Efetua transferência, baixa ou estorno de remessa, gravando dados na base.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/05/06 - 10:30
Revisao     :
Obs.        :
*/
*-----------------------------------*
Function Ae108Armazens(cAlias, nOpc)
*-----------------------------------*
Local aOrd := {}
Local lROrd := .F.
Local lRet := .T.

Begin Sequence

   Do Case
      Case (cAlias == "WkEY5" .Or. cAlias == "WkEY8")
         aOrd := SaveOrd({"EY5"})
         (Right(cAlias, 3))->(DbGoTo((cAlias)->WK_RECNO))
         lRet := !(lROrd := !Ae108ArmMan((Right(cAlias, 3)), (cAlias)->WK_RECNO, nOpc))

      Case cAlias == "EY5"
         //Baixa de Saldo para quantidades estocadas
         If cOpcao == "BAIXA"
            EY5->(RecLock("EY5", .F.))
            EY8->(RecLock("EY8", .T.))
            AvReplace("M", "EY8")
            EY8->EY8_DTBX := Date()
            EY8->EY8_HRBX := Time()
            EY8->EY8_USERBX := cUserName
            MSMM(,AVSX3("EY8_VM_OBS",AV_TAMANHO),,M->EY8_VM_OBS,INCMEMO,,,"EY8","EY8_OBS")
            EY5->EY5_SLDATU -= M->EY8_SLDINI
            EY8->(MsUnlock())
            EY5->(MsUnlock())
            MsgInfo(STR0069, STR0002)//"Baixa de remessa efetuada com sucesso."###"Aviso"

         ElseIf cOpcao == "TRANSFERENCIA"//Transferencia de saldo entre armazéns
            EY5->(RecLock("EY5", .F.))
            EY5->EY5_SLDATU -= M->EY5_SLDINI
            M->EY5_IDORIG := EY5->EY5_ID
            EY5->(MsUnlock())
            M->EY5_SLDATU := M->EY5_SLDINI
            M->EY5_ID := GetNewId()
            EY5->(RecLock("EY5", .T.))
            AvReplace("M", "EY5")
            EY5->(MsUnlock())
            MsgInfo(STR0068, STR0002)//"Transferência de remessa efetuada com sucesso."###"Aviso"
         EndIf

      Case cAlias == "EY8"//Estorno de baixa
         If cOpcao == "ESTORNO" .And. MsgYesNo(STR0066, STR0021)//"Confirma estorno da baixa de remessa?"###"Atenção"
            aOrd := SaveOrd({"EY5"})
            EY5->(DbSetOrder(2))
            EY8->(RecLock("EY8", .F.))
            If EY5->(DbSeek(xFilial()+EY8->EY8_ID))
               EY5->(RecLock("EY5", .F.))
               EY5->EY5_SLDATU += EY8->EY8_SLDINI
               EY5->(MsUnlock())
            EndIf
            MSMM(EY8->EY8_OBS,,,,EXCMEMO)
            EY8->(DbDelete())
            EY8->(MsUnlock())
            MsgInfo(STR0067, STR0002)//"Estorno da baixa efetuado com sucesso."###"Aviso"
         EndIf
   End Case

End Sequence
RestOrd(aOrd, lROrd)

//DFS - Criação de Ponto de Entrada para customização na baixa e estorno do armazém de consignação
If EasyEntryPoint("EECAE108")
   ExecBlock("EECAE108",.F.,.F.,"GRV_ESTORNO")
Endif

Return lRet

/*
Funcao      : Ae108GetNewId
Parametros  : Nenhum.
Retorno     : nId
Objetivos   : Busca próximo número sequencial de remessa.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/05/06 - 10:30
Revisao     :
Obs.        :
*/
Static Function GetNewId()
Local aOrd := SaveOrd("EY5")
Local nId := 0

EY5->(DbSetOrder(2))
If EY5->(AvSeekLast(xFilial()))
   While EY5->(Empty(EY5_ID) .And. !Eof() .And. !Bof() .And. EY5_FILIAL == xFilial())
      EY5->(DbSkip(-1))
   EndDo
   If EY5->EY5_FILIAL == xFilial("EY5")
      nId := Val(EY5->EY5_ID)
   EndIf
EndIf

RestOrd(aOrd, .T.)

Return StrZero(nId + 1, AvSx3("EY5_ID", AV_TAMANHO))

/*
Funcao      : AE108ManOIC()
Parametros  : nOpc -> Indica a operação escolhida.
Retorno     : Nenhum.
Objetivos   : Manutenção de OIC´s
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/11/2005
Revisao     :
Obs.        :
*/
*-------------------------*
Function AE108ManOIC(nOpc)
*-------------------------*
Local nOldArea := Select()
Local oDlg
Local lOk := .F., nIpRecno
Local bOk  := {|| lOk := .T. , oDlg:End() }
Local bCancel  := {|| lOk := .F. , oDlg:End() }
Local aButtons := {}
Local cFileBak1 := "", cFileBak2 := "", cFileBak3 := ""
Local LinhaIni       // DFS - Variavel para criação da tela de Manutenção de OIC no Tema TEMAP10
Local ColunIni       // DFS - Variavel para criação da tela de Manutenção de OIC no Tema TEMAP10
Local LinhaFin       // DFS - Variavel para criação da tela de Manutenção de OIC no Tema TEMAP10
Local ColunFin       // DFS - Variavel para criação da tela de Manutenção de OIC no Tema TEMAP10
Local aRecno := {}   // BAK - Variavel para grava os recnos para tratamento de apresentação de tela.
Private cPrefix := AllTrim("002"+EasyGParam("MV_AVG0120",,""))
Private lGrvPrefix := .T.
Private oMsSelectEXZ

Begin Sequence

   aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| AE108DetOIC(VIS_DET)},STR0012}) //"Visualizar"

   If nOpc # VISUALIZAR .And. nOpc # EXCLUIR //.And. Empty(M->EEC_DTEMBA) - FSY - 01/08/13 - Permite alterar a OIC mesmo com data de embarque.

      aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/   ,{|| AE108DetOIC(INC_DET)}, STR0013}) //"Incluir"
      aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/,{|| AE108DetOIC(ALT_DET)}, STR0014}) //"Alterar"
      aAdd(aButtons,{"EXCLUIR",{|| AE108ExcOIC(EXC_DET)}, STR0015}) //"Excluir"

      cFileBak1 :=CriaTrab(,.F.)
      dbSelectArea("WKEXZ")
      //Copy to (cFileBak1+GetdbExtension())
      TETempBackup(cFileBak1) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      cFileBak2 :=CriaTrab(,.F.)
      dbSelectArea("WKEY2")
      //Copy to (cFileBak2+GetdbExtension())
      TETempBackup(cFileBak2) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      cFileBak3 :=CriaTrab(,.F.)
      dbSelectArea("WorkIp")
      //Copy to (cFileBak3+GetdbExtension())
      TETempBackup(cFileBak3) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   EndIf

   If lMarcacao
      aAdd(aButtons,{"PAPEL_ESCRITO",{|| AE108OICMarc("WKEXZ",nOpc,@aRecno)}, STR0133}) //"Marcação" - BAK - 31 de Janeiro de 2011 //STR0133	"Marcação"
   EndIf

   WKEXZ->(DbSetOrder(2))
   WKEXZ->(DbGoTop())

   If EasyEntryPoint("EECAE108")
      ExecBlock("EECAE108",.F.,.F.,{"OIC_INI",nOpc})
   Endif

   // DFS - Condição quando o tema for TEMAP10, para que a tela não apareça cortada.
   If SetMdiChild()
      LinhaIni    := DLG_LIN_INI + (DLG_LIN_INI/4)
      ColunIni    := DLG_COL_INI + (DLG_COL_INI/4)
      ColunFin    := DLG_COL_FIM - (DLG_COL_FIM/3)
      LinhaFin    := DLG_LIN_FIM - (DLG_LIN_FIM/3)

   Else
      LinhaIni    := DLG_LIN_INI+(DLG_LIN_FIM/4)
      ColunIni    := DLG_COL_INI+(DLG_COL_FIM/4)
      LinhaFin    := DLG_LIN_FIM-(DLG_LIN_FIM/4)
      ColunFin    := DLG_COL_FIM-(DLG_COL_FIM/4.5)

   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0080 FROM LinhaIni, ColunIni;  //"Manutenção de OIC´s"
 					                    TO LinhaFin, ColunFin; //DFS - Alteração da variável para atribuição de valores quando for TEMAP10 (MDI).
   						      			OF oMainWnd PIXEL

   //by CRF 14/10/2010 - 09;47
   aEXZBrowse := AddCpoUser(aEXZBrowse,"EXZ","2")

   oMsSelectEXZ := MsSelect():New("WKEXZ",,,aEXZBrowse,,,PosDlg(oDlg))
   oMsSelectEXZ:bAval := {|| AE108DetOIC(VIS_DET) }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   M->EEC_MARCAC := Ae108Marcac()

   If EasyEntryPoint("EECAE108")
      ExecBlock("EECAE108",.F.,.F.,{"OIC_FIM",nOpc,lOk})
   Endif

   If nOpc == VISUALIZAR .Or. nOpc == EXCLUIR .Or. !Empty(M->EEC_DTEMBA)
      Break
   Else
      If !lOk
         DbSelectArea("WKEXZ")
         AvZap()
         TERestBackup(cFileBak1)

         DbSelectArea("WKEY2")
         AvZap()
         TERestBackup(cFileBak2)
       
         DbSelectArea("WorkIp")
         AvZap()
         TERestBackup(cFileBak3)
         WorkIP->(dbGoTop())
      EndIf

   EndIf

End Sequence

If( File(cFileBak1+GetDBExtension()),FErase(cFileBak1+GetDBExtension()),)
If( File(cFileBak2+GetDBExtension()),FErase(cFileBak2+GetDBExtension()),)
If( File(cFileBak3+GetDBExtension()),FErase(cFileBak3+GetDBExtension()),)

Return Nil

/*
Funcao      : AE108DetOIC()
Parametros  : nOpc -> Indica a operação escolhida.
Retorno     : Nenhum.
Objetivos   : Manutenção dos detalhes de um OIC.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 11/11/2005
Revisao     :
Obs.        :
*/
*-------------------------*
Function AE108DetOIC(nOpc)
*-------------------------*
Local oDlg
Local nOpcao  := 0
Local cSeqOIC
Local aBack
Local aButtons := {}
Local lValid := .F.
Local nRecnoEXZ
Local bOk     := {|| Eval(bValid), If (lValid .Or. nOpc == VIS_DET, (nOpcao := 1, oDlg:End()), MsgInfo(STR0105,STR0021)),  } //"A vinculação de itens é obrigatória."###"Atenção"
Local bCancel := {|| nOpcao := 0, oDlg:End() }
Local bValid  := {|| WorkIp->(DbClearFilter()),WorkIp->(DbGoTop(), dbEval({|| If ((WorkIp->WK_FLAGOIC==cMarca),(lValid:=.T.),) },,{|| !WorkIp->(Eof()) }),DbGoTop()),WorkIp->(DbSetFilter({|| &(cCond)}, cCond))}
Local aOrd, aFilter
Local nInd
Local oMsSelectEY2
Local aRecno := {}   // BAK - Variavel para grava os recnos para tratamento de apresentação de tela.
Local cIPFilter := WorkIp->(DbFilter())
Private cSafra, cOicAtu
Private cMarca := GetMark()
Private lInverte := .F.
Private aGets[0],aTela[0]

Begin Sequence

   If nOpc <> VIS_DET
      aBack := EECCopyTo({"WKEXZ", "WKEY2", "WorkIp"})
      aButtons := {{"LBTIK",{|| SelOICItem("TODOS")},STR0024}} //"Marca/Desmarca Todos"
   EndIf

   If lMarcacao
      aAdd(aButtons,{"PAPEL_ESCRITO",{|| AE108OICMarc("WKEY2",nOpc,@aRecno)}, "Marcação"}) //"Marcação" - BAK - 01 de Fevereiro de 2011
   EndIf

   If IsVazio("WKEXZ") .And. nOpc <> INC_DET
      MsgInfo(STR0083,STR0002)//"Não há OIC´s lançados" ### "Aviso"
      Break
   Endif

   If nOpc == INC_DET
      If !ChkSaldoOIC()
         MsgInfo(STR0101, STR0021)//"Não é possível incluir o OIC, não há itens com saldo a vincular." ### "Atenção"
         Break
      EndIf
      If !Ae108IncOic()
         Break
      EndIf
      nRecnoEXZ := WKEXZ->(Recno())
      //WKEXZ->(DbGoBottom(),DbSkip())
      WKEXZ->(DbAppend())
      WKEXZ->EXZ_PREEMB := M->EEC_PREEMB
      WKEXZ->EXZ_OIC    := If(lGrvPrefix, cPrefix, "")+cOicAtu
      WKEXZ->EXZ_SAFRA  := cSafra

      IF(EasyEntryPoint("EECAE108"),ExecBlock("EECAE108",.F.,.F.,"INCLUI_WKEXZ"),) // MCF - 09/05/2016

   Else
      cSafra := WKEXZ->EXZ_SAFRA
   EndIf

   WorkIp->(DbClearFilter())
   WorkIp->(DbSetOrder(2))
   WKEY2->(DbSetOrder(2))
   WKEY2->(DbSetFilter({|| WKEY2->EY2_OIC == WKEXZ->EXZ_OIC .And. WKEY2->EY2_SAFRA == WKEXZ->EXZ_SAFRA }, "WKEY2->EY2_OIC == WKEXZ->EXZ_OIC .And. WKEY2->EY2_SAFRA == WKEXZ->EXZ_SAFRA" ))
   WKEY2->(DbGoTop())
   While WKEY2->(!Eof())
      WorkIp->(DbSeek(WKEY2->EY2_SEQEMB))
      If Empty(WorkIp->WK_FLAGOIC)
         WorkIp->WK_FLAGOIC := cMarca
         WorkIp->WK_QTDOIC := 0
      EndIf
      WorkIp->WK_QTDOIC  += WKEY2->EY2_QTDE
      WKEY2->(DbSkip())
   EndDo
   WKEY2->(DbGoTop())
   //FSM - 19/07/2012 - Nopado
   //WorkIp->(DbSetFilter({|| WorkIp->(WK_FLAGOIC == cMarca .Or. WK_TOTOIC <> EE9_SLDINI)}, "WorkIp->(WK_FLAGOIC == cMarca .Or. WK_TOTOIC <> EE9_SLDINI)"))
   // BAK - Não estava apresentando os itens para a vinculação no OIC
   If nOpc <> INC_DET
      cCond := "WK_FLAGOIC == '" + cMarca + "' .Or. WK_TOTOIC <> "+ AllTrim(Str(WorkIp->EE9_SLDINI)) //FSM - 19/07/2012 - Nopado
   Else
      cCond := "WK_FLAGOIC <> '" + cMarca + "' .Or. WK_TOTOIC <> "+ AllTrim(Str(WorkIp->EE9_SLDINI)) //FSM - 19/07/2012 - Nopado
   EndIf
   WorkIp->(DbSetFilter({|| &(cCond)}, cCond))
   WorkIp->(DbGoTop())

   aCposBrowse:={{"WK_FLAGOIC",""," "},;
                 {{|| WorkIp->EE9_SEQEMB},"",AvSx3("EE9_SEQEMB",AV_TITULO)},;
                 {{|| Transf(WorkIp->WK_QTDOIC, AVSX3("EXZ_QTDE", AV_PICTURE)) },"",STR0102},;//"Qtd. Vinculada"
                 {{|| Transf(WorkIp->(EE9_SLDINI - WK_TOTOIC),AVSX3("EXZ_QTDE",AV_PICTURE))},"",STR0103 }}//"Saldo a Vincular"

   DEFINE MSDIALOG oDlg TITLE STR0084 FROM DLG_LIN_INI+(DLG_LIN_FIM/4),DLG_COL_INI+(DLG_COL_FIM/4);//"Vinculação de Itens"
   					                                  TO DLG_LIN_FIM-(DLG_LIN_FIM/4),DLG_COL_FIM-(DLG_COL_FIM/4.5); //4)  ; // By JPP - 06/11/2006 - 17:10 - Correção no dimensionamento da tela para ambiente MDI.
   						      						  OF oMainWnd PIXEL
   aPos := PosDlg(oDlg)

   oMsSelectEY2 := MsSelect():New("WorkIp","WK_FLAGOIC",,aCposBrowse,@lInverte,@cMarca,aPos)
   oMsSelectEY2:bAval := {|| If (nOpc <> VIS_DET,SelOICItem(),),}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   WorkIp->(DbClearFilter())
   WKEY2->(DbClearFilter())
   WKEY2->(DbGoTop())
   WorkIp->(DbGoTop())

   If nOpc == VIS_DET
      Break
   EndIf

   If nOpcao == 0
      EECRestBack(aBack, .F.) 
      If nOpc == INC_DET
         WKEXZ->(DbGoTo(nRecnoEXZ))
      EndIf
   Else
      If nOpc == INC_DET
/*         WKEXZ->(DbAppend())
         WKEXZ->EXZ_PREEMB := M->EEC_PREEMB
         WKEXZ->EXZ_OIC    := cPrefix+cOicAtu
         WKEXZ->EXZ_SAFRA  := cSafra
         WKEY2->(dbEval({|| If( (Empty(WKEY2->EY2_OIC)),(WKEY2->EY2_OIC := WKEXZ->EXZ_OIC), ) },,;
                        {|| !WKEY2->(EOF()) }))*/
      EndIf
      //Recalcula o total vinculado do OIC
      nQtde := WKEXZ->EXZ_QTDE
      WKEXZ->EXZ_QTDE := 0
      WKEY2->(DbGoTop())
      WKEY2->(dbEval({|| If (WKEY2->(EY2_OIC+EY2_SAFRA) == WKEXZ->(EXZ_OIC+EXZ_SAFRA),WKEXZ->EXZ_QTDE += WKEY2->EY2_QTDE,) },,;
                     {|| !WKEY2->(EOF()) }))
      WKEXZ->WK_SLDINV += (WKEXZ->EXZ_QTDE - nQtde)
   EndIf

End Sequence

WorkIp->(DbGoTop())
WorkIp->(dbEval({|| WorkIp->(WK_FLAGOIC := Space(2), WK_QTDOIC := 0) },,{|| !WorkIp->(EOF()) }))
//RMD - 02/03/13 - Em algumas situações (ex. Off-Shore) o sistema não insere filtro na WorkIp.
If !Empty(cIpFilter)
	WorkIp->(DbSetFilter({|| &(cIPFilter)}, cIPFilter))
EndIf
EECRestBack(aBack, .T.) 

Return Nil

/*
Funcao      : AE108IncOic()
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Obter dados necessários para inclusão de um OIC.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 06/02/06
Revisao     :
Obs.        :
*/
*-----------------------*
Function AE108IncOic()
*-----------------------*
Local cGetSafra := AllTrim(EasyGParam("MV_AVG0117",,(Right(AllTrim(Str(Year(Date())-1)),2)+Right(AllTrim(Str(Year(Date()))),2))))
Local cGetOic   := Ae108SeekLastOIC(cGetSafra)
Local lRet      := .F.
Local bOk       := {|| If(Eval(bValid),(lRet := .T., oDlg:End()),)}
Local bCancel   := {|| oDlg:End()}
Local bValid    := {|| Ae108VldSafra(cGetSafra) .And. ValidOic(cGetOic, cGetSafra)}
Local oDlg
Private cSafraAux := ""

Begin Sequence

   if EasyEntryPoint("EECAE108")
      ExecBlock("EECAE108",.F.,.F.,{"SAFRA",cGetSafra,cGetOic})
      if !empty(cSafraAux)
         cGetSafra := cSafraAux
      endif
   endif

   If Valtype(cGetSafra) <> "C" .Or. Len(cGetSafra) <> 4 .Or. (Val(Right(cGetSafra,2)) - 1) <> (Val(Left(cGetSafra,2)))
      Msginfo(STR0108,STR0021) // "Safra atual invalida. A Safra atual não será carregada." ### "Atenção"
      cGetSafra := (Right(AllTrim(Str(Year(Date())-1)),2)+Right(AllTrim(Str(Year(Date()))),2))
      cGetOic   := Ae108SeekLastOIC(cGetSafra)
   EndIf

   // BAK - Ajuste do tamanho da tela para apresentar corretamente os gets
   Define MsDialog oDlg Title STR0134 From 1,1 To /*110*/190,389 OF oMainWnd Pixel // 110,260 // By JPP - 06/11/2006 - 17:10 - Correção no dimensionamento da tela para ambiente MDI. //STR0134	"Inclusão de OIC."
      AvBorda(oDlg,,.T.)

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 14/09/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 24,35 Say STR0106 Pixel Of oPanel //"Safra"
      @ 23,60 MsGet cGetSafra Size 25,08 Pixel Of oPanel Valid Ae108VldSafra(cGetSafra) On Change cGetOic := Ae108SeekLastOIC(cGetSafra) Picture "@R 99/99"

      @ 35,35 Say AvSx3("EXZ_OIC",AV_TITULO) Pixel Of oPanel//"Nro. Oic"
      @ 34,60 MsGet cGetOic Size 25,08 Pixel Of oPanel Valid ValidOic(cGetOic, cGetSafra) Picture "@R 9999"

      IF(EasyEntryPoint("EECAE108"),ExecBlock("EECAE108",.F.,.F.,"TELA_INCOIC"),) // GFP - 12/04/2016

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered

   If lRet
      cSafra := Left(cGetSafra,2)+Right(cGetSafra,2)
      If !EasyGParam("MV_AVG0117",.T.)
         MsgInfo(STR0107,STR0021) // "O parametro 'MV_AVG0117' não existe. A safra criada não poderá ser configurada como safra atual." ### "Atenção"
      Else
         SetMv("MV_AVG0117",cSafra)
      EndIf
      cOicAtu := cGetOic
   EndIf
End Sequence

Return lRet

/*
Funcao      : ValidOic
Parametros  : cOic
Retorno     : lRet
Objetivos   : Valida a inclusão de um Oic
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 16/02/06
*/
*------------------------------------*
Static Function ValidOic(cOic, cSafra)
*------------------------------------*
Local aOrd := SaveOrd({"EXZ", "WKEXZ"})
Private lRet := .T., cOicRDM := cOic, cSafraRDM := cSafra //MCF - 09/05/2016 - Variável criada para ser utilizada no ponto de entrada VALIDOIC

Begin Sequence
   If Len(AllTrim(cOic)) < 4
      MsgInfo(STR0118, STR0021)//"O número do OIC deve possuir 4 dígitos." "Atenção"
      lRet := .F.
      Break
   EndIf
   cOic := IncSpace(If(lGrvPrefix, cPrefix, "")+cOic,AvSx3("EXZ_OIC",AV_TAMANHO),.F.)
   EXZ->(DbSetOrder(3))
   EXZ->(DbGoTop())
   WKEXZ->(DbGoTop())
   While WKEXZ->(!Eof())
      If WKEXZ->EXZ_Safra == cSafra .And. WKEXZ->EXZ_OIC == cOic
         lRet := .F.
         Exit
      EndIf
      WKEXZ->(DbSkip())
   EndDo
   If lRet .And. EXZ->(DbSeek(xFilial("EXZ")+cSafra+cOic))
      lRet := .F.
   EndIf

   IF(EasyEntryPoint("EECAE108"),ExecBlock("EECAE108",.F.,.F.,"VALIDOIC"),) // GFP - 12/04/2016

   If !lRet
      MsgInfo(STR0119, STR0021)//"Já existe registo com esse código." "Atenção"
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : AE108ExcOIC()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Exclui um OIC e todos os seus vinculos com itens do embarque.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 16/11/2005
*/
*--------------------*
Function AE108ExcOIC()
*--------------------*
Local aMsg := {}, aDetail := {}

Begin Sequence
   If IsVazio("WKEXZ")
      MsgInfo(STR0083,STR0002)//"Não há OIC´s lançados" ### "Aviso"
      Break //DFS - 25/10/12 - Inclusão de break para sair do Begin Sequence se não houver OIC's lançados
   Endif

   WKEY2->(DbSetOrder(1))
   WKEY2->(DbSeek(WKEXZ->(EXZ_OIC+EXZ_SAFRA)))
   While WKEY2->(!Eof() .And. EY2_OIC == WKEXZ->EXZ_OIC .And. EY2_SAFRA == WKEXZ->EXZ_SAFRA)
      If !Empty(WKEY2->EY2_NRINVO)
         aAdd(aDetail, {WKEY2->EY2_SEQEMB, WKEY2->EY2_NRINVO})
      EndIf
      WKEY2->(DbSkip())
   EndDo
   If Len(aDetail) > 0
      aAdd(aMsg, {STR0081, .T.})//"Não é possivel excluir o OIC porque o mesmo encontra-se vinculado a(s) seguinte(s) invoice(s):"
      aAdd(aMsg, {EECMontaMsg({"EY2_SEQEMB","EY2_NRINVO"},aDetail), .F.})
      EECView(aMsg,,STR0008)
      Break
   EndIf
   If !MsgYesNo(STR0082,STR0021)//"Deseja excluir o OIC?" ### "Atenção"
      Break
   EndIf
   WKEY2->(DbGoTop())
   WKEY2->(DbSeek(WKEXZ->(EXZ_OIC+EXZ_SAFRA)))
   While WKEY2->(!Eof() .And. EY2_OIC == WKEXZ->EXZ_OIC .And. EY2_SAFRA == WKEXZ->EXZ_SAFRA)
      If !Empty(WKEY2->WK_RECNO)
         aADD(aDetOICDel, WKEY2->WK_RECNO)
      EndIf
      WorkIp->(DbSetOrder(2))
      WorkIp->(DbSeek(WKEY2->EY2_SEQEMB))
      WorkIp->WK_TOTOIC -= WKEY2->EY2_QTDE
      WKEY2->(DbDelete())
      WKEY2->(DbSkip())
   EndDo
   If !Empty(WKEXZ->WK_RECNO)
      aADD(aCapOICDel, WKEXZ->WK_RECNO)
   EndIf
   WKEXZ->(DbDelete())
   WKEXZ->(DbGoTop())
   oMsSelectEXZ:oBrowse:Refresh()

End Sequence

Return Nil

/*
Funcao      : AE108OICMarc(cWork,nOpc)
Parametros  : cWork - variável pra verificar qual work será utilizado, podendo ser WKEXZ (capa) ou WKEY2 (detalhe),
                      para tratar o campo de marcação de cada uma delas.
              nOpc - Indica a operação escolhida.
Retorno     :
Objetivos   : Tratamento para a marcação das OIC´s.
Autor       : Bruno Akyo Kubagawa
Data/Hora   : 31/01/11 15:00
Revisao     :
Obs.        :
*/
Function AE108OICMarc(cWork,nOpc,aRecno)
Local lOk       := .F.
Local cSay      := ""
Local cMemoMarc := ""
Local cTitulo   := ""
Local cMsgYesNo := ""
Local nLinIni   := 0
Local nColIni   := 0
Local nLinFim   := 0
Local nColFim   := 0
Local nSayLin   := 0
Local nSayCol   := 0
Local nOpcA     := nOpc
Local bOk       := {|| lOk := .T. , oDlg:End() }
Local bCancel   := {|| lOk := .F. , oDlg:End() }
Local oSay
Local oGet
Local oDlg
Local lMarcYesNo := .T.
Local nRecno

Begin Sequence

   Do Case
      Case cWork == "WKEXZ"
         If Select("WKEXZ") = 0
            DbSelectArea("WKEXZ")
         EndIf

         If Empty(WKEXZ->EXZ_OIC)
            MsgInfo(STR0135, STR0021)//STR0135	"Insira um OIC para registrar uma marcação." //STR0021 	"Atenção"
            Break
         EndIf

         cSay      := STR0136 + Transf(WKEXZ->EXZ_OIC,"@R 999/99999/9999") + ":" //STR0136	"Insira abaixo uma marcação para o OIC "
         nLinIni   := 24
         nColIni   := 02
         nLinFim   := 109.5
         nColFim   := 234
         nSayLin   := 15
         nSayCol   := 11
         cTitulo   := STR0137 + Transf(WKEXZ->EXZ_OIC,"@R 999/99999/9999") //STR0137	"Edição da marcação do OIC - "
         cMsgYesNo := STR0138 + Transf(WKEXZ->EXZ_OIC,"@R 999/99999/9999") + "?" //STR0138	"Deseja criar uma marcação específica para esse OIC - "

         //Tratamento para nOpc da capa.
         //Opção de escolha da capa esta decrementado a um.
         // no vetor aRotina a opção de inclusão está com 3 porém na define INC_DET está com 4.
         nOpcA++

         If Empty(WKEXZ->EXZ_MARCAC)
            cMemoMarc := M->EEC_MARCAC
         Else
            cMemoMarc := WKEXZ->EXZ_MARCAC
         EndIf

         nRecno := WKEXZ->(Recno())

      Case cWork == "WKEY2"
         If Select("WKEY2") = 0
            DbSelectArea("WKEY2")
         EndIf

         If Empty(WorkIp->WK_FLAGOIC)
            MsgInfo(STR0139, STR0021)//STR0139	"Marque um item para inserir uma marcação." //STR0021 	"Atenção"
            Break
         EndIf

         WKEY2->(DBSetOrder(1))
         WKEY2->(DbSeek(WKEXZ->EXZ_OIC+WKEXZ->EXZ_SAFRA+WorkIp->EE9_SEQEMB))
         cSay      := STR0140 + ENTER + "OIC " + Transf(WKEY2->EY2_OIC,"@R 999/99999/9999") + " - " + AllTrim(WKEY2->EY2_SEQEMB) //STR0140	"Insira abaixo uma marcação para o item do "
         nLinIni   := 36
         nColIni   := 02
         nLinFim   := 98
         nColFim   := 234
         nSayLin   := 15
         nSayCol   := 14
         cTitulo   := STR0141 + Transf(WKEY2->EY2_OIC,"@R 999/99999/9999") + " - " + AllTrim(WKEY2->EY2_SEQEMB)//STR0141	"Edição da marcação do item do OIC - "
         cMsgYesNo := STR0138 + Transf(WKEXZ->EXZ_OIC,"@R 999/99999/9999") + " - " + AllTrim(WKEY2->EY2_SEQEMB) + "?" //STR0138	"Deseja criar uma marcação específica para esse OIC - "

         If Empty(WKEXZ->EXZ_MARCAC) .And. Empty(WKEY2->EY2_MARCAC)
            cMemoMarc := M->EEC_MARCAC
         ElseIf Empty(WKEY2->EY2_MARCAC)
            cMemoMarc := WKEXZ->EXZ_MARCAC
         Else
            cMemoMarc := WKEY2->EY2_MARCAC
         EndIf

         nRecno := WKEY2->(Recno())

   EndCase

   If ASCAN(aRecno,nRecno) == 0 .And. nOpcA <> VIS_DET
      lMarcYesNo  := MsgYesNo(cMsgYesNo,STR0021)//STR0021 	"Atenção"
      If lMarcYesNo
         AADD(aRecno,nRecno)
      EndIf
   EndIf

   If lMarcYesNo
      Define MsDialog oDlg Title cTitulo From 9,0 To 27,60 Of oMainWnd

         oFont := TFont():New('Courier new',,-14,.T.)
         oSay  := TSay():New(nSayLin, nSayCol, {|| cSay}, oDlg,,oFont,,,, .T.,,, nColFim, 20)
         If nOpcA <> VIS_DET
            @ nLinIni, nColIni Get oMemo Var cMemoMarc MEMO HSCROLL Size nColFim,nLinFim Of oDlg Pixel
         Else
            @ nLinIni, nColIni Get oMemo Var cMemoMarc MEMO HSCROLL Size nColFim,nLinFim When .F. Of oDlg Pixel
         EndIf
         oMemo:EnableVScroll(.T.)
         oMemo:EnableHScroll(.T.)

      Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, bOk, bCancel)
   EndIf

   Do Case
      Case cWork == "WKEXZ" .And. lOk
         If RecLock("WKEXZ",.F.)
            WKEXZ->EXZ_MARCAC := cMemoMarc
            WKEXZ->(MsUnLock())
         EndIf
      Case cWork == "WKEY2" .And. lOk
         If RecLock("WKEY2",.F.)
            WKEY2->EY2_MARCAC := cMemoMarc
            WKEY2->(MsUnLock())
         EndIf
   EndCase


End Sequence

Return Nil

/*
Funcao      : ChkSaldoOIC()
Parametros  : Nenhum.
Retorno     : lSaldo -> .T. Existem itens com saldo a vincular.
                        .F. Não existem itens com saldo a vincular.
Objetivos   : Verificar se existem itens com saldo não vinculado a OIC´s.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 21/11/05 13:00
Revisao     :
Obs.        :
*/
*----------------------------*
Static Function ChkSaldoOIC()
*----------------------------*
Local nRecno, lSaldo := .F.

Begin Sequence

   nRecno := WorkIp->(Recno())
   WorkIp->(DbGoTop())
   While WorkIp->(!Eof())
      If WorkIp->(EE9_SLDINI - WK_TOTOIC) > 0
         lSaldo := .T.
         Break
      EndIf
      WorkIp->(DbSkip())
   EndDo

End Sequence
WorkIp->(DbGoTo(nRecno))

Return lSaldo

/*
Funcao      : SelOICItem(cOpc, lTodos)
Parametros  : cOpc   -> Opção escolhida
              lTodos -> Indica se foi escolhida a opção "MarcaTodos"
Retorno     : Nenhum.
Objetivos   : Vincular itens do embarque a um OIC.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 21/11/05 15:00
Revisao     :
Obs.        :
*/
*---------------------------------------*
Static Function SelOICItem(cOpc, lTodos)
*---------------------------------------*
Local nQtde, nVinc
Local cCond := Space(2)
Local aMsg := {}
Default cOpc   := "ITEM"
Default lTodos := .F.

Begin Sequence

   Do Case

      Case cOpc == "ITEM"

         If WorkIp->WK_FLAGOIC == cMarca
            WKEY2->(DbSetOrder(1))
            WKEY2->(DbSeek(WKEXZ->EXZ_OIC+WKEXZ->EXZ_SAFRA+WorkIp->EE9_SEQEMB))
            While WKEY2->(!Eof() .And. EY2_SEQEMB == WorkIp->EE9_SEQEMB)
               If !Empty(WKEY2->EY2_NRINVO)
                  If !lTodos
                     MsgInfo(StrTran(STR0085,"XXX",AllTrim(WKEY2->EY2_NRINVO)),STR0002)//"Não é possivel desvincular o item porque o mesmo está vinculado a invoice XXX"
                  Else
                     aAdd(aErros, {WKEY2->EY2_SEQEMB, WKEY2->EY2_NRINVO})
                  EndIf
                  Break
               EndIf
               WKEY2->(DbSkip())
            EndDo
            WKEY2->(DbSkip(-1))
            WorkIp->WK_TOTOIC -= WKEY2->EY2_QTDE
            WorkIp->WK_QTDOIC := 0
            If(!Empty(WKEY2->WK_RECNO), aAdd(aDetOICDel, WKEY2->WK_RECNO),)
            WKEY2->(DbDelete())
            WorkIp->WK_FLAGOIC := Space(2)
         Else
            nQtde := WorkIp->(EE9_SLDINI - WK_TOTOIC)
            If nQtde > 0
               If (!lTodos .And. (nVinc := AltOICItem(nQtde)) > 0) .Or. (lTodos)
                  If(lTodos, nVinc := nQtde,)
                  WKEY2->(DbAppend())
                  WorkIp->WK_FLAGOIC := cMarca
                  WKEY2->EY2_PREEMB  := M->EEC_PREEMB
                  WKEY2->EY2_OIC     := WKEXZ->EXZ_OIC
                  WKEY2->EY2_SAFRA   := cSafra
                  WKEY2->EY2_SEQEMB  := WorkIp->EE9_SEQEMB
                  WKEY2->EY2_QTDE    := nVinc
                  WorkIp->WK_TOTOIC  += nVinc
                  WorkIp->WK_QTDOIC  := nVinc
               EndIf
            Else
               If !lTodos
                  MsgInfo(STR0086,STR0002)//"Item sem saldo disponível para vinculação" ### "Aviso"
               Else
                  aAdd(aErros, {WorkIp->EE9_SEQEMB})
               Endif
            EndIf
         EndIf

      Case cOpc == "TODOS"
         Private aErros := {}
         WorkIp->(DbGoTop())
         If Empty(WorkIp->WK_FLAGOIC)
            cCond := cMarca
         EndIf
         While WorkIp->(!Eof())
            If WorkIp->WK_FLAGOIC != cCond
               SelOICItem("ITEM",.T.)
            EndIf
            WorkIp->(DbSkip())
         EndDo
         WorkIp->(DbGoTop())
         If Len(aErros) > 0 .And. MsgYesNo(STR0097,STR0033)//"Deseja visualizar problemas na vinculação de itens?"###"Atenção"
            If Empty(cCond)
               aAdd(aMsg, {STR0099, .T.})//"Os seguintes itens não podem ser desmarcados porque estão vinculados a Invoices:"
               aAdd(aMsg, {EECMontaMsg({"EY2_SEQEMB","EY2_NRINVO"},aErros), .F.})
               EECView(aMsg,,STR0008)
            Else
               aAdd(aMsg, {STR0100, .T.})//"Os seguintes itens não puderam ser marcados porque não possuem saldo suficiente:"
               aAdd(aMsg, {EECMontaMsg({"EY2_SEQEMB"},aErros), .F.})
               EECView(aMsg,,STR0008)
            EndIf
         EndIf

   EndCase

End Sequence

Return Nil

/*
Funcao      : AltOICItem(nQtde, lTodos)
Parametros  : nQtde  -> Saldo a vincular do item em questão.
              lTodos -> Indica se foi escolhida a opção "MarcaTodos"
Retorno     : lOk
Objetivos   : Possibilitar que o usuário informe a quantidade a ser vinculada do item.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 21/11/05 13:00
Revisao     :
Obs.        :
*/
*---------------------------------------*
Static Function AltOICItem(nQtde)
*---------------------------------------*
Local oDlg
Local lOk       := .F.
Local bOk       := {|| If ((Eval(bValidSup) .And. Eval(bValidSup)),(lOk := .T., oDlg:End()), )}
Local bCancel   := {|| oDlg:End() }
Local bValidSup := {|| (If ((nQtde > nSaldo),(MsgInfo(STR0087,STR0002),.F.),.T.))}//"Quantidade superior a Permitida" ### "Aviso"
Local bValidInf := {|| (If ((nQtde < 1),(MsgInfo(STR0088,STR0002),.F.),.T.))}//"Quantidade inferior a Permitida" ### "Aviso"
Local nSaldo    := nQtde

Begin Sequence

    // BAK - Ajuste do tamanho da tela, para apresentar corretamente os gets.
	DEFINE MSDIALOG oDlg TITLE STR0096 FROM 1,1 To /*100*/190,350 OF oMainWnd Pixel//"Controle de Saldo" - 285 // By JPP - 06/11/2006 - 17:10 - Correção no dimensionamento da tela para ambiente MDI.

    oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //LRS - 17/08/2018
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @ 14,4  To 48,140 Label STR0089 Pixel Of oPanel//"Indique a quantidade a ser vinculada"
    @ 23,10  Say STR0090 Pixel Of oPanel//"Saldo:"
    @ 22,60 MsGet nSaldo Size 70,07 Picture "@E 999,999,999,999.99" When .F. Pixel Of oPanel
    @ 35,10  Say STR0091 Pixel Of oPanel//"Total a vincular:"
    @ 34,60 MsGet nQtde  Size 70,07 Picture "@E 999,999,999,999.99" Valid Positivo(nQtde) Pixel Of oPanel

    Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered

    If !lOk
       nQtde := 0
       Break
    EndIf

End Sequence

Return nQtde

/*
Funcao      : Ae108WkOIC(lGrv,cAlias)
Parametros  : lGrv   -> .T.   - Grava as tabelas de OIC´s a partir dos arquivos de trabalho.
                        .F.   - Alimenta os arquivos de trabalho com os dados dos OIC´s.
              cAlias -> "EXZ" - A operação será feita com base na tabela de capa dos OIC´s.
                        "EY2" - A operação será feita com base na tabela de detalhes dos OIC´s.
Retorno     : Nenhum.
Objetivos   : Gravar dados referentes a OIC´s.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 21/11/05 11:00
Revisao     :
Obs.        :
*/
*-------------------------------*
Function Ae108WkOIC(lGrv,cAlias)
*-------------------------------*
Local aOrd, nInc

If Type("aCapOICDel") <> "A"
   aCapOICDel := {}
EndIf
If Type("aDetOICDel") <> "A"
   aDetOICDel := {}
EndIf

Begin Sequence
   If cAlias == "EXZ"
      If !lGrv

         AVReplace("EXZ","WKEXZ")
         WKEXZ->WK_RECNO  := EXZ->(RECNO())
         WKEXZ->WK_SLDINV := EXZ->EXZ_QTDE
         If lMarcacao .And. EXZ->(FieldPos("EXZ_CODMAR")) > 0
            WKEXZ->EXZ_MARCAC := MSMM(EXZ->EXZ_CODMAR,AVSX3("EXZ_MARCAC",AV_TAMANHO),,,LERMEMO) // BAK - 01 de Fevereiro de 2011
         EndIf
         aOrd := SaveOrd({"EY2"})
         EY2->(DbSetOrder(1))
         EY2->(DbSeek(xFilial("EY2")+M->EEC_PREEMB+WKEXZ->EXZ_OIC+WKEXZ->EXZ_SAFRA))
      Else
         For nInc := 1 To Len(aCapOICDel)
            EXZ->(DbGoTo(aCapOICDel[nInc]))
            If lMarcacao .And. EXZ->(FieldPos("EXZ_CODMAR")) > 0
               MSMM(EXZ->EXZ_CODMAR,,,,EXCMEMO) // BAK - 01 de Fevereiro de 2011
            EndIf
            EXZ->(RecLock("EXZ",.F.))
            EXZ->(DbDelete())
            EXZ->(MsUnlock())
         Next

         IF(EasyEntryPoint("EECAE108"),ExecBlock("EECAE108",.F.,.F.,"ANTES_GRAVAOIC"),) //LBL - 19/07/2013

         WKEXZ->(DbGoTop())
         While WKEXZ->(!Eof())
            If Empty(WKEXZ->WK_RECNO)
               EXZ->(RecLock("EXZ",.T.))
            Else
               EXZ->(DbGoTo(WKEXZ->WK_RECNO))
               EXZ->(RecLock("EXZ",.F.))
               If lMarcacao .And. EXZ->(FieldPos("EXZ_CODMAR")) > 0
                  MSMM(EXZ->EXZ_CODMAR,,,,EXCMEMO) // BAK - 01 de Fevereiro de 2011
               EndIf
            EndIf
            AvReplace("WKEXZ","EXZ")
            EXZ->EXZ_FILIAL := xFilial("EXZ")
            If lMarcacao .And. EXZ->(FieldPos("EXZ_CODMAR")) > 0
               MSMM(,AVSX3("EXZ_MARCAC",AV_TAMANHO),,WKEXZ->EXZ_MARCAC,INCMEMO,,,"EXZ","EXZ_CODMAR")// BAK - 01 de Fevereiro de 2011
            EndIf
            EXZ->(MsUnlock())
            WKEXZ->(DbSkip())
         EndDo
      EndIf
   EndIf

   If cAlias == "EY2"
      If !lGrv
         AVReplace("EY2","WKEY2")
         WKEY2->WK_RECNO := EY2->(RECNO())
         If lMarcacao .And. EXZ->(FieldPos("EXZ_CODMAR")) > 0
            WKEY2->EY2_MARCAC := MSMM(EY2->EY2_CODMAR,AVSX3("EY2_MARCAC",AV_TAMANHO),,,LERMEMO) // BAK - 01 de Fevereiro de 2011
         EndIf
         If !Empty(WKEY2->EY2_NRINVO)
            WKEXZ->(DbSetOrder(1))
            WKEXZ->(DbSeek(WKEY2->(EY2_OIC+EY2_SAFRA)))
            WKEXZ->WK_SLDINV -= WKEY2->EY2_QTDE
         EndIf
         WorkIp->(DbSetOrder(2))
         If WorkIp->(dbSeek(EY2->EY2_SEQEMB))
            WorkIp->WK_TOTOIC += EY2->EY2_QTDE
         EndIf
      Else
         For nInc := 1 To Len(aDetOICDel)
            EY2->(DbGoTo(aDetOICDel[nInc]))
            If lMarcacao .And. EXZ->(FieldPos("EXZ_CODMAR")) > 0
               MSMM(EY2->EY2_CODMAR,,,,EXCMEMO) // BAK - 01 de Fevereiro de 2011
            EndIf
            EY2->(RecLock("EY2",.F.))
            EY2->(DbDelete())
            EY2->(MsUnlock())
         Next

         WKEY2->(DbGoTop())
         While WKEY2->(!Eof())
            If Empty(WKEY2->WK_RECNO)
               EY2->(RecLock("EY2",.T.))
            Else
               EY2->(DbGoTo(WKEY2->WK_RECNO))
               EY2->(RecLock("EY2",.F.))
               If lMarcacao .And. EXZ->(FieldPos("EXZ_CODMAR")) > 0
                  MSMM(EY2->EY2_CODMAR,,,,EXCMEMO) // BAK - 01 de Fevereiro de 2011
               EndIf
            EndIf
            AvReplace("WKEY2","EY2")
            EY2->EY2_FILIAL := xFilial("EY2")
            If lMarcacao .And. EXZ->(FieldPos("EXZ_CODMAR")) > 0
               MSMM(,AVSX3("EY2_MARCAC",AV_TAMANHO),,WKEY2->EY2_MARCAC,INCMEMO,,,"EY2","EY2_CODMAR")// BAK - 01 de Fevereiro de 2011
            EndIf
            EY2->(MsUnlock())
            WKEY2->(DbSkip())
         EndDo
      EndIf
   EndIf

   If ValType(aOrd) == "A"
      RestOrd(aOrd, .T.)
   Endif

End Sequence

Return Nil

/*
Funcao      : AE108BuscaOic()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Procura por um processo a partir do número de um OIC.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/11/05 15:00
Revisao     :
Obs.        :
*/
*----------------------*
Function AE108BuscaOic()
*----------------------*

Local aOrd := SaveOrd({"EXZ", "EEC"})
Local cOic := Space(AVSX3("EXZ_OIC",AV_TAMANHO))
Local cSafra := Space(AVSX3("EXZ_SAFRA",AV_TAMANHO))
Local lOk := .F.
Local bOk      := {|| If(Eval(bValid),(lOk := .T., oDlg:End()),)}
Local bCancel  := {|| oDlg:End()}
Local bValid   := {|| If(Empty(cOic) .Or. !Ae108VldSafra(cSafra),(MsgInfo(STR0111,STR0033),.F.),.T.)}//"Favor informar o número do OIC."###"Atenção"
Local oDlg
Private cPrefix := AllTrim("002"+EasyGParam("MV_AVG0120",,""))

Begin Sequence

   If EasyEntryPoint("EECAE108")
      ExecBlock("EECAE108",.F.,.F.,"BUSCA_OIC")
   Endif

    DEFINE MSDIALOG oDlg TITLE STR0092 FROM 1,1 To 150,740 OF oMainWnd Pixel//"Pesquisa por OIC"
    

    @ 34,84  To 68,251 Label "" Pixel
    @ 43,105  Say STR0093 Pixel Of oDlg//"Número do OIC:"
    @ 42,155 MsGet cOic Size 70,07 Picture ("@R 9999") Of oDlg Pixel
    @ 55,105  Say STR0106 Pixel Of oDlg//"Safra:"
    @ 54,155 MsGet cSafra Size 70,07 Pixel Valid Ae108VldSafra(cSafra) Picture "@R 99/99" Of oDlg

    Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered

   If !lOk
      Break
   EndIf

   EXZ->(DbSetOrder(2))
   If EXZ->(DbSeek(xFilial("EXZ")+cOic+AllTrim(cSafra))) .Or. EXZ->(DbSeek(xFilial("EXZ")+AvKey(cPrefix+cOic, "EXZ_OIC")+AllTrim(cSafra)))
      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial("EEC")+EXZ->EXZ_PREEMB))
   Else
      MsgInfo(STR0094,STR0002)//"Não foram encontrados processos para o número de OIC informado" ### "Aviso"
   EndIf

End Sequence

RestOrd(aOrd, .F.)

Return Nil

/*
Funcao      : AE108MarkOIC(cTipo)
Parametros  : cTipo -> "OIC"        - Inclui na Invoice todos os itens do OIC marcado.
                       "ALTERAITEM" - Soma a quantidade de um item na mesma invoice.
                       "TODOS"      - Inclui na Invoice os itens de todos os OIC´s do embarque.
Retorno     : Nenhum.
Objetivos   : Vincula os itens dos OIC´s na invoice.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/11/05 12:42
Revisao     :
Obs.        :
*/
*----------------------------------*
Function AE108MarkOIC(cTipo, nQtde)
*----------------------------------*
Local cCond := Space(2),;
      cFlag := cMarca
Local lDesvincula := .F.

Local aOrd := SaveOrd({"WKEXZ","WKEY2","WrkSldInv"})

Begin Sequence
   Do Case
      Case cTipo == "OIC"
         WKEY2->(DbSetOrder(2))
         WrkSldInv->(DbSetOrder(1))
         If Empty(WKITOIC->WK_FLAG)
            If nQtde > 0
               WKITOIC->WK_FLAG := cMarca
               WKITOIC->WK_TOTIT  -= nQtde
               WKITOIC->WK_TOTVIN += nQtde
               WKEY2->(DbSeek(WKITOIC->EY2_SEQEMB))
               While WKEY2->(!Eof() .And. EY2_SEQEMB == WKITOIC->EY2_SEQEMB)
                  If Empty(WKEY2->EY2_NRINVO)
                     If WKEY2->EY2_QTDE == nQtde
                        Exit
                     Else
                        WKEY2->EY2_QTDE -= nQtde
                        WKEY2->(DbAppend())
                        AvReplace("WKITOIC", "WKEY2")
                        WKEY2->WK_RECNO := 0
                        WKEY2->EY2_QTDE := nQtde
                        Exit
                     EndIf
                  EndIf
                  WKEY2->(DbSkip())
               EndDo
               WrkSldInv->(DbSeek(Ae108EY2(WKEY2->EY2_SEQEMB)/*WKEY2->EY2_SEQEMB*/)) //LGS-12/01/2016
               If WrkSldInv->WK_FLAG <> cMarca
                  AE108MarkInv("ITEM")
               Else
                  AE108MarkOIC("ALTERAITEM")
               EndIf
               WKEY2->EY2_NRINVO := M->EXP_NRINVO
               WKEXZ->WK_SLDINV -= nQtde
            EndIf
         Else
            WKITOIC->WK_FLAG := Space(2)
            nQtde := WKITOIC->WK_TOTVIN
            WKITOIC->WK_TOTIT  += nQtde
            WKITOIC->WK_TOTVIN := 0
            WKEY2->(DbSeek(WKITOIC->EY2_SEQEMB))
            While WKEY2->(!Eof() .And. EY2_SEQEMB == WKITOIC->EY2_SEQEMB)
               If WKEY2->EY2_NRINVO == M->EXP_NRINVO
                  nRecnoWKEY2 := WKEY2->(Recno())
                  WrkSldInv->(DbSeek(Ae108EY2(WKEY2->EY2_SEQEMB)/*WKEY2->EY2_SEQEMB*/)) //LGS-12/01/2016
                  If WrkSldInv->EXR_SLDINI == WKEY2->EY2_QTDE
                     AE108MarkInv("ITEM")
                  Else
                     AE108MarkOIC("ALTERAITEM")
                  EndIf
                  WKEY2->EY2_NRINVO := CriaVar("EY2_NRINVO")
               ElseIf Empty(WKEY2->EY2_NRINVO)
                  WKEY2->EY2_QTDE += nQtde
                  lDesvincula := .T.
               EndIf
               WKEY2->(DbSkip())
            EndDo
            If lDesvincula
               WKEY2->(DbGoTo(nRecnoWKEY2))
               If(!Empty(WKEY2->WK_RECNO), aAdd(aDetOICDel, WKEY2->WK_RECNO),)
               WKEY2->(DbDelete())
            EndIf
            WKEXZ->WK_SLDINV += nQtde
         EndIf

      Case cTipo == "ALTERAITEM"
         If WKITOIC->WK_FLAG == cMarca
            WrkSldInv->EXR_SALDO  -= WKEY2->EY2_QTDE
            WrkSldInv->EXR_SLDINI += WKEY2->EY2_QTDE
         Else
            WrkSldInv->EXR_SALDO  += WKEY2->EY2_QTDE
            WrkSldInv->EXR_SLDINI -= WKEY2->EY2_QTDE
         EndIf


      Case cTipo == "TODOS_IT"
         If !Empty(WKITOIC->WK_FLAG)
            cCond := cMarca
            cFlag := Space(2)
         EndIf
         WKITOIC->(DbGoTop())
         While WKITOIC->(!Eof())
            If WKITOIC->WK_FLAG == cCond
               AE108MarkOIC("OIC", WKITOIC->WK_TOTIT)
               WKITOIC->WK_FLAG := cFlag
            EndIf
            WKITOIC->(DbSkip())
         EndDo

      Case cTipo == "TODOS_OIC"
         WKEXZ->(DbGoTop())
         While WKEXZ->(!Eof())
            AE108ItOIC(.T.)
            WKEXZ->(DbSkip())
         EndDo
         WKEXZ->(DbGoTop())

   End Case

End Sequence

RestOrd(aOrd,.T.)

Return Nil

/*
Funcao      : AE108ItOic
Parametros  :
Retorno     : Nenhum.
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   :
Revisao     :
Obs.        :
*/
*--------------------------*
Function AE108ItOIC(lTodos)
*--------------------------*
Local nRecnoEY2 := WKEY2->(Recno())
Local oDlg
Local lInverte := .F., lVinc := .F., lOk := .T.
Local aCposBrowse:= {{"WK_FLAG",""," "},;
                    {{|| WKITOIC->EY2_SEQEMB},"",AvSx3("EE9_SEQEMB",AV_TITULO)},;
                    {{|| Transf(WKITOIC->WK_TOTVIN, AVSX3("EXZ_QTDE", AV_PICTURE)) },"",STR0102},;//"Qtd. Vinculada"
                    {{|| Transf(WKITOIC->WK_TOTIT,AVSX3("EXZ_QTDE",AV_PICTURE))},"",STR0103 }}//"Saldo a Vincular"

Local bOk     := {|| oDlg:End() }
Local bCancel := {|| lOk := .F., oDlg:End() }
Local aButtons := {{"LBTIK",{|| Ae108MarkOIC("TODOS_IT"), oMsSelect:oBrowse:Refresh()},STR0024}} //"Marca/Desmarca Todos"

Local aBack

Default lTodos := .F.

Begin Sequence

   Ae109Works("ZAP", {{"WKITOIC","EY2","cArqOic1",,,,,}})

   If !lTodos
      aBack := EECCopyTo({"WrkSldInv", "WKEXZ", "WKEY2"})
   EndIf

   WKEY2->(DbSetFilter({|| WKEY2->EY2_OIC == WKEXZ->EXZ_OIC .And. WKEY2->EY2_SAFRA == WKEXZ->EXZ_SAFRA },"WKEY2->EY2_OIC == WKEXZ->EXZ_OIC .And. WKEY2->EY2_SAFRA == WKEXZ->EXZ_SAFRA"))
   WKEY2->(DbGoTop())
   While WKEY2->(!Eof())
      If WKEY2->EY2_SEQEMB <> WKITOIC->EY2_SEQEMB .And. (Empty(WKEY2->EY2_NRINVO) .Or. WKEY2->EY2_NRINVO == M->EXP_NRINVO)
         WKITOIC->(DbAppend())
         AvReplace("WKEY2", "WKITOIC")
      EndIf
      If  Empty(WKEY2->EY2_NRINVO)
         WKITOIC->EY2_QTDE += WKEY2->EY2_QTDE
         WKITOIC->WK_TOTIT := WKEY2->EY2_QTDE //Saldo
      ElseIf WKEY2->EY2_NRINVO == M->EXP_NRINVO
         WKITOIC->WK_FLAG := cMarca
         WKITOIC->EY2_QTDE += WKEY2->EY2_QTDE
         WKITOIC->WK_TOTVIN := WKEY2->EY2_QTDE //Total Vinculado
      EndIf
      WKEY2->(DbSkip())
   EndDo
   WKITOIC->(DbGoTop())

   If !lTodos
      DEFINE MSDIALOG oDlg TITLE STR0084 FROM DLG_LIN_INI+(DLG_LIN_FIM/4),DLG_COL_INI+(DLG_COL_FIM/4);//"Vinculação de Itens"
      					                    TO DLG_LIN_FIM-(DLG_LIN_FIM/4),DLG_COL_FIM-(DLG_COL_FIM/5); //4)  ;  // By JPP - 06/11/2006 - 17:10 - Correção no dimensionamento da tela para ambiente MDI.
      						                OF oMainWnd PIXEL
      aPos := PosDlg(oDlg)

      oMsSelect := MsSelect():New("WKITOIC","WK_FLAG",,aCposBrowse,@lInverte,@cMarca,aPos)
      oMsSelect:bAval := {|| AE108MarkOIC("OIC", If(WKITOIC->WK_FLAG <> cMarca,AltOICItem(WKITOIC->WK_TOTIT),)) }

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   Else
      Ae108MarkOIC("TODOS_IT")
   EndIf

   If lOk
      WKITOIC->(DbGoTop())
      WKITOIC->(DbEval({|| If(WKITOIC->WK_FLAG == cMarca, lVinc := .T.,) },,{|| WKITOIC->(!Eof()) }))
      If lVinc
         WKEXZ->WK_FLAG := cMarca
      Else
         WKEXZ->WK_FLAG := Space(2)
      EndIf
   Else
      EECRestBack(aBack)
   EndIf

   EECRestBack(aBack, .T.)

   WKEY2->(DbClearFilter())
End Sequence

Return Nil

/*
Funcao      : AE108VldItDe()
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Exibe no OK final os problemas encontrados ao desmarcar itens do embarque
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 22/11/05 14:00
Revisao     :
Obs.        :
*/
*---------------------*
Function AE108VldItDe()
*---------------------*
Local lRet := .T.
Local aOrd := {}, aMsg := {}, aMsg1 := {},;
      aAmostra := {}, aOic := {}, aRe := {}, aVenda := {}
Local nInc, nRecno, nItem

Begin Sequence

   //Se o tamanho do aItemVinc (declarado como Private no EECAe100) for maior que zero,
   If Len(aItemVinc) > 0
      If MsgYesNo(STR0097,STR0033)//"Deseja visualizar problemas na vinculação de itens?"###"Atenção"
         If EECFlags("CAFE")
            aOrd := SaveOrd({"WKEY2"})
            WKEY2->(DbSetOrder(2))
         EndIf

         For nInc := 1 To Len(aItemVinc)
            If lConsign
               If cTipoProc == PC_RC .And. aItemVinc[nInc][2] == "RE"//Embarque de Remessa por consignação
                  aAdd(aRE, {aItemVinc[nInc][1], aItemVinc[nInc][3], aItemVinc[nInc][4]})
               ElseIf cTipoProc $ PC_VR+PC_VB .And. aItemVinc[nInc][2] == "VENDA"//Venda regular e venda com back to back
                  aAdd(aVenda, {aItemVinc[nInc][1], aItemVinc[nInc][3], aItemVinc[nInc][4]})
               EndIf
            EndIf
            If EECFlags("CAFE") .And. aItemVinc[nInc][2] == "OIC"
               WKEY2->(DbSeek(aItemVinc[nInc][1]))
               aAdd(aOic, {aItemVinc[nInc][1], WKEY2->EY2_OIC})
            EndIf

            If EECFlags("AMOSTRA") .And. aItemVinc[nInc][2] == "AMOSTRA"
               aAdd(aAmostra, {aItemVinc[nInc][1], aItemVinc[nInc][3]})
            EndIf
         Next

         If Len(aVenda) > 0
            aAdd(aMsg, {STR0076 + ENTER, .T.})//"Os seguintes itens não podem ser desmarcados pois estão vinculados a remessas:"
            aAdd(aMsg, {EECMontaMsg({{"EE9_SEQEMB",,,,,},;
                                     {"EE9_SLDINI",,,,,},;
                                     {"EE9_SLDINI",,STR0055,,,}},;//"Qtd. Vinc"
                                     aVenda), .F.})
            aAdd(aMsg, {ENTER, .T.})
         EndIf

         If Len(aOic) > 0
            aAdd(aMsg, {STR0098 + ENTER, .T.})//"Os seguintes itens não podem ser desmarcados pois estão vinculados a OIC´s:"
            aAdd(aMsg, {EECMontaMsg({"EE9_SEQEMB","EXZ_OIC"},aOic), .F.})
            aAdd(aMsg, {ENTER, .T.})
         EndIf

         If Len(aAmostra) > 0
            aAdd(aMsg, {STR0112 + ENTER, .T.})//"Os seguintes itens não podem ser desmarcados pois estão vinculados a Amostras:"
            aAdd(aMsg, {EECMontaMsg({"EE9_SEQEMB","EXU_NROAMO"}, aAmostra), .F.})
            aAdd(aMsg, {ENTER, .T.})
         EndIf

         //**
         //Validação exclusiva do embarque de remessa
         If lConsign .And. cTipoProc == PC_RC//Embarque de Remessa por consignação
            aAdd(aMsg1, {STR0115 + ENTER, .T.})//"Os seguintes itens desmarcados possuem vínculo com R.E. em consignação:"
            aAdd(aMsg1, {EECMontaMsg({"EE9_SEQEMB","EE9_RE"},aRE), .F.})
            aAdd(aMsg1, {ENTER, .T.})
            aAdd(aMsg1, {STR0116 + ENTER, .T.})//"Para continuar, é necessário desvincular o R.E. de cada item."
            aAdd(aMsg1, {STR0117 + ENTER, .T.})//"Deseja que o sistema faça a desvinculação automaticamente?"
            If EECView(aMsg1, STR0021)//Atenção
               nRecno := WorkIp->(Recno())
               For nInc := 1 To Len(aRE)
                  WorkIp->(DbGoTo(aRe[nInc][3]))
                  //Desvincula o R.E. do item
                  Ae108VldConsig("RE")
                  If (nItem := aScan(aItemVinc, {|x| x[1] == aRe[nInc][1] .And. x[2] == "RE"})) > 0
                     aItemVinc := aDel(aItemVinc, nItem)
                     aItemVinc := aSize(aItemVinc, Len(aItemVinc)-1)
                  EndIf
               Next
               WorkIp->(DbGoTo(nRecno))
            Else
               lRet := .F.
            EndIf
         EndIf
         //**

         If Len(aMsg) > 0
            EECView(aMsg, STR0021)//###"Atenção"
            lRet := .F.
         EndIf

      Else
         lRet := .F.
      EndIf
   EndIf

   if lRet == .T.
      cRetGetItemInv := getItemInv()     //WHRS 06/07/2017 TE-5995 519182 - MTRADE-1013 / 1230-Duplicação Itens da Invoice
      if !empty(cRetGetItemInv)
         AVGetSvLog(STR0058, cRetGetItemInv, {6,15})
         lRet:=.F.
      endIf
   endIf
End Sequence

lRetPto := lRet
If EasyEntryPoint("EECAE108")
   ExecBlock("EECAE108", .F., .F., "FIM_VLD_ITEM")
   lRet := lRetPto
EndIf

If Len(aOrd) > 0
   RestOrd(aOrd,.T.)
EndIf

Return lRet

/*
Funcao      : AE108VlMark(lOpc)
Parametros  : lOpc -> .T. - Item está sendo marcado.
                      .F. - Item está sendo desmarcado
Retorno     : Nenhum.
Objetivos   : Tratamentos diversos ao marcar/desmarcar um item do embarque.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/12/05 12:42
Revisao     :
Obs.        :
*/
*-------------------------*
Function AE108VlMark(lOpc)
*-------------------------*
Local aOrd := {}
   //Validações de consignação
   If lConsign
      //Validações do embarque de remessa por consignação
      If cTipoProc == PC_RC
         If lOpc
            //Verifica se o item havia sido desmarcado antes
            If (nItem := aScan(aItemVinc, {|x| x[1] == WorkIp->EE9_SEQEMB .And. x[2] == "RE"})) > 0
               aItemVinc := aDel(aItemVinc, nItem)
               aItemVinc := aSize(aItemVinc, Len(aItemVinc)-1)
            EndIf
         Else
            //Caso o item possua R.E., guarda o EE9_SEQEMB e o recno no array
            If !Empty(WorkIp->EE9_RE)
               aAdd(aItemVinc, WorkIp->({EE9_SEQEMB, "RE", EE9_RE, Recno()}))
            EndIf
         EndIf
      //Validações da venda regular e venda com back to back
      ElseIf cTipoProc $ PC_VR+PC_VB
         //Caso o item possua vinculo com remessa, guarda o EE9_SEQEMB, a quantidade do item e a quantidade vinculada no array
         If WorkIp->(Empty(WP_FLAG) .And. WK_QTDREM > 0)
            aAdd(aItemVinc, WorkIp->({EE9_SEQEMB, "VENDA", EE9_SLDINI, WK_QTDREM}))
         EndIf
      EndIf
   EndIf

   //Validações dos tratamentos de OIC
   If EECFlags("CAFE")
      If lOpc
         //Verifica se o item havia sido desmarcado antes
         If (nItem := aScan(aItemVinc, {|x| x[1] == WorkIp->EE9_SEQEMB .And. x[2] == "OIC"})) > 0
            aItemVinc := aDel(aItemVinc,nItem)
            aItemVinc := aSize(aItemVinc,Len(aItemVinc)-1)
         EndIf
      Else
         aOrd := SaveOrd("WKEY2")
         WKEY2->(DbSetOrder(2))
         //Caso o item esteja vinculado a um OIC, guarda o EE9_SEQEMB do item no array
         If WorkIp->WK_TOTOIC > 0 .And. WKEY2->(DbSeek(WorkIp->EE9_SEQEMB))
            aAdd(aItemVinc, WorkIp->({EE9_SEQEMB, "OIC"}))
         EndIf
         RestOrd(aOrd)
      EndIf
   EndIf

   //Validações dos tratamentos de amostra
   If EECFlags("AMOSTRA")
      If lOpc
         //Verifica se o item havia sido desmarcado antes
         If (nItem := aScan(aItemVinc, {|x| x[1] == WorkIp->EE9_SEQEMB .And. x[2] == "AMOSTRA"})) > 0
            aItemVinc := aDel(aItemVinc,nItem)
            aItemVinc := aSize(aItemVinc,Len(aItemVinc)-1)
         EndIf
      Else
         //Caso o item esteja vinculado a uma Amostra, guarda o EE9_SEQEMB do item no array
         aOrd := SaveOrd({"EXU", "EXV"})
         EXU->(DbSetOrder(1))
         EXV->(DbSetOrder(2))
         If EXV->(DbSeek(xFilial()+WorkIp->(EE9_PEDIDO+EE9_PREEMB)))
            If EXU->(DbSeek(xFilial()+EXV->EXV_NROAMO)) .And. EXU->EXU_STATUS <> STAM_DC .And. EXU->EXU_STATUS <> STAM_RJ
               aAdd(aItemVinc, WorkIp->({EE9_SEQEMB, "AMOSTRA", EXU->EXU_NROAMO}))
            EndIf
         EndIf
         RestOrd(aOrd)
      EndIf

   EndIf

    //THTS - 11/11/2017 - Grava a NF na WorkNF após marcar ou apaga após desmarcar
    If !Empty(WorkIP->EE9_NF)
        If lOpc
            If !WorkNF->(dbSeek(EEM_NF +AvKey(WorkIP->EE9_NF,"EEM_NRNF") + AvKey(WorkIP->EE9_SERIE,"EEM_SERIE")))
                AE100WrkNF(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIP->EE9_NF,WorkIP->EE9_SERIE,WorkIp->(Ap101FilNf()))
            EndIf
        Else
            If WorkNF->(dbSeek(EEM_NF +AvKey(WorkIP->EE9_NF,"EEM_NRNF") + AvKey(WorkIP->EE9_SERIE,"EEM_SERIE")))
                RecLock("WorkNF",.F.)
                WorkNF->(dbDelete())
                WorkNF->(MsUnlock())
            EndIf
        EndIf
    EndIf

Return Nil

/*
Funcao      : Ae108Marcac()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Montar os dados do OIC a serem carregados automaticamente no campo EEC_MARCAC.
Autor       : Julio de Paula Paz
Data/Hora   : 28/12/2005 10:00
Revisao     :
Obs.        :
*/
*-------------------------*
Function Ae108Marcac()
Local cDescSaca := ""
Local cComplem := "", cNomEmp :=""
Private cRet := "" // By JPP - 14/01/2010

Begin Sequence
   If Type("cEmpOIC") <> "U" .And. ValType(cEmpOIC) == "C"
      cNomEmp := cEmpOIC
   EndIf
   If Type("cComplOic") <> "U" .And. ValType(cComplOic) == "C"
      cComplem := cComplOic
   EndIf
   WKEXZ->(DbGoTop())
   If ! Empty(cNomEmp)
      cRet := cNomEmp + ENTER
   EndIf
   Do While WKEXZ->(! Eof())
      If WKEXZ->EXZ_QTDE == 1
         cDescSaca := " Saca"  // By JPP - 14/01/2010
      Else
         cDescSaca := " Sacas" // By JPP - 14/01/2010
      EndIf
      If ! Empty(cComplem)
         cRet += cComplem+"/"
      EndIf
      cRet += Transform(AllTrim(WKEXZ->EXZ_OIC), AvSx3("EXZ_OIC",AV_PICTURE));
              + " = " +Transform(WKEXZ->EXZ_QTDE,AvSx3("EXZ_QTDE",AV_PICTURE)) + cDescSaca + ENTER
      WKEXZ->(DbSkip())
   EndDo
   If EasyEntryPoint("EECAE108")
      cRET := ExecBlock("EECAE108", .F., .F., {"GRV_MARCAC"})
   EndIf
End Sequence
Return cRet

/*
Funcao      : Ae108VldSafra(cSafra)
Parametros  : cSafra = Safra digitada.
Retorno     : .T./.F.
Objetivos   : Validar a digitação da safra
Autor       : Julio de Paula Paz
Data/Hora   : 29/12/2005 10:00
Revisao     :
Obs.        :
*/
Function Ae108VldSafra(cSafra)
Local lRet := .T.
Begin Sequence
   If Empty(cSafra)
      lRet := .F.
      MsgInfo(STR0110,STR0021) // "A digitação da safra é obrigatorio!"  ### "Atenção"
   Else
      If (Val(Right(cSafra,2)) - 1) <> (Val(Left(cSafra,2))) .Or. (Val(Right(cSafra,2)) == 0 .And. Val(Left(cSafra,2)) <> 99)
         MsgInfo(STR0109, STR0021)//"A safra deve ser informada no formato: 'Ano Anterior/Ano Atual'"###"Atenção"
         lRet := .F.
      EndIf
   EndIf
End Sequence
Return lRet

/*
Funcao      : Ae108SeekLastOIC()
Parametros  : cSafra
Retorno     : cOic
Objetivos   : Retornar o número do ultimo OIC cadastrado para a safra desejada
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 09/02/06
Revisao     :
Obs.        :
*/
Function Ae108SeekLastOIC(cSafra)
Local cOic := "0", aOrd, aFilter
Local cSeek:= ""

Private CPENumOic := ""

Begin Sequence
      If ValType(cSafra) <> "C"
         Break
      EndIf
      aFilter := EECSaveFilter("EXZ")
      aOrd := SaveOrd({"EXZ", "WKEXZ"})
      EXZ->(DbClearFilter())
      EXZ->(DbSetOrder(3))
      EXZ->(DbGoTop())

      If lGrvPrefix
         cSeek:= EXZ->(xFilial("EXZ")) + cSafra + cPrefix
      Else
         cSeek:= EXZ->(xFilial("EXZ")) + cSafra
      EndIf

      //If EXZ->(AvSeekLast(xFilial("EXZ")+cSafra+cPrefix)) nopado por WFS em 25/03/2010
      If EXZ->(AvSeekLast(cSeek))
         While EXZ->(!Bof()) .And. EXZ->EXZ_PREEMB == M->EEC_PREEMB .And. EXZ->EXZ_SAFRA == cSafra .And. !WKEXZ->(DbSeek(EXZ->(EXZ_OIC+EXZ_SAFRA)))
            EXZ->(DbSkip(-1))
         EndDo
         If EXZ->EXZ_SAFRA == cSafra // .And. WKEXZ->(DbSeek(EXZ->(EXZ_OIC+EXZ_SAFRA)))   // By JPP - 03/03/2006 - 13:57 - O OIC posicionado pode não estar na Work.
            cOic := Right(AllTrim(EXZ->EXZ_OIC),4)
         EndIf
      EndIf
      WKEXZ->(DbGoTop())
      While WKEXZ->(!Eof())
         //If WKEXZ->EXZ_SAFRA == cSafra .And. Val(WKEXZ->EXZ_OIC) > Val(cOic) nopado por WFS
         If WKEXZ->EXZ_SAFRA == cSafra .And. Val(Right(AllTrim(WKEXZ->EXZ_OIC),4)) > Val(cOic)
            cOic := Right(AllTrim(WKEXZ->EXZ_OIC),4)//WKEXZ->EXZ_OIC
         EndIf
         WKEXZ->(DbSkip())
      EndDo
      RestOrd(aOrd,.T.)
      EECRestFilter(aFilter)
      cOic := StrZero(Val(cOic)+1,4)
End Sequence

if EasyEntryPoint("EECAE108")
   ExecBlock("EECAE108",.F.,.F.,{"NUM_OIC",cSafra,cOic})
   if !empty(CPENumOic)
      cOic := StrZero(Val(CPENumOic),4)
   endif
endif

Return cOic


/*
Funcao     : MenuDef()
Parametros : cOrigem
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 27/01/07 - 15:13
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina := {}
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   #IFDEF TOP
      aAdd(aRotina , { STR0058, "Ae108ArmBusca", 0, 1})//Pesquisar
   #ELSE
      aAdd(aRotina , { STR0058, "AxPesqui" , 0 , 1})//Pesquisar
   #ENDIF

      Do Case

         Case cOrigem $ "AE108ARMBAIXA" //Armazém
              aAdd(aRotina, { STR0059, "Ae108ArmMan"  , 0, 2}) //Visualizar
              aAdd(aRotina, { STR0060, "Ae108ArmMan"  , 0, 4})  //Baixar

              If EasyEntryPoint("EAE108AMNU")
	             aRotAdic := ExecBlock("EAE108AMNU",.f.,.f.)
	             If ValType(aRotAdic) == "A"
		            aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	             EndIf
              EndIf


         Case cOrigem $ "AE108ARMESTORNO" //Estorno de Baixas
              aAdd(aRotina, {STR0059, "Ae108ArmMan"  , 0, 2})//Visualizar
              aAdd(aRotina, {STR0062, "Ae108Armazens", 0, 5}) //Estornar

              If EasyEntryPoint("EAE108AEMNU")
	             aRotAdic := ExecBlock("EAE108AEMNU",.f.,.f.)
	             If ValType(aRotAdic) == "A"
		            aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	             EndIf
              EndIf


         Case cOrigem $ "AE108ARMTRANSF" //Transferência
              aAdd(aRotina, {STR0059, "Ae108ArmMan"  , 0, 2})//Visualizar
              aAdd(aRotina, {STR0064, "Ae108ArmMan"  , 0, 4}) //Transferir

              If EasyEntryPoint("EAE108ATMNU")
	             aRotAdic := ExecBlock("EAE108ATMNU",.f.,.f.)
	             If ValType(aRotAdic) == "A"
		            aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	             EndIf
              EndIf

   End Case

End Sequence

Return aRotina

/*
Funcao     : Ae108Fiergs()
Objetivos  : Permitir o anexo da Fatura/Invoice no embarque para ser utilizado na integração da FIERGS
Autor      : Laercio G S Junior - LGS
Data/Hora  : 27/08/2015 - 13:05
*/
*----------------------------------------*
Function Ae108Fiergs()
*----------------------------------------*
Local oDlg, oBrowse, aPos
Local aCampos := {}, aSemSx3 := {}
Local nOpcao	:= 0
Local bOk		:= {|| nOpcao := 1 , oDlg:End() }
Local bCancel	:= {|| nOpcao := 0 , oDlg:End() }
Private cMrcProc:=GetMark()
Private oMkFiergs

	AADD(aSemSX3,{"WKRECNO"   ,"N",15,0})
	cFileSY0:=E_CriaTrab("SY0",aSemSX3,"WKFIERGS")
	IndRegua("WKFIERGS",cFileSY0+TEOrdBagExt(),"Y0_PROCESS")

	AADD(aCampos,{"Y0_DOC"     ,,AVSX3("Y0_DOC"    ,5), AVSX3("Y0_DOC"    ,6)})
	AADD(aCampos,{"Y0_ARQPDF"  ,,AVSX3("Y0_ARQPDF" ,5), AVSX3("Y0_ARQPDF" ,6)})
	AADD(aCampos,{"Y0_USUARIO" ,,AVSX3("Y0_USUARIO",5), AVSX3("Y0_USUARIO",6)})
	AADD(aCampos,{"Y0_DATA"    ,,AVSX3("Y0_DATA"   ,5), AVSX3("Y0_DATA"   ,6)})
	AADD(aCampos,{"Y0_HORA"    ,,AVSX3("Y0_HORA"   ,5), AVSX3("Y0_HORA"   ,6)})

	Ae108Y0Work() //Carrega Work de Anexo

	DEFINE MSDIALOG oDlg TITLE STR0144 FROM 0,0 TO 280,600 OF oMainWnd PIXEL //"Histórico de Documentos"

		aPos := PosDlg(oDlg)

		oPanel:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
		oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

		@ 005, 010 BUTTON STR0013 Size 29, 11 action( If(WKFIERGS->(EasyReccount("WKFIERGS")) == 0, EECHistDoc(,,,"FIERGS"), MsgInfo(STR0142 + ENTER + STR0143) ) ) OF oPanel PIXEL
		@ 005, 050 BUTTON STR0012 Size 29, 11 action( If(WKFIERGS->(EasyReccount("WKFIERGS")) >  0, EECHistDoc("SY0",WKFIERGS->WKRECNO,2,"FIERGS"),) ) OF oPanel PIXEL
		@ 005, 090 BUTTON STR0015 Size 29, 11 action( If(WKFIERGS->(EasyReccount("WKFIERGS")) >  0, EECHistDoc("SY0",WKFIERGS->WKRECNO,4,"FIERGS"),) ) OF oPanel PIXEL

		WKFIERGS->(DBGOTOP())
		oMkFiergs:= MsSelect():New("WKFIERGS","","",aCampos,.F.,@cMrcProc,{aPos[1]+5,aPos[2],aPos[3]-18,aPos[4]},,,oPanel)
		oMkFiergs:oBrowse:Align:= CONTROL_ALIGN_BOTTOM
		oMkFiergs:oBrowse:Refresh()
		oDlg:lMaximized := .F.
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) CENTERED

	WKFIERGS->((E_EraseArq(cFileSY0)))

Return Nil

/*
Funcao     : Ae108Y0Work()
Objetivos  : Carrega a work "WKFIERGS" com o registro da SY0
Autor      : Laercio G S Junior - LGS
Data/Hora  : 27/08/2015 - 13:05
*/
Function Ae108Y0Work(lRefresh)
Default lRefresh := .F.

	WKFIERGS->(AvZap())
	SY0->( DbSetOrder(6) )
	SY0->(DbSeek(xFilial("SY0") + M->EEC_PREEMB + AvKey("FIERGS","Y0_ROTINA") ))
	Do While SY0->(!Eof()) .And. SY0->Y0_PROCESS == M->EEC_PREEMB .And. SY0->Y0_ROTINA == AvKey("FIERGS","Y0_ROTINA")
	   WKFIERGS->(DBAPPEND())
	   WKFIERGS->Y0_PROCESS	:= SY0->Y0_PROCESS
	   WKFIERGS->Y0_DOC		:= SY0->Y0_DOC
	   WKFIERGS->Y0_DATA	:= SY0->Y0_DATA
	   WKFIERGS->Y0_HORA	:= SY0->Y0_HORA
	   WKFIERGS->Y0_USUARIO	:= SY0->Y0_USUARIO
	   WKFIERGS->Y0_ARQPDF	:= SY0->Y0_ARQPDF
	   WKFIERGS->WKRECNO	:= SY0->(RECNO())
	   SY0->(DbSkip())
	EndDo

	If lRefresh
	   WKFIERGS->(DBGOTOP())
	   oMkFiergs:oBrowse:Refresh()
	EndIf

Return Nil

/*
Funcao     : Ae108EY2()
Objetivos  : Retorna o pedido e sequencia para posicionar corretamente a WrkSldInv.
Autor      : Laercio G S Junior - LGS
Data/Hora  : 13/01/2016 - 13:05
*/
*----------------------------------------*
Static Function Ae108EY2(cSeqEmb)
*----------------------------------------*
Local aOrd := SaveOrd({"WorkIp"}),;
      cRet := ""

	WorkIP->(dbSetOrder(2))
	If WorkIp->(dbSeek(cSeqEmb))
	   cRet := WorkIp->(EE9_PEDIDO+EE9_SEQUEN)
	EndIf

RestOrd(aOrd,.T.)
Return cRet

/*
Funcao     : Ae108SumCpo()
Objetivos  : Retorna o total do campo passado como parametro com base na WorkIp,
             para realizar o rateio corretamente na WorkSldInv
Autor      : Laercio G S Junior - LGS
Data/Hora  : 13/01/2016 - 13:05
*/
*----------------------------------------*
Static Function Ae108SumCpo(cTabela)
*----------------------------------------*
Local aOrd := SaveOrd({"WorkDetInv","WorkIp"})
Local nFrete   := 0
Local nSeguro  := 0
Local nOutras  := 0
Local nDesconto:= 0
Local nSldIni  := 0

Default cTabela := "WorkDetInv"

Begin Sequence

	WorkIP->(dbSetOrder(1))
	WorkIP->(DbSeek(&(cTabela+"->(EXR_PEDIDO+EXR_SEQUEN)")))
	Do While WorkIp->(!Eof()) .And. WorkIp->(EE9_PEDIDO+EE9_SEQUEN) ==  &(cTabela+"->(EXR_PEDIDO+EXR_SEQUEN)")
      nFrete   += WorkIp->EE9_VLFRET
      nSeguro  += WorkIp->EE9_VLSEGU
      nOutras  += WorkIp->EE9_VLOUTR
      nDesconto+= WorkIp->EE9_VLDESC
      nSldIni  += WorkIp->EE9_SLDINI

	   WorkIp->(DbSkip())
	EndDo

End Sequence

RestOrd(aOrd,.T.)
Return {nFrete,nSeguro,nOutras,nDesconto,nSldIni}

/*
Funcao     : getItemInv()
Objetivos  : Retorna mensagem com os itens e suas invoices,
             para que o usuario devincule os itens da invoice antes de remover o pedido do embarque
Autor      : Wandersn Henrique Reliquias de Souza - WHRS	
Data/Hora  : 07/07/2017
*/
Static Function getItemInv()
//WHRS 06/07/2017 TE-5995 519182 - MTRADE-1013 / 1230-Duplicação Itens da Invoice
local cMsgLogInv := ''

local nRecnoWkIp := WorkIp->(Recno())
      WorkIp->(DbGoTop())
      
      WorkDetInv->(DbSetOrder(2))

        Do While WorkIP->(!Eof())
	    	 If Empty(WorkIP->WP_FLAG)
                if WorkDetInv->(dbSeek(WorkIp->(EE9_PEDIDO+EE9_SEQUEN))) 
                    if empty(cMsgLogInv)
                       cMsgLogInv := STR0145 + ENTER
                    endIf
                    cMsgLogInv += STR0146 +" "+ alltrim(WorkIP->EE9_COD_I) +" - "+ STR0147 +" "+ alltrim(WorkIp->EE9_PEDIDO) +" - "+ STR0148 +" "+ alltrim(WorkIp->EE9_SEQUEN) +" - "+  STR0149 +" "+ alltrim(WorkDetInv->EXR_NRINVO) +" "+ ENTER
                ENDIF
	     	 EndIf
             WorkIP->(DbSkip())
	    EndDo
		
        WorkIp->(DbGoTo(nRecnoWkIp))
return cMsgLogInv


Static Function CalcPrcTot(cTabela)
Local nDecTot
Local nRateio
Local nDespesas
Local nPreco
Local nQtd
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)
Local aOrd := SaveOrd({"WorkIp"})
Local aVlCampos := {}

WorkIP->(dbSetOrder(1))
if WorkIP->( dbseek( &(cTabela+"->(EXR_PEDIDO+EXR_SEQUEN)") ) )
   aVlCampos := Ae108SumCpo(cTabela)
   
   nDecTot := EasyGParam("MV_AVG0110",, 2)
   nRateio := &(cTabela+"->(EXR_SLDINI)") / aVlCampos[SLDINI]

   &(cTabela+"->(EXR_VLFRET)") := aVlCampos[FRETE] * nRateio
   &(cTabela+"->(EXR_VLSEGU)") := aVlCampos[SEGURO] * nRateio
   &(cTabela+"->(EXR_VLOUTR)") := aVlCampos[OUTDESP] * nRateio
   &(cTabela+"->(EXR_VLDESC)") := aVlCampos[DESCONTO] * nRateio
   
   // VERIFICA SE TEM O PREÇO ABERTO
   If M->EEC_PRECOA $ cSim
         nDespesas := &(cTabela+"->(EXR_VLFRET + EXR_VLSEGU + EXR_VLOUTR)" /*- EXR_VLDESC*/ )
   Else
         nDespesas := &(cTabela+"->(EXR_VLFRET + EXR_VLSEGU + EXR_VLOUTR)" /*+ EXR_VLDESC*/ )
   EndIf
   nPreco := WorkIp->EE9_PRECO

   //Cálculo da quantidade quando se usa a conversão de unidade de medidas
   If lConvUnid
         nQtd := AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,&(cTabela+"->(EXR_SLDINI)"),.F.)
   Else
         nQtd := &(cTabela+"->(EXR_SLDINI)")
   EndIf

   If M->EEC_PRECOA $ cSim
         &(cTabela+"->(EXR_PRCTOT)") := Round((nPreco*nQtd)+nDespesas - &(cTabela+"->(EXR_VLDESC)"),nDecTot) //Total do item
         &(cTabela+"->(EXR_PRCINC)") := Round(nPreco*nQtd,nDecTot) //FOB
   Else
      If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
         &(cTabela+"->(EXR_PRCTOT)") := Round(nPreco*nQtd - &(cTabela+"->(EXR_VLDESC)"),nDecTot) //Total do item
         &(cTabela+"->(EXR_PRCINC)") := Round((nPreco*nQtd)-nDespesas ,nDecTot) //FOB
      Else
         &(cTabela+"->(EXR_PRCTOT)") := Round(nPreco*nQtd,nDecTot) //Total do item
         &(cTabela+"->(EXR_PRCINC)") := Round((nPreco*nQtd)-nDespesas + &(cTabela+"->(EXR_VLDESC)"),nDecTot) //FOB
      EndIf
   Endif
endif
RestOrd(aOrd,.T.)

Return
