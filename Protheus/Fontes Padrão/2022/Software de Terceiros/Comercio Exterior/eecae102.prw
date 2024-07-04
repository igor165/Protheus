#INCLUDE "EECAE102.ch"
#INCLUDE "EEC.CH"
#Include "TOPCONN.CH"


/*
Programa        : EECAE102.PRW
Objetivo        : Apresentar processos a embarcar
Autor           : Heder M Oliveira
Data/Hora       : 28/12/98 10:47
Obs.            :
Revisao         : Osman Medeiros Jr.
Data/Hora       : 04/06/01 16:16
Revisao         : Jeferson Barros Jr.
Data/Hora       : 24/07/01 14:31
Revisao.:-Luciano Campos de Santana - 27/03/2003
          Quando for gravar os campos ee9_prctot e ee9_prcinc, gravar com
          arredondamento p/ duas casas decimais
Revisao.: Luciano Campos de Santana - 31/10/2001 - 10:00
          -So mostra a mensagem AVG0000082 quando o campo intrumento de
           negociacao for alterado
          -So mostra a mensagem AVG0000079 quandos os campos ETD, Transit Time
           e ETA Destino forem preenchidos
*/

#xTranslate SumTotal() => Eval(bTotal,"SOMA")
#xTranslate SubTotal() => Eval(bTotal,"SUBTRAI")

/*
cWORK2ALIAS:="WorkIP"   ITENS DOS PEDIDOS NO EMBARQUE
cPITNomTMP := deve conter o nome do arquivo temporario do alias
WorkEm     := identificador de alias de Embalagens

    novos identificadores devem ter em sua a nomenclatura a sigla PIT para evitar
    reduncias com sistema.

*/
*----------------------
FUNCTION EECAE102()
*----------------------
Local bAddWork, lRet:=.T., aOrd
Local aOrdIp
//MFR 07/11/2019 OSSME-3963
Private lVar := .F.
// *** Trata Work de Agentes ...
bAddWork  := {|| WorkAg->(RecLock("WorkAg", .T.)),AP100AGGrava(.T.,OC_EM), WorkAg->(MsUnlock())}
EEB->(dbSetOrder(1))
IF ! Inclui
   EEB->(dbSeek(xFilial("EEB")+EEC->EEC_PREEMB+OC_EM))
   EEB->(dbEval(bAddWork,,{||  !EEB->(EOF()) .AND. EEB->EEB_FILIAL == xFilial("EEB") .And. EEB->EEB_PEDIDO == EEC->EEC_PREEMB .AND. EEB->EEB_OCORRE==OC_EM}))
Endif

lITGRAVA:=AE100ITGRAVA(.T.)

IF ( !lITGRAVA )
   lRET:=.F.
   Break
Endif

//** Trata Work de Despesas ...
bAddWork := {|| WorkDe->(RecLock("WorkDe", .T.)), AP100DSGrava(.T.,OC_EM), WorkDe->(MsUnlock())}
EET->(dbSetOrder(1))
IF ! Inclui
   cKey := AVKey(EEC->EEC_PREEMB,"EET_PEDIDO")

   EET->(dbSeek(xFilial("EET")+AvKey(cKey,"EET_PEDIDO")+OC_EM))
   EET->(dbEval(bAddWork,,{||EET->EET_FILIAL == xFilial("EET") .And. ;
         EET->EET_PEDIDO+EET->EET_OCORRE == AvKey(cKey,"EET_PEDIDO")+OC_EM}))
Endif

// *** Trataa Work de Instituicoes Financeiras ...
bAddWork := {|| WorkIn->(RecLock("WorkIn", .T.)),AP100INSGrava(.T.,OC_EM), WorkIn->(MsUnlock())}
EEJ->(dbSetOrder(1))

IF ! Inclui
   EEJ->(dbSeek(xFilial("EEJ")+EEC->EEC_PREEMB+OC_EM))
   EEJ->(dbEval(bAddWork,,{||  !EEJ->(EOF()) .AND. EEJ->EEJ_FILIAL == xFilial("EEJ") .And. EEJ->EEJ_PEDIDO == EEC->EEC_PREEMB.AND.EEJ->EEJ_OCORRE==OC_EM}))
Endif

// *** Trata Work de Notas Fiscais ... AWR Sexta Feira 13/08/1999
bAddWork := {|| WorkNF->(RecLock("WorkNF", .T.)),AE101Grava(.T.,{}), WorkNF->(MsUnlock())}
EEM->(dbSetOrder(1))

IF ! Inclui
   EEM->(dbSeek(xFilial("EEM")+EEC->EEC_PREEMB))
   EEM->(dbEval(bAddWork,,{||  !EEM->(EOF()) .AND. EEM->EEM_FILIAL == xFilial("EEM") .And. EEM->EEM_PREEMB == EEC->EEC_PREEMB}))
Endif

// *** Trata Work de Notify's ...
bAddWork := {|| WorkNo->(RecLock("WorkNo", .T.)),AP100NoGrv(.T.,OC_EM), WorkNo->(MsUnlock())}
EEN->(DBSETORDER(1))

IF ! Inclui
   EEN->(dbSeek(xFilial("EEN")+EEC->EEC_PREEMB+OC_EM))
   EEN->(dbEval(bAddWork,,{||  !EEN->(EOF()) .AND. EEN->EEN_FILIAL == xFilial("EEN") .And. EEN->EEN_PROCES == EEC->EEC_PREEMB.AND.EEN->EEN_OCORRE==OC_EM}))
Endif

//** Tratamento p/ o work de atividades ...
IF Select("EXB") > 0
   If !Inclui
      bAddWork := {|| AP100DocGrava(.T.,OC_EM)}
      aOrd := SaveOrd("EXB")
      EXB->(dbSetOrder(2))
      EXB->(dbSeek(xFilial("EXB")+M->EEC_PREEMB+AvKey("","EXB_PEDIDO")+"1"))
      EXB->(dbEval(bAddWork,,{|| EXB->(!Eof()) .And. EXB->EXB_FILIAL == xFilial("EXB") .And.;
                                 EXB->EXB_TIPO = "1" .And. Empty(EXB->EXB_PEDIDO) .And.;
                                 EXB->EXB_PREEMB == M->EEC_PREEMB}))
      RestOrd(aOrd)
   EndIf
Endif

If EECFlags("HIST_PRECALC")
   If !Inclui
      bAddWork := {|| AP100PreCalcGrv(.t.,OC_EM)}
      aOrd := SaveOrd("EXM")
      EXM->(DbSetOrder(1))
      EXM->(DbSeek(xFilial("EXM")+M->EEC_PREEMB))
      EXM->(DbEval(bAddWork,,{|| EXM->(!Eof()) .And. EXM->EXM_FILIAL == xFilial("EXM") .And.;
                                 EXM->EXM_PREEMB == M->EEC_PREEMB}))
      RestOrd(aOrd)
   EndIf
EndIf

If EECFlags("INVOICE") //By OMJ - 22/06/2005 15:35 - Tratamento de Invoice

   // *** Trata Work de Invoices ( Capa )  ...
   bAddWork := {|| WorkInv->(RecLock("WorkInv", .T.)),AE108InvGrv(.T.,"CAPA"),WorkInv->(MsUnlock())}
   EXP->(DBSETORDER(1))

   IF !Inclui
      EXP->(dbSeek(xFilial("EXP")+EEC->EEC_PREEMB))
      EXP->(dbEval(bAddWork,,{||  !EXP->(EOF()) .AND.;
                                  EXP->EXP_FILIAL == xFilial("EXP") .And.;
                                  EXP->EXP_PREEMB == EEC->EEC_PREEMB }))
   Endif

   // *** Trata Work de Invoices ( Det )  ...
   bAddWork := {|| WorkDetInv->(RecLock("WorkDetInv", .T.)),AE108InvGrv(.T.,"DETALHE"), WorkDetInv->(MsUnlock())}
   EXR->(DBSETORDER(1))

   IF !Inclui

      nIdxWorkIp := WorkIp->(IndexOrd())
      nRecWorkIp := WorkIp->(RecNo())

      WorkIp->(dbSetOrder(2))

      EXR->(dbSeek(xFilial("EXR")+EEC->EEC_PREEMB))
      EXR->(dbEval(bAddWork,,{||  !EXR->(EOF()) .AND.;
                                  EXR->EXR_FILIAL == xFilial("EXR") .And.;
                                  EXR->EXR_PREEMB == EEC->EEC_PREEMB }))

      WorkIp->(dbSetOrder(nIdxWorkIp))
      WorkIp->(dbGoTo(nRecWorkIp))

   Endif

EndIf

If EECFlags("CAFE")

   // *** Trata Work da capa dos OIC´s
   bAddWork := {|| WKEXZ->(RecLock("WKEXZ", .T.)),Ae108WkOIC(.F.,"EXZ"), WKEXZ->(MsUnlock())}
   EXZ->(DBSETORDER(1))

   IF !Inclui
      EXZ->(dbSeek(xFilial("EXZ")+EEC->EEC_PREEMB))
      EXZ->(dbEval(bAddWork,,{||  !EXZ->(EOF()) .AND.;
                                  EXZ->EXZ_FILIAL == xFilial("EXZ") .And.;
                                  EXZ->EXZ_PREEMB == EEC->EEC_PREEMB }))
   Endif

   // *** Trata Work de detalhes dos OIC´s
   bAddWork := {|| WKEY2->(RecLock("WKEY2", .T.)),Ae108WkOIC(.F.,"EY2"), WKEY2->(MsUnlock())}
   EY2->(DBSETORDER(1))

   IF !Inclui

      nIdxWorkIp := WorkIp->(IndexOrd())
      nRecWorkIp := WorkIp->(RecNo())

      WorkIp->(dbSetOrder(2))

      EY2->(dbSeek(xFilial("EY2")+EEC->EEC_PREEMB))
      EY2->(dbEval(bAddWork,,{||  !EY2->(EOF()) .AND.;
                                  EY2->EY2_FILIAL == xFilial("EY2") .And.;
                                  EY2->EY2_PREEMB == EEC->EEC_PREEMB }))

      WorkIp->(dbSetOrder(nIdxWorkIp))
      WorkIp->(dbGoTo(nRecWorkIp))

   Endif

   // ** JPM - 09/12/05 - Controle de Armazéns, carrega a Work.
   WkArm->(AvZap())
   If !Inclui
      EY9->(DbSetOrder(1))
      EY9->(DbSeek(xFilial()+EEC->EEC_PREEMB))
      While EY9->(!EoF()) .And. EY9->(EY9_FILIAL+EY9_PREEMB) == xFilial("EY9")+EEC->EEC_PREEMB
         WkArm->(RecLock("WkArm", .T.))
         AvReplace("EY9","WkArm")
         WkArm->WK_RECNO := EY9->(RecNo())
         WkArm->DBDELETE   := .F.
         WkArm->(MsUnlock())
         EY9->(DbSkip())
      EndDo
   EndIf
   // **

EndIf

Ae100PrecoI(.t.) //JPM - 20/09/05 - Já carrega com os preços calculados corretamente.
//RMD - 08/05/06 - Tratamentos para rotina de venda de consignação
If lConsign .And. !Inclui .And. (cTipoProc == PC_VR .Or. cTipoProc == PC_VB)
   EY5->(DbSetOrder(1))
   If EY5->(DbSeek(xFilial()+M->(EEC_ARM+EEC_ARLOJA)))//RMD - 25/11/21 - Não valida mais o RE/INVOICE, validando somente a data de recebimento
      //EY5->(DbEval({|| WKEY5->(If((cTipoProc == PC_VR .And. EY5->EY5_ORIGEM == "1" .And. !Empty(EY5->EY5_RE) ;
      //                             .Or. cTipoProc == PC_VB .And. EY5->EY5_ORIGEM == "2" .And. !Empty(EY5->EY5_INVOIC)),;
      EY5->(DbEval({|| WKEY5->(If(!Empty(EY5->EY5_DTREC), ;
                       (RecLock("WKEY5", .T.),;
                       AvReplace("EY5","WKEY5"),;
                       WK_RECNO := EY5->(Recno()), MsUnlock()),)) },,;
                       {|| EY5->(!Eof() .And. xFilial() == EY5_FILIAL .And. EY5_IMPORT == M->EEC_ARM .And. EY5_IMLOJA == M->EEC_ARLOJA)}))
      WkEY5->(DbGoTop())
   EndIf
   EY7->(DbSetOrder(1))
   If EY7->(DbSeek(xFilial()+M->EEC_PREEMB))
      EY7->(DbEval({|| WKEY7->(RecLock("WKEY7", .T.), AvReplace("EY7","WKEY7"), WK_RECNO := EY7->(Recno()), MsUnlock()) },,;
                   {|| EY7->(!Eof() .And. xFilial() == EY7_FILIAL .And. EY7_EMBVIN == M->EEC_PREEMB)}))
      WkEY7->(DbGoTop())
   EndIf
   aOrdIp := SaveOrd("WorkIp")
   WorkIp->(DbSetOrder(2))
   While WkEY7->(!Eof())
      WkEY5->(DbSeek(WkEY7->(EY7_IMPORT+EY7_IMLOJA+EY7_PREEMB+EY7_PEDIDO+EY7_SEQUEN+EY7_COD_I+EY7_RE+EY7_INVOIC)))
      WkEY5->WK_QTDVIN += WkEY7->EY7_SLDINI
      If WorkIp->(DbSeek(WkEY7->EY7_SEQEMB))
         WorkIp->WK_QTDREM += WKEY7->EY7_SLDINI
      EndIf
      WkEY7->(DbSkip())
   EndDo
   RestOrd(aOrdIp, .T.)
   WkEY7->(DbGoTop())
EndIf

If Type("lItFabric") == "L" .And. lItFabric  // By JPP - 14/11/2007 - 14:00
   // *** Trata Work de Fabricantes para os itens de Embarque ... // By JPP - 14/11/2007 - 14:00
   bAddWork := {|| WkEYU->(RecLock("WkEYU", .T.)),AE109WKEYU(.F.,"EYU"), WkEYU->(MsUnlock())}
   EYU->(dbSetOrder(1))

   IF ! Inclui
      If EYU->(dbSeek(xFilial("EYU")+EEC->EEC_PREEMB))
         EYU->(dbEval(bAddWork,,{||  !EYU->(EOF()) .AND. EYU->EYU_FILIAL == xFilial("EYU") .And. EYU->EYU_PREEMB == EEC->EEC_PREEMB }))
      EndIf
   Endif
EndIf

//TRP - 17/02/2009 - Carrega os dados da tabela EDG para a WorkEDG.
If Type("lDrawSC") == "L" .and. lDrawSC
   WorkEDG->(AvZap())
   AE100LoadEDG()
EndIf
//TRP - 29/10/10 - Carrega os dados da tabela EWI para a WKEWI
If ChkFile("EWI")
   bAddWork := {|| WkEWI->(RecLock("WkEWI", .T.)),AE109WKEWI(.F.,"EWI"), WkEWI->(MsUnlock())}
   EWI->(dbSetOrder(1))

   IF ! Inclui
      If EWI->(dbSeek(xFilial("EWI")+EEC->EEC_PREEMB))
         EWI->(dbEval(bAddWork,,{||  !EWI->(EOF()) .AND. EWI->EWI_FILIAL == xFilial("EWI") .And. EWI->EWI_PREEMB == EEC->EEC_PREEMB }))
      EndIf
   Endif
Endif
IF EasyEntryPoint("EECPEM34")
   lRetorno := ExecBlock("EECPEM34",.F.,.F.)
   If ValType(lRetorno) = "L"
      lRet:= lRetorno
   EndIf
Endif

RETURN lRET

/*
Funcao      : AE100ITGRAVA
Parametros  : nenhum
Retorno     : NIL
Objetivos   : GERAR
Autor       : Heder M Oliveira
Data/Hora   : 27/01/99 10:46
Revisao     : Cristiano A. Ferreira
Obs.        : 11/08/1999 18:25
*/
Function AE100ITGRAVA(lProc)

   Local lRET:=.T., nAPos:={}
   Local nRecno, nVlComis := 0, nCampos:=0, nWKEY2Recno
   // Local aFieldVirtual := {}
   Local bLastHandler
   Local vRet

   If Type("lIntEmb") == "U"  // SVG - 11/09/08
      Private lIntEmb := EECFlags("INTEMB")
   EndIf
   If Type("lConsolOffShore") == "U"
      Private lConsolOffShore := ((M->EEC_INTERM $ cSim) .And. lConsolida)
   EndIf

   Begin Sequence

      If Type("lAbriuExp") = "U"
         lAbriuExp := .f.
      EndIf

      EE8->(dbSetOrder(1))
      EE7->(dbSetOrder(1))
      EE9->(dbSetOrder(2))
      EE9->(dbSeek(XFILIAL()+M->EEC_PREEMB))

      M->EEC_TOTPED := 0

      /*
      Rotina p/ gravar todos os campos virtuais do EE9 no aFieldVirtual.
      Autor       : Alexsander Martins dos Santos
      Data e Hora : 31/10/2003 às 14:56.
      Objetivo    : Apresentar os campos virtuais com seu conteudo.
      */
      /* by CAF 29/01/05 - AVReplace faz o tratamento para gravação dos campos virtuais
      SX3->(dbSetOrder(1))
      SX3->(dbSeek("EE9"))

      While SX3->(!Eof() .and. X3_ARQUIVO = "EE9")

         If !Empty(SX3->X3_RELACAO) .and. SX3->X3_CONTEXT = "V" .and. X3Uso(SX3->X3_USADO)
            aAdd(aFieldVirtual, {SX3->X3_CAMPO, SX3->X3_RELACAO})
         EndIf

         SX3->(dbSkip())

      End
      */
      //Fim da rotina.

      While !EE9->(EOF()) .AND. EE9->EE9_FILIAL==XFILIAL("EE9") .AND.;
         EE9->EE9_PREEMB == M->EEC_PREEMB

         WorkIP->(RecLock("WorkIP", .T.))

         AVREPLACE("EE9","WorkIP")

         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
         //Se o fluxo de integração alternativo entre o SigaEEC e o SigaFat estiver habilitado, será realizado um tratamento para //
         //verificar se as Notas Fiscais foram excluídas no módulo de Faturamento e nesse caso zera as Notas dos itens do Embarque//
         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
         If lIntEmb
            If Empty(M->EEC_DTEMBA)
               If !Empty(EE9->EE9_NF)
                  SF2->(DbSetOrder(1))
                  If !SF2->(DbSeek(xFilial("SF2")+AvKey(EE9->EE9_NF,"F2_DOC")+AvKey(EE9->EE9_SERIE,"F2_SERIE")))
                     WorkIp->EE9_NF    := CriaVar("EE9_NF")
                     WorkIp->EE9_SERIE := CriaVar("EE9_SERIE")
                     FAT3DelNF(EE9->EE9_NF,EE9->EE9_SERIE)
                  EndIf
               EndIf
            EndIf
         EndIf

         WorkIP->TRB_ALI_WT:= "EE9"
         WorkIp->TRB_REC_WT:= EE9->(Recno())
         //If lConsign //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
            If (Empty(cTipoProc) .Or. cTipoProc == PC_RC) .And. !Empty(WorkIp->EE9_RE)
               EER->(DbSetOrder(3))
               If EER->(DbSeek(xFilial()+Left(WorkIp->EE9_RE, 9)))
                  If EER->EER_MANUAL == "S"
                     EY6->(DbSetOrder(2))
                     If !WkEY6->(DbSeek(WorkIp->EE9_RE)) .And. EY6->(DbSeek(xFilial()+WorkIp->EE9_RE))
                        WkEY6->(RecLock("WkEY6", .T.))
                        AvReplace("EY6", "WkEY6")
                        WkEY6->WK_QTDVIN := AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
                     ElseIf WkEY6->(!Eof()) //MCF - 17/05/2016
                        WkEY6->(RecLock("WkEY6", .F.))
                        WkEY6->WK_QTDVIN += AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
                     EndIf
                     WkEY6->(MsUnlock())
                  EndIf
               EndIf
            EndIf
            If cTipoProc $ PC_VR+PC_VB
               WorkIp->WK_QTDREM := 0
               WkEY7->(DbSetOrder(2))
               If WkEY7->(DbSeek(WorkIp->EE9_SEQEMB))
                  WorkIp->WK_QTDREM -= AvTransUnid(WkEY7->EY7_UNIDAD, WorkIp->EE9_UNIDAD, WorkIp->EE9_COD_I, WkEY7->EY7_SLDINI, .F.)
               EndIf
               WkEY7->(DbSetOrder(1))
            EndIf
         //EndIf

         /*
         AMS - 05/11/2003 às 13:00, Substituido a rotina abaixo, pq os campos do aMemoItens já
                                    estão sendo carregados no aFieldVirtual e tendo o seu conteúdo
                                    carregado pelo X3_RELACAO e gravado no WorkIP.
                                    Obs. Os campos de tipo "MEMO" devem ter o X3_RELACAO preenchido.

         FOR I := 1 TO LEN(aMEMOITEM)
            IF WORKIP->(FIELDPOS(aMEMOITEM[i,2])) > 0
               WORKIP->&(aMEMOITEM[I,2]) := If(lAbriuExp, MSMM_DR(EE9->&(aMEMOITEM[I,1]),AVSX3(aMEMOITEM[I,2],AV_TAMANHO)), MSMM(EE9->&(aMEMOITEM[I,1]),AVSX3(aMEMOITEM[I,2],AV_TAMANHO)))
            ENDIF
         NEXT
         */

         ///WorkIP->EE9_VM_DES := MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES")[AV_TAMANHO])

         If Empty(WorkIP->EE9_VM_DES)  // GFP - 09/01/2014
            WorkIP->EE9_VM_DES:=MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES")[AV_TAMANHO])
         Endif

         WorkIP->WP_FLAG := cMARCA
         WorkIP->WP_RECNO  :=EE9->(RECNO())

         IF EE8->(dbSeek(XFILIAL("EE8")+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
            WorkIP->WP_SLDATU :=EE8->EE8_SLDATU
         Endif

         M->EE9_SEQEMB := WorkIP->EE9_SEQEMB
         M->EE9_SLDINI := WorkIP->EE9_SLDINI
         M->EE9_COD_I  := WorkIP->EE9_COD_I
         M->EE9_EMBAL1 := WorkIP->EE9_EMBAL1
         M->EE9_QTDEM1 := WorkIP->EE9_QTDEM1
         M->EE9_PEDIDO := WorkIP->EE9_PEDIDO
         M->EE9_SEQUEN := WorkIP->EE9_SEQUEN
         nRecNo := WorkIP->(RecNo())

         // *** CAF 22/12/1999 10:02 // ***** Grava WorkEm, com informacoes do EE9 ***** \\
         // *** CAF 22/12/1999 10:02 AE100WkEmb(M->EEC_PREEMB,EE9->EE9_SEQEMB,EE9->EE9_EMBAL1,EE9->EE9_PEDIDO,EE9->EE9_SEQUEN)
         // *** CAF 22/12/1999 10:02 // ***** //////////////////////////////////// ***** \\

         If AvFlags("GRADE")
            WorkIp->WK_ITEMGR:= Posicione("EE8", 1, EE8->(xFilial()) + EE9->(EE9_PEDIDO + EE9_SEQUEN + EE9_COD_I), "EE8_ITEMGR")
         EndIf

         WorkIP->(dbGoTo(nRecNo))
         WorkIP->(MsUnlock())
         // Soma Totais da capa do EEC
         SumTotal()

         If lIntDraw .and. lOkEE9_ATO
            nAPos := ASCAN(aApropria,{|X| X[1]==WorkIP->EE9_ATOCON .and. X[2]=WorkIP->EE9_SEQED3})
            If nAPos > 0
               aApropria[nAPos,3] += WorkIP->EE9_QT_AC
               aApropria[nAPos,4] += WorkIP->EE9_VL_AC
            Else
               AADD(aApropria,{WorkIP->EE9_ATOCON,WorkIP->EE9_SEQED3,WorkIP->EE9_QT_AC,WorkIP->EE9_VL_AC})
            EndIf
         EndIf

         /*
         Rotina p/ execução e gravação dos campos virtuais que estão no aFieldVirtual.
         Autor       : Alexsander Martins dos Santos
         Data e Hora : 31/10/2003 às 15:10.
         Objetivo    : Gravar o retorno do x3_relação(aFieldVirtual[x][2]) nos campos virtuais da Work.
         */
         /* by CAF 29/01/05 - AVReplace faz tratamento para gravação dos campos virtuais.
         bLastHandler := ErrorBlock({||.t.})

         Begin Sequence

            For nCampos := 1 To Len(aFieldVirtual)
                If ValType(WorkIP->&(aFieldVirtual[nCampos][1])) == ValType((vRet := &(aFieldVirtual[nCampos][2])))
                   WorkIP->&(aFieldVirtual[nCampos][1]) := &(aFieldVirtual[nCampos][2])
                EndIf
            Next

         End Sequence

         ErrorBlock(bLastHandler)
         */

         //Fim da rotina.
         /* wfs 12/03/2020 - carregar as works das embalagens especiais - último parâmetro indica o processamento até o método LoadWorks */
         If AvFlags("OPERACAO_ESPECIAL") .And. !Empty(EE9->EE9_CODOPE)
            oOperacao:InitOperacao(EE9->EE9_CODOPE, "EE9", {{"EE9","WorkIP"},{"EEC","M"}},.T.,.F.,"MARC_ITS_EMB",.T.)
         EndIf

         EE9->(DBSKIP(1))

      Enddo

      IF !Inclui
         // ***** Grava WorkEm, com informacoes do EEK ***** \\
         //AE100WkEmb(M->EEC_PREEMB)
         If EE9->(!EOF()) .and. EE9->(!BOF())
            AE100WkEmb(M->EEC_PREEMB,M->EE9_SEQEMB,M->EE9_EMBAL1,M->EE9_PEDIDO,M->EE9_SEQUEN)//ER - 12/07/2006 - Passa todos os parametros
         EndIf
         // ***** //////////////////////////////////// ***** \\
      Endif

      If EECFlags("COMISSAO")//JPM - 29/01/05
         WorkAg->(DbGoTop())
         While WorkAg->(!EoF())
            If WorkAg->EEB_TIPCOM = "3"/*Deduzir da fatura*/ .And. Left(WorkAg->EEB_TIPOAG,1) = CD_AGC//Ag. Rec. Comi.
               nVlComis += WorkAg->EEB_TOTCOM
            EndIf
            WorkAg->(DbSkip())
         EndDo

         WorkAg->(DbGoTop())

      // *** CAF 19/04/2001
      ElseIf !Empty(M->EEC_VALCOM) .And. M->EEC_TIPCOM == "3" // Tipo de Comissao = Deduzir da Fatura
         If M->EEC_TIPCVL == "1" // Percentual
            nVlComis := (M->EEC_VALCOM/100) * M->EEC_TOTPED //Neste momento, esta variável corresponde ao total FOB
         Else
            nVlComis := M->EEC_VALCOM
         Endif
      Endif
      /////////////////////////////

      M->EEC_TOTPED += M->EEC_SEGPRE
      M->EEC_TOTPED += M->EEC_FRPREV
      M->EEC_TOTPED += AvGetCpo("M->EEC_DESP1")
      M->EEC_TOTPED += AvGetCpo("M->EEC_DESP2")
      M->EEC_TOTPED += M->EEC_DESPIN
      M->EEC_TOTPED += M->EEC_FRPCOM
      M->EEC_TOTPED -= M->EEC_DESCON //*= (1-(M->EEC_DESCON/100))
      M->EEC_TOTPED -= nVlComis

      // JPM - 21/10/05 - Carregar work de agrupamentos e de itens da filial oposta
      If EECFlags("INTERMED") .And. Select("WorkGrp") > 0 // If EECFlags("CONTROL_QTD") .And. Select("WorkGrp") > 0 // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
         Ap104LoadGrp()  // carrega work de agrupamentos
         If lConsolOffShore
            Ae104LoadOpos() // carrega work de itens da filial oposta
         EndIf
      EndIf

      If EECFlags("CAFE") //RMD - 21/11/05 - Manutenção de OIC´s
         nWKEY2Recno := WKEY2->(Recno())
         WKEY2->(DbSetOrder(2))
         If WKEY2->(DbSeek(WorkIp->EE9_SEQEMB))//Verifica se o item esta vinculado a algum OIC
            While WKEY2->(!Eof() .And. EY2_SEQEMB == WorkIP->EE9_SEQEMB)
               WorkIp->WK_TOTOIC += WKEY2->EY2_QTDE //Grava no campo WK_TOTOIC a quantidade
               WKEY2->(DbSkip())                    //total do item vinculado a OIC´s
            EndDo
         EndIf
         WKEY2->(DbGoTo(nWKEY2Recno))
      EndIf
   End Sequence

RETURN(lRET)

/*
Programa        : EECPME01.PRW
Objetivo        : Gravar registros ainda nao marcados no WorkIP p/selecao
Autor           : Heder M Oliveira
Data/Hora       :
Obs.            :
Revisão         : WFS - implementações para utilização da grade
*/

FUNCTION EECPME01(cPEDIDO,lALTERA,lSelecao,cSolucao)
   Local lRET:=.F.
   Local bGETSETEE8,bGETSETEE9
   Local aOrd := SaveOrd({"EE8"})
   Local vRet
   Local aNotas := {}
   Local n,i
   Local nRecOld, lAddNF
   Local cCampoCod, cCampoMem, j // JPP - 13/05/2005 -14:05
   Local cFilter, bFilter, cOldFilter
   Local aCpoNotCopy := {"EE8_FATIT"}
   Local lAltVlEmb:= .F., lMsgYesNo:= .F.
   Local nRecEE8:= 0
   // BAK - Permite comparar notas fiscais a partir da tabela EES - 16/12/2011
   Local lNFSEES := .F.
   Local nPos := 0
   Local lTemIt_Ped, lTemNFItem, lPrim_Item, lExibNFIt  //NCF - 11/03/2015
   If AvFlags("NFS_DESVINC")
      lNFSEES := .T.
   EndIf

   //ER - 03/08/2006 - Verifica se está integrado com o faturamento e é um Processo B2b ou Remessa.
   Private lB2BFat := IsProcNotFat()

   Default lALTERA:=.F.
   Default lSelecao := .t. //chamado da seleção de processos

   Begin Sequence

      WorkIP->(dbSetOrder(1))
      EE8->(dbSetOrder(1))
      lTemItWkIp := WorkIP->(DbSeek(cPedido))                                      // NCF - 11/03/2015
      lExibNFIt := .T.//lTemNFItem := If(lTemItWkIp, !Empty(WorkIP->EE9_NF), .F.)
      lSt_It_Pd := .T.
      /*
      Rotina p/ gravar todos os campos virtuais do EE8 no aFieldVirtual.
      Autor       : Alexsander Martins dos Santos
      Data e Hora : 31/10/2003 às 14:56.
      Objetivo    : Apresentar os campos virtuais com seu conteudo.
      */
      /* by CAF 29/01/05 - AVReplace faz tratamento para gravação dos campos virtuais.
      SX3->(dbSetOrder(1))
      SX3->(dbSeek("EE9"))

      While SX3->(!Eof() .and. X3_ARQUIVO = "EE9")

         If !Empty(SX3->X3_RELACAO) .and. SX3->X3_CONTEXT = "V" .and. X3Uso(SX3->X3_USADO)
            aAdd(aFieldVirtual, {SX3->X3_CAMPO, SX3->X3_RELACAO})
         EndIf

         SX3->(dbSkip())

      End
      */
      //Fim da rotina.

      IF ( !lALTERA )
         PROCREGUA(EE8->(Easyreccount("EE8")))
         EE7->(DbSeek(xFilial("EE7")+cPEDIDO))
         EE8->(dbSeek(XFILIAL("EE8")+cPEDIDO))

         DO While !EE8->(EOF()) .AND. XFILIAL("EE8")==EE8->EE8_FILIAL .AND.;
               cPEDIDO==EE8->EE8_PEDIDO

            INCPROC()

            IF !WorkIP->(DBSeek(cPEDIDO + EE8->EE8_SEQUEN + If(AvFlags("GRADE"), EE8->EE8_ITEMGR, "")))
               IF EE8->EE8_SLDATU == 0
                  lConsiste := .t.
                  If SB1->(FieldPos("B1_REPOSIC")) > 0
                     IF Posicione("SB1",1,xFilial("SB1")+EE8->EE8_COD_I,"B1_REPOSIC") $cSim
                         lConsiste := .f.
                     Endif
                  Endif
                  If lConsiste
                     EE8->(DBSKIP())
                     Loop
                  Endif
               Endif

               // *** CAF 06/06/2000 9:25 Integracao com Faturamento
//               If !lSelNotFat // AMS - 22/07/2004 às 17:44.
               IF !lNFSEES .And. lIntegra .AND. ((EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM))
                  nRecEE8:= EE8->(RecNo())
                  aNotas := AE100ItemSD2(EE8->EE8_PEDIDO,EE8->EE8_SEQUEN,@cSolucao)

                  EE8->(DBGoTo(nRecEE8))

                  IF Empty(aNotas)
                     EE8->(dbSkip())
                     Loop
                  Endif
               Else
                  // BAK - Tratamento para notas de saida a partir da tabela EES
                  //aNotas := {{"","",0,""}}
                  aNotas := {{"","",0,"","","",""}}
                  If lNFSEES
                     nRecEE8:= EE8->(RecNo())
                     aNotas := AE100ItemEES(EE8->EE8_PEDIDO,EE8->EE8_SEQUEN)
                     EE8->(DBGoTo(nRecEE8))
                     If Empty(aNotas)
                        EE8->(dbSkip())
                        Loop
                     Endif
                  EndIf
               Endif
//               EndIf
               If AvFlags("EEC_LOGIX")           // NCF - 11/03/2015
                  If !lTemItWkIp .And. lSt_It_Pd
                     If (Len(aNotas) == 1 .And. Empty(aNotas[1][1])) .Or.((Type("lAe100Auto") <> "L" .Or. lAe100Auto) .Or.;
                        MsgYesNo('Deseja permitir seleção de todo o saldo dos itens deste Pedido?'+CHR(13)+CHR(10)+;
                                 ''+CHR(13)+CHR(10)+;
                                 'Clique em SIM se deseja exibir todo o saldo faturado ou não. Neste caso as'+CHR(13)+CHR(10)+;
                                 'Notas Fiscais de saída destes itens não serão exibidas até que o saldo '+CHR(13)+CHR(10)+;
                                 'total de todos os itens seja faturado e a comparação de Notas Fiscais x '+CHR(13)+CHR(10)+;
                                 'Embarque seja acionada.'+CHR(13)+CHR(10)+;
                                 ''+CHR(13)+CHR(10)+;
                                 'Clique em NAO se deseja exibir os itens faturados. Neste caso, o saldo '+CHR(13)+CHR(10)+;
                                 'dos itens sem fatura (parcialmente faturados) não serão exibidos para  '+CHR(13)+CHR(10)+;
                                 'seleção.'+CHR(13)+CHR(10)+;
                                 ''+CHR(13)+CHR(10)+;
                                 'Esta opção é irreversível para um Pedido após um item relacionado ao mesmo '+CHR(13)+CHR(10)+;
                                 'estiver incluso neste processo de Embarque em modo de alteração.'+CHR(13)+CHR(10) ))

                        If (nPosPed := aScan(aOpcPedFat, {|x| x[1] == cPedido   } )  ) == 0
                           aAdd( aOpcPedFat, {cPedido,.T.} )
                        EndIf
                        aNotas := {{"","",0,"","","",""}}
                        lExibNFIt := .F.
                     Else
                        If (nPosPed := aScan(aOpcPedFat, {|x| x[1] == cPedido   } )  ) == 0
                           aAdd( aOpcPedFat, {cPedido,.F.} )
                        Else
                           aOpcPedFat[nPosPed][2] := .F.
                        EndIf
                     EndIf
                     lSt_It_Pd := .F.
                  Else
                     If ( nPosPed := aScan(aOpcPedFat, {|x| x[1] == cPedido   } ) ) > 0
                        If aOpcPedFat[nPosPed][2]
                           aNotas := {{"","",0,"","","",""}}
                        EndIF
                     Else

                     EndIf
                  EndIf
               EndIf

		       //AAF 08/07/2015 - Ratear desconto por item na quebra de NF
		       oRatDesc := EasyRateio():New(EE8->EE8_DESCON,EE8->EE8_SLDINI,Len(aNotas),AvSX3("EE9_DESCON",AV_DECIMAL))

               For n:=1 To Len(aNotas)
                  WorkIP->(RecLock("WorkIP", .T.))

                  For i:=1 To EE8->(FCount())
                     cField := EE8->(FieldName(i))

                     //Verifica os campos que não devem ser carregados automaticamente.
                     If aScan(aCpoNotCopy,cField) > 0
                        Loop
                     EndIf

                     bGETSETEE8:=FIELDWBLOCK(cFIELD,SELECT("EE8"))
                     cFIELDEE9:="EE9"+SUBSTR(ALLTRIM(cFIELD),4)
                     bGETSETEE9:=FIELDWBLOCK(cFIELDEE9,SELECT("WorkIP"))
                     IF ( WorkIP->(FIELDPOS(cFIELDEE9))#0)
                        EVAL(bGETSETEE9,EVAL(bGETSETEE8))
                     Endif
                  Next i

                  WorkIP->TRB_ALI_WT:= "EE8"
                  WorkIP->TRB_REC_WT:= EE8->(Recno())

                  IF (lIntegra .Or. lNFSEES) .AND.;
                     ((EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM))
                     *
                     WorkIP->EE9_NF    := aNotas[n,1]
                     WorkIP->EE9_SERIE := aNotas[n,2]
                     If EECFlags("FATFILIAL")
                        WorkIP->EE9_FIL_NF := aNotas[n,4]
                     EndIf
                     If AvFlags("EEC_LOGIX") //NCF - 23/11/2017
                        WorkIP->EE9_FATSEQ  := aNotas[n,7]
                        AE102ESSEYY( If(!Empty(WorkIP->WP_FLAG),"1","2") ,WorkIP->EE9_PREEMB,"WORKIP" )
                     EndIf
                     If AvFlags("NOTAS_FISCAIS_SAIDA_LOTE_EXPORTACAO")
                        AE102EESEK6( If(!Empty(WorkIP->WP_FLAG),"1","2") ,WorkIP->EE9_PREEMB,"WORKIP" )
                     EndIf
                  Endif

                  //WorkIP->EE9_VM_DES := MSMM(EE8->EE8_DESC,AVSX3("EE8_VM_DES")[AV_TAMANHO])  // JPP - 13/05/2005 -14:05

                  For j := 1 To Len(aMemoItem) // JPP - 13/05/2005 -14:05 - Os campos memos dos itens serão gravados com base no Array aMemoItem
                      cCampoCod := "EE8"+Substr(aMemoItem[j,1],4,7)
                      cCampoMem := "EE8"+Substr(aMemoItem[j,2],4,7)
                      If EE8->(Fieldpos(cCampoCod)) > 0 .And. AvSX3(cCampoMem,,,.t.) .And.;
                         EE9->(Fieldpos(aMemoItem[j,1])) > 0 .And. AvSX3(aMemoItem[j,2],,,.t.)
                         WorkIp->&(aMemoItem[j,2]) := EasyMSMM(&("EE8->"+cCampoCod),AVSX3(cCampoMem)[AV_TAMANHO],,,LERMEMO,,,"EE8",cCampoCod)      //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
                      EndIf
                  Next

                  //saldos de quantidade na 1. vez (embarque total)
                  WorkIP->EE9_SLDINI := 0
                  WorkIP->WP_SLDATU  := EE8->EE8_SLDATU
                  WorkIP->WP_FLAG    := ""

                  /*
                  AMS - 16/11/2005. Notapa a atualização dos pesos, para que seja feita somente quando o usuário informar a qtde
                                    ou quando o item for selecionado.
                  */
                  //If EE8->EE8_SLDINI <> EE8->EE8_SLDATU
                  //   Ap101CalcPsBr(OC_EM,.t.,.f.) // Efetua os cálculos pela work.
                  //EndIf

                  WorkIP->EE9_PRCTOT := 0
                  WorkIP->EE9_PRCINC := 0

                  // ** JPM - 23/02/06 - Pesos liquidos e brutos não devem ser zerados quando é digitação manual.
                  If !EasyGParam("MV_AVG0009",,.F.)
                     WorkIP->EE9_PSLQTO := 0
                     WorkIP->EE9_PSBRTO := 0
                  EndIf

                  WorkIP->EE9_QTDEM1 := 0

                  IF !Empty(aNotas[n][3])
                     WorkIP->WP_SLDATU := aNotas[n][3]
                  Endif

                  If AvFlags("GRADE")
                     If EE8->EE8_GRADE == "S"
                        WorkIp->WK_ITEMGR := EE8->EE8_ITEMGR
                     EndIf
                  EndIf

                  //MCF - 24/05/2016 - Adicionado validação para caso o embarque seja criado sem faturamento (MV_AVG0067)
				  IF !Empty(aNotas[n][3])
				     //AAF 08/07/2015 - Ratear desconto por item na quebra de NF
				     WorkIP->EE9_DESCON := oRatDesc:GetItemRateio(aNotas[n][3])
				  EndIf
                  WorkIP->(MsUnlock())
               Next n

               If EasyEntryPoint("EECAE102") // By DFS - 02/10/09 - 11:15 - Inclusão do ponto de entrada
                  ExecBlock("EECAE102",.f.,.f.,"ADD_CPO_EMB")
               EndIf

            ELSEIF lNFSEES .Or. (lINTEGRA .AND. ((EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM))) // BAK - Nota Fiscal de Saida a partir do EES
                   nRecEE8:= EE8->(RecNo())
                   If !lNFSEES .And. lINTEGRA .AND. ((EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM))
                      aNotas := AE100ItemSD2(EE8->EE8_PEDIDO,EE8->EE8_SEQUEN)
                   ElseIf lNFSEES
                      aNotas := AE100ItemEES(EE8->EE8_PEDIDO,EE8->EE8_SEQUEN)
                   EndIf
                   EE8->(DBGoTo(nRecEE8))

                   IF ! Empty(aNotas) .And. !Empty(WorkIP->EE9_NF)
                      For n:=1 To Len(aNotas)

                          // by CAF 14/02/2005 - Estava duplicando os registros.
                          lAddNF := .t.
                          nRecOld := WorkIP->(RecNo())
                          WorkIp->(DBSeek(aNotas[n][5] + aNotas[n][6])) //reposiciona no primeiro registro da sequência
                          While WorkIP->(!Eof()) .And. WorkIP->EE9_PEDIDO == cPedido .And.;
                                WorkIP->EE9_SEQUEN == EE8->EE8_SEQUEN

                             IF WorkIP->EE9_NF == AvKey(aNotas[n,1], "EE9_NF" ) .And. WorkIP->EE9_SERIE == AvKey(aNotas[n,2], "EE9_SERIE" ) .And.;      //NCF - 11/03/2014 - Ajuste da chave de comparação com AvKey
                                If(EECFlags("FATFILIAL"),WorkIP->EE9_FIL_NF == AvKey(aNotas[n,4], "EE9_FIL_NF" ),.T.) // JPM - 27/12/05

                                lAddNF := .f.
                                Exit
                             Endif

                             WorkIP->(dbSkip())
                          Enddo
                          WorkIP->(dbGoTo(nRecOld))

                          IF !lAddNF .Or. EE8->EE8_SLDATU <= 0
                             Loop
                          Endif

                          WorkIP->(RecLock("WorkIP", .T.))
                          For i:=1 To EE8->(FCount())
                              cField := EE8->(FieldName(i))
                              bGETSETEE8:=FIELDWBLOCK(cFIELD,SELECT("EE8"))
                              cFIELDEE9:="EE9"+SUBSTR(ALLTRIM(cFIELD),4)
                              bGETSETEE9:=FIELDWBLOCK(cFIELDEE9,SELECT("WorkIP"))
                              IF ( WorkIP->(FIELDPOS(cFIELDEE9))#0)
                                 EVAL(bGETSETEE9,EVAL(bGETSETEE8))
                              Endif
                          Next
                          WorkIP->TRB_ALI_WT:= "EE8"
                          WorkIP->TRB_REC_WT:= EE8->(Recno())
                          WorkIP->EE9_NF    := aNotas[n,1]
                          WorkIP->EE9_SERIE := aNotas[n,2]
                          If EECFlags("FATFILIAL")
                             WorkIP->EE9_FIL_NF := aNotas[n,4]
                          EndIf

                          // WorkIP->EE9_VM_DES := MSMM(EE8->EE8_DESC,AVSX3("EE8_VM_DES")[AV_TAMANHO]) // JPP - 13/05/2005 -14:05

                          For j := 1 To Len(aMemoItem) // JPP - 13/05/2005 -14:05 - Os campos memos dos itens serão gravados com base no Array aMemoItem
                              cCampoCod := "EE8"+Substr(aMemoItem[j,1],4,7)
                              cCampoMem := "EE8"+Substr(aMemoItem[j,2],4,7)
                              If EE8->(Fieldpos(cCampoCod)) > 0 .And. AvSX3(cCampoMem,,,.t.) .And.;
                                 EE9->(Fieldpos(aMemoItem[j,1])) > 0 .And. AvSX3(aMemoItem[j,2],,,.t.)
                                 &(aMemoItem[j,2]) := EasyMSMM(&("EE8->"+cCampoCod),AVSX3(cCampoMem)[AV_TAMANHO],,,LERMEMO,,,"EE8",cCampoCod)    //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
                              EndIf
                          Next

                          //saldos de quantidade na 1. vez (embarque total)
                          WorkIP->EE9_SLDINI := 0
                          WorkIP->WP_SLDATU  := EE8->EE8_SLDATU
                          WorkIP->WP_FLAG    := ""
                          IF !Empty(aNotas[n,3])
                             WorkIP->WP_SLDATU := aNotas[n,3]
                          EndiF

                          /*
                          AMS - 16/11/2005. Nopada a atualização dos campos de pesos, para que seja gravado 0.
                          //WorkIP->EE9_PSLQTO := WorkIP->(EE9_SLDINI*EE9_PSLQUN) // AMS - 17/02/2005.
                          //WorkIP->EE9_PSBRTO := WorkIP->(EE9_SLDINI*EE9_PSBRUN) // AMS - 17/02/2005.

                          //If WorkIP->(EE9_SLDINI % EE9_QE) == 0
                          //   WorkIP->EE9_QTDEM1 := Int(WorkIP->(EE9_SLDINI/EE9_QE)) //QUANT.DE EMBAL.
                          //Else
                          //   WorkIP->EE9_QTDEM1 := Int(WorkIP->(EE9_SLDINI/EE9_QE))+1 //QUANT.DE EMBAL.
                          //EndIf
                          */
                          WorkIP->EE9_PRCTOT := 0
                          WorkIP->EE9_PRCINC := 0
                          WorkIP->EE9_PSLQTO := 0
                          WorkIP->EE9_PSBRTO := 0
                          WorkIP->EE9_QTDEM1 := 0
                          WorkIP->(MsUnlock())
                      Next
                   //WFS 02/10/2009 - Atualização valor do item no embarque quando há alteração no
                   //pedido de exportação, para processos não faturados.
                   ElseIf Empty(WorkIP->EE9_NF) .And. (EasyGParam("MV_EECFAT",, .F.) .And. !EasyGParam("MV_AVG0067",, .F.)) //MCF - 06/01/2016

                      If !lMsgYesNo .And. WorkIP->EE9_PRECO <> EE8->EE8_PRECO
                         lAltVlEmb:= MsgYesNo(STR0123, STR0048) //Existem divergências entre os valores dos itens do embarque e os itens do + ENTER + pedido de exportação. Deseja atualizar?, Atenção
                         lMsgYesNo:= .T.
                      EndIf

                      If lAltVlEmb
                         WorkIP->EE9_PRECO:= EE8->EE8_PRECO
                      EndIf

                      If !Empty(aNotas) .And. (nPos := aScan(aNotas,{ |X| X[5] == EE8->EE8_PEDIDO .And. X[6] == EE8->EE8_SEQUEN })) > 0
                          WorkIP->EE9_NF    := aNotas[nPos,1]
                          WorkIP->EE9_SERIE := aNotas[nPos,2]
                          If !Empty(aNotas[nPos,3])
                             WorkIP->WP_SLDATU := aNotas[nPos,3]
                          EndIf
                      EndIf
                   EndIf
            ENDIF


            /*
            Rotina p/ execução e gravação dos campos virtuais que estão no aFieldVirtual.
            Autor       : Alexsander Martins dos Santos
            Data e Hora : 31/10/2003 às 15:10.
            Objetivo    : Gravar o retorno do x3_relação(aFieldVirtual[x][2]) nos campos virtuais da Work.
            */
            /* by CAF 29/01/05 - AVReplace faz tratamento para gravação dos campos virtuais.
            bLastHandler := ErrorBlock({||.t.})

            Begin Sequence

               For nCampos := 1 To Len(aFieldVirtual)
                   If ValType(WorkIP->&(aFieldVirtual[nCampos][1])) == ValType((vRet := &(aFieldVirtual[nCampos][2])))
                      WorkIP->&(aFieldVirtual[nCampos][1]) := &(aFieldVirtual[nCampos][2])
                   EndIf
               Next

            End Sequence

            ErrorBlock(bLastHandler)
            */
            //Fim da rotina.

            lRet := .T.

            EE8->(DBSKIP(1))

         Enddo

         If EECFlags("INTERMED") // If EECFlags("CONTROL_QTD") // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
            If lConsolOffShore
               Ae104LoadOpos(cPedido) // JPM - 21/10/05 - carrega itens da filial oposta
            EndIf
            If Empty(cOldFilter := WorkIp->(DbFilter()))
               cOldFilter := ".t."
            EndIf
            cFilter := "WorkIp->EE9_PEDIDO == cPedido"
            bFilter := &("{||" + cFilter + "}")
            WorkIp->(DbSetFilter(bFilter,cFilter))
            Ap104LoadGrp()         // carrega grupos apenas para os itens que acabaram de ser carregados (filtro)
            WorkIp->(DbSetFilter(&("{||" + cOldFilter + "}"),cOldFilter))
         EndIf

      ELSE
         EE8->(dbSeek(XFILIAL("EE8")+cPEDIDO+WorkIP->EE9_SEQUEN))
         WorkIP->EE9_SLDINI := 0
         WorkIP->WP_SLDATU  := EE8->EE8_SLDATU
         WorkIP->WP_FLAG    := ""
      ENDIF

   End Sequence

   RestOrd(aOrd)

RETURN(lRET)

/*
Funcao          : AE100PEDREF(nRET)
Parametros      : nRET := campo retorno
Retorno         : xRET:=retorno depEndEndo do campo
Objetivos       : Disparar retornos automaticos de trigger
Autor           : Heder M Oliveira
Data/Hora       : 02/02/99 11:42
Revisao         :
Obs.            :
*/
Function AE100PEDREF(nRET)
   Local xRet := ""
   Default nRET:=1

   Begin Sequence

      If Type("lNotShowScreen") <> "L" // JPM - 06/05/06
         lNotShowScreen := .F.
      EndIf

      If nRET ==1 //retornar codigo importador e totais do seu pedido referencia
                  //retornar codigo do importador

         //RMD - 01/08/18 - Trata o execauto do embarque
         If Type("lAe100Auto") <> "L" .Or. !lAe100Auto
            MsAguarde({|| MsProcTxt(STR0035),; //"Copiando Dados do Processo ..."
                           xRet := AE100CopyPed(!lNotShowScreen) },STR0036) //"Embarque"
         Else
            xRet := AE100CopyPed(!lNotShowScreen)
         EndIf

         If EasyEntryPoint("EECAE102")
            Execblock("EECAE102", .F., .F., "PEDREF_FINAL")
         EndIf

      Endif

   End Sequence

Return xRET
/*
Funcao          : AE100CopyPed
Parametros      : lRefresh => Executa refresh nos objetos da tela.
Retorno         : xRET:=retorno depEndEndo do campo
Objetivos       : Disparar retornos automaticos de trigger
Autor           : Heder M Oliveira
Data/Hora       : 02/02/99 11:42
Revisao         :
Obs.            :
*/
Function AE100CopyPed(lRefresh)
   Local xRet:="",cOldArea:=select(),nTOTITEM:=0,aSX3
   Local cVar, bVar, i:=0

   Local aCampos
   Local nCampo     := 0
   Local aDespesas  := X3DIReturn()
   Local nDespesa   := 0

   Local aCposNotCopy := {"EE7_PEDFAT", "EE7_CODMAR", "EE7_CODMEM"} //MCF - 03/11/2015 - Não copiar o EE7_CODMAR do pedido para não sobrescrever
                                                      //o campo EE7_MARCACAO do pedido referencia no momento da gravação do embarque.
   Default lRefresh := .t.

   Begin Sequence

      If lTotRodape  // GFP - 11/04/2014
         aAdd(aCposNotCopy,"EE7_TOTFOB")
         aAdd(aCposNotCopy,"EE7_TOTLIQ")
         aAdd(aCposNotCopy,"EE7_VALCOM")
      EndIf

      SX3->(dbSetOrder(2))
      EE7->(dbSetOrder(1))

      If !EE7->(dbSeek(XFILIAL("EE7")+M->EEC_PEDREF))
         Break
      Endif

      /*
      AMS - 26/11/2004 às 19:37. Inicialização dos campos referentes a Despesas Internacionais.
      */
      If EECFlags("FRESEGCOM")

         aCampos  := { "EXL_MD",;
                       "EXL_VD",;
                       "EXL_PA",;
                       "EXL_EM",;
                       "EXL_DE",;
                       "EXL_FO",;
                       "EXL_LF",;
                       "EXL_CP",;
                       "EXL_DP",;
                       "EXL_DC",;
                       "EXL_DT" }

         For nDespesa := 1 To Len(aDespesas)

            M->&(aDespesas[nDespesa][2]) := CriaVar(aDespesas[nDespesa][2])

            For nCampo := 1 To Len(aCampos)
               M->&(aCampos[nCampo]+aDespesas[nDespesa][1]) := CriaVar(aCampos[nCampo]+aDespesas[nDespesa][1])
            Next

         Next

      EndIf

      xRET :=EE7->EE7_IMPORT

      For i:=1 To EE7->(FCount())
         cField := EE7->(FieldName(i))

         //Campos que não devem ser copiados.
         If aScan(aCposNotCopy,cField) > 0
            Loop
         EndIf

         //cVar:="EEC"+SUBSTR(ALLTRIM(cFIELD),4)
         cVar := SubStr(AllTrim(cField), 4)

         /*
         AMS - 18/12/2004 às 16:40. Consistencia para copiar os campos para o  EEC ou EXL.
         */
         Do Case
            Case EEC->(FieldPos("EEC"+cVar)) > 0
               cVar := "EEC"+cVar

            Case Select("EXL") > 0 .and. EXL->(FieldPos("EXL"+cVar)) > 0
               cVar := "EXL"+cVar

            Otherwise
               Loop

         End Case

         bVar := MemVarBlock(cVar)

         &cVar:= CriaVar(cVar, .F.)

         Eval(bVar, EE7->(FIELDGET(I)))

      Next

      // by CAF 10/08/2001 11:16 Copia os Campos Virtuais
      SX3->(dbSetOrder(1))
      SX3->(dbSeek("EEC"))
      While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EEC"
         IF Upper(SX3->X3_CONTEXT) == "V"
            M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
         Endif
         SX3->(dbSkip())
      Enddo

      SX3->(DbSetOrder(2))
      SX3->(dbSeek("EEC_MOTSIT")) //NCF - 21/01/2010 - Roda o gatilho do campo já que o contradominio (EEC_DSCMST)
      IF SX3->X3_TRIGGER $ "Ss"   //                   é um campo virtual cuja variável de memória é criada no bloco
         RunTrigger(1)            //                   acima, após o gatilho já ter executado.
      Endif

      /*
      AMS - 18/12/2004 às 17:02. Copia os campos virtuais do EXL.
      */
      SX3->(dbSetOrder(1))
      If Select("EXL") > 0
         SX3->(dbSeek("EXL"))
         While SX3->(!Eof() .and. X3_ARQUIVO == "EXL")
            If Upper(SX3->X3_CONTEXT) == "V"
               M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
            EndIf
            SX3->(dbSkip())
         End
      Endif

      M->EEC_DESCPA := MSMM(Posicione("SY6",1,xFilial("SY6")+M->EEC_CONDPA+STR(M->EEC_DIASPA,3),"Y6_DESC_P"),60,1)
      //M->EEC_PAISET := Posicione("SA1",1,xFilial("SA1")+IF(!Empty(M->EEC_CLIENT),M->EEC_CLIENT+M->EEC_CLLOJA,M->EEC_IMPORT+M->EEC_IMLOJA),"A1_PAIS")
      If Empty(EE7->EE7_PAISET)
         M->EEC_PAISET := Posicione("SYR",1,xFilial("SYR")+M->EEC_VIA+M->EEC_ORIGEM+M->EEC_DEST,"YR_PAIS_DE")
      EndIf
      M->EEC_STATUS :=ST_DC //AGUARDANDO CONFECCAO DOCUMENTOS
      M->EEC_DTPROC := dDATABASE
      M->EEC_FIM_PE :=AVCTOD("")

      SYR->(dbSetOrder(1))
      IF SYR->(dbSeek(XFILIAL("SYR")+M->EEC_VIA+M->EEC_ORIGEM+M->EEC_DEST+M->EEC_TIPTRA))
         M->EEC_PAISDT := SYR->YR_PAIS_DE
         M->EEC_TRSTIM := SYR->YR_TRANS_T
      Endif

      DSCSITEE7(,OC_EM)

      M->EEC_CLIEDE :=IF(!EMPTY(M->EEC_CLIENT),POSICIONE("SA1",1,XFILIAL("SA1")+M->EEC_CLIENT+M->EEC_CLLOJA,"A1_NOME"),"")
      M->EEC_EXPODE :=IF(!EMPTY(M->EEC_EXPORT),BUSCAF_F(M->EEC_EXPORT+M->EEC_EXLOJA,.F.),"")
      M->EEC_CONSDE :=IF(!EMPTY(M->EEC_CONSIG), if( empty(M->EEC_CONSDE), POSICIONE("SA1",1,XFILIAL("SA1")+M->EEC_CONSIG+M->EEC_COLOJA,"A1_NOME"), M->EEC_CONSDE),"")

      M->EEC_MARCAC := MSMM(EE7->EE7_CODMAR,AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
      M->EEC_OBS    := MSMM(EE7->EE7_CODMEM,AVSX3("EEC_OBS",AV_TAMANHO),,,LERMEMO)
      M->EEC_GENERI := MSMM(EE7->EE7_DSCGEN,AVSX3("EEC_GENERI",AV_TAMANHO),,,LERMEMO)
      M->EEC_OBSPED := MSMM(EE7->EE7_CODOBP,AVSX3("EEC_OBSPED",AV_TAMANHO),,,LERMEMO)
      If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-30/10/2015
         M->EEC_VMDCOF := MSMM(M->EEC_INFCOF,AVSX3("EEC_VMDCOF",AV_TAMANHO),,,LERMEMO)
      EndIf

      SYQ->(dbSetOrder(1))
      SYQ->(dbSeek(XFILIAL("SYQ")+M->EEC_VIA))
      M->EEC_VIA_DE:=SYQ->YQ_DESCR

      //RMD - ROADMAP: C1 - 27/05/15 - Preenche a NBS do frete de acordo com a Via de Transporte
      If !Empty(M->EEC_VIA) .And. SYQ->(FieldPos("YQ_PRDSIS")) > 0 .And. !Empty(cPrdSis := Posicione("SYQ", 1, xFilial("SYQ")+M->EEC_VIA, "YQ_PRDSIS"))
         If !Empty(cNBSVia := Posicione("SB5", 1, xFilial("SB5")+cPrdSis, "B5_NBS"))
            M->EXL_NBSFR := cNBSVia
         EndIf
      EndIf

      M->EEC_URFDSP := POSICIONE("SY9",2,XFILIAL("SY9")+M->EEC_ORIGEM,"Y9_URF")

      M->EEC_URFENT := M->EEC_URFDSP

      /* AMS - 18/12/2004 às 16:17. Retirado Seek no SY6 pois não havia necessidade.
      SY6->(dbSetOrder(1))
      IF SY6->(dbSeek(XFILIAL("SY6")+M->EEC_CONDPA+STR(M->EEC_DIASPA)))
         M->EEC_DESCPA:=SY6->(MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",AV_TAMANHO),,,LERMEMO))
      Endif
      */
      M->EEC_DESCPA:=SY6->(MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",AV_TAMANHO),,,LERMEMO))

      M->EEC_PESLIQ:=M->EEC_PESBRU:=M->EEC_TOTITE:=M->EEC_TOTPED:=0

      // JPM - 10/11/05
      lConsolOffShore := (M->EEC_INTERM $ cSim) .And. lConsolida

      AE101CobCamb("CARREGA_EMB") // By JPP - 22/09/2005 - 17:55 - Carregar automaticamente o campo Cobertura cambial(EEC_COBCAM)

      WorkIP->(dbGoTop())
      WorkIP->(dbEval({||SumTotal()},{||!Empty(WP_FLAG)}))

      // ** By JBJ - Flag para controle de Refresh para os objetos da tela da manutencao de embarque.
      If lRefresh
         If Type("oItens") == "O"
            oItens:Refresh()
         EndIf
         If Type("oLiquido") == "O"
            oLiquido:Refresh()
         EndIf
         If Type("oPedido") == "O"
            oPedido:Refresh()
         EndIf
         If Type("oBruto") == "O"
            oBruto:Refresh()
         EndIf
         If Type("oMsSelect") == "O"
            oMsSelect:oBrowse:Refresh()
         EndIf
      EndIf

      WorkAg->(AvZap())
      WorkIn->(AvZap())
      WorkDe->(AvZap())
      WorkNo->(AvZap())

      // GRAVA DESPESAS
      bAddWork := {|| WorkDe->(RecLock("WorkDe", .T.)),AP100DSGrava(.T.,OC_EM), WorkDe->(MsUnlock())}
      EET->(dbSetOrder(1))

      cKey := AVKey(EE7->EE7_PEDIDO,"EET_PEDIDO")

      EET->(dbSeek(xFilial("EET")+AvKey(cKey,"EET_PEDIDO")+OC_PE))
      EET->(dbEval(bAddWork,,{||EET->EET_FILIAL == xFilial("EET") .And. ;
                 EET->EET_PEDIDO+EET->EET_OCORRE == AvKey(cKey,"EET_PEDIDO")+OC_PE}))

      WorkDe->(dbGotop())
      WorkDe->(dbEval({||WorkDe->EET_RECNO:=0,WorkDe->EET_OCORRE:=OC_EM}))
      WorkDe->(DBGOTOP())

      // Grava Instituicoes ..
      bAddWork := {|| WorkIn->(RecLock("WorkIn", .T.)),AP100INSGrava(.T.,OC_EM), WorkIn->(MsUnlock())}
      EEJ->(dbSetOrder(1))

      EEJ->(dbSeek(xFilial("EEJ")+EE7->EE7_PEDIDO+OC_PE))
      EEJ->(dbEval(bAddWork,,{|| !EEJ->(EOF()) .AND. EEJ->EEJ_FILIAL == xFilial("EEJ") .And. EEJ->EEJ_PEDIDO == EE7->EE7_PEDIDO.AND.EEJ->EEJ_OCORRE==OC_PE}))

      WorkIn->(dbGoTop())
      WorkIn->(dbEval({||WorkIn->WK_RECNO:=0,WorkIn->EEJ_OCORRE:=OC_EM}))
      WorkIn->(DBGOTOP())

      // Grava Empresas/Agencias
      bAddWork  := {|| WorkAg->(RecLock("WorkAg", .T.)),AP100AGGrava(.T.,OC_EM), WorkAg->(MsUnlock())}
      EEB->(dbSetOrder(1))

      EEB->(dbSeek(xFilial("EEB")+EE7->EE7_PEDIDO+OC_PE))
      EEB->(dbEval(bAddWork,,{|| !EEB->(EOF()) .AND. EEB->EEB_FILIAL == xFilial("EEB") .And. EEB->EEB_PEDIDO == EE7->EE7_PEDIDO.AND.EEB->EEB_OCORRE==OC_PE}))

      WorkAg->(dbGotop())
      WorkAg->(dbEval({||WorkAg->WK_RECNO:=0,WorkAg->EEB_OCORRE:=OC_EM}))
      WorkAg->(DBGOTOP())

      // Grava Notify ...
      bAddWork := {|| WorkNo->(RecLock("WorkNo", .T.)),AP100NoGrv(.T.,OC_EM), WorkNo->(MsUnlock())}

      EEN->(DBSETORDER(1))

      EEN->(dbSeek(xFilial("EEN")+EE7->EE7_PEDIDO+OC_PE))
      EEN->(dbEval(bAddWork,,{|| !EEN->(EOF()) .AND. EEN->EEN_FILIAL == xFilial("EEN") .And. EEN->EEN_PROCES == EE7->EE7_PEDIDO.AND.EEN->EEN_OCORRE==OC_PE}))

      WorkNo->(dbGotop())
      WorkNo->(dbEval({||WorkNo->WK_RECNO:=0,WorkNo->EEN_OCORRE:=OC_EM}))
      WorkNo->(DBGOTOP())

      If EasyGParam("MV_AVG0119",,.F.) // FJH 03/02/05
         M->EEC_DESCON := 0
      Endif
      If lConsign .And. cTipoProc $ (PC_VR+PC_VB)
         M->EEC_TIPO := cTipoProc
      EndIf

      If EEC->(FieldPos("EEC_VLRIE")) # 0  // GFP - 17/12/2015
         M->EEC_VVLIE := AE100VLRIE(1)
      EndIf
   End Sequence

   dbSelectArea(cOldArea)

Return xRET

/*
    Funcao   : EECVLEE9(cCAMPO)
    Autor    : Heder M Oliveira
    Data     : 29/07/99 16:26
    Revisao  : 29/07/99 16:26
    Uso      : Validar campos EE9
    Recebe   :
    Retorna  :

*/
FUNCTION EECVLEE9(cCAMPO)
   Local lRET     :=.T.
   Local cFatIt   := ""
   Local nRecEE8  := 0
   Local aSaveOrd := SaveOrd("EES", 1)
   Local nTotFOB  := 0 //LRS

   // ** JPM - 31/10/05 - Validação artificial pela MsGetDados - Controle de quantidades entre filiais Brasil X Off-Shore
   If Type("lArtificial") <> "L"
      lArtificial := .f.
   EndIf

   If lArtificial
      cWork := If(Type("lGdFilAtu") <> "L" .Or. lGdFilAtu,"WorkIp","WorkOpos")
   Else
      cWork := "WorkIp"
   EndIf

   Begin Sequence
     DO CASE
        CASE cCAMPO="EE9_PRECO"
            AE100CALC("PRECOS")

        CASE cCAMPO="EE9_SLDINI"
            If EECFlags("CAFE") .And. Type("lMarkAll") <> "L" .And. cWork == "WorkIp"
               If M->EE9_SLDINI < WorkIp->WK_TOTOIC
                  EasyHelp(STR0117,STR0058)//"Quantidade insuficiente, item possui quantidade vinculada a OIC´s."###"Atenção"
                  lRet := .F.
                  Break
               EndIf
            EndIf

            IF ( M->EE9_SLDINI > ((cWork)->WP_SLDATU+(cWork)->EE9_SLDINI) )
               lRET:=.F.
               HELP(" ",1,"AVG0000636") //("Não é possível embarcar quantidade maior que a disponível","Atenção")
               Break
            ENDIF

            /*
            AMS - 20/12/2004 às 12:04. Consistência para não permitir que a qtde informada do item seja menor
                                       que a qtde faturada, caso o item esteja faturado.
            */
            If Type("lMarkAll") <> "L"
               If EES->(dbSeek(xFilial()+AVKey(M->EEC_PREEMB, "EES_PREEMB")))
                  While EES->(!Eof() .and. EES_FILIAL == xFilial() .and. EES_PREEMB == AVKey(M->EEC_PREEMB, "EES_PREEMB"))
                     If EES->(EES_PEDIDO == M->EE9_PEDIDO .and. EES_SEQUEN == M->EE9_SEQUEN) .And. M->EE9_NF == EES->EES_NRNF .And. M->EE9_SERIE == EES->EES_SERIE
                        If EES->(FieldPos("EES_QTDDEV")) > 0 .and. EES->(FieldPos("EES_VALDEV")) > 0
                           If M->EE9_SLDINI < (EES->EES_QTDE - EES->EES_QTDDEV)
                              EasyHelp(STR0071+" ("+AllTrim(Transform((EES->EES_QTDE - EES->EES_QTDDEV), AVSX3("EES_QTDE", AV_PICTURE)))+").", STR0058) //"A qtde. informada não pode ser menor que a qtde faturada"###"Atenção"
                              lRet := .F.
                              Break
                           EndIf
                        EndIf
                     EndIf
                     EES->(dbSkip())
                  End
               Else
                  /*
                  ER - 15/03/2007 - Na inclusão o EES ainda não foi gravado, por isso verifica no SD2.
                  */
                  If lIntegra
                     nRecEE8 := EE8->(RecNo())
                     EE8->(DbSetOrder(1))
                     If EE8->(DbSeek(xFilial("EE8")+WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN))
                        cFatIt := EE8->EE8_FATIT
                     EndIf
                     EE8->(DbGoTo(nRecEE8))

                     //Verifica se Existe quantidade devolvida.
                     SD2->(DbSetOrder(3))
                     If SD2->(DbSeek(xFilial("SD2")+WorkIp->EE9_NF+WorkIp->EE9_SERIE))
                        While SD2->(!EOF()) .and. SD2->(D2_FILIAL + D2_DOC + D2_SERIE) == xFilial("SD2")+WorkIp->EE9_NF+WorkIp->EE9_SERIE
                           If SD2->D2_ITEM == cFatIt
                              If M->EE9_SLDINI < (SD2->D2_QUANT - SD2->D2_QTDEDEV)
                                 EasyHelp(STR0071+" ("+AllTrim(Transform((SD2->D2_QUANT - SD2->D2_QTDEDEV), AVSX3("EES_QTDE", AV_PICTURE)))+").", STR0058) //"A qtde. informada não pode ser menor que a qtde faturada"###"Atenção"
                                 lRet := .F.
                                 Break
                              EndIf
                              Exit
                           EndIf
                           SD2->(DbSkip())
                        EndDo
                      EndIf
                  EndIf
               EndIf
            EndIf

            IF !EMPTY(M->EE9_QE)
               IF (M->EE9_SLDINI % M->EE9_QE) != 0
                  IF Type("lMarkAll") <> "L" .And. (Type("lAe100Auto") <> "L" .Or. !lAe100Auto)
                     HELP(" ",1,"AVG0000637") //("Quantidade informada não e multipla pela quantidade na Embalagem !","Aviso")
                  Endif
                  //lRet := .F.
                  //Break MFR 07/06/2021 OSSME-5869, como é só um aviso, deve seguir com as demais regras de negócio.
                  //        No caso deste chamado não estava recalculando os valores do rodapé do item
               Endif
            Endif

            //If lConsign //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
               If (Empty(cTipoProc) .Or. cTipoProc == PC_RC) .And. !Empty(M->EE9_RE)
                  If WkEY6->(DbSeek(M->EE9_RE))
                     If AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, (M->EE9_SLDINI - WorkIp->EE9_SLDINI), .F.) > WkEY6->EY6_SLDATU
                        EasyHelp(STR0112, STR0048)//"Não é possível selecionar a quantidade informada porque o RE vinculado ao item não possui saldo disponível"###"Atenção"
                        lRet := .F.
                        Break
                     EndIf
                  Else
                     EY6->(DbSetOrder(2))
                     If EY6->(DbSeek(xFilial()+M->EE9_RE))
                        If AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, (M->EE9_SLDINI - WorkIp->EE9_SLDINI), .F.) > WkEY6->EY6_SLDATU
                           EasyHelp(STR0112, STR0048)//"Não é possível selecionar a quantidade informada porque o RE vinculado ao item não possui saldo disponível"###"Atenção"
                           lRet := .F.
                           Break
                        EndIf
                        WkEY6->(RecLock("WkEY6", .T.))
                        AvReplace("EY6", "WkEY6")
                        WkEY6->EY6_SLDATU -= AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, (M->EE9_SLDINI - WorkIp->EE9_SLDINI), .F.) //MCF - 17/05/2016
                        WkEY6->WK_QTDVIN += AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, (M->EE9_SLDINI - WorkIp->EE9_SLDINI), .F.)

                        EER->(DbSetOrder(3))
                        If EER->(DbSeek(xFilial()+Left(M->EE9_RE, 9))) .And. EER->EER_MANUAL == "S"
                           WkEY6->WK_ALTIPO := "1"
                        EndIf
                        WkEY6->(MsUnlock())
                     EndIf
                  EndIf
                  //MCF - 17/05/2016 - Antes era permitido a inserção de qualquer RE, agora o sistema realiza a validação na EY6. Para cenários
                  //que o número da RE informado não existia na tabela, o sistema apresentava erro.
                  //WkEY6->EY6_SLDATU -= AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, (M->EE9_SLDINI - WorkIp->EE9_SLDINI), .F.)//LRS - 13/11/2015 - Nopado pois o resultado não é esperado pela work > WkEY6->EY6_SLDATU
                  //WkEY6->WK_QTDVIN += AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, (M->EE9_SLDINI - WorkIp->EE9_SLDINI), .F.)//LRS - 13/11/2015 - Nopado pois o resultado não é esperado pela work > WkEY6->EY6_SLDATU
                  //EER->(DbSetOrder(3))
                  //If EER->(DbSeek(xFilial()+Left(M->EE9_RE, 9))) .And. EER->EER_MANUAL == "S"
                     //WkEY6->WK_ALTIPO := "1"
                  //EndIf
               EndIf
               If cTipoProc $ PC_VR+PC_VB
                  If M->EE9_SLDINI <> WorkIp->EE9_SLDINI
                     If WorkIp->WK_QTDREM > M->EE9_SLDINI
                        EasyHelp(STR0115, STR0048)//"A quantidade informada é inferior a quantidade já vinculada com remessas. Não será possível prosseguir."##"Atenção"
                        lRet := .F.
                     EndIf
                  EndIf
               EndIf
            //EndIf

            If EECFlags("ESTUFAGEM") .And. M->EE9_SLDINI <> WorkIp->EE9_SLDINI .And. !lItEstufado
               If aScan(aAtuEstufagem, WorkIp->EE9_SEQEMB) == 0
                  aAdd(aAtuEstufagem, WorkIp->EE9_SEQEMB)
               EndIf
            EndIf

            AE100CALC("PRECOS")
            IF !EMPTY(M->EE9_QE)
               IF (M->EE9_SLDINI % M->EE9_QE) == 0
                   //DFS - 28/11/12 - Retirado a função Int, para que, sistema não calcule erroneamente (arredondando para menos) a quantidade de embalagem.
                   M->EE9_QTDEM1 := M->EE9_SLDINI/M->EE9_QE //QUANT.DE EMBAL.
               Else
                   M->EE9_QTDEM1 := Int(M->EE9_SLDINI/M->EE9_QE)+1 //QUANT.DE EMBAL.
               ENDIF
            Endif

            AE100CALC("EMBALA")
            AE100CALC("CALCEMB")
            AE100CALC("PESOS",,cCampo)

        CASE cCAMPO="EE9_EMBAL1"
           AE100CALC("CALCEMB")
           AE100CALC("PESOS",,cCampo)
        CASE cCAMPO="EE9_PSLQUN"
           AE100CALC("PESOS",,cCampo)
        CASE cCAMPO="EE9_QTDEM1"
           // GFP - 21/07/2012 - Inclusão de calculo de Quantidade na embalagem
          IF !EMPTY(M->EE9_QTDEM1)
            //MFR 06/09/2021 OSSME-6137 Não estava calculando quando a divisão não é exata
              M->EE9_QE := Round(M->EE9_SLDINI/M->EE9_QTDEM1,AVSX3("EE9_QE",4)) //QUANT.NA EMBAL.            
          Endif
           AE100CALC("EMBALA")
           AE100CALC("PESOS",,cCampo)
        CASE cCAMPO="EE9_QE"

            IF !EMPTY(M->EE9_QE)
               IF (M->EE9_SLDINI % M->EE9_QE) != 0
                  M->EE9_QTDEM1 := Int(M->EE9_SLDINI/M->EE9_QE)+1 //QUANT.DE EMBAL.
                  IF Type("lMarkAll") <> "L" .And. (Type("lAe100Auto") <> "L" .Or. !lAe100Auto)
                     HELP(" ",1,"AVG0000637") //("Quantidade informada não e multipla pela quantidade na Embalagem !","Aviso")
                  Endif
                  //lRet := .F.
                  Break
               Else   
                  M->EE9_QTDEM1 := M->EE9_SLDINI/M->EE9_QE //QUANT.DE EMBAL.
               Endif
            Endif

            AE100CALC("EMBALA")

        CASE cCAMPO="EE9_PSBRUN"
           AE100CALC("PESOS",,cCampo)

        CASE cCAMPO="EE9_DTPREM"
            IF M->EE9_DTPREM < dDataBase
               HELP(" ",1,"AVG0000638") //("Data de Previsão de Embarque deve ser maior que a data atual !","Aviso")
               lRet := .F.
               Break
            Endif

        CASE cCAMPO="EE9_DTENTR"
            IF M->EE9_DTENTR < dDataBase
               HELP(" ",1,"AVG0000639") //("Data de Entrega deve ser maior que a data atual !","Aviso")
               lRet := .F.
               Break
            Endif
        //DFS - 13/12/12 - Inclusão de tratamento para que, preencha automaticamente o campo Destaque da NCM. Caso não encontre, apresenta mensagem.
        CASE cCAMPO="EE9_DTQNCM"
            If !Empty(M->EE9_DTQNCM) .AND. !SYD->( dbSetOrder(3) , dbseek(xFilial("SYD")+M->EE9_POSIPI)) .and. !(alltrim(M->EE9_DTQNCM) $ SYD->YD_DESTAQU)
               EasyHelp(STR0137,STR0039) //"O Destaque informado não está cadastrado na tabela 'SYD - Cadastro de NCM'. Favor informar um Destaque correto para a NCM selecionada.", "Atenção"
               lRet := .F.
               Break
            EndIf

       Case cCampo == "EE9_VLCOM"  //LRS - 27/11/2014 - Validação para pegar a porcentagem calculada de acordo com o valor digitado
	           IF M->EE9_PRCINC == 0
	              nTotFob := M->EE9_SLDINI * M->EE9_PRECOI
	           Else
	              nTotFob := M->EE9_PRCINC
	           EndIF
	           IF M->EE9_VLCOM > nTotFob
	  	          EasyHelp(STR0108,STR0051) //Valor da comissão maior que o valor total do item ## Atenção
	  	          lRet := .F.
	  	       Else
	  	          M->EE9_PERCOM:= Round(((M->EE9_VLCOM/nTotFob)*100),2)
	          EndIF

       Case cCampo == "EE9_PERCOM"  //LRS - 27/11/2014 - Validação para pegar a porcentagem calculada de acordo com o valor digitado
	           IF M->EE9_PRCINC == 0
	              nTotFob := M->EE9_SLDINI * M->EE9_PRECOI
	           Else
	              nTotFob := M->EE9_PRCINC
	           EndIF

	           IF M->EE9_PERCOM > 0
	  	          M->EE9_VLCOM:= Round(nTotFob*(M->EE9_PERCOM/100),AVSX3("EE9_VLCOM",AV_DECIMAL))
	           EndIF


     EndCASE
   EndSequence

   AE100DetTela(.F.)

   RestOrd(aSaveOrd, .T.)
RETURN lRET

/*
Programa        : EECAE102.PRW
Objetivo        : Gerar total fob e cif da tela de item do embarque
Autor           : Mauricio Frison
Data/Hora       : 14/12/2021
Obs.            :
*/
FUNCTION AE102GerTotIt()
Local nVlrTotal //Variável qeu irá conter o frete, seguro, despesas e desconto a ser considerado no valor Cif
Local nArredUnit := EasyGParam("MV_AVG0109",, 4)
Local nArredTot  := EasyGParam("MV_AVG0110",, 2)   
Local nCount := 2 //deixamos fixo 2, pois só interessa o rateio pra o item em questão
                  //2 para que não aplique o ajuste de diferença no próprio item, invalidando assim o rateio
Local nDespIt,nFrtIt,nDescIt
Local aDespesas := X3DIReturn(OC_EM)
Local nFrtCapa := M->EEC_FRPREV + M->EEC_FRPCOM

nVlrTotal:=0

   //MFR 14/12/2021 OSSME-6434
   //M->EE9_PRCINC := Round(M->EE9_PRECO * M->EE9_SLDINI,nArredTot) //Valor Fob
   //M->EE9_PRCTOT := Round(M->EE9_PRECO * M->EE9_SLDINI,nArredTot) //Valor Cif

   nVltotIt := (AvTransUnid(M->EE9_UNIDAD,M->EE9_UNPRC,M->EE9_COD_I,M->EE9_SLDINI,.F.); //Apura Valor Total do item
               *Round(M->EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL)))
   //MFR 14/12/2021 OSSME-6434 colocado abaixo da linha da conversão da unidade de medida   
   M->EE9_PRCINC := Round(nVltotIt,nArredTot) //Valor Fob
   M->EE9_PRCTOT := Round(nVltotIt,nArredTot) //Valor Cif                    

   nQtdeAntIt := Workip->wp_oldini
   If  nQtdeAntIt == 0 //se a qtde ANTERIOR é zero entao está incluindo, usa a qde da ee8 que é qtde inicial da tela                       
         nPrcTotCapa :=  M->EEC_TOTFOB - (WorkIp->EE9_PRECO * workip->wp_sldatu) + nVltotIt        // Apura o novo valor total do processo               
   Else // é alteração, neste caso usa a qde ANTERIOR, pq. eu posso ter alterado várias vezes a qtde da tela sem fazer gravação final
         nPrcTotCapa := M->EEC_TOTFOB - (WorkIp->EE9_PRECO * nQtdeAntIt) + nVltotIt        // Apura o valor novo total do processo               
   EndIf    

   nDespIt := AP100getDesp(aDespesas,nPrcTotCapa,nVltotIt,nCount,nArredUnit)
   nFrtIt  := AP100getFrt(nPrcTotCapa,nVltotIt,nCount,nArredUnit,nFrtCapa,M->EEC_PESLIQ,M->EE9_PSLQTO,M->EEC_PESBRU,M->EE9_PSBRTO)
   nDescIt := AP100getD(nPrcTotCapa,nVltotIt,nCount,nArredUnit,"M->EEC")

   nVlrTotal+= nDespIt + nFrtIt - nDescIt
   // Apura os valores finais para o valor fob e incoterm
   If nVlrTotal > 0
      IF M->EEC_PRECOA $ cSim
         M->EE9_PRCTOT+= nVlrTotal  //Valor incoterm
      Else
         M->EE9_PRCINC-= nVlrTotal //Valor Fob
         M->EE9_PRECOI := Round(M->EE9_PRCINC / M->EE9_SLDINI,nArredUnit)
      Endif
   EndIf   
 Return M->EE9_PRCINC


/*
    Funcao   : AE100CALC(cCAMPO)
    Autor    : Heder M Oliveira
    Data     : 03/08/99 16:20
    Revisao  : 03/08/99 16:20
    Uso      : Calcular pesos e precos
    Recebe   :
    Retorna  :
*/
FUNCTION AE100CALC(cCAMPO,lOk,cCpo)
   Local lRET:=.T.

   //Local lPesoManual := .f. WFS 02/04/09 077374
   Local lBrutoXQtde := .f.
   Local lRetPto     := .t.          // By JPP -  22/06/2005 -14:15
   Local lLoop, i
   Local cLastEmb    := ""

   //Local nQtdEmb    := 0       //NCF - 08/05/2015
   //Local nPesEmb    := 0
   Local nQuant     := 0
   Local nQe        := 0
   //Local cEmbalagem := 0
   Local aOrdEmbs   := {}        //NCF - 08/05/2015

   Private lPesoManual := .f. //WFS 02/04/09 077374
   Private nQtdEmb     := 0   //NCF - 08/05/2015
   Private nPesEmb     := 0
   Private cEmbalagem  := ""
   Private nQtdeEmbInt := 0

   Default lOk  := .f.
   Default cCpo := "" //JPM - 23/02/06
   //WFS 22/04/09 - Para verificar se houve alteração na unidade de medida da capa do processo
   Static cOldUn:= ""

   DO CASE
      CASE cCAMPO=="PRECOS"
           AE102GerTotIt()
         
      CASE cCAMPO=="PESOS_TRB"
           M->EE9_SLDINI := EE9->EE9_SLDINI
           M->EE9_PSLQUN := EE9->EE9_PSLQUN
           M->EE9_QTDEM1 := EE9->EE9_QTDEM1
           M->EE9_EMBAL1 := EE9->EE9_EMBAL1
           M->EE9_SEQEMB := EE9->EE9_SEQEMB
           M->EE9_QE     := EE9->EE9_QE
           M->EE9_PSLQTO := EE9->EE9_PSLQTO
           M->EE9_PSBRUN := EE9->EE9_PSBRUN
           M->EE9_PSBRTO := EE9->EE9_PSBRTO

           AE100CALC("PESOS")

           WorkIP->EE9_PSLQTO := M->EE9_PSLQTO
           WorkIP->EE9_PSBRUN := M->EE9_PSBRUN
           WorkIP->EE9_PSBRTO := M->EE9_PSBRTO

      CASE cCAMPO=="PESOS" //CALCULO DE PESO LIQUIDOS E BRUTOS

           // Digitação de peso total por linha
           lPesoManual := GetNewPar("MV_AVG0009",.F.) .Or. (SB1->(FieldPos("B1_REPOSIC")) > 0 .AND. Posicione("SB1",1,xFilial("SB1")+M->EE9_COD_I,"B1_REPOSIC") $cSim)

           // ** JPM - 23/02/06 - Quando um dos pesos totais não estiver preenchido, então o sistema deve recalcular.
           If lPesoManual .And. (Empty(M->EE9_PSLQTO) .Or. Empty(M->EE9_PSBRTO))
              lPesoManual := .F.
           EndIf

           // ** JPM - 23/02/06 - Quando o usuário digitar os seguintes campos, deve forçar o recálculo dos pesos totais
           If lPesoManual .And. cCpo $ "EE9_SLDINI/EE9_EMBAL1/EE9_PSLQUN/EE9_QTDEM1/EE9_PSBRUN/"
              lPesoManual := .F.
           EndIf

           If Type("lArtificial") = "L"// chamada das rotinas da MsGetDb
              lLoop := !lArtificial .And. lConsolida
           Else
              lLoop := .f.
           EndIf

           If lLoop
              i := 1
           EndIf

           While If(lLoop, i <= Len(aColsAtu),.t.)

              If lLoop
                 If Empty(Ae104AuxFieldPutGet(,"WP_FLAG",,i,,.f.))
                    i++
                    Loop
                 EndIf
                 Ae104AuxIt(2,cFilBr,.f.,i,,) // simula variáveis de memória de acordo com o aCols da GetDados
              EndIf

              // Digitação de peso total por linha
              lPesoManual := GetNewPar("MV_AVG0009",.F.) .Or. (SB1->(FieldPos("B1_REPOSIC")) > 0 .AND. Posicione("SB1",1,xFilial("SB1")+M->EE9_COD_I,"B1_REPOSIC") $cSim)
              // Calcula Peso Bruto Total = Qtde*Peso Bruto Unit.
              lBrutoXQtde := EasyGParam("MV_AVG0063",,.F.)

              If EasyEntryPoint("EECAE102") // By JPP - 22/06/05 - 14:15 - Inclusão do ponto de entrada
                 lRetPto := ExecBlock("EECAE102",.f.,.f.,"EM_PESOS")
                 If ValType(lRetPto) <> "L"
                    lRetPto := .t.
                 EndIf
              EndIf
              //WFS 22/04/09 ---
              //Quando carrega a primeira vez, os conteúdos da Work e da Memória são os mesmos.
              If WorkIp->EE9_UNPES == M->EE9_UNPES
                 cOldUn:= M->EE9_UNPES
              EndIf
              //Se estiver em branco, assume o padrão do sistema (kg).
              If Empty(cOldUn)
                 cOldUn:= "KG"
              EndIf
              //Verifica se a conversão de unidade de medida está cadastrada
              If AvTransUnid(cOldUn, M->EE9_UNPES, M->EE9_COD_I, M->EE9_PSLQUN, .T.) == Nil
                 EasyHelp(STR0127 + AllTrim(cOldUn) + STR0128 + AllTrim(M->EE9_UNPES) + STR0129 + ENTER +; //	STR0127	"A conversão de " //	STR0128	" para " //STR0129	" não está cadastrada."
                         STR0130, STR0058) //Atenção //STR0130	"Acesse Atualizações/ Tabelas Siscomex para realizar o cadastro."
                 M->EE9_UNPES:= cOldUn
                 Break
              Else
                 cOldUn:= M->EE9_UNPES
              EndIf
              //Conversão para kg. Após os cálculos, retorna para a unidade escolhida para o processo
              M->EE9_PSLQUN:= AvTransUnid(If(ValType(M->EE9_UNPES) == "C", M->EE9_UNPES, WorkIp->EE9_UNPES), "KG", If(ValType(M->EE9_COD_I) == "C", M->EE9_COD_I, WorkIp->EE9_COD_I), M->EE9_PSLQUN, .F.)
              //---

              IF ! lPesoManual .And. ! lOk
                 //CALCULO DE PESO LIQUIDO
                 M->EE9_PSLQTO:=M->EE9_SLDINI*M->EE9_PSLQUN //PESO LIQUIDO TOTAL
              Endif
              If lRetPto // By JPP - 22/06/05 - 14:15 - Se for falso não calcula os pesos brutos.
                 IF !lBrutoXQtde .And. M->EEC_BRUEMB $ cSim
                    //CALCULAR PESOS BRUTOS
                    EE5->(dbSetOrder(1))
                    EE5->(dbSeek(XFILIAL("EE5")+M->EE9_EMBAL1))
                    M->EE9_PSBRUN:=(M->EE9_PSLQUN*M->EE9_QE)+EE5->EE5_PESO //PESO BRUTO UNITARIO

                    IF !lPesoManual .And. !lOk
                       nQuant     := M->EE9_SLDINI
                       nQe        := M->EE9_QE
                       cEmbalagem := M->EE9_EMBAL1

                       If nQuant <= nQe .Or. nQe == 0
                          nQtdEmb := 1
                       Else
                          If (nQuant % nQe) > 0
                             nQtdEmb := Int(nQuant / nQe) + 1
                          Else
                             nQtdEmb := nQuant / nQe
                          EndIf
                       EndIf

                       nPesEmb := nQtdEmb * EE5->EE5_PESO
                       nQtdeEmbInt:= nQtdEmb
                       cEmbalagem := M->EE9_EMBAL1
                       aOrdEmbs := SaveOrd({"EE5","EEK"})
                       //Cálculo para Embalagens Múltiplas.
                       EEK->(DbSetOrder(1))
                       If EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagem))
                           Do While EEK->(!Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
                                                       EEK->EEK_TIPO   == OC_EMBA .And.;
                                                       EEK->EEK_CODIGO == cEmbalagem

                              If EE5->(DbSeek(xFilial("EE5")+EEK->EEK_EMB))

                                 If nQtdEmb <= EEK->EEK_QTDE
                                    nQtdEmb := 1
                                 Else
                                    If (nQtdEmb % EEK->EEK_QTDE) > 0
                                       nQtdEmb := Int(nQtdEmb / EEK->EEK_QTDE) + 1
                                    Else
                                       nQtdEmb := nQtdEmb / EEK->EEK_QTDE
                                    EndIf
                                 EndIf

                                 nPesEmb += (EE5->EE5_PESO*nQtdEmb) //WFS 22/04/09 estava nopado; tratamento de conversão no início e fim da transação
                                 //nPesEmb += (AvTransUnid(If(Type("M->EE9_UNPES") == "C", M->EE9_UNPES, WorkIp->EE9_UNPES), "KG", If(Type("M->EE9_COD_I") == "C", M->EE9_COD_I, WorkIp->EE9_COD_I), EE5->EE5_PESO, .F.)*nQtdEmb) nopado por WFS 22/04/09
                                 cLastEmb := EEK->EEK_EMB
                              EndIf

                              EEK->(DbSkip())

                              // quando o código for diferente é que passou pelo último resgistro e caso já tenha passado não passa de novo
                              If !AvFlags("EEC_LOGIX") .And. EEK->EEK_CODIGO <> cEmbalagem
                                 If !EEK->(DBSeek(xFilial("EEK") + OC_EMBA + cLastEmb))
                                    Exit
                                 else
                                    cEmbalagem:= cLastEmb // depois de posicionar cEnbalagem recebe o último registro para fazer o loop novamente
                                 EndIf
                              EndIf

                           EndDo
                       EndIf
                       cEmbalagem := M->EE9_EMBAL1                //NCF - 08/05/2015 - Reapura embalagem interna para utilização em ponto de entrada
                       RestOrd(aOrdEmbs,.T.)                      //NCF - 08/05/2015 - Restarura ordem e recupera registros para reapuração de peso no ponto de entrada

                       If EasyEntryPoint("EECAE102")
                          ExecBlock("EECAE102",.F.,.F.,"CALC_EMB_MULTIPLA")
                       EndIf

                       M->EE9_PSBRTO := M->EE9_PSLQTO + nPesEmb
                    EndIf

                 ELSE
                    //AMS - 23/09/2003 às 17:05. Alteração do calculo para obter o peso bruto total.
                    //TRP - 23/07/2012 - O sistema só deve considerar o Peso Líquido Unitário para carregar o campo Peso Bruto Unitário quando o mesmo estiver vazio.
                    //Inclusão de tratamento considerando o conteúdo do campo EEC_BRUEMB
                    M->EE9_PSBRUN := IF(EMPTY(M->EE9_PSBRUN),M->EE9_PSLQUN,M->EE9_PSBRUN)

                    IF !lPesoManual .And. !lOk
                       IF lBrutoXQtde
                          //Inclusão de tratamento considerando o conteúdo do campo EEC_BRUEMB
                          M->EE9_PSBRTO := M->EE9_SLDINI*M->EE9_PSBRUN
                       Else
                          M->EE9_PSBRTO := M->EE9_QTDEM1*M->EE9_PSBRUN
                       Endif
                    Endif
                 Endif
                 //WFS 22/04/09 ---
                 //Após a realização dos cálculos, converter para a unidade real do processo.
                 M->EE9_PSLQUN:= AvTransUnid("KG", If(ValType(M->EE9_UNPES) == "C", M->EE9_UNPES, WorkIp->EE9_UNPES), If(ValType(M->EE9_COD_I) == "C", M->EE9_COD_I, WorkIp->EE9_COD_I), M->EE9_PSLQUN, .F.)
                 M->EE9_PSBRUN:= AvTransUnid("KG", If(ValType(M->EE9_UNPES) == "C", M->EE9_UNPES, WorkIp->EE9_UNPES), If(ValType(M->EE9_COD_I) == "C", M->EE9_COD_I, WorkIp->EE9_COD_I), M->EE9_PSBRUN, .F.)
                 M->EE9_PSLQTO:= AvTransUnid("KG", If(ValType(M->EE9_UNPES) == "C", M->EE9_UNPES, WorkIp->EE9_UNPES), If(ValType(M->EE9_COD_I) == "C", M->EE9_COD_I, WorkIp->EE9_COD_I), M->EE9_PSLQTO, .F.)
                 M->EE9_PSBRTO:= AvTransUnid("KG", If(ValType(M->EE9_UNPES) == "C", M->EE9_UNPES, WorkIp->EE9_UNPES), If(ValType(M->EE9_COD_I) == "C", M->EE9_COD_I, WorkIp->EE9_COD_I), M->EE9_PSBRTO, .F.)
              EndIf

              If lLoop // executa gatilhos e restaura variáveis de memória.
                 Ae104AuxIt(3, cFilBr,.f.,i,.t.,)
                 i++
              Else
                 Exit
              EndIf

           EndDo

           If lLoop // totaliza valores
              Ae104AuxIt(7,,.f.,,,.t.)
           EndIf

      CASE cCAMPO=="EMBALA"
           CalcEmbalagem()

      CASE cCAMPO=="CALCEMB"
           // Chamado pelo EECAE102.PRW e pelo SX7
           AE100WkEmb(M->EEC_PREEMB,M->EE9_SEQEMB,M->EE9_EMBAL1,M->EE9_PEDIDO,M->EE9_SEQUEN)
   EndCASE

   lREFRESH:=.T.

RETURN lRET

/*
    Funcao   : CALCEMBALAGEM
    Autor    : Cristiano A Ferreira
    Data     : 03/08/99 16:30
    Revisao  : Heder M Oliveira 03/08/99 16:30
    Uso      : calculcar n.embalagens
    Recebe   :
    Retorna  :

*/
STATIC FUNCTION CalcEmbalagem()

   Local aOrd := SaveOrd({"WorkEm","EEK"})
   Local nQtdeEmb := M->EE9_QTDEM1

   EEK->(dbSetOrder(1))

   WorkEm->(dbSetOrder(1))
   WorkEm->(dbSeek(M->EEC_PREEMB+M->EE9_SEQEMB+M->EE9_EMBAL1))

   IF !IsMemVar("lMarkAll") //LRS - 18/04/2018
      lMarkAll:= Nil
   EndIf

   While !WorkEm->(Eof()) .And. WorkEm->(EEK_PEDIDO+EEK_SEQUEN+EEK_CODIGO) ==;
                                 M->EEC_PREEMB+M->EE9_SEQEMB+M->EE9_EMBAL1

      IF EEK->(dbSeek(xFilial("EEK")+OC_EMBA+WorkEm->EEK_CODIGO+WorkEm->EEK_SEQ))
         IF ( nQtdeEmb % EEK->EEK_QTDE ) != 0
            IF ValType(lMarkAll) <> "L" .And. (Type("lAe100Auto") <> "L" .Or. !lAe100Auto)
               //MsgStop(STR0037+AllTrim(WorkEm->EEK_EMB)+STR0038,STR0039) //"Embalagem "###" com espaço livre !"###"Aviso"
                    MsgInfo(STR0147 + " '" +; //"A embalagem Cod.:"
                            AllTrim(WorkEm->EEK_EMB) + "' " + STR0005 + ": " +; //"Descrição"
                            "'" + Alltrim(Posicione("EE5", 1, xFilial("EE5")+WorkEm->EEK_EMB, "EE5_DESC")) + "' "+;
                            STR0148 + ENTER + STR0149,; //"possui espaço livre." "Avalie se a distribuição de embalagens está correta."
                            STR0039) //"Aviso"
            Endif
            WorkEm->EEK_QTDE := Int(nQtdeEmb/EEK->EEK_QTDE)+1
         Else
            WorkEm->EEK_QTDE := nQtdeEmb/EEK->EEK_QTDE
         Endif

         nQtdeEmb := WorkEm->EEK_QTDE
      Endif
      WorkEm->(dbSkip())
   Enddo

   RestOrd(aOrd)

Return NIL

/*
    Funcao   : AE100CRIT(cCAMPO)
    Autor    : Heder M Oliveira
    Data     : 04/08/99 11:21
    Revisao  : 04/08/99 11:21
    Uso      : Criticar campos na inclusao / alteracao
    Recebe   :
    Retorna  :
    Obs.     : GCC  13/05/2013 - Implementado a validação dos campos EEC_EMBARC e EEC_VIAGEM
    		   WFS 28/07/2009 - implementado o cálculo direto do valor FOB para preço aberto
                                (percentual de seguro x valor).
*/
FUNCTION AE100CRIT(cCAMPO,lMENSA,lRecalc)
   Local lNFPosEm := EasyGParam("MV_NFDTC",,.F.) //Alcir Alves - 30-08-05 - Nf após embarque - 30-08-05
   Local lRet:=.T.,cOldArea:=select(), cSeek := "", nRec, nTaxa1, nTaxa2
   Local aORD:=SAVEORD({"SY9","EE1","EE9","EEC","EE5"})
   Local nOrdEE1,nTotal := 0, nVar := 0
   Local bTotal := {|| nTotal += WORKIP->EE9_PRCINC}
   Local nTotalNF := 0
   Local nRecNo, bFor,nFob:=0
   LOCAL nA,nB,nC,nD
   Local cMsg, nTotPedReais, nTotPed, nSldLC, nSldLCReais, nTotPedAnt
   Local lEmbFaturado := .T.
   Local lSemB2B := .t.
   Local nTotDSE := 0
   Local nAdiant := 0 //TRP-24/07/08
   Local nTaxaSeguro := EasyGParam("MV_AVG0124",,10)
   Local cCobCam := "" , lSeekAnt := .F. //AOM - 04/07/2011 - Verifica se a cond. pagto esta com cobertura Cambial

   Local lVldEmb := EasyGParam("MV_EEC0010", , .F.) // GCC - 13/05/2013 - Verifica se o conteúdo do campo embarcação será validado
   Local lVldVia := EasyGParam("MV_EEC0011", , .F.) // GCC - 13/05/2013 - Verifica se o conteúdo do campo Nr. Voo / Viagens será validado
   Local nVlComiss:=0
   If ValType("nTotPesBru") == "U"  // GFP - 21/01/2014
      nTotPesBru := 0
   EndIf
   If ValType("nPesBrEmb") == "U"  // GFP - 21/01/2014
      nPesBrEmb := 0
   EndIf
   Private lExistTpDesc := If(EE7->(FieldPos("EE7_TPDESC")) > 0 .OR. EEC->(FieldPos("EEC_TPDESC")) > 0,.T.,.F.)  // GFP - 04/02/2014
   Private lGerAdEEC := .F.
   If EasyGParam("MV_EFF0006",.T.)
      lGerAdEEC := EasyGParam("MV_EFF0006",,.F.)
   EndIf

   DEFAULT lMENSA:=.T., cCAMPO := " "
   Default lRecalc := .T. 
   //MFR 10/02/2020 OSSME-5267
   if lMensa .And. IsMemVar("lAE100Auto")
      lMensa := !lAE100Auto
   EndIf
   If Type("lAltValPosEmb") == "U"
      lAltValPosEmb := EasyGParam("MV_AVG0081",,.F.)
   EndIf

   Begin Sequence
      DO CASE
         CASE cCAMPO == "EEC_AMOSTR"
            cOpcao := AP102CboxAmo("M->EEC_AMOSTR")  // GFP - 03/11/2015
            IF (cOpcao <> "2")  // GFP - 03/11/2015
               M->EEC_STATUS :=ST_AE //AGUARDANDO EMBARQUE
               DSCSITEE7(,OC_EM)
               lREFRESH:=.T.
            ENDIF

         Case cCampo == "EEC_FRPREV"  //necessario lancar frete
             SYJ->(dbSetOrder(1))
             SYJ->(dbSeek(XFILIAL("SYJ")+M->EEC_INCOTE))
             If SYJ->YJ_CLFRETE $ cSim .and. M->EEC_FRPREV==0
                lRet:=.T.
               IF ( lMENSA )
                  HELP(" ",1,"AVG0000066",,STR0040,2,1) //"FRETE"
               ENDIF
                If !lAltValPosEmb
                   lRet:= .F.
                EndIf
             ElseIf SYJ->YJ_CLFRETE $ cNao .AND. M->EEC_FRPREV # 0
                lRet:=.F.
                M->EEC_FRPREV:=0
                HELP(" ",1,"AVG0000067",,STR0040,2,1) //"FRETE"
             Endif
             If lRet .and. EECFlags("FRESEGCOM")
                lRet := DespIntVld()
             EndIf

         Case cCampo == "EEC_SEGPRE" .OR. cCampo == "EEC_SEGURO" .OR. cCampo == "EEC_PRECOA" //necessario lancar seguro    
            if cCampo == "EEC_PRECOA"
               EECTotCom(OC_EM,, .T.)
            EndIf        
            SYJ->(dbSetOrder(1))
            SYJ->(dbSeek(XFILIAL("SYJ")+M->EEC_INCOTE))

            nTaxaSeguro := 1 + (nTaxaSeguro / 100)             
            IF ( M->EEC_SEGURO # 0 )
               IF M->EEC_PRECOA $ cSim
                  nRecNo := WorkIP->(RecNo())
                  bFor   := {|| WorkIP->WP_FLAG <> "  " }
                  WorkIP->(dbGoTop())
                  WorkIP->(dbEval(bTotal,bFor))
                  WorkIP->(dbGoTo(nRecNo))
                  ///M->EEC_SEGPRE:=(M->EEC_SEGURO/100)*NTOTAL

                  IF EEC->(FieldPos("EEC_DESSEG")) > 0 .And. M->EEC_DESSEG == "1" //LRS - 11/09/2015
                     nA            := nTOTAL+M->EEC_FRPREV - M->EEC_DESCON
                  ELSE
                     nA            := nTOTAL+M->EEC_FRPREV
                  ENDIF

                  nB            := (M->EEC_SEGURO/100) * nTaxaSeguro
                  nC            := 1 - nB
                  nD            := nA / nC

                  If EasyGParam("MV_AVG0183", .F., .F.) //habilita o cálculo direto do seguro previsto (total x percentual do seguro)
                     //WFS 28/07/2009 - Alterado como melhoria, conforme chamado 077797.
                     M->EEC_SEGPRE := ROUND(nA * nB,AVSX3("EEC_SEGPRE",AV_DECIMAL))
                  Else
                     M->EEC_SEGPRE := ROUND(nD-nA,AVSX3("EEC_SEGPRE",AV_DECIMAL))
                  EndIf
               Else
                  M->EEC_SEGPRE := ROUND(M->EEC_TOTPED*nTaxaSeguro*(M->EEC_SEGURO/100),AVSX3("EEC_SEGPRE",AV_DECIMAL))
               Endif
            ENDIF

            If SYJ->YJ_CLSEGUR $ cSim .and. (M->EEC_SEGPRE == 0 .AND. M->EEC_SEGURO == 0)
               lRet:=.T.
               IF ( lMENSA ) .and. cCampo == "EEC_SEGPRE"
                  EECHelp(" ",1,"AVG0000066",,,STR0041,2,1) //"SEGURO"
               ENDIF
               //WFS 26/05/2010
               If !lAltValPosEmb
                  lRet:= .F.
               EndIf
            ElseIf SYJ->YJ_CLSEGUR $ cNao .AND. (M->EEC_SEGPRE # 0 .OR. M->EEC_SEGURO # 0)
               lRet:=.F.
               M->EEC_SEGPRE:=0
               M->EEC_SEGURO:=0
               IF ( lMENSA ) .and. cCampo == "EEC_SEGPRE"
                  EECHelp(" ",1,"AVG0000067",,,STR0041,2,1) //"SEGURO"
               ENDIF
            Endif

             /*
             Imposto chamada para a função DespIntVld(), passando como parametro o campo "EEC_SEGPRE"
             onde irá calcular a paridade para a Despesas Internacionais.
             Autor       : Alexsander Martins dos Santos
             Data e Hora : 23/09/2004 às 09:55.
             */
             If lRet .and. EECFlags("COMISSAO")
                lRet := DespIntVld()
             EndIf

             // by CAF 15/03/2000 14:07
             IF lRecalc
                AE100PrecoI(.T.)
             Endif

             lREFRESH:=.T.

         //** By JBJ 30/07/01 - 9:49

         Case cCampo $ "EEC_IMPORT|EEC_IMLOJA"

            lRet := TEVlCliFor(M->EEC_IMPORT,M->EEC_IMLOJA,"SA1","1|4")

            IF lRET .AND. ! EMPTY(SA1->A1_CONDPAG) .AND. READVAR() = "M->EEC_IMPORT"
               M->EEC_CONDPA := SA1->A1_CONDPAG
               M->EEC_DIASPA := SA1->A1_DIASPAG
               SY6->(DBSETORDER(1))
               SY6->(DBSEEK(XFILIAL("SY6")+M->EEC_CONDPA+STR(M->EEC_DIASPA,AVSX3("EEC_DIASPA",AV_TAMANHO),0)))
               M->EEC_DESCPA := MSMM(SY6->Y6_DESC_P,50,1)
            ENDIF

         Case cCampo $ "EEC_FORN|EEC_FOLOJA"
            lRet := TEVlCliFor(M->EEC_FORN,M->EEC_FOLOJA,"SA2","2|3")

         Case cCampo $ "EEC_BENEF|EEC_BELOJA"
            lRet := TEVlCliFor(M->EEC_BENEF,M->EEC_BELOJA,"SA2","3|5")

        Case cCampo $ "EE9_CODUE|EE9_LOJUE "
            lRet := TEVlCliFor(M->EE9_CODUE,M->EE9_LOJUE,"SA2","")

        Case cCampo $ "EYU_FABR|EYU_FA_LOJ"
            lRet := TEVlCliFor(M->EYU_FABR,M->EYU_FA_LOJ,"SA2","1|3")

         Case cCampo $ "EEC_CLIENT|EEC_CLLOJA"
            lRet := TEVlCliFor(M->EEC_CLIENT,M->EEC_CLLOJA,"SA1","")

            If lRet .And. lIntermed
                If (M->EEC_INTERM $ cSim) .And. (xFilial("EEC") == cFilBr)
                    If Empty(M->EEC_CLIENT)
                    EasyHelp(STR0077+AvSx3("EEC_CLIENT",AV_TITULO)+STR0078+AvSx3("EEC_CLIENT",15)+STR0079+; //"O campo '"###"' na pasta '"###"' deve ser "
                            STR0080,STR0048) //"informado para processos com tratamentos de off-shore."###"Atenção"
                    If Type("lMsgCrit") == "L"
                        lMsgCrit := .F.
                    EndIf
                    lRet:=.f.
                    EndIf
                EndIf
            EndIf

        Case cCampo $ "EEC_EXPORT|EEC_EXLOJA"

            lRet := TEVlCliFor(M->EEC_EXPORT,M->EEC_EXLOJA,"SA2","3|4")

         Case cCampo = "EEC_CLIENF"
            IF !Empty(M->EEC_CLIENF)
               SA1->(dbSetOrder(1))
               lAux := SA1->(dbSeek(xFilial("SA1")+M->EEC_CLIENF+M->EEC_CLOJAF))

               // Verifica se o cliente final esta cadastrado
               lRet := ExistCpo("SA1",M->EEC_CLIENF+IF(lAux,M->EEC_CLOJAF,""))

               IF lRet
                  M->EEC_CLOJAF := SA1->A1_LOJA
               Endif
            EndIf

         Case cCampo = "EEC_MOTSIT"

           IF !Empty(M->EEC_MOTSIT)
              // Verifica se a descrição esta cadastada ...
              lRet := ExistCpo("EE4",M->EEC_MOTSIT)  // ** by JBJ - 22/11/01 9:35

              cTipmen:= Posicione("EE4",1,xFilial("EE4")+M->EEC_MOTSIT,"EE4_TIPMEN")

              If lRet .And. Val(SubStr(cTipmen,1,1))#1
                 Help(" ",1,"AVG0005072")// O item selecionado não é uma descrição valida
                 lRet:= .F.
              Endif
           Endif


         Case cCampo $ "EE9_FORN|EE9_FOLOJA"
            lRet := TEVlCliFor(M->EE9_FORN,M->EE9_FOLOJA,"SA2","2|3")

         Case cCampo $ "EE9_FABR|EE9_FALOJA"
            lRet := TEVlCliFor(M->EE9_FABR,M->EE9_FALOJA,"SA2","1|3")

         Case cCampo=="EEC_TIPCOM"  //informar tipo de comissao
             IF lMensa
                If (EMPTY(M->EEC_TIPCOM) .AND. !EMPTY(M->EEC_TIPCVL) .AND. !EMPTY(M->EEC_VALCOM)) .OR. ;
                   (EMPTY(M->EEC_TIPCOM) .AND. EMPTY(M->EEC_TIPCVL) .AND. !EMPTY(M->EEC_VALCOM)) .OR. ;
                   (EMPTY(M->EEC_TIPCOM) .AND. !EMPTY(M->EEC_TIPCVL) .AND. EMPTY(M->EEC_VALCOM))
                   lRet:=.F.
                   HELP(" ",1,"AVG0000036")
                ELSEIF M->EEC_VALCOM==0
                   M->EEC_TIPCOM:=""
                Endif
             Endif
         Case cCAMPO=="EEC_TIPCVL"  //informar tipo de valor de comissao
             IF lMensa
                If (!EMPTY(M->EEC_TIPCOM) .AND. EMPTY(M->EEC_TIPCVL) .AND. !EMPTY(M->EEC_VALCOM)) .OR. ;
                   (EMPTY(M->EEC_TIPCOM)  .AND. EMPTY(M->EEC_TIPCVL) .AND. !EMPTY(M->EEC_VALCOM)) .OR. ;
                   (!EMPTY(M->EEC_TIPCOM) .AND. EMPTY(M->EEC_TIPCVL) .AND. EMPTY(M->EEC_VALCOM))
                    lRet:=.F.
                    HELP(" ",1,"AVG0000060")
                // ** By JBJ - 02/04/2002 17:26
                //ELSEIF M->EEC_VALCOM==0
                //    M->EEC_TIPCVL:=""
                Endif
             Endif
         Case cCAMPO=="EEC_VALCOM"  //informar comissao
             If (!EMPTY(M->EEC_TIPCOM) .AND. EMPTY(M->EEC_VALCOM)) .OR. ;
                (EMPTY(M->EEC_TIPCOM) .AND. !EMPTY(M->EEC_TIPCVL) .AND. EMPTY(M->EEC_VALCOM))
                 WorkAg->(dbGoTop())
                 lRET:=.T.
                 While !WorkAg->(EOF())
                     If LEFT(WorkAg->EEB_TIPOAG,1)==CD_AGC  //agente a receber comissao
                        lRet:=.F.
                     Endif
                     WorkAg->(DBSKIP(1))
                 EndDo
                 IF !lRet
                    HELP(" ",1,"AVG0000077")
                 ELSE
                    //M->EEC_TIPCVL:="" // ** By JBJ 02/04/2002 17:28
                    M->EEC_TIPCOM:=""
                    //HELP(" ",1,"AVG0000076")
                 Endif
             EndIf
             // ** By JBJ - 02/04/02 13:26
             If M->EEC_TIPCVL = "1"
                If M->EEC_VALCOM > 99.99
                   EasyHelp(STR0042,STR0039) //"A porcentagem de comissão não pode ser superior a 100 %"###"Aviso"
                   Return .f.
                EndIf
             ElseIf M->EEC_TIPCVL = "2"
                If M->EEC_TOTPED <> 0
                   //nFob := (M->EEC_TOTPED+M->EEC_DESCON)-(M->EEC_FRPREV+M->EEC_FRPCOM+M->EEC_SEGPRE+M->EEC_DESPIN+AvGetCpo("M->EEC_DESP1")+AvGetCpo("M->EEC_DESP2"))
                   nFob := EECFob(OC_EM)
                   If M->EEC_VALCOM >= nFob
                      EasyHelp(STR0043,STR0039) //"O valor da comissão deve ser inferior ao valor FOB."###"Aviso"
                      Return .f.
                   EndIf
                EndIf
             EndIf

         Case cCAMPO=="EEC_LC_NUM"

            // JPM - 30/12/04

            EEL->(DbSetOrder(1))

            If EEL->(DbSeek(xFilial("EEL")+M->EEC_LC_NUM)) .And. EECFlags("ITENS_LC")
               If Posicione("EEC",1,M->(EEC_FILIAL+EEC_PREEMB),"EEC_LC_NUM") <> M->EEC_LC_NUM .And. EEL->EEL_FINALI $ cSim // Se a L/C estiver finalizada, não pode ser utilizada
                  EasyHelp(STR0094, STR0039) // "Esta Carta de Crédito já está finalizada. Sendo assim, não poderá ser utilizada.","Aviso"
                  lRet := .f.
                  Break
               EndIf
            EndIf

            nAdiant:= AE102TotADiant() //TRP-24/07/08
            If !Empty(M->EEC_LC_NUM) .And. lNRotinaLC .And. !EECFlags("ITENS_LC")

               EEC->(DbSetOrder(1))
               nReplicacao := 0
               nReplReais  := 0
               If lReplicacao
                  nRec2 := EEC->(RecNo())
                  If EEC->(DbSeek(cFilEx+M->EEC_PEDREF)) .And. M->EEC_LC_NUM == EEC->EEC_LC_NUM .And.;
                     !Empty(EEC->EEC_DTEMBA)

                     nReplicacao := EECCalcTaxa(EEC->EEC_MOEDA,M->EEC_MOEDA,EEC->EEC_TOTPED,AvSx3("EEC_TOTPED",AV_DECIMAL))

                     nReplReais := EEC->EEC_TOTPED
                     If EEC->EEC_MOEDA <> "R$ "
                        nReplReais *= BuscaTaxa(EEC->EEC_MOEDA,dDataBase)
                        nReplReais := Round(nReplReais,AvSx3("EEC_TOTPED",AV_DECIMAL))
                     EndIf
                  EndIf
                  EEC->(DbGoTo(nRec2))
               EndIf

               nTotPedAnt := 0
               If EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB)) .And. EEC->EEC_LC_NUM == M->EEC_LC_NUM .And.;
                  !Empty(EEC->EEC_DTEMBA)

                  nTotPedAnt := (EEC->EEC_TOTPED - nAdiant)  //TRP-24/07/08
               EndIf

               nTaxa1 := 1
               nTaxa2 := 1

               //nSldLC := EEL->EEL_SLDEMB
               If M->EEC_LC_NUM <> EEC->EEC_LC_NUM
			      nSldLC := EEL->EEL_SLDVNC
			   Else
			      nSldLC := EEL->EEL_SLDEMB
			   EndIf

               If nTotPedAnt <> 0
                  nSldLC += EECCalcTaxa(EEC->EEC_MOEDA,EEL->EEL_MOEDA,nTotPedAnt,AvSx3("EEC_TOTPED",AV_DECIMAL))
               EndIf

               nSldLC += nReplicacao

               nTotPed := (M->EEC_TOTPED - nAdiant) //TRP-24/07/08

               If EEL->EEL_MOEDA <> M->EEC_MOEDA
                  If EEL->EEL_MOEDA <> "R$ "
                     nTaxa1 := BuscaTaxa(EEL->EEL_MOEDA,dDataBase)
                  Endif
                  If M->EEC_MOEDA <> "R$ "
                     nTaxa2 := BuscaTaxa(M->EEC_MOEDA,dDataBase)
                  Endif
                  If EEC->EEC_MOEDA <> "R$ " .And. nTotPedAnt <> 0
                     nTotPedAnt := Round(nTotPedAnt * BuscaTaxa(EEC->EEC_MOEDA,dDataBase),2)
                  EndIf
                  //nSldLCReais := Round(EEL->EEL_SLDEMB * nTaxa1,2) + nTotPedAnt + nReplReais
                  nSldLCReais := Round(EEL->EEL_SLDVNC * nTaxa1,2) + nTotPedAnt + nReplReais

                  nTotPedReais := Round((M->EEC_TOTPED - nAdiant) * nTaxa2,2)  //TRP-24/07/08
               EndIf

               If EEL->EEL_MOEDA <> M->EEC_MOEDA
                  lRet := (nSldLCReais >= nTotPedReais)
               Else
                  lRet := (nSldLC >= nTotPed)
               EndIf

               If !lRet .And. !lValLC//!@lValLC //LGS-04/07/2014
                  cMsg := STR0062+AllTrim(M->EEC_LC_NUM)+STR0069+Alltrim(M->EEC_MOEDA)+" "
                  cMsg += AllTrim(Transf(nTotPed,AvSx3("EEC_TOTPED",AV_PICTURE)))
                  If M->EEC_MOEDA <> "R$ " .And. EEL->EEL_MOEDA <> M->EEC_MOEDA
                     cMsg += " (R$ "+ AllTrim(Transf(nTotPedReais,AvSx3("EEC_TOTPED",AV_PICTURE)))+")"
                  EndIf
                  cMsg += STR0070+AllTrim(EEL->EEL_MOEDA)+" "
                  //cMsg += AllTrim(Transf(nSldLC,AvSx3("EEL_SLDEMB",AV_PICTURE)))
                  cMsg += AllTrim(Transf(nSldLC,AvSx3("EEL_SLDVNC",AV_PICTURE)))

                  If EEL->EEL_MOEDA <> "R$ " .And. EEL->EEL_MOEDA <> M->EEC_MOEDA
                     //cMsg += " (R$ " + AllTrim(Transf(nSldLCReais,AvSx3("EEL_SLDEMB",AV_PICTURE)))+")"
                     cMsg += " (R$ " + AllTrim(Transf(nSldLCReais,AvSx3("EEL_SLDVNC",AV_PICTURE)))+")"
                  EndIf
                  cMsg += "."

                  IF !IsMemVar("lAe100Auto") .Or. !lAe100Auto
	                  MsgStop(cMsg,STR0039)                                           //"O Saldo da L/C "##" não é suficiente." //" Saldo necessário: "##". Saldo L/C: "## ,"Aviso"
                     If !EasyGParam("MV_EEC0041",,.F.)                               // LRS - 31/12/2014 - Criado MV para não precisar mais cair no MSGYESNO
	                     cMsgLC := STR0068 +" "+AllTrim(M->EEC_LC_NUM)                //LGS-04/07/2014
					         lValLC := MsgYesNo(SubStr(cMsgLC,2,length(cMsgLC)),STR0039)
					      EndIf
                     If lValLC
						      lRet := .T.
					      Else
					         Break
					      EndIf
				      Else
				         EasyHelp(cMsg,STR0039)
				         lValLC := .F.
				         Break
				      EndIF
               EndIf
            EndIf

            If !lRet .And. lValLC//@lValLC //LGS-04/07/2014 - Se o cliente já marcou que deseja vincular a L/C mesmo o valor sendo menor passo True para gravar sem erros.
			      lRet := .T.
            EndIf

            If !Empty(M->EEC_LC_NUM) .And. lNRotinaLC

               If !Ae102DataLC(.t.)
                  lRet := .f.
                  Break
               EndIf

            EndIf

            If lMensa .And. EECFlags("ITENS_LC") //Apenas por enquanto.
               nRec := WorkIp->(RecNo())

               If !Ae107AtuIp()
                  lRet := .f.
               EndIf

               WorkIp->(DbGoTo(nRec))
               oMsSelect:oBrowse:Refresh()

               If !lRet
                  Break
               EndIf

            EndIf

         Case cCampo == "EE9_LC_NUM" // JPM - 15/07/05

            If !Empty(M->EE9_LC_NUM)

               If !Ae102DataLC(.f.)
                  lRet := .f.
                  Break
               EndIf

               If Posicione("EEL",1,xFilial("EEL")+M->EE9_LC_NUM,"EEL_FINALI") $ cSim
                  EasyHelp(STR0094, STR0039) // "Esta Carta de Crédito já está finalizada. Sendo assim, não poderá ser utilizada.","Aviso"
                  lRet := .f.
                  Break
               EndIf

               If EEL->EEL_CTPROD $ cNao //só valida se a L/C não controlar produtos. Se controla, esta validação é feita no preenchimento da sequência da L/C
                  If !Ae107ValIt(OC_EM,WorkIp->(RecNo()))
                     lRet := .f.
                     Break
                  EndIf
               EndIf

               If M->EE9_LC_NUM <> M->EEC_LC_NUM
                  M->EEC_LC_NUM := CriaVar("EEC_LC_NUM")
               EndIf

            Else
               If !Empty(M->EEC_LC_NUM)
                  M->EEC_LC_NUM := CriaVar("EEC_LC_NUM")
               EndIf
            EndIf

         Case cCAMPO == "EE9_SEQ_LC" // JPM - 19/07/05

            If !Empty(M->EE9_SEQ_LC)
               If Posicione("EXS",1,xFilial("EXS")+M->EE9_LC_NUM+M->EE9_SEQ_LC,"EXS_COD_I" ) <> M->EE9_COD_I
                  EasyHelp(STR0095,STR0039) // "O Produto da Sequência de L/C informada não é igual ao Produto do item atual.","Aviso"
                  lRet := .f.
                  Break
               EndIf

               If !Ae107ValIt(OC_EM,WorkIp->(RecNo()))
                  lRet := .f.
                  Break
               EndIf
            EndIf

         Case cCAMPO=="EEC_MARCAC"
             IF ! Inclui
                Break
             Endif
              // By OMJ 26/02/2003 16:00 - Nao montar a marcacao na Inclusao
             IF !lOkFinal .AND. lEECMarks .AND. lMensa .And. (IIf(!Empty(M->EEC_MARCAC) .And. !lAe100Auto, MsgYesNo(STR0125, STR0058), .T.)) //"Deseja sobrepor a marcação existente (pasta embalagens)?"
                M->EEC_MARCAC:=EECMARKS(OC_EM)
             Endif
         CASE cCAMPO == "EEC_LICIMP"
            IF ( M->EEC_EXLIMP $ cSim .AND. EMPTY(M->EEC_LICIMP))
                 lRET:=.F.
                 HELP(" ",1,"AVG0000073")
            Endif
        CASE cCAMPO $ "EEC_VIA/EEC_ORIGEM/EEC_DEST/EEC_TIPTRA"
            If !ReadVar() $ "M->EEC_VIA/M->EEC_ORIGEM/M->EEC_DEST/M->EEC_TIPTRA" .Or. Vazio()
               Break
            endif
             If ReadVar() == "M->EEC_VIA"
                nVar  := 1
                cSeek := M->EEC_VIA
             ElseIf ReadVar() == "M->EEC_ORIGEM"
                nVar  := 2
                cSeek := M->EEC_VIA+M->EEC_ORIGEM+IIF(!Empty(M->EEC_DEST), M->EEC_DEST, "")
             ElseIf ReadVar() == "M->EEC_DEST"
                nVar  := 3
                cSeek := M->EEC_VIA+M->EEC_ORIGEM+M->EEC_DEST
             Else
                nVar  := 4
                cSeek := M->EEC_VIA+M->EEC_ORIGEM+M->EEC_DEST+M->EEC_TIPTRA
             Endif

             If !EECVia(cSeek)
                EasyHelp(STR0061, STR0039) //"A Via não está cadastrada."###"Aviso"
                lRet := .F.
             EndIf

             If lRet .And. lMensa
                If nVar <= 1
                   M->EEC_VIA_DE := Posicione("SYQ",1,xFilial("SYQ")+M->EEC_VIA,"YQ_DESCR")
                   M->EEC_ORIGEM := SYR->YR_ORIGEM
                Endif
                If nVar <= 2
                   M->EEC_DEST   := SYR->YR_DESTINO
                Endif
                If nVar <= 3
                   M->EEC_TIPTRA := SYR->YR_TIPTRAN
                Endif

                M->EEC_PAISDT := SYR->YR_PAIS_DE
                M->EEC_PAISET := SYR->YR_PAIS_DE
                M->EEC_TRSTIM := SYR->YR_TRANS_T

                SY9->(dbSetOrder(2))
                IF SY9->(dbSeek(XFILIAL("SY9")+M->EEC_ORIGEM))
                   M->EEC_DSCORI  := SY9->Y9_DESCR
                   M->EEC_URFDSP  := SY9->Y9_URF
                   M->EEC_URFENT  := SY9->Y9_URF
                Endif

                M->EEC_DSCDES := Posicione("SY9",2,xFilial("SY9")+M->EEC_DEST,"Y9_DESCR")
             Endif

             //RMD - ROADMAP: C1 - 27/04/15 - Carrega o campo referente a NBS associada para registro de frete
             If lRet .And. "EEC_VIA" $ ReadVar() .And. !Empty(M->EEC_VIA)
             	If SYQ->(FieldPos("YQ_PRDSIS")) > 0 .And. !Empty(cPrdSis := Posicione("SYQ", 1, xFilial("SYQ")+M->EEC_VIA, "YQ_PRDSIS"))
             		If !Empty(cNBSVia := Posicione("SB5", 1, xFilial("SB5")+cPrdSis, "B5_NBS"))
             			If Empty(M->EXL_NBSFR) .Or. (M->EXL_NBSFR <> cNBSVia .And. MsgYesNo("Deseja atualizar a NBS para serviços de frete?", "Aviso"))
             				M->EXL_NBSFR := cNBSVia
             			EndIf
             		EndIf
             	EndIf
             EndIf


             lREFRESH:=.T.

             //ENDIF
        CASE cCAMPO $ "EEC_TRSTIM/EEC_ETD/EEC_TRSDOC"
           //Atualiza dados transito
           IF ( !EMPTY(M->EEC_TRSTIM) .AND. !EMPTY(M->EEC_ETD)) // .AND. EMPTY(M->EEC_ETADES))
              M->EEC_ETADES:=M->EEC_ETD+M->EEC_TRSTIM
           ENDIF
           //atualiza dados no registro embarque
           IF (!EMPTY(M->EEC_TRSDOC) .AND. !EMPTY(M->EEC_ETD) .AND. EMPTY(M->EEC_DTLMDC) )
              M->EEC_DTLMDC:=M->EEC_ETADES-M->EEC_TRSDOC
           Endif
           lREFRESH:=.T.

        CASE cCAMPO = "EEC_ETADES"
             /* By JBJ - 05/05/04 - Para os processos já embarcado o critica é feita com base
                                    na data de embarque. Desconsiderando o campo EEC_ETD
                                    (Data Prevista de Saída do Porto de Origem).*/

             If !Empty(M->EEC_ETADES) .And. !Empty(M->EEC_TRSTIM)
                If !Empty(M->EEC_DTEMBA)
                   If !Empty(M->EEC_ETD)
                      If (M->EEC_ETADES < (M->EEC_ETD + M->EEC_TRSTIM))
                         lRet := .f.
                         Help(" ",1,"AVG0000079")
                      EndIf
                   EndIf
                EndIf
             EndIf
        CASE cCAMPO = "EEC_DTLMDC"
           If !Empty(M->EEC_DTLMDC)
              IF !( M->EEC_DTLMDC > (M->EEC_ETD+M->EEC_TRSDOC) ) //FMB 04/04/05
                 lRET:=.F.
                 HELP(" ",1,"AVG0000080")
              Endif
           EndIf
        CASE cCAMPO="EEC_VLMNSC"
           IF (M->EEC_VLMNSC==0)
              M->EEC_VLMNSC:=M->EEC_TOTPED*(M->EEC_MRGNSC/100)
           ENDIF
        CASE cCAMPO="EEC_INSCOD"
             IF Empty(M->EEC_PAISET)
               lRet := .F.
               HELP(" ",1,"AVG0000081")
             Endif
                nOrdEE1 := EE1->(IndexOrd())
                EE1->(DBSETORDER(2))
                If !Empty(M->EEC_INSCOD) //ER - 23/03/2006 às 15:15
                   IF ! EE1->(DBSEEK(xFilial()+TR_INS+AVKey(M->EEC_INSCOD,"EE1_DOCUM")+M->EEC_PAISET))
                      lRet := .F. // BAK - 04/08/2011 - Alteração para retornar falso
                      HELP(" ",1,"AVG0000082")
                   Endif
                EndIf
                EE1->(dbSetOrder(nOrdEE1))
                EE1->(DBSEEK(xFILIAL()))
        CASE cCAMPO == "EEC_DTEMBA"
            
            lSemB2B := !lBackTo .And. !(cTipoProc $ PC_VR+PC_VB)//RMD - 30/11/21 - Se for venda de remessa também não deve validar a nota fiscal

            If !Empty(M->EEC_DTEMBA) .And. ( INCLUI .OR. Empty(EEC->EEC_DTEMBA)) .and. cCAMPO $ ReadVar()

                aAdt := AE102ADTVLD() // retorno {nPercEsp, nTotEsp, nPercAss, nTotAss, nDif, aAdtAssd,aParcSY6}
                // se a diferença entre o esperado e o já recebido for maior q zero entra na validação
                If aAdt[5] > 0 .OR. (aAdt[1] > 0 .and. aAdt[3] == 0 )
                    cMSg := "O valor total do processo de embarque é de: " + Alltrim(transform( M->EEC_TOTPED , pesqpict( "EEC","EEC_TOTPED" ))) + ENTER //
                    cMsg += "A condição de pagamento utilizada define uma previsão de " + alltrim(transform(aAdt[1],"999.99")) + "% do valor antecipado antes do embarque, que corresponde a " + M->EEC_MOEDA + " " + alltrim(transform(aAdt[2],pesqpict("EEQ","EEQ_VL"))) + ENTER + ENTER

                    // caso exista adiantamentos associados ao processo de embarque
                    If aAdt[4] > 0
                        cMsg += "Porém, foram associados adiantamentos que correspondem a " + M->EEC_MOEDA + " " + alltrim(transform(aAdt[4],pesqpict("EEQ","EEQ_VL"))) + ENTER + ENTER
                        cmsg += "Relação dos adiantamentos:" + ENTER
                        for nA := 1 to len(aAdt[6])
                            EEQ->(dbgoto(aAdt[6][nA]))
                            cMsg += "Nro Adt: "+ alltrim(EEQ->EEQ_NRINVO) + " Dt. Vcto.: " + dtoc(EEQ->EEQ_VCT) + " Valor: " + alltrim(transform( EEQ->EEQ_VL,pesqpict( "EEQ" , "EEQ_VL" ))) + ENTER
                        next
                        cMsg += ENTER + "Desta forma, existe um saldo de " + M->EEC_MOEDA + " " + alltrim(transform(aAdt[5],pesqpict("EEQ","EEQ_VL"))) + " a ser associado." + ENTER + ENTER
                    Else // se não existir associação de adiantamentos ao processo de embarque
                        cMsg += "Porém, não foram associados adiantamentos a este embarque." + ENTER + ENTER
                    endif

                    /// complemento da mensagem para quando a liberação financeira não foi preenchida
                    If EEC->(FieldPos("EEC_DTADTE")) > 0
                        If Empty(M->EEC_DTADTE)
                            cMsg += "Para continuar, será necessário vincular os adiantamentos faltantes ou efetuar a liberação financeira do embarque preenchendo o campo 'Lib.Pend.Ad' na aba 'Financeiro'." + ENTER + ENTER
                            If aAdt[1] < 100 // quando o percentual esperado é menor que 100%
                                cMsg += "Caso a liberação financeira seja efetuada sem vincular novos adiantamentos, o valor restante será distribuído proporcionalmente entre as parcelas com vencimento após o embarque." + ENTER
                            Else
                                cMsg += "Caso a liberação financeira seja efetuada sem vincular novos adiantamentos, o valor restante será registrado automaticamente em uma nova parcela de câmbio a receber com vencimento no próximo dia útil após a data de embarque, e poderá ser reprogramada na rotina de câmbio." + ENTER
                            endIf
                        Else
                            If aAdt[1] < 100
                                cMsg += "Como a liberação financeira já foi registrada no campo 'Lib.Pend.Ad', caso confirme, o valor restante será distribuido proporcionalmente entre as parcelas com vencimento após o embarque." + ENTER
                            Else
                                cMsg += "Como a liberação financeira já foi registrada no campo 'Lib.Pend.Ad', caso confirme, o valor restante será registrado automaticamente em uma nova parcela de câmbio a receber com vencimento no próximo dia útil após a data de embarque, e poderá ser reprogramada na rotina de câmbio." + ENTER
                            EndIf
                        EndIf
                    Else
                        cMsg += "Para continuar, associe os adiantamentos faltantes ou utilize outra condição de pagamento." + ENTER
                    EndIf
                    // caso seja rotina automática o campo de liberação financeira esteja vazio e não exista o mesmo no array de execauto
                    if lAe100Auto
                        If EEC->(FieldPos("EEC_DTADTE")) > 0 .And. Empty(M->EEC_DTADTE)
                            //if (nPos := aScan(aAE100Auto, {|x| x[1] == "EEC" })) > 0 .AND. aScan( aAE100Auto[nPos][2] , {|x| x[1] == "EEC_DTADTE" } ) == 0
                                autogrlog( cMsg )
                                lRet := .F.
                                Break
                            //endif
                        endif
                    Else
                        If EEC->(FieldPos("EEC_DTADTE")) == 0
                            EECView(cMsg, "Aviso",,,,,.T.)
							lRet := .F.
							Break
                        Else
                            If EECView(cMsg, "Aviso")
                                If Empty(M->EEC_DTADTE)
                                    MsgStop("Não será possível prosseguir sem que o campo 'Lib.Pend.Ad' seja informado.", "Atenção")
                                    lRet := .F.
                                    Break
                                EndIf
                            Else
                                lRet:= .F.
                                Break
                            EndIf
                        EndIf
                    EndIf
                EndIf
                nVlComiss := AE102CalcAg(,,"2")
                If nVlComiss > 0 .And. aAdt[4] > 0 .And. (M->EEC_TOTPED - aAdt[4] - AE102CalcAg(,,"2")) <= 0 //Existe adto associado ao embarque e total do pedido menos adiantamento maior ou igual a conta grafica
                    //THTS - 06/09/2019 - Verifica se existe comissao e caso exista, se o valor associado nao e maior que o valor liquido do embarque (valor - conta grafica)
                    EasyHelp(STR0150, STR0058)//"Não é possível embarcar, pois o saldo do embarque após a associação do adiantamento é menor ou igual o valor da comissão Conta Gráfica."###Atenção
                    lRet := .F.
                    Break
                EndIf
            endif

             //WFS - 03/12/2013 - Valida a retirada da data de embarque quando for processo de drawback isenção
             If !Inclui .And. lIntDraw
              	If Empty(M->EEC_DTEMBA) .And. !Empty(EEC->EEC_DTEMBA) .And. !ValidaIsencao()
             		lRet:= .F.
					Break
             	EndIf
             EndIf

             //Valida alterações na data de embarque para produtos estocados em consignação
             If lConsign .And. (cTipoProc == PC_RC .Or. cTipoProc == PC_BC)
                If Empty(M->EEC_DTEMBA)
                   If !Empty(M->EEC_DTREC)
                      EasyHelp(STR0106, STR0058)//"Não é possível retirar a data de embarque porque a data de recebimento já foi preenchida."###Atenção
                      lRet := .F.
                      Break
                   EndIf
                   If !Empty(EEC->EEC_DTEMBA) .And. Ae108ChkArm(M->EEC_IMPORT, M->EEC_IMLOJA, M->EEC_PREEMB)
                      EasyHelp(STR0107, STR0058)//"Não é possível alterar a data porque um ou mais itens possuem vinculação em vendas de consignação"###Atenção
                      lRet := .F.
                      Break
                   EndIf
                Else
                   If !Empty(M->EEC_DTREC) .And. M->EEC_DTEMBA > M->EEC_DTREC
                      EasyHelp(STR0110,STR0058)//"Não é possível informar uma data de embarque superior a data de recebimento."###"Atenção"
                      lRet := .F.
                      Break
                   EndIf
                   If EEC->EEC_DTEMBA <> M->EEC_DTEMBA .And. Ae108ChkArm(M->EEC_IMPORT, M->EEC_IMLOJA, M->EEC_PREEMB)
                      EasyHelp(STR0107, STR0058)//"Não é possível alterar a data porque um ou mais itens possuem vinculação em vendas de consignação"###Atenção
                      lRet := .F.
                      Break
                   EndIf
                   /* NOPADO - 17/11/2021 - OSSME-6390 - Nao deve mais validar o campo RE, pois agora é utilizada a DUE.
                   If cTipoProc == PC_RC
                      nRecnoIp := WorkIp->(Recno())
                      WorkIp->(DbGoTop())
                      While WorkIp->(!Eof())
                         If Empty(WorkIp->EE9_RE)
                            EasyHelp(STR0114, STR0058)//"Não é possível embarcar porque um ou mais itens não possuem vinculação com R.E.´s."###"Atenção"
                            lRet := .F.
                            Break
                         EndIf
                         WorkIp->(DBSkip())
                      EndDo
                   EndIf*/
                EndIf
             EndIf

            //ER - 27/04/2007 - Verifica se existe adiantamento Pós-Embarque
            If !Inclui
               If Empty(M->EEC_DTEMBA) .and. !Empty(EEC->EEC_DTEMBA)
                  EEQ->(DbSetOrder(1))
                  If EEQ->(DbSeek(xFilial("EEQ")+M->EEC_PREEMB))
                     While EEQ->(!EOF()) .and. EEQ->(EEQ_FILIAL + EEQ_PREEMB) == xFilial("EEQ")+M->EEC_PREEMB
                        If EEQ->EEQ_EVENT == "603"
                           EasyHelp(STR0121,STR0058)//"Existem Parcelas de Adiantamento Pós-Embarque vinculadas a esse Embarque."###"Atenção"
                           lRet := .F.
                           Break
                        EndIf
                        If (!EEQ->EEQ_EVENT $ "101/122,602,605" .OR. EEQ->EEQ_TIPO <> "A")//LGS-10/07/2014-Permitir tirar a data de embarque mesmo o processo tendo adiantamento vinculado.
                           If !Empty(EEQ->EEQ_PGT) .And. If( /*AvFlags("EEC_LOGIX") .and.*/ Alltrim(EEQ->EEQ_EVENT) == '122' , .F. , .T.) //NCF - 19/02/2014  //NCF - 08/10/2015 - Integ. EEC x ESS (Desp./Comiss.)
                              cMsgErr := "Não é possível retirar a data de embarque pois existem parcelas de câmbio contratadas."+Chr(13)+Chr(10)
                              cMsgErr += Chr(13)+Chr(10)
                              cMsgErr += "Evento: "+AllTrim(EEQ->EEQ_EVENT)+" Parcela: "+AllTrim(EEQ->EEQ_PARC)+" Data de liquidação: "+DTOC(EEQ->EEQ_PGT)

                              if lAe100Auto
                                 autogrlog( cMsgErr )
                              else
                                 EECView(cMsgErr,"Atenção")
                              endif
                              lRet := .F.
                              Break
                           EndIf
                        EndIf
                        EEQ->(DbSkip())
                     EndDo
                  EndIf
               EndIf
            EndIf

             If !Empty(M->EEC_DTEMBA) .And. AvFlags("EEC_LOGIX") .And. !cTipoProc $ (PC_BN+ "/" + PC_BC) //MCF - 19/07/2016

                If Inclui
                   MsgAlert("Data de Embarque não pode ser preenchida na inclusão do Processo "+;
                            "quando o módulo está integrado ao ERP LOGIX. Neste caso, salve a "+;
                            "gravação do processo de embarque e entre posteriormente em modo  "+;
                            "de alteração deste registro para então informar a data de embarque.")
                   lRet := .F.
                   Break
                EndIf

                nRecnoIp := WorkIp->(Recno())
                WorkIp->(DbGoTop())
                While WorkIp->(!Eof())
                   If Empty(WorkIp->EE9_NF)
                      EasyHelp("Existem itens sem Nota Fiscal associada. Não será possível embarcar.", STR0058)
                      lRet := .F.
                      WorkIp->(DbGoTo(nRecnoIp))
                      Break
                   EndIf
                   WorkIp->(DBSkip())
                EndDo
                WorkIp->(DbGoTo(nRecnoIp))
             EndIf

             IF !Inclui .And. !AF200STATUS("EEQ")
                lRET := .F.
             ELSEIF ! EMPTY(M->EEC_DTEMBA)

                //ER - 22/03/06 às 11:20 - Alteração dos critérios utilizados em relação ao parametro MV_NFDTC.
                //THTS - 07/11/2017 - Faz a validação na WorkNF e nao na tabela gravada no banco
                WorkNF->(dbGoTop())

                Do While !WorkNF->(Eof())
                    If WorkNF->EEM_DTNF > M->EEC_DTEMBA .and. !lNFPosEm
                        lRET := .F.
                        EasyHelp(STR0097+alltrim(WorkNF->EEM_NRNF))//"Existe uma nota fiscal com data superior a data do embarque, NF:"
                        Exit
                    EndIf
                    WorkNF->(DbSkip())
                EndDo

                IF lRET
                   If lConsign .And. (cTipoProc == PC_RC .Or. cTipoProc == PC_BC)
                      If Empty(M->EEC_DTREC)
                         M->EEC_STATUS := ST_TR
                      Else
                         M->EEC_STATUS := ST_EC
                      EndIf
                   Else
                      M->EEC_STATUS :=ST_EM
                   EndIf
                   M->EEC_FIM_PE :=dDATABASE
                ENDIF

         //ACB 27/08/2010 - Nopado para que ao preencher o campos de envio de documento o status mude para aguardando embarque
         //ELSEIF EMPTY(M->EEC_DTEMBA) .AND. (M->EEC_STATUS=ST_EM .Or. M->EEC_STATUS == ST_TR)
             ELSEIF EMPTY(M->EEC_DTEMBA) .AND. (M->EEC_STATUS=ST_EM .Or. M->EEC_STATUS == ST_TR .Or. !EMPTY(M->EEC_DTENDC))
                    M->EEC_STATUS := ST_AE  //AG. EMBARQUE
                    M->EEC_FIM_PE := AVCTOD("")
             //ACB - 27/08/2010 - Caso seja apagada a data de envio de doc volta o status de "Aguardando Cofecccao de documentos"
             ELSEIF EMPTY(M->EEC_DTENDC) .AND. (M->EEC_STATUS == ST_AE)
                    M->EEC_STATUS := ST_DC
             ENDIF

             /*
              Validação na data de embarque para o valor de tolerância.
              Autor       : Alexsander Martins dos Santos
              Data e Hora : 03/11/2003 às 14:00.
              Objetivo    : Não permitir divergencia entre o valor da NF e Tot. Processo.
             */
             If lSemB2B
                If !Empty(M->EEC_DTEMBA) .and. EasyGParam("MV_AVG0055",.T.) .and. EasyGParam("MV_AVG0055",.F.) <> 999
                   WorkNF->(dbGoTop())

                   While !WorkNF->(Eof())

                      If WorkNF->EEM_TIPOCA = "N" .and. WorkNF->EEM_TIPONF $ "1,2"
                         nTotalNF := nTotalNF + (WorkNF->EEM_VLNF/If(WorkNF->(FieldPos("EEM_TXTB")) <> 0, WorkNF->EEM_TXTB, BuscaTaxa(M->EEC_MOEDA, WorkNF->EEM_DTNF)))

                         //Verifica a presença de NFs de Devolução
                         If EES->(FieldPos("EES_QTDDEV")) > 0 .and. EES->(FieldPos("EES_VALDEV")) > 0
                            EES->(DbSetOrder(1))
                            If EES->(DbSeek(xFilial("EES")+WorkNF->EEM_PREEMB+WorkNF->EEM_NRNF))
                               If !Empty(EES->EES_VALDEV)
                                   nTotalNf -= (EES->EES_VALDEV/If(WorkNF->(FieldPos("EEM_TXTB")) <> 0, WorkNF->EEM_TXTB, BuscaTaxa(M->EEC_MOEDA, WorkNF->EEM_DTNF)))
                               EndIf
                            EndIf
                         EndIf
                      EndIf

                      WorkNF->(dbSkip())

                   End

                   If M->EEC_TOTPED <> nTotalNF .and. Abs(M->EEC_TOTPED - nTotalNF) > EasyGParam("MV_AVG0055",.F.)
                      EasyHelp(STR0059, STR0058) //"N.F.s de venda não fecham com o total do processo !"###"Atenção"
                      lRet := .F.
                   EndIf
                EndIf
             EndIf

             IF !Empty(M->EEC_DTEMBA)
                /*
                AMS - 02/11/2004 às 12:05. Consistencia para rotina de Despesas Internacionais.
                */
                If EECFlags("FRESEGCOM") .And. !EasyGParam("MV_AVG0081",, .F.)
                   If !DIVld_DTEMBA()
                      lRet := .F.
                      Break
                   EndIf
                EndIf
             Endif

             /*
             AMS - 02/08/2004 às 15:29. Consistência na Dt.Embarque, para permitir o preenchimento, quando
                                        o MV_AVG0067 estiver .T. e a rotina AE104NFCompara(Compara as qtde's
                                        dos itens, entre a NF e o Embarque) tiver sido executada.
             */
             If lSemB2B
                If (lSelNotFat .or. (lIntCont .And. lContNfCompara)) .and. !Empty(M->EEC_DTEMBA) .and. !lNFCompara

                   If lIntegra //Quando integrado com a Microsiga é verificado se os itens possuem NF´s para comparar.
                      WorkIp->(Eval({|x| dbGoTop(),;
                                         dbEval({|| lEmbFaturado := .F.}, {|| Empty(EE9_NF)}, {|| lEmbFaturado},,, .F.),;
                                         dbGoTo(x)}, Recno()))
                   Else
                      lEmbFaturado := .F.
                   EndIf

                   //DFS - 24/04/13 - Inclusão de verificação para que, não apresente a mensagem se não houver integração com Faturamento.
                   If (!lEmbFaturado .And. !AvFlags("EEC_LOGIX") .And. EasyGParam("MV_EECFAT",, .F.) .AND. EasyGParam("MV_AVG0067",, .F.)) .AND. M->EEC_AMOSTR <> "1"  // GFP - 15/06/2015
                      EasyHelp(STR0060, STR0058) //"O preenchimento da dt.embarque, somente será aceita, após a comparação dos itens da NF contra os itens do Embarque."###"Atenção"
                      M->EEC_DTEMBA := CriaVar("EEC_DTEMBA")
                      lRet := .F.
                   EndIf
                EndIf
             EndIf

             lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                          EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                          EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                          EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                          EF6->( FieldPos("EF6_SEQCNT") ) > 0

             lParFin := EEQ->(FieldPos("EEQ_PARFIN")) > 0

             // ** AAF - 02/03/06 - Consistência da Data de Embarque caso haja vinculação do processo a Contrato de Financiamento.
             If EasyGParam("MV_EFF",,.F.) .AND. Empty(M->EEC_DTEMBA) .AND. !Empty(EEC->EEC_DTEMBA) .and. !lGerAdEEC

                lMultiFil  := VerSenha(115) .And. Posicione("SX2",1,"EF1","X2_MODO") == "C" .And. Posicione("SX2",1,"EEQ","X2_MODO") == "E" .And. EF3->( FieldPos("EF3_FILORI") ) > 0

                EEQ->( dbSetOrder(1) )
                EF1->( dbSetOrder(1) )
                EF3->( dbSetOrder(2) )

                EEQ->( dbSeek(xFilial("EEQ")+M->EEC_PREEMB) )
                Do While !EEQ->(EoF()) .AND. EEQ->(EEQ_FILIAL+EEQ_PREEMB) == xFilial("EEQ")+M->EEC_PREEMB
                   If EEQ->EEQ_EVENT == '101'
                      //FSM - 12/11/2012
                      If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,"E","")+"600"+EEQ->(EEQ_NRINVO+If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN)) ))
                         If lMultiFil
                            Do While !EF3->(EoF()) .And. EF3->(EF3_FILIAL+EF3_CODEVE+EF3_INVOIC+EF3_PARC) == xFilial("EF3")+"600"+EEQ->(EEQ_NRINVO+If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN))
                               If EEQ->EEQ_FILIAL==EF3->EF3_FILORI
                                   lRet:= .F.
                                   Exit
                                EndIf
                                EF3->(DBSkip())
                            EndDo
                         Else
                            lRet:= .F.
                         EndIf

                         If !lRet
                            EasyHelp(STR0105)//"Data de Embarque não pode ser apagada pois o processo está associado a contrato(s) de financiamento"
                            Exit
                         EndIf

                      EndIf
                   EndIf

                   EEQ->( dbSkip() )
                EndDo

             EndIf

             //ER - 09/02/2007
             If lRet .and. lBackTo .and. !Empty(M->EEC_DTEMBA)
                If !Ap106IsBackTo() .and. lConsign
                   EasyHelp(STR0122,STR0048)//"Não foram vinculadas Invoices a Pagar para esse Processo."###"Atenção"
                   lRet := .F.
                   Break
                EndIf
             EndIf
             // **
             // ** AAF - 24/09/04 - Validação em Back to Back
             If lRet == .T. .AND. Len(aColsBtB) > 0
                lRet:= AP106Valid("EEC_DTEMBA")
             Endif
             // **
             // **
             If !Empty(M->EEC_DTEMBA) .And. EECFLAGS("AMOSTRA") .And. M->EEC_ENVAMO == "1" .And. !Am100VldEmb("EMBARQUE", M->EEC_PREEMB)
                lRet := .F.
                Break
             EndIf
             // **
             DSCSITEE7(,OC_EM)
             lREFRESH:=.T.
        CASE cCAMPO = "EEC_CONDPA" .OR. cCAMPO = "EEC_DIASPA"
             If lIntDraw
                /*AOM - 04/07/2011 - Tratamento que verifica se os itens possue apropriação dos itens
                  no drawback e se a condição de pagt está ao contrario da selecionada (Com cobert ou Sem cobert */
                cCobCam := M->EEC_COBCAM
                AE101CobCamb("EEC_CONDPA") //Atualiza o campo cobertura cabial
                //Verifica se os itens estao com apropriação
                If Select("WorkAnt") > 0
                   WorkAnt->(dbSetOrder(1))
                   lSeekAnt :=  WorkAnt->(dbSeek(WorkIP->EE9_ATOCON+M->EEC_PREEMB+WorkIP->EE9_PEDIDO+WorkIP->EE9_SEQUEN+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,WorkIP->EE9_SEQEMB,"")))//AOM - 29/08/2011
                Else
                   EDD->(dbSetOrder(3))
                   lSeekAnt :=  EDD->(dbSeek(xFilial("EDD")+M->EEC_PREEMB+WorkIP->EE9_PEDIDO+WorkIP->EE9_SEQUEN+WorkIP->EE9_COD_I+WorkIP->EE9_ATOCON+IIf(FieldPos("EE9_SEQED3")>0, WorkIP->EE9_SEQED3,"")+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,WorkIP->EE9_SEQEMB,"")))//AOM - 29/08/2011
                EndIf

                nRecno := WorkIp->(Recno())
                WorkIp->(DbGoTop())
                While WorkIp->(!Eof())
                   If !Empty(WorkIP->WP_FLAG) .And. !Empty(WorkIP->EE9_ATOCON) .And. !Empty(WorkIP->EE9_SEQED3) .And. cCobCam  <>  M->EEC_COBCAM  .And. lExistEDD .And. lSeekAnt
                      If cCobCam == "1"
                         EasyHelp(STR0131,STR0039)//STR0131	Existem item(ns) do Embarque com apropriação do Ato Concessório. Para efetuar a alteração da condição de pagamento com cobertura cambial para outra sem cobertura cambial é necessário desapropriar o(s) item(ns). //STR0039	"Aviso"
                      Else
                         EasyHelp(STR0132,STR0039)// STR0132	Existem item(ns) do Embarque com apropriação do Ato Concessório. Para efetuar a alteração da condição de pagamento sem cobertura cambial para outra com cobertura cambial é necessário desapropriar o(s) item(ns).//STR0039	"Aviso"
                      EndIf
                      M->EEC_COBCAM := cCobCam
                      WorkIp->(DbGoto(nRecno))
                      lRet := .F.
                      Break
                   EndIf
                WorkIp->(DBSkip())
                EndDo
                WorkIp->(DbGoto(nRecno))
             EndIf

             AE102(SY6->Y6_MDPGEXP)

             If !ExistCpo("SY6",M->EEC_CONDPA) //RMD - 06/09/05 - Impede que seja gerado um embarque com uma condição de pag. inexistente
                lRet := .F.
                Break
             EndIf


             If cCAMPO = "EEC_CONDPA"  // By JPP - 22/09/2005 - 17:55 - Carregar automaticamente o campo Cobertura cambial(EEC_COBCAM)
                AE101CobCamb("EEC_CONDPA")
             EndIf
             lRefresh := .T.

        CASE cCAMPO == "EEC_NPARC"
           IF M->EEC_DIASPA != -1 .And. M->EEC_DIASPA <= 900
              IF !EMPTY(M->EEC_NPARC)
                 M->EEC_PARCEL := (AE100VLPROC()-M->EEC_ANTECI)/M->EEC_NPARC
              ENDIF
           ENDIF

        CASE cCAMPO == "EEC_NRAVSG"
           //IF ( !EMPTY(M->EEC_NRAVSG) )
           //   nNRAVSG   := VAL(LEFT(M->EEC_NRAVSG,AT("/",M->EEC_NRAVSG)-1))
           //    IF (nNRAVSG<VAL(LEFT(EasyGParam("MV_NRAVSG"),AT("/",EasyGParam("MV_NRAVSG"))-1)))
           //       HELP(" ",1,"AVG0000084")
           //       lRET:=.F.
           //    ENDIF
           //ENDIF

        CASE cCAMPO == "EEC_DTCONH"
           IF ( EMPTY(M->EEC_DTINVO ))
              //AST - 02/07/08 - Se a Data de conhecimento estiver vazia, usa a data-base
              IF ( !EMPTY(M->EEC_DTCONH))
                 M->EEC_DTINVO:=M->EEC_DTCONH+POSICIONE("SY6",1,XFILIAL("SY6")+M->EEC_CONDPA+STR(M->EEC_DIASPA,AVSX3("EEC_DIASPA",AV_TAMANHO)),"Y6_DIAS_PA")
              ELSE
                 M->EEC_DTINVO:=DDATABASE+POSICIONE("SY6",1,XFILIAL("SY6")+M->EEC_CONDPA+STR(M->EEC_DIASPA,AVSX3("EEC_DIASPA",AV_TAMANHO)),"Y6_DIAS_PA")
              ENDIF
              lREFRESH:=.T.

           ENDIF
           // by CAF 30/01/2003 Compatibilizacao EEQ M->EEC_CBVCT  := IF(EMPTY(M->EEC_CBVCT).AND.!EMPTY(M->EEC_DTCONH),(M->EEC_DTCONH+M->EEC_DIASPA),M->EEC_CBVCT)
        CASE cCAMPO == "EEC_LIBSIS"  //liberacao siscomex
           IF ( EMPTY(M->EEC_LIBSIS) )
              M->EEC_STASIS := SI_AS //AGUARDANDO LIBERACAO SISCOMEX
           ELSEIF !EMPTY(M->EEC_LIBSIS) .AND. M->EEC_STASIS==SI_AS
              M->EEC_STASIS := SI_LS //AGUARDANDO ENVIO SISCOMEX
           ENDIF

        CASE cCAMPO == "EEC_NRINVO" //Nr. Invoice
          /* IF EMPTY(M->EEC_NRINVO) // By JPP - 08/06/2005 14:20 - A inicialização do campo passou a ser feita via gatilho.
              M->EEC_NRINVO:=M->EEC_PREEMB
           Endif */
           lRet := AE102NrInvo()

        CASE cCAMPO = "EEC_MPGEXP"
             AE101CobCamb("EEC_MPGEXP")// By JPP - 22/09/2005 - 17:55 - Carregar automaticamente o campo Cobertura cambial(EEC_COBCAM)

             If M->&(cCampo) == "006"  // GFP - 12/11/2012 - Sem Cobertura Cambial
                nTotVlrSCob := M->EEC_TOTPED
             Else
                nTotVlrSCob := 0
             EndIf

             If lIntDraw
                /*AOM - 04/07/2011 - Tratamento que verifica se os itens possue apropriação dos itens
                  no drawback e se a condição de pagt está ao contrario da selecionada (Com cobert ou Sem cobert) */
                cCobCam := M->EEC_COBCAM

                //Verifica se os itens estao com apropriação
                If Select("WorkAnt") > 0
                   WorkAnt->(dbSetOrder(1))
                   lSeekAnt :=  WorkAnt->(dbSeek(WorkIP->EE9_ATOCON+M->EEC_PREEMB+WorkIP->EE9_PEDIDO+WorkIP->EE9_SEQUEN+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,WorkIP->EE9_SEQEMB,"")))//AOM - 29/08/2011
                Else
                   EDD->(dbSetOrder(3))
                   lSeekAnt :=  EDD->(dbSeek(xFilial("EDD")+M->EEC_PREEMB+WorkIP->EE9_PEDIDO+WorkIP->EE9_SEQUEN+WorkIP->EE9_COD_I+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,WorkIP->EE9_SEQEMB,"")))//AOM - 29/08/2011
                EndIf

                nRecno := WorkIp->(Recno())
                WorkIp->(DbGoTop())
                While WorkIp->(!Eof())
                   If !Empty(WorkIP->WP_FLAG) .And. !Empty(WorkIP->EE9_ATOCON) .And. !Empty(WorkIP->EE9_SEQED3) .And. cCobCam  <>  M->EEC_COBCAM  .And. lExistEDD .And. lSeekAnt
                      If cCobCam == "1"
                         EasyHelp(STR0134,STR0039)// STR0134	"Existem item(ns) do Embarque com apropriação do Ato Concessório. Para efetuar a alteração da Modalidade de Exportação com cobertura cambial para outra sem cobertura cambial é necessário desapropriar o(s) item(ns)." //STR0039	"Aviso"
                      Else
                         EasyHelp(STR0135,STR0039) // STR0135	"Existem item(ns) do Embarque com apropriação do Ato Concessório. Para efetuar a alteração da Modalidade de Exportação sem cobertura cambial para outra com cobertura cambial é necessário desapropriar o(s) item(ns)." //STR0039	"Aviso"
                      EndIf
                      M->EEC_COBCAM := cCobCam
                      WorkIp->(DbGoto(nRecno))
                      lRet := .F.
                      Break
                   EndIf
                   WorkIp->(DBSkip())
                EndDo
                WorkIp->(DbGoto(nRecno))
             EndIf
             AE102(M->EEC_MPGEXP)
             AE101CobCamb("EEC_MPGEXP") // By JPP - 22/09/2005 - 17:55 - Carregar automaticamente o campo Cobertura cambial(EEC_COBCAM)
        CASE cCAMPO = "EE9_DTRE"
             IF NAOVAZIO(M->EE9_RE) .AND. VAZIO(M->EE9_DTRE)
                NAOVAZIO()
                lRET := .F.
             ElseIf Empty(M->EE9_RE) .And. !Empty(M->EE9_DTRE)
                EasyHelp(STR0098,STR0058) // By JPP - 13/09/2005 -09:30 - Não permitir a digitação da data do RE quando o campo numero do RE estiver em branco.
                lRet := .F.
             EndIf
             If EE9->(FieldPos("EE9_PERIE")) > 0 .AND. EE9->(FieldPos("EE9_BASIE")) > 0 .AND. EE9->(FieldPos("EE9_VLRIE")) > 0   // GFP - 17/12/2015
                If Posicione("SX3",2,"EE9_PERIE","X3_TRIGGER") == "S"
                   RunTrigger(1)
                EndIf
             EndIf
        CASE cCAMPO = "EE9_RE"

           If !Empty(M->EE9_RE)
               // MFR 27/04/2017 TE-5414 WCC-511226
               // If !AE100VLDRESD(M->EE9_RE, "EE9_RE")
              If !AE100VLDRESD(M->EE9_RE, "EE9_RE", EEC->EEC_PREEMB)
                 lRet := .F.
                 Break
              EndIf
              If Len(AllTrim(M->EE9_RE)) < 12 .or. Val(Right(AllTrim(M->EE9_RE), 3)) = 0
                 EasyHelp(STR0136, STR0048) // STR0136 "O numero do RE deve possuir doze digitos e os três ultimos digitos não podem ser preenchidos com zero pois refere-se a sequência do RE."//AOM - 22/09/10
                 lRet := .F.
              EndIf
              If /*lConsign .And.*/ Empty(cTipoProc) .Or. cTipoProc == PC_RC //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
                 If !Empty(WorkIp->EE9_RE) .And. WorkIp->EE9_RE == M->EE9_RE
                    Break
                 EndIf
                 If WkEY6->(DbSeek(M->EE9_RE))
                    If AvTransUnid(M->EE9_UNIDAD, WkEY6->EY6_UNIDAD, M->EE9_COD_I, M->EE9_SLDINI, .F.) > WkEY6->EY6_SLDATU
                       EasyHelp(STR0111, STR0048)//"Não é possível vincular o RE informado pois o mesmo não possui saldo disponível para vinculação"###"Atenção"
                       lRet := .F.
                       Break
                    EndIf
                    EER->(DbSetOrder(3))
                    If EER->(DbSeek(xFilial("EER")+Left(M->EE9_RE,9)))
                       M->EE9_DTRE := EER->EER_DTGERS
                    EndIf
                 Else
                    EY6->(DbSetOrder(2))
                    If !EY6->(DbSeek(xFilial()+M->EE9_RE))
                       EasyHelp(STR0113, STR0048)//"Não foi encontrado nenhum RE cadastrado no sistema com o código informado."###"Atenção"
                       lRet := .F.
                       Break
                    EndIf
                    If AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, M->EE9_SLDINI, .F.) > EY6->EY6_SLDATU
                       EasyHelp(STR0111, STR0048)//"Não é possível vincular o RE informado pois o mesmo não possui saldo disponível para vinculação"###"Atenção"
                       lRet := .F.
                       Break
                    EndIf


                    EER->(DbSetOrder(3))
                    If EER->(DbSeek(xFilial("EER")+Left(M->EE9_RE,9)))
                       M->EE9_DTRE := EER->EER_DTGERS
                    EndIf

                 EndIf

              EndIf
              If EE9->(FieldPos("EE9_PERIE")) > 0 .AND. EE9->(FieldPos("EE9_BASIE")) > 0 .AND. EE9->(FieldPos("EE9_VLRIE")) > 0   // GFP - 17/12/2015
                 If Posicione("SX3",2,"EE9_PERIE","X3_TRIGGER") == "S"
                    RunTrigger(1)
                 EndIf
              EndIf
           EndIf

        CASE cCAMPO = "EE9_NRSD"
           If !Empty(M->EE9_NRSD)
            // MFR 27/04/2017 TE-5414 WCC-511226
            // If !AE100VLDRESD(M->EE9_NRSD, "EE9_NRSD")
              If !AE100VLDRESD(M->EE9_NRSD, "EE9_NRSD", EEC->EEC_PREEMB)
                 lRet := .F.
                 Break
              EndIf
           EndIf

         CASE cCAMPO = "EE9_FPCOD"
            lRet := VAZIO() .OR. EXISTCPO("SYC",M->EE9_FPCOD,1)

         CASE cCAMPO = "EE9_GPCOD"
           If !Empty(M->EE9_GPCOD)
              EEH->(dbSetOrder(1))
              If !EEH->(dbSeek(xFilial("EEH")+AVKEY(M->EEC_IDIOMA,"EEH_IDIOMA")+AVKEY(M->EE9_GPCOD,"EEH_COD")))
                 Help(" ",1,"REGNOIS")
                 lRet := .F.
                 Break
              EndIf
           EndIf

         CASE cCAMPO = "EE9_DPCOD"
            lRet := VAZIO() .OR. EXISTCPO("EEG",M->EEC_IDIOMA+M->EE9_DPCOD,1)

        CASE cCAMPO $ "EEC_CONSIG|EEC_COLOJA"
            lRet := TEVlCliFor(M->EEC_CONSIG,M->EEC_COLOJA,"SA1","2|4")

        //Case cCampo == "EE9_CODAGE"
        Case cCampo $ "EE9_CODAGE/EE9_TIPCOM"
           If !Empty(M->EE9_CODAGE)
              //If WorkAg->(DbSeek(M->EE9_CODAGE+CD_AGC)) - JPM - 01/06/05
              If WorkAg->(DbSeek(M->EE9_CODAGE+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+;
                                 If(EE9->(FieldPos("EE9_TIPCOM")) > 0,M->EE9_TIPCOM,"")))

                 If WorkAg->EEB_TIPCVL = "1" // Percentual.
                    M->EE9_PERCOM := WorkAg->EEB_VALCOM
                    M->EE9_VLCOM  := Round(M->EE9_PRCINC*(M->EE9_PERCOM/100),AVSX3("EE9_VLCOM",AV_DECIMAL))

                 ElseIf WorkAg->EEB_TIPCVL = "2" // Valor Fixo.
                    M->EE9_PERCOM := 0
                    M->EE9_VLCOM  := WorkAg->EEB_VALCOM
                 Else // Percentual por item.
                    M->EE9_PERCOM := 0
                    M->EE9_VLCOM  := 0
                 EndIf
              EndIf
           Else
              M->EE9_PERCOM := 0
              M->EE9_VLCOM  := 0
           EndIf

        Case cCampo == "EEC_INTERM"
           If ALTERA .And. EEC->EEC_INTERM == M->EEC_INTERM .And. !INCLUI
              Break
           EndIf

           //** RMD - Valida os itens já vinculados
           nRec := WorkIp->(Recno())
           WorkIp->(DbGoTop())
           aIpItens := {}
           While WorkIp->(!Eof())
              If WorkIp->WP_FLAG <> "  " .And. EE7->(DbSeek(xFilial()+WorkIp->EE9_PEDIDO)) .And. EE7->EE7_INTERM <> M->EEC_INTERM
                 aAdd(aIpItens, WorkIp->({EE9_PEDIDO, EE9_SEQEMB}))
              EndIf
              WorkIp->(DbSkip())
           EndDo
           WorkIp->(DbGoTo(nRec))
           If Len(aIpItens) > 0
              aMsg := {}
              aAdd(aMsg, {STR0118, .T.})//"Os seguintes itens vinculados ao embarque fazem parte de processos com opção de tratamento de Off-Shore diferente da escolhida."
              aAdd(aMsg, {STR0119, .T.})//"Para poder alterar esta opção, é necessário desvincular os itens primeiro."
              aAdd(aMsg, {EECMontaMsg({"EE9_PEDIDO", "EE9_SEQEMB"}, aIpItens), .F.})
              EECView(aMsg, STR0058)  //"Atenção"
              lRet := .F.
              Break
           EndIf
           //**


              //cFilEx := AvKey(EasyGParam("MV_AVG0024",,""),"EE9_FILIAL")
              /*
              nRec := EEC->(RecNo())
              EEC->(DbSetOrder(1))
              If EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))
                 If !Empty(EEC->EEC_DTEMBA)
                    lRet := .f.
                 EndIf
              EndIf
              EEC->(DbGoTo(nRec))

              If !lRet
                 MsgStop(STR0049+ENTER+; //"Problema:"
                         STR0050+AllTrim(Transf(M->EEC_PREEMB,AvSx3("EEC_PREEMB",AV_PICTURE)))+STR0051+ENTER+; //"O processo '"###"' já foi embarcado na filial OffShore e não "
                         STR0052,STR0058) //"poderá ser alterado/cancelado/excluído." //"Atenção"
              EndIf
              */

         // JPP - 11/01/05 - 11:15 - Na alteração do Pais é verificado se existe normas vinculadas a produtos.
         Case cCampo == "EEC_PAISET"
              If lMENSA
                 AP100Normas(OC_EM)
              EndIf

         Case cCampo == "EEC_TSISC" // FJH 13/10/05 ADICIONANDO CONSISTENCIA DO CAMPO EEC_TSISC
            Do Case
               Case M->EEC_TSISC == "1" // O campo RE deve estar preenchido em todos os itens
                  WorkIp->(dbGoTop())
                  While WorkIp->(!EOF())
                     If Empty(WorkIp->EE9_RE)
                        lRet := .F.
                     Endif
                     WorkIp->(dbSkip())
                  End
                  If !lRet
                     EasyHelp(STR0099) // "De acordo com o tipo siscomex escolhido, o RE deve estar preenchido em todos os itens do embarque"
                  Endif

               //JAP - Criado o parâmetro MV_AVG0121 e a variável nTotDSE para definição do teto do total do pedido para geração da DSE.
               Case ( M->EEC_TSISC == "3" .or. M->EEC_TSISC == "4" ) // EEC_TOTPED < 10.000
                  nTotDSE := EasyGParam("MV_AVG0121",,10000)
                  If M->EEC_TOTPED >= nTotDSE
                        EasyHelp(STR0100+Alltrim(Str(nTotDSE))) // "De acordo com o tipo siscomex escolhido, O total do pedido deve ser menor que"
                        lRet := .F.
                  EndIf

               Case ( M->EEC_TSISC == "5" .or. M->EEC_TSISC == "6" .or. M->EEC_TSISC == "7" ) // DSE deve estar preechido
                  If Type("EXL->EXL_DSE") <> "U"
                     If Empty( M->EXL_DSE )
                        EasyHelp(STR0101) // "De acordo com o tipo siscomex escolhido, O campo DSE deve estar preenchido"
                        lRet := .F.
                     Endif
                  Endif

               Case M->EEC_TSISC == "8" // O campo RE deve estar vazio em todos os itens
                  WorkIp->(dbGoTop())
                  While WorkIp->(!EOF())
                     If !Empty(WorkIp->EE9_RE)
                        lRet := .F.
                     Endif
                     WorkIp->(dbSkip())
                  End
                  If IsVazio("WorkNF") .And. !lRet
                     EasyHelp(STR0102) // "De acordo com o tipo siscomex escolhido, o RE deve estar vazio em todos os itens do embarque"
                  Else
                     lRet := .T.
                  Endif

               Case M->EEC_TSISC == "9" // EEC_AMOSTR $ cSim
                  If !(M->EEC_AMOSTR <> "3") //!(M->EEC_AMOSTR $ cSim)
                     EasyHelp(STR0103) // "De acordo com o tipo siscomex escolhido, O campo amostra deve ser preenchido com SIM"
                     lRet := .F.
                  Endif

               Otherwise // O campo foi preenchido incorretamente
                  If !Empty(M->EEC_TSISC)
                     EasyHelp(STR0104) // "Tipo Siscomex Inválido"
                     lRet := .F.
                  Endif
            End Case

         Case cCampo == "EEC_DTREC"
            EXL->(DbSetOrder(1))
            If !Empty(M->EEC_DTREC)
               If Empty(M->EEC_DTEMBA)
                  EasyHelp(STR0108, STR0058)//"Não é possível informar a data de recebimento antes de informar a data de embarque."###Atenção
                  lRet := .F.
                  Break
               ElseIf M->EEC_DTREC < M->EEC_DTEMBA
                  EasyHelp(STR0109, STR0058)//"Não é possível informar uma data de recebimento inferior a data de embarque."##"Atenção"
               EndIf
               If EXL->(DbSeek(xFilial()+M->EEC_PREEMB))
                  If !Empty(EXL->EXL_DTREC) .And. EXL->EXL_DTREC <> M->EEC_DTREC .And. Ae108ChkArm(M->EEC_IMPORT, M->EEC_IMLOJA, M->EEC_PREEMB)
                     EasyHelp(STR0107, STR0058)//"Não é possível alterar a data porque um ou mais itens possuem vinculação em vendas de consignação."###Atenção
                     lRet := .F.
                     Break
                  EndIf
               EndIf
               M->EEC_STATUS := ST_EC
            Else
               If EXL->(DbSeek(xFilial()+M->EEC_PREEMB))
                  If !Empty(EXL->EXL_DTREC) .And. Ae108ChkArm(M->EEC_IMPORT, M->EEC_IMLOJA, M->EEC_PREEMB)
                     EasyHelp(STR0107, STR0058)//"Não é possível alterar a data porque um ou mais itens possuem vinculação em vendas de consignação."###Atenção
                     lRet := .F.
                     Break
                  EndIf
               EndIf
               If !Empty(M->EEC_DTEMBA)
                  M->EEC_STATUS := ST_TR
               EndIf
            EndIf
            M->EEC_STTDES := Tabela("YC", M->EEC_STATUS)

         //OAP - 26/01/2011 - Adequação para os códigos de enquadramento
         Case cCampo == "EEC_ENQCO1"
            If Empty(M->EEC_ENQCOX) .AND. !Empty(M->EEC_ENQCOD) //.AND. !Empty(M->EEC_ENQCO1)
               If FindFunction("AS100V_Enq")
                  lRet := AS100V_Enq(M->EEC_ENQCO1,M->EEC_ENQCOD)
               EndIf
            EndIf

         //OAP - 26/01/2011 - Adequação para os códigos de enquadramento
         Case cCampo == "EEC_ENQCO2"
            If Empty(M->EEC_ENQCOX) .AND. !Empty(M->EEC_ENQCOD) .AND. !Empty(M->EEC_ENQCO1) //.AND. !Empty(M->EEC_ENQCO2)
               If FindFunction("AS100V_Enq")
                  lRet := AS100V_Enq(M->EEC_ENQCO2,M->EEC_ENQCOD,M->EEC_ENQCO1)
               EndIf
            EndIf

         //OAP - 26/01/2011 - Adequação para os códigos de enquadramento
         Case cCampo == "EEC_ENQCO3"
            If Empty(M->EEC_ENQCOX) .AND. !Empty(M->EEC_ENQCOD) .AND. !Empty(M->EEC_ENQCO1) .AND. !Empty(M->EEC_ENQCO2) //.AND. !Empty(M->EEC_ENQCO3)
               If FindFunction("AS100V_Enq")
                  lRet := AS100V_Enq(M->EEC_ENQCO3,M->EEC_ENQCOD,M->EEC_ENQCO1,M->EEC_ENQCO2)
               EndIf
            EndIf

		 // GCC - 13/05/2013 - Habilita validação do código informado com o cadastro de disponibilidade de navios
         Case cCampo == "EEC_EMBARC" .And. lVldEmb
         	If !Empty(M->EEC_EMBARC)
	         	If !ExistCpo("EE6",M->EEC_EMBARC)
	      			lRet:= .F.
					EasyHelp(STR0138, STR0140) // "O código informado no campo embarcação não esta cadastrado. Favor verificar o cadastro de disponibilidade de navios!", "Aviso - Disponibilidade de Navio")
				EndIf
			EndIf

		 // GCC - 13/05/2013 - Habilita validação de inclusão de numero de viagens, somente se o mesmo estiver cadastrado na tabela disponibilidade de navio (EE6)
         Case cCampo == "EEC_VIAGEM" .And. lVldVia
         	If !Empty(M->EEC_VIAGEM)
	 			If !ExistCpo("EE6",M->EEC_EMBARC+M->EEC_VIAGEM)
	      			lRet:= .F.
					EasyHelp(STR0139, STR0141) // "O número de voo / viagens informado não está cadastrado. Favor verificar o cadastro de disponibilidade de navios!", "Aviso - Número de Voo / Viagens"
				EndIf
			EndIf
         Case (cCampo == "EE7_TPDESC" .OR. cCampo == "EEC_TPDESC") .AND. lExistTpDesc     // GFP - 08/07/2013 - Validação dos campos Tp. Desconto.
            If (cCampo == "EEC_TPDESC" .AND. !Empty(M->EEC_DTEMBA)) .OR. cCampo == "EE7_TPDESC"  // GFP - 04/02/2014
               If !Empty(M->&(cCampo))
                  If !Pertence('12',M->&(cCampo))
                     lRet := .F.
                  Else
                     lRet := .T.
                  EndIf
               Else
                  lRet := .F.
               EndIf
            Else
               lRet := .T.
            EndIf

            //RMD - 28/10/14 - Recalcula os preços na troca do campo
            If cCampo == "EE7_TPDESC"
	            Ap100PrecoI(.T.)
	        Else
		        Ae100PrecoI(.T.)
	        EndIf

        //LBL - 01/11/13
        CASE cCAMPO="EXL_DSE"
        	IF !Empty(M->EXL_DSE)
        	   nRecNo := WorkIP->(Recno())
        	   WorkIP->(DbGoTop())
                  While WorkIP->(!Eof())
        	         If !Empty(WorkIP->EE9_NRSD)
        		        EasyHelp(STR0142, STR0133)/*"Não é possível informar o número da Declaracao Simp. Exporta. pois existem itens com Nr. Solicitacao Despacho  informada.","Aviso"*/
        			    lRet := .F.
          			    Exit
        		     EndIf
        		   WorkIP->(DbSkip())
        	      EndDo
        	   WorkIP->(DbGoTo(nRecNo))
            ENDIF

         CASE cCAMPO == "EEC_EMBAFI"     // GFP - 07/01/2014
            If !Empty(M->EEC_EMBAFI)
               If EasyGParam("MV_EEC0037",,.F.)
                  AE100CRIT("EEC_QTDEMB")
               EndIf
            Else
               M->EEC_PESBRU := nTotPesBru
            EndIf

         CASE cCAMPO == "EEC_QTDEMB"     // GFP - 07/01/2014
            If !Empty(M->EEC_EMBAFI)
               EE5->(DbSetOrder(1))  //EE5_FILIAL+EE5_CODEMB
               EE5->(DbSeek(xFilial("EE5")+M->EEC_EMBAFI))
               If nPesBrEmb # EE5->EE5_PESO * M->EEC_QTDEMB
                  nTotPesBru := nTotPesBru - nPesBrEmb
                  nPesBrEmb := EE5->EE5_PESO * M->EEC_QTDEMB
                  M->EEC_PESBRU := nTotPesBru + nPesBrEmb
                  nTotPesBru := M->EEC_PESBRU
               EndIf
            Else
               M->EEC_QTDEMB := 0
               nPesBrEmb := 0
            EndIf

         CASE cCAMPO == "EYY_NROMEX" .OR. cCAMPO == "EYY_DTMEX"   // GFP - 05/03/2014
            dDtME    := If(Type("M->EYY_DTMEX") <> "U"  .AND. !Empty(M->EYY_DTMEX), M->EYY_DTMEX, Wk_NFRem->EYY_DTMEX)
            cMemoExp := If(Type("M->EYY_NROMEX") <> "U"  .AND. !Empty(M->EYY_NROMEX), M->EYY_NROMEX, Wk_NFRem->EYY_NROMEX)
            If cCAMPO == "EYY_DTMEX" .AND. Empty(dDtME) .AND. !Empty(Wk_NFRem->EYY_NROMEX)
               EasyHelp("A data do Memorando de Exportação deve ser informada","Atenção!")
               Return .F.
            EndIf
            If !Empty(dDtME) .AND. !Empty(cMemoExp)
               nRecno := Wk_NFRem->(Recno())
               Wk_NFRem->(DbGoTop())
               Do While Wk_NFRem->(!Eof()) .AND. lRET
                  //If Wk_NFRem->EYY_NROMEX == cMemoExp .AND. Wk_NFRem->EYY_DTMEX == dDtME .AND. Wk_NFRem->(Recno()) <> nRecno - RMD 07/11/14 - A comparação da data estava incorreta.
                  If Wk_NFRem->EYY_NROMEX == cMemoExp .AND. Wk_NFRem->EYY_DTMEX <> dDtME .AND. Wk_NFRem->(Recno()) <> nRecno
                     EasyHelp("Não é possível informar o mesmo número de Memorando de Exportação para datas diferentes.","Atenção!")
                     lRET := .F.
                     Exit
                  EndIf
                  Wk_NFRem->(DbSkip())
               EndDo
               Wk_NFRem->(DbGoTo(nRecno))
            EndIf

         Case cCampo == "EEC_DESSEG" //LRS - 11/09/2015
         	AE100Crit("EEC_SEGURO",.F.)

         Case cCampo == "EEC_DUEAVR"
            if ! empty(M->EEC_DUEAVR) .and. ! empty(M->EEC_DTDUE) .and. M->EEC_DUEAVR < M->EEC_DTDUE
               lRet := .F.
               EasyHelp("Não é possível informar uma data de averbação menor que a data da DUE.","Atenção!")
            endif

      End Case
   End Sequence
   RESTORD(aORD)
   dbSelectArea(cOldArea)
RETURN lRET 

/*
Funcao      : AE100WkrEmb
Parametros  :
Retorno     : nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/07/99 15:41
Revisao     :
Obs.        :
*/
Function AE100WkEmb(cEmbarq,cSeqEmb,cEmb,cPedido,cSequen,lProc)

Local nRecWork := WorkEm->(RecNo())
Local aOrd := SaveOrd("EEK")
Local cEmbOld

Default lProc := .f. // Carrega os dados do Processo ?

Begin Sequence

   IF ! Inclui .And. WorkEm->(Eof() .And. Bof())
      // Alteracao/Visual/Exclusao, primeira vez ...

      // ***
      If !EasyGParam("MV_AVG0005") //ER - 12/07/06 - Adição da verificação do parametro MV_AVG0005.

         EEK->(dbSetOrder(2))
         EEK->(dbSeek(xFilial()+OC_EM+cEmbarq))

         While ! EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
                 EEK->EEK_TIPO == OC_EM .And. EEK->EEK_PEDIDO == cEmbarq

            WorkEm->(RecLock("WorkEm", .T.))

            AVReplace("EEK","WorkEm")

            WorkEm->(MsUnlock())

            EEK->(dbSkip())
         Enddo

      Else

         EEK->(dbSetOrder(1))
         EEK->(dbSeek(xFilial()+OC_EMBA+cEmb))

         While ! EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
               EEK->EEK_TIPO == OC_EMBA .And. EEK->EEK_CODIGO == cEmb

            WorkEm->(RecLock("WorkEm", .T.))

            AvReplace("EEK","WorkEm")

            WorkEm->EEK_PEDIDO := cEmbarq
            WorkEm->EEK_SEQUEN := cSeqEmb

            WorkEm->(MsUnlock())

            EEK->(dbSkip())
         Enddo

      EndIf
      Break

   EndIf

    IF WorkEm->(dbSeek(cEmbarq+cSeqEmb)) .And.;
        WorkEm->EEK_CODIGO != cEmb

        // Usuario alterou a 1¦ embalagem ...
        cEmbOld := WorkEm->EEK_CODIGO
        WorkEm->(dbSeek(cEmbarq+cSeqEmb+cEmbOld))
        While ! WorkEm->(Eof()) .And. WorkEm->(EEK_PEDIDO+EEK_SEQUEN+EEK_CODIGO) ==;
                                    cEmbarq+cSeqEmb+cEmbOld

        WorkEm->(dbDelete())
        WorkEm->(dbSkip())
        Enddo
        WorkEm->(dbGoTop())
    Else
        WorkEm->(dbGoTo(nRecWork))
    Endif

   IF ! WorkEm->(dbSeek(cEmbarq+cSeqEmb))
      IF lProc .and. !EasyGParam("MV_AVG0005") //ER - 12/07/06 - Adição da verificação do parametro MV_AVG0005.
         EEK->(dbSetOrder(2))
         EEK->(dbSeek(xFilial()+OC_PE+cPedido+cSequen))

         While ! EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
               EEK->EEK_TIPO == OC_PE .And.;
               EEK->EEK_PEDIDO == cPedido .And. EEK->EEK_SEQUEN==cSequen

            WorkEm->(RecLock("WorkEm", .T.))

            AVReplace("EEK", "WorkEm")

            WorkEm->EEK_PEDIDO := cEmbarq
            WorkEm->EEK_SEQUEN := cSeqEmb

            WorkEm->(MsUnlock())

            EEK->(dbSkip())
         Enddo
      Else
         EEK->(dbSetOrder(1))
         EEK->(dbSeek(xFilial()+OC_EMBA+cEmb))

         While ! EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
               EEK->EEK_TIPO == OC_EMBA .And. EEK->EEK_CODIGO == cEmb

            WorkEm->(RecLock("WorkEm", .T.))

            AvReplace("EEK","WorkEm")

            WorkEm->EEK_PEDIDO := cEmbarq
            WorkEm->EEK_SEQUEN := cSeqEmb

            WorkEm->(MsUnlock())

            EEK->(dbSkip())
         Enddo
      Endif

      AE100CALC("EMBALA")

   Endif
End Sequence

RestOrd(aOrd)

Return NIL


/*
Funcao      : AE100PrecoI
Parametros  : lCalc -> .t. - Calcula os totais.
                       .f. - Verifica o MV_AVG0059 para calcular ou não os totais.
              lMsg ->  .T. - Apresenta mensagens.
                       .F. - Não apresenta mensagens.
Retorno     :
Objetivos   : Regras de formacao de preco com incoterm
Autor       : Cristiano A. Ferreira
Data/Hora   : 31/07/99 11:18
Revisao     :
Obs.        :
*/
*-------------------------*
FUNCTION AE100PrecoI(lCalc, lMsg)
*-------------------------*
Local nRecWork := WorkIP->(RecNo()), nRecAtual
Local nFator, /*nTotRateio := 0, JPM*/ nPrecoTot, nPrecoGrvdo := 0
Local nTotPreco := 0, nPreco, /*nAuxDesp, JPM*/ nAuxVal := 0
Local /*nVlDespesas, */ nVlComis := 0
Local lLastRec := .f., nVal, cVar, cAlias
Local bFor := {||  WorkIP->WP_FLAG <> "  "}
LOCAL n1,nFATORFRE:=0,nAUXVALFRE /*nAUXDESPFR,  ;
      nTOTFATFRE := 0,;
      nVLFRETE   := M->EEC_FRPREV+M->EEC_FRPCOM,; JPM */
Local nDECPRC    := EasyGParam("MV_AVG0109",, 4),; //2,; //AVSX3("EE9_PRECO",AV_DECIMAL),;
      nDecTot    := EasyGParam("MV_AVG0110",, 2),; //2,; //AvSx3("EE9_PRCTOT" ,AV_DECIMAL),;//JPM
      cOLDFIL    := WORKIP->(DBFILTER()),;
      bOLDFIL    := &("{|| "+WORKIP->(DBFILTER())+"}"),;
      cRATEIO    := GetNewPar("MV_AVG0021","3"),;
      nQtd       := 0

// ** JPM - 01/04/05
Local i/*, aVlDespesas := {{"EE9_VLFRET",0,0,0,2},; //Frete
                         {"EE9_VLSEGU",0,0,0,2},; //Seguro
                         {"EE9_VLOUTR",0,0,0,2},; //Outras despesas internacionais
                         {"EE9_VLDESC",0,0,0,2} } //Desconto JPM - 12/07/06 - passada para private, para pto entrada*/
Local nDespesas, nVlDesp

/* aVlDespesas por dimensão: aVlDespesas[i][1] = Campo da Despesa no Item
                             aVlDespesas[i][2] = Valor da Despesa rateada pelo item atual
                             aVlDespesas[i][3] = Valor Total da Despesa
                             aVlDespesas[i][4] = Quanto da despesa falta pra ser rateada
                             aVlDespesas[i][5] = Casas Decimais

Obs.: o desconto não é despesa, mas receberá quase o mesmo tratamento
*/

Local lPreco := EasyGParam("MV_AVG0085",,.f.) //Define se o desconto será incluido na formação de preço do item
Local lDespesas := EE9->(FieldPos("EE9_VLFRET")) > 0 .And. ;
                   EE9->(FieldPos("EE9_VLSEGU")) > 0 .And. ;
                   EE9->(FieldPos("EE9_VLOUTR")) > 0 .And. ;
                   EE9->(FieldPos("EE9_VLDESC")) > 0

Local lEEC_VLFOB := EEC->(FieldPos("EEC_VLFOB")) > 0

Local nRound := 8 //Máximo de casas decimais para resultados de divisões no Protheus
Local aDespesas := X3DIReturn(OC_EM)
Local cUnidadeKg := EasyGParam("MV_AVG0031",,"KG")
Local bUnidade := {|x| If(Empty(x),cUnidadeKg,x) }
Local lAcerto  := EasyGParam("MV_AVG0092",,.t.)//Define se haverá acerto nos itens ao final.
Local lIsRepl := (If(Type("lAx100") == "U", .F., lAx100)) .or. (If(Type("lRepEmb") == "U", .F., lRepEmb))
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)
Local lTotRodape := EEC->(FieldPos("EEC_TOTFOB")) # 0  .AND. EEC->(FieldPos("EEC_TOTLIQ")) # 0 //LRS - 21/01/2015
Local lRet := .T.
Private aVlDespesas :=  {{"EE9_VLFRET",0,0,0,2},; //Frete
                         {"EE9_VLSEGU",0,0,0,2},; //Seguro
                         {"EE9_VLOUTR",0,0,0,2},; //Outras despesas internacionais
                         {"EE9_VLDESC",0,0,0,2} } //Desconto
If lDespesas
   For i := 1 to Len(aVlDespesas)
      aVlDespesas[i][5] := AvSx3(aVlDespesas[i][1],AV_DECIMAL) //Casas decimais dos campos de acordo com o SX3
   Next
EndIf
// ** Fim

PRIVATE nTOTAL  := 0, nTOTPED := 0

Default lCalc := .f.
Default lMsg  := .T.

Begin Sequence
   If !lCalc
      If EasyGParam("MV_AVG0059",.t.)
         If !EasyGParam("MV_AVG0059",,.f.)
            Break
         EndIf
      EndIf
   EndIf

   If ReadVar() == "M->EEC_DESCON" .And. (Round(M->EEC_TOTPED,AvSX3("EEC_TOTPED",AV_DECIMAL)) - M->EEC_DESCON) <= 0
      EECView(STR0151,STR0039) //"Valor informado de desconto é superior ou igual ao total FOB!" # "Aviso"
      lRet := .F.
      Break
   EndIf
   
   // Flag para conversao de unidades do preco, peso e quantidade.
   If Type("lConvUnid") == "U"
      lConvUnid := (EEC->(FieldPos("EEC_UNIDAD")) # 0) .And. (EE9->(FieldPos("EE9_UNPES")) # 0) .And.;
                   (EE9->(FieldPos("EE9_UNPRC"))  # 0)
   EndIf

   //MFR 07/11/2019 OSSME-3963 retirado daqui e executado na linha 4237
   // Alterado por Heder M Oliveira - 11/17/1999
   //AE100CRIT("EEC_SEGURO",.F.)

   // ** JPM - 04/04/05
   //nVlDespesas := (M->EEC_SEGPRE+M->EEC_DESPIN+;
   //                AvGetCpo("M->EEC_DESP1")+AvGetCpo("M->EEC_DESP2"))-M->EEC_DESCON

   For i := 1 to Len(aDespesas)
      if !(aDespesas[i][1] $ "FR/FA/SE")
         aVlDespesas[3][3] += M->&(aDespesas[i][2]) //Vl. tot. de outras Desp. Internacionais
      EndIf
   Next

   aVlDespesas[1][3] := M->EEC_FRPREV+M->EEC_FRPCOM //Vl. Total do Frete
   aVlDespesas[2][3] := M->EEC_SEGPRE               //Vl. Total do Seguro
   aVlDespesas[4][3] := M->EEC_DESCON               //Vl. Total do Desconto

   For i := 1 to Len(aVlDespesas)
      aVlDespesas[i][4] := aVlDespesas[i][3]
   Next

   //nAuxDesp    := nVlDespesas
   //nAUXDESPFRE   := nVLFRETE

   // ** JPM - fim

   M->EEC_TOTPED := 0
   If lTotRodape  // GFP - 11/04/2014
      M->EEC_TOTFOB := 0
   EndIf
   AE102TOT(cRATEIO)
   nVlComis := 0

   If EECFlags("COMISSAO")//JPM - 29/01/05
      WorkAg->(DbGoTop())
      While WorkAg->(!Eof())
         If WorkAg->EEB_TIPCOM = "3"/*Deduzir da fatura*/ .And. Left(WorkAg->EEB_TIPOAG,1) = CD_AGC//Ag. Rec. Comi.
            nVlComis += WorkAg->EEB_TOTCOM
         EndIf
         WorkAg->(DbSkip())
      EndDo

      WorkAg->(DbGoTop())
   // *** CAF 19/04/2001
   ElseIf !Empty(M->EEC_VALCOM) .And. M->EEC_TIPCOM == "3" // Tipo de Comissao = Deduzir da Fatura
      IF M->EEC_TIPCVL == "1" // Percentual
         nVlComis := Round((M->EEC_VALCOM/100) * nTotPed,2)//Neste momento, esta variável equivale ao Total FOB
      Else
         nVlComis := M->EEC_VALCOM
      Endif
   Endif

   IF ( M->EEC_PRECOA $ cSim ) //Preço Aberto
      nPrecoTot := nTOTPED
   Else //Preço Fechado

      //nPRECOTOT := nTOTPED-aVlDespesas[1][3]

      ////////////////////////////////////////////////////////////
      //ER - 29/10/2008.                                        //
      //Não considera o valor do Frete para o rateio do Seguro e//
      //das Despesas Internacionais entre os itens.             //
      ////////////////////////////////////////////////////////////
      nPrecoTot := nTotPed
   Endif

   If lTotRodape  // GFP - 11/04/2014
      M->EEC_TOTFOB += nPrecoTot
   EndIf

   WorkIP->(dbGoTop())

   DO While ! WorkIP->(Eof())
      IF ! Eval(bFor)
         WorkIP->(dbSkip())
         Loop
      Endif

      IF nTOTPED != 0

         //*** Rateio do valor do frete
         IF cRATEIO = "1"  // PESO LIQUIDO
            If lConvUnid
               aVlDespesas[1][2] := (aVlDespesas[1][3]/;
                                      AvTransUnid(Eval(bUnidade,M->EEC_UNIDAD), Eval(bUnidade,WorkIp->EE9_UNPES),WorkIp->EE9_COD_I,M->EEC_PESLIQ,.F.))*;
                                         WorkIp->EE9_PSLQTO//WorkIP->EE9_SLDINI
            Else
               aVlDespesas[1][2] := (aVlDespesas[1][3]/M->EEC_PESLIQ)*WorkIp->EE9_PSLQTO//WorkIP->EE9_SLDINI
            Endif

         ELSEIF cRATEIO = "2"  // PESO BRUTO
            If lConvUnid
               aVlDespesas[1][2] := (aVlDespesas[1][3]/;
                                      AvTransUnid(Eval(bUnidade,M->EEC_UNIDAD), Eval(bUnidade,WorkIp->EE9_UNPES),WorkIp->EE9_COD_I,M->EEC_PESBRU,.F.))*;
                                         WorkIp->EE9_PSBRTO//WorkIP->EE9_SLDINI
            Else
               aVlDespesas[1][2] := (aVlDespesas[1][3]/M->EEC_PESBRU)*WorkIp->EE9_PSBRTO//WorkIP->EE9_SLDINI
            Endif
         Else
            If lConvUnid
               nFATORFRE := ROUND(AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,;
                                  WorkIp->EE9_SLDINI,.F.)*Round(WorkIP->EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))/nTOTAL,nRound)
            Else
               nFATORFRE := ROUND(WORKIP->(Round(EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))*EE9_SLDINI)/nTOTAL,nRound)
            EndIf
            aVlDespesas[1][2] := aVlDespesas[1][3] * nFatorFre //JPM - Frete para este item
         Endif
         //*** Final do rateio do frete

         //*** Rateio das demais despesas
         //Busca o preço total de cada item
         IF M->EEC_PRECOA $ cSim
            If lConvUnid
               nFATOR := AvTransUnid(WorkIp->EE9_UNIDAD, WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.);
                         *Round(WorkIP->EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))
            Else
               nFATOR := WorkIP->(Round(EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))*EE9_SLDINI)
            EndIf
         ELSE // se for preço fechado, tira o frete para fazer o rateio, pois o mesmo tem rateio diferenciado
            If lConvUnid
               /*
               nFATOR := (AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.)*;
                         Round(WorkIP->EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))) - aVlDespesas[1][2] //-(nVLFRETE*nFATORFRE) //JPM
               */
               nFator := (AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.)*;
                         Round(WorkIP->EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL)))
            Else
               //nFATOR := WorkIP->(Round(EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))*EE9_SLDINI) - aVlDespesas[1][2] //-(nVLFRETE*nFATORFRE) //JPM
               nFator := WorkIP->(Round(EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))*EE9_SLDINI)
            EndIf
         ENDIF
         //Encontra o fator de proporção do preço de cada um sobre o preço total do processo
         nFator := Round(nFATOR/nPRECOTOT,nRound)

         //Rateia o valor de cada despesa para o item posicionado, utilizando o fator de proporção
         For i := 2 to Len(aVlDespesas)//Começa a partir da segunda posição, pois o frete foi avaliado a parte
            //Tratamento do desconto
            If aVlDespesas[i][1] == "EE9_VLDESC"
               If EasyGParam("MV_AVG0119",,.F.)//Desconto por item
                  //Neste caso o valor do desconto é aplicado diretamente no valor do item, sem interferir nos demais
                  aVlDespesas[i][2] := WorkIp->EE9_DESCON
               Else//Desconto informado na capa do processo
                  //Neste caso o valor do desconto é rateado entre os itens, como as demais despesas
                  aVlDespesas[i][2] := aVlDespesas[i][3] * nFator
               EndIf
            Else//Tratamento das demais despesas (rateadas por item)
               aVlDespesas[i][2] := aVlDespesas[i][3] * nFator
            EndIf
         Next

         If EasyEntryPoint("EECAE100") // ** JPM - 12/07/06 - Ponto de entrada para modificar o rateio das despesas
            ExecBlock("EECAE100",.f.,.f.,{"RATEIO_PRECOI"})
         EndIf
         //*** Final do rateio das demais despesas
      ELSE
         nFator := 0
      Endif

      //nTotRateio += nFator //JPM - 04/04/05
      //nTOTFATFRE += nFATORFRE

      // Verifica se é o último registro
      nRecAtual := WorkIP->(RecNo())
      WorkIP->(dbSkip())

      DO While ! WorkIP->(Eof())
         IF ! Eval(bFor)
            WorkIP->(dbSkip())
            Loop
         Endif
         Exit
      Enddo
      IF WorkIP->(Eof())
         lLastRec := .T.
         // Ultimo registro ...
         /*IF nTotRateio != 1 //JPM - 04/04/05
             nFator += (1-nTotRateio)
         Endif
         nAUXVAL := nAUXDESP
         IF nTOTFATFRE # 1
            nFATORFRE := nFATORFRE+1-nTOTFATFRE
         ENDIF
         nAUXVALFRE := nAUXDESPFR
      ELSE

         nAuxVal    := ROUND(nFator*nVlDespesas,2)
         nAUXVALFRE := ROUND(nFATORFRE*nVLFRETE,2)*/
      Endif

      WorkIP->(dbGoTo(nRecAtual))

       //*** Totaliza o valor das despesas para o item posicionado e faz os ajustes necessários
      nDespesas := 0
      nAuxVal    := 0
      nAuxValFre := 0

      //MFR OSSME-4012 OSSME-05/11/2019
      For i := 1 to Len(aVlDespesas)
          WorkIp->&(aVlDespesas[i][1]) := 0
      Next

      For i := 1 to Len(aVlDespesas)
         //*** Atualiza os valores das despesas para o item nos campos correspondentes
         //Grava no campo de despesa da work o valor calculado.
         //MFR OSSME-4012 05/11/2019
         If aVlDespesas[i][4] > 0
            WorkIp->&(aVlDespesas[i][1]) := Round(aVlDespesas[i][2],aVlDespesas[i][5])
            //Valor restante para ser rateado
            aVlDespesas[i][4] -= WorkIp->&(aVlDespesas[i][1]) //Valor restante para ser rateado
         EndIf   
         //***
         lRefazRateio := .T.
         //*** Acerto dos resíduos
         /*
         Caso o parâmetro 'MV_AVG0092' estiver ligado, a WorkIp estiver posicionada no último registro e a despesa atual possuir algum resíduo
         em relação ao valor da despesa na capa do processo e valor rateado, faz o acerto dos resíduos
         */
         If lAcerto .And. lLastRec .And. aVlDespesas[i][4] <> 0
            While WorkIp->(!Bof())
               If WorkIp->&(aVlDespesas[i][1]) + aVlDespesas[i][4] > 0 //Verifica se com o acerto o valor
                                                                       //continua maior que zero
                  WorkIp->&(aVlDespesas[i][1]) += aVlDespesas[i][4] //efetua o acerto
                  nVal := aVlDespesas[i][4] // valor que será acertado nos campos de preço

                  nValPto := nVal

                  If EasyEntryPoint("EECAE100")
                     ExecBlock("EECAE100", .F., .F., {"PRECOI_ATU_PRECO", aVlDespesas[i][1]})
                  EndIf

                  nVal := nValPto

                  aVlDespesas[i][4] := 0 //valor a ser rateado = 0

                  If WorkIp->(RecNo()) <> nRecAtual //se estiver posicionado em um registro diferente do item atual,
                                                    //tem que fazer acertos nos campos de preço, que já foram
                                                    //calculados
                     If aVlDespesas[i][1] <> "EE9_VLDESC"
                        If !(M->EEC_PRECOA $ cSim)
                           If lConvUnid // Conversao da unidade.
                              nQtd := AvTransUnid(WorkIp->EE9_UNIDAD, WorkIp->EE9_UNPRC, WorkIp->EE9_COD_I,;
                                      WorkIp->EE9_SLDINI,.F.)
                              WorkIp->EE9_PRECOI := Round(((WorkIp->EE9_PRECOI*nQtd)-nVal)/nQtd,nDecPrc)

                           Else
                              WorkIp->EE9_PRECOI := Round((WorkIp->(EE9_PRECOI*EE9_SLDINI)-nVal)/WorkIp->EE9_SLDINI,nDecPrc)
                           EndIf
                           WorkIp->EE9_PRCINC -= nVal
                           //M->EEC_TOTPED -= nVal //RMD - 18/11/14 - Se o preço é fechado não atualiza o TOTPED
                        Else
                           WorkIp->EE9_PRCTOT += nVal
                           M->EEC_TOTPED += nVal//RMD - 18/11/14 - Se o preço é aberto soma também no TOTPED
                           WorkIp->EE9_PRCUN := Round(WorkIp->(EE9_PRCTOT/EE9_SLDINI),nDecPrc)
                        EndIf

                     ElseIf !lPreco
                        /*
                           No caso do desconto, só faz acerto de desconto se o parâmetro 'MV_AVG0085' estiver
                           desligado (caso contrário o desconto não faz parte da formação do preço do item).
                        */
                        If !(M->EEC_PRECOA $ cSim)
                           If lConvUnid // Conversao da unidade.
                              nQtd := AvTransUnid(WorkIp->EE9_UNIDAD, WorkIp->EE9_UNPRC, WorkIp->EE9_COD_I,;
                                      WorkIp->EE9_SLDINI,.F.)

                              //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
                              If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
                                 WorkIp->EE9_PRECOI := Round(((WorkIp->EE9_PRECOI*nQtd)+nVal)/nQtd,nDecPrc)
                              Else
                                 WorkIp->EE9_PRECOI := Round(((WorkIp->EE9_PRECOI*nQtd)-nVal)/nQtd,nDecPrc)
                              EndIf

                           //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
                           Else
                              If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
                                 WorkIp->EE9_PRECOI := Round((WorkIp->(EE9_PRECOI*EE9_SLDINI)+nVal)/WorkIp->EE9_SLDINI,nDecPrc)
                              Else
                                 WorkIp->EE9_PRECOI := Round((WorkIp->(EE9_PRECOI*EE9_SLDINI)-nVal)/WorkIp->EE9_SLDINI,nDecPrc)
                              EndIf
                           EndIf
                           WorkIp->EE9_PRCINC += nVal
                           M->EEC_TOTPED += nVal
                        Else
                           WorkIp->EE9_PRCTOT -= nVal
                           WorkIp->EE9_PRCUN := Round(WorkIp->(EE9_PRCTOT/EE9_SLDINI),nDecPrc)
                        EndIf

                     EndIf

                  EndIf

                  Exit
               EndIf
               WorkIp->(DbSkip(-1))
            EndDo
            WorkIp->(dbGoTo(nRecAtual))
         EndIf

         //*** Totaliza o valor das despesas em variáveis auxiliares para uso em ponto de entrada
         If aVlDespesas[i][1] = "EE9_VLFRET"
            nAuxValFre += WorkIp->&(aVlDespesas[i][1])
            nAuxValFre := Round(nAuxValFre,AVSX3(aVlDespesas[i][1],AV_DECIMAL))
         ElseIf aVlDespesas[i][1] <> "EE9_VLDESC"
            nAuxVal    += WorkIp->&(aVlDespesas[i][1])
         ElseIf !lPreco //só considera o desconto na formação de preço se o MV estiver desligado.
            If M->EEC_PRECOA $ cNao
               //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
               If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CNAO) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. !lSubDesc
                  nAuxVal -= WorkIp->&(aVlDespesas[i][1])
               Else
                  nAuxVal += WorkIp->&(aVlDespesas[i][1])
               EndIf

               nAuxVal := Round(nAuxVal,AVSX3(aVlDespesas[i][1],AV_DECIMAL))
            EndIf
         EndIf
         //***

         //***

         //RMD - 27/11/13 - Isola o valor da depesa na variável nVal antes de totalizar, para possibilitar customização
         nVal := 0

         If aVlDespesas[i][1] <> "EE9_VLDESC"
            //nDespesas += If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
            nVal += If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
         ElseIf !lPreco //só considera o desconto na formação de preço se o MV estiver desligado.
            If M->EEC_PRECOA $ cNao
               //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
               If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CNAO) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. !lSubDesc
                  //nDespesas -= If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
                  nVal += If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2]) //RMD - 28/10/14 - O correto é somar o valor
               /* RMD - 28/10/14 - Faz o acerto somente no calculo do valor TOTAL (sem afetar o FOB)
               Else
                  //nDespesas += If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
                  nVal += If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
                  */
               EndIf
            Else
               //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
               If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CNAO) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. !lSubDesc
                  //nDespesas += If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
                  nVal += If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
               Else
                  //nDespesas -= If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
                  nVal -= If(lAcerto,WorkIp->&(aVlDespesas[i][1]),aVlDespesas[i][2])
               EndIf
            EndIf
         EndIf
         nValPto := nVal
         If EasyEntryPoint("EECAE100")
         	ExecBlock("EECAE100", .F., .F., {"PRECOI_ATU_PRECO", aVlDespesas[i][1]})
         EndIf

         nVal := nValPto

         nDespesas += nVal

         nDespesas := Round(nDespesas,AVSX3(aVlDespesas[i][1],AV_DECIMAL))

      Next
      //*** Final da totalização e ajuste das despesas

      //*** Obtenção do Preço FOB unitário
      IF M->EEC_PRECOA $ cSim
         //No caso de preço aberto o Preço FOB é igual ao preço unitário
         nPRECO := WORKIP->EE9_PRECO
      ELSE
         If WorkIp->EE9_STATUS == "Q"  // GFP - 01/03/2016 - Quando processo cancelado, zera despesas para não gerar valores negativos em tela.
           nDespesas := 0
         EndIf
         //No caso de preço fechado o Preço FOB é igual ao preço unitário menos o valor das despesas por unidade
         If lConvUnid
            nQtd := AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.)
            //nPRECO := (WorkIp->EE9_PRECO*nQtd-nDespesas)/nQtd
            nPRECO := (Round(WorkIp->EE9_PRECO*nQtd, nDecPrc)-nDespesas)/nQtd
         Else
            //nPRECO := (WORKIP->(EE9_PRECO*EE9_SLDINI)-nDespesas)/WORKIP->EE9_SLDINI
            nPRECO := (Round(WORKIP->(EE9_PRECO*EE9_SLDINI), nDecPrc)-nDespesas)/WORKIP->EE9_SLDINI
         EndIf
      ENDIF
      //***

      /* by jbj - 14/10/05 - PARA ACERTAR ARREDONDAMENTO - Para os processos com preço fechado, o sistema gerava não conformidade na apuração do
                             valor total do processo.

        ER - 11/10/07 - Permite o controle de arredondamento pelo parametro, para clientes que alteram o número de casa decimais do
                        preço Fob Unitário.
      */
      nPreco := ROUND(nPRECO,nDECPRC)

      WorkIP->EE9_PRECOI := nPreco
      nTotPreco          += nPreco
      nPrecoGrvdo        += WorkIP->EE9_PRECOI

      //*** Calcula o Valor Total e o Valor Total FOB com base nos preços unitários
      If lConvUnid
         nQtd := AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.)
		 WorkIP->EE9_PRCTOT := ROUND((nPreco*nQtd)+nDespesas,nDecTot)
         WorkIP->EE9_PRCINC := ROUND(nPreco*nQtd,nDecTot)

      Else
         WorkIP->EE9_PRCTOT := ROUND((nPreco*WorkIP->EE9_SLDINI)+nDespesas,nDecTot)
         WorkIP->EE9_PRCINC := ROUND(nPreco*WorkIP->EE9_SLDINI,nDecTot)
      EndIf
      //***

      // by CAF 06/08/2001 14:42 Corrigir problemas de arredondamento
      IF M->EEC_PRECOA $ cSim
         If lConvUnid
            WorkIP->EE9_PRCINC := Round(AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.);
                                        *WorkIP->EE9_PRECO, nDecTot) //2
         Else
            WorkIP->EE9_PRCINC := Round(WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI, nDecTot) //2
         EndIf
      Else
         If lConvUnid
	         //RMD - 28/10/14 - Subtrai o desconto do valor Total sem alterar o FOB
	         If !lPreco .And. (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CSIM .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc)
				WorkIP->EE9_PRCTOT := Round(AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.);
				*WorkIP->EE9_PRECO-WorkIp->EE9_VLDESC, nDecTot) //2
	         Else
				WorkIP->EE9_PRCTOT := Round(AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.);
				*WorkIP->EE9_PRECO, nDecTot) //2
		     EndIf

         Else
            WorkIP->EE9_PRCTOT := Round(WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI, nDecTot) //2
         EndIf
      Endif

      If lConvUnid
         nQtd := AvTransUnid(WorkIp->EE9_UNIDAD, WorkIp->EE9_UNPRC, WorkIp->EE9_COD_I,;
                             WorkIp->EE9_SLDINI,.F.)
      Else
         nQtd := WorkIp->EE9_SLDINI
      EndIf

      If M->EEC_PRECOA $ cSim //JPM - grava o campo de preço unitário no incoterm
         WorkIp->EE9_PRCUN := Round(WorkIp->EE9_PRCTOT/nQtd,nDecPrc)
      Else
         WorkIp->EE9_PRCUN := WorkIp->EE9_PRECO
      EndIf

      // ** Manutenção dos totais da capa e itens do processo.
      aAux:={nAuxVal,nAuxValFre}
      If EasyEntryPoint("EECAE100")
         ExecBlock("EECAE100",.f.,.f.,{"PE_PRECOI",aAux})
      EndIf

      //nAuxDesp   := nAUXDESP-nAuxVal        /// RATEIO DESPESAS SEM O FRETE
      //nAUXDESPFR := nAUXDESPFR-nAUXVALFRE   /// RATEIO DO FRETE
      //M->EEC_TOTPED += WorkIP->EE9_PRCINC
      M->EEC_TOTPED += WorkIP->EE9_PRCTOT //ER - 20/11/2007. Realiza o cálculo do total, já com as despesas calculadas.

      WorkIP->(dbSkip())
   Enddo

   If EasyEntryPoint("EECAE100") // ** JPM - 12/07/06 - Ponto de entrada antes do cálculo do TOTPED.
      ExecBlock("EECAE100",.f.,.f.,{"ANTES_TOTPED_PRECOI"})
   EndIf

   /*
   M->EEC_TOTPED += M->EEC_SEGPRE
   M->EEC_TOTPED += M->EEC_FRPREV
   M->EEC_TOTPED += AvGetCpo("M->EEC_DESP1")
   M->EEC_TOTPED += AvGetCpo("M->EEC_DESP2")
   M->EEC_TOTPED += M->EEC_DESPIN
   M->EEC_TOTPED += M->EEC_FRPCOM
   */ //JPM - 04/04/05

   /*   ER - 20/11/2007. O cálculo do preço Total já considera o valor das despesas.
   For i := 1 to Len(aDespesas) //soma as despesas no total do pedido
      M->EEC_TOTPED += M->&(aDespesas[i][2])
   Next
   */

   M->EEC_TOTPED -= nVlComis

   /*
      Caso o parâmetro 'MV_AVG0085' estiver ligado,  o sistema não considerou o desconto na formação do preço dos itens,
      ele será aplicado diretamente no total do processo, independente do preço ser aberto ou fechado.
   */
   If lPreco
      //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
      //RMD - 28/10/14 - Corrigido, estava somando na opção de subtrair e subtraindo na de somar.
      If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. M->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
         M->EEC_TOTPED -= M->EEC_DESCON
      Else
         M->EEC_TOTPED += M->EEC_DESCON
      EndIf
   EndIf

   M->EEC_TOTFOB := Round(M->EEC_VLFOB := EECFob(OC_EM,, .F.), AvSX3("EEC_VLFOB",AV_DECIMAL))//RMD - 18/11/14

   //AAF 30/12/2013 - Arredondar total conforme a quantidade de decimais
   M->EEC_TOTPED := Round(M->EEC_TOTPED,AvSX3("EEC_TOTPED",AV_DECIMAL))
   //MFR OSSME-3579 12/08/2109
   M->EEC_TOTLIQ :=Round(M->EEC_TOTFOB - AE102CalcAg(),AvSX3("EEC_TOTLIQ",AV_DECIMAL)) //RMD - 21/11/14 - Valor Líquido: Total do Pedido - Comissão da Deduzir da Fatura.
   nTotEmbBr := M->EEC_TOTPED + AE102CalcAg()

End Sequence

If lRet
   IF ! EMPTY(cOLDFIL)
      WorkIP->(dbSetFilter(bOLDFIL,cOLDFIL))
   ENDIF

   WorkIP->(dbGoTo(nRecWork))

   If Type("oMsSelect:oBrowse") == "O" .and. lMsg .And. !lIsRepl
      If Upper(Alltrim(oMsSelect:oBrowse:cAlias)) <> "WORKIT" .AND. (!ismemvar("lAutom") .OR. !lAutom)   //TRP 22/11/2007
         oMsSelect:oBrowse:Refresh()
      Endif
   EndIf

   M->EE9_PRCTOT := WorkIP->EE9_PRCTOT
   M->EE9_PRCINC := WorkIP->EE9_PRCINC

   //MFR 07/11/2019 OSSME-3963
   if !isMemVar("lVar") 
      lVar:=.F.
   EndIf
   lVar := !lVar
EndIf

IF Type("oPedido") == "O" .and. lMsg
      AE100TTELA(.F.)
Endif

//15/06/2020
//ae100crit("EEC_SEGURO",.F.,lVar)
Return lRet//.T.

/*
Funcao      : AE100Import
Parametros  :
Retorno     : Valor da Comissao
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 30/07/99 10:51
Revisao     :
Obs.        :
*/
FUNCTION AE100Import

Local cAgente, nComissao, cX5_DESC

Begin Sequence
   If !Inclui .Or. M->EEC_IMPORT+M->EEC_IMLOJA == cCodImport
      Break
   Endif

   SA1->(dbSeek(xFilial("SA1")+M->EEC_IMPORT+M->EEC_IMLOJA))

   cAgente   := AVKEY(SA1->A1_CODAGE,"EEB_CODAGE")
   nComissao := SA1->A1_COMAGE

   IF SA1->(dbSeek(xFilial("SA1")+cCodImport))
      IF !Empty(SA1->A1_CODAGE)
         IF WorkAg->(dbSeek(AVKEY(SA1->A1_CODAGE,"EEB_CODAGE")))
         // Alterado por Heder M Oliveira - 9/21/1999
         // checar tipo do agente que esta sendo eliminado
            WHILE ( !WORKAG->(EOF()) )
               // *** CAF 28/12/1999 IF ( WORKAG->EEB_CODAGE == AVKEY(SA1->A1_CODAGE,"EEB_CODAGE") .AND. WORKAG->EEB_TIPOAG==CD_AGC )
               IF (WORKAG->EEB_CODAGE == AVKEY(SA1->A1_CODAGE,"EEB_CODAGE") .AND. Left(WORKAG->EEB_TIPOAG,1)==CD_AGC)
                  WorkAg->(dbDelete())
               ENDIF
               WORKAG->(DBSKIP())
            END
         Endif
      Endif
   Endif

   cCodImport := M->EEC_IMPORT+M->EEC_IMLOJA

   IF !Empty(cAgente) .And. !Empty(nComissao)
      SY5->(dbSetOrder(1))
      SY5->(dbSeek(xFilial("SY5")+cAgente))

      WorkAg->(RecLock("WorkAg", .T.))
      WorkAg->EEB_CODAGE := cAgente
      WorkAg->EEB_NOME   := SY5->Y5_NOME
      WorkAg->EEB_TXCOMIS:= nComissao

      If ! EMPTY(cX5_DESC:=Tabela('YE',CD_AGC))
         WorkAg->EEB_TIPOAG := Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
      Else
         WorkAg->EEB_TIPOAG := SPACE(AVSX3("EEB_TIPOAG",AV_TAMANHO))
      EndIf
      If EasyEntryPoint("EECAE102")//DFS - 07/01/10 - Inclusão de ponto de entrada para customizar o preenchimento desses campos ao incluir o agente de comissão vinculado no cadastro do cliente.
         ExecBlock("EECAE102",.F.,.F.,"TP_AGNT_EMB")
      EndIf
      WorkAg->(MsUnlock())
   Endif
End Sequence

IF Empty(nComissao)
   nComissao := M->EEC_VALCOM
Endif

Return nComissao

/*
Funcao      : AE100ItemSD2
Parametros  : cPedido := Nro do Processo de Exportacao (EE7)
              cSequen := Nro da Sequencia (EE8)
Retorno     : aNotas
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 06/06/2000 17:00
Revisao     :
Obs.        :
*/
Function AE100ItemSD2(cPedido, cSequen, cSolucao)

Local aOrd := SaveOrd({"SD2"})
Local aNotas := {}
Local aFiliais := Ap101RetFil(), i  // JPM - 27/12/05 - Geração de Notas Fiscais em Várias Filiais

Local cPedFat, cFatIt
Local cNota := ""
Local cSerie := ""
Local cFilNf := ""
Local cProduto:= EE8->EE8_COD_I
Local nPos
Local cNrProc:= ""

Private lPreenche_NF
Default cSolucao := ""
Begin Sequence

   // Identificacao do Pedido no SIGAFAT
   cPedFat := Posicione("EE7",1,xFilial("EE7")+cPedido,"EE7_PEDFAT")
   // Identificacao do Item do Pedido no SIGAFAT
   cFatIt  := Posicione("EE8",1,xFilial("EE8")+cPedido+cSequen,"EE8_FATIT")

   cPedFat := AvKey(cPedFat,"D2_PEDIDO")
   cFatIt  := AvKey(cFatIt,"D2_ITEMPV")

   //TDF - 27/04/2012 - Caso não encontrar pedido e item no SIGAFAT
   If Empty(cPedFat) .AND. Empty(cFatIt)
      //aNotas := {{"","",0,""}}
      aNotas := {{"","",0,"","",""}}
      Break
   EndIf

   SD2->(dbSetOrder(8)) // FILIAL+PEDIDO+ITEMPV

   If ValType(M->EEC_PREEMB) == "C"
      cNrProc:= M->EEC_PREEMB
   EndIf

   For i := 1 To Len(aFiliais)
      SD2->(dbSeek(aFiliais[i]+cPedFat+cFatIt))

      While SD2->(!Eof() .And. D2_FILIAL == aFiliais[i] .And. D2_PEDIDO+D2_ITEMPV == cPedFat+cFatIt)
         SysRefresh()

         //WFS 10/02/2010 - tratamentos para utilização da grade quando usa-se o fluxo padrão de integração
         //com o faturamento (parâmetro MV_AVG0067 = .F.).
         //Se é um item da grade, será considerado apenas se o produto for o mesmo do posicionado na tabela
         //EE8, itens do pedido de exportação.
         If AvFlags("GRADE") .And. SD2->D2_GRADE $ cSim
            If AllTrim(SD2->D2_COD) <> AllTrim(cProduto)
               SD2->(DBSkip())
               Loop
            EndIf
         EndIf

         /*WFS 23/01/2009 ---
         Ponto de entrada para verificar se o número da nota fiscal será mostrado na work independente
         do campo SD2_PREEMB estar preenchido. */
         lPreenche_NF:= .F.
         If EasyEntryPoint("EECAE100")
            ExecBlock("EECAE100",.F.,.F.,"NUMERO_NOTA")
         EndIf

         IF !Empty(SD2->D2_PREEMB) .And. (Empty(cNrProc) .Or. SD2->D2_PREEMB <> M->EEC_PREEMB)
            If !lPreenche_NF
               SD2->(dbSkip())
               Loop
            EndIf
         Endif

         //TRP 26/11/2007 - Verifica se o campo EE7_PEDFAT (pedido de venda) está preenchido.
                          //Caso esteja, grava na seleção do item no embarque as colunas Nota Fiscal e Serie.
         If !Empty(cPedFat)
            cNota  := SD2->D2_DOC
            cSerie := SD2->D2_SERIE
            cFilNf := SD2->D2_FILIAL
         Endif

         If ValidUsoNF(cFilNf, cNota, cSerie) //Se NF do Pedido já está em uso
            cSolucao := STR0152//"Nota Fiscal já está sendo utilizada em outro Processo."
            SD2->(dbSkip())
            Loop
         EndIf

         IF (nPos:=aScan(aNotas,{|x| x[1] == cNota .And. x[2] == cSerie .And. x[4] == cFilNf})) == 0
            aAdd(aNotas,{cNota,cSerie,0,cFilNf,cPedido,cSequen})
            nPos := Len(aNotas)
         Endif

         aNotas[nPos][3] += SD2->D2_QUANT
         aNotas[nPos][3] -= SD2->D2_QTDEDEV //ER - Tratamento para Quantidades devovlidas.

         //MFR 12/01/2021 OSSME-5466
         if aNotas[nPos][3] <= 0 
            aDel(aNotas,nPos)
            aSize(aNotas,len(aNotas)-1)
         EndIf
         SD2->(dbSkip())
      Enddo
   Next

   If Empty(aNotas) .and. lSelNotFat
      //aNotas := {{"","",0,""}}
      aNotas := {{"","",0,"","",""}}
   EndIf

End Sequence

RestOrd(aOrd)

Return aNotas

/*
Funcao      : AE100GrvItSD2(cPedido,cSequen)
Parametros  : cPedido := Nro do Processo de Exportacao (EE7)
              cSequen := Nro da Sequencia (EE8)
Retorno     : nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 06/06/2000 17:00
Revisao     : João Pedro Macimiano Trabbold - 26/12/05 - geração de notas fiscais em várias filiais
              WFS - 10/05/2010 Implementação da gravação do campo F2_HAWB
              com o número do processo de exportação.
Obs.        :
*/
Function AE100GrvItSD2(cPedido,cSequen,cFlag,cNota,cSerie,cFilNf)

Local aOrd := SaveOrd({"SD2", "SF2"})
Local cPedFat, cFatIt
Local cQry

Local aArea := GetArea()

Default cFilNf := xFilial("SD2") //JPM - 26/12/05

Begin Sequence

   // Identificacao do Pedido no SIGAFAT
   cPedFat := Posicione("EE7",1,xFilial("EE7")+cPedido,"EE7_PEDFAT")
   // Identificacao do Item do Pedido no SIGAFAT
   cFatIt  := Posicione("EE8",1,xFilial("EE8")+cPedido+cSequen,"EE8_FATIT")

   cPedFat := AvKey(cPedFat,"C6_NUM")
   cFatIt  := AvKey(cFatIt,"C6_ITEM")

   cQry := "SELECT R_E_C_N_O_ D2_RECNO FROM " + RetSqlName('SD2') +;
            " WHERE D2_FILIAL='" + cFilNf + "' AND D2_DOC='" + cNota + "' AND D2_SERIE='" + cSerie + "'" +;
            " AND D2_PEDIDO='" + cPedFat + "' AND D2_ITEMPV='" + cFatIt + "' AND D_E_L_E_T_=' '"

   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QrySD2", .F., .T.)

   While !(QrySD2->(Eof()))
      SD2->(dbGoTo(QrySD2->D2_RECNO))
      SD2->(RecLock("SD2",.F.))
      SD2->D2_PREEMB := cFlag
      SD2->(MsUnlock())
      QrySD2->(dbSkip())
   EndDo

   QrySD2->(dbCloseArea())

   //WFS 10/05/2010
   SF2->(DBSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL
   If SF2->(DBSeek(cFilNf+cNota+cSerie))
      SF2->(RecLock("SF2", .F.))
      SF2->F2_HAWB:= cFlag
      SF2->(MsUnlock())
   EndIf

End Sequence

RestOrd(aOrd, .T.)
RestArea(aArea)

Return NIL

/*
Funcao          : AE102CRIAWORK()
Parametros      : lIntegracao - .t. = Chamada a partir de atualização automática de processo.
Retorno         : .T.
Objetivos       : Criação dos arquivos temporários para manutenção de embarque.
Autor           : Jeferson Barros Jr.
Data/Hora       : 24/07/01 - 14:12
Revisao         :
Obs.            :
*/

*---------------------------------*
Function AE102CRIAWORK(lIntegracao)
*---------------------------------*
Local lRET:=.T.,lITGRAVA:=.T.,VETEEK,Z,nLEN, j:=0
Local aSemSX3, cCpo
Local aOrd
Local lConsig := Type("EEC->EEC_CONSDE")="C" .AND. type("EEC->EEC_ENDCON")="C" .AND. type("EEC->EEC_END2CO")="C"
Local lEET_EVENT, nOrderSX3:=SX3->(IndexOrd())
Local aAuxCmp:={}
//Local cFilEx := AvKey(EasyGParam("MV_AVG0024",,""),"EEC_FILIAL")
Local lITCubagem := EasyGParam("MV_AVG0010", .F., .F., xFilial("EEC"))
Local cFolder, aDelItem:={}
Local aSaveOrd := SaveOrd("SX3", 1)
Local nPos := 0
Local aItensNaoEdit := {}    // By JPP - 23/09/2005 - 15:50 - Este vetor possui os campos que não serão editaveis.
Local i, cChave, cAux, aBox, cIniBrw, cCampo
Local aExlInttra
Local aCpoWkStru := {} //THTS - 31/10/2017 - Utilizado para criar o campo DBDELETE na Work
Default lIntegracao := .f.

SX3->(DBSETORDER(2))
lOkEE9_CC := SX3->(dbSeek("EE9_CC"))

If Type("lIntEmb") == "U"  // SVG - 11/09/08
   Private lIntEmb := EECFlags("INTEMB")
EndIf

Private lLibPes := .f.

Private cWORKALIAS,cWORK2ALIAS,aPITSEMSX3,aIPSEMSX3,;
        aIPDELETADOS,aHEADER,aCAMPOS

If ValType(lITCubagem) <> "L"
   lITCubagem := .F.
EndIf

lEET_EVENT := SX3->(dbSeek("EET_EVENT"))
SX3->(DBSETORDER(nOrderSX3))

If Type("oText") = "O"
   MsProcTxt(STR0001) // "Criando arquivos temporários ..."
EndIf

If Type("lItFabric") == "U"  // By JPP - 14/11/2007 - 14:00
   lItFabric := EasyGParam("MV_AVG0138",,.F.)
EndIf

	//RMD - 23/08/12 - Tratamento específico para manter arquivos de trabalho - Vide EECAE109.
	EECSetKeepUsrFiles()

Begin Sequence
   cWORK2ALIAS:="WorkIP"

   // //definicao dos campos para enchoice de cambio
   // aITEMCAMBIO:={"EEC_CBVCT","EEC_CBPGT","EEC_CBNR","EEC_CBTX","EEC_CBRFBC",;
   //               "EEC_DECAM","EEC_CBSOL","EEC_CBBANC","EEC_CBBCNO","EEC_CBDTCE",;
   //              "EEC_CBAGEN","EEC_CBNCON"}

   //definicao dos campos para enchoice de registro de documentos
   aITEMREGDOC:={"EEC_NRCTOR","EEC_NRCTFA","EEC_NRCTCS","EEC_NRCONH","EEC_MAWB",;
                 "EEC_DTCONH","EEC_NRCTSG","EEC_BCDCREG",;
                 "EEC_TRSDOC","EEC_DTLMDC","EEC_DTENDC","EEC_BCEXRF","EEC_NRINVO","EEC_DTINVO",;
                 "EEC_COURI2","EEC_COURIE","EEC_DTSLIN","EEC_DTSLPL","EEC_NRINSP","EEC_NRAVSG",;
                 "EEC_APLCSG","EEC_DTEMBA","EEC_DTSEGU","EEC_DTPALE","EEC_DTINSP"}

   // //definicao dos campos para enchoice de transito
   // aITEMTRANSITO:={}

   //definicao dos campos para enchoice de faturamento
   aITEMFATURA:={"EEC_DTSLNF","EEC_DTSDFB","EEC_NRINVO","EEC_DTINVO","NOUSER"} // By JPP - 06/03/2006 - 15:50 - Parametro:"NOUSER" - Este parametro não exibe campos de usuário na enchoice.
   SX3->(DbSetOrder(1))
   SX3->(DbSeek("EEC"))
   Do While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == "EEC"  // By JPP - 07/03/2006 - 09:45 - Adiciona na enchoice de faturamento os campos de usuário da pasta faturamento.
      If Upper(SX3->X3_PROPRI) == "U" .And. SX3->X3_FOLDER == "9"  // campo de usuário e pasta faturamento.
         Aadd(aITEMFATURA,SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
   EndDo
   /*
   aITEMFATURA:={"EEC_DTSLNF","EEC_DTSDFB","EEC_DTNF","EEC_NRNF","EEC_VLTTNF","EEC_DTNFC",;
                 "EEC_NRNFC","EEC_VLNFC","EEC_NRINVO","EEC_DTINVO"}
   */

   //definicao dos campos para enchoice da capa do embarque (header master)
   aHDENCHOICE:={"EEC_PREEMB","EEC_PEDREF","EEC_DTPROC","EEC_STTDES",;
                 "EEC_MOTSIT","EEC_DSCMTS","EEC_IMPORT","EEC_IMPODE","EEC_CLIENT","EEC_CLIEDE",;
                 "EEC_FORN","EEC_FORNDE","EEC_EXPORT","EEC_EXPODE","EEC_CONSIG",;
                 "EEC_CONSDE","EEC_CONDPA","EEC_DIASPA","EEC_DESCPA","EEC_FRPPCC",;
                 "EEC_VIA","EEC_VIA_DE","EEC_ORIGEM","EEC_DEST","EEC_INCOTE","EEC_PGTANT",;
                 "EEC_SL_LC","EEC_LC_NUM","EEC_EMBAFI","EEC_IDIOMA","EEC_TIPCOM","EEC_VALCOM",;
                 "EEC_TIPCVL","EEC_FRPREV","EEC_SEGPRE","EEC_MOEDA","EEC_OBS","EEC_REFIMP",;
                 "EEC_MARCAC","EEC_OBSPED","EEC_PRECOA","EEC_CUBAGE","EEC_SEGURO","EEC_GENERI",;
                 "EEC_SL_EME","EEC_LICIMP","EEC_DSCORI","EEC_DSCDES","EEC_REFAGE","EEC_MPGEXP",;
                 "EEC_DSCMPE","EEC_FOLOJA","EEC_IMLOJA","EEC_EXLOJA","EEC_COLOJA","EEC_BELOJA",;
                 "EEC_CLLOJA","EEC_BENEF","EEC_BENEDE","EEC_ENDBEN","EEC_ENDIMP","EEC_TIPTRA",;
                 "EEC_FRPCOM","EEC_INSCOD","EEC_ENQCOD",;
                 "EEC_EXLIMP","EEC_DTLIMP","EEC_URFDSP","EEC_URFENT","EEC_PAISDT","EEC_PAISET",;
                 "EEC_REGVEN","EEC_OPCRED","EEC_SECEX","EEC_LIMOPE","EEC_MRGNSC","EEC_ANTECI",;
                 "EEC_VISTA","EEC_NPARC","EEC_PARCEL","EEC_VLMNSC","EEC_VLCONS","EEC_COBCAM",;
                 "EEC_FINCIA","EEC_DECPES","EEC_DECQTD","EEC_DECPRC","EEC_END2IM","EEC_END2BE",;
                 "EEC_RESPON","EEC_DESCON","EEC_DESPIN",/*"EEC_AMOSTR",*/ "EEC_CALCEM","EEC_CONFEC",;
                 "EEC_PACKAG","EEC_ONTHEP","EEC_QUANTI","EEC_UNIT","EEC_NETWGT","EEC_GROSSW",;
                 "EEC_ENQCO1","EEC_ENQCO2","EEC_ENQCO3","EEC_ENQCO4","EEC_ENQCO5","EEC_GEDERE",;
                 "EEC_GDRPRO","EEC_DIRIVN","EEC_LIBSIS","EEC_BRUEMB","EEC_NRCTOR","EEC_NRCTFA",;
                 "EEC_NRCONH","EEC_MAWB","EEC_DTCONH","EEC_NRCTSG",;
                 "EEC_TRSDOC","EEC_DTLMDC","EEC_DTENDC","EEC_BCEXRF",;
                 "EEC_COURI2","EEC_COURIE","EEC_DTSLIN","EEC_DTSLPL","EEC_NRINSP","EEC_NRAVSG",;
                 "EEC_APLCSG","EEC_DTEMBA","EEC_DTSEGU","EEC_DTPALE","EEC_DTINSP",;
                 "EEC_DTFCPR","EEC_ETA","EEC_TRSTIM","EEC_ETD","EEC_ETADES","EEC_EMBARC",;
                 "EEC_VIAGEM", "EEC_TPDESC"}


   //AOM - 16/01/2012 - Adicionando o campo CodErp na capa de Embarque
   If EEC->(FieldPos("EEC_CODERP")) > 0 .And. (nPos := aScan(aHdEnchoice, {|x| AllTrim(x) == "EEC_PEDREF" })) > 0
      aAdd(aHdEnchoice, Nil)
      aIns(aHdEnchoice, nPos + 1)
      aHdEnchoice[nPos+1] := "EEC_CODERP"
   EndIf

   //RMD - 23/09/13 - Campo para informar o valor do frete já embutido nos itens
   If EEC->(FieldPos("EEC_FREEMB")) > 0 .And. EasyGParam("MV_EEC0039",,.F.)
      aAdd(aHdEnchoice, "EEC_FREEMB")
   EndIf

   If !EECFlags("ESTUFAGEM")
      aAdd(aHdEnchoice, "EEC_DTESTU")
   EndIf

   If EEC->(FieldPos("EEC_PTINT")) > 0   // BHF - 13/08/08 - Inserção do Porto intermediário.
      aAdd(aHDENCHOICE,"EEC_PTINT")
   EndIf

   If EECFlags("COMPLE_EMB_CAPA")
      //aAdd(aHdEnchoice, "EEC_EXL")
      aAdd(aHdEnchoice,IncSpace("EEC_EXL", Len(SX3->X3_CAMPO), .F.))  // TLM 01/11/2007
   EndIf

   If EECFlags("CAFE")  // By JPP - 13/01/2006 - 15:45
      aAdd(aHDENCHOICE,"EEC_ENVAMO")
   Else
      aAdd(aHDENCHOICE,"EEC_AMOSTR")
   EndIf

   IF TYPE("M->EEC_DESP1")<>"U"
       aAdd(aHDENCHOICE,"EEC_DESP1")
   ENDIF

   IF TYPE("M->EEC_DESP2")<>"U"
       aAdd(aHDENCHOICE,"EEC_DESP2")
   ENDIF

   IF TYPE("M->EEC_PACKA2")<>"U"
       aAdd(aHDENCHOICE,"EEC_PACKA2")
   ENDIF

   IF TYPE("M->EEC_PACKA3")<>"U"
       aAdd(aHDENCHOICE,"EEC_PACKA3")
   ENDIF

   IF TYPE("M->EEC_PACKA4")<>"U"
       aAdd(aHDENCHOICE,"EEC_PACKA4")
   ENDIF

   If EEC->(FieldPos("EEC_ENDCON")) > 0
      aAdd(aHDENCHOICE,"EEC_ENDCON")
   EndIf
   If EEC->(FieldPos("EEC_END2CO")) > 0
      aAdd(aHDENCHOICE,"EEC_END2CO")
   EndIf

   IF lIntegra
      aAdd(aHDENCHOICE,"EEC_PEDDES")
      aAdd(aHDENCHOICE,"EEC_PEDEMB")
   Endif

   IF EEC->(TYPE("EEC_SPCRM1"))#"U" .AND. EEC->(TYPE("EEC->EEC_SPCRM2"))#"U".AND. EEC->(TYPE("EEC->EEC_SPCRM3"))#"U"
      AADD(aHDENCHOICE,"EEC_SPCRM1")
      AADD(aHDENCHOICE,"EEC_SPCRM2")
      AADD(aHDENCHOICE,"EEC_SPCRM3")
   ENDIF

   IF TYPE("EEC->EEC_ENQCOX") <> "U"
      aAdd(aHDENCHOICE,"EEC_ENQCOX")
   ENDIF

   /* by jbj - 29/06/04 15:25 - Os campos de intermediação são disponibilizados para manutenção
                                apenas com a rotina de intermediação ligada e somente para a
                                filial do brasil. */
   If lIntermed //.And. AvGetM0Fil() <> cFilEx
      aAdd(aHDEnchoice,"EEC_INTERM")
      aAdd(aHDEnchoice,"EEC_COND2")
      aAdd(aHDEnchoice,"EEC_DIAS2")
      aAdd(aHDEnchoice,"EEC_INCO2")
      aAdd(aHDEnchoice,"EEC_PERC")
   EndIf

   If lConvUnid
      aAdd(aHDEnchoice,"EEC_UNIDAD")
   EndIf

   If EEC->(FieldPos("EEC_PTCROM")) # 0 // By JPP - 20/03/2007 - 17:00
      aAdd(aHDEnchoice,"EEC_PTCROM")
   EndIf

   If lIntEmb
      aAdd(aHDEnchoice,"EEC_PEDFAT")
   EndIf

   If EEC->(FieldPos("EEC_DTVCRE")) # 0 // NCF - 22/11/2013
      aAdd(aHDEnchoice,"EEC_DTVCRE")
   EndIf

   IF !lIntegracao .And. cFilEx = AvGetM0Fil()

      // Tratamentos para os campos referentes ao siscomex na filial do exterior.
      SXA->(DbSetOrder(1))
      If SXA->(DbSeek("EEC"))
         Do While SXA->(!Eof()) .And. SXA->XA_ALIAS == "EEC"
            If AllTrim(SXA->XA_DESCRIC) == "Siscomex"
               cFolder := SXA->XA_ORDEM
               Exit
            EndIf
            SXA->(DbSkip())
         EndDo
      EndIf

      nLen := 0
      aAuxCmp:={}
      SX3->(DBSETORDER(2))
      FOR Z := 1 TO LEN(aHDENCHOICE)
         IF aHDENCHOICE[Z] # NIL
            If (SX3->(DbSeek(aHDEnchoice[z]))) .And. !(SX3->X3_FOLDER = cFolder)
               aAdd(aAuxCmp,aHDEnchoice[z])
            EndIf
         ENDIF
      NEXT
      aHDEnchoice := aClone(aAuxCmp)
   ENDIF

   SX3->(dbSetOrder(2))
   If SX3->(dbSeek("EEC_CODUSU"))
      aAdd(aHDEnchoice, "EEC_CODUSU")
      If SX3->(dbSeek("EEC_USUDIG")) .and. SX3->(dbSeek("EEC_EMAIL"))
         aAdd(aHDEnchoice, "EEC_USUDIG")
         aAdd(aHDEnchoice, "EEC_EMAIL" )
      EndIf
   EndIf

   // by CAF 14/02/2005 - Criação dos campos Nro.Comprovante de Exportação e Data
   IF aScan(aHdEnchoice,"EEC_NRCE") == 0 .And. SX3->(dbSeek("EEC_NRCE"))
      aAdd(aHdEnchoice,"EEC_NRCE")
      IF aScan(aHdEnchoice,"EEC_DTCE") == 0 .And. SX3->(dbSeek("EEC_DTCE"))
         aAdd(aHdEnchoice,"EEC_DTCE")
      Endif
   Endif

   If EECFlags("AMOSTRA_BASE")
      aAdd(aHdEnchoice, "EEC_AMBASE")
   EndIf

   //definicao de campos para a enchoice dos itens do processo
   aItemEnchoice:={"EE9_COD_I","EE9_PART_N","EE9_FORN","EE9_FABR",;
                   "EE9_PRECO","EE9_SLDINI","EE9_FALOJA","EE9_FOLOJA",;
                   "EE9_VM_DES","EE9_QE","EE9_EMBAL1","EE9_PSLQUN",;
                   "EE9_PSBRUN","EE9_QTDEM1","EE9_UNIDAD",;
                   "EE9_POSIPI","EE9_NLNCCA","EE9_NALSH","EE9_FPCOD","EE9_GPCOD","EE9_DPCOD",;
                   /*"EE9_ATOCON","EE9_RE","EE9_DTRE",*/"EE9_FINALI","EE9_PRECOI",;
                   "EE9_NRSD","EE9_DTAVRB","EE9_REFCLI","EE9_CODNOR","EE9_VM_NOR","EE9_PERCOM"} // ** By JBJ - 02/04/02
   //WFS 26/06/09
   If EE9->(FieldPos("EE9_DTDDE")) > 0
      AAdd(aItemEnchoice, "EE9_DTDDE")
   EndIf

   If EE9->(FieldPos("EE9_LPCO")) > 0
      AAdd(aItemEnchoice, "EE9_LPCO")
   EndIf

   // FJH - 03/02/06
   If EasyGParam("MV_AVG0119",,.F.) .and. EE9->(FieldPos("EE9_DESCON")) > 0
      aAdd(aItemEnchoice,"EE9_DESCON")
   Endif

   If EECFlags("INTTRA")
      aAdd(aHDEnchoice, "EEC_ETB")
      aAdd(aHDEnchoice, "EEC_ETBHR")
      aAdd(aHDEnchoice, "EEC_ETAHR")
      aAdd(aHDEnchoice, "EEC_ETDHR")
      aAdd(aHDEnchoice, "EEC_DLDRAF")
      aAdd(aHDEnchoice, "EEC_DLDRHR")
      aAdd(aHDEnchoice, "EEC_DLCARG")
      aAdd(aHDEnchoice, "EEC_DLCAHR")

      aAdd(aItemEnchoice, "EE9_DINT")
   EndIf

   //AAS
   If EasyEntryPoint("EECAE102")
      ExecBlock("EECAE102",.f.,.f.,"EE9_ENCHOICE_ESTRU")
   EndIf

   If EECFlags("CAFE")
      aAdd(aItemEnchoice, "EE9_CODQUA")//Campos de Qualidade
      aAdd(aItemEnchoice, "EE9_DSCQUA")
      aAdd(aItemEnchoice, "EE9_CODPEN")//Campos de Peneira
      aAdd(aItemEnchoice, "EE9_DSCPEN")
      aAdd(aItemEnchoice, "EE9_CODTIP")//Campos de Tipo
      aAdd(aItemEnchoice, "EE9_DSCTIP")
      aAdd(aItemEnchoice, "EE9_CODBEB")//Campos de Bebida
      aAdd(aItemEnchoice, "EE9_DSCBEB")
      If Ap104VerPreco()
         aAdd(aItemEnchoice,"EE9_PRECO2")  // FJH - Adicionando os campos novos de preco.
         aAdd(aItemEnchoice,"EE9_PRECO3")
         aAdd(aItemEnchoice,"EE9_PRECO4")
         aAdd(aItemEnchoice,"EE9_PRECO5")
      EndIf
   Endif
   //PLB 07/02/06 - Não permite associação com AC na filial Off-Shore
   If !(Type("BackTo") == "L" .And. lBackTo) .And. (EasyGParam("MV_AVG0024",,"") != AvGetM0Fil() .Or. Empty( EasyGParam("MV_AVG0024",,"") ))
      aAdd(aItemEnchoice,"EE9_ATOCON")
   EndIf

   If lOkEE9_ATO //lIntDraw .and.
      aAdd(aItemEnchoice,"EE9_SEQED3")
   EndIf

   If !(Type("lConsign") == "L" .And. lConsign) .Or. cTipoProc $ PC_RC+PC_RG
      aAdd(aItemEnchoice, "EE9_RE")
      aAdd(aItemEnchoice, "EE9_DTRE")
   EndIf

   If lOkEE9_CC
      aAdd(aItemEnchoice,"EE9_CC")
      aAdd(aItemEnchoice,"EE9_DESCCC")
   EndIf

   IF lIntegra .Or. AvFlags("NFS_DESVINC")
      aAdd(aItemEnchoice,"EE9_NF")
      aAdd(aItemEnchoice,"EE9_SERIE")
   Endif

/*WHRS TE-6464 542022 - MTRADE-1806 - Ajustes nos dados do XML da DUE*/
   If AVFlags("DU-E2")
      aAdd(aItemEnchoice,"EE9_PCARGA")
      aAdd(aItemEnchoice,"EE9_DESPCA")
      aAdd(aItemEnchoice,"EE9_OBSPCA")
   endIf

   If AVFlags("DU-E2") .And. EE9->(FieldPos("EE9_LPCO")) > 0
      aAdd(aItemEnchoice, "EE9_LPCO")
   EndIf
   If AVFlags("DU-E2") .And. !lIntDraw .And. EE9->(FieldPos("EE9_TPAC")) > 0
      aAdd(aItemEnchoice, "EE9_TPAC")
   EndIf

   //RMD - 11/07/18 - Caso exista o campo de justificativa de depuração estatística da DUE, incluir o campo na tela
   If AVFlags("DU-E2") .And. EE9->(FieldPos("EE9_JUSDUE")) > 0
      aAdd(aItemEnchoice,"EE9_JUSDUE")
   EndIf

   If EE9->(FieldPos("EE9_UNPRC")) # 0
      aAdd(aItemEnchoice,"EE9_UNPRC")
   EndIf

   If EE9->(FieldPos("EE9_UNPES")) # 0
      aAdd(aItemEnchoice,"EE9_UNPES")
   EndIf

   // ** By JBJ - 24/07/02 - 16:48 ...
   If EE9->(FieldPos("EE9_RV")) # 0
      aAdd(aItemEnchoice,"EE9_RV")
   EndIf

   // *** 16/05/2001 15:55 CAF
   IF Type("EE9->EE9_RC") <> "U"
      aAdd(aItemEnchoice,"EE9_RC")
   Endif

   // ** 16/12/2003 - 19:00
   If EE9->(FieldPos("EE9_PACKAG")) # 0
      aAdd(aItemEnchoice,"EE9_PACKAG")
   EndIf

   // ** JPM - 01/06/05 - Campo Tipo de comissão para o item
   If EE9->(FieldPos("EE9_TIPCOM")) > 0
      aAdd(aItemEnchoice,"EE9_TIPCOM")
   EndIf

   // ** By JBJ - 05/06/03 - 17:53 - Retirar/Adicionar campos para tratamento de comissao realizado por agente.
   If EECFlags("COMISSAO")
      // ** Capa do embarque.
      aDelCapa:={"EEC_TIPCOM","EEC_TIPCVL","EEC_VALCOM","EEC_REFAGE"}

      For j:=1 To Len(aDelCapa)
         nPos := aScan(aHDEnchoice,aDelCapa[j])
         If nPos > 0
            aHDEnchoice := aDel(aHDEnchoice,nPos)
            aHDEnchoice := aSize(aHDEnchoice,Len(aHDEnchoice)-1)      // By JPP - 09/12/04 11:55 - Correção do nome da variavel aHDEnchoice.
         EndIf
      Next

      aNewCapa:={"EEC_DSCCOM"}
      For j:=1 To Len(aNewCapa)
         aAdd(aHDEnchoice,aNewCapa[j])
      Next

      // ** Novos campos item.
      aNewCmpItem := {"EE9_CODAGE","EE9_DSCAGE","EE9_MAXCOM","EE9_VLCOM"}
      For z:=1 To Len(aNewCmpItem)
         aAdd(aItemEnchoice,aNewCmpItem[z])
      Next
   EndIf

   // AMS - 10/05/2005 às 13:50.
   If EE9->(FieldPos("EE9_CODUE")  > 0 .and. FieldPos("EE9_LOJUE")  > 0 .and. FieldPos("EE9_AGRE") > 0 .and. FieldPos("EE9_AGSUFI") > 0)
      aAdd(aItemEnchoice, "EE9_CODUE")
      aAdd(aItemEnchoice, "EE9_LOJUE")
      aAdd(aItemEnchoice, "EE9_NOMUE")
      aAdd(aItemEnchoice, "EE9_AGRE")
      aAdd(aItemEnchoice, "EE9_AGSUFI")
   EndIf

   // JPM - 06/07/05 - Campos de vinculação a itens de L/C
   If EECFlags("ITENS_LC")
      If EasyGParam("MV_AVG0096",,.f.)
         aAdd(aItemEnchoice,"EE9_LC_NUM")
      EndIf
      aAdd(aItemEnchoice,"EE9_SEQ_LC")
   EndIf

   // ER - 04/09/2006 - Campo de Conhecimento de Embarque
   If EE9->(FieldPos("EE9_HOUSE")) # 0
      If SX3->(dbSeek(AvKey("EE9_HOUSE","X3_CAMPO"))) .And. X3Uso(SX3->X3_USADO)
         aAdd(aItemEnchoice,"EE9_HOUSE")
      EndIf
   EndIf

   /////////////////////////////////////////////////////////////////////////
   //ER - 17/09/2008.                                                     //
   //Campos utilizados no novo fluxo de integração entre SigaEEC e SigaFAT//
   /////////////////////////////////////////////////////////////////////////
   If lIntEmb
      aAdd(aItemEnchoice,"EE9_FATIT")
   EndIf

   // TDF-16/03/2011
   If lIntEmb .Or. lIntegra
      If EE9->(FieldPos("EE9_TES")) <> 0 .and.  EE9->(FieldPos("EE9_CF")) <> 0
         aAdd(aItemEnchoice,"EE9_TES")
         aAdd(aItemEnchoice,"EE9_CF")
      EndIf
   EndIf

   //AOM - 26/04/2011 - Operacao Especial
   If AvFlags("OPERACAO_ESPECIAL")
      AAdd(aItemEnchoice,"EE9_CODOPE")
      AAdd(aItemEnchoice,"EE9_DESOPE")
   EndIF

   //TRP- 20/02/2009
   If Type ("lDrawSC") == "L" .and. lDrawSC
      aAdd(aItemEnchoice,"EE9_VLSCOB")
   EndIf

   //TRP - 27/10/2011 - Nr. Destaque
   If EE9->(FieldPos("EE9_DTQNCM")) <> 0
      aAdd(aItemEnchoice,"EE9_DTQNCM")
   Endif

   Aadd(aItensNaoEdit,"EEC_COBCAM")    // By JPP - 23/09/2005 - 15:50 - Este vetor possui os campos que não serão editaveis.
   If EECFlags("INTERMED") // EECFlags("CONTROL_QTD") // JPM - 10/11/05 - Com a rotina de controle de quantidades ativa, não será possível editar este campo, apenas no pedido.
                           // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
      AAdd(aItensNaoEdit,"EEC_INTERM")
   EndIf

   //*** RMD - Verificação dos campos do EXL
   If Type("aCamposEXL") == "A"
      //Campos específicos do Inttra.
      aExlInttra := {"EXL_REFADD", "EXL_DEADLI", "EXL_CBKCOM", "EXL_BKCOM",  "EXL_CBKTCO", "EXL_BKTPCO", "EXL_CSICOM", "EXL_SICOM",  "EXL_BLCLA1", "EXL_CBLCL1",;
                     "EXL_BLCLM1", "EXL_BLCLA2", "EXL_CBLCL2", "EXL_BLCLM2", "EXL_BLCLA3", "EXL_CBLCL3", "EXL_BLCLM3", "EXL_CSIRIN", "EXL_SIRINS", "EXL_LOCFRE",;
                     "EXL_BOOK",   "EXL_BKRFIN", "EXL_TPSERV", "EXL_TIPMOV", "EXL_LOCREC", "EXL_LOCENT", "EXL_ETDORI", "EXL_DTRETI", "EXL_HRRETI", "EXL_TIPOBL",;
                     "EXL_QTDBL",  "EXL_QTDBLC", "EXL_IMPFRE", "EXL_ENVVAL", "EXL_MEMOBL", "EXL_MEMOSI",  "EXL_STADES"}

      aEXLNotShow := {"EXL_STADES"}
      SX3->(DbSetOrder(1))
      SX3->(DbSeek("EXL"))
      While SX3->(!Eof() .And. X3_ARQUIVO == "EXL")
         If X3Uso(SX3->X3_USADO)

            //Somente exibir campos do Inttra se a integração estiver ligada.
            If (aScan(aExlInttra, {|x| IncSpace(x, Len(SX3->X3_CAMPO), .F.) == SX3->X3_CAMPO}) > 0) .And. !EECFlags("INTTRA")
               SX3->(DbSkip())
               Loop
            EndIf

            If aScan(aEXLNotShow, {|x| IncSpace(x, Len(SX3->X3_CAMPO), .F.) == SX3->X3_CAMPO}) > 0
               SX3->(DbSkip())
               Loop
            EndIf

            //Alimenta array para uso na Enchoice do EXL.
            aAdd(aCamposEXL, SX3->X3_CAMPO)

         EndIf
         SX3->(DbSkip())
      EndDo
   EndIf
   //***

   For nPos := 1 To Len(aHDEnchoice)

      If Ascan(aItensNaoEdit,aHDEnchoice[nPos]) > 0 // By JPP - 22/09/2005 - 10:20 - Nao adicionar no array aEECCamposEditaveis os campos não editaveis.
         Loop
      EndIf
      If aScan(aEECCamposEditaveis, {|x| x == aHDEnchoice[nPos]}) = 0
         aAdd(aEECCamposEditaveis, aHDEnchoice[nPos])
      EndIf
   Next

   //AMS - 21/07/2004. Não permite a edição do campo cubagem se o MV_AVG0010 estiver .T..
   If lITCubagem
      If (nPos := aScan(aEECCamposEditaveis, "EEC_CUBAGE")) <> 0
         aDel(aEECCamposEditaveis, nPos)
         aEECCamposEditaveis := aSize(aEECCamposEditaveis, Len(aEECCamposEditaveis)-1)
      EndIf
   EndIf

   /*
   AMS - 10/08/2005. Tratamento para permitir que campos do pedido definido no SX3 como X3_PROPRI = "U"(usuário)
                     possam ser editados.
   */
   If Len(aEECCamposEditaveis) > 0

      SX3->(dbSeek("EEC"))

      While SX3->(!Eof() .and. X3_ARQUIVO = "EEC")
         If SX3->(X3_PROPRI = "U" .and. aScan(aEECCamposEditaveis, {|x| x == RTrim(X3_CAMPO)}) = 0)
            aAdd(aEECCamposEditaveis, RTrim(SX3->X3_CAMPO))
         EndIf
         SX3->(dbSkip())
      End

   EndIf

   aIPSEMSX3 := { {"WP_RECNO" ,"N",7,0},;
                  {"WP_FLAG"  ,"C",2,0},;
                  {"WP_SLDATU",/*"N",15,3*/AVSX3("EE9_SLDINI",2),AVSX3("EE9_SLDINI",3),AVSX3("EE9_SLDINI",4)},; //NCF - 21/02/2016 - Tamanho e decimal deve se baser na configuração do campo principal que terá seu valor transportado.
                  {"WP_OLDINI",AVSX3("EE9_SLDINI",2),AVSX3("EE9_SLDINI",3),AVSX3("EE9_SLDINI",4)} }

   // JPM - 01/04/05 - Novos campos
   If EE9->(FieldPos("EE9_PRCUN"))  > 0 .And. EE9->(FieldPos("EE9_VLFRET")) > 0 .And. ;
      EE9->(FieldPos("EE9_VLSEGU")) > 0 .And. EE9->(FieldPos("EE9_VLOUTR")) > 0 .And. ;
      EE9->(FieldPos("EE9_VLDESC")) > 0

      aAdd(aIpSemSX3,{"EE9_PRCUN" ,AVSX3("EE9_PRCUN" ,AV_TIPO),AVSX3("EE9_PRCUN" ,AV_TAMANHO),AVSX3("EE9_PRCUN" ,AV_DECIMAL)})
      aAdd(aIpSemSX3,{"EE9_VLFRET",AVSX3("EE9_VLFRET",AV_TIPO),AVSX3("EE9_VLFRET",AV_TAMANHO),AVSX3("EE9_VLFRET",AV_DECIMAL)})
      aAdd(aIpSemSX3,{"EE9_VLSEGU",AVSX3("EE9_VLSEGU",AV_TIPO),AVSX3("EE9_VLSEGU",AV_TAMANHO),AVSX3("EE9_VLSEGU",AV_DECIMAL)})
      aAdd(aIpSemSX3,{"EE9_VLOUTR",AVSX3("EE9_VLOUTR",AV_TIPO),AVSX3("EE9_VLOUTR",AV_TAMANHO),AVSX3("EE9_VLOUTR",AV_DECIMAL)})
      aAdd(aIpSemSX3,{"EE9_VLDESC",AVSX3("EE9_VLDESC",AV_TIPO),AVSX3("EE9_VLDESC",AV_TAMANHO),AVSX3("EE9_VLDESC",AV_DECIMAL)})

   Else
      aAdd(aIpSemSX3,{"EE9_PRCUN" ,AVSX3("EE9_PRECO" ,AV_TIPO),AVSX3("EE9_PRECO" ,AV_TAMANHO),AVSX3("EE9_PRECO" ,AV_DECIMAL)})
      aAdd(aIpSemSX3,{"EE9_VLFRET",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
      aAdd(aIpSemSX3,{"EE9_VLSEGU",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
      aAdd(aIpSemSX3,{"EE9_VLOUTR",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
      aAdd(aIpSemSX3,{"EE9_VLDESC",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})

   EndIf

   If EasyGParam("MV_AVG0119",,.F.) .and. EE9->(FieldPos("EE9_DESCON")) > 0
        aAdd(aIpSemSX3,{"EE9_DESCON",AVSX3("EE9_DESCON",AV_TIPO),AVSX3("EE9_DESCON",AV_TAMANHO),AVSX3("EE9_DESCON",AV_DECIMAL)})
   Endif

   If EECFlags("CAFE") //RMD - 17/11/05 - Manutenção de OIC´s
      aAdd(aIpSemSX3,{"WK_FLAGOIC","C",  2, 0}) //Flag para opção de marca/desmarca
      aAdd(aIpSemSX3,{"WK_TOTOIC" ,"N", 15, 3}) //Total vinculado a OIC´s
      aAdd(aIpSemSX3,{"WK_QTDOIC" ,"N", 15, 3}) //Quantidade vinculada a um OIC

      // O campo Registro de Venda, não será exibido na Capa do embarque.
      aDelCapa:={"EEC_REGVEN"}

      For j:=1 To Len(aDelCapa)
         nPos := aScan(aHDEnchoice,aDelCapa[j])
         If nPos > 0
            aHDEnchoice := aDel(aHDEnchoice,nPos)
            aHDEnchoice := aSize(aHDEnchoice,Len(aHDEnchoice)-1)
         EndIf
      Next


   EndIf

   If lOkEE9_ATO //lIntDraw .and.
      cCpo := "EE9_SEQED3"
      SX3->(DbSetOrder(2))
      If SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. !X3Uso(SX3->X3_USADO)    //TRP- 02/03/2009
         aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif

      cCpo := "EE9_QT_AC"
      aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})

      cCpo := "EE9_VL_AC"
      aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
   EndIf

   If lOkEE9_CC
      aOrd := SaveOrd("SX3",2)
      cCpo := "EE9_CC"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif

      cCpo := "EE9_DESCCC"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif
      RestOrd(aOrd)
   EndIf

   IF lIntegra .Or. AvFlags("NFS_DESVINC")
      aOrd := SaveOrd("SX3",2)
      cCpo := "EE9_NF"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif

      cCpo := "EE9_SERIE"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif

      If AVFLAGS("EEC_LOGIX")
         cCpo := "EES_FATSEQ"
         IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
            aAdd(aIpSemSX3,{"EE9_FATSEQ",AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
         Endif
      EndIf

      // ** JPM - 27/12/05 - Geração de notas fiscais em várias filiais.
      If EECFlags("FATFILIAL")
         AddNaoUsado(aIpSemSx3,"EE9_FIL_NF")
      EndIf
      // **

      RestOrd(aOrd)
   Endif

   If AvFlags("GRADE")
      aAdd(aIpSemSX3,{"WK_ITEMGR",AVSX3("EE8_ITEMGR",2),AVSX3("EE8_ITEMGR",3),AVSX3("EE8_ITEMGR",4)})
   EndIf
   aAdd(aIpSemSX3,{"EE9_SERIE",AVSX3("EE9_SERIE",2),AVSX3("EE9_SERIE",3),AVSX3("EE9_SERIE",4)})
   aAdd(aIpSemSX3,{"EE9_NF",AVSX3("EE9_NF",2),AVSX3("EE9_NF",3),AVSX3("EE9_NF",4)})
   // Adicionar no Work o campo Comissão
   aOrd := SaveOrd("SX3",2)
   cCpo := "EE9_PERCOM"
   IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
      aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
   Endif
   cCpo := "EE9_DESCON"
   IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. !X3Uso(SX3->X3_USADO)
      aAdd(aIpSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
   Endif

   IF SX3->(dbSeek(AvKey("EE9_DTDDE","X3_CAMPO"))) .And. EE9->(FieldPos("EE9_DTDDE")) > 0
      aAdd(aIpSemSX3,{"EE9_DTDDE",AVSX3("EE9_DTDDE",2),AVSX3("EE9_DTDDE",3),AVSX3("EE9_DTDDE",4)})
   Endif

   RestOrd(aOrd)

   If Type("lConsign") == "L" .And. lConsign .And. cTipoProc $ PC_VR+PC_VB
      aAdd(aIpSemSx3, {"WK_QTDREM", AvSx3("EE9_SLDINI", 2), AvSx3("EE9_SLDINI", 3), AvSx3("EE9_SLDINI", 4)})
   EndIf

   aPITDeletados := {}
   aIPDELETADOS:={}

   // *** Gera Work de Embalagens ...
   If Select("WorkEm") = 0
      aHEADER:={}
      aCAMPOS:=ARRAY(EEK->(FCOUNT()))
      // ** JPM - 28/06/2006 - Buscar dados do dicionário.
      vetEEK := {}
      AddNaoUsado(vetEEK,"EEK_CODIGO")
      AddNaoUsado(vetEEK,"EEK_PEDIDO")
      AddNaoUsado(vetEEK,"EEK_SEQUEN")
      AddNaoUsado(vetEEK,"EEK_SEQ"   )
      AddNaoUsado(vetEEK,"EEK_EMB"   )
      // **
      //vetEEK := {{"EEK_CODIGO", "C", 20,0},{"EEK_PEDIDO","C",20,0},{"EEK_SEQUEN","C",6,0}}
      cNomArq4 := EECCriaTrab("EEK",VETEEK,"WorkEm")
      EECIndRegua("WorkEm",cNomArq4+TEOrdBagExt(),"EEK_PEDIDO+EEK_SEQUEN+EEK_CODIGO+EEK_SEQ+EEK_EMB")
      Set Index to (cNomArq4+TEOrdBagExt())
   EndIf

   aAdd(aIpSemSX3,{"WP_MKITNF","C",02,0})

   If lIntEmb .Or. lIntegra // TDF-16/03/2011
      If EE9->(FieldPos("EE9_TES")) <> 0 .and.  EE9->(FieldPos("EE9_CF")) <> 0
         aAdd(aIpSemSX3,{"EE9_TES",AVSX3("EE9_TES",AV_TIPO),AVSX3("EE9_TES",AV_TAMANHO),AVSX3("EE9_TES",AV_DECIMAL)})
         aAdd(aIpSemSX3,{"EE9_CF" ,AVSX3("EE9_CF" ,AV_TIPO),AVSX3("EE9_CF" ,AV_TAMANHO),AVSX3("EE9_CF" ,AV_DECIMAL)})
      EndIf
   EndIf

   //TRP - 03/02/07 - Campos do WalkThru
   AADD(aIPSEMSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aIPSEMSX3,{"TRB_REC_WT","N",10,0})

   If EasyEntryPoint("EECAE102")                        // By JPP - 12/11/2009 - 15:30
      ExecBlock("EECAE102",.f.,.f.,"WORKIP_ESTRU")
   EndIf

   // gera work de Itens
   If Select("WorkIp") = 0
      aHEADER:={}
      aCAMPOS:=ARRAY(EE9->(FCOUNT()))
      cNOMARQIP:=EECCriaTrab("EE9",aIPSEMSX3,cWORK2ALIAS)  //ITEM A EMBARCAR
      If AvFlags("GRADE")
         EECIndRegua(cWORK2ALIAS,cNOMARQIP+TEOrdBagExt(),"EE9_PEDIDO+EE9_SEQUEN+WK_ITEMGR+EE9_SEQEMB","AllwayTrue()",;
                 "AllwaysTrue()",STR0002) //"Processando Arquivo Temporario ..."
      Else
         EECIndRegua(cWORK2ALIAS,cNOMARQIP+TEOrdBagExt(),"EE9_PEDIDO+EE9_SEQUEN+EE9_SEQEMB","AllwayTrue()",;
                 "AllwaysTrue()",STR0002) //"Processando Arquivo Temporario ..."
      EndIf
      cNomArq5 := EECGetIndexFile(cWork2Alias, cNOMARQIP, 1)//CriaTrab(,.f.)

      //If !AvFlags("FIM_ESPECIFICO_EXP") //complementar o índice para tratar notas fiscais de remessa com fim específico de exportação
      If !AvFlags("FIM_ESPECIFICO_EXP") .Or. !(lIntegra .Or. AvFlags("NFS_DESVINC")) //RMD - 07/02/17 - Verificar as condições para o campo EE9_NF existir, caso contrário ocorre erro na OffShore
         EECIndRegua(cWork2Alias,cNomArq5+TEOrdBagExt(),"EE9_SEQEMB","AllwayTrue()",;
                 "AllwaysTrue()",STR0002) //"Processando Arquivo Temporario ..."
      Else
         EECIndRegua(cWork2Alias,cNomArq5+TEOrdBagExt(),"EE9_SEQEMB+EE9_NF+EE9_SERIE","AllwayTrue()",;
                 "AllwaysTrue()",STR0002) //"Processando Arquivo Temporario ..."
      EndIf
      Set Index to (cNomArqIp+TEOrdBagExt()),(cNomArq5+TEOrdBagExt())
   EndIf

   // AWR Sexta Feira 13/08/1999
   // PROCESSA({||lITGRAVA:=AE100ITGRAVA(.T.)},"Gravando arquivo de trabalho","Preparacao de Embarque")

   // Alterado por Heder M Oliveira - 11/23/1999
   SA1->(dbSetOrder(1)) //Descricao de clientes
   aCampoPED:={}
   AAdd(aCampoPED, {{||WorkIP->EE9_SEQEMB}, "", AvSx3("EE9_SEQEMB", AV_TITULO)})// Sequência do embarque
   // SVG - 01/07/2010 -
   aAdd(aCampoPED,{{||WorkIP->EE9_PEDIDO},"",AVSX3("EE9_PEDIDO",AV_TITULO)})                 //PROCESSO
   aAdd(aCampoPED,{{||WorkIP->EE9_SEQUEN},"",STR0003})                                       //"Sequência"
   aAdd(aCampoPED,{{||WorkIP->EE9_COD_I},"",STR0004})                                        //"Cód.Item"
   aAdd(aCampoPED,{{||MEMOLINE(WorkIP->EE9_VM_DES,60,1)},"",STR0005})                        //"Descrição"
   aAdd(aCampoPED,{{||BUSCAF_F(WorkIP->EE9_FORN+WorkIP->EE9_FOLOJA,.T.)},"",STR0006})        //"Fornecedor"
   aAdd(aCampoPED,{{||BUSCAF_F(WorkIP->EE9_FABR+WorkIP->EE9_FALOJA,.T.)},"",STR0007})        //"Fabricante"
   aAdd(aCampoPED,{{||WorkIP->EE9_PART_N},"",STR0008}) //"Part.No."
   aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_PRECO,EECPreco("EE9_PRECO", AV_PICTURE))},"",STR0009})  //"Preço Unit."
   aAdd(aCampoPED,{{||WorkIP->EE9_UNIDAD},"",STR0010}) //"Unid.Medida"
   aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_SLDINI,AVSX3("EE9_SLDINI",AV_PICTURE))},"",STR0011}) //"Quantidade"
   aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_PRCTOT,EECPreco("EE9_PRCTOT", AV_PICTURE))},"",STR0012}) //"Vlr.Total"
   If Type ("lDrawSC") == "L" .and. lDrawSC .And. EE9->(FieldPos("EE9_VLSCOB")) > 0
      aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_VLSCOB,AVSX3("EE9_VLSCOB",AV_PICTURE))},"",STR0124}) //"Vlr Tot S/ Cob"   // SVG - 01/07/2010 -
   EndIf
   If EasyGParam("MV_AVG0119",,.F.) .and. EE9->(FieldPos("EE9_DESCON")) > 0
      aAdd(aCampoPED,{{||Transf(WorkIP->EE9_DESCON,EECPreco("EE9_DESCON", AV_PICTURE))},"",AvSX3("EE9_DESCON", AV_TITULO)})  //"Desconto"
   Endif
   aAdd(aCampoPED,{{||Transf(WorkIP->EE9_PRCINC,EECPreco("EE9_PRCINC", AV_PICTURE))},"",AvSX3("EE9_PRCINC", AV_TITULO)})  //"Preço Incoterm"
   aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_PSLQUN,AVSX3("EE9_PSLQUN",AV_PICTURE))},"",STR0013}) //"Peso Liquído Unitário"
   aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_PSLQTO,AVSX3("EE9_PSLQTO",AV_PICTURE))},"",STR0014}) //"Peso Liquído Total"
   aAdd(aCampoPED,{{||WorkIP->EE9_EMBAL1},"",STR0015}) //"Embalagem"
   aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_QTDEM1,AVSX3("EE9_QTDEM1",AV_PICTURE))},"",STR0016}) //"Qtd. Embalagem"
   aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_PSBRUN,AVSX3("EE9_PSBRUN",AV_PICTURE))},"",STR0017}) //"Peso Bruto Unitário"
   aAdd(aCampoPED,{{||TRANSF(WorkIP->EE9_PSBRTO,AVSX3("EE9_PSBRTO",AV_PICTURE))},"",STR0018})  //"Peso Bruto Total"
   // by CAF 04/04/2002 {{||TRANSF(WorkIP->WP_SLDATU,AVSX3("EE9_SLDINI",AV_PICTURE))},"",STR0019}}   //"Saldo a Embarcar"

//             {{||TRANSF(WorkIP->EE9_PRECO, AVSX3("EE9_PRECO",AV_PICTURE) )},"",STR0009},;  //"Preço Unit."
//             {{||TRANSF(WorkIP->EE9_PRCTOT,AVSX3("EE9_PRCTOT",AV_PICTURE))},"",STR0012},; //"Vlr.Total"
//             ColBrw("EE9_PRCINC","WorkIP"),;

   If lIntDraw .and. lOkEE9_ATO
      aAdd(aCampoPED,{"EE9_ATOCON",,AVSX3("EE9_ATOCON",5),AVSX3("EE9_ATOCON",6)}) //Ato Concess.
      aAdd(aCampoPED,{"EE9_SEQED3",,AVSX3("EE9_SEQED3",5),AVSX3("EE9_SEQED3",6)}) //Seq. do A.C.
      aAdd(aCampoPED,{"EE9_RE",,AVSX3("EE9_RE",5),AVSX3("EE9_RE",6)}) //R.E.
   EndIf

   //RMD - 13/10/08 - Exibe no browse os campos de TES e CFOP, se estiver utilizando a integração nova.
   //TDF-16/03/2011
   If lIntEmb .Or. lIntegra
      If EE9->(FieldPos("EE9_TES") > 0 .And. FieldPos("EE9_CF") > 0)
  	     aAdd(aCampoPED, {{|| WorkIp->EE9_TES }, "", AvSx3("EE9_TES", AV_TITULO)})
  	     aAdd(aCampoPED, {{|| WorkIp->EE9_CF } , "", AvSx3("EE9_CF" , AV_TITULO)})
      EndIf
   EndIf

   IF lIntegra .Or. AvFlags("NFS_DESVINC")
      aAdd(aCampoPED,NIL)
      aAdd(aCampoPED,NIL)
      aIns(aCampoPED,3)
      aIns(aCampoPED,4)
      aCampoPED[3] := ColBrw("EE9_NF","WorkIP")
      aCampoPED[4] := ColBrw("EE9_SERIE","WorkIP")
   Endif

   //AOM - 26/04/2011 - Operacao Especial
   If AvFlags("OPERACAO_ESPECIAL")
      AAdd(aCampoPED,{"EE9_CODOPE",,AVSX3("EE9_CODOPE",5),AVSX3("EE9_CODOPE",6)})
      AAdd(aCampoPED,{"EE9_DESOPE",,AVSX3("EE9_DESOPE",5),AVSX3("EE9_DESOPE",6)})
   EndIF

  //by CRF 27/10/2010 - 11:06
  aCampoPED :=  AddCpoUser(aCampoPED,"EE9","5","WorkIp")



   aCampoPIT:={{"WP_FLAG","","  "},;
              {{||WorkIP->EE9_PEDIDO},"","Pedido"},; //"Pedido"
              {{||WorkIP->EE9_SEQUEN},"",STR0003},; //"Sequência"
              {{||WorkIP->EE9_COD_I},"",STR0004},; //"Cód.Item"
              {{||MEMOLINE(WorkIP->EE9_VM_DES,60,1)},"",STR0005},; //"Descrição"
              {{||BUSCAF_F(WorkIP->EE9_FORN+WorkIP->EE9_FOLOJA,.T.)},"",STR0006},; //"Fornecedor"
              {{||BUSCAF_F(WorkIP->EE9_FABR+WorkIP->EE9_FALOJA,.T.)},"",STR0007},; //"Fabricante"
              {{||WorkIP->EE9_PART_N},"",STR0008},; //"Part.No."
              {{||TRANSF(WorkIP->EE9_PRECO,EECPreco("EE9_PRECO", AV_PICTURE))},"",STR0009},; //"Preço Unit."
              {{||WorkIP->EE9_UNIDAD},"",STR0010},; //"Unid.Medida"
              {{||TRANSF(WorkIP->EE9_SLDINI,AVSX3("EE9_SLDINI",AV_PICTURE))},"",STR0011},; //"Quantidade"
              {{||TRANSF(WorkIP->EE9_PRCTOT,EECPreco("EE9_PRCTOT", AV_PICTURE))},"",STR0012},; //"Vlr.Total"
              {{||Transf(WorkIP->EE9_PRCINC,EECPreco("EE9_PRCINC", AV_PICTURE))},"",AvSX3("EE9_PRCINC", AV_TITULO)},;  //"Preço Incoterm"
              {{||TRANSF(WorkIP->EE9_PSLQUN,AVSX3("EE9_PSLQUN",AV_PICTURE))},"",STR0013},; //"Peso Liquído Unitário"
              {{||TRANSF(WorkIP->EE9_PSLQTO,AVSX3("EE9_PSLQTO",AV_PICTURE))},"",STR0014},; //"Peso Liquído Total"
              {{||WorkIP->EE9_EMBAL1},"",STR0015},; //"Embalagem"
              {{||TRANSF(WorkIP->EE9_QTDEM1,AVSX3("EE9_QTDEM1",AV_PICTURE))},"",STR0016},; //"Qtd. Embalagem"
              {{||TRANSF(WorkIP->EE9_PSBRUN,AVSX3("EE9_PSBRUN",AV_PICTURE))},"",STR0017},; //"Peso Bruto Unitário"
              {{||TRANSF(WorkIP->EE9_PSBRTO,AVSX3("EE9_PSBRTO",AV_PICTURE))},"",STR0018},; //"Peso Bruto Total"
              {{||TRANSF(WorkIP->WP_SLDATU,AVSX3("EE9_SLDINI",AV_PICTURE))},"",STR0019}} //"Saldo a Embarcar"

   If EasyGParam("MV_AVG0119",,.F.) .and. EE9->(FieldPos("EE9_DESCON")) > 0
      aAdd(aCampoPIT,{{||Transf(WorkIP->EE9_DESCON,EECPreco("EE9_DESCON", AV_PICTURE))},"",AvSX3("EE9_DESCON", AV_TITULO)})  //"Desconto"
   Endif

//            {{||TRANSF(WorkIP->EE9_PRECO,AVSX3("EE9_PRECO",AV_PICTURE))},"",STR0009},; //"Preço Unit."
//            {{||TRANSF(WorkIP->EE9_PRCTOT,AVSX3("EE9_PRCTOT",AV_PICTURE))},"",STR0012},; //"Vlr.Total"
//            ColBrw("EE9_PRCINC","WorkIP"),;

   If lIntDraw .and. lOkEE9_ATO
      aAdd(aCampoPIT,{"EE9_ATOCON",,AVSX3("EE9_ATOCON",5),AVSX3("EE9_ATOCON",6)}) //Ato Concess.
      aAdd(aCampoPIT,{"EE9_SEQED3",,AVSX3("EE9_SEQED3",5),AVSX3("EE9_SEQED3",6)}) //Seq. do A.C.
   EndIf
   IF lIntegra .Or. AvFlags("NFS_DESVINC")
      aAdd(aCampoPIT,NIL)
      aAdd(aCampoPIT,NIL)
      aIns(aCampoPIT,3)
      aIns(aCampoPIT,4)
      aCampoPIT[3] := ColBrw("EE9_NF","WorkIP")
      aCampoPIT[4] := ColBrw("EE9_SERIE","WorkIP")
   Endif

   //AOM - 26/04/2011 - Operacao Especial
   If AvFlags("OPERACAO_ESPECIAL")
      AAdd(aCampoPIT,{"EE9_CODOPE",,AVSX3("EE9_CODOPE",5),AVSX3("EE9_CODOPE",6)})
      AAdd(aCampoPIT,{"EE9_DESOPE",,AVSX3("EE9_DESOPE",5),AVSX3("EE9_DESOPE",6)})
   EndIF

   aCampoPIT := AddCpoUser(aCampoPIT,"EE9","5","WorkIP")

   aPITPos := {55,4,140,261} //posicao da enchoice

   // *** Cria Work de Despesas ...
   If Select("WorkDe") = 0                    //*** GFP - 19/08/2011 - Criação campo Filtro
      aSemSX3  := { {"EET_RECNO", "N", 7, 0},{"WK_FILTRO", "C", 1, 0}}

      aOrd := SaveOrd("SX3",2)
      cCpo := "EET_OCORRE"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif
      RestOrd(aOrd)

      bAddWork := {|| WorkDe->(RecLock("WorkDe", .T.)),AP100DSGrava(.T.,OC_EM), WorkDe->(MsUnlock())}

      aHeader := {}
      aCampos := Array(EET->(FCount()))

      aDeEnchoice := {"EET_PEDIDO","EET_DESPES","EET_DESCDE","EET_DESADI",;
                      "EET_VALORR","EET_BASEAD","EET_DOCTO",;
                      "EET_PAGOPO","EET_RECEBE","EET_REFREC"}
      If lEET_EVENT
         aAdd(aDeEnchoice,"EET_EVENT")
      EndIf
      aDePos    := {55,4,140,261} //posicao da enchoice
      aDeBrowse := { {{|| WorkDE->EET_DESPES+" "+if(SYB->(dbSeek(xFilial("SYB")+WorkDE->EET_DESPES)),SYB->YB_DESCR,"")},,STR0020},; //"Despesa"
                     ColBrw("EET_DESADI","WorkDE"),;
                     ColBrw("EET_VALORR","WorkDE"),;
                     {{|| IF(WorkDE->EET_BASEAD $ cSim,STR0021,STR0022) },,STR0023},; //"Sim"###"Não"###"Adianta/o ?"
                     ColBrw("EET_DOCTO","WorkDE") }

      SYB->(dbSetOrder(1)) //Descricao de despesas

      //AOM - 19/01/2012
      If EET->(FieldPos("EET_SEQ")) > 0
         aAdd(aSemSX3,{"EET_SEQ",AVSX3("EET_SEQ",2),AVSX3("EET_SEQ",3),AVSX3("EET_SEQ",4)})
      EndIf
      aAdd(aSemSx3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
      cNomArq1 := EECCriaTrab("EET",aSemSX3,"WorkDe")  // Criacao do arquivo de Trabalho

      EECIndRegua("WorkDe",cNomArq1+TEOrdBagExt(),"EET_PEDIDO+EET_DESPES+Dtos(EET_DESADI)+EET_DOCTO","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

      //AOM - 19/01/2012
      If EET->(FieldPos("EET_SEQ")) > 0

               cNomArq1A  := EECGetIndexFile("WorkDe", cNomArq1, 1)
               EECIndRegua("WorkDe",cNomArq1A+TEOrdBagExt(),"EET_PEDIDO+EET_OCORRE+EET_SEQ+EET_DESPES","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

               cNomArq1B  := EECGetIndexFile("WorkDe", cNomArq1, 2)
               EECIndRegua("WorkDe",cNomArq1B+TEOrdBagExt(),"EET_PEDIDO+EET_SEQ","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

               //RMD - 24/02/20 - Incluído novo índice para possibilitar a localização da despesa por agente e código da despesa na inclusão via MsExecAuto
               cNomArq1C  := EECGetIndexFile("WorkDe", cNomArq1, 3)
               EECIndRegua("WorkDe",cNomArq1C+TEOrdBagExt(),"EET_CODAGE+EET_DESPES","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

               Set Index to (cNomArq1+TEOrdBagExt()),(cNomArq1A+TEOrdBagExt()),(cNomArq1B+TEOrdBagExt()),(cNomArq1C+TEOrdBagExt())
      Else
	      Set Index to (cNomArq1+TEOrdBagExt())
      EndIf

   EndIf

   // *** Gera Work de Agentes ...
   If Select("WorkAg") = 0
      bAddWork  := {|| WorkAg->(RecLock("WorkAg", .T.)),AP100AGGrava(.T.,OC_EM), WorkAg->(MsUnlock())}

      aAgEnchoice := {"EEB_CODAGE","EEB_NOME","EEB_TIPOAG"} //"EEB_TXCOMI","EEB_TXSERV","EEB_TXEMBA","EEB_TXFRET"}

      //ER - 15/08/2007
      If EECFlags("INTTRA")
         aAdd(aAgEnchoice,"EEB_CONTR")
      EndIf

      aAgPos    := {55,4,140,261}               //posicao da enchoice
      aAgBrowse := { {"EEB_CODAGE",,STR0025},;  //"Codigo"
                     {"EEB_NOME",,STR0026},;    //"Razão Social"
                     {"EEB_TIPOAG",,STR0027}}  //"Classificação"

      If EE9->(FieldPos("EE9_TIPCOM")) > 0 //JPM - 01/06/05
         AAdd(aAgBrowse,{/*"EEB_TIPCOM"*/ {||BscxBox("EEB_TIPCOM",WorkAg->EEB_TIPCOM) },,AvSx3("EEB_TIPCOM",AV_TITULO)}) //JPM - 31/05/05
      EndIf

      aHEADER:={}
      aSemSX3  := { {"WK_RECNO", "N", 7, 0},{"EEB_OCORRE","C",1,0},{"WK_FILTRO","C",1,0} }// FDR - 29/07/11

      /* by CAF Substituido pela função AddNaoUsado
      If EEB->(FieldPos("EEB_FOBAGE")) > 0
         aAdd(aSemSX3,{"EEB_FOBAGE", AvSx3("EEB_FOBAGE",AV_TIPO)   ,;
                                     AvSx3("EEB_FOBAGE",AV_TAMANHO),;
                                     AvSx3("EEB_FOBAGE",AV_DECIMAL)})
      EndIf
      */
      AddNaoUsado(aSemSX3,"EEB_FOBAGE")
      AddNaoUsado(aSemSX3,"EEB_TOTCOM")

      aCampos  := Array(EEB->(FCount()))

      cNomArq2 := EECCriaTrab("EEB",aSemSX3,"WorkAg")  // Criacao do arquivo de Trabalho

      /*
      IndRegua("WorkAg",cNomArq2+OrdBagExt(),"EEB_CODAGE+EEB_TIPOAG","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
      ** JPM - 01/06/05 */
      EECIndRegua("WorkAg",cNomArq2+TEOrdBagExt(),"EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
      Set Index to (cNomArq2+TEOrdBagExt())

   EndIf

   // *** Gera Work de Instituicoes Financeiras ...
   If Select("WorkIn") = 0
      bAddWork := {|| WorkIn->(RecLock("WorkIn", .T.)),AP100INSGrava(.T.,OC_EM), WorkIn->(MsUnlock())}

      aHEADER := {}
      aSemSX3 := { {"WK_RECNO", "N", 7, 0},{"EEJ_OCORRE","C",1,0} }
      aCampos := Array(EEJ->(FCount()))

      aInEnchoice := {"EEJ_CODIGO","EEJ_AGENCI","EEJ_NUMCON","EEJ_NOME","EEJ_TIPOBC","EEJ_FAVORE","EEJ_BENEDE"}
      aInPos      := {55,4,140,261}               //posicao da enchoice
      aInBrowse   := { {"EEJ_CODIGO",,STR0028},;  //"Código"
                       {"EEJ_AGENCI",,STR0029},;  //"Agência"
                       {"EEJ_NUMCON",,STR0030},;  //"Conta"
                       {"EEJ_NOME",,STR0031}  ,;  //"Nome"
                       {"EEJ_TIPOBC",,STR0032} }  //"Relação"
      // ** JPM - 28/06/2006
      AddNaoUsado(aSemSX3,"EEJ_TIPOBC")
      AddNaoUsado(aSemSX3,"EEJ_CODIGO")
      AddNaoUsado(aSemSX3,"EEJ_NUMCON")
      // **
      aAdd(aSemSx3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
      cNomArq3 := EECCriaTrab("EEJ",aSemSX3,"WorkIn")  // Criacao do arquivo de Trabalho
      EECIndRegua("WorkIn",cNomArq3+TEOrdBagExt(),"EEJ_TIPOBC+EEJ_CODIGO+EEJ_NUMCON","AllwayTrue()",;
                "AllwaysTrue()",STR0024)              //"Processando Arquivo Temporário ..."

      cNomArq32 := EECGetIndexFile("WorkIn", cNomArq3, 1)  // LRS - 16/08/2016
      EECIndRegua("WorkIn",cNomArq32+TEOrdBagExt(),"EEJ_PEDIDO+EEJ_OCORRE","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

      Set Index To (cNomArq3+TEOrdBagExt()),(cNomArq32+TEOrdBagExt())
   EndIf

   // *** Gera Work de NF ...
   If Select("WorkNF") = 0
      bAddWork := {|| WorkNF->(RecLock("WorkNF", .T.)),AE101Grava(.T.,{}), WorkNF->(MsUnlock())}
      aHEADER  := {}
      aCampos  := Array(EEM->(FCount()))
      aSemSx3  := {{"WK_RECNO","N",7,0}}
      If EECFlags("FATFILIAL")
         AddNaoUsado(aSemSx3,"EEM_FIL_NF")
      EndIf
      // ** JPM - 28/06/06
      AddNaoUsado(aSemSX3,"EEM_TIPOCA")
      AddNaoUsado(aSemSX3,"EEM_NRNF")
      // **
      //TRP - 21/03/07
      AddNaoUsado(aSemSX3,"EEM_MODNF")
      cNomArq6 := EECCriaTrab("EEM",aSemSx3,"WorkNF")

      EECIndRegua("WorkNF",cNomArq6+TEOrdBagExt(),"EEM_TIPOCA+EEM_NRNF+EEM_SERIE") //THTS - 09/11/2017
      Set Index to (cNomArq6+TEOrdBagExt())
   EndIf

   // *** Gera Work de Notify's ...
   If Select("WorkNo") = 0
      bAddWork := {|| WorkNo->(RecLock("WorkNo", .T.)),AP100NoGrv(.T.,OC_EM), WorkNo->(MsUnlock())}

      aHEADER := {}
      aSemSX3 := { {"WK_RECNO","N", 7, 0},{"EEN_OCORRE","C",1,0} }
      aCampos := Array(EEJ->(FCount()))

      aNoEnchoice := {"EEN_IMLOJA","EEN_IMPODE","EEN_IMPORT","EEN_ENDIMP","EEN_END2IM"}
      aNoPos      := {55,4,140,261}               //posicao da enchoice
      aNoBrowse   := { {"EEN_IMPORT",,STR0033},;  //"Notify"
                       {"EEN_IMLOJA",,STR0034},;  //"Loja"
                       {"EEN_IMPODE",,STR0005} }  //"Descrição"
      // ** JPM - 28/06/06
      AddNaoUsado(aSemSX3,"EEN_IMPORT")
      AddNaoUsado(aSemSX3,"EEN_IMLOJA")
      // **
      cNomArq7 := EECCriaTrab("EEN",aSemSX3,"WorkNo")  // Criacao do arquivo de Trabalho
      EECIndRegua("WorkNo",cNomArq7+TEOrdBagExt(),"EEN_IMPORT+EEN_IMLOJA","AllwayTrue()",;
              "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
      Set Index to (cNomArq7+TEOrdBagExt())
   EndIf

   If Select("EXB") > 0
      If Select("WorkDoc") = 0
         aHeader    := {}
         aSemSX3    := {{"WK_RECNO","N", 7, 0}}
         aCampos    := Array(EXB->(fCount()))

         aDocBrowse := {{{|| WorkDoc->EXB_FLAG+"-"+If(WorkDoc->EXB_FLAG="1",STR0044,STR0045)},"",STR0046},;  //"Específica"###"Padrão(Cliente/País)"###"Tipo de Tarefa"
                        {{|| LoadDoc(WorkDoc->EXB_CODATV)},"",AVSX3("EXB_CODATV",AV_TITULO)},;
                        {{|| Transf(WorkDoc->EXB_DTREAL,"  /  /  ")},"",AVSX3("EXB_DTREAL",AV_TITULO)},;
                        {{|| WorkDoc->EXB_OBS},"",AVSX3("EXB_OBS",AV_TITULO)},;
                        {{|| WorkDoc->EXB_USER},"",AVSX3("EXB_USER",AV_TITULO)},;
                        {{|| Transf(WorkDoc->EXB_DATA,"  /  /  ")},"",AVSX3("EXB_DATA",AV_TITULO)}}

         // ** JPM - 28/06/06
         AddNaoUsado(aSemSX3,"EXB_ORDEM")
         AddNaoUsado(aSemSX3,"EXB_CODATV")
         AddNaoUsado(aSemSX3,"EXB_TIPO")
         // **

         cNomArq8   := EECCriaTrab("EXB",aSemSX3,"WorkDoc")
         EECIndRegua("WorkDoc",cNomArq8+TEOrdBagExt(),"EXB_ORDEM","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

         cNomArq82  := EECGetIndexFile("WorkDoc", cNomArq8, 1)//CriaTrab(,.f.)
         EECIndRegua("WorkDoc",cNomArq82+TEOrdBagExt(),"EXB_CODATV+EXB_TIPO","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

         dbSelectArea("WorkDoc")
         Set Index To (cNomArq8+TEOrdBagExt()),(cNomArq82+TEOrdBagExt())

         bAddWork := {|| AP100DocGrava(.T.,OC_EM)}
      EndIf
   EndIf

   If EECFlags("HIST_PRECALC")
      aHeader    := {}
      aSemSX3    := {{"WK_VALR ","N", AvSx3("EXM_VALOR",AV_TAMANHO), AvSx3("EXM_VALOR",AV_DECIMAL)},;
                     {"WK_RECNO","N", 7, 0}}

      aCampos    := Array(EXM->(FCount()))
      aPreCalcBrowse := {{{|| WorkCalc->EXM_DESP} ,"", AvSx3("EXM_DESP" ,AV_TITULO)},;
                         {{|| AllTrim(WorkCalc->EXM_DESCR)},"", AVSX3("EXM_DESCR",AV_TITULO)+Space(30)},;
                         {{|| Transf(WorkCalc->WK_VALR,AvSx3("EXM_VALOR",AV_PICTURE))},"", "Valor R$"},;
                         {{|| WorkCalc->EXM_MOEDA},"", AVSX3("EXM_MOEDA",AV_TITULO)},;
                         {{|| Transf(WorkCalc->EXM_VALOR,AvSx3("EXM_VALOR",AV_PICTURE))},"", AvSx3("EXM_VALOR",AV_TITULO)}}

      cNomArq9   := EECCriaTrab("EXM",aSemSX3,"WorkCalc")
      EECIndRegua("WorkCalc",cNomArq9+TEOrdBagExt(),"EXM_DESP","AllwayTrue()","AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

      dbSelectArea("WorkCalc")
      Set Index To (cNomArq9+TEOrdBagExt())

      bAddWork := {|| AP100PreCalcGrv(.t.,OC_EM)}
   EndIf


   If EECFlags("INVOICE")

      // *** Gera Work de Capa das Invoice...
      If Select("WorkInv") = 0

         aHeader := {}
         aSemSX3 := {{"EXP_RECNO","N", 7, 0}}
         aCampos := Array(EXP->(FCount()))

         aInvEnchoice := {"EXP_NRINVO","EXP_DTINVO","EXP_NRCONH","EXP_DTCONH","EXP_LC_NUM",;
                          "EXP_FRPREV","EXP_SEGPRE","EXP_DESPIN","EXP_DESCON","EXP_VLFOB",;
                          "EXP_TOTPED","EXP_PESLIQ","EXP_PESBRU"}

         If AvFlags("INTITAU")
            AAdd(aInvEnchoice, "EXP_PRAZO")
         EndIf

         aInvBrowse   := {{"EXP_NRINVO",,AvSx3("EXP_NRINVO",AV_TITULO),AvSx3("EXP_NRINVO",AV_PICTURE)},;
                          {"EXP_DTINVO",,AvSx3("EXP_DTINVO",AV_TITULO),AvSx3("EXP_DTINVO",AV_PICTURE)},;
                          {"EXP_NRCONH",,AvSx3("EXP_NRCONH",AV_TITULO),AvSx3("EXP_NRCONH",AV_PICTURE)},;
                          {"EXP_DTCONH",,AvSx3("EXP_DTCONH",AV_TITULO),AvSx3("EXP_DTCONH",AV_PICTURE)},;
                          {"EXP_LC_NUM",,AvSx3("EXP_LC_NUM",AV_TITULO),AvSx3("EXP_LC_NUM",AV_PICTURE)},;
                          {"EXP_VLFOB" ,,AvSx3("EXP_VLFOB" ,AV_TITULO),AvSx3("EXP_VLFOB" ,AV_PICTURE)},;
                          {"EXP_FRPREV",,AvSx3("EXP_FRPREV",AV_TITULO),AvSx3("EXP_FRPREV",AV_PICTURE)},;
                          {"EXP_SEGPRE",,AvSx3("EXP_SEGPRE",AV_TITULO),AvSx3("EXP_SEGPRE",AV_PICTURE)},;
                          {"EXP_DESPIN",,AvSx3("EXP_DESPIN",AV_TITULO),AvSx3("EXP_DESPIN",AV_PICTURE)},;
                          {"EXP_DESCON",,AvSx3("EXP_DESCON",AV_TITULO),AvSx3("EXP_DESCON",AV_PICTURE)},;
                          {"EXP_TOTPED",,AvSx3("EXP_TOTPED",AV_TITULO),AvSx3("EXP_TOTPED",AV_PICTURE)}}


         //by CRF 13/10/2010 - 11:45
         aInvBrowse := AddCpoUser(aInvBrowse,"EXP","2")

         If AvFlags("INTITAU")
            AAdd(aInvBrowse, {"EXP_PRAZO" ,,AvSx3("EXP_PRAZO" ,AV_TITULO),AvSx3("EXP_PRAZO" ,AV_PICTURE)}) //FRS
         EndIf

         cArqCapInv := EECCriaTrab("EXP",aSemSX3,"WorkInv")  // Criacao do arquivo de Trabalho
         EECIndRegua("WorkInv",cArqCapInv+TEOrdBagExt(),"EXP_NRINVO","AllwayTrue()",;
                   "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
         Set Index to (cArqCapInv+TEOrdBagExt())

      EndIf

      If Select("WorkDetInv") = 0

         aHeader := {}
         aCampos := Array(EXR->(FCount()))
         aSemSX3 := {{"EXR_RECNO" ,"N", 7, 0}}

         aDetInvEnchoice := {"EXR_PEDIDO","EXR_NRINVO","EXR_SEQEMB","EXR_COD_I" ,"EXR_VM_DES","EXR_FORN",;
                             "EXR_FOLOJA","EXR_FABR"  ,"EXR_FALOJA","EXR_SLDINI","EXR_PRECO" ,"EXR_VLFRET",;
                             "EXR_VLSEGU","EXR_VLOUTR","EXR_VLDESC","EXR_PSLQTO","EXR_PSBRTO","EXR_PRCTOT",;
                             "EXR_PRCINC","EXR_PSLQUN","EXR_PSBRUN","EXR_LC_NUM"}

         aAltDetInv := {"EXR_SLDINI"}

         aDetInvBrowse := {{ "EXR_PEDIDO"  ,"",AvSx3("EXR_PEDIDO",AV_TITULO),AvSx3("EXR_PEDIDO",AV_PICTURE) },;
                           { "EXR_SEQUEN"  ,"",AvSx3("EXR_SEQUEN",AV_TITULO),AvSx3("EXR_SEQUEN",AV_PICTURE) },;
                           /*{ "EXR_SEQEMB"  ,"",AvSx3("EXR_SEQEMB",AV_TITULO),AvSx3("EXR_SEQEMB",AV_PICTURE) },;//LGS-14/01/2016*/;
                           { "EXR_COD_I"   ,"",AvSx3("EXR_COD_I" ,AV_TITULO),AvSx3("EXR_COD_I" ,AV_PICTURE) },;
                           {{|| Memoline(WorkDetInv->EXR_VM_DES,60,1)}                        ,"",AvSx3("EXR_VM_DES",AV_TITULO), },;
                           { "EXR_SLDINI" ,"",AvSx3("EXR_SLDINI",AV_TITULO),AvSx3("EXR_SLDINI",AV_PICTURE) },;
                           { "EXR_UNIDAD" ,"",AvSx3("EXR_UNIDAD",AV_TITULO),AvSx3("EXR_UNIDAD",AV_PICTURE) },; //FJH 06/09/05 Adicionando Unidade de Med. da Qtd.
                           { "EXR_PRECO"  ,"",AvSx3("EXR_PRECO" ,AV_TITULO),EECPreco("EE9_PRECO", AV_PICTURE) },;
                           { "EXR_PRCINC" ,"",AvSx3("EXR_PRCINC",AV_TITULO),AvSx3("EXR_PRCINC",AV_PICTURE) },;
                           { "EXR_VLFRET" ,"",AvSx3("EXR_VLFRET",AV_TITULO),AvSx3("EXR_VLFRET",AV_PICTURE) },;
                           { "EXR_VLSEGU" ,"",AvSx3("EXR_VLSEGU",AV_TITULO),AvSx3("EXR_VLSEGU",AV_PICTURE) },;
                           { "EXR_VLOUTR" ,"",AvSx3("EXR_VLOUTR",AV_TITULO),AvSx3("EXR_VLOUTR",AV_PICTURE) },;
                           { "EXR_VLDESC" ,"",AvSx3("EXR_VLDESC",AV_TITULO),AvSx3("EXR_VLDESC",AV_PICTURE) },;
                           { "EXR_PRCTOT" ,"",AvSx3("EXR_PRCTOT",AV_TITULO),AvSx3("EXR_PRCTOT",AV_PICTURE) },;
                           { "EXR_PSBRTO" ,"",AvSx3("EXR_PSBRTO",AV_TITULO),AvSx3("EXR_PSBRTO",AV_PICTURE) },;
                           { "EXR_PSLQTO" ,"",AvSx3("EXR_PSLQTO",AV_TITULO),AvSx3("EXR_PSLQTO",AV_PICTURE) },;
                           {{|| BuscaF_F(WorkDetInv->(EXR_FORN+EXR_FOLOJA),.T.)}               ,"",AvSx3("EXR_FORN"  ,AV_TITULO) },;
                           {{|| BuscaF_F(WorkDetInv->(EXR_FABR+EXR_FALOJA),.T.)}               ,"",AvSx3("EXR_FABR"  ,AV_TITULO) }}
                         //{ "EXR_PRECO"  ,"",AvSx3("EXR_PRECO" ,AV_TITULO),AvSx3("EE9_PRECO" ,AV_PICTURE) },;



      //by CRF - 13/10/2010 11:08
      aDetInvBrowse := AddCpoUser(aDetInvBrowse,"EXR","2")

         cArqDetInv := EECCriaTrab("EXR",aSemSX3,"WorkDetInv")  // Criacao do arquivo de Trabalho
         EECIndRegua("WorkDetInv",cArqDetInv+TEOrdBagExt(),"EXR_NRINVO+EXR_PEDIDO+EXR_SEQUEN","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..." //LGS-13/01/2016

         cArq2DetInv := EECGetIndexFile("WorkDetInv", cArqDetInv, 1)//CriaTrab(,.f.)  // Criacao do arquivo de Trabalho
         EECIndRegua("WorkDetInv",cArq2DetInv+TEOrdBagExt(),"EXR_PEDIDO+EXR_SEQUEN" /*"EXR_SEQEMB"*/,"AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..." //LGS-13/01/2016

         Set Index To (cArqDetInv+TEOrdBagExt()),(cArq2DetInv+TEOrdBagExt())

      EndIf

   EndIf

   If Ap104VerPreco() .and. EECFlags("CAFE")
      AAdd(aCampoPED,{{||TRANSF(WorkIp->EE9_PRECO5,EECPreco("EE9_PRECO5",6))},"","Preco $/Sc50"})
      AAdd(aCampoPED,{{||TRANSF(WorkIp->EE9_PRECO2,EECPreco("EE9_PRECO2",6))},"","Preco $/Sc60"})
      AAdd(aCampoPED,{{||TRANSF(WorkIp->EE9_PRECO3,EECPreco("EE9_PRECO3",6))},"","Preco Cents/Lb"})
      AAdd(aCampoPED,{{||TRANSF(WorkIp->EE9_PRECO4,EECPreco("EE9_PRECO4",6))},"","Preco $/Ton"})
   Endif

   If EECFlags("INTERMED") // EECFlags("CONTROL_QTD") // se a rotina de controle de quantidades entre filiais Brasil e Off-Shore estiver ligada...
                           // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
      If Select("WorkGrp") = 0 // cria work para agrupamento de itens por origem e pelos campos do aConsolida.

         aHeader := {}
         aCampos := {}
         aSemSx3 := {}
         SX3->(DbSetOrder(2))
         For i := 1 To Len(aGrpCpos) // Adiciona campos para criação da work de agrupamentos.
            SX3->(DbSeek(aGrpCpos[i]))
            If aGrpCpos[i] = "EE9_ORIGEM"
               AAdd(aSemSx3,{"EE9_ORIGEM","C",AvSx3("EE9_SEQUEN",AV_TAMANHO),0})
            ElseIf aGrpCpos[i] = "WP_FLAG"
               AAdd(aSemSx3,{"WP_FLAG" ,"C",2,0})
            ElseIf aGrpCpos[i] = "WP_SLDATU"
               AAdd(aSemSx3,{"WP_SLDATU" ,"N",AvSx3("EE8_SLDATU",AV_TAMANHO),AvSx3("EE8_SLDATU",AV_DECIMAL)})
            ElseIf X3Uso(SX3->X3_USADO)
               AAdd(aCampos,AllTrim(aGrpCpos[i]))
            Else
               AddNaoUsado(aSemSx3,AllTrim(aGrpCpos[i]))
            EndIf
         Next

         //TRP - 03/02/07 - Campos do WalkThru
         AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
         AADD(aSemSX3,{"TRB_REC_WT","N",10,0})



         // CRF 22/11/2010 - 11:46
         aSemSx3:= addWkCpoUser(aSemSx3,"EE9")


         cNomArqGrp   := EECCriaTrab(,aSemSx3,"WorkGrp")
         EECIndRegua("WorkGrp",cNomArqGrp+TEOrdBagExt(),"EE9_PEDIDO+EE9_ORIGEM","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
         Set Index to (cNomArqGrp+TEOrdBagExt())
         aGrpBrowse := {}

         SX3->(DbSetOrder(2))

         AAdd(aGrpBrowse,{"WP_FLAG",,""}) //campo de flag
         For i := 1 To Len(aGrpCpos)
            If aGrpCpos[i] $ "EE9_FOLOJA/EE9_FALOJA/WP_FLAG   "
               Loop
            EndIf
            If aGrpCpos[i] = "WP_SLDATU"
               AAdd(aGrpBrowse,{{||TRANSF(WorkGrp->WP_SLDATU,AVSX3("EE9_SLDINI",AV_PICTURE))},"",STR0019}) //"Saldo a Embarcar"
               Loop
            EndIf
            If aGrpCpos[i] = "EE9_ORIGEM"
               AAdd(aGrpBrowse,{{||TRANSF(WorkGrp->EE9_ORIGEM,AVSX3("EE9_SEQUEN",AV_PICTURE))},"",STR0116 })//"Sequência/Origem - Pedido"
               Loop
            EndIf

            AAdd(aGrpBrowse,ColBrw(aGrpCpos[i],"WorkGrp")) // campos do browse

            If aGrpCpos[i] = "EE9_VM_DES"
               aGrpBrowse[Len(aGrpBrowse)][1] := {|| MemoLine(WorkGrp->EE9_VM_DES,AvSx3("EE9_VM_DES",AV_TAMANHO),1)}
            EndIf

            If aGrpCpos[i] = "EE9_FORN  "
               aGrpBrowse[Len(aGrpBrowse)][1] := {|| BUSCAF_F(WorkGrp->EE9_FORN+WorkGrp->EE9_FOLOJA,.T.) }
               aGrpBrowse[Len(aGrpBrowse)][3] := STR0006 // "Fornecedor"
            EndIf

            If aGrpCpos[i] = "EE9_FABR  "
               aGrpBrowse[Len(aGrpBrowse)][1] := {|| BUSCAF_F(WorkGrp->EE9_FABR+WorkGrp->EE9_FALOJA,.T.) }
               aGrpBrowse[Len(aGrpBrowse)][3] := STR0007 // "Fabricante"
            EndIf

            // Tratamento condicional para campos que não têm sempre o conteúdo igual, para ficar com um '-' no browse
            If aGrpInfo[i] = "N"
               cCampo := aGrpCpos[i]
               //(quase o mesmo tratamento da avsx3)
               SX3->(DbSeek(cCampo))
               If !Empty(SX3->X3_INIBRW)
                  cIniBrw := AllTrim(SX3->X3_INIBRW)
               Else
                  If !Empty(X3Cbox())
                     aBox := ComboX3Box(cCampo,X3Cbox())
                     cIniBrw := ""
                     For i:=1 To Len(aBox)
                        cIniBrw += "IF(WorkGrp->"+cCampo+" == "+IF(SX3->X3_TIPO=="C","'","")+Substr(aBox[i],1,At("=",aBox[i])-1)+IF(SX3->X3_TIPO=="C","'","")+",'"+Substr(aBox[i],At("=",aBox[i])+1)+"',"
                     Next
                     cIniBrw += "''"+Replic(")",Len(aBox))
                  ElseIf Empty(SX3->X3_PICTURE)
                     cIniBrw := "WorkGrp->"+cCAMPO
                  Else
                     cIniBrw := "Transform(WorkGrp->"+cCAMPO+",'"+AllTrim(SX3->X3_PICTURE)+"')"
                  Endif
               Endif
               cIniBrw := "{|| If(Empty(WorkGrp->" + cCAMPO + "),'-'," + cIniBrw + ") }"
               aGrpBrowse[Len(aGrpBrowse)][1] := &cIniBrw
            EndIf

         Next

      EndIf

      If Select("WorkOpos") = 0 // work de itens da filial oposta
         aCampos := {}
         cNomArqOpos := EECCriaTrab(,WorkIp->(DbStruct()),"WorkOpos")
         EECIndRegua("WorkOpos",cNomArqOpos+TEOrdBagExt(),"EE9_PEDIDO+EE9_SEQUEN","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
         Set Index to (cNomArqOpos+TEOrdBagExt())
      EndIf
   EndIf

   If EECFlags("CAFE")

      // *** Gera Work de Capa das OIC´s
      If Select("WKEXZ") == 0

         aHeader := {}
         aSemSX3 := {{"WK_RECNO"  ,"N", 10, 0},;
                     {"WK_FLAG"   ,"C",  2, 0},;
                     {"WK_SLDINV" ,"N", 15, 3}}

         aOrd := SaveOrd("SX3",2)
         cCpo := "EY2_NRINVO"
         IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
            aAdd(aSemSX3,{"WK_NRINVO",AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
         Endif
         RestOrd(aOrd)


         aCampos := Array(EXZ->(FCount()))

         cArqCapOIC := EECCriaTrab("EXZ",aSemSX3,"WKEXZ")

         aEXZBrowse := ArrayBrowse("EXZ","WKEXZ")
         /* RMD - 04/05/08 - Volta a utilizar ArrayBrowse porque a não conformidade abaixo não foi mais
                             reproduzida.

         //ER - 18/10/2006 - Não utiliza ArrayBrowse, porque causa erro de "Violação de Acesso".
         aEXZBrowse := {{"EXZ_OIC"  ,"",AvSx3("EXZ_OIC"  ,AV_TITULO),AvSx3("EXZ_OIC"  ,AV_PICTURE)},;
                        {"EXZ_SAFRA","",AvSx3("EXZ_SAFRA",AV_TITULO),AvSx3("EXZ_SAFRA",AV_PICTURE)},;
                        {"EXZ_QTDE" ,"",AvSx3("EXZ_QTDE" ,AV_TITULO),AvSx3("EXZ_QTDE" ,AV_PICTURE)}}
         */

         EECIndRegua("WKEXZ",cArqCapOIC+TEOrdBagExt(),"EXZ_OIC+EXZ_SAFRA","AllwayTrue()",;
                   "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

         cArq2CapOIC := EECGetIndexFile("WKEXZ", cArqCapOIC, 1)// FSY - 30/01/2014 - Corrigido variavel cArqCapOIC do 2 parametro
         //cArq2CapOIC := EECGetIndexFile("WKEXZ", cArq2CapOIC, 1)//CriaTrab(,.f.)
         EECIndRegua("WKEXZ",cArq2CapOIC+TEOrdBagExt(),"EXZ_SAFRA+EXZ_OIC","AllwayTrue()",;
                   "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
         Set Index To (cArqCapOIC+TEOrdBagExt()),(cArq2CapOIC+TEOrdBagExt())

      EndIf

      If Select("WKEY2") == 0

         aHeader := {}
         aCampos := Array(EY2->(FCount()))
         aSemSX3 := {{"WK_RECNO" ,"N", 10, 0}}

         AddNaoUsado(aSemSX3, "EY2_NRINVO")

         aEY2Browse := ArrayBrowse("EY2","WKEY2")

         cArqDetOIC := EECCriaTrab("EY2",aSemSX3,"WKEY2")
         EECIndRegua("WKEY2",cArqDetOIC+TEOrdBagExt(),"EY2_OIC+EY2_SAFRA+EY2_SEQEMB","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

         cArq2DetOIC := EECGetIndexFile("WKEY2", cArqDetOIC, 1)//CriaTrab(,.f.)  // Criacao do arquivo de Trabalho
         EECIndRegua("WKEY2",cArq2DetOIC+TEOrdBagExt(),"EY2_SEQEMB","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

         Set Index To (cArqDetOIC+TEOrdBagExt()),(cArq2DetOIC+TEOrdBagExt())

      EndIf

      If Select("WkArm") == 0
         //THTS - 31/10/2017
         aAdd(aCpoWkStru,{"WK_RECNO","N",7,0})
         aAdd(aCpoWkStru,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
         cWorkArmazem := EECCriaTrab("EY9",aCpoWkStru,"WkArm")
         EECIndRegua("WkArm",cWorkArmazem+TEOrdBagExt(),"EY9_CODARM","AllwayTrue()",;
                  "AllwaysTrue()","Processando Arquivo Temporario ...")
         Set Index to (cWorkArmazem+TEOrdBagExt())
      EndIf
   EndIf

   If Type("lPagtoAnte") == "L" .And. lPagtoAnte // Pagamento Antecipado habilitado // By JPP - 08/02/2006 11:40
      If Select("WORKSLD_AD") = 0 // Tabela Temporária utilizada na valida e Tratamento de Adiantamentos vinculados
         aHeader := {}
         aCampos:= Array(EEQ->(fCount()))
         aSemSx3 := {}
         Aadd(aSemSx3,{"EEQ_PREEMB","C",AvSx3("EEQ_PREEMB",AV_TAMANHO),AvSx3("EEQ_PREEMB",AV_DECIMAL)})
         Aadd(aSemSx3,{"WK_FLAG"  ,"C",02,0})
         Aadd(aSemSx3,{"WK_VLEST" ,"N",AVSX3("EEQ_VL",AV_TAMANHO),AVSX3("EEQ_VL",AV_DECIMAL)})
         Aadd(aSemSx3,{"WK_RECNO","N",10,0})
         Aadd(aSemSx3,{"WK_STATUS","C",50,0})

         cArqAdiant := EECCriaTrab("EEQ",aSemSx3,"WORKSLD_AD")
         EECIndRegua("WORKSLD_AD",cArqAdiant+TEOrdBagExt(),"EEQ_FASE+EEQ_PREEMB+EEQ_PARC",,,STR0024) //"Processando Arquivo Temporário..."
         Set Index To (cArqAdiant+TEOrdBagExt())
      EndIf
   EndIf

   //RMD - 08/05/06 - Tratamentos para rotina de consignação
   //If Type("lConsign") == "L" .And. lConsign //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
      Do Case
        Case Empty(cTipoProc) .Or. cTipoProc == PC_RC .Or. cTipoProc == PC_BC
            If aScan(aEECCamposEditaveis, "EEC_DTREC") == 0
               aAdd(aEECCamposEditaveis,"EEC_DTREC")
            EndIf
            If aScan(aHdEnchoice, "EEC_DTREC") == 0
               aAdd(aHdEnchoice,"EEC_DTREC")
            EndIf
            If Select("WKEY6") == 0
               aHeader := {}
               aCampos := Array(EY6->(FCount()))
               aSemSx3 := {{"WK_QTDVIN","N",15, 3},;
                           {"WK_ALTIPO","C", 1, 0}}
               cArqWkEY6 := EECCriaTrab("EY6", aSemSx3, "WKEY6")
               EECIndRegua("WKEY6", cArqWkEY6+TEOrdBagExt(),"EY6_RE",;
                        "AllwayTrue()","AllwaysTrue()",STR0024)//"Processando Arquivo Temporário..."
               Set Index To (cArqWkEY6+TEOrdBagExt())
            EndIf

         Case cTipoProc == PC_VR .Or. cTipoProc == PC_VB
            If aScan(aEECCamposEditaveis, "EEC_ARM") == 0
               aAdd(aEECCamposEditaveis,"EEC_ARM")
            EndIf
            If aScan(aEECCamposEditaveis, "EEC_ARLOJA") == 0
               aAdd(aEECCamposEditaveis,"EEC_ARLOJA")
            EndIf
            If aScan(aEECCamposEditaveis, "EEC_ARMDES") == 0
               aAdd(aEECCamposEditaveis,"EEC_ARMDES")
            EndIf
            If aScan(aHdEnchoice, "EEC_ARM") == 0
               aAdd(aHdEnchoice,"EEC_ARM")
            EndIf
            If aScan(aHdEnchoice, "EEC_ARLOJA") == 0
               aAdd(aHdEnchoice,"EEC_ARLOJA")
            EndIf
            If aScan(aHdEnchoice, "EEC_ARMDES") == 0
               aAdd(aHdEnchoice,"EEC_ARMDES")
            EndIf
            If Select("WKEY5") == 0
               aHeader := {}
               aCampos := Array(EY5->(FCount()))
               aSemSx3 := {{"WK_RECNO" ,"N", 7, 0},;
                           {"WK_MARCA" ,"C", 2, 0},;
                           {"WK_CHANGE","C", 2, 0},;
                           {"WK_QTDVIN","N",15, 3}}
               cArqWkEY5 := EECCriaTrab("EY5", aSemSx3, "WKEY5")
               EECIndRegua("WKEY5", cArqWkEY5+TEOrdBagExt(),"EY5_IMPORT+EY5_IMLOJA+EY5_PREEMB+EY5_PEDIDO+EY5_SEQUEN+EY5_COD_I+EY5_RE+EY5_INVOIC",;
                        "AllwayTrue()","AllwaysTrue",STR0024)//"Processando Arquivo Temporário..."
               cArq2WkEY5 := EECGetIndexFile("WKEY5", cArqWkEY5, 1)//CriaTrab(,.F.)
               EECIndRegua("WKEY5", cArq2WkEY5+TEOrdBagExt(),"EY5_IMPORT+EY5_IMLOJA+EY5_COD_I+EY5_UNPES+DTOS(EY5_DTRE)",;
                        "AllwayTrue()","AllwaysTrue()",STR0024)//Procesando Arquivo Temporário...
               Set Index To (cArqWkEY5+TEOrdBagExt()),(cArq2WkEY5+TEOrdBagExt())
            EndIf
            If Select("WKEY7") == 0
               aHeader := {}
               aCampos := Array(EY7->(FCount()))
               aSemSx3 := {{"WK_RECNO" ,"N", 7, 0}}
               cArqWkEY7 := EECCriaTrab("EY7", aSemSx3, "WKEY7")
               EECIndRegua("WKEY7", cArqWkEY7+TEOrdBagExt(),"EY7_PREEMB+EY7_PEDIDO+EY7_SEQUEN+EY7_COD_I+EY7_RE+EY7_INVOIC+EY7_SEQEMB",;
                        "AllwayTrue()","AllwaysTrue()",STR0024)//"Processando Arquivo Temporário..."
               Set Index To (cArqWkEY7+TEOrdBagExt())

               cArq2WkEY7 := EECGetIndexFile("WKEY7", cArq2WkEY7, 1)//CriaTrab(,.F.)
               EECIndRegua("WKEY7", cArq2WkEY7+TEOrdBagExt(),"EY7_SEQEMB",;
                        "AllwayTrue()","AllwaysTrue()",STR0024)//Procesando Arquivo Temporário...
               Set Index To (cArqWkEY7+TEOrdBagExt()),(cArq2WkEY7+TEOrdBagExt())
            EndIf
      End Case
   //EndIf
   If Type("lItFabric") == "L" .And. lItFabric //EasyGParam("MV_AVG0138",,.F.)   // By JPP - 14/11/2007 - 14:00
      If Select("WKEYU") == 0
         aItFabPos  := {55,4,140,420}//{55,4,140,261}
         aCampoEYU:={{{||If(WKEYU->EYU_TIPO=="1","Empresa Industrial-Intermediaria",If(WKEYU->EYU_TIPO=="2","Fabricante-Intermediario",""))},"",AVSX3("EYU_TIPO",AV_TITULO)},;
                     {{||WKEYU->EYU_FABR},"",AVSX3("EYU_FABR",AV_TITULO)},;
                     {{||WKEYU->EYU_FA_LOJ},"",AVSX3("EYU_FA_LOJ",AV_TITULO)},;
                     {{||WKEYU->EYU_FA_DES},"",AVSX3("EYU_FA_DES",AV_TITULO)},;
                     {{||WKEYU->EYU_CNPJ},"",AVSX3("EYU_CNPJ",AV_TITULO)},;
                     {{||WKEYU->EYU_UF},"",AVSX3("EYU_UF",AV_TITULO)},;
                     {{||WKEYU->EYU_ATOCON},"",AVSX3("EYU_ATOCON",AV_TITULO)},;
                     {{||WKEYU->EYU_SEQED3},"",AVSX3("EYU_SEQED3",AV_TITULO)},;   //TRP - 29/10/10
                     {{||WKEYU->EYU_PROD},"",AVSX3("EYU_PROD",AV_TITULO)},;
                     {{||WKEYU->EYU_VM_DES},"",AVSX3("EYU_VM_DES",AV_TITULO)},;
                     {{||WKEYU->EYU_POSIPI},"",AVSX3("EYU_POSIPI",AV_TITULO)},;
                     {{||WKEYU->EYU_NCMDES},"",AVSX3("EYU_NCMDES",AV_TITULO)},;
                     {{||WKEYU->EYU_NCM_UM},"",AVSX3("EYU_NCM_UM",AV_TITULO)},;
                     {{||WKEYU->EYU_QTD},"",AVSX3("EYU_QTD",AV_TITULO)},;
                     {{||WKEYU->EYU_UMPROD},"",AVSX3("EYU_UMPROD",AV_TITULO)},;
                     {{||WKEYU->EYU_QTDPRO},"",AVSX3("EYU_QTDPRO",AV_TITULO)},;
                     {{||WKEYU->EYU_MOEDA},"",AVSX3("EYU_MOEDA",AV_TITULO)},;
                     {{||WKEYU->EYU_VALOR},"",AVSX3("EYU_VALOR",AV_TITULO)},;
                     {{||WKEYU->EYU_DTNF},"",AVSX3("EYU_DTNF",AV_TITULO)}}



         If EYU->(FieldPos("EYU_VLSCOB")) > 0
            AAdd(aCampoEYU,{{||WKEYU->EYU_VLSCOB},"",AVSX3("EYU_VLSCOB",AV_TITULO)})
         Endif

         If EYU->(FieldPos("EYU_PESO")) > 0
            AAdd(aCampoEYU,{{||WKEYU->EYU_PESO},"",AVSX3("EYU_PESO",AV_TITULO)})
         Endif

         If EYU->(FieldPos("EYU_OBS")) > 0
            AAdd(aCampoEYU,{{||WKEYU->EYU_OBS},"",AVSX3("EYU_OBS",AV_TITULO)})
         Endif
         aHeader := {}
         aCampos := Array(EYU->(FCount()))
         aSemSx3 := {{"WK_RECNO" ,"N", 7, 0}}
         aAdd(aSemSx3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
         cArqWkEYU := EECCriaTrab("EYU", aSemSx3, "WKEYU")
         EECIndRegua("WKEYU", cArqWkEYU+TEOrdBagExt(),"EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON",;
                  "AllwayTrue()","AllwaysTrue()",STR0024)//"Processando Arquivo Temporário..."
         Set Index To (cArqWkEYU+TEOrdBagExt())
      EndIf
   EndIf

   ///////////////////////////////////////////////
   //ER - 13/11/2008                            //
   //Criação da Work de Notas Fiscais de Remessa//
   ///////////////////////////////////////////////
   If AvFlags("FIM_ESPECIFICO_EXP")
      If Select("WK_NFRem") == 0

         ChkFile("EYY")

         aHeader := {}
         aCampos := Array(EYY->(FCount()))

         If !NFRemFimEsp()

            aSemSX3 := {{"EYY_RECNO","N", 7, 0},{"EE9_COD_I","C", 15, 0}}//FSY - 08/01/2014 - Embarque
            Aadd(aSemSX3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deverá ser sempre o último campo da Work

            cArqNFRem := EECCriaTrab("EYY",aSemSX3,"WK_NFRem")  // Criacao do arquivo de Trabalho
            EECIndRegua("WK_NFRem", cArqNFRem + TEOrdBagExt(), "EYY_SEQUEN + EYY_NFSAI + EYY_SERSAI + EYY_NFENT + EYY_SERENT",;
                      "AllwayTrue()","AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

            cArq2NFRem := EECGetIndexFile("WK_NFRem", cArqNFRem, 2)  // Criacao do arquivo de Trabalho
            EECIndRegua("WK_NFRem",cArq2NFRem+TEOrdBagExt(),"EE9_COD_I + EYY_PEDIDO + EYY_SEQUEN + EYY_NFSAI + EYY_SERSAI","AllwayTrue()",;
                      "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

            cArq3NFRem := EECGetIndexFile("WK_NFRem", cArqNFRem, 3)  // Criacao do arquivo de Trabalho //NCF - 23/11/2017
            EECIndRegua("WK_NFRem",cArq3NFRem+TEOrdBagExt(),"Str(EYY_RECNO)","AllwayTrue()",;
                      "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
         Else

            aSemSX3 := {{"EYY_RECNO" , "N", 7, 0},;
                        {"SD1_RECNO" , "N", 7, 0}}

            Aadd(aSemSX3,{"DBDELETE","L",1,0}) //MPG - 15/01/2018 - Este campo deverá ser sempre o último campo da Work

            cArqNFRem := EECCriaTrab("EYY",aSemSX3,"WK_NFRem")  // Criacao do arquivo de Trabalho
            EECIndRegua("WK_NFRem", cArqNFRem + TEOrdBagExt(), "EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI",;
                      "AllwayTrue()","AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

            cArq2NFRem := EECGetIndexFile("WK_NFRem", cArqNFRem, 2)  // Criacao do arquivo de Trabalho
            EECIndRegua("WK_NFRem",cArq2NFRem+TEOrdBagExt(),"EYY_COD_I + EYY_PEDIDO + EYY_SEQUEN + EYY_NFSAI + EYY_SERSAI","AllwayTrue()",;
                      "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

            cArq3NFRem := EECGetIndexFile("WK_NFRem", cArqNFRem, 3)  // Criacao do arquivo de Trabalho //NCF - 23/11/2017
            EECIndRegua("WK_NFRem",cArq3NFRem+TEOrdBagExt(),"Str(EYY_RECNO)","AllwayTrue()",;
                      "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
         EndIf

         Set Index To (cArqNFRem+TEOrdBagExt()), (cArq2NFRem+TEOrdBagExt()), (cArq3NFRem+TEOrdBagExt())
      EndIf
   EndIf

   //TRP - 16/02/2009
   //Criação da Work para Manutenção de DrawBack sem Cobertura Cambial na Exportação
   If Select("WorkEDG") == 0  .and. ChkFile("EDG")

      aSemSX3 := {{"EDG_RECNO","N", 10, 0},;
                  {"EDG_FLAG"  ,"L",01,0}}
      aCampos := Array(EDG->(FCount()))

      cArqDrawSC := EECCriaTrab("EDG",aSemSX3,"WorkEDG")
      EECIndRegua("WorkEDG",cArqDrawSC+TEOrdBagExt(),"EDG_SEQEMB+EDG_ITEM","AllwayTrue()",;
                   "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
      Set Index To (cArqDrawSC+TEOrdBagExt())
   EndIf
   //TRP - 29/10/10 - Criacão da Work para Manutencão de Notas Fiscais de Fabricantes
   If Select("WKEWI") == 0  .and. ChkFile("EWI")

      aSemSx3 := {{"WK_RECNO" ,"N", 7, 0}}

      cArqWkEWI := EECCriaTrab("EWI", aSemSx3, "WKEWI")
      EECIndRegua("WKEWI", cArqWkEWI+TEOrdBagExt(),"EWI_PREEMB+EWI_SEQEMB+EWI_TIPO+EWI_CNPJ+EWI_POSIPI+EWI_ATOCON+EWI_SEQED3",;
               "AllwayTrue()","AllwaysTrue()",STR0024)//"Processando Arquivo Temporário..."
      Set Index To (cArqWkEWI+TEOrdBagExt())

   EndIf
End Sequence

RestOrd(aSaveOrd)

RETURN lRET

/*
Funcao      : LoadDoc(cCodDoc)
Parametros  : Codigo do documento.
Retorno     : .t.
Objetivos   : Trazer descricao do documento.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/08/2002 17:23
Revisao     :
Obs.        :
*/
*------------------------------*
Static Function LoadDoc(cCodDoc)
*------------------------------*
Local cRet:="", aOrd:=SaveOrd("EEA")

Begin Sequence

   If EEA->(DbSeek(xFilial("EEA")+cCodDoc))
      cRet:=AllTrim(cCodDoc)+" - "+EEA->EEA_TITULO
   EndIf

End Sequence

RestOrd(aOrd)

Return cRet
*--------------------------------------------------------------------
STATIC FUNCTION AE102(cP_MPGEXP)
LOCAL n1
// CARREGANDO OS VALORES P/ SISCOMEX.
// PRIMEIRO POR MOD. DE PAGTO DA EXPORTACAO E DEPOIS
// PELA CONDICAO/DIASPA DE PAGAMENTO
IF cP_MPGEXP = "002"
   // CONSIGNADO
   M->EEC_NPARC  := 1
   M->EEC_VISTA  := 0
   M->EEC_ANTECI := 0
   M->EEC_PARCEL := 0
   M->EEC_VLCONS := AE100VLPROC()
ELSEIF cP_MPGEXP = "005"
       // ANTECIPADO
       M->EEC_NPARC  := 1
       M->EEC_VISTA  := 0
       M->EEC_ANTECI := AE100VLPROC()
       M->EEC_PARCEL := 0
       M->EEC_VLCONS := 0
ELSEIF M->EEC_DIASPA = -1
       // A VISTA
       M->EEC_NPARC  := 1
       M->EEC_VISTA  := AE100VLPROC()
       M->EEC_ANTECI := 0
       M->EEC_PARCEL := 0
       M->EEC_VLCONS := 0
ELSE
   // PARCELADO
   n1 := 1
   DO WHILE SY6->(FIELDPOS("Y6_PERC_"+STRZERO(n1,2,0))) # 0 .AND.;
      SY6->(FIELDGET(FIELDPOS("Y6_PERC_"+STRZERO(n1,2,0)))) > 0
      *
      n1 := n1+1
   ENDDO
   M->EEC_NPARC  := IF((n1-1)=0,1,n1-1)
   M->EEC_VISTA  := 0
   M->EEC_ANTECI := 0
   M->EEC_PARCEL := (AE100VLPROC()-M->EEC_ANTECI)/M->EEC_NPARC
   M->EEC_VLCONS := 0
ENDIF
// by CAF 30/01/2003 Compatibilizacao EEQ M->EEC_CBVCT  := IF(EMPTY(M->EEC_CBVCT).AND.!EMPTY(M->EEC_DTCONH),(M->EEC_DTCONH+M->EEC_DIASPA),M->EEC_CBVCT)
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION AE102TOT(cP_RATEIO)
cP_RATEIO := ALLTRIM(cP_RATEIO)
WORKIP->(DBCLEARFILTER(),DBGOTOP())
DO WHILE ! WORKIP->(EOF())
   IF WORKIP->WP_FLAG <> "  "
      IF cP_RATEIO = "1"  // PESO LIQUIDO
         nTOTAL := nTOTAL+WORKIP->EE9_PSLQTO

      ELSEIF cP_RATEIO = "2"  // PESO BRUTO
         nTOTAL := nTOTAL+WORKIP->EE9_PSBRTO

      ELSE  // PRECO DIGITADO
         If lConvUnid // By JBJ - 17/12/02
            nTOTAL := nTOTAL+(AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.);
                      *WORKIP->EE9_PRECO)
            /*
            nTOTAL := nTOTAL+(AvTransUnid(WorkIp->EE9_UNPRC,WorkIp->EE9_UNIDAD,WorkIp->EE9_COD_I,WorkIp->EE9_PRECO,.F.);
                      *WORKIP->EE9_SLDINI)
            */
         Else
            nTOTAL := nTOTAL+WORKIP->(Round(EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))*EE9_SLDINI)
         EndIf
      ENDIF
      If lConvUnid // ** By JBJ - 17/12/02
         nTOTPED := nTOTPED+(AvTransUnid(WorkIp->EE9_UNIDAD,WorkIp->EE9_UNPRC,WorkIp->EE9_COD_I,WorkIp->EE9_SLDINI,.F.);
                    *Round(WORKIP->EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL)))
         /*
         nTOTPED := nTOTPED+(AvTransUnid(WorkIp->EE9_UNPRC,WorkIp->EE9_UNIDAD,WorkIp->EE9_COD_I,WorkIp->EE9_PRECO,.F.);
                    *WORKIP->EE9_SLDINI)
         */
      Else
         nTOTPED := nTOTPED+WORKIP->(Round(EE9_PRECO,AVSX3("EE9_PRECO",AV_DECIMAL))*EE9_SLDINI)
      EndIf
   ENDIF
   WORKIP->(DBSKIP())
ENDDO
RETURN(NIL)
*--------------------------------------------------------------------

/*
Funcao      : ae102SetWorks()
Parametros  : Nenhum.
Retorno     : aRet - Variáveis para deleção futura das works.
Objetivos   : Declaração de variáveis/Criação de works.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/05/2003 14:09.
Revisao     :
Obs.        :
*/
*----------------------*
Function ae102SetWorks()
*----------------------*
Local aRet:={}

Private cNomArqIp   , cNomArq1   , cNomArq2  ,;
        cNomArq3    , cNomArq4   , cNomArq5  ,;
        cNomArq6    , cNomArq7   , cNomArq8  ,;
        cNomArq82   , cNomArq9   , cArqCapInv,;
        cArqDetInv  , cArq2DetInv, cArqAdiant,;
        cArqWkEY5   , cArq2WkEY5 , cArqWkEY6 ,;
        cArqWkEY7   , cArq2WkEY7 , cNomArqGrp,;
        cNomArqOpos , cArqCapOIC , cArqDetOIC,;
        cWorkArmazem, cArqNFRem, cArq2NFRem, cArq3NFRem, cNomArq1A, cNomArq1B, cNomArq1C//RMD - 24/02/20

Private lIntegra := IsIntFat(), lIntermed := .f., lConvUnid := .f.,;
        lIntDraw := EasyGParam("MV_EEC_EDC",,.F.),;
        lOkEE9_ATO  := SX3->(dbSeek("EE9_ATOCON"))

//RMD - 21/02/17 - Checa se as variáveis não existem antes de declarar, para não perder conteúdo
//Private cFilBr := "", cFilEx := ""
If Type("cFilBr") == "U"
    Private cFilBr := ""
Endif
If Type("cFilEx") == "U"
    Private cFilEx := ""
Endif
Private aEECCamposEditaveis  := {}

Begin Sequence

   /* JPM - 26/09/05 - Substituído por função genérica
   cFilBr := EasyGParam("MV_AVG0023",,"")
   cFilBr := IF(ALLTRIM(cFilBr)=".","",cFilBr)
   cFilEx := EasyGParam("MV_AVG0024",,"")
   cFilEx := IF(ALLTRIM(cFilEx)=".","",cFilEx)

   If !Empty(cFilBr) .And. !Empty(cFilEx) .And.;
      (EEC->(FieldPos("EEC_INTERM")) # 0) .And. (EEC->(FieldPos("EEC_COND2")) # 0) .And.;
      (EEC->(FieldPos("EEC_DIAS2")) # 0) .And. (EEC->(FieldPos("EEC_INCO2")) # 0) .And.;
      (EEC->(FieldPos("EEC_PERC")) # 0)
      lIntermed := .t.
   EndIf
   */
   lIntermed := EECFlags("INTERMED")

   If (EEC->(FieldPos("EEC_UNIDAD")) # 0) .And. (EE9->(FieldPos("EE9_UNPES")) # 0) .And.;
      (EE9->(FieldPos("EE9_UNPRC")) # 0)
      lConvUnid :=.t.
   EndIf

   // ** Cria as works.
   Ae102CriaWork(.t.)

   aRet:={cNomArqIp , cNomArq1,    cNomArq2,;
          cNomArq3  , cNomArq4,    cNomArq5,;
          cNomArq6  , cNomArq7,    cNomArq8,;
          cNomArq82 , cNomArq9,    cArqCapInv,;
          cArqDetInv, cArq2DetInv, cArqAdiant,;
          cArqWkEY5 , cArq2WkEY5,  cArqWkEY6, ;
          cArqWkEY7, cArq2WkEY7,   cNomArqGrp,;
          cNomArqOpos, cArqCapOIC, cArqDetOIC,;
          cWorkArmazem, cArqNFRem, cArq2NFRem, cArq3NFRem, cNomArq1A, cNomArq1B, cNomArq1C}//RMD - 24/02/20

End Sequence

Return aRet

/*
Funcao      : ap102DelWorks().
Parametros  : aVars.
Retorno     : .t./.f.
Objetivos   : Apagar os arquivos temporários.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/05/2003 14:30.
Revisao     :
Obs.        :
*/
*---------------------------*
Function ae102DelWorks(aVars)
*---------------------------*
Local lRet:=.t.

Begin Sequence

   If ValType(aVars) <> "A"
      Break
      lRet:=.f.
   EndIf

   If(Select("WorkIp")  > 0, WorkIP->(E_EraseArq(aVars[1],aVars[6])),nil)
   If(Select("WorkDe")  > 0, WorkDe->(E_EraseArq(aVars[2], aVars[29], aVars[30], aVars[31])),nil)//RMD - 24/02/20
   If(Select("WorkAg")  > 0, WorkAg->(E_EraseArq(aVars[3])),nil)
   If(Select("WorkIn")  > 0, WorkIn->(E_EraseArq(aVars[4])),nil)
   If(Select("WorkEm")  > 0, WorkEm->(E_ERASEARQ(aVars[5])),nil)
   If(Select("WorkNF")  > 0, WorkNF->(E_EraseArq(aVars[7])),nil)
   If(Select("WorkNo")  > 0, WorkNo->(E_EraseArq(aVars[8])),nil)
   If(Select("WorkDoc") > 0, WorkDoc->(E_EraseArq(aVars[9],aVars[10])),nil)
   If(Select("WorkCalc")> 0, workcalc->(E_EraseArq(aVars[11])),nil)
   If(Select("WorkInv") > 0,WorkInv->(E_EraseArq(aVars[12])),nil)
   If(Select("WorkDetInv") > 0,WorkDetInv->(E_EraseArq(aVars[13],aVars[14])),nil)
   If(Select("WORKSLD_AD") > 0,WORKSLD_AD->(E_EraseArq(aVars[15])),nil)
   If(Select("WkEY5") > 0,WkEY5->(E_EraseArq(aVars[16], aVars[17])),nil)
   If(Select("WkEY6") > 0,WkEY6->(E_EraseArq(aVars[18])),nil)
   If(Select("WkEY7") > 0,WkEY7->(E_EraseArq(aVars[19], aVars[20])),nil)
   IF(Select("WorkGrp")  > 0, WorkGrp->(E_EraseArq(aVars[21])),)
   IF(Select("WorkOpos") > 0,WorkOpos->(E_EraseArq(aVars[22])),)
   If(Select("WKEXZ") > 0, WKEXZ->(E_EraseArq(aVars[23])),)
   If(Select("WKEY2") > 0, WKEY2->(E_EraseArq(aVars[24])),)
   If(Select("WkArm") > 0, WkArm->(E_EraseArq(aVars[25])),)
   If(Select("WK_NFRem") > 0, WK_NFRem->(E_EraseArq(aVars[26],aVars[27],aVars[28])),)

End Sequence

Return lRet

/*
Funcao      : ae102SetGrvEmb()
Parametros  : lGrv - .t. (Inclusao)/.f.(Alteracao).
Retorno     : .t.
Objetivos   : Declarar variaveis necessarias e executar a chamada da funcao ae100Grava.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/05/2003 14:35.
Revisao     :
Obs.        :
*/
*---------------------------*
Function ae102SetGrvEmb(lGrv, lAuto)
*---------------------------*
Local lRet:=.t.
Local nOldOrd//AAF 09/12/04 - Guarda a ordem do SX3.

Default lGrv := .t.

If(Type("aAgDeletados")     <> "A", aAgDeletados:={},)
If(Type("aInDeletados")     <> "A", aInDeletados:={},)
If(Type("aDeDeletados")     <> "A", aDeDeletados:={},)
If(Type("aNoDeletados")     <> "A", aNoDeletados:={},)
If(Type("aDocDeletados")    <> "A", aDocDeletados:={},)
If(Type("aDeletados")       <> "A", aDeletados:={},)
If(Type("aNfDeletados")     <> "A", aNfDeletados:={},)
If(Type("aMemoItem")        <> "A", aMemoItem := {{"EE9_DESC","EE9_VM_DES"}},)
If(Type("aNfRemDeletados")  <> "A", aNfRemDeletados:={},)
nOldOrd:= SX3->( IndexOrd() )
SX3->( dbSetOrder(2) )
Private  lIntermed    := .f.,;
         lIntCont     := EasyGParam("MV_EEC_ECO",,.F.),;
         lOkYS_PREEMB := SX3->(dbSeek("YS_PREEMB")) .and. SX3->(dbSeek("YS_INVEXP")),;//AAF - 09/12/04 - Procura os campos no SX3.
         lIntegra     := IsIntFat(),;
         lIntDraw     := EasyGParam("MV_EEC_EDC",,.F.),;
         lCommodity   := .f.,;
         lAltera      := .T.
SX3->( dbSetOrder(nOldOrd) )

//RMD - 21/02/17 - Checa se as variáveis não existem antes de declarar, para não perder conteúdo
//Private cFilBr := "", cFilEx := ""
If Type("cFilBr") == "U"
    Private cFilBr := ""
Endif
If Type("cFilEx") == "U"
    Private cFilEx := ""
Endif
Private cFilSYS:=xFilial("SYS")
Private lYSTPMODU   := SX3->(DBSEEK("YS_TPMODU")) .AND. SX3->(DBSEEK("YS_MOEDA"))
Private lContNfCompara := EasyGParam("MV_AVG0130",,.T.) // By JPP - 13/12/2006 - 16:00 - Habilitar a rotina de comparação de notas fiscais na integração com o Contábil

If Type("lDtEmba") = "U"
   Private lDtEmba := .f.
EndIf
If Type("cMarca") = "U"
   Private cMarca := GetMark()
EndIf
Private aPreCalcDeletados:={}

Private cOcorre := OC_EM
Private lReplicacao := .f.
Private aDadosOffShore := {}
Private lTratComis := EasyGParam("MV_AVG0077",,.F.)
Private lNRotinaLC := .f.
Private aDesvinculados := {}
Private lAltValPosEmb := EasyGParam("MV_AVG0081",,.f.)
Private lLibPes:= GetNewPar("MV_AVG0009",.F.)
Private lOkEE9_ATO  := SX3->(dbSeek("EE9_ATOCON"))
Private lExistEDD   := SX3->(dbSeek("EDD_FILIAL"))

Private lConsign := EECFlags("CONSIGNACAO")
If lConsign .And. !Type("cTipoProc") == "C"
   Private cTipoProc := PC_RG
EndIf

Private lBACKTO    := EasyGParam("MV_BACKTO",,.F.) .AND. ChkFile("EXK") ;
                      .AND. EE8->( FieldPos("EE8_INVPAG") > 0 ) .AND. EE9->( FieldPos("EE9_INVPAG") > 0  );
                      .And. (!lConsign .Or. cTipoProc $ PC_BN+PC_BC)
                      //RMD - 02/05/06 - Não inclui o tratamento de Back To Back no pedido regular quando estiver habilitada a rotina específica de Back to Back.

If lBACKTO
   Private cFilEXK := xFilial("EXK")
EndIf
Private aColsBtB   :={}
Private lReplicaDados := EasyGParam("MV_AVG0079",,.f.)
Private cArqMain  := "",;
        cArqMain2 := "",;
        cArqMain3 := "",;
        cArqMain4 := ""
Private lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)
Private lSelNotFat := EasyGParam("MV_AVG0067", .F., .F., xFilial("EE9"))
Private aCInvDeletados := {}
Private aDInvDeletados := {}
Private lConvUnid := .f.
Private lItFabric := EasyGParam("MV_AVG0138",,.F.)
If Type("lNFCompara") = "U"  // By JPP - 08/03/2007 - 14:30
   Private lNFCompara := .F.
EndIf
If Type("lMsgZeraSaldo") = "U"// ** By JPP - 14/03/2007 - Desabilita/Habilita mensagem(opção) para eliminar saldo de pedidos embarcados parcialmente.
   Private lMsgZeraSaldo := EasyGParam("MV_AVG0136",,.F.)
EndIf
If Type("aApropria") = "U"// ** By JPP - 21/03/2007 - 13:00
   Private aApropria := {}
EndIf
If !IsMemVar("lPedAdia")
    Private lPedAdia := .F.
EndIf
If !IsMemVar("lCliAdia")
    Private lCliAdia := .F.
EndIf

Default lAuto := .F.
Begin Sequence

   /* JPM - 26/09/05 - Substituído por função genérica
   cFilBr := EasyGParam("MV_AVG0023",,"")
   cFilBr := IF(ALLTRIM(cFilBr)=".","",cFilBr)
   cFilEx := EasyGParam("MV_AVG0024",,"")
   cFilEx := IF(ALLTRIM(cFilEx)=".","",cFilEx)

   If !Empty(cFilBr) .And. !Empty(cFilEx) .And.;
      (EEC->(FieldPos("EEC_INTERM")) # 0) .And. (EEC->(FieldPos("EEC_COND2")) # 0) .And.;
      (EEC->(FieldPos("EEC_DIAS2")) # 0) .And. (EEC->(FieldPos("EEC_INCO2")) # 0)  .And.;
      (EEC->(FieldPos("EEC_PERC")) # 0)

      lIntermed := .t.
   EndIf
   */
   lIntermed := EECFlags("INTERMED")

   /* JPM - 26/09/05 - Substituído por função genérica
   If EasyGParam("MV_AVG0029",,.F.) .And. EasyGParam("MV_AVG0034",.t.) .And. !Empty(EasyGParam("MV_AVG0034",,""))
      lCommodity := .t.
   EndIf
   */
   lCommodity := EECFlags("COMMODITY")

   If (EEC->(FieldPos("EEC_UNIDAD")) # 0) .And. (EE9->(FieldPos("EE9_UNPES")) # 0) .And.;
      (EE9->(FieldPos("EE9_UNPRC")) # 0)
      lConvUnid :=.t.
   EndIf

   // ** Gera o embarque.
   lOk := Ae100Grava(lGrv,.t.,lAuto)

   If !lOk
      Do While __lSX8
         RollBackSX8()
      EndDo
   Else
      While __lSX8
         ConfirmSX8()
      Enddo
   EndIf
End Sequence

Return lRet

/*
Funcao      : AE102LoadEmb(cEmbarque,cFil).
Parametros  : cEmbarque:= Embarque a ser Carregado.
              cFil:= Filial do Embarque a ser carregado.
Retorno     : Nenhum.
Objetivos   : Carregar Memória e Works com os dados do Embarque.
Autor       : Alessandro Alves Ferreira - AAF.
Data/Hora   : 08/03/05 15:47
Revisao     :
Obs.        :
*/
*------------------------------------*
Function AE102LoadEmb(cEmbarque, cFil)
*------------------------------------*
Local nInc
Local aOrd:= {}

Private cMarca := GetMark()

Private bTotal := {|x| x := if(x=="SOMA",1,-1),;
                      M->EEC_PESLIQ += x*If(lConvUnid,AvTransUnid(WorkIp->EE9_UNPES,M->EEC_UNIDAD,WorkIp->EE9_COD_I,WorkIp->EE9_PSLQTO,.F.),WorkIp->EE9_PSLQTO),;
                      M->EEC_PESBRU += x*If(lConvUnid,AvTransUnid(WorkIp->EE9_UNPES,M->EEC_UNIDAD,WorkIp->EE9_COD_I,WorkIp->EE9_PSBRTO,.F.),WorkIp->EE9_PSBRTO),;
                      M->EEC_TOTPED += x*WorkIP->EE9_PRCINC,;
                      M->EEC_TOTITE += x*1}

Private lOkEE9_Ato := SX3->(dbSeek("EE9_ATOCON"))
Private lIntDraw   := EasyGParam("MV_EEC_EDC",,.F.)
Private lDtEmba    := !Empty(EEC->EEC_DTEMBA)

If Type("aApropria") = "U" //ER - 26/10/2007
   Private aApropria := {}
EndIf

Default cFil := xFilial("EEC")


//ER - 25/08/05. Verificação se a rotina de Complemento de Embarque está instalada.

If EECFlags("COMPLE_EMB")
   aOrd := SaveOrd({"EEC","EXL"})
Else
   aOrd := SaveOrd("EEC")
EndIF

cFilOld := cFilAnt // Guarda Filial Anterior
cFilAnt := cFil    // Seta a filial.

EEC->(DbSetOrder(1))
EEC->(DbSeek(cFil+cEmbarque))

// Carrrega dados do embarque
If !IsBlind()//RMD - 12/03/18 - Não exibe a tela de for rotina automática
   MsAguarde({|| MsProcTxt(STR0081), lOK:=EECAE102()},STR0036) //"Preparando dados do embarque ..."###"Embarque"
Else
   lOK:=EECAE102()
EndIf

cFilAnt:= cFilOld//Retorna a Filial.

RestOrd(aOrd)

Return .t.

/*
Funcao      : AE102NrInvo()
Parametros  : Nenhum.
Retorno     : .T. ou .F.
Objetivos   : Não Permitir cadastrar um numero de invoice que já exista, se existir o indice com chave=EEC_FILIAL+EEC_NRINVO.
Autor       : Julio de Paula Paz
Data/Hora   : 08/06/2005 - 14:40
Revisao     :
Obs.        :
*/
Function AE102NrInvo()
Local lRet, aOrd := SaveOrd({"SIX","EEC"})
Begin Sequence
   If Empty(M->EEC_NRINVO)
      M->EEC_NRINVO:=M->EEC_PREEMB
   Endif
   EEC->(DbSetOrder(15)) //EEC_FILIAL+EEC_NRINVO
   If EEC->(DbSeek(xFilial("EEC")+M->EEC_NRINVO))
      If EEC->EEC_PREEMB == M->EEC_PREEMB .And. EEC->EEC_NRINVO == M->EEC_NRINVO  // É uma alteração.
         lRet := .T.
      Else
         If Type("lMultiOffShore") == "L" .And. lMultiOffShore .And. (EEC->EEC_NIOFFS <> M->EEC_NIOFFS)
            lRet := .T.
         Else
            lRet := .F.
            EasyHelp(STR0082+ENTER+STR0083+M->EEC_NRINVO+ENTER+STR0084+EEC->EEC_PREEMB ,STR0048) // "Não é permitido cadastrar o mesmo número de Invoice, em dois processos diferentes!" ### "Invoice: " ### "Cadastrada no embarque: "###"Atenção"
         EndIf
      EndIf
   Else
      lRet := .T.
   EndIf
End Sequence
RestOrd(aOrd,.T.)
Return lRet

/*
Funcao      : Ae102EdtDesp().
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Determinar o modo de edição dos Campos de Despesas.
Autor       : Julio de Paula Paz.
Data/Hora   : 05/07/2005 17:50.
Revisao     :
Obs.        :
*/
*---------------------------*
Function Ae102EdtDesp()
*---------------------------*
Local lRet := lAltera
Begin Sequence
   If !Empty(M->EEC_PEDDES)
      lRet := .f.
   EndIf
End Sequence
Return lRet

/*
Funcao      : Ae102NFC().
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Bloquear a exclusão de embarques que possuam nota fiscal complementar.
Autor       : Julio de Paula Paz.
Data/Hora   : 08/07/2005 17:50.
Revisao     :
Obs.        :
*/
*---------------------------*
Function Ae102NFC()
*---------------------------*
Local lRet := .f.
Begin Sequence
   If !Empty(EEC->EEC_PEDDES) .Or. !Empty(EEC->EEC_PEDEMB)
      lRet := .t.
      EasyHelp(STR0085+; // "Não é permitido Excluir Embarque que possua Nota Fiscal Complementar."
              STR0086,;  // " Estorne as Notas Fiscais Complementares!"
              STR0039)   // "Aviso"
   EndIf
End Sequence
Return lRet

/*
Funcao      : Ae102DataLC().
Parametros  : lCapa - define se a validação é chamada do campo da capa ou do item
Retorno     : .t./.f.
Objetivos   : validar as datas de embarque e vencimento da carta de crédito
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 05/08/2005 10:38.
Revisao     :
Obs.        :
*/
*-------------------------*
Function Ae102DataLC(lCapa)
*-------------------------*
Local lRet := .t.
Local cDtPrevEmb
Local cCampo, i
Local nParcs := 0
Default lCapa := .t.

cCampo := If(lCapa,"EEC_LC_NUM","EE9_LC_NUM")

Begin Sequence

   cDtPrevEmb := EasyGParam("MV_AVG0082",,"EEC_ETD")//Define o campo que será considerado como Dt. Previsão de Emb.
   If EEC->(FieldPos(cDtPrevEmb)) = 0 .Or. Posicione("SX3",2,cDtPrevEmb,"X3_TIPO") <> "D"
      cDtPrevEmb := "EEC_ETD"
   EndIf

   //ER - 04/12/2007 - Verifica se existe mais que 10 parcelas de cambio.
   SX3->(DbSetOrder(2))
   If SX3->(DbSeek("Y6_PERC_01"))
      While SX3->(!EOF()) .and. Left(SX3->X3_CAMPO,8) == "Y6_PERC_"
         nParcs ++
         SX3->(DbSkip())
      EndDo
   EndIf

   //Valida o prazo de embarque da L/C  //MFR 10/02/2020 OSSME-5267
   If !Empty(EEL->EEL_DT_EMB) .and. !lAE100Auto

      If dDataBase > EEL->EEL_DT_EMB .Or. (!Empty(M->EEC_DTEMBA) .And. M->EEC_DTEMBA > EEL->EEL_DT_EMB)
         //"A L/C "##" nao podera ser utilizada, pois o prazo de embarque da mesma e ate "##". Deseja continuar com esta L/C?"/"Aviso"
         If !MsgYesNo(STR0063 + Alltrim(EEL->EEL_LC_NUM) + STR0064 + DtoC(EEL->EEL_DT_EMB) + STR0068,STR0039)
            M->&(cCampo) := Space(AvSx3(cCampo,AV_TAMANHO))
            Break
         EndIf
      Else
         If Empty(M->EEC_DTEMBA) .And. !Empty(M->&(cDtPrevEmb)) .And. M->&(cDtPrevEmb) > EEL->EEL_DT_EMB 
            If !MsgYesNo(STR0065 + DtoC(M->&(cDtPrevEmb)) + STR0066 + Alltrim(EEL->EEL_LC_NUM) + ;
                      STR0067 + DtoC(EEL->EEL_DT_EMB) + STR0068,STR0039)
                      //"O embarque esta previsto para "##", porem o prazo de embarque da L/C "##;
                      //" e ate "##". Deseja continuar com esta L/C?"/"Aviso"
                M->&(cCampo) := Space(AvSx3(cCampo,AV_TAMANHO))
                Break
            EndIf
         EndIf  
      EndIf

   EndIf

   //Valida a data de vencimento da L/C, apenas se for do tipo "Stand By"
   If !Empty(EEL->EEL_DT_VEN) .And. EEL->EEL_TIPO == "2"
      nDias := 0
      SY6->(DbSetOrder(1))
      If SY6->(DbSeek(xFilial("SY6")+M->EEC_CONDPA))
         If SY6->Y6_TIPO = "3"
            //For i := 1 to 10
            For i := 1 to nParcs
               If &("SY6->Y6_DIAS_"+StrZero(i,2)) > nDias
                  nDias := &("SY6->Y6_DIAS_"+StrZero(i,2))
               EndIf
            Next
         Else
            nDias := SY6->Y6_DIAS_PA
         EndIf
      EndIf

      cMsg1 := STR0072 //"O limite de vencimento do cambio "
      cMsg2 := STR0073 //"e maior que a data de vencimento da L/C "

      //MFR 10/02/2020 OSSME-5267
      if !lAE100Auto
         If !Empty(M->EEC_DTEMBA)  
            If (M->EEC_DTEMBA + nDias) > EEL->EEL_DT_VEN
               If !MsgYesNo(cMsg1 + cMsg2 + AllTrim(EEL->EEL_LC_NUM) + STR0076,STR0074)//"Vinculacao nao permitida"
                  lRet := .f.
                  Break
               Endif
            EndIf   
         ElseIf !Empty(M->&(cDtPrevEmb))
            If (M->&(cDtPrevEmb) + nDias) > EEL->EEL_DT_VEN
               If !MsgYesNo(cMsg1 + STR0075 + cMsg2 + AllTrim(EEL->EEL_LC_NUM) + STR0076,STR0039)//"(de acordo com a previsao de embarque) "##". Deseja continuar?"
                  lRet := .f.
                  Break
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : AE102TelaNProc(lAutomatico)
Parametros  : lAutomatico = .t. - Gravação do pedido automatica. Exibir mensagens apenas no servidor.
                            .f. - Gravação do pedido não automatica. Solicitar novo codigo para o processo.
Retorno     :
Objetivos   : Exibir tela para solicitar o codigo do processo ou exibir mensagem no servidor.
Autor       : Julio de Paula Paz
Data/Hora   : 05/08/2005 13:35
Revisao     :
Obs.        :
*/
Function AE102TelaNProc(lAutomatico)
Local oDlg
Local lRet := .F.
Local cPictProc := AvSx3("EEC_PREEMB",AV_PICTURE)
Local cProc := Space(AvSx3("EEC_PREEMB",AV_TAMANHO)), oProc,;
      bOk   := {|| If(!Empty(cProc),(M->EEC_PREEMB:=cProc,lRet:= .t.,oDlg:End()),Nil)},;
      bCancel := {|| lRet := .F., oDlg:End()}

Begin Sequence
   If Type("lSched") == "L" .And. lSched
      EECMsg(STR0087+M->EEC_PREEMB+STR0088) // "Gravacao do Processo '" ###"' Cancelada. Ja existe um processo com este Codigo!"
      Break
   EndIf
   If lAutomatico
      ConOut(STR0087+M->EEC_PREEMB+STR0088) // "Gravacao do Processo '" ###"' Cancelada. Ja existe um processo com este Codigo!"
   Else
      Msginfo(STR0089+M->EEC_PREEMB+STR0090,STR0048) //  "Processo '" ### "' já Cadastrado. Digite um novo Código para o processo!" ### "Atenção"
      Define MsDialog oDlg Title STR0093 from 10,12 to 15,60 Of oMainWnd  // "Digite o Codigo do Processo"
         @ 18,07 Say STR0091 Pixel // "Processo"
         @ 18,40 Msget oProc Var cProc Size 100,10 Picture cPictProc Pixel
      Activate MsDialog oDlg On Init Enchoicebar(oDlg,bOk,bCancel) Centered
      If ! lRet
         MsgInfo(STR0092,STR0048) // "Gravação do Processo cancelada." ### "Atenção"
      EndIf
   EndIf
End Sequence

Return lRet


/*
Função      : EECPreco
Objetivo    : Retornar o número de casas decimais ou a mascara de edição, de acordo com o parametro passado,
              dos campos de preços do pedido e embarque.
Parametros  : cCmp = Nome do campo
              nOpc = Opção de retorno = 4 - Número de casas decimais.
                                        6 - Mascara de edição.
Retorno     : xRet
Autor       : Alexsander Martins dos Santos
Data e Hora : 18/11/2005 às 10:22.
*/

Function EECPreco(cCmp, nOpc)
Local nDecPrcUnit := EasyGParam("MV_AVG0109",, 0)
Local nDecPrcTot  := EasyGParam("MV_AVG0110",, 0)
//MFR 19/10/2020 OSSME-5231
//Local aOrd := SaveOrd({"SX3"})

Local aCmpPrc     := { { "EE8_PRECO" , nDecPrcUnit },;
                       { "EE8_PRECO2", nDecPrcUnit },;
                       { "EE8_PRECO3", nDecPrcUnit },;
                       { "EE8_PRECO4", nDecPrcUnit },;
                       { "EE8_PRECO5", nDecPrcUnit },;
                       { "EE8_PRECOI", nDecPrcUnit },;
                       { "EE8_PRCUN" , nDecPrcUnit },;
                       { "EE9_PRECO" , nDecPrcUnit },;
                       { "EE9_PRECO2", nDecPrcUnit },;
                       { "EE9_PRECO3", nDecPrcUnit },;
                       { "EE9_PRECO4", nDecPrcUnit },;
                       { "EE9_PRECO5", nDecPrcUnit },;
                       { "EE9_PRECOI", nDecPrcUnit },;
                       { "EE9_PRCUN" , nDecPrcUnit },;
                       { "EE8_PRCTOT", nDecPrcTot  },;
                       { "EE8_PRCINC", nDecPrcTot  },;
                       { "EE9_PRCTOT", nDecPrcTot  },;
                       { "EE9_PRCINC", nDecPrcTot  } }

Local nPos
Local xRet

Begin Sequence

  

   If (nPos := aScan(aCmpPrc, {|x| x[1] == cCmp})) = 0 .or. aCmpPrc[nPos][2] = 0
      xRet := AvSX3(cCmp, nOpc)
      Break
   EndIf

   Do Case

      Case nOpc = AV_DECIMAL

         xRet := aCmpPrc[nPos][2]

      Case nOpc = AV_PICTURE
         xRet := AvSX3(cCmp, nOpc)
         xRet := Left(xRet, At(".", xRet))+Replicate("9", aCmpPrc[nPos][2])

   End Case

End Sequence

// ** JPM - 24/02/06 - Alteração para não dar erro no programa
If nOpc = AV_DECIMAL .And. ValType(xRet) <> "N"
   xRet := 0
ElseIf nOpc = AV_PICTURE .And. ValType(xRet) <> "C"
   xRet := ""
EndIf
// **
//MFR 19/10/2020 OSSME-5231
//RestOrd(aOrd,.T.)

Return(xRet)
//TRP-24/07/08- Função responsável pela somatória dos adiantamentos, afim de retirá-los do total do pedido.
*-------------------------------*
Function AE102TotADiant(cEmb)
*-------------------------------*
Local nTot:= 0, aOrdAd := SaveOrd("EEQ")
Default cEmb := M->EEC_PREEMB
EEQ->(DbSetOrder(6))
EEQ->(DbGotop())
If EEQ->(DbSeek(xFilial("EEQ")+"E"+cEmb))
   Do While EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL == xFilial("EEQ") .AND. EEQ->EEQ_FASE == "E" .AND. EEQ->EEQ_PREEMB == cEmb
      If EEQ->EEQ_TIPO == "A"
         nTot+= EEQ->EEQ_VL
      Endif
      EEQ->(DbSkip())
   Enddo
Endif

RestOrd(aOrdAd)
Return nTot

/*
Funcao          : AE100VLDRESD
Parametros      : cInfo (Retorna o número digitado), cCampo (O campo verificado)
Retorno         : lRet
Objetivos       : Não permitir mais de um embarque com numeração de RE ou SD iguais.
Autor           : Diogo Felipe dos Santos
Data/Hora       : 17/06/2011
*/

*-----------------------------------*
//            MFR 27/04/2017 TE-5414 WCC-511226
//Function AE100VLDRESD(cInfo, cCampo)
Function AE100VLDRESD(cInfo, cCampo, cPreemb)
*-----------------------------------*
Local lRet := .T.,cUtil:=""
Local lValida:= EasyGParam("MV_EEC0003",,.F.) //TDF - 18/08/11 - Parâmetro que define se irá validar numeração do RE
//            MFR 27/04/2017 TE-5414 WCC-511226
Default cPreemb = ""

Begin Sequence

   If Empty(cInfo) .Or. !lValida
      Break
   EndIf

   #IFDEF TOP
         cQueryString := "SELECT DISTINCT EE9.EE9_PREEMB, "
         cQueryString += "EE9."+cCampo+", "
         cQueryString += "EE9.EE9_PREEMB "
         cQueryString += "FROM " +RetSQLName("EE9")+" EE9 "
         cQueryString += "WHERE "
         cQueryString += "EE9.D_E_L_E_T_ <> '*' AND "
//       MFR 27/04/2017 TE-5414 WCC-511226
//       cQueryString += "EE9.EE9_FILIAL = '"+xFilial("EE9")+"' AND  EE9."+cCampo+" = '"+cInfo+"' AND EE9.EE9_PREEMB <> '"+ cInfo)+"'"
         cQueryString += "EE9.EE9_FILIAL = '"+xFilial("EE9")+"' AND  EE9."+cCampo+" = '"+cInfo+"' AND EE9.EE9_PREEMB <> '"+ iif(!empty(cPreemb),cPreemb,cInfo)+"'"

         dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQueryString)), "QRY", .F., .T. )

         Do While QRY->(!Eof())
            cUtil+=QRY->EE9_PREEMB + ENTER
            QRY->(dbSkip())
            lRet := .F.
         EndDo
         QRY->(dbCloseArea())
   #ENDIF

   If !Empty(cUtil)
      Alert(STR0126+cUtil)
      Break
   EndIf

End Sequence
Return lRet

/*
Funcao      : AE100ItemEES
Parametros  : cPedido := Nro do Processo de Exportacao (EE7)
              cSequen := Nro da Sequencia (EE8)
Retorno     : aNotas
Objetivos   :
Autor       : Bruno Akyo Kubagawa
Data/Hora   : 16/12/2011
Revisao     :
Obs.        :
*/
Function AE100ItemEES(cPedido, cSequen)

Local aOrd := SaveOrd({"EES"})
Local aNotasAp := {}
Local aFiliais := Ap101RetFil()
Local i
//Local cPedFat, cFatIt
Local cNota := ""
Local cSerie := ""
Local cFilNf := ""
Local cProduto:= EE8->EE8_COD_I
Local nPos
Local cFatSeq := ""

Private lPreenche_NF

Begin Sequence

   /*// Identificacao do Pedido no SIGAFAT
   cPedFat := Posicione("EEM",1,xFilial("EEM")+cPedido,"EE7_PEDFAT")
   // Identificacao do Item do Pedido no SIGAFAT
   cSeqFat := Posicione("EE8",1,xFilial("EE8")+cPedido+cSequen,"EE8_FATIT")*/

   //cPedFat := AvKey(cPedFat,"EES_PEDIDO")
   //cSeqFat  := AvKey(cSeqFat,"EES_SEQUEN")
   cPedido := AvKey(cPedido,"EES_PEDIDO")
   cSequen  := AvKey(cSequen,"EES_SEQUEN")

   EES->(dbSetOrder(4)) // FILIAL+PEDIDO+SEQUEN
   For i := 1 To Len(aFiliais)
      EES->(dbSeek(aFiliais[i]+cPedido+cSequen))

      While EES->(!Eof() .And. EES_FILIAL == aFiliais[i] .And. EES_PEDIDO+EES_SEQUEN == cPedido+cSequen)
         SysRefresh()

         /*If lGrade .And. SD2->D2_GRADE $ cSim
            If AllTrim(SD2->D2_COD) <> AllTrim(cProduto)
               SD2->(DBSkip())
               Loop
            EndIf
         EndIf*/

         lPreenche_NF:= .F.
         If EasyEntryPoint("EECAE100")
            ExecBlock("EECAE100",.F.,.F.,"NUMERO_NOTA")
         EndIf

         If AVFLAGS("EEC_LOGIX")
            IF !Empty(EES->EES_PREEMB)
               If !lPreenche_NF
                  EES->(dbSkip())
                  Loop
               EndIf
            Endif
         EndIf
         /*IF !Empty(SD2->D2_PREEMB)
            If !lPreenche_NF
               SD2->(dbSkip())
               Loop
            EndIf
         Endif*/

         //If !Empty(cPedFat)
            cNota  := EES->EES_NRNF
            cSerie := EES->EES_SERIE
            cFilNf := EES->EES_FILIAL
            cFatSeq:= EES->EES_FATSEQ
         //Endif

         IF (nPos:=aScan(aNotasAp,{|x| x[1] == cNota .And. x[2] == cSerie .And. x[4] == cFilNf .And. x[7] == cFatSeq })) == 0
            aAdd(aNotasAp,{cNota,cSerie,0,cFilNf,cPedido, cSequen , cFatSeq })
            nPos := Len(aNotasAp)
         Endif

         aNotasAp[nPos][3] += EES->EES_QTDE
         aNotasAp[nPos][3] -= EES->EES_QTDDEV

         EES->(dbSkip())
      Enddo
   Next

   If Empty(aNotasAp) .and. lSelNotFat
      aNotasAp := {{"","",0,"","","",""}}
   EndIf

End Sequence

RestOrd(aOrd)

Return aClone(aNotasAp)
/*
Funcao      : ValidaIsencao
Parametros  :
Retorno     : lRet
Objetivos   : Validar a vinculação do processo à um processo de drawback isenção.
			    Se houver vinculação, a data de embarque/ data de avervação não poderá ser retirada.
Autor       : Wilsimar Fabricio da Silva - WFS
Data/Hora   : 02/12/2013
Revisao     :
Obs.        :
*/

Static Function ValidaIsencao()
Local lRet:= .T.
Local aOrd:= SaveOrd({"ED0", "EE9"})
Local cMsg:= ""

Begin Sequence

	EE9->(DBSetOrder(2)) //EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN
	EE9->(DBSeek(xFilial() + M->EEC_PREEMB))

	While EE9->(!Eof()) .And. EE9->(EE9_FILIAL + EE9_PREEMB) == M->(EEC_FILIAL + EEC_PREEMB)

		//Verifica se é ato de isenção
		If EE9->EE9_ISENTO == "S"
			cMsg := STR0143 + ENTER  //"Este processo está vinculado à um ato concessório modalidade isenção."
			cMSg += STR0144 + ENTER  //"Para prosseguir, faça a desvinculação do embarque de exportação do processo de drawback."

			//Antes da emissão do pedido de AC e o preenchimento do ato concessório do drawback, o campo ee9_atocon conterá o número do pedido
			ED0->(DBSetOrder(1)) //ED0_FILIAL+ED0_PD
			If !ED0->(DBSeek(xFilial() + AvKey(EE9->EE9_ATOCON, "ED0_PD")))
				ED0->(DBSetOrder(2)) //ED0_FILIAL+ED0_AC
				ED0->(DBSeek(xFilial() + AvKey(EE9->EE9_ATOCON, "ED0_AC")))
			EndIf

			cMsg += STR0145 + AllTrim(ED0->ED0_PD) + "."	//"Pedido de Drawback: "
			EasyHelp(cMsg, STR0035)
			lRet:= .F.
			Break
		EndIf
		EE9->(DBSkip())
	EndDo

End Sequence

RestOrd(aOrd, .T.)
Return lRet

// GFP - 28/10/2014 - Efetua calculo dos valores de comissão a deduzir
// NCF - 16/08/2019 - Modificada para apurar valor conforme o Alias (WorkAg,EEB)
//THTS - 06/09/2019 - Adicionado o parametro cTipoCom, passando qual comissao deseja saber o valor total
*----------------------------------------*
Function AE102CalcAg(cAlias,cChaveAlias,cTipoCom)
*----------------------------------------*
Local nValDeduz := 0
Local aOrd
Local bWhile
Local bPosic
Default cAlias := "WorkAg"
Default cChaveAlias := (cAlias)->&(IndexKey())
Default cTipoCom := "3"
bWhile := If( cAlias == "WorkAg" , {|| (cAlias)->(!eof()) }    , {|| (cAlias)->(!eof()) .And. Left( (cAlias)->(&(IndexKey())) , Len(cChaveAlias) ) == cChaveAlias  } )
bPosic := If( cAlias == "WorkAg" , {|| (cAlias)->(DbGoTop()) } , {|| (cAlias)->(DbSetOrder(1)) , (cAlias)->(DbSeek( cChaveAlias ))  } )

If Select(cAlias) > 0
   aOrd := SaveOrd(cAlias) //MCF - 01/07/2015
   Eval( bPosic )
   Do While Eval( bWhile )
      If (cAlias)->EEB_TIPCOM == cTipoCom
         nValDeduz += (cAlias)->EEB_TOTCOM
      EndIf
      (cAlias)->(DbSkip())
   EndDo
   RestOrd(aOrd,.T.)
EndIf 

Return nValDeduz

//MCF - 21/12/2014 - Retorna Loja do Consignatário
*-----------------------*
Function AE102ConLoja()
*-----------------------*
Local cRet := ""
SA1->(DBSETORDER(1))
SA1->(DBSEEK(XFILIAL("SA1")+M->EEC_CONSIG))

Do While SA1->(!Eof()) .And. SA1->A1_COD == M->EEC_CONSIG .And. SA1->A1_FILIAL == xFilial("SA1")
	If SA1->A1_TIPCLI $ ('2/4') .And. SA1->A1_MSBLQL # "1"
      cRet := SA1->A1_LOJA
      EXIT
	Endif
	SA1->(DbSkip())
Enddo

Return cRet
/*
Função     : NFRemFimEsp()
Objetivo   : Retonar se a rotina está com nova estrutura de controle de saldo
Parâmetros :
Retorno    :
Autor      : WFS
Data       : set/2016
Revisão    :
Observação : Remover esta função e suas chamadas quando a funcionalidade for publicada
             no release 12.
*/
Static Function NFRemFimEsp()
Local lRet:= .f.

   If FindFunction("NFRemNewStruct") .And. NFRemNewStruct()
      lRet:= .T.
   EndIf

Return lRet


/*
Função     : AE102ESSEYY()
Objetivo   : Vincular/Desvincular o embarque aos itens das notas de remessa
Parâmetros : cOp:'1' = Vincula / '2' = Desvincula
Retorno    :
Autor      : Nilson César
Data       : Nov/2017
Revisão    :
*/
Function AE102ESSEYY(cOp,cPreemb,cAliasTab)

Local lRet        := .F.
Local cQry        := ""
Local i
Local aRegEYY     := {}
Local aEstruNFREM := {}
Local cOldArea    := Select()
Local xRecEYY
Default cOp       := "0"
Default cPreemb   := ""
Default cAliasTab := "EES"

Begin Sequence

   If !AvFlags("FIM_ESPECIFICO_EXP")
      Break
   EndIf

   If cAliasTab == "WORKIP"
      aEstruNFREM := WK_NFRem->(DbStruct())
      nTamCpoRec  := aEstruNFREM[aScan( aEstruNFREM , {|x| x[1] == "EYY_RECNO"} )][3]
   EndIf

   If cAliasTab == "EES"
      If !ChkFile("EYY") .Or. cOp == "0" .Or. ( cOp == '1' .And. Empty(cPreemb) )
         Break
      EndIf
   Endif

   If Select("QryNfRem") > 0
      QryNfRem->(DbCloseArea())
   EndIf

   cQry := " SELECT *"
   cQry += " FROM " + RetSqlName("EYY") + " EYY"
   cQry += " WHERE EYY.EYY_FILIAL = '"+ xFilial("EYY")+"'"
   cQry += " AND EYY.EYY_PEDIDO = '"+ If(cAliasTab == "EES", EES->EES_PEDIDO, WorkIP->EE9_PEDIDO ) +"'"
   cQry += " AND EYY.EYY_SEQUEN = '"+ If(cAliasTab == "EES", EES->EES_SEQUEN, WorkIP->EE9_SEQUEN ) +"'"
   cQry += " AND EYY.EYY_NFSAI  = '"+ If(cAliasTab == "EES", EES->EES_NRNF  , WorkIP->EE9_NF     ) +"'"
   cQry += " AND EYY.EYY_SERSAI = '"+ If(cAliasTab == "EES", EES->EES_SERIE , WorkIP->EE9_SERIE  ) +"'"

   If EYY->(FieldPos("EYY_SQFNFS")) > 0
      If cAliasTab == "EES"
         cQry += " AND EYY.EYY_SQFNFS = '"+ EES->EES_FATSEQ +"'"
      ElseIf cAliasTab == "WORKIP" .And. WorkIp->(FieldPos("EE9_FATSEQ")) > 0
         cQry += " AND EYY.EYY_SQFNFS = '"+ WorkIP->EE9_FATSEQ +"'"
      EndIf
   EndIf
   //cQry += " AND EYY.EYY_PREEMB = '"+AvKey("","EYY_PREEMB")+"'"

   cQry += If(TcSrvType()<>"AS/400","AND EYY.D_E_L_E_T_ <> '*' "," EYY.@DELETED@ <> '*' ")
   cQry:=ChangeQuery(cQry)

   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QryNfRem", .F., .T.)

   If QryNfRem->(Eof()) .Or. QryNfRem->(Bof())
      QryNfRem->(DbCloseArea())
      Break
   Else
      QryNfRem->(DbGoTop())
      Do While QryNfRem->(!Eof())
         aAdd(aRegEYY,QryNfRem->R_E_C_N_O_)
         QryNfRem->(DbSkip())
      EndDo
   EndIf

   For i:=1 To Len(aRegEYY)
      EYY->(DbGoTo(aRegEYY[i]))

      If cAliasTab == "EES"

         EYY->(RecLock("EYY",.F.))
         If cOp == '1'
            EYY->EYY_PREEMB := cPreemb
         Else
            EYY->EYY_PREEMB := ""
         EndIf
         EYY->(MsUnlock())

         lRet := .T.

      ElseIf cAliasTab == "WORKIP"

         If Select("Wk_NfRem") > 0

            nOldOrd := Wk_NfRem->(IndexOrd())
            nOldRec := Wk_NfRem->(Recno())
            Wk_NfRem->(DbSetOrder(3))

            If cOp == "1"
               xRecEYY := If( Valtype(Wk_NfRem->EYY_RECNO) == "C" , Str(EYY->(Recno()),nTamCpoRec) , EYY->(Recno()) )
               If !Wk_NfRem->(DbSeek( xRecEYY )) //NCF - 23/11/2017 - Deve acompanhar o tamanho do campo EYY_RECNO
                  Wk_NfRem->(RecLock("Wk_NfRem", .T.))
               Else
                  Wk_NfRem->(RecLock("Wk_NfRem", .F.))
               EndIf

               AvReplace("EYY", "Wk_NfRem")

               WK_NFRem->EYY_PREEMB:= cPreemb
               WK_NFRem->EYY_NFSAI := WorkIp->EE9_NF
               WK_NFRem->EYY_SERSAI:= WorkIp->EE9_SERIE
               WK_NFRem->EYY_RE    := WorkIp->EE9_RE
               If WK_NFRem->(FieldPos("EE9_COD_I"))>0 .And. WorkIp->(FieldPos("EE9_COD_I")) > 0
                  WK_NFRem->EE9_COD_I := WorkIp->EE9_COD_I
               EndIf
               Wk_NfRem->EYY_RECNO := EYY->(RecNo())
               Wk_NfRem->(MsUnlock())
            ElseIf cOp == "2"
               xRecEYY := If( Valtype(Wk_NfRem->EYY_RECNO) == "C" , Str(EYY->(Recno()),nTamCpoRec) , EYY->(Recno()) )
               If Wk_NfRem->(DbSeek( xRecEYY )) //NCF - 23/11/2017 - Deve acompanhar o tamanho do campo EYY_RECNO
                  Wk_NfRem->(DbDelete())
               EndIf
            EndIf

            lRet := .T.
            Wk_NfRem->(DbSetOrder(nOldOrd))
            Wk_NfRem->(DbGoTo(nOldRec))
         EndIf

      EndIf
   Next i

   QryNfRem->(DbCloseArea())

End Sequence

DbSelectArea(cOldArea)

Return lRet


/*
Função     : AE102EESEK6()
Objetivo   : Vincular/Desvincular o embarque aos itens das notas de formação de lote de exportação
Parâmetros : cOp:'1' = Vincula / '2' = Desvincula
Retorno    :
Autor      : Nilson César
Data       : Nov/2017
Revisão    :
*/
Function AE102EESEK6(cOp,cPreemb,cAliasTab)

Local lRet         := .F.
Local cQry         := ""
Local i
Local aRegEK6      := {}
Local aEstruNFLote := {}
Local cOldArea     := Select()
Local xRecEK6
Default cOp        := "0"
Default cPreemb    := ""
Default cAliasTab  := "EES"

Begin Sequence

   If cAliasTab == "EES"
      If !ChkFile("EK6") .Or. cOp == "0" .Or. ( cOp == '1' .And. Empty(cPreemb) )
         Break
      EndIf
   Endif

   If Select("QryNFLote") > 0
      QryNFLote->(DbCloseArea())
   EndIf

   cQry := " SELECT *"
   cQry += " FROM " + RetSqlName("EK6") + " EK6"
   cQry += " WHERE EK6.EK6_FILIAL = '"+ xFilial("EK6")+"'"
   cQry += If(TcSrvType()<>"AS/400","AND EK6.D_E_L_E_T_ <> '*' "," EK6.@DELETED@ <> '*' ")
   cQry += " AND EK6.EK6_PDNFSD = '"+ If(cAliasTab == "EES", EES->EES_PEDIDO, WorkIP->EE9_PEDIDO ) +"'"
   cQry += " AND EK6.EK6_SQPDNF = '"+ If(cAliasTab == "EES", EES->EES_SEQUEN, WorkIP->EE9_SEQUEN ) +"'"
   cQry += " AND EK6.EK6_NFSD   = '"+ If(cAliasTab == "EES", EES->EES_NRNF  , WorkIP->EE9_NF     ) +"'"
   cQry += " AND EK6.EK6_SENFSD = '"+ If(cAliasTab == "EES", EES->EES_SERIE , WorkIP->EE9_SERIE  ) +"'"

   If cAliasTab == "EES"
      cQry += " AND EK6.EK6_SQFTSD = '"+ EES->EES_FATSEQ +"'"
      ElseIf cAliasTab == "WORKIP" .And. WorkIp->(FieldPos("EE9_FATSEQ")) > 0
      cQry += " AND EK6.EK6_SQFTSD = '"+ WorkIP->EE9_FATSEQ +"'"
   EndIf

   cQry:=ChangeQuery(cQry)

   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QryNFLote", .F., .T.)

   If QryNFLote->(Eof()) .Or. QryNFLote->(Bof())
      QryNFLote->(DbCloseArea())
      Break
   Else
      QryNFLote->(DbGoTop())
      Do While QryNFLote->(!Eof())
         aAdd(aRegEK6,QryNFLote->R_E_C_N_O_)
         QryNFLote->(DbSkip())
      EndDo
   EndIf

   For i:=1 To Len(aRegEK6)

      EK6->(DbGoTo(aRegEK6[i]))

      EK6->(RecLock("EK6",.F.))
      If cOp == '1'
         EK6->EK6_PREEMB := cPreemb
      Else
         EK6->EK6_PREEMB := ""
      EndIf
      EK6->(MsUnlock())

      lRet := .T.

   Next i

   QryNFLote->(DbCloseArea())

End Sequence

DbSelectArea(cOldArea)

Return lRet


Function AE102ADTVLD(lMensagem,cCondPg)
Local xRet
Local nPercEsp  := 0
Local nTotEsp   := 0
Local nPercAss  := 0
Local nTotAss   := 0
Local nDif      := 0
Local lcond     := .T.
Local nParc     := "01"
Local aParcADT  := {}
Local aParcPOS  := {}
Local aAdtAssd  := {}
Local cQry      := ""

Default lMensagem   := .F.
Default cCondPg     := M->EEC_CONDPA

// pega o valor total esperado e percentuais das parcelas de adiantamento
    SY6->(dbsetorder(1))
    SY6->( dbseek( xfilial("SY6")+cCondPg ) )
    While (lCond)
        if SY6->(fieldpos( ("Y6_DIAS_"+nParc) )) > 0
            if &( "SY6->Y6_DIAS_"+nParc ) < 0
                aAdd( aParcADT , { nParc , &("SY6->Y6_PERC_"+nParc) , &("SY6->Y6_DIAS_"+nParc) , ((M->EEC_TOTPED *  &("SY6->Y6_PERC_"+nParc))/100) })
                nTotEsp += ((M->EEC_TOTPED *  &("SY6->Y6_PERC_"+nParc))/100)
                nPercEsp += &("SY6->Y6_PERC_"+nParc)
            Else
                if &( "SY6->Y6_PERC_"+nParc ) > 0
                    aAdd( aParcPOS , { nParc , &("SY6->Y6_PERC_"+nParc) , &("SY6->Y6_DIAS_"+nParc) , ((M->EEC_TOTPED *  &("SY6->Y6_PERC_"+nParc))/100) })
                endif
            endif
            nParc := soma1(nParc)
        Else
            lCond := .F.
        endif
    EndDo
    nTotEsp  := Round(nTotEsp, 2)
    nPercEsp := Round(nPercEsp, 2)

// query para pegar os adiantamentos associados, valores e percentuais
    cQry += " SELECT R_E_C_N_O_ As RECEEQ, EEQ_VL FROM "+RetSQLName("EEQ")+"  "
    cQry += " WHERE EEQ_FILIAL = '" + xFilial("EEQ") + "' "
    cQry += "   AND EEQ_PREEMB = '"+M->EEC_PREEMB+"' AND EEQ_EVENT = '101' AND EEQ_TIPO ='A' "
    cQry += "   AND D_E_L_E_T_ <> '*' "

    if select("QEEQ") > 0
        QEEQ->(DbCloseArea())
    endif
    cQry:=ChangeQuery(cQry)
    dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QEEQ", .F., .T.)
    TcSetField("QEEQ","EEQ_VL","N", AvSx3("EEQ_VL", AV_TAMANHO), AvSx3("EEQ_VL", AV_DECIMAL) )

    QEEQ->(dbGoTop())
    While !QEEQ->(Eof())
        nTotAss  += QEEQ->EEQ_VL
        aAdd(aAdtAssd, QEEQ->RECEEQ)
        QEEQ->(dbskip())
    Enddo
    nPercAss := Round((nTotAss / M->EEC_TOTPED) * 100, 2)

// pega a diferença dos valores
    If nTotAss < nTotEsp
        nDif := nTotEsp - nTotAss
    EndIf

// lmensagem é para o campo virtual do embarque aba financeiro que vai mostrar os valores e um só campo
    If lMensagem
        xRet := "% esperado de adto: " + transform(nPercEsp,"999.99") + "% (" + M->EEC_MOEDA +" "+ alltrim(transform(nTotEsp,pesqpict("EEQ","EEQ_VL"))) + ") - % associado de adto: " + transform(nPercAss,"999.99") + "% (" + M->EEC_MOEDA +" "+ alltrim(transform(nTotAss,pesqpict("EEQ","EEQ_VL"))) + ")"
    Else
        xret := {nPercEsp, nTotEsp, nPercAss, nTotAss, nDif, aAdtAssd,aParcADT,aParcPOS}
    EndIf

Return xRet

/*
Funcao     : ValidUsoNF()
Parametros : cFilNf, cNota, cSerie - Verifica se a nota e serie ja esta sendo utilizada em outro proceso
Objetivos  : Verificar se o Pedido selecionado já possui NF e se sim, verificar se a NF já foi utilizada em outro processo
Autor      : THTS - Tiago Tudisco
Data       : 30/06/2022
*/
Static Function ValidUsoNF(cFilNf, cNota, cSerie)
Local lRet := .F.
Local cQuery
Local cQryTMP := GetNextAlias()

cQuery := "SELECT EEM_PREEMB "
cQuery += "FROM " + RetSQLName("EEM") + " "
cQuery += "WHERE EEM_FILIAL = '" + cFilNf   + "' "
cQuery += "  AND EEM_NRNF	 = '" + cNota     + "' "
cQuery += "  AND EEM_SERIE  = '" + cSerie    + "' "
cQuery += "  AND EEM_TIPOCA = '" + EEM_NF + "' " //'N'
cQuery += "  AND EEM_TIPONF = '" + EEM_SD + "' " //'1'
cQuery += "  AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQuery), cQryTMP, .T., .T.)

If (cQryTMP)->(!EOF()) .And. !Empty((cQryTMP)->(EEM_PREEMB)) .And. (cQryTMP)->(EEM_PREEMB) <> M->EEC_PREEMB
   lRet := .T.
EndIf

(cQryTMP)->(dbCloseArea())

Return lRet

*-----------------------------------------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAE102                                                                                        *
*-----------------------------------------------------------------------------------------------------------------*
