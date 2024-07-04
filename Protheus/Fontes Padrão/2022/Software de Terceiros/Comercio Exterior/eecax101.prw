#INCLUDE "eecax101.ch"
#include "EEC.CH"

/*
Programa        : EECAX101.PRW.
Objetivo        : Funções de Off-Shore utilizadas nas rotinas de pedido de exportação e 
                  processos de embarque.
Autor           : Jeferson Barros Jr.
Data/Hora       : 11/04/2005 10:45.
Obs.            : 
*/

/*
Funcao      : Ax101IsEmbExt(cProc)
Parametros  : cProc => Nro do processo.
Retorno     : .t./.f.
Objetivos   : A função irá verificar se o processo de embarque está embarcado na filial de off-shore, em caso 
              positivo, a função irá exibir uma msg ao usuário alertando sobre as críticas realizadas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/04/2005 - 15:22.
Revisao     :
Obs.        :
*/
*---------------------------*
Function Ax101IsEmbExt(cProc)
*---------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EEC"})

Begin Sequence

   cProc := AvKey(AllTrim(Upper(cProc)),"EEC_PREEMB")

   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(cFilEx+cProc))
      If !Empty(EEC->EEC_DTEMBA)
         MsgInfo(STR0001+; //"Este processo está embarcado na filial de off-shore, com isso, o sistema não permitirá a "
                 STR0002+; //"inclusão/exclusão de itens, bem como a alteração das quantidades dos itens já cadastrados. "
                 STR0003,STR0004) //"Para realizar estas operações a data de embarque na filial de off-shore deverá ser apagada."###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Ax101VldQtde()
Parametros  : cOcorrencia = OC_PE - Pedido.
                            OC_EM - Embarque.
Retorno     : .t./.f.
Objetivos   : A função irá realizar validações nas quantidades dos produtos entre as filiais,
              Brasil e Off-Shore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/04/2005 - 10:48.
Revisao     :
Obs.        :
*/
*--------------------------------*
Function Ax101VldQtde(cOcorrencia)
*--------------------------------*
Local lRet:=.t.
Local aOrd:={}
Local nQtd := 0

Default cOcorrencia := OC_PE

Begin Sequence

   If cOcorrencia == OC_PE

      // ** Trata as condições básicas para os ambientes com a rotina de commodities habilitada.
      If lCommodity .And. !Empty(WorkIt->EE8_RECNO)

         aOrd:=SaveOrd({"EE8"})
         EE8->(DbGoTo(WorkIt->EE8_RECNO))

         If WorkIt->EE8_SLDINI < EE8->EE8_SLDINI
            nQtd := Abs(WorkIt->EE8_SLDINI - EE8->EE8_SLDINI)

            If EE8->(DbSeek(cFilEx+M->EE7_PEDIDO))
               Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFilEx .And.;
                                            EE8->EE8_PEDIDO == M->EE7_PEDIDO .And. nQtd > 0

                  If Empty(EE8->EE8_DTFIX)
                     If nQtd <= EE8->EE8_SLDINI
                        nQtd := 0
                     Else
                        nQtd -= EE8->EE8_SLDINI
                     EndIf
                  EndIf
                  EE8->(DbSkip())
               EndDo
            EndIf

            If nQtd > 0
               MsgStop(STR0005+; //"O sistema não poderá realizar a alteração na quantidade. Na filial de off-shore, "
                       STR0006,STR0004) //"não há quantidade disponível para o valor necessário."###"Atenção"
               lRet:=.f.
               Break
            EndIf
         EndIf
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Ax101SetQtde()
Parametros  : cOcorrencia = OC_PE - Pedido.
                            OC_EM - Embarque.
Retorno     : .t./.f.
Objetivos   : A função irá realizar acertos nas quantidades dos produtos entre as filiais,
              Brasil e Off-Shore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/04/2005 - 10:48.
Revisao     :
Obs.        :
*/
*--------------------------------*
Function Ax101SetQtde(cOcorrencia)
*--------------------------------*
Local aOrd:={}, aProcMultiOffShore:={}
Local cWk, cAlias, cCmpRecno, cSearchKey, cOldFilter, cSeqEmb
Local nValor := 0, j:=0, i:=0, nRecNo:=0
Local lRet := .t.
Local bOldFilter

Private aAtuProcs:={}

Default cOcorrencia := OC_PE

Begin Sequence

   // ** Validações iniciais para os tratamentos de validação de quantidades.
   If cOcorrencia == OC_PE
      DbSelectArea("EE7")
      aOrd := SaveOrd({"EE7"})
      EE7->(dbSetOrder(1))
      If !EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))
         lRet:=.f.
         Break
      EndIf
      RestOrd(aOrd,.t.)
   Else
      DbSelectArea("EEC")
      aOrd := SaveOrd({"EEC"})
      EEC->(dbSetOrder(1))
      If !EEC->(DbSeek(cFilEx+M->EEC_PREEMB))
         lRet:=.f.
         Break
      EndIf
      RestOrd(aOrd,.t.)      
   EndIf

   // ** Efetua os acertos somente a partir da filial brasil.
   If AvGetM0Fil() <> cFilBr
      lRet:=.f.
      Break
   EndIf

   If cOcorrencia == OC_PE
      DbSelectArea("EE8")
      cAlias     := "EE8"
      cWk        := "WorkIt"
      aOrd       := SaveOrd({"EE7","EE8","WorkIt"})
      cCmpRecNo  := "EE8_RECNO"
      cSearchKey := "cFilEx+WorkIt->EE8_PEDIDO+WorkIt->EE8_SEQUEN"
      EE8->(dbSetOrder(1))
   Else
//      DbSelectArea("EE8")
      DbSelectArea("EE9")
      cAlias     := "EE9"
      cWk        := "WorkIp"
      aOrd       := SaveOrd({"EEC","EE9","WorkIp"})
      cCmpRecNo  := "WP_RECNO"
      cSearchKey := "cFilEx+WorkIp->EE9_PREEMB+WorkIp->EE9_SEQEMB"
      EE9->(dbSetOrder(3))
                  
      cOldFilter := WorkIP->(dbFilter())
      bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")
      
      WorkIp->(DbClearFilter())
      WorkIp->(DbGoTop())
   EndIf

   (cWk)->(DbGoTop())
   Do While (cWk)->(!Eof())

      // ** Trata os itens desmarcados em fase de embarque.
      If cOcorrencia  == OC_EM .And. Empty((cWk)->&("WP_FLAG")) .And. !Empty((cWk)->&(cCmpRecNo))
         If EE9->(DbSeek(cFilEx+WorkIp->EE9_PREEMB+WorkIp->EE9_SEQEMB))
            If EE9->(RecLock("EE9",.f.))
               Ax101AddProc(EE9->EE9_PREEMB)

               For i:=1 To Len(aMemoItem)
                  If EE9->(FieldPos(aMemoItem[i][1])) > 0
                     MSMM(EE9->&(aMemoItem[i][1]),,,,EXCMEMO)
                  EndIf
               Next

               // Acerta o saldo do item no processo.
               If EE8->(DbSeek(cFilEx+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
                  If EE8->(RecLock("EE8",.f.))
                     EE8->EE8_SLDATU += EE9->EE9_SLDINI
                     EE8->(MsUnLock())
                  EndIf
               EndIf

               EE9->(DbDelete())
               EE9->(MsUnLock())

               
               /* Trata os ambientes com multi Off-Shore. Neste caso o sistema irá considerar 
                  todos os níveis de off-shore encontrados para o processo de embarque. */

               If lMultiOffShore
                  aProcMultiOffShore := Ax101LoadOffShore(EE9->EE9_PREEMB) // Carrega o nro de todos os processos de multi Off-shore.

                  If Len(aProcMultiOffShore) > 0
                     For j:=1 To Len(aProcMultiOffShore)
                        If EE9->(DbSeek(cFilEx+AvKey(aProcMultiOffShore[j],"EE9_PREEMB")+WorkIp->EE9_SEQEMB))
                           If EE9->(RecLock("EE9",.f.))
                              Ax101AddProc(EE9->EE9_PREEMB)
                              For i:=1 To Len(aMemoItem)
                                 If EE9->(FieldPos(aMemoItem[i][1])) > 0
                                    MSMM(EE9->&(aMemoItem[i][1]),,,,EXCMEMO)
                                 EndIf
                              Next

                              // Acerta o saldo do item no processo.          
                              EE9->(DbDelete())
                              EE9->(MsUnLock())
                           EndIf
                        EndIf
                     Next
                  EndIf
               EndIf
            EndIf
            (cWk)->(DbSkip())
            Loop
         EndIf
      EndIf

      If !Empty((cWk)->&(cCmpRecNo))

         /* Trata os casos em que o item já existia  priviamente, ou  seja, neste  ponto o
            sistema irá  tratar as  alterações na  quantidade dos item, e irá realizar  os
            tratamentos necessários para relplicação da quantidade na filial do exterior e
            no caso da fase de embarque, o sistema irá  atualizar  tb,  todos os níveis de
            off-shore. */

         (cAlias)->(DbSeek(&(cSearchKey)))

         nValor := (cWk)->&(cAlias+"_SLDINI") - (cAlias)->&(cAlias+"_SLDINI")

          // Para os casos em que não houve alteração na quantidade, o sistema não realiza os controles de quantidade.
         If nValor = 0
            (cWk)->(DbSkip())
            Loop
         EndIf

         If cOcorrencia == OC_PE
            If !lCommodity

               /* Realiza o acerto de quantidades para os itens do pedido em ambiente que não possua habilitado
                  os tratamentos de commodities. */

               If EE8->(RecLock("EE8",.f.))
                  EE8->EE8_SLDINI := WorkIt->EE8_SLDINI
                  EE8->EE8_SLDATU += nValor   

                  Ax101SetDadosItem(OC_PE) // Acerto das informações da linha.
                  EE8->(MsUnLock())

                  Ax101AddProc(EE8->EE8_PEDIDO)
               EndIf
            Else
               If Empty(EE8->EE8_DTFIX)
                  If EE8->(RecLock("EE8",.f.))
                     EE8->EE8_SLDINI := WorkIt->EE8_SLDINI
                     EE8->EE8_SLDATU += nValor

                     Ax101SetDadosItem(OC_PE) // Acerto das informações da linha.
                     EE8->(MsUnLock())

                     Ax101AddProc(EE8->EE8_PEDIDO)
                  EndIf
               Else
                  If EE8->(DbSeek(cFilEx+WorkIt->EE8_PEDIDO))
                     Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFilEx .And.;
                                                  EE8->EE8_PEDIDO == WorkIt->EE8_PEDIDO .And. nValor <> 0

                        // Os itens com data de fixação, são desconsiderados.
                        If !Empty(EE8->EE8_DTFIX)
                           EE8->(DbSkip())
                           Loop
                        EndIf

                        If Valor > 0
                           If EE8->(RecLock("EE8",.f.))
                              EE8->EE8_SLDINI += nValor
                              EE8->EE8_SLDATU += nValor

                              Ax101SetDadosItem(OC_PE) // Acerto das informações da linha.
                              EE8->(MsUnLock())

                              Ax101AddProc(EE8->EE8_PEDIDO)
                              nValor := 0
                           EndIf
                        Else
                           If Abs(nValor) < EE8->EE8_SLDATU
                              If EE8->(RecLock("EE8",.f.))
                                 EE8->EE8_SLDINI += nValor
                                 EE8->EE8_SLDATU += nValor

                                 Ax101SetDadosItem(OC_PE) // Acerto das informações da linha.
                                 EE8->(MsUnLock())

                                 Ax101AddProc(EE8->EE8_PEDIDO)
                                 nValor := 0
                              EndIf

                           ElseIf Abs(nValor) >= EE8->EE8_SLDATU .And. EE8->EE8_SLDATU > 0
                              If EE8->(RecLock("EE8",.f.))
                                 nValor += EE8->EE8_SLDATU

                                 EE8->EE8_SLDINI -= EE8->EE8_SLDATU
                                 EE8->EE8_SLDATU := 0

                                 If EE8->EE8_SLDINI == 0 .And. EE8->EE8_SLDATU == 0
                                    For i:=1 To Len(aMemoItem)
                                       If EE8->(FieldPos(aMemoItem[i][1])) > 0
                                          MSMM(EE8->&(aMemoItem[i][1]),,,,EXCMEMO)
                                       EndIf
                                    Next
                                    EE8->(DbDelete())
                                 Else
                                    Ax101SetDadosItem(OC_PE) // Acerto das informações da linha.
                                 EndIf
                                 EE8->(MsUnLock())

                                 Ax101AddProc(EE8->EE8_PEDIDO)
                              EndIf
                           EndIf
                        EndIf

                        EE8->(DbSkip())
                     EndDo
                  EndIf
               EndIf
            EndIf
            
            /*WFS 13/01/09 ---
              Se o saldo atual (EE8_SLDATU) ficou negativo é porque a nova quantidade do pedido é menor que
              a do embarque. Neste caso, o saldo passará a ser 0 e a quantidade do embarque será reajustada
              para a quantidade do pedido (EE8_SLDINI)*/
            If EE8->EE8_SLDATU < 0
               EE8->(RecLock("EE8", .F.))
               EE8->EE8_SLDATU:= 0
               EE8->(MsUnlock())
            EndIf
            //---

         ElseIf EE9->(!Eof()) // Fase de embarque.

            If EE9->(RecLock("EE9",.f.))
               EE9->EE9_SLDINI := WorkIp->EE9_SLDINI
               Ax101SetDadosItem(OC_EM)  // Acerto das informações da linha
               EE9->(MsUnLock())

               Ax101AddProc(EE9->EE9_PREEMB)

               If EE8->(DbSeek(cFilEx+WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN))
                  If EE8->(RecLock("EE8",.f.))
                     EE8->EE8_SLDATU := WorkIp->WP_SLDATU //EE8->EE8_SLDATU -= nValor
                     EE8->(MsUnLock())
                  EndIf
               EndIf
            EndIf

            /* Trata os ambientes com multi Off-Shore. Neste caso o sistema irá considerar 
               todos os níveis de off-shore encontrados para o processo de embarque. */

            If lMultiOffShore
               aProcMultiOffShore := Ax101LoadOffShore(EE9->EE9_PREEMB) // Carrega o nro de todos os processos de multi Off-shore.

               If Len(aProcMultiOffShore) > 0
                  For j:=1 To Len(aProcMultiOffShore)
                     If EE9->(DbSeek(cFilEx+AvKey(aProcMultiOffShore[j],"EE9_PREEMB")+WorkIp->EE9_SEQEMB))
                        If EE9->(RecLock("EE9",.f.))
                           EE9->EE9_SLDINI := WorkIp->EE9_SLDINI
                           Ax101SetDadosItem(OC_EM) // Acerto das informações da linha.
                           EE9->(MsUnLock())
                           Ax101AddProc(EE9->EE9_PREEMB)
                        EndIf
                     EndIf
                  Next
               EndIf
            EndIf
         EndIf
      
      Else
         /* Trata as situações de inclusão de item. Neste caso o sistema irá atualizar
            automaticamente a filial do exterior incluindo a nova sequência. */

         If cOcorrencia == OC_EM
            If Empty((cWk)->&("WP_FLAG")) //ASK 03/09/2007 - Grava apenas os itens marcados.
               (cWk)->(DbSkip())
               Loop         
            EndIf
         EndIf
         
         If (cAlias)->(RecLock(cAlias,.t.))
            AVReplace(cWk,cAlias)
            (cAlias)->&(cAlias+"_FILIAL") := cFilEx

            If cOcorrencia == OC_PE
               EE8->EE8_PEDIDO := M->EE7_PEDIDO
               EE8->EE8_PRENEG := 0
            Else
               EE9->EE9_PREEMB := M->EEC_PREEMB
            EndIf

            For i:=1 To Len(aMemoItem)
               If (cAlias)->(FieldPos(aMemoItem[i][1])) > 0
                  MSMM(,TAMSX3(aMemoItem[i][2])[1],,(cWk)->&(aMemoItem[i][2]),INCMEMO,,,cAlias,aMemoItem[i][1])
               EndIf
            Next

            If cOcorrencia == OC_EM
               // Acerta o saldo do item no processo.
               If EE8->(DbSeek(cFilEx+WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN))
                  If EE8->(RecLock("EE8",.f.))
                     EE8->EE8_SLDATU := WorkIp->WP_SLDATU //EE8->EE8_SLDATU -= WorkIp->EE9_SLDINI
                     EE8->(MsUnLock())
                  EndIf
               EndIf
            EndIf

            (cAlias)->(MsUnlock())
         
         
            If cOcorrencia == OC_EM

               /* Trata os ambientes com multi Off-Shore. Neste caso o sistema irá considerar 
                  todos os níveis de off-shore encontrados para o processo de embarque. */

               If lMultiOffShore
                  aProcMultiOffShore := Ax101LoadOffShore(EE9->EE9_PREEMB) // Carrega o nro de todos os processos de multi Off-shore.

                  If Len(aProcMultiOffShore) > 0
                     For j:=1 To Len(aProcMultiOffShore)
                        If EE9->(RecLock("EE9",.t.))
                           AVReplace(cWk,cAlias)
                           EE9->EE9_FILIAL := cFilEx
                           EE9->EE9_PREEMB := aProcMultiOffShore[j]
                           For i:=1 To Len(aMemoItem)
                              If EE9->(FieldPos(aMemoItem[i][1])) > 0
                                 MSMM(,TAMSX3(aMemoItem[i][2])[1],,(cWk)->&(aMemoItem[i][2]),INCMEMO,,,cAlias,aMemoItem[i][1])
                              EndIf
                           Next
                           EE9->(MsUnLock())
                        EndIf
                     Next
                  EndIf
               EndIf
            EndIf
         EndIf
      EndIf
      
      (cWk)->(DbSkip())
   EndDo

   If cOcorrencia == OC_PE
      // ** Considera os itens deletados, os mesmos serão automaticamente deletados da filial de off-shore.
      For j:=1 To Len(aDeletados)
         EE8->(DbGoTo(aDeletados[j]))
         If EE8->(DbSeek(cFilEx+EE8->EE8_PEDIDO+EE8->EE8_SEQUEN))
            If EE8->(RecLock("EE8",.f.))
               Ax101AddProc(EE8->EE8_PEDIDO)
               For i:=1 To Len(aMemoItem)
                  If EE8->(FieldPos(aMemoItem[i][1])) > 0
                     MSMM(EE8->&(aMemoItem[i][1]),,,,EXCMEMO)
                  EndIf
               Next
               EE8->(DbDelete())
               EE8->(MsUnLock())
            EndIf
        EndIf
      Next
   EndIf

   /* Neste ponto o sistema irá automaticamente atualizar/recalcular os totais para os processos,
      que foram atualizados automaticamente pela rotina de acerto de quantidades. */

   For j:= 1 To Len(aAtuProcs)
      Ap101AtuFil(cOcorrencia,.t.,cFilEx,aAtuProcs[j])
   Next

End Sequence

If !Empty(cOldFilter)
    WorkIP->(DbSetFilter(bOldFilter,cOldFilter))
    WorkIP->(dbGoTop())
Endif

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Ax101LoadOffShore()
Parametros  : cProc - Processo de Embarque.
Retorno     : aEmbarques - Array com o nome de todas os embarques na filial de off-shore.
Objetivos   : Carregar o processo de off-shore, e se existir os vários níveis de off-shore.
Autor       : Jeferson Barros Jr. 
Data/Hora   : 31/03/05 - 14:17.
Obs.        :
*/
*--------------------------------------*
Static Function Ax101LoadOffShore(cProc)
*--------------------------------------*
Local aRet := {}, aOrd:=SaveOrd("EEC")
Local cKey

Begin Sequence

   If !lMultiOffShore .Or. Empty(cProc)
      Break
   EndIf

   cProc := AvKey(AllTrim(Upper(cProc)),"EEC_PREEMB")

   EEC->(DbSetOrder(14))
   cKey := cFilEx+cProc

   Do While EEC->(DbSeek(cKey))
      Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL+EEC->EEC_PEDREF == cKey
         If !Empty(EEC->EEC_NIOFFS)
            aAdd(aRet,EEC->EEC_PREEMB)
            Exit
         EndIf
         EEC->(DbSkip())
      EndDo
      cKey := cFilEx+EEC->EEC_PREEMB
   EndDo

End Sequence

RestOrd(aOrd,.t.)

Return aRet

/*
Funcao      : Ax101SetDadosItem().
Parametros  : cOcorrencia - Pedido/Embarque.
Retorno     : .t./.f.
Objetivos   : Recalcular os dados referentes as embalagens e pesos da linha do pedido ou do embarque.
Autor       : Jeferson Barros Jr. 
Data/Hora   : 12/04/05 - 10:41.
Obs.        : Considera que o registro esteja travado.
*/
*--------------------------------------------*
Static Function Ax101SetDadosItem(cOcorrencia)
*--------------------------------------------*
Local lRet:=.t.

Default cOcorrencia := OC_PE

Begin Sequence

   cAlias := If(cOcorrencia==OC_PE,"EE8","EE9")
   
   If ((cAlias)->&(cAlias+"_SLDINI") % (cAlias)->&(cAlias+"_QE")) != 0
      (cAlias)->&(cAlias+"_QTDEM1") := Int((cAlias)->&(cAlias+"_SLDINI")/(cAlias)->&(cAlias+"_QE"))+1
   Else
      (cAlias)->&(cAlias+"_QTDEM1") := Int((cAlias)->&(cAlias+"_SLDINI")/(cAlias)->&(cAlias+"_QE"))
   Endif

   // ** Recalculo dos pesos bruto e liquido.
   Ap101CalcPsBr(cOcorrencia)                      

End Sequence

Return lRet 

/*
Funcao      : Ax101AddProc().
Parametros  : cProc
Retorno     : .t./.f.
Objetivos   : Set do array de controle de processos a serem atualizados após alterações na quantidade
              dos itens.
Autor       : Jeferson Barros Jr. 
Data/Hora   : 12/04/05 - 10:58.
Obs.        : 
*/
*---------------------------------*
Static Function Ax101AddProc(cProc)
*---------------------------------*
Local lRet := .t.

Begin Sequence

   If Empty(cProc)
      lRet := .f.
      Break
   EndIf
   
   If aScan(aAtuProcs,cProc) == 0
      aAdd(aAtuProcs,cProc)
   EndIf

End Sequence  

Return lRet
*-------------------------------------------------------------------------------------------------------------------*
*                                     Fim do programa EECAX101                                                      *
*-------------------------------------------------------------------------------------------------------------------*
