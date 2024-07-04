//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EFFUPDATE()
//Autor.....: Pedro Baroni (PLB)
//Data......: 01 de Setembro de 2006        
//Sintaxe...: EFFUPDATE() - Padrao
//Uso.......: SIGAEFF
//Versao....: Protheus - 8.11 - Release 4
//------------------------------------------------------------------------------------//
#Include "EFFUPDATE.CH"

*--------------------------*
User Function EFFUPMENU()
*--------------------------*

EFFUPDATE("MENU")

RETURN .T.

*------------------------------------*
Function EFFUPDATE(cChamada)
*------------------------------------*
 Local lDicOk  := .T.  ,;
       lTabOk  := .T.  ,;
       ni      := 1    ,;
       cMsg    := ""   ,;
       aCampos := {}   ,;
       lGrava  := .T.

 Private lMenu := (cChamada # NIL .AND. cChamada == "MENU")

   If lMenu
      lGrava := MsgYesNo(STR0009)  //"Confirma Atualizacao?"
   EndIf

   If lGrava 

      aCampos := { "EEQ_TP_CON" , "EEQ_FORN"   , "EEQ_FOLOJA" , "EEQ_IMPORT" , "EEQ_IMLOJA" , ;
                   "EF1_CALCJR" , "EF1_JR_ANT" , "EF1_LIQPER" , "EF1_PGJURO" , "EF1_PREPAG" , "EF1_REAJIR" ,  ;
                   "EF1_SEQCNT" , "EF1_TPCAJR" , "EF1_TPCAPR" , "EF1_TPMODU" , "EF1_TPPEJR" , "EF1_TPPEPR" ,  ;
                   "EF2_BAN_FI" , "EF2_BONUS"  , "EF2_SEQCNT" , "EF2_TIPJUR" , "EF2_TPMODU" , ;
                   "EF3_BAN_FI" , "EF3_ORIGEM" , "EF3_SEQCNT" , "EF3_TPMODU" , ;
                   "EF4_BAN_FI" , "EF4_SEQCNT" , "EF4_TPMODU" , ;
                   "WB_EVENT"   , "WB_TIPOC"   , "WB_TP_CON"    }

      SX3->( DBSetOrder(2) )

      For ni := 1  to  Len(aCampos)
         If !SX3->( DBSeek(aCampos[ni]) )
            lDicOk := .F.
            Exit
         EndIf
      Next ni

      For ni := 1  to  Len(aCampos)
         If !( &(IIF(At("_",aCampos[ni])==3,"S","")+SubStr(aCampos[ni],1,At("_",aCampos[ni])-1)+"->( FieldPos('"+aCampos[ni]+"') )") > 0 )
            lTabOk := .F.
            Exit
         EndIf
      Next ni

      If !lDicOk
         cMsg := STR0005+STR0006  //"Descricao do Erro - Dicionario de dados "
      EndIf
      If !lTabOk
         If !Empty(cMsg)
            cMsg += "e "
         Else
            cMsg += STR0005  //"Descricao do Erro - "
         EndIf
         cMsg += STR0007  //"Tabelas "
      EndIf
      cMsg += STR0008  //"incompletos(as) para esta atualizacao."

      If lDicOk  .And.  lTabOk
         If lMenu
            Processa({|| QBG_EXECUTA() },STR0010,,.T.)  //"Gravando Dados"
         Else
            QBG_EXECUTA()
         EndIf
      ElseIf !lMenu
         UpdEventLog( 65, { "EFFUPDATE", cMsg } )
      EndIf
   
   EndIf

Return .T.

*-----------------------------------------------------------------------------------*
Static Function QBG_EXECUTA()
*-----------------------------------------------------------------------------------*
 Local cChavEF1 := "" ,;
       cChavEF2 := "" ,;
       cChavEF3 := "" ,;
       cChavEF4 := "" ,;
       lTpModu  := .F.

   If lMenu
      oDlgProc := GetWndDefault()
      ProcRegua(EF1->(EasyRecCount() ))
   Else
      UpdSet01(EF1->(EasyRecCount() ))
   EndIf

   EF1->( DBSetOrder(0) )
   EF1->( DBGoTop() )
   
   Begin TransAction
      cChavEF2 := "xFilial('EF2')+EF2->EF2_CONTRA"
      cChavEF3 := "xFilial('EF3')+EF3->EF3_CONTRA"
      cChavEF4 := "xFilial('EF4')+EF4->EF4_CONTRA"
      Do While !EF1->( EOF() )

         If lMenu
            IncProc(STR0001+Alltrim(EF1->EF1_CONTRA))  //"Contrato de Financiamento: "
         Else
            UpdInc01(STR0001+Alltrim(EF1->EF1_CONTRA))  //"Contrato de Financiamento: "
         EndIf
   
         If Empty(EF1->EF1_TPMODU)
            cChavEF1 := xFilial("EF1")+EF1->EF1_TPMODU+EF1->EF1_CONTRA
         Else
            cChavEF1 := xFilial("EF1")+EF1->EF1_CONTRA
            lTpModu  := .T.
         EndIf

         RecLock("EF1",.F.)
   
         If Empty(EF1->EF1_CALCJR)
            EF1->EF1_CALCJR := "1"
         EndIf
         If Empty(EF1->EF1_JR_ANT)
            EF1->EF1_JR_ANT := "2"
         EndIf
         If Empty(EF1->EF1_LIQPER)
            EF1->EF1_LIQPER := "2"
         EndIf
         If Empty(EF1->EF1_PGJURO)
            EF1->EF1_PGJURO := "1"
         EndIf
         If Empty(EF1->EF1_PREPAG)
            EF1->EF1_PREPAG := "1"
         EndIf
         If Empty(EF1->EF1_REAJIR)
            EF1->EF1_REAJIR := "2"
         EndIf
         If Empty(EF1->EF1_SEQCNT)
            EF1->EF1_SEQCNT := "00"
         EndIf
         If Empty(EF1->EF1_TPCAJR)
            EF1->EF1_TPCAJR := "1"
         EndIf
         If Empty(EF1->EF1_TPCAPR)
            EF1->EF1_TPCAPR := "1"
         EndIf
         If Empty(EF1->EF1_TPPEJR)
            EF1->EF1_TPPEJR := "1"
         EndIf
         If Empty(EF1->EF1_TPPEPR)
            EF1->EF1_TPPEPR := "1"
         EndIf

         If lTpModu
            EF2->( DBSetOrder(0) )
            EF3->( DBSetOrder(0) )
            EF4->( DBSetOrder(0) )
         Else
            EF2->( DBSetOrder(1) )
            EF3->( DBSetOrder(1) )
            EF4->( DBSetOrder(1) )
         EndIf

         EF2->( DBGoTop() )
         Do While IIF(lTpModu,!EF2->( EoF() ),EF2->( DBSeek(cChavEF1) ))
            If IIF(lTpModu,cChavEF1 == &cChavEF2,.T.)
               RecLock("EF2",.F.)
               If IIF(lTpModu,Empty(EF2->EF2_TPMODU) .Or. EF1->EF1_TPMODU == EF2->EF2_TPMODU,.T.)
                  If Empty(EF2->EF2_BAN_FI)
                     EF2->EF2_BAN_FI := EF1->EF1_BAN_FI
                  EndIf
                  If Empty(EF2->EF2_SEQCNT)
                     EF2->EF2_SEQCNT := "00"
                  EndIf
                  If Empty(EF2->EF2_BONUS)
                     EF2->EF2_BONUS := "2"
                  EndIf
                  If Empty(EF2->EF2_TIPJUR)
                     EF2->EF2_TIPJUR := "0"
                  EndIf
               EndIf
               If Empty(EF2->EF2_TPMODU)
                  EF2->EF2_TPMODU := "E"
               EndIf
               EF2->( MSUnLock() )
            EndIf
            EF2->( DBSkip() )
         EndDo

         EF3->( DBGoTop() )
         Do While IIF(lTpModu,!EF3->( EoF() ),EF3->( DBSeek(cChavEF1) ))
            If IIF(lTpModu,cChavEF1 == &cChavEF3,.T.)
               RecLock("EF3",.F.)
               If IIF(lTpModu,Empty(EF3->EF3_TPMODU) .Or. EF1->EF1_TPMODU == EF3->EF3_TPMODU,.T.)
                  If Empty(EF3->EF3_BAN_FI)
                     EF3->EF3_BAN_FI := EF1->EF1_BAN_FI
                  EndIf
                  If Empty(EF3->EF3_ORIGEM) .And. !Empty(EF3->EF3_PREEMB) .And. !Empty(EF3->EF3_INVOIC) .And. !Empty(EF3->EF3_PARC)
                     EF3->EF3_ORIGEM := "EEQ"
                  EndIf
                  If Empty(EF3->EF3_SEQCNT)
                     EF3->EF3_SEQCNT := "00"
                  EndIf
               EndIf
               If Empty(EF3->EF3_TPMODU)
                  EF3->EF3_TPMODU := "E"
               EndIf
               EF3->( MSUnLock() )
            EndIf
            EF3->( DBSkip() )
         EndDo

         EF4->( DBGoTop() )
         Do While IIF(lTpModu,!EF4->( EoF() ),EF4->( DBSeek(cChavEF1) ))
            If IIF(lTpModu,cChavEF1 == &cChavEF4,.T.)
               RecLock("EF4",.F.)
               If IIF(lTpModu,Empty(EF4->EF4_TPMODU) .Or. EF1->EF1_TPMODU == EF4->EF4_TPMODU,.T.)
                  If Empty(EF4->EF4_BAN_FI)
                     EF4->EF4_BAN_FI := EF1->EF1_BAN_FI
                  EndIf
                  If Empty(EF4->EF4_SEQCNT)
                     EF4->EF4_SEQCNT := "00"
                  EndIf
               EndIf
               If Empty(EF4->EF4_TPMODU)
                  EF4->EF4_TPMODU := "E"
               EndIf
               EF4->( MSUnLock() )
            EndIf
            EF4->( DBSkip() )
         EndDo

         If Empty(EF1->EF1_TPMODU)
            EF1->EF1_TPMODU := "E"
         EndIf

         EF1->( MSUnLock() )
         EF1->( DBSkip() )
         lTpModu := .F.
      EndDo
   End TransAction

   EF1->( DBCommit() )
   EF2->( DBCommit() )
   EF3->( DBCommit() )
   EF4->( DBCommit() )


   EEQ->( DBSetOrder(1) )
   EEC->( DBSetOrder(1) )
   EEQ->( DBGoTop() )
   
   If lMenu
      oDlgProc := GetWndDefault()
      ProcRegua(EEQ->(EasyRecCount() ))
   Else
      UpdSet01( EEQ->(EasyRecCount() ) )
   EndIf

   Begin TransAction
      Do While !EEQ->( EOF() )
         If lMenu
            IncProc(STR0002+STR0004+Alltrim(EEQ->EEQ_NRINVO))  //"Exportacao - Invoice: "
         Else
            UpdInc01(STR0002+STR0004+Alltrim(EEQ->EEQ_NRINVO))  //"Exportacao - Invoice: "
         EndIf
         RecLock("EEQ",.F.)
   
         If Empty(EEQ->EEQ_TP_CON)
            EEQ->EEQ_TP_CON := "1"
         EndIf

         If EEC->( DBSeek(xFilial("EEC")+EEQ->EEQ_PREEMB) )
            If Empty(EEQ->EEQ_FORN)
               EEQ->EEQ_FORN := EEC->EEC_FORN
            EndIf
            If Empty(EEQ->EEQ_FOLOJA)
               EEQ->EEQ_FOLOJA := EEC->EEC_FOLOJA
            EndIf
            If Empty(EEQ->EEQ_IMPORT)
               EEQ->EEQ_IMPORT := EEC->EEC_IMPORT
            EndIf
            If Empty(EEQ->EEQ_IMLOJA)
               EEQ->EEQ_IMLOJA := EEC->EEC_IMLOJA
            EndIf
         EndIf

         EEQ->( MSUnLock() )
         EEQ->( DBSkip() )
      EndDo
   End TransAction

   EEQ->( DBCommit() )


   SWB->( DBSetOrder(1) )
   SWB->( DBGoTop() )

   If lMenu
      oDlgProc := GetWndDefault()
      ProcRegua(SWB->(EasyRecCount() ))
   Else
      UpdSet01( SWB->(EasyRecCount() ) )
   EndIf

   Begin TransAction
      Do While !SWB->( EOF() )
         If lMenu
            IncProc(STR0003+STR0004+Alltrim(SWB->WB_INVOICE))  //"Importacao - Invoice: "
         Else
            UpdInc01(STR0003+STR0004+Alltrim(SWB->WB_INVOICE))  //"Importacao - Invoice: "
         EndIf
         RecLock("SWB",.F.)

         If Empty(SWB->WB_EVENT)
            If Left(SWB->WB_TIPOREG,1) == "1"  // Principal
               SWB->WB_EVENT := "101"

            ElseIf Left(SWB->WB_TIPOREG,1) == "A"  // Frete
               SWB->WB_EVENT := "102"

            ElseIf Left(SWB->WB_TIPOREG,1) == "B"  // Seguro
               SWB->WB_EVENT := "103"
            EndIf
         EndIf

         If Empty(SWB->WB_TIPOC)
            SWB->WB_TIPOC := "P"
         EndIf

         If Empty(SWB->WB_TP_CON)
            SWB->WB_TP_CON := "2"
         EndIf

         SWB->( MSUnLock() )
         SWB->( DBSkip() )
      EndDo
   End TransAction

   SWB->( DBCommit() )

   If lMenu
      MsgInfo(STR0011)  //"Atualizacao Concluida com Sucesso"
   EndIf

Return .T.