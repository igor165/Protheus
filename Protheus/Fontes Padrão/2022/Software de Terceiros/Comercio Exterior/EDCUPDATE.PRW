//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EFFUPDATE()
//Autor.....: Pedro Baroni (PLB)
//Data......: 01 de Setembro de 2006        
//Sintaxe...: EDCUPDATE() - Padrao
//Uso.......: SIGAEDC
//Versao....: Protheus - 8.11 - Release 4
//------------------------------------------------------------------------------------//
#Include "EDCUPDATE.CH"

*--------------------------*
User Function EDCUPMENU()
*--------------------------*

EDCUPDATE("MENU")

RETURN .T.

*-----------------------------------------------------------------------------------*
Function EDCUPDATE(cChamada)
*-----------------------------------------------------------------------------------*
 Local lDicOk  := .T.  ,;
       lTabOk  := .T.  ,;
       ni      := 1    ,;
       cMsg    := ""   ,;
       aCampos := {}   ,;
       lGrava  := .T.

 Private lMenu := (cChamada # NIL  .And.  cChamada == "MENU")

   If lMenu
      lGrava := MsgYesNo(STR0006)  //"Confirma Atualizacao?"
   EndIf

   If lGrava 

      aCampos := { "ED0_RUD"    , "ED0_SEGURO" , ;
                   "ED1_PESO"   , "ED1_PRCUNI" , "ED1_UMNCM"  , "ED1_UMPROD" , ;
                   "ED2_COEFEC" , "ED2_PESO"   , "ED2_PRCUNI" , /*"ED2_QTDCAL" ,*/ "ED2_UMITEM" , ;
                   "ED4_QTDCAL"   }

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
         cMsg := STR0002+STR0003  //"Descricao do Erro - Dicionario de dados "
      EndIf
      If !lTabOk
         If !Empty(cMsg)
            cMsg += "e "
         Else
            cMsg += STR0002  //"Descricao do Erro - "
         EndIf
         cMsg += STR0004  //"Tabelas "
      EndIf
      cMsg += STR0005  //"incompletos(as) para esta atualizacao."

      If lDicOk  .And.  lTabOk
         If lMenu
            Processa({|| QBG_EXECUTA() },STR0007,,.T.)  //"Gravando Dados"
         ElseIf !lMenu
            QBG_EXECUTA()
         EndIf
      Else
         UpdEventLog( 65, { "EDCUPDATE", cMsg } )
      EndIf
      
   EndIf

Return .T.
*-----------------------------------------------------------------------------------*
Static Function QBG_EXECUTA()
*-----------------------------------------------------------------------------------*
Local cChavED0 := "" ,;
      cChavED1 := "" ,;
      cChavED2 := "" ,;
      cChavED4 := "" ,;
      nSumSec  := 0

   ED0->( DBSetOrder(1) )
   ED1->( DBSetOrder(1) )
   ED2->( DBSetOrder(1) )
   ED4->( DBSetOrder(1) )
   EE9->( DBSetOrder(2) )
   SB1->( DBSetOrder(1) )
   SYD->( DBSetOrder(1) )
   SW7->( DBSetOrder(4) )
   SW8->( DBSetOrder(4) )
     
   ED0->( DBGoTop() )
   
   If lMenu
      oDlgProc := GetWndDefault()
      ProcRegua(ED0->(EasyRecCount() ))
   Else
      UpdSet01(ED0->(EasyRecCount() ))
   EndIf

   Begin TransAction

      cChavED1 := "xFilial('ED1')+ED1->ED1_PD"
      cChavED2 := "xFilial('ED2')+ED2->ED2_PD"
      cChavED4 := "xFilial('ED4')+ED4->ED4_PD"

      Do While !ED0->( EOF() )
         If lMenu
            IncProc(STR0001+Alltrim(ED0->ED0_PD))  //"Pedido de DrawBack - "
         Else
            UpdInc01(STR0001+Alltrim(ED0->ED0_PD))  //"Pedido de DrawBack - "
         EndIf
   
         cChavED0 := xFilial("ED0")+ED0->ED0_PD

         RecLock("ED0",.F.)
   
         If Empty(ED0->ED0_RUD)
            ED0->ED0_RUD := "1"
         EndIf
       
         If ED1->( DBSeek(cChavED0) )
            Do While !ED1->( EoF() )  .And.  cChavED0 == &cChavED1
               RecLock("ED1",.F.)

               If Empty(ED1->ED1_PESO)
                  If ED0->ED0_MODAL == "1"   // Isenção
                     If EE9->( DBSeek(xFilial("EE9")+ED1->ED1_PREEMB+ED1->ED1_PEDIDO+ED1->ED1_SEQUEN) )
                        ED1->ED1_PESO := ED1->ED1_QTD * EE9->EE9_PSLQTO / EE9->EE9_SLDINI
                     EndIf
                  ElseIf ED0->ED0_MODAL == "2"   // Suspensão
                     If SB1->( DBSeek(xFilial("SB1")+ED1->ED1_PROD) )
                        ED1->ED1_PESO := ED1->ED1_QTD * SB1->B1_PESO
                     EndIf
                  EndIf
               EndIf               

               If Empty(ED1->ED1_PRCUNI)
                  ED1->ED1_PRCUNI := ED1->ED1_VAL_EM / ED1->ED1_QTD
               EndIf                         

               If Empty(ED1->ED1_UMNCM)  .And.  SYD->( DBSeek(xFilial("SYD")+ED1->ED1_NCM) )    
                  ED1->ED1_UMNCM := SYD->YD_UNID
               EndIf

               If Empty(ED1_UMPROD)  .And.  SB1->( DBSeek(xFilial("SB1")+ED1->ED1_PROD) )
                  ED1->ED1_UMPROD := SB1->B1_UM
               EndIf

               ED1->( MSUnLock() )
               ED1->( DBSkip() )
            EndDo
         EndIf

         If ED2->( DBSeek(cChavED0) )
            Do While !ED2->( EoF() )  .And.  cChavED0 == &cChavED2
               RecLock("ED2",.F.)
               
               If Empty(ED2->ED2_COEFEC)
                  ED2->ED2_COEFEC := ED2->ED2_QTD / ED2->ED2_QTDNCM
               EndIf
               
               If Empty(ED2->ED2_PESO)
                  If ED0->ED0_MODAL == "1"   // Isenção
                     If SW7->( DBSeek(xFilial("SW7")+ED2->ED2_HAWB+ED2->ED2_PO_NUM+ED2->ED2_POSICA+ED2->ED2_PGI_NUM) )
                        ED2->ED2_PESO := ED2->ED2_QTD * SW7->W7_PESO
                     EndIf
                  ElseIf ED0->ED0_MODAL == "2"   // Suspensão
                     If SB1->( DBSeek(xFilial("SB1")+ED2->ED2_ITEM) )
                        ED2->ED2_PESO := ED2->ED2_QTD * SB1->B1_PESO
                     EndIf
                  EndIf
               EndIf
               
               If Empty(ED2->ED2_PRCUNI)
                  ED2->ED2_PRCUNI := ED2_VALEMB / ED2_QTD
               EndIf
               
               //If Empty(ED2->ED2_QTDCAL)
               //   ED2->ED2_QTDCAL := ED2->ED2_QTD - ( ( Max(ED2->ED2_PERCPE - ED2->ED2_PERCAP,0) * ED2->ED2_QTD ) / 100 )
               //EndIf

               If Empty(ED2->ED2_UMITEM)  .And.  SB1->( DBSeek(xFilial("SB1")+ED2->ED2_ITEM) )
                  ED2->ED2_UMITEM := SB1->B1_UM
               EndIf

               nSumSec += ED2->ED2_SEGURO

               ED2->( MSUnLock() )
               ED2->( DBSkip() )
            EndDo
         EndIf

         If ED4->( DBSeek(cChavED0) )
            Do While !ED4->( EoF() )  .And.  cChavED0 == &cChavED4
               RecLock("ED4",.F.)

               If Empty(ED4->ED4_QTDCAL)
                  If ED2->( DBSeek(cChavED0) )
                     Do While !ED2->( EoF() )  .And.  cChavED0 == &cChavED2  .And.  ED2->ED2_SEQSIS == ED4->ED4_SEQSIS
                        ED4->ED4_QTDCAL += ED2->ED2_QTD - ( ( Max(ED2->ED2_PERCPE - ED2->ED2_PERCAP,0) * ED2->ED2_QTD ) / 100 )
                        //ED4->ED4_QTDCAL += ED2->ED2_QTDCAL
                        ED2->( DBSkip() )
                     EndDo
                  EndIf
               EndIf

               ED4->( MSUnLock() )
               ED4->( DBSkip() )
            EndDo
         EndIf

         If Empty(ED0->ED0_SEGURO)
            ED0->ED0_SEGURO := nSumSec
         EndIf

         ED0->( MSUnLock() )
         ED0->( DBSkip() )
         nSumSec := 0
      EndDo

   End TransAction

   ED0->( DBCommit() )
   ED1->( DBCommit() )
   ED2->( DBCommit() )
   ED4->( DBCommit() )

   If lMenu
      MsgInfo(STR0008)  //"Atualizacao Concluida com Sucesso"
   EndIf

Return .T.