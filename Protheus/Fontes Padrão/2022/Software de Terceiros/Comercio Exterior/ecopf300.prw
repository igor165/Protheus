#INCLUDE "ECOPF300.ch"
#Include "Average.ch"
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ ECOPF300 ³ Autor ³ EMERSON DIB           ³ Data ³ 02.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Controle / Cancelamento da Contabilizacao  ACC/ACE         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


*-------------------*
Function ECOPF300()
*-------------------*
Local cAliasAnt:=ALIAS()

Private aRotina := MenuDef()
Private cCadastro := STR0003 //"Controle da Contabilização"
Private lTop      := .F., aTaxas := {}, cTotProc
Private nContECF  := 0, nContEF3 := 0, nContECH := 0, nContEEQ := 0, nContEET := 0, nContEES := 0
Private lContab   := .F.//, lEve100 := .F.
Private cFilEC1   := xFilial("EC1"), cFilEF3 := xFilial("EF3"), cFilECF := xFilial("ECF")
Private cFilEF1   := xFilial("EF1"), cFilEET := xFilial("EET"), cFilEEQ := xFilial("EEQ")
Private cFilEZC   := xFilial("EZC"), cFilEES := xFilial("EES"), cFilECG := xFilial("ECG")
//Private nNR_Cont  := EasyGParam("MV_NRCONT",,1) , lEndFim := .F. 
PRIVATE nNR_Cont := '0000'
Private lEndFim := .F.
Private lTemECFNew := .F., lTemECENew := .F., lTemEEQNew := .F., lTemEETNew := .F., lExiteEZC := .F., lTemEESNew := .F., lTemEF1PRA := .F.
Private cTPMODU   := ""
Private lTemTPMODU
private bTPMODUECF 
private bTPMODUECG
Private lAchouNR := .f. // Nick Menezes 21/02/2006
Private nEC1_REC   // NM - 22/02/2006
Private lECOFIM := .F.
// Nick - 12/09/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0 .AND. ECA->( FieldPos("ECA_SEQCNT") ) > 0 .AND.;
                     ECF->( FieldPos("ECF_SEQCNT") ) > 0 .AND. ECE->( FieldPos("ECE_SEQCNT") ) > 0
Private lExisteECE := EasyGParam("MV_ESTORNO", .F., .F.) //AAF 10/09/07
EC1->(DBSETORDER(2))
EC1->(DBGOTOP())
DO WHILE EC1->(!EOF())
   IF cFilEC1 = EC1->EC1_FILIAL // .AND. EC1->EC1_STATUS = ' ' Nick Problema encontrado com estorno
      nNRCONAU := EC1->EC1_NR_CON
      nNR_Cont := IF(VAL(nNRCONAU) >= VAL(nNR_Cont),nNRCONAU,nNR_Cont) 
   ENDIF
   EC1->(DBSKIP())
ENDDO
EC1->(DBSETORDER(1))


// Verifica a existencia de novos campos no SX3
SX3->(DbSetOrder(2))
lTemECFNew := SX3->(DbSeek("ECF_CONTRA")) .And. SX3->(DbSeek("ECF_TP_EVE"))
lTemEEQNew := SX3->(DbSeek("EEQ_NR_CON"))
lTemEETNew := SX3->(DbSeek("EET_NR_CON"))
lTemEESNew := SX3->(DbSeek("EES_NR_CON"))
lTemTPMODU := SX3->(DbSeek("ECG_TPMODU")) .AND. SX3->(DbSeek("ECF_TPMODU"))
lTemEF1PRA := SX3->(DbSeek("EF1_PRACA"))
SX3->(DbSetOrder(1)) 

If lTemTPMODU
   cTPMODU:='EXPORT'
   bTPMODUECF := {|| ECF->ECF_TPMODU = 'EXPORT' }
   bTPMODUECG := {|| ECG->ECG_TPMODU = 'EXPORT' }   
Else
   bTPMODUECF := {|| .T. }
   bTPMODUECG := {|| .T. }
EndIf

#IFDEF TOP
  IF (TcSrvType() != "AS/400") // Considerar qdo for AS/400 para que tenha o tratamento de Codbase
     lTop := .T.
  Endif
#ENDIF

EF3->(DbSetOrder(5))
ECF->(DbSetOrder(4))
EEQ->(DbSetOrder(8))
EES->(DbSetOrder(2))
EC1->(DbSetOrder(1))
ECH->(DbSetOrder(1))
ECG->(DbSetOrder(4))
EET->(DbSetOrder(2))

DbSelectArea("EC1")
EC1->(DbSetFilter({||(EC1->(!Eof()) .And. EC1->EC1_FILIAL = cFilEC1 .And. EC1->EC1_TPMODU = 'EXPORT') }, "(EC1->(!Eof()) .And. EC1->EC1_FILIAL = cFilEC1 .And. EC1->EC1_TPMODU = 'EXPORT')"))
//Alcir Alves - 26-04-05 - ponto de entrada para tratamentos de variaveis antes do mbrowse
If EasyEntryPoint("ECOPF300")
    ExecBlock("ECOPF300",.F.,.F.,"PRE_ROTINAS_MBROWSE")
Endif
//

mBrowse( 6, 1, 22, 75, "EC1")
DbSelectArea("EC1")
//Set Filter To

DBSELECTAREA(cAliasAnt)

EF3->(DbSetOrder(1))
ECF->(DbSetOrder(1))
EEQ->(DbSetOrder(1))
EES->(DbSetOrder(1))
EES->(DbSetOrder(1))
ECG->(DbSetOrder(1))
EET->(DbSetOrder(1))

Return .T.


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 01/02/07 - 15:34
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0001  ,"AxPesqui", 0 , 1},; //"Pesquisar"
                    { STR0002  ,"PF300CAN", 0 , 6} } //"Cancela"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("CPF300MNU")
	aRotAdic := ExecBlock("CPF300MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*-------------------*
Function PF300CAN()
*-------------------*
Local aFil := {cFilAnt}/*AvgSelectFil(.F.)*/, i    // NM - 22/02/2006

IF Val(EC1->EC1_NR_CON) # VAL(nNR_Cont)
   E_Msg(STR0004,1)  //"Só pode ser cancelado a última contabilização."
   Return .F.
ELSEIF EC1->EC1_STATUS = "E"
   E_Msg(STR0005,1)  //"Existe contabilização em aberto, cancelamento não autorizado."
   Return .F.
EndIf

/* AAF 20/02/09 - Contabilizar apenas filial corrente
IF LEN(aFil) > 1  // Nick 22/02/2006
   E_Msg(STR0027,1)  //"Esta operação não pode ser executada por usuarios com acesso a mais de uma Filial."
   Return .f.
Endif 
*/

If SimNao(STR0006,STR0007,,,,STR0007)#'S' //"Confirma cancelamento da contabilização ?"###"Questão ?"###"Questão ?"
   Return .F.
EndIf

lCancel := .f.
nEC1_REC := EC1->(RECNO())

// Nick Menezes - 21/02/2006 - Forçar para que todos fiquem com status com problemas até a finalizacao do estorno
// para o caso de algo der errado.
RECLOCK("EC1",.F.)
EC1->EC1_OK := "2"
EC1->(MSUNLOCK())

MsAguarde({||PF300ContaReg()},STR0008)  //"Aguarde... Apurando Dados."
cTotProc:= '2'

If lTemEEQNew
   cTotProc:= Str(Val(cTotProc) + 1,1,0)
EndIf

If lTemEETNew
   cTotProc:= Str(Val(cTotProc) + 1,1,0)
EndIf

If lTemEESNew
   cTotProc:= Str(Val(cTotProc) + 1,1,0)
EndIf
lEnd := .f.
If(EasyEntryPoint("ECOPF300"),Execblock("ECOPF300",.F.,.F.,"Cancela_Inicio"),)

// Conforme solicitacao do Alessandro Porta para a Gevisa - Nick - 31/07/2006
If lECOFIM
  Return .F.
Endif

EC1->(DBGOTO(nEC1_REC)) // NM 22/02/2006 para ter certeza de estar posicionado no registro correto
oProcess := MsNewProcess():New({|| PF300CANC() },STR0025,STR0012+"1 / "+cTotProc,.F.)
oProcess:Activate()

// Nick Menezes - 21/02/2006 - Certeza de estorno da ultma contabilizacao
ECF->(DbSetOrder(4))
EES->(DbSetOrder(2))
EEQ->(DbSetOrder(8))
ECG->(DbSetOrder(3))

lAchouNR := ECF->(DbSeek(xFilial("ECF")+cTPMODU+AVKEY(EC1->EC1_NR_CON, "ECF_NR_CON")))
IF ! lAchouNR
   lAchouNR := EES->(DbSeek(xFilial("EES")+AVKEY(EC1->EC1_NR_CON, "ECF_NR_CON")))
   IF ! lAchouNR 
      lAchouNR := EEQ->(DbSeek(xFilial("EEQ")+AVKEY(EC1->EC1_NR_CON, "ECF_NR_CON")))
   Endif
Endif
IF ! lAchouNR
   Reclock('EC1',.F.)
   EC1->EC1_STATUS := "E"
   EC1->EC1_OK := "1"
   EC1->(MsUnlock())
Else
   MsgInfo(STR0011) //"Contabilização não estornada !!!"
EndIf

Return .T.

*-----------------------*
Function PF300CANC()
*-----------------------*
oProcess:SetRegua1(Val(cTotProc))
oProcess:IncRegua1(STR0012+"1 / "+cTotProc+" "+STR0009)
PF300CaEF3()   //"Cancelando Eventos do Contrato."

oProcess:IncRegua1(STR0012+"2 / "+cTotProc+" "+STR0010)
PF300CaECF() //"Cancelando V.C. do Contrato."

If lTemEEQNew
   oProcess:IncRegua1(STR0012+"3 / "+cTotProc+" "+STR0016)
   PF300CaEMB()    //"Cancelando Parcelas do Embarque."
Endif

If lTemEETNew
   oProcess:IncRegua1(STR0012+"4 / "+cTotProc+" "+STR0017)
   PF300CaDES() //"Cancelando Despesas de Exportação."
Endif

If lTemEESNew
   oProcess:IncRegua1(STR0012+"5 / "+cTotProc+" "+STR0021)
   PF300CaEES() //"Cancelando Itens da Nota Fiscal."
Endif

oProcess:IncRegua1(STR0012+"6 / "+cTotProc+" "+STR0014)
PF300CaECH() //Cancelando Totais das Contas...

If lExisteECE
   oProcess:IncRegua1(STR0028+"7 / "+cTotProc+" "+STR0014) //"Cancelando Eventos de Estorno..."
   PF300CaECE() //"Cancelando Processos Estornados."
Endif

//If(EasyEntryPoint("ECOPF300"),Execblock("ECOPF300",.F.,.F.,"Cancela_FIM"),)
If EasyEntryPoint("ECOPF300")
   EasyExRdm("U_ECOPF300", "Cancela_FIM")   
EndIf

Return .T.

*-----------------------------*
Function PF300CaECH()
*-----------------------------*
Local cFilECH := xFilial('ECH') // ECH -> RESULTADO DAS CONTAS
oProcess:SetRegua2(nContECH)
ECH->(DbSetOrder(1))
ECH->(DbSeek(cFilECH+'EXPORT'+AVKEY(EC1->EC1_NR_CON, "ECH_NR_CON")))

Do While ECH->(!Eof()) .AND. Alltrim(EC1->EC1_NR_CON) = Alltrim(ECH->ECH_NR_CON) .AND. ECH->ECH_FILIAL = cFilECH
   Reclock('ECH',.F.)
   ECH->(DBDELETE())
   ECH->(MSUNLOCK())
   ECH->(DbSeek(cFilECH+'EXPORT'+AVKEY(EC1->EC1_NR_CON, "ECH_NR_CON")))
EndDo
Return .T.

*-----------------------------*
Function PF300CaEF3()
*-----------------------------*
 Local aContratos := {}  // PLB 13/06/07
 Local bContratos := {||}

   oProcess:SetRegua2(nContEF3)

   cMes := STRZERO(VAL(EC1->EC1_MES)+1,2,0)
   cAno := SUBSTR(EC1->EC1_ANO,3,4)
   IF cMes = "13"
      cMes := "01"
      cAno := STRZERO(VAL(cAno)+1,4,0)
   Endif
   dDta_Ini := AVCTOD("01/"+EC1->EC1_MES+"/"+EC1->EC1_ANO)
   dDta_Fim  := AVCTOD("01/"+cMes+"/"+cAno) - 1

   // ** PLB 13/06/07   
   If lEFFTpMod
      bContratos := { |x| x[1]+x[2]+x[3]+x[4] == EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT }
   ElseIf lTemEF1PRA
      bContratos := { |x| x[1]+x[2]+x[3] == EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA }
   Else
      bContratos := { |x| x == EF1->EF1_CONTRA }
   EndIf
   // **

   EF1->(DbSetOrder(1))
   EF3->(DbSetOrder(5))

   //EF3->(DbSeek(cFilEF3+IF(lEFFTpMod,'E','')+AVKEY(EC1->EC1_NR_CON, "EF3_NR_CON"))) // Nick 07/07/06 Incluido o TPMODU = E
   //Do While EF3->(!Eof()) .AND. Alltrim(EC1->EC1_NR_CON) = Alltrim(EF3->EF3_NR_CON) .AND. EF3->EF3_FILIAL = cFilEF3

   // PLB 13/06/07
   Do While EF3->( DBSeek( cFilEF3+IIF( lEFFTpMod, "E", "" )+AvKey( EC1->EC1_NR_CON, "EF3_NR_CON" ) ) )

      oProcess:IncRegua2("1 / 1 "+STR0013+Alltrim(EF3->EF3_CONTRA) + ' ' + STR0023 +  Alltrim(EF3->EF3_INVOIC) ) //"Contrato: "
   
      IF lTemEF1PRA // MJA 29/01/05
         EF1->(DbSeek(cFilEF1+IF(lEFFTpMod,EF3->EF3_TPMODU,'')+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,''))) // Nick 07/07/06 Incluido o TPMODU
      ELSE
         EF1->(DbSeek(cFilEF1+IF(lEFFTpMod,EF3->EF3_TPMODU,'')+EF3->EF3_CONTRA)) // Nick 07/07/06 Incluido o TPMODU
      ENDIF 
      /* If ! Empty(EF1->EF1_DT_JUR) .and. EF1->EF1_DT_JUR <= dDta_Fim
         lEve100 := .T.   
      Else                
         lEve100 := .F.          
      EndIf*/

      // Realiza estorno dos saldos do contrato
      If EF3->EF3_GERECO = '1'       // Evento foi gerado na contabilização
         lContab := .T.
         Reclock("EF1", .F.)
         If EF3->EF3_TP_EVE = '01'   // ACC
         	 If EF3->EF3_CODEVE $ '500/501'
               EF1->EF1_SLD_PR -= EF3->EF3_VL_REA        // Sld. Principal em Reais = Sld.Principal - V.C.
            Elseif EF3->EF3_CODEVE $ '520/550/551'
               EF1->EF1_SLD_JR -= EF3->EF3_VL_REA        // Sld. Juros ACC em Reais = Sld.Anterior - V.C - Prov. Juros
               If EF3->EF3_CODEVE $ '520'
                  EF1->EF1_SLD_JM -= EF3->EF3_VL_MOE     // Sld. Juros ACC na Moeda = Sld.Anterior - V.C.
               Endif
            Endif
         Else  						// ACE
            If EF3->EF3_CODEVE $ '500/501'
               EF1->EF1_SL2_PR -= EF3->EF3_VL_REA         // Sld. Principal em Reais = Sld.Principal - V.C.
            Elseif EF3->EF3_CODEVE $ '520/550/551'
               EF1->EF1_SL2_JR -= EF3->EF3_VL_REA         // Sld. Juros ACE em Reais = Sld.Anterior - V.C. - Prov.Juros
               If EF3->EF3_CODEVE $ '520'
                  EF1->EF1_SL2_JM -= EF3->EF3_VL_MOE      // Sld. Juros ACE na Moeda = Sld.Anterior - Prov.Juros
               Endif
            Endif
         Endif

         EF1->(MsUnlock())
         //Endif

         Reclock('EF3',.F.)
         EF3->(DBDELETE())
         EF3->(MSUNLOCK())

      Else

         /*If EF3->EF3_CODEVE $ '100'
            lEve100 := .T.                       
         Endif   VI 30/07/03 */
         
         lContab := .T.
         Reclock('EF3',.F.)
         EF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
         EF3->(MSUNLOCK())

      Endif
   
      // Retorna as datas de contabilização e taxa do mes anterior

      //If ! Empty(EF1->EF1_DT_JUR) .and. EF1->EF1_DT_JUR <= dDta_Fim
      //   lEve100 := .T.   
      //Else                
      //   lEve100 := .F.          
      //EndIf

      // If lEve100 
      /*   If ! Empty(EF1->EF1_DT_ANT) .and. ! Empty(EF1->EF1_TX_ANT)
            lContratoNovo := .F.
            Reclock('EF1',.F.)
      //    EF1->EF1_TX_CTB := If(!lEve100, EF1->EF1_TX_ANT, 0)               // Ultima taxa de contabilizacao (ultimo dia do mes)
      //    EF1->EF1_DT_CTB := If(!lEve100, EF1->EF1_DT_ANT, CTOD(' / / '))   // Ultima data da contabilizacao
            EF1->EF1_TX_CTB := EF1->EF1_TX_ANT // Ultima taxa de contabilizacao (ultimo dia do mes)
            EF1->EF1_DT_CTB := EF1->EF1_DT_ANT // Ultima data da contabilizacao
            EF1->EF1_TX_ANT := 0                							 // Ultima taxa de contabilizacao (ultimo dia do mes)
            EF1->EF1_DT_ANT := CTOD(' / / ')    							 // Ultima data da contabilizacao
            EF1->(MSUNLOCK())
         Endif
      */

      // ** PLB 13/06/07
      If AScan( aContratos, bContratos ) == 0
         If lEFFTpMod
            AAdd( aContratos, { EF1->EF1_CONTRA, EF1->EF1_BAN_FI, EF1->EF1_PRACA, EF1->EF1_SEQCNT } )
         ElseIf lTemEF1PRA
            AAdd( aContratos, { EF1->EF1_CONTRA, EF1->EF1_BAN_FI, EF1->EF1_PRACA } )
         Else
            AAdd( aContratos, EF1->EF1_CONTRA )
         EndIf
         Reclock('EF1',.F.)
         EF1->EF1_TX_CTB := EF1->EF1_TX_ANT  // Ultima taxa de contabilizacao (ultimo dia do mes)
         EF1->EF1_DT_CTB := EF1->EF1_DT_ANT  // Ultima data da contabilizacao
         EF1->EF1_TX_ANT := 0                // Ultima taxa de contabilizacao (ultimo dia do mes)
         EF1->EF1_DT_ANT := CTOD(" / / ")    // Ultima data da contabilizacao
         EF1->( MsUnLock() )
      EndIf
      // **

      //EF3->(DbSeek(cFilEF3+IF(lEFFTpMod,'E','')+AVKEY(EC1->EC1_NR_CON, "EF3_NR_CON"))) // Nick 07/07/06 Incluido o TPMODU
   EndDo
       

Return .T.

*-----------------------------*
Function PF300CaECF()
*-----------------------------*

oProcess:SetRegua2(nContECF)

EC6->(DbSetOrder(6))
EC6->(DbSeek(xFilial('EC6')+"EXPORT101")) 
cTX_101 := EC6->EC6_TXCV      
EC6->(DbSetOrder(1))
cDtUlt := ctod('01/'+strzero(month(EC1->EC1_DT_CON),2,0)+'/'+right(strzero(year(EC1->EC1_DT_CON),4,0),2))
cDtUlt -= 1
ECF->(DbSetOrder(4))
ECF->(DbSeek(cFilECF+cTPMODU+AVKEY(EC1->EC1_NR_CON, "ECF_NR_CON")))
lPrim:=.T.
cProc:=ECF->ECF_PREEMB
Do While ECF->(!Eof()) .AND. Alltrim(EC1->EC1_NR_CON) = Alltrim(ECF->ECF_NR_CON) .AND. ECF->ECF_FILIAL = cFilECF .and. Eval(bTPMODUECF)


   oProcess:IncRegua2("1 / 1 "+STR0015+Alltrim(ECF->ECF_PREEMB) ) //"Processo :"

   If cProc <> ECF->ECF_PREEMB
      lPrim:=.T.   
      cProc:=ECF->ECF_PREEMB      
   EndIf
     
   If ECF->ECF_ORIGEM = 'CO' .Or. ECF->ECF_ORIGEM = 'EX'
//    If ECF->ECF_ORIGEM = 'EX' .AND. LEFT(ECF->ECF_ID_CAM,1) $ '580/581/582/583' // VI 31/07/03 .AND. !Empty(ECF->ECF_DTCONV)
//    If ECF->ECF_ORIGEM = 'EX' .AND. ECF->ECF_ID_CAM $ '580/581/582/583' .AND. (ECF->ECF_DTCONT <= EC1->EC1_DT_CON .OR. !Empty(ECF->ECF_DTCONV))
      If lPrim .AND. ECG->(DbSeek(cFilECG+cTPMODU+ECF->ECF_ORIGEM+ECF->ECF_PREEMB))
        //If lPrim .AND. ECG->(DbSeek(cFilECG+cTPMODU+ECF->ECF_ORIGEM+ECF->ECF_PREEMB)) .and. ECF->ECF_ID_CAM $ '580/581/582/583' // Nick Menezes - 21/02/06
         lPrim:=.F.
         //--------------------------------- MJA 20/01/05 Para buscar a taxa de compra e venda correta para cada filial 
         EC6->(DbSetOrder(6))
         EC6->(DbSeek(ECF->ECF_FILORI+"EXPORT101"))
         cTX_101 := EC6->EC6_TXCV
         EC6->(DbSetOrder(1))
         //--------------------------------- Fim
         Reclock('ECG',.F.)
         IF ECF->ECF_TIPO = 'A' // Nick 11/09/06 Correcao de cancelamento para voltar a txa anterior para adiantamentos
            ECG->ECG_ULT_TX := ECF->ECF_FLUTUA
         Else
            ECG->ECG_ULT_TX := ECOPF300Tx(ECF->ECF_MOEDA, cDtUlt, cTX_101)
         Endif
         ECG->(MSUNLOCK())
      Endif   
      
      lContab := .T.
      If ECF->ECF_ID_CAM = '999' .Or. ECF->ECF_LINK = '999'
         Reclock('ECF',.F.)
         ECF->ECF_NR_CON := SPACE(LEN(ECF->ECF_NR_CON))
         ECF->(MSUNLOCK())
      Else
         Reclock('ECF',.F.)
         ECF->(DBDELETE())
         ECF->(MSUNLOCK())
      Endif   
   Endif

   ECF->(DbSeek(cFilECF+cTPMODU+AVKEY(EC1->EC1_NR_CON, "ECF_NR_CON")))
Enddo

Return .T.

*-----------------------------*
Function PF300CaEMB()
*-----------------------------*
Local aFil := {cFilAnt}/*AvgSelectFil(.F.)*/, i    // MJA 20/01/05        

oProcess:SetRegua2(nContEEQ)
FOR i := 1 to Len(aFil) // For para buscar todas as filiais que o usuário tem permissão de utilizar no EEQ

    EEQ->(DbSetOrder(8))
    EEQ->(DbSeek(xFilial("EEQ")+AVKEY(EC1->EC1_NR_CON, "ECF_NR_CON")))

	Do While EEQ->(!Eof()) .AND. Alltrim(EC1->EC1_NR_CON) = Alltrim(EEQ->EEQ_NR_CON) .AND. EEQ->EEQ_FILIAL = xFilial("EEQ")  // MJA 20/01/05
	
	   oProcess:IncRegua2("1 / 1 "+STR0015 + Alltrim(EEQ->EEQ_PREEMB) ) //"Processo :"
	
	   lContab := .T.
	   Reclock('EEQ',.F.)
	   EEQ->EEQ_NR_CON := Space(Len(EEQ->EEQ_NR_CON))
	   EEQ->(MSUNLOCK())
	
	   EEQ->(DbSeek(xFilial("EEQ")+AVKEY(EC1->EC1_NR_CON, "ECF_NR_CON"))) // MJA 20/01/05
	Enddo
NEXT i 
Return .T.

*------------------------*
Function PF300CaDES()
*------------------------*

Local aFil := {cFilAnt}/*AvgSelectFil(.F.)*/, i    // MJA 20/01/05        

oProcess:SetRegua2(nContEET)

For i := 1 to Len(aFil)
    EET->(DbSetOrder(2))
	EET->(DbSeek(xFilial("EET")+AVKEY(EC1->EC1_NR_CON, "EET_NR_CON")))
	
	Do While EET->(!Eof()) .AND. Alltrim(EC1->EC1_NR_CON) = Alltrim(EET->EET_NR_CON) .AND. EET->EET_FILIAL = xFilial("EET")
	
	   oProcess:IncRegua2("1 / 1 "+STR0015 + Alltrim(EET->EET_PEDIDO) ) //"Processo :"
	
	   lContab := .T.
	   Reclock('EET',.F.)
	   EET->EET_NR_CON := Space(Len(EET->EET_NR_CON))
	   EET->(MSUNLOCK())
	
	   EET->(DbSeek(xFilial("EET")+AVKEY(EC1->EC1_NR_CON, "EET_NR_CON")))
	Enddo
Next i

Return .T.

*-----------------------------*
Function PF300CaEES()
*-----------------------------*                              

Local aFil := {cFilAnt}/*AvgSelectFil(.F.)*/, i    // MJA 20/01/05        

oProcess:SetRegua2(nContEES)

For i := 1 to Len(aFil)
    EES->(DbSetOrder(2))
	EES->(DbSeek(xFilial("EES")+AVKEY(EC1->EC1_NR_CON, "EES_NR_CON")))
	
	Do While EES->(!Eof()) .AND. Alltrim(EC1->EC1_NR_CON) = Alltrim(EES->EES_NR_CON) .AND. EES->EES_FILIAL = xFilial("EES")
	
	   oProcess:IncRegua2("1 / 1 "+STR0015 + Alltrim(EES->EES_PREEMB) ) //"Processo :"
	
	   lContab := .T.
	   Reclock('EES',.F.)
	   EES->EES_NR_CON := Space(Len(EES->EES_NR_CON))
	   EES->(MSUNLOCK())
	
	   EES->(DbSeek(xFilial("EES")+AVKEY(EC1->EC1_NR_CON, "EES_NR_CON")))
	Enddo
Next i	
Return .T.


*-------------------------------*
Function PF300ContaReg()
*-------------------------------*
Local cQueryEF3, cQueryECF, cQueryEEQ, cQueryEET, cQueryEES, cQueryECH
Local cAliasEF3, cAliasECF, cAliasEEQ, cAliasEET, cAliasEES, cAliasECH
Local cQuery, cFilECH := xFilial('ECH')
Local aFil := {cFilAnt}/*AvgSelectFil(.F.)*/, i    // MJA 20/01/05        
Private cCondDel := IF(TcSrvType() != "AS/400", "AND D_E_L_E_T_ <> '*' ", "")

If lTop

   cAliasEF3 := "EF3TMP"
   cAliasECF := "ECFTMP"
   cAliasEEQ := "EEQTMP"
   cAliasEET := "EETTMP"
   cAliasEES := "EESTMP"
   cAliasECH := "ECHTMP"   

   // Query EF3
   cQueryEF3 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EF3")+ " WHERE EF3_FILIAL='" + cFilEF3 + "' "
   cQueryEF3 += IF(lEFFTpMod,"AND EF3_TPMODU = 'E' ","")+"AND EF3_NR_CON = '" + EC1->EC1_NR_CON + "' " + cCondDel // Nick 07/07/06
   PF300ExecQry(cQueryEF3, cAliasEF3)
   If Select(cAliasEF3) > 0
      nContEF3  := (cAliasEF3)->TOTALREG
      (cAliasEF3)->(DbCloseArea())
   Else
      nContEF3  := 0
   Endif

   // Query ECH
   cQueryECH := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECH")+ " WHERE ECH_FILIAL='" + cFilECH + "' "
   cQueryECH += "AND ECH_NR_CON = '" + EC1->EC1_NR_CON + "' " + cCondDel
   PF300ExecQry(cQueryECH, cAliasECH)
   If Select(cAliasECH) > 0
      nContECH  := (cAliasECH)->TOTALREG
      (cAliasECH)->(DbCloseArea())
   Else
      nContECH  := 0
   Endif
               
   // Query ECF
   cQueryECF := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECF")+ " WHERE ECF_FILIAL='"  + cFilECF + "' " 
   cQueryECF += "AND ECF_NR_CON = '" + EC1->EC1_NR_CON + "' " + cCondDel 
   PF300ExecQry(cQueryECF, cAliasECF)
   If Select(cAliasECF) > 0
      nContECF  := (cAliasECF)->TOTALREG
      (cAliasECF)->(DbCloseArea())
   Else
      nContECF  := 0
   Endif
   
   // Query EEQ               

   cFil:="'"
   aEval(aFil,{|x,y| cFil += x + iIF(y == Len(aFil),"'","','")})

   cQueryEEQ := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EEQ")+ " WHERE EEQ_FILIAL IN (" + cFil + ") "
   cQueryEEQ += "AND EEQ_NR_CON = '" + EC1->EC1_NR_CON + "' " + cCondDel 
   If lTemEEQNew
      PF300ExecQry(cQueryEEQ, cAliasEEQ)
      If Select(cAliasEEQ) > 0
         nContEEQ  := (cAliasEEQ)->TOTALREG
         (cAliasEEQ)->(DbCloseArea())
      Else
         nContEEQ  := 0
      Endif
   Endif

   // Query EET
   cQueryEET := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EET")+ " WHERE EET_FILIAL IN (" + cFil + ") "
   cQueryEET += "AND EET_NR_CON = '" + EC1->EC1_NR_CON + "' " + cCondDel 
   If lTemEETNew
      PF300ExecQry(cQueryEET, cAliasEET)
      If Select(cAliasEET) > 0
         nContEET  := (cAliasEET)->TOTALREG
         (cAliasEET)->(DbCloseArea())
      Else
         nContEET  := 0
      Endif
   Endif   
   
   // Query EES
   cQueryEES := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EES")+ " WHERE EES_FILIAL IN (" + cFil + ") "
   cQueryEES += "AND EES_NR_CON = '" + EC1->EC1_NR_CON + "' " + cCondDel
   If lTemEESNew
      PF300ExecQry(cQueryEES, cAliasEES)
      If Select(cAliasEES) > 0
         nContEES  := (cAliasEES)->TOTALREG
         (cAliasEES)->(DbCloseArea())
      Else
         nContEES  := 0
      Endif
   Endif

Else
  
   *--------> EF3
   nContEF3 := 0
   EF3->(DbSeek(cFilEF3+IF(lEFFTpMod,'E','')+AVKEY(EC1->EC1_NR_CON, "EF3_NR_CON"))) // Nick Incluido o TPMODU
   EF3->(DbEval({||nContEF3++, MsProcTxt(STR0013+EF3->EF3_CONTRA) },,{||EF3->(!Eof()) .And. Alltrim(EF3->EF3_NR_CON) = Alltrim(EC1->EC1_NR_CON) .And. EF3->EF3_FILIAL=cFilEF3},,,.T.)) //"Contrato : "

   *--------> ECH
   nContECH := 0
   ECH->(DbSeek(cFilECH+cTPMODU+AVKEY(EC1->EC1_NR_CON, "ECH_NR_CON")))
   ECH->(DbEval({||nContECH++, MsProcTxt(STR0026+ECH->ECH_CONTA) },,{||ECH->(!Eof()) .And. Alltrim(ECH->ECH_NR_CON) = Alltrim(EC1->EC1_NR_CON) .And. ECH->ECH_FILIAL=cFilECH},,,.T.)) //"Conta : "
   
   *--------> ECF               
   nContECF := 0
   ECF->(DbSeek(cFilECF+cTPMODU+AVKEY(EC1->EC1_NR_CON, "ECF_NR_CON")))
   ECF->(DbEval({||nContECF++, MsProcTxt(STR0015+ECF->ECF_PREEMB) },,{||ECF->(!EOF()) .And. Eval(bTPMODUECF) .and. Alltrim(ECF->ECF_NR_CON) = Alltrim(EC1->EC1_NR_CON) .And. ECF->ECF_FILIAL=cFilECF})) //"Processo :"
   
   For i:=1 to Len(aFil)
   
	   *--------> EEQ
	   If lTemEEQNew
	      nContEEQ := 0
	      EEQ->(DbSeek(xFilial("EEQ")+AVKEY(EC1->EC1_NR_CON, "EEQ_NR_CON")))
	      EEQ->(DbEval({||nContEEQ++, MsProcTxt(STR0015+EEQ->EEQ_PREEMB) },,{||EEQ->(!Eof()) .And. Alltrim(EEQ->EEQ_NR_CON) = Alltrim(EC1->EC1_NR_CON) .And. EEQ->EEQ_FILIAL=xFilial("EEQ")},,,.T.)) //"Processo : "
	   Endif
	   
	   *--------> EET
	   If lTemEETNew
	      nContEET := 0
	      EET->(DbSeek(xFilial("EET")+AVKEY(EC1->EC1_NR_CON, "EET_NR_CON")))
	      EET->(DbEval({||nContEET++, MsProcTxt(STR0015+EET->EET_PEDIDO) },,{||EET->(!Eof()) .And. Alltrim(EET->EET_NR_CON) = Alltrim(EC1->EC1_NR_CON) .And. EET->EET_FILIAL=xFilial("EET")},,,.T.)) //"Processo : "
	   Endif
	
	   //If(EasyEntryPoint("ECOPF300"),Execblock("ECOPF300",.F.,.F.,"EZCCODBASE"),)
	   
	   *--------> EES
	   If lTemEESNew
	      nContEES := 0
	      EES->(DbSeek(xFilial("EES")+AVKEY(EC1->EC1_NR_CON, "EES_NR_CON")))
	      EES->(DbEval({||nContEES++, MsProcTxt(STR0015+EES->EES_PREEMB) },,{||EES->(!Eof()) .And. Alltrim(EES->EES_NR_CON) = Alltrim(EC1->EC1_NR_CON) .And. EES->EES_FILIAL=xFilial("EES")},,,.T.)) //"Processo : "
	   Endif
   
   Next i
Endif

//Rdmake para o Diario Auxiliar 
If(EasyEntryPoint("ECOPF300"),Execblock("ECOPF300",.F.,.F.,"GeraQuery"),)

Return .T.

*-------------------------------------*
Function PF300ExecQry(cQuery, cAlias)
*-------------------------------------*

 cQuery := ChangeQuery(cQuery)
 DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAlias,.F.,.T.)

Return .T.

*------------------------------------------*
FUNCTION ECOPF300Tx(PInd, PData, cTipoTx)
*------------------------------------------*
Local aTabMsg:={}  //Alcir Alves - 18-04-05
Local nTaxaECO:=0, nAPos          

// 1-Venda , 2-Compra
If Empty(Alltrim(cTipoTx)) 
   cTipoTx := '2'
EndIF

nAPos := aScan(aTaxas,{|x| x[1]==PInd .and. x[2]==PData .and. x[3]==cTipoTx }) 
If nAPos > 0
   nTaxaECO := aTaxas[nAPos,4]
Else
   nTaxaECO := ECOBuscaTaxa(PInd, PData,.F.,,cTipoTx)
   AAdd(aTaxas,{PInd, PData, cTipoTx, nTaxaEco})
   If ECB->(Eof()) .or. nTaxaECO = 0
      AADD(aTabMsg, STR0024+ Pind +") "+ Dtoc(PData)) //"Taxa Zerada - ("
   Endif
Endif

Return nTaxaECO         
                     
//AAF 10/09/07
*********************
Function PF300CaECE()
*********************
Local cNrCon := AVKEY(EC1->EC1_NR_CON, "ECE_NR_CON")
Local cFilECE:= xFilial("ECE")

ECE->(DBSETORDER(2))
ECE->(DBSEEK(cFilECE+cTPMODU+cNrCon))
DO WHILE ! ECE->(EOF()) .AND. cNrCon == ECE->ECE_NR_CON .AND. ECE->ECE_FILIAL = cFilECE .AND. cTpModu == ECE->ECE_TPMODU
   
   Reclock('ECE',.F.)
   ECE->ECE_NR_CON := '0000'
   ECE->(MSUNLOCK())
   ECE->(DBSEEK(cFilECE+cTPMODU+cNrCon))
ENDDO
ECE->(DBSETORDER(1))

Return .T.
