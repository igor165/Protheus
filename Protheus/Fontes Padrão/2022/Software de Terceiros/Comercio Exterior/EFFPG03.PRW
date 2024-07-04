#include "protheus.ch"
#include "msgraphi.ch"
#Include "Average.ch"
#Include "TOPCONN.CH" 
#include "effpg03.ch"

#Define EV_ENCERR   "180"
#Define EV_TRANSF   "190"
#Define EV_EMBARQUE "600"
#Define EV_LIQ_CAMB "630"
#Define EV_LIQ_FORC "660"

#Define EXP       "E"
#Define IMP       "I"
#Define ACC       "01"
#Define ACE       "02"

********************************************************************************************************
Function EFFPG03()
********************************************************************************************************

 Private cText       := ""                     ,;
         cValor      := "0"                    ,;
         nColorValor := NIL                    ,; 
         bClick      := NIL                    ,;
         cPicJuros   := AvSX3("EF3_TX_MOE",6)

   // cText       : Texto da Coluna
   // cValor      : Valor a ser exibido ( String ), já com a picture aplicada.
   // nColorValor : Cor do Valor no Formato RGB ( Opcional )
   // bClick      : Bloco de código a ser  executado no click do valor  ( Opcional )

Return EFFPG03Proc()


********************************************************************************************************
Static Function EFFPG03Proc()
********************************************************************************************************

 Local aRetPanel := {}              ,;
       nIndicad1 := 0               ,;
       nIndicad2 := 0               ,;
       nIndicad3 := 0               ,;
       nIndicad4 := 0               ,;
       nIndicad5 := 0               ,;
       cOldChEXP := ""              ,;
       cOldChIMP := ""

 Private cAliasEF1  := ""              ,;
         cFilEF1    := xFilial("EF1")  ,;
         cFilEF2    := xFilial("EF2")  ,;
         cFilEF3    := xFilial("EF3")  ,;
         nConRSEXP  := 0               ,;
         nConRSIMP  := 0

 Private dDtIni, dDtFim
 
   If Empty(mv_par01)
      If Empty(mv_par02)
         dDtIni := dDataBase - 180
      EndIf
   Else
      dDtIni := CToD("01/" + mv_par01)
      If Empty(mv_par02)
         dDtFim := dDtIni + 180
      EndIf
   EndIf

   If Empty(mv_par02)
      If Empty(mv_par01)
         dDtFim := dDataBase
      EndIf
   Else
      dDtFim := CToD("01/" + mv_par02)
      If Empty(mv_par01)
         dDtIni := dDtFim - 180
      EndIf
   EndIf

   EF2->( DBSetOrder(2) )
   EF3->( DBSetOrder(1) )

   #IFDEF TOP
      EFFPG03Qry()
      cAliasEF1 := "TRB"
      TRB->( DBGoTop() )
      lTop := .T.
   #ELSE
      cAliasEF1 := "EF1"
      EF1->( DBSetOrder(1) )
      EF1->( DBSeek(cFilEF1) )
   #ENDIF

   Do While (cAliasEF1)->( !EoF()  .And.  EF1_FILIAL == cFilEF1 )

      #IFDEF TOP
         If Empty((cAliasEF1)->EF1_DT_JUR)
            (cAliasEF1)->( DBSkip() )
            Loop
         EndIf
         If !Empty((cAliasEF1)->EF1_DT_ENC)  .And.  !Empty(dDtIni)
            If (cAliasEF1)->EF1_DT_ENC < dDtIni
               (cAliasEF1)->( DBSkip() )
               Loop
            EndIf
         EndIf
         If !Empty(dDtFim)
            If (cAliasEF1)->EF1_DT_CON > dDtFim
               (cAliasEF1)->( DBSkip() )
               Loop
            EndIf
         EndIf
      #ENDIF

      nIndicad1 := EFFPG03TxE(nIndicad1)
      nIndicad2 := EFFPG03TxI(nIndicad2)
      nIndicad3 := EFFPG03QtE(nIndicad3,@cOldChEXP)
      nIndicad4 := EFFPG03QtI(nIndicad4,@cOldChIMP)
      nIndicad5 := EFFPG03InE(nIndicad5)
      (cAliasEF1)->( DBSkip() )

   EndDo

   nIndicad1 := EFFPG03Tra(nIndicad1,EXP)
   nIndicad2 := EFFPG03Tra(nIndicad2,IMP)

   (cAliasEF1)->( DBCloseArea() )

   AAdd( aRetPanel, EFFPG03_01(nIndicad1) )
   AAdd( aRetPanel, EFFPG03_02(nIndicad2) )
   AAdd( aRetPanel, EFFPG03_03(nIndicad3) )
   AAdd( aRetPanel, EFFPG03_04(nIndicad4) )
   AAdd( aRetPanel, EFFPG03_05(nIndicad5) )

Return aRetPanel


********************************************************************************************************
Static Function EFFPG03Qry()
********************************************************************************************************

 Local cQuery := ""  ,;
       cFrom  := ""  ,;
       cWhere := ""

   cQuery := " SELECT " ;
             +"  EF1.EF1_FILIAL, EF1.EF1_TPMODU, EF1.EF1_CONTRA, EF1.EF1_BAN_FI "  ;
             +", EF1.EF1_PRACA , EF1.EF1_SEQCNT, EF1.EF1_CAMTRA, EF1.EF1_DT_JUR "  ;
             +", EF1.EF1_DT_VEN, EF1.EF1_DT_ENC, EF1.EF1_TP_FIN, EF1.EF1_VL_MOE "  ;
             +", EF1.EF1_SLD_PM, EF1.EF1_MOEDA , EF1.EF1_DT_CON, EF1.EF1_PARCPR "  ;
             +", EF1.EF1_PERIPR, EF1.EF1_TPPEPR "                                  ;

   cFrom := "FROM "+RetSqlName("EF1")+" EF1 "

   cWhere := "WHERE EF1.EF1_FILIAL='"+cFilEF1+"' "+IIF(TcSrvType()<>"AS/400","AND EF1.D_E_L_E_T_ <> '*' ","")
   cWhere += "AND EF1.EF1_DT_JUR <> '' AND EF1.EF1_DT_JUR <> '        ' "

   If !Empty(dDtIni)
      cWhere += "AND ( EF1.EF1_DT_ENC = '        ' OR  EF1.EF1_DT_ENC >= '"+DToS(dDtIni)+"' ) "
   Else
      cWhere += "AND EF1.EF1_DT_ENC = '        ' "
   EndIf

   If !Empty(dDtFim)
      cWhere += "AND EF1.EF1_DT_CON <= '"+DToS(dDtFim)+"' "
   EndIf

   cQuery += cFrom+cWhere+" ORDER BY EF1_TPMODU, EF1_CONTRA, EF1_BAN_FI, EF1_PRACA, EF1_SEQCNT "
   cQuery := ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","EF1_DT_JUR","D")
   TcSetField("TRB","EF1_DT_VEN","D")
   TcSetField("TRB","EF1_DT_ENC","D")
   TcSetField("TRB","EF1_DT_CON","D")
   DBSelectArea("TRB")

Return


********************************************************************************************************
Static Function EFFPG03TxE(nTaxa)
********************************************************************************************************

 Local cChave     := (cAliasEF1)->( EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA )  ,;
       cChaveEF2a := ""                                                           ,;
       cChaveEF2b := ""                                                           ,;
       nRecnoEF3  := 0                                                            ,;
       nDiasACC   := 0                                                            ,;
       nDiasACE   := 0                                                            ,;
       nDiasJur   := 0                                                            ,;
       nTxMedACC  := 0                                                            ,;
       nTxMedACE  := 0                                                            ,;
       nTxMedInv  := 0                                                            ,;
       nTxMedCon  := 0                                                            ,;
       dDtMin     := CToD("  /  /  ")                                             ,;
       dDtIniJur  := CToD("  /  /  ")                                             ,;
       dDtFimJur  := CToD("  /  /  ")                                             ,;
       dDtIniACE  := CToD("  /  /  ")                                             ,;
       dDtFimACE  := CToD("  /  /  ")                                             ,;
       nVlConRS   := 0                                                            ,;
       nPeriodic  := 0                                                            ,;
       lCalculou  := .F.                                                          ,;
       lTemLiq    := .F.                                                          ,;
       ni         := 1
 
 Private aPerInv    := {}  ,;
         aPeriod    := {}  ,;
         nTaxaMedia := 0

   If EFFPG03Abt(EXP,cFilEF3+cChave,dDtIni)
      cChave += (cAliasEF1)->EF1_SEQCNT
      If (cAliasEF1)->EF1_CAMTRA $ cSim  // Com Parcelas de Pagamento
         nPeriodic := (cAliasEF1)->( IIF( EF1_TPPEPR=="2", EF1_PERIPR * 30, EF1_PERIPR ) )
         dDtFimJur := (cAliasEF1)->EF1_DT_JUR + nPeriodic - 1
         dDtIniJur := (cAliasEF1)->EF1_DT_JUR + 1  // Não calcula juros sobre primeiro dia
         For ni := 1  to  (cAliasEF1)->EF1_PARCPR
            nDiasJur  += (dDtFimJur-dDtIniJur+1)
            nTxMedCon += ((dDtFimJur-dDtIniJur+1)*EFFPG03Jur(dDtIniJur,dDtFimJur,cFilEF2+cChave,Space(AvSX3("EF3_FILORI",3)+AvSX3("EF3_INVOIC",3)+AvSX3("EF3_PARC",3)),(cAliasEF1)->EF1_TP_FIN))
            dDtFimJur += nPeriodic
         Next ni
         dDtFimJur -= nPeriodic  // Desfaz a última incrementação que ocorre dentro do laço acima
         nTxMedCon := nTxMedCon / nDiasJur
      Else
         //Chamar rotina para cada invoice, saldo ACC e saldo ACE.
         EF3->( DBSeek(cFilEF3+cChave+EV_EMBARQUE) )
         Do While EF3->( !EoF()  .And.  EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE == cFilEF3+cChave+EV_EMBARQUE )
            lTemLiq   := .F.
            lCalculou := .F.
            nDiasACC  := 0
            nDiasACE  := 0
            nTxMedACC := 0
            nTxMedACE := 0
            nTxMedInv := 0
            nRecNoEF3 := EF3->( RecNo() )
            dDtIniJur := (cAliasEF1)->EF1_DT_JUR
            dDtFimJur := EF3->EF3_DT_EVE
            dDtIniACE := EF3->EF3_DT_EVE+1
            nDiasACC  := (dDtFimJur-dDtIniJur+1)
            If EF3->( DBSeek(cFilEF3+cChave+EV_LIQ_CAMB+EF3_PARC+EF3_INVOIC) )  ;
               .Or.  EF3->( DBSeek(cFilEF3+cChave+EV_LIQ_FORC+EF3_PARC+EF3_INVOIC) )
               lTemLiq := .T.
            EndIf
            If lTemLiq
               dDtFimACE := EF3->EF3_DT_EVE
            Else
               dDtFimACE := dDtFim
               If (cAliasEF1)->( !Empty(EF1_DT_VEN)  .And.  EF1_DT_VEN < dDtFimACE )
                  dDtFimACE := (cAliasEF1)->EF1_DT_VEN
               EndIf
               If (cAliasEF1)->( !Empty(EF1_DT_ENC)  .And.  EF1_DT_ENC < dDtFimACE )
                  dDtFimACE := (cAliasEF1)->EF1_DT_ENC
               EndIf
            EndIf
            nDiasACE  := (dDtFimACE-dDtIniACE+1)
            EF3->( DBGoTo(nRecNoEF3) )
            If (cAliasEF1)->EF1_TP_FIN == ACC
               cChaveEF2a := cFilEF2+cChave+EF3->EF3_FILORI+EF3->EF3_INVOIC+EF3->EF3_PARC+ACE
               cChaveEF2b := cFilEF2+cChave+Space(Len(EF3->EF3_FILORI+EF3->EF3_INVOIC+EF3->EF3_PARC))+ACE
               If EF2->( DBSeek(cChaveEF2a)  .Or.  DBSeek(cChaveEF2b) )
                  dDtMin := EF2->EF2_DT_FIM
                  Do While EF2->( !EoF()  .And.  EF2_FILIAL+EF2_TPMODU+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA+EF2_SEQCNT+EF2_FILORI+EF2_INVOIC+EF2_PARC+EF2_TP_FIN $ cChaveEF2a+"///"+cChaveEF2b  )
                     If EF2->EF2_DT_INI < dDtMin
                        dDtMin := EF2->EF2_DT_INI
                     EndIf
                     EF2->( DBSkip() )
                  EndDo
                  If dDtMin > dDtIniACE
                     nTxMedACE := ((dDtMin-1-dDtIniACE+1)*EFFPG03Jur(dDtIniACE,dDtMin-1 ,cFilEF2+cChave,EF3->( EF3_FILORI+EF3_INVOIC+EF3_PARC ),ACC) +;
                                  (dDtFimACE-dDtMin+1)   *EFFPG03Jur(dDtMin   ,dDtFimACE,cFilEF2+cChave,EF3->( EF3_FILORI+EF3_INVOIC+EF3_PARC ),ACE)) ;
                                  / nDiasACE
                  Else
                     nTxMedACE := EFFPG03Jur(dDtIniACE,dDtFimACE,cFilEF2+cChave,EF3->( EF3_FILORI+EF3_INVOIC+EF3_PARC ),ACE)
                  EndIf
               ElseIf lTemLiq
                  nTxMedInv := EFFPG03Jur(dDtIniJur,dDtFimACE,cFilEF2+cChave,EF3->( EF3_FILORI+EF3_INVOIC+EF3_PARC ),ACC)
                  lCalculou := .T.
               Else
                  nTxMedACE := EFFPG03Jur(dDtIniACE,dDtFimACE,cFilEF2+cChave,EF3->( EF3_FILORI+EF3_INVOIC+EF3_PARC ),ACC)
               EndIf
            Else
               nTxMedACE := EFFPG03Jur(dDtIniACE,dDtFimACE,cFilEF2+cChave,EF3->( EF3_FILORI+EF3_INVOIC+EF3_PARC ),(cAliasEF1)->EF1_TP_FIN)
            EndIf
            If !lCalculou
               nTxMedACC := EFFPG03Jur(dDtIniJur,dDtFimJur,cFilEF2+cChave,EF3->( EF3_FILORI+EF3_INVOIC+EF3_PARC ),(cAliasEF1)->EF1_TP_FIN)
               nTxMedInv := ( ( nTxMedACC*nDiasACC ) + ( nTxMedACE*nDiasACE ) ) / ( nDiasACC+nDiasACE )
            EndIf
            nTxMedCon += ( nTxMedInv * EF3->EF3_VL_MOE ) / (cAliasEF1)->EF1_VL_MOE
            EF3->( DBSkip() )
         EndDo

         dDtIniJur := (cAliasEF1)->EF1_DT_JUR
         dDtFimJur := dDtFim
         If (cAliasEF1)->( !Empty(EF1_DT_VEN)  .And.  EF1_DT_VEN < dDtFimJur )
            dDtFimJur := (cAliasEF1)->EF1_DT_VEN
         EndIf
         If (cAliasEF1)->( !Empty(EF1_DT_ENC)  .And.  EF1_DT_ENC < dDtFimJur )
            dDtFimJur := (cAliasEF1)->EF1_DT_ENC
         EndIf
         nTxMedCon += ( EFFPG03Jur(dDtIniJur,dDtFimJur,cFilEF2+cChave,Space(Len(EF3->( EF3_FILORI+EF3_INVOIC+EF3_PARC ))),(cAliasEF1)->EF1_TP_FIN) ;
                        * (cAliasEF1)->EF1_SLD_PM ) / (cAliasEF1)->EF1_VL_MOE
      EndIf
      nVlConRS   := (cAliasEF1)->EF1_VL_MOE * BuscaTaxa((cAliasEF1)->EF1_MOEDA,dDtFimJur,,.F.,.T.)
      nConRSEXP  += nVlConRS
      nTaxa      += nTxMedCon * nVlConRS
   EndIf

Return nTaxa


********************************************************************************************************
Static Function EFFPG03TxI(nTaxa)
********************************************************************************************************

 Local cChave    := (cAliasEF1)->( EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA )  ,;
       nDiasJur  := 0                                                            ,;
       nTxMedCon := 0                                                            ,;
       dDtIniJur := CToD("  /  /  ")                                             ,;
       dDtFimJur := CToD("  /  /  ")                                             ,;
       nVlConRS  := 0                                                            ,;
       nPeriodic := 0                                                            ,;
       ni        := 1

 Private aPerInv    := {}  ,;
         aPeriod    := {}  ,;
         nTaxaMedia := 0

   If EFFPG03Abt(IMP,cFilEF3+cChave,dDtIni)
      cChave += (cAliasEF1)->EF1_SEQCNT
      nPeriodic := (cAliasEF1)->( IIF( EF1_TPPEPR=="2", EF1_PERIPR * 30, EF1_PERIPR ) )
      dDtFimJur := (cAliasEF1)->EF1_DT_JUR + nPeriodic - 1
      dDtIniJur := (cAliasEF1)->EF1_DT_JUR + 1  // Não calcula juros sobre primeiro dia
      For ni := 1  to  (cAliasEF1)->EF1_PARCPR
         nDiasJur  += (dDtFimJur-dDtIniJur+1)
         nTxMedCon += ((dDtFimJur-dDtIniJur+1)*EFFPG03Jur(dDtIniJur,dDtFimJur,cFilEF2+cChave,Space(AvSX3("EF3_FILORI",3)+AvSX3("EF3_INVOIC",3)+AvSX3("EF3_PARC",3)),(cAliasEF1)->EF1_TP_FIN))
         dDtFimJur += nPeriodic
      Next ni
      dDtFimJur -= nPeriodic
      nTxMedCon := nTxMedCon / nDiasJur
      nVlConRS  := (cAliasEF1)->EF1_VL_MOE * BuscaTaxa((cAliasEF1)->EF1_MOEDA,dDtFimJur,,.F.,.T.)
      nConRSIMP += nVlConRS
      nTaxa     += nTxMedCon * nVlConRS
   EndIf

Return nTaxa


********************************************************************************************************
Static Function EFFPG03QtE(nQuantidade,cOldChave)
********************************************************************************************************

 Local cChave := cFilEF3+(cAliasEF1)->( EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA )
 
   If cChave != cOldChave
      If EFFPG03Abt(EXP,cChave,dDtFim)
         nQuantidade += 1
         cOldChave   := cChave
      EndIf
   EndIf

Return nQuantidade


********************************************************************************************************
Static Function EFFPG03QtI(nQuantidade,cOldChave)
********************************************************************************************************

 Local cChave := cFilEF3+(cAliasEF1)->( EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA )
 
   If cChave != cOldChave
      If EFFPG03Abt(IMP,cChave,dDtFim)
         nQuantidade += 1
         cOldChave   := cChave
      EndIf
   EndIf

Return nQuantidade


********************************************************************************************************
Static Function EFFPG03InE(nQuantidade)
********************************************************************************************************

 Local cChave    := ""  ,;
       cInvoice  := ""  ,;
       nRecNoEF3 := 0
 
   If (cAliasEF1)->EF1_TPMODU == EXP
      cChave := cFilEF3+(cAliasEF1)->( EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT )
      EF3->( DBSeek(cChave+EV_EMBARQUE) )
      Do While EF3->( !EoF()  .And.  EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE == cChave+EV_EMBARQUE )
         nRecNoEF3 := EF3->( RecNo() )
         cInvoice := EF3->( EF3_PARC+EF3_INVOIC )
         If !EF3->( DBSeek(cChave+EV_LIQ_CAMB+cInvoice) )  .And.  !EF3->( DBSeek(cChave+EV_LIQ_FORC+cInvoice) )
            nQuantidade += 1
         EndIf
         EF3->( DBGoTo(nRecNoEF3) )
         EF3->( DBSkip() )
      EndDo
   EndIf

Return nQuantidade


********************************************************************************************************
Static Function EFFPG03Abt(cTpModu,cChave,dDtLim)
********************************************************************************************************

 Local lRet   := .F.               ,;
       dDtIni := CToD("  /  /  ")

   If (cAliasEF1)->EF1_CAMTRA $ cSim  .Or.  cTpModu == IMP  //"I"
      dDtIni := (cAliasEF1)->EF1_DT_JUR
   ElseIf cTpModu == EXP  //"E"
      dDtIni := (cAliasEF1)->EF1_DT_CON
   EndIf

   If (cAliasEF1)->( EF1_TPMODU == cTpModu  .And.  dDtIni <= dDtFim )  ;
      .And.  (cAliasEF1)->( Empty(EF1_DT_ENC)  .Or.  EF1_DT_ENC > dDtLim )   ;
      .And.  !EF3->( DBSeek(cChave+(cAliasEF1)->EF1_SEQCNT+EV_ENCERR) )      ;
      .And.  !EF3->( DBSeek(cChave+(cAliasEF1)->EF1_SEQCNT+EV_TRANSF) )

      lRet := .T.

   EndIf

Return lRet


********************************************************************************************************
Static Function EFFPG03Jur(dDtIni,dDtFim,cChave,cInvoice,cTpFin)
********************************************************************************************************

 Local cChaveEF2  := cChave+cInvoice+cTpFin  ,;
       lTemInv    := !Empty(cInvoice)        ,;
       nPos       := 0                       ,;
       ni         := 1                       ,;
       dDtIniAux  := CToD("  /  /  ")        ,;
       dDtFimAux  := CToD("  /  /  ")        ,;
       dDtMin     := CToD("  /  /  ")        ,;
       nCoef      := 0

   If EF2->( DBSeek(cChaveEF2) )
      Do While  EF2->( !EoF() .And.  EF2_FILIAL+EF2_TPMODU+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA+EF2_SEQCNT+EF2_FILORI+EF2_INVOIC+EF2_PARC+EF2_TP_FIN == cChaveEF2 )
         If EF2->( EF2_DT_INI > dDtFim  .Or.  EF2_DT_FIM < dDtIni )
            EF2->( DBSkip() )
            Loop
         EndIf
         If dDtIni < EF2->EF2_DT_INI
            dDtIniAux := EF2->EF2_DT_INI
         Else
            dDtIniAux := dDtIni
         EndIf
         If dDtFim > EF2->EF2_DT_FIM
            dDtFimAux := EF2->EF2_DT_FIM
         Else
            dDtFimAux := dDtFim
         EndIf
         If lTemInv
            AAdd(aPerInv,{EF2->EF2_TIPJUR,dDtIniAux,dDtFimAux,EF2->EF2_TX_FIX})
         Else
            AAdd(aPeriod,{EF2->EF2_TIPJUR,dDtIniAux,dDtFimAux,EF2->EF2_TX_FIX})
         EndIf
         EF2->( DBSkip() )
      EndDo
   EndIf

   If lTemInv
      EFFPG03Jur(dDtIni,dDtFim,cChave,Space(Len(cInvoice)),cTpFin)
   Else
      // Verifica se existem periodos sobrepostos com e sem Invoice específica
      For ni := 1  to  Len(aPerInv)
         nPos := AScan( aPeriod, { |x| aPerInv[ni][1] == x[1]  .And.  ( aPerInv[ni][2] <= x[3]  .Or.  aPerInv[ni][3] >= x[2] ) } )
         If nPos > 0
            If aPerInv[ni][2] <= aPeriod[nPos][3]            // Data Inicial Invoice menor que Data Final
               If aPerInv[ni][2]-1 < aPeriod[nPos][2]
                  ADel(aPeriod,nPos)
                  ASize(aPeriod,Len(aPeriod)-1)
               Else
                  aPeriod[nPos][3] := aPerInv[ni][2]-1
               EndIf
            ElseIf aPerInv[ni][3] >= aPeriod[nPos][2]
               If aPerInv[ni][3]+1 > aPeriod[nPos][3]
                  ADel(aPeriod,nPos)
                  ASize(aPeriod,Len(aPeriod)-1)
               Else
                  aPeriod[nPos][2] := aPerInv[ni][3]+1
               EndIf
            EndIf
         EndIf
      Next ni

      // Adiciona ao array de retorno a quantidade de dias e a taxa
      If Len(aPeriod) > 0 
         dDtMin := aPeriod[1][2]
      ElseIf Len(aPerInv) > 0 
         dDtMin := aPerInv[1][2]
      EndIf
      AEval( aPeriod, { |x| ( IIF( x[2]<dDtMin, dDtMin:=x[2],  ), ;
                              nCoef += (x[3]-x[2]+1) * x[4] ) } )
      AEval( aPerInv, { |x| ( IIF( x[2]<dDtMin, dDtMin:=x[2],  ), ;
                              nCoef += (x[3]-x[2]+1) * x[4] ) } )

      nTaxaMedia := nCoef / ( dDtFim-dDtMin+1 )
      aPerInv := {}
      aPeriod := {}
   EndIf

Return nTaxaMedia


********************************************************************************************************
Static Function EFFPG03Tra(nIndicador,cTpModu)
********************************************************************************************************

   If cTpModu == EXP  //"E"
      nIndicador := nIndicador / nConRSEXP
   ElseIf cTpModu == IMP  //"I"
      nIndicador := nIndicador / nConRSIMP
   EndIf

Return nIndicador


********************************************************************************************************
Static Function EFFPG03_01(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0001 //"Juros Médio Exportação"
   cValor      := "0"
   nColorValor := NIL
   bClick      := NIL

   cValor := Transform( nValor, cPicJuros )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador


********************************************************************************************************
Static Function EFFPG03_02(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0002 //"Juros Médio Importação"
   cValor      := "0"
   nColorValor := NIL
   bClick      := NIL

   cValor := Transform( nValor, cPicJuros )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador


********************************************************************************************************
Static Function EFFPG03_03(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0003 //"Contratos em aberto Exportação"
   cValor      := "0"
   nColorValor := NIL
   bClick      := NIL

   cValor := AllTrim( Str( nValor ) )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador


********************************************************************************************************
Static Function EFFPG03_04(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0004 //"Contratos em aberto Importação"
   cValor      := "0"
   nColorValor := NIL
   bClick      := NIL

   cValor := AllTrim( Str( nValor ) )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador


********************************************************************************************************
Static Function EFFPG03_05(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0005 //"Invoices financiadas em aberto Exportação"
   cValor      := "0"
   nColorValor := NIL
   bClick      := NIL

   cValor := AllTrim( Str( nValor ) )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador